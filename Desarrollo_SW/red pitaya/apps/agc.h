/*
 * agc.h -- AGC del receptor AIS: lleva la ganancia del ADRF6850 para que la rafaga de referencia quede en 'objetivo'.
 *
 * Despues de cada rafaga se recibe su pico de nivel. La referencia es un percentil de los ultimos 'ventana' picos, cada uno
 * llevado a la ganancia actual (pico * 10^((g_actual - g_de_la_medicion) * planta / 10)); con percentil 100 es el maximo.
 * Una referencia por encima del objetivo baja la ganancia de inmediato (ataque proporcional); por debajo la sube de a
 * 'paso_liberacion_db' cada 'liberacion_rafagas' rafagas bajas seguidas. Dentro de la zona muerta no se mueve, y sin rafagas
 * tampoco. Un pico sobre 'nivel_proteccion' baja 'paso_max_db' sin esperar. Este modulo no toca el hardware.
 */
#ifndef AGC_H
#define AGC_H

#include <stddef.h>
#include <stdint.h>

#define AGC_VENTANA_MAX 64

typedef struct {
    double objetivo;              /* nivel pico al que se lleva la referencia */
    int    ventana;               /* rafagas en la ventana (1 a AGC_VENTANA_MAX) */
    double percentil;             /* 0 a 100; 100 = maximo */
    double zona_muerta_db;        /* no corrige si la referencia esta a menos de esto del objetivo */
    double kp;                    /* fraccion del error que corrige en cada ataque */
    double paso_max_db;           /* paso maximo de ganancia por rafaga */
    int    liberacion_rafagas;    /* rafagas bajas seguidas antes de subir la ganancia */
    double paso_liberacion_db;    /* paso al subir */
    double nivel_proteccion;      /* un pico sobre este nivel baja paso_max_db de inmediato */
    double g_min_db;              /* limites de la ganancia que pide el AGC */
    double g_max_db;
    double planta;                /* dB de nivel por dB de ganancia pedida */
    double g_inicial_db;          /* ganancia con que arranca */
} agc_params_t;

typedef struct {
    agc_params_t p;
    double       niv[AGC_VENTANA_MAX];
    double       g[AGC_VENTANA_MAX];   /* ganancia con que se midio cada pico */
    int          n, cab, bajos;
    uint32_t     rafagas, cambios, protecciones;
} agc_t;

typedef struct {
    double ref;                   /* referencia de la ventana, a la ganancia actual */
    double err_db;                /* 10 log10(ref / objetivo) */
    double g_nueva_db;            /* ganancia a aplicar (igual a la actual si no hay cambio) */
    int    cambio;                /* 1 si hay que cambiar la ganancia (paso de al menos 0,05 dB) */
    int    proteccion;            /* 1 si actuo la proteccion */
} agc_paso_t;

/* 0 si los parametros son validos; si no, -1 y el motivo en err. */
int  agc_params_validar(const agc_params_t *p, char *err, size_t n);

/* Lee el archivo de configuracion (todas las claves son obligatorias; una ausente, repetida, desconocida o fuera de rango es
 * un error con el numero de linea). 'activo' es 1 si el AGC arranca activado. 0 si esta bien; si no, -1 y el motivo en err. */
void agc_params_defecto(agc_params_t *p);                        /* los mismos valores que trae agc.conf */
int  agc_leer_conf(const char *ruta, agc_params_t *p, int *activo, char *err, size_t n);

void agc_iniciar(agc_t *a, const agc_params_t *p);        /* parametros nuevos, ventana y contadores en cero */
agc_paso_t agc_rafaga(agc_t *a, double pico, double g_actual_db);

#endif
