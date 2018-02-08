# -*- coding: utf-8 -*-
"""
Created on Mon Jan 29 14:35:19 2018

@author: v-zhha
"""

import numpy as np 
from scipy.optimize import nnls 

#Define minimisation function
def fn(x, A, b):
    return np.sum(A*x,1) - b

# batch_size = 1024
# all_data = [
#     (2, 11701.52, 134.93, 2837.363, 0.0, 246.09), (3, 16330.87), (4, 19697.99, 246.9, 7448.919, 0.0, 447.76), (5, 22566.99),
#     (6, 24784.19, 334.95, 8932.943, 0.0, 627.99), (7, 25738.806), (8, 27262.14, 362.35, 9970.75, 0.0, 729.71)
# ]

# batch_size = 2048
# all_data = [
#     (2, 16269.46, 160.891, 2244.082, 0.0, 217.698), (3, 23438.75), (4, 28800.45, 300.054, 4986.929, 0.0, 407.6924), (5, 33881.481),
#     (6, 38186.394, 404.482, 7346.834, 0.0, 559.154), (7, 41653.834), (8, 45493.42, 483.74, 8158.156, 0.0, 698.839)
# ]

# batch_size = 4096
# all_data = [
#     (2, 20303.36, 178.462, 1365.902, 0.0, 195.535), (3, 28971.57), (4, 37650.52, 339.398, 3486.94, 0.0, 364.981), (5, 44974.416),
#     (6, 53934.951, 470.792, 5483.506, 0.0, 516.936), (7, 58550.133), (8, 66129.85, 585.092, 5939.851, 0.0, 659.377)
# ]

#pcie_bandwidth = [12, 9, 9, 5, 5, 5, 5]
pcie_bandwidth = [5, 5, 5, 5, 5, 5, 5]
ratio = [1, 1.3333333333333333, 1.5, 1.6, 1.6666666666666667, 1.7142857142857142, 1.75]
batch_size = 64
#all_data = [
#    (2, 250.5, 94.1758241758, 680.460164835, 0.0, 1830.53684211), (3, 367.61), (4, 465.76), (5, 529.67),
#    (6, 556.83), (7, 502.5), (8, 526.42, 55.0058823529, 385.625382966, 0.0, 4602.52631579)
#]
all_data = [
    (2, 235.14, 93.7313432836, 435.371968284, 0.0, 1617.22631579), (3, 367.61), (4, 426.4), (5, 529.67),
    (6, 556.83), (7, 502.5), (8, 565.85, 42.7485714286, 210.658482143, 0.0, 4530.95348837)
]

profile_settings = [0, 6]
#profile_data = [all_data[i] for i in profile_settings]

batch_times = [(batch_size * all_data[i][0] / all_data[i][1]) for i in range(len(all_data))]
gpu_times = [(batch_times[i] * all_data[i][2] / 100) for i in profile_settings]
#pcie_times = [(batch_times[i] * all_data[i][3] / ratio[i] / pcie_bandwidth[i] / 1024) for i in profile_settings]
pcie_times = [(batch_times[i] * all_data[i][3] / pcie_bandwidth[i] / 1024) for i in profile_settings]
pcie_traffics = [(batch_times[i] * all_data[i][3]) for i in profile_settings]
network_times = [(batch_times[i] * all_data[i][4] / (5 * 1024)) for i in profile_settings]
#cpu_times = [(batch_times[i] * all_data[i][5] / (5600 * all_data[i][0])) for i in profile_settings]
cpu_times = [(batch_times[j] - gpu_times[i] - pcie_times[i]) for i, j in enumerate(profile_settings)]
mean_times = list(map(np.mean, [gpu_times, pcie_times, network_times, cpu_times]))

pcie_traffic = np.mean(pcie_traffics)

input_data = []
output_data = []

for i, j in enumerate(profile_settings):
    input_data.append([gpu_times[i], pcie_times[i],
                       network_times[i], cpu_times[i] * all_data[i][0]])
    output_data.append(batch_times[j])

A = np.array(input_data)
B = np.array(output_data) 

print(A)
print(B)

x, _ = nnls(A,B)
print("Theta is")
print(x) 
print("Regression:")
print(fn(x,A,B))

input_data = []
output_data = []

for i, data in enumerate(all_data):
    if not i in profile_settings:
        num_gpu = data[0]
#        input_data.append([mean_times[0], pcie_traffic / pcie_bandwidth[i] * ratio[i], mean_times[2], mean_times[3] * num_gpu])
        input_data.append([mean_times[0], mean_times[1], mean_times[2], mean_times[3] * num_gpu])        
        output_data.append(batch_size * num_gpu / data[1])

A = np.array(input_data)
B = np.array(output_data) 
print(fn(x,A,0))
print(np.divide(fn(x,A,B), B))

#Define problem
#A = np.array([[60., 90., 120.], 
#              [30., 120., 90.],
#              [1.,  1.,   1. ]])
#
#b = np.array([67.5, 60., 1.])
#
#
#
#print(x,x.sum(),fn(x,A,b))
