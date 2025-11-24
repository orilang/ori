# 220 Deterministic Destruction

## 220.1 Overview

Deterministic destruction in Ori defines how resources are safely and predictably cleaned up when an owning value reaches the end of its lifetime.  
This mechanism integrates with the ownership and lifetime model and extends it with destructors and structured `defer` semantics.

---

## 220.2 Goals

- **Predictable cleanup** at lexical scope exit.
- **Zero-panic destructors**: destructor bodies must not contain any code path that can panic.
- **Safe interplay with `defer`**, which runs before destructors.
- **Move-only semantics** for types that declare destructors.
- **Deterministic behavior during panic unwinding.**
- **Explicit, opt-in cleanup**: only types declaring destructors participate.

---

## 220.3 Core Concepts

### 220.3.1 Destructor (conceptual)

A **destructor** is a block associated with a type:

```ori
destructor TypeName {
    // cleanup logic
}
```

Inside this block:
- `value` refers to the owned instance being destroyed
- It is implicitly provided by the compiler
- It cannot be reassigned or moved out
- It is always valid for the duration of the destructor execution

One destructor may be defined per nominal type.

### 220.3.2 Owning Value

Only **owning values** can trigger destruction. Non-owning references (`view`, `shared`, etc.) never run destructors.

### 220.3.3 Destruction Point

A value is destroyed when:
- Its scope ends (normal exit)
- Control-flow leaves its scope early (`return`, `break`, `continue`)
- Ownership is transferred (full move)
- A panic unwinds past its scope

---

## 220.4 When Destruction Occurs

### 220.4.1 Normal Scope Exit

Values are destroyed in **reverse declaration order** (LIFO).  
Destructors run only for types that declare them.

### 220.4.2 Early Exit

`return`, `break`, `continue` trigger destruction of local variables before control flow leaves the scope.

### 220.4.3 Panic Unwinding

During panic unwinding:

1. All `defer` blocks execute in **reverse registration order**.
2. All destructors run in **reverse declaration order**.

Destructors cannot panic, ensuring no double-unwind hazards.

---

## 220.5 Interaction with `defer`

### 220.5.1 Syntax

```ori
defer statement
```

or

```ori
defer {
    // block
}
```

### 220.5.2 Ordering

On scope exit:

1. `defer` blocks (LIFO)
2. destructors (LIFO)

Example:

```ori
func f() {
    var a A
    defer log("first")
    var b B
    defer log("second")
}
// exit order: log("second"), log("first"), destroy b, destroy a
```

---

## 220.6 Moves, Copies, and Destruction

### 220.6.1 Move-Only for Types with Destructors

Types declaring destructors cannot be implicitly copied:

```ori
var a T
var b T = a   // compile-time error
```

### 220.6.2 Full Moves

Ownership transfers fully.  
The source becomes invalid and will not be destroyed.

### 220.6.3 Partial Moves (Struct Fields)

Fields moved out of a struct:
- are no longer destroyed by the original struct
- are destroyed when the new owner is destroyed

Remaining fields are destroyed normally.  
Compiler tracks which fields remain valid.

---

## 220.7 Panic Rules

### 220.7.1 Destructors Cannot Panic

Any potential panic inside the destructor body is a **compile-time error**:
- no explicit `panic`
- no operations that can panic
- no calls to functions that can panic

### 220.7.2 Runtime Implications

- Unwinding is simple and safe
- No double-panic scenarios
- Cleanup is reliable in all exit paths

---

## 220.8 Aggregates and Containment

### 220.8.1 Structs

If a struct has a destructor:
- It handles its own finalization
- Then its fields are destroyed automatically in reverse declaration order (unless moved out)

If it does not:
- Only fields with destructors are destroyed.

### 220.8.2 Arrays

Elements are destroyed from the last to the first.

### 220.8.3 Slices and Maps

Based on the v0.5 memory model:

- Containers that **own** elements are responsible for destroying them.
- Containers that only **reference** storage must not destroy elements.

