"""
gmsk_tx_signal.py -- Generacion de senales de prueba tipo AIS (GMSK,
h=0.5, BT=0.4, siempre con NRZI) para enviar al DAC.

Dos variantes de trama:
  - construir_ranura()/generar_trama_bits(): ranura de largo fijo (224
    bits), SIN bit stuffing.
  - construir_ranura_stuffed()/generar_trama_bits_stuffed(): igual, pero
    con bit stuffing HDLC real aplicado a datos+FCS -- el largo de la
    ranura varia segun el contenido (el stuffing agrega bits), y el flag
    (01111110, seis unos seguidos) queda garantizado unico en el stream:
    nunca puede aparecer por azar dentro de los datos.

construir_buffer_dac() modula (gmskmod_bc real de GNU Radio) y empaqueta
para el DAC cualquiera de las dos, o cualquier otro stream de bits (por
ejemplo de generar_bits_aleatorios()) -- no le importa la estructura de
lo que recibe, solo lo codifica en NRZI y lo sube a RF.
generar_senal_ais_prueba() encadena generar_trama_bits_stuffed() +
construir_buffer_dac() en un solo llamado, para el caso de uso tipico
(armar todo lo que hace falta para transmitir una trama de prueba).

El destuffing y la delimitacion de trama (busqueda de flag, CRC del lado
receptor) NO estan aca -- eso es logica de decodificacion, se define en
el notebook que arma el receptor.
"""

import numpy as np
from gnuradio import gr, blocks, digital

# ---------------- estructura de la ranura de prueba ----------------
N_PREAMBULO = 24
START_FLAG = '01111110'
N_PAYLOAD = 168
N_FCS = 16
N_RANURA = N_PREAMBULO + len(START_FLAG) + N_PAYLOAD + N_FCS + len(START_FLAG)


def crc16_ccitt(bits):
    """FCS de AIS/HDLC: CRC-16 con polinomio x^16 + x^12 + x^5 + 1, MSB
    primero. Se usa aca solo para completar el campo FCS de la ranura de
    prueba que se transmite -- no para validar nada del lado receptor."""
    reg = 0xFFFF
    for b in bits:
        reg ^= (int(b) & 1) << 15
        if reg & 0x8000:
            reg = ((reg << 1) & 0xFFFF) ^ 0x1021
        else:
            reg = (reg << 1) & 0xFFFF
    return reg


def nrzi_encode(bits, estado_inicial=1):
    """Codifica NRZI: mantiene el nivel si el bit es 1, lo invierte si es
    0 (convencion AIS/HDLC)."""
    bits = np.asarray(bits, dtype=np.uint8)
    out = np.empty_like(bits)
    estado = estado_inicial
    for i, b in enumerate(bits):
        if b == 0:
            estado ^= 1
        out[i] = estado
    return out


def _fase_cierra(bits_secuencia):
    """True si la fase acumulada de esta secuencia (GMSK h=0.5) es
    multiplo de 2*pi -- condicion general, valida para cualquier largo de
    secuencia (a diferencia de 'cantidad de unos par', que solo alcanza
    cuando el largo es multiplo de 4)."""
    n_ones = int(np.sum(bits_secuencia))
    n = len(bits_secuencia)
    return (2 * n_ones - n) % 4 == 0


def construir_ranura(data):
    """Arma la ranura completa (training + flag + datos + FCS + flag) a
    partir del campo de datos. El training es todo ceros: una racha de
    ceros se convierte en 0101... alternado al maximo tras codificar en
    NRZI, que es lo que necesita el sincronismo de simbolo."""
    training = [0] * N_PREAMBULO
    start_flag = [int(c) for c in START_FLAG]
    fcs_val = crc16_ccitt(data)
    fcs = [(fcs_val >> (15 - k)) & 1 for k in range(16)]
    end_flag = [int(c) for c in START_FLAG]
    return training + start_flag + list(data) + fcs + end_flag


