
import os
import sys
import urllib.request
import shutil
import json
import csv
import zipfile
import datetime
import time

sys.path.insert(0, "./source/python/client")
from martiLQ import *

httpFetch = True
os.environ["MARTILQ_LOGPATH"] = "./docs/source/samples/python/test/logs"


def HttpList(remote_url):
    
    files = []

    with open("./docs/source/samples/python/listfiles_bsb_http.txt", "r") as f:
        files = f.read().splitlines()

    return files



remote_url = "http://apnedata.merebox.com.s3.ap-southeast-2.amazonaws.com/au/bsb/"
print("Fetch sample file list")
files = HttpList(remote_url)

test_dir = "./docs/source/samples/python/test/fetch_http"
if not os.path.exists(test_dir):
    os.mkdir(test_dir)

if httpFetch:
    print("Fetch sample files via HTTP")
    for file_name in files:
        if file_name.startswith("BSBDirectory"):
            if file_name.endswith(".csv") | file_name.endswith(".txt"):
                try:
                    with urllib.request.urlopen(remote_url + file_name) as resp:
                        last_modified = resp.info()["Last-Modified"]
                        dt_obj = datetime.datetime.strptime(last_modified, '%a, %d %b %Y %H:%M:%S %Z')

                        data_file_name = os.path.join(test_dir, file_name)
                        with open(data_file_name, 'wb') as data_file:
                            shutil.copyfileobj(resp, data_file)

                        modTime = time.mktime(dt_obj.timetuple())
                        os.utime(data_file_name, (modTime, modTime))
                except:
                    print("error with fetching "+remote_url + file_name)

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
mResource.SetAttributeValueNumber(oResource, Key="files", Category="dataset", Function="count", Value=fileZipCount)
oMarti["resources"].append(oResource)

mlq.Close()

print("Save martiLQ ZIP definition")
jsonFile = open(os.path.join(test_dir, "MartiLQ_BSBZip.json"), "w")
jsonFile.write(json.dumps(oMarti, indent=5))
jsonFile.close()
print("ZIP sample JSON written: MartiLQ_BSBZip.json")



print("Sample completed: SampleGenerateHttpBsb.py")

lqresults, testError = mlq.TestMartiDefinition(os.path.join(test_dir, "BSBDirectoryPlain.json"))

testfile = open(os.path.join(test_dir, "LoadQualityTest01.csv"), "w+", newline ="") 
with testfile:     
    lqwriter = csv.writer(testfile) 
    lqwriter.writerows(lqresults) 

if testError:
    print("MISMATCH DETECTED")
else:
    print("MATCHED")

print("Test completed: SampleGenerateHttpBsb.py")

