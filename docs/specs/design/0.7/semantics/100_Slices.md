# 100. Slices

Slices in Ori are dynamic, contiguous views over arrays.  
They provide flexible data handling without losing control over memory and type safety.

---

## 100.1 Overview

A **slice** is a lightweight descriptor that references a contiguous segment of elements of a given type.  
Slices do **not** own their underlying memory — they act as a safe view of an array or allocated buffer.

Example:

```ori
var nums []int = make([]int, 5)
nums[0] = 42
```

Slices combine flexibility with predictable memory semantics — no hidden growth, no implicit reallocation.

---

## 100.2 Declaration and Initialization

```ori
var s []int        // uninitialized slice (nil)
var data [5]int
var view []int = data[0:3] // slice of array
```

A slice type is written as `[]T`, where `T` is any valid element type.

---

## 100.3 Slice Creation

Slices can be created in two ways:

### 1. With `make`

```ori
var nums []int = make([]int, 5)
```

The `make` built-in allocates a new backing array and returns a slice descriptor referencing it.

Syntax:
```
make([]T, length [, capacity])
```

- **length** → number of initialized elements available for indexing.
- **capacity** → total number of elements the slice can hold before reallocation.
- If capacity is omitted, it defaults to the length.

Example:
```ori
var a []int = make([]int, 3, 10)
```
`a` has a **length** of 3 and a **capacity** of 10.

### 2. With a dynamic literal

```ori
var nums []int = []int{1, 2, 3}
```

A dynamic literal allocates a new backing array whose length and capacity equal the number of elements listed.

Equivalent to:
```ori
var nums []int = make([]int, 3)
nums[0] = 1
nums[1] = 2
nums[2] = 3
```

Both forms allocate memory explicitly. No slice can exist without a defined backing array.

---

## 100.3.1 Capacity and Overflow Behavior

When appending exceeds the current capacity:

- A **new backing array** is allocated.
- Existing elements are copied into the new memory.
- The returned slice points to the new array.

Example:
```ori
var s []int = make([]int, 2, 2)
s = append(s, 10) // reallocation occurs here
```

After reallocation, `s` no longer shares memory with the old slice.  
Ori’s allocator **never implicitly doubles** capacity — all allocation is explicit and predictable.

---

## 100.4 Indexing and Ranging

Elements are accessed by index starting at 0.

```ori
nums[0] = 1
var x int = nums[1]
```

Out-of-range indexing causes a runtime error.

Slices can also be ranged over:

```ori
for i, v := range nums {
    fmt.Println(i, v)
}
```

---

## 100.5 Slicing Expressions

A new slice may be derived from another:

```ori
var sub []int = nums[2:5]
```

The result shares the same underlying data.  
Changes in one slice are visible in others referencing the same memory.

### 100.5.1 Bounds-Safe Slicing Syntax

Ori supports half-open slicing syntax that ensures runtime safety:

- `s[a:b]` → slice from index `a` to `b` (exclusive)
- `s[a:]` → slice from index `a` to the end
- `s[:b]` → slice from start to `b` (exclusive)
- `s[:]` → full shared view of the slice

All slicing operations are **bounds-checked** at runtime.  
If the specified range exceeds slice length or is invalid (`a > b`), a runtime error occurs.

Example:

```ori
var nums []int = []int{1, 2, 3, 4, 5}
var head view []int = nums[:3] // [1, 2, 3]
var tail view []int = nums[2:] // [3, 4, 5]
```

Both `head` and `tail` are shared views of the same underlying memory.

---

## 100.6 Append Operation

Ori uses explicit appending — `append()` returns a **new** slice.

```ori
var data []int = make([]int, 0, 4)
data = append(data, 1)
data = append(data, 2)
```

`append` may allocate a new backing array if the capacity is exceeded.  
No implicit reallocation occurs — all allocation is explicit.

---

## 100.7 Copy Operation

Slices can be copied using the `copy()` built-in:

