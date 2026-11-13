# Scalar functions

Named computed expressions in the optional `SCALARS` clause (after `FROM`/joins, before `WHERE` in a query; before the verb in `UPDATE`/`DELETE`). Reference scalar names in `SELECT` and `WHERE`; later scalars may reference earlier ones.

```
SCALARS { <name> <scalar-function> } [ ...n ]

<scalar-node> ::= <scalar-function> | <qualified-column> | <unqualified-column> | <cte-column> | <literal>
```

A `<cte-column>` operand requires the CTE to have returned exactly one row.

## Inline invocation

Any scalar function may also be written in place, without a `SCALARS` definition: in `SELECT` (with or without `AS`), in `WHERE` predicates of queries, `UPDATE`, and `DELETE`, in `UPDATE` `SET` values, and in `IF`/searched-`CASE` predicates (also inside `SCALARS` definitions). It behaves exactly like a `SCALARS` definition referenced by name.

```
FROM adoptions
WHERE YEAR(adoption-date) = 2024 AND LEN(name) > 3
SELECT UPPER(name) AS name, species, adoption-fee * 2;

UPDATE adoptions SET adoption-fee = adoption-fee + 5 WHERE LOWER(species) = 'cat';
```

- Inline arithmetic takes **no `END`**; it ends at the first non-operator token. `ABS(col1) + 1` is one arithmetic expression.
- Unaliased inline `SELECT` items are named `scalar-<n>` (zero-based `SELECT` position), like `literal-<n>` for literals.
- Standing alone, constants need parentheses inline: `PI()`, `E()`, `TAU()`, `PHI()`. Bare `PI` etc. only as arithmetic operands or function arguments.
- `GETUTCDATE()` is the query time everywhere; each `RAND` call is evaluated separately.
- Two-argument `MIN`/`MAX` are scalars; one-argument `MIN(col)`/`MAX(col)` are aggregates.
- **Not allowed** in `JOIN ... ON` predicates (`scalar functions are not supported in this predicate`), `INSERT`/`UPSERT` `VALUES`, `MERGE`, `GROUP BY`, `ORDER BY`.
- AST: each inline call becomes a generated scalar `inline.<i>` appended to the statement's `scalars` (after `SCALARS` definitions; `<i>` is its index in that list) and is referenced as `[%scalar-name 'inline.<i>']` / `[%selected-scalar 'inline.<i>' alias]`.

```
FROM adoptions A
SCALARS full-label CONCAT(name, ' (', species, ')')
        fee-tier IF adoption-fee > 75 THEN 'premium' ELSE 'standard' ENDIF
SELECT name, species, adoption-date, full-label, fee-tier;
```

## Control flow

```
IF <predicate> THEN <scalar-node> ELSE <scalar-node> ENDIF
CASE [ <scalar-node> ] WHEN { <scalar-node> | <predicate> } THEN <scalar-node> [ ...n ] [ ELSE <scalar-node> ] END
COALESCE ( <scalar-node> [ ,...n ] )
```

- `IF` — `ELSE` is required; `THEN`/`ELSE` must be the same type.
- `CASE` — **simple form** with a leading expression compares it to each `WHEN` value; **searched form** omits it and evaluates each `WHEN` as a predicate. First match wins. `ELSE` optional; with no match and no `ELSE` the query crashes. All `THEN`/`ELSE` must share a type.
- `COALESCE` — first existing argument. Useless until outer joins exist (no nulls otherwise).

## Arithmetic

```
<arithmetic-op> ::= + | - | * | / | % | ^
```

- Operands are `@ud`, `@sd`, or `@rd`; both sides same type, result same type. `%` (modulo) does **not** accept `@rd`.
- `/` on `@ud`/`@sd` is **integer division** and truncates toward zero: `5 / 2 END` is `2`, not `.~2.5`. Use `@rd` operands for a fractional result.
- An arithmetic scalar in the `SCALARS` clause must **terminate with `END`**: `col1 + col2 * 3 END`. Inline arithmetic has no `END`.
- Put whitespace between a numeric literal and a following operator (`1+1` fails; `1 +1`, `1 + 1` work). After a column or `)` none is needed, except `-`, which a column name absorbs.
- Whitespace required before each operand: `1+ 1` or `1 + 1`, never `1+1`.
- Precedence: `^` (highest), then `*` `/` `%`, then `+` `-`. `^` is right-associative; the rest left-associative. Parentheses override.
- Only mathematical functions and constants (below) may appear inside arithmetic — not string functions.