---

## 220.9 Surface Syntax

### 220.9.1 Destructor Declaration

```ori
destructor TypeName {
    // implicit: value : TypeName
}
```

Example:

```ori
struct File {
    fd int
}

destructor File {
    if value.fd >= 0 {
        close_fd(value.fd)
    }
}
```

### 220.9.2 Restrictions

Inside a destructor:
- `value` is implicitly provided and refers to the owned instance
- No parameters allowed
- No return values
- No `panic`
- No `defer` inside destructor
- Cannot call functions that may panic
- Cannot move `value` or reassign it

---

## 220.10 Examples

### 220.10.1 Valid Examples

#### Simple Resource Destructor

```ori
struct File {
    fd int
}

destructor File {
    if value.fd >= 0 {
        close_fd(value.fd)
    }
}
```

#### Struct with Fields

```ori
struct Connection {
    file File
    lock Mutex
}

destructor Connection {
    // connection-level cleanup
}
// then lock and file destructors run automatically
```

---

### 220.10.2 Forbidden Examples (Compile-Time Errors)

#### 220.10.2.1 Destructor that may panic

```ori
destructor Buffer {
    log(value.data[value.len])   // may panic → compile-time error
}
```

```ori
destructor Foo {
    panic("not allowed")         // ❌ compile-time error
}
```

```ori
func risky() {
    panic("x")
}

destructor Foo {
    risky()                      // ❌ compile-time error
}
```

#### 220.10.2.2 Destructor with parameters

```ori
destructor File(extra int) { }   // ❌ forbidden, compile-time error
```

#### 220.10.2.3 Destructor with return type

```ori
destructor File int { return 3 }   // ❌ forbidden, compile-time error
```

#### 220.10.2.4 `return` inside destructor

```ori
destructor File {
    return                        // ❌ forbidden, compile-time error
}
```

#### 220.10.2.5 Multiple destructors for the same type

```ori
destructor File { }
destructor File { }               // ❌ forbidden, compile-time error
```

#### 220.10.2.6 Destructor for primitive or alias

```ori
destructor int { }               // ❌ forbidden, compile-time error
```

```ori
type UserID = int
destructor UserID { }            // ❌ forbidden, compile-time error
```

#### 220.10.2.7 Manual call of destructor

```ori
var f File
f.destructor()                   // ❌ forbidden, compile-time error
```

#### 220.10.2.8 Moving out `value`

```ori
destructor Box {
    other = value                // ❌ full move forbidden, compile-time error
}
```

```ori
destructor Foo {
    y := move(value.x)           // ❌ partial move forbidden, compile-time error
}
```

#### 220.10.2.9 Assigning to `value`

```ori
destructor Foo {
    value = Foo{}                // ❌ forbidden, compile-time error
}
```

#### 220.10.2.10 `defer` inside destructor

```ori
destructor File {
    defer log("should not happen") // ❌ forbidden, compile-time error
}
```

#### 220.10.2.11 Blocking or spawning

```ori
destructor Socket {
    spawn_task(handle(value))     // ❌ forbidden, compile-time error
    spawn_thread(handle(value))   // ❌ forbidden, compile-time error
}
```

```ori
destructor Foo {
    for {}                 // ❌ forbidden, infinite block, compile-time error
}
```

#### 220.10.2.12 Destructor declared inside a block

```ori
func test() {
    destructor File { }           // ❌ forbidden, compile-time error
}
```

#### 220.10.2.13 Using moved-out fields

```ori
struct S {
    x Resource
    y Resource
}

func test() {
    var s S
    take(s.x)                     // move-out
}

destructor S {
    close(value.x)                // ❌ forbidden, x was moved out compile-time error
}
```

#### 220.10.2.14 Recursive destruction

```ori
destructor Node {
    destroy(value)                // ❌ forbidden conceptual recursion, compile-time error
}
```

---

## 220.11 Compiler Responsibilities - Static Semantics

### 220.11.1 Type Eligibility and Registration

