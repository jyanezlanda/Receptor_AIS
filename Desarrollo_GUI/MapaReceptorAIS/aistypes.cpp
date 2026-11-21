#include "aistypes.h"

namespace Ais {

ShipCategory categoryFromType(int t)
{
    if (t == 30)
        return ShipCategory::Fishing;
    if ((t >= 31 && t <= 34) || (t >= 50 && t <= 59))
        return ShipCategory::TugSpecial;
    if (t == 36 || t == 37)
        return ShipCategory::Pleasure;
    if (t >= 40 && t <= 49)
        return ShipCategory::HighSpeed;
    if (t >= 60 && t <= 69)
        return ShipCategory::Passenger;
    if (t >= 70 && t <= 79)
        return ShipCategory::Cargo;
    if (t >= 80 && t <= 89)
        return ShipCategory::Tanker;
    if (t == 0)
        return ShipCategory::Unknown;
    return ShipCategory::Other;
}

QString categoryName(ShipCategory c)
{
    switch (c) {
    case ShipCategory::Cargo:      return QStringLiteral("Carga");
    case ShipCategory::Tanker:     return QStringLiteral("Tanquero");
    case ShipCategory::Passenger:  return QStringLiteral("Pasajeros");
    case ShipCategory::Fishing:    return QStringLiteral("Pesquero");
    case ShipCategory::TugSpecial: return QStringLiteral("Remolcador / servicio");
    case ShipCategory::HighSpeed:  return QStringLiteral("Alta velocidad");
    case ShipCategory::Pleasure:   return QStringLiteral("Recreo / vela");
    case ShipCategory::Other:      return QStringLiteral("Otro");
    case ShipCategory::Unknown:    break;
    }
    return QStringLiteral("Desconocido");
}

QColor categoryColor(ShipCategory c)
{
    switch (c) {
    case ShipCategory::Cargo:      return QColor(0x2e, 0x9d, 0x4a);
    case ShipCategory::Tanker:     return QColor(0xd3, 0x3a, 0x2c);
    case ShipCategory::Passenger:  return QColor(0x2f, 0x6f, 0xdb);
    case ShipCategory::Fishing:    return QColor(0xe0, 0x8a, 0x1e);
    case ShipCategory::TugSpecial: return QColor(0x13, 0x9c, 0xad);
    case ShipCategory::HighSpeed:  return QColor(0xd4, 0xb1, 0x00);
    case ShipCategory::Pleasure:   return QColor(0xb0, 0x3f, 0xc4);
    case ShipCategory::Other:      return QColor(0x6e, 0x6e, 0x6e);
    case ShipCategory::Unknown:    break;
    }
    return QColor(0x9a, 0x9a, 0x9a);
}

QString shipTypeText(int t)
{
    QString text;
    switch (t) {
    case 0:  return QStringLiteral("No disponible");
    case 30: text = QStringLiteral("Pesquero"); break;
    case 31:
    case 32: text = QStringLiteral("Remolcando"); break;
    case 33: text = QStringLiteral("Dragado / obras submarinas"); break;
    case 34: text = QStringLiteral("Operaciones de buceo"); break;
    case 35: text = QStringLiteral("Operaciones militares"); break;
    case 36: text = QStringLiteral("Velero"); break;
    case 37: text = QStringLiteral("Embarcación de recreo"); break;
    case 50: text = QStringLiteral("Embarcación de práctico"); break;
    case 51: text = QStringLiteral("Búsqueda y salvamento"); break;
    case 52: text = QStringLiteral("Remolcador"); break;
    case 53: text = QStringLiteral("Lancha de servicio portuario"); break;
    case 54: text = QStringLiteral("Anticontaminación"); break;
    case 55: text = QStringLiteral("Fuerzas de seguridad"); break;
    case 58: text = QStringLiteral("Transporte sanitario"); break;
    case 59: text = QStringLiteral("Buque no combatiente"); break;
    default:
        if (t >= 20 && t <= 29)
            text = QStringLiteral("Ala en efecto suelo (WIG)");
        else
            text = categoryName(categoryFromType(t));
        break;
    }
    return QStringLiteral("%1 (%2)").arg(text).arg(t);
}

QString navStatusText(int s)
{
    switch (s) {
    case 0:  return QStringLiteral("Navegando con motor");
    case 1:  return QStringLiteral("Fondeado");
    case 2:  return QStringLiteral("Sin gobierno");
    case 3:  return QStringLiteral("Maniobrabilidad restringida");
    case 4:  return QStringLiteral("Restringido por su calado");
    case 5:  return QStringLiteral("Amarrado");
    case 6:  return QStringLiteral("Varado");
    case 7:  return QStringLiteral("Pescando");
    case 8:  return QStringLiteral("Navegando a vela");
    case 11: return QStringLiteral("Remolcando a popa");
    case 12: return QStringLiteral("Empujando / remolcando al costado");
    case 14: return QStringLiteral("AIS-SART / MOB / EPIRB activo");
    case 15: return QStringLiteral("No definido");
    default: return QStringLiteral("Reservado (%1)").arg(s);
    }
}

static QString formatCoord(double value, QChar pos, QChar neg, int degWidth)
{
    if (std::isnan(value))
        return QStringLiteral("—");
    const double a = std::abs(value);
    int deg = int(a);
    double min = (a - deg) * 60.0;
    if (min >= 59.9995) { // evita "60.000'"
        min = 0.0;
        ++deg;
    }
    return QStringLiteral("%1° %2' %3")
        .arg(deg, degWidth, 10, QLatin1Char('0'))
        .arg(min, 6, 'f', 3, QLatin1Char('0'))
        .arg(value < 0 ? neg : pos);
}

QString formatLatitude(double lat)
{
    return formatCoord(lat, QLatin1Char('N'), QLatin1Char('S'), 2);
}

QString formatLongitude(double lon)
{
    return formatCoord(lon, QLatin1Char('E'), QLatin1Char('O'), 3);
}

} // namespace Ais
