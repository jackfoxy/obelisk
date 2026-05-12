# DDL: Table

## CREATE TABLE

Creates a new table within the specified or default database.

`<table>`s are the source of indexed persistent `<relation>`s in Obelisk.

```
<create-table> ::=
  CREATE TABLE
    [ <db-qualifier> ]<table>
    ( <column> <aura>
      [ ,... n ] )
    PRIMARY KEY ( <column> [ ASC | DESC ] [ ,... n ] )
    [ FOREIGN KEY ( <column> [ ,... n ] )
      REFERENCES [ <namespace>. ] <table> ( <column> [ ,... n ] )
        [ ON DELETE { RESTRICT | CASCADE | SET DEFAULT } ]
        [ ON UPDATE { RESTRICT | CASCADE | SET DEFAULT } ]
      [ ,... n ] ]
    [ <as-of> ]
```

### Examples
```
CREATE TABLE order-detail
  (invoice-nbr @ud, line-item @ud, product-id @ud, special-offer-id @ud, message @t)
PRIMARY KEY (invoice-nbr, line-item);

CREATE TABLE db1..tbl-a
  (pk1 @ud, pk2 @ud, pk3 @ud, label-a @t)
  PRIMARY KEY (pk1 ASC, pk2 DESC, pk3 ASC);

CREATE TABLE db1..tbl-b
  (pk1 @ud, pk3 @ud, label-b @t)
  PRIMARY KEY (pk1 DESC, pk3);
```

### Arguments

Note: All names must adhere to the hoon term naming standard.

**`<table>`**
This is a user-defined name for the new table.

If not explicitly qualified, it defaults to the Obelisk agent's current database and the 'dbo' namespace.

**`<column> <aura>`**
The list of user-defined column names and associated auras.

For more details on auras, refer to [01-preliminaries](01-preliminaries.md)

**`<PRIMARY KEY`**

A constraint that enforces data integrity via a specified column or columns through a unique index. The index contains the columns listed, and sorts the data in either ascending or descending order, defaulting to ascending. Only one PRIMARY KEY constraint can be created per table. 

**`FOREIGN KEY ( <column> [ ,... n ] )`**
The ordered source column list in the table being created or altered.

Foreign keys are unnamed. A foreign key is identified by its ordered source columns and referenced table.

**`REFERENCES [ <namespace>. ] <table> ( <column> [ ,... n ] )`**
The referenced table and ordered referenced column list.

The referenced table must be in the same database as the source table.

The referenced columns must exactly match the referenced table's complete `PRIMARY KEY`, including order. The associated source and referenced column auras must match pairwise.

**`ON DELETE { RESTRICT | CASCADE | SET DEFAULT }`**
This argument specifies the action to be taken on the rows in the table that have a referential relationship when the referenced row is deleted from the foreign table.

**`ON UPDATE { RESTRICT | CASCADE | SET DEFAULT }`**
This argument specifies the action to be taken on the rows in the table that have a referential relationship when an `UPDATE` changes one or more columns of the referenced table's `PRIMARY KEY`. Updates to non-primary-key columns in the referenced row do not trigger referential actions.

**`RESTRICT` (default)**
The Obelisk agent raises an error and aborts the parent row delete/update if referencing child rows exist.

* `CASCADE`
Corresponding rows are deleted from the referencing table when that row is deleted from the parent foreign table. On update, referencing row foreign-key column values are rewritten from the old referenced primary-key values to the new referenced primary-key values, preserving the declared source/reference column pairing and order.

* `SET DEFAULT`
All the values that make up the foreign key in the referencing row(s) are set to their bunt (default) values. This operation is successful only if the foreign table contains the resulting bunt key, otherwise the action on the parent foreign table is aborted.

**`<as-of>`**
Timestamp of table alteration. Defaults to `NOW` (current time). When specified, the timestamp must be greater than both the latest database schema and content timestamps.

WARNING: It is possible to future date a `CREATE TABLE`. This will lock all schema and data updates in the database until that future time..

### API
```
+$  create-table
  $:
    %create-table
    =qualified-table
    columns=(list column)
    pri-indx=(list ordered-column)
    foreign-keys=(list foreign-key)
    as-of=(unit as-of)
  ==
```

### Remarks

This command mutates the state of the Obelisk agent.

`FOREIGN KEY` constraints ensure data integrity for the data contained in the column or columns. They necessitate that each value in the column exists in the corresponding referenced column or columns in the referenced table. `FOREIGN KEY` constraints can only reference the complete `PRIMARY KEY` of the referenced table, in primary key order.

