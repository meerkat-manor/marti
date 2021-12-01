
import ftplib 
import os
import json
import sys
import csv
import zipfile


sys.path.insert(0, "./source/python/client")
from martiLQ import *

ftpFetch = True
os.environ["MARTILQ_LOGPATH"] = "./docs/source/samples/python/test/logs"

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
            
            with open(file_local, 'wb') as fl:
                res = ftp.retrbinary(f"RETR {file_remote}", fl.write)
                if not res.startswith('226 Transfer complete'):
                    print('Download failed')
                    if os.path.isfile(file_local):
                        os.remove(file_local)          

        except ftplib.all_errors as e:
            print('FTP error:', e) 
            if os.path.isfile(file_local):
                os.remove(file_local)


remote_host = "bsb.hostedftp.com"
remote_dir = "/~auspaynetftp/BSB/"

print("Fetch sample file list")
files = ftpList(remote_host, remote_dir)

test_dir = "./docs/source/samples/python/test/fetch_ftp"
if not os.path.exists(test_dir):
    os.mkdir(test_dir)

print("Fetch sample files via FTP")
for file_name in files:
    if file_name.startswith("BSBDirectory"):
        if file_name.endswith(".csv") | file_name.endswith(".txt"):
            file_remote = remote_dir + file_name
            file_local = os.path.join(test_dir, file_name)
            if ftpFetch:
                ftpPull(remote_host, file_remote, file_local)

print("Creating martiLQ definition")
mlq = martiLQ()
oMarti = mlq.NewMartiDefinition()

for file_name in files:
    if file_name.startswith("BSBDirectory"):
        if file_name.endswith(".csv") | file_name.endswith(".txt"):
            oResource = mlq.NewMartiLQResource(os.path.join(test_dir, file_name), "", False, True)
            oMarti["resources"].append(oResource)

mlq.Close()


print("Save martiLQ definition")
jsonFile = open(os.path.join(test_dir, "martilq_bsb.json"), "w")
jsonFile.write(json.dumps(oMarti, indent=5))
jsonFile.close()
print("Base sample JSON written: martilq_bsb.json")


print("Creating martiLQ ZIP file")
zipFileName = "martilq_bsb.zip"
fileZipCount = 0

mlq = martiLQ()
oMarti = mlq.NewMartiDefinition()
with zipfile.ZipFile(os.path.join(test_dir, zipFileName), "w", compression=zipfile.ZIP_DEFLATED) as zipObj:
    for file_name in files:
        if file_name.startswith("BSBDirectory"):
            if file_name.endswith(".csv") | file_name.endswith(".txt"):
                file_remote = remote_dir + file_name
                file_local = os.path.join(test_dir, file_name)
                if ftpFetch:
                    ftpPull(remote_host, file_remote, file_local)
                zipObj.write(file_local, file_name)
                fileZipCount = fileZipCount + 1
                oResource = mlq.NewMartiLQResource(os.path.join(test_dir, file_name), "", False, True)
                oResource["url"] = "@"+zipFileName + "/" + file_name
                oMarti["resources"].append(oResource)
            

oResource = mlq.NewMartiLQResource(os.path.join(test_dir, zipFileName), "", False, True)
oResource["url"] = test_dir + "/" + zipFileName

mResource.SetAttributeValueString(oResource, Key="compression", Category="format", Function="algo", Value="WINZIP")
mResource.SetAttributeValueNumber(oResource, Key="files", Category="dataset", Function="count", Value=fileZipCount)

oMarti["resources"].append(oResource)

mlq.Close()

print("Save martiLQ ZIP definition")
jsonFile = open(os.path.join(test_dir, "martilq_bsb_zip.json"), "w")
jsonFile.write(json.dumps(oMarti, indent=5))
jsonFile.close()
print("ZIP sample JSON written: martilq_bsb_zip.json")

print("Sample completed: SampleGenerateFtpBsb.py")

lqresults, testError = mlq.TestMartiDefinition(os.path.join(test_dir, "martilq_bsb.json"))

testfile = open(os.path.join(test_dir, "LoadQualityTest01.csv"), "w+", newline ="") 
with testfile:     
    lqwriter = csv.writer(testfile) 
    lqwriter.writerows(lqresults) 

if testError:
    print("MISMATCH DETECTED")
else:
    print("MATCHED")

print("Test completed: SampleGenerateFtpBsb.py")

