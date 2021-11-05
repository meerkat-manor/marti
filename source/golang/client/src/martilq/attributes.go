package martilq

import (
	"time"	
	"os"
	"io"
	"bytes"
	"strconv"
	"log"
)

// These are predefined categories, custom ones can be added
func cCategory() [] string {
	return []string {"dataset", "format", "compression", "encryption"}
}

// These are predefined functions, custom ones can be added
// Fuctions are associated with Categories
func cFunction() [] string {
	return []string {"count", "value", "temporal", "spatial", "algo"}
}

type Attribute struct {
	Category string `json:"category"`
	Name string `json:"name"`
	Function string `json:"function"`
	Comparison string `json:"comparison"`
	Value string `json:"value"`
}


func lineCounter(r io.Reader, lineEnding []byte) (int, error) {
    buf := make([]byte, 32*1024)
    count := 0

    for {
        c, err := r.Read(buf)
        count += bytes.Count(buf[:c], lineEnding)

        switch {
        case err == io.EOF:
            return count, nil

        case err != nil:
            return count, err
        }
    }
}

func NewDefaultExtensionAttributes(SourcePath string, ExtendAttributes bool) []Attribute {
        
	var lattribute []Attribute
	var oAttribute Attribute

	if ExtendAttributes {
		lineEnding := []byte {'\n'}
		f, err := os.Open(SourcePath)
		if err != nil {
			panic(err)
		}
		defer f.Close()
		count, err := lineCounter(f, lineEnding)

		oAttribute = Attribute{"dataset","records","count","EQ", strconv.Itoa(count)}
		lattribute = append(lattribute, oAttribute)
	}
		
	return lattribute
}


func NewDefaultCsvAttributes(header bool, delimiter string) []Attribute {
        
	var lattribute []Attribute
	var oAttribute Attribute

	if header {
		oAttribute = Attribute{"dataset","header","count","EQ","1"	}
		lattribute = append(lattribute, oAttribute)
	} else {
		oAttribute = Attribute{"dataset","header","count","EQ","0"	}
		lattribute = append(lattribute, oAttribute)
	}

	oAttribute = Attribute{"dataset","footer","count","EQ","0"}
	lattribute = append(lattribute, oAttribute)

	oAttribute = Attribute{"format","standard","value","EQ","RFC4180"}
	lattribute = append(lattribute, oAttribute)

	oAttribute = Attribute{"format","separator","value","EQ",","}
	lattribute = append(lattribute, oAttribute)

	oAttribute = Attribute{"format","delimiter","value","EQ",delimiter}
	lattribute = append(lattribute, oAttribute)

	oAttribute = Attribute{"format","escape","value","EQ","\""}
	lattribute = append(lattribute, oAttribute)

	oAttribute = Attribute{"format","lineEnding","value","EQ","CRLF"}
	lattribute = append(lattribute, oAttribute)

	oAttribute = Attribute{"format","columns","value","EQ",","	}
	lattribute = append(lattribute, oAttribute)

	oAttribute = Attribute{"format","radixPoint","value","EQ","."	}
	lattribute = append(lattribute, oAttribute)

	oAttribute = Attribute{"format","thousandSeparator","value","EQ",""	}
	lattribute = append(lattribute, oAttribute)

	oAttribute = Attribute{"dataset","records","count","NA","0"	}
	lattribute = append(lattribute, oAttribute)

	oAttribute = Attribute{"dataset","columns","count","NA","0"	}
	lattribute = append(lattribute, oAttribute)

	return lattribute

}


func NewDefaultZipAttributes(CompressionType string, Encryption string) []Attribute {
        
	var attributes []Attribute

	oAttribute := Attribute {"format","compression", "algo", "EQ", CompressionType}
	attributes = append(attributes, oAttribute)

	oAttribute = Attribute {"format","encryption","algo","EQ",Encryption}
	attributes = append(attributes, oAttribute)

	oAttribute = Attribute {"dataset","files","count","NA", "0"}
	attributes = append(attributes, oAttribute)
		
	return attributes
}


func NewDefaultTemporalAttributes(businessDate time.Time, runDate time.Time, duration bool, startDate time.Time, endDate time.Time) []Attribute {
        
	var attributes []Attribute

	oAttribute := Attribute {"dataset","businessDate", "temporal", "EQ", businessDate.Format("2006-01-02T15:04:05-0700")}
	attributes = append(attributes, oAttribute)

	oAttribute = Attribute {"dataset","runDate", "temporal", "EQ", runDate.Format("2006-01-02T15:04:05-0700")}
	attributes = append(attributes, oAttribute)

	if duration {

		oAttribute := Attribute {"dataset","duration", "temporal", "GE", startDate.Format("2006-01-02T15:04:05-0700")}
		attributes = append(attributes, oAttribute)
	
		oAttribute = Attribute {"dataset","duration", "temporal", "LE", endDate.Format("2006-01-02T15:04:05-0700")}
		attributes = append(attributes, oAttribute)
	
	}
		
	return attributes
}


func RemoveMartiAttribute(Attributes []Attribute, ACategory string, AName string, AFunction string, Comparison string , Value string) []Attribute  {

	for ix := 0; ix< len(Attributes); ix++ {
		attr := Attributes[ix]
		if attr.Category == ACategory && attr.Name == AName && attr.Function == AFunction && attr.Comparison == Comparison {
			copy(Attributes[ix:], Attributes[ix+1:]) 
			Attributes[len(Attributes)-1] = Attribute{}     
			return Attributes[:len(Attributes)-1]     
		}
	}

	log.Fatal("No matching record found")
	return Attributes
}

func SetMartiAttribute(Attributes []Attribute, ACategory string, AName string, AFunction string, Comparison string , Value string) []Attribute  {

	for ix := 0; ix< len(Attributes); ix++ {
		attr := Attributes[ix]
		if attr.Category == ACategory && attr.Name == AName && attr.Function == AFunction {
			if attr.Comparison == Comparison || attr.Comparison == "NA" {
				Attributes[ix].Comparison = Comparison
				Attributes[ix].Value = Value
				return Attributes
			}
		}
	}

	oAttribute := Attribute { ACategory, AName, AFunction, Comparison, Value }	
	Attributes = append(Attributes, oAttribute)

	return Attributes
}

