# 230 Interfaces.md

## 230.1 Interfaces – Overview

Interfaces describe **behavior** via required method signatures.  
Implementation is always **explicit** using:

```
Type implements Interface
```

Ori supports:

- **Static dispatch** (via generic constraints)
- **Dynamic dispatch** (via interface-typed values)

Interface values are represented as **(data pointer + vtable pointer)**.  
They **do not own** the underlying object; they are non‑owning views.

---

## 230.2 Interface Declarations

### 230.2.1 Syntax

```
type interface Greeter {
    greet() string
    identify() string
}
```

**Constraints:**
- Only **method signatures** allowed inside an `interface` block.
- Fields are forbidden.
- Default method bodies are forbidden (e.g., `Write(...) int { ... }`).
- Method signatures follow normal function/method rules.

### 230.2.2 Method signature matching

For each method `M` in interface `I`:

- Name must be unique within `I`
- Full signature must match:
  - name
  - parameter list types
  - result list types

The implementing type must provide a matching method (receiver rules defined in `170_MethodsAndInterfaces.md`).

---

## 230.3 Method Sets and Interface Requirements

Ori reuses **method sets** from `170_MethodsAndInterfaces.md`.  
A type `T` implements interface `I` **if**:
- The method set of `T` contains a matching method for every method in `I`.

**Compiler rule:**

> To check `T implements I`:
> - build the method set of `T`
> - ensure that every `I.M` exists in `T` with a matching signature

If any method is missing or mismatched, compilation fails at the `implements` declaration.

---

## 230.4 Explicit Implementation Declarations

### 230.4.1 Basic form

```
type interface Writer {
    Write(p []byte) int
}

type struct File {
    Path string
}

File implements Writer
```

**Semantics:**
- Implementation is **explicit**
- Declaration must appear at file scope.
- At most **one** `Type implements Interface` per pair.

### 230.4.2 Multiple interfaces

```
File implements Reader
File implements Writer
```

- Each clause is checked independently.
- If two interfaces require the **same method name** with **different signatures**, compilation fails.

### 230.4.3 Allowed types

Any **named type** with a method set may implement an interface:
```
MyStruct implements SomeInterface
MySum    implements AnotherInterface
```

Pointer, alias, and sum‑type method‑set rules come from `170_MethodsAndInterfaces.md`.

---

## 230.5 Interface Composition

### 230.5.1 Syntax

```
type interface Reader {
    Read(p []byte) int
}

type interface Writer {
    Write(p []byte) int
}

type interface ReadWriter {
    Reader
    Writer
}
```

The method set of `ReadWriter` is the **union** of `Reader` and `Writer`.

Composition is **shallow**; no new semantics added; conflicts cause compile-time errors.

### 230.5.2 Conflict handling

```
type interface A {
    process(x int) int
}

type interface B {
    process(x string) int
}

type interface C {
    A
    B
}
```

`C` is **invalid** because:
- `process` resolves to **two incompatible signatures**

Conflict errors occur at **interface declaration time** and causes compile-time errors.

### 230.5.3 No inheritance

- No `extends` keyword
- No interface hierarchies
- Only composition

---

## 230.6 Interface Values and Representation

Values of interface type `I` are **interface values**.

### 230.6.1 Representation

At runtime, an interface value contains:
```
data_ptr   : pointer to concrete value
vtable_ptr : pointer to vtable for (ConcreteType implements I)
```

- `data_ptr` points to the underlying object (not owned)
- `vtable_ptr` points to a static function‑pointer table

Binary layout is implementation‑defined but stable.

### 230.6.2 Zero value and `nil`

The zero value of an interface:
```
data_ptr   = null
vtable_ptr = null
```

Behavior:
- Calling a method on a zero interface value is a compile-time error when detectable,otherwise a runtime safety error
- Zero interface equals zero interface

### 230.6.3 Assignment to interfaces

```
var f File
var w Writer = f
```

Compiler checks that `File implements Writer`.  
Runtime sets:
- `w.data_ptr = &f`
- `w.vtable_ptr = &VTable(File implements Writer)`

No hidden heap allocation.  
The interface value never relocates the underlying object.
It merely stores a pointer to existing storage.

---

