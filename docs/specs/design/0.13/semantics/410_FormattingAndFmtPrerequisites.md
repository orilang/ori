# 410. Formatting Contract and Fmt Prerequisites

This document defines the **core formatting contract** in Ori.  
It provides the semantic building blocks that a future `fmt` package, the logging framework, and other libraries can reuse.

Key ideas:
- Formatting is **library-based**, not a language feature.
- Formatting is **type-directed and explicit**, not reflection-driven.
- Compile-time reflection (CTR) is used only for **validation and optional derives**, not for magic.
- Formatting writes **directly into sinks**; it does not allocate large intermediate strings implicitly.

`410_FormattingAndFmtPrerequisites.md` does **not** specify the `fmt` package API (`Printf`, `Sprintf`, etc.).  
That surface lives in `ecosystem/004_FmtPackageFoundations.md`. This file only defines the **semantic contract** any formatting engine must obey.

> Depends on:
> - `semantics/140_Errors.md` (error semantics)
> - `semantics/150_TypesAndMemory.md`
> - `semantics/190_Concurrency.md`
> - `semantics/220_DeterministicDestruction.md`
> - `semantics/340_CompiletimeReflection.md` and `semantics/341_CompiletimeReflection_Phase3.md`
> - `semantics/360_StringBuilder.md`
> - `semantics/370_FileSystemAndIO.md`
> - `ecosystem/003_Time.md`
> - future `ecosystem/004_FmtPackageFoundations.md`

---

## 410.1 Goals and Non‑Goals

### 410.1.1 Goals

The formatting contract MUST:
1. Provide a minimal, explicit set of abstractions:
   - sinks that accept formatted text
   - formatting context and spec (kind, width, precision, alignment)
   - interfaces that types can implement to control their formatting
2. Cover all core built-in types:
   - booleans, integers, floats, strings
   - error types
   - time values
3. Integrate cleanly with:
   - compile-time reflection for optional derives (CTR Phase 3)
   - logging (to be extended in `381_LoggingFramework_Phase2.md`)
4. Support type‑safe format checking:
   - High-level APIs (fmt, logging) can reject type/verb mismatches at compile time when possible.
5. Avoid hidden runtime reflection, attributes, and global magic.

### 410.1.2 Non‑Goals

This file does **not**:
- Define `fmt` functions (`Print`, `Printf`, `Sprint`, etc.).
- Define any format string syntax (e.g. `%8.2f`); that belongs to **format string semantics** in syntax/semantics documents.
- Define localization/i18n or templating.
- Define structured logging semantics (covered in `380_LoggingFramework_Phase1.md` and its Phase 2 extension).

---

## 410.2 Core Concepts

Formatting in Ori is modeled around three core concepts:

1. **Format sink**  
   A minimal interface that accepts formatted text (`string`/`rune`) and may fail with an `Error`.

2. **Format specification**  
   A structured description of *how* a value should be formatted:
   - which “kind” of formatting (text, debug, decimal int, float, hex, etc.),
   - width, precision, and alignment.

3. **Formattable interfaces**  
   Types can implement interfaces to explicitly control their formatted output.

Higher-level libraries like `fmt` and logging:
- Translate user input (format strings, structured log fields, etc.) into a `FormatSpec`
- Call the appropriate formatting function for each value with a `FormatContext`

---

## 410.3 Format Sink

### 410.3.1 `FormatSink` Interface

A **format sink** is any value that can receive formatted text:
```ori
type interface FormatSink {
    WriteString(s string) Error
    WriteRune(r rune) Error
}
```

Rules:
1. **Atomicity per call**  
   - Each `WriteString` or `WriteRune` call is treated as an atomic unit:
     - Either it succeeds and writes the entire string/rune,
     - Or it fails and writes nothing
2. **Ordering**  
   - A formatting engine MUST invoke sink methods in the order it wants the text to appear
   - The sink MUST preserve this order for a single formatting operation
3. **Error handling**  
   - If `WriteString` or `WriteRune` returns a non‑nil `Error`, the formatting engine MUST:
     - stop formatting the current value, and
     - propagate the error

