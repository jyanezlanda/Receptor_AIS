/**
 * @file    adrf6850_conf.c
 * @brief   Lectura del archivo de configuracion del ADRF6850 (adrf6850.conf). Ver adrf6850_conf.h.
 */
#include "adrf6850_conf.h"

#include <errno.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <strings.h>

#define LINEA_MAX 256

enum { K_RF, K_FI, K_PPM, K_LO, K_BBW, K_BBFC, K_CP, K_LOMON_EN, K_LOMON_PWR, K_GAIN,
       K_REFIN, K_DOBL, K_DIV2, K_RDIV_EN, K_RDIV, K_VOCM, K_VGAPOL, K_MUX, K_AUTOCAL, K_LOCKTO, K_VERIFY, K_N };

static const char *const NOMBRES[K_N] = {
    "f_rf_hz", "f_fi_hz", "corr_ppm", "lo_hz", "bb_wideband", "bb_fc_mhz", "cp_code",
    "lomon_en", "lomon_pwr_dbm", "gain_mdb", "refin_hz", "ref_doblador", "ref_div2",
    "ref_rdiv_en", "ref_rdiv", "vocm_interno", "vga_pendiente", "muxout", "autocal_us", "lock_timeout_us", "verify_retries"
};

#define FALLA(...) do { snprintf(err, err_len, __VA_ARGS__); return -1; } while (0)

/* CRC-32 (IEEE 802.3, igual a zlib.crc32): identifica el contenido del archivo leido. */
static uint32_t crc32_acumular(uint32_t crc, const unsigned char *p, size_t n)
{
    size_t i;
    int b;
    for (i = 0; i < n; i++) {
        crc ^= p[i];
        for (b = 0; b < 8; b++) crc = (crc >> 1) ^ (0xEDB88320U & (0U - (crc & 1U)));
    }
    return crc;
}

static char *recortar(char *s)
{
    char *fin;
    while (*s == ' ' || *s == '\t') s++;
    fin = s + strlen(s);
    while (fin > s && (fin[-1] == ' ' || fin[-1] == '\t' || fin[-1] == '\r' || fin[-1] == '\n')) fin--;
    *fin = '\0';
    return s;
}

static int leer_entero(const char *s, long *out)
{
    char *fin;
    long v;
    errno = 0;
    v = strtol(s, &fin, 0);                    /* decimal, 0x... o 0... */
    if (fin == s || errno != 0) return -1;
    while (*fin == ' ' || *fin == '\t') fin++;
    if (*fin != '\0') return -1;
    *out = v;
    return 0;
}

static int leer_real(const char *s, double *out)
{
    char *fin;
    double v;
    errno = 0;
    v = strtod(s, &fin);
    if (fin == s || errno != 0) return -1;
    while (*fin == ' ' || *fin == '\t') fin++;
    if (*fin != '\0') return -1;
    *out = v;
    return 0;
}

