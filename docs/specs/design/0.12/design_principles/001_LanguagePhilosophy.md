# 001. Language Philosophy

Ori is a **system-capable general-purpose programming language** built on three essential promises:  
**clarity**, **determinism**, and **explicit control**.  

It is designed for developers who want predictable execution and full visibility into what their code does — with no hidden runtime behavior or implicit transformations.

---

## 1. Introduction

Ori’s mission is to offer a programming environment where **safety and simplicity coexist**.  
It draws lessons from Go’s readability, Zig’s explicitness, and Rust’s safety, while avoiding their respective pitfalls — complexity, verbosity, or hidden runtime behavior.

Ori code should be **clear to read, safe to execute, and deterministic to reason about**.

---

## 2. Core Principles

| Principle | Description |
|------------|--------------|
| **Explicitness** | Every behavior must be visible in code — no implicit conversions, imports, or hidden initialization. |
| **Determinism** | The same inputs always produce the same results, regardless of context. |
| **Safety** | Prevent undefined behavior by design while keeping control in the developer’s hands. |
| **Simplicity** | A small, orthogonal set of features that compose naturally. |
| **Predictability** | No hidden concurrency, no automatic reallocation, no silent failures. |
| **Readability** | Code should express intent clearly, not trick the reader into guessing. |

Ori’s design rejects “magic” abstractions — developers always see the cost and consequences of their code.

---

## 3. Philosophy Compared to Other Languages

From **Go**, Ori inherits simplicity and readability, but not the runtime or unchecked errors.  
From **Zig**, it takes explicit memory control and compile-time clarity.  
From **Rust**, it borrows safety principles, but avoids the heavy syntax and implicit lifetimes.  

Ori’s guiding phrase:

> “You should always know what your code does — and why.”

---

## 4. Design Intent

No garbage collector — memory safety through structure and ownership discipline.  
No global mutable state — promote modular and testable design.  
No implicit initialization or hidden imports.  
**No runtime magic** — Ori has no background runtime or hidden services. Execution is fully under developer control.  
**Mandatory error handling** — Ori enforces explicit handling of returned errors at compile time.  
  If a function returns an `error`, it must be checked or explicitly propagated (e.g., with `try`).  
  Unhandled errors are a **compile-time violation**, not a linter warning.  
  This guarantees that failure cases are never silently ignored.  
Encourage clear error handling over silent exceptions.  

Ori’s compilation rules ensure that every critical behavior — imports, memory, errors — is **known, visible, and validated** before execution.

---

## 5. Developer Experience

Ori emphasizes an experience where **correctness and clarity come first**:

- Fail early, fail clearly — `assert`, `error`, and `panic` are explicit tools.  
- Zero-surprise refactoring — what you read is what executes.  
- Predictable compilation model — no hidden runtime linking or background scheduling.  
- Clear diagnostics — compiler errors are precise and actionable.  

---

## 6. Summary

Ori builds trust through explicitness:

- Trust the **developer** to write safe, visible code.  
- Trust the **compiler** to enforce clarity and correctness.  
- Trust the **runtime** (or lack thereof) to behave deterministically.  

**Ori is a language for those who value control, transparency, and precision over convenience-driven ambiguity.**
