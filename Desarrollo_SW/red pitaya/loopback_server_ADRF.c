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
#include <sys/ioctl.h>
#include <sys/socket.h>
#include <netinet/in.h>
#include <netinet/tcp.h>
#include <linux/spi/spidev.h>

#include "adrf6850.h"

/*
 * Servidor de loopback TX/RX + configuracion de front-end para Red Pitaya
 * (Alpine Linux, framework SDR de Pavel Demin).
 *
 */

#define CMA_ALLOC _IOWR('Z', 0, uint32_t)

#define TCP_PORT     1003

#define CMD_READ_ADC     0x03
#define CMD_SET_FIFO     0x04
#define CMD_SET_CFG      0x05
#define CMD_TX_LOAD      0x06
#define CMD_TX_START     0x07
#define CMD_TX_STOP      0x08

/* ---- Configuración del ADRF6850 por SPI ---- */
#define CMD_ADRF_INIT       0x10   /* payload ignorado, corre adrf6850_init() */
#define CMD_ADRF_UPDATE     0x11   /* payload = ADRF_UPDATE_WIRE_BYTES, seguido de esos bytes */
#define CMD_ADRF_GET_STATE  0x12   /* payload ignorado, responde ADRF_STATE_WIRE_BYTES bytes */
#define CMD_ADRF_SET_LO     0x13   /* payload = LO en Hz */
#define CMD_ADRF_SET_GAIN   0x14   /* payload = ganancia en dB */

#define TX_BURST_SAMPLES  32u
#define TX_MAX_BURSTS     (1u << 18)
#define TX_MAX_SAMPLES    (TX_MAX_BURSTS * TX_BURST_SAMPLES)
#define TX_DDR_BUF_BYTES  (TX_MAX_SAMPLES * sizeof(uint32_t))

#define DAC_RATE_HZ       125000000.0
#define DAC_BYTES_PER_S   (DAC_RATE_HZ * 4.0)
#define BURST_BYTES       (TX_BURST_SAMPLES * 4)

/* ---- Variables globales ---- */
static volatile uint32_t *cfg = NULL;
static volatile uint32_t *sts = NULL;
static volatile uint32_t *data_reg = NULL;

static volatile uint32_t *tx_ctrl = NULL;
static volatile uint32_t *tx_addr = NULL;
static volatile uint32_t *tx_size = NULL;
static volatile uint32_t *tx_sts = NULL;
static volatile uint32_t *ddr_buf = NULL;

static uint32_t tx_phys_addr = 0;
static uint32_t tx_len = 0;

static int mem_fd = -1;
static int cma_fd = -1;
static int sock_server = -1;
static int sock_client = -1;

static uint32_t *rx_buf = NULL;
static size_t rx_buf_cap = 0;

static struct timespec g_fifo_reset_time;
static int g_fifo_reset_valid = 0;

static volatile sig_atomic_t g_stop = 0;

/* ============================================================
 * 			SPI (spidev)
 * ============================================================
 */
#define ADRF_SPI_DEVICE     "/dev/spidev1.0"
#define ADRF_SPI_MODE       SPI_MODE_0
#define ADRF_SPI_SPEED_HZ   1000000u
#define ADRF_SPI_BITS       8

static int adrf_spi_fd = -1;

static int adrf_spi_init(const char *device) {
    uint8_t  mode  = ADRF_SPI_MODE;
    uint8_t  bits  = ADRF_SPI_BITS;
    uint32_t speed = ADRF_SPI_SPEED_HZ;

    adrf_spi_fd = open(device, O_RDWR);
    if (adrf_spi_fd < 0) {
        fprintf(stderr, "ADRF: no se pudo abrir %s: %s\n", device, strerror(errno));
        return -1;
    }
    if (ioctl(adrf_spi_fd, SPI_IOC_WR_MODE, &mode) < 0 ||
        ioctl(adrf_spi_fd, SPI_IOC_WR_BITS_PER_WORD, &bits) < 0 ||
        ioctl(adrf_spi_fd, SPI_IOC_WR_MAX_SPEED_HZ, &speed) < 0) {
        fprintf(stderr, "ADRF: ioctl de configuracion SPI fallo: %s\n", strerror(errno));
        close(adrf_spi_fd);
        adrf_spi_fd = -1;
        return -1;
    }
    printf("ADRF: %s abierto (modo %u, %u bits, %u Hz)\n",
           device, mode, bits, speed);
    return 0;
}

