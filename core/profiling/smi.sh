#!/bin/sh
if [ $# != 4 ]; then
    echo -e "smi parameter number wrong!\n"
    exit 1
fi

pid=$1
prefix=$2
cuda_devices=$3
freq=$4


while :
do
date=$(date +"%Y-%m-%d_%H-%M-%S")
var="$(nvidia-smi -a -i ${cuda_devices} | grep "Bus Id\|Tx\|Rx\|Gpu\|Used GPU Memory" | tr -s ' ')"
if ps -p $pid > /dev/null
then
  echo "$date ${var}" >> ${prefix}_smi.txt
  sleep ${freq}
else
  break
fi
done
