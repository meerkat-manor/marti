

import ftplib
from genericpath import getsize 
import os
import uuid
import json
import datetime
import getpass
import hashlib
import glob
import argparse
from configparser import ConfigParser
import requests
import mimetypes

from mconfiguration import mConfiguration
from mlogging import mLogging
from mresource import mResource

class martiLQ:

    _SoftwareVersion = "0.0.1"
    _default_metaFile = "##marti##.json"

    _oSoftware = {
        "extension": "software",
        "softwareName": "MARTILQREFERENCE",
        "author": "Meerkat@merebox.com",
        "version": "0.0.1"
    }


    _MartiErrorId = ""
    _oMartiDefinition = None
    _oConfiguration = None
    _Log = None


    def GetSoftwareName(self):
        return "MARTILQREFERENCE"

    def __init__(self):
        self._oConfiguration = mConfiguration()
        self._Log = mLogging()
        self._Log.SetConfig(self._oConfiguration.GetConfig("logPath"), self._oConfiguration.GetSoftwareName())

    def LoadConfig(self, ConfigPath):
        self._oConfiguration.LoadConfig(ConfigPath)

    def SaveConfig(self, ConfigPath):
        return self._oConfiguration.SaveConfig(ConfigPath)

    def Set(self, MartiLQ):
        self._oMartiDefinition = MartiLQ

    def SetTitle(self, Title):
        self._oMartiDefinition.title = Title

    def Get(self):
        return self._oMartiDefinition

    def Save(self, JsonPath):
        jsonFile = open(JsonPath, "w")
        jsonFile.write(json.dumps(self._oMartiDefinition, indent=5))
        jsonFile.close()

    def Load(self, JsonPath):

        self._MartiErrorId = ""

        self._Log.OpenLog()
        self._Log.WriteLog("Function 'Load' parameters follow")
        self._Log.WriteLog("Parameter: SourcePath   Value: {}".format(JsonPath))
        self._Log.WriteLog("")

        if not os.path.exists(JsonPath):
            self._Log.WriteLog("martiLQ document file '"+ JsonPath +"' does not exist")
            raise Exception("martiLQ document file '{}' does not exist".format(JsonPath))

        if not self._oMartiDefinition is None:
            self._Log.WriteLog("Existing definition overwritten in memory")

        jsonFile = open(JsonPath, "r")
        self._oMartiDefinition = json.load(jsonFile)
        jsonFile.close()

        
    def Close(self):
        self._Log.CloseLog()

    def NewMartiDefinition(self):

        today = datetime.datetime.today() 
        dateToday = today.strftime("%Y-%m-%dT%H:%M:%S") 

        publisher = self._oConfiguration.GetConfig("publisher")
        if publisher == "":
            publisher = getpass.getuser()

        lcustom = []
        lcustom.append(self._oSoftware)

        lresource = []

        self._oMartiDefinition = {
            "content-type": "application/vnd.martilq.json",
            "title": "",
            "uid": str(uuid.uuid4()),

            "description": "",
            "modified": dateToday,
            "publisher": publisher,
            "contactPoint": self._oConfiguration.GetConfig("contactPoint"),
            "accessLevel": self._oConfiguration.GetConfig("accessLevel"),
            "rights": self._oConfiguration.GetConfig("rights"),
            "tags": self._oConfiguration.GetConfig("tags"),
            "license": self._oConfiguration.GetConfig("license"),
            "state": self._oConfiguration.GetConfig("state"),
            "batch": self._oConfiguration.GetConfig("batch"),
            "describedBy": self._oConfiguration.GetConfig("describedBy"),
            "landingPage": self._oConfiguration.GetConfig("landingPage"),
            "theme": self._oConfiguration.GetConfig("theme"), 

            "resources": lresource,
            "custom": lcustom
        }

        return self._oMartiDefinition

    def Temporal(self):

        oTemporal = {
            "enabled": False,
            "extension": "temporal",
            "businessDate": "",
            "runDate": ""
        }

        return oTemporal

    def Spatial(self):

        oSpatial = {
            "enabled": False,
            "country": "",
            "region": "",
            "town": "",
        }

        return oSpatial

    def NewMartiChildItem(self, SourceFolder, UrlPath=None, Recurse=True, ExtendAttributes=True, ExcludeHash=False, Filter ="*"):

        if not SourceFolder.endswith("*"):
            SourceFullName = os.path.abspath(SourceFolder)
            SourceFullName = os.path.join(SourceFullName, Filter)
        else:
            SourceFullName = os.path.abspath(SourceFolder)

        for fullName in glob.iglob(SourceFullName, recursive=Recurse):
            if os.path.isfile(fullName):
                oResource = self.NewMartiLQResource(SourcePath=fullName, UrlPath=UrlPath, ExtendAttributes=ExtendAttributes, ExcludeHash=ExcludeHash)
                if self._oMartiDefinition["resources"] is None:
                    print("MartiLQ defintion resources not initialised") 
                    self._Log.WriteLog("MartiLQ defintion resources not initialised") 
                self._oMartiDefinition["resources"].append(oResource)



    def NewMartiLQResource(self, SourcePath, UrlPath, ExcludeHash, ExtendAttributes): 

        self._MartiErrorId = ""
        oRes = mResource()
        oRes.SetConfig(self._oConfiguration)
        
        resource = oRes.NewMartiLQResource(SourcePath, UrlPath, ExcludeHash, ExtendAttributes)

        return resource




    def FtpPull(self, host, file_remote, file_local):

        with ftplib.FTP(host) as ftp:
                    
            try:
                ftp.login()  
                
                with open(file_local, 'wb') as fl:
                    res = ftp.retrbinary(f"RETR {file_remote}", fl.write)
                    if not res.startswith('226 Transfer complete'):
                        print('Download failed for: '+file_remote)
                        self._Log.WriteLog('Download failed for: '+file_remote)
                        if os.path.isfile(file_local):
                            os.remove(file_local)          

            except ftplib.all_errors as e:
                self._Log.WriteLog('FTP error:', e) 
                if os.path.isfile(file_local):
                    os.remove(file_local)


    def Fetch(self, TargetPath):

        if TargetPath is None or TargetPath == "":
            self._Log.WriteLog("Target path is missing from fetch")
            raise Exception("Target path is missing from fetch")

        if self._oMartiDefinition is None:
            self._Log.WriteLog("No defintion loaded")
            raise Exception("No defintion loaded")

        if len(self._oMartiDefinition["resources"]) < 1:
            self._Log.WriteLog("No resources in defintion")
            raise Exception("No resources in defintion")

        if not os.path.exists(TargetPath):
            os.makedirs(TargetPath, exist_ok=True)

        fetched_files = [] 
        fetch_error = []

        for resource in self._oMartiDefinition["resources"]:

            if not resource["url"] is None and not resource["url"] == "":
                method = str(resource["url"].split(":", 2)[0]).lower()

                if method == "ftp":
                    parts = resource["url"].split("/", 3)
                    host = parts[2]
                    file_remote = parts[3]
                    self.FtpPull(host, file_remote, os.path.join(TargetPath, resource["documentName"]))
                    fetched_files.append(os.path.join(TargetPath, resource["documentName"]))

                elif method == "http" or method == "https":
                    response = requests.get(resource["url"])
                    if not response.status_code == 200:
                        self._Log.WriteLog("HTTP fetch failed with code {} for '{}'".format(response.status_code, resource["url"]))
                        print("HTTP fetch failed with code {} for '{}'".format(response.status_code, resource["url"]))
                        fetch_error.append(resource["url"])
                    else:
                        with open(os.path.join(TargetPath, resource["documentName"]),'wb') as fh:
                            fh.write(response.content)
                        fetched_files.append(os.path.join(TargetPath, resource["documentName"]))

                elif method == "file":
                    pass

                else:
                    fetch_error.append(resource["documentName"])

            else:
                fetch_error.append(resource["documentName"])

        return fetched_files, fetch_error


    def TestAttributeDefinition(self, oTestResults, documentName, localR, remoteR):

        errorCount = 0

        for attrL in localR:

            if attrL["comparison"] != "NA":
                try:
                    for attrR in remoteR:
                        if attrL["category"] == attrR["category"] and attrL["name"] == attrR["name"] and attrL["function"] == attrR["function"]:
                            match = False
                            if attrL["comparison"] == "EQ":
                                match = attrL["value"] == attrR["value"]
                                otest = [documentName, "Attribute", (attrL["category"]+" " + attrL["name"]+" " + attrL["function"]), match, attrL["value"], attrR["value"] ]
                                oTestResults.append(otest)
                                if not match:
                                    errorCount = errorCount + 1
                            break
                except Exception as e:
                    print(e.message)
                    print("ERROR with: {}".format(attrL["name"]))
                    otest = [documentName, "Attribute", attrL["name"], False, "N/F", "N/F" ]
                    oTestResults.append(otest)
                    errorCount = errorCount + 1

        return errorCount

    def TestMartiDefinition(self, SourcePath, Sign=None):

        self._MartiErrorId = ""

        self._Log.OpenLog()
        self._Log.WriteLog("Function 'TestMartiDefinition' parameters follow")
        self._Log.WriteLog("Parameter: SourcePath   Value: {}".format(SourcePath))
        self._Log.WriteLog("")

        if self._oMartiDefinition is None:
            pass

        if not os.path.exists(SourcePath):
            pass    

        jsonFile = open(SourcePath, "r")
        lq = json.load(jsonFile)
        jsonFile.close()

        testError = 0
        oTestResults = []

        otest = ["ResourceName", "Level", "Metric", "Matches", "LocalCalculation", "SuppliedValue" ]
        oTestResults.append(otest)

        otest = ["@", "Batch", "Resource count", (len(self._oMartiDefinition["resources"]) == len(lq["resources"])), len(self._oMartiDefinition["resources"]), len(lq["resources"]) ]
        oTestResults.append(otest)

        for resource in self._oMartiDefinition["resources"]:

            for retarget in lq["resources"]:
                if resource["documentName"] == retarget["documentName"]:

                    if retarget["hash"]["signed"]:
                        # Need to verify the hash
                        if Sign is None:
                            Sign = self._oConfiguration.GetConfig("signKey_file")

                        if Sign is None:
                            self._Log.WriteLog("No Sign Key specified so Hash check cannot be performed for signed content")
                        else:
                            try:
                                import OpenSSL
                                from OpenSSL import crypto
                                import base64
                            except ImportError:
                                self._Log.WriteLog("Import error in signed verification")

                            pub_key_file = open(Sign, "r")
                            pubkey = pub_key_file.read()
                            pub_key_file.close()

                            x509 = crypto.X509()
                            x509.set_pubkey(pubkey)

                            try:
                                crypto.verify(x509, retarget["hash"]["value"], resource["hash"]["value"], retarget["hash"]["algo"])
                                otest = [resource["documentName"], "Resource", "Hash",False, resource["hash"]["value"], retarget["hash"]["value"] ]
                            except:
                                testError = testError + 1
                                self._Log.WriteLog("Error in verification for {}".format(resource["documentName"]))
                                otest = [resource["documentName"], "Resource", "Hash", True, resource["hash"]["value"], retarget["hash"]["value"] ]
                        
                        oTestResults.append(otest)

                        pass
                    else:
                        if not resource["hash"]["value"] == retarget["hash"]["value"]:
                            testError = testError + 1
                        otest = [resource["documentName"], "Resource", "Hash", (resource["hash"]["value"] == retarget["hash"]["value"]), resource["hash"]["value"], retarget["hash"]["value"] ]
                        oTestResults.append(otest)

                    if not resource["length"] == retarget["length"]:
                        testError = testError + 1
                    otest = [resource["documentName"], "Resource", "Length", (resource["length"] == retarget["length"]), resource["length"], retarget["length"] ]
                    oTestResults.append(otest)

                    errorAttrCount = self.TestAttributeDefinition(oTestResults, resource["documentName"], resource["attributes"], retarget["attributes"])
                    testError = testError + errorAttrCount

                    break

        self._Log.WriteLog("TestMartiDefinition function completed with {} errors".format(testError))

        return oTestResults, testError



