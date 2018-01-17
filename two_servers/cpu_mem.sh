#!/bin/sh
if [ $# != 1 ]; then
    echo -e "cpu profiling parameter number wrong!\n"
    exit 1
fi

pid=$1
freq=1


#total="$(free -m | grep Mem | tr -s ' ' | cut -d ' ' -f 2)"
#echo $total
while :
do
date=$(date +"%Y-%m-%d_%H-%M-%S")
var="$(top -b -n 1 -p ${pid}| grep -w ${pid} | tr -s ' ' | cut -d ' ' -f 9,10)"
if ps -p $pid > /dev/null
then
  echo "$date ${var}"
  sleep ${freq}
else
  break
fi
done
