log_dir="per_log/"
mkdir -p $log_dir
cuda_devices="0 0,1 0,1,2,3"
#cuda_devices="0"
models="alexnet vgg16 inception3 resnet50"
#models="alexnet"
batch_size='64'
num_batches="100"

run(){
    ./killport.sh
    echo 3 | sudo tee /proc/sys/vm/drop_caches
    ./dis_run_perf.sh $1 $2 $3 $4 $5 $6
}


for i in `seq 1 2`
do
    for model in $models
    do
        if [ "$model" = "alexnet" ]; then
            batch_size='128'
        else
            batch_size='64'
        fi

        for cuda_device in $cuda_devices
        do
            prefix=$model"_"
            if [ "$cuda_device" = "0" ]; then
                filename_prefix=$log_dir$prefix"1.txt"
                run $cuda_device 1 $batch_size $num_batches $model $filename_prefix
            elif [ "$cuda_device" = "0,1" ]; then
                filename_prefix=$log_dir$prefix"2.txt"
                run $cuda_device 2 $batch_size $num_batches $model $filename_prefix
            elif [ "$cuda_device" = "0,1,2,3" ]; then
                filename_prefix=$log_dir$prefix"4.txt"
                run $cuda_device 4 $batch_size $num_batches $model $filename_prefix
#            elif [ "$cuda_device" = "0,1,2,3,4,5,6,7" ]; then
 #               filename_prefix=$log_dir$prefix"8.txt"
  #              run $cuda_device 8 $batch_size $num_batches $model $filename_prefix
            fi
        done
    done
done
