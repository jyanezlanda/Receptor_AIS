/**
 * @file    adrf6850_conf.h
 * @brief   Lectura del archivo de configuracion del ADRF6850 (adrf6850.conf).
 *
 * El .conf es la UNICA fuente de la configuracion inicial: el driver no tiene valores por defecto. Todas las
 * claves son obligatorias (salvo lo_hz); una clave ausente, repetida, desconocida o fuera de rango es un error
 * y no se toca el hardware.
 */
#ifndef ADRF6850_CONF_H
#define ADRF6850_CONF_H

#include <stddef.h>
#include <stdint.h>
#include "adrf6850.h"

#ifdef __cplusplus
extern "C" {
#endif

typedef struct {
    uint32_t           f_rf_hz;       /**< frecuencia de la senal a recibir (solo informativo si hay lo_hz) */
    uint32_t           f_fi_hz;       /**< FI que se entrega al ADC                                         */
    double             corr_ppm;      /**< error de la referencia, en ppm                                   */
    int                lo_explicito;  /**< 1 si el archivo define lo_hz                                     */
    adrf6850_config_t  drv;           /**< todo lo que adrf6850_init() necesita (el LO ya esta calculado)   */
    uint32_t           crc32;         /**< CRC-32 (IEEE 802.3) del contenido del archivo                   */
} adrf_conf_t;

/**
 * Lee y valida el archivo (sintaxis, rangos y, ademas, la validacion del driver: PFD, temporizador de
 * autocalibracion, LO alcanzable). Devuelve 0 si esta bien; si no, -1 con el motivo en @p err (con el numero
 * de linea cuando corresponde). No toca el hardware.
 */
int adrf_conf_leer(const char *ruta, adrf_conf_t *c, char *err, size_t err_len);

/** Imprime por stdout un resumen de lo que se va a aplicar. */
void adrf_conf_imprimir(const adrf_conf_t *c);

/** Hace adrf6850_init() con esta configuracion. Devuelve 0 si esta bien; si no, -1 con el motivo en @p err. */
int adrf_conf_aplicar(const adrf_conf_t *c, char *err, size_t err_len);

#ifdef __cplusplus
}
#endif

#endif /* ADRF6850_CONF_H */
