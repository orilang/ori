# 380 Logging Framework - Phase 1

This document specifies the semantics and core APIs of the Ori logging framework.  
It defines log levels, log record structure, concurrency guarantees, interaction with deterministic destruction, and fatal error handling.

Logging is a **library-level facility**, not a language feature. It must obey the general principles defined in:
- `001_LanguagePhilosophy.md`
- `002_TypeSafetyAndExplicitness.md`
- `005_ConcurrencyAndPredictability.md`
- `150_TypesAndMemory.md`
- `190_Concurrency.md`
- `220_DeterministicDestruction.md`
- `330_BuildSystemAndCompilationPipeline_Phase1/2.md`

This file focuses on **semantics** and **expected behavior**, not on a particular implementation or performance tuning.

---

## 380.1 Goals and Non‑Goals

### 380.1.1 Goals

The Ori logging framework MUST:

1. Provide a small, explicit, and predictable API for application and library logging.
2. Support **structured logging** (key/value pairs), not printf-style formatting.
3. Be **safe to use concurrently** from multiple tasks by default.
4. Integrate correctly with deterministic destruction (`220_DeterministicDestruction.md`),
   without relying on it for fatal shutdown paths.
5. Provide a well‑defined **Fatal** behavior: log the entry, flush if applicable, then terminate the process with exit code `1`.
6. Require **no global mutable state**; multiple loggers can coexist independently.
7. Be usable consistently by:
   - application code
   - libraries
   - the testing framework (`300_TestingFramework_Phase1/2.md`)
   - the build system and tooling (`330_BuildSystemAndCompilationPipeline_Phase1/2.md`).

### 380.1.2 Non‑Goals

The logging framework does **not** attempt to:
1. Provide a printf-style formatting language (no `%d`, `%s`, `%v`, etc.).
2. Perform runtime reflection for automatic struct or object serialization.
3. Implement asynchronous logging (log queues, background tasks). This may be added
   later as a separate `AsyncLogger` type in a future version.
4. Provide transport-specific features (e.g. log shipping, remote ingestion).
5. Guarantee persistence to disk or durable storage; logging is best effort.

---

## 380.2 Terminology

- **Log level**: a severity classification for a log record (`Debug`, `Info`, `Warn`, `Error`, `Fatal`).
- **Log record**: a single log event with a level, message, timestamp, and fields.
- **Field**: a key/value pair attached to a log record.
- **Writer**: an abstraction that receives the serialized log record bytes.
- **Flush**: operation that pushes any buffered log data to the underlying sink.
  Flush **does not** guarantee persistence to disk.

Unless otherwise stated, “task” refers to Ori’s concurrency unit as described in `190_Concurrency.md`.

---

## 380.3 Log Levels

### 380.3.1 Enumeration

Log levels are represented as a simple enumeration:

```ori
type enum LogLevel {
    Debug
    Info
    Warn
    Error
    Fatal
}
```

The ordering is, from least to most severe:
```text
Debug < Info < Warn < Error < Fatal
```

### 380.3.2 Meaning

- `Debug`: Diagnostic information, typically disabled in production.
- `Info`: Important high-level events in normal operation.
- `Warn`: Suspicious or unexpected events that do not prevent progress.
- `Error`: Failures that affect behavior or requests but allow the process to continue.
- `Fatal`: An unrecoverable condition after which the process **must exit**.

### 380.3.3 Level Filtering

Each logger instance has a minimum level:
- Records with `record.level < logger.level` MUST be skipped.
- Skipped records MUST NOT perform any formatting, allocation, or I/O.

The goal is to make disabled logging as close to zero‑cost as possible.

---

## 380.4 Log Record Model

### 380.4.1 Log Record Fields

A log record conceptually contains at least:
- `level: LogLevel`
- `time: Time` (seminantics defined in ecosystem/003_Time.md)
- `message: string`
- `fields: list of (key string, value any)`
- optional logger metadata (e.g. fixed prefix, logger name)

This specification does not mandate a concrete in‑memory representation. Implementations are free to use stack allocations, pre‑allocated buffers, or other techniques, as long as they preserve observable behavior.

### 380.4.2 Structured Logging (Key/Value Pairs)

Structured logging uses key/value pairs:
```ori
logger.Info("server started",
    "port", port,
    "secure", isTLS,
    "clients", clientCount,
)
```

