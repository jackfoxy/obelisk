# SELECT
*supported in urQL parser, partially supported and under development in Obelisk*

The `<query>` statement provides a means to create `<relation>`s derived from persisted and/or cached `<relation>`s and/or constants. Data rows can be joined based on predicates, specific columns can be selected, and the resulting rows can be filtered by predicate.

```
<query> ::=
  [ FROM <relation> [ <as-of> ] [ [AS] <alias> ]
    { JOIN <relation> [ <as-of> ] [ [AS] <alias> ] }
    | {
        { JOIN | LEFT JOIN | RIGHT JOIN | OUTER JOIN }
          <relation> [ <as-of> ] [ [AS] <alias> ]
          ON <predicate>
      } 
    [ ...n ]
    | CROSS JOIN <relation> [ <as-of> ] [ [AS] <alias> ]
  ]
  [ SCALARS { <name> <scalar-function> } [ ...n ]]
  [ WHERE <predicate> ]
  [ GROUP BY { <qualified-column> 
               | <column-alias> 
               | <column-ordinal> } [ ,...n ]
    [ HAVING <predicate> ]
  ]
  SELECT [ TOP <n> ]
    { * | { [<ship-qualifier>]<table-or-view> | <alias> }.*
        | <scalar-node> [ AS <column-alias> ]
    } [ ,...n ]
  [ ORDER BY 
    {
      { <qualified-column> | <column-alias> | <column-ordinal> } { ASC | DESC }
    }  [ ,...n ]
  ]
```

```
<scalar-node> ::=
  <scalar-function>
  | <qualified-column>
  | <unqualified-column>
  | <cte-column>
  | <literal>
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

`JOIN` is an inner join returning all matching pairs of rows.

When specified without `ON <predicate>` it is a *natural join*: Obelisk joins on all columns shared between the two objects by matching name and aura type. The columns need not be primary keys. Joining on full primary key columns is most efficient (indexed); joining on a partial primary key (leading columns only — trailing-only subsets are not valid) or on non-key columns requires a scan.

When specified with `ON <predicate>` the predicate may only contain column equality conditions joined by `AND`. No other operators or `OR` conjunctions are permitted in the `ON` predicate. For more complex join conditions use `CROSS JOIN` with a `WHERE` predicate.

`LEFT JOIN` is a left outer join returning all rows from the left table not meeting the join condition, along with all matching pairs of rows.

*not currently supported in Obelisk*

`RIGHT JOIN` is a right outer join returning all rows from the right table not meeting the join condition, along with all matching pairs of rows.

*not currently supported in Obelisk*

`OUTER JOIN` is a full outer join returning matching pairs of rows, as well as all rows from both tables not meeting the join condition.

*not currently supported in Obelisk*

`CROSS JOIN` is a cartesian join of two tables.

Cross database joins are permitted, but not cross ship joins.

**`<as-of>`**
Timestamp for selection of table data. Defaults to `NOW` (current time). When specified, the timestamp must be greater than both the latest database schema and content timestamps.

`HAVING <predicate>` filters aggregated rows returned from the `<query>`. The column references in the predicate must be either one of the grouping columns or be contained in an aggregate function.

*supported in urQL parser, not yet supported in Obelisk*

Avoid using `ORDER BY` in CTEs or in any query prior to the last step in a `<selection>`, unless required by `TOP` specified in the `SELECT` statement.

*GROUP BY, ORDER BY, and TOP supported in urQL parser, not yet supported in Obelisk*

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
        { <scalar-query> | ( <value> ,...n ) }
    | expression <inequality-op> 
        { ALL | ANY} { ( <scalar-query> ) | ( <value> ,...n ) }
    | expression [ NOT ] BETWEEN expression [ AND ] expression
    | [ NOT ] EXISTS { <column value> | <scalar-query> } }
```
`NOT` negates the succeeding predicate.

`AND` performs logical *AND* on left and right predicates.

`OR` performs logical *OR* on left and right predicates, takes precedence over *AND*.

