# SCALAR FUNCTIONS

Scalar functions are introduced by name (@tas) in the optional SCALARS clause following the FROM clause.

`[ SCALARS {<name> <scalar-function>} [ ...n ]]`

Scalars operate on the current row's data, as well as selected Common Table Expression data elements (see below).

Reference scalars by name in SELECT and WHERE clauses. Subsequent scalar definitions may reference prior scalars by name.

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
  | <datetime-function>
  | <mathematical-function>
  | <string-function>
```

```
<expression> ::=
  <column-reference>
  | <literal-value>
  | <scalar-name>
  | <cte-column>
  | <arithmetic>
  | <datetime-function>
  | <mathematical-function>
  | <string-function>
```

When referencing <cte-column> the Common Table Expression must have returned one and only one row, making the reference to a singleton datum.

## Control Flow Functions

### IF-THEN-ELSE

`IF` evaluates a predicate and returns one of two expressions.

```
IF <predicate> THEN { <expression> | <named-scalar> }
               ELSE { <expression> | <named-scalar> } ENDIF
```

The `ELSE` clause is required. The `THEN` and `ELSE` expressions must be the same type.

Accepted types: any, provided `THEN` and `ELSE` expressions share the same type.

Example:
```
IF col1 > 10 THEN 'high' ELSE 'low' ENDIF
:: returns 'high' when col1 > 10, 'low' otherwise
```

### CASE

`CASE` evaluates a list of conditions and returns the first matching result. Two forms are supported:

**Simple form** — compares a single leading expression against a set of values:

```
CASE <expression>
  WHEN <expression> THEN { <expression> | <named-scalar> } [ ...n ]
  [ ELSE { <expression> | <named-scalar> } ]
END
```

The leading `<expression>` is evaluated once. Each `WHEN` value is compared against it in order; the first match determines the result.

**Searched form** — omits the leading expression; each `WHEN` clause is evaluated as an independent predicate:

```
CASE
  WHEN <predicate> THEN { <expression> | <named-scalar> } [ ...n ]
  [ ELSE { <expression> | <named-scalar> } ]
END
```

The expected boolean (or loobean) logic applies to each predicate. The first branch whose predicate is true determines the result.

In both forms, `ELSE` is optional. If no `WHEN` branch matches and no `ELSE` clause is present, the query crashes with an informative message.

Accepted types: any, provided all `THEN` and `ELSE` expressions share the same type.

Examples:
```
:: simple form
CASE col1
  WHEN 1 THEN 'one'
  WHEN 2 THEN 'two'
  ELSE 'other'
END

:: searched form
CASE
  WHEN col1 > 10 THEN 'high'
  WHEN col1 > 5  THEN 'medium'
  ELSE 'low'
END
```

### COALESCE

`COALESCE` returns the first `<expression>` in the list that exists. Non-existence occurs when a selected `<expression>` value is not returned due to an outer join not matching or `<scalar-query>` not returning rows.

All expressions must share the same type.

## Arithmetic Operations

```
<operator>  ::= + | - | * | / | % | ^
<operand>   ::= <expression> | <named-scalar>
<arithmetic> ::=
  <operand> <operator> <operand>
  | ( <arithmetic> )
  | <arithmetic> <operator> <arithmetic>
  END
