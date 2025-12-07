# ROADMAP_v0.13.md

This document describes the Ori v0.13 milestone.

v0.13 is intentionally small and focused on **developer experience**: debug information, stack traces, and a canonical formatter.

Unsafe features and FFI are explicitly **out of scope** for this milestone and may be introduced in v1 or later, depending on implementation experience.

---

## 1. Scope and Goals

The goals of v0.13 are:

- Define the **minimum debuggability contract** for Ori programs:
  - What information must be available in stack traces.
  - How this interacts with tasks and the executor model.
- Define the **canonical Ori code style** and the behavior of an `ori fmt` tool:
  - A single, deterministic formatting style.
  - Integration expectations with the build and tooling pipeline.

Non-goals:
- No new core language features.
- No changes to the type system, memory model, or concurrency semantics.
- No FFI or `unsafe` features.

---

## 2. Items

### 2.1 Debug Info & Stack Traces – Phase 1

**Spec file:** `tooling/003_DebugInfoAndStackTraces_Phase1.md`

**Objective:**  
Define the baseline guarantees for debug information emitted by the compiler and the behavior of stack traces across different optimization levels and debug-info settings.

**Key points:**

- Required contents of a stack frame in a trace (in debug-info-rich builds):
  - Function name.
  - Source file path (or module path).
  - Line number (and optionally column).
- Task-aware stack traces:
  - Each stack trace must clearly indicate:
    - The task identifier.
    - The location where the task was spawned (call site).
- Behavior on:
  - Unhandled panics / unrecoverable errors.
  - Test failures (integration with the testing framework).
- Optimization interaction:
  - `--opt=release` and `--opt=aggressive` may inline or elide frames,
    but stack traces in debug-info-rich builds must still be coherent and meaningful.
- Debug-info axis:
  - `--debug-info=full`: full symbol and line information, suitable for development and testing.
  - `--debug-info=none`: no debug information is guaranteed; stack trace quality is implementation-defined.
  - Implementations MAY support additional intermediate levels (e.g. `--debug-info=line`).
- Guarantees for tools (in debug-info-rich builds):
  - Debug info is stable enough to be consumed by external debuggers and profilers.
  - Symbol naming scheme is deterministic.

Milestone exit criteria:
- The spec clearly defines:
  - Stack trace shape.
  - The minimum information that must be present in debug-info-rich builds.
  - How tasks and the executor model appear in traces.
  - How `--opt` and `--debug-info` influence stack traces.
- At least one example stack trace for:
  - A simple panic in the main task.
  - A panic in a spawned task.

---

### 2.2 Formatter & Code Style – Phase 1

**Spec file:** `tooling/004_FormatterAndCodeStyle_Phase1.md`

**Objective:**  
Define the canonical Ori code style and the behavior of the `orifmt` tool so that all codebases can converge on a single, predictable formatting.

**Key points:**

- Global philosophy:
  - Formatter is **idempotent**.
  - Minimal or no configuration; projects are not expected to customize style.
- Syntax layout rules:
  - Indentation (spaces, width).
  - Brace placement for:
    - `func`, `if`, `for`, `switch`, `type struct`, `type enum`, `type` aliases, etc.
  - Spacing around operators, commas, colons, and keywords.
- Imports and declarations:
  - Deterministic ordering of imports.
  - Recommended ordering of top-level declarations in a file (types, vars, consts, funcs).
- Interaction with comments:
  - Rules for preserving line comments and block comments.
  - Stable behavior around `switch` cases and nested control-flow.
  - Forward-compatible wording for future constructs (e.g. `unsafe` blocks, FFI declarations) without defining them yet.
- Tooling integration:
  - `ori fmt` (or equivalent) subcommand.
  - Expected integration points with IDEs and editors (format-on-save).
- Relationship with compiler diagnostics:
  - Style issues are handled by the formatter, not the compiler.
  - The compiler never rejects programs solely on formatting grounds.

Milestone exit criteria:
- The spec describes:
  - A complete, deterministic formatting style.
  - Expected CLI behavior (`ori fmt ...`).
- Example before/after snippets for:
  - A typical file with imports, a struct, and several functions.
  - A file with `switch`, `for`, and `if` nesting.

---

## 3. Non-Goals for v0.13

The following are explicitly **out of scope** for v0.13:

- **Unsafe operations** and `unsafe` blocks.
- **Foreign Function Interface (FFI)** of any kind (C or other).
- ABI and memory layout guarantees.
- Changes to:
  - Deterministic destruction semantics.
  - Concurrency and task model.
  - Type system or generics.
  - Compile-time reflection.

These topics are candidates for post-v0.13 milestones and may land in v1 or later, depending on implementation experience and prototyping feedback.

---

## 4. Forward Compatibility Notes

To keep future paths open for unsafe and FFI without breaking v1 code:
- Certain identifiers may be reserved for future language features, for example:
  - `unsafe`, `extern`, and others to be decided when such features are designed.
- The current specification:
  - **Does not define any FFI or ABI contract.**
  - Does not guarantee in-memory layout of most types.
- Programs that rely on:
  - Specific struct/enum layout,
  - Particular binary representation of values,
  - Or ad-hoc interaction with foreign code,
  
do so outside the language specification and may break in future versions.

---

## 5. Milestone Exit Criteria Summary

Ori v0.13 is considered complete when:
1. `tooling/003_DebugInfoAndStackTraces_Phase1.md` is written and stable:
   - Describes the minimum debug info and stack trace guarantees.
   - Includes examples for main-task and spawned-task failures.
   - Clarifies the effects of `--opt` and `--debug-info` on stack traces.

2. `tooling/004_FormatterAndCodeStyle_Phase1.md` is written and stable:
   - Describes a complete, deterministic code style.
   - Defines the behavior of an `orifmt` (or `ori fmt`) tool.
   - Provides before/after examples.

No other language features are required for this milestone.
