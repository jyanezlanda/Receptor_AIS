#ifndef RECEIVERLINK_H
#define RECEIVERLINK_H

#include <QByteArray>
#include <QObject>
#include <QTimer>
#include <QVector>

class QTcpSocket;

/*
 * Enlace con el servidor de datos de la Red Pitaya (adc_server_2ch, puerto 1003): pone en marcha el receptor y lee las FIFO con la salida
 * demodulada de los canales AIS: A (161,975 MHz, canal 0) y B (162,025 MHz, canal 1).
 *
 * Protocolo (little-endian): un byte de comando y cuatro de payload; la respuesta es un byte de confirmacion (0x01 = ok), salvo
 * GET_STS (12 bytes), READ_ADC (4 bytes por palabra) y GET_CANALES (0x01 y la cantidad de canales). El canal A usa GET_STS 0x23 y
 * READ_ADC 0x03; el canal B, 0x26 y 0x25. Al conectar hace lo mismo que el notebook de pruebas: configura el NCO de la FI (10,7 MHz
 * con un reloj de 125 MHz), pone en marcha el receptor, elige la salida demodulada, vacia las FIFO y pregunta cuantos canales tiene el
 * servidor; un adc_server de un solo canal contesta 0x00 y se lee solo el A. Despues sondea cada 20 ms el estado de cada canal (palabras
 * disponibles, nivel y squelch) y lee solo las palabras disponibles: pedir de mas haria que el servidor rellene con ceros.
 * Es asincrono: no bloquea la interfaz.
 */
class ReceiverLink : public QObject
{
    Q_OBJECT

public:
    static constexpr int kMaxChannels = 2;

    explicit ReceiverLink(QObject *parent = nullptr);
    ~ReceiverLink() override;

    void open(const QString &host, quint16 port, int timeoutMs);
    void close();
    bool isReady() const { return m_ready; }
    int channelCount() const { return m_channelCount; }

signals:
    void channelsDetected(int count);                                           // 1 o 2; llega antes de connected()
    void connected();                                                           // el receptor quedo en marcha
    void failed(const QString &message);                                        // no se pudo conectar o se perdio el enlace
    void wordsReceived(int channel, const QVector<quint32> &words);            // palabras de la FIFO; los bits van del MSB al LSB
    void statusUpdated(int channel, quint32 level, bool squelchOpen, quint32 fifoWords);

private:
    enum class Step { Closed, Startup, WaitChannels, Idle, WaitStatus, WaitData };
    struct StartupCommand
    {
        quint8 cmd;
        quint32 payload;
        QString what;
    };

    void send(quint8 cmd, quint32 payload);
    void sendStartup();
    void requestStatus();
    void finishChannel();
    void process();
    void fail(const QString &message);

    QTcpSocket *m_socket = nullptr;
    QTimer m_poll;
    QTimer m_watchdog;
    Step m_step = Step::Closed;
    bool m_ready = false;
    int m_timeoutMs = 5000;
    QByteArray m_buffer;
    QVector<StartupCommand> m_startup;
    int m_startIndex = 0;
    quint32 m_wantWords = 0;
    int m_channelCount = 1;
    int m_channel = 0;       // canal que se esta leyendo
    bool m_backlog = false;  // algun canal de esta vuelta lleno la lectura: la proxima vuelta sigue enseguida
};

#endif // RECEIVERLINK_H
