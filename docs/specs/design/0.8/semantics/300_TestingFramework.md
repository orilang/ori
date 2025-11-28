# 300. Testing Framework

## 300.1 Overview

Ori’s testing framework follows the principles already established in `280_CompilerDirectivesAndKeywords.md`:
- **No attributes** (`@test`, `#[test]`, etc.)
- **No special syntax** (`test "..." {}`)
- **No runtime skip logic**
- **Test discovery is purely based on file naming and function naming**
- **Tests must be deterministic and explicit**

Ori’s test philosophy:
- Tests are **ordinary functions**
- Tests are discovered by naming conventions:
  - Files ending with `*_test.ori`
  - Functions starting with `Test`
- Tests run in a **single process**, sequentially
- An optional **TestContext** (`t *TestContext`) provides structured testing APIs
- **Panic = test failure**
- **Normal return = test success**

This approach keeps testing powerful, explicit, and predictable without introducing language-level magic.

---

## 300.2 Test File Discovery

A file is considered a test file if its name ends with:

```
*_test.ori
```

Rules:

- Such files are compiled only during `ori test`
- They belong to the same module as other Ori source files in the directory
- Non-test builds (`ori build`) ignore them
- There is no way to conditionally mark a file as test or non-test except by file name

Examples:
```
math/add.ori
math/add_test.ori
```

---

## 300.3 Test Function Discovery

Inside a test file, any function with the form:

```
func TestXxx(t *TestContext)
```

is considered a test entry point.

Rules:
- Must begin with `Test` (capital T)
- Must accept exactly **one parameter**: `t *TestContext`
- Must return no value
- Must not be generic
- Must not be `extern`
- Must not be `comptime func`

Example:

```
func TestAdd(t *TestContext) {
    if add(2, 3) != 5 {
        t.Fail("expected 5")
    }
}
```

---

## 300.4 TestContext API

The compiler injects a `TestContext` pointer into each test.  
It provides structured test features without language magic.

### 300.4.1 t.Fail(message string)

Marks the test as failed, but the test continues executing.

```
t.Fail("incorrect value")
```

---

### 300.4.2 t.FailNow(message string)
Immediately aborts the test by raising a controlled panic.

```
t.FailNow("fatal failure")
```

Equivalent to:

```
t.Fatal("fatal failure")
```

---

### 300.4.3 t.Fatal(message string)

Alias for `t.FailNow`. Conventional shorthand.

---

### 300.4.4 t.Run(name string, func(t *TestContext))

Runs a subtest with its own TestContext and deterministic scope.

```
t.Run("simple add", func(t *TestContext) {
    if add(1, 2) != 3 {
        t.Fail("bad add")
    }
})
```

Subtests:
- Run sequentially
- Have their own destruction scope
- Can contain nested subtests

### 300.4.5 t.Cleanup(func())
Registers a cleanup function executed after the test completes.

Cleanups run **after local variables are destroyed**, in **LIFO** order.

```
t.Cleanup(func() {
    File.remove("temp.bin")
})
```

---

### 300.4.6 t.OS (string)

Reports the current operating system as a lowercase string:

```
"linux"
"windows"
"darwin"
```

Used for OS-specific tests, with explicit early return.

Example:

```
if t.OS != "linux" {
    return
}
```

There is no skip state, no skip counter, and no hidden behavior.

---

## 300.5 Test Execution Model

Tests are run:

1. In deterministic order:
   - Test files sorted lexicographically
   - Test functions discovered in lexical order within the file
   - Subtests run in the order they are declared
2. Sequentially (no parallel test execution)
3. In a single process
4. With deterministic destruction:
   - Local variables destroyed at end of function
   - Then cleanup functions run
   - Then TestContext destroyed

Test outcomes:
- **Pass**: normal return
- **Fail**: panic triggered by t.FailNow or panic triggered in code
- **Continue**: t.Fail does not interrupt

---

## 300.6 Panic Behavior

Any panic inside a test or subtest marks that test as **failed**.

Subtest example:

```
t.Run("panic example", func(t *TestContext) {
    panic("boom")
})
```

This does not terminate the parent suite; the failure is recorded and execution continues.

---

## 300.7 OS-Specific Tests (Explicit Early Return)

Ori does **not** support `t.Skip` or runtime skip semantics.

Instead, OS-specific tests use **explicit early returns**:

```
func TestOnlyLinux(t *TestContext) {
    if t.OS != "linux" {
        return
    }

    // linux-specific logic
}
```

No hidden logic, no skip counters, no conditional metadata.

---

## 300.8 Test Runner Behavior (`ori test`)

### 300.8.1 Basic invocation

```
ori test
```

Runs tests in the current module.

---

### 300.8.2 Recursive invocation (`./...`)

```
ori test ./...
```

Runs tests in all modules under the current directory.

This mirrors Go’s extremely ergonomic `./...` wildcard.

---

### 300.8.3 Directory/package selection

```
ori test ./math
ori test ./utils
```
---

### 300.8.4 Filtering (`-run`)

```
ori test -run TestAdd
ori test -run add
```

Filters test names by substring.

---

### 300.8.5 Output format

```
running 3 tests
TestAdd ... ok
TestMin ... ok
TestLinuxOnly ... ok
```

Failures include the panic or Fail message.

### 300.8.6 Exit codes

- `0` = all tests passed
- `1` = at least one failure
- `2` = test build failure

---

## 300.9 Examples

### Basic test

```
func TestAdd(t *TestContext) {
    if add(2, 3) != 5 {
        t.Fail("expected 5")
    }
}
```

### Using Cleanup

```
func TestFile(t *TestContext) {
    t.Cleanup(func() { File.remove("temp.txt") })

    var f = File.create("temp.txt")
    f.write("hello")
}
```

### Subtests

```
func TestMath(t *TestContext) {
    t.Run("add", func(t *TestContext) {
        if add(1, 2) != 3 {
            t.Fail("bad add")
        }
    })

    t.Run("mul", func(t *TestContext) {
        if mul(3, 4) != 12 {
            t.Fail("bad mul")
        }
    })
}
```

### OS-specific

```
func TestOnlyWindows(t *TestContext) {
    if t.OS != "windows" {
        return
    }

    // windows-only logic
}
```

---

## Summary

Ori’s testing system:
- Uses Go-style discovery
- Uses an explicit TestContext instead of attributes
- Avoids global state and runtime skipping
- Has deterministic destruction and no magic
- Is powerful via t.Run, t.Cleanup, and t.OS
- Remains fully explicit, predictable, and easy to reason about
