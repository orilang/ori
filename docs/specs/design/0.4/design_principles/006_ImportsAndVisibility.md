# 006. Imports and Visibility

Ori enforces a **clean, explicit, and deterministic** import system.  
No blank imports, no dot imports, no wildcards, and no hidden runtime initialization.  
Imports exist purely for code visibility and linking — not side effects.

> “Only what you import, you use — and only what you export, others see.”

---

## 1. Design Principles

| Principle | Description |
|------------|--------------|
| **Explicit imports** | Every import must use a string path and may include an alias. |
| **No blank or dot imports** | Hidden imports or namespace merges are forbidden. |
| **No wildcard imports** | Wildcard imports are forbidden — Ori will remain explicit. |
| **Scoped visibility** | Only imported names are visible; nothing leaks between modules. |
| **Public by capitalization** | Uppercase identifiers are exported; lowercase are internal. |
| **No runtime initialization** | There is no `init()` function or automatic global setup. |
| **Unused imports cause a compile-time error** | Explicitness is enforced — nothing implicit is allowed. |

---

## 2. Example: Correct Import Usage

```ori
package main

import "fmt"
import "os"
import net "http/net"

func main() {
    fmt.Println(os.Args)
    net.Get("http://orilang.org")
}
```

### Block Import Form

For readability, multiple imports can be grouped:

```ori
import (
    "fmt"
    "os"
    net "http/net"
)
```

Both forms are equivalent; grouping does not affect semantics.

---

## 3. Forbidden Import Forms

The following patterns are not allowed in Ori:

```ori
// ❌ Dot import — forbidden
import . "fmt"

// ❌ Blank import — forbidden
import _ "unsafe"

// ❌ Hidden initialization — forbidden
func init() { /* not supported */ }

// ❌ Wildcard or selective imports — forbidden
import "math" { Sin, Cos }
```

Ori disallows any import form that executes side effects or merges namespaces implicitly.
Wildcard or selective (e.g., `import "math" { Sin, Cos }`) imports won't be supported.

---

## 4. Global Scope Rules

- Only **`const`** declarations are allowed at the top level.  
- Global **mutable variables** are forbidden.  
- There is no `init()` function or implicit initialization phase.  
- Each module is loaded deterministically.

```ori
// ✅ Allowed
const Version string = "0.4"

// ❌ Forbidden
var Cache map[string]string // mutable global not allowed
```

---

## 5. Visibility Rules

| Symbol Type | Exported (Public) | Internal (Private) |
|--------------|------------------|--------------------|
| `FuncName` | ✅ | ❌ |
| `funcName` | ❌ | ✅ |
| `StructType` | ✅ | ❌ |
| `structType` | ❌ | ✅ |
| `CONST_NAME` | ✅ | ❌ |
| `varName` | ❌ | ✅ |

Public symbols are visible to importing modules; private ones remain internal.  
Visibility is lexical and determined by capitalization.

---

## 6. Compilation and Linking Behavior

Ori follows Go’s **clean linking model** rather than lazy compilation.

- When a package is imported, its source is **parsed and type-checked**.  
- Only **referenced identifiers** and their dependencies are included in the final binary.  
- **Unused imports cause a compile-time error.**  
- **Unused code** is eliminated during linking.

This ensures predictable and optimized binaries without partial or lazy compilation.

> “Only referenced code becomes part of the binary — nothing more, nothing hidden.”

---

## 7. Language Comparison

| Language | Import Behavior | Binary Impact |
|-----------|-----------------|---------------|
| Go | Compiles all, links only used symbols | Clean binaries |
| Zig | Compiles only referenced symbols | Lean, explicit |
| Rust | Compiles full modules, dead code eliminated by LLVM | Moderate |
| **Ori** | Compiles all, links only used symbols | Clean and predictable |

Ori intentionally mirrors Go’s deterministic linking strategy for simplicity and transparency while rejecting Go’s runtime initialization behaviors.

---

## 8. Future Directions

- Further compiler optimization for dependency resolution.

---

## 9. Summary

Ori’s import and visibility rules ensure clean namespaces and deterministic linking.  
No hidden imports, no runtime initialization, and no ambiguity in visibility or linkage.

> “If it’s imported, you see it. If it’s exported, you named it.”
