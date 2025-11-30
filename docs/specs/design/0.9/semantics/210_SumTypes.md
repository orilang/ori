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
