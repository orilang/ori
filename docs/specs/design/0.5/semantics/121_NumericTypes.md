# 121. Numeric Types

Ori defines numeric types as **explicit**, **predictable**, and **safe**.  
No implicit type promotion, silent wrapping, or automatic coercion is allowed.  
All arithmetic must be intentional and unambiguous.

---

## 121.1 Overview

Numeric types in Ori have:
- Deterministic widths (e.g., `int32`, `uint64`).
- No implicit conversions between numeric families.
- Human-readable literal syntax (`1_000_000`).
- Checked arithmetic by default — overflow triggers a **runtime panic** unless explicitly handled.

Ori’s numeric system prevents silent data corruption and ensures correctness across architectures.

---

## 121.2 Integer Types

Ori provides both **signed** and **unsigned** integers with fixed bit widths.  
The aliases `int` and `uint` default to 64-bit variants.

| Type | Description | Range | Example |
|-------|-------------|--------|----------|
| `int8`, `int16`, `int32`, `int64` | Signed integers | −2ⁿ⁻¹ to 2ⁿ⁻¹−1 | `var a int32 = 100` |
| `uint8`, `uint16`, `uint32`, `uint64` | Unsigned integers | 0 to 2ⁿ−1 | `var b uint16 = 500` |
| `int` | Alias to `int64` | −2⁶³ to 2⁶³−1 | `var x int = 123` |
| `uint` | Alias to `uint64` | 0 to 2⁶⁴−1 | `var y uint = 456` |

### Integer Rules

No implicit conversion between signed and unsigned integers.  
Arithmetic between mixed types is **invalid** without explicit conversion.  
Use `int` and `uint` for general arithmetic unless fixed-width precision is required.

---

## 121.3 Floating-Point Types

| Type | Description |
|-------|-------------|
| `float32` | 32-bit IEEE 754 floating-point |
| `float64` | 64-bit IEEE 754 floating-point |
| `float` | Alias to `float64` on 64-bit architecture |

### Example
```ori
var f float32 = 1.5
var g float64 = float64(f) + 2.0
```

Floating-point operations follow IEEE 754 behavior (NaN, +Inf, -Inf).

---

## 121.4 Numeric Literal Syntax

Numeric literals may include **underscores for readability**, similar to Go.

```ori
var a int = 1_000_000    // 1000000
var b int = 0b1010_1010  // binary literal
var c int = 0xFF_FF      // hexadecimal
var d float = 3.141_592
```

### Rules for underscores
- Allowed **only between digits** — not at start, end, or next to base prefixes or decimal points.
- Must separate valid digit groups.

Examples:
```ori
1_000_000   // ✅ valid
1000_       // ❌ invalid
_1000       // ❌ invalid
0x_FF       // ❌ invalid
```

Ori enforces these rules to prevent malformed or misleading numeric literals.

---

## 121.5 Arithmetic Rules

Operands must share the same numeric type.  
Integer division truncates toward zero.  
Float division preserves fractional results.  
Overflow is **checked by default** — triggers **runtime panic** if detected.

### Example
```ori
var a int = 5 / 2     // 2
var b float = 5.0 / 2 // 2.5
```

---

## 121.6 Overflow and Underflow

Ori never silently wraps integer and float values.  
All arithmetic operations are **checked** and trigger a **runtime panic** on overflow or underflow.

### Default Behavior

| Operation | Description |
|------------|--------------|
| `+`, `-`, `*` | Checked arithmetic. **Panics** on overflow. |
| `/` | Checked division. **Panics** on divide-by-zero. |
| Compile-time constants | Overflow detected at compile time (**compile error**). |

### Example — Default Checked Arithmetic

```ori
var a uint8 = 255
a += 1 // ⚠️ runtime panic: overflow (uint8)
```

### Explicit Wrapping Operators

| Operator | Meaning |
|-----------|----------|
| `+%` | Wrapping addition (modular arithmetic) |
| `-%` | Wrapping subtraction |
| `*%` | Wrapping multiplication |

Example — Explicit Wrapping:
```ori
var a uint8 = 255
a +%= 1 // ✅ wraps to 0 explicitly
```

### Overflow Detection Functions

Ori provides **explicit overflow-checking arithmetic functions**, each returning `(result, overflowed)` tuples.

| Function | Description | Return | Example |
|-----------|-------------|---------|----------|
| `overflow_add(a, b)` | Performs addition, returns overflow flag | `(T, bool)` | `r, ov := overflow_add(a, b)` |
| `overflow_sub(a, b)` | Performs subtraction, returns overflow flag | `(T, bool)` | `r, ov := overflow_sub(a, b)` |
| `overflow_mul(a, b)` | Performs multiplication, returns overflow flag | `(T, bool)` | `r, ov := overflow_mul(a, b)` |

Example — Checked Detection (No Panic):
```ori
var a uint8 = 255
r, ov := overflow_add(a, 1)
if ov {
    fmt.Println("overflow detected")
}
```

### Design Rationale

Prevents silent numeric corruption.  
Behavior is identical across build modes — always checked, always safe.  
Runtime panics are deterministic and report detailed diagnostic context.  
Matches Zig’s explicit overflow model and avoids Rust’s mode-dependent behavior.

---

## 121.7 Type Conversion

Numeric conversions are **explicit** only.

```ori
var a int64 = 42
var b int32 = int32(a) // ✅ explicit
var c int32 = a        // ❌ implicit narrowing not allowed
```

Conversions between integer and float families must also be explicit.

---

## 121.8 Comparisons

Comparisons are only valid between values of the **same numeric type**.

```ori
var x int32 = 10
var y int64 = 10
if int64(x) == y { fmt.Println("equal") }
```

---

## 121.9 Constants and Literals

Numeric constants are **untyped** until assigned to a variable or used in context.

```ori
var x int32 = 123
var y float64 = 123.0
```

The compiler infers the type based on the destination but performs no implicit widening or narrowing.

---

## 121.10 Comparison with Zig and Rust

| Language | Default Overflow Behavior | Wrapping Option | Notes |
|-----------|---------------------------|------------------|-------|
| **Ori (v0.5)** | **Runtime panic** on overflow | Explicit (`+%`, `-%`, `*%`) | Consistent across builds |
| **Zig** | **Runtime panic** | Explicit (`+%`, `-%`, `*%`) | No undefined behavior |
| **Rust (Debug)** | Panic | `.wrapping_add()` | Safe by default |
| **Rust (Release)** | Wraps silently | `.wrapping_add()` | Performance-optimized |

Ori aligns with Zig’s deterministic safety model, ensuring consistent checked arithmetic across all builds.

---

## 121.11 Design Summary

| Principle | Description |
|------------|-------------|
| **Explicit typing** | No implicit type promotion or inference. |
| **Deterministic width** | Same behavior across architectures. |
| **Human-readable literals** | `_` allowed for readability. |
| **Checked arithmetic** | Overflow triggers **runtime panic**. |
| **Explicit wrapping ops** | `+%`, `-%`, `*%` for intentional wrapping. |
| **Overflow detection** | `overflow_add`, `overflow_sub`, `overflow_mul` return `(value, overflowed)` tuples. |

---

## 121.12 Future Extensions

- `saturating_add(a, b)` and similar APIs (clamp at min/max).
- Compile-time range-constrained numeric types (`int<0..255>`).
- Arbitrary precision (`bigint`, `decimal`).  
- SIMD and vector numeric operations.  
- Context-based safe blocks (`safe { ... }`).

---
