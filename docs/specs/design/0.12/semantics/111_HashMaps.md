# 111. HashMaps

## 111.1 Overview

A `hashmap[K]V` is an **unordered dictionary** mapping unique keys of type `K` to values of type `V` using hash-based indexing.

Unlike `map[K]V`, a `hashmap[K]V` does **not** preserve insertion order.  
Iteration order is **unspecified**, but always **deterministic** for a given container state.

Hashmaps are **mutable containers** and follow the rules of `260_ContainerOwnershipModel.md`.

---

## 111.2 Construction

Hashmaps must be constructed explicitly:

```ori
var h hashmap[string]int = make(hashmap[string]int)
```

A literal form is allowed:

```ori
var h = hashmap[int]string{
    1: "one",
    2: "two",
}
```

Iteration order of literals is **unspecified**, even though the literal lists keys in a specific order.

`nil` hashmaps cannot store values:

```ori
var h hashmap[string]int = nil
h["x"] = 1    // ❌ compile-time error
```

---

## 111.3 Hashing and Determinism

Hashmaps rely on hashing internally. Ori guarantees:

### Rule 1 — Hashing is deterministic across all executions  
The same key always produces the same hash value across runs.

### Rule 2 — Hashing is deterministic across platforms  
Hash("a") is identical on:
- Linux x64
- macOS ARM
- Windows x64

### Rule 3 — Hashing is deterministic across compiler versions  
Unless explicitly changed in a major version with migration notes.

### Rule 4 — Hash collisions are resolved in a deterministic way  
Different keys hashing to the same bucket are handled in a stable, reproducible manner.

These rules ensure:
- reproducible builds  
- deterministic tests  
- predictable debugging  

Ori **never** uses randomized hash seeds.

---

## 111.4 Iteration (Unordered Yet Deterministic)

Iteration order is **unspecified**, but obeys strict rules:

1. The order is **deterministic for the current container state**.  
2. A mutation (insert/delete) may change iteration order.  
3. Resizing or rehashing may change iteration order.  
4. The same sequence of operations produces the same iteration order in all executions.

Example:

```ori
for k, v := range h {
    print(k, v)
}
```

No guarantees are made about the actual sequence of keys, only that the order is deterministic, stable, and repeatable.

---

## 111.5 Insert or Overwrite

```ori
h[key] = value
```

Rules:
- If `key` is new → inserted into a bucket based on its hash  
- If `key` exists → value replaced, bucket position unchanged  

Unlike `map[K]V`, hashmaps do **not** maintain insertion order metadata.

---

## 111.6 Lookup

```ori
value = h[key]
value, ok = h[key]
```

Lookups do not affect iteration order.

---

## 111.7 Deletion

```ori
delete(h, key)
```

Effects:

- If `key` exists → removed from its bucket  
- Iteration order may change due to internal rebalancing  
- Future insertions may reuse deleted slots  

---

## 111.8 Copy and Aliasing

Hashmaps behave like all containers in Ori:

```ori
var a = make(hashmap[string]int)
a["x"] = 1

var b = a   // aliasing
b["y"] = 2

// a["y"] == 2
// b["x"] == 1
```

Assignment copies the handle, not the storage.

---

## 111.9 Cloning (Shallow)

Ori provides:

```ori
func CloneHashMap[K, V](src hashmap[K]V) hashmap[K]V
```

This performs a **shallow clone**:

- new independent backing table  
- keys and values copied by assignment  
- nested containers are **not deep-cloned**  

Deep cloning must be implemented by the developer as specified for `maps`.

---

## 111.10 Deterministic Destruction

When the last handle referencing a hashmap dies:

- all keys and values are destroyed
- destruction order is **unspecified** but deterministic for the container state
- matches the rules of `220_DeterministicDestruction.md`

Hashmaps do not expose a stable iteration order, so destruction order is intentionally unspecified.

---

## 111.11 Concurrency

Hashmaps are not thread-safe.

Rules:
- Concurrent writes are undefined behavior and may cause compile-time errors
- Reads are safe only when no concurrent writes occur
- Shared hashmaps require explicit synchronization

---

## 111.12 Examples

### 111.12.1 Basic Usage

```ori
var h hashmap[string]int = make(hashmap[string]int)

h["a"] = 1
h["b"] = 2

for k, v := range h {
    print(k, v)
}
// Output order is unspecified but deterministic.
```

### 111.12.2 Overwrite

```ori
h["a"] = 10
```

### 111.12.3 Delete

```ori
delete(h, "b")
```

### 111.12.4 Clone

```ori
var clone = CloneHashMap(h)
clone["x"] = 99
```
