#!/bin/sh
data_dir="prof_data/"
#sudo rm $data_dir*
mkdir -p $data_dir

#work_dir="/home/fanyang/v-wencxi/"

#cuda_devices="0 0,1 0,1,2,3 0,1,2,3,4,5,6,7"
cuda_devices="0 0,1 0,1,2,3"

models="alexnet inception3 resnet50"
#models="vgg16"

batch_size='64'
num_batches='100'

freq=0.5

run(){
    echo 3 | sudo tee /proc/sys/vm/drop_caches
    while :
    do
        ./killport.sh
        killall -9 python
        ./dis_run_prof.sh $1 $2 $3 $4 $5 & sleep 5
        #        pids="$(top -b -n 1 | grep -w "python" | grep -w "R\|S" | cut -d ' ' -f 1)"
        pids="$(ps -eo pid,stat,command | grep 'python ../tf_cnn' | grep -v grep | tr -s ' ' | cut -d ' ' -f 1)"

        ps_pid=100000
	    wr_pid=0
	    count=0
	        
	    for pid in $pids
        do
            if [ -z $pid ];then
                echo "Can not get the TF process pid, launch again!"
                break
            else
	        if [ $pid -gt $wr_pid ];then
		    wr_pid=$pid		    
	        fi
		if [ $pid -lt $ps_pid ];then
		    ps_pid=$pid
		fi		
	        count=`expr $count + 1`
            fi
	    done

	    echo $ps_pid
	    echo $wr_pid
	    echo $count
        
	    if [ $count -eq 2 ];then
		break
	    else
		echo "Can not get ps and worker pid correctly, launch again!"
		continue
	    fi
	done
    
    
    # mesurement content
    ./ps_cpu_mem.sh ${ps_pid} $6 $freq &
    ./wr_cpu_mem.sh ${wr_pid} $6 $freq &
    ./smi.sh ${wr_pid} $6 $1 $freq &
    ./pcm.sh ${wr_pid} $6 $freq &
    ./netspeed.sh ib0 ${wr_pid} $6 &
    ./io.sh $6 & io_pid=$!

    while :
    do
        if ps -p $wr_pid > /dev/null
        then
            continue
        else
            break
        fi
    done
    kill $io_pid
}

for model in $models             
do
    if [ "$model" = "alexnet" ]; then
        batch_size='128'
    else
        batch_size='64'
    fi

    for cuda_device in $cuda_devices
    do
        filename_prefix=$data_dir$model"_"$batch_size"_"$cuda_device
        if [ "$cuda_device" = "0" ]; then
            run $cuda_device 1 $batch_size $num_batches $model $filename_prefix
        elif [ "$cuda_device" = "0,1" ]; then
            run $cuda_device 2 $batch_size $num_batches $model $filename_prefix
        elif [ "$cuda_device" = "0,1,2,3" ]; then
            run $cuda_device 4 $batch_size $num_batches $model $filename_prefix
    #    elif [ "$cuda_device" = "0,1,2,3,4,5,6,7" ]; then
     #       run $cuda_device 8 $batch_size $model $filename_prefix
        fi
    done
done

