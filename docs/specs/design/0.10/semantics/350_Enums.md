# 350. Enums

Enums in Ori represent a **closed set of named, symbolic variants**.  
They are implemented as **field-less sum types**, providing strong typing, exhaustive switching, and complete safety without integer representations or implicit conversions.  
Enums integrate cleanly with Ori’s type system, container model, pattern matching rules, and compile-time reflection.

---

# 350.1 Goals and Philosophy

Enums in Ori serve three purposes:
1. Represent a **small, fixed, closed set** of states or symbolic values.
2. Provide **type-safe**, **namespace-scoped** constants.
3. Enable **exhaustive** `switch` statements for correctness and clarity.

Enums are intentionally **not integer-backed**, because Ori forbids:
- implicit conversions
- fragile numeric identities
- iota-like auto-numbering
- attribute-based representation control (see `280_CompilerDirectivesAndKeywords.md`)

Enums in Ori are *pure symbolic variants* with no associated payloads.

---

# 350.2 Syntax

An enum is declared using the `type enum` form:
```ori
type enum Color =
    | Red
    | Green
    | Blue
```

Each variant:
- has no payload
- belongs to the enum’s namespace
- is a distinct constant value of the enum type

There is no support for:
- assigning explicit numeric values
- controlling representation
- attaching attributes
- bitflags or mask semantics
- payload variants (these belong to general sum types)

---

# 350.3 Type Semantics

Enums behave as **value types**:
- They occupy a small, fixed amount of memory determined by the compiler
- They have no heap allocation
- They are trivially comparable
- They are deterministic and immutable

## 350.3.1 Equality

Two enum values are equal if and only if they are the same variant:
```ori
var c Color = Color.Red
if c == Color.Red { /* true */ }
if c == Color.Green { /* false */ }
```

Enums are fully comparable and therefore **may be used as map keys** (see comparable key rules in `110_Maps.md`).

## 350.3.2 Assignment and Copying

Enums are assigned and copied by value:
```ori
var a Color = Color.Red
var b Color = a   // independent copy
```

---

# 350.4 Pattern Matching and Switch Exhaustiveness

Enums integrate directly with Ori’s `switch` semantics for sum types.

### 350.4.1 Strict Exhaustive Switch (NO DEFAULT ALLOWED)

A switch over an enum must cover all variants:
```ori
switch c {
    case Color.Red   : ...
    case Color.Green : ...
    case Color.Blue  : ...
}
```

If any variant is missing, the compiler emits a compile-time error.

---

### 350.4.2 Default Clauses Are Forbidden

Enums represent a fully known, closed set of variants.  
Allowing `default` would hide missing cases.

This is a **compile-time error**:
```ori
switch c {
    case Color.Red   : ...
    default          : ...   // ❌ forbidden for enums
}
```

This rule ensures:
- full exhaustiveness
- future-proofing when adding new enum values (all switches must update)
- clarity and safety

---

# 350.5 No Integer Representation

Enums have **no numeric form**.
Forbidden operations:
```ori
var x int = Color.Red        // ❌ no implicit or explicit conversion
var y Color = 1              // ❌ invalid enum construction
println(Color.Red + 1)       // ❌ arithmetic not allowed
```

Enums cannot be assigned numeric values, and the ordering of variants has no semantic meaning.

This avoids:
- iota-style silent shifting
- unsafe interop
- layout/ABI instability
- accidental misuse in arithmetic contexts

---

# 350.6 Interaction with Containers

Enums work naturally with all container types documented in v0.7:
## 350.6.1 Slices

```ori
var xs []Color = []Color{Color.Red, Color.Blue}
```

## 350.6.2 Arrays

```ori
var arr [3]Color = [3]Color{Color.Red, Color.Green, Color.Blue}
```

## 350.6.3 Maps (ordered)

Enums may be used as keys because they are comparable:
```ori
var m map[Color]string = make(map[Color]string)
m[Color.Red] = "stop"
m[Color.Green] = "go"
```

## 350.6.4 HashMaps (unordered)

Same rules apply:
```ori
var h hashmap[Color]int = make(hashmap[Color]int)
h[Color.Blue] = 42
```

Enums have no heap storage and therefore integrate cleanly with all ownership rules defined in `260_ContainerOwnershipModel.md`.

---

# 350.7 Deterministic Destruction

Enums have no internal resources.  
Destruction is trivial:
- they contain no handles
- they own no heap memory
- they require no cleanup logic

They behave identically to small integer-like value types in terms of destruction, but without any integer identity.

---

# 350.8 Compile-Time Reflection

Compile-time reflection does not yet expose enum metadata.  
CTR Phase 2 will allow inspecting:
- the list of variants
- the names of variants
- the parent enum type

Example:
```
comptime for v := reflect.Enum(Color).variants {
    println(v.name)
}
```

CTR does **not** expose underlying integer values because enums do not have any.

---

# 350.9 Error Conditions

The compiler must reject:

### 350.9.1 Duplicate Variant Names

```ori
type enum Status =
    | Ok
    | Ok    // ❌ duplicate
```

### 350.9.2 Missing Pipe Symbol

```ori
type enum State =
    Idle      // ❌ missing '|'
    | Running // ✔ valid
```

### 350.9.3 Unused or Unknown Enum Variant Names

Using undeclared variants is an error:
```ori
if x == Color.Purple { } // ❌ Purple not declared
```

### 350.9.4 Attempting Numeric Conversions

```ori
var n int = Color.Red // ❌ no conversion allowed
```

### 350.9.5 Instantiating Enums Incorrectly

```ori
var s State = State() // ❌ enums have no constructor
```

---

# 350.10 Examples

### Basic Enum

```ori
type enum Light =
    | Red
    | Yellow
    | Green

func action(l Light) string {
    switch l {
        case Light.Red    : return "stop"
        case Light.Yellow : return "prepare"
        case Light.Green  : return "go"
    }
}
```

### Enum as Map Key

```ori
var scores map[Level]int = make(map[Level]int)
scores[Level.Easy] = 10
scores[Level.Hard] = 50
```

### Enum in Array

```ori
var seq [3]Light = [3]Light{Light.Red, Light.Green, Light.Red}
```

---

# 350.12 Summary

Enums in Ori are:
- **field-less sum types**
- **type-safe**, **comparable**, **hashable**
- **exhaustively switchable**
- **non-numeric**, **non-represented**
- **consistent with all ownership and container rules**
- **free of attributes or iota-like semantics**

This design ensures long-term safety and clarity.
