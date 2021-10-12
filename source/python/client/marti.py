

import ftplib
from genericpath import getsize 
import os
import uuid
import json
import datetime
import getpass
import hashlib

global_LogPathName = ""
global_SoftwareVersion = "0.0.1"
global_default_metaFile = "##marti##.mri"

global_MartiErrorId = ""


def GetSoftwareName():
    return "MARTIREFERENCE"


def GetLogName():

    today = datetime.datetime.today() 
    dateToday = today.strftime("%Y-%m-%d") 
    
    if None ==  global_LogPathName or global_LogPathName == "":
        return None

    if not os.path.exists(global_LogPathName):
        os.mkdir(global_LogPathName)
    
    logName = GetSoftwareName() + "_" + dateToday + ".log"

    return os.path.join(global_LogPathName, logName)


def WriteLog(LogEntry):

    sFullPath = GetLogName()

    today = datetime.datetime.today() 
    dateToday = today.strftime("%Y-%m-%d") 

    if None != sFullPath and sFullPath != "":

        if not os.path.exists(sFullPath):
            print("Log path: $sFullPath")
            filec = open(sFullPath, "a")
        else:
            filec = open(sFullPath, "a")
        
        filec.write(dateToday)
        filec.write(".")
        filec.write(LogEntry)
        filec.write("\n")
        filec.close()
    

def OpenLog():

    today = datetime.datetime.today() 
    dateToday = today.strftime("%Y-%m-%d") 
    WriteLog("***********************************************************************************")
    WriteLog("*   Start of processing: {}".format(dateToday))
    WriteLog("***********************************************************************************")


def CloseLog():

    today = datetime.datetime.today() 
    dateToday = today.strftime("%Y-%m-%d") 
    WriteLog("***********************************************************************************")
    WriteLog("*   End of processing: {}".format(dateToday))
    WriteLog("***********************************************************************************")


def NewMartiDefinition():

    today = datetime.datetime.today() 
    dateToday = today.strftime("%Y-%m-%d") 

    oSoftware = {
        "extension": "software",
        "softwareName": GetSoftwareName(),
        "author": "Meerkat@merebox.com",
        "version": global_SoftwareVersion
    }

    publisher = getpass.getuser()

    lcustom = []
    lcustom.append(oSoftware)

    lresource = []

    oMarti = {
        "title": "",
        "uid": str(uuid.uuid4()),
        "resources": lresource,

        "description": "",
        "modified": dateToday,
        "tags": ["document", "marti"],
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

    return oMarti



def NewMartiResource(SourcePath, UrlPath, ExcludeHash, ExtendAttributes, LogPath): 

    today = datetime.datetime.today() 
    dateToday = today.strftime("%Y-%m-%d") 

    global global_MartiErrorId
    global_MartiErrorId = ""
    global global_LogPathName
    global_LogPathName = LogPath

    OpenLog()
    WriteLog("Function 'NewMartiResource' parameters follow")
    WriteLog("Parameter: SourcePath   Value: {}".format(SourcePath))
    WriteLog("Parameter: UrlPath   Value: {}".format(UrlPath))
    WriteLog("Parameter: ExcludeHash   Value: {}".format(ExcludeHash))
    WriteLog("")

    if os.path.exists(SourcePath):
       
        item = os.path.basename(SourcePath)

        WriteLog("Define file {}".format(SourcePath))

        try:
            mtime = os.path.getmtime(SourcePath)
        except OSError:
            mtime = 0
        last_modified_date = datetime.datetime.fromtimestamp(mtime).strftime("%Y-%m-%d %H:%M:%S")

        if ExcludeHash:
            hash = None
        else:
            hash = NewMartiHash(Algorithm="SHA256", FilePath=SourcePath, Value="")

        lattribute = SetMartiResourceAttributes(SourcePath, os.path.splitext(SourcePath)[1][1:], ExtendAttributes)

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
            "version": global_SoftwareVersion,
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
        
        
    else:
        global_MartiErrorId = "MRI2001"
        message = "Document '{}' not found or is a folder".format(SourcePath)
        WriteLog(message + " " + global_MartiErrorId) 
        CloseLog()
        raise Exception(message)
    
    CloseLog()

    return oResource



def NewMartiHash(Algorithm, FilePath, Value=""):
    
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
    

def NewEncryption(Algorithm, Value):

    oEncryption = { 
        "algo": Algorithm,
        "value": Value
    }

    return oEncryption






def SetMartiAttribute(Attributes, ACategory, AName, AFunction, Comparison, Value):

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



def NewDefaultCsvAttributes():
       
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



def NewDefaultJsonAttributes():
       
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


def NewDefaultZipAttributes(CompressionType = "ZIP",Encryption = ""):
       
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


def SetAttributeValueString(Attributes,Category,Key,Function,Value,Comparison = "EQ"):

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


def SetAttributeValueNumber(Attributes,Category,Key,Function,Value,Comparison = "EQ"):

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


def SetMartiResourceAttributes(Path,FileType,ExtendedAttributes):

    lattribute = None

    if FileType == "csv":
        lattribute = NewDefaultCsvAttributes()

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
            SetAttributeValueNumber(lattribute, "records", "dataset", "count", rowCount)
            SetAttributeValueNumber(lattribute, "columns", "dataset", "count", colCount)


    if FileType == "txt":
        lattribute = NewDefaultCsvAttributes()

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
            SetAttributeValueNumber(lattribute, "records", "dataset", "count", rowCount)
            SetAttributeValueNumber(lattribute, "columns", "dataset", "count", colCount)


    if FileType == "json":
        lattribute = NewDefaultJsonAttributes()
    

    if FileType == "zip":
        lattribute = NewDefaultZipAttributes("ZIP")
        if ExtendedAttributes:
            # $shell = New-Object -Com Shell.Application
            # $zipFile = $shell.NameSpace($Path)
            # $items = $zipFile.Items()
            SetAttributeValueNumber(lattribute, "files", "dataset", "count", -1)

    if FileType == "7z":
        lattribute = NewDefaultZipAttributes("7Z")

    if lattribute == None:
        lattribute = []
    

    return lattribute


