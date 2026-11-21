#include "mapwidget.h"

#include "aistypes.h"
#include "vesselmodel.h"

#include <QDateTime>
#include <QDir>
#include <QKeyEvent>
#include <QMouseEvent>
#include <QNetworkAccessManager>
#include <QNetworkDiskCache>
#include <QNetworkReply>
#include <QNetworkRequest>
#include <QPainter>
#include <QPainterPath>
#include <QStandardPaths>
#include <QToolButton>
#include <QToolTip>
#include <QWheelEvent>
#include <QtMath>

#include <algorithm>
#include <cmath>

namespace {

constexpr int kTileSize = 256;
constexpr int kMinZoom = 2;
constexpr int kMaxZoom = 18;
constexpr double kMaxLat = 85.05112878;
constexpr double kPi = 3.14159265358979323846;
constexpr int kMaxPendingTiles = 24;
constexpr qint64 kRetryFailedMs = 15000;
constexpr int kStaleSeconds = 600; // buques sin mensajes por mas de 10 min se atenuan

// Servidor de teselas. Respetar la politica de uso de OSM:
// https://operations.osmfoundation.org/policies/tiles/
const char kTileUrl[] = "https://tile.openstreetmap.org/%1/%2/%3.png";
const char kUserAgent[] = "MapaReceptorAIS/0.1 (Qt; receptor AIS UTN-FRBA)";

const QColor kWaterColor(170, 211, 223);

double worldSize(int zoom)
{
    return double(kTileSize) * double(1 << zoom);
}

QString tileKey(int z, int x, int y)
{
    return QStringLiteral("%1/%2/%3").arg(z).arg(x).arg(y);
}

// Mayor numero de la forma {1,2,5} x 10^n que no supera x.
double niceNumber(double x)
{
    if (x <= 0)
        return 0;
    const double base = std::pow(10.0, std::floor(std::log10(x)));
    const double f = x / base;
    return (f >= 5 ? 5 : f >= 2 ? 2 : 1) * base;
}

} // namespace

MapWidget::MapWidget(QWidget *parent)
    : QWidget(parent)
    , m_nam(new QNetworkAccessManager(this))
{
    setMouseTracking(true);
    setFocusPolicy(Qt::StrongFocus);
    setAttribute(Qt::WA_OpaquePaintEvent);
    setMinimumSize(320, 240);
    setCursor(Qt::OpenHandCursor);

    m_tiles.setMaxCost(400);

    auto *diskCache = new QNetworkDiskCache(this);
    const QString cacheDir =
        QStandardPaths::writableLocation(QStandardPaths::CacheLocation) + QStringLiteral("/tiles");
    QDir().mkpath(cacheDir);
    diskCache->setCacheDirectory(cacheDir);
    diskCache->setMaximumCacheSize(qint64(200) * 1024 * 1024);
    m_nam->setCache(diskCache);
    connect(m_nam, &QNetworkAccessManager::finished, this, &MapWidget::onTileFinished);

    auto makeButton = [this](const QString &text, const QString &tip) {
        auto *b = new QToolButton(this);
        b->setText(text);
        b->setToolTip(tip);
        b->setFixedSize(30, 30);
        b->setCursor(Qt::ArrowCursor);
        b->setStyleSheet(QStringLiteral(
            "QToolButton { background: rgba(255,255,255,230); color: #222;"
            " border: 1px solid #9a9a9a; border-radius: 4px; font: bold 16px; }"
            "QToolButton:hover { background: #ffffff; }"
            "QToolButton:pressed { background: #dcdcdc; }"));
        return b;
    };
    m_zoomInButton = makeButton(QStringLiteral("+"), tr("Acercar"));
    m_zoomOutButton = makeButton(QStringLiteral("−"), tr("Alejar"));
    connect(m_zoomInButton, &QToolButton::clicked, this, &MapWidget::zoomIn);
    connect(m_zoomOutButton, &QToolButton::clicked, this, &MapWidget::zoomOut);
}

void MapWidget::setModel(VesselModel *model)
{
    if (m_model)
        disconnect(m_model, nullptr, this, nullptr);
    m_model = model;
    if (m_model) {
        auto refresh = [this] { update(); };
        connect(m_model, &QAbstractItemModel::dataChanged, this, refresh);
        connect(m_model, &QAbstractItemModel::rowsInserted, this, refresh);
        connect(m_model, &QAbstractItemModel::modelReset, this, refresh);
    }
    update();
}

