package martilq

import (
	"testing"
)

func TestConfig_NotExist(t *testing.T) {
	c := NewConfiguration()
	if c.LoadConfig("../martilq.ini") != false {
		t.Error("Configuration file not loaded")
	}
}

func TestConfig_LoadNone(t *testing.T) {
	c := NewConfiguration()
	if c.LoadConfig("") != true {
		t.Error("Default configuration not loaded")
	}
}

func TestConfig_LoadFile(t *testing.T) {
	c := NewConfiguration()
	if c.LoadConfig("../../../../martilq.ini") != true {
		t.Error("File configuration not loaded")
	}
	if c.state != "active" {
		t.Error("State not as expected: "+c.state)
	}
	if c.rights != "None" {
		t.Error("Rights not as expected: "+c.rights)
	}
}


func TestConfig_Save(t *testing.T) {
	c := NewConfiguration()
	if c.SaveConfig("../test/martilq_write.ini") != true {
		t.Error("Default configuration not saved")
	}
}
