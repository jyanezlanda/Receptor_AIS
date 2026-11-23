/*
 * adrf_server.c -- Servidor TCP del ADRF6850 para la Red Pitaya, para el bitstream en que el DAC se maneja por registro.
 *
 * Compilar:  gcc -O2 -Wall adrf_server.c adrf6850.c adrf6850_conf.c agc.c -lm -pthread -o adrf_server
 * Usar:      ./adrf_server_dacreg [-c archivo.conf] [-a] [-d [-F mV] [-O mV]] [-g agc.conf | -n] [-p puerto] [-i pausa_us]
 *
 *   -p  puerto TCP (1005 por defecto; el servidor de datos usa 1003)
 *   -c  archivo de configuracion: se lee y valida al arrancar. Sin -c solo se puede inicializar con CMD_ADRF_INIT_CFG.
 *   -a  hace el init al arrancar con el .conf (exige -c)
 *   -i  pausa en microsegundos tras cada transaccion SPI; solo para el emulador ESP32 (-i 300)
 *   -d  aplica VGAIN por el DAC: cada vez que el driver fija la ganancia escribe la palabra del DAC (cfg[2] del hub del
 *       receptor; OUT2 en los bits 29:16). Sin -d no se toca la FPGA y solo se informa la tension a aplicar en J2,
 *       que es lo que hay que usar si el bitstream no esta cargado.
 *   -F  con -d: mV que suma el codigo maximo del DAC con la carga de VGAIN (1000 por defecto)
 *   -O  con -d: mV con el codigo 0 (0 por defecto)
 *   -g  con -d: archivo de configuracion del AGC (agc.conf). El AGC lleva la ganancia del ADRF segun el pico de cada rafaga
 *       (registro por rafaga de la FPGA, sts[3] y sts[4]); ver agc.h. Con -d y sin -g el AGC arranca activado con los parametros por
 *       defecto (los de agc.conf); con -g, activado o no segun 'activo' del archivo.
 *   -n  con -d: sin AGC al arrancar; se configura y activa con CMD_ADRF_AGC_SET. No se combina con -g.
 *
 * Protocolo: 1 byte de comando + 4 bytes de payload (little-endian). La respuesta es 1 byte (0x01 = ok, 0x00 = error)
 * salvo en los comandos que devuelven datos:
 *   GET_STATE   ADRF_STATE_WIRE_BYTES bytes
 *   READ_REG    [0x01, valor], o [0x00, 0x00] si la direccion no existe (leer despues del init: en modo I2C no vale)
 *   GET_CONF    1 + ADRF_CONF_WIRE_BYTES bytes: [0x01, ...], o [0x00, ceros] si no hay .conf
 *   GET_VERIFY  1 + ADRF_VERIFY_WIRE_BYTES bytes: [0x01, escrituras, reintentos, fallas (u32), registro, escrito, leido (u8)]
 *               de la ultima operacion que escribio registros (init, update o set_lo)
 *   INIT_CFG    en dos pasos: el cliente manda [cmd][payload = ADRF_CFG_WIRE_BYTES]; el servidor contesta 0x01 (listo) o
 *               0x00 (rechazado: el cliente no manda los datos); luego el cliente manda la configuracion y el servidor
 *               contesta el resultado. Asi un servidor que no conoce el comando no toma los datos por comandos.
 *   VGAIN_RAW   payload = codigo del DAC (0 a 8191), sin conversion ni limite de tension; error sin -d o fuera de rango
 *   GET_VGAIN   1 + ADRF_VGAIN_WIRE_BYTES bytes: [ok, codigo, pedido_mv, efectivo_mv] (u16 cada uno; ok = 0 sin -d)
 *   AGC_SET     en dos pasos, como INIT_CFG: [cmd][payload = AGC_SET_WIRE_BYTES]; el servidor contesta 0x01 (listo) o 0x00; luego el
 *               cliente manda [activar u32][ganancia inicial en mdB i32, -1 = no cambiarla][usar_parametros u32][13 parametros u32]
 *               y el servidor contesta 0x01 o 0x00 (sin -d, ADRF sin inicializar, parametros invalidos o ganancia inicial fuera de
 *               rango). Activar con parametros nuevos reinicia la ventana y los contadores. Una orden de activar que falla deja
 *               el AGC desactivado.
 *   AGC_GET     1 + AGC_GET_WIRE_BYTES bytes: [ok][activo, ganancia mdB (i32), rafagas, cambios, protecciones, ultimo pico, t_ms,
 *               seq, errores][13 parametros]; ok = 0 sin -d. Todo u32 little-endian.
 *   AGC_LOG     payload = seq desde la que se piden registros; responde [ok][seq u32][n u32] y n registros de AGC_REG_BYTES bytes
 *               (t_ms, pico, referencia, error en cdB, ganancia antes y despues en mdB, flags: bit 0 cambio, bit 1 proteccion).
 *               Guarda los ultimos AGC_LOG_N.
 * Un mutex protege el driver, el DAC y el estado del AGC: lo toman los comandos y el hilo del AGC.
 * Este proceso es el unico dueño de /dev/spidev1.0.
 */
#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>
#include <string.h>
#include <errno.h>
#include <signal.h>
#include <unistd.h>
#include <fcntl.h>
#include <sys/ioctl.h>
#include <sys/mman.h>
#include <sys/socket.h>
#include <netinet/in.h>
#include <netinet/tcp.h>
#include <linux/spi/spidev.h>
#include <math.h>
#include <pthread.h>
#include <time.h>

#include "adrf6850.h"
#include "adrf6850_conf.h"
#include "agc.h"

#define TCP_PORT_DEFECTO     1005

#define CMD_ADRF_INIT        0x10   /* payload ignorado: adrf6850_init() con la configuracion del .conf */
#define CMD_ADRF_UPDATE      0x11   /* payload = ADRF_UPDATE_WIRE_BYTES, seguido de esos bytes */
#define CMD_ADRF_GET_STATE   0x12   /* payload ignorado: responde ADRF_STATE_WIRE_BYTES bytes  */
#define CMD_ADRF_SET_LO      0x13   /* payload = LO en Hz                                      */
#define CMD_ADRF_SET_GAIN    0x14   /* payload = ganancia en mili-dB (0 a 60000)               */
#define CMD_ADRF_READ_REG    0x15   /* payload = direccion del registro (0 a 33); responde 2 bytes */
#define CMD_ADRF_INIT_CFG    0x16   /* payload = ADRF_CFG_WIRE_BYTES: init con la configuracion del cliente (2 pasos) */
#define CMD_ADRF_GET_CONF    0x17   /* responde 1 + ADRF_CONF_WIRE_BYTES bytes: el .conf del servidor */
#define CMD_ADRF_GET_VERIFY  0x18   /* responde 1 + ADRF_VERIFY_WIRE_BYTES bytes: verificacion de la ultima operacion */
#define CMD_ADRF_VGAIN_RAW   0x19   /* payload = codigo del DAC de VGAIN (0 a 8191) */
#define CMD_ADRF_GET_VGAIN   0x1A   /* responde 1 + ADRF_VGAIN_WIRE_BYTES bytes: codigo y tensiones de VGAIN */
#define CMD_ADRF_AGC_SET     0x1B   /* payload = AGC_SET_WIRE_BYTES; en dos pasos */
#define CMD_ADRF_AGC_GET     0x1C   /* responde 1 + AGC_GET_WIRE_BYTES bytes: estado y parametros del AGC */
#define CMD_ADRF_AGC_LOG     0x1D   /* payload = seq desde la que se piden registros */

