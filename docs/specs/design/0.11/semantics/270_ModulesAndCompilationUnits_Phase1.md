# 270. Modules and Compilation Units - Phase 1

This document defines the complete rules for **modules**, **packages**, **imports**, **visibility**, and **compilation units** in Ori.  
It consolidates and extends the syntactic rules described in `090_ModulesAndImports.md` and formalizes how the compiler organizes and processes code.

Ori follows a **strict module and package system**, with additional restrictions to ensure predictability, safety, and clarity.

---

# 270.1 Module Root

A module is the top-level project unit.
Every Ori module **must** contain a manifest file:
```
ori.mod
```

This file defines:
- the module’s root directory
- the canonical base path for all import strings

If `ori.mod` is missing:
```
error: missing ori.mod file; every module must define a root manifest
```

Only **one** module root is allowed.
Nested modules are forbidden.

Example (valid):
```
myapp/
 ├── ori.mod
 ├── main.ori
 └── util/
      ├── math.ori
      └── debug.ori
```

Example (invalid — nested module):
```
myapp/
 ├── ori.mod
 └── vendor/
       └── otherlib/
             └── ori.mod   // ❌ nested module
```

---

## 270.1.1 ori.mod Manifest File Format

For now, the `ori.mod` file uses a minimal and explicit format.

It contains a single directive:
```
module <module-name>
```

Where `<module-name>` is an identifier naming the module.
Example:
```
module myapp
```

Rules:
- The module name must be a valid identifier (ASCII letters, digits, underscores; must not start with a digit).
- Only one directive is allowed in this version.
- Additional fields (dependencies, versions, vendor configuration, build options) will be introduced in future design versions.
- If the file contains anything other than a single `module` directive, the compiler must fail.

Invalid examples:

```
module 123app       // ❌ cannot start with digit
module myapp        // OK
module second       // ❌ multiple module directives
name myapp          // ❌ unknown directive
```

---

# 270.2 Project Layout

The module root contains:
- `.ori` source files
- directories containing Ori packages
- optional test files (future version)

Example of a well-structured module:

```
myapp/
 ├── ori.mod
 ├── main.ori
 ├── util/
 │    ├── math.ori
 │    ├── format.ori
 │    └── strings.ori
 └── net/
      └── http/
           ├── client.ori
           └── server.ori
```

Example (invalid — folder contains `.ori` but missing package clause):

```
myapp/log/
 └── logger.ori  // contains no package definition → ❌ error
```

---

# 270.3 Packages

A **package** is a directory of `.ori` files sharing a `package` clause:

```ori
package util
```

Rules recap:

1. All `.ori` files in the directory must have **the same** `package` name.
2. A package must not span multiple directories.
3. Package name must equal the **last segment of its import path**.
4. Empty directories are ignored.

Example:

```
import "crypto/aes"
```

means:

```
<module_root>/crypto/aes/
```

must contain files starting with:

```ori
package aes
```

Invalid example:

Directory:
```
myapp/crypto/aes/encrypt.ori
```

Content:
```ori
package crypt    // ❌ does not match folder name 'aes'
```

Error:
```
package name 'crypt' does not match expected package name 'aes'
```

Invalid example — mixed packages:

```
math.ori    → package util
debug.ori   → package log   // ❌
```

---

# 270.4 Compilation Units

A **compilation unit** is a single `.ori` file.

Rules:

- Exactly one `package` clause.
- Must be at top of the file.
- All files in the same directory share a single namespace.

Example (valid):

File: `util/math.ori`

```ori
package util

func Add(a int, b int) int { return a + b }
```

File: `util/helpers.ori`

```ori
package util

func clamp(x, min, max int) int { ... }
```

These two files can freely call each other’s functions:

```ori
func Foo(x int) int {
    return clamp(Add(x, 2), 0, 10)
}
```

Invalid examples:

```
package util
package other   // ❌ duplicate package clause
```

```
func test() {}   // ❌ missing package clause
```

---

# 270.5 Build Behavior

Compilation steps:

1. Determine module root using `ori.mod`.
2. Discover package directories.
3. Check each folder for a valid package name.
4. Resolve imports.
5. Build a **dependency graph** of packages.
6. Reject cycles.
7. Topologically sort packages.
8. Compile leaf packages first.
9. Compile parent packages last.
10. If there is a `main` package, build an executable; otherwise a library.

---

# 270.6 Import Rules

Import paths are directory paths relative to module root.

Valid:

```
import "fmt"
import "util"
import "net/http"
import "crypto/aead"
```

