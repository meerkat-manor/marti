package martilq


import (
	"fmt"
	"os"
	"path/filepath"
	"encoding/json"
	"io/ioutil"
	"github.com/google/uuid"
	"math"
	"time"
	"errors"
	"strings"
	"strconv"
	"bufio"
	"log"
	"reflect"
)



type Marti struct {
	Content_type string `json:"content-type"`
	Title string `json:"title"`
	Uid string `json:"uid"`

	Description string `json:"description"`
	Modified time.Time `json:"modified"`
	Publisher string `json:"publisher"`
	ContactPoint string `json:"contactPoint"`
	AccessLevel string `json:"accessLevel"`
	Rights string `json:"rights"`
	Tags []string `json:"tags"`
	License string `json:"license"`
	State string `json:"state"`
	Batch float64 `json:"batch"`
	DescribedBy string `json:"describedBy"`
	LandingPage string `json:"landingPage"`
	Theme string `json:"theme"`

	Resources []Resource `json:"resources"`
	Custom []interface{} `json:"custom"`


	config configuration
}

func NewMarti() Marti {

	m := Marti {}
	m.Content_type = "application/vnd.martilq.json"
	u := uuid.New()
	m.Uid = u.String()

	software := GetSoftware()
	m.Custom = append(m.Custom, software)
	spatial := GetSpatial()
	m.Custom = append(m.Custom, spatial)
	temporal := GetTemporal()
	m.Custom = append(m.Custom, temporal)

	m.config = NewConfiguration()

	return m
}

func Load(c configuration, pathFile string) (Marti, error) {
	
	m := Marti {}

	data, err := ioutil.ReadFile(pathFile)
    if err != nil {
	  return m, err
    }

    err = json.Unmarshal(data, &m)
    if err != nil {
        fmt.Println("error:", err)
		return m, err
    }

	if reflect.TypeOf(c) == reflect.TypeOf(m.config) {
		m.config = c
	}

	return m, nil
}

func (m *Marti) LoadConfig(ConfigPath string) {
	m.config.LoadConfig(ConfigPath)

	m.Publisher = m.config.publisher
	m.ContactPoint = m.config.contactPoint
	m.AccessLevel = m.config.accessLevel
	m.State = m.config.state
	m.Rights = m.config.rights
	if m.config.tags != "" {
		m.Tags = strings.Split(m.config.tags, ",")
	}
	m.Theme = m.config.theme
	m.License = m.config.license
	if m.config.batch != "" {
		if m.config.batch[0] == '@' {
			_, err := os.Stat(m.config.batch[1:])
			if os.IsNotExist(err) {
				WriteLog(fmt.Sprintf("Batch file '%v' does not exist" , m.config.batch))		
			} else {
				readFile, err := os.Open(m.config.batch[1:])
				if err != nil {
					log.Fatalf("failed to open file: %s", err)
				}
				reader := bufio.NewReader(readFile)
				var line string
				line, _ = reader.ReadString('\n')
				m.Batch, _ = strconv.ParseFloat(line, 10)
				readFile.Close()
			}
			
		} else {
			m.Batch, _ = strconv.ParseFloat(m.config.batch, 10)
		}
	}

}


func (m *Marti) AddResource(Title string, SourcePath string, Url string) (Resource, error) {

	r, err := NewMartiLQResource(m.config, SourcePath, Url, false, true)
	if err != nil {
		return r, errors.New("Error in adding resource: "+SourcePath)
	}
	r.Title = Title
	
	// Find if we already have the resource
	// This can occur if we are reloading
	matched := false
	for ix := 0; ix < len(m.Resources); ix++ {
		if m.Resources[ix].DocumentName == r.DocumentName && m.Resources[ix].Url == r.Url {
			m.Resources[ix] = r
			matched = true
			break
		}		
    }

	if !matched {
		m.Resources = append(m.Resources, r)
	}

	return r, nil
}

func (m *Marti) Save(pathFile string) bool {

	if pathFile == "" {
		return false
	}

	j, err := json.MarshalIndent(m, "","    ")
	if err != nil {
		fmt.Println(err)
		return false
	} else {
		_ = ioutil.WriteFile(pathFile, j, 0644)
	}

	return true
}


func ProcessDirectory(ConfigPath string, SourcePath string, Recursive bool, TargetPath string) Marti {

	m := NewMarti()

	_, err := os.Stat(TargetPath)
	if err == nil {
		m, err = Load(m.config, TargetPath)
		if err != nil {
			panic("Unable to load existing MartiLQ defintion: " + TargetPath)
		}
		// Update the batch number, minor version
		m.Batch = math.Round((m.Batch + m.config.batchInc)/m.config.batchInc)*m.config.batchInc
		m.config.LoadConfig(ConfigPath)
	} else {
		if ConfigPath != "" {
			m.LoadConfig(ConfigPath)
		}
	}

	filepath.Walk(SourcePath, func(path string, info os.FileInfo, err error) error {
        if err != nil {
            log.Fatalf(err.Error())
        }
		if info.IsDir() {
			if Recursive {

			}
		} else {
			url := "file://"+info.Name()
			m.AddResource(info.Name(), path, url) 
		}
        return nil
    })

	return m

}
