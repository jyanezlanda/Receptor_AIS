#ifndef MAPPAGE_H
#define MAPPAGE_H

#include <QWidget>

QT_BEGIN_NAMESPACE
namespace Ui {
class MapPage;
}
QT_END_NAMESPACE

class MapWidget;
class QSortFilterProxyModel;
class VesselModel;

/*
 * Pestana principal: mapa + lista de buques + detalle del seleccionado.
 * Diseno en mappage.ui.
 */
class MapPage : public QWidget
{
    Q_OBJECT

public:
    explicit MapPage(QWidget *parent = nullptr);
    ~MapPage() override;

    void setModel(VesselModel *model);
    MapWidget *map() const;

    QByteArray saveState() const;
    void restoreState(const QByteArray &state);

public slots:
    void selectVessel(quint32 mmsi);
    void setSimulationRunning(bool running);

signals:
    void simulationToggled(bool enabled);

private slots:
    void on_btnSimulacion_clicked();

private:
    void onTableSelectionChanged();
    void onVesselUpdated(quint32 mmsi);
    void clearVessels();

    Ui::MapPage *ui;
    VesselModel *m_model = nullptr;
    QSortFilterProxyModel *m_proxy = nullptr;
    bool m_syncingSelection = false;
};

#endif // MAPPAGE_H
