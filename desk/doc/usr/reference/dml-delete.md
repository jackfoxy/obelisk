# DELETE

Deletes rows from a `<relation>`.

```
<delete> ::=
  [ WITH [ <common-table-expression> [ ,...n ] ] ]
  [ SCALARS { <name> <scalar-function> } [ ...n ]]
  DELETE [ FROM ] <table> [ <as-of> ]
    WHERE <predicate>
```

```
<common-table-expression> ::= ( <query> ) [ AS ] <name>
```

### Example

```
DELETE FROM my-table-2
WHERE col1 = 'tomorrow';
```

### Arguments

**`<table>`**
The target of the `DELETE` operation.tal

**`<predicate>`**
Any valid `<predicate>`, including predicates on CTEs and/or scalar names determining rows to delete.

**`<as-of>`**
Timestamp equal to or greater than the table content state upon which to perform the DELETE operation. The resulting content timestamp will be `NOW` (current server time) and all other rows of the newly current table content will be from the `<as-of>` state.

### API
```
+$  crud-txn
  $:
    %crud-txn
    ctes=(list cte)
    body=[%delete delete]
  ==

+$  delete
  $:
    %delete
    scalars=(list scalar)
    =qualified-table
    as-of=(unit as-of)
    =predicate
  ==
```

### Remarks

This command mutates the state of the Obelisk agent.

Including the scalar RAND in the predicate will result in a non-deterministic state.

Data in the *sys* namespace cannot be deleted.

### Produced Metadata

message DELETE FROM  <namespace name>.<table name>
server-time: <timestamp>
schema-time: <timestamp>   The most current table schema time
data-time: <timestamp>     The source content time upon which the DELETE acted
message: deleted:
vector count: <count>
message: table data:
vector count: <count>

### Exceptions

delete state change after query in script
database `<database>` does not exist
delete from table `<table>` as-of data time out of order
delete from table `<table>` as-of schema time out of order
table `<namespace>`.`<table>` does not exist
delete invalid predicate: `<predicate>`
`GRANT` permission on `<table>` violated
