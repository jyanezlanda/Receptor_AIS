"""
gmsk_ais_framing.py -- Delimitacion de trama AIS del lado del receptor:
busqueda del flag, destuffing HDLC, validacion de CRC.

Uso tipico:
    bits = rpio.leer_bits_demodulados(sock, n_words)
    tramas = buscar_tramas(bits)
    for datos in tramas:
        ... datos ya paso CRC, son los N_PAYLOAD bits del campo de
            datos, sin el stuffing ni los flags ...
"""

import numpy as np
from gmsk_tx_signal import START_FLAG, N_PAYLOAD, N_FCS, crc16_ccitt


def bit_destuff_avanzar(bits, i0, n_necesarios):
    """Destuffea HDLC a partir de la posicion i0 (justo despues de un
    flag), hasta juntar n_necesarios bits reales. Descarta cada 0
    que siga a una racha de 5 unos seguidos. Devuelve (bits_destuffed,
    posicion_final) o (None, None) si la racha de bits no cierra bien
    (por ejemplo, un stuffing inválido, señal de que el flag
    encontrado era una coincidencia falsa, no uno real)."""
    destuffed = []
    unos = 0
    i = i0
    n = len(bits)
    while len(destuffed) < n_necesarios:
        if i >= n:
            return None, None
        b = int(bits[i])
        if unos == 5:
            if b != 0:
                return None, None
            unos = 0
            i += 1
            continue
        destuffed.append(b)
        unos = unos + 1 if b == 1 else 0
        i += 1
    if unos == 5:
        if i >= n or int(bits[i]) != 0:
            return None, None
        i += 1
    return np.array(destuffed, dtype=np.uint8), i


def buscar_tramas(bits):
    """Busca el flag (01111110, o su version invertida, por si la
    polaridad de la señal quedo espejada en algun punto de la cadena)
    en cualquier posición del stream, destuffea lo que sigue, y valida
    el CRC contra el flag de cierre. Devuelve una lista de arrays de
    N_PAYLOAD bits (el campo de datos de cada trama que paso CRC),
    puede tener 0, 1, o varias entradas segun cuantas tramas genuinas
    y coincidencias falsas que igual pasen CRC haya en el stream."""

    flag = np.array([int(c) for c in START_FLAG], dtype=np.uint8)
    flag_inv = 1 - flag
    npat = len(flag)

    candidatos = []
    for i in range(len(bits) - npat + 1):
        if np.array_equal(bits[i:i+npat], flag):
            candidatos.append((i, False))
        elif np.array_equal(bits[i:i+npat], flag_inv):
            candidatos.append((i, True))

    resultados = []
    for i_flag, invertir in candidatos:
        bits_norm = (1 - bits) if invertir else bits

        datos_fcs, i_fin = bit_destuff_avanzar(bits_norm, i_flag + npat, N_PAYLOAD + N_FCS)
        if datos_fcs is None:
            continue
        if i_fin + npat > len(bits_norm) or not np.array_equal(bits_norm[i_fin:i_fin+npat], flag):
            continue

        datos = datos_fcs[:N_PAYLOAD]
        fcs_bits = datos_fcs[N_PAYLOAD:N_PAYLOAD+N_FCS]
        fcs_recibido = 0
        for bit in fcs_bits:
            fcs_recibido = (fcs_recibido << 1) | int(bit)
        if crc16_ccitt(datos) != fcs_recibido:
            continue

        resultados.append(datos)
    return resultados