Sinks may wrap:
- `StringBuilder` (in‑memory accumulation)
- `File` (for console or file output)
- Logging buffers
- Any other string/rune consumer

### 410.3.2 Relationship with IO/Logging Writers

Phase 1 of the logging framework defines a `Writer` interface:
```ori
type interface Writer {
    Write(buf []byte) (int, error)
}
```

The **binary writer** concept (`Writer`) and **text sink** (`FormatSink`) are distinct but composable:
- A `Writer` can be adapted to a `FormatSink` by encoding `string`/`rune` as UTF‑8 bytes and calling `Write`
- A `FormatSink` can be adapted to a `Writer` by decoding bytes as UTF‑8 and calling `WriteString` (if needed)

This file does not mandate a particular adapter type but assumes such adapters exist in the standard library.

---

## 410.4 Format Specification

### 410.4.1 `FormatKind`

Formatting behaviour is driven by a finite set of **format kinds**:

```ori
type enum FormatKind {
    // generic text domains
    Text        // human‑oriented text representation
    Debug       // developer / introspection representation

    // integers
    IntDecimal      // signed decimal
    IntUnsigned     // unsigned decimal
    IntHexLower     // lower‑case hexadecimal
    IntHexUpper     // upper‑case hexadecimal
    IntBinary       // binary

    // floats
    FloatFixed      // fixed‑point decimal (e.g. 3.14)
    FloatScientific // scientific notation (e.g. 3.14e+00)

    // meta
    TypeName        // print canonical type name
}
```

The exact mapping between **verbs** in format strings and `FormatKind` is defined elsewhere  
(e.g. `%d` → `IntDecimal`, `%f` → `FloatFixed`, `%T` → `TypeName`).

### 410.4.2 Alignment

```ori
type enum Align {
    Default
    Left
    Right
}
```

- `Default` leaves alignment up to the formatting engine or type.
- `Right` and `Left` behave as specified by width rules below.

### 410.4.3 `FormatSpec` and `FormatContext`

A **format specification** is represented as:
```ori
type struct FormatSpec {
    kind      FormatKind
    width     int  // minimum field width; -1 = unspecified
    precision int  // interpretation depends on kind; -1 = unspecified
    align     Align
}
```

The **format context** passed to formatting methods is:

```ori
type struct FormatContext {
    sink  FormatSink
    spec  FormatSpec
}
```

Rules:
1. `width` is a **minimum display width in characters**:
   - If produced text is shorter than `width`, the formatter pads with spaces:
     - `align == Right` or `Default` for numbers → pad on the left,
     - `align == Left` → pad on the right.
   - If produced text is longer than `width`, it is never truncated; `width` is a minimum, not a maximum.
2. `precision`:
   - For float kinds:
     - If `precision == -1`, a type‑specific default is used (e.g. 6 digits after decimal).
     - If `precision >= 0`, that many digits after the decimal point (for `FloatFixed`) or after the decimal in mantissa (for `FloatScientific`).
   - For other kinds, `precision` is ignored unless specified otherwise in built‑in rules.

`FormatContext` is **short‑lived**:
- It is valid only for the duration of a single formatting operation.
- Implementations MUST NOT store `*FormatContext` beyond the call where they receive it.

---

## 410.5 Formattable Interfaces

### 410.5.1 `Formattable`

The primary interface for human‑oriented formatting:
```ori
type interface Formattable {
    Format(ctx *FormatContext) Error
}
```

Rules:
1. Implementations read `ctx.spec.kind`, `ctx.spec.width`, etc. and write to `ctx.sink`.
2. Implementations MAY:
   - ignore width/precision/alignment if they do not make sense for the type
   - but MUST remain deterministic and not panic under normal conditions
3. If the type does not recognize a particular `FormatKind`, it SHOULD return an `Error` indicating unsupported format.

### 410.5.2 `DebugFormattable`

A secondary interface for developer/debug output:
```ori
type interface DebugFormattable {
    FormatDebug(ctx *FormatContext) Error
}
```