```

Arithmetic expressions support basic mathematical operations following standard mathematical precedence and associativity rules. Arithmetic scalars must terminate with the END keyword.

### Accepted Types

All arithmetic operators accept `@ud`, `@sd`, and `@rd`. Both operands must be the same type. The result is the same type as the inputs.

**Exception:** `%` (modulo) does not support `@rd`; it accepts only `@ud` and `@sd`.

### Important Syntax Requirements

**Whitespace around operators:** Operators require whitespace before the next operand. For example, `1+1` is invalid, but `1+ 1` or `1 + 1` are valid.

**Float literal notation:** Floating-point literals use Hoon double-precision (`@rd`) notation with a leading `~.` after the dot. For example, `0.1` must be written as `.~0.1`, and `3.14` as `.~3.14`.

### Operator Precedence and Associativity

**Precedence** (which operations group together first):
- Exponentiation (`^`) has highest precedence
- Multiplication (`*`), Division (`/`), and Modulo (`%`) have intermediate precedence
- Addition (`+`) and Subtraction (`-`) have lowest precedence

**Associativity** (how operators of equal precedence group):
- Exponentiation (`^`) is right-associative: `a ^ b ^ c` means `a ^ (b ^ c)`
- All other operators are left-associative: `a - b - c` means `(a - b) - c`

Parentheses `( )` can be used to explicitly specify grouping.

### Mixing Builtin Functions with Arithmetic

Mathematical builtin functions can be combined with arithmetic operators in the same expression. Only mathematical functions (`ABS`, `CEILING`, `DAY`, `DEGREES`, `FLOOR`, `HOUR`, `LEN`, `LOG`, `MAX`, `MIN`, `MINUTE`, `MONTH`, `ROUND`, `SECOND`, `SIGN`, `SIN`, `COS`, `TAN`, `ASIN`, `ACOS`, `ATAN`, `ATAN2`, `SQRT`, `YEAR`) and constants (`PI`, `TAU`, `E`, `PHI`) are allowed in arithmetic expressions. String functions like `CONCAT`, `TRIM`, etc. cannot be used in arithmetic contexts.

Examples:
```
ABS(-5) + 1                           :: builtin function as operand
SQRT(4) * 2 ^ 3                       :: multiple operations in one expression
(ABS(--3) + FLOOR(.~2.9)) * SQRT(16) :: complex nested expression
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

## DateTime Functions

```
<datetime-function> ::=
  GETUTCDATE ( )
  | YEAR ( <expression> )
  | MONTH ( <expression> )
  | DAY ( <expression> )
  | HOUR ( <expression> )
  | MINUTE ( <expression> )
  | SECOND ( <expression> )
  | ADD-TIME ( <expression> , <expression> )
  | SUBTRACT-TIME ( <expression> , <expression> )
```

---

**GETUTCDATE()** returns the current UTC date and time.

Returns: `@da`

Example:
```
GETUTCDATE()
:: returns current time, e.g., ~2024.10.27..15.30.45
```

---

**YEAR(** `<expression>` **)** extracts the year component from a date.

Parameter: `@da`
Returns: `@ud`

Example:
```
YEAR(~2024.10.27)
:: returns 2024
```

---

**MONTH(** `<expression>` **)** extracts the month component from a date.

Parameter: `@da`
Returns: `@ud` (1–12)

Example:
```
MONTH(~2024.10.27)
:: returns 10
```

---

**DAY(** `<expression>` **)** extracts the day of the month from a date, or the number of whole days from a duration.

Parameter: `@da` or `@dr`
Returns: `@ud`

Examples:
```
DAY(~2024.10.27)
:: returns 27

DAY(~d5)
:: returns 5 (5-day duration)
```

---

**HOUR(** `<expression>` **)** extracts the hour component from a date (0–23), or the number of whole hours from a duration.

Parameter: `@da` or `@dr`
Returns: `@ud`

Examples:
```
HOUR(~2024.10.27..15.30.45)
:: returns 15

HOUR(~h3)
:: returns 3 (3-hour duration)

HOUR(~d1h3)
:: returns 27 (1-day 3-hour duration: 24 + 3)
```

---

**MINUTE(** `<expression>` **)** extracts the minute component from a date (0–59), or the number of whole minutes from a duration.

Parameter: `@da` or `@dr`
Returns: `@ud`

Examples:
```
MINUTE(~2024.10.27..15.30.45)
:: returns 30

MINUTE(~m45)
:: returns 45 (45-minute duration)

MINUTE(~h1m30)
:: returns 90 (1-hour 30-minute duration: 60 + 30)
```

---

**SECOND(** `<expression>` **)** extracts the second component from a date (0–59), or the number of whole seconds from a duration.

Parameter: `@da` or `@dr`
Returns: `@ud`

Examples:
```
SECOND(~2024.10.27..15.30.45)
:: returns 45

SECOND(~s30)
:: returns 30 (30-second duration)

SECOND(~m1s45)
:: returns 105 (1-minute 45-second duration: 60 + 45)
```

---

