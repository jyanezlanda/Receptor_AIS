#include "connectionpage.h"
#include "ui_connectionpage.h"

#include <QButtonGroup>
#include <QDateTime>
#include <QDesktopServices>
#include <QFontDatabase>
#include <QIntValidator>
#include <QNetworkInterface>
#include <QSerialPortInfo>
#include <QSettings>
#include <QTcpSocket>
#include <QTimer>
#include <QUrl>

namespace {

/*
 * Los combos se cargan en connectionpage.ui. Estas tablas traducen el
 * indice elegido al valor real: si se agregan o reordenan opciones en
 * Designer, actualizar tambien la tabla correspondiente.
 */
const QSerialPort::DataBits kDataBits[] = {      // cmbBitsDatos: 5, 6, 7, 8
    QSerialPort::Data5, QSerialPort::Data6, QSerialPort::Data7, QSerialPort::Data8};
const QSerialPort::Parity kParity[] = {          // cmbParidad
    QSerialPort::NoParity, QSerialPort::EvenParity, QSerialPort::OddParity,
    QSerialPort::MarkParity, QSerialPort::SpaceParity};
const QSerialPort::StopBits kStopBits[] = {      // cmbBitsParada: 1, 1.5, 2
    QSerialPort::OneStop, QSerialPort::OneAndHalfStop, QSerialPort::TwoStop};
const QSerialPort::FlowControl kFlow[] = {       // cmbFlujo
    QSerialPort::NoFlowControl, QSerialPort::HardwareControl, QSerialPort::SoftwareControl};
const ConnectionConfig::Protocol kProtocol[] = { // cmbEthProtocolo / cmbWifiProtocolo
    ConnectionConfig::Protocol::Tcp, ConnectionConfig::Protocol::Udp};
const ConnectionConfig::Role kRole[] = {         // cmbEthRol
    ConnectionConfig::Role::Client, ConnectionConfig::Role::Server};
const ConnectionConfig::DataFormat kFormat[] = { // cmbFormato
    ConnectionConfig::DataFormat::Receiver, ConnectionConfig::DataFormat::Nmea,
    ConnectionConfig::DataFormat::Raw};

template<typename T, size_t N>
T pick(const T (&table)[N], int index)
{
    return table[qBound(0, index, int(N) - 1)];
}

const char kDefaultWifiApHost[] = "192.168.42.1";

// Llena un combo con los adaptadores de red activos del tipo pedido.
// Devuelve la cantidad de adaptadores encontrados.
int fillAdapters(QComboBox *combo, bool wifi)
{
    const QString previous = combo->currentData().toString();
    combo->clear();
    combo->addItem(QObject::tr("Automático (según la tabla de rutas)"), QString());
    int found = 0;
    const auto interfaces = QNetworkInterface::allInterfaces();
    for (const QNetworkInterface &iface : interfaces) {
        const auto flags = iface.flags();
        if (!(flags & QNetworkInterface::IsUp) || (flags & QNetworkInterface::IsLoopBack))
            continue;
        if ((iface.type() == QNetworkInterface::Wifi) != wifi)
            continue;
        for (const QNetworkAddressEntry &entry : iface.addressEntries()) {
            const QHostAddress ip = entry.ip();
            if (ip.protocol() != QAbstractSocket::IPv4Protocol)
                continue;
            combo->addItem(QStringLiteral("%1 — %2").arg(iface.humanReadableName(), ip.toString()),
                           ip.toString());
            ++found;
        }
    }
    const int idx = combo->findData(previous);
    combo->setCurrentIndex(idx >= 0 ? idx : 0);
    return found;
}

} // namespace

