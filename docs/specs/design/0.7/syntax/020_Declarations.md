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