def Make(ConfigPath, SourcePath, Filter, Recursive, UrlPrefix, DefinitionPath):

    oMarti = martiLQ()
    if ConfigPath != "":
        oMarti.LoadConfig(ConfigPath)
    oMarti.NewMartiDefinition()

    oMarti.NewMartiChildItem(SourceFolder=SourcePath, UrlPath=UrlPrefix , ExcludeHash=False, Filter=Filter, Recurse=Recursive, ExtendAttributes=True)

    if DefinitionPath != "":
        oMarti.Save(DefinitionPath)

    return oMarti


def GetResources(ConfigPath, OutputPath, DefinitionPath, Proxy=None, ProxyUser=None,ProxyCredential=None):

    oMarti = martiLQ()
    if ConfigPath != "":
        oMarti.LoadConfig(ConfigPath)

    oMarti.Load(DefinitionPath)
    oMarti._oConfiguration.SetConfig("proxy", Proxy)
    fetched_files, fetch_error = oMarti.Fetch(OutputPath)
    if len(fetch_error) > 0:
        print("Fetch file error")
    else:
        print("Fetched files")

    return fetched_files, fetch_error

def main():


    parser = argparse.ArgumentParser(description='Processing for MartiLQ')

    parser.add_argument("-t", "--task", dest="task", type=str,
                        choices=["INIT", "MAKE", "GET", "RECON"],
                        help='task to execute')
    parser.add_argument("-s", "--source", dest="sourcePath",
                        help='path to source documents')
    parser.add_argument("-c", "--config", dest="configPath",
                        help='path to source documents')
    parser.add_argument("-m", "--martilq", dest="definitionPath",
                        help='martiLQ document path')
    parser.add_argument("-o", "--output", dest="outputPath",
                        help="output file path")

    parser.add_argument("-u", "--url", dest="urlPrefix",
                        help="URL prefix for documents")
    
    parser.add_argument("-R", "--recursive", action="store_false",
                        help="recursive processing for source")
    
    parser.add_argument("--udpate", action="store_false",
                        help="allow update of existing martiLQ document")
    
    parser.add_argument("--title", dest="title",
                        help="title for martiLQ document")
    parser.add_argument("--filter", dest="filter",
                        default="*",
                        help="filter for source documents")
    parser.add_argument("--description", dest="description",
                        help="decription for document")
    parser.add_argument("--landing", dest="landing",
                        help="landing detail for martiLQ document")

    args = parser.parse_args()

     

    if args.task == "INIT":
        if args.configPath is None or args.configPath == "":
            raise Exception("Configuration path parameter required")
        m = martiLQ()
        if m.SaveConfig(args.configPath):
            print("Saved martiLQ configuration: " + args.configPath)
        else:
            print("Error in saving configuration file")
        m.Close()


    if args.task == "MAKE":

        if args.sourcePath is None or args.sourcePath == "":
            raise Exception("Source path parameter required")
        if args.definitionPath is None or args.definitionPath == "":
            raise Exception("martiLQ document (json) path and name parameter required")

        m = Make(ConfigPath=args.configPath, SourcePath=args.sourcePath, Filter=args.filter, Recursive=args.recursive, UrlPrefix=args.urlPrefix, DefinitionPath=args.definitionPath)

        if args.title != "":
            m.Get()["title"] = args.title
		
        if args.description != "":
            m.Get()["description"] = args.description
			
        m.Save(args.definitionPath)
        m.Close()
        print("Saved martiLQ document: " + args.definitionPath)

    if args.task == "GET":

        if args.outputPath is None or args.outputPath == "":
            raise Exception("Output path parameter required")
        if args.definitionPath is None or args.definitionPath == "":
            raise Exception("martiLQ document (json) path and name parameter required")

        fetched_files, fetch_error = GetResources(ConfigPath=args.configPath, OutputPath=args.outputPath, DefinitionPath=args.definitionPath)
        for item in fetched_files:
           print("\t"+item)
        print("GET Feature done")

    if args.task == "RECON":
        print("RECON Feature not imlemented yet")



if __name__ == "__main__":
    main()
