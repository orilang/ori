# 360. StringBuilder

## 360.1 Overview

`StringBuilder` is a mutable, growable text builder type provided by the Ori standard library.  
It is designed for efficient construction of `string` values without creating many intermediate temporary strings.

`StringBuilder`:
- owns a growable `[]byte` buffer internally
- supports appending textual data (strings and bytes)
- can be reset and reused
- produces immutable `string` values via `String()`

It follows the same ownership, aliasing, and deterministic destruction rules as other Ori containers described in `260_ContainerOwnershipModel.md`.

`StringBuilder` lives in the standard library (for example, in a `strings`-like package), but this document specifies its language-level semantics.

---

## 360.2 Type Definition and Invariants

The core definition of `StringBuilder` is:
```ori
type struct StringBuilder {
    buf []byte   // unexported; may be nil or a valid slice
}
```

### 360.2.1 Invariants

At all times, a `StringBuilder` value obeys the following invariants:
- `buf` is either:
  - `nil`, meaning the builder is empty and has no allocated storage yet, or
  - a valid `[]byte` slice whose elements are initialized bytes
- `len(buf)` is the number of bytes currently in the builder
- `cap(buf)` is the capacity of the builder’s internal buffer
- The first `len(buf)` bytes of `buf` represent the logical contents of the builder
- Operations on a builder never expose uninitialized bytes

`StringBuilder{}` is the canonical empty builder:
```ori
var b StringBuilder = StringBuilder{}  // ✔ empty, valid, buf == nil
```

Declaring a StringBuilder without explicit initialization is a compile-time error:
```ori
var b StringBuilder   // ❌ compile-time error (struct must be explicitly initialized)
```

The literal `StringBuilder{}` uses the default value nil for the internal []byte field,
and the first write to the builder allocates internal storage as needed.

---

## 360.3 Construction

### 360.3.1 Zero-Value Construction

The simplest way to obtain a builder is to explicitly initialize it:
```ori
var b StringBuilder                   // compile-time error
var b StringBuilder = StringBuilder{} // empty, valid
b.WriteString("hello")
```

The zero value must behave identically to a builder obtained from any constructor.

### 360.3.2 Explicit-Capacity Constructors (Standard Library)

The standard library may provide helper constructors such as:
```ori
// In a standard library package, conceptually:
func NewStringBuilder() StringBuilder
func NewStringBuilderWithCap(cap int) StringBuilder
```

Semantics:
- `NewStringBuilder()` returns an empty builder with unspecified initial capacity.
- `NewStringBuilderWithCap(cap int)` returns an empty builder with at least `cap` bytes of capacity.
  - If `cap < 0`, the function must panic with a clear error message.

These helpers are library-level conveniences and do not introduce new language syntax.

---

## 360.4 Methods and Signatures

All mutating methods on `StringBuilder` use a **`shared` receiver** to reflect Ori’s container semantics and make aliasing explicit.

### 360.4.1 WriteString

```ori
func (b shared StringBuilder) WriteString(s string)
```

Appends the contents of `s` to the builder.

Semantics:
- If `len(s) == 0`, the method does nothing.
- If `len(buf) + len(s) <= cap(buf)`, the existing buffer is reused.
- Otherwise, a new backing buffer is allocated with greater capacity, existing bytes are copied, and `buf` is updated to reference the new storage.
- No trailing NUL byte is added; the builder stores raw bytes.

### 360.4.2 WriteByte

```ori
func (b shared StringBuilder) WriteByte(c byte)
```

Appends the single byte `c` to the builder.

Semantics:
- Equivalent to `WriteBytes([]byte{c})` but may be more efficient.
- Grows the buffer as needed using the same rules as `WriteString`.

### 360.4.3 WriteBytes

```ori
func (b shared StringBuilder) WriteBytes(data []byte)
```

Appends the contents of `data` to the builder.

Semantics:
- If `len(data) == 0`, the method does nothing.
- Appends the bytes of `data` exactly, without copying or modifying `data` itself.
- Allocation and growth follow the same rules as `WriteString`.

