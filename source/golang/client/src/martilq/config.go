package martilq

import (
	"fmt"
	"gopkg.in/ini.v1"
	"log"
	"os"
	"time"
	"strings"
	"strconv"
)

const cSoftwareName = "MARTILQREFERENCE"
const cSoftwareAuthor = "Meerkat@merebox.com"
const cSoftwareVersion = "0.0.1"
const cIniFileName = "martilq.ini"
const cExpires = "t:7:0:0"
const cEncoding = ""

type configuration struct {
	softwareName string

	dateFormat string
	dateTimeFormat string
	logPath string
	tempPath string
	dataPath string

	publisher string
	contactPoint string
	accessLevel string
	license string
	rights string
	tags string
	theme string
	batch string
	batchInc float64

	title string
	author string
	urlPrefix string
	state string
	version string
	expires string
	encoding string
	compression string
	describedBy string

	hash bool
	hashAlgorithm string
	signKey_File string
	signKey_Password string

	proxyName string
	proxyPort int
	proxyUser string
	proxyCredential string

	loaded bool
	configPath string

	temporal oTemporal
	spatial oSpatial
}


func GetSoftwareName() string {
	return cSoftwareName
}

func NewConfiguration() configuration {

	c :=  configuration {}

	c.softwareName = GetSoftwareName()

	c.dateFormat = "2006-01-02"
	c.dateTimeFormat = "2006-01-02T15:04:05-0700"

	c.title = "{{documentName}}"
	c.state = "active"
	c.accessLevel = "Confidential"
	c.rights = "Restricted"
	c.expires = cExpires
	c.encoding = cEncoding
	c.compression = ""
	c.describedBy = ""
	c.batchInc = 0.001

	c.urlPrefix = "file://"
	c.hash = true
	c.hashAlgorithm = "SHA256" 
	c.loaded = false

	c.spatial = GetSpatial()
	c.temporal = GetTemporal()

	configPath := findIni()
	if configPath != "" {
		c.LoadConfig(configPath)
	}

	return c
}

func findIni() string {

	foundPath := ""

	// Start wih local and move further out
	if foundPath == "" {
		iniFile := Loadenv("MARTILQ_MARTILQ_INI", "")
			if iniFile != "" {
			_, err := os.Stat(iniFile)
			if err == nil {
				foundPath = iniFile
			}
		}
	}

	if foundPath == "" {
		_, err := os.Stat(cIniFileName)
		if err == nil {
			foundPath = cIniFileName
		}
	}

	if foundPath == "" {
		_, err := os.Stat("./config/"+ cIniFileName)
		if err == nil {
			foundPath = "./config/"+  cIniFileName
		}
	}

	if foundPath == "" {
		userHomeDir, err := os.UserHomeDir()
		if err == nil {
			_, err := os.Stat(userHomeDir+ "/"+ cIniFileName)
			if err == nil {
				foundPath = userHomeDir+ "/"+ cIniFileName
			}
		}
	}

	return foundPath
}

func (c *configuration) SaveConfig(ConfigPath string) bool {

	cfgini, _ := ini.LooseLoad("./martilq.ini")
		
	cfgini.Section("General").Key("logPath").SetValue (c.logPath)
	cfgini.Section("General").Key("tempPath").SetValue (c.tempPath)
	cfgini.Section("General").Key("dataPath").SetValue (c.dataPath)
	cfgini.Section("General").Key("dateFormat").SetValue (c.datdateFormataPath)
	cfgini.Section("General").Key("dateTimeFormat").SetValue (c.dateTimeFormat)

	cfgini.Section("MartiLQ").Key("tags").SetValue(c.tags)
	cfgini.Section("MartiLQ").Key("publisher").SetValue(c.publisher)
	cfgini.Section("MartiLQ").Key("contactPoint").SetValue(c.contactPoint)
	cfgini.Section("MartiLQ").Key("accessLevel").SetValue(c.accessLevel)
	cfgini.Section("MartiLQ").Key("rights").SetValue(c.rights)
	cfgini.Section("MartiLQ").Key("license").SetValue(c.license)
	cfgini.Section("MartiLQ").Key("batch").SetValue(c.batch)
	cfgini.Section("MartiLQ").Key("theme").SetValue(c.theme)

	cfgini.Section("Resources").Key("author").SetValue (c.author)
	cfgini.Section("Resources").Key("title").SetValue (c.title)
	cfgini.Section("Resources").Key("state").SetValue (c.state)
	cfgini.Section("Resources").Key("expires").SetValue (c.expires)
	cfgini.Section("Resources").Key("encoding").SetValue (c.encoding)
	cfgini.Section("Resources").Key("compression").SetValue (c.compression)
	cfgini.Section("Resources").Key("version").SetValue (c.version)
	cfgini.Section("Resources").Key("urlPrefix").SetValue (c.urlPrefix)
	
	cfgini.Section("Hash").Key("hashAlgorithm").SetValue (c.hashAlgorithm)
	cfgini.Section("Hash").Key("signKey_File").SetValue (c.signKey_File)
	cfgini.Section("Hash").Key("signKey_Password").SetValue (c.signKey_Password)

	cfgini.Section("Network").Key("proxyName").SetValue (c.proxyName)
	cfgini.Section("Network").Key("proxyPort").SetValue (strconv.Itoa(c.proxyPort))
	cfgini.Section("Network").Key("proxyUser").SetValue (c.proxyUser)
	cfgini.Section("Network").Key("proxyCredential").SetValue (c.proxyCredential)

	err := cfgini.SaveTo(ConfigPath)
	if err != nil {
		WriteLog(fmt.Sprintf("Error saving to '%v'" , ConfigPath))
		return false
	}

	res := c.spatial.SaveSpatial(ConfigPath)
	res = c.temporal.SaveTemporal(ConfigPath)
	if res {

	}

	return true
}

