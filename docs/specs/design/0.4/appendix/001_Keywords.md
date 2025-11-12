# 001. Keywords

Ori reserves a minimal but expressive set of keywords.  
They have special syntactic meaning and **cannot be used as identifiers** for variables, functions, or types.

---

## Control Flow
```
if        else
for       range
switch    case
default   break
continue  fallthrough
return
```

---

## Declarations
```
package   import
const     var
func      type
struct    map
hashmap   chan
```

---

## Error Handling
```
error     try
```

---

## Memory & Lifetime
```
alloc     free
defer     ref
view
```

---

## Boolean Literals
```
true      false
```

---

## Future Reserved Words
These are reserved for potential advanced features:
```
unsafe    interface
spawn     implements
```

---

> Ori’s keyword set is **intentionally small and stable** — focused on clarity, control, and predictability.  
> New keywords will only be added if they improve readability without introducing hidden behavior.
