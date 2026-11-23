"""ais_frame.py -- Armado de tramas AIS a partir de los bits demodulados: el mismo algoritmo de ais_frame.c (ver ais_frame.h), para los
notebooks. Busca la bandera HDLC en la polaridad normal y en la invertida, destufea, verifica el FCS (CRC-16 X.25, residuo 0xF0B8) y
acepta la trama si el tipo (1 a 27), el largo y la alineacion a bytes son plausibles.

    rx = AisRx()
    tramas = rx.bits(bits)       # bits: iterable de 0/1 (por ejemplo r['bits']); devuelve las tramas completas de esta llamada
    rx.stats()                   # contadores, los mismos que los de ais_rx_t
"""

DATOS_MAX_BITS = 1008          # 5 ranuras
_MAX_CUERPO = DATOS_MAX_BITS + 16


def largo_ok(tipo, b):
    """True si b bits de datos es un largo plausible para el tipo de mensaje."""
    if tipo in (1, 2, 3, 4, 9, 11, 18, 22): return b == 168
    if tipo == 5: return b == 424
    if tipo in (6, 12): return 72 <= b <= 1008
    if tipo in (7, 13): return b in (72, 104, 136, 168)
    if tipo == 8: return 56 <= b <= 1008
    if tipo == 10: return b == 72
    if tipo == 14: return 40 <= b <= 1008
    if tipo == 15: return 88 <= b <= 160
    if tipo == 16: return b in (96, 144)
    if tipo == 17: return 80 <= b <= 816
    if tipo == 19: return b == 312
    if tipo == 20: return 72 <= b <= 160
    if tipo == 21: return 272 <= b <= 360
    if tipo == 23: return b == 160
    if tipo == 24: return b in (160, 168)
    if tipo == 25: return 40 <= b <= 168
    if tipo == 26: return 60 <= b <= 1008
    if tipo == 27: return b in (96, 168)
    return False


def _crc_x25(bits):
    reg = 0xFFFF
    for b in bits:
        fb = (reg & 1) ^ b
        reg >>= 1
        if fb:
            reg ^= 0x8408
    return reg


class AisRx:
    def __init__(self):
        self._e = [dict(buscando=True, reg=0, unos=0, bits=[]) for _ in range(2)]
        self._c = dict(bits=0, candidatas=0, fcs_malo=0, fcs_ok=0, descartadas=0, abortadas=0, tramas=0)
        self._pol = [dict(candidatas=0, fcs_malo=0, fcs_ok=0, descartadas=0, abortadas=0, tramas=0) for _ in range(2)]

    def reset(self):
        """Descarta la trama en curso (por ejemplo entre dos rafagas); conserva los contadores."""
        self._e = [dict(buscando=True, reg=0, unos=0, bits=[]) for _ in range(2)]

    def stats(self):
        """Contadores totales (las dos polaridades)."""
        return dict(self._c)

    def stats_senal(self):
        """Contadores de la polaridad que tiene la señal (la que acepta mas tramas; la normal si empatan): la otra solo encuentra banderas al reves dentro de
        los datos y arma candidatas de basura. 'bits' y 'tramas' son totales."""
        p = 1 if self._pol[1]['tramas'] > self._pol[0]['tramas'] else 0
        return dict(self._pol[p], bits=self._c['bits'], tramas=self._c['tramas'])

    def _cuenta(self, pol, campo):
        self._c[campo] += 1
        self._pol[pol][campo] += 1

    def _evaluar(self, e, pol, salida):
        cuerpo = e['bits']
        if len(cuerpo) < 6: return
        n = len(cuerpo) - 6                                   # el 0 y los cinco 1 de la bandera quedaron guardados
        if n < 16: return
        self._cuenta(pol, 'candidatas')
        if _crc_x25(cuerpo[:n]) != 0xF0B8:
            self._cuenta(pol, 'fcs_malo'); return
        self._cuenta(pol, 'fcs_ok')
        nd = n - 16
        if nd < 38 or nd % 8 or nd > DATOS_MAX_BITS:
            self._cuenta(pol, 'descartadas'); return
        logico = [cuerpo[(i & ~7) + 7 - (i & 7)] for i in range(nd)]      # cada byte sale con el bit menos significativo primero
        tipo = int(''.join(map(str, logico[0:6])), 2)
        if not largo_ok(tipo, nd):
            self._cuenta(pol, 'descartadas'); return
        mmsi = int(''.join(map(str, logico[8:38])), 2)
        logico += [0] * (-nd % 6)
        payload = ''.join(chr(v + 48 if v < 40 else v + 56) for v in (int(''.join(map(str, logico[k:k + 6])), 2) for k in range(0, len(logico), 6)))
        self._cuenta(pol, 'tramas')
        salida.append(dict(tipo=tipo, mmsi=mmsi, bits=nd, relleno=len(logico) - nd, invertida=pol, payload=payload))

    def bits(self, bits):
        salida, c = [], self._c
        for b0 in bits:
            c['bits'] += 1
            for pol in (0, 1):
                e = self._e[pol]; b = (int(b0) & 1) ^ pol
                if e['buscando']:
                    e['reg'] = ((e['reg'] << 1) | b) & 0xFF
                    if e['reg'] == 0x7E:
                        e['buscando'] = False; e['bits'] = []; e['unos'] = 0
                    continue
                if e['unos'] == 5:
                    e['unos'] = 0 if b == 0 else 6               # 0 de relleno, o sexto uno: bandera o aborto
                    continue
                if e['unos'] == 6:
                    if b == 0:                                     # bandera: cierra esta trama y abre la siguiente
                        self._evaluar(e, pol, salida); e['bits'] = []; e['unos'] = 0
                    else:                                          # siete unos: aborto, o el relleno de unos que sigue a una bandera (hasta 5 bits guardados)
                        if len(e['bits']) > 5: self._cuenta(pol, 'abortadas')
                        e['buscando'] = True; e['reg'] = 0xFF
                    continue
                if len(e['bits']) >= _MAX_CUERPO + 6:             # demasiado larga
                    self._cuenta(pol, 'abortadas'); e['buscando'] = True; e['reg'] = 0
                    continue
                e['bits'].append(b)
                e['unos'] = e['unos'] + 1 if b else 0
        return salida
