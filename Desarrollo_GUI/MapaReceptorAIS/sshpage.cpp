#include "sshpage.h"
#include "ui_sshpage.h"

#include "connectionmanager.h" // colores de estado compartidos

#include <QFileDialog>
#include <QFontDatabase>
#include <QKeyEvent>
#include <QMessageBox>
#include <QScrollBar>
#include <QSettings>
#include <QStandardPaths>
#include <QTextBlock>
#include <QTextCursor>

namespace {

// Colores de la consola
const QColor kColorCommand(0x4f, 0xa3, 0xe0); // comandos enviados
const QColor kColorError(0xe0, 0x6c, 0x5c);   // salida de error de ssh / remota
const QColor kColorInfo(0x9a, 0x9a, 0x9a);    // mensajes de la aplicacion

// Mismos colores de indicador que la pestana Conexion
QString ledColor(SshSession::State s)
{
    using CS = ConnectionManager::State;
    switch (s) {
    case SshSession::State::Disconnected: return ConnectionManager::stateColor(CS::Disconnected);
    case SshSession::State::Connecting:   return ConnectionManager::stateColor(CS::Connecting);
    case SshSession::State::Connected:    return ConnectionManager::stateColor(CS::Connected);
    case SshSession::State::Error:        return ConnectionManager::stateColor(CS::Error);
    }
    return {};
}

QString stateTitle(SshSession::State s)
{
    switch (s) {
    case SshSession::State::Disconnected: return QObject::tr("Desconectado");
    case SshSession::State::Connecting:   return QObject::tr("Conectando…");
    case SshSession::State::Connected:    return QObject::tr("Conectado");
    case SshSession::State::Error:        return QObject::tr("Error");
    }
    return {};
}

} // namespace

SshPage::SshPage(QWidget *parent)
    : QWidget(parent)
    , ui(new Ui::SshPage)
    , m_session(new SshSession(this))
{
    ui->setupUi(this);

    ui->splitter->setStretchFactor(0, 0);
    ui->splitter->setStretchFactor(1, 1);
    ui->splitter->setSizes({540, 700});
    ui->txtConsola->setFont(QFontDatabase::systemFont(QFontDatabase::FixedFont));
    ui->lblSshAyuda->setForegroundRole(QPalette::PlaceholderText);
    ui->lblComandosAyuda->setForegroundRole(QPalette::PlaceholderText);
    ui->txtComando->installEventFilter(this);

    connect(ui->cmbAuth, &QComboBox::currentIndexChanged, this, &SshPage::updateAuthFields);
    connect(ui->btnExaminar, &QPushButton::clicked, this, [this] {
        const QString dir = ui->txtClave->text().isEmpty()
                                ? QStandardPaths::writableLocation(QStandardPaths::HomeLocation)
                                      + QStringLiteral("/.ssh")
                                : ui->txtClave->text();
        const QString file = QFileDialog::getOpenFileName(this, tr("Clave privada"), dir);
        if (!file.isEmpty())
            ui->txtClave->setText(QDir::toNativeSeparators(file));
    });
    connect(ui->btnConectar, &QPushButton::clicked, this, &SshPage::onConnectClicked);
    connect(ui->txtPassword, &QLineEdit::returnPressed, this, &SshPage::onConnectClicked);
    connect(ui->btnOlvidarHost, &QPushButton::clicked, this, [this] {
        const QString msg = SshSession::forgetHostKey(ui->txtHost->text().trimmed(),
                                                      quint16(ui->spnPuerto->value()));
        appendConsole(msg, kColorInfo, true);
        ui->lblEstadoDetalle->setText(msg);
        ui->lblEstadoDetalle->setVisible(true);
    });

    // Consola
    connect(ui->btnEnviar, &QPushButton::clicked, this, &SshPage::sendTypedCommand);
    connect(ui->txtComando, &QLineEdit::returnPressed, this, &SshPage::sendTypedCommand);
    connect(ui->btnLimpiarConsola, &QPushButton::clicked, ui->txtConsola, &QPlainTextEdit::clear);

    // Comandos rapidos: cada boton ejecuta el texto de su campo
    const QList<QPair<QPushButton *, QLineEdit *>> quick = {
        {ui->btnIniciar, ui->txtCmdIniciar},
        {ui->btnDetener, ui->txtCmdDetener},
        {ui->btnEstadoRp, ui->txtCmdEstado},
        {ui->btnLog, ui->txtCmdLog},
        {ui->btnSimIniciar, ui->txtCmdSimIniciar},
        {ui->btnSimDetener, ui->txtCmdSimDetener},
    };
    for (const auto &q : quick) {
        QLineEdit *edit = q.second;
        connect(q.first, &QPushButton::clicked, this, [this, edit] { runCommand(edit->text()); });
    }
    connect(ui->btnReiniciar, &QPushButton::clicked, this, [this] {
        if (QMessageBox::question(this, tr("Reiniciar Red Pitaya"),
                                  tr("¿Reiniciar la Red Pitaya? Se cortarán todas las conexiones."))
            == QMessageBox::Yes)
            runCommand(ui->txtCmdReiniciar->text());
    });
    connect(ui->btnApagar, &QPushButton::clicked, this, [this] {
        if (QMessageBox::question(this, tr("Apagar Red Pitaya"),
                                  tr("¿Apagar la Red Pitaya?\n\nEsperá unos 15 segundos a que el LED deje "
                                     "de parpadear antes de desenchufar la alimentación."))
            == QMessageBox::Yes)
            runCommand(ui->txtCmdApagar->text());
    });

    // Sesion
    connect(m_session, &SshSession::stateChanged, this, &SshPage::onStateChanged);
    connect(m_session, &SshSession::outputReceived, this,
            [this](const QString &text) { appendConsole(text, palette().color(QPalette::Text)); });
    connect(m_session, &SshSession::errorOutputReceived, this,
            [this](const QString &text) { appendConsole(text, kColorError); });

    loadSettings();
    updateAuthFields();
    onStateChanged(SshSession::State::Disconnected, QString());
}

