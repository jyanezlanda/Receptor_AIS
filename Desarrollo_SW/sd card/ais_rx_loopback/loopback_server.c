#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>
#include <string.h>
#include <unistd.h>
#include <fcntl.h>
#include <sys/mman.h>
#include <sys/socket.h>
#include <sys/ioctl.h>
#include <netinet/in.h>
#include <linux/spi/spidev.h>

#define TCP_PORT     1003
#define CMD_READ_ADC 0x03
#define CMD_SET_FIFO 0x04
#define CMD_SET_CFG  0x05  // escribe cfg completo (PINC + bit de reset)

volatile uint32_t *cfg, *sts, *data_reg;
int spi_fd = -1;

void spi_write(uint8_t reg, uint16_t val) {
    if(spi_fd < 0) return;
    uint8_t tx[3];
    tx[0] = reg;
    tx[1] = (val >> 8) & 0xFF;
    tx[2] = val & 0xFF;
    struct spi_ioc_transfer tr = {
        .tx_buf        = (unsigned long)tx,
        .rx_buf        = 0,
        .len           = 3,
        .speed_hz      = 1000000,
        .bits_per_word = 8,
    };
    ioctl(spi_fd, SPI_IOC_MESSAGE(1), &tr);
}

int main() {
    // Mapear axi_hub
    int mem_fd = open("/dev/mem", O_RDWR);
    if(mem_fd < 0) { perror("open /dev/mem"); return 1; }

    cfg      = mmap(NULL, 4096, PROT_READ|PROT_WRITE, MAP_SHARED, mem_fd, 0x40000000);
    sts      = mmap(NULL, 4096, PROT_READ|PROT_WRITE, MAP_SHARED, mem_fd, 0x41000000);
    data_reg = mmap(NULL, 4096, PROT_READ|PROT_WRITE, MAP_SHARED, mem_fd, 0x42000000);

    // Abrir SPI (opcional)
    spi_fd = open("/dev/spidev1.0", O_RDWR);
    if(spi_fd < 0) {
        printf("SPI no disponible, continuando sin SPI\n");
    } else {
        int mode = SPI_MODE_0;
        ioctl(spi_fd, SPI_IOC_WR_MODE, &mode);
    }

    // Servidor TCP
    int sock_server = socket(AF_INET, SOCK_STREAM, 0);
    int yes = 1;
    setsockopt(sock_server, SOL_SOCKET, SO_REUSEADDR, &yes, sizeof(yes));

    struct sockaddr_in addr = {
        .sin_family      = AF_INET,
        .sin_addr.s_addr = htonl(INADDR_ANY),
        .sin_port        = htons(TCP_PORT)
    };
    bind(sock_server,  (struct sockaddr*)&addr, sizeof(addr));
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

            if(cmd == CMD_SET_CFG) {
                // payload = valor completo del cfg (PINC<<1 | reset_bit)
                *cfg = payload;
                uint8_t ack = 0x01;
                send(sock_client, &ack, 1, 0);
            }
            else if(cmd == CMD_SET_FIFO) {
                // Preserva el PINC actual, solo modifica el bit 0
                uint32_t current = *cfg;
                if(payload == 0)
                    *cfg = current & ~0x00000001;  // bit 0 = 0 → reset
                else
                    *cfg = current |  0x00000001;  // bit 0 = 1 → run
                uint8_t ack = 0x01;
                send(sock_client, &ack, 1, 0);
            }
            else if(cmd == CMD_READ_ADC) {
                uint32_t n = payload;

                // sts de 64 bits: leer un registro de 32 bits
                // read_count está en sts[0] (los 32 bits bajos)
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
        }
        printf("Cliente desconectado.\n");
        close(sock_client);
    }

    return 0;
}
