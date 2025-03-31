# INSERT

Inserts rows into a `<table>`.

```
<insert> ::=
  INSERT INTO <table> [ <as-of-time> ]
    [ ( <column> [ ,...n ] ) ]
    { VALUES (<scalar-expression> [ ,...n ] ) [ ...n ]
      | <selection> }
```

```
<scalar-expression> ::=
  { <constant>
    | TBD }
```

### API
```
+$  insert
  $:
    %insert
    table=qualified-object
    as-of=(unit as-of)
    columns=(unit (list @tas))
    values=insert-values
  ==
```

### Arguments

**`<table>`**
The target of the `INSERT` operation.

**`<column>` [ ,...n ]**
When present, the column list must account for all column identifiers (names or aliases) in the target. This determines the order in which values are applied in the `<table>`'s data rows. If not specified row values must be in the `<table>`'s canonical column order.

**(`<scalar-expression>` [ ,...n ] ) [ ,...n ]**
*fully supported in urQL parser, only literals supported in Obelisk*

Row(s) of literal values to insert into target. Source auras must match target columnwise.

**`<selection>`**
*selection supported in urQL parser, not yet supported in Obelisk*

Selection creating source `<table-set>` to insert into target. Source auras must match target columnwise.

(Selection is a wrapper for query.)

**`<as-of-time>`**
Timestamp equal to or greater than the table content state upon which to perform the INSERT operation. The resulting content timestamp will be `NOW` (current server time).

### Remarks

This command mutates the state of the Obelisk agent.

The `VALUES` or `<selection>` must provide data for all columns in the expected order, either the order specified by `( <column> [ ,...n ] )` or if not present the inserted columns must be arranged in the canonical order of the target `<table>` columns, i.e. the order in which the columns were specified at table creation time.

The `default` keyword may be used instead of a value to specify the column type's bunt (default) value.

Cord values are represented in single quotes `'this is a cord'`. Single quotes within cord values must be escaped with double backslash as `'this is a cor\\'d'`.

Note that multiple parentheses enclosed rows of column values are NOT comma separated.

### Produced Metadata

message: INSERT INTO <namespace name>.<table name>
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
table `<table>` as-of data time out of order
table `<table>` as-of schema time out of order
table `<namespace>`.`<table>` does not exist
incorrect columns specified: `<columns>`
invalid column: `<column>`
cannot add duplicate key: `<row-key>`
`GRANT` permission on `<table>` violated

## Example

```
INSERT INTO reference.species-vital-signs-ranges
  (species, temperature-low, temperature-high, heart-rate-low, heart-rate-high, respiratory-rate-low, respiratory-rate-high)
VALUES
  ('Dog', .99.5, .102.5, 60, 140, 10, 35)
  ('Cat', .99.5, .102.5, 140, 220, 20, 30)
  ('Rabbit', .100.5, .103.5, 120, 150, 30, 60);
```
