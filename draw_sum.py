#!/usr/bin/env python3
import matplotlib
matplotlib.use('Agg')
import sys
import matplotlib.pyplot as plt

FREQ=1
def plotting_network(tx, rx, title, option):
    '''
    Plot the data points using pyplot.
    '''
    if option == 0:
        data_x = list(map(lambda x: x * FREQ, range(len(tx))))
        plt.plot(data_x, tx, color='r', linewidth=0.5, label='TX')
        plt.plot(data_x, rx, color='b', linewidth=0.5, label='RX')
        plt.title(title)
        plt.xlabel('Time / s')
        plt.ylabel('Traffic (MB / s)')
        plt.legend(loc='best')
        plt.savefig('profiling_results/%s.pdf' % title, format='pdf')
        plt.clf()
    else:
        title+='CDF'
        tx.sort()
        rx.sort()
        count=len(tx)
        data_y=list(map(lambda x: x/count, range(len(tx))))
        plt.plot(tx, data_y, color='r', linewidth=2.0, label='TX')
        data_y=list(map(lambda x: x/count, range(len(rx))))
        plt.plot(rx, data_y, color='b', linewidth=2.0, label='RX')
        plt.title(title)
        plt.xlabel('Traffic (MB / s)')
        plt.legend(loc='best')
        plt.savefig('profiling_results/%s.pdf' % title, format='pdf')
        plt.clf()

    return

def plotting_cpu(cpu, title, option):
    '''
    Plot the data points using pyplot.
    '''
    if option == 0:        
        data_x = list(map(lambda x: x * FREQ, range(len(cpu))))
        plt.plot(data_x, cpu, color='r', linewidth=0.5, label='CPU')
        plt.title(title)
        plt.xlabel('Time / s')
        plt.ylabel('CPU usage')
        plt.legend(loc='best')
        plt.savefig('profiling_results/%s.pdf' % title, format='pdf')
        plt.clf()
    else:
        title+='CDF'
        cpu.sort()
        count=len(cpu)
        data_y=list(map(lambda x: x/count, range(len(cpu))))
        plt.plot(cpu, data_y, color='r', linewidth=2.0, label='CPU')
        plt.title(title)
        plt.xlabel('CPU usage')
        plt.legend(loc='best')
        plt.savefig('profiling_results/%s.pdf' % title, format='pdf')
        plt.clf()

    return

def plotting_gpu(gpu, title, option):
    '''
    Plot the data points using pyplot.
    '''
    if option == 0:        
        data_x = list(map(lambda x: x * FREQ, range(len(gpu))))
        plt.plot(data_x, gpu, color='r', linewidth=0.5, label='GPU')
        plt.title(title)
        plt.xlabel('Time / s')
        plt.ylabel('GPU usage')
        plt.legend(loc='best')
        plt.savefig('profiling_results/%s.pdf' % title, format='pdf')
        plt.clf()
    else:
        title+='CDF'
        gpu.sort()
        count=len(gpu)
        data_y=list(map(lambda x: x/count, range(len(gpu))))
        plt.plot(gpu, data_y, color='r', linewidth=2.0, label='GPU')
        plt.title(title)
        plt.xlabel('GPU usage')
        plt.legend(loc='best')
        plt.savefig('profiling_results/%s.pdf' % title, format='pdf')
        plt.clf()

    return

def plotting_smi(tx, rx, title, option):
    '''
    Plot the data points using pyplot.
    '''
    if option == 0:
        data_x = list(map(lambda x: x * FREQ, range(len(tx))))
        plt.plot(data_x, tx, color='r', linewidth=0.5, label='TX')
        plt.plot(data_x, rx, color='b', linewidth=0.5, label='RX')
        plt.title(title)
        plt.xlabel('Time / s')
        plt.ylabel('Traffic (MB / s)')
        plt.legend(loc='best')
        plt.savefig('profiling_results/%s.pdf' % title, format='pdf')
        plt.clf()
    else:
        title+='CDF'
        tx.sort()
        rx.sort()
        count=len(tx)
        data_y=list(map(lambda x: x/count, range(len(tx))))
        plt.plot(tx, data_y, color='r', linewidth=2.0, label='TX')
        data_y=list(map(lambda x: x/count, range(len(rx))))
        plt.plot(rx, data_y, color='b', linewidth=2.0, label='RX')
        plt.title(title)
        plt.xlabel('Traffic (MB / s)')
        plt.legend(loc='best')
        plt.savefig('profiling_results/%s.pdf' % title, format='pdf')
        plt.clf()

    return


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

    title+='nic'
