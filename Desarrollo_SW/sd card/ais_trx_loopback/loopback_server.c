#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>
#include <string.h>
#include <unistd.h>
#include <fcntl.h>
#include <time.h>
#include <sys/mman.h>
#include <sys/ioctl.h>
#include <sys/socket.h>
#include <netinet/in.h>

/*
 * Servidor de loopback TX/RX para Red Pitaya (Alpine Linux, framework SDR de
 * Pavel Demin).
 *
 * TX: un axis_ram_reader lee en rafagas fijas de 128 bytes (32 muestras de
 * 32 bits) directamente desde DDR via el puerto HP0 en loop
 * infinito, sin intervencion de la CPU una vez arrancado.
 */

#define CMA_ALLOC _IOWR('Z', 0, uint32_t)

#define TCP_PORT     1003

/* Comandos RX */
#define CMD_READ_ADC 0x03
#define CMD_SET_FIFO 0x04
#define CMD_SET_CFG  0x05

/* Comandos TX */
#define CMD_TX_LOAD  0x06  /* payload = N muestras, luego recibe N*4 bytes */
#define CMD_TX_START 0x07  /* configura direccion/tamano y arranca el loop en HW */
#define CMD_TX_STOP  0x08  /* detiene el loop (mantiene el reader en reset) */

/* RX — rx_0/hub_0 en GP0 */
volatile uint32_t *cfg;
volatile uint32_t *sts;
volatile uint32_t *data_reg;

/* TX — test_0/axi_hub_0 en GP1.
 *   tx_ctrl @ 0x80000000 + 0  bit0 = aresetn del axis_ram_reader (0=reset, 1=corriendo)
 *   tx_addr @ 0x80000000 + 4  min_addr: direccion fisica del buffer TX en DDR
 *   tx_size @ 0x80000000 + 8  bits[17:0] = nro de rafagas - 1 (ADDR_WIDTH=18)
 * tx_sts  @ 0x81000000       categoria STS (1 palabra): contador de rafagas
 */
volatile uint32_t *tx_ctrl;
volatile uint32_t *tx_addr;
volatile uint32_t *tx_size;
volatile uint32_t *tx_sts;

/* Buffer TX: reservado via /dev/cma */
#define TX_BURST_SAMPLES  32u                                 /* AXI_DATA_WIDTH=64 -> 2 muestras/beat x 16 beats/rafaga */
#define TX_MAX_BURSTS     (1u << 18)                          /* ADDR_WIDTH=18 del axis_ram_reader */
#define TX_MAX_SAMPLES    (TX_MAX_BURSTS * TX_BURST_SAMPLES)  /* 8.388.608 muestras = 32 MB */
#define TX_DDR_BUF_BYTES  (TX_MAX_SAMPLES * sizeof(uint32_t))

volatile uint32_t *ddr_buf;
static uint32_t    tx_phys_addr = 0;  /* direccion fisica real del buffer, devuelta por CMA_ALLOC */
static uint32_t    tx_len       = 0;  /* muestras cargadas actualmente (multiplo de TX_BURST_SAMPLES) */

