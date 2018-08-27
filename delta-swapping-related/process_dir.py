import os
import sys
from calculate_variance import ProcessFile

# filepath="/vpublic01/frog/v-xuapen/benchmarks/scripts/tf_cnn_benchmarks/scripts/"
# filepath="/vpublic01/frog/v-xuapen/node335-bk/mem_log_allvalue/result/"
pwd = os.getcwd()
filepath = pwd+'/'

def process_dir(path):
  if not os.path.exists(path):
    raise IOError

  files = os.listdir(path)
  for fi in files:
    fi_d = os.path.join(path, fi)
    if os.path.isdir(fi_d):
      print("curr_dir: %s" % fi_d)
      # continue
      process_dir(fi_d)
    else:
      if '.pdf' in fi:
        continue
      print(fi)
      
      # in_filename=str(fi)
      in_fullname=path + '/' + fi
      out_dir=path
      # out_dir=out_filepath+fi.split('.')[0]+'/'
      # if os.path.exists(out_dir):
      #   continue
      # os.mkdir(out_dir)
      plot_title=None
      # plot_title=fi.split('.')[0]

      in_p=open(in_fullname)
      pf = ProcessFile()
      pf.process_file(in_p, plot=False, plot_title=plot_title, out_dir=out_dir, CDF=True)
      # pf.process_max(in_p, out_dir=out_dir)
      # print(os.path.join(path, fi_d))

if __name__ == '__main__':
  rela_dir = ''
  if len(sys.argv) != 1:
    rela_dir = sys.argv[1]
    if '/' in rela_dir:
      pass
    else:
      rela_dir += '/'

  filepath += rela_dir
  # out_filepath=filepath+'result/'
  # if not os.path.exists(out_filepath):
  #   os.mkdir(out_filepath)
  process_dir(filepath)
