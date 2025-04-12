# SELECT
*supported in urQL parser, partially supported and under development in Obelisk*

The `<query>` command provides a means to create `<table-set>`s derived from persisted and/or cached `<table-set>`s and/or constants. Data rows can be joined based on predicates, specific columns can be selected, and the resulting rows can be filtered by predicate.

```
<query> ::=
  [ FROM <table-set> [ <as-of-time> ] [ [AS] <alias> ]
    { JOIN <table-set> [ <as-of-time> ] [ [AS] <alias> ] }
    | {
        { JOIN | LEFT JOIN | RIGHT JOIN | OUTER JOIN }
          <table-set> [ <as-of-time> ] [ [AS] <alias> ]
          ON <predicate>
      } 
    [ ...n ]
    | CROSS JOIN <table-set> [ <as-of-time> ] [ [AS] <alias> ]
  ]
  [ WHERE <predicate> ]
  [ GROUP BY { <qualified-column> 
               | <column-alias> 
               | <column-ordinal> } [ ,...n ]
    [ HAVING <predicate> ]
  ]
  SELECT [ TOP <n> ] [ BOTTOM <n> ]
    { * | { [<ship-qualifier>]<table-view> | <alias> }.*
        | <expression> [ AS <column-alias> ]
    } [ ,...n ]
  [ ORDER BY 
    {
      { <qualified-column> | <column-alias> | <column-ordinal> } { ASC | DESC }
    }  [ ,...n ]
  ]
```
`JOIN` is an inner join returning all matching pairs of rows. When specified without `ON <predicate>` it specifies a natural join, indicating the join is performed on matching primary keys. All columns in the keys must match on column name, aura type, and sequence. `ASC | DESC` for the key columns does not have to match

*natural join is the only inner join currently supported in Obelisk*

`LEFT JOIN` is a left outer join returning all rows from the left table not meeting the join condition, along with all matching pairs of rows.

*not currently supported in Obelisk*

`RIGHT JOIN` is a right outer join returning all rows from the right table not meeting the join condition, along with all matching pairs of rows.

*not currently supported in Obelisk*

`OUTER JOIN` is a full outer join returning matching pairs of rows, as well as all rows from both tables not meeting the join condition.

*not currently supported in Obelisk*

`CROSS JOIN` is a cartesian join of two tables.

Cross database joins are permitted, but not cross ship joins.

**`<as-of-time>`**
Timestamp for selection of table data. Defaults to `NOW` (current time). When specified, the timestamp must be greater than both the latest database schema and content timestamps.

`HAVING <predicate>` filters aggregated rows returned from the `<query>`. The column references in the predicate must be either one of the grouping columns or be contained in an aggregate function.

*supported in urQL parser, not yet supported in Obelisk*

Avoid using `ORDER BY` in CTEs or in any query prior to the last step in a `<selection>`, unless required by `TOP` or `BOTTOM` specified in the `SELECT` statement.

*GROUP BY, ORDER BY, TOP, and BOTTOM supported in urQL parser, not yet supported in Obelisk*

```
<predicate> ::=
  { [ NOT ] <predicate> |  [ ( ] <simple-predicate> [ ) ] }
  [ { { AND | OR } [ NOT ] { <predicate> |  [ ( ] <simple-predicate> [ ) ] }
      [ ...n ]
  ]
```

```
<simple-predicate> ::=
  { expression <binary-operator> expression
    | expression [ NOT ] EQUIV expression
    | expression [ NOT ] IN
        { <scalar-query> | ( <value> ,...n ) }
    | expression <inequality-operator> 
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
<binary-operator> ::=
  { = | <> | != | > | >= | !> | < | <= | !< | EQUIV | NOT EQUIV}
```
Whitespace is not required between operands and binary-operators, except when the left operand is a numeric literal, in which case whitespace is required.

`<inequality-operator>` is any `<binary-operator>` other than equality and `EQUIV`.

```
<expression> ::=
  { <qualified-column>
    | <constant>
    | <scalar>
	  | <scalar-query>
    | <aggregate-function>( { <column> | <scalar> } )
  }
```
*<aggregate-function> is not yet implemente in the urQL parser*
`<scalar-query>` is a CTE that returns only one column. The first returned value is accepted and subsequent values ignored. Ordering the CTE may be required for predictable results.

```
<column> ::=
  { <qualified-column>
    | <column-alias>
    | <constant> }
```

```
<qualified-column> ::=
[ [ <ship-qualifier> ]<table-view> | <alias> ].<column-name>
```

### API
```
+$  query
  $:
    %query
    from=(unit from)
    scalars=(list scalar-function)
    predicate=(unit predicate)
    group-by=(list grouping-column)
    having=(unit predicate)
    selection=select
    order-by=(list ordering-column)
  ==
```

### Arguments

**`<table-set> [ [AS] <alias> ]`**
Any valid `<table-set>`.

`<alias>` allows short-hand reference to the `<table-set>` in the `SELECT` clause and subsequent `<predicates>`. 

**`{ <qualified-column> | <column-alias> | <column-ordinal> }`**

Used to select columns for ordering and grouping. `<column-ordinal>`s are 1-based.

**`[ TOP <n> ] [ BOTTOM <n> ]`**

Selects only the first and/or last `n` rows returned by the rest of the query. If the result set is less than `n`, the entire set of rows is returned. 

`TOP` and `BOTTOM` require the presence of an `ORDER BY` clause. This clause must provide for a total ordering of the returned rows, i.e. every sequence of `ORDER BY` columns must be unique within the returned rows. 

### Remarks

The `SELECT` clause may choose columns from a single CTE, in which case the `FROM` clause is absent. It may also choose only literal constants and `SCALAR` functions on literals, columns, or scalar queries, in which case it will return a result set of one row.

The simplest possible query is `SELECT 0`.

`<query>` alone does not change the Obelisk agent state.

*as-of-time currently missing from specification*

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


### Examples

SELECT 0;

FROM reference.calendar T1
JOIN reference.calendar-us-fed-holiday T2
WHERE T1.date BETWEEN ~2025.1.1 AND ~2025.12.31
SELECT T1.date, day-name, us-federal-holiday
