# DDL: Index
*supported in urQL parser, not yet supported in Obelisk*

## CREATE INDEX

This command creates an index over selected columns of an existing table.

### AST
```
<create-index> ::=
  CREATE [ UNIQUE ] INDEX <index>
    ON [ <db-qualifier> ] <table>
    ( <column> [ ASC | DESC ] [ ,...n ] )
    [ <as-of> ]
```

### Examples
```
CREATE INDEX ix-vendor-id ON product-vendor (vendor-id);
CREATE UNIQUE INDEX ix-vendor-id2 ON dbo.product-vendor
  (vendor-id DESC, name ASC, address DESC);
CREATE INDEX ix-vendor-id3 ON purchasing..product-vendor (vendor-id);
```

### Arguments

**`UNIQUE`**
Specifies that no two rows are permitted to have the same index key value.

**`<index>`**
User-defined name for the new index. This name must follow the Hoon term naming standard. Index names are unique within tables.

**`[ <db-qualifier> ] <table>`**
Name of existing table the index targets.
If not explicitly qualified, defaults to the Obelisk agent's current database and 'dbo' namespace.

**`<column> [ ASC | DESC ] [ ,...n ] `**
List of column names in the target table. This list represents the sort hierarchy and optionally specifies the sort direction for each level. The default sorting is `ASC` (ascending).

**`<as-of>`**
Timestamp of index creation. Defaults to `NOW` (current time). When specified, the timestamp must be greater than both the latest database schema and content timestamps. 

### API

```
+$  create-index
  $:
    %create-index
    name=@tas
    =qualified-table
    unique=?
    columns=(list ordered-column)
    as-of=(unit as-of)
  ==
```

### Remarks

This command mutates the state of the Obelisk agent.

### Produced Metadata

Schema timestamp

### Exceptions

index must be created by local agent
index name already exists for table
database `<database>` does not exist
table does not exist
column does not exist
create index `<index>` as-of schema time out of order
create index `<index>`as-of data time out of order
UNIQUE specified and existing values are not unique for the column(s) specified
create index state change after query in script

## ALTER INDEX

*supported in urQL parser, not yet supported in Obelisk*

Modifies the structure of an existing `<index>` on a user `<table>` or `<view>`.

```
<alter-index> ::=
  ALTER [ UNIQUE ] INDEX <index>
    ON [ <db-qualifier> ] <table>
    [ ( <column> [ ASC | DESC ] [ ,...n ] ) ]
    { DISABLE | RESUME}
    [ <as-of> ]
```

### Arguments

**`UNIQUE`**
Specifies that no two rows are permitted to have the same index key value.

**`<index>`**
Specifies the target index.

**`[ <db-qualifier> ] <table>`**
Name of the underlying object of the index.

**`<column> [ ASC | DESC ] [ ,...n ] `**
List of column names in the target table. This list represents the sort hierarchy and optionally specifies the sort direction for each level. The default sorting is `ASC` (ascending).

**`DISABLE | RESUME`**
Used to disable an active index or resume a disabled index.

**`<as-of>`**
Timestamp of index alteration. Defaults to `NOW` (current time). When specified, the timestamp must be greater than both the latest database schema and content timestamps.

### API
```
+$  alter-index
  $:
    %alter-index
    name=qualified-table
    =qualified-table
    unique=?
    columns=(list ordered-column)
    action=index-action
    as-of=(unit as-of)
  ==
```

### Remarks

This command mutates the state of the Obelisk agent.

Cannot alter primary key and foreign key indices.

`RESUME` will rebuild the index if the underlying object is dirty.

### Produced Metadata

Schema timestamp

### Exceptions

index must be altered by local agent
index name does not exist for table
database `<database>` does not exist
table does not exist
column does not exist
alter index `<index>` as-of schema time out of order
alter index `<index>`as-of data time out of order
UNIQUE specified and existing values are not unique for the column(s) specified
alter index state change after query in script

## DROP INDEX

*supported in urQL parser, not yet supported in Obelisk*

Deletes an existing `<index>`.

```
<drop-index> ::= 
  DROP INDEX <index>
    ON [ <db-qualifier> ] <table>
    [ <as-of> ]
```

### Arguments

**`<index>`**
The name of the index to delete.

**`[ <db-qualifier> ] <table>`**
`<table>` or `<view>` with the named index.

**`<as-of>`**
Timestamp of dropping index. Defaults to `NOW` (current time). When specified, the timestamp must be greater than both the latest database schema and content timestamps.

### API
```
+$  drop-index
  $:
    %drop-index
    name=@tas
    =qualified-table
    as-of=(unit as-of)
  ==
```

### Remarks

This command mutates the state of the Obelisk agent.

This command can be used to delete a `<foreign-key>`.

If `<view>` is shadowing `<table>`, the system attempts to find `<index>` on `<view>` first, then `<table>`.

### Produced Metadata

Schema timestamp

### Exceptions

index must be dropped by local agent
index name does not exist for table
database `<database>` does not exist
table does not exist
drop index `<index>` as-of schema time out of order
drop index `<index>`as-of data time out of order
drop index state change after query in script
