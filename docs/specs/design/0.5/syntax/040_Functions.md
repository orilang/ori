# 40. Functions

This section describes the syntax, semantics, and conventions of function declarations and calls in Ori.

---

## 40.1 Overview

Functions are first-class citizens in Ori.  
They define reusable code blocks with clearly typed parameters and return values.

```ori
func add(a int, b int) int {
    return a + b
}
```

Functions are declared using the `func` keyword.  
Parameters and return types are explicit.

---

## 40.2 Grammar

```
FuncDecl       = "func" Identifier "(" [ ParameterList ] ")" [ ReturnTypes ] Block .
ParameterList  = ParameterGroup { "," ParameterGroup } .
ParameterGroup = Identifier { "," Identifier } [ Type ] .
Statement      = Expression | ReturnStmt .
ReturnStmt     = "return" [ Expression ] .
```

Examples:

```ori
func greet(name string) {
    fmt.Println("Hello,", name)
}

func sum(a int, b int) int {
    return a + b
}

// shorthand notation of func sum(a int, b int) int
func sum(a, b int) int {
    return a + b
}
```

---

## 40.3 Return Semantics

Functions may return zero, one, or multiple values.  
Return types are always explicit.

```ori
func divide(a int, b int) (int, bool) {
    if b == 0 {
        return 0, false
    }
    return a / b, true
}
```

---

## 40.4 Named Returns (Planned)

Named return variables are under consideration for future versions but are **not implemented** in v0.5.

---

## 40.5 Receivers and Methods

Functions can be declared with an explicit **receiver** to define methods on types:

```ori
type Point struct {
    x int
    y int
}

func (p Point) Length() float64 {
    return math.Sqrt(float64(p.x*p.x + p.y*p.y))
}
```

Receivers are always explicit:
- `value` receivers copy the struct.
- `pointer` receivers (planned) allow mutation.

---

## 40.6 Function Values

Functions are first-class values and can be assigned to variables or passed as arguments.

```ori
func apply(func func(int) int, x int) int {
    return func(x)
}

func double(x int) int {
    return x * 2
}

result := apply(double, 4)
```

---

## 40.7 Anonymous Functions and Closures

Anonymous (lambda) functions are supported:

```ori
inc := func(x int) int {
    return x + 1
}

var dec = func(x int) int {
    return x - 1
}

fmt.Println(inc(5)) // 6
fmt.Println(dec(2)) // 4
```

Closures capture surrounding variables by value.

---

## 40.8 Variadic Functions (Planned)

Variadic parameter syntax is under consideration:
```ori
func sum(nums ...int) int
```

---

## 40.9 Error Handling in Functions

Functions can return an error type or `Result<T, E>` equivalent for explicit error propagation.

```ori
func readConfig() error {
    ...
}

func readFile(path string) (string, error) {
    if path == "" {
        return "", error("empty path")
    }
    return "data", nil
}
```

See: [Errors](semantics/140_Errors.md)

---

## 40.10 Examples

```ori
package main

func factorial(n int) int {
    if n <= 1 {
        return 1
    }
    return n * factorial(n - 1)
}
```

---

## References

- [Types](syntax/050_Types.md)
- [Blocks](syntax/080_Blocks.md)
