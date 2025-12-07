# 260. Container Ownership Model

Ori’s container types (`string`, `slice`, `map`, `hashmap`) are heap‑backed, reference‑semantics values with **explicit, deterministic ownership** and **predictable aliasing rules**.  
This document refines the general model from `150_TypesAndMemory.md` and the behavioral map semantics from `110_Maps.md` by specifying how containers own memory, how aliases behave, and how lifetimes are enforced.

This file **does not** redefine surface syntax or APIs already covered elsewhere; it focuses on **ownership, aliasing, and lifetime semantics**.

---

## 260.1 Overview

Container ownership in Ori follows these principles:
- **No garbage collector** — all heap memory is freed deterministically when its last owner is destroyed.
- **Handle + backing storage model** — a container value is a *handle* to heap‑allocated backing storage (buffer, table, nodes…).
- **Reference semantics by default** — assigning or passing a container copies the handle; backing storage is shared until explicitly cloned or moved.
- **Views are non‑owning** — `view` qualifiers never own container storage and must not outlive their source.
- **Explicit structural operations** — growth, reallocation, and rehashing are explicit consequences of operations like `append`, `insert`, `delete`, and `clear`.
- **No hidden non‑determinism** — map iteration order is defined; hashmap iteration order is intentionally unspecified but stable within a single iteration snapshot.
- **Safety-first aliasing** — operations that would invalidate live views are rejected at compile time whenever statically detectable.

This document assumes the type categories and qualifiers defined in `150_TypesAndMemory.md`.

---

## 260.2 Container Categories

Ori exposes two broad container families:

- **String‑like**: `string`
- **Sequence‑like**: `slice[T]`
- **Dictionary‑like**:
  - `map[K]V` — **ordered**, deterministic insertion order semantics
  - `hashmap[K]V` — **unordered**, hash‑based lookup, iteration order not part of the API contract

All four are:
- heap‑backed
- reference‑semantics values (handle + backing storage)
- subject to deterministic destruction (see `220_DeterministicDestruction.md`)

---

## 260.3 General Ownership Rules

### 260.3.1 Handles and Backing Storage

A container value `C` conceptually consists of:

- a small, fixed‑size *handle* stored inline (e.g., pointers, length/capacity or table metadata)
- a heap‑allocated *backing storage* (buffer or table) containing the elements

Copying a container:
- copies **only the handle**
- does **not** duplicate backing storage
- produces two containers that alias the same backing storage

Example:

```ori
var a []int = make([]int, 0, 8)
var b = a           // b aliases a’s backing buffer
```

Deep copies are performed via explicit APIs such as `clone` (for maps) or future library helpers.

---

### 260.3.2 Deterministic Destruction and Shared Storage

When the last live container handle referencing a backing storage instance is destroyed, the backing storage is:
1. logically invalidated and
2. deterministically deallocated and
3. all contained elements are destroyed according to their own destruction rules.

Implementations may use reference counting, arena ownership, or other mechanisms internally, but from the language perspective the behavior is **deterministic, with no GC**.

---

### 260.3.3 Views of Containers and Their Elements

`view` qualifiers never own container storage:

- `view string` refers to a substring of an existing `string`.
- `view []T` may refer to:
  - a slice of an existing `slice[T]`, or
  - a slice derived from contiguous container storage.
- `view T` for elements refers to a specific element within a container.

In all cases:

- the **source** container must outlive the view;
- any operation that may invalidate the referenced region while a view is live must be rejected.

Lifetime rules follow the general `view` semantics from `150_TypesAndMemory.md`. fileciteturn0file0

---

## 260.4 Strings

### 260.4.1 String Properties

`string` is:

- a UTF‑8 sequence of bytes
- **immutable** at the element level
- represented as a handle to heap‑allocated or static storage
- a reference‑semantics type (handle copy shares underlying bytes)

Because strings are immutable:

- multiple string handles can safely share the same storage;
- views into a string cannot mutate underlying bytes.

