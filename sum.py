'''
file_name='profile_result.txt'

in_p=open(file_name,'r')
lines=in_p.readlines()
out_p=open('sum.txt', 'a+')

gpu=[]
rx=[]
tx=[]

rec=''
for line in lines:
	if 'alexnet' in line or 'vgg16' in line or 'inception3' in line or 'resnet50' in line:
		if rec==line:
			continue
		else:
			if rec=='':
				out_p.write(rec+'\n')
			else:
				out_p.write('gpu average usage: '+str(sum(gpu)/len(gpu))+'\n')
				out_p.write('rx average: '+str(sum(rx)/len(rx))+'\n')
				out_p.write('tx average: '+str(sum(tx)/len(rx))+'\n')
			continue

	if 'cpu average usage' in line:
		tokens=line.split(':')

'''


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
    out_p.write('memory max usage:'+str(max(mem)*515880/102400)+'\n')

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



    out_p.write("GPU average usage: "+str(sum(gpu)/len(gpu))+"\n")
    out_p.write("GPU average tx throughput: "+str(sum(tx_t)/len(tx_t)/1024)+"\n")
    out_p.write("GPU average rx usage: "+str(sum(rx_t)/len(rx_t)/1024)+"\n")
        
            
    return

filename=sys.argv[1]
out_filename='sum_result.txt'

in_p=open(filename, 'r')
out_p=open(out_filename, 'a+')

filename=filename[5:]
tokens=filename.split('_')
out_p.write(tokens[0]+'\t'+tokens[1]+'\t'+tokens[2]+'\n')

#elif tokens[3] == 'pcm':

if tokens[3] == 'cpu':
    cpu_mem(in_p, out_p)
#elif tokens[3] == 'pcm':
elif tokens[3] == 'smi.txt':
    smi(in_p, out_p)