`INSERT`, `UPDATE`, and `DELETE` enforce foreign keys at the mutation's effective content time, including when `AS OF` is supplied.

Self-referential foreign keys are allowed. Cyclic foreign-key dependencies are allowed only when all actions in the cycle are `RESTRICT`; cascading actions in cycles are rejected.

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
foreign key references another database
foreign key source column does not exist
`<table>` referenced by `FOREIGN KEY` does not exist
`<table-column>` column referenced by `FOREIGN KEY` does not exist
aura mis-match in `FOREIGN KEY`
foreign key reference columns do not match referenced `PRIMARY KEY`
foreign key already exists
state change after query in script

## ALTER TABLE

Modify the columns and/or `<foreign-key>`s of an existing `<table>`.

```
<alter-table> ::=
  ALTER TABLE [ <db-qualifier> ]<table>
    [ RENAME TO <table> ]
    [ COLUMNS ( <column> [ ,... n ] ) ]
    [ PRIMARY KEY ( <column> [ ,... n ] ) ]
    [ ADD COLUMN ( { <column>  <aura> } [ ,... n ] ) ]
    [ DROP COLUMN ( <column> [ ,... n ] ) ]
    [ RENAME COLUMN ( { <column> TO <column> } [ ,... n ] ) ]
    [ ALTER COLUMN ( { <column>  <aura> } [ ,... n ] ) ]
    [ ADD FOREIGN KEY ( <column> [ ,... n ] )
        REFERENCES [ <namespace>.] <table> ( <column> [ ,... n ] )
        [ ON DELETE { RESTRICT | CASCADE | SET DEFAULT } ]
        [ ON UPDATE { RESTRICT | CASCADE | SET DEFAULT } ]
    ]
    [ DROP FOREIGN KEY ( <column> [ ,... n ] ) [ <namespace>.] <table> ]
    [ ,... n ]
    [ <as-of> ]
```

At least one clause is required.

Example:
```
ALTER TABLE my-table
DROP FOREIGN KEY (customer-id) customer
```

### Arguments

Note: All names must adhere to the hoon term naming standard.

**`<table>`**
Name of `<table>` to alter.

**`RENAME TO`**
Renames `<table>` within the current namespace. Use `ALTER NAMESPACE` to transfer table to another namespace.

**`COLUMNS`**
Sets the cannonical ordering of columns after all `ADD`, `DROP`, and `RENAME` column operations have been performed.

**`<PRIMARY KEY`**

Changes the constraint that enforces data integrity via a specified column or columns through a unique index.The index contains the columns listed, and sorts the data in either ascending or descending order, defaulting to ascending. Only one PRIMARY KEY constraint can be created per table. 

`ALTER TABLE PRIMARY KEY` is rejected if the table is referenced by any foreign key, unless those foreign keys are first dropped. `ON UPDATE` does not apply to changes in primary-key definition.

**`ADD ( <column> <aura> [ ,... n ] )`**
Denotes a list of user-defined column names and associated auras. If `COLUMNS` is not specified the columns are appended to the existing canonical ordering.

**`DROP COLUMN ( <column> [ ,... n ] )`**
Denotes a list of existing column names to delete from the `<table>` structure.

**`RENAME COLUMN`**
Renames existing columns. If `COLUMNS` is not specified the existing canonical ordering remains in effect.

**`ALTER COLUMN ( <column> <aura> [ ,... n ] )`**
Denotes a list of user-defined column names and associated auras. `ALTER` is used to change the aura of an existing column.

**`ADD | DROP`**
The action is to add or drop a foreign key.

**`ADD FOREIGN KEY ( <column> [ ,... n ] )`**
The ordered source column list in the table being altered.

Foreign keys are unnamed. A foreign key is identified by its ordered source columns and referenced table.

`ADD FOREIGN KEY` validates all existing rows in the altered table at the alteration's effective content time. The operation fails if any existing foreign-key value does not match an existing referenced primary-key value.

**`REFERENCES [ <namespace>. ] <table> ( <column> [ ,... n ] )`**
The referenced table and ordered referenced column list.

The referenced table must be in the same database as the source table. Cross-database foreign keys are rejected.

The referenced columns must exactly match the referenced table's complete `PRIMARY KEY`, including order. The associated source and referenced column auras must match pairwise.

**`ON DELETE { RESTRICT | CASCADE | SET DEFAULT }`**
This argument specifies the action to be taken on the rows in the table that have a referential relationship when the referenced row is deleted from the foreign table.

