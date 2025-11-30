# 110. Maps

Maps in Ori are **ordered**, associative collections that map unique keys to values.  
They prioritize **determinism, explicit allocation, and safety** in line with Ori’s design principles.

---

## 110.1 Philosophy and Guarantees

**Ordered iteration** — iteration over a map yields entries in **insertion order**.  
**Deterministic behavior** — rehashing or growth never changes the logical order.  
**Explicit allocation** — creation uses `make`, optional initial capacity may be provided.  
**No hidden magic** — two-value lookup for existence; deletions are explicit; no implicit defaults.  
**Single-writer iteration rule** — structural changes (insert/delete) during iteration are **not allowed** (runtime error). Value updates to existing keys are allowed.

---

## 110.2 Declaration and Initialization

A map type is written as `map[K]V`, where `K` and `V` are valid types for keys and values.

```ori
var users map[string]int
```

Maps must be created before use using `make`:

```ori
var users map[string]int = make(map[string]int)           // default capacity
var ages  map[string]int = make(map[string]int, 128)      // with initial capacity
```

---

## 110.3 Supported Key Types (Comparability Defined)

**Keys must be comparable**, i.e., the type supports `==` and `!=` with a **total, deterministic equivalence relation**.

### 110.3.1 Comparable key types
- **Booleans**: `true`, `false`.
- **Integers**: all signed/unsigned integer types.
- **Floating-point**: allowed with constraints (see below).
- **Strings**: lexicographic equality by content (UTF‑8).
- **Arrays**: elementwise comparison; valid if element type is comparable.
- **Structs**: fieldwise comparison; valid if **all fields** are comparable.
- **Enums / distinct named integer types**: compared by underlying value.

### 110.3.2 Non-comparable key types
- **Slices** and **maps** (reference/aggregate types).
- **Function values** and **opaque handles**.
- **Structs** containing any non-comparable field.

### 110.3.3 Floating-point as keys
- `NaN` is **not allowed** as a key (runtime error on insertion or comparison path).
- `+0.0` and `-0.0` are considered **equal** keys.
- Equality uses IEEE‑754 semantics with the above normalizations for map keys.

> Rationale: keys require a stable, total equivalence; `NaN` breaks transitivity.

---

## 110.4 Insertion, Access, and Update

```ori
var users map[string]int = make(map[string]int)

users["Alice"] = 42          // insert (appended in order)
users["Alice"] = 43          // update (order unchanged)

var age int = users["Alice"] // lookup
```

### Missing-key lookup
- If a key does **not** exist, the expression `m[k]` returns the **zero value** of `V`.
- To distinguish “missing” from “present with zero value”, use the **two-value** form (see §110.5).

---

## 110.5 Existence Check

Use the two-value form to test whether a key is present:

```ori
var age int

age, ok := users["Bob"]
if ok {
    fmt.Println("Found:", age)
} else {
    fmt.Println("Missing")
}
```

`ok` is `true` only if the key existed at lookup time.

---

## 110.6 Deletion

Remove a key with `delete`:

```ori
delete(users, "Alice")
```

Deleting a non-existent key is a no-op.  
Deletion **removes** the key from the order; reinserting the same key appends it at the **end**.

---

## 110.7 Iteration (Ordered) and Mutation Rules

Maps are iterated in **insertion order**:

```ori
for k, v := range users {
    fmt.Println(k, v)
}
```

### 110.7.1 What is prohibited during iteration
**Structural mutation** (inserting or deleting keys) while iterating the same map is a **runtime error**:

```ori
for k, v := range users {
    users["z"] = 9        // ❌ runtime error (insert during iteration)
}
```

```ori
for k, v := range users {
    delete(users, k)      // ❌ runtime error (delete during iteration)
}
```

### 110.7.2 What is allowed during iteration
Updating values of **existing keys** is allowed:

```ori
for k, v := range users {
    users[k] = v + 1      // ✅ value update only
}
```

