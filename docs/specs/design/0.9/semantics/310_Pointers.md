# 310. Pointers

**Pointers** in Ori provide low-level access to raw memory addresses.  
They are intended for FFI, embedded systems, and advanced performance-critical operations.  
Pointers do **not** participate in Ori’s ownership, view, or shared-memory system, and they do not provide any safety guarantees.  
They are purely raw, nullable addresses.  
Pointers must always be used consciously and explicitly.

--- 

## 310.1 Overview

Ori emphasizes explicitness, predictability, and safe-by-default design. Pointers therefore follow these principles:
- **Explicit** — Pointer types must always be written by the programmer. No inference
- **Nullable** — Pointers may hold `nil`
- **Non-owning** — Pointers never control destruction or ownership
- **Low-level** — Raw addresses without safety or validity guarantees
- **Rare** — Everyday code should use containers, slices, and shared-memory primitives instead

Pointers mainly exist for:
- FFI (Foreign Function Interface) interaction
- Address-based low-level systems programming
- Specialized data structures

---

## 310.2 Pointer Type Syntax

Pointer types are written with the prefix `*`:

```ori
var p *int
var q *User
```

---

### 310.2.1 Nullability

All pointer types are nullable by default.

```ori
var p *int = nil
```

Dereferencing `nil` is invalid:
- If the compiler can prove `p` is `nil` → **compile-time error**
- Otherwise → **runtime safety error**

---

## 310.3 Obtaining a Pointer

A pointer is obtained only through the **address-of** operator:
```ori
var x int = 5
var p *int = &x   // OK
```

---

### 310.3.1 No Type Inference for Pointers

Pointer inference is **forbidden**:
```ori
var p = &x    // ❌ compile-time error: pointer type must be explicit
```

Only the explicit form is allowed:
```ori
var p *int = &x
```

This avoids ambiguity with other memory-related types (`view`, `shared`).

---

## 310.4 Dereferencing

Dereferencing uses the unary `*` operator.

### 310.4.1 Reading

```ori
var x int = 42
var p *int = &x

var y int = *p   // y = 42
```

---

### 310.4.2 Writing

```ori
*p = 99
```

---

### 310.4.3 Dereferencing Rules

- Dereferencing known-nil → compile-time error
- Dereferencing `nil` → runtime safety error
- Dereferencing does not extend lifetimes
- Dereferencing never affects destructors or ownership

---

## 310.5 Pointer Semantics

### 310.5.1 No Ownership

A pointer never owns the memory it points to:
```ori
{
    var u User{Name: "A"}
    var p *User = &u
}   // destructor(u) runs here
    // p is now dangling
```

---

### 310.5.2 Comparisons

Only equality is supported:
```ori
p == q
p != q
p == nil
```

Ordering comparisons are **forbidden**:
```ori
p < q     // ❌ compile-time error
```

---

### 310.5.3 Pointer Arithmetic

All pointer arithmetic is forbidden:
```ori
p + 1     // ❌ compile-time error
p - 4     // ❌ compile-time error
```

---

### 310.5.4 Dangling Pointers

A pointer becomes **dangling** when it still holds an address, but the object at that address has been destroyed or deallocated.

Examples:
- A pointer to a local variable used after the variable’s scope ends
- A pointer to memory freed by a foreign allocator

Ori does not track all aliases or automatically nullify pointers when their target is destroyed. After the lifetime of the pointee ends, every pointer to it becomes dangling, and dereferencing such a pointer is a runtime safety error.

The compiler may statically reject trivial escaping cases (such as `return &localVar`), but in general it does not perform lifetime analysis for pointers.

---

### 310.5.5 Pointers Cannot Be Method Receivers

Raw pointers (*T) cannot be used as method receivers.

Example of invalid method declaration:
```ori
func (t *Test) count() int   // ❌ invalid
```

Reasons:
- Pointers are unsafe: nullable, may dangle, not lifetime-checked
- Pointers do not integrate with shared / const receiver semantics
- Pointers do not imply ownership or safe aliasing
- Pointer receivers would break deterministic destruction and concurrency rules

Use safe receivers instead:
- For mutation:
  ```ori
  func (t shared Test) count() int
  ```
- For read-only access:
  ```ori
  func (t const Test) show() string
  ```
- For copy semantics:
  ```ori
  func (t Test) clone() Test
  ```

This ensures method calls always operate on valid, lifetime-checked memory.

---

## 310.6 Runtime Safety Rules

The following produce runtime errors:
- Dereferencing a `nil` pointer
- Dereferencing an invalid or dangling pointer
- Using pointers across threads without synchronization

No compiler lifetime analysis is performed for pointers.

---

## 310.7 Heap Allocation with `new(T)`