```ori
var src []int = []int{1, 2, 3}
var dst []int = make([]int, 3)
copy(src, dst)
```

The `copy()` operation copies elements from the **source** into the **destination** until the shorter of the two slices is exhausted.

After copying:
- The two slices reference **different memory regions**.
- Modifying `dst` will **not** affect `src`.

Example:
```ori
dst[0] = 99
fmt.Println(src[0]) // still 1 — independent copy
```

`copy()` always produces a **copy view** (deep copy), not a shared reference.

---

## 100.8 Const Slices

Ori supports **constant slices** declared as `const []T`.

A const slice is an immutable slice descriptor defined at compile time.  
It cannot be modified, appended to, or re-sliced beyond its bounds.

Example:

```ori
const primes []int = [5]int{2, 3, 5, 7, 11}
fmt.Println(primes[0]) // 2
```

### Properties
- The slice and its elements are immutable.
- Stored in read-only memory at compile time.
- Ideal for lookup tables, static data, or predefined sequences.

### Rules
| Operation | Allowed? |
|------------|-----------|
| Indexing (`x = primes[0]`) | ✅ Yes |
| Mutation (`primes[0] = 9`) | ❌ No |
| Append (`append(primes, 13)`) | ❌ No |
| Slicing (`primes[1:3]`) | ✅ Yes (returns another const slice) |

Const slices improve safety and memory efficiency for static data.

---

## 100.9 Nil and Empty Slices

A nil slice (`nil`) has no backing array or data.

```ori
var s []int
fmt.Println(s == nil) // true
```

Empty slices have a valid descriptor but zero length:

```ori
var s []int = make([]int, 0)
```

---

## 100.10 Comparison and Equality

Slices cannot be compared directly except to `nil`.

To compare content, explicit iteration is required.

---

## 100.11 Passing Slices to Functions

Slices are passed **by value**, but the value contains a pointer to the backing array.  
Mutating elements inside a function affects the caller’s slice content.

Example:

```ori
func fill(s []int) {
    for i := 0; i < len(s); i = i + 1 {
        s[i] = i
    }
}
```

---

## 100.12 Memory Model

Slices reference memory managed by arrays or the allocator.  
Re-slicing does not copy data.  
Explicit functions like `append()` or `make()` may allocate.

---

## 100.13 Copy View vs Shared View

Slices in Ori can exist in two distinct reference modes:

| Mode | Description | Behavior |
|------|--------------|-----------|
| **Copy View (default)** | Regular slice that owns its memory allocation. Copies create new, independent buffers. | Safe for modification. |
| **Shared View (`view` keyword)** | Non-owning reference to another slice or array. Modifications affect the original data. | Efficient but must be used with care. |

---

### Example: Shared vs Copy Views

```ori
var data []int = []int{1, 2, 3, 4}

// Create a shared view referencing a subsection
var sub view []int = data[1:3]

// Create a copy view (deep copy)
var clone []int = make([]int, len(sub))
copy(sub, clone)

// Modify through the shared view
sub[0] = 99

fmt.Println(data)  // [1 99 3 4]
fmt.Println(clone) // [2 3] — unaffected
```

---

### Semantics Summary

| Operation | Effect |
|------------|---------|
| `[:]` slicing | Creates a **shared view** (same memory). |
| `copy()` | Creates a **copy view** (independent memory). |
| `view` qualifier | Enforces non-owning reference semantics explicitly. |
| `append()` | May reallocate; returns a new independent slice if capacity exceeded. |

---

### Notes

- The `view` qualifier ensures clarity of intent: a programmer **chooses** whether to share or copy memory.  
- It prevents accidental aliasing — all shared memory must be declared explicitly using `view`.  
- A `view` slice cannot outlive its source object; the compiler enforces safe lifetime semantics.

---

## References
- [Types](syntax/050_Types.md)
- [Expressions](syntax/070_Expressions.md)
