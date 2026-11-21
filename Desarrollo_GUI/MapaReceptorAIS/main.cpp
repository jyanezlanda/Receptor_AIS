#include "mainwindow.h"
#include "sshsession.h"

#include <QApplication>

int main(int argc, char *argv[])
{
    // Cuando ssh.exe pide la contrasena, vuelve a ejecutar este programa en
    // "modo askpass": responde y termina sin abrir ninguna ventana.
    if (SshSession::handleAskPass(argc, argv))
        return 0;

    QApplication a(argc, argv);
    QApplication::setOrganizationName(QStringLiteral("ALMA"));
    QApplication::setApplicationName(QStringLiteral("MapaReceptorAIS"));

    MainWindow w;
    w.show();
    return QApplication::exec();
}