def generar_trama_bits(rng):
    """Sortea un campo de datos al azar hasta que la ranura, codificada
    en NRZI, cierre en fase al repetirse en loop. Devuelve
    (trama_completa, campo_de_datos) -- trama_completa son los bits
    LOGICOS (antes de NRZI); construir_buffer_dac() los codifica.
    """
    while True:
        data = list(rng.randint(0, 2, N_PAYLOAD))
        trama = construir_ranura(data)
        trama_arr = np.array(trama, dtype=np.uint8)

        n_ceros = len(trama_arr) - int(np.sum(trama_arr))
        if n_ceros % 2 != 0:
            continue   # el NRZI no volveria al mismo estado tras un periodo

        if not _fase_cierra(nrzi_encode(trama_arr)):
            continue   # la fase acumulada no seria multiplo de 2*pi

        break
    assert len(trama) == N_RANURA
    return trama, data


def bit_stuff(bits):
    """Bit stuffing HDLC: inserta un 0 despues de cada racha de 5 unos
    consecutivos. Garantiza que la unica racha de 6 unos seguidos en el
    stream transmitido es la del propio flag (01111110) -- por
    construccion, el flag no puede aparecer nunca dentro de los datos."""
    bits = np.asarray(bits, dtype=np.uint8)
    out = []
    unos = 0
    for b in bits:
        out.append(int(b))
        if b == 1:
            unos += 1
            if unos == 5:
                out.append(0)
                unos = 0
        else:
            unos = 0
    return np.array(out, dtype=np.uint8)


def construir_ranura_stuffed(data):
    """Arma la ranura con bit stuffing aplicado SOLO a datos+FCS -- el
    training y los flags nunca se stuffean (el stuffing protege
    justamente el contenido que, sin el, podria imitar al flag)."""
    training = [0] * N_PREAMBULO
    start_flag = [int(c) for c in START_FLAG]
    fcs_val = crc16_ccitt(data)
    fcs = [(fcs_val >> (15 - k)) & 1 for k in range(16)]
    end_flag = [int(c) for c in START_FLAG]

    datos_y_fcs = np.array(list(data) + fcs, dtype=np.uint8)
    datos_y_fcs_stuffed = bit_stuff(datos_y_fcs)

    return training + start_flag + list(datos_y_fcs_stuffed) + end_flag


def generar_trama_bits_stuffed(rng):
    """Sortea el campo de datos hasta que la ranura completa (con
    stuffing aplicado), codificada en NRZI, cierre en fase. El largo de
    la ranura VARIA de una trama a otra (el stuffing agrega bits segun
    el contenido). Devuelve (trama_completa, campo_de_datos), igual que
    generar_trama_bits()."""
    while True:
        data = list(rng.randint(0, 2, N_PAYLOAD))
        trama = construir_ranura_stuffed(data)
        trama_arr = np.array(trama, dtype=np.uint8)

        n_ceros = len(trama_arr) - int(np.sum(trama_arr))
        if n_ceros % 2 != 0:
            continue   # el NRZI no volveria al mismo estado tras un periodo

        if not _fase_cierra(nrzi_encode(trama_arr)):
            continue   # la fase acumulada no seria multiplo de 2*pi

        break
    return trama, data


def generar_bits_aleatorios(rng, n_bits):
    """Genera un stream de bits al azar de largo n_bits (sin ninguna
    estructura de trama -- ni training, ni flag, ni CRC), verificando que
    cierre en fase al codificarse en NRZI y modularse en loop. Sirve para
    probar las funciones de gmsk_demod (estimacion de CFO, recuperacion
    de reloj de simbolo, etc.) de forma generica, sin depender de la
    estructura de una trama AIS completa.

    Devuelve los bits LOGICOS (antes de NRZI); construir_buffer_dac() los
    codifica, igual que con generar_trama_bits().

    n_bits debe ser PAR: con n_bits impar las dos condiciones de cierre
    de fase (paridad de ceros + fase multiplo de 2*pi) son matematicamente
    incompatibles entre si -- nunca hay una secuencia que cumpla las dos,
    y la busqueda no terminaria nunca.
    """
    if n_bits % 2 != 0:
        raise ValueError(f"n_bits debe ser par (se pidio {n_bits}): con largo "
                          f"impar el cierre de fase en NRZI es imposible de lograr")

    while True:
        bits = rng.randint(0, 2, n_bits).astype(np.uint8)

        n_ceros = n_bits - int(np.sum(bits))
        if n_ceros % 2 != 0:
            continue

        if not _fase_cierra(nrzi_encode(bits)):
            continue

        break
    return bits