ConnectionPage::ConnectionPage(QWidget *parent)
    : QWidget(parent)
    , ui(new Ui::ConnectionPage)
{
    ui->setupUi(this);

    ui->splitter->setStretchFactor(0, 0);
    ui->splitter->setStretchFactor(1, 1);
    ui->splitter->setSizes({520, 700});
    ui->txtMonitor->setFont(QFontDatabase::systemFont(QFontDatabase::FixedFont));
    ui->cmbBaudios->setValidator(new QIntValidator(50, 10000000, ui->cmbBaudios));
    for (QLabel *hint : {ui->lblInterfazDesc, ui->lblPuertoInfo, ui->lblEthAyuda, ui->lblWifiAyuda})
        hint->setForegroundRole(QPalette::PlaceholderText);

    // Seleccion de interfaz: una sola pagina visible a la vez (los
    // widgets ocultos no ocupan lugar, asi el formulario se ajusta).
    m_ifaceGroup = new QButtonGroup(this);
    m_ifaceGroup->addButton(ui->radioSerie, int(ConnectionConfig::Interface::Serial));
    m_ifaceGroup->addButton(ui->radioEthernet, int(ConnectionConfig::Interface::Ethernet));
    m_ifaceGroup->addButton(ui->radioWifi, int(ConnectionConfig::Interface::Wifi));
    m_pages = {ui->grpSerie, ui->grpEthernet, ui->grpWifi};
    for (QWidget *page : std::as_const(m_pages))
        page->hide();
    connect(m_ifaceGroup, &QButtonGroup::idToggled, this, [this](int id, bool on) {
        if (on)
            onInterfaceChanged(id);
    });

    // Serie
    connect(ui->btnActualizarPuertos, &QPushButton::clicked, this,
            &ConnectionPage::refreshSerialPorts);
    connect(ui->cmbPuerto, &QComboBox::currentIndexChanged, this,
            &ConnectionPage::updateSerialPortInfo);

    // Ethernet / WiFi
    connect(ui->cmbFormato, &QComboBox::currentIndexChanged, this, &ConnectionPage::onFormatChanged);
    connect(ui->cmbEthRol, &QComboBox::currentIndexChanged, this,
            &ConnectionPage::updateNetworkFieldStates);
    connect(ui->cmbEthProtocolo, &QComboBox::currentIndexChanged, this,
            &ConnectionPage::updateNetworkFieldStates);
    connect(ui->cmbWifiProtocolo, &QComboBox::currentIndexChanged, this,
            &ConnectionPage::updateNetworkFieldStates);
    connect(ui->btnActualizarAdaptadores, &QPushButton::clicked, this,
            &ConnectionPage::refreshAdapters);
    connect(ui->btnRedesWifi, &QPushButton::clicked, this, [] {
#ifdef Q_OS_WIN
        QDesktopServices::openUrl(QUrl(QStringLiteral("ms-settings:network-wifi")));
#endif
    });
    connect(ui->cmbWifiModo, &QComboBox::currentIndexChanged, this, [this](int mode) {
        if (mode == 0 && ui->txtWifiHost->text().trimmed().isEmpty())
            ui->txtWifiHost->setText(QString::fromLatin1(kDefaultWifiApHost));
        else if (mode == 1 && ui->txtWifiHost->text() == QLatin1String(kDefaultWifiApHost))
            ui->txtWifiHost->clear();
    });

    // Botones
    connect(ui->btnConectar, &QPushButton::clicked, this, &ConnectionPage::onConnectClicked);
    connect(ui->btnProbar, &QPushButton::clicked, this, &ConnectionPage::onTestClicked);
    connect(ui->btnLimpiarMonitor, &QPushButton::clicked, this, [this] {
        ui->txtMonitor->clear();
        m_rxTotal = 0;
    });

    // Velocidad de recepcion
    auto *rateTimer = new QTimer(this);
    connect(rateTimer, &QTimer::timeout, this, [this] {
        ui->lblRxStats->setText(
            tr("Recibidos: %L1 bytes  ·  %L2 B/s").arg(m_rxTotal).arg(m_rxWindow));
        m_rxWindow = 0;
    });
    rateTimer->start(1000);

    refreshSerialPorts();
    refreshAdapters();
    loadSettings();
    onFormatChanged();
    onStateChanged(ConnectionManager::State::Disconnected, QString());
}

ConnectionPage::~ConnectionPage()
{
    delete ui;
}

void ConnectionPage::setManager(ConnectionManager *manager)
{
    m_manager = manager;
    connect(m_manager, &ConnectionManager::stateChanged, this, &ConnectionPage::onStateChanged);
    connect(m_manager, &ConnectionManager::dataReceived, this, &ConnectionPage::onDataReceived);
    onStateChanged(m_manager->state(), QString());
}

// ---------------------------------------------------------------------------

void ConnectionPage::onInterfaceChanged(int id)
{
    for (int i = 0; i < m_pages.size(); ++i)
        m_pages[i]->setVisible(i == id);
    // La descripcion es el tooltip del boton (editable en Designer).
    if (QAbstractButton *b = m_ifaceGroup->button(id))
        ui->lblInterfazDesc->setText(b->toolTip());
    updateNetworkFieldStates();
}

