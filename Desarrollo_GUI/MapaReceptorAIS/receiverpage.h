#ifndef RECEIVERPAGE_H
#define RECEIVERPAGE_H

#include "adrflink.h"
#include "aisdecoder.h"
#include "sessionlogger.h"

#include <QElapsedTimer>
#include <QTimer>
#include <QWidget>

class QCheckBox;
class QLabel;
class QLineEdit;
class QProgressBar;
class QPushButton;
class QSpinBox;
class TracePlot;

/*
 * Pestana "Receptor": estado del receptor (nivel, squelch, FIFO, contadores del armado de tramas), estado del AGC del servidor del
 * ADRF, un grafico de la ganancia y del pico de cada rafaga de los ultimos dos minutos y el control del registro CSV. Solo muestra:
 * la ganancia la maneja el AGC del servidor.
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
    void setReceiverStatus(quint32 level, bool squelchOpen, quint32 fifoWords);
    void setAgcLink(bool linked, const QString &message);
    void setAgcStatus(const AgcStatus &status);
    void setDecoderStats(const AisDecoder::Stats &stats);
    void setLoggerResult(bool active, const QString &text);                    // respuesta a loggingRequested

signals:
    void controlPortChanged(quint16 port);
    void loggingRequested(bool on, const QString &folder);
    void statusRow(const StatusRow &row);                                      // una por segundo, con el receptor conectado

private:
    void onSecond();
    void resetDisplay();
    static QString count(quint64 value);

    TracePlot *m_plot = nullptr;
    QProgressBar *m_level = nullptr;
    QLabel *m_levelPeak = nullptr;
    QLabel *m_squelch = nullptr;
    QLabel *m_fifo = nullptr;
    QLabel *m_burstRate = nullptr;
    QLabel *m_messages = nullptr;
    QLabel *m_frames = nullptr;
    QLabel *m_badFcs = nullptr;
    QLabel *m_discarded = nullptr;
    QLabel *m_aborted = nullptr;
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
    QElapsedTimer m_displayTimer;
    QElapsedTimer m_rateTimer;

    bool m_active = false;
    bool m_squelchWas = false;
    int m_edges = 0;
    quint32 m_peakSecond = 0;
    quint32 m_levelNow = 0;
    bool m_squelchOpen = false;
    quint32 m_fifoWords = 0;
    double m_burstsPerSecond = 0.0;
    bool m_agcLinked = false;
    AgcStatus m_agc;
    AisDecoder::Stats m_stats;
    quint16 m_lastPort = 1005;
};

#endif // RECEIVERPAGE_H
