package martilq

import (
	"testing"
	"strconv"
)

func TestResource_Default(t *testing.T) {
	c := NewConfiguration()
	r, err := NewMartiLQResource(c, "./resource.go", "", false, true)

	if err != nil {
		t.Error("Error returned")
	}

	if len(r.Attributes) != 1 {
		t.Error("Arrays size not 1: " + strconv.Itoa(len(r.Attributes)))
	}
}