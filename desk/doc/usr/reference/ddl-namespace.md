# DDL: Namespace

## CREATE NAMESPACE

Creates a new namespace within the specified or default database.

Namespaces group various database components, including tables and views. When not explicitly specified, namespace designations default to `dbo`.

```
<create-namespace> ::= 
  CREATE NAMESPACE [<database>.] <namespace> [ <as-of> ]
```

### Example
```
CREATE NAMESPACE my-namespace
```

### Arguments

** `<database>`**
The database within which to create the namespace. When specified overrides the default database.

If not explicitly qualified, it defaults to the Obelisk agent's current database.

**`<namespace>`**
This is a user-defined name for the new namespace. It must adhere to the hoon term naming standard. 

Note: The "sys" namespace is reserved for system use.

**`<as-of>`**
Timestamp of namespace creation. Defaults to NOW (current time). When specified timestamp must be greater than both the latest database schema and content timestamps.

WARNING: It is possible to future date a `CREATE NAMESPACE`. This will lock all schema and data updates in the database until that future time.

### API
```
+$  create-namespace 
  $:
    %create-namespace
    database-name=@tas 
    name=@tas
    as-of=(unit as-of)
  ==
```

### Remarks

This command mutates the state of the Obelisk agent. However, it does not generate the *state change after query in script* because it is a trivial change that cannot effect a query.

### Produced Metadata

message: CREATE NAMESPACE <name>
server-time: <timestamp>
schema-time: <timestamp>

### Exceptions

schema changes must be by local agent
database `<database>` does not exist
namespace `<namespace>` as-of schema time out of order
namespace `<namespace>` as-of content time out of order
namespace `<namespace>` already exists

## ALTER NAMESPACE

Transfer an existing user `<table>` to another `<namespace>`.

```
<alter-namespace> ::=
  ALTER NAMESPACE [ <database>. ] <namespace>
    TRANSFER TABLE [ <db-qualifier> ] <table>
    [ <as-of> ]
```

### Arguments

**`<namespace>`**
Name of the target namespace into which the object is to be transferred. 

**`TABLE`**
Indicates the type of the target object.

**`<table>`**
Name of the object to be transferred to the target namespace.

**`<as-of>`**
Timestamp of namespace update. Defaults to NOW (current time). When specified, the timestamp must be greater than both the latest database schema and content timestamps. 

### API
```
+$  alter-namespace
  $:  %alter-namespace
    database-name=@tas
    target-namespace=@tas
    =table-or-view
    =qualified-table
    as-of=(unit as-of)
    ==
```

### Remarks
This command mutates the state of the Obelisk agent.

`ALTER NAMESPACE ... TRANSFER TABLE` may move a table between namespaces in the same database, or between namespaces in different user databases. When the transferred table participates in any foreign key (as parent or child), cross-database transfer is rejected; in that case the source table's database and the target namespace's database must match. Foreign-key references involving the transferred table remain valid and are updated to the table's new namespace-qualified identity.

Objects cannot be transferred in or out of database *sys*.

Objects cannot be transferred in or out of namespace *sys*.

### Produced Metadata

action: ALTER NAMESPACE TRANSFER TABLE <table>
server-time: <timestamp>
schema-time: <timestamp>
data-time: <timestamp>

### Exceptions

schema changes must be by local agent
database `<database>` does not exist
namespace `<namespace>` as-of schema time out of order
namespace `<namespace>` as-of content time out of order
namespace `<namespace>` does not exist
alter namespace state change after query in script
`<table>` does not exist
`<table>` already exists in target namespace

## DROP NAMESPACE

Deletes a `<namespace>` and all tables in that namespace.

```
<drop-namespace> ::= 
  DROP NAMESPACE [ FORCE ] [ <database>. ] <namespace>
  [ <as-of> ]
```

### Arguments

**`FORCE`**
Optionally force deletion of `<namespace>`, dropping all tables associated with the namespace.

**`<namespace>`**
The name of `<namespace>` to delete.

**`<as-of>`**
Timestamp of namespace deletion. Defaults to `NOW` (current time). When specified timestamp must be greater than both the latest database schema and content timestamps. 

### API
```
+$  drop-namespace
  $:
    %drop-namespace 
    database-name=@tas 
    name=@tas 
    force=?
    as-of=(unit as-of)
  ==
```

### Remarks

This command mutates the state of the Obelisk agent.

Without `FORCE`, the namespace can be dropped only when all tables in the namespace are empty and dropping those tables would not orphan any foreign keys. An orphan foreign key is a constraint whose parent table is in the dropped namespace while the child table is outside the dropped namespace.

Foreign keys wholly contained within the dropped namespace do not block a non-`FORCE` drop, provided the involved tables are empty. Foreign keys where only the child table is in the dropped namespace also do not block a non-`FORCE` drop, provided the child table is empty.

With `FORCE`, all tables in the namespace are dropped regardless of row counts or foreign-key participation. Foreign-key metadata is cleaned up for all affected surviving tables:

- if parent and child are both dropped, both sides are removed with the tables
- if the parent is dropped and the child remains, the child's outbound foreign-key metadata is removed
- if the child is dropped and the parent remains, the parent's incoming foreign-key metadata is removed

Dropped tables remain available to historical queries when selected with an `AS OF` time before the namespace drop. The same namespace name, and the same table names within that namespace, may be created again after the drop time.

The namespaces *dbo* and *sys* cannot be dropped.

### Produced Metadata

action: DROP NAMESPACE <namespace>
server-time: <timestamp>
schema-time: <timestamp>
data-time: <timestamp>

The result also includes a message for each table dropped by the namespace drop.

### Exceptions

schema changes must be by local agent
database `<database>` does not exist
namespace `<namespace>` does not exist
namespace `<namespace>` as-of schema time out of order
namespace `<namespace>` as-of content time out of order
drop namespace state change after query in script
namespace `<namespace>` cannot be dropped
`<namespace>` has populated tables and `FORCE` was not specified
`<namespace>` would orphan foreign keys and `FORCE` was not specified
`<namespace>` has populated tables and would orphan foreign keys, and `FORCE` was not specified

When the drop would orphan foreign keys, the error message names at least one affected foreign key relationship. If more than one relationship would be orphaned, the message also includes the total count.
