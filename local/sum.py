import sys
import math

def cpu_mem(in_p, out_p):
    cpu=[]
    mem=[]

    lines=in_p.readlines()
    for line in lines:
        tokens=line.split()
        cpu.append(float(tokens[1]))
#        mem.append(float(tokens[2]))

    #hack number
    start=int(len(cpu)*0.25)
    if len(cpu) < 20:
        end=len(cpu)-2
    elif len(cpu) < 50:
        end=len(cpu)-6
    else:
        end=int(len(cpu)*0.6)

    cpu=cpu[start:end]
#    mem=mem[start:end]

    out_p.write('cpu average usage: '+str(sum(cpu)/len(cpu))+'\n')
#    out_p.write('memory max usage: '+str(max(mem)*515880/102400)+'\n')

    return

def smi(in_p, out_p, device_num):
    gpu=[]
    rx_t=[]
    tx_t=[]
    tag=[]

    lines=in_p.readlines()
    for index, line in enumerate(lines):
        if "Bus Id" in line:
            continue    # Ignore GPU id.

        if "Used GPU Memory" in line:
            tag.append(index)
        else:
            tokens=line.split()
            if "Tx" in line:
                tx_t.append(float(tokens[3]))
            elif "Rx" in line:
                rx_t.append(float(tokens[3]))
            elif "Gpu" in line:
                gpu.append(float(tokens[2]))

    #hack_num
    start=int(tag[0]/4.0) + int(len(tag)*0.25)
    end=int(len(tag)*0.6) + start

    gpu=gpu[start:end]
    tx_t=tx_t[start:end]
    rx_t=rx_t[start:end]

    out_p.write("GPU average usage: "+str(sum(gpu)/len(gpu))+"\n")
    out_p.write("GPU average tx throughput: "+str(sum(tx_t)/len(tx_t)/1024)+"\n")
    out_p.write("GPU average rx throughput: "+str(sum(rx_t)/len(rx_t)/1024)+"\n")


#    s=int(math.ceil(tag[0]/device_num/4.0) + math.ceil(len(tag)/device_num*0.6))
 #   e=int(len(tag)/device_num*0.3)+s        
                    
    return #int(start/device_num)

def disk(in_p, out_p):
    d_read=[]
    d_write=[]
    d_util=[]

    lines=in_p.readlines()
    for line in lines:
        if 'sda' in line:
            tokens=line.split()
            d_read.append(float(tokens[5])/1024)
            d_write.append(float(tokens[6])/1024)
            d_util.append(float(tokens[13]))

    #Not work for I/O, due to prefetching?
    #hack number
    start=int(len(d_read)*0.6)
    end=int(len(d_read)*0.3)+start
    d_read=d_read[start:end]
    d_util=d_util[start:end]

    out_p.write("Disk average reading bandwidth: "+str(sum(d_read)/len(d_read))+"\n")
#    out_p.write("Disk average writing bandwidth: "+str(sum(d_write)/len(d_write))+"\n")
    out_p.write("Disk average utilization: "+str(sum(d_util)/len(d_util))+"\n")

    return

model=sys.argv[1]
batch_size=sys.argv[2]
cuda_devices=sys.argv[3]

dir_prefix="prof_data/"
prefix=dir_prefix+model+'_'+batch_size+'_'+cuda_devices+'_'
cpu_file=open(prefix+'cpu.txt', 'r')
smi_file=open(prefix+'smi.txt', 'r')
#io_file=open(prefix+'io.txt', 'r')

out_dir="log/"
out_filename=out_dir+model+'_result.txt'
out_p=open(out_filename, 'a')
out_p.write(model+'_'+batch_size+'_'+cuda_devices+'\n')


#filename=full_filename.split('/')[-1]
#tokens=filename.split('_')
#out_p.write(tokens[0]+'\t'+tokens[1]+'\t'+tokens[2]+'\n
device_num=len(cuda_devices.split(','))
start=smi(smi_file, out_p, device_num) 

cpu_mem(cpu_file, out_p)
#disk(io_file, out_p)

cpu_file.close()
smi_file.close()
#io_file.close()
out_p.close()