### 360.4.4 Reset

```ori
func (b shared StringBuilder) Reset()
```

Resets the builder to be empty.

Semantics:

- After `Reset()`, `len(b.buf) == 0`.
- Implementations **may** keep the current capacity to allow reuse:
  - `cap(b.buf)` is implementation-defined but typically unchanged.
- The contents of any previously returned `string` values remain valid and are not affected by `Reset()`.

### 360.4.5 Len

```ori
func (b StringBuilder) Len() int
```

Returns the number of bytes currently stored in the builder.

Semantics:
- `Len()` is pure and does not modify the builder.
- `Len()` always equals `len(b.buf)`.

### 360.4.6 Cap

```ori
func (b StringBuilder) Cap() int
```

Returns the capacity of the builder’s internal buffer.

Semantics:
- `Cap()` is pure and does not modify the builder.
- `Cap()` always equals `cap(b.buf)` when `buf` is non-nil; for a zero-value builder, `Cap()` returns `0`.

### 360.4.7 Grow

```ori
func (b shared StringBuilder) Grow(n int)
```

Ensures that the builder can append at least `n` additional bytes without further allocation.

Semantics:
- If `n <= 0`, `Grow` does nothing.
- Otherwise, it ensures that `cap(b.buf) - len(b.buf) >= n`.
- If the current capacity is already sufficient, no allocation occurs.
- If `n` is too large to satisfy due to implementation limits, `Grow` must panic with a clear error.

`Grow` is an optimization; it does not change `Len()`.

### 360.4.8 String

```ori
func (b shared StringBuilder) String() string
```

Returns a `string` containing a copy (or immutable view) of the builder’s contents.

Semantics:
- The returned `string` contains the bytes of `b.buf[0:len(b.buf)]` interpreted as UTF‑8 (or raw bytes if the caller
  uses the builder for non-text data).
- Future writes to `b` do **not** modify previously returned strings.
- Implementations are free to reuse internal buffers where safe, but must preserve the immutability guarantees of `string`.

---

## 360.5 Ownership, Aliasing, and Deterministic Destruction

`StringBuilder` follows the general container rules from `260_ContainerOwnershipModel.md`:

### 360.5.1 Handle + Backing Storage

- A `StringBuilder` value is a small handle (struct) that contains a `[]byte` field.
- The `[]byte` slice itself is a handle to heap-allocated backing storage for the builder’s bytes.
- Copying a `StringBuilder` value copies the slice handle; backing storage is shared between copies.

Example:
```ori
var a StringBuilder = StringBuilder{}
a.WriteString("hello")

var b = a      // b aliases the same internal buffer as a
b.WriteByte('!')

// Now both a and b logically contain "hello!" because they share `buf`.
```

### 360.5.2 Cloning

If an independent builder is required, the caller must clone explicitly:
```ori
func CloneBuilder(src StringBuilder) StringBuilder {
    var out StringBuilder = StringBuilder{}
    if src.Len() == 0 {
        return out
    }

    // allocate an independent buffer
    outBuf := make([]byte, src.Len())
    copy(src.buf, outBuf)
    out.buf = outBuf
    return out
}
```

The standard library may provide such a helper, but cloning is deliberately explicit.

### 360.5.3 Deterministic Destruction

When the last live `StringBuilder` handle referencing a given backing buffer is destroyed:
- The backing buffer is deallocated according to the same rules as any `[]byte` slice
- Elements (bytes) do not have destructors, so destruction is constant-time
- All previously returned `string` values are unaffected, as they are immutable and may use independent storage

Builders stored inside other structs or containers are destroyed as part of those owners’ deterministic destruction
sequence, as specified in `220_DeterministicDestruction.md`.

---

## 360.6 Interaction with `string` and `[]byte`

### 360.6.1 From Builder to String

`String()` is the canonical way to obtain a `string` from a builder.

- Multiple calls to `String()` are allowed.
- Each call returns a `string` that is logically independent of future mutations of the builder.
- Implementations may share storage internally as long as no mutation of the builder can affect any existing `string`.

### 360.6.2 Using Builder as a Byte Buffer

