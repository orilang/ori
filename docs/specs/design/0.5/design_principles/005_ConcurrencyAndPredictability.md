# 005. Concurrency and Predictability

Ori’s concurrency model is **explicit, deterministic, and runtime-free**.  
There is no hidden scheduler, no automatic goroutines, and no background threads.  
If your program runs tasks concurrently, that fact is **visible in code**.

> “If it runs concurrently, you should see it.”

---

## 1. Introduction

Ori supports concurrency as a **deliberate tool**, not a side effect.  
Developers explicitly create tasks, explicitly synchronize, and explicitly communicate.  
There is no implicit parallelism or runtime-managed scheduling.

---

## 2. Design Philosophy

| Principle | Description |
|-----------|-------------|
| **Explicit concurrency** | Tasks are created with a clear construct (`spawn`) and waited with `wait()`. |
| **No runtime scheduler** | Ori provides primitives; it does not run hidden schedulers or pools. |
| **Predictable behavior** | Execution order, synchronization, and lifetime are visible in code. |
| **Typed communication** | Channels (when used) are typed; capacity rules are explicit and documented. |
| **Safe synchronization** | All shared mutable state requires explicit synchronization. |

---

## 3. Explicit Task Spawning

Ori uses **explicit task creation** — no implicit goroutines or “async magic”.

```ori
func worker(id int) {
    fmt.Println("worker", id, "started")
    // ... do work ...
    fmt.Println("worker", id, "done")
}

func main() {
    task := spawn worker(1)
    task.wait() // explicit synchronization
}
```

- `spawn` starts a concurrent task.
- `wait()` blocks until the task completes.
- There is **no hidden scheduling** or background runtime: what you write is what runs.

---

## 4. Communication and Synchronization

Ori encourages clear, typed communication and explicit synchronization.  
Channel capacity semantics are **intentionally conservative for v0.5** (see note below).

```ori
// Typed channel example (capacity semantics TBD in v0.5)
var ch chan int = make(chan int, 2)

spawn func() {
    ch <- 42
}()

var value int = <-ch
fmt.Println("received:", value)
```

**Channel design (v0.5 stance):**
- Channels must declare a **concrete element type** (e.g., `chan int`).
- Capacity may be **specified or omitted**; detailed behavior (blocking, backpressure, errors) will be finalized in a future version.
- Ori will keep send/receive semantics **explicit** — no hidden runtime behavior.

> *Future: bounded vs unbounded semantics will be evaluated for predictability, backpressure, and memory safety before being finalized.*

---

## 5. Shared Data Rules

Shared mutable state must be protected by explicit synchronization.  
Ori forbids unsynchronized concurrent mutation.

```ori
func safeIncrement(counter *int) {
    var mu Mutex // scoped synchronization primitive
    mu.lock()
    counter += 1
    mu.unlock()
}
```

> In Ori, synchronization primitives (like `Mutex`) are **scoped or passed**, not global.  
> Global mutable state is not allowed.

After stating “avoiding race conditions at the language level,” Ori defines:

> **Race condition** — a situation where two or more concurrent tasks access shared data at the same time and at least one modifies it, causing **non-deterministic** outcomes.  
> Ori prevents this by requiring **explicit synchronization** for any shared mutable state.

---

## 6. Determinism and Task Lifetime

Ori’s model ensures task lifetime is **explicit and deterministic**:

- A task only exists if code explicitly `spawn`s it.
- A task finishes when work ends, and code **explicitly** `wait()`s for it.
- No hidden task pools or schedulers are active in the background.

This makes Ori suitable for **real-time**, **embedded**, and **predictable parallel** workloads.

---

## 7. Structured Concurrency (Future Direction)

Ori plans to introduce **structured concurrency**:

> All spawned tasks are **bound to a lexical scope**. When the scope ends, **all child tasks must complete or be cancelled deterministically**.

Conceptual sketch (illustrative, not final syntax):

```ori
scope s {
    t1 := s.spawn worker(1)
    t2 := s.spawn worker(2)
    s.waitAll() // scope cannot exit until tasks are resolved
}
```

Structured concurrency prevents “fire-and-forget” leaks and makes cancellation and cleanup deterministic.

---

## 8. Safer Message Passing (Future Direction)

Ori may introduce **ownership-aware channels** to ensure values sent between tasks are **safely transferred** (no aliasing surprises, clear ownership after send).

Goals:
- Typed, explicit ownership transfer semantics.
- Compile-time checks where possible.
- Predictable backpressure behavior (bounded queues, blocking modes, or explicit failure).

---

## 9. Trade-offs

| Limitation | Description | Rationale |
|-----------|-------------|-----------|
| **No automatic concurrency** | Developers must `spawn` and `wait()` explicitly. | Avoids unpredictability and hidden costs. |
| **More boilerplate** | Synchronization and communication are explicit. | Prioritizes clarity over brevity. |
| **Manual synchronization** | Developers must choose locks/channels carefully. | Guarantees visible concurrency behavior. |

> Ori trades convenience for **deterministic, analyzable** concurrency.

---

## 10. Summary

Ori’s concurrency is **explicit, predictable, and runtime-free**:

- `spawn` starts work; `wait()` finishes it.  
- Communication is typed; channel capacity semantics are **deliberately deferred** for a careful design.  
- Shared mutable state requires explicit synchronization.  
- Future: **structured concurrency** and **ownership-aware channels**.

> “Concurrency is a tool — not a background process.”
