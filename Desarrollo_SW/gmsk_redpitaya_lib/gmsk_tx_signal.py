"""
gmsk_tx_signal.py -- Generacion de una senal de prueba tipo AIS (GMSK,
h=0.5, BT=0.4, con NRZI opcional, SIN bit stuffing) para enviar al DAC.

Arma una ranura con training + flag HDLC + datos + FCS + flag, la modula
con gmskmod_bc real de GNU Radio, y la empaqueta como palabras de 14 bits
listas para el DAC. Es del lado del transmisor de prueba unicamente: no
tiene ninguna relacion con como se demodula la senal despues.
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
    primero. """
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
    0 (convención AIS/HDLC)."""
    bits = np.asarray(bits, dtype=np.uint8)
    out = np.empty_like(bits)
    estado = estado_inicial
    for i, b in enumerate(bits):
        if b == 0:
            estado ^= 1
        out[i] = estado
    return out


def construir_ranura(data, nrzi_habilitado):
    """Arma la ranura completa (training + flag + datos + FCS + flag) a
    partir del campo de datos. El training es todo ceros si hay NRZI
    (una racha de ceros se convierte en 0101... alternado al maximo tras
    codificar, que es lo que necesita el sincronismo de simbolo), o
    alternado 0101... directo si no hay NRZI."""
    if nrzi_habilitado:
        training = [0] * N_PREAMBULO
    else:
        training = [i % 2 for i in range(N_PREAMBULO)]

    start_flag = [int(c) for c in START_FLAG]
    fcs_val = crc16_ccitt(data)
    fcs = [(fcs_val >> (15 - k)) & 1 for k in range(16)]
    end_flag = [int(c) for c in START_FLAG]
    return training + start_flag + list(data) + fcs + end_flag


def generar_trama_bits(rng, nrzi_habilitado):
    """Sortea un campo de datos al azar hasta que la ranura tengan una 
    cantidad par de unos. Condición para que el buffer cierre en fase 
    al repetirse en loop.
    Devuelve (trama_completa, campo_de_datos).
    """
    while True:
        data = list(rng.randint(0, 2, N_PAYLOAD))
        trama = construir_ranura(data, nrzi_habilitado)
        if sum(trama) % 2 != 0:
            continue
        if nrzi_habilitado and int(np.sum(nrzi_encode(np.array(trama)))) % 2 != 0:
            continue
        break
    assert len(trama) == N_RANURA
    return trama, data


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
                          amplitud, tx_burst_samples, nrzi_habilitado):
    """Modula la ranura, la sube a la portadora y la empaqueta para el
    DAC (palabras de 14 bits en dos's complement, empaquetadas en enteros
    de 32 bits).

    La ranura se modula 3 veces seguidas y se conserva la copia del medio, 
    para que las colas del filtro gaussiano en los bordes sean las del propio 
    loop. Así el buffer cierra sin transitorio al repetirse. 
    La portadora se ajusta a un número entero de ciclos dentro del buffer 
    por la misma razón.

    Devuelve (words, fc_ajustada, N_muestras, baseband_complejo).
    """
    ns = len(bits_trama)

    bits_para_modular = np.tile(bits_trama, 3)
    if nrzi_habilitado:
        bits_para_modular = nrzi_encode(bits_para_modular)

    tb = TxGmsk(list(bits_para_modular), sps_tx, l_pulso, bt)
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
