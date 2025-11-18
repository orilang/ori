# Ori Language Specification — Version 0.5

Ori is a **system-capable general-purpose programming language**.  
It emphasizes **explicitness**, **predictability**, and **no runtime magic**.  
Every construct in Ori is designed to be transparent, deterministic, and safe by default.

> “Explicit code is predictable code — Ori hides nothing.”

---

## 📘 Overview

This repository contains the full **Ori v0.5 language specification**, divided into clearly defined sections:

- **Syntax:** Defines grammar, tokens, and basic structures.
- **Semantics:** Explains the meaning and runtime behavior of constructs.
- **Design Principles:** Documents the philosophy and rationale behind language rules.
- **Appendix:** Provides quick reference materials such as keywords, built-ins, and grammar summaries.

---

## 📂 Directory Structure

### 🧱 Core

```
001_Introduction.md
002_Language_Overview.md
```

### 🧩 syntax/
Fundamental grammar, lexical rules, and program structure.

```
005_LexicalElements.md
010_ProgramStructure.md
015_Literals.md
020_Declarations.md
030_Variables.md
040_Functions.md
050_Types.md
060_Statements.md
070_Expressions.md
080_Blocks.md
090_ModulesAndImports.md
095_SyntaxSummary.md
100_Comments.md
101_TokensAndOperators.md
```

---

### ⚙️ semantics/
Describes how code behaves at runtime — slices, maps, structs, errors, and concurrency.

```
100_Slices.md
101_Array.md
110_Maps.md
111_HashMaps.md
120_Strings.md
121_NumericTypes.md
130_Structs.md
140_Errors.md
150_TypesAndMemory.md
160_ControlFlow.md
170_MethodsAndInterfaces.md
180_RuntimeAndPanicHandling.md
190_Concurrency.md
200_MemorySafetyAndOwnership.md
210_GenericTypes.md
220_FFIandInteroperability.md
```

---

### 🧠 design_principles/
Outlines Ori’s philosophy and rationale for its rules and behavior.

```
001_DesignIntent.md
002_TypeSafetyAndExplicitness.md
003_ErrorHandlingPhilosophy.md
004_RuntimeAndMemoryPhilosophy.md
005_ConcurrencyAndPredictability.md
006_ImportsAndVisibility.md
007_TypeSystemPhilosophy.md
```

---

### 📚 appendix/
Compact reference materials for developers and implementers.

```
001_Keywords.md
002_Builtins.md
003_GrammarIndex.md
004_Glossary.md
```

---

## 🧾 Design Highlights

- **No implicit conversions** — every type conversion must be explicit.  
- **No automatic zero values** — developers must initialize all data.  
- **No global variables** — only `const` is allowed at the package level.  
- **Compile-time error enforcement** — unhandled errors cause compilation failure.  
- **No runtime magic** — Ori does not depend on hidden schedulers, GC, or init hooks.  
- **Explicit concurrency** — tasks are spawned and waited upon manually (`spawn`, `wait`).  
- **Predictable compilation and linking** — no lazy imports or runtime side effects.

---

## 🧩 Specification Scope (v0.5)

The v0.5 specification defines:
- Complete **syntax and grammar** using Wirth Syntax Notation (WSN).
- Core **semantics** for types, memory, and control flow.
- Explicit **error handling model** via `try` and typed errors.
- Foundational **concurrency primitives** (channels, mutexes, tasks).
- Full **type system philosophy**, including numeric safety rules.

---

## 🔮 Future Directions (v0.5+)

- Ownership and borrowing semantics (`view`, `ref` qualifiers).  
- Const generics for arrays and numeric operations.  
- Interface and trait-based polymorphism.  
- Optional safety extensions for FFI and low-level memory control.

---

## 📜 License

The Ori Language Specification is an open technical document intended for compiler implementers, contributors, and developers interested in language design.  
You are free to study, modify, and distribute it under the same open philosophy that defines Ori itself.

---

> **Ori v0.5 — A language built on clarity, precision, and developer intent.**
