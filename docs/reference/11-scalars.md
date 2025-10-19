# SCALAR FUNCTIONS

The full syntax involves complex manipulations at the row level through scalar functions, data aggregation across preliminary rows via aggregate functions, filtering by aggregation, and row ordering.

NOTE: scalar and aggregate functions are currently under development and not available. Also, these are subject to change.

## Control Flow Functions

```
<scalar-function> ::=
  IF <predicate> THEN { <expression> | <named-scalar> }
                 ELSE { <expression> | <named-scalar> } ENDIF
  | CASE <expression>
    WHEN { <expression> | <predicate> }
	  THEN { <expression> | <named-scalar> } [ ...n ]
     [ ELSE { <expression> | <named-scalar> } ]
    END
  | COALESCE ( <expression> [ ,...n ] )
  | <arithmetic>
  | <builtin-function>
```

If a `CASE` expression uses `<predicate>`, the expected boolean (or loobean) logic applies. If it uses `<expression>` `@`0 is treated as false and any other value as true (not loobean). (NOTE: This is preliminary design subject to change.)

`COALESCE` returns the first `<expression>` in the list that exists. Non-existence occurs when a selected `<expression>` value is not returned due to an outer join not matching or `<scalar-query>` not returning rows.

## Arithmetic Operations

```
<operator> ::= + | - | * | / | ^
<operand>  ::= <expression> | <named-scalar> 
<arithmetic> ::=  
    { <operand> <operator> <operand>
    | ( <operand> <operator> <operand> ) }
    [ <operator> [...n] ]
```

Arithmetic expressions support basic mathematical operations. TODO: add note on operator precedence when it's implemented in engine.

## Builtin Functions

```
<builtin-function> ::=
  <datetime-function>
  | <mathematical-function> 
  | <string-function>
```

### DateTime Functions

```
<datetime-function> ::=
  GETUTCDATE ( )
  | DAY ( <expression> )
  | MONTH ( <expression> )
  | YEAR ( <expression> )
```

**GETUTCDATE()** returns the current UTC date and time as a `@da` atom.

**DAY(** `<expression>` **)** extracts the day component from a date expression, returning an integer value from 1-31.

**MONTH(** `<expression>` **)** extracts the month component from a date expression, returning an integer value from 1-12.

**YEAR(** `<expression>` **)** extracts the year component from a date expression, returning the full year as an integer.

### Mathematical Functions

```
<mathematical-function> ::=
  ABS ( <expression> )
  | LOG ( <expression> [ , <expression> ] )
  | FLOOR ( <expression> )
  | POWER ( <expression> , <expression> )
  | CEILING ( <expression> )
  | ROUND ( <expression> , <expression> [ , <expression> ] )
  | SIGN ( <expression> )
  | SQRT ( <expression> )
```

**ABS(** `<expression>` **)** returns the absolute value of a numeric expression. Negative values become positive; positive values remain unchanged.

**LOG(** `<expression>` [ **,** `<expression>` ] **)** returns the logarithm of the first expression. If a second expression is provided, it is used as the base; otherwise, the natural logarithm (base e) is calculated.

**FLOOR(** `<expression>` **)** returns the largest integer less than or equal to the numeric expression (rounds down to the nearest integer).

**POWER(** `<expression>` **,** `<expression>` **)** returns the first expression raised to the power of the second expression (base^exponent).

**CEILING(** `<expression>` **)** returns the smallest integer greater than or equal to the numeric expression (rounds up to the nearest integer).

**ROUND(** `<expression>` **,** `<expression>` [ **,** `<expression>` ] **)** rounds the first expression to the number of decimal places specified by the second expression. The optional third expression specifies the rounding function behavior.

**SIGN(** `<expression>` **)** returns -1, 0, or 1 depending on whether the numeric expression is negative, zero, or positive.

**SQRT(** `<expression>` **)** returns the square root of the numeric expression. The expression must evaluate to a non-negative number.

### String Functions

```
<string-function> ::=
  LEN ( <expression> )
  | LEFT ( <expression> , <expression> )
  | RIGHT ( <expression> , <expression> )
  | SUBSTRING ( <expression> , <expression> , <expression> )
  | TRIM ( [ <expression> , ] <expression> )
  | CONCAT ( <expression> [ ,...n ] )
```

**LEN(** `<expression>` **)** returns the length of a string expression as an integer representing the number of characters.

**LEFT(** `<expression>` **,** `<expression>` **)** returns the leftmost characters of the first expression, with the number of characters specified by the second expression.

**RIGHT(** `<expression>` **,** `<expression>` **)** returns the rightmost characters of the first expression, with the number of characters specified by the second expression.

**SUBSTRING(** `<expression>` **,** `<expression>` **,** `<expression>` **)** returns a substring from the first expression, starting at the position specified by the second expression (1-based) and with the length specified by the third expression.

**TRIM(** [ `<expression>` **,** ] `<expression>` **)** removes leading and trailing whitespace from the string expression. If the optional first expression is provided, it specifies the characters to remove instead of whitespace.

**CONCAT(** `<expression>` [ **,...n** ] **)** concatenates two or more string expressions into a single string. All expressions are converted to strings before concatenation.

### Expression Context

```
<expression> ::=
  <column-reference>
  | <literal-value>
  | <scalar-alias>
  | <builtin-function>
  | ( <expression> )
```

All builtin functions can be used wherever `<expression>` is valid, including in SELECT clauses, WHERE predicates, scalar definitions, and as parameters to other functions.


