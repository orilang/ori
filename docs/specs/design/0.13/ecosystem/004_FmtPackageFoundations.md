# 004 FmtPackageFoundations – Fmt Package Foundations (High‑Level Design Only)

This document defines the role, principles, and high‑level structure of the `fmt` package in Ori. It connects the `fmt` design to:
- The compile‑time reflection model (`semantics/340_CompiletimeReflection.md` and `semantics/341_CompiletimeReflection_Phase3.md`).
- The formatting and formatting‑related semantics (`semantics/410_FormattingAndFmtPrerequisites.md`).
- Existing ecosystem components such as OS, IO, logging, and the testing framework.

The goal is to make the **language and core semantics ready** for a future `fmt` package, not to ship a complete, frozen `fmt` API.

> Scope: high‑level design of the future `fmt` standard library package, **without** freezing the full API or implementing `fmt` it.

---

## 004.1 Overview and Goals

### 004.1.1 Role of the `fmt` Package

The `fmt` package is the standard facility for **text formatting and printing** in Ori. Its responsibilities include:
- Formatting values into textual representations using a small, explicit set of formatting rules.
- Writing formatted output to:
  - Standard output and error streams
  - In‑memory buffers (e.g. `StringBuilder`)
  - Arbitrary IO sinks that implement the appropriate writer interfaces
- Providing convenient helpers for:
  - Printing to the console (debugging, simple CLIs)
  - Building formatted strings
  - Building error messages from formatted text
- Integrating cleanly with:
  - The testing framework (for `t.Logf` and similar helpers)
  - The logging framework (for human‑oriented log messages, not for structured data fields)
  - The compile‑time reflection (CTR) model, for type‑aware and debug‑oriented formatting

The `fmt` package is **not** responsible for:
- Structured logging (key/value logging, log routing, log filtering). That is the domain of the logging framework.
- Localization or internationalization.
- HTML/JSON/XML templating or general templating engines.
- Runtime reflection.

### 004.1.2 Goals

The primary goals of the `fmt` design are:

1. **Type safety and predictability**

   - Format strings and arguments must be checked at compile time whenever possible.
   - The result of formatting a given type with a given verb must be well‑specified and stable, except for explicitly debug‑only verbs.

2. **No runtime reflection**

   - `fmt` does not rely on runtime reflection or dynamic type inspection.
   - All type‑sensitive behaviour must be expressible using:
     - The static type system.
     - Compile‑time reflection (CTR).
     - Explicit interfaces implemented by user types.

3. **Explicit extension points**

   - User types must opt in to custom formatting by implementing dedicated interfaces such as `Formattable` and `DebugFormattable`.
   - There is no "magic" catch‑all like "print any value however you can"; any such behaviour is restricted to debug‑only verbs and clearly documented as unstable.

4. **Integration with existing semantics**

   - `fmt` must be built on top of:
     - The writer and IO abstractions defined in `semantics/370_FileSystemAndIO.md` and the logging framework.
     - The formatting contracts defined in `semantics/410_FormattingAndFmtPrerequisites.md`.
     - The structured error model in `semantics/140_Errors.md`.

5. **Performance awareness**

   - `fmt` should avoid unnecessary allocations and copies.
   - Formatting operations must behave predictably in the presence of errors and cancellation.

### 004.1.3 Non‑Goals

The following are explicitly **out of scope** for the current version of fmt foundations:
- Finalizing the exact public API of `fmt`. Function names and signatures may still evolve.
- Defining complex formatting DSLs, localization, or template languages.
- Introducing any new runtime reflection or attribute systems (e.g. `@derive`, `@format`, etc.).
- Implementing advanced logging constructs; these are covered in the logging framework documents.

---

## 004.2 Design Principles

The design of `fmt` follows Ori’s global principles:

1. **Explicitness**

   - Callers must explicitly specify format strings and arguments.
   - Types must explicitly implement formatting interfaces to participate in non‑trivial formatting.

2. **Compile‑time validation**

   - Wherever the compiler can see a literal or compile‑time constant format string, it must validate that:
     - The number of verbs matches the number of arguments.
     - Each argument type is compatible with the corresponding verb.
   - Violations are **compile‑time errors**, not warnings.

3. **Minimal magic**

   - There is no general "format anything somehow" behaviour for regular verbs.
   - A dedicated debug verb (e.g. `%?`) may inspect values via CTR, but:
     - It is clearly documented as **debug‑only**.
     - Its exact output format is not stable for user‑visible text.

