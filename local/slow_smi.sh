#!/bin/sh

#For slow return of nvidia-smi
if [ ! $# -eq 3 ]; then
    echo -e "smi parameter number wrong!\n"
    exit 1
fi

perfix=$1
cuda_devices=$2
freq_ms=$3

nvidia-smi -a -i $cuda_devices -lms $freq_ms >>${prefix}_smi.txt

