#!/bin/bash
#log_dir="per_log_ps/"
log_dir="prof_log_ps/"
mkdir -p $log_dir
#cuda_devices="0,2 0,7 0,1,6,7 0,5,6,7"
#cuda_devices="0,1"
cuda_devices1=('0' '0,1' '0,1,2,3')
cuda_devices2=('2' '2,3' '4,5,6,7')
models="vgg16 inception3 resnet50"
#models="alexnet"
batch_sizes="8 16 32 64"
num_batches="100"

run(){
    echo 3 | sudo tee /proc/sys/vm/drop_caches
    ./local_run_perf.sh $1 $2 $3 $4 $5 $6
}

run_psc(){
    echo 3 | sudo tee /proc/sys/vm/drop_caches
    taskset -c 0-13,28-41 ./local_run_perf_psc.sh $1 $2 $3 $4 $5 $6
}

run_ps(){
    echo 3 | sudo tee /proc/sys/vm/drop_caches
    ./killport.sh
    ./ps_run_perf.sh $1 $2 $3 $4 $5 $6 $7
}

run_ps_mea(){
    echo 3 | sudo tee /proc/sys/vm/drop_caches
    ./killport.sh
    ./ps_run_prof.sh $1 $2 $3 $4 $5 $6 $7
}

for model in $models
do
    for batch_size in $batch_sizes
    do
        for i in `seq 0 2`
        do
                prefix=$model"_"$batch_size"_"
                if [ $i -eq 0 ]; then
                    filename_prefix=$log_dir$prefix"1"
                    run_ps_mea ${cuda_devices1[$i]} 1 $batch_size $num_batches $model $filename_prefix ${cuda_devices2[$i]}
                elif [ $i -eq 1 ]; then
                    filename_prefix=$log_dir$prefix"2"
                    run_ps_mea ${cuda_devices1[$i]} 2 $batch_size $num_batches $model $filename_prefix ${cuda_devices2[$i]}
                elif [ $i -eq 2 ]; then
                    filename_prefix=$log_dir$prefix"4"
                    run_ps_mea ${cuda_devices1[$i]} 4 $batch_size $num_batches $model $filename_prefix ${cuda_devices2[$i]}
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
        for i in `seq 0 2`
        do
                prefix=$model"_"$batch_size"_"
                if [ $i -eq 0 ]; then
                    filename_prefix=$log_dir$prefix"1"
                    run_ps_mea ${cuda_devices1[$i]} 1 $batch_size $num_batches $model $filename_prefix ${cuda_devices2[$i]}
                elif [ $i -eq 1 ]; then
                    filename_prefix=$log_dir$prefix"2"
                    run_ps_mea ${cuda_devices1[$i]} 2 $batch_size $num_batches $model $filename_prefix ${cuda_devices2[$i]}
                elif [ $i -eq 2 ]; then
                    filename_prefix=$log_dir$prefix"4"
                    run_ps_mea ${cuda_devices1[$i]} 4 $batch_size $num_batches $model $filename_prefix ${cuda_devices2[$i]}
                fi
        done
    done
done
            

