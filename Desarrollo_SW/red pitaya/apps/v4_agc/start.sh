#!/bin/sh

BITSTREAM="/media/mmcblk0p1/apps/system_wrapper.bit"

# 1. Cargar bitstream
echo "Cargando bitstream..."
cat $BITSTREAM > /dev/xdevcfg
echo "Listop"
