#include "vesselmodel.h"

namespace {

QString ageText(const QDateTime &t)
{
    if (!t.isValid())
        return QStringLiteral("—");
    const qint64 s = t.secsTo(QDateTime::currentDateTime());
    if (s < 60)
        return QStringLiteral("%1 s").arg(qMax<qint64>(0, s));
    if (s < 3600)
        return QStringLiteral("%1 min").arg(s / 60);
    return QStringLiteral("%1 h").arg(s / 3600);
}

} // namespace

VesselModel::VesselModel(QObject *parent)
    : QAbstractTableModel(parent)
{
    // Refresca la columna "Visto" (antiguedad del ultimo mensaje) cada segundo.
    m_ageTimer.setInterval(1000);
    connect(&m_ageTimer, &QTimer::timeout, this, [this] {
        if (!m_vessels.isEmpty())
            emit dataChanged(index(0, ColLastSeen), index(rowCount() - 1, ColLastSeen),
                             {Qt::DisplayRole});
    });
    m_ageTimer.start();
}

int VesselModel::rowCount(const QModelIndex &parent) const
{
    return parent.isValid() ? 0 : int(m_vessels.size());
}

int VesselModel::columnCount(const QModelIndex &parent) const
{
    return parent.isValid() ? 0 : ColCount;
}

QVariant VesselModel::data(const QModelIndex &index, int role) const
{
    if (!index.isValid() || index.row() >= m_vessels.size())
        return {};
    const Vessel &v = m_vessels.at(index.row());

    if (role == MmsiRole)
        return v.mmsi;

    if (role == SortRole) {
        switch (index.column()) {
        case ColMmsi:     return v.mmsi;
        case ColName:     return v.displayName();
        case ColType:     return Ais::categoryName(Ais::categoryFromType(v.shipType));
        case ColSog:      return std::isnan(v.sog) ? -1.0 : v.sog;
        case ColLastSeen: return v.lastSeen.isValid() ? -v.lastSeen.toMSecsSinceEpoch() : 0;
        }
        return {};
    }

    if (role == Qt::DisplayRole) {
        switch (index.column()) {
        case ColMmsi: return QString::number(v.mmsi);
        case ColName: return v.name.trimmed().isEmpty() ? QStringLiteral("—") : v.name.trimmed();
        case ColType: return Ais::categoryName(Ais::categoryFromType(v.shipType));
        case ColSog:  return std::isnan(v.sog) ? QStringLiteral("—") : QString::number(v.sog, 'f', 1);
        case ColLastSeen: return ageText(v.lastSeen);
        }
    }

    if (role == Qt::DecorationRole && index.column() == ColType)
        return Ais::categoryColor(Ais::categoryFromType(v.shipType));

    if (role == Qt::TextAlignmentRole) {
        switch (index.column()) {
        case ColSog:
        case ColLastSeen:
            return QVariant::fromValue(Qt::AlignRight | Qt::AlignVCenter);
        }
    }

    if (role == Qt::ToolTipRole) {
        return QStringLiteral("%1\n%2  %3")
            .arg(v.displayName(), Ais::formatLatitude(v.lat), Ais::formatLongitude(v.lon));
    }
    return {};
}

QVariant VesselModel::headerData(int section, Qt::Orientation orientation, int role) const
{
    if (orientation != Qt::Horizontal || role != Qt::DisplayRole)
        return {};
    switch (section) {
    case ColMmsi:     return QStringLiteral("MMSI");
    case ColName:     return QStringLiteral("Nombre");
    case ColType:     return QStringLiteral("Tipo");
    case ColSog:      return QStringLiteral("SOG (kn)");
    case ColLastSeen: return QStringLiteral("Visto");
    }
    return {};
}

const Vessel *VesselModel::find(quint32 mmsi) const
{
    const int row = rowOf(mmsi);
    return row < 0 ? nullptr : &m_vessels.at(row);
}

void VesselModel::upsert(const Vessel &u)
{
    if (u.mmsi == 0)
        return;

    const QDateTime now = u.lastSeen.isValid() ? u.lastSeen : QDateTime::currentDateTime();
    const int row = rowOf(u.mmsi);

    if (row < 0) {
        const int newRow = int(m_vessels.size());
        beginInsertRows({}, newRow, newRow);
        Vessel v = u;
        v.lastSeen = now;
        v.msgCount = 1;
        v.track.clear();
        if (v.hasPosition())
            v.track.append(QPointF(v.lon, v.lat));
        m_vessels.append(v);
        m_index.insert(v.mmsi, newRow);
        endInsertRows();
        emit countChanged(int(m_vessels.size()));
    } else {
        Vessel &v = m_vessels[row];
        if (!u.name.trimmed().isEmpty())        v.name = u.name;
        if (!u.callsign.trimmed().isEmpty())    v.callsign = u.callsign;
        if (!u.destination.trimmed().isEmpty()) v.destination = u.destination;
        if (u.imo != 0)                         v.imo = u.imo;
        if (u.shipType != 0)                    v.shipType = u.shipType;
        if (u.length > 0)                       v.length = u.length;
        if (u.beam > 0)                         v.beam = u.beam;
        if (!std::isnan(u.draught))             v.draught = u.draught;
        if (u.navStatus != Ais::NavStatusNotDefined) v.navStatus = u.navStatus;
        if (!std::isnan(u.sog))                 v.sog = u.sog;
        if (!std::isnan(u.cog))                 v.cog = u.cog;
        if (u.heading != Ais::HeadingNotAvailable) v.heading = u.heading;
        if (u.hasPosition()) {
            const QPointF p(u.lon, u.lat);
            if (v.track.isEmpty() || v.track.constLast() != p) {
                v.track.append(p);
                if (v.track.size() > MaxTrackPoints)
                    v.track.remove(0, v.track.size() - MaxTrackPoints);
            }
            v.lat = u.lat;
            v.lon = u.lon;
        }
        if (u.lastMsgType != 0) v.lastMsgType = u.lastMsgType;
        v.lastSeen = now;
        ++v.msgCount;
        emit dataChanged(index(row, 0), index(row, ColCount - 1));
    }
    emit vesselUpdated(u.mmsi);
}

void VesselModel::clear()
{
    beginResetModel();
    m_vessels.clear();
    m_index.clear();
    endResetModel();
    emit countChanged(0);
}
