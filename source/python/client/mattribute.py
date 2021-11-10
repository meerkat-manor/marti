
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


class mAttribute:

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


    def UpdateAttribute(self, Attributes, ACategory, AName, AFunction, Comparison, Value):

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


    def SetAttributes(self, PathFile, FileType, ExtendedAttributes):

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