```
2 + 3 * 4 END            :: 14
2 ^ 3 ^ 2 END            :: 512 (right-assoc)
(ABS(--3) + FLOOR(.~2.9)) * SQRT(16) END
```

## DateTime

`GETUTCDATE()` · `YEAR(t)` · `MONTH(t)` · `DAY(t)` · `HOUR(t)` · `MINUTE(t)` · `SECOND(t)` · `ADD-TIME(t, dr)` · `SUBTRACT-TIME(t, dr)`

- `t` is `@da` or `@dr`. For a `@dr`, the component functions return whole units (`HOUR(~d1h3)` → 27). `YEAR`/`MONTH` apply to `@da`.
- `ADD-TIME`/`SUBTRACT-TIME` take a date-or-duration plus a `@dr`; result type matches the first arg.

## System

`VERSION()` — Obelisk version from `desk.docket-0` as `@t` `'<major>.<minor>.<patch>'`, fixed at desk build time.

## Mathematical

`ABS` · `LOG` (natural; crashes ≤0) · `FLOOR` · `CEILING` · `ROUND(value, length)` · `SIGN` · `SQRT` (crashes <0) · `MAX(a,b)` · `MIN(a,b)` · `RAND(low,high)` · `DEGREES` · `SIN` · `COS` · `TAN` · `ASIN` · `ACOS` · `ATAN` · `ATAN2(y,x)`

- All accept `@ud`/`@sd`/`@rd`; two-arg functions need matching types. Result type generally matches input (`LOG`/`ATAN2` return `@rd`).
- `ROUND` length: positive rounds to that many decimals; negative (`@sd` only) rounds to `10^|length|`; round-half-up toward +inf.
- `RAND(low, high)` is inclusive both ends; **the only non-deterministic `SELECT`** — emits `warning: results are non-deterministic`.

Constants (`@rd`, usable in arithmetic): `PI`, `TAU`, `E`, `PHI`.

### Float accuracy

`@rd` math is **not uniformly IEEE-754**. Two tiers:

- **Exact (jetted IEEE-754, round-nearest):** `+` `-` `*` `/`, `ABS`, `SQRT`, `FLOOR`, `CEILING`, `SIGN`, `MIN`, `MAX`, and every comparison (`=` `<` `>` `<=` `>=` in `WHERE`, plus `ORDER BY` and index ordering, which use real float ordering — not bit ordering).
- **Approximate (pure-Hoon series in `lib/math`, round-toward-zero, ~1e-15 relative tolerance):** `LOG`, `SIN`, `COS`, `TAN`, `ASIN`, `ACOS`, `ATAN`, `ATAN2`, `DEGREES`, and the `^` operator. These are not correctly rounded. Expect last-digit divergence from libm-based SQL engines, and never test their output with exact equality against a literal.

`^` is **not** a correctly-rounded `pow`. Integer exponents are repeated multiplication (error accumulates per multiply); fractional exponents are evaluated as `EXP(n * LOG(x))`. So `.~2.0 ^ .~0.5 END` and `SQRT(.~2.0)` can disagree, as can `.~2.0 ^ .~-1.0 END` and `.~1.0 / .~2.0 END`. Prefer `SQRT` over `^ .~0.5`, and division over a negative exponent.

`ROUND` on `@rd` scales by `10^length` through the approximate `^`, so rounding to many decimal places is itself inexact.

`-0.0` and `.~0.0` compare **equal** in a predicate but sort as **distinct** key values; avoid negative zero in indexed columns.

These are properties of the Urbit float libraries, not of urQL, and may change as `lib/math` gains jets.

## String

`LEN` · `LEFT(s,n)` · `RIGHT(s,n)` · `SUBSTRING(s, start [, len])` (1-based) · `LOWER` · `UPPER` · `LTRIM(s [,pat])` · `RTRIM(s [,pat])` · `TRIM(s [,pat])` · `CONCAT(s [,...n])` · `REPLACE(s, pat, repl)` · `REPLICATE(s, n)` · `REVERSE(s)` · `STRING(num)` · `STRING-CONCAT(s [,...n], delim)` · `PATINDEX(s, pat)` (1-based, 0 if absent) · `QUOTESTRING(s [, open, close])` (default `[ ]`) · `STUFF(s, start, del-count, repl)` (1-based)

- String args/returns are `@t`. `STRING` converts a number to `@t`; `LEN`/`PATINDEX` return `@ud`.
- `STRING-CONCAT`'s **last** argument is the delimiter.
