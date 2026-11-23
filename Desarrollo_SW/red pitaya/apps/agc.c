/* agc.c -- ver agc.h. */
#include "agc.h"

#include <ctype.h>
#include <math.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#define MAL(...) do { snprintf(err, n, __VA_ARGS__); return -1; } while (0)

int agc_params_validar(const agc_params_t *p, char *err, size_t n)
{
    if (!(p->objetivo >= 10.0 && p->objetivo <= 1400.0))               MAL("objetivo %.1f fuera de 10 a 1400", p->objetivo);
    if (!(p->nivel_proteccion >= p->objetivo && p->nivel_proteccion <= 1500.0))
                                                                       MAL("nivel_proteccion %.1f fuera de objetivo a 1500", p->nivel_proteccion);
    if (!(p->ventana >= 1 && p->ventana <= AGC_VENTANA_MAX))           MAL("ventana %d fuera de 1 a %d", p->ventana, AGC_VENTANA_MAX);
    if (!(p->percentil >= 0.0 && p->percentil <= 100.0))               MAL("percentil %.2f fuera de 0 a 100", p->percentil);
    if (!(p->zona_muerta_db >= 0.0 && p->zona_muerta_db <= 6.0))       MAL("zona_muerta_db %.2f fuera de 0 a 6", p->zona_muerta_db);
    if (!(p->kp >= 0.05 && p->kp <= 1.0))                              MAL("kp %.3f fuera de 0,05 a 1", p->kp);
    if (!(p->paso_max_db >= 0.5 && p->paso_max_db <= 6.0))             MAL("paso_max_db %.2f fuera de 0,5 a 6", p->paso_max_db);
    if (!(p->liberacion_rafagas >= 1 && p->liberacion_rafagas <= 1000)) MAL("liberacion_rafagas %d fuera de 1 a 1000", p->liberacion_rafagas);
    if (!(p->paso_liberacion_db >= 0.1 && p->paso_liberacion_db <= 3.0)) MAL("paso_liberacion_db %.2f fuera de 0,1 a 3", p->paso_liberacion_db);
    if (!(p->g_min_db >= 0.0 && p->g_min_db < 60.0))                   MAL("g_min_db %.2f fuera de 0 a 60", p->g_min_db);
    if (!(p->g_max_db > p->g_min_db && p->g_max_db <= 60.0))           MAL("g_max_db %.2f debe estar entre g_min_db y 60", p->g_max_db);
    if (!(p->planta >= 0.5 && p->planta <= 2.0))                       MAL("planta %.3f fuera de 0,5 a 2", p->planta);
    if (!(p->g_inicial_db >= p->g_min_db && p->g_inicial_db <= p->g_max_db))
                                                                       MAL("g_inicial_db %.2f fuera de g_min_db a g_max_db", p->g_inicial_db);
    return 0;
}

void agc_params_defecto(agc_params_t *p)
{
    p->g_inicial_db = 20.0; p->objetivo = 550.0; p->ventana = 8; p->percentil = 85.0; p->zona_muerta_db = 0.5; p->kp = 0.7;
    p->paso_max_db = 3.0; p->liberacion_rafagas = 8; p->paso_liberacion_db = 1.0; p->nivel_proteccion = 1100.0;
    p->g_min_db = 3.0; p->g_max_db = 30.0; p->planta = 1.24;
}

/* ---- archivo de configuracion ---- */
enum { K_ACTIVO, K_G_INICIAL, K_OBJETIVO, K_VENTANA, K_PERCENTIL, K_ZONA, K_KP, K_PASO_MAX, K_LIBERACION, K_PASO_LIB, K_PROTECCION,
       K_G_MIN, K_G_MAX, K_PLANTA, K_N };
static const char *const g_claves[K_N] = { "activo", "g_inicial_db", "objetivo", "ventana", "percentil", "zona_muerta_db", "kp", "paso_max_db",
                                           "liberacion_rafagas", "paso_liberacion_db", "nivel_proteccion", "g_min_db", "g_max_db", "planta" };

static char *recortar(char *s)
{
    char *fin;

    while (isspace((unsigned char)*s)) s++;
    fin = s + strlen(s);
    while (fin > s && isspace((unsigned char)fin[-1])) *--fin = '\0';
    return s;
}