static void adrf_spi_close(void) {
    if (adrf_spi_fd >= 0) { 
	close(adrf_spi_fd); adrf_spi_fd = -1; 
    }
}

void adrf6850_hw_spi_write(const uint8_t *buf, uint32_t len) {
    struct spi_ioc_transfer xfer;

    if (adrf_spi_fd < 0 || len == 0U) return;

    memset(&xfer, 0, sizeof(xfer));
    xfer.tx_buf = (unsigned long)(uintptr_t)buf;
    xfer.rx_buf = 0;
    xfer.len = len;
    xfer.speed_hz = ADRF_SPI_SPEED_HZ;
    xfer.bits_per_word = ADRF_SPI_BITS;

    if (ioctl(adrf_spi_fd, SPI_IOC_MESSAGE(1), &xfer) < 0) {
        fprintf(stderr, "ADRF: SPI write falló: %s\n", strerror(errno));
    }
}

void adrf6850_hw_spi_read(uint8_t *buf, uint32_t len) {
    struct spi_ioc_transfer xfer;
    uint8_t dummy_tx[8];

    if (adrf_spi_fd < 0 || len == 0U || len > sizeof(dummy_tx)) return;
    memset(dummy_tx, 0, sizeof(dummy_tx));

    memset(&xfer, 0, sizeof(xfer));
    xfer.tx_buf = (unsigned long)(uintptr_t)dummy_tx;
    xfer.rx_buf = (unsigned long)(uintptr_t)buf;
    xfer.len = len;
    xfer.speed_hz = ADRF_SPI_SPEED_HZ;
    xfer.bits_per_word = ADRF_SPI_BITS;

    if (ioctl(adrf_spi_fd, SPI_IOC_MESSAGE(1), &xfer) < 0) {
        fprintf(stderr, "ADRF: SPI read fallo: %s\n", strerror(errno));
    }
}

int adrf6850_hw_ldet_read(void) {
    /* TO-DO: implementar con GPIO */
    return -1;
}

int adrf6850_hw_vgain_set_mv(uint16_t mv) {
    /* TO-DO: Implementar */
    return 0;
}

/* ============================================================
 * Serializacion manual de adrf6850_params_t / adrf6850_state_t
 * ============================================================
 */

#define ADRF_UPDATE_WIRE_BYTES  18u
#define ADRF_STATE_WIRE_BYTES   26u

static void wr_u32(uint8_t *p, uint32_t v) {
    p[0] = (uint8_t)(v);       p[1] = (uint8_t)(v >> 8);
    p[2] = (uint8_t)(v >> 16); p[3] = (uint8_t)(v >> 24);
}
static void wr_u16(uint8_t *p, uint16_t v) {
    p[0] = (uint8_t)(v); p[1] = (uint8_t)(v >> 8);
}
static uint32_t rd_u32(const uint8_t *p) {
    return (uint32_t)p[0] | ((uint32_t)p[1] << 8) |
           ((uint32_t)p[2] << 16) | ((uint32_t)p[3] << 24);
}

/* Decodifica los ADRF_UPDATE_WIRE_BYTES recibidos en un
 * adrf6850_params_t. Layout (todo little-endian):
 *   [0:4)   mask         uint32
 *   [4:8)   lo_hz        uint32
 *   [8:12)  gain_mdb     int32
 *   [12]    bb_wideband  uint8
 *   [13]    bb_fc        uint8   (0..3, ver adrf6850_bb_fc_t)
 *   [14]    lomon_en     uint8
 *   [15]    lomon_pwr    uint8   (0..3, ver adrf6850_lomon_pwr_t)
 *   [16]    cp_code      uint8
 *   [17]    fast_hop     uint8
 */
static void adrf_params_from_wire(const uint8_t *w, adrf6850_params_t *p) {
    memset(p, 0, sizeof(*p));
    p->mask        = rd_u32(w + 0);
    p->lo_hz       = rd_u32(w + 4);
    p->gain_mdb    = (int32_t)rd_u32(w + 8);
    p->bb_wideband = w[12];
    p->bb_fc       = (adrf6850_bb_fc_t)w[13];
    p->lomon_en    = w[14];
    p->lomon_pwr   = (adrf6850_lomon_pwr_t)w[15];
    p->cp_code     = w[16];
    p->fast_hop    = w[17];
}