`new(T)` allocates a `T` on the heap (defined in `150_TypesAndMemory.md`):

```ori
var p *T = new(T)
```

Properties:
- Returns a pointer `*T`
- Memory is owned by the variable holding the pointer
- Destroyed when that owner goes out of scope
- May escape function scope safely

Example:
```ori
func f() *int {
    var p *int = new(int)
    *p = 10
    return p
}
```

---

## 310.7 Interactions with Other Features

### 310.7.1 Pointers vs Views

| Feature | View (`view T`) | Pointer (`*T`) |
|--------|------------------|----------------|
| Safety | High | None |
| Nullability | No | Yes |
| Bounds checks | Yes | No |
| Alias tracking | Yes | No |
| Primary use | Safe slicing | Raw address access |

Views should be used whenever safety is desired.

---

### 310.7.2 Pointers vs Shared

`shared` is a **concurrency qualifier**, not a memory-level primitive.

| Feature | `shared T` | `*T` |
|---------|-------------|-------|
| Purpose | concurrency-safe access | raw address |
| Nullability | never | yes |
| Ownership | normal | no |
| Thread-safe | yes (rules enforced) | no |
| Use case | multi-task communication | FFI, low-level ops |

Guideline:

> Use `shared` for cross-thread access.  
> Use pointers for raw memory or interop only.

---

### 310.7.3 Returning Pointers to Locals

Returning the address of a local variable is illegal:
```ori
func f() *int {
    var x int = 10
    return &x       // ❌ compile-time error
}
```

Correct syntax:
```ori
func f() *int {
    var x *int = new(int)
    *x = 10
    return x
}
```

---

### 310.7.4 Pointers and Generics

Pointers work naturally inside generic functions:
```ori
func Swap[T](a *T, b *T) {
    var tmp T = *a
    *a = *b
    *b = tmp
}
```

---

### 310.7.5 Pointers and FFI

Pointers are essential to FFI:
```ori
@[extern("C")] // exact syntax not yet define
func malloc(size int) *byte

@[extern("C")] // exact syntax not yet define
func free(p *byte)
```

They carry the exact semantics of the foreign system and are inherently unsafe.

---

## 310.8 Concurrency

Pointers are not concurrency-safe.  
Example of unsafe behavior:
```ori
spawn_thread {
    *p = 10   // possible data race
}
```

Developers must rely on:
- `shared`
- synchronization primitives
- concurrency-safe containers

when sharing data between tasks.

---

## 310.9 Forbidden Patterns

The compiler must reject:
```ori
var p = &x              // ❌ compile-time error: pointer type must be explicit
var p = nil             // ❌ compile-time error: type must be explicit
p + 1                   // ❌ compile-time error: pointer arithmetic
return &localVar        // ❌ compile-time error: pointer escaping local
p = 10                  // ❌ compile-time error: assigning int to *int
```

---

## 310.10 Correct Usage Examples

```ori
var x int = 5
var p *int = &x

*p = 10
var y = *p        // y = 10
```

```ori
type struct Node {
    value int
    next  *Node
}
```

```ori
func increment(x *int) {
    *x = *x + 1
}
```

---

## 310.11 Misuse Examples (Common Errors)

### 310.11.1 Assigning a Value Directly to a Pointer

```ori
var x int = 5
var p *int = &x

p = 10
```

❌ **ERROR**: `p` has type `*int`, cannot assign an `int`.

Correct version:
```ori
*p = 10
```

---

### 310.11.2 Confusing Pointer with Value

```ori
var x int = 5
var p *int = &x

var y = p
```

❌ `y` is a `*int`, not the value `5`.

Correct:

```ori
var y int = *p
```

---

### 310.11.3 Attempting Pointer Arithmetic

```ori
p += 1     // ❌ compile-time error
z = p + 4  // ❌ compile-time error
```

Ori does not support pointer arithmetic.

---

### 310.11.4 Assuming Dereference Happens Automatically

```ori
var x int = 5
var p *int = &x

var y int = p    // ❌ compile-time error
```

Dereference must always be explicit:
```ori
var y int = p  // ❌ error
var y int = *p // ✅ valid
```

---

## 310.12 Summary

- Pointer types use `*T`
- Pointers are nullable; `nil` is the null pointer
- Pointers must be declared explicitly
- No pointer inference
- Dereferencing uses `*p`
- Dereferencing a known-nil pointer produces a compile-time error
- Dereferencing a possibly-nil pointer produces a runtime error
- `new(T)` introduces heap allocation
- Pointers never own memory
- No pointer arithmetic
- Only equality comparisons allowed
- Unsafe across threads unless wrapped
- Intended primarily for FFI and low-level operations
- Unsafe for concurrency without protection
