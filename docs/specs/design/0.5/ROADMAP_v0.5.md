# 🧭 Ori v0.5 — Focused Roadmap

## Scope
1. 🧵 Concurrency & Scheduling
2. 🧠 Memory & Lifetime Model
3. ⚙️ Error Model Integration

---

## 🧩 1. Concurrency & Scheduling
**Goal:** Introduce Ori’s task-based concurrency system — lightweight, explicit, and deterministic.

**Key design items:**
- `spawn` keyword to start concurrent tasks:
  ```ori
  spawn worker()
  ```
- Task completion handled via `wait`, not `join` or `await` — keeping syntax short and intuitive:
  ```ori
  task := spawn worker()
  task.wait()
  ```
- Optional message-passing (channel-style or shared-state synchronization rules).
- Scheduler model (cooperative or preemptive) — define execution semantics clearly.
- Safety rules for memory visibility and task isolation.

**Comparative design:**
- ✅ Simpler and more predictable than Go’s implicit goroutines.
- ✅ Avoids Rust’s complexity with `Send`/`Sync` traits.
- 🧩 Clear deterministic semantics — each task has a controlled lifecycle.

📄 *Deliverable:* `080_Concurrency.md`

---

## 🧩 2. Memory & Lifetime Model
**Goal:** Define predictable ownership and lifetime behavior for values and references — the foundation for safe concurrency.

**Key design items:**
- Clarify **value vs reference** semantics across all types.
- Define the **`view` qualifier** precisely for non-owning access (e.g., slices, strings, structs).
- Specify lifetime and aliasing rules to prevent unsafe access after scope end.
- Ensure safe memory behavior without garbage collection.
- Include guidance for escape analysis and stack/heap boundaries.

**Comparative design:**
- ✅ Predictable like Go (no hidden memory overhead).
- ✅ Safe like Rust (no dangling references).
- 🚫 No hidden move/borrow machinery — ownership rules remain transparent to users.

📄 *Deliverable:* Update to `050_Types.md`

---

## 🧩 3. Error Model Integration
**Goal:** Extend Ori’s error model to work seamlessly with concurrent execution while preserving explicitness.

**Key design items:**
- Define how `spawn`ed tasks return or report errors:
  ```ori
  task := spawn worker()
  if err := task.wait(); err != nil {
      // handle error
  }
  ```
- All errors remain **explicitly handled** — no silent propagation.
- Errors integrate naturally with the concurrency model.
- Introduce a **base error struct** for consistent error representation and extension.
- Keep design open for structured errors later (without introducing generics yet).

**Comparative design:**
- ✅ Cleaner than Go’s `if err != nil` verbosity.
- ✅ Less boilerplate than Rust’s pattern-heavy `Result` handling.
- 🚫 No hidden or implicit propagation.

📄 *Deliverable:* Update to `Errors.md`

---

## 🧱 Expected Outcome
> Ori v0.5 establishes the foundation of safe concurrency and lifetime management — with clear, explicit error semantics and predictable memory behavior — readying the language for runtime and FFI expansion in v0.6.
