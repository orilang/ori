# ROADMAP_v0.12 – Formatting Foundations and CTR Phase 3

This roadmap defines the scope of Ori v0.12.  
The main theme of this version is to introduce the **semantic and compile-time prerequisites for a future `fmt` package**, without fully specifying `fmt` itself.  
The focus is on type-safe formatting, integration with existing semantics (logging, OS, time, StringBuilder, File), and a small, targeted extension of compile-time reflection (CTR).

All items below are **design/specification work only**; they do not imply a full standard library implementation in v0.12.

---

## 1. Compile-Time Reflection – Phase 3 (fmt-oriented)

**Spec file:** `semantics/341_CompiletimeReflection_Phase3.md`  
**Theme:** targeted, fmt-driven extensions to CTR.

**Goals:**
- Add the minimum additional CTR capabilities required to support a type-safe, non-reflective formatting model:
  - Compile-time "implements" checks, e.g. the ability to ask whether a type `T` implements a given interface `I` at compile time.
  - Stable, deterministic type naming suitable for diagnostics and `%T`-style formatting, derived from existing `TypeInfo` without introducing runtime reflection.
  - Clarify and, where necessary, extend `TypeInfo` / `StructInfo` / `EnumInfo` so that library code can derive simple default formatters at compile time (e.g. `StructName{field=value, ...}`) while remaining explicit and controlled.

**Non-goals:**
- No attribute-based derives (`@derive`, `@tag`, etc.).
- No new runtime reflection system.
- No generic, open-ended “macro system” beyond what already exists in compile-time execution.

This phase is strictly about giving the language enough compile-time inspection power for formatting and related diagnostics, while keeping Ori’s reflection model explicit and predictable.

---

## 2. Formatting Contract and Fmt Prerequisites in Semantics

**Spec file:** `semantics/410_FormattingAndFmtPrerequisites.md`  
**Theme:** define the *language-level* formatting model on which a future `fmt` package will be built.

**Goals:**
- Specify the core abstractions used for formatting:
  - A sink or writer interface that covers the act of writing formatted text (e.g. to `StringBuilder`, `File`, or other outputs).
  - One or more "formattable" interfaces that user-defined types may implement to control their textual representation (e.g. human-friendly vs debug-oriented output).
- Define how formatting interacts with:
  - Error handling (when and how formatting functions can fail).
  - Allocation rules (avoid hidden large temporary allocations; write primarily into the provided sink).
  - Existing primitives: `StringBuilder`, `File`/OS streams, time types, and errors.
- Specify which built-in types must have well-defined, built-in formatting behaviour (integers, floats, strings, booleans, errors, time types, etc.).

**Non-goals:**

- Do not define concrete `fmt` APIs (`Printf`, `Sprintf`, etc.) here; this file is about the *contract*, not a specific package.
- Do not introduce attributes or magic formatting annotations.

---

## 3. Format String Semantics and Static Checking

**Spec files (updates only):**

- `syntax/015_Literals.md`
- `syntax/070_Expressions.md`
- Other affected semantics files as needed (e.g. notes in `semantics/160_ControlFlow.md`, `semantics/170_MethodsAndInterfaces.md`).

**Theme:** define how Ori understands "format strings" and how the compiler can statically validate calls that use them.

**Goals:**
- Define the grammar of format strings used by a future `fmt` package:
  - The structure of format verbs.
  - Which verbs are allowed for which kinds of types (e.g. integer-only verbs, string-only verbs).
- Specify compile-time checking rules when:
  - The format string is a literal or compile-time constant.
  - The callee is a known “format function” (by specification, not attributes).
- Make mismatches between verbs and arguments **compile-time errors**, not warnings:
  - Wrong number of arguments.
  - Incompatible type for a given verb.
- Clarify behaviour when format strings are dynamic:
  - No static checking guarantees when the format string cannot be resolved at compile time.

**Non-goals:**
- Do not fully specify the `fmt` package interface itself.
- Do not handle localization/i18n; format strings remain opaque bytes/UTF-8 sequences for now.

---

## 4. Fmt Package Foundations (High-Level Design Only)

**Spec file:** `ecosystem/004_FmtPackageFoundations.md`  
**Theme:** high-level design of the future `fmt` package, grounded in the semantics from items 1–3.

**Goals:**
- Describe the **intended shape** of the `fmt` package as an ecosystem component:
  - Families of functions such as `Print/Println/Printf`, `Sprint/Sprintln/Sprintf`, and `Fprint/Fprintln/Fprintf`.
  - Expected roles of each family (stdout/stderr printing, string-building, writing to arbitrary sinks).
- Define how `fmt` will:
  - Use the formatting contract (`Formattable`, writer/sink interfaces).
  - Use CTR Phase 3 capabilities (e.g. compile-time `implements` checks, type names) to pick formatting strategies and produce better diagnostics.
  - Enforce format string checking as per item 3.
- Clarify the goals and non-goals of `fmt`:
  - Convenience, type safety, and predictability.
  - No general-purpose runtime reflection; no user-defined attributes.

**Non-goals:**
- Do not freeze the full public API surface of `fmt` in v0.12.
- Do not specify localization, templates, or advanced formatting beyond what is needed for v1.

---

## 5. Logging Framework – Phase 2 (Formatting Integration)

**Spec file:** `semantics/381_LoggingFramework_Phase2.md`  
**Theme:** integrate the logging framework with the new formatting model.

**Goals:**
- Revisit and extend `380_LoggingFramework_Phase1.md` to:
  - Allow log calls that use format strings in a type-safe way.
  - Define how logging uses the same formatting contracts and CTR-based capabilities defined above.
- Specify efficient behaviour:
  - Log messages must not perform expensive formatting if the log level is disabled.
  - When formatting is performed, it must follow the same rules and guarantees as the `fmt` design (allocation, error handling, type safety).
- Clarify integration with:
  - `time` (for timestamps).
  - `os` and `File` (for log outputs).
  - Potentially `StringBuilder` for in-memory log buffering.

**Non-goals:**

- Do not fully design a rich, structured logging ecosystem in v0.12.
- Do not define complex sinks, filters, or backends beyond those needed to validate the formatting integration.

---

## Out-of-Scope for v0.12

The following are explicitly **out of scope** for v0.12 and reserved for later versions (likely v1 or beyond):

- Full `fmt` package specification with final API and examples.
- Structured logging formats (JSON logs, key/value logging, etc.).
- Localization/internationalization support in formatting and logging.
- Any form of runtime reflection or attribute-based opt-in for formatting/derives.

v0.12 focuses entirely on **making the language and core semantics ready** for a safe, explicit, and powerful `fmt` design in a later version.
