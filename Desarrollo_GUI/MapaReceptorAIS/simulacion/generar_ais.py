#!/usr/bin/env python3
"""
Genera mensajes AIS simulados en formato NMEA 0183 (!AIVDM) para probar la GUI.

Los buques recorren rutas cerradas en el Rio de la Plata. Cada ruta se recorre
un numero entero de veces durante el archivo, asi que al repetirlo en bucle el
movimiento es continuo (sin saltos).

Salida (en la carpeta de este script):
  ais_sim.nmea     sentencias !AIVDM; una linea "#" separa cada segundo de envio
  ais_sim.json     datos esperados de cada buque (para verificar el decodificador)

Mensajes incluidos (ITU-R M.1371):
  1  posicion clase A          18  posicion clase B
  5  datos estaticos clase A   24  datos estaticos clase B (partes A y B)
  4  estacion base (la GUI la ignora)
  y algunas sentencias con checksum invalido, que deben descartarse.

Uso:  python generar_ais.py [--segundos 1200] [--aceleracion 20]
"""
import argparse
import json
import math
import os

# ---------------------------------------------------------------------------
# Codificacion AIS
# ---------------------------------------------------------------------------

SIXBIT_TEXT = "@ABCDEFGHIJKLMNOPQRSTUVWXYZ[\\]^_ !\"#$%&'()*+,-./0123456789:;<=>?"


class Bits:
    def __init__(self):
        self.bits = []

    def u(self, value, n):
        value = int(value)
        if value < 0 or value >= (1 << n):
            raise ValueError(f"{value} no entra en {n} bits")
        self.bits += [(value >> (n - 1 - i)) & 1 for i in range(n)]
        return self

    def s(self, value, n):
        value = int(round(value))
        if not -(1 << (n - 1)) <= value < (1 << (n - 1)):
            raise ValueError(f"{value} no entra en {n} bits con signo")
        return self.u(value & ((1 << n) - 1), n)

    def text(self, string, nchars):
        string = string.upper()[:nchars].ljust(nchars, "@")
        for ch in string:
            self.u(SIXBIT_TEXT.index(ch) if ch in SIXBIT_TEXT else 0, 6)
        return self

    def armor(self):
        """Devuelve (payload, bits de relleno)."""
        fill = (-len(self.bits)) % 6
        bits = self.bits + [0] * fill
        out = []
        for i in range(0, len(bits), 6):
            v = int("".join(map(str, bits[i:i + 6])), 2)
            out.append(chr(v + 48 if v < 40 else v + 56))
        return "".join(out), fill


def nmea_checksum(body):
    cs = 0
    for ch in body:
        cs ^= ord(ch)
    return f"{cs:02X}"


_seq_id = 0


def to_sentences(bits, channel="A"):
    """Arma las sentencias !AIVDM (fragmenta si el payload supera 60 caracteres)."""
    global _seq_id
    payload, fill = bits.armor()
    chunks = [payload[i:i + 60] for i in range(0, len(payload), 60)]
    seq = ""
    if len(chunks) > 1:
        seq = str(_seq_id)
        _seq_id = (_seq_id + 1) % 10
    out = []
    for i, chunk in enumerate(chunks, 1):
        f = fill if i == len(chunks) else 0
        body = f"AIVDM,{len(chunks)},{i},{seq},{channel},{chunk},{f}"
        out.append(f"!{body}*{nmea_checksum(body)}")
    return out


def pos_units(deg):
    return round(deg * 600000)  # 1/10000 de minuto


def msg1(v, sec, status):
    b = Bits()
    b.u(1, 6).u(0, 2).u(v["mmsi"], 30).u(status, 4).u(128, 8)  # ROT no disponible
    b.u(min(1022, round(v["sog"] * 10)), 10).u(1, 1)
    b.s(pos_units(v["lon"]), 28).s(pos_units(v["lat"]), 27)
    b.u(round(v["cog"] * 10) % 3600 if v["sog"] > 0 else 3600, 12)
    b.u(v["heading"], 9).u(sec % 60, 6).u(0, 2).u(0, 3).u(0, 1).u(0, 19)
    return b


