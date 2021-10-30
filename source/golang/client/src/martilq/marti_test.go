package martilq

import (
	"testing"
	"os"
)

func TestMarti_JsonSave(t *testing.T) {
	m:= NewMarti()
	m.Save("../test/basic_test.json")
}

func TestMarti_ResourceAdd(t *testing.T) {
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

func TestMarti_ResourceExpire(t *testing.T) {
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


func TestMarti_DirectoryA(t *testing.T) {
	
	currentDirectory, _ := os.Getwd()
	SourcePath := currentDirectory
	Recursive := false
	TargetPath := "../test/test_martilq_directoryA.json"
	ProcessDirectory("", SourcePath, Recursive, TargetPath) 

}

func TestMarti_DirectoryB(t *testing.T) {
	
	currentDirectory, _ := os.Getwd()
	SourcePath := currentDirectory
	Recursive := false
	TargetPath := "../test/test_martilq_directoryB.json"
	ProcessDirectory("../config/martilq.ini", SourcePath, Recursive, TargetPath) 

}
