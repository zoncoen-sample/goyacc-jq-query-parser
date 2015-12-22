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
	{".key", KeyFilter{Key: "key"}},
	{".[0]", IndexFilter{Index: "0"}},
	{".key | .[0]", BinOp{Left: KeyFilter{Key: "key"}, Op: Token{Token: 57351, Literal: "|"}, Right: IndexFilter{Index: "0"}}},
	{".first | .second | .third", BinOp{
		Left: BinOp{
			Left:  KeyFilter{Key: "first"},
			Op:    Token{Token: 57351, Literal: "|"},
			Right: KeyFilter{Key: "second"}},
		Op:    Token{Token: 57351, Literal: "|"},
		Right: KeyFilter{Key: "third"}}},
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