**ADD-TIME(** `<expression>` **,** `<expression>` **)** adds a duration to a date or duration.

Parameters: `@da` or `@dr` (time expression), `@dr` (duration to add)
Returns: same type as first parameter

Examples:
```
ADD-TIME(~2024.10.27, ~d1)
:: returns ~2024.10.28

ADD-TIME(~d5, ~d3)
:: returns ~d8
```

---

**SUBTRACT-TIME(** `<expression>` **,** `<expression>` **)** subtracts a duration from a date or duration.

Parameters: `@da` or `@dr` (time expression), `@dr` (duration to subtract)
Returns: same type as first parameter

Examples:
```
SUBTRACT-TIME(~2024.10.27, ~d1)
:: returns ~2024.10.26

SUBTRACT-TIME(~d10, ~d3)
:: returns ~d7
```

---

## Mathematical Functions

```
<mathematical-function> ::=
  ABS ( <expression> )
  | LOG ( <expression> )
  | FLOOR ( <expression> )
  | CEILING ( <expression> )
  | ROUND ( <expression> , <expression> )
  | SIGN ( <expression> )
  | SQRT ( <expression> )
  | MAX ( <expression> , <expression> )
  | MIN ( <expression> , <expression> )
  | DEGREES ( <expression> )
  | SIN ( <expression> )
  | COS ( <expression> )
  | TAN ( <expression> )
  | ASIN ( <expression> )
  | ACOS ( <expression> )
  | ATAN ( <expression> )
  | ATAN2 ( <expression> , <expression> )
  | PI
  | TAU
  | E
  | PHI
```

---

**ABS(** `<expression>` **)** returns the absolute value of a numeric expression.

Parameter: `@ud`, `@sd`, or `@rd`
Returns: same type as input

Examples:
```
ABS(-42)      :: @sd → returns --42
ABS(.~-3.7)   :: @rd → returns .~3.7
ABS(5)        :: @ud → returns 5
```

---

**LOG(** `<expression>` **)** returns the natural logarithm (base *e*) of a numeric expression. Crashes on zero or negative input.

Parameter: `@ud`, `@sd`, or `@rd`
Returns: `@rd`

Examples:
```
LOG(.~1.0)
:: returns .~0.0

LOG(.~2.718281828)
:: returns approximately .~1.0

LOG(1)
:: returns .~0.0 (@ud input converted to @rd)
```

---

**FLOOR(** `<expression>` **)** returns the largest integer value less than or equal to the expression. For `@sd` and `@ud` inputs (which have no fractional part), returns the value unchanged.

Parameter: `@ud`, `@sd`, or `@rd`
Returns: same type as input

Examples:
```
FLOOR(.~3.7)   :: returns .~3.0
FLOOR(.~-1.5)  :: returns .~-2.0
FLOOR(5)       :: @ud → returns 5
```

---

**CEILING(** `<expression>` **)** returns the smallest integer value greater than or equal to the expression. For `@sd` and `@ud` inputs, returns the value unchanged.

Parameter: `@ud`, `@sd`, or `@rd`
Returns: same type as input

Examples:
```
CEILING(.~3.2)  :: returns .~4.0
CEILING(.~-1.5) :: returns .~-1.0
CEILING(5)      :: @ud → returns 5
```

---

**ROUND(** `<expression>` **,** `<expression>` **)** rounds a numeric value. Uses round-half-up (ties round toward +infinity).

Parameters: `@ud`, `@sd`, or `@rd` (value); `@ud` or `@sd` (length)
Returns: same type as first parameter

The `length` parameter controls rounding position:
- **Positive length** (or `@ud`): rounds to that many decimal places. For `@sd` and `@ud` inputs this is a no-op since they have no fractional part.
- **Negative length** (`@sd` only): rounds to the nearest 10^|length| before the decimal point.

Examples:
```
ROUND(.~1.456, 2)    :: returns .~1.46
ROUND(.~1.5, 0)      :: returns .~2.0  (half rounds up)
ROUND(.~-1.5, 0)     :: returns .~-1.0 (toward +infinity)
ROUND(.~123.4, -1)   :: rounds to nearest 10 → .~120.0
ROUND(.~1200.0, -2)  :: rounds to nearest 100 → .~1200.0
ROUND(1235, -1)      :: @ud, rounds to nearest 10 → 1240
ROUND(--1235, -1)    :: @sd, rounds to nearest 10 → --1240
```

