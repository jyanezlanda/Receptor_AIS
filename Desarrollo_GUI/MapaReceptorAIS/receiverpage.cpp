#include "receiverpage.h"

#include <QApplication>
#include <QCheckBox>
#include <QDir>
#include <QFileDialog>
#include <QFormLayout>
#include <QGroupBox>
#include <QHBoxLayout>
#include <QLabel>
#include <QLineEdit>
#include <QLocale>
#include <QPainter>
#include <QProgressBar>
#include <QPushButton>
#include <QSettings>
#include <QSpinBox>
#include <QStandardPaths>
#include <QVBoxLayout>

#include <utility>

namespace {
constexpr int kLevelMax = 1500;      // por encima de este nivel el receptor se acerca a saturar
constexpr double kSpanSeconds = 120; // ventana del grafico
constexpr int kDisplayMs = 100;      // el estado llega cada 20 ms: se muestra diez veces por segundo
constexpr quint16 kDefaultControlPort = 1005;

QString coloredText(const QString &text, const char *color)
{
    return QStringLiteral("<span style='color:%1'>%2</span>").arg(QLatin1String(color), text.toHtmlEscaped());
}
} // namespace

// Ganancia del ADRF (eje izquierdo) y pico de cada rafaga (eje derecho) de los ultimos dos minutos.
class TracePlot : public QWidget
{
public:
    explicit TracePlot(QWidget *parent = nullptr)
        : QWidget(parent)
    {
        setMinimumHeight(180);
        m_clock.start();
    }

    void setTarget(double target)
    {
        m_target = target;
    }

    void setGainRange(double lo, double hi)
    {
        m_gainMin = lo;
        m_gainMax = hi;
    }

    void clear()
    {
        m_samples.clear();
        update();
    }

    void add(double gainDb, double peak)
    {
        const double t = m_clock.elapsed() / 1000.0;
        m_samples.append({t, gainDb, peak});
        while (!m_samples.isEmpty() && t - m_samples.first().t > kSpanSeconds)
            m_samples.removeFirst();
        update();
    }

protected:
    void paintEvent(QPaintEvent *) override
    {
        QPainter p(this);
        p.setRenderHint(QPainter::Antialiasing);
        const QRectF r = rect().adjusted(46, 8, -50, -22);
        const QColor text = palette().color(QPalette::Text);
        QColor grid = text;
        grid.setAlpha(40);
        const QColor gainColor(0x1f, 0x77, 0xb4);
        const QColor peakColor(0xff, 0x7f, 0x0e);

        p.setPen(grid);
        for (int i = 0; i <= 5; ++i) {
            const double y = r.bottom() - r.height() * i / 5.0;
            p.drawLine(QPointF(r.left(), y), QPointF(r.right(), y));
            p.setPen(gainColor);
            p.drawText(QRectF(0, y - 8, r.left() - 4, 16), Qt::AlignRight | Qt::AlignVCenter,
                       QString::number(m_gainMin + (m_gainMax - m_gainMin) * i / 5.0, 'f', 0));
            p.setPen(peakColor);
            p.drawText(QRectF(r.right() + 4, y - 8, 46, 16), Qt::AlignLeft | Qt::AlignVCenter,
                       QString::number(kLevelMax * i / 5));
            p.setPen(grid);
        }
        p.setPen(text);
        p.drawText(QRectF(r.left(), r.bottom() + 4, 120, 16), Qt::AlignLeft, tr("hace 2 min"));
        p.drawText(QRectF(r.right() - 60, r.bottom() + 4, 60, 16), Qt::AlignRight, tr("ahora"));
        const QString gainLegend = tr("Ganancia [dB]");
        const double legendX = r.left() + 8 + p.fontMetrics().horizontalAdvance(gainLegend) + 24;
        p.setPen(gainColor);
        p.drawText(QRectF(r.left() + 8, r.top() + 2, 200, 16), Qt::AlignLeft, gainLegend);
        p.setPen(peakColor);
        p.drawText(QRectF(legendX, r.top() + 2, 260, 16), Qt::AlignLeft, tr("Pico de cada ráfaga"));
        p.setPen(text);

        if (m_samples.isEmpty()) {
            p.drawText(r, Qt::AlignCenter, tr("Sin datos del AGC"));
            return;
        }
        auto yGain = [&](double g) { return r.bottom() - r.height() * qBound(0.0, (g - m_gainMin) / (m_gainMax - m_gainMin), 1.0); };
        auto yPeak = [&](double v) { return r.bottom() - r.height() * qBound(0.0, v / kLevelMax, 1.0); };
        if (m_target > 0) {
            QPen dash(peakColor, 1, Qt::DashLine);
            p.setPen(dash);
            p.drawLine(QPointF(r.left(), yPeak(m_target)), QPointF(r.right(), yPeak(m_target)));
        }
        const double now = m_clock.elapsed() / 1000.0;
        auto xAt = [&](double t) { return r.right() - r.width() * (now - t) / kSpanSeconds; };
        QPolygonF gain, peak;
        for (const Sample &s : std::as_const(m_samples)) {
            gain << QPointF(xAt(s.t), yGain(s.gain));
            peak << QPointF(xAt(s.t), yPeak(s.peak));
        }
        p.setClipRect(r.adjusted(-1, -1, 1, 1));
        p.setPen(QPen(peakColor, 1.2));
        p.drawPolyline(peak);
        p.setPen(QPen(gainColor, 2));
        p.drawPolyline(gain);
    }

private:
    struct Sample
    {
        double t, gain, peak;
    };
    QVector<Sample> m_samples;
    QElapsedTimer m_clock;
    double m_target = 0;
    double m_gainMin = 0;
    double m_gainMax = 30;
};