`[ NOT ] EQUIV` is a binary operator, similar to (not) equals `<>`, `=`. However, comparing two `NOT EXISTS` yields true. *EQUIV will be implemented in Obelisk when outer joins are available.*

`[ NOT ] BETWEEN ... [ AND ]`

tests for in the range defined by the beginning expression and the ending expression. The test expression, beginning and ending expression must all be the same data type. Ending expression must be greater than beginning expression.

`BETWEEN` returns TRUE if the value of the test expression is greater than or equal to the value of beginning expression and less than or equal to the value of ending expression.

When applied to a column `EXISTS` tests whether the returned `<row-type>` includes the required column. In the case of `<scalar-query>`, it tests whether a CTE returns any rows. *EXISTS will be implemented in Obelisk when outer joins are available.*

`ALL` *not implemented.*

`ANY` *not implemented.*

`<scalar-query>` is a CTE that selects for one column. Depending on whether the operator expects a set or a value, it operates on the entire result set or on the first row returned, respectively.

```
<binary-op> ::=
  { = | <> | != | > | >= | !> | < | <= | !< | EQUIV | NOT EQUIV}
```
Whitespace is not required between operands and binary-ops, except when the left operand is a numeric literal, in which case whitespace is required.

`<inequality-op>` is any `<binary-op>` other than equality and `EQUIV`.

`<scalar-query>` is a CTE that returns only one column. The first returned value is accepted and subsequent values ignored. Ordering the CTE may be required for predictable results.

```
<column> ::=
  { <qualified-column>
    | <column-alias>
    | <constant> }
```

```
<qualified-column> ::=
[ [ <ship-qualifier> ]<table-or-view> | <alias> ].<column-name>
```

### API
```
+$  query
  $:
    %query
    from=(unit from)f
    scalars=(list scalar-function)
    predicate=(unit predicate)
    group-by=(list grouping-column)
    having=(unit predicate)
    selection=select
    order-by=(list ordering-column)
  ==
```

### Arguments

**`<relation> [ [AS] <alias> ]`**
Any valid `<relation>`.

`<alias>` allows short-hand reference to the `<relation>` in the `SELECT` clause and subsequent `<predicates>`. 

**`SCALARS { <name> <scalar-function> } [ ...n ]`**

Defines named computed expressions evaluated per row. Scalar names may be used in `SELECT` and `WHERE`. Appears after `FROM` and before `WHERE`. See [SCALARS reference](scalars.md).

**`{ <qualified-column> | <column-alias> | <column-ordinal> }`**

Used to select columns for ordering and grouping. `<column-ordinal>`s are 1-based.

**`[ TOP <n> ]`**

Selects only the first and/or last `n` rows returned by the rest of the query. If the result set is less than `n`, the entire set of rows is returned. 

`TOP` requires the presence of an `ORDER BY` clause. This clause must provide for a total ordering of the returned rows, i.e. every sequence of `ORDER BY` columns must be unique within the returned rows. 

### Remarks

The `SELECT` clause may choose columns from a single CTE, in which case the `FROM` clause is absent. It may also choose only literal constants and `SCALAR` functions on literals, columns, or scalar queries, in which case it will return a result set of one row.

The simplest possible query is `SELECT 0`.

Column references in `WHERE` predicates must use unqualified column names or the alias assigned in `FROM` or `JOIN`. Raw table names and fully-qualified table names are not valid in predicates. CTE column references and `SCALARS` names are also valid in predicates.

`<query>` alone does not change the Obelisk agent state.

*as-of currently missing from specification*

### Produced Metadata

message: SELECT
server-time: <timestamp>
schema-time: <timestamp>
data-time: <timestamp>
vector count: 1

...

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

(literal only selection) no literal values
selected value <value> not a literal
SELECT: database {<database.query-obj>} does not exist
SELECT:  `<database>`.`<namespace>`.`<table>` does not exist at schema time `<time>`
no natural or foreign key join <object> <object>
SELECT: column {<column.sel>} must be qualified
SELECT: column `<column>` not found
