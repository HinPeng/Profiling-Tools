prefix_dir="data/"
mkdir -p $prefix_dir

#work_dir="/home/fanyang/v-wencxi/"

#cuda_devices=${1}
#num_gpus=${2}
#batch_sizes=${3}
#model=${4}


cuda_devices="0 0,1 0,1,2,3 0,1,2,3,4,5,6,7"
#cuda_devices="0,1,2,3,4,5,6,7"
batch_sizes="8 16 32 64 128"
#batch_sizes='128'
models="vgg16 inception3 resnet50"
#models="alexnet"

test(){
    if [ -d "${work_dir}static_analysis/result/$5" ]; then
        return 0
    fi

    while :
    do
        killall -9 python
        ./single_run_dl.sh $1 $2 $3 $4 & pid="$(top -b -n 1 | grep -w "python" | grep -w "R\|S" | cut -d ' ' -f 1)"
        if [ "$pid" = '' ];then
            echo "Can not get the TF process pid, launch again!"
            continue
        else
            break
        fi
    done
    
    
    # mesurement content
    ./cpu_mem.sh ${pid} $5 &
    ./smi.sh ${pid} $5 $1 &
    ./io.sh $5 & io_pid=$!

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

#    for static analysis
#    mkdir -p ${work_dir}static_analysis/result/$5
#    mkdir -p ${work_dir}tf_exec_graph/$5
#    mv ${work_dir}static_analysis/result/*.txt ${work_dir}static_analysis/result/$5
#    mv ${work_dir}tf_exec_graph/*.txt ${work_dir}tf_exec_graph/$5
}


for model in $models
do
    for batch_size in $batch_sizes
    do
        for cuda_device in $cuda_devices
        do
            filename_prefix=$model"_"$batch_size"_"$cuda_device
            echo "$filename_prefix"

            #            echo -e "$model $batch_size $cuda_device\n" >>
            if [ "$cuda_device" = "0" ]; then
                test $cuda_device 1 $batch_size $model $filename_prefix
            elif [ "$cuda_device" = "0,1" ]; then
                test $cuda_device 2 $batch_size $model $filename_prefix
            elif [ "$cuda_device" = "0,1,2,3" ]; then
                test $cuda_device 4 $batch_size $model $filename_prefix
            elif [ "$cuda_device" = "0,1,2,3,4,5,6,7" ]; then
                test $cuda_device 8 $batch_size $model $filename_prefix
            fi
        done
    done
done