Although intended for textual data, `StringBuilder` can also be used as a generic byte accumulator.

Example:
```ori
var b StringBuilder = StringBuilder{}
b.WriteBytes([]byte{0x01, 0x02, 0x03})
b.WriteByte(0xFF)
```

The semantics are identical; `String()` will interpret the bytes as they are.

### 360.6.3 No Direct `Bytes()` View

Ori does **not** provide a `Bytes()` method that returns a `[]byte` view of the builder’s internal buffer.
This avoids subtle aliasing and mutation pitfalls where callers could hold onto a slice that becomes invalid when the builder grows or is reset.

If a byte slice is needed, the caller can copy explicitly:
```ori
var data []byte = make([]byte, b.Len())
copy(b.buf, data)   // library helper may be provided
```

A future version may introduce a `BytesCopy()` helper that returns a copied `[]byte`.

---

## 360.7 Concurrency

`StringBuilder` is **not** intrinsically thread-safe:
- A builder must not be mutated concurrently from multiple tasks without synchronization
- To share a builder across tasks, it must be declared `shared` and protected by a mutex or other synchronization primitive, following the same rules as other containers
- It is safe to read from a builder (via `Len()`, `Cap()`, `String()`) while no concurrent writes are occurring

Example (invalid):
```ori
func worker(b StringBuilder) {
    b.WriteString("x")   // ❌ concurrent mutation without synchronization
}

func test() {
    var b shared StringBuilder = StringBuilder{}
    t := spawn_task worker(b)
    result, err := t.Wait()
}
```

Example (valid, conceptually):
```ori
func worker(b StringBuilder) {
    var mu sync.Mutex
    mu.Lock()
    b.WriteString("x")
    mu.Unlock()
}

func test() {
    var b shared StringBuilder = StringBuilder{}
    t := spawn_task worker(b)
    result, err := t.Wait()
}
```

The exact synchronization primitives are defined elsewhere in the standard library, but the general rule remains:
`StringBuilder` obeys the same concurrency constraints as other mutable containers.

---

## 360.8 Examples

### 360.8.1 Basic Usage

```ori
func BuildGreeting(name string) string {
    var b StringBuilder = StringBuilder{}

    b.WriteString("Hello, ")
    b.WriteString(name)
    b.WriteString("!")

    return b.String()
}
```

### 360.8.2 Reuse with Reset

```ori
func DemoReuse() {
    var b StringBuilder = StringBuilder{}

    b.WriteString("first")
    s1 := b.String()

    b.Reset()
    b.WriteString("second")
    s2 := b.String()

    // s1 == "first"
    // s2 == "second"
}
```

### 360.8.3 Explicit Growth

```ori
func BuildMany(names []string) string {
    var b StringBuilder = StringBuilder{}

    // Reserve a rough capacity to avoid repeated allocations.
    // For example, assume ~16 bytes per name.
    b.Grow(len(names) * 16)

    for i, name := range names {
        if i > 0 {
            b.WriteString(", ")
        }
        b.WriteString(name)
    }

    return b.String()
}
```

### 360.8.4 Aliasing Behavior

```ori
func DemoAlias() {
    var a StringBuilder = StringBuilder{}
    a.WriteString("x")

    var b = a       // a and b alias the same buffer
    b.WriteString("y")

    s1 := a.String()
    s2 := b.String()

    // Both s1 and s2 are "xy".
}
```

---

## 360.9 Summary

- `StringBuilder` is a standard library struct that owns a growable `[]byte` buffer
- StringBuilder{} represents an empty builder.
- Declaring a StringBuilder without initialization is a compile-time error (per 130_Structs.md).
- Mutating methods use a `shared StringBuilder` receiver and follow Ori’s container semantics
- `String()` produces immutable `string` values that are not affected by subsequent mutations
- Ownership, aliasing, and deterministic destruction mirror the general container rules
- No `Bytes()` view is provided to avoid aliasing pitfalls; callers copy explicitly when needed
- `StringBuilder` is not thread-safe by default and must be synchronized when shared across tasks
