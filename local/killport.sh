pids="$(netstat -anp 2>/dev/null | grep 42222 | tr -s ' ' | cut -d ' ' -f 7 | cut -d '/' -f 1)"
for pid in $pids
do
    if [ ! -z $pid ]; then
        if ps -p $pid > /dev/null; then
            sudo kill -9 $pid
        fi        
    fi
done

