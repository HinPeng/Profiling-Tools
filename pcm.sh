#!/bin/sh
if [ $# != 2 ]; then
    echo -e "parameter number wrong!\n"
    exit 1
fi

dir_prefix="data/"
pid=$1
prefix=$2
freq=1


while :
do
date=$(date +"%Y-%m-%d_%H-%M-%S")
var="$(sudo /home/fanyang/v-wencxi/pcm/pcm-pcie.x -B -i=1 2>/dev/null | awk 'NR==2 || NR==3{print}' | tr -s ' ')"  #| cut -d ' ' -f 2,3,14,15)"
if ps -p $pid > /dev/null
then
  echo "$date ${var}" >> ${dir_prefix}${prefix}_pcm.txt
  sleep ${freq}
else
  break
fi
done
