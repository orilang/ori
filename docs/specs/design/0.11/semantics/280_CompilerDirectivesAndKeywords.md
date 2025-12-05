# 280. Compiler Directives And Keywords

## 280.1 Overview

Ori does not include any general attribute or annotation system (such as @inline, @test, @packed, #[repr], etc.).  
This follows Ori’s design principles of explicitness, clarity, and predictable behavior.

Instead, Ori uses:
- keywords for explicit compilation behavior (extern, comptime)
- naming conventions for tests (*_test.ori and TestXxx)
- standardized comments for deprecation (// Deprecated: ...)

There are no hidden compiler behaviors or metadata layers.

---

## 280.2 Keywords Used as Directives

### 280.2.1 extern

Declares a function implemented outside Ori (usually via the C ABI):
```ori
extern func printf(fmt string, ...) int
```

Rules:
- Only valid for function declarations
- Uses the platform’s default C ABI
- External functions may not accept Ori-specific types (slices, maps, views) unless future FFI rules allow it

---

### 280.2.2 comptime

The `comptime` keyword controls compile-time execution.  
It appears only in two forms:
1. Compile-time constant declaration:
   ```ori
   comptime const NAME = expr
   ```
2. Compile-time-only function:
   ```ori
   comptime func name(...) ...
   ```

All expression-level uses of comptime are forbidden.  
See 250_Compiletime.md for the full specification.

---

## 280.3 Test Discovery Rules

Ori uses Go-style test discovery.

### 280.3.1 Test File Naming

Any file ending with:
```ori
*_test.ori
```
is treated as a test file.

### 280.3.2 Test Function Naming

Inside test files, any function beginning with:
```ori
Test
```
is treated as a test entry point.

Example:
```ori
func TestAdd() {
    var result = add(2, 3)
    if result != 5 {
        panic("expected 5")
    }
}
```
No special keywords or attributes are required.

---

## 280.4 Deprecation Handling

A function or type may be marked as deprecated using a standardized comment:
```ori
// Deprecated: Use NewAPI instead.
func OldAPI() {}
```
Tools may read this format and issue warnings.
No annotation syntax is required.

---

## 280.5 No Comment-Based Directives

Ori disallows all comment-based compiler directives such as:
```ori
// ori:inline
// ori:packed
// ori:cfg
```

These are forbidden because they:
- create implicit compiler behavior
- become a pseudo-annotation system
- reduce explicitness
- increase long-term complexity

Comments cannot alter compilation except for recognized deprecation notices.

---

## 280.6 Removed / Not Included Features

Ori intentionally excludes the following in v0.8 and v1.0:
- @attribute syntax
- Rust-style #[attribute]
- decorator-like constructs
- macro annotations
- layout directives such as packed
- inline keyword or directive
- conditional compilation attributes
- metadata or reflection annotations

These features are excluded to preserve clarity and simplicity.

---

## 280.7 Summary

Ori’s compiler directives are intentionally minimal:
- Keywords: extern, comptime
- Naming conventions: *_test.ori, TestXxx
- Standard comments: // Deprecated: ...
- No attribute or annotation system
- No comment-based directives
- comptime appears only in two declaration-level forms

This keeps Ori explicit, predictable, and easy to reason about.
