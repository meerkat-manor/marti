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

os.environ["MARTILQ_LOGPATH"] = "./test/python/results/logs"
        
print("Python base sample/test case")

def HttpList(remote_url):
    
    files = []

    with open("./docs/source/samples/python/listfiles_bsb_http.txt", "r") as f:
        files = f.read().splitlines()

    return files


remote_url = "http://apnedata.merebox.com.s3.ap-southeast-2.amazonaws.com/au/bsb/"
print("Fetch sample file list")
files = HttpList(remote_url)

test_dir = "./test/python/results"
if not os.path.exists(test_dir):
    os.mkdir(test_dir)
if not os.path.exists(os.path.join(test_dir, "data")):
    os.mkdir(os.path.join(test_dir, "data"))

print("Fetch sample files via HTTP")
for file_name in files:
    if file_name.startswith("BSBDirectory"):
        if file_name.endswith(".csv") | file_name.endswith(".txt"):
            try:
                with urllib.request.urlopen(remote_url + file_name) as resp:
                    last_modified = resp.info()["Last-Modified"]
                    dt_obj = datetime.datetime.strptime(last_modified, '%a, %d %b %Y %H:%M:%S %Z')

                    data_file_name = os.path.join(test_dir, "data", file_name)
                    with open(data_file_name, 'wb') as data_file:
                        shutil.copyfileobj(resp, data_file)

                    modTime = time.mktime(dt_obj.timetuple())
                    os.utime(data_file_name, (modTime, modTime))
            except Exception as e:
                print("error "+ str(e))
                print("error with fetching "+remote_url + file_name)

print("Creating martiLQ definition")
mlq = martiLQ()
oMarti = mlq.NewMartiDefinition()

for file_name in files:
    if file_name.startswith("BSBDirectory"):
        if file_name.endswith(".csv") | file_name.endswith(".txt"):
            oResource = mlq.NewMartiLQResource(os.path.join(test_dir, "data", file_name), "", False, True)
            oMarti["resources"].append(oResource)

mlq.Close()


print("Save martiLQ definition")
jsonFile = open(os.path.join(test_dir, "martiLQ_base_test.json"), "w")
jsonFile.write(json.dumps(oMarti, indent=5))
jsonFile.close()
print("Base sample JSON written: martiLQ_base_test.json")


