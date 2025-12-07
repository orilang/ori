# 341 CompiletimeReflection Phase 3 – fmt-Oriented Extensions

This document defines **Phase 3** of Ori’s compile-time reflection (CTR) system.

Phase 3 is intentionally small and focused:
- It does **not** introduce runtime reflection.
- It does **not** add attributes/annotations or a macro system.
- It does **not** change the core `TypeInfo` shapes introduced in `340_CompiletimeReflection_Phase1And2.md`.

Instead, it:
1. Promotes a few previously "example-only" helpers to **first-class built-ins**.
2. Precisely defines the semantics of `TypeInfo.typeName` so it can be used reliably by formatting and diagnostics.
3. Clarifies ordering and naming guarantees for `StructInfo`, `EnumInfo`, and `SumTypeInfo` so that library code can safely derive debug-style printers and validators at compile time.

The primary consumers of these extensions are:
- The future `fmt` package (once specified in a later version),
- The logging framework,
- The compiler’s own diagnostics and error messages,
- Library code that wishes to offer explicit “derive” helpers built on top of CTR.

> Depends on: `semantics/250_Compiletime.md`, `semantics/340_CompiletimeReflection_Phase1And2.md`  
> Theme: Minimal, explicit extensions to compile-time reflection (CTR) required to support a type-safe, non-reflective formatting model and improved diagnostics.

---

## 341.1 Scope and Non‑Goals

### 341.1.1 In Scope

Phase 3 covers:
- New built-in `comptime` helpers:
  - `implements(T, I) bool` – checks if a type implements an interface at compile time.
  - `isComparable(T) bool` – checks if a type is comparable according to core semantics.
- A precise, canonical definition of `TypeInfo.typeName`:
  - For named types, built-in types, and composite types.
  - Suitable for `%T`-style formatting and compiler diagnostics.
- Clarified structural guarantees for:
  - `StructInfo` field ordering and naming,
  - `EnumInfo` variant ordering and naming,
  - `SumTypeInfo` variant ordering and payload invariants.

These refinements are designed to be sufficient for:
- Type-safe formatting (fmt),
- Logging that uses the same formatting rules,
- Simple "derive debug printer" libraries implemented entirely in user-space using CTR.

### 341.1.2 Out of Scope

Phase 3 does **not**:
- Introduce runtime reflection of any kind.
- Introduce user-visible attributes/annotations (e.g. `@derive`, `@tag`, etc.).
- Introduce AST manipulation or hygienic macros.
- Change the basic structure of `TypeInfo`, `StructInfo`, `EnumInfo`, `SumTypeInfo` as defined in `340_CompiletimeReflection_Phase1And2.md`.

Any future evolution in those directions must be done in separate phases and remain consistent with Ori’s principles of explicitness and predictability.

---

## 341.2 New Built-in Comptime Functions

This section introduces two **built-in compile-time functions** that are conceptually already present in Phase 1/2 examples, but become **normative** with Phase 3.

All built-ins in this section:
- May only be invoked in **compile-time** contexts (inside `comptime` functions or expressions as defined in `250_Compiletime.md`).
- Are pure and deterministic (no I/O, no side effects beyond compile-time state).

### 341.2.1 `implements(T, I) bool`

#### Signature

```ori
comptime func implements(T type, I type) bool
```

#### Semantics

- `T` and `I` must be valid types known at compile time.
- `I` **must be an interface type** (see `semantics/230_Interfaces.md`):
  - If `I` is not an interface, the compiler emits a compile-time error:
    ```ori
    comptime_error("implements: second argument must be an interface type")
    ```

- `implements(T, I)` returns `true` if and only if:
  - For every method `m` in the interface `I`, there exists a corresponding method `m` on `T` that:
    - Has the same name.
    - Has the same number of parameters and return values.
    - Has parameter and result types that are assignment-compatible according to the interface rules (no widening/weakening beyond what interfaces already allow).
    - Matches the same `shared`/`view` receiver semantics as required by `I`.

- If `T` is itself an interface:
  - `implements(T, I)` returns `true` if `T` is at least as strong as `I` (i.e. it includes all methods of `I` with compatible signatures).

