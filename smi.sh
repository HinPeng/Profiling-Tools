#!/bin/sh
if [ $# != 3 ]; then
    echo -e "parameter number wrong!\n"
    exit 1
fi

dir_prefix="data/"
pid=$1
prefix=$2
cuda_devices=$3
freq=1


while :
do
date=$(date +"%Y-%m-%d_%H-%M-%S")
var="$(nvidia-smi -a -i ${cuda_devices} | grep "Bus Id\|Tx\|Rx\|Gpu\|Used GPU Memory" | tr -s ' ')"
if ps -p $pid > /dev/null
then
  echo "$date ${var}" >> ${dir_prefix}${prefix}_smi.txt
  sleep ${freq}
else
  break
fi
done
