#!/bin/sh

#Default Implementation

if [ $# != 2 ]; then
    echo -e "smi parameter number wrong!\n"
    exit 1
fi

pid=$1
cuda_devices=$2
freq=1000

nvidia-smi -a -i ${cuda_devices} -lms $freq | grep "Bus Id\|Tx\|Rx\|Gpu\|Used GPU Memory" | tr -s ' ' 



