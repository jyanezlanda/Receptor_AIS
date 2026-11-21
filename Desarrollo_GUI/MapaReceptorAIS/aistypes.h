#ifndef AISTYPES_H
#define AISTYPES_H

#include <QColor>
#include <QDateTime>
#include <QPointF>
#include <QString>
#include <QVector>

#include <cmath>
#include <limits>

/*
 * Tipos y utilidades comunes para datos AIS (ITU-R M.1371).
 */

namespace Ais {

constexpr int HeadingNotAvailable = 511;
constexpr int NavStatusNotDefined = 15;

enum class ShipCategory {
    Unknown,
    Cargo,
    Tanker,
    Passenger,
    Fishing,
    TugSpecial,
    HighSpeed,
    Pleasure,
    Other
};

ShipCategory categoryFromType(int shipType);
QString categoryName(ShipCategory category);
QColor categoryColor(ShipCategory category);
QString shipTypeText(int shipType);
QString navStatusText(int navStatus);

QString formatLatitude(double lat);
QString formatLongitude(double lon);

inline double nan() { return std::numeric_limits<double>::quiet_NaN(); }

} // namespace Ais

/*
 * Estado conocido de un buque. Se va completando a medida que llegan
 * mensajes de posicion (tipos 1/2/3/18/19) y estaticos (tipos 5/24).
 * Los campos sin dato quedan en NaN / 0 / cadena vacia.
 */
struct Vessel
{
    quint32 mmsi = 0;

    // Datos estaticos y de viaje
    QString name;
    QString callsign;
    QString destination;
    quint32 imo = 0;
    int shipType = 0;
    int length = 0;     // eslora [m]
    int beam = 0;       // manga [m]
    double draught = Ais::nan(); // calado [m]

    // Datos dinamicos
    int navStatus = Ais::NavStatusNotDefined;
    double lat = Ais::nan();
    double lon = Ais::nan();
    double sog = Ais::nan();     // velocidad sobre el fondo [nudos]
    double cog = Ais::nan();     // rumbo sobre el fondo [grados]
    int heading = Ais::HeadingNotAvailable; // rumbo verdadero [grados]

    // Recepcion
    int lastMsgType = 0;
    QDateTime lastSeen;
    quint32 msgCount = 0;
    QVector<QPointF> track; // historico de posiciones (x = lon, y = lat)

    bool hasPosition() const { return !std::isnan(lat) && !std::isnan(lon); }
    bool isMoving() const { return !std::isnan(sog) && sog > 0.5; }
    QString displayName() const
    {
        return name.trimmed().isEmpty() ? QString::number(mmsi) : name.trimmed();
    }
    // Rumbo a usar para dibujar: heading si existe, si no COG.
    double drawCourse() const
    {
        if (heading != Ais::HeadingNotAvailable)
            return heading;
        return std::isnan(cog) ? 0.0 : cog;
    }
};

#endif // AISTYPES_H