The compiler must:
- Ensure destructors only apply to nominal types.
- Reject destructors for primitives or primitive aliases.
- Enforce that only one destructor may be defined per type.
- Mark types with destructors as non-copyable.

---

## 220.12 Panic-Freedom Analysis

### 220.12.1 Direct Panic Sources

Explicit panics or constructs that inherently panic are rejected.

### 220.12.2 Calls to Potentially Panicking Functions

Destructors may only call panic-free functions. Any call to a function without a guaranteed no-panic status is rejected.

### 220.12.3 Control Flow

All branches must be verified panic-free.

---

## 220.13 Ownership and Move Tracking in Destructors

### 220.13.1 Value State Tracking

Compiler tracks the state of `value` and its fields:
- Valid
- Moved
- Invalid

### 220.13.2 Forbidden Moves

Any move of `value` or its fields is rejected.

### 220.13.3 Using Moved-Out Fields

Use of moved-out fields inside the destructor produces errors.

---

## 220.14 Scope Lowering and Code Generation Model

Compiler rewrites scopes into:
- user code
- `defer` stack
- deterministic destruction tail

---

## 220.15 Integration with Other Semantics Files

### 220.15.1 Types And Memory

Types with destructors become move-only.

### 220.15.2 Methods And Interfaces

Destructors are not part of method sets or interfaces.

### 220.15.3 Concurrency

Destructors must not spawn or block indefinitely.

---

## 220.16 Diagnostics

Compiler should emit precise messages for:
- panic paths
- illegal moves
- duplicate destructors
- invalid placements
- etc.

---

## 220.17 Non-Goals for current implementation

- Async-aware destructors
- Multi-phase destruction
- Destructor overloading
- Automatic or GC-like finalizers
- Dynamic destruction registration beyond `defer`

---

## 220.18 Automatic Destructor Synthesis

This section defines how Ori handles destructors for types where the user does **not** explicitly declare one, and how automatic field destruction behaves.

Deterministic destruction must remain:
- zero-cost when no cleanup is needed
- predictable when some fields require destruction
- safe when user-defined destructors exist

---

### 220.18.1 Types That Do Not Need a Destructor

No destructor (neither user-defined nor synthesized) is created when:

- the type has **no fields** whose types have destructors, and
- the type has **no special ownership semantics** requiring cleanup

Examples:
```ori
struct Point {
    x float
    y float
}

struct Id {
    value int
}
```

These types:
- remain trivially copyable (unless restricted by other rules),
- incur **zero** destruction overhead.

---

### 220.18.2 Types That Require Automatic Field Destruction

If a type has **no user-declared destructor** but contains fields whose types have destructors, the compiler **synthesizes** field destruction.

Example:
```ori
struct Session {
    conn Connection  // Connection has a destructor
    token string
}
```

The compiler behaves conceptually as if it had generated:
```ori
destructor Session {
    // no Session-specific logic
    // destroy fields in reverse declaration order
    destroy(value.conn)
}
```

Notes:
- `Session` becomes move-only, because it contains a field (`Connection`) that has a destructor
- Field destruction order is always last-declared → first-declared

---

### 220.18.3 Example – Nested Structs

```ori
struct Cache {
    buf Buffer    // Buffer has destructor
}

struct State {
    cache Cache   // Cache requires destruction
    id    Id      // Id has no destructor
}
```

Here:
- `Cache` gets synthesized field destruction for `buf`
- `State` gets synthesized field destruction for `cache` only

Conceptual expansion:

```ori
destructor Cache {
    destroy(value.buf)
}

destructor State {
    destroy(value.cache)
}
```

No destructor is ever needed for `Id`.

---

### 220.18.4 User-Defined Destructor + Automatic Field Destruction

When the user declares a destructor for a type `T`, the compiler:
1. Runs the user-defined destructor body.
2. Then automatically destroys any remaining fields of `T` that:
   - are still valid
   - and whose types have destructors

Example:

