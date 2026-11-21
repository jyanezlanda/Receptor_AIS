#ifndef DEMOSIMULATOR_H
#define DEMOSIMULATOR_H

#include "aistypes.h"

#include <QObject>
#include <QPolygonF>
#include <QTimer>

/*
 * Genera buques ficticios navegando en el Rio de la Plata para probar
 * la interfaz sin tener la Red Pitaya conectada.
 */
class DemoSimulator : public QObject
{
    Q_OBJECT

public:
    explicit DemoSimulator(QObject *parent = nullptr);

    bool isRunning() const { return m_timer.isActive(); }

public slots:
    void setRunning(bool running);

signals:
    void vesselUpdated(const Vessel &vessel);
    void runningChanged(bool running);

private:
    void createFleet();
    void tick();

    QTimer m_timer;
    QVector<Vessel> m_fleet;
    QPolygonF m_water; // zona navegable aproximada (x = lon, y = lat)
};

#endif // DEMOSIMULATOR_H