void ConnectionPage::refreshSerialPorts()
{
    const QString previous = ui->cmbPuerto->currentText();
    ui->cmbPuerto->clear();
    const auto ports = QSerialPortInfo::availablePorts();
    for (const QSerialPortInfo &info : ports)
        ui->cmbPuerto->addItem(info.portName());
    if (!previous.isEmpty())
        ui->cmbPuerto->setCurrentText(previous);
    updateSerialPortInfo();
}

void ConnectionPage::updateSerialPortInfo()
{
    const QString name = ui->cmbPuerto->currentText();
    const auto ports = QSerialPortInfo::availablePorts();
    for (const QSerialPortInfo &info : ports) {
        if (info.portName() != name)
            continue;
        QStringList parts;
        if (!info.description().isEmpty())
            parts << info.description();
        if (!info.manufacturer().isEmpty())
            parts << info.manufacturer();
        if (info.hasVendorIdentifier() && info.hasProductIdentifier())
            parts << QStringLiteral("VID:PID %1:%2")
                         .arg(info.vendorIdentifier(), 4, 16, QLatin1Char('0'))
                         .arg(info.productIdentifier(), 4, 16, QLatin1Char('0'));
        ui->lblPuertoInfo->setText(parts.join(QStringLiteral(" · ")));
        return;
    }
    ui->lblPuertoInfo->setText(ports.isEmpty() ? tr("No se detectaron puertos serie.")
                                               : QString());
}

void ConnectionPage::refreshAdapters()
{
    fillAdapters(ui->cmbEthAdaptador, false);
    const int wifi = fillAdapters(ui->cmbWifiAdaptador, true);
    ui->lblWifiAviso->setVisible(wifi == 0);
}

void ConnectionPage::onFormatChanged()
{
    if (pick(kFormat, ui->cmbFormato->currentIndex()) == ConnectionConfig::DataFormat::Receiver) {
        // 1004 era el puerto de un servidor que ya no existe: el de datos del receptor es el 1003.
        for (QSpinBox *port : {ui->spnEthPuerto, ui->spnWifiPuerto}) {
            if (port->value() == 1004)
                port->setValue(1003);
        }
    }
    updateNetworkFieldStates();
}

void ConnectionPage::updateNetworkFieldStates()
{
    // Receptor: la PC es siempre cliente TCP del adc_server de la Red Pitaya.
    const bool receiver = pick(kFormat, ui->cmbFormato->currentIndex())
                          == ConnectionConfig::DataFormat::Receiver;
    ui->cmbEthProtocolo->setEnabled(!receiver);
    ui->cmbWifiProtocolo->setEnabled(!receiver);

    // Ethernet
    const bool ethUdp = !receiver && pick(kProtocol, ui->cmbEthProtocolo->currentIndex())
                                         == ConnectionConfig::Protocol::Udp;
    const bool ethServer = !receiver && pick(kRole, ui->cmbEthRol->currentIndex())
                                            == ConnectionConfig::Role::Server;
    ui->cmbEthRol->setEnabled(!receiver && !ethUdp);
    ui->txtEthHost->setEnabled(!ethUdp && !ethServer);
    ui->spnEthPuerto->setEnabled(!ethUdp && !ethServer);
    ui->spnEthPuertoLocal->setEnabled(ethUdp || ethServer);

    // WiFi (la PC siempre es cliente en TCP)
    const bool wifiUdp = !receiver && pick(kProtocol, ui->cmbWifiProtocolo->currentIndex())
                                          == ConnectionConfig::Protocol::Udp;
    ui->spnWifiPuerto->setEnabled(!wifiUdp);
    ui->spnWifiPuertoLocal->setEnabled(wifiUdp);

    const bool serial = m_ifaceGroup->checkedId() == int(ConnectionConfig::Interface::Serial);
    ui->spnTimeout->setEnabled(!serial);
}

