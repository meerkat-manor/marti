
import os
import sys
import csv

sys.path.insert(0, "../../../source/python/client")
from martiLQ import *

test_directory = "./test/fetch_http"
os.environ["MARTILQ_LOGPATH"] = os.path.join(test_directory, "logs")

if not os.path.exists("./test"):
    os.mkdir("./test")

if not os.path.exists(test_directory):
    os.mkdir(test_directory)

print("Creating martiLQ definition")
mlq = martiLQ()
mlq.LoadConfig()
print("Loading definition json")
mlq.Load("../BSBDirectoryHttp.json")
print("Fetching files")
fetched_files, fetch_error = mlq.Fetch(test_directory)

if len(fetched_files) < 0:
    raise Exception("No resource files fetched")
else:
    print("Fetched {} files".format(len(fetched_files)))

if len(fetch_error) > 0:
    raise Exception("Some resources not fetched")

print("Generate the self value, overriding existing")
oMarti = mlq.NewMartiDefinition()
for full_fileName in fetched_files:
    if os.path.isfile(full_fileName):
        oResource = mlq.NewMartiLQResource(full_fileName, "", False, True)
        oMarti["resources"].append(oResource)
print("Perform validation test")
lqresults, testError = mlq.TestMartiDefinition("../BSBDirectoryHttp.json")

testfile = open("./test/LoadQualityTest_Http.csv", "w+", newline ="") 
with testfile:     
    lqwriter = csv.writer(testfile) 
    lqwriter.writerows(lqresults) 

if testError > 0:
    print("MISMATCH DETECTED")
else:
    print("RECONCILED")

mlq.CloseLog()

print("Test completed: SampleFetchHttpBsb.py")

