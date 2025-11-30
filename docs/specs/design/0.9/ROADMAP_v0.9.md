# ROADMAP_v0.9.md

## Overview
This document outlines the planned milestones for Ori v0.9, focusing on build system integration, improved tooling, standard library foundations, and compile-time reflection enhancements.

## 1. Build System & Compilation Pipeline
- File: `semantics/330_BuildSystemAndCompilationPipeline.md`
- Outline the structure of the Ori build system, compiler flags, linking model, and integration with modules and FFI.
- Goals:
  - Define the semantics of building and linking Ori programs.
  - Provide predictable and reproducible builds.
  - Specify interaction with module and import systems.

## 2. Compiler Diagnostics Specification
- File: `tooling/001_CompilerDiagnostics.md`
- Define a consistent error reporting format with clear codes, messages, and suggestions.
- Goals:
  - Improve developer experience with clear and actionable diagnostics.
  - Standardize error messaging across the compiler and tooling.

## 3. LSP & Tooling Capabilities
- File: `tooling/002_LSPAndTooling.md`
- Specify the baseline capabilities needed for Ori-compatible editors and IDEs.
- Goals:
  - Support essential LSP features like go-to-definition, diagnostics, hover info, and symbol indexing.
  - Provide guidelines for future tooling like formatters and linters.

## 4. Standard Library Foundations
- File: `ecosystem/001_StandardLibraryFoundations.md`
- Define the structure and philosophy of the Ori standard library.
- Goals:
  - Establish a foundation for essential modules like memory, time, logging, and filesystem operations.
  - Provide a consistent and ergonomic API design.

## 5. Compile-Time Reflection (Phase 1)
- Primary File Update: `semantics/250_Compiletime.md`
- Optional New File: `semantics/340_CompiletimeReflection.md` (if scope grows)
- Introduce minimal reflection capabilities at compile-time for metadata inspection.
- Goals:
  - Enable safe and limited introspection of types, structs, and sum types.
  - Avoid macro-level features and maintain simplicity and safety.
