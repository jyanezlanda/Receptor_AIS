#include "connectionmanager.h"

#include "receiverlink.h"

#include <QHostAddress>
#include <QNetworkDatagram>
#include <QTcpServer>
#include <QTcpSocket>
#include <QUdpSocket>

QString ConnectionConfig::summary() const
{
    if (interface == Interface::Serial)
        return QStringLiteral("Serie %1 @ %2").arg(serialPort).arg(baudRate);

    const QString medium = interface == Interface::Wifi ? QStringLiteral("WiFi")
                                                        : QStringLiteral("Ethernet");
    if (dataFormat == DataFormat::Receiver)
        return QStringLiteral("%1 Receptor %2:%3").arg(medium, host).arg(port);
    if (protocol == Protocol::Udp)
        return QStringLiteral("%1 UDP :%2").arg(medium).arg(localPort);
    if (role == Role::Server)
        return QStringLiteral("%1 TCP servidor :%2").arg(medium).arg(localPort);
    return QStringLiteral("%1 TCP %2:%3").arg(medium, host).arg(port);
}

ConnectionManager::ConnectionManager(QObject *parent)
    : QObject(parent)
{
    m_connectTimeout.setSingleShot(true);
    connect(&m_connectTimeout, &QTimer::timeout, this,
            [this] { fail(tr("Tiempo de espera agotado al conectar con %1:%2")
                              .arg(m_config.host).arg(m_config.port)); });

    m_reconnectTimer.setSingleShot(true);
    m_reconnectTimer.setInterval(3000);
    connect(&m_reconnectTimer, &QTimer::timeout, this, [this] {
        if (m_wantOpen)
            open(m_config);
    });
}

ConnectionManager::~ConnectionManager()
{
    m_wantOpen = false;
    releaseResources();
}

QString ConnectionManager::stateText(State state)
{
    switch (state) {
    case State::Disconnected: return tr("Desconectado");
    case State::Connecting:   return tr("Conectando…");
    case State::Listening:    return tr("Esperando datos");
    case State::Connected:    return tr("Conectado");
    case State::Error:        return tr("Error");
    }
    return {};
}

QString ConnectionManager::stateColor(State state)
{
    switch (state) {
    case State::Disconnected: return QStringLiteral("#7f8c8d");
    case State::Connecting:   return QStringLiteral("#f39c12");
    case State::Listening:    return QStringLiteral("#2980b9");
    case State::Connected:    return QStringLiteral("#27ae60");
    case State::Error:        return QStringLiteral("#c0392b");
    }
    return {};
}

void ConnectionManager::open(const ConnectionConfig &config)
{
    m_reconnectTimer.stop();
    releaseResources();
    m_config = config;
    m_wantOpen = true;
    m_rxBytes = 0;

    if (config.dataFormat == ConnectionConfig::DataFormat::Receiver)
        openReceiver();
    else if (config.interface == ConnectionConfig::Interface::Serial)
        openSerial();
    else if (config.protocol == ConnectionConfig::Protocol::Udp)
        openUdp();
    else if (config.role == ConnectionConfig::Role::Server)
        openTcpServer();
    else
        openTcpClient();
}

void ConnectionManager::close()
{
    m_wantOpen = false;
    m_reconnectTimer.stop();
    releaseResources();
    setState(State::Disconnected, tr("Conexión cerrada"));
}

qint64 ConnectionManager::send(const QByteArray &data)
{
    if (m_serial && m_serial->isOpen())
        return m_serial->write(data);
    if (m_tcp && m_tcp->state() == QAbstractSocket::ConnectedState)
        return m_tcp->write(data);
    if (m_udp && !m_config.host.isEmpty())
        return m_udp->writeDatagram(data, QHostAddress(m_config.host), m_config.port);
    return -1;
}

// ---------------------------------------------------------------------------

