data_dir="prof_data/"
mkdir -p $data_dir

#work_dir="/home/fanyang/v-wencxi/"

#cuda_devices="0 0,1 0,1,2,3 0,1,2,3,4,5,6,7"
cuda_devices="0 0,1 0,1,2,3 0,1,2,3,4,5,6,7"

models="alexnet vgg16 inception3 resnet50"
#models="vgg16"

batch_sizes='64'
num_batches='100'

freq=1
freq_ms=1000

run(){
    echo 3 | sudo tee /proc/sys/vm/drop_caches
    while :
    do
#        ./killport.sh
        killall -9 python
        ./local_run_prof.sh $1 $2 $3 $4 $5 & pid="$(top -b -n 1 | grep -w "python" | grep -w "R\|S" | cut -d ' ' -f 1)"
        if [ -z $pid ];then
            echo "Can not get the TF process pid, launch again!"
            continue
        else
            break
        fi
    done
    
    
    # mesurement content
    ./cpu_mem.sh ${pid} $6 $freq &
    ./pcm.sh ${pid} $6 $freq &
    ./slow_smi.sh $6 $1 $freq_ms & smi_pid=$!    #For slow return smi
    #./smi.sh ${pid} $6 $1 $freq &
    ./io.sh $6 & io_pid=$!

    while :
    do
        if ps -p $pid > /dev/null
        then
            continue
        else
            break
        fi
    done
    kill $io_pid
    kill $smi_pid    #For slow return of smi
}

for model in $models             
do
    for batch_size in $batch_sizes
    do
        for cuda_device in $cuda_devices
        do
            filename_prefix=$data_dir$model"_"$batch_size"_"$cuda_device
            if [ "$cuda_device" = "0" ]; then
                run $cuda_device 1 $batch_size $num_batches $model $filename_prefix
            elif [ "$cuda_device" = "0,1" ]; then
                run $cuda_device 2 $batch_size $num_batches $model $filename_prefix
            elif [ "$cuda_device" = "0,1,2,3" ]; then
                run $cuda_device 4 $batch_size $num_batches $model $filename_prefix
            elif [ "$cuda_device" = "0,1,2,3,4,5,6,7" ]; then
                run $cuda_device 8 $batch_size $num_batches $model $filename_prefix
            fi
        done
    done
done

