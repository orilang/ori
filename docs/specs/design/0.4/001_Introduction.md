# 1. Introduction

**Ori** is a **system-capable general-purpose programming language** designed for **clarity, performance, and explicit control**.

It combines the **expressiveness of high-level languages** with the **predictability and precision of systems languages**, allowing developers to build everything — from **operating systems and compilers** to **UI applications and web servers** — using a single consistent model of execution.

Ori’s design emphasizes:
- **Explicit behavior** — nothing happens implicitly.
- **Predictable performance** — copy and reference semantics are always visible in code.
- **Deterministic safety** — clear lifetime, memory, and error rules.

## 1.1 Goals

Predictable and explicit semantics.  
Clear and consistent syntax.  
Safe memory and type model.  
Zero hidden behaviors.

## 1.2 Document Structure
The specification is split across modular files for clarity:
- Core syntax and semantics in `/syntax` and `/semantics/`
- Design rationale and comparisons in `/design_principles/`
- Reference material in `/appendix/`

See the [index](000_INDEX.md) for navigation.

## 1.3 Notation

Ori uses [Wirth syntax notation (WSN)](https://en.wikipedia.org/wiki/Wirth_syntax_notation).
It's an alternative to [Extended Backus-Naur Form (EBNF)](https://en.wikipedia.org/wiki/Extended_Backus%E2%80%93Naur_form) that you might saw in other design language.

Here is the syntax notation:
```
SYNTAX     = { Production } .
 Production = Identifier "=" Expression "." .
 Expression = Term { "|" Term } .
 Term       = Factor { Factor } .
 Factor     = Identifier
            | Literal
            | Optional
            | Grouping
            | Repetition .
 Identifier = letter { letter } .
 Optional   = "[" Expression "]" .
 Repetition = "{" Expression "}" .
 Grouping   = "(" Expression ")" .
 Literal    = '"' character { character } '"' .
```

---

## 1.4 Source code encoding

Ori source code is encoded in [UTF-8](https://en.wikipedia.org/wiki/UTF-8).  
Invalid UTF-8 sequence will endup in a compilation error.

---
