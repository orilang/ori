# Ori Design Specification

Welcome to the Ori language design documentation.  
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
- [Deterministic Destruction](semantics/215_DeterministicDestruction.md)
- [Control Flow](semantics/160_ControlFlow.md)
- [Methods And Interfaces](semantics/170_MethodsAndInterfaces.md)
- [Runtime And PanicHandling](semantics/180_RuntimeAndPanicHandling.md)
- [Concurrency](semantics/190_Concurrency.md)
- [Generic Types](semantics/200_GenericTypes.md)
- [Sum Types](semantics/210_SumTypes.md)
- [Deterministic Destruction](semantics/220_DeterministicDestruction.md)
- [Pattern Matching](semantics/240_PatternMatching.md)
- [Compile Time](semantics/250_Compiletime.md)
- [Container Ownership Model](semantics/260_ContainerOwnershipModel.md)
- [Modules And CompilationUnits - Phase 1](semantics/270_ModulesAndCompilationUnits_Phase1.md)
- [Modules And CompilationUnits - Phase 2](semantics/270_ModulesAndCompilationUnits_Phase2.md)
- [Compiler Directives And Keywords](semantics/280_CompilerDirectivesAndKeywords.md)
- [Foreign Function Interface](semantics/290_FFI.md)
- [Testing Framework - Phase 1](semantics/300_TestingFramework_Phase1.md)
- [Testing Framework - Phase 2](semantics/300_TestingFramework_Phase2.md)
- [Pointers](semantics/310_Pointers.md)
- [Blank Identifier](semantics/320_BlankIdentifier.md)
- [Build System And Compilation Pipeline](semantics/330_BuildSystemAndCompilationPipeline.md)
- [Build System And Compilation Pipeline - Phase 1](semantics/330_BuildSystemAndCompilationPipeline_Phase1.md)
- [Build System And Compilation Pipeline - Phase 2](semantics/330_BuildSystemAndCompilationPipeline_Phase2.md)
- [Compiletime Reflection](semantics/340_CompiletimeReflection.md)
- [Enums](semantics/350_Enums.md)
- [String Builder](semantics/360_StringBuilder.md)
- [File System And IO](semantics/370_FileSystemAndIO.md)
- [Logging Framework - Phase 1](semantics/380_LoggingFramework_Phase1.md)
- [UTF8 And Text Model](semantics/390_UTF8AndTextModel.md)
- [Executor And Tasks](semantics/400_ExecutorAndTasks_Phase2.md)

### Standard Library
- [Standard Library Foundations](ecosystem/001_StandardLibraryFoundations.md)
- [OS](ecosystem/001_OS.md)
- [Time](ecosystem/003_Time.md)
- [Core Packages Catalog](ecosystem/010_CorePackagesCatalog.md)

