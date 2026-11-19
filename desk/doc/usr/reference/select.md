# SELECT

The `<query>` statement provides a means to create `<relation>`s derived from persisted and/or cached `<relation>`s and/or constants. Data rows can be joined based on predicates, specific columns can be selected, and the resulting rows can be filtered by predicate.

```
[ WITH [ <common-table-expression> [ ,...n ] ] ]
<query> ::=
  [ FROM <relation> [ <as-of> ] [ [AS] <alias> ] ]
  [ { JOIN | LEFT JOIN | RIGHT JOIN | OUTER JOIN }
      <relation> [ <as-of> ] [ [AS] <alias> ]
      [ ON <predicate> ]
    | CROSS JOIN <relation> [ <as-of> ] [ [AS] <alias> ]
  ] [ ...n ]
  [ SCALARS { <name> <scalar-function> } [ ...n ]]
  [ WHERE <predicate> ]
  [ GROUP BY { <qualified-column>
               | <column-alias>
               | <column-ordinal> } [ ,...n ]
  ]
  [ HAVING <predicate> ]
  SELECT [ TOP <n> ]
    { * | { [<ship-qualifier>]<table-or-view> | <alias> }.*
        | <scalar-node> [ AS <column-alias> ]
        | <aggregate-function> [ AS <column-alias> ]
    } [ ,...n ]
  [ UNION
    | EXCEPT
    | INTERSECT
    | DIVIDED BY [ WITH REMAINDER ]
    <query>
  ] [ ,...n ]
  [ ORDER BY 
    {
      { <qualified-column> | <column-alias> | <column-ordinal> } [ ASC | DESC ]
    }  [ ,...n ]
  ]
```

```
<common-table-expression> ::= ( <query> ) [ AS ] <name>
```

```
<predicate> ::=
  { [ NOT ] <predicate> |  [ ( ] <simple-predicate> [ ) ] }
  [ { { AND | OR } [ NOT ] { <predicate> |  [ ( ] <simple-predicate> [ ) ] }
      [ ...n ]
  ]
```

```
<simple-predicate> ::=
  { expression <binary-op> expression
    | expression [ NOT ] EQUIV expression
    | expression [ NOT ] IN
        { <cte-column> | ( <value> ,...n ) }
    | expression <inequality-op> 
        { ALL | ANY} { ( <cte-column> ) | ( <value> ,...n ) }
    | expression [ NOT ] BETWEEN expression [ AND ] expression
    | [ NOT ] EXISTS { <column> | <cte-column> } }
```

```
<scalar-node> ::=
  <scalar-function>
  | <qualified-column>
  | <unqualified-column>
  | <cte-column>
  | <literal>
```

```
<column> ::=
  { <qualified-column>
    | <column-alias>
    | <literal> }
```

```
<qualified-column> ::=
[ [ <ship-qualifier> ]<table-or-view> | <alias> ].<column-name>
```

### Examples

```
SELECT 0;
```

```
FROM adoptions A
SELECT *;
```

```
FROM adoptions A
WHERE A.species = 'Cat'
SELECT A.name, A.adopter-email, A.adoption-date;
```

```
FROM persons P
JOIN staff S
SELECT P.first-name, P.last-name, P.email, S.hire-date;
```

```
FROM adoptions A
SCALARS fee-tier IF A.adoption-fee > 75 THEN 'premium' ELSE 'standard' ENDIF
WHERE A.species = 'Dog'
SELECT A.name, A.adopter-email, A.adoption-fee, fee-tier;
```

```
FROM adoptions A
WHERE YEAR(A.adoption-date) = 2024
SELECT UPPER(A.name) AS name, A.adoption-fee * 2 AS double-fee, GETUTCDATE();
```

```
WITH (FROM persons P
      JOIN staff S
      SELECT P.first-name, P.last-name, P.email, S.hire-date) AS shelter-staff
FROM shelter-staff SS
WHERE SS.hire-date > ~2018.1.1
SELECT SS.first-name, SS.last-name, SS.hire-date;
```

```
FROM adoptions A
JOIN vaccinations V
WHERE A.adoption-date BETWEEN ~2024.1.1 AND ~2024.12.31
SELECT A.name, A.species, A.adoption-date, V.vaccine, V.vaccination-time;
```

```
FROM adoptions A
JOIN vaccinations V
  ON A.name = V.name
 AND A.species = V.species
SELECT A.name, A.species, A.adoption-date, V.vaccine, V.vaccination-time;
```

```
FROM animals A
LEFT JOIN adoptions D
  ON A.name = D.name
 AND A.species = D.species
WHERE NOT EXISTS D.adopter-email
SELECT A.name, A.species;
```

### Query Arguments

**`WITH [ <common-table-expression> [ ,...n ] ]`**

