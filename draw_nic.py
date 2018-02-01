#!/usr/bin/env python3
import matplotlib
matplotlib.use('Agg')
import sys
import matplotlib.pyplot as plt

FREQ=1
def plotting_network(tx, rx, title):
    '''
    Plot the data points using pyplot.
    '''
    data_x = list(map(lambda x: x * FREQ, range(len(tx))))

    plt.plot(data_x, tx, color='r', linewidth=0.5, label='TX')
    plt.plot(data_x, rx, color='b', linewidth=0.5, label='RX')
    plt.title(title)
    plt.xlabel('Time / s')
    plt.ylabel('Traffic (MB / s)')
    plt.legend(loc='best')

    plt.savefig('profiling_results/%s.pdf' % title, format='pdf')
    plt.clf()

def plotting_network_CDF(tx, rx, title):
    '''
    Plot the data points using pyplot.
    '''
#    data_x = list(map(lambda x: x * FREQ, range(len(tx))))

    tx.sort()
    rx.sort()
    count=len(tx)

    data_y=list(map(lambda x: x/count, range(len(tx))))

    plt.plot(tx, data_y, color='r', linewidth=2.0, label='TX')
    plt.plot(rx, data_y, color='b', linewidth=2.0, label='RX')
#    plt.plot(data_x, tx, color='r', linewidth=0.5, label='TX')
 #   plt.plot(data_x, rx, color='b', linewidth=0.5, label='RX')
    plt.title(title)
    plt.xlabel('Time / s')
    plt.ylabel('Traffic (MB / s)')
    plt.legend(loc='best')

    plt.savefig('profiling_results/%s.pdf' % title, format='pdf')
    plt.clf()

def nic(in_p, sum_file, title):
    nic_rx=[]
    nic_tx=[]

    lines=in_p.readlines()
    for line in lines:
        tokens=line.split()
        nic_tx.append(float(tokens[2])/1024)
        nic_rx.append(float(tokens[5])/1024)
#        tx_p.write(tokens[2]+'\n')
#        rx_p.write(tokens[5]+'\n')

  #  plotting_network(nic_tx, nic_rx, "nic")

    title+='nic'
#    plotting_network_CDF(nic_tx, nic_rx, title)
    sum_file.write(title)
    #sum_file.write("max tx: %s, max rx: %s" % (max(nic_tx),max(nic_rx)) + '\n')
    sum_file.write("avg tx: %s, avg rx: %s" % (max(nic_tx)/len(nic_tx),max(nic_rx)/len(nic_rx)) + '\n')
    return

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

def smi(in_p, rx_p, tx_p, gpu_p):


#    gpu=[]
 #   rx_t=[]
  #  tx_t=[]

#    flag1=0
    lines=in_p.readlines()
    for line in lines:
        if "Bus Id" in line:
            continue

        tokens=line.split()
        if "Tx" in line:
#            tx_t.append(float(tokens[3]))
            tx_p.write(tokens[3]+'\n')
        elif "Rx" in line:
            rx_p.write(tokens[3]+'\n')
#            rx_t.append(float(tokens[3]))
        elif "Gpu" in line:
            gpu_p.write(tokens[2]+'\n')
#            gpu.append(float(tokens[2]))


    #start=int(0.1*len(gpu))
    #gpu=gpu[start:]
    #tx_t=tx_t[start:]
    #rx_t=rx_t[start:]

    #out_p.write("GPU average usage: "+str(sum(gpu)/len(gpu))+"\n")
    #out_p.write("GPU average tx throughput: "+str(sum(tx_t)/len(tx_t)/1024)+"\n")
    #out_p.write("GPU average rx throughput: "+str(sum(rx_t)/len(rx_t)/1024)+"\n")
        
            
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

model=sys.argv[1]
batch_size=sys.argv[2]
cuda_devices=sys.argv[3]

dir_prefix="24_prof_data/"
prefix=dir_prefix+model+'_'+batch_size+'_'+cuda_devices+'_'
title=model+'_'+batch_size+'_'+cuda_devices+'_'
nic_file=open(prefix+'nic.txt', 'r')
sum_file=open("profile_summary.txt", 'a')
#smi_file=open(prefix+'smi.txt', 'r')
#io_file=open(prefix+'io.txt', 'r')

#out_dir="./"
#rx_f=out_dir+model+'_'+batch_size+'_'+cuda_devices+'_nicrx.txt'
#tx_f=out_dir+model+'_'+batch_size+'_'+cuda_devices+'_nictx.txt'
#rx_p=open(rx_f, 'w')
#tx_p=open(tx_f, 'w')
#out_p.write(model+'_'+batch_size+'_'+cuda_devices+'\n')


#filename=full_filename.split('/')[-1]
#tokens=filename.split('_')
#out_p.write(tokens[0]+'\t'+tokens[1]+'\t'+tokens[2]+'\n
#device_num=len(cuda_devices.split(','))
#tu=smi(smi_file, out_p, device_num) 
#smi(cpu_file, rx_p, tx_p, gpu_p)
nic(nic_file, sum_file, title)

nic_file.close()
sum_file.close()
#gpu_p.close()

