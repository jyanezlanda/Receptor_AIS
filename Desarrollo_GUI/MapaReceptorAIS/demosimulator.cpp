#include "demosimulator.h"

#include <QRandomGenerator>
#include <QtMath>

namespace {

constexpr double kTimeScale = 30.0; // segundos simulados por cada tick de 1 s
constexpr double kMetersPerDegLat = 111320.0;

double rnd(double lo, double hi)
{
    return lo + (hi - lo) * QRandomGenerator::global()->generateDouble();
}

struct ShipSpec
{
    const char *name;
    const char *callsign;
    int type;
    double sog;
    int length;
    int beam;
    double draught;
    const char *destination;
};

// Nombres y datos ficticios.
const ShipSpec kFleet[] = {
    {"ESTRELLA DEL SUR", "LW2101", 70, 11.5, 190, 32, 9.8, "BUENOS AIRES"},
    {"CRUZ DEL PLATA", "LW3307", 80, 10.2, 228, 32, 11.2, "LA PLATA"},
    {"NORTE ARGENTINO", "LW4410", 71, 12.8, 175, 28, 8.9, "ROSARIO"},
    {"LUCERO DEL ALBA", "LW5122", 60, 20.5, 98, 24, 3.6, "COLONIA"},
    {"ALBATROS II", "LW6018", 30, 7.5, 34, 9, 3.9, "MAR DEL PLATA"},
    {"CORMORAN", "LW7290", 52, 9.0, 32, 11, 4.5, "BUENOS AIRES"},
    {"SANTA LUCIA", "LW8834", 37, 5.5, 14, 4, 1.8, "SAN ISIDRO"},
    {"TALISMAN", "LW9051", 36, 6.2, 12, 4, 2.0, "COLONIA"},
    {"DELTA EXPRESS", "LW1188", 40, 27.0, 70, 18, 2.5, "MONTEVIDEO"},
    {"AURORA AUSTRAL", "LW2240", 84, 0.0, 245, 42, 13.5, "ZONA ALIJO"},
    {"PAMPERO", "LW3375", 79, 13.1, 210, 32, 10.4, "SAN NICOLAS"},
    {"GAVIOTA", "LW4466", 50, 14.0, 18, 5, 1.6, "PRACTICAJE"},
};

} // namespace

DemoSimulator::DemoSimulator(QObject *parent)
    : QObject(parent)
{
    // Poligono simplificado del Rio de la Plata (lon, lat).
    m_water << QPointF(-58.33, -34.57) << QPointF(-58.05, -34.43) << QPointF(-57.85, -34.52)
            << QPointF(-57.40, -34.49) << QPointF(-57.00, -34.60) << QPointF(-57.00, -35.20)
            << QPointF(-57.25, -35.22) << QPointF(-57.85, -34.85) << QPointF(-58.20, -34.70);

    m_timer.setInterval(1000);
    connect(&m_timer, &QTimer::timeout, this, &DemoSimulator::tick);
}

void DemoSimulator::setRunning(bool running)
{
    if (running == isRunning())
        return;
    if (running) {
        if (m_fleet.isEmpty())
            createFleet();
        m_timer.start();
        tick();
    } else {
        m_timer.stop();
    }
    emit runningChanged(running);
}

void DemoSimulator::createFleet()
{
    const QRectF box = m_water.boundingRect();
    quint32 mmsi = 701000101; // MID 701 = Argentina
    for (const ShipSpec &s : kFleet) {
        Vessel v;
        v.mmsi = mmsi;
        mmsi += 1137;
        v.name = QString::fromLatin1(s.name);
        v.callsign = QString::fromLatin1(s.callsign);
        v.destination = QString::fromLatin1(s.destination);
        v.imo = s.length > 50 ? 9000000 + QRandomGenerator::global()->bounded(900000) : 0;
        v.shipType = s.type;
        v.length = s.length;
        v.beam = s.beam;
        v.draught = s.draught;
        v.sog = s.sog;
        v.cog = rnd(0, 360);
        v.navStatus = s.sog > 0 ? (s.type == 30 ? 7 : s.type == 36 ? 8 : 0) : 1;

        QPointF p;
        do {
            p = QPointF(rnd(box.left(), box.right()), rnd(box.top(), box.bottom()));
        } while (!m_water.containsPoint(p, Qt::OddEvenFill));
        v.lon = p.x();
        v.lat = p.y();
        m_fleet.append(v);
    }
}

void DemoSimulator::tick()
{
    const QPointF center(-57.60, -34.80);
    int i = 0;
    for (Vessel &v : m_fleet) {
        if (v.sog > 0.1) {
            const double dist = v.sog * 0.514444 * kTimeScale; // metros
            const double rad = qDegreesToRadians(v.cog);
            QPointF next(v.lon + dist * std::sin(rad)
                                     / (kMetersPerDegLat * std::cos(qDegreesToRadians(v.lat))),
                         v.lat + dist * std::cos(rad) / kMetersPerDegLat);
            if (m_water.containsPoint(next, Qt::OddEvenFill)) {
                v.lon = next.x();
                v.lat = next.y();
                v.cog = std::fmod(v.cog + rnd(-2.0, 2.0) + 360.0, 360.0);
            } else {
                // Llego a la costa: gira hacia el centro del rio.
                const double dx = (center.x() - v.lon) * std::cos(qDegreesToRadians(v.lat));
                const double dy = center.y() - v.lat;
                v.cog = std::fmod(qRadiansToDegrees(std::atan2(dx, dy)) + rnd(-25, 25) + 360.0,
                                  360.0);
            }
            v.heading = int(std::lround(v.cog + rnd(-3, 3) + 360)) % 360;
        } else {
            v.cog = Ais::nan();
            v.heading = 215;
        }
        v.lastSeen = QDateTime::currentDateTime();
        // Alterna mensajes de posicion (tipo 1) y estaticos (tipo 5).
        v.lastMsgType = (QRandomGenerator::global()->bounded(6) == 0) ? 5 : 1;

        // No todos los buques transmiten en todos los ticks.
        if (QRandomGenerator::global()->bounded(10) < 8 || i == 0)
            emit vesselUpdated(v);
        ++i;
    }
}
