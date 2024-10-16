
# DROP TRIGGER

TBD

```
<drop-trigger> ::= 
  DROP TRIGGER   [ <db-qualifer> ]{ <trigger> }
    ON { <table> | <view> }
```


# DROP TYPE

TBD

`DROP TYPE <type>`


## Remarks
Cannot drop if type-name is in use.


# DROP VIEW

```
<drop-view> ::= DROP VIEW [ FORCE ] [ <db-qualifer> ]<view>
```


## API
```
+$  drop-view
  $:
    %drop-view
    view=qualified-object
    force=?
  ==
```

## Arguments

**`FORCE`**
Force delete of `<view>`.

**`<view>`**
Name of `<view>` to delete.

## Remarks
This command mutates the state of the Obelisk agent.

Views that are in use in another view cannot be dropped unless `FORCE` is specified, which may result in cascading object drops.

## Produced Metadata
DELETE from `<database>.sys.views`.

## Exceptions
`<view>` does not exist.
`<view>` is in use by other `<view>` and FORCE was not specified.