def msg5(v):
    b = Bits()
    b.u(5, 6).u(0, 2).u(v["mmsi"], 30).u(0, 2).u(v["imo"], 30)
    b.text(v["callsign"], 7).text(v["name"], 20).u(v["type"], 8)
    bow = v["length"] // 2
    port = v["beam"] // 2
    b.u(bow, 9).u(v["length"] - bow, 9).u(port, 6).u(v["beam"] - port, 6)
    b.u(1, 4)  # EPFD: GPS
    b.u(11, 4).u(20, 5).u(18, 5).u(0, 6)  # ETA: 20/11 18:00
    b.u(round(v["draught"] * 10), 8).text(v["destination"], 20).u(0, 1).u(0, 1)
    return b


def msg18(v, sec):
    b = Bits()
    b.u(18, 6).u(0, 2).u(v["mmsi"], 30).u(0, 8)
    b.u(min(1022, round(v["sog"] * 10)), 10).u(1, 1)
    b.s(pos_units(v["lon"]), 28).s(pos_units(v["lat"]), 27)
    b.u(round(v["cog"] * 10) % 3600, 12).u(v["heading"], 9).u(sec % 60, 6)
    b.u(0, 2).u(1, 1).u(0, 1).u(1, 1).u(1, 1).u(1, 1).u(0, 1).u(0, 1).u(0, 20)
    return b


def msg24a(v):
    return Bits().u(24, 6).u(0, 2).u(v["mmsi"], 30).u(0, 2).text(v["name"], 20)


def msg24b(v):
    b = Bits()
    b.u(24, 6).u(0, 2).u(v["mmsi"], 30).u(1, 2).u(v["type"], 8)
    b.text("SIM", 3).u(0, 4).u(0, 20)  # fabricante, modelo, serie
    b.text(v["callsign"], 7)
    bow = v["length"] // 2
    port = v["beam"] // 2
    b.u(bow, 9).u(v["length"] - bow, 9).u(port, 6).u(v["beam"] - port, 6)
    b.u(1, 4).u(0, 2)
    return b


def msg4(mmsi, lat, lon, sec):
    b = Bits()
    b.u(4, 6).u(0, 2).u(mmsi, 30).u(2026, 14).u(11, 4).u(20, 5).u(12, 5).u(0, 6).u(sec % 60, 6)
    b.u(1, 1).s(pos_units(lon), 28).s(pos_units(lat), 27).u(7, 4).u(0, 10).u(0, 1).u(0, 19)
    return b


# ---------------------------------------------------------------------------
# Escenario: rutas cerradas en el Rio de la Plata (lon, lat)
# ---------------------------------------------------------------------------

AGUA = [(-58.33, -34.57), (-58.05, -34.43), (-57.85, -34.52), (-57.40, -34.49), (-57.00, -34.60),
        (-57.00, -35.20), (-57.25, -35.22), (-57.85, -34.85), (-58.20, -34.70)]


def en_agua(lon, lat):
    dentro = False
    j = len(AGUA) - 1
    for i in range(len(AGUA)):
        xi, yi = AGUA[i]
        xj, yj = AGUA[j]
        if (yi > lat) != (yj > lat) and lon < (xj - xi) * (lat - yi) / (yj - yi) + xi:
            dentro = not dentro
        j = i
    return dentro


