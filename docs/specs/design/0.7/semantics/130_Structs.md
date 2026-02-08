# 130. Structs

Structs in Ori are **explicitly defined and explicitly initialized** composite types.  
They group related fields and can define associated methods, providing a foundation for structured, type-safe data.

---

## 130.1 Overview

A `struct` represents a fixed collection of named fields, each with an explicit type.  
Unlike some other languages, Ori **does not create implicit zero values** — every struct must be explicitly initialized.

Structs are **value types** by default: assignments and returns copy their contents unless a `ref` or `view` qualifier is used.

Struct names starting with an **uppercase** letter are **exported (public)**,  
while lowercase struct names are **private** to their defining package or module.

---

## 130.2 Why Zero Values Are Not Allowed

In Go and C, every variable or struct receives a *zero value* automatically (e.g., `0`, `false`, `""`).  
While convenient, this approach hides initialization behavior and can lead to subtle bugs.

### Pitfalls of implicit zero values

**Hidden state:** a struct may appear valid even though it was never initialized.  
**Logic errors:** e.g., `if user.ID == 0` might mean “unset,” but it’s also the zero default.  
**Silent bugs:** forgotten initialization compiles and runs silently.  
**Unpredictable behavior in FFI or embedded contexts.**

Ori forbids implicit zero values to ensure explicit construction and visible intent.

> **Rule:**  
> Every struct must be created explicitly through a literal or constructor.  
> No field is initialized unless explicitly defined by the developer.

---

## 130.3 Declaration

### Grammar

```
StructDecl = "struct" Identifier "{" { FieldDecl } "}" .
FieldDecl  = Identifier Type [ "=" Expression ] .
```

### Example

```ori
type User struct {
    name string
    age  int
}
```

Optional field defaults can be specified:

```ori
type Config struct {
    host string = "localhost"
    port int = 8080
}
```

---

## 130.4 Explicit Initialization

Structs must always be initialized explicitly — no automatic zero values exist.

```ori
var u User // ❌ invalid — requires explicit initialization
var u User = User{name: "Ori", age: 20} // ✅ valid
```

All fields must be provided, either directly or through explicit defaults.

```ori
type Config struct {
    host string = "localhost"
    port int = 8080
}

var cfg Config = Config{} // uses explicit field defaults
```

---

## 130.5 Field Access and Visibility

Field visibility is determined by capitalization:

| Field Name | Visibility |
|-------------|-------------|
| Starts with uppercase | Exported (public) |
| Starts with lowercase | Private to the defining package |

```ori
type User struct {
    Name string // public
    email string // private
}
```

Fields are accessed using dot notation:

```ori
fmt.Println(u.Name)
u.email = "private@ori.dev" // valid within same package
```

---

## 130.6 Value and Reference Semantics

By default, structs are **value types**.  
Assignment or parameter passing copies all fields.

```ori
var a User = User{name: "A", age: 10}
var b User = a // copy
b.name = "B"

fmt.Println(a.name) // "A" — unaffected
```

To share or mutate across copies, use the `view` or `ref` qualifier.

---

## 130.7 Qualifiers: const, view, ref

Ori supports qualifiers that define how values are accessed, borrowed, or mutated.

| Qualifier | Status | Description |
|------------|---------|-------------|
| `const` | ✅ Stable | Immutable binding — value or field cannot be reassigned or mutated. |
| `view` | ✅ Stable | Non-owning read-only reference (like a safe slice or borrow). |
| `shared` | ✅ Stable | Mutable alias to an existing value; semantics under review for lifetime and aliasing guarantees. |

```ori
var u User = User{name: "Ori", age: 20}

var const  frozen User  = u  // immutable copy
var view   watcher User = u // read-only borrow
var shared alias User   = u   // mutable alias

alias.age = 25 // modifies u.age
```

---

## 130.8 Methods

Structs can have associated methods declared with explicit receivers.

### Grammar

```
MethodDecl = "func" "(" Receiver ")" Identifier "(" [ Parameters ] ")" [ ReturnType ] Block .
```

### Example

```ori
type User struct {
    name string
    age  int
}

func (u User) Greet() {
    fmt.Println("Hello,", u.name)
}
```

### Mutating methods

Methods that modify the receiver must use the `ref` qualifier:

```ori
func (ref u User) Birthday() {
    u.age += 1
}
```

This is semantically similar to Go’s pointer receiver but with safe reference semantics.

---

## 130.9 Composition and Embedding

Ori **does not support type-name embedding** or **field promotion**.

### ❌ Invalid

```ori
type Address struct {
    city string
    country string
}

type User struct {
    name string
    Address // forbidden
}
```

### ✅ Valid

```ori
type Address struct {
    city string
    country string
}

type User struct {
    name string
    addr Address
}

fmt.Println(u.addr.city)
```

Field and method access must always be explicit.  
No recursive promotion, shadowing, or method inheritance is allowed.

### Why Embedding Is Forbidden

1. **Name collisions:** Go silently shadows inner fields; Ori forbids ambiguous names.  
2. **Recursive flattening:** implicit access chains like `u.name` (from nested structs) create unclear ownership.  
3. **Method promotion:** automatically exposing inner methods leaks implementation details.  
4. **Ownership clarity:** explicit field names allow controlled use of `view` or `ref`.

| Problem | Go Behavior | Ori Behavior |
|----------|--------------|---------------|
| Name collision | Shadowed silently | Compile-time error |
| Field promotion | Recursive flattening | Explicit only |
| Method promotion | Implicit | Disallowed |
| Ownership | Implicit | Explicit via qualifiers |
| API clarity | Blurred | Explicit and predictable |

---

## 130.10 Memory Layout, Padding, and Alignment

Ori structs have **predictable layouts** with natural alignment.  
Fields are ordered and aligned sequentially according to their type’s requirements.

### Alignment

Each field begins at a memory address aligned to its size.  
This ensures efficient CPU access.

### Padding

Unused bytes may be inserted between fields to maintain alignment:
```ori
type Example struct {
    a byte   // 1 byte
    b int32  // may start at offset 4, with 3 bytes of padding
}
```

Padding is automatically handled by the compiler and is **deterministic**.

### FFI (Foreign Function Interface)
**FFI** refers to interoperability between Ori and external languages such as C.  
Precise layout and alignment rules ensure compatibility across language boundaries.

---

## 130.11 Immutability and Safety

A `const` struct cannot have its fields modified after creation.  
`view` references cannot mutate the target.  
`ref` allows controlled mutation (experimental).  
Structs are not implicitly thread-safe; synchronization is the developer’s responsibility.

---

## 130.12 Explicit Construction and Initialization Functions

Ori forbid hidden or automatic `init()` functions.  
Developers can define constructor-like helpers for initialization:

```ori
func NewUser(name string, age int) User {
    return User{name: name, age: age}
}
```

This keeps struct creation explicit and visible.

---

## References
- [050_Types.md](syntax/050_Types.md)
- [120_Strings.md](semantics/120_Strings.md)
- [100_Slices.md](semantics/100_Slices.md)
