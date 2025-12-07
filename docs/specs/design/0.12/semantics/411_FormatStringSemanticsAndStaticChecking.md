# 411. Format String Semantics and Static Checking

This document defines how **format strings** are interpreted by the compiler and how **static checking** of format-aware calls works.

It does **not** specify the complete `fmt` package API. Instead, it provides a language-level contract that `fmt`, the testing framework, and the logging framework packages can rely on.

> **Depends on:**
> - 341. Compile-Time Reflection – Phase 3 (fmt-oriented)
> - 410. Formatting and Fmt Prerequisites

---

## 411.1 Goals and Non‑Goals

### 411.1.1 Goals

- Define a precise **syntax** for format conversions using Wirth Syntax Notation (WSN).
- Define when the compiler **statically validates** calls that use format strings.
- Define **verb–type compatibility**, so mismatches become *compile-time errors* in checked calls.
- Provide a safe and explicit **debug verb** (`%?`) that integrates with compile-time reflection and the formatting contract.

### 411.1.2 Non‑Goals

- Do not define the full API surface of the `fmt` package.
- Do not introduce runtime reflection or attributes.
- Do not handle localization / i18n or templating.

---

## 411.2 Format‑Aware Functions

A **format‑aware function** is a function whose calls must be statically checked when a compile‑time constant format string is passed.

Format‑aware functions are **fixed by the language and standard library design**. Examples (future / conceptual):
- `fmt.Printf(format string, args ...any)`
- `fmt.Sprintf(format string, args ...any)`
- `fmt.Fprintf(w Writer, format string, args ...any)`

Existing designs that are format‑aware:
- Testing framework: `t.Logf(format string, args ...any)`
- Logging framework (Phase 2): `logger.Debugf`, `logger.Infof`, `logger.Warnf`, `logger.Errorf`

Each format‑aware function is specified by:
- Its **name** and package, and
- The **index of the format parameter** (e.g. `0` for `fmt.Printf`, `1` for `fmt.Fprintf`).

> **Note:** User code cannot mark arbitrary functions as format‑aware. Static format checking is reserved for a small, explicitly specified set of functions.

---

## 411.3 When Static Checking Applies

A call is **statically format‑checked** if and only if all of the following hold:
1. The callee is a **format‑aware function**.
2. The designated `format` argument is a **compile‑time constant string**:
   - a string literal, or
   - a compile‑time constant expression fully evaluable at compile time.
3. The remaining arguments are passed directly at the call site.

If any condition does not hold, **no static format checking** is performed for that call. The call may still fail at runtime (for example if the format string is malformed).

Examples:
```ori
// Checked: literal format string, known format-aware function.
fmt.Printf("x = %d, y = %d", x, y)

// Not checked: format string is a runtime value.
var f = readConfigFormat()
fmt.Printf(f, x, y)         // may succeed or fail at runtime, no compile-time validation
```

---

## 411.4 Format String Grammar (WSN)

### 411.4.1 Conversion Syntax

Format strings consist of ordinary characters and **conversions** beginning with `%`. The internal structure of a conversion is defined using Wirth Syntax Notation.

```wsn
Conversion   = "%" ( "%" | VerbSpec ) .

VerbSpec     = [ Flags ] [ Width ] [ Precision ] Verb .

Flags        = { FlagChar } .
FlagChar     = "-" | "0" | "+" .

Width        = Digit { Digit } .
Precision    = "." Digit { Digit } .

Digit        = "0" | "1" | "2" | "3" | "4"
             | "5" | "6" | "7" | "8" | "9" .

Verb         = "d" | "b" | "o" | "x" | "X"
             | "f" | "e"
             | "s" | "q"
             | "t"
             | "T"
             | "?" .
```

Informally:
- `"%%"` is a **literal percent sign** conversion and consumes no argument.
- All other conversions match `VerbSpec` and consume exactly one argument.

The exact relation between `Conversion` and the overall string literal syntax is defined in `015_Literals.md`. This document only specifies the structure of the `%...` part.

### 411.4.2 Validity

For calls that are statically checked (see 411.3):
- Any `%` that does not start a valid `Conversion` according to this grammar is a **compile‑time error**.
- Any invalid combination of flags, width, precision, or verb is also a **compile‑time error**.

---

## 411.5 Type Categories

For static checking, argument types are mapped to **type categories**:
- **Integer types**
  - All built‑in signed and unsigned integer types.
  - Enum types whose underlying representation is an integer.

- **Float types**
  - All built‑in floating‑point types.

- **Bool**
  - `bool`.

- **Text‑like types**
  - `string`
  - `[]byte`
  - `[]rune`
  - `rune`

- **Any value type**
  - Any well‑formed type in Ori (used for `%T` and `%?`).

This categorization is only for static checking. The actual formatting behaviour is defined in the general formatting contract (410).

---

## 411.6 Verb–Type Compatibility

The compiler checks whether each verb in the format string is compatible with the corresponding argument’s type category.

### 411.6.1 Integer and Enum Verbs

- `%d` — decimal integer  
  Allowed: integer types, enum types.

- `%b` — binary representation  
  Allowed: integer types.

- `%o` — octal representation  
  Allowed: integer types.

- `%x`, `%X` — hexadecimal (lower/upper)  
  Allowed: integer types.

### 411.6.2 Float Verbs

- `%f` — decimal fixed‑point  
  Allowed: float types.

- `%e` — scientific notation  
  Allowed: float types.