// ---------------------------------------------------------------------------
// Coordenadas
// ---------------------------------------------------------------------------

QPointF MapWidget::lonLatToWorld(double lon, double lat, int zoom)
{
    const double n = worldSize(zoom);
    const double latRad = qDegreesToRadians(std::clamp(lat, -kMaxLat, kMaxLat));
    const double x = (lon + 180.0) / 360.0 * n;
    const double y = (1.0 - std::log(std::tan(latRad) + 1.0 / std::cos(latRad)) / kPi) / 2.0 * n;
    return {x, y};
}

void MapWidget::worldToLonLat(const QPointF &world, int zoom, double &lon, double &lat)
{
    const double n = worldSize(zoom);
    lon = world.x() / n * 360.0 - 180.0;
    lat = qRadiansToDegrees(std::atan(std::sinh(kPi * (1.0 - 2.0 * world.y() / n))));
}

QPointF MapWidget::centerWorld() const
{
    return lonLatToWorld(m_centerLon, m_centerLat, m_zoom);
}

void MapWidget::setCenterWorld(const QPointF &world)
{
    double lon, lat;
    worldToLonLat(world, m_zoom, lon, lat);
    // Longitud circular, latitud limitada al rango de Web Mercator.
    lon = std::fmod(lon + 180.0, 360.0);
    if (lon < 0)
        lon += 360.0;
    m_centerLon = lon - 180.0;
    m_centerLat = std::clamp(lat, -kMaxLat, kMaxLat);
    update();
    emit viewChanged();
}

QPointF MapWidget::toScreen(double lon, double lat) const
{
    return lonLatToWorld(lon, lat, m_zoom) - centerWorld() + QPointF(width() / 2.0, height() / 2.0);
}

void MapWidget::screenToLonLat(const QPointF &pos, double &lon, double &lat) const
{
    worldToLonLat(pos - QPointF(width() / 2.0, height() / 2.0) + centerWorld(), m_zoom, lon, lat);
}

void MapWidget::setCenter(double lat, double lon)
{
    m_centerLat = std::clamp(lat, -kMaxLat, kMaxLat);
    m_centerLon = lon;
    update();
    emit viewChanged();
}

void MapWidget::setZoom(int zoom)
{
    zoomAt(QPointF(width() / 2.0, height() / 2.0), zoom);
}

void MapWidget::zoomIn()
{
    setZoom(m_zoom + 1);
}

void MapWidget::zoomOut()
{
    setZoom(m_zoom - 1);
}

void MapWidget::zoomAt(const QPointF &screenPos, int newZoom)
{
    newZoom = std::clamp(newZoom, kMinZoom, kMaxZoom);
    if (newZoom == m_zoom)
        return;
    // Mantiene fijo el punto geografico que esta bajo screenPos.
    double lon, lat;
    screenToLonLat(screenPos, lon, lat);
    m_zoom = newZoom;
    const QPointF offset = screenPos - QPointF(width() / 2.0, height() / 2.0);
    setCenterWorld(lonLatToWorld(lon, lat, m_zoom) - offset);
}

void MapWidget::centerOnVessel(quint32 mmsi)
{
    if (!m_model)
        return;
    const Vessel *v = m_model->find(mmsi);
    if (v && v->hasPosition()) {
        if (m_zoom < 12)
            m_zoom = 12;
        setCenter(v->lat, v->lon);
    }
}

void MapWidget::fitAllVessels()
{
    if (!m_model)
        return;
    double minLat = 90, maxLat = -90, minLon = 180, maxLon = -180;
    int count = 0;
    for (const Vessel &v : m_model->vessels()) {
        if (!v.hasPosition())
            continue;
        minLat = std::min(minLat, v.lat);
        maxLat = std::max(maxLat, v.lat);
        minLon = std::min(minLon, v.lon);
        maxLon = std::max(maxLon, v.lon);
        ++count;
    }
    if (count == 0)
        return;

    int zoom = 13;
    if (count > 1) {
        const double margin = 60.0;
        for (zoom = kMaxZoom - 3; zoom > kMinZoom; --zoom) {
            const QPointF a = lonLatToWorld(minLon, maxLat, zoom);
            const QPointF b = lonLatToWorld(maxLon, minLat, zoom);
            if (b.x() - a.x() <= width() - margin && b.y() - a.y() <= height() - margin)
                break;
        }
    }
    m_zoom = zoom;
    const QPointF a = lonLatToWorld(minLon, maxLat, m_zoom);
    const QPointF b = lonLatToWorld(maxLon, minLat, m_zoom);
    setCenterWorld((a + b) / 2.0);
}

