# 370. File System And IO Semantics

This document defines the **language-level semantics and constraints** around file system access and blocking IO in Ori.  
It does *not* freeze the standard library API surface; instead, it describes the guarantees that any `os`-level file and IO APIs must respect.

The concrete API surface of the `os` package (types, functions, examples) is specified separately in `ecosystem/001_OS.md`.
This separation keeps language semantics stable while allowing the standard library to evolve.

**Depends on:**
- `140_Errors.md` (builtin `Error` type and error handling model)  
- `220_DeterministicDestruction.md` (resource lifetimes and destructors)  
- `ecosystem/001_StandardLibraryFoundations.md` (package responsibilities and boundaries)  
- `ecosystem/001_OS.md` (concrete `os` API specification)

---

## 370.1 Goals

The semantics of file system and IO in Ori are guided by the following goals:

1. **Deterministic ownership of OS resources**  
   Types that represent OS-backed resources (such as files) must be value types with deterministic destruction.  
   There is no GC-based finalizer magic for closing files or flushing buffers.

2. **Blocking, explicit IO**  
   v0.11 defines **blocking**, **byte-oriented** IO.  
   There is no async/await, no non-blocking primitives, and no background threads started implicitly by the language.

3. **Clear error reporting**  
   All file system and IO operations must use the builtin `Error` type for failures.  
   Errors are never silently ignored by the language.

4. **No hidden buffering or extra threads**  
   The language semantics forbid implicit background tasks and hidden buffers.  
   Higher-level packages (e.g. buffered IO, async executors) must be explicit about any such behavior.

5. **Separation of semantics and API**  
   This document focuses on *what must be true* of file system and IO behavior.  
   The concrete functions, types, and helpers are described in `ecosystem/001_OS.md` and may evolve across versions.

---

## 370.2 OS-Backed Resource Types

### 370.2.1 Owning handle semantics

Any type that represents an OS-backed resource such as a file descriptor, socket, or similar handle **must**:

- be a value type with a single clear owner at any point in time
- be **move-only** (no implicit copying of ownership)
- integrate with deterministic destruction (see `220_DeterministicDestruction.md`)
- never rely on a garbage collector or hidden finalizer for cleanup

The canonical example is the `os.File` type specified in `ecosystem/001_OS.md`.

---

### 370.2.2 Destructors for IO resources

For any such resource type `R`, the destructor:

- is executed exactly once when the value's lifetime ends
- must **not panic**
- must **not perform unbounded blocking operations**
- performs a single best-effort close of the underlying OS resource

If the underlying OS close operation can fail, that failure **cannot** be surfaced from the destructor.  
There is no mechanism for propagating `Error` from destructors.  
To handle close errors, user code must call an explicit `Close()`-style method prior to scope exit.

---

### 370.2.3 Shared receivers for mutation

Methods that mutate the internal state of an IO resource value must use a **shared receiver**:

```ori
func (f shared File) Close() Error
```

This ensures:
- mutation is only allowed when the value is explicitly marked as shared
- aliasing and ownership rules remain explicit
- it is impossible to mutate a non-shared value in place

Pointer-based receivers (e.g. `*File`) must not be used as the primary mechanism for resource mutation.  
Ownership must flow through value semantics and the `shared` marker, not raw pointers.

---

## 370.3 Blocking IO Semantics

### 370.3.1 Blocking behavior

All built-in file and IO operations in v0.11 are **blocking**:
- A call to a read/write/seek/sync/stat operation may block the current task until the operation completes or fails.
- The language does not introduce any background tasks or async scheduler for these operations themselves.

Higher-level libraries or executors may provide non-blocking or async semantics in future versions, but those are explicitly outside the scope of v0.11 semantics.

---

### 370.3.2 Byte-oriented IO

At the semantics level, IO operates on **raw bytes**:

- All file and IO operations work on `[]byte` slices or similar raw byte types
- Text encoding, decoding, normalization, and Unicode-specific behavior are the responsibility of higher-level packages
- The IO semantics do not assume or enforce any particular text encoding

Future documents (e.g. a UTF-8 and text model spec) may define how strings and text interact with IO, but they do not change the base assumption that IO is byte-oriented.

---

## 370.4 Error Handling

### 370.4.1 Use of builtin `Error`

All fallible IO operations must use the builtin `Error` type defined in `140_Errors.md`.

At the semantics level, that implies:
- A successful IO operation returns a `nil` error
- A failed IO operation returns a non-`nil` error whose `Code` and `Message` are meaningful and stable within a given Ori version
- Sentinel `Error` values (e.g. `ErrNotFound`, `ErrClosed`, `ErrEOF`) can be compared using `==` and must behave consistently across platforms

The language does not introduce any special case for IO errors; they are regular `Error` values, subject to the same conventions as all other errors.

---

### 370.4.2 End-of-file semantics

