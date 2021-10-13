

import ftplib
from genericpath import getsize 
import os
import uuid
import json
import datetime
import getpass
import hashlib


class martiLQ:

    gLogPathName = ""
    gSoftwareVersion = "0.0.1"
    gdefault_metaFile = "##marti##.mri"

    gMartiErrorId = ""
    gLogOpen = False

    oMartiDefinition = None

    def __init__(self):
        self.gLogOpen = False

    def Get(self):
        return self.oMartiDefinition

    def Close(self):
        if self.gLogOpen:
            self.CloseLog()
        self.gLogOpen = False

    def GetSoftwareName(self):
        return "MARTILQREFERENCE"

    def GetLogName(self):

        today = datetime.datetime.today() 
        dateToday = today.strftime("%Y-%m-%d") 
        
        if None ==  self.gLogPathName or self.gLogPathName == "":
            return None

        if not os.path.exists(self.gLogPathName):
            os.mkdir(self.gLogPathName)
        
        logName = self.GetSoftwareName() + "_" + dateToday + ".log"

        return os.path.join(self.gLogPathName, logName)


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

        if not self.gLogOpen:
            today = datetime.datetime.today() 
            dateToday = today.strftime("%Y-%m-%d") 
            self.WriteLog("***********************************************************************************")
            self.WriteLog("*   Start of processing: {}".format(dateToday))
            self.WriteLog("***********************************************************************************")
        self.gLogOpen = True

    def CloseLog(self):

        if self.gLogOpen:
            today = datetime.datetime.today() 
            dateToday = today.strftime("%Y-%m-%d") 
            self.WriteLog("***********************************************************************************")
            self.WriteLog("*   End of processing: {}".format(dateToday))
            self.WriteLog("***********************************************************************************")
        self.gLogOpen = False

    def NewMartiDefinition(self):

        today = datetime.datetime.today() 
        dateToday = today.strftime("%Y-%m-%d") 

        oSoftware = {
            "extension": "software",
            "softwareName": self.GetSoftwareName(),
            "author": "Meerkat@merebox.com",
            "version": self.gSoftwareVersion
        }

        publisher = getpass.getuser()

        lcustom = []
        lcustom.append(oSoftware)

        lresource = []

        self.oMartiDefinition = {
            "title": "",
            "uid": str(uuid.uuid4()),
            "resources": lresource,

            "description": "",
            "modified": dateToday,
            "tags": ["document", self.GetSoftwareName()],
            "publisher": publisher,
            "contactPoint": "",
            "accessLevel": "Confidential",
            "rights": "Restricted",
            "license": "",
            "state": "active",

            "describedBy": "",
            "landingPage": "",
            "theme": "", 

            "custom": lcustom
        }

        return self.oMartiDefinition



    def NewMartiResource(self, SourcePath, UrlPath, ExcludeHash, ExtendAttributes, LogPath): 

        today = datetime.datetime.today() 
        dateToday = today.strftime("%Y-%m-%d") 

        self.gMartiErrorId = ""
        self.gLogPathName = LogPath

        self.OpenLog()
        self.WriteLog("Function 'NewMartiResource' parameters follow")
        self.WriteLog("Parameter: SourcePath   Value: {}".format(SourcePath))
        self.WriteLog("Parameter: UrlPath   Value: {}".format(UrlPath))
        self.WriteLog("Parameter: ExcludeHash   Value: {}".format(ExcludeHash))
        self.WriteLog("")

        if os.path.exists(SourcePath):
        
            item = os.path.basename(SourcePath)
            self.WriteLog("Define file {}".format(SourcePath))

            try:
                mtime = os.path.getmtime(SourcePath)
            except OSError:
                mtime = 0
            last_modified_date = datetime.datetime.fromtimestamp(mtime).strftime("%Y-%m-%d %H:%M:%S")

            if ExcludeHash:
                hash = None
            else:
                hash = self.NewMartiHash(Algorithm="SHA256", FilePath=SourcePath, Value="")

            lattribute = self.SetMartiResourceAttributes(SourcePath, os.path.splitext(SourcePath)[1][1:], ExtendAttributes)

            oResource = { 
                "title": item.replace(os.path.splitext(SourcePath)[1], ""),
                "uid": str(uuid.uuid4()), 
                "documentName": item,
                "issuedDate": dateToday,
                "modified": last_modified_date,
                "state": "active",
                "author": "",
                "length": os.path.getsize(SourcePath),
                "hash": hash,

                "description": "",
                "url": "",
                "version": self.gSoftwareVersion,
                "format": os.path.splitext(SourcePath)[1][1:],
                "compression": None,
                "encryption": None,

                "attributes": lattribute
            }

            if None != UrlPath and UrlPath != "":
                if UrlPath[UrlPath.Length-1] == "/" or UrlPath[UrlPath.Length-1] == "\\":
                    oResource["url"] = UrlPath.replace("\\", "/") + item
                else:
                    oResource["url"] = UrlPath.replace("\\", "/") + "/" + item
            
            self.WriteLog("Complete file {}".format(SourcePath))
            
        else:
            self.gMartiErrorId = "MRI2001"
            message = "Document '{}' not found or is a folder".format(SourcePath)
            self.WriteLog(message + " " + self.gMartiErrorId) 
            raise Exception(message)
        
        return oResource



    def NewMartiHash(self, Algorithm, FilePath, Value=""):
        
        if Value  == "" and FilePath != "":
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

        oHash = { 
            "algo": Algorithm,
            "value": Value
        }

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
            "function": "algorithm",
            "comparison": "NA",
            "value": CompressionType
        }
        lattribute.append(oAttribute)
        
        oAttribute = {
            "category": "format",
            "name": "encryption",
            "function": "algorithm",
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


    def SetAttributeValueString(self, Attributes,Category,Key,Function,Value,Comparison = "EQ"):

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


    def SetAttributeValueNumber(self, Attributes,Category,Key,Function,Value,Comparison = "EQ"):

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


    def SetMartiResourceAttributes(self, Path,FileType,ExtendedAttributes):

        lattribute = None

        if FileType == "csv":
            lattribute = self.NewDefaultCsvAttributes()

            if ExtendedAttributes:
                delimiter = ","
                rowCount = 0
                colCount = 0
                # csvData = Import-Csv $Path -Delimiter $delimiter 
                # foreach ($datum in $csvData) {
                #     $cc = (Get-Member -InputObject $datum -type NoteProperty).count
                #     if ($colCount -lt $cc) {
                #         $colCount = $cc
                #     }
                #     $rowCount += 1
                # }
                self.SetAttributeValueNumber(lattribute, "records", "dataset", "count", rowCount)
                self.SetAttributeValueNumber(lattribute, "columns", "dataset", "count", colCount)


        if FileType == "txt":
            lattribute = self.NewDefaultCsvAttributes()

            if ExtendedAttributes:
                delimiter = "`t"
                rowCount = 0
                colCount = 0
                # $csvData = Import-Csv $Path -Delimiter $delimiter 
                # foreach ($datum in $csvData) {
                #     $cc = (Get-Member -InputObject $datum -type NoteProperty).count
                #     if ($colCount -lt $cc) {
                #         $colCount = $cc
                #     }
                #     $rowCount += 1
                # }
                self.SetAttributeValueNumber(lattribute, "records", "dataset", "count", rowCount)
                self.SetAttributeValueNumber(lattribute, "columns", "dataset", "count", colCount)


        if FileType == "json":
            lattribute = self.NewDefaultJsonAttributes()
        

        if FileType == "zip":
            lattribute = self.NewDefaultZipAttributes("ZIP")
            if ExtendedAttributes:
                # $shell = New-Object -Com Shell.Application
                # $zipFile = $shell.NameSpace($Path)
                # $items = $zipFile.Items()
                self.SetAttributeValueNumber(lattribute, "files", "dataset", "count", -1)

        if FileType == "7z":
            lattribute = self.NewDefaultZipAttributes("7Z")

        if lattribute == None:
            lattribute = []
        

        return lattribute

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

    def TestMartiDefinition(self, oMarti, LQSourcePath, LogPath =""):

        self.gMartiErrorId = ""
        self.gLogPathName = LogPath

        self.OpenLog()
        self.WriteLog("Function 'TestMartiDefinition' parameters follow")
        self.WriteLog("Parameter: oMarti         Value: {}".format(oMarti))
        self.WriteLog("Parameter: LQSourcePath   Value: {}".format(LQSourcePath))
        self.WriteLog("")

        if oMarti is None:
            oMarti = self.oMartiDefinition

        if oMarti is None:
            pass

        if not os.path.exists(LQSourcePath):
            pass    

        jsonFile = open(LQSourcePath, "r")
        lq = json.load(jsonFile)
        jsonFile.close()

        testError = False
        oTestResults = []

        otest = ["ResourceName", "Level", "Metric", "Matches", "LocalCalculation", "SuppliedValue" ]
        oTestResults.append(otest)

        otest = ["", "Batch", "Resource count", (len(oMarti["resources"]) == len(lq["resources"])), len(oMarti["resources"]), len(lq["resources"]) ]
        oTestResults.append(otest)

        for resource in oMarti["resources"]:

            for retarget in lq["resources"]:
                if resource["documentName"] == retarget["documentName"]:

                    testError = testError or resource["hash"]["value"] != retarget["hash"]["value"]
                    otest = [resource["documentName"], "Resource", "Hash", (resource["hash"]["value"] == retarget["hash"]["value"]), resource["hash"]["value"], retarget["hash"]["value"] ]
                    oTestResults.append(otest)

                    testError = testError or resource["length"] != retarget["length"]
                    otest = [resource["documentName"], "Resource", "Length", (resource["length"] == retarget["length"]), resource["length"], retarget["length"] ]
                    oTestResults.append(otest)

                    errorAttrCount = self.TestAttributeDefinition(oTestResults, resource["documentName"], resource["attributes"], retarget["attributes"])

                    if errorAttrCount > 0:
                        testError = True

                    break

        return oTestResults, testError
