log_dir="per_log/35/"
mkdir -p $log_dir
cuda_devices="0,1,2,3,4"
#cuda_devices="0"
models="vgg16 inception3 resnet50"
#models="vgg16"
batch_sizes="8 16 32 64"
num_batches="100"

run(){
    ./killport.sh
    echo 3 | sudo tee /proc/sys/vm/drop_caches
    ./dis_run_perf.sh $1 $2 $3 $4 $5 $6
}


for i in `seq 1 1`
do
    for model in $models
    do
	    for batch_size in $batch_sizes
	    do
	        for cuda_device in $cuda_devices
            do
		        prefix=$model"_"$batch_size"_"
		        if [ "$cuda_device" = "0" ]; then
                    filename_prefix=$log_dir$prefix"1.txt"
                    run $cuda_device 1 $batch_size $num_batches $model $filename_prefix
		        elif [ "$cuda_device" = "0,1" ]; then
                    filename_prefix=$log_dir$prefix"2.txt"
                    run $cuda_device 2 $batch_size $num_batches $model $filename_prefix
                elif [ "$cuda_device" = "0,1,2" ]; then
                    filename_prefix=$log_dir$prefix"3.txt"
                    run $cuda_device 3 $batch_size $num_batches $model $filename_prefix
		        elif [ "$cuda_device" = "0,1,2,3" ]; then
                    filename_prefix=$log_dir$prefix"4.txt"
                    run $cuda_device 4 $batch_size $num_batches $model $filename_prefix
                elif [ "$cuda_device" = "0,1,2,3,4" ]; then
                    filename_prefix=$log_dir$prefix"5.txt"
                    run $cuda_device 5 $batch_size $num_batches $model $filename_prefix
                elif [ "$cuda_device" = "0,1,2,3,4,5" ]; then
                    filename_prefix=$log_dir$prefix"6.txt"
                    run $cuda_device 6 $batch_size $num_batches $model $filename_prefix            
                elif [ "$cuda_device" = "0,1,2,3,4,5,6" ]; then
                    filename_prefix=$log_dir$prefix"7.txt"
                    run $cuda_device 7 $batch_size $num_batches $model $filename_prefix            
		        fi
            done
	    done
    done
done

models="alexnet"
batch_sizes="32 64 128 512"
for i in `seq 1 1`
do
    for model in $models
    do
	    for batch_size in $batch_sizes
	    do
	        for cuda_device in $cuda_devices
            do
		        prefix=$model"_"$batch_size"_"
		        if [ "$cuda_device" = "0" ]; then
                    filename_prefix=$log_dir$prefix"1.txt"
                    run $cuda_device 1 $batch_size $num_batches $model $filename_prefix
		        elif [ "$cuda_device" = "0,1" ]; then
                    filename_prefix=$log_dir$prefix"2.txt"
                    run $cuda_device 2 $batch_size $num_batches $model $filename_prefix
                elif [ "$cuda_device" = "0,1,2" ]; then
                    filename_prefix=$log_dir$prefix"3.txt"
                    run $cuda_device 3 $batch_size $num_batches $model $filename_prefix
		        elif [ "$cuda_device" = "0,1,2,3" ]; then
                    filename_prefix=$log_dir$prefix"4.txt"
                    run $cuda_device 4 $batch_size $num_batches $model $filename_prefix
                elif [ "$cuda_device" = "0,1,2,3,4" ]; then
                    filename_prefix=$log_dir$prefix"5.txt"
                    run $cuda_device 5 $batch_size $num_batches $model $filename_prefix
                elif [ "$cuda_device" = "0,1,2,3,4,5" ]; then
                    filename_prefix=$log_dir$prefix"6.txt"
                    run $cuda_device 6 $batch_size $num_batches $model $filename_prefix            
                elif [ "$cuda_device" = "0,1,2,3,4,5,6" ]; then
                    filename_prefix=$log_dir$prefix"7.txt"
                    run $cuda_device 7 $batch_size $num_batches $model $filename_prefix            		        
		        fi
            done
	    done
    done
done

