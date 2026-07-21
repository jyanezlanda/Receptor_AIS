#!/bin/sh

BITSTREAM="/media/mmcblk0p1/apps/ais_trx_loopback/ais_trx_loopback.bit"

# 1. Cargar bitstream
echo "Cargando bitstream..."
cat $BITSTREAM > /dev/xdevcfg
echo "Listop"
