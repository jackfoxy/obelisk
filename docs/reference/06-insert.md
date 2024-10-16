# INSERT

Inserts rows into a `<table>`.

```
<insert> ::=
  INSERT INTO <table>
    [ ( <column> [ ,...n ] ) ]
    { VALUES (<scalar-expression> [ ,...n ] ) [ ...n ]
      | <selection> }
    [ <as-of-time> ]
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
    columns=(unit (list @t))
    values=insert-values
    as-of=(unit as-of)
  ==
```

### Arguments

**`<table>`**
The target of the `INSERT` operation.

**`<column>` [ ,...n ]**
When present, the column list must account for all column identifiers (names or aliases) in the target once. It determines the order in which the update values are applied and the output `<table>`'s column order.   

**(`<scalar-expression>` [ ,...n ] ) [ ,...n ]**
*fully supported in urQL parser, only literals supported in Obelisk*

Row(s) of literal values to insert into target. Source auras must match target columnwise.

**`<selection>`**
*selection supported in urQL parser, not yet supported in Obelisk*

Selection creating source `<table-set>` to insert into target. Source auras must match target columnwise.

(Selection is a wrapper for query.)

**`<as-of-time>`**
Timestamp of table creation. Defaults to `NOW` (current time). When specified, the timestamp must be greater than both the latest database schema and content timestamps.

### Remarks

This command mutates the state of the Obelisk agent.

The `VALUES` or `<selection>` must provide data for all columns in the expected order.

Cord values are represented in single quotes `'this is a cord'`. Single quotes within cord values must be escaped with double backslash as `'this is a cor\\'d'`.

If `( <column> [ ,...n ] )` is not specified, the inserted columns must be arranged in the same order as the target `<table>` columns.

Note that multiple parentheses enclosed rows of column values are NOT comma separated.

### Produced Metadata

Row count
Content timestamp (labelled 'data time')

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
  (species, temp-low, temp-high, heart-rate-low, heart-rate-high, respiratory-rate-low, respiratory-rate-high)
VALUES
  ('Dog', .99.5, .102.5, 60, 140, 10, 35)
  ('Cat', .99.5, .102.5, 140, 220, 20, 30)
  ('Rabbit', .100.5, .103.5, 120, 150, 30, 60);
```
