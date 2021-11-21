
import os
import requests
import ftplib
from genericpath import getsize 

from mlogging import mLogging
from mconfiguration import mConfiguration

class mUtility:

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



