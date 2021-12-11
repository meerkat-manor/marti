package martilq

import (
	"testing"
	"os"
)

func TestMartiLQ_JsonSave(t *testing.T) {
	m:= NewMarti()
	m.Save("../test/basic_test.json")
}

func TestMartiLQ_ResourceAdd(t *testing.T) {
	m := NewMarti()
	r := NewResource(m.config)
	r.Title = "Title text"
	r.DocumentName = "document name"
	m.Resources = append(m.Resources, r)

	r,_ = NewMartiLQResource(m.config, "marti_test.go", "https://github.com/merebox/marti", false, true)
	r.Title = "Adding real file"
	m.Resources = append(m.Resources, r)

	m.Save("../test/test_addresource.json")
}

func TestMartiLQ_ResourceExpire(t *testing.T) {
	m := NewMarti()
	m.LoadConfig("../../../../martilq.ini")
	r := NewResource(m.config)
	r.Title = "Title text"
	r.DocumentName = "document name"
	m.Resources = append(m.Resources, r)

	r,_ = NewMartiLQResource(m.config, "marti_test.go", "https://github.com/merebox/marti", false, true)
	r.Title = "Adding real file"
	m.Resources = append(m.Resources, r)

	m.Save("../test/test_addexpiry.json")
}


func TestMartiLQ_DirectoryA(t *testing.T) {
	
	currentDirectory, _ := os.Getwd()
	SourcePath := currentDirectory
	Recursive := false
	DefPath := "../test/test_martilq_directoryA.json"
	Make("", SourcePath, "", Recursive, DefPath, "") 

}

func TestMartiLQ_DirectoryB(t *testing.T) {
	
	currentDirectory, _ := os.Getwd()
	SourcePath := currentDirectory
	Recursive := false
	DefPath := "../test/test_martilq_directoryB.json"
	Make("../conf/martilq.ini", SourcePath, "", Recursive, DefPath, "") 

}
