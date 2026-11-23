#ifndef AISDECODER_H
#define AISDECODER_H

#include "ais_frame/ais_frame.h"
#include "aistypes.h"

#include <QHash>
#include <QMap>
#include <QObject>
#include <QVector>

/*
 * Decodificador de sentencias NMEA 0183 de AIS (!AIVDM / !AIVDO).
 *
 * Recibe bytes sueltos (pueden cortar lineas por la mitad), valida el
 * checksum, arma los mensajes de varias sentencias (p. ej. el tipo 5) y
 * decodifica los mensajes de buques segun ITU-R M.1371:
 *   1, 2, 3  posicion clase A        5   datos estaticos y de viaje clase A
 *   18       posicion clase B        19  posicion + datos clase B extendido
 *   24       datos estaticos clase B (partes A y B)
 * El resto de los tipos se cuentan pero no generan buques.
 *
 * Tambien arma las tramas desde los bits demodulados de la FIFO del receptor (feedWords): bandera HDLC, destuffing, FCS y
 * verificacion del tipo y el largo del mensaje (ais_frame), y decodifica cada trama como si fuera una sentencia.
 */
class AisDecoder : public QObject
{
    Q_OBJECT

public:
    struct Stats
    {
        quint64 sentences = 0;   // sentencias AIVDM/AIVDO validas
        quint64 badChecksum = 0; // descartadas por checksum
        quint64 malformed = 0;   // lineas con formato invalido o fragmentos sueltos
        quint64 messages = 0;    // mensajes AIS completos
        quint64 unsupported = 0; // mensajes de tipos que no generan buques
        QMap<int, quint64> byType;
        // Armado de tramas desde la FIFO del receptor (ais_frame)
        quint64 rxBits = 0;       // bits recibidos
        quint64 rxCandidates = 0; // tramas entre dos banderas
        quint64 rxBadFcs = 0;     // con FCS incorrecto
        quint64 rxDiscarded = 0;  // FCS correcto, pero tipo o largo no plausible
        quint64 rxAborted = 0;    // siete unos seguidos o demasiado largas
        quint64 rxFrames = 0;     // tramas aceptadas
    };

    explicit AisDecoder(QObject *parent = nullptr);

    // Bytes recibidos tal cual llegan del enlace.
    void feed(const QByteArray &data);
    // Una sentencia completa (sin fin de linea). Devuelve false si se descarto.
    bool decodeSentence(const QByteArray &sentence);
    // Palabras de 32 bits de la FIFO del receptor (los bits van del MSB al LSB).
    void feedWords(const QVector<quint32> &words);

    // Decodifica un payload ya desarmado. Devuelve true si produjo datos de un buque.
    static bool decodePayload(const QByteArray &payload, int fillBits, Vessel &out, int *msgType = nullptr);

    const Stats &stats() const { return m_stats; }
    void reset();

signals:
    void vesselDecoded(const Vessel &vessel);
    void statsChanged();

private:
    struct Fragment
    {
        int total = 0;
        int received = 0;
        QByteArray payload;
        qint64 startedMs = 0;
    };

    void handleMessage(const QByteArray &payload, int fillBits);
    static void onFrame(const ais_frame_t *frame, void *user);

    QByteArray m_lineBuffer;
    QHash<QByteArray, Fragment> m_fragments; // clave: emisor + canal + id de secuencia
    Stats m_stats;
    ais_rx_t m_rx;
};

#endif // AISDECODER_H
