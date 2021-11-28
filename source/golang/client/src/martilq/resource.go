package martilq

import (
	"github.com/google/uuid"
	"encoding/csv"
	"os"
	"io"
	"strings"
	"time"
	"fmt"
	"log"
	"errors"
	"mime"
	"strconv"
)


type Resource struct {
	Title string `json:"title"`
	Uid string `json:"uid"`
	DocumentName string `json:"documentName"`
	IssueDate string `json:"issueDate"`
	Modified string `json:"modified"`
	Expires string `json:"expires"`
	State string `json:"state"`
	Author string `json:"author"`
	Length int64 `json:"length"`
	Hash hash `json:"hash"`

	Description string `json:"description"`
	Url string `json:"url"`
	Structure string `json:"structure"`
	Version string `json:"version"`
	ContentType string `json:"contentType"`
	Encoding string `json:"encoding"`
	Compression string `json:"compression"`
	Encryption string `json:"encryption"`
	DescribedBy string `json:"describedBy"`

	Attributes []Attribute `json:"attributes"`
}

func NewResource(config configuration) Resource {

	r := Resource {}
	u := uuid.New()
	r.Uid = u.String()

	r.IssueDate = time.Now().Format(config.dateTimeFormat)
	r.State = config.state
	r.Author  = config.author
	r.Expires = config.ExpireDate("").Format(config.dateTimeFormat)
	r.Encoding = config.encoding
	r.Compression = config.compression
	r.DescribedBy = config.describedBy

	return r
}

func NewMartiLQResource(config configuration, sourcePath string, urlPath string, excludeHash bool, extendAttributes bool) (Resource, error) {
	
	r := Resource {}

	stats, err := os.Stat(sourcePath)
	if err != nil {
		if os.IsNotExist(err) {
			log.Printf("'" + sourcePath + "' file does not exist.")
			return r, errors.New("'" + sourcePath + "' file does not exist.")
		}
	}


	if config.dataPath != "" {

	}

	u := uuid.New()
	r.Uid = u.String()

	r.State = config.state
	r.Author  = config.author
	r.Expires = config.ExpireDate(sourcePath).Format(config.dateTimeFormat)
	if time.Now().Before(config.ExpireDate(sourcePath)) && r.State == "expired" {
		r.State = "active"
	}
	r.Encoding = config.encoding
	r.Compression = config.compression
	r.DescribedBy = config.describedBy

	r.DocumentName = stats.Name()
	switch config.title {
	case "{{documentName.ext}}":
		r.Title = r.DocumentName
	case "{{documentName}}":
		parts := strings.Split(r.DocumentName, ".")
		r.Title = strings.Replace(r.DocumentName, ("."+parts[len(parts)-1]), "",-1)
	case "{{print}}":
		fmt.Println("r: "+ r.Title)
		r.Title = r.DocumentName
	default:
		r.Title = config.title
	}

	r.IssueDate = time.Now().Format(config.dateTimeFormat)
	r.Modified = stats.ModTime().Format(config.dateTimeFormat)
	r.Url = urlPath
	r.Length = stats.Size()
	if !excludeHash {
		h := NewMartiLQHash(config.hashAlgorithm, sourcePath, "", config.signKey_File)
		r.Hash = h
	}

	parts := strings.Split(sourcePath,".")
	extension := parts[len(parts)-1]

	r.ContentType = mime.TypeByExtension("."+extension)
	records := 0
	columns := -1

	switch extension {
	case "csv":
		r.Attributes = NewDefaultCsvAttributes(true, ",")

		f_csv, err := os.Open(sourcePath)
		if err != nil {
			log.Fatal(err)
		}

		rdr := csv.NewReader(f_csv)	
		for {
			record, err := rdr.Read()
			if err == io.EOF {
				break
			}
			if err != nil {
				log.Fatal(err)
			}
			records = records + 1
			if len(record) > columns {
				columns = len(record)
			}
		}
		f_csv.Close()

	default:
		r.Attributes = NewDefaultExtensionAttributes(sourcePath, extendAttributes)
	}

	if columns > 0 {
		r.Attributes =  SetMartiAttribute(r.Attributes, "dataset", "columns", "count", "EQ" , strconv.Itoa(columns))
		r.Attributes =  SetMartiAttribute(r.Attributes, "dataset", "records", "count", "EQ" , strconv.Itoa(records))
	}

	return r, nil
}
