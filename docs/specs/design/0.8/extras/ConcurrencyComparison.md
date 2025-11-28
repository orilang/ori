# ConcurrencyComparison.md — Go vs Zig vs Rust vs Ori (v0.5)

## 📘 Version Baselines Used

| Language | Version Range Used | Notes |
|----------|----------------------|--------|
| **Go** | **1.21 → 1.22** | Mature goroutine model, preemptive scheduling, string-based errors |
| **Zig** | **0.11 → 0.12 design** | No built‑in concurrency; explicit OS threads; manual sync |
| **Rust** | **1.70 → 1.75** | Ownership system, Send/Sync, threads + async executors |
| **Ori (v0.5)** | **Draft spec** | Cooperative tasks, channels, select, explicit shared memory |

---

## Summary: Ori vs Go, Zig, and Rust

| Category | **Go** | **Zig** | **Rust** | **Ori (v0.5 design)** |
| --- | --- | --- | --- | --- |
| **Concurrency Model** | Green threads (goroutines, runtime scheduler) | OS threads (manual concurrency) | OS threads + async executors (library-based) | Task scheduler (cooperative green tasks) + system tasks (explicit opt-in) |
| **Communication** | Channels (built-in) + optional shared memory | Shared memory, atomics, manual channels | Channels in stdlib, message-passing via ownership | **Channels by default**; shared memory must be explicit (`shared`, `atomic`) |
| **Safety** | Runtime race detector, not enforced by type system | No GC, full control but no static safety | Full static safety via ownership/borrowing + `Send`/`Sync` traits | **Statically race-free by default** (no shared mutable access unless marked `shared`) |
| **Error Handling** | Dynamic `error` values (string-like, manual checks) | Typed `!T` errors, explicit `try` / `catch` | `Result<T, E>` + `?` propagation | Explicit `error` struct, typed and returned via `wait()` or channel |
| **Preemption / Scheduling** | Preemptive (runtime-managed) | OS preemption | OS preemption | **Cooperative scheduling**, yield points at `send`, `recv`, `wait`, `yield()` |
| **Performance predictability** | Non-deterministic due to preemption | Fully deterministic (OS-level) | Deterministic under user control | **Deterministic** (cooperative) with runtime-tunable granularity |
| **Blocking behavior** | Implicit blocking, mitigated by `select` | Manual blocking, user decides | Manual, depends on executor | **Explicit blocking via `select`**, predictable and controlled |
| **Deadlock handling** | Possible; avoided with `select` | Programmer’s responsibility | Library-dependent | **Built-in `select` keyword** for reactive control flow |
| **Ease of use** | Easiest (simple syntax) | Verbose but explicit | Verbose, steep learning curve | **Go-level simplicity**, Rust-level safety, Zig-level control |
| **FFI / System Integration** | Simple, strong runtime coupling | Direct, no runtime | Direct, safe wrappers | **Both modes:** system tasks can integrate with OS/FFI safely |
| **Memory model** | GC + race detector | Manual | Ownership + lifetimes | **Ownership + view semantics + channel sync** (no GC, no lifetimes syntax) |
| **Philosophy** | “Do not communicate by sharing memory.” | “Give control back to the programmer.” | “Guarantee memory safety at compile time.” | **“You can’t data-race in Ori unless you ask for it.”** |

---

# 1. Safety & Race Prevention

### ✅ Ori’s Strength:
- **Go** detects races *after the fact* (runtime).
- **Zig** gives full control but no static safety.
- **Rust** enforces safety via complex generics and lifetimes.
- **Ori** reaches **Rust-level race prevention** *without heavy syntax*:
  - No mutable capture across `spawn`.
  - `shared` required for any cross-task mutability.
  - Channels and task joins define synchronization points.

💬 **Rating:**

| Language | Safety Level | Mechanism |
| --- | --- | --- |
| Go | ★☆☆☆☆ | Runtime detector |
| Zig | ★★☆☆☆ | Manual control |
| Rust | ★★★★★ | Type system (Send/Sync) |
| **Ori** | **★★★★☆** | Compiler rules + channel ownership |