void MapWidget::setSelectedMmsi(quint32 mmsi)
{
    if (m_selected == mmsi)
        return;
    m_selected = mmsi;
    update();
}

void MapWidget::setShowLabels(bool show)
{
    m_showLabels = show;
    update();
}

void MapWidget::setShowTracks(bool show)
{
    m_showTracks = show;
    update();
}

// ---------------------------------------------------------------------------
// Teselas
// ---------------------------------------------------------------------------

void MapWidget::requestTile(int z, int x, int y)
{
    const QString key = tileKey(z, x, y);
    if (m_tiles.contains(key) || m_pending.contains(key))
        return;
    if (m_pending.size() >= kMaxPendingTiles)
        return; // se vuelve a pedir en el proximo repintado
    const auto failed = m_failed.constFind(key);
    if (failed != m_failed.constEnd()
        && QDateTime::currentMSecsSinceEpoch() - failed.value() < kRetryFailedMs)
        return;

    QNetworkRequest request(QUrl(QString::fromLatin1(kTileUrl).arg(z).arg(x).arg(y)));
    request.setHeader(QNetworkRequest::UserAgentHeader, QByteArray(kUserAgent));
    request.setAttribute(QNetworkRequest::CacheLoadControlAttribute,
                         QNetworkRequest::PreferCache);
    QNetworkReply *reply = m_nam->get(request);
    reply->setProperty("tileKey", key);
    m_pending.insert(key);
}

void MapWidget::onTileFinished(QNetworkReply *reply)
{
    reply->deleteLater();
    const QString key = reply->property("tileKey").toString();
    m_pending.remove(key);

    if (reply->error() != QNetworkReply::NoError) {
        m_failed.insert(key, QDateTime::currentMSecsSinceEpoch());
        m_tileError = reply->errorString();
        update();
        return;
    }
    auto *pixmap = new QPixmap;
    if (!pixmap->loadFromData(reply->readAll())) {
        delete pixmap;
        m_failed.insert(key, QDateTime::currentMSecsSinceEpoch());
        return;
    }
    m_failed.remove(key);
    m_tileError.clear();
    m_tiles.insert(key, pixmap);
    update();
}

bool MapWidget::drawFallbackTile(QPainter &p, const QRectF &target, int z, int x, int y)
{
    // Mientras llega la tesela, usa una de menor zoom escalada (si esta en cache).
    for (int d = 1; d <= 5 && z - d >= 0; ++d) {
        const QPixmap *parent = m_tiles.object(tileKey(z - d, x >> d, y >> d));
        if (!parent)
            continue;
        const double sub = double(kTileSize) / double(1 << d);
        const QRectF source((x - ((x >> d) << d)) * sub, (y - ((y >> d) << d)) * sub, sub, sub);
        p.drawPixmap(target, *parent, source);
        return true;
    }
    return false;
}

// ---------------------------------------------------------------------------
// Dibujo
// ---------------------------------------------------------------------------

void MapWidget::paintEvent(QPaintEvent *)
{
    QPainter p(this);
    p.fillRect(rect(), kWaterColor);
    drawTiles(p);

    p.setRenderHint(QPainter::Antialiasing);
    if (m_showTracks)
        drawTracks(p);
    drawVessels(p);
    drawScaleBar(p);
    drawInfoOverlay(p);

    m_zoomInButton->setEnabled(m_zoom < kMaxZoom);
    m_zoomOutButton->setEnabled(m_zoom > kMinZoom);
}

void MapWidget::drawTiles(QPainter &p)
{
    const QPointF cw = centerWorld();
    const double left = cw.x() - width() / 2.0;
    const double top = cw.y() - height() / 2.0;
    const int n = 1 << m_zoom;

    const int x0 = int(std::floor(left / kTileSize));
    const int x1 = int(std::floor((left + width()) / kTileSize));
    const int y0 = std::max(0, int(std::floor(top / kTileSize)));
    const int y1 = std::min(n - 1, int(std::floor((top + height()) / kTileSize)));

    p.setRenderHint(QPainter::SmoothPixmapTransform);
    for (int ty = y0; ty <= y1; ++ty) {
        for (int tx = x0; tx <= x1; ++tx) {
            const int wx = ((tx % n) + n) % n;
            const QRectF target(tx * double(kTileSize) - left, ty * double(kTileSize) - top,
                                kTileSize, kTileSize);
            if (const QPixmap *tile = m_tiles.object(tileKey(m_zoom, wx, ty))) {
                p.drawPixmap(target.topLeft(), *tile);
            } else {
                drawFallbackTile(p, target, m_zoom, wx, ty);
                requestTile(m_zoom, wx, ty);
            }
        }
    }
}

