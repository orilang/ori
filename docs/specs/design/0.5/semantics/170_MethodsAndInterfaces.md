# 170. Methods and Interfaces

Ori provides **methods** and **interfaces** to attach behavior to types and define reusable contracts.  
All relationships are **explicit** — there is no implicit satisfaction or hidden inheritance.

---

## 170.1 Overview

Methods and interfaces in Ori form the foundation of structured and modular programming.  
They provide predictable, type-safe mechanisms for behavior composition without inheritance or ambiguity.

- Methods bind functions to specific types.
- Interfaces define contracts that types must explicitly implement.
- All conformance is declared, never inferred.

---

## 170.2 Method Declaration

A method is a function bound to a specific type via a **receiver**.  
The receiver defines how the method accesses the underlying value.

### Grammar
```
MethodDecl = "func" "(" Receiver ")" Identifier "(" [ ParameterList ] ")" [ FuncResult ] Block .
Receiver    = [ ReceiverModifier ] Identifier Type .
ReceiverModifier = "ref" | "const" .
```

### Receiver Semantics

| Modifier | Description |
|-----------|--------------|
| *(none)* | The method operates on a copy of the receiver. |
| `shared` | The method operates on a reference to the original instance (can modify). |
| `const` | The method operates on a read-only reference (cannot modify). |

### Example
```ori
struct User {
    name string
}

func (u shared User) rename(newName string) {
    u.name = newName
}

func (u User) greet() string {
    return "Hello, " + u.name
}

func (u const User) printName() {
    fmt.Println(u.name)
}
```

---

## 170.3 Method Overloading

Ori **does not support method overloading**.  
Each method name must be **unique** within a type’s method set, regardless of parameter types or receiver kind.

This design prevents ambiguity and ensures clear, deterministic method resolution.

### ✅ Valid
```ori
struct User {
    name string
}

func (u User) greet() string {
    return "Hello " + u.name
}
```

### ❌ Invalid — different parameter count
```ori
func (u User) greet() string        // ok
func (u User) greet(msg string) {}  // ❌ error: method 'greet' already defined
```

### ❌ Invalid — different parameter type
```ori
func (u User) greet(msg string) {}
func (u User) greet(id int) {}      // ❌ error: duplicate method 'greet'
```

### ❌ Invalid — different receiver kind
```ori
func (u User) greet() string {}
func (u shared User) greet() string {} // ❌ error: duplicate method 'greet'
```

---

## 170.4 Interfaces

Interfaces define **behavioral contracts** — sets of methods that a type must implement.  
All implementations must be declared explicitly.

### Grammar
```
InterfaceDecl = "interface" Identifier "{" { MethodSig } "}" .
MethodSig     = Identifier "(" [ ParameterList ] ")" [ FuncResult ] .
```

### Example
```ori
interface Greeter {
    greet() string
}
```

Any type implementing `Greeter` must define a compatible `greet()` method.

If an interface defines **multiple methods**, the implementing type must define **all** of them.  
Otherwise, the compiler emits an explicit error.

Example:
```ori
interface Greeter {
    greet() string
    identify() string
}

struct User { name string }

User implements Greeter

func (u User) greet() string {
    return "Hello, " + u.name
}

func (u User) identify() string {
    return "User type"
}
```

If a method is missing:
```
error: 'User' does not fully implement 'Greeter' — missing method 'identify'
```

---

## 170.5 Explicit Implementation

Ori requires **explicit declaration** of interface conformance.  
A type must declare that it implements an interface before being used as such.

### Example — User and Bot implementing Greeter

#### Step 1. Define the interface
```ori
interface Greeter {
    greet() string
}
```

#### Step 2. Define concrete types
```ori
struct User {
    name string
}

struct Bot {
    id int
}
```

#### Step 3. Declare explicit implementation
```ori
User implements Greeter
Bot  implements Greeter
```

#### Step 4. Define interface methods
```ori
func (u User) greet() string {
    return "Hello, " + u.name
}

func (b Bot) greet() string {
    return "Beep boop — unit " + string(b.id)
}
```

#### Step 5. Use interface polymorphism
```ori
func sayHello(g Greeter) {
    fmt.Println(g.greet())
}

var u User = User{name: "Ori"}
var b Bot = Bot{id: 42}

sayHello(u)
sayHello(b)
```

**Output:**
```
Hello, Ori
Beep boop — unit 42
```

#### Step 6. Using interface collections
```ori
var greeters []Greeter = [u, b]

for _, g := range greeters {
    fmt.Println(g.greet())
}
```

Each element in `greeters` can be a different type, as long as it implements `Greeter`.

### Summary of Concepts