# MMSI con MID 701 (Argentina); los nombres son ficticios.
BUQUES = [
    dict(mmsi=701123450, name="RIO URUGUAY STAR", callsign="LW3401", imo=9412345, type=70, length=180,
         beam=30, draught=9.5, destination="BUENOS AIRES", clase="A", vueltas=1,
         ruta=[(-58.22, -34.63), (-57.90, -34.70), (-57.40, -34.83), (-57.10, -34.92),
               (-57.15, -34.98), (-57.45, -34.90), (-57.95, -34.75)]),
    dict(mmsi=701123461, name="CONDOR DEL PLATA", callsign="LW3402", imo=9423456, type=80, length=230,
         beam=40, draught=12.8, destination="LA PLATA", clase="A", vueltas=1,
         ruta=[(-57.85, -34.80), (-57.55, -34.72), (-57.30, -34.95), (-57.55, -34.96)]),
    dict(mmsi=701123472, name="COLONIA EXPRESS", callsign="LW3403", imo=9434567, type=40, length=78,
         beam=20, draught=2.6, destination="COLONIA", clase="A", vueltas=4,
         ruta=[(-58.27, -34.60), (-57.90, -34.52), (-57.88, -34.54), (-58.25, -34.62)]),
    dict(mmsi=701123483, name="DON JUAN PESCADOR", callsign="LW3404", imo=0, type=30, length=32,
         beam=8, draught=3.5, destination="MAR DEL PLATA", clase="A", vueltas=2,
         ruta=[(-57.25, -35.02), (-57.10, -35.00), (-57.08, -35.12), (-57.22, -35.12)]),
    dict(mmsi=701123494, name="REMOLCADOR TITAN", callsign="LW3405", imo=0, type=52, length=30,
         beam=11, draught=4.2, destination="DOCK SUD", clase="A", vueltas=3,
         ruta=[(-58.24, -34.62), (-58.10, -34.60), (-58.05, -34.66), (-58.18, -34.68)]),
    dict(mmsi=701123505, name="LAGUNA AZUL", callsign="LW3406", imo=9445678, type=60, length=120,
         beam=24, draught=4.8, destination="MONTEVIDEO", clase="A", vueltas=1,
         ruta=[(-58.20, -34.64), (-57.70, -34.60), (-57.20, -34.62), (-57.05, -34.70),
               (-57.30, -34.70), (-57.80, -34.66)]),
    dict(mmsi=701123516, name="ESTRELLA FUGAZ", callsign="LW3407", imo=0, type=36, length=12,
         beam=4, draught=1.9, destination="COLONIA", clase="B", vueltas=1,
         ruta=[(-57.95, -34.55), (-57.70, -34.55), (-57.70, -34.62), (-57.95, -34.62)]),
    dict(mmsi=701123527, name="VIENTO SUR", callsign="LW3408", imo=0, type=37, length=10,
         beam=3, draught=1.2, destination="SAN ISIDRO", clase="B", vueltas=2,
         ruta=[(-58.20, -34.60), (-58.10, -34.56), (-58.05, -34.60), (-58.15, -34.63)]),
    # Fondeados: posicion fija, estado 1 (fondeado)
    dict(mmsi=701123538, name="ATLANTIC PAMPA", callsign="LW3409", imo=9456789, type=84, length=250,
         beam=44, draught=13.9, destination="ZONA ALIJO", clase="A", fondeado=(-57.95, -34.62)),
    dict(mmsi=701123549, name="SANTA MARIA III", callsign="LW3410", imo=9467890, type=71, length=165,
         beam=27, draught=8.7, destination="ROSARIO", clase="A", fondeado=(-57.70, -34.67)),
]

ESTACION_BASE = dict(mmsi=7010001, lat=-34.585, lon=-58.365)  # cerca del puerto de Buenos Aires


def distancia_nm(a, b):
    lat_m = math.radians((a[1] + b[1]) / 2)
    dx = (b[0] - a[0]) * 60 * math.cos(lat_m)
    dy = (b[1] - a[1]) * 60
    return math.hypot(dx, dy)


def rumbo(a, b):
    lat_m = math.radians((a[1] + b[1]) / 2)
    dx = (b[0] - a[0]) * math.cos(lat_m)
    dy = b[1] - a[1]
    return (math.degrees(math.atan2(dx, dy)) + 360) % 360


def punto_en_ruta(ruta, distancia):
    """Posicion y rumbo a 'distancia' millas del inicio de una ruta cerrada."""
    tramos = [(ruta[i], ruta[(i + 1) % len(ruta)]) for i in range(len(ruta))]
    total = sum(distancia_nm(a, b) for a, b in tramos)
    d = distancia % total
    for a, b in tramos:
        largo = distancia_nm(a, b)
        if d <= largo:
            f = d / largo
            return (a[0] + (b[0] - a[0]) * f, a[1] + (b[1] - a[1]) * f), rumbo(a, b)
        d -= largo
    return tramos[-1][1], rumbo(*tramos[-1])


