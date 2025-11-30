# 340. Compile-Time Reflection (CTR)

## 340.1 Overview

Compile-Time Reflection (CTR) allows compile-time functions to inspect type metadata in a
safe, pure, deterministic, read-only manner.

CTR in Ori is intentionally minimal:
- It does NOT allow macros
- It does NOT allow code generation
- It does NOT allow AST or token manipulation
- It does NOT expose any runtime reflection
- It only provides structured type metadata accessible at compile time

CTR is designed to support:
- compile-time interface conformance checks
- generic constraints based on type structure
- validation of struct fields and sum variants
- safe introspection that cannot affect runtime behavior

CTR is fully compatible with the rules of CTE defined in `250_Compiletime.md`.

---

## 340.2 The `typeinfo` Built-In

Compile-time metadata is accessed through:
```ori
comptime const info = typeinfo(T)
```
Where `T` is any compile-time-known type.  
Constraints:
- `typeinfo(T)` may only appear inside:
  - a `comptime func`
  - a function with compile-time const parameters
  - a `comptime const` declaration
- Calling `typeinfo` at runtime is forbidden.
- `typeinfo` returns a compile-time constant value of type `TypeInfo`.

---

## 340.3 TypeInfo Metadata Structure

Reflection in Phase 1 exposes only essential fields.
```ori
type struct TypeInfo {
    kind         TypeKind
    name         string
    size         int
    alignment    int

    structInfo     StructInfo
    sumInfo        SumInfo
    interfaceInfo  InterfaceInfo
}
```

### 340.3.1 TypeKind

```ori
type enum TypeKind {
    Int, Float, Bool, String,
    Array, Slice,
    Struct, Sum, Interface,
    Pointer
}
```

`Slice` and `Pointer` do not expose internals in Phase 1.

> Note:  enum type is only used as a representation for now but not implemented

---

## 340.4 Struct Metadata

```ori
type struct StructInfo {
    fields []FieldInfo
}
```

Each declared field:
```ori
type struct FieldInfo {
    name   string
    type   Type
    offset int
}
```

Notes:
- Offset is a simple integer; no pointer arithmetic is allowed
- Field order matches declaration order

---

## 340.5 Sum Type Metadata

```ori
type struct SumInfo {
    variants []VariantInfo
}
```

Each variant:
```ori
type struct VariantInfo {
    name string
    fields []FieldInfo // defined in 340.4 section
}
```

---

## 340.6 Interface Metadata

```ori
type struct InterfaceInfo {
    methods []MethodInfo
}
```

Each method:
```ori
type struct MethodInfo {
    name string
    sig  FunctionSignature
}
```

`FunctionSignature` is the same type used by the compiler to describe function types.

This enables compile-time verification that a type provides all required methods of an interface.

---

## 340.7 CTR Restrictions

CTR follows all restrictions of CTE (250_Compiletime.md). In addition:

### 340.7.1 Forbidden in CTR

- Creating or modifying TypeInfo values
- Generating functions or code
- Expanding or rewriting types
- Accessing runtime data
- Using reflection at runtime
- Performing IO, concurrency, allocation, or mutation
- Any form of metaprogramming beyond read-only metadata

### 340.7.2 Allowed

- Reading metadata
- Iterating over struct fields, interface methods, or sum variants
- Conditional logic using metadata
- Issuing compile-time errors via `comptime_error`

CTR is guaranteed to be:
- pure
- deterministic
- side-effect-free

---

## 340.8 Examples

### 340.8.1 Example: Ensuring a Struct Has No Pointer Fields

```ori
comptime func ensureNoPointers(T type) {
    const info = typeinfo(T)

    if info.kind != TypeKind.Struct {
        comptime_error("expected a struct")
    }

    for f := range info.structInfo.fields {
        const fieldInfo = typeinfo(f.type)
        if fieldInfo.kind == TypeKind.Pointer {
            comptime_error("struct contains forbidden pointer field: " + f.name)
        }
    }
}
```

---

### 340.8.2 Example: Validating That a Type Implements an Interface
```ori
comptime func ensureImplements(T type, I type) {
    const tinfo = typeinfo(T)
    const iinfo = typeinfo(I)

    if iinfo.kind != TypeKind.Interface {
        comptime_error("expected interface type")
    }

    for m := range iinfo.interfaceInfo.methods {
        if !T.hasMethod(m.name, m.sig) {
            comptime_error("type does not implement method: " + m.name)
        }
    }
}
```

