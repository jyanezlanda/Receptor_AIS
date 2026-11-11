/*
 * adc_server.c -- Servidor de captura para la Red Pitaya (puerto 1003), para el bitstream en que el DAC se maneja por registro.
 *
 * Maneja la FPGA: NCO, reset de la FIFO, seleccion de la salida y lectura de la FIFO. No hay transmision: el DAC solo entrega VGAIN
 * y lo maneja adrf_server.
 *
 * Compilar:  gcc -O2 -Wall adc_server.c -o adc_server
 * Usar:      ./adc_server [-p puerto]          (necesita el bitstream cargado)
 *
 * Protocolo: 1 byte de comando + 4 bytes de payload (little-endian). Respuesta de 1 byte (0x01 = ok, 0x00 = error),
 * salvo CMD_READ_ADC (n*4 bytes de datos), CMD_GET_STS (12 bytes) y CMD_GET_RAFAGA (8 bytes). Un comando desconocido se rechaza.
 *
 *   CMD_READ_ADC   0x03  payload = n palabras de 32 bits a leer del FIFO
 *   CMD_SET_FIFO   0x04  payload = 0: baja cfg[0] bit 0 (reset del FIFO); otro: lo sube
 *   CMD_SET_CFG    0x05  payload -> cfg[0]  (PINC << 1 | run)
 *   CMD_TX_LOAD    0x06  no hay TX: se descartan las muestras (payload = n; siguen n*4 bytes) y se contesta error
 *   CMD_TX_START   0x07  no hay TX: error
 *   CMD_TX_STOP    0x08  ok: no hay nada que detener
 *   CMD_GET_STS    0x23  sin payload; responde sts[0], sts[1] y sts[2] (3 x uint32 little-endian), 78 bits utiles:
 *                        bits 15:0 read_count del FIFO; 35:16 nivel_senal (20 bits, envolvente de la magnitud del discriminador);
 *                        36 activo (squelch confirmado); 56:37 piso_ruido del squelch; 76:57 dispersion del squelch;
 *                        77 activo_ext (activo mantenido 3 ms tras caer)
 *   CMD_GET_RAFAGA 0x24  sin payload; responde sts[3] y sts[4] (2 x uint32 little-endian): registro por rafaga de gmsk_pico_rafaga, actualizado al caer activo.
 *                        sts[3]: bits 19:0 pico de nivel de la ultima rafaga (0 si fue demasiado corta), bits 31:20 contador de rafagas (da la vuelta);
 *                        sts[4]: bits 15:0 duracion en muestras de IQ (satura), bit 16 pico valido. Se lee sts[3], sts[4] y sts[3] de nuevo y se repite si el contador cambio.
 *   CMD_SET_SALIDA 0x22  payload 0: al FIFO le llega la salida demodulada (bits, despues del squelch); otro valor: el
 *                        IQ crudo del FIR (sin demodular ni squelch). Escribe cfg[3] bit 0, el selector del mux de
 *                        salida. Despues de cambiar de salida hay que vaciar el FIFO (CMD_SET_FIFO 0 y 1).
 */
#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>
#include <string.h>
#include <errno.h>
#include <signal.h>
#include <unistd.h>
#include <fcntl.h>
#include <time.h>
#include <sys/mman.h>
#include <sys/socket.h>
#include <netinet/in.h>
#include <netinet/tcp.h>

#define TCP_PORT_DEFECTO 1003

#define CMD_READ_ADC     0x03
#define CMD_SET_FIFO     0x04
#define CMD_SET_CFG      0x05
#define CMD_TX_LOAD      0x06
#define CMD_TX_START     0x07
#define CMD_TX_STOP      0x08
#define CMD_GET_STS      0x23
#define CMD_GET_RAFAGA   0x24
#define CMD_SET_SALIDA   0x22

#define TX_MAX_DESCARTE   (1u << 23)     /* muestras de un TX_LOAD que se descartan; un pedido mayor corta la conexion */

#define RX_MAX_WORDS      (1u << 24)     /* tope de una lectura: 16 M palabras (64 MB) */
#ifndef READ_TIMEOUT_S
#define READ_TIMEOUT_S    10.0           /* si el FIFO no entrega todo en este tiempo, se manda lo leido */
#endif

static volatile uint32_t *cfg = NULL;
static volatile uint32_t *sts = NULL;
static volatile uint32_t *data_reg = NULL;

static int mem_fd = -1;
static int sock_server = -1;
static uint32_t *rx_buf = NULL;
static size_t rx_buf_cap = 0;

static volatile sig_atomic_t g_stop = 0;

/* ---- Hardware (/dev/mem): inicio ---- */
static int hw_abrir(void)
{
    mem_fd = open("/dev/mem", O_RDWR | O_SYNC);
    if (mem_fd < 0) { perror("open /dev/mem"); return -1; }

    cfg      = mmap(NULL, 4096, PROT_READ | PROT_WRITE, MAP_SHARED, mem_fd, 0x40000000);
    sts      = mmap(NULL, 4096, PROT_READ | PROT_WRITE, MAP_SHARED, mem_fd, 0x41000000);
    data_reg = mmap(NULL, 4096, PROT_READ | PROT_WRITE, MAP_SHARED, mem_fd, 0x42000000);
    if (cfg == MAP_FAILED || sts == MAP_FAILED || data_reg == MAP_FAILED) {
        perror("mmap /dev/mem");
        cfg = sts = data_reg = NULL;
        return -1;
    }
    return 0;
}

