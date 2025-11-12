# 90. Modules and Imports

Modules and imports in Ori define how source code is organized, shared, and reused across packages.

---

## 90.1 Overview

Modules group related packages into a single distribution unit.\
Imports bring external or internal packages into scope in an explicit and predictable way.

Ori’s import system is designed for **clarity** and **safety**:
- No implicit side effects
- No global variables
- No automatic initialization functions

```ori
package main

import "fmt"

func main() {
    fmt.Println("Hello, Ori!")
}
```

---

## 90.2 Module Definition

Modules are defined by a top-level manifest file (planned for v0.5) or inferred from directory structure.

Example project layout:

```text
example/
 ├── ori.mod          # (planned) module descriptor
 ├── main.ori
 └── math/
      └── calc.ori
```

---

## 90.3 Package Declaration

Each `.ori` file must begin with a `package` clause that identifies the namespace it belongs to:

```ori
package math
```

All files in the same directory share the same package name.

---

## 90.4 Import Declaration

Imports bring other packages into scope.  
There are three valid forms:

### Single Import
```ori
import "fmt"
```

### Grouped Import
```ori
import (
    "fmt"
    "math"
)
```

### Aliased Import
```ori
import io "os/io"
```

The alias can be any valid identifier. Use meaningful names to avoid conflicts.

---

## 90.5 Prohibited Imports Forms

To maintain explicitness and avoid hidden effects, Ori **does not support**:

| Syntax | Status | Reason |
|---------|---------|--------|
| `import _ "pkg"` | ❌ Not supported | No hidden initialization side effects |
| `import . "pkg"` | ❌ Not supported | Prevents namespace pollution |

Imports must always use a clear alias or the package’s own name.

---

## 90.6 Global State and Initialization

Ori does **not** allow global mutable variables.  
Only compile-time constants (`const`) are permitted at the package level.

```ori
package config

const DefaultPort int = 8080  // ✅ allowed
var GlobalValue   int = 42    // ❌ invalid — no global variables
```

---

## 90.7 No `init()` Functions

Ori does **not** support automatic `init()` functions.\
All initialization must occur through explicit function calls.

Example:

```ori
func setup() {
    ...
}

func main() {
    setup()
}
```

## 90.8 Import Resolution

Imports are resolved relative to the module root.\
Cyclic imports are **not permitted**.\
Each package is initialized only when its contents are explicitly referenced.

---

## 90.9 Example

```ori
package main

import (
    "fmt"
    format "fmt"
)

const Version = "0.4"

func main() {
    format.Println("Ori v", Version)
    fmt.Println("Done")
}
```

---

## 90.9 Future Extensions

Planned for later versions:
- Module versioning metadata (`ori.mod`)
- Private/internal import visibility
- Local and remote package registries

---

## References
- [Program Structure](syntax/010_ProgramStructure.md)
- [Declarations](syntax/020_Declarations.md)