SshPage::~SshPage()
{
    delete ui;
}

SshSession::Config SshPage::currentConfig() const
{
    SshSession::Config c;
    c.host = ui->txtHost->text().trimmed();
    c.port = quint16(ui->spnPuerto->value());
    c.user = ui->txtUsuario->text().trimmed();
    c.useKey = ui->cmbAuth->currentIndex() == 1; // 0: contrasena, 1: clave privada
    c.password = ui->txtPassword->text();
    c.keyFile = ui->txtClave->text().trimmed();
    c.acceptNewHostKey = ui->chkAceptarHost->isChecked();
    c.timeoutSec = ui->spnTimeout->value();
    return c;
}

void SshPage::updateAuthFields()
{
    const bool useKey = ui->cmbAuth->currentIndex() == 1;
    ui->txtClave->setEnabled(useKey);
    ui->btnExaminar->setEnabled(useKey);
    // Con clave privada, el campo de contrasena sirve para su frase (opcional).
    ui->lblPassword->setText(useKey ? tr("Frase de la clave:") : tr("Contraseña:"));
    ui->txtPassword->setPlaceholderText(useKey ? tr("Solo si la clave está protegida")
                                               : tr("Contraseña del usuario"));
}

void SshPage::onConnectClicked()
{
    const auto state = m_session->state();
    if (state == SshSession::State::Connected || state == SshSession::State::Connecting) {
        m_session->close();
        return;
    }
    const SshSession::Config cfg = currentConfig();
    QString problem;
    if (cfg.host.isEmpty())
        problem = tr("Ingresá la IP de la Red Pitaya.");
    else if (cfg.user.isEmpty())
        problem = tr("Ingresá el usuario.");
    else if (cfg.useKey && cfg.keyFile.isEmpty())
        problem = tr("Elegí el archivo de clave privada.");
    if (!problem.isEmpty()) {
        onStateChanged(SshSession::State::Error, problem);
        return;
    }
    saveSettings();
    m_session->open(cfg);
}