The `WITH` clause makes the result `<relation>` of a `<crud-txn>` statement available to the subsequent `<crud-txn>` statements in the `WITH` clause and `<cmd>`s in the main `<crud-txn>` by `<name>`. `<crud-txn>`s in the `WITH` clause cannot have their own `WITH` clause, rather preceding CTEs within the clause are available and function as a virtual `WITH` clause.

Output column names within a CTE must be unique. When a CTE selects from a join in which both relations share a column name, the duplicates must be disambiguated with aliases (e.g. `T1.date AS cal-date, T2.date AS hol-date`). `SELECT *` on a joined CTE is valid only when the resulting column names are unique.

**`<relation> [ [AS] <alias> ]`**
Any valid `<relation>`.

`<alias>` allows short-hand reference to the `<relation>` in the `SELECT` clause and subsequent `<predicates>`. 

**`SCALARS { <name> <scalar-function> } [ ...n ]`**

Defines named computed expressions evaluated per row. Scalar names may be used in `SELECT` and `WHERE`. Appears after `FROM` and before `WHERE`. Scalar functions may also be invoked inline in `SELECT` and `WHERE` without a definition. See [SCALARS reference](scalars.md).

**`{ <qualified-column> | <column-alias> | <column-ordinal> }`**

Used to select columns for ordering and grouping. A `<column-ordinal>` is a positive integer giving the 1-based position of a column in the `SELECT` list; `*` and `<alias>.*` count as each column they expand to, in the table's column order. An ordinal of 0, or greater than the number of output columns, is an error.

**`[ TOP <n> ]`**

Selects only the first `n` rows returned by the rest of the query, in `ORDER BY` order. `n` must be 1 or greater. If the result set is less than `n`, the entire set of rows is returned.

`TOP` requires the presence of an `ORDER BY` clause. This clause must provide for a total ordering of the returned rows, i.e. every sequence of `ORDER BY` values must be unique within the returned rows. The ordering is checked against the actual rows: when two returned rows have equal `ORDER BY` values the query crashes.

`TOP` is not allowed in the last `<query>` of a set operation, because the `ORDER BY` following it orders the combined result. An earlier `<query>` of a set operation, or a CTE, may use `TOP` with its own `ORDER BY`.

**`JOIN`**
`JOIN` is an inner join returning all matching pairs of rows.

When specified without `ON <predicate>` it is a *natural join*: Obelisk joins on all columns shared between the two objects by matching name and aura type. The columns need not be primary keys. Joining on full primary key columns is most efficient (indexed); joining on a partial primary key (leading columns only — trailing-only subsets are not valid) or on non-key columns requires a scan.

When specified with `ON <predicate>` the predicate may only contain column equality conditions joined by `AND`. No other operators or `OR` conjunctions are permitted in the `ON` predicate. For more complex join conditions use `CROSS JOIN` with a `WHERE` predicate.

Cross database joins are permitted, but not cross ship joins.

`LEFT JOIN` is a left outer join returning all matching pairs of rows, along with all rows from the left `<relation>` not meeting the join condition.

`RIGHT JOIN` is a right outer join returning all matching pairs of rows, along with all rows from the right `<relation>` not meeting the join condition.

`OUTER JOIN` is a full outer join returning all matching pairs of rows, as well as all rows from both `<relation>`s not meeting the join condition.

The left `<relation>` of a join is everything joined before it. Outer joins take the same join conditions as `JOIN`: a natural join without `ON`, or `ON <predicate>` with column equality conditions joined by `AND`.

Obelisk has no nulls. A row not meeting the join condition has no columns from the `<relation>` it did not match: it is a row of a sub-type of the full joined `<row-type>`. Such a row cannot match a later join whose condition uses a missing column.

When a `FROM` clause contains an outer join, joins are performed in the order written. Otherwise `CROSS JOIN`s are performed last.

`SELECT` returns only the values that exist in a row. A selected column, `<alias>.*`, or scalar whose value does not exist in a row is omitted from that row. A row in which no selected value exists is omitted from the result.

The `<row-type>`s of a result are those the joins produce, before `WHERE`. A `<row-type>` whose rows `WHERE` removes keeps its selected columns. A selected column found in no `<row-type>` the joins produced, such as a column of a `<relation>` that matched nothing, is not part of the result. A one-table display of the result matches columns across `<row-type>`s by output name, so give selected columns of the same name from different `<relation>`s distinct names with `AS`.

`CROSS JOIN` is a cartesian join of two tables.

**`<as-of>`**
Timestamp for crud-txn of table data. Defaults to `NOW` (current time). When specified, the timestamp must be greater than both the latest database schema and content timestamps.

**`GROUP BY`**
`GROUP BY` groups the rows of the query, after `WHERE`, by the values of its columns: the query returns one row per group of rows with equal `GROUP BY` values. Each `GROUP BY` column is one of:

