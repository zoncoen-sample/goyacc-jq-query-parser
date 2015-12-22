package main

import (
	"io"
	"strings"
	"testing"
)

var parseTests = []struct {
	text string
	ast  Filter
}{
	{".", EmptyFilter{}},
}

func parse(r io.Reader) Filter {
	l := new(Lexer)
	l.Init(r)
	yyParse(l)
	return l.result
}

func TestParse(t *testing.T) {
	for i, test := range parseTests {
		r := strings.NewReader(test.text)
		res := parse(r)
		if res != test.ast {
			t.Errorf("case %d: got %#v; expected %#v", i, res, test.ast)
		}
	}
}
