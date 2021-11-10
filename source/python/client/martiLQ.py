

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
            "softwareAuthor": "Meerkat@merebox.com",
            "softwareVersion": self._SoftwareVersion,

            "logPath": "./logs/",
            "dateFormat": "2006-01-02",
            "dateTimeFormat": "2006-01-02T15:04:05+0100",
            "dataPath": "",
            "temPath": "",

            "tags": None,
            "publisher": "",
            "contactPoint": "",
            "license": "",
            "accessLevel": "Confidential",
            "rights": "Restricted",
            "batch": 1.0000,
            "batchInc": 0.0001,
            "theme": "",

            "author": "",
            "title": "{{documentName}}",
            "state": "active",
            "expires": "m:7:0:0",
            "version": "1.0",
            "urlPrefix": "",
            "encoding": "",
            "compression": "",
            "encryption": "",
            "describedBy": "",
            "landingPage": "",

            "hashAlgorithm": "SHA256",
            "signKey_File": None,
            "signKey_Password": None,

            "proxy": None,
            "proxy_User": None,
            "proxy_Credential": None,

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

        if config_object.has_section("General"):
            items = config_object["General"]
            if not items is None:
                config_attr = ["logPath", "tempPath", "dataPath", "dateFomat", "dateTimeFormat"]
                for x in config_attr:
                    try:
                        if not items[x] is None and not items[x] == "":
                            self._oConfiguration[x] = items[x]
                    except Exception:
                        self.WriteLog("Error in config ignored: " + x)

        if config_object.has_section("MartiLQ"):
            items = config_object["MartiLQ"]
            if not items is None:
                config_attr = ["rights", "accessLevel", "tags","publisher","batch","theme", "license","contactPoint"]
                for x in config_attr:
                    try:
                        if not items[x] is None and not items[x] == "":
                            self._oConfiguration[x] = items[x]
                    except Exception:
                        self.WriteLog("Error in config ignored: " + x)

        if config_object.has_section("Resources"):
            items = config_object["Resources"]
            if not items is None:
                config_attr = ["state", "author", "title", "expires","encoding", "version", "urlPrefix", "compression", "encryption", "describedBy", "landingPage"]
                for x in config_attr:
                    try:
                        if not items[x] is None and not items[x] == "":
                            self._oConfiguration[x] = items[x]
                    except Exception:
                        self.WriteLog("Error in config ignored: " + x)

        if config_object.has_section("Hash"):
            items = config_object["Hash"]    
            if not items is None:
                config_attr = ["hashAlgorithm", "signKey_File", "signKey_Password"]
                for x in config_attr:
                    try:
                        if not items[x] is None and not items[x] == "":
                            self._oConfiguration[x] = items[x]
                    except Exception:
                        self.WriteLog("Error in config ignored: " + x)

        if config_object.has_section("Network"):
            items = config_object["Network"]    
            if not items is None:
                config_attr = ["proxy", "proxy_User", "proxy_Credential"]
                for x in config_attr:
                    try:
                        if not items[x] is None and not items[x] == "":
                            self._oConfiguration[x] = items[x]
                    except Exception:
                        self.WriteLog("Error in config ignored: " + x)

        # Now check environmental values
        self._oConfiguration["signKey_File"] = os.getenv("MARTILQ_SIGNKEY_FILE", self._oConfiguration["signKey_File"])
        self._oConfiguration["signKey_Password"] = os.getenv("MARTILQ_SIGNKEY_PASSWORD", self._oConfiguration["signKey_Password"])
        self._oConfiguration["logPath"] = os.getenv("MARTILQ_LOGPATH", self._oConfiguration["logPath"])

        self.WriteLog("Configuration load processed")


    def SaveConfig(self, ConfigPath=None):

        if not os.path.isfile(ConfigPath):
            cfgfile = open(ConfigPath, 'w')

            config_object = ConfigParser()

            config_object.add_section("General")
            config_attr = ["logPath", "tempPath", "dataPath", "dateFomat", "dateTimeFormat"]
            for x in config_attr:
                try:
                    if x in self._oConfiguration:
                        if self._oConfiguration[x] is None:
                            config_object.set("General", x, "")
                        elif type(self._oConfiguration[x]) is float or type(self._oConfiguration[x]) is int:
                            config_object.set("General", x, str(self._oConfiguration[x]))
                        else:
                            config_object.set("General", x, self._oConfiguration[x])
                except Exception as e:
                    self.WriteLog("Error in config ignored: " + x + " = " + str(e))

            config_object.add_section("MartiLQ")
            config_attr = ["rights", "accessLevel", "tags","publisher","batch","theme", "license","contactPoint"]
            for x in config_attr:
                try:
                    if x in self._oConfiguration:
                        if self._oConfiguration[x] is None:
                            config_object.set("MartiLQ", x, "")
                        elif type(self._oConfiguration[x]) is float or type(self._oConfiguration[x]) is int:
                            config_object.set("MartiLQ", x, str(self._oConfiguration[x]))
                        else:
                            config_object.set("MartiLQ", x, self._oConfiguration[x])
                except Exception as e:
                    self.WriteLog("Error in config ignored: " + x + " = " + str(e))

            config_object.add_section("Resources")
            config_attr = ["state", "author", "title", "expires","encoding", "version", "urlPrefix", "compression", "encryption", "describedBy", "landingPage"]
            for x in config_attr:
                try:
                    if x in self._oConfiguration:
                        if self._oConfiguration[x] is None:
                            config_object.set("Resources", x, "")
                        elif type(self._oConfiguration[x]) is float or type(self._oConfiguration[x]) is int:
                            config_object.set("Resources", x, str(self._oConfiguration[x]))
                        else:
                            config_object.set("Resources", x, self._oConfiguration[x])
                except Exception as e:
                    self.WriteLog("Error in config ignored: " + x + " = " + str(e))


            config_object.add_section("Hash")
            config_attr = ["hashAlgorithm", "signKey_File", "signKey_Password"]
            for x in config_attr:
                try:
                    if x in self._oConfiguration:
                        if self._oConfiguration[x] is None:
                            config_object.set("Hash", x, "")
                        elif type(self._oConfiguration[x]) is float or type(self._oConfiguration[x]) is int:
                            config_object.set("Hash", x, str(self._oConfiguration[x]))
                        else:
                            config_object.set("Hash", x, self._oConfiguration[x])
                except Exception as e:
                    self.WriteLog("Error in config ignored: " + x + " = " + str(e))

            config_object.add_section("Network")
            config_attr = ["proxy", "proxy_User", "proxy_Credential"]
            for x in config_attr:
                try:
                    if x in self._oConfiguration:
                        if self._oConfiguration[x] is None:
                            config_object.set("Network", x, "")
                        elif type(self._oConfiguration[x]) is float or type(self._oConfiguration[x]) is int:
                            config_object.set("Network", x, str(self._oConfiguration[x]))
                        else:
                            config_object.set("Hash", x, self._oConfiguration[x])
                except Exception as e:
                    self.WriteLog("Error in config ignored: " + x + " = " + str(e))

            config_object.add_section("Custom_Spatial")
            config_attr = ["enabled", "country", "region", "town"]
            for x in config_attr:
                config_object.set("Custom_Spatial", x, "")

            config_object.add_section("Custom_Temporal")
            config_attr = ["enabled", "businessDate", "runDate"]
            for x in config_attr:
                config_object.set("Custom_Temporal", x, "")

            config_object.write(cfgfile)
            cfgfile.close()

            self.WriteLog("Configuration save processed")
            return True

        else:
            self.WriteLog("Configuration file exists and new not saved")
            return False

    def ExpireDate(self, sourcePath): # time.Time 

        expires = datetime.datetime.today() 

        lExpires = self._oConfiguration["expires"].split(":")
        if len(lExpires) != 4 and len(lExpires) != 7:
            raise Exception("Expires value '"+ self._oConfiguration["expires"] +"' is invalid")

        base = lExpires[0]
        if sourcePath == "" or base == "m":
            base = "t"

        modified = datetime.datetime.today() 
        if base == "m":
            try:
                mtime = os.path.getmtime(sourcePath)
            except OSError:
                mtime = 0
            modified = datetime.datetime.fromtimestamp(mtime) 

        lExpire = [0, 0, 0]
        lExpire[0] = int(lExpires[1])
        lExpire[1] = int(lExpires[2])
        lExpire[2] = int(lExpires[3])

        if len(lExpires) > 4:
            lExpireD = [0,0,0]
            lExpireD[0] = int(lExpires[4])
            lExpireD[1] = int(lExpires[5])
            lExpireD[2] = int(lExpires[6])
            
            if base == "m":
                expires = modified + datetime.timedelta(years=lExpire[0],months=lExpire[1],days=lExpire[2],hours=lExpireD[0], minutes=lExpireD[1], seconds=lExpireD[2])
            elif base == "r":
                expires = self._oConfiguration.temporal.RunDate + datetime.timedelta(years=lExpire[0],months=lExpire[1],days=lExpire[2],hours=lExpireD[0], minutes=lExpireD[1], seconds=lExpireD[2])
            elif base == "b":
                expires = self._oConfiguration.temporal.BusinessDate + datetime.timedelta(years=lExpire[0],months=lExpire[1],days=lExpire[2],hours=lExpireD[0], minutes=lExpireD[1], seconds=lExpireD[2])
            #elif base == "t":
            #    fallthrough
            else:			
                expires = datetime.datetime.today() + datetime.timedelta(years=lExpire[0],months=lExpire[1],days=lExpire[2],hours=lExpireD[0], minutes=lExpireD[1], seconds=lExpireD[2])
        else:
            if base == "m":
                expires = modified + datetime.timedelta(years=lExpire[0],months=lExpire[1],days=lExpire[2])
            elif base == "r":
                expires = self._oConfiguration.temporal.RunDate + datetime.timedelta(years=lExpire[0],months=lExpire[1],days=lExpire[2])
            elif base == "b":
                expires = self._oConfiguration.temporal.BusinessDate + datetime.timedelta(years=lExpire[0],months=lExpire[1],days=lExpire[2])
            #elif base == "t":
            #    fallthrough
            else:			
                expires = datetime.datetime.today() + datetime.timedelta(days=lExpire[2])
                expires = expires.replace(year=expires.year+lExpire[0])
                if expires.month+lExpire[1] > 12:
                    expires = expires.replace(year=expires.year+1)
                    expires = expires.replace(month=expires.month+lExpire[1]-12)
                else:
                    expires = expires.replace(month=expires.month+lExpire[1])
                    
        return expires



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

        self.OpenLog()
        self.WriteLog("Function 'Load' parameters follow")
        self.WriteLog("Parameter: SourcePath   Value: {}".format(JsonPath))
        self.WriteLog("")

        if not os.path.exists(JsonPath):
            self.WriteLog("martiLQ document file '"+ JsonPath +"' does not exist")
            raise Exception("martiLQ document file '{}' does not exist".format(JsonPath))

        if not self._oMartiDefinition is None:
            self.WriteLog("Existing definition overwritten in memory")

        jsonFile = open(JsonPath, "r")
        self._oMartiDefinition = json.load(jsonFile)
        jsonFile.close()


    def SetConfig(self, Key=None, Value=None):

        if not Key is None:
            self._oConfiguration[Key] = Value

    def GetConfig(self, Key=None):

        try:
            if not Key is None:
                if Key == "tags":
                    return self._oConfiguration[Key].split(",")     
                return self._oConfiguration[Key] 
            else:
                return None
        except Exception:
            self.WriteLog("Error in getting config: "+ Key)
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
        dateToday = today.strftime("%Y-%m-%dT%H:%M:%S") 

        publisher = self.GetConfig("publisher")
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
            "contactPoint": self.GetConfig("contactPoint"),
            "accessLevel": self.GetConfig("accessLevel"),
            "rights": self.GetConfig("rights"),
            "tags": self.GetConfig("tags"),
            "license": self.GetConfig("license"),
            "state": self.GetConfig("state"),
            "batch": self.GetConfig("batch"),
            "describedBy": self.GetConfig("describedBy"),
            "landingPage": self.GetConfig("landingPage"),
            "theme": self.GetConfig("theme"), 

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
                    self.WriteLog("MartiLQ defintion resources not initialised") 
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

            sTitle =  self.GetConfig("title")
            if sTitle == "{{documentName}}":
                sTitle = item.replace(os.path.splitext(SourcePath)[1], "")
            if sTitle == "{{documentName.ext}}":
                sTitle = item

            oResource = { 
                "title": sTitle,
                "uid": str(uuid.uuid4()), 
                "documentName": item,
                "issueDate": dateToday,
                "modified": last_modified_date,
                "expires": self.ExpireDate(item).strftime("%Y-%m-%dT%H:%M:%S%z"),
                "state": self.GetConfig("state"),
                "author": self.GetConfig("author"),
                "length": os.path.getsize(SourcePath),
                "hash": hash,

                "description": "",
                "url": self.GetConfig("urlPrefix"),
                "version": self.GetConfig("version"),
                "content-type": self.GetContentType(SourcePath),
                "encoding": self.GetConfig("encoding"),
                "compression": self.GetConfig("compression"),
                "encryption": self.GetConfig("encryption"),
                "describedBy": self.GetConfig("describedBy"),
                "landingPage": self.GetConfig("landingPage"),
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

        for attr in Attributes:

            if attr["category"] == ACategory and attr["name"] == AName and attr["function"] == AFunction:
                attr["comparison"] = Comparison
                attr["value"] = Value
                return Attributes
            

            oAttribute = {
                "category": ACategory,
                "name": AName,
                "function": AFunction,
                "comparison": Comparison,
                "value": Value
            }

            Attributes.append(oAttribute)
        

        return Attributes


    def NewDefaultAnyAttributes(self, anyFileName):
        

        records = 0
        anyFile = open(anyFileName,'r')
        while True:
            next_line = anyFile.readline()
            if not next_line:
                break;
            records = records + 1

        anyFile.close()

        lattribute = []
        
        oAttribute = {
            "category": "dataset",
            "name": "records",
            "function": "count",
            "comparison": "EQ",
            "value": records
        }
        lattribute.append(oAttribute)
                
        return lattribute



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
        matched = False

        if FileType == "csv":
            matched = True
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
            matched = True
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
            matched = True
            lattribute = self.NewDefaultJsonAttributes()
        

        if FileType == "zip":
            matched = True
            lattribute = self.NewDefaultZipAttributes("ZIP")
            if ExtendedAttributes:
                self.SetAttributeValueNumber(lattribute, "dataset", "files", "count", 0, Comparison="NA")

        if FileType == "7z":
            matched = True
            lattribute = self.NewDefaultZipAttributes("7Z")
            if ExtendedAttributes:
                self.SetAttributeValueNumber(lattribute, "dataset", "files", "count", 0, Comparison="NA")

        if not matched:
            lattribute = self.NewDefaultAnyAttributes(PathFile)

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
                        print('Download failed for: '+file_remote)
                        self.WriteLog('Download failed for: '+file_remote)
                        if os.path.isfile(file_local):
                            os.remove(file_local)          

            except ftplib.all_errors as e:
                self.WriteLog('FTP error:', e) 
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

                if method == "ftp":
                    parts = resource["url"].split("/", 3)
                    host = parts[2]
                    file_remote = parts[3]
                    self.FtpPull(host, file_remote, os.path.join(TargetPath, resource["documentName"]))
                    fetched_files.append(os.path.join(TargetPath, resource["documentName"]))

                elif method == "http" or method == "https":
                    response = requests.get(resource["url"])
                    if not response.status_code == 200:
                        self.WriteLog("HTTP fetch failed with code {} for '{}'".format(response.status_code, resource["url"]))
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

        otest = ["@", "Batch", "Resource count", (len(self._oMartiDefinition["resources"]) == len(lq["resources"])), len(self._oMartiDefinition["resources"]), len(lq["resources"]) ]
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
    oMarti._oConfiguration["proxy"]=Proxy
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
        m.OpenLog()
        if m.SaveConfig(args.configPath):
            print("Saved martiLQ configuration: " + args.configPath)
        else:
            print("Error in saving configuration file")
        m.CloseLog()


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
        m.CloseLog()
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
