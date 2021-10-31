package martilq

import (
	"testing"
	"strconv"
	"time"
)

func TestAttr_Zip(t *testing.T) {
	a := NewDefaultZipAttributes("7z", "")
	if len(a) != 3{
		t.Error("Arrays size not 3: " + strconv.Itoa(len(a)))
	}
	if a[0].Value != "7z" {
		t.Error("Value not saved: " + a[0].Value)
	}
}


func TestAttr_Csv(t *testing.T) {
	a := NewDefaultCsvAttributes(true,",")
	if len(a) != 12 {
		t.Error("Arrays size not 12: " + strconv.Itoa(len(a)))
	}
	if a[0].Value != "1" {
		t.Error("Value not saved: " + a[0].Value)
	}
}


func TestAttr_TemporalA(t *testing.T) {

	businessDate := time.Now()
	businessDate = time.Date(businessDate.Year(), businessDate.Month(), businessDate.Day(), 0, 0, 0, 0, time.Local).AddDate(0,0,-1)
	runDate := time.Now()
	startDate := time.Now().AddDate(0,0,-2)
	endDate := time.Now().AddDate(0,0,-1)

	a := NewDefaultTemporalAttributes(businessDate, runDate, false, startDate, endDate)
	if len(a) != 2 {
		t.Error("Arrays size not 2: " + strconv.Itoa(len(a)))
	}
	if a[0].Comparison != "EQ" {
		t.Error("Comparison Value not saved: " + a[0].Value)
	}

	a = NewDefaultTemporalAttributes(businessDate, runDate, true, startDate, endDate)
	if len(a) != 4 {
		t.Error("Arrays size not 4: " + strconv.Itoa(len(a)))
	}
	if a[0].Comparison != "EQ" {
		t.Error("Comparison Value not saved: " + a[0].Value)
	}

}