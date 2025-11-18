# 15. Literals

Literals represent fixed constant values embedded directly in Ori source code.

---

## 15.1 Overview

A literal is a lexical token that denotes a value such as a number, string, boolean, or nil.

Examples:

```ori
42
3.14
"hello"
true
nil
```

---

## 15.2 Integer Literals

Integer literals represent whole numbers.

### Decimal
```ori
var a int = 123
```

### Hexadecimal
```ori
var b = 0xFF
```

### Binary (planned)
```ori
var c = 0b1010
```

### Rules
- Underscores (`_`) may be used as visual separators (e.g., `1_000_000`).
- Negative values use the unary `-` operator.

---

## 15.3 Floating-Point Literals

Floating-point literals represent real numbers.

```ori
var pi float = 3.1415
var exp int = 1e-9
```

Both decimal and exponent notation are supported.

---

## 15.4 String Literals

String literals represent immutable sequences of Unicode characters.

```ori
var msg = "Hello, Ori!"
```

Enclosed in double quotes (`"`).  
Supports escape sequences (`\n`, `\t`, `\"`, `\\`).\
Raw strings using backticks (planned).

---

## 15.5 Rune Literals (Planned)

Rune literals represent single Unicode code points.

```ori
var ch = 'A'
```

Planned for future versions.

---

## 15.6 Boolean Literals

Booleans have two constant values: `true` and `false`.

```ori
var ok = true
var done = false
```

---

## 15.7 Nil Literal

`nil` represents the absence of a value.

It may be used with pointers, slices, maps, and optional types (when introduced).

```ori
var data = nil
```

---

## 15.8 Summary

| Type | Example | Notes |
|-------|----------|--------|
| Integer | `123`, `0xFF` | Base 10 or 16 |
| Float | `3.14`, `1e-9` | Decimal or exponent |
| String | `"text"` | Double-quoted, UTF-8 |
| Boolean | `true`, `false` | Logical constants |
| Nil | `nil` | Absence of value |
