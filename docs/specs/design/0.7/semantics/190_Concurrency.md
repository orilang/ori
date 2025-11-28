# 190. Concurrency

Ori’s concurrency model defines how tasks execute, communicate, and synchronize safely.

Key objectives:

- Deterministic behavior through **cooperative green tasks**.
- Dual execution domains: **`spawn_task`** (cooperative) and **`spawn_thread`** (OS threads).
- Strict scheduler isolation (no cross-spawning).
- Race-free concurrency via `view`, `shared`, channels, and strict memory rules.
- Predictable synchronization via `Wait()` and explicit yield points.

---

## 190.1 Overview

Ori favors:

- **Cooperative green tasks** for most concurrent work.
- **OS threads** only for CPU-heavy or blocking operations.
- Clear separation between the two domains.
- No hidden runtime or garbage collector involvement.

Concurrency is built on:

- Tasks (`spawn_task`)
- Threads (`spawn_thread`)
- Channels
- `view` and `shared` qualifiers
- Deterministic scheduling and memory rules

---

## 190.2 Cooperative Green Tasks

### 190.2.1 What Are Green Tasks?

Green tasks are lightweight user-space tasks scheduled by the Ori runtime.

They:
- run inside the cooperative scheduler
- have small stacks
- context‑switch cheaply
- never preempt each other arbitrarily
- scale to thousands of concurrent tasks

They behave like **software threads**, but with deterministic scheduling.

---

## 190.3 Cooperative Scheduling

A task yields execution only when it:
- calls `Send()`
- calls `Recv()`
- calls `Wait()`
- calls `yield()`

These are **yield points**.

Tasks are **never preempted automatically** by the runtime between yield points.

---

## 190.4 The `yield()` Keyword

`yield()` voluntarily returns control to the scheduler:

```ori
func worker() {
    for {
        do_work()
        yield()
    }
}
```

### 190.4.1 Implicit Yield Points

- `Send()`
- `Recv()`
- `Wait()`

Each suspends the current task and allows another task to run.

---

## 190.5 Why Cooperative?

| Benefit       | Explanation                                      |
|---------------|--------------------------------------------------|
| Deterministic | Task switching happens only at defined points.   |
| Lightweight   | No OS scheduling overhead.                       |
| Debuggable    | Repeatable interleavings.                        |
| Safe          | No preemption while mutating data.               |
| Simple        | No async/await or futures.                       |

---

## 190.6 Drawbacks

| Drawback                        | Mitigation                   |
|---------------------------------|------------------------------|
| A task can starve others        | Insert `yield()` in loops    |
| CPU-heavy loops block scheduler | Prefer `spawn_thread`        |
| Single-core execution per thread| Use multiple OS threads      |

---

## 190.7 Example: Cooperative Switching

```ori
func main() {
    spawn_task func() {
        for i := range int(3) {
            print("A", i)
            yield()
        }
    }

    for i := range int(3) {
        print("B", i)
        yield()
    }
}
```

Switching order is deterministic.

---

## 190.8 `spawn_task` vs `spawn_thread`

### 190.8.1 `spawn_task` — Cooperative Tasks

```ori
t TaskHandler[int] := spawn_task worker()
```

Properties:
- Scheduled by the Ori runtime
- Very cheap to create
- Yields cooperatively at well-defined points
- **Cannot spawn OS threads**
- Deterministic switching

---

### 190.8.2 `spawn_thread` — OS Threads

```ori
t ThreadHandler[int] := spawn_thread worker()
```

Properties:
- Real OS thread
- Preemptive
- **Cannot call `yield()`**
- **Cannot spawn tasks**
- Ideal for CPU-heavy or blocking code

---

### 190.8.3 Summary Table

| Category                 | `spawn_task` (cooperative)               | `spawn_thread` (OS thread)                      |
| ------------------------ | ---------------------------------------- | ----------------------------------------------- |
| Execution model          | Cooperative                              | Preemptive                                      |
| Yielding allowed?        | Yes                                      | ❌ Forbidden                                     |
| Creates OS thread?       | No                                       | Yes                                             |
| Cost                     | Very low                                 | High                                            |
| Blocking behavior        | Yields scheduler                         | Blocks kernel thread                             |
| Memory visibility        | At `Wait()`                              | At `Wait()`                                     |
| spawn_task inside?       | Yes                                      | ❌ Forbidden                                     |
| spawn_thread inside?     | ❌ Forbidden                              | Yes                                             |
| Best use case            | IO, actors, reactive                     | CPU loops, blocking FFI                         |

---

### 190.8.4 `TaskHandler[T]` and `ThreadHandler[T]`

Both are **opaque handles** to running computations.

They expose:
```ori
func (h TaskHandler[T])   Wait() (T, error)
func (h ThreadHandler[T]) Wait() (T, error)
```

- No fields
- No mutation
- No scheduler/state introspection
- No cancellation API in v0.5

---

### 190.8.5 Panic Handling Inside Tasks and Threads

Panics:
- terminate the task/thread immediately
- never propagate upward
- never crash the program,
- are captured by the runtime
- converted to an `error` returned by `.Wait()`

```ori
func job() int {
    panic("bad state")
}

t := spawn_task job()
value, err := t.Wait()   // err = "panic: bad state"
```

Panics become errors returned by `.Wait()`.

