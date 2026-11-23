#include "mainwindow.h"
#include "ui_mainwindow.h"

#include "aisdecoder.h"
#include "connectionpage.h"
#include "demosimulator.h"
#include "mappage.h"
#include "receiverpage.h"
#include "sessionlogger.h"
#include "sshpage.h"
#include "vesselmodel.h"

#include <QApplication>
#include <QCloseEvent>
#include <QDir>
#include <QLabel>
#include <QMessageBox>
#include <QSettings>
#include <QStatusBar>

MainWindow::MainWindow(QWidget *parent)
    : QMainWindow(parent)
    , ui(new Ui::MainWindow)
{
    ui->setupUi(this);

    m_model = new VesselModel(this);
    m_connection = new ConnectionManager(this);
    m_simulator = new DemoSimulator(this);
    m_decoder = new AisDecoder(this);
    m_decoderB = new AisDecoder(this);

    ui->mapPage->setModel(m_model);
    ui->connectionPage->setManager(m_connection);

    // Pestana del receptor: estado, AGC y registro CSV
    m_receiverPage = new ReceiverPage;
    ui->tabs->insertTab(ui->tabs->indexOf(ui->sshPage), m_receiverPage, tr("Receptor"));
    m_adrf = new AdrfLink(this);
    m_logger = new SessionLogger(this);

    // Menus (definidos en mainwindow.ui)
    connect(ui->actionSalir, &QAction::triggered, this, &QWidget::close);
    connect(ui->actionVerMapa, &QAction::triggered, this,
            [this] { ui->tabs->setCurrentWidget(ui->mapPage); });
    connect(ui->actionVerConexion, &QAction::triggered, this,
            [this] { ui->tabs->setCurrentWidget(ui->connectionPage); });
    connect(ui->actionVerSsh, &QAction::triggered, this,
            [this] { ui->tabs->setCurrentWidget(ui->sshPage); });
    connect(ui->actionAcercaDeQt, &QAction::triggered, qApp, &QApplication::aboutQt);
    connect(ui->actionAcercaDe, &QAction::triggered, this, [this] {
        QMessageBox::about(
            this, tr("Acerca de"),
            tr("<h3>Receptor AIS</h3>"
               "<p>Interfaz de visualización para el receptor AIS basado en Red Pitaya.</p>"
               "<p>UTN — Facultad Regional Buenos Aires</p>"
               "<p>Cartografía: © colaboradores de OpenStreetMap.</p>"));
    });

    createStatusBar();

    // Simulacion de buques (para probar la interfaz sin hardware)
    connect(m_simulator, &DemoSimulator::vesselUpdated, m_model, &VesselModel::upsert);
    connect(ui->mapPage, &MapPage::simulationToggled, m_simulator, &DemoSimulator::setRunning);
    connect(m_simulator, &DemoSimulator::runningChanged, ui->mapPage,
            &MapPage::setSimulationRunning);

    // Enlace con la Red Pitaya
    connect(m_connection, &ConnectionManager::stateChanged, this,
            &MainWindow::onConnectionStateChanged);
    connect(m_connection, &ConnectionManager::dataReceived, this, &MainWindow::onRawDataReceived);
    connect(m_connection, &ConnectionManager::wordsReceived, this, &MainWindow::onReceiverWords);
    connect(m_connection, &ConnectionManager::receiverChannels, this, &MainWindow::onReceiverChannels);
    connect(m_connection, &ConnectionManager::receiverChannels, m_receiverPage, &ReceiverPage::setChannelCount);
    connect(m_connection, &ConnectionManager::receiverStatus, this, &MainWindow::onReceiverStatus);
    connect(m_connection, &ConnectionManager::receiverStatus, m_receiverPage, &ReceiverPage::setReceiverStatus);

    // Estado del AGC (servidor del ADRF) y registro CSV
    connect(m_adrf, &AdrfLink::statusUpdated, m_receiverPage, &ReceiverPage::setAgcStatus);
    connect(m_adrf, &AdrfLink::statusUpdated, this, &MainWindow::onAgcStatus);
    connect(m_adrf, &AdrfLink::linkChanged, m_receiverPage, &ReceiverPage::setAgcLink);
    connect(m_adrf, &AdrfLink::linkChanged, this, &MainWindow::onAgcLink);
    connect(m_receiverPage, &ReceiverPage::controlPortChanged, this, [this](quint16 port) {
        if (m_adrf->isOpen())
            m_adrf->open(m_connection->config().host, port);
    });
    connect(m_receiverPage, &ReceiverPage::statusRow, m_logger, &SessionLogger::logStatus);
    connect(m_receiverPage, &ReceiverPage::loggingRequested, this, &MainWindow::onLoggingRequested);

    // Un decodificador por canal: cada buque decodificado, de cualquiera de los dos, entra al mismo modelo que usa el mapa
    for (AisDecoder *decoder : {m_decoder, m_decoderB}) {
        const QChar channel = QLatin1Char(decoder == m_decoder ? 'A' : 'B');
        connect(decoder, &AisDecoder::vesselDecoded, m_model, &VesselModel::upsert);
        connect(decoder, &AisDecoder::vesselDecoded, this, [this, channel](const Vessel &vessel) { m_logger->logMessage(vessel, channel); });
        connect(decoder, &AisDecoder::statsChanged, this, &MainWindow::updateDecoderStatus);
    }

    connect(m_model, &VesselModel::countChanged, this,
            [this](int n) { m_statusVessels->setText(tr("Buques: %1").arg(n)); });

    QSettings s;
    restoreGeometry(s.value(QStringLiteral("window/geometry")).toByteArray());
    ui->mapPage->restoreState(s.value(QStringLiteral("window/mapSplitter")).toByteArray());
}

