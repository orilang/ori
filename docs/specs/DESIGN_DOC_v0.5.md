# Ori Design Specification — Version 0.5

Welcome to the Ori language design documentation (v0.5).
This directory contains the official specification, structured into thematic sections.

---

## 📚 Table of Contents

### Core
- [001_Introduction](001_Introduction.md)
- [002_Language_Overview](002_Language_Overview.md)

### Syntax
- [Program Structure](syntax/010_ProgramStructure.md)
- [Lexical Elements](syntax/005_LexicalElements.md)
- [Literals](syntax/015_Literals.md)
- [Declarations](syntax/020_Declarations.md)
- [Variables](syntax/030_Variables.md)
- [Functions](syntax/040_Functions.md)
- [Types](syntax/050_Types.md)
- [Statements](syntax/060_Statements.md)
- [Expressions](syntax/070_Expressions.md)
- [Blocks](syntax/080_Blocks.md)
- [Modules and Imports](syntax/090_ModulesAndImports.md)
- [Syntax Summary](syntax/095_SyntaxSummary.md)
- [Comments](syntax/100_Comments.md)
- [Tokens And Operators](syntax/101_TokensAndOperators.md)

### Semantics
- [Slices](semantics/100_Slices.md)
- [Arrays](semantics/101_Arrays.md)
- [Maps](semantics/110_Maps.md)
- [HashMaps](semantics/111_HashMaps.md)
- [Strings](semantics/120_Strings.md)
- [Numeric Types](semantics/121_NumericTypes.md)
- [Structs](semantics/130_Structs.md)
- [Errors](semantics/140_Errors.md)
- [Types and Memory](semantics/150_TypesAndMemory.md)
- [Control Flow](semantics/160_ControlFlow.md)
- [Methods And Interfaces](semantics/170_MethodsAndInterfaces.md)
- [Runtime And PanicHandling](semantics/180_RuntimeAndPanicHandling.md)
- [Concurrency](semantics/190_Concurrency.md)

### Design Principles
- [Language Philosophy](design_principles/001_LanguagePhilosophy.md)
- [TypeSafety And Explicitness](design_principles/002_TypeSafetyAndExplicitness.md)
- [Error Handling Philosophy](design_principles/003_ErrorHandlingPhilosophy.md)
- [Runtime And Memory Philosophy](design_principles/004_RuntimeAndMemoryPhilosophy.md)
- [Concurrency And Predictability](design_principles/005_ConcurrencyAndPredictability.md)
- [Imports And Visibility](design_principles/006_ImportsAndVisibility.md)
- [Type System Philosophy](design_principles/007_TypeSystemPhilosophy.md)

### Appendix
- [Keywords](appendix/001_Keywords.md)
- [Builtins](appendix/002_Builtins.md)
- [Grammar Index](appendix/003_GrammarIndex.md)
- [Glossary](appendix/004_Glossary.md)

---

## 🔗 Full Specification
A complete concatenated version of this documentation is available here:  
👉 [DESIGN_DOC_v0.5_FULL.md](DESIGN_DOC_v0.5_FULL.md)

---

# 1. Introduction

**Ori** is a **system-capable general-purpose programming language** designed for **clarity, performance, and explicit control**.

It combines the **expressiveness of high-level languages** with the **predictability and precision of systems languages**, allowing developers to build everything — from **operating systems and compilers** to **UI applications and web servers** — using a single consistent model of execution.

Ori’s design emphasizes:
- **Explicit behavior** — nothing happens implicitly.
- **Predictable performance** — copy and reference semantics are always visible in code.
- **Deterministic safety** — clear lifetime, memory, and error rules.

## 1.1 Goals

Predictable and explicit semantics.  
Clear and consistent syntax.  
Safe memory and type model.  
Zero hidden behaviors.

## 1.2 Document Structure
The specification is split across modular files for clarity:
- Core syntax and semantics in `/syntax` and `/semantics/`
- Design rationale and comparisons in `/design_principles/`
- Reference material in `/appendix/`

See the [index](000_INDEX.md) for navigation.

## 1.3 Notation

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

## 1.4 Source code encoding

