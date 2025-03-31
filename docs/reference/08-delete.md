# DELETE

Deletes rows from a `<table-set>`.

```
<delete> ::=
  DELETE [ FROM ] <table> [ <as-of-time> ]
    WHERE <predicate>
```
### API
```
+$  delete
  $:
    %delete
    table=qualified-object
    as-of=(unit as-of)
    predicate=predicate
  ==
```

### Arguments

**`<table>`**
The target of the `DELETE` operation.

**`<predicate>`**
Any valid `<predicate>`, including predicates on CTEs determining rows to delete.

**`<as-of-time>`**
Timestamp equal to or greater than the table content state upon which to perform the DELETE operation. The resulting content timestamp will be `NOW` (current server time).

### Remarks

This command mutates the state of the Obelisk agent.

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
