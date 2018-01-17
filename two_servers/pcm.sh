#!/bin/sh
if [ $# != 1 ]; then
    echo -e "pcm parameter number wrong!\n"
    exit 1
fi

pid=$1
freq=1


while :
do
date=$(date +"%Y-%m-%d_%H-%M-%S")
var="$(sudo /home/fanyang/v-wencxi/pcm/pcm-pcie.x -B -i=1 2>/dev/null | awk 'NR==2 || NR==3{print}' | tr -s ' ')"  #| cut -d ' ' -f 2,3,14,15)"
if ps -p $pid > /dev/null
then
  echo "$date ${var}"
  sleep ${freq}
else
  break
fi
done