#    plotting_network(nic_tx, nic_rx, title, 1)
    
    #hack_num
    start=int(len(nic_tx)*0.25)
    end=int(len(nic_tx)*0.6) + start

    nic_tx=nic_tx[start:end]
    nic_rx=nic_rx[start:end]
    
    sum_file.write(title)
    #sum_file.write("max tx: %s, max rx: %s" % (max(nic_tx),max(nic_rx)) + '\n')
    sum_file.write("NIC Avg tx: %s, Avg rx: %s" % (sum(nic_tx)/len(nic_tx),sum(nic_rx)/len(nic_rx)) + '\n')
    
    return

def ps_cpu(in_p, sum_file,  title):
    cpu=[]
   # mem=[]

    lines=in_p.readlines()
    for line in lines:
        tokens=line.split()
        cpu.append(float(tokens[1]))
  #      mem.append(float(tokens[2]))

 #   out_p.write('cpu average usage: '+str(sum(cpu)/len(cpu))+'\n')
#    out_p.write('memory max usage: '+str(max(mem)*515880/102400)+'\n')

    title+='ps_cpu'
    plotting_cpu(cpu, title, 1)
    return

def wr_cpu(in_p, sum_file, title):
    cpu=[]
   # mem=[]

    lines=in_p.readlines()
    for line in lines:
        tokens=line.split()
        if tokens[1].isalpha():
            cpu.append(float(tokens[2]))
        else:
            cpu.append(float(tokens[1]))
            #      mem.append(float(tokens[2]))

 #   out_p.write('cpu average usage: '+str(sum(cpu)/len(cpu))+'\n')
#    out_p.write('memory max usage: '+str(max(mem)*515880/102400)+'\n')

    title+='wr_cpu'
#    plotting_cpu(cpu, title, 1)

    #hack number
    start=int(len(cpu)*0.25)
    if len(cpu) < 20:
        end=len(cpu)-2
    elif len(cpu) < 50:
        end=len(cpu)-6
    else:
        end=int(len(cpu)*0.6)

    cpu=cpu[start:end]

    sum_file.write(title)
    sum_file.write("Avg cpu: %s" % (sum(cpu)/len(cpu)) + '\n')

    return

def smi(in_p, sum_file, title):
    gpu=[]
    rx_t=[]
    tx_t=[]
    tag=[]

#    flag1=0
    lines=in_p.readlines()
    for index, line in enumerate(lines):
        if "Bus Id" in line:
            continue

        if "Used GPU Memory" in line:
            tag.append(index)
        else:
            tokens=line.split()
#            if "Tx" in line:
#                tx_t.append(float(tokens[3])/1024)
#            elif "Rx" in line:
#                rx_t.append(float(tokens[3])/1024)
            if "Gpu" in line:
                gpu.append(float(tokens[2]))

    title+='smi'
#    plotting_gpu(gpu, title, 0)

    #hack_num
    start=int(tag[0]/4.0) + int(len(tag)*0.25)
    end=int(len(tag)*0.6) + start

    gpu=gpu[start:end]
#    tx_t=tx_t[start:end]
#    rx_t=rx_t[start:end]

    sum_file.write("GPU average usage: "+str(sum(gpu)/len(gpu))+"\n")
#    sum_file.write("GPU average tx throughput: "+str(sum(tx_t)/len(tx_t))+"\n")
#    sum_file.write("GPU average rx throughput: "+str(sum(rx_t)/len(rx_t))+"\n")
            
    return

def disk(in_p, sum_file, title):
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

    #hack_num
    start=int(len(d_read)*0.25)
    end=int(len(d_read)*0.6) + start

    d_read=d_read[start:end]
    d_write=d_write[start:end]
    d_util=d_util[start:end]

    sum_file.write("Disk average reading bandwidth: "+str(sum(d_read)/len(d_read))+"\n")
#    out_p.write("Disk average writing bandwidth: "+str(sum(d_write)/len(d_write))+"\n")
    sum_file.write("Disk average utilization: "+str(sum(d_util)/len(d_util))+"\n")

    return


model=sys.argv[1]
batch_size=sys.argv[2]
cuda_devices=sys.argv[3]

dir_prefix="prof_log_2_23_qsmi/"
prefix=dir_prefix+model+'_'+batch_size+'_'+cuda_devices+'_'
title=model+'_'+batch_size+'_'+cuda_devices+'_'

ps_cpu_file=open(prefix+'cpu.txt')
smi_file=open(prefix+'smi.txt', 'r')
nic_file=open(prefix+'nic.txt', 'r')
#io_file=open(prefix+'io.txt', 'r')
sum_file=open("profile_summary_23.txt", 'a')

#filename=full_filename.split('/')[-1]
#tokens=filename.split('_')

wr_cpu(ps_cpu_file, sum_file, title)
smi(smi_file, sum_file, title)
#disk(io_file, sum_file, title)
nic(nic_file, sum_file, title)

ps_cpu_file.close()
smi_file.close()
nic_file.close()
#io_file.close()
sum_file.close()
#gpu_p.close()

