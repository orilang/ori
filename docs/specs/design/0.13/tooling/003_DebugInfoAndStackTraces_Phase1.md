# 003. Debug Info and Stack Traces – Phase 1

This document defines the **Phase 1** specification for Ori’s runtime debug information and stack trace behavior.

It is part of the tooling layer and builds on:
- `330_BuildSystemAndCompilationPipeline_Phase1.md` (build flags, pipeline)
- `300_TestingFramework_Phase1.md` (test execution rules)
- The concurrency / executor specifications (tasks and scheduling)

`Phase 1` focuses on **textual stack traces** and the **minimum debug-info contract** required for debugging Ori programs. It does **not** define a binary debug-info format or external debugger protocol.

---

## 003.1 Goals and Non-Goals

### 003.1.1 Goals

- Provide a **predictable, language-level contract** for:
  - When stack traces are produced.
  - What information they contain in **debug-info-rich builds**.
  - How stack traces interact with Ori’s task and executor model.
- Ensure stack traces remain **coherent and meaningful** under both `--opt=release` and `--opt=aggressive`.
- Define the behavior of stack traces for:
  - Unhandled panics / unrecoverable errors.
  - Test failures in `ori test`.
  - Optional explicit stack trace capture API (Phase 1: design hooks, not full API).

### 003.1.2 Non-Goals

- No binary debug format (DWARF, PDB, etc.) is specified.
- No debugger protocol or integration (e.g. breakpoints, watch expressions).
- No guarantees about local variable naming or availability in stack traces.
- No graphical / IDE presentation is mandated; only the **textual contract** is.

---

## 003.2 Terminology

- **Frame**: One logical call-site in the stack trace, representing a function call in the Ori program (real or inlined).
- **Stack trace**: A sequence of frames, ordered from most-recent call (top) to earliest call (bottom).
- **Debug-info-rich build**: Any build where `--debug-info` is not `none` (e.g. `--debug-info=full` or `--debug-info=line`).
- **Stripped build**: A build where `--debug-info=none`.
- **Task**: A unit of concurrent execution managed by the Ori executor. Tasks are created via the concurrency APIs (e.g. `spawn_task`) and scheduled by the executor runtime.

---

## 003.3 Build Flags and Debug Info

Ori’s build flags are defined in `330_BuildSystemAndCompilationPipeline_Phase1.md`.

`Phase 1` introduces **debug-info semantics** without changing the optimization axis.

### 003.3.1 Optimization Axis

The optimization axis is **unchanged**:
- `--opt=release` (default)
- `--opt=aggressive`

No other `--opt` values (such as `debug`) are introduced in `Phase 1`.

### 003.3.2 Debug-Info Axis

Implementations MUST support at least the following debug-info settings:
- `--debug-info=full`
  - Full symbol and line information is emitted.
  - Intended for development, testing, and debugging.
- `--debug-info=none`
  - No debug information is guaranteed.
  - Stack trace quality and contents are implementation-defined (may be minimal).

Implementations MAY additionally support intermediate levels, such as:
- `--debug-info=line`
  - Enough information to reconstruct:
    - Function names.
    - File paths.
    - Line numbers.
  - Local variable names and some metadata may be omitted.

Unless explicitly overridden by the user, the **default** debug-info setting in `Phase 1` is implementation-defined, but it is **recommended** that compilers default to a debug-info-rich configuration suitable for development and testing (e.g. `--debug-info=full`).

---

## 003.4 Stack Trace Model

### 003.4.1 When Stack Traces Are Produced

`Phase 1` requires stack traces for at least the following events:

1. **Unhandled panic / unrecoverable error in any task**  
   - A stack trace MUST be produced before the process terminates.
   - The trace MUST identify the task in which the panic occurred.

2. **Test failures under `ori test`**  
   - When a test function panics or fails with a fatal error, the test runner
     MUST emit a stack trace for the failing test case.

3. **Optional explicit capture** (forward-compatible hook)  
   - The standard library MAY expose a function such as:
     ```ori
     func CaptureStackTrace() StackTrace
     ```
     or similar. `Phase 1` only **reserves** this concept; the exact API can be defined later. The semantics of the trace content are the same as for panic-produced traces.

### 003.4.2 Frame Contents (Debug-Info-Rich Builds)

In a debug-info-rich build (`--debug-info != none`), each frame in a stack trace MUST contain at least:
- The **fully qualified function name**, including:
  - Package path.
  - Function or method name.
- The **source file path** (implementation may normalize or abbreviate paths).
- The **line number** associated with the call site.
- The implementation MAY also include:
  - Column number.
  - Additional metadata (e.g. inlined marker, async/task boundary markers).

