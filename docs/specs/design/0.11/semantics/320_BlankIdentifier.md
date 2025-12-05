# 320. Blank Identifier `_`

The blank identifier `_` in Ori is a **pure discard target**.  
It does not bind a name, it cannot be referenced, and it has no semantic meaning beyond discarding a value.

Ori’s design philosophy emphasizes explicitness and predictable behavior.  
Therefore, `_` is intentionally limited and cannot be used as a wildcard pattern or implicit match binding.

---

## 320.1 Overview

The blank identifier:
- Never introduces a variable
- Never participates in the symbol table
- Cannot be referenced or shadowed
- Runs destructors on discarded **temporary** values
- Does *not* run destructors on discarded **views** (because such usage is forbidden)
- Is permitted only in clearly defined positions

---

## 320.2 Allowed Usages

### 320.2.1 Discarding a Returned Value

```
_ = compute()
x, _ = getPair()
```

### 320.2.2 Function Parameters

```
func handleEvent(_ string, code int) {
    // first parameter intentionally ignored
}
```

### 320.2.3 Loop Iteration

```
for _, value := range items {
    // index ignored
}

for index, _ := range items {
    // value ignored
}
```

### 320.2.4 Assigning to `_` (not declaring)

This is allowed:

```
_ = viewSlice(someArray)   // OK
```

This is **not** allowed:

```
var _ = viewSlice(someArray)   // ❌ forbidden
```

Rationale:  
`var _ = ...` implicitly introduces a variable declaration, which does not make sense for a discard target.  
A simple assignment `_ = expr` is allowed because `_` is not being declared — it is only discarding the value.

---

## 320.3 Forbidden Usages

### 320.3.1 Variable Declarations

```
var _ = value        // ❌ forbidden
const _ = 1          // ❌ forbidden
```

### 320.3.2 Pattern Matching

```
switch x {
    case _:      // ❌ wildcard matches forbidden
}
```

Ori requires explicit and exhaustive matching for sum types and patterns.  
Wildcard matches undermine this safety guarantee.

### 320.3.3 Imports

Wildcard imports are forbidden:

```
import "fmt" _                // ❌ forbidden
import "math" { Sin, _ }      // ❌ forbidden
```

### 320.3.4 As a Field Name

```
type struct User {
    _ int      // ❌ forbidden
}
```

### 320.3.5 As a Return Value Placeholder

```
func load() (_, int)          // ❌ forbidden
```

Return value names must be real identifiers.

### 320.3.6 Future-Proofing: No Destructuring Wildcards

Even if destructuring syntax is introduced in future versions, `_` cannot appear in it:

```
(x, _, z) = getTuple()        // ❌ forbidden
```

---

## 320.4 Destructor Semantics

Even though `_` does not introduce a variable, discarding a **temporary value** must still run its destructor:

```
_ = openFile()   // destructor will run immediately after assignment
```

This ensures deterministic resource safety.

However, `_` **cannot** be used in any context that extends the lifetime of a view or shared reference:

```
var _ = viewSlice(arr)   // ❌ forbidden
_ = viewSlice(arr)       // ✔️ allowed (no lifetime extension)
```

---

## 320.5 Compiler Rules Summary

- `_` is a special token, not an identifier.
- `_` cannot appear in declarations.
- `_` cannot be referenced.
- `_` may appear in assignment, parameters, and loop bindings.
- `_` never stores a value.
- `_` runs destructors for temporary values.
- `_` never affects lifetime analysis.
- `_` cannot appear in pattern matching or destructuring.
- `_` triggers no warnings for “unused” semantics.

---

## 320.6 Summary Table

| Context                         | Allowed? | Notes |
|---------------------------------|----------|-------|
| `var _ = expr`                  | ❌       | `_` cannot declare a variable |
| `_ = expr`                      | ✔️       | Discards value, destructor runs |
| `x, _ = expr`                   | ✔️       | Discard secondary value |
| Function parameter              | ✔️       | Ignores param |
| Loop index/value                | ✔️       | Discards position/value |
| Pattern matching                | ❌       | No wildcard matches |
| Imports                         | ❌       | No wildcard or selective `_` imports |
| Struct field name               | ❌       | `_` cannot be a field |
| Function return names           | ❌       | Must be explicit |
| Destructuring bindings          | ❌       | Forbidden now & future |