| Concept | Meaning |
|----------|----------|
| `interface Greeter` | Declares required methods. |
| `User implements Greeter` | Declares explicit relationship between type and interface. |
| `func (u User) greet()` | Defines method required by the interface. |
| `Greeter` in function parameter | Enables runtime polymorphism. |
| `[]Greeter` | Heterogeneous collection of conforming types. |

---

## 170.6 Dynamic Dispatch

When an interface value is used at runtime, Ori stores:
- A reference to the concrete value.
- A **method table** (vtable) for the implemented interface methods.

This allows safe, predictable runtime polymorphism without implicit behavior.

- Compile-time: the compiler verifies that all required methods are implemented.
- Runtime: the correct method is resolved via the vtable.

### Conceptual Model
```text
Greeter → [ pointer to value | pointer to method table ]
```

---

## 170.7 Monomorphism and Polymorphism — Definitions

- **Polymorphism**: the ability for one function or abstraction to work with values of **different types** that share a common behavior (e.g., an interface).  
- **Monomorphism**: the process of turning polymorphic code into **type-specific** code at **compile time** (specialization).

Ori supports **dynamic polymorphism** via interfaces in v0.5, and intends to support **static polymorphism** (monomorphism) via generics in a future version.

---

## 170.8 Monomorphism (Static Polymorphism)

**Static polymorphism** means the compiler generates **specialized code** for each concrete type used with a generic function.

> *Status in v0.5: planned for a future version.*

### Conceptual Example (future syntax)
```ori
// Generic numeric constraint assumed
func max[T numeric](a T, b T) T {
    if a > b { return a }
    return b
}

// Calls would generate specialized versions:
max[int](10, 20)         // → max_int
max[float64](3.14, 2.71) // → max_float64
```

### Pros
- Zero runtime overhead; highly optimized.
- Strong compile-time safety.
- Inlining and per-type optimization.

### Cons
- Larger binaries (code bloat) when used with many types.
- Requires recompilation for new types.
- No runtime substitution (values must be concrete at compile time).

---

## 170.9 Polymorphism (Dynamic)

**Dynamic polymorphism** means method selection occurs **at runtime** through interfaces.

### Example (current v0.5)
```ori
interface Drawable {
    draw()
}

struct Circle { radius int }
struct Square { size int }

Circle implements Drawable
Square implements Drawable

func (c Circle) draw() {
    fmt.Println("draw circle", c.radius)
}

func (s Square) draw() {
    fmt.Println("draw square", s.size)
}

func paintAll(items []Drawable) {
    for _, d := range items {
        d.draw() // runtime dispatch through the interface
    }
}

paintAll([Circle{radius: 10}, Square{size: 5}])
```

### Pros
- Flexible: different concrete types can be handled uniformly.
- Works well for plugins, handlers, and heterogeneous collections.
- Keeps binaries compact (shared interface entry points).

### Cons
- Small runtime overhead (indirect calls).
- No inlining across interface boundaries.
- Behavior defined by contracts, not concrete types.

---

## 170.10 How They Coexist

In Ori’s design:
- **Interfaces** provide **dynamic polymorphism** (runtime dispatch).  
- **Generics** (future) provide **static polymorphism** (compile-time specialization).

Use **interfaces** when you need **heterogeneous collections** or **runtime substitution**.  
Use **generics** when you need **maximum performance** and **compile-time specialization**.

### Summary Table

| Aspect | Static (Monomorphism) | Dynamic (Polymorphism) |
|---------|------------------------|--------------------------|
| Binding time | Compile-time | Runtime |
| Dispatch | Direct call (inlined) | Indirect call via vtable |
| Type scope | Concrete, generic types | Any implementing type |
| Performance | Maximum (zero overhead) | Slight overhead |
| Code size | Larger (one per specialization) | Compact (shared code) |
| Use cases | Numerics, algorithms | Interfaces, plugin systems |
| Status in Ori | Planned (v0.5+) | Implemented (v0.5) |

---

## 170.11 Summary

| Concept | Description |
|----------|--------------|
| **Method** | Function bound to a type. |
| **Receiver** | `ref`, `const`, or value; defines access semantics. |
| **Interface** | Declares a set of required methods. |
| **implements** | Declares explicit conformance between a type and an interface. |
| **No overloading** | Prevents ambiguity in method lookup. |
| **Dynamic dispatch** | Safe runtime polymorphism via method tables. |
| **Monomorphism** | Future compile-time specialization via generics. |
| **Polymorphism** | Runtime dispatch via interfaces (available). |

---

Ori’s method and interface system emphasizes **explicitness**, **clarity**, and **predictable behavior**,  
with a clear path toward efficient compile-time polymorphism in future versions.
