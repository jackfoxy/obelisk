# DDL: Namespace

## CREATE NAMESPACE

Creates a new namespace within the specified or default database.

Namespaces group various database components, including tables and views. When not explicitly specified, namespace designations default to `dbo`.

```
<create-namespace> ::= 
  CREATE NAMESPACE [<database>.] <namespace> [ <as-of-time> ]
```

### API
```
+$  create-namespace 
    database-name=@tas 
    name=@tas
    as-of=(unit as-of)
  ==
```

### Arguments

** `<database>`**
The database within which to create the namespace. When specified overrides the default database.

If not explicitly qualified, it defaults to the Obelisk agent's current database.

**`<namespace>`**
This is a user-defined name for the new namespace. It must adhere to the hoon term naming standard. 

Note: The "sys" namespace is reserved for system use.

**`<as-of-time>`**
Timestamp of namespace creation. Defaults to NOW (current time). When specified timestamp must be greater than both the latest database schema and content timestamps.

WARNING: It is possible to future date a `CREATE NAMESPACE`. This will lock all schema and data updates in the database until that future time.

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

### Example
`CREATE NAMESPACE my-namespace`

## ALTER NAMESPACE

*supported in urQL parser, not yet supported in Obelisk*

Transfer an existing user `<table>` or `<view>` to another `<namespace>`.

```
<alter-namespace> ::=
  ALTER NAMESPACE [ <database>. ] <namespace>
    TRANSFER { TABLE | VIEW } [ <db-qualifer> ]{ <table> | <view> }
    [ <as-of-time> ]
```

### API
```
+$  alter-namespace
  $:  %alter-namespace
    database-name=@tas
    source-namespace=@tas
    object-type=object-type
    target-namespace=@tas
    target-name=@tas
    as-of=(unit as-of)
  ==
```

### Arguments

**`<namespace>`**
Name of the target namespace into which the object is to be transferred. 

**`TABLE | VIEW`**
Indicates the type of the target object.

**`<table> | <view>`**
Name of the object to be transferred to the target namespace.

**`<as-of-time>`**
Timestamp of namespace update. Defaults to NOW (current time). When specified, the timestamp must be greater than both the latest database schema and content timestamps. 

### Remarks
This command mutates the state of the Obelisk agent.

Objects cannot be transferred in or out of namespace *sys*.

### Produced Metadata
Schema timestamp

### Exceptions

schema changes must be by local agent
database `<database>` does not exist
namespace `<namespace>` as-of schema time out of order
namespace `<namespace>` as-of content time out of order
namespace `<namespace>` does not exist
alter namespace state change after query in script
`<table>` or `<view>` does not exist

## DROP NAMESPACE

*supported in urQL parser, not yet supported in Obelisk*

Deletes a `<namespace>` and all its associated objects when `FORCE` specified.

```
<drop-namespace> ::= 
  DROP NAMESPACE [ FORCE ] [ <database>. ] <namespace>
  [ <as-of-time> ]
```

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

### Arguments

**`FORCE`**
Optionally force deletion of `<namespace>`, dropping all objects associated with the namespace.

**`<namespace>`**
The name of `<namespace>` to delete.

**`<as-of-time>`**
Timestamp of namespace deletion. Defaults to `NOW` (current time). When specified timestamp must be greater than both the latest database schema and content timestamps. 

### Remarks

This command mutates the state of the Obelisk agent.

Only succeeds when no *populated* `<table>`s are in the namespace, unless `FORCE` is specified, possibly resulting in cascading object drops described in `DROP TABLE`.

The namespaces *dbo* and *sys* cannot be dropped.

### Produced Metadata

Schema timestamp

### Exceptions

schema changes must be by local agent
namespace `<namespace>` does not exist
namespace `<namespace>` as-of schema time out of order
namespace `<namespace>` as-of content time out of order
drop namespace state change after query in script
`<namespace>` has populated tables and `FORCE` was not specified.
