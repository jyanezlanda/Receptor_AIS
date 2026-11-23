#ifndef MAINWINDOW_H
#define MAINWINDOW_H

#include "adrflink.h"
#include "connectionmanager.h"

#include <QElapsedTimer>
#include <QMainWindow>

QT_BEGIN_NAMESPACE
namespace Ui {
class MainWindow;
}
QT_END_NAMESPACE

class AisDecoder;
class DemoSimulator;
class QLabel;
class ReceiverPage;
class SessionLogger;
class VesselModel;

/*
 * Ventana principal. El diseno (pestanas, menus, textos) esta en
 * mainwindow.ui; aca solo se conectan los modelos y la logica.
 */
class MainWindow : public QMainWindow
{
    Q_OBJECT

public:
    explicit MainWindow(QWidget *parent = nullptr);
    ~MainWindow() override;

protected:
    void closeEvent(QCloseEvent *event) override;

private:
    void createStatusBar();
    void onConnectionStateChanged(ConnectionManager::State state, const QString &message);
    void onRawDataReceived(const QByteArray &data);
    void updateDecoderStatus();
    void onReceiverStatus(quint32 level, bool squelchOpen, quint32 fifoWords);
    void onAgcStatus(const AgcStatus &status);
    void onAgcLink(bool linked, const QString &message);
    void onLoggingRequested(bool on, const QString &folder);

    Ui::MainWindow *ui;

    VesselModel *m_model = nullptr;
    ConnectionManager *m_connection = nullptr;
    DemoSimulator *m_simulator = nullptr;
    AisDecoder *m_decoder = nullptr;
    AdrfLink *m_adrf = nullptr;
    ReceiverPage *m_receiverPage = nullptr;
    SessionLogger *m_logger = nullptr;

    QLabel *m_statusConnection = nullptr;
    QLabel *m_statusVessels = nullptr;
    QLabel *m_statusAis = nullptr;
    QLabel *m_statusRx = nullptr;
    QLabel *m_statusReceiver = nullptr;
    QLabel *m_statusAgc = nullptr;
    QElapsedTimer m_receiverStatusTimer;
};

#endif // MAINWINDOW_H
