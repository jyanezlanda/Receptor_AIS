#include "aisdecoder.h"

#include <QDateTime>
#include <QList>

namespace {

constexpr int kMaxLineLength = 200;    // una sentencia NMEA tiene como maximo 82 caracteres
constexpr qint64 kFragmentTimeoutMs = 10000;

// Bits de un mensaje AIS desarmado (cada caracter del payload aporta 6 bits).
class BitReader
{
public:
    BitReader(const QByteArray &payload, int fillBits)
    {
        m_bits.reserve(payload.size() * 6);
        for (char ch : payload) {
            int v = static_cast<unsigned char>(ch) - 48;
            if (v > 40)
                v -= 8;
            if (v < 0 || v > 63) {
                m_valid = false;
                return;
            }
            for (int i = 5; i >= 0; --i)
                m_bits.append(char((v >> i) & 1));
        }
        m_bits.chop(qBound(0, fillBits, 5));
    }

    bool valid() const { return m_valid; }
    int size() const { return int(m_bits.size()); }

    quint32 u(int start, int len) const
    {
        quint32 v = 0;
        for (int i = start; i < start + len; ++i)
            v = (v << 1) | (i < m_bits.size() ? quint32(m_bits.at(i)) : 0u);
        return v;
    }

    qint32 s(int start, int len) const
    {
        const quint32 v = u(start, len);
        return (v & (1u << (len - 1))) ? qint32(v) - qint32(1u << len) : qint32(v);
    }

    QString text(int start, int chars) const
    {
        static const char table[] =
            "@ABCDEFGHIJKLMNOPQRSTUVWXYZ[\\]^_ !\"#$%&'()*+,-./0123456789:;<=>?";
        QString out;
        for (int i = 0; i < chars && start + i * 6 + 6 <= m_bits.size(); ++i)
            out += QLatin1Char(table[u(start + i * 6, 6)]);
        // '@' es el relleno de los campos de texto
        const int end = out.indexOf(QLatin1Char('@'));
        if (end >= 0)
            out.truncate(end);
        return out.trimmed();
    }

private:
    QByteArray m_bits;
    bool m_valid = true;
};

// Posicion: 1/10000 de minuto. 181 grados (lon) y 91 grados (lat) = no disponible.
void setPosition(Vessel &v, qint32 lonRaw, qint32 latRaw)
{
    const double lon = lonRaw / 600000.0;
    const double lat = latRaw / 600000.0;
    if (lon >= -180.0 && lon <= 180.0 && lat >= -90.0 && lat <= 90.0) {
        v.lon = lon;
        v.lat = lat;
    }
}

void setSogCogHdg(Vessel &v, quint32 sog, quint32 cog, quint32 hdg)
{
    if (sog != 1023)
        v.sog = sog / 10.0;
    if (cog < 3600)
        v.cog = cog / 10.0;
    if (hdg < 360)
        v.heading = int(hdg);
}

void setDimensions(Vessel &v, const BitReader &b, int start)
{
    const int bow = int(b.u(start, 9));
    const int stern = int(b.u(start + 9, 9));
    const int port = int(b.u(start + 18, 6));
    const int starboard = int(b.u(start + 24, 6));
    if (bow + stern > 0)
        v.length = bow + stern;
    if (port + starboard > 0)
        v.beam = port + starboard;
}

} // namespace

AisDecoder::AisDecoder(QObject *parent)
    : QObject(parent)
{
}

void AisDecoder::reset()
{
    m_lineBuffer.clear();
    m_fragments.clear();
    m_stats = Stats();
    emit statsChanged();
}

void AisDecoder::feed(const QByteArray &data)
{
    m_lineBuffer += data;
    int start = 0;
    for (;;) {
        const int nl = int(m_lineBuffer.indexOf('\n', start));
        if (nl < 0)
            break;
        QByteArray line = m_lineBuffer.mid(start, nl - start).trimmed();
        start = nl + 1;
        if (!line.isEmpty())
            decodeSentence(line);
    }
    m_lineBuffer.remove(0, start);
    // Proteccion ante datos que no son NMEA (sin fines de linea)
    if (m_lineBuffer.size() > kMaxLineLength * 4)
        m_lineBuffer = m_lineBuffer.right(kMaxLineLength);
}