The semantics of end-of-file (EOF) are standardized for all file-like IO:
- A read operation that reads **zero bytes** and encounters EOF must report a specific EOF error (e.g. `ErrEOF`)
- A read operation that reads **some bytes** and then hits EOF may return the bytes and report success; the EOF is then observed on the next call

The exact sentinel value and naming are specified in `ecosystem/001_OS.md`, but the behavior is part of the language's IO semantics.

### 370.4.3 Close errors and destructors

If an explicit `Close()` method is provided on an IO resource type:
- it may return a non-`nil` `Error` if the OS reports a failure on close
- it must be idempotent: calling it multiple times must not panic

If user code never calls `Close()`, the destructor must still close the underlying resource best-effort, but any OS-level error from that close is ignored and not reported.  
This is a deliberate trade-off to keep destructors panic-free and predictable.

---

## 370.5 Standard Streams

The process-wide standard streams (`stdin`, `stdout`, `stderr`) are special OS resources provided by the host environment.

Semantically:
- Their lifetime is managed by the operating system, not by user code
- They must not be automatically closed by regular destruction logic at program exit in a way that surprises user code
- Any `os`-level wrappers around these streams must make it clear whether they own the underlying descriptor or are non-owning views

A typical approach (described in `ecosystem/001_OS.md`) is to expose constructors like `os.Stdin()`, `os.Stdout()`, and `os.Stderr()` that return `File` values which:
- behave like regular file-like handles for read/write operations
- do **not** own the underlying OS standard streams for the purpose of destruction
- have destructors that are no-ops with respect to the underlying OS handles
- provide a `Close()` method that either returns a well-defined `ErrInvalidOperation` or is a documented no-op

This semantics document does not mandate the exact API shape, but it requires that:

- destructors for wrapper types must not attempt to close OS-managed standard streams implicitly;
- closing or not closing the wrapper must never introduce undefined behavior in the runtime.

---

## 370.6 Concurrency and IO

### 370.6.1 Task-level blocking

In the concurrency model defined by `190_Concurrency.md`, a task that performs a blocking IO operation is simply **blocked** until the operation completes.

The language semantics guarantee that:
- there is no automatic spawning of helper tasks to offload blocking IO;
- there is no implicit cooperative scheduling added by IO operations themselves.

An implementation may choose to use OS threads or other techniques to avoid blocking entire processes, but this is an implementation detail and must not change the visible blocking behavior of the calling task.

---

### 370.6.2 Thread-safety of IO resource types

The semantics do **not** require that `File`-like types be safe for concurrent use from multiple tasks without synchronization.

Instead:
- it is legal for an implementation to document `File` as **not thread-safe**;
- users who need to share IO resources between tasks must wrap them in synchronization primitives (e.g. a `Mutex`).

The `os` package documentation (ecosystem spec) must explicitly document whether its IO types are safe for concurrent use.

---

### 370.6.3 Destructors under concurrency

Because destructors run automatically at end-of-scope, the following constraints apply:

- Destructors must not assume there are no concurrent accesses to the resource; any such assumptions must be enforced at the type level or by user code.
- Destructors must not block indefinitely waiting for other tasks to finish; they should perform a single close operation and return.

This ensures that deterministic destruction remains predictable even in the presence of concurrent tasks.

---

## 370.7 File Modes and Octal Notation (Forward Compatibility)

In Unix and Linux environments, file permissions are commonly represented using **octal notation** such as `0o755` or `0755`.

Ori v0.11 does **not yet** define octal integer literals in the core language, but:
- The semantics of `FileMode` assume that it can represent permission bits that conceptually correspond to Unix-style rwx flags
- The `os` package examples (e.g. in `ecosystem/001_OS.md`) may use notation like `0o755` to describe typical permission patterns

This notation is considered **forward-looking and illustrative**:
- It indicates that future versions of Ori are expected to support octal literals (for example, with a `0o` prefix), because it is a familiar convention for file modes.
- Until octal literals are formally added to the language, such examples should be understood as conceptual and not literally valid Ori code in current version.

Standard library specs must clearly document when an example uses a future literal feature, so that implementations and users do not misinterpret it as currently-supported syntax.

---

## 370.8 Relationship to `ecosystem/001_OS.md`

This semantics document and `ecosystem/001_OS.md` are meant to be read together:

- `370_FileSystemAndIO.md` defines **what must be true** of file system and IO behavior in any conforming Ori implementation.
- `ecosystem/001_OS.md` defines **how the `os` package exposes these behaviors** via concrete types and functions.

If a future version changes the `os` API shape, this semantics document should remain largely valid, as long as:
- IO resources remain value-typed, move-only, and destructor-backed
- errors continue to use the builtin `Error` type
- IO operations remain explicitly blocking or non-blocking according to clearly documented rules
- octal file mode notation is eventually supported in a way that is consistent with the semantics described here.
