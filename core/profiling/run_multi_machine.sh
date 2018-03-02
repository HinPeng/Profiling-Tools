#!/bin/bash
#source /home/core/v-xuapen/tf_1.3.0/bin/activate
machines=("10.151.41.23" "10.151.41.24")
num_machines=${#machines[*]}


worker_port=30000
ps_port=29999

worker_hosts=""
ps_hosts=""

j=`expr $num_machines - 1`
for i in `seq 0 $j`
do
    worker_hosts=$worker_hosts${machines[$i]}":$worker_port,"
    ps_hosts=$ps_hosts${machines[$i]}":$ps_port,"
done

worker_hosts=${worker_hosts%%,}
ps_hosts=${ps_hosts%%,}
#echo $worker_hosts
#echo $ps_hosts    
    

#configs="1:1 2:2 3:3 4:4"
# configs="1:1"

prefix_dir="/home/core/v-xuapen/benchmarks/scripts/tf_cnn_benchmarks/profiling/"
perf_dir=$prefix_dir"perf_log/"

mkdir -p $perf_dir

#cuda_devices="0 0,1 0,1,2,3"
cuda_devices="0"
#models="vgg16 inception3 resnet50"
models="resnet50"
#batch_sizes="8 16 32 64"
batch_sizes="8"
num_batches="100"

run(){
    ./killport.sh $worker_port $ps_port
    echo 3 | sudo tee /proc/sys/vm/drop_caches
    #    ./dis_run_perf.sh $1 $2 $3 $4 $5 $6 $7 $8 $9
    ./test.sh
}

if [ "$1" = "--remote" ]; then
    run $2 $3 $4 $5 $6 $7 $8 $9 $10
else
    for model in $models
    do
        for batch_size in $batch_sizes
        do
            for cuda_device in $cuda_devices
            do
                echo "Starting configuration ${model}_${batch_size}_${cuda_device}..."
                #Starting servers and workers
                num_gpu=$(echo $cuda_device | tr -d ',' | wc -L)
                prefix_file_name=$perf_dir$model"_"$batch_size"_"$cuda_device".txt"
                index_machine=`expr $num_machines - 1`
                while [ $index_machine -ge 0 ]
                do                    
                    if [ $index_machine -eq 0 ]; then
			echo "Starting processes locally"
#                        run $cuda_device $num_gpu $batch_size $num_batches $model $prefix_file_name $worker_hosts $ps_hosts $index_machine
                    else
                        echo "Starting processes remotely on machine $index_machine"
			ssh core@${machines[$index_machine]} "cd $prefix_dir ; ./run_multi_machine.sh --remote" &
#                        ssh core@${machines[$index_machine]} "$prefix_dir/run_multi_machine.sh --remote $cuda_device $num_gpu $batch_size $num_batches $model $prefix_file_name $worker_hosts $ps_hosts $index_machine" &
                    fi
                    ((index_machine--))
                done
                sleep 1
            done
        done
    done
fi

models="alexnet"
models="vgg16"
batch_sizes="32 64 128 512"