bool AisDecoder::decodeSentence(const QByteArray &sentenceIn)
{
    QByteArray sentence = sentenceIn.trimmed();

    // Bloque de etiquetas opcional: \s:fuente,c:hora*CS\!AIVDM,...
    if (sentence.startsWith('\\')) {
        const int end = int(sentence.indexOf('\\', 1));
        if (end < 0)
            return false;
        sentence = sentence.mid(end + 1);
    }
    const int bang = int(sentence.indexOf('!'));
    if (bang < 0)
        return false; // no es una sentencia AIS (p. ej. $GPRMC): se ignora sin contarla
    sentence = sentence.mid(bang);

    // Checksum: XOR de todo lo que hay entre '!' y '*'
    const int star = int(sentence.lastIndexOf('*'));
    if (star < 0 || star + 3 > sentence.size()) {
        ++m_stats.malformed;
        emit statsChanged();
        return false;
    }
    bool ok = false;
    const int expected = sentence.mid(star + 1, 2).toInt(&ok, 16);
    quint8 cs = 0;
    for (int i = 1; i < star; ++i)
        cs ^= quint8(sentence.at(i));
    if (!ok || cs != expected) {
        ++m_stats.badChecksum;
        emit statsChanged();
        return false;
    }

    const QList<QByteArray> f = sentence.left(star).split(',');
    // f[0]=!xxVDM  f[1]=total  f[2]=numero  f[3]=id secuencia  f[4]=canal  f[5]=payload  f[6]=relleno
    if (f.size() < 7 || f.at(0).size() != 6
        || !(f.at(0).endsWith("VDM") || f.at(0).endsWith("VDO"))) {
        ++m_stats.malformed;
        emit statsChanged();
        return false;
    }
    const int total = f.at(1).toInt();
    const int number = f.at(2).toInt();
    const int fill = f.at(6).toInt();
    if (total < 1 || total > 9 || number < 1 || number > total || f.at(5).isEmpty()) {
        ++m_stats.malformed;
        emit statsChanged();
        return false;
    }
    ++m_stats.sentences;

    if (total == 1) {
        handleMessage(f.at(5), fill);
        emit statsChanged();
        return true;
    }

    // Mensaje de varias sentencias
    const qint64 now = QDateTime::currentMSecsSinceEpoch();
    for (auto it = m_fragments.begin(); it != m_fragments.end();) {
        if (now - it->startedMs > kFragmentTimeoutMs) {
            ++m_stats.malformed;
            it = m_fragments.erase(it);
        } else {
            ++it;
        }
    }
    const QByteArray key = f.at(0) + ',' + f.at(4) + ',' + f.at(3);
    Fragment &frag = m_fragments[key];
    if (number == 1) {
        if (frag.received > 0)
            ++m_stats.malformed; // quedo uno incompleto con el mismo id
        frag = Fragment{total, 1, f.at(5), now};
    } else if (frag.received == number - 1 && frag.total == total) {
        frag.payload += f.at(5);
        ++frag.received;
    } else {
        // Fragmento fuera de orden o sin el comienzo
        ++m_stats.malformed;
        m_fragments.remove(key);
        emit statsChanged();
        return false;
    }
    if (frag.received == frag.total) {
        const QByteArray payload = frag.payload;
        m_fragments.remove(key);
        handleMessage(payload, fill);
    }
    emit statsChanged();
    return true;
}

void AisDecoder::handleMessage(const QByteArray &payload, int fillBits)
{
    Vessel v;
    int type = 0;
    ++m_stats.messages;
    const bool vessel = decodePayload(payload, fillBits, v, &type);
    ++m_stats.byType[type];
    if (vessel)
        emit vesselDecoded(v);
    else
        ++m_stats.unsupported;
}

bool AisDecoder::decodePayload(const QByteArray &payload, int fillBits, Vessel &v, int *msgType)
{
    const BitReader b(payload, fillBits);
    if (!b.valid() || b.size() < 38) {
        if (msgType)
            *msgType = 0;
        return false;
    }
    const int type = int(b.u(0, 6));
    if (msgType)
        *msgType = type;

    v = Vessel();
    v.mmsi = b.u(8, 30);
    v.lastMsgType = type;
    v.lastSeen = QDateTime::currentDateTime();

    switch (type) {
    case 1:
    case 2:
    case 3: // Posicion clase A
        if (b.size() < 137)
            return false;
        v.navStatus = int(b.u(38, 4));
        setPosition(v, b.s(61, 28), b.s(89, 27));
        setSogCogHdg(v, b.u(50, 10), b.u(116, 12), b.u(128, 9));
        return true;

    case 5: // Datos estaticos y de viaje clase A
        if (b.size() < 420)
            return false;
        v.imo = b.u(40, 30);
        v.callsign = b.text(70, 7);
        v.name = b.text(112, 20);
        v.shipType = int(b.u(232, 8));
        setDimensions(v, b, 240);
        if (b.u(294, 8) > 0)
            v.draught = b.u(294, 8) / 10.0;
        v.destination = b.text(302, 20);
        return true;

    case 18: // Posicion clase B
        if (b.size() < 133)
            return false;
        setPosition(v, b.s(57, 28), b.s(85, 27));
        setSogCogHdg(v, b.u(46, 10), b.u(112, 12), b.u(124, 9));
        return true;

    case 19: // Posicion clase B extendida
        if (b.size() < 301)
            return false;
        setPosition(v, b.s(57, 28), b.s(85, 27));
        setSogCogHdg(v, b.u(46, 10), b.u(112, 12), b.u(124, 9));
        v.name = b.text(143, 20);
        v.shipType = int(b.u(263, 8));
        setDimensions(v, b, 271);
        return true;

    case 24: { // Datos estaticos clase B
        const quint32 part = b.u(38, 2);
        if (part == 0 && b.size() >= 160) {
            v.name = b.text(40, 20);
            return true;
        }
        if (part == 1 && b.size() >= 162) {
            v.shipType = int(b.u(40, 8));
            v.callsign = b.text(90, 7);
            setDimensions(v, b, 132);
            return true;
        }
        return false;
    }

    default:
        return false;
    }
}
