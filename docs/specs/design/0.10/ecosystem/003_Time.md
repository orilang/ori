# 003. Time Package

The `time` package provides Ori's minimal, explicit, deterministic `time API`.  
It exposes only the primitives required for measuring durations, obtaining timestamps, and sleeping.  
It does not include calendars, time zones, parsing, formatting, timers, tickers, schedulers, or any implicit task creation.  
This file defines the complete `Time API`.

---

## 003.1 Goals

- Provide a simple and explicit wall-clock timestamp (`Time`).
- Provide a monotonic timestamp for duration measurement.
- Represent durations with an integer nanosecond type.
- Offer basic utilities (`Now`, `MonotonicNow`, `Sleep`, `Since`, `SinceMonotonic`).
- Avoid all hidden behavior:
  - no suffix-based literals (`500ms`, `1s`)
  - no background threads
  - no timers or tickers
  - no attribute-based magic
- All time arithmetic is explicit and uses normal operations.

These goals match the high-level foundations of the standard library.

---

## 003.2 Types

### 003.2.1 Duration

```
type Duration int64
```

`Duration` represents a span of time in **nanoseconds**.

A helper constructor converts integer nanoseconds into a Duration:
```
func duration(n int64) Duration {
    return Duration(n)
}
```

Arithmetic on `Duration` uses the normal operators: `+`, `-`, `%`, `*`, `/`,
comparisons, etc.

---

### 003.2.2 Time

```
type Time struct {
    unixNano int64   // wall-clock timestamp, nanoseconds since Unix epoch
}
```

Properties:
- Immutable value
- Represents wall-clock time in UTC
- Its internal representation is opaque; users interact with it only through the API.

---

## 003.3 Duration Constants

```
const Nanosecond  Duration = duration(1)
const Microsecond Duration = duration(1_000)
const Millisecond Duration = duration(1_000_000)
const Second      Duration = duration(1_000_000_000)
const Minute      Duration = 60 * Second
const Hour        Duration = 60 * Minute
```

These constants enable ergonomic and explicit duration expressions.

---

## 003.4 Functions

### 003.4.1 Now

```
func Now() Time
```

Returns the current **wall-clock** system time.

---

### 003.4.2 MonotonicNow

```
func MonotonicNow() Duration
```

Returns a **monotonic timestamp** measured in nanoseconds.

---

### 003.4.3 Sleep

```
func Sleep(d Duration)
```

Blocks the current task for at least `d` nanoseconds.

---

### 003.4.4 Since (wall-clock)

```
func Since(t Time) Duration
```

Returns the elapsed duration between `Now()` and a prior wall-clock `Time`.

---

### 003.4.5 SinceMonotonic (monotonic)

```
func SinceMonotonic(start Duration) Duration
```

Returns the elapsed monotonic duration.

---

## 003.5 Usage Examples

```
time.Sleep(500 * time.Millisecond)

start := time.Now()
elapsed := time.Since(start)

start2 := time.MonotonicNow()
elapsed2 := time.SinceMonotonic(start2)
```

---

## 003.6 Exclusions in current version

- No `time.After`
- No `time.Ticker`
- No clocks with timezone or calendar logic
- No parsing or formatting
- No deadline or cancellation APIs

---

## 003.7 Summary

The `time` package provides:
- A minimal but complete `Duration` type.
- A simple `Time` type for wall-clock timestamps.
- Monotonic and wall-clock time sources.
- Elapsed-time helpers (`Since`, `SinceMonotonic`).
- Explicit duration arithmetic via exported constants.
- A predictable `Sleep` function consistent with Ori’s concurrency model.
