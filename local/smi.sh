#!/bin/sh

#Default Implementation

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
var="$(nvidia-smi -a -i ${cuda_devices} | grep "Bus Id\|Tx\|Rx\|Gpu" | tr -s ' ')"
if ps -p $pid > /dev/null
then
  echo "$date ${var}" >> ${prefix}_smi.txt
  sleep ${freq}
else
  break
fi
done

#End


#For slow return of nvidia-smi
#if [ ! $# -eq 2 ]; then
 #   echo -e "parameter number wrong!\n"
  #  exit 1
#fi

#perfix=$1
#cuda_devices=$2
#freq_ms=1000

#nvidia-smi -a -i $cuda_devices -lms $freq_ms | grep "Bus Id\|Tx\|Rx\|Gpu" | tr -s ' ' >>${prefix}_smi.txt