---

**SIGN(** `<expression>` **)** returns -1, 0, or 1 depending on the sign of the expression.

Parameter: `@ud`, `@sd`, or `@rd`
Returns: same type as input

Examples:
```
SIGN(.~-3.7)  :: @rd → returns .~-1.0
SIGN(.~0.0)   :: @rd → returns .~0.0
SIGN(.~2.5)   :: @rd → returns .~1.0
SIGN(-7)      :: @sd → returns -1
SIGN(--0)     :: @sd → returns --0
SIGN(5)       :: @ud → returns 1
SIGN(0)       :: @ud → returns 0
```

---

**SQRT(** `<expression>` **)** returns the square root of a numeric expression. Crashes on negative input.

Parameter: `@ud`, `@sd`, or `@rd`
Returns: same type as input

Examples:
```
SQRT(.~16.0)  :: @rd → returns .~4.0
SQRT(16)      :: @ud → returns 4
SQRT(--9)     :: @sd → returns --3
```

---

**MAX(** `<expression>` **,** `<expression>` **)** returns the larger of two numeric values. Both arguments must be the same type.

Parameter: `@ud`, `@sd`, or `@rd` (both must match)
Returns: same type as inputs

Examples:
```
MAX(3, 5)           :: @ud → returns 5
MAX(.~3.5, .~2.1)   :: @rd → returns .~3.5
MAX(--10, -5)       :: @sd → returns --10
```

---

**MIN(** `<expression>` **,** `<expression>` **)** returns the smaller of two numeric values. Both arguments must be the same type.

Parameter: `@ud`, `@sd`, or `@rd` (both must match)
Returns: same type as inputs

Examples:
```
MIN(3, 5)           :: @ud → returns 3
MIN(.~3.5, .~2.1)   :: @rd → returns .~2.1
MIN(--10, -5)       :: @sd → returns -5
```

---

**DEGREES(** `<expression>` **)** converts radians to degrees.

Parameter: `@ud`, `@sd`, or `@rd`
Returns: same type as input

Examples:
```
DEGREES(PI)          :: returns 180 (@ud)
DEGREES(.~3.14159)   :: returns approximately .~180.0
```

---

**SIN(** `<expression>` **)** returns the sine of an angle in radians.

Parameter: `@ud`, `@sd`, or `@rd`
Returns: same type as input

Examples:
```
SIN(.~0.0)       :: returns .~0.0
SIN(PI / 2)      :: @ud → returns 1
```

---

**COS(** `<expression>` **)** returns the cosine of an angle in radians.

Parameter: `@ud`, `@sd`, or `@rd`
Returns: same type as input

Examples:
```
COS(.~0.0)    :: returns .~1.0
COS(PI)       :: @ud → returns -1 (as @sd)
```

---

**TAN(** `<expression>` **)** returns the tangent of an angle in radians.

Parameter: `@ud`, `@sd`, or `@rd`
Returns: same type as input

Example:
```
TAN(.~0.0)    :: returns .~0.0
```

---

**ASIN(** `<expression>` **)** returns the arcsine of a value, in radians. Input must be in the range [-1, 1].

Parameter: `@ud`, `@sd`, or `@rd`
Returns: same type as input

Example:
```
ASIN(.~1.0)    :: returns approximately .~1.5707963 (π/2)
```

---

**ACOS(** `<expression>` **)** returns the arccosine of a value, in radians. Input must be in the range [-1, 1].

Parameter: `@ud`, `@sd`, or `@rd`
Returns: same type as input

Example:
```
ACOS(.~1.0)    :: returns .~0.0
```

---

**ATAN(** `<expression>` **)** returns the arctangent of a value, in radians.

Parameter: `@ud`, `@sd`, or `@rd`
Returns: same type as input

Example:
```
ATAN(.~1.0)    :: returns approximately .~0.7853982 (π/4)
```

---

**ATAN2(** `<expression>` **,** `<expression>` **)** returns the angle (in radians) whose tangent is the quotient of the two arguments. The first argument is the y-coordinate and the second is the x-coordinate. Both must be the same numeric type.