Ori loses only half a star vs Rust because it’s more permissive for FFI and system tasks.

---

# 2. Simplicity & Developer Ergonomics

### ✅ Ori’s Strength:
- Syntax is Go-level simple.
- No `await`, `Result`, `Try`, `Sync` trait complexity.
- Deterministic concurrency feels natural: `spawn`, `wait`, `chan`, `select`.

💬 **Rating:**

| Language | Ergonomics | Developer Load |
| --- | --- | --- |
| Go | ★★★★★ | Intuitive, but unsafe |
| Zig | ★★☆☆☆ | Verbose, explicit threading |
| Rust | ★★☆☆☆ | Heavy syntax, async complexity |
| **Ori** | **★★★★☆** | Simple, explicit, deterministic |

---

# 3. Performance & Predictability

### ✅ Ori’s Strength:
- Cooperative tasks = zero preemption overhead.
- Channels and atomics can be lock-free.
- Runtime is optional: system tasks map directly to OS threads.

⚠️ **Trade-off:**
- Cooperative scheduling can cause stalls if tasks never yield.
- Needs yield enforcement or runtime checks.

💬 **Rating:**

| Language | Model | Predictability |
| --- | --- | --- |
| Go | Green threads, preemptive | Medium (runtime overhead, GC) |
| Zig | OS threads | High (manual) |
| Rust | OS threads | High (user controlled) |
| **Ori** | **Hybrid (green + system)** | **High** (deterministic, configurable) |

---

# 4. Expressiveness & Control

### ✅ Ori’s Strength:
- `select` gives event-driven flexibility (like Go’s).
- Optional `shared` unlocks low-level control.
- Atomic ops available for performance-critical cases.
- No hidden magic (unlike Go’s scheduler).

💬 **Rating:**

| Language | Expressiveness | Comments |
| --- | --- | --- |
| Go | ★★★★☆ | Channels + select, but unsafe |
| Zig | ★★★☆☆ | Raw control, verbose |
| Rust | ★★★☆☆ | Rich, but buried in abstractions |
| **Ori** | **★★★★☆** | Balanced: message-driven + low-level access optional |

---

# 5. Error Handling in Concurrency

### ✅ Ori’s Strength:
- Errors integrate directly into task or channel results.
- No hidden panics, no `try` boilerplate.
- Compatible with structured error propagation later.

💬 **Rating:**

| Language | Approach | Clarity |
| --- | --- | --- |
| Go | manual `if err != nil` | ★★☆☆☆ |
| Zig | `!T` + `try` / `catch` | ★★★☆☆ |
| Rust | `Result<T, E>` + `?` | ★★★★☆ |
| **Ori** | `error` struct + typed return | **★★★★☆** |

---

# 6. Conceptual Clarity

### ✅ Ori’s Strength:
Unified concurrency story:
- One primitive (`spawn`)
- One communication medium (`chan`)
- One synchronization mechanism (`Wait` / `select`)
- Optional explicit shared state (`shared`, `atomic`)

No duality of “async/await vs threads”.

💬 **Rating:**

| Language | Clarity | Comments |
| --- | --- | --- |
| Go | ★★★☆☆ | Mix of channels and unsafe sharing |
| Zig | ★★★★☆ | Explicit, minimal |
| Rust | ★★★☆☆ | Complex rules and traits |
| **Ori** | **★★★★★** | Clean, single-concept design |

---

# 7. Overall Summary

| Metric | Go | Zig | Rust | **Ori (v0.5)** |
| --- | --- | --- | --- | --- |
| **Safety** | 2/5 | 3/5 | 5/5 | **4.5/5** |
| **Simplicity** | 5/5 | 2/5 | 2/5 | **4.5/5** |
| **Performance** | 3/5 | 5/5 | 5/5 | **4.5/5** |
| **Expressiveness** | 4/5 | 3/5 | 4/5 | **4.5/5** |
| **Clarity** | 3/5 | 4/5 | 3/5 | **5/5** |
| **Average** | **3.4 / 5** | **3.4 / 5** | **3.8 / 5** | **🔹 4.6 / 5** |

