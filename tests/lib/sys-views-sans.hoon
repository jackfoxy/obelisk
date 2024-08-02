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
::
++  test-sys-ns
  =|  run=@ud
  =/  row1  :-  %vector
                :~  [%namespace [~.tas %dbo]]
                    [%tmsp [~.da ~2000.1.1]]
                    ==
  =/  row2  :-  %vector
                :~  [%namespace [~.tas %sys]]
                    [%tmsp [~.da ~2000.1.1]]
                    ==
  =/  row3  :-  %vector
                :~  [%namespace [~.tas %ns1]]
                    [%tmsp [~.da ~2000.1.2]]
                    ==
  ::
  =/  expected  :~  %results
                    :-  %result-set  ~[row1 row2 row3]
                    :-  %server-time  ~2000.1.2
                    :-  %schema-time  ~2000.1.2
                    :-  %data-time  ~2000.1.2
                    :-  %vector-count  3
                ==
  ::
  =^  mov1  agent
    %:  ~(on-poke agent (bowl [run ~2000.1.1]))
        %obelisk-action
        !>([%tape-create-db "CREATE DATABASE db1 AS OF ~2000.1.1"])
    ==
  =.  run  +(run)
  =^  mov2  agent
    %:  ~(on-poke agent (bowl [run ~2000.1.2]))
        %obelisk-action
        !>  :+  %tape
                %db1
                "CREATE NAMESPACE ns1 AS OF ~2000.1.2"
    ==
  =.  run  +(run)
  =^  mov3  agent
    %:  ~(on-poke agent (bowl [run ~2000.1.2]))
        %obelisk-action
        !>([%tape %db1 "FROM sys.namespaces SELECT *"])
    ==
  %+  expect-eq
    !>  expected
    ::!>  ;;(* expected)
    ::!>  ->+>+>-.mov3
    !>  ;;(cmd-result ->+>+>-.mov3)
--