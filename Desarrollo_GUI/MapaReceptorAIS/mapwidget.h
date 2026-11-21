#ifndef MAPWIDGET_H
#define MAPWIDGET_H

#include <QCache>
#include <QHash>
#include <QPixmap>
#include <QSet>
#include <QWidget>

class QNetworkAccessManager;
class QNetworkReply;
class QToolButton;
class VesselModel;
struct Vessel;

/*
 * Mapa "slippy" con teselas de OpenStreetMap (proyeccion Web Mercator)
 * dibujado con QPainter. No depende de Qt Location ni de WebEngine.
 *
 *  - Arrastrar con el boton izquierdo: desplazar
 *  - Rueda / doble clic / botones +/-: zoom
 *  - Clic sobre un buque: seleccionarlo
 *
 * Las teselas se guardan en un cache de disco para poder trabajar
 * sin conexion en zonas ya visitadas.
 */
class MapWidget : public QWidget
{
    Q_OBJECT

public:
    explicit MapWidget(QWidget *parent = nullptr);

    void setModel(VesselModel *model);

    void setCenter(double lat, double lon);
    double centerLat() const { return m_centerLat; }
    double centerLon() const { return m_centerLon; }
    void setZoom(int zoom);
    int zoom() const { return m_zoom; }

    void centerOnVessel(quint32 mmsi);
    void fitAllVessels();

    quint32 selectedMmsi() const { return m_selected; }

public slots:
    void setSelectedMmsi(quint32 mmsi);
    void setShowLabels(bool show);
    void setShowTracks(bool show);
    void zoomIn();
    void zoomOut();

signals:
    void vesselClicked(quint32 mmsi);
    void viewChanged();

protected:
    void paintEvent(QPaintEvent *event) override;
    void resizeEvent(QResizeEvent *event) override;
    void wheelEvent(QWheelEvent *event) override;
    void mousePressEvent(QMouseEvent *event) override;
    void mouseMoveEvent(QMouseEvent *event) override;
    void mouseReleaseEvent(QMouseEvent *event) override;
    void mouseDoubleClickEvent(QMouseEvent *event) override;
    void leaveEvent(QEvent *event) override;
    void keyPressEvent(QKeyEvent *event) override;

private:
    // Conversiones de coordenadas
    static QPointF lonLatToWorld(double lon, double lat, int zoom);
    static void worldToLonLat(const QPointF &world, int zoom, double &lon, double &lat);
    QPointF centerWorld() const;
    void setCenterWorld(const QPointF &world);
    QPointF toScreen(double lon, double lat) const;
    void screenToLonLat(const QPointF &pos, double &lon, double &lat) const;
    void zoomAt(const QPointF &screenPos, int newZoom);

    // Teselas
    void requestTile(int z, int x, int y);
    void onTileFinished(QNetworkReply *reply);
    bool drawFallbackTile(QPainter &p, const QRectF &target, int z, int x, int y);

    // Dibujo
    void drawTiles(QPainter &p);
    void drawTracks(QPainter &p);
    void drawVessels(QPainter &p);
    void drawVessel(QPainter &p, const Vessel &v, bool selected);
    void drawLabel(QPainter &p, const QPointF &anchor, const QString &text, bool bold);
    void drawScaleBar(QPainter &p);
    void drawInfoOverlay(QPainter &p);

    quint32 vesselAt(const QPoint &pos) const;

    QNetworkAccessManager *m_nam = nullptr;
    QCache<QString, QPixmap> m_tiles;
    QSet<QString> m_pending;
    QHash<QString, qint64> m_failed; // clave -> momento del fallo [ms]
    QString m_tileError;

    VesselModel *m_model = nullptr;

    double m_centerLat = -34.75;
    double m_centerLon = -57.75;
    int m_zoom = 10;

    bool m_dragging = false;
    QPoint m_pressPos;
    QPoint m_lastMousePos;
    bool m_cursorValid = false;
    double m_cursorLat = 0.0;
    double m_cursorLon = 0.0;
    int m_wheelAccum = 0;

    quint32 m_selected = 0;
    quint32 m_hovered = 0;
    bool m_showLabels = true;
    bool m_showTracks = true;

    QToolButton *m_zoomInButton = nullptr;
    QToolButton *m_zoomOutButton = nullptr;
};

#endif // MAPWIDGET_H
