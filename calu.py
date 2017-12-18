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
    out_p.write('memory average usage:'+str(sum(mem)/len(mem))+'\n')

    return

def pcm(in_p, out_p):
    pcm_read=[]
    pcm_write=[]

    lines=in_p.readlines()
    for line in lines:
        tokens=line.split()

    return

def smi(in_p, out_p, device_ids):
    device_id=device_ids.split(',')
    count=len(device_id)

    gpu=[]
    mem=[]
    rx_t=[]
    tx_t=[]
    for i in range(count):
        gpu.append([])
        mem.append([])
        rx_t.append([])
        tx_t.append([])

    flag=-1
#    flag1=0
    lines=in_p.readlines()
    for line in lines:
        if "Bus Id" in line:
            flag=(flag+1)%count
            continue

        tokens=line.split()
        if "Tx" in line:
            tx_t[flag].append(float(tokens[3]))
        elif "Rx" in line:
            rx_t[flag].append(float(tokens[3]))
        elif "Gpu" in line:
            gpu[flag].append(float(tokens[2]))
        elif "Used GPU Memory" in line:
            mem[flag].append(float(tokens[4]))


    for i in range(count):
        out_p.write("GPU"+str(i)+" average usage: "+str(sum(gpu[i])/len(gpu[i]))+"\n")
        out_p.write("GPU"+str(i)+" memory max usage: "+str(max(mem[i]))+"\n")
        out_p.write("GPU"+str(i)+" average tx throughput: "+str(sum(tx_t[i])/len(tx_t[i]))+"\n")
        out_p.write("GPU"+str(i)+" average rx usage: "+str(sum(rx_t[i])/len(rx_t[i]))+"\n")
        
            
    return

filename=sys.argv[1]
out_filename='profile_result.txt'

in_p=open(filename, 'r')
out_p=open(out_filename, 'a+')

filename=filename[5:]
tokens=filename.split('_')
out_p.write(tokens[0]+'\t'+tokens[1]+'\t'+tokens[2]+'\n')

if tokens[3] == 'cpu':
    cpu_mem(in_p, out_p)
#elif tokens[3] == 'pcm':

elif tokens[3] == 'smi.txt':
    smi(in_p, out_p, tokens[2])


