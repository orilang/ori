# 300. Testing Framework — Phase 2 Extensions

This document extends `300_TestingFramework_Phase1.md` with additional testing capabilities. These additions preserve Ori’s core principles:
- No attributes or annotations (`@test`, `#[test]`, etc.)
- No implicit skip or runtime metadata
- Full determinism in ordering and destruction
- Explicit, visible APIs for all behavior
- Subtests remain sequential unless explicitly parallelized
- Tests remain normal functions discovered by naming conventions

Phase 2 introduces improvements centered on ergonomics, correctness, concurrency testing, and strict, predictable timeouts.

The default per-test timeout is **10 minutes**.

Ori does **not** implement a global test suite timeout.

---

## 300.20 Overview of Phase 2 Additions

Phase 2 introduces:
- Deterministic parallel subtests (`t.Parallel`)
- Strict per-test timeouts (`t.Deadline`)
- Structured logging (`t.Log`, `t.Logf`)
- Environment helpers (`t.Env`)
- Temporary directories (`t.TempDir`)
- Standard assertion helpers (`t.Equal`, `t.NotEqual`, `t.Nil`, etc.)
- Clearer failure reporting

These additions extend — but do not modify — the semantics of Phase 1.

---

## 300.21 Parallel Subtests

Parallel execution in Ori is **explicit**, **deterministic**, and **restricted for simplicity**.

### 300.21.1 API

```
t.Parallel(func(t *TestContext))
```

### 300.21.2 Semantics

- A parallel block behaves as **one atomic concurrent test unit**.
- The block inherits the parent test’s timeout.
- Parallel tasks run concurrently but:
  - **Print output in declaration order**
  - **Never interleave log lines**
  - **All tasks must complete before the parent test returns**

### 300.21.3 Restrictions inside `t.Parallel`

Inside a parallel block:
- `t.Run` is **forbidden**
- `t.Parallel` is **forbidden**
- `t.Deadline` is **forbidden**

A parallel block must not create subtests and must not override or disable its timeout.

---

## 300.22 Test Deadlines (Timeouts)

Ori enforces a **single timeout per test**, determined at the top-level test function.

### 300.22.1 Default timeout

Every test has a default timeout of:
```
10 minutes
```

This timeout applies uniformly to the test and all its subtests, including parallel tasks.

### 300.22.2 API

```
t.Deadline(d Duration)
```

### 300.22.3 Timeout rules

- `t.Deadline` is **only** be called in a top-level test (`func TestXxx`)
- Subtests (`t.Run`) **cannot** override the timeout
- Parallel blocks (`t.Parallel`) **cannot** override the timeout
- Timeouts **cannot** be disabled

### 300.22.4 Effective timeout resolution

The effective timeout for any test or subtest is determined by the following table:

Top-level Deadline? | Subtest Deadline? | Allowed? | Result
--------------------|-------------------|----------|--------
No                  | No                | ✔        | Uses default (10 minutes)
Yes                 | No                | ✔        | Uses overridden timeout
No                  | Yes               | ❌       | Compile-time error
Yes                 | Yes               | ❌       | Compile-time error
Inside Parallel     | Any               | ❌       | Compile-time error

### 300.22.5 Timeout behavior

If a test exceeds its timeout, Ori injects:
```
panic("test deadline exceeded")
```

- Only the timed-out test fails
- The overall suite continues
- Cleanup functions of the timed-out test **do not run**

### 300.22.6 No global timeout

Ori does **not** implement a suite-wide timeout.

---

## 300.23 Logging Support

### 300.23.1 API

```
t.Log(msg string)
t.Logf(format string, args...)
```

### 300.23.2 Output rules

- Logs are buffered per test/subtest
- Logs print:
  - if the test fails, or
  - if `--verbose` is passed to the runner
- Log lines **never interleave** across tests
- Tests and subtests print results in **declaration order**, even when using `t.Parallel`

---

## 300.24 Environment Helpers

### 300.24.1 API

```
t.Env(name string) string
```

### 300.24.2 Behavior

- Returns the value of the environment variable or an empty string
- Early return based on environment logic is considered a **PASS**
- Ori has **no skipped-test state**

Example:
```
if t.Env("CI") == "" {
    return
}
```

---

## 300.25 Temporary Directories

### 300.25.1 API

```
dir := t.TempDir()
```

### 300.25.2 Behavior

- Creates a unique temporary directory for the current test or subtest
- Automatically deleted during cleanup
- Safe to use in both sequential and parallel contexts

---

## 300.26 Assertion Helpers

Ori provides a standard set of assertion helpers to avoid reliance on external libraries.

### 300.26.1 API

```
t.Equal(got, want)
t.NotEqual(a, b)
t.True(expr, msg)
t.False(expr, msg)
t.Nil(v)
t.NotNil(v)
t.Error(err)
t.NoError(err)
t.ErrorIs(err)
```

### 300.26.2 Semantics

- Failed assertions call `t.FailNow` with file/line information
- Assertions abort the current test or subtest

---

## 300.27 Enhanced Failure Output

When a test fails:
- The runner prints:
  - test name
  - file and line of failure
  - collected logs
- Output is deterministic and sorted by declaration order

---

## 300.28 Interaction with Phase 1 Features

Everything from Phase 1 remains intact:
- Tests discovered via `*_test.ori` and functions named `TestXxx`
- Subtests created via `t.Run` execute sequentially
- Parallel blocks are atomic and restricted
- Deterministic ordering across the entire test suite

Phase 2 **extends** the framework; it does not alter Phase 1 semantics.

---

## 300.29 Examples

### Parallel subtests (correct usage)

```
func TestConcurrentAccess(t *TestContext) {
    t.Deadline(10 * time.Second)

    t.Parallel(func(t *TestContext) {
        // task 1 logic
    })

    t.Parallel(func(t *TestContext) {
        // task 2 logic
    })

    t.Run("subtest", func(t *TestContext) {
        // inherits 10s timeout
        doWork()
    })
}
```

### Deadline override (only allowed at top level)

```
func TestLoad(t *TestContext) {
    t.Deadline(5 * time.Second)

    t.Run("slow-path", func(t *TestContext) {
        slowComputation()   // uses 5s timeout
    })
}
```

### Forbidden patterns

```
t.Parallel(func(t *TestContext) {
    t.Deadline(10 * time.Second)          // ❌ forbidden
})

t.Parallel(func(t *TestContext) {
    t.Run("bad", func(t *TestContext) {}) // ❌ forbidden
})

t.Run("bad", func(t *TestContext) {
    t.Deadline(5 * time.Second)           // ❌ forbidden (subtest override)
})

t.Run("bad", func(t *TestContext) {
    t.Parallel(func(t *TestContext) {})   // ❌ forbidden
})

t.Run("bad", func(t *TestContext) {
    t.Run("bad", func(t *TestContext) {}) // ❌ forbidden
})
```

---

## 300.30 Summary of Phase 2

Phase 2 adds:
- deterministic parallel execution
- strict per-test timeout model (default: 10 minutes)
- deterministic logging and output
- environment inspection
- temporary directories
- standard assertion helpers
- improved failure reporting

Ori’s testing system remains explicit, deterministic, and free of magic.
