import os
import argparse
import subprocess
import signal
import time

def parse_args():
  parser = argparse.ArgumentParser(description='Mount ramdisk and nfs')
  parser.add_argument('--is_ramdisk', dest="is_ramdisk",action="store_true")
  parser.add_argument('--ip_file', type=str, dest="ip_file", required=True)
  parser.add_argument('--path', type=str, dest="path", required=True)
  parser.add_argument('--my_ip', type=str, dest="my_ip", required=True)

  return parser.parse_args()


def make_ramdisk_nfs(path, target_ip, size, enable_nfs = False, context = None):
  # path, size, target_ip, enable_nfs = True
  """Mount a ramdisk and mount nfs on the ramdisk"""
  subprocess.Popen("sudo umount -l %s" % (path), shell=True).wait()
  subprocess.Popen("sudo umount -f %s" % (path), shell=True).wait()
  if enable_nfs:
    subprocess.Popen("sudo exportfs -u %s:%s" % (target_ip, path), shell=True).wait()
  subprocess.Popen("sudo rm -rf %s" % (path), shell=True).wait()
  os.makedirs(path)
  os.chmod(path, 777)
  
  subprocess.Popen("sudo mount -t tmpfs -o size=%s tmpfs %s" % (size, path), shell=True)
  if enable_nfs:
    nfs_exports_str = "%s %s(rw,no_root_squash,fsid=1)" % (path, target_ip)
    subprocess.Popen("sudo exportfs %s:%s -o rw,async,no_root_squash,no_subtree_check,fsid=1" % (target_ip, path), shell=True)
  

def mount_remote_ramdisk(remote_ip, remote_path, local_path, context = None):
  """Mount the remote nfs ramdisk at remote_ip:remote_path to local_path"""
  subprocess.Popen("sudo umount -l %s" % (local_path), shell=True).wait()
  subprocess.Popen("sudo umount -f %s" % (local_path), shell=True).wait()
  subprocess.Popen("sudo rm -rf %s" % (local_path), shell=True).wait()
  # refer to https://docs.python.org/dev/library/os.path.html#os.path.exists
  # os.path.exists() may return False even the path exists
  time.sleep(0.5)

  os.makedirs(local_path)
  os.chmod(local_path, 777)

  cmd = "sudo mount -t nfs %s:%s %s" % (remote_ip, remote_path, local_path)
  subprocess.Popen(cmd, shell=True)

if __name__ == '__main__':
  args = parse_args()
  ip_list = []
  with open(args.ip_file, 'r') as fp:
    lines = fp.readlines()
    for line in lines:
      ip_list.append(line.rstrip('\n'))
    if args.is_ramdisk:
      make_ramdisk_nfs(os.path.join(args.path, args.my_ip), '*', "10G", enable_nfs = True)
      make_ramdisk_nfs(os.path.join(args.path, 'ckpts'), '*', '10G', enable_nfs = False)
    else:
      for ip in ip_list:
        if ip == args.my_ip:
          continue
        mount_remote_ramdisk(ip, os.path.join(args.path, ip), os.path.join(args.path, ip))
