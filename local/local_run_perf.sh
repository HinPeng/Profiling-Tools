CUDA_VISIBLE_DEVICES=$1  python ../tf_cnn_benchmarks.py --local_parameter_device=gpu --num_gpus=$2 --batch_size=$3 --num_batches=$4 --model=$5 --use_nccl=true --variable_update=replicated --data_dir=/home/fanyang/imagenet/raw-data/tmp --data_name=imagenet | grep "Avg images/sec" >>$6
