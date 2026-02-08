# 381. Logging Framework – Phase 2 (Formatting Integration)

This document extends the logging framework specified in `380_LoggingFramework_Phase1.md` with a precise, type-safe *formatting integration*.

Phase 2 keeps **structured logging** as the primary model (message + key/value fields) and integrates it with:
- The compile-time reflection (CTR) extensions in `341_CompiletimeReflection_Phase3.md`.
- The language-level formatting contracts in `410_FormattingAndFmtPrerequisites.md`.
- The testing framework logging facilities defined in `300_TestingFramework_Phase2.md`.

The primary goals are:
- Make log **value formatting** consistent with the formatting semantics used by the future `fmt` package.
- Preserve the **performance guarantees** and **predictability** of `Phase 1` (no work when logs are filtered out, no hidden reflection).
- Align `Logger` behaviour with `TestContext` logging (`t.Log`, `t.Logf`) without coupling either system to a specific `fmt` API.

> **Depends on:**  
> - 380_LoggingFramework_Phase1.md
> - 341_CompiletimeReflection_Phase3.md
> - 410_FormattingAndFmtPrerequisites.md
> - 300_TestingFramework_Phase1.md
> - 300_TestingFramework_Phase2.md

---

## 381.1 Overview and Scope

`Phase 2` focuses on **how values become text** inside log records.

It does **not**:
- Introduce a new printf-style language owned by the logging framework.
- Replace the structured logging API with printf-based logging.
- Add runtime reflection or attributes.

Instead, Phase 2 defines:
1. A **value formatting pipeline** for log fields, based on the formatting interfaces and CTR capabilities.
2. How this pipeline behaves for different output modes (human-readable vs JSON).
3. How logging *interacts* with format-string-based APIs such as `t.Logf` and a future `fmt` package, without depending on their final shape.
4. How formatting errors and failures are handled, especially in `Fatal` logs.

All semantics defined here are additive to `Phase 1`. When this document conflicts with `380_LoggingFramework_Phase1.md` on a point related to formatting, this `Phase 2` specification prevails.

---

## 381.2 Terminology and Dependencies

The following terminology is used in this document:
- **Logger:** The logging object defined in `Phase 1`, responsible for emitting log records at various levels (`Debug`, `Info`, `Warn`, `Error`, `Fatal`).
- **Log record:** A single log event, consisting of:
  - Timestamp
  - Level
  - Message string
  - Key/value fields (structured data)
  - Optional context metadata (module name, file/line, etc.)
- **Output mode:** The serialization format used for log records:
  - *Human-readable text* (line-oriented, optimized for humans)
  - *JSON* (structured, optimized for machines)
- **Format contracts:** The formatting interfaces and semantics defined in `410_FormattingAndFmtPrerequisites.md`.
  - This document refers to them abstractly as:
    - `Formattable` – for user-facing textual representation.
    - `DebugFormattable` – for debug/structural representation.
  - Their exact signatures are defined in `410_FormattingAndFmtPrerequisites.md`.
- **CTR:** Compile-time reflection capabilities defined in `341_CompiletimeReflection_Phase3.md`, including:
  - `typeinfo(T)` returning `TypeInfo`.
  - The ability to ask whether a type implements a given interface at compile time.

`Phase 2` assumes these facilities exist, but it does not define their exact APIs beyond what is needed to describe logging behaviour.

---

## 381.3 Value Formatting Model

### 381.3.1 General rule

Whenever the logging framework needs to convert a **field value** to a textual or serialized form, it MUST follow the **same semantics** as the language-level formatting model specified in `410_FormattingAndFmtPrerequisites.md`, subject to the restrictions in this section.

Logging never uses hidden runtime reflection and never bypasses compile-time type information.

### 381.3.2 Formatting pipeline for fields

For each field `(key string, value V)` attached to a log record, the logger conceptually applies the following pipeline:

1. **Built-in types**

   If `V` is one of the built-in types with defined formatting semantics (e.g. integers, floats, booleans, strings, byte slices, errors, enums, time-related types), the logger MUST use the canonical formatting defined in `410_FormattingAndFmtPrerequisites.md` for that type.