ConnectionConfig ConnectionPage::currentConfig() const
{
    ConnectionConfig c;
    c.interface = ConnectionConfig::Interface(qMax(0, m_ifaceGroup->checkedId()));
    c.dataFormat = pick(kFormat, ui->cmbFormato->currentIndex());
    c.timeoutMs = ui->spnTimeout->value();
    c.autoReconnect = ui->chkReconectar->isChecked();

    c.serialPort = ui->cmbPuerto->currentText().trimmed();
    c.baudRate = ui->cmbBaudios->currentText().toInt();
    c.dataBits = pick(kDataBits, ui->cmbBitsDatos->currentIndex());
    c.parity = pick(kParity, ui->cmbParidad->currentIndex());
    c.stopBits = pick(kStopBits, ui->cmbBitsParada->currentIndex());
    c.flowControl = pick(kFlow, ui->cmbFlujo->currentIndex());

    if (c.interface == ConnectionConfig::Interface::Wifi) {
        c.host = ui->txtWifiHost->text().trimmed();
        c.port = quint16(ui->spnWifiPuerto->value());
        c.localPort = quint16(ui->spnWifiPuertoLocal->value());
        c.protocol = pick(kProtocol, ui->cmbWifiProtocolo->currentIndex());
        c.role = ConnectionConfig::Role::Client;
        c.localAddress = ui->cmbWifiAdaptador->currentData().toString();
    } else {
        c.host = ui->txtEthHost->text().trimmed();
        c.port = quint16(ui->spnEthPuerto->value());
        c.localPort = quint16(ui->spnEthPuertoLocal->value());
        c.protocol = pick(kProtocol, ui->cmbEthProtocolo->currentIndex());
        c.role = pick(kRole, ui->cmbEthRol->currentIndex());
        c.localAddress = ui->cmbEthAdaptador->currentData().toString();
    }
    if (c.dataFormat == ConnectionConfig::DataFormat::Receiver) {
        c.protocol = ConnectionConfig::Protocol::Tcp;
        c.role = ConnectionConfig::Role::Client;
    }
    return c;
}

void ConnectionPage::onConnectClicked()
{
    if (!m_manager)
        return;
    const auto state = m_manager->state();
    if (state != ConnectionManager::State::Disconnected
        && state != ConnectionManager::State::Error) {
        m_manager->close();
        return;
    }

    const ConnectionConfig cfg = currentConfig();
    if (cfg.dataFormat == ConnectionConfig::DataFormat::Receiver
        && cfg.interface == ConnectionConfig::Interface::Serial) {
        setStatus(ConnectionManager::stateColor(ConnectionManager::State::Error),
                  tr("El formato Receptor necesita Ethernet o WiFi"),
                  tr("El receptor se conecta por la red al adc_server de la Red Pitaya."));
        return;
    }
    const bool needsHost = cfg.interface != ConnectionConfig::Interface::Serial
                           && cfg.protocol == ConnectionConfig::Protocol::Tcp
                           && cfg.role == ConnectionConfig::Role::Client;
    if (needsHost && cfg.host.isEmpty()) {
        setStatus(ConnectionManager::stateColor(ConnectionManager::State::Error),
                  tr("Falta la dirección"), tr("Ingresá la IP o el nombre de la Red Pitaya."));
        return;
    }
    saveSettings();
    ui->txtMonitor->appendPlainText(tr("── Abriendo %1 ──").arg(cfg.summary()));
    m_manager->open(cfg);
}

void ConnectionPage::onTestClicked()
{
    const QString ok = ConnectionManager::stateColor(ConnectionManager::State::Connected);
    const QString bad = ConnectionManager::stateColor(ConnectionManager::State::Error);
    const ConnectionConfig cfg = currentConfig();

    if (cfg.interface == ConnectionConfig::Interface::Serial) {
        QSerialPort port(cfg.serialPort);
        if (port.open(QIODevice::ReadWrite)) {
            port.close();
            setStatus(ok, tr("Prueba correcta"), tr("El puerto %1 está disponible.").arg(cfg.serialPort));
        } else {
            setStatus(bad, tr("Prueba fallida"),
                      tr("No se pudo abrir %1: %2").arg(cfg.serialPort, port.errorString()));
        }
        return;
    }

    if (cfg.protocol == ConnectionConfig::Protocol::Udp
        || cfg.role == ConnectionConfig::Role::Server) {
        setStatus(ConnectionManager::stateColor(ConnectionManager::State::Disconnected),
                  tr("Sin prueba"),
                  tr("En modo UDP o servidor la PC solo espera datos; usá «Conectar» y mirá el monitor."));
        return;
    }

    if (m_testSocket)
        m_testSocket->deleteLater();
    m_testSocket = new QTcpSocket(this);
    if (!cfg.localAddress.isEmpty())
        m_testSocket->bind(QHostAddress(cfg.localAddress));
    ui->btnProbar->setEnabled(false);
    setStatus(ConnectionManager::stateColor(ConnectionManager::State::Connecting),
              tr("Probando…"), tr("Intentando abrir %1:%2").arg(cfg.host).arg(cfg.port));

    QTcpSocket *socket = m_testSocket;
    auto finish = [this, socket, ok, bad](bool success, const QString &detail) {
        if (socket != m_testSocket)
            return;
        ui->btnProbar->setEnabled(true);
        setStatus(success ? ok : bad, success ? tr("Prueba correcta") : tr("Prueba fallida"), detail);
        socket->disconnect(this);
        socket->abort();
        socket->deleteLater();
        m_testSocket = nullptr;
    };
    connect(socket, &QTcpSocket::connected, this, [finish, cfg] {
        finish(true, tr("La Red Pitaya responde en %1:%2.").arg(cfg.host).arg(cfg.port));
    });
    connect(socket, &QTcpSocket::errorOccurred, this,
            [finish, socket] { finish(false, socket->errorString()); });
    QTimer::singleShot(cfg.timeoutMs, socket,
                       [finish] { finish(false, tr("Sin respuesta dentro del tiempo de espera.")); });
    socket->connectToHost(cfg.host, cfg.port);
}

