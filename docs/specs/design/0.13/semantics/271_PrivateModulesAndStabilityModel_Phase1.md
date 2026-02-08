# 271. Private Modules and Stability Model — Phase 1

## 271.1 Purpose

Ori introduces a dedicated directory named `private/` to clearly separate
**public module API** from **private implementation details**.

This mechanism is inspired by Go’s `internal/` directory but provides a clearer
name and a more explicit structure aligned with Ori’s principles:

- **Explicitness**
- **Predictable architecture**
- **Clear visibility boundaries**
- **Simple, folder-based semantics without keywords or metadata**

Phase 1 defines the folder structure, import rules, and early stability model.
**Full stability enforcement is intentionally deferred** until Ori is mature
enough to support a strict, stable module ecosystem.

## 271.2 Overview

A module may contain a directory named:
```
private/
```

Any packages inside `private/`:
- **are visible only within the same module**,  
- **cannot be imported by external modules**,  
- **cannot be part of the module’s public API surface**,  
- **may optionally be organized into stability tiers**.

This provides a clean separation between:
- **public packages** (top-level directories)
- **private implementation packages** (under `private/`)

## 271.3 Directory Structure

### 271.3.1 Base Structure

```
module/
    foo/                 ← public
    bar/                 ← public
    private/             ← private subtree (module-only)
```

### 271.3.2 Optional Stability Tiers

Developers may optionally create:
```
private/
    stable/
    unstable/
```

These folders communicate the intended stability of private APIs.  
**They do not enforce behavior yet in Phase 1**, but they define the future model.

Examples:
```
private/stable/logging/
private/stable/runtime/
private/unstable/scheduler_v2/
private/unstable/parser_experimental/
```

## 271.4 Visibility Rules (Phase 1 — Fully Enforced)

### 271.4.1 Private Visibility Boundary

- Any package located under `private/` is **importable only by packages inside the same module**.
- External modules attempting to import `module/private/...` MUST produce a compile-time error.

### 271.4.2 Top-Level Public Packages

- Packages at the module root or in subdirectories **not under `private/`** are considered public.
- Public packages may form the module’s API surface.
- Public packages may import private packages (Phase 1 does NOT restrict this yet).

## 271.5 Stability Model (Phase 1 — Not Yet Enforced)

Ori defines two optional maturity tiers under `private/`:

### 271.5.1 `private/stable/`

Internal APIs expected to remain stable.

### 271.5.2 `private/unstable/`

Experimental, evolving, or prototyping code.

### 271.5.3 No Compile-Time Enforcement Yet

`Phase 1` intentionally does not enforce stability restrictions. Enforcement will be introduced once Ori’s ecosystem matures.

## 271.6 Expected Future Behavior (Non-Binding)

Possible future rules include:
- Public packages importing unstable → error or warning.
- Public packages importing stable → allowed but not re-exported.
- Private stable packages importing unstable → warning.
- Compiler flags like `--allow-unstable` / `--disallow-unstable`.

Graduation:
```
mv private/unstable/foo private/stable/foo
```

## 271.7 Design Rationale

Folder-based model chosen for:
- Simplicity
- Explicitness
- Predictability
- Extensibility
- Better clarity than Go, Zig, Rust

## 271.8 Examples

### Example 1 — Private Unstable

```
private/unstable/scheduler2/
```

### Example 2 — Private Stable

```
private/stable/hash/
```

## 271.9 Diagnostics (Phase 1)

Only enforced rule:

**Error:** Importing private code from outside the module.

## 271.10 Future Work

- Strict stability enforcement
- Re-export rules
- Diagnostics
- Integration with modules and build system

## 271.11 Summary

`Phase 1` provides:
- `private/` visibility boundary
- optional stability tiers
- no enforced rules yet beyond module visibility
- foundation for a future stability model