2. **Types implementing formatting interfaces**

   If `V` is a type for which CTR can determine at compile time that it implements one or more of the formatting interfaces defined in `410_FormattingAndFmtPrerequisites.md`, then:

   - For **human-readable text output**:
     - The logger MUST prefer the "user-facing" formatting interface (e.g. `Formattable`).
   - For **debug-oriented output modes** (including JSON if configured to use debug-style representations):
     - The logger SHOULD prefer the "debug" formatting interface (e.g. `DebugFormattable`) when available.
     - If a debug interface is not implemented, it MUST fall back to the user-facing interface.

   The decision to use a particular interface MUST be made based on compile-time `implements(T, I)`-style checks, as described in `341_CompiletimeReflection_Phase3.md`.

3. **CTR-based structural fallback**

   If `V` is neither a built-in with defined formatting semantics nor a type that implements any of the recognized formatting interfaces, the logger MUST construct a **structural debug representation** using CTR:

   - For named structs:
     ```text
     TypeName{field1=value1, field2=value2, ...}
     ```
   - For enums (without payloads):
     ```text
     EnumType.VARIANT_NAME
     ```
   - For sum types:
     ```text
     SumType.VariantName(value=...)
     ```

   The exact shape of this debug representation MUST be consistent with the debug-style formatting defined in `410_FormattingAndFmtPrerequisites.md` (e.g. a possible `%?` verb or equivalent).

Logging MUST NOT attempt to use any hidden dynamic reflection system to obtain type information; it can only use CTR and the language semantics already defined.

### 381.3.3 Determinism and stability

The textual representation produced by the pipeline for a given type and value MUST be:
- **Deterministic**: the same program, with the same input and configuration, produces the same representations.
- **Stable within a major version**: minor changes in the logging implementation must not arbitrarily change the default formatting of built-in types, enums, and simple structs.

The specification does not require that complex structural representations be fully stable across major versions, but implementers should avoid unnecessary churn.

---

## 381.4 Interaction with Log Levels and Performance

`Phase 1` specifies that logs **below** the configured level MUST be ignored with minimal overhead.

`Phase 2` reaffirms and extends this guarantee:
- A `Logger` MUST perform **level filtering** before:
  - Evaluating fields.
  - Formatting values.
  - Allocating buffers for textual representation.
  - Performing any I/O.

Formally, for a log method such as:
```ori
func (l *Logger) Info(msg string, fields ...any)
```

the implementation MUST be equivalent to:
```ori
func (l *Logger) Info(msg string, fields ...any) {
    if LogLevel.Info < l.level {
        return
    }

    // Only here is it permitted to:
    // - Normalize and validate fields
    // - Format values according to 381.3
    // - Serialize, buffer, and write to outputs
}
```

This rule applies to all log levels (`Debug`, `Info`, `Warn`, `Error`, `Fatal`) except that `Fatal` may perform some additional work before process termination (see 381.7).

Any helper methods or wrappers around the `Logger` MUST preserve this property.

---

## 381.5 Message String Semantics

### 381.5.1 Plain message strings

The **message** part of a log record is a plain `string`. The logging framework:

- MUST NOT parse the message as a format string.
- MUST NOT interpret `%`-style sequences or other markup in the message.
- Treats the message as opaque text for the purpose of serialization and output.

### 381.5.2 Interaction with formatting libraries

Callers MAY construct the message string using `fmt` or other formatting helpers before passing it to the logger, for example:

```ori
var msg = fmt.Sprintf("user %s logged in", userID)
logger.Info(msg,
    "user", userID,
    "ip", ip,
)
```

From the perspective of the logging framework:
- This is indistinguishable from any other message string.
- Any format-string checking and formatting performed by `fmt` occurs **outside** the logging framework.

`Phase 2` does **not** introduce `Infof`, `Debugf`, or similar methods on `Logger`. Such APIs, if provided in the future, are considered thin wrappers around the core logging semantics and would be specified separately at the ecosystem level.

---

