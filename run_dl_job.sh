#cuda_device=$1
#num_gpu=$2
#batch_size=$3
#model=$4

killall -9 python
log_file="log.txt"
rm -f $log_file

cuda_devices="0 0,1 0,1,2,3 0,1,2,3,4,5,6,7"
#num_gpus="1 2 4 8"
#batch_sizes="8 16 32 64"
batch_sizes="16"
models="alexnet vgg16 inception3 resnet50"



test(){
    CUDA_VISIBLE_DEVICES=$1 python ../../tf_cnn_benchmarks.py --local_parameter_device=cpu --num_gpus=$2 --batch_size=$3 --model=$4 --variable_update=parameter_server --use_nccl=True --num_batches=1000 --data_dir=/home/fanyang/imagenet/raw-data/tmp --data_name=imagenet
}



for model in $models
do
    for batch_size in $batch_sizes
    do
        for cuda_device in $cuda_devices
        do
            echo "$model $batch_size $cuda_device" >> $log_file
            #test $cuda_device 4 $batch_size $model | grep "total images/sec" >> log.txt

            if [ "$cuda_device" = "0" ]; then
                test $cuda_device 1 $batch_size $model | grep "total images/sec" >> $log_file
            elif [ "$cuda_device" = "0,1" ]; then
                test $cuda_device 2 $batch_size $model | grep "total images/sec" >> $log_file
            elif [ "$cuda_device" = "0,1,2,3" ]; then
                test $cuda_device 4 $batch_size $model | grep "total images/sec" >> $log_file
            elif [ "$cuda_device" = "0,1,2,3,4,5,6,7" ]; then
                test $cuda_device 8 $batch_size $model | grep "total images/sec" >> $log_file
            fi
        done
    done
done







                
                               