void SshPage::onStateChanged(SshSession::State state, const QString &message)
{
    ui->lblLed->setStyleSheet(
        QStringLiteral("background:%1; border-radius:8px; border:1px solid rgba(0,0,0,80);")
            .arg(ledColor(state)));
    ui->lblEstado->setText(stateTitle(state));
    ui->lblEstadoDetalle->setText(message);
    ui->lblEstadoDetalle->setVisible(!message.isEmpty());

    const bool idle = state == SshSession::State::Disconnected || state == SshSession::State::Error;
    const bool connected = state == SshSession::State::Connected;
    ui->btnConectar->setText(idle ? tr("Conectar") : tr("Desconectar"));
    ui->configArea->setEnabled(idle);
    ui->btnOlvidarHost->setEnabled(idle);
    const QList<QWidget *> needSession = {ui->btnIniciar, ui->btnDetener, ui->btnEstadoRp,
                                          ui->btnLog, ui->btnSimIniciar, ui->btnSimDetener,
                                          ui->btnReiniciar, ui->btnApagar, ui->txtComando,
                                          ui->btnEnviar};
    for (QWidget *w : needSession)
        w->setEnabled(connected);

    if (!message.isEmpty())
        appendConsole(QStringLiteral("── %1 ──").arg(message),
                      state == SshSession::State::Error ? kColorError : kColorInfo, true);
    if (connected)
        ui->txtComando->setFocus();
}

void SshPage::runCommand(const QString &command)
{
    const QString cmd = command.trimmed();
    if (cmd.isEmpty())
        return;
    appendConsole(QStringLiteral("$ %1").arg(cmd), kColorCommand, true);
    m_session->sendCommand(cmd);
}

void SshPage::sendTypedCommand()
{
    const QString cmd = ui->txtComando->text().trimmed();
    if (cmd.isEmpty())
        return;
    if (m_history.isEmpty() || m_history.constLast() != cmd)
        m_history.append(cmd);
    if (m_history.size() > 100)
        m_history.removeFirst();
    m_historyPos = int(m_history.size());
    ui->txtComando->clear();
    runCommand(cmd);
}

bool SshPage::eventFilter(QObject *watched, QEvent *event)
{
    // Historial de comandos con las flechas arriba/abajo
    if (watched == ui->txtComando && event->type() == QEvent::KeyPress && !m_history.isEmpty()) {
        const int key = static_cast<QKeyEvent *>(event)->key();
        if (key == Qt::Key_Up || key == Qt::Key_Down) {
            m_historyPos = qBound(0, m_historyPos + (key == Qt::Key_Up ? -1 : 1),
                                  int(m_history.size()));
            ui->txtComando->setText(m_historyPos < m_history.size() ? m_history.at(m_historyPos)
                                                                    : QString());
            return true;
        }
    }
    return QWidget::eventFilter(watched, event);
}

void SshPage::appendConsole(const QString &text, const QColor &color, bool ownLine)
{
    QPlainTextEdit *console = ui->txtConsola;
    QScrollBar *bar = console->verticalScrollBar();
    const bool atBottom = bar->value() >= bar->maximum() - 4;

    QTextCursor cursor(console->document());
    cursor.movePosition(QTextCursor::End);
    // Los mensajes propios empiezan en una linea nueva
    if (ownLine && !console->document()->isEmpty()
        && !console->document()->lastBlock().text().isEmpty())
        cursor.insertText(QStringLiteral("\n"));
    QTextCharFormat fmt;
    fmt.setForeground(color);
    QString clean = text;
    clean.remove(QLatin1Char('\r'));
    if (ownLine && !clean.endsWith(QLatin1Char('\n')))
        clean += QLatin1Char('\n'); // y terminan en su propia linea
    cursor.insertText(clean, fmt);

    if (atBottom)
        bar->setValue(bar->maximum());
}