## 381.6 Output Modes and Formatting

`Phase 1` defines multiple output modes (e.g. human-readable text and JSON). `Phase 2` specifies how the value formatting pipeline applies in each mode.

### 381.6.1 Human-readable text output

In human-readable text mode, the logger typically produces lines of the form:

```text
TIMESTAMP LEVEL MESSAGE key1=value1 key2=value2 ...
```

`Phase 2` adds the following rules:
- The representation of each `valueN` MUST be the result of the pipeline described in `381.3`.
- For complex types, the representation SHOULD be concise and human-friendly:
  - Long nested structures may be truncated in a controlled way.
  - Implementations SHOULD avoid dumping entire graphs or recursively following shared references indefinitely.

The exact layout (spacing, ordering of fields, timestamp placement) is implementation-defined but MUST remain deterministic for a given configuration.

### 381.6.2 JSON output

In JSON mode, log records are serialized as JSON objects with fields including at least:
- `timestamp`
- `level`
- `message`
- `fields` (a JSON object mapping keys to values)

For each field value:
- If the value is a built-in type with a natural JSON representation (integer, float, bool, string), implementations SHOULD encode it as the corresponding JSON primitive.
- For enums, implementations SHOULD encode the variant name as a JSON string.
- For time-related types, implementations SHOULD use the canonical string representation defined by the `time` package (e.g. RFC 3339).
- For complex types without a direct JSON mapping, implementations MUST:
  - Produce a string representation using the structural debug fallback (`381.3.2` point 3), and
  - Encode that representation as a JSON string.

Implementations MAY provide configuration hooks to customize how particular types are encoded in JSON (for example, to allow richer structured representations), but such hooks are outside the scope of this core semantics document.

---

## 381.7 Fatal Logs, Flushing, and Formatting Errors

`Phase 1` specifies that `Fatal` logs:
- Emit a log record at `Fatal` level.
- Flush underlying sinks where possible.
- Terminate the process via a configurable `exitFn`.

`Phase 2` clarifies how formatting interacts with `Fatal`.

### 381.7.1 Guaranteed formatting behaviour

For a `Fatal` log call:
1. The logger MUST apply the same field value formatting pipeline as for other levels.
2. If formatting for a particular field or message fails due to an internal error (e.g. a bug in a user-provided `Formattable` implementation), the logger MUST:
   - Substitute a conservative fallback representation (e.g. `"<logging-format-error>"`), and
   - Continue with emitting the `Fatal` record.

The logger MUST NOT panic user code as a result of a formatting failure inside a `Fatal` call.

### 381.7.2 Flushing and process termination

After constructing the `Fatal` log record:
1. The logger MUST attempt to write the record to all configured sinks.
2. For sinks that provide an explicit flushing interface (as defined in Phase 1), the logger MUST call `Flush()` once per sink.
3. Once all writes and flushes have been attempted, the logger MUST call `exitFn(1)`.

No additional user-level destructors or defers are guaranteed to run after `exitFn(1)`.

---

## 381.8 Testing Integration

The testing framework (`300_TestingFramework_Phase1/Phase2.md`) defines logging methods such as:
```ori
func (t *TestContext) Log(msg string)
func (t *TestContext) Logf(format string, args ...any)
```

`Phase 2` of the logging framework aligns these methods with the logging semantics as follows.

### 381.8.1 t.Log

`t.Log` behaves like a logger configured to write to the test’s output buffer:
- It accepts a plain message string; `t.Log` does not parse or interpret the message as a format string.
- It MAY internally attach additional structured data (e.g. when printing diffs) but MUST use the same value formatting pipeline as in `381.3` for any values it formats.

### 381.8.2 t.Logf

`t.Logf` is a formatted logging helper specified in `300_TestingFramework_Phase2.md`. Its behaviour is:
1. At **compile time**, calls to `t.Logf(format, args...)` are subject to the same format-string checking rules as the future `fmt` formatting functions, as specified in `Format String Semantics and Static Checking` in v0.12.
2. At **runtime**, `t.Logf`:
   - Formats the message using the same formatting semantics as the language-level formatting model in `410_FormattingAndFmtPrerequisites.md`.
   - Calls `t.Log(formattedMessage)`.