MainWindow::~MainWindow()
{
    delete ui;
}

void MainWindow::createStatusBar()
{
    m_statusConnection = new QLabel;
    m_statusVessels = new QLabel(tr("Buques: 0"));
    m_statusAis = new QLabel;
    m_statusRx = new QLabel(tr("RX: 0 bytes"));
    m_statusReceiver = new QLabel;
    m_statusAgc = new QLabel;
    statusBar()->addWidget(m_statusConnection, 1);
    statusBar()->addPermanentWidget(m_statusReceiver);
    statusBar()->addPermanentWidget(m_statusAgc);
    statusBar()->addPermanentWidget(m_statusVessels);
    statusBar()->addPermanentWidget(m_statusAis);
    statusBar()->addPermanentWidget(m_statusRx);
    updateDecoderStatus();
    onConnectionStateChanged(m_connection->state(), QString());
}

void MainWindow::onConnectionStateChanged(ConnectionManager::State state, const QString &message)
{
    QString text = QStringLiteral("<span style='color:%1; font-size:14px'>&#9679;</span> %2")
                       .arg(ConnectionManager::stateColor(state),
                            ConnectionManager::stateText(state));
    if (state != ConnectionManager::State::Disconnected)
        text += QStringLiteral(" — %1").arg(m_connection->config().summary().toHtmlEscaped());
    m_statusConnection->setText(text);
    m_statusConnection->setToolTip(message);
    if (state != ConnectionManager::State::Connected)
        m_statusReceiver->clear();

    // El estado del AGC se consulta al servidor del ADRF mientras el receptor esta conectado
    const bool receiverUp = state == ConnectionManager::State::Connected
                            && m_connection->config().dataFormat == ConnectionConfig::DataFormat::Receiver;
    m_receiverPage->setReceiverActive(receiverUp);
    if (receiverUp) {
        m_adrf->open(m_connection->config().host, m_receiverPage->controlPort());
    } else {
        m_adrf->close();
        m_statusAgc->clear();
        m_statusAgc->setToolTip(QString());
    }

    // Conexion nueva: se descarta cualquier linea o mensaje a medio armar
    if (state == ConnectionManager::State::Connecting || state == ConnectionManager::State::Listening) {
        m_decoder->reset();
        m_decoderB->reset();
        m_channelCount = 1;
        m_rx[0] = m_rx[1] = ChannelState();
    }
}

void MainWindow::onRawDataReceived(const QByteArray &data)
{
    m_statusRx->setText(tr("RX: %L1 bytes").arg(m_connection->bytesReceived()));

    switch (m_connection->config().dataFormat) {
    case ConnectionConfig::DataFormat::Nmea:
        m_decoder->feed(data);
        break;
    case ConnectionConfig::DataFormat::Receiver:
        break; // las palabras de la FIFO llegan por wordsReceived y las arma AisDecoder::feedWords
    case ConnectionConfig::DataFormat::Raw:
        break; // solo monitor
    }
}

void MainWindow::onReceiverWords(int channel, const QVector<quint32> &words)
{
    (channel == 1 ? m_decoderB : m_decoder)->feedWords(words);
}

void MainWindow::onReceiverChannels(int count)
{
    m_channelCount = qBound(1, count, 2);
    refreshReceiverLabel();
}

void MainWindow::onReceiverStatus(int channel, quint32 level, bool squelchOpen, quint32 fifoWords)
{
    if (channel < 0 || channel > 1)
        return;
    m_rx[channel] = {level, squelchOpen, fifoWords};
    // El estado llega cada 20 ms por canal: se muestra unas pocas veces por segundo.
    if (m_receiverStatusTimer.isValid() && m_receiverStatusTimer.elapsed() < 250)
        return;
    m_receiverStatusTimer.start();
    refreshReceiverLabel();
}

void MainWindow::refreshReceiverLabel()
{
    const QString open = tr("abierto");
    const QString closed = tr("cerrado");
    if (m_channelCount > 1) {
        m_statusReceiver->setText(tr("Receptor A: nivel %L1 (%2) · B: nivel %L3 (%4)")
                                      .arg(m_rx[0].level)
                                      .arg(m_rx[0].squelchOpen ? open : closed)
                                      .arg(m_rx[1].level)
                                      .arg(m_rx[1].squelchOpen ? open : closed));
        m_statusReceiver->setToolTip(tr("Palabras pendientes en las FIFO del receptor: A %L1, B %L2")
                                         .arg(m_rx[0].fifoWords)
                                         .arg(m_rx[1].fifoWords));
        return;
    }
    m_statusReceiver->setText(tr("Receptor: nivel %L1 · squelch %2").arg(m_rx[0].level).arg(m_rx[0].squelchOpen ? open : closed));
    m_statusReceiver->setToolTip(tr("Palabras pendientes en la FIFO del receptor: %L1").arg(m_rx[0].fifoWords));
}