#
#for i in `seq 1 1`
#do
#    for model in $models
#    do
#        for batch_size in $batch_sizes
#        do
#            for cuda_device in $cuda_devices
#            do
#                prefix=$model"_"$batch_size"_"
#                if [ "$cuda_device" = "0" ]; then
#                    filename_prefix=$log_dir$prefix"1.txt"
#                    run_psc $cuda_device 1 $batch_size $num_batches $model $filename_prefix
#                elif [ "$cuda_device" = "0,1" ]; then
#                    filename_prefix=$log_dir$prefix"2.txt"
#                    run_psc $cuda_device 2 $batch_size $num_batches $model $filename_prefix
#                elif [ "$cuda_device" = "0,2" ]; then
#                    filename_prefix=$log_dir$prefix"02.txt"
#                    run_psc $cuda_device 2 $batch_size $num_batches $model $filename_prefix
#                elif [ "$cuda_device" = "0,7" ]; then
#                    filename_prefix=$log_dir$prefix"07.txt"
#                    run_psc $cuda_device 2 $batch_size $num_batches $model $filename_prefix
#                elif [ "$cuda_device" = "0,1,2" ]; then
#                    filename_prefix=$log_dir$prefix"3.txt"
#                    run_psc $cuda_device 3 $batch_size $num_batches $model $filename_prefix
#                elif [ "$cuda_device" = "0,1,2,3" ]; then
#                    filename_prefix=$log_dir$prefix"4.txt"
#                    run_psc $cuda_device 4 $batch_size $num_batches $model $filename_prefix
#                elif [ "$cuda_device" = "0,2,4,6" ]; then
#                    filename_prefix=$log_dir$prefix"0246.txt"
#                    run_psc $cuda_device 4 $batch_size $num_batches $model $filename_prefix                    
#                elif [ "$cuda_device" = "0,1,6,7" ]; then
#                    filename_prefix=$log_dir$prefix"0167.txt"
#                    run_psc $cuda_device 4 $batch_size $num_batches $model $filename_prefix
#                elif [ "$cuda_device" = "0,5,6,7" ]; then
#                    filename_prefix=$log_dir$prefix"0567.txt"
#                    run_psc $cuda_device 4 $batch_size $num_batches $model $filename_prefix                
#                elif [ "$cuda_device" = "0,1,2,3,4" ]; then
#                    filename_prefix=$log_dir$prefix"5.txt"
#                    run_psc $cuda_device 5 $batch_size $num_batches $model $filename_prefix
#                elif [ "$cuda_device" = "0,1,2,3,4,5" ]; then
#                    filename_prefix=$log_dir$prefix"6.txt"
#                    run_psc $cuda_device 6 $batch_size $num_batches $model $filename_prefix
#                elif [ "$cuda_device" = "0,1,2,3,4,5,6" ]; then
#                    filename_prefix=$log_dir$prefix"7.txt"
#                    run_psc $cuda_device 7 $batch_size $num_batches $model $filename_prefix
#                elif [ "$cuda_device" = "0,1,2,3,4,5,6,7" ]; then
#                    filename_prefix=$log_dir$prefix"8.txt"
#                    run_psc $cuda_device 8 $batch_size $num_batches $model $filename_prefix
#                fi
#            done
#        done
#    done
#done
#
##log_dir="per_log_psc/"
#models="alexnet"
#batch_sizes="32 64 128 512"
#
#for i in `seq 1 1`
#do
#    for model in $models
#    do
#        for batch_size in $batch_sizes
#        do
#            for cuda_device in $cuda_devices
#            do
#                prefix=$model"_"$batch_size"_"
#                if [ "$cuda_device" = "0" ]; then
#                    filename_prefix=$log_dir$prefix"1.txt"
#                    run_psc $cuda_device 1 $batch_size $num_batches $model $filename_prefix
#                elif [ "$cuda_device" = "0,1" ]; then
#                    filename_prefix=$log_dir$prefix"2.txt"
#                    run_psc $cuda_device 2 $batch_size $num_batches $model $filename_prefix
#                elif [ "$cuda_device" = "0,2" ]; then
#                    filename_prefix=$log_dir$prefix"02.txt"
#                    run_psc $cuda_device 2 $batch_size $num_batches $model $filename_prefix
#                elif [ "$cuda_device" = "0,7" ]; then
#                    filename_prefix=$log_dir$prefix"07.txt"
#                    run_psc $cuda_device 2 $batch_size $num_batches $model $filename_prefix
#                elif [ "$cuda_device" = "0,1,2" ]; then
#                    filename_prefix=$log_dir$prefix"3.txt"
#                    run_psc $cuda_device 3 $batch_size $num_batches $model $filename_prefix
#                elif [ "$cuda_device" = "0,1,2,3" ]; then
#                    filename_prefix=$log_dir$prefix"4.txt"
#                    run_psc $cuda_device 4 $batch_size $num_batches $model $filename_prefix
#                elif [ "$cuda_device" = "0,2,4,6" ]; then
#                    filename_prefix=$log_dir$prefix"0246.txt"
#                    run_psc $cuda_device 4 $batch_size $num_batches $model $filename_prefix                                        
#                elif [ "$cuda_device" = "0,1,6,7" ]; then
#                    filename_prefix=$log_dir$prefix"0167.txt"
#                    run_psc $cuda_device 4 $batch_size $num_batches $model $filename_prefix
#                elif [ "$cuda_device" = "0,5,6,7" ]; then
#                    filename_prefix=$log_dir$prefix"0567.txt"
#                    run_psc $cuda_device 4 $batch_size $num_batches $model $filename_prefix                
#                elif [ "$cuda_device" = "0,1,2,3,4" ]; then
#                    filename_prefix=$log_dir$prefix"5.txt"
#                    run_psc $cuda_device 5 $batch_size $num_batches $model $filename_prefix
#                elif [ "$cuda_device" = "0,1,2,3,4,5" ]; then
#                    filename_prefix=$log_dir$prefix"6.txt"
#                    run_psc $cuda_device 6 $batch_size $num_batches $model $filename_prefix
#                elif [ "$cuda_device" = "0,1,2,3,4,5,6" ]; then
#                    filename_prefix=$log_dir$prefix"7.txt"
#                    run_psc $cuda_device 7 $batch_size $num_batches $model $filename_prefix
#                elif [ "$cuda_device" = "0,1,2,3,4,5,6,7" ]; then
#                    filename_prefix=$log_dir$prefix"8.txt"
#                    run_psc $cuda_device 8 $batch_size $num_batches $model $filename_prefix
#                fi
#            done
#        done
#    done
#done

