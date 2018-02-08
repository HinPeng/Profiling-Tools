#!/bin/sh

# Default Implementation for slow return of smi
#
#if [ $# != 2 ]; then
#    echo -e "smi parameter number wrong!\n"
#    exit 1
#fi
#
#pid=$1
#cuda_devices=$2
#freq=1000
#
#nvidia-smi -a -i ${cuda_devices} -lms $freq | grep "Bus Id\|Tx\|Rx\|Gpu\|Used GPU Memory" | tr -s ' ' 

# For quick return of smi
if [ $# != 2 ]
then
    echo "smi paramerter number wrong!"
    exit 1
fi

pid=$1
cuda_devices=$2
freq=1

while :
do
    var="$(nvidia-smi -a -i ${cuda_devices} | grep "Bus Id\|Tx\|Rx\|Gpu\|Used GPU Memory" | tr -s ' ' )"
    if ps -p $pid > /dev/null
    then
        echo "$var"
        sleep ${freq}
    else
        break
    fi
done