4. **Separation of concerns**

   - `fmt` is responsible for formatting logic.
   - IO sinks are responsible for actual writes, flushing, buffering, and error handling.
   - Logging and testing build on `fmt` rather than re‑implementing formatting themselves.

---

## 004.3 Core Concepts and Dependencies

The `fmt` package is built on the following concepts and existing interfaces.

### 004.3.1 Writer and Flusher

The logging framework defines minimal IO abstractions:
```ori
type Writer interface {
    Write(buf []byte) (int, Error)
}

type Flusher interface {
    Flush() Error
}
```

The `fmt` package must:
- Accept any `Writer` implementation as a target for formatted output (via `Fprint`‑style functions).
- Propagate `Write` errors to callers of writer‑based formatting functions.
- Not assume that flushing is required or handled by `fmt`; callers may choose to call `Flush` when appropriate.

Standard library components that implement `Writer` include, but are not limited to:
- File handles and OS streams (see `ecosystem/001_OS.md` and `semantics/370_FileSystemAndIO.md`).
- `StringBuilder` (see `semantics/360_StringBuilder.md`).
- Logging transports and adapters.

### 004.3.2 Formattable and DebugFormattable Interfaces

The formatting semantics document (`semantics/410_FormattingAndFmtPrerequisites.md`) defines the core formatting interfaces, roughly:
```ori
type Formattable interface {
    // Format writes a human‑oriented representation of the value
    // into the provided context. It must respect the format verb,
    // width, precision, and other options present in ctx.
    Format(ctx *FormatContext) Error
}

type DebugFormattable interface {
    // FormatDebug writes a debug‑oriented representation of the value.
    // This representation may include additional fields or internal state.
    // It is intended for debugging and logging, not for stable user‑facing text.
    FormatDebug(ctx *FormatContext) Error
}
```

Where `FormatContext` is defined in the semantics document and includes at least:
- A target sink (`Writer` or an internal sink abstraction).
- Parsed format verb, width, precision, and flags.
- Information about whether the call is for user‑oriented or debug‑oriented formatting.

The `fmt` package must:
- Prefer `Formattable` for regular, user‑oriented verbs.
- Use `DebugFormattable` only for debug verbs (such as `%?`), not for regular text.

### 004.3.3 CTR: Type Info and "Implements" Queries

The compile‑time reflection model provides:
- Type information structures such as `TypeInfo`, `StructInfo`, `EnumInfo`, etc.
- A way to ask at compile time whether a type implements a given interface:
  - The exact API is defined in `semantics/340_CompiletimeReflection.md` and `semantics/341_CompiletimeReflection_Phase3.md`.

`fmt` uses these capabilities for:
- Implementing type‑aware debug formatting (for `%?`) in terms of CTR.
- Producing type names in `%T`‑style contexts from the stable type identity defined by CTR.
- Possibly assisting compile‑time static checking for certain patterns of formatting calls.

All CTR usage in `fmt` must remain:
- **Compile‑time only** (no runtime reflection).
- Clearly limited to debug or diagnostic scenarios, unless otherwise specified.

### 004.3.4 Errors and Structured Error Model

The `Error` type and structured error model are specified in `semantics/140_Errors.md`. The `fmt` package treats `Error` as a **first‑class built‑in category** for formatting.

High‑level expectations:
- For regular text verbs, formatting an `Error` must yield its canonical user‑facing message, as defined by the error semantics (e.g. error kind, message, and possibly cause chain summary).
- For debug verbs, formatting an `Error` may include additional structured information (error code, context fields, underlying causes) if the semantics document permits it.

`fmt` **does not** require an `Error` interface with an `Error() string` method; it must rely on the semantics of the `Error` type itself.

---

## 004.4 API Families (High‑Level Shape)

This section defines the **families** of functions the `fmt` package will provide. Exact signatures and fine details are defined in later versions.

### 004.4.1 Console Printing: Print / Println / Printf

These functions write to the standard output stream (configured via the OS/IO layer):
- `Print(args...)`
- `Println(args...)`
- `Printf(format string, args...)`

Behaviour:
- `Print`:
  - Formats each argument using default text formatting rules.
  - Joins arguments with a separator (e.g. a single space) or no separator; the choice is defined in the detailed `fmt` specification.
- `Println`:
  - Same as `Print`, but appends a newline.