**`ON UPDATE { RESTRICT | CASCADE | SET DEFAULT }`**
This argument specifies the action to be taken on the rows in the table that have a referential relationship when an `UPDATE` changes one or more columns of the referenced table's `PRIMARY KEY`. Updates to non-primary-key columns in the referenced row do not trigger referential actions.

**`RESTRICT` (default)**
The Obelisk agent raises an error and aborts the parent row delete/update if referencing child rows exist.

* `CASCADE`
Corresponding rows are deleted from the referencing table when that row is deleted from the parent foreign table. On update, referencing row foreign-key column values are rewritten from the old referenced primary-key values to the new referenced primary-key values, preserving the declared source/reference column pairing and order.

* `SET DEFAULT`
All the values that make up the foreign key in the referencing row(s) are set to their bunt (default) values. This operation is successful only if the foreign table contains the resulting bunt key, otherwise the action on the parent foreign table is aborted.

**`DROP FOREIGN KEY ( <column> [ ,... n ] ) [ <namespace>. ] <table>`**
Drops the foreign key from the altered table whose ordered source columns and referenced table match the clause.

**`<as-of>`**
Timestamp of table alteration. Defaults to `NOW` (current time). When specified, the timestamp must be greater than both the latest database schema and content timestamps.

WARNING: It is possible to future date a `ALTER TABLE`. This will lock all schema and data updates in the database until that future time.

### API
```
+$  alter-table
  $:
    %alter-table
    =qualified-table
    new-name=(unit @tas)
    columns=(list @tas)
    pri-indx=(list ordered-column)
    add-columns=(list column)
    drop-columns=(list @tas)
    rename-columns=(list [@tas @tas])
    alter-columns=(list column)
    add-foreign-keys=(list foreign-key)
    drop-foreign-keys=(unit [(list @tas) =qualified-table])
    as-of=(unit as-of)
    ==
```

### Remarks

This command mutates the state of the Obelisk agent.

`FOREIGN KEY` constraints ensure data integrity for the data contained in the column or columns. They necessitate that each value in the column exists in the corresponding referenced column or columns in the referenced table. `FOREIGN KEY` constraints can only reference the complete `PRIMARY KEY` of the referenced table, in primary key order.

`INSERT`, `UPDATE`, and `DELETE` enforce foreign keys at the mutation's effective content time, including when `AS OF` is supplied.

Self-referential foreign keys are allowed. Cyclic foreign-key dependencies are allowed only when all actions in the cycle are `RESTRICT`; cascading actions in cycles are rejected.

### Produced Metadata

Schema timestamp

### Exceptions

table must be altered by local agent
database `<database>` does not exist
`<table>` does not exists in `<namespace>`
alter a column that does not exist
add a column that does exist
drop a column that does not exist
foreign key references another database
foreign key source column does not exist
`<table>` referenced by `FOREIGN KEY` does not exist
`<table-column>` column referenced by `FOREIGN KEY` does not exist
aura mis-match in `FOREIGN KEY`
foreign key reference columns do not match referenced `PRIMARY KEY`
foreign key already exists
foreign key to drop does not exist
alter table `<table>` as-of schema time out of order
alter table `<table>`as-of data time out of order
alter table state change after query in script
alter table COLUMNS does not alter existing canonical order
alter table COLUMNS does include every column
alter table PRIMARY KEY is not unique over existing data
alter table PRIMARY KEY does not alter existing key


## DROP TABLE

Deletes a `<table>` and all associated objects.

```
<drop-table> ::= 
  DROP TABLE [ FORCE ] [ <db-qualifier> ]{ <table> }
    [ <as-of> ]
```

### Examples

```
"DROP TABLE my-table"

"DROP TABLE FORCE db2..my-table-2"
```

### Arguments

**`FORCE`**
Optionally force deletion of table when table is populated, used in a view, or used in a foreign key.

**`<table>`**
Name of `<table>` to delete.

**`<as-of>`**
Timestamp of table deletion. Defaults to `NOW` (current time). When specified, the timestamp must be greater than both the latest database schema and content timestamps. 

### API
```
+$  drop-table
  $:
    %drop-table
    =qualified-table
    force=?
    as-of=(unit as-of)
  ==
```

### Remarks

This command mutates the state of the Obelisk agent.

Cannot drop if used in a view or foreign key, unless `FORCE` is specified, resulting in cascading object drops. Affected views and foreign keys dropped.

Without `FORCE`, `DROP TABLE` is rejected if the table is referenced by, or contains, any foreign key. With `FORCE`, all foreign keys that reference the table and all foreign keys defined by the table are dropped. If the table is both parent and child, both incoming and outgoing foreign-key constraints are removed.

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
