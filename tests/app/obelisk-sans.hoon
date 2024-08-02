::  Demonstrate unit testing on a Gall agent with %obelisk.
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
::  fail on changing state after select in script
++  test-fail-insert-05
  =|  run=@ud
  =^  mov1  agent
    %:  ~(on-poke agent (bowl [run ~2000.1.1]))
        %obelisk-action
        !>([%tape-create-db "CREATE DATABASE db1"])
    ==
  =.  run  +(run)
  ::
  %+  expect-fail-message
        'insert state change after query in script'
  |.  %:  ~(on-poke agent (bowl [run ~2000.1.2]))
      %obelisk-action
      !>  :+  %tape
              %db1
              "CREATE TABLE db1..my-table (col1 @t) PRIMARY KEY (col1); ".
              "SELECT 0;".
              "INSERT INTO db1..my-table (col1) VALUES ('cord') "
    ==
--
