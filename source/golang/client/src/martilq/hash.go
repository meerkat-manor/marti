package martilq

import (
    "io/ioutil"
	"crypto/sha256"
	"encoding/hex"
	"log"
)

type hash struct {
	Algo string `json:"algo"`
	Value string `json:"value"`
	Signed bool `json:"signed"`
}

func NewMartiLQHash(algo string, filePath string, value string, sign string) hash {

	h := hash {}

	h.Algo = algo
	h.Value = value
	h.Signed = false

	if value == "" {
		hasher := sha256.New()
		s, err := ioutil.ReadFile(filePath)    
		hasher.Write(s)
		if err != nil {
			log.Fatal(err)
		}

		h.Value = hex.EncodeToString(hasher.Sum(nil))
	}

	if sign != "" {


		h.Signed = true
	}

	return h
}