Typical behaviour:
- Display more structural information,
- Show field names,
- Include tags or internal state that is not suitable for end users.

### 410.5.3 Dispatch Rules (Conceptual)

A formatting engine that wants to format a value `v` of static type `T` with `FormatSpec spec` typically performs:
1. If `spec.kind == FormatKind.TypeName`:
   - Use CTR to obtain `TypeInfo` and write `TypeInfo.typeName` to the sink. fileciteturn0file2  

2. Else if `spec.kind == Debug` **and** `T` implements `DebugFormattable`:
   - Call `v.FormatDebug(&ctx)`.

3. Else if `T` implements `Formattable`:
   - Call `v.Format(&ctx)`.

4. Else if `T` is one of the **built-in types** with built‑in formatting behaviour (410.6):
   - Apply the built-in rules.

5. Else:
   - This `(T, FormatSpec)` combination is unsupported:
     - If the format spec is known at compile time, high-level APIs SHOULD treat this as a **compile‑time error**.  
     - Otherwise, they MAY fail at runtime with an `Error`.

The exact dispatch mechanism (interface checks, generics, etc.) is an implementation choice, but the observable behaviour MUST follow these rules.

---

## 410.6 Built‑in Formatting Semantics

The following subsections define **default formatting behaviour** for core built‑in types.  
These are used when no user‑defined `Formattable`/`DebugFormattable` is involved.

### 410.6.1 Strings

Type: `string`

- Supported kinds:
  - `Text`
  - `Debug` (same as `Text` for plain strings)
- Behaviour:
  - Write the string’s bytes as UTF‑8.
  - Apply `width`/`align` padding as described in `410.4`.
  - `precision` is ignored.
- Unsupported kinds:
  - Integer kinds, float kinds, `TypeName` (unless explicitly mapped by a higher-level API) are invalid for runtime values of type `string`.

### 410.6.2 Booleans

Type: `bool`

- Supported kinds:
  - `Text`, `Debug`:
    - `true` → `"true"`, `false` → `"false"`.
- Numeric kinds (`IntDecimal`, etc.) are invalid.

Width/alignment work as for strings.

### 410.6.3 Integers

Applies to all built-in integer types (signed and unsigned).

Supported kinds:
- `IntDecimal`:
  - Signed decimal representation (with leading `-` for negative values).
- `IntUnsigned`:
  - Unsigned decimal. For signed types, behaviour is unspecified or disallowed unless explicitly supported by the API.
- `IntHexLower` / `IntHexUpper`:
  - Lower-/upper-case hexadecimal, no `0x` prefix.
- `IntBinary`:
  - Binary representation without `0b` prefix.
- `Text`:
  - Same as `IntDecimal` by default.
- `Debug`:
  - Same as `IntDecimal`, or extended with type name at the discretion of the formatting engine.

Width/alignment:
- `width` and `align` apply as described in 410.4.
- `precision` is ignored.

Any float-only kind (`FloatFixed`, `FloatScientific`) is invalid for integers.

### 410.6.4 Floats

Applies to built-in float types (`float32`, `float64`, etc.).

Supported kinds:
- `FloatFixed`:
  - Fixed-point decimal.
  - If `precision == -1`, a default precision is used (language recommendation: 6 digits after decimal).
  - If `precision >= 0`, exactly that many digits after the decimal point are printed, rounding according to Ori’s numeric semantics.
- `FloatScientific`:
  - Scientific notation, e.g. `-1.234000e+03`.
  - Same precision rules as `FloatFixed`.
- `Text`:
  - An implementation-chosen default float representation; typically `FloatFixed` with default precision.
- `Debug`:
  - May include additional details (e.g. `float64(1.23)`) at the discretion of the formatter.

Width/alignment:
- `width` and `align` apply as described in `410.4`.

Integer-only kinds (`IntDecimal`, `IntHexLower`, etc.) are invalid for floats.

### 410.6.5 Errors

Type: the language’s standard error type (as specified in `140_Errors.md`).

