#!/bin/bash
source /home/fanyang/v-xuapen/tf_1.3.0/bin/activate
#machines=("10.0.0.19" "10.0.0.20" "10.0.0.23" "10.0.0.25")
machines=("10.0.0.19" "10.0.0.20")

num_machines=${#machines[*]}

worker_port=30000
ps_port=29999

worker_hosts=""
ps_hosts=""

machine_suffix=""
j=`expr $num_machines - 1`
for i in `seq 0 $j`
do
    worker_hosts=$worker_hosts${machines[$i]}":$worker_port,"
    ps_hosts=$ps_hosts${machines[$i]}":$ps_port,"
    machine_suffix=$machine_suffix${machines[$i]##*.}"_"
done

worker_hosts=${worker_hosts%,*}
ps_hosts=${ps_hosts%,*}
machine_suffix=${machine_suffix%_*}
#echo $worker_hosts
#echo $ps_hosts
#echo $machine_suffix
    

#configs="1:1 2:2 3:3 4:4"
# configs="1:1"

prefix_dir="/home/fanyang/v-xuapen/benchmarks/scripts/tf_cnn_benchmarks/profiling/"
perf_dir=$prefix_dir"perf_log_"$machine_suffix"/"

mkdir -p $perf_dir

cuda_devices="0 0,1 0,1,2,3 0,1,2,3,4,5,6,7"

#cuda_devices="0"
#models="inception3 resnet50"
#models="resnet50"
#batch_sizes="8 16 32 64"
#batch_sizes="64"
num_batches="100"

models="alexnet"
batch_sizes="32 64 128 512"

run(){
#    ./killport.sh $ps_port
#    ./killport.sh $worker_port
#    echo 3 | sudo tee /proc/sys/vm/drop_caches
    ./dis_run_perf.sh $1 $2 $3 $4 $5 $6 $7 $8 $9
}

if [ "$1" = "--remote" ]; then
    run $2 $3 $4 $5 $6 $7 $8 $9 ${10}
else
    for model in $models
    do
        for batch_size in $batch_sizes
        do
            for cuda_device in $cuda_devices
            do
                echo "Starting configuration ${model}_${batch_size}_${cuda_device}..."
                num_gpu=$(echo $cuda_device | tr -d ',' | wc -L)
                prefix_file_name=$perf_dir$model"_"$batch_size"_"$cuda_device".txt"
                index_machine=`expr $num_machines - 1`
                while [ $index_machine -ge 0 ]
                do                    
                    if [ $index_machine -eq 0 ]; then
			echo "Starting processes locally"
#			echo 3 | sudo tee /proc/sys/vm/drop_caches
                        run $cuda_device $num_gpu $batch_size $num_batches $model $prefix_file_name $worker_hosts $ps_hosts $index_machine
                    else
                        echo "Starting processes remotely on machine $index_machine"
                        ssh fanyang@${machines[$index_machine]} "cd $prefix_dir; ./run_multi_machine.sh --remote $cuda_device $num_gpu $batch_size $num_batches $model $prefix_file_name $worker_hosts $ps_hosts $index_machine; exit" &
                    fi
                    ((index_machine--))
                done
                sleep 10
            done
        done
    done
fi

#models="alexnet"
#batch_sizes="32 64 128 512"
#if [ "$1" = "--remote" ]; then
#    run $2 $3 $4 $5 $6 $7 $8 $9 ${10}
#else
#    for model in $models
#    do
#        for batch_size in $batch_sizes
#        do
#            for cuda_device in $cuda_devices
#            do
#                echo "Starting configuration ${model}_${batch_size}_${cuda_device}..."
#                num_gpu=$(echo $cuda_device | tr -d ',' | wc -L)
#                prefix_file_name=$perf_dir$model"_"$batch_size"_"$cuda_device".txt"
#                index_machine=`expr $num_machines - 1`
#                while [ $index_machine -ge 0 ]
#                do                    
#                    if [ $index_machine -eq 0 ]; then
#			echo "Starting processes locally"
##			echo 3 | sudo tee /proc/sys/vm/drop_caches
#                        run $cuda_device $num_gpu $batch_size $num_batches $model $prefix_file_name $worker_hosts $ps_hosts $index_machine
#                    else
#                        echo "Starting processes remotely on machine $index_machine"
#                        ssh fanyang@${machines[$index_machine]} "cd $prefix_dir; ./run_multi_machine.sh --remote $cuda_device $num_gpu $batch_size $num_batches $model $prefix_file_name $worker_hosts $ps_hosts $index_machine" &
#                    fi
#                    ((index_machine--))
#                done
#                sleep 10
#            done
#        done
#    done
#fi
#