ReceiverPage::ReceiverPage(QWidget *parent)
    : QWidget(parent)
{
    QSettings settings;
    auto label = [] {
        auto *l = new QLabel(QStringLiteral("—"));
        l->setTextInteractionFlags(Qt::TextSelectableByMouse);
        return l;
    };

    auto *agc = new QGroupBox(tr("AGC (adrf_server)"));
    auto *agcForm = new QFormLayout(agc);
    agcForm->addRow(tr("Estado:"), m_agcState = label());
    agcForm->addRow(tr("Ganancia:"), m_gain = label());
    agcForm->addRow(tr("Objetivo:"), m_target = label());
    agcForm->addRow(tr("Pico de la última ráfaga:"), m_lastPeak = label());
    agcForm->addRow(tr("Ráfagas procesadas:"), m_agcBursts = label());
    agcForm->addRow(tr("Cambios de ganancia:"), m_agcChanges = label());
    agcForm->addRow(tr("Protecciones de nivel:"), m_agcProtections = label());
    agcForm->addRow(tr("Errores al cambiar la ganancia:"), m_agcErrors = label());
    m_port = new QSpinBox;
    m_port->setRange(1, 65535);
    m_port->setValue(settings.value(QStringLiteral("receiver/controlPort"), kDefaultControlPort).toInt());
    m_port->setToolTip(tr("Puerto del servidor del ADRF en la Red Pitaya. Atiende un solo cliente: con un notebook conectado a ese puerto, esta pestaña no recibe el estado del AGC."));
    agcForm->addRow(tr("Puerto del servidor:"), m_port);
    m_lastPort = quint16(m_port->value());

    auto *top = new QHBoxLayout;
    top->addWidget(makeChannelBox(m_ch[0], tr("Canal A (161,975 MHz)")), 1);
    top->addWidget(makeChannelBox(m_ch[1], tr("Canal B (162,025 MHz)")), 1);
    top->addWidget(agc, 1);

    m_plot = new TracePlot;
    auto *plotBox = new QGroupBox(tr("Ganancia y pico de cada ráfaga"));
    auto *plotLayout = new QVBoxLayout(plotBox);
    plotLayout->addWidget(m_plot);

    auto *csv = new QGroupBox(tr("Registro en CSV"));
    auto *csvLayout = new QHBoxLayout(csv);
    m_csvCheck = new QCheckBox(tr("Registrar en CSV"));
    m_csvFolder = new QLineEdit(settings
                                    .value(QStringLiteral("receiver/csvFolder"),
                                           QDir(QStandardPaths::writableLocation(QStandardPaths::DocumentsLocation))
                                               .filePath(QStringLiteral("ReceptorAIS")))
                                    .toString());
    m_csvFolder->setReadOnly(true);
    m_csvBrowse = new QPushButton(tr("Elegir carpeta…"));
    m_csvInfo = new QLabel;
    m_csvInfo->setTextInteractionFlags(Qt::TextSelectableByMouse);
    csvLayout->addWidget(m_csvCheck);
    csvLayout->addWidget(m_csvFolder, 1);
    csvLayout->addWidget(m_csvBrowse);
    auto *csvOuter = new QVBoxLayout;
    csvOuter->addLayout(csvLayout);
    csvOuter->addWidget(m_csvInfo);
    csv->setLayout(csvOuter);

    auto *root = new QVBoxLayout(this);
    root->addLayout(top);
    root->addWidget(plotBox, 1);
    root->addWidget(csv);

    connect(m_port, &QSpinBox::editingFinished, this, [this] {
        const quint16 port = quint16(m_port->value());
        if (port != m_lastPort) {
            m_lastPort = port;
            emit controlPortChanged(port);
        }
    });
    connect(m_csvCheck, &QCheckBox::toggled, this, [this](bool on) { emit loggingRequested(on, m_csvFolder->text()); });
    connect(m_csvBrowse, &QPushButton::clicked, this, [this] {
        const QString dir = QFileDialog::getExistingDirectory(this, tr("Carpeta de los registros CSV"), m_csvFolder->text());
        if (!dir.isEmpty())
            m_csvFolder->setText(QDir::toNativeSeparators(dir));
    });
    connect(&m_second, &QTimer::timeout, this, &ReceiverPage::onSecond);
    m_second.start(1000);
    resetDisplay();
}

