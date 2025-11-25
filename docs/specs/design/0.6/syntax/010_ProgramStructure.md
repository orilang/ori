# 10. Program Structure

This section describes how an Ori program is organized — from packages and files to the entry point of execution.

---

## 10.1 Overview

An Ori program is composed of one or more **packages**.  
Each package is a directory containing one or more `.ori` source files that share the same package name.

Packages provide a namespace and form the basic unit of compilation and dependency management.

```text
myapp/
 ├── main.ori
 ├── util/
 │    ├── strings.ori
 │    └── math.ori
 └── net/
      └── client.ori
```

---

## 10.2 Package Declaration

Every `.ori` source file begins with a package declaration:

```ori
package main
```

The package name defines the namespace of the file.  
All files in the same directory must share the same package name.  
A `main` package indicates that the program is an executable with an entry point (`main` function).

---

## 10.3 Import Declarations

Imports bring other packages or modules into the current scope:

```ori
import "fmt"
import "net/http"
```

Multiple imports can be grouped:

```ori
import (
    "fmt"
    "math"
    "net"
)
```

Ori allows optional **import aliases** for disambiguation:

```ori
import io "os/io"
```

- The alias `io` is used to reference the imported package
- The underscore `_` alias (blank import) is forbidden
- The dot `.` import is forbidden

See: [Modules and Imports](syntax/090_ModulesAndImports.md)

---

## 10.4 The `main` Function

The entry point of an Ori executable is the `main` function inside the `main` package:

```ori
package main

func main() {
    fmt.Println("Hello, Ori!")
}
```

- The function must have no parameters and no return value.
- The program terminates when `main` returns.

---

## 10.5 Program Execution Model

Execution begins with package initialization in dependency order, followed by `main`.

1. Imported packages are initialized in dependency order.
2. Global constants are set up.
3. Global variables are forbidden.
4. The `main.main()` function is invoked.

This deterministic initialization ensures reproducibility and predictability.

---

## 10.6 File Layout Guidelines

Recommended file organization:

| File Type | Purpose |
|------------|----------|
| `main.ori` | Entry point of executable package. |
| `*.ori` | Standard source files within the same package. |
| `_test.ori` | Optional test files. |

Example layout:

```text
math/
 ├── math.ori
 └── vector.ori
main/
 └── main.ori
```

---

## 10.7 Example Program

```ori
package main

import (
    "fmt"
    "math"
)

func main() {
    var x float = 2.0
    var y = math.Sqrt(x)
    fmt.Println("√", x, "=", y)
}
```

---

## References
- [Declarations](syntax/020_Declarations.md)
- [Modules and Imports](syntax/090_ModulesAndImports.md)