void ConnectionManager::openSerial()
{
    if (m_config.serialPort.isEmpty()) {
        fail(tr("No se seleccionó ningún puerto serie"));
        return;
    }
    m_serial = new QSerialPort(this);
    m_serial->setPortName(m_config.serialPort);
    m_serial->setBaudRate(m_config.baudRate);
    m_serial->setDataBits(m_config.dataBits);
    m_serial->setParity(m_config.parity);
    m_serial->setStopBits(m_config.stopBits);
    m_serial->setFlowControl(m_config.flowControl);

    if (!m_serial->open(QIODevice::ReadWrite)) {
        fail(tr("No se pudo abrir %1: %2").arg(m_config.serialPort, m_serial->errorString()));
        return;
    }
    connect(m_serial, &QSerialPort::readyRead, this,
            [this] { handleData(m_serial->readAll()); });
    connect(m_serial, &QSerialPort::errorOccurred, this, [this](QSerialPort::SerialPortError e) {
        if (e != QSerialPort::NoError && e != QSerialPort::TimeoutError)
            fail(tr("Error en %1: %2").arg(m_config.serialPort, m_serial->errorString()));
    });
    setState(State::Connected, tr("Puerto %1 abierto").arg(m_config.serialPort));
}

void ConnectionManager::openTcpClient()
{
    auto *socket = new QTcpSocket(this);
    if (!m_config.localAddress.isEmpty())
        socket->bind(QHostAddress(m_config.localAddress));
    attachTcpSocket(socket, false);
    setState(State::Connecting, tr("Conectando con %1:%2…").arg(m_config.host).arg(m_config.port));
    m_connectTimeout.start(m_config.timeoutMs);
    socket->connectToHost(m_config.host, m_config.port);
}

void ConnectionManager::openTcpServer()
{
    m_server = new QTcpServer(this);
    const QHostAddress bindAddr = m_config.localAddress.isEmpty()
                                      ? QHostAddress(QHostAddress::Any)
                                      : QHostAddress(m_config.localAddress);
    if (!m_server->listen(bindAddr, m_config.localPort)) {
        fail(tr("No se pudo escuchar en el puerto %1: %2")
                 .arg(m_config.localPort)
                 .arg(m_server->errorString()));
        return;
    }
    connect(m_server, &QTcpServer::pendingConnectionAvailable, this, [this] {
        while (QTcpSocket *incoming = m_server->nextPendingConnection()) {
            if (m_tcp) {
                // Solo se admite una Red Pitaya a la vez.
                incoming->disconnectFromHost();
                incoming->deleteLater();
                continue;
            }
            attachTcpSocket(incoming, true);
            setState(State::Connected,
                     tr("Red Pitaya conectada desde %1").arg(incoming->peerAddress().toString()));
        }
    });
    setState(State::Listening, tr("Esperando a la Red Pitaya en el puerto TCP %1")
                                   .arg(m_config.localPort));
}

void ConnectionManager::openUdp()
{
    m_udp = new QUdpSocket(this);
    const QHostAddress bindAddr = m_config.localAddress.isEmpty()
                                      ? QHostAddress(QHostAddress::AnyIPv4)
                                      : QHostAddress(m_config.localAddress);
    if (!m_udp->bind(bindAddr, m_config.localPort)) {
        fail(tr("No se pudo abrir el puerto UDP %1: %2")
                 .arg(m_config.localPort)
                 .arg(m_udp->errorString()));
        return;
    }
    connect(m_udp, &QUdpSocket::readyRead, this, [this] {
        while (m_udp && m_udp->hasPendingDatagrams()) {
            const QNetworkDatagram dg = m_udp->receiveDatagram();
            if (m_state != State::Connected)
                setState(State::Connected,
                         tr("Recibiendo datagramas de %1").arg(dg.senderAddress().toString()));
            handleData(dg.data());
        }
    });
    setState(State::Listening, tr("Escuchando en el puerto UDP %1").arg(m_config.localPort));
}

