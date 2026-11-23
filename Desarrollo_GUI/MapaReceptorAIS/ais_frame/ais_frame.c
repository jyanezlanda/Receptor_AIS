/* ais_frame.c -- ver ais_frame.h. */
#include "ais_frame.h"

#include <stdio.h>
#include <string.h>

#define MAX_CUERPO   (AIS_DATOS_MAX_BITS + 16u)      /* datos + FCS */
#define CUENTA(campo) do { rx->campo++; rx->pol[pol].campo++; } while (0)

static uint16_t crc_x25(const uint8_t *b, unsigned n)
{
    uint16_t reg = 0xFFFF;
    unsigned i;

    for (i = 0; i < n; i++) {
        unsigned fb = (reg & 1u) ^ b[i];

        reg >>= 1;
        if (fb) reg ^= 0x8408;
    }
    return reg;
}

int ais_largo_ok(int tipo, int b)
{
    switch (tipo) {
    case 1: case 2: case 3: case 4: case 9: case 11: case 18: case 22:  return b == 168;
    case 5:                                                             return b == 424;
    case 6: case 12:                                                    return b >= 72 && b <= 1008;
    case 7: case 13:                                                    return b == 72 || b == 104 || b == 136 || b == 168;
    case 8:                                                             return b >= 56 && b <= 1008;
    case 10:                                                            return b == 72;
    case 14:                                                            return b >= 40 && b <= 1008;
    case 15:                                                            return b >= 88 && b <= 160;
    case 16:                                                            return b == 96 || b == 144;
    case 17:                                                            return b >= 80 && b <= 816;
    case 19:                                                            return b == 312;
    case 20:                                                            return b >= 72 && b <= 160;
    case 21:                                                            return b >= 272 && b <= 360;
    case 23:                                                            return b == 160;
    case 24:                                                            return b == 160 || b == 168;
    case 25:                                                            return b >= 40 && b <= 168;
    case 26:                                                            return b >= 60 && b <= 1008;
    case 27:                                                            return b == 96 || b == 168;
    default:                                                            return 0;
    }
}

/* Bit 'i' del mensaje en orden logico: cada byte de la trama sale con el bit menos significativo primero. */
static unsigned logico(const uint8_t *datos, unsigned i)
{
    return datos[(i & ~7u) + 7u - (i & 7u)];
}

static void evaluar(ais_rx_t *rx, ais_estado_t *e, int pol, ais_frame_cb cb, void *usuario)
{
    unsigned n = e->n, nd, i, j, chars;
    ais_frame_t f;

    if (n < 6) return;                                     /* banderas seguidas */
    n -= 6;                                                /* el 0 y los cinco 1 de la bandera quedaron guardados */
    if (n < 16) return;
    CUENTA(candidatas);
    if (crc_x25(e->bits, n) != 0xF0B8) { CUENTA(fcs_malo); return; }
    CUENTA(fcs_ok);
    nd = n - 16;
    if (nd < 38 || nd % 8 != 0 || nd > AIS_DATOS_MAX_BITS) { CUENTA(descartadas); return; }

    f.tipo = 0;
    for (i = 0; i < 6; i++) f.tipo = (f.tipo << 1) | (int)logico(e->bits, i);
    if (!ais_largo_ok(f.tipo, (int)nd)) { CUENTA(descartadas); return; }
    f.mmsi = 0;
    for (i = 8; i < 38; i++) f.mmsi = (f.mmsi << 1) | logico(e->bits, i);
    f.bits = (int)nd;
    f.invertida = pol;
    chars = (nd + 5) / 6;
    for (i = 0; i < chars; i++) {
        unsigned v = 0;

        for (j = 0; j < 6; j++) v = (v << 1) | ((i * 6 + j < nd) ? logico(e->bits, i * 6 + j) : 0u);
        f.payload[i] = (char)(v < 40 ? v + 48 : v + 56);
    }
    f.payload[chars] = '\0';
    f.relleno = (int)(chars * 6 - nd);
    CUENTA(tramas);
    if (cb) cb(&f, usuario);
}

