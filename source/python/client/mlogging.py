
import os
import datetime


class mLogging:

    _LogOpen = False
    _LogPath = None
    _SoftwareName = "MARTILQREFERENCE"


    def SetConfig(self, LogPath, SoftwareName):

        self._LogPath = LogPath
        self._SoftwareName = SoftwareName

    def GetLogName(self):

        today = datetime.datetime.today() 
        dateToday = today.strftime("%Y-%m-%d") 
        
        if None ==  self._LogPath or self._LogPath == "":
            return None

        if not os.path.exists(self._LogPath):
            os.mkdir(self._LogPath)
        
        logName = self._SoftwareName + "_" + dateToday + ".log"

        return os.path.join(self._LogPath, logName)


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