### 411.6.3 Text Verbs

- `%s` — text representation  
  Allowed:
  - `string`
  - `[]byte`
  - `[]rune`

- `%q` — quoted / escaped representation  
  Allowed:
  - `string`
  - `rune`
  - `[]byte`
  - `[]rune`

The precise escaping rules are defined in the formatting contract (410). At a high level, `%q` produces a representation suitable for use in Ori source (string or rune literal).

### 411.6.4 Bool Verb

- `%t` — textual boolean ("true" or "false")  
  Allowed: `bool`.

### 411.6.5 Type Verb

- `%T` — canonical static type name  
  Allowed: any value type.

`%T` uses compile‑time type information (from `TypeInfo`) to obtain a canonical name for the *static* type of the argument. It does not imply runtime reflection.

### 411.6.6 Debug Verb

- `%?` — debug representation  
  Allowed: any value type.

The static checker accepts `%?` for every type. The concrete debug formatting behaviour is defined by:

- The debug formatting contract (e.g. `DebugFormattable`), and
- Compile‑time reflection rules in 341 (e.g. field and variant inspection).

### 411.6.7 Literal Percent

- `%%` — literal `%`  
  Allowed in any format string. Does **not** consume an argument.

---

## 411.7 Static Checking Algorithm

For each format‑checked call (411.3), the compiler conceptually performs the following steps:

1. **Parse the format string** and extract all `Conversion` sequences:
   - Distinguish between `%%` and real verbs.
   - For each real verb, extract the verb character and (optionally) flags, width, and precision.

2. **Count arguments vs verbs**:
   - Let `N` be the number of real verbs (excluding `%%`).
   - Let `M` be the number of arguments following the format parameter.
   - If `N != M`, emit a **compile‑time error**:
     - Example: *"format string uses 2 verbs, but 3 arguments were provided"*.

3. **Check verb–argument compatibility**:
   - For each real verb, determine the type category of the corresponding argument (411.5).
   - If the verb is not allowed for that category (411.6), emit a **compile‑time error**:
     - Example: `%d` with `string`, `%f` with `int`, `%t` with `int`, `%s` with `bool`.

4. **Reject invalid syntax**:
   - If the format string contains a malformed conversion sequence (according to the grammar in 411.4), emit a **compile‑time error**.

The compiler may also use the static type of the format string expression (if constant) to attach errors precisely to that literal.

---

## 411.8 Examples

### 411.8.1 Arity Checking

```ori
fmt.Printf("x = %d, y = %d", x, y)      // OK

fmt.Printf("x = %d, y = %d", x)         // ERROR:
                                        // format string uses 2 verbs, but 1 argument was provided

fmt.Printf("x = %d", x, y)              // ERROR:
                                        // format string uses 1 verb, but 2 arguments were provided

fmt.Printf("percent = %%")              // OK: 0 verbs, 0 arguments
fmt.Printf("percent = %%", x)           // ERROR:
                                        // format string uses 0 verbs, but 1 argument was provided
```

### 411.8.2 Type Compatibility

```ori
var i int
var f float64
var s string
var b bool
var r rune
var bt []byte
var rn []rune

fmt.Printf("%d", i)     // OK
fmt.Printf("%d", s)     // ERROR: %d requires integer or enum type

fmt.Printf("%f", f)     // OK
fmt.Printf("%f", i)     // ERROR: %f requires float type

fmt.Printf("%s", s)     // OK
fmt.Printf("%s", bt)    // OK
fmt.Printf("%s", rn)    // OK
fmt.Printf("%s", b)     // ERROR: %s requires string, []byte, or []rune

fmt.Printf("%q", s)     // OK
fmt.Printf("%q", r)     // OK
fmt.Printf("%q", bt)    // OK
fmt.Printf("%q", rn)    // OK
fmt.Printf("%q", i)     // ERROR: %q requires string, rune, []byte, or []rune

fmt.Printf("%t", b)     // OK
fmt.Printf("%t", i)     // ERROR: %t requires bool

fmt.Printf("%T", i)     // OK: prints canonical name of type of i
fmt.Printf("%T", s)     // OK
```

### 411.8.3 Debug Verb

```ori
fmt.Printf("%?", i)         // OK: debug int
fmt.Printf("%?", f)         // OK: debug float
fmt.Printf("%?", s)         // OK: debug string
fmt.Printf("%?", someEnum)  // OK: debug enum
fmt.Printf("%?", user)      // OK: debug struct value
```

For `%?`, the static checker enforces only:

- The call is format‑checked (411.3),
- Arity is correct,
- Syntax of the conversion is valid.

The precise debug representation is defined by the formatting contract and compile‑time reflection (e.g. default struct/enum formatting, `DebugFormattable` interface).

---

## 411.9 Interaction with CTR and Formatting Contract

This section documents the hooks into other parts of the specification; details live in their respective documents.

- `%T` relies on compile‑time reflection (341) for type names:
  - The compiler uses `TypeInfo` for the static type of each argument.
  - No runtime reflection is introduced.

- `%?` is the primary **debug consumer** of:
  - The debug formatting contract (e.g. a `DebugFormattable` interface defined in 410), and
  - CTR Phase 3 metadata (fields, enum variants, etc.).

Implementations may provide default `%?` behaviour for structs, enums, and other composite types using only compile‑time reflection and the formatting interfaces defined in 410. This document only requires that `%?` be *accepted* by the static checker for any type; the exact printed form is specified elsewhere.
