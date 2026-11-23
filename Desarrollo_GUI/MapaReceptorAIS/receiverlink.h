#ifndef RECEIVERLINK_H
#define RECEIVERLINK_H

#include <QByteArray>
#include <QObject>
#include <QTimer>
#include <QVector>

class QTcpSocket;

/*
 * Enlace con el servidor de datos de la Red Pitaya (adc_server, puerto 1003): pone en marcha el receptor y lee la FIFO con la salida
 * demodulada.
 *
 * Protocolo (little-endian): un byte de comando y cuatro de payload; la respuesta es un byte de confirmacion (0x01 = ok), salvo
 * GET_STS (12 bytes) y READ_ADC (4 bytes por palabra). Al conectar hace lo mismo que el notebook de pruebas: configura el NCO de la FI
 * (10,7 MHz con un reloj de 125 MHz), pone en marcha el receptor, elige la salida demodulada y vacia la FIFO. Despues sondea cada 20 ms el
 * estado (palabras disponibles, nivel y squelch) y lee solo las palabras disponibles: pedir de mas haria que el servidor rellene con ceros.
 * Es asincrono: no bloquea la interfaz.
 */
class ReceiverLink : public QObject
{
    Q_OBJECT

public:
    explicit ReceiverLink(QObject *parent = nullptr);
    ~ReceiverLink() override;

    void open(const QString &host, quint16 port, int timeoutMs);
    void close();
    bool isReady() const { return m_ready; }

signals:
    void connected();                                   // el receptor quedo en marcha
    void failed(const QString &message);                // no se pudo conectar o se perdio el enlace
    void wordsReceived(const QVector<quint32> &words);  // palabras de la FIFO; los bits van del MSB al LSB
    void statusUpdated(quint32 level, bool squelchOpen, quint32 fifoWords);

private:
    enum class Step { Closed, Startup, Idle, WaitStatus, WaitData };
    struct StartupCommand
    {
        quint8 cmd;
        quint32 payload;
        QString what;
    };

    void send(quint8 cmd, quint32 payload);
    void sendStartup();
    void requestStatus();
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
};

#endif // RECEIVERLINK_H
