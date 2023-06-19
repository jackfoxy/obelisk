::  Demonstrate unit testing on a Gall agent with %obelisk.
::
/-  ast, *obelisk
/+  *test
/=  agent  /app/obelisk
|%
::  Build an example bowl manually.
::
++  bowl
  |=  run=@ud
  ^-  bowl:gall
  :*  [~zod ~zod %obelisk]     :: (our src dap)
      [~ ~]                     :: (wex sup)
      [run `@uvJ`(shax run) *time [~zod %obelisk ud+run]]
                                :: (act eny now byk)
  ==
::  Build a reference state mold.
::
+$  state
  $:  [%0 =databases]
  ==
--
|%
::  Test adding a watcher to the list.
::
++  db1
    [[%db1 [%db-row name=%db1 created-by-agent=%agent created-tmsp=~2023.6.19..14.22.19..0ca5 sys=~[[%db-internals agent=%agent tmsp=~2023.6.19..14.22.19..0ca5 namespaces=[[p=%dbo q=%dbo] ~ [[p=%sys q=%sys] ~ ~]]]]]] ~ ~]

++  test-add-db1
  =|  run=@ud 
  =^  move  agent  (~(on-poke agent (bowl run)) %obelisk-action !>([%tape-create-db "CREATE DATABASE db1"]))
  =+  !<(=state on-save:agent)
  %+  expect-eq
    !>  [%0 databases=db1]
    !>  databases.state
--