Parameters: `@ud`, `@sd`, or `@rd` (y); same type (x)
Returns: `@rd`

Example:
```
ATAN2(.~1.0, .~1.0)    :: returns approximately .~0.7853982 (π/4)
```

---

### Constants

The following constants are available as zero-argument expressions and can be used directly in arithmetic:

| Constant | Value | Type |
|----------|-------|------|
| `PI`  | `3.141592653589793`  | `@rd` |
| `TAU` | `6.283185307179586`  | `@rd` |
| `E`   | `2.718281828459045`  | `@rd` |
| `PHI` | `1.618033988749895`  | `@rd` |

Examples:
```
PI                  :: returns .~3.141592653589793
TAU / 2             :: returns PI
E ^ .~2.0           :: returns approximately .~7.389056
DEGREES(TAU)        :: returns 360 (as @ud)
```

---

### String Functions

```
<string-function> ::=
  LEN ( <expression> )
  | LEFT ( <expression> , <expression> )
  | RIGHT ( <expression> , <expression> )
  | SUBSTRING ( <expression> , <expression> [ , <expression> ] )
  | LOWER ( <expression> )
  | UPPER ( <expression> )
  | LTRIM ( <expression> [ , <expression> ] )
  | RTRIM ( <expression> [ , <expression> ] )
  | TRIM ( <expression> [ , <expression> ] )
  | CONCAT ( <expression> [ ,...n ] )
  | REPLACE ( <expression> , <expression> , <expression> )
  | REPLICATE ( <expression> , <expression> )
  | REVERSE ( <expression> )
  | STRING ( <expression> )
  | STRING-CONCAT ( <expression> [ ,...n ] , <expression> )
  | PATINDEX ( <expression> , <expression> )
  | QUOTESTRING ( <expression> [ , <expression> , <expression> ] )
  | STUFF ( <expression> , <expression> , <expression> , <expression> )
```

---

**LEN(** `<expression>` **)** returns the number of characters in a string.

Parameter: `@t`
Returns: `@ud`

Example:
```
LEN('hello')
:: returns 5
```

---

**LEFT(** `<expression>` **,** `<expression>` **)** returns the leftmost N characters from a string.

Parameters: `@t` (string), `@ud` (number of characters)
Returns: `@t`

Example:
```
LEFT('hello', 3)
:: returns 'hel'
```

---

**RIGHT(** `<expression>` **,** `<expression>` **)** returns the rightmost N characters from a string. If N is greater than or equal to the string length, the entire string is returned.

Parameters: `@t` (string), `@ud` (number of characters)
Returns: `@t`

Example:
```
RIGHT('hello', 3)
:: returns 'llo'
```

---

**SUBSTRING(** `<expression>` **,** `<expression>` [ **,** `<expression>` ] **)** returns a substring. Position is 1-based.

Parameters: `@t` (string), `@ud` (start position, 1-based), optional `@ud` (length)
Returns: `@t`

Examples:
```
SUBSTRING('hello world', 7, 5)
:: returns 'world'

SUBSTRING('hello world', 7)
:: returns 'world' (no length: returns from start to end)
```

---

**LOWER(** `<expression>` **)** converts all uppercase characters to lowercase.

Parameter: `@t`
Returns: `@t`

Example:
```
LOWER('Hello World')
:: returns 'hello world'
```

---

**UPPER(** `<expression>` **)** converts all lowercase characters to uppercase.

Parameter: `@t`
Returns: `@t`

Example:
```
UPPER('hello world')
:: returns 'HELLO WORLD'
```

---

**LTRIM(** `<expression>` [ **,** `<expression>` ] **)** removes leading characters from a string.

Parameters: `@t` (string), optional `@t` (pattern to remove)
Returns: `@t`

Without a pattern, removes leading whitespace (spaces, tabs, carriage returns). With a pattern, removes all leading occurrences of that pattern string.

Examples:
```
LTRIM('  hello  ')
:: returns 'hello  ' (leading whitespace removed)

LTRIM('xxxhello', 'x')
:: returns 'hello'
```

---

