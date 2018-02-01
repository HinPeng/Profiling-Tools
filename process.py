#!/usr/bin/env python3
'''
Processing and visualizing the profiling data.
'''

import sys
from functools import reduce
import matplotlib.pyplot as plt

# Defining constants
MACHINES = ['24', '19']
# BATCHES = ['8', '16', '32', '64', '128']
BATCHES = ['1024', '2048', '4096', '8192']
# CONFS = [
#     '2:0', '1:1', '4:0',
#     '2:2', '3:1', '8:0',
#     '4:4', '6:2'
# ]
NUMBATCH = 200
CONFS = ['2:0', '4:0', '8:0', '3:0', '5:0', '6:0', '7:0']
# CONFS = ['3:0', '5:0', '6:0', '7:0']
#devices = ['0,no-ps', '0,1', '0,1,2,3', '0,1,2,3,4,5,6,7']
SUFFIXES = ['speed', 'cpu_mem', 'smi', 'network', 'ps']
MODEL = 'transformer'
FREQ = 0.1

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

    plt.savefig('profiling_results/figs/%s.pdf' % title, format='pdf')
    plt.clf()

def plotting(data_y, title, label_y):
    '''
    Plot the data points using pyplot.
    '''
    data_x = range(len(data_y))

    plt.plot(data_x, data_y, color='r', linewidth=0.5)
    plt.title(title)
    if label_y == 'Speed':
        plt.xlabel('Batch')
    else:
        plt.xlabel('Time / s')
    unit = '%'
    if label_y == 'Speed':
        unit = 'sec/batch'
    elif label_y == 'GMEM':
        unit = 'MB'
    elif label_y == 'H2D' or label_y == 'D2H':
        unit = 'MB/s'
    plt.ylabel('%s (%s)' % (label_y, unit))
    plt.savefig('profiling_results/figs/%s.pdf' % title, format='pdf')
    plt.clf()

def speed():
    with open('profiling_results/result_%s_speed.csv' % MODEL, 'w') as fout:
    # with open('profiling_results/result_%s_shuffled_speed.csv' % MODEL, 'w') as fout:
        fout.write('Setting, Speed_0, Speed_1, Speed_total\n')
        for batch in BATCHES:
            for conf in CONFS:
                setting = '%s_batchpd_%s_conf_%s' % (MODEL, batch, conf)
                # setting = '%s_numbatch_%s_batchpd_%s_conf_%s_shuffled' % (MODEL, NUMBATCH, batch, conf)
                fout.write(setting)
                results = _speed('%s_speed.txt' % setting)
                for result in results:
                    fout.write(', %s' % result)
                fout.write('\n')

def _speed(fname_in):
    data = []
    returns = []
    starts = []
    ends = []
    # conf = fname_in.split('_')[6].split(':')
    conf = fname_in.split('_')[4].split(':')
    batch_size = int(fname_in.split('_')[2])
    for i, c in enumerate(conf):
        if not c == '0':
            with open('data/%s_%s/%s' % (MODEL, MACHINES[i], fname_in), 'r') as fin:
                data = fin.readlines()
            time = float(data[1].split(' ')[6].strip('('))
            returns.append(batch_size * int(c) * 100 / time)
    #             _data = list(map(
    #                 lambda x: float(x.split(' ')[-1]),
    #                 fin.readlines()[1:]
    #             ))
    #             data.append(_data)
    #         time_per_batch = [(data[i][j+1] - data[i][j]) for j in range(len(_data)-1)]
    #         plot_title = '%s_%s' % (fname_in.split('.')[0], MACHINES[i])
    #         plotting(time_per_batch, plot_title, 'Speed')

    #         start, end = data[i][0], data[i][-1]
    #         starts.append(start)
    #         ends.append(end)
    #         returns.append(batch_size * int(c) * (len(data[i]) - 1) / (end - start))
        else:
            returns.append('N/A')
    returns.append(returns[0])
    return returns
    # total = [(int(conf[i]) * (len(data[i]) - 1)) for i in range(len(data))]
    # min_start = min(starts)
    # max_end = max(ends)
    # returns.append(batch_size * sum(total) / (max_end - min_start))
    # return returns

    # with open(fname_in, 'r') as fin:
    #     data = list(map(float, fin.readlines()[1:-1]))

    # plot_title = str(reduce(
    #     lambda x, y: '%s_%s' % (x, y),
    #     fname_in.split('/')[-1].split('_')[:5]
    # ))

    # plotting(data, '%s_Speed' % plot_title)

    # data = data[100:-1]
    # batch_size = int(fname_in.split('_')[2])
    # speed_avg = batch_size * len(data) / sum(data)
    # return (speed_avg,)

