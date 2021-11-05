
import os
import sys
import urllib.request
import shutil
import json
import csv
import zipfile
import datetime
import time

sys.path.insert(0, "../../../../source/python/client")
from martiLQ import *

httpFetch = True
os.environ["MARTILQ_LOGPATH"] = "./test/logs"


def HttpList(remote_url):
    
    files = []

    with open("listfiles_bsb.txt", "r") as f:
        files = f.read().splitlines()

    return files



remote_url = "http://apnedata.merebox.com.s3.ap-southeast-2.amazonaws.com/au/bsb/"
print("Fetch sample file list")
files = HttpList(remote_url)

test_dir = "./test/http"
if not os.path.exists(test_dir):
    os.mkdir(test_dir)

if httpFetch:
    print("Fetch sample files")
    for file_name in files:
        if file_name.startswith("BSBDirectory"):
            if file_name.endswith(".csv") | file_name.endswith(".txt"):
                with urllib.request.urlopen(remote_url + file_name) as resp:
                    last_modified = resp.info()["Last-Modified"]
                    dt_obj = datetime.datetime.strptime(last_modified, '%a, %d %b %Y %H:%M:%S %Z')

                    data_file_name = os.path.join(test_dir, file_name)
                    with open(data_file_name, 'wb') as data_file:
                        shutil.copyfileobj(resp, data_file)

                    modTime = time.mktime(dt_obj.timetuple())
                    os.utime(data_file_name, (modTime, modTime))

print("Creating martiLQ definition")
mlq = martiLQ()
oMarti = mlq.NewMartiDefinition()

for file_name in files:
    if file_name.startswith("BSBDirectory"):
        if file_name.endswith(".csv") | file_name.endswith(".txt"):
            oResource = mlq.NewMartiLQResource(os.path.join(test_dir, file_name), "", False, True)
            oMarti["resources"].append(oResource)

mlq.CloseLog()


print("Save martiLQ definition")
jsonFile = open(os.path.join(test_dir, "BSBDirectoryPlain.json"), "w")
jsonFile.write(json.dumps(oMarti, indent=5))
jsonFile.close()
print("Base sample JSON written: BSBDirectoryPlain.json")

print("Creating martiLQ ZIP file")
zipFileName = "BSBDirectory.zip"
fileZipCount = 0

mlq = martiLQ()
oMarti = mlq.NewMartiDefinition()
with zipfile.ZipFile(os.path.join(test_dir, zipFileName), "w", compression=zipfile.ZIP_DEFLATED) as zipObj:
    for file_name in files:
        if file_name.startswith("BSBDirectory"):
            if file_name.endswith(".csv") | file_name.endswith(".txt"):
                file_local = os.path.join(test_dir, file_name)
                zipObj.write(file_local, file_name)
                fileZipCount = fileZipCount + 1
                oResource = mlq.NewMartiLQResource(os.path.join(test_dir, file_name), "", False, True)
                oResource["url"] = "@"+zipFileName + "/" + file_name
                oMarti["resources"].append(oResource)
            

oResource = mlq.NewMartiLQResource(os.path.join(test_dir, zipFileName), "", False, True)
oResource["url"] = test_dir + zipFileName
mlq.SetAttributeValueString(Attributes=oResource["attributes"], Key="compression", Category="format", Function="algo", Value="WINZIP")
mlq.SetAttributeValueNumber(Attributes=oResource["attributes"], Key="files", Category="dataset", Function="count", Value=fileZipCount)
oMarti["resources"].append(oResource)

mlq.CloseLog()

print("Save martiLQ ZIP definition")
jsonFile = open(os.path.join(test_dir, "MartiLQ_BSBZip.json"), "w")
jsonFile.write(json.dumps(oMarti, indent=5))
jsonFile.close()
print("ZIP sample JSON written: MartiLQ_BSBZip.json")



print("Sample completed: SampleGenerateBsb.py")

lqresults, testError = mlq.TestMartiDefinition(os.path.join(test_dir, "BSBDirectoryPlain.json"))

testfile = open(os.path.join(test_dir, "LoadQualityTest01.csv"), "w+", newline ="") 
with testfile:     
    lqwriter = csv.writer(testfile) 
    lqwriter.writerows(lqresults) 

if testError:
    print("MISMATCH DETECTED")

print("Test completed: SampleGenerateFtpBsb.py")