**RTRIM(** `<expression>` [ **,** `<expression>` ] **)** removes trailing characters from a string.

Parameters: `@t` (string), optional `@t` (pattern to remove)
Returns: `@t`

Without a pattern, removes trailing whitespace. With a pattern, removes all trailing occurrences of that pattern string.

Examples:
```
RTRIM('  hello  ')
:: returns '  hello' (trailing whitespace removed)

RTRIM('helloyyy', 'y')
:: returns 'hello'
```

---

**TRIM(** `<expression>` [ **,** `<expression>` ] **)** removes leading and trailing characters from a string.

Parameters: `@t` (string), optional `@t` (pattern to remove)
Returns: `@t`

Without a pattern, removes leading and trailing whitespace. With a pattern, removes all leading and trailing occurrences of that pattern string.

Examples:
```
TRIM('  hello  ')
:: returns 'hello'

TRIM('xxxhelloxxx', 'x')
:: returns 'hello'
```

---

**CONCAT(** `<expression>` [ **,...n** ] **)** concatenates two or more string expressions.

Parameters: `@t` [ ,...n ]
Returns: `@t`

Example:
```
CONCAT('hello', ' ', 'world')
:: returns 'hello world'
```

---

**REPLACE(** `<expression>` **,** `<expression>` **,** `<expression>` **)** replaces all occurrences of a pattern within a string.

Parameters: `@t` (string), `@t` (pattern), `@t` (replacement)
Returns: `@t`

Example:
```
REPLACE('hello world', 'l', 'L')
:: returns 'heLLo worLd'
```

---

**REPLICATE(** `<expression>` **,** `<expression>` **)** repeats a string N times.

Parameters: `@t` (string), `@ud` (count)
Returns: `@t`

Example:
```
REPLICATE('ab', 3)
:: returns 'ababab'
```

---

**REVERSE(** `<expression>` **)** reverses the characters in a string.

Parameter: `@t`
Returns: `@t`

Example:
```
REVERSE('hello')
:: returns 'olleh'
```

---

**STRING(** `<expression>` **)** converts a numeric value to its string representation.

Parameter: `@ud`, `@sd`, or `@rd`
Returns: `@t`

Examples:
```
STRING(42)
:: returns '42'

STRING(--42)
:: returns '--42'

STRING(.~42.42)
:: returns '.~42.42'
```

---

**STRING-CONCAT(** `<expression>` [ **,...n** ] **,** `<expression>` **)** joins strings with a delimiter. The final argument is the delimiter; all preceding arguments are the strings to join.

Parameters: `@t` [ ,...n ] (strings), `@t` (delimiter)
Returns: `@t`

Example:
```
STRING-CONCAT('hello', 'world', ', ')
:: returns 'hello, world'
```

---

**PATINDEX(** `<expression>` **,** `<expression>` **)** returns the 1-based starting position of the first occurrence of a pattern within a string, or 0 if not found.

Parameters: `@t` (string), `@t` (pattern)
Returns: `@ud`

Examples:
```
PATINDEX('hello world', 'world')
:: returns 7

PATINDEX('hello', 'xyz')
:: returns 0
```

---

**QUOTESTRING(** `<expression>` [ **,** `<expression>` **,** `<expression>` ] **)** wraps a string in delimiter characters.

Parameters: `@t` (string), optional `@t` (open delimiter), optional `@t` (close delimiter)
Returns: `@t`

Without delimiters, wraps in `[` and `]` by default. With delimiters, both open and close must be provided.

Examples:
```
QUOTESTRING('hello')
:: returns '[hello]'

QUOTESTRING('hello', '<', '>')
:: returns '<hello>'
```

---

**STUFF(** `<expression>` **,** `<expression>` **,** `<expression>` **,** `<expression>` **)** deletes a portion of a string and inserts a replacement at that position. Position is 1-based.

Parameters: `@t` (string), `@ud` (start position, 1-based), `@ud` (number of characters to delete), `@t` (replacement string)
Returns: `@t`

Examples:
```
STUFF('hello world', 7, 5, 'there')
:: returns 'hello there'

STUFF('hello', 2, 3, 'ELL')
:: returns 'hELLo'
```

---