void MainWindow::onAgcStatus(const AgcStatus &s)
{
    if (!s.available) {
        m_statusAgc->setText(tr("AGC: no disponible"));
        return;
    }
    m_statusAgc->setText(tr("AGC: %1 dB%2").arg(s.gainDb, 0, 'f', 1).arg(s.active ? QString() : tr(" (inactivo)")));
    m_statusAgc->setToolTip(tr("Pico de la última ráfaga: %L1 (objetivo %L2)\nRáfagas procesadas: %L3 · cambios de ganancia: %L4 · protecciones: %L5")
                                .arg(s.lastPeak)
                                .arg(s.target, 0, 'f', 0)
                                .arg(s.bursts)
                                .arg(s.changes)
                                .arg(s.protections));
}

void MainWindow::onAgcLink(bool linked, const QString &message)
{
    if (linked || m_connection->state() != ConnectionManager::State::Connected)
        return;
    m_statusAgc->setText(tr("AGC: sin enlace"));
    m_statusAgc->setToolTip(message);
}

void MainWindow::onLoggingRequested(bool on, const QString &folder)
{
    if (!on) {
        m_logger->stop();
        m_receiverPage->setLoggerResult(false, tr("Registro detenido"));
        return;
    }
    QString error;
    if (!m_logger->start(folder, &error)) {
        m_receiverPage->setLoggerResult(false, error);
        return;
    }
    m_receiverPage->setLoggerResult(true, tr("Registrando en %1 y %2")
                                              .arg(QDir::toNativeSeparators(m_logger->messagesPath()),
                                                   QDir::toNativeSeparators(m_logger->statusPath())));
}

namespace {
// Los contadores de los dos canales, sumados
AisDecoder::Stats sumStats(const AisDecoder::Stats &a, const AisDecoder::Stats &b)
{
    AisDecoder::Stats s = a;
    s.sentences += b.sentences;
    s.badChecksum += b.badChecksum;
    s.malformed += b.malformed;
    s.messages += b.messages;
    s.unsupported += b.unsupported;
    for (auto it = b.byType.cbegin(); it != b.byType.cend(); ++it)
        s.byType[it.key()] += it.value();
    s.rxBits += b.rxBits;
    s.rxCandidates += b.rxCandidates;
    s.rxBadFcs += b.rxBadFcs;
    s.rxDiscarded += b.rxDiscarded;
    s.rxAborted += b.rxAborted;
    s.rxFrames += b.rxFrames;
    return s;
}
} // namespace

void MainWindow::updateDecoderStatus()
{
    m_receiverPage->setDecoderStats(0, m_decoder->stats());
    m_receiverPage->setDecoderStats(1, m_decoderB->stats());
    const AisDecoder::Stats st = sumStats(m_decoder->stats(), m_decoderB->stats());
    m_statusAis->setText(tr("AIS: %L1 mensajes").arg(st.messages));
    QStringList types;
    for (auto it = st.byType.cbegin(); it != st.byType.cend(); ++it)
        types << tr("tipo %1: %L2").arg(it.key()).arg(it.value());
    QString perChannel;
    if (m_channelCount > 1)
        perChannel = tr("Mensajes por canal: A %L1, B %L2\n").arg(m_decoder->stats().messages).arg(m_decoderB->stats().messages);
    m_statusAis->setToolTip(perChannel
                            + tr("Sentencias válidas: %L1\nChecksum inválido: %L2\nMal formadas: %L3\n"
                                 "Tipos sin buque (ignorados): %L4\n"
                                 "Receptor (suma de los canales): bits %L5, tramas %L6, FCS malo %L7, descartadas por tipo o largo %L8, abortadas %L9\n%10")
                                  .arg(st.sentences)
                                  .arg(st.badChecksum)
                                  .arg(st.malformed)
                                  .arg(st.unsupported)
                                  .arg(st.rxBits)
                                  .arg(st.rxFrames)
                                  .arg(st.rxBadFcs)
                                  .arg(st.rxDiscarded)
                                  .arg(st.rxAborted)
                                  .arg(types.join(QLatin1Char('\n'))));
}

void MainWindow::closeEvent(QCloseEvent *event)
{
    QSettings s;
    s.setValue(QStringLiteral("window/geometry"), saveGeometry());
    s.setValue(QStringLiteral("window/mapSplitter"), ui->mapPage->saveState());
    ui->connectionPage->saveSettings();
    ui->sshPage->saveSettings();
    m_receiverPage->saveSettings();
    m_logger->stop();
    m_adrf->close();
    m_connection->close();
    event->accept();
}
