# Ori v0.10 Roadmap

Ori v0.10 introduces six focused, high-impact features that strengthen the type system, compile-time capabilities, runtime foundations, and module ecosystem.
This release represents the first iteration of "language completeness".

---

## 1. Enums (Field-less Sum Types) — New File: 350_Enums.md

### Goals

Introduce a safe, explicit model for enums as *sum types without payloads*.
Enums become a restricted form of Ori’s existing tagged union system.

### Deliverables

- New syntax for field-less sum-type enums:
```ori
type enum Color =
| Red
| Green
| Blue
```

- Enums behave as symbolic, strongly-typed variants.
- No implicit integer backing, no iota-style behavior.
- Switch exhaustiveness rules apply.
- CTR support for enumerating variants.
- Document differences with:
- iota (Go)
- integer-backed enums (C, Zig repr types)
- algebraic enums (Rust)
- Add examples and best practices.

---

## 2. Collections – Phase 1 (StringBuilder + Map/HashMap Polishing)

### Goals

Expand the standard library with the final foundational container and polish dictionary types introduced in v0.7.

### Deliverables

- Introduce `StringBuilder` for efficient string construction.
- Final clarification of `map[K]V` behavior:
- ordering
- clone semantics
- clear/delete rules
- examples for idiomatic usage
- Final clarification of `hashmap[K]V` behavior:
- deterministic hashing model
- iteration behavior
- clone/clear semantics
- Add full test suite examples in `*_test.ori` form.

(Note: `Vector[T]` was removed; slices already fulfill this role.)

---

## 3. Time API – Phase 1

### Goals

Provide minimal, deterministic time primitives required for concurrency, tests, and real-world applications.

### Deliverables

- `Now()` — wall clock
- `MonotonicNow()` — monotonic timestamp
- `Duration` type
- `Sleep(d)`
- `After(d)`
- `Ticker`
- No hidden threads or implicit allocation.
- Platform-neutral guarantees.

---

## 4. Testing Framework – Phase 2

### Goals

Enhance the explicit, deterministic testing model introduced in v0.8.

### Deliverables

- Subtests: `t.Run("case", func(t *TestContext) {})`
- OS/environment conditions:
- `t.OS == "linux"`
- `t.Env("CI")`
- Built-in test timeouts
- Parallel tests (deterministic scheduling; no Go-style nondeterminism)
- Improved diagnostics and error messages
- Integration of Time API
- Examples added to `300_TestingFramework.md`

---

## 5. Compile-Time Reflection – Phase 2

(No attribute system; structural reflection only.)

### Goals

Complete the CTR model by enabling structural inspection of all major type
categories without introducing annotations or attributes.

### Deliverables

- Reflection of:
- struct fields (names, types)
- enums and variants
- sum types with payloads
- interfaces and methods
- generic parameters and constraints
- No annotation system (`@tag`, `@serde`, etc. remain forbidden).
- CTR remains pure, side-effect-free, deterministic.
- Examples for:
- generating lookup tables
- auto-deriving enum string names
- verifying interface implementation consistency

---

## 6. Modules & Build System – Phase 2

### Goals

Strengthen the Ori module system introduced in v0.8 and prepare for larger, multi-module projects.

### Deliverables

- `ori.mod` v2:
- `module <name>`
- `dependencies { ... }` (minimal, explicit)
- Workspace/multi-module support
- Refined vendor behavior (reproducible builds)
- Cross-compilation flags and build options clarified
- Documentation updates in `270_ModulesAndCompilationUnits.md`
- Expanded examples for real-world project structure

---

# Summary

v0.10 contains six deliberate, high-value additions:
1. Enums (350_Enums.md)
2. Collections Phase 1 (StringBuilder + Map/HashMap polish)  
3. Time API Phase 1
4. Testing Framework Phase 2
5. Compile-Time Reflection Phase 2
6. Modules & Build System Phase 2

This version finalizes several major subsystems (CTR, tests, time, modules), introduces safe enums, and prepares the ground for higher-level libraries in future releases.
