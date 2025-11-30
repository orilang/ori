# 330. Build System and Compilation Pipeline

## 330.1 Overview

This document defines the official build system and compilation pipeline for Ori.  
It builds upon the module rules defined in `270_ModulesAndCompilationUnits.md`,
the testing rules in `300_TestingFramework.md`, and the FFI rules in `290_FFI.md`.

Ori uses **whole-program compilation (WPC)**, explicit build targets, static linking,
and predictable output directory conventions. The build system must remain explicit,
consistent, and minimal while supporting future extensibility.

The goals of the Ori build pipeline are:
- Provide a clear, deterministic compilation model
- Ensure static linking by default with no need for a C compiler
- Support explicit cross-compilation through architecture and OS flags
- Provide predictable and consistent directory layouts for all generated artifacts
- Allow optional emission of intermediate representations via explicit flags
- Treat tests as first-class builds using the same compilation pipeline

---

## 330.2 Build Commands

The Ori compiler provides the following core commands:

### 330.2.1 `ori build`

Builds the current module into a binary:
```ori
ori build
ori build --arch=x86_64 --os=linux --opt=release
```

---

### 330.2.2 `ori run`

Builds (if necessary) and runs the produced binary:
```ori
ori run
ori run --arch=aarch64 --os=macos --opt=release
```

---

### 330.2.3 `ori test`

Discovers and builds test files (`*_test.ori`) and executes tests:
```ori
ori test
ori test --arch=x86_64 --os=linux --opt=release
```

Tests use the same compilation pipeline but produce a distinct test binary.

---

### 330.2.4 `ori build --emit=*`

Optionally emits intermediate artifacts such as IR (intermediate representation) or assembly:
```ori
ori build --emit=ir
ori build --emit=obj
ori build --emit=asm
```

Artifacts are placed in:
```ori
build/<arch>/<os>/<opt>/<module>/artifacts/
```

Nothing is emitted unless explicitly requested.

---

## 330.3 Build Flags

The Ori compiler accepts explicit and orthogonal build flags.

### 330.3.1 `--arch`

Target CPU architecture:
- `x86_64`
- `aarch64`
- `riscv64`

---

### 330.3.2 `--os`

Target operating system:
- `linux`
- `macos`
- `windows`

---

### 330.3.3 `--opt`

Optimization level. Ori does not use numeric levels like -O0/-O2 but explicit names:
- `release` (default)
- `aggressive`

---

### 330.3.4 Defaults
If unspecified:
```ori
--arch = host arch
--os   = host os
--opt  = release
```

---

## 330.4 Output Directory Structure

All Ori builds must produce output using the following structure:
```ori
build/<arch>/<os>/<opt>/<module>/
bin/       # final executable
tests/     # test binary (only for ori test)
artifacts/ # optional IR/asm/obj (only with --emit)
```

Example:
```ori
build/x86_64/linux/release/myapp/bin/myapp
build/x86_64/linux/aggressive/myapp/bin/myapp
build/aarch64/macos/release/myapp/tests/myapp_tests
build/x86_64/linux/release/myapp/artifacts/program.ir
```

This structure is stable, explicit, and fully deterministic.

---

330.5 ASCII Diagram — Output Directory Layout

```ori
build/
└── x86_64/
    └── linux/
        ├── release/
        │   └── myapp/
        │       ├── bin/
        │       │   └── myapp
        │       ├── tests/
        │       │   └── myapp_tests
        │       └── artifacts/
        │           ├── program.ir
        │           └── program.o
        └── aggressive/
            └── myapp/
                └── bin/
                    └── myapp
```
---

## 330.5 Compilation Pipeline

Ori uses a fixed and explicit 11-step compilation pipeline.

### 330.5.1 Step 1 — Input Discovery

- Locate module root using `ori.mod`.
- Verify the module name.
- Enumerate all `.ori` source files except test files (`*_test.ori`) unless running `ori test`.

---

### 330.5.2 Step 2 — Parsing → AST

All source files are parsed into ASTs. Parsing always produces ASTs directly; Ori does not use CSTs.
Syntax errors halt compilation.

---

### 330.5.3 Step 3 — Package Assembly

- ASTs belonging to the same package are merged.
- Mixed package names in a directory are compile-time errors.

---

### 330.5.4 Step 4 — Import Resolution

- Resolve import paths relative to module root.
- Validate rules from `270_ModulesAndCompilationUnits.md` (no cycles, no dot imports, no unused imports, etc.).
- Construct the full dependency graph of packages.

---

### 330.5.5 Step 5 — Type Checking & Semantic Analysis

