# 150. Types and Memory

Ori’s type and memory system is **deterministic**, **explicit**, and **safe by design**.  
There is no garbage collector or implicit memory reallocation.  
Developers have full control over allocation, ownership, and lifetimes.

---

## 150.1 Overview

Ori emphasizes **predictable behavior** through explicit ownership and well-defined type semantics.  
All variables are initialized explicitly, memory layout is deterministic, and values are never implicitly copied to the heap.

---

## 150.2 Type Categories

| Category | Examples | Description |
|-----------|-----------|-------------|
| **Primitive** | `int`, `float`, `bool`, `rune` | Basic scalar types stored by value. |
| **Composite** | `struct`, `array`, `slice`, `map`, `hashmap`, `string` | Aggregated types combining other types. |
| **Reference** | `view`, `ref` | Non-owning or alias references to existing values. |
| **Constant** | `const` | Immutable binding preventing mutation. |

### Rune Type

A `rune` represents a single **Unicode code point** (UTF-32 scalar value).  
It corresponds to a "character" in Unicode terms, but not necessarily to one byte.

> In C, the closest equivalent to a `rune` is a `char`, but a C `char` only represents a single byte (typically ASCII), not a full Unicode code point.

---

## 150.3 Value Semantics

All primitive and composite values use **value semantics** by default:

- Assignment or function argument passing **copies** the value.  
- No implicit deep copies or heap promotions occur.  
- Mutations on a copy do **not** affect the original.

Example:

```ori
var a int = 10
var b int = a // copies the value
b = 20
fmt.Println(a) // 10
```

---

## 150.4 Memory Model

**Stack allocation** for local and short-lived variables.  
**Heap allocation** via constructors (`make`, `append`, etc.).  
**No garbage collector** — all lifetimes are explicit and predictable.  
**Temporary values** exist within their lexical scope.

Ori may later introduce scoped automatic cleanup (RAII-like aka **Resource Acquisition Is Initialization** aka defer) but currently follows deterministic scope-based lifetime rules.

---

## 150.5 Ownership and Qualifiers

| Qualifier | Meaning | Notes |
|------------|----------|-------|
| `const` | Immutable binding; cannot be reassigned or mutated. | Used for read-only values. |
| `view` | Non-owning reference; read-only access. | Safe shared access. |
| `ref` | Mutable alias to another value. | Experimental; no lifetime inference yet. |

---

## 150.6 Rune vs String

### Definition

A `rune` represents **one Unicode code point** (UTF-32).  
A `string` represents a **UTF-8 encoded sequence** of runes.

Example:

```ori
var r rune = 'β'     // One Unicode rune
var s string = "Ori" // UTF-8 encoded sequence of runes

fmt.Println(r)       // β
fmt.Println(len(s))  // 3 bytes (UTF-8)
for r := range s {
    fmt.Println(r)   // O, r, i
}
```

### Convert Between Them

```ori
var r rune = 'O'
var s string = string(r) // "O"
var r2 rune = s[0]       // 'O' (first byte, may not be full rune if multi-byte UTF-8)
```

Conversions between `rune` and `string` are **explicit** and do not perform automatic widening or narrowing.

---

### Pitfalls to Avoid

A "character" in a string is **not always one byte** — UTF-8 uses 1–4 bytes per rune.  
`len(s)` returns **byte length**, not the number of runes.  
Comparing different types is invalid:

```ori
if 'O' == "O" { ... } // ❌ Type mismatch
if string('O') == "O" { ... } // ✅ Explicit conversion
```

Indexing strings returns bytes, not runes; use iteration to access characters safely.  
Truncating strings mid-sequence can break UTF-8 integrity.

---

### Design Implication for Ori v0.4

| Decision | Status | Rationale |
|-----------|---------|-----------|
| Use `rune` instead of `char` | ✅ Adopted | Consistent with prior specs (`050_Types.md`, `120_Strings.md`). |
| Encoding for `rune` | UTF-32 | One fixed-width Unicode scalar per value. |
| Encoding for `string` | UTF-8 | Compact, standard, and FFI-friendly. |
| Conversion between them | Explicit | Prevents hidden allocations or truncation. |
| Iteration | Over `rune` values | Avoids confusion between bytes and characters. |

---

### Corrected Concept Summary

| Concept | Keyword | Meaning | Notes |
|----------|----------|----------|--------|
| Single Unicode code point | `rune` | 32-bit scalar value (UTF-32) | Value type, fixed size |
| Text sequence | `string` | UTF-8 encoded array of runes | Immutable, heap-allocated |
| Conversion | `string(r)` / `rune(s[i])` | Explicit only | No implicit widening |
| Iteration | `for r := range s` | Iterate over Unicode runes | Safe decoding |
| C equivalence | `char` | Single byte (ASCII) | Not Unicode-aware |

---

## 150.7 Copy vs View vs Ref

| Operation | Copy | View | Ref |
|------------|------|------|-----|
| Ownership | Owns value | Borrows reference | Aliases target |
| Mutability | Independent | Read-only | Mutable |
| Lifetime | Independent | Linked to source | Linked to source |
| Example | `a := b` | `var view v = b` | `var ref r = b` |

---

## 150.8 Lifetime Rules

Values are destroyed when leaving their lexical scope.  
`view` references cannot outlive their source.  
No dynamic runtime lifetime analysis — static scope visibility only.  
`ref` must be used carefully; future versions may enforce lifetime tracking.

---

## 150.9 Allocation and Deallocation

```ori
var arr = make([]int, 10) // Allocates on the heap
free(arr)                 // Planned for future versions
```

`make` constructs heap-allocated objects (arrays, slices, maps).  
Deallocation is explicit and deterministic.  
No garbage collection or implicit memory reuse.

---

## 150.10 Immutability and Thread Safety

- `const` values are inherently thread-safe.  
- `view` ensures safe read-only concurrency.  
- `ref` aliases are **not thread-safe** unless synchronized explicitly.  
- Future versions may add synchronization primitives or atomic qualifiers.

---

## 150.11 Unsafe Operations (Future)

Future Ori versions may introduce an `unsafe` keyword for low-level memory manipulation:

```ori
unsafe {
    var p *int = addressOf(x)
    *p = 42
}
```

Unsafe operations are intended for system-level code or FFI integration, not general use.  
The Unsafe syntax and usage will be discussed in future versions.

---

## 150.12 Design Summary

No garbage collector.  
No hidden heap allocations.  
All values and references are explicit.  
`rune` (UTF-32) and `string` (UTF-8) separation ensures encoding clarity.  
Ownership and lifetime rules are simple and predictable.

---

## 150.13 Future Extensions

- Scoped cleanup (RAII-like destructors aka Resource Acquisition Is Initialization aka defer).
- Compile-time lifetime validation.
- Reference counting for shared data.
- Explicit pointer and FFI-safe structures.
- Optimized move semantics for large composites.
