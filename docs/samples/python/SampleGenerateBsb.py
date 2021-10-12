

import ftplib 
import os
import json
import sys
  
sys.path.insert(0, "../../../source/python/client")
from marti import *

def ftpList(host, path):
    
    files = []
    with ftplib.FTP(host) as ftp:
        try:
            ftp.login()  
            ftp.cwd(path)
            files = ftp.nlst()
        except ftplib.all_errors as e:
            print('FTP error:', e)

    return files


def ftpPull(host, file_remote, file_local):

    with ftplib.FTP(host) as ftp:
                
        try:
            ftp.login()  
            ftp.sendcmd('TYPE I') 
            
            with open(file_local, 'w') as fl:
                res = ftp.retrlines('RETR ' + file_remote, fl.write)
                if not res.startswith('226 Transfer complete'):
                    print('Download failed')
                    if os.path.isfile(file_local):
                        os.remove(file_local)          

        except ftplib.all_errors as e:
            print('FTP error:', e) 
            if os.path.isfile(file_local):
                os.remove(file_local)


remote_host = 'bsb.hostedftp.com'
remote_dir = '/~auspaynetftp/BSB/'

print("Fetch sample file list")
files = ftpList(remote_host, remote_dir)

print("Fetch sample files")
for file_name in files:
    if file_name.startswith('BSBDirectory'):
        if file_name.endswith('.csv') | file_name.endswith('.txt'):
            file_remote = remote_dir + file_name
            file_local = './test/' + file_name
            ftpPull(remote_host, file_remote, file_local)

print("Creating marti definition")
oMarti = NewMartiDefinition()

for file_name in files:
    if file_name.startswith('BSBDirectory'):
        if file_name.endswith('.csv') | file_name.endswith('.txt'):
            oResource = NewMartiResource(os.path.join("./test/", file_name), "", False, True, "./test/logs")
            oMarti["resources"].append(oResource)

print("Save marti definition")
jd = json.dumps(oMarti, indent=5)

jsonFile = open("./test/BSBDirectoryPlain.mri.json", "w")
jsonFile.write(jd)
jsonFile.close()
print("Sample completed")
