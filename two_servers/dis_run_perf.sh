CUDA_VISIBLE_DEVICES="" python ../tf_cnn_benchmarks.py --local_parameter_device='cpu' --job_name="ps" --batch_size=$3 --worker_hosts="10.0.0.23:43222,10.0.0.24:43223" --ps_hosts="10.0.0.23:42222,10.0.0.24:42223" --model=$5 --variable_update="distributed_replicated" --task_index=1 &
CUDA_VISIBLE_DEVICES=$1 python ../tf_cnn_benchmarks.py  --num_gpus=$2 --job_name="worker" --worker_hosts="10.0.0.23:43222,10.0.0.24:43223" --ps_hosts="10.0.0.23:42222,10.0.0.24:42223" --batch_size=$3 --num_batches=$4 --model=$5 --use_nccl='True' --variable_update="distributed_replicated" --task_index=1 --data_dir='/home/fanyang/v-wencxi/ImageNet/raw-data/tmp/' --data_name=imagenet | grep 'Avg images/sec' >> $6
