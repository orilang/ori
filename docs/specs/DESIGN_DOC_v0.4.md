# Ori Programming Language — Design Document

## Overview

Ori is a **systems-capable general-purpose programming language** designed for **speed**, **clarity**, **predictability**, and **explicit behavior**.
It gives you full control over memory and performance without any `garbage collector` or `runtime` management.\
It provides predictable behavior (no implicit allocation, initialization, or reflection), deterministic performance, and zero hidden runtime costs.

> **Core principle:** *Everything in Ori must be explicit, predictable, and visible in code.*

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

### Identifier Naming and Visibility Rules

Identifiers name variables, functions, constants, types, struct fields, and methods.
They use **ASCII letters, digits, and underscores**; visibility is determined by **initial capitalization**.

```
Identifier = unicode_letter { unicode_letter | unicode_digit | "_" } .
```
Identifiers are case-sensitive.

---

**Syntax (EBNF)**
```
Letter      = "A" … "Z" | "a" … "z" .
Digit       = "0" … "9" .
Identifier  = Letter { Letter | Digit | "_" } .
```

---

**Rules**
1. Must begin with a letter (`A–Z` or `a–z`).
2. May contain letters, digits, and `_`.
3. **Cannot start** with `_` or a digit.
4. Case-sensitive.
5. **Uppercase** initial (`A–Z`) → **exported** (public across modules).
6. **Lowercase** initial (`a–z`) → **private** (module-scoped).
7. **Non-ASCII** in identifiers is **illegal**.
8. The single `_` (blank identifier) is **reserved** for a future version; not defined in v0.4.

---

**Examples (valid)**
`User`, `user`, `UserName`, `user_name`, `MAX_VALUE`, `index1`

---

**Invalid**
`_User`, `123User`, `ΔUser`, `ユーザー`

---

**No reflection** (runtime or compile-time) in v0.4—privacy cannot be bypassed.

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
Program      = PackageDecl { ImportDecl } { TopLevelDecl } ;
TopLevelDecl = FuncDecl | VarDecl | Statement .
```

---

### Function Declaration
```
FuncDecl       = "func" Identifier "(" [ ParameterList ] ")" [ ReturnTypes ] Block .
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

### If statement

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

### Switch statement

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

### For statement

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

### Types

```
Type = "int" | "float" | "bool" | "string" | Identifier .
```

---

### Comments

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

### Slices (Dynamic arrays)

```
SliceDecl = "[" "]" Type .
```

Example:
```
var nums []int = [1, 2, 3]
nums = append(nums, 4)
```

Properties:
- reference semantics like map
- can grow dynamically
- built-in `len()` and `append()` functions
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

### Package and Import
```
PackageDecl = "package" Identifier .
ImportDecl  = "import" ( ImportSpec | "(" { ImportSpec } ")" ) .
ImportSpec  = [ ImportAlias ] ImportPath .
ImportAlias = Identifier .
ImportPath  = String .
```

Example:
```
package main

import "fmt"
import io "io/ioutil"

import (
    "os"
    "net"
)
```

---

### Import Semantics

Ori’s import system is **explicit, static, and side-effect free**.

✅ Supported
```ori
import "fmt"
import io "io/ioutil"
import (
    "os"
    "net"
)
```

🚫 Not supported
```ori
import _ "database/sql/driver"  // blank import
import . "fmt"                   // dot import
```

#### Rationale

Ori does **not** support **blank (`_`)** or **dot (`.`)** imports because they introduce implicit side effects, uncontrolled initialization, and hidden dependencies.

- **Blank imports** in Go execute package-level initializers and `init()` functions, causing code to run implicitly when the package is imported.
  This can hide state changes, network connections, or registration logic that’s not visible to the programmer.

- **Dot imports** merge identifiers from another package into the current scope, creating naming ambiguity and making code less readable.

Ori enforces:
- **No implicit code execution** on import
- **No global initialization side effects**
- **No namespace pollution**

This ensures imports are **purely declarative** and **compile-time only**, following the model of languages like **Zig** and **Rust**, where importing a module never changes runtime behavior unless explicitly invoked by the programmer.

> **Design Principle:** In Ori, `import` brings *symbols*, not *side effects*.

---

### Multiple Return Values

```
ReturnTypes = "(" Type { "," Type } ")" | Type .
```

Example:
```
func div(a, b int) (int, error) {
  if b == 0 {
    return 0, error("division by zero")
  }
  return a / b, nil
}
```

---

### Error Type

```
ErrorType = "error" .
```

Properties:
- built-in reference type representing an error
- literal creation: `error("message")`
- zero value: `nil`

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
| `map`, `slice`, `error` | Reference | Shared |

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

### Slices

```
E ⊢ [v1, v2, ... vn ] ⇓ slice(v1, v2, ... vn)
————————————————————————————————————————————————————————
E ⊢ append(slice(v1, ... vn), v) ⇓ slice(v1, ... vn, v)
```

Slices share memory -- assignment copies the reference, not data.

---

### Errors

```
E ⊢ error("message") ⇓ error_value("message")
————————————————————————————————————————————————————————
E ⊢ nil ⇓ error_value(nil)
```

Returning error:
```
E ⊢ return v1, v2 ⇓ (v1, v2)
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

## Built-in functions

| Name | Description | Example |
|------|-------------|---------|
| len(x) | return number of elements | len(arr) |
| append(x, v) | append elements to slice | append(nums, 10) |
| error(message) | create new error | error("fail") |
| print(v...) | outputs to stdout | print("hello", x) |

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

```
package main

import "fmt"

type Point struct {
  x int
  y int
}

func scale(points []Point, factor int) error {
  if factor == 0 {
    return error("invalid factor")
  }
  for i:= 0; i < len(points); i++ {
    points[i] = points[i].x * factor
    points[i] = points[i].y * factor
  }
  return nil
}

func main() {
  points := Point = [Point{ {1, 2} , {3, 4} }]
  err := scale(points, 2)
  if err != nil {
    print(err)
    return
  }
  fmt.Print(points)
}
```

---

## Design Principles Summary

Ori’s language design is guided by a small set of core principles ensuring clarity, predictability, and control.

### Explicit Over Implicit

All program behavior must be visible in code.\
Ori rejects automatic execution, hidden initialization, or implicit conversions.

> _Nothing happens behind your back._

### Clarity Over Cleverness

Syntax favors simplicity and readability over terseness.\
Ori disallows:
- dot imports (`import . "pkg"`)
- implicit type coercion
- automatic global initialization

### Purity of Imports

Imports are compile-time only and side-effect free.\
Importing a package never runs code — it only brings symbols into scope.

### Value Transparency

Each operation’s cost (copy vs reference) is explicit and deterministic.
Data semantics follow clear rules:
- Structs and arrays: value (copy) semantics
- Maps, slices, and errors: reference semantics

### Optional but Safe Typing

Developers can omit types where context is clear, but numeric and precision-critical types must be explicit.\
Inference is local, predictable, and never changes runtime semantics.

### No Global State Magic

Global registries or automatic side effects are forbidden.
Initialization must be explicit, controlled, and testable.

### Predictable Execution Model

Every line of code runs in a deterministic order.\
No hidden scheduling, background threads, or automatic init sequences.

> Ori code should behave the same way tomorrow, next year, or on another machine.

---

© 2025 Ori Language — Design Spec v0.4
