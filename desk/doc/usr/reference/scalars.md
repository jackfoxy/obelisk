# SCALAR FUNCTIONS

The full syntax involves complex manipulations at the row level through scalar functions, data aggregation across preliminary rows via aggregate functions, filtering by aggregation, and row ordering.

NOTE: scalar and aggregate functions are currently under development and not available. Also, these are subject to change.

`<expression>` many be another scalar function, but not aggregate functions.

## Control Flow Functions

```
<scalar-function> ::=
  IF <predicate> THEN { <expression> | <named-scalar> }
                 ELSE { <expression> | <named-scalar> } ENDIF
  | CASE [ <expression> ]
    WHEN { <expression> | <predicate> }
	  THEN { <expression> | <named-scalar> } [ ...n ]
     [ ELSE { <expression> | <named-scalar> } ]
    END
  | COALESCE ( <expression> [ ,...n ] )
  | <arithmetic>
  | <builtin-function>
```

## CASE

`CASE` evaluates a list of conditions and returns the first matching
result. Two forms are supported:

**Simple form** — compares a single leading expression against a set of
values:

```
CASE <expression>
  WHEN <expression> THEN { <expression> | <named-scalar> } [ ...n ]
  [ ELSE { <expression> | <named-scalar> } ]
END
```

The leading `<expression>` is evaluated once. Each `WHEN` value is
compared against it in order; the first match determines the result.
`@`0 is treated as false and any other value as true (not loobean).

**Searched form** — omits the leading expression; each `WHEN` clause is
evaluated as an independent predicate:

```
CASE
  WHEN <predicate> THEN { <expression> | <named-scalar> } [ ...n ]
  [ ELSE { <expression> | <named-scalar> } ]
END
```

The expected boolean (or loobean) logic applies to each predicate. The
first branch whose predicate is true determines the result.

In both forms, `ELSE` is optional. If no `WHEN` branch matches and no
`ELSE` clause is present, the query crashes with an informative message.

(NOTE: This is preliminary design subject to change.)

## COALESCE

`COALESCE` returns the first `<expression>` in the list that exists.
Non-existence occurs when a selected `<expression>` value is not
returned due to an outer join not matching or `<scalar-query>` not
returning rows.

## Arithmetic Operations

```
<operator> ::= + | - | * | / | % | ^
<operand>  ::= <expression> | <named-scalar> 
<arithmetic> ::=
  <operand> <operator> <operand>
  | ( <arithmetic> )
  | <arithmetic> <operator> <arithmetic>
```

Arithmetic expressions support basic mathematical operations following standard mathematical precedence and associativity rules.

### Important Syntax Requirements

**Whitespace around operators:** Operators require whitespace before the next operand. For example, `1+1` is invalid, but `1+ 1` or `1 + 1` are valid.

**Float literal notation:** Floating-point literals must use Hoon notation with a leading dot. For example, `0.1` must be written as `.0.1`, and `3.14` as `.3.14`.

### Operator Precedence and Associativity

Arithmetic operators follow standard mathematical conventions for precedence and associativity:

**Precedence** (which operations group together first):
- Exponentiation (`^`) has highest precedence
- Multiplication (`*`), Division (`/`), and Modulo (`%`) have intermediate precedence
- Addition (`+`) and Subtraction (`-`) have lowest precedence

**Associativity** (how operators of equal precedence group):
- Exponentiation (`^`) is right-associative: `a ^ b ^ c` means `a ^ (b ^ c)`
- All other operators are left-associative: `a - b - c` means `(a - b) - c`

Parentheses `( )` can be used to explicitly specify grouping.

### Mixing Builtin Functions with Arithmetic

Mathematical builtin functions can be combined with arithmetic operators in the same expression. Only mathematical functions (`ABS`, `CEILING`, `DAY`, `FLOOR`, `LEN`, `LOG`, `MONTH`, `POWER`, `ROUND`, `SIGN`, `SQRT`, `YEAR`) are allowed in arithmetic expressions. String functions like `CONCAT`, `TRIM`, etc. cannot be used in arithmetic contexts.

Examples:
```
ABS(-5) + 1                           :: builtin function as operand
SQRT(4) * POWER(2, 3)                 :: multiple builtins in one expression
(ABS(-3) + FLOOR(.2.9)) * SQRT(16)   :: complex nested expression
YEAR(~2023.6.20) - MONTH(~2023.6.20)  :: datetime functions in arithmetic
```

### Examples

```
2 + 3 * 4       :: multiplication before addition: 2 + (3 * 4) = 14
(2 + 3) * 4     :: parentheses override precedence: 5 * 4 = 20
2 ^ 3 ^ 2       :: right-associative: 2 ^ (3 ^ 2) = 2 ^ 9 = 512
10 - 5 - 2      :: left-associative: (10 - 5) - 2 = 5 - 2 = 3
8 / 4 / 2       :: left-associative: (8 / 4) / 2 = 2 / 2 = 1
10 % 3          :: modulo: remainder of 10 / 3 = 1
```

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

**GETUTCDATE()** returns the current UTC date and time.

Returns: `@da`

Example:
```
SELECT GETUTCDATE()
:: returns current time, e.g., ~2024.10.27..15.30.45
```

**DAY(** `<expression>` **)** extracts the day component from a date expression.

Parameter: `@da` (date)  
Returns: `@ud` (unsigned decimal, 1-31)

