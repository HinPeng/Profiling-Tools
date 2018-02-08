#!/bin/sh

echo 3 | sudo tee /proc/sys/vm/drop_caches
affi=$1
s=`date +%s%N`
taskset -c ${affi} ./local_run_perf.sh 0 1 64 100 vgg16 log.txt
e=`date +%s%N`
elp=`echo $e $s | awk '{print ($1-$2)/1000000000}'`
echo ${elp} >> log.txt