int main() {
    int mem_fd = open("/dev/mem", O_RDWR | O_SYNC);
    if(mem_fd < 0) { perror("open /dev/mem"); return 1; }

    /* RX */
    cfg      = mmap(NULL, 4096, PROT_READ|PROT_WRITE, MAP_SHARED, mem_fd, 0x40000000);
    sts      = mmap(NULL, 4096, PROT_READ|PROT_WRITE, MAP_SHARED, mem_fd, 0x41000000);
    data_reg = mmap(NULL, 4096, PROT_READ|PROT_WRITE, MAP_SHARED, mem_fd, 0x42000000);

    /* TX — registros de control: una sola pagina en la base de la
     * categoria cfg (0x80000000); las tres palabras se acceden como
     * tx_ctrl[0], tx_ctrl[1], tx_ctrl[2] sobre ese mismo mapeo. */
    tx_ctrl = mmap(NULL, 4096, PROT_READ|PROT_WRITE, MAP_SHARED, mem_fd, 0x80000000);
    tx_addr = tx_ctrl + 1;   /* offset +4 bytes = palabra 1 de cfg_data */
    tx_size = tx_ctrl + 2;   /* offset +8 bytes = palabra 2 de cfg_data */
    tx_sts  = mmap(NULL, 4096, PROT_READ|PROT_WRITE, MAP_SHARED, mem_fd, 0x81000000);

    if(cfg == MAP_FAILED || sts == MAP_FAILED || data_reg == MAP_FAILED ||
       tx_ctrl == MAP_FAILED || tx_sts == MAP_FAILED) {
        perror("mmap /dev/mem"); return 1;
    }

    int cma_fd = open("/dev/cma", O_RDWR);
    if(cma_fd < 0) { perror("open /dev/cma"); return 1; }

    tx_phys_addr = TX_DDR_BUF_BYTES;   /* al llamar al ioctl, esta variable pasa a
                                        * contener la direccion fisica real */
    if(ioctl(cma_fd, CMA_ALLOC, &tx_phys_addr) < 0) {
        perror("ioctl CMA_ALLOC"); return 1;
    }
    printf("TX: buffer CMA de %lu bytes reservado en 0x%08X\n",
           (unsigned long)TX_DDR_BUF_BYTES, tx_phys_addr);

    /* mapeo real de escritura: /dev/mem sobre la misma direccion fisica,
     * sin cache (comportamiento por defecto de /dev/mem en ARM) */
    ddr_buf = mmap(NULL, TX_DDR_BUF_BYTES, PROT_READ|PROT_WRITE, MAP_SHARED,
                   mem_fd, tx_phys_addr);
    if(ddr_buf == MAP_FAILED) { perror("mmap /dev/mem (buffer TX)"); return 1; }

    /* Reader en reset hasta que se cargue y arranque un buffer valido */
    tx_ctrl[0] = 0;

    int sock_server = socket(AF_INET, SOCK_STREAM, 0);
    int yes = 1;
    setsockopt(sock_server, SOL_SOCKET, SO_REUSEADDR, &yes, sizeof(yes));
    struct sockaddr_in addr = {
        .sin_family      = AF_INET,
        .sin_addr.s_addr = htonl(INADDR_ANY),
        .sin_port        = htons(TCP_PORT)
    };
    bind(sock_server, (struct sockaddr*)&addr, sizeof(addr));
    listen(sock_server, 4);
    printf("Servidor escuchando en puerto %d\n", TCP_PORT);

    while(1) {
        int sock_client = accept(sock_server, NULL, NULL);
        printf("Cliente conectado.\n");

        while(1) {
            uint8_t  cmd;
            uint32_t payload;
            if(recv(sock_client, &cmd,     1, MSG_WAITALL) <= 0) break;
            if(recv(sock_client, &payload, 4, MSG_WAITALL) <= 0) break;

            uint8_t ack;

            /* ---- RX ---- */
            if(cmd == CMD_SET_CFG) {
                *cfg = payload;
                ack = 0x01;
                send(sock_client, &ack, 1, 0);
            }
            else if(cmd == CMD_SET_FIFO) {
                uint32_t cur = *cfg;
                *cfg = (payload == 0) ? (cur & ~0x1u) : (cur | 0x1u);
                ack = 0x01;
                send(sock_client, &ack, 1, 0);
            }
            else if(cmd == CMD_READ_ADC) {
                uint32_t n = payload;
                uint64_t count = (uint64_t)sts[0] | ((uint64_t)sts[1] << 32);
                while(count < n) {
                    usleep(1000);
                    count = (uint64_t)sts[0] | ((uint64_t)sts[1] << 32);
                }
                for(uint32_t i = 0; i < n; i++) {
                    uint32_t sample = *data_reg;
                    send(sock_client, &sample, 4, 0);
                }
            }

            /* ---- TX ---- */
            else if(cmd == CMD_TX_LOAD) {
                uint32_t n = payload;
                if(n > TX_MAX_SAMPLES) n = TX_MAX_SAMPLES;

                /* el axis_ram_reader solo lee en rafagas completas de 32 muestras */
                uint32_t n_padded = ((n + TX_BURST_SAMPLES - 1) / TX_BURST_SAMPLES)
                                    * TX_BURST_SAMPLES;
                if(n_padded > TX_MAX_SAMPLES) n_padded = TX_MAX_SAMPLES;

                uint8_t *dst   = (uint8_t *)ddr_buf;
                uint32_t total = n * 4;
                uint32_t rcvd  = 0;
                while(rcvd < total) {
                    int r = recv(sock_client, dst + rcvd, total - rcvd, 0);
                    if(r <= 0) break;
                    rcvd += r;
                }
                if(n_padded > n) {
                    memset(dst + n * 4, 0, (n_padded - n) * 4);
                }

                tx_len = n_padded;
                printf("TX: %u muestras cargadas en DDR (%u tras padding a multiplo de %u)\n",
                       n, tx_len, TX_BURST_SAMPLES);

                /* Verificacion rapida: releer las primeras 4 palabras
                 * recien escritas, a traves del mismo puntero. Si esto no
                 * coincide con lo que se envio, el problema esta en el
                 * mapeo/escritura en si, no en el reader. */
                {
                    uint32_t *check = (uint32_t *)ddr_buf;
                    printf("TX: verificacion (primeras 4 palabras releidas): "
                           "0x%08X 0x%08X 0x%08X 0x%08X\n",
                           check[0], check[1], check[2], check[3]);
                }

                ack = 0x01;
                send(sock_client, &ack, 1, 0);
            }
            else if(cmd == CMD_TX_START) {
                if(tx_len == 0) {
                    printf("TX: no hay buffer cargado\n");
                    ack = 0x00;
                    send(sock_client, &ack, 1, 0);
                    continue;
                }
                uint32_t n_bursts = tx_len / TX_BURST_SAMPLES;
                tx_ctrl[0] = 0;                                  /* reset mientras configuro */
                tx_addr[0] = tx_phys_addr;
                tx_size[0] = n_bursts - 1;
                tx_ctrl[0] = 1;                                  /* libera el reset -> loop infinito en HW */
                printf("TX: arrancado, %u muestras en loop continuo\n", tx_len);

                /* Medicion empirica del caudal real del reader: se toma el
                 * contador de rafagas dos veces, separadas por un intervalo
                 * corto conocido, y se calcula el delta con wraparound
                 * modulo n_bursts (el contador vuelve a 0 al llegar a
                 * n_bursts-1, no en 2^18). Se compara contra las
                 * 3.906.250 rafagas/s (500 MB/s) que exige el DAC a
                 * 125 MS/s continuos con 32 muestras por rafaga. */
                {
                    struct timespec t0, t1;
                    uint32_t s0, s1, delta;
                    double elapsed_s, rate_bursts;

                    clock_gettime(CLOCK_MONOTONIC, &t0);
                    s0 = tx_sts[0] & 0x3FFFF;   /* 18 bits */
                    usleep(1000);               /* 1 ms nominal: bien por debajo
                                                  * de una vuelta completa del
                                                  * buffer (~8.3 ms a caudal
                                                  * pleno con 32552 rafagas),
                                                  * para no confundir vueltas
                                                  * multiples con una sola */
                    s1 = tx_sts[0] & 0x3FFFF;
                    clock_gettime(CLOCK_MONOTONIC, &t1);

                    elapsed_s = (t1.tv_sec - t0.tv_sec) +
                                (t1.tv_nsec - t0.tv_nsec) / 1e9;
                    delta = (s1 >= s0) ? (s1 - s0) : (s1 + n_bursts - s0);
                    rate_bursts = delta / elapsed_s;

                    printf("TX: caudal medido = %.0f rafagas/s (%.1f MB/s) "
                           "-- necesario = 3906250 rafagas/s (500.0 MB/s) "
                           "-- %.1f%% del necesario\n",
                           rate_bursts, rate_bursts * 128.0 / 1e6,
                           100.0 * rate_bursts / 3906250.0);
                }

                ack = 0x01;
                send(sock_client, &ack, 1, 0);
            }
            else if(cmd == CMD_TX_STOP) {
                tx_ctrl[0] = 0;
                printf("TX: detenido\n");
                ack = 0x01;
                send(sock_client, &ack, 1, 0);
            }
        }

        /* Al desconectarse el cliente, dejar el reader en reset */
        tx_ctrl[0] = 0;
        printf("Cliente desconectado.\n");
        close(sock_client);
    }
    return 0;
}