int adrf_conf_leer(const char *ruta, adrf_conf_t *c, char *err, size_t err_len)
{
    FILE *f;
    char linea[LINEA_MAX];
    int nlinea = 0;
    int visto[K_N];
    int k;

    memset(c, 0, sizeof(*c));
    memset(visto, 0, sizeof(visto));

    f = fopen(ruta, "r");
    if (f == NULL) FALLA("no se pudo abrir '%s': %s", ruta, strerror(errno));
    {   /* primera pasada: CRC-32 del contenido */
        unsigned char buf[512];
        size_t n;
        uint32_t crc = 0xFFFFFFFFU;
        while ((n = fread(buf, 1, sizeof(buf), f)) > 0) crc = crc32_acumular(crc, buf, n);
        c->crc32 = ~crc;
        rewind(f);
    }

    while (fgets(linea, sizeof(linea), f) != NULL) {
        char *p, *eq, *clave, *valor;
        long n;
        double d;

        nlinea++;
        if (strchr(linea, '\n') == NULL && !feof(f)) {
            fclose(f);
            FALLA("linea %d: demasiado larga (maximo %d caracteres)", nlinea, LINEA_MAX - 1);
        }
        p = strchr(linea, '#');
        if (p != NULL) *p = '\0';
        p = recortar(linea);
        if (*p == '\0') continue;

        eq = strchr(p, '=');
        if (eq == NULL) { fclose(f); FALLA("linea %d: se esperaba 'clave = valor'", nlinea); }
        *eq = '\0';
        clave = recortar(p);
        valor = recortar(eq + 1);
        if (*valor == '\0') { fclose(f); FALLA("linea %d: la clave '%s' no tiene valor", nlinea, clave); }

        for (k = 0; k < K_N; k++) if (strcasecmp(clave, NOMBRES[k]) == 0) break;
        if (k == K_N) { fclose(f); FALLA("linea %d: clave desconocida '%s'", nlinea, clave); }
        if (visto[k]) { fclose(f); FALLA("linea %d: la clave '%s' esta repetida", nlinea, clave); }
        visto[k] = 1;

        #define NUM(rango_ok, msg) do { \
            if (leer_entero(valor, &n) != 0) { fclose(f); FALLA("linea %d: '%s' no es un numero entero (valor '%s')", nlinea, clave, valor); } \
            if (!(rango_ok)) { fclose(f); FALLA("linea %d: %s (valor %ld)", nlinea, msg, n); } } while (0)

        switch (k) {
        case K_RF:  NUM(n >= (long)ADRF6850_LO_MIN_HZ && n <= (long)ADRF6850_LO_MAX_HZ, "f_rf_hz debe estar entre 100 MHz y 1000 MHz"); c->f_rf_hz = (uint32_t)n; break;
        case K_FI:  NUM(n >= 1000000L && n <= 100000000L, "f_fi_hz debe estar entre 1 MHz y 100 MHz"); c->f_fi_hz = (uint32_t)n; break;
        case K_PPM:
            if (leer_real(valor, &d) != 0) { fclose(f); FALLA("linea %d: corr_ppm no es un numero (valor '%s')", nlinea, valor); }
            if (d < -1000.0 || d > 1000.0) { fclose(f); FALLA("linea %d: corr_ppm debe estar entre -1000 y 1000 (valor %g)", nlinea, d); }
            c->corr_ppm = d;
            break;
        case K_LO:  NUM(n >= (long)ADRF6850_LO_MIN_HZ && n <= (long)ADRF6850_LO_MAX_HZ, "lo_hz debe estar entre 100 MHz y 1000 MHz"); c->drv.lo_hz = (uint32_t)n; c->lo_explicito = 1; break;
        case K_BBW: NUM(n == 0 || n == 1, "bb_wideband debe ser 0 o 1"); c->drv.bb_wideband = (uint8_t)n; break;
        case K_BBFC:
            if (leer_entero(valor, &n) != 0) { fclose(f); FALLA("linea %d: bb_fc_mhz no es un numero entero (valor '%s')", nlinea, valor); }
            if      (n == 50) c->drv.bb_fc = ADRF6850_BB_FC_50MHZ;
            else if (n == 43) c->drv.bb_fc = ADRF6850_BB_FC_43MHZ;
            else if (n == 37) c->drv.bb_fc = ADRF6850_BB_FC_37MHZ;
            else if (n == 30) c->drv.bb_fc = ADRF6850_BB_FC_30MHZ;
            else { fclose(f); FALLA("linea %d: bb_fc_mhz debe ser 50, 43, 37 o 30 (valor %ld)", nlinea, n); }
            break;
        case K_CP:  NUM(n >= 0 && n <= 15, "cp_code debe estar entre 0 y 15"); c->drv.cp_code = (uint8_t)n; break;
        case K_LOMON_EN: NUM(n == 0 || n == 1, "lomon_en debe ser 0 o 1"); c->drv.lomon_en = (uint8_t)n; break;
        case K_LOMON_PWR:
            if (leer_entero(valor, &n) != 0) { fclose(f); FALLA("linea %d: lomon_pwr_dbm no es un numero entero (valor '%s')", nlinea, valor); }
            if      (n == -24) c->drv.lomon_pwr = ADRF6850_LOMON_M24DBM;
            else if (n == -18) c->drv.lomon_pwr = ADRF6850_LOMON_M18DBM;
            else if (n == -12) c->drv.lomon_pwr = ADRF6850_LOMON_M12DBM;
            else if (n == -6)  c->drv.lomon_pwr = ADRF6850_LOMON_M6DBM;
            else { fclose(f); FALLA("linea %d: lomon_pwr_dbm debe ser -24, -18, -12 o -6 (valor %ld)", nlinea, n); }
            break;
        case K_GAIN:  NUM(n >= 0 && n <= 60000, "gain_mdb debe estar entre 0 y 60000"); c->drv.gain_mdb = (int32_t)n; break;
        case K_REFIN: NUM(n >= 1000000L && n <= 100000000L, "refin_hz debe estar entre 1 MHz y 100 MHz"); c->drv.refin_hz = (uint32_t)n; break;
        case K_DOBL:  NUM(n == 0 || n == 1, "ref_doblador debe ser 0 o 1"); c->drv.ref_doubler_en = (uint8_t)n; break;
        case K_DIV2:  NUM(n == 0 || n == 1, "ref_div2 debe ser 0 o 1"); c->drv.ref_div2_en = (uint8_t)n; break;
        case K_RDIV_EN: NUM(n == 0 || n == 1, "ref_rdiv_en debe ser 0 o 1"); c->drv.ref_rdiv_en = (uint8_t)n; break;
        case K_RDIV:  NUM(n >= 1 && n <= 32, "ref_rdiv debe estar entre 1 y 32"); c->drv.ref_rdiv = (uint8_t)n; break;
        case K_VOCM:  NUM(n == 0 || n == 1, "vocm_interno debe ser 0 o 1"); c->drv.vocm_internal = (uint8_t)n; break;
        case K_VGAPOL: NUM(n == 0 || n == 1, "vga_pendiente debe ser 0 (positiva) o 1 (negativa)"); c->drv.vga_polarity = (uint8_t)n; break;
        case K_MUX:   NUM(n >= 0 && n <= 15, "muxout debe estar entre 0 y 15"); c->drv.muxout = (uint8_t)n; break;
        case K_AUTOCAL: NUM(n >= 1 && n <= 10000, "autocal_us debe estar entre 1 y 10000"); c->drv.autocal_time_us = (uint32_t)n; break;
        case K_LOCKTO:  NUM(n >= 0 && n <= 1000000L, "lock_timeout_us debe estar entre 0 y 1000000"); c->drv.lock_timeout_us = (uint32_t)n; break;
        case K_VERIFY:  NUM(n >= 0 && n <= 3, "verify_retries debe estar entre 0 y 3"); c->drv.verify_retries = (uint8_t)n; break;
        default: break;
        }
        #undef NUM
    }
    fclose(f);

    /* No hay valores por defecto: toda clave obligatoria tiene que estar en el archivo. */
    c->lo_explicito = visto[K_LO];
    for (k = 0; k < K_N; k++) {
        int opcional = (k == K_LO) || (visto[K_LO] && (k == K_RF || k == K_FI || k == K_PPM));
        if (!visto[k] && !opcional)
            FALLA("falta la clave '%s': el .conf debe definir todo, el driver no tiene valores por defecto", NOMBRES[k]);
    }

    /* LO: explicito, o f_rf - f_fi corregido por el error de la referencia. */
    if (!c->lo_explicito) {
        double nominal, pedido;
        if (c->f_fi_hz >= c->f_rf_hz)
            FALLA("f_fi_hz = %lu debe ser menor que f_rf_hz (%lu Hz)", (unsigned long)c->f_fi_hz, (unsigned long)c->f_rf_hz);
        nominal = (double)(c->f_rf_hz - c->f_fi_hz);
        pedido  = nominal / (1.0 + c->corr_ppm * 1e-6);
        if (pedido < (double)ADRF6850_LO_MIN_HZ || pedido > (double)ADRF6850_LO_MAX_HZ)
            FALLA("el LO calculado (%.0f Hz) esta fuera del rango del ADRF6850 (100 MHz a 1000 MHz)", pedido);
        c->drv.lo_hz = (uint32_t)(pedido + 0.5);
    }

    /* Mensajes claros para los dos errores de configuracion mas probables, antes de la validacion general. */
    {
        unsigned long r_eff = c->drv.ref_rdiv_en ? c->drv.ref_rdiv : 1UL;
        double pfd = (double)c->drv.refin_hz * (1.0 + c->drv.ref_doubler_en) / ((double)r_eff * (1.0 + c->drv.ref_div2_en));
        double bscdiv = pfd * (double)c->drv.autocal_time_us / 24e6;
        if (pfd < 10e6 || pfd > 30e6)
            FALLA("la frecuencia del PFD (%.3f MHz, de refin_hz, ref_doblador, ref_div2 y ref_rdiv) debe estar entre 10 y 30 MHz", pfd / 1e6);
        if (bscdiv < 1.0 || bscdiv >= 256.0)
            FALLA("autocal_us = %lu da un temporizador de autocalibracion de %.1f; debe estar entre 1 y 255 (PFD %.3f MHz)",
                  (unsigned long)c->drv.autocal_time_us, bscdiv, pfd / 1e6);
    }
    {
        adrf6850_status_t st = adrf6850_validate_config(&c->drv);
        if (st != ADRF6850_OK)
            FALLA("el driver rechaza la configuracion (codigo %d): ver los limites de adrf6850_config_t", (int)st);
    }
    return 0;
}

