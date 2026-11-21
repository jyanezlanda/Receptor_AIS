#include "mainwindow.h"
#include "ui_mainwindow.h"

#include "aisdecoder.h"
#include "connectionpage.h"
#include "demosimulator.h"
#include "mappage.h"
#include "sshpage.h"
#include "vesselmodel.h"

#include <QApplication>
#include <QCloseEvent>
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

    ui->mapPage->setModel(m_model);
    ui->connectionPage->setManager(m_connection);

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

    // Decodificador AIS: cada buque decodificado entra al mismo modelo que usa el mapa
    connect(m_decoder, &AisDecoder::vesselDecoded, m_model, &VesselModel::upsert);
    connect(m_decoder, &AisDecoder::statsChanged, this, &MainWindow::updateDecoderStatus);

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
    statusBar()->addWidget(m_statusConnection, 1);
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

    // Conexion nueva: se descarta cualquier linea o mensaje a medio armar
    if (state == ConnectionManager::State::Connecting || state == ConnectionManager::State::Listening)
        m_decoder->reset();
}

void MainWindow::onRawDataReceived(const QByteArray &data)
{
    m_statusRx->setText(tr("RX: %L1 bytes").arg(m_connection->bytesReceived()));

    switch (m_connection->config().dataFormat) {
    case ConnectionConfig::DataFormat::Nmea:
        m_decoder->feed(data);
        break;
    case ConnectionConfig::DataFormat::DemodBits:
        // TODO: decodificar los bits demodulados de la FPGA (NRZI, HDLC, CRC) y pasar el
        //       payload a AisDecoder::decodePayload().
        break;
    case ConnectionConfig::DataFormat::Raw:
        break; // solo monitor
    }
}

void MainWindow::updateDecoderStatus()
{
    const AisDecoder::Stats &st = m_decoder->stats();
    m_statusAis->setText(tr("AIS: %L1 mensajes").arg(st.messages));
    QStringList types;
    for (auto it = st.byType.cbegin(); it != st.byType.cend(); ++it)
        types << tr("tipo %1: %L2").arg(it.key()).arg(it.value());
    m_statusAis->setToolTip(tr("Sentencias válidas: %L1\nChecksum inválido: %L2\nMal formadas: %L3\n"
                               "Tipos sin buque (ignorados): %L4\n%5")
                                .arg(st.sentences)
                                .arg(st.badChecksum)
                                .arg(st.malformed)
                                .arg(st.unsupported)
                                .arg(types.join(QLatin1Char('\n'))));
}

void MainWindow::closeEvent(QCloseEvent *event)
{
    QSettings s;
    s.setValue(QStringLiteral("window/geometry"), saveGeometry());
    s.setValue(QStringLiteral("window/mapSplitter"), ui->mapPage->saveState());
    ui->connectionPage->saveSettings();
    ui->sshPage->saveSettings();
    m_connection->close();
    event->accept();
}