func (c *configuration) LoadConfig(ConfigPath string) bool {

	if ConfigPath != "" {
		_, err := os.Stat(ConfigPath)
		if os.IsNotExist(err) {
			WriteLog(fmt.Sprintf("Configuration path '%v' does not exist" , ConfigPath))
			return false
		}
	} else {
		// Check default locations
		_, err := os.Stat(cIniFileName)
		if os.IsNotExist(err) == false {
			ConfigPath = cIniFileName
		}

	}

	if ConfigPath != "" {

		cfgini, err := ini.Load(ConfigPath)
		if err != nil {
			WriteLog(fmt.Sprintf("Fail to read file: %v", ConfigPath))
			fmt.Printf("Fail to read file: %v", err)
			return false
		}
		
		c.logPath = cfgini.Section("General").Key("logPath").MustString(c.logPath)
		c.tempPath = cfgini.Section("General").Key("tempPath").MustString(c.tempPath)
		c.dataPath = cfgini.Section("General").Key("dataPath").MustString(c.dataPath)
		c.dateFormat = cfgini.Section("General").Key("dateFormat").MustString(c.dateFormat)
		c.dateTimeFormat = cfgini.Section("General").Key("dateTimeFormat").MustString(c.dateTimeFormat)

		c.tags = cfgini.Section("MartiLQ").Key("tags").MustString(c.tags)
		c.accessLevel = cfgini.Section("MartiLQ").Key("accessLevel").MustString(c.accessLevel)
		c.rights = cfgini.Section("MartiLQ").Key("rights").MustString(c.rights)
		c.batch = cfgini.Section("MartiLQ").Key("batch").MustString(c.batch)
		c.license = cfgini.Section("MartiLQ").Key("license").MustString(c.license)
		c.publisher = cfgini.Section("MartiLQ").Key("publisher").MustString(c.publisher)
		c.contactPoint = cfgini.Section("MartiLQ").Key("contactPoint").MustString(c.contactPoint)
		c.theme= cfgini.Section("MartiLQ").Key("theme").MustString(c.theme)

		c.title = cfgini.Section("Resources").Key("title").MustString(c.title)
		c.author = cfgini.Section("Resources").Key("author").MustString(c.author)
		c.state = cfgini.Section("Resources").Key("state").MustString(c.state)
		c.expires = cfgini.Section("Resources").Key("expires").MustString(c.expires)
		c.encoding = cfgini.Section("Resources").Key("encoding").MustString(c.encoding)
		c.compression = cfgini.Section("Resources").Key("compression").MustString(c.compression)
		c.urlPrefix = cfgini.Section("Resources").Key("urlPrefix").MustString(c.urlPrefix)
		
		c.hashAlgorithm = cfgini.Section("Hash").Key("hashAlgorithm").MustString(c.hashAlgorithm)
		c.signKey_File = cfgini.Section("Hash").Key("signKey_File").MustString(c.signKey_File)
		c.signKey_Password = cfgini.Section("Hash").Key("signKey_Password").MustString(c.signKey_Password)

		c.proxyName = cfgini.Section("Network").Key("proxyName").MustString(c.proxyName)
		port := cfgini.Section("Network").Key("proxyPort").MustString("")
		if port != "" {
			c.proxyPort, _ = strconv.Atoi(port)
		}
		c.proxyUser = cfgini.Section("Network").Key("proxyUser").MustString(c.proxyUser)
		c.proxyCredential = cfgini.Section("Network").Key("proxyCredential").MustString(c.proxyCredential)
	
		c.spatial, _ = LoadSpatial(ConfigPath)
		c.temporal, _ = LoadTemporal(ConfigPath)

		c.configPath = ConfigPath
	}

	// Now check environmental values
	c.signKey_File = Loadenv("MARTILQ_SIGNKEY_FILE", c.signKey_File)
	c.signKey_Password = Loadenv("MARTILQ_SIGNKEY_PASSWORD", c.signKey_Password)
	
	c.logPath = Loadenv("MARTILQ_LOGPATH", c.logPath)

	c.loaded = true
	
	return true
}