/* Codifica el estado actual del dispositivo en ADRF_STATE_WIRE_BYTES.
 * Layout (todo little-endian):
 *   [0]      initialized   uint8
 *   [1:5)    lo_hz         uint32
 *   [5:9)    lo_actual_hz  uint32
 *   [9]      rfdiv         uint8
 *   [10:12)  n_int         uint16
 *   [12:16)  n_frac        uint32
 *   [16:20)  gain_mdb      int32
 *   [20:22)  vgain_mv      uint16
 *   [22]     bb_wideband   uint8
 *   [23]     bb_fc         uint8
 *   [24]     cp_code       uint8
 *   [25]     autocal_off   uint8
 */
static void adrf_state_to_wire(const adrf6850_state_t *s, uint8_t *w) {
    w[0] = s->initialized;
    wr_u32(w + 1, s->lo_hz);
    wr_u32(w + 5, s->lo_actual_hz);
    w[9] = s->rfdiv;
    wr_u16(w + 10, s->n_int);
    wr_u32(w + 12, s->n_frac);
    wr_u32(w + 16, (uint32_t)s->gain_mdb);
    wr_u16(w + 20, s->vgain_mv);
    w[22] = s->bb_wideband;
    w[23] = (uint8_t)s->bb_fc;
    w[24] = s->cp_code;
    w[25] = s->autocal_off;
}

/* ============================================================ */

static void on_sigint(int sig) {
    (void)sig;
    g_stop = 1;
}

static void cleanup_and_exit(int code) {
    if (tx_ctrl) tx_ctrl[0] = 0;
    if (sock_client >= 0) close(sock_client);
    if (sock_server >= 0) close(sock_server);
    free(rx_buf);
    if (ddr_buf) munmap((void *)ddr_buf, TX_DDR_BUF_BYTES);
    if (cfg)      munmap((void *)cfg,      4096);
    if (sts)      munmap((void *)sts,      4096);
    if (data_reg) munmap((void *)data_reg, 4096);
    if (tx_ctrl)  munmap((void *)tx_ctrl,  4096);
    if (tx_sts)   munmap((void *)tx_sts,   4096);
    if (cma_fd >= 0) close(cma_fd);   /* libera la reserva CMA */
    if (mem_fd >= 0) close(mem_fd);
    adrf_spi_close();
    printf("Saliendo, memoria CMA liberada.\n");
    exit(code);
}

/* recv exacto de 'len' bytes; devuelve 0 si ok, -1 si se corto la
 * conexion o si Ctrl+C interrumpio la espera. */
