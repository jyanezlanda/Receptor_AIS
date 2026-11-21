#include "sshsession.h"

#include <QCoreApplication>
#include <QDir>
#include <QFileInfo>
#include <QProcessEnvironment>
#include <QStandardPaths>

#include <cstdio>

#ifdef Q_OS_WIN
#include <windows.h>
#endif

namespace {

// Variables de entorno del modo askpass (solo las ve el proceso ssh hijo).
const char kAskPassFlag[] = "MAPA_AIS_ASKPASS";
const char kAskPassSecret[] = "MAPA_AIS_ASKPASS_SECRET";

// Marcador para saber que el login termino y el shell remoto responde.
const QByteArray kReadyMarker = "__MAPA_AIS_SSH_LISTO__";

} // namespace

SshSession::SshSession(QObject *parent)
    : QObject(parent)
{
    m_loginTimeout.setSingleShot(true);
    connect(&m_loginTimeout, &QTimer::timeout, this, [this] {
        if (m_state != State::Connecting || !m_process)
            return;
        m_stderrLog += QStringLiteral("\n(tiempo de espera agotado)");
        m_process->kill();
    });
}

SshSession::~SshSession()
{
    if (m_process) {
        m_process->disconnect(this);
        m_process->kill();
        m_process->waitForFinished(1000);
    }
}

QString SshSession::sshExecutable()
{
#ifdef Q_OS_WIN
    // Preferir el OpenSSH de Windows; si no esta, el que haya en el PATH
    // (por ejemplo el de Git para Windows).
    const QString winSsh = QDir::fromNativeSeparators(qEnvironmentVariable("SystemRoot"))
                           + QStringLiteral("/System32/OpenSSH/ssh.exe");
    if (QFileInfo::exists(winSsh))
        return winSsh;
#endif
    return QStandardPaths::findExecutable(QStringLiteral("ssh"));
}

bool SshSession::handleAskPass(int argc, char *argv[])
{
    if (!qEnvironmentVariableIsSet(kAskPassFlag))
        return false;

    // ssh pasa el texto del pedido como primer argumento. Nunca se
    // confirma automaticamente una pregunta "yes/no" (clave de host).
    const QByteArray prompt = argc > 1 ? QByteArray(argv[1]) : QByteArray();
    QByteArray answer = prompt.contains("yes/no") ? QByteArray("no")
                                                  : qgetenv(kAskPassSecret);
    answer += '\n';
#ifdef Q_OS_WIN
    // La app es de subsistema grafico: se escribe directo al handle heredado.
    DWORD written = 0;
    WriteFile(GetStdHandle(STD_OUTPUT_HANDLE), answer.constData(), DWORD(answer.size()),
              &written, nullptr);
#else
    std::fwrite(answer.constData(), 1, size_t(answer.size()), stdout);
    std::fflush(stdout);
#endif
    return true;
}

QString SshSession::forgetHostKey(const QString &host, quint16 port)
{
    const QString ssh = sshExecutable();
    const QString keygen = QFileInfo(ssh).absolutePath() + QStringLiteral("/ssh-keygen")
#ifdef Q_OS_WIN
                           + QStringLiteral(".exe")
#endif
        ;
    const QString target = port == 22 ? host : QStringLiteral("[%1]:%2").arg(host).arg(port);
    QProcess p;
    p.start(keygen, {QStringLiteral("-R"), target});
    if (!p.waitForFinished(5000))
        return tr("No se pudo ejecutar ssh-keygen.");
    if (p.exitCode() != 0)
        return tr("No había una clave guardada para %1.").arg(target);
    return tr("Clave de %1 olvidada. En la próxima conexión se aceptará la nueva.").arg(target);
}

