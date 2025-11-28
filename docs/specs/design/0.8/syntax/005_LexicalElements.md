# 5. Lexical Elements

This section defines the lexical structure of Ori source code — the lowest level of syntax recognized by the tokenizer.

---

## 5.1 Character Set

Ori source files are encoded in **UTF-8**.  
All identifiers, string literals, and comments use Unicode characters.

Line endings may be either `LF` or `CRLF` and are treated equivalently.

---

## 5.2 Whitespace

Whitespace characters (space, tab, newline, carriage return) are ignored except when separating tokens.

---

## 5.3 Tokens

Tokens are the basic lexical units of Ori source code. They are classified as:

| Category | Examples |
|-----------|-----------|
| Identifiers | `main`, `userName`, `fmt` |
| Keywords | `func`, `var`, `if`, `for` |
| Operators | `+`, `-`, `==`, `&&` |
| Delimiters | `(`, `)`, `{`, `}`, `,`, `;` |
| Literals | `42`, `"hello"`, `true` |

Tokens are separated by whitespace, comments, or delimiters.

---

## 5.4 Identifiers

Identifiers name program entities such as variables, functions, and types.

### Rules
- Must begin with a letter (`A–Z`, `a–z`).
- May contain ASCII letters, digits, and underscores (`_`).
- Cannot start with a digit.
- Case-sensitive.

### Examples

```ori
var userName = "Alice"
func GetUser(id int) User
```

Names beginning with an uppercase letter are **exported** (visible across packages).

---

## 5.5 Keywords

The following words are reserved and cannot be used as identifiers:

```
package import var const func type struct if else for switch return break continue true false nil interface destructor comptime comptime_error extern void module package type
```

---

## 5.6 Operators and Delimiters

See: [Tokens and Operators](syntax/101_TokensAndOperators.md)

---

## 5.7 Comments

Comments are treated as whitespace and ignored by the compiler.

See: [Comments](syntax/100_Comments.md)
