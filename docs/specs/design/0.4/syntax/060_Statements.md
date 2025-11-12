# 60. Statements

This section describes the statement constructs available in Ori — the building blocks of control flow and program logic.

---

## 60.1 Overview

A **statement** performs an action — executing code, declaring variables, controlling flow, or evaluating expressions for side effects.

Examples:

```ori
let x = 10
x = x + 1
if x > 10 {
    fmt.Println("x is large")
}
```

---

### 60.2 Grammar

```
Block        = "{" { Statement } "}" .
Statement    = Decl | SimpleStmt | IfStmt | ForStmt | ReturnStmt | Block .

SimpleStmt   = VarDecl | ConstDecl | AssignStmt | ExprStmt .
AssignStmt   = Expression "=" Expression
             | ExpressionList "=" ExpressionList .

IfStmt       = "if" Expression Block [ "else" Block ] .

ForStmt      = "for" Identifier [ "," Identifier ] ":=" "range" Expression Block
             | "for" Expression Block
             | "for" [ SimpleStmt ";" ] Expression [ ";" SimpleStmt ] Block .
```

## 60.2 Categories of Statements

| Category | Description |
|-----------|--------------|
| Declaration statements | Introduce new variables, constants, or types |
| Expression statements | Evaluate an expression for side effects |
| Assignment statements | Modify existing variables |
| Control statements | Manage flow (if, for, switch, etc.) |
| Block statements | Group multiple statements together |

---

## 60.3 Assignment Statement

Assignments modify existing values:

```ori
x = x + 1
name = "Ori"
```

Left-hand side must be an assignable variable.\
Both sides must have compatible types.\
Multiple assignments are supported:

```ori
x, y = y, x
```

---

## 60.4 If Statement

### Grammar

```
IfStmt = "if" [ SimpleStmt ";" ] Expression Block [ "else" (IfStmt | Block) ] .
SimpleStmt = VarDecl | Assignment | Expression .
```

### Examples

Conditional branching is handled using `if` / `else`:

```ori
if x > 10 {
    fmt.Println("big")
} else {
    fmt.Println("small")
}
```

Parentheses are not required. Blocks are mandatory.

Nested or chained conditions use `else if`:

```ori
if score > 90 {
    grade = "A"
} else if score > 75 {
    grade = "B"
} else {
    grade = "C"
}
```

More examples:
```
if a > b {
  return a
}

if a > b && c > d {
  return a * c
}

if a > b || c > d {
  return true
}

if (a + b) > (c + d) {
  return true
}

if a > b {
  return a
} else if c > d {
  return c
}

if a > b {
  return a
} else if c > d {
    return c
  else {
    return 0
  }
}

if err := f(); err != nil {
  return err
}

if _, err := f(); err != nil {
  return err
}

if k, ok := f(); ok {
  return k
}
```

---

## 60.5 For Statement

Ori uses a single `for` keyword to express looping constructs.

### Grammar

```
ForStmt = "for" Identifier [ "," Identifier ] ":=" "range" Expression Block
        | "for" Expression Block
        | "for" [ SimpleStmt ";" ] Expression [ ";" SimpleStmt ] Block .
```

### Range Form

Iterate over arrays, slices, or maps:

```ori
for i, v := range items {
    fmt.Println(i, v)
}

for i := range f() {
  fmt.Println(i)
}

for _, v := range x() {
  fmt.Println(v)
}
```

### Conditional Form

```ori
for i < 10 {
    i = i + 1
}
```

### Classic Form

```ori
for i := 0; i < 5; i++ {
    fmt.Println(i)
}

for i := 5; i > 0; i-- {
    fmt.Println(i)
}

for i := 0; i < max(); i++ {
  fmt.Println(i)
}
```

See: [Grammar reference](appendix/A_GrammarReference.md)

---

## 60.6 Switch Statement

### Grammar

```
SwitchStmt = "switch" [ SimpleStmt ";" ] [ Expression ] "{" { CaseClause } "}" .
CaseClause = ( "case" ExpresionList | "default" ) ":" { Statement } .
ExpressionList = Expression { "," Expression } .
```

### Examples

```ori
switch a {
case 1:
  fmt.Println("a")
case 2:
  fmt.Println("b")
default:
  fmt.Println("c")
}

switch {
case a == 0:
  fmt.Println("a")
case b == 1:
  fmt.Println("b")
default:
  fmt.Println("c")
}

switch x {
case a, b:
  fmt.Println("x")
default:
  fmt.Println("c")
}

switch x := f() {
case a, b:
  fmt.Println("x")
default:
  fmt.Println("c")
}
```

---

## 60.7 Return Statement

### Grammar

```
ReturnStmt = "return" [ ExpressionList ] .
```

### Examples

Terminates a function and optionally returns values.

```ori
return
return x
return x, y
```

The number and types of returned values must match the function’s return signature.

---

## 60.8 Break and Continue

`break` terminates the nearest loop.\
`continue` skips to the next iteration.

```ori
for i := 0; i < 10; i++ {
    if i == 5 {
        continue
    }
    if i == 8 {
        break
    }
}
```

---

## 60.9 Block Statement

### Grammar

```
Block = "{" { Statement } "}" .
```

### Examples

A block is a sequence of statements enclosed in `{}`.

```ori
{
    var a int = 1
    var b int = 2
    fmt.Println(a + b)
    x, d int := 3, 4
    fmt.Println(c + d)
}
```

Blocks define their own lexical scope.

---

## 60.10 Defer and Panic (Planned)

Deferred calls and panic recovery are **not included in v0.4**, but may be explored later as structured constructs.

---

## References
- [Expressions](syntax/070_Expressions.md)
- [Blocks](syntax/080_Blocks.md)
