#!/bin/sh

#For slow return of nvidia-smi
if [ ! $# -eq 2 ]; then
    echo -e "smi parameter number wrong!\n"
    exit 1
fi

#perfix=$1
cuda_devices=$1
freq_ms=$2

nvidia-smi -a -i $cuda_devices -lms $freq_ms | grep "Bus Id\|Tx\|Rx\|Gpu\|Used GPU Memory"