void ConnectionManager::openReceiver()
{
    if (m_config.interface == ConnectionConfig::Interface::Serial) {
        fail(tr("El formato Receptor necesita Ethernet o WiFi"));
        return;
    }
    if (m_config.host.isEmpty()) {
        fail(tr("Falta la dirección de la Red Pitaya"));
        return;
    }
    m_receiver = new ReceiverLink(this);
    connect(m_receiver, &ReceiverLink::connected, this, [this] {
        m_connectTimeout.stop();
        setState(State::Connected, tr("Receptor en marcha en %1:%2").arg(m_config.host).arg(m_config.port));
    });
    connect(m_receiver, &ReceiverLink::failed, this, [this](const QString &message) { fail(message); });
    connect(m_receiver, &ReceiverLink::wordsReceived, this, [this](const QVector<quint32> &words) {
        // Para el monitor: los bits como bytes, en el orden en que llegan.
        QByteArray raw;
        raw.reserve(words.size() * 4);
        for (quint32 w : words)
            for (int shift = 24; shift >= 0; shift -= 8)
                raw.append(char((w >> shift) & 0xFF));
        m_rxBytes += quint64(raw.size());
        emit wordsReceived(words);
        emit dataReceived(raw);
    });
    connect(m_receiver, &ReceiverLink::statusUpdated, this, &ConnectionManager::receiverStatus);
    setState(State::Connecting, tr("Conectando con %1:%2…").arg(m_config.host).arg(m_config.port));
    m_connectTimeout.start(m_config.timeoutMs);
    m_receiver->open(m_config.host, m_config.port, m_config.timeoutMs);
}

void ConnectionManager::attachTcpSocket(QTcpSocket *socket, bool fromServer)
{
    m_tcp = socket;
    m_tcp->setParent(this);
    m_tcp->setSocketOption(QAbstractSocket::LowDelayOption, 1);

    connect(m_tcp, &QTcpSocket::connected, this, [this] {
        m_connectTimeout.stop();
        setState(State::Connected,
                 tr("Conectado a %1:%2").arg(m_tcp->peerName()).arg(m_tcp->peerPort()));
    });
    connect(m_tcp, &QTcpSocket::readyRead, this, [this] { handleData(m_tcp->readAll()); });
    connect(m_tcp, &QTcpSocket::errorOccurred, this, [this, fromServer](QAbstractSocket::SocketError e) {
        if (fromServer && e == QAbstractSocket::RemoteHostClosedError)
            return; // lo maneja disconnected()
        fail(m_tcp->errorString());
    });
    connect(m_tcp, &QTcpSocket::disconnected, this, [this, fromServer] {
        if (fromServer) {
            // Vuelve a esperar una nueva conexion de la Red Pitaya.
            m_tcp->deleteLater();
            m_tcp = nullptr;
            setState(State::Listening, tr("La Red Pitaya se desconectó; esperando nueva conexión"));
        } else if (m_state == State::Connected) {
            fail(tr("La Red Pitaya cerró la conexión"));
        }
    });
}

void ConnectionManager::handleData(const QByteArray &data)
{
    if (data.isEmpty())
        return;
    m_rxBytes += quint64(data.size());
    emit dataReceived(data);
}

void ConnectionManager::fail(const QString &message)
{
    m_connectTimeout.stop();
    releaseResources();
    if (m_wantOpen && m_config.autoReconnect) {
        setState(State::Error, tr("%1 — reintentando en %2 s")
                                   .arg(message)
                                   .arg(m_reconnectTimer.interval() / 1000));
        m_reconnectTimer.start();
    } else {
        m_wantOpen = false;
        setState(State::Error, message);
    }
}

void ConnectionManager::releaseResources()
{
    m_connectTimeout.stop();
    // Se desconectan las senales antes de cerrar para no recibir
    // errores/desconexiones provocados por el propio cierre.
    if (m_receiver) {
        m_receiver->disconnect(this);
        m_receiver->close();
        m_receiver->deleteLater();
        m_receiver = nullptr;
    }
    if (m_serial) {
        m_serial->disconnect(this);
        m_serial->close();
        m_serial->deleteLater();
        m_serial = nullptr;
    }
    if (m_tcp) {
        m_tcp->disconnect(this);
        m_tcp->abort();
        m_tcp->deleteLater();
        m_tcp = nullptr;
    }
    if (m_server) {
        m_server->disconnect(this);
        m_server->close();
        m_server->deleteLater();
        m_server = nullptr;
    }
    if (m_udp) {
        m_udp->disconnect(this);
        m_udp->close();
        m_udp->deleteLater();
        m_udp = nullptr;
    }
}

void ConnectionManager::setState(State state, const QString &message)
{
    m_state = state;
    emit stateChanged(state, message);
}