#define ADRF_REG_MAX         0x21u  /* CR33 (codigo de revision) es el ultimo registro */

#define ADRF_UPDATE_WIRE_BYTES  18u
#define ADRF_STATE_WIRE_BYTES   26u
#define ADRF_VERIFY_WIRE_BYTES  15u   /* writes u32, retries u32, failures u32, fail_addr u8, fail_wrote u8, fail_read u8 */
#define ADRF_CFG_WIRE_BYTES     33u   /* adrf6850_config_t */
#define ADRF_VGAIN_WIRE_BYTES    6u   /* codigo u16, pedido_mv u16, efectivo_mv u16 */
#define ADRF_CONF_WIRE_BYTES    54u   /* adrf6850_config_t + f_rf_hz + f_fi_hz + corr_ppm + lo_explicito + crc32 */

static volatile sig_atomic_t g_stop = 0;
static unsigned g_pausa_us = 0;       /* -i */
static adrf_conf_t g_conf;            /* configuracion leida del .conf (-c) */
static int g_conf_cargada = 0;        /* 1 si se dio -c y el archivo se leyo bien */

static pthread_mutex_t g_mtx = PTHREAD_MUTEX_INITIALIZER;   /* driver, DAC y estado del AGC */
#define BLOQUEAR()    pthread_mutex_lock(&g_mtx)
#define DESBLOQUEAR() pthread_mutex_unlock(&g_mtx)
static __thread int t_agc = 0;        /* 1 mientras el hilo del AGC cambia la ganancia: no se imprime cada cambio */

/* ---- SPI (spidev): inicio ---- */
#define ADRF_SPI_DEVICE     "/dev/spidev1.0"
#define ADRF_SPI_SPEED_HZ   1000000u

static int adrf_spi_fd = -1;

static int adrf_spi_init(const char *device)
{
    uint8_t  mode  = SPI_MODE_0;
    uint8_t  bits  = 8;
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
    printf("ADRF: %s abierto (modo %u, %u bits, %u Hz)\n", device, mode, bits, speed);
    return 0;
}

static void adrf_spi_close(void)
{
    if (adrf_spi_fd >= 0) { close(adrf_spi_fd); adrf_spi_fd = -1; }
}

static void spi_transferir(const uint8_t *tx, uint8_t *rx, uint32_t len, const char *que)
{
    struct spi_ioc_transfer xfer;

    memset(&xfer, 0, sizeof(xfer));
    xfer.tx_buf        = (unsigned long)(uintptr_t)tx;
    xfer.rx_buf        = (unsigned long)(uintptr_t)rx;
    xfer.len           = len;
    xfer.speed_hz      = ADRF_SPI_SPEED_HZ;
    xfer.bits_per_word = 8;
    if (ioctl(adrf_spi_fd, SPI_IOC_MESSAGE(1), &xfer) < 0) {
        fprintf(stderr, "ADRF: SPI %s fallo: %s\n", que, strerror(errno));
    }
}
/* ---- SPI (spidev): fin ---- */

/* Hooks que pide el driver. La pausa (-i) va aca, fuera del bloque de spidev. */
static void pausa_spi(void)
{
    if (g_pausa_us > 0) usleep(g_pausa_us);
}

void adrf6850_hw_spi_write(const uint8_t *buf, uint32_t len)
{
    if (adrf_spi_fd < 0 || len == 0U) return;
    spi_transferir(buf, NULL, len, "write");
    pausa_spi();
}

/* Full-duplex: tx y rx en un solo mensaje spidev, con CS bajo todo el tiempo (la lectura de un registro saca el dato
 * por SDO en el mismo frame que el comando 0xD5). */
void adrf6850_hw_spi_xfer(const uint8_t *tx, uint8_t *rx, uint32_t len)
{
    if (adrf_spi_fd < 0 || len == 0U || len > 8U) return;
    spi_transferir(tx, rx, len, "xfer");
    pausa_spi();
}

int adrf6850_hw_ldet_read(void)
{
    /* LDET (pin 40) solo llega a R2 y al LED D3, no a un GPIO: se devuelve -1 y el driver espera un tiempo fijo.
     * init y set_lo no confirman el enganche del PLL; se mira en LDET o en D3. Con LDET en un GPIO, leerlo aca (0/1). */
    return -1;
}

/* ---- VGAIN por el DAC ---- */
#define VGAIN_REG_BASE     0x40000000u   /* hub del receptor */
#define VGAIN_REG_PALABRA  2u            /* cfg_data[95:64]: la palabra del DAC; el canal B (OUT2) va en los bits 29:16 */
#define DAC_CODIGO_MAX     8191u         /* codigo maximo de 14 bits con signo */
#define VGAIN_MAX_MV       1500u         /* rango de VGAIN: 0 a 1,5 V */

static double g_dac_fs_mv = 1000.0;      /* -F: mV que suma el codigo maximo */
static double g_dac_off_mv = 0.0;        /* -O: mV con el codigo 0 */
static unsigned g_vgain_pedido_mv = 0;   /* ultima tension pedida (por el driver o por VGAIN_RAW) */

/* ---- Registro de VGAIN: inicio ---- */
static volatile uint32_t *g_vgain_reg = NULL;   /* NULL: VGAIN no se aplica (se informa la tension a aplicar en J2) */
static int g_vgain_mem_fd = -1;

static int vgain_reg_abrir(void)
{
    void *p;

    g_vgain_mem_fd = open("/dev/mem", O_RDWR | O_SYNC);
    if (g_vgain_mem_fd < 0) { perror("open /dev/mem"); return -1; }
    p = mmap(NULL, 4096, PROT_READ | PROT_WRITE, MAP_SHARED, g_vgain_mem_fd, VGAIN_REG_BASE);
    if (p == MAP_FAILED) { perror("mmap /dev/mem"); close(g_vgain_mem_fd); g_vgain_mem_fd = -1; return -1; }
    g_vgain_reg = (volatile uint32_t *)p + VGAIN_REG_PALABRA;
    return 0;
}

static void vgain_reg_escribir(uint32_t palabra) { *g_vgain_reg = palabra; }
static uint32_t vgain_reg_leer(void) { return *g_vgain_reg; }

