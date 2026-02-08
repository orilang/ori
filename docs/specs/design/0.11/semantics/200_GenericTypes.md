# 200. Generic Types

This document defines the **semantic rules** for Ori’s generic types and

---

## 200.1 Overview

Generic types introduce **parametric polymorphism** into Ori.  
They allow functions, structs, and type aliases to be parameterized over **types**.

Semantics are based on:
- **Static typing**
- **Monomorphization at instantiation sites**
- **Zero-cost abstraptions**
- **No constraints or specialization for now**

Type parameters apply only at **compile time** and do not exist at runtime.

---

## 200.2 Generic Functions Semantics

### 200.2.1 Declaration

Ori uses function syntax with square brackets for type parameters:

```
func name[T1, T2](params...) ReturnType { ... }
```

#### Grammar

```
GenericFunctionDecl =
    "func" Identifier "[" TypeParamList "]"
    "(" ParamList ")" Type Block ;

TypeParamList =
    Identifier { "," Identifier } ;

GenericTypeDecl =
    "struct" Identifier "[" TypeParamList "]" StructBody
  | "type" Identifier "[" TypeParamList "]" "=" Type ;
```

### 200.2.2 Generic Functions

Example:
```
func max[T](a T, b T) T {
    if a > b {
        return a
    }
    return b
}
```

- `func` keyword
- `max[T]` declares a single type parameter `T`
- Parameters are `name Type`
- Return type follows the parameter list

### 200.2.3 Generic Types

### Structs
```
type Box[T] struct {
    value T
}
```

### Type Aliases
```
type List[T] = struct {
    items []T
}
```

### Sum Types (syntax example; generic behavior only)
```
type Option[T] =
    | Some(T)
    | None
```

## 200.3 Generic Methods

Methods on generic types inherit type parameters:

```
func (b Box[T]) Unwrap() T {
    return b.value
}
```

Methods may introduce new type parameters:

```
func (b Box[T]) Convert[U](f func(T) U) U {
    return f(b.value)
}
```

---

## 200.4 — Instantiation Rules

### 200.4.1 Explicit Instantiation

Always allowed:

```
var x = max[int](3, 7)
var y = max[string]("a", "b")
```

### 200.4.2 Instantiation Produces Concrete Types

```
var a Box[int]
var b Box[string]
```

Produces:
- `Box[int]    → struct { value int }`
- `Box[string] → struct { value string }`

Each is a distinct type.

### 200.4.3 Generic Function Instantiation

```
max[int](3, 5)
max[float](1.0, 2.0)
```

Each produces a unique monomorphized function.

### 200.4.4 Composite Types with Generics

```
var arr []Box[int]
var table [10]Option[float]
var m map[string, List[int]]
```

### 200.4.5 Multiple Type Parameters

```
type Pair[T, U] struct {
    left  T
    right U
}
```

Usage:

```
var p Pair[int, string]
```

### 200.4.6 Generic Methods Instantiation

Given:

```
func (p Pair[T, U]) Swap() Pair[U, T] { ... }
```

Instantiated only when used:

```
var p Pair[int, string]
p.Swap()   // produces Pair[string, int]
```

### 200.4.7 Invalid Instantiations

```
Box[int, string]         // ❌ wrong number of type parameters
max[T](3, 4)             // ❌ T undeclared
Box[Foo()]               // ❌ value, not a type
```

---

## 200.5 — Monomorphization Model

### 200.5.1 Generic Type Monomorphization

Each instantiation generates a specialized version.

```
Box[int]
Box[string]
```

Each is:
- a unique concrete type
- with its own layout
- with its own destructor behavior (if any)

### 200.5.2 Generic Function Monomorphization

```
func max[T](a T, b T) T
```

Calls produce:

```
max$int(int, int) int
max$float(float, float) float
```

### 200.5.3 Cross-Module Monomorphization

Instantiation happens at **use site**, not definition site.

Library:

```
type Box[T] struct { value T }
```

Application:

```
var a Box[int]
var b Box[string]
```

Application module produces:
- `Box[int]`
- `Box[string]`

Library module does not produce monomorphized versions.

### 200.5.4 Incremental Compilation

The compiler caches monomorphized instantiations using:
- module path
- definition hash
- type argument list

### 200.5.5 Dead Code Elimination

```
max[int](3,4)
max[string]("a","b")   // unused
```

Only `max[int]` remains in the final binary.

### 200.5.6 Generic Methods on Generic Types

Instantiated only when invoked.

### 200.5.7 ABI Behavior

Each instantiation:
- has a concrete ABI
- is fully inlinable
- contains no runtime type info

### 200.5.8 Error Behavior

Compile-time errors appear only when an instantiation is reached:

```
func foo[T]() {
    var x T
    x.NotExists()   // error only if foo[T] is instantiated
}
```

---

## 200.6 — Type Inference Rules

### 200.6.1 Allowed Inference (Functions Only)

Inference is allowed only from argument types.

```
var a int = 3
var b int = 10

var m = max(a, b)   // T = int inferred
```

Another example:

```
func map[T, U](in []T, f func(T) U) []U

map([]int{1,2,3}, square)   // T=int, U=int
```

