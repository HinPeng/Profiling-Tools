#!/bin/bash

num_machines=2
num_devices=4
machines=("10.0.0.24" "10.0.0.23")
batch_sizes="32 16 8"
configs="1:1 2:2 3:3 4:4 1:3 2:4 1:5 2:6 1:7"
# batch_sizes="32 16"
# configs="1:1"
worker_port=30000
ps_port=29999

prefix_dir="/home/fanyang/v-hazhao/GpuProfiling/measurement_tool/data/deepspeech/"
mkdir -p $prefix_dir
index_machine=1
while [ $index_machine -lt $num_machines ]
do
    ssh fanyang@${machines[${index_machine}]} "mkdir -p $prefix_dir"
    ((index_machine++))
done

script="/home/fanyang/v-hazhao/tensorflow-1.4/bin/python -u DeepSpeech.py --train_files training_data/cv-valid-train.csv --dev_files training_data/cv-valid-dev.csv --test_files training_data/cv-valid-test.csv --log_level 2 --limit_train_batch 50 --epoch 2"

# Generating host list
worker_hosts="${machines[0]}:${worker_port},${machines[1]}:${worker_port}"
ps_hosts="${machines[0]}:${ps_port},${machines[1]}:${ps_port}"
# index_machine=0
# while [ $index_machine -lt $num_machines ]
# do
#     worker_hosts[$index_machine]="${machines[${index_machine}]}:$worker_port"
#     ps_hosts[$index_machine]="${machines[${index_machine}]}:$ps_port"
#     ((index_machine++))
# done
# worker_hosts=$(printf ",%s" ${worker_hosts[@]})
# worker_hosts=${worker_hosts:1}
# ps_hosts=$(printf ",%s" ${ps_hosts[@]})
# ps_hosts=${ps_hosts:1}

# for batch_size in $batch_sizes
# do
# for conf in $configs
# do
#     echo "Starting configuration ${batch_size}_${conf}..."
#     # Starting servers and workers
#     index_machine=0
#     filename_prefix="deepspeech_batchpd_"$batch_size"_conf_"$conf"_shuffled"
#     while [ $index_machine -lt $num_machines ]
#     do
#         ((a=index_machine+1))
#         cvd_count=$(echo $conf | cut -d ":" -f $a)
#         ((cvd_count--))
#         cvd=$(seq -s , 0 $cvd_count)

#         if [ $index_machine == 0 ]; then
#             # starting processes locally
#             CUDA_VISIBLE_DEVICES="" $script --conf $conf --train_batch_size $batch_size --ps_hosts $ps_hosts --worker_hosts $worker_hosts --job_name=ps --task_index=$index_machine --coord_host 10.0.0.24 & ps_pid=$!
#             #2>&1 | sed 's/^/[ps     '"$index_machine"'] /' &
#             CUDA_VISIBLE_DEVICES=$cvd $script --conf $conf --train_batch_size $batch_size --ps_hosts $ps_hosts --worker_hosts $worker_hosts --job_name=worker --task_index=$index_machine --coord_host 10.0.0.24 --prefix ${filename_prefix} --cvd $cvd --ps_pid $ps_pid > ${prefix_dir}${filename_prefix}_speed.txt & worker_pid=$!
#             #2>&1 | sed 's/^/[worker '"$index_machine"'] /' &
            