static void vgain_reg_cerrar(void)
{
    if (g_vgain_reg) munmap((void *)(g_vgain_reg - VGAIN_REG_PALABRA), 4096);
    g_vgain_reg = NULL;
    if (g_vgain_mem_fd >= 0) close(g_vgain_mem_fd);
    g_vgain_mem_fd = -1;
}
/* ---- Registro de VGAIN: fin ---- */

/* ---- Registros de la FPGA para el AGC: inicio ---- */
#define STS_BASE      0x41000000u   /* registros de estado del receptor; el registro por rafaga es sts[3] y sts[4] */
static volatile uint32_t *g_sts = NULL;   /* NULL: sin AGC */

static int sts_abrir(void)
{
    void *p;

    if (g_vgain_mem_fd < 0) return -1;
    p = mmap(NULL, 4096, PROT_READ, MAP_SHARED, g_vgain_mem_fd, STS_BASE);
    if (p == MAP_FAILED) { perror("mmap /dev/mem (sts)"); return -1; }
    g_sts = (volatile uint32_t *)p;
    return 0;
}

static void sts_cerrar(void)
{
    if (g_sts) munmap((void *)g_sts, 4096);
    g_sts = NULL;
}
/* ---- Registros de la FPGA para el AGC: fin ---- */

/* Codigo del DAC para mv milivoltios en VGAIN: se limita a 0..VGAIN_MAX_MV y al fondo de escala; nunca es negativo. */
static uint32_t vgain_mv_a_codigo(unsigned mv)
{
    double v = (mv > VGAIN_MAX_MV) ? (double)VGAIN_MAX_MV : (double)mv;
    double c = (v - g_dac_off_mv) / g_dac_fs_mv * DAC_CODIGO_MAX;

    if (c < 0.0) c = 0.0;
    if (c > (double)DAC_CODIGO_MAX) c = (double)DAC_CODIGO_MAX;
    return (uint32_t)(c + 0.5);
}

static unsigned vgain_codigo_a_mv(uint32_t codigo)
{
    double v = g_dac_off_mv + g_dac_fs_mv * (double)codigo / DAC_CODIGO_MAX;

    return (v <= 0.0) ? 0u : (unsigned)(v + 0.5);
}

/* Escribe la palabra del DAC (canal B) y la lee de vuelta: -1 si el registro no quedo como se escribio. */
static int vgain_escribir(uint32_t codigo)
{
    uint32_t palabra = codigo << 16, leido;

    vgain_reg_escribir(palabra);
    leido = vgain_reg_leer();
    if (leido != palabra) {
        fprintf(stderr, "ADRF: VGAIN: se escribio 0x%08X en el registro del DAC y se leyo 0x%08X\n", palabra, leido);
        return -1;
    }
    return 0;
}

int adrf6850_hw_vgain_set_mv(uint16_t mv)
{
    uint32_t codigo;
    unsigned efectivo;

    /* Sin -d, VGAIN viene de una fuente externa en J2 y el hook solo informa la tension a aplicar. */
    if (g_vgain_reg == NULL) {
        printf("ADRF: VGAIN externo (J2): aplicar %u mV\n", (unsigned)mv);
        return 0;
    }
    codigo = vgain_mv_a_codigo(mv);
    if (vgain_escribir(codigo) < 0) return -1;         /* != 0 hace fallar el init o el set_gain */
    g_vgain_pedido_mv = mv;
    efectivo = vgain_codigo_a_mv(codigo);
    if (!t_agc)
        printf("ADRF: VGAIN por el DAC: %u mV pedidos -> codigo %u (%u mV)%s\n", (unsigned)mv, codigo, efectivo,
               ((unsigned)mv > efectivo + 1u) ? " [el DAC no llega a la tension pedida]" : "");
    return 0;
}

/* ---- serializacion de adrf6850_params_t / adrf6850_state_t (little-endian) ---- */
static void wr_u32(uint8_t *p, uint32_t v)
{
    p[0] = (uint8_t)v; p[1] = (uint8_t)(v >> 8); p[2] = (uint8_t)(v >> 16); p[3] = (uint8_t)(v >> 24);
}
static void wr_u16(uint8_t *p, uint16_t v) { p[0] = (uint8_t)v; p[1] = (uint8_t)(v >> 8); }
static uint32_t rd_u32(const uint8_t *p)
{
    return (uint32_t)p[0] | ((uint32_t)p[1] << 8) | ((uint32_t)p[2] << 16) | ((uint32_t)p[3] << 24);
}

/* Informe del enlace SPI: solo habla si hubo un reintento o una falla (con el enlace sano no imprime nada).
 * "que" es la operacion; "st" su resultado. */
static void informar_verificacion(const char *que, adrf6850_status_t st)
{
    adrf6850_verify_stats_t v;

    adrf6850_get_verify_stats(&v);
    if (v.retries > 0U || v.failures > 0U)
        printf("ADRF: %s: escrituras verificadas: %u, reintentos: %u, fallas: %u\n",
               que, (unsigned)v.writes, (unsigned)v.retries, (unsigned)v.failures);
    if (st == ADRF6850_ERR_VERIFY)
        printf("ADRF: %s: FALLO la verificacion de CR%u: escrito 0x%02X, leido 0x%02X, aun despues de los reintentos\n",
               que, (unsigned)v.fail_addr, (unsigned)v.fail_wrote, (unsigned)v.fail_read);
}

/* adrf6850_config_t (ADRF_CFG_WIRE_BYTES = 33): refin_hz u32, ref_doubler_en u8, ref_div2_en u8, ref_rdiv_en u8,
 * ref_rdiv u8, vocm_internal u8, vga_polarity u8, muxout u8, autocal_time_us u32, lock_timeout_us u32, lo_hz u32,
 * gain_mdb i32, bb_wideband u8, bb_fc u8, cp_code u8, lomon_en u8, lomon_pwr u8, verify_retries u8 */
static void cfg_a_cable(const adrf6850_config_t *c, uint8_t *w)
{
    wr_u32(w + 0, c->refin_hz);
    w[4] = c->ref_doubler_en; w[5] = c->ref_div2_en; w[6] = c->ref_rdiv_en; w[7] = c->ref_rdiv;
    w[8] = c->vocm_internal;  w[9] = c->vga_polarity; w[10] = c->muxout;
    wr_u32(w + 11, c->autocal_time_us);
    wr_u32(w + 15, c->lock_timeout_us);
    wr_u32(w + 19, c->lo_hz);
    wr_u32(w + 23, (uint32_t)c->gain_mdb);
    w[27] = c->bb_wideband; w[28] = (uint8_t)c->bb_fc; w[29] = c->cp_code; w[30] = c->lomon_en; w[31] = (uint8_t)c->lomon_pwr;
    w[32] = c->verify_retries;
}

