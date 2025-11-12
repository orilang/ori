# 95. Syntax Summary

This section provides a consolidated grammar overview of Ori’s core syntax using Extended Backus–Naur Form (EBNF).

---

## 95.1 Program Structure

```
Program       = PackageClause { ImportDecl | TopLevelDecl } .
PackageClause = "package" Identifier .
ImportDecl  = "import" ( ImportSpec | "(" { ImportSpec } ")" ) .
ImportSpec  = [ ImportAlias ] ImportPath .
ImportAlias = Identifier .
ImportPath  = String .
TopLevelDecl  = ConstDecl | VarDecl | FuncDecl | TypeDecl .
```

---

## 95.2 Declarations

```
ConstDecl   = "const" Identifier "=" Expression .
VarDecl     = "var" Identifier [ ":" Type ] "=" Expression .
FuncDecl    = "func" Identifier "(" [ ParameterList ] ")" [ ReturnTypes ] Block .
ReturnTypes = "(" Type { "," Type } ")" | Type .
TypeDecl    = "type" Identifier Type .
```

---

## 95.3 Statements

```
Statement =
      Block
    | IfStmt
    | ForStmt
    | SwitchStmt
    | ReturnStmt
    | BreakStmt
    | ContinueStmt
    | ExpressionStmt .

IfStmt = "if" [ SimpleStmt ";" ] Expression Block [ "else" (IfStmt | Block) ] .
SimpleStmt = VarDecl | Assignment | Expression .

ForStmt = "for" Identifier [ "," Identifier ] ":=" "range" Expression Block
        | "for" Expression Block
        | "for" [ SimpleStmt ";" ] Expression [ ";" SimpleStmt ] Block .

SwitchStmt = "switch" [ SimpleStmt ";" ] [ Expression ] "{" { CaseClause } "}" .
CaseClause = ( "case" ExpresionList | "default" ) ":" { Statement } .
ExpressionList = Expression { "," Expression } .

ReturnStmt = "return" [ ExpressionList ] .
BreakStmt = "break" .
ContinueStmt = "continue" .
Block      = "{" { Statement } "}" .
```

---

## 95.4 Expressions

```
Expression =
      UnaryExpr
    | Expression BinaryOp Expression .

UnaryExpr  = PrimaryExpr | UnaryOp UnaryExpr .
PrimaryExpr = Operand | OperandSelector | OperandIndex | OperandArguments .

BinaryOp = "+" | "-" | "*" | "/" | "%" | "==" | "!=" | "<" | "<=" | ">" | ">=" | "&&" | "||" | "&" | "|" | "^" | "<<" | ">>" .
UnaryOp  = "+" | "-" | "!" | "&" | "*" .
```

---

## 95.5 Literals

```
Literal = IntLit | FloatLit | StringLit | BoolLit | NilLit .
```

---

## 95.6 Type System

```
Type =
      Identifier
    | ArrayType
    | SliceType
    | MapType
    | StructType
    | ReturnTypes .

ArrayType   = "[" IntLit "]" Type .

SliceType   = "[" "]" Type .
SliceExpr   = Expression "[" Expression ":" Expression "]" .
MakeSlice   = "make" "(" SliceType "," Expression [ "," Expression ] ")" .
AppendExpr  = "append" "(" Expression "," Expression ")" .

MapType      = "map" "[" Type "]" Type | "hashmap" "[" Type "]" Type .
MapLiteral   = "{" [ KeyValueList ] "}" .
KeyValueList = KeyValue { "," KeyValue } .
KeyValue     = Expression ":" Expression .
MapAccess    = Expression "[" Expression "]" .
MakeMap      = "make" "(" MapType [ "," Expression ] ")" .
DeleteExpr   = "delete" "(" Expression "," Expression ")" .
CopyExpr     = "copy" "(" Expression "," Expression ")" .

StructType   = "struct" "{" { FieldDecl "," } "}" .

ReturnTypes  = "(" Type { "," Type } ")" | Type .
```

---

## 95.7 Summary Notes

- Grammar is case-sensitive.
- Whitespace and comments are ignored.
- Keywords are reserved.

---

## References
- [Lexical Elements](syntax/005_LexicalElements.md)
- [Expressions](syntax/070_Expressions.md)
- [Statements](syntax/060_Statements.md)
