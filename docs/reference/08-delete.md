# DELETE

Deletes rows from a `<table-set>`.

```
<delete> ::=
  DELETE [ FROM ] <table>
    WHERE <predicate>
  [ <as-of-time> ]
```
### API
```
+$  delete
  $:
    %delete
    table=qualified-object
    predicate=(unit predicate)
    as-of=(unit as-of)
  ==
```

### Arguments

**`<table>`**
The target of the `DELETE` operation.

**`<predicate>`**
Any valid `<predicate>`, including predicates on CTEs determining rows to delete.

**`<as-of-time>`**
Timestamp of table row[s] deletion. Defaults to `NOW` (current time). When specified, the timestamp must be greater than both the latest database schema and content timestamps.

### Remarks

This command mutates the state of the Obelisk agent.

Data in the *sys* namespace cannot be deleted.

### Produced Metadata

Row count
Content timestamp

### Exceptions

delete state change after query in script
database `<database>` does not exist
delete from table `<table>` as-of data time out of order
delete from table `<table>` as-of schema time out of order
table `<namespace>`.`<table>` does not exist
delete invalid predicate: `<predicate>`
`GRANT` permission on `<table>` violated
