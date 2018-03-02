#!/bin/bash
if [ $# != 2 ]; then
    echo -e "killport parameter number wrong!\n"
    exit 1
fi


worker_port=$1
ps_port=$2
pids="$(netstat -anp 2>/dev/null | grep $worker_port | tr -s ' ' | cut -d ' ' -f 7 | cut -d '/' -f 1)"
for pid in $pids
do
    if [ ! -z $pid ]; then
        if ps -p $pid > /dev/null; then
            sudo kill -9 $pid
        fi        
    fi
done

pids="$(netstat -anp 2>/dev/null | grep $ps_port | tr -s ' ' | cut -d ' ' -f 7 | cut -d '/' -f 1)"
for pid in $pids
do
    if [ ! -z $pid ]; then
        if ps -p $pid > /dev/null; then
            sudo kill -9 $pid
        fi        
    fi
done

