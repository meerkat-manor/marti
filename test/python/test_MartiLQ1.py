
import os
import json
import sys
import csv
import zipfile

sys.path.insert(0, "./source/python/client")
from martiLQ import *

os.environ["MARTILQ_LOGPATH"] = "./test/python/results/logs"
        
print("Python test case #1")

mlq = martiLQ()
mlq.LoadConfig()
oMarti = mlq.NewMartiDefinition()
mlq.NewMartiChildItem(SourceFolder= "./docs/*", UrlPath="./docs" , ExcludeHash=False, ExtendAttributes=True)

oMarti["description"] = "Sample execution #1"

print("Save martiLQ definition #1")
mlq.Save("./test/python/results/DocsPlain1.mti")

print("Save martiLQ definition #2")
oMarti["description"] = "Sample execution #2"
jsonFile = open("./test/python/results/DocsPlain2.mti", "w")
jsonFile.write(json.dumps(oMarti, indent=5))
jsonFile.close()
print("Base sample mti written: DocsPlain2.mti")

print("Load martiLQ definition #1")
mlq.Load("./test/python/results/DocsPlain1.mti")
oMarti = mlq.Get()
print("Definition description is: {}".format(oMarti["description"]))

mlq.CloseLog()
       
print("Completed Python test case #1")
