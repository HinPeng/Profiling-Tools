import os
import sys


class mergeFile():

  def __init__(self, path=None):
    if path is not None:
      self.path = path
    else:
      self.path = './'
    self.counts = dict()
    self.value = dict()
    self.all_layers = ['conv', 'mpool', 'apool', 'affine','dropout', 'batchnorm', 'lrn']

  def mergexls(self):
    files = os.listdir(self.path)
    for fi in files:
      if '.txt' not in fi:
        continue
      
      fi_d = os.path.join(self.path, fi)
      if os.path.isdir(fi_d):
        print(fi)
        # print(fi_d)
        pass
      else:
        for l in self.all_layers:
          if l in fi:
            if self.counts.get(l) is not None:
              self.counts[l] += 1
            else:
              self.counts[l] = 1

    for l,v in self.counts.items():
      for i in range(v):
        # print(l+str(i+1)+'.txt')
        tmp = []
        with open(l+str(i+1)+'.txt', 'r') as f:
          lines = f.readlines()
          for line in lines:
            tmp.append(float(line))

        if self.value.get(l) is None:
          self.value[l] = []
        self.value[l].append(tmp)

    for l,v in self.counts.items():
      length = len(self.value[l][0])
      with open(l+'.xls', 'w') as f:
        for j in range(length):
          for i in range(v):
            if i == v - 1:
              f.write(str(self.value[l][i][j])+'\n')
            else:
              f.write(str(self.value[l][i][j])+'\t')


if __name__ == '__main__':  
  path = None
  if len(sys.argv) > 1:
    path = sys.argv[1]
  mf = mergeFile(path=path)
  mf.mergexls()