def main():
    ap = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("--segundos", type=int, default=1200, help="duracion del archivo en segundos de envio")
    ap.add_argument("--aceleracion", type=float, default=20.0,
                    help="segundos simulados por cada segundo de envio (para que se note el movimiento)")
    args = ap.parse_args()

    t_total_h = args.segundos * args.aceleracion / 3600.0
    for v in BUQUES:
        if "ruta" in v:
            ruta = v["ruta"]
            for i in range(len(ruta)):
                a, b = ruta[i], ruta[(i + 1) % len(ruta)]
                for f in (x / 20 for x in range(21)):  # vertices y 19 puntos intermedios de cada tramo
                    p = (a[0] + (b[0] - a[0]) * f, a[1] + (b[1] - a[1]) * f)
                    assert en_agua(*p), f"{v['name']}: el tramo {a}->{b} pasa por tierra en {p}"
            largo = sum(distancia_nm(v["ruta"][i], v["ruta"][(i + 1) % len(v["ruta"])])
                        for i in range(len(v["ruta"])))
            # Velocidad tal que se completen 'vueltas' recorridos exactos en el archivo
            v["sog"] = round(largo * v["vueltas"] / t_total_h, 1)
            v["largo_nm"] = largo
        else:
            v["sog"] = 0.0
            v["lon"], v["lat"] = v["fondeado"]
            v["cog"] = 0.0
            v["heading"] = 215

    lineas = []
    esperado = {}
    for t in range(args.segundos):
        horas = t * args.aceleracion / 3600.0
        for k, v in enumerate(BUQUES):
            if "ruta" in v:
                # La velocidad redondeada a 0,1 kn podria dejar un pequeno salto al repetir: se avanza
                # proporcionalmente al recorrido para cerrar exacto. Cada buque arranca en un punto
                # distinto de su ruta (fase) para que no salgan todos amontonados.
                fase = (k * 0.37) % 1.0
                d = v["largo_nm"] * (v["vueltas"] * t / args.segundos + fase)
                (lon, lat), cog = punto_en_ruta(v["ruta"], d)
                v["lon"], v["lat"], v["cog"] = lon, lat, cog
                v["heading"] = int(round(cog + (k % 3) - 1)) % 360
            canal = "A" if (t + k) % 2 == 0 else "B"
            seg = int(horas * 3600) % 60

            envia_pos = False
            if v["clase"] == "A":
                periodo = 10 if v["sog"] == 0 else 1
                if (t + k) % periodo == 0:
                    estado = 1 if v["sog"] == 0 else (7 if v["type"] == 30 else 0)
                    lineas += to_sentences(msg1(v, seg, estado), canal)
                    envia_pos = True
                # Datos estaticos: uno por segundo al arrancar, despues cada 30 s
                # (un transpondedor real los manda cada 6 minutos).
                if t % 30 == k % 30:
                    lineas += to_sentences(msg5(v), canal)
            else:
                if (t + k) % 3 == 0:
                    lineas += to_sentences(msg18(v, seg), canal)
                    envia_pos = True
                if t % 30 == k % 30:
                    lineas += to_sentences(msg24a(v), canal)
                    lineas += to_sentences(msg24b(v), canal)

            # Datos esperados: la primera posicion que efectivamente se envia
            if envia_pos and str(v["mmsi"]) not in esperado:
                esperado[str(v["mmsi"])] = dict(
                    name=v["name"], callsign=v["callsign"], imo=v["imo"], type=v["type"],
                    length=v["length"], beam=v["beam"], draught=v["draught"],
                    destination=v["destination"], clase=v["clase"], sog=v["sog"],
                    lat0=round(v["lat"], 5), lon0=round(v["lon"], 5))

        if t % 10 == 0:
            lineas += to_sentences(msg4(ESTACION_BASE["mmsi"], ESTACION_BASE["lat"], ESTACION_BASE["lon"], t))
        if t % 97 == 50:
            # Sentencia corrupta (checksum invalido): el decodificador debe descartarla
            buena = to_sentences(msg1(BUQUES[0], 0, 0))[0]
            lineas.append(buena[:-2] + ("00" if buena[-2:] != "00" else "11"))
        lineas.append("#")

    carpeta = os.path.dirname(os.path.abspath(__file__))
    with open(os.path.join(carpeta, "ais_sim.nmea"), "w", newline="\n") as f:
        f.write("\n".join(lineas) + "\n")
    with open(os.path.join(carpeta, "ais_sim.json"), "w", encoding="utf-8") as f:
        json.dump(dict(segundos=args.segundos, aceleracion=args.aceleracion,
                       estacion_base=ESTACION_BASE["mmsi"], buques=esperado), f, ensure_ascii=False, indent=1)

    n_sent = sum(1 for l in lineas if l.startswith("!"))
    print(f"{n_sent} sentencias en {args.segundos} s ({len(BUQUES)} buques, x{args.aceleracion:g})")
    for v in BUQUES:
        print(f"  {v['mmsi']}  {v['name']:<18} clase {v['clase']}  {v['sog']:5.1f} kn")


if __name__ == "__main__":
    main()
