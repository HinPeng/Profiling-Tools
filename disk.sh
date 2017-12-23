#!/bin/sh
if [ $# != 2]; then
    echo -e 'parameter number wrong!\n'
    exit 1
fi

dir_prefix='data/'
pid=$1
prefix=$2
freq=1

while :
do
    date=$(date +"%Y-%m-%d_%H-%M-%S")
    var="$(iostat -x -d sda | grep sda | tr -s ' ' | cut -d ' ' -f 6,7,14)"
    if ps -p $pid > /dev/null
    then
        echo "$date ${var}" >> ${dir_prefix}${prefix}_disk.txt
        sleep $freq
    else
        break
    fi
done

   
