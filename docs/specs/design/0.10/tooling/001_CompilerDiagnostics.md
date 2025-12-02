# 001. CompilerDiagnostics

## 001.1 Ori Compiler Diagnostics Specification

This document specifies the structure, behavior, and formatting rules for all compiler diagnostics in Ori.  
Diagnostics must be deterministic, explicit, and consistent across all tools.

---

## 001.2. Error Codes

All diagnostics use the following format:

```
ORIxxxx
```

- `ORI` is the fixed prefix for Ori diagnostics.
- `xxxx` is a four-digit numeric code.
- Leading zeroes are mandatory.
- Codes are grouped by functional domain (see below).

## 001.2.1 Error Code Ranges

**1000–1999 : Parsing & Lexing**

- unexpected token
- invalid literal
- malformed expression
- unterminated string/comment

**2000–2999 : Type System**

- type mismatch
- invalid assignment
- missing method
- incorrect interface implementation
- generics instantiation errors

**3000–3999 : Compile-Time & Reflection**

- invalid use of `comptime`
- invalid reflection query
- accessing missing fields through reflection

**4000–4999 : Memory & Ownership**
- illegal pointer operations
- invalid view after destruction
- mutation of non-shared value
- invalid lifetime or ownership transfer

**5000–5999 : Concurrency**

- invalid waits
- invalid channel operations
- misuse of `spawn` or concurrency primitives

**6000–6999 : Modules & Build**

- unresolved import
- circular module dependency
- symbol visibility issues

**7000–7999 : FFI**

- invalid extern type
- ABI-incompatible function signature
- misuse of `void` outside extern

**8000–8999 : Testing Framework**

- invalid test signature
- invalid test file naming

---

## 001.3 Diagnostic Message Structure

Every diagnostic must follow this exact format:

```
error ORI2043: cannot assign pointer to non-shared value
 --> main.ori:12:14
 12 |     p.x = 3
    |          ^ cannot modify field of non-shared value
help: mark the receiver as shared to enable mutation
```

## 001.3.1 Components

- **Header**
  - `error` or, rarely, `warning`
  - error code (e.g., `ORI2043`)
  - short description in lowercase, no period

- **Location**
  ```
  --> file:line:column
  ```

- **Context Snippet**
  - the exact line of code
  - a caret `^` marking the specific span
  - optional secondary labels

- **Help Section (optional)**
  ```
  help: a short actionable suggestion
  ```

- **Notes (optional)**
  ```
  note: additional context or previous definition
  ```

---

## 001.4 Errors vs Warnings

Ori aims to remove ambiguity in diagnostics.  
The following rules apply:

## 001.4.1 These are **compile-time errors** never warnings

- unused variable
- unused import
- unreachable code

Developers must fix these issues immediately.  
They cannot be suppressed, demoted, or ignored.

## 001.4.2 Valid Warning Categories (rare)

Only these may produce warnings:

1. **deprecated API usage**
2. **unnecessary explicit cast**
3. **non-exhaustive pattern matching** (when legal but likely unintended)
4. **overly broad visibility** (e.g., exposing internal type publicly)

Warnings are:
- minimal
- actionable
- never produced in high volume

## 001.4.3 Global Warning Behavior

- No per-error-code suppression mechanism.
- No per-file override.
- Only compiler flag:

```
--warnings-as-errors
```

---

## 001.5 Ordering of Diagnostics

To guarantee deterministic output in editors and CI, Ori enforces a strict ordering of diagnostics:

1. lexing errors
2. parsing errors
3. type system errors
4. memory & ownership errors
5. compile-time errors
6. reflection errors
7. concurrency errors
8. modules & build errors
9. FFI errors
10. testing errors

Within each category:
- sorted by `(file, line, column)`
- ties broken by numeric error code

---

## 001.6 Color & Formatting Rules

- Color is allowed but **never required**
- Diagnostic meaning must remain clear in plain text
- Color must not encode semantics (e.g., red for error is fine, but color alone cannot add meaning)

---

## 001.7 JSON Diagnostic Output

The compiler must support JSON diagnostics for tooling:

Flag:
```
--json-diagnostics
```

Output example:
```json
{
  "file": "main.ori",
  "line": 12,
  "column": 14,
  "code": "ORI2043",
  "severity": "error",
  "message": "cannot assign pointer to non-shared value",
  "help": "mark the receiver as shared to enable mutation"
}
```

This is a minimal, stable format intended for LSP servers, external tools, and CI systems.

---

## 001.8 Diagnostic Philosophy

Ori’s diagnostic system follows these principles:

- **Explicitness:** never hide potential issues
- **Predictability:** same input always yields same diagnostics in same order
- **Clarity:** messages are short and precise
- **Non-guessing:** compiler avoids speculative “did you mean?” suggestions
- **Compiler errors are a hard contract**, not stylistic hints.
- **Consistency:** all tools must use this spec

---

## 001.9 Examples

### Example 1 — Type mismatch
```
error ORI2021: expected int but got string
 --> math.ori:44:18
 44 |     var x int = "hello"
    |                  ^^^^^^ string here
help: convert the string or change the variable type
```

### Example 2 — Unused variable (compile-time error)
```
error ORI1103: variable 'value' is declared but never used
 --> main.ori:10:9
 10 |     var value = count()
    |         ^^^^^
help: remove the variable or use it
```

### Example 3 — Unreachable code
```
error ORI1301: unreachable code after return
 --> main.ori:22:5
 22 |     return x
    |     ^^^^^^^^
 23 |     fmt.println("never runs")
    |     ^^^^^^^^^^^^^^^^^^^^^^^^^ unreachable
```
