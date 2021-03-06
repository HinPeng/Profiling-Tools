
import matplotlib
matplotlib.use('Agg')
import sys
import os
import matplotlib.pyplot as plt
from calculate_variance import ProcessFile

FREQ = 1
def plotting_Normal(in_v, title=None, out_dir=None):
  data_x = list(map(lambda x: x*FREQ, range(len(in_v))))
  plt.plot(data_x, in_v, color='r', linewidth=0.5, label='Variance')
  if title:
    plt.title(title)
    plt.xlabel('Mini-batch')
    plt.ylabel('Variance')
    plt.legend(loc='best')
    if out_dir:
      plt.savefig('%s/%s.pdf' % (out_dir, title), format='pdf')
    else:
      plt.savefig('./%s.pdf' % title, format='pdf')
    plt.clf()

def plotting_CDF(in_v, title=None, out_dir=None):
  title+='_CDF'
  in_v.sort()
  _count = len(in_v)
  data_y = list(map(lambda x: x/float(_count), range(_count)))
  plt.plot(in_v, data_y, color='r', linewidth=0.5, label='Variance')
  plt.title(title)
  plt.xlabel('Tensor Value')
  plt.ylabel('CDF')
  plt.legend(loc='best')
  if out_dir:
    plt.savefig('%s/%s.pdf' % (out_dir, title), format='pdf')
  else:
    plt.savefig('./%s.pdf' % title, format='pdf')
  plt.clf()

def plotting(in_v, title=None, out_dir=None, CDF=False):
  if CDF == False:
    return plotting_Normal(in_v, title=title, out_dir=out_dir)
  else:
    return plotting_CDF(in_v, title=title, out_dir=out_dir)

def extract_inv(filename, out_dir=None):
  if '.pdf' in filename:
    return
  rela_name = filename.split('/')[-1]
  title_name = filename.split('/')[-2]+'_'+rela_name.split('.')[0]

  in_value = []
  with open(filename, 'r') as f:
    lines = f.readlines()
    for line in lines:
      in_value.append(float(line))

  plotting(in_value, title=title_name, out_dir=out_dir)

def process_dir(path):
  files = os.listdir(path)
  for fi in files:
    fi_d = os.path.join(path, fi)
    if os.path.isdir(fi_d):
      process_dir(fi_d)
    else:
      in_filename=str(fi)
      in_fullname=path+'/'+in_filename
      # out_dir=path+in_filename.split('.')[0]+'/'
      # os.mkdir(out_dir)
      extract_inv(in_fullname, out_dir=path)
    



# filepath="/vpublic01/frog/v-xuapen/benchmarks/scripts/tf_cnn_benchmarks/scripts/"
pwd = os.getcwd()
filepath = pwd + '/'

if __name__ == '__main__':
  rela_dir = ''
  if len(sys.argv) != 1:
    rela_dir = sys.argv[1]
  else:
    print('need a child dir to be given!')
    raise IOError
  if '/' in rela_dir:
    pass
  else:
    rela_dir += '/'
  filepath += rela_dir
  filepath=filepath+'result/'
  if not os.path.exists(filepath):
    raise IOError
  process_dir(filepath)