### Tooling
- [Compiler Diagnostics](tooling/001_CompilerDiagnostics.md)
- [LSP And Tooling](tooling/002_LSPAndTooling.md)

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
| Errors | `T, error` | `error` | `Result` | `error union` |
| Generics | Yes | Yes (Go 1.18+) | Yes | Yes |
| FFI | Yes | Yes | Yes | Yes |
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
package import var const func type struct if else for switch return break continue true false nil interface destructor comptime comptime_error extern void module package type
```

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
- The dot `.` import is forbidden

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
| `_test.ori` | Optional test files. |

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

## 15.5 Rune Literals

Rune literals represent single Unicode code points.

```ori
var ch = 'A'
```

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
type struct User {
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
| Struct | `struct` | `type struct Point { x int, y int }` |

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
type struct User {
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
type struct Point {
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
- The underscore (`_`) is reserved as the **blank identifier**.

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

## 40.4 Named Returns

Named return variables are under consideration.

---

## 40.5 Receivers and Methods

Functions can be declared with an explicit **receiver** to define methods on types:

```ori
type struct Point {
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
type struct User {
    id: ID
    name: string
}
```

Named types create distinct semantic types even if the underlying representation matches.

---

## 50.6 Struct Types

Structs group multiple named fields into one type.

```ori
type struct Point {
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
type struct Error {
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

Deferred calls and panic recovery are **not included in current version**, but may be explored later as structured constructs.

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

Modules are defined by a top-level manifest file or inferred from directory structure.

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
type struct User {
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

## References
- [100_Slices.md](semantics/100_Slices.md)
- [050_Types.md](syntax/050_Types.md)

---


# 110. Maps

## 110.1 Overview

A `map[K]V` is an **ordered dictionary** mapping unique keys of type `K` to values of type `V`.

- **Insertion order is preserved**.
- Lookup, insertion, and deletion are **amortized O(1)**.
- Maps are **mutable containers** and follow the rules of  
  `260_ContainerOwnershipModel.md`.

Maps store keys exactly as provided; there is **no reordering**, and **resizing never disturbs iteration order**.

---

## 110.2 Construction

Maps must be constructed explicitly:

```ori
var m map[string]int = make(map[string]int)
```

`nil` maps cannot store values:

```ori
var m map[string]int = nil
m["x"] = 1    // ❌ compile-time error
```

A literal form is allowed:

```ori
var m = map[int]string{
    1: "one",
    2: "two",
}
```

Literal ordering defines insertion order.

---

## 110.3 Insertion Order (Deterministic)

Ori guarantees:

### Rule 1 — The order of iteration is exactly insertion order.

Given:

```ori
m["a"] = 1
m["b"] = 2
m["c"] = 3
```

Iteration:

```
a → b → c
```

### Rule 2 — Reinserting an existing key does NOT change its position

```ori
m["b"] = 5
```

Order remains:

```
a → b → c
```

### Rule 3 — Deleting a key preserves the relative order of remaining keys

```ori
delete(m, "b")
```

Now order is:

```
a → c
```

### Rule 4 — Internal growth / reallocation preserves insertion order

Even if the map grows and allocates new storage, iteration order is unchanged.

This is a semantic guarantee, not an implementation detail.

---

## 110.4 Hashing and Determinism

Ori maps use hashing internally, but:

### 1. Hashing must be deterministic across all executions  
No per-run random seeds, no randomized iteration.

### 2. Hashing must be deterministic across platforms  
Hash("hello") must be equal on:

- Linux x64
- macOS ARM
- Windows x64

### 3. Hashing must be deterministic across compiler versions  
Unless explicitly documented in a major version bump.

### 4. Hash collisions are resolved in a deterministic way  
Iteration order is fully independent of internal hash table arrangements.

This allows:
- reproducible builds
- test determinism
- stable debugging
- no "map nondeterminism surprises"

---

## 110.5 Lookup

Standard rules:
```ori
value = m[key]
value, ok = m[key]
```

Lookups do not change iteration order.

---

## 110.6 Insert or Overwrite

```ori
m[key] = value
```

- If `key` is new → append to insertion list
- If `key` exists → replace `value`, position unchanged

---

## 110.7 Deletion

```ori
delete(m, key)
```

Effects:

- If present → remove the key/value pair
- Order of remaining keys is unchanged
- Future insertions append at the end

Deleting and reinserting restores key at *end*, not original position.

---

## 110.8 Copy and Aliasing

Assignment copies the **handle**, not the backing storage:

```ori
var a = make(map[string]int)
a["x"] = 1

var b = a    // aliasing
b["y"] = 2

// Now both a["y"] and b["y"] == 2
```

This matches all other containers in Ori.

---

## 110.9 Cloning

Clone must be explicit:
```ori
func CloneMap[K, V](src map[K]V) map[K]V {
    var out = make(map[K]V)
    for k, v := range src {
        out[k] = v
    }
    return out
}
```

Cloning:
- creates independent storage
- preserves insertion order
- does not clone values deeply unless user does so

---

## 110.10 Shallow vs Deep Cloning

Ori provides a standard library function for cloning maps:
```ori
func CloneMap[K, V](src map[K]V) map[K]V
```

This function performs a shallow clone of the map. Understanding the distinction between shallow clone and deep clone is essential for correct usage.

## 110.10.1 Shallow Cloning

A shallow clone creates a new map with its own independent internal storage, but keys and values are copied by assignment according to the semantics of their types.

Example:
```ori
var m1 = make(map[string][]int)
m1["a"] = []int{1, 2}

var m2 = CloneMap(m1)
m2["a"][0] = 99
```

Result:
- `m1` and `m2` do not share the same map container.
- but `m1["a"]` and `m2["a"]` alias the same slice, because assignment of slices copies the handle, not the underlying storage.

This behavior is intentional and consistent with Ori’s `260_ContainerOwnershipModel.md`.

---

## 110.10.2 Deep Cloning

A `deep clone` recursively duplicates all nested containers and values.

For example:
- slices inside a map would be cloned element-by-element
- maps inside maps would be recursively cloned
- user-defined structs might need their own clone semantics
- references, external resources, or handles might require special handling

Because deep cloning requires type-specific rules and may involve unbounded, implicit allocations, Ori does not define or perform deep cloning automatically.

Example of manual deep cloning:
```ori
func DeepCloneMap(sliceMap map[string][]int) map[string][]int {
    var out = make(map[string][]int)
    for k, v := range sliceMap {
        var clone = make([]int, len(v))
        copy(v, clone)
        out[k] = clone
    }
    return out
}
```

## 110.10.3 Why Ori Does Not Provide Automatic Deep Cloning

Ori deliberately does not offer deep cloning for these reasons:
- **Correct semantics are type-dependent**
  - A deep clone of a file descriptor, mutex, channel, or handle is either meaningless or unsafe.
- **Hidden allocations violate Ori’s explicitness philosophy**
  - Deep clone may recursively allocate large amounts of memory without the programmer being aware
- **Performance ambiguity**
  - Deep cloning can accidentally become O(N²) or worse on nested structures
- **No global rule applies to all values**
  - Should a pointer be cloned or shared?
  - Should a StringBuilder be duplicated or aliased?
  - Should a map inside a struct be shallow-cloned or deep-cloned?
  - Ori cannot make correct assumptions
- **Deterministic destruction becomes unclear**
  - Automatically duplicating nested containers complicates destruction order and memory guarantees defined in `220_DeterministicDestruction.md`.
- **Predictability and simplicity**
  - Shallow cloning is easy to explain, easy to reason about, and follows the same semantics as all other containers (slices, maps, hashmaps, StringBuilder, etc.).

---

## 110.11 Deterministic Destruction

When the last handle referencing a map dies:

- all keys and values are dropped  
- deterministic destruction order: in insertion order  
- consistent with `220_DeterministicDestruction.md`

---

## 110.12 Concurrency

Maps are not thread-safe.

Rules:
- Concurrent writes → undefined behavior and compile-time warning if detectable  
- Reads are safe only if no concurrent writes  
- Shared maps must be protected by synchronization primitives  

---

## 110.13 Examples

### 110.13.1 Basic Usage

```ori
var m map[string]int = make(map[string]int)

m["a"] = 1
m["b"] = 2

for k, v in m {
    print(k, v)
}
// Output: a 1, b 2
```

### 110.13.2 Overwriting a Key

```ori
m["a"] = 10
// Order remains: a → b
```

### 110.13.3 Deleting a Key

```ori
delete(m, "a")
// Order: b
```

### 110.13.4 Cloning a Map

```ori
var original = make(map[string]int)
original["x"] = 1
original["y"] = 2

var clone = CloneMap(original)
clone["x"] = 99

// original["x"] == 1
// clone["x"] == 99
```

---


# 111. HashMaps

## 111.1 Overview

A `hashmap[K]V` is an **unordered dictionary** mapping unique keys of type `K` to values of type `V` using hash-based indexing.

Unlike `map[K]V`, a `hashmap[K]V` does **not** preserve insertion order.  
Iteration order is **unspecified**, but always **deterministic** for a given container state.

Hashmaps are **mutable containers** and follow the rules of `260_ContainerOwnershipModel.md`.

---

## 111.2 Construction

Hashmaps must be constructed explicitly:

```ori
var h hashmap[string]int = make(hashmap[string]int)
```

A literal form is allowed:

```ori
var h = hashmap[int]string{
    1: "one",
    2: "two",
}
```

Iteration order of literals is **unspecified**, even though the literal lists keys in a specific order.

`nil` hashmaps cannot store values:

```ori
var h hashmap[string]int = nil
h["x"] = 1    // ❌ compile-time error
```

---

## 111.3 Hashing and Determinism

Hashmaps rely on hashing internally. Ori guarantees:

### Rule 1 — Hashing is deterministic across all executions  
The same key always produces the same hash value across runs.

### Rule 2 — Hashing is deterministic across platforms  
Hash("a") is identical on:
- Linux x64
- macOS ARM
- Windows x64

### Rule 3 — Hashing is deterministic across compiler versions  
Unless explicitly changed in a major version with migration notes.

### Rule 4 — Hash collisions are resolved in a deterministic way  
Different keys hashing to the same bucket are handled in a stable, reproducible manner.

These rules ensure:
- reproducible builds  
- deterministic tests  
- predictable debugging  

Ori **never** uses randomized hash seeds.

---

## 111.4 Iteration (Unordered Yet Deterministic)

Iteration order is **unspecified**, but obeys strict rules:

1. The order is **deterministic for the current container state**.  
2. A mutation (insert/delete) may change iteration order.  
3. Resizing or rehashing may change iteration order.  
4. The same sequence of operations produces the same iteration order in all executions.

Example:

```ori
for k, v := range h {
    print(k, v)
}
```

No guarantees are made about the actual sequence of keys, only that the order is deterministic, stable, and repeatable.

---

## 111.5 Insert or Overwrite

```ori
h[key] = value
```

Rules:
- If `key` is new → inserted into a bucket based on its hash  
- If `key` exists → value replaced, bucket position unchanged  

Unlike `map[K]V`, hashmaps do **not** maintain insertion order metadata.

---

## 111.6 Lookup

```ori
value = h[key]
value, ok = h[key]
```

Lookups do not affect iteration order.

---

## 111.7 Deletion

```ori
delete(h, key)
```

Effects:

- If `key` exists → removed from its bucket  
- Iteration order may change due to internal rebalancing  
- Future insertions may reuse deleted slots  

---

## 111.8 Copy and Aliasing

Hashmaps behave like all containers in Ori:

```ori
var a = make(hashmap[string]int)
a["x"] = 1

var b = a   // aliasing
b["y"] = 2

// a["y"] == 2
// b["x"] == 1
```

Assignment copies the handle, not the storage.

---

## 111.9 Cloning (Shallow)

Ori provides:

```ori
func CloneHashMap[K, V](src hashmap[K]V) hashmap[K]V
```

This performs a **shallow clone**:

- new independent backing table  
- keys and values copied by assignment  
- nested containers are **not deep-cloned**  

Deep cloning must be implemented by the developer as specified for `maps`.

---

## 111.10 Deterministic Destruction

When the last handle referencing a hashmap dies:

- all keys and values are destroyed
- destruction order is **unspecified** but deterministic for the container state
- matches the rules of `220_DeterministicDestruction.md`

Hashmaps do not expose a stable iteration order, so destruction order is intentionally unspecified.

---

## 111.11 Concurrency

Hashmaps are not thread-safe.

Rules:
- Concurrent writes are undefined behavior and may cause compile-time errors
- Reads are safe only when no concurrent writes occur
- Shared hashmaps require explicit synchronization

---

## 111.12 Examples

### 111.12.1 Basic Usage

```ori
var h hashmap[string]int = make(hashmap[string]int)

h["a"] = 1
h["b"] = 2

for k, v := range h {
    print(k, v)
}
// Output order is unspecified but deterministic.
```

### 111.12.2 Overwrite

```ori
h["a"] = 10
```

### 111.12.3 Delete

```ori
delete(h, "b")
```

### 111.12.4 Clone

```ori
var clone = CloneHashMap(h)
clone["x"] = 99
```

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
type struct User {
    name string
    age  int
}
```

Optional field defaults can be specified:

```ori
type struct Config {
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
type struct Config {
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
type struct User {
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

---

## 130.8 Methods

Structs can have associated methods declared with explicit receivers.

### Grammar

```
MethodDecl = "func" "(" Receiver ")" Identifier "(" [ Parameters ] ")" [ ReturnType ] Block .
```

### Example

```ori
type struct User {
    name string
    age  int
}

func (u User) Greet() {
    fmt.Println("Hello,", u.name)
}
```

### Mutating methods

Methods that modify the receiver must use the `shared` qualifier:
```ori
func (u shared User) Birthday() {
    u.age += 1
}
```

This is semantically similar to Go’s pointer receiver but with safe reference semantics.

---

## 130.9 Composition and Embedding

Ori **does not support type-name embedding** or **field promotion**.

### ❌ Invalid

```ori
type struct Address {
    city string
    country string
}

type struct User {
    name string
    Address // forbidden
}
```

### ✅ Valid

```ori
type struct Address {
    city string
    country string
}

type struct User {
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
type struct Example {
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
type struct Error {
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
type struct ParseError {
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

### 170.2.1 Grammar
```
MethodDecl = "func" "(" Receiver ")" Identifier "(" [ ParameterList ] ")" [ FuncResult ] Block .
Receiver    = [ ReceiverModifier ] Identifier Type .
ReceiverModifier = "shared" | "const" .
```

### 170.2.2 Receiver Semantics

| Modifier | Description |
|-----------|--------------|
| *(none)* | The method operates on a copy of the receiver. |
| `shared` | The method operates on a reference to the original instance (can modify). |
| `const` | The method operates on a read-only reference (cannot modify). |

### 170.2.3 Example
```ori
type struct User {
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

### 170.2.4 Receiver Restrictions

Ori forbids using raw pointers (*T) as method receivers.

Raw pointers are unsafe, nullable, may dangle, and do not participate in lifetime or aliasing checks (§310_Pointers). They cannot serve as method receivers because methods must operate on safe, well-defined memory references.

**Valid receiver** categories:
```
func (t Test) run()
```

**Shared receiver** — operates on the original instance, mutation allowed
```
func (t shared Test) update()
```

**Const receiver** — operates on the original instance, read-only
```
func (t const Test) print()
```

Forbidden:
```
func (t *Test) count() int   // ❌ invalid: raw pointers cannot be receivers
```

This ensures predictable aliasing, safe access, and compatibility with Ori’s ownership, memory, and concurrency rules.

---

## 170.3 Method Overloading

Ori **does not support method overloading**.  
Each method name must be **unique** within a type’s method set, regardless of parameter types or receiver kind.

This design prevents ambiguity and ensures clear, deterministic method resolution.

### ✅ Valid
```ori
type struct User {
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
type interface Greeter {
    greet() string
}
```

Any type implementing `Greeter` must define a compatible `greet()` method.

If an interface defines **multiple methods**, the implementing type must define **all** of them.  
Otherwise, the compiler emits an explicit error.

Example:
```ori
type interface Greeter {
    greet() string
    identify() string
}

type struct User { name string }

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
type interface Greeter {
    greet() string
}
```

#### Step 2. Define concrete types
```ori
type struct User {
    name string
}

type struct Bot {
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
| `interface Greeter` | Declares required methods. |
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

Ori supports **dynamic polymorphism** via interfaces, and intends to support **static polymorphism** (monomorphism) via generics.

---

## 170.8 Monomorphism (Static Polymorphism)

**Static polymorphism** means the compiler generates **specialized code** for each concrete type used with a generic function.

### Example
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

### Example
```ori
type interface Drawable {
    draw()
}

type struct Circle { radius int }
type struct Square { size int }

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
- **Generics** provide **static polymorphism** (compile-time specialization).

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
| Status in Ori | Implemented | Implemented |

---

## 170.11 Summary

| Concept | Description |
|----------|--------------|
| **Method** | Function bound to a type. |
| **Receiver** | `shared`, `const`, or value; defines access semantics. |
| **Interface** | Declares a set of required methods. |
| **implements** | Declares explicit conformance between a type and an interface. |
| **No overloading** | Prevents ambiguity in method lookup. |
| **Dynamic dispatch** | Safe runtime polymorphism via method tables. |
| **Monomorphism** | Compile-time specialization via generics. |
| **Polymorphism** | Runtime dispatch via interfaces (available). |

---

Ori’s method and interface system emphasizes **explicitness**, **clarity**, and **predictable behavior**,  
with a clear path toward efficient compile-time polymorphism.

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
2. Stack unwinding begins — deferred cleanup functions may run (planned support).  
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

## 180.4 Recovering from Panics

Panics are **fatal and non-recoverable**.  
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
| No implicit recovery | Panics always terminate unless a recovery (planned) scope is explicitly defined. |
| Stack trace visibility | Always printed before termination. |
| RAII-like cleanup (planned) | Resource Acquisition Is Initialization cleanup like defer will be introduced is planned. |

---

## 180.8 Summary

| Feature | Description |
|----------|--------------|
| `panic` | Triggers immediate program termination. |
| `assert` | Checks invariants; panics on failure. |
| `todo` | Marks unimplemented code with standardized panic message. |
| `error` | Represents recoverable conditions in normal flow. |
| **No recovery yet** | Planned. |
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

No cancellation API for now.

---

## 190.17 Error Integration

This note specifies how the unified `Error` type is used in task handling.

### 190.17.1 Task Wait Error Semantics

Task handles expose a `Wait` method that returns the canonical `Error` type:

```ori
type struct Task {
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


# 200. Generic Types

This document defines the **semantic rules** for Ori’s generic types and

---

## 200.1 Overview

Generic types introduce **parametric polymorphism** into Ori.  
They allow functions, structs, and type aliases to be parameterized over **types**.

Semantics are based on:
- **Static typing**
- **Monomorphization at instantiation sites**
- **Zero-cost abstraptions**
- **No constraints or specialization for now**

Type parameters apply only at **compile time** and do not exist at runtime.

---

## 200.2 Generic Functions Semantics

### 200.2.1 Declaration

Ori uses function syntax with square brackets for type parameters:

```
func name[T1, T2](params...) ReturnType { ... }
```

#### Grammar

```
GenericFunctionDecl =
    "func" Identifier "[" TypeParamList "]"
    "(" ParamList ")" Type Block ;

TypeParamList =
    Identifier { "," Identifier } ;

GenericTypeDecl =
    "struct" Identifier "[" TypeParamList "]" StructBody
  | "type" Identifier "[" TypeParamList "]" "=" Type ;
```

### 200.2.2 Generic Functions

Example:
```
func max[T](a T, b T) T {
    if a > b {
        return a
    }
    return b
}
```

- `func` keyword
- `max[T]` declares a single type parameter `T`
- Parameters are `name Type`
- Return type follows the parameter list

### 200.2.3 Generic Types

### Structs
```
type struct Box[T] {
    value T
}
```

### Type Aliases
```
type List[T] = struct {
    items []T
}
```

### Sum Types (syntax example; generic behavior only)
```
type Option[T] =
    | Some(T)
    | None
```

## 200.3 Generic Methods

Methods on generic types inherit type parameters:

```
func (b Box[T]) Unwrap() T {
    return b.value
}
```

Methods may introduce new type parameters:

```
func (b Box[T]) Convert[U](f func(T) U) U {
    return f(b.value)
}
```

---

## 200.4 — Instantiation Rules

### 200.4.1 Explicit Instantiation

Always allowed:

```
var x = max[int](3, 7)
var y = max[string]("a", "b")
```

### 200.4.2 Instantiation Produces Concrete Types

```
var a Box[int]
var b Box[string]
```

Produces:
- `Box[int]    → struct { value int }`
- `Box[string] → struct { value string }`

Each is a distinct type.

### 200.4.3 Generic Function Instantiation

```
max[int](3, 5)
max[float](1.0, 2.0)
```

Each produces a unique monomorphized function.

### 200.4.4 Composite Types with Generics

```
var arr []Box[int]
var table [10]Option[float]
var m map[string, List[int]]
```

### 200.4.5 Multiple Type Parameters

```
type struct Pair[T, U] {
    left  T
    right U
}
```

Usage:

```
var p Pair[int, string]
```

### 200.4.6 Generic Methods Instantiation

Given:

```
func (p Pair[T, U]) Swap() Pair[U, T] { ... }
```

Instantiated only when used:

```
var p Pair[int, string]
p.Swap()   // produces Pair[string, int]
```

### 200.4.7 Invalid Instantiations

```
Box[int, string]         // ❌ wrong number of type parameters
max[T](3, 4)             // ❌ T undeclared
Box[Foo()]               // ❌ value, not a type
```

---

## 200.5 — Monomorphization Model

### 200.5.1 Generic Type Monomorphization

Each instantiation generates a specialized version.

```
Box[int]
Box[string]
```

Each is:
- a unique concrete type
- with its own layout
- with its own destructor behavior (if any)

### 200.5.2 Generic Function Monomorphization

```
func max[T](a T, b T) T
```

Calls produce:

```
max$int(int, int) int
max$float(float, float) float
```

### 200.5.3 Cross-Module Monomorphization

Instantiation happens at **use site**, not definition site.

Library:

```
type struct Box[T] { value T }
```

Application:

```
var a Box[int]
var b Box[string]
```

Application module produces:
- `Box[int]`
- `Box[string]`

Library module does not produce monomorphized versions.

### 200.5.4 Incremental Compilation

The compiler caches monomorphized instantiations using:
- module path
- definition hash
- type argument list

### 200.5.5 Dead Code Elimination

```
max[int](3,4)
max[string]("a","b")   // unused
```

Only `max[int]` remains in the final binary.

### 200.5.6 Generic Methods on Generic Types

Instantiated only when invoked.

### 200.5.7 ABI Behavior

Each instantiation:
- has a concrete ABI
- is fully inlinable
- contains no runtime type info

### 200.5.8 Error Behavior

Compile-time errors appear only when an instantiation is reached:

```
func foo[T]() {
    var x T
    x.NotExists()   // error only if foo[T] is instantiated
}
```

---

## 200.6 — Type Inference Rules

### 200.6.1 Allowed Inference (Functions Only)

Inference is allowed only from argument types.

```
var a int = 3
var b int = 10

var m = max(a, b)   // T = int inferred
```

Another example:

```
func map[T, U](in []T, f func(T) U) []U

map([]int{1,2,3}, square)   // T=int, U=int
```

### 200.6.2 Forbidden Inference

#### 200.6.2.1 From Return Type
```
var x int = NewZero()  // ❌ T cannot be inferred
```

#### 200.6.2.2 From Assignment Context
```
var x = NewZero()  // ❌
```

#### 200.6.2.3 Ambiguous Arguments
```
max(3, 2.0)  // ❌ int vs float
```

#### 200.6.2.4 Partially Undetermined Parameters
```
func MakePair[T, U](v T) Pair[T, U]

MakePair(10)   // ❌ U is unconstrained
```

Must be explicit:

```
MakePair[int, string](10)
```

### 200.6.3 Generic Methods

Receiver fixes type params:

```
var b Box[int]
b.Unwrap()   // T = int
```

### 200.6.4 Generic Types Never Infer

```
var b Box[int]      // ok
var c Box           // ❌
var d = Box[int]{...} // ok
var e = Box{...}    // ❌
```

---

## 200.7 — Interaction With Existing Features

### 200.7.1 Slices & Arrays

#### Slices

```
var s []T
var s2 []Box[int]
```

#### Arrays

Allowed only after monomorphization:

```
var a [10]T       // ok when T is concrete
```

Forbidden:

```
var a [len(T)]    // ❌ T has no runtime value
```

### 200.7.2 maps

Key comparability validated **after instantiation**:

```
map[[]int, int]   // ❌ slice not comparable
map[int, User]    // ok
```

### 200.7.3 Sum Types

```
type Option[T] =
    | Some(T)
    | None
```

Fully monomorphized per T.

### 200.7.4 Concurrency

```
func SpawnTask[T](work func() T) TaskHandle[T]
```

Generic task handles allowed.

### 200.7.5 Memory Model

Generic instantiations integrate naturally:

```
Box[T] has a destructor if T has a destructor.
```

### 200.7.6 Modules & Build System

Monomorphization at use-site ensures:
- stable ABIs
- small libraries
- predictable binary layout

### 200.7.7 FFI

Direct FFI of generic instantiations **not allowed**:

```
extern func Process(Box[int])  // ❌
```

Must name it:

```
type IntBox = Box[int]
extern func Process(IntBox)    // ok
```

### 200.7.8 Reflection

No runtime type info for generics in current version.

---

## 200.8 — Restrictions of the current version

Constraints are not part of current implementation. A future version may introduce a constraint system using interface-like or rule-based bounds.

### 200.8.1 No Constraints / Traits
No:
```
func max[T ordered](...)
func Print[T comparable](...)
```

### 200.8.2 No Higher-Kinded Types

```
func Use[F[_]](...)    // ❌
```

### 200.8.3 No Const Generics

In current version, type parameters are types only, not values.

So we do not have:
```
// ❌ not in current version
type struct1 Matrix[T, N int] {
    data [N][N]T
}
[T = int](v T) []byte { ...special int version... }
```

For now:
- Array sizes are normal compile-time expressions, not type parameters.
- Generics don’t know about integer constants.


### 200.8.4 No Specialization

```
func foo[T](...)
func foo[int](...)   // ❌
```

### 200.8.5 No Inference from Return Type

```
func NewZero[T]() T { ... }
var x int = NewZero()  // ❌ illegal in current versions
var xy = NewZero()     // ❌ illegal in current versions
```

You must write:
```
var x int = NewZero[int]()

```


### 200.8.6 No Type Inference for Generic Types

```
type struct Box[T] { value T }

var b Box[int]          // ✅
var c Box               // ❌ missing [T]
var d = Box[int]{ ... } // ✅
var e = Box{ ... }      // ❌ cannot omit [T]

```

### 200.8.7 No Type Parameter Defaults

```
type struct map[K, V = any]   // ❌
// ❌ invalid idea: leaving second parameter as wildcard
type IntMap[V] = Map[int, V]        // this is OK as alias
var m Map[int, _]                   // ❌ no placeholder `_`
```

### 200.8.8 No Variadic Type Parameters

```
type struct Tuple[...T]   // ❌
```

### 200.8.9 No Runtime Type Introspection

```
func Debug[T](v T) {
    println(typeof(T).Name)  // ❌ no such thing in current version
}
```

### 200.8.10 No Auto-Boxing or Erased Generics

No Java/C# style erasure or implicit “any”.
```
func PrintAll(values []any)  // only if you define `any` as a real type
```

### 200.8.11 No Specialization / Overload by Type Parameter

You can’t write two different implementations of the same generic function specialized for different concrete T and have the compiler pick “the best match”.

Example that is not allowed:
```
// ❌ not in current version
func Serialize[T](v T) []byte { ...generic path... }
func Serialize[T = int](v T) []byte { ...special int version... }
```

---

## Summary

Ori current version generics implementations are:
- Generic functions and types with explicit `[T]`
- Static monomorphization at use-site
- Simple, predictable inference rules
- No runtime overhead or type metadata
- Safe integration with slices, maps, sum types, concurrency, memory model, and modules
- Strict restrictions to maintain clarity and avoid premature complexity
- integrated with existing systems
- without constraints, specialization, or type-level features

---


# 210. Sum Types (Algebraic Data Types)

Sum types allow a value to take one of several well-defined variants, each optionally carrying typed payload fields.  
Ori adopts a clean, ML-style syntax (Meta Language family) using `|` to declare variants, enabling expressive modeling of states, domain data, and configuration-like structures.

---

## 210.1 Overview

A sum type is declared as:

```
type Shape =
    | Circle(radius float)
    | Rect(w float, h float)
```

Key characteristics:
- `type Name =` introduces the sum type.
- Each variant begins with `|`.
- Each variant behaves as a **compile-time constructor** for the sum type.  
  Constructors use function-call syntax but are **not** regular functions.
- Each variant has:
  - a name (`Circle`, `Rect`),
  - an optional payload list (`radius float`, `w float, h float`),
  - parentheses always present (empty or not).

Sum types enable clean, explicit representation of data that may take multiple structured forms without relying on interfaces or manual tagging.

---

## 210.2 Grammar

```
SumTypeDecl   = "type" Identifier "=" VariantList
VariantList   = Variant { Variant }
Variant       = "|" Identifier "(" [ VariantFields ] ")"
VariantFields = VariantField { "," VariantField }
VariantField  = Identifier Type
```

Construction:

```
VariantExpr = Identifier "(" [ Arguments ] ")"
Arguments   = Argument { "," Argument }
Argument    = (Identifier ":" Expression) | Expression
```

Switch (minimal, binding-only model):

```
SwitchStmt   = "switch" Expression "{" { CaseClause } "}"
CaseClause   = "case" Identifier("(" Identifier ")" ) ":" Block
```

---

## 210.3 Construction

A sum type value is constructed by calling the variant name as if it were a function.

### Named arguments
```
var s = Circle(radius: 10)
var r = Rect(w: 4, h: 3)
```

### Positional arguments
```
var s = Circle(10)
var r = Rect(4, 3)
```

Named arguments improve clarity; positional arguments improve brevity.  
Both forms follow Ori’s parameter rules consistently.

---

## 210.4 Switching and Variant Binding

In the current version, variant binding is simple and does not support destructuring of fields.

```
switch shape {
    case Circle(c):
        print(c.radius)

    case Rect(r):
        print(r.w, r.h)
}
```

Rules:
- The identifier in parentheses (`c`, `r`) binds to the payload container.
- No field-destructuring syntax is included yet.
- All variants must appear in the switch (exhaustiveness).

---

## 210.5 Exhaustiveness Checking

Ori enforces full exhaustiveness for sum types.

Example:

```
type T =
    | A(x int)
    | B(y float)
    | C(z string)
```

Invalid:

```
switch value {
    case A(a):
    case B(b):
}
```

Compiler error:
```
non-exhaustive switch: missing variant C
```

This ensures correctness and eliminates silent fallthrough or forgotten branches.

---

## 210.6 Type System Semantics

### 210.6.1 Variant Tag

Each instance stores:
- a compiler-generated hidden tag,
- inline payload storage.

### 210.6.2 Active Variant Rules

- Exactly one active variant exists at any time.
- Overwriting a value replaces the previous active variant and applies destructor rules if needed.
- **Any reference, pointer, or view to the payload of a previous variant becomes invalid immediately after the variant changes. Accessing such invalidated payload is always a compile-time error. Ori never produces a runtime safety error for variant invalidation.**

#### Example

```
var shape = Circle(radius: 5)

// shape currently holds Circle
print(shape)  // Circle(5)

// Overwrite with Rect: previous Circle payload is discarded
shape = Rect(w: 2, h: 3)

// Accessing the previous variant's payload is always illegal:
var x = shape.radius   // ERROR: Circle is no longer active and will produce a compile-time error.
```

### 210.6.3 Move Semantics

Moving a sum type moves:
- the tag,
- the active payload.

Ownership and lifetime rules follow the memory model defined previously.

#### Example

```
var a = Circle(radius: 10)

// Move a into b
var b = a

// After the move, a becomes invalid for use,
// and b now owns the Circle(10) value.
```

If payload fields contain resources with destructors, transferring ownership transfers cleanup responsibility.

---

## 210.7 Interaction With Deterministic Destruction

If a variant contains fields with destructors:
- destruction occurs when the value goes out of scope,
- or when the active variant is overwritten,
- or when the value is moved and the source becomes invalid.

Destructor behavior follows the deterministic destruction rules defined elsewhere (keyword/name TBD).

---

## 210.8 Generic Sum Types

Errors are regular struct types and functions return tuples like `(T, error)`.

Correct generic sum type examples:

### Optional values

```
type Option[T] =
    | Some(value T)
    | None
```

### Domain modeling (not error handling)

```
type ParseNode =
    | Number(value int)
    | Text(value string)
    | List(items []ParseNode)
```

### State machines

```
type ConnectionState =
    | Disconnected
    | Connecting(attempt int)
    | Connected(addr string)
```

These use cases are valid because they do **not** overlap with Ori’s tuple-return error system.

---

## 210.9 Full Example

Below is a complete, realistic example combining construction, movement, active variant replacement, switching, and optional values.

```
type Shape =
    | Circle(radius float)
    | Rect(w float, h float)

func describe(s Shape) string {
    switch s {
        case Circle(c):
            return "Circle radius=" + string(c.radius)

        case Rect(r):
            return "Rect w=" + string(r.w) + " h=" + string(r.h)
    }
}

func main() {
    var s1 = Circle(radius: 8)   // inferred to type Shape
    var s2 = Rect(w: 3, h: 4)    // inferred to type Shape

    // Overwrite (active variant changes)
    s1 = Rect(w: 10, h: 2)

    // Move ownership
    var s3 = s1  // s1 becomes invalid

    print(describe(s2)) // "Rect w=3 h=4"
    print(describe(s3)) // "Rect w=10 h=2"
}
```

---

## 210.10 Summary

This document defines sum types for the current Ori specification:

- ML-style variant syntax using `|`.
- Only compile-time errors for invalidated variant access (never runtime).
- Simple, clean construction syntax supporting named and positional arguments.
- Binding-only switching model with enforced exhaustiveness.
- Clear rules for active variant invalidation and move semantics.
- Straightforward grammar for declarations, constructions, and switch statements.
- Integration with ownership, moves, and deterministic destruction.
- Generic sum types allowed for data modeling (but not for error modeling).
- No future-version assumptions included.

This establishes a robust and extensible foundation for algebraic data types in Ori.

---


# 220 Deterministic Destruction

## 220.1 Overview

Deterministic destruction in Ori defines how resources are safely and predictably cleaned up when an owning value reaches the end of its lifetime.  
This mechanism integrates with the ownership and lifetime model and extends it with destructors and structured `defer` semantics.

---

## 220.2 Goals

- **Predictable cleanup** at lexical scope exit.
- **Zero-panic destructors**: destructor bodies must not contain any code path that can panic.
- **Safe interplay with `defer`**, which runs before destructors.
- **Move-only semantics** for types that declare destructors.
- **Deterministic behavior during panic unwinding.**
- **Explicit, opt-in cleanup**: only types declaring destructors participate.

---

## 220.3 Core Concepts

### 220.3.1 Destructor (conceptual)

A **destructor** is a block associated with a type:

```ori
destructor TypeName {
    // cleanup logic
}
```

Inside this block:
- `value` refers to the owned instance being destroyed
- It is implicitly provided by the compiler
- It cannot be reassigned or moved out
- It is always valid for the duration of the destructor execution

One destructor may be defined per nominal type.

### 220.3.2 Owning Value

Only **owning values** can trigger destruction. Non-owning references (`view`, `shared`, etc.) never run destructors.

### 220.3.3 Destruction Point

A value is destroyed when:
- Its scope ends (normal exit)
- Control-flow leaves its scope early (`return`, `break`, `continue`)
- Ownership is transferred (full move)
- A panic unwinds past its scope

---

## 220.4 When Destruction Occurs

### 220.4.1 Normal Scope Exit

Values are destroyed in **reverse declaration order** (LIFO).  
Destructors run only for types that declare them.

### 220.4.2 Early Exit

`return`, `break`, `continue` trigger destruction of local variables before control flow leaves the scope.

### 220.4.3 Panic Unwinding

During panic unwinding:

1. All `defer` blocks execute in **reverse registration order**.
2. All destructors run in **reverse declaration order**.

Destructors cannot panic, ensuring no double-unwind hazards.

---

## 220.5 Interaction with `defer`

### 220.5.1 Syntax

```ori
defer statement
```

or

```ori
defer {
    // block
}
```

### 220.5.2 Ordering

On scope exit:

1. `defer` blocks (LIFO)
2. destructors (LIFO)

Example:

```ori
func f() {
    var a A
    defer log("first")
    var b B
    defer log("second")
}
// exit order: log("second"), log("first"), destroy b, destroy a
```

---

## 220.6 Moves, Copies, and Destruction

### 220.6.1 Move-Only for Types with Destructors

Types declaring destructors cannot be implicitly copied:

```ori
var a T
var b T = a   // compile-time error
```

### 220.6.2 Full Moves

Ownership transfers fully.  
The source becomes invalid and will not be destroyed.

### 220.6.3 Partial Moves (Struct Fields)

Fields moved out of a struct:
- are no longer destroyed by the original struct
- are destroyed when the new owner is destroyed

Remaining fields are destroyed normally.  
Compiler tracks which fields remain valid.

---

## 220.7 Panic Rules

### 220.7.1 Destructors Cannot Panic

Any potential panic inside the destructor body is a **compile-time error**:
- no explicit `panic`
- no operations that can panic
- no calls to functions that can panic

### 220.7.2 Runtime Implications

- Unwinding is simple and safe
- No double-panic scenarios
- Cleanup is reliable in all exit paths

---

## 220.8 Aggregates and Containment

### 220.8.1 Structs

If a struct has a destructor:
- It handles its own finalization
- Then its fields are destroyed automatically in reverse declaration order (unless moved out)

If it does not:
- Only fields with destructors are destroyed.

### 220.8.2 Arrays

Elements are destroyed from the last to the first.

### 220.8.3 Slices and Maps

Based on the v0.5 memory model:

- Containers that **own** elements are responsible for destroying them.
- Containers that only **reference** storage must not destroy elements.

---

## 220.9 Surface Syntax

### 220.9.1 Destructor Declaration

```ori
destructor TypeName {
    // implicit: value : TypeName
}
```

Example:

```ori
type struct File {
    fd int
}

destructor File {
    if value.fd >= 0 {
        close_fd(value.fd)
    }
}
```

### 220.9.2 Restrictions

Inside a destructor:
- `value` is implicitly provided and refers to the owned instance
- No parameters allowed
- No return values
- No `panic`
- No `defer` inside destructor
- Cannot call functions that may panic
- Cannot move `value` or reassign it

---

## 220.10 Examples

### 220.10.1 Valid Examples

#### Simple Resource Destructor

```ori
type struct File {
    fd int
}

destructor File {
    if value.fd >= 0 {
        close_fd(value.fd)
    }
}
```

#### Struct with Fields

```ori
type struct Connection {
    file File
    lock Mutex
}

destructor Connection {
    // connection-level cleanup
}
// then lock and file destructors run automatically
```

---

### 220.10.2 Forbidden Examples (Compile-Time Errors)

#### 220.10.2.1 Destructor that may panic

```ori
destructor Buffer {
    log(value.data[value.len])   // may panic → compile-time error
}
```

```ori
destructor Foo {
    panic("not allowed")         // ❌ compile-time error
}
```

```ori
func risky() {
    panic("x")
}

destructor Foo {
    risky()                      // ❌ compile-time error
}
```

#### 220.10.2.2 Destructor with parameters

```ori
destructor File(extra int) { }   // ❌ forbidden, compile-time error
```

#### 220.10.2.3 Destructor with return type

```ori
destructor File int { return 3 }   // ❌ forbidden, compile-time error
```

#### 220.10.2.4 `return` inside destructor

```ori
destructor File {
    return                        // ❌ forbidden, compile-time error
}
```

#### 220.10.2.5 Multiple destructors for the same type

```ori
destructor File { }
destructor File { }               // ❌ forbidden, compile-time error
```

#### 220.10.2.6 Destructor for primitive or alias

```ori
destructor int { }               // ❌ forbidden, compile-time error
```

```ori
type UserID = int
destructor UserID { }            // ❌ forbidden, compile-time error
```

#### 220.10.2.7 Manual call of destructor

```ori
var f File
f.destructor()                   // ❌ forbidden, compile-time error
```

#### 220.10.2.8 Moving out `value`

```ori
destructor Box {
    other = value                // ❌ full move forbidden, compile-time error
}
```

```ori
destructor Foo {
    y := move(value.x)           // ❌ partial move forbidden, compile-time error
}
```

#### 220.10.2.9 Assigning to `value`

```ori
destructor Foo {
    value = Foo{}                // ❌ forbidden, compile-time error
}
```

#### 220.10.2.10 `defer` inside destructor

```ori
destructor File {
    defer log("should not happen") // ❌ forbidden, compile-time error
}
```

#### 220.10.2.11 Blocking or spawning

```ori
destructor Socket {
    spawn_task(handle(value))     // ❌ forbidden, compile-time error
    spawn_thread(handle(value))   // ❌ forbidden, compile-time error
}
```

```ori
destructor Foo {
    for {}                 // ❌ forbidden, infinite block, compile-time error
}
```

#### 220.10.2.12 Destructor declared inside a block

```ori
func test() {
    destructor File { }           // ❌ forbidden, compile-time error
}
```

#### 220.10.2.13 Using moved-out fields

```ori
type struct S {
    x Resource
    y Resource
}

func test() {
    var s S
    take(s.x)                     // move-out
}

destructor S {
    close(value.x)                // ❌ forbidden, x was moved out compile-time error
}
```

#### 220.10.2.14 Recursive destruction

```ori
destructor Node {
    destroy(value)                // ❌ forbidden conceptual recursion, compile-time error
}
```

---

## 220.11 Compiler Responsibilities - Static Semantics

### 220.11.1 Type Eligibility and Registration

The compiler must:
- Ensure destructors only apply to nominal types.
- Reject destructors for primitives or primitive aliases.
- Enforce that only one destructor may be defined per type.
- Mark types with destructors as non-copyable.

---

## 220.12 Panic-Freedom Analysis

### 220.12.1 Direct Panic Sources

Explicit panics or constructs that inherently panic are rejected.

### 220.12.2 Calls to Potentially Panicking Functions

Destructors may only call panic-free functions. Any call to a function without a guaranteed no-panic status is rejected.

### 220.12.3 Control Flow

All branches must be verified panic-free.

---

## 220.13 Ownership and Move Tracking in Destructors

### 220.13.1 Value State Tracking

Compiler tracks the state of `value` and its fields:
- Valid
- Moved
- Invalid

### 220.13.2 Forbidden Moves

Any move of `value` or its fields is rejected.

### 220.13.3 Using Moved-Out Fields

Use of moved-out fields inside the destructor produces errors.

---

## 220.14 Scope Lowering and Code Generation Model

Compiler rewrites scopes into:
- user code
- `defer` stack
- deterministic destruction tail

---

## 220.15 Integration with Other Semantics Files

### 220.15.1 Types And Memory

Types with destructors become move-only.

### 220.15.2 Methods And Interfaces

Destructors are not part of method sets or interfaces.

### 220.15.3 Concurrency

Destructors must not spawn or block indefinitely.

---

## 220.16 Diagnostics

Compiler should emit precise messages for:
- panic paths
- illegal moves
- duplicate destructors
- invalid placements
- etc.

---

## 220.17 Non-Goals for current implementation

- Async-aware destructors
- Multi-phase destruction
- Destructor overloading
- Automatic or GC-like finalizers
- Dynamic destruction registration beyond `defer`

---

## 220.18 Automatic Destructor Synthesis

This section defines how Ori handles destructors for types where the user does **not** explicitly declare one, and how automatic field destruction behaves.

Deterministic destruction must remain:
- zero-cost when no cleanup is needed
- predictable when some fields require destruction
- safe when user-defined destructors exist

---

### 220.18.1 Types That Do Not Need a Destructor

No destructor (neither user-defined nor synthesized) is created when:

- the type has **no fields** whose types have destructors, and
- the type has **no special ownership semantics** requiring cleanup

Examples:
```ori
type struct Point {
    x float
    y float
}

type struct Id {
    value int
}
```

These types:
- remain trivially copyable (unless restricted by other rules),
- incur **zero** destruction overhead.

---

### 220.18.2 Types That Require Automatic Field Destruction

If a type has **no user-declared destructor** but contains fields whose types have destructors, the compiler **synthesizes** field destruction.

Example:
```ori
type struct Session {
    conn Connection  // Connection has a destructor
    token string
}
```

The compiler behaves conceptually as if it had generated:
```ori
destructor Session {
    // no Session-specific logic
    // destroy fields in reverse declaration order
    destroy(value.conn)
}
```

Notes:
- `Session` becomes move-only, because it contains a field (`Connection`) that has a destructor
- Field destruction order is always last-declared → first-declared

---

### 220.18.3 Example – Nested Structs

```ori
type struct Cache {
    buf Buffer    // Buffer has destructor
}

type struct State {
    cache Cache   // Cache requires destruction
    id    Id      // Id has no destructor
}
```

Here:
- `Cache` gets synthesized field destruction for `buf`
- `State` gets synthesized field destruction for `cache` only

Conceptual expansion:

```ori
destructor Cache {
    destroy(value.buf)
}

destructor State {
    destroy(value.cache)
}
```

No destructor is ever needed for `Id`.

---

### 220.18.4 User-Defined Destructor + Automatic Field Destruction

When the user declares a destructor for a type `T`, the compiler:
1. Runs the user-defined destructor body.
2. Then automatically destroys any remaining fields of `T` that:
   - are still valid
   - and whose types have destructors

Example:

```ori
type struct Resource {
    data view[byte]
    alloc Allocator
}

destructor Resource {
    if value.data != nil {
        value.alloc.free(value.data)
    }
    // alloc is not destroyed here
}
```

If `Allocator` has a destructor, the compiler behaves like:

```ori
destructor Resource {
    if value.data != nil {
        value.alloc.free(value.data)
    }
    // automatic field destruction (reverse declaration order):
    destroy(value.alloc)
}
```

Rules:
- User code handles type-specific logic
- The compiler still guarantees field cleanup, without double-destroying moved-out fields

---

### 220.18.5 Example – Partial Moves and Synthesis

```ori
type struct Pair {
    left  File
    right File
}

func useRight(p Pair) {
    take(p.right)   // move-out `right`
    // `left` is still valid here
}
```

Destruction behavior:
- The compiler tracks that `right` was moved out
- The synthesized destructor for `Pair` only destroys `left`

Conceptually:

```ori
destructor Pair {
    // destruction of fields in reverse order,
    // but skipping fields marked as moved-out:
    if field_is_valid(value.right) {
        destroy(value.right)      // skipped in this example
    }
    if field_is_valid(value.left) {
        destroy(value.left)       // runs
    }
}
```

Any attempt in a **user-defined** destructor to explicitly destroy `value.right` after it was moved out remains a **compile-time error**.

---

### 220.18.6 Example – Sum Types

Consider the sum type below:
```ori
type Shape =
    | Circle(radius float)
    | Rect(w float, h float)
    | Image(buf Buffer)
```

If `Shape` has no explicit destructor:
- The compiler synthesizes destruction that depends on the active variant.
- Only the active variant’s payload is destroyed.

Conceptually:
```ori
destructor Shape {
    switch value {
    case Circle:
        // nothing to destroy
    case Rect:
        // nothing to destroy
    case Image:
        destroy(value.buf)
    }
}
```

Key points:
- Only the **current variant** participates in destruction
- There is **no implicit recursion**; only variant payloads are destroyed
- If `Buffer` changes its destructor behavior, `Shape` automatically follows

---

### 220.18.7 Zero-Cost Guarantee

Ori guarantees:

> If a type and all of its fields have no destructors, the compiler does not generate any destruction code or metadata for that type.

This applies even for deep nesting:

```ori
type struct A { x int }
type struct B { a A }
type struct C { b B }
```

None of `A`, `B`, `C` get destructors or destruction tails.

---

### 220.18.8 Diagnostics for Synthesis Edge Cases

The compiler should emit clear diagnostics if automatic destruction becomes ambiguous or unsafe, for example:
- When combining user-defined destructors with complex partial moves.
- When synthesized destruction would attempt to destroy an already moved-out field (which should be rejected earlier by move tracking).
- When types are arranged in patterns that could look recursive but are actually just pointer graphs (no automatic traversal).

All such errors should point to:
- the type that triggered synthesis,
- the field that required destruction,
- and the user-defined destructor (if any) involved in the conflict.

---

### 220.18.8.1 Error: Synthesized destructor must destroy a field that was moved out

```ori
type struct Pair {
    left  File
    right File
}

func consume(p Pair) {
    take(p.right)  // move-out
} // destructor synthesis required for Pair
```

**Compiler error**

```
error: cannot synthesize destructor for 'Pair':
       field 'right' was moved out and cannot be destroyed.
help: consider writing a custom destructor for 'Pair'
```

---

### 220.18.8.2 Error: User-defined destructor conflicts with synthesized field destruction

```ori
type struct Holder {
    buf Buffer
}

destructor Holder {
    destroy(value.buf)   // user destroys this
}
```

**Compiler error**

```
error: destructor for 'Holder' manually destroys field 'buf',
       but this field also participates in automatic destruction.
help: do not manually destroy fields; only write type-level cleanup.
```

---

### 220.18.8.3 Error: User-defined destructor attempts to destroy a moved-out field

```ori
type struct Frame {
    tmp TempBuf
    img Image
}

func decode(f Frame) {
    take(f.tmp) // move-out
}

destructor Frame {
    destroy(value.tmp)   // ❌ illegal
}
```

**Compiler error**

```
error: field 'tmp' has been moved out and cannot be destroyed
note: this prevents synthesizing a correct destructor for 'Frame'
help: remove manual field destruction; rely on automatic destruction
```

---

### 220.18.8.4 Error: Recursive type requiring synthesis but containing owned fields

```ori
type struct Node {
    next Node     // ❌ illegal: recursive value containment
    data Buffer
}
```

**Compiler error**

```
error: cannot synthesize destructor for recursive type 'Node'
       value-type recursion is not allowed when the type owns fields
help: use a pointer to 'Node' instead
```

---

### 220.18.8.5 Error: Ambiguous ownership in generic types

```ori
type struct Box[T] {
    item T
}

func process[T](x Box[T]) {
    take(x.item)    // move-out inside generic function
}
```

**Compiler error**

```
error: destructor synthesis for 'Box[T]' is ambiguous:
       field 'item' was moved out but T may or may not own resources
help: require 'T' to be move-only or panic-free via a generic constraint
```

---

### 220.18.8.6 Example – Using Generic Constraints

```ori
type interface Disposable { }

type struct Box[T Disposable] {
    item T
}
```

---

### 220.18.8.7 Error: Interface object cannot infer destructor requirements

```ori
type interface Writer {
    write(view[byte]) int
}

type struct FileWriter {
    file File
}

var w Writer = FileWriter{ ... }
```

**Compiler error**

```
error: cannot destroy value of interface type 'Writer'
       dynamic destructor dispatch is not supported
help: store concrete types, or wrap the resource in an owning struct
```

---

### 220.18.8.8 Error: Synthesized destructor would require dynamic dispatch

```ori
type interface Closeable { }

type struct Handle[T Closeable] {
    obj T
}

func use(h Handle[Writer]) { }  // Writer is an interface
```

**Compiler error**

```
error: cannot synthesize destructor for 'Handle[Writer]':
       'Writer' is an interface and may have multiple implementations
help: use a concrete type argument instead of an interface
```

---

### 220.18.8.9 Error: Sum type variant requires custom destructor

```ori
type Boxed =
    | One(buf Buffer)
    | Two(ptr *byte)

func leak(b Boxed) {
    switch b {
    case One:
        take(b.buf)   // move-out
    }
}
```

**Compiler error**

```
error: variant 'One' of sum type 'Boxed' contains field 'buf'
       which may be moved out, preventing safe destruction synthesis
help: write an explicit destructor for 'Boxed'
```

---

## 220.19 Move Semantics and Destructor Interactions

This phase defines how deterministic destruction interacts with moves, returns, assignments, swaps, temporaries, generics, and pattern matching.
The goal is complete predictability with no hidden copies or accidental double‑destruction.

---

### 220.19.1 Reassignment of Variables Holding Destructible Types

If a type `T` has a destructor, then `T` is **move‑only**.

```ori
var a T
var b T

a = b       // ❌ forbidden: implicit copy
a = move(b) // allowed: ownership moves
```

Semantics of reassignment:
1. Destroy previous value of `a`
2. Move ownership from `b` into `a`
3. Mark `b` as invalid

---

### 220.19.2 Returning Values with Destructors

Returning a destructible value transfers ownership to the caller.

```ori
func make_file() File {
    var f File
    return f   // move f to caller
}
```

The destructor for `f` runs **only** in the caller, not inside `make_file`.

Returning parameters is also a move:
```ori
func forward(f File) File {
    return f   // moves f out, f becomes invalid
}
```

Each return path must either:
- move the value out, or
- destroy it

but never both.

---

### 220.19.3 Swaps

Swapping two values of destructible types must occur via moves.

Conceptual semantics:

```ori
swap(a, b)
```

is lowered to:

1. tmp = move(a)
2. a = move(b)
3. b = move(tmp)

No destruction occurs during the swap itself.

---

### 220.19.4 Temporaries and Expression Lifetimes

Temporaries created by expressions have well‑defined lifetimes.

Example:
```ori
use(make_file())
```

Semantics:
1. `make_file()` creates a temporary `File`
2. It is moved into the parameter of `use`
3. No destructor runs for the temporary
4. Destructor runs when the parameter’s lifetime ends

If a temporary is not moved into anything:

```ori
func f() {
    do_something(make_file())  
    // temporary destroyed at end of expression
}
```

---

### 220.19.5 Pattern Matching and Move Semantics in Sum Types

```ori
type Shape =
    | Circle(r float)
    | Image(buf Buffer)

func consume(s Shape) {
    switch s {
    case Image:
        take(s.buf) // move-out
    }
}
```

At destruction:
- `buf` must only be destroyed if still valid  
- Attempting to destroy moved-out variant payload is a compiler error  
- If the compiler cannot confirm validity, it rejects synthesis and requires an explicit destructor

---

### 220.19.6 Generics and Destructor-Aware Constraints

Example: types that *always* require destruction:

```ori
type interface Disposable { }

type struct Box[T Disposable] {
    item T
}
```

Synthesized:
```ori
destructor Box[T Disposable] {
    destroy(value.item)
}
```

Types that *never* require destruction:

```ori
type interface Copyable { }

type struct PodBox[T Copyable] {
    item T
}
```

Generic functions:

```ori
func forward[T](x T) T {
    return x   // move if T is move-only, copy if T is trivial
}
```

Compiler tracks move-only status through constraints.

---

### 220.19.7 Destructor Elision & Optimizations

Elision is allowed only if semantics remain unchanged:

- RVO (construct into caller's storage)
- Skip destroying dead temporaries
- Skip intermediate destructors if proven unnecessary

But:

> Every owning value must still be destroyed exactly once in the final observable execution.

No optimization may skip or duplicate destruction.

---

## 220.20 ABI, Lowering & Runtime Model

This phase defines how destructors integrate with the ABI, code generation, cross-module boundaries,
panic-unwind behavior, optimization, and debugging. This completes the formal model.

---

### 220.20.1 ABI Representation of Destructors

Ori uses **compile‑time only** destructor knowledge. No runtime metadata or RTTI is stored in objects.

RTTI (Run-Time Type Information) is runtime metadata that allows a program to inspect or identify types during execution. Ori does not use RTTI; all type and destructor information is known at compile time, ensuring zero-overhead and deterministic behavior.

#### 220.20.1.1 No RTTI (Run-Time Type Information) or dynamic dispatch

- No vtables
- No type tags
- No runtime destructor pointers

Each nominal type with a destructor emits exactly one function:

```
__ori_destruct_TypeName(TypeName* value)
```

Example:
```
__ori_destruct_File(File* value)
```

#### 220.20.1.2 ABI Stability

If a module exports a type with a destructor:
- That destructor symbol forms part of the module's stable ABI.
- It must not change calling convention or signature across patch versions.

---

### 220.20.2 Lowering Rules (Compiler Rewriting)

The Ori compiler rewrites each lexical scope into:
1. **User code**
2. **Defer stack**
3. **Deterministic destruction tail**

Lowering example:

```ori
func f() {
    var x A
    defer log("x")
    var y B
}
```

Lowered:

```
f():
    alloc x
    register_defer(scope0, log("x"))
    alloc y

scope0_exit:
    run_defer(scope0)   # log("x")
    destroy y
    destroy x
    return
```

---

### 220.20.3 Lowering of Early Exits

#### 220.20.3.1 Return

```ori
return expr
```

Lowered into:

```
move expr → return_slot
jump scope0_exit_after_return
```

#### 220.20.3.2 Break / Continue

```
jump scope_exit
jump loop_target
```

Cleaning up every intermediate scope is mandatory.

---

### 220.20.4 Panic Unwinding ABI Behavior

Panic unwinding proceeds deterministically:

```
unwind_frame:
    run defer stack (reverse order)
    run destructors   (reverse order)
    continue unwinding
```

#### Guarantees:
- Destructors cannot panic (compile‑time enforced)
- No double-unwind hazards
- Every owned value is destroyed once

Example:

```ori
func f() {
    var a A
    defer log("A")
    var b B
    panic("fail")
}
```

Unwind order:
```
log("A")
destroy b
destroy a
```

---

### 220.20.5 Cross‑Module Behavior

If module A uses a destructible type from module B:

Module A lowers destruction into:

```
call __ori_destruct_TypeFromB(&local_value)
```

No dynamic dispatch or RTTI is needed.

ABI rule:
> Cross‑module destructor calls must always resolve to the original module’s destructor.

---

### 220.20.6 Calling Conventions

Destructor signature:

```
void __ori_destruct_T(*T value)
```

Properties:
- `nounwind`
- internal linkage unless exported
- may be inlined
- must not allocate or panic

Example emitted header:
```
define internal fastcc void @__ori_destruct_File(%File* %value) nounwind {
    ...
}
```

---

### 220.20.7 Optimization Model

#### 220.20.7.1 Allowed Optimizations

- Return Value Optimization (RVO)/No Return Value Optimization NRVO
- Inlining destructors
- Eliding destruction of dead temporaries
- Skipping destructor calls for values proven unreachable

Example (dead temporary):

```ori
func test() {
    make_file("tmp.txt")   // destructor runs for temporary
}
```

Lowered:

```
call __ori_destruct_File(&tmp)
```

The compiler may inline and eliminate this if `tmp` is proven unused.

#### 220.20.7.2 Forbidden Optimizations

The compiler must NOT:
- reorder defers relative to destructors
- reorder destructors across scopes
- omit destructor calls for owned values  
- duplicate destruction

---

### 220.20.8 Debugging & Tooling Behavior

#### 220.20.8.1 Destructor Symbol Visibility
If not inlined, destructors appear in stack traces:

```
__ori_destruct_File
__ori_destruct_Connection
```

#### 220.20.8.2 Debug Stepping
Debuggers:
- Step *into* destructors like normal functions
- Step field-by-field if inlined
- Skip entirely if optimized away

#### 220.20.8.3 Panic Stack Traces

```
panic: failure
  at foo.ori:23
  at __ori_destruct_Buffer
  at __ori_destruct_Session
```

---

### 220.20.9 Lifetime Boundaries & ABI Guarantees

Ori guarantees:
- Each owning value destroyed exactly **once**
- Full-expression boundaries are destruction insertion points
- No implicit copies for move-only types
- Destructor ordering is stable
- ABI for destructors is stable across modules

---

### 220.20.10 Examples

#### 220.20.10.1 Cross‑module destruction

Module B:

```ori
type struct File { fd int }
destructor File {
    if value.fd >= 0 { close_fd(value.fd) }
}
```

Module A:

```ori
func run() {
    var f File
}
```

Lowered:

```
call __ori_destruct_File(&f)
```

---

#### 220.20.10.2 Panic unwind across modules

Module A:

```ori
func run() {
    var a A
    callB()
}
```

Module B:

```ori
func callB() {
    var b B
    panic("x")
}
```

Unwind order:
```
destroy b
destroy a
```

---

#### 220.20.10.3 Return Value Optimization (RVO) eliminating destructor in callee

```ori
func make_file() File {
    return File{fd: open(...)}
}
```

Lowering:
- Construct directly in caller’s return slot
- No destructor runs inside `make_file`

Destructor runs only when the caller's value goes out of scope.

---

## 220.21 Summary

Ori’s deterministic destruction model combines:
- opt-in destructors
- strong ownership rules
- panic-free cleanup
- predictable ordering with `defer`
- predictable behavior under panic
- compiler-enforced correctness
- safe and explicit resource lifecycle semantics
- automatic, field-based destructor synthesis
- safe and explicit resource lifecycle semantics with zero-cost for trivial types

---


# 230 Interfaces.md

## 230.1 Interfaces – Overview

Interfaces describe **behavior** via required method signatures.  
Implementation is always **explicit** using:

```
Type implements Interface
```

Ori supports:

- **Static dispatch** (via generic constraints)
- **Dynamic dispatch** (via interface-typed values)

Interface values are represented as **(data pointer + vtable pointer)**.  
They **do not own** the underlying object; they are non‑owning views.

---

## 230.2 Interface Declarations

### 230.2.1 Syntax

```
type interface Greeter {
    greet() string
    identify() string
}
```

**Constraints:**
- Only **method signatures** allowed inside an `interface` block.
- Fields are forbidden.
- Default method bodies are forbidden (e.g., `Write(...) int { ... }`).
- Method signatures follow normal function/method rules.

### 230.2.2 Method signature matching

For each method `M` in interface `I`:

- Name must be unique within `I`
- Full signature must match:
  - name
  - parameter list types
  - result list types

The implementing type must provide a matching method (receiver rules defined in `170_MethodsAndInterfaces.md`).

---

## 230.3 Method Sets and Interface Requirements

Ori reuses **method sets** from `170_MethodsAndInterfaces.md`.  
A type `T` implements interface `I` **if**:
- The method set of `T` contains a matching method for every method in `I`.

**Compiler rule:**

> To check `T implements I`:
> - build the method set of `T`
> - ensure that every `I.M` exists in `T` with a matching signature

If any method is missing or mismatched, compilation fails at the `implements` declaration.

---

## 230.4 Explicit Implementation Declarations

### 230.4.1 Basic form

```
type interface Writer {
    Write(p []byte) int
}

type struct File {
    Path string
}

File implements Writer
```

**Semantics:**
- Implementation is **explicit**
- Declaration must appear at file scope.
- At most **one** `Type implements Interface` per pair.

### 230.4.2 Multiple interfaces

```
File implements Reader
File implements Writer
```

- Each clause is checked independently.
- If two interfaces require the **same method name** with **different signatures**, compilation fails.

### 230.4.3 Allowed types

Any **named type** with a method set may implement an interface:
```
MyStruct implements SomeInterface
MySum    implements AnotherInterface
```

Pointer, alias, and sum‑type method‑set rules come from `170_MethodsAndInterfaces.md`.

---

## 230.5 Interface Composition

### 230.5.1 Syntax

```
type interface Reader {
    Read(p []byte) int
}

type interface Writer {
    Write(p []byte) int
}

type interface ReadWriter {
    Reader
    Writer
}
```

The method set of `ReadWriter` is the **union** of `Reader` and `Writer`.

Composition is **shallow**; no new semantics added; conflicts cause compile-time errors.

### 230.5.2 Conflict handling

```
type interface A {
    process(x int) int
}

type interface B {
    process(x string) int
}

type interface C {
    A
    B
}
```

`C` is **invalid** because:
- `process` resolves to **two incompatible signatures**

Conflict errors occur at **interface declaration time** and causes compile-time errors.

### 230.5.3 No inheritance

- No `extends` keyword
- No interface hierarchies
- Only composition

---

## 230.6 Interface Values and Representation

Values of interface type `I` are **interface values**.

### 230.6.1 Representation

At runtime, an interface value contains:
```
data_ptr   : pointer to concrete value
vtable_ptr : pointer to vtable for (ConcreteType implements I)
```

- `data_ptr` points to the underlying object (not owned)
- `vtable_ptr` points to a static function‑pointer table

Binary layout is implementation‑defined but stable.

### 230.6.2 Zero value and `nil`

The zero value of an interface:
```
data_ptr   = null
vtable_ptr = null
```

Behavior:
- Calling a method on a zero interface value is a compile-time error when detectable,otherwise a runtime safety error
- Zero interface equals zero interface

### 230.6.3 Assignment to interfaces

```
var f File
var w Writer = f
```

Compiler checks that `File implements Writer`.  
Runtime sets:
- `w.data_ptr = &f`
- `w.vtable_ptr = &VTable(File implements Writer)`

No hidden heap allocation.  
The interface value never relocates the underlying object.
It merely stores a pointer to existing storage.

---

## 230.7 Method Calls and Dispatch

### 230.7.1 Static dispatch (concrete type)

```
var f File
f.Write(p)
```

- `File` is statically known
- Compiler resolves call statically and may inline

### 230.7.2 Dynamic dispatch (interface type)

```
func Save(w Writer) {
    w.Write(p)
}
```

Runtime:
- Uses `w.vtable_ptr` to get function pointer
- Passes `w.data_ptr` as receiver
- Applies receiver-adjustment rules from `170`

### 230.7.3 Mutability

Mutability of method calls is determined exclusively by the receiver modifier defined in `170_MethodsAndInterfaces.md`.
Raw pointer receivers (*T) are not allowed in Ori (see §310.5.5).

Allowed receiver forms:
- **Value receiver** — operates on a copy:
  ```ori
  func (self File) Describe() string {
    return self.Path
  }
  ```
- **Shared receiver** — operates on the original instance (mutable):
  ```ori
  func (self shared File) Write(p []byte) int {
    // allowed: modifies the underlying File
    self.buffer.append(p)
    return p.len()
  }
  ```
- **Const receiver** — read-only view of the original:
  ```ori
  func (self const File) Size() int {
    return self.buffer.len()
  }
  ```
- **Forbidden**:
  ```ori
  func (self *File) Write(p []byte) int   // ❌ forbidden
  ```

Interface dispatch (static or dynamic) passes the receiver exactly as declared:
- shared → mutable reference
- const  → read-only reference
- value  → copy

Pointer semantics (*T) never participate in method dispatch.

---

## 230.8 Generics and Interface Constraints

### 230.8.1 Declaring constraints

```
T implements Writer
func Save[T](x T) {
    x.Write(...)
}
```

Inside `Save`, calls are **statically dispatched**:
- No interface indirection
- No vtable
- Function is monomorphized for each `T`

### 230.8.2 Multiple constraints

```
T implements Reader
T implements Writer

func Copy[T](r T, w T) {
    var buf []byte
    r.Read(buf)
    w.Write(buf)
}
```

Constraint conflicts produce compile-time errors.

### 230.8.3 Static type‑check conditions

```
if T implements Writer {
    // comptime branch
}
```

- Evaluated at compile‑time
- Selects specialized code paths in `comptime` contexts

---

## 230.9 Explicit Implementation Checking & Errors

### 230.9.1 When checking occurs

`Type implements Interface` is validated when:
- Both sides are known
- Forward declarations resolved once complete

### 230.9.2 Error examples

#### 1. Missing method

```
type interface Writer {
    Write(p []byte) int
}

type struct File {}

File implements Writer
// ERROR: File lacks Write(p []byte) int
```

#### 2. Signature mismatch

```
type interface Writer {
    Write(p []byte) int
}

func (self shared File) Write(p []byte) string { ... }

File implements Writer
// ERROR: result type string ≠ int
```

#### 3. Composition conflict

(see 230.5.2)

#### 4. Duplicate implementation

```
File implements Writer
File implements Writer
// ERROR: duplicate implementation
```

---

## 230.10 Interactions with Other Features

### 230.10.1 Sum Types

Sum types may implement interfaces if they define methods:

```
type Shape =
    | Circle(radius float64)
    | Rect(w float64, h float64)

func (s Shape) Area() float64 { ... }

Shape implements HasArea
```

### 230.10.2 Deterministic Destruction

From `220_DeterministicDestruction.md`:
- Interface values **do not own** the referenced object
- They must not outlive the object's storage
- Moving or destroying the underlying object while interface values still exist is a compile-time error when detectable, otherwise a runtime safety error

### 230.10.3 Containers

Containers (slices, maps, etc.) may store interface values:
- Each entry stores its own pair `(data_ptr, vtable_ptr)`

Containers of concrete types behave normally; interface usage remains explicit.

---

## 230.11 Summary

- Interfaces define behavior.
- Implementation is always explicit with `Type implements Interface`.
- Interface values are `(data pointer + vtable pointer)`; non‑owning.
- Static dispatch via generics; dynamic dispatch via interface‑typed values.
- Composition is allowed; no inheritance keyword.
- Mutability follows receiver rules from `170_MethodsAndInterfaces.md`.

---


# 240. PatternMatching

# Pattern Matching in Ori

## 240.1. Overview

Ori integrates pattern matching into the existing `switch` statement.  
Pattern matching applies only to **sum types**, while **value-based** and **condition-based** switches retain their own semantics.

Pattern matching is:
- explicit
- safe
- non-fallthrough
- exhaustive
- free of guards or wildcard patterns

---

## 240.2. Structural Switch (Sum Types)

A `switch` is in *structural mode* when the switched expression is a **sum type**.

### 240.2.1 Syntax
```
switch value {
    case Variant(a):
        ...
    case OtherVariant(x, y):
        ...
}
```

---

### 240.2.2 Exhaustiveness

All `sum-type` variants must be explicitly listed.

```
switch s {
    case Circle(r):
    case Rect(w, h):
}
```

If any variant is missing:
```
switch s {
    case Circle(r):
}
```

**Compile-time Error:** non-exhaustive switch on `Shape`. Missing: `Rect`.

### 240.2.3 Forbidden `default` and fallback cases

`default:` and wildcard-style branches are *not allowed* in structural switches and will produce compile-time errors.

---

### 240.2.4 No fallthrough

Sum-type switches forbid `fallthrough` entirely:
```
switch s {
    case Circle(r):
        fallthrough // ERROR
}
```

---

### 240.2.5 Strict variant validation

- Wrong variant name → error with suggestion
  ```
  switch s {
    case Circl(r): // ERROR: did you mean Circle?
  }
  ```
- Wrong arity → error
  ```
  switch s {
    case Rect(w): // ERROR expected 2 fields
  }
  ```
- Duplicate variant → error
  ```
  case Circle(a):
  case Circle(b): // ERROR duplicate
  ```

---

## 240.3. Destructuring Semantics & Payload Lifetime

### 240.3.1 Local bindings

Destructuring binds **new local variables**:
```
switch s {
  case Circle(r):
    print(r) // r is a new local
}
```

---

### 240.3.2 Copy or move

Bindings receive:
- a copy if the payload type is copyable
- a move if the payload is move-only:
  ```
  case FileHandle(fh):
    use(fh) // fh moved if handle is move-only
  ```

---

### 240.3.3 All fields must be named

Ori forbids:
- wildcards
- underscores
- omitted fields
- partial destructuring

Correct:
```
case Rect(w, h):
```

Incorrect:
```
case Rect(w, _):     // forbidden
case Rect(w):        // wrong arity
```

More Examples:
```
case Rect(width, height):
case Pair(a, b):
```

Invalid:
```
case Rect(w, _): // forbidden
case Pair(a):   // wrong arity
```

### 240.3.4 No nested destructuring

```
case Wrapper(Rect(w, h)): // forbidden
```

### 240.3.5 Original variant not mutated

Switching does not mutate the original sum-type value.  
Moved payloads follow the standard move rules.

```
var s = Circle(5)
switch s {
  case Circle(r):
    r = 10 // modifies local copy, not s
}
```

---

### 240.3.6 Unit Variants (Payload‑Less)

Variants with no payload use the syntax:
```
case Nothing:
```

Using parentheses is forbidden:
```
case Nothing(): // ERROR — payload‑less variants do not take parentheses
```

---

### 240.3.7 Static Dispatch Clarification

Pattern matching on sum types always uses **static dispatch**.
It never performs:
- dynamic dispatch
- virtual calls
- interface‑based dynamic dispatch

The matched variant is known at compile‑time, and the compiler emits a deterministic branch sequence.

---

## 240.4. Value-Mode Switch (Primitives)

Allowed for: integers, strings, bool, floats.

### 240.4.1 Case labels must be compile-time constants

Example:
```
switch x {
    case 1:
    case A: // A is const
}
```

---

### 240.4.2 `default:` allowed

Example:
```
switch code {
    case 200:
    default:
}
```

---

### 240.4.3 `fallthrough` allowed

Example:
```
case 1:
    fallthrough
case 2:
```

---

### 240.4.4 Non-exhaustive switches allowed

Example:
```
switch flag {
    case true:
}
```

---

### 240.4.5 Duplicate constants → error

Example:
```
case 1:
case 1: // error
```

---

### 240.4.6 Grouped case labels allowed

Example:
```
case 'a', 'e', 'i':
```
---


### 240.4.7 Expression evaluated once

Example:
```
switch x {
    case 1:
        ...
    case 2:
        fallthrough
    case 3:
        ...
    default:
        ...
}
```

---

## 240.5. Condition-Mode Switch (Expression-Less Boolean Switch)

Allowed form:
```
switch {
    case x() == 1:
    case y > 10:
    default:
}
```

Rules:
- Each `case` must be a boolean expression
- No destructuring
- No fallthrough
- `default:` allowed (acts like `else`)
- `case 1:` is forbidden here (1 is not boolean)

Forbidden:
```
switch {
    case 1:     // not boolean → error
}
```

---

## 240.6. Diagnostics & Error Messages

### 240.6.1 Non-exhaustive structural switch

**Error:** non-exhaustive switch on `T`. Missing: A, B, C.

Non-exhaustive:
```
switch s {
    case D:
}
// ERROR: missing A, B, C
```

---

### 240.6.2 Forbidden features in structural mode

- `default`:
  ```
  case Rect(w, h):
  default:            // ❌ forbidden, compile-time error
  ```
- `fallthrough`
- wildcard patterns:
  ```
  case Rect(w, _):    // ❌ forbidden, compile-time error
  ```
- nested patterns:
  ```
  case Wrapper(Rect(w, h)):  // ❌ nested destructuring is forbidden, compile-time error
  ```
- guard expressions:
  ```
  case Circle(r) if r > 0:  // ❌ no guard syntax is forbidden, compile-time error
  ```

---

### 240.6.3 Wrong variant or arity

- Unknown variant → suggestion provided
- Wrong number of fields → exact arity listed
- Duplicate variant → error

---

### 240.6.4 Value-mode violations

- duplicate constants
  ```
  case "ok":
  case "ok": // ERROR duplicate
  ```
- non-constant case labels
- type not switchable

---

### 240.6.5 Condition-mode violations

- case not boolean:
  ```
  switch {
    case 5: // ERROR not boolean
  }
  ```
- attempting destructuring
- forbidden literal match

---

### 240.6.6 Error for Switching on Non-Sum Type in Structural Mode

```
switch 1 {
    case Circle(r):   // ERROR: structural pattern on a non-sum-type
}

var s string = "hello"
switch s {
    case Circle(r):   // ERROR
}
```

---

## 240.7. Summary

Structural switch:
- must be exhaustive
- no default
- no fallthrough
- exact destructuring only
- explicit variant names
- strict arity

Value-mode switch:
- constants only
- default allowed
- fallthrough allowed
- non-exhaustive ok

Condition-mode switch:
- boolean expressions
- default allowed
- no fallthrough
- no destructuring

---


# 250. Compile-Time Execution (CTE)

## 250.1 Overview

Compile-Time Execution (CTE) allows certain user-defined constants and functions to be evaluated
during compilation using the `comptime` keyword.

Ori does not implicitly run any user code at compile time.
All compile-time evaluation is explicit, predictable, and safe.

CTE supports:
- compile-time constants
- compile-time-only functions
- generic parameters that must be compile-time values
- compile-time constraints
- compile-time errors

Ori intentionally excludes:
- implicit compile-time evaluation
- implicit purity detection
- automatic folding of arbitrary user functions

---

## 250.2 Allowed CTE Forms

Ori supports exactly two syntactic uses of `comptime`:

### 250.2.1 Compile-time constant declaration

```ori
comptime const NAME = expr
```

Examples:
```ori
comptime const FIB10 = fib(10)
comptime const SIZE = 32 + 8
```

`expr` must be fully CTE-safe.

### 250.2.2 Compile-time-only function declaration

```ori
comptime func fib(n int) int {
    ...
}
```

A `comptime func`:
- is executed only during compilation
- must be pure
- must terminate
- cannot depend on runtime inputs
- cannot be called from runtime code
- can only call other `comptime func` functions

---

## 250.3 Forbidden Forms of CTE

Ori forbids all expressions or modifiers outside the two approved forms.

Invalid:
```ori
const X = comptime expr
var X = comptime expr
comptime expr
comptime { ... }
func f[T](comptime N int)  // forbidden any expression-level usage of comptime
```

This prevents comptime from leaking into general expressions and keeps the grammar simple.

---

## 250.4 Compile-Time Errors

Compile-time functions may issue errors using:
```ori
comptime_error("message")
```
Example:
```ori
comptime func ensurePositive(n int) {
    if n <= 0 {
        comptime_error("expected positive value")
    }
}
```

If invoked during CTE, this aborts compilation.

---

## 250.5 Allowed Operations in CTE

### 250.5.1 Allowed

- arithmetic
- comparisons
- pure branching (if, for) using only compile-time values
- calling other comptime functions
- local variable declarations
- creating local fixed-size arrays
- compile-time constant folding
- evaluating generic compile-time constraints

---

### 250.5.2 Forbidden Operations

CTE must not depend on runtime or non-deterministic behavior.

Forbidden:
- I/O of any kind
- OS APIs
- randomness, timestamps
- concurrency (tasks, threads, Wait)
- heap allocation or deallocation
- pointers or references
- views and slices
- maps and hashmaps
- accessing or modifying runtime globals
- calling non-CTE functions

---

## 250.6 Generic Functions and Compile-Time Parameters

Ori allows compile-time generic parameters using `const`:
```ori
func makeArray[T](const N int) [N]T {
    var arr [N]T
    return arr
}
```

Rules:
- N must be known at compile time.
- Passing a non-CTE value to N is a compile-time error.
- N behaves as a normal int inside the function but is treated as a constant type parameter.

---

## 250.7 Compile-Time Constraints With Generics

A compile-time function may validate generic parameters:
```ori
comptime func ensureEven(n int) {
    if n % 2 != 0 {
        comptime_error("expected an even size")
    }
}

comptime const VALID = ensureEven(4)
```
Or inside a function with a constant parameter:
```ori
func bufferOf[T](const N int) [N]T {
    comptime ensureEven(N)
    return [N]T{}
}
```

---

## 250.8 Examples

### 250.8.1 Compile-Time Fibonacci

```ori
comptime func fib(n int) int {
    if n < 2 { return n }

    var a = 0
    var b = 1

    for i = 2; i < n; i = i + 1 {
        var tmp = a + b
        a = b
        b = tmp
    }
    return b
}

comptime const RESULT = fib(10)
```

---

### 250.8.2 Compile-Time Array Size Validation

```ori
comptime func checkLimit(n int) {
    if n > 1024 {
        comptime_error("size too large")
    }
}

func allocChunk[T](const N int) [N]T {
    comptime checkLimit(N)
    return [N]T{}
}
```

---

## 250.9 Summary

Ori’s CTE system:
- uses only two comptime forms (constant + function)
- forbids expression-level comptime
- makes generic constant parameters explicit via `const`
- is pure, deterministic, and easy to reason about

---


# 260. Container Ownership Model

Ori’s container types (`string`, `slice`, `map`, `hashmap`) are heap‑backed, reference‑semantics values with **explicit, deterministic ownership** and **predictable aliasing rules**.  
This document refines the general model from `150_TypesAndMemory.md` and the behavioral map semantics from `110_Maps.md` by specifying how containers own memory, how aliases behave, and how lifetimes are enforced.

This file **does not** redefine surface syntax or APIs already covered elsewhere; it focuses on **ownership, aliasing, and lifetime semantics**.

---

## 260.1 Overview

Container ownership in Ori follows these principles:
- **No garbage collector** — all heap memory is freed deterministically when its last owner is destroyed.
- **Handle + backing storage model** — a container value is a *handle* to heap‑allocated backing storage (buffer, table, nodes…).
- **Reference semantics by default** — assigning or passing a container copies the handle; backing storage is shared until explicitly cloned or moved.
- **Views are non‑owning** — `view` qualifiers never own container storage and must not outlive their source.
- **Explicit structural operations** — growth, reallocation, and rehashing are explicit consequences of operations like `append`, `insert`, `delete`, and `clear`.
- **No hidden non‑determinism** — map iteration order is defined; hashmap iteration order is intentionally unspecified but stable within a single iteration snapshot.
- **Safety-first aliasing** — operations that would invalidate live views are rejected at compile time whenever statically detectable.

This document assumes the type categories and qualifiers defined in `150_TypesAndMemory.md`.

---

## 260.2 Container Categories

Ori exposes two broad container families:

- **String‑like**: `string`
- **Sequence‑like**: `slice[T]`
- **Dictionary‑like**:
  - `map[K]V` — **ordered**, deterministic insertion order semantics
  - `hashmap[K]V` — **unordered**, hash‑based lookup, iteration order not part of the API contract

All four are:
- heap‑backed
- reference‑semantics values (handle + backing storage)
- subject to deterministic destruction (see `220_DeterministicDestruction.md`)

---

## 260.3 General Ownership Rules

### 260.3.1 Handles and Backing Storage

A container value `C` conceptually consists of:

- a small, fixed‑size *handle* stored inline (e.g., pointers, length/capacity or table metadata)
- a heap‑allocated *backing storage* (buffer or table) containing the elements

Copying a container:
- copies **only the handle**
- does **not** duplicate backing storage
- produces two containers that alias the same backing storage

Example:

```ori
var a []int = make([]int, 0, 8)
var b = a           // b aliases a’s backing buffer
```

Deep copies are performed via explicit APIs such as `clone` (for maps) or future library helpers.

---

### 260.3.2 Deterministic Destruction and Shared Storage

When the last live container handle referencing a backing storage instance is destroyed, the backing storage is:
1. logically invalidated and
2. deterministically deallocated and
3. all contained elements are destroyed according to their own destruction rules.

Implementations may use reference counting, arena ownership, or other mechanisms internally, but from the language perspective the behavior is **deterministic, with no GC**.

---

### 260.3.3 Views of Containers and Their Elements

`view` qualifiers never own container storage:

- `view string` refers to a substring of an existing `string`.
- `view []T` may refer to:
  - a slice of an existing `slice[T]`, or
  - a slice derived from contiguous container storage.
- `view T` for elements refers to a specific element within a container.

In all cases:

- the **source** container must outlive the view;
- any operation that may invalidate the referenced region while a view is live must be rejected.

Lifetime rules follow the general `view` semantics from `150_TypesAndMemory.md`. fileciteturn0file0

---

## 260.4 Strings

### 260.4.1 String Properties

`string` is:

- a UTF‑8 sequence of bytes
- **immutable** at the element level
- represented as a handle to heap‑allocated or static storage
- a reference‑semantics type (handle copy shares underlying bytes)

Because strings are immutable:

- multiple string handles can safely share the same storage;
- views into a string cannot mutate underlying bytes.

---

### 260.4.2 String Copy Semantics

Assigning or passing a `string`:

- copies the string handle;
- does *not* duplicate the underlying byte buffer.

Implementations may use copy‑on‑write or symbol interning internally, but the language guarantees:

- modifying a `string` value is only possible via **replacement**:

```ori
s := "hello"
s = s + " world"   // new string created; original storage remains immutable
```

---

### 260.4.3 String Slicing and `view string`

A substring operation yields a **view**:

```ori
s string := "hello world"
prefix view string := s[0:5]   // "hello"
```

Rules:

- `view string` is non‑owning; it cannot outlive `s`.
- implementations may represent `view string` as `(ptr, len)` into `s`’s buffer.
- any attempt to return a `view string` to a temporary or local string that does not escape is rejected at compile time.

Invalid:

```ori
func bad() view string {
    s string := "hi"
    return s[0:1]    // ❌ view to local string
}
```

Valid:

```ori
func ok(s string) view string {
    return s[0:1]    // caller owns `s`
}
```

---

### 260.4.4 String Literals and Static Storage

String literals may reside in static, read‑only storage. Views into such storage are valid for the entire program lifetime, subject to normal scope rules.

---

## 260.5 Slices

### 260.5.1 Slice Properties

A `slice[T]` is a *view‑like handle with mutation*:
- it references contiguous storage for elements of type `T`
- the handle stores `(ptr, len, cap)` or equivalent
- the underlying storage is owned by some heap allocation or larger container
- assignment copies the handle, so multiple slices may alias the same backing storage

Slices are not self‑owning values; instead, they are **mutable windows** into backing storage.

---

### 260.5.2 Append Semantics

Ori provides `append` with Go‑style ergonomics and explicit rules:
```ori
s []int := make([]int, 0, 4)
s = append(s, 1)
s = append(s, 2, 3, 4)
s = append(s, 5)     // may reallocate here
```

Rules:

- If `len(s) + new_elements <= cap(s)`:
  - no reallocation occurs;
  - the backing storage is reused;
  - all slices aliasing this buffer observe the mutations.
- If capacity is insufficient:
  - a new backing buffer is allocated with a larger capacity;
  - elements are copied into the new buffer;
  - the returned slice handle references the new storage;
  - slices that still reference the old storage remain valid but see only the old elements.

Append **always returns a new slice value**; code must assign the result to use the extended slice.

---

### 260.5.3 Reallocation and Aliasing Safety

Reallocation is safe by default, but developers must be aware of aliasing:

```ori
base []int := make([]int, 0, 2)
a := base
b := base

a = append(a, 1, 2)  // fills capacity; no reallocation
b[0] = 9             // both a and b see [9, 2]

a = append(a, 3)     // may reallocate; a now references new storage
// b still references the original backing storage
```

**Lifetime rule:** any `view []T` or `view T` into a slice’s storage must not be used after the underlying storage is released. The compiler:

- rejects obvious cases where a view could outlive its slice’s backing storage (e.g., views of temporaries);
- may conservatively reject code where it cannot prove that reallocation does not occur while a view is live.

---

### 260.5.4 Views of Slices

A slice can be converted to a read‑only view:

```ori
func sum(v view []int) int { /* ... */ }

func demo() {
    s []int := make([]int, 0, 8)
    s = append(s, 1, 2, 3)
    total := sum(view(s))   // OK
}
```

Rules:

- `view []T` cannot be used to mutate elements.
- operations that may reallocate or deallocate the underlying storage while a `view []T` is live are rejected when statically detectable.
- a `view T` to an individual element has the same lifetime constraints as any `view`.

---

### 260.5.5 Capacity Management

In addition to `append`, the standard library may offer:

- `reserve(slice[T], newCap int)` to grow capacity explicitly without changing length;
- `shrink_to_fit(slice[T])` to reduce capacity to `len`.

These functions are library‑level; the language semantics only require that:

- reallocation never changes existing element values;
- reallocation never changes the logical order of elements within the slice.

---

## 260.6 Ordered Maps: `map[K]V`

This section refines the ownership semantics of `map[K]V` as defined functionally in `110_Maps.md`.

### 260.6.1 Handle and Table

A `map[K]V` value is a handle to an internal ordered table structure:
- the table preserves **insertion order** for keys and values
- structural changes (insert/delete/clear) may reallocate or re‑organize the table internally
- the external iteration order remains in insertion order, even after growth or rehash.

Assigning or passing a map:
- copies the handle
- results in two map values that share the same underlying table.

---

### 260.6.2 Structural Mutations and Aliasing

Structural mutations:
- insert new keys
- delete existing keys
- clear the table
- may cause internal reallocation

Because map handles share storage, structural mutations are visible through all aliases:

```ori
m1 map[string]int = make(map[string]int)
m2 := m1

m1["a"] = 1
// m2["a"] is now 1 as well
```

The `clone` built‑in creates a new map with its own backing storage with identical contents and iteration order. The new map is therefore independant from the original map.

---

### 260.6.3 Views of Map Values

Lookup returns:
- **by value** in the normal `m[k]` or two‑value form
- optionally **by view**, via explicit APIs like `at_view(m, k) -> (view V, bool)` (library‑level)

If a view into a map value is provided:

- any structural mutation that could invalidate its location (e.g., delete, clear, growth or rehash) while the view is live is rejected when statically detectable
- deletion during iteration is a runtime error as specified in `110_Maps.md` (single‑writer iteration rule).

---

### 260.6.4 Iteration and Structural Safety

Iteration over a map uses insertion order and forbids structural mutation during iteration (insert/delete), enforced at runtime.

At the ownership level:
- iterators internally hold a view into the map’s table
- structural changes would invalidate this view, which is why they are treated as runtime errors
- non‑structural value updates are allowed because they do not invalidate layout

---

## 260.7 Hashmaps: `hashmap[K]V`

`hashmap[K]V` is a hash‑based dictionary container focused on throughput rather than deterministic iteration.

### 260.7.1 Properties

- hash‑based table with buckets and collision handling
- lookup, insert, delete are expected O(1) average case
- **iteration order is not specified** and may change across program runs, builds, or due to internal rehashing
- handle + backing storage model identical to `map[K]V` at a high level

---

### 260.7.2 Ownership and Aliasing

Assignment and parameter passing copy the handle and share backing storage, as with `map[K]V`.

Structural mutations (insert/delete/clear) may:
- rehash or resize the table
- move elements between buckets
- invalidate any internal views or iterators

As with maps, if the standard library offers view‑style APIs for hashmaps, their use is subject to the same lifetime rules: views must not outlive the underlying table and must not be used across structural mutations that could invalidate them.

---

### 260.7.3 Iteration

Hashmap iteration:
- is allowed via `for k, v := range h` syntax
- does not guarantee any particular ordering
- should not be relied upon for deterministic output or tests

If deterministic behavior is required, programs should use `map[K]V` or collect keys into a slice and sort them before iteration.

---

## 260.8 Container Ownership Rules (Unified)

### 260.8.1 Assignment and Parameter Passing

For all container types (`string`, `slice[T]`, `map[K]V`, `hashmap[K]V`):
- assignment copies the handle
- parameter passing copies the handle
- backing storage remains shared

To obtain an independent copy:
- use an explicit cloning function (`clone` for maps; similar helpers for other containers)
- or construct a new container and copy elements explicitly

---

## 260.9 Views, Aliasing, and Mutation Safety

### 260.9.1 General Rules

- A `view` never owns storage; it is tied to the lifetime of its source
- A container may be aliased through multiple handles and views simultaneously
- The compiler rejects obvious cases where a view would outlive its source container
- The language aims to ensure that no safe program observes a dangling view

---

### 260.9.2 Operations That May Invalidate Views

Potentially invalidating operations include:
- releasing or detaching the backing storage (container going out of scope when it is the last owner)
- `append` on slices when it triggers reallocation
- `clear`, `delete`, or growth that triggers table reallocation on maps or hashmaps
- container destruction during panic unwinding

The compiler:
- statically rejects simple patterns where such operations occur while a dependent view might still be used
- may conservatively reject code that is too complex to analyze soundly

---

### 260.9.3 Examples

Invalid view escape:

```ori
func bad_view_slice() view []int {
    s []int := make([]int, 0, 4)
    s = append(s, 1, 2, 3)
    return view(s)          // ❌ s’s backing storage is local
}
```

Valid borrowed view:

```ori
func head(v view []int) int {
    return v[0]
}

func demo() {
    s []int := make([]int, 0, 4)
    s = append(s, 1, 2, 3)
    h := head(view(s))      // OK: s outlives view
}
```

---

## 260.10 Deterministic Destruction Interaction

Container destruction integrates with deterministic destruction rules from `220_DeterministicDestruction.md`:

- when the last handle to a container’s backing storage is destroyed, the container’s destructor:
  - walks all elements, invoking their destructors (if any);
  - releases the backing storage
- views into that storage become invalid; any use of a view after its source container is destroyed is a compile-time error.
If the compiler cannot guarantee safety, it must reject the code

Containers held inside other containers or structs follow normal composition rules: destruction order is well‑defined and occurs from outer owner to inner fields.

---

## 260.11 Concurrency and Containers

Containers are subject to the concurrency and lifetime rules from `150_TypesAndMemory.md`.

### 260.11.1 Shared Containers

To share a container across tasks, it must be declared `shared`:
```ori
shared users map[string]int = make(map[string]int)
```

Rules:
- non‑`shared` containers cannot be passed to other tasks if they might be mutated there
- `shared` containers must be protected by synchronization primitives (mutexes, channels, etc.) for mutation
- `view` of a `shared` container is allowed for read‑only access, subject to lifetime rules

---

### 260.11.2 Views Across Tasks

`view` types are safe to send across tasks because they are read‑only, but:
- the source container must outlive all tasks using the view
- as with other cross‑task views, the creator must ensure the container is not destroyed before all tasks complete

Invalid:
```ori
func demo_bad() {
    s []int := make([]int, 0, 4)
    s = append(s, 1, 2, 3)
    spawn_task worker(view(s))   // ❌ s may be destroyed before worker finishes
}
```

Valid:
```ori
func demo_ok() {
    s []int := make([]int, 0, 4)
    s = append(s, 1, 2, 3)
    t := spawn_task worker(view(s))
    t.Wait()
}
```
---

### 260.11.3 Concurrent Structural Mutations

Structural mutations (append, insert, delete, clear, rehash) are not inherently thread‑safe:

- concurrent structural operations on the same container without synchronization are data races and undefined behavior
- this includes both maps and hashmaps, and slices whose backing storage is shared

To safely share mutable containers across tasks:

- confine mutation to a single owner task and communicate via messages or
- declare the container `shared` and guard all structural mutations with appropriate synchronization

---

## 260.12 Summary

- Containers are **handle + backing storage** values with reference semantics
- Assignment and parameter passing copy handles; storage is shared until explicitly cloned or moved.
- `string` is immutable; multiple strings may share storage safely
- `slice[T]` is a mutable window into contiguous storage; `append` may reallocate but never changes existing element values
- `map[K]V` is an ordered dictionary with deterministic **insertion order** iteration; `hashmap[K]V` is unordered and hash‑based
- `view` types never own storage and must not outlive their sources
- Operations that could invalidate live views are rejected when statically detectable; safe programs do not observe dangling views
- Containers obey the same deterministic destruction and concurrency rules as other Ori types, with additional care for structural mutations and aliasing


---


# 270. Modules and Compilation Units - Phase 1

This document defines the complete rules for **modules**, **packages**, **imports**, **visibility**, and **compilation units** in Ori.  
It consolidates and extends the syntactic rules described in `090_ModulesAndImports.md` and formalizes how the compiler organizes and processes code.

Ori follows a **strict module and package system**, with additional restrictions to ensure predictability, safety, and clarity.

---

# 270.1 Module Root

A module is the top-level project unit.
Every Ori module **must** contain a manifest file:
```
ori.mod
```

This file defines:
- the module’s root directory
- the canonical base path for all import strings

If `ori.mod` is missing:
```
error: missing ori.mod file; every module must define a root manifest
```

Only **one** module root is allowed.
Nested modules are forbidden.

Example (valid):
```
myapp/
 ├── ori.mod
 ├── main.ori
 └── util/
      ├── math.ori
      └── debug.ori
```

Example (invalid — nested module):
```
myapp/
 ├── ori.mod
 └── vendor/
       └── otherlib/
             └── ori.mod   // ❌ nested module
```

---

## 270.1.1 ori.mod Manifest File Format

For now, the `ori.mod` file uses a minimal and explicit format.

It contains a single directive:
```
module <module-name>
```

Where `<module-name>` is an identifier naming the module.
Example:
```
module myapp
```

Rules:
- The module name must be a valid identifier (ASCII letters, digits, underscores; must not start with a digit).
- Only one directive is allowed in this version.
- Additional fields (dependencies, versions, vendor configuration, build options) will be introduced in future design versions.
- If the file contains anything other than a single `module` directive, the compiler must fail.

Invalid examples:

```
module 123app       // ❌ cannot start with digit
module myapp        // OK
module second       // ❌ multiple module directives
name myapp          // ❌ unknown directive
```

---

# 270.2 Project Layout

The module root contains:
- `.ori` source files
- directories containing Ori packages
- optional test files (future version)

Example of a well-structured module:

```
myapp/
 ├── ori.mod
 ├── main.ori
 ├── util/
 │    ├── math.ori
 │    ├── format.ori
 │    └── strings.ori
 └── net/
      └── http/
           ├── client.ori
           └── server.ori
```

Example (invalid — folder contains `.ori` but missing package clause):

```
myapp/log/
 └── logger.ori  // contains no package definition → ❌ error
```

---

# 270.3 Packages

A **package** is a directory of `.ori` files sharing a `package` clause:

```ori
package util
```

Rules recap:

1. All `.ori` files in the directory must have **the same** `package` name.
2. A package must not span multiple directories.
3. Package name must equal the **last segment of its import path**.
4. Empty directories are ignored.

Example:

```
import "crypto/aes"
```

means:

```
<module_root>/crypto/aes/
```

must contain files starting with:

```ori
package aes
```

Invalid example:

Directory:
```
myapp/crypto/aes/encrypt.ori
```

Content:
```ori
package crypt    // ❌ does not match folder name 'aes'
```

Error:
```
package name 'crypt' does not match expected package name 'aes'
```

Invalid example — mixed packages:

```
math.ori    → package util
debug.ori   → package log   // ❌
```

---

# 270.4 Compilation Units

A **compilation unit** is a single `.ori` file.

Rules:

- Exactly one `package` clause.
- Must be at top of the file.
- All files in the same directory share a single namespace.

Example (valid):

File: `util/math.ori`

```ori
package util

func Add(a int, b int) int { return a + b }
```

File: `util/helpers.ori`

```ori
package util

func clamp(x, min, max int) int { ... }
```

These two files can freely call each other’s functions:

```ori
func Foo(x int) int {
    return clamp(Add(x, 2), 0, 10)
}
```

Invalid examples:

```
package util
package other   // ❌ duplicate package clause
```

```
func test() {}   // ❌ missing package clause
```

---

# 270.5 Build Behavior

Compilation steps:

1. Determine module root using `ori.mod`.
2. Discover package directories.
3. Check each folder for a valid package name.
4. Resolve imports.
5. Build a **dependency graph** of packages.
6. Reject cycles.
7. Topologically sort packages.
8. Compile leaf packages first.
9. Compile parent packages last.
10. If there is a `main` package, build an executable; otherwise a library.

---

# 270.6 Import Rules

Import paths are directory paths relative to module root.

Valid:

```
import "fmt"
import "util"
import "net/http"
import "crypto/aead"
```

Invalid:

```
import "./fmt"         // ❌
import "../util"       // ❌
import "/abs/path"     // ❌
import "util/"         // ❌ trailing slash
import "util//math"    // ❌ double slash
import ""              // ❌ empty import path
```

Example of valid nested structure:

```
myapp/
 └── data/
      └── parser/
           ├── tokenizer.ori   → package parser
           └── reader.ori      → package parser
```

Imported with:

```ori
import "data/parser"
```

---

## 270.6.1 Import Forms

Allowed:

```
import "fmt"
import ("fmt" "math")
import io "os/io"
```

Forbidden:

```
import _ "fmt"
import . "fmt"
```

---

## 270.6.2 Alias Rules & Examples

### Valid alias:

```
import h "net/http"
```

### Conflicting alias name:

```
import http "net/http"
import http "my/http"   // ❌ conflict
```

### Alias conflicts with local identifier:

```ori
var http = 5
import http "net/http"  // ❌ alias shadows local variable
```

### Redundant imports:

```ori
import "fmt"
import "fmt"   // ❌ error
```

### Redundant after alias:

```
import f "fmt"
import "fmt"   // ❌ redundant; both map to same package
```

---

# 270.7 File and Package Interactions

Inside a package:

- File order does not matter.
- Top-level declarations from all files merge into one namespace.
- Duplicated names cause errors.

Example (valid multi-file type definition):

`user/user.ori`:

```ori
package user
type struct User {
    Name string
}
```

`user/methods.ori`:

```ori
package user
func (u User) Greet() string { return "Hello " + u.Name }
```

Invalid (duplicate):

```
type struct User { Name string }
type struct User { Age int }    // ❌ duplicate type
```

---

# 270.8 Visibility Rules

Case-based visibility:

Exported:
```
Name, User, Parse, HTTPServer
```

Internal:
```
name, user, parse, httpServer
```

Examples:

```ori
type struct User {
    Name string   // exported
    age  int      // internal
}
```

Another package can do:

```
u := User{Name: "Ori"}      // OK
println(u.Name)             // OK
println(u.age)              // ❌ cannot access internal field
```

---

# 270.9 Entry Points

Executables must include a `main` package and:

```ori
func main()
```

Examples:

File: `main.ori`

```ori
package main
import "fmt"

func main() {
    fmt.Println("Hello")
}
```

Invalid:

```
package main
func main() {}
func main() {}    // ❌ duplicate main
```

```
package util
func main() {}    // ❌ main() must be inside package main
```

---

# 270.10 Error Conditions (Full List with Examples)

### Missing ori.mod
```
error: missing ori.mod file
```

### Mixed package names:
```
file1.ori: package util
file2.ori: package fmt   // ❌
```

### Missing package clause:
```
func c() {}  // ❌ missing package
```

### Cyclic import:
```
util imports net
net imports util  // ❌ cycle
```

### Self-import:
```
import "util"   // from util/ → ❌
```

### Duplicate imports:

```
import "fmt"
import "fmt"   // ❌
```

### Alias conflicts:

```
import http "net/http"
var http = 5               // ❌
```

### Unused imports:

```
import "fmt"   // ❌ never referenced
```

### Duplicate top-level declarations:

```
const A = 1
const A = 2    // ❌
```

### Type cycles (value embedding):

```
type struct A { b B }
type struct B { a A }   // ❌ infinite size
```

Valid pointer cycle:

```
type struct A { b *B }
type struct B { a *A }  // OK
```

### Top-level var:
```
var x = 10   // ❌ no global vars
```

### Top-level statements:
```
package util
println("hi")   // ❌ not allowed
```

---

# 270.11 Valid Layout Examples

### Example A — Simple App

```
myapp/
 ├── ori.mod
 ├── main.ori
 └── util/
      ├── math.ori
      └── helpers.ori
```

### Example B — Multi-Level

```
service/
 ├── ori.mod
 ├── api/
 │    ├── server.ori
 │    └── request.ori
 └── core/
      ├── model.ori
      └── storage.ori
```

Imports:

```ori
import "api"
import "core"
import "core/storage"
```

---

# 270.12 Invalid Layout Examples

### Nested same-name directory:

```
util/
 ├── util.ori      → package util
 └── util/         // ❌ ambiguous namespace
```

### Two modules inside one tree:

```
app/
 ├── ori.mod
 └── lib/
      └── ori.mod   // ❌ not allowed
```

### Package name not matching folder:

```
crypto/hash/hmac.ori
package hash      // ❌ must be package hmac
```

---


# 270. ModulesAndCompilationUnits - Phase 2

## 270.1. ori.mod

- Required fields:
  - `module <name>`
  - `ori x.y.z`
  - `require (<module-path> <revision>)`
- `<revision>` = SemVer or Git commit prefix
- Only one version per module allowed in `ori.mod`
- Importable modules MUST appear in `ori.mod`
- Transitive modules must NOT appear in `ori.mod`

## 270.2. `.vendor` Directory

The `.vendor` directory is always stored into the developer repository.

- Location: `.vendor/<module-path>/<revision>/`
- Revision = SemVer or commit
- Contains only:
  - `*.ori`
  - `ori.mod`
  - legal files: *LICENSE*, COPYING*, *NOTICE* (case-insensitive)
- Everything else stripped
- Symlinks forbidden → download error

## 270.3. Import Resolution

- Import path example:
  `import "github.com/foo/bar/util"`
- Resolve to:
  `.vendor/github.com/foo/bar/<revision>/util/`
- No version in import path
- Only modules listed in `ori.mod` can be imported

## 270.4. Sanitization

Kept:
- `.ori`
- `ori.mod`
- files matching LICENSE / COPYING / NOTICE (case incensitive)
Removed:
- Hidden files
- Assets
- Configs
- Scripts
- Build files
- Everything else

## 270.5. Hashing in ori.sum

- Hash only `.ori` and `ori.mod`
- Manifest generated from sorted paths:
  `<path>\n<size>\n<sha256(content)>\n`
- Final hash = sha256(manifest), base64-encoded:  `sha256:<hash>`
- Each module entry: `<module-path> <revision> sha256:<hash>`

## 270.6. Transitive Dependencies

- Transitives resolved recursively from each dependency’s `ori.mod`
- Added to `.vendor` and `ori.sum`
- Multi-version transitives allowed
- Conflict only if user imports the module

## 270.7. Forbidden

- Nested ori.mod
- Multiple versions of same direct module
- Missing ori.mod in dependency
- Hidden imports not listed in root ori.mod

## 270.8. Security

- HTTPS-only
- Strict TLS
- No scripts, no codegen
- No symlinks
- Deterministic builds

---


# 280. Compiler Directives And Keywords

## 280.1 Overview

Ori does not include any general attribute or annotation system (such as @inline, @test, @packed, #[repr], etc.).  
This follows Ori’s design principles of explicitness, clarity, and predictable behavior.

Instead, Ori uses:
- keywords for explicit compilation behavior (extern, comptime)
- naming conventions for tests (*_test.ori and TestXxx)
- standardized comments for deprecation (// Deprecated: ...)

There are no hidden compiler behaviors or metadata layers.

---

## 280.2 Keywords Used as Directives

### 280.2.1 extern

Declares a function implemented outside Ori (usually via the C ABI):
```ori
extern func printf(fmt string, ...) int
```

Rules:
- Only valid for function declarations
- Uses the platform’s default C ABI
- External functions may not accept Ori-specific types (slices, maps, views) unless future FFI rules allow it

---

### 280.2.2 comptime

The `comptime` keyword controls compile-time execution.  
It appears only in two forms:
1. Compile-time constant declaration:
   ```ori
   comptime const NAME = expr
   ```
2. Compile-time-only function:
   ```ori
   comptime func name(...) ...
   ```

All expression-level uses of comptime are forbidden.  
See 250_Compiletime.md for the full specification.

---

## 280.3 Test Discovery Rules

Ori uses Go-style test discovery.

### 280.3.1 Test File Naming

Any file ending with:
```ori
*_test.ori
```
is treated as a test file.

### 280.3.2 Test Function Naming

Inside test files, any function beginning with:
```ori
Test
```
is treated as a test entry point.

Example:
```ori
func TestAdd() {
    var result = add(2, 3)
    if result != 5 {
        panic("expected 5")
    }
}
```
No special keywords or attributes are required.

---

## 280.4 Deprecation Handling

A function or type may be marked as deprecated using a standardized comment:
```ori
// Deprecated: Use NewAPI instead.
func OldAPI() {}
```
Tools may read this format and issue warnings.
No annotation syntax is required.

---

## 280.5 No Comment-Based Directives

Ori disallows all comment-based compiler directives such as:
```ori
// ori:inline
// ori:packed
// ori:cfg
```

These are forbidden because they:
- create implicit compiler behavior
- become a pseudo-annotation system
- reduce explicitness
- increase long-term complexity

Comments cannot alter compilation except for recognized deprecation notices.

---

## 280.6 Removed / Not Included Features

Ori intentionally excludes the following in v0.8 and v1.0:
- @attribute syntax
- Rust-style #[attribute]
- decorator-like constructs
- macro annotations
- layout directives such as packed
- inline keyword or directive
- conditional compilation attributes
- metadata or reflection annotations

These features are excluded to preserve clarity and simplicity.

---

## 280.7 Summary

Ori’s compiler directives are intentionally minimal:
- Keywords: extern, comptime
- Naming conventions: *_test.ori, TestXxx
- Standard comments: // Deprecated: ...
- No attribute or annotation system
- No comment-based directives
- comptime appears only in two declaration-level forms

This keeps Ori explicit, predictable, and easy to reason about.

---


# 290. Foreign Function Interface (FFI)

## 290.1 Overview

This chapter defines Ori’s **Foreign Function Interface (FFI)**.

Goals:
- Allow Ori code to call functions implemented in C (or C-compatible ABIs).
- Allow Ori code to interact with C-defined types and constants.
- Keep the FFI surface **minimal, explicit, and predictable**.
- Preserve Ori’s internal freedom to evolve layouts and ownership rules without being constrained by C ABI.

FFI in Ori is intentionally conservative. Only a small set of types are allowed across the boundary, and all extern declarations must be explicit about their ABI contracts.

Ori does **not** introduce any general attribute or annotation system for FFI.  
Instead, FFI uses the `extern` keyword as a compiler directive. See 280_CompilerDirectivesAndKeywords.md for the general description of `extern`.

---

## 290.2 Extern Declarations

Ori uses three FFI-specific declaration forms:

```ori
extern func ...
extern type struct ...
extern const ...
```

These forms are reserved for FFI usage only.

### 290.2.1 `extern func`

Declares a function that is implemented outside Ori, using the platform’s C ABI:
```ori
extern func memset(dst *uint8, value int32, size uint64) *void
extern func puts(s *int8) int32
extern func qsort(base *void, n uint64, size uint64, cmp *void) void
```

Rules:
- The declaration has **no body** in Ori.
- The function is assumed to follow the platform’s default C calling convention.
- All parameter and return types must be **FFI-safe** (see 290.3).
- The ABI and behavior are defined by the external implementation, not by Ori.

#### 290.2.1.1 Explicit Return Type Required

Every `extern func` must specify an explicit return type. The following is **forbidden**:
```ori
extern func foo()        // compile-time error: missing return type
```

If the C function returns `void`, the extern declaration must use:
```ori
extern func foo() void   // OK: explicit FFI void
```

This avoids ambiguity and keeps FFI contracts explicit.

### 290.2.2 `extern type struct`

Declares a struct type whose layout and ABI are defined externally (typically by C):

```ori
extern type struct Timeval {
    tv_sec  int64
    tv_usec int64
}

extern type struct FILE
```

There are two sub-kinds:
1. **Transparent FFI struct**: fields are declared in Ori and must use FFI-safe types.
2. **Opaque FFI struct**: no fields are declared; the type is only usable through pointers.

Rules:
- Layout is defined by the platform C ABI, not by Ori’s internal struct rules.
- Only **FFI-safe types** may be used as fields.
- `extern type struct` types:
  - Have trivial, POD-like semantics in Ori.
  - Do not participate in deterministic destruction (no destructors).
  - Cannot be generic.
  - Cannot define methods in Ori with a receiver of that type (see 290.6).

Opaque structs (no fields) are used as handles:

```ori
extern type struct FILE

extern func fopen(path *int8, mode *int8) *FILE
extern func fclose(f *FILE) int32
```

Ori cannot construct or inspect a value of an opaque extern struct; it can only pass pointers to and from external functions.

### 290.2.3 `extern const`

Declares a constant imported from an external library or object:
```ori
extern const EOF int32
extern const PI float64
```

Rules:
- The type must be FFI-safe.
- The value is provided by the external link target.
- The constant is read-only in Ori; assigning to it is a compile-time error.

---

## 290.3 FFI-Safe Types

An **FFI-safe type** is a type whose representation and ABI are guaranteed to match the C ABI used by the extern declarations.

The following types are FFI-safe:

### 290.3.1 Scalar Types

The following scalar types are allowed in `extern func` parameters and return positions, and as fields in `extern type struct`:
- `int8`, `int16`, `int32`, `int64`
- `uint8`, `uint16`, `uint32`, `uint64`
- `float32`, `float64`
- `bool` (mapped to C `_Bool` / `bool` according to the platform ABI)

For FFI, users should prefer these fixed-width types to maintain ABI clarity.

The following are **not FFI-safe** and forbidden in extern declarations or extern struct fields:

- `int`, `uint`, `float` (platform-dependent width)
- any future extended numeric types (e.g., big integers, decimals)
- any type aliases whose underlying type is not FFI-safe

### 290.3.2 Pointer and Array Types

The following pointer and array forms are FFI-safe:
- `*T` where `T` is FFI-safe
- `[N]T` where `T` is FFI-safe

Special case: `*void` is allowed **only in extern declarations** to model C’s `void*`:

```ori
extern func malloc(size uint64) *void
extern func free(ptr *void) void
```

Outside of extern declarations, `void` and `*void` are not used as general Ori types.

### 290.3.3 External Struct Types

`extern type struct` declarations define FFI-safe struct types.
- Transparent extern structs:
  - All fields must use FFI-safe types.
  - Copying a value is allowed and treated as a raw memory copy (no destructors).
- Opaque extern structs:
  - Have no fields declared in Ori.
  - Are only used through pointers.

If a non-FFI-safe type is used as a field in an `extern type struct`, the compiler must emit a compile-time error.

### 290.3.4 Non-FFI-Safe Types

The following kinds of types are **not FFI-safe** and cannot appear in `extern` declarations or `extern type struct` fields:
- string
- slices
- views
- maps, hashmaps, and any other managed containers
- sum types
- interfaces
- function types and closures
- generic types and generic instantiations
- any type that has a user-defined destructor or non-trivial deterministic destruction behavior

Using a non-FFI-safe type in an extern context is a compile-time error.

---

## 290.4 `void` in FFI

Ori does not use `void` as a general-purpose type in normal code.  
For native Ori functions, "no return value" is expressed as:

```ori
func log(msg string) {
    // ...
}
```

In FFI, `void` is introduced as a **pseudo-type** used only in extern declarations:

- As the return type of functions that return C `void`:
  ```ori
  extern func puts(s *int8) int32
  extern func free(ptr *void) void
  ```
- As `*void` to model C’s `void*` in extern declarations.

Rules:

- `void` is only valid in `extern func` declarations and as the pointee for `*void` in extern signatures.
- Declaring `var x void` or `var p *void` in normal Ori code is forbidden.
- `extern func` declarations must always specify an explicit return type; `extern func foo()` without a return type is a compile-time error.

---

## 290.5 Calling External Functions

Given an extern function declaration:

```ori
extern func write(fd int32, buf *uint8, n uint64) int64
```

Ori code may call it as a normal function:
```ori
func writeAll(fd int32, data []uint8) int64 {
    // assuming some way to obtain *uint8 and length from the slice
    var ptr = sliceDataPtr(data)
    var len = sliceLen(data)

    return write(fd, ptr, len)
}
```

Rules:

- The call syntax is the same as for normal Ori functions.
- The compiler assumes nothing about side effects or purity.
- If the external implementation has undefined behavior, that behavior is outside Ori’s semantics.

### 290.5.1 Pointer Validity for Calls

When passing a pointer to an extern function:

```ori
extern func takesPtr(p *int32) void

func example() {
    var x int32 = 42
    takesPtr(&x)       // OK
}
```

Rules:
- The value pointed to must remain valid for at least the duration of the call.
- It is a compile-time error to pass the address of a non-addressable temporary:
  ```ori
  takesPtr(&(1 + 2))   // compile-time error: temporary has no stable address
  ```
- Ori does not attempt to reason about the long-term storage behavior of the C function. The programmer must not allow C to store pointers to stack-allocated Ori data that will become invalid after the call returns.

---

## 290.6 Operations on `extern type struct`

For a transparent extern struct:

```ori
extern type struct Timeval {
    tv_sec  int64
    tv_usec int64
}
```

Allowed:
- Declaring variables:
  ```ori
  var tv Timeval
  ```
- Copying values (assignment uses raw memory copy semantics).
- Taking addresses (`&tv`) and passing `*Timeval` to extern functions.

Not allowed:
- Defining methods with receivers:
  ```ori
  extern type struct Timeval { tv_sec int64, tv_usec int64 }

  func (t *Timeval) ToMillis() int64 { ... }  // forbidden, compile-time error
  ```
- Defining destructors or participating in deterministic destruction.
- Using `extern type struct` as a generic parameter or instantiation.

For an opaque extern struct:
```ori
extern type struct FILE
```

- Values of type `FILE` cannot be constructed or copied in Ori.
- Only pointers (`*FILE`) may be used and passed to extern functions.

---

## 290.7 Ownership and Allocation Rules

FFI follows a conservative ownership model.

### 290.7.1 C-Owned Memory

Memory allocated by C (e.g., via `malloc`) is treated as **C-owned**:

```ori
extern func malloc(size uint64) *void
extern func free(ptr *void) void
```

Rules:
- Ori must not attempt to free, reallocate, or manage C-owned memory using Ori’s own allocators.
- The typical pattern is:
  - C allocates (`malloc`)  
  - Ori uses the pointer according to the API contract  
  - C frees (`free`)

---

### 290.7.2 Ori-Owned Memory

Memory allocated by Ori using its own allocation mechanisms is **Ori-owned**.

Rules:
- C must not attempt to free or reallocate Ori-owned memory using `free` or other C allocation functions.
- Ori is responsible for freeing its own allocations according to its ownership and deterministic destruction rules.

---

### 290.7.3 Passing Ori Pointers to C

When an Ori pointer is passed to C:

- The pointed-to memory must remain valid for the duration of the call.
- Ori code must not assume that C will obey Ori’s ownership conventions unless the API explicitly documents it.
- The compiler does not perform deep escape analysis across FFI; the programmer must avoid exposing stack-only or short-lived pointers to long-lived C data.

### 290.7.4 Returning Pointers from C to Ori

When C returns a pointer (e.g., from `malloc` or library APIs):

- Ori treats the pointer as opaque and does not attach ownership metadata.
- The contract for how to use and eventually free that pointer is defined by the external API documentation.
- Ori code must follow the external API’s rules (e.g., “free with `free`”, “do not free”, “use a specific destroy function”, etc.).

---

## 290.8 Forbidden Features in Extern Contexts

To keep the FFI small, predictable, and implementable, the following constructs are **not allowed** in extern declarations or extern type definitions:

- Generics:
  ```ori
  extern func foo[T](x T) void   // forbidden
  ```
- Methods with receivers:
  ```ori
  extern func (p *Point) Move()  // forbidden
  ```
- Interfaces and sum types.
- Slices, views, strings, maps, hashmaps, and any managed containers.
- Function types, closures, and callbacks (function pointers may be added in a future version).
- Any type with a user-defined destructor or non-trivial deterministic destruction behavior.

Use of these features in an extern context must produce a compile-time error.

---

## 290.9 Summary

- FFI uses `extern` as a keyword-based directive:
  - `extern func` for external functions.
  - `extern type struct` for external struct types (transparent or opaque).
  - `extern const` for external constants.
- All extern declarations must use **FFI-safe types** only.
- `void` is introduced solely as an FFI pseudo-type, primarily for return types and `*void` in extern signatures.
- `extern type struct` cleanly separates C-ABI types from Ori’s internal struct layout and deterministic destruction model.
- Ownership across FFI is conservative:
  - C-owned memory is freed by C.
  - Ori-owned memory is freed by Ori.
- Advanced language features (generics, methods, interfaces, containers, destructors) are excluded from the FFI surface to keep it small and predictable.

This specification provides a minimal but solid foundation for calling into C libraries and interoperating with C-defined types, while preserving Ori’s design goals of clarity, explicitness, and safety.

---


# 300. Testing Framework - Phase 1

## 300.1 Overview

Ori’s testing framework follows the principles already established in `280_CompilerDirectivesAndKeywords.md`:
- **No attributes** (`@test`, `#[test]`, etc.)
- **No special syntax** (`test "..." {}`)
- **No runtime skip logic**
- **Test discovery is purely based on file naming and function naming**
- **Tests must be deterministic and explicit**

Ori’s test philosophy:
- Tests are **ordinary functions**
- Tests are discovered by naming conventions:
  - Files ending with `*_test.ori`
  - Functions starting with `Test`
- Tests run in a **single process**, sequentially
- An optional **TestContext** (`t *TestContext`) provides structured testing APIs
- **Panic = test failure**
- **Normal return = test success**

This approach keeps testing powerful, explicit, and predictable without introducing language-level magic.

---

## 300.2 Test File Discovery

A file is considered a test file if its name ends with:

```
*_test.ori
```

Rules:

- Such files are compiled only during `ori test`
- They belong to the same module as other Ori source files in the directory
- Non-test builds (`ori build`) ignore them
- There is no way to conditionally mark a file as test or non-test except by file name

Examples:
```
math/add.ori
math/add_test.ori
```

---

## 300.3 Test Function Discovery

Inside a test file, any function with the form:

```
func TestXxx(t *TestContext)
```

is considered a test entry point.

Rules:
- Must begin with `Test` (capital T)
- Must accept exactly **one parameter**: `t *TestContext`
- Must return no value
- Must not be generic
- Must not be `extern`
- Must not be `comptime func`

Example:

```
func TestAdd(t *TestContext) {
    if add(2, 3) != 5 {
        t.Fail("expected 5")
    }
}
```

---

## 300.4 TestContext API

The compiler injects a `TestContext` pointer into each test.  
It provides structured test features without language magic.

### 300.4.1 t.Fail(message string)

Marks the test as failed, but the test continues executing.

```
t.Fail("incorrect value")
```

---

### 300.4.2 t.FailNow(message string)
Immediately aborts the test by raising a controlled panic.

```
t.FailNow("fatal failure")
```

Equivalent to:

```
t.Fatal("fatal failure")
```

---

### 300.4.3 t.Fatal(message string)

Alias for `t.FailNow`. Conventional shorthand.

---

### 300.4.4 t.Run(name string, func(t *TestContext))

Runs a subtest with its own TestContext and deterministic scope.

```
t.Run("simple add", func(t *TestContext) {
    if add(1, 2) != 3 {
        t.Fail("bad add")
    }
})
```

Subtests:
- Run sequentially
- Have their own destruction scope
- Can contain nested subtests

### 300.4.5 t.Cleanup(func())
Registers a cleanup function executed after the test completes.

Cleanups run **after local variables are destroyed**, in **LIFO** order.

```
t.Cleanup(func() {
    File.remove("temp.bin")
})
```

---

### 300.4.6 t.OS (string)

Reports the current operating system as a lowercase string:

```
"linux"
"windows"
"darwin"
```

Used for OS-specific tests, with explicit early return.

Example:

```
if t.OS != "linux" {
    return
}
```

There is no skip state, no skip counter, and no hidden behavior.

---

## 300.5 Test Execution Model

Tests are run:

1. In deterministic order:
   - Test files sorted lexicographically
   - Test functions discovered in lexical order within the file
   - Subtests run in the order they are declared
2. Sequentially (no parallel test execution)
3. In a single process
4. With deterministic destruction:
   - Local variables destroyed at end of function
   - Then cleanup functions run
   - Then TestContext destroyed

Test outcomes:
- **Pass**: normal return
- **Fail**: panic triggered by t.FailNow or panic triggered in code
- **Continue**: t.Fail does not interrupt

---

## 300.6 Panic Behavior

Any panic inside a test or subtest marks that test as **failed**.

Subtest example:

```
t.Run("panic example", func(t *TestContext) {
    panic("boom")
})
```

This does not terminate the parent suite; the failure is recorded and execution continues.

---

## 300.7 OS-Specific Tests (Explicit Early Return)

Ori does **not** support `t.Skip` or runtime skip semantics.

Instead, OS-specific tests use **explicit early returns**:

```
func TestOnlyLinux(t *TestContext) {
    if t.OS != "linux" {
        return
    }

    // linux-specific logic
}
```

No hidden logic, no skip counters, no conditional metadata.

---

## 300.8 Test Runner Behavior (`ori test`)

### 300.8.1 Basic invocation

```
ori test
```

Runs tests in the current module.

---

### 300.8.2 Recursive invocation (`./...`)

```
ori test ./...
```

Runs tests in all modules under the current directory.

This mirrors Go’s extremely ergonomic `./...` wildcard.

---

### 300.8.3 Directory/package selection

```
ori test ./math
ori test ./utils
```
---

### 300.8.4 Filtering (`-run`)

```
ori test -run TestAdd
ori test -run add
```

Filters test names by substring.

---

### 300.8.5 Output format

```
running 3 tests
TestAdd ... ok
TestMin ... ok
TestLinuxOnly ... ok
```

Failures include the panic or Fail message.

### 300.8.6 Exit codes

- `0` = all tests passed
- `1` = at least one failure
- `2` = test build failure

---

## 300.9 Examples

### Basic test

```
func TestAdd(t *TestContext) {
    if add(2, 3) != 5 {
        t.Fail("expected 5")
    }
}
```

### Using Cleanup

```
func TestFile(t *TestContext) {
    t.Cleanup(func() { File.remove("temp.txt") })

    var f = File.create("temp.txt")
    f.write("hello")
}
```

### Subtests

```
func TestMath(t *TestContext) {
    t.Run("add", func(t *TestContext) {
        if add(1, 2) != 3 {
            t.Fail("bad add")
        }
    })

    t.Run("mul", func(t *TestContext) {
        if mul(3, 4) != 12 {
            t.Fail("bad mul")
        }
    })
}
```

### OS-specific

```
func TestOnlyWindows(t *TestContext) {
    if t.OS != "windows" {
        return
    }

    // windows-only logic
}
```

---

## Summary of Phase 1

Ori’s testing system:
- Uses Go-style discovery
- Uses an explicit TestContext instead of attributes
- Avoids global state and runtime skipping
- Has deterministic destruction and no magic
- Is powerful via t.Run, t.Cleanup, and t.OS
- Remains fully explicit, predictable, and easy to reason about

---


# 300. Testing Framework — Phase 2 Extensions

This document extends `300_TestingFramework_Phase1.md` with additional testing capabilities. These additions preserve Ori’s core principles:
- No attributes or annotations (`@test`, `#[test]`, etc.)
- No implicit skip or runtime metadata
- Full determinism in ordering and destruction
- Explicit, visible APIs for all behavior
- Subtests remain sequential unless explicitly parallelized
- Tests remain normal functions discovered by naming conventions

Phase 2 introduces improvements centered on ergonomics, correctness, concurrency testing, and strict, predictable timeouts.

The default per-test timeout is **10 minutes**.

Ori does **not** implement a global test suite timeout.

---

## 300.20 Overview of Phase 2 Additions

Phase 2 introduces:
- Deterministic parallel subtests (`t.Parallel`)
- Strict per-test timeouts (`t.Deadline`)
- Structured logging (`t.Log`, `t.Logf`)
- Environment helpers (`t.Env`)
- Temporary directories (`t.TempDir`)
- Standard assertion helpers (`t.Equal`, `t.NotEqual`, `t.Nil`, etc.)
- Clearer failure reporting

These additions extend — but do not modify — the semantics of Phase 1.

---

## 300.21 Parallel Subtests

Parallel execution in Ori is **explicit**, **deterministic**, and **restricted for simplicity**.

### 300.21.1 API

```
t.Parallel(func(t *TestContext))
```

### 300.21.2 Semantics

- A parallel block behaves as **one atomic concurrent test unit**.
- The block inherits the parent test’s timeout.
- Parallel tasks run concurrently but:
  - **Print output in declaration order**
  - **Never interleave log lines**
  - **All tasks must complete before the parent test returns**

### 300.21.3 Restrictions inside `t.Parallel`

Inside a parallel block:
- `t.Run` is **forbidden**
- `t.Parallel` is **forbidden**
- `t.Deadline` is **forbidden**

A parallel block must not create subtests and must not override or disable its timeout.

---

## 300.22 Test Deadlines (Timeouts)

Ori enforces a **single timeout per test**, determined at the top-level test function.

### 300.22.1 Default timeout

Every test has a default timeout of:
```
10 minutes
```

This timeout applies uniformly to the test and all its subtests, including parallel tasks.

### 300.22.2 API

```
t.Deadline(d Duration)
```

### 300.22.3 Timeout rules

- `t.Deadline` is **only** be called in a top-level test (`func TestXxx`)
- Subtests (`t.Run`) **cannot** override the timeout
- Parallel blocks (`t.Parallel`) **cannot** override the timeout
- Timeouts **cannot** be disabled

### 300.22.4 Effective timeout resolution

The effective timeout for any test or subtest is determined by the following table:

Top-level Deadline? | Subtest Deadline? | Allowed? | Result
--------------------|-------------------|----------|--------
No                  | No                | ✔        | Uses default (10 minutes)
Yes                 | No                | ✔        | Uses overridden timeout
No                  | Yes               | ❌       | Compile-time error
Yes                 | Yes               | ❌       | Compile-time error
Inside Parallel     | Any               | ❌       | Compile-time error

### 300.22.5 Timeout behavior

If a test exceeds its timeout, Ori injects:
```
panic("test deadline exceeded")
```

- Only the timed-out test fails
- The overall suite continues
- Cleanup functions of the timed-out test **do not run**

### 300.22.6 No global timeout

Ori does **not** implement a suite-wide timeout.

---

## 300.23 Logging Support

### 300.23.1 API

```
t.Log(msg string)
t.Logf(format string, args...)
```

### 300.23.2 Output rules

- Logs are buffered per test/subtest
- Logs print:
  - if the test fails, or
  - if `--verbose` is passed to the runner
- Log lines **never interleave** across tests
- Tests and subtests print results in **declaration order**, even when using `t.Parallel`

---

## 300.24 Environment Helpers

### 300.24.1 API

```
t.Env(name string) string
```

### 300.24.2 Behavior

- Returns the value of the environment variable or an empty string
- Early return based on environment logic is considered a **PASS**
- Ori has **no skipped-test state**

Example:
```
if t.Env("CI") == "" {
    return
}
```

---

## 300.25 Temporary Directories

### 300.25.1 API

```
dir := t.TempDir()
```

### 300.25.2 Behavior

- Creates a unique temporary directory for the current test or subtest
- Automatically deleted during cleanup
- Safe to use in both sequential and parallel contexts

---

## 300.26 Assertion Helpers

Ori provides a standard set of assertion helpers to avoid reliance on external libraries.

### 300.26.1 API

```
t.Equal(got, want)
t.NotEqual(a, b)
t.True(expr, msg)
t.False(expr, msg)
t.Nil(v)
t.NotNil(v)
t.Error(err)
t.NoError(err)
t.ErrorIs(err)
```

### 300.26.2 Semantics

- Failed assertions call `t.FailNow` with file/line information
- Assertions abort the current test or subtest

---

## 300.27 Enhanced Failure Output

When a test fails:
- The runner prints:
  - test name
  - file and line of failure
  - collected logs
- Output is deterministic and sorted by declaration order

---

## 300.28 Interaction with Phase 1 Features

Everything from Phase 1 remains intact:
- Tests discovered via `*_test.ori` and functions named `TestXxx`
- Subtests created via `t.Run` execute sequentially
- Parallel blocks are atomic and restricted
- Deterministic ordering across the entire test suite

Phase 2 **extends** the framework; it does not alter Phase 1 semantics.

---

## 300.29 Examples

### Parallel subtests (correct usage)

```
func TestConcurrentAccess(t *TestContext) {
    t.Deadline(10 * time.Second)

    t.Parallel(func(t *TestContext) {
        // task 1 logic
    })

    t.Parallel(func(t *TestContext) {
        // task 2 logic
    })

    t.Run("subtest", func(t *TestContext) {
        // inherits 10s timeout
        doWork()
    })
}
```

### Deadline override (only allowed at top level)

```
func TestLoad(t *TestContext) {
    t.Deadline(5 * time.Second)

    t.Run("slow-path", func(t *TestContext) {
        slowComputation()   // uses 5s timeout
    })
}
```

### Forbidden patterns

```
t.Parallel(func(t *TestContext) {
    t.Deadline(10 * time.Second)          // ❌ forbidden
})

t.Parallel(func(t *TestContext) {
    t.Run("bad", func(t *TestContext) {}) // ❌ forbidden
})

t.Run("bad", func(t *TestContext) {
    t.Deadline(5 * time.Second)           // ❌ forbidden (subtest override)
})

t.Run("bad", func(t *TestContext) {
    t.Parallel(func(t *TestContext) {})   // ❌ forbidden
})

t.Run("bad", func(t *TestContext) {
    t.Run("bad", func(t *TestContext) {}) // ❌ forbidden
})
```

---

## 300.30 Summary of Phase 2

Phase 2 adds:
- deterministic parallel execution
- strict per-test timeout model (default: 10 minutes)
- deterministic logging and output
- environment inspection
- temporary directories
- standard assertion helpers
- improved failure reporting

Ori’s testing system remains explicit, deterministic, and free of magic.

---


# 310. Pointers

**Pointers** in Ori provide low-level access to raw memory addresses.  
They are intended for FFI, embedded systems, and advanced performance-critical operations.  
Pointers do **not** participate in Ori’s ownership, view, or shared-memory system, and they do not provide any safety guarantees.  
They are purely raw, nullable addresses.  
Pointers must always be used consciously and explicitly.

--- 

## 310.1 Overview

Ori emphasizes explicitness, predictability, and safe-by-default design. Pointers therefore follow these principles:
- **Explicit** — Pointer types must always be written by the programmer. No inference
- **Nullable** — Pointers may hold `nil`
- **Non-owning** — Pointers never control destruction or ownership
- **Low-level** — Raw addresses without safety or validity guarantees
- **Rare** — Everyday code should use containers, slices, and shared-memory primitives instead

Pointers mainly exist for:
- FFI (Foreign Function Interface) interaction
- Address-based low-level systems programming
- Specialized data structures

---

## 310.2 Pointer Type Syntax

Pointer types are written with the prefix `*`:

```ori
var p *int
var q *User
```

---

### 310.2.1 Nullability

All pointer types are nullable by default.

```ori
var p *int = nil
```

Dereferencing `nil` is invalid:
- If the compiler can prove `p` is `nil` → **compile-time error**
- Otherwise → **runtime safety error**

---

## 310.3 Obtaining a Pointer

A pointer is obtained only through the **address-of** operator:
```ori
var x int = 5
var p *int = &x   // OK
```

---

### 310.3.1 No Type Inference for Pointers

Pointer inference is **forbidden**:
```ori
var p = &x    // ❌ compile-time error: pointer type must be explicit
```

Only the explicit form is allowed:
```ori
var p *int = &x
```

This avoids ambiguity with other memory-related types (`view`, `shared`).

---

## 310.4 Dereferencing

Dereferencing uses the unary `*` operator.

### 310.4.1 Reading

```ori
var x int = 42
var p *int = &x

var y int = *p   // y = 42
```

---

### 310.4.2 Writing

```ori
*p = 99
```

---

### 310.4.3 Dereferencing Rules

- Dereferencing known-nil → compile-time error
- Dereferencing `nil` → runtime safety error
- Dereferencing does not extend lifetimes
- Dereferencing never affects destructors or ownership

---

## 310.5 Pointer Semantics

### 310.5.1 No Ownership

A pointer never owns the memory it points to:
```ori
{
    var u User{Name: "A"}
    var p *User = &u
}   // destructor(u) runs here
    // p is now dangling
```

---

### 310.5.2 Comparisons

Only equality is supported:
```ori
p == q
p != q
p == nil
```

Ordering comparisons are **forbidden**:
```ori
p < q     // ❌ compile-time error
```

---

### 310.5.3 Pointer Arithmetic

All pointer arithmetic is forbidden:
```ori
p + 1     // ❌ compile-time error
p - 4     // ❌ compile-time error
```

---

### 310.5.4 Dangling Pointers

A pointer becomes **dangling** when it still holds an address, but the object at that address has been destroyed or deallocated.

Examples:
- A pointer to a local variable used after the variable’s scope ends
- A pointer to memory freed by a foreign allocator

Ori does not track all aliases or automatically nullify pointers when their target is destroyed. After the lifetime of the pointee ends, every pointer to it becomes dangling, and dereferencing such a pointer is a runtime safety error.

The compiler may statically reject trivial escaping cases (such as `return &localVar`), but in general it does not perform lifetime analysis for pointers.

---

### 310.5.5 Pointers Cannot Be Method Receivers

Raw pointers (*T) cannot be used as method receivers.

Example of invalid method declaration:
```ori
func (t *Test) count() int   // ❌ invalid
```

Reasons:
- Pointers are unsafe: nullable, may dangle, not lifetime-checked
- Pointers do not integrate with shared / const receiver semantics
- Pointers do not imply ownership or safe aliasing
- Pointer receivers would break deterministic destruction and concurrency rules

Use safe receivers instead:
- For mutation:
  ```ori
  func (t shared Test) count() int
  ```
- For read-only access:
  ```ori
  func (t const Test) show() string
  ```
- For copy semantics:
  ```ori
  func (t Test) clone() Test
  ```

This ensures method calls always operate on valid, lifetime-checked memory.

---

## 310.6 Runtime Safety Rules

The following produce runtime errors:
- Dereferencing a `nil` pointer
- Dereferencing an invalid or dangling pointer
- Using pointers across threads without synchronization

No compiler lifetime analysis is performed for pointers.

---

## 310.7 Heap Allocation with `new(T)`

`new(T)` allocates a `T` on the heap (defined in `150_TypesAndMemory.md`):

```ori
var p *T = new(T)
```

Properties:
- Returns a pointer `*T`
- Memory is owned by the variable holding the pointer
- Destroyed when that owner goes out of scope
- May escape function scope safely

Example:
```ori
func f() *int {
    var p *int = new(int)
    *p = 10
    return p
}
```

---

## 310.7 Interactions with Other Features

### 310.7.1 Pointers vs Views

| Feature | View (`view T`) | Pointer (`*T`) |
|--------|------------------|----------------|
| Safety | High | None |
| Nullability | No | Yes |
| Bounds checks | Yes | No |
| Alias tracking | Yes | No |
| Primary use | Safe slicing | Raw address access |

Views should be used whenever safety is desired.

---

### 310.7.2 Pointers vs Shared

`shared` is a **concurrency qualifier**, not a memory-level primitive.

| Feature | `shared T` | `*T` |
|---------|-------------|-------|
| Purpose | concurrency-safe access | raw address |
| Nullability | never | yes |
| Ownership | normal | no |
| Thread-safe | yes (rules enforced) | no |
| Use case | multi-task communication | FFI, low-level ops |

Guideline:

> Use `shared` for cross-thread access.  
> Use pointers for raw memory or interop only.

---

### 310.7.3 Returning Pointers to Locals

Returning the address of a local variable is illegal:
```ori
func f() *int {
    var x int = 10
    return &x       // ❌ compile-time error
}
```

Correct syntax:
```ori
func f() *int {
    var x *int = new(int)
    *x = 10
    return x
}
```

---

### 310.7.4 Pointers and Generics

Pointers work naturally inside generic functions:
```ori
func Swap[T](a *T, b *T) {
    var tmp T = *a
    *a = *b
    *b = tmp
}
```

---

### 310.7.5 Pointers and FFI

Pointers are essential to FFI:
```ori
@[extern("C")] // exact syntax not yet define
func malloc(size int) *byte

@[extern("C")] // exact syntax not yet define
func free(p *byte)
```

They carry the exact semantics of the foreign system and are inherently unsafe.

---

## 310.8 Concurrency

Pointers are not concurrency-safe.  
Example of unsafe behavior:
```ori
spawn_thread {
    *p = 10   // possible data race
}
```

Developers must rely on:
- `shared`
- synchronization primitives
- concurrency-safe containers

when sharing data between tasks.

---

## 310.9 Forbidden Patterns

The compiler must reject:
```ori
var p = &x              // ❌ compile-time error: pointer type must be explicit
var p = nil             // ❌ compile-time error: type must be explicit
p + 1                   // ❌ compile-time error: pointer arithmetic
return &localVar        // ❌ compile-time error: pointer escaping local
p = 10                  // ❌ compile-time error: assigning int to *int
```

---

## 310.10 Correct Usage Examples

```ori
var x int = 5
var p *int = &x

*p = 10
var y = *p        // y = 10
```

```ori
type struct Node {
    value int
    next  *Node
}
```

```ori
func increment(x *int) {
    *x = *x + 1
}
```

---

## 310.11 Misuse Examples (Common Errors)

### 310.11.1 Assigning a Value Directly to a Pointer

```ori
var x int = 5
var p *int = &x

p = 10
```

❌ **ERROR**: `p` has type `*int`, cannot assign an `int`.

Correct version:
```ori
*p = 10
```

---

### 310.11.2 Confusing Pointer with Value

```ori
var x int = 5
var p *int = &x

var y = p
```

❌ `y` is a `*int`, not the value `5`.

Correct:

```ori
var y int = *p
```

---

### 310.11.3 Attempting Pointer Arithmetic

```ori
p += 1     // ❌ compile-time error
z = p + 4  // ❌ compile-time error
```

Ori does not support pointer arithmetic.

---

### 310.11.4 Assuming Dereference Happens Automatically

```ori
var x int = 5
var p *int = &x

var y int = p    // ❌ compile-time error
```

Dereference must always be explicit:
```ori
var y int = p  // ❌ error
var y int = *p // ✅ valid
```

---

## 310.12 Summary

- Pointer types use `*T`
- Pointers are nullable; `nil` is the null pointer
- Pointers must be declared explicitly
- No pointer inference
- Dereferencing uses `*p`
- Dereferencing a known-nil pointer produces a compile-time error
- Dereferencing a possibly-nil pointer produces a runtime error
- `new(T)` introduces heap allocation
- Pointers never own memory
- No pointer arithmetic
- Only equality comparisons allowed
- Unsafe across threads unless wrapped
- Intended primarily for FFI and low-level operations
- Unsafe for concurrency without protection

---


# 320. Blank Identifier `_`

The blank identifier `_` in Ori is a **pure discard target**.  
It does not bind a name, it cannot be referenced, and it has no semantic meaning beyond discarding a value.

Ori’s design philosophy emphasizes explicitness and predictable behavior.  
Therefore, `_` is intentionally limited and cannot be used as a wildcard pattern or implicit match binding.

---

## 320.1 Overview

The blank identifier:
- Never introduces a variable
- Never participates in the symbol table
- Cannot be referenced or shadowed
- Runs destructors on discarded **temporary** values
- Does *not* run destructors on discarded **views** (because such usage is forbidden)
- Is permitted only in clearly defined positions

---

## 320.2 Allowed Usages

### 320.2.1 Discarding a Returned Value

```
_ = compute()
x, _ = getPair()
```

### 320.2.2 Function Parameters

```
func handleEvent(_ string, code int) {
    // first parameter intentionally ignored
}
```

### 320.2.3 Loop Iteration

```
for _, value := range items {
    // index ignored
}

for index, _ := range items {
    // value ignored
}
```

### 320.2.4 Assigning to `_` (not declaring)

This is allowed:

```
_ = viewSlice(someArray)   // OK
```

This is **not** allowed:

```
var _ = viewSlice(someArray)   // ❌ forbidden
```

Rationale:  
`var _ = ...` implicitly introduces a variable declaration, which does not make sense for a discard target.  
A simple assignment `_ = expr` is allowed because `_` is not being declared — it is only discarding the value.

---

## 320.3 Forbidden Usages

### 320.3.1 Variable Declarations

```
var _ = value        // ❌ forbidden
const _ = 1          // ❌ forbidden
```

### 320.3.2 Pattern Matching

```
switch x {
    case _:      // ❌ wildcard matches forbidden
}
```

Ori requires explicit and exhaustive matching for sum types and patterns.  
Wildcard matches undermine this safety guarantee.

### 320.3.3 Imports

Wildcard imports are forbidden:

```
import "fmt" _                // ❌ forbidden
import "math" { Sin, _ }      // ❌ forbidden
```

### 320.3.4 As a Field Name

```
type struct User {
    _ int      // ❌ forbidden
}
```

### 320.3.5 As a Return Value Placeholder

```
func load() (_, int)          // ❌ forbidden
```

Return value names must be real identifiers.

### 320.3.6 Future-Proofing: No Destructuring Wildcards

Even if destructuring syntax is introduced in future versions, `_` cannot appear in it:

```
(x, _, z) = getTuple()        // ❌ forbidden
```

---

## 320.4 Destructor Semantics

Even though `_` does not introduce a variable, discarding a **temporary value** must still run its destructor:

```
_ = openFile()   // destructor will run immediately after assignment
```

This ensures deterministic resource safety.

However, `_` **cannot** be used in any context that extends the lifetime of a view or shared reference:

```
var _ = viewSlice(arr)   // ❌ forbidden
_ = viewSlice(arr)       // ✔️ allowed (no lifetime extension)
```

---

## 320.5 Compiler Rules Summary

- `_` is a special token, not an identifier.
- `_` cannot appear in declarations.
- `_` cannot be referenced.
- `_` may appear in assignment, parameters, and loop bindings.
- `_` never stores a value.
- `_` runs destructors for temporary values.
- `_` never affects lifetime analysis.
- `_` cannot appear in pattern matching or destructuring.
- `_` triggers no warnings for “unused” semantics.

---

## 320.6 Summary Table

| Context                         | Allowed? | Notes |
|---------------------------------|----------|-------|
| `var _ = expr`                  | ❌       | `_` cannot declare a variable |
| `_ = expr`                      | ✔️       | Discards value, destructor runs |
| `x, _ = expr`                   | ✔️       | Discard secondary value |
| Function parameter              | ✔️       | Ignores param |
| Loop index/value                | ✔️       | Discards position/value |
| Pattern matching                | ❌       | No wildcard matches |
| Imports                         | ❌       | No wildcard or selective `_` imports |
| Struct field name               | ❌       | `_` cannot be a field |
| Function return names           | ❌       | Must be explicit |
| Destructuring bindings          | ❌       | Forbidden now & future |

---


# 330. Build System and Compilation Pipeline

## 330.1 Overview

This document defines the official build system and compilation pipeline for Ori.  
It builds upon the module rules defined in `270_ModulesAndCompilationUnits.md`,
the testing rules in `300_TestingFramework.md`, and the FFI rules in `290_FFI.md`.

Ori uses **whole-program compilation (WPC)**, explicit build targets, static linking,
and predictable output directory conventions. The build system must remain explicit,
consistent, and minimal while supporting future extensibility.

The goals of the Ori build pipeline are:
- Provide a clear, deterministic compilation model
- Ensure static linking by default with no need for a C compiler
- Support explicit cross-compilation through architecture and OS flags
- Provide predictable and consistent directory layouts for all generated artifacts
- Allow optional emission of intermediate representations via explicit flags
- Treat tests as first-class builds using the same compilation pipeline

---

## 330.2 Build Commands

The Ori compiler provides the following core commands:

### 330.2.1 `ori build`

Builds the current module into a binary:
```ori
ori build
ori build --arch=x86_64 --os=linux --opt=release
```

---

### 330.2.2 `ori run`

Builds (if necessary) and runs the produced binary:
```ori
ori run
ori run --arch=aarch64 --os=macos --opt=release
```

---

### 330.2.3 `ori test`

Discovers and builds test files (`*_test.ori`) and executes tests:
```ori
ori test
ori test --arch=x86_64 --os=linux --opt=release
```

Tests use the same compilation pipeline but produce a distinct test binary.

---

### 330.2.4 `ori build --emit=*`

Optionally emits intermediate artifacts such as IR (intermediate representation) or assembly:
```ori
ori build --emit=ir
ori build --emit=obj
ori build --emit=asm
```

Artifacts are placed in:
```ori
build/<arch>/<os>/<opt>/<module>/artifacts/
```

Nothing is emitted unless explicitly requested.

---

## 330.3 Build Flags

The Ori compiler accepts explicit and orthogonal build flags.

### 330.3.1 `--arch`

Target CPU architecture:
- `x86_64`
- `aarch64`
- `riscv64`

---

### 330.3.2 `--os`

Target operating system:
- `linux`
- `macos`
- `windows`

---

### 330.3.3 `--opt`

Optimization level. Ori does not use numeric levels like -O0/-O2 but explicit names:
- `release` (default)
- `aggressive`

---

### 330.3.4 Defaults
If unspecified:
```ori
--arch = host arch
--os   = host os
--opt  = release
```

---

## 330.4 Output Directory Structure

All Ori builds must produce output using the following structure:
```ori
build/<arch>/<os>/<opt>/<module>/
bin/       # final executable
tests/     # test binary (only for ori test)
artifacts/ # optional IR/asm/obj (only with --emit)
```

Example:
```ori
build/x86_64/linux/release/myapp/bin/myapp
build/x86_64/linux/aggressive/myapp/bin/myapp
build/aarch64/macos/release/myapp/tests/myapp_tests
build/x86_64/linux/release/myapp/artifacts/program.ir
```

This structure is stable, explicit, and fully deterministic.

---

330.5 ASCII Diagram — Output Directory Layout

```ori
build/
└── x86_64/
    └── linux/
        ├── release/
        │   └── myapp/
        │       ├── bin/
        │       │   └── myapp
        │       ├── tests/
        │       │   └── myapp_tests
        │       └── artifacts/
        │           ├── program.ir
        │           └── program.o
        └── aggressive/
            └── myapp/
                └── bin/
                    └── myapp
```
---

## 330.5 Compilation Pipeline

Ori uses a fixed and explicit 11-step compilation pipeline.

### 330.5.1 Step 1 — Input Discovery

- Locate module root using `ori.mod`.
- Verify the module name.
- Enumerate all `.ori` source files except test files (`*_test.ori`) unless running `ori test`.

---

### 330.5.2 Step 2 — Parsing → AST

All source files are parsed into ASTs. Parsing always produces ASTs directly; Ori does not use CSTs.
Syntax errors halt compilation.

---

### 330.5.3 Step 3 — Package Assembly

- ASTs belonging to the same package are merged.
- Mixed package names in a directory are compile-time errors.

---

### 330.5.4 Step 4 — Import Resolution

- Resolve import paths relative to module root.
- Validate rules from `270_ModulesAndCompilationUnits.md` (no cycles, no dot imports, no unused imports, etc.).
- Construct the full dependency graph of packages.

---

### 330.5.5 Step 5 — Type Checking & Semantic Analysis

The compiler applies all rules defined in the semantics layer:
- type system
- sum types
- generics
- deterministic destruction
- pointer safety
- concurrency constraints
- FFI validation
- compile-time execution (`comptime` rules)

---

### 330.5.6 Step 6 — Compile-Time Execution

All `comptime const` and `comptime func` calls are evaluated.
Only allowed CTE forms are permitted (`250_Compiletime.md`).

---

### 330.5.7 Step 7 — Generic Monomorphization

Generic functions, structs, and methods are instantiated for each concrete type parameter combination.
`const` generic parameters are resolved at compile time.

The output is a fully concrete, monomorphic program representation.

---

### 330.5.8 Step 8 — IR Generation

The fully-typed, monomorphized AST is lowered into Ori’s internal IR.
The IR format is *not* stable across compiler versions.

---

### 330.5.9 Step 9 — Optimization Passes

Depending on `--opt`:
- `release`: moderate optimization
- `aggressive`: maximum optimization (inlining, DCE, loop transforms)

---

### 330.5.10 Step 10 — Code Generation

Machine code is generated for the target architecture and OS.

---

### 330.5.11 Step 11 — Linking

Ori invokes the system linker directly:
- Linux: ld, lld, or gold
- macOS: ld64
- Windows: link.exe or lld-link

Ori never requires a C compiler for linking, only the system linker.

The result is placed in:
```ori
build/<arch>/<os>/<opt>/<module>/bin
```

---

## 330.6 Test Compilation Pipeline

Tests reuse the same compilation pipeline with these differences:
- Only files ending with `*_test.ori` are included.
- A `TestContext` type is automatically injected.
- The output binary is placed under:

```ori
build/<arch>/<os>/<opt>/<module>/tests
```

Example:
```ori
build/x86_64/linux/release/myapp/tests/myapp_tests
```

Test execution rules follow `300_TestingFramework.md`.

---

## 330.7 Extern and FFI Linking

FFI uses only the system linker. Ori's compiler:
- Does not parse C headers.
- Does not require a C compiler.
- Only links against `.o`, `.a`, `.so`, `.dylib`, `.dll` or platform equivalents.

The user must provide matching `extern` declarations according to `290_FFI.md`.
ABI mismatches are the responsibility of the programmer.

---

## 330.8 Detailed Compilation Walkthrough Example

This example shows exactly how a real Ori module is compiled.

Project structure:
```
myapp/
    ori.mod
    main.ori
    util/
        math.ori

```

Contents of ori.mod:
```
module myapp
```

`main.ori`:
```ori
package main
import "util/math"

func main() {
    var x = add(2, 3)
    println(x)
}
```

`util/math.ori`:
```ori
package math
func add(a int, b int) int {
    return a + b
}
```

**Step-by-step walkthrough**

1. Input Discovery:
  - Locate `ori.mod` → `module myapp`
  - Collect main.ori and `util/math.ori`

2. Parsing → AST:
  - ASTs generated for both files

3. Package Assembly:
  - `main.ori` → package main`
  - `util/math.ori` → `package math`

4. Import Resolution:
  - Resolve `util/math` → `<module_root>/util/math`
  - Build dependency graph: main → math

5. Type Checking:
  - Verify that `add(int, int) returns int`
  - Verify println exists in prelude or stdlib

6. Compile-Time Execution:
  - No comptime usage here

7. Monomorphization:
  - No generics involved:

8. IR Generation
  - Lower `add()` and `main()` to IR
  - Inline `add()` inside `main()` in release mode

9. Optimization:
  - Constant folding and DCE applied

10. Code Generation:
  - CPU-specific machine code emitted

11. Linking:
  - Link IR output into final executable:
    `build/x86_64/linux/release/myapp/bin/myapp`

---

## 330.9 Errors and Diagnostics

Build errors include:
- syntax errors
- semantic/type errors
- import cycle errors
- unused imports
- missing package clauses
- invalid FFI declarations
- linking errors

Diagnostic formatting is defined in `tooling/001_CompilerDiagnostics.md`.

---

## 330.10 Future Extensions

The build pipeline is designed to support:
- incremental builds
- multiple binaries per module
- build tags or conditional compilation
- dynamic linking (optional)
- stable cache formats
- parallel compilation stages
- package manager integration

These features are intentionally excluded to preserve simplicity and predictability.

---

## 330.10 Summary

Ori’s build system is:
- Whole-program compiled
- Statically linked
- Explicit and predictable
- Structured by `arch/os/opt/module`
- Simple by default
- Extensible later

The pipeline described above is authoritative for v0.9 and v1.0.

---


# 330 BuildSystemAndCompilationPipeline - Phase 2

## 1. ori mod download

- Fetch dependencies using:
  `git clone --depth=1 --branch <tag> <https-url>`
- For commits:
  `git clone --depth=1 --revision <sha> <https-url>`
- HTTPS-only, strict TLS
- Timeout: 10s, Retries: 3
- Remove `.git/`
- Sanitize according to spec
- Hash `.ori` + `ori.mod`
- Update `ori.sum` atomically

Git command is used instead of fetching tarballs because not all repository providers provides fetching tarballs.  
It's then save to use only `git clone` command

## 2. Build rules

- `ori build` NEVER downloads
- `ori build` verifies:
  - `.vendor` exists
  - Hash matches `ori.sum`
  - No unexpected vendor files
- Build fails on mismatch

## 3. Output

Same as Phase 1:
- `build/<arch>/<os>/<opt>/<module>/bin/`
- No changes

## 4. Transitive Expansion

- Dependencies’ ori.mod processed recursively
- Transitive versions may conflict only if directly imported
- All transitives must appear in `.vendor` and `ori.sum`

## 5. Hash Verification

- At build time:
  - Recompute hashes
  - Compare to `ori.sum`
  - Fail on mismatch, missing, or extra folders

## 6. Security

- No execution of dependency scripts
- No dynamic behavior
- No fallbacks
- Fully deterministic, offline builds

## 7. Error Cases

- Missing ori.mod
- ori-specified version > compiler version
- Missing vendor folder
- Checksum mismatch
- Symlink found in dependency

---


# 340. Compile-Time Reflection

This document specifies Ori’s **compile-time reflection** (CTR) system.

CTR allows *compile-time* inspection of types and limited structural validation,
without introducing:
- attributes or annotations
- runtime reflection
- macros or AST rewriting
- hidden code generation

CTR is intentionally:
- **structural** (based on the shape of types)
- **annotation-free** (no `@tag`, `@serde`, `#[repr]`, etc.)
- **compile-time only** (no runtime reflection)
- **deterministic and side-effect free**

---

## 340.1 Scope and Goals

Compile-time reflection in Ori serves three main purposes:

1. **Validation:**  
   Enforce constraints on types at compile time (e.g., "every field is exported", "no pointers in this struct", T implements interface X").

2. **Table / helper generation:**  
   Build constant tables or helper values from type structure 
   (e.g., enum → string lookup arrays).

3. **Tooling integration:**  
   Provide a foundation for tools (linters, codegen tools, docs) that can reuse
   the same structural model as the compiler.

CTR does **not** attempt to:
- replace the type system
- implement a macro system
- provide attribute-driven derives
- expose runtime layout guarantees beyond size and alignment

---

## 340.2 Non-Goals and Constraints

CTR explicitly **does not** provide:
- **Attributes or annotations.**  
  There is no `@tag`, `@serde`, `#[repr]`, `@packed`, etc.
- **Runtime reflection.**
- **I/O or side effects at compile time.**
- **AST rewriting or macro expansion.**

---

## 340.3 Building Blocks

CTR is built on three primitives:
1. The special meta-type `type` used for type parameters.
2. The built-in function:
   ```ori
   comptime func typeinfo(T type) TypeInfo
   ```
3. `comptime const` and `comptime func` declarations.

---

## 340.4 The `type` Meta-Type

`type` represents a *compile-time type token*.

Properties:
- Exists only at compile time.
- Can be passed to `typeinfo()`.
- Cannot appear in runtime values.
- Cannot cross the comptime/runtime boundary.

---

## 340.5 The `TypeInfo` Structure

CTR exposes type structure through:
```ori
type struct TypeInfo {
    kind       TypeKind
    typeName   string

    structInfo     StructInfo
    sumTypeInfo    SumTypeInfo
    enumInfo       EnumInfo
    interfaceInfo  InterfaceInfo

    arrayInfo      ArrayInfo
    sliceInfo      SliceInfo
    mapInfo        MapInfo
    hashMapInfo    HashMapInfo
    pointerInfo    PointerInfo
    sharedInfo     SharedInfo
    viewInfo       ViewInfo
    funcInfo       FuncInfo
}
```

`typeName` is the canonical human-readable name of the type.  
For anonymous or composite types (e.g., `[]int`, `map[string]User`), the compiler provides a stable generated name.
---

## 340.6 `TypeKind`

```ori
type enum TypeKind {
    Int, Float, Bool, String,
    Array, Slice,
    Struct, SumType, Enum, Interface,
    Pointer,
    Map, HashMap,
    Function,
    Shared,
    View
}
```

---

## 340.7 Metadata Records

### 340.7.1 Structs

```ori
type struct StructInfo {
    size       int
    alignment  int
    fields []FieldInfo
}

type struct FieldInfo {
    name      string
    type      type
    exported  bool
}
```

---

### 340.7.2 Sum Types

```ori
type struct SumTypeInfo {
    variants []SumTypeVariantInfo
}

type struct SumTypeVariantInfo {
    name       string
    fields     []FieldInfo
    hasPayload bool
}
```

---

### 340.7.3 Enums

```ori
type struct EnumInfo {
    size       int
    alignment  int
    variants []EnumVariantInfo
}

type struct EnumVariantInfo {
    name string
}
```

`Enum` representation is guaranteed to be a fixed-size integer chosen by the compiler (e.g. uint8/uint16/uint32 depending on number of variants).

---

### 340.7.4 Interfaces

```ori
type struct InterfaceInfo {
    methods []MethodInfo
}

type struct MethodInfo {
    name       string
    params     []type
    returns    []type
    isVariadic bool
}
```

---

### 340.7.5 Arrays

```ori
type struct ArrayInfo {
    size       int
    alignment  int
    element type
    length  int
}
```

---

### 340.7.6 Slices

```ori
type struct SliceInfo {
    element type
}
```

---

### 340.7.7 Maps & HashMaps

```ori
type struct MapInfo {
    key   type
    value type
}

type struct HashMapInfo {
    key   type
    value type
}
```

---

### 340.7.8 Pointers

```ori
type struct PointerInfo {
    size       int
    alignment  int
    target     type
}
```

---

### 340.7.9 Shared

```ori
type struct SharedInfo {
    underlying type
}
```

---

### 340.7.10 Views

```ori
type struct ViewInfo {
    underlying type
}
```

---

### 340.7.11 Functions

```ori
type struct FuncInfo {
    params     []type
    returns    []type
    isVariadic bool
}
```

---

## 340.8 Using TypeInfo

### 340.8.1 Basic Example

```ori
comptime func PrintKind[T type]() {
    comptime const info = typeinfo(T)
    println(info.kind)
}
```

---

### 340.8.2 Interface Enforcement

```ori
comptime func ensureImplements[T type, I type]() {
    if !implements(T, I) {
        comptime_error("T does not implement interface I")
    }
}
```

---

### 340.8.3 Reject Pointer Fields in a Struct

```ori
comptime func forbidPointers[T type]() {
    comptime const info = typeinfo(T)
    if info.kind != TypeKind.Struct {
        comptime_error("expected struct")
    }

    for _, f := range info.structInfo.fields {
        const finfo = typeinfo(f.type)
        if finfo.kind == TypeKind.Pointer {
            comptime_error("pointer field forbidden: " + f.name)
        }
    }
}
```

---

### 340.8.4 Require Exported Fields Only

```ori
comptime func requireExportedFields[T type]() {
    comptime const info = typeinfo(T)
    for _, f := range info.structInfo.fields {
        if !f.exported {
            comptime_error("field not exported: " + f.name)
        }
    }
}
```


---

### 340.8.5 Enum → String table

```ori
comptime func enumNames[T type]() []string {
    comptime const info = typeinfo(T)
    if info.kind != TypeKind.Enum {
        comptime_error("expected enum")
    }

    var names []string = make([]string, 0, len(info.enumInfo.variants))
    for _, f := range info.enumInfo.variants {
        names = append(names, f.name)
    }
    return names
}
```

---

### 340.8.6 Validate Sum Type Variant Payloads

```ori
comptime func ensureVariantHasPayload[T type](vname string) {
    comptime const info = typeinfo(T)
    if info.kind != TypeKind.SumType {
        comptime_error("expected sum type")
    }

    for _, f := range info.sumTypeInfo.variants {
        if f.name == vname {
            if !f.hasPayload {
                comptime_error("variant has no payload: " + vname)
            }
            return
        }
    }

    comptime_error("variant not found: " + vname)
}
```

---

### 340.8.7 Restrict Generic to Slices of Structs

```ori
comptime func ensureSliceOfStruct[T type]() {
    comptime const info = typeinfo(T)

    if info.kind != TypeKind.Slice {
        comptime_error("expected slice")
    }

    const elem = info.sliceInfo.element
    if typeinfo(elem).kind != TypeKind.Struct {
        comptime_error("expected slice of struct")
    }
}
```

---

### 340.8.8 Validate Map Key Type is Comparable

```ori
comptime func ensureComparableKey[K type]() {
    if !isComparable(K) {
        comptime_error("map key must be comparable")
    }
}
```

---

## 340.9 Purity & Error Handling

### 340.9.1 Purity

`comptime func` must be:
- deterministic
- side-effect free
- cannot perform I/O
- cannot mutate global state

---

### 340.9.2 `comptime_error`

Terminates evaluation immediately and reports an error at the call site.

```ori
comptime_error("bad type")
```

---

## 340.10 Phase Summary

### Phase 1 Provided:
- `typeinfo(T)` for structs, interfaces, sum types
- Basic `TypeKind`
- `StructInfo`, `SumTypeInfo`, `InterfaceInfo`

### Phase 2 Adds:
- Support for inspecting:
  - arrays
  - slices
  - maps
  - hashmaps
  - pointers
  - shared
  - views
  - functions
  - enums (distinct from sum types)
- Extended `TypeKind`
- `EnumInfo`
- `ArrayInfo`, `SliceInfo`, `MapInfo`, `HashMapInfo`,
  `PointerInfo`, `ViewInfo`, `FuncInfo`.
- `hasPayload` flag for sum-type variants.

---

## 340.11 Summary

Ori’s CTR system is:
- **structural** (inspect type shape)
- **annotation-free**
- **compile-time only**
- **deterministic**
- supports all major type categories in the language

CTR enables rich validation while maintaining Ori’s principles:
no macros, no attributes, no runtime reflection, no hidden behavior.

---


# 350. Enums

Enums in Ori represent a **closed set of named, symbolic variants**.  
They are implemented as **field-less sum types**, providing strong typing, exhaustive switching, and complete safety without integer representations or implicit conversions.  
Enums integrate cleanly with Ori’s type system, container model, pattern matching rules, and compile-time reflection.

---

# 350.1 Goals and Philosophy

Enums in Ori serve three purposes:
1. Represent a **small, fixed, closed set** of states or symbolic values.
2. Provide **type-safe**, **namespace-scoped** constants.
3. Enable **exhaustive** `switch` statements for correctness and clarity.

Enums are intentionally **not integer-backed**, because Ori forbids:
- implicit conversions
- fragile numeric identities
- iota-like auto-numbering
- attribute-based representation control (see `280_CompilerDirectivesAndKeywords.md`)

Enums in Ori are *pure symbolic variants* with no associated payloads.

---

# 350.2 Syntax

An enum is declared using the `type enum` form:
```ori
type enum Color =
    | Red
    | Green
    | Blue
```

Each variant:
- has no payload
- belongs to the enum’s namespace
- is a distinct constant value of the enum type

There is no support for:
- assigning explicit numeric values
- controlling representation
- attaching attributes
- bitflags or mask semantics
- payload variants (these belong to general sum types)

---

# 350.3 Type Semantics

Enums behave as **value types**:
- They occupy a small, fixed amount of memory determined by the compiler
- They have no heap allocation
- They are trivially comparable
- They are deterministic and immutable

## 350.3.1 Equality

Two enum values are equal if and only if they are the same variant:
```ori
var c Color = Color.Red
if c == Color.Red { /* true */ }
if c == Color.Green { /* false */ }
```

Enums are fully comparable and therefore **may be used as map keys** (see comparable key rules in `110_Maps.md`).

## 350.3.2 Assignment and Copying

Enums are assigned and copied by value:
```ori
var a Color = Color.Red
var b Color = a   // independent copy
```

---

# 350.4 Pattern Matching and Switch Exhaustiveness

Enums integrate directly with Ori’s `switch` semantics for sum types.

### 350.4.1 Strict Exhaustive Switch (NO DEFAULT ALLOWED)

A switch over an enum must cover all variants:
```ori
switch c {
    case Color.Red   : ...
    case Color.Green : ...
    case Color.Blue  : ...
}
```

If any variant is missing, the compiler emits a compile-time error.

---

### 350.4.2 Default Clauses Are Forbidden

Enums represent a fully known, closed set of variants.  
Allowing `default` would hide missing cases.

This is a **compile-time error**:
```ori
switch c {
    case Color.Red   : ...
    default          : ...   // ❌ forbidden for enums
}
```

This rule ensures:
- full exhaustiveness
- future-proofing when adding new enum values (all switches must update)
- clarity and safety

---

# 350.5 No Integer Representation

Enums have **no numeric form**.
Forbidden operations:
```ori
var x int = Color.Red        // ❌ no implicit or explicit conversion
var y Color = 1              // ❌ invalid enum construction
println(Color.Red + 1)       // ❌ arithmetic not allowed
```

Enums cannot be assigned numeric values, and the ordering of variants has no semantic meaning.

This avoids:
- iota-style silent shifting
- unsafe interop
- layout/ABI instability
- accidental misuse in arithmetic contexts

---

# 350.6 Interaction with Containers

Enums work naturally with all container types documented in v0.7:
## 350.6.1 Slices

```ori
var xs []Color = []Color{Color.Red, Color.Blue}
```

## 350.6.2 Arrays

```ori
var arr [3]Color = [3]Color{Color.Red, Color.Green, Color.Blue}
```

## 350.6.3 Maps (ordered)

Enums may be used as keys because they are comparable:
```ori
var m map[Color]string = make(map[Color]string)
m[Color.Red] = "stop"
m[Color.Green] = "go"
```

## 350.6.4 HashMaps (unordered)

Same rules apply:
```ori
var h hashmap[Color]int = make(hashmap[Color]int)
h[Color.Blue] = 42
```

Enums have no heap storage and therefore integrate cleanly with all ownership rules defined in `260_ContainerOwnershipModel.md`.

---

# 350.7 Deterministic Destruction

Enums have no internal resources.  
Destruction is trivial:
- they contain no handles
- they own no heap memory
- they require no cleanup logic

They behave identically to small integer-like value types in terms of destruction, but without any integer identity.

---

# 350.8 Compile-Time Reflection

Compile-time reflection does not yet expose enum metadata.  
CTR Phase 2 will allow inspecting:
- the list of variants
- the names of variants
- the parent enum type

Example:
```
comptime for v := reflect.Enum(Color).variants {
    println(v.name)
}
```

CTR does **not** expose underlying integer values because enums do not have any.

---

# 350.9 Error Conditions

The compiler must reject:

### 350.9.1 Duplicate Variant Names

```ori
type enum Status =
    | Ok
    | Ok    // ❌ duplicate
```

### 350.9.2 Missing Pipe Symbol

```ori
type enum State =
    Idle      // ❌ missing '|'
    | Running // ✔ valid
```

### 350.9.3 Unused or Unknown Enum Variant Names

Using undeclared variants is an error:
```ori
if x == Color.Purple { } // ❌ Purple not declared
```

### 350.9.4 Attempting Numeric Conversions

```ori
var n int = Color.Red // ❌ no conversion allowed
```

### 350.9.5 Instantiating Enums Incorrectly

```ori
var s State = State() // ❌ enums have no constructor
```

---

# 350.10 Examples

### Basic Enum

```ori
type enum Light =
    | Red
    | Yellow
    | Green

func action(l Light) string {
    switch l {
        case Light.Red    : return "stop"
        case Light.Yellow : return "prepare"
        case Light.Green  : return "go"
    }
}
```

### Enum as Map Key

```ori
var scores map[Level]int = make(map[Level]int)
scores[Level.Easy] = 10
scores[Level.Hard] = 50
```

### Enum in Array

```ori
var seq [3]Light = [3]Light{Light.Red, Light.Green, Light.Red}
```

---

# 350.12 Summary

Enums in Ori are:
- **field-less sum types**
- **type-safe**, **comparable**, **hashable**
- **exhaustively switchable**
- **non-numeric**, **non-represented**
- **consistent with all ownership and container rules**
- **free of attributes or iota-like semantics**

This design ensures long-term safety and clarity.

---


# 360. StringBuilder

## 360.1 Overview

`StringBuilder` is a mutable, growable text builder type provided by the Ori standard library.  
It is designed for efficient construction of `string` values without creating many intermediate temporary strings.

`StringBuilder`:
- owns a growable `[]byte` buffer internally
- supports appending textual data (strings and bytes)
- can be reset and reused
- produces immutable `string` values via `String()`

It follows the same ownership, aliasing, and deterministic destruction rules as other Ori containers described in `260_ContainerOwnershipModel.md`.

`StringBuilder` lives in the standard library (for example, in a `strings`-like package), but this document specifies its language-level semantics.

---

## 360.2 Type Definition and Invariants

The core definition of `StringBuilder` is:
```ori
type struct StringBuilder {
    buf []byte   // unexported; may be nil or a valid slice
}
```

### 360.2.1 Invariants

At all times, a `StringBuilder` value obeys the following invariants:
- `buf` is either:
  - `nil`, meaning the builder is empty and has no allocated storage yet, or
  - a valid `[]byte` slice whose elements are initialized bytes
- `len(buf)` is the number of bytes currently in the builder
- `cap(buf)` is the capacity of the builder’s internal buffer
- The first `len(buf)` bytes of `buf` represent the logical contents of the builder
- Operations on a builder never expose uninitialized bytes

`StringBuilder{}` is the canonical empty builder:
```ori
var b StringBuilder = StringBuilder{}  // ✔ empty, valid, buf == nil
```

Declaring a StringBuilder without explicit initialization is a compile-time error:
```ori
var b StringBuilder   // ❌ compile-time error (struct must be explicitly initialized)
```

The literal `StringBuilder{}` uses the default value nil for the internal []byte field,
and the first write to the builder allocates internal storage as needed.

---

## 360.3 Construction

### 360.3.1 Zero-Value Construction

The simplest way to obtain a builder is to explicitly initialize it:
```ori
var b StringBuilder                   // compile-time error
var b StringBuilder = StringBuilder{} // empty, valid
b.WriteString("hello")
```

The zero value must behave identically to a builder obtained from any constructor.

### 360.3.2 Explicit-Capacity Constructors (Standard Library)

The standard library may provide helper constructors such as:
```ori
// In a standard library package, conceptually:
func NewStringBuilder() StringBuilder
func NewStringBuilderWithCap(cap int) StringBuilder
```

Semantics:
- `NewStringBuilder()` returns an empty builder with unspecified initial capacity.
- `NewStringBuilderWithCap(cap int)` returns an empty builder with at least `cap` bytes of capacity.
  - If `cap < 0`, the function must panic with a clear error message.

These helpers are library-level conveniences and do not introduce new language syntax.

---

## 360.4 Methods and Signatures

All mutating methods on `StringBuilder` use a **`shared` receiver** to reflect Ori’s container semantics and make aliasing explicit.

### 360.4.1 WriteString

```ori
func (b shared StringBuilder) WriteString(s string)
```

Appends the contents of `s` to the builder.

Semantics:
- If `len(s) == 0`, the method does nothing.
- If `len(buf) + len(s) <= cap(buf)`, the existing buffer is reused.
- Otherwise, a new backing buffer is allocated with greater capacity, existing bytes are copied, and `buf` is updated to reference the new storage.
- No trailing NUL byte is added; the builder stores raw bytes.

### 360.4.2 WriteByte

```ori
func (b shared StringBuilder) WriteByte(c byte)
```

Appends the single byte `c` to the builder.

Semantics:
- Equivalent to `WriteBytes([]byte{c})` but may be more efficient.
- Grows the buffer as needed using the same rules as `WriteString`.

### 360.4.3 WriteBytes

```ori
func (b shared StringBuilder) WriteBytes(data []byte)
```

Appends the contents of `data` to the builder.

Semantics:
- If `len(data) == 0`, the method does nothing.
- Appends the bytes of `data` exactly, without copying or modifying `data` itself.
- Allocation and growth follow the same rules as `WriteString`.

### 360.4.4 Reset

```ori
func (b shared StringBuilder) Reset()
```

Resets the builder to be empty.

Semantics:

- After `Reset()`, `len(b.buf) == 0`.
- Implementations **may** keep the current capacity to allow reuse:
  - `cap(b.buf)` is implementation-defined but typically unchanged.
- The contents of any previously returned `string` values remain valid and are not affected by `Reset()`.

### 360.4.5 Len

```ori
func (b StringBuilder) Len() int
```

Returns the number of bytes currently stored in the builder.

Semantics:
- `Len()` is pure and does not modify the builder.
- `Len()` always equals `len(b.buf)`.

### 360.4.6 Cap

```ori
func (b StringBuilder) Cap() int
```

Returns the capacity of the builder’s internal buffer.

Semantics:
- `Cap()` is pure and does not modify the builder.
- `Cap()` always equals `cap(b.buf)` when `buf` is non-nil; for a zero-value builder, `Cap()` returns `0`.

### 360.4.7 Grow

```ori
func (b shared StringBuilder) Grow(n int)
```

Ensures that the builder can append at least `n` additional bytes without further allocation.

Semantics:
- If `n <= 0`, `Grow` does nothing.
- Otherwise, it ensures that `cap(b.buf) - len(b.buf) >= n`.
- If the current capacity is already sufficient, no allocation occurs.
- If `n` is too large to satisfy due to implementation limits, `Grow` must panic with a clear error.

`Grow` is an optimization; it does not change `Len()`.

### 360.4.8 String

```ori
func (b shared StringBuilder) String() string
```

Returns a `string` containing a copy (or immutable view) of the builder’s contents.

Semantics:
- The returned `string` contains the bytes of `b.buf[0:len(b.buf)]` interpreted as UTF‑8 (or raw bytes if the caller
  uses the builder for non-text data).
- Future writes to `b` do **not** modify previously returned strings.
- Implementations are free to reuse internal buffers where safe, but must preserve the immutability guarantees of `string`.

---

## 360.5 Ownership, Aliasing, and Deterministic Destruction

`StringBuilder` follows the general container rules from `260_ContainerOwnershipModel.md`:

### 360.5.1 Handle + Backing Storage

- A `StringBuilder` value is a small handle (struct) that contains a `[]byte` field.
- The `[]byte` slice itself is a handle to heap-allocated backing storage for the builder’s bytes.
- Copying a `StringBuilder` value copies the slice handle; backing storage is shared between copies.

Example:
```ori
var a StringBuilder = StringBuilder{}
a.WriteString("hello")

var b = a      // b aliases the same internal buffer as a
b.WriteByte('!')

// Now both a and b logically contain "hello!" because they share `buf`.
```

### 360.5.2 Cloning

If an independent builder is required, the caller must clone explicitly:
```ori
func CloneBuilder(src StringBuilder) StringBuilder {
    var out StringBuilder = StringBuilder{}
    if src.Len() == 0 {
        return out
    }

    // allocate an independent buffer
    outBuf := make([]byte, src.Len())
    copy(src.buf, outBuf)
    out.buf = outBuf
    return out
}
```

The standard library may provide such a helper, but cloning is deliberately explicit.

### 360.5.3 Deterministic Destruction

When the last live `StringBuilder` handle referencing a given backing buffer is destroyed:
- The backing buffer is deallocated according to the same rules as any `[]byte` slice
- Elements (bytes) do not have destructors, so destruction is constant-time
- All previously returned `string` values are unaffected, as they are immutable and may use independent storage

Builders stored inside other structs or containers are destroyed as part of those owners’ deterministic destruction
sequence, as specified in `220_DeterministicDestruction.md`.

---

## 360.6 Interaction with `string` and `[]byte`

### 360.6.1 From Builder to String

`String()` is the canonical way to obtain a `string` from a builder.

- Multiple calls to `String()` are allowed.
- Each call returns a `string` that is logically independent of future mutations of the builder.
- Implementations may share storage internally as long as no mutation of the builder can affect any existing `string`.

### 360.6.2 Using Builder as a Byte Buffer

Although intended for textual data, `StringBuilder` can also be used as a generic byte accumulator.

Example:
```ori
var b StringBuilder = StringBuilder{}
b.WriteBytes([]byte{0x01, 0x02, 0x03})
b.WriteByte(0xFF)
```

The semantics are identical; `String()` will interpret the bytes as they are.

### 360.6.3 No Direct `Bytes()` View

Ori does **not** provide a `Bytes()` method that returns a `[]byte` view of the builder’s internal buffer.
This avoids subtle aliasing and mutation pitfalls where callers could hold onto a slice that becomes invalid when the builder grows or is reset.

If a byte slice is needed, the caller can copy explicitly:
```ori
var data []byte = make([]byte, b.Len())
copy(b.buf, data)   // library helper may be provided
```

A future version may introduce a `BytesCopy()` helper that returns a copied `[]byte`.

---

## 360.7 Concurrency

`StringBuilder` is **not** intrinsically thread-safe:
- A builder must not be mutated concurrently from multiple tasks without synchronization
- To share a builder across tasks, it must be declared `shared` and protected by a mutex or other synchronization primitive, following the same rules as other containers
- It is safe to read from a builder (via `Len()`, `Cap()`, `String()`) while no concurrent writes are occurring

Example (invalid):
```ori
func worker(b StringBuilder) {
    b.WriteString("x")   // ❌ concurrent mutation without synchronization
}

func test() {
    var b shared StringBuilder = StringBuilder{}
    t := spawn_task worker(b)
    result, err := t.Wait()
}
```

Example (valid, conceptually):
```ori
func worker(b StringBuilder) {
    var mu sync.Mutex
    mu.Lock()
    b.WriteString("x")
    mu.Unlock()
}

func test() {
    var b shared StringBuilder = StringBuilder{}
    t := spawn_task worker(b)
    result, err := t.Wait()
}
```

The exact synchronization primitives are defined elsewhere in the standard library, but the general rule remains:
`StringBuilder` obeys the same concurrency constraints as other mutable containers.

---

## 360.8 Examples

### 360.8.1 Basic Usage

```ori
func BuildGreeting(name string) string {
    var b StringBuilder = StringBuilder{}

    b.WriteString("Hello, ")
    b.WriteString(name)
    b.WriteString("!")

    return b.String()
}
```

### 360.8.2 Reuse with Reset

```ori
func DemoReuse() {
    var b StringBuilder = StringBuilder{}

    b.WriteString("first")
    s1 := b.String()

    b.Reset()
    b.WriteString("second")
    s2 := b.String()

    // s1 == "first"
    // s2 == "second"
}
```

### 360.8.3 Explicit Growth

```ori
func BuildMany(names []string) string {
    var b StringBuilder = StringBuilder{}

    // Reserve a rough capacity to avoid repeated allocations.
    // For example, assume ~16 bytes per name.
    b.Grow(len(names) * 16)

    for i, name := range names {
        if i > 0 {
            b.WriteString(", ")
        }
        b.WriteString(name)
    }

    return b.String()
}
```

### 360.8.4 Aliasing Behavior

```ori
func DemoAlias() {
    var a StringBuilder = StringBuilder{}
    a.WriteString("x")

    var b = a       // a and b alias the same buffer
    b.WriteString("y")

    s1 := a.String()
    s2 := b.String()

    // Both s1 and s2 are "xy".
}
```

---

## 360.9 Summary

- `StringBuilder` is a standard library struct that owns a growable `[]byte` buffer
- StringBuilder{} represents an empty builder.
- Declaring a StringBuilder without initialization is a compile-time error (per 130_Structs.md).
- Mutating methods use a `shared StringBuilder` receiver and follow Ori’s container semantics
- `String()` produces immutable `string` values that are not affected by subsequent mutations
- Ownership, aliasing, and deterministic destruction mirror the general container rules
- No `Bytes()` view is provided to avoid aliasing pitfalls; callers copy explicitly when needed
- `StringBuilder` is not thread-safe by default and must be synchronized when shared across tasks

---


# 370. File System And IO Semantics

This document defines the **language-level semantics and constraints** around file system access and blocking IO in Ori.  
It does *not* freeze the standard library API surface; instead, it describes the guarantees that any `os`-level file and IO APIs must respect.

The concrete API surface of the `os` package (types, functions, examples) is specified separately in `ecosystem/001_OS.md`.
This separation keeps language semantics stable while allowing the standard library to evolve.

**Depends on:**
- `140_Errors.md` (builtin `Error` type and error handling model)  
- `220_DeterministicDestruction.md` (resource lifetimes and destructors)  
- `ecosystem/001_StandardLibraryFoundations.md` (package responsibilities and boundaries)  
- `ecosystem/001_OS.md` (concrete `os` API specification)

---

## 370.1 Goals

The semantics of file system and IO in Ori are guided by the following goals:

1. **Deterministic ownership of OS resources**  
   Types that represent OS-backed resources (such as files) must be value types with deterministic destruction.  
   There is no GC-based finalizer magic for closing files or flushing buffers.

2. **Blocking, explicit IO**  
   v0.11 defines **blocking**, **byte-oriented** IO.  
   There is no async/await, no non-blocking primitives, and no background threads started implicitly by the language.

3. **Clear error reporting**  
   All file system and IO operations must use the builtin `Error` type for failures.  
   Errors are never silently ignored by the language.

4. **No hidden buffering or extra threads**  
   The language semantics forbid implicit background tasks and hidden buffers.  
   Higher-level packages (e.g. buffered IO, async executors) must be explicit about any such behavior.

5. **Separation of semantics and API**  
   This document focuses on *what must be true* of file system and IO behavior.  
   The concrete functions, types, and helpers are described in `ecosystem/001_OS.md` and may evolve across versions.

---

## 370.2 OS-Backed Resource Types

### 370.2.1 Owning handle semantics

Any type that represents an OS-backed resource such as a file descriptor, socket, or similar handle **must**:

- be a value type with a single clear owner at any point in time
- be **move-only** (no implicit copying of ownership)
- integrate with deterministic destruction (see `220_DeterministicDestruction.md`)
- never rely on a garbage collector or hidden finalizer for cleanup

The canonical example is the `os.File` type specified in `ecosystem/001_OS.md`.

---

### 370.2.2 Destructors for IO resources

For any such resource type `R`, the destructor:

- is executed exactly once when the value's lifetime ends
- must **not panic**
- must **not perform unbounded blocking operations**
- performs a single best-effort close of the underlying OS resource

If the underlying OS close operation can fail, that failure **cannot** be surfaced from the destructor.  
There is no mechanism for propagating `Error` from destructors.  
To handle close errors, user code must call an explicit `Close()`-style method prior to scope exit.

---

### 370.2.3 Shared receivers for mutation

Methods that mutate the internal state of an IO resource value must use a **shared receiver**:

```ori
func (f shared File) Close() Error
```

This ensures:
- mutation is only allowed when the value is explicitly marked as shared
- aliasing and ownership rules remain explicit
- it is impossible to mutate a non-shared value in place

Pointer-based receivers (e.g. `*File`) must not be used as the primary mechanism for resource mutation.  
Ownership must flow through value semantics and the `shared` marker, not raw pointers.

---

## 370.3 Blocking IO Semantics

### 370.3.1 Blocking behavior

All built-in file and IO operations in v0.11 are **blocking**:
- A call to a read/write/seek/sync/stat operation may block the current task until the operation completes or fails.
- The language does not introduce any background tasks or async scheduler for these operations themselves.

Higher-level libraries or executors may provide non-blocking or async semantics in future versions, but those are explicitly outside the scope of v0.11 semantics.

---

### 370.3.2 Byte-oriented IO

At the semantics level, IO operates on **raw bytes**:

- All file and IO operations work on `[]byte` slices or similar raw byte types
- Text encoding, decoding, normalization, and Unicode-specific behavior are the responsibility of higher-level packages
- The IO semantics do not assume or enforce any particular text encoding

Future documents (e.g. a UTF-8 and text model spec) may define how strings and text interact with IO, but they do not change the base assumption that IO is byte-oriented.

---

## 370.4 Error Handling

### 370.4.1 Use of builtin `Error`

All fallible IO operations must use the builtin `Error` type defined in `140_Errors.md`.

At the semantics level, that implies:
- A successful IO operation returns a `nil` error
- A failed IO operation returns a non-`nil` error whose `Code` and `Message` are meaningful and stable within a given Ori version
- Sentinel `Error` values (e.g. `ErrNotFound`, `ErrClosed`, `ErrEOF`) can be compared using `==` and must behave consistently across platforms

The language does not introduce any special case for IO errors; they are regular `Error` values, subject to the same conventions as all other errors.

---

### 370.4.2 End-of-file semantics

The semantics of end-of-file (EOF) are standardized for all file-like IO:
- A read operation that reads **zero bytes** and encounters EOF must report a specific EOF error (e.g. `ErrEOF`)
- A read operation that reads **some bytes** and then hits EOF may return the bytes and report success; the EOF is then observed on the next call

The exact sentinel value and naming are specified in `ecosystem/001_OS.md`, but the behavior is part of the language's IO semantics.

### 370.4.3 Close errors and destructors

If an explicit `Close()` method is provided on an IO resource type:
- it may return a non-`nil` `Error` if the OS reports a failure on close
- it must be idempotent: calling it multiple times must not panic

If user code never calls `Close()`, the destructor must still close the underlying resource best-effort, but any OS-level error from that close is ignored and not reported.  
This is a deliberate trade-off to keep destructors panic-free and predictable.

---

## 370.5 Standard Streams

The process-wide standard streams (`stdin`, `stdout`, `stderr`) are special OS resources provided by the host environment.

Semantically:
- Their lifetime is managed by the operating system, not by user code
- They must not be automatically closed by regular destruction logic at program exit in a way that surprises user code
- Any `os`-level wrappers around these streams must make it clear whether they own the underlying descriptor or are non-owning views

A typical approach (described in `ecosystem/001_OS.md`) is to expose constructors like `os.Stdin()`, `os.Stdout()`, and `os.Stderr()` that return `File` values which:
- behave like regular file-like handles for read/write operations
- do **not** own the underlying OS standard streams for the purpose of destruction
- have destructors that are no-ops with respect to the underlying OS handles
- provide a `Close()` method that either returns a well-defined `ErrInvalidOperation` or is a documented no-op

This semantics document does not mandate the exact API shape, but it requires that:

- destructors for wrapper types must not attempt to close OS-managed standard streams implicitly;
- closing or not closing the wrapper must never introduce undefined behavior in the runtime.

---

## 370.6 Concurrency and IO

### 370.6.1 Task-level blocking

In the concurrency model defined by `190_Concurrency.md`, a task that performs a blocking IO operation is simply **blocked** until the operation completes.

The language semantics guarantee that:
- there is no automatic spawning of helper tasks to offload blocking IO;
- there is no implicit cooperative scheduling added by IO operations themselves.

An implementation may choose to use OS threads or other techniques to avoid blocking entire processes, but this is an implementation detail and must not change the visible blocking behavior of the calling task.

---

### 370.6.2 Thread-safety of IO resource types

The semantics do **not** require that `File`-like types be safe for concurrent use from multiple tasks without synchronization.

Instead:
- it is legal for an implementation to document `File` as **not thread-safe**;
- users who need to share IO resources between tasks must wrap them in synchronization primitives (e.g. a `Mutex`).

The `os` package documentation (ecosystem spec) must explicitly document whether its IO types are safe for concurrent use.

---

### 370.6.3 Destructors under concurrency

Because destructors run automatically at end-of-scope, the following constraints apply:

- Destructors must not assume there are no concurrent accesses to the resource; any such assumptions must be enforced at the type level or by user code.
- Destructors must not block indefinitely waiting for other tasks to finish; they should perform a single close operation and return.

This ensures that deterministic destruction remains predictable even in the presence of concurrent tasks.

---

## 370.7 File Modes and Octal Notation (Forward Compatibility)

In Unix and Linux environments, file permissions are commonly represented using **octal notation** such as `0o755` or `0755`.

Ori v0.11 does **not yet** define octal integer literals in the core language, but:
- The semantics of `FileMode` assume that it can represent permission bits that conceptually correspond to Unix-style rwx flags
- The `os` package examples (e.g. in `ecosystem/001_OS.md`) may use notation like `0o755` to describe typical permission patterns

This notation is considered **forward-looking and illustrative**:
- It indicates that future versions of Ori are expected to support octal literals (for example, with a `0o` prefix), because it is a familiar convention for file modes.
- Until octal literals are formally added to the language, such examples should be understood as conceptual and not literally valid Ori code in current version.

Standard library specs must clearly document when an example uses a future literal feature, so that implementations and users do not misinterpret it as currently-supported syntax.

---

## 370.8 Relationship to `ecosystem/001_OS.md`

This semantics document and `ecosystem/001_OS.md` are meant to be read together:

- `370_FileSystemAndIO.md` defines **what must be true** of file system and IO behavior in any conforming Ori implementation.
- `ecosystem/001_OS.md` defines **how the `os` package exposes these behaviors** via concrete types and functions.

If a future version changes the `os` API shape, this semantics document should remain largely valid, as long as:
- IO resources remain value-typed, move-only, and destructor-backed
- errors continue to use the builtin `Error` type
- IO operations remain explicitly blocking or non-blocking according to clearly documented rules
- octal file mode notation is eventually supported in a way that is consistent with the semantics described here.

---


# 380 Logging Framework - Phase 1

This document specifies the semantics and core APIs of the Ori logging framework.  
It defines log levels, log record structure, concurrency guarantees, interaction with deterministic destruction, and fatal error handling.

Logging is a **library-level facility**, not a language feature. It must obey the general principles defined in:
- `001_LanguagePhilosophy.md`
- `002_TypeSafetyAndExplicitness.md`
- `005_ConcurrencyAndPredictability.md`
- `150_TypesAndMemory.md`
- `190_Concurrency.md`
- `220_DeterministicDestruction.md`
- `330_BuildSystemAndCompilationPipeline_Phase1/2.md`

This file focuses on **semantics** and **expected behavior**, not on a particular implementation or performance tuning.

---

## 380.1 Goals and Non‑Goals

### 380.1.1 Goals

The Ori logging framework MUST:

1. Provide a small, explicit, and predictable API for application and library logging.
2. Support **structured logging** (key/value pairs), not printf-style formatting.
3. Be **safe to use concurrently** from multiple tasks by default.
4. Integrate correctly with deterministic destruction (`220_DeterministicDestruction.md`),
   without relying on it for fatal shutdown paths.
5. Provide a well‑defined **Fatal** behavior: log the entry, flush if applicable, then terminate the process with exit code `1`.
6. Require **no global mutable state**; multiple loggers can coexist independently.
7. Be usable consistently by:
   - application code
   - libraries
   - the testing framework (`300_TestingFramework_Phase1/2.md`)
   - the build system and tooling (`330_BuildSystemAndCompilationPipeline_Phase1/2.md`).

### 380.1.2 Non‑Goals

The logging framework does **not** attempt to:
1. Provide a printf-style formatting language (no `%d`, `%s`, `%v`, etc.).
2. Perform runtime reflection for automatic struct or object serialization.
3. Implement asynchronous logging (log queues, background tasks). This may be added
   later as a separate `AsyncLogger` type in a future version.
4. Provide transport-specific features (e.g. log shipping, remote ingestion).
5. Guarantee persistence to disk or durable storage; logging is best effort.

---

## 380.2 Terminology

- **Log level**: a severity classification for a log record (`Debug`, `Info`, `Warn`, `Error`, `Fatal`).
- **Log record**: a single log event with a level, message, timestamp, and fields.
- **Field**: a key/value pair attached to a log record.
- **Writer**: an abstraction that receives the serialized log record bytes.
- **Flush**: operation that pushes any buffered log data to the underlying sink.
  Flush **does not** guarantee persistence to disk.

Unless otherwise stated, “task” refers to Ori’s concurrency unit as described in `190_Concurrency.md`.

---

## 380.3 Log Levels

### 380.3.1 Enumeration

Log levels are represented as a simple enumeration:

```ori
type enum LogLevel {
    Debug
    Info
    Warn
    Error
    Fatal
}
```

The ordering is, from least to most severe:
```text
Debug < Info < Warn < Error < Fatal
```

### 380.3.2 Meaning

- `Debug`: Diagnostic information, typically disabled in production.
- `Info`: Important high-level events in normal operation.
- `Warn`: Suspicious or unexpected events that do not prevent progress.
- `Error`: Failures that affect behavior or requests but allow the process to continue.
- `Fatal`: An unrecoverable condition after which the process **must exit**.

### 380.3.3 Level Filtering

Each logger instance has a minimum level:
- Records with `record.level < logger.level` MUST be skipped.
- Skipped records MUST NOT perform any formatting, allocation, or I/O.

The goal is to make disabled logging as close to zero‑cost as possible.

---

## 380.4 Log Record Model

### 380.4.1 Log Record Fields

A log record conceptually contains at least:
- `level: LogLevel`
- `time: Time` (seminantics defined in ecosystem/003_Time.md)
- `message: string`
- `fields: list of (key string, value any)`
- optional logger metadata (e.g. fixed prefix, logger name)

This specification does not mandate a concrete in‑memory representation. Implementations are free to use stack allocations, pre‑allocated buffers, or other techniques, as long as they preserve observable behavior.

### 380.4.2 Structured Logging (Key/Value Pairs)

Structured logging uses key/value pairs:
```ori
logger.Info("server started",
    "port", port,
    "secure", isTLS,
    "clients", clientCount,
)
```

Rules:
1. Keys MUST be strings. Implementations may enforce this at compile time or runtime.
2. Values MAY be any type (`any`), but must be serializable into some textual representation.
3. The order of fields MUST be preserved as provided by the caller.
4. Keys need not be unique, but callers SHOULD avoid duplicates.

Implementations are free to choose the underlying serialization format, as long as
the observable behavior matches the configured output mode.

### 380.4.3 Output Formats

At minimum, two output formats SHOULD be supported by the standard logging library:

1. **Human-readable**:
   - ISO8601 timestamp
   - level name
   - message
   - key/value pairs

   Example (illustrative only):
   ```text
   2025-12-03T10:04:11Z INFO server started port=8080 clients=4
   ```

2. **JSON**:
   - Single line per record
   - Deterministic key order
   - No reflection-based magic

   Example (illustrative only):
   ```json
   {"time":"2025-12-03T10:04:11Z","level":"INFO","msg":"server started","port":8080,"clients":4}
   ```

The choice of format is a construction‑time decision (e.g. `NewLogger` vs `NewJSONLogger`).
This semantic file does not fix API names, only required behavior.

---

## 380.5 Writer Abstractions

### 380.5.1 Writer Interface

Loggers send serialized log records to a `Writer`:
```ori
type interface Writer {
    Write(buf []byte) (int, error)
}
```

Rules:
1. `Write` MUST attempt to write all bytes in `buf`.
2. On success, it returns `(len(buf), nil)`.
3. On partial write, it returns `(n, error)` with `0 <= n < len(buf)`.
4. On failure without any bytes written, it returns `(0, error)`.

Loggers MUST treat partial writes and non‑nil errors as write failures.
How failures are handled is defined in `380.10`.

### 380.5.2 Flusher Interface

Some writers buffer data internally and support explicit flushing.

Ori defines a **public**, but minimal, interface for this capability:
```ori
type interface Flusher {
    Flush() error
}
```

Rules:
1. `Flush` MAY be a no‑op for unbuffered writers.
2. `Flush` MUST NOT guarantee durable persistence to disk. It only guarantees that
   buffered data is pushed to the underlying sink.
3. The logging framework **does not** require callers to invoke `Flush` directly.
   Instead, loggers call `Flush` internally when appropriate (e.g. on `Fatal`).

Custom writers MAY implement `Flusher` to participate in flush semantics.

---

## 380.6 Logger Type and Concurrency Semantics

### 380.6.1 Conceptual Logger Type

A canonical logger has at least the following conceptual shape:
```ori
type struct Logger {
    mu          Mutex        // protects all internal state
    writer      Writer
    level       LogLevel
    timeFn      func() Time  // injected clock function
    prefix      string       // optional static prefix
    ownsWriter  bool         // participates in deterministic destruction
    exitFn      func(int)    // injected exit function for Fatal
    // optional: error tracking, output mode, etc.
}
```

This structure is illustrative. Implementations MAY use different internal layouts as long as the observable semantics described in this file are preserved.

### 380.6.2 Thread Safety (Tasks)

A `Logger` MUST be safe to use concurrently from multiple tasks by default:
- Calls to logging methods (Debug, Info, Warn, Error, Fatal) MUST NOT race internally.
- Log lines MUST NOT interleave or corrupt each other at the byte level.
- Each call to a logging method MUST produce an indivisible log record in the output.

The usual way to achieve this is to guard logging operations with an internal `Mutex` (see `190_Concurrency.md`). Alternatives (per‑record allocation, lock-free queues, etc.)
are allowed as long as they preserve the same observable behavior.

> **Note:** Writers themselves are **not** required to be thread-safe. The logger’s
> internal synchronization is responsible for serializing access to the `Writer`.

---

## 380.7 Logger Construction

### 380.7.1 Construction Parameters

The canonical construction function has the following conceptual signature:

```ori
func NewLogger(
    writer Writer,
    level LogLevel,
    timeFn func() Time,
    exitFn func(int),
) Logger
```

Rules:
1. `writer` MUST NOT be nil.
2. `level` controls the minimum level that will be emitted (see 380.3.3).
3. `timeFn` is a clock function returning a `Time` value (see `ecosystem/003_Time.md`).
   - In typical code this will be `time.Now`.
   - Tests may inject a deterministic or fake clock.
4. `exitFn` is a function used by `Fatal` to terminate the process.
   - In typical code this will be `os.Exit` (from the `os` package).
   - Tests may inject a function that panics or records the exit code instead of
     actually terminating the process.

### 380.7.2 Ownership Flag

Construction may also define whether the `Logger` **owns** its writer:

- If `ownsWriter == true`, the logger participates in deterministic destruction
  (see 380.9).
- If `ownsWriter == false`, the logger must **not** close or destroy the writer.

The exact mechanism for setting `ownsWriter` is implementation-specific (e.g.
separate constructors).

---

## 380.8 Logging Methods

### 380.8.1 Method Set

At minimum, a `Logger` MUST provide the following methods:
```ori
func (l *Logger) Debug(msg string, fields ...any)
func (l *Logger) Info(msg string, fields ...any)
func (l *Logger) Warn(msg string, fields ...any)
func (l *Logger) Error(msg string, fields ...any)
func (l *Logger) Fatal(msg string, fields ...any) // see 380.8.4
```

All methods:
1. MUST be safe to call concurrently from multiple tasks.
2. MUST NOT panic under normal circumstances.
3. MUST NOT return errors to the caller. Logging APIs are fire‑and‑forget from
   the caller’s perspective; error handling is described in `380.10`.

The `fields` parameters represent key/value pairs as described in `380.4.2`.
Implementations SHOULD validate that the number of fields is even and SHOULD handle malformed input in a predictable way (e.g. ignore the trailing value).

### 380.8.2 Level Filtering

Each method MUST perform a level check before allocating or formatting:
- `Debug` emits only when `LogLevel.Debug >= logger.level`.
- `Info` emits only when `LogLevel.Info >= logger.level`.
- `Warn` emits only when `LogLevel.Warn >= logger.level`.
- `Error` emits only when `LogLevel.Error >= logger.level`.
- `Fatal` always emits if called; level filtering does not apply to `Fatal`.

If a record is filtered out, the method MUST return immediately without:
- allocating memory for formatting,
- writing to the writer,
- or producing side effects.

### 380.8.3 Example Usage

```ori
var logger = NewLogger(
    writer: fileWriter,
    level: LogLevel.Info,
    timeFn: time.Now,
    exitFn: os.Exit,
)

logger.Info("server started",
    "port", port,
    "secure", isTLS,
)

logger.Warn("high memory usage",
    "bytes", memUsage,
)

logger.Error("failed to reload config",
    "file", path,
    "err", err,
)
```

### 380.8.4 Fatal Semantics

`Fatal` is reserved for unrecoverable conditions. Its behavior is strictly defined:
```ori
func (l *Logger) Fatal(msg string, fields ...any)
```

MUST perform, in order:
1. Construct the log record with level `LogLevel.Fatal`.
2. Serialize and write the log record to `l.writer`.
3. If `l.writer` implements `Flusher`, call `Flush()`:
   - Any error from `Flush` is ignored for the purpose of control flow.
   - Implementations MAY record the flush error internally.
4. Call `l.exitFn(1)` to terminate the process with exit code `1`.

Rules:
1. `Fatal` MUST NOT return to the caller in normal execution.
2. `Fatal` MUST be safe to call concurrently with other logging methods. Once
   `exitFn` is called, the process terminates and further behavior is undefined.
3. `Fatal` MUST NOT rely on deterministic destructors to flush or close writers.
   The explicit flush in step (3) is the only guarantee of delivery.

> **Testing note:** In tests, users SHOULD inject an `exitFn` that does not
> terminate the process (e.g. a function that panics with a sentinel value).
> This allows tests to assert on fatal behavior. See `380.11.2`.

---

## 380.9 Deterministic Destruction Integration

### 380.9.1 Logger Lifetime

When a `Logger` instance reaches its deterministic destruction point (see `220_DeterministicDestruction.md`), the following semantics apply:
1. If `ownsWriter == true`, the logger MUST perform any cleanup required to release the writer. For file writers, this ypically involves closing the underlying file handle.
2. If `ownsWriter == false`, the logger MUST NOT close or destroy the writer.

The exact mechanism for resource release (e.g. `Close` methods) is defined by the corresponding writer types and their semantics, not by this file.

### 380.9.2 Interaction with Fatal

`os.Exit` and other process‑terminating mechanisms **do not** trigger deterministic destruction.  
Therefore:
- When `Fatal` calls `exitFn(1)`, destructors for `Logger` and its writer are not guaranteed to run.
- The only flushing guarantee for fatal records is the explicit flush described in `380.8.4`.

Documentation for the logging library MUST state this clearly.

---

## 380.10 Error Handling in Logging

### 380.10.1 No Error Returns

Logging methods (`Debug`, `Info`, `Warn`, `Error`, `Fatal`) MUST NOT return errors.
The primary reasons are:
- Logging is typically non‑critical and should not clutter control flow with error handling.
- Errors while logging usually indicate underlying I/O issues that require higher-level handling (e.g. health checks, telemetry), not per‑call handling.

### 380.10.2 Internal Error Recording

Implementations MAY record the last write or flush error internally, for example:
```ori
func (l *Logger) LastError() error
```

If such an accessor is provided, the following rules apply:
1. It MUST be safe to call concurrently.
2. It MUST NOT panic.
3. It MUST return `nil` if no error has been observed since construction or since the last reset (if resetting is supported).

### 380.10.3 Error Callbacks

Implementations MAY also support an optional error callback that is invoked when a write or flush error occurs.  
Such callbacks:
1. MUST be invoked synchronously from the logging method that observes the error.
2. MUST NOT themselves call logging methods on the same logger (to avoid cycles).
3. MUST be documented as advanced usage.

This specification does not require error callbacks; they are an allowed extension.

---

## 380.11 Testing Considerations

### 380.11.1 Injected Clocks

By injecting `timeFn` into `NewLogger`, tests can:
- Use deterministic timestamps.
- Avoid relying on wall‑clock time.

This is consistent with `003_Time.md` and `300_TestingFramework_Phase1/2.md`.

### 380.11.2 Testing Fatal Behavior

In tests, `exitFn` MUST be overridden to avoid terminating the test process:
```ori
func testExit(code int) {
    panic(TestExit{code: code})
}

func TestFatalLogging(t *TestContext) {
    var logger = NewLogger(
        writer: testWriter,
        level: LogLevel.Debug,
        timeFn: fakeTime.Now,
        exitFn: testExit,
    )

    t.ExpectPanic(TestExit{code: 1}, func() {
        logger.Fatal("boom")
    })

    // Assert that testWriter received the fatal record.
}
```

This pattern allows unit tests to:
1. Verify that `Fatal` logs a record.
2. Verify that `Fatal` terminates with the expected exit code.
3. Avoid hard‑wiring `os.Exit` into test processes.

### 380.11.3 Capturing Logs in Tests

The testing framework or test helpers MAY provide a dedicated `TestWriter` that:
- Stores log records in memory.
- Implements `Writer` (and optionally `Flusher`).
- Allows tests to assert on captured records (messages, levels, fields).

The semantics of such test‑only components are outside the scope of this file but MUST respect the contracts defined in `380.5`.

---

## 380.12 Future Extensions (Non‑Normative)

The following features are explicitly left for future versions:

1. **AsyncLogger**  
   A logger implementation that uses a background task and a bounded queue to decouple log call latency from I/O latency. It MUST preserve structured record semantics and level filtering rules.

2. **Context‑Enriched Loggers**  
   Helper APIs for deriving loggers with additional fixed fields (e.g. component or request identifiers). These would produce child loggers that reuse the same underlying writer and exit function but prepend fields or prefixes.

3. **Per‑module or per‑package logging configuration**  
   Integration of logging configuration with module metadata (`270_ModulesAndCompilationUnits_Phase1/2.md`)
   and the build system (`330_BuildSystemAndCompilationPipeline_Phase1/2.md`).

4. **Pluggable serializers**  
   Supporting multiple serialization formats (plain text, JSON, ND‑JSON, etc.) via explicit strategy objects, without changing the core logging semantics.

None of these extensions affect the core guarantees specified in this file.

---

## 380.13 Summary of Key Guarantees

1. **Levels**: `Debug`, `Info`, `Warn`, `Error`, `Fatal` with strictly ordered severity.
2. **Structured logging**: message + key/value fields, with preserved field order.
3. **Concurrency**: `Logger` is safe for concurrent use from multiple tasks.
4. **Writers**: implement `Writer`, optionally `Flusher` for buffered output.
5. **Fatal**: log → optional flush → terminate via `exitFn(1)`; does not rely on deterministic destruction.
6. **Deterministic destruction**: loggers may own writers; they release them on destruction in normal execution, but not after `Fatal`.
7. **Errors**: logging methods do not return errors; implementations may expose error inspection or callbacks as advanced features.

---


# 390. UTF-8 And Text Model

## 390.1. String Model

Ori defines `string` as a built-in primitive type representing an immutable sequence of bytes that must contain valid UTF-8.  Strings have the following properties:
- Stored as a contiguous sequence of bytes
- Immutable at the language level
- Length refers to number of bytes, not number of runes.
- Indexing (`s[i]`) returns a `uint8` byte
- UTF-8 validity is enforced at creation time (literals, builders, concatenation, file reads, etc.)

## 390.2. UTF-8 Validity
String creation functions ensure UTF-8 validity. Invalid UTF-8 can only appear via:
- Byte slicing (`s[a:b]`)
- Explicit unsafe APIs
- FFI input

Ori does *not* implicitly repair, normalize, or reinterpret invalid UTF-8.

## 390.3. Slicing Rules

Byte slicing uses:
```
s[a:b]
```

This always returns a string of bytes without checking UTF-8 boundaries. This allows creation of invalid UTF-8 strings intentionally.

Rune-aware slicing must be explicit:
```
utf8.SliceRunes(s, startRune, endRune) -> string
```

## 390.4. Rune Type

Ori defines:
```
type Rune = uint32
```

A Rune is a Unicode scalar value (`0 .. 0x10FFFF`, excluding surrogates). Conversions are explicit:
- `utf8.Encode(r Rune) []byte`
- `utf8.DecodeNext(s string, index int) (Rune, int, err)`

Surrogate code points range from `U+D800` to `U+DFFF` and must never occur in a Rune.

## 390.5. Iteration Model

Byte iteration:
```
for b := range s {
    // b is uint8
}
```

Rune iteration:
```
for r := range utf8.Runes(s) {
    // r is Rune
}
```

`utf8.Runes(s)` returns a zero-allocation iterator that decodes UTF-8 during iteration.

## 390.6. Searching and Matching

Ori does not support implicit operators like `"é" in s`.  
Explicit APIs exist:
```
utf8.Contains(s, "é")
utf8.IndexRune(s, r)
bytes.Contains(s, pattern)
```

Byte search is always allowed. Rune search requires explicit UTF-8 decoding.

## 390.7. Normalization Policy

Ori never performs Unicode normalization implicitly.

Normalization forms:
- NFC: Canonical composition
- NFD: Canonical decomposition
- NFKC / NFKD: Compatibility normalization

Future standard library packages may provide:
```
utf8.NormalizeNFC(s)
utf8.NormalizeNFD(s)
...
```
None are automatic.

## 390.8. Error Handling Semantics

Functions decoding UTF-8 return structured errors.  
Example:
```
func utf8.DecodeNext(s string, index int) (Rune, int, err) {
    ....
}
```

Invalid UTF-8 inside a string causes decoding APIs to return errors.

## 390.9. FFI Interoperability

Ori strings are not null-terminated. Conversion APIs:
```
ToCString(s: string) []byte        // appends null terminator
FromCString(ptr: *char) string     // validates UTF-8
```

Invalid UTF-8 from external sources produces an error.

## 390.10. Compile-Time Rules

The compiler validates UTF-8 for:
- string literals
- constant strings built at compile time

Any invalid literal produces a compile-time error.

---


# 400 Executor And Tasks – Phase 2

## 400.1 Overview

This specification defines Ori’s executor model, cooperative task behavior, cancellation signals, deadline signals, blocking‑IO rules, task groups, and error‑handling integration.

Tasks are lightweight cooperative units executed by a **single global executor**, while OS threads handle blocking IO and CPU‑heavy work.  
This spec extends `190_Concurrency.md` by formalizing executor semantics and introducing graceful shutdown and signaling mechanisms.

---

## 400.2 Executor Model

### 400.2.1 Definition

An **executor** is the single‑threaded cooperative scheduler responsible for running all tasks created via `spawn_task`.

### 400.2.2 Properties

- Exactly **one executor** exists in Ori.
- The executor runs on the OS thread that enters `main`
- All `spawn_task` invocations schedule tasks onto this executor
- The executor maintains a **run queue** of ready tasks
- Tasks run until they hit a **yield point**:
  - `yield()`
  - `Send()`
  - `Recv()`
  - `Wait()`
- Scheduling is **deterministic and cooperative**
- Tasks never migrate between threads or executors

### 400.2.3 Purpose

The executor provides:
- deterministic ordering of task execution
- a foundation for non‑blocking concurrency
- integration of cancellation and deadline signals
- enforcement of non‑blocking IO rules

The executor is **not**:
- a threadpool
- a job scheduler
- a goroutine‑like M:N runtime

It is a deterministic run‑queue for cooperative tasks.

---

## 400.3 Tasks and Threads

### 400.3.1 Tasks (`spawn_task`)

Tasks:
- run exclusively on the executor
- never block its OS thread
- must not perform blocking IO
- must reach yield points to allow scheduling
- are cooperative and deterministic

### 400.3.2 Threads (`spawn_thread`)

Threads:
- are real OS threads
- may perform blocking IO
- run concurrently with the executor
- cannot call `yield()`
- cannot create tasks (`spawn_task` forbidden inside threads)

---

## 400.4 Blocking IO Rules

### 400.4.1 Non‑blocking requirement for tasks

Tasks MUST NOT call functions that perform blocking IO.

Blocking inside a task would freeze the executor and invalidate deterministic concurrency.

### 400.4.2 Compiler Enforcement

Each stdlib function carries internal metadata:

```
isIOBlocking: bool
```

(Not visible to the user.)

Rules:
- If a function with `isIOBlocking = true` is reachable inside a `spawn_task` body → **compile‑time error**
- A function is considered blocking if it directly or transitively calls blocking OS syscalls

### 400.4.3 Allowed operations in tasks

- in‑memory operations
- metadata syscalls that do not block
- `Send`, `Recv`, `Wait`, `yield`
- pure computation that periodically yields

### 400.4.4 Blocking IO via threads

To perform blocking IO:

```
t := spawn_thread func() Result {
    return ReadFile("path")
}
value, err := t.Wait()
```

Threads safely isolate blocking operations.

---

## 400.5 Signals (Cancellation & Deadlines)

### 400.5.1 CancelSignal

```
type struct CancelSignal { /* opaque */ }

func MakeCancelSignal() CancelSignal
func (s CancelSignal) Trigger()
func (s CancelSignal) IsTriggered() bool
```

Characteristics:
- cooperative: tasks must check explicitly
- does not forcibly terminate tasks
- does not unwind stacks
- has no relationship to deadlines

### 400.5.2 DeadlineSignal

```
type struct DeadlineSignal { /* opaque */ }

func MakeDeadlineSignal(d Duration) DeadlineSignal
func (d DeadlineSignal) IsExceeded() bool
```

Characteristics:
- time‑based
- independent from cancellation
- does not auto‑trigger CancelSignal
- must be explicitly checked in task code

### 400.5.3 Signals do not imply exit

Signals are advisory:
- they never kill tasks
- they never propagate implicitly
- they must be observed cooperatively

---

## 400.6 Task Lifecycle & Graceful Shutdown

### 400.6.1 Valid termination paths

A task may terminate by:

1. returning normally
2. returning an error (including ErrCancelled or ErrDeadline)
3. reacting to signals cooperatively
4. panicking (converted into ErrPanic)

### 400.6.2 Deterministic destruction

Upon task return:
- all local variables are destroyed deterministically
- all `defer` destructors run in reverse order
- no resource leaks occur

### 400.6.3 No forced termination

Executors do not:
- kill tasks
- preempt tasks
- inject cancellations

Tasks must reach yield boundaries.

---

## 400.7 TaskGroup

### 400.7.1 Definition

A `TaskGroup` is a semantic grouping of tasks that allows waiting on all of them.  
It does **not**:
- contain its own executor
- own cancellation state
- manage deadlines
- supervise or kill tasks

### 400.7.2 API

```
type struct TaskGroup { /* opaque */ }

func MakeTaskGroup() TaskGroup
func (g TaskGroup) SpawnTask(fn func() Error)
func (g TaskGroup) Wait() Error
```

### 400.7.3 Behavior

- All group tasks run on the single executor
- `Wait()` returns:
  - `nil` if all tasks succeed
  - the first non‑nil error in spawn order
- No automatic cancellation of other tasks
- No auto‑deadline behavior

---

## 400.8 Error Model Integration

### 400.8.1 Canonical errors

```
const ErrCancelled Error
const ErrDeadline  Error
const ErrPanic     Error    // panic("x") → ErrPanic("x")
```

These are well‑known sentinel values.

### 400.8.2 Task outcomes

`Wait()` returns exactly one of:

- `nil`
- ErrCancelled
- ErrDeadline
- user‑defined error
- ErrPanic

### 400.8.3 Panic behavior

- panic terminates the task
- executor catches the panic
- panic is converted into ErrPanic
- destructors still run normally

### 400.8.4 Thread error rules

`ThreadHandler[T].Wait()` returns `(T, Error)` with identical error semantics.

---

## 400.9 Interaction With Executor Scheduling

### 400.9.1 Yield points resume executor control

A task only yields at:
- `yield()`
- `Send()`
- `Recv()`
- `Wait()`

### 400.9.2 Signals do not cause automatic yield

A task must explicitly check signals to exit.

---

## 400.10 Program Shutdown

- Tasks must complete voluntarily
- Executor shuts down only when no tasks remain
- Threads must be waited on explicitly
- No implicit cancellations occur at program end

---

## 400.11 Future Extensions (Non‑Speculative Notes)

The model intentionally leaves room for:
- custom executors
- async IO runtimes built in stdlib
- structured concurrency layers

These require no changes to the semantics defined in this file.

---

## 400.12 Summary

Ori’s executor and task model is:
- deterministic
- cooperative
- explicit
- non‑preemptive
- free from blocking IO hazards
- fully integrated with signals and deterministic destruction

It offers a clean foundation for safe, predictable concurrency.

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
- **Explicit unsafe blocks** — allowed only in advanced use cases like FFI (planned feature).  
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

**Channel design:**
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

## 7. Structured Concurrency

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

## 8. Safer Message Passing (Planned)

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
- **Reference-like types** — `view`, `shared`
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

### Rune
Represents a single Unicode code point.  
Equivalent to a `char` in C, but safe for multibyte characters.

---

### Shared
A qualifier for referencing values without copying.  
Future feature for fine-grained control over memory semantics.

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


# 001. OS Package — File System, Environment, and IO

The `os` package provides Ori's minimal, explicit, deterministic interface to the host operating system:
- opening, reading, writing, syncing, and closing files
- basic directory operations
- environment variables
- access to standard input, output, and error streams

This file defines the **API-level specification** for the `os` package.  
It is allowed to evolve in future versions, but must always respect the semantics described in:
- `semantics/370_FileSystemAndIO.md`
- `140_Errors.md`
- `220_DeterministicDestruction.md`
- `ecosystem/001_StandardLibraryFoundations.md`

---

## 001.1 Goals

- Provide a small, explicit API for working with the file system and environment
- Use value-typed, destructor-backed handles for OS resources.
- Integrate tightly with the builtin `Error` type
- Avoid any hidden buffering, background threads, or implicit concurrency
- Keep the API portable across platforms, while allowing platform-specific extensions in separate packages

This document describes the **complete OS API**.

---

## 001.2 Core Types

### 001.2.1 `File`

```ori
package os

type struct File {
    // internal representation is opaque and implementation-defined
}
```

`File` is an owning handle to an OS-backed file descriptor or equivalent. It has the following properties:
- **Ownership:** A `File` value owns exactly one OS resource. Ownership transfers when the value is moved
- **Move-only:** `File` cannot be copied implicitly. Cloning or copying a `File` is a compile-time error unless the language provides an explicit move operation
- **Destructor-backed:** When a `File` value goes out of scope, its destructor runs and performs a best-effort close of the underlying OS resource
- **Methods:** All methods that mutate internal state use a `shared` receiver:
  ```ori
  func (f shared File) Read(buf []byte) (int, Error)
  func (f shared File) Write(buf []byte) (int, Error)
  func (f shared File) Seek(offset int64, mode SeekMode) (int64, Error)
  func (f shared File) Sync() Error
  func (f shared File) Close() Error
  func (f shared File) Stat() (FileInfo, Error)
  func (f shared File) ReadAll() ([]byte, Error)
  func (f shared File) WriteAll(data []byte) Error
  ```

The internal layout (e.g. whether there is a raw `fd` integer) is not part of the API and may vary across implementations.

---

### 001.2.2 `FileMode`

```ori
type FileMode uint32
```

`FileMode` represents file permission bits and basic type information. The exact bit layout is implementation-defined, but must be sufficient to represent typical Unix-style permissions and basic type flags (directory, regular file, etc.).

The `os` package may expose portable constants, for example:

```ori
const ModePermUserRead  FileMode
const ModePermUserWrite FileMode
const ModePermUserExec  FileMode
// ... and so on for group/other
```

Additionally, examples may use octal notation (e.g. `0o755`) to describe typical Unix permissions.  
Ori does **not yet** support octal integer literals in the core language, but this notation is used in examples to indicate common Unix-style modes and anticipated future literal support (see `semantics/370_FileSystemAndIO.md`).

---

### 001.2.3 `FileInfo`

```ori
type struct FileInfo {
    Name const string     // base name, not a full path
    Size const int64      // size in bytes for regular files
    Mode const FileMode   // permission bits and basic type info
    IsDir const bool      // true if this represents a directory
    // Future fields (e.g. ModTime) may be added in later versions.
}
```

`FileInfo` is an immutable value providing metadata about a file system object.

---

### 001.2.4 `DirEntry`

```ori
type struct DirEntry {
    Name const string     // entry name, not a full path
    IsDir const bool      // true if the entry is a directory
    Mode const FileMode   // best-effort mode information
}
```

`DirEntry` is returned by directory listing APIs and does not own any OS resources.

---

### 001.2.5 `SeekMode`

```ori
type SeekMode int

const (
    SeekStart   SeekMode = 0  // relative to the beginning of the file
    SeekCurrent SeekMode = 1  // relative to the current offset
    SeekEnd     SeekMode = 2  // relative to the end of the file
)
```

`SeekMode` defines how the offset passed to `Seek` is interpreted.

---

### 001.2.6 `OpenOptions`

```ori
type struct OpenOptions {
    Read      bool
    Write     bool
    Append    bool
    Create    bool
    CreateNew bool
    Truncate  bool
    Mode      FileMode
}
```

`OpenOptions` allows precise control over how a file is opened. Invalid combinations (e.g. `CreateNew` without `Write`) must result in an `Error`.

---

## 001.3 Errors

All fallible functions and methods in the `os` package use the builtin `Error` type as their last return value.

The `os` package may define sentinel errors for common conditions:

```ori
const ErrNotFound         Error
const ErrPermissionDenied Error
const ErrAlreadyExists    Error
const ErrIsDir            Error
const ErrInvalidPath      Error
const ErrInvalidSeek      Error
const ErrClosed           Error
const ErrEOF              Error
```

These sentinel values must be comparable using `==` and have stable `Code` fields within a given Ori version.

Example:

```ori
var file, err = os.Open("config.toml")
if err == ErrNotFound {
    // handle missing file
}
```

---

## 001.4 File Operations

### 001.4.1 Opening files

```ori
func os.Open(path string) (File, Error)
```

- Opens an existing file at `path` in read-only mode
- Returns `(File, nil)` on success
- Returns `(File{}, ErrNotFound)` if the file does not exist

```ori
func os.Create(path string) (File, Error)
```

- Creates or truncates the file at `path` for read/write access.
- Returns `(File, nil)` on success
- Returns an appropriate `Error` on failure (e.g. `ErrInvalidPath`, `ErrPermissionDenied`)

```ori
func os.OpenWith(path string, opts OpenOptions) (File, Error)
```

- Opens a file with the specified options
- Must reject invalid combinations of options with a clear `Error` (e.g. `ErrInvalidPath` or another sentinel)

### 001.4.2 Reading

```ori
func (f shared File) Read(buf []byte) (int, Error)
```

- Attempts to read up to `len(buf)` bytes into `buf`
- Returns `(n, nil)` on success (`0 <= n <= len(buf)`)
- At end-of-file:
  - Returns `(0, ErrEOF)` if no bytes were read
  - May return `(n > 0, nil)` and report EOF on the next call
- Returns `(0, ErrClosed)` if the file is closed

```ori
func (f shared File) ReadAll() ([]byte, Error)
```

- Reads from the current offset until EOF
- Allocates and returns a new `[]byte` slice containing the entire content
- Returns `ErrClosed` if the file is closed

### 001.4.3 Writing

```ori
func (f shared File) Write(buf []byte) (int, Error)
```

- Attempts to write up to `len(buf)` bytes from `buf` into the file
- May return partial writes (`n < len(buf)`) without error, depending on OS behavior
- Returns `(n, ErrClosed)` if the file is closed

```ori
func (f shared File) WriteAll(data []byte) Error
```

- Writes all bytes from `data`, repeatedly calling `Write` until completion or error
- Returns `nil` on success, or a non-`nil` `Error` on failure

### 001.4.4 Seeking

```ori
func (f shared File) Seek(offset int64, mode SeekMode) (int64, Error)
```

- Repositions the file offset based on `offset` and `mode`
- Returns the new absolute offset from the beginning of the file
- Returns `ErrInvalidSeek` if the resulting offset would be negative or otherwise invalid
- Returns `ErrClosed` if the file is closed

### 001.4.5 Syncing

```ori
func (f shared File) Sync() Error
```

- Flushes in-memory state of the file to stable storage, as far as the platform allows.
- Returns `nil` on success or an appropriate `Error` on failure.
- Returns `ErrClosed` if the file is closed.

### 001.4.6 Closing

```ori
func (f shared File) Close() Error
```

- Closes the underlying OS resource and marks the `File` as closed
- Returns `nil` on success
- Returns `ErrClosed` if the file is already closed
- After `Close()` succeeds:
  - The destructor for `File` becomes a no-op for that value
  - All subsequent calls to `Read`, `Write`, `Seek`, `Sync`, and `Stat` return `ErrClosed`

If user code never calls `Close()`, the `File` destructor will still close the resource best-effort, but any close error is ignored, as required by the semantics document.

### 001.4.7 Metadata

```ori
func (f shared File) Stat() (FileInfo, Error)
func os.Stat(path string) (FileInfo, Error)
```

- `File.Stat` returns metadata for the open file described by `f`
- `os.Stat` returns metadata for the file system object at `path` without opening it for IO
- Both return `(FileInfo{}, ErrNotFound)` if the target does not exist

---

## 001.5 Directory Operations

### 001.5.1 Creating directories

```ori
func os.Mkdir(path string, mode FileMode) Error
```

- Creates a single directory at `path` with the specified `mode`
- Returns `ErrAlreadyExists` if a file or directory already exists at `path`
- Returns `ErrInvalidPath` for invalid paths
- Returns `ErrPermissionDenied` for permission errors

Examples may use octal-like notation for the mode, such as:

```ori
var err = os.Mkdir("data", 0o755)
// NOTE: 0o755 is illustrative and may rely on future octal literal support.
```

### 001.5.2 Removing files and directories

```ori
func os.Remove(path string) Error
```

- Removes the file or empty directory at `path`
- Returns `ErrNotFound` if `path` does not exist
- Returns `ErrPermissionDenied` or another appropriate `Error` if removal fails

Higher-level helpers such as `RemoveAll` may be added later, but are not part of current spec.

### 001.5.3 Listing directory contents

```ori
func os.ReadDir(path string) ([]DirEntry, Error)
```

- Returns a slice of `DirEntry` for the immediate entries in the directory at `path`
- Whether `.` and `..` are included is implementation-defined, but implementations are encouraged to exclude them
- Returns `ErrNotFound` if the directory does not exist
- Returns `ErrPermissionDenied` if the directory cannot be read

This is a collect-all API meant for typical use cases and small to medium directories.

---

## 001.6 Environment Variables

The `os` package exposes environment variables as process-level key-value pairs.

```ori
func os.Getenv(key string) (string, bool)
```

- Returns the value associated with `key` and a boolean indicating whether the variable is set
- Returns `("", false)` if the variable is not set

```ori
func os.Setenv(key string, value string) Error
```

- Sets the environment variable `key` to `value`
- Returns `nil` on success or an appropriate `Error` on failure

```ori
func os.Unsetenv(key string) Error
```

- Removes the environment variable `key` from the environment
- Returns `nil` on success, even if the variable was not previously set
- Returns an appropriate `Error` on failure

All environment functions must be safe to call from multiple concurrent tasks.

---

## 001.7 Standard Streams

The process-wide standard streams are exposed via three functions:

```ori
func os.Stdin() File
func os.Stdout() File
func os.Stderr() File
```

Each call returns a `File` value that acts as a **non-owning wrapper** around the corresponding process stream:

- The underlying OS descriptors for standard input, output, and error are **not** owned by these `File` values for the purposes of destruction
- The destructor for these wrapper values must not attempt to close the real OS standard streams
- The `Close()` method on such wrapper values:
  - must **not** close the real OS stream; and
  - should either return `ErrInvalidOperation` or be explicitly documented as a no-op

All other methods (`Read` on `os.Stdin()`, `Write` / `WriteAll` on `os.Stdout()` and `os.Stderr()`, etc.) behave as for regular `File` values, subject to OS constraints.

Typical usage:

```ori
import "os"

func main() {
    var out = os.Stdout()
    out.WriteAll([]byte("hello, world
"))
}
```

The implementation is free to cache underlying OS handles internally, but such details are not visible at the API level.

---

## 001.8 Concurrency Behavior

- All `os` file and directory operations are **blocking** from the perspective of the calling task
- The `File` type is **not guaranteed** to be safe for concurrent use from multiple tasks without synchronization
- Implementations may document certain operations as thread-safe, but users must not rely on implicit safety

To share a `File` between tasks, user code should wrap it in a synchronization primitive such as a mutex.

Destructors for `File` must obey the global rules:

- no panics
- no unbounded blocking
- single best-effort close

---

## 001.9 Octal File Modes in Examples

This document uses octal notation for file modes in examples, such as:
```ori
os.Mkdir("logs", 0o755)
```

Ori does **not yet** support octal integer literals in the language, but:
- this notation reflects a widely-used Unix/Linux convention for file permissions;
- future versions of Ori are expected to support octal literals (e.g. via a `0o` prefix)
- until then, such examples should be treated as **conceptual** and may rely on tooling or compiler flags in early implementations

Implementations targeting Unix-like systems should ensure that `FileMode` and mode-related APIs behave consistently with this conceptual model, even if the literal syntax evolves later.

---

## 001.10 Examples

### 001.10.1 Copying a file

```ori
import "os"

func CopyFile(srcPath string, dstPath string) Error {
    var src, err = os.Open(srcPath)
    if err != nil {
        return err
    }
    defer src.Close()

    var dst, err2 = os.Create(dstPath)
    if err2 != nil {
        return err2
    }
    defer dst.Close()

    var buf = make([]byte, 4096)
    for {
        var n, rerr = src.Read(buf)
        if rerr == ErrEOF {
            break
        }
        if rerr != nil {
            return rerr
        }

        var written = 0
        while written < n {
            var w, werr = dst.Write(buf[written:n])
            if werr != nil {
                return werr
            }
            written += w
        }
    }

    return nil
}
```

### 001.10.2 Reading a small configuration file

```ori
import "os"

func ReadConfig(path string) ([]byte, Error) {
    return os.ReadFile(path)
}
```

### 001.10.3 Creating a directory and listing contents

```ori
import "os"

func ListOrCreateDir(path string) Error {
    var err = os.Mkdir(path, 0o755)
    if err != nil && err != ErrAlreadyExists {
        return err
    }

    var entries, derr = os.ReadDir(path)
    if derr != nil {
        return derr
    }

    for _, e := range entries {
        if e.IsDir {
            println("dir ", e.Name)
        } else {
            println("file", e.Name)
        }
    }

    return nil
}
```

This concludes the current specification of the `os` package's file system, environment, and standard stream APIs.

---


# 001. Standard Library Foundations

The Ori standard library is intentionally small, explicit, and guided by the same principles as the language itself: clarity, determinism, predictability, and zero hidden behavior.  
The standard library does not aim to provide a broad API surface. Instead, it establishes the foundational packages, responsibilities, and design constraints that will
shape the ecosystem as Ori evolves.

The goals are:
1. Identify the core packages that must exist in a minimal, usable system.
2. Define their conceptual responsibilities without finalizing APIs.
3. Specify boundaries: what each package must do, and what it must not do.
4. Ensure all packages integrate cleanly with:
   - the builtin Error type (see `140_Errors.md`)
   - deterministic destruction (see `220_DeterministicDestruction.md`)
   - explicit ownership and memory semantics
   - Ori's philosophy of simplicity and explicitness.

The standard library does NOT attempt to fully specify the API of each package. Only high-level design foundations are provided here.

---

# 001.1 Included Packages

The following foundational packages are introduced:
- os
- filepath
- time
- log
- sync
- net

These represent the minimal set necessary for basic system interaction, I/O, timing, concurrency primitives, and networking. No additional packages are included at this stage.

The formatting package "fmt" is intentionally postponed because it requires deeper compile-time and reflection capabilities.

---

# 001.2. Package Definitions (High-Level Only)

Each package description below outlines:
- purpose and scope
- integration requirements with Ori semantics
- design constraints
- explicit non-goals

These are NOT frozen API contracts.

---

# 001.2.1 Package: os

The `os` package provides direct interaction with operating system primitives:
- files and basic file I/O
- creation and removal of directories
- environment variables
- process identification and process exit

Responsibilities:
- Expose a minimal, explicit interface to OS resources
- Integrate with deterministic destruction: files and network sockets must be treated as owning resources automatically cleaned up at scope exit unless explicitly closed earlier
- Use the builtin `Error type` consistently.

Non-goals:
- file metadata (stat, permissions)
- buffered I/O layers
- process spawning
- symbolic links
- recursive directory operations

---

# 001.2.2 Package: filepath

The `filepath` package provides path manipulation utilities that operate purely on strings:
- extracting directory or file components
- joining paths
- normalizing paths
- checking whether a path is absolute

Responsibilities:
- Pure string manipulation, no OS access
- Provide consistent behavior across platforms by using platform-aware separators.

Non-goals for:
- globbing
- pattern matching
- realpath / canonicalization via filesystem access

---

# 001.2.3 Package: time

The `time` package provides:
- a `Time` type representing timestamps
- a `Duration` type
- obtaining the current time
- sleeping for a fixed duration

Responsibilities:
- Provide only the minimal primitives required to measure time and wait
- Avoid time zones, calendars, and formatting/parsing

Non-goals:
- date/time formatting
- locale awareness
- timers, schedulers, repeating tasks
- complex arithmetic involving months or leap years

---

# 001.2.4 Package: log

The `log` package offers:
- minimal logging utilities
- a few log levels (at least Debug, Info, Warn, Error)
- a default thread-safe logger writing to stderr

Responsibilities:
- Simple, explicit logging without reflection or formatting templates
- User-configurable output destination
- No hidden allocations unless explicitly required

Non-goals:
- printf-style formatting
- structured or JSON logging
- multi-sink logging
- contextual or hierarchical loggers

---

# 001.2.5 Package: sync

The `sync` package provides essential synchronization primitives:
- mutexes
- reader-writer locks
- minimal atomic integer type(s)

Responsibilities:
- Enable basic mutual exclusion and atomic operations
- Integrate safely with Ori's ownership semantics
- Avoid implicit background threads or scheduling semantics

Non-goals:
- condition variables
- semaphores
- synchronized channels
- lock-free collections
- wait groups or thread pools

---

# 001.2.6 Package: net

The `net` package provides:
- minimal TCP client and server primitives
- owning connection values with deterministic destruction
- a minimal listener abstraction

Responsibilities:
- Allow simple blocking TCP networking
- Align with deterministic destruction (connections and listeners are owning values cleaned at scope exit)
- Keep semantics predictable and platform-neutral

Non-goals:
- non-blocking IO
- timeouts
- DNS APIs
- UDP
- TLS
- HTTP
- async networking

---

# 001.3 Integration With Ori Semantics

All packages must follow these rules:
- Explicit `Error` handling:
  - All functions that can fail must return the builtin Error type
  - No error wrapping, no exceptions
- Deterministic destruction:
  - Any resource tied to an OS handle (files, sockets, listeners, etc.) must be represented as an owning value with a destructor, ensuring cleanup on all control-flow paths.
- No reflection or formatting introspection:
  - In current version we avoid APIs that rely on runtime type inspection or formatting verbs. These are deferred until compile-time reflection phases and the `fmt` package are designed
- Explicit resource control:
  - No hidden allocations unless stated
  - No hidden goroutines or system threads
  - No implicit concurrency

---

# 001.4 Exclusions

The following features are intentionally excluded from the current version of the standard library, either due to complexity or because they depend on future compile-time or ownership semantics:
- fmt (formatting system)
- json and serialization
- buffered IO
- subprocess management
- filesystem metadata APIs
- cryptography
- HTTP or higher-level networking
- async tasks or event loop
- global configuration layers

---

# 001.5 Philosophy Summary

The Ori standard library is intentionally minimalistic:
- small enough to be easy to implement and evolve
- stable enough to support real-world usage
- explicit enough to maintain predictability
- constrained enough to prevent accidental design debt

This document defines foundations, not final APIs.  
Future versions will refine and expand these packages as the language gains additional capabilities (e.g., compile-time reflection, fmt system, more powerful generics).

---


# 003. Time Package

The `time` package provides Ori's minimal, explicit, deterministic `time API`.  
It exposes only the primitives required for measuring durations, obtaining timestamps, and sleeping.  
It does not include calendars, time zones, parsing, formatting, timers, tickers, schedulers, or any implicit task creation.  
This file defines the complete `Time API`.

---

## 003.1 Goals

- Provide a simple and explicit wall-clock timestamp (`Time`).
- Provide a monotonic timestamp for duration measurement.
- Represent durations with an integer nanosecond type.
- Offer basic utilities (`Now`, `MonotonicNow`, `Sleep`, `Since`, `SinceMonotonic`).
- Avoid all hidden behavior:
  - no suffix-based literals (`500ms`, `1s`)
  - no background threads
  - no timers or tickers
  - no attribute-based magic
- All time arithmetic is explicit and uses normal operations.

These goals match the high-level foundations of the standard library.

---

## 003.2 Types

### 003.2.1 Duration

```
type Duration int64
```

`Duration` represents a span of time in **nanoseconds**.

A helper constructor converts integer nanoseconds into a Duration:
```
func duration(n int64) Duration {
    return Duration(n)
}
```

Arithmetic on `Duration` uses the normal operators: `+`, `-`, `%`, `*`, `/`,
comparisons, etc.

---

### 003.2.2 Time

```
type struct Time {
    unixNano int64   // wall-clock timestamp, nanoseconds since Unix epoch
}
```

Properties:
- Immutable value
- Represents wall-clock time in UTC
- Its internal representation is opaque; users interact with it only through the API.

---

## 003.3 Duration Constants

```
const Nanosecond  Duration = duration(1)
const Microsecond Duration = duration(1_000)
const Millisecond Duration = duration(1_000_000)
const Second      Duration = duration(1_000_000_000)
const Minute      Duration = 60 * Second
const Hour        Duration = 60 * Minute
```

These constants enable ergonomic and explicit duration expressions.

---

## 003.4 Functions

### 003.4.1 Now

```
func Now() Time
```

Returns the current **wall-clock** system time.

---

### 003.4.2 MonotonicNow

```
func MonotonicNow() Duration
```

Returns a **monotonic timestamp** measured in nanoseconds.

---

### 003.4.3 Sleep

```
func Sleep(d Duration)
```

Blocks the current task for at least `d` nanoseconds.

---

### 003.4.4 Since (wall-clock)

```
func Since(t Time) Duration
```

Returns the elapsed duration between `Now()` and a prior wall-clock `Time`.

---

### 003.4.5 SinceMonotonic (monotonic)

```
func SinceMonotonic(start Duration) Duration
```

Returns the elapsed monotonic duration.

---

## 003.5 Usage Examples

```
time.Sleep(500 * time.Millisecond)

start := time.Now()
elapsed := time.Since(start)

start2 := time.MonotonicNow()
elapsed2 := time.SinceMonotonic(start2)
```

---

## 003.6 Exclusions in current version

- No `time.After`
- No `time.Ticker`
- No clocks with timezone or calendar logic
- No parsing or formatting
- No deadline or cancellation APIs

---

## 003.7 Summary

The `time` package provides:
- A minimal but complete `Duration` type.
- A simple `Time` type for wall-clock timestamps.
- Monotonic and wall-clock time sources.
- Elapsed-time helpers (`Since`, `SinceMonotonic`).
- Explicit duration arithmetic via exported constants.
- A predictable `Sleep` function consistent with Ori’s concurrency model.

---


# 010. Core Packages Catalog

This document catalogs Ori’s core standard library packages.

It is **not** a detailed API specification.  
Instead, it defines:
- Which packages exist
- Whether they are **v1.0 core** or **planned post-1.0**
- Their responsibilities and relationships
- Cross-cutting constraints (no reflection magic, no global mutable state, deterministic destruction, etc.)

`ecosystem/001_StandardLibraryFoundations.md` defines high-level philosophy.  
This file lists the **concrete packages** that implement that philosophy.

---

## 010.1 Version & Stability Model

Each package in this catalog is tagged with one of:

- **Status: v1.0 core**  
  Must exist and be usable in Ori v1.0.

- **Status: planned post-1.0**  
  Conceptually part of the standard library, but can ship in a later minor version without blocking v1.0.

A package can move from "planned post-1.0" to "v1.0 core" via roadmap decisions in future versions of the language spec.

---

## 010.2 Global Constraints for All Packages

All standard packages must respect Ori’s core principles:

1. **No global mutable state**
   - Global constants are allowed.
   - Global variables are forbidden.
   - Shared resources (e.g. loggers, executors) are created explicitly and passed around.

2. **No runtime reflection**
   - No APIs that inspect arbitrary structs/interfaces at runtime.
   - Compile-time reflection may be used by library authors, but the resulting APIs are explicit and type-directed.

3. **Deterministic destruction**
   - Any package that allocates OS resources (files, sockets, timers, threads, tasks, etc.) must define clear rules for:
     - Ownership.
     - When destruction happens.
     - What the destructor can and cannot do.
   - Leaking resources is always a concrete, visible choice (e.g. moving ownership).

4. **Explicit error handling**
   - No hidden panics for recoverable errors.
   - Errors are returned explicitly and documented.

5. **No hidden buffering or background threads**
   - Buffering must be explicit (e.g. `bufio`).
   - Background threads/tasks are created via explicit, documented APIs (e.g. `executor`).

6. **No attributes / annotations**
   - No `@deprecated`, `@tag`, `@serde`, etc. in the language.
   - Standard library does not assume the existence of such constructs.

---

## 010.3 Package Categories

Packages are grouped by domain:
- **Core runtime & OS**: `os`, `fs`, `filepath`
- **I/O primitives**: `io`, `bufio`
- **Text & data**: `strings`, `utf8`, `bytes`
- **Time & scheduling**: `time`, `executor`
- **Diagnostics & formatting**: `fmt`, `log`
- **Testing & tooling**: `testing`, `testing/quick` (post-1.0)
- **Networking & encoding** (planned post-1.0): `net`, `json`, `hash/*`, `flag`, etc.

---

## 010.4 Core Runtime & OS

### 010.4.1 `os`

**Status:** v1.0 core

**Responsibilities:**

- Process-related information:
  - OS name, architecture.
  - Process ID.
- Environment variables:
  - `GetEnv`, `SetEnv`, `UnsetEnv`.
  - Clear guarantees about lifetime and visibility.
- Process exit:
  - Functions/constants to exit with a given code.
- Standard streams:
  - `os.Stdout()`, `os.Stderr()`, `os.Stdin()` returning **`shared File`** handles.
  - No global mutable `os.Stdout` variables.

**Non-responsibilities:**

- **File management** (open, create, remove, rename, etc.). Those belong to `fs`.
- Path manipulation (belongs to `filepath`).
- Networking (belongs to `net`, post-1.0).

---

### 010.4.2 `fs`

**Status:** v1.0 core

**Responsibilities:**

- Filesystem operations:
  - `Open`, `Create`, `Remove`, `Rename`, `Stat`.
  - Directory operations (create, remove, list, walk).
  - File permissions and modes (numeric / octal notation in docs).
- File handle abstractions:
  - `File` type with explicit ownership.
  - Deterministic destruction (`Close` semantics) aligned with `220_DeterministicDestruction.md`.
- Potential support for:
  - Working directories.
  - Symlinks, if the platform supports them (documented explicitly).

**Design notes:**

- `fs` is the main “user-facing” filesystem package.
- Ori intentionally does **not** follow Go’s `os.File` design; it instead follows the cleaner separation typical of Rust (`std::fs`) and Zig (`std.fs`).

---

### 010.4.3 `filepath`

**Status:** v1.0 core

**Responsibilities:**

- Pure path manipulation:
  - `Join`, `Split`, `Base`, `Dir`.
  - `Ext`, `Clean`, `IsAbs`, etc.
- OS-dependent separator behavior (documented, but without side effects).
- Functions operate on strings; they do not touch the filesystem.

**Non-responsibilities:**

- Opening files or checking their existence (belongs to `fs`).

---

## 010.5 I/O Primitives

### 010.5.1 `io`

**Status:** v1.0 core

**Responsibilities:**

- Fundamental I/O interfaces:
  - `Reader`, `Writer`.
  - `ReadCloser`, `WriteCloser`.
  - `Seeker` / `Seekable` abstractions.
- Utility functions:
  - Copying between `Reader` and `Writer`.
  - Discard sinks, limited readers, etc.

**Design constraints:**

- No hidden buffering.
- No magic transformations (e.g. no transparent compression/decompression).
- Error behavior is explicit and consistent.

---

### 010.5.2 `bufio`

**Status:** v1.0 core

**Responsibilities:**

- Explicit buffering decorators around `io.Reader` and `io.Writer`:
  - `BufferedReader`, `BufferedWriter`, or similar types.
- APIs to:
  - Control buffer size.
  - Flush explicitly.
  - Inspect how much is buffered.

**Design constraints:**

- No implicit global buffers.
- No automatic background flush threads.
- Buffering never happens silently; the type names and constructors make it obvious.

---

## 010.6 Text & Data

### 010.6.1 `bytes`

**Status:** v1.0 core

**Responsibilities:**

- Utilities for `[]byte` manipulation:
  - Search, split, join.
  - Efficient building and reading of byte sequences.
- In-memory buffer objects layered on `[]byte`.
- Useful for binary protocols and FFI.

**Design constraints:**

- No UTF-8 assumptions.
- No automatic conversions to/from strings.

---

### 010.6.2 `strings`

**Status:** v1.0 core

**Responsibilities:**

- String utilities:
  - `Contains`, `HasPrefix`, `HasSuffix`.
  - `Index`, `LastIndex`, etc.
  - `Trim`, `TrimSpace`, `ToLower`/`ToUpper` for ASCII (Unicode behavior must be explicitly defined).
- Safe, explicit iteration helpers (by byte, by rune) consistent with the UTF-8 model.

**Design constraints:**

- String indices are in **bytes**, not runes.
- No implicit normalization.
- Any Unicode-aware behavior must be explicitly documented and typically built on top of `utf8`.

---

### 010.6.3 `utf8`

**Status:** v1.0 core

**Responsibilities:**

- Low-level UTF-8 primitives:
  - Rune decoding and encoding.
  - Validation of byte sequences.
  - Counting runes, checking boundaries.

**Design constraints:**

- `utf8` is a **low-level building block**.
- Higher-level functions for working with textual data should live in `strings` and in future text packages.
- No normalization logic is built in; that would be part of a future, more advanced `text` package if needed.

---

## 010.7 Time & Scheduling

### 010.7.1 `time`

**Status:** v1.0 core (already defined in `ecosystem/003_Time.md`)

**Responsibilities:**

- Time representations:
  - `Duration`.
  - Monotonic vs wall-clock time.
- Utilities:
  - `Now`, monotonic clocks, `Sleep`, timers.
  - Arithmetic on durations and timestamps.

---

### 010.7.2 `executor`

**Status:** v1.0 core

**Responsibilities:**

- Library layer on top of `190_Concurrency.md` and `400_ExecutorAndTasks_Phase2.md`.
- Facilities for:
  - Task scheduling primitives that are too high-level or configurable to be keywords.
  - Task groups, pools, structured concurrency helpers.
  - Cancellation, deadline propagation.
  - Graceful shutdown of hierarchies of tasks.

**Design constraints:**

- No hidden global executor instance; users must construct executors explicitly or use well-documented defaults.
- The library must respect the concurrency rules of Ori (no implicit sharing without `shared`, etc.).
- Integrates with `time` for deadlines/timeouts.

---

## 010.8 Diagnostics & Formatting

### 010.8.1 `fmt`

**Status:** v1.0 core

**Responsibilities:**

- Human-oriented text formatting for:
  - Debugging.
  - CLI tools.
  - Simple user messages.
- Formatting APIs that do **not** rely on runtime reflection:
  - Type-safe formatting functions.
  - Interfaces for types that want to define custom formatting behavior (e.g. `Format`-style methods).

**Design constraints:**

- No `%v`-style “print anything by reflection”.
- No reflection-driven formatting like Go’s `fmt` package.
- For complex types, the user must implement explicit formatting behavior (or use generated code at compile time).
- `fmt` focuses on human readability; structured, machine-readable logging belongs to `log`.

---

### 010.8.2 `log`

**Status:** v1.0 core

**Responsibilities:**

- Structured logging with:
  - Log levels (e.g. Debug, Info, Warn, Error, Fatal).
  - Key-value pairs for context.
- Composable loggers:
  - Different outputs (stdout, file, in-memory).
  - Easily redirected during testing.
- Integration with `io`/`bufio` for performance and `fs` for file logging.

**Design constraints:**

- No global mutable “default logger”.
- Creating and passing loggers is explicit.
- No hidden threads or async behavior; if async logging exists, it must be explicit and documented.
- Deterministic destruction of log targets (e.g. closing log files) is mandatory.

---

## 010.9 Testing & Tooling

### 010.9.1 `testing`

**Status:** v1.0 core

**Responsibilities:**

- Standard test harness integration, consistent with `300_TestingFramework_Phase1/2.md`.
- Core types and helpers:
  - `TestContext`.
  - `t.Run`, `t.Parallel` (subject to language rules).
  - `t.Deadline` (top-level only, as per semantics).
  - OS filtering (e.g. skipping tests on unsupported platforms).
- Utilities for:
  - Temporary directories and files in a safe, controlled way.
  - Common assertions or helpers (if decided in the semantics).

**Design constraints:**

- No attributes/annotations such as `@test`.
- Tests are discovered by naming and `_test.ori` files, similar in spirit to Go but using Ori’s semantics.
- Integration with `time` and `executor` for deadlines and parallelism.

---

### 010.9.2 `testing/quick` (or equivalent)

**Status:** planned post-1.0

**Responsibilities:**

- Property-based / randomized testing tools.
- Generators for common data structures.

**Design constraints:**

- Must build on top of `testing` but not be required for basic unit testing.
- Might require more advanced compile-time support and should not block v1.0.

---

## 010.10 Planned Post-1.0 Packages

The following packages are **intentionally excluded from v1.0**, but are anticipated as natural evolutions of the ecosystem.

They are listed here to keep the big picture coherent.

### 010.10.1 `net`

**Status:** planned post-1.0

**Responsibilities:**

- Basic networking primitives (TCP, UDP).
- Name resolution.
- Timeouts for network operations (using `time` and possibly `executor`).

**Design constraints:**

- No HTTP or higher-level protocols in the initial `net`.
- No hidden global connection pools.

---

### 010.10.2 `json`

**Status:** planned post-1.0

**Responsibilities:**

- JSON encoder/decoder.
- APIs that do **not** depend on runtime reflection:
  - Users provide explicit encode/decode logic.
  - Optional compile-time helpers could generate boilerplate.

**Design constraints:**

- RFC-compliant, well-specified behavior.
- No hidden global config.

---

### 010.10.3 `hash` and `hash/*`

**Status:** planned post-1.0

**Responsibilities:**

- `hash`:
  - Common interface for hash functions (e.g. `Write([]byte)`, `Sum()`).
- `hash/sha256`, `hash/sha1`, `hash/sha512`, etc.:
  - Concrete implementations.

**Design constraints:**

- Deterministic and well-documented behavior.
- No automatic global registries.

---

### 010.10.4 `flag`

**Status:** planned post-1.0

**Responsibilities:**

- Command-line parsing for executables.

**Design constraints:**

- Safe defaults.
- No hidden global state; parsing is done through explicit objects passed to `main` or similar.

---

### 010.10.5 Advanced text packages (e.g. `text`, `text/normalize`)

**Status:** planned post-1.0

**Potential responsibilities:**

- Unicode normalization.
- Locale-aware operations.
- More advanced text manipulation than `strings`/`utf8`.

**Design constraints:**

- No implicit normalization in core types (`string` remains raw UTF-8).
- All heavy text features are opt-in via these packages.

---

## 010.11 Summary

For Ori v1.0, the **core standard library surface** is:
- `os`, `fs`, `filepath`
- `io`, `bufio`
- `strings`, `utf8`, `bytes`
- `time`, `executor`
- `fmt`, `log`
- `testing`

These packages:
- Follow the cleaner separation patterns seen in modern systems languages.
- Respect Ori’s strict rules on determinism, explicitness, and the absence of runtime reflection or global mutable state.

Future versions of the language and ecosystem will add:
- Networking (`net`),
- JSON (`json`),
- Hashing (`hash/*`),
- CLI helpers (`flag`),
- Advanced text and testing facilities,

without breaking the structure laid out in this catalog.

---


# 001. CompilerDiagnostics

## 001.1 Ori Compiler Diagnostics Specification

This document specifies the structure, behavior, and formatting rules for all compiler diagnostics in Ori.  
Diagnostics must be deterministic, explicit, and consistent across all tools.

---

## 001.2. Error Codes

All diagnostics use the following format:

```
ORIxxxx
```

- `ORI` is the fixed prefix for Ori diagnostics.
- `xxxx` is a four-digit numeric code.
- Leading zeroes are mandatory.
- Codes are grouped by functional domain (see below).

## 001.2.1 Error Code Ranges

**1000–1999 : Parsing & Lexing**

- unexpected token
- invalid literal
- malformed expression
- unterminated string/comment

**2000–2999 : Type System**

- type mismatch
- invalid assignment
- missing method
- incorrect interface implementation
- generics instantiation errors

**3000–3999 : Compile-Time & Reflection**

- invalid use of `comptime`
- invalid reflection query
- accessing missing fields through reflection

**4000–4999 : Memory & Ownership**
- illegal pointer operations
- invalid view after destruction
- mutation of non-shared value
- invalid lifetime or ownership transfer

**5000–5999 : Concurrency**

- invalid waits
- invalid channel operations
- misuse of `spawn` or concurrency primitives

**6000–6999 : Modules & Build**

- unresolved import
- circular module dependency
- symbol visibility issues

**7000–7999 : FFI**

- invalid extern type
- ABI-incompatible function signature
- misuse of `void` outside extern

**8000–8999 : Testing Framework**

- invalid test signature
- invalid test file naming

---

## 001.3 Diagnostic Message Structure

Every diagnostic must follow this exact format:

```
error ORI2043: cannot assign pointer to non-shared value
 --> main.ori:12:14
 12 |     p.x = 3
    |          ^ cannot modify field of non-shared value
help: mark the receiver as shared to enable mutation
```

## 001.3.1 Components

- **Header**
  - `error` or, rarely, `warning`
  - error code (e.g., `ORI2043`)
  - short description in lowercase, no period

- **Location**
  ```
  --> file:line:column
  ```

- **Context Snippet**
  - the exact line of code
  - a caret `^` marking the specific span
  - optional secondary labels

- **Help Section (optional)**
  ```
  help: a short actionable suggestion
  ```

- **Notes (optional)**
  ```
  note: additional context or previous definition
  ```

---

## 001.4 Errors vs Warnings

Ori aims to remove ambiguity in diagnostics.  
The following rules apply:

## 001.4.1 These are **compile-time errors** never warnings

- unused variable
- unused import
- unreachable code

Developers must fix these issues immediately.  
They cannot be suppressed, demoted, or ignored.

## 001.4.2 Valid Warning Categories (rare)

Only these may produce warnings:

1. **deprecated API usage**
2. **unnecessary explicit cast**
3. **non-exhaustive pattern matching** (when legal but likely unintended)
4. **overly broad visibility** (e.g., exposing internal type publicly)

Warnings are:
- minimal
- actionable
- never produced in high volume

## 001.4.3 Global Warning Behavior

- No per-error-code suppression mechanism.
- No per-file override.
- Only compiler flag:

```
--warnings-as-errors
```

---

## 001.5 Ordering of Diagnostics

To guarantee deterministic output in editors and CI, Ori enforces a strict ordering of diagnostics:

1. lexing errors
2. parsing errors
3. type system errors
4. memory & ownership errors
5. compile-time errors
6. reflection errors
7. concurrency errors
8. modules & build errors
9. FFI errors
10. testing errors

Within each category:
- sorted by `(file, line, column)`
- ties broken by numeric error code

---

## 001.6 Color & Formatting Rules

- Color is allowed but **never required**
- Diagnostic meaning must remain clear in plain text
- Color must not encode semantics (e.g., red for error is fine, but color alone cannot add meaning)

---

## 001.7 JSON Diagnostic Output

The compiler must support JSON diagnostics for tooling:

Flag:
```
--json-diagnostics
```

Output example:
```json
{
  "file": "main.ori",
  "line": 12,
  "column": 14,
  "code": "ORI2043",
  "severity": "error",
  "message": "cannot assign pointer to non-shared value",
  "help": "mark the receiver as shared to enable mutation"
}
```

This is a minimal, stable format intended for LSP servers, external tools, and CI systems.

---

## 001.8 Diagnostic Philosophy

Ori’s diagnostic system follows these principles:

- **Explicitness:** never hide potential issues
- **Predictability:** same input always yields same diagnostics in same order
- **Clarity:** messages are short and precise
- **Non-guessing:** compiler avoids speculative “did you mean?” suggestions
- **Compiler errors are a hard contract**, not stylistic hints.
- **Consistency:** all tools must use this spec

---

## 001.9 Examples

### Example 1 — Type mismatch
```
error ORI2021: expected int but got string
 --> math.ori:44:18
 44 |     var x int = "hello"
    |                  ^^^^^^ string here
help: convert the string or change the variable type
```

### Example 2 — Unused variable (compile-time error)
```
error ORI1103: variable 'value' is declared but never used
 --> main.ori:10:9
 10 |     var value = count()
    |         ^^^^^
help: remove the variable or use it
```

### Example 3 — Unreachable code
```
error ORI1301: unreachable code after return
 --> main.ori:22:5
 22 |     return x
    |     ^^^^^^^^
 23 |     fmt.println("never runs")
    |     ^^^^^^^^^^^^^^^^^^^^^^^^^ unreachable
```

---


# 002. LSP And Tooling

## 002.1 Overview of Ori Language Server Protocol (LSP) & Tooling Capabilities Specification

This document specifies the required Language Server Protocol (LSP) and tooling capabilities for Ori.  
The goal is to define a deterministic, explicit, and compiler-driven tooling experience aligned with Ori’s philosophy.

The Ori LSP does not attempt to guess developer intent. All semantic information must originate from the compiler’s official semantic engine, ensuring correctness, consistency, and predictability across all development environments.

---

## 002.2. Goals and Non-Goals

## 002.2.1 Goals

- Provide deterministic diagnostics consistent with compiler error rules
- Offer essential IDE support: navigation, hover info, and code outline
- Integrate tightly with the Ori compiler in "LSP mode" for semantic queries
- Support Ori language constructs including generics, interfaces, sum types, pointers, modules, and compile-time features
- Guarantee no deviation between compiler semantics and LSP behavior

---

## 002.2.2 Non-Goals

- Rename symbol capability (postponed)
- Auto-import suggestions
- LSP-driven refactoring
- Semantic guessing or heuristic symbol resolution
- Any feature that modifies code automatically beyond diagnostics

---

## 002.3. Overview of the Ori Tooling Architecture

Ori tooling consists of:
- The official Ori compiler, which provides parsing, AST construction, symbol tables, type inference, module resolution, semantic checking, and error reporting
- The Ori LSP server, which acts as a thin layer wrapping compiler functionality, exposing it through LSP APIs
- Editors and IDEs communicating with the LSP via standard LSP messages

The LSP must NOT replicate compiler logic. It must always delegate to the compiler for:
- Parsing
- Type resolution
- Semantic checks
- Module resolution
- Generic instantiation
- Sum type resolution
- Interface conformance checks

---

## 002.4. Interaction Between Compiler and LSP

## 002.4.1 Compiler LSP Mode
The Ori compiler exposes a stable interface ("LSP mode") allowing:
- Incremental parsing (file-by-file or buffer-by-buffer)
- Access to the AST for each file
- Access to the symbol table for each module
- Semantic analysis for changed files and dependent modules
- Error and diagnostic extraction in a stable JSON format
- Queries for definitions, symbol resolution, and type information
- Queries for module and import resolution

---

## 002.4.2 Incremental Analysis Rules

The compiler must support incremental re-analysis of:
- Modified files
- All files that depend on modified symbols
- Modules impacted by changed imports

Incremental analysis must be deterministic and follow the same rules as a full build.

---

## 002.5. Required Capabilities

## 002.5.1 Syntax Diagnostics

The LSP must provide parser-level errors including:
- Unexpected tokens
- Unmatched delimiters
- Invalid literals
- Incorrect statement structure
- Lexical errors

These diagnostics come straight from the compiler parser.

---

## 002.5.2 Semantic Diagnostics

The LSP must provide full compiler-driven semantic diagnostics including:
- Undefined identifier
- Type mismatch
- Incorrect number of arguments
- Invalid interface implementation
- Invalid pointer usage
- Violations of container ownership rules
- Invalid sum type variant access
- Invalid module imports
- Duplicate declarations
- Unused imports (compile-time error)
- Unreachable code (compile-time error)

All diagnostics must follow the compiler error format defined in `tooling/001_CompilerDiagnostics.md`

No diagnostic or error text must come from the LSP itself.

---

## 002.5.3 Symbol Resolution (Go-To Definition)

The LSP must support navigating to the definition of:
- Structs
- Interfaces
- Functions
- Methods
- Constants
- Types
- Generic instantiations (when instantiated)
- Sum type variants
- Module definitions
- Import targets

Resolution must follow the compiler's exact semantic rules.

---

## 002.5.4 Hover Information

The LSP must display:
- Type of the identifier or expression
- Symbol kind (struct, function, interface, sum type, const, etc.)
- Module path
- Source definition location
- For structs: list of fields with types
- For functions: full signature including generic parameters
- For comptime functions: [comptime] tag
- For extern items: [extern] tag
- For sum types: list of variants

Hover text must be deterministic.

---

## 002.5.5 Document Symbols (Outline)

The LSP must provide a hierarchical outline of:
- Structs
- Interfaces
- Sum types and variants
- Functions
- Comptime functions
- Constants

Symbols appear in source order (not alphabetical).

---

## 002.5.6 Text Synchronization

The LSP must support:
- Full document sync
- Optional incremental sync (if implemented)

The compiler must be able to parse unsaved buffers for real-time diagnostics.

---

## 002.6. Optional Capabilities (v1.0+)

## 002.6.1 Find References

Requires global indexing.
Postponed.

---

## 002.6.2 Rename

Rename must respect:
- Exported symbol constraints
- Interface contracts
- Module boundaries
- No shadowing

Postponed in future version.

---

## 002.6.3 Auto-Import Suggestions

Not allowed in current version.
Ori does not allow heuristic guesses.

---

## 002.6.4 Formatting

May be introduced later alongside a formatter design in `ecosystem/`.

---

## 002.7. Behavior With Advanced Language Features

## 002.7.1 Generics

- The LSP displays generic signatures
- Monomorphized instantiations are shown only if the compiler already emitted them
- No speculative instantiation

---

## 002.7.2 Sum Types

- Hover must display all variants and fields
- Go-to-definition jumps to variant definitions
- The LSP must respect compile-time variant safety rules

---

## 002.7.3 Interfaces

- Hover must display required methods
- Implementation relations come from semantic analysis only

---

## 002.7.4 Pointers and Container Ownership

- Hover must reflect pointer type, ownership, and mutability constraints
- Diagnostics integrate rules from:
  - `semantics/310_Pointers.md`
  - `semantics/260_ContainerOwnershipModel.md`

---

## 002.7.5 Modules and Imports

- LSP uses the compiler module resolver from `semantics/270_ModulesAndCompilationUnits.md`
- Handles:
  - absolute imports
  - relative imports
  - module root detection

---

## 002.7.6 Compile-Time Functions

- Hover marks functions as [comptime]
- Resolver must show comptime-only symbols clearly
- Reflection (if defined in compile-time reflection section) is exposed but not executed

---

## 002.8. Deterministic Behavior and Error Ordering

LSP diagnostics must follow the exact ordering rules of the compiler:
- Primary error first
- Secondary errors following source order
- Deterministic ordering for multi-error groups
- No editor-specific reordering

---

## 002.9. Examples

Example hover for function:
```
func Add(a int, b int) int
```
Defined in: `math/add.ori:14`

Example hover for struct:
```
type struct User {
    name string
    age  int
}
```
Defined in: `user/user.ori:3`

Example hover for sum type:
```
type Shape =
    | Circle { radius int }
    | Rect   { w int, h int }
```

----

## 002.10. Future Directions

Future improvements may include:
- Full rename support
- Auto-import completion
- Semantic code actions
- Integration with formatter
- Index-driven global queries

These are excluded from current version to preserve deterministic behavior and avoid speculative semantics.

---



© 2025 Ori Language — Design Spec