void MapWidget::drawTracks(QPainter &p)
{
    if (!m_model)
        return;
    for (const Vessel &v : m_model->vessels()) {
        if (v.track.size() < 2)
            continue;
        QPolygonF poly;
        poly.reserve(v.track.size());
        for (const QPointF &ll : v.track)
            poly.append(toScreen(ll.x(), ll.y()));
        QColor c = Ais::categoryColor(Ais::categoryFromType(v.shipType));
        const bool sel = v.mmsi == m_selected;
        c.setAlpha(sel ? 230 : 140);
        p.setPen(QPen(c, sel ? 2.5 : 1.5, sel ? Qt::SolidLine : Qt::DashLine, Qt::RoundCap,
                      Qt::RoundJoin));
        p.drawPolyline(poly);
    }
}

void MapWidget::drawVessels(QPainter &p)
{
    if (!m_model)
        return;
    const QRectF visible = QRectF(rect()).adjusted(-40, -40, 40, 40);
    const Vessel *selected = nullptr;

    for (const Vessel &v : m_model->vessels()) {
        if (!v.hasPosition())
            continue;
        if (v.mmsi == m_selected) {
            selected = &v; // se dibuja al final, por encima del resto
            continue;
        }
        if (visible.contains(toScreen(v.lon, v.lat)))
            drawVessel(p, v, false);
    }
    if (selected)
        drawVessel(p, *selected, true);

    // Etiquetas despues de todos los iconos para que no queden tapadas.
    for (const Vessel &v : m_model->vessels()) {
        if (!v.hasPosition())
            continue;
        const bool sel = v.mmsi == m_selected;
        const bool hov = v.mmsi == m_hovered;
        if (!(sel || hov || (m_showLabels && m_zoom >= 9)))
            continue;
        const QPointF pos = toScreen(v.lon, v.lat);
        if (visible.contains(pos))
            drawLabel(p, pos + QPointF(12, -10), v.displayName(), sel);
    }
}

void MapWidget::drawVessel(QPainter &p, const Vessel &v, bool selected)
{
    const QPointF pos = toScreen(v.lon, v.lat);
    QColor fill = Ais::categoryColor(Ais::categoryFromType(v.shipType));
    const bool stale = v.lastSeen.isValid()
                       && v.lastSeen.secsTo(QDateTime::currentDateTime()) > kStaleSeconds;
    if (stale)
        fill.setAlpha(110);

    p.save();
    p.translate(pos);

    if (selected) {
        p.setPen(QPen(QColor(255, 255, 255, 230), 5));
        p.setBrush(Qt::NoBrush);
        p.drawEllipse(QPointF(0, 0), 16, 16);
        p.setPen(QPen(QColor(220, 30, 30), 2.5));
        p.drawEllipse(QPointF(0, 0), 16, 16);
    }

    p.setPen(QPen(QColor(20, 20, 20, stale ? 110 : 220), 1.2));
    p.setBrush(fill);
    if (v.isMoving()) {
        p.rotate(v.drawCourse());
        // Vector de velocidad: largo proporcional a la SOG.
        const double vecLen = 12 + std::min(v.sog, 30.0) * 1.5;
        p.drawLine(QPointF(0, -9), QPointF(0, -vecLen));
        const QPolygonF hull{QPointF(0, -10), QPointF(6.5, 8), QPointF(0, 4), QPointF(-6.5, 8)};
        p.drawPolygon(hull);
    } else {
        // Buque detenido / fondeado / amarrado
        p.drawEllipse(QPointF(0, 0), 5.5, 5.5);
    }
    p.restore();
}

void MapWidget::drawLabel(QPainter &p, const QPointF &anchor, const QString &text, bool bold)
{
    QFont f = font();
    f.setPointSizeF(f.pointSizeF() * 0.95);
    f.setBold(bold);
    QPainterPath path;
    path.addText(anchor, f, text);
    p.setPen(QPen(QColor(255, 255, 255, 220), 3.5, Qt::SolidLine, Qt::RoundCap, Qt::RoundJoin));
    p.setBrush(Qt::NoBrush);
    p.drawPath(path);
    p.setPen(Qt::NoPen);
    p.setBrush(QColor(25, 25, 25));
    p.drawPath(path);
}