- `Printf`:
  - Interprets the first parameter as a format string.
  - Uses the format string semantics defined in `semantics/410_FormattingAndFmtPrerequisites.md`.
  - Applies static checking when the format string is compile‑time known.

All three variants write to a standard `Writer` associated with standard output and return:
- The number of bytes written.
- An `Error` if writing fails (callers may choose to ignore the error).

### 004.4.2 Writer‑Based Printing: Fprint / Fprintln / Fprintf

These functions generalize printing to any `Writer`:
- `Fprint(w Writer, args...)`
- `Fprintln(w Writer, args...)`
- `Fprintf(w Writer, format string, args...)`

Behaviour:
- Semantically identical to the `Print*` functions, except they target the given `Writer`.
- They must propagate any `Write` errors from the given `Writer`.

The exact behaviour of the `Writer` (e.g. buffering, flushing, non‑blocking IO) is defined by the writer implementation, not by `fmt`.

### 004.4.3 String‑Building: Sprint / Sprintln / Sprintf

These functions build and return a `string`:
- `Sprint(args...) string`
- `Sprintln(args...) string`
- `Sprintf(format string, args...) string`

Implementation guidelines:
- `fmt` should use `StringBuilder` internally to minimize allocations and copies.
- `Sprint` and `Sprintln` follow the same argument formatting and joining rules as `Print` and `Println`.
- `Sprintf` follows the same format string semantics as `Printf`.

These functions do not expose IO errors; any failure to allocate memory results in standard runtime behaviour for allocation failure (as defined elsewhere in the runtime semantics).

### 004.4.4 Error Construction: Errorf

The `Errorf` family bridges formatting with the structured error system:
- `Errorf(format string, args...) Error`

High‑level semantics:
- `Errorf` constructs a new `Error` whose user‑visible message is the result of `Sprintf(format, args...)`.
- Additional error fields (kind, code, metadata) follow the structured error design and may be extended in the future.
- The returned `Error` must integrate cleanly with the structured error propagation mechanisms defined in `semantics/140_Errors.md`.

---

## 004.5 Value Formatting Model

This section describes how `fmt` decides how to format a value for a particular verb.

### 004.5.1 Priority Order

For a given argument `x` and a parsed format description (verb, width, precision, flags), `fmt` must follow this decision order:

1. **Formattable**

   - If the static type of `x` implements `Formattable`, call:
     ```ori
     var err = x.Format(ctx)
     ```

   - `ctx` contains the verb and options provided by the caller.

2. **DebugFormattable**

   - If the verb is a debug‑only verb (e.g. `%?`), and the static type of `x` implements `DebugFormattable`, call:
     ```ori
     var err = x.FormatDebug(ctx)
     ```

3. **Built‑in category**

   - If the static type of `x` belongs to a built‑in category (integer, float, string, `[]byte`, rune, boolean, pointer types, `Error`, time types, etc.), use the built‑in formatting rules for that category and verb.

4. **Debug fallback (CTR‑based, debug‑only)**

   - If the verb is a debug‑only verb (e.g. `%?`) and no `DebugFormattable` or built‑in behaviour applies, `fmt` may use compile‑time reflection to produce a diagnostic representation of `x`:
     - Accessing `TypeInfo` and its substructures to retrieve field names, variant names, etc.
     - Generating an implementation‑defined representation such as:
       ```text
       TypeName{field1=value1, field2=value2, ...}
       ```

   - The exact format and fields included are **not stable**. This behaviour is only appropriate for debugging and logging.

5. **Unsupported**

   - For regular verbs, if none of the above applies, formatting is a static error whenever the compiler can detect it:
     - The compiler may reject calls where it knows that the verb and argument type are incompatible.
   - For cases that cannot be statically detected (e.g. dynamic format strings), the `fmt` package must specify well‑defined runtime failure behaviour (typically a panic).

This priority order enforces Ori’s explicitness and avoids “best‑effort” formatting for unprepared types, except for the explicitly debug‑only path.

### 004.5.2 Built‑in Categories (Overview)

The following categories are expected to have built‑in formatting behaviour:

- **Integers**

  - Decimal formatting.
  - Optional radix formats (hexadecimal, possibly octal or binary).
  - Width, alignment, and zero‑padding options.

- **Floating‑point numbers**

  - Fixed‑point and exponential formats.
  - Precision and width options.

- **Strings and `[]byte`**

  - Plain printing.
  - Quoted / escaped form (e.g. `%q`).

