# 120. Strings

Strings in Ori are **immutable**, **UTF‑8 encoded** sequences of bytes representing text.  
They are designed for safety, predictability, and explicit handling of encoding and slicing.

---

## 120.1 Overview

A `string` in Ori is a **read-only value type** representing text data.  
It can be indexed and sliced like a byte sequence, but its content cannot be modified after creation.

```ori
var name string = "Ori Language"
fmt.Println(len(name)) // 12 bytes (UTF‑8 encoded)
```

### Key properties

| Property | Description |
|-----------|--------------|
| **Immutable** | Strings cannot be modified after creation. |
| **UTF‑8 encoding** | Every string is valid UTF‑8 by definition. |
| **Value semantics** | Assignments copy the descriptor (reference-counted or value‑copied). |
| **Safe indexing** | Access beyond bounds is a runtime error. |
| **Viewable** | Can be passed or sliced using the `view` qualifier. |

---

## 120.2 Declaration and Initialization

### Using string literals

```ori
var s string = "hello"
var multiline string = """Line 1
Line 2"""
```

Multi‑line strings preserve newlines and indentation exactly as written.

### From byte slices

```ori
var data []byte = []byte{72, 101, 108, 108, 111}
var s string = string(data)
```

The conversion checks that the byte sequence is valid UTF‑8.  
Invalid encodings cause a **runtime error**.

---

## 120.3 Immutability

Strings are immutable. Reassignment replaces the entire string; mutation by index is not allowed.

```ori
var s string = "abc"
s[0] = 'z' // ❌ compile-time error
```

To modify string content, convert to a mutable byte slice:

```ori
var b []byte = []byte(s)
b[0] = 'z'
var new string = string(b)
```

---

## 120.4 Length and Indexing

### Length
`len(s)` returns the number of **bytes**, not runes (code points).

```ori
var s string = "é"
fmt.Println(len(s)) // 2 bytes in UTF‑8
```

### Indexing
Indexing returns a **byte value** (type `byte`):

```ori
var first byte = s[0]
```

Accessing beyond range is a **runtime error**.

---

## 120.5 Slicing and Views

Strings can be sliced like arrays or slices using half‑open ranges.

```ori
var s string = "abcdef"
var sub string = s[2:5] // "cde"
```

### Bounds safety
All string slicing is **bounds-checked** at runtime.  
Invalid indices (`a > b` or `b > len(s)`) cause a runtime error.

### Shared views
Use the `view` qualifier for non‑owning substring references:

```ori
var s string = "hello world"
var sub view string = s[6:] // view of "world"
```

A `view string` shares memory with the original and cannot outlive it.

---

## 120.6 Concatenation

Concatenation creates a **new string**:

```ori
var a string = "hello"
var b string = "world"
var c string = a + " " + b
```

String concatenation allocates new memory for the combined data.

---

## 120.7 Comparison

Strings are compared lexicographically by Unicode scalar value.

```ori
if "abc" < "abd" {
    fmt.Println("true")
}
```

Comparisons are byte‑wise but since Ori enforces UTF‑8, the result is deterministic and well‑defined.

---

## 120.8 Conversion

### To bytes

```ori
var s string = "hello"
var b []byte = []byte(s)
```

### From bytes

```ori
var b []byte = []byte{72, 105}
var s string = string(b)
```

Invalid UTF‑8 bytes raise a **runtime error**.

### To rune slices

```ori
var r []rune = []rune(s)
```

A `rune` represents a Unicode scalar value (`int32`).

---

## 120.9 Constants

String constants are allowed and always UTF‑8:

```ori
const greet string = "Hello, Ori!"
```

String constants are stored in **read‑only memory** and may be referenced directly without allocation.

---

## 120.10 Built‑in Functions

| Function | Signature | Behavior |
|-----------|------------|-----------|
| `len` | `len(s string) -> int` | Number of bytes. |
| `copy` | `copy(src string, dst []byte)` | Copies bytes from `src` into `dst`. |
| `append` | `append(a string, b string) -> string` | Returns a new concatenated string. |
| `contains` | `contains(s, sub string) -> bool` | Checks substring presence. |
| `index` | `index(s, sub string) -> int` | Returns first occurrence index, -1 if missing. |
| `split` | `split(s, sep string) -> []string` | Splits string by separator. |
| `join` | `join(parts []string, sep string) -> string` | Joins slice into one string. |