void MapWidget::drawScaleBar(QPainter &p)
{
    // Metros por pixel en la latitud del centro (Web Mercator).
    const double mpp = 2.0 * kPi * 6378137.0 * std::cos(qDegreesToRadians(m_centerLat))
                       / worldSize(m_zoom);
    const double maxPx = 120.0;

    const double meters = niceNumber(maxPx * mpp);
    const double nm = niceNumber(maxPx * mpp / 1852.0);
    const double pxMeters = meters / mpp;
    const double pxNm = nm * 1852.0 / mpp;

    const QString lblMeters = meters >= 1000 ? QStringLiteral("%1 km").arg(meters / 1000.0)
                                             : QStringLiteral("%1 m").arg(meters);
    const QString lblNm = QStringLiteral("%1 NM").arg(nm);

    const int x = 10;
    const int y = height() - 58;
    const QRectF bg(x - 4, y - 4, std::max(pxMeters, pxNm) + 70, 40);
    p.setPen(Qt::NoPen);
    p.setBrush(QColor(255, 255, 255, 190));
    p.drawRoundedRect(bg, 3, 3);

    p.setPen(QPen(QColor(40, 40, 40), 2));
    auto bar = [&](int yy, double px, const QString &label) {
        p.drawLine(QPointF(x, yy), QPointF(x + px, yy));
        p.drawLine(QPointF(x, yy - 4), QPointF(x, yy + 4));
        p.drawLine(QPointF(x + px, yy - 4), QPointF(x + px, yy + 4));
        p.drawText(QPointF(x + px + 6, yy + 4), label);
    };
    bar(y + 7, pxMeters, lblMeters);
    bar(y + 25, pxNm, lblNm);
}

void MapWidget::drawInfoOverlay(QPainter &p)
{
    const QFontMetrics fm(font());

    // Atribucion obligatoria de OpenStreetMap
    const QString attribution = QStringLiteral("© OpenStreetMap contributors");
    QRect r = fm.boundingRect(attribution).adjusted(-5, -2, 5, 2);
    r.moveBottomRight(rect().bottomRight() - QPoint(2, 2));
    p.setPen(Qt::NoPen);
    p.setBrush(QColor(255, 255, 255, 200));
    p.drawRect(r);
    p.setPen(QColor(50, 50, 50));
    p.drawText(r, Qt::AlignCenter, attribution);

    // Coordenadas bajo el cursor y nivel de zoom
    QString info = QStringLiteral("Zoom %1").arg(m_zoom);
    if (m_cursorValid)
        info.prepend(QStringLiteral("%1   %2    ")
                         .arg(Ais::formatLatitude(m_cursorLat), Ais::formatLongitude(m_cursorLon)));
    r = fm.boundingRect(info).adjusted(-6, -3, 6, 3);
    r.moveBottomLeft(QPoint(6, height() - 6));
    p.setPen(Qt::NoPen);
    p.setBrush(QColor(255, 255, 255, 200));
    p.drawRoundedRect(r, 3, 3);
    p.setPen(QColor(30, 30, 30));
    p.drawText(r, Qt::AlignCenter, info);

    // Aviso si el servidor de mapas no responde
    if (!m_tileError.isEmpty()) {
        const QString msg = QStringLiteral("Sin acceso al servidor de mapas: %1").arg(m_tileError);
        QRect er = fm.boundingRect(msg).adjusted(-8, -4, 8, 4);
        er.moveTopLeft(QPoint(8, 8));
        p.setPen(Qt::NoPen);
        p.setBrush(QColor(180, 40, 40, 215));
        p.drawRoundedRect(er, 4, 4);
        p.setPen(Qt::white);
        p.drawText(er, Qt::AlignCenter, msg);
    }
}

// ---------------------------------------------------------------------------
// Interaccion
// ---------------------------------------------------------------------------

quint32 MapWidget::vesselAt(const QPoint &pos) const
{
    if (!m_model)
        return 0;
    quint32 best = 0;
    double bestDist = 12.0 * 12.0;
    for (const Vessel &v : m_model->vessels()) {
        if (!v.hasPosition())
            continue;
        const QPointF d = toScreen(v.lon, v.lat) - QPointF(pos);
        const double dist = QPointF::dotProduct(d, d);
        if (dist < bestDist) {
            bestDist = dist;
            best = v.mmsi;
        }
    }
    return best;
}

