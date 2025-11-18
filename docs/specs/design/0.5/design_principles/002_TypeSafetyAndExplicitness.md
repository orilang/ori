# 002. Type Safety and Explicitness

Ori enforces a **strong, fully explicit type system**.  
Every variable, constant, and conversion must be **declared intentionally** — there is no type inference, no hidden conversions, and no implicit default values.

This design guarantees that all types and behaviors are **visible**, **predictable**, and **auditable**.

---

## 1. Introduction

Ori’s type system is founded on **clarity and control**.  
Types are not hints to the compiler; they are contracts defined by the developer.

There is **no inference**, **no automatic zero values**, and **no implicit conversions**.  
Each variable and constant must declare its **type** and **initial value** explicitly.

---

## 2. Core Rules

| Rule | Description |
|------|--------------|
| **Explicit Declaration** | Every variable must declare its type. Example: `var a int = 123` is valid; `var a = 123` is invalid. |
| **Enforced Numeric Types** | Numeric literals are not inferred — `var x = 10` is invalid; `var x int = 10` is required. |
| **No Automatic Values** | Ori does not assign zero or default values automatically. Every variable must be explicitly initialized. |
| **No Implicit Conversions** | Type changes must be explicit using conversion syntax like `float64(x)`. |
| **No Untyped Constants** | All constants must have declared types. |

Ori’s typing rules make data behavior transparent at all times.

---

## 3. Example: Enforced Type Clarity

```ori
// ✅ Valid
var count int = 10
var price float64 = 25.5
price = price + float64(count)

// ❌ Invalid: missing type
var total = 0          
// compile error: missing explicit type

// ❌ Invalid: missing initialization
var x int              
// compile error: variable not initialized
```

---

## 4. Why No Automatic Values

In many languages, uninitialized variables default to zero values (e.g., `0`, `false`, `""`).  
While convenient, this can **hide unintentional logic bugs** and cause silent misbehavior.

Ori forbids automatic initialization — developers must assign explicit values.  

This ensures that:
- Every variable represents a **deliberate state**.  
- No uninitialized or placeholder value slips through.  
- Refactoring is deterministic — no “magical” behavior change.  

Example:

```ori
var ready bool = false // explicit
var count int = 0      // explicit
```

Explicitness leads to clarity and avoids the hidden side effects common in languages with implicit defaults.

---

## 5. Benefits of Explicit Typing

**Deterministic behavior** — no silent conversions or data loss.  
**Safer numeric operations** — overflow and truncation are visible and avoidable.  
**Readable contracts** — code intent is immediately clear from declarations.  
**Predictable compilation** — no guessing or inference from the compiler.  
**Reliable debugging** — the compiler enforces full type knowledge before execution.  

Explicit types remove ambiguity between human reasoning and machine behavior.

---

## 6. Type Conversion Rules

All type conversions must be explicit.  
Only compatible types can be converted, and reinterpretation is forbidden in v0.5.

```ori
var a int = 10
var b float64 = 2.5
var c float64 = float64(a) + b // explicit conversion required
```

Rules:

- **Explicit only:** no automatic casting or coercion.  
- **Compatible types only:** `int → float64` allowed, `int → string` forbidden.  
- **Unsafe conversions:** not supported yet; reserved for `unsafe` contexts in future versions.  

---

## 7. Future Directions

**Type aliases** for domain semantics (e.g., `type UserID = int64`).  
**Generic constraints** for reusable type-safe code (planned for v0.5+).  
**Optional loop variable deduction**, never full inference.  

Even future type features will maintain Ori’s principle of **explicit control**.

---

## 8. Summary

Ori enforces a strong, explicit, and predictable type system:

- Every variable has a **declared type**.  
- Every variable must have an **explicit initial value**.  
- Every conversion is **intentional**.  
- No type inference.  
- No zero defaults.  
- No ambiguity.

> “If the compiler needs to guess, it means the developer wasn’t explicit enough.”

---

Ori’s type philosophy ensures code that is **clear to the reader**, **trusted by the compiler**, and **deterministic in execution**.