quint16 ReceiverPage::controlPort() const
{
    return quint16(m_port->value());
}

void ReceiverPage::saveSettings() const
{
    QSettings settings;
    settings.setValue(QStringLiteral("receiver/controlPort"), m_port->value());
    settings.setValue(QStringLiteral("receiver/csvFolder"), m_csvFolder->text());
}

QString ReceiverPage::count(quint64 value)
{
    return QLocale().toString(value);
}

QGroupBox *ReceiverPage::makeChannelBox(Channel &c, const QString &title)
{
    auto label = [] {
        auto *l = new QLabel(QStringLiteral("—"));
        l->setTextInteractionFlags(Qt::TextSelectableByMouse);
        return l;
    };
    c.box = new QGroupBox(title);
    auto *form = new QFormLayout(c.box);
    c.level = new QProgressBar;
    c.level->setRange(0, kLevelMax);
    c.level->setFormat(QStringLiteral("%v"));
    form->addRow(tr("Nivel:"), c.level);
    form->addRow(tr("Pico del último segundo:"), c.levelPeak = label());
    form->addRow(tr("Squelch:"), c.squelch = label());
    form->addRow(tr("Palabras en la FIFO:"), c.fifo = label());
    form->addRow(tr("Ráfagas por segundo:"), c.burstRate = label());
    form->addRow(tr("Mensajes AIS:"), c.messages = label());
    form->addRow(tr("Tramas correctas:"), c.frames = label());
    form->addRow(tr("FCS incorrecto:"), c.badFcs = label());
    form->addRow(tr("Descartadas (tipo o largo):"), c.discarded = label());
    form->addRow(tr("Abortadas:"), c.aborted = label());
    return c.box;
}

void ReceiverPage::resetDisplay()
{
    for (Channel &c : m_ch) {
        for (QLabel *l : {c.levelPeak, c.squelch, c.fifo, c.burstRate, c.messages, c.frames, c.badFcs, c.discarded, c.aborted})
            l->setText(QStringLiteral("—"));
        c.level->setValue(0);
    }
    for (QLabel *l : {m_agcState, m_gain, m_target, m_lastPeak, m_agcBursts, m_agcChanges, m_agcProtections, m_agcErrors})
        l->setText(QStringLiteral("—"));
    m_plot->clear();
    m_agc = AgcStatus();
    m_agcLinked = false;
}

void ReceiverPage::setReceiverActive(bool active)
{
    if (m_active == active)
        return;
    m_active = active;
    for (Channel &c : m_ch) {
        c.edges = 0;
        c.peakSecond = 0;
        c.squelchWas = false;
        c.burstsPerSecond = 0.0;
    }
    m_rateTimer.restart();
    if (!active)
        resetDisplay();
}

void ReceiverPage::setChannelCount(int count)
{
    m_channelCount = qBound(1, count, 2);
    const bool hasB = m_channelCount > 1;
    m_ch[1].box->setEnabled(hasB);
    m_ch[1].box->setTitle(hasB ? tr("Canal B (162,025 MHz)") : tr("Canal B (162,025 MHz): el servidor es de un solo canal"));
}

