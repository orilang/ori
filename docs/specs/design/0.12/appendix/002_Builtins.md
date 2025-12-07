# 002. Built-in Functions and Constants

Ori includes a **small, safe set of built-in functions and constants** that provide core language functionality.  
All other behavior belongs to imported modules.

---

## 1. Core Functions

| Function | Description | Example |
|-----------|--------------|----------|
| `len(x)` | Returns the length of arrays, slices, maps, strings, or channels. | `len(users)` |
| `cap(x)` | Returns the capacity of arrays, slices, or channels. | `cap(buffer)` |
| `append(slice, value)` | Returns a new slice with `value` appended. | `users = append(users, "Alice")` |
| `copy(src, dst)` | Copies elements from `src` to `dst`, returns count. | `n = copy(a, b)` |
| `delete(map, key)` | Removes a key from a map. | `delete(users, "id")` |
| `make(type, size)` | Allocates and initializes slices, maps, or channels. | `buf = make([]byte, 128)` |
| `new(Type)` | Allocates memory for a value of `Type`. | `ptr = new(User)` |

---

## 2. Error and Panic Utilities

| Function | Description | Example |
|-----------|--------------|----------|
| `error(msg)` | Creates a generic error value. | `return error("invalid state")` |
| `panic(msg)` | Immediately stops execution with a message. | `panic("unreachable")` |
| `assert(cond)` | Panics if condition is false. | `assert(x > 0)` |
| `todo()` | Marks unfinished code; panics at runtime. | `todo()` |

---

## 3. Memory and Lifetime

| Function | Description | Example |
|-----------|--------------|----------|
| `alloc(Type, size)` | Allocates a memory region for a type. | `p = alloc(int, 10)` |
| `free(ptr)` | Frees explicitly allocated memory. | `free(p)` |
| `defer(expr)` | Delays execution of `expr` until the end of the current scope. | `defer file.close()` |

---

## 4. Numeric Safety Helpers

| Function | Description | Example |
|-----------|--------------|----------|
| `overflow_add(a, b)` | Returns result and overflow flag. | `r, ok := overflow_add(a, b)` |
| `overflow_sub(a, b)` | Returns result and overflow flag. | `r, ok := overflow_sub(a, b)` |
| `overflow_mul(a, b)` | Returns result and overflow flag. | `r, ok := overflow_mul(a, b)` |

---

## 5. Built-in Constants

| Constant | Description |
|-----------|-------------|
| `nil` | Represents an uninitialized reference, map, slice, or error. |
| `true`, `false` | Boolean constants. |

---

> Ori’s built-ins are **minimal**, **safe**, and **explicit** —  
> each one can be understood in isolation, without hidden behavior or runtime magic.
