#ifndef CONNECTIONMANAGER_H
#define CONNECTIONMANAGER_H

#include <QObject>
#include <QSerialPort>
#include <QTimer>

class QTcpServer;
class QTcpSocket;
class QUdpSocket;

/*
 * Parametros de la conexion con la Red Pitaya.
 */
struct ConnectionConfig
{
    enum class Interface { Serial, Ethernet, Wifi };
    enum class Protocol { Tcp, Udp };
    enum class Role { Client, Server };
    enum class DataFormat { DemodBits, Nmea, Raw };

    Interface interface = Interface::Ethernet;
    DataFormat dataFormat = DataFormat::DemodBits;

    // Serie
    QString serialPort;
    qint32 baudRate = 115200;
    QSerialPort::DataBits dataBits = QSerialPort::Data8;
    QSerialPort::Parity parity = QSerialPort::NoParity;
    QSerialPort::StopBits stopBits = QSerialPort::OneStop;
    QSerialPort::FlowControl flowControl = QSerialPort::NoFlowControl;

    // Red (Ethernet / WiFi)
    QString host = QStringLiteral("192.168.1.100");
    quint16 port = 1004;
    Protocol protocol = Protocol::Tcp;
    Role role = Role::Client;
    quint16 localPort = 1004;
    QString localAddress; // IP del adaptador local a usar (vacio = automatico)
    int timeoutMs = 5000;

    bool autoReconnect = false;

    QString summary() const;
};

/*
 * Abre y mantiene el enlace con la Red Pitaya (serie, TCP o UDP)
 * y entrega los bytes recibidos sin interpretar.
 */
class ConnectionManager : public QObject
{
    Q_OBJECT

public:
    enum class State { Disconnected, Connecting, Listening, Connected, Error };
    Q_ENUM(State)

    explicit ConnectionManager(QObject *parent = nullptr);
    ~ConnectionManager() override;

    State state() const { return m_state; }
    const ConnectionConfig &config() const { return m_config; }
    quint64 bytesReceived() const { return m_rxBytes; }

    static QString stateText(State state);
    static QString stateColor(State state); // color del indicador (#rrggbb)

public slots:
    void open(const ConnectionConfig &config);
    void close();
    qint64 send(const QByteArray &data);

signals:
    void stateChanged(ConnectionManager::State state, const QString &message);
    void dataReceived(const QByteArray &data);

private:
    void openSerial();
    void openTcpClient();
    void openTcpServer();
    void openUdp();
    void attachTcpSocket(QTcpSocket *socket, bool fromServer);
    void handleData(const QByteArray &data);
    void fail(const QString &message);
    void releaseResources();
    void setState(State state, const QString &message);

    ConnectionConfig m_config;
    State m_state = State::Disconnected;
    bool m_wantOpen = false;
    quint64 m_rxBytes = 0;

    QSerialPort *m_serial = nullptr;
    QTcpSocket *m_tcp = nullptr;
    QTcpServer *m_server = nullptr;
    QUdpSocket *m_udp = nullptr;

    QTimer m_connectTimeout;
    QTimer m_reconnectTimer;
};

#endif // CONNECTIONMANAGER_H