static void cfg_desde_cable(const uint8_t *w, adrf6850_config_t *c)
{
    memset(c, 0, sizeof(*c));
    c->refin_hz        = rd_u32(w + 0);
    c->ref_doubler_en  = w[4];  c->ref_div2_en = w[5];  c->ref_rdiv_en = w[6];  c->ref_rdiv = w[7];
    c->vocm_internal   = w[8];  c->vga_polarity = w[9]; c->muxout = w[10];
    c->autocal_time_us = rd_u32(w + 11);
    c->lock_timeout_us = rd_u32(w + 15);
    c->lo_hz           = rd_u32(w + 19);
    c->gain_mdb        = (int32_t)rd_u32(w + 23);
    c->bb_wideband     = w[27]; c->bb_fc = (adrf6850_bb_fc_t)w[28]; c->cp_code = w[29];
    c->lomon_en        = w[30]; c->lomon_pwr = (adrf6850_lomon_pwr_t)w[31];
    c->verify_retries  = w[32];
}

/* .conf del servidor (ADRF_CONF_WIRE_BYTES = 54): adrf6850_config_t (33), f_rf_hz u32, f_fi_hz u32, corr_ppm f64,
 * lo_explicito u8, crc32 u32 */
static void conf_a_cable(const adrf_conf_t *c, uint8_t *w)
{
    double ppm = c->corr_ppm;
    cfg_a_cable(&c->drv, w);
    wr_u32(w + 33, c->f_rf_hz);
    wr_u32(w + 37, c->f_fi_hz);
    memcpy(w + 41, &ppm, sizeof(ppm));
    w[49] = (uint8_t)(c->lo_explicito ? 1 : 0);
    wr_u32(w + 50, c->crc32);
}

/* CMD_ADRF_UPDATE: mask u32, lo_hz u32, gain_mdb i32, bb_wideband u8, bb_fc u8, lomon_en u8,
 * lomon_pwr u8, cp_code u8, fast_hop u8 */
