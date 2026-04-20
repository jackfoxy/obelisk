# UPDATE

Changes content of selected columns in existing rows of a `<relation>`. 

```
<update> ::=
  [ WITH [ <common-table-expression> [ ,...n ] ] ]
  [ SCALARS { <name> <scalar-function> } [ ...n ]]
  UPDATE [ <ship-qualifier> ] <table> [ <as-of> ]
    SET { <column> = <scalar-node> } [ ,...n ]
    [ WHERE <predicate> ]
```

```
<common-table-expression> ::= ( <query> ) [ AS ] <name>
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
UPDATE my-table
:: updates every row
:: col0 updated to default for column type
SET col0=DEFAULT,
    col1='upd1',
    col3=7,
    col4=~2025.4.25;

UPDATE my-table 
SET col0=~1980.1.1,
    col1='hello',
    col3=152,
    col4=~1978.12.31
WHERE col1='Default'
  AND col2=~nec;

WITH (FROM my-table-2
      WHERE col4 = 'row3'
      SELECT col1, col3) AS my-cte
UPDATE my-table 
SET col1='updated'
WHERE my-cte.col1 = my-cte.col3;
```

### Arguments

**`<table>`**
The target of the `UPDATE` operation.

**`<scalar-node>`**
`<scalar-node>` is a valid expression within the statement context.

**`<predicate>`**
Any valid `<predicate>`, including predicates on CTEs and/or scalars.

**`<as-of>`**
Timestamp equal to or greater than the table content state upon which to perform the UPDATE operation. The resulting content timestamp will be `NOW` (current server time).

### API
```
+$  update
  $:
    %update
    ctes=(list cte)
    scalars=(list scalar)
    =qualified-table
    as-of=(unit as-of)
    $:  columns=(list qualified-column)
        values=(list value-or-default)
        ==
    =predicate
  ==
```

### Remarks

This command mutates the state of the Obelisk agent.

Data in the *sys* namespace cannot be updated.

Cord literal values are represented in single quotes 'this is a cord'. Single quotes within cord values must be escaped with double backslash as `'this is a cor\\'d'`.

The `DEFAULT` keyword may be used instead of a value to specify the column type's bunt (default) value.

### Produced Metadata

message UPDATE  <namespace name>.<table name>
server-time: <timestamp>
schema-time: <timestamp>   The most current table schema time
data-time: <timestamp>     The source content time upon which the UPDATE acted
message: updated:
vector count: <count>
message: table data:
vector count: <count>

### Exceptions

update state change after query in script
database `<database>` does not exist
update into table `<table>` as-of data time out of order
update into table `<table>` as-of schema time out of order
table `<namespace>`.`<table>` does not exist
`<namespace>`.`<table>` not matched by column qualifier
columns and values mismatch
value type not supported: `<value>`
value type: `<value>` does not match column: `<columns>`
update invalid column: `<columns>`
aura mismatch on `SET`
`GRANT` permission on `<table>` violated