- **Booleans**

  - Printed as `true` or `false` (lowercase).

- **Runes (Unicode scalar values)**

  - Character representation (if printable).
  - Numeric (code‑point) representations for debug or explicit numeric verbs.

- **Pointers**

  - Optional low‑level representation (e.g. `%p`), unspecified but stable within a single execution.
  - Primarily for diagnostics, not user‑facing text.

- **Errors**

  - For regular verbs: user‑facing message derived from the structured error semantics.
  - For debug verbs: may include additional structure (codes, causes, metadata).

- **Time types**

  - If the standard library defines time types (e.g. `time.Duration`, `time.Instant`), `fmt` must define default textual representations for them, consistent with the `time` package design.

The detailed behaviour of each category and verb is specified in the formatting semantics document (`semantics/410_FormattingAndFmtPrerequisites.md`) and the future full `fmt` specification.

### 004.5.3 Debug‑Only Formatting

Debug‑only formatting (e.g. `%?`):
- May produce representations that:
  - Include internal fields.
  - Change between compiler versions.
  - Are not suitable as stable user‑facing formats.
- Is allowed to use CTR extensively.
- Must be clearly documented as such and should be visually distinct (e.g. using explicit delimiters, type names).

Callers must not rely on debug‑only formatting for any external protocols, persisted logs, or user‑visible output that must remain stable.

---

## 004.6 Format String Semantics and Static Checking

The detailed syntax of format strings and static checking rules live in:
- `syntax/015_Literals.md`
- `syntax/070_Expressions.md`
- `semantics/410_FormattingAndFmtPrerequisites.md`

This section defines how `fmt` interacts with those rules.

### 004.6.1 Format Strings

A **format string** is a `string` value that is interpreted by certain `fmt` functions (e.g. `Printf`, `Fprintf`, `Sprintf`, `Errorf`) as a sequence of:
- Literal characters, copied unchanged to the output.
- Format verbs, each describing:
  - A specific verb character (e.g. `d`, `s`, `x`, `?`).
  - Optional flags (alignment, sign, zero‑padding, etc.).
  - Optional width and precision.

The exact grammar of verbs is specified in the semantics document and must be sufficiently constrained to enable static checking.

### 004.6.2 Static Checking Rules

For any call of the form:
```ori
fmt.Printf("literal format string", arg1, arg2, ...)
```

where the compiler can determine that the first argument is a compile‑time constant format string, the compiler must:

- Parse the format string.
- Count the number of verbs that expect arguments.
- Determine the expected categories or interfaces for each argument.
- Validate that:
  - The number of verbs matches the number of arguments.
  - Each argument’s static type is compatible with the corresponding verb.

On violation, the compiler must emit a **compile‑time error**.

These rules apply to all functions explicitly designated as **format functions**, including but not limited to:
- `Printf`, `Fprintf`, `Sprintf`, `Errorf`.
- Testing helpers such as `t.Logf`.
- Future logging helpers such as `Logger.Infof`, if they adopt fmt semantics.

### 004.6.3 Dynamic Format Strings

When the format string is not a compile‑time constant (for example, it is read from configuration or constructed at runtime):
- The compiler does not provide static guarantees.
- `fmt` must specify its runtime behaviour for:
  - Verb and argument mismatches.
  - Invalid or malformed format strings.
- In general, runtime violations should result in deterministic panics or errors, not silent truncation or undefined behaviour.

---

## 004.7 Integration with Testing and Logging

### 004.7.1 Testing Framework

The testing framework (`semantics/300_TestingFramework_Phase1.md` and `Phase 2`) provides functions such as:
- `t.Log(msg string)`
- `t.Logf(format string, args...)`

The `fmt` foundations define:
- `t.Logf` must use the same format string semantics and static checking rules as `fmt.Sprintf`.
- Static checking applies when the `format` argument is a compile‑time constant.
- `t.Logf` may ignore write errors (test logs are best effort and should not fail tests), but must still follow the same formatting rules.

This ensures that formatting in tests is consistent with formatting in production code.

### 004.7.2 Logging Framework

The logging framework (see `semantics/380_LoggingFramework_Phase1.md` and `Phase 2`) focuses on structured logging: a log record consists of a message plus key/value fields. The `fmt` package is primarily used for the **message** string.

Expected usage patterns:
- Logging functions may accept pre‑formatted messages:
  ```ori
  logger.Info("user logged in", "user_id", userID)
  ```

