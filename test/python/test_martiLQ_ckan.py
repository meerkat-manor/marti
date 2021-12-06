
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
mlq = ConvertFromCkan(CkanPath=srcFile, PackageUrl="https://data.gov.sg/api/action/package_show?id=e7a00a47-2676-4352-9495-a796124a3453")

saveFile = "./test/python/results/test_martiLQ_ckan_SG1.json"
mlq.Save(saveFile)
print("Saved martiLQ document: " + saveFile)

        
print("Python sample/test case for Singapore CKAN #2")

srcFile = ".\docs\source\samples\json\CKAN_SG_ChargeableIncomeofCompanies.json"
mlq = ConvertFromCkan(CkanPath=None, PackageUrl="https://data.gov.sg/api/action/package_show?id=e7a00a47-2676-4352-9495-a796124a3453", FetchResource=True)

saveFile = "./test/python/results/test_martiLQ_ckan_SG2.json"
mlq.Save(saveFile)
print("Saved martiLQ document: " + saveFile)

print("Python sample/test case for Australia CKAN")

srcFile = ".\docs\source\samples\json\CKAN_AU_asic_ckan_api.json"
mlq = ConvertFromCkan(CkanPath=srcFile, PackageUrl="")
print("Wrote converted definition to: " + srcFile)

saveFile = "./test/python/results/test_martiLQ_ckan_AU1.json"
mlq.Save(saveFile)
print("Saved martiLQ document: " + saveFile)

