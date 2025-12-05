# 400 Executor And Tasks – Phase 2

## 400.1 Overview

This specification defines Ori’s executor model, cooperative task behavior, cancellation signals, deadline signals, blocking‑IO rules, task groups, and error‑handling integration.

Tasks are lightweight cooperative units executed by a **single global executor**, while OS threads handle blocking IO and CPU‑heavy work.  
This spec extends `190_Concurrency.md` by formalizing executor semantics and introducing graceful shutdown and signaling mechanisms.

---

## 400.2 Executor Model

### 400.2.1 Definition

An **executor** is the single‑threaded cooperative scheduler responsible for running all tasks created via `spawn_task`.

### 400.2.2 Properties

- Exactly **one executor** exists in Ori.
- The executor runs on the OS thread that enters `main`
- All `spawn_task` invocations schedule tasks onto this executor
- The executor maintains a **run queue** of ready tasks
- Tasks run until they hit a **yield point**:
  - `yield()`
  - `Send()`
  - `Recv()`
  - `Wait()`
- Scheduling is **deterministic and cooperative**
- Tasks never migrate between threads or executors

### 400.2.3 Purpose

The executor provides:
- deterministic ordering of task execution
- a foundation for non‑blocking concurrency
- integration of cancellation and deadline signals
- enforcement of non‑blocking IO rules

The executor is **not**:
- a threadpool
- a job scheduler
- a goroutine‑like M:N runtime

It is a deterministic run‑queue for cooperative tasks.

---

## 400.3 Tasks and Threads

### 400.3.1 Tasks (`spawn_task`)

Tasks:
- run exclusively on the executor
- never block its OS thread
- must not perform blocking IO
- must reach yield points to allow scheduling
- are cooperative and deterministic

### 400.3.2 Threads (`spawn_thread`)

Threads:
- are real OS threads
- may perform blocking IO
- run concurrently with the executor
- cannot call `yield()`
- cannot create tasks (`spawn_task` forbidden inside threads)

---

## 400.4 Blocking IO Rules

### 400.4.1 Non‑blocking requirement for tasks

Tasks MUST NOT call functions that perform blocking IO.

Blocking inside a task would freeze the executor and invalidate deterministic concurrency.

### 400.4.2 Compiler Enforcement

Each stdlib function carries internal metadata:

```
isIOBlocking: bool
```

(Not visible to the user.)

Rules:
- If a function with `isIOBlocking = true` is reachable inside a `spawn_task` body → **compile‑time error**
- A function is considered blocking if it directly or transitively calls blocking OS syscalls

### 400.4.3 Allowed operations in tasks

- in‑memory operations
- metadata syscalls that do not block
- `Send`, `Recv`, `Wait`, `yield`
- pure computation that periodically yields

### 400.4.4 Blocking IO via threads

To perform blocking IO:

```
t := spawn_thread func() Result {
    return ReadFile("path")
}
value, err := t.Wait()
```

Threads safely isolate blocking operations.

---

## 400.5 Signals (Cancellation & Deadlines)

### 400.5.1 CancelSignal

```
type struct CancelSignal { /* opaque */ }

func MakeCancelSignal() CancelSignal
func (s CancelSignal) Trigger()
func (s CancelSignal) IsTriggered() bool
```

Characteristics:
- cooperative: tasks must check explicitly
- does not forcibly terminate tasks
- does not unwind stacks
- has no relationship to deadlines

### 400.5.2 DeadlineSignal

```
type struct DeadlineSignal { /* opaque */ }

func MakeDeadlineSignal(d Duration) DeadlineSignal
func (d DeadlineSignal) IsExceeded() bool
```

Characteristics:
- time‑based
- independent from cancellation
- does not auto‑trigger CancelSignal
- must be explicitly checked in task code

### 400.5.3 Signals do not imply exit

Signals are advisory:
- they never kill tasks
- they never propagate implicitly
- they must be observed cooperatively

---

## 400.6 Task Lifecycle & Graceful Shutdown

### 400.6.1 Valid termination paths

A task may terminate by:

1. returning normally
2. returning an error (including ErrCancelled or ErrDeadline)
3. reacting to signals cooperatively
4. panicking (converted into ErrPanic)

### 400.6.2 Deterministic destruction

Upon task return:
- all local variables are destroyed deterministically
- all `defer` destructors run in reverse order
- no resource leaks occur

### 400.6.3 No forced termination

Executors do not:
- kill tasks
- preempt tasks
- inject cancellations

Tasks must reach yield boundaries.

---

## 400.7 TaskGroup

### 400.7.1 Definition

A `TaskGroup` is a semantic grouping of tasks that allows waiting on all of them.  
It does **not**:
- contain its own executor
- own cancellation state
- manage deadlines
- supervise or kill tasks

### 400.7.2 API

```
type struct TaskGroup { /* opaque */ }

func MakeTaskGroup() TaskGroup
func (g TaskGroup) SpawnTask(fn func() Error)
func (g TaskGroup) Wait() Error
```

### 400.7.3 Behavior

- All group tasks run on the single executor
- `Wait()` returns:
  - `nil` if all tasks succeed
  - the first non‑nil error in spawn order
- No automatic cancellation of other tasks
- No auto‑deadline behavior

---

## 400.8 Error Model Integration

### 400.8.1 Canonical errors

```
const ErrCancelled Error
const ErrDeadline  Error
const ErrPanic     Error    // panic("x") → ErrPanic("x")
```

These are well‑known sentinel values.

### 400.8.2 Task outcomes

`Wait()` returns exactly one of:

- `nil`
- ErrCancelled
- ErrDeadline
- user‑defined error
- ErrPanic

### 400.8.3 Panic behavior

- panic terminates the task
- executor catches the panic
- panic is converted into ErrPanic
- destructors still run normally

### 400.8.4 Thread error rules

`ThreadHandler[T].Wait()` returns `(T, Error)` with identical error semantics.

---

## 400.9 Interaction With Executor Scheduling

### 400.9.1 Yield points resume executor control

A task only yields at:
- `yield()`
- `Send()`
- `Recv()`
- `Wait()`

### 400.9.2 Signals do not cause automatic yield

A task must explicitly check signals to exit.

---

## 400.10 Program Shutdown

- Tasks must complete voluntarily
- Executor shuts down only when no tasks remain
- Threads must be waited on explicitly
- No implicit cancellations occur at program end

---

## 400.11 Future Extensions (Non‑Speculative Notes)

The model intentionally leaves room for:
- custom executors
- async IO runtimes built in stdlib
- structured concurrency layers

These require no changes to the semantics defined in this file.

---

## 400.12 Summary

Ori’s executor and task model is:
- deterministic
- cooperative
- explicit
- non‑preemptive
- free from blocking IO hazards
- fully integrated with signals and deterministic destruction

It offers a clean foundation for safe, predictable concurrency.