static int recv_all(int fd, void *buf, size_t len) {
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

static int send_all(int fd, const void *buf, size_t len) {
    size_t sent = 0;
    const uint8_t *p = (const uint8_t *)buf;
    while (sent < len) {
        ssize_t s = send(fd, p + sent, len - sent, 0);
        if (s > 0) { sent += (size_t)s; continue; }
        if (s < 0 && errno == EINTR) { if (g_stop) return -1; continue; }
        return -1;
    }
    return 0;
}

static int ensure_rx_buf(size_t n_words) {
    if (n_words <= rx_buf_cap) return 0;
    uint32_t *nb = realloc(rx_buf, n_words * sizeof(uint32_t));
    if (!nb) return -1;
    rx_buf = nb;
    rx_buf_cap = n_words;
    return 0;
}

int main(void) {
    struct sigaction sa;
    struct sockaddr_in addr;
    int yes = 1;
    uint8_t cmd, ack;
    uint32_t payload;

    memset(&sa, 0, sizeof(sa));
    sa.sa_handler = on_sigint;
    sigaction(SIGINT, &sa, NULL);

    mem_fd = open("/dev/mem", O_RDWR | O_SYNC);
    if (mem_fd < 0) { perror("open /dev/mem"); return 1; }

    cfg = mmap(NULL, 4096, PROT_READ|PROT_WRITE, MAP_SHARED, mem_fd, 0x40000000);
    sts = mmap(NULL, 4096, PROT_READ|PROT_WRITE, MAP_SHARED, mem_fd, 0x41000000);
    data_reg = mmap(NULL, 4096, PROT_READ|PROT_WRITE, MAP_SHARED, mem_fd, 0x42000000);

    /* cfg en test_0/axi_hub_0 en GP1: tx_ctrl[0]=ctrl,
     * tx_ctrl[1]=addr, tx_ctrl[2]=size, tx_sts va solo */
    tx_ctrl = mmap(NULL, 4096, PROT_READ|PROT_WRITE, MAP_SHARED, mem_fd, 0x80000000);
    tx_addr = tx_ctrl + 1;
    tx_size = tx_ctrl + 2;
    tx_sts  = mmap(NULL, 4096, PROT_READ|PROT_WRITE, MAP_SHARED, mem_fd, 0x81000000);

    if (cfg == MAP_FAILED || sts == MAP_FAILED || data_reg == MAP_FAILED ||
        tx_ctrl == MAP_FAILED || tx_sts == MAP_FAILED) {
        perror("mmap /dev/mem"); return 1;
    }

    cma_fd = open("/dev/cma", O_RDWR);
    if (cma_fd < 0) { perror("open /dev/cma"); return 1; }

    tx_phys_addr = TX_DDR_BUF_BYTES;
    if (ioctl(cma_fd, CMA_ALLOC, &tx_phys_addr) < 0) {
        perror("ioctl CMA_ALLOC"); return 1;
    }
    printf("TX: buffer CMA de %lu bytes reservado en 0x%08X\n",
           (unsigned long)TX_DDR_BUF_BYTES, tx_phys_addr);

    ddr_buf = mmap(NULL, TX_DDR_BUF_BYTES, PROT_READ|PROT_WRITE, MAP_SHARED,
                   mem_fd, tx_phys_addr);
    if (ddr_buf == MAP_FAILED) { perror("mmap /dev/mem (buffer TX)"); return 1; }

    tx_ctrl[0] = 0;

    if (adrf_spi_init(ADRF_SPI_DEVICE) < 0) {
        fprintf(stderr, "ADRF: SPI no disponible, los comandos CMD_ADRF_* "
                "van a fallar hasta que se resuelva.\n");
    }

    sock_server = socket(AF_INET, SOCK_STREAM, 0);
    setsockopt(sock_server, SOL_SOCKET, SO_REUSEADDR, &yes, sizeof(yes));
    memset(&addr, 0, sizeof(addr));
    addr.sin_family = AF_INET;
    addr.sin_addr.s_addr = htonl(INADDR_ANY);
    addr.sin_port = htons(TCP_PORT);
    bind(sock_server, (struct sockaddr*)&addr, sizeof(addr));
    listen(sock_server, 4);
    printf("Servidor escuchando en puerto %d\n", TCP_PORT);

    while (!g_stop) {
        sock_client = accept(sock_server, NULL, NULL);
        if (sock_client < 0) {
            if (errno == EINTR) continue;
            break;
        }
        setsockopt(sock_client, IPPROTO_TCP, TCP_NODELAY, &yes, sizeof(yes));
        printf("Cliente conectado.\n");

        while (!g_stop) {
            uint32_t n, n_bursts, n_padded, cur, n_leidas, disponibles, a_leer;
            struct timespec t_ini, t_ahora;
            double t_transcurrido, t_ultimo_print;
            uint8_t *dst;
            size_t total, rcvd;

            if (recv_all(sock_client, &cmd, 1) < 0) break;
            if (recv_all(sock_client, &payload, 4) < 0) break;

            if (cmd == CMD_SET_CFG) {
                *cfg = payload;
                ack = 0x01;
                send_all(sock_client, &ack, 1);
            }
            else if (cmd == CMD_SET_FIFO) {
                cur = *cfg;
                *cfg = (payload == 0) ? (cur & ~0x1u) : (cur | 0x1u);
                if (payload != 0) {
                    clock_gettime(CLOCK_MONOTONIC, &g_fifo_reset_time);
                    g_fifo_reset_valid = 1;
                }
                ack = 0x01;
                send_all(sock_client, &ack, 1);
            }
            else if (cmd == CMD_READ_ADC) {
                n = payload;
                if (ensure_rx_buf(n) < 0) {
                    fprintf(stderr, "CMD_READ_ADC: sin memoria para %u palabras\n", n);
                    continue;
                }

                n_leidas = 0;
                clock_gettime(CLOCK_MONOTONIC, &t_ini);
                t_ultimo_print = 0.0;

                if (g_fifo_reset_valid) {
                    double gap = (t_ini.tv_sec - g_fifo_reset_time.tv_sec) +
                                 (t_ini.tv_nsec - g_fifo_reset_time.tv_nsec) / 1e9;
                    fprintf(stderr, "CMD_READ_ADC: arranca %.2f ms despues del "
                            "reset del FIFO, read_count inicial=%u\n",
                            gap * 1e3, sts[0] & 0xFFFFu);
                }

                while (n_leidas < n && !g_stop) {
                    disponibles = sts[0] & 0xFFFFu;
                    a_leer = (disponibles < (n - n_leidas)) ? disponibles : (n - n_leidas);
                    for (uint32_t i = 0; i < a_leer; i++) rx_buf[n_leidas++] = *data_reg;

                    clock_gettime(CLOCK_MONOTONIC, &t_ahora);
                    t_transcurrido = (t_ahora.tv_sec - t_ini.tv_sec) +
                                     (t_ahora.tv_nsec - t_ini.tv_nsec) / 1e9;
                    if (t_transcurrido - t_ultimo_print > 1.0) {
                        fprintf(stderr, "CMD_READ_ADC: %u/%u leidas  "
                                "read_count=%u  (%.1fs)\n",
                                n_leidas, n, disponibles, t_transcurrido);
                        t_ultimo_print = t_transcurrido;
                    }
                    if (t_transcurrido > 10.0) {
                        fprintf(stderr, "CMD_READ_ADC: timeout a los %u/%u, "
                                "se manda incompleto (resto en cero)\n", n_leidas, n);
                        break;
                    }
                }
                if (g_stop) break;
                send_all(sock_client, rx_buf, (size_t)n * sizeof(uint32_t));
            }
            else if (cmd == CMD_TX_LOAD) {
                n = payload;
                if (n > TX_MAX_SAMPLES) n = TX_MAX_SAMPLES;
                n_padded = ((n + TX_BURST_SAMPLES - 1) / TX_BURST_SAMPLES) * TX_BURST_SAMPLES;
                if (n_padded > TX_MAX_SAMPLES) n_padded = TX_MAX_SAMPLES;

                dst = (uint8_t *)ddr_buf;
                total = (size_t)n * 4;
                rcvd = 0;
                while (rcvd < total) {
                    ssize_t r = recv(sock_client, dst + rcvd, total - rcvd, 0);
                    if (r <= 0) break;
                    rcvd += (size_t)r;
                }
                if (n_padded > n) memset(dst + n * 4, 0, (n_padded - n) * 4);

                tx_len = n_padded;
                printf("TX: %u muestras cargadas (%u tras padding)\n", n, tx_len);
                {
                    uint32_t *check = (uint32_t *)ddr_buf;
                    printf("TX: verificacion (primeras 4 palabras releidas): "
                           "0x%08X 0x%08X 0x%08X 0x%08X\n",
                           check[0], check[1], check[2], check[3]);
                }

                ack = 0x01;
                send_all(sock_client, &ack, 1);
            }
            else if (cmd == CMD_TX_START) {
                if (tx_len == 0) {
                    printf("TX: no hay buffer cargado\n");
                    ack = 0x00;
                    send_all(sock_client, &ack, 1);
                    continue;
                }
                n_bursts = tx_len / TX_BURST_SAMPLES;
                tx_ctrl[0] = 0;
                tx_addr[0] = tx_phys_addr;
                tx_size[0] = n_bursts - 1;
                tx_ctrl[0] = 1;
                printf("TX: arrancado, %u muestras en loop continuo\n", tx_len);

                {
                    struct timespec t0, t1;
                    uint32_t s0, s1, delta;
                    double elapsed_s, rate_bursts;

                    clock_gettime(CLOCK_MONOTONIC, &t0);
                    s0 = tx_sts[0] & 0x3FFFF;
                    usleep(1000);
                    s1 = tx_sts[0] & 0x3FFFF;
                    clock_gettime(CLOCK_MONOTONIC, &t1);

                    elapsed_s = (t1.tv_sec - t0.tv_sec) + (t1.tv_nsec - t0.tv_nsec) / 1e9;
                    delta = (s1 >= s0) ? (s1 - s0) : (s1 + n_bursts - s0);
                    rate_bursts = delta / elapsed_s;

                    printf("TX: caudal medido = %.0f rafagas/s (%.1f MB/s) -- "
                           "necesario = %.0f rafagas/s (%.1f MB/s) -- %.1f%%\n",
                           rate_bursts, rate_bursts * BURST_BYTES / 1e6,
                           DAC_BYTES_PER_S / BURST_BYTES, DAC_BYTES_PER_S / 1e6,
                           100.0 * rate_bursts * BURST_BYTES / DAC_BYTES_PER_S);
                }

                ack = 0x01;
                send_all(sock_client, &ack, 1);
            }
            else if (cmd == CMD_TX_STOP) {
                tx_ctrl[0] = 0;
                printf("TX: detenido\n");
                ack = 0x01;
                send_all(sock_client, &ack, 1);
            }
            /* -------- comandos nuevos: ADRF6850 -------- */
            else if (cmd == CMD_ADRF_INIT) {
                adrf6850_status_t st = ADRF6850_ERR_HW;
                if (adrf_spi_fd >= 0) {
                    st = adrf6850_init();
                }
                printf("ADRF: init -> %d\n", (int)st);
                ack = (st == ADRF6850_OK) ? 0x01 : 0x00;
                send_all(sock_client, &ack, 1);
            }
            else if (cmd == CMD_ADRF_UPDATE) {
                uint8_t wire[ADRF_UPDATE_WIRE_BYTES];
                adrf6850_params_t p;
                adrf6850_status_t st = ADRF6850_ERR_PARAM;

                if (payload != ADRF_UPDATE_WIRE_BYTES) {
                    fprintf(stderr, "ADRF: CMD_ADRF_UPDATE con payload=%u, "
                            "se esperaban %u bytes\n", payload, ADRF_UPDATE_WIRE_BYTES);
                    /* hay que drenar igual los bytes que el cliente va a
                     * mandar, si no la conexion queda desincronizada */
                    if (payload > 0 && payload < 4096) {
                        uint8_t *scratch = malloc(payload);
                        if (scratch) { recv_all(sock_client, scratch, payload); free(scratch); }
                    }
                } else if (recv_all(sock_client, wire, sizeof(wire)) < 0) {
                    break;
                } else if (adrf_spi_fd >= 0) {
                    adrf_params_from_wire(wire, &p);
                    st = adrf6850_update(&p);
                    printf("ADRF: update (mask=0x%02X) -> %d\n", (unsigned)p.mask, (int)st);
                } else {
                    st = ADRF6850_ERR_HW;
                }
                ack = (st == ADRF6850_OK) ? 0x01 : 0x00;
                send_all(sock_client, &ack, 1);
            }
            else if (cmd == CMD_ADRF_GET_STATE) {
                uint8_t wire[ADRF_STATE_WIRE_BYTES];
                adrf_state_to_wire(adrf6850_get_state(), wire);
                send_all(sock_client, wire, sizeof(wire));
            }
            else if (cmd == CMD_ADRF_SET_LO) {
                adrf6850_status_t st = ADRF6850_ERR_HW;
                if (adrf_spi_fd >= 0) {
                    st = adrf6850_set_lo(payload);
                }
                printf("ADRF: set_lo(%u Hz) -> %d\n", payload, (int)st);
                ack = (st == ADRF6850_OK) ? 0x01 : 0x00;
                send_all(sock_client, &ack, 1);
            }
            else if (cmd == CMD_ADRF_SET_GAIN) {
                adrf6850_status_t st = ADRF6850_ERR_HW;
                int32_t gain_mdb = (int32_t)payload;
                if (adrf_spi_fd >= 0) {
                    st = adrf6850_set_gain_mdb(gain_mdb);
                }
                printf("ADRF: set_gain(%d mdB) -> %d\n", gain_mdb, (int)st);
                ack = (st == ADRF6850_OK) ? 0x01 : 0x00;
                send_all(sock_client, &ack, 1);
            }
        }

        tx_ctrl[0] = 0;
        if (sock_client >= 0) { close(sock_client); sock_client = -1; }
        printf("Cliente desconectado.\n");
    }

    cleanup_and_exit(0);
    return 0;
}
