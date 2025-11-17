# 160. Control Flow

Control flow in Ori governs how statements are executed in sequence or conditionally.  
All control constructs are **explicit**, **deterministic**, and designed to avoid hidden behaviors.

---

## 160.1 Overview

Ori provides structured flow-control statements for:
- Conditional branching (`if`, `else`)
- Loops (`for`)
- Multi-branch dispatch (`switch`)
- Flow modification (`break`, `continue`, `fallthrough`, `return`)

No implicit truthiness, automatic conversions, or silent fallthroughs exist.  
All flow control follows a **block-based** structure.

---

## 160.2 Conditional Statements (`if`, `else`)

The `if` statement evaluates a condition and executes the associated block if it is true.

### Grammar
```
IfStmt = "if" [ SimpleStmt ";" ] Expression Block [ "else" ( IfStmt | Block ) ] .
```

`SimpleStmt` allows short variable declarations scoped to the `if` statement.  
The condition must be a boolean expression.

### Examples
```ori
if x > 0 {
    fmt.Println("Positive")
} else if x == 0 {
    fmt.Println("Zero")
} else {
    fmt.Println("Negative")
}

// With initialization
if v := compute(); v > 10 {
    fmt.Println("High")
}
```

---

## 160.3 Loops (`for`)

Ori uses a single `for` keyword for all loop types.  
No `while` keyword exists; `for` covers all cases.

### Grammar

```
ForStmt = "for" [ Condition | ForClause | RangeClause ] Block .
ForClause = [ InitStmt ] ";" [ Condition ] ";" [ PostStmt ] .
RangeClause = IdentifierList ":=" "range" Expression .
```

### Forms

#### (a) Infinite loop
```ori
for {
    doWork()
}
```

#### (b) Conditional loop
```ori
for i < 10 {
    i += 1
}
```

#### (c) Three-component loop
```ori
for i := 0; i < 10; i += 1 {
    fmt.Println(i)
}
```

#### (d) Range iteration
```ori
for i, v := range items {
    fmt.Println(i, v)
}
```

### Loop Control Statements

| Statement | Description |
|------------|--------------|
| `break` | Exits the innermost loop or switch. |
| `continue` | Skips to the next iteration of the current loop. |

Example:
```ori
for i := 0; i < 10; i += 1 {
    if i == 5 {
        continue
    }
    if i == 8 {
        break
    }
    fmt.Println(i)
}
```

---

## 160.4 Switch Statement

The `switch` statement selects among multiple branches based on value matching.  
It evaluates the expression once, then compares against each `case` in order.

### Grammar

```
SwitchStmt     = "switch" [ SimpleStmt ";" ] [ Expression ] "{" { CaseClause } "}" .
CaseClause     = "case" ExpressionList ":" StatementList | "default" ":" StatementList .
FallthroughStmt = "fallthrough" .
```

### Semantics

The `switch` expression is evaluated once.  
Each `case` is checked sequentially until a match is found.  
The first matching case executes; execution ends unless a `fallthrough` is explicitly declared.  
The optional `default` clause executes if no case matches.

### Examples

#### Basic switch

```ori
switch x {
case 1:
    fmt.Println("One")
case 2:
    fmt.Println("Two")
default:
    fmt.Println("Other")
}
```

#### Switch with initializer

```ori
switch v := getValue(); v {
case 0:
    fmt.Println("Zero")
case 1, 2, 3:
    fmt.Println("Small")
default:
    fmt.Println("Large")
}
```

#### Explicit fallthrough

Ori supports **explicit** fallthrough — it must be written manually.
```ori
switch value {
case 1:
    fmt.Println("one")
    fallthrough
case 2:
    fmt.Println("two or one")
default:
    fmt.Println("other")
}
```

#### Switch Without Expression

```
switch {
case a == 0:
    fmt.Println("a")
case b == 1:
    fmt.Println("b")
default:
    fmt.Println("c")
}
```
This form is useful for multi-branch conditionals where each branch has a distinct test expression.


### Notes

Each **case** is evaluated in order.  
The first true condition executes.  
**default** runs if none of the conditions match.  
Fallthrough can only occur at the **end** of a case block.  
Fallthrough transfers control to the **immediately following** case.

---

## 160.5 Return Statement

The `return` statement exits a function, optionally returning values.

### Grammar

```
ReturnStmt = "return" [ ExpressionList ] .
```

### Rules

If the function declares results, the number and types of expressions must match.  
`return` without expressions is only allowed when all results are named.

### Examples

```ori
func add(a int, b int) int {
    return a + b
}

func compute() (int, bool) {
    result := 42
    return result, true
}
```

---

## 160.6 Summary

| Construct | Purpose | Notes |
|------------|----------|-------|
| `if`, `else` | Conditional execution | Boolean expressions only |
| `for` | Looping construct | Unified loop syntax; supports `range` |
| `break`, `continue` | Loop control | Immediate loop or switch exit |
| `switch` | Multi-branch selection | Explicit `fallthrough`, single evaluation |
| `return` | Function exit | Supports multiple values |

---

Ori’s control flow is designed to remain minimal yet expressive — ensuring **clarity**, **predictability**, and **explicit developer intent**.