#         else
#             # starting processes remotely
#             ssh fanyang@${machines[${index_machine}]} "cd v-hazhao/DeepSpeech/ ; CUDA_VISIBLE_DEVICES=\"\" $script --conf $conf --train_batch_size $batch_size --ps_hosts $ps_hosts --worker_hosts $worker_hosts --job_name=ps --task_index=$index_machine --coord_host 10.0.0.24 & "'ps_pid=$! '"; CUDA_VISIBLE_DEVICES=$cvd $script --conf $conf --train_batch_size $batch_size --ps_hosts $ps_hosts --worker_hosts $worker_hosts --job_name=worker --task_index=$index_machine --coord_host 10.0.0.24 --prefix ${filename_prefix} --cvd $cvd --ps_pid "'$ps_pid'" > ${prefix_dir}${filename_prefix}_speed.txt" &
#             # 2>&1 | sed 's/^/[ps     '"$index_machine"'] /' &" &
#             # ssh fanyang@${machines[${index_machine}]} "cd v-hazhao/DeepSpeech/ ; CUDA_VISIBLE_DEVICES=$cvd $script --ps_hosts $ps_hosts --worker_hosts $worker_hosts --job_name=worker --task_index=$index_machine --coord_host 10.150.144.105 --prefix ${filename_prefix} --cvd $cvd > ${prefix_dir}${filename_prefix}_speed.txt" &
#             # 2>&1 | sed 's/^/[worker '"$index_machine"'] /' &"
#         fi

#         ((index_machine++))
#     done

#     /home/fanyang/v-hazhao/GpuProfiling/measurement_tool/killer.sh $ps_pid & killer_pid=$!

#     # Monitor process status
#     while :
#     do
#         if ps -p $ps_pid > /dev/null
#         then
#             sleep 10
#         else
#             kill -KILL $worker_pid
#             index_machine=1
#             while [ $index_machine -lt $num_machines ]
#             do
#                 ssh fanyang@${machines[${index_machine}]} 'worker_pid=$(ps -ef | grep job_name=worker | grep -v grep | awk '"'{print "'$2'"}'"') ; kill -KILL $worker_pid'
#                 ssh fanyang@${machines[${index_machine}]} 'ps_pid=$(ps -ef | grep job_name=ps | grep -v grep | awk '"'{print "'$2'"}'"') ; kill -KILL $ps_pid'
#                 ((index_machine++))
#             done
#             break
#         fi
#     done
#     kill $killer_pid

#     echo "Configuration ${batch_size}_$conf done."
#     sleep 60
# done
# done

# Starting single-machine tests
# echo "Starting single-machine tests..."
# num_gpus=("2" "4" "8")
# batch_sizes=("64" "16" "64")
# index=0
# while [ $index -lt 3 ]
# do
#     batch_size=${batch_sizes[$index]}
#     num=${num_gpus[$index]}
#     echo "Starting configuration ${batch_size}_${num}..."
#     filename_prefix="deepspeech_batchpd_"$batch_size"_conf_"$num
#     cvd_count=$num
#     ((cvd_count--))
#     cvd=$(seq -s , 0 $cvd_count)
#     CUDA_VISIBLE_DEVICES=$cvd $script --train_batch_size $batch_size --prefix ${filename_prefix} --cvd $cvd > ${prefix_dir}${filename_prefix}_speed.txt #& worker_pid=$!
#     pid=$!
#     kill -KILL $pid
#     echo "Configuration ${batch_size}_${num} done."
#     sleep 60
#     ((index++))
# done

num_gpus="5"
# batch_sizes="8 16 32"
batch_sizes="32"
for num in $num_gpus
do
    for batch_size in $batch_sizes
    do
        echo "Starting configuration ${batch_size}_${num}..."
        filename_prefix="deepspeech_batchpd_"$batch_size"_conf_"$num":0_shuffled"
        cvd_count=$num
        ((cvd_count--))
        cvd=$(seq -s , 0 $cvd_count)
        CUDA_VISIBLE_DEVICES=$cvd $script --train_batch_size $batch_size --prefix ${filename_prefix} --cvd $cvd > ${prefix_dir}${filename_prefix}_speed.txt #& worker_pid=$!
        worker_pid=$!
        echo "$worker_pid"
        kill -9 ${worker_pid}
        echo "Configuration ${batch_size}_${num} done."
    done
done

# If we are forced to quit, we kill all ramining jobs/servers
function quit {
  echo
  echo "Killing whole process group - the hard way..."
  kill -KILL -$$
}
trap quit SIGINT SIGTERM