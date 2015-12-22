%{
package main

import (
    "fmt"
    "text/scanner"
    "os"
    "strings"
)

type Filter interface{}

type Token struct {
    token   int
    literal string
}

type EmptyFilter struct {
}
%}

%union{
    token Token
    expr  Filter
}

%type<expr> filter empty_filter
%token<token> PERIOD

%%

filter
    : empty_filter
    {
        $$ = $1
        yylex.(*Lexer).result = $$
    }

empty_filter
    : PERIOD
    {
        $$ = EmptyFilter{}
    }

%%

type Lexer struct {
    scanner.Scanner
    result Filter
}

func (l *Lexer) Lex(lval *yySymType) int {
    token := int(l.Scan())
    if token == int('.') {
        token = PERIOD
    }
    lval.token = Token{token: token, literal: l.TokenText()}
    return token
}

func (l *Lexer) Error(e string) {
    panic(e)
}

func main() {
    l := new(Lexer)
    l.Init(strings.NewReader(os.Args[1]))
    yyParse(l)
    fmt.Printf("%#v\n", l.result)
}
