#include "receiverlink.h"

#include <QTcpSocket>
#include <QtEndian>

namespace {

constexpr quint8 kCmdReadAdc = 0x03;
constexpr quint8 kCmdSetFifo = 0x04;
constexpr quint8 kCmdSetCfg = 0x05;
constexpr quint8 kCmdSetOutput = 0x22;
constexpr quint8 kCmdGetStatus = 0x23;

constexpr double kNcoHz = 10.7e6;    // frecuencia del NCO del receptor (la FI)
constexpr double kClockHz = 125e6;   // reloj de muestreo de la Red Pitaya
constexpr int kPollMs = 20;          // pausa entre lecturas del estado
constexpr quint32 kMaxWords = 4096;  // palabras por lectura (la FIFO guarda hasta 65535)
constexpr int kStatusBytes = 12;

} // namespace

ReceiverLink::ReceiverLink(QObject *parent)
    : QObject(parent)
{
    m_poll.setSingleShot(true);
    connect(&m_poll, &QTimer::timeout, this, &ReceiverLink::requestStatus);
    m_watchdog.setSingleShot(true);
    connect(&m_watchdog, &QTimer::timeout, this, [this] {
        fail(tr("El receptor no responde (más de %1 ms sin contestar)").arg(m_timeoutMs));
    });
}

ReceiverLink::~ReceiverLink()
{
    close();
}

void ReceiverLink::open(const QString &host, quint16 port, int timeoutMs)
{
    close();
    m_timeoutMs = qMax(1000, timeoutMs);
    m_step = Step::Startup;
    m_startIndex = 0;

    const quint32 pinc = quint32(qRound64(kNcoHz / kClockHz * double(1 << 30)));
    m_startup = {
        {kCmdSetCfg, pinc << 1, tr("configurar el NCO")},
        {kCmdSetCfg, (pinc << 1) | 1u, tr("poner en marcha el receptor")},
        {kCmdSetOutput, 0, tr("elegir la salida demodulada")},
        {kCmdSetFifo, 0, tr("vaciar la FIFO")},
        {kCmdSetFifo, 1, tr("vaciar la FIFO")},
    };

    m_socket = new QTcpSocket(this);
    m_socket->setSocketOption(QAbstractSocket::LowDelayOption, 1);
    connect(m_socket, &QTcpSocket::connected, this, &ReceiverLink::sendStartup);
    connect(m_socket, &QTcpSocket::readyRead, this, [this] {
        m_buffer += m_socket->readAll();
        process();
    });
    connect(m_socket, &QTcpSocket::errorOccurred, this, [this](QAbstractSocket::SocketError error) {
        switch (error) {
        case QAbstractSocket::ConnectionRefusedError:
            fail(tr("Conexión rechazada: ¿está corriendo el adc_server en la Red Pitaya (puerto de datos)?"));
            break;
        case QAbstractSocket::RemoteHostClosedError:
            fail(tr("La Red Pitaya cerró la conexión"));
            break;
        case QAbstractSocket::HostNotFoundError:
            fail(tr("No se encontró la dirección de la Red Pitaya"));
            break;
        default:
            fail(m_socket->errorString());
            break;
        }
    });
    connect(m_socket, &QTcpSocket::disconnected, this,
            [this] { fail(tr("La Red Pitaya cerró la conexión")); });
    m_socket->connectToHost(host, port);
}

void ReceiverLink::close()
{
    m_step = Step::Closed;
    m_ready = false;
    m_poll.stop();
    m_watchdog.stop();
    m_buffer.clear();
    if (m_socket) {
        m_socket->disconnect(this);
        m_socket->abort();
        m_socket->deleteLater();
        m_socket = nullptr;
    }
}

void ReceiverLink::fail(const QString &message)
{
    if (m_step == Step::Closed)
        return;
    close();
    emit failed(message);
}

void ReceiverLink::send(quint8 cmd, quint32 payload)
{
    QByteArray frame(5, 0);
    frame[0] = char(cmd);
    qToLittleEndian(payload, reinterpret_cast<uchar *>(frame.data()) + 1);
    m_socket->write(frame);
    m_watchdog.start(m_timeoutMs);
}

void ReceiverLink::sendStartup()
{
    const StartupCommand &c = m_startup.at(m_startIndex);
    send(c.cmd, c.payload);
}

void ReceiverLink::requestStatus()
{
    if (m_step != Step::Idle)
        return;
    m_step = Step::WaitStatus;
    send(kCmdGetStatus, 0);
}

void ReceiverLink::process()
{
    while (m_socket) {
        switch (m_step) {
        case Step::Startup: {
            if (m_buffer.isEmpty())
                return;
            const char ack = m_buffer.at(0);
            m_buffer.remove(0, 1);
            m_watchdog.stop();
            if (ack != 0x01) {
                fail(tr("El servidor de datos rechazó el paso «%1»: ¿es el adc_server de la Red Pitaya?")
                         .arg(m_startup.at(m_startIndex).what));
                return;
            }
            if (++m_startIndex < m_startup.size()) {
                sendStartup();
                continue;
            }
            m_ready = true;
            m_step = Step::Idle;
            m_poll.start(0);
            emit connected();
            continue;
        }
        case Step::WaitStatus: {
            if (m_buffer.size() < kStatusBytes)
                return;
            const auto *b = reinterpret_cast<const uchar *>(m_buffer.constData());
            const quint32 s0 = qFromLittleEndian<quint32>(b);
            const quint32 s1 = qFromLittleEndian<quint32>(b + 4);
            m_buffer.remove(0, kStatusBytes);
            m_watchdog.stop();
            const quint32 fifoWords = s0 & 0xFFFFu;
            emit statusUpdated(((s1 & 0xFu) << 16) | (s0 >> 16), ((s1 >> 4) & 1u) != 0, fifoWords);
            if (m_step != Step::WaitStatus)
                return; // el receptor de la senal cerro el enlace
            const quint32 n = qMin(fifoWords & ~1u, kMaxWords); // la FIFO se lee de a pares de palabras
            if (n >= 2) {
                m_wantWords = n;
                m_step = Step::WaitData;
                send(kCmdReadAdc, n);
            } else {
                m_step = Step::Idle;
                m_poll.start(kPollMs);
            }
            continue;
        }
        case Step::WaitData: {
            const int need = int(m_wantWords) * 4;
            if (m_buffer.size() < need)
                return;
            QVector<quint32> words;
            words.resize(int(m_wantWords));
            const auto *b = reinterpret_cast<const uchar *>(m_buffer.constData());
            for (int i = 0; i < words.size(); ++i)
                words[i] = qFromLittleEndian<quint32>(b + 4 * i);
            m_buffer.remove(0, need);
            m_watchdog.stop();
            m_step = Step::Idle;
            m_poll.start(m_wantWords >= kMaxWords ? 0 : kPollMs); // con atraso, sigue enseguida
            emit wordsReceived(words);
            continue;
        }
        case Step::Idle:
            m_buffer.clear(); // no se espera nada: lo que llegue esta desfasado
            return;
        case Step::Closed:
            return;
        }
    }
}