From the perspective of the logging framework:
- `t.Logf` is equivalent to constructing a formatted string with a future `fmt.Sprintf` and then passing it to `t.Log`.
- There is no additional structured data produced by `t.Logf` itself.

### 381.8.3 Consistency requirement

Implementations MUST ensure that:
- `t.Logf` and any future `fmt` functions that are declared to use the same format-string semantics produce **identical results** for the same format string, types, and arguments.
- The value formatting rules used by the logging framework for fields are compatible with the rules used by `t.Logf` for building messages.

---

## 381.9 Diagnostics and Invariants

### 381.9.1 Misuse of field arguments

If the logging framework detects clear misuse of field arguments (e.g. odd number of arguments for key/value pairs, non-string keys when string keys are required), implementations SHOULD:
- Either reject the call at compile time (if the misuse is detectable via static analysis), or
- Emit a log record with a reserved diagnostic key (e.g. `"logging_error"`) describing the misuse, and
- Still include as much of the user-provided data as is safely representable.

These diagnostics MUST never cause a panic in user code.

### 381.9.2 Formatting panics in user code

If a user-provided `Formattable` or `DebugFormattable` implementation panics during formatting:
- The logger MUST treat this as equivalent to a formatting failure.
- It MUST:
  - Recover from the panic at the logging boundary, and
  - Replace the value with a safe fallback representation (e.g. `"<logging-format-panic>"`), and
  - Continue emitting the log record.

The logger MUST NOT propagate the panic beyond the logging system.

---

## 381.10 Examples

> These examples are illustrative only. They are not part of the normative specification.

### 381.10.1 Basic structured Info log

```ori
logger.Info("server started",
    "port", port,
    "secure", isTLS,
    "clients", clientCount,
)
```

Assuming:
- `port` is an `int`,
- `isTLS` is a `bool`,
- `clientCount` is an `int64`,

in a human-readable output mode, one possible line is:
```text
2025-12-07T10:15:00Z INFO server started port=8080 secure=true clients=5
```

### 381.10.2 Logging a struct with no custom formatter

```ori
type Config struct {
    host string
    port int
}

var cfg Config = loadConfig()

logger.Debug("config loaded",
    "config", cfg,
)
```

If `Config` does not implement any formatting interface, the logger uses the structural fallback, e.g.:

```text
2025-12-07T10:15:05Z DEBUG config loaded config=Config{host="localhost", port=8080}
```

### 381.10.3 Using a custom Formattable implementation

```ori
type User structID {
    value string
}

func (id UserID) Format(ctx *FormatContext) Error {
    // Only show a short prefix for human readability.
    return ctx.WriteString("user:" + id.value[0:8])
}

// Later:
var id UserID = getUserID()

logger.Info("login",
    "user", id,
    "ip", ip,
)
```

In a human-readable mode, the logger will use `UserID.Format` for the `user` field:

```text
2025-12-07T10:15:10Z INFO login user=user:1a2b3c4d ip=192.0.2.1
```

### 381.10.4 Testing with t.Logf

```ori
func TestLogin(t *TestContext) {
    var userID = "alice"
    var ip = "192.0.2.1"

    t.Logf("user %s logged in from %s", userID, ip)
}
```

Assuming the format-string semantics are the same as a future `fmt.Sprintf`, the output recorded for the test is equivalent to:

```ori
t.Log("user alice logged in from 192.0.2.1")
```

The logging framework treats this as a plain message string.

---

## 381.11 Future Work

Potential future extensions, outside the scope of Phase 2, include:

- Structured logging helpers that integrate more deeply with the formatting interfaces (e.g. typed field builders).
- Pluggable encoders for specific types in JSON mode (e.g. custom JSON representation for IDs).
- Additional output modes (e.g. binary logs, journald integration), reusing the same value formatting semantics.

These extensions must not introduce runtime reflection and must respect the guarantees and invariants defined in this document.
