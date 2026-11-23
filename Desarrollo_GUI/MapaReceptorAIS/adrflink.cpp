#include "adrflink.h"

#include <QAbstractSocket>
#include <QTcpSocket>
#include <QtEndian>

namespace {
constexpr char kCmdAgcGet = 0x1C;
constexpr int kStatusBytes = 36;                 // nueve palabras de 32 bits
constexpr int kBodyBytes = kStatusBytes + 52;    // mas trece parametros
constexpr int kFrameBytes = 1 + kBodyBytes;
constexpr int kPollMs = 500;
constexpr int kReplyTimeoutMs = 2000;
constexpr int kConnectTimeoutMs = 4000;
constexpr int kRetryMs = 2000;

quint32 word(const char *p)
{
    return qFromLittleEndian<quint32>(reinterpret_cast<const uchar *>(p));
}
} // namespace

AdrfLink::AdrfLink(QObject *parent)
    : QObject(parent)
    , m_socket(new QTcpSocket(this))
{
    qRegisterMetaType<AgcStatus>("AgcStatus");
    m_poll.setInterval(kPollMs);
    m_watchdog.setSingleShot(true);
    m_retry.setSingleShot(true);
    m_retry.setInterval(kRetryMs);

    connect(m_socket, &QTcpSocket::connected, this, [this] {
        m_connecting = false;
        m_watchdog.stop();
        m_buffer.clear();
        requestStatus();
        m_poll.start();
    });
    connect(m_socket, &QTcpSocket::readyRead, this, &AdrfLink::onReadyRead);
    connect(m_socket, &QTcpSocket::disconnected, this, [this] {
        if (m_wanted)
            drop(tr("El servidor del ADRF cerró la conexión"));
    });
    connect(m_socket, &QTcpSocket::errorOccurred, this, [this](QAbstractSocket::SocketError error) {
        if (!m_wanted)
            return;
        if (error == QAbstractSocket::RemoteHostClosedError)
            drop(tr("El servidor del ADRF cerró la conexión"));
        else
            drop(m_connecting ? tr("No se pudo conectar con el servidor del ADRF (%1:%2): %3")
                                    .arg(m_host).arg(m_port).arg(m_socket->errorString())
                              : tr("Error en el enlace con el servidor del ADRF: %1").arg(m_socket->errorString()));
    });
    connect(&m_poll, &QTimer::timeout, this, &AdrfLink::requestStatus);
    connect(&m_watchdog, &QTimer::timeout, this, &AdrfLink::onTimeout);
    connect(&m_retry, &QTimer::timeout, this, &AdrfLink::connectNow);
}

AdrfLink::~AdrfLink()
{
    m_wanted = false;
    m_socket->abort();
}

void AdrfLink::open(const QString &host, quint16 port)
{
    if (m_wanted && host == m_host && port == m_port)
        return;
    close();
    m_host = host;
    m_port = port;
    m_wanted = true;
    m_lastMessage.clear();
    connectNow();
}

void AdrfLink::close()
{
    const bool wasLinked = m_linked;
    m_wanted = false;
    m_poll.stop();
    m_watchdog.stop();
    m_retry.stop();
    m_connecting = false;
    m_socket->abort();
    m_buffer.clear();
    if (wasLinked)
        setLink(false, tr("Enlace con el ADRF cerrado"));
    m_lastMessage.clear();
}

void AdrfLink::connectNow()
{
    if (!m_wanted)
        return;
    m_connecting = true;
    m_buffer.clear();
    m_watchdog.start(kConnectTimeoutMs);
    m_socket->connectToHost(m_host, m_port);
}

void AdrfLink::requestStatus()
{
    if (m_socket->state() != QAbstractSocket::ConnectedState || m_watchdog.isActive())
        return; // una consulta a la vez
    const char request[5] = {kCmdAgcGet, 0, 0, 0, 0};
    m_buffer.clear();
    m_socket->write(request, sizeof(request));
    m_watchdog.start(kReplyTimeoutMs);
}

void AdrfLink::onReadyRead()
{
    m_buffer += m_socket->readAll();
    if (m_buffer.size() < kFrameBytes)
        return;
    AgcStatus status;
    if (!parse(m_buffer.left(kFrameBytes), &status))
        return;
    m_buffer.clear();
    m_watchdog.stop();
    if (!m_linked)
        setLink(true, tr("Enlace con el servidor del ADRF en %1:%2").arg(m_host).arg(m_port));
    emit statusUpdated(status);
}

void AdrfLink::onTimeout()
{
    if (m_connecting) {
        drop(tr("Sin respuesta del servidor del ADRF en %1:%2").arg(m_host).arg(m_port));
    } else if (m_buffer.size() == 1 && m_buffer.at(0) == 0) {
        drop(tr("El servidor del ADRF no conoce el comando del AGC: ¿es una versión anterior?"));
    } else {
        drop(tr("El servidor del ADRF no contesta (%1:%2): ¿hay otro cliente conectado a ese puerto?").arg(m_host).arg(m_port));
    }
}

void AdrfLink::drop(const QString &message)
{
    m_poll.stop();
    m_watchdog.stop();
    m_connecting = false;
    m_socket->blockSignals(true); // abort() emite disconnected(): ya se esta tratando
    m_socket->abort();
    m_socket->blockSignals(false);
    m_buffer.clear();
    if (m_linked || message != m_lastMessage)
        setLink(false, message);
    if (m_wanted)
        m_retry.start();
}

void AdrfLink::setLink(bool linked, const QString &message)
{
    m_linked = linked;
    m_lastMessage = message;
    emit linkChanged(linked, message);
}

bool AdrfLink::parse(const QByteArray &frame, AgcStatus *out)
{
    if (frame.size() < kFrameBytes)
        return false;
    const char *d = frame.constData() + 1;
    AgcStatus s;
    s.available = frame.at(0) == 0x01;
    s.active = word(d) != 0;
    s.gainDb = qint32(word(d + 4)) / 1000.0;
    s.bursts = word(d + 8);
    s.changes = word(d + 12);
    s.protections = word(d + 16);
    s.lastPeak = word(d + 20);
    s.serverMs = word(d + 24);
    s.seq = word(d + 28);
    s.errors = word(d + 32);
    const char *p = d + kStatusBytes; // objetivo, ventana, percentil, zona muerta, kp, paso max, liberacion, paso lib, proteccion, gmin, gmax, planta, ginicial
    s.target = word(p);
    s.window = int(word(p + 4));
    s.percentile = word(p + 8) / 100.0;
    s.deadZoneDb = word(p + 12) / 100.0;
    s.minGainDb = word(p + 36) / 1000.0;
    s.maxGainDb = word(p + 40) / 1000.0;
    *out = s;
    return true;
}
