# 003. Error Handling Philosophy

Ori’s philosophy on error handling is simple and strict:  
**errors are part of normal program flow**, not exceptional control flow.

There are no exceptions, no hidden recovery, and no ignored results.  
If an operation can fail, the developer must make that failure **visible and intentional**.

> “If it can fail, it must be visible.”

---

## 1. Introduction

Ori’s error system is built around explicitness and compile-time enforcement.  
Unlike languages that rely on runtime exceptions or linter-based checks, Ori **integrates error handling directly into the language semantics**.

This approach eliminates ambiguity: every error must either be **handled** or **explicitly propagated**.  
Unhandled errors prevent compilation.

---

## 2. Design Principles

| Principle | Description |
|------------|--------------|
| **Explicit handling** | All errors must be checked or explicitly propagated using `try`. |
| **Compile-time enforcement** | Unhandled errors are detected at compile time, not at runtime. |
| **No hidden recovery** | No global handlers, no automatic retries, and no silent failure recovery. |
| **No string errors** | Errors are typed values, not arbitrary text. |
| **Clarity over convenience** | Predictable code is prioritized over brevity. |

---

## 3. Example: Explicit Propagation

### 3.1 Non-entry function (propagation allowed)

Propagation with `try` is valid **only** inside functions that *return `error`*.  
`try` re-throws the error to the caller and requires the current function to have an `error` in its result type.

```ori
func initConfig() error {
    try openFile("config.ori") // propagated upward
    fmt.Println("File loaded successfully")
    return nil
}
```

### 3.2 Entry point (`main`) (no propagation)

`main` **cannot** declare return values, so there is **nothing to propagate to**.  
At the program boundary, you must **handle** the error or **fail fast**.

```ori
func main() {
    var err error = initConfig()
    if err != nil {
        panic("could not load config: " + err.string())
    }
    fmt.Println("ok")
}
```

**Rule:** `try` cannot be used at the top level (`main`) because there is no caller to receive the error.
---


## 4. Explicit Handling

### 4.1 Entry point (`main`)

The entry function **cannot** declare return values. Handle errors explicitly at the boundary.

```ori
func main() {
    var err error = openFile("config.ori")
    if err != nil {
        panic("could not load: " + err.string())
    }
    fmt.Println("ok")
}
```

> Rationale: `main` is the top-level boundary. Either handle the error or fail fast with a clear panic.

### 4.2 Other functions

In non-entry functions, returning `error` is valid and encouraged; callers must handle or `try`-propagate it.

```ori
func run() error {
    var err error = openFile("config.ori")
    if err != nil {
        return err
    }
    fmt.Println("ok")
    return nil
}
```

Ori forces developers to **choose**: handle the error explicitly, or propagate it using `try`.  
Silence is never an option.

---

## 5. Built-ins Recap

| Built-in | Description | Example |
|-----------|--------------|----------|
| `error(msg)` | Creates a new error instance. | `return error("invalid config")` |
| `nil` | Represents “no error”. | `return nil` |
| `try` | Propagates the error upward automatically. | `try readFile()` |

---

## 6. Why No Exceptions

Ori deliberately rejects exception-based control flow for several reasons:

- Exceptions hide logical paths and break determinism.  
- They allow failure to occur in parts of code not visible in the call site.  
- They require runtime stack unwinding and hidden control flow.  
- They make static analysis less reliable.  

By contrast, Ori’s error model is **linear and visible** — you can read the code and immediately understand all possible outcomes.

---

## 7. Advantages of Ori’s Approach

| Advantage | Description |
|------------|--------------|
| **Compile-time safety** | The compiler enforces explicit error handling before execution. |
| **Predictable runtime** | No hidden stack unwinding or exception handling. |
| **Consistent code** | Every function clearly declares whether it can fail. |
| **Self-documenting APIs** | Function signatures naturally reflect error semantics. |
| **Easier testing** | Error cases are first-class and can be tested directly. |

---

## 8. Trade-offs and Inconveniences

While Ori’s model is safer and clearer, it introduces certain inconveniences that developers must consciously accept.

| Inconvenience | Description | Mitigation |
|---------------|--------------|-------------|
| **More verbose code** | Requires frequent `if err != nil` checks or `try`. | Minimal syntax and editor tooling reduce friction. |
| **Slower prototyping** | Early experiments require explicit error checks. | IDE templates and code generators streamline repetitive handling. |
| **Propagation discipline** | Functions must declare and respect error return types. | Promotes cleaner, self-documented APIs. |
| **No global fallback recovery** | Crashes cannot be caught globally like exceptions. | Encourages modular fault isolation and local error control. |
| **Nested flow verbosity** | Deep call chains may require multiple `try` or `if` blocks. | Future versions may add scoped error guards for ergonomics. |

> Ori accepts verbosity as the cost of **honesty** in error handling.

---

## 9. Comparison Summary

| Aspect | Exceptions (Go-like recover or Java) | Ori’s Explicit Model |
|--------|--------------------------------------|----------------------|
| Visibility | Hidden in control flow | Always visible |
| Recovery | Implicit or global | Local and explicit |
| Enforcement | Runtime | Compile-time |
| Safety | Unchecked | Guaranteed |
| Readability | Non-linear | Linear and predictable |

---

## 10. Summary

Ori’s error philosophy treats failure as a **normal condition**, not an exception.  
It enforces correctness at compile time and keeps runtime logic predictable.

By trading conciseness for reliability, Ori eliminates an entire class of runtime bugs caused by ignored or hidden errors.

> “If it can fail, it must be visible.”

Explicitness, determinism, and compile-time validation — that is Ori’s foundation for trustworthy error handling.