def cpu_mem():
    # with open('profiling_results/result_%s_shuffled_cpu_mem.csv' % MODEL, 'w') as fout:
    with open('profiling_results/result_%s_cpu_mem.csv' % MODEL, 'w') as fout:
        fout.write('Setting, CPU_AVG_0, CPU_MAX_0, MEM_AVG_0, MEM_MAX_0, CPU_AVG_1, CPU_MAX_1, MEM_AVG_1, MEM_MAX_1\n')
        for batch in BATCHES:
            for conf in CONFS:
                # setting = '%s_numbatch_%s_batchpd_%s_conf_%s_shuffled' % (MODEL, NUMBATCH, batch, conf)
                setting = '%s_batchpd_%s_conf_%s' % (MODEL, batch, conf)
                fout.write(setting)
                results = _cpu_mem('%s_cpu_mem.txt' % setting)
                for result in results:
                    fout.write(', %s' % result)
                fout.write('\n')

def _cpu_mem(fname_in):
    returns = []
    conf = fname_in.split('_')[4].split(':')
    for i, c in enumerate(conf):
        if not c == '0':
            with open('data/%s_%s/%s' % (MODEL, MACHINES[i], fname_in), 'r') as fin:
                data = fin.readlines()
                if not len(data[0].strip().split()) == 13:
                    print('data/%s_%s/%s' % (MODEL, MACHINES[i], fname_in))
                    sys.exit(1)
            cpu = []
            mem = []
            for line in data:
                tokens = line.split()
                cpu.append(float(tokens[9]))
                mem.append(float(tokens[10]))
            plot_title = '%s_%s' % (fname_in.split('.')[0], MACHINES[i])

            plotting(cpu, '%s_CPU' % plot_title, 'CPU')
            plotting(mem, '%s_MEM' % plot_title, 'MEM')
            returns.append(sum(cpu) / len(cpu))
            returns.append(max(cpu))
            returns.append(sum(mem) / len(mem))
            returns.append(max(mem))
        else:
            returns.append('N/A, N/A, N/A, N/A')
    return returns

