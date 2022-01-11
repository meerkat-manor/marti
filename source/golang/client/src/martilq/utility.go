package martilq

import (
	"os"
	"path"
	"time"
	"strings"
	"log"
	"errors"
)

func GetLogName() string {

    date := time.Now().Format("2006-01-02")
	logPathName := "./logs"
    
    if (logPathName == "") {
        return "./logs"
    }
	
	if _, err := os.Stat(logPathName); errors.Is(err, os.ErrNotExist) {
		err := os.Mkdir(logPathName, os.ModePerm)
		if err != nil {
			log.Println(err)
		}
	}

    logName := GetSoftwareName() + "_" + date + ".log"
    sFullPath := path.Join(logPathName, logName )
	
	_, err := os.Stat(sFullPath)
  	if err != nil && os.IsNotExist(err) {
		log.Println("Log path: "+ sFullPath)
	}

    return sFullPath
}


func WriteLog(LogEntry string) {
    
    sFullPath := GetLogName() 
	if (sFullPath != "") {
		logFile, err := os.OpenFile(sFullPath, os.O_CREATE|os.O_APPEND|os.O_WRONLY, 0644)
		if err != nil {
			log.Fatal(err)
		}
		defer logFile.Close()
		log.SetOutput(logFile)
    }
	log.Println(LogEntry)
}

func OpenLog() {
    dateTime := time.Now().Format("2006-01-02T15:04:05-0700")
    WriteLog( "***********************************************************************************")
    WriteLog( "*   Start of processing: ["+dateTime+"]")
    WriteLog( "***********************************************************************************")
}

func CloseLog() {
    dateTime := time.Now().Format("2006-01-02T15:04:05-0700")
    WriteLog( "***********************************************************************************")
    WriteLog( "*   End of processing: ["+dateTime+"]")
    WriteLog( "***********************************************************************************")
}


func NewLocalTempFile(UrlPath string, configuration *Configuration, TempPath string) string {

    parts := strings.Split(UrlPath, "/")
    doc_name := parts[len(parts)-1]
	temp_dir := TempPath

	if (temp_dir == "") {
		if (configuration == nil) {
			temp_dir = NewConfiguration().tempPath
		} else {
			temp_dir = configuration.tempPath
		}
	}

	if _, err := os.Stat(temp_dir); errors.Is(err, os.ErrNotExist) {
		err := os.Mkdir(temp_dir, os.ModePerm)
		if err != nil {
			log.Println(err)
		} else {
        	WriteLog("Created temp folder : " + temp_dir)
		}
	}

    return path.Join(temp_dir, doc_name )
}