void ConnectionPage::onStateChanged(ConnectionManager::State state, const QString &message)
{
    setStatus(ConnectionManager::stateColor(state), ConnectionManager::stateText(state), message);

    const bool idle = state == ConnectionManager::State::Disconnected
                      || state == ConnectionManager::State::Error;
    ui->btnConectar->setText(idle ? tr("Conectar") : tr("Desconectar"));
    ui->btnProbar->setEnabled(idle && !m_testSocket);
    ui->configArea->setEnabled(idle);

    if (!message.isEmpty())
        ui->txtMonitor->appendPlainText(QStringLiteral("── %1 ──").arg(message));
}

void ConnectionPage::onDataReceived(const QByteArray &data)
{
    m_rxTotal += quint64(data.size());
    m_rxWindow += quint64(data.size());
    if (ui->chkPausar->isChecked())
        return;

    QString text;
    if (ui->cmbMonitorModo->currentIndex() == 0) { // Hexadecimal
        text = QString::fromLatin1(data.toHex(' ').toUpper());
    } else {                                       // ASCII
        text.reserve(data.size());
        for (char ch : data) {
            const auto c = static_cast<unsigned char>(ch);
            if (c == '\n' || c == '\t' || (c >= 0x20 && c < 0x7f))
                text += QLatin1Char(char(c));
            else if (c != '\r')
                text += QLatin1Char('.');
        }
        if (text.endsWith(QLatin1Char('\n')))
            text.chop(1);
    }
    if (ui->chkMarcasTiempo->isChecked())
        text.prepend(QDateTime::currentDateTime().toString(QStringLiteral("[HH:mm:ss.zzz] ")));
    ui->txtMonitor->appendPlainText(text);
}

void ConnectionPage::setStatus(const QString &color, const QString &title, const QString &detail)
{
    ui->lblLed->setStyleSheet(
        QStringLiteral("background:%1; border-radius:8px; border:1px solid rgba(0,0,0,80);")
            .arg(color));
    ui->lblEstado->setText(title);
    ui->lblEstadoDetalle->setText(detail);
    ui->lblEstadoDetalle->setVisible(!detail.isEmpty());
}

// ---------------------------------------------------------------------------
// Persistencia (los valores por defecto son los del .ui)
// ---------------------------------------------------------------------------