int agc_leer_conf(const char *ruta, agc_params_t *p, int *activo, char *err, size_t n)
{
    FILE *f = fopen(ruta, "r");
    char linea[256];
    double v[K_N];
    int visto[K_N] = { 0 }, nlinea = 0, k;

    if (f == NULL) MAL("no se pudo abrir '%s'", ruta);
    while (fgets(linea, sizeof(linea), f) != NULL) {
        char *c, *eq, *clave, *valor, *fin;

        nlinea++;
        if (strchr(linea, '\n') == NULL && !feof(f)) { fclose(f); MAL("linea %d demasiado larga", nlinea); }
        if ((c = strchr(linea, '#')) != NULL) *c = '\0';
        clave = recortar(linea);
        if (*clave == '\0') continue;
        eq = strchr(clave, '=');
        if (eq == NULL) { fclose(f); MAL("linea %d: se esperaba 'clave = valor'", nlinea); }
        *eq = '\0';
        valor = recortar(eq + 1);
        clave = recortar(clave);
        for (k = 0; k < K_N && strcmp(clave, g_claves[k]) != 0; k++) { }
        if (k == K_N) { fclose(f); MAL("linea %d: clave desconocida '%s'", nlinea, clave); }
        if (visto[k]) { fclose(f); MAL("linea %d: clave repetida '%s'", nlinea, clave); }
        v[k] = strtod(valor, &fin);
        if (*valor == '\0' || *fin != '\0') { fclose(f); MAL("linea %d: '%s' no es un numero (clave '%s')", nlinea, valor, clave); }
        visto[k] = 1;
    }
    fclose(f);
    for (k = 0; k < K_N; k++) if (!visto[k]) MAL("falta la clave '%s'", g_claves[k]);
    if (v[K_ACTIVO] != 0.0 && v[K_ACTIVO] != 1.0) MAL("activo debe ser 0 o 1 (se dio %g)", v[K_ACTIVO]);
    if (v[K_VENTANA] != floor(v[K_VENTANA]) || v[K_LIBERACION] != floor(v[K_LIBERACION])) MAL("ventana y liberacion_rafagas deben ser enteros");
    p->g_inicial_db = v[K_G_INICIAL]; p->objetivo = v[K_OBJETIVO]; p->ventana = (int)v[K_VENTANA]; p->percentil = v[K_PERCENTIL];
    p->zona_muerta_db = v[K_ZONA]; p->kp = v[K_KP]; p->paso_max_db = v[K_PASO_MAX]; p->liberacion_rafagas = (int)v[K_LIBERACION];
    p->paso_liberacion_db = v[K_PASO_LIB]; p->nivel_proteccion = v[K_PROTECCION]; p->g_min_db = v[K_G_MIN]; p->g_max_db = v[K_G_MAX];
    p->planta = v[K_PLANTA]; *activo = (int)v[K_ACTIVO];
    return agc_params_validar(p, err, n);
}

/* ---- nucleo ---- */
void agc_iniciar(agc_t *a, const agc_params_t *p)
{
    agc_params_t copia = *p;                 /* p puede apuntar a a->p */

    memset(a, 0, sizeof(*a));
    a->p = copia;
}

static double acotar(double x, double lo, double hi) { return x < lo ? lo : (x > hi ? hi : x); }

/* Percentil con interpolacion lineal entre los valores ordenados. Ordena v. */
static double percentil(double *v, int n, double pc)
{
    double pos, frac;
    int i, j, lo, hi;

    for (i = 1; i < n; i++) {
        double x = v[i];
        for (j = i - 1; j >= 0 && v[j] > x; j--) v[j + 1] = v[j];
        v[j + 1] = x;
    }
    pos = pc / 100.0 * (n - 1);
    lo = (int)floor(pos);
    hi = (lo + 1 < n) ? lo + 1 : lo;
    frac = pos - lo;
    return v[lo] + (v[hi] - v[lo]) * frac;
}

agc_paso_t agc_rafaga(agc_t *a, double pico, double g_actual_db)
{
    const agc_params_t *p = &a->p;
    agc_paso_t r;
    double niv = pico > 1.0 ? pico : 1.0, adj[AGC_VENTANA_MAX], dg = 0.0, g_nuevo;
    int i;

    a->niv[a->cab] = niv;
    a->g[a->cab] = g_actual_db;
    a->cab = (a->cab + 1) % p->ventana;
    if (a->n < p->ventana) a->n++;
    for (i = 0; i < a->n; i++) adj[i] = a->niv[i] * pow(10.0, (g_actual_db - a->g[i]) * p->planta / 10.0);
    r.ref = percentil(adj, a->n, p->percentil);
    r.err_db = 10.0 * log10(r.ref / p->objetivo);
    r.proteccion = 0;

    if (r.err_db > p->zona_muerta_db) {                                   /* ataque */
        dg = -p->kp * r.err_db / p->planta;
        a->bajos = 0;
    } else if (r.err_db < -p->zona_muerta_db) {                           /* liberacion lenta */
        if (++a->bajos >= p->liberacion_rafagas) {
            dg = -p->kp * r.err_db / p->planta;
            if (dg > p->paso_liberacion_db) dg = p->paso_liberacion_db;
            a->bajos = 0;
        }
    } else {
        a->bajos = 0;
    }
    dg = acotar(dg, -p->paso_max_db, p->paso_max_db);
    if (niv > p->nivel_proteccion) { dg = -p->paso_max_db; r.proteccion = 1; }
    g_nuevo = acotar(g_actual_db + dg, p->g_min_db, p->g_max_db);

    r.cambio = fabs(g_nuevo - g_actual_db) >= 0.05;
    r.g_nueva_db = r.cambio ? g_nuevo : g_actual_db;
    a->rafagas++;
    if (r.cambio) a->cambios++;
    if (r.proteccion) a->protecciones++;
    return r;
}
