#ifndef VESSELMODEL_H
#define VESSELMODEL_H

#include "aistypes.h"

#include <QAbstractTableModel>
#include <QHash>
#include <QTimer>

/*
 * Modelo con todos los buques recibidos, indexados por MMSI.
 * Es la unica fuente de datos para el mapa, la tabla y el panel de detalle.
 */
class VesselModel : public QAbstractTableModel
{
    Q_OBJECT

public:
    // El COG y el resto de los datos se ven en el panel de detalle.
    enum Column { ColMmsi, ColName, ColType, ColSog, ColLastSeen, ColCount };
    enum Role { MmsiRole = Qt::UserRole, SortRole };

    explicit VesselModel(QObject *parent = nullptr);

    int rowCount(const QModelIndex &parent = {}) const override;
    int columnCount(const QModelIndex &parent = {}) const override;
    QVariant data(const QModelIndex &index, int role = Qt::DisplayRole) const override;
    QVariant headerData(int section, Qt::Orientation orientation,
                        int role = Qt::DisplayRole) const override;

    const QVector<Vessel> &vessels() const { return m_vessels; }
    const Vessel *find(quint32 mmsi) const;
    int rowOf(quint32 mmsi) const { return m_index.value(mmsi, -1); }

    static constexpr int MaxTrackPoints = 300;

public slots:
    // Inserta o actualiza un buque. Solo pisa los campos que traen dato.
    void upsert(const Vessel &update);
    void clear();

signals:
    void vesselUpdated(quint32 mmsi);
    void countChanged(int count);

private:
    QVector<Vessel> m_vessels;
    QHash<quint32, int> m_index;
    QTimer m_ageTimer;
};

#endif // VESSELMODEL_H
