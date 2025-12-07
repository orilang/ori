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
