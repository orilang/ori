# 003. Grammar Index

This appendix summarizes the main grammar rules for **Ori v0.4**, collected from all syntax and semantics sections.  
Ori uses **Wirth Syntax Notation (WSN)** — an alternative to **Extended Backus–Naur Form (EBNF)** —  
chosen for its clarity, compactness, and direct correspondence with language structure.

---

## 1. Program Structure
```
Program         = { PackageDecl | ImportDecl | TopLevelDecl } .
PackageDecl     = "package" Identifier .
ImportDecl      = "import" ( String | "(" { ImportSpec } ")" ) .
ImportSpec      = [ Identifier ] String .
TopLevelDecl    = ConstDecl | VarDecl | FuncDecl | TypeDecl | StructDecl .
```

---

## 2. Declarations
```
ConstDecl       = "const" Identifier Type "=" Expression .
VarDecl         = "var" Identifier Type "=" Expression .
TypeDecl        = "type" Identifier "=" Type .
```

---

## 3. Types
```
Type            = Identifier
                | ArrayType
                | SliceType
                | MapType
                | HashMapType
                | StructType
                | ChannelType .

ArrayType       = "[" Expression "]" Type .
SliceType       = "[]" Type .
MapType         = "map" "[" Type "]" Type .
HashMapType     = "hashmap" "[" Type "]" Type .
StructType      = "struct" "{" FieldList "}" .
ChannelType     = "chan" Type .

FieldList       = { FieldDecl } .
FieldDecl       = Identifier Type .
```

---

## 4. Functions
```
FuncDecl        = "func" Identifier "(" [ ParameterList ] ")" [ ResultList ] Block .
ParameterList   = Parameter { "," Parameter } .
Parameter       = Identifier Type .
ResultList      = Type | "(" Type { "," Type } ")" .
```

---

## 5. Statements
```
Statement       = Block | IfStmt | ForStmt | SwitchStmt
                | ReturnStmt | DeferStmt | ExpressionStmt .

Block           = "{" { Statement } "}" .

IfStmt          = "if" Expression Block [ "else" Block ] .
ReturnStmt      = "return" [ ExpressionList ] .
DeferStmt       = "defer" Expression .
ExpressionStmt  = Expression .
```

---

## 6. For Statement
```
ForStmt         = "for" ( ForRange | ForLoop | ForCondition ) .
ForRange        = Identifier [ "," Identifier ] ":=" "range" Expression Block .
ForLoop         = [ SimpleStmt ";" ] Expression [ ";" SimpleStmt ] Block .
ForCondition    = Expression Block .
```

---

## 7. Switch Statement
```
SwitchStmt      = "switch" [ Expression ] "{" { CaseClause } "}" .
CaseClause      = "case" ExpressionList ":" { Statement }
                | "default" ":" { Statement } .
```

---

## 8. Expressions
```
Expression      = UnaryExpr | BinaryExpr | PrimaryExpr .
UnaryExpr       = [ UnaryOp ] PrimaryExpr .
BinaryExpr      = Expression BinaryOp Expression .
PrimaryExpr     = Operand | Selector | Index | Call | SliceExpr .
ExpressionList  = Expression { "," Expression } .

Operand         = Identifier | Literal | "(" Expression ")" .
Selector        = PrimaryExpr "." Identifier .
Index           = PrimaryExpr "[" Expression "]" .
Call            = PrimaryExpr "(" [ ExpressionList ] ")" .
SliceExpr       = PrimaryExpr "[" [ Expression ] ":" [ Expression ] "]" .
```

---

## 9. Literals
```
Literal         = IntegerLit | FloatLit | StringLit | RuneLit | BooleanLit .
```

---

## 10. Error Handling
```
TryExpr         = "try" Expression .
ErrorLiteral    = "error" "(" String ")" .
```

---

## 11. Channels
```
SendStmt        = Expression "<-" Expression .
RecvExpr        = "<-" Expression .
```

---

## 12. Grammar Notes

- Identifiers use ASCII letters, digits, and underscores; must not start with digits.  
- Capitalized identifiers are **exported**, lowercase are **internal**.  
- Implicit conversions and zero values are **not allowed**.  
- Each declaration and expression must be **fully typed**.  
- Grammar aims for **predictable parsing** and **unambiguous compilation**.

---

> Ori’s grammar is designed to be clear, deterministic, and easy to implement in a recursive descent parser.  
> There is no syntactic sugar beyond these core rules.
