

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

#from source.python.client.mlogging import mLogging
from mlogging import mLogging

class mConfiguration:

    _SoftwareVersion = "0.0.1"
    _default_metaFile = "##martilq##.json"

    _oSoftware = {
        "extension": "software",
        "softwareName": "MARTILQREFERENCE",
        "author": "Meerkat@merebox.com",
        "version": "0.0.1"
    }
    
    
    _oConfiguration = None
    _Log = None


    def GetSoftwareName(self):
        return "MARTILQREFERENCE"

    def __init__(self):

        self._oConfiguration = {
            "softwareName": self.GetSoftwareName(),
            "softwareAuthor": "Meerkat@merebox.com",
            "softwareVersion": self._SoftwareVersion,

            "logPath": "./logs/",
            "dateFormat": "2006-01-02",
            "dateTimeFormat": "2006-01-02T15:04:05+0100",
            "dataPath": "",
            "tempPath": "temp",

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
            "expires": "m:10:0:0",
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
        
        self._Log = mLogging()
        self._Log.SetConfig(self._oConfiguration["logPath"], self.GetSoftwareName())

    def LoadConfig(self, ConfigPath=None):

        config_object = ConfigParser()
        if not ConfigPath is None:
            if os.path.exists(ConfigPath):
                config_object.read(ConfigPath)
            else:
                self._Log.WriteLog("Configuration path '{}' does not exist".format(ConfigPath))
                raise Exception("Configuration path '{}' does not exist".format(ConfigPath))
        else:
            # Look in default location and name
            home = os.path.expanduser('~')
            if os.path.exists(os.path.join(home, ".martilq/martilq.ini")): 
                ConfigPath = os.path.join(home, ".martilq/martilq.ini")
            if os.path.exists("martilq.ini"): 
                ConfigPath = "martilq.ini"
            if not ConfigPath is None:
              self._Log.WriteLog("Usig configuration path '{}'".format(ConfigPath))
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
                        self._Log.WriteLog("Error in config ignored: " + x)

        self._Log.SetConfig(self._oConfiguration["logPath"], self.GetSoftwareName())

        if config_object.has_section("MartiLQ"):
            items = config_object["MartiLQ"]
            if not items is None:
                config_attr = ["rights", "accessLevel", "tags","publisher","batch","theme", "license","contactPoint"]
                for x in config_attr:
                    try:
                        if not items[x] is None and not items[x] == "":
                            self._oConfiguration[x] = items[x]
                    except Exception:
                        self._Log.WriteLog("Error in config ignored: " + x)

        if config_object.has_section("Resources"):
            items = config_object["Resources"]
            if not items is None:
                config_attr = ["state", "author", "title", "expires","encoding", "version", "urlPrefix", "compression", "encryption", "describedBy", "landingPage"]
                for x in config_attr:
                    try:
                        if not items[x] is None and not items[x] == "":
                            self._oConfiguration[x] = items[x]
                    except Exception:
                        self._Log.WriteLog("Error in config ignored: " + x)

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
                        self._Log.WriteLog("Error in config ignored: " + x)

        # Now check environmental values
        self._oConfiguration["signKey_File"] = os.getenv("MARTILQ_SIGNKEY_FILE", self._oConfiguration["signKey_File"])
        self._oConfiguration["signKey_Password"] = os.getenv("MARTILQ_SIGNKEY_PASSWORD", self._oConfiguration["signKey_Password"])
        self._oConfiguration["logPath"] = os.getenv("MARTILQ_LOGPATH", self._oConfiguration["logPath"])

        self._Log.WriteLog("Configuration load processed")


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
                    self._Log.WriteLog("Error in config ignored: " + x + " = " + str(e))

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
                    self._Log.WriteLog("Error in config ignored: " + x + " = " + str(e))

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
                    self._Log.WriteLog("Error in config ignored: " + x + " = " + str(e))


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
                    self._Log.WriteLog("Error in config ignored: " + x + " = " + str(e))

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
                    self._Log.WriteLog("Error in config ignored: " + x + " = " + str(e))

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

            self._Log.WriteLog("Configuration save processed")
            return True

        else:
            self._Log.WriteLog("Configuration file exists and new not saved")
            return False

    
    def SetConfig(self, Key=None, Value=None):

        if not Key is None:
            self._oConfiguration[Key] = Value

    def GetConfig(self, Key=None):

        try:
            if self._oConfiguration is None:
                return None
            if not Key is None:
                if Key == "tags":
                    return self._oConfiguration[Key].split(",")     
                return self._oConfiguration[Key] 
            else:
                return None
        except Exception:
            self._Log.WriteLog("Error in getting config: "+ Key)
            return None


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

