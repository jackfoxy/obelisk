# DDL: Database

## CREATE DATABASE

Creates a new user-space database on the ship.

```
<create-database> ::=
  CREATE DATABASE <database> [ <as-of-time> ]
```

### API
```
+$  create-database
  $:
    %create-database
    name=@tas
    as-of=(unit <as-of>)
  ==
```

### Arguments

**`<database>`**
The user-defined name for the new database. It must comply with the Hoon term naming standard. 

**`<as-of-time>`**
Timestamp of database creation. Defaults to `NOW` (current time). Subsequent DDL and data actions must have timestamps greater than this timestamp. 

### Remarks

This command mutates the state of the Obelisk agent. It inserts a row into the view `sys.sys.databases`.

### Produced Metadata

Schema timestamp
Content timestamp

### Exceptions

database must be created by local agent
database name cannot be 'sys'
database `<database>` already exists'

### Example
```
  CREATE DATABASE my-database
```

## DROP DATABASE

*supported in urQL parser, not yet supported in Obelisk*

Deletes an existing `<database>` and all associated objects.
```
<drop-database> ::= DROP DATABASE [ FORCE ] <database>
```

### API
```
+$  drop-database        
  $: 
    %drop-database
    name=@tas
    force=?
  ==
```

### Arguments

**`FORCE`**
Optionally, force deletion of a database.

**`<database>`**
The name of the database to delete.

## Remarks
This command mutates the state of the Obelisk agent.

The command only succeeds when no populated tables exist in the database, unless `FORCE` is specified.

Dropping a database is permanent and leaves no trace of the database for time travel transactions. It removes the row from the `sys.sys.databases` view.

If the database only contains future dated content. The `DROP` command will succeed without requiring `FORCE`.

## Produced Metadata
Schema timestamp
Content timestamp

## Exceptions
database must be dropped by local agent
database %sys cannot be dropped
database `<database>` does not exist
`<database>` has populated tables and `FORCE` was not specified
state change after query in script