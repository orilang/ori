# 007. Type System Philosophy

Ori’s type system emphasizes **clarity, explicitness, and safety through precision**.  
There are no implicit conversions, no automatic zero values, and no hidden type inference.  
Developers must always declare intent explicitly.

> “A type in Ori is a contract — not a guess.”

---

## 1. Core Design Principles

| Principle | Description |
|------------|--------------|
| **Explicit typing** | Every variable must declare its type explicitly. |
| **No inference** | `var a int = 123`, not `var a = 123`. |
| **No implicit conversions** | Conversions between numeric, string, or pointer types require explicit syntax. |
| **Strong type identity** | Types are not interchangeable unless explicitly converted. |
| **Compile-time checking** | Type correctness is verified before code generation. |
| **No automatic zero values** | Variables must be initialized by the developer. |

---

## 2. Type Categories

- **Primitives** — `int`, `uint`, `float`, `bool`, `rune`, `string`
- **Composite types** — `array`, `slice`, `map`, `hashmap`, `struct`
- **Reference-like types** — `view`, `shared`
- **User-defined types** — explicit `type` declarations

---

## 3. Type Safety and Explicit Conversion

Ori rejects implicit conversions that may lose information or change meaning.

```ori
var a int = 10
var b float32 = float32(a) // explicit conversion required
```

Conversions must always be deliberate and visible in code.

> “Ori will never convert for you — you must decide.”

---

## 4. Type Contracts and Identity

Two types are considered distinct unless explicitly declared compatible.

```ori
type Celsius int
type Fahrenheit int

func toF(c Celsius) Fahrenheit {
    return Fahrenheit((c * 9 / 5) + 32)
}
```

Even though both are based on `int`, they are different in type identity.

---

## 5. Errors as Types

Errors are first-class citizens in Ori.  
They are **typed values**, not exceptions or hidden control flow.  
They must be **declared**, **handled**, or **propagated** using `try`.

```ori
func openFile(path string) error {
    // returns explicit error type
}
```

---

## 6. Numeric Safety

- Integer overflow produces a **runtime panic** unless checked explicitly (`overflow_add`, `overflow_sub`, etc.).  
- No silent wraparound unless explicitly defined.  
- Signed and unsigned types are strictly distinct.  

This ensures consistent behavior across architectures and compilers.

---

## 7. Design Rationale

Ori’s type system prioritizes:

- **Predictable memory layout.**  
- **Compiler-verifiable contracts.**  
- **No implicit type inference.**  
- **No hidden conversions or automatic initialization.**  

> “Every value in Ori has a defined type, and every type has a defined behavior.”

---

## 9. Summary

Ori’s type system is **strong, explicit, and predictable** — designed to prevent ambiguity, enforce correctness, and support high-performance compilation.

> “Explicit types make implicit bugs impossible.”