## 230.7 Method Calls and Dispatch

### 230.7.1 Static dispatch (concrete type)

```
var f File
f.Write(p)
```

- `File` is statically known
- Compiler resolves call statically and may inline

### 230.7.2 Dynamic dispatch (interface type)

```
func Save(w Writer) {
    w.Write(p)
}
```

Runtime:
- Uses `w.vtable_ptr` to get function pointer
- Passes `w.data_ptr` as receiver
- Applies receiver-adjustment rules from `170`

### 230.7.3 Mutability

Mutability of method calls is determined exclusively by the receiver modifier defined in `170_MethodsAndInterfaces.md`.
Raw pointer receivers (*T) are not allowed in Ori (see §310.5.5).

Allowed receiver forms:
- **Value receiver** — operates on a copy:
  ```ori
  func (self File) Describe() string {
    return self.Path
  }
  ```
- **Shared receiver** — operates on the original instance (mutable):
  ```ori
  func (self shared File) Write(p []byte) int {
    // allowed: modifies the underlying File
    self.buffer.append(p)
    return p.len()
  }
  ```
- **Const receiver** — read-only view of the original:
  ```ori
  func (self const File) Size() int {
    return self.buffer.len()
  }
  ```
- **Forbidden**:
  ```ori
  func (self *File) Write(p []byte) int   // ❌ forbidden
  ```

Interface dispatch (static or dynamic) passes the receiver exactly as declared:
- shared → mutable reference
- const  → read-only reference
- value  → copy

Pointer semantics (*T) never participate in method dispatch.

---

## 230.8 Generics and Interface Constraints

### 230.8.1 Declaring constraints

```
T implements Writer
func Save[T](x T) {
    x.Write(...)
}
```

Inside `Save`, calls are **statically dispatched**:
- No interface indirection
- No vtable
- Function is monomorphized for each `T`

### 230.8.2 Multiple constraints

```
T implements Reader
T implements Writer

func Copy[T](r T, w T) {
    var buf []byte
    r.Read(buf)
    w.Write(buf)
}
```

Constraint conflicts produce compile-time errors.

### 230.8.3 Static type‑check conditions

```
if T implements Writer {
    // comptime branch
}
```

- Evaluated at compile‑time
- Selects specialized code paths in `comptime` contexts

---

## 230.9 Explicit Implementation Checking & Errors

### 230.9.1 When checking occurs

`Type implements Interface` is validated when:
- Both sides are known
- Forward declarations resolved once complete

### 230.9.2 Error examples

#### 1. Missing method

```
type interface Writer {
    Write(p []byte) int
}

type struct File {}

File implements Writer
// ERROR: File lacks Write(p []byte) int
```

#### 2. Signature mismatch

```
type interface Writer {
    Write(p []byte) int
}

func (self shared File) Write(p []byte) string { ... }

File implements Writer
// ERROR: result type string ≠ int
```

#### 3. Composition conflict

(see 230.5.2)

#### 4. Duplicate implementation

```
File implements Writer
File implements Writer
// ERROR: duplicate implementation
```

---

## 230.10 Interactions with Other Features

### 230.10.1 Sum Types

Sum types may implement interfaces if they define methods:

```
type Shape =
    | Circle(radius float64)
    | Rect(w float64, h float64)

func (s Shape) Area() float64 { ... }

Shape implements HasArea
```

### 230.10.2 Deterministic Destruction

From `220_DeterministicDestruction.md`:
- Interface values **do not own** the referenced object
- They must not outlive the object's storage
- Moving or destroying the underlying object while interface values still exist is a compile-time error when detectable, otherwise a runtime safety error

### 230.10.3 Containers

Containers (slices, maps, etc.) may store interface values:
- Each entry stores its own pair `(data_ptr, vtable_ptr)`

Containers of concrete types behave normally; interface usage remains explicit.

---

## 230.11 Summary

- Interfaces define behavior.
- Implementation is always explicit with `Type implements Interface`.
- Interface values are `(data pointer + vtable pointer)`; non‑owning.
- Static dispatch via generics; dynamic dispatch via interface‑typed values.
- Composition is allowed; no inheritance keyword.
- Mutability follows receiver rules from `170_MethodsAndInterfaces.md`.
