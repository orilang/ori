# 390. UTF-8 And Text Model

## 390.1. String Model

Ori defines `string` as a built-in primitive type representing an immutable sequence of bytes that must contain valid UTF-8.  Strings have the following properties:
- Stored as a contiguous sequence of bytes
- Immutable at the language level
- Length refers to number of bytes, not number of runes.
- Indexing (`s[i]`) returns a `uint8` byte
- UTF-8 validity is enforced at creation time (literals, builders, concatenation, file reads, etc.)

## 390.2. UTF-8 Validity
String creation functions ensure UTF-8 validity. Invalid UTF-8 can only appear via:
- Byte slicing (`s[a:b]`)
- Explicit unsafe APIs
- FFI input

Ori does *not* implicitly repair, normalize, or reinterpret invalid UTF-8.

## 390.3. Slicing Rules

Byte slicing uses:
```
s[a:b]
```

This always returns a string of bytes without checking UTF-8 boundaries. This allows creation of invalid UTF-8 strings intentionally.

Rune-aware slicing must be explicit:
```
utf8.SliceRunes(s, startRune, endRune) -> string
```

## 390.4. Rune Type

Ori defines:
```
type Rune = uint32
```

A Rune is a Unicode scalar value (`0 .. 0x10FFFF`, excluding surrogates). Conversions are explicit:
- `utf8.Encode(r Rune) []byte`
- `utf8.DecodeNext(s string, index int) (Rune, int, err)`

Surrogate code points range from `U+D800` to `U+DFFF` and must never occur in a Rune.

## 390.5. Iteration Model

Byte iteration:
```
for b := range s {
    // b is uint8
}
```

Rune iteration:
```
for r := range utf8.Runes(s) {
    // r is Rune
}
```

`utf8.Runes(s)` returns a zero-allocation iterator that decodes UTF-8 during iteration.

## 390.6. Searching and Matching

Ori does not support implicit operators like `"é" in s`.  
Explicit APIs exist:
```
utf8.Contains(s, "é")
utf8.IndexRune(s, r)
bytes.Contains(s, pattern)
```

Byte search is always allowed. Rune search requires explicit UTF-8 decoding.

## 390.7. Normalization Policy

Ori never performs Unicode normalization implicitly.

Normalization forms:
- NFC: Canonical composition
- NFD: Canonical decomposition
- NFKC / NFKD: Compatibility normalization

Future standard library packages may provide:
```
utf8.NormalizeNFC(s)
utf8.NormalizeNFD(s)
...
```
None are automatic.

## 390.8. Error Handling Semantics

Functions decoding UTF-8 return structured errors.  
Example:
```
func utf8.DecodeNext(s string, index int) (Rune, int, err) {
    ....
}
```

Invalid UTF-8 inside a string causes decoding APIs to return errors.

## 390.9. FFI Interoperability

Ori strings are not null-terminated. Conversion APIs:
```
ToCString(s: string) []byte        // appends null terminator
FromCString(ptr: *char) string     // validates UTF-8
```

Invalid UTF-8 from external sources produces an error.

## 390.10. Compile-Time Rules

The compiler validates UTF-8 for:
- string literals
- constant strings built at compile time

Any invalid literal produces a compile-time error.