static void hw_cerrar(void)
{
    if (cfg)      munmap((void *)cfg, 4096);
    if (sts)      munmap((void *)sts, 4096);
    if (data_reg) munmap((void *)data_reg, 4096);
    if (mem_fd >= 0) close(mem_fd);
}
/* ---- Hardware: fin ---- */

static void on_signal(int sig) { (void)sig; g_stop = 1; }

/* recv exacto de 'len' bytes: 0 si ok, -1 si se corto la conexion o hubo Ctrl+C */
static int recv_all(int fd, void *buf, size_t len)
{
    size_t got = 0;
    uint8_t *p = (uint8_t *)buf;
    while (got < len) {
        ssize_t r = recv(fd, p + got, len - got, 0);
        if (r > 0) { got += (size_t)r; continue; }
        if (r < 0 && errno == EINTR) { if (g_stop) return -1; continue; }
        return -1;
    }
    return 0;
}

static int send_all(int fd, const void *buf, size_t len)
{
    size_t sent = 0;
    const uint8_t *p = (const uint8_t *)buf;
    while (sent < len) {
        ssize_t s = send(fd, p + sent, len - sent, MSG_NOSIGNAL);
        if (s > 0) { sent += (size_t)s; continue; }
        if (s < 0 && errno == EINTR) { if (g_stop) return -1; continue; }
        return -1;
    }
    return 0;
}

static int responder(int fd, int ok)
{
    uint8_t ack = ok ? 0x01 : 0x00;
    return send_all(fd, &ack, 1);
}

/* Lee y tira 'nbytes' del socket: mantiene sincronizada la conexion cuando se rechaza un pedido */
static int descartar(int fd, uint64_t nbytes)
{
    static uint8_t basura[65536];
    while (nbytes > 0) {
        size_t n = nbytes < sizeof(basura) ? (size_t)nbytes : sizeof(basura);
        if (recv_all(fd, basura, n) < 0) return -1;
        nbytes -= n;
    }
    return 0;
}

static int ensure_rx_buf(size_t n_words)
{
    uint32_t *nb;
    if (n_words <= rx_buf_cap) return 0;
    nb = realloc(rx_buf, n_words * sizeof(uint32_t));
    if (!nb) return -1;
    rx_buf = nb;
    rx_buf_cap = n_words;
    return 0;
}

/* Lee n palabras del FIFO y las manda. -1 si hay que cortar la conexion. */
static int cmd_read_adc(int fd, uint32_t n)
{
    struct timespec t_ini, t_ahora;
    uint32_t n_leidas = 0, disponibles, a_leer, i;

    if (n > RX_MAX_WORDS || ensure_rx_buf(n) < 0) {
        fprintf(stderr, "CMD_READ_ADC: pedido de %u palabras rechazado (maximo %u)\n", n, RX_MAX_WORDS);
        return -1;
    }
    clock_gettime(CLOCK_MONOTONIC, &t_ini);
    while (n_leidas < n && !g_stop) {
        disponibles = sts[0] & 0xFFFFu;
        a_leer = (disponibles < (n - n_leidas)) ? disponibles : (n - n_leidas);
        for (i = 0; i < a_leer; i++) rx_buf[n_leidas++] = *data_reg;

        clock_gettime(CLOCK_MONOTONIC, &t_ahora);
        if ((t_ahora.tv_sec - t_ini.tv_sec) + (t_ahora.tv_nsec - t_ini.tv_nsec) / 1e9 > READ_TIMEOUT_S) {
            fprintf(stderr, "CMD_READ_ADC: timeout con %u/%u palabras; el resto se envia en cero\n", n_leidas, n);
            memset(rx_buf + n_leidas, 0, (size_t)(n - n_leidas) * sizeof(uint32_t));
            break;
        }
    }
    if (g_stop) return -1;
    return send_all(fd, rx_buf, (size_t)n * sizeof(uint32_t));
}

