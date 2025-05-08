# DDL: Table

## CREATE TABLE

Creates a new table within the specified or default database.

`<table>`s are the source of indexed persistent `<table-sets>`s in Obelisk.

```
<create-table> ::=
  CREATE TABLE
    [ <db-qualifer> ]<table>
    ( <column> <aura>
      [ ,... n ] )
    PRIMARY KEY ( <column> [ ,... n ] )
    [ { FOREIGN KEY <foreign-key> ( <column> [ ASC | DESC ] [ ,... n ] )
      REFERENCES [ <namespace>. ] <table> ( <column> [ ,... n ] )
        [ ON DELETE { NO ACTION | CASCADE | SET DEFAULT } ]
        [ ON UPDATE { NO ACTION | CASCADE | SET DEFAULT } ] }
      [ ,... n ] ]
    [ <as-of-time> ]
```

### API
```
+$  create-table
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

Note: All names must adhere to the hoon term naming standard.

**`<table>`**
This is a user-defined name for the new table.

If not explicitly qualified, it defaults to the Obelisk agent's current database and the 'dbo' namespace.

**`<column> <aura>`**
The list of user-defined column names and associated auras.

For more details on auras, refer to [01-preliminaries](01-preliminaries.md)

*foreign keys supported in urQL parser, not yet supported in Obelisk*

**`<foreign-key> ( <column> [ ASC | DESC ] [ ,... n ]`**
This is a user-defined name for `<foreign-key>`.

This list comprises column names in the table for association with a foreign table along with sort ordering. Default is `ASC` (ascending).

Note: The Obelisk engine does not yet implement foreign keys.

**`<table> ( <column> [ ,... n ]`**
Referenced foreign `<table>` and columns. Count and associated column auras must match the specified columns from the new `<table>` and comprise a `UNIQUE` index on the referenced foreign `<table>`.

**`ON DELETE { NO ACTION | CASCADE | SET DEFAULT }`**
This argument specifies the action to be taken on the rows in the table that have a referential relationship when the referenced row is deleted from the foreign table.

* `NO ACTION` (default)
The Obelisk agent raises an error and the delete action on the row in the parent foreign table is aborted.

* `CASCADE`
Corresponding rows are deleted from the referencing table when that row is deleted from the parent foreign table.

* `SET DEFAULT`
All the values that make up the foreign key in the referencing row(s) are set to their bunt (default) values when the corresponding row in the parent foreign table is deleted.

The Obelisk agent raises an error if the parent foreign table has no entry with bunt values.

**`ON UPDATE { NO ACTION | CASCADE | SET DEFAULT }`**
This argument specifies the action to be taken on the rows in the table that have a referential relationship when the referenced row is updated in the foreign table.

* `NO ACTION` (default)
The Database Engine raises an error and the update action on the row in the parent table is aborted.

* `CASCADE`
Corresponding rows are updated in the referencing table when that row is updated in the parent table.

* `SET DEFAULT`
All the values that make up the foreign key in the referencing row(s) are set to their bunt (default) values when the corresponding row in the parent foreign table is updated. 

The Obelisk agent raises an error if the parent foreign table has no entry with bunt values.

**`<as-of-time>`**
Timestamp of table creation. Defaults to `NOW` (current time). When specified, the timestamp must be greater than both the latest database schema and content timestamps. 

WARNING: Future `<as-of-time>` is possible, but this sets the database content timestamp to the future, effectively locking the database for content updates until the future date is realized.

### Remarks

This command mutates the state of the Obelisk agent.

`PRIMARY KEY` must be unique.

`FOREIGN KEY` constraints ensure data integrity for the data contained in the column or columns. They necessitate that each value in the column exists in the corresponding referenced column or columns in the referenced table. `FOREIGN KEY` constraints can only reference columns that are subject to a `PRIMARY KEY` or `UNIQUE INDEX` constraint in the referenced table.

### Produced Metadata

message: CREATE TABLE <name>
server time: <timestamp>
schema time: <timestamp>

### Exceptions

table must be created by local agent
database `<database>` does not exist
`<table>` as-of schema time out of order
`<table>`as-of data time out of order
namespace `<namespace>` does not exist
duplicate column names `<columns>`
duplicate column names in key `<columns>`
key column not in column definitions `<pri-indx>`
`<table>` exists in `<namespace>`
`<table>` referenced by `FOREIGN KEY` does not exist
`<table-column>` column referenced by `FOREIGN KEY` does not exist
aura mis-match in `FOREIGN KEY`
state change after query in script

### Example
```
CREATE TABLE order-detail
  (invoice-nbr @ud, line-item @ud, product-id @ud, special-offer-id @ud, message @t)
PRIMARY KEY (invoice-nbr, line-item)
FOREIGN KEY fk-special-offer-order-detail (product-id, specialoffer-id)
REFERENCES special-offer (product-id, special-offer-id)
```

## ALTER TABLE

*supported in urQL parser, not yet supported in Obelisk*

Modify the columns and/or `<foreign-key>`s of an existing `<table>`.

```
<alter-> ::=
  ALTER TABLE [ <db-qualifer> ]{ <table> }
    { ADD COLUMN ( <column>  <aura> [ ,... n ] )
      | ALTER COLUMN ( <column>  <aura> [ ,... n ] )
      | DROP COLUMN ( <column> [ ,... n ] )
      | ADD FOREIGN KEY <foreign-key> (<column> [ ,... n ])
        REFERENCES [<namespace>.]<table> (<column> [ ,... n ])
        [ ON DELETE { NO ACTION | CASCADE } ]
        [ ON UPDATE { NO ACTION | CASCADE } ]
        [ ,... n ]
      | DROP FOREIGN KEY ( <foreign-key> [ ,... n ] } )
    [ <as-of-time> ]
```

Example:
```
ALTER TABLE my-table
DROP FOREIGN KEY fk-1, fk-2
```

### API
```
+$  alter-table
  $:
    %alter-table
    table=qualified-object
    alter-columns=(list column)
    add-columns=(list column)
    drop-columns=(list @tas)
    add-foreign-keys=(list foreign-key)
    drop-foreign-keys=(list @tas)
    as-of=(unit as-of)
  ==
```

### Arguments

Note: All names must adhere to the hoon term naming standard.

**`<table>`**
Name of `<table>` to alter.

**`ADD | ALTER COLUMN ( <column> <aura> [ ,... n ] )`**
Denotes a list of user-defined column names and associated auras. `ALTER` is used to change the aura of an existing column.

**`DROP COLUMN ( <column> [ ,... n ] )`**
Denotes a list of existing column names to delete from the `<table>` structure.

**`ADD | DROP`**
The action is to add or drop a foreign key.

**`<foreign-key> ( <column> [ ASC | DESC ] [ ,... n ]`**
This is a user-defined name for `<foreign-key>`.
This list comprises column names in the table for association with a foreign table along with sort ordering. Default is `ASC` (ascending).

**`<table> ( <column> [ ,... n ]`**
Referenced foreign `<table>` and columns. Count and associated column auras must match the specified columns from the new `<table>` and comprise a `UNIQUE` index on the referenced foreign `<table>`.

**`ON DELETE { NO ACTION | CASCADE | SET DEFAULT }`**
This argument specifies the action to be taken on the rows in the table that have a referential relationship when the referenced row is deleted from the foreign table.

* `NO ACTION` (default)
The Obelisk agent raises an error and the delete action on the row in the parent foreign table is aborted.

* `CASCADE`
Corresponding rows are deleted from the referencing table when that row is deleted from the parent foreign table.

* `SET DEFAULT`
All the values that make up the foreign key in the referencing row(s) are set to their bunt (default) values when the corresponding row in the parent foreign table is deleted.

The Obelisk agent raises an error if the parent foreign table has no entry with bunt values.

**`ON UPDATE { NO ACTION | CASCADE | SET DEFAULT }`**
This argument specifies the action to be taken on the rows in the table that have a referential relationship when the referenced row is updated in the foreign table.

* `NO ACTION` (default)
The Database Engine raises an error and the update action on the row in the parent table is aborted.

* `CASCADE`
Corresponding rows are updated in the referencing table when that row is updated in the parent table.

* `SET DEFAULT`
All the values that make up the foreign key in the referencing row(s) are set to their bunt (default) values when the corresponding row in the parent foreign table is updated. 

The Obelisk agent raises an error if the parent foreign table has no entry with bunt values.

**`<as-of-time>`**
Timestamp of table alteration. Defaults to `NOW` (current time). When specified, the timestamp must be greater than both the latest database schema and content timestamps.

WARNING: It is possible to future date a `CREATE TABLE`. This will lock all schema and data updates in the database until that future time.

### Remarks

This command mutates the state of the Obelisk agent.

`FOREIGN KEY` constraints ensure data integrity for the data contained in the column or columns. They necessitate that each value in the column exists in the corresponding referenced column or columns in the referenced table. `FOREIGN KEY` constraints can only reference columns that are subject to a `PRIMARY KEY` or `UNIQUE INDEX` constraint in the referenced table.

### Produced Metadata

Schema timestamp

### Exceptions

table must be altered by local agent
database `<database>` does not exist
`<table>` does not exists in `<namespace>`
alter a column that does not exist
add a column that does exist
drop a column that does not exist
`<table>` referenced by `FOREIGN KEY` does not exist
`<table-column>` column referenced by `FOREIGN KEY` does not exist
aura mis-match in `FOREIGN KEY`
alter table `<table>` as-of schema time out of order
alter table `<table>`as-of data time out of order
alter table state change after query in script


## DROP TABLE

Deletes a `<table>` and all associated objects.

```
<drop-table> ::= 
  DROP TABLE [ FORCE ] [ <db-qualifer> ]{ <table> }
    [ <as-of-time> ]
```

### API
```
+$  drop-table
  $:
    %drop-table
    table=qualified-object
    force=?
    as-of=(unit as-of)
  ==
```

### Arguments

**`FORCE`**
Optionally force deletion of table when table is populated, used in a view, or used in a foreign key.

**`<table>`**
Name of `<table>` to delete.

**`<as-of-time>`**
Timestamp of table deletion. Defaults to `NOW` (current time). When specified, the timestamp must be greater than both the latest database schema and content timestamps. 

### Remarks

This command mutates the state of the Obelisk agent.

Cannot drop if used in a view or foreign key, unless `FORCE` is specified, resulting in cascading object drops. Affected views and foreign keys dropped.

Cannot drop when the `<table>` is populated unless `FORCE` is specified.

### Produced Metadata

message: DROP TABLE <name>
server time: <timestamp>
schema time: <timestamp>
data time <timestamp>
vector count: <n>

### Exceptions

table must be dropped by local agent
database `<database>` does not exist
`<table>` as-of schema time out of order
`<table>`as-of data time out of order
namespace `<namespace>` does not exist
`<table>` does not exist in `<namespace>`
`<table>` has data, use `FORCE` to `DROP`
`<table>` used in `<view>`, use `FORCE` to `DROP`
`<table>` used in `<foreign-key>`, use `FORCE` to `DROP`
state change after query in script
`GRANT` permission on `<table>` violated
