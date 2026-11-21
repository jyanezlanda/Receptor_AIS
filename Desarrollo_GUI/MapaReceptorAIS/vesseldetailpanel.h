#ifndef VESSELDETAILPANEL_H
#define VESSELDETAILPANEL_H

#include <QGroupBox>

QT_BEGIN_NAMESPACE
namespace Ui {
class VesselDetailPanel;
}
QT_END_NAMESPACE

struct Vessel;

/*
 * Panel con todos los datos conocidos del buque seleccionado.
 * Diseno en vesseldetailpanel.ui.
 */
class VesselDetailPanel : public QGroupBox
{
    Q_OBJECT

public:
    explicit VesselDetailPanel(QWidget *parent = nullptr);
    ~VesselDetailPanel() override;

    void showVessel(const Vessel *vessel);
    void clear();
    quint32 currentMmsi() const { return m_mmsi; }

signals:
    void centerRequested(quint32 mmsi);

private:
    Ui::VesselDetailPanel *ui;
    quint32 m_mmsi = 0;
};

#endif // VESSELDETAILPANEL_H
