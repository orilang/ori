# Ori Programming Language — Design Document

## Overview

Ori is a modern, lightweight general programming language designed for speed, clarity, concurrency, and safety.
It gives you full control over memory and performance without any `garbage collector` or `runtime` management.

This document defines the core syntax, covering **expressions**, **functions**, and **blocks**, with evaluation rules.

---

## Notation

Ori is using [Wirth syntax notation (WSN)](https://en.wikipedia.org/wiki/Wirth_syntax_notation).
It's an alternative to [Extended Backus-Naur Form (EBNF)](https://en.wikipedia.org/wiki/Extended_Backus%E2%80%93Naur_form) that you might saw in other design language.

Here is the syntax notation:
```
SYNTAX     = { Production } .
 Production = Identifier "=" Expression "." .
 Expression = Term { "|" Term } .
 Term       = Factor { Factor } .
 Factor     = Identifier
            | Literal
            | Optional
            | Grouping
            | Repetition .
 Identifier = letter { letter } .
 Optional   = "[" Expression "]" .
 Repetition = "{" Expression "}" .
 Grouping   = "(" Expression ")" .
 Literal    = """" character { character } """" .
```

---

## Source code encoding

Ori source code is encoded in [UTF-8](https://en.wikipedia.org/wiki/UTF-8) which means any invalid UTF-8 sequence will endup in a compilation error.

### Characters

Here are the supported characters backed by unicode specifications:
```
newline           = /* \n or U+000A */ .
unicode_character = /* any valid unicode characters except newline */ .
unicode_letter    = /* any valid unicode letters */
unicode_digit     = /* any valid unicode digits */
```

The source of truth can be found [here](https://www.unicode.org/versions/Unicode17.0.0/) in the section `Unicode Character Database`.\
Go then to section [General Category](https://www.unicode.org/reports/tr44/tr44-36.html#General_Category) and then reach [General category values](https://www.unicode.org/reports/tr44/tr44-36.html#General_Category_Values)

---

## Lexical Elements

### Identifiers
```
Identifier = unicode_letter { unicode_letter | unicode_digit | "_" } .
```
Identifiers are case-sensitive.

### Literals
```
Number   = unicode_digit { unicode_digit } .
String   = '"' { unicode_character } '"' | '`' { unicode_character } '`'.
Boolean  = "true" | "false" .
```
Examples:
```
42
"hello"
`hello`
true
```

---

## Grammar

### Program
```
Program      = { TopLevelDecl } ;
TopLevelDecl = FuncDecl | VarDecl | Statement .
```

### Function Declaration
```
FuncDecl      = "func" Identifier "(" [ ParameterList ] ")" Block .
ParameterList = Identifier { "," Identifier } .
Statement     = Expression | ReturnStmt .
ReturnStmt    = "return" [ Expression ] .
```
Example:
```
func add(a, b) {
    return a + b
}
```

### Variable Declaration
```
VarDecl = "var" Identifier "=" Expression | Identifier ":=" Expression .
```
Example:
```
var x = 10
var y = x * 2
x := x * 3
```

### Statements
```
Statement =
      VarDecl
    | Assignment
    | Expression
    | ReturnStmt
    | Block
    .

Assignment = Identifier "=" Expression | Identifier ":=" Expression .
ReturnStmt = "return" [ Expression ] .
```

Example:
```
func main() {
    var x = 5
    var y = 10
    print(x + y)
}
```

### Blocks

Blocks represents contents between the curly brackets.
```
Block = "{" { Statement } "}" .
```
Example:
```
{
  var x = 5
  var y = 10
  print(x + y)
}
```

---

### Expressions
```
Expression =
      Primary
    | UnaryOp Expression
    | Expression BinaryOp Expression
    | FunctionCall
    .

Primary =
      Identifier
    | Literal
    | "(" Expression ")"
    .

UnaryOp       = "-" | "!" ;
BinaryOp      = "+" | "-" | "*" | "/" | "==" | "!=" | "<" | ">" | "<=" | ">=" .
FunctionCall  = Identifier "(" [ ParameterList ] ")" .
ParameterList = Expression { "," Expression } .
```

---

## Evaluation Rules

Evaluation happens in the context of an **environment** (a mapping of identifiers → values).
Expressions always evaluate to a value.

### Variable Declaration
```
E ⊢ Expression ⇓ v
——————————————
E ⊢ var x = Expression ⇓ E[x ↦ v]
```
Read: evaluate the expression to value `v` and bind it to `x` in environment `E`.

### Assignment
```
E(x) = _
E ⊢ Expression ⇓ v
——————————————
E ⊢ x = Expression ⇓ E[x ↦ v]
```

### Binary Operation
```
E ⊢ e1 ⇓ v1      E ⊢ e2 ⇓ v2
——————————————
E ⊢ e1 + e2 ⇓ v1 + v2
```
Same for other operators (`-`, `*`, `/`, comparisons, etc.).

### Function Call
```
E ⊢ f ⇓ (params, body, Ef)
E ⊢ args ⇓ vals
——————————————
E ⊢ f(args) ⇓ Eval(body, Ef ∪ [params ↦ vals])
```

### Block
```
E ⊢ s1 ⇓ E1    E1 ⊢ s2 ⇓ E2    ...    En-1 ⊢ sn ⇓ En
——————————————————————————————————————————————
E ⊢ { s1; s2; ...; sn } ⇓ En
```

### Return
Returning exits immediately from a function call, carrying the resulting value.

---

## Example Program

```
func fib(n) int {
    if n <= 1 {
        return n
    }
    return fib(n-1) + fib(n-2)
}

func main() {
    var result = fib(10)
    print(result)
}
```

---

© 2025 Ori Language — Design Spec
