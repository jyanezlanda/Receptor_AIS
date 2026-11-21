#ifndef AISDECODER_H
#define AISDECODER_H

#include "aistypes.h"

#include <QHash>
#include <QMap>
#include <QObject>

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
    };

    explicit AisDecoder(QObject *parent = nullptr);

    // Bytes recibidos tal cual llegan del enlace.
    void feed(const QByteArray &data);
    // Una sentencia completa (sin fin de linea). Devuelve false si se descarto.
    bool decodeSentence(const QByteArray &sentence);

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

    QByteArray m_lineBuffer;
    QHash<QByteArray, Fragment> m_fragments; // clave: emisor + canal + id de secuencia
    Stats m_stats;
};

#endif // AISDECODER_H
