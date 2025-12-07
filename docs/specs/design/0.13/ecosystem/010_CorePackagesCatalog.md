# 010. Core Packages Catalog

This document catalogs Ori’s core standard library packages.

It is **not** a detailed API specification.  
Instead, it defines:
- Which packages exist
- Whether they are **v1.0 core** or **planned post-1.0**
- Their responsibilities and relationships
- Cross-cutting constraints (no reflection magic, no global mutable state, deterministic destruction, etc.)

`ecosystem/001_StandardLibraryFoundations.md` defines high-level philosophy.  
This file lists the **concrete packages** that implement that philosophy.

---

## 010.1 Version & Stability Model

Each package in this catalog is tagged with one of:

- **Status: v1.0 core**  
  Must exist and be usable in Ori v1.0.

- **Status: planned post-1.0**  
  Conceptually part of the standard library, but can ship in a later minor version without blocking v1.0.

A package can move from "planned post-1.0" to "v1.0 core" via roadmap decisions in future versions of the language spec.

---

## 010.2 Global Constraints for All Packages

All standard packages must respect Ori’s core principles:

1. **No global mutable state**
   - Global constants are allowed.
   - Global variables are forbidden.
   - Shared resources (e.g. loggers, executors) are created explicitly and passed around.

2. **No runtime reflection**
   - No APIs that inspect arbitrary structs/interfaces at runtime.
   - Compile-time reflection may be used by library authors, but the resulting APIs are explicit and type-directed.

3. **Deterministic destruction**
   - Any package that allocates OS resources (files, sockets, timers, threads, tasks, etc.) must define clear rules for:
     - Ownership.
     - When destruction happens.
     - What the destructor can and cannot do.
   - Leaking resources is always a concrete, visible choice (e.g. moving ownership).

4. **Explicit error handling**
   - No hidden panics for recoverable errors.
   - Errors are returned explicitly and documented.

5. **No hidden buffering or background threads**
   - Buffering must be explicit (e.g. `bufio`).
   - Background threads/tasks are created via explicit, documented APIs (e.g. `executor`).

6. **No attributes / annotations**
   - No `@deprecated`, `@tag`, `@serde`, etc. in the language.
   - Standard library does not assume the existence of such constructs.

---

## 010.3 Package Categories

Packages are grouped by domain:
- **Core runtime & OS**: `os`, `fs`, `filepath`
- **I/O primitives**: `io`, `bufio`
- **Text & data**: `strings`, `utf8`, `bytes`
- **Time & scheduling**: `time`, `executor`
- **Diagnostics & formatting**: `fmt`, `log`
- **Testing & tooling**: `testing`, `testing/quick` (post-1.0)
- **Networking & encoding** (planned post-1.0): `net`, `json`, `hash/*`, `flag`, etc.

---

## 010.4 Core Runtime & OS

### 010.4.1 `os`

**Status:** v1.0 core

**Responsibilities:**

- Process-related information:
  - OS name, architecture.
  - Process ID.
- Environment variables:
  - `GetEnv`, `SetEnv`, `UnsetEnv`.
  - Clear guarantees about lifetime and visibility.
- Process exit:
  - Functions/constants to exit with a given code.
- Standard streams:
  - `os.Stdout()`, `os.Stderr()`, `os.Stdin()` returning **`shared File`** handles.
  - No global mutable `os.Stdout` variables.

**Non-responsibilities:**

- **File management** (open, create, remove, rename, etc.). Those belong to `fs`.
- Path manipulation (belongs to `filepath`).
- Networking (belongs to `net`, post-1.0).

---

### 010.4.2 `fs`

**Status:** v1.0 core

**Responsibilities:**

- Filesystem operations:
  - `Open`, `Create`, `Remove`, `Rename`, `Stat`.
  - Directory operations (create, remove, list, walk).
  - File permissions and modes (numeric / octal notation in docs).
- File handle abstractions:
  - `File` type with explicit ownership.
  - Deterministic destruction (`Close` semantics) aligned with `220_DeterministicDestruction.md`.
- Potential support for:
  - Working directories.
  - Symlinks, if the platform supports them (documented explicitly).

**Design notes:**

- `fs` is the main “user-facing” filesystem package.
- Ori intentionally does **not** follow Go’s `os.File` design; it instead follows the cleaner separation typical of Rust (`std::fs`) and Zig (`std.fs`).

---

### 010.4.3 `filepath`

**Status:** v1.0 core

**Responsibilities:**

- Pure path manipulation:
  - `Join`, `Split`, `Base`, `Dir`.
  - `Ext`, `Clean`, `IsAbs`, etc.
