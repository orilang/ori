# ROADMAP v0.8

This version focuses on finalizing several foundational areas of the Ori language before moving toward v0.9 and v1.0.  
The scope remains intentionally tight (6 items), following your incremental roadmap philosophy.

---

## 1. Module System Refinement  
**File:** `semantics/270_ModulesAndCompilationUnits.md`

Define and formalize:
- Modules, packages, and compilation units  
- File-to-module mapping rules  
- Import resolution behavior  
- Allowed vs forbidden import forms  
- Visibility rules across module boundaries  
- Build unit structure (no package manager yet)

---

## 2. Attribute / Annotation System  
**File:** `semantics/280_Attributes.md`

Introduce the unified attribute system:
- Syntax: `@name`, `@name(value)`  
- Allowed placement (structs, functions, fields, variables, modules)  
- Initial built-in attributes:
  - `@inline`
  - `@deprecated`
  - `@test` (integrates with test framework)
  - `@extern("C")` (for FFI)
- Rules for compile-time evaluation interaction

---

## 3. FFI Foundations (C ABI)  
**File:** `semantics/290_FFI.md`

Minimal but complete C interop:
- `@extern("C")` or equivalent keyword  
- Ori-to-C type mapping  
- FFI-safe structs & layouts  
- Ownership rules when interacting with C  
- Restrictions on passing views, slices, or Ori-managed containers  
- No dynamic loading yet

---

## 4. Testing Framework Basics  
**File:** `semantics/300_TestingFramework.md`

Define:
- The `@test` attribute  
- Test discovery semantics  
- Test execution rules:
  - Parallel vs sequential  
  - Panic behavior  
- Assertion strategy (panic-as-failure)  
- Optional future extensions: fixtures, categories

---

## 5. Pointers  
**File:** `semantics/310_Pointers.md`

Specify pointer semantics:
- `*T` pointer type syntax  
- Dereferencing rules  
- Nullable vs non-nullable pointers  
- No implicit pointer arithmetic  
- Explicit unsafe escape hatches (if any)  
- Interaction with deterministic destruction, ownership, FFI  
- When pointers are required (FFI, low-level data structures)

---

## 6. Blank Identifier `_`  
**File:** `semantics/320_BlankIdentifier.md`

Define behavior of `_`:
- Allowed in:
  - Variable assignments  
  - Function parameters  
  - Multiple return-value discards  
- Not allowed in:
  - Pattern matching (no wildcard matches)  
  - Imports (wildcard imports forbidden)
- How `_` interacts with:
  - Destructors  
  - Compile-time evaluation  
  - Unused variable checks  
- Must always act as a discard target, never introduce a name

---

## Explicit Decision: Operator Overloading  
**Status:** **Forbidden for v1**  
**Rationale:**  
To keep Ori predictable, explicit, and fully readable, operator overloading is **not supported**.  
This decision may be revisited after v1.5.

A note documenting this will be placed in `design_principles/007_TypeSystemPhilosophy.md`.

---

## Summary of New Files

```
semantics/
├── 270_ModulesAndCompilationUnits.md
├── 280_CompilerDirectivesAndKeywords.md
├── 290_FFI.md
├── 300_TestingFramework.md
├── 310_Pointers.md
└── 320_BlankIdentifier.md
```

---

## Notes
- All new items integrate cleanly with v0.5–v0.7 foundations.  
- No breaking changes expected.  
- v0.8 completes the essential primitives needed before v0.9 (which can begin focusing on productivity features, tooling, safety refinements, etc.).

