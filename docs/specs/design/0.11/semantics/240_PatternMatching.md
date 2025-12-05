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
