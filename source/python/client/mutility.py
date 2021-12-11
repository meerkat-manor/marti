
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


    def NewLocalTempFile(UrlPath, Configuration, TempPath=None):
        # Create temporary file on disk for cases
        # where file size, hashing and encryption are required
        # This is useful for (1) CKAN file fetch

        parts = UrlPath.split("/")
        doc_name = parts[len(parts)-1]

        if Configuration is None:
            Configuration = mConfiguration()

        if not TempPath is None:
            temp_dir = TempPath
        else:
            temp_dir = Configuration.GetConfig("tempPath")

        if not os.path.isdir(temp_dir):
            _log = mLogging()
            _log.SetConfig(Configuration.GetConfig("logPath"), Configuration.GetSoftwareName())
            os.makedirs(temp_dir)
            _log.WriteLog("Created temp folder : {}".format(temp_dir))

        return os.path.join(temp_dir, doc_name)
