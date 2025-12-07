# 150. Types and Memory

Ori’s type and memory model is **deterministic**, **explicit**, and **safe by design**.  
Ori **forbids any garbage collector**.  
Allocation, ownership, and lifetimes are always explicit and predictable.

---

## 150.1 Overview

Ori enforces a clear and rigorous memory model:

- No implicit heap allocations  
- No background memory management  
- No lifetime extension  
- No implicit copies except for pure value types  
- All ownership and reference relationships are explicit  

This section defines **value semantics**, **reference semantics**, **views**, **shared qualifiers**, allocation rules, and lifetime constraints.

---

## 150.2 Type Categories

| Category | Examples | Description |
|----------|----------|-------------|
| **Primitive** | `int`, `float`, `bool`, `rune` | Stored inline; pure value types. |
| **Composite (value)** | `array`, `struct` | Inline or stack‑allocated unless explicitly moved/escaped. |
| **Composite (reference)** | `slice`, `map`, `hashmap`, `string` | Heap-backed storage with reference handles. |
| **Reference (pointer)** | `*T` | Direct reference to a value; no ownership. |
| **Qualifiers** | `view`, `shared`, `const` | Modify ownership or access semantics. |

All types have well‑defined ownership and lifetime rules.

---

## 150.3 Value Semantics

Value types behave predictably:

- Assignment copies the value.  
- Passing to a function copies the value.  
- Mutating a copy does not affect the original.  
- No implicit heap promotion occurs.

Example:

```ori
a int := 10
b := a      // copy
b = 20
print(a)    // 10
```

Structs and fixed-size arrays follow the same rule.

---

## 150.4 Reference Semantics

Reference-based types hold a pointer to underlying memory:

- `string` (UTF-8)
- `slice`
- `map`
- `hashmap`
- pointers `*T`

Assignment does **not** duplicate memory; it copies the reference:

```ori
s []int := [1, 2, 3]
t := s        // both reference the same data
t[0] = 9
print(s[0])   // 9
```

Pointer example:

```ori
x int := 42
p *int := &x
*p = 10
print(x)      // 10
```

Pointers require strict lifetime guarantees (see rules below).

Use a pointer when:

- passing large structures by reference  
- representing optional values (`*T` can be `nil`)  
- interfacing with low-level or FFI code  

Use a `view` when you want *read‑only access* that does not transfer ownership or lifetime.

---

## 150.5 The `view` Qualifier

A `view` is a **non-owning, read‑only reference** to existing memory.

Properties:

- Read‑only  
- Does not own memory  
- Cheap to copy  
- Cannot outlive the source  

Example:

```ori
func sum(v view []int) int {
    total = 0
    for n := range v {
        total += n
    }
    return total
}

arr []int := [1, 2, 3]
result := sum(view(arr))   // OK
```

---

## 150.6 The `shared` Qualifier

`shared` marks data as intended for use across multiple concurrent tasks.

Properties:

- Does **not** provide automatic safety  
- Allows multi-task observation or mutation  
- **Requires synchronization** for mutation  
- Non-`shared` mutable data cannot be sent across tasks  

Example:

```ori
shared nums []int := [1, 2, 3]

t1 := spawn_task worker(nums)
t2 := spawn_task worker(nums)

t1.Wait()
t2.Wait()
```

With mutation:

```ori
func worker(m mutex, d shared []int) {
    m.lock()
    d[0] = d[0] + 1
    m.unlock()
}

func main() {
    var m sync.Mutex
    shared nums []int := [0, 0, 0]
    t1 := spawn_task worker(m, nums)
    t2 := spawn_task worker(m, nums)

    t1.Wait()
    t2.Wait()
}
```

---

## 150.6.1 Reference Usage Examples

These examples illustrate pointer validity relative to lifetimes.

### ❌ Forbidden Example — Reference Outliving Its Source

```ori
func bad_ref() *int {
    x int := 10
    return &x    // ❌ invalid: x is destroyed at end of function
}
```

### ✅ Valid Example — Reference to Heap‑Allocated Value

```ori
func ok_ref() *int {
    p *int := new(int)   // allocated on heap
    *p = 42
    return p             // OK: heap allocation outlives function scope
}
```

