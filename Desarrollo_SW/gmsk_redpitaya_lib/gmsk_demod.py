"""
gmsk_demod.py -- Demodulacion GMSK pura.

Recibe IQ complejo ya en banda base (a la tasa del receptor) y entrega:
  - estimacion de offset de frecuencia (CFO)
  - recuperacion de fase/reloj de simbolo (Oerder & Meyr, ciega, no asistida
    por datos)
  - la salida del discriminador de FM
  - un stream de bits sincronizado
"""

import numpy as np
from gnuradio import gr, blocks, analog


def nrzi_decode(bits, estado_inicial=1):
    """Decodifica NRZI: bit logico = 1 si NO hubo transicion respecto del
    bit anterior, 0 si hubo transicion (convencion AIS/HDLC: un '0'
    logico produce una transicion, un '1' no). El primer bit decodificado
    usa `estado_inicial` como referencia para el bit anterior asumido.
    """
    bits = np.asarray(bits, dtype=np.uint8)
    prev = np.concatenate(([estado_inicial], bits[:-1]))
    return (bits == prev).astype(np.uint8)


def estimar_cfo_gmsk(iq, fs):
    """Estima el offset de frecuencia (CFO) de una senal GMSK h=0.5 por el
    metodo de la cuarta potencia: z**4 cancela en gran medida los saltos
    de fase de los datos y deja un tono asociado al offset de portadora,
    que se mide con una recta sobre la fase desenrollada.

    iq: IQ complejo en banda base. fs: tasa de muestreo del IQ [Hz].
    Devuelve el offset estimado en Hz.
    """
    z = np.asarray(iq, dtype=np.complex128)
    z = z - np.mean(z)
    mag = np.abs(z)
    keep = mag > (0.15 * np.max(mag) if mag.size else 0.0)
    if np.count_nonzero(keep) < 32:
        return 0.0

    idx_all = np.flatnonzero(keep)
    if len(idx_all) < 16:
        return 0.0
    jumps = np.where(np.diff(idx_all) > 1)[0]
    starts = np.r_[0, jumps + 1]
    ends = np.r_[jumps + 1, len(idx_all)]
    lengths = ends - starts
    k = int(np.argmax(lengths))
    idx = idx_all[starts[k]:ends[k]].astype(np.float64)
    if len(idx) < 16:
        return 0.0

    z4 = z[idx.astype(np.int64)] ** 4
    ph = np.unwrap(np.angle(z4))

    if len(idx) > 200:
        lo = int(0.05 * len(idx))
        hi = int(0.95 * len(idx))
        idx = idx[lo:hi]
        ph = ph[lo:hi]

    slope = np.polyfit(idx / fs, ph, 1)[0]
    return float(slope / (2.0 * np.pi * 4.0))


def recuperar_fase_simbolo(soft, sps):
    """Recuperacion de reloj de simbolo, metodo de la linea espectral
    (Oerder & Meyr): eleva al cuadrado la salida del discriminador y mide
    la fase de la componente que cae exactamente en la tasa de simbolo.
    No requiere ningun patron de bits conocido -- funciona igual sobre
    datos al azar que sobre training.

    soft: salida del discriminador de FM (array real). sps: muestras por
    simbolo. Devuelve tau en [0, 1), fraccion de un periodo de simbolo.
    """
    y = soft.astype(np.float64) ** 2
    n = np.arange(len(y))
    f0 = 1.0 / sps
    X = np.sum(y * np.exp(-1j * 2 * np.pi * f0 * n))
    return (-np.angle(X) / (2 * np.pi)) % 1.0


class ReceptorGmskCiego(gr.top_block):
    """Receptor GMSK feedforward: corrige CFO, discrimina en FM y deja la
    salida disponible para recuperar simbolos a cualquier fase de
    muestreo. 

    Uso tipico:
        rx = ReceptorGmskCiego(iq, fs, sps)
        rx.run()
        bits = rx.bits_sincronizados(nrzi_habilitado=True)
    """

    def __init__(self, iq, fs, sps):
        gr.top_block.__init__(self, "receptor_gmsk_ciego", catch_exceptions=True)
        self.fs = fs
        self.sps = sps
        self.iq = np.asarray(iq, dtype=np.complex64)

        self.offset_est = estimar_cfo_gmsk(self.iq, fs)
        self.rot = blocks.rotator_cc(-2 * np.pi * self.offset_est / fs)

        sensitivity = (np.pi / 2) / sps
        self.fmdemod = analog.quadrature_demod_cf(1.0 / sensitivity)

        self.soft_sink = blocks.vector_sink_f()
        self.src = blocks.vector_source_c(
            [complex(x) for x in self.iq.astype(np.complex64)], False)

        self.connect(self.src, self.rot, self.fmdemod, self.soft_sink)

    def soft(self):
        """Salida cruda del discriminador de FM (una muestra por muestra
        de IQ, no por simbolo)."""
        return np.array(self.soft_sink.data(), dtype=np.float32)

    def bits_con_tau(self, tau):
        """Muestrea la salida del discriminador con la fase de simbolo
        `tau` dada, y devuelve (bits_crudos, symbols, positions):
          - bits_crudos: decision dura (0/1) por simbolo, SIN decodificar
            NRZI, umbral = mediana de todos los simbolos de la captura.
          - symbols: valor blando (soft) en cada instante de muestreo.
          - positions: posicion (en muestras) de cada simbolo dentro de
            `soft()`.
        Sirve como bloque de construccion para quien necesite re-estimar
        tau localmente (por ejemplo, sobre una ventana de training) y
        volver a muestrear.
        """
        soft = self.soft()
        f = self._interp(soft)
        n_symbols = int((len(soft) - tau * self.sps) / self.sps)
        positions = tau * self.sps + np.arange(n_symbols) * self.sps
        symbols = f(positions)
        dc = np.median(symbols)
        bits_crudos = (symbols - dc > 0).astype(np.uint8)
        return bits_crudos, symbols, positions

    def bits_sincronizados(self, nrzi_habilitado=True):
        """Salida estandar de esta libreria: recupera tau de forma ciega
        (global, sobre toda la captura) y devuelve el stream de bits ya
        sincronizado -- decodificado en NRZI si corresponde. No busca
        ningun flag ni valida nada de estructura de trama; el stream
        completo (training, datos, lo que sea) sale tal cual.
        """
        soft = self.soft()
        tau = recuperar_fase_simbolo(soft, self.sps)
        bits_crudos, symbols, positions = self.bits_con_tau(tau)
        if nrzi_habilitado:
            return nrzi_decode(bits_crudos)
        return bits_crudos

    @staticmethod
    def _interp(soft):
        from scipy.interpolate import interp1d
        return interp1d(np.arange(len(soft)), soft, kind='linear',
                         fill_value='extrapolate')