This function does **not** depend on runtime behaviour. It inspects only compile-time type information.

#### Usage

This helper is intended to be used by:

- The `fmt` ecosystem:
  ```ori
  comptime func requireFormattable[T type]() {
      if !implements(T, fmt.Formattable) {
          comptime_error("T must implement fmt.Formattable")
      }
  }
  ```

- Logging and diagnostics helpers that want to enforce that a type implements a contract.

#### Errors

- Calling `implements` with a non-interface second parameter is a compile-time error.
- Calling `implements` in a non-compile-time context is a compile-time error.

---

### 341.2.2 `isComparable(T) bool`

#### Signature

```ori
comptime func isComparable(T type) bool
```

#### Semantics

- `T` must be a valid type known at compile time.
- `isComparable(T)` returns `true` if and only if values of type `T` can be compared using `==` and `!=` according to Ori’s core semantics.
- For **basic types** (booleans, numeric types, strings), comparability follows the rules defined in their respective semantics files.
- For **composite types**, the following rules apply:
  - Arrays: comparable if the element type is comparable.
  - Structs: comparable if **all fields** are comparable.
  - Enums: comparable if the language defines enums as comparable (typically yes, by tag).
  - Slices, maps, hash maps, and other reference-like types: comparability depends on the semantics defined for those container types (e.g. pointer equality or disallowed).

- For **sum types** and **interfaces**, comparability obeys the same rules as in the core semantics (usually disallowed or restricted).

This function does not attempt to guess or change the comparability rules; it reports them.

#### Usage

Typical use cases:
- Compile-time enforcement that a type used as a map key is comparable:
  ```ori
  comptime func ensureComparableKey[K type]() {
      if !isComparable(K) {
          comptime_error("map key type must be comparable")
      }
  }
  ```

- CTR-driven validators or generic data structures.

#### Errors

- Calling `isComparable` in a non-compile-time context is a compile-time error.

---

## 341.3 Canonical Type Names via `TypeInfo.typeName`

`TypeInfo` was introduced in Phase 1/2 as the primary descriptor for types known at compile time. It includes a `typeName: string` field usable for diagnostics and formatting.

Phase 3 **fixes the meaning** of `typeName` to be:
- Canonical,
- Deterministic,
- Human-readable,
- Suitable for `%T`-style formatting and compiler error messages.

### 341.3.1 General Rules

For any `TypeInfo` instance `info`:
- `info.typeName` is a UTF-8 string that uniquely identifies the type within the compilation unit (and, where appropriate, across modules).
- `typeName` is **stable** within a single compilation:
  - The same type always yields the same `typeName`.
  - Diferent named types yield diferent `typeName` even if structurally identical.

The exact formatting of `typeName` is specified below for each kind of type.

### 341.3.2 Built-in and Named Types

- For **built-in numeric types** (e.g. `int32`, `uint64`, `float64`), `typeName` is the exact keyword name:
  - `int32`, `uint64`, `float64`, etc.

- For **built-in non-numeric types**:
  - `bool`, `string`, and other built-ins use their keyword name (`bool`, `string`, etc.).

- For **user-defined named types**:
  - `typeName` is of the form:
    ```text
    <ModuleName>.<TypeName>
    ```

    where:

    - `<ModuleName>` is the logical module/package name determined by the module system (as defined in the modules semantics).
    - `<TypeName>` is the identifier as written in the source (case preserved).

  - For nested or internal types, the implementation may extend the scheme (e.g. with `$` or `/` separators), but must remain deterministic and consistent within a compilation.

### 341.3.3 Composite Types

Composite types whose shape is built from other types use a fixed grammar:

- **Slices**:
  ```text
  []<ElementName>
  ```

  e.g. `[]int32`, `[]mypkg.User`.

- **Arrays**:
  ```text
  [<N>]<ElementName>
  ```

  e.g. `[16]int32`, `[3]mypkg.Point`.

- **Maps**:
  ```text
  map[<KeyName>]<ValueName>
  ```

  e.g. `map[string]mypkg.User`.