void ReceiverPage::setReceiverStatus(int channel, quint32 level, bool squelchOpen, quint32 fifoWords)
{
    if (channel < 0 || channel > 1)
        return;
    Channel &c = m_ch[channel];
    if (squelchOpen && !c.squelchWas)
        ++c.edges;
    c.squelchWas = squelchOpen;
    c.peakSecond = qMax(c.peakSecond, level);
    c.levelNow = level;
    c.squelchOpen = squelchOpen;
    c.fifoWords = fifoWords;
    if (c.displayTimer.isValid() && c.displayTimer.elapsed() < kDisplayMs)
        return;
    c.displayTimer.start();
    c.level->setValue(int(qMin<quint32>(level, kLevelMax)));
    c.squelch->setText(squelchOpen ? coloredText(tr("abierto"), "#27ae60") : tr("cerrado"));
    c.fifo->setText(count(fifoWords));
}

void ReceiverPage::setAgcLink(bool linked, const QString &message)
{
    m_agcLinked = linked;
    if (!linked) {
        m_agcState->setText(coloredText(message, "#c0392b"));
        m_agcState->setToolTip(message);
    }
}

void ReceiverPage::setAgcStatus(const AgcStatus &s)
{
    m_agc = s;
    m_agcLinked = true;
    m_agcState->setToolTip(QString());
    if (!s.available) {
        m_agcState->setText(coloredText(tr("no disponible (el servidor se inició sin -d)"), "#c0392b"));
        return;
    }
    m_agcState->setText(s.active ? coloredText(tr("activo"), "#27ae60") : coloredText(tr("inactivo"), "#d68910"));
    m_gain->setText(tr("%1 dB (rango %2 a %3 dB)").arg(s.gainDb, 0, 'f', 1).arg(s.minGainDb, 0, 'f', 0).arg(s.maxGainDb, 0, 'f', 0));
    m_target->setText(tr("%1 (percentil %2 de %3 ráfagas, zona muerta %4 dB)")
                          .arg(s.target, 0, 'f', 0)
                          .arg(s.percentile, 0, 'f', 0)
                          .arg(s.window)
                          .arg(s.deadZoneDb, 0, 'f', 1));
    m_lastPeak->setText(count(s.lastPeak));
    m_agcBursts->setText(count(s.bursts));
    m_agcChanges->setText(count(s.changes));
    m_agcProtections->setText(count(s.protections));
    m_agcErrors->setText(s.errors ? coloredText(count(s.errors), "#c0392b") : count(s.errors));
    m_plot->setTarget(s.target);
    m_plot->setGainRange(0, 30);
    m_plot->add(s.gainDb, s.lastPeak);
}

void ReceiverPage::setDecoderStats(int channel, const AisDecoder::Stats &stats)
{
    if (channel >= 0 && channel <= 1)
        m_ch[channel].stats = stats;
}

void ReceiverPage::setLoggerResult(bool active, const QString &text)
{
    m_csvCheck->blockSignals(true);
    m_csvCheck->setChecked(active);
    m_csvCheck->blockSignals(false);
    m_csvBrowse->setEnabled(!active);
    m_csvInfo->setText(text);
}

void ReceiverPage::onSecond()
{
    if (!m_active)
        return;
    const double seconds = qMax(0.001, m_rateTimer.restart() / 1000.0);
    for (int i = 0; i < m_channelCount; ++i) {
        Channel &c = m_ch[i];
        c.burstsPerSecond = c.edges / seconds;
        c.edges = 0;
        const quint32 peak = c.peakSecond;
        c.peakSecond = 0;
        c.levelPeak->setText(count(peak));
        c.burstRate->setText(QString::number(c.burstsPerSecond, 'f', 1));
        c.messages->setText(count(c.stats.messages));
        c.frames->setText(count(c.stats.rxFrames));
        c.badFcs->setText(count(c.stats.rxBadFcs));
        c.discarded->setText(count(c.stats.rxDiscarded));
        c.aborted->setText(count(c.stats.rxAborted));

        StatusRow row;
        row.canal = QLatin1Char(char('A' + i));
        row.level = peak;
        row.squelchOpen = c.squelchOpen;
        row.fifoWords = c.fifoWords;
        row.burstsPerSecond = c.burstsPerSecond;
        row.agcLinked = m_agcLinked && m_agc.available;
        row.agcActive = m_agc.active;
        if (row.agcLinked) {
            row.gainDb = m_agc.gainDb;
            row.lastPeak = m_agc.lastPeak;
            row.agcBursts = m_agc.bursts;
            row.agcChanges = m_agc.changes;
            row.agcProtections = m_agc.protections;
            row.agcErrors = m_agc.errors;
        }
        row.messages = c.stats.messages;
        row.frames = c.stats.rxFrames;
        row.badFcs = c.stats.rxBadFcs;
        row.discarded = c.stats.rxDiscarded;
        row.aborted = c.stats.rxAborted;
        emit statusRow(row);
    }
}
