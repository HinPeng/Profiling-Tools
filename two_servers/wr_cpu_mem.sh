#!/bin/sh
if [ $# != 3 ]; then
    echo -e "cpu parameter number wrong!\n"
    exit 1
fi

pid=$1
prefix=$2
freq=$3


total="$(free -m | grep Mem | tr -s ' ' | cut -d ' ' -f 2)"
#echo $total
while :
do
date=$(date +"%Y-%m-%d_%H-%M-%S")
var="$(top -b -n 1 -p ${pid}| grep -w ${pid} | tr -s ' ' | cut -d ' ' -f 9,10)"
if ps -p $pid > /dev/null
then
  set ${var}
  cpu_percentage="$1"
  mem_percentage="$2"
  echo "$date ${cpu_percentage} ${mem_percentage} ${total}" >> ${prefix}_wr_cpu_mem.txt
  sleep ${freq}
else
  break
fi
done