* `<column-alias>` -- an output column name of the `SELECT`, which may name a scalar, e.g. `SELECT YEAR(hire-date) AS hired ... GROUP BY hired`. An output name takes precedence over a source column of the same name, as for `ORDER BY`.
* `<qualified-column>` -- any column of the `FROM` relations, or a scalar of the `SCALARS` clause by name.
* `<column-ordinal>` -- the 1-based position of a `SELECT` column.

A query with `GROUP BY`, `HAVING`, or an aggregate function is grouped. Without `GROUP BY` all its rows are one group, even when there are none. Every column of the `SELECT` and `HAVING` of a grouped query must be a `GROUP BY` column or within an aggregate function; `*` and `<alias>.*` are not allowed. Scalars over `GROUP BY` columns and aggregates are allowed.

Groups are of equal values, so `.~0` and `.~-0`, or `5` and `--5` of different numeric types, group together. Rows lacking a `GROUP BY` column (from an outer join) form a group of their own, which lacks that column.

See [Aggregate Functions](aggregates.md).

**`HAVING`**
`HAVING <predicate>` filters the groups of a grouped query, as `WHERE` filters rows. Its column references must be `GROUP BY` columns or within an aggregate function, and it may use aggregates not selected.

```
FROM emp
GROUP BY dept
HAVING COUNT(*) > 2 AND MAX(pay) < 100
SELECT dept, AVG(pay);
```

**`ORDER BY`**
Orders the rows of the result. Each `ORDER BY` column is ascending unless followed by `DESC`; `ASC` is the default. Each `ORDER BY` column is one of:

* `<column-alias>` -- an output column name of the `SELECT`. An output name takes precedence over a source column of the same name.
* `<qualified-column>` -- any column of the `FROM` relations, selected or not. An unqualified column name found in more than one joined relation must be qualified.
* `<column-ordinal>` -- the 1-based position of an output column, counting the columns of `*` and `<alias>.*`. An ordinal cannot order the rows of several `<row-type>`s; order them by column name. A `<row-type>` whose rows `WHERE` removes still counts.

Rows are ordered by the aura of each column: `@t`, `@ta`, and `@tas` alphabetically ignoring case, with lower case first among otherwise equal values; `@rd`, `@rs`, `@rh`, and `@rq` as floating point numbers; signed auras (`@s...`) as signed numbers; other auras by atom value.

Obelisk has no nulls. A row lacking an `ORDER BY` column (from an outer join) sorts after all other rows ascending, and before them descending.

When the `ORDER BY` columns do not order the returned rows totally (two returned rows have equal `ORDER BY` values), the result is preceded by the message `warning: result set order is partial and non-deterministic`.

`ORDER BY` following a set operation orders the combined result and may only name output columns or ordinals.

`ORDER BY` in a CTE, or in any query prior to the last step in a `<query>` involving set operations, is ignored unless `TOP` is specified in the `SELECT` statement.

### Predicate Arguments

`NOT` negates the succeeding predicate.

`AND` performs logical *AND* on left and right predicates.

`OR` performs logical *OR* on left and right predicates.

`[ NOT ] EQUIV` is a binary operator, similar to (not) equals `<>`, `=`. However, comparing two `NOT EXISTS` yields true. `EQUIV` is true when both operands exist and are equal, or when neither exists. `NOT EQUIV` is its negation.

`[ NOT ] BETWEEN ... [ AND ]`

