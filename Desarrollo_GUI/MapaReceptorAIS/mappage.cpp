#include "mappage.h"
#include "ui_mappage.h"

#include "aistypes.h"
#include "mapwidget.h"
#include "vesseldetailpanel.h"
#include "vesselmodel.h"

#include <QHeaderView>
#include <QItemSelectionModel>
#include <QMessageBox>
#include <QSortFilterProxyModel>

namespace {

// Vista inicial del mapa
constexpr double kHomeLat = -34.75;
constexpr double kHomeLon = -57.75;
constexpr int kHomeZoom = 10;

// Leyenda de colores por tipo de buque (los colores salen de aistypes.cpp).
QString legendHtml()
{
    using Ais::ShipCategory;
    const ShipCategory cats[] = {ShipCategory::Cargo,      ShipCategory::Tanker,
                                 ShipCategory::Passenger,  ShipCategory::Fishing,
                                 ShipCategory::TugSpecial, ShipCategory::HighSpeed,
                                 ShipCategory::Pleasure,   ShipCategory::Other,
                                 ShipCategory::Unknown};
    QStringList items;
    for (ShipCategory c : cats) {
        items << QStringLiteral("<span style='color:%1; font-size:15px'>&#9632;</span>&nbsp;%2")
                     .arg(Ais::categoryColor(c).name(), Ais::categoryName(c));
    }
    return items.join(QStringLiteral("&nbsp;&nbsp; "));
}

} // namespace

MapPage::MapPage(QWidget *parent)
    : QWidget(parent)
    , ui(new Ui::MapPage)
{
    ui->setupUi(this);

    ui->legendLabel->setText(legendHtml());
    ui->splitter->setStretchFactor(0, 3);
    ui->splitter->setStretchFactor(1, 1);
    ui->splitter->setSizes({880, 500});
    ui->map->setCenter(kHomeLat, kHomeLon);
    ui->map->setZoom(kHomeZoom);

    // Botones de la barra superior
    connect(ui->btnCentrar, &QToolButton::clicked, this, [this] {
        if (ui->detailPanel->currentMmsi())
            ui->map->centerOnVessel(ui->detailPanel->currentMmsi());
    });
    connect(ui->btnVerTodos, &QToolButton::clicked, ui->map, &MapWidget::fitAllVessels);
    connect(ui->btnInicio, &QToolButton::clicked, this, [this] {
        ui->map->setZoom(kHomeZoom);
        ui->map->setCenter(kHomeLat, kHomeLon);
    });
    connect(ui->btnEtiquetas, &QToolButton::toggled, ui->map, &MapWidget::setShowLabels);
    connect(ui->btnTrayectorias, &QToolButton::toggled, ui->map, &MapWidget::setShowTracks);
    connect(ui->btnSimulacion, &QToolButton::toggled, this, &MapPage::simulationToggled);
    connect(ui->btnLimpiar, &QToolButton::clicked, this, &MapPage::clearVessels);
    ui->map->setShowLabels(ui->btnEtiquetas->isChecked());
    ui->map->setShowTracks(ui->btnTrayectorias->isChecked());

    // Tabla (ordenable y filtrable)
    m_proxy = new QSortFilterProxyModel(this);
    m_proxy->setSortRole(VesselModel::SortRole);
    m_proxy->setFilterKeyColumn(-1);
    m_proxy->setFilterCaseSensitivity(Qt::CaseInsensitive);
    m_proxy->setDynamicSortFilter(true);
    ui->vesselTable->setModel(m_proxy);
    connect(ui->filterEdit, &QLineEdit::textChanged, m_proxy,
            &QSortFilterProxyModel::setFilterFixedString);
    connect(ui->vesselTable->selectionModel(), &QItemSelectionModel::selectionChanged, this,
            &MapPage::onTableSelectionChanged);
    connect(ui->vesselTable, &QTableView::doubleClicked, this, [this](const QModelIndex &idx) {
        ui->map->centerOnVessel(idx.data(VesselModel::MmsiRole).toUInt());
    });

    connect(ui->detailPanel, &VesselDetailPanel::centerRequested, ui->map,
            &MapWidget::centerOnVessel);
    connect(ui->map, &MapWidget::vesselClicked, this, &MapPage::selectVessel);
}

