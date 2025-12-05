# 2. Language Overview

This document provides a high-level overview of the Ori programming language: its syntax, design philosophy, and core concepts.  
It serves as a quick introduction for readers before diving into the detailed syntax and semantics sections.

---

## 2.1 Design Goals

Ori is a **system-capable general-purpose programming language** focused on:

- **Explicitness over magic** — all operations and allocations are visible.
- **Predictability** — no hidden control flow, conversions, or memory semantics.
- **Safety without verbosity** — strong typing and value semantics, but concise.
- **Simplicity** — syntax easy to learn and consistent across constructs.
- **Performance** — close to C-level performance with predictable memory layout.

---

## 2.2 Syntax

A minimal Ori program:

```ori
package main

import "fmt"

func main() {
  var name = "Ori"
  fmt.Println("Hello,", name)
}
```

**`package`** declares the current compilation unit.  
**`import`** brings modules into scope.  
**`func`** declares a function (with explicit parameter types and return types).  
**`var`** declares variables.

---

## 2.3 Core Building Blocks

| Concept | Description | Reference |
|----------|--------------|------------|
| **Program** | A set of packages and modules forming a build unit. | [Program Structure](syntax/010_ProgramStructure.md) |
| **Variables** | Explicitly declared, strongly typed bindings. | [Variables](syntax/030_Variables.md) |
| **Functions** | First-class citizens with value and pointer receivers. | [Functions](syntax/040_Functions.md) |
| **Structs** | Predictable layout composite types. | [Structs](semantics/130_Structs.md) |
| **Slices & Maps** | Safe, efficient data structures with value semantics. | [Slices](semantics/100_Slices.md), [Maps](semantics/110_Maps.md), [HashMaps](semantics/111_HashMaps.md) |
| **Errors** | Typed error handling — no exceptions. | [Errors](semantics/140_Errors.md) |
| **Modules** | Importable units of code; no hidden side effects. | [Modules and Imports](syntax/090_ModulesAndImports.md) |

---

## 2.4 Type System Overview

Ori enforces **strong, static typing**.  
Every variable and expression has a well-defined type at compile-time.

Key properties:
- Type inference where unambiguous (`var x = "Ori"` ⇒ `string`).
- Explicit conversions (`int(a)`), no silent coercions.
- User-defined types via `type` and `struct`.
- No implicit nilability — pointers and optionals are distinct types.

See: [Types](syntax/050_Types.md)

---

## 2.5 Memory and Ownership Model

Ori follows a **value-first memory model** similar to Go, with explicit reference types where needed.

- Structs, arrays, and primitives are passed **by value** by default.
- References are explicit (`&T` / `*T` planned for pointer-like types).
- Slices, strings, and maps are *views over data* with defined copy semantics.
- No hidden allocations — all growth operations (e.g., `append`) may allocate.

See: [Types and Memory](semantics/150_TypesAndMemory.md)

---

## 2.6 Control Flow

Ori provides familiar structured control flow constructs:

- `if` / `else` statements.
- `for` loops with range iteration.
- `switch` expressions for pattern-based dispatch.
- `return`, `break`, and `continue` for flow control.

See: [Statements](syntax/060_Statements.md)

---

## 2.7 Language in Context

| Feature | Ori | Go | Rust | Zig |
|----------|-----|----|------|-----|
| Memory Model | Value + explicit refs | GC | Ownership | Manual/Allocator |
| Errors | `T, error` | `error` | `Result` | `error union` |
| Generics | Yes | Yes (Go 1.18+) | Yes | Yes |
| FFI | Yes | Yes | Yes | Yes |
| Build Philosophy | Unified toolchain | Unified | Cargo-based | Self-hosted |

---

## 2.8 Next Steps

Continue reading:
- [Program Structure](syntax/010_ProgramStructure.md)
- [Declarations](syntax/020_Declarations.md)
