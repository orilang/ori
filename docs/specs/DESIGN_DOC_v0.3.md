# Ori Programming Language — Design Document

## Overview

Ori is a modern, lightweight general programming language designed for **speed**, **clarity**, and **control**.\
It gives you full control over memory and performance without any `garbage collector` or `runtime` management.\
It provides predictable behavior, deterministic performance, and zero hidden runtime costs.

This version (v0.3) introduces:
- **Composite types**: `struct`, `array`, and `map`
- **Type declarations** (`type Name Type`)
- **Memory semantics** (value vs. reference)
- **Type checking rules** for assignment and expressions
- Extended **evaluation rules** for composite types

---

## Notation

Ori uses [Wirth syntax notation (WSN)](https://en.wikipedia.org/wiki/Wirth_syntax_notation).
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
 Literal    = '"' character { character } '"' .
```

---

## Source code encoding

Ori source code is encoded in [UTF-8](https://en.wikipedia.org/wiki/UTF-8).\
Invalid UTF-8 sequence will endup in a compilation error.

---

### Characters

Here are the supported characters backed by unicode specifications:
```
newline           = /* \n or U+000A */ .
unicode_character = /* any valid unicode characters except newline */ .
unicode_letter    = /* any valid unicode letters */
unicode_digit     = /* any valid unicode digits */
```

The source of truth can be found [here](https://www.unicode.org/versions/Unicode17.0.0/) in the section `Unicode Character Database`.\
Then go to section [General Category](https://www.unicode.org/reports/tr44/tr44-36.html#General_Category) and reach [General category values](https://www.unicode.org/reports/tr44/tr44-36.html#General_Category_Values)

---

## Lexical Elements

### Identifiers
```
Identifier = unicode_letter { unicode_letter | unicode_digit | "_" } .
```
Identifiers are case-sensitive.

---

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

---

### Function Declaration
```
FuncDecl       = "func" Identifier "(" [ ParameterList ] ")" [ Type ] Block .
ParameterList  = ParameterGroup { "," ParameterGroup } .
ParameterGroup = Identifier { "," Identifier } [ Type ] .
Statement      = Expression | ReturnStmt .
ReturnStmt     = "return" [ Expression ] .
```
Example:
```
func add(a int, b int) int {
    return a + b
}
```

Or using a shorthand notation:
```
func add(a, b int) int {
    return a + b
}
```

**Note**: Multiple paramters of the same type can be grouped together.\
`func add(a, b int)` is equivalent to `func(a int, b int)`.

---

### Variables
```
VarDecl = "var" Identifier [ Type ] "=" Expression | Identifier ":=" Expression .
```
Example:
```
var x int = 10
var y = "Ori"
x := x + 1
```

---

### Statements
```
Statement =
      VarDecl
    | Assignment
    | Expression
    | ReturnStmt
    | Block
    | IfStmt
    | SwitchStmt
    | ForStmt
    .

Assignment = Identifier "=" Expression | Identifier ":=" Expression .
```

---

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
FunctionCall  = Identifier "(" [ ExpressionList ] ")" .
ExpressionList = Expression { "," Expression } .
```

---

## If statement

```
IfStmt = "if" [ SimpleStmt ";" ] Expression Block [ "else" (IfStmt | Block) ] .
SimpleStmt = VarDecl | Assignment | Expression .
```

Examples:
```
if a > b {
  return a
}

if a > b && c > d {
  return a*c
}

if a > b || c > d {
  return true
}

if (a + b) > (c + d) {
  return true
}

if a > b {
  return a
} else if c > d {
  return c
}

if a > b {
  return a
} else if c > d {
    return c
  else {
    return 0
  }
}

if err := f(); err != nil {
  return err
}

if _, err := f(); err != nil {
  return err
}

if k, ok := f(); ok {
  return k
}
```

---

## Switch statement

```
SwitchStmt = "switch" [ SimpleStmt ";" ] [ Expression ] "{" { CaseClause } "}" .
CaseClause = ( "case" ExpresionList | "default" ) ":" { Statement } .
ExpressionList = Expression { "," Expression } .
```

```
switch a {
case 1:
  print("a")
case 2:
  print("b")
default:
  print("c")
}

switch {
case a == 0:
  print("a")
case b == 1:
  print("b")
default:
  print("c")
}

switch x {
case a, b:
  print("x")
default:
  print("c")
}

switch x := f() {
case a, b:
  print("x")
default:
  print("c")
}
```

---

## For statement

```
ForStmt = "for" Identifier [ "," Identifier ] ":=" "range" Expression Block
        | "for" Expression Block
        | "for" [ SimpleStmt ";" ] Expression [ ";" SimpleStmt ] Block .
```

```
for i := range 5 {
  print(i)
}

for i := range f() {
  print(i)
}

for k, v := range x() {
  print(k, v)
}

for _, v := range x() {
  print(v)
}

for i := 0, i < 5; i++ {
  print(k, v)
}

for i := 5, i > 0; i-- {
  print(k, v)
}

for i := 0, i < max(); i++ {
  print(k, v)
}
```

---

## Types

```
Type = "int" | "float" | "bool" | "string" | Identifier .
```

---

## Comments

To make a comment you can use `/* ... */` as a multiline comment or `// ` for a sigle line comment.

```
Comment      = LineComment | BlockComment .
LineComment  = "//" { unicode_character } newline .
BlockComment = "/*" { unicode_character } "*/" .
```

Examples:
```
/*
This is a multi line comment
That can be used as a description of
package main
*/
package main

// This is a single line comment
// You can use it as a function definition
func main()

var x = 10 // sigle line comment

// same as before
var y = 10

/* same as before */
var z = 10
```

---

### Structs

```
StructType = "struct" "{" { FieldDecl } "}" .
FieldDecl  = Identifier [ Type ] .
```

Example:
```
type Point struct {
  x int
  y int
}
```
is the same as:
```
type Point struct {
  x, y int
}
```

Structs are **value types** -- assigning or passing them copies their contents.

---

### Arrays

```
ArrayType = "[" Expression "]" Type .
```

```
var nums [3]int = [3]int{1, 2, 3}
nums := [3]int{1, 2, 3} // same as above
```

```
var items []string = ["a", "b", "c"]
items := []string{"a", "b", "c"} // same as above
```

Arrays are **fixed-length** and **value types**
Two arrays are equal if all elements are equal.

---

### Maps

```
MapType = "map[" Type "]" Type .
```

```
var users map[string]int = {
  "alice": 1,
  "bob": 2,
}
```

Maps are **reference types**.\
Assignment or parameter passing copies the reference, not the underlying data.

---

### Type Declarations

Add named type definitions:

```
TypeDecl = "type" Identifier Type .
```

Example:
```
type ID int
type Person struct {
  name string
  age int
}
```

---

### Memory model

Structs and arrays are passed by value.\
Maps and slices are reference-like.\
Assignment performs copy for values.\
Reference update for references types.

So:
```
a := Point{x: 1, y: 2}
b := a
b.x = 5
// a.x remains 1
```

Example with reference:
```
a := &Point{x: 1, y: 2}
b := a
b.x = 5
// a.x equals 5
```

---

## Evaluation Rules

Evaluation occurs in an **environment** a mapping of identifiers to values.
Each block creates a new enviroment.

```
E ⊢ Expression ⇓ v
——————————————————————————————————
E ⊢ var x = Expression ⇓ E[x ↦ v]
```
Read: evaluate the expression to value `v` and bind it to `x` in environment `E`.

---

### Assignment Evaluation
```
E(x) = _
E ⊢ Expression ⇓ v
——————————————————————————————
E ⊢ x = Expression ⇓ E[x ↦ v]
```

---

### Binary Operation Evaluation
```
E ⊢ e1 ⇓ v1      E ⊢ e2 ⇓ v2
——————————————————————————————
E ⊢ e1 + e2 ⇓ v1 + v2
```
Same for other operators (`-`, `*`, `/`, comparisons, etc.).

---

### If Evaluation

```
E ⊢ cond ⇓ true   E ⊢ Block ⇓ v
—————————————————————————————————
E ⊢ if cond Block ⇓ v

E ⊢ cond ⇓ false  E ⊢ else Block ⇓ v
——————————————————————————————————————
E ⊢ if cond Block else Block ⇓ v
```

---

### Switch Evaluation

Evaluate cases top-down until one matches or default executes.\
Only the first matching case runs.

---

### For Evaluation

```
for i := range int(5)        // iterate from 0 to 4
for k, v := range collection // iterate over collection pairs
for i := 0 i < N; i++        // traditional form
```

---

### Function Call Evalution
```
E ⊢ f ⇓ (params, body, Ef)
E ⊢ args ⇓ vals
————————————————————————————————————————————————
E ⊢ f(args) ⇓ Eval(body, Ef ∪ [params ↦ vals])
```

---

### Block Evalutation
```
E ⊢ s1 ⇓ E1    E1 ⊢ s2 ⇓ E2    ...    En-1 ⊢ sn ⇓ En
———————————————————————————————————————————————————————
E ⊢ { s1; s2; ...; sn } ⇓ En
```

---

### Return Evaluation
Returning exits immediately from a function call, carrying the resulting value.

---

### Struct Evaluation
```
E ⊢ e_i ⇓ v_i
————————————————————————————————————————————————————————————
E ⊢ struct { f1: e1, ;... fn: en } ⇓ { f1: v1, ... fn: vn }
```

Field access:
```
E ⊢ s ⇓ { ... , f: v, ... }
————————————————————————————
E ⊢ s.f ⇓ v
```

---

### Array Evaluation
```
E ⊢ e_i ⇓ v_i
—————————————————————————————————————————————
E ⊢ [N]T{ e1, e2, ... } ⇓ array(v1, v2, ...)
```

Indexing:
```
E ⊢ a ⇓ array(v0, v1, v2, ...)
E ⊢ i ⇓ k
———————————————————————————————
E ⊢ a[k] ⇓ vk
```

---

### Map Evaluation
```
E ⊢ e_i ⇓ (k_i, v_i)
———————————————————————————————————————————————————
E ⊢ map[K]V{ k1: v1, k2: v2, ... } ⇓ {k2↦v2, ... }
```

Access:
```
E ⊢ m ⇓ { k1↦v1, ..., kn↦vn }
E ⊢ e ⇓ ki
———————————————————————————————
E ⊢ m[e] ⇓ vi
```

---

### Type Checking

Assignments require compatible types.
```
x: T, y: T
——————————
x = y
```

Struct field must be accesed with valid name.\
Function return types are checked against declared type or inferred if omitted.

---

### Value VS Reference Semantics

| Type Category | Behavior | Copy or Reference |
|----------------|-----------|------------------|
| `int`, `float`, `bool`, `string` | Value | Copy |
| `struct`, `array` | Value | Copy |
| `map` | Reference | Shared |

Examples:
```
a := Point{x: 1, y: 2}
b := a
b.x = 5
// a.x == 1 (value copy)

users := map[string]int{"bob": 20}
ages := users
users["bob] = 99
// ages["bob"] == 99 (shared reference)
```

---

## Optional Static Typing

Ori supports **optional static typing**.\
Developers can omit types when they are obvious or inferred from context.

Example
```
var message   = "Hello"  // inferred as string
var count int = 10       // explicit
func add(a int, b int) { // typed
  print(a + b)
}
```

The compiler enforces consistent typing at compile time, with inference restricted to local and unambigous cases.

---

## Numeric Type Enforcement

Ori enforces explicit typing for numeric types to privent ambiguity and unsafe coercions.

### Rules
| Category | Inference | Example | Behavior |
|-----------|------------|----------|-----------|
| Integer   | ❌ explicit | `var x int = 10` | Must specify numeric type |
| Float     | ❌ explicit | `var y float = 1.5` | Must specify type |
| Boolean   | ✅ inferred | `var ok = true` | Inferred |
| String    | ✅ inferred | `var name = "Ori"` | Inferred |
| Other types | ✅ inferred | `var arr = [1, 2, 3]` | Inferred |

### Reasoning
- Prevents silent int↔float coercions.
- Improves determinism and low-level safety.
- Keeps syntax simple for non-numeric types.

---

## Example Programs

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

```
type Point struct {
  x int
  y int
}

func move(p Point, dx, dy int) Point {
  p.x = p.x + dx
  p.y = p.y + dy
  return p
}

func main() {
  var a Point = Point{x: 1, y: 2}
  var b = move(a, 3, 4)

  var users map[string]int = {"alice": 10, "bob": 20}
  users["bob"] = users["bob"] + 5

  print(b.x, b.y)
  print(users["bob"])
}
```

---

© 2025 Ori Language — Design Spec