```ori
struct Resource {
    data view[byte]
    alloc Allocator
}

destructor Resource {
    if value.data != nil {
        value.alloc.free(value.data)
    }
    // alloc is not destroyed here
}
```

If `Allocator` has a destructor, the compiler behaves like:

```ori
destructor Resource {
    if value.data != nil {
        value.alloc.free(value.data)
    }
    // automatic field destruction (reverse declaration order):
    destroy(value.alloc)
}
```

Rules:
- User code handles type-specific logic
- The compiler still guarantees field cleanup, without double-destroying moved-out fields

---

### 220.18.5 Example – Partial Moves and Synthesis

```ori
struct Pair {
    left  File
    right File
}

func useRight(p Pair) {
    take(p.right)   // move-out `right`
    // `left` is still valid here
}
```

Destruction behavior:
- The compiler tracks that `right` was moved out
- The synthesized destructor for `Pair` only destroys `left`

Conceptually:

```ori
destructor Pair {
    // destruction of fields in reverse order,
    // but skipping fields marked as moved-out:
    if field_is_valid(value.right) {
        destroy(value.right)      // skipped in this example
    }
    if field_is_valid(value.left) {
        destroy(value.left)       // runs
    }
}
```

Any attempt in a **user-defined** destructor to explicitly destroy `value.right` after it was moved out remains a **compile-time error**.

---

### 220.18.6 Example – Sum Types

Consider the sum type below:
```ori
type Shape =
    | Circle(radius float)
    | Rect(w float, h float)
    | Image(buf Buffer)
```

If `Shape` has no explicit destructor:
- The compiler synthesizes destruction that depends on the active variant.
- Only the active variant’s payload is destroyed.

Conceptually:
```ori
destructor Shape {
    switch value {
    case Circle:
        // nothing to destroy
    case Rect:
        // nothing to destroy
    case Image:
        destroy(value.buf)
    }
}
```

Key points:
- Only the **current variant** participates in destruction
- There is **no implicit recursion**; only variant payloads are destroyed
- If `Buffer` changes its destructor behavior, `Shape` automatically follows

---

### 220.18.7 Zero-Cost Guarantee

Ori guarantees:

> If a type and all of its fields have no destructors, the compiler does not generate any destruction code or metadata for that type.

This applies even for deep nesting:

```ori
struct A { x int }
struct B { a A }
struct C { b B }
```

None of `A`, `B`, `C` get destructors or destruction tails.

---

### 220.18.8 Diagnostics for Synthesis Edge Cases

The compiler should emit clear diagnostics if automatic destruction becomes ambiguous or unsafe, for example:
- When combining user-defined destructors with complex partial moves.
- When synthesized destruction would attempt to destroy an already moved-out field (which should be rejected earlier by move tracking).
- When types are arranged in patterns that could look recursive but are actually just pointer graphs (no automatic traversal).

All such errors should point to:
- the type that triggered synthesis,
- the field that required destruction,
- and the user-defined destructor (if any) involved in the conflict.

---

### 220.18.8.1 Error: Synthesized destructor must destroy a field that was moved out

```ori
struct Pair {
    left  File
    right File
}

func consume(p Pair) {
    take(p.right)  // move-out
} // destructor synthesis required for Pair
```

**Compiler error**

```
error: cannot synthesize destructor for 'Pair':
       field 'right' was moved out and cannot be destroyed.
help: consider writing a custom destructor for 'Pair'
```

---

### 220.18.8.2 Error: User-defined destructor conflicts with synthesized field destruction

```ori
struct Holder {
    buf Buffer
}

destructor Holder {
    destroy(value.buf)   // user destroys this
}
```

**Compiler error**

```
error: destructor for 'Holder' manually destroys field 'buf',
       but this field also participates in automatic destruction.
help: do not manually destroy fields; only write type-level cleanup.
```

---

### 220.18.8.3 Error: User-defined destructor attempts to destroy a moved-out field

