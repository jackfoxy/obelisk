::  Demonstrate unit testing queries on a Gall agent with %obelisk.
::
/-  ast, *obelisk
/+  *test, *sys-views
/=  agent  /app/obelisk
|%
::
::  Build an example bowl manually
++  bowl
  |=  [run=@ud now=@da]
  ^-  bowl:gall
  :*  [~zod ~zod %obelisk `path`(limo `path`/test-agent)]  :: (our src dap sap)
      [~ ~ ~]                                              :: (wex sup sky)
      [run `@uvJ`(shax run) now [~zod %base ud+run]]       :: (act eny now byk)
  ==
::
::  Build a reference state mold
+$  state
  $:  %0
      =databases
      ==
--
|%
::
::  SELECT prior to table existence
++  test-fail-select-01
  =|  run=@ud
  =/  my-select  "FROM my-table SELECT ".
                 "my-table.col4,my-table.col3,my-table.col2,my-table.col1"
  ::
  =^  mov1  agent
    %:  ~(on-poke agent (bowl [run ~2012.4.30]))
        %obelisk-action
        !>([%tape-create-db "CREATE DATABASE db1"])
    ==
  =.  run  +(run)
  =^  mov2  agent
    %:  ~(on-poke agent (bowl [run ~2012.5.1]))
        %obelisk-action
        !>  :+  %tape
                %db1
                "CREATE TABLE db1..my-table ".
                "(col1 @t, col2 @da, col3 @t, col4 @t) ".
                "PRIMARY KEY CLUSTERED (col1) ".
                "AS OF ~2012.5.3"
    ==
    =.  run  +(run)
  =^  mov3  agent
    %:  ~(on-poke agent (bowl [run ~2012.5.2]))
        %obelisk-action
        !>  :+  %tape
                %db1
                "INSERT INTO my-table".
                " VALUES".
                " ('Abby', ~1999.2.19, 'tricolor', 'row1')".
                " ('Ace', ~2005.12.19, 'ticolor', 'row2')".
                " ('Angel', ~2001.9.19, 'tuxedo', 'row3') ".
                "AS OF ~2012.5.4"
    ==
  =.  run  +(run)
  ::
  %+  expect-fail-message
        'table %dbo.%my-table does not exist at schema time ~2012.4.30'
  |.  %:  ~(on-poke agent (bowl [run ~2012.5.2]))
          %obelisk-action
          !>([%tape %db1 my-select])
      ==

--