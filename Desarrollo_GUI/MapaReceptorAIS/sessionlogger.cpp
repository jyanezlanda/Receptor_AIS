#include "sessionlogger.h"

#include <QDateTime>
#include <QDir>

#include <cmath>

namespace {
QString now()
{
    return QDateTime::currentDateTimeUtc().toString(Qt::ISODateWithMs);
}

QString num(double v, int decimals)
{
    return std::isfinite(v) ? QString::number(v, 'f', decimals) : QString();
}
} // namespace

SessionLogger::SessionLogger(QObject *parent)
    : QObject(parent)
{
}

SessionLogger::~SessionLogger()
{
    stop();
}

QString SessionLogger::csvField(const QString &text)
{
    if (!text.contains(QLatin1Char(',')) && !text.contains(QLatin1Char('"')) && !text.contains(QLatin1Char('\n'))
        && !text.contains(QLatin1Char('\r')))
        return text;
    QString quoted = text;
    quoted.replace(QLatin1Char('"'), QStringLiteral("\"\""));
    return QLatin1Char('"') + quoted + QLatin1Char('"');
}

bool SessionLogger::start(const QString &folder, QString *error)
{
    stop();
    auto fail = [&](const QString &text) {
        if (error)
            *error = text;
        stop();
        return false;
    };
    QDir dir(folder);
    if (!dir.mkpath(QStringLiteral(".")))
        return fail(tr("No se pudo crear la carpeta %1").arg(QDir::toNativeSeparators(folder)));
    const QString stamp = QDateTime::currentDateTimeUtc().toString(QStringLiteral("yyyyMMdd_HHmmss"));
    m_messages.setFileName(dir.filePath(QStringLiteral("mensajes_%1.csv").arg(stamp)));
    m_status.setFileName(dir.filePath(QStringLiteral("receptor_%1.csv").arg(stamp)));
    if (!m_messages.open(QIODevice::WriteOnly | QIODevice::Truncate))
        return fail(tr("No se pudo abrir %1: %2").arg(QDir::toNativeSeparators(m_messages.fileName()), m_messages.errorString()));
    if (!m_status.open(QIODevice::WriteOnly | QIODevice::Truncate))
        return fail(tr("No se pudo abrir %1: %2").arg(QDir::toNativeSeparators(m_status.fileName()), m_status.errorString()));
    m_messages.write("hora_utc,canal,mmsi,tipo_msg,nombre,indicativo,tipo_buque,destino,lat,lon,sog_kn,cog_grados,rumbo_grados,estado_nav,eslora_m,"
                     "manga_m,calado_m,mensajes_del_buque\n");
    m_status.write("hora_utc,canal,nivel_pico_1s,squelch,palabras_fifo,rafagas_por_s,agc_enlace,agc_activo,ganancia_db,ultimo_pico,agc_rafagas,agc_cambios,"
                   "agc_protecciones,agc_errores,mensajes_ais,tramas_ok,fcs_malo,descartadas,abortadas\n");
    m_messages.flush();
    m_status.flush();
    return true;
}

void SessionLogger::stop()
{
    if (m_messages.isOpen())
        m_messages.close();
    if (m_status.isOpen())
        m_status.close();
}

void SessionLogger::logMessage(const Vessel &v, QChar channel)
{
    if (!m_messages.isOpen())
        return;
    const QStringList f = {now(),
                           QString(channel),
                           QString::number(v.mmsi),
                           QString::number(v.lastMsgType),
                           csvField(v.name),
                           csvField(v.callsign),
                           QString::number(v.shipType),
                           csvField(v.destination),
                           num(v.lat, 6),
                           num(v.lon, 6),
                           num(v.sog, 1),
                           num(v.cog, 1),
                           v.heading == Ais::HeadingNotAvailable ? QString() : QString::number(v.heading),
                           v.navStatus == Ais::NavStatusNotDefined ? QString() : QString::number(v.navStatus),
                           QString::number(v.length),
                           QString::number(v.beam),
                           num(v.draught, 1),
                           QString::number(v.msgCount)};
    m_messages.write((f.join(QLatin1Char(',')) + QLatin1Char('\n')).toUtf8());
    m_messages.flush();
}

void SessionLogger::logStatus(const StatusRow &r)
{
    if (!m_status.isOpen())
        return;
    const QStringList f = {now(),
                           QString(r.canal),
                           QString::number(r.level),
                           QString::number(r.squelchOpen ? 1 : 0),
                           QString::number(r.fifoWords),
                           num(r.burstsPerSecond, 1),
                           QString::number(r.agcLinked ? 1 : 0),
                           QString::number(r.agcActive ? 1 : 0),
                           num(r.gainDb, 3),
                           QString::number(r.lastPeak),
                           QString::number(r.agcBursts),
                           QString::number(r.agcChanges),
                           QString::number(r.agcProtections),
                           QString::number(r.agcErrors),
                           QString::number(r.messages),
                           QString::number(r.frames),
                           QString::number(r.badFcs),
                           QString::number(r.discarded),
                           QString::number(r.aborted)};
    m_status.write((f.join(QLatin1Char(',')) + QLatin1Char('\n')).toUtf8());
    m_status.flush();
}
