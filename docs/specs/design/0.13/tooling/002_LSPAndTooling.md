# 002. LSP And Tooling

## 002.1 Overview of Ori Language Server Protocol (LSP) & Tooling Capabilities Specification

This document specifies the required Language Server Protocol (LSP) and tooling capabilities for Ori.  
The goal is to define a deterministic, explicit, and compiler-driven tooling experience aligned with Ori’s philosophy.

The Ori LSP does not attempt to guess developer intent. All semantic information must originate from the compiler’s official semantic engine, ensuring correctness, consistency, and predictability across all development environments.

---

## 002.2. Goals and Non-Goals

## 002.2.1 Goals

- Provide deterministic diagnostics consistent with compiler error rules
- Offer essential IDE support: navigation, hover info, and code outline
- Integrate tightly with the Ori compiler in "LSP mode" for semantic queries
- Support Ori language constructs including generics, interfaces, sum types, pointers, modules, and compile-time features
- Guarantee no deviation between compiler semantics and LSP behavior

---

## 002.2.2 Non-Goals

- Rename symbol capability (postponed)
- Auto-import suggestions
- LSP-driven refactoring
- Semantic guessing or heuristic symbol resolution
- Any feature that modifies code automatically beyond diagnostics

---

## 002.3. Overview of the Ori Tooling Architecture

Ori tooling consists of:
- The official Ori compiler, which provides parsing, AST construction, symbol tables, type inference, module resolution, semantic checking, and error reporting
- The Ori LSP server, which acts as a thin layer wrapping compiler functionality, exposing it through LSP APIs
- Editors and IDEs communicating with the LSP via standard LSP messages

The LSP must NOT replicate compiler logic. It must always delegate to the compiler for:
- Parsing
- Type resolution
- Semantic checks
- Module resolution
- Generic instantiation
- Sum type resolution
- Interface conformance checks

---

## 002.4. Interaction Between Compiler and LSP

## 002.4.1 Compiler LSP Mode
The Ori compiler exposes a stable interface ("LSP mode") allowing:
- Incremental parsing (file-by-file or buffer-by-buffer)
- Access to the AST for each file
- Access to the symbol table for each module
- Semantic analysis for changed files and dependent modules
- Error and diagnostic extraction in a stable JSON format
- Queries for definitions, symbol resolution, and type information
- Queries for module and import resolution

---

## 002.4.2 Incremental Analysis Rules

The compiler must support incremental re-analysis of:
- Modified files
- All files that depend on modified symbols
- Modules impacted by changed imports

Incremental analysis must be deterministic and follow the same rules as a full build.

---

## 002.5. Required Capabilities

## 002.5.1 Syntax Diagnostics

The LSP must provide parser-level errors including:
- Unexpected tokens
- Unmatched delimiters
- Invalid literals
- Incorrect statement structure
- Lexical errors

These diagnostics come straight from the compiler parser.

---

## 002.5.2 Semantic Diagnostics

The LSP must provide full compiler-driven semantic diagnostics including:
- Undefined identifier
- Type mismatch
- Incorrect number of arguments
- Invalid interface implementation
- Invalid pointer usage
- Violations of container ownership rules
- Invalid sum type variant access
- Invalid module imports
- Duplicate declarations
- Unused imports (compile-time error)
- Unreachable code (compile-time error)

All diagnostics must follow the compiler error format defined in `tooling/001_CompilerDiagnostics.md`

No diagnostic or error text must come from the LSP itself.

---

## 002.5.3 Symbol Resolution (Go-To Definition)

The LSP must support navigating to the definition of:
- Structs
- Interfaces
- Functions
- Methods
- Constants
- Types
- Generic instantiations (when instantiated)
- Sum type variants
- Module definitions
- Import targets

Resolution must follow the compiler's exact semantic rules.

---

## 002.5.4 Hover Information

The LSP must display:
- Type of the identifier or expression
- Symbol kind (struct, function, interface, sum type, const, etc.)
- Module path
- Source definition location
- For structs: list of fields with types
- For functions: full signature including generic parameters
- For comptime functions: [comptime] tag
- For extern items: [extern] tag
- For sum types: list of variants

Hover text must be deterministic.

---

## 002.5.5 Document Symbols (Outline)

The LSP must provide a hierarchical outline of:
- Structs
- Interfaces
- Sum types and variants
- Functions
- Comptime functions
- Constants

Symbols appear in source order (not alphabetical).

---

## 002.5.6 Text Synchronization

The LSP must support:
- Full document sync
- Optional incremental sync (if implemented)

The compiler must be able to parse unsaved buffers for real-time diagnostics.

---

## 002.6. Optional Capabilities (v1.0+)

## 002.6.1 Find References

Requires global indexing.
Postponed.

---

## 002.6.2 Rename

Rename must respect:
- Exported symbol constraints
- Interface contracts
- Module boundaries
- No shadowing

Postponed in future version.

---

## 002.6.3 Auto-Import Suggestions

Not allowed in current version.
Ori does not allow heuristic guesses.

---

## 002.6.4 Formatting

May be introduced later alongside a formatter design in `ecosystem/`.

---

## 002.7. Behavior With Advanced Language Features

## 002.7.1 Generics

- The LSP displays generic signatures
- Monomorphized instantiations are shown only if the compiler already emitted them
- No speculative instantiation

---

## 002.7.2 Sum Types

- Hover must display all variants and fields
- Go-to-definition jumps to variant definitions
- The LSP must respect compile-time variant safety rules

---

## 002.7.3 Interfaces

- Hover must display required methods
- Implementation relations come from semantic analysis only

---

## 002.7.4 Pointers and Container Ownership

- Hover must reflect pointer type, ownership, and mutability constraints
- Diagnostics integrate rules from:
  - `semantics/310_Pointers.md`
  - `semantics/260_ContainerOwnershipModel.md`

---

## 002.7.5 Modules and Imports

- LSP uses the compiler module resolver from `semantics/270_ModulesAndCompilationUnits.md`
- Handles:
  - absolute imports
  - relative imports
  - module root detection

---

## 002.7.6 Compile-Time Functions

- Hover marks functions as [comptime]
- Resolver must show comptime-only symbols clearly
- Reflection (if defined in compile-time reflection section) is exposed but not executed

---

## 002.8. Deterministic Behavior and Error Ordering

LSP diagnostics must follow the exact ordering rules of the compiler:
- Primary error first
- Secondary errors following source order
- Deterministic ordering for multi-error groups
- No editor-specific reordering

---

## 002.9. Examples

Example hover for function:
```
func Add(a int, b int) int
```
Defined in: `math/add.ori:14`

Example hover for struct:
```
type User struct {
    name string
    age  int
}
```
Defined in: `user/user.ori:3`

Example hover for sum type:
```
type Shape =
    | Circle { radius int }
    | Rect   { w int, h int }
```

----

## 002.10. Future Directions

Future improvements may include:
- Full rename support
- Auto-import completion
- Semantic code actions
- Integration with formatter
- Index-driven global queries

These are excluded from current version to preserve deterministic behavior and avoid speculative semantics.
