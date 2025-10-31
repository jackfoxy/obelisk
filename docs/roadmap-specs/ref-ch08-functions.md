# Functions

**IMPORTANT NOTE**: the design of functions is still on-going. Nothing is implemented in the parser and take the following as preliminary design work.

Urql has two kinds of functions.

Scalar functions take one or more columns as parameters from a single intermediary data row and return a single scalar value. Scalar functions must be declared after the `CTEs` and `FROM` clauses and before the `SELECT` clause. The user-assigned scalar name may be used in any predicate or `SELECT` clause.

Aggregate functions operate on a single column of intermediary data rows. They are always declared inline in a `SELECT` clause or `HAVING` predicate by the function name, no space, open and close parenthesis which contain parameters specific to the function including the intermediary data column.

## Boolean Functions

Boolean funtions can be Scalar or Aggregate and depending on their context must follow rules for either type.

If `<expression>` is of loobean type (%.y, %.n) normal boolean evaluation proceeds.  Evaluation of any other type evaluates as boolean TRUE unless `EXISTS <expression>` evaluates as FALSE.


```
AND ::=
  AND(<expression 1>, ..., <expression n>)
```

```
OR ::=
  OR(<expression 1>, ..., <expression n>)
```

```
XOR ::=
  XOR(<expression 1>, <expression 2>)
```

```
NOT ::=
  NOT(<expression)
```

## Scalar Functions


### arithmetic operators


```
<modulo> ::=
  <expression> % <expression>
```
Returns the integer remainder of a division.

```
<negation> ::=
  NOT <expression>
```
NOT (-4) → 4


### bitwise operators

```
<bitwise AND> ::=
  <expression> & <expression>
```
91 & 15 → 11

```
<bitwise OR> ::=
  <expression> | <expression>
```
32 | 3 → 35

```
<bitwise Exclusive OR> ::=
  <expression> # <expression>
```
17 # 5 → 20

```
<bitwise NOT> ::=
  _ <expression>
```
_ 1 → -2

```
<bitwise shift left> ::=
  <expression> << @ud
```
1 << 4 → 16

>> (Shift right)

```
<bitwise shift right> ::=
  <expression> >> @ud
```
8 >> 2 → 2

### predicate

```
<predicate> ::=
  <predicate>
```
A scalar returning a predicate follows the same construction rules as a `WHERE` predicate.

(misc scalars)
https://learn.microsoft.com/en-us/sql/odbc/reference/appendixes/appendix-e-scalar-functions?view=sql-server-ver16
https://www.postgresql.org/docs/14/functions.html

### conversion and casting

https://learn.microsoft.com/en-us/sql/odbc/reference/appendixes/explicit-data-type-conversion-function?view=sql-server-ver16
https://learn.microsoft.com/en-us/sql/odbc/reference/appendixes/sql-92-cast-function?view=sql-server-ver16
https://www.postgresql.org/docs/14/functions-formatting.html

## Aggregate Functions

`<expression>` many be a scalar function or another aggregate function.

https://learn.microsoft.com/en-us/sql/t-sql/functions/aggregate-functions-transact-sql?view=sql-server-ver16
https://www.postgresql.org/docs/15/functions-aggregate.html