Example:
```
SELECT DAY(~2024.10.27)
:: returns 27
```

**MONTH(** `<expression>` **)** extracts the month component from a date expression.

Parameter: `@da` (date)  
Returns: `@ud` (unsigned decimal, 1-12)

Example:
```
SELECT MONTH(~2024.10.27)
:: returns 10
```

**YEAR(** `<expression>` **)** extracts the year component from a date expression.

Parameter: `@da` (date)  
Returns: `@ud` (unsigned decimal)

Example:
```
SELECT YEAR(~2024.10.27)
:: returns 2024
```

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

**ABS(** `<expression>` **)** returns the absolute value of a numeric expression.

Parameter: `@sd` (signed decimal)  
Returns: `@sd` (signed decimal)

Example:
```
SELECT ABS(-42)
:: returns 42
```

**LOG(** `<expression>` [ **,** `<expression>` ] **)** returns the logarithm of the first expression. If a base is provided, computes logarithm to that base.

Parameters: `@rs` or `@ud` (float or unsigned decimal), optional `@ud` (base)  
Returns: `@rs` or `@sd` (float or signed decimal)

Examples:
```
SELECT LOG(.2.718)
:: returns natural logarithm (base e)

SELECT LOG(100, 10)
:: returns 2 (log base 10 of 100)
```

**FLOOR(** `<expression>` **)** returns the largest value less than or equal to the numeric expression.

Parameter: `@rs` (float)  
Returns: `@rs` (float)

Example:
```
SELECT FLOOR(.3.7)
:: returns .3.0
```

**POWER(** `<expression>` **,** `<expression>` **)** returns the first expression raised to the power of the second expression.

Parameters: `@rs` or `@ud` (base), `@ud` (exponent)  
Returns: `@rs` or `@ud` (same type as base)

Example:
```
SELECT POWER(2, 8)
:: returns 256
```

**CEILING(** `<expression>` **)** returns the smallest value greater than or equal to the numeric expression.

Parameter: `@rs` or `@sd` (float or signed decimal)  
Returns: `@rs` or `@sd` (same type as input)

Example:
```
SELECT CEILING(.3.2)
:: returns .4.0
```

**ROUND(** `<expression>` **,** `<expression>` [ **,** `<expression>` ] **)** rounds the first expression to the specified number of decimal places.

Parameters: `@rs` (float), `@ud` (precision), optional `@ud` (rounding function)  
Returns: `@rs` (float)

Example:
```
SELECT ROUND(.3.14159, 2)
:: returns .3.14
```

**SIGN(** `<expression>` **)** returns -1, 0, or 1 depending on whether the numeric expression is negative, zero, or positive.

Parameter: `@sd` (signed decimal)  
Returns: `@sd` (signed decimal: -1, 0, or 1)

Example:
```
SELECT SIGN(-42)
:: returns -1
```

**SQRT(** `<expression>` **)** returns the square root of the numeric expression.

Parameter: `@rs` or `@ud` (float or unsigned decimal)  
Returns: `@rs` or `@ud` (same type as input)

Example:
```
SELECT SQRT(16)
:: returns 4
```

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

**LEN(** `<expression>` **)** returns the length of a string expression.

Parameter: `@t` (cord/string)  
Returns: `@ud` (unsigned decimal)

Example:
```
SELECT LEN('hello')
:: returns 5
```

**LEFT(** `<expression>` **,** `<expression>` **)** returns the leftmost characters from a string.

Parameters: `@t` (cord/string), `@ud` (number of characters)  
Returns: `@t` (cord/string)

Example:
```
SELECT LEFT('hello', 3)
:: returns 'hel'
```

**RIGHT(** `<expression>` **,** `<expression>` **)** returns the rightmost characters from a string.

Parameters: `@t` (cord/string), `@ud` (number of characters)  
Returns: `@t` (cord/string)

Example:
```
SELECT RIGHT('hello', 3)
:: returns 'llo'
```

**SUBSTRING(** `<expression>` **,** `<expression>` **,** `<expression>` **)** returns a substring from a string.

Parameters: `@t` (cord/string), `@ud` (start position, 1-based), `@ud` (length)  
Returns: `@t` (cord/string)

Example:
```
SELECT SUBSTRING('hello world', 7, 5)
:: returns 'world'
```

**TRIM(** [ `<expression>` **,** ] `<expression>` **)** removes leading and trailing characters from a string.

Parameters: optional `@t` (characters to remove), `@t` (cord/string)  
Returns: `@t` (cord/string)

Examples:
```
SELECT TRIM('  hello  ')
:: returns 'hello' (whitespace removed by default)

SELECT TRIM('x', 'xxxhelloxxx')
:: returns 'hello'
```

**CONCAT(** `<expression>` [ **,...n** ] **)** concatenates two or more string expressions.

Parameters: `@t` (cord/string) [ **,...n** ]  
Returns: `@t` (cord/string)

Example:
```
SELECT CONCAT('hello', ' ', 'world')
:: returns 'hello world'
```

### Expression Context

```
<expression> ::=
  <column-reference>
  | <literal-value>
  | <scalar-name>
  | <builtin-function>
  | ( <expression> )
```

All builtin functions can be used wherever `<expression>` is valid, including in SELECT clauses, WHERE predicates, scalar definitions, and as parameters to other functions.


