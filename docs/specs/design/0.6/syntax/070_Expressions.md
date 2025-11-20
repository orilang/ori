# 70. Expressions

Expressions compute values from operands and operators.  
They are the fundamental building blocks of evaluation in Ori.

---

## 70.1 Overview

Expressions can produce values, perform computations, or invoke functions.  
Examples:

```ori
x + y
f(42)
user.name
```

---

## 70.2 Categories of Expressions

| Category | Description |
|-----------|--------------|
| Primary expressions | Identifiers, literals, grouped expressions |
| Composite expressions | Struct, array, or map literals |
| Unary expressions | Negation, address, dereference, etc. |
| Binary expressions | Arithmetic, comparison, logical operations |
| Function calls | Invocation of declared or anonymous functions |
| Selector expressions | Access fields or methods |

---

## 70.3 Primary Expressions

### Identifiers and Literals

```ori
x
42
"hello"
true
```

### Grouped Expressions

Parentheses may be used to control precedence:

```ori
(x + y) * z
```

---

## 70.4 Composite Literals

Construct composite values inline.

```ori
var p = Point{x: 1, y: 2}
var arr = [3]int{1, 2, 3}
var m = map[string]int{"a": 1, "b": 2}
```

---

## 70.5 Unary Operators

| Operator | Meaning |
|-----------|----------|
| `+x` | Unary plus (no effect) |
| `-x` | Negation |
| `!x` | Logical NOT |
| `&x` | Address of (planned) |
| `*x` | Dereference (planned) |

Examples:

```ori
var n int = -5
var ok = !false
```

---

## 70.6 Binary Operators

| Category | Operators | Example |
|-----------|------------|----------|
| Arithmetic | `+`, `-`, `*`, `/`, `%` | `a + b` |
| Comparison | `==`, `!=`, `<`, `<=`, `>`, `>=` | `x == y` |
| Logical | `&&`, `\|\|` | `x && y` |
| Bitwise | `&`, `\|`, `^`, `<<`, `>>` | `x & y` |

Operator precedence and associativity follow conventional rules.

---

## 70.7 Function Calls

Functions are invoked with parentheses enclosing arguments.

```ori
result = add(1, 2)
```

Arguments are evaluated left to right.

See: [Functions](syntax/040_Functions.md)

---

## 70.8 Field and Method Selectors

Use the dot operator to access struct fields or methods.

```ori
user.name
point.Length()
```

The left operand must be a struct or pointer to struct.

---

## 70.9 Index Expressions

Index into arrays, slices, or maps:

```ori
nums[0]
users["alice"]
```

Out-of-range accesses are runtime errors.

---

## 70.10 Type Conversion Expressions

Explicit type conversion is performed using the target type as a function:

```ori
var f = float64(3)
var i = int(3.14)
```

Implicit conversions are **not allowed**.

---

## 70.11 Composite Construction Expressions

Composite literals and function calls can be combined:

```ori
make([]int, 10)   // create slice
new(Point)        // allocate struct (planned)
```

`make` is a builtin function for allocating dynamic types like slices and maps.

---

## 70.12 Example

```ori
func main() {
    var a int = 3
    var b int = 4
    var c = math.Sqrt(float64(a*a + b*b)) // inferred float64
    fmt.Println("c =", c)
}
```

---

## References
- [Statements](syntax/060_Statements.md)
- [Functions](syntax/040_Functions.md)
- [Types](syntax/050_Types.md)