---

### 260.4.2 String Copy Semantics

Assigning or passing a `string`:

- copies the string handle;
- does *not* duplicate the underlying byte buffer.

Implementations may use copy‑on‑write or symbol interning internally, but the language guarantees:

- modifying a `string` value is only possible via **replacement**:

```ori
s := "hello"
s = s + " world"   // new string created; original storage remains immutable
```

---

### 260.4.3 String Slicing and `view string`

A substring operation yields a **view**:

```ori
s string := "hello world"
prefix view string := s[0:5]   // "hello"
```

Rules:

- `view string` is non‑owning; it cannot outlive `s`.
- implementations may represent `view string` as `(ptr, len)` into `s`’s buffer.
- any attempt to return a `view string` to a temporary or local string that does not escape is rejected at compile time.

Invalid:

```ori
func bad() view string {
    s string := "hi"
    return s[0:1]    // ❌ view to local string
}
```

Valid:

```ori
func ok(s string) view string {
    return s[0:1]    // caller owns `s`
}
```

---

### 260.4.4 String Literals and Static Storage

String literals may reside in static, read‑only storage. Views into such storage are valid for the entire program lifetime, subject to normal scope rules.

---

## 260.5 Slices

### 260.5.1 Slice Properties

A `slice[T]` is a *view‑like handle with mutation*:
- it references contiguous storage for elements of type `T`
- the handle stores `(ptr, len, cap)` or equivalent
- the underlying storage is owned by some heap allocation or larger container
- assignment copies the handle, so multiple slices may alias the same backing storage

Slices are not self‑owning values; instead, they are **mutable windows** into backing storage.

---

### 260.5.2 Append Semantics

Ori provides `append` with Go‑style ergonomics and explicit rules:
```ori
s []int := make([]int, 0, 4)
s = append(s, 1)
s = append(s, 2, 3, 4)
s = append(s, 5)     // may reallocate here
```

Rules:

- If `len(s) + new_elements <= cap(s)`:
  - no reallocation occurs;
  - the backing storage is reused;
  - all slices aliasing this buffer observe the mutations.
- If capacity is insufficient:
  - a new backing buffer is allocated with a larger capacity;
  - elements are copied into the new buffer;
  - the returned slice handle references the new storage;
  - slices that still reference the old storage remain valid but see only the old elements.

Append **always returns a new slice value**; code must assign the result to use the extended slice.

---

### 260.5.3 Reallocation and Aliasing Safety

Reallocation is safe by default, but developers must be aware of aliasing:

```ori
base []int := make([]int, 0, 2)
a := base
b := base

a = append(a, 1, 2)  // fills capacity; no reallocation
b[0] = 9             // both a and b see [9, 2]

a = append(a, 3)     // may reallocate; a now references new storage
// b still references the original backing storage
```

**Lifetime rule:** any `view []T` or `view T` into a slice’s storage must not be used after the underlying storage is released. The compiler:

- rejects obvious cases where a view could outlive its slice’s backing storage (e.g., views of temporaries);
- may conservatively reject code where it cannot prove that reallocation does not occur while a view is live.

---

### 260.5.4 Views of Slices

A slice can be converted to a read‑only view:

```ori
func sum(v view []int) int { /* ... */ }

func demo() {
    s []int := make([]int, 0, 8)
    s = append(s, 1, 2, 3)
    total := sum(view(s))   // OK
}
```

Rules:

- `view []T` cannot be used to mutate elements.
- operations that may reallocate or deallocate the underlying storage while a `view []T` is live are rejected when statically detectable.
- a `view T` to an individual element has the same lifetime constraints as any `view`.

---

### 260.5.5 Capacity Management

In addition to `append`, the standard library may offer:

- `reserve(slice[T], newCap int)` to grow capacity explicitly without changing length;
- `shrink_to_fit(slice[T])` to reduce capacity to `len`.