- OS-dependent separator behavior (documented, but without side effects).
- Functions operate on strings; they do not touch the filesystem.

**Non-responsibilities:**

- Opening files or checking their existence (belongs to `fs`).

---

## 010.5 I/O Primitives

### 010.5.1 `io`

**Status:** v1.0 core

**Responsibilities:**

- Fundamental I/O interfaces:
  - `Reader`, `Writer`.
  - `ReadCloser`, `WriteCloser`.
  - `Seeker` / `Seekable` abstractions.
- Utility functions:
  - Copying between `Reader` and `Writer`.
  - Discard sinks, limited readers, etc.

**Design constraints:**

- No hidden buffering.
- No magic transformations (e.g. no transparent compression/decompression).
- Error behavior is explicit and consistent.

---

### 010.5.2 `bufio`

**Status:** v1.0 core

**Responsibilities:**

- Explicit buffering decorators around `io.Reader` and `io.Writer`:
  - `BufferedReader`, `BufferedWriter`, or similar types.
- APIs to:
  - Control buffer size.
  - Flush explicitly.
  - Inspect how much is buffered.

**Design constraints:**

- No implicit global buffers.
- No automatic background flush threads.
- Buffering never happens silently; the type names and constructors make it obvious.

---

## 010.6 Text & Data

### 010.6.1 `bytes`

**Status:** v1.0 core

**Responsibilities:**

- Utilities for `[]byte` manipulation:
  - Search, split, join.
  - Efficient building and reading of byte sequences.
- In-memory buffer objects layered on `[]byte`.
- Useful for binary protocols and FFI.

**Design constraints:**

- No UTF-8 assumptions.
- No automatic conversions to/from strings.

---

### 010.6.2 `strings`

**Status:** v1.0 core

**Responsibilities:**

- String utilities:
  - `Contains`, `HasPrefix`, `HasSuffix`.
  - `Index`, `LastIndex`, etc.
  - `Trim`, `TrimSpace`, `ToLower`/`ToUpper` for ASCII (Unicode behavior must be explicitly defined).
- Safe, explicit iteration helpers (by byte, by rune) consistent with the UTF-8 model.

**Design constraints:**

- String indices are in **bytes**, not runes.
- No implicit normalization.
- Any Unicode-aware behavior must be explicitly documented and typically built on top of `utf8`.

---

### 010.6.3 `utf8`

**Status:** v1.0 core

**Responsibilities:**

- Low-level UTF-8 primitives:
  - Rune decoding and encoding.
  - Validation of byte sequences.
  - Counting runes, checking boundaries.

**Design constraints:**

- `utf8` is a **low-level building block**.
- Higher-level functions for working with textual data should live in `strings` and in future text packages.
- No normalization logic is built in; that would be part of a future, more advanced `text` package if needed.

---

## 010.7 Time & Scheduling

### 010.7.1 `time`

**Status:** v1.0 core (already defined in `ecosystem/003_Time.md`)

**Responsibilities:**

- Time representations:
  - `Duration`.
  - Monotonic vs wall-clock time.
- Utilities:
  - `Now`, monotonic clocks, `Sleep`, timers.
  - Arithmetic on durations and timestamps.

---

### 010.7.2 `executor`

**Status:** v1.0 core

**Responsibilities:**

- Library layer on top of `190_Concurrency.md` and `400_ExecutorAndTasks_Phase2.md`.
- Facilities for:
  - Task scheduling primitives that are too high-level or configurable to be keywords.
  - Task groups, pools, structured concurrency helpers.
  - Cancellation, deadline propagation.
  - Graceful shutdown of hierarchies of tasks.

**Design constraints:**

- No hidden global executor instance; users must construct executors explicitly or use well-documented defaults.
- The library must respect the concurrency rules of Ori (no implicit sharing without `shared`, etc.).
- Integrates with `time` for deadlines/timeouts.

---

## 010.8 Diagnostics & Formatting

### 010.8.1 `fmt`

**Status:** v1.0 core

**Responsibilities:**

- Human-oriented text formatting for:
  - Debugging.
  - CLI tools.
  - Simple user messages.
- Formatting APIs that do **not** rely on runtime reflection:
  - Type-safe formatting functions.
  - Interfaces for types that want to define custom formatting behavior (e.g. `Format`-style methods).

**Design constraints:**

- No `%v`-style “print anything by reflection”.
- No reflection-driven formatting like Go’s `fmt` package.
- For complex types, the user must implement explicit formatting behavior (or use generated code at compile time).
- `fmt` focuses on human readability; structured, machine-readable logging belongs to `log`.