- **HashMaps**:
  ```text
  hashmap[<KeyName>]<ValueName>
  ```

- **Pointers / references** (if present in the type system):
  ```text
  *<UnderlyingName>
  ```

- **Shared / view qualifiers**:
  ```text
  shared <UnderlyingName>
  view <UnderlyingName>
  ```

The exact set of composite forms depends on the core semantics; Phase 3 requires that:
- All composite types use a **documented, structured** spelling.
- Implementations use the same spelling for identical composite types.

### 341.3.4 Type Names and Formatting

The `fmt` and logging semantics may rely on:
- `TypeInfo.typeName` as the canonical string printed by `%T`-style formatting.
- Compiler diagnostics may use `typeName` when formatting types in error messages.

User code **may** also display `typeName` in its own diagnostics or logs. Parsing `typeName` is not guaranteed stable across versions, but the implementation should avoid gratuitous changes.

---

## 341.4 Structural Guarantees for `StructInfo`, `EnumInfo`, `SumTypeInfo`

Phase 3 does not introduce new fields into `StructInfo`, `EnumInfo`, or `SumTypeInfo`. Instead, it **strengthens guarantees** about:

- Ordering of elements,
- Naming,
- Presence/absence of payload descriptors.

These guarantees are minimal but sufficient to implement **library-level derive helpers** (including future formatting helpers) purely in user code.

### 341.4.1 `StructInfo` – Fields

Let:
```ori
type struct StructInfo {
    fields []FieldInfo
    // ...
}

type struct FieldInfo {
    name      string
    type      Type
    exported  bool
    // ...
}
```

then Phase 3 guarantees:
1. **Ordering**:
   - `fields` enumerates all fields of the struct in **source declaration order**.
2. **Naming**:
   - `FieldInfo.name` is exactly the identifier as written in the source (case preserved).
3. **Export flag**:
   - `FieldInfo.exported` is `true` if the field is exported according to Ori’s export rules (e.g. leading uppercase name if Ori follows Go-style exporting).
4. **Completeness**:
   - All fields declared in the struct are present in `fields`; there are no hidden fields.

These guarantees enable generic compile-time helpers like:
```ori
comptime func structFieldNames[T type]() []string {
    comptime const ti = typeinfo(T)
    if ti.kind != TypeKind.Struct {
        comptime_error("structFieldNames: T must be a struct")
    }

    var names []string
    for _, f := range ti.structInfo.fields {
        names = append(names, f.name)
    }
    return names
}
```

---

### 341.4.2 `EnumInfo` – Variants

Let:
```ori
type struct EnumInfo {
    variants []EnumVariantInfo
    // ...
}

type struct EnumVariantInfo {
    name string
    // ...
}
```

Phase 3 guarantees:
1. **Ordering**:
   - `variants` lists all enum variants in **source declaration order**.
2. **Naming**:
   - `EnumVariantInfo.name` is the variant identifier as written in the source (case preserved).
3. **Completeness**:
   - All variants declared in the enum are present; there are no implied or hidden variants.

This allows simple helpers such as:
```ori
comptime func enumVariantNames[T type]() []string {
    comptime const ti = typeinfo(T)
    if ti.kind != TypeKind.Enum {
        comptime_error("enumVariantNames: T must be an enum")
    }

    var names []string
    for _, v := range ti.enumInfo.variants {
        names = append(names, v.name)
    }
    return names
}
```

Such helpers are particularly useful for:
- Generic debug printers for enums,
- Validation, code generation, and documentation tooling.

---

### 341.4.3 `SumTypeInfo` – Variants and Payloads

Let:
```ori
type struct SumTypeInfo {
    variants []SumVariantInfo
    // ...
}

type struct SumVariantInfo {
    name       string
    hasPayload bool
    fields     []FieldInfo
    // ...
}
```

Phase 3 guarantees:
1. **Ordering**:
   - `variants` are listed in **source declaration order**.
2. **Naming**:
   - `name` is the variant identifier as written in the source.
