# 80. Blocks

Blocks in Ori define lexical scopes and group statements or declarations together.  
They are the foundation of structured programming, determining variable lifetime and visibility.

---

## 80.1 Overview

A **block** is a sequence of statements enclosed in curly braces `{}`.

```ori
{
    var x int = 10
    fmt.Println(x)
}
```

Blocks are used to:
- Group related statements
- Limit variable scope
- Define function bodies, conditionals, and loops

---

## 80.2 Grammar

```
Block = "{" { Statement } "}" .
```

Every block introduces a **new lexical scope**.

---

## 80.3 Scoping Rules

- Variables declared inside a block are **local** to that block.
- Nested blocks can shadow variables from outer scopes.
- Shadowing the same name within a single block is **not allowed**.

```ori
var x int = 1
{
    var x int = 2  // shadows outer x
    fmt.Println(x) // prints 2
}
fmt.Println(x) // prints 1
```

---

## 80.4 Block Usage

Blocks appear in multiple language constructs:

| Construct | Example |
|------------|----------|
| Function | `func main() { ... }` |
| If / Else | `if cond { ... } else { ... }` |
| For loop | `for i := 0; i < 10; i = i + 1 { ... }` |
| Switch | `switch x { ... }` |
| Standalone | `{ var a int = 1; fmt.Println(a) }` |

---

## 80.5 Nested Blocks

Blocks may be nested arbitrarily to control visibility and lifetime of variables.

```ori
func demo() {
    var a int = 1
    {
        var b int = 2
        fmt.Println(a + b)
    }
    // b is out of scope here
}
```

---

## 80.6 Lifetime and Destruction

When a block ends:
- Local variables go out of scope.
- Memory managed by the runtime (stack or heap) is released predictably.

Ori ensures deterministic destruction for value-based semantics.

---

## 80.7 Empty Blocks

Empty blocks are valid and represent no operation:

```ori
{}
```

---

## References
- [Statements](syntax/060_Statements.md)
- [Functions](syntax/040_Functions.md)