---

### 010.8.2 `log`

**Status:** v1.0 core

**Responsibilities:**

- Structured logging with:
  - Log levels (e.g. Debug, Info, Warn, Error, Fatal).
  - Key-value pairs for context.
- Composable loggers:
  - Different outputs (stdout, file, in-memory).
  - Easily redirected during testing.
- Integration with `io`/`bufio` for performance and `fs` for file logging.

**Design constraints:**

- No global mutable “default logger”.
- Creating and passing loggers is explicit.
- No hidden threads or async behavior; if async logging exists, it must be explicit and documented.
- Deterministic destruction of log targets (e.g. closing log files) is mandatory.

---

## 010.9 Testing & Tooling

### 010.9.1 `testing`

**Status:** v1.0 core

**Responsibilities:**

- Standard test harness integration, consistent with `300_TestingFramework_Phase1/2.md`.
- Core types and helpers:
  - `TestContext`.
  - `t.Run`, `t.Parallel` (subject to language rules).
  - `t.Deadline` (top-level only, as per semantics).
  - OS filtering (e.g. skipping tests on unsupported platforms).
- Utilities for:
  - Temporary directories and files in a safe, controlled way.
  - Common assertions or helpers (if decided in the semantics).

**Design constraints:**

- No attributes/annotations such as `@test`.
- Tests are discovered by naming and `_test.ori` files, similar in spirit to Go but using Ori’s semantics.
- Integration with `time` and `executor` for deadlines and parallelism.

---

### 010.9.2 `testing/quick` (or equivalent)

**Status:** planned post-1.0

**Responsibilities:**

- Property-based / randomized testing tools.
- Generators for common data structures.

**Design constraints:**

- Must build on top of `testing` but not be required for basic unit testing.
- Might require more advanced compile-time support and should not block v1.0.

---

## 010.10 Planned Post-1.0 Packages

The following packages are **intentionally excluded from v1.0**, but are anticipated as natural evolutions of the ecosystem.

They are listed here to keep the big picture coherent.

### 010.10.1 `net`

**Status:** planned post-1.0

**Responsibilities:**

- Basic networking primitives (TCP, UDP).
- Name resolution.
- Timeouts for network operations (using `time` and possibly `executor`).

**Design constraints:**

- No HTTP or higher-level protocols in the initial `net`.
- No hidden global connection pools.

---

### 010.10.2 `json`

**Status:** planned post-1.0

**Responsibilities:**

- JSON encoder/decoder.
- APIs that do **not** depend on runtime reflection:
  - Users provide explicit encode/decode logic.
  - Optional compile-time helpers could generate boilerplate.

**Design constraints:**

- RFC-compliant, well-specified behavior.
- No hidden global config.

---

### 010.10.3 `hash` and `hash/*`

**Status:** planned post-1.0

**Responsibilities:**

- `hash`:
  - Common interface for hash functions (e.g. `Write([]byte)`, `Sum()`).
- `hash/sha256`, `hash/sha1`, `hash/sha512`, etc.:
  - Concrete implementations.

**Design constraints:**

- Deterministic and well-documented behavior.
- No automatic global registries.

---

### 010.10.4 `flag`

**Status:** planned post-1.0

**Responsibilities:**

- Command-line parsing for executables.

**Design constraints:**

- Safe defaults.
- No hidden global state; parsing is done through explicit objects passed to `main` or similar.

---

### 010.10.5 Advanced text packages (e.g. `text`, `text/normalize`)

**Status:** planned post-1.0

**Potential responsibilities:**

- Unicode normalization.
- Locale-aware operations.
- More advanced text manipulation than `strings`/`utf8`.

**Design constraints:**

- No implicit normalization in core types (`string` remains raw UTF-8).
- All heavy text features are opt-in via these packages.

---

## 010.11 Summary

For Ori v1.0, the **core standard library surface** is:
- `os`, `fs`, `filepath`
- `io`, `bufio`
- `strings`, `utf8`, `bytes`
- `time`, `executor`
- `fmt`, `log`
- `testing`

These packages:
- Follow the cleaner separation patterns seen in modern systems languages.
- Respect Ori’s strict rules on determinism, explicitness, and the absence of runtime reflection or global mutable state.

Future versions of the language and ecosystem will add:
- Networking (`net`),
- JSON (`json`),
- Hashing (`hash/*`),
- CLI helpers (`flag`),
- Advanced text and testing facilities,

without breaking the structure laid out in this catalog.