tests for in the range defined by the beginning expression and the ending expression. The test expression, beginning and ending expression must all be the same data type, or all numeric types, which compare by exact value (see Mixed Numeric Types in [Scalars](scalars.md#mixed-numeric-types)). Ending expression must be greater than beginning expression.

`BETWEEN` returns TRUE if the value of the test expression is greater than or equal to the value of beginning expression and less than or equal to the value of ending expression.

When applied to a column `EXISTS` tests whether the returned `<row-type>` includes the required column. In the case of `<cte-column>`, it tests whether a CTE returns any rows. `NOT EXISTS` is its negation. The column must belong to a `<relation>` of the query.

A column, or a scalar computed from one, does not exist in a row from an outer join not matching that column's `<relation>`. Any comparison (`=`, `<>`, `>`, `BETWEEN`, `IN`, and the rest, including their `NOT` forms) with an operand that does not exist is false. `NOT` negates as usual, so `NOT <column> = <value>` is true when `<column>` does not exist. Use `EXISTS` and `EQUIV` to test existence directly.

`ALL` *not implemented.*

`ANY` *not implemented.*

When applied in an equality or inequality operation `<cte-column>` must be in a CTE that returned one and only one row. A `<cte-column>` in the `SELECT` list must likewise be in a CTE that returned one and only one row, even when the query returns no rows.

```
<binary-op> ::=
  { = | <> | != | > | >= | !> | < | <= | !< | EQUIV | NOT EQUIV}
```
Whitespace is not required between operands and binary-ops, except when the left operand is a numeric literal, in which case whitespace is required.

`<inequality-op>` is any `<binary-op>` other than equality and `EQUIV`.

### Set Operations

Set operations function between the prior `<relation>` or running `<relation>` resulting from prior set operations and the `<relation>` created by the right `<query>`.

`<relation>`s may be of different types.

**UNION**

`UNION` concatenates the left and right `<relation>`s into one `<relation>` of distinct rows.

When a set query contains `UNION`, every `SELECT` participating in the set query must produce unique output column names. Selecting the same column twice, or using `AS` to produce the same output name twice, is rejected. This restriction is specific to set queries containing `UNION`; `EXCEPT` and `INTERSECT` alone do not impose it.

**EXCEPT**

`EXCEPT` returns distinct rows from the left `<relation>` that are not in the right `<relation>`. Rows that are not of the same `<row-type>` are considered not matching.

**INTERSECT**

`INTERSECT` returns distinct rows that are in both the left and right `<relation>`s. Rows that are not of the same `<row-type>` are considered not matching.

**DIVIDED BY [ WITH REMAINDER ]**

This operator performs a relational division on the left `<relation>` as the dividend and the right `<relation>` as divisor.

Divisor columns are matched to dividend columns by name and aura. The quotient columns are the dividend columns that are not divisor columns, in dividend column order. For each distinct quotient row, its *matching set* is the set of distinct divisor-column values paired with it in the dividend.

* `DIVIDED BY` is exact division (no remainder). It returns each distinct quotient row whose matching set equals the divisor: it is paired with every divisor row and with nothing else.
* `DIVIDED BY WITH REMAINDER` is Codd's division. It returns each distinct quotient row whose matching set contains every divisor row. Additional pairings (the remainder) are allowed.

Empty operands:

* An empty dividend returns an empty result.
* An empty divisor returns every distinct quotient row of the dividend for `DIVIDED BY WITH REMAINDER`, and an empty result for `DIVIDED BY`.

Row types are divided separately. Each dividend `<row-type>` is divided by each divisor `<row-type>` whose column names all occur in it, and the result is the union of those quotients. When an operand is empty, its `<row-type>` is the operand's `SELECT` output.

The quotient becomes the left `<relation>` of the next set operation.

These conditions are rejected:

* A divisor `<row-type>` has a column that is not in any dividend `<row-type>`.
* A dividend `<row-type>` contains no divisor `<row-type>`.
* A divisor column name matches a dividend column with a different aura.
* The divisor covers every dividend column, which leaves no quotient columns.
* The dividend or divisor has a duplicate output column name.

### API
```
+$  crud-txn
  $:  %crud-txn
    ctes=(list cte)
    body=crud-body
    ==

+$  cte
  $:  %cte
    name=@tas
    body=cte-body
    ==

+$  cte-body
  $%  [%query query]
      [%set-query set-query]
  ==

+$  crud-body
  $%  [%query query]
      [%set-query set-query]
      [%insert insert]
      [%upsert insert]
      [%delete delete]
      [%update update]
      [%merge merge]
  ==

+$  query
  $:  %query
    from=(unit from)
    scalars=(list scalar)
    =predicate
    group-by=(list grouping-column)
    having=predicate
    =select
    order-by=(list ordering-column)
    ==
```

### Remarks

The simplest possible query is `SELECT 0`.

Column references in `WHERE` predicates must use unqualified column names or the alias assigned in `FROM` or `JOIN`. Raw table names and fully-qualified table names are not valid in predicates. CTE column references, `SCALARS` names, and inline scalar functions are also valid in predicates, e.g. `WHERE YEAR(adoption-date) = 2024`. Scalar functions are not valid in `JOIN ... ON` predicates.

An inline scalar function in `SELECT` without `AS` produces a column named `scalar-<n>`, where `<n>` is its zero-based position in the `SELECT` list (an unaliased literal is likewise named `literal-<n>`).

`<query>` does not change the Obelisk agent state, although it may create a cached view result, which is why the Obelisk agent requires a poke and not a scry.

### Produced Metadata

message: SELECT
server-time: <timestamp>
message: <database name>.<namespace name>.<table or view name>
schema-time: <timestamp>
data-time: <timestamp>
message: <database name>.<namespace name>.<table or view name> (1st joined object, etc.)
schema-time: <timestamp>
data-time: <timestamp>
vector count: <count>

### Exceptions

(literal only crud-txn) no literal values
selected value <value> not a literal
SELECT: database {<database.query-obj>} does not exist
SELECT:  `<database>`.`<namespace>`.`<table>` does not exist at schema time `<time>`
no natural or foreign key join <object> <object>
SELECT: column {<column.sel>} must be qualified
SELECT: column `<column>` not found
