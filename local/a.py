import sys
model=sys.argv[1]
batch_size=sys.argv[2]
cuda_devices=sys.argv[3]

dir_prefix="per_log_ps/"
prefix=dir_prefix+model+'_'+batch_size+'_'+cuda_devices
#title=model+'_'+batch_size+'_'+cuda_devices+'_'

perf_file=open(prefix+'.txt', 'r')
out_p=open('prof_sum.txt', 'a')
out_p.write(prefix+'\n')

lines=perf_file.readlines()
for line in lines:
    tokens=line.split(':')
    perf=float(tokens[1])
    perf=perf*int(cuda_devices)
    out_p.write(str(perf)+'\n')

perf_file.close()
out_p.close()



