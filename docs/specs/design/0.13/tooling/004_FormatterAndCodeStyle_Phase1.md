# 004. Formatter and Code Style – Phase 1

## 004.1 Overview

This document defines the **canonical code style** for Ori source files and the behavior of the official formatter (`ori fmt` subcommand).

The formatter has three core goals:
1. **Idempotence** – formatting a file multiple times must not change it after the first pass.
2. **Determinism** – the same input program always produces the same formatted output, regardless of machine, OS, or environment.
3. **Zero configuration** – the formatter enforces a single canonical style for all Ori codebases.

`Phase 1` focuses on:
- Top-level file layout (package, imports, declarations).
- Indentation, braces, and spacing rules.
- Basic treatment of comments, blank lines, and line wrapping.
- CLI contract for `ori fmt`.

Later phases may extend the formatter with more advanced layout rules (complex expression wrapping, alignment heuristics, etc.), but must remain backwards-compatible with this document.

---

## 004.2 Goals and Non-Goals

### 004.2.1 Goals

- Provide a **single, unambiguous style** for all Ori source files.
- Ensure the formatter is a **pure source-to-source transform**:
  - It does not change semantics.
  - It does not depend on build flags or optimization level.
- Integrate cleanly with the CLI tooling:
  - `ori fmt` can be run on individual files, directories, or modules.
- Preserve user comments and meaningful blank lines as far as possible, while still normalizing layout.

### 004.2.2 Non-Goals

- The formatter does **not**:
  - Attempt to “simplify” or refactor code.
  - Rename identifiers or re-order top-level declarations for semantics.
  - Analyze or enforce semantic invariants (that is the compiler’s job).
- Phase 1 does **not**:
  - Define project-wide style configuration.
  - Provide special handling for future features (`unsafe`, FFI-related syntax, etc.), beyond basic syntactic layout.

---

## 004.3 CLI and High-Level Behavior

### 004.3.1 `ori fmt` Command

The formatter is exposed as:

```text
ori fmt <paths...>
```

Rules:
- If no paths are provided, `ori fmt` formats the current module root (all `.ori` files under the current directory, respecting module boundaries).
- If a path is a file and ends with `.ori`, that file is formatted in-place.
- If a path is a directory, all `.ori` files within that directory tree are
  formatted in-place, excluding:
  - Generated code directories explicitly ignored by the build system (if any).
  - Vendor / cache directories, as defined elsewhere.

### 004.3.2 Exit Codes

- `0` – success, all files formatted or already formatted.
- Non-zero – fatal errors (invalid flags, syntax errors, I/O errors).

If a file cannot be parsed as valid Ori source:
- The formatter must not modify it.
- An error is printed, and the exit code is non-zero.

### 004.3.3 Idempotence and Stability

- Running `ori fmt` on already-formatted code must not change it.
- The formatter must be deterministic:
  - Same source → same output, regardless of filesystem order or platform.

---

## 004.4 General Formatting Rules

### 004.4.1 Whitespace and Indentation

- Indentation uses **spaces**, not tabs.
- Default indentation width is **4 spaces** per level.
- Nested blocks (`if`, `for`, `switch`, `func`, `type struct`, `type enum`) each increase indentation level by 1.

Example:
```ori
func main() {
    var x int = 10
    if x > 5 {
        println("big")
    } else {
        println("small")
    }
}
```

- No trailing whitespace at the end of lines.
- Files must end with a single newline character.

### 004.4.2 Braces

- Opening brace `{` is placed at the **end of the same line** as the construct it belongs to.
- Closing brace `}` is placed on its **own line**, aligned with the start of the construct.

Examples:
```ori
func add(a int, b int) int {
    return a + b
}

if condition {
    doSomething()
} else {
    doSomethingElse()
}

for i := 0; i < 10; i++ {
    println(i)
}

switch x {
case 0:
    println("zero")
default:
    println("other")
}
```

### 004.4.3 Spaces Around Tokens

The formatter enforces the following space rules:
- A **single space**:
  - After keywords which are followed by parentheses or identifiers:
    - `if`, `for`, `switch`, `func`, `type`, `package`, `import`.
  - Around binary operators: `+`, `-`, `*`, `/`, `%`, `==`, `!=`, `<`, `<=`,
    `>`, `>=`, `&&`, `||`, `&`, `|`, `^`, `<<`, `>>`.
  - Around assignment and declaration operators: `=`, `:=`, `+=`, `-=`, etc.
