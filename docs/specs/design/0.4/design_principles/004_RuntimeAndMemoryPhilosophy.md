# 004. Runtime and Memory Philosophy

Ori’s execution model is **deterministic, transparent, and runtime-free**.  
There is no garbage collector, no background scheduler, and no hidden runtime.  
Memory management is explicit, predictable, and visible in code.

> “Ori runs exactly what you wrote — nothing more, nothing less.”

---

## 1. Introduction

Ori favors **developer control** over automation.  
Unlike Go, which uses a garbage collector and background runtime, Ori requires the developer to manage resources directly.  
Like C++, it emphasizes **explicit lifetime and deterministic destruction** for performance and reliability.

---

## 2. Core Principles

| Principle | Description |
|------------|--------------|
| **No hidden runtime** | Ori compiles to standalone binaries without a background runtime or GC. |
| **Deterministic memory model** | Allocation, ownership, and deallocation are explicit and predictable. |
| **No garbage collector** | Memory is freed explicitly or via structured scope cleanup. |
| **No implicit reference counting** | There is no hidden retain/release or automatic lifetime tracking. |
| **Predictable performance** | No runtime pauses, allocations, or unpredictable overhead. |

---

## 3. Developer-Controlled Lifetime

Memory ownership is always explicit in Ori.  
A value’s lifetime is controlled by the scope in which it is created, and its release must be deliberate.

```ori
var user User = User{name: "Alice"}
var users []User = make([]User, 10)
free(users) // explicit release when done
```

> In Ori, resource lifetime is predictable because it’s visible in code.

---

## 4. Why No Garbage Collector

Garbage collectors simplify programming but remove control.  
They introduce runtime pauses, unpredictable cleanup timing, and hidden memory costs.

Ori, like C++, prioritizes **predictable control and deterministic destruction**.  
By making cleanup explicit, developers know exactly when resources are freed, improving performance and reliability in embedded and system-level programs.

> Go’s GC offers convenience. Ori offers certainty.

---

## 5. Runtime Guarantees

Ori provides **no hidden runtime behavior**:  
- No background threads or event loops.  
- No runtime memory manager.  
- No automatic stack resizing or allocation.  
- No leaks caused by invisible references.

Compiled binaries contain only what developers write and import — nothing else.

---

## 6. Explicit Resource Management

Ori adopts **RAII-like scope guards**, inspired by **C++ and Go**, to ensure deterministic cleanup without a garbage collector.

```ori
func useFile() {
    f := open("data.txt")
    defer f.close() // cleanup always triggered on exit
}
```

Scope guards combine the **determinism of C++’s RAII** with the **simplicity of Go’s `defer`**,  
providing predictable cleanup that requires no runtime or GC.

---

## 7. Safety vs Control

Ori enforces a strict but flexible safety model:

- **Safe defaults** — no use-after-free or dangling references (enforced by design).  
- **Explicit unsafe blocks** — allowed only in advanced use cases like FFI (future feature).  
- **Manual memory management** — developers control allocation (`alloc`, `free`, `copy`).  

This balance lets developers choose between control and safety explicitly.

---

## 8. Trade-offs

| Limitation | Description | Rationale |
|-------------|--------------|------------|
| **Manual cleanup** | Developers must release memory/resources explicitly. | Full control and visibility. |
| **Steeper learning curve** | Requires understanding ownership and lifetime. | Prevents hidden performance bugs. |
| **No automatic safety net** | Unsafe by neglect, safe by discipline. | Predictability and performance. |

> Ori favors correctness through control rather than safety through automation.

---

## 9. Future Directions

- Optional static ownership verification (borrow-check-like analysis).  
- Scoped heap allocations.  
- Reference and view types with compile-time lifetime validation.  

---

## 10. Summary

Ori’s runtime and memory philosophy:

- No hidden runtime.  
- No garbage collector.  
- No implicit threads or allocations.  
- Complete developer control over lifetime and performance.

> “You own what you allocate — and you see what you free.”
