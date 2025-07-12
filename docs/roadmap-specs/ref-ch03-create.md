
# CREATE PROCEDURE
Procedures are parameterized urQL scripts. 

```
<create-proc> ::=
  CREATE { PROC | PROCEDURE }
      [<db-qualifer>]<procedure>
      [ { #<parameter> <data-type> } ] [ ,...n ]
  AS { <urql command>; | *hoon } [ ;...n ]
```

## Remarks
TBD

Cannot be used to create a database.

# CREATE TRIGGER

A trigger automatically runs when a specified table or view event occurs in the Obelisk agent. It runs a previously defined `<procedure>`.

An `INSTEAD OF` trigger fires before the triggering event can occur and replaces it. Otherwise the procedure runs after the triggering event succedes and all state changed by both the triggering event and trigger `<procedure>` is included in one and the same state change.

Triggering events are `INSERT`, `UPDATE`, and `DELETE` statements on a `<table>` and simple execution in the case of `<view>`.

```
<create-trigger> ::=
  CREATE TRIGGER [ <db-qualifer> ]<trigger>
    ON { <table> | <view> }
    { AFTER | INSTEAD OF }   
      { [ INSERT ] [ , ] [ UPDATE ] [ , ] [ DELETE ] }
  AS <procedure>
  [ ENABLE | DISABLE ]
```

## Remarks
TBD

This command could be used to trigger any database process or agent.

# CREATE TYPE

TBD

`CREATE TYPE <type>`

# CREATE VIEW
A view creates a `<table-set>` whose contents (columns and rows) are defined by a `<selection>`.

The possibility of caching of views is TBD.

```
<create-view> ::=
  CREATE VIEW [ <db-qualifer> ]<view> AS <selection>
```

## API
```
+$  create-view
  $:
    %create-view
    view=qualified-object
    query=selection
  ==
```

## Arguments

**`<view>`**
The user-defined name for the new view, which must adhere to the Hoon term naming standard.

**`<selection>`**
The `<selection>` that produces the output `<table-set>`.

## Remarks
This command mutates the state of the Obelisk agent.

Views are read only.

The final step of the `<selection>` must establish unique column names, whether inherited from prior `<table-set>`s or aliased columns.

Views cannot be defined on foreign ship databases.

## Produced Metadata

## Examples

INSERT `name`, `<selection>`, `<timestamp>` INTO `<database>.sys.views`
INSERT `name`, `<ordinal>`, `<column>` INTO `<database>.sys.view-columns`

## Exceptions

view already exists