void adrf_conf_imprimir(const adrf_conf_t *c)
{
    static const int fc_mhz[4] = {50, 43, 37, 30};
    static const int mon_dbm[4] = {-24, -18, -12, -6};
    const adrf6850_config_t *d = &c->drv;
    unsigned long r_eff = d->ref_rdiv_en ? d->ref_rdiv : 1UL;
    double pfd = (double)d->refin_hz * (1.0 + d->ref_doubler_en) / ((double)r_eff * (1.0 + d->ref_div2_en));

    printf("ADRF: configuracion inicial (la unica fuente: el driver no tiene valores por defecto):\n");
    if (c->lo_explicito)
        printf("  senal: LO explicito (lo_hz)\n");
    else
        printf("  senal: RF %.6f MHz -> FI %.6f MHz (corr_ppm = %+g)\n", c->f_rf_hz / 1e6, c->f_fi_hz / 1e6, c->corr_ppm);
    printf("  LO = %.6f MHz\n", d->lo_hz / 1e6);
    printf("  referencia: %.3f MHz%s%s%s -> PFD %.3f MHz | autocalibracion %lu us\n", d->refin_hz / 1e6,
           d->ref_doubler_en ? " x2" : "", d->ref_div2_en ? " /2" : "", d->ref_rdiv_en ? " /R" : "", pfd / 1e6, (unsigned long)d->autocal_time_us);
    printf("  banda base: %s, corte %d MHz | VOCM %s | bomba de carga: cp_code = 0x%X | LOMON: %s (%d dBm)\n",
           d->bb_wideband ? "wideband" : "narrow-band", fc_mhz[(int)d->bb_fc & 3], d->vocm_internal ? "interno" : "externo",
           (unsigned)d->cp_code, d->lomon_en ? "encendido" : "apagado", mon_dbm[(int)d->lomon_pwr & 3]);
    printf("  ganancia: %.1f dB, pendiente de VGAIN %s (VGAIN sale de J2: se aplica a mano)\n",
           d->gain_mdb / 1000.0, d->vga_polarity ? "negativa" : "positiva");
    if (d->verify_retries)
        printf("  escrituras verificadas: se lee cada registro y, si no coincide, se reescribe (hasta %u reintentos)\n", (unsigned)d->verify_retries);
    else
        printf("  escrituras SIN verificar (verify_retries = 0)\n");
}

int adrf_conf_aplicar(const adrf_conf_t *c, char *err, size_t err_len)
{
    adrf6850_status_t st = adrf6850_init(&c->drv);
    if (st != ADRF6850_OK) FALLA("adrf6850_init() devolvio %d", (int)st);
    return 0;
}
