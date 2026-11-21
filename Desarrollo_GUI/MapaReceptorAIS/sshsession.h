#ifndef SSHSESSION_H
#define SSHSESSION_H

#include <QObject>
#include <QProcess>
#include <QTimer>

/*
 * Sesion SSH con la Red Pitaya usando el cliente OpenSSH del sistema
 * (ssh.exe, incluido en Windows 10/11) a traves de QProcess.
 *
 * - Se abre una sesion sin terminal (ssh -T): cada linea escrita en la
 *   entrada estandar se ejecuta como un comando del shell remoto.
 * - La contrasena se entrega con el mecanismo estandar SSH_ASKPASS:
 *   ssh.exe vuelve a ejecutar esta misma aplicacion en "modo askpass"
 *   (ver handleAskPass(), llamado al principio de main()).
 *   La contrasena nunca se guarda en disco.
 */
class SshSession : public QObject
{
    Q_OBJECT

public:
    struct Config
    {
        QString host = QStringLiteral("192.168.1.100");
        quint16 port = 22;
        QString user = QStringLiteral("root");
        bool useKey = false;     // false: contrasena, true: clave privada
        QString password;        // contrasena, o frase de la clave privada
        QString keyFile;
        bool acceptNewHostKey = true;
        int timeoutSec = 10;
    };

    enum class State { Disconnected, Connecting, Connected, Error };
    Q_ENUM(State)

    explicit SshSession(QObject *parent = nullptr);
    ~SshSession() override;

    State state() const { return m_state; }
    const Config &config() const { return m_config; }

    // Ruta del cliente ssh a usar (vacia si no se encontro).
    static QString sshExecutable();

    // Si el proceso fue lanzado por ssh.exe como askpass, responde y
    // devuelve true: main() debe terminar sin abrir la interfaz.
    static bool handleAskPass(int argc, char *argv[]);

    // Borra la clave guardada de un host (ssh-keygen -R), util cuando se
    // reinstala la Red Pitaya y cambia su clave. Devuelve un mensaje.
    static QString forgetHostKey(const QString &host, quint16 port);

public slots:
    void open(const Config &config);
    void close();
    bool sendCommand(const QString &command);

signals:
    void stateChanged(SshSession::State state, const QString &message);
    void outputReceived(const QString &text);      // salida estandar remota
    void errorOutputReceived(const QString &text); // errores y avisos

private:
    void onReadyReadStdout();
    void onReadyReadStderr();
    void onFinished(int exitCode);
    QString describeFailure(int exitCode) const;
    void setState(State state, const QString &message);

    Config m_config;
    State m_state = State::Disconnected;
    QProcess *m_process = nullptr;
    QTimer m_loginTimeout;
    QByteArray m_pendingStdout; // hasta detectar el marcador de inicio
    QString m_stderrLog;
    bool m_closing = false;
};

#endif // SSHSESSION_H
