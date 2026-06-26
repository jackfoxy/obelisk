# INSERT

Inserts rows into a `<table>`.

```
<insert> ::=
  INSERT INTO <table> [ <as-of> ]
    [ ( <column> [ ,...n ] ) ]
    VALUES (<scalar-node> [ ,...n ] ) [ ...n ]
  | INSERT INTO [ FORCE ] <table> [ <as-of> ]
    [ ( <column> [ ,...n ] ) ]
    <query>
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

INSERT INTO FORCE reference.species-vital-signs-ranges-copy
FROM reference.species-vital-signs-ranges
SELECT species, temperature-low, temperature-high, heart-rate-low, heart-rate-high, respiratory-rate-low, respiratory-rate-high;
```

### Arguments
`FORCE` with `VALUES`
**`FORCE`**
Creates a new target table from a `<query>` source. When `FORCE` is specified the target must not already exist. When `FORCE` is not specified the target must already exist. `FORCE` with `VALUES` is invalid syntax.

**`<table>`**
The qualified or unqualified target of the `INSERT` operation.

**`<column>` [ ,...n ]**
When present, the column list must account for all column identifiers (names or aliases) in the target. This determines the order in which values are applied in the `<table>`'s data rows.

For existing tables, if not specified row values must be in the `<table>`'s canonical column order.

For `FORCE` inserts, if specified the column list defines the new table's canonical column order. If not specified the new table's canonical columns are determined by the `<query>` output column order.

**(`<scalar-node>` [ ,...n ] ) [ ,...n ]**
*fully supported in urQL parser, only literals supported in Obelisk*

Row(s) of literal values to insert into target. Source auras must match target columnwise.

**`<query>`**

`SELECT` query returning a `<relation>` to insert into target. Source auras must match target columnwise.

**`<as-of>`**
Timestamp equal to or greater than the existing table content state upon which to perform the INSERT operation. The resulting content timestamp will be `NOW` (current server time). `FORCE` creates a new table and must not specify target `<as-of>`.

### API
```
+$  insert
  $:
    op=?(%insert %upsert)
    force=?
    =qualified-table
    as-of=(unit as-of)
    columns=(unit (list @tas))
    values=insert-values
  ==
```

### Remarks

This command mutates the state of the Obelisk agent.

The `VALUES` or `<query>` must provide data for all columns in the expected order, either the order specified by `( <column> [ ,...n ] )` or if not present the inserted columns must be arranged in the canonical order of the target `<table>` columns, i.e. the order in which the columns were specified at table creation time or subsequently altered.

The `DEFAULT` keyword may be used instead of a value to specify the column type's bunt (default) value.

`INSERT` from `<query>` is executed as though the query result were a `VALUES` source with the same column order, row values, and auras. Inserting into an existing table and creating a new table with `FORCE` use the same deterministic row construction, type checking, `DEFAULT`, duplicate-key, and foreign-key rules as `VALUES`.

When `FORCE` is specified, the runtime creates the target table before inserting rows. The new table's column auras are the source auras after applying the column-order rules above.

When `FORCE` is specified, the runtime determines the new table's primary key by testing prefixes of the canonical column list from left to right. It starts with `~[column-1]`, then `~[column-1 column-2]`, and continues until the set of projected row keys has length equal to the length of the insert rows. The first prefix satisfying that condition becomes the primary key. For zero or one inserted row, `~[column-1]` is selected. Because `<query>` results are sets, the full-row prefix is unique for `INSERT` from `<query>`.

Use [`UPSERT`](/docs/usr/reference/dml-upsert.md) when rows with existing
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
table `<namespace>`.`<table>` already exists
table `<namespace>`.`<table>` does not exist and `FORCE` was not specified
table `<table>` as-of data time out of order
table `<table>` as-of schema time out of order
incorrect columns specified: `<columns>`
invalid column: `<column>`
cannot add duplicate key: `<row-key>`
`GRANT` permission on `<table>` violated
