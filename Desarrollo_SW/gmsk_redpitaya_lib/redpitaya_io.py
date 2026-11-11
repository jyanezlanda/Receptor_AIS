"""
redpitaya_io.py - Cliente de los servidores de la Red Pitaya: datos (adc_server, puerto 1003) y ADRF6850 (adrf_server, puerto 1005).

Protocolo: 1 byte de comando + 4 bytes de payload; ack de 1 byte salvo
CMD_READ_ADC, que responde con n_words*4 bytes de datos.

elegir_salida() / leer_iq() eligen entre la salida demodulada y el IQ crudo del FIR.

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

CMD_SET_SALIDA = 0x22   # que le llega al FIFO: 0 = salida demodulada, 1 = IQ crudo del FIR

SALIDA_DEMODULADA = 0   # bits demodulados, despues del squelch (operacion normal)
SALIDA_IQ         = 1   # I y Q del FIR: sin demodular y sin squelch

# Tasa de las muestras IQ: salida del CIC (R = 651) y del FIR (sin decimacion) a 125 MHz.
FS_IQ_HZ = 125e6 / 651   # ~192,012 kHz: una muestra cada ~5,21 us

# Alias de los puntos de prueba, para el codigo que importa estos nombres. Solo PUNTO_SALIDA_NORMAL y PUNTO_FIR tienen una
# salida asociada; elegir_punto_prueba() rechaza los demas.
PUNTO_SALIDA_NORMAL = SALIDA_DEMODULADA
PUNTO_FIR           = SALIDA_IQ
PUNTO_ROTADOR       = 2   # sin salida asociada
PUNTO_SOFT          = 3   # sin salida asociada
PUNTO_BIT_CRUDO     = 4   # sin salida asociada


def send_cmd(sock, cmd, payload):
    """Envía un comando (1 byte) + payload (4 bytes)."""
    sock.sendall(struct.pack('B', cmd))
    sock.sendall(struct.pack('I', payload))


def _recibir_exacto(sock, n_bytes):
    """Recibe exactamente n_bytes; levanta ConnectionError si el servidor cierra la conexion."""
    partes, falta = [], n_bytes
    while falta > 0:
        chunk = sock.recv(min(falta, 1 << 20))
        if not chunk:
            raise ConnectionError("el servidor cerro la conexion en medio de una lectura")
        partes.append(chunk)
        falta -= len(chunk)
    return b''.join(partes)


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


def vaciar_fifo(sock):
    """Descarta lo que haya en el FIFO de salida (SET_FIFO 0 y 1): la lectura siguiente trae solo flujo posterior."""
    send_cmd(sock, CMD_SET_FIFO, 0); read_ack(sock)
    send_cmd(sock, CMD_SET_FIFO, 1); read_ack(sock)


def read_adc(sock, n_samples):
    """Resetea el FIFO de captura y lee n_samples muestras complejas
    (I + jQ) del ADC."""
    n_words = n_samples * 2
    send_cmd(sock, CMD_SET_FIFO, 0); read_ack(sock)
    send_cmd(sock, CMD_SET_FIFO, 1); read_ack(sock)
    send_cmd(sock, CMD_READ_ADC, n_words)
    raw = _recibir_exacto(sock, n_words * 4)
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
    un array de bits. Devuelve un array de 0/1 (numpy uint8). No vacia
    el FIFO: entrega lo mas viejo que haya; para flujo reciente, llamar
    antes a vaciar_fifo()."""
    n_palabras = (n_words // 2) * 2
    send_cmd(sock, CMD_READ_ADC, n_palabras)
    raw = _recibir_exacto(sock, n_palabras * 4)
    w = struct.unpack(f'{n_palabras}i', raw)
    return _palabras_a_bits(w)


def leer_iq_crudo(sock, n_muestras):
    """Lee n_muestras IQ (cada una = 2 palabras de 32 bits, I y Q) de la salida que este seleccionada: hay que haber
    elegido SALIDA_IQ antes. Para elegirla automaticamente y restaurar la salida demodulada al terminar, usar leer_iq()."""
    raw = read_adc(sock, n_muestras)
    i = np.array([int(c.real) for c in raw], dtype=np.int64)
    q = np.array([int(c.imag) for c in raw], dtype=np.int64)
    return i, q


def elegir_salida(sock, salida):
    """Elige que le llega al FIFO de lectura, sin resintetizar: 'demodulada' / SALIDA_DEMODULADA (bits, despues del
    squelch) o 'iq' / SALIDA_IQ (I y Q del FIR, sin demodular ni squelch). Despues de cambiar vacia el FIFO (SET_FIFO 0 y
    1), para que no queden palabras de la salida anterior."""
    if isinstance(salida, str):
        salida = {'demodulada': SALIDA_DEMODULADA, 'iq': SALIDA_IQ}.get(salida.lower(), salida)
    if salida not in (SALIDA_DEMODULADA, SALIDA_IQ):
        raise ValueError(f"salida invalida {salida!r}: usar 'demodulada' / SALIDA_DEMODULADA o 'iq' / SALIDA_IQ")
    send_cmd(sock, CMD_SET_SALIDA, salida)
    if not read_ack(sock):
        raise RuntimeError("el servidor no soporta CMD_SET_SALIDA")
    send_cmd(sock, CMD_SET_FIFO, 0); read_ack(sock)
    send_cmd(sock, CMD_SET_FIFO, 1); read_ack(sock)


def leer_iq(sock, n_muestras, como_complejo=False, restaurar=True):
    """Pone la salida en IQ, vacia el FIFO y lee n_muestras muestras. Devuelve (i, q) como arrays int64, tal cual salen
    del FIR (sin escalar), o I + jQ como complejo (float64) si como_complejo=True.

    Es la salida que NO pasa por el squelch ni por la demodulacion: sirve para medir el piso de ruido sin senal y para
    pruebas con un tono sin modular. Las muestras estan separadas 1/FS_IQ_HZ (~5,2 us) y son contiguas mientras la
    lectura mantenga el ritmo del FIFO (de 16 palabras: ~42 us de margen). Con restaurar=True (por defecto) deja la
    salida demodulada al terminar, para que leer_bits_demodulados() no lea IQ por error.

    Limitacion: el reset del FIFO no esta sincronizado con el par I/Q; si se libera justo entre la I y la Q de una
    muestra (estimado: ~1 captura de cada 650), la captura empieza en Q y I y Q quedan intercambiadas. Con un tono
    conocido se nota porque el signo de su frecuencia sale invertido."""
    elegir_salida(sock, SALIDA_IQ)
    try:
        z = read_adc(sock, n_muestras)       # resetea el FIFO y lee 2 * n palabras: I, Q, I, Q...
    finally:
        if restaurar:
            try:
                elegir_salida(sock, SALIDA_DEMODULADA)
            except (OSError, RuntimeError):
                pass          # si la lectura fallo por la conexion, no tapar el error original
    if como_complejo:
        return z
    return z.real.astype(np.int64), z.imag.astype(np.int64)


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
    rafaga, vacia el FIFO, espera a que termine de tocar (con margen,
    dado que la cadena de recepcion completa tiene su propia latencia
    antes de que el ultimo bit real llegue a fifo_0), la detiene, y lee.

    fs: frecuencia de muestreo del DAC en Hz. 
    margen: factor multiplicativo sobre la duracion real de la rafaga 
    n_words_lectura: cuántas palabras de 32 bits pedir-"""
    tx_stop(sock)
    time.sleep(espera_previa_s)
    tx_load_and_start(sock, words)
    vaciar_fifo(sock)                       # la lectura trae solo lo demodulado desde el arranque

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


def elegir_punto_prueba(sock, punto, modo=0):
    """PUNTO_SALIDA_NORMAL elige la salida demodulada y PUNTO_FIR el IQ. Cualquier otro punto, o modo != 0, levanta
    ValueError. Preferir elegir_salida()."""
    if modo != 0:
        raise ValueError("modo != 0: el hardware no tiene salida de magnitud")
    if punto not in (PUNTO_SALIDA_NORMAL, PUNTO_FIR):
        raise ValueError(f"el punto de prueba {punto} no tiene salida asociada: solo 0 (demodulada) y 1 (IQ); ver elegir_salida()")
    elegir_salida(sock, punto)
    print(f"Salida -> {'demodulada' if punto == SALIDA_DEMODULADA else 'IQ crudo (FIR)'}")


# ---------------------------------------------------------------------------------------------------------------
# VGAIN del ADRF6850 por el DAC. El buffer de TX lleva dos canales de 14 bits en complemento a dos: el A (OUT1) en los
# bits 13:0, con la senal de prueba, y el B (OUT2) en los bits 29:16. Un buffer de valor constante en el canal B da una
# continua en OUT2, que se conecta a J2 (VGAIN).
# ---------------------------------------------------------------------------------------------------------------
DAC_CODIGO_MAX   = 8191          # codigo maximo de 14 bits con signo
DAC_V_FS         = 1.0           # V que suma el codigo maximo, con la carga de VGAIN (20 kohm); se mide con ajustar_dac()
DAC_V_OFFSET     = 0.0           # V con el codigo 0
VGAIN_MAX_MV     = 1500          # rango de VGAIN: 0 a 1,5 V
VGAIN_N_PALABRAS = 1024          # largo del buffer de nivel continuo (multiplo de 32)


def vgain_mv_a_codigo(mv, v_fs=None, v_offset=None):
    """Codigo del DAC para mv milivoltios en VGAIN. Se limita a 0..VGAIN_MAX_MV y al fondo de escala del DAC; nunca da una
    tension negativa (el minimo absoluto del pin es -0,3 V)."""
    v_fs = DAC_V_FS if v_fs is None else v_fs
    v_offset = DAC_V_OFFSET if v_offset is None else v_offset
    v = min(max(mv, 0.0), VGAIN_MAX_MV) / 1000.0
    return int(min(max(round((v - v_offset) / v_fs * DAC_CODIGO_MAX), 0), DAC_CODIGO_MAX))


def vgain_max_alcanzable_mv():
    """VGAIN maximo que da el DAC con la calibracion actual (limitado a VGAIN_MAX_MV)."""
    return min((DAC_V_OFFSET + DAC_V_FS) * 1000.0, VGAIN_MAX_MV)


def con_vgain(words, mv):
    """Agrega el nivel de VGAIN (canal B) a un buffer de TX que trae la senal en el canal A."""
    a = np.asarray(words, dtype=np.int64) & 0x3FFF
    return (a | (vgain_mv_a_codigo(mv) << 16)).astype(np.int32)


def set_vgain_mv(sock, mv, reiniciar=True):
    """Pone VGAIN en mv milivoltios y devuelve el codigo del DAC. Con reiniciar=True carga un buffer de nivel continuo y
    arranca el TX (reemplaza lo que hubiera). Con reiniciar=False solo recarga el buffer, sin parar el TX: cambia el nivel
    cuando el TX ya corre con un buffer del mismo largo."""
    codigo = vgain_mv_a_codigo(mv)
    words = np.full(VGAIN_N_PALABRAS, codigo << 16, dtype=np.int32)
    if reiniciar:
        tx_load_and_start(sock, words)
    else:
        send_cmd(sock, CMD_TX_LOAD, len(words))
        sock.sendall(words.tobytes())
        read_ack(sock)
    return codigo


def ajustar_dac(codigos, tensiones):
    """Ajusta tension = v_offset + v_fs * codigo / DAC_CODIGO_MAX con las mediciones del tester y devuelve (v_fs, v_offset),
    los valores para DAC_V_FS y DAC_V_OFFSET."""
    pendiente, offset = np.polyfit(np.asarray(codigos, float), np.asarray(tensiones, float), 1)
    return pendiente * DAC_CODIGO_MAX, offset


# ============================================================
# ADRF6850 - configuracion del front-end por SPI (comandos CMD_ADRF_*)
# ============================================================

CMD_ADRF_INIT      = 0x10
CMD_ADRF_UPDATE    = 0x11
CMD_ADRF_GET_STATE = 0x12
CMD_ADRF_SET_LO    = 0x13
CMD_ADRF_SET_GAIN  = 0x14
CMD_ADRF_READ_REG  = 0x15          # lee un registro por SDO
CMD_ADRF_INIT_CFG  = 0x16          # init con la configuracion del cliente
CMD_ADRF_GET_CONF  = 0x17          # trae la configuracion del .conf del servidor
CMD_ADRF_GET_VERIFY = 0x18         # resultado de la verificacion de escrituras de la ultima operacion
CMD_ADRF_VGAIN_RAW = 0x19          # codigo del DAC de VGAIN sin conversion (servidor con -d)
CMD_ADRF_GET_VGAIN = 0x1A          # codigo y tensiones de VGAIN (servidor con -d)
ADRF_REG_MAX       = 33            # CR33 (codigo de revision) es el ultimo registro

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
    """Inicializa el ADRF con el .conf del servidor (secuencia de power-up de la hoja de datos). Devuelve True si el
    driver termino sin error y False si no (por ejemplo, una escritura que no verifico: ver adrf_get_verify). No confirma
    el enganche del PLL: LDET no llega a la Red Pitaya."""
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


def _recv_exacto(sock, n):
    """Lee exactamente n bytes (o levanta ConnectionError si se corta la conexion)."""
    datos = b''
    while len(datos) < n:
        chunk = sock.recv(n - len(datos))
        if not chunk:
            raise ConnectionError("conexion cerrada esperando la respuesta del servidor")
        datos += chunk
    return datos


def adrf_read_reg(sock, addr):
    """Lee un registro del ADRF6850 por SDO (addr 0 a 33) y devuelve el byte. Llamarla despues de adrf_init(): en modo I2C
    el valor no vale. ValueError si el servidor rechaza la direccion; RuntimeError si no soporta la lectura."""
    send_cmd(sock, CMD_ADRF_READ_REG, int(addr))
    primero = _recv_exacto(sock, 1)
    if primero[0] == 0x01:
        return _recv_exacto(sock, 1)[0]
    # 0x00: si la direccion no existe el servidor manda [0x00, 0x00]; si no conoce el comando manda un solo 0x00.
    timeout_orig = sock.gettimeout()
    sock.settimeout(0.5)
    try:
        _recv_exacto(sock, 1)
    except (socket.timeout, ConnectionError):
        raise RuntimeError("el servidor no soporta CMD_ADRF_READ_REG")
    finally:
        sock.settimeout(timeout_orig)
    raise ValueError(f"el servidor rechazo la lectura del registro CR{addr} (direccion valida: 0 a {ADRF_REG_MAX})")


# ---------------------------------------------------------------------------------------------------------------
# Configuracion del ADRF desde el cliente. Las claves son las del adrf6850.conf: el diccionario de adrf_get_conf()
# sirve tal cual para adrf_init_cfg().
# ---------------------------------------------------------------------------------------------------------------
ADRF_CLAVES_CONF = ("bb_wideband", "bb_fc_mhz", "cp_code", "lomon_en", "lomon_pwr_dbm", "gain_mdb", "refin_hz",
                    "ref_doblador", "ref_div2", "ref_rdiv_en", "ref_rdiv", "vocm_interno", "vga_pendiente",
                    "muxout", "autocal_us", "lock_timeout_us", "verify_retries")   # + (lo_hz) o (f_rf_hz, f_fi_hz, corr_ppm)
_FC_A_COD = {50: 0, 43: 1, 37: 2, 30: 3}
_COD_A_FC = {v: k for k, v in _FC_A_COD.items()}
_PWR_A_COD = {-24: 0, -18: 1, -12: 2, -6: 3}
_COD_A_PWR = {v: k for k, v in _PWR_A_COD.items()}
_ADRF_CFG_BYTES, _ADRF_CONF_BYTES, _ADRF_VGAIN_BYTES = 33, 54, 6
_FMT_CFG = '<I7BIIIi6B'      # = adrf6850_config_t en el cable (33 bytes), ver adrf_server.c


def adrf_lo_desde_cfg(cfg):
    """LO que se le pide al ADRF: 'lo_hz' si la configuracion lo trae; si no, (f_rf_hz - f_fi_hz) corregido por corr_ppm y
    redondeado al mas cercano (igual que el servidor al leer el .conf)."""
    if cfg.get("lo_hz"):
        return int(cfg["lo_hz"])
    return int((cfg["f_rf_hz"] - cfg["f_fi_hz"]) / (1 + cfg.get("corr_ppm", 0.0) * 1e-6) + 0.5)


def _cfg_a_bytes(cfg):
    faltan = [k for k in ADRF_CLAVES_CONF if k not in cfg]
    if faltan or ("lo_hz" not in cfg and not all(k in cfg for k in ("f_rf_hz", "f_fi_hz"))):
        raise KeyError(f"a la configuracion le faltan claves: {faltan or ['lo_hz (o f_rf_hz y f_fi_hz)']}")
    return struct.pack(_FMT_CFG, int(cfg["refin_hz"]), int(cfg["ref_doblador"]), int(cfg["ref_div2"]),
                       int(cfg["ref_rdiv_en"]), int(cfg["ref_rdiv"]), int(cfg["vocm_interno"]),
                       int(cfg["vga_pendiente"]), int(cfg["muxout"]), int(cfg["autocal_us"]),
                       int(cfg["lock_timeout_us"]), adrf_lo_desde_cfg(cfg), int(cfg["gain_mdb"]),
                       int(cfg["bb_wideband"]), _FC_A_COD[int(cfg["bb_fc_mhz"])], int(cfg["cp_code"]),
                       int(cfg["lomon_en"]), _PWR_A_COD[int(cfg["lomon_pwr_dbm"])], int(cfg["verify_retries"]))


def adrf_init_cfg(sock, cfg):
    """Inicializa el ADRF con la configuracion del cliente (diccionario con las claves del .conf), sin leer ningun .conf.
    Devuelve True si el init salio bien y False si el servidor lo rechazo o fallo. Va en dos pasos: el servidor confirma que
    entiende el comando antes de recibir los datos; si no lo entiende (RuntimeError), la configuracion no se manda."""
    datos = _cfg_a_bytes(cfg)                 # si falta una clave, falla antes de mandar nada
    send_cmd(sock, CMD_ADRF_INIT_CFG, len(datos))
    if _recv_exacto(sock, 1)[0] != 0x01:
        raise RuntimeError("el servidor no acepta CMD_ADRF_INIT_CFG")
    sock.sendall(datos)
    return _recv_exacto(sock, 1)[0] == 0x01


def adrf_get_conf(sock):
    """Trae la configuracion que el servidor leyo de su .conf (-c), como diccionario con las claves del .conf, listo para
    adrf_init_cfg. Agrega 'lo_hz' (el LO ya calculado), '_lo_explicito' y '_crc32' (CRC-32 del archivo).
    ValueError si el servidor no tiene .conf; RuntimeError si no soporta el comando."""
    send_cmd(sock, CMD_ADRF_GET_CONF, 0)
    if _recv_exacto(sock, 1)[0] != 0x01:
        # sin .conf el servidor manda ademas ceros hasta completar la respuesta; si no conoce el comando manda un solo 0x00
        timeout_orig = sock.gettimeout()
        sock.settimeout(0.5)
        try:
            _recv_exacto(sock, _ADRF_CONF_BYTES)
        except (socket.timeout, ConnectionError):
            raise RuntimeError("el servidor no soporta CMD_ADRF_GET_CONF")
        finally:
            sock.settimeout(timeout_orig)
        raise ValueError("el servidor no tiene un .conf cargado (arrancarlo con -c archivo.conf)")
    d = _recv_exacto(sock, _ADRF_CONF_BYTES)
    (refin, dob, div2, rdiv_en, rdiv, vocm, vgapol, mux, autocal, locko, lo, gain,
     bbw, bbfc, cp, lomon_en, lomon_pwr, verificar) = struct.unpack(_FMT_CFG, d[:_ADRF_CFG_BYTES])
    f_rf, f_fi, ppm, lo_expl, crc = struct.unpack('<IIdBI', d[_ADRF_CFG_BYTES:])
    return dict(refin_hz=refin, ref_doblador=dob, ref_div2=div2, ref_rdiv_en=rdiv_en, ref_rdiv=rdiv,
                vocm_interno=vocm, vga_pendiente=vgapol, muxout=mux, autocal_us=autocal, lock_timeout_us=locko,
                lo_hz=lo, gain_mdb=gain, bb_wideband=bbw, bb_fc_mhz=_COD_A_FC[bbfc], cp_code=cp, lomon_en=lomon_en,
                lomon_pwr_dbm=_COD_A_PWR[lomon_pwr], verify_retries=verificar, f_rf_hz=f_rf, f_fi_hz=f_fi, corr_ppm=ppm,
                _lo_explicito=bool(lo_expl), _crc32=crc)


def adrf_get_verify(sock):
    """Resultado de la verificacion de escrituras de la ultima operacion que escribio registros (init, update o set_lo),
    como diccionario: 'writes' (escrituras verificadas), 'retries' (reintentos: errores del enlace detectados y
    corregidos), 'failures' (escrituras que no verificaron ni con los reintentos) y, de la ultima falla, 'fail_addr',
    'fail_wrote' y 'fail_read'. Con verify_retries = 0 todo es cero. RuntimeError si el servidor no soporta el comando."""
    send_cmd(sock, CMD_ADRF_GET_VERIFY, 0)
    if _recv_exacto(sock, 1)[0] != 0x01:
        raise RuntimeError("el servidor no soporta CMD_ADRF_GET_VERIFY")
    escrituras, reintentos, fallas, fa, fw, fr = struct.unpack('<IIIBBB', _recv_exacto(sock, 15))
    return dict(writes=escrituras, retries=reintentos, failures=fallas, fail_addr=fa, fail_wrote=fw, fail_read=fr)


def set_ganancia(sock_adrf, sock_datos, gain_mdb, reiniciar=True):
    """Fija la ganancia del ADRF en mili-dB: el driver calcula la tension de VGAIN segun la pendiente configurada y el DAC del
    servidor de datos la aplica. Devuelve esa tension en mV; RuntimeError si el driver rechaza la ganancia."""
    if not adrf_set_gain(sock_adrf, gain_mdb):
        raise RuntimeError("el driver rechazo la ganancia")
    mv = adrf_get_state(sock_adrf)['vgain_mv']
    set_vgain_mv(sock_datos, mv, reiniciar)
    return mv


def adrf_vgain_raw(sock, codigo):
    """Escribe el codigo (0 a 8191) en el DAC de VGAIN, sin conversion ni limite de tension. Devuelve False si el servidor lo
    rechaza: no tiene el DAC activado (-d), el codigo esta fuera de rango o el registro no quedo como se escribio."""
    send_cmd(sock, CMD_ADRF_VGAIN_RAW, int(codigo) & 0xFFFFFFFF)
    return read_ack(sock)


def adrf_get_vgain(sock):
    """Estado del DAC de VGAIN como diccionario: 'activo' (el servidor tiene -d), 'codigo' (leido del registro), 'pedido_mv'
    (ultima tension pedida) y 'efectivo_mv' (la que da el codigo con la calibracion del servidor). Con activo=False los otros
    tres valen 0. RuntimeError si el servidor no soporta el comando."""
    send_cmd(sock, CMD_ADRF_GET_VGAIN, 0)
    primero = _recv_exacto(sock, 1)[0]
    timeout_orig = sock.gettimeout()
    sock.settimeout(0.5)                  # un servidor que no conoce el comando manda un solo 0x00
    try:
        d = _recv_exacto(sock, _ADRF_VGAIN_BYTES)
    except (socket.timeout, ConnectionError):
        raise RuntimeError("el servidor no soporta CMD_ADRF_GET_VGAIN")
    finally:
        sock.settimeout(timeout_orig)
    codigo, pedido, efectivo = struct.unpack('<HHH', d)
    return dict(activo=(primero == 0x01), codigo=codigo, pedido_mv=pedido, efectivo_mv=efectivo)