Here the pointer refers to heap memory, not a local stack variable.

---

## 150.7 Copy vs View vs Shared

| Category | Owns Memory | Mutability | Allowed in Tasks | Lifetime Tied To |
|----------|-------------|------------|------------------|------------------|
| **Copy** | Yes | Yes | Yes | Itself |
| **Reference (pointer)** | No | Yes | Only if target is shared or heap‑allocated | Target value |
| **view** | No | No | Yes | Source value |
| **shared** | Yes | Yes (sync required) | Yes | Shared owner |

---

## 150.8 Lifetime Rules

### **Rule 1 — A `view` cannot outlive its source**

Invalid:

```ori
func bad_view() view []int {
    arr []int := [1, 2, 3]
    return view(arr)   // ❌ arr destroyed here
}
```

Valid:

```ori
func ok_view(input []int) view []int {
    return view(input)   // caller owns memory
}
```

---

### **Rule 2 — A reference cannot escape its scope unless the value is moved or promoted**

Invalid:

```ori
func bad_ref_escape() *int {
    x int := 42
    return &x      // ❌ x destroyed at end of function
}
```

Valid:

```ori
func ok_ref_escape() *int {
    p *int := new(int)   // heap allocation
    *p = 21
    return p             // safe escape
}
```

---

### **Rule 3 — Temporary expressions cannot produce long-lived views**

Invalid:

```ori
v view []int := view(make_list())   // ❌ temporary list destroyed immediately
```

Valid:

```ori
list []int := make_list()
v view []int := view(list)          // list owns memory
```

---

## 150.9 Allocation and Deallocation

### **Stack Allocation**
Used for local, non-escaping values:

```ori
func id(x int) int {
    y int := x
    return y
}
```

### **Heap Allocation**
Triggered by:

- `new(T)`
- `make(...)`
- Escape analysis

```ori
func create() []int {
    arr []int := [1, 2, 3]
    return arr   // arr promoted to heap
}
```

Ori **forbids garbage collection**; memory is freed deterministically when ownership ends.

---

## 150.10 Concurrency and Lifetimes

### **Rule 1 — Mutable data cannot cross tasks unless marked `shared`**

Invalid:

```ori
arr []int := [1, 2, 3]
spawn_task worker(arr)    // ❌ arr not shared
```

Valid:

```ori
shared arr []int := [1, 2, 3]
spawn_task worker(arr)
```

---

### **Rule 2 — `view` across tasks is always safe**

```ori
func worker(v view []int) {
    for n := range v { _ = n }
}

arr []int := [1, 2, 3]
v view []int := view(arr)
spawn_task worker(v)    // OK
```

Mutation is not allowed:

```ori
func worker(v view []int) {
    v[0] = 9   // ❌ cannot mutate through view
}
```

---

### **Rule 3 — The source must outlive all tasks using its view**

Invalid:

```ori
func demo_bad() {
    arr []int := [1, 2, 3]
    spawn_task worker(view(arr))
} // ❌ arr destroyed before worker finishes
```

Valid:

```ori
func demo_ok() {
    arr []int := [1, 2, 3]
    t := spawn_task worker(view(arr))
    t.Wait()
}
```

---

## 150.11 Summary Table

| Concept | Description | Enforcement |
|---------|-------------|-------------|
| **Value semantics** | Copy on assign; stack by default | Always safe |
| **Reference semantics** | Pointers + heap-backed handles | Lifetime checks |
| **`view`** | Read-only, non-owning | Must not outlive source |
| **`shared`** | Explicit multi-task sharing | Requires sync |
| **Lifetime rules** | Deterministic, lexical | Compiler enforced |
| **Allocation** | Stack or explicit/promotion heap | No GC |
| **Escape analysis** | Auto heap promotion | Compile-time |
| **Concurrency safety** | Only `shared` or `view` may cross tasks | Checked at compile-time |

---

## 150.12 Design Summary

- No garbage collector  
- No implicit lifetime extensions  
- Explicit ownership rules  
- `view` for safe read‑only sharing  
- `shared` for explicit concurrent access  
- Pointers only valid if target outlives usage  
- Deterministic memory model
