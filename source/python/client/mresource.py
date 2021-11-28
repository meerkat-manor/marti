
from genericpath import getsize 
import os
import uuid
import datetime
import getpass
import hashlib
import glob
import requests
import mimetypes


from mconfiguration import mConfiguration
from mlogging import mLogging
from mattribute import mAttribute

class mResource:

    _oConfiguration = None
    _Log = None

    def __init__(self):
        self._LogOpen = False        
        self._oConfiguration = mConfiguration()
        self._Log = mLogging()
        self._Log.SetConfig(self._oConfiguration.GetConfig("logPath"), self._oConfiguration.GetSoftwareName())


    def SetConfig(self, Configuration):

        self._oConfiguration = Configuration
        self._Log.SetConfig(self._oConfiguration.GetConfig("logPath"), self._oConfiguration.GetSoftwareName())


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

        self._Log.OpenLog()
        self._Log.WriteLog("Function 'NewMartiLQResource' parameters follow")
        self._Log.WriteLog("Parameter: SourcePath   Value: {}".format(SourcePath))
        self._Log.WriteLog("Parameter: UrlPath   Value: {}".format(UrlPath))
        self._Log.WriteLog("Parameter: ExcludeHash   Value: {}".format(ExcludeHash))
        self._Log.WriteLog("")

        if os.path.exists(SourcePath):
        
            item = os.path.basename(SourcePath)
            self._Log.WriteLog("Define file {}".format(SourcePath))
            HashAlgorithm = self._oConfiguration.GetConfig("hashAlgorithm")

            try:
                mtime = os.path.getmtime(SourcePath)
            except OSError:
                mtime = 0
            last_modified_date = datetime.datetime.fromtimestamp(mtime).strftime("%Y-%m-%dT%H:%M:%S")

            if ExcludeHash:
                hash = None
            else:
                hash = self.NewMartiLQHash(Algorithm=HashAlgorithm, FilePath=SourcePath, Value="", Sign=self._oConfiguration.GetConfig("signKey_File"))

            oAttr = mAttribute()
            oAttr.SetConfig(self._oConfiguration)
            lattribute = oAttr.SetAttributes(SourcePath, str(os.path.splitext(SourcePath)[1][1:]).lower(), ExtendAttributes)

            sTitle =  self._oConfiguration.GetConfig("title")
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
                "expires": self._oConfiguration.ExpireDate(item).strftime("%Y-%m-%dT%H:%M:%S%z"),
                "state": self._oConfiguration.GetConfig("state"),
                "author": self._oConfiguration.GetConfig("author"),
                "length": os.path.getsize(SourcePath),
                "hash": hash,

                "description": "",
                "url": self._oConfiguration.GetConfig("urlPrefix"),
                "structure": "",
                "version": self._oConfiguration.GetConfig("version"),
                "contentType": self.GetContentType(SourcePath),
                "encoding": self._oConfiguration.GetConfig("encoding"),
                "compression": self._oConfiguration.GetConfig("compression"),
                "encryption": self._oConfiguration.GetConfig("encryption"),
                "describedBy": self._oConfiguration.GetConfig("describedBy"),
                "landingPage": self._oConfiguration.GetConfig("landingPage"),
                "attributes": lattribute
            }

            if None != UrlPath and UrlPath != "":
                if UrlPath[len(UrlPath)-1] == "/" or UrlPath[len(UrlPath)-1] == "\\":
                    oResource["url"] = UrlPath.replace("\\", "/") + item
                else:
                    oResource["url"] = UrlPath.replace("\\", "/") + "/" + item
            
            self._Log.WriteLog("Complete file {}".format(SourcePath))
            
        else:
            self._MartiErrorId = "MRI2001"
            message = "Document '{}' not found or is a folder".format(SourcePath)
            self._Log.WriteLog(message + " " + self._MartiErrorId) 
            raise Exception(message)
        
        return oResource


    def SetAttributeValueString(oResource, Category, Key, Function, Value, Comparison="EQ"):

        for item in oResource["attributes"]:
        
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

        oResource["attributes"].append(oAttribute)
        
        return
        
    
    def SetAttributeValueNumber(oResource, Category, Key, Function, Value, Comparison="EQ"):
        
        mResource.SetAttributeValueString(oResource, Category, Key, Function, Value, Comparison)

        return


    def NewMartiLQHash(self, Algorithm, FilePath, Value="", Sign=""):
        
        try:
            signed = False
            if Value  == "" and FilePath != "":

                if not Sign is None and not Sign == "" and not os.path.exists(Sign):
                    self._Log.WriteLog("Sign file '{}' not found".format(Sign))
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
                    password = self._oConfiguration.GetConfig("sigenKey_Password")

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
            self._Log.WriteLog("Hash error for file {}: {}".format(FilePath, str(e)))
            raise e

        return oHash
        

    def NewEncryption(self, Algorithm, Value):

        oEncryption = { 
            "algo": Algorithm,
            "value": Value
        }

        return oEncryption

