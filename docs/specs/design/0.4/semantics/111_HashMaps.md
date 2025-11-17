# 111. HashMaps

HashMaps in Ori are **unordered**, associative collections that map unique keys to values using hashing.  
They are designed for **maximum performance**, **predictable memory control**, and **deterministic hash behavior** across builds.

---

## 111.1 Overview

A `hashmap[K]V` provides constant-time average lookups, insertions, and deletions.  
Unlike `map[K]V`, iteration order is **not guaranteed** — the internal order may differ from insertion order.

Example:

```ori
var counts hashmap[string]int = make(hashmap[string]int)
counts["apple"] = 5
counts["orange"] = 3
```

---

## 111.2 Philosophy and Guarantees

**Unordered iteration** — iteration order is undefined; may change between runs or insertions.  
**Explicit allocation** — created using `make`, optional capacity hint accepted.  
**Deterministic hashing** — Ori’s runtime uses stable hashing for reproducible builds (same input → same layout).  
**Fast-path performance** — optimized for O(1) average access.  
**No implicit synchronization** — not thread-safe; external synchronization required for concurrent access.  
**Explicit error handling** — lookup returns zero value if missing; two-value lookup form available.

---

## 111.3 Declaration and Initialization

```ori
var h hashmap[string]int = make(hashmap[string]int)
var h2 hashmap[string]int = make(hashmap[string]int, 1024) // with capacity hint
```

HashMaps must be explicitly allocated with `make` before use.  
A `nil` hashmap cannot be written to.

---

## 111.4 Supported Key Types

Same as `map[K]V` (see section 110.3):

- All **comparable** types (`bool`, integers, floats, strings, comparable structs/arrays).
- Floating-point rules apply: `NaN` is not allowed; `+0.0` == `-0.0`.

> Non-comparable types (e.g., slices, maps, functions) are invalid as keys.

---

## 111.5 Insertion, Access, and Update

```ori
h["apple"] = 10
h["banana"] = 20

var n int = h["apple"] // returns value (or zero value if missing)
```

Use the two-value form to check for existence:

```ori
var v int

v, ok := h["pear"]
if ok {
    fmt.Println("Found pear")
} else {
    fmt.Println("Not found")
}
```

---

## 111.6 Deletion

Remove entries with `delete`:

```ori
delete(h, "banana")
```

Deleting a non-existent key is safe and has no effect.

---

## 111.7 Iteration

HashMaps are **unordered** — iteration order is intentionally unspecified:

```ori
for k, v := range h {
    fmt.Println(k, v) // order is arbitrary
}
```

> The iteration order may differ between runs and should not be relied upon for deterministic output.

To obtain a deterministic ordering, extract keys and sort them manually:

```ori
var ks []string = keys(h)
sort(ks)
for _, k := range ks {
    fmt.Println(k, h[k])
}
```

---

## 111.8 Built-in Functions

Ori provides a compact set of built-ins for hashmaps:

| Function | Signature | Behavior |
|----------|------------|-----------|
| `make` | `make(hashmap[K]V [, capacity]) -> hashmap[K]V` | Allocates new hashmap. |
| `len` | `len(h hashmap[K]V) -> int` | Number of entries. |
| `cap` | `cap(h hashmap[K]V) -> int` | Returns internal capacity hint. |
| `delete` | `delete(h hashmap[K]V, k K)` | Removes key `k`. |
| `clear` | `clear(h hashmap[K]V)` | Removes all entries, retains capacity. |
| `keys` | `keys(h hashmap[K]V) -> []K` | Returns keys (unordered). |
| `values` | `values(h hashmap[K]V) -> []V` | Returns values (unordered). |
| `clone` | `clone(h hashmap[K]V) -> hashmap[K]V` | Creates an independent copy of the hashmap. |

---

## 111.9 Nil and Empty HashMaps

A nil hashmap has no backing storage:

```ori
var h hashmap[string]int
fmt.Println(h == nil) // true
```

Any write to a nil hashmap triggers a **runtime error**.  
Always allocate hashmaps using `make()`.

---

## 111.10 Memory and Growth

HashMaps expand automatically as elements are inserted.  
Rehashing preserves key-value pairs but not bucket order.  
Growth is **amortized O(1)**; capacity may double on expansion.  
`cap(h)` reports the internal bucket count (for tuning, not iteration).

---

## 111.11 Concurrency

HashMaps are **not thread-safe**. Concurrent reads and writes without synchronization cause undefined behavior.

For concurrent access:
- Protect the hashmap with a **mutex** or synchronization primitive.
- Use **message-passing** between goroutines/tasks.
- Use a **read-only clone** for safe sharing.

Future versions may include `sync.hashmap` for concurrent use cases.

---

## 111.12 Deterministic Hashing

Ori’s hashmaps use **deterministic, stable hashing** to ensure reproducible builds.  
Hash seeds are fixed per build target, so serialized or iterated outputs are consistent across executions.

Optional compiler flags may enable **randomized hashing** for security-sensitive environments.

---

## 111.13 Examples

### Basic usage

```ori
var h hashmap[string]int = make(hashmap[string]int)
h["a"] = 1
h["b"] = 2

fmt.Println(len(h)) // 2

if _, ok := h["c"]; !ok {
    fmt.Println("missing key c")
}

delete(h, "a")
```

### Unordered iteration

```ori
for k, v := range h {
    fmt.Println(k, v) // order not guaranteed
}
```

### Cloning

```ori
var copy hashmap[string]int = clone(h)
```

---

## 111.14 Future Extensions

- Specialized `hashmap_fast` for primitive keys (integer-indexed buckets).
- Lock-free concurrent hashmaps.
- Custom hash function hooks for user-defined key types.
- On-disk hashmaps for persistent storage.

---

## References
- [110_Maps.md](semantics/110_Maps.md)
- [050_Types.md](syntax/050_Types.md)