// ---------------------------------------------------------------------------
// Persistencia (la contrasena NO se guarda)
// ---------------------------------------------------------------------------

void SshPage::loadSettings()
{
    QSettings s;
    s.beginGroup(QStringLiteral("ssh"));
    auto loadText = [&s](QLineEdit *edit, const QString &key) {
        edit->setText(s.value(key, edit->text()).toString());
    };
    loadText(ui->txtHost, QStringLiteral("host"));
    ui->spnPuerto->setValue(s.value(QStringLiteral("port"), ui->spnPuerto->value()).toInt());
    loadText(ui->txtUsuario, QStringLiteral("user"));
    ui->cmbAuth->setCurrentIndex(
        qBound(0, s.value(QStringLiteral("auth"), ui->cmbAuth->currentIndex()).toInt(),
               ui->cmbAuth->count() - 1));
    loadText(ui->txtClave, QStringLiteral("keyFile"));
    ui->spnTimeout->setValue(s.value(QStringLiteral("timeoutSec"), ui->spnTimeout->value()).toInt());
    ui->chkAceptarHost->setChecked(
        s.value(QStringLiteral("acceptNewHostKey"), ui->chkAceptarHost->isChecked()).toBool());
    // Grupo "comandos_v3": los comandos guardados de la version vieja (loopback_server, en
    // "cmd/") se ignoran para que se usen los nuevos valores por defecto del .ui.
    s.remove(QStringLiteral("cmd"));
    loadText(ui->txtCmdIniciar, QStringLiteral("comandos_v3/start"));
    loadText(ui->txtCmdDetener, QStringLiteral("comandos_v3/stop"));
    loadText(ui->txtCmdEstado, QStringLiteral("comandos_v3/status"));
    loadText(ui->txtCmdLog, QStringLiteral("comandos_v3/log"));
    loadText(ui->txtCmdSimIniciar, QStringLiteral("comandos_v3/simStart"));
    loadText(ui->txtCmdSimDetener, QStringLiteral("comandos_v3/simStop"));
    loadText(ui->txtCmdReiniciar, QStringLiteral("comandos_v3/reboot"));
    loadText(ui->txtCmdApagar, QStringLiteral("comandos_v3/poweroff"));
    s.endGroup();
}

void SshPage::saveSettings() const
{
    QSettings s;
    s.beginGroup(QStringLiteral("ssh"));
    s.setValue(QStringLiteral("host"), ui->txtHost->text());
    s.setValue(QStringLiteral("port"), ui->spnPuerto->value());
    s.setValue(QStringLiteral("user"), ui->txtUsuario->text());
    s.setValue(QStringLiteral("auth"), ui->cmbAuth->currentIndex());
    s.setValue(QStringLiteral("keyFile"), ui->txtClave->text());
    s.setValue(QStringLiteral("timeoutSec"), ui->spnTimeout->value());
    s.setValue(QStringLiteral("acceptNewHostKey"), ui->chkAceptarHost->isChecked());
    s.setValue(QStringLiteral("comandos_v3/start"), ui->txtCmdIniciar->text());
    s.setValue(QStringLiteral("comandos_v3/stop"), ui->txtCmdDetener->text());
    s.setValue(QStringLiteral("comandos_v3/status"), ui->txtCmdEstado->text());
    s.setValue(QStringLiteral("comandos_v3/log"), ui->txtCmdLog->text());
    s.setValue(QStringLiteral("comandos_v3/simStart"), ui->txtCmdSimIniciar->text());
    s.setValue(QStringLiteral("comandos_v3/simStop"), ui->txtCmdSimDetener->text());
    s.setValue(QStringLiteral("comandos_v3/reboot"), ui->txtCmdReiniciar->text());
    s.setValue(QStringLiteral("comandos_v3/poweroff"), ui->txtCmdApagar->text());
    s.endGroup();
}
