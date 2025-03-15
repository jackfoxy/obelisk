# Security and Permissions
*supported in urQL parser, not yet supported in Obelisk*

## Security Model

*prelinary security model, not implemented in Obelisk engine yet

1. By default, any agent on the server host ship can create and maintain databases and has full read and write permissions on all objects and content in any local database.
2. By default, no agent from a foreign ship has any rights on any database.
3. No agent from a foreign ship can ever create a database or alter the schema of an existing database.
4. Granting and revoking is effective in server-time and applies to all objects regardless of chronology.
5. If a view shadows a table, and a security event executes on the name, both the named objects are equally effected.
6. Permissions on objects nest by generality as per the server object model.
7. Scripts containing security events may only contain security events.
8. Nested permissions are progressively more permissive in permission and/or granular in grantee.
9. If two nested permissions are for the same @p, or the outer *grantee* is more generally the case for the inner @p, and the grant object nests, the inner permission must be more or equally permissive. ADMINREAD < READONLY < INSERT <= UPDATE <= DELETE < READWRITE
10. Security permissions are outside the scope of time indexing and apply in real time.

Permission updating takes place through GRANT and REVOKE commands. GRANT adds permissions to foreign ships, possibly restricted by path, and to previously restricted local paths. REVOKE removes permissions from previously allowed foreign ships, possibly restricted by path, and from local paths.

Permissions may grant access to foreign ships based on their relation to the host ship (parent, moons, siblings -- applies to moon host only) or as ship @p, optionally qualified by an agent or shrubbery path.

The object of a permission may be the whole server (the databases currently on the server), a database, a namespace, a table set (table or view), or a table set column.

Granting and revoking permissions may be qualified be a timespan constraint.

## GRANT

Grants permission to selected foreign ships and/or paths on foreign ships to read from and/or write to the server or selected `<database>`, `<namespace>`, `<table-set>`, or column objects on the host ship.

Grant will also restore a permission to a local path previously revoked.
```
<grant> ::=
  GRANT { ADMINREAD
          | READONLY
          | READWRITE
          | INSERT
          | UPDATE
          | DELETE
        }
    TO  <security-group>
        | { PARENT      [ <path> ]
            | SIBLINGS  [ <path> ]
            | MOONS     [ <path> ]
            | <@p>      [ <path> ]
            | our <path>
          } [ ,...n ]
    ON  { SERVER
          | <security-target>
          | { DATABASE <database>
              | NAMESPACE [<database>.] <namespace>
              | <table-set>
              | /<db>/<namespace>/<table-set-name>/<column-name>
            } [ ,...n ]
        }
    [ FOR { <@dr> [ [ STARTING ] <@da> ] }
          | { <@da> TO <@da> }
    ]
```

### API
```
$:
  %grant
  permission=grant-permission
  grantees=(list [dime (unit path)])
  grant-objects=(list grant-object)
  duration=(unit sec-time)
==
```

### Example

`GRANT READONLY TO ~sampel-palnet ON NAMESPACE my-namespace`

### Arguments

**ADMINREAD**
Grants read permission on `<database>.sys` views. Read persmission is further restricted by permitted GRANT objects. For instance if permission is only granted on one table set, ADMINREAD is restricted to sys view results on that object.

**READONLY**
Grants read-only permission on selected object(s).

**READWRITE**
Grants read and write permission on selected object(s).

**INSERT**
Insert only permission.
*not implemented in parser*

**UPDATE**
Update only permission.
*not implemented in parser*

**DELETE**
Delete only permission.
*not implemented in parser*

**PARENT [ <path> ]**
Grantee is parent of ship on which Obelisk agent is running, optionally restricted to a path or agent.

**SIBLINGS [ <path> ]**
Grantees are all other moons of the parent of ship on which Obelisk agent is running, optionally restricted to a path or agent.

**MOONS [ <path> ]**
Grantees are all moons of the ship on which Obelisk agent is running, optionally restricted to a path or agent.

**<@p> [ <path> ]**
Ship to grant permission to, optionally restricted to a path or agent.

**our <path>**
Path or agent on local ship.

**SERVER**
Grant permission on all databases currently on the server.

**`<database>`**
Grant permission on named database to all `<table>s` and `<view>`s.

**`[<database>.]<namespace>`**
Grant permission on named namespace to all `<table>s` and `<view>`s.

**`[<db-qualifier>] { <table-set> | <view> | <column> }`**
Grant permission is on named object.

### Remarks

This command mutates the state of the Obelisk agent.

Security permissions are outside the scope of time travelling. This means the current security state is uniformally enforced. 

