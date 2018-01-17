data_dir="prof_data/"
mkdir -p $data_dir

cuda_devices="0 0,1 0,1,2,3"
#cuda_devices="0,1"
num_batches='100'

run(){
    echo 3 | sudo tee /proc/sys/vm/drop_caches
    ./killport.sh
    ./dis_run_prof.sh $1 $2 $3 $4 $5 $6
}
#
#run_psc(){
#    echo 3 | sudo tee /proc/sys/vm/drop_caches
#    ./local_run_prof_psc.sh $1 $2 $3 $4 $5 $6
#}

models="vgg16 inception3 resnet50"
#models="resnet50"
batch_sizes="8 16 32 64"
#batch_sizes='32'


for model in $models             
do
    for batch_size in $batch_sizes
    do
        for cuda_device in $cuda_devices
        do
            prefix=$data_dir$model"_"$batch_size"_"$cuda_device
            if [ "$cuda_device" = "0" ]; then
                run $cuda_device 1 $batch_size $num_batches $model $prefix
            elif [ "$cuda_device" = "0,1" ]; then
                run $cuda_device 2 $batch_size $num_batches $model $prefix
            elif [ "$cuda_device" = "0,1,2,3" ]; then
                run $cuda_device 4 $batch_size $num_batches $model $prefix
            elif [ "$cuda_device" = "0,1,2,3,4,5,6,7" ]; then
                run $cuda_device 8 $batch_size $num_batches $model $prefix
            fi
        done
    done
done

models="alexnet"
batch_sizes="32 64 128 512"

for model in $models             
do
   for batch_size in $batch_sizes
    do
        for cuda_device in $cuda_devices
        do
            prefix=$data_dir$model"_"$batch_size"_"$cuda_device
            if [ "$cuda_device" = "0" ]; then
                run $cuda_device 1 $batch_size $num_batches $model $prefix
            elif [ "$cuda_device" = "0,1" ]; then
                run $cuda_device 2 $batch_size $num_batches $model $prefix
            elif [ "$cuda_device" = "0,1,2,3" ]; then
                run $cuda_device 4 $batch_size $num_batches $model $prefix
            elif [ "$cuda_device" = "0,1,2,3,4,5,6,7" ]; then
                run $cuda_device 8 $batch_size $num_batches $model $prefix
            fi
        done
    done
done
#
#data_dir="prof_data_psc/"
#mkdir -p $data_dir
#
#models="vgg16 inception3 resnet50"
##models="resnet50"
#batch_sizes="8 16 32 64"
##batch_sizes='32'
#
#
#for model in $models             
#do
#    for batch_size in $batch_sizes
#    do
#        for cuda_device in $cuda_devices
#        do
#            prefix=$data_dir$model"_"$batch_size"_"$cuda_device
#            if [ "$cuda_device" = "0" ]; then
#                run_psc $cuda_device 1 $batch_size $num_batches $model $prefix
#            elif [ "$cuda_device" = "0,1" ]; then
#                run_psc $cuda_device 2 $batch_size $num_batches $model $prefix
#            elif [ "$cuda_device" = "0,1,2,3" ]; then
#                run_psc $cuda_device 4 $batch_size $num_batches $model $prefix
#            elif [ "$cuda_device" = "0,1,2,3,4,5,6,7" ]; then
#                run_psc $cuda_device 8 $batch_size $num_batches $model $prefix
#            fi
#        done
#    done
#done
#
#models="alexnet"
#batch_sizes="32 64 128 512"
#
#for model in $models             
#do
#   for batch_size in $batch_sizes
#    do
#        for cuda_device in $cuda_devices
#        do
#            prefix=$data_dir$model"_"$batch_size"_"$cuda_device
#            if [ "$cuda_device" = "0" ]; then
#                run_psc $cuda_device 1 $batch_size $num_batches $model $prefix
#            elif [ "$cuda_device" = "0,1" ]; then
#                run_psc $cuda_device 2 $batch_size $num_batches $model $prefix
#            elif [ "$cuda_device" = "0,1,2,3" ]; then
#                run_psc $cuda_device 4 $batch_size $num_batches $model $prefix
#            elif [ "$cuda_device" = "0,1,2,3,4,5,6,7" ]; then
#                run_psc $cuda_device 8 $batch_size $num_batches $model $prefix
#            fi
#        done
#    done
#done

