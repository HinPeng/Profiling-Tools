#!/bin/bash
if [ $# != 2 ]; then
    echo -e "nic parameter number wrong!\n"
    exit 1
fi

pid=$2
#prefix=$3
freq=1


if [ -z "$1" ]; then
        echo
        echo usage: $0 network-interface
        echo
        echo e.g. $0 eth0
        echo
        exit
fi

IF=$1

while true
do
        R1=`cat /sys/class/net/$1/statistics/rx_bytes`
        T1=`cat /sys/class/net/$1/statistics/tx_bytes`
        sleep ${freq}
        R2=`cat /sys/class/net/$1/statistics/rx_bytes`
        T2=`cat /sys/class/net/$1/statistics/tx_bytes`
        TB=`expr $T2 - $T1`
        RB=`expr $R2 - $R1`
        TBPS=`expr $TB / $freq`
        RBPS=`expr $RB / $freq`
        TKBPS=`expr $TBPS / 1024`
        RKBPS=`expr $RBPS / 1024`

        date=$(date +"%Y-%m-%d_%H-%M-%S")
        
        if ps -p $pid > /dev/null
        then
          echo "${date} tx_$1: $TKBPS kb/s rx_$1: $RKBPS kb/s" #>> ${prefix}_nic.txt
        else
          break
        fi

done