class TxGmsk(gr.top_block):
    """Corre gmskmod_bc de GNU Radio sobre una lista de bits y devuelve
    el baseband complejo. El map_bb es necesario: gmskmod_bc espera
    simbolos +-1, no bits 0/1."""

    def __init__(self, bits, sps, l_pulso, bt):
        gr.top_block.__init__(self, "tx_gmsk")
        self.src = blocks.vector_source_b(list(map(int, bits)), False)
        self.map = digital.map_bb([-1, 1])
        self.mod = digital.gmskmod_bc(int(sps), int(l_pulso), float(bt))
        self.sink = blocks.vector_sink_c()
        self.connect(self.src, self.map, self.mod, self.sink)

    def baseband(self):
        return np.array(self.sink.data(), dtype=np.complex64)


def construir_buffer_dac(bits_trama, fs, f_lo, offset, sps_tx, l_pulso, bt,
                          amplitud, tx_burst_samples):
    """Codifica en NRZI, modula y sube a la portadora un stream de bits
    LOGICOS cualquiera (una trama de generar_trama_bits(), o un stream
    generico de generar_bits_aleatorios(), o cualquier otro array de
    0/1) y lo empaqueta para el DAC (palabras de 14 bits en dos's
    complement, empaquetadas en enteros de 32 bits). No sabe ni le
    importa si `bits_trama` tiene estructura de trama AIS o no.

    La secuencia se modula 3 veces seguidas (ya codificada en NRZI) y se
    conserva la copia del medio, para que las colas del filtro gaussiano
    en los bordes sean las del propio loop -- asi el buffer cierra sin
    transitorio al repetirse. La portadora se ajusta a un numero entero
    de ciclos dentro del buffer por la misma razon. Quien haya generado
    `bits_trama` es responsable de que cierre en fase (ver
    generar_trama_bits()/generar_bits_aleatorios()).

    Devuelve (words, fc_ajustada, N_muestras, baseband_complejo).
    """
    ns = len(bits_trama)

    bits_codificados = nrzi_encode(np.tile(bits_trama, 3))

    tb = TxGmsk(list(bits_codificados), sps_tx, l_pulso, bt)
    tb.run()
    bb3 = tb.baseband().astype(np.complex128)
    k0 = ns * sps_tx
    bb = bb3[k0:k0 + ns * sps_tx]

    n = (len(bb) // tx_burst_samples) * tx_burst_samples
    bb = bb[:n]

    fc = f_lo + offset
    cycles = round(n * fc / fs)
    fc_adj = cycles * fs / n
    t = np.arange(n) / fs
    rf = np.real(bb * np.exp(1j * 2 * np.pi * fc_adj * t))
    rf_i16 = (rf / np.max(np.abs(rf)) * amplitud).astype(np.int16)
    words = (rf_i16.astype(np.int32) & 0x3FFF)
    return words, fc_adj, n, bb.astype(np.complex64)


def generar_senal_ais_prueba(rng, fs, f_lo, offset, sps_tx, l_pulso, bt,
                              amplitud, tx_burst_samples):
    """Genera una trama AIS de prueba completa (con NRZI y bit stuffing)
    y arma el buffer listo para el DAC, en un solo llamado -- encadena
    generar_trama_bits_stuffed() y construir_buffer_dac(). Es el caso de
    uso tipico: todo lo que hace falta para transmitir una trama de
    prueba, junto.

    Devuelve (words, fc_ajustada, N_muestras, baseband_complejo,
    bits_trama, payload) -- bits_trama y payload se devuelven ademas
    porque hacen falta despues, del lado del receptor, para contar
    errores de bit contra lo realmente transmitido.
    """
    bits_trama, payload = generar_trama_bits_stuffed(rng)
    words, fc_adj, n, bb = construir_buffer_dac(
        bits_trama, fs, f_lo, offset, sps_tx, l_pulso, bt,
        amplitud, tx_burst_samples)
    return words, fc_adj, n, bb, bits_trama, payload