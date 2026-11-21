#include "vesseldetailpanel.h"
#include "ui_vesseldetailpanel.h"

#include "aistypes.h"

namespace {

QString numberOrDash(double v, int decimals, const QString &unit)
{
    if (std::isnan(v))
        return QStringLiteral("—");
    return QStringLiteral("%1 %2").arg(QString::number(v, 'f', decimals), unit).trimmed();
}

QString textOrDash(const QString &s)
{
    const QString t = s.trimmed();
    return t.isEmpty() ? QStringLiteral("—") : t;
}

} // namespace

VesselDetailPanel::VesselDetailPanel(QWidget *parent)
    : QGroupBox(parent)
    , ui(new Ui::VesselDetailPanel)
{
    ui->setupUi(this);
    connect(ui->centerButton, &QPushButton::clicked, this, [this] {
        if (m_mmsi)
            emit centerRequested(m_mmsi);
    });
    clear();
}

VesselDetailPanel::~VesselDetailPanel()
{
    delete ui;
}

void VesselDetailPanel::clear()
{
    m_mmsi = 0;
    ui->titleLabel->setText(tr("Ninguno"));
    ui->swatchLabel->setStyleSheet(QString());
    ui->centerButton->setEnabled(false);
    // Todos los valores ("val...") vuelven a "—".
    const auto labels = ui->formWidget->findChildren<QLabel *>();
    for (QLabel *l : labels) {
        if (l->objectName().startsWith(QLatin1String("val")))
            l->setText(QStringLiteral("—"));
    }
    ui->formWidget->setEnabled(false);
}

void VesselDetailPanel::showVessel(const Vessel *v)
{
    if (!v) {
        clear();
        return;
    }
    m_mmsi = v->mmsi;
    ui->formWidget->setEnabled(true);
    ui->centerButton->setEnabled(v->hasPosition());

    const auto category = Ais::categoryFromType(v->shipType);
    ui->titleLabel->setText(v->displayName());
    ui->swatchLabel->setStyleSheet(
        QStringLiteral("background:%1; border:1px solid #333; border-radius:3px;")
            .arg(Ais::categoryColor(category).name()));

    ui->valMmsi->setText(QString::number(v->mmsi));
    ui->valCallsign->setText(textOrDash(v->callsign));
    ui->valImo->setText(v->imo ? QString::number(v->imo) : QStringLiteral("—"));
    ui->valType->setText(Ais::shipTypeText(v->shipType));
    ui->valStatus->setText(Ais::navStatusText(v->navStatus));
    ui->valLat->setText(Ais::formatLatitude(v->lat));
    ui->valLon->setText(Ais::formatLongitude(v->lon));
    ui->valSog->setText(numberOrDash(v->sog, 1, QStringLiteral("kn")));
    ui->valCog->setText(numberOrDash(v->cog, 1, QStringLiteral("°")));
    ui->valHeading->setText(v->heading == Ais::HeadingNotAvailable
                                ? QStringLiteral("—")
                                : QStringLiteral("%1°").arg(v->heading));
    ui->valDest->setText(textOrDash(v->destination));
    ui->valDims->setText((v->length > 0 || v->beam > 0)
                             ? QStringLiteral("%1 m × %2 m").arg(v->length).arg(v->beam)
                             : QStringLiteral("—"));
    ui->valDraught->setText(numberOrDash(v->draught, 1, QStringLiteral("m")));
    ui->valLast->setText(v->lastSeen.isValid()
                             ? QStringLiteral("%1 (tipo %2)")
                                   .arg(v->lastSeen.toString(QStringLiteral("dd/MM/yyyy HH:mm:ss")))
                                   .arg(v->lastMsgType)
                             : QStringLiteral("—"));
    ui->valCount->setText(QString::number(v->msgCount));
}