3. **Payload invariants**:
   - If `hasPayload == false`, then `fields` is an empty slice.
   - If `hasPayload == true`, `fields` describes the payload components. The meaning of those fields (positional vs named) is whatever the sum-type semantics defined in `210_SumTypes.md`.
4. **Completeness**:
   - All variants of the sum type are present in `variants`.

These guarantees enable compile-time helpers that:
- Inspect which variants carry payloads,
- Generate default matching tables or debug print strategies,
- Enforce constraints (e.g. “this API only accepts sum types with no payload”).

---

## 341.5 Intended Usage Patterns

This section provides **non-normative** examples of how the Phase 3 features are expected to be used by libraries and tools.

### 341.5.1 Enforcing Interface Implementation

A typical pattern for enforcing that a type implements a given interface at compile time:
```ori
comptime func requireImplements[T type, I type]() {
    if !implements(T, I) {
        comptime_error("required interface not implemented")
    }
}
```

This is the pattern the future `fmt` package is expected to use internally (e.g. to ensure a type implements `fmt.Formattable` before calling its formatting method).

### 341.5.2 Compile-Time Struct Debug Formatter

A library may use CTR to build a generic "debug printer" for structs:
```ori
comptime func deriveStructDebugInfo[T type]() (fieldNames []string) {
    comptime const ti = typeinfo(T)
    if ti.kind != TypeKind.Struct {
        comptime_error("deriveStructDebugInfo: T must be a struct")
    }

    var names []string
    for _, f := range ti.structInfo.fields {
        names = append(names, f.name)
    }
    return names
}
```

At runtime, a debug formatter can then:
- Use these field names,
- Use field accessors on values of type `T`,
- Produce output like `StructName{field1=value1, field2=value2}` without runtime reflection.

### 341.5.3 Enum Name Lists

Similarly, for enums:
```ori
comptime func deriveEnumNames[T type]() []string {
    comptime const ti = typeinfo(T)
    if ti.kind != TypeKind.Enum {
        comptime_error("deriveEnumNames: T must be an enum")
    }

    var names []string
    for _, v := range ti.enumInfo.variants {
        names = append(names, v.name)
    }
    return names
}
```

Which can be used for:
- Logging / debugging,
- Converting enum variants to strings in error messages,
- Generating documentation.

### 341.5.4 Type-Directed Diagnostics via `typeName`

A compile-time diagnostic helper might use `TypeInfo.typeName`:
```ori
comptime func assertComparable[T type]() {
    if !isComparable(T) {
        comptime const ti = typeinfo(T)
        comptime_error("type " + ti.typeName + " is not comparable")
    }
}
```

This gives precise, stable type names in error messages without runtime reflection.

---

## 341.6 Purity, Determinism, and Limitations

All new built-ins and guarantees in Phase 3 obey the same **purity and determinism rules** as existing compile-time facilities:
- Compile-time functions cannot perform I/O,
- They cannot depend on runtime state,
- Their outputs must be deterministic for a given compilation.

The compiler is allowed to:
- Reject any use of `implements` or `isComparable` in non-compile-time contexts.
- Reject uses of CTR that would require runtime state.

The Phase 3 clarifications on `typeName`, `StructInfo`, `EnumInfo`, and `SumTypeInfo` are **guarantees**, not suggestions: all conforming compilers must adhere to them, so that code written against this spec behaves consistently across implementations.

---

## 341.7 Summary

Phase 3 extends Ori’s compile-time reflection with a small set of focused capabilities:
- **Built-ins**:
  - `implements(T, I) bool` – compile-time interface conformance checks.
  - `isComparable(T) bool` – compile-time comparability checks.
- **Naming**:
  - A canonical, deterministic definition of `TypeInfo.typeName`, suitable for `%T`-style formatting and diagnostics.
- **Structure**:
  - Strong ordering and naming guarantees for `StructInfo.fields`, `EnumInfo.variants`, and `SumTypeInfo.variants`.

These changes are sufficient to support:
- A non-reflective, type-safe formatting ecosystem (`fmt`),
- Logging built on the same formatting model,
- Richer compile-time diagnostics and library-level derive helpers while keeping Ori’s reflection model explicit, annotation-free, and entirely limited to compile-time.
