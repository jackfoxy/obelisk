# Permissions
*supported in urQL parser, not yet supported in Obelisk*

## GRANT

Grants permission to selected foreign ships to read from and/or write to selected `<database>`, `<namespace>`, or `<table-object>` objects on host ship.

### Security Model

1. By default, any agent on the host ship can create and maintain databases and all objects and content therein.
2. No agent from a foreign ship can ever create a database or alter the schema of an existing database.
3. By default, no agent from a foreign ship has any rights on any database.
4. Granting and revoking rights are explained in the docs for their respective commands.
5. Granting and revoking is effective in real-time, outside the scope of `<as-of-time>`.

To Do:
0. cross-database security model
1. Add agent to the security model.
2. Allow revoking of rights by on-ship agent. (for real security this has to be opt-in...do this in create database)

### AST
```
<grant> ::=
  GRANT { ADMINREAD | READONLY | READWRITE }
    TO { PARENT | SIBLINGS | MOONS | <@p> [ ,...n ] }
    ON { DATABASE <database>
        | NAMESPACE [<database>.] <namespace>
        | [<db-qualifier>] <table-object> 
      }
```

### Example

`GRANT READONLY TO ~sampel-palnet ON NAMESPACE my-namespace`

### API
```
$:
  %grant
  permission=grant-permission
  to=grantee
  grant-target=grant-object
==
```

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

**`[<db-qualifer>]<table-object>`**
Grant permission is on named object, whether is is a `<table>` or `<view>`.

### Remarks

This command mutates the state of the Obelisk agent.

Write permission includes `DELETE`, `INSERT`, and `UPDATE`.

When a granted database object is dropped, all applicable `GRANT`s are also dropped.

`<table-object>` remains valid whether a `<view>` is shadowing a `<table>` or not.
In the case where a shadowing `<view>` is dropped, the grant then applies to the `<table>`. In the case where a new `<view>` shadows a granted `<table>`, the grant newly applies to the `<view>`.


### Produced Metadata

INSERT grantee, grant, target, `<timestamp>` INTO `<database>.sys.grants`

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
  REVOKE { ADMINREAD | READONLY | READWRITE | ALL }
  FROM { PARENT | SIBLINGS | MOONS | ALL | <@p> [ ,...n ] }
    ON { DATABASE <database>
          | NAMESPACE [<database>.] <namespace>
          | [<db-qualifier>] <table-object> 
        }
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

**`[<db-qualifer>]<table-object>`**
Revoke permission is on named object, whether it is a `<table>` or `<view>`.

### Remarks

This command mutates the state of the Obelisk agent.

### Produced Metadata

DROP grantee, grant, target FROM `<database>.sys.grants`

### Exceptions

revoke permissions must be by local agent
`GRANT` does not exist.