```ori
struct Frame {
    tmp TempBuf
    img Image
}

func decode(f Frame) {
    take(f.tmp) // move-out
}

destructor Frame {
    destroy(value.tmp)   // ❌ illegal
}
```

**Compiler error**

```
error: field 'tmp' has been moved out and cannot be destroyed
note: this prevents synthesizing a correct destructor for 'Frame'
help: remove manual field destruction; rely on automatic destruction
```

---

### 220.18.8.4 Error: Recursive type requiring synthesis but containing owned fields

```ori
struct Node {
    next Node     // ❌ illegal: recursive value containment
    data Buffer
}
```

**Compiler error**

```
error: cannot synthesize destructor for recursive type 'Node'
       value-type recursion is not allowed when the type owns fields
help: use a pointer to 'Node' instead
```

---

### 220.18.8.5 Error: Ambiguous ownership in generic types

```ori
struct Box[T] {
    item T
}

func process[T](x Box[T]) {
    take(x.item)    // move-out inside generic function
}
```

**Compiler error**

```
error: destructor synthesis for 'Box[T]' is ambiguous:
       field 'item' was moved out but T may or may not own resources
help: require 'T' to be move-only or panic-free via a generic constraint
```

---

### 220.18.8.6 Example – Using Generic Constraints

```ori
interface Disposable { }

struct Box[T Disposable] {
    item T
}
```

---

### 220.18.8.7 Error: Interface object cannot infer destructor requirements

```ori
interface Writer {
    write(view[byte]) int
}

struct FileWriter {
    file File
}

var w Writer = FileWriter{ ... }
```

**Compiler error**

```
error: cannot destroy value of interface type 'Writer'
       dynamic destructor dispatch is not supported
help: store concrete types, or wrap the resource in an owning struct
```

---

### 220.18.8.8 Error: Synthesized destructor would require dynamic dispatch

```ori
interface Closeable { }

struct Handle[T Closeable] {
    obj T
}

func use(h Handle[Writer]) { }  // Writer is an interface
```

**Compiler error**

```
error: cannot synthesize destructor for 'Handle[Writer]':
       'Writer' is an interface and may have multiple implementations
help: use a concrete type argument instead of an interface
```

---

### 220.18.8.9 Error: Sum type variant requires custom destructor

```ori
type Boxed =
    | One(buf Buffer)
    | Two(ptr *byte)

func leak(b Boxed) {
    switch b {
    case One:
        take(b.buf)   // move-out
    }
}
```

**Compiler error**

```
error: variant 'One' of sum type 'Boxed' contains field 'buf'
       which may be moved out, preventing safe destruction synthesis
help: write an explicit destructor for 'Boxed'
```

---

## 220.19 Move Semantics and Destructor Interactions

This phase defines how deterministic destruction interacts with moves, returns, assignments, swaps, temporaries, generics, and pattern matching.
The goal is complete predictability with no hidden copies or accidental double‑destruction.

---

### 220.19.1 Reassignment of Variables Holding Destructible Types

If a type `T` has a destructor, then `T` is **move‑only**.

```ori
var a T
var b T

a = b       // ❌ forbidden: implicit copy
a = move(b) // allowed: ownership moves
```

Semantics of reassignment:
1. Destroy previous value of `a`
2. Move ownership from `b` into `a`
3. Mark `b` as invalid

---

### 220.19.2 Returning Values with Destructors

Returning a destructible value transfers ownership to the caller.

```ori
func make_file() File {
    var f File
    return f   // move f to caller
}
```

The destructor for `f` runs **only** in the caller, not inside `make_file`.

Returning parameters is also a move:
```ori
func forward(f File) File {
    return f   // moves f out, f becomes invalid
}
```

Each return path must either:
- move the value out, or
- destroy it

but never both.

---

### 220.19.3 Swaps

Swapping two values of destructible types must occur via moves.

Conceptual semantics:

```ori
swap(a, b)
```

is lowered to:

1. tmp = move(a)
2. a = move(b)
3. b = move(tmp)

No destruction occurs during the swap itself.

