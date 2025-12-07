# 001. Standard Library Foundations

The Ori standard library is intentionally small, explicit, and guided by the same principles as the language itself: clarity, determinism, predictability, and zero hidden behavior.  
The standard library does not aim to provide a broad API surface. Instead, it establishes the foundational packages, responsibilities, and design constraints that will
shape the ecosystem as Ori evolves.

The goals are:
1. Identify the core packages that must exist in a minimal, usable system.
2. Define their conceptual responsibilities without finalizing APIs.
3. Specify boundaries: what each package must do, and what it must not do.
4. Ensure all packages integrate cleanly with:
   - the builtin Error type (see `140_Errors.md`)
   - deterministic destruction (see `220_DeterministicDestruction.md`)
   - explicit ownership and memory semantics
   - Ori's philosophy of simplicity and explicitness.

The standard library does NOT attempt to fully specify the API of each package. Only high-level design foundations are provided here.

---

# 001.1 Included Packages

The following foundational packages are introduced:
- os
- filepath
- time
- log
- sync
- net

These represent the minimal set necessary for basic system interaction, I/O, timing, concurrency primitives, and networking. No additional packages are included at this stage.

The formatting package "fmt" is intentionally postponed because it requires deeper compile-time and reflection capabilities.

---

# 001.2. Package Definitions (High-Level Only)

Each package description below outlines:
- purpose and scope
- integration requirements with Ori semantics
- design constraints
- explicit non-goals

These are NOT frozen API contracts.

---

# 001.2.1 Package: os

The `os` package provides direct interaction with operating system primitives:
- files and basic file I/O
- creation and removal of directories
- environment variables
- process identification and process exit

Responsibilities:
- Expose a minimal, explicit interface to OS resources
- Integrate with deterministic destruction: files and network sockets must be treated as owning resources automatically cleaned up at scope exit unless explicitly closed earlier
- Use the builtin `Error type` consistently.

Non-goals:
- file metadata (stat, permissions)
- buffered I/O layers
- process spawning
- symbolic links
- recursive directory operations

---

# 001.2.2 Package: filepath

The `filepath` package provides path manipulation utilities that operate purely on strings:
- extracting directory or file components
- joining paths
- normalizing paths
- checking whether a path is absolute

Responsibilities:
- Pure string manipulation, no OS access
- Provide consistent behavior across platforms by using platform-aware separators.

Non-goals for:
- globbing
- pattern matching
- realpath / canonicalization via filesystem access

---

# 001.2.3 Package: time

The `time` package provides:
- a `Time` type representing timestamps
- a `Duration` type
- obtaining the current time
- sleeping for a fixed duration

Responsibilities:
- Provide only the minimal primitives required to measure time and wait
- Avoid time zones, calendars, and formatting/parsing

Non-goals:
- date/time formatting
- locale awareness
- timers, schedulers, repeating tasks
- complex arithmetic involving months or leap years

---

# 001.2.4 Package: log

The `log` package offers:
- minimal logging utilities
- a few log levels (at least Debug, Info, Warn, Error)
- a default thread-safe logger writing to stderr

Responsibilities:
- Simple, explicit logging without reflection or formatting templates
- User-configurable output destination
- No hidden allocations unless explicitly required

Non-goals:
- printf-style formatting
- structured or JSON logging
- multi-sink logging
- contextual or hierarchical loggers

---

# 001.2.5 Package: sync

The `sync` package provides essential synchronization primitives:
- mutexes
- reader-writer locks
- minimal atomic integer type(s)

Responsibilities:
- Enable basic mutual exclusion and atomic operations
- Integrate safely with Ori's ownership semantics
- Avoid implicit background threads or scheduling semantics

Non-goals:
- condition variables
- semaphores
- synchronized channels
- lock-free collections
- wait groups or thread pools

---

# 001.2.6 Package: net

The `net` package provides:
- minimal TCP client and server primitives
- owning connection values with deterministic destruction
- a minimal listener abstraction

Responsibilities:
- Allow simple blocking TCP networking
- Align with deterministic destruction (connections and listeners are owning values cleaned at scope exit)
- Keep semantics predictable and platform-neutral

Non-goals:
- non-blocking IO
- timeouts
- DNS APIs
- UDP
- TLS
- HTTP
- async networking

---

# 001.3 Integration With Ori Semantics

All packages must follow these rules:
- Explicit `Error` handling:
  - All functions that can fail must return the builtin Error type
  - No error wrapping, no exceptions
- Deterministic destruction:
  - Any resource tied to an OS handle (files, sockets, listeners, etc.) must be represented as an owning value with a destructor, ensuring cleanup on all control-flow paths.
- No reflection or formatting introspection:
  - In current version we avoid APIs that rely on runtime type inspection or formatting verbs. These are deferred until compile-time reflection phases and the `fmt` package are designed
- Explicit resource control:
  - No hidden allocations unless stated
  - No hidden goroutines or system threads
  - No implicit concurrency

---

# 001.4 Exclusions

The following features are intentionally excluded from the current version of the standard library, either due to complexity or because they depend on future compile-time or ownership semantics:
- fmt (formatting system)
- json and serialization
- buffered IO
- subprocess management
- filesystem metadata APIs
- cryptography
- HTTP or higher-level networking
- async tasks or event loop
- global configuration layers

---

# 001.5 Philosophy Summary

The Ori standard library is intentionally minimalistic:
- small enough to be easy to implement and evolve
- stable enough to support real-world usage
- explicit enough to maintain predictability
- constrained enough to prevent accidental design debt

This document defines foundations, not final APIs.  
Future versions will refine and expand these packages as the language gains additional capabilities (e.g., compile-time reflection, fmt system, more powerful generics).
