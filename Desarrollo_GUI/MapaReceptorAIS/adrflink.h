#ifndef ADRFLINK_H
#define ADRFLINK_H

#include <QByteArray>
#include <QMetaType>
#include <QObject>
#include <QString>
#include <QTimer>

class QTcpSocket;

// Estado del AGC del servidor del ADRF (respuesta de AGC_GET).
struct AgcStatus
{
    bool available = false;   // el servidor tiene el DAC (-d) y los registros por rafaga: el AGC existe
    bool active = false;
    double gainDb = 0.0;      // ganancia actual del ADRF
    quint32 bursts = 0;       // rafagas procesadas desde que se activo
    quint32 changes = 0;      // cambios de ganancia
    quint32 protections = 0;  // veces que actuo la proteccion de nivel
    quint32 lastPeak = 0;     // pico de la ultima rafaga
    quint32 serverMs = 0;     // reloj del servidor
    quint32 seq = 0;          // rafagas registradas por la FPGA
    quint32 errors = 0;       // cambios de ganancia que fallaron
    double target = 0.0;      // nivel pico objetivo
    int window = 0;           // rafagas de la ventana
    double percentile = 0.0;
    double deadZoneDb = 0.0;
    double minGainDb = 0.0;
    double maxGainDb = 0.0;
};
Q_DECLARE_METATYPE(AgcStatus)

/*
 * Enlace con el servidor del ADRF de la Red Pitaya (adrf_server, puerto 1005): consulta el estado del AGC dos veces por segundo
 * (comando AGC_GET). Solo lee: no cambia la ganancia ni los parametros. Si se pierde el enlace o el servidor no contesta, lo dice y
 * reintenta cada dos segundos mientras siga abierto. El servidor atiende un cliente a la vez: con otro conectado (por ejemplo un
 * notebook) no contesta y el enlace queda reintentando.
 *
 * Protocolo (little-endian): un byte de comando y cuatro de payload; AGC_GET (0x1C) contesta un byte (0x01 = el AGC esta disponible)
 * y 88 bytes: nueve palabras de estado y trece de parametros (en las unidades del cable). Es asincrono.
 */
class AdrfLink : public QObject
{
    Q_OBJECT

public:
    explicit AdrfLink(QObject *parent = nullptr);
    ~AdrfLink() override;

    void open(const QString &host, quint16 port);
    void close();
    bool isOpen() const { return m_wanted; }
    bool isLinked() const { return m_linked; }

    // Decodifica una respuesta completa de AGC_GET (89 bytes). Falso si es corta.
    static bool parse(const QByteArray &frame, AgcStatus *out);

signals:
    void statusUpdated(const AgcStatus &status);
    void linkChanged(bool linked, const QString &message);

private:
    void connectNow();
    void requestStatus();
    void onReadyRead();
    void onTimeout();
    void drop(const QString &message);
    void setLink(bool linked, const QString &message);

    QTcpSocket *m_socket = nullptr;
    QTimer m_poll;
    QTimer m_watchdog;
    QTimer m_retry;
    QString m_host;
    quint16 m_port = 1005;
    bool m_wanted = false;
    bool m_linked = false;
    bool m_connecting = false;
    QString m_lastMessage;
    QByteArray m_buffer;
};

#endif // ADRFLINK_H
