# 250. Compiletime

# Compile-Time Execution (CTE)

## 250.1. Overview

Compile-Time Execution (CTE) allows certain user-defined functions and expressions to be executed during compilation using the `comptime` keyword.  
Ori does **not** implicitly execute user functions at compile time.  
All compile-time evaluation must be explicit.

CTE exists to enable:
- constant computations from user code
- generic constraints validation
- type-based constant derivations
- compile-time errors and diagnostics

Ori keeps CTE **explicit, predictable, and safe**, avoiding implicit purity inference.

---

## 250.1.1 Why CTE Is Not Automatic

Ori does **not** automatically evaluate user functions at compile time because:
- **It is dangerous** — accidental expensive or infinite computations could freeze compilation
- **The compiler would need to guess purity** — requiring complex effect systems or whole-program purity inference
- **It may introduce silent behavior** — where some functions get folded at compile time and others don’t, based on unclear heuristics
- **Ori avoids implicit magic** — consistent with no implicit casting, no implicit borrowing, no implicit allocations, no implicit fallthrough

Therefore, CTE is always **explicit** through `comptime`.

---

## 250.2. `comptime` Keyword

### 250.2.1 Compile-Time Function Declaration

```
comptime func fib(n int) int {
    if n < 2 {
        return n
    }

    var a = 0
    var b = 1

    for i = 2; i < n; i = i + 1 {
        var tmp = a + b
        a = b
        b = tmp
    }

    return b
}
```

A `comptime func`:
- must be pure
- must terminate
- cannot perform I/O or heap allocation
- cannot use runtime-only values or types
- cannot access references, views, or runtime slices/maps
- **can only call other `comptime func` functions**

---

### 250.2.2 `comptime` Expression

```
const F = comptime fib(10)
```

This forces compile-time evaluation of any function, even if the function is not declared `comptime func`.  
The compiler verifies the function’s call graph complies with CTE restrictions.

---

## 250.3. Compile-Time Errors

### 250.3.1 `comptime_error("message")`

Aborts compilation with a custom error message.

Example:
```
comptime func ensureNumeric[T]() {
    if !isNumeric[T]() {
        comptime_error("T must be numeric")
    }
}

func add[T](a T, b T) T {
    comptime ensureNumeric[T]()
    return a + b
}
```

If `T` is not numeric, compilation errors with:
```
T must be numeric
```

---

## 250.4. Allowed Operations in CTE

### 250.4.1 Allowed

- arithmetic
- comparisons
- pure branching (`if` and `for` using only comptime values)
- calling other comptime functions
- local variable declarations (`var`)
- creating local fixed-size arrays
- constant folding
- evaluating generic constraints

---

### 250.4.2 Calling Non‑CTE Functions

- **Inside a `comptime func`**: *forbidden* — may only call other `comptime func` functions
- **Inside `comptime(expr)`**: allowed *only if* the function body is pure and CTE‑safe

---

## 250.5. Forbidden Operations in CTE

CTE must never depend on runtime or non-deterministic behavior.

### 250.5.1 Runtime-Dependent Operations

- I/O (files, network, system calls)
- OS-specific APIs
- randomness
- time-based operations

---

### 250.5.2 Memory and Execution

- heap allocation or deallocation
- pointers, references, views, shared
- slicing runtime buffers
- dynamic allocation of containers (maps, hashmaps, slices)

---

### 250.5.3 Concurrency

- `spawn_task`
- `spawn_thread`
- `Wait()`
- any task/thread operations

---

### 250.5.4 Global State

- reading or modifying global mutable state (Ori forbids mutable globals entirely)

---

## 250.6. Interaction With Generics

### 250.6.1 Checking Constraints

```
comptime func ensurePositive(n int) {
    if n <= 0 {
        comptime_error("expected positive value")
    }
}

const Size = comptime ensurePositive(32)
```

---

### 250.6.2 Using CTE Inside Generic Functions

```
func makeArray[T](n int) [comptime(n)]T {
    ...
}
```

---

## 250.7. Interaction With Interfaces

Dynamic dispatch is forbidden in CTE.

Allowed:
- checking if a type implements an interface (compile-time only)
- using interface type metadata

Forbidden:
- calling interface methods
- creating or manipulating interface runtime values

### Example — interface implementation check

```
T implements Writer
if !T {
    comptime_error("T must implement Writer")
}
```

This syntax aligns with previously defined Ori interface semantics.

---

## 250.8. Examples

### 250.8.1 Compile-Time Fibonacci
```
comptime func fib(n int) int {
    if n < 2 { return n }

    var a = 0
    var b = 1

    for i = 2; i < n; i = i + 1 {
        var tmp = a + b
        a = b
        b = tmp
    }

    return b
}

const RESULT = comptime fib(10)
```

---

### 250.8.2 Compile-Time Table Size Validation

```
comptime func checkSize(n int) {
    if n > 1024 {
        comptime_error("size too large")
    }
}

const N = comptime checkSize(1500) // compile-time error
```

---

## 250.10. Summary
Ori’s CTE system is:
- explicit (`comptime`)
- safe
- pure
- deterministic
- simple to reason about
- integrated with generics and type system

This makes Ori powerful without introducing the complexity or magic of macro systems.
