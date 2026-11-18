# AGGREGATE FUNCTIONS

An aggregate function computes one value from the rows of a group. Without `GROUP BY` all the rows of the query are one group; with `GROUP BY` the query returns one row per group of rows with equal `GROUP BY` values (see [GROUP BY](select.md#group-by) and [HAVING](select.md#having)).

```
<aggregate-function> ::=
    AVG ( [ ALL | DISTINCT ] <scalar-node> )
  | BOOL-AND ( [ ALL | DISTINCT ] <scalar-node> )
  | BOOL-OR ( [ ALL | DISTINCT ] <scalar-node> )
  | COUNT ( { [ ALL | DISTINCT ] <scalar-node> | * } )
  | MAX ( <scalar-node> )
  | MIN ( <scalar-node> )
  | STDEV ( [ ALL | DISTINCT ] <scalar-node> )
  | STDEVP ( [ ALL | DISTINCT ] <scalar-node> )
  | SUM ( [ ALL | DISTINCT ] <scalar-node> )
  | VAR ( [ ALL | DISTINCT ] <scalar-node> )
  | VARP ( [ ALL | DISTINCT ] <scalar-node> )
```

The argument is any scalar expression of a row: a column, a literal, a scalar, arithmetic, or a scalar function, e.g. `SUM(price * quantity)`.

`ALL` aggregates every value and is the default. `DISTINCT` aggregates each distinct value once. Values are distinct by value, so `.~0` and `.~-0`, or `5` and `--5`, are one value.

## Where aggregates are allowed

Aggregate functions are allowed only in `SELECT` and `HAVING`. There they may be the argument of a scalar function or an operand of arithmetic, e.g. `ROUND(AVG(pay), --2)` or `SUM(pay) / COUNT(*)`.

An aggregate function cannot be the argument of another aggregate function, and aggregates are not allowed in `WHERE`, `SCALARS`, `JOIN ... ON`, `GROUP BY`, `ORDER BY`, or in `INSERT`, `UPSERT`, `UPDATE`, and `DELETE`. Order by an aggregate through its output name or ordinal.

`MIN` and `MAX` with one argument are aggregate functions; with two arguments they are scalar functions.

An aggregate in `SELECT` without `AS` is named `<function>-<n>`, the lower case function name and its zero-based position in the `SELECT` list: `SELECT dept, COUNT(*)` produces the columns `dept` and `count-1`.

## Values that do not exist

Obelisk has no nulls. A row whose argument value does not exist, such as a row of an outer join that matched nothing, is not aggregated, except by `COUNT(*)`, which counts rows.

An aggregate of no values does not exist and is omitted from its row, except `COUNT`, which is `0`. This happens for a query without `GROUP BY` whose rows are all filtered out: `COUNT(*)` is `0` and `SUM` is omitted. `STDEV` and `VAR` of a single value also do not exist.

## Functions

| Function | Result | Result type |
|----------|--------|-------------|
| `AVG` | the mean of the values | the common type of the values and `@rd` |
| `BOOL-AND` | `%.y` when every value is `%.y` | `@f` |
| `BOOL-OR` | `%.y` when any value is `%.y` | `@f` |
| `COUNT(*)` | the number of rows | `@ud` |
| `COUNT` | the number of values | `@ud` |
| `MAX` | the greatest value | the type of the values |
| `MIN` | the least value | the type of the values |
| `STDEV` | the sample standard deviation | the common type of the values and `@rd` |
| `STDEVP` | the population standard deviation | the common type of the values and `@rd` |
| `SUM` | the sum of the values | the type of the values, without a bit width |
| `VAR` | the sample variance | the common type of the values and `@rd` |
| `VARP` | the population variance | the common type of the values and `@rd` |

`AVG`, `STDEV`, `STDEVP`, `VAR`, and `VARP` compute in a floating-point type: `@rd` for integers, `@rh`, `@rs`, and `@rd`, and `@rq` for `@rq` (see Mixed Numeric Types in [Scalars](scalars.md#mixed-numeric-types)). They round toward zero.

`SUM`, `AVG`, `STDEV`, `STDEVP`, `VAR`, and `VARP` require numeric values. `SUM` of a sized type, such as `@udD`, is of its unsized base, `@ud`, so a sum is never limited by the width.

`BOOL-AND` and `BOOL-OR` require loobean (`@f`) values. Like the other aggregates they skip rows lacking the value, and do not exist for a group of no values, rather than taking `%.y` or `%.n`. `DISTINCT` does not change their result.

`MIN` and `MAX` accept values of any type, ordered as `ORDER BY` orders them: text alphabetically, floating-point types as floating-point numbers, signed types as signed numbers, and other types by atom value.

Sample statistics divide by one less than the number of values; population statistics divide by the number of values. `STDEV` and `STDEVP` are the square roots of `VAR` and `VARP`.

## Examples

```
FROM emp
GROUP BY dept
HAVING COUNT(*) > 2
SELECT dept, COUNT(*) AS staff, AVG(pay), MAX(pay) - MIN(pay) AS spread
ORDER BY staff DESC;
```

```
FROM emp
SELECT COUNT(*), COUNT(DISTINCT dept), SUM(pay), ROUND(AVG(pay), --2);
```

```
FROM emp
GROUP BY dept
SELECT dept, BOOL-AND(remote) AS all-remote, BOOL-OR(remote) AS any-remote;
```

```
FROM dept D LEFT JOIN emp E ON D.dept = E.dept
GROUP BY D.dept
SELECT D.dept, COUNT(E.id) AS staff;
```

The last example counts 0 staff for a department with no employees, since `COUNT(E.id)` counts only rows that have an `E.id`.