---

### 220.19.4 Temporaries and Expression Lifetimes

Temporaries created by expressions have well‑defined lifetimes.

Example:
```ori
use(make_file())
```

Semantics:
1. `make_file()` creates a temporary `File`
2. It is moved into the parameter of `use`
3. No destructor runs for the temporary
4. Destructor runs when the parameter’s lifetime ends

If a temporary is not moved into anything:

```ori
func f() {
    do_something(make_file())  
    // temporary destroyed at end of expression
}
```

---

### 220.19.5 Pattern Matching and Move Semantics in Sum Types

```ori
type Shape =
    | Circle(r float)
    | Image(buf Buffer)

func consume(s Shape) {
    switch s {
    case Image:
        take(s.buf) // move-out
    }
}
```

At destruction:
- `buf` must only be destroyed if still valid  
- Attempting to destroy moved-out variant payload is a compiler error  
- If the compiler cannot confirm validity, it rejects synthesis and requires an explicit destructor

---

### 220.19.6 Generics and Destructor-Aware Constraints

Example: types that *always* require destruction:

```ori
interface Disposable { }

struct Box[T Disposable] {
    item T
}
```

Synthesized:
```ori
destructor Box[T Disposable] {
    destroy(value.item)
}
```

Types that *never* require destruction:

```ori
interface Copyable { }

struct PodBox[T Copyable] {
    item T
}
```

Generic functions:

```ori
func forward[T](x T) T {
    return x   // move if T is move-only, copy if T is trivial
}
```

Compiler tracks move-only status through constraints.

---

### 220.19.7 Destructor Elision & Optimizations

Elision is allowed only if semantics remain unchanged:

