# 140. Errors

Ori’s error model is **explicit**, **predictable**, and **minimal**.  
Errors are values that functions return and callers must handle.  
There are **no exceptions** or hidden control flow.  
The `try` keyword exists only to reduce boilerplate when propagating errors.

---

## 140.1 Design Philosophy

**Explicit handling** — functions that can fail must declare an `error` result; callers must check it.  
**No hidden control flow** — no throw/catch, no panic-driven recovery in the language core.  
**Concise propagation** — `try EXPR` returns early if `EXPR` produces a non-`nil` error.  
**Custom errors** — structured error types are encouraged; `error("msg")` is provided for generic cases.  
**Small and orthogonal** — complements Ori’s clarity-first philosophy.

> Errors are values, not exceptions.

---

## 140.2 Built-ins

| Function / Keyword | Description | Example |
|--------------------|-------------|---------|
| `error(msg)` | Create a generic error value with message `msg`. | `return error("invalid state")` |
| `nil` | Zero value for the `error` type (means “no error”). | `return nil` |
| `try` | Propagate an error upward if present; otherwise yield the non-error value. | `data := try read()` |

**Notes**

`nil` is **only** the zero value for `error` (and other reference-like types); it does **not** imply general zero-values for structs.  
`try` may only appear inside functions that return an `error` result; otherwise it is a compile-time error.

---

## 140.3 Grammar

```
ErrorType     = "error" .
ErrorLiteral  = "error" "(" String ")" .
TryExpr       = "try" Expression .
ReturnStmt    = "return" [ ExpressionList ] .
FuncResult    = Type | "(" Type { "," Type } ")" .
FuncDecl      = "func" Identifier "(" [ Parameters ] ")" [ FuncResult ] Block .
```

**Conventions**

A function that uses `try` **must** declare an `error` in its `FuncResult`.  
`(T, error)` is idiomatic when a value is returned alongside an error.

---

## 140.4 Declaring and Returning Errors

### Simple error return
```ori
func readFile(path string) (string, error) {
    if !exists(path) {
        return "", error("file not found: " + path)
    }
    data := os.readAll(path)
    return data, nil
}
```

### Explicit caller check
```ori
data, err := readFile("/etc/ori.conf")
if err != nil {
    fmt.Println("read error:", err)
    return
}
fmt.Println("config:", data)
```

---

## 140.5 Propagation with `try`

`try` expands to the standard “check-and-return” pattern, avoiding repetition.

```ori
func loadConfig(path string) (Config, error) {
    raw  := try readFile(path)     // if error, returns it immediately
    cfg  := try parseConfig(raw)   // if error, returns it immediately
    return cfg, nil
}
```

Roughly equivalent to:
```ori
raw, err := readFile(path)
if err != nil { return nil, err }
cfg, err := parseConfig(raw)
if err != nil { return nil, err }
return cfg, nil
```

**Rules**

`try E` is valid if the enclosing function returns `error`.  
If `E` yields `(T, error)`, `try E` evaluates to `T` when error is `nil`, or **returns** the error otherwise.

---

## 140.6 Custom Error Types

Structured errors improve clarity and debuggability.

```ori
struct IOError {
    path string
    msg  string
}

func (e IOError) String() string {
    return "io: " + e.path + " — " + e.msg
}

func open(path string) (File, error) {
    if !exists(path) {
        return File{}, IOError{path: path, msg: "not found"}
    }
    return File{/* ... */}, nil
}
```

**Notes**

Any type that implements `String() string` can be printed as an error.  
Use custom error fields (path, op, cause, code) instead of encoding details into a single string.

---

## 140.7 Patterns and Idioms

### Guard + return
```ori
cfg, err := loadConfig(path)
if err != nil { return err }
use(cfg)
```

### Switch-like handling by type
```ori
_, err := open("/restricted/secret")
if err != nil {
    if err == PermissionError {
        fmt.Println("denied")
        return err
    }
    return err
}
```

### Wrap with context (convention)
```ori
func readUser(path string) (User, error) {
    data, err := readFile(path)
    if err != nil {
        return User{}, error("readUser: " + err.String())
    }
    return parseUser(data)
}
```

---

## 140.8 Interop and Concurrency Notes

**FFI:** map foreign error codes to Ori error values at the boundary; avoid leaking integers.  
**Goroutines/Tasks:** prefer sending errors over channels or returning them from task joins.  
**Logging:** prefer structured log fields over string concatenation; keep the error as a value.

---

## 140.9 Anti-patterns to Avoid

- **Ignoring errors:** `_ := read()` (discarding the error) — only safe if you are absolutely sure.  
- **Stringly-typed errors:** avoid parsing error messages; prefer concrete types.  
- **Overusing generic `error("...")`:** provide custom types when the caller may need to branch on them.

---

## 140.10 Examples (End-to-End)

### Parsing with staged validation
```ori
func loadUsers(p string) ([]User, error) {
    raw   := try readFile(p)
    lines := split(raw, "  n")
    users := make([]User, 0, len(lines))
    for _, line := range lines {
        u, err := parseUser(line)
        if err != nil {
            // Continue-on-error policy chosen here
            fmt.Println("skip:", err)
            continue
        }
        users = append(users, u)
    }
    return users, nil
}
```

### Early return on invalid arguments
```ori
func sqrt(n float64) (float64, error) {
    if n < 0 {
        return 0, error("sqrt: negative input")
    }
    return math.sqrt(n), nil
}
```

---

## 140.11 Design Rationale (Concise)

Keeping **Go-style explicitness** avoids hidden control flow and surprises.  
Adding **`try`** removes boilerplate while preserving visibility.  
Supporting **custom error types** improves correctness, testing, and recovery strategies.  
A **small set of built-ins** keeps the model easy to teach and consistent across the standard library.

---

## 140.12 Future Extensions

- Pattern matching & destructuring for error types.
- Error wrapping helpers with provenance metadata (cause/trace).
- Lints for unchecked results and unreachable branches after `try`.
- Tooling for error-flow visualization in functions and APIs.

---

## References

- [010_ProgramStructure.md](syntax/010_ProgramStructure.md)  
- [050_Types.md](syntax/050_Types.md)  
- [060_Statements.md](syntax/060_Statements.md)  