static void un_bit(ais_rx_t *rx, int pol, unsigned b, ais_frame_cb cb, void *usuario)
{
    ais_estado_t *e = &rx->e[pol];

    b ^= (unsigned)pol;
    if (e->buscando) {
        e->reg = (uint8_t)((e->reg << 1) | b);
        if (e->reg == 0x7E) { e->buscando = 0; e->n = 0; e->unos = 0; }
        return;
    }
    if (e->unos == 5) {
        if (b == 0) { e->unos = 0; return; }               /* 0 de relleno */
        e->unos = 6;                                       /* sexto uno: bandera o aborto */
        return;
    }
    if (e->unos == 6) {
        if (b == 0) {                                      /* bandera: cierra esta trama y abre la siguiente */
            evaluar(rx, e, pol, cb, usuario);
            e->n = 0;
            e->unos = 0;
        } else {                                           /* siete unos: aborto, o el relleno de unos que sigue a una bandera (hasta 5 bits guardados) */
            if (e->n > 5) CUENTA(abortadas);
            e->buscando = 1;
            e->reg = 0xFF;
        }
        return;
    }
    if (e->n >= MAX_CUERPO + 6) {                          /* demasiado larga */
        CUENTA(abortadas);
        e->buscando = 1;
        e->reg = 0;
        return;
    }
    e->bits[e->n++] = (uint8_t)b;
    e->unos = b ? e->unos + 1 : 0;
}

void ais_rx_reset(ais_rx_t *rx)
{
    int p;

    for (p = 0; p < 2; p++) { rx->e[p].buscando = 1; rx->e[p].reg = 0; rx->e[p].unos = 0; rx->e[p].n = 0; }
}

void ais_rx_iniciar(ais_rx_t *rx)
{
    memset(rx, 0, sizeof(*rx));
    ais_rx_reset(rx);
}

void ais_rx_bits(ais_rx_t *rx, const uint8_t *bits, size_t n, ais_frame_cb cb, void *usuario)
{
    size_t i;

    for (i = 0; i < n; i++) {
        unsigned b = bits[i] & 1u;

        rx->bits++;
        un_bit(rx, 0, b, cb, usuario);
        un_bit(rx, 1, b, cb, usuario);
    }
}

void ais_rx_palabras(ais_rx_t *rx, const uint32_t *w, size_t n, ais_frame_cb cb, void *usuario)
{
    size_t i;
    int k;

    for (i = 0; i < n; i++)
        for (k = 31; k >= 0; k--) {
            unsigned b = (w[i] >> k) & 1u;

            rx->bits++;
            un_bit(rx, 0, b, cb, usuario);
            un_bit(rx, 1, b, cb, usuario);
        }
}

size_t ais_a_nmea(const ais_frame_t *t, char canal, int secuencia, char *out, size_t cap)
{
    const size_t largo = strlen(t->payload), por = 60, total = (largo + por - 1) / por;
    size_t k, usado = 0;

    for (k = 0; k < total; k++) {
        char cuerpo[160], tz[8];
        size_t ini = k * por, n = (largo - ini < por) ? largo - ini : por;
        unsigned cs = 0, i;
        int escrito;

        snprintf(tz, sizeof(tz), "%d", secuencia % 10);
        escrito = snprintf(cuerpo, sizeof(cuerpo), "AIVDM,%u,%u,%s,%c,%.*s,%d", (unsigned)total, (unsigned)k + 1, total > 1 ? tz : "", canal,
                           (int)n, t->payload + ini, k + 1 == total ? t->relleno : 0);
        if (escrito < 0 || (size_t)escrito >= sizeof(cuerpo)) return 0;
        for (i = 0; cuerpo[i]; i++) cs ^= (unsigned char)cuerpo[i];
        escrito = snprintf(out + usado, cap - usado, "!%s*%02X\r\n", cuerpo, cs);
        if (escrito < 0 || (size_t)escrito >= cap - usado) return 0;
        usado += (size_t)escrito;
    }
    return usado;
}