def _smi(fname_in):
    returns = []
    conf = fname_in.split('_')[4].split(':')
    for i, c in enumerate(conf):
        if not c == '0':
            data = []
            gpu_total = []
            gpu_to_cpu_total = []
            cpu_to_gpu_total = []
            num = int(c)
            plot_title = '%s_%s' % (fname_in.split('.')[0], MACHINES[i])
            with open('data/%s_%s/%s' % (MODEL, MACHINES[i], fname_in), 'r') as fin:
                data = fin.readlines()
                data = data[:int(0.95*len(data))]
            for j in range(len(data)//(num*5)):
                gpu = [data[(j*num+k)*5+3].strip() for k in range(num)]
                try:
                    gpu = list(map(lambda x: int(x.split(' ')[2]), gpu))
                except ValueError as ve:
                    print('%s/%s' % (MACHINES[i], fname_in))
                gpu_total.append(sum(gpu))

                gpu_to_cpu = [data[(j*num+k)*5+1].strip() for k in range(num)]
                gpu_to_cpu = list(map(lambda x: int(x.split(' ')[3])/1024, gpu_to_cpu))
                gpu_to_cpu_total.append(sum(gpu_to_cpu))

                cpu_to_gpu = [data[(j*num+k)*5+2].strip() for k in range(num)]
                cpu_to_gpu = list(map(lambda x: int(x.split(' ')[3])/1024, cpu_to_gpu))
                cpu_to_gpu_total.append(sum(cpu_to_gpu))

            plotting(gpu_total, '%s_GPU' % plot_title, 'GPU')
            plotting(gpu_to_cpu_total, '%s_D2H' % plot_title, 'D2H')
            plotting(cpu_to_gpu_total, '%s_H2D' % plot_title, 'H2D')

    #     for j in range(num):
    #         gpu = [data[k*num*5+3].strip() for k in range(len(data)//(num*5))]
    #         gpu = list(map(lambda x: int(x.split(' ')[2]), gpu))
    #         gpu_total.append(gpu)

    #         gpu_to_cpu = [data[k*num*5+1].strip() for k in range(len(data)//(num*5))]
    #         gpu_to_cpu = list(map(lambda x: int(x.split(' ')[3])/1024, gpu_to_cpu))
    #         gpu_to_cpu_total.append(gpu_to_cpu)

    #         cpu_to_gpu = [data[k*num*5+2].strip() for k in range(len(data)//(num*5))]
    #         cpu_to_gpu = list(map(lambda x: int(x.split(' ')[3])/1024, cpu_to_gpu))
    #         cpu_to_gpu_total.append(cpu_to_gpu)
    #     gpu_time = [sum() for j in range()]
        
    # data = []

    # with open(fname_in, 'r') as fin:
    #     data = fin.readlines()
    
    # plot_title = str(reduce(
    #     lambda x, y: '%s_%s' % (x, y),
    #     fname_in.split('/')[-1].split('_')[:5]
    # ))

    # gpu = [data[i*5+3].strip() for i in range(len(data)//5)]
    # gpu = list(map(lambda x: int(x.split(' ')[2]), gpu))
    # plotting(gpu, '%s_GPU' % plot_title)

    # gmem = [data[i*5+4].strip() for i in range(len(data)//5)]
    # gmem = list(map(lambda x: int(x.split(' ')[4]), gmem))
    # plotting(gmem, '%s_GMEM' % plot_title)

    # gpu_to_cpu = [data[i*5+1].strip() for i in range(len(data)//5)]
    # gpu_to_cpu = list(map(lambda x: int(x.split(' ')[3])/1024, gpu_to_cpu))
    # plotting(gpu_to_cpu, '%s_D2H' % plot_title)

    # cpu_to_gpu = [data[i*5+2].strip() for i in range(len(data)//5)]
    # cpu_to_gpu = list(map(lambda x: int(x.split(' ')[3])/1024, cpu_to_gpu))
    # plotting(cpu_to_gpu, '%s_H2D' % plot_title)

            returns.append(sum(gpu_total) / len(gpu_total))
            returns.append(max(gpu_total))
            returns.append(sum(gpu_to_cpu_total) / len(gpu_to_cpu_total))
            returns.append(max(gpu_to_cpu_total))
            returns.append(sum(cpu_to_gpu_total) / len(cpu_to_gpu_total))
            returns.append(max(cpu_to_gpu_total))
        else:
            returns.append('N/A, N/A, N/A, N/A, N/A, N/A')

    # return gpu_avg, gpu_max, gmem_avg, gpu_to_cpu_avg, gpu_to_cpu_max, cpu_to_gpu_avg, cpu_to_gpu_max
    return returns

def smi():
    # with open('profiling_results/result_%s_shuffled_smi.csv' % MODEL, 'w') as fout:
    with open('profiling_results/result_%s_smi.csv' % MODEL, 'w') as fout:
        fout.write('Setting, GPU_AVG_0, GPU_MAX_0, D2H_AVG_0, D2H_MAX_0, H2D_AVG_0, H2D_MAX_0, GPU_AVG_1, GPU_MAX_1, D2H_AVG_1, D2H_MAX_1, H2D_AVG_1, H2D_MAX_1\n')
        for batch in BATCHES:
            for conf in CONFS:
                # setting = '%s_numbatch_%s_batchpd_%s_conf_%s_shuffled' % (MODEL, NUMBATCH, batch, conf)
                setting = '%s_batchpd_%s_conf_%s' % (MODEL, batch, conf)
                fout.write(setting)
                results = _smi('%s_smi.txt' % setting)
                for result in results:
                    fout.write(', %s' % result)
                fout.write('\n')

def _network(fname_in):
    returns = []
    for machine in MACHINES:
        data = []
        with open('data/%s_%s/%s' % (MODEL, machine, fname_in), 'r') as fin:
            data = fin.readlines()[5:]
        tx_total = [float(data[i].split(' ')[2]) for i in range(len(data))]
        rx_total = [float(data[i].split(' ')[5]) for i in range(len(data))]
        tx = [((tx_total[i+1] - tx_total[i]) / (1024 * FREQ)) for i in range(len(tx_total)-1)]
        rx = [((rx_total[i+1] - rx_total[i]) / (1024 * FREQ)) for i in range(len(rx_total)-1)]
        plot_title = '%s_%s' % (fname_in.split('.')[0], machine)
        plotting_network(tx, rx, plot_title)
        returns.append((tx_total[-1] - tx_total[1]) / (len(tx_total) * FREQ * 1024))
        returns.append(max(tx))
        returns.append((rx_total[-1] - rx_total[1]) / (len(rx_total) * FREQ * 1024))
        returns.append(max(rx))
    return returns

def network():
    with open('profiling_results/result_%s_network.csv' % MODEL, 'w') as fout:
        fout.write('Setting, TX_AVG_0, TX_MAX_0, RX_AVG_0, RX_MAX_0, TX_AVG_1, TX_MAX_1, RX_AVG_1, RX_MAX_1\n')
        for batch in BATCHES:
            for conf in CONFS:
                if '0' in conf:
                    continue
                setting = '%s_batchpd_%s_conf_%s' % (MODEL, batch, conf)
                fout.write(setting)
                results = _network('%s_network.txt' % setting)
                for result in results:
                    fout.write(', %s' % result)
                fout.write('\n')

def ps():
    pass

def main():
    speed()
    # network()
    smi()
    cpu_mem()


# def _main(model):
#     with open('profiling_results/result_%s.csv' % model, 'a+') as fout:
#         items = [
#             'Setting', 'Perf.(samples/s)', 'CPU_AVG(%)', 'CPU_MAX(%)',
#             'MEM_AVG(%)', 'MEM_MAX(%)', 'GPU_AVG(%)',
#             'GPU_MAX(%)', 'D2H_AVG(MB/s)', 'D2H_MAX(MB/s)',
#             'H2D_AVG(MB/s)', 'H2D_MAX(MB/s)', 'Network_AVG(MB/s),',
#             'Network_MAX(MB/s)', 'PS_CPU_AVG(%)', 'PS_CPU_MAX(%)',
#             'PS_MEM_AVG(%)', 'PS_MEM_MAX(%)'
#             ]
#         if fout.readline() == '':
#             fout.write('%s\n' % (str(reduce(lambda x, y: '%s, %s' % (x, y), items))))

#         machines = ['24', '19']
#         batches = ['8', '16', '32', '64', '128']
#         confs = [
#             '2:0', '4:0', '8:0',
#             '1:1', '2:2', '3:1',
#             '4:4', '6:2'
#         ]
#         #devices = ['0,no-ps', '0,1', '0,1,2,3', '0,1,2,3,4,5,6,7']
#         suffixes = ['speed', 'cpu_mem', 'smi', 'network', 'ps']
#         funcs = [speed, cpu_mem, smi, cpu_mem]

#         for conf in confs:
#             used_machines = []
#             for i, v in enumerate(conf.split(':')):
#                 if not v == '0':
#                     used_machines.append(i)
#             for batch in batches:
#                 line = ['%s_batchpd_%s_conf_%s' % (model, batch, conf)]
#                 for index, suffix in enumerate(suffixes):
#                     if len(used_machines) == 1 and suffix == 'ps':
#                         line.append('N/A, N/A, N/A, N/A')
#                     tmp = []
#                     for i in used_machines:
#                         fname = 'data/%s_%s/%s_%s.txt' % (model, machines[i], line[0], suffix)
#                         tmp.append(funcs[index](fname, fout))
#                         results = ['"%s, %s"' % (tmp[0][i], tmp[1][i]) for i in range(len(tmp[0]))]
#                         line.append(results)
#                 fout.write('%s\n' % (str(reduce(
#                     lambda x, y: '%s, %s' % (x, y), line))))

if __name__ == '__main__':
    main()
