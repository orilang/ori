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

Ori enforces explicit typing for numeric types to privent ambiguity and unsafe coercions.

#### Rules

| Category | Inference | Example | Behavior |
|-----------|------------|----------|-----------|
| Integer   | ❌ explicit | `var x int = 10` | Must specify numeric type |
| Float     | ❌ explicit | `var y float = 1.5` | Must specify type |
| Boolean   | ✅ inferred | `var ok = true` | Inferred |
| String    | ✅ inferred | `var name = "Ori"` | Inferred |
| Other types | ✅ inferred | `var arr = [1, 2, 3]` | Inferred |

#### Reasoning

Prevents silent int↔float coercions.\
Improves determinism and low-level safety.\
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

Ori **does not** perform automatic zero-initialization.\
Every variable must be **fully initialized** before use.
Uninitialized variable **cannot** be read or used which will result in compile-time error.\
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

Use short or meaningful names for local variables.\
Prefer `const` when immutability is guaranteed.\
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

Global variables refer to values declared at the package level and accessible from any scope within that package.\
While convenient, they introduce implicit dependencies, hidden state, and concurrency risks.\
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