Invalid:

```
import "./fmt"         // ❌
import "../util"       // ❌
import "/abs/path"     // ❌
import "util/"         // ❌ trailing slash
import "util//math"    // ❌ double slash
import ""              // ❌ empty import path
```

Example of valid nested structure:

```
myapp/
 └── data/
      └── parser/
           ├── tokenizer.ori   → package parser
           └── reader.ori      → package parser
```

Imported with:

```ori
import "data/parser"
```

---

## 270.6.1 Import Forms

Allowed:

```
import "fmt"
import ("fmt" "math")
import io "os/io"
```

Forbidden:

```
import _ "fmt"
import . "fmt"
```

---

## 270.6.2 Alias Rules & Examples

### Valid alias:

```
import h "net/http"
```

### Conflicting alias name:

```
import http "net/http"
import http "my/http"   // ❌ conflict
```

### Alias conflicts with local identifier:

```ori
var http = 5
import http "net/http"  // ❌ alias shadows local variable
```

### Redundant imports:

```ori
import "fmt"
import "fmt"   // ❌ error
```

### Redundant after alias:

```
import f "fmt"
import "fmt"   // ❌ redundant; both map to same package
```

---

# 270.7 File and Package Interactions

Inside a package:

- File order does not matter.
- Top-level declarations from all files merge into one namespace.
- Duplicated names cause errors.

Example (valid multi-file type definition):

`user/user.ori`:

```ori
package user
type struct User {
    Name string
}
```

`user/methods.ori`:

```ori
package user
func (u User) Greet() string { return "Hello " + u.Name }
```

Invalid (duplicate):

```
type struct User { Name string }
type struct User { Age int }    // ❌ duplicate type
```

---

# 270.8 Visibility Rules

Case-based visibility:

Exported:
```
Name, User, Parse, HTTPServer
```

Internal:
```
name, user, parse, httpServer
```

Examples:

```ori
type struct User {
    Name string   // exported
    age  int      // internal
}
```

Another package can do:

```
u := User{Name: "Ori"}      // OK
println(u.Name)             // OK
println(u.age)              // ❌ cannot access internal field
```

---

# 270.9 Entry Points

Executables must include a `main` package and:

```ori
func main()
```

Examples:

File: `main.ori`

```ori
package main
import "fmt"

func main() {
    fmt.Println("Hello")
}
```

Invalid:

```
package main
func main() {}
func main() {}    // ❌ duplicate main
```

```
package util
func main() {}    // ❌ main() must be inside package main
```

---

# 270.10 Error Conditions (Full List with Examples)

### Missing ori.mod
```
error: missing ori.mod file
```

### Mixed package names:
```
file1.ori: package util
file2.ori: package fmt   // ❌
```

### Missing package clause:
```
func c() {}  // ❌ missing package
```

### Cyclic import:
```
util imports net
net imports util  // ❌ cycle
```

### Self-import:
```
import "util"   // from util/ → ❌
```

### Duplicate imports:

```
import "fmt"
import "fmt"   // ❌
```

### Alias conflicts:

```
import http "net/http"
var http = 5               // ❌
```

### Unused imports:

```
import "fmt"   // ❌ never referenced
```

### Duplicate top-level declarations:

```
const A = 1
const A = 2    // ❌
```

### Type cycles (value embedding):

```
type struct A { b B }
type struct B { a A }   // ❌ infinite size
```

Valid pointer cycle:

```
type struct A { b *B }
type struct B { a *A }  // OK
```

### Top-level var:
```
var x = 10   // ❌ no global vars
```

### Top-level statements:
```
package util
println("hi")   // ❌ not allowed
```

---

# 270.11 Valid Layout Examples

### Example A — Simple App

```
myapp/
 ├── ori.mod
 ├── main.ori
 └── util/
      ├── math.ori
      └── helpers.ori
```

### Example B — Multi-Level

```
service/
 ├── ori.mod
 ├── api/
 │    ├── server.ori
 │    └── request.ori
 └── core/
      ├── model.ori
      └── storage.ori
```

Imports:

```ori
import "api"
import "core"
import "core/storage"
```

---

# 270.12 Invalid Layout Examples

### Nested same-name directory:

```
util/
 ├── util.ori      → package util
 └── util/         // ❌ ambiguous namespace
```

### Two modules inside one tree:

```
app/
 ├── ori.mod
 └── lib/
      └── ori.mod   // ❌ not allowed
```

### Package name not matching folder:

```
crypto/hash/hmac.ori
package hash      // ❌ must be package hmac
```