Rules:
1. Keys MUST be strings. Implementations may enforce this at compile time or runtime.
2. Values MAY be any type (`any`), but must be serializable into some textual representation.
3. The order of fields MUST be preserved as provided by the caller.
4. Keys need not be unique, but callers SHOULD avoid duplicates.

Implementations are free to choose the underlying serialization format, as long as
the observable behavior matches the configured output mode.

### 380.4.3 Output Formats

At minimum, two output formats SHOULD be supported by the standard logging library:

1. **Human-readable**:
   - ISO8601 timestamp
   - level name
   - message
   - key/value pairs

   Example (illustrative only):
   ```text
   2025-12-03T10:04:11Z INFO server started port=8080 clients=4
   ```

2. **JSON**:
   - Single line per record
   - Deterministic key order
   - No reflection-based magic

   Example (illustrative only):
   ```json
   {"time":"2025-12-03T10:04:11Z","level":"INFO","msg":"server started","port":8080,"clients":4}
   ```

The choice of format is a construction‑time decision (e.g. `NewLogger` vs `NewJSONLogger`).
This semantic file does not fix API names, only required behavior.

---

## 380.5 Writer Abstractions

### 380.5.1 Writer Interface

Loggers send serialized log records to a `Writer`:
```ori
type interface Writer {
    Write(buf []byte) (int, error)
}
```

Rules:
1. `Write` MUST attempt to write all bytes in `buf`.
2. On success, it returns `(len(buf), nil)`.
3. On partial write, it returns `(n, error)` with `0 <= n < len(buf)`.
4. On failure without any bytes written, it returns `(0, error)`.

Loggers MUST treat partial writes and non‑nil errors as write failures.
How failures are handled is defined in `380.10`.

### 380.5.2 Flusher Interface

Some writers buffer data internally and support explicit flushing.

Ori defines a **public**, but minimal, interface for this capability:
```ori
type interface Flusher {
    Flush() error
}
```

Rules:
1. `Flush` MAY be a no‑op for unbuffered writers.
2. `Flush` MUST NOT guarantee durable persistence to disk. It only guarantees that
   buffered data is pushed to the underlying sink.
3. The logging framework **does not** require callers to invoke `Flush` directly.
   Instead, loggers call `Flush` internally when appropriate (e.g. on `Fatal`).

Custom writers MAY implement `Flusher` to participate in flush semantics.

---

## 380.6 Logger Type and Concurrency Semantics

### 380.6.1 Conceptual Logger Type

A canonical logger has at least the following conceptual shape:
```ori
type struct Logger {
    mu          Mutex        // protects all internal state
    writer      Writer
    level       LogLevel
    timeFn      func() Time  // injected clock function
    prefix      string       // optional static prefix
    ownsWriter  bool         // participates in deterministic destruction
    exitFn      func(int)    // injected exit function for Fatal
    // optional: error tracking, output mode, etc.
}
```

This structure is illustrative. Implementations MAY use different internal layouts as long as the observable semantics described in this file are preserved.

### 380.6.2 Thread Safety (Tasks)

A `Logger` MUST be safe to use concurrently from multiple tasks by default:
- Calls to logging methods (Debug, Info, Warn, Error, Fatal) MUST NOT race internally.
- Log lines MUST NOT interleave or corrupt each other at the byte level.
- Each call to a logging method MUST produce an indivisible log record in the output.

The usual way to achieve this is to guard logging operations with an internal `Mutex` (see `190_Concurrency.md`). Alternatives (per‑record allocation, lock-free queues, etc.)
are allowed as long as they preserve the same observable behavior.

> **Note:** Writers themselves are **not** required to be thread-safe. The logger’s
> internal synchronization is responsible for serializing access to the `Writer`.

---

## 380.7 Logger Construction

### 380.7.1 Construction Parameters

The canonical construction function has the following conceptual signature:

```ori
func NewLogger(
    writer Writer,
    level LogLevel,
    timeFn func() Time,
    exitFn func(int),
) Logger
```

Rules:
1. `writer` MUST NOT be nil.
2. `level` controls the minimum level that will be emitted (see 380.3.3).
3. `timeFn` is a clock function returning a `Time` value (see `ecosystem/003_Time.md`).
   - In typical code this will be `time.Now`.
   - Tests may inject a deterministic or fake clock.
4. `exitFn` is a function used by `Fatal` to terminate the process.
   - In typical code this will be `os.Exit` (from the `os` package).
   - Tests may inject a function that panics or records the exit code instead of
     actually terminating the process.

