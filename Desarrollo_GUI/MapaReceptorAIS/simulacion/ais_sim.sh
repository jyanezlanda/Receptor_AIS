#!/bin/sh
# ais_sim.sh -- Envia mensajes AIS simulados (NMEA !AIVDM) por TCP para probar la GUI.
#
#   ./ais_sim.sh [puerto] [archivo]        (por defecto 1004 y ais_sim.nmea en esta carpeta)
#
# Espera a que un cliente se conecte (la GUI: pestana Conexion, Ethernet, TCP, puerto 1004,
# formato NMEA) y le envia el archivo en bucle. Cada linea "#" del archivo es una pausa de
# 1 segundo. Si el cliente se desconecta, vuelve a esperar a otro.
# Se detiene con:  pkill -f ais_sim.sh
#
# El archivo se genera en la PC con simulacion/generar_ais.py (proyecto MapaReceptorAIS).

DIR=$(cd "$(dirname "$0")" && pwd)

# Modo interno: envia el archivo por la salida estandar (la conexion TCP).
if [ "$1" = "--emitir" ]; then
    while true; do
        while IFS= read -r linea; do
            case "$linea" in
                "#"*) sleep 1 ;;
                *) printf '%s\r\n' "$linea" || exit 0 ;;
            esac
        done < "$2"
    done
fi

PUERTO=${1:-1004}
ARCHIVO=${2:-$DIR/ais_sim.nmea}

if [ ! -r "$ARCHIVO" ]; then
    echo "No se encuentra el archivo $ARCHIVO" >&2
    exit 1
fi

# nc de busybox: con -e ejecuta el emisor recien cuando hay un cliente conectado.
if nc --help 2>&1 | grep -q -- "-e PROG"; then
    MODO=e
else
    MODO=pipe
fi

echo "Simulacion AIS: $(grep -c '^!' "$ARCHIVO") sentencias, esperando clientes en el puerto TCP $PUERTO (modo $MODO)"
while true; do
    if [ "$MODO" = e ]; then
        nc -l -p "$PUERTO" -e /bin/sh "$DIR/ais_sim.sh" --emitir "$ARCHIVO"
    else
        sh "$DIR/ais_sim.sh" --emitir "$ARCHIVO" | nc -l -p "$PUERTO"
    fi
    echo "$(date '+%H:%M:%S') cliente desconectado; esperando otro"
    sleep 1
done
