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
    Token   int
    Literal string
}

type EmptyFilter struct {
}

type KeyFilter struct {
    Key string
}

type IndexFilter struct {
    Index string
}
%}

%union{
    token Token
    expr  Filter
}

%type<expr> program filter empty_filter key_filter index_filter
%token<token> PERIOD STRING INT LBRACK RBRACK

%%

program
    : filter
    {
        $$ = $1
        yylex.(*Lexer).result = $$
    }

filter
    : empty_filter
    {
        $$ = $1
    }
    | key_filter
    {
        $$ = $1
    }
    | index_filter
    {
        $$ = $1
    }

empty_filter
    : PERIOD
    {
        $$ = EmptyFilter{}
    }

key_filter
    : PERIOD STRING
    {
        $$ = KeyFilter{Key: $2.Literal}
    }

index_filter
    : PERIOD LBRACK INT RBRACK
    {
        $$ = IndexFilter{Index: $3.Literal}
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
    if token == scanner.Ident {
        token = STRING
    }
    if token == scanner.Int {
        token = INT
    }
    if token == int('[') {
        token = LBRACK
    }
    if token == int(']') {
        token = RBRACK
    }
    lval.token = Token{Token: token, Literal: l.TokenText()}
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