These functions are library‑level; the language semantics only require that:

- reallocation never changes existing element values;
- reallocation never changes the logical order of elements within the slice.

---

## 260.6 Ordered Maps: `map[K]V`

This section refines the ownership semantics of `map[K]V` as defined functionally in `110_Maps.md`.

### 260.6.1 Handle and Table

A `map[K]V` value is a handle to an internal ordered table structure:
- the table preserves **insertion order** for keys and values
- structural changes (insert/delete/clear) may reallocate or re‑organize the table internally
- the external iteration order remains in insertion order, even after growth or rehash.

Assigning or passing a map:
- copies the handle
- results in two map values that share the same underlying table.

---

### 260.6.2 Structural Mutations and Aliasing

Structural mutations:
- insert new keys
- delete existing keys
- clear the table
- may cause internal reallocation

Because map handles share storage, structural mutations are visible through all aliases:

```ori
m1 map[string]int = make(map[string]int)
m2 := m1

m1["a"] = 1
// m2["a"] is now 1 as well
```

The `clone` built‑in creates a new map with its own backing storage with identical contents and iteration order. The new map is therefore independant from the original map.

---

### 260.6.3 Views of Map Values

Lookup returns:
- **by value** in the normal `m[k]` or two‑value form
- optionally **by view**, via explicit APIs like `at_view(m, k) -> (view V, bool)` (library‑level)

If a view into a map value is provided:

- any structural mutation that could invalidate its location (e.g., delete, clear, growth or rehash) while the view is live is rejected when statically detectable
- deletion during iteration is a runtime error as specified in `110_Maps.md` (single‑writer iteration rule).

---

### 260.6.4 Iteration and Structural Safety

Iteration over a map uses insertion order and forbids structural mutation during iteration (insert/delete), enforced at runtime.

At the ownership level:
- iterators internally hold a view into the map’s table
- structural changes would invalidate this view, which is why they are treated as runtime errors
- non‑structural value updates are allowed because they do not invalidate layout

---

## 260.7 Hashmaps: `hashmap[K]V`

`hashmap[K]V` is a hash‑based dictionary container focused on throughput rather than deterministic iteration.

### 260.7.1 Properties

- hash‑based table with buckets and collision handling
- lookup, insert, delete are expected O(1) average case
- **iteration order is not specified** and may change across program runs, builds, or due to internal rehashing
- handle + backing storage model identical to `map[K]V` at a high level

---

### 260.7.2 Ownership and Aliasing

Assignment and parameter passing copy the handle and share backing storage, as with `map[K]V`.

Structural mutations (insert/delete/clear) may:
- rehash or resize the table
- move elements between buckets
- invalidate any internal views or iterators

As with maps, if the standard library offers view‑style APIs for hashmaps, their use is subject to the same lifetime rules: views must not outlive the underlying table and must not be used across structural mutations that could invalidate them.

---

### 260.7.3 Iteration

Hashmap iteration:
- is allowed via `for k, v := range h` syntax
- does not guarantee any particular ordering
- should not be relied upon for deterministic output or tests

If deterministic behavior is required, programs should use `map[K]V` or collect keys into a slice and sort them before iteration.

---

## 260.8 Container Ownership Rules (Unified)

### 260.8.1 Assignment and Parameter Passing

For all container types (`string`, `slice[T]`, `map[K]V`, `hashmap[K]V`):
- assignment copies the handle
- parameter passing copies the handle
- backing storage remains shared

To obtain an independent copy:
- use an explicit cloning function (`clone` for maps; similar helpers for other containers)
- or construct a new container and copy elements explicitly

---

## 260.9 Views, Aliasing, and Mutation Safety

### 260.9.1 General Rules

- A `view` never owns storage; it is tied to the lifetime of its source
- A container may be aliased through multiple handles and views simultaneously
- The compiler rejects obvious cases where a view would outlive its source container
- The language aims to ensure that no safe program observes a dangling view

