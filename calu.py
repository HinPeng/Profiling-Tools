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
        tokens=line.split

    return

def smi(in_p, out_p, device_ids):
    device_id=device_ids.split(',')
    count=len(device_id)


    #for i in range(count)
    return

filename=sys.argv[1]
out_filename='profile_result.txt'

in_p=open(filename, 'r')
out_p=open(out_filename, 'a+')

tokens=filename.split('_')
out_p.write(tokens[0]+'\t'+tokens[1]+'\t'+tokens[2]+'\n')
if tokens[3] == 'cpu':
    cpu_mem(in_p, out_p)
elif tokens[3] == 'pcm':
    pcm(in_p, out_p)
elif tokens[3] =='smi':
    smi(in_p, out_p, tokens[2])

