"""
redpitaya_io.py - Comunicación con el servidor de la Red Pitaya.

Protocolo: 1 byte de comando + 4 bytes de payload; ack de 1 byte salvo
CMD_READ_ADC, que responde con n_words*4 bytes de datos.

transmitir_y_recibir() es el flujo tipico de prueba: carga y arranca
una rafaga, espera a que termine de tocar, la detiene, y lee los bits
demodulados.
"""

import socket
import struct
import time
import numpy as np

CMD_READ_ADC = 0x03
CMD_SET_FIFO = 0x04
CMD_SET_CFG  = 0x05
CMD_TX_LOAD  = 0x06
CMD_TX_START = 0x07
CMD_TX_STOP  = 0x08

CMD_SET_UMBRALES = 0x20
CMD_SET_CFG3     = 0x21

PUNTO_SALIDA_NORMAL = 0
PUNTO_FIR           = 1
PUNTO_ROTADOR       = 2
PUNTO_SOFT          = 3
PUNTO_BIT_CRUDO     = 4

_NOMBRES_PUNTO_PRUEBA = {
    0: "salida normal", 1: "FIR (I/Q)", 2: "rotador (iq_corregido)",
    3: "soft[n]", 4: "bit_crudo (pre-NRZI)",
}

_modo_actual = 0
_sel_actual  = 0


def send_cmd(sock, cmd, payload):
    """Envía un comando (1 byte) + payload (4 bytes)."""
    sock.sendall(struct.pack('B', cmd))
    sock.sendall(struct.pack('I', payload))


def read_ack(sock):
    """Lee el byte de confirmacion del servidor."""
    return sock.recv(1)[0] == 0x01


def tx_load_and_start(sock, words):
    """Carga el buffer (array de enteros de 32 bits) al DDR y arranca la
    reproduccion en loop continuo."""
    send_cmd(sock, CMD_TX_LOAD, len(words))
    sock.sendall(words.astype(np.int32).tobytes())
    read_ack(sock)
    send_cmd(sock, CMD_TX_START, 0)
    read_ack(sock)


def tx_stop(sock):
    """Detiene la reproduccion del DAC."""
    send_cmd(sock, CMD_TX_STOP, 0)
    read_ack(sock)


def read_adc(sock, n_samples):
    """Resetea el FIFO de captura y lee n_samples muestras complejas
    (I + jQ) del ADC."""
    n_words = n_samples * 2
    send_cmd(sock, CMD_SET_FIFO, 0); read_ack(sock)
    send_cmd(sock, CMD_SET_FIFO, 1); read_ack(sock)
    send_cmd(sock, CMD_READ_ADC, n_words)
    raw = b''
    total = n_words * 4
    while len(raw) < total:
        raw += sock.recv(total - len(raw))
    w = struct.unpack(f'{n_words}i', raw)
    return np.array(w[0::2], float) + 1j * np.array(w[1::2], float)


def _palabras_a_bits(palabras):
    """Desempaqueta un iterable de palabras de 32 bits en un array de
    bits (MSB primero dentro de cada palabra), usado por
    leer_bits_demodulados()."""
    bits = []
    for word in palabras:
        w = word & 0xFFFFFFFF
        for b in range(31, -1, -1):
            bits.append((w >> b) & 1)
    return np.array(bits, dtype=np.uint8)