---

## 190.9 Compiler Rules

### 190.9.1 Cross-Spawning Rules

These are **forbidden** in Ori v0.5:

### ❌ A task spawning an OS thread
```ori
spawn_task func() {
    th := spawn_thread heavy()   // ERROR
}
```

### ❌ A thread spawning a task
```ori
spawn_thread func() {
    t := spawn_task job()        // ERROR
}
```

### ✔ Allowed
```ori
spawn_task worker()
spawn_task helper()

spawn_thread heavy()
spawn_thread blocking_job()
```

Each execution domain can only spawn within itself.

---

### 190.9.2 No Mutable Capture Into Tasks

**Note:**  
> When passing slices, maps, or strings into tasks:  
> – Use `view` for read‑only access  
> – Use `shared` for concurrent mutation  
> – Or pass by value for copies  
> Any other form is rejected by the compiler.

```ori
x int := 0
spawn_task func() {
    x += 1   // ❌ forbidden
}
```

### How to fix:

Use value capture:
```ori
x int := 0
spawn_task func(v int) {
    fmt.Println(v)
}(x)
```

Or use shared memory explicitly:
```ori
import "atomic"

shared count := atomic.StoreInt(0)
spawn_task func() {
    count.AddInt(1)
}
```

---

### 190.9.3 Channels

> **Note:**  
> Channels themselves never require `shared`.  
> Synchronization via `Send`/`Recv` provides all necessary visibility guarantees.

```ori
ch := make(chan int)
spawn_task producer(ch)
v := ch.Recv()
```

- Channels transfer ownership
- Operations `Send()` and `Recv()` are yield points
- Unbuffered only in v0.5

---

### 190.9.4 Ownership Transfer

```ori
ch.Send(value)   // sender loses ownership
v := ch.Recv()   // receiver gains ownership
```

---

### 190.9.5 `Wait()` Defines Memory Visibility

All writes performed by a task are guaranteed visible after `.Wait()` returns.

```ori
t := spawn_task worker()
result, err := t.Wait()
```

---

## 190.10 Scheduler Integration

Tasks yield on `Send`, `Recv`, `Wait`, `yield`.  
`spawn_thread` bypasses scheduler entirely.  
Blocking syscalls in tasks freeze the scheduler, it's forbidden.

---

## 190.11 The `select` Keyword

```ori
select {
    case msg := ch1.Recv():
        print(msg)
    case msg := ch2.Recv():
        print(msg)
    default:
        yield()
}
```

- First ready case (source order) is chosen
- `default` prevents blocking
- `Send`/`Recv` cases yield automatically

---

## 190.12 Determinism Rules

1. Switching only at yield points  
2. Deterministic `select`  
3. Synchronous channels  
4. `Wait()` = visibility boundary  
5. No preemption  

---

## 190.13 Example — Worker Pool

```ori
import "atomic"

func worker(id int, jobs chan int, results chan string) error {
    for {
        select {
            case job := jobs.Recv():
                results.Send("worker " + string(id) + " processed " + string(job))
            case default:
                yield()
        }
    }
    return nil
}

func main() {
    const num_workers int = 3
    const num_jobs int = 5

    jobs := make(chan int)
    results := make(chan string)
    shared done := atomic.StoreInt(0)

    for i := range num_workers {
        spawn_task worker(i, jobs, results)
    }

    for j := range num_jobs {
        jobs.Send(j)
    }

    for {
        select {
            case msg := results.Recv():
                print(msg)
                done.AddInt(1)
                if done.LoadInt() == num_jobs {
                    fmt.Println("All jobs done.")
                    break
                }
            case default:
                yield()
        }
    }
}
```

---

## 190.14 Channel Buffering

Only **unbuffered channels** exist.

---

## 190.15 Channel Closing

Ori permanently **forbids** `Close()` semantics.

---

## 190.16 Task Cancellation

No cancellation API for now.

---

## 190.17 Error Integration

This note specifies how the unified `Error` type is used in task handling.

### 190.17.1 Task Wait Error Semantics

Task handles expose a `Wait` method that returns the canonical `Error` type:

```ori
type struct Task {
    // internal fields not exposed here
}

func (t Task) Wait() Error {
    // Returns nil on success.
    // Returns a non-nil Error value on failure.
}
```

### 190.17.2 Rules

`Wait()` never wraps or chains errors.  
`Wait()` returns:
- `nil` if the task completed successfully, or
- a non-nil `Error` value describing the failure.

Sentinel errors (predeclared `const` Error values) may be used to signal specific task outcomes:

```ori
const ErrTaskCancelled Error = Error{
    Message: "task cancelled",
    Code:    3001,
}

err := task.Wait()
if err == ErrTaskCancelled {
    // handle cancellation
}
```

All task-related APIs that can fail must use `Error` in their signatures to stay consistent with the global error model.

---

## 190.18 Summary

| Concept | Ori Behavior |
|--------|---------------|
| Cooperative tasks | deterministic, yield‑based |
| spawn_task | creates green task |
| spawn_thread | creates OS thread |
| Strict isolation | no cross‑spawning |
| Wait() | sync + visibility boundary |
| Channels | unbuffered, synchronous |
| Shared memory | explicit only |
| yield() | voluntary scheduler hint |
| Panic behavior | captured, returned via Wait() |