void MapWidget::resizeEvent(QResizeEvent *event)
{
    QWidget::resizeEvent(event);
    m_zoomInButton->move(width() - 40, 10);
    m_zoomOutButton->move(width() - 40, 44);
}

void MapWidget::wheelEvent(QWheelEvent *event)
{
    m_wheelAccum += event->angleDelta().y();
    const int steps = m_wheelAccum / 120;
    if (steps != 0) {
        m_wheelAccum -= steps * 120;
        zoomAt(event->position(), m_zoom + steps);
    }
    event->accept();
}

void MapWidget::mousePressEvent(QMouseEvent *event)
{
    if (event->button() == Qt::LeftButton) {
        m_dragging = true;
        m_pressPos = event->pos();
        m_lastMousePos = event->pos();
        setCursor(Qt::ClosedHandCursor);
    }
}

void MapWidget::mouseMoveEvent(QMouseEvent *event)
{
    screenToLonLat(event->position(), m_cursorLon, m_cursorLat);
    m_cursorValid = true;

    if (m_dragging) {
        const QPoint delta = event->pos() - m_lastMousePos;
        m_lastMousePos = event->pos();
        setCenterWorld(centerWorld() - QPointF(delta));
        return;
    }

    const quint32 hovered = vesselAt(event->pos());
    if (hovered != m_hovered) {
        m_hovered = hovered;
        setCursor(hovered ? Qt::PointingHandCursor : Qt::OpenHandCursor);
        if (hovered && m_model) {
            if (const Vessel *v = m_model->find(hovered)) {
                QToolTip::showText(
                    event->globalPosition().toPoint(),
                    QStringLiteral("<b>%1</b><br>MMSI %2<br>%3<br>SOG %4 kn · COG %5°")
                        .arg(v->displayName().toHtmlEscaped())
                        .arg(v->mmsi)
                        .arg(Ais::categoryName(Ais::categoryFromType(v->shipType)))
                        .arg(std::isnan(v->sog) ? QStringLiteral("—")
                                                : QString::number(v->sog, 'f', 1))
                        .arg(std::isnan(v->cog) ? QStringLiteral("—")
                                                : QString::number(v->cog, 'f', 0)),
                    this);
            }
        } else {
            QToolTip::hideText();
        }
    }
    update();
}

void MapWidget::mouseReleaseEvent(QMouseEvent *event)
{
    if (event->button() != Qt::LeftButton || !m_dragging)
        return;
    m_dragging = false;
    setCursor(m_hovered ? Qt::PointingHandCursor : Qt::OpenHandCursor);

    // Un clic sin arrastre selecciona el buque mas cercano (o deselecciona).
    if ((event->pos() - m_pressPos).manhattanLength() < 4) {
        const quint32 mmsi = vesselAt(event->pos());
        if (mmsi != m_selected) {
            m_selected = mmsi;
            update();
        }
        emit vesselClicked(mmsi);
    }
}

void MapWidget::mouseDoubleClickEvent(QMouseEvent *event)
{
    if (event->button() == Qt::LeftButton)
        zoomAt(event->position(), m_zoom + 1);
    else if (event->button() == Qt::RightButton)
        zoomAt(event->position(), m_zoom - 1);
}

void MapWidget::leaveEvent(QEvent *event)
{
    QWidget::leaveEvent(event);
    m_cursorValid = false;
    m_hovered = 0;
    update();
}

void MapWidget::keyPressEvent(QKeyEvent *event)
{
    const double step = 80.0;
    switch (event->key()) {
    case Qt::Key_Plus:
    case Qt::Key_Equal: zoomIn(); break;
    case Qt::Key_Minus: zoomOut(); break;
    case Qt::Key_Left:  setCenterWorld(centerWorld() - QPointF(step, 0)); break;
    case Qt::Key_Right: setCenterWorld(centerWorld() + QPointF(step, 0)); break;
    case Qt::Key_Up:    setCenterWorld(centerWorld() - QPointF(0, step)); break;
    case Qt::Key_Down:  setCenterWorld(centerWorld() + QPointF(0, step)); break;
    default: QWidget::keyPressEvent(event); return;
    }
}