---

### 260.9.2 Operations That May Invalidate Views

Potentially invalidating operations include:
- releasing or detaching the backing storage (container going out of scope when it is the last owner)
- `append` on slices when it triggers reallocation
- `clear`, `delete`, or growth that triggers table reallocation on maps or hashmaps
- container destruction during panic unwinding

The compiler:
- statically rejects simple patterns where such operations occur while a dependent view might still be used
- may conservatively reject code that is too complex to analyze soundly

---

### 260.9.3 Examples

Invalid view escape:

```ori
func bad_view_slice() view []int {
    s []int := make([]int, 0, 4)
    s = append(s, 1, 2, 3)
    return view(s)          // ❌ s’s backing storage is local
}
```

Valid borrowed view:

```ori
func head(v view []int) int {
    return v[0]
}

func demo() {
    s []int := make([]int, 0, 4)
    s = append(s, 1, 2, 3)
    h := head(view(s))      // OK: s outlives view
}
```

---

## 260.10 Deterministic Destruction Interaction

Container destruction integrates with deterministic destruction rules from `220_DeterministicDestruction.md`:

- when the last handle to a container’s backing storage is destroyed, the container’s destructor:
  - walks all elements, invoking their destructors (if any);
  - releases the backing storage
- views into that storage become invalid; any use of a view after its source container is destroyed is a compile-time error.
If the compiler cannot guarantee safety, it must reject the code

Containers held inside other containers or structs follow normal composition rules: destruction order is well‑defined and occurs from outer owner to inner fields.

---

## 260.11 Concurrency and Containers

Containers are subject to the concurrency and lifetime rules from `150_TypesAndMemory.md`.

### 260.11.1 Shared Containers

To share a container across tasks, it must be declared `shared`:
```ori
shared users map[string]int = make(map[string]int)
```

Rules:
- non‑`shared` containers cannot be passed to other tasks if they might be mutated there
- `shared` containers must be protected by synchronization primitives (mutexes, channels, etc.) for mutation
- `view` of a `shared` container is allowed for read‑only access, subject to lifetime rules

---

### 260.11.2 Views Across Tasks

`view` types are safe to send across tasks because they are read‑only, but:
- the source container must outlive all tasks using the view
- as with other cross‑task views, the creator must ensure the container is not destroyed before all tasks complete

Invalid:
```ori
func demo_bad() {
    s []int := make([]int, 0, 4)
    s = append(s, 1, 2, 3)
    spawn_task worker(view(s))   // ❌ s may be destroyed before worker finishes
}
```

Valid:
```ori
func demo_ok() {
    s []int := make([]int, 0, 4)
    s = append(s, 1, 2, 3)
    t := spawn_task worker(view(s))
    t.Wait()
}
```
---

### 260.11.3 Concurrent Structural Mutations

Structural mutations (append, insert, delete, clear, rehash) are not inherently thread‑safe:

- concurrent structural operations on the same container without synchronization are data races and undefined behavior
- this includes both maps and hashmaps, and slices whose backing storage is shared

To safely share mutable containers across tasks:

- confine mutation to a single owner task and communicate via messages or
- declare the container `shared` and guard all structural mutations with appropriate synchronization

---

## 260.12 Summary

- Containers are **handle + backing storage** values with reference semantics
- Assignment and parameter passing copy handles; storage is shared until explicitly cloned or moved.
- `string` is immutable; multiple strings may share storage safely
- `slice[T]` is a mutable window into contiguous storage; `append` may reallocate but never changes existing element values
- `map[K]V` is an ordered dictionary with deterministic **insertion order** iteration; `hashmap[K]V` is unordered and hash‑based
- `view` types never own storage and must not outlive their sources
- Operations that could invalidate live views are rejected when statically detectable; safe programs do not observe dangling views
- Containers obey the same deterministic destruction and concurrency rules as other Ori types, with additional care for structural mutations and aliasing

