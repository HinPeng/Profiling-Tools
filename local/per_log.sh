log_dir="per_log/"
mkdir -p $log_dir
cuda_devices="0,1,2,3 0,1,2,3,4,5,6,7"
#cuda_devices="0"
#models="alexnet vgg16 inception3 resnet50"
models="inception3 resnet50"
batch_sizes="8 16 32"
num_batches="100"

run(){
    echo 3 | sudo tee /proc/sys/vm/drop_caches
    ./local_run_perf.sh $1 $2 $3 $4 $5 $6
}


for i in `seq 1 2`
do
    for model in $models
    do
        for batch_size in $batch_sizes
        do
            for cuda_device in $cuda_devices
            do
                prefix=$model"_"$batch_size"_"
                if [ "$cuda_device" = "0" ]; then
                    filename_prefix=$log_dir$prefix"1.txt"
                    run $cuda_device 1 $batch_size $num_batches $model $filename_prefix
                elif [ "$cuda_device" = "0,1" ]; then
                    filename_prefix=$log_dir$prefix"2.txt"
                    run $cuda_device 2 $batch_size $num_batches $model $filename_prefix
                elif [ "$cuda_device" = "0,1,2,3" ]; then
                    filename_prefix=$log_dir$prefix"4.txt"
                    run $cuda_device 4 $batch_size $num_batches $model $filename_prefix
                elif [ "$cuda_device" = "0,1,2,3,4,5,6,7" ]; then
                    filename_prefix=$log_dir$prefix"8.txt"
                    run $cuda_device 8 $batch_size $num_batches $model $filename_prefix
                fi
            done
        done
    done
done