void SshSession::open(const Config &config)
{
    if (m_process)
        return;
    m_config = config;
    m_closing = false;
    m_pendingStdout.clear();
    m_stderrLog.clear();

    const QString ssh = sshExecutable();
    if (ssh.isEmpty()) {
        setState(State::Error, tr("No se encontró el cliente ssh. En Windows se instala desde "
                                  "Configuración → Sistema → Características opcionales → "
                                  "Cliente OpenSSH."));
        return;
    }

    QStringList args{
        QStringLiteral("-T"), // sin terminal: los comandos llegan por la entrada estandar
        QStringLiteral("-p"), QString::number(config.port),
        QStringLiteral("-o"), QStringLiteral("ConnectTimeout=%1").arg(config.timeoutSec),
        QStringLiteral("-o"), QStringLiteral("ServerAliveInterval=15"),
        QStringLiteral("-o"), QStringLiteral("ServerAliveCountMax=3"),
        QStringLiteral("-o"), QStringLiteral("NumberOfPasswordPrompts=1"),
        QStringLiteral("-o"), config.acceptNewHostKey ? QStringLiteral("StrictHostKeyChecking=accept-new")
                                                      : QStringLiteral("StrictHostKeyChecking=yes"),
    };
    if (config.useKey) {
        args << QStringLiteral("-i") << QDir::toNativeSeparators(config.keyFile)
             << QStringLiteral("-o") << QStringLiteral("IdentitiesOnly=yes")
             << QStringLiteral("-o") << QStringLiteral("PreferredAuthentications=publickey");
        if (config.password.isEmpty())
            args << QStringLiteral("-o") << QStringLiteral("BatchMode=yes");
    } else {
        args << QStringLiteral("-o") << QStringLiteral("PubkeyAuthentication=no")
             << QStringLiteral("-o")
             << QStringLiteral("PreferredAuthentications=password,keyboard-interactive");
    }
    args << QStringLiteral("%1@%2").arg(config.user, config.host);

    QProcessEnvironment env = QProcessEnvironment::systemEnvironment();
    env.insert(QStringLiteral("SSH_ASKPASS"),
               QDir::toNativeSeparators(QCoreApplication::applicationFilePath()));
    env.insert(QStringLiteral("SSH_ASKPASS_REQUIRE"), QStringLiteral("force"));
    env.insert(QStringLiteral("DISPLAY"), QStringLiteral(":0")); // requerido por versiones viejas
    env.insert(QString::fromLatin1(kAskPassFlag), QStringLiteral("1"));
    env.insert(QString::fromLatin1(kAskPassSecret), config.password);

    m_process = new QProcess(this);
    m_process->setProcessEnvironment(env);
    connect(m_process, &QProcess::readyReadStandardOutput, this, &SshSession::onReadyReadStdout);
    connect(m_process, &QProcess::readyReadStandardError, this, &SshSession::onReadyReadStderr);
    connect(m_process, &QProcess::finished, this, [this](int code) { onFinished(code); });
    connect(m_process, &QProcess::errorOccurred, this, [this](QProcess::ProcessError e) {
        if (e == QProcess::FailedToStart) {
            m_stderrLog += tr("No se pudo ejecutar %1").arg(m_process->program());
            onFinished(-1);
        }
    });

    setState(State::Connecting,
             tr("Conectando a %1@%2:%3…").arg(config.user, config.host).arg(config.port));
    m_loginTimeout.start((config.timeoutSec + 10) * 1000);
    m_process->start(ssh, args);
    // Se ejecuta apenas el login termina; su eco confirma la conexion.
    m_process->write("echo " + kReadyMarker + "\n");
}

void SshSession::close()
{
    if (!m_process)
        return;
    m_closing = true;
    m_process->write("exit\n");
    m_process->closeWriteChannel();
    // Si no termina solo, se fuerza el cierre.
    QTimer::singleShot(1500, this, [this] {
        if (m_process && m_closing)
            m_process->kill();
    });
}

bool SshSession::sendCommand(const QString &command)
{
    if (m_state != State::Connected || !m_process)
        return false;
    m_process->write(command.toUtf8() + '\n');
    return true;
}