### 200.6.2 Forbidden Inference

#### 200.6.2.1 From Return Type
```
var x int = NewZero()  // ❌ T cannot be inferred
```

#### 200.6.2.2 From Assignment Context
```
var x = NewZero()  // ❌
```

#### 200.6.2.3 Ambiguous Arguments
```
max(3, 2.0)  // ❌ int vs float
```

#### 200.6.2.4 Partially Undetermined Parameters
```
func MakePair[T, U](v T) Pair[T, U]

MakePair(10)   // ❌ U is unconstrained
```

Must be explicit:

```
MakePair[int, string](10)
```

### 200.6.3 Generic Methods

Receiver fixes type params:

```
var b Box[int]
b.Unwrap()   // T = int
```

### 200.6.4 Generic Types Never Infer

```
var b Box[int]      // ok
var c Box           // ❌
var d = Box[int]{...} // ok
var e = Box{...}    // ❌
```

---

## 200.7 — Interaction With Existing Features

### 200.7.1 Slices & Arrays

#### Slices

```
var s []T
var s2 []Box[int]
```

#### Arrays

Allowed only after monomorphization:

```
var a [10]T       // ok when T is concrete
```

Forbidden:

```
var a [len(T)]    // ❌ T has no runtime value
```

### 200.7.2 maps

Key comparability validated **after instantiation**:

```
map[[]int, int]   // ❌ slice not comparable
map[int, User]    // ok
```

### 200.7.3 Sum Types

```
type Option[T] =
    | Some(T)
    | None
```

Fully monomorphized per T.

### 200.7.4 Concurrency

```
func SpawnTask[T](work func() T) TaskHandle[T]
```

Generic task handles allowed.

### 200.7.5 Memory Model

Generic instantiations integrate naturally:

```
Box[T] has a destructor if T has a destructor.
```

### 200.7.6 Modules & Build System

Monomorphization at use-site ensures:
- stable ABIs
- small libraries
- predictable binary layout

### 200.7.7 FFI

Direct FFI of generic instantiations **not allowed**:

```
extern func Process(Box[int])  // ❌
```

Must name it:

```
type IntBox = Box[int]
extern func Process(IntBox)    // ok
```

### 200.7.8 Reflection

No runtime type info for generics in current version.

---

## 200.8 — Restrictions of the current version

Constraints are not part of current implementation. A future version may introduce a constraint system using interface-like or rule-based bounds.

### 200.8.1 No Constraints / Traits
No:
```
func max[T ordered](...)
func Print[T comparable](...)
```

### 200.8.2 No Higher-Kinded Types

```
func Use[F[_]](...)    // ❌
```

### 200.8.3 No Const Generics

In current version, type parameters are types only, not values.

So we do not have:
```
// ❌ not in current version
type Matrix[T, N int] struct1 {
    data [N][N]T
}
[T = int](v T) []byte { ...special int version... }
```

For now:
- Array sizes are normal compile-time expressions, not type parameters.
- Generics don’t know about integer constants.


### 200.8.4 No Specialization

```
func foo[T](...)
func foo[int](...)   // ❌
```

### 200.8.5 No Inference from Return Type

```
func NewZero[T]() T { ... }
var x int = NewZero()  // ❌ illegal in current versions
var xy = NewZero()     // ❌ illegal in current versions
```

You must write:
```
var x int = NewZero[int]()

```


### 200.8.6 No Type Inference for Generic Types

```
type Box[T] struct { value T }

var b Box[int]          // ✅
var c Box               // ❌ missing [T]
var d = Box[int]{ ... } // ✅
var e = Box{ ... }      // ❌ cannot omit [T]

```

### 200.8.7 No Type Parameter Defaults

```
type map[K, V = any] struct   // ❌
// ❌ invalid idea: leaving second parameter as wildcard
type IntMap[V] = Map[int, V]        // this is OK as alias
var m Map[int, _]                   // ❌ no placeholder `_`
```

### 200.8.8 No Variadic Type Parameters

```
type Tuple[...T] struct   // ❌
```

### 200.8.9 No Runtime Type Introspection

```
func Debug[T](v T) {
    println(typeof(T).Name)  // ❌ no such thing in current version
}
```

### 200.8.10 No Auto-Boxing or Erased Generics

No Java/C# style erasure or implicit “any”.
```
func PrintAll(values []any)  // only if you define `any` as a real type
```

### 200.8.11 No Specialization / Overload by Type Parameter

You can’t write two different implementations of the same generic function specialized for different concrete T and have the compiler pick “the best match”.

Example that is not allowed:
```
// ❌ not in current version
func Serialize[T](v T) []byte { ...generic path... }
func Serialize[T = int](v T) []byte { ...special int version... }
```

---

## Summary

Ori current version generics implementations are:
- Generic functions and types with explicit `[T]`
- Static monomorphization at use-site
- Simple, predictable inference rules
- No runtime overhead or type metadata
- Safe integration with slices, maps, sum types, concurrency, memory model, and modules
- Strict restrictions to maintain clarity and avoid premature complexity
- integrated with existing systems
- without constraints, specialization, or type-level features