- Callers may use `fmt` to build the message:
  ```ori
  var msg = fmt.Sprintf("user %s logged in", userID)
  logger.Info(msg, "user_id", userID)
  ```

- Phase 2 of the logging framework may provide `Xxxf` helpers:
  ```ori
  func (logger shared Logger) Infof(format string, args...) {
      if !logger.isLevelEnabled(LogLevel.Info) {
          return
      }
      var msg = fmt.Sprintf(format, args...)
      logger.Info(msg)
  }
  ```

In all cases:
- Format string semantics and static checking must be identical to `fmt`.
- Structured fields remain explicit key/value pairs and are **not** derived from format strings.

---

## 004.8 Error Handling and Guarantees

### 004.8.1 IO Errors

Writer‑based functions (`Fprint`, `Fprintln`, `Fprintf`) must:
- Propagate any `Write` errors from the target `Writer`.
- Return `(int, Error)` representing:
  - Number of bytes successfully written.
  - The first error encountered, if any.

Console‑based functions (`Print`, `Println`, `Printf`) behave identically but target the standard output `Writer`. Callers may choose to ignore the returned error.

The `fmt` package itself must not attempt to recover from IO errors; such recovery, if any, is the responsibility of higher‑level code.

### 004.8.2 Formatting Errors

Formatting errors include:
- Invalid or unsupported format verbs.
- Mismatch between argument types and verbs that the compiler could not detect (for example, dynamic format strings).
- Errors returned by `Formattable` / `DebugFormattable` implementations.

The high‑level rules are:
- When invalid format strings or incompatible argument types are detectable at compile time, they must be rejected at compile time.
- When such errors occur at runtime (e.g. dynamic format strings), `fmt` must follow a deterministic failure mode:
  - Typically a panic that clearly reports the offending verb and argument.
- Errors returned from `Formattable` / `DebugFormattable` implementations:
  - Are treated as formatting errors.
  - May be surfaced as panics or propagated as part of the function’s error result, depending on the function family.
  - The detailed policy is specified in the full `fmt` spec and may differ between writer‑based and string‑based functions.

### 004.8.3 Performance Considerations

Implementations of `fmt` must:
- Avoid unnecessary allocations by:
  - Using `StringBuilder` for string‑building functions.
  - Writing directly into the target `Writer` for writer‑based functions.
- Avoid formatting work when the result will be discarded:
  - For example, logging helpers must check log levels before performing any formatting.
- Be careful with recursive debug formatting to avoid unbounded recursion in cyclical structures.

---

## 004.9 Future Extensions (Non‑Normative)

The following possible future extensions are explicitly **non‑normative**, but should be kept in mind while designing `fmt`:

- **Custom formatters per verb**
  - Allowing a type to offer different formatting behaviours for different verbs, beyond what `Formattable` and `DebugFormattable` provide by default.

- **Domain‑specific formatting**
  - Helpers for formatting JSON, URLs, SQL, or other domain‑specific texts.
  - These are likely separate packages that re‑use `fmt` semantics rather than extensions of `fmt` itself.

- **Localization and internationalization**
  - Using locale‑aware formats for dates, times, numbers, and messages.
  - Such features would likely be built in higher‑level packages that use `fmt` as a low‑level building block.

- **Structured formatting APIs**
  - APIs that combine structured logging with formatting in a way that avoids double work (e.g. generating both a human‑oriented message and machine‑readable fields).

These extensions must not violate the core principles laid out in this document: no runtime reflection, explicit extension points, and strong compile‑time guarantees where possible.

---

## 004.10 Summary

The `fmt` package foundations:
- Define the **role** of `fmt` in the Ori ecosystem.
- Specify the **principles** that guide its design: type safety, no runtime reflection, explicit extension points.
- Establish the **core concepts and dependencies**:
  - Writer/Flusher interfaces.
  - Formattable/DebugFormattable interfaces.
  - CTR‑based type information and implements checks.
  - Integration with the structured error model.
- Describe the **API families** (`Print*`, `Fprint*`, `Sprint*`, `Errorf`) at a high level.
- Define the **value formatting model**, format string semantics, and static checking requirements.
- Clarify integration with the **testing** and **logging** frameworks.
- Specify high‑level **error handling** and performance considerations.

This document does **not** freeze the exact function signatures or the full verb set; those details will be specified in later versions once the underlying semantics (formatting contracts and CTR Phase 3) have been finalized.