static void params_desde_cable(const uint8_t *w, adrf6850_params_t *p)
{
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

/* CMD_ADRF_GET_STATE: initialized u8, lo_hz u32, lo_actual_hz u32, rfdiv u8, n_int u16, n_frac u32,
 * gain_mdb i32, vgain_mv u16, bb_wideband u8, bb_fc u8, cp_code u8, autocal_off u8 */
static void estado_a_cable(const adrf6850_state_t *s, uint8_t *w)
{
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

/* ---- red ---- */
/* ---- AGC ---- */
#define AGC_LOG_N              256u
#define AGC_REG_BYTES          28u                              /* t_ms, pico, ref (u32); err_cdb, g_antes_mdb, g_mdb (i32); flags (u32) */
#define AGC_PARAMS_WIRE_BYTES  52u                              /* 13 palabras u32: ver agc_params_a_cable */
#define AGC_SET_WIRE_BYTES     (12u + AGC_PARAMS_WIRE_BYTES)    /* activar, ganancia inicial (mdB), usar_parametros, parametros */
#define AGC_GET_WIRE_BYTES     (36u + AGC_PARAMS_WIRE_BYTES)    /* 9 palabras de estado y los parametros */

typedef struct { uint32_t t_ms, pico, ref; int32_t err_cdb, g_antes_mdb, g_mdb; uint32_t flags; } agc_reg_t;

static agc_t g_agc;                         /* parametros y estado del AGC */
static int g_agc_listo = 0;                 /* hay parametros (del .conf o del cliente) */
static volatile int g_agc_activo = 0;
static volatile int g_agc_pend_ini = 0;     /* llevar a g_inicial_db cuando el ADRF este inicializado */
static agc_reg_t g_agc_log[AGC_LOG_N];
static uint32_t g_agc_seq = 0;              /* rafagas registradas desde que arranco el servidor */
static uint32_t g_agc_ult_pico = 0, g_agc_errores = 0;
static pthread_t g_agc_th;
static int g_agc_th_vivo = 0;
static struct timespec g_t0;

static uint32_t ahora_ms(void)
{
    struct timespec t;
    long long ms;

    clock_gettime(CLOCK_MONOTONIC, &t);
    ms = (long long)(t.tv_sec - g_t0.tv_sec) * 1000 + (t.tv_nsec - g_t0.tv_nsec) / 1000000;
    return (uint32_t)ms;
}

static void agc_params_a_cable(const agc_params_t *p, uint8_t *w)
{
    wr_u32(w + 0,  (uint32_t)lround(p->objetivo));
    wr_u32(w + 4,  (uint32_t)p->ventana);
    wr_u32(w + 8,  (uint32_t)lround(p->percentil * 100.0));
    wr_u32(w + 12, (uint32_t)lround(p->zona_muerta_db * 100.0));
    wr_u32(w + 16, (uint32_t)lround(p->kp * 1000.0));
    wr_u32(w + 20, (uint32_t)lround(p->paso_max_db * 1000.0));
    wr_u32(w + 24, (uint32_t)p->liberacion_rafagas);
    wr_u32(w + 28, (uint32_t)lround(p->paso_liberacion_db * 1000.0));
    wr_u32(w + 32, (uint32_t)lround(p->nivel_proteccion));
    wr_u32(w + 36, (uint32_t)lround(p->g_min_db * 1000.0));
    wr_u32(w + 40, (uint32_t)lround(p->g_max_db * 1000.0));
    wr_u32(w + 44, (uint32_t)lround(p->planta * 1000.0));
    wr_u32(w + 48, (uint32_t)lround(p->g_inicial_db * 1000.0));
}

static void agc_params_desde_cable(const uint8_t *w, agc_params_t *p)
{
    p->objetivo           = (double)rd_u32(w + 0);
    p->ventana            = (int)rd_u32(w + 4);
    p->percentil          = rd_u32(w + 8) / 100.0;
    p->zona_muerta_db     = rd_u32(w + 12) / 100.0;
    p->kp                 = rd_u32(w + 16) / 1000.0;
    p->paso_max_db        = rd_u32(w + 20) / 1000.0;
    p->liberacion_rafagas = (int)rd_u32(w + 24);
    p->paso_liberacion_db = rd_u32(w + 28) / 1000.0;
    p->nivel_proteccion   = (double)rd_u32(w + 32);
    p->g_min_db           = rd_u32(w + 36) / 1000.0;
    p->g_max_db           = rd_u32(w + 40) / 1000.0;
    p->planta             = rd_u32(w + 44) / 1000.0;
    p->g_inicial_db       = rd_u32(w + 48) / 1000.0;
}

/* Con g_mtx tomado. */
static int agc_poner_ganancia(double g_db)
{
    int ok;

    t_agc = 1;
    ok = adrf6850_set_gain_mdb((int32_t)lround(g_db * 1000.0)) == ADRF6850_OK;
    t_agc = 0;
    return ok;
}

/* Con g_mtx tomado. 0 si queda como se pidio. Una orden de activar que falla deja el AGC desactivado. */
static int agc_activar(int activar, int32_t g_ini_mdb, const agc_params_t *nuevos)
{
    g_agc_activo = 0;
    g_agc_pend_ini = 0;
    if (!activar) return 0;
    if (g_sts == NULL || g_vgain_reg == NULL || !adrf6850_get_state()->initialized) return -1;
    if (nuevos != NULL) agc_iniciar(&g_agc, nuevos);
    else if (g_agc_listo) agc_iniciar(&g_agc, &g_agc.p);
    else return -1;
    g_agc_listo = 1;
    if (g_ini_mdb >= 0) {
        double g = g_ini_mdb / 1000.0;

        if (g < g_agc.p.g_min_db || g > g_agc.p.g_max_db || !agc_poner_ganancia(g)) return -1;
    }
    g_agc_activo = 1;
    return 0;
}

/* Con g_mtx tomado: una rafaga con pico valido. */
static void agc_procesar(uint32_t pico)
{
    const adrf6850_state_t *st = adrf6850_get_state();
    int32_t g_antes_mdb = st->gain_mdb;
    agc_paso_t r;
    agc_reg_t *e = &g_agc_log[g_agc_seq % AGC_LOG_N];

    if (!st->initialized) return;
    r = agc_rafaga(&g_agc, (double)pico, g_antes_mdb / 1000.0);
    if (r.cambio && !agc_poner_ganancia(r.g_nueva_db)) g_agc_errores++;
    e->t_ms = ahora_ms();
    e->pico = pico;
    e->ref = (uint32_t)lround(r.ref);
    e->err_cdb = (int32_t)lround(r.err_db * 100.0);
    e->g_antes_mdb = g_antes_mdb;
    e->g_mdb = adrf6850_get_state()->gain_mdb;
    e->flags = (r.cambio ? 1u : 0u) | (r.proteccion ? 2u : 0u);
    g_agc_ult_pico = pico;
    g_agc_seq++;
}

/* Sondea el registro por rafaga cada 2 ms; sts[3] bits 19:0 pico y 31:20 contador, sts[4] bit 16 pico valido. El par se lee
 * sts[3], sts[4], sts[3] y se repite si el contador cambio. Sin rafagas no hace nada. */
static void *agc_hilo(void *arg)
{
    struct timespec dt = { 0, 2000000L };
    uint32_t ult = g_sts[3] >> 20;

    (void)arg;
    while (!g_stop) {
        uint32_t a, b, c;
        int n = 0;

        nanosleep(&dt, NULL);
        if (g_agc_pend_ini) {                                   /* arranque en la ganancia conocida, aunque no haya rafagas */
            BLOQUEAR();
            if (g_agc_pend_ini && adrf6850_get_state()->initialized) {
                g_agc_pend_ini = 0;
                if (agc_poner_ganancia(g_agc.p.g_inicial_db)) printf("AGC: arranca en %.1f dB\n", g_agc.p.g_inicial_db);
                else { g_agc_activo = 0; fprintf(stderr, "AGC: no se pudo llevar la ganancia a %.1f dB; desactivado\n", g_agc.p.g_inicial_db); }
            }
            DESBLOQUEAR();
        }
        do { a = g_sts[3]; b = g_sts[4]; c = g_sts[3]; } while (a != c && ++n < 4);
        if ((c >> 20) == ult) continue;
        ult = c >> 20;
        if (!((b >> 16) & 1u)) continue;
        BLOQUEAR();
        if (g_agc_activo && !g_agc_pend_ini) agc_procesar(c & 0xFFFFFu);
        DESBLOQUEAR();
    }
    return NULL;
}

/* AGC_SET, segundo paso: 1 si quedo como se pidio. */
static int agc_comando_set(const uint8_t *w)
{
    uint32_t activar = rd_u32(w), usar = rd_u32(w + 8);
    int32_t g_ini = (int32_t)rd_u32(w + 4);
    agc_params_t pp;
    char err[160];
    int ok;

    memset(&pp, 0, sizeof(pp));
    if (activar && usar) {
        agc_params_desde_cable(w + 12, &pp);
        if (agc_params_validar(&pp, err, sizeof(err)) != 0) {
            fprintf(stderr, "AGC: parametros rechazados: %s\n", err);
            BLOQUEAR();
            agc_activar(0, -1, NULL);                   /* una orden de activar que falla deja el AGC desactivado */
            DESBLOQUEAR();
            return 0;
        }
    }
    BLOQUEAR();
    ok = agc_activar(activar != 0, g_ini, usar ? &pp : NULL) == 0;
    DESBLOQUEAR();
    printf("AGC: %s -> %s\n", activar ? "activar" : "desactivar", ok ? "ok" : "rechazado");
    return ok;
}

static void agc_get_a_cable(uint8_t *w)             /* 1 + AGC_GET_WIRE_BYTES bytes */
{
    memset(w, 0, 1 + AGC_GET_WIRE_BYTES);
    if (g_sts == NULL) return;
    w[0] = 0x01;
    BLOQUEAR();
    wr_u32(w + 1,  g_agc_activo ? 1u : 0u);
    wr_u32(w + 5,  (uint32_t)adrf6850_get_state()->gain_mdb);
    wr_u32(w + 9,  g_agc.rafagas);
    wr_u32(w + 13, g_agc.cambios);
    wr_u32(w + 17, g_agc.protecciones);
    wr_u32(w + 21, g_agc_ult_pico);
    wr_u32(w + 25, ahora_ms());
    wr_u32(w + 29, g_agc_seq);
    wr_u32(w + 33, g_agc_errores);
    agc_params_a_cable(&g_agc.p, w + 37);
    DESBLOQUEAR();
}

static size_t agc_log_a_cable(uint32_t desde, uint8_t *w)   /* 9 + n * AGC_REG_BYTES bytes; devuelve el largo */
{
    uint32_t seq, ini, n, k;

    BLOQUEAR();
    seq = g_agc_seq;
    ini = (seq > AGC_LOG_N) ? seq - AGC_LOG_N : 0;
    if (desde > ini) ini = desde;
    n = (seq > ini) ? seq - ini : 0;
    w[0] = (g_sts != NULL) ? 0x01 : 0x00;
    wr_u32(w + 1, seq);
    wr_u32(w + 5, n);
    for (k = 0; k < n; k++) {
        const agc_reg_t *e = &g_agc_log[(ini + k) % AGC_LOG_N];
        uint8_t *q = w + 9 + k * AGC_REG_BYTES;

        wr_u32(q, e->t_ms); wr_u32(q + 4, e->pico); wr_u32(q + 8, e->ref);
        wr_u32(q + 12, (uint32_t)e->err_cdb); wr_u32(q + 16, (uint32_t)e->g_antes_mdb); wr_u32(q + 20, (uint32_t)e->g_mdb);
        wr_u32(q + 24, e->flags);
    }
    DESBLOQUEAR();
    return 9 + (size_t)n * AGC_REG_BYTES;
}
/* ---- AGC: fin ---- */

static void on_signal(int sig) { (void)sig; g_stop = 1; }

static int recv_all(int fd, void *buf, size_t len)
{
    size_t got = 0;
    uint8_t *p = (uint8_t *)buf;
    while (got < len) {
        ssize_t r = recv(fd, p + got, len - got, 0);
        if (r > 0) { got += (size_t)r; continue; }
        if (r < 0 && errno == EINTR) { if (g_stop) return -1; continue; }
        return -1;                       /* conexion cerrada o error */
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

/* Atiende a un cliente hasta que se desconecta. Devuelve cuando se corta la conexion. */
static void atender(int fd)
{
    uint8_t cmd;
    uint32_t payload;

    while (!g_stop) {
        adrf6850_status_t st;

        if (recv_all(fd, &cmd, 1) < 0 || recv_all(fd, &payload, 4) < 0) return;

        switch (cmd) {
        case CMD_ADRF_INIT:
            if (!g_conf_cargada) {
                fprintf(stderr, "ADRF: CMD_ADRF_INIT sin .conf cargado (arrancar con -c, o usar CMD_ADRF_INIT_CFG)\n");
                if (responder(fd, 0) < 0) return;
                break;
            }
            BLOQUEAR();
            st = adrf6850_init(&g_conf.drv);
            informar_verificacion("init", st);
            DESBLOQUEAR();
            printf("ADRF: init -> %d\n", (int)st);
            if (responder(fd, st == ADRF6850_OK) < 0) return;
            break;

        case CMD_ADRF_INIT_CFG: {
            uint8_t w[ADRF_CFG_WIRE_BYTES];
            adrf6850_config_t cfg;

            if (payload != ADRF_CFG_WIRE_BYTES) {
                fprintf(stderr, "ADRF: CMD_ADRF_INIT_CFG con payload=%u, se esperaban %u bytes\n", payload, ADRF_CFG_WIRE_BYTES);
                if (responder(fd, 0) < 0) return;           /* el cliente no manda los datos si recibe 0x00 */
                break;
            }
            if (responder(fd, 1) < 0) return;               /* paso 1: listo para recibir la configuracion */
            if (recv_all(fd, w, sizeof(w)) < 0) return;
            cfg_desde_cable(w, &cfg);
            BLOQUEAR();
            st = adrf6850_validate_config(&cfg);
            if (st != ADRF6850_OK) {
                fprintf(stderr, "ADRF: configuracion del cliente rechazada por el driver (codigo %d): no se toco el chip\n", (int)st);
            } else {
                printf("ADRF: configuracion del cliente: LO = %.6f MHz, ganancia %.1f dB, filtro %s %d MHz, bomba 0x%X\n",
                       cfg.lo_hz / 1e6, cfg.gain_mdb / 1000.0, cfg.bb_wideband ? "wideband, corte" : "narrow-band",
                       (int[]){50, 43, 37, 30}[(int)cfg.bb_fc & 3], (unsigned)cfg.cp_code);
                st = adrf6850_init(&cfg);
                informar_verificacion("init (configuracion del cliente)", st);
            }
            DESBLOQUEAR();
            printf("ADRF: init (configuracion del cliente) -> %d\n", (int)st);
            if (responder(fd, st == ADRF6850_OK) < 0) return;   /* paso 2: resultado */
            break;
        }

        case CMD_ADRF_GET_VERIFY: {
            uint8_t w[1 + ADRF_VERIFY_WIRE_BYTES];
            adrf6850_verify_stats_t v;

            BLOQUEAR();
            adrf6850_get_verify_stats(&v);
            DESBLOQUEAR();
            w[0] = 0x01;
            wr_u32(w + 1, v.writes);
            wr_u32(w + 5, v.retries);
            wr_u32(w + 9, v.failures);
            w[13] = v.fail_addr; w[14] = v.fail_wrote; w[15] = v.fail_read;
            if (send_all(fd, w, sizeof(w)) < 0) return;
            break;
        }

        case CMD_ADRF_GET_CONF: {
            uint8_t w[1 + ADRF_CONF_WIRE_BYTES];

            memset(w, 0, sizeof(w));
            if (g_conf_cargada) {
                w[0] = 0x01;
                conf_a_cable(&g_conf, w + 1);
            } else {
                fprintf(stderr, "ADRF: CMD_ADRF_GET_CONF sin .conf cargado (arrancar con -c)\n");
            }
            if (send_all(fd, w, sizeof(w)) < 0) return;
            break;
        }

        case CMD_ADRF_UPDATE: {
            uint8_t w[ADRF_UPDATE_WIRE_BYTES];
            adrf6850_params_t p;

            if (payload != ADRF_UPDATE_WIRE_BYTES) {
                /* se drenan igual los bytes que el cliente va a mandar, o la conexion se desincroniza */
                uint8_t basura[256];
                fprintf(stderr, "ADRF: CMD_ADRF_UPDATE con payload=%u, se esperaban %u bytes\n",
                        payload, ADRF_UPDATE_WIRE_BYTES);
                while (payload > 0) {
                    uint32_t n = payload < sizeof(basura) ? payload : (uint32_t)sizeof(basura);
                    if (recv_all(fd, basura, n) < 0) return;
                    payload -= n;
                }
                if (responder(fd, 0) < 0) return;
                break;
            }
            if (recv_all(fd, w, sizeof(w)) < 0) return;
            params_desde_cable(w, &p);
            BLOQUEAR();
            adrf6850_clear_verify_stats();
            st = adrf6850_update(&p);
            informar_verificacion("update", st);
            DESBLOQUEAR();
            printf("ADRF: update (mask=0x%02X) -> %d\n", (unsigned)p.mask, (int)st);
            if (responder(fd, st == ADRF6850_OK) < 0) return;
            break;
        }

        case CMD_ADRF_GET_STATE: {
            uint8_t w[ADRF_STATE_WIRE_BYTES];
            BLOQUEAR();
            estado_a_cable(adrf6850_get_state(), w);
            DESBLOQUEAR();
            if (send_all(fd, w, sizeof(w)) < 0) return;
            break;
        }

        case CMD_ADRF_SET_LO:
            BLOQUEAR();
            adrf6850_clear_verify_stats();
            st = adrf6850_set_lo(payload);
            informar_verificacion("set_lo", st);
            DESBLOQUEAR();
            printf("ADRF: set_lo(%u Hz) -> %d\n", payload, (int)st);
            if (responder(fd, st == ADRF6850_OK) < 0) return;
            break;

        case CMD_ADRF_SET_GAIN: {
            int32_t gain_mdb = (int32_t)payload;
            BLOQUEAR();
            st = adrf6850_set_gain_mdb(gain_mdb);
            DESBLOQUEAR();
            printf("ADRF: set_gain(%d mdB) -> %d\n", gain_mdb, (int)st);
            if (responder(fd, st == ADRF6850_OK) < 0) return;
            break;
        }

        case CMD_ADRF_READ_REG: {
            uint8_t resp[2] = { 0x00, 0x00 };

            if (payload <= ADRF_REG_MAX) {
                BLOQUEAR();
                resp[1] = adrf6850_read_reg((uint8_t)payload);
                DESBLOQUEAR();
                resp[0] = 0x01;
                printf("ADRF: read_reg(CR%u) -> 0x%02X\n", payload, (unsigned)resp[1]);
            } else {
                fprintf(stderr, "ADRF: read_reg con direccion invalida %u (maximo %u)\n", payload, ADRF_REG_MAX);
            }
            if (send_all(fd, resp, sizeof(resp)) < 0) return;
            break;
        }

        case CMD_ADRF_VGAIN_RAW: {
            int ok = 0;

            BLOQUEAR();
            if (g_vgain_reg == NULL) {
                fprintf(stderr, "ADRF: VGAIN_RAW rechazado: el servidor no tiene el DAC activado (-d)\n");
            } else if (payload > DAC_CODIGO_MAX) {
                fprintf(stderr, "ADRF: VGAIN_RAW rechazado: codigo %u (maximo %u)\n", payload, DAC_CODIGO_MAX);
            } else if (vgain_escribir(payload) == 0) {
                g_vgain_pedido_mv = vgain_codigo_a_mv(payload);
                printf("ADRF: VGAIN por el DAC: codigo %u (%u mV)\n", payload, g_vgain_pedido_mv);
                ok = 1;
            }
            DESBLOQUEAR();
            if (responder(fd, ok) < 0) return;
            break;
        }

        case CMD_ADRF_GET_VGAIN: {
            uint8_t w[1 + ADRF_VGAIN_WIRE_BYTES] = { 0 };

            if (g_vgain_reg != NULL) {
                uint32_t codigo = (vgain_reg_leer() >> 16) & 0x3FFFu;

                w[0] = 0x01;
                wr_u16(w + 1, (uint16_t)codigo);
                wr_u16(w + 3, (uint16_t)g_vgain_pedido_mv);
                wr_u16(w + 5, (uint16_t)vgain_codigo_a_mv(codigo));
            }
            if (send_all(fd, w, sizeof(w)) < 0) return;
            break;
        }

        case CMD_ADRF_AGC_SET: {
            uint8_t w[AGC_SET_WIRE_BYTES];

            if (payload != AGC_SET_WIRE_BYTES) {
                fprintf(stderr, "ADRF: CMD_ADRF_AGC_SET con payload=%u, se esperaban %u bytes\n", payload, AGC_SET_WIRE_BYTES);
                if (responder(fd, 0) < 0) return;           /* el cliente no manda los datos si recibe 0x00 */
                break;
            }
            if (responder(fd, 1) < 0) return;               /* paso 1: listo para recibir */
            if (recv_all(fd, w, sizeof(w)) < 0) return;
            if (responder(fd, agc_comando_set(w)) < 0) return;   /* paso 2: resultado */
            break;
        }

        case CMD_ADRF_AGC_GET: {
            uint8_t w[1 + AGC_GET_WIRE_BYTES];

            agc_get_a_cable(w);
            if (send_all(fd, w, sizeof(w)) < 0) return;
            break;
        }

        case CMD_ADRF_AGC_LOG: {
            uint8_t w[9 + AGC_LOG_N * AGC_REG_BYTES];
            size_t n = agc_log_a_cable(payload, w);

            if (send_all(fd, w, n) < 0) return;
            break;
        }

        default:
            fprintf(stderr, "ADRF: comando desconocido 0x%02X\n", (unsigned)cmd);
            if (responder(fd, 0) < 0) return;
            break;
        }
    }
}

/* Lee y valida el .conf. Si algo esta mal el servidor no arranca: no hay valores por defecto a los que volver. */
static int cargar_configuracion(const char *ruta)
{
    char err[320];

    if (adrf_conf_leer(ruta, &g_conf, err, sizeof(err)) != 0) {
        fprintf(stderr, "ADRF: configuracion '%s' invalida: %s\n", ruta, err);
        return -1;
    }
    printf("ADRF: configuracion leida de '%s'\n", ruta);
    adrf_conf_imprimir(&g_conf);
    return 0;
}

/* Opcion -a: el init al arrancar. Si falla se informa y el servidor sigue, para poder diagnosticar. */
static void iniciar_al_arrancar(void)
{
    char err[320];
    const adrf6850_state_t *st;

    if (adrf_conf_aplicar(&g_conf, err, sizeof(err)) != 0) {
        fprintf(stderr, "ADRF: init NO realizado: %s\n", err);
        return;
    }
    st = adrf6850_get_state();
    printf("ADRF: init hecho: LO = %.6f MHz, VGAIN = %u mV en J2 (se aplica a mano)\n",
           st->lo_actual_hz / 1e6, (unsigned)st->vgain_mv);
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

/* mV de una opcion: 0 si es un numero valido */
static int parse_mv(const char *txt, double *mv)
{
    char *fin;

    *mv = strtod(txt, &fin);
    return (*txt != '\0' && *fin == '\0') ? 0 : -1;
}

static int uso_mv(const char *opcion, const char *valor)
{
    fprintf(stderr, "%s necesita un numero en mV (se dio '%s')\n", opcion, valor);
    return 2;
}

int main(int argc, char **argv)
{
    struct sigaction sa;
    struct sockaddr_in addr;
    int puerto = TCP_PORT_DEFECTO, yes = 1, i;
    const char *conf_ruta = NULL, *agc_ruta = NULL;
    int agc_activo_conf = 0;
    int auto_init = 0, usar_dac = 0, fs_dado = 0, off_dado = 0, sin_agc = 0;
    int srv;

    for (i = 1; i < argc; i++) {
        if (strcmp(argv[i], "-p") == 0 && i + 1 < argc)      puerto = atoi(argv[++i]);
        else if (strcmp(argv[i], "-c") == 0 && i + 1 < argc) conf_ruta = argv[++i];
        else if (strcmp(argv[i], "-g") == 0 && i + 1 < argc) agc_ruta = argv[++i];
        else if (strcmp(argv[i], "-i") == 0 && i + 1 < argc) g_pausa_us = (unsigned)atoi(argv[++i]);
        else if (strcmp(argv[i], "-a") == 0)                 auto_init = 1;
        else if (strcmp(argv[i], "-d") == 0)                 usar_dac = 1;
        else if (strcmp(argv[i], "-n") == 0)                 sin_agc = 1;
        else if (strcmp(argv[i], "-F") == 0 && i + 1 < argc) { if (parse_mv(argv[++i], &g_dac_fs_mv) < 0)  return uso_mv(argv[i - 1], argv[i]); fs_dado = 1; }
        else if (strcmp(argv[i], "-O") == 0 && i + 1 < argc) { if (parse_mv(argv[++i], &g_dac_off_mv) < 0) return uso_mv(argv[i - 1], argv[i]); off_dado = 1; }
        else {
            fprintf(stderr, "uso: %s [-c archivo.conf] [-a] [-d [-F mV] [-O mV]] [-g agc.conf | -n] [-p puerto] [-i pausa_spi_us]\n", argv[0]);
            return 2;
        }
    }
    if ((fs_dado || off_dado) && !usar_dac) {
        fprintf(stderr, "-F y -O solo valen con -d (VGAIN por el DAC)\n");
        return 2;
    }
    if (g_dac_fs_mv < 100.0 || g_dac_fs_mv > 5000.0 || g_dac_off_mv < -200.0 || g_dac_off_mv > 200.0) {
        fprintf(stderr, "-F debe estar entre 100 y 5000 mV y -O entre -200 y 200 mV (se dio %.1f y %.1f)\n", g_dac_fs_mv, g_dac_off_mv);
        return 2;
    }
    if (agc_ruta != NULL && !usar_dac) {
        fprintf(stderr, "-g solo vale con -d (el AGC mueve VGAIN por el DAC)\n");
        return 2;
    }
    if (agc_ruta != NULL && sin_agc) {
        fprintf(stderr, "-g y -n se excluyen: -n es arrancar sin AGC\n");
        return 2;
    }
    if (auto_init && conf_ruta == NULL) {
        fprintf(stderr, "-a (init automatico) necesita -c archivo.conf: sin .conf no hay valores con los que inicializar\n");
        return 2;
    }
    if (puerto < 1 || puerto > 65535) {
        fprintf(stderr, "puerto invalido: %d\n", puerto);
        return 2;
    }

    setvbuf(stdout, NULL, _IOLBF, 0);          /* las lineas aparecen enseguida aunque la salida vaya a un archivo */
    signal(SIGPIPE, SIG_IGN);
    memset(&sa, 0, sizeof(sa));
    sa.sa_handler = on_signal;                 /* sin SA_RESTART: accept/recv se interrumpen */
    sigaction(SIGINT, &sa, NULL);
    sigaction(SIGTERM, &sa, NULL);

    printf("ADRF: VGA con %s\n", ADRF6850_VGA_DOBLE_PENDIENTE ? "doble pendiente con histeresis (quiebre en 30 dB = 750 mV, +-1 dB)" : "pendiente fija (la de vga_pendiente del .conf)");
    if (conf_ruta != NULL) {
        if (cargar_configuracion(conf_ruta) < 0) return 1;  /* antes de abrir el SPI: un .conf malo no toca nada */
        g_conf_cargada = 1;
    } else {
        printf("ADRF: sin .conf: solo CMD_ADRF_INIT_CFG puede inicializar el chip (con los valores del cliente)\n");
    }

    if (agc_ruta != NULL) {
        agc_params_t pp;
        char err[320];

        if (agc_leer_conf(agc_ruta, &pp, &agc_activo_conf, err, sizeof(err)) != 0) {
            fprintf(stderr, "AGC: configuracion '%s' invalida: %s\n", agc_ruta, err);
            return 1;
        }
        agc_iniciar(&g_agc, &pp);
        g_agc_listo = 1;
        printf("AGC: configuracion leida de '%s': objetivo %.0f, percentil %.0f de %d rafagas, zona muerta %.2f dB, proteccion sobre %.0f, de %.1f a %.1f dB, arranca en %.1f dB, %s\n",
               agc_ruta, pp.objetivo, pp.percentil, pp.ventana, pp.zona_muerta_db, pp.nivel_proteccion, pp.g_min_db, pp.g_max_db, pp.g_inicial_db,
               agc_activo_conf ? "activado al arrancar" : "desactivado al arrancar");
    }
    else if (usar_dac && !sin_agc) {
        agc_params_t pp;

        agc_params_defecto(&pp);
        agc_iniciar(&g_agc, &pp);
        g_agc_listo = 1;
        agc_activo_conf = 1;
        printf("AGC: sin -g, parametros por defecto (los de agc.conf), arranca en %.1f dB, activado al arrancar (-n lo evita)\n", pp.g_inicial_db);
    }
    if (usar_dac) {
        if (vgain_reg_abrir() < 0) return 1;
        printf("ADRF: VGAIN por el DAC (OUT2): fondo de escala %.1f mV, offset %.1f mV, maximo alcanzable %u mV\n",
               g_dac_fs_mv, g_dac_off_mv, vgain_codigo_a_mv(DAC_CODIGO_MAX) < VGAIN_MAX_MV ? vgain_codigo_a_mv(DAC_CODIGO_MAX) : VGAIN_MAX_MV);
    }
    if (usar_dac && sts_abrir() < 0) fprintf(stderr, "AGC: no se pudieron mapear los registros de estado: el AGC no estara disponible\n");
    if (adrf_spi_init(ADRF_SPI_DEVICE) < 0) {
        fprintf(stderr, "ADRF: sin SPI este servidor no tiene nada que hacer; saliendo.\n");
        vgain_reg_cerrar();
        return 1;
    }
    if (g_pausa_us > 0) printf("ADRF: pausa de %u us tras cada transaccion SPI\n", g_pausa_us);
    if (auto_init) iniciar_al_arrancar();
    clock_gettime(CLOCK_MONOTONIC, &g_t0);
    if (g_sts != NULL) {
        if (agc_activo_conf) { g_agc_activo = 1; g_agc_pend_ini = 1; }
        if (pthread_create(&g_agc_th, NULL, agc_hilo, NULL) == 0) {
            g_agc_th_vivo = 1;
        } else {
            perror("pthread_create");
            g_agc_activo = 0; g_agc_pend_ini = 0;
            sts_cerrar();
        }
    }

    srv = socket(AF_INET, SOCK_STREAM, 0);
    if (srv < 0) { perror("socket"); adrf_spi_close(); vgain_reg_cerrar(); return 1; }
    setsockopt(srv, SOL_SOCKET, SO_REUSEADDR, &yes, sizeof(yes));
    memset(&addr, 0, sizeof(addr));
    addr.sin_family = AF_INET;
    addr.sin_addr.s_addr = htonl(INADDR_ANY);
    addr.sin_port = htons((uint16_t)puerto);
    if (bind(srv, (struct sockaddr *)&addr, sizeof(addr)) < 0 || listen(srv, 4) < 0) {
        fprintf(stderr, "ADRF: no se pudo escuchar en el puerto %d: %s\n", puerto, strerror(errno));
        close(srv);
        adrf_spi_close();
        vgain_reg_cerrar();
        return 1;
    }
    printf("ADRF: servidor del ADRF6850 (init con el .conf o con la configuracion del cliente, lectura por SDO, escrituras verificadas)\n");
    printf("Servidor ADRF escuchando en puerto %d\n", puerto);

    while (!g_stop) {
        int cli = accept(srv, NULL, NULL);
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

    g_stop = 1;
    if (g_agc_th_vivo) pthread_join(g_agc_th, NULL);
    close(srv);
    adrf_spi_close();
    sts_cerrar();
    vgain_reg_cerrar();
    printf("Saliendo.\n");
    return 0;
}