Ori source code is encoded in [UTF-8](https://en.wikipedia.org/wiki/UTF-8).  
Invalid UTF-8 sequence will endup in a compilation error.

---
# 2. Language Overview

This document provides a high-level overview of the Ori programming language: its syntax, design philosophy, and core concepts.  
It serves as a quick introduction for readers before diving into the detailed syntax and semantics sections.

---

## 2.1 Design Goals

Ori is a **system-capable general-purpose programming language** focused on:

- **Explicitness over magic** — all operations and allocations are visible.
- **Predictability** — no hidden control flow, conversions, or memory semantics.
- **Safety without verbosity** — strong typing and value semantics, but concise.
- **Simplicity** — syntax easy to learn and consistent across constructs.
- **Performance** — close to C-level performance with predictable memory layout.

---

## 2.2 Syntax

A minimal Ori program:

```ori
package main

import "fmt"

func main() {
  var name = "Ori"
  fmt.Println("Hello,", name)
}
```

**`package`** declares the current compilation unit.  
**`import`** brings modules into scope.  
**`func`** declares a function (with explicit parameter types and return types).  
**`var`** declares variables.

---

## 2.3 Core Building Blocks

| Concept | Description | Reference |
|----------|--------------|------------|
| **Program** | A set of packages and modules forming a build unit. | [Program Structure](syntax/010_ProgramStructure.md) |
| **Variables** | Explicitly declared, strongly typed bindings. | [Variables](syntax/030_Variables.md) |
| **Functions** | First-class citizens with value and pointer receivers. | [Functions](syntax/040_Functions.md) |
| **Structs** | Predictable layout composite types. | [Structs](semantics/130_Structs.md) |
| **Slices & Maps** | Safe, efficient data structures with value semantics. | [Slices](semantics/100_Slices.md), [Maps](semantics/110_Maps.md), [HashMaps](semantics/111_HashMaps.md) |
| **Errors** | Typed error handling — no exceptions. | [Errors](semantics/140_Errors.md) |
| **Modules** | Importable units of code; no hidden side effects. | [Modules and Imports](syntax/090_ModulesAndImports.md) |

---

## 2.4 Type System Overview

Ori enforces **strong, static typing**.  
Every variable and expression has a well-defined type at compile-time.

Key properties:
- Type inference where unambiguous (`var x = "Ori"` ⇒ `string`).
- Explicit conversions (`int(a)`), no silent coercions.
- User-defined types via `type` and `struct`.
- No implicit nilability — pointers and optionals are distinct types.

See: [Types](syntax/050_Types.md)

---

## 2.5 Memory and Ownership Model

Ori follows a **value-first memory model** similar to Go, with explicit reference types where needed.

- Structs, arrays, and primitives are passed **by value** by default.
- References are explicit (`&T` / `*T` planned for pointer-like types).
- Slices, strings, and maps are *views over data* with defined copy semantics.
- No hidden allocations — all growth operations (e.g., `append`) may allocate.

See: [Types and Memory](semantics/150_TypesAndMemory.md)

---

## 2.6 Control Flow

Ori provides familiar structured control flow constructs:

- `if` / `else` statements.
- `for` loops with range iteration.
- `switch` expressions for pattern-based dispatch.
- `return`, `break`, and `continue` for flow control.

See: [Statements](syntax/060_Statements.md)

---

## 2.7 Language in Context

| Feature | Ori | Go | Rust | Zig |
|----------|-----|----|------|-----|
| Memory Model | Value + explicit refs | GC | Ownership | Manual/Allocator |
| Errors | Result-style | `error` | `Result` | `error union` |
| Generics | Planned | Yes (Go 1.18+) | Yes | Yes |
| FFI | Planned, C-compatible | Yes | Yes | Yes |
| Build Philosophy | Unified toolchain | Unified | Cargo-based | Self-hosted |

---

## 2.8 Next Steps

Continue reading:
- [Program Structure](syntax/010_ProgramStructure.md)
- [Declarations](syntax/020_Declarations.md)
# 5. Lexical Elements

This section defines the lexical structure of Ori source code — the lowest level of syntax recognized by the tokenizer.

---

## 5.1 Character Set

Ori source files are encoded in **UTF-8**.  
All identifiers, string literals, and comments use Unicode characters.

Line endings may be either `LF` or `CRLF` and are treated equivalently.

---

## 5.2 Whitespace

Whitespace characters (space, tab, newline, carriage return) are ignored except when separating tokens.

---

## 5.3 Tokens

Tokens are the basic lexical units of Ori source code. They are classified as:

| Category | Examples |
|-----------|-----------|
| Identifiers | `main`, `userName`, `fmt` |
| Keywords | `func`, `var`, `if`, `for` |
| Operators | `+`, `-`, `==`, `&&` |
| Delimiters | `(`, `)`, `{`, `}`, `,`, `;` |
| Literals | `42`, `"hello"`, `true` |

Tokens are separated by whitespace, comments, or delimiters.

---

## 5.4 Identifiers

Identifiers name program entities such as variables, functions, and types.

### Rules
- Must begin with a letter (`A–Z`, `a–z`).
- May contain ASCII letters, digits, and underscores (`_`).
- Cannot start with a digit.
- Case-sensitive.

### Examples

```ori
var userName = "Alice"
func GetUser(id int) User
```

Names beginning with an uppercase letter are **exported** (visible across packages).

---

## 5.5 Keywords

The following words are reserved and cannot be used as identifiers:

```
package import var const func type struct if else for switch return break continue true false nil
```

Future keywords may include `interface`.

---

## 5.6 Operators and Delimiters

See: [Tokens and Operators](syntax/101_TokensAndOperators.md)

---

## 5.7 Comments

Comments are treated as whitespace and ignored by the compiler.

See: [Comments](syntax/100_Comments.md)

---


# 10. Program Structure

This section describes how an Ori program is organized — from packages and files to the entry point of execution.

---

## 10.1 Overview

An Ori program is composed of one or more **packages**.  
Each package is a directory containing one or more `.ori` source files that share the same package name.

Packages provide a namespace and form the basic unit of compilation and dependency management.

```text
myapp/
 ├── main.ori
 ├── util/
 │    ├── strings.ori
 │    └── math.ori
 └── net/
      └── client.ori
```

---

## 10.2 Package Declaration

Every `.ori` source file begins with a package declaration:

```ori
package main
```

The package name defines the namespace of the file.  
All files in the same directory must share the same package name.  
A `main` package indicates that the program is an executable with an entry point (`main` function).

---

## 10.3 Import Declarations

Imports bring other packages or modules into the current scope:

```ori
import "fmt"
import "net/http"
```

Multiple imports can be grouped:

```ori
import (
    "fmt"
    "math"
    "net"
)
```

Ori allows optional **import aliases** for disambiguation:

```ori
import io "os/io"
```

- The alias `io` is used to reference the imported package
- The underscore `_` alias (blank import) is forbidden
- The ot `.` import is forbidden

See: [Modules and Imports](syntax/090_ModulesAndImports.md)

---

## 10.4 The `main` Function

The entry point of an Ori executable is the `main` function inside the `main` package:

```ori
package main

func main() {
    fmt.Println("Hello, Ori!")
}
```

- The function must have no parameters and no return value.
- The program terminates when `main` returns.

---

## 10.5 Program Execution Model

Execution begins with package initialization in dependency order, followed by `main`.

1. Imported packages are initialized in dependency order.
2. Global constants are set up.
3. Global variables are forbidden.
4. The `main.main()` function is invoked.

This deterministic initialization ensures reproducibility and predictability.

---

## 10.6 File Layout Guidelines

Recommended file organization:

| File Type | Purpose |
|------------|----------|
| `main.ori` | Entry point of executable package. |
| `*.ori` | Standard source files within the same package. |
| `_test.ori` | Optional future test files. |

Example layout:

```text
math/
 ├── math.ori
 └── vector.ori
main/
 └── main.ori
```

---

## 10.7 Example Program

```ori
package main

import (
    "fmt"
    "math"
)

func main() {
    var x float = 2.0
    var y = math.Sqrt(x)
    fmt.Println("√", x, "=", y)
}
```

---

## References
- [Declarations](syntax/020_Declarations.md)
- [Modules and Imports](syntax/090_ModulesAndImports.md)

---


# 15. Literals

Literals represent fixed constant values embedded directly in Ori source code.

---

## 15.1 Overview

A literal is a lexical token that denotes a value such as a number, string, boolean, or nil.

Examples:

```ori
42
3.14
"hello"
true
nil
```

---

## 15.2 Integer Literals

Integer literals represent whole numbers.

### Decimal
```ori
var a int = 123
```

### Hexadecimal
```ori
var b = 0xFF
```

### Binary (planned)
```ori
var c = 0b1010
```

### Rules
- Underscores (`_`) may be used as visual separators (e.g., `1_000_000`).
- Negative values use the unary `-` operator.

---

## 15.3 Floating-Point Literals

Floating-point literals represent real numbers.

```ori
var pi float = 3.1415
var exp int = 1e-9
```

Both decimal and exponent notation are supported.

---

## 15.4 String Literals

String literals represent immutable sequences of Unicode characters.

```ori
var msg = "Hello, Ori!"
```

Enclosed in double quotes (`"`).  
Supports escape sequences (`\n`, `\t`, `\"`, `\\`).\
Raw strings using backticks (planned).

---

## 15.5 Rune Literals (Planned)

Rune literals represent single Unicode code points.

```ori
var ch = 'A'
```

Planned for future versions.

---

## 15.6 Boolean Literals

Booleans have two constant values: `true` and `false`.

```ori
var ok = true
var done = false
```

---

## 15.7 Nil Literal

`nil` represents the absence of a value.

It may be used with pointers, slices, maps, and optional types (when introduced).

```ori
var data = nil
```

---

## 15.8 Summary

| Type | Example | Notes |
|-------|----------|--------|
| Integer | `123`, `0xFF` | Base 10 or 16 |
| Float | `3.14`, `1e-9` | Decimal or exponent |
| String | `"text"` | Double-quoted, UTF-8 |
| Boolean | `true`, `false` | Logical constants |
| Nil | `nil` | Absence of value |

---


# 20. Declarations

This section defines how identifiers are declared in Ori — including constants, variables, functions, types, and structs.

---

## 20.1 Overview

A **declaration** introduces a new name into the program scope and binds it to a value, type, function, or constant.

```ori
const float PI = 3.1415
type User struct {
  id int
  name string
}
```

Declarations appear at package, function, or block level.

---

## 20.2 Kinds of Declarations

| Kind | Keyword | Example |
|------|----------|----------|
| Constant | `const` | `const int limit = 100` |
| Variable | `var` | `var count int = 0` |
| Function | `func` | `func add(a, b int) int { return a + b }` |
| Type | `type` | `type Age = int` |
| Struct | `struct` | `type Point struct { x int, y int }` |

---

## 20.3 Constant Declarations

Constants are immutable compile-time values.

```ori
const MaxRetries int = 5
const Message        = "Hello"
```

Constants must be initialized with constant expressions (no runtime computation).

---

## 20.4 Type Declarations

Type aliases and named types provide clarity and stronger semantics.

```ori
type ID int
type User struct {
    id ID
    name string
}
```

---

## 20.5 Function Declarations

Functions define reusable behavior.  
They can be declared at the top level or within other functions (nested functions are allowed).

```ori
func greet(name string) {
    fmt.Println("Hello,", name)
}
```

See: [Functions](syntax/040_Functions.md)

---

## 20.6 Struct Declarations

Structs define aggregate types with named fields.

```ori
type Point struct {
    x int
    y int
}
```

Structs support **value semantics** and **explicit field access**.

See: [Structs](semantics/130_Structs.md)

---

## References

- [Variables](syntax/030_Variables.md)
- [Functions](syntax/040_Functions.md)

---


# 30. Variables

This section explains variable declarations, initialization rules, naming conventions, and assignment behavior in Ori.

---

## 30.1 Overview

A **variable** holds a typed value that can change during program execution.  
All variables must be **explicitly declared** before use.

```ori
var count int   = 0
var name string = "Ori"
```

---

## 30.2 Grammar

```
VarDecl = "var" Identifier [ Type ] "=" Expression | Identifier ":=" Expression .
```

### Numeric Type Enforcement

Ori enforces explicit typing for numeric types to prevent ambiguity and unsafe coercions.

#### Rules

| Category | Inference | Example | Behavior |
|-----------|------------|----------|-----------|
| Integer   | ❌ explicit | `var x int = 10` | Must specify numeric type |
| Float     | ❌ explicit | `var y float = 1.5` | Must specify type |
| Boolean   | ✅ inferred | `var ok = true` | Inferred |
| String    | ✅ inferred | `var name = "Ori"` | Inferred |
| Other types | ✅ inferred | `var arr = [1, 2, 3]` | Inferred |

#### Reasoning

Prevents silent int↔float coercions.  
Improves determinism and low-level safety.  
Keeps syntax simple for non-numeric types.

### Short form

Type is inferred from the initializer:
```ori
var s = "hello"   // inferred as string
```

### Explicit form

Type annotation is provided explicitly:
```ori
var s string = "hello"
```

---

## 30.3 Naming Rules

Identifiers follow a strict naming conventions for safety and clarity:
- Must start with a letter (`A–Z` or `a–z`).
- May contain ASCII letter, digits, or underscores (`_`).
- Cannot start with underscore `_`, a digit or contain spaces.
- Case-sensitive.
- Names beginning with a **uppercase letter** are **exported**.
- Names beginning with a **lowercase letter** are **private**.
- **Non-ASCII** in identifiers is **illegal**.
- The underscore (`_`) is reserved as the **blank identifier** for a future version.

**Valid examples**:
```
User
user
UserName
user_name
MAX_VALUE
index1
```

**Invalid examples**:
```
_User
123User
ΔUser
ユーザー
école
```

---

## 30.4 Initialization Rules

Ori **does not** perform automatic zero-initialization.  
Every variable must be **fully initialized** before use.
Uninitialized variable **cannot** be read or used which will result in compile-time error.  
Variables cannot be redeclared in the same scope.

```ori
var a int = 1  // ✅ valid
a = 2          // ✅ valid reassignment
var a int = 3  // ❌ invalid, variable already declared
var b int      // ❌ invalid, variable uninitialized, compile-time error
var c bool     // ❌ invalid, variable uninitialized, compile-time error
var d string   // ❌ invalid, variable uninitialized, compile-time error
var e float    // ❌ invalid, variable uninitialized, compile-time error
const f float  // ❌ invalid, variable uninitialized, compile-time error
```

---

## 30.5 Mutability

By default, `var` bindings are **mutable** — their value can be reassigned.
`const` bindings are **immutable** — their value cannot be reassigned.

```ori
var x int = 10     // ✅ valid mutable binding
x = 20             // ✅ valid mutable binding
const xy int = 10  // ✅ valid immutable binding
xy = 20            // ❌ invalid immutable binding
```

---

## 30.6 Variable Lifetime and Scope

Variables declared inside a block are destroyed when the block ends.
Package-level variables exist for the program’s lifetime.
Shadowing within the same block is not allowed.

```ori
func demo() {
    var x = 10
    if true {
        var y = 5
        fmt.Println(x, y)
    }
    // y is no longer accessible here
}
```

---

## 30.7 Blank Identifier

The underscore `_` can be used to discard unwanted values or suppress warnings.

```ori
var _, b = computePair()
```

This identifier is **write-only** and cannot be read.

---

## 30.8 Best Practices

Use short or meaningful names for local variables.  
Prefer `const` when immutability is guaranteed.  
Avoid using underscores except for temporary or ignored values.

---

## 30.9 Examples

```ori
func main() {
    var name = "Ori"
    var age int = 3
    fmt.Println(name, age)
}
```

## 30.10 Global variables

Global variables refer to values declared at the package level and accessible from any scope within that package.  
While convenient, they introduce implicit dependencies, hidden state, and concurrency risks.  
Ori aims to balance **practical usability** with **predictability and safety**.

Global variables are forbidden, only `const` variables are allowed.

Valid example:
```ori
package main

const xy int = 20 // ✅ valid declaration

func main() {
  print("xy", xy) // program will work
}
```

Invalid example:
```ori
package main

var x int = 10 // ❌ forbidden declaration, compile-time error

func main() {
  print("x", x)
}
```

---

## References
- [Declarations](syntax/020_Declarations.md)
- [Types](syntax/050_Types.md)

---


# 40. Functions

This section describes the syntax, semantics, and conventions of function declarations and calls in Ori.

---

## 40.1 Overview

Functions are first-class citizens in Ori.  
They define reusable code blocks with clearly typed parameters and return values.

```ori
func add(a int, b int) int {
    return a + b
}
```

Functions are declared using the `func` keyword.  
Parameters and return types are explicit.

---

## 40.2 Grammar

```
FuncDecl       = "func" Identifier "(" [ ParameterList ] ")" [ ReturnTypes ] Block .
ParameterList  = ParameterGroup { "," ParameterGroup } .
ParameterGroup = Identifier { "," Identifier } [ Type ] .
Statement      = Expression | ReturnStmt .
ReturnStmt     = "return" [ Expression ] .
```

Examples:

```ori
func greet(name string) {
    fmt.Println("Hello,", name)
}

func sum(a int, b int) int {
    return a + b
}

// shorthand notation of func sum(a int, b int) int
func sum(a, b int) int {
    return a + b
}
```

---

## 40.3 Return Semantics

Functions may return zero, one, or multiple values.  
Return types are always explicit.

```ori
func divide(a int, b int) (int, bool) {
    if b == 0 {
        return 0, false
    }
    return a / b, true
}
```

---

## 40.4 Named Returns (Planned)

Named return variables are under consideration for future versions but are **not implemented** in v0.5.

---

## 40.5 Receivers and Methods

Functions can be declared with an explicit **receiver** to define methods on types:

```ori
type Point struct {
    x int
    y int
}

func (p Point) Length() float64 {
    return math.Sqrt(float64(p.x*p.x + p.y*p.y))
}
```

Receivers are always explicit:
- `value` receivers copy the struct.
- `pointer` receivers (planned) allow mutation.

---

## 40.6 Function Values

Functions are first-class values and can be assigned to variables or passed as arguments.

```ori
func apply(func func(int) int, x int) int {
    return func(x)
}

func double(x int) int {
    return x * 2
}

result := apply(double, 4)
```

---

## 40.7 Anonymous Functions and Closures

Anonymous (lambda) functions are supported:

```ori
inc := func(x int) int {
    return x + 1
}

var dec = func(x int) int {
    return x - 1
}

fmt.Println(inc(5)) // 6
fmt.Println(dec(2)) // 4
```

Closures capture surrounding variables by value.

---

## 40.8 Variadic Functions (Planned)

Variadic parameter syntax is under consideration:
```ori
func sum(nums ...int) int
```

---

## 40.9 Error Handling in Functions

Functions can return an error type or `Result<T, E>` equivalent for explicit error propagation.

```ori
func readConfig() error {
    ...
}

func readFile(path string) (string, error) {
    if path == "" {
        return "", error("empty path")
    }
    return "data", nil
}
```

See: [Errors](semantics/140_Errors.md)

---

## 40.10 Examples

```ori
package main

func factorial(n int) int {
    if n <= 1 {
        return 1
    }
    return n * factorial(n - 1)
}
```

---

## References

- [Types](syntax/050_Types.md)
- [Blocks](syntax/080_Blocks.md)

---


# 50. Types

This section defines Ori’s type system, built-in types, user-defined types, and conversion rules.

---

## 50.1 Overview

Ori uses a **strong, static, and explicit** type system.  
All variables, parameters, and expressions have a known type at compile time.

Goals:
- Prevent implicit conversions.
- Make memory layout predictable.
- Support composable, user-defined types.

---

## 50.2 Grammar

```
Type         = IdentType | ArrayType | SliceType | MapType | HashMapType | PointerType | StructType | FuncType .
SliceType    = "[]" Type .
MapType      = "map" "[" Type "]" Type .
HashMapType  = "hashmap" "[" Type "]" Type .
PointerType  = "&" Type .
StructType   = "struct" "{" { FieldDecl ";" } "}" .
```

## 50.3 Built-in Types

| Category | Types | Description |
|-----------|--------|-------------|
| Boolean | `bool` | true or false |
| Integers | `int8`, `int16`, `int32`, `int64`, `int`, `uint`, `uint8`, `uint32`, `uint64`, `uint` | signed and unsigned |
| Floating-point | `float32`, `float64`, `float` | IEEE 754 compliant |
| String | `string` | UTF-8 encoded immutable text |
| Byte and Rune | `byte`, `rune` | 8-bit and 32-bit character units |
| Compound | `array`, `slice`, `map`, `struct` | composite data types |

---

## 50.4 Type Inference

The compiler infers the type when it is clear from the initializer:

```ori
var message = "hi"     // inferred as string
message2 := "hi again" // inferred as string
var myFunc := func()   // inferred as func
x := false             // inferred as bool
```

Ori enforces explicit typing for numeric types to privent ambiguity and unsafe coercions.
```ori
var x = 0     // invalid
var x int = 0 // valid
```

---

## 50.5 User-Defined Types

Use the `type` keyword to define new named types:

```ori
type ID int
type User struct {
    id ID
    name string
}
```

Named types create distinct semantic types even if the underlying representation matches.

---

## 50.6 Struct Types

Structs group multiple named fields into one type.

```ori
type Point struct {
    x int
    y int
}
```

Structs have **value semantics** and predictable in-memory layout.

See: [Structs](semantics/130_Structs.md)

---

## 50.7 Array and Slice Types

```ori
var numbers [5]int       // fixed-size array
var dynamic []int        // slice (dynamic view)
```

Arrays have fixed length known at compile-time.  
Slices are dynamically sized references to contiguous elements.

See: [Slices](semantics/100_Slices.md)

---

## 50.8 Map Types

```ori
var users map[string]int
var people hashmap[string]int
```

Maps associate keys with values and are dynamically allocated.

See: [Maps](semantics/110_Maps.md)

---

## 50.9 Type Conversion

Conversions must always be **explicit**:

```ori
var x int = 5
var y float64 = float64(x)
```

---

## 50.10 Pointer and Reference Types

Pointers will allow explicit referencing and dereferencing:

```ori
var p = &value
var v = *p
```

Ori will ensure **no unsafe implicit pointer arithmetic**.

---

## 50.11 Type Qualifiers

Qualifiers modify type semantics.  
Currently supported: `const`.

Example:

```ori
const MAX_USERS = 100
```

---

## 050.12 Types — Error Type Integration

This note integrates the canonical `Error` struct into the type system.

### 050.12.1 Error Type

Ori defines one builtin error struct:

```ori
type Error struct {
    Message const string
    Code    const int
}
```

### 050.12.2 Properties

`Error` is a regular struct type with two `const` fields.  
`Error` is used by convention as the return type for operations that may fail:

```ori
func Open(path string) (File, Error)
```

- `nil` is the zero-value for the `Error` result position and represents success.

### 050.12.3 Usage Rules

Functions that can fail should return `(T, Error)` or `(Error)` when no value is produced.  
Sentinel errors are declared as `const` values of type `Error`:

```ori
const ErrInvalidUser Error = Error{
    Message: "invalid user",
    Code:    1001,
}
```

- Custom error structs may be declared, but they are confined to APIs that explicitly use them and are not interchangeable with `Error` in function signatures.

---

## 50.13 Summary

| Feature | Behavior |
|----------|-----------|
| Type inference | Only when unambiguous |
| Explicit conversion | Required |
| Memory model | Value by default |
| Pointers | Planned |

---

## References
- [Variables](syntax/030_Variables.md)
- [Structs](semantics/130_Structs.md)
- [Slices](semantics/100_Slices.md)
- [Maps](semantics/110_Maps.md)

---


# 60. Statements

This section describes the statement constructs available in Ori — the building blocks of control flow and program logic.

---

## 60.1 Overview

A **statement** performs an action — executing code, declaring variables, controlling flow, or evaluating expressions for side effects.

Examples:

```ori
var x int = 10
x = x + 1
if x > 10 {
    fmt.Println("x is large")
}
```

---

### 60.2 Grammar

```
Block        = "{" { Statement } "}" .
Statement    = Decl | SimpleStmt | IfStmt | ForStmt | ReturnStmt | Block .

SimpleStmt   = VarDecl | ConstDecl | AssignStmt | ExprStmt .
AssignStmt   = Expression "=" Expression
             | ExpressionList "=" ExpressionList .

IfStmt       = "if" Expression Block [ "else" Block ] .

ForStmt      = "for" Identifier [ "," Identifier ] ":=" "range" Expression Block
             | "for" Expression Block
             | "for" [ SimpleStmt ";" ] Expression [ ";" SimpleStmt ] Block .
```

## 60.2 Categories of Statements

| Category | Description |
|-----------|--------------|
| Declaration statements | Introduce new variables, constants, or types |
| Expression statements | Evaluate an expression for side effects |
| Assignment statements | Modify existing variables |
| Control statements | Manage flow (if, for, switch, etc.) |
| Block statements | Group multiple statements together |

---

## 60.3 Assignment Statement

Assignments modify existing values:

```ori
x = x + 1
name = "Ori"
```

Left-hand side must be an assignable variable.  
Both sides must have compatible types.  
Multiple assignments are supported:

```ori
x, y = y, x
```

---

## 60.4 If Statement

### Grammar

```
IfStmt = "if" [ SimpleStmt ";" ] Expression Block [ "else" (IfStmt | Block) ] .
SimpleStmt = VarDecl | Assignment | Expression .
```

### Examples

Conditional branching is handled using `if` / `else`:

```ori
if x > 10 {
    fmt.Println("big")
} else {
    fmt.Println("small")
}
```

Parentheses are not required. Blocks are mandatory.

Nested or chained conditions use `else if`:

```ori
if score > 90 {
    grade = "A"
} else if score > 75 {
    grade = "B"
} else {
    grade = "C"
}
```

More examples:
```
if a > b {
  return a
}

if a > b && c > d {
  return a * c
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

## 60.5 For Statement

Ori uses a single `for` keyword to express looping constructs.

### Grammar

```
ForStmt = "for" Identifier [ "," Identifier ] ":=" "range" Expression Block
        | "for" Expression Block
        | "for" [ SimpleStmt ";" ] Expression [ ";" SimpleStmt ] Block .
```

### Range Form

Iterate over arrays, slices, or maps:

```ori
for i, v := range items {
    fmt.Println(i, v)
}

for i := range f() {
  fmt.Println(i)
}

for _, v := range x() {
  fmt.Println(v)
}
```

### Conditional Form

```ori
for i < 10 {
    i = i + 1
}
```

### Classic Form

```ori
for i := 0; i < 5; i++ {
    fmt.Println(i)
}

for i := 5; i > 0; i-- {
    fmt.Println(i)
}

for i := 0; i < max(); i++ {
  fmt.Println(i)
}
```

See: [Grammar reference](appendix/A_GrammarReference.md)

---

## 60.6 Switch Statement

### Grammar

```
SwitchStmt = "switch" [ SimpleStmt ";" ] [ Expression ] "{" { CaseClause } "}" .
CaseClause = ( "case" ExpresionList | "default" ) ":" { Statement } .
ExpressionList = Expression { "," Expression } .
```

### Examples

```ori
switch a {
case 1:
  fmt.Println("a")
case 2:
  fmt.Println("b")
default:
  fmt.Println("c")
}

switch {
case a == 0:
  fmt.Println("a")
case b == 1:
  fmt.Println("b")
default:
  fmt.Println("c")
}

switch x {
case a, b:
  fmt.Println("x")
default:
  fmt.Println("c")
}

switch x := f() {
case a, b:
  fmt.Println("x")
default:
  fmt.Println("c")
}
```

---

## 60.7 Return Statement

### Grammar

```
ReturnStmt = "return" [ ExpressionList ] .
```

### Examples

Terminates a function and optionally returns values.

```ori
return
return x
return x, y
```

The number and types of returned values must match the function’s return signature.

---

## 60.8 Break and Continue

`break` terminates the nearest loop.  
`continue` skips to the next iteration.

```ori
for i := 0; i < 10; i++ {
    if i == 5 {
        continue
    }
    if i == 8 {
        break
    }
}
```

---

## 60.9 Block Statement

### Grammar

```
Block = "{" { Statement } "}" .
```

### Examples

A block is a sequence of statements enclosed in `{}`.

```ori
{
    var a int = 1
    var b int = 2
    fmt.Println(a + b)
    x, d int := 3, 4
    fmt.Println(c + d)
}
```

Blocks define their own lexical scope.

---

## 60.10 Defer and Panic (Planned)

Deferred calls and panic recovery are **not included in v0.5**, but may be explored later as structured constructs.

---

## References
- [Expressions](syntax/070_Expressions.md)
- [Blocks](syntax/080_Blocks.md)

---


# 70. Expressions

Expressions compute values from operands and operators.  
They are the fundamental building blocks of evaluation in Ori.

---

## 70.1 Overview

Expressions can produce values, perform computations, or invoke functions.  
Examples:

```ori
x + y
f(42)
user.name
```

---

## 70.2 Categories of Expressions

| Category | Description |
|-----------|--------------|
| Primary expressions | Identifiers, literals, grouped expressions |
| Composite expressions | Struct, array, or map literals |
| Unary expressions | Negation, address, dereference, etc. |
| Binary expressions | Arithmetic, comparison, logical operations |
| Function calls | Invocation of declared or anonymous functions |
| Selector expressions | Access fields or methods |

---

## 70.3 Primary Expressions

### Identifiers and Literals

```ori
x
42
"hello"
true
```

### Grouped Expressions

Parentheses may be used to control precedence:

```ori
(x + y) * z
```

---

## 70.4 Composite Literals

Construct composite values inline.

```ori
var p = Point{x: 1, y: 2}
var arr = [3]int{1, 2, 3}
var m = map[string]int{"a": 1, "b": 2}
```

---

## 70.5 Unary Operators

| Operator | Meaning |
|-----------|----------|
| `+x` | Unary plus (no effect) |
| `-x` | Negation |
| `!x` | Logical NOT |
| `&x` | Address of (planned) |
| `*x` | Dereference (planned) |

Examples:

```ori
var n int = -5
var ok = !false
```

---

## 70.6 Binary Operators

| Category | Operators | Example |
|-----------|------------|----------|
| Arithmetic | `+`, `-`, `*`, `/`, `%` | `a + b` |
| Comparison | `==`, `!=`, `<`, `<=`, `>`, `>=` | `x == y` |
| Logical | `&&`, `\|\|` | `x && y` |
| Bitwise | `&`, `\|`, `^`, `<<`, `>>` | `x & y` |

Operator precedence and associativity follow conventional rules.

---

## 70.7 Function Calls

Functions are invoked with parentheses enclosing arguments.

```ori
result = add(1, 2)
```

Arguments are evaluated left to right.

See: [Functions](syntax/040_Functions.md)

---

## 70.8 Field and Method Selectors

Use the dot operator to access struct fields or methods.

```ori
user.name
point.Length()
```

The left operand must be a struct or pointer to struct.

---

## 70.9 Index Expressions

Index into arrays, slices, or maps:

```ori
nums[0]
users["alice"]
```

Out-of-range accesses are runtime errors.

---

## 70.10 Type Conversion Expressions

Explicit type conversion is performed using the target type as a function:

```ori
var f = float64(3)
var i = int(3.14)
```

Implicit conversions are **not allowed**.

---

## 70.11 Composite Construction Expressions

Composite literals and function calls can be combined:

```ori
make([]int, 10)   // create slice
new(Point)        // allocate struct (planned)
```

`make` is a builtin function for allocating dynamic types like slices and maps.

---

## 70.12 Example

```ori
func main() {
    var a int = 3
    var b int = 4
    var c = math.Sqrt(float64(a*a + b*b)) // inferred float64
    fmt.Println("c =", c)
}
```

---

## References
- [Statements](syntax/060_Statements.md)
- [Functions](syntax/040_Functions.md)
- [Types](syntax/050_Types.md)

---


# 80. Blocks

Blocks in Ori define lexical scopes and group statements or declarations together.  
They are the foundation of structured programming, determining variable lifetime and visibility.

---

## 80.1 Overview

A **block** is a sequence of statements enclosed in curly braces `{}`.

```ori
{
    var x int = 10
    fmt.Println(x)
}
```

Blocks are used to:
- Group related statements
- Limit variable scope
- Define function bodies, conditionals, and loops

---

## 80.2 Grammar

```
Block = "{" { Statement } "}" .
```

Every block introduces a **new lexical scope**.

---

## 80.3 Scoping Rules

- Variables declared inside a block are **local** to that block.
- Nested blocks can shadow variables from outer scopes.
- Shadowing the same name within a single block is **not allowed**.

```ori
var x int = 1
{
    var x int = 2  // shadows outer x
    fmt.Println(x) // prints 2
}
fmt.Println(x) // prints 1
```

---

## 80.4 Block Usage

Blocks appear in multiple language constructs:

| Construct | Example |
|------------|----------|
| Function | `func main() { ... }` |
| If / Else | `if cond { ... } else { ... }` |
| For loop | `for i := 0; i < 10; i = i + 1 { ... }` |
| Switch | `switch x { ... }` |
| Standalone | `{ var a int = 1; fmt.Println(a) }` |

---

## 80.5 Nested Blocks

Blocks may be nested arbitrarily to control visibility and lifetime of variables.

```ori
func demo() {
    var a int = 1
    {
        var b int = 2
        fmt.Println(a + b)
    }
    // b is out of scope here
}
```

---

## 80.6 Lifetime and Destruction

When a block ends:
- Local variables go out of scope.
- Memory managed by the runtime (stack or heap) is released predictably.

Ori ensures deterministic destruction for value-based semantics.

---

## 80.7 Empty Blocks

Empty blocks are valid and represent no operation:

```ori
{}
```

---

## 80.8 Future Extensions

Planned for later versions:
- **Defer** statements bound to block lifetime.
- **RAII-like scope guards (Resource Acquisition Is Initialization)** for deterministic cleanup.

---

## References
- [Statements](syntax/060_Statements.md)
- [Functions](syntax/040_Functions.md)

---


# 90. Modules and Imports

Modules and imports in Ori define how source code is organized, shared, and reused across packages.

---

## 90.1 Overview

Modules group related packages into a single distribution unit.  
Imports bring external or internal packages into scope in an explicit and predictable way.

Ori’s import system is designed for **clarity** and **safety**:
- No implicit side effects
- No global variables
- No automatic initialization functions

```ori
package main

import "fmt"

func main() {
    fmt.Println("Hello, Ori!")
}
```

---

## 90.2 Module Definition

Modules are defined by a top-level manifest file (planned for v0.5) or inferred from directory structure.

Example project layout:

```text
example/
 ├── ori.mod          # (planned) module descriptor
 ├── main.ori
 └── math/
      └── calc.ori
```

---

## 90.3 Package Declaration

Each `.ori` file must begin with a `package` clause that identifies the namespace it belongs to:

```ori
package math
```

All files in the same directory share the same package name.

---

## 90.4 Import Declaration

Imports bring other packages into scope.  
There are three valid forms:

### Single Import
```ori
import "fmt"
```

### Grouped Import
```ori
import (
    "fmt"
    "math"
)
```

### Aliased Import
```ori
import io "os/io"
```

The alias can be any valid identifier. Use meaningful names to avoid conflicts.

---

## 90.5 Prohibited Imports Forms

To maintain explicitness and avoid hidden effects, Ori **does not support**:

| Syntax | Status | Reason |
|---------|---------|--------|
| `import _ "pkg"` | ❌ Not supported | No hidden initialization side effects |
| `import . "pkg"` | ❌ Not supported | Prevents namespace pollution |

Imports must always use a clear alias or the package’s own name.

---

## 90.6 Global State and Initialization

Ori does **not** allow global mutable variables.  
Only compile-time constants (`const`) are permitted at the package level.

```ori
package config

const DefaultPort int = 8080  // ✅ allowed
var GlobalValue   int = 42    // ❌ invalid — no global variables
```

---

## 90.7 No `init()` Functions

Ori does **not** support automatic `init()` functions.  
All initialization must occur through explicit function calls.

Example:

```ori
func setup() {
    ...
}

func main() {
    setup()
}
```

## 90.8 Import Resolution

Imports are resolved relative to the module root.  
Cyclic imports are **not permitted**.  
Each package is initialized only when its contents are explicitly referenced.

---

## 90.9 Example

```ori
package main

import (
    "fmt"
    format "fmt"
)

const Version = "0.5"

func main() {
    format.Println("Ori v", Version)
    fmt.Println("Done")
}
```

---

## 90.9 Future Extensions

Planned for later versions:
- Module versioning metadata (`ori.mod`)
- Private/internal import visibility
- Local and remote package registries

---

## References
- [Program Structure](syntax/010_ProgramStructure.md)
- [Declarations](syntax/020_Declarations.md)

---


# 95. Syntax Summary

This section provides a consolidated grammar overview of Ori’s core syntax using [Wirth syntax notation (WSN)](https://en.wikipedia.org/wiki/Wirth_syntax_notation).

---

## 95.1 Program Structure

```
Program       = PackageClause { ImportDecl | TopLevelDecl } .
PackageClause = "package" Identifier .
ImportDecl  = "import" ( ImportSpec | "(" { ImportSpec } ")" ) .
ImportSpec  = [ ImportAlias ] ImportPath .
ImportAlias = Identifier .
ImportPath  = String .
TopLevelDecl  = ConstDecl | VarDecl | FuncDecl | TypeDecl .
```

---

## 95.2 Declarations

```
ConstDecl   = "const" Identifier "=" Expression .
VarDecl     = "var" Identifier [ ":" Type ] "=" Expression .
FuncDecl    = "func" Identifier "(" [ ParameterList ] ")" [ ReturnTypes ] Block .
ReturnTypes = "(" Type { "," Type } ")" | Type .
TypeDecl    = "type" Identifier Type .
```

---

## 95.3 Statements

```
Statement =
      Block
    | IfStmt
    | ForStmt
    | SwitchStmt
    | ReturnStmt
    | BreakStmt
    | ContinueStmt
    | ExpressionStmt .

IfStmt = "if" [ SimpleStmt ";" ] Expression Block [ "else" (IfStmt | Block) ] .
SimpleStmt = VarDecl | Assignment | Expression .

ForStmt = "for" Identifier [ "," Identifier ] ":=" "range" Expression Block
        | "for" Expression Block
        | "for" [ SimpleStmt ";" ] Expression [ ";" SimpleStmt ] Block .

SwitchStmt = "switch" [ SimpleStmt ";" ] [ Expression ] "{" { CaseClause } "}" .
CaseClause = ( "case" ExpresionList | "default" ) ":" { Statement } .
ExpressionList = Expression { "," Expression } .

ReturnStmt = "return" [ ExpressionList ] .
BreakStmt = "break" .
ContinueStmt = "continue" .
Block      = "{" { Statement } "}" .
```

---

## 95.4 Expressions

```
Expression =
      UnaryExpr
    | Expression BinaryOp Expression .

UnaryExpr  = PrimaryExpr | UnaryOp UnaryExpr .
PrimaryExpr = Operand | OperandSelector | OperandIndex | OperandArguments .

BinaryOp = "+" | "-" | "*" | "/" | "%" | "==" | "!=" | "<" | "<=" | ">" | ">=" | "&&" | "||" | "&" | "|" | "^" | "<<" | ">>" .
UnaryOp  = "+" | "-" | "!" | "&" | "*" .
```

---

## 95.5 Literals

```
Literal = IntLit | FloatLit | StringLit | BoolLit | NilLit .
```

---

## 95.6 Type System

```
Type =
      Identifier
    | ArrayType
    | SliceType
    | MapType
    | StructType
    | ReturnTypes .

ArrayType   = "[" IntLit "]" Type .

SliceType   = "[" "]" Type .
SliceExpr   = Expression "[" Expression ":" Expression "]" .
MakeSlice   = "make" "(" SliceType "," Expression [ "," Expression ] ")" .
AppendExpr  = "append" "(" Expression "," Expression ")" .

MapType      = "map" "[" Type "]" Type | "hashmap" "[" Type "]" Type .
MapLiteral   = "{" [ KeyValueList ] "}" .
KeyValueList = KeyValue { "," KeyValue } .
KeyValue     = Expression ":" Expression .
MapAccess    = Expression "[" Expression "]" .
MakeMap      = "make" "(" MapType [ "," Expression ] ")" .
DeleteExpr   = "delete" "(" Expression "," Expression ")" .
CopyExpr     = "copy" "(" Expression "," Expression ")" .

StructType   = "struct" "{" { FieldDecl "," } "}" .

ReturnTypes  = "(" Type { "," Type } ")" | Type .
```

---

## 95.7 Summary Notes

- Grammar is case-sensitive.
- Whitespace and comments are ignored.
- Keywords are reserved.

---

## References
- [Lexical Elements](syntax/005_LexicalElements.md)
- [Expressions](syntax/070_Expressions.md)
- [Statements](syntax/060_Statements.md)

---


# 100. Comments

This section describes the syntax and semantics of comments in Ori source code.

---

## 100.1 Overview

Comments are text fragments ignored by the compiler.  
They are used to document code and improve readability.

Ori supports **line comments** and **block comments**.

---

## 100.2 Line Comments

A line comment begins with `//` and continues until the end of the line.

```ori
// This is a single-line comment
var x int = 10  // Inline comment after a statement
```

Line comments can appear anywhere whitespace is allowed.  
They do not nest.

---

## 100.3 Block Comments

Block comments begin with `/*` and end with `*/`.

```ori
/*
This is a multi-line comment.
It can span several lines.
*/
```

### Rules

Block comments **cannot nest**.  
Can start or end anywhere, whitespace is valid.  
Are typically used for large explanations or temporary code disabling.

---

## 100.4 Doc Comments (Planned)

Ori plans to support **documentation comments** that attach to declarations.

Example (planned):

```ori
// Represents a user account in the system.
type User struct {
    id int
    name string
}
```

These may later integrate with a `oridoc` tool for documentation generation.

---

## 100.5 Placement Guidelines

| Location | Example | Notes |
|-----------|----------|-------|
| Top of file | `// Package documentation` | Describes file or module purpose |
| Before declarations | `// Explains the next type or func` | Recommended for public API |
| Inline | `var x int = 10 // counter` | Keep short and aligned |

---

## 100.6 Best Practices

Use **line comments (`//`)** for normal documentation.  
Reserve **block comments (`/* */`)** for large text or disabled code.  
Keep doc comments short and focused.  
Avoid comment drift — keep them up-to-date with code behavior.

---

## References
- [Program Structure](syntax/010_ProgramStructure.md)
- [Declarations](syntax/020_Declarations.md)

---


# 101. Tokens and Operators

This section defines all valid tokens and their precedence in Ori.

---

## 101.1 Token Categories

| Category | Examples |
|-----------|-----------|
| Identifiers | `name`, `User`, `GetID` |
| Keywords | `func`, `var`, `const`, `for`, `if`, `else`, `return`, `switch`, `import`, `package` |
| Literals | `42`, `"hello"`, `true`, `nil` |
| Operators | `+`, `-`, `*`, `/`, `==`, `&&` |
| Delimiters | `(` `)` `{` `}` `[` `]` `,` `;` `:` `.` |

---

## 101.2 Operators

| Category | Operators | Description |
|-----------|------------|-------------|
| Arithmetic | `+` `-` `*` `/` `%` | Addition, subtraction, multiplication, division, modulo |
| Comparison | `==` `!=` `<` `<=` `>` `>=` | Boolean comparisons |
| Logical | `&&` `\|\|` `!` | Boolean logic |
| Bitwise | `&` `\|` `^` `<<` `>>` | Bitwise operations |
| Assignment | `=`,`:=` | Assign value |
| Range (loop) | `:=` | Range iterator binding |
| Member access | `.` | Field or method access |

---

## 101.3 Operator Precedence

| Precedence | Operators | Description |
|-------------|------------|--------------|
| Highest | `()` `[]` `.` | Grouping, indexing, member access |
| 2 | `!` `-` `+` | Unary operations |
| 3 | `*` `/` `%` | Multiplicative |
| 4 | `+` `-` | Additive |
| 5 | `<<` `>>` `&` `\|` `^` | Bitwise |
| 6 | `==` `!=` `<` `<=` `>` `>=` | Comparisons |
| 7 | `&&` | Logical AND |
| 8 | `\|\|` | Logical OR |
| Lowest | `=` `:=` | Assignment and range binding |

Operators of the same precedence level associate **left to right**.

---

## 101.4 Tokens Summary

All valid tokens in Ori:

```
+  -  *  /  %  &  |  ^  <<  >>  &&  ||
== != < <= > >=
= :=
( ) [ ] { } , ; : .
```

---

## References
- [Lexical Elements](syntax/005_LexicalElements.md)
- [Expressions](syntax/070_Expressions.md)

---


# 100. Slices

Slices in Ori are dynamic, contiguous views over arrays.  
They provide flexible data handling without losing control over memory and type safety.

---

## 100.1 Overview

A **slice** is a lightweight descriptor that references a contiguous segment of elements of a given type.  
Slices do **not** own their underlying memory — they act as a safe view of an array or allocated buffer.

Example:

```ori
var nums []int = make([]int, 5)
nums[0] = 42
```

Slices combine flexibility with predictable memory semantics — no hidden growth, no implicit reallocation.

---

## 100.2 Declaration and Initialization

```ori
var s []int        // uninitialized slice (nil)
var data [5]int
var view []int = data[0:3] // slice of array
```

A slice type is written as `[]T`, where `T` is any valid element type.

---

## 100.3 Slice Creation

Slices can be created in two ways:

### 1. With `make`

```ori
var nums []int = make([]int, 5)
```

The `make` built-in allocates a new backing array and returns a slice descriptor referencing it.

Syntax:
```
make([]T, length [, capacity])
```

- **length** → number of initialized elements available for indexing.
- **capacity** → total number of elements the slice can hold before reallocation.
- If capacity is omitted, it defaults to the length.

Example:
```ori
var a []int = make([]int, 3, 10)
```
`a` has a **length** of 3 and a **capacity** of 10.

### 2. With a dynamic literal

```ori
var nums []int = []int{1, 2, 3}
```

A dynamic literal allocates a new backing array whose length and capacity equal the number of elements listed.

Equivalent to:
```ori
var nums []int = make([]int, 3)
nums[0] = 1
nums[1] = 2
nums[2] = 3
```

Both forms allocate memory explicitly. No slice can exist without a defined backing array.

---

## 100.3.1 Capacity and Overflow Behavior

When appending exceeds the current capacity:

- A **new backing array** is allocated.
- Existing elements are copied into the new memory.
- The returned slice points to the new array.

Example:
```ori
var s []int = make([]int, 2, 2)
s = append(s, 10) // reallocation occurs here
```

After reallocation, `s` no longer shares memory with the old slice.  
Ori’s allocator **never implicitly doubles** capacity — all allocation is explicit and predictable.

---

## 100.4 Indexing and Ranging

Elements are accessed by index starting at 0.

```ori
nums[0] = 1
var x int = nums[1]
```

Out-of-range indexing causes a runtime error.

Slices can also be ranged over:

```ori
for i, v := range nums {
    fmt.Println(i, v)
}
```

---

## 100.5 Slicing Expressions

A new slice may be derived from another:

```ori
var sub []int = nums[2:5]
```

The result shares the same underlying data.  
Changes in one slice are visible in others referencing the same memory.

### 100.5.1 Bounds-Safe Slicing Syntax

Ori supports half-open slicing syntax that ensures runtime safety:

- `s[a:b]` → slice from index `a` to `b` (exclusive)
- `s[a:]` → slice from index `a` to the end
- `s[:b]` → slice from start to `b` (exclusive)
- `s[:]` → full shared view of the slice

All slicing operations are **bounds-checked** at runtime.  
If the specified range exceeds slice length or is invalid (`a > b`), a runtime error occurs.

Example:

```ori
var nums []int = []int{1, 2, 3, 4, 5}
var head view []int = nums[:3] // [1, 2, 3]
var tail view []int = nums[2:] // [3, 4, 5]
```

Both `head` and `tail` are shared views of the same underlying memory.

---

## 100.6 Append Operation

Ori uses explicit appending — `append()` returns a **new** slice.

```ori
var data []int = make([]int, 0, 4)
data = append(data, 1)
data = append(data, 2)
```

`append` may allocate a new backing array if the capacity is exceeded.  
No implicit reallocation occurs — all allocation is explicit.

---

## 100.7 Copy Operation

Slices can be copied using the `copy()` built-in:

```ori
var src []int = []int{1, 2, 3}
var dst []int = make([]int, 3)
copy(src, dst)
```

The `copy()` operation copies elements from the **source** into the **destination** until the shorter of the two slices is exhausted.

After copying:
- The two slices reference **different memory regions**.
- Modifying `dst` will **not** affect `src`.

Example:
```ori
dst[0] = 99
fmt.Println(src[0]) // still 1 — independent copy
```

`copy()` always produces a **copy view** (deep copy), not a shared reference.

---

## 100.8 Const Slices

Ori supports **constant slices** declared as `const []T`.

A const slice is an immutable slice descriptor defined at compile time.  
It cannot be modified, appended to, or re-sliced beyond its bounds.

Example:

```ori
const primes []int = [5]int{2, 3, 5, 7, 11}
fmt.Println(primes[0]) // 2
```

### Properties
- The slice and its elements are immutable.
- Stored in read-only memory at compile time.
- Ideal for lookup tables, static data, or predefined sequences.

### Rules
| Operation | Allowed? |
|------------|-----------|
| Indexing (`x = primes[0]`) | ✅ Yes |
| Mutation (`primes[0] = 9`) | ❌ No |
| Append (`append(primes, 13)`) | ❌ No |
| Slicing (`primes[1:3]`) | ✅ Yes (returns another const slice) |

Const slices improve safety and memory efficiency for static data.

---

## 100.9 Nil and Empty Slices

A nil slice (`nil`) has no backing array or data.

```ori
var s []int
fmt.Println(s == nil) // true
```

Empty slices have a valid descriptor but zero length:

```ori
var s []int = make([]int, 0)
```

---

## 100.10 Comparison and Equality

Slices cannot be compared directly except to `nil`.

To compare content, explicit iteration is required.

---

## 100.11 Passing Slices to Functions

Slices are passed **by value**, but the value contains a pointer to the backing array.  
Mutating elements inside a function affects the caller’s slice content.

Example:

```ori
func fill(s []int) {
    for i := 0; i < len(s); i = i + 1 {
        s[i] = i
    }
}
```

---

## 100.12 Memory Model

Slices reference memory managed by arrays or the allocator.  
Re-slicing does not copy data.  
Explicit functions like `append()` or `make()` may allocate.

---

## 100.13 Copy View vs Shared View

Slices in Ori can exist in two distinct reference modes:

| Mode | Description | Behavior |
|------|--------------|-----------|
| **Copy View (default)** | Regular slice that owns its memory allocation. Copies create new, independent buffers. | Safe for modification. |
| **Shared View (`view` keyword)** | Non-owning reference to another slice or array. Modifications affect the original data. | Efficient but must be used with care. |

---

### Example: Shared vs Copy Views

```ori
var data []int = []int{1, 2, 3, 4}

// Create a shared view referencing a subsection
var sub view []int = data[1:3]

// Create a copy view (deep copy)
var clone []int = make([]int, len(sub))
copy(sub, clone)

// Modify through the shared view
sub[0] = 99

fmt.Println(data)  // [1 99 3 4]
fmt.Println(clone) // [2 3] — unaffected
```

---

### Semantics Summary

| Operation | Effect |
|------------|---------|
| `[:]` slicing | Creates a **shared view** (same memory). |
| `copy()` | Creates a **copy view** (independent memory). |
| `view` qualifier | Enforces non-owning reference semantics explicitly. |
| `append()` | May reallocate; returns a new independent slice if capacity exceeded. |

---

### Notes

- The `view` qualifier ensures clarity of intent: a programmer **chooses** whether to share or copy memory.  
- It prevents accidental aliasing — all shared memory must be declared explicitly using `view`.  
- A `view` slice cannot outlive its source object; the compiler enforces safe lifetime semantics.

---

## 100.14 Future Extensions

Planned for future versions:

- **Copy-on-write slices** → for concurrency-safe mutation without locks
- **Advanced slicing optimizations** → compile-time range validation

---

## References
- [Types](syntax/050_Types.md)
- [Expressions](syntax/070_Expressions.md)

---


# 101. Arrays

Arrays in Ori are fixed-size, value types that store elements of the same type in contiguous memory.  
They form the foundation for slices and provide deterministic memory layout and safety.

---

## 101.1 Overview

An **array** is a collection of elements with a compile-time constant length.  
Unlike slices, arrays own their data and have a fixed size that cannot change after declaration.

Example:

```ori
var numbers [5]int = [5]int{1, 2, 3, 4, 5}
```

---

## 101.2 Declaration and Initialization

### Static Declaration

```ori
var arr [3]int
```

Creates an array of three integers, all initialized to the zero value of `int`.

### Initialization with Values

```ori
var primes [5]int = [5]int{2, 3, 5, 7, 11}
```

### Inferred Length

The compiler can infer the array length from the initializer:

```ori
var data [...]int = [..]int{1, 2, 3, 4}
```

This declares an array of length 4.

---

## 101.3 Array Type and Properties

An array type is defined by its element type and fixed length:

```ori
[T; N]
```
or equivalently in Ori syntax:

```ori
[N]T
```

Example:

```ori
var matrix [3][3]int
```

This creates a 3×3 array of integers.

### Properties

| Property | Description |
|-----------|--------------|
| **Fixed size** | The length `N` is part of the type. |
| **Value type** | Assignment copies all elements. |
| **Contiguous memory** | Elements are stored sequentially. |
| **Zero-initialized** | All elements start with their zero value. |

---

## 101.4 Indexing and Assignment

Array elements are accessed using zero-based indexing.

```ori
arr[0] = 10
var x int = arr[1]
```

Accessing an index outside `[0, N)` causes a runtime error.

---

## 101.5 Array Copy Semantics

Assigning one array to another copies **all elements**.

```ori
var a [3]int = [3]int{1, 2, 3}
var b [3]int = a
b[0] = 99

fmt.Println(a) // [1 2 3]
fmt.Println(b) // [99 2 3]
```

Arrays have **value semantics** — assignment creates an independent copy.

---

## 101.6 Passing Arrays to Functions

Arrays are passed **by value** by default.  
Modifying an array inside a function does not affect the caller’s copy.

```ori
func reset(a [3]int) {
    a[0] = 0
}

var arr [3]int = [3]int{1, 2, 3}
reset(arr)
fmt.Println(arr) // [1 2 3]
```

To pass by reference, use a pointer or a `view`:

```ori
func reset(v view [3]int) {
    v[0] = 0
}

reset(arr) // modifies original
```

---

## 101.7 Iteration

Arrays can be iterated using `for range`:

```ori
var arr [3]int = [3]int{10, 20, 30}

for i, v := range arr {
    fmt.Println(i, v)
}
```

Iteration always visits elements in order.

---

## 101.8 Arrays and Slices

A slice can be created from an array using slicing syntax:

```ori
var arr [5]int = [5]int{1, 2, 3, 4, 5}
var sub view []int = arr[1:4]
```

This creates a **shared view** referencing the same memory as the array.  
Changes in the slice affect the array and vice versa.

---

## 101.9 Multidimensional Arrays

Arrays can contain other arrays as elements.

```ori
var grid [2][3]int = [2][3]int{
    [3]int{1, 2, 3},
    [3]int{4, 5, 6},
}
```

Nested arrays have predictable, contiguous layout in row-major order.

---

## 101.10 Comparison and Equality

Arrays of the same type and length can be compared directly.

```ori
var a [3]int = [3]int{1, 2, 3}
var b [3]int = [3]int{1, 2, 3}
fmt.Println(a == b) // true
```

If element types are comparable, the comparison is lexicographical.

---

## 101.11 Const Arrays

Arrays can be declared as constants using `const`:

```ori
const lookup [3]int = [3]int{10, 20, 30}
```

Const arrays are immutable and stored in read-only memory.

---

## 101.12 Memory and Layout

- Arrays are **contiguous in memory**.
- Alignment follows the element type.
- Size is `sizeof(T) * N`.
- Arrays cannot be resized or reallocated.

---

## 101.13 Future Extensions

Planned for future versions:
- Array literals with type inference (`[auto]int{...}`).
- Compile-time evaluated array operations (sum, map, reduce).
- Fixed-size buffer optimizations for embedded systems.

---

## References
- [100_Slices.md](semantics/100_Slices.md)
- [050_Types.md](syntax/050_Types.md)

---


# 110. Maps

Maps in Ori are **ordered**, associative collections that map unique keys to values.  
They prioritize **determinism, explicit allocation, and safety** in line with Ori’s design principles.

---

## 110.1 Philosophy and Guarantees

**Ordered iteration** — iteration over a map yields entries in **insertion order**.  
**Deterministic behavior** — rehashing or growth never changes the logical order.  
**Explicit allocation** — creation uses `make`, optional initial capacity may be provided.  
**No hidden magic** — two-value lookup for existence; deletions are explicit; no implicit defaults.  
**Single-writer iteration rule** — structural changes (insert/delete) during iteration are **not allowed** (runtime error). Value updates to existing keys are allowed.

---

## 110.2 Declaration and Initialization

A map type is written as `map[K]V`, where `K` and `V` are valid types for keys and values.

```ori
var users map[string]int
```

Maps must be created before use using `make`:

```ori
var users map[string]int = make(map[string]int)           // default capacity
var ages  map[string]int = make(map[string]int, 128)      // with initial capacity
```

---

## 110.3 Supported Key Types (Comparability Defined)

**Keys must be comparable**, i.e., the type supports `==` and `!=` with a **total, deterministic equivalence relation**.

### 110.3.1 Comparable key types
- **Booleans**: `true`, `false`.
- **Integers**: all signed/unsigned integer types.
- **Floating-point**: allowed with constraints (see below).
- **Strings**: lexicographic equality by content (UTF‑8).
- **Arrays**: elementwise comparison; valid if element type is comparable.
- **Structs**: fieldwise comparison; valid if **all fields** are comparable.
- **Enums / distinct named integer types**: compared by underlying value.

### 110.3.2 Non-comparable key types
- **Slices** and **maps** (reference/aggregate types).
- **Function values** and **opaque handles**.
- **Structs** containing any non-comparable field.

### 110.3.3 Floating-point as keys
- `NaN` is **not allowed** as a key (runtime error on insertion or comparison path).
- `+0.0` and `-0.0` are considered **equal** keys.
- Equality uses IEEE‑754 semantics with the above normalizations for map keys.

> Rationale: keys require a stable, total equivalence; `NaN` breaks transitivity.

---

## 110.4 Insertion, Access, and Update

```ori
var users map[string]int = make(map[string]int)

users["Alice"] = 42          // insert (appended in order)
users["Alice"] = 43          // update (order unchanged)

var age int = users["Alice"] // lookup
```

### Missing-key lookup
- If a key does **not** exist, the expression `m[k]` returns the **zero value** of `V`.
- To distinguish “missing” from “present with zero value”, use the **two-value** form (see §110.5).

---

## 110.5 Existence Check

Use the two-value form to test whether a key is present:

```ori
var age int

age, ok := users["Bob"]
if ok {
    fmt.Println("Found:", age)
} else {
    fmt.Println("Missing")
}
```

`ok` is `true` only if the key existed at lookup time.

---

## 110.6 Deletion

Remove a key with `delete`:

```ori
delete(users, "Alice")
```

Deleting a non-existent key is a no-op.  
Deletion **removes** the key from the order; reinserting the same key appends it at the **end**.

---

## 110.7 Iteration (Ordered) and Mutation Rules

Maps are iterated in **insertion order**:

```ori
for k, v := range users {
    fmt.Println(k, v)
}
```

### 110.7.1 What is prohibited during iteration
**Structural mutation** (inserting or deleting keys) while iterating the same map is a **runtime error**:

```ori
for k, v := range users {
    users["z"] = 9        // ❌ runtime error (insert during iteration)
}
```

```ori
for k, v := range users {
    delete(users, k)      // ❌ runtime error (delete during iteration)
}
```

### 110.7.2 What is allowed during iteration
Updating values of **existing keys** is allowed:

```ori
for k, v := range users {
    users[k] = v + 1      // ✅ value update only
}
```

If structural changes are needed, first collect operations, then apply them **after** the loop.

---

## 110.8 Built-in Map Functions

Ori provides a minimal, explicit set of built-ins for maps:

| Function | Signature | Behavior |
|----------|-----------|----------|
| `make` | `make(map[K]V [, capacity]) -> map[K]V` | Allocate a new map, optionally reserving capacity. |
| `len` | `len(m map[K]V) -> int` | Number of entries. |
| `cap` | `cap(m map[K]V) -> int` | Implementation hint: reserved bucket capacity (may be ≥ `len`). |
| `delete` | `delete(m map[K]V, k K)` | Remove key `k` if present. |
| `clear` | `clear(m map[K]V)` | Remove all entries, preserving capacity. |
| `keys` | `keys(m map[K]V) -> []K` | Returns keys in **insertion order**. |
| `values` | `values(m map[K]V) -> []V` | Returns values in **insertion order**. |
| `items` | `items(m map[K]V) -> []struct{key: K, value: V}` | Snapshot of entries in insertion order. |
| `clone` | `clone(m map[K]V) -> map[K]V` | Deep copy preserving insertion order. |

> `cap(m)` is informational and may help tuning. `clear` avoids reallocation when reusing a map.

---

## 110.9 Comparison and Equality

Maps cannot be compared directly, only to `nil`:

```ori
if users == nil {
    fmt.Println("uninitialized")
}
```

Content equality requires an explicit comparison, e.g. via a standard library helper (not a built-in).

---

## 110.10 Passing Maps to Functions

Maps are passed **by value**, but the value contains a reference to shared internal data.  
Thus, modifying a map within a function affects the caller’s map.

```ori
func add(m map[string]int, key string, val int) {
    m[key] = val
}
```

Use `clone` to obtain an independent copy:

```ori
var copy map[string]int = clone(users)
```

---

## 110.11 Nil Maps

A `nil` map has no backing table:

```ori
var m map[string]int
fmt.Println(m == nil) // true
```

Writing to a `nil` map is a runtime error. Always `make()` maps before use.

---

## 110.12 Memory and Growth

Maps grow dynamically as elements are added.  
Growth **does not** change the iteration order.  
Existing references to keys remain valid; iterators are invalidated only if structure is mutated during iteration (runtime error).

---

## 110.13 Concurrency

Maps are **not thread-safe by default**. Access from multiple threads/goroutines requires synchronization.

**Use one of the following patterns:**
- Guard the map with a **mutex** (read/write lock if supported by the standard library).
- Confine the map to a **single owner** task and communicate via channels/messages.
- Use **immutable snapshots** (e.g., `clone`) for read-only sharing.

Concurrent reads/writes without synchronization are **data races** and undefined behavior.

---

## 110.14 Examples

### Ordered Behavior

```ori
var m map[string]int = make(map[string]int)
m["a"] = 1
m["c"] = 3
m["b"] = 2

for k, v := range m {
    fmt.Println(k, v) // prints: a 1, c 3, b 2  (in insertion order)
}

delete(m, "c")
m["c"] = 30

// Now order is: a, b, c
for k, v := range m {
    fmt.Println(k, v)
}
```

### Built-ins

```ori
var m map[string]int = make(map[string]int, 4)
m["x"] = 1
m["y"] = 2

var ks []string = keys(m)      // ["x", "y"]
var vs []int    = values(m)    // [1, 2]
var it = items(m)              // [{key:"x", value:1}, {key:"y", value:2}]

clear(m)                       // m is now empty, capacity retained
```

### Iteration mutation examples

```ori
// ❌ Prohibited: insert during iteration
for k, v := range m {
    m["z"] = 9
}

// ❌ Prohibited: delete during iteration
for k, v := range m {
    delete(m, k)
}

// ✅ Allowed: update value of existing key
for k, v := range m {
    m[k] = v + 1
}
```

---

## 110.15 Future Extensions

- Ordered subranges / slicing of `items(m)` for pagination.
- Stable hashing profiles for reproducible builds across targets.
- Read-only map views for safe sharing across threads.

---

## References
- [Types](syntax/050_Types.md)
- [Expressions](syntax/070_Expressions.md)

---


# 111. HashMaps

HashMaps in Ori are **unordered**, associative collections that map unique keys to values using hashing.  
They are designed for **maximum performance**, **predictable memory control**, and **deterministic hash behavior** across builds.

---

## 111.1 Overview

A `hashmap[K]V` provides constant-time average lookups, insertions, and deletions.  
Unlike `map[K]V`, iteration order is **not guaranteed** — the internal order may differ from insertion order.

Example:

```ori
var counts hashmap[string]int = make(hashmap[string]int)
counts["apple"] = 5
counts["orange"] = 3
```

---

## 111.2 Philosophy and Guarantees

**Unordered iteration** — iteration order is undefined; may change between runs or insertions.  
**Explicit allocation** — created using `make`, optional capacity hint accepted.  
**Deterministic hashing** — Ori’s runtime uses stable hashing for reproducible builds (same input → same layout).  
**Fast-path performance** — optimized for O(1) average access.  
**No implicit synchronization** — not thread-safe; external synchronization required for concurrent access.  
**Explicit error handling** — lookup returns zero value if missing; two-value lookup form available.

---

## 111.3 Declaration and Initialization

```ori
var h hashmap[string]int = make(hashmap[string]int)
var h2 hashmap[string]int = make(hashmap[string]int, 1024) // with capacity hint
```

HashMaps must be explicitly allocated with `make` before use.  
A `nil` hashmap cannot be written to.

---

## 111.4 Supported Key Types

Same as `map[K]V` (see section 110.3):

- All **comparable** types (`bool`, integers, floats, strings, comparable structs/arrays).
- Floating-point rules apply: `NaN` is not allowed; `+0.0` == `-0.0`.

> Non-comparable types (e.g., slices, maps, functions) are invalid as keys.

---

## 111.5 Insertion, Access, and Update

```ori
h["apple"] = 10
h["banana"] = 20

var n int = h["apple"] // returns value (or zero value if missing)
```

Use the two-value form to check for existence:

```ori
var v int

v, ok := h["pear"]
if ok {
    fmt.Println("Found pear")
} else {
    fmt.Println("Not found")
}
```

---

## 111.6 Deletion

Remove entries with `delete`:

```ori
delete(h, "banana")
```

Deleting a non-existent key is safe and has no effect.

---

## 111.7 Iteration

HashMaps are **unordered** — iteration order is intentionally unspecified:

```ori
for k, v := range h {
    fmt.Println(k, v) // order is arbitrary
}
```

> The iteration order may differ between runs and should not be relied upon for deterministic output.

To obtain a deterministic ordering, extract keys and sort them manually:

```ori
var ks []string = keys(h)
sort(ks)
for _, k := range ks {
    fmt.Println(k, h[k])
}
```

---

## 111.8 Built-in Functions

Ori provides a compact set of built-ins for hashmaps:

| Function | Signature | Behavior |
|----------|------------|-----------|
| `make` | `make(hashmap[K]V [, capacity]) -> hashmap[K]V` | Allocates new hashmap. |
| `len` | `len(h hashmap[K]V) -> int` | Number of entries. |
| `cap` | `cap(h hashmap[K]V) -> int` | Returns internal capacity hint. |
| `delete` | `delete(h hashmap[K]V, k K)` | Removes key `k`. |
| `clear` | `clear(h hashmap[K]V)` | Removes all entries, retains capacity. |
| `keys` | `keys(h hashmap[K]V) -> []K` | Returns keys (unordered). |
| `values` | `values(h hashmap[K]V) -> []V` | Returns values (unordered). |
| `clone` | `clone(h hashmap[K]V) -> hashmap[K]V` | Creates an independent copy of the hashmap. |

---

## 111.9 Nil and Empty HashMaps

A nil hashmap has no backing storage:

```ori
var h hashmap[string]int
fmt.Println(h == nil) // true
```

Any write to a nil hashmap triggers a **runtime error**.  
Always allocate hashmaps using `make()`.

---

## 111.10 Memory and Growth

HashMaps expand automatically as elements are inserted.  
Rehashing preserves key-value pairs but not bucket order.  
Growth is **amortized O(1)**; capacity may double on expansion.  
`cap(h)` reports the internal bucket count (for tuning, not iteration).

---

## 111.11 Concurrency

HashMaps are **not thread-safe**. Concurrent reads and writes without synchronization cause undefined behavior.

For concurrent access:
- Protect the hashmap with a **mutex** or synchronization primitive.
- Use **message-passing** between goroutines/tasks.
- Use a **read-only clone** for safe sharing.

Future versions may include `sync.hashmap` for concurrent use cases.

---

## 111.12 Deterministic Hashing

Ori’s hashmaps use **deterministic, stable hashing** to ensure reproducible builds.  
Hash seeds are fixed per build target, so serialized or iterated outputs are consistent across executions.

Optional compiler flags may enable **randomized hashing** for security-sensitive environments.

---

## 111.13 Examples

### Basic usage

```ori
var h hashmap[string]int = make(hashmap[string]int)
h["a"] = 1
h["b"] = 2

fmt.Println(len(h)) // 2

if _, ok := h["c"]; !ok {
    fmt.Println("missing key c")
}

delete(h, "a")
```

### Unordered iteration

```ori
for k, v := range h {
    fmt.Println(k, v) // order not guaranteed
}
```

### Cloning

```ori
var copy hashmap[string]int = clone(h)
```

---

## 111.14 Future Extensions

- Specialized `hashmap_fast` for primitive keys (integer-indexed buckets).
- Lock-free concurrent hashmaps.
- Custom hash function hooks for user-defined key types.
- On-disk hashmaps for persistent storage.

---

## References
- [110_Maps.md](semantics/110_Maps.md)
- [050_Types.md](syntax/050_Types.md)

---


# 120. Strings

Strings in Ori are **immutable**, **UTF‑8 encoded** sequences of bytes representing text.  
They are designed for safety, predictability, and explicit handling of encoding and slicing.

---

## 120.1 Overview

A `string` in Ori is a **read-only value type** representing text data.  
It can be indexed and sliced like a byte sequence, but its content cannot be modified after creation.

```ori
var name string = "Ori Language"
fmt.Println(len(name)) // 12 bytes (UTF‑8 encoded)
```

### Key properties

| Property | Description |
|-----------|--------------|
| **Immutable** | Strings cannot be modified after creation. |
| **UTF‑8 encoding** | Every string is valid UTF‑8 by definition. |
| **Value semantics** | Assignments copy the descriptor (reference-counted or value‑copied). |
| **Safe indexing** | Access beyond bounds is a runtime error. |
| **Viewable** | Can be passed or sliced using the `view` qualifier. |

---

## 120.2 Declaration and Initialization

### Using string literals

```ori
var s string = "hello"
var multiline string = """Line 1
Line 2"""
```

Multi‑line strings preserve newlines and indentation exactly as written.

### From byte slices

```ori
var data []byte = []byte{72, 101, 108, 108, 111}
var s string = string(data)
```

The conversion checks that the byte sequence is valid UTF‑8.  
Invalid encodings cause a **runtime error**.

---

## 120.3 Immutability

Strings are immutable. Reassignment replaces the entire string; mutation by index is not allowed.

```ori
var s string = "abc"
s[0] = 'z' // ❌ compile-time error
```

To modify string content, convert to a mutable byte slice:

```ori
var b []byte = []byte(s)
b[0] = 'z'
var new string = string(b)
```

---

## 120.4 Length and Indexing

### Length
`len(s)` returns the number of **bytes**, not runes (code points).

```ori
var s string = "é"
fmt.Println(len(s)) // 2 bytes in UTF‑8
```

### Indexing
Indexing returns a **byte value** (type `byte`):

```ori
var first byte = s[0]
```

Accessing beyond range is a **runtime error**.

---

## 120.5 Slicing and Views

Strings can be sliced like arrays or slices using half‑open ranges.

```ori
var s string = "abcdef"
var sub string = s[2:5] // "cde"
```

### Bounds safety
All string slicing is **bounds-checked** at runtime.  
Invalid indices (`a > b` or `b > len(s)`) cause a runtime error.

### Shared views
Use the `view` qualifier for non‑owning substring references:

```ori
var s string = "hello world"
var sub view string = s[6:] // view of "world"
```

A `view string` shares memory with the original and cannot outlive it.

---

## 120.6 Concatenation

Concatenation creates a **new string**:

```ori
var a string = "hello"
var b string = "world"
var c string = a + " " + b
```

String concatenation allocates new memory for the combined data.

---

## 120.7 Comparison

Strings are compared lexicographically by Unicode scalar value.

```ori
if "abc" < "abd" {
    fmt.Println("true")
}
```

Comparisons are byte‑wise but since Ori enforces UTF‑8, the result is deterministic and well‑defined.

---

## 120.8 Conversion

### To bytes

```ori
var s string = "hello"
var b []byte = []byte(s)
```

### From bytes

```ori
var b []byte = []byte{72, 105}
var s string = string(b)
```

Invalid UTF‑8 bytes raise a **runtime error**.

### To rune slices

```ori
var r []rune = []rune(s)
```

A `rune` represents a Unicode scalar value (`int32`).

---

## 120.9 Constants

String constants are allowed and always UTF‑8:

```ori
const greet string = "Hello, Ori!"
```

String constants are stored in **read‑only memory** and may be referenced directly without allocation.

---

## 120.10 Built‑in Functions

| Function | Signature | Behavior |
|-----------|------------|-----------|
| `len` | `len(s string) -> int` | Number of bytes. |
| `copy` | `copy(src string, dst []byte)` | Copies bytes from `src` into `dst`. |
| `append` | `append(a string, b string) -> string` | Returns a new concatenated string. |
| `contains` | `contains(s, sub string) -> bool` | Checks substring presence. |
| `index` | `index(s, sub string) -> int` | Returns first occurrence index, -1 if missing. |
| `split` | `split(s, sep string) -> []string` | Splits string by separator. |
| `join` | `join(parts []string, sep string) -> string` | Joins slice into one string. |

All functions are pure and safe; they never modify input strings.

---

## 120.11 Comparison and Equality

Equality uses byte‑wise comparison:

```ori
if a == b {
    fmt.Println("equal")
}
```

The comparison is O(n) over the byte sequence.

---

## 120.12 Concurrency and Thread Safety

Strings are **thread‑safe** because they are immutable.  
They can be safely shared between threads or goroutines without synchronization.

---

## 120.13 Memory and Lifetime

Strings are immutable and reference‑counted or copy‑on‑write internally.  
Slices of strings (`view string`) share the same underlying memory.  
Once all references go out of scope, memory is reclaimed automatically.  
No hidden conversions or implicit allocations occur.

---

## 120.14 String Literals and Raw Strings

Ori supports **two literal syntaxes** for strings:
1. **Backtick (`...`)** — raw, literal form  
2. **Triple quotes (`"""..."""`)** — escaped multiline form  

Each serves a distinct purpose and has clear, predictable behavior.

### 120.14.1 Backtick Strings (Raw Literals)

```ori
var path string = `C:\Users\Ori\docs`
var query string = `SELECT * FROM users WHERE id = 42`
var text string = `Line 1
Line 2
Line 3`
```

#### Characteristics

| Feature | Behavior |
|----------|-----------|
| **Escapes** | Not processed (`\n`, `\t` remain literal) |
| **Multiline** | Supported |
| **Backslashes** | Preserved as-is |
| **UTF-8 validation** | Always enforced |
| **Can include quotes (`"`)** | Yes |
| **Can include backtick (`)** | No |
| **Interpolation** | Not allowed |
| **Use case** | Raw text, file paths, SQL, code snippets, JSON blocks |

---

### 120.14.2 Triple-Quoted Strings (Escaped Multiline Literals)

```ori
var message string = """Line 1
Line 2\tTabbed"""
```

#### Characteristics

| Feature | Behavior |
|----------|-----------|
| **Escapes** | Processed (`\n`, `\t`, `\uXXXX`, etc.) |
| **Multiline** | Supported |
| **Indentation** | Preserved as written |
| **UTF-8 validation** | Always enforced |
| **Can include backticks** | Yes |
| **Can include quotes** | Yes, no escaping required |
| **Interpolation** | Not supported (may be added later) |
| **Use case** | Text blocks, formatted messages |

---

### 120.14.3 Comparative Summary

| Feature | Backtick (`...`) | Triple-quoted (`"""..."""`) |
|----------|------------------|------------------------------|
| **Escapes interpreted** | ❌ No | ✅ Yes |
| **Multiline** | ✅ Yes | ✅ Yes |
| **Indentation preserved** | ✅ Yes | ✅ Yes |
| **Can contain `"`** | ✅ Yes | ✅ Yes |
| **Can contain backtick `** | ❌ No | ✅ Yes |
| **UTF-8 validation** | ✅ Yes | ✅ Yes |
| **Interpolation** | ❌ Not yet | ❌ Not yet |
| **Primary use** | Raw text, regex, SQL, JSON | Human-readable multiline text |
| **Closest analogs** | Go’s `` `...` ``, Rust’s `r"..."` | Python’s `"""..."""`, Rust’s normal `"...\n..."` |

---

### 120.14.4 Design Philosophy

Ori distinguishes between **literal intent** and **formatting convenience**:

- Use **backticks** when the text must be taken **exactly as written** — no escapes, no processing.  
- Use **triple quotes** when readability or formatting matters and **escapes** are useful.  
- Both enforce **UTF-8 correctness** at compile time.

This design unifies the best of:
- Go’s *raw literal simplicity*, and
- Python/Rust’s *expressive multiline escaping*.

---

## 120.15 Future Extensions

- Compile‑time evaluated string interpolation.  
- Native support for multi‑encoding literals (`b"..."`, `r"..."` for raw strings).  
- Efficient substring indexing by code point (`rune`) rather than byte.  
- Optional interning for repeated constants.

---

## References
- [100_Slices.md](semantics/100_Slices.md)
- [050_Types.md](syntax/050_Types.md)

---


# 121. Numeric Types

Ori defines numeric types as **explicit**, **predictable**, and **safe**.  
No implicit type promotion, silent wrapping, or automatic coercion is allowed.  
All arithmetic must be intentional and unambiguous.

---

## 121.1 Overview

Numeric types in Ori have:
- Deterministic widths (e.g., `int32`, `uint64`).
- No implicit conversions between numeric families.
- Human-readable literal syntax (`1_000_000`).
- Checked arithmetic by default — overflow triggers a **runtime panic** unless explicitly handled.

Ori’s numeric system prevents silent data corruption and ensures correctness across architectures.

---

## 121.2 Integer Types

Ori provides both **signed** and **unsigned** integers with fixed bit widths.  
The aliases `int` and `uint` default to 64-bit variants.

| Type | Description | Range | Example |
|-------|-------------|--------|----------|
| `int8`, `int16`, `int32`, `int64` | Signed integers | −2ⁿ⁻¹ to 2ⁿ⁻¹−1 | `var a int32 = 100` |
| `uint8`, `uint16`, `uint32`, `uint64` | Unsigned integers | 0 to 2ⁿ−1 | `var b uint16 = 500` |
| `int` | Alias to `int64` | −2⁶³ to 2⁶³−1 | `var x int = 123` |
| `uint` | Alias to `uint64` | 0 to 2⁶⁴−1 | `var y uint = 456` |

### Integer Rules

No implicit conversion between signed and unsigned integers.  
Arithmetic between mixed types is **invalid** without explicit conversion.  
Use `int` and `uint` for general arithmetic unless fixed-width precision is required.

---

## 121.3 Floating-Point Types

| Type | Description |
|-------|-------------|
| `float32` | 32-bit IEEE 754 floating-point |
| `float64` | 64-bit IEEE 754 floating-point |
| `float` | Alias to `float64` on 64-bit architecture |

### Example
```ori
var f float32 = 1.5
var g float64 = float64(f) + 2.0
```

Floating-point operations follow IEEE 754 behavior (NaN, +Inf, -Inf).

---

## 121.4 Numeric Literal Syntax

Numeric literals may include **underscores for readability**, similar to Go.

```ori
var a int = 1_000_000    // 1000000
var b int = 0b1010_1010  // binary literal
var c int = 0xFF_FF      // hexadecimal
var d float = 3.141_592
```

### Rules for underscores
- Allowed **only between digits** — not at start, end, or next to base prefixes or decimal points.
- Must separate valid digit groups.

Examples:
```ori
1_000_000   // ✅ valid
1000_       // ❌ invalid
_1000       // ❌ invalid
0x_FF       // ❌ invalid
```

Ori enforces these rules to prevent malformed or misleading numeric literals.

---

## 121.5 Arithmetic Rules

Operands must share the same numeric type.  
Integer division truncates toward zero.  
Float division preserves fractional results.  
Overflow is **checked by default** — triggers **runtime panic** if detected.

### Example
```ori
var a int = 5 / 2     // 2
var b float = 5.0 / 2 // 2.5
```

---

## 121.6 Overflow and Underflow

Ori never silently wraps integer and float values.  
All arithmetic operations are **checked** and trigger a **runtime panic** on overflow or underflow.

### Default Behavior

| Operation | Description |
|------------|--------------|
| `+`, `-`, `*` | Checked arithmetic. **Panics** on overflow. |
| `/` | Checked division. **Panics** on divide-by-zero. |
| Compile-time constants | Overflow detected at compile time (**compile error**). |

### Example — Default Checked Arithmetic

```ori
var a uint8 = 255
a += 1 // ⚠️ runtime panic: overflow (uint8)
```

### Explicit Wrapping Operators

| Operator | Meaning |
|-----------|----------|
| `+%` | Wrapping addition (modular arithmetic) |
| `-%` | Wrapping subtraction |
| `*%` | Wrapping multiplication |

Example — Explicit Wrapping:
```ori
var a uint8 = 255
a +%= 1 // ✅ wraps to 0 explicitly
```

### Overflow Detection Functions

Ori provides **explicit overflow-checking arithmetic functions**, each returning `(result, overflowed)` tuples.

| Function | Description | Return | Example |
|-----------|-------------|---------|----------|
| `overflow_add(a, b)` | Performs addition, returns overflow flag | `(T, bool)` | `r, ov := overflow_add(a, b)` |
| `overflow_sub(a, b)` | Performs subtraction, returns overflow flag | `(T, bool)` | `r, ov := overflow_sub(a, b)` |
| `overflow_mul(a, b)` | Performs multiplication, returns overflow flag | `(T, bool)` | `r, ov := overflow_mul(a, b)` |

Example — Checked Detection (No Panic):
```ori
var a uint8 = 255
r, ov := overflow_add(a, 1)
if ov {
    fmt.Println("overflow detected")
}
```

### Design Rationale

Prevents silent numeric corruption.  
Behavior is identical across build modes — always checked, always safe.  
Runtime panics are deterministic and report detailed diagnostic context.  
Matches Zig’s explicit overflow model and avoids Rust’s mode-dependent behavior.

---

## 121.7 Type Conversion

Numeric conversions are **explicit** only.

```ori
var a int64 = 42
var b int32 = int32(a) // ✅ explicit
var c int32 = a        // ❌ implicit narrowing not allowed
```

Conversions between integer and float families must also be explicit.

---

## 121.8 Comparisons

Comparisons are only valid between values of the **same numeric type**.

```ori
var x int32 = 10
var y int64 = 10
if int64(x) == y { fmt.Println("equal") }
```

---

## 121.9 Constants and Literals

Numeric constants are **untyped** until assigned to a variable or used in context.

```ori
var x int32 = 123
var y float64 = 123.0
```

The compiler infers the type based on the destination but performs no implicit widening or narrowing.

---

## 121.10 Comparison with Zig and Rust

| Language | Default Overflow Behavior | Wrapping Option | Notes |
|-----------|---------------------------|------------------|-------|
| **Ori (v0.5)** | **Runtime panic** on overflow | Explicit (`+%`, `-%`, `*%`) | Consistent across builds |
| **Zig** | **Runtime panic** | Explicit (`+%`, `-%`, `*%`) | No undefined behavior |
| **Rust (Debug)** | Panic | `.wrapping_add()` | Safe by default |
| **Rust (Release)** | Wraps silently | `.wrapping_add()` | Performance-optimized |

Ori aligns with Zig’s deterministic safety model, ensuring consistent checked arithmetic across all builds.

---

## 121.11 Design Summary

| Principle | Description |
|------------|-------------|
| **Explicit typing** | No implicit type promotion or inference. |
| **Deterministic width** | Same behavior across architectures. |
| **Human-readable literals** | `_` allowed for readability. |
| **Checked arithmetic** | Overflow triggers **runtime panic**. |
| **Explicit wrapping ops** | `+%`, `-%`, `*%` for intentional wrapping. |
| **Overflow detection** | `overflow_add`, `overflow_sub`, `overflow_mul` return `(value, overflowed)` tuples. |

---

## 121.12 Future Extensions

- `saturating_add(a, b)` and similar APIs (clamp at min/max).
- Compile-time range-constrained numeric types (`int<0..255>`).
- Arbitrary precision (`bigint`, `decimal`).  
- SIMD and vector numeric operations.  
- Context-based safe blocks (`safe { ... }`).

---

---


# 130. Structs

Structs in Ori are **explicitly defined and explicitly initialized** composite types.  
They group related fields and can define associated methods, providing a foundation for structured, type-safe data.

---

## 130.1 Overview

A `struct` represents a fixed collection of named fields, each with an explicit type.  
Unlike some other languages, Ori **does not create implicit zero values** — every struct must be explicitly initialized.

Structs are **value types** by default: assignments and returns copy their contents unless a `ref` or `view` qualifier is used.

Struct names starting with an **uppercase** letter are **exported (public)**,  
while lowercase struct names are **private** to their defining package or module.

---

## 130.2 Why Zero Values Are Not Allowed

In Go and C, every variable or struct receives a *zero value* automatically (e.g., `0`, `false`, `""`).  
While convenient, this approach hides initialization behavior and can lead to subtle bugs.

### Pitfalls of implicit zero values

**Hidden state:** a struct may appear valid even though it was never initialized.  
**Logic errors:** e.g., `if user.ID == 0` might mean “unset,” but it’s also the zero default.  
**Silent bugs:** forgotten initialization compiles and runs silently.  
**Unpredictable behavior in FFI or embedded contexts.**

Ori forbids implicit zero values to ensure explicit construction and visible intent.

> **Rule:**  
> Every struct must be created explicitly through a literal or constructor.  
> No field is initialized unless explicitly defined by the developer.

---

## 130.3 Declaration

### Grammar

```
StructDecl = "struct" Identifier "{" { FieldDecl } "}" .
FieldDecl  = Identifier Type [ "=" Expression ] .
```

### Example

```ori
type User struct {
    name string
    age  int
}
```

Optional field defaults can be specified:

```ori
type Config struct {
    host string = "localhost"
    port int = 8080
}
```

---

## 130.4 Explicit Initialization

Structs must always be initialized explicitly — no automatic zero values exist.

```ori
var u User // ❌ invalid — requires explicit initialization
var u User = User{name: "Ori", age: 20} // ✅ valid
```

All fields must be provided, either directly or through explicit defaults.

```ori
type Config struct {
    host string = "localhost"
    port int = 8080
}

var cfg Config = Config{} // uses explicit field defaults
```

---

## 130.5 Field Access and Visibility

Field visibility is determined by capitalization:

| Field Name | Visibility |
|-------------|-------------|
| Starts with uppercase | Exported (public) |
| Starts with lowercase | Private to the defining package |

```ori
type User struct {
    Name string // public
    email string // private
}
```

Fields are accessed using dot notation:

```ori
fmt.Println(u.Name)
u.email = "private@ori.dev" // valid within same package
```

---

## 130.6 Value and Reference Semantics

By default, structs are **value types**.  
Assignment or parameter passing copies all fields.

```ori
var a User = User{name: "A", age: 10}
var b User = a // copy
b.name = "B"

fmt.Println(a.name) // "A" — unaffected
```

To share or mutate across copies, use the `view` or `ref` qualifier.

---

## 130.7 Qualifiers: const, view, ref

Ori supports qualifiers that define how values are accessed, borrowed, or mutated.

| Qualifier | Status | Description |
|------------|---------|-------------|
| `const` | ✅ Stable | Immutable binding — value or field cannot be reassigned or mutated. |
| `view` | ✅ Stable | Non-owning read-only reference (like a safe slice or borrow). |
| `shared` | ✅ Stable | Mutable alias to an existing value; semantics under review for lifetime and aliasing guarantees. |

```ori
var u User = User{name: "Ori", age: 20}

var const  frozen User  = u  // immutable copy
var view   watcher User = u // read-only borrow
var shared alias User   = u   // mutable alias

alias.age = 25 // modifies u.age
```

> **Note:**  
> The `ref` qualifier is experimental in v0.5.  
> Its semantics for ownership, lifetime, and aliasing will be refined in future versions.

---

## 130.8 Methods

Structs can have associated methods declared with explicit receivers.

### Grammar

```
MethodDecl = "func" "(" Receiver ")" Identifier "(" [ Parameters ] ")" [ ReturnType ] Block .
```

### Example

```ori
type User struct {
    name string
    age  int
}

func (u User) Greet() {
    fmt.Println("Hello,", u.name)
}
```

### Mutating methods

Methods that modify the receiver must use the `ref` qualifier:

```ori
func (ref u User) Birthday() {
    u.age += 1
}
```

This is semantically similar to Go’s pointer receiver but with safe reference semantics.

---

## 130.9 Composition and Embedding

Ori **does not support type-name embedding** or **field promotion**.

### ❌ Invalid

```ori
type Address struct {
    city string
    country string
}

type User struct {
    name string
    Address // forbidden
}
```

### ✅ Valid

```ori
type Address struct {
    city string
    country string
}

type User struct {
    name string
    addr Address
}

fmt.Println(u.addr.city)
```

Field and method access must always be explicit.  
No recursive promotion, shadowing, or method inheritance is allowed.

### Why Embedding Is Forbidden

1. **Name collisions:** Go silently shadows inner fields; Ori forbids ambiguous names.  
2. **Recursive flattening:** implicit access chains like `u.name` (from nested structs) create unclear ownership.  
3. **Method promotion:** automatically exposing inner methods leaks implementation details.  
4. **Ownership clarity:** explicit field names allow controlled use of `view` or `ref`.

| Problem | Go Behavior | Ori Behavior |
|----------|--------------|---------------|
| Name collision | Shadowed silently | Compile-time error |
| Field promotion | Recursive flattening | Explicit only |
| Method promotion | Implicit | Disallowed |
| Ownership | Implicit | Explicit via qualifiers |
| API clarity | Blurred | Explicit and predictable |

---

## 130.10 Memory Layout, Padding, and Alignment

Ori structs have **predictable layouts** with natural alignment.  
Fields are ordered and aligned sequentially according to their type’s requirements.

### Alignment

Each field begins at a memory address aligned to its size.  
This ensures efficient CPU access.

### Padding

Unused bytes may be inserted between fields to maintain alignment:
```ori
type Example struct {
    a byte   // 1 byte
    b int32  // may start at offset 4, with 3 bytes of padding
}
```

Padding is automatically handled by the compiler and is **deterministic**.

### FFI (Foreign Function Interface)
**FFI** refers to interoperability between Ori and external languages such as C.  
Precise layout and alignment rules ensure compatibility across language boundaries.

---

## 130.11 Immutability and Safety

A `const` struct cannot have its fields modified after creation.  
`view` references cannot mutate the target.  
`ref` allows controlled mutation (experimental).  
Structs are not implicitly thread-safe; synchronization is the developer’s responsibility.

---

## 130.12 Explicit Construction and Initialization Functions

Ori forbid hidden or automatic `init()` functions.  
Developers can define constructor-like helpers for initialization:

```ori
func NewUser(name string, age int) User {
    return User{name: name, age: age}
}
```

This keeps struct creation explicit and visible.

---

## 130.13 Future Extensions

- Formalized ownership and aliasing model for `ref`.
- Struct generics and type parameters.
- Optional field-level annotations or attributes.
- **Struct annotations and data transformation** — planned compile-time attribute system for serialization, reflection, and case-style mapping (`snake_case`, `camelCase`, `PascalCase`).
- Reflection or compile-time field enumeration.

---

## References
- [050_Types.md](syntax/050_Types.md)
- [120_Strings.md](semantics/120_Strings.md)
- [100_Slices.md](semantics/100_Slices.md)

---


# 140. Errors

Ori’s error model is **structured**, **immutable**, **explicit**, and **simple**.  
Errors are always **values**, never interfaces, and never dynamic objects.  
There is exactly **one builtin error type**, and all error handling follows a predictable, strict pattern.

---

## 140.1 Design Philosophy

**Structured-only** — all errors are struct values.  
**Immutable** — error fields use `const` and cannot be modified.  
**Explicit** — all functions that can fail must return an error.  
**No wrapping** — errors do not contain other errors.  
**No polymorphism** — errors are not interfaces and never involve dynamic dispatch.  
**Comparable** — errors support deterministic structural comparison.  
**Simple identity** — error identity is defined by `(Message, Code)`.

---

## 140.2 Built-in Error Type

Ori provides **one canonical error type**:

```ori
type Error struct {
    Message const string
    Code    const int
}
```

This struct is used across all APIs that return errors.

---

## 140.3 Returning Errors

```ori
func ReadFile(path string) (string, Error) {
    if !Exists(path) {
        return "", Error{
            Message: "file not found",
            Code:    404,
        }
    }
    data := read(path)
    return data, nil
}
```

Returning `nil` means success.

---

## 140.4 Error Propagation with `try`

```ori
func LoadConfig(path string) (Config, Error) {
    raw  := try ReadFile(path)
    cfg  := try Parse(raw)
    return cfg, nil
}
```

---

## 140.5 Sentinel Errors (Predeclared Error Constants)

```ori
const ErrInvalidUser Error = Error{
    Message: "invalid user",
    Code:    1001,
}
```

```ori
if err == ErrInvalidUser {
    Log("user rejected")
}
```

Sentinel errors must be `const` and use the builtin `Error` struct.

---

## 140.6 Error Comparison Rules

```ori
err1 := Error{Message:"x", Code:1}
err2 := Error{Message:"x", Code:1}

err1 == err2   // true
```

```ori
if err == nil {
    // success
}
```

Only errors of the same type may be compared:

```ori
ParseError{...} == Error{...}   // compile-time error
```

Identity is defined by `(Message, Code)` for the builtin `Error` type.

---

## 140.7 Custom Error Types

```ori
type ParseError struct {
    Message const string
    Line    const int
}
```

Custom errors are only used when explicitly declared in signatures:

```ori
func ParseJSON(s string) (JSON, ParseError)
```

They cannot be returned where `(T, Error)` is expected and cannot be compared with `Error` values.

---

## 140.8 No Error Wrapping

Ori forbids wrapping or chaining errors.

Context must be added manually:

```ori
return Error{
    Message: "ReadUser: " + err.Message,
    Code:    err.Code,
}
```

---

## 140.9 Concurrency Integration

```ori
func (t Task) Wait() Error {
    // nil on success, non-nil on failure
}
```

`.Wait()` always returns the builtin `Error` type and never uses wrapping or chaining.

---

## 140.10 Anti-Patterns

Returning string-only errors — forbidden.  
Mutating error fields — forbidden.  
Wrapping errors — forbidden.  
Comparing errors by message only — discouraged.  
Returning custom errors where `Error` is expected — invalid.

---

## 140.11 Examples

```ori
const ErrTimeout Error = Error{
    Message: "timeout",
    Code:    2001,
}

val, err := Fetch()
if err == ErrTimeout {
    Retry()
}
```

---

## 140.12 Future Extensions

- Optional error code registry.
- Linting for unused error checks.
- Editor tooling for error-flow visualization.

---


# 150. Types and Memory

Ori’s type and memory model is **deterministic**, **explicit**, and **safe by design**.  
Ori **forbids any garbage collector**.  
Allocation, ownership, and lifetimes are always explicit and predictable.

---

## 150.1 Overview

Ori enforces a clear and rigorous memory model:

- No implicit heap allocations  
- No background memory management  
- No lifetime extension  
- No implicit copies except for pure value types  
- All ownership and reference relationships are explicit  

This section defines **value semantics**, **reference semantics**, **views**, **shared qualifiers**, allocation rules, and lifetime constraints.

---

## 150.2 Type Categories

| Category | Examples | Description |
|----------|----------|-------------|
| **Primitive** | `int`, `float`, `bool`, `rune` | Stored inline; pure value types. |
| **Composite (value)** | `array`, `struct` | Inline or stack‑allocated unless explicitly moved/escaped. |
| **Composite (reference)** | `slice`, `map`, `hashmap`, `string` | Heap-backed storage with reference handles. |
| **Reference (pointer)** | `*T` | Direct reference to a value; no ownership. |
| **Qualifiers** | `view`, `shared`, `const` | Modify ownership or access semantics. |

All types have well‑defined ownership and lifetime rules.

---

## 150.3 Value Semantics

Value types behave predictably:

- Assignment copies the value.  
- Passing to a function copies the value.  
- Mutating a copy does not affect the original.  
- No implicit heap promotion occurs.

Example:

```ori
a int := 10
b := a      // copy
b = 20
print(a)    // 10
```

Structs and fixed-size arrays follow the same rule.

---

## 150.4 Reference Semantics

Reference-based types hold a pointer to underlying memory:

- `string` (UTF-8)
- `slice`
- `map`
- `hashmap`
- pointers `*T`

Assignment does **not** duplicate memory; it copies the reference:

```ori
s []int := [1, 2, 3]
t := s        // both reference the same data
t[0] = 9
print(s[0])   // 9
```

Pointer example:

```ori
x int := 42
p *int := &x
*p = 10
print(x)      // 10
```

Pointers require strict lifetime guarantees (see rules below).

Use a pointer when:

- passing large structures by reference  
- representing optional values (`*T` can be `nil`)  
- interfacing with low-level or FFI code  

Use a `view` when you want *read‑only access* that does not transfer ownership or lifetime.

---

## 150.5 The `view` Qualifier

A `view` is a **non-owning, read‑only reference** to existing memory.

Properties:

- Read‑only  
- Does not own memory  
- Cheap to copy  
- Cannot outlive the source  

Example:

```ori
func sum(v view []int) int {
    total = 0
    for n := range v {
        total += n
    }
    return total
}

arr []int := [1, 2, 3]
result := sum(view(arr))   // OK
```

---

## 150.6 The `shared` Qualifier

`shared` marks data as intended for use across multiple concurrent tasks.

Properties:

- Does **not** provide automatic safety  
- Allows multi-task observation or mutation  
- **Requires synchronization** for mutation  
- Non-`shared` mutable data cannot be sent across tasks  

Example:

```ori
shared nums []int := [1, 2, 3]

t1 := spawn_task worker(nums)
t2 := spawn_task worker(nums)

t1.Wait()
t2.Wait()
```

With mutation:

```ori
func worker(m mutex, d shared []int) {
    m.lock()
    d[0] = d[0] + 1
    m.unlock()
}

func main() {
    var m sync.Mutex
    shared nums []int := [0, 0, 0]
    t1 := spawn_task worker(m, nums)
    t2 := spawn_task worker(m, nums)

    t1.Wait()
    t2.Wait()
}
```

---

## 150.6.1 Reference Usage Examples

These examples illustrate pointer validity relative to lifetimes.

### ❌ Forbidden Example — Reference Outliving Its Source

```ori
func bad_ref() *int {
    x int := 10
    return &x    // ❌ invalid: x is destroyed at end of function
}
```

### ✅ Valid Example — Reference to Heap‑Allocated Value

```ori
func ok_ref() *int {
    p *int := new(int)   // allocated on heap
    *p = 42
    return p             // OK: heap allocation outlives function scope
}
```

Here the pointer refers to heap memory, not a local stack variable.

---

## 150.7 Copy vs View vs Shared

| Category | Owns Memory | Mutability | Allowed in Tasks | Lifetime Tied To |
|----------|-------------|------------|------------------|------------------|
| **Copy** | Yes | Yes | Yes | Itself |
| **Reference (pointer)** | No | Yes | Only if target is shared or heap‑allocated | Target value |
| **view** | No | No | Yes | Source value |
| **shared** | Yes | Yes (sync required) | Yes | Shared owner |

---

## 150.8 Lifetime Rules

### **Rule 1 — A `view` cannot outlive its source**

Invalid:

```ori
func bad_view() view []int {
    arr []int := [1, 2, 3]
    return view(arr)   // ❌ arr destroyed here
}
```

Valid:

```ori
func ok_view(input []int) view []int {
    return view(input)   // caller owns memory
}
```

---

### **Rule 2 — A reference cannot escape its scope unless the value is moved or promoted**

Invalid:

```ori
func bad_ref_escape() *int {
    x int := 42
    return &x      // ❌ x destroyed at end of function
}
```

Valid:

```ori
func ok_ref_escape() *int {
    p *int := new(int)   // heap allocation
    *p = 21
    return p             // safe escape
}
```

---

### **Rule 3 — Temporary expressions cannot produce long-lived views**

Invalid:

```ori
v view []int := view(make_list())   // ❌ temporary list destroyed immediately
```

Valid:

```ori
list []int := make_list()
v view []int := view(list)          // list owns memory
```

---

## 150.9 Allocation and Deallocation

### **Stack Allocation**
Used for local, non-escaping values:

```ori
func id(x int) int {
    y int := x
    return y
}
```

### **Heap Allocation**
Triggered by:

- `new(T)`
- `make(...)`
- Escape analysis

```ori
func create() []int {
    arr []int := [1, 2, 3]
    return arr   // arr promoted to heap
}
```

Ori **forbids garbage collection**; memory is freed deterministically when ownership ends.

---

## 150.10 Concurrency and Lifetimes

### **Rule 1 — Mutable data cannot cross tasks unless marked `shared`**

Invalid:

```ori
arr []int := [1, 2, 3]
spawn_task worker(arr)    // ❌ arr not shared
```

Valid:

```ori
shared arr []int := [1, 2, 3]
spawn_task worker(arr)
```

---

### **Rule 2 — `view` across tasks is always safe**

```ori
func worker(v view []int) {
    for n := range v { _ = n }
}

arr []int := [1, 2, 3]
v view []int := view(arr)
spawn_task worker(v)    // OK
```

Mutation is not allowed:

```ori
func worker(v view []int) {
    v[0] = 9   // ❌ cannot mutate through view
}
```

---

### **Rule 3 — The source must outlive all tasks using its view**

Invalid:

```ori
func demo_bad() {
    arr []int := [1, 2, 3]
    spawn_task worker(view(arr))
} // ❌ arr destroyed before worker finishes
```

Valid:

```ori
func demo_ok() {
    arr []int := [1, 2, 3]
    t := spawn_task worker(view(arr))
    t.Wait()
}
```

---

## 150.11 Summary Table

| Concept | Description | Enforcement |
|---------|-------------|-------------|
| **Value semantics** | Copy on assign; stack by default | Always safe |
| **Reference semantics** | Pointers + heap-backed handles | Lifetime checks |
| **`view`** | Read-only, non-owning | Must not outlive source |
| **`shared`** | Explicit multi-task sharing | Requires sync |
| **Lifetime rules** | Deterministic, lexical | Compiler enforced |
| **Allocation** | Stack or explicit/promotion heap | No GC |
| **Escape analysis** | Auto heap promotion | Compile-time |
| **Concurrency safety** | Only `shared` or `view` may cross tasks | Checked at compile-time |

---

## 150.12 Design Summary

- No garbage collector  
- No implicit lifetime extensions  
- Explicit ownership rules  
- `view` for safe read‑only sharing  
- `shared` for explicit concurrent access  
- Pointers only valid if target outlives usage  
- Deterministic memory model

---

## 150.13 Future Extensions

- Move semantics  
- Reference lifetime checking  
- Destructors / RAII  
- Atomic qualifiers  
- FFI-safe pointers

---


# 160. Control Flow

Control flow in Ori governs how statements are executed in sequence or conditionally.  
All control constructs are **explicit**, **deterministic**, and designed to avoid hidden behaviors.

---

## 160.1 Overview

Ori provides structured flow-control statements for:
- Conditional branching (`if`, `else`)
- Loops (`for`)
- Multi-branch dispatch (`switch`)
- Flow modification (`break`, `continue`, `fallthrough`, `return`)

No implicit truthiness, automatic conversions, or silent fallthroughs exist.  
All flow control follows a **block-based** structure.

---

## 160.2 Conditional Statements (`if`, `else`)

The `if` statement evaluates a condition and executes the associated block if it is true.

### Grammar
```
IfStmt = "if" [ SimpleStmt ";" ] Expression Block [ "else" ( IfStmt | Block ) ] .
```

`SimpleStmt` allows short variable declarations scoped to the `if` statement.  
The condition must be a boolean expression.

### Examples
```ori
if x > 0 {
    fmt.Println("Positive")
} else if x == 0 {
    fmt.Println("Zero")
} else {
    fmt.Println("Negative")
}

// With initialization
if v := compute(); v > 10 {
    fmt.Println("High")
}
```

---

## 160.3 Loops (`for`)

Ori uses a single `for` keyword for all loop types.  
No `while` keyword exists; `for` covers all cases.

### Grammar

```
ForStmt = "for" [ Condition | ForClause | RangeClause ] Block .
ForClause = [ InitStmt ] ";" [ Condition ] ";" [ PostStmt ] .
RangeClause = IdentifierList ":=" "range" Expression .
```

### Forms

#### (a) Infinite loop
```ori
for {
    doWork()
}
```

#### (b) Conditional loop
```ori
for i < 10 {
    i += 1
}
```

#### (c) Three-component loop
```ori
for i := 0; i < 10; i += 1 {
    fmt.Println(i)
}
```

#### (d) Range iteration
```ori
for i, v := range items {
    fmt.Println(i, v)
}
```

### Loop Control Statements

| Statement | Description |
|------------|--------------|
| `break` | Exits the innermost loop or switch. |
| `continue` | Skips to the next iteration of the current loop. |

Example:
```ori
for i := 0; i < 10; i += 1 {
    if i == 5 {
        continue
    }
    if i == 8 {
        break
    }
    fmt.Println(i)
}
```

---

## 160.4 Switch Statement

The `switch` statement selects among multiple branches based on value matching.  
It evaluates the expression once, then compares against each `case` in order.

### Grammar

```
SwitchStmt     = "switch" [ SimpleStmt ";" ] [ Expression ] "{" { CaseClause } "}" .
CaseClause     = "case" ExpressionList ":" StatementList | "default" ":" StatementList .
FallthroughStmt = "fallthrough" .
```

### Semantics

The `switch` expression is evaluated once.  
Each `case` is checked sequentially until a match is found.  
The first matching case executes; execution ends unless a `fallthrough` is explicitly declared.  
The optional `default` clause executes if no case matches.

### Examples

#### Basic switch

```ori
switch x {
case 1:
    fmt.Println("One")
case 2:
    fmt.Println("Two")
default:
    fmt.Println("Other")
}
```

#### Switch with initializer

```ori
switch v := getValue(); v {
case 0:
    fmt.Println("Zero")
case 1, 2, 3:
    fmt.Println("Small")
default:
    fmt.Println("Large")
}
```

#### Explicit fallthrough

Ori supports **explicit** fallthrough — it must be written manually.
```ori
switch value {
case 1:
    fmt.Println("one")
    fallthrough
case 2:
    fmt.Println("two or one")
default:
    fmt.Println("other")
}
```

#### Switch Without Expression

```
switch {
case a == 0:
    fmt.Println("a")
case b == 1:
    fmt.Println("b")
default:
    fmt.Println("c")
}
```
This form is useful for multi-branch conditionals where each branch has a distinct test expression.


### Notes

Each **case** is evaluated in order.  
The first true condition executes.  
**default** runs if none of the conditions match.  
Fallthrough can only occur at the **end** of a case block.  
Fallthrough transfers control to the **immediately following** case.

---

## 160.5 Return Statement

The `return` statement exits a function, optionally returning values.

### Grammar

```
ReturnStmt = "return" [ ExpressionList ] .
```

### Rules

If the function declares results, the number and types of expressions must match.  
`return` without expressions is only allowed when all results are named.

### Examples

```ori
func add(a int, b int) int {
    return a + b
}

func compute() (int, bool) {
    result := 42
    return result, true
}
```

---

## 160.6 Summary

| Construct | Purpose | Notes |
|------------|----------|-------|
| `if`, `else` | Conditional execution | Boolean expressions only |
| `for` | Looping construct | Unified loop syntax; supports `range` |
| `break`, `continue` | Loop control | Immediate loop or switch exit |
| `switch` | Multi-branch selection | Explicit `fallthrough`, single evaluation |
| `return` | Function exit | Supports multiple values |

---

Ori’s control flow is designed to remain minimal yet expressive — ensuring **clarity**, **predictability**, and **explicit developer intent**.

---


# 170. Methods and Interfaces

Ori provides **methods** and **interfaces** to attach behavior to types and define reusable contracts.  
All relationships are **explicit** — there is no implicit satisfaction or hidden inheritance.

---

## 170.1 Overview

Methods and interfaces in Ori form the foundation of structured and modular programming.  
They provide predictable, type-safe mechanisms for behavior composition without inheritance or ambiguity.

- Methods bind functions to specific types.
- Interfaces define contracts that types must explicitly implement.
- All conformance is declared, never inferred.

---

## 170.2 Method Declaration

A method is a function bound to a specific type via a **receiver**.  
The receiver defines how the method accesses the underlying value.

### Grammar
```
MethodDecl = "func" "(" Receiver ")" Identifier "(" [ ParameterList ] ")" [ FuncResult ] Block .
Receiver    = [ ReceiverModifier ] Identifier Type .
ReceiverModifier = "ref" | "const" .
```

### Receiver Semantics

| Modifier | Description |
|-----------|--------------|
| *(none)* | The method operates on a copy of the receiver. |
| `shared` | The method operates on a reference to the original instance (can modify). |
| `const` | The method operates on a read-only reference (cannot modify). |

### Example
```ori
type User struct {
    name string
}

func (u shared User) rename(newName string) {
    u.name = newName
}

func (u User) greet() string {
    return "Hello, " + u.name
}

func (u const User) printName() {
    fmt.Println(u.name)
}
```

---

## 170.3 Method Overloading

Ori **does not support method overloading**.  
Each method name must be **unique** within a type’s method set, regardless of parameter types or receiver kind.

This design prevents ambiguity and ensures clear, deterministic method resolution.

### ✅ Valid
```ori
type User struct {
    name string
}

func (u User) greet() string {
    return "Hello " + u.name
}
```

### ❌ Invalid — different parameter count
```ori
func (u User) greet() string        // ok
func (u User) greet(msg string) {}  // ❌ error: method 'greet' already defined
```

### ❌ Invalid — different parameter type
```ori
func (u User) greet(msg string) {}
func (u User) greet(id int) {}      // ❌ error: duplicate method 'greet'
```

### ❌ Invalid — different receiver kind
```ori
func (u User) greet() string {}
func (u shared User) greet() string {} // ❌ error: duplicate method 'greet'
```

---

## 170.4 Interfaces

Interfaces define **behavioral contracts** — sets of methods that a type must implement.  
All implementations must be declared explicitly.

### Grammar
```
InterfaceDecl = "interface" Identifier "{" { MethodSig } "}" .
MethodSig     = Identifier "(" [ ParameterList ] ")" [ FuncResult ] .
```

### Example
```ori
type Greeter interface {
    greet() string
}
```

Any type implementing `Greeter` must define a compatible `greet()` method.

If an interface defines **multiple methods**, the implementing type must define **all** of them.  
Otherwise, the compiler emits an explicit error.

Example:
```ori
type Greeter interface {
    greet() string
    identify() string
}

type User struct { name string }

User implements Greeter

func (u User) greet() string {
    return "Hello, " + u.name
}

func (u User) identify() string {
    return "User type"
}
```

If a method is missing:
```
error: 'User' does not fully implement 'Greeter' — missing method 'identify'
```

---

## 170.5 Explicit Implementation

Ori requires **explicit declaration** of interface conformance.  
A type must declare that it implements an interface before being used as such.

### Example — User and Bot implementing Greeter

#### Step 1. Define the interface
```ori
type Greeter interface {
    greet() string
}
```

#### Step 2. Define concrete types
```ori
type User struct {
    name string
}

type Bot struct {
    id int
}
```

#### Step 3. Declare explicit implementation
```ori
User implements Greeter
Bot  implements Greeter
```

#### Step 4. Define interface methods
```ori
func (u User) greet() string {
    return "Hello, " + u.name
}

func (b Bot) greet() string {
    return "Beep boop — unit " + string(b.id)
}
```

#### Step 5. Use interface polymorphism
```ori
func sayHello(g Greeter) {
    fmt.Println(g.greet())
}

var u User = User{name: "Ori"}
var b Bot = Bot{id: 42}

sayHello(u)
sayHello(b)
```

**Output:**
```
Hello, Ori
Beep boop — unit 42
```

#### Step 6. Using interface collections
```ori
var greeters []Greeter = [u, b]

for _, g := range greeters {
    fmt.Println(g.greet())
}
```

Each element in `greeters` can be a different type, as long as it implements `Greeter`.

### Summary of Concepts

| Concept | Meaning |
|----------|----------|
| `type Greeter interface` | Declares required methods. |
| `User implements Greeter` | Declares explicit relationship between type and interface. |
| `func (u User) greet()` | Defines method required by the interface. |
| `Greeter` in function parameter | Enables runtime polymorphism. |
| `[]Greeter` | Heterogeneous collection of conforming types. |

---

## 170.6 Dynamic Dispatch

When an interface value is used at runtime, Ori stores:
- A reference to the concrete value.
- A **method table** (vtable) for the implemented interface methods.

This allows safe, predictable runtime polymorphism without implicit behavior.

- Compile-time: the compiler verifies that all required methods are implemented.
- Runtime: the correct method is resolved via the vtable.

### Conceptual Model
```text
Greeter → [ pointer to value | pointer to method table ]
```

---

## 170.7 Monomorphism and Polymorphism — Definitions

- **Polymorphism**: the ability for one function or abstraction to work with values of **different types** that share a common behavior (e.g., an interface).  
- **Monomorphism**: the process of turning polymorphic code into **type-specific** code at **compile time** (specialization).

Ori supports **dynamic polymorphism** via interfaces in v0.5, and intends to support **static polymorphism** (monomorphism) via generics in a future version.

---

## 170.8 Monomorphism (Static Polymorphism)

**Static polymorphism** means the compiler generates **specialized code** for each concrete type used with a generic function.

> *Status in v0.5: planned for a future version.*

### Conceptual Example (future syntax)
```ori
// Generic numeric constraint assumed
func max[T numeric](a T, b T) T {
    if a > b { return a }
    return b
}

// Calls would generate specialized versions:
max[int](10, 20)         // → max_int
max[float64](3.14, 2.71) // → max_float64
```

### Pros
- Zero runtime overhead; highly optimized.
- Strong compile-time safety.
- Inlining and per-type optimization.

### Cons
- Larger binaries (code bloat) when used with many types.
- Requires recompilation for new types.
- No runtime substitution (values must be concrete at compile time).

---

## 170.9 Polymorphism (Dynamic)

**Dynamic polymorphism** means method selection occurs **at runtime** through interfaces.

### Example (current v0.5)
```ori
type Drawable interface {
    draw()
}

type Circle struct { radius int }
type Square struct { size int }

Circle implements Drawable
Square implements Drawable

func (c Circle) draw() {
    fmt.Println("draw circle", c.radius)
}

func (s Square) draw() {
    fmt.Println("draw square", s.size)
}

func paintAll(items []Drawable) {
    for _, d := range items {
        d.draw() // runtime dispatch through the interface
    }
}

paintAll([Circle{radius: 10}, Square{size: 5}])
```

### Pros
- Flexible: different concrete types can be handled uniformly.
- Works well for plugins, handlers, and heterogeneous collections.
- Keeps binaries compact (shared interface entry points).

### Cons
- Small runtime overhead (indirect calls).
- No inlining across interface boundaries.
- Behavior defined by contracts, not concrete types.

---

## 170.10 How They Coexist

In Ori’s design:
- **Interfaces** provide **dynamic polymorphism** (runtime dispatch).  
- **Generics** (future) provide **static polymorphism** (compile-time specialization).

Use **interfaces** when you need **heterogeneous collections** or **runtime substitution**.  
Use **generics** when you need **maximum performance** and **compile-time specialization**.

### Summary Table

| Aspect | Static (Monomorphism) | Dynamic (Polymorphism) |
|---------|------------------------|--------------------------|
| Binding time | Compile-time | Runtime |
| Dispatch | Direct call (inlined) | Indirect call via vtable |
| Type scope | Concrete, generic types | Any implementing type |
| Performance | Maximum (zero overhead) | Slight overhead |
| Code size | Larger (one per specialization) | Compact (shared code) |
| Use cases | Numerics, algorithms | Interfaces, plugin systems |
| Status in Ori | Planned (v0.5+) | Implemented (v0.5) |

---

## 170.11 Summary

| Concept | Description |
|----------|--------------|
| **Method** | Function bound to a type. |
| **Receiver** | `ref`, `const`, or value; defines access semantics. |
| **Interface** | Declares a set of required methods. |
| **implements** | Declares explicit conformance between a type and an interface. |
| **No overloading** | Prevents ambiguity in method lookup. |
| **Dynamic dispatch** | Safe runtime polymorphism via method tables. |
| **Monomorphism** | Future compile-time specialization via generics. |
| **Polymorphism** | Runtime dispatch via interfaces (available). |

---

Ori’s method and interface system emphasizes **explicitness**, **clarity**, and **predictable behavior**,  
with a clear path toward efficient compile-time polymorphism in future versions.

---


# 180. Runtime and Panic Handling

Ori’s runtime is designed to be **deterministic**, **minimal**, and **safe**.  
It avoids hidden recovery mechanisms and ensures predictable program termination on fatal errors.

---

## 180.1 Overview

Ori distinguishes between two classes of runtime failure:

| Type | Description | Recoverable |
|------|--------------|--------------|
| **error** | Expected failure handled by developers using `try` or explicit returns. | ✅ Yes |
| **panic** | Unrecoverable, fatal runtime failure (e.g., index out of bounds, division by zero). | ❌ No |

Errors are part of normal program flow.  
Panics represent critical conditions that should **terminate execution immediately**.

---

## 180.2 Error vs Panic

| Concept | Description | Example |
|----------|--------------|----------|
| `error` | Represents an expected failure. | `try openFile("data.txt")` |
| `panic` | Represents an unexpected or unrecoverable condition. | `panic("index out of range")` |

Example:
```ori
func readConfig(path string) string {
    if !exists(path) {
        panic("configuration file missing")
    }
    return readFile(path)
}
```

---

## 180.3 Panic Behavior

When a panic occurs:
1. The current function stops executing immediately.  
2. Stack unwinding begins — deferred cleanup functions may run (future support).  
3. The runtime prints:
   - The panic message
   - A precise stack trace (function, file path, line)
   - The exit code
4. The program terminates with a non-zero exit status.

### Example
```ori
func divide(a int, b int) int {
    if b == 0 {
        panic("division by zero")
    }
    return a / b
}
```

**Runtime output:**
```
panic: division by zero

at math.divide (/project/src/math.ori:10)
at main.main (/project/src/main.ori:4)

exit code 1
```

---

## 180.4 Recovering from Panics (Future Extension)

For version 0.5, panics are **fatal and non-recoverable**.  
Future versions may introduce **controlled recovery scopes** for testing or advanced runtime management.

---

## 180.5 Built-in Panic Functions

Ori provides a minimal set of built-in functions for runtime validation and development workflow support.

| Function | Description | Example |
|-----------|--------------|----------|
| `panic(msg string)` | Triggers immediate program termination with message and stack trace. | `panic("invalid state")` |
| `assert(cond bool, msg string)` | Panics if `cond` is false; used to enforce invariants. | `assert(len(users) > 0, "empty user list")` |
| `todo()` | Marks code as intentionally unimplemented and panics at runtime. | `todo()` |

### Built-in Function Philosophy

Unlike some other languages, Ori includes `assert` and `todo` as first-class built-ins.  
They simplify common patterns and encourage **clear, intentional development behavior**.

---

### Example 1: Using `assert`
```ori
func divide(a int, b int) int {
    assert(b != 0, "division by zero")
    return a / b
}
```

**If `b == 0`:**
```
panic: assertion failed: division by zero
at main.divide (/src/main.ori:3)
at main.main (/src/main.ori:10)

exit code 1
```

---

### Example 2: Using `todo`
```ori
func connectDatabase() {
    todo() // TODO: implement database connection
}
```

**Runtime output:**
```
panic: TODO at /src/db.ori:5
at main.connectDatabase (/src/db.ori:5)
at main.main (/src/main.ori:12)

exit code 1
```

These built-ins provide standardized panic messages with consistent formatting, including **file paths** and **line numbers** for direct debugging.

---

## 180.6 Interaction with Errors

`error` values propagate via explicit `return` or `try`.  
`panic` bypasses normal control flow and terminates execution.  

**Design guideline:**
- Use `error` for *expected* conditions (file not found, invalid input).  
- Use `panic` for *unexpected* internal failures or violated invariants.

Example:
```ori
func openFile(path string) error {
    if !exists(path) {
        return error("file not found")
    }
    if !hasPermission(path) {
        panic("security violation: access denied")
    }
    return nil
}
```

---

## 180.7 Runtime Guarantees

Ori’s runtime provides strict guarantees to maintain deterministic execution:

| Guarantee | Description |
|------------|--------------|
| Deterministic panics | Panic messages and traces are consistent across executions. |
| File path + line info | Every panic reports its exact origin. |
| No implicit recovery | Panics always terminate unless a future recovery scope is explicitly defined. |
| Stack trace visibility | Always printed before termination. |
| RAII-like cleanup (future) | Resource Acquisition Is Initialization cleanup like defer will be introduced in future versions. |

---

## 180.8 Summary

| Feature | Description |
|----------|--------------|
| `panic` | Triggers immediate program termination. |
| `assert` | Checks invariants; panics on failure. |
| `todo` | Marks unimplemented code with standardized panic message. |
| `error` | Represents recoverable conditions in normal flow. |
| **No recovery yet** | Planned for future version. |
| **Stack trace with file paths** | Always displayed for deterministic debugging. |
| **Exit code** | Non-zero exit on panic termination. |

---

Ori’s runtime model prioritizes **clarity, determinism, and developer control**, providing meaningful diagnostics and avoiding hidden behaviors.

---


# 190. Concurrency

Ori’s concurrency model defines how tasks execute, communicate, and synchronize safely.

Key objectives:

- Deterministic behavior through **cooperative green tasks**.
- Dual execution domains: **`spawn_task`** (cooperative) and **`spawn_thread`** (OS threads).
- Strict scheduler isolation (no cross-spawning).
- Race-free concurrency via `view`, `shared`, channels, and strict memory rules.
- Predictable synchronization via `Wait()` and explicit yield points.

---

## 190.1 Overview

Ori favors:

- **Cooperative green tasks** for most concurrent work.
- **OS threads** only for CPU-heavy or blocking operations.
- Clear separation between the two domains.
- No hidden runtime or garbage collector involvement.

Concurrency is built on:

- Tasks (`spawn_task`)
- Threads (`spawn_thread`)
- Channels
- `view` and `shared` qualifiers
- Deterministic scheduling and memory rules

---

## 190.2 Cooperative Green Tasks

### 190.2.1 What Are Green Tasks?

Green tasks are lightweight user-space tasks scheduled by the Ori runtime.

They:
- run inside the cooperative scheduler
- have small stacks
- context‑switch cheaply
- never preempt each other arbitrarily
- scale to thousands of concurrent tasks

They behave like **software threads**, but with deterministic scheduling.

---

## 190.3 Cooperative Scheduling

A task yields execution only when it:
- calls `Send()`
- calls `Recv()`
- calls `Wait()`
- calls `yield()`

These are **yield points**.

Tasks are **never preempted automatically** by the runtime between yield points.

---

## 190.4 The `yield()` Keyword

`yield()` voluntarily returns control to the scheduler:

```ori
func worker() {
    for {
        do_work()
        yield()
    }
}
```

### 190.4.1 Implicit Yield Points

- `Send()`
- `Recv()`
- `Wait()`

Each suspends the current task and allows another task to run.

---

## 190.5 Why Cooperative?

| Benefit       | Explanation                                      |
|---------------|--------------------------------------------------|
| Deterministic | Task switching happens only at defined points.   |
| Lightweight   | No OS scheduling overhead.                       |
| Debuggable    | Repeatable interleavings.                        |
| Safe          | No preemption while mutating data.               |
| Simple        | No async/await or futures.                       |

---

## 190.6 Drawbacks

| Drawback                        | Mitigation                   |
|---------------------------------|------------------------------|
| A task can starve others        | Insert `yield()` in loops    |
| CPU-heavy loops block scheduler | Prefer `spawn_thread`        |
| Single-core execution per thread| Use multiple OS threads      |

---

## 190.7 Example: Cooperative Switching

```ori
func main() {
    spawn_task func() {
        for i := range int(3) {
            print("A", i)
            yield()
        }
    }

    for i := range int(3) {
        print("B", i)
        yield()
    }
}
```

Switching order is deterministic.

---

## 190.8 `spawn_task` vs `spawn_thread`

### 190.8.1 `spawn_task` — Cooperative Tasks

```ori
t TaskHandler[int] := spawn_task worker()
```

Properties:
- Scheduled by the Ori runtime
- Very cheap to create
- Yields cooperatively at well-defined points
- **Cannot spawn OS threads**
- Deterministic switching

---

### 190.8.2 `spawn_thread` — OS Threads

```ori
t ThreadHandler[int] := spawn_thread worker()
```

Properties:
- Real OS thread
- Preemptive
- **Cannot call `yield()`**
- **Cannot spawn tasks**
- Ideal for CPU-heavy or blocking code

---

### 190.8.3 Summary Table

| Category                 | `spawn_task` (cooperative)               | `spawn_thread` (OS thread)                      |
| ------------------------ | ---------------------------------------- | ----------------------------------------------- |
| Execution model          | Cooperative                              | Preemptive                                      |
| Yielding allowed?        | Yes                                      | ❌ Forbidden                                     |
| Creates OS thread?       | No                                       | Yes                                             |
| Cost                     | Very low                                 | High                                            |
| Blocking behavior        | Yields scheduler                         | Blocks kernel thread                             |
| Memory visibility        | At `Wait()`                              | At `Wait()`                                     |
| spawn_task inside?       | Yes                                      | ❌ Forbidden                                     |
| spawn_thread inside?     | ❌ Forbidden                              | Yes                                             |
| Best use case            | IO, actors, reactive                     | CPU loops, blocking FFI                         |

---

### 190.8.4 `TaskHandler[T]` and `ThreadHandler[T]`

Both are **opaque handles** to running computations.

They expose:
```ori
func (h TaskHandler[T])   Wait() (T, error)
func (h ThreadHandler[T]) Wait() (T, error)
```

- No fields
- No mutation
- No scheduler/state introspection
- No cancellation API in v0.5

---

### 190.8.5 Panic Handling Inside Tasks and Threads

Panics:
- terminate the task/thread immediately
- never propagate upward
- never crash the program,
- are captured by the runtime
- converted to an `error` returned by `.Wait()`

```ori
func job() int {
    panic("bad state")
}

t := spawn_task job()
value, err := t.Wait()   // err = "panic: bad state"
```

Panics become errors returned by `.Wait()`.

---

## 190.9 Compiler Rules

### 190.9.1 Cross-Spawning Rules

These are **forbidden** in Ori v0.5:

### ❌ A task spawning an OS thread
```ori
spawn_task func() {
    th := spawn_thread heavy()   // ERROR
}
```

### ❌ A thread spawning a task
```ori
spawn_thread func() {
    t := spawn_task job()        // ERROR
}
```

### ✔ Allowed
```ori
spawn_task worker()
spawn_task helper()

spawn_thread heavy()
spawn_thread blocking_job()
```

Each execution domain can only spawn within itself.

---

### 190.9.2 No Mutable Capture Into Tasks

**Note:**  
> When passing slices, maps, or strings into tasks:  
> – Use `view` for read‑only access  
> – Use `shared` for concurrent mutation  
> – Or pass by value for copies  
> Any other form is rejected by the compiler.

```ori
x int := 0
spawn_task func() {
    x += 1   // ❌ forbidden
}
```

### How to fix:

Use value capture:
```ori
x int := 0
spawn_task func(v int) {
    fmt.Println(v)
}(x)
```

Or use shared memory explicitly:
```ori
import "atomic"

shared count := atomic.StoreInt(0)
spawn_task func() {
    count.AddInt(1)
}
```

---

### 190.9.3 Channels

> **Note:**  
> Channels themselves never require `shared`.  
> Synchronization via `Send`/`Recv` provides all necessary visibility guarantees.

```ori
ch := make(chan int)
spawn_task producer(ch)
v := ch.Recv()
```

- Channels transfer ownership
- Operations `Send()` and `Recv()` are yield points
- Unbuffered only in v0.5

---

### 190.9.4 Ownership Transfer

```ori
ch.Send(value)   // sender loses ownership
v := ch.Recv()   // receiver gains ownership
```

---

### 190.9.5 `Wait()` Defines Memory Visibility

All writes performed by a task are guaranteed visible after `.Wait()` returns.

```ori
t := spawn_task worker()
result, err := t.Wait()
```

---

## 190.10 Scheduler Integration

Tasks yield on `Send`, `Recv`, `Wait`, `yield`.  
`spawn_thread` bypasses scheduler entirely.  
Blocking syscalls in tasks freeze the scheduler, it's forbidden.

---

## 190.11 The `select` Keyword

```ori
select {
    case msg := ch1.Recv():
        print(msg)
    case msg := ch2.Recv():
        print(msg)
    default:
        yield()
}
```

- First ready case (source order) is chosen
- `default` prevents blocking
- `Send`/`Recv` cases yield automatically

---

## 190.12 Determinism Rules

1. Switching only at yield points  
2. Deterministic `select`  
3. Synchronous channels  
4. `Wait()` = visibility boundary  
5. No preemption  

---

## 190.13 Example — Worker Pool

```ori
import "atomic"

func worker(id int, jobs chan int, results chan string) error {
    for {
        select {
            case job := jobs.Recv():
                results.Send("worker " + string(id) + " processed " + string(job))
            case default:
                yield()
        }
    }
    return nil
}

func main() {
    const num_workers int = 3
    const num_jobs int = 5

    jobs := make(chan int)
    results := make(chan string)
    shared done := atomic.StoreInt(0)

    for i := range num_workers {
        spawn_task worker(i, jobs, results)
    }

    for j := range num_jobs {
        jobs.Send(j)
    }

    for {
        select {
            case msg := results.Recv():
                print(msg)
                done.AddInt(1)
                if done.LoadInt() == num_jobs {
                    fmt.Println("All jobs done.")
                    break
                }
            case default:
                yield()
        }
    }
}
```

---

## 190.14 Channel Buffering

Only **unbuffered channels** exist.

---

## 190.15 Channel Closing

Ori permanently **forbids** `Close()` semantics.

---

## 190.16 Task Cancellation

No cancellation API in v0.5.

---

## 190.17 Error Integration

This note specifies how the unified `Error` type is used in task handling.

### 190.17.1 Task Wait Error Semantics

Task handles expose a `Wait` method that returns the canonical `Error` type:

```ori
type Task struct {
    // internal fields not exposed here
}

func (t Task) Wait() Error {
    // Returns nil on success.
    // Returns a non-nil Error value on failure.
}
```

### 190.17.2 Rules

`Wait()` never wraps or chains errors.  
`Wait()` returns:
- `nil` if the task completed successfully, or
- a non-nil `Error` value describing the failure.

Sentinel errors (predeclared `const` Error values) may be used to signal specific task outcomes:

```ori
const ErrTaskCancelled Error = Error{
    Message: "task cancelled",
    Code:    3001,
}

err := task.Wait()
if err == ErrTaskCancelled {
    // handle cancellation
}
```

All task-related APIs that can fail must use `Error` in their signatures to stay consistent with the global error model.

---

## 190.18 Summary

| Concept | Ori Behavior |
|--------|---------------|
| Cooperative tasks | deterministic, yield‑based |
| spawn_task | creates green task |
| spawn_thread | creates OS thread |
| Strict isolation | no cross‑spawning |
| Wait() | sync + visibility boundary |
| Channels | unbuffered, synchronous |
| Shared memory | explicit only |
| yield() | voluntary scheduler hint |
| Panic behavior | captured, returned via Wait() |

---


# 001. Language Philosophy

Ori is a **system-capable general-purpose programming language** built on three essential promises:  
**clarity**, **determinism**, and **explicit control**.  

It is designed for developers who want predictable execution and full visibility into what their code does — with no hidden runtime behavior or implicit transformations.

---

## 1. Introduction

Ori’s mission is to offer a programming environment where **safety and simplicity coexist**.  
It draws lessons from Go’s readability, Zig’s explicitness, and Rust’s safety, while avoiding their respective pitfalls — complexity, verbosity, or hidden runtime behavior.

Ori code should be **clear to read, safe to execute, and deterministic to reason about**.

---

## 2. Core Principles

| Principle | Description |
|------------|--------------|
| **Explicitness** | Every behavior must be visible in code — no implicit conversions, imports, or hidden initialization. |
| **Determinism** | The same inputs always produce the same results, regardless of context. |
| **Safety** | Prevent undefined behavior by design while keeping control in the developer’s hands. |
| **Simplicity** | A small, orthogonal set of features that compose naturally. |
| **Predictability** | No hidden concurrency, no automatic reallocation, no silent failures. |
| **Readability** | Code should express intent clearly, not trick the reader into guessing. |

Ori’s design rejects “magic” abstractions — developers always see the cost and consequences of their code.

---

## 3. Philosophy Compared to Other Languages

From **Go**, Ori inherits simplicity and readability, but not the runtime or unchecked errors.  
From **Zig**, it takes explicit memory control and compile-time clarity.  
From **Rust**, it borrows safety principles, but avoids the heavy syntax and implicit lifetimes.  

Ori’s guiding phrase:

> “You should always know what your code does — and why.”

---

## 4. Design Intent

No garbage collector — memory safety through structure and ownership discipline.  
No global mutable state — promote modular and testable design.  
No implicit initialization or hidden imports.  
**No runtime magic** — Ori has no background runtime or hidden services. Execution is fully under developer control.  
**Mandatory error handling** — Ori enforces explicit handling of returned errors at compile time.  
  If a function returns an `error`, it must be checked or explicitly propagated (e.g., with `try`).  
  Unhandled errors are a **compile-time violation**, not a linter warning.  
  This guarantees that failure cases are never silently ignored.  
Encourage clear error handling over silent exceptions.  

Ori’s compilation rules ensure that every critical behavior — imports, memory, errors — is **known, visible, and validated** before execution.

---

## 5. Developer Experience

Ori emphasizes an experience where **correctness and clarity come first**:

- Fail early, fail clearly — `assert`, `error`, and `panic` are explicit tools.  
- Zero-surprise refactoring — what you read is what executes.  
- Predictable compilation model — no hidden runtime linking or background scheduling.  
- Clear diagnostics — compiler errors are precise and actionable.  

---

## 6. Summary

Ori builds trust through explicitness:

- Trust the **developer** to write safe, visible code.  
- Trust the **compiler** to enforce clarity and correctness.  
- Trust the **runtime** (or lack thereof) to behave deterministically.  

**Ori is a language for those who value control, transparency, and precision over convenience-driven ambiguity.**

---


# 002. Type Safety and Explicitness

Ori enforces a **strong, fully explicit type system**.  
Every variable, constant, and conversion must be **declared intentionally** — there is no type inference, no hidden conversions, and no implicit default values.

This design guarantees that all types and behaviors are **visible**, **predictable**, and **auditable**.

---

## 1. Introduction

Ori’s type system is founded on **clarity and control**.  
Types are not hints to the compiler; they are contracts defined by the developer.

There is **no inference**, **no automatic zero values**, and **no implicit conversions**.  
Each variable and constant must declare its **type** and **initial value** explicitly.

---

## 2. Core Rules

| Rule | Description |
|------|--------------|
| **Explicit Declaration** | Every variable must declare its type. Example: `var a int = 123` is valid; `var a = 123` is invalid. |
| **Enforced Numeric Types** | Numeric literals are not inferred — `var x = 10` is invalid; `var x int = 10` is required. |
| **No Automatic Values** | Ori does not assign zero or default values automatically. Every variable must be explicitly initialized. |
| **No Implicit Conversions** | Type changes must be explicit using conversion syntax like `float64(x)`. |
| **No Untyped Constants** | All constants must have declared types. |

Ori’s typing rules make data behavior transparent at all times.

---

## 3. Example: Enforced Type Clarity

```ori
// ✅ Valid
var count int = 10
var price float64 = 25.5
price = price + float64(count)

// ❌ Invalid: missing type
var total = 0          
// compile error: missing explicit type

// ❌ Invalid: missing initialization
var x int              
// compile error: variable not initialized
```

---

## 4. Why No Automatic Values

In many languages, uninitialized variables default to zero values (e.g., `0`, `false`, `""`).  
While convenient, this can **hide unintentional logic bugs** and cause silent misbehavior.

Ori forbids automatic initialization — developers must assign explicit values.  

This ensures that:
- Every variable represents a **deliberate state**.  
- No uninitialized or placeholder value slips through.  
- Refactoring is deterministic — no “magical” behavior change.  

Example:

```ori
var ready bool = false // explicit
var count int = 0      // explicit
```

Explicitness leads to clarity and avoids the hidden side effects common in languages with implicit defaults.

---

## 5. Benefits of Explicit Typing

**Deterministic behavior** — no silent conversions or data loss.  
**Safer numeric operations** — overflow and truncation are visible and avoidable.  
**Readable contracts** — code intent is immediately clear from declarations.  
**Predictable compilation** — no guessing or inference from the compiler.  
**Reliable debugging** — the compiler enforces full type knowledge before execution.  

Explicit types remove ambiguity between human reasoning and machine behavior.

---

## 6. Type Conversion Rules

All type conversions must be explicit.  
Only compatible types can be converted, and reinterpretation is forbidden in v0.5.

```ori
var a int = 10
var b float64 = 2.5
var c float64 = float64(a) + b // explicit conversion required
```

Rules:

- **Explicit only:** no automatic casting or coercion.  
- **Compatible types only:** `int → float64` allowed, `int → string` forbidden.  
- **Unsafe conversions:** not supported yet; reserved for `unsafe` contexts in future versions.  

---

## 7. Future Directions

**Type aliases** for domain semantics (e.g., `type UserID = int64`).  
**Generic constraints** for reusable type-safe code (planned for v0.5+).  
**Optional loop variable deduction**, never full inference.  

Even future type features will maintain Ori’s principle of **explicit control**.

---

## 8. Summary

Ori enforces a strong, explicit, and predictable type system:

- Every variable has a **declared type**.  
- Every variable must have an **explicit initial value**.  
- Every conversion is **intentional**.  
- No type inference.  
- No zero defaults.  
- No ambiguity.

> “If the compiler needs to guess, it means the developer wasn’t explicit enough.”

---

Ori’s type philosophy ensures code that is **clear to the reader**, **trusted by the compiler**, and **deterministic in execution**.

---


# 003. Error Handling Philosophy

Ori’s philosophy on error handling is simple and strict:  
**errors are part of normal program flow**, not exceptional control flow.

There are no exceptions, no hidden recovery, and no ignored results.  
If an operation can fail, the developer must make that failure **visible and intentional**.

> “If it can fail, it must be visible.”

---

## 1. Introduction

Ori’s error system is built around explicitness and compile-time enforcement.  
Unlike languages that rely on runtime exceptions or linter-based checks, Ori **integrates error handling directly into the language semantics**.

This approach eliminates ambiguity: every error must either be **handled** or **explicitly propagated**.  
Unhandled errors prevent compilation.

---

## 2. Design Principles

| Principle | Description |
|------------|--------------|
| **Explicit handling** | All errors must be checked or explicitly propagated using `try`. |
| **Compile-time enforcement** | Unhandled errors are detected at compile time, not at runtime. |
| **No hidden recovery** | No global handlers, no automatic retries, and no silent failure recovery. |
| **No string errors** | Errors are typed values, not arbitrary text. |
| **Clarity over convenience** | Predictable code is prioritized over brevity. |

---

## 3. Example: Explicit Propagation

### 3.1 Non-entry function (propagation allowed)

Propagation with `try` is valid **only** inside functions that *return `error`*.  
`try` re-throws the error to the caller and requires the current function to have an `error` in its result type.

```ori
func initConfig() error {
    try openFile("config.ori") // propagated upward
    fmt.Println("File loaded successfully")
    return nil
}
```

### 3.2 Entry point (`main`) (no propagation)

`main` **cannot** declare return values, so there is **nothing to propagate to**.  
At the program boundary, you must **handle** the error or **fail fast**.

```ori
func main() {
    var err error = initConfig()
    if err != nil {
        panic("could not load config: " + err.string())
    }
    fmt.Println("ok")
}
```

**Rule:** `try` cannot be used at the top level (`main`) because there is no caller to receive the error.
---


## 4. Explicit Handling

### 4.1 Entry point (`main`)

The entry function **cannot** declare return values. Handle errors explicitly at the boundary.

```ori
func main() {
    var err error = openFile("config.ori")
    if err != nil {
        panic("could not load: " + err.string())
    }
    fmt.Println("ok")
}
```

> Rationale: `main` is the top-level boundary. Either handle the error or fail fast with a clear panic.

### 4.2 Other functions

In non-entry functions, returning `error` is valid and encouraged; callers must handle or `try`-propagate it.

```ori
func run() error {
    var err error = openFile("config.ori")
    if err != nil {
        return err
    }
    fmt.Println("ok")
    return nil
}
```

Ori forces developers to **choose**: handle the error explicitly, or propagate it using `try`.  
Silence is never an option.

---

## 5. Built-ins Recap

| Built-in | Description | Example |
|-----------|--------------|----------|
| `error(msg)` | Creates a new error instance. | `return error("invalid config")` |
| `nil` | Represents “no error”. | `return nil` |
| `try` | Propagates the error upward automatically. | `try readFile()` |

---

## 6. Why No Exceptions

Ori deliberately rejects exception-based control flow for several reasons:

- Exceptions hide logical paths and break determinism.  
- They allow failure to occur in parts of code not visible in the call site.  
- They require runtime stack unwinding and hidden control flow.  
- They make static analysis less reliable.  

By contrast, Ori’s error model is **linear and visible** — you can read the code and immediately understand all possible outcomes.

---

## 7. Advantages of Ori’s Approach

| Advantage | Description |
|------------|--------------|
| **Compile-time safety** | The compiler enforces explicit error handling before execution. |
| **Predictable runtime** | No hidden stack unwinding or exception handling. |
| **Consistent code** | Every function clearly declares whether it can fail. |
| **Self-documenting APIs** | Function signatures naturally reflect error semantics. |
| **Easier testing** | Error cases are first-class and can be tested directly. |

---

## 8. Trade-offs and Inconveniences

While Ori’s model is safer and clearer, it introduces certain inconveniences that developers must consciously accept.

| Inconvenience | Description | Mitigation |
|---------------|--------------|-------------|
| **More verbose code** | Requires frequent `if err != nil` checks or `try`. | Minimal syntax and editor tooling reduce friction. |
| **Slower prototyping** | Early experiments require explicit error checks. | IDE templates and code generators streamline repetitive handling. |
| **Propagation discipline** | Functions must declare and respect error return types. | Promotes cleaner, self-documented APIs. |
| **No global fallback recovery** | Crashes cannot be caught globally like exceptions. | Encourages modular fault isolation and local error control. |
| **Nested flow verbosity** | Deep call chains may require multiple `try` or `if` blocks. | Future versions may add scoped error guards for ergonomics. |

> Ori accepts verbosity as the cost of **honesty** in error handling.

---

## 9. Comparison Summary

| Aspect | Exceptions (Go-like recover or Java) | Ori’s Explicit Model |
|--------|--------------------------------------|----------------------|
| Visibility | Hidden in control flow | Always visible |
| Recovery | Implicit or global | Local and explicit |
| Enforcement | Runtime | Compile-time |
| Safety | Unchecked | Guaranteed |
| Readability | Non-linear | Linear and predictable |

---

## 10. Summary

Ori’s error philosophy treats failure as a **normal condition**, not an exception.  
It enforces correctness at compile time and keeps runtime logic predictable.

By trading conciseness for reliability, Ori eliminates an entire class of runtime bugs caused by ignored or hidden errors.

> “If it can fail, it must be visible.”

Explicitness, determinism, and compile-time validation — that is Ori’s foundation for trustworthy error handling.

---


# 004. Runtime and Memory Philosophy

Ori’s execution model is **deterministic, transparent, and runtime-free**.  
There is no garbage collector, no background scheduler, and no hidden runtime.  
Memory management is explicit, predictable, and visible in code.

> “Ori runs exactly what you wrote — nothing more, nothing less.”

---

## 1. Introduction

Ori favors **developer control** over automation.  
Unlike Go, which uses a garbage collector and background runtime, Ori requires the developer to manage resources directly.  
Like C++, it emphasizes **explicit lifetime and deterministic destruction** for performance and reliability.

---

## 2. Core Principles

| Principle | Description |
|------------|--------------|
| **No hidden runtime** | Ori compiles to standalone binaries without a background runtime or GC. |
| **Deterministic memory model** | Allocation, ownership, and deallocation are explicit and predictable. |
| **No garbage collector** | Memory is freed explicitly or via structured scope cleanup. |
| **No implicit reference counting** | There is no hidden retain/release or automatic lifetime tracking. |
| **Predictable performance** | No runtime pauses, allocations, or unpredictable overhead. |

---

## 3. Developer-Controlled Lifetime

Memory ownership is always explicit in Ori.  
A value’s lifetime is controlled by the scope in which it is created, and its release must be deliberate.

```ori
var user User = User{name: "Alice"}
var users []User = make([]User, 10)
free(users) // explicit release when done
```

> In Ori, resource lifetime is predictable because it’s visible in code.

---

## 4. Why No Garbage Collector

Garbage collectors simplify programming but remove control.  
They introduce runtime pauses, unpredictable cleanup timing, and hidden memory costs.

Ori, like C++, prioritizes **predictable control and deterministic destruction**.  
By making cleanup explicit, developers know exactly when resources are freed, improving performance and reliability in embedded and system-level programs.

> Go’s GC offers convenience. Ori offers certainty.

---

## 5. Runtime Guarantees

Ori provides **no hidden runtime behavior**:  
- No background threads or event loops.  
- No runtime memory manager.  
- No automatic stack resizing or allocation.  
- No leaks caused by invisible references.

Compiled binaries contain only what developers write and import — nothing else.

---

## 6. Explicit Resource Management

Ori adopts **RAII-like scope guards**, inspired by **C++ and Go**, to ensure deterministic cleanup without a garbage collector.

```ori
func useFile() {
    f := open("data.txt")
    defer f.close() // cleanup always triggered on exit
}
```

Scope guards combine the **determinism of C++’s RAII** with the **simplicity of Go’s `defer`**,  
providing predictable cleanup that requires no runtime or GC.

---

## 7. Safety vs Control

Ori enforces a strict but flexible safety model:

- **Safe defaults** — no use-after-free or dangling references (enforced by design).  
- **Explicit unsafe blocks** — allowed only in advanced use cases like FFI (future feature).  
- **Manual memory management** — developers control allocation (`alloc`, `free`, `copy`).  

This balance lets developers choose between control and safety explicitly.

---

## 8. Trade-offs

| Limitation | Description | Rationale |
|-------------|--------------|------------|
| **Manual cleanup** | Developers must release memory/resources explicitly. | Full control and visibility. |
| **Steeper learning curve** | Requires understanding ownership and lifetime. | Prevents hidden performance bugs. |
| **No automatic safety net** | Unsafe by neglect, safe by discipline. | Predictability and performance. |

> Ori favors correctness through control rather than safety through automation.

---

## 9. Future Directions

- Optional static ownership verification (borrow-check-like analysis).  
- Scoped heap allocations.  
- Reference and view types with compile-time lifetime validation.  

---

## 10. Summary

Ori’s runtime and memory philosophy:

- No hidden runtime.  
- No garbage collector.  
- No implicit threads or allocations.  
- Complete developer control over lifetime and performance.

> “You own what you allocate — and you see what you free.”

---


# 005. Concurrency and Predictability

Ori’s concurrency model is **explicit, deterministic, and runtime-free**.  
There is no hidden scheduler, no automatic goroutines, and no background threads.  
If your program runs tasks concurrently, that fact is **visible in code**.

> “If it runs concurrently, you should see it.”

---

## 1. Introduction

Ori supports concurrency as a **deliberate tool**, not a side effect.  
Developers explicitly create tasks, explicitly synchronize, and explicitly communicate.  
There is no implicit parallelism or runtime-managed scheduling.

---

## 2. Design Philosophy

| Principle | Description |
|-----------|-------------|
| **Explicit concurrency** | Tasks are created with a clear construct (`spawn`) and waited with `wait()`. |
| **No runtime scheduler** | Ori provides primitives; it does not run hidden schedulers or pools. |
| **Predictable behavior** | Execution order, synchronization, and lifetime are visible in code. |
| **Typed communication** | Channels (when used) are typed; capacity rules are explicit and documented. |
| **Safe synchronization** | All shared mutable state requires explicit synchronization. |

---

## 3. Explicit Task Spawning

Ori uses **explicit task creation** — no implicit goroutines or “async magic”.

```ori
func worker(id int) {
    fmt.Println("worker", id, "started")
    // ... do work ...
    fmt.Println("worker", id, "done")
}

func main() {
    task := spawn worker(1)
    task.wait() // explicit synchronization
}
```

- `spawn` starts a concurrent task.
- `wait()` blocks until the task completes.
- There is **no hidden scheduling** or background runtime: what you write is what runs.

---

## 4. Communication and Synchronization

Ori encourages clear, typed communication and explicit synchronization.  
Channel capacity semantics are **intentionally conservative for v0.5** (see note below).

```ori
// Typed channel example (capacity semantics TBD in v0.5)
var ch chan int = make(chan int, 2)

spawn func() {
    ch <- 42
}()

var value int = <-ch
fmt.Println("received:", value)
```

**Channel design (v0.5 stance):**
- Channels must declare a **concrete element type** (e.g., `chan int`).
- Capacity may be **specified or omitted**; detailed behavior (blocking, backpressure, errors) will be finalized in a future version.
- Ori will keep send/receive semantics **explicit** — no hidden runtime behavior.

> *Future: bounded vs unbounded semantics will be evaluated for predictability, backpressure, and memory safety before being finalized.*

---

## 5. Shared Data Rules

Shared mutable state must be protected by explicit synchronization.  
Ori forbids unsynchronized concurrent mutation.

```ori
func safeIncrement(counter *int) {
    var mu Mutex // scoped synchronization primitive
    mu.lock()
    counter += 1
    mu.unlock()
}
```

> In Ori, synchronization primitives (like `Mutex`) are **scoped or passed**, not global.  
> Global mutable state is not allowed.

After stating “avoiding race conditions at the language level,” Ori defines:

> **Race condition** — a situation where two or more concurrent tasks access shared data at the same time and at least one modifies it, causing **non-deterministic** outcomes.  
> Ori prevents this by requiring **explicit synchronization** for any shared mutable state.

---

## 6. Determinism and Task Lifetime

Ori’s model ensures task lifetime is **explicit and deterministic**:

- A task only exists if code explicitly `spawn`s it.
- A task finishes when work ends, and code **explicitly** `wait()`s for it.
- No hidden task pools or schedulers are active in the background.

This makes Ori suitable for **real-time**, **embedded**, and **predictable parallel** workloads.

---

## 7. Structured Concurrency (Future Direction)

Ori plans to introduce **structured concurrency**:

> All spawned tasks are **bound to a lexical scope**. When the scope ends, **all child tasks must complete or be cancelled deterministically**.

Conceptual sketch (illustrative, not final syntax):

```ori
scope s {
    t1 := s.spawn worker(1)
    t2 := s.spawn worker(2)
    s.waitAll() // scope cannot exit until tasks are resolved
}
```

Structured concurrency prevents “fire-and-forget” leaks and makes cancellation and cleanup deterministic.

---

## 8. Safer Message Passing (Future Direction)

Ori may introduce **ownership-aware channels** to ensure values sent between tasks are **safely transferred** (no aliasing surprises, clear ownership after send).

Goals:
- Typed, explicit ownership transfer semantics.
- Compile-time checks where possible.
- Predictable backpressure behavior (bounded queues, blocking modes, or explicit failure).

---

## 9. Trade-offs

| Limitation | Description | Rationale |
|-----------|-------------|-----------|
| **No automatic concurrency** | Developers must `spawn` and `wait()` explicitly. | Avoids unpredictability and hidden costs. |
| **More boilerplate** | Synchronization and communication are explicit. | Prioritizes clarity over brevity. |
| **Manual synchronization** | Developers must choose locks/channels carefully. | Guarantees visible concurrency behavior. |

> Ori trades convenience for **deterministic, analyzable** concurrency.

---

## 10. Summary

Ori’s concurrency is **explicit, predictable, and runtime-free**:

- `spawn` starts work; `wait()` finishes it.  
- Communication is typed; channel capacity semantics are **deliberately deferred** for a careful design.  
- Shared mutable state requires explicit synchronization.  
- Future: **structured concurrency** and **ownership-aware channels**.

> “Concurrency is a tool — not a background process.”

---


# 006. Imports and Visibility

Ori enforces a **clean, explicit, and deterministic** import system.  
No blank imports, no dot imports, no wildcards, and no hidden runtime initialization.  
Imports exist purely for code visibility and linking — not side effects.

> “Only what you import, you use — and only what you export, others see.”

---

## 1. Design Principles

| Principle | Description |
|------------|--------------|
| **Explicit imports** | Every import must use a string path and may include an alias. |
| **No blank or dot imports** | Hidden imports or namespace merges are forbidden. |
| **No wildcard imports** | Wildcard imports are forbidden — Ori will remain explicit. |
| **Scoped visibility** | Only imported names are visible; nothing leaks between modules. |
| **Public by capitalization** | Uppercase identifiers are exported; lowercase are internal. |
| **No runtime initialization** | There is no `init()` function or automatic global setup. |
| **Unused imports cause a compile-time error** | Explicitness is enforced — nothing implicit is allowed. |

---

## 2. Example: Correct Import Usage

```ori
package main

import "fmt"
import "os"
import net "http/net"

func main() {
    fmt.Println(os.Args)
    net.Get("http://orilang.org")
}
```

### Block Import Form

For readability, multiple imports can be grouped:

```ori
import (
    "fmt"
    "os"
    net "http/net"
)
```

Both forms are equivalent; grouping does not affect semantics.

---

## 3. Forbidden Import Forms

The following patterns are not allowed in Ori:

```ori
// ❌ Dot import — forbidden
import . "fmt"

// ❌ Blank import — forbidden
import _ "unsafe"

// ❌ Hidden initialization — forbidden
func init() { /* not supported */ }

// ❌ Wildcard or selective imports — forbidden
import "math" { Sin, Cos }
```

Ori disallows any import form that executes side effects or merges namespaces implicitly.
Wildcard or selective (e.g., `import "math" { Sin, Cos }`) imports won't be supported.

---

## 4. Global Scope Rules

- Only **`const`** declarations are allowed at the top level.  
- Global **mutable variables** are forbidden.  
- There is no `init()` function or implicit initialization phase.  
- Each module is loaded deterministically.

```ori
// ✅ Allowed
const Version string = "0.5"

// ❌ Forbidden
var Cache map[string]string // mutable global not allowed
```

---

## 5. Visibility Rules

| Symbol Type | Exported (Public) | Internal (Private) |
|--------------|------------------|--------------------|
| `FuncName` | ✅ | ❌ |
| `funcName` | ❌ | ✅ |
| `StructType` | ✅ | ❌ |
| `structType` | ❌ | ✅ |
| `CONST_NAME` | ✅ | ❌ |
| `varName` | ❌ | ✅ |

Public symbols are visible to importing modules; private ones remain internal.  
Visibility is lexical and determined by capitalization.

---

## 6. Compilation and Linking Behavior

Ori follows Go’s **clean linking model** rather than lazy compilation.

- When a package is imported, its source is **parsed and type-checked**.  
- Only **referenced identifiers** and their dependencies are included in the final binary.  
- **Unused imports cause a compile-time error.**  
- **Unused code** is eliminated during linking.

This ensures predictable and optimized binaries without partial or lazy compilation.

> “Only referenced code becomes part of the binary — nothing more, nothing hidden.”

---

## 7. Language Comparison

| Language | Import Behavior | Binary Impact |
|-----------|-----------------|---------------|
| Go | Compiles all, links only used symbols | Clean binaries |
| Zig | Compiles only referenced symbols | Lean, explicit |
| Rust | Compiles full modules, dead code eliminated by LLVM | Moderate |
| **Ori** | Compiles all, links only used symbols | Clean and predictable |

Ori intentionally mirrors Go’s deterministic linking strategy for simplicity and transparency while rejecting Go’s runtime initialization behaviors.

---

## 8. Future Directions

- Further compiler optimization for dependency resolution.

---

## 9. Summary

Ori’s import and visibility rules ensure clean namespaces and deterministic linking.  
No hidden imports, no runtime initialization, and no ambiguity in visibility or linkage.

> “If it’s imported, you see it. If it’s exported, you named it.”

---


# 007. Type System Philosophy

Ori’s type system emphasizes **clarity, explicitness, and safety through precision**.  
There are no implicit conversions, no automatic zero values, and no hidden type inference.  
Developers must always declare intent explicitly.

> “A type in Ori is a contract — not a guess.”

---

## 1. Core Design Principles

| Principle | Description |
|------------|--------------|
| **Explicit typing** | Every variable must declare its type explicitly. |
| **No inference** | `var a int = 123`, not `var a = 123`. |
| **No implicit conversions** | Conversions between numeric, string, or pointer types require explicit syntax. |
| **Strong type identity** | Types are not interchangeable unless explicitly converted. |
| **Compile-time checking** | Type correctness is verified before code generation. |
| **No automatic zero values** | Variables must be initialized by the developer. |

---

## 2. Type Categories

- **Primitives** — `int`, `uint`, `float`, `bool`, `rune`, `string`
- **Composite types** — `array`, `slice`, `map`, `hashmap`, `struct`
- **Reference-like types** — `view`, `ref` (planned for future versions)
- **User-defined types** — explicit `type` declarations

---

## 3. Type Safety and Explicit Conversion

Ori rejects implicit conversions that may lose information or change meaning.

```ori
var a int = 10
var b float32 = float32(a) // explicit conversion required
```

Conversions must always be deliberate and visible in code.

> “Ori will never convert for you — you must decide.”

---

## 4. Type Contracts and Identity

Two types are considered distinct unless explicitly declared compatible.

```ori
type Celsius int
type Fahrenheit int

func toF(c Celsius) Fahrenheit {
    return Fahrenheit((c * 9 / 5) + 32)
}
```

Even though both are based on `int`, they are different in type identity.

---

## 5. Errors as Types

Errors are first-class citizens in Ori.  
They are **typed values**, not exceptions or hidden control flow.  
They must be **declared**, **handled**, or **propagated** using `try`.

```ori
func openFile(path string) error {
    // returns explicit error type
}
```

---

## 6. Numeric Safety

- Integer overflow produces a **runtime panic** unless checked explicitly (`overflow_add`, `overflow_sub`, etc.).  
- No silent wraparound unless explicitly defined.  
- Signed and unsigned types are strictly distinct.  

This ensures consistent behavior across architectures and compilers.

---

## 7. Design Rationale

Ori’s type system prioritizes:

- **Predictable memory layout.**  
- **Compiler-verifiable contracts.**  
- **No implicit type inference.**  
- **No hidden conversions or automatic initialization.**  

> “Every value in Ori has a defined type, and every type has a defined behavior.”

---

## 8. Future Directions

- **Const generics** for arrays and numeric operations.  
- **View and shared qualifiers** for ownership and borrowing models (planned for v0.5+).  

---

## 9. Summary

Ori’s type system is **strong, explicit, and predictable** — designed to prevent ambiguity, enforce correctness, and support high-performance compilation.

> “Explicit types make implicit bugs impossible.”

---


# 001. Keywords

Ori reserves a minimal but expressive set of keywords.  
They have special syntactic meaning and **cannot be used as identifiers** for variables, functions, or types.

---

## Control Flow
```
if        else
for       range
switch    case
default   break
continue  fallthrough
return
```

---

## Declarations
```
package   import
const     var
func      type
struct    map
hashmap   chan
```

---

## Error Handling
```
error     try
```

---

## Memory & Lifetime
```
alloc     free
defer     shared
view
```

---

## Boolean Literals
```
true      false
```

---

## Future Reserved Words
These are reserved for potential advanced features:
```
unsafe    interface
spawn     implements
```

---

> Ori’s keyword set is **intentionally small and stable** — focused on clarity, control, and predictability.  
> New keywords will only be added if they improve readability without introducing hidden behavior.

---


# 002. Built-in Functions and Constants

Ori includes a **small, safe set of built-in functions and constants** that provide core language functionality.  
All other behavior belongs to imported modules.

---

## 1. Core Functions

| Function | Description | Example |
|-----------|--------------|----------|
| `len(x)` | Returns the length of arrays, slices, maps, strings, or channels. | `len(users)` |
| `cap(x)` | Returns the capacity of arrays, slices, or channels. | `cap(buffer)` |
| `append(slice, value)` | Returns a new slice with `value` appended. | `users = append(users, "Alice")` |
| `copy(src, dst)` | Copies elements from `src` to `dst`, returns count. | `n = copy(a, b)` |
| `delete(map, key)` | Removes a key from a map. | `delete(users, "id")` |
| `make(type, size)` | Allocates and initializes slices, maps, or channels. | `buf = make([]byte, 128)` |
| `new(Type)` | Allocates memory for a value of `Type`. | `ptr = new(User)` |

---

## 2. Error and Panic Utilities

| Function | Description | Example |
|-----------|--------------|----------|
| `error(msg)` | Creates a generic error value. | `return error("invalid state")` |
| `panic(msg)` | Immediately stops execution with a message. | `panic("unreachable")` |
| `assert(cond)` | Panics if condition is false. | `assert(x > 0)` |
| `todo()` | Marks unfinished code; panics at runtime. | `todo()` |

---

## 3. Memory and Lifetime

| Function | Description | Example |
|-----------|--------------|----------|
| `alloc(Type, size)` | Allocates a memory region for a type. | `p = alloc(int, 10)` |
| `free(ptr)` | Frees explicitly allocated memory. | `free(p)` |
| `defer(expr)` | Delays execution of `expr` until the end of the current scope. | `defer file.close()` |

---

## 4. Numeric Safety Helpers

| Function | Description | Example |
|-----------|--------------|----------|
| `overflow_add(a, b)` | Returns result and overflow flag. | `r, ok := overflow_add(a, b)` |
| `overflow_sub(a, b)` | Returns result and overflow flag. | `r, ok := overflow_sub(a, b)` |
| `overflow_mul(a, b)` | Returns result and overflow flag. | `r, ok := overflow_mul(a, b)` |

---

## 5. Built-in Constants

| Constant | Description |
|-----------|-------------|
| `nil` | Represents an uninitialized reference, map, slice, or error. |
| `true`, `false` | Boolean constants. |

---

> Ori’s built-ins are **minimal**, **safe**, and **explicit** —  
> each one can be understood in isolation, without hidden behavior or runtime magic.

---


# 003. Grammar Index

This appendix summarizes the main grammar rules for **Ori v0.5**, collected from all syntax and semantics sections.  
Ori uses **Wirth Syntax Notation (WSN)** — an alternative to **Extended Backus–Naur Form (EBNF)** —  
chosen for its clarity, compactness, and direct correspondence with language structure.

---

## 1. Program Structure
```
Program         = { PackageDecl | ImportDecl | TopLevelDecl } .
PackageDecl     = "package" Identifier .
ImportDecl      = "import" ( String | "(" { ImportSpec } ")" ) .
ImportSpec      = [ Identifier ] String .
TopLevelDecl    = ConstDecl | VarDecl | FuncDecl | TypeDecl | StructDecl .
```

---

## 2. Declarations
```
ConstDecl       = "const" Identifier Type "=" Expression .
VarDecl         = "var" Identifier Type "=" Expression .
TypeDecl        = "type" Identifier "=" Type .
```

---

## 3. Types
```
Type            = Identifier
                | ArrayType
                | SliceType
                | MapType
                | HashMapType
                | StructType
                | ChannelType .

ArrayType       = "[" Expression "]" Type .
SliceType       = "[]" Type .
MapType         = "map" "[" Type "]" Type .
HashMapType     = "hashmap" "[" Type "]" Type .
StructType      = "struct" "{" FieldList "}" .
ChannelType     = "chan" Type .

FieldList       = { FieldDecl } .
FieldDecl       = Identifier Type .
```

---

## 4. Functions
```
FuncDecl        = "func" Identifier "(" [ ParameterList ] ")" [ ResultList ] Block .
ParameterList   = Parameter { "," Parameter } .
Parameter       = Identifier Type .
ResultList      = Type | "(" Type { "," Type } ")" .
```

---

## 5. Statements
```
Statement       = Block | IfStmt | ForStmt | SwitchStmt
                | ReturnStmt | DeferStmt | ExpressionStmt .

Block           = "{" { Statement } "}" .

IfStmt          = "if" Expression Block [ "else" Block ] .
ReturnStmt      = "return" [ ExpressionList ] .
DeferStmt       = "defer" Expression .
ExpressionStmt  = Expression .
```

---

## 6. For Statement
```
ForStmt         = "for" ( ForRange | ForLoop | ForCondition ) .
ForRange        = Identifier [ "," Identifier ] ":=" "range" Expression Block .
ForLoop         = [ SimpleStmt ";" ] Expression [ ";" SimpleStmt ] Block .
ForCondition    = Expression Block .
```

---

## 7. Switch Statement
```
SwitchStmt      = "switch" [ Expression ] "{" { CaseClause } "}" .
CaseClause      = "case" ExpressionList ":" { Statement }
                | "default" ":" { Statement } .
```

---

## 8. Expressions
```
Expression      = UnaryExpr | BinaryExpr | PrimaryExpr .
UnaryExpr       = [ UnaryOp ] PrimaryExpr .
BinaryExpr      = Expression BinaryOp Expression .
PrimaryExpr     = Operand | Selector | Index | Call | SliceExpr .
ExpressionList  = Expression { "," Expression } .

Operand         = Identifier | Literal | "(" Expression ")" .
Selector        = PrimaryExpr "." Identifier .
Index           = PrimaryExpr "[" Expression "]" .
Call            = PrimaryExpr "(" [ ExpressionList ] ")" .
SliceExpr       = PrimaryExpr "[" [ Expression ] ":" [ Expression ] "]" .
```

---

## 9. Literals
```
Literal         = IntegerLit | FloatLit | StringLit | RuneLit | BooleanLit .
```

---

## 10. Error Handling
```
TryExpr         = "try" Expression .
ErrorLiteral    = "error" "(" String ")" .
```

---

## 11. Channels
```
SendStmt        = Expression "<-" Expression .
RecvExpr        = "<-" Expression .
```

---

## 12. Grammar Notes

- Identifiers use ASCII letters, digits, and underscores; must not start with digits.  
- Capitalized identifiers are **exported**, lowercase are **internal**.  
- Implicit conversions and zero values are **not allowed**.  
- Each declaration and expression must be **fully typed**.  
- Grammar aims for **predictable parsing** and **unambiguous compilation**.

---

> Ori’s grammar is designed to be clear, deterministic, and easy to implement in a recursive descent parser.  
> There is no syntactic sugar beyond these core rules.

---


# 004. Glossary

This glossary defines core terms used in the Ori language specification (v0.5).  
Each term has a single, explicit meaning in the context of the language.

---

### Alias
An alternate name for an imported package.  
```ori
import net "http/net"
```

---

### Block
A sequence of statements enclosed in braces `{ ... }`.  
Defines a new scope for variables and deferred operations.

---

### Channel
A typed conduit used for communication between concurrent routines.  
Channels are **explicitly created**, **typed**, and **not thread-safe by default**.

---

### Compile-time
The stage where the Ori compiler analyzes, type-checks, and optimizes code before binary generation.  
All type and syntax errors are caught here.

---

### Const
An immutable value known at compile time.  
Must be explicitly declared and initialized.

---

### Error
A first-class value representing a recoverable problem.  
Errors are never implicit; they must be handled, propagated (`try`), or explicitly ignored (compile-time error if not).

---

### Fallthrough
A keyword used in `switch` statements to continue execution into the next case explicitly.  
Implicit fallthrough is not supported.

---

### Function
A reusable block of code defined with `func`.  
Can return multiple values and must declare all result types.

---

### Global Variable
Forbidden in Ori. Only `const` declarations are allowed at the package level.

---

### Import
Brings external modules into scope.  
No wildcard, blank, or dot imports are supported.

---

### Interface
A future concept for describing contracts between types.  
Reserved but not implemented in v0.5.

---

### Map
An ordered associative container for key-value pairs.  
Keys must be comparable; modifying during iteration is prohibited.

---

### HashMap
An unordered associative container with constant-time access.  
Not thread-safe; must use synchronization when shared.

---

### Nil
Represents the absence of a value (uninitialized reference, map, slice, or error).  
Used explicitly — not as an implicit default.

---

### Ownership
A planned memory model concept for controlling value lifetimes and preventing data races (future version).

---

### Panic
A runtime stop triggered by `panic(msg)` or failed assertions.  
Includes file and line number information.

---

### Ref
A planned qualifier for referencing values without copying.  
Future feature for fine-grained control over memory semantics.

---

### Rune
Represents a single Unicode code point.  
Equivalent to a `char` in C, but safe for multibyte characters.

---

### Slice
A dynamic view of an array with length and capacity.  
Never reallocates implicitly — operations are explicit.

---

### Struct
A composite type grouping named fields.  
Fields must be explicitly initialized; no zero-value defaults exist.

---

### Try
Keyword for propagating errors upward.  
Short-circuits the function execution if an error is encountered.

---

### View
A planned qualifier for referencing non-owning slices or string sections without copying.  
Intended for safe, efficient read-only access.

---

> Ori’s terminology emphasizes **explicitness**, **predictability**, and **safety** —  
> every construct behaves visibly, with no hidden behavior or implicit side effects.

---



© 2026 Ori Language — Design Spec