- **No space**:
  - Immediately inside parentheses, brackets, or braces:
    - `f(x, y)` not `f( x, y )`
    - `arr[0]` not `arr[ 0 ]`
  - Between a function name and the opening parenthesis of its parameter list:
    - `func add(a int, b int) int` not `func add (a int, b int) int`
  - Before commas, semicolons, or colons.

Example:
```ori
var x int = 10
x = x + 1
if x > 0 {
    println("positive")
}
```

---

## 004.5 File Structure

### 004.5.1 Package Clause

- The package clause must be the **first non-comment line** of the file.
- Format:
```ori
package mypackage
```

- A single blank line must follow the package clause (unless the file ends there).

### 004.5.2 Import Blocks

- All imports must be grouped into a single `import` block when there is more than one import.
- Single import:
```ori
import "os"
```

- Multiple imports:
```ori
import (
    "fmt"
    "os"
    "time"
)
```

- Imports are sorted **lexicographically** by their path.
- A single blank line must separate the `import` block from the following top-level declarations.

### 004.5.3 Top-Level Declarations

Top-level declarations include:
- `const` declarations
- `type` declarations
- `func` declarations (including test functions)

Formatting rules:
- A single blank line **between groups** of logically distinct declarations.
- No enforced reordering of declarations:
  - The formatter must not reorder top-level declarations since that can affect readability and, in rare cases, semantics (e.g. doc tooling).

Example:
```ori
package main

import (
    "os"
    "time"
)

const defaultTimeout Duration = 5 * time.Second

type struct Config {
    path   string
    repeat int
}

func main() {
    var cfg Config = loadConfig()
    run(cfg)
}
```

---

## 004.6 Declarations and Definitions

### 004.6.1 Function Declarations

- Parameter lists and return types are kept on a single line if they fit within a reasonable line length (line length heuristic is implementation-defined in `Phase 1` but should typically target around 100 characters).
- If wrapped, parameters are aligned one per line, indented by one level.

Examples (single-line):
```ori
func add(a int, b int) int {
    return a + b
}
```

Multi-line parameters:
```ori
func handleRequest(
    ctx Context,
    req Request,
    deadline Duration,
) Result {
    // ...
}
```

- An empty function body **without comments** is formatted as:
```ori
func noop() {}
```

- If the body contains comments, they are preserved on separate lines:
```ori
func noop() {
    // intentionally empty
}
```

### 004.6.2 Type Declarations

#### 004.6.2.1 Struct Types

- Each field appears on its own line.
- Fields are **not** aligned into vertical columns in Phase 1
  (to keep the formatter simpler and stable).
- A single blank line is allowed between logically grouped fields but is not inserted automatically by the formatter.

Example:
```ori
type struct Point {
    x int
    y int
}

type struct Config {
    path     string
    retries  int
    timeout  Duration
    fallback bool
}
```

The formatter enforces that:
- There is **no blank line immediately after** the opening `{` unless the next line is a comment.
- There is **no blank line immediately before** the closing `}`, unless the previous line is a comment.

So inputs like:
```ori
type struct Config {

    path     string
    retries  int
    timeout  Duration
    fallback bool
}
```

are normalized to:
```ori
type struct Config {
    path     string
    retries  int
    timeout  Duration
    fallback bool
}
```

#### 004.6.2.2 Enum Types

Formatting example:
```ori
type enum Color {
    Red
    Green
    Blue
}
```

- Enum variants appear one per line.
- No trailing comma after the last variant (Phase 1).

### 004.6.3 Variable and Constant Declarations

Ori forbids global `var` declarations. This section applies to:
- Top-level `const` declarations.
- Local `var`/`const` declarations inside functions and blocks.

Single declarations:
```ori
const defaultPort int = 8080

func example() {
    var count int = 0
}
```

Multiple declarations in a block:
```ori
const (
    ExitOK    int = 0
    ExitError int = 1
)

func example() {
    var (
        x int = 1
        y int = 2
    )
}
```

- The formatter preserves block vs non-block style but normalizes spacing and
  indentation.

---

## 004.7 Statements and Expressions

### 004.7.1 If Statements

- `if` condition on the same line as the keyword.
- `else` and `else if` on the same line as the closing brace of the previous block.

Example:
```ori
if x > 0 {
    println("positive")
} else if x == 0 {
    println("zero")
} else {
    println("negative")
}
```

### 004.7.2 For Loops