Write permission includes `INSERT`, `UPDATE`, `DELETE`, and `TRUNCATE TABLE`.

If a database object is dropped and then recreated with the same name, all currently applicable permissions continue to apply.

`<table-set>` applies whether a `<view>` is shadowing a `<table>` or not.
In the case where a shadowing `<view>` is dropped while a GRANT or REVOKE is in effect, the permission applies to the `<table>`. In the case where a new `<view>` shadows a granted `<table>` while a GRANT or REVOKE is in effect, the permission applies to both named objects.

### Produced Metadata

< message "INSERT grantee, grant, target INTO `<database>.sys.grants`" >
<security-time>
<schema-time>
<data-time>

### Exceptions

grant permissions must be by local agent
`<database>` does not exist.
`<namespace>` does not exist.
`<table-set>` does not exist.
`GRANT` target type does not exist. (e.g. host is a `MOON` and `GRANT` is `ON MOONS`)


## REVOKE

Revokes permission to selected foreign ships and local paths to read from and/or write to the server, selected `<database>`, `<namespace>`, `<table-set>`, `view`, or column objects on the host ship.

```
<revoke> ::=
  REVOKE { ALL
           | ADMINREAD
           | READONLY
           | READWRITE
           | INSERT
           | UPDATE
           | DELETE
         }
  FROM   { ALL         [ <path> ]
           | PARENT    [ <path> ]
           | SIBLINGS  [ <path> ]
           | MOONS     [ <path> ]
           | <@p>      [ <path> ]
           | our <path>
         } [ ,...n ]
    ON   SERVER
         | { DATABASE <database>
             | NAMESPACE [<database>.] <namespace>
             | <table-set>
             | /<db>/<namespace>/<table-set-name>/<column-name>
           } [ ,...n ]
    [ FOR { <@dr> [ [ STARTING ] <@da> ] }
          | { <@da> TO <@da> }
    ]
```

### API
```
+$  revoke
  $:
    %revoke
    permission=revoke-permission
    from=(list [dime (unit path)])
    revoke-target=(list revoke-object)
    duration=(unit sec-time)
  ==
```

### Arguments

**ADMINREAD**
Revokes read permission on `<database>.sys` tables and views.

**READONLY**
Revokes read-only permission on selected object.

**READWRITE**
Revokes read and write (DELETE, INSERT, UPDATE) permission on selected object.

**INSERT**
Revokes insert permission.
*not implemented in parser*

**UPDATE**
Revokes update permission.
*not implemented in parser*

**DELETE**
Revokes delete permission.
*not implemented in parser*


**PARENT [ <path> ]**
Revokes rights from all foreign ships currently granted rights, optionally restricted to a path or agent.

**PARENT [ <path> ]**
Revokes right from the parent of the ship on which the Obelisk agent is running, optionally restricted to a path or agent.

**SIBLINGS [ <path> ]**
Revokes right from all other moons of the parent of the ship on which the Obelisk agent is running, which is also a moon, optionally restricted to a path or agent.

**MOONS [ <path> ]**
Revokes right from all moons of the ship on which the Obelisk agent is running, optionally restricted to a path or agent.

**<@p>  [ <path> ]**
List of ships from which permission will be revoked, optionally restricted to a path or agent.

**our <path>**
Path or agent on local ship.

**`<database>`**
Revoke permission on the named database.

**`[<database>.]<namespace>`**
Revoke permission on named namespace.

**`[<db-qualifier>] { <table-set> | <view> | <column> }`**
Revoke permission is on named object.

### Remarks

*See remarks on GRANT.*

### Produced Metadata

< message "REVOKE grantee, grant, target FROM `<database>.sys.grants`" >
<security-time>
<schema-time>
<data-time

### Exceptions

revoke permissions must be by local agent
`REVOKE` does not exist.

## CREATE SECURITY-GROUP

*not yet supported in urQL parser or Obelisk engine*

<security-group> ::=
  CREATE SECURITY-GROUP
    { PARENT      [ <path> ]
      | SIBLINGS  [ <path> ]
      | MOONS     [ <path> ]
      | <@p>      [ <path> ]
      | our <path>
    } [ ,...n ]

## SECURITY-TARGET

*not yet supported in urQL parser or Obelisk engine*

<security-target> ::=
  CREATE SECURITY-TARGET
    { DATABASE <database>
      | NAMESPACE [<database>.] <namespace>
      | <table-set>
      | /<db>/<namespace>/<table-set-name>/<column-name>
    } [ ,...n ]
