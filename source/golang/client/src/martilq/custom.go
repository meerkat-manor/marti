package martilq

import (
	"time"
)
       
type oSoftware struct {
	Extension string `json:"extension"` 
	SoftwareName string `json:"softwareName"` 
	Author string `json:"author"` 
	Version string `json:"version"`
}

type oTemporal struct {
	Extension string `json:"extension"`
	BusinessDate time.Time
	RunDate time.Time
}

type oSpatial struct {
	Extension string `json:"extension"`
	Country string `json:"country"`
	Region string
	Town string
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
