#ifndef RECEIVERPAGE_H
#define RECEIVERPAGE_H

#include "adrflink.h"
#include "aisdecoder.h"
#include "sessionlogger.h"

#include <QElapsedTimer>
#include <QTimer>
#include <QWidget>

class QCheckBox;
class QGroupBox;
class QLabel;
class QLineEdit;
class QProgressBar;
class QPushButton;
class QSpinBox;
class TracePlot;

/*
 * Pestana "Receptor": estado de cada canal del receptor (nivel, squelch, FIFO, contadores del armado de tramas), estado del AGC del
 * servidor del ADRF, un grafico de la ganancia y del pico de cada rafaga de los ultimos dos minutos y el control del registro CSV.
 * Solo muestra: la ganancia la maneja el AGC del servidor.
 */
class ReceiverPage : public QWidget
{
    Q_OBJECT

public:
    explicit ReceiverPage(QWidget *parent = nullptr);

    quint16 controlPort() const;   // puerto del servidor del ADRF
    void saveSettings() const;

public slots:
    void setReceiverActive(bool active);                                       // receptor conectado o no
    void setChannelCount(int count);                                           // canales del servidor de datos: 1 o 2
    void setReceiverStatus(int channel, quint32 level, bool squelchOpen, quint32 fifoWords);   // canal 0 = A, 1 = B
    void setAgcLink(bool linked, const QString &message);
    void setAgcStatus(const AgcStatus &status);
    void setDecoderStats(int channel, const AisDecoder::Stats &stats);
    void setLoggerResult(bool active, const QString &text);                    // respuesta a loggingRequested

signals:
    void controlPortChanged(quint16 port);
    void loggingRequested(bool on, const QString &folder);
    void statusRow(const StatusRow &row);                                      // una por segundo y por canal, con el receptor conectado

private:
    // Lo que se muestra y se acumula de cada canal
    struct Channel
    {
        QGroupBox *box = nullptr;
        QProgressBar *level = nullptr;
        QLabel *levelPeak = nullptr;
        QLabel *squelch = nullptr;
        QLabel *fifo = nullptr;
        QLabel *burstRate = nullptr;
        QLabel *messages = nullptr;
        QLabel *frames = nullptr;
        QLabel *badFcs = nullptr;
        QLabel *discarded = nullptr;
        QLabel *aborted = nullptr;
        QElapsedTimer displayTimer;
        bool squelchWas = false;
        int edges = 0;
        quint32 peakSecond = 0;
        quint32 levelNow = 0;
        bool squelchOpen = false;
        quint32 fifoWords = 0;
        double burstsPerSecond = 0.0;
        AisDecoder::Stats stats;
    };

    void onSecond();
    void resetDisplay();
    QGroupBox *makeChannelBox(Channel &channel, const QString &title);
    static QString count(quint64 value);

    TracePlot *m_plot = nullptr;
    Channel m_ch[2];
    int m_channelCount = 1;
    QLabel *m_agcState = nullptr;
    QLabel *m_gain = nullptr;
    QLabel *m_target = nullptr;
    QLabel *m_lastPeak = nullptr;
    QLabel *m_agcBursts = nullptr;
    QLabel *m_agcChanges = nullptr;
    QLabel *m_agcProtections = nullptr;
    QLabel *m_agcErrors = nullptr;
    QSpinBox *m_port = nullptr;
    QCheckBox *m_csvCheck = nullptr;
    QLineEdit *m_csvFolder = nullptr;
    QPushButton *m_csvBrowse = nullptr;
    QLabel *m_csvInfo = nullptr;
    QTimer m_second;
    QElapsedTimer m_rateTimer;

    bool m_active = false;
    bool m_agcLinked = false;
    AgcStatus m_agc;
    quint16 m_lastPort = 1005;
};

#endif // RECEIVERPAGE_H