### 380.7.2 Ownership Flag

Construction may also define whether the `Logger` **owns** its writer:

- If `ownsWriter == true`, the logger participates in deterministic destruction
  (see 380.9).
- If `ownsWriter == false`, the logger must **not** close or destroy the writer.

The exact mechanism for setting `ownsWriter` is implementation-specific (e.g.
separate constructors).

---

## 380.8 Logging Methods

### 380.8.1 Method Set

At minimum, a `Logger` MUST provide the following methods:
```ori
func (l *Logger) Debug(msg string, fields ...any)
func (l *Logger) Info(msg string, fields ...any)
func (l *Logger) Warn(msg string, fields ...any)
func (l *Logger) Error(msg string, fields ...any)
func (l *Logger) Fatal(msg string, fields ...any) // see 380.8.4
```

All methods:
1. MUST be safe to call concurrently from multiple tasks.
2. MUST NOT panic under normal circumstances.
3. MUST NOT return errors to the caller. Logging APIs are fire‑and‑forget from
   the caller’s perspective; error handling is described in `380.10`.

The `fields` parameters represent key/value pairs as described in `380.4.2`.
Implementations SHOULD validate that the number of fields is even and SHOULD handle malformed input in a predictable way (e.g. ignore the trailing value).

### 380.8.2 Level Filtering

Each method MUST perform a level check before allocating or formatting:
- `Debug` emits only when `LogLevel.Debug >= logger.level`.
- `Info` emits only when `LogLevel.Info >= logger.level`.
- `Warn` emits only when `LogLevel.Warn >= logger.level`.
- `Error` emits only when `LogLevel.Error >= logger.level`.
- `Fatal` always emits if called; level filtering does not apply to `Fatal`.

If a record is filtered out, the method MUST return immediately without:
- allocating memory for formatting,
- writing to the writer,
- or producing side effects.

### 380.8.3 Example Usage

```ori
var logger = NewLogger(
    writer: fileWriter,
    level: LogLevel.Info,
    timeFn: time.Now,
    exitFn: os.Exit,
)

logger.Info("server started",
    "port", port,
    "secure", isTLS,
)

logger.Warn("high memory usage",
    "bytes", memUsage,
)

logger.Error("failed to reload config",
    "file", path,
    "err", err,
)
```

### 380.8.4 Fatal Semantics

`Fatal` is reserved for unrecoverable conditions. Its behavior is strictly defined:
```ori
func (l *Logger) Fatal(msg string, fields ...any)
```

MUST perform, in order:
1. Construct the log record with level `LogLevel.Fatal`.
2. Serialize and write the log record to `l.writer`.
3. If `l.writer` implements `Flusher`, call `Flush()`:
   - Any error from `Flush` is ignored for the purpose of control flow.
   - Implementations MAY record the flush error internally.
4. Call `l.exitFn(1)` to terminate the process with exit code `1`.

Rules:
1. `Fatal` MUST NOT return to the caller in normal execution.
2. `Fatal` MUST be safe to call concurrently with other logging methods. Once
   `exitFn` is called, the process terminates and further behavior is undefined.
3. `Fatal` MUST NOT rely on deterministic destructors to flush or close writers.
   The explicit flush in step (3) is the only guarantee of delivery.

> **Testing note:** In tests, users SHOULD inject an `exitFn` that does not
> terminate the process (e.g. a function that panics with a sentinel value).
> This allows tests to assert on fatal behavior. See `380.11.2`.

---

## 380.9 Deterministic Destruction Integration

### 380.9.1 Logger Lifetime

When a `Logger` instance reaches its deterministic destruction point (see `220_DeterministicDestruction.md`), the following semantics apply:
1. If `ownsWriter == true`, the logger MUST perform any cleanup required to release the writer. For file writers, this ypically involves closing the underlying file handle.
2. If `ownsWriter == false`, the logger MUST NOT close or destroy the writer.

The exact mechanism for resource release (e.g. `Close` methods) is defined by the corresponding writer types and their semantics, not by this file.

### 380.9.2 Interaction with Fatal

`os.Exit` and other process‑terminating mechanisms **do not** trigger deterministic destruction.  
Therefore:
- When `Fatal` calls `exitFn(1)`, destructors for `Logger` and its writer are not guaranteed to run.
- The only flushing guarantee for fatal records is the explicit flush described in `380.8.4`.

