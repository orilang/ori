# 101. Tokens and Operators

This section defines all valid tokens and their precedence in Ori.

---

## 101.1 Token Categories

| Category | Examples |
|-----------|-----------|
| Identifiers | `name`, `User`, `GetID` |
| Keywords | `func`, `var`, `const`, `for`, `if`, `else`, `return`, `switch`, `import`, `package` |
| Literals | `42`, `"hello"`, `true`, `nil` |
| Operators | `+`, `-`, `*`, `/`, `==`, `&&` |
| Delimiters | `(` `)` `{` `}` `[` `]` `,` `;` `:` `.` |

---

## 101.2 Operators

| Category | Operators | Description |
|-----------|------------|-------------|
| Arithmetic | `+` `-` `*` `/` `%` | Addition, subtraction, multiplication, division, modulo |
| Comparison | `==` `!=` `<` `<=` `>` `>=` | Boolean comparisons |
| Logical | `&&` `\|\|` `!` | Boolean logic |
| Bitwise | `&` `\|` `^` `<<` `>>` | Bitwise operations |
| Assignment | `=`,`:=` | Assign value |
| Range (loop) | `:=` | Range iterator binding |
| Member access | `.` | Field or method access |

---

## 101.3 Operator Precedence

| Precedence | Operators | Description |
|-------------|------------|--------------|
| Highest | `()` `[]` `.` | Grouping, indexing, member access |
| 2 | `!` `-` `+` | Unary operations |
| 3 | `*` `/` `%` | Multiplicative |
| 4 | `+` `-` | Additive |
| 5 | `<<` `>>` `&` `\|` `^` | Bitwise |
| 6 | `==` `!=` `<` `<=` `>` `>=` | Comparisons |
| 7 | `&&` | Logical AND |
| 8 | `\|\|` | Logical OR |
| Lowest | `=` `:=` | Assignment and range binding |

Operators of the same precedence level associate **left to right**.

---

## 101.4 Tokens Summary

All valid tokens in Ori:

```
+  -  *  /  %  &  |  ^  <<  >>  &&  ||
== != < <= > >=
= :=
( ) [ ] { } , ; : .
```

---

## References
- [Lexical Elements](syntax/005_LexicalElements.md)
- [Expressions](syntax/070_Expressions.md)