If structural changes are needed, first collect operations, then apply them **after** the loop.

---

## 110.8 Built-in Map Functions

Ori provides a minimal, explicit set of built-ins for maps:

| Function | Signature | Behavior |
|----------|-----------|----------|
| `make` | `make(map[K]V [, capacity]) -> map[K]V` | Allocate a new map, optionally reserving capacity. |
| `len` | `len(m map[K]V) -> int` | Number of entries. |
| `cap` | `cap(m map[K]V) -> int` | Implementation hint: reserved bucket capacity (may be ≥ `len`). |
| `delete` | `delete(m map[K]V, k K)` | Remove key `k` if present. |
| `clear` | `clear(m map[K]V)` | Remove all entries, preserving capacity. |
| `keys` | `keys(m map[K]V) -> []K` | Returns keys in **insertion order**. |
| `values` | `values(m map[K]V) -> []V` | Returns values in **insertion order**. |
| `items` | `items(m map[K]V) -> []struct{key: K, value: V}` | Snapshot of entries in insertion order. |
| `clone` | `clone(m map[K]V) -> map[K]V` | Deep copy preserving insertion order. |

> `cap(m)` is informational and may help tuning. `clear` avoids reallocation when reusing a map.

---

## 110.9 Comparison and Equality

Maps cannot be compared directly, only to `nil`:

```ori
if users == nil {
    fmt.Println("uninitialized")
}
```

Content equality requires an explicit comparison, e.g. via a standard library helper (not a built-in).

---

## 110.10 Passing Maps to Functions

Maps are passed **by value**, but the value contains a reference to shared internal data.  
Thus, modifying a map within a function affects the caller’s map.

```ori
func add(m map[string]int, key string, val int) {
    m[key] = val
}
```

Use `clone` to obtain an independent copy:

```ori
var copy map[string]int = clone(users)
```

---

## 110.11 Nil Maps

A `nil` map has no backing table:

```ori
var m map[string]int
fmt.Println(m == nil) // true
```

Writing to a `nil` map is a runtime error. Always `make()` maps before use.

---

## 110.12 Memory and Growth

Maps grow dynamically as elements are added.  
Growth **does not** change the iteration order.  
Existing references to keys remain valid; iterators are invalidated only if structure is mutated during iteration (runtime error).

---

## 110.13 Concurrency

Maps are **not thread-safe by default**. Access from multiple threads/goroutines requires synchronization.

**Use one of the following patterns:**
- Guard the map with a **mutex** (read/write lock if supported by the standard library).
- Confine the map to a **single owner** task and communicate via channels/messages.
- Use **immutable snapshots** (e.g., `clone`) for read-only sharing.

Concurrent reads/writes without synchronization are **data races** and undefined behavior.

---

## 110.14 Examples

### Ordered Behavior

```ori
var m map[string]int = make(map[string]int)
m["a"] = 1
m["c"] = 3
m["b"] = 2

for k, v := range m {
    fmt.Println(k, v) // prints: a 1, c 3, b 2  (in insertion order)
}

delete(m, "c")
m["c"] = 30

// Now order is: a, b, c
for k, v := range m {
    fmt.Println(k, v)
}
```

### Built-ins

```ori
var m map[string]int = make(map[string]int, 4)
m["x"] = 1
m["y"] = 2

var ks []string = keys(m)      // ["x", "y"]
var vs []int    = values(m)    // [1, 2]
var it = items(m)              // [{key:"x", value:1}, {key:"y", value:2}]

clear(m)                       // m is now empty, capacity retained
```

### Iteration mutation examples

```ori
// ❌ Prohibited: insert during iteration
for k, v := range m {
    m["z"] = 9
}

// ❌ Prohibited: delete during iteration
for k, v := range m {
    delete(m, k)
}

// ✅ Allowed: update value of existing key
for k, v := range m {
    m[k] = v + 1
}
```

---

## References
- [Types](syntax/050_Types.md)
- [Expressions](syntax/070_Expressions.md)
