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
:: successful AS OF insert followed by fail on data time
++  test-fail-insert-12
  =|  run=@ud
  =/  my-insert-1  "INSERT INTO db1..my-table (col1, col2, col3) ".
                   "VALUES ('cord',~nomryg-nilref,20) ('Default',Default, 0) ".
                   "AS OF ~2012.5.5"
  =/  my-insert-2  "INSERT INTO db1..my-table (col1, col2, col3) ".
                   "VALUES ('cord2',~nomryg-nilref,20) ('Default2',Default, 0) "
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
                "(col1 @t, col2 @p, col3 @ud) ".
                "PRIMARY KEY CLUSTERED (col1)"
    ==
  =.  run  +(run)
  =^  mov3  agent
    %:  ~(on-poke agent (bowl [run ~2012.5.2]))
        %obelisk-action
        !>([%tape %db1 my-insert-1])
    ==
  =.  run  +(run)
  ::
  %+  expect-fail-message
        'insert into table %my-table as-of data time out of order'
  |.  %:  ~(on-poke agent (bowl [run ~2012.5.5]))
          %obelisk-action
          !>([%tape %db1 my-insert-2])
      ==

--