Example (illustrative, not binding on exact text format):
```text
panic: index out of range
task 3 (spawned at main.main:42)

  at myapp/internal/core.(*Worker).run (internal/core/worker.ori:87)
  at myapp/internal/core.processItem (internal/core/processor.ori:123)
  at myapp/main.main (main.ori:42)
```

The **ordering** is always:
- Top frame = site where the panic or explicit capture occurred.
- Bottom frame = earliest reachable call in the current call-chain.

### 003.4.3 Frames and Inlining

Optimizations (especially under `--opt=aggressive`) may inline functions and rearrange code, but stack traces in debug-info-rich builds MUST remain **coherent and meaningful**:
- The implementation MAY:
  - Mark inlined functions explicitly.
  - Collapse multiple inlined calls into a smaller number of frames.
- The implementation MUST NOT:
  - Produce arbitrary or misleading file/line information for non-pathological user code.
  - Emit frames out of order (no reordering of the logical call chain).

The exact mapping from inlined code back to frames is implementation-defined, but users MUST be able to recognize:
- Where in their source a panic or failure originates.
- The logical sequence of calls leading to that point (possibly with inlined calls annotated or partially elided).

### 003.4.4 Tail Calls and Recursion

Tail-call optimizations MAY elide frames, but **the same requirements** apply:
- For debug-info-rich builds, traces MUST remain coherent and show a meaningful path back to user code, even if some tail-call frames are removed.

Deep recursion may hit platform or runtime limits; the implementation MAY truncate traces, but truncated traces SHOULD:
- Indicate truncation (e.g. `... 50 more frames ...`).
- Preserve the most recent frames (closest to the panic) at a minimum.

---

## 003.5 Tasks and Executor Integration

Ori uses an executor and tasks for concurrency. `Phase 1` defines how stack traces must represent this model.

### 003.5.1 Identifying the Task

Every stack trace MUST indicate:
- The **task identifier** in which the error occurred (e.g. `task 3`).
- Whether the task is the **main task** (the one running `main.main`).

The exact format of task identifiers is implementation-defined, but they MUST form a stable identifier within a single process execution (for example, integer IDs assigned incrementally by the executor).

Example:
```text
panic: connection closed unexpectedly
task 5 (spawned at net/server.(*Server).Serve:88)
```

Here, `task 5` refers to the logical Ori task with ID 5 managed by the executor, regardless of which OS thread actually executed it or which API created it (e.g. `spawn_task`, `spawn_thread`, a task group helper, or test runner).

### 003.5.2 Spawn Site Information

In debug-info-rich builds, stack traces MUST include:
- The **spawn site** of the task:
  - Function name.
  - File path.
  - Line number where the task was created.

This can be rendered either:
- As a separate line near the task header (as shown above), or
- As a synthetic frame at the bottom of the task’s stack trace.

The requirement is that users can identify **where** the task originated.  
Example (synthetic bottom frame):
```text
task 5:

  at net/server.handleConnection (server.ori:210)
  at net/server.(*Server).Serve (server.ori:88)
  at [task spawned from main.main (main.ori:42)]
```

The exact formatting is implementation-defined but MUST include this spawn-site information in debug-info-rich builds.

### 003.5.3 Cross-Task Failures

If a panic in one task causes other tasks to be cancelled or aborted, the runtime is only required to emit **one primary stack trace**:
- The primary trace MUST be for the task where the panic or unrecoverable error originated.
- Implementations MAY optionally emit additional traces (e.g. for tasks that were waiting on the failing task), but this is not required in `Phase 1`.

---

## 003.6 Interaction with `--opt` and `--debug-info`

### 003.6.1 Optimization (`--opt`)

- `--opt=release` and `--opt=aggressive` control optimization strength as defined
  in `330_BuildSystemAndCompilationPipeline_Phase1.md`.
- Optimization MAY:
  - Inline functions.
  - Reorder basic blocks.
  - Elide trivial frames.

However, in a **debug-info-rich build**:
- Stack traces MUST still:
  - Provide correct function names for frames.
  - Map frames to accurate file/line locations for non-pathological user code.
- The implementation MAY represent inlined or elided frames in an implementation-defined way, as discussed in `003.4.3`.

### 003.6.2 Debug Info (`--debug-info`)

In **debug-info-rich builds** (`--debug-info` not `none`):

- The requirements from `003.4` and `003.5` are **mandatory**.
- Unhandled panics and test failures MUST emit stack traces containing:
  - Function names.
  - File paths.
  - Line numbers.
  - Task information (ID and spawn site).

