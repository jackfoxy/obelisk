# Permissions
*supported in urQL parser, not yet supported in Obelisk*

## Security Model

1. By default, any agent on the server host ship can create and maintain databases and all objects and content therein.
2. No agent from a foreign ship can ever create a database or alter the schema of an existing database.
3. By default, no agent from a foreign ship has any rights on any database.
4. Granting and revoking rights are explained in the docs for their respective commands.
5. Granting and revoking is effective in server-time and by overriding with `<as-of-time>`.
6. Overriding security events with `<as-of-time>` is subject to the constraint of both the data and schema times.
7. If a view shadows a table, and a security event executes both the named objects are equally effected.
8. Permission objects nest ordered by generality, i.e. in the server object model.
9. Only one security event per user per object per script. It's effectiveness in the script is according to it's placement (execution order).

To Do:
0. cross-database security model
1. Add agent to the security model.
2. Allow revoking of rights by on-ship agent. (for real security this has to be opt-in...do this in create database)

## GRANT

Grants permission to selected foreign ships and local agents to read from and/or write to selected `<database>`, `<namespace>`, `<table-object>`, `view`, objects on host ship.

```
<grant> ::=
  GRANT { ADMINREAD | READONLY | READWRITE }
    TO  { AGENT | ALLAGENT | PARENT | SIBLINGS | MOONS | <@p> [ ,...n ] }
    ON  { DATABASE <database>
         | NAMESPACE [<database>.] <namespace>
         | [<db-qualifier>] { <table-object>
                             | <view>
                             | <column>
                            }
        }
    [ FOR { <@dr> [ [ COMMENCING ] { <@dr> | <as-of-time> } ] }
          | { <as-of-time> TO <as-of-time> }
    ]
    [ <as-of-time> ]
```

### API
```
$:
  %grant
  permission=grant-permission
  to=grantee
  grant-target=grant-object
==
```

### Example

`GRANT READONLY TO ~sampel-palnet ON NAMESPACE my-namespace`

### Arguments

**ADMINREAD**
Grants read permission on `<database>.sys` tables and views.
The `ON` clause must be `<database>`.

**READONLY**
Grants read-only permission on selected object.

**READWRITE**
Grants read and write permission on selected object.

**PARENT**
Grantee is parent of ship on which Obelisk agent is running.

**SIBLINGS**
Grantees are all other moons of the parent of ship on which Obelisk agent is running.

**MOONS**
Grantees are all moons of the ship on which Obelisk agent is running.

**<@p> [ ,...n ]**
List of ships to grant permission to.

**`<database>`**
Grant permission on named database to all `<table>s` and `<view>`s.

**`[<database>.]<namespace>`**
Grant permission on named namespace to all `<table>s` and `<view>`s.

**`[<db-qualifier>] { <table-object> | <view> | <column> }`**
Grant permission is on named object.

### Remarks

This command mutates the state of the Obelisk agent.

Write permission includes `DELETE`, `INSERT`, `UPDATE` and `TRUNCATE TABLE`.

When a granted database object is dropped, all applicable `GRANT`s are also dropped.

`<table-object>` remains valid whether a `<view>` is shadowing a `<table>` or not.
In the case where a shadowing `<view>` is dropped, the grant then applies to the `<table>`. In the case where a new `<view>` shadows a granted `<table>`, the grant applies to both named objects.

### Produced Metadata

< message "INSERT grantee, grant, target INTO `<database>.sys.grants`" >
<security-time>
<schema-time>
<data-time>

### Exceptions

grant permissions must be by local agent
`<database>` does not exist.
`<namespace>` does not exist.
`<table-object>` does not exist.
`GRANT` target type does not exist. (e.g. host is a `MOON` and `GRANT` is `ON MOONS`)


## REVOKE

Revokes permission to read from and/or write to selected database objects on the host ship to selected foreign ships.

```
<revoke> ::=
  REVOKE { AGENT | ALLAGENT | ADMINREAD | READONLY | READWRITE | ALL }
  FROM   { PARENT | SIBLINGS | MOONS | ALL | <@p> [ ,...n ] }
    ON   { DATABASE <database>
          | NAMESPACE [<database>.] <namespace>
          | [<db-qualifier>] { <table-object>
                              | <view>
                              | <column>
                             }
         }
    [ FOR { <@dr> [ [ COMMENCING ] { <@dr> | <as-of-time> } ] }
          | { <as-of-time> TO <as-of-time> }
    ]
    [ <as-of-time> ]
```


### API
```
+$  revoke
  $:
    %revoke
    permission=revoke-permission
    from=revoke-from
    revoke-target=revoke-object
  ==
```

### Arguments

**ADMINREAD**
Revokes read permission on `<database>.sys` tables and views. The `ON` clause must be `<database>`.

**READONLY**
Revokes read-only permission on selected object.

**READWRITE**
Revokes read and write (DELETE, INSERT, UPDATE) permission on selected object.

**PARENT**
The grantee is the parent of the ship on which the Obelisk agent is running.

**SIBLINGS**
The grantees are all other moons of the parent of the ship on which the Obelisk agent is running, which is also a moon.

**MOONS**
The grantees are all moons of the ship on which the Obelisk agent is running.

**<@p> [ ,...n ]**
List of ships from which permission will be revoked.

**`<database>`**
Revoke permission on the named database.

**`[<database>.]<namespace>`**
Revoke permission on named namespace.

**`[<db-qualifier>] { <table-object> | <view> | <column> }`**
Revoke permission is on named object.

### Remarks

This command mutates the state of the Obelisk agent.

*See remarks on GRANT.*

### Produced Metadata

< message "REVOKE grantee, grant, target FROM `<database>.sys.grants`" >
<security-time>
<schema-time>
<data-time

### Exceptions

revoke permissions must be by local agent
`REVOKE` does not exist.
