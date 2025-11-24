# ROADMAP_v0.7.md

# Ori v0.7 Roadmap
**Focus Areas:**
1. Interfaces (behavior polymorphism)
2. Pattern Matching for Sum Types (using `switch`)
3. Minimal Compile-Time Execution (CTE)
4. Container Ownership & Aliasing Rules

---

## 230 – Interfaces
Introduce the full specification for Ori’s interface system (behavior-based polymorphism).
This extends method semantics defined in **170_MethodsAndInterfaces.md**.

### Goals
- Provide a strong, static polymorphism model.
- Allow dynamic dispatch when explicitly requested.
- Maintain predictable memory layout and deterministic performance.

### Topics to Define
- Interface declaration syntax
- Explicit vs implicit implementation rules
- Interface satisfaction rules (method-set based)
- Static vs dynamic dispatch semantics
- Vtable model and memory layout
- Passing/returning interface values
- `T implements Interface` queries (compile-time)
- Generic types implementing interfaces
- Error messages and diagnostics

### Deliverables
- **230_Interfaces.md**

---

## 240 – Pattern Matching for Sum Types (via `switch`)
Integrate sum-type destructuring and exhaustiveness checks into Ori’s existing `switch` construct.

### Goals
- Enable ergonomic and safe deconstruction of sum types.
- Guarantee exhaustive handling at compile time.
- Allow guarded and nested patterns while keeping syntax simple.

### Topics to Define
- Switch-based pattern syntax
- Destructuring: `case Variant(x, y):`
- Exhaustiveness checking
- Guards: `case Circle(r) if r > 0:`
- Binding lifetimes and payload access rules
- Redundant or unreachable patterns
- Nested pattern rules

### Deliverables
- **240_PatternMatching.md**

---

## Minimal Compile-Time Execution (CTE)
Add a foundational CTE capability to Ori without introducing full macro systems.

### Goals
- Allow compile-time evaluation of pure expressions.
- Support constants derived from types or generic parameters.
- Make room for future evolution (e.g., limited reflection).

### Topics to Define
- `comptime` keyword or attribute
- Compile-time purity and determinism rules
- Allowed operations (arithmetic, type queries, pure functions)
- Forbidden operations (mutation, I/O, heap allocation)
- Type-level queries: `T.sizeof`, `T.alignof`, field metadata
- Using CTE inside generics and constant expressions
- Error diagnostics when CTE fails or escapes constraints

### Deliverables
- New file (tentative): **250_Comptime.md**
  - Or integrated into existing semantics, per your preference.

---

## Container Ownership & Aliasing Rules
Define clear semantics for ownership, copying, viewing, and aliasing for:

- slices
- maps
- strings

### Goals
- Make container behavior predictable and memory-safe.
- Clarify when operations copy memory vs create views.
- Stabilize interactions between containers, structs, and generics.

### Topics to Define
- Ownership model for container types
- “View vs copy” rules for slices and maps
- String immutability: storage, slicing rules, views
- When containers invalidate views
- Move semantics and aliasing prevention
- Map behavior with non-copy element types
- Internal buffer lifetime rules

### Deliverables
- Integrated into:
  - **150_TypesAndMemory.md**
  - **220_DeterministicDestruction.md**
  - Container-specific sections

---

# Summary Table

| Feature Area | Deliverable | Goal |
|--------------|-------------|------|
| Interfaces | 230_Interfaces.md | Define Ori’s interface system (behavior polymorphism) |
| Pattern Matching | 240_PatternMatching.md | Sum-type destructuring & exhaustiveness using `switch` |
| Compile-Time Execution | 250_Compiletime.md (tentative) | Pure compile-time evaluation + type queries |
| Container Ownership Model | Integrated in memory semantics | Predictable aliasing/view/copy semantics |

---

# Status
**v0.7 scope is locked.**
Next step: Begin implementing **230_Interfaces.md**.
