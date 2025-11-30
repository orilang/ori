# 180. Runtime and Panic Handling

Ori’s runtime is designed to be **deterministic**, **minimal**, and **safe**.  
It avoids hidden recovery mechanisms and ensures predictable program termination on fatal errors.

---

## 180.1 Overview

Ori distinguishes between two classes of runtime failure:

| Type | Description | Recoverable |
|------|--------------|--------------|
| **error** | Expected failure handled by developers using `try` or explicit returns. | ✅ Yes |
| **panic** | Unrecoverable, fatal runtime failure (e.g., index out of bounds, division by zero). | ❌ No |

Errors are part of normal program flow.  
Panics represent critical conditions that should **terminate execution immediately**.

---

## 180.2 Error vs Panic

| Concept | Description | Example |
|----------|--------------|----------|
| `error` | Represents an expected failure. | `try openFile("data.txt")` |
| `panic` | Represents an unexpected or unrecoverable condition. | `panic("index out of range")` |

Example:
```ori
func readConfig(path string) string {
    if !exists(path) {
        panic("configuration file missing")
    }
    return readFile(path)
}
```

---

## 180.3 Panic Behavior

When a panic occurs:
1. The current function stops executing immediately.  
2. Stack unwinding begins — deferred cleanup functions may run (planned support).  
3. The runtime prints:
   - The panic message
   - A precise stack trace (function, file path, line)
   - The exit code
4. The program terminates with a non-zero exit status.

### Example
```ori
func divide(a int, b int) int {
    if b == 0 {
        panic("division by zero")
    }
    return a / b
}
```

**Runtime output:**
```
panic: division by zero

at math.divide (/project/src/math.ori:10)
at main.main (/project/src/main.ori:4)

exit code 1
```

---

## 180.4 Recovering from Panics

Panics are **fatal and non-recoverable**.  
Future versions may introduce **controlled recovery scopes** for testing or advanced runtime management.

---

## 180.5 Built-in Panic Functions

Ori provides a minimal set of built-in functions for runtime validation and development workflow support.

| Function | Description | Example |
|-----------|--------------|----------|
| `panic(msg string)` | Triggers immediate program termination with message and stack trace. | `panic("invalid state")` |
| `assert(cond bool, msg string)` | Panics if `cond` is false; used to enforce invariants. | `assert(len(users) > 0, "empty user list")` |
| `todo()` | Marks code as intentionally unimplemented and panics at runtime. | `todo()` |

### Built-in Function Philosophy

Unlike some other languages, Ori includes `assert` and `todo` as first-class built-ins.  
They simplify common patterns and encourage **clear, intentional development behavior**.

---

### Example 1: Using `assert`
```ori
func divide(a int, b int) int {
    assert(b != 0, "division by zero")
    return a / b
}
```

**If `b == 0`:**
```
panic: assertion failed: division by zero
at main.divide (/src/main.ori:3)
at main.main (/src/main.ori:10)

exit code 1
```

---

### Example 2: Using `todo`
```ori
func connectDatabase() {
    todo() // TODO: implement database connection
}
```

**Runtime output:**
```
panic: TODO at /src/db.ori:5
at main.connectDatabase (/src/db.ori:5)
at main.main (/src/main.ori:12)

exit code 1
```

These built-ins provide standardized panic messages with consistent formatting, including **file paths** and **line numbers** for direct debugging.

---

## 180.6 Interaction with Errors

`error` values propagate via explicit `return` or `try`.  
`panic` bypasses normal control flow and terminates execution.  

**Design guideline:**
- Use `error` for *expected* conditions (file not found, invalid input).  
- Use `panic` for *unexpected* internal failures or violated invariants.

Example:
```ori
func openFile(path string) error {
    if !exists(path) {
        return error("file not found")
    }
    if !hasPermission(path) {
        panic("security violation: access denied")
    }
    return nil
}
```

---

## 180.7 Runtime Guarantees

Ori’s runtime provides strict guarantees to maintain deterministic execution:

| Guarantee | Description |
|------------|--------------|
| Deterministic panics | Panic messages and traces are consistent across executions. |
| File path + line info | Every panic reports its exact origin. |
| No implicit recovery | Panics always terminate unless a recovery (planned) scope is explicitly defined. |
| Stack trace visibility | Always printed before termination. |
| RAII-like cleanup (planned) | Resource Acquisition Is Initialization cleanup like defer will be introduced is planned. |

---

## 180.8 Summary

| Feature | Description |
|----------|--------------|
| `panic` | Triggers immediate program termination. |
| `assert` | Checks invariants; panics on failure. |
| `todo` | Marks unimplemented code with standardized panic message. |
| `error` | Represents recoverable conditions in normal flow. |
| **No recovery yet** | Planned. |
| **Stack trace with file paths** | Always displayed for deterministic debugging. |
| **Exit code** | Non-zero exit on panic termination. |

---

Ori’s runtime model prioritizes **clarity, determinism, and developer control**, providing meaningful diagnostics and avoiding hidden behaviors.
