# 250. Compile-Time Execution (CTE)

## 250.1 Overview

Compile-Time Execution (CTE) allows certain user-defined constants and functions to be evaluated
during compilation using the `comptime` keyword.

Ori does not implicitly run any user code at compile time.
All compile-time evaluation is explicit, predictable, and safe.

CTE supports:
- compile-time constants
- compile-time-only functions
- generic parameters that must be compile-time values
- compile-time constraints
- compile-time errors

Ori intentionally excludes:
- implicit compile-time evaluation
- implicit purity detection
- automatic folding of arbitrary user functions

---

## 250.2 Allowed CTE Forms

Ori supports exactly two syntactic uses of `comptime`:

### 250.2.1 Compile-time constant declaration

```ori
comptime const NAME = expr
```

Examples:
```ori
comptime const FIB10 = fib(10)
comptime const SIZE = 32 + 8
```

`expr` must be fully CTE-safe.

### 250.2.2 Compile-time-only function declaration

```ori
comptime func fib(n int) int {
    ...
}
```

A `comptime func`:
- is executed only during compilation
- must be pure
- must terminate
- cannot depend on runtime inputs
- cannot be called from runtime code
- can only call other `comptime func` functions

---

## 250.3 Forbidden Forms of CTE

Ori forbids all expressions or modifiers outside the two approved forms.

Invalid:
```ori
const X = comptime expr
var X = comptime expr
comptime expr
comptime { ... }
func f[T](comptime N int)  // forbidden any expression-level usage of comptime
```

This prevents comptime from leaking into general expressions and keeps the grammar simple.

---

## 250.4 Compile-Time Errors

Compile-time functions may issue errors using:
```ori
comptime_error("message")
```
Example:
```ori
comptime func ensurePositive(n int) {
    if n <= 0 {
        comptime_error("expected positive value")
    }
}
```

If invoked during CTE, this aborts compilation.

---

## 250.5 Allowed Operations in CTE

### 250.5.1 Allowed

- arithmetic
- comparisons
- pure branching (if, for) using only compile-time values
- calling other comptime functions
- local variable declarations
- creating local fixed-size arrays
- compile-time constant folding
- evaluating generic compile-time constraints

---

### 250.5.2 Forbidden Operations

CTE must not depend on runtime or non-deterministic behavior.

Forbidden:
- I/O of any kind
- OS APIs
- randomness, timestamps
- concurrency (tasks, threads, Wait)
- heap allocation or deallocation
- pointers or references
- views and slices
- maps and hashmaps
- accessing or modifying runtime globals
- calling non-CTE functions

---

## 250.6 Generic Functions and Compile-Time Parameters

Ori allows compile-time generic parameters using `const`:
```ori
func makeArray[T](const N int) [N]T {
    var arr [N]T
    return arr
}
```

Rules:
- N must be known at compile time.
- Passing a non-CTE value to N is a compile-time error.
- N behaves as a normal int inside the function but is treated as a constant type parameter.

---

## 250.7 Compile-Time Constraints With Generics

A compile-time function may validate generic parameters:
```ori
comptime func ensureEven(n int) {
    if n % 2 != 0 {
        comptime_error("expected an even size")
    }
}

comptime const VALID = ensureEven(4)
```
Or inside a function with a constant parameter:
```ori
func bufferOf[T](const N int) [N]T {
    comptime ensureEven(N)
    return [N]T{}
}
```

---

## 250.8 Examples

### 250.8.1 Compile-Time Fibonacci

```ori
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

comptime const RESULT = fib(10)
```

---

### 250.8.2 Compile-Time Array Size Validation

```ori
comptime func checkLimit(n int) {
    if n > 1024 {
        comptime_error("size too large")
    }
}

func allocChunk[T](const N int) [N]T {
    comptime checkLimit(N)
    return [N]T{}
}
```

---

## 250.9 Summary

Ori’s CTE system:
- uses only two comptime forms (constant + function)
- forbids expression-level comptime
- makes generic constant parameters explicit via `const`
- is pure, deterministic, and easy to reason about
