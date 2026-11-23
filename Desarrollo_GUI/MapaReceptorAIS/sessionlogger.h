#ifndef SESSIONLOGGER_H
#define SESSIONLOGGER_H

#include "aistypes.h"

#include <QFile>
#include <QObject>
#include <QString>

// Una fila del registro de estado del receptor (una por segundo y por canal).
struct StatusRow
{
    QChar canal = QLatin1Char('A');   // 'A' o 'B'
    quint32 level = 0;          // pico del nivel en el ultimo segundo
    bool squelchOpen = false;
    quint32 fifoWords = 0;
    double burstsPerSecond = 0.0;
    bool agcLinked = false;
    bool agcActive = false;
    double gainDb = Ais::nan();
    quint32 lastPeak = 0;
    quint32 agcBursts = 0;
    quint32 agcChanges = 0;
    quint32 agcProtections = 0;
    quint32 agcErrors = 0;
    quint64 messages = 0;
    quint64 frames = 0;
    quint64 badFcs = 0;
    quint64 discarded = 0;
    quint64 aborted = 0;
};

/*
 * Registro de la sesion en dos archivos CSV (UTF-8, separados por comas, decimales con punto, horas en UTC):
 *   mensajes_<fecha>.csv  una fila por mensaje AIS decodificado, con el canal por el que llego y el estado del buque despues de ese mensaje
 *   receptor_<fecha>.csv  una fila por segundo y por canal con el nivel y el squelch del receptor, el AGC y los contadores del armado de tramas
 * Sirve para medir perdidas y el comportamiento del AGC en las pruebas largas.
 */
class SessionLogger : public QObject
{
    Q_OBJECT

public:
    explicit SessionLogger(QObject *parent = nullptr);
    ~SessionLogger() override;

    bool start(const QString &folder, QString *error = nullptr);
    void stop();
    bool isActive() const { return m_messages.isOpen(); }
    QString messagesPath() const { return m_messages.fileName(); }
    QString statusPath() const { return m_status.fileName(); }

    static QString csvField(const QString &text);

public slots:
    void logMessage(const Vessel &vessel, QChar channel);
    void logStatus(const StatusRow &row);

private:
    QFile m_messages;
    QFile m_status;
};

#endif // SESSIONLOGGER_H