MapPage::~MapPage()
{
    delete ui;
}

MapWidget *MapPage::map() const
{
    return ui->map;
}

void MapPage::setModel(VesselModel *model)
{
    m_model = model;
    ui->map->setModel(model);
    m_proxy->setSourceModel(model);

    // Las columnas existen recien cuando hay modelo.
    QHeaderView *header = ui->vesselTable->horizontalHeader();
    header->setStretchLastSection(false);
    header->setSectionResizeMode(QHeaderView::ResizeToContents);
    header->setSectionResizeMode(VesselModel::ColName, QHeaderView::Stretch);
    header->setSectionResizeMode(VesselModel::ColType, QHeaderView::Interactive);
    ui->vesselTable->setColumnWidth(VesselModel::ColType, 130);
    ui->vesselTable->sortByColumn(VesselModel::ColName, Qt::AscendingOrder);

    connect(model, &VesselModel::countChanged, this,
            [this](int n) { ui->countLabel->setText(tr("Buques: %1").arg(n)); });
    connect(model, &VesselModel::vesselUpdated, this, &MapPage::onVesselUpdated);
    connect(model, &QAbstractItemModel::modelReset, ui->detailPanel, &VesselDetailPanel::clear);
}

void MapPage::selectVessel(quint32 mmsi)
{
    if (!m_model)
        return;
    ui->map->setSelectedMmsi(mmsi);
    ui->detailPanel->showVessel(m_model->find(mmsi));

    // Sincroniza la seleccion de la tabla sin realimentar la senal.
    m_syncingSelection = true;
    const int row = m_model->rowOf(mmsi);
    const QModelIndex proxyIdx =
        row < 0 ? QModelIndex() : m_proxy->mapFromSource(m_model->index(row, 0));
    if (proxyIdx.isValid()) {
        ui->vesselTable->selectRow(proxyIdx.row());
        ui->vesselTable->scrollTo(proxyIdx);
    } else {
        ui->vesselTable->clearSelection(); // sin buque, o oculto por el filtro
    }
    m_syncingSelection = false;
}

void MapPage::onTableSelectionChanged()
{
    if (m_syncingSelection || !m_model)
        return;
    const QModelIndexList rows = ui->vesselTable->selectionModel()->selectedRows();
    const quint32 mmsi = rows.isEmpty() ? 0 : rows.first().data(VesselModel::MmsiRole).toUInt();
    ui->map->setSelectedMmsi(mmsi);
    ui->detailPanel->showVessel(m_model->find(mmsi));
}

void MapPage::onVesselUpdated(quint32 mmsi)
{
    if (mmsi == ui->detailPanel->currentMmsi())
        ui->detailPanel->showVessel(m_model->find(mmsi));
}

void MapPage::clearVessels()
{
    if (!m_model || m_model->rowCount() == 0)
        return;
    if (QMessageBox::question(this, tr("Limpiar"),
                              tr("¿Borrar los %1 buques de la lista?").arg(m_model->rowCount()))
        == QMessageBox::Yes) {
        m_model->clear();
        ui->detailPanel->clear();
        ui->map->setSelectedMmsi(0);
    }
}

void MapPage::setSimulationRunning(bool running)
{
    const QSignalBlocker blocker(ui->btnSimulacion);
    ui->btnSimulacion->setChecked(running);
}

QByteArray MapPage::saveState() const
{
    return ui->splitter->saveState();
}

void MapPage::restoreState(const QByteArray &state)
{
    if (!state.isEmpty())
        ui->splitter->restoreState(state);
}

void MapPage::on_btnSimulacion_clicked()
{
    // Slot agregado desde Qt Creator ("Ir a slot..."). Se conecta solo por su nombre.
    // La simulacion ya se maneja con btnSimulacion::toggled -> simulationToggled (ver el
    // constructor); si no se usa, se puede borrar junto con su declaracion en mappage.h.
}
