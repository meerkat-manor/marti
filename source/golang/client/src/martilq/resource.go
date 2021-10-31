package martilq

import (
	"github.com/google/uuid"
	"os"
	"time"
	"log"
	"errors"
)


type Resource struct {
	Title string `json:"title"`
	Uid string `json:"uid"`
	DocumentName string `json:"documentName"`
	IssueDate time.Time `json:"issueDate"`
	Modified time.Time `json:"modified"`
	Expires time.Time `json:"expires"`
	State string `json:"state"`
	Author string `json:"author"`
	Length int64 `json:"length"`
	Hash hash `json:"hash"`

	Description string `json:"description"`
	Url string `json:"url"`
	Version string `json:"version"`
	Content_Type string `json:"content-type"`
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

	r.IssueDate = time.Now()
	r.State = config.state
	r.Author  = config.author
	r.Expires = config.ExpireDate()
	r.Encoding = config.encoding

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
	r.Expires = config.ExpireDate()
	r.Encoding = config.encoding

	r.DocumentName = stats.Name()
	if config.title == "{{documentName}}" {
		r.Title = r.DocumentName
	}
	r.IssueDate = time.Now()
	r.Modified = stats.ModTime()
	r.Url = urlPath
	r.Length = stats.Size()
	if !excludeHash {
		h := NewMartiLQHash(config.hashAlgorithm, sourcePath, "", config.signKey_File)
		r.Hash = h
	}

	r.Attributes = NewDefaultExtensionAttributes(sourcePath, extendAttributes)

	return r, nil
}
