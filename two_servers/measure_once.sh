#!/bin/sh
prefix=$1
pid=$2
cuda_devices=$3
job_name=$4

if [ -z $job_name || "worker" = $job_name ]
then
    #./pcm.sh $pid > ${prefix}_pcm.txt &
    ./cpu_mem.sh $pid > ${prefix}_cpu.txt &
    ./smi.sh $pid $cuda_devices > ${prefix}_smi.txt &
    ./netspeed.sh ib0 $pid > ${prefix}_nic.txt &
    iostat -x -d sda -t 1 > ${prefix}_io.txt & io_pid=$!

    smi_pid="$(ps -eo pid,command | grep smi | grep -v grep | tr -s ' ' | cut -d ' ' -f 1)"

    while :
    do
        if ps -p $pid > /dev/null
        then
    	    sleep 1
            continue
        else
            break
        fi
    done
    kill $io_pid
    kill $smi_pid    #For slow return of smi
elif [ "ps" = $job_name ]
    ./cpu_mem.sh $pid > ${prefix}_pscpu.txt
fi
