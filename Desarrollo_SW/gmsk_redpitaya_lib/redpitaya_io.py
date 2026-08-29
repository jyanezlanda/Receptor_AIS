"""
redpitaya_io.py -- Comunicación con el servidor de la Red Pitaya.

Protocolo: 1 byte de comando + 4 bytes de payload; ack de 1 byte salvo
CMD_READ_ADC, que responde con n_words*4 bytes de datos.
"""

import socket
import struct
import numpy as np

CMD_READ_ADC = 0x03
CMD_SET_FIFO = 0x04
CMD_SET_CFG  = 0x05
CMD_TX_LOAD  = 0x06
CMD_TX_START = 0x07
CMD_TX_STOP  = 0x08


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