void ConnectionPage::loadSettings()
{
    QSettings s;
    s.beginGroup(QStringLiteral("connection"));

    const int iface = s.value(QStringLiteral("interface"),
                              int(ConnectionConfig::Interface::Ethernet)).toInt();
    QAbstractButton *b = m_ifaceGroup->button(iface);
    (b ? b : ui->radioEthernet)->setChecked(true);

    auto loadIndex = [&s](QComboBox *combo, const QString &key) {
        const int idx = s.value(key, combo->currentIndex()).toInt();
        if (idx >= 0 && idx < combo->count())
            combo->setCurrentIndex(idx);
    };
    auto loadText = [&s](QLineEdit *edit, const QString &key) {
        edit->setText(s.value(key, edit->text()).toString());
    };
    auto loadSpin = [&s](QSpinBox *spin, const QString &key) {
        spin->setValue(s.value(key, spin->value()).toInt());
    };
    auto loadAdapter = [&s](QComboBox *combo, const QString &key) {
        const int idx = combo->findData(s.value(key).toString());
        if (idx >= 0)
            combo->setCurrentIndex(idx);
    };

    const QString port = s.value(QStringLiteral("serial/port")).toString();
    if (!port.isEmpty())
        ui->cmbPuerto->setCurrentText(port);
    ui->cmbBaudios->setCurrentText(
        s.value(QStringLiteral("serial/baud"), ui->cmbBaudios->currentText()).toString());
    loadIndex(ui->cmbBitsDatos, QStringLiteral("serial/dataBits"));
    loadIndex(ui->cmbParidad, QStringLiteral("serial/parity"));
    loadIndex(ui->cmbBitsParada, QStringLiteral("serial/stopBits"));
    loadIndex(ui->cmbFlujo, QStringLiteral("serial/flow"));

    loadText(ui->txtEthHost, QStringLiteral("eth/host"));
    loadSpin(ui->spnEthPuerto, QStringLiteral("eth/port"));
    loadSpin(ui->spnEthPuertoLocal, QStringLiteral("eth/localPort"));
    loadIndex(ui->cmbEthProtocolo, QStringLiteral("eth/protocol"));
    loadIndex(ui->cmbEthRol, QStringLiteral("eth/role"));
    loadAdapter(ui->cmbEthAdaptador, QStringLiteral("eth/adapter"));

    loadIndex(ui->cmbWifiModo, QStringLiteral("wifi/mode"));
    loadText(ui->txtWifiSsid, QStringLiteral("wifi/ssid"));
    loadText(ui->txtWifiHost, QStringLiteral("wifi/host"));
    loadSpin(ui->spnWifiPuerto, QStringLiteral("wifi/port"));
    loadSpin(ui->spnWifiPuertoLocal, QStringLiteral("wifi/localPort"));
    loadIndex(ui->cmbWifiProtocolo, QStringLiteral("wifi/protocol"));
    loadAdapter(ui->cmbWifiAdaptador, QStringLiteral("wifi/adapter"));

    loadIndex(ui->cmbFormato, QStringLiteral("dataFormat"));
    loadSpin(ui->spnTimeout, QStringLiteral("timeoutMs"));
    ui->chkReconectar->setChecked(
        s.value(QStringLiteral("autoReconnect"), ui->chkReconectar->isChecked()).toBool());
    s.endGroup();
}

void ConnectionPage::saveSettings() const
{
    QSettings s;
    s.beginGroup(QStringLiteral("connection"));
    s.setValue(QStringLiteral("interface"), m_ifaceGroup->checkedId());

    s.setValue(QStringLiteral("serial/port"), ui->cmbPuerto->currentText());
    s.setValue(QStringLiteral("serial/baud"), ui->cmbBaudios->currentText());
    s.setValue(QStringLiteral("serial/dataBits"), ui->cmbBitsDatos->currentIndex());
    s.setValue(QStringLiteral("serial/parity"), ui->cmbParidad->currentIndex());
    s.setValue(QStringLiteral("serial/stopBits"), ui->cmbBitsParada->currentIndex());
    s.setValue(QStringLiteral("serial/flow"), ui->cmbFlujo->currentIndex());

    s.setValue(QStringLiteral("eth/host"), ui->txtEthHost->text());
    s.setValue(QStringLiteral("eth/port"), ui->spnEthPuerto->value());
    s.setValue(QStringLiteral("eth/localPort"), ui->spnEthPuertoLocal->value());
    s.setValue(QStringLiteral("eth/protocol"), ui->cmbEthProtocolo->currentIndex());
    s.setValue(QStringLiteral("eth/role"), ui->cmbEthRol->currentIndex());
    s.setValue(QStringLiteral("eth/adapter"), ui->cmbEthAdaptador->currentData());

    s.setValue(QStringLiteral("wifi/mode"), ui->cmbWifiModo->currentIndex());
    s.setValue(QStringLiteral("wifi/ssid"), ui->txtWifiSsid->text());
    s.setValue(QStringLiteral("wifi/host"), ui->txtWifiHost->text());
    s.setValue(QStringLiteral("wifi/port"), ui->spnWifiPuerto->value());
    s.setValue(QStringLiteral("wifi/localPort"), ui->spnWifiPuertoLocal->value());
    s.setValue(QStringLiteral("wifi/protocol"), ui->cmbWifiProtocolo->currentIndex());
    s.setValue(QStringLiteral("wifi/adapter"), ui->cmbWifiAdaptador->currentData());

    s.setValue(QStringLiteral("dataFormat"), ui->cmbFormato->currentIndex());
    s.setValue(QStringLiteral("timeoutMs"), ui->spnTimeout->value());
    s.setValue(QStringLiteral("autoReconnect"), ui->chkReconectar->isChecked());
    s.endGroup();
}
