pids="$(ps -eo pid,command | grep smi | grep -v grep | cut -d ' ' -f 1)"
for pid in $pids
do
    if ps -p $pid > /dev/null
    then
	sudo kill -9 $pid
    else
	continue
    fi
done
