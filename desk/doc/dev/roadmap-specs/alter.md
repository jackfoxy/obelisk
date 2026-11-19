

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

