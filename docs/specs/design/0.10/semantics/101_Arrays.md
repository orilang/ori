# 101. Arrays

Arrays in Ori are fixed-size, value types that store elements of the same type in contiguous memory.  
They form the foundation for slices and provide deterministic memory layout and safety.

---

## 101.1 Overview

An **array** is a collection of elements with a compile-time constant length.  
Unlike slices, arrays own their data and have a fixed size that cannot change after declaration.

Example:

```ori
var numbers [5]int = [5]int{1, 2, 3, 4, 5}
```

---

## 101.2 Declaration and Initialization

### Static Declaration

```ori
var arr [3]int
```

Creates an array of three integers, all initialized to the zero value of `int`.

### Initialization with Values

```ori
var primes [5]int = [5]int{2, 3, 5, 7, 11}
```

### Inferred Length

The compiler can infer the array length from the initializer:

```ori
var data [...]int = [..]int{1, 2, 3, 4}
```

This declares an array of length 4.

---

## 101.3 Array Type and Properties

An array type is defined by its element type and fixed length:

```ori
[T; N]
```
or equivalently in Ori syntax:

```ori
[N]T
```

Example:

```ori
var matrix [3][3]int
```

This creates a 3×3 array of integers.

### Properties

| Property | Description |
|-----------|--------------|
| **Fixed size** | The length `N` is part of the type. |
| **Value type** | Assignment copies all elements. |
| **Contiguous memory** | Elements are stored sequentially. |
| **Zero-initialized** | All elements start with their zero value. |

---

## 101.4 Indexing and Assignment

Array elements are accessed using zero-based indexing.

```ori
arr[0] = 10
var x int = arr[1]
```

Accessing an index outside `[0, N)` causes a runtime error.

---

## 101.5 Array Copy Semantics

Assigning one array to another copies **all elements**.

```ori
var a [3]int = [3]int{1, 2, 3}
var b [3]int = a
b[0] = 99

fmt.Println(a) // [1 2 3]
fmt.Println(b) // [99 2 3]
```

Arrays have **value semantics** — assignment creates an independent copy.

---

## 101.6 Passing Arrays to Functions

Arrays are passed **by value** by default.  
Modifying an array inside a function does not affect the caller’s copy.

```ori
func reset(a [3]int) {
    a[0] = 0
}

var arr [3]int = [3]int{1, 2, 3}
reset(arr)
fmt.Println(arr) // [1 2 3]
```

To pass by reference, use a pointer or a `view`:

```ori
func reset(v view [3]int) {
    v[0] = 0
}

reset(arr) // modifies original
```

---

## 101.7 Iteration

Arrays can be iterated using `for range`:

```ori
var arr [3]int = [3]int{10, 20, 30}

for i, v := range arr {
    fmt.Println(i, v)
}
```

Iteration always visits elements in order.

---

## 101.8 Arrays and Slices

A slice can be created from an array using slicing syntax:

```ori
var arr [5]int = [5]int{1, 2, 3, 4, 5}
var sub view []int = arr[1:4]
```

This creates a **shared view** referencing the same memory as the array.  
Changes in the slice affect the array and vice versa.

---

## 101.9 Multidimensional Arrays

Arrays can contain other arrays as elements.

```ori
var grid [2][3]int = [2][3]int{
    [3]int{1, 2, 3},
    [3]int{4, 5, 6},
}
```

Nested arrays have predictable, contiguous layout in row-major order.

---

## 101.10 Comparison and Equality

Arrays of the same type and length can be compared directly.

```ori
var a [3]int = [3]int{1, 2, 3}
var b [3]int = [3]int{1, 2, 3}
fmt.Println(a == b) // true
```

If element types are comparable, the comparison is lexicographical.

---

## 101.11 Const Arrays

Arrays can be declared as constants using `const`:

```ori
const lookup [3]int = [3]int{10, 20, 30}
```

Const arrays are immutable and stored in read-only memory.

---

## 101.12 Memory and Layout

- Arrays are **contiguous in memory**.
- Alignment follows the element type.
- Size is `sizeof(T) * N`.
- Arrays cannot be resized or reallocated.

---

## References
- [100_Slices.md](semantics/100_Slices.md)
- [050_Types.md](syntax/050_Types.md)
