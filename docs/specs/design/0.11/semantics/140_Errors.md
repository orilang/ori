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