- RVO (construct into caller's storage)
- Skip destroying dead temporaries
- Skip intermediate destructors if proven unnecessary

But:

> Every owning value must still be destroyed exactly once in the final observable execution.

No optimization may skip or duplicate destruction.

---

## 220.20 ABI, Lowering & Runtime Model

This phase defines how destructors integrate with the ABI, code generation, cross-module boundaries,
panic-unwind behavior, optimization, and debugging. This completes the formal model.

---

### 220.20.1 ABI Representation of Destructors

Ori uses **compile‑time only** destructor knowledge. No runtime metadata or RTTI is stored in objects.

RTTI (Run-Time Type Information) is runtime metadata that allows a program to inspect or identify types during execution. Ori does not use RTTI; all type and destructor information is known at compile time, ensuring zero-overhead and deterministic behavior.

#### 220.20.1.1 No RTTI (Run-Time Type Information) or dynamic dispatch

- No vtables
- No type tags
- No runtime destructor pointers

Each nominal type with a destructor emits exactly one function:

```
__ori_destruct_TypeName(TypeName* value)
```

Example:
```
__ori_destruct_File(File* value)
```

#### 220.20.1.2 ABI Stability

If a module exports a type with a destructor:
- That destructor symbol forms part of the module's stable ABI.
- It must not change calling convention or signature across patch versions.

---

### 220.20.2 Lowering Rules (Compiler Rewriting)

The Ori compiler rewrites each lexical scope into:
1. **User code**
2. **Defer stack**
3. **Deterministic destruction tail**

Lowering example:

```ori
func f() {
    var x A
    defer log("x")
    var y B
}
```

Lowered:

```
f():
    alloc x
    register_defer(scope0, log("x"))
    alloc y

scope0_exit:
    run_defer(scope0)   # log("x")
    destroy y
    destroy x
    return
```

---

### 220.20.3 Lowering of Early Exits

#### 220.20.3.1 Return

```ori
return expr
```

Lowered into:

```
move expr → return_slot
jump scope0_exit_after_return
```

#### 220.20.3.2 Break / Continue

```
jump scope_exit
jump loop_target
```

Cleaning up every intermediate scope is mandatory.

---

### 220.20.4 Panic Unwinding ABI Behavior

Panic unwinding proceeds deterministically:

```
unwind_frame:
    run defer stack (reverse order)
    run destructors   (reverse order)
    continue unwinding
```

#### Guarantees:
- Destructors cannot panic (compile‑time enforced)
- No double-unwind hazards
- Every owned value is destroyed once

Example:

```ori
func f() {
    var a A
    defer log("A")
    var b B
    panic("fail")
}
```

Unwind order:
```
log("A")
destroy b
destroy a
```

---

### 220.20.5 Cross‑Module Behavior

If module A uses a destructible type from module B:

Module A lowers destruction into:

```
call __ori_destruct_TypeFromB(&local_value)
```

No dynamic dispatch or RTTI is needed.

ABI rule:
> Cross‑module destructor calls must always resolve to the original module’s destructor.

---

### 220.20.6 Calling Conventions

Destructor signature:

```
void __ori_destruct_T(*T value)
```

Properties:
- `nounwind`
- internal linkage unless exported
- may be inlined
- must not allocate or panic

Example emitted header:
```
define internal fastcc void @__ori_destruct_File(%File* %value) nounwind {
    ...
}
```

---

### 220.20.7 Optimization Model

#### 220.20.7.1 Allowed Optimizations

- Return Value Optimization (RVO)/No Return Value Optimization NRVO
- Inlining destructors
- Eliding destruction of dead temporaries
- Skipping destructor calls for values proven unreachable

Example (dead temporary):

```ori
func test() {
    make_file("tmp.txt")   // destructor runs for temporary
}
```

Lowered:

```
call __ori_destruct_File(&tmp)
```

The compiler may inline and eliminate this if `tmp` is proven unused.

#### 220.20.7.2 Forbidden Optimizations

The compiler must NOT:
- reorder defers relative to destructors
- reorder destructors across scopes
- omit destructor calls for owned values  
- duplicate destruction

---

### 220.20.8 Debugging & Tooling Behavior

#### 220.20.8.1 Destructor Symbol Visibility
If not inlined, destructors appear in stack traces:

```
__ori_destruct_File
__ori_destruct_Connection
```

#### 220.20.8.2 Debug Stepping
Debuggers:
- Step *into* destructors like normal functions
- Step field-by-field if inlined
- Skip entirely if optimized away

#### 220.20.8.3 Panic Stack Traces

```
panic: failure
  at foo.ori:23
  at __ori_destruct_Buffer
  at __ori_destruct_Session
```

---

### 220.20.9 Lifetime Boundaries & ABI Guarantees

Ori guarantees:
- Each owning value destroyed exactly **once**
- Full-expression boundaries are destruction insertion points
- No implicit copies for move-only types
- Destructor ordering is stable
- ABI for destructors is stable across modules

---

### 220.20.10 Examples

#### 220.20.10.1 Cross‑module destruction

Module B:

```ori
struct File { fd int }
destructor File {
    if value.fd >= 0 { close_fd(value.fd) }
}
```

Module A:

```ori
func run() {
    var f File
}
```

Lowered:

```
call __ori_destruct_File(&f)
```

---

#### 220.20.10.2 Panic unwind across modules

Module A:

```ori
func run() {
    var a A
    callB()
}
```

Module B:

```ori
func callB() {
    var b B
    panic("x")
}
```

Unwind order:
```
destroy b
destroy a
```

---

#### 220.20.10.3 Return Value Optimization (RVO) eliminating destructor in callee

```ori
func make_file() File {
    return File{fd: open(...)}
}
```

Lowering:
- Construct directly in caller’s return slot
- No destructor runs inside `make_file`

Destructor runs only when the caller's value goes out of scope.

---

## 220.21 Summary

Ori’s deterministic destruction model combines:
- opt-in destructors
- strong ownership rules
- panic-free cleanup
- predictable ordering with `defer`
- predictable behavior under panic
- compiler-enforced correctness
- safe and explicit resource lifecycle semantics
- automatic, field-based destructor synthesis
- safe and explicit resource lifecycle semantics with zero-cost for trivial types
