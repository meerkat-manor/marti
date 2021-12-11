
import os
import json
import sys
import csv
import zipfile

sys.path.insert(0, "./source/python/client")
from martiLQ import *

os.environ["MARTILQ_LOGPATH"] = "./test/python/results/logs"
        
print("Python sample/test case for Singapore CKAN #1")

srcFile = ".\docs\source\samples\json\CKAN_SG_ChargeableIncomeofCompanies.json"
mlq = ConvertFromCkan(InputObject=srcFile)

saveFile = "./test/python/results/martiLQ_ckan_test_SG1.json"
mlq.Save(saveFile)
print("Saved martiLQ document: " + saveFile)

        
print("Python sample/test case for Singapore CKAN #2")

srcFile = ".\docs\source\samples\json\CKAN_SG_ChargeableIncomeofCompanies.json"
mlq = ConvertFromCkan(InputObject="https://data.gov.sg/api/action/package_show?id=e7a00a47-2676-4352-9495-a796124a3453", FetchResource=True, DataPath="test/python/results/data")

saveFile = "./test/python/results/martiLQ_ckan_test_SG2.json"
mlq.Save(saveFile)
print("Saved martiLQ document: " + saveFile)

print("Python sample/test case for Australia CKAN")

srcFile = ".\docs\source\samples\json\CKAN_AU_asic_ckan_api.json"
mlq = ConvertFromCkan(InputObject=srcFile)
print("Wrote converted definition to: " + srcFile)

saveFile = "./test/python/results/martiLQ_ckan_test_AU1.json"
mlq.Save(saveFile)
print("Saved martiLQ document: " + saveFile)

