# TRUNCATE TABLE

Removes all rows in a base table.

```
<truncate-table> ::=
  TRUNCATE TABLE [ <ship-qualifier> ] <table>
  [ <as-of-time> ]
```

### API
```
+$  truncate-table
  $:
    %truncate-table
    table=qualified-object
    as-of=(unit as-of)
  ==
```

### Arguments

**`<table>`**
The target table.

**`<as-of-time>`**
Timestamp of table creation. Defaults to `NOW` (current time). When specified, the timestamp must be greater than both the latest database schema and content timestamps.

### Remarks

The command potentially mutates `<table>`, resulting in a state change of the Obelisk agent.

Tables in the *sys* namespace cannot be truncated.

### Produced Metadata

message: TRUNCATE TABLE <namespace name>.<table name>
server-time: <timestamp>
data-time: <timestamp>
vector count: <count>

### Exceptions

state change after query in script
database `<database>` does not exist
namespace %ns1 does not exist
`<table>` as-of data time out of order
`<table>` as-of schema time out of order
table `<table>` does not exist in `<namespace>`
`GRANT` permission on `<table>` violated