void SshSession::onReadyReadStdout()
{
    const QByteArray data = m_process->readAllStandardOutput();
    if (m_state == State::Connected) {
        emit outputReceived(QString::fromUtf8(data));
        return;
    }
    // Todavia no se vio el marcador: se acumula hasta encontrarlo.
    m_pendingStdout += data;
    const int idx = m_pendingStdout.indexOf(kReadyMarker);
    if (idx < 0)
        return;
    m_loginTimeout.stop();
    QByteArray rest = m_pendingStdout.mid(idx + kReadyMarker.size());
    if (rest.startsWith("\r\n"))
        rest.remove(0, 2);
    else if (rest.startsWith('\n'))
        rest.remove(0, 1);
    const QByteArray before = m_pendingStdout.left(idx); // p. ej. mensaje de bienvenida
    m_pendingStdout.clear();
    setState(State::Connected, tr("Sesión abierta en %1@%2").arg(m_config.user, m_config.host));
    if (!before.isEmpty())
        emit outputReceived(QString::fromUtf8(before));
    if (!rest.isEmpty())
        emit outputReceived(QString::fromUtf8(rest));
}

void SshSession::onReadyReadStderr()
{
    const QString text = QString::fromUtf8(m_process->readAllStandardError());
    m_stderrLog += text;
    if (m_stderrLog.size() > 8000)
        m_stderrLog = m_stderrLog.right(4000);
    emit errorOutputReceived(text);
}

void SshSession::onFinished(int exitCode)
{
    if (!m_process)
        return;
    m_loginTimeout.stop();
    const bool wasConnected = m_state == State::Connected;
    m_process->disconnect(this);
    m_process->deleteLater();
    m_process = nullptr;

    if (m_closing || (wasConnected && exitCode == 0))
        setState(State::Disconnected, tr("Sesión SSH cerrada"));
    else
        setState(State::Error, describeFailure(exitCode));
    m_closing = false;
}

QString SshSession::describeFailure(int exitCode) const
{
    const QString log = m_stderrLog;
    const QString target = QStringLiteral("%1:%2").arg(m_config.host).arg(m_config.port);
    if (log.contains(QLatin1String("REMOTE HOST IDENTIFICATION HAS CHANGED"))
        || log.contains(QLatin1String("Host key verification failed")))
        return tr("La clave del host %1 no coincide con la guardada (¿se reinstaló la Red Pitaya?). "
                  "Usá «Olvidar clave del host» y volvé a conectar.").arg(m_config.host);
    if (log.contains(QLatin1String("Permission denied")))
        return m_config.useKey ? tr("Acceso denegado: la clave privada no fue aceptada.")
                               : tr("Acceso denegado: usuario o contraseña incorrectos.");
    if (log.contains(QLatin1String("Connection refused")))
        return tr("%1 rechazó la conexión: ¿está corriendo el servidor SSH?").arg(target);
    if (log.contains(QLatin1String("timed out")) || log.contains(QLatin1String("tiempo de espera")))
        return tr("Sin respuesta de %1: revisá el cable Ethernet y la dirección IP.").arg(target);
    if (log.contains(QLatin1String("Could not resolve hostname")))
        return tr("No se pudo resolver el nombre «%1».").arg(m_config.host);
    if (log.contains(QLatin1String("No route to host"))
        || log.contains(QLatin1String("Network is unreachable")))
        return tr("No hay ruta hacia %1: revisá la red y la IP de la PC.").arg(m_config.host);
    if (log.contains(QLatin1String("No such file")) && m_config.useKey)
        return tr("No se encontró el archivo de clave privada.");

    // Ultima linea con contenido de la salida de error
    const QStringList lines = log.split(QLatin1Char('\n'), Qt::SkipEmptyParts);
    for (auto it = lines.crbegin(); it != lines.crend(); ++it) {
        const QString l = it->trimmed();
        if (!l.isEmpty())
            return l;
    }
    return tr("ssh terminó con código %1").arg(exitCode);
}

void SshSession::setState(State state, const QString &message)
{
    m_state = state;
    emit stateChanged(state, message);
}