All functions are pure and safe; they never modify input strings.

---

## 120.11 Comparison and Equality

Equality uses byte‑wise comparison:

```ori
if a == b {
    fmt.Println("equal")
}
```

The comparison is O(n) over the byte sequence.

---

## 120.12 Concurrency and Thread Safety

Strings are **thread‑safe** because they are immutable.  
They can be safely shared between threads or goroutines without synchronization.

---

## 120.13 Memory and Lifetime

Strings are immutable and reference‑counted or copy‑on‑write internally.  
Slices of strings (`view string`) share the same underlying memory.  
Once all references go out of scope, memory is reclaimed automatically.  
No hidden conversions or implicit allocations occur.

---

## 120.14 String Literals and Raw Strings

Ori supports **two literal syntaxes** for strings:
1. **Backtick (`...`)** — raw, literal form  
2. **Triple quotes (`"""..."""`)** — escaped multiline form  

Each serves a distinct purpose and has clear, predictable behavior.

### 120.14.1 Backtick Strings (Raw Literals)

```ori
var path string = `C:\Users\Ori\docs`
var query string = `SELECT * FROM users WHERE id = 42`
var text string = `Line 1
Line 2
Line 3`
```

#### Characteristics

| Feature | Behavior |
|----------|-----------|
| **Escapes** | Not processed (`\n`, `\t` remain literal) |
| **Multiline** | Supported |
| **Backslashes** | Preserved as-is |
| **UTF-8 validation** | Always enforced |
| **Can include quotes (`"`)** | Yes |
| **Can include backtick (`)** | No |
| **Interpolation** | Not allowed |
| **Use case** | Raw text, file paths, SQL, code snippets, JSON blocks |

---

### 120.14.2 Triple-Quoted Strings (Escaped Multiline Literals)

```ori
var message string = """Line 1
Line 2\tTabbed"""
```

#### Characteristics

| Feature | Behavior |
|----------|-----------|
| **Escapes** | Processed (`\n`, `\t`, `\uXXXX`, etc.) |
| **Multiline** | Supported |
| **Indentation** | Preserved as written |
| **UTF-8 validation** | Always enforced |
| **Can include backticks** | Yes |
| **Can include quotes** | Yes, no escaping required |
| **Interpolation** | Not supported (may be added later) |
| **Use case** | Text blocks, formatted messages |

---

### 120.14.3 Comparative Summary

| Feature | Backtick (`...`) | Triple-quoted (`"""..."""`) |
|----------|------------------|------------------------------|
| **Escapes interpreted** | ❌ No | ✅ Yes |
| **Multiline** | ✅ Yes | ✅ Yes |
| **Indentation preserved** | ✅ Yes | ✅ Yes |
| **Can contain `"`** | ✅ Yes | ✅ Yes |
| **Can contain backtick `** | ❌ No | ✅ Yes |
| **UTF-8 validation** | ✅ Yes | ✅ Yes |
| **Interpolation** | ❌ Not yet | ❌ Not yet |
| **Primary use** | Raw text, regex, SQL, JSON | Human-readable multiline text |
| **Closest analogs** | Go’s `` `...` ``, Rust’s `r"..."` | Python’s `"""..."""`, Rust’s normal `"...\n..."` |

---

### 120.14.4 Design Philosophy

Ori distinguishes between **literal intent** and **formatting convenience**:

- Use **backticks** when the text must be taken **exactly as written** — no escapes, no processing.  
- Use **triple quotes** when readability or formatting matters and **escapes** are useful.  
- Both enforce **UTF-8 correctness** at compile time.

This design unifies the best of:
- Go’s *raw literal simplicity*, and
- Python/Rust’s *expressive multiline escaping*.

---

## 120.15 Future Extensions

- Compile‑time evaluated string interpolation.  
- Native support for multi‑encoding literals (`b"..."`, `r"..."` for raw strings).  
- Efficient substring indexing by code point (`rune`) rather than byte.  
- Optional interning for repeated constants.

---

## References
- [100_Slices.md](semantics/100_Slices.md)
- [050_Types.md](syntax/050_Types.md)
