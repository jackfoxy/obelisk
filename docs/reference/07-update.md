# UPDATE
*supported in urQL parser, not yet supported in Obelisk*

Changes content of selected columns in existing rows of a `<table-set>`. 

```
<update> ::=
  UPDATE [ <ship-qualifier> ] <table> [ <as-of-time> ]
    SET { <column> = <scalar-expression> } [ ,...n ]
    [ WHERE <predicate> ]
```

### API
```
+$  update
  $:
    %update
    table=qualified-object
    as-of=(unit as-of)
    columns=(list @tas)
    values=(list value-or-default)
    predicate=(unit predicate)
  ==
```

### Arguments

**`<table>`**
The target of the `UPDATE` operation.

**`<scalar-expression>`**
`<scalar-expression>` is a valid expression within the statement context.

**`<predicate>`**
Any valid `<predicate>`, including predicates on CTEs.

**`<as-of-time>`**
Timestamp equal to or greater than the table content state upon which to perform the UPDATE operation. The resulting content timestamp will be `NOW` (current server time).

### Remarks

This command mutates the state of the Obelisk agent.

Data in the *sys* namespace cannot be updated.

Cord literal values are represented in single quotes 'this is a cord'. Single quotes within cord values must be escaped with double backslash as `'this is a cor\\'d'`.

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