In **stripped builds** (`--debug-info=none`):
- The implementation is not required to emit full stack traces.
- Stack traces, if any, are **implementation-defined**, but SHOULD be best-effort.
- At minimum, implementations SHOULD:
  - Emit the panic message or error reason.
  - Optionally include partial or symbolic stack information.

`Phase 1` does not require any relationship between `--debug-info` and the placement of debug information (e.g. embedded in the binary vs separate files).

---

## 003.7 Panic and Unrecoverable Error Behavior

### 003.7.1 Panic in the Main Task

When a panic or unrecoverable error occurs in the main task:
1. The runtime MUST capture a stack trace (subject to `--debug-info`).
2. The runtime MUST emit the panic message and stack trace to the standard error stream (or equivalent log channel defined by the platform / runtime).
3. The process MUST terminate with a non-zero exit code.

Ordering relative to deterministic destruction:
- The language guarantees that deterministic destruction semantics still apply.
- `Phase 1` does not mandate whether stack trace emission happens before or after all destructors run, but implementations SHOULD ensure that:
  - The stack trace is visible even if some destructors themselves fail.

### 003.7.2 Panic in a Non-Main Task

When a panic occurs in a non-main task:
- The same rules apply:
  - A stack trace MUST be captured.
  - The panic message and stack trace MUST be emitted.
  - The process MUST terminate with a non-zero exit code, unless the language later defines recoverable panics for specific contexts (out of scope for `Phase 1`).

Recoverable panics, if introduced later, MUST specify how they impact stack trace behavior; for `Phase 1`, all panics are considered unrecoverable.

---

## 003.8 Integration with `ori test`

The testing framework is defined in `300_TestingFramework_Phase1.md`. `Phase 1` defines the following expectations for `ori test`:
- When a test fails due to:
  - A panic.
  - A fatal assertion or expectation failure that aborts the test body.
- The test runner MUST:
  - Emit a stack trace for the failing test case.
  - Clearly associate the trace with the test name.

Example (illustrative):
```text
--- FAIL: TestConcurrentAccess
panic: race detected on shared resource
task 7 (spawned at tests/concurrency_test.ori:23)

  at myapp/internal/store.(*Store).put (internal/store/store.ori:110)
  at myapp/internal/store.(*Store).Put (internal/store/store.ori:95)
  at myapp/tests.TestConcurrentAccess (tests/concurrency_test.ori:30)
```

Timeouts and deadlines (as specified in the testing framework) MAY also produce stack traces, but this is not required in `Phase 1`. An implementation MAY:
- Emit a stack trace showing where the test appears to be stuck.
- Or emit only a failure message indicating a timeout.

Future phases of the testing framework may add stronger requirements for deadlines and timeout diagnostics.

---

## 003.9 Textual Format and Tooling Hooks

### 003.9.1 Human-Readable Format

The exact textual layout (indentation, punctuation) of stack traces is implementation-defined, but implementations MUST:
- Use a **consistent and documented format**.
- Ensure that:
  - Each frame is clearly distinguishable (e.g. one line per frame).
  - The panic/error message is clearly separated from the stack frames.
  - The task identifier and spawn site are clearly indicated.

### 003.9.2 Machine-Readable Extensions (Optional)

`Phase 1` does **not** require a machine-readable format (JSON, etc.), but:
- Implementations MAY additionally emit stack trace information in a structured form (e.g. via a logging framework or side-channel).
- If such a format exists, it MUST still satisfy the semantics of this document (same frames, same mapping to function/file/line), even if presented differently.

Future tooling phases may standardize a machine-readable stack trace format.

---

## 003.10 Future Extensions

Future phases may extend this specification to include:
- Binary debug-info formats and mappings to platform debuggers.
- More precise guarantees about local variable availability in stack frames.
- Integrated support for async/await-style constructs (if added to the language) and their impact on stack traces.
- Stronger guarantees around timeouts and deadlines in `ori test`, including  automatic capture of stack traces for hung or slow tests.
- Configurable stack trace rendering (e.g. hide standard library frames).

This `Phase 1` document is intentionally conservative to avoid constraining future debugger integration and runtime evolution.

---

## 003.11 Summary

`Phase 1` defines:
- A **debug-info axis** (`--debug-info`) orthogonal to optimization (`--opt`).
- A clear contract for stack traces in **debug-info-rich builds**:
  - Frames with function, file, and line information.
  - Task identifiers and spawn sites.
- Required behavior for:
  - Unhandled panics in main and non-main tasks.
  - Test failures under `ori test`.

These rules provide a stable foundation for debugging Ori programs while leaving room for future, more advanced tooling features.
