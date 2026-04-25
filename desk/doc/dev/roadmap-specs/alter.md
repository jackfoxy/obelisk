

# ALTER PROCEDURE

TBD

```
<alter-proc> ::=
  ALTER { PROC | PROCEDURE }
    [<db-qualifer>]<procedure>
    [ { #<parameter> <data-type> } ] [ ,...n ]
  AS { <urql command>; | *hoon } [ ;...n ]
```

# ALTER TRIGGER

TBD

```
<alter-trigger> ::=
  ALTER TRIGGER { [ <db-qualifer> ]{ <trigger> } | ALL }
     ON { SERVER | <database.name> | <table> | <view> }
     [ ENABLE | DISABLE ]
```

# ALTER VIEW
Alter the structure of an existing `<view>`.

```
<alter-view> ::=
  ALTER VIEW [ <db-qualifer> ]{ <view> }
    ( { [<alias>.] <column> } [ ,...n ] )
  AS <select_statement>
```

## API
```
+$  alter-view
  $:
    %alter-view
    view=qualified-object
    crud-txn
  ==
```

## Arguments

**`<view>`**
Specifies the name of the view to alter.

**`<crud-txn>`**
Refers to the `<crud-txn>` producing the output `<relation>`.

## Remarks
This command mutates the state of the Obelisk agent.

## Produced Metadata
UPDATE `<database>.sys.views`
UPDATE `<database>.sys.view-columns`

## Exceptions
view does not exist.