func Loadenv(key string, default_value string ) string {

	tmp := os.Getenv(key)
	if tmp != "" {
		return tmp
	}
	return default_value
}


func (c *configuration) ExpireDate(sourcePath string ) time.Time {

	var expires time.Time

	lExpires := strings.Split(c.expires,":")
	if len(lExpires) != 4 && len(lExpires) != 7 {
		panic("Expires value '"+ c.expires +"' is invalid")
	}

	base := lExpires[0]
	if sourcePath == "" && base == "m" {
		base = "t"
	}

	modified := time.Now()
	if base == "m" {
		stats, err := os.Stat(sourcePath)
		if err != nil {
			if os.IsNotExist(err) {
				log.Printf("'" + sourcePath + "' file does not exist for Expiry.")
				base = "t"
			}
		} else {
			modified = stats.ModTime()
		}
	}

	var lExpire [3]int 
	lex, _ := strconv.Atoi(lExpires[1])
	lExpire[0] = lex
	lex, _ =strconv.Atoi(lExpires[2])
	lExpire[1] = lex
	lex, _ =strconv.Atoi(lExpires[3])
	lExpire[2] = lex

	if len(lExpires) > 4 {
		var lExpireD [3]int
		lex, _ := strconv.Atoi(lExpires[4])
		lExpireD[0] = lex
		lex, _ =strconv.Atoi(lExpires[5])
		lExpireD[1] = lex
		lex, _ =strconv.Atoi(lExpires[6])
		lExpireD[2] = lex
		
		switch base {
		case "m":
			expires = modified.AddDate(lExpire[0],lExpire[1],lExpire[2]).Add(time.Hour * time.Duration(lExpireD[0])).Add(time.Minute * time.Duration(lExpireD[1])).Add(time.Second * time.Duration(lExpireD[2]))	
		case "r":
			expires = c.temporal.RunDate.AddDate(lExpire[0],lExpire[1],lExpire[2]).Add(time.Hour * time.Duration(lExpireD[0])).Add(time.Minute * time.Duration(lExpireD[1])).Add(time.Second * time.Duration(lExpireD[2]))			
		case "b":
			expires = c.temporal.BusinessDate.AddDate(lExpire[0],lExpire[1],lExpire[2]).Add(time.Hour * time.Duration(lExpireD[0])).Add(time.Minute * time.Duration(lExpireD[1])).Add(time.Second * time.Duration(lExpireD[2]))			
		case "t":
			fallthrough
		default:			
			expires = time.Now().AddDate(lExpire[0],lExpire[1],lExpire[2]).Add(time.Hour * time.Duration(lExpireD[0])).Add(time.Minute * time.Duration(lExpireD[1])).Add(time.Second * time.Duration(lExpireD[2]))			
		}
	} else {
		switch base {
		case "m":
			expires = modified.AddDate(lExpire[0],lExpire[1],lExpire[2])
			expires = time.Date(expires.Year(), expires.Month(), expires.Day(), 0, 0, 0, 0, time.Local)
		case "r":
			expires = c.temporal.RunDate.AddDate(lExpire[0],lExpire[1],lExpire[2])
			expires = time.Date(expires.Year(), expires.Month(), expires.Day(), 0, 0, 0, 0, time.Local)
		case "b":
			expires = c.temporal.BusinessDate.AddDate(lExpire[0],lExpire[1],lExpire[2])
			expires = time.Date(expires.Year(), expires.Month(), expires.Day(), 0, 0, 0, 0, time.Local)
		case "t":
			fallthrough
		default:			
			expires = time.Now().AddDate(lExpire[0],lExpire[1],lExpire[2])
			expires = time.Date(expires.Year(), expires.Month(), expires.Day(), 0, 0, 0, 0, time.Local)
		}
	}

	return expires
}
