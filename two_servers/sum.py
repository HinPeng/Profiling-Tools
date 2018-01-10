import sys

def cpu_mem(in_p, out_p):
    cpu=[]
    mem=[]

    lines=in_p.readlines()
    for line in lines:
        tokens=line.split()
        cpu.append(float(tokens[1]))
        mem.append(float(tokens[2]))

    out_p.write('cpu average usage: '+str(sum(cpu)/len(cpu))+'\n')
    out_p.write('memory max usage: '+str(max(mem)*515880/102400)+'\n')

    return

def smi(in_p, out_p):


    gpu=[]
    rx_t=[]
    tx_t=[]

#    flag1=0
    lines=in_p.readlines()
    for line in lines:
        if "Bus Id" in line:
            continue

        tokens=line.split()
        if "Tx" in line:
            tx_t.append(float(tokens[3]))
        elif "Rx" in line:
            rx_t.append(float(tokens[3]))
        elif "Gpu" in line:
            gpu.append(float(tokens[2]))


    start=int(0.1*len(gpu))
    gpu=gpu[start:]
    tx_t=tx_t[start:]
    rx_t=rx_t[start:]

    out_p.write("GPU average usage: "+str(sum(gpu)/len(gpu))+"\n")
    out_p.write("GPU average tx throughput: "+str(sum(tx_t)/len(tx_t)/1024)+"\n")
    out_p.write("GPU average rx throughput: "+str(sum(rx_t)/len(rx_t)/1024)+"\n")
        
            
    return

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

    out_p.write("Disk average reading bandwidth: "+str(sum(d_read)/len(d_read))+"\n")
#    out_p.write("Disk average writing bandwidth: "+str(sum(d_write)/len(d_write))+"\n")
    out_p.write("Disk average utilization: "+str(sum(d_util)/len(d_util))+"\n")

    return

full_filename=sys.argv[1]
out_filename='sum_result.txt'

in_p=open(full_filename, 'r')
out_p=open(out_filename, 'a+')

filename=full_filename.split('/')[-1]
tokens=filename.split('_')
out_p.write(tokens[0]+'\t'+tokens[1]+'\t'+tokens[2]+'\n')

#elif tokens[3] == 'pcm':

if tokens[3] == 'cpu':
    cpu_mem(in_p, out_p)
elif tokens[3] == 'smi.txt':
    smi(in_p, out_p)
elif tokens[3] == 'io.txt':
    disk(in_p, out_p)
