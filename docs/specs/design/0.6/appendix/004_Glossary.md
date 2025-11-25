# 004. Glossary

This glossary defines core terms used in the Ori language specification (v0.5).  
Each term has a single, explicit meaning in the context of the language.

---

### Alias
An alternate name for an imported package.  
```ori
import net "http/net"
```

---

### Block
A sequence of statements enclosed in braces `{ ... }`.  
Defines a new scope for variables and deferred operations.

---

### Channel
A typed conduit used for communication between concurrent routines.  
Channels are **explicitly created**, **typed**, and **not thread-safe by default**.

---

### Compile-time
The stage where the Ori compiler analyzes, type-checks, and optimizes code before binary generation.  
All type and syntax errors are caught here.

---

### Const
An immutable value known at compile time.  
Must be explicitly declared and initialized.

---

### Error
A first-class value representing a recoverable problem.  
Errors are never implicit; they must be handled, propagated (`try`), or explicitly ignored (compile-time error if not).

---

### Fallthrough
A keyword used in `switch` statements to continue execution into the next case explicitly.  
Implicit fallthrough is not supported.

---

### Function
A reusable block of code defined with `func`.  
Can return multiple values and must declare all result types.

---

### Global Variable
Forbidden in Ori. Only `const` declarations are allowed at the package level.

---

### Import
Brings external modules into scope.  
No wildcard, blank, or dot imports are supported.

---

### Interface
A future concept for describing contracts between types.  
Reserved but not implemented in v0.5.

---

### Map
An ordered associative container for key-value pairs.  
Keys must be comparable; modifying during iteration is prohibited.

---

### HashMap
An unordered associative container with constant-time access.  
Not thread-safe; must use synchronization when shared.

---

### Nil
Represents the absence of a value (uninitialized reference, map, slice, or error).  
Used explicitly — not as an implicit default.

---

### Ownership

A planned memory model concept for controlling value lifetimes and preventing data races (future version).

---

### Panic
A runtime stop triggered by `panic(msg)` or failed assertions.  
Includes file and line number information.

---

### Rune
Represents a single Unicode code point.  
Equivalent to a `char` in C, but safe for multibyte characters.

---

### Shared
A qualifier for referencing values without copying.  
Future feature for fine-grained control over memory semantics.

---

### Slice
A dynamic view of an array with length and capacity.  
Never reallocates implicitly — operations are explicit.

---

### Struct
A composite type grouping named fields.  
Fields must be explicitly initialized; no zero-value defaults exist.

---

### Try
Keyword for propagating errors upward.  
Short-circuits the function execution if an error is encountered.

---

### View
A planned qualifier for referencing non-owning slices or string sections without copying.  
Intended for safe, efficient read-only access.

---

> Ori’s terminology emphasizes **explicitness**, **predictability**, and **safety** —  
> every construct behaves visibly, with no hidden behavior or implicit side effects.