The compiler applies all rules defined in the semantics layer:
- type system
- sum types
- generics
- deterministic destruction
- pointer safety
- concurrency constraints
- FFI validation
- compile-time execution (`comptime` rules)

---

### 330.5.6 Step 6 — Compile-Time Execution

All `comptime const` and `comptime func` calls are evaluated.
Only allowed CTE forms are permitted (`250_Compiletime.md`).

---

### 330.5.7 Step 7 — Generic Monomorphization

Generic functions, structs, and methods are instantiated for each concrete type parameter combination.
`const` generic parameters are resolved at compile time.

The output is a fully concrete, monomorphic program representation.

---

### 330.5.8 Step 8 — IR Generation

The fully-typed, monomorphized AST is lowered into Ori’s internal IR.
The IR format is *not* stable across compiler versions.

---

### 330.5.9 Step 9 — Optimization Passes

Depending on `--opt`:
- `release`: moderate optimization
- `aggressive`: maximum optimization (inlining, DCE, loop transforms)

---

### 330.5.10 Step 10 — Code Generation

Machine code is generated for the target architecture and OS.

---

### 330.5.11 Step 11 — Linking

Ori invokes the system linker directly:
- Linux: ld, lld, or gold
- macOS: ld64
- Windows: link.exe or lld-link

Ori never requires a C compiler for linking, only the system linker.

The result is placed in:
```ori
build/<arch>/<os>/<opt>/<module>/bin
```

---

## 330.6 Test Compilation Pipeline

Tests reuse the same compilation pipeline with these differences:
- Only files ending with `*_test.ori` are included.
- A `TestContext` type is automatically injected.
- The output binary is placed under:

```ori
build/<arch>/<os>/<opt>/<module>/tests
```

Example:
```ori
build/x86_64/linux/release/myapp/tests/myapp_tests
```

Test execution rules follow `300_TestingFramework.md`.

---

## 330.7 Extern and FFI Linking

FFI uses only the system linker. Ori's compiler:
- Does not parse C headers.
- Does not require a C compiler.
- Only links against `.o`, `.a`, `.so`, `.dylib`, `.dll` or platform equivalents.

The user must provide matching `extern` declarations according to `290_FFI.md`.
ABI mismatches are the responsibility of the programmer.

---

## 330.8 Detailed Compilation Walkthrough Example

This example shows exactly how a real Ori module is compiled.

Project structure:
```
myapp/
    ori.mod
    main.ori
    util/
        math.ori

```

Contents of ori.mod:
```
module myapp
```

`main.ori`:
```ori
package main
import "util/math"

func main() {
    var x = add(2, 3)
    println(x)
}
```

`util/math.ori`:
```ori
package math
func add(a int, b int) int {
    return a + b
}
```

**Step-by-step walkthrough**

1. Input Discovery:
  - Locate `ori.mod` → `module myapp`
  - Collect main.ori and `util/math.ori`

2. Parsing → AST:
  - ASTs generated for both files

3. Package Assembly:
  - `main.ori` → package main`
  - `util/math.ori` → `package math`

4. Import Resolution:
  - Resolve `util/math` → `<module_root>/util/math`
  - Build dependency graph: main → math

5. Type Checking:
  - Verify that `add(int, int) returns int`
  - Verify println exists in prelude or stdlib

6. Compile-Time Execution:
  - No comptime usage here

7. Monomorphization:
  - No generics involved:

8. IR Generation
  - Lower `add()` and `main()` to IR
  - Inline `add()` inside `main()` in release mode

9. Optimization:
  - Constant folding and DCE applied

10. Code Generation:
  - CPU-specific machine code emitted

11. Linking:
  - Link IR output into final executable:
    `build/x86_64/linux/release/myapp/bin/myapp`

---

## 330.9 Errors and Diagnostics

Build errors include:
- syntax errors
- semantic/type errors
- import cycle errors
- unused imports
- missing package clauses
- invalid FFI declarations
- linking errors

Diagnostic formatting is defined in `tooling/001_CompilerDiagnostics.md`.

---

## 330.10 Future Extensions

The build pipeline is designed to support:
- incremental builds
- multiple binaries per module
- build tags or conditional compilation
- dynamic linking (optional)
- stable cache formats
- parallel compilation stages
- package manager integration

These features are intentionally excluded to preserve simplicity and predictability.

---

## 330.10 Summary

Ori’s build system is:
- Whole-program compiled
- Statically linked
- Explicit and predictable
- Structured by `arch/os/opt/module`
- Simple by default
- Extensible later

The pipeline described above is authoritative for v0.9 and v1.0.
