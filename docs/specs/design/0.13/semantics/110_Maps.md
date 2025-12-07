# 110. Maps

## 110.1 Overview

A `map[K]V` is an **ordered dictionary** mapping unique keys of type `K` to values of type `V`.

- **Insertion order is preserved**.
- Lookup, insertion, and deletion are **amortized O(1)**.
- Maps are **mutable containers** and follow the rules of  
  `260_ContainerOwnershipModel.md`.

Maps store keys exactly as provided; there is **no reordering**, and **resizing never disturbs iteration order**.

---

## 110.2 Construction

Maps must be constructed explicitly:

```ori
var m map[string]int = make(map[string]int)
```

`nil` maps cannot store values:

```ori
var m map[string]int = nil
m["x"] = 1    // ❌ compile-time error
```

A literal form is allowed:

```ori
var m = map[int]string{
    1: "one",
    2: "two",
}
```

Literal ordering defines insertion order.

---

## 110.3 Insertion Order (Deterministic)

Ori guarantees:

### Rule 1 — The order of iteration is exactly insertion order.

Given:

```ori
m["a"] = 1
m["b"] = 2
m["c"] = 3
```

Iteration:

```
a → b → c
```

### Rule 2 — Reinserting an existing key does NOT change its position

```ori
m["b"] = 5
```

Order remains:

```
a → b → c
```

### Rule 3 — Deleting a key preserves the relative order of remaining keys

```ori
delete(m, "b")
```

Now order is:

```
a → c
```

### Rule 4 — Internal growth / reallocation preserves insertion order

Even if the map grows and allocates new storage, iteration order is unchanged.

This is a semantic guarantee, not an implementation detail.

---

## 110.4 Hashing and Determinism

Ori maps use hashing internally, but:

### 1. Hashing must be deterministic across all executions  
No per-run random seeds, no randomized iteration.

### 2. Hashing must be deterministic across platforms  
Hash("hello") must be equal on:

- Linux x64
- macOS ARM
- Windows x64

### 3. Hashing must be deterministic across compiler versions  
Unless explicitly documented in a major version bump.

### 4. Hash collisions are resolved in a deterministic way  
Iteration order is fully independent of internal hash table arrangements.

This allows:
- reproducible builds
- test determinism
- stable debugging
- no "map nondeterminism surprises"

---

## 110.5 Lookup

Standard rules:
```ori
value = m[key]
value, ok = m[key]
```

Lookups do not change iteration order.

---

## 110.6 Insert or Overwrite

```ori
m[key] = value
```

- If `key` is new → append to insertion list
- If `key` exists → replace `value`, position unchanged

---

## 110.7 Deletion

```ori
delete(m, key)
```

Effects:

- If present → remove the key/value pair
- Order of remaining keys is unchanged
- Future insertions append at the end

Deleting and reinserting restores key at *end*, not original position.

---

## 110.8 Copy and Aliasing

Assignment copies the **handle**, not the backing storage:

```ori
var a = make(map[string]int)
a["x"] = 1

var b = a    // aliasing
b["y"] = 2

// Now both a["y"] and b["y"] == 2
```

This matches all other containers in Ori.

---

## 110.9 Cloning

Clone must be explicit:
```ori
func CloneMap[K, V](src map[K]V) map[K]V {
    var out = make(map[K]V)
    for k, v := range src {
        out[k] = v
    }
    return out
}
```

Cloning:
- creates independent storage
- preserves insertion order
- does not clone values deeply unless user does so

---

## 110.10 Shallow vs Deep Cloning

Ori provides a standard library function for cloning maps:
```ori
func CloneMap[K, V](src map[K]V) map[K]V
```

This function performs a shallow clone of the map. Understanding the distinction between shallow clone and deep clone is essential for correct usage.

## 110.10.1 Shallow Cloning

A shallow clone creates a new map with its own independent internal storage, but keys and values are copied by assignment according to the semantics of their types.

Example:
```ori
var m1 = make(map[string][]int)
m1["a"] = []int{1, 2}

var m2 = CloneMap(m1)
m2["a"][0] = 99
```

Result:
- `m1` and `m2` do not share the same map container.
- but `m1["a"]` and `m2["a"]` alias the same slice, because assignment of slices copies the handle, not the underlying storage.

This behavior is intentional and consistent with Ori’s `260_ContainerOwnershipModel.md`.

---

## 110.10.2 Deep Cloning

A `deep clone` recursively duplicates all nested containers and values.

For example:
- slices inside a map would be cloned element-by-element
- maps inside maps would be recursively cloned
- user-defined structs might need their own clone semantics
- references, external resources, or handles might require special handling

Because deep cloning requires type-specific rules and may involve unbounded, implicit allocations, Ori does not define or perform deep cloning automatically.

Example of manual deep cloning:
```ori
func DeepCloneMap(sliceMap map[string][]int) map[string][]int {
    var out = make(map[string][]int)
    for k, v := range sliceMap {
        var clone = make([]int, len(v))
        copy(v, clone)
        out[k] = clone
    }
    return out
}
```

## 110.10.3 Why Ori Does Not Provide Automatic Deep Cloning

Ori deliberately does not offer deep cloning for these reasons:
- **Correct semantics are type-dependent**
  - A deep clone of a file descriptor, mutex, channel, or handle is either meaningless or unsafe.
- **Hidden allocations violate Ori’s explicitness philosophy**
  - Deep clone may recursively allocate large amounts of memory without the programmer being aware
- **Performance ambiguity**
  - Deep cloning can accidentally become O(N²) or worse on nested structures
- **No global rule applies to all values**
  - Should a pointer be cloned or shared?
  - Should a StringBuilder be duplicated or aliased?
  - Should a map inside a struct be shallow-cloned or deep-cloned?
  - Ori cannot make correct assumptions
- **Deterministic destruction becomes unclear**
  - Automatically duplicating nested containers complicates destruction order and memory guarantees defined in `220_DeterministicDestruction.md`.
- **Predictability and simplicity**
  - Shallow cloning is easy to explain, easy to reason about, and follows the same semantics as all other containers (slices, maps, hashmaps, StringBuilder, etc.).

---

## 110.11 Deterministic Destruction

When the last handle referencing a map dies:

- all keys and values are dropped  
- deterministic destruction order: in insertion order  
- consistent with `220_DeterministicDestruction.md`

---

## 110.12 Concurrency

Maps are not thread-safe.

Rules:
- Concurrent writes → undefined behavior and compile-time warning if detectable  
- Reads are safe only if no concurrent writes  
- Shared maps must be protected by synchronization primitives  

---

## 110.13 Examples

### 110.13.1 Basic Usage

```ori
var m map[string]int = make(map[string]int)

m["a"] = 1
m["b"] = 2

for k, v in m {
    print(k, v)
}
// Output: a 1, b 2
```

### 110.13.2 Overwriting a Key

```ori
m["a"] = 10
// Order remains: a → b
```

### 110.13.3 Deleting a Key

```ori
delete(m, "a")
// Order: b
```

### 110.13.4 Cloning a Map

```ori
var original = make(map[string]int)
original["x"] = 1
original["y"] = 2

var clone = CloneMap(original)
clone["x"] = 99

// original["x"] == 1
// clone["x"] == 99
```
