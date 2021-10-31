package martilq

import (
	"time"
	"fmt"
	"gopkg.in/ini.v1"
)
       
type oSoftware struct {
	Extension string `json:"extension"` 
	SoftwareName string `json:"softwareName"` 
	Author string `json:"author"` 
	Version string `json:"version"`
}

type oTemporal struct {
	enabled bool
	Extension string `json:"extension"`
	BusinessDate time.Time  `json:"businessDate"`
	RunDate time.Time `json:"runDate"`
}

type oSpatial struct {
	enabled bool
	Extension string `json:"extension"`
	Country string `json:"country"`
	Region string `json:"region"`
	Town string `json:"town"`
}

func GetSoftware() oSoftware {

	o := oSoftware {}
	o.Extension = "software"
	o.SoftwareName = "MARTILQREFERENCE"
	o.Author = "Meerkat@merebox.com"
	o.Version = "0.0.1"

	return o
}

func GetTemporal() oTemporal {
	o := oTemporal {}
	o.Extension = "temporal"

	return o
}

func GetSpatial() oSpatial {
	o := oSpatial {}
	o.Extension = "spatial"

	return o
}


func LoadSpatial(ConfigPath string) (oSpatial, error) {
	o := oSpatial {}
	o.Extension = "spatial"

	cfgini, err := ini.Load(ConfigPath)
	if err != nil {
		WriteLog(fmt.Sprintf("Fail to read file: %v", ConfigPath))
		fmt.Printf("Fail to read file: %v", err)
		return o, err
	}
	
	o.enabled = cfgini.Section("Custom_Spatial").Key("enabled").MustBool(o.enabled)
	o.Country = cfgini.Section("Custom_Spatial").Key("country").MustString(o.Country)
	o.Region = cfgini.Section("Custom_Spatial").Key("region").MustString(o.Region)
	o.Town = cfgini.Section("Custom_Spatial").Key("town").MustString(o.Town)

	return o, nil
}

func (s *oSpatial) SaveSpatial(ConfigPath string) bool {

	cfgini, _ := ini.Load(ConfigPath)
		
	cfgini.Section("Custom_Spatial").Key("enabled").SetValue("false")
	cfgini.Section("Custom_Spatial").Key("country").SetValue(s.Country)
	cfgini.Section("Custom_Spatial").Key("region").SetValue(s.Region)
	cfgini.Section("Custom_Spatial").Key("town").SetValue(s.Town)

	err := cfgini.SaveTo(ConfigPath)
	if err != nil {
		WriteLog(fmt.Sprintf("Error saving to '%v'" , ConfigPath))
		return false
	}

	return true

}


func LoadTemporal(ConfigPath string) (oTemporal, error) {
	o := oTemporal {}
	o.Extension = "temporal"

	cfgini, err := ini.Load(ConfigPath)
	if err != nil {
		WriteLog(fmt.Sprintf("Fail to read file: %v", ConfigPath))
		fmt.Printf("Fail to read file: %v", err)
		return o, err
	}
	
	o.enabled = cfgini.Section("Custom_Temporal").Key("enabled").MustBool(o.enabled)
	t := cfgini.Section("Custom_Temporal").Key("businessDate").MustString("")
	if t != "" {
		matched := false
		if t == "{{now}}" {
			matched = true
			o.BusinessDate = time.Now()
		} 
		if t == "{{yesterday}}" {
			matched = true
			o.BusinessDate = time.Now().AddDate(0,0,-1)
			o.BusinessDate = time.Date(o.BusinessDate.Year(), o.BusinessDate.Month(), o.BusinessDate.Day(), 0, 0, 0, 0, time.Local)
		} 
		if t == "{{today}}" {
			matched = true
			o.BusinessDate = time.Now()
			o.BusinessDate = time.Date(o.BusinessDate.Year(), o.BusinessDate.Month(), o.BusinessDate.Day(), 0, 0, 0, 0, time.Local)
		} 
		if !matched {

		}
	}
	t = cfgini.Section("Custom_Temporal").Key("runDate").MustString("")
	if t != "" {
		matched := false
		if t == "{{now}}" {
			matched = true
			o.RunDate = time.Now()
		} 
		if t == "{{today}}" {
			matched = true
			o.RunDate = time.Now()
			o.RunDate = time.Date(o.RunDate.Year(), o.RunDate.Month(), o.RunDate.Day(), 0, 0, 0, 0, time.Local)
		} 
		if !matched {

		}
	}

	return o, nil
}

func (s *oTemporal) SaveTemporal(ConfigPath string) bool {


	cfgini, _ := ini.Load(ConfigPath)
		
	cfgini.Section("Custom_Temporal").Key("enabled").SetValue("false")
	cfgini.Section("Custom_Temporal").Key("businessDate").SetValue("{{today}}")
	cfgini.Section("Custom_Temporal").Key("runDate").SetValue("{{today}}")

	err := cfgini.SaveTo(ConfigPath)
	if err != nil {
		WriteLog(fmt.Sprintf("Error saving to '%v'" , ConfigPath))
		return false
	}

	return true
}
