log_dir="perf_int_log_nccl/"
mkdir -p $log_dir

#cuda_devices="0,1,2 0,1,2,3,4 0,1,2,3,4,5 0,1,2,3,4,5,6"
#cuda_devices="0,3 0,7"
models="vgg16 inception3 resnet50"
#models="resnet50"
batch_sizes="8 16 32 64"
num_batches="100"

run(){
    echo 3 | sudo tee /proc/sys/vm/drop_caches
    taskset -c 0-13,28-41 ./local_run_perf.sh 0,7 2 $1 $2 $3 $4 & taskset -c 14-27,42-55 ./local_run_perf.sh 1,6 2 $1 $2 $3 $4
}

run_psc(){
    echo 3 | sudo tee /proc/sys/vm/drop_caches
    taskset -c 0-13,28-41 ./local_run_perf_psc.sh 0,2 2 $1 $2 $3 $4 & taskset -c 14-27,42-55 ./local_run_perf_psc.sh 1,3 2 $1 $2 $3 $4
}


for i in `seq 1 1`
do
    for model in $models
    do
        for batch_size in $batch_sizes
        do
            filename_prefix=$log_dir$model"_"$batch_size".txt"
            run $batch_size $num_batches $model $filename_prefix
        done
    done
done

models="alexnet"
batch_sizes="32 64 128 512"

for i in `seq 1 1`
do
    for model in $models
    do
        for batch_size in $batch_sizes
        do
            filename_prefix=$log_dir$model"_"$batch_size".txt"
            run $batch_size $num_batches $model $filename_prefix
        done
    done
done

#log_dir="perf_int_log_psc/"
#mkdir -p $log_dir
#
#models="vgg16 inception3 resnet50"
##models="alexnet"
#batch_sizes="8 16 32 64"
#num_batches="100"
#
#for i in `seq 1 1`
#do
#    for model in $models
#    do
#        for batch_size in $batch_sizes
#        do
#            filename_prefix=$log_dir$model"_"$batch_size".txt"
#            run_psc $batch_size $num_batches $model $filename_prefix
#        done
#    done
#done
#
#models="alexnet"
#batch_sizes="32 64 128 512"
#
#for i in `seq 1 1`
#do
#    for model in $models
#    do
#        for batch_size in $batch_sizes
#        do
#            filename_prefix=$log_dir$model"_"$batch_size".txt"
#            run_psc $batch_size $num_batches $model $filename_prefix
#        done
#    done
#done
#

