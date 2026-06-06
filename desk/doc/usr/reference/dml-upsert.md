# UPSERT

Inserts rows into a `<table>`, or overwrites existing rows with the same
primary key.

```
<upsert> ::=
  UPSERT INTO <table> [ <as-of> ]
    [ ( <column> [ ,...n ] ) ]
    VALUES (<scalar-node> [ ,...n ] ) [ ...n ]
```

## Example

```
UPSERT INTO reference.species-vital-signs-ranges
  (species, temperature-low, temperature-high, heart-rate-low, heart-rate-high, respiratory-rate-low, respiratory-rate-high)
VALUES
  ('Dog', .99.5, .102.5, 60, 140, 10, 35)
  ('Cat', .99.5, .102.5, 140, 220, 20, 30);
```

### Arguments

**`<table>`**
The target of the `UPSERT` operation.

**`<column>` [ ,...n ]**
When present, the column list must account for all column identifiers (names or
aliases) in the target. This determines the order in which values are applied
in the `<table>`'s data rows. If not specified row values must be in the
`<table>`'s canonical column order.

**(`<scalar-node>` [ ,...n ] ) [ ,...n ]**
Row(s) of literal values to upsert into target. Source auras must match target
columnwise.

**`<as-of>`**
Timestamp equal to or greater than the table content state upon which to
perform the UPSERT operation. The resulting content timestamp will be `NOW`
(current server time).

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
```

### Remarks

This command mutates the state of the Obelisk agent.

`UPSERT` uses the same value and column ordering rules as `INSERT`. Unlike
`INSERT`, it does not fail when a row has an existing primary key. The existing
row is replaced by the new row.

If a single `UPSERT` command contains multiple rows for the same primary key,
the last row takes precedence.

The `DEFAULT` keyword may be used instead of a value to specify the column
type's bunt (default) value.

Text values use Hoon aura notation: `@t` cords are represented in single
quotes, `@tas` terms with `%`, and `@ta` knots with `~.`. `@ta` and `@tas`
values are validated before rows are written.

### Produced Metadata

action: UPSERT INTO <namespace name>.<table name>
server time: <timestamp>
schema time: <timestamp>   The most current table schema time
data time: <timestamp>     The source content time upon which the UPSERT acted
message: upserted:
vector count: <count>
message: table data:
vector count: <count>

### Exceptions

state change after query in script
type of column `<column>` does not match input value type `<aura>`
database `<database>` does not exist
table `<table>` as-of data time out of order
table `<table>` as-of schema time out of order
table `<namespace>`.`<table>` does not exist
incorrect columns specified: `<columns>`
invalid column: `<column>`
`GRANT` permission on `<table>` violated
