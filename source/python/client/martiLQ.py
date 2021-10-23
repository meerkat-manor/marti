

import ftplib
from genericpath import getsize 
import os
import uuid
import json
import datetime
import getpass
import hashlib
import glob
from configparser import ConfigParser
import requests
import mimetypes

class martiLQ:

    _SoftwareVersion = "0.0.1"
    _default_metaFile = "##marti##.mti"

    _oSoftware = {
        "extension": "software",
        "softwareName": "MARTILQREFERENCE",
        "author": "Meerkat@merebox.com",
        "version": "0.0.1"
    }


    _MartiErrorId = ""
    _LogOpen = False

    _oMartiDefinition = None

    _oConfiguration = None


    def GetSoftwareName(self):
        return "MARTILQREFERENCE"

    def __init__(self):
        self._LogOpen = False
        
        _oSoftware = {
            "extension": "software",
            "softwareName": self.GetSoftwareName(),
            "author": "Meerkat@merebox.com",
            "version": self._SoftwareVersion
        }

        self._oConfiguration = {
            "softwareName": self.GetSoftwareName(),
            "author": "Meerkat@merebox.com",
            "version": self._SoftwareVersion,

            "logPath": None,

            "state": "active",
            "accessLevel": "Confidential",
            "rights": "Restricted",

            "hashAlgorithm": "SHA256",
            "signKey_File": None,
            "signKey_Password": None,

            "loaded": False
        }

    def LoadConfig(self, ConfigPath=None):

        config_object = ConfigParser()
        if not ConfigPath is None:
            if os.path.exists(ConfigPath):
                config_object.read(ConfigPath)
            else:
                self.WriteLog("Configuration path '{}' does not exist".format(ConfigPath))
                raise Exception("Configuration path '{}' does not exist".format(ConfigPath))
        else:
            # Look in default location and name
            home = os.path.expanduser('~')
            if os.path.exists(os.path.join(home, ".martilq/martilq.ini")): 
                ConfigPath = os.path.join(home, ".martilq/martilq.ini")
            if os.path.exists("martilq.ini"): 
                ConfigPath = "martilq.ini"
            if not ConfigPath is None:
              self.WriteLog("Usig configuration path '{}'".format(ConfigPath))
              config_object.read(ConfigPath)

        if config_object.has_section("Resources"):
            items = config_object["Resource"]
            if not items is None:
                config_attr = ["accessLevel", "rights", "state"]
                for x in config_attr:
                    if not items[x] is None and not items[x] == "":
                        self._oConfiguration[x] = items[x]

        if config_object.has_section("Hash"):
            items = config_object["Hash"]    
            if not items is None:
                config_attr = ["hashAlgorithm", "signKey_File", "signKey_Password"]
                for x in config_attr:
                    if not items[x] is None and not items[x] == "":
                        self._oConfiguration[x] = items[x]

        # Now check environmental values
        self._oConfiguration["signKey_File"] = os.getenv("MARTILQ_SIGNKEY_FILE", self._oConfiguration["signKey_File"])
        self._oConfiguration["signKey_Password"] = os.getenv("MARTILQ_SIGNKEY_PASSWORD", self._oConfiguration["signKey_Password"])
        self._oConfiguration["logPath"] = os.getenv("MARTILQ_LOGPATH", self._oConfiguration["logPath"])

        self.WriteLog("Configuration load processed")

    def Set(self, MartiLQ):
        self._oMartiDefinition = MartiLQ

    def Get(self):
        return self._oMartiDefinition

    def Save(self, JsonPath):
        jsonFile = open(JsonPath, "w")
        jsonFile.write(json.dumps(self._oMartiDefinition, indent=5))
        jsonFile.close()

    def Load(self, JsonPath):

        self._MartiErrorId = ""

        self.OpenLog()
        self.WriteLog("Function 'Load' parameters follow")
        self.WriteLog("Parameter: SourcePath   Value: {}".format(JsonPath))
        self.WriteLog("")

        if os.path.exists(JsonPath):
            self.WriteLog("Overwriting existing definition")
        else:
            if not os.path.exists(os.path.dirname(JsonPath)):
                self.WriteLog("Parent folder does not exist")
                raise Exception("Parent folder '{}' does not exist".format(os.path.dirname(JsonPath)))

        if not self._oMartiDefinition is None:
            self.WriteLog("Existing definition overwritten")

        jsonFile = open(JsonPath, "r")
        self._oMartiDefinition = json.load(jsonFile)
        jsonFile.close()


    def SetConfig(self, Key=None, Value=None):

        if not Key is None:
            self._oConfiguration[Key] = Value

    def GetConfig(self, Key=None):

        if not Key is None:
            return self._oConfiguration[Key] 
        else:
            return None
        
    def Close(self):
        if self._LogOpen:
            self.CloseLog()
        self._LogOpen = False

    def GetLogName(self):

        today = datetime.datetime.today() 
        dateToday = today.strftime("%Y-%m-%d") 
        
        if None ==  self._oConfiguration["logPath"] or self._oConfiguration["logPath"] == "":
            return None

        if not os.path.exists(self._oConfiguration["logPath"]):
            os.mkdir(self._oConfiguration["logPath"])
        
        logName = self.GetSoftwareName() + "_" + dateToday + ".log"

        return os.path.join(self._oConfiguration["logPath"], logName)


    def WriteLog(self, LogEntry):

        sFullPath = self.GetLogName()

        today = datetime.datetime.today() 
        dateToday = today.strftime("%Y-%m-%dT%H:%M:%S") 

        if None != sFullPath and sFullPath != "":

            if not os.path.exists(sFullPath):
                print("Log path: {}".format(sFullPath))
                filec = open(sFullPath, "a")
            else:
                filec = open(sFullPath, "a")
            
            filec.write(dateToday)
            filec.write(".")
            filec.write(LogEntry)
            filec.write("\n")
            filec.close()
        

    def OpenLog(self):

        if not self._LogOpen:
            today = datetime.datetime.today() 
            dateToday = today.strftime("%Y-%m-%d") 
            self.WriteLog("***********************************************************************************")
            self.WriteLog("*   Start of processing: {}".format(dateToday))
            self.WriteLog("***********************************************************************************")
        self._LogOpen = True

    def CloseLog(self):

        if self._LogOpen:
            today = datetime.datetime.today() 
            dateToday = today.strftime("%Y-%m-%d") 
            self.WriteLog("***********************************************************************************")
            self.WriteLog("*   End of processing: {}".format(dateToday))
            self.WriteLog("***********************************************************************************")
        self._LogOpen = False

    def NewMartiDefinition(self):

        today = datetime.datetime.today() 
        dateToday = today.strftime("%Y-%m-%d") 

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
            "contactPoint": "",
            "accessLevel": self.GetConfig("accessLevel"),
            "rights": self.GetConfig("rights"),
            "tags": [],
            "license": "",
            "state": "active",
            "batch": 1.0,
            "describedBy": "",
            "landingPage": "",
            "theme": "", 

            "resources": lresource,
            "custom": lcustom
        }

        return self._oMartiDefinition


    def NewMartiChildItem(self, SourceFolder, UrlPath=None, Recurse=True, ExtendAttributes=True, ExcludeHash=False, Filter ="*"):

        SourceFullName = os.path.abspath(SourceFolder)

        for fullName in glob.iglob(SourceFullName, recursive=Recurse):
            if os.path.isfile(fullName):
                oResource = self.NewMartiLQResource(SourcePath=fullName, UrlPath=UrlPath, ExtendAttributes=ExtendAttributes, ExcludeHash=ExcludeHash)
                self._oMartiDefinition["resources"].append(oResource)


    def GetContentType(self, SourcePath):

        ext = None

        # Some overrides
        match = str(os.path.splitext(SourcePath)[1][1:]).lower()
        if (ext is None or ext == "") and match == "csv":
            ext = "text/csv"

        if ext is None or ext == "":
            ext, _ = mimetypes.guess_type(SourcePath, strict=True)

        if ext is None or ext == "":
            match = str(os.path.splitext(SourcePath)[1][1:]).lower()
            if match == "md":
                ext = "application/markdown"

        if ext is None or ext == "":
            ext = "application/vnd.unknown." + os.path.splitext(SourcePath)[1][1:]

        return ext

    def NewMartiLQResource(self, SourcePath, UrlPath, ExcludeHash, ExtendAttributes): 

        today = datetime.datetime.today() 
        dateToday = today.strftime("%Y-%m-%dT%H:%M:%S") 

        self._MartiErrorId = ""

        self.OpenLog()
        self.WriteLog("Function 'NewMartiLQResource' parameters follow")
        self.WriteLog("Parameter: SourcePath   Value: {}".format(SourcePath))
        self.WriteLog("Parameter: UrlPath   Value: {}".format(UrlPath))
        self.WriteLog("Parameter: ExcludeHash   Value: {}".format(ExcludeHash))
        self.WriteLog("")

        if os.path.exists(SourcePath):
        
            item = os.path.basename(SourcePath)
            self.WriteLog("Define file {}".format(SourcePath))
            HashAlgorithm = self.GetConfig("hashAlgorithm")

            try:
                mtime = os.path.getmtime(SourcePath)
            except OSError:
                mtime = 0
            last_modified_date = datetime.datetime.fromtimestamp(mtime).strftime("%Y-%m-%dT%H:%M:%S")

            if ExcludeHash:
                hash = None
            else:
                hash = self.NewMartiLQHash(Algorithm=HashAlgorithm, FilePath=SourcePath, Value="", Sign=self.GetConfig("signKey_File"))

            lattribute = self.SetMartiLQResourceAttributes(SourcePath, str(os.path.splitext(SourcePath)[1][1:]).lower(), ExtendAttributes)

            oResource = { 
                "title": item.replace(os.path.splitext(SourcePath)[1], ""),
                "uid": str(uuid.uuid4()), 
                "documentName": item,
                "issuedDate": dateToday,
                "modified": last_modified_date,
                "state": self.GetConfig("state"),
                "author": self.GetConfig("author"),
                "length": os.path.getsize(SourcePath),
                "hash": hash,

                "description": "",
                "url": "",
                "version": "",
                "content-type": self.GetContentType(SourcePath),
                "compression": None,
                "encryption": None,

                "attributes": lattribute
            }

            if None != UrlPath and UrlPath != "":
                if UrlPath[len(UrlPath)-1] == "/" or UrlPath[len(UrlPath)-1] == "\\":
                    oResource["url"] = UrlPath.replace("\\", "/") + item
                else:
                    oResource["url"] = UrlPath.replace("\\", "/") + "/" + item
            
            self.WriteLog("Complete file {}".format(SourcePath))
            
        else:
            self._MartiErrorId = "MRI2001"
            message = "Document '{}' not found or is a folder".format(SourcePath)
            self.WriteLog(message + " " + self._MartiErrorId) 
            raise Exception(message)
        
        return oResource



    def NewMartiLQHash(self, Algorithm, FilePath, Value="", Sign=""):
        
        try:
            signed = False
            if Value  == "" and FilePath != "":

                if not Sign is None and not Sign == "" and not os.path.exists(Sign):
                    self.WriteLog("Sign file '{}' not found".format(Sign))
                    Sign = ""

                if Sign is None or Sign == "":

                    if Algorithm == "SHA256":
                        sha_hash = hashlib.sha256()
                        with open(FilePath,"rb") as fh:
                            for byte_block in iter(lambda: fh.read(4096),b""):
                                sha_hash.update(byte_block)
                            Value = sha_hash.hexdigest()
                    if Algorithm == "SHA512":
                        sha_hash = hashlib.sha512()
                        with open(FilePath,"rb") as fh:
                            for byte_block in iter(lambda: fh.read(4096),b""):
                                sha_hash.update(byte_block)
                            Value = sha_hash.hexdigest()
                    if Algorithm == "MD5":
                        sha_hash = hashlib.md5()
                        with open(FilePath,"rb") as fh:
                            for byte_block in iter(lambda: fh.read(4096),b""):
                                sha_hash.update(byte_block)
                            Value = sha_hash.hexdigest()
                
                else:
                    
                    import OpenSSL
                    from OpenSSL import crypto
                    import base64

                    private_key_file = open(Sign, "r")
                    privkey = private_key_file.read()
                    private_key_file.close()
                    password = self.GetConfig("sigenKey_Password")

                    if privkey.startswith('-----BEGIN '):
                        pkey = crypto.load_privatekey(crypto.FILETYPE_PEM, privkey, password.encode('utf-8'))
                    else:
                        pkey = crypto.load_pkcs12(privkey, password).get_privatekey()
                    with open(FilePath,"rb") as fh:
                        sign = OpenSSL.crypto.sign(pkey, fh.read(), Algorithm) 
                        Value = (base64.b64encode(sign)).decode('utf-8')
                        signed = True

            oHash = { 
                "algo": Algorithm,
                "value": Value,
                "signed": signed
            }

        except Exception as e:
            self.WriteLog("Hash error for file {}: {}".format(FilePath, str(e)))
            raise e

        return oHash
        

    def NewEncryption(self, Algorithm, Value):

        oEncryption = { 
            "algo": Algorithm,
            "value": Value
        }

        return oEncryption


    def SetMartiAttribute(self, Attributes, ACategory, AName, AFunction, Comparison, Value):

        matched = False
    
        for attr in Attributes:

            if attr["category"] == ACategory and attr["name"] == AName and attr["function"] == AFunction:
                matched = True
                attr["comparison"] = Comparison
                attr["value"] = Value
            

        if not matched:
            
            oAttribute = {
                "category": ACategory,
                "name": AName,
                "function": AFunction,
                "comparison": Comparison,
                "value": Value
            }

            Attributes.append(oAttribute)
        

        return Attributes



    def NewDefaultCsvAttributes(self):
        
        lattribute = []

        oAttribute = {
            "category": "dataset",
            "name": "header",
            "function": "count",
            "comparison": "NA",
            "value": 1
        }
        lattribute.append(oAttribute)
        
        oAttribute = {
            "category": "dataset",
            "name": "footer",
            "function": "count",
            "comparison": "NA",
            "value":  0
        }
        lattribute.append(oAttribute)
        
        oAttribute = {
            "category": "format",
            "name": "separator",
            "function": "value",
            "comparison": "NA",
            "value": ","
        }
        lattribute.append(oAttribute)
        
        oAttribute = {
            "category": "format",
            "name": "columns",
            "function": "value",
            "comparison": "NA",
            "value": ","
        }
        lattribute.append(oAttribute)

        oAttribute = {
            "category": "dataset",
            "name": "records",
            "function": "count",
            "comparison": "NA",
            "value": 0
        }
        lattribute.append(oAttribute)
        
        oAttribute = {
            "category": "dataset",
            "name": "columns",
            "function": "count",
            "comparison": "NA",
            "value": 0
        }
        lattribute.append(oAttribute)
        
        return lattribute



    def NewDefaultJsonAttributes(self):
        
        lattribute = []
        
        oAttribute = {
            "category": "format",
            "name": "list",
            "function": "offset",
            "comparison": "NA",
            "value": ","
        }
        lattribute.append(oAttribute)
        
        oAttribute = {
            "category": "format",
            "name": "columns",
            "function": "value",
            "comparison": "NA",
            "value": ","
        }
        lattribute.append(oAttribute)

        oAttribute = {
            "category": "dataset",
            "name": "records",
            "function": "count",
            "comparison": "NA",
            "value": 0
        }    
        lattribute.append(oAttribute)
        
        oAttribute = {
            "category": "dataset",
            "name": "columns",
            "function": "count",
            "comparison": "NA",
            "value": 0
        }
        lattribute.append(oAttribute)
        
        return lattribute


    def NewDefaultZipAttributes(self, CompressionType = "ZIP",Encryption = ""):
        
        lattribute = []
        
        oAttribute = {
            "category": "format",
            "name": "compression",
            "function": "algo",
            "comparison": "NA",
            "value": CompressionType
        }
        lattribute.append(oAttribute)
        
        oAttribute = {
            "category": "format",
            "name": "encryption",
            "function": "algo",
            "comparison": "NA",
            "value": Encryption
        }
        lattribute.append(oAttribute)

        oAttribute = {
            "category": "dataset",
            "name": "files",
            "function": "count",
            "comparison": "NA",
            "value": 0
        }    
        lattribute.append(oAttribute)
            
        return lattribute


    def SetAttributeValueString(self, Attributes, Category, Key, Function, Value, Comparison="EQ"):

        for item in Attributes:
        
            if item["category"] == Category and item["name"] == Key and item["function"] == Function:
                if item["comparison"] == "NA" or item["comparison"] == Comparison:
                    item["comparison"] = Comparison
                    item["value"] = Value
                    return

        # Add the attribute    
        oAttribute = {
            "category": Category,
            "name": Key,
            "function": Function,
            "comparison": Comparison,
            "value": Value
        }    

        Attributes.append(oAttribute)
        
        return


    def SetAttributeValueNumber(self, Attributes, Category, Key, Function, Value, Comparison = "EQ"):

        for item in Attributes:

            if item["category"] == Category and item["name"] == Key and item["function"] == Function:
                if item["comparison"] == "NA" or item["comparison"] == Comparison:
                    item["comparison"] = Comparison
                    item["value"] = Value
                    return


        # Add the attribute    
        oAttribute = {
            "category": Category,
            "name": Key,
            "function": Function,
            "comparison": Comparison,
            "value": Value
        }    

        Attributes.append(oAttribute)

        return


    def SetMartiLQResourceAttributes(self, PathFile, FileType, ExtendedAttributes):

        lattribute = None

        if FileType == "csv":
            lattribute = self.NewDefaultCsvAttributes()

            if ExtendedAttributes:
                delimiter = ","
                rowCount = 0
                colCount = 0

                #TODO check import
                import csv

                with open(PathFile, 'r') as csvfile:
                    datareader = csv.reader(csvfile, delimiter=",")
                    for row in datareader:
                        if len(row) > colCount:
                            colCount = len(row)
                        rowCount = rowCount + 1

                self.SetAttributeValueNumber(lattribute, Category="dataset", Key="records", Function="count", Value=rowCount)
                self.SetAttributeValueNumber(lattribute, Category="dataset", Key="columns", Function="count", Value=colCount)


        if FileType == "txt":
            lattribute = self.NewDefaultCsvAttributes()

            if ExtendedAttributes:
                rowCount = 0
                colCount = 0

                #TODO check import
                import csv

                with open(PathFile, 'r') as csvfile:
                    datareader = csv.reader(csvfile, delimiter="\t")
                    for row in datareader:
                        if len(row) > colCount:
                            colCount = len(row)
                        rowCount = rowCount + 1

                self.SetAttributeValueNumber(lattribute, Category="dataset", Key="records", Function="count", Value=rowCount)
                self.SetAttributeValueNumber(lattribute, Category="dataset", Key="columns", Function="count", Value=colCount)


        if FileType == "json":
            lattribute = self.NewDefaultJsonAttributes()
        

        if FileType == "zip":
            lattribute = self.NewDefaultZipAttributes("ZIP")
            if ExtendedAttributes:
                self.SetAttributeValueNumber(lattribute, "dataset", "files", "count", 0, Comparison="NA")

        if FileType == "7z":
            lattribute = self.NewDefaultZipAttributes("7Z")
            if ExtendedAttributes:
                self.SetAttributeValueNumber(lattribute, "dataset", "files", "count", 0, Comparison="NA")

        if lattribute == None:
            lattribute = []
        

        return lattribute

    def FtpPull(self, host, file_remote, file_local):

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


    def Fetch(self, TargetPath):

        if TargetPath is None or TargetPath == "":
            self.WriteLog("Target path is missing from fetch")
            raise Exception("Target path is missing from fetch")

        if self._oMartiDefinition is None:
            self.WriteLog("No defintion loaded")
            raise Exception("No defintion loaded")

        if len(self._oMartiDefinition["resources"]) < 1:
            self.WriteLog("No resources in defintion")
            raise Exception("No resources in defintion")

        fetched_files = [] 
        fetch_error = []

        for resource in self._oMartiDefinition["resources"]:

            if not resource["url"] is None and not resource["url"] == "":
                method = str(resource["url"].split(":", 2)[0]).lower()
                #print("Method of fetch {} for {}".format(method, resource["url"]))
                matched = False
                if method == "ftp":
                    matched = True
                    parts = resource["url"].split("/", 3)
                    host = parts[2]
                    file_remote = parts[3]
                    self.FtpPull(host, file_remote, os.path.join(TargetPath, resource["documentName"]))
                    fetched_files.append(os.path.join(TargetPath, resource["documentName"]))

                if method == "http" or method == "https":
                    matched = True
                    response = requests.get(resource["url"])
                    if not response.status_code == 200:
                        self.WriteLog("HTP fetch failed with code {} for '{}'".format(response.status_code, resource["url"]))
                        print("HTP fetch failed with code {} for '{}'".format(response.status_code, resource["url"]))
                        fetch_error.append(resource["url"])
                    else:
                        with open(os.path.join(TargetPath, resource["documentName"]),'wb') as fh:
                            fh.write(response.content)
                        fetched_files.append(os.path.join(TargetPath, resource["documentName"]))

                if method == "file":
                    pass

                if not matched:
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

        self.OpenLog()
        self.WriteLog("Function 'TestMartiDefinition' parameters follow")
        self.WriteLog("Parameter: SourcePath   Value: {}".format(SourcePath))
        self.WriteLog("")

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

        otest = ["", "Batch", "Resource count", (len(self._oMartiDefinition["resources"]) == len(lq["resources"])), len(self._oMartiDefinition["resources"]), len(lq["resources"]) ]
        oTestResults.append(otest)

        for resource in self._oMartiDefinition["resources"]:

            for retarget in lq["resources"]:
                if resource["documentName"] == retarget["documentName"]:

                    if retarget["hash"]["signed"]:
                        # Need to verify the hash
                        if Sign is None:
                            Sign = self.GetConfig("signKey_file")

                        if Sign is None:
                            self.WriteLog("No Sign Key specified so Hash check cannot be performed for signed content")
                        else:
                            try:
                                import OpenSSL
                                from OpenSSL import crypto
                                import base64
                            except ImportError:
                                self.WriteLog("Import error in signed verification")

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
                                self.WriteLog("Error in verification for {}".format(resource["documentName"]))
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

        self.WriteLog("TestMartiDefinition function completed with {} errors".format(testError))

        return oTestResults, testError