- Supported kinds:
  - `Text`:
    - Print the error message string (as defined by the error semantics, e.g. `Error.Message()`).
  - `Debug`:
    - May include error type and additional debug information.
- Other kinds (numeric, floats, `TypeName`) are invalid for error values as values.

Width/alignment are applied to the resulting string representation.

### 410.6.6 Time Values

Time values come from the `time` package (`ecosystem/003_Time.md`):
- `Text`:
  - Uses a default, stable, human-readable layout (e.g. RFC 3339 or a spec-defined pattern).
- `Debug`:
  - May include more precise internal representation (monotonic components, timezone, etc.).
- Numeric and float kinds are invalid by default, unless explicitly mapped by a higher-level API.

The exact default layout is defined in the time semantics, not here.

---

## 410.7 Errors and Allocation Rules

### 410.7.1 Error Propagation

- If a formatting method (built-in or user-defined) encounters an error from `FormatSink`:
  - It MUST stop writing further data.
  - It MUST propagate that `Error` to its caller.

- If a formatting method finds that the `FormatKind` is unsupported for the given type:
  - It SHOULD return an `Error` describing the unsupported combination.
  - High-level APIs are responsible for deciding whether to turn this into:
    - a compile-time error (if known at compile time), or
    - a runtime failure.

### 410.7.2 No Hidden Large Allocations

Formatting engines and implementations SHOULD:
- Prefer writing directly to `FormatSink` without building large intermediate strings.
- Avoid per-call heap allocations for common cases where possible.

This is a **performance recommendation**, not an observable semantic requirement, but aligns with Ori’s design goals for predictability and memory usage.

---

## 410.8 Interaction with CTR Phase 3

CTR Phase 3 introduces:
- `implements(T, I) bool` – compile-time interface conformance
- `isComparable(T) bool`
- Canonical `TypeInfo.typeName`
- Strong ordering/naming guarantees for struct, enum, sum-type metadata

Formatting libraries MAY:
- Use `implements(T, Formattable)` and `implements(T, DebugFormattable)` at compile time to:
  - select specializations
  - produce better error messages
- Use `TypeInfo.typeName` to implement `%T`-style functionality (`FormatKind.TypeName`)

This contract ensures that the formatting system can be both:
- **Type-safe and explicit** (no runtime reflection)
- **Extensible** (user types can implement interfaces or use library-provided derive helpers)

---

## 410.9 Interaction with Logging and Testing

`Logging Phase 1` uses structured logging and a binary `Writer` abstraction. 
`Logging Phase 2` (separate document) will:
- Add **formatting-aware log message APIs** (e.g. `Infof`-style).
- Define that:
  - log message formatting uses the same `FormatSpec`,`FormatKind`, and interfaces defined here
  - logs do not format messages when a log level is disabled

The testing framework’s `t.Logf` (defined in `300_TestingFramework_Phase2.md`) may also reuse the same formatting contract for consistency.

---

## 410.10 Out of Scope and Future Work

Future versions may add:
- Additional `FormatKind` variants (octal, URL‑escaped, JSON, etc.).
- More specialized formatting interfaces (e.g. `HexFormattable`, `BinaryFormattable`).
- Derived debug/text formatting for structs/enums/sum-types implemented as libraries on top of CTR.

These must respect the same core principles:
- No runtime reflection,
- No attributes,
- Explicit, interface-driven semantics.

---

## 410.11 Summary

This file defines the **core contract** for formatting in Ori:

- `FormatSink` for writing text with explicit error handling.
- `FormatKind`, `FormatSpec`, `FormatContext` as the abstract description of “how to format”.
- `Formattable` and `DebugFormattable` as the key interfaces for user-defined types.
- Built-in formatting rules for strings, booleans, integers, floats, errors, and time.
- Error and allocation guidelines for predictable, efficient formatting.
- Integration points with CTR Phase 3, logging, and testing.

With this contract in place, the `fmt` package and logging Phase 2 can be designed in a way that is **type-safe, explicit, and consistent** with the rest of the Ori language and standard library.
