#!/bin/bash

num_machines=2
machines=("10.0.0.24" "10.0.0.23")
batch_sizes="1024 2048 4096 6144"
# batch_sizes="2048"
# modes="sync async"
modes="async"
worker_port=30000
ps_port=29999

configs="1:1 2:2 3:3 4:4 1:3 2:4 1:5 2:6 1:7"
# configs="1:1"
prefix_dir="/home/fanyang/v-hazhao/GpuProfiling/measurement_tool/data/transformer/"
mkdir -p $prefix_dir

master_config=('{"environment": "cloud", "cluster": {"ps": ["10.0.0.24:29999", "10.0.0.23:29999"], "master": ["10.0.0.24:30000", "10.0.0.23:30000"]}, "task": {"index": 0, "type": "master"}}' '{"environment": "cloud", "cluster": {"ps": ["10.0.0.24:29999", "10.0.0.23:29999"], "master": ["10.0.0.24:30000", "10.0.0.23:30000"]}, "task": {"index": 1, "type": "master"}}')
master_flag=("--master=grpc://10.0.0.24:30000 --ps_replicas=2 --worker_replicas=2 --worker_id=0 --worker_job=/job:master --schedule=train" "--master=grpc://10.0.0.23:30000 --ps_replicas=2 --worker_replicas=2 --worker_id=1 --worker_job=/job:master --schedule=train")
ps_config=('{"environment": "cloud", "cluster": {"ps": ["10.0.0.24:29999", "10.0.0.23:29999"], "master": ["10.0.0.24:30000", "10.0.0.23:30000"]}, "task": {"index": 0, "type": "ps"}}' '{"environment": "cloud", "cluster": {"ps": ["10.0.0.24:29999", "10.0.0.23:29999"], "master": ["10.0.0.24:30000", "10.0.0.23:30000"]}, "task": {"index": 1, "type": "ps"}}')
ps_flag=('--master=grpc://10.0.0.24:29999 --schedule=run_std_server' '--master=grpc://10.0.0.23:29999 --schedule=run_std_server')

script="/home/fanyang/v-hazhao/tensorflow-1.4/bin/python -u /home/fanyang/v-hazhao/tensorflow-1.4/lib/python2.7/site-packages/tensor2tensor/bin/t2t_trainer.py --data_dir=data/ --problems=translate_ende_wmt32k --model=transformer --hparams_set=transformer_base --output_dir=translate_ende_wmt32k/transformer_base"

run(){
    index=$1
    conf=$2
    mode=$3
    batch_size=$4
    filename_prefix="transformer_batchpd_${batch_size}_conf_${conf}_${mode}"

    ((a=index+1))
    cvd_count=$(echo $conf | cut -d ":" -f $a)
    ((cvd_count--))
    cvd=$(seq -s , 0 $cvd_count)
    ((cvd_count++))
    hparam="--hparams=batch_size=$batch_size"

    rm -r translate_ende_wmt32k/transformer_base/*
    if [ $mode = "sync" ]; then
        TF_CONFIG=${ps_config[$index]} CUDA_VISIBLE_DEVICES=$cvd $script ${ps_flag[$index]} $hparam & 
        TF_CONFIG=${master_config[$index]} CUDA_VISIBLE_DEVICES="" $script ${master_flag[$index]} --ps_gpu=$cvd_count $hparam --sync --train_steps=801 > ${prefix_dir}${filename_prefix}_speed.txt & worker_pid=$!
    else
        TF_CONFIG=${ps_config[$index]} CUDA_VISIBLE_DEVICES="" $script ${ps_flag[$index]} $hparam & 
        TF_CONFIG=${master_config[$index]} CUDA_VISIBLE_DEVICES=$cvd $script ${master_flag[$index]} --worker_gpu=$cvd_count $hparam --train_steps=801 > ${prefix_dir}${filename_prefix}_speed.txt & worker_pid=$!
    fi
    ./monitor.sh $worker_pid $filename_prefix $cvd
}

if [ $1 == "--remote" ]; then
    run $2 $3 $4 $5
else
    for mode in $modes
    do
        for batch_size in $batch_sizes
        do
            for conf in $configs
            do
                echo "Starting configuration ${batch_size}_${conf}_${mode}..."
                # Starting servers and workers
                index_machine=1
                while [ $index_machine -ge 0 ]
                do
                    if [ $index_machine == 0 ]; then
                        # Starting processes locally
                        run $index_machine $conf $mode $batch_size
                    else
                        # Starting processes remotely
                        ssh fanyang@${machines[$index_machine]} "cd v-hazhao/transformer ; ./run_multi_machine.sh --remote ${index_machine} $conf $mode $batch_size" &
                    fi
                    ((index_machine--))
                done
                sleep 30
            done
        done
    done
fi