/* Atiende a un cliente hasta que se desconecta. */
static void atender(int fd)
{
    uint8_t cmd;
    uint32_t payload, cur;

    while (!g_stop) {
        if (recv_all(fd, &cmd, 1) < 0 || recv_all(fd, &payload, 4) < 0) return;

        switch (cmd) {
        case CMD_SET_CFG:
            *cfg = payload;
            if (responder(fd, 1) < 0) return;
            break;
        case CMD_SET_FIFO:
            cur = *cfg;
            *cfg = (payload == 0) ? (cur & ~0x1u) : (cur | 0x1u);
            if (responder(fd, 1) < 0) return;
            break;
        case CMD_SET_SALIDA:
            cfg[3] = (payload != 0) ? 1u : 0u;
            printf("salida: %s\n", payload ? "IQ crudo (FIR)" : "demodulada");
            if (responder(fd, 1) < 0) return;
            break;
        case CMD_GET_RAFAGA: {                 /* sts[3] y sts[4] se actualizan juntos en la FPGA: si sts[3] no cambio entre las dos lecturas, el par es consistente */
            uint32_t a, b, c;
            int n = 0;
            do { a = sts[3]; b = sts[4]; c = sts[3]; } while (a != c && ++n < 4);
            uint32_t v[2] = { c, b };
            if (send_all(fd, v, sizeof(v)) < 0) return;
            break;
        }
        case CMD_GET_STS: {
            uint32_t v[3] = { sts[0], sts[1], sts[2] };
            if (send_all(fd, v, sizeof(v)) < 0) return;
            break;
        }
        case CMD_READ_ADC:
            if (cmd_read_adc(fd, payload) < 0) return;
            break;
        case CMD_TX_LOAD:                      /* sin TX: se descartan las muestras para no perder la sincronia */
            fprintf(stderr, "TX: no disponible en este bitstream\n");
            if (payload > TX_MAX_DESCARTE) return;
            if (descartar(fd, (uint64_t)payload * 4) < 0) return;
            if (responder(fd, 0) < 0) return;
            break;
        case CMD_TX_START:
            fprintf(stderr, "TX: no disponible en este bitstream\n");
            if (responder(fd, 0) < 0) return;
            break;
        case CMD_TX_STOP:                      /* no hay TX: ya esta detenido */
            if (responder(fd, 1) < 0) return;
            break;
        default:
            fprintf(stderr, "comando desconocido 0x%02X\n", (unsigned)cmd);
            if (responder(fd, 0) < 0) return;
            break;
        }
    }
}

/* Un cliente que desaparece sin cerrar (se cae la red) no debe dejar al servidor colgado para siempre. */
static void ajustar_socket_cliente(int fd)
{
    int yes = 1, idle = 30, intervalo = 10, intentos = 3;
    setsockopt(fd, IPPROTO_TCP, TCP_NODELAY, &yes, sizeof(yes));
    setsockopt(fd, SOL_SOCKET, SO_KEEPALIVE, &yes, sizeof(yes));
    setsockopt(fd, IPPROTO_TCP, TCP_KEEPIDLE, &idle, sizeof(idle));
    setsockopt(fd, IPPROTO_TCP, TCP_KEEPINTVL, &intervalo, sizeof(intervalo));
    setsockopt(fd, IPPROTO_TCP, TCP_KEEPCNT, &intentos, sizeof(intentos));
}

static void salir(int codigo)
{
    if (sock_server >= 0) close(sock_server);
    free(rx_buf);
    hw_cerrar();
    printf("Saliendo.\n");
    exit(codigo);
}

int main(int argc, char **argv)
{
    struct sigaction sa;
    struct sockaddr_in addr;
    int puerto = TCP_PORT_DEFECTO, yes = 1, i;

    for (i = 1; i < argc; i++) {
        if (strcmp(argv[i], "-p") == 0 && i + 1 < argc) puerto = atoi(argv[++i]);
        else { fprintf(stderr, "uso: %s [-p puerto]\n", argv[0]); return 2; }
    }
    if (puerto < 1 || puerto > 65535) { fprintf(stderr, "puerto invalido: %d\n", puerto); return 2; }

    setvbuf(stdout, NULL, _IOLBF, 0);
    signal(SIGPIPE, SIG_IGN);
    memset(&sa, 0, sizeof(sa));
    sa.sa_handler = on_signal;                 /* sin SA_RESTART: accept/recv se interrumpen */
    sigaction(SIGINT, &sa, NULL);
    sigaction(SIGTERM, &sa, NULL);

    if (hw_abrir() < 0) salir(1);

    sock_server = socket(AF_INET, SOCK_STREAM, 0);
    if (sock_server < 0) { perror("socket"); salir(1); }
    setsockopt(sock_server, SOL_SOCKET, SO_REUSEADDR, &yes, sizeof(yes));
    memset(&addr, 0, sizeof(addr));
    addr.sin_family = AF_INET;
    addr.sin_addr.s_addr = htonl(INADDR_ANY);
    addr.sin_port = htons((uint16_t)puerto);
    if (bind(sock_server, (struct sockaddr *)&addr, sizeof(addr)) < 0 || listen(sock_server, 4) < 0) {
        fprintf(stderr, "no se pudo escuchar en el puerto %d: %s\n", puerto, strerror(errno));
        salir(1);
    }
    printf("Servidor escuchando en puerto %d\n", puerto);

    while (!g_stop) {
        int cli = accept(sock_server, NULL, NULL);
        if (cli < 0) {
            if (errno == EINTR) continue;
            break;
        }
        ajustar_socket_cliente(cli);
        printf("Cliente conectado.\n");
        atender(cli);
        close(cli);
        printf("Cliente desconectado.\n");
    }

    salir(0);
    return 0;
}
