# Ori v0.6 Roadmap  
**Focus Areas:**  
1. Generics (Parametric Polymorphism)  
2. Sum Types (Algebraic Data Types)  
3. Deterministic Destruction (Destructors + Defer)

---

## 1. Generics (Parametric Polymorphism)

### 1.1 Goals
- Introduce type parameters for types (`List[T]`, `Map[K, V]`, `Option[T]`, `Result[T]`).
- Support generic functions (`func max[T](a T, b T) T`).
- Support generic methods on generic types.
- Use *monomorphization* as the compilation strategy.
- Allow type argument inference when unambiguous.

### 1.2 Non-Goals for v0.6
- No trait/interface constraint system.
- No higher-kinded types.
- No specialization features.
- No implicit generic instantiation from complex expressions.

### 1.3 Required Additions
- Grammar extensions for type parameters on types and functions.
- Rules for instantiating generic types.
- Rules for using generic values in composite structures.
- Detection of invalid or unused type parameters.
- Integration with slices, maps, structs, error types, and tasks.

### 1.4 Deliverables
- Full grammar update for type parameters.
- Type checker support.
- Code generation rules for monomorphized instantiation.
- Built-in containers upgraded to generic forms where appropriate.

---

## 2. Sum Types (Algebraic Data Types)

### 2.1 Goals
- Add tagged union types with variant constructors.
- Add simple match/switch with exhaustive checking.
- Add `Option[T]` and `Result[T]` as standard library types.
- Enable safe modeling of states and error conditions.

### 2.2 Syntax Model
A sum type consists of named variants with optional payload fields, for example:
```
type Shape =
    | Circle(radius float)
    | Rect(w float, h float)
```

### 2.3 Language Semantics
- Every variant carries a unique, compiler-generated tag.
- Payload fields behave like struct fields.
- Variables of a sum type can only hold one active variant at a time.
- Exhaustiveness required in `switch` over a sum type.

### 2.4 Non-Goals for v0.6
- No pattern matching syntax beyond basic switching.
- No destructuring in `switch`.
- No generic variant constraints.

### 2.5 Deliverables
- Grammar additions for variant types.
- Switch exhaustivity checking.
- Standard library `Option[T]` and `Result[T]`.

---

## 3. Deterministic Destruction (Destructors + Defer)

### 3.1 Goals
- Provide predictable cleanup semantics for resources.
- Integrate with ownership and lifetime rules from v0.5.
- Ensure deterministic invocation of destructors.
- Provide a structured `defer` mechanism.

### 3.2 Features

#### 3.2.1 Destructors
- A type may define a **destructor method** (syntax to be defined in the v0.6 design phase).
- A destructor is automatically invoked:
  - when a value goes out of scope,
  - after a full move,
  - during panic unwinding (after all `defer` blocks run).

#### 3.2.2 `defer`
- Runs cleanup logic when the scope exits.
- LIFO ordering.
- Executes even during panic unwinding.

#### 3.2.3 Interaction Rules
- `defer` blocks run first.
- Destructors run after all `defer` blocks in the same scope.
- Moves must preserve destruction correctness.
- Partial moves must not invalidate remaining fields.

### 3.3 Non-Goals for v0.6
- No async-aware destruction semantics.
- No destructor prioritization or multi-phase destruction.
- No syntax commitment to keywords like `drop` or `destroy`.

### 3.4 Deliverables
- Grammar for `defer`.
- Specification of destructor invocation rules.
- Panic-safety rules for both destructors and `defer`.
- Updated memory model specification (expansion of v0.5).

---

## Summary

Ori v0.6 delivers three foundational features that strengthen the type system, improve resource safety, and prepare the ground for future language capabilities:

- **Generics**: Type parameters for functions and types, monomorphized at compile time.  
- **Sum Types**: Safe algebraic variants enabling expressive APIs and precise error modeling.  
- **Deterministic Destruction**: Predictable cleanup model with destructors and `defer`, integrated with ownership rules.

Each of these is designed to be stable, minimal, and compatible with future expansions in v0.7 and beyond.