def leer_bits_demodulados(sock, n_words):
    """Lee n_words palabras de 32 bits de fifo_0 y las desempaqueta en
    un array de bits. Devuelve un array de 0/1 (numpy uint8)."""
    n_palabras = (n_words // 2) * 2
    send_cmd(sock, CMD_READ_ADC, n_palabras)
    raw = b''
    total = n_palabras * 4
    while len(raw) < total:
        raw += sock.recv(total - len(raw))
    w = struct.unpack(f'{n_palabras}i', raw)
    return _palabras_a_bits(w)


def leer_iq_crudo(sock, n_muestras):
    """Lee n_muestras IQ (cada una = 2 palabras de 32 bits, I y Q)
    desde el punto de prueba seleccionado (ver elegir_punto_prueba)."""
    raw = read_adc(sock, n_muestras)
    i = np.array([int(c.real) for c in raw], dtype=np.int64)
    q = np.array([int(c.imag) for c in raw], dtype=np.int64)
    return i, q


def leer_escalares_crudos(sock, n_palabras):
    """Lee n_palabras valores escalares de 32 bits desde el punto de
    prueba seleccionado. gmsk_pad32 ya hace la extensión de signo (o
    el relleno con cero) del lado del hardware"""
    raw = read_adc(sock, (n_palabras + 1) // 2)
    palabras = []
    for c in raw:
        palabras.append(int(c.real))
        palabras.append(int(c.imag))
    return np.array(palabras[:n_palabras], dtype=np.int64)


def veredicto(nombre, condicion, detalle):
    """Imprime un chequeo con formato [OK]/[FALLO] y devuelve la
    condicion (para poder encadenar/acumular resultados)."""
    estado = "OK" if condicion else "FALLO"
    print(f"  [{estado}] {nombre}: {detalle}")
    return condicion


def transmitir_y_recibir(sock, words, fs, n_words_lectura=32, margen=2.0,
                          espera_previa_s=0.05):
    """Transmite una rafaga (words, formato de
    construir_buffer_dac()/generar_senal_ais_prueba(), palabras de 14
    bits en dos's complement empaquetadas en enteros de 32) y lee de
    vuelta los bits demodulados. El flujo completo de una prueba:
    para el TX (por si estaba corriendo de antes), carga y arranca la
    rafaga, espera a que termine de tocar (con margen, dado que la
    cadena de recepcion completa tiene su propia latencia antes de
    que el ultimo bit real llegue a fifo_0), la detiene, y lee.

    fs: frecuencia de muestreo del DAC en Hz. 
    margen: factor multiplicativo sobre la duracion real de la rafaga 
    n_words_lectura: cuántas palabras de 32 bits pedir-"""
    tx_stop(sock)
    time.sleep(espera_previa_s)
    tx_load_and_start(sock, words)

    duracion_s = len(words) / fs
    time.sleep(duracion_s * margen + 0.02)

    bits = leer_bits_demodulados(sock, n_words_lectura)
    tx_stop(sock)
    return bits


def calcular_pinc_y_cfg(f_lo, fs, bits_acumulador=30):
    """Calcula la palabra de incremento de fase (PINC) del NCO del
    receptor y los dos valores de configuracion (reset / run) que espera
    CMD_SET_CFG."""
    pinc = round(f_lo / fs * (1 << bits_acumulador))
    cfg_val_reset = (pinc << 1) | 0
    cfg_val_run   = (pinc << 1) | 1
    return cfg_val_reset, cfg_val_run


def abrir_y_arrancar(host, port, words, cfg_val_reset, cfg_val_run):
    """Abre la conexión, carga el buffer, arranca el TX
    y deja el NCO del receptor configurado y corriendo."""
    s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    s.connect((host, port))
    s.setsockopt(socket.IPPROTO_TCP, socket.TCP_NODELAY, 1)
    tx_load_and_start(s, words)
    send_cmd(s, CMD_SET_CFG, cfg_val_reset); read_ack(s)
    send_cmd(s, CMD_SET_CFG, cfg_val_run);   read_ack(s)
    return s


def conectar_comandos(host, port):
    """Abre una conexión de comandos simple, sin ningún efecto de lado
    (no carga ni arranca TX, no toca el NCO). Para cuando hace falta
    una conexión de comandos propia, independiente de la que se haya
    usado (y quizás ya cerrado) en otra parte del notebook."""
    s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    s.connect((host, port))
    s.setsockopt(socket.IPPROTO_TCP, socket.TCP_NODELAY, 1)
    return s


def _escribir_cfg3(sock, sel=None, modo=None):
    """Arma y manda el payload de CMD_SET_CFG3. Mantiene sel/modo
    como estado (cambiar uno no resetea el otro), igual que el resto
    de los comandos de un solo bit de esta placa."""
    global _modo_actual, _sel_actual
    if sel is not None:
        _sel_actual = sel
    if modo is not None:
        _modo_actual = modo
    payload = (_sel_actual << 1) | _modo_actual
    send_cmd(sock, CMD_SET_CFG3, payload)
    read_ack(sock)


def elegir_punto_prueba(sock, punto, modo=0):
    """Cambia que señal llega al FIFO, sin resintetizar. modo=0 es
    lectura normal; modo=1 es calibración (magnitud cruda)."""
    _escribir_cfg3(sock, sel=punto, modo=modo)
    print(f"Punto de prueba -> {_NOMBRES_PUNTO_PRUEBA.get(punto, punto)}")


# ============================================================
# ADRF6850 - configuracion del front-end por SPI (comandos CMD_ADRF_*)
# ============================================================

CMD_ADRF_INIT      = 0x10
CMD_ADRF_UPDATE    = 0x11
CMD_ADRF_GET_STATE = 0x12
CMD_ADRF_SET_LO    = 0x13
CMD_ADRF_SET_GAIN  = 0x14

# mascaras de ADRF6850_UPD_* (adrf6850.h) para usar con adrf_update()
ADRF_UPD_LO     = 1 << 0
ADRF_UPD_GAIN   = 1 << 1
ADRF_UPD_BB     = 1 << 2
ADRF_UPD_LOMON  = 1 << 3
ADRF_UPD_CP     = 1 << 4
ADRF_UPD_ALL    = 0x1F

# adrf6850_bb_fc_t (CR29[5:4])
ADRF_BB_FC_50MHZ = 0
ADRF_BB_FC_43MHZ = 1
ADRF_BB_FC_37MHZ = 2
ADRF_BB_FC_30MHZ = 3

# adrf6850_lomon_pwr_t (CR27[1:0])
ADRF_LOMON_M24DBM = 0
ADRF_LOMON_M18DBM = 1
ADRF_LOMON_M12DBM = 2
ADRF_LOMON_M6DBM  = 3

_FMT_UPDATE = '<IIiBBBBBB'   # mask, lo_hz, gain_mdb, bb_wideband, bb_fc,
                             # lomon_en, lomon_pwr, cp_code, fast_hop
_FMT_STATE  = '<BIIBHIiHBBBB'  # initialized, lo_hz, lo_actual_hz, rfdiv,
                               # n_int, n_frac, gain_mdb, vgain_mv,
                               # bb_wideband, bb_fc, cp_code, autocal_off


def adrf_init(sock):
    """Corre adrf6850_init() completo (secuencia de power-up de la data
    sheet). Devuelve True si el PLL enganchó, False si no."""
    send_cmd(sock, CMD_ADRF_INIT, 0)
    return read_ack(sock)


def adrf_update(sock, mask, lo_hz=0, gain_mdb=0, bb_wideband=0, bb_fc=0,
                 lomon_en=0, lomon_pwr=0, cp_code=0, fast_hop=0):
    """Reconfiguracion general: solo se tocan los campos marcados en
    `mask` (OR de las constantes ADRF_UPD_*). Devuelve True/False."""
    wire = struct.pack(_FMT_UPDATE, mask, lo_hz, gain_mdb, bb_wideband,
                        bb_fc, lomon_en, lomon_pwr, cp_code, fast_hop)
    send_cmd(sock, CMD_ADRF_UPDATE, len(wire))
    sock.sendall(wire)
    return read_ack(sock)


def adrf_set_lo(sock, lo_hz):
    """Atajo: retunea el LO (100 MHz a 1000 MHz), dejando que la parte
    autocalibre."""
    send_cmd(sock, CMD_ADRF_SET_LO, int(lo_hz))
    return read_ack(sock)


def adrf_set_gain(sock, gain_mdb):
    """Atajo: ajusta la ganancia del VGA, en mili-dB (0 a 60000)."""
    send_cmd(sock, CMD_ADRF_SET_GAIN, int(gain_mdb) & 0xFFFFFFFF)
    return read_ack(sock)


def adrf_get_state(sock):
    """Lee el estado actual del dispositivo. Devuelve un dict con los
    mismos campos que adrf6850_state_t."""
    send_cmd(sock, CMD_ADRF_GET_STATE, 0)
    raw = b''
    total = struct.calcsize(_FMT_STATE)
    while len(raw) < total:
        chunk = sock.recv(total - len(raw))
        if not chunk:
            raise ConnectionError("conexion cerrada leyendo CMD_ADRF_GET_STATE")
        raw += chunk

    (initialized, lo_hz, lo_actual_hz, rfdiv, n_int, n_frac, gain_mdb,
     vgain_mv, bb_wideband, bb_fc, cp_code, autocal_off) = struct.unpack(_FMT_STATE, raw)

    return {
        'initialized':   bool(initialized),
        'lo_hz':         lo_hz,
        'lo_actual_hz':  lo_actual_hz,
        'rfdiv':         rfdiv,
        'n_int':         n_int,
        'n_frac':        n_frac,
        'gain_mdb':      gain_mdb,
        'vgain_mv':      vgain_mv,
        'bb_wideband':   bool(bb_wideband),
        'bb_fc':         bb_fc,
        'cp_code':       cp_code,
        'autocal_off':   bool(autocal_off),
    }