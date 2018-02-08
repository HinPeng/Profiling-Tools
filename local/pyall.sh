#for file in ${1}*.txt
#do
#    python sum.py $file
#done

models="vgg16 inception3 resnet50"
##models="vgg16"
#batch_sizes="8 16 32"
##batch_sizes="64"
#cuda_devices="0 0,1 0,1,2,3"
##cuda_devices="0"
#
#for model in $models
#do
#    for batch_size in $batch_sizes
#    do
#        for cuda_device in $cuda_devices
#        do
#            python sum.py $model $batch_size $cuda_device
#        done
#    done
#done

#models="vgg16"
batch_sizes="8"
cuda_devices="0,3"
#cuda_devices="0,1,2,3,4 0,1,2,3,4,5 0,1,2,3,4,5,6"

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
