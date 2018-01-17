#for file in ${1}*.txt
#do
#    python sum.py $file
#done

models="vgg16 inception3 resnet50"
#models="alexnet"
batch_sizes="8 16 32 64"
#batch_sizes="32 64 128 512"
cuda_devices="0 0,1 0,1,2,3 0,1,2,3,4,5,6,7"

for model in $models
do
    for batch_size in $batch_sizes
    do
        for cuda_device in $cuda_devices
        do
            python sum.py $model $batch_size $cuda_device
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
            python sum.py $model $batch_size $cuda_device
        done
    done
done