Documentation for the logging library MUST state this clearly.

---

## 380.10 Error Handling in Logging

### 380.10.1 No Error Returns

Logging methods (`Debug`, `Info`, `Warn`, `Error`, `Fatal`) MUST NOT return errors.
The primary reasons are:
- Logging is typically non‑critical and should not clutter control flow with error handling.
- Errors while logging usually indicate underlying I/O issues that require higher-level handling (e.g. health checks, telemetry), not per‑call handling.

### 380.10.2 Internal Error Recording

Implementations MAY record the last write or flush error internally, for example:
```ori
func (l *Logger) LastError() error
```

If such an accessor is provided, the following rules apply:
1. It MUST be safe to call concurrently.
2. It MUST NOT panic.
3. It MUST return `nil` if no error has been observed since construction or since the last reset (if resetting is supported).

### 380.10.3 Error Callbacks

Implementations MAY also support an optional error callback that is invoked when a write or flush error occurs.  
Such callbacks:
1. MUST be invoked synchronously from the logging method that observes the error.
2. MUST NOT themselves call logging methods on the same logger (to avoid cycles).
3. MUST be documented as advanced usage.

This specification does not require error callbacks; they are an allowed extension.

---

## 380.11 Testing Considerations

### 380.11.1 Injected Clocks

By injecting `timeFn` into `NewLogger`, tests can:
- Use deterministic timestamps.
- Avoid relying on wall‑clock time.

This is consistent with `003_Time.md` and `300_TestingFramework_Phase1/2.md`.

### 380.11.2 Testing Fatal Behavior

In tests, `exitFn` MUST be overridden to avoid terminating the test process:
```ori
func testExit(code int) {
    panic(TestExit{code: code})
}

func TestFatalLogging(t *TestContext) {
    var logger = NewLogger(
        writer: testWriter,
        level: LogLevel.Debug,
        timeFn: fakeTime.Now,
        exitFn: testExit,
    )

    t.ExpectPanic(TestExit{code: 1}, func() {
        logger.Fatal("boom")
    })

    // Assert that testWriter received the fatal record.
}
```

This pattern allows unit tests to:
1. Verify that `Fatal` logs a record.
2. Verify that `Fatal` terminates with the expected exit code.
3. Avoid hard‑wiring `os.Exit` into test processes.

### 380.11.3 Capturing Logs in Tests

The testing framework or test helpers MAY provide a dedicated `TestWriter` that:
- Stores log records in memory.
- Implements `Writer` (and optionally `Flusher`).
- Allows tests to assert on captured records (messages, levels, fields).

The semantics of such test‑only components are outside the scope of this file but MUST respect the contracts defined in `380.5`.

---

## 380.12 Future Extensions (Non‑Normative)

The following features are explicitly left for future versions:

1. **AsyncLogger**  
   A logger implementation that uses a background task and a bounded queue to decouple log call latency from I/O latency. It MUST preserve structured record semantics and level filtering rules.

2. **Context‑Enriched Loggers**  
   Helper APIs for deriving loggers with additional fixed fields (e.g. component or request identifiers). These would produce child loggers that reuse the same underlying writer and exit function but prepend fields or prefixes.

3. **Per‑module or per‑package logging configuration**  
   Integration of logging configuration with module metadata (`270_ModulesAndCompilationUnits_Phase1/2.md`)
   and the build system (`330_BuildSystemAndCompilationPipeline_Phase1/2.md`).

4. **Pluggable serializers**  
   Supporting multiple serialization formats (plain text, JSON, ND‑JSON, etc.) via explicit strategy objects, without changing the core logging semantics.

None of these extensions affect the core guarantees specified in this file.

---

## 380.13 Summary of Key Guarantees

1. **Levels**: `Debug`, `Info`, `Warn`, `Error`, `Fatal` with strictly ordered severity.
2. **Structured logging**: message + key/value fields, with preserved field order.
3. **Concurrency**: `Logger` is safe for concurrent use from multiple tasks.
4. **Writers**: implement `Writer`, optionally `Flusher` for buffered output.
5. **Fatal**: log → optional flush → terminate via `exitFn(1)`; does not rely on deterministic destruction.
6. **Deterministic destruction**: loggers may own writers; they release them on destruction in normal execution, but not after `Fatal`.
7. **Errors**: logging methods do not return errors; implementations may expose error inspection or callbacks as advanced features.
