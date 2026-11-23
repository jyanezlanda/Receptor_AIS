#ifndef CONNECTIONPAGE_H
#define CONNECTIONPAGE_H

#include "connectionmanager.h"

#include <QWidget>

QT_BEGIN_NAMESPACE
namespace Ui {
class ConnectionPage;
}
QT_END_NAMESPACE

class QButtonGroup;
class QTcpSocket;

/*
 * Pestana de configuracion del enlace con la Red Pitaya:
 * interfaz serie, Ethernet o WiFi, mas un monitor de los datos crudos.
 * Diseno en connectionpage.ui.
 */
class ConnectionPage : public QWidget
{
    Q_OBJECT

public:
    explicit ConnectionPage(QWidget *parent = nullptr);
    ~ConnectionPage() override;

    void setManager(ConnectionManager *manager);
    ConnectionConfig currentConfig() const;
    void loadSettings();
    void saveSettings() const;

private:
    void onInterfaceChanged(int id);
    void refreshSerialPorts();
    void refreshAdapters();
    void updateSerialPortInfo();
    void updateNetworkFieldStates();
    void onFormatChanged();
    void onConnectClicked();
    void onTestClicked();
    void onStateChanged(ConnectionManager::State state, const QString &message);
    void onDataReceived(const QByteArray &data);
    void setStatus(const QString &color, const QString &title, const QString &detail);

    Ui::ConnectionPage *ui;
    ConnectionManager *m_manager = nullptr;
    QButtonGroup *m_ifaceGroup = nullptr;
    QList<QWidget *> m_pages; // serie, Ethernet, WiFi (mismo orden que Interface)
    QTcpSocket *m_testSocket = nullptr;

    quint64 m_rxTotal = 0;
    quint64 m_rxWindow = 0;
};

#endif // CONNECTIONPAGE_H
