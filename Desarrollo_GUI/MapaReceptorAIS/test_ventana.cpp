// Abre la ventana principal sin pantalla (QT_QPA_PLATFORM=offscreen), conecta en modo Receptor a un servidor de datos y guarda capturas.
// Uso:  test_ventana HOST SEGUNDOS CARPETA_DE_CAPTURAS
#include "connectionpage.h"
#include "mainwindow.h"

#include <QApplication>
#include <QComboBox>
#include <QDir>
#include <QLabel>
#include <QLineEdit>
#include <QPushButton>
#include <QSpinBox>
#include <QStatusBar>
#include <QTabWidget>
#include <QTableView>
#include <QTimer>
#include <cstdio>

int main(int argc, char *argv[])
{
    QApplication app(argc, argv);
    QApplication::setOrganizationName(QStringLiteral("ALMA_PRUEBA"));
    QApplication::setApplicationName(QStringLiteral("MapaReceptorAIS_prueba"));
    if (argc < 4)
        return 2;
    MainWindow w;
    w.resize(1500, 1000);
    w.show();
    auto *tabs = w.findChild<QTabWidget *>(QStringLiteral("tabs"));
    auto *format = w.findChild<QComboBox *>(QStringLiteral("cmbFormato"));
    auto *port = w.findChild<QSpinBox *>(QStringLiteral("spnEthPuerto"));
    auto *host = w.findChild<QLineEdit *>(QStringLiteral("txtEthHost"));
    auto *proto = w.findChild<QComboBox *>(QStringLiteral("cmbEthProtocolo"));
    auto *role = w.findChild<QComboBox *>(QStringLiteral("cmbEthRol"));
    auto *page = w.findChild<ConnectionPage *>(); // la pestana SSH tambien tiene un btnConectar
    auto *connect = page->findChild<QPushButton *>(QStringLiteral("btnConectar"));
    std::printf("formato: '%s' | puerto al abrir: %d | protocolo y rol habilitados: %d %d | host habilitado: %d\n", qPrintable(format->currentText()), port->value(),
                proto->isEnabled(), role->isEnabled(), host->isEnabled());
    host->setText(QString::fromLocal8Bit(argv[1]));
    tabs->setCurrentIndex(1);
    const QString dir = QString::fromLocal8Bit(argv[3]);
    QTimer::singleShot(300, [&] { connect->click(); });
    QTimer::singleShot(int(QString::fromLocal8Bit(argv[2]).toDouble() * 1000) - 200, [&] {
        w.grab().save(dir + QStringLiteral("/conexion.png"));
        tabs->setCurrentIndex(0);
        QTimer::singleShot(150, [&] {
            w.grab().save(dir + QStringLiteral("/mapa.png"));
            auto *table = w.findChild<QTableView *>(QStringLiteral("vesselTable"));
            std::printf("filas en la tabla de buques: %d\n", table->model()->rowCount());
            const auto labels = w.statusBar()->findChildren<QLabel *>();
            for (QLabel *l : labels)
                if (!l->text().isEmpty()) std::printf("barra de estado: %s\n", qPrintable(l->text()));
            QApplication::quit();
        });
    });
    return QApplication::exec();
}