#### 004.7.2.1 Traditional For

```ori
for i := 0; i < 10; i++ {
    println(i)
}
```

#### 004.7.2.2 Range For

```ori
for i, v := range values {
    println(i, v)
}

for v := range values {
    println(v)
}
```

- The formatter enforces single spaces around `:=`, `<`, etc.

### 004.7.3 Switch Statements

Example:
```ori
switch value {
case 0:
    println("zero")
case 1:
    println("one")
default:
    println("other")
}
```

- `case` labels and `default` are indented one level inside the switch block.
- Statements inside each case are indented one additional level.

### 004.7.4 Return Statements

- `return` and expression are on the same line when short:

```ori
return x + 1
```

- For long expressions, the formatter may wrap according to its line-length
  heuristic, but Phase 1 does not strictly standardize wrapping beyond
  preserving validity and indentation.

---

## 004.8 Comments and Blank Lines

### 004.8.1 Line Comments

- Line comments use `//`.
- The formatter does not reflow or break comment text.
- A single space after `//` is preferred but not enforced on existing comments.

Example:
```ori
// loadConfig loads configuration from disk.
func loadConfig(path string) Config {
    // TODO: handle timeouts
    // NOTE: this is a blocking call
    return readConfigFromFile(path)
}
```

### 004.8.2 Block Comments

- Block comments use `/* ... */`.
- The formatter preserves internal formatting of block comments.

Example:
```ori
/* Multi-line comment
   explaining a complex piece of logic.
*/
func doSomething() {
    // ...
}
```

### 004.8.3 Blank Lines

- The formatter collapses **multiple consecutive blank lines** into a maximum of **one** blank line in most contexts.
- A single blank line is kept:
  - Between the package clause and imports.
  - Between imports and the first top-level declaration.
  - Between top-level declaration groups.
- Within function bodies:
  - Blank lines are kept as-is, except that runs of more than two blank lines may be reduced (implementation-defined, but `Phase 1` recommends collapsing 3+ blank lines into 2).
  - Blank lines **immediately after an opening `{`** or **immediately before a closing `}`** are removed, unless the next/previous line is a comment.

Examples input:
```ori
func example() {

    var x int = 0

}
```

Formatted:
```ori
func example() {
    var x int = 0
}
```

Input with an internal blank line:
```ori
func example() {
    var x int = 0

    doSomething()
}
```

Formatted (blank line preserved):
```ori
func example() {
    var x int = 0

    doSomething()
}
```

---

## 004.9 Interaction with Other Tooling

### 004.9.1 Build System

- `ori fmt` operates only on **source files**.
- It does **not** invoke the build pipeline and does not depend on `--opt` or other build flags.
- Typical workflow:

```text
ori fmt ./...
ori build
ori test
```

### 004.9.2 Diagnostics and Lints

- The compiler should not reject programs purely for formatting reasons.
- Diagnostics may **suggest** running `ori fmt` when:
  - Source does not conform to canonical layout.
  - E.g. "run `ori fmt` to normalize formatting".

### 004.9.3 Editors and IDEs

- Editors and IDEs are encouraged to integrate `ori fmt` as:
  - Format-on-save.
  - Before-commit hook in version control workflows.
- Tools should treat `ori fmt` as the **single source of truth** for code style.

---

## 004.10 Examples

### 004.10.1 Before / After Example

**Before:**

```ori
package main
import "time"
import "os"
type struct Config {

    path string
retries int
timeout Duration}

func main(){
var cfg Config=loadConfig()
if cfg.retries>0{
    run(cfg)
}else{
println("no retries")
}
}
```

**After `ori fmt`**:

```ori
package main

import (
    "os"
    "time"
)

type struct Config {
    path    string
    retries int
    timeout Duration
}

func main() {
    var cfg Config = loadConfig()
    if cfg.retries > 0 {
        run(cfg)
    } else {
        println("no retries")
    }
}
```

---

## 004.11 Future Extensions

Future phases of the formatter and style specification may:
- Add more precise rules for:
  - Line wrapping and breaking of long expressions.
  - Trailing commas in lists (e.g. allowing them in enums or parameter lists).
  - Alignment of composite literals.
- Introduce special handling for:
  - `unsafe` blocks, when/if they are added.
  - FFI-related declarations.
- Provide a stable machine-readable style description for external tooling.

Any such extensions must remain **backwards-compatible** with the rules in this document and must not invalidate already formatted code.
