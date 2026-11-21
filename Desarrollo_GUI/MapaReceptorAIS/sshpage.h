#ifndef SSHPAGE_H
#define SSHPAGE_H

#include "sshsession.h"

#include <QWidget>

QT_BEGIN_NAMESPACE
namespace Ui {
class SshPage;
}
QT_END_NAMESPACE

class QColor;

/*
 * Pestana SSH: acceso a la consola de la Red Pitaya por Ethernet,
 * con comandos rapidos para iniciar/detener el receptor.
 * Diseno en sshpage.ui.
 */
class SshPage : public QWidget
{
    Q_OBJECT

public:
    explicit SshPage(QWidget *parent = nullptr);
    ~SshPage() override;

    void loadSettings();
    void saveSettings() const;

protected:
    bool eventFilter(QObject *watched, QEvent *event) override;

private:
    SshSession::Config currentConfig() const;
    void updateAuthFields();
    void onConnectClicked();
    void onStateChanged(SshSession::State state, const QString &message);
    void runCommand(const QString &command);
    void sendTypedCommand();
    void appendConsole(const QString &text, const QColor &color, bool ownLine = false);

    Ui::SshPage *ui;
    SshSession *m_session = nullptr;
    QStringList m_history;
    int m_historyPos = 0;
};

#endif // SSHPAGE_H
