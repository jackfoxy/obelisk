# INSERT

Inserts rows into a `<table>`.

```
<insert> ::=
  [ WITH [ <common-table-expression> [ ,...n ] ] ]
  INSERT INTO <table> [ <as-of> ]
    [ ( <column> [ ,...n ] ) ]
    VALUES (<scalar-node> [ ,...n ] ) [ ...n ]
  | INSERT INTO <table> [ <as-of> ]
    [ ( <column> [ ,...n ] ) ]
    <query>

<common-table-expression> ::= ( <query> ) [ AS ] <name>
```

```
<scalar-node> ::=
  { <literal>
    | TBD }
```

## Example

```
INSERT INTO reference.species-vital-signs-ranges
  (species, temperature-low, temperature-high, heart-rate-low, heart-rate-high, respiratory-rate-low, respiratory-rate-high)
VALUES
  ('Dog', .99.5, .102.5, 60, 140, 10, 35)
  ('Cat', .99.5, .102.5, 140, 220, 20, 30)
  ('Rabbit', .100.5, .103.5, 120, 150, 30, 60);

INSERT INTO reference.species-vital-signs-ranges
:: inserted values are in canonical column order
VALUES
  ('Dog', .99.5, .102.5, 60, 140, 10, 35)
  ('Cat', .99.5, .102.5, 140, 220, 20, 30)
  ('Rabbit', .100.5, .103.5, 120, 150, 30, 60);

INSERT INTO reference.species-vital-signs-ranges-copy
FROM reference.species-vital-signs-ranges
SELECT species, temperature-low, temperature-high, heart-rate-low, heart-rate-high, respiratory-rate-low, respiratory-rate-high;

WITH (FROM reference.species-vital-signs-ranges WHERE species = 'Dog' SELECT *) AS dogs
INSERT INTO reference.species-vital-signs-ranges-copy
FROM dogs
SELECT *;
```

### Arguments

**`<common-table-expression>`**
A named query that `<query>` may read.

**`<table>`**
The qualified or unqualified target of the `INSERT` operation. The target must already exist.

**`<column>` [ ,...n ]**
When present, the column list must account for all column identifiers (names or aliases) in the target. This determines the order in which values are applied in the `<table>`'s data rows.

If not specified row values must be in the `<table>`'s canonical column order.

**(`<scalar-node>` [ ,...n ] ) [ ,...n ]**
*fully supported in urQL parser, only literals supported in Obelisk runtime*

Row(s) of literal values to insert into target. Source auras must match target columnwise.

**`<query>`**
A query or set operation query (`UNION`, `EXCEPT`, `INTERSECT`, `DIVIDED BY`) whose rows are inserted into target. It may begin with `FROM` or `SELECT`, and may read `<common-table-expression>`s of the `WITH` clause. Output columns match target columns by position and aura; output column names are ignored.

**`<as-of>`**
Timestamp equal to or greater than the existing table content state upon which to perform the INSERT operation. The resulting content timestamp will be `NOW` (current server time).

### API
```
+$  insert
  $:
    op=?(%insert %upsert)
    =qualified-table
    as-of=(unit as-of)
    columns=(unit (list @tas))
    values=insert-values
  ==
+$  insert-values
  $%  [%data (list (list value-or-default))]
      [%query query]
      [%set-query set-query]
      ==
```

`<query>` produces `[%query query]` or `[%set-query set-query]`.

### Remarks

This command mutates the state of the Obelisk agent.

The `VALUES` or `<query>` must provide data for all columns in the expected order, either the order specified by `( <column> [ ,...n ] )` or if not present the inserted columns must be arranged in the canonical order of the target `<table>` columns, i.e. the order in which the columns were specified at table creation time or subsequently altered.

The `DEFAULT` keyword may be used instead of a value to specify the column type's bunt (default) value.

`INSERT` from `<query>` is executed as though the query result were a `VALUES` source with the same column order, row values, and auras, using the same type checking, duplicate-key, and foreign-key rules as `VALUES`:

* The query reads state as it was before the `INSERT`, so a query of the target table itself sees none of the inserted rows.
* `ORDER BY` in `<query>` serves only `TOP`; without `TOP` it is ignored.
* Every query row must have a value for every target column. A row of an outer join that lacks a column fails.
* Two query rows with the same primary key fail, since query rows have no order.
* A query with no rows inserts nothing and leaves the table's data time unchanged.
* A query with random scalars adds the `warning: results are non-deterministic` message.

Use [`UPSERT`](/docs/usr/reference/dml/upsert.md) when rows with existing
primary keys should be overwritten instead of rejected.

Text values use Hoon aura notation: `@t` cords are represented in single
quotes, `@tas` terms with `%`, and `@ta` knots with `~.`. Single quotes within
cord values must be escaped with double backslash as `'this is a cor\\'d'`.
`@ta` and `@tas` values are validated before rows are written.

Note that multiple parentheses enclosed rows of column values are NOT comma separated.

### Produced Metadata

action: INSERT INTO <namespace name>.<table name>
server time: <timestamp>
schema time: <timestamp>   The most current table schema time
data time: <timestamp>     The source content time upon which the INSERT acted
message: inserted:
vector count: <count>
message: table data:
vector count: <count>

### Exceptions

state change after query in script
type of column `<column>` does not match input value type `<aura>`
database `<database>` does not exist
table `<namespace>`.`<table>` does not exist
table `<table>` as-of data time out of order
table `<table>` as-of schema time out of order
incorrect columns specified: `<columns>`
query row lacks column `<column>`
query row has `<n>` columns, target has `<m>`
query rows have duplicate key: `<row-key>`
invalid column: `<column>`
cannot add duplicate key: `<row-key>`
`GRANT` permission on `<table>` violated
