/*
 * ais_frame.h -- Armado de tramas AIS a partir de los bits demodulados (los de la FIFO del receptor: ya sin NRZI).
 *
 * Busca la bandera HDLC (01111110) en la polaridad normal y en la invertida, destufea los bits hasta la bandera siguiente,
 * verifica el FCS (CRC-16 X.25, residuo 0xF0B8) y acepta la trama si el tipo de mensaje y su largo son plausibles:
 *  - tipos 1 a 27 (los demas se descartan);
 *  - los datos son un numero entero de bytes (como los transmite HDLC);
 *  - los tipos de largo fijo tienen ese largo (168 bits para 1, 2, 3, 4, 9, 11, 18 y 22; 424 para el 5; 312 para el 19; ...) y los
 *    de largo variable entran en su rango. Una trama de hasta 5 ranuras (1008 bits de datos) es valida.
 * Esto evita que el ruido arme tramas falsas con un FCS valido: sin la verificacion del tipo y del largo, el FCS de 16 bits solo
 * deja pasar una cada pocas horas de ruido continuo.
 *
 * El modulo no depende del hardware ni de Qt. Los bits se pueden dar en cualquier cantidad (el estado se conserva entre llamadas)
 * y se informa cada trama valida por una funcion de retorno. Para armar las sentencias !AIVDM usar ais_a_nmea().
 */
#ifndef AIS_FRAME_H
#define AIS_FRAME_H

#include <stddef.h>
#include <stdint.h>

#ifdef __cplusplus
extern "C" {
#endif

#define AIS_DATOS_MAX_BITS  1008u      /* 5 ranuras */
#define AIS_PAYLOAD_MAX     168        /* AIS_DATOS_MAX_BITS / 6 */

typedef struct {
    int      tipo;                     /* tipo de mensaje (1 a 27) */
    uint32_t mmsi;
    int      bits;                     /* bits de datos, sin el FCS (multiplo de 8) */
    int      relleno;                  /* bits de relleno del ultimo caracter del payload */
    int      invertida;                /* 1 si la trama llego con la polaridad invertida */
    char     payload[AIS_PAYLOAD_MAX + 1];   /* payload AIVDM: 6 bits por caracter ASCII */
} ais_frame_t;

typedef void (*ais_frame_cb)(const ais_frame_t *trama, void *usuario);

typedef struct {
    int      buscando;                 /* 1 hasta encontrar la bandera de apertura */
    uint8_t  reg;                      /* ultimos 8 bits mientras se busca */
    int      unos;                     /* racha de unos de la trama en curso */
    unsigned n;                        /* bits guardados de la trama en curso */
    uint8_t  bits[AIS_DATOS_MAX_BITS + 16 + 16];
} ais_estado_t;

typedef struct {
    uint64_t candidatas;               /* tramas entre dos banderas con al menos 16 bits */
    uint64_t fcs_malo;                 /* con FCS incorrecto */
    uint64_t fcs_ok;                   /* con FCS correcto */
    uint64_t descartadas;              /* FCS correcto pero de tipo o largo no plausible */
    uint64_t abortadas;                /* siete unos seguidos en medio de una trama, o demasiado larga */
    uint64_t tramas;                   /* aceptadas */
} ais_cuentas_t;

/* Los contadores de arriba suman las dos polaridades. Para mostrar el estado del enlace conviene 'pol': la polaridad que tiene la señal es la
 * que acepta tramas; la otra solo encuentra banderas al reves dentro de los datos y arma candidatas de basura. */
typedef struct {
    ais_estado_t e[2];                 /* 0: polaridad normal, 1: invertida */
    uint64_t bits;                     /* bits recibidos */
    uint64_t candidatas, fcs_malo, fcs_ok, descartadas, abortadas, tramas;   /* totales, ver ais_cuentas_t */
    ais_cuentas_t pol[2];              /* por polaridad */
} ais_rx_t;

void ais_rx_iniciar(ais_rx_t *rx);                       /* todo en cero */
void ais_rx_reset(ais_rx_t *rx);                         /* descarta la trama en curso (por ejemplo entre dos rafagas); conserva los contadores */
void ais_rx_bits(ais_rx_t *rx, const uint8_t *bits, size_t n, ais_frame_cb cb, void *usuario);              /* un bit (0 o 1) por byte */
void ais_rx_palabras(ais_rx_t *rx, const uint32_t *w, size_t n, ais_frame_cb cb, void *usuario);            /* palabras de la FIFO, MSB primero */

/* Sentencias !AIVDM de la trama (una, o varias de a lo sumo 60 caracteres de payload, separadas por "\r\n" y con ese fin).
 * 'canal' es 'A' o 'B'; 'secuencia' (0 a 9) identifica las sentencias de un mensaje largo. Devuelve el largo escrito (sin el NUL)
 * o 0 si 'cap' no alcanza. */
size_t ais_a_nmea(const ais_frame_t *trama, char canal, int secuencia, char *out, size_t cap);

/* 1 si 'bits' de datos es un largo plausible para el tipo de mensaje. */
int ais_largo_ok(int tipo, int bits);

#ifdef __cplusplus
}
#endif

#endif