Note:
`T.hasMethod` is a built-in compile-time utility provided by the compiler in Phase 1.

---

### 340.8.3 Example: Ensuring All Fields Are Comparable

Some generic algorithms (sorting, maps keys, sets) require that a type is totally comparable.  
Reflection makes this trivial.

```ori
comptime func ensureComparable(T type) {
    const info = typeinfo(T)

    if info.kind != TypeKind.Struct {
        comptime_error("expected a struct for comparability check")
    }

    for f := range info.structInfo.fields {
        const fi = typeinfo(f.type)

        // Allowed comparable kinds (Phase 1)
        if fi.kind != TypeKind.Int
           && fi.kind != TypeKind.Float
           && fi.kind != TypeKind.Bool
           && fi.kind != TypeKind.String {
            comptime_error("field " + f.name + " is not comparable")
        }
    }
}
```

Use:
```ori
func sortPair[T](value T) {
  comptime ensureComparable(T) // Safe: T can be compared field-by-field
}
```

---

### 340.8.4 Example: Enforcing Interface Implementation

Developers often want additional structural guarantees inside generic functions.  
Even though Ori requires explicit interface declarations (`T implements Serializable`), CTR allows additional compile-time validation to ensure a type fully satisfies the interface before use.  
This keeps the philosophy intact: **explicit implementation + optional structural validation**.

CTR allows natural structural validation.

```ori
comptime func ensureImplementsSerializable(T type) {
    const iface = typeinfo(Serializable)

    for m := range iface.interfaceInfo.methods {
        if !T.hasMethod(m.name, m.sig) {
            comptime_error(
                "type " + T.name +
                " does not implement method: " + m.name
            )
        }
    }
}

type interface Serializable {
    serialize() string
}

type struct User {
    name string
}

func (self User) serialize() string {
    return self.name
}

User implements Serializable   // REQUIRED in Ori

```

Use:
```ori
func save[T](x T) {
    comptime ensureImplementsSerializable(T) // safe: T correctly implements Serializable
}
```

### 340.8.5 Example: Validating Sum Type Variants

Useful for designing domain-specific structures or enforcing invariants.

```ori
comptime func ensureTwoVariants(T type) {
    const info = typeinfo(T)

    if info.kind != TypeKind.Sum {
        comptime_error("expected a sum type")
    }

    if len(info.sumInfo.variants) != 2 {
        comptime_error("sum type must have exactly two variants")
    }
}
```

Use:
```ori
type Result[T] =
    | Ok(value T)
    | Err(message string)

comptime ensureTwoVariants(Result[int])
```

This ensures the Result pattern is followed correctly.

---

### 340.8.6 Example: Preventing Recursive Struct Definitions

Recursive structures are dangerous unless wrapped in pointers.
CTR enables enforcing a rule like "no struct may contain a field of its own type".

```ori
comptime func ensureNonRecursive(T type) {
    const info = typeinfo(T)

    if info.kind != TypeKind.Struct {
        return
    }

    for f := range info.structInfo.fields {
        if f.type == T {
            comptime_error("recursive struct is not allowed: field " + f.name)
        }
    }
}
```

Use:
```ori
type struct Node {
    value int
    next  Node   // invalid! should be *Node
}

comptime ensureNonRecursive(Node)
```

Compiler error:
```ori
error: recursive struct is not allowed: field next
```

---

### 340.8.7 Example: Size-or-Alignment Constrained Types

```ori
comptime func ensureSmall(T type, max int) {
    const info = typeinfo(T)

    if info.size > max {
        comptime_error("type too large: " + info.name)
    }
}
```

Use:
```ori
func storeInCache[T](value T) {
    comptime ensureSmall(T, 32)
}
```

---

## 340.9 Purpose of CTR Phase 1

CTR is intentionally limited to introspection for now.  
Its goals are:
- Providing a stable foundation for safe generic constraints
- Enabling compile-time structural validation
- Preparing for future expansions without introducing macro-style features

CTR Phase 1 does NOT attempt to:
- Replace language features with metaprogramming
- Provide dynamic reflection
- Allow compile-time manipulation of code or AST

---

## 340.10 Summary

CTR Phase 1 introduces:
- the `typeinfo(T)` built-in
- safe structured metadata types: TypeInfo, StructInfo, SumInfo, InterfaceInfo
- read-only introspection usable inside comptime functions
- no macros, no codegen, no runtime reflection

This preserves Ori’s core principles:
- simplicity
- explicitness
- compile-time safety
- predictable behavior
