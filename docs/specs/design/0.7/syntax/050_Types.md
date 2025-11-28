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
