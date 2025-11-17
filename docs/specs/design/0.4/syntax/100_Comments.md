# 100. Comments

This section describes the syntax and semantics of comments in Ori source code.

---

## 100.1 Overview

Comments are text fragments ignored by the compiler.  
They are used to document code and improve readability.

Ori supports **line comments** and **block comments**.

---

## 100.2 Line Comments

A line comment begins with `//` and continues until the end of the line.

```ori
// This is a single-line comment
var x int = 10  // Inline comment after a statement
```

Line comments can appear anywhere whitespace is allowed.  
They do not nest.

---

## 100.3 Block Comments

Block comments begin with `/*` and end with `*/`.

```ori
/*
This is a multi-line comment.
It can span several lines.
*/
```

### Rules

Block comments **cannot nest**.  
Can start or end anywhere, whitespace is valid.  
Are typically used for large explanations or temporary code disabling.

---

## 100.4 Doc Comments (Planned)

Ori plans to support **documentation comments** that attach to declarations.

Example (planned):

```ori
// Represents a user account in the system.
type User struct {
    id int
    name string
}
```

These may later integrate with a `oridoc` tool for documentation generation.

---

## 100.5 Placement Guidelines

| Location | Example | Notes |
|-----------|----------|-------|
| Top of file | `// Package documentation` | Describes file or module purpose |
| Before declarations | `// Explains the next type or func` | Recommended for public API |
| Inline | `var x int = 10 // counter` | Keep short and aligned |

---

## 100.6 Best Practices

Use **line comments (`//`)** for normal documentation.  
Reserve **block comments (`/* */`)** for large text or disabled code.  
Keep doc comments short and focused.  
Avoid comment drift — keep them up-to-date with code behavior.

---

## References
- [Program Structure](syntax/010_ProgramStructure.md)
- [Declarations](syntax/020_Declarations.md)
