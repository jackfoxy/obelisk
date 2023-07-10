::  unit tests on %obelisk library simulating pokes
::
/-  ast, *obelisk
/+  *test
|%
::  Build an example bowl manually.
::
++  bowl
  |=  [run=@ud now=@da]
  ^-  bowl:gall
  :*  [~zod ~zod %obelisk]                            :: (our src dap)
      [~ ~ ~]                                         :: (wex sup sky)
      [run `@uvJ`(shax run) now [~zod %base ud+run]]  :: (act eny now byk)
  ==
::  Build a reference state mold.
::
+$  state
  $:  %0 
      =databases
      ==
--
|%
++  internals-ns
  [n=[p=%dbo q=%dbo] l=~ r=[n=[p=%sys q=%sys] l=~ r=~]]
++  internals-my-table
  [p=[%dbo %my-table] q=[%table pri-indx=[%index unique=%.y clustered=%.y columns=~[[%ordered-column name=%col1 is-ascending=%.y]]] columns=~[[%column name=%col1 type=%t]] indices=~]]
++  internals-table-3
  [p=[%dbo %my-table-3] q=[%table pri-indx=pri-indx-table-3 columns=~[[%column name=%col1 type=%t] [%column name=%col2 type=%p] [%column name=%col3 type=%ud]] indices=~]]
++  pri-indx-table-3
  [%index unique=%.y clustered=%.y columns=~[[%ordered-column name=%col1 is-ascending=%.y] [%ordered-column name=%col3 is-ascending=%.n]]]
::
++  file-my-table
  [p=[%dbo %my-table] q=[%file ship=~zod agent=%agent tmsp=~2023.7.9..22.27.32..49e3 clustered=%.y key=~[[%t %.y]] pri-idx=~ length=0 column-lookup=[n=[p=%col1 q=[%t 0]] l=~ r=~] data=~]]
++  file-my-table-3
  [p=[%dbo %my-table-3] q=[%file ship=~zod agent=%agent tmsp=~2023.7.9..22.35.34..7e90 clustered=%.y key=~[[%t %.y] [%ud %.n]] pri-idx=~ length=0 column-lookup=col-lu-table-3 data=~]]
++  col-lu-table-3
  [n=[p=%col3 q=[%ud 2]] l=[n=[p=%col2 q=[%p 1]] l=~ r=~] r=[n=[p=%col1 q=[%t 0]] l=~ r=~]]
::
++  gen0-intrnl
  [%internals agent=%agent tmsp=~2023.7.9..22.24.54..4b8a namespaces=internals-ns tables=~]
++  gen1-intrnl
  [%internals agent=%agent tmsp=~2023.7.9..22.27.32..49e3 namespaces=internals-ns tables=[n=internals-my-table l=~ r=~]]
++  gen2-intrnl
  [%internals agent=%agent tmsp=~2023.7.9..22.35.34..7e90 namespaces=internals-ns tables=[n=internals-my-table l=[n=internals-table-3 l=~ r=~] r=~]]
::
++  gen0-data
  [%data ship=~zod agent=%agent tmsp=~2023.7.9..22.24.54..4b8a files=~]
++  gen1-data
  [%data ship=~zod agent=%agent tmsp=~2023.7.9..22.27.32..49e3 files=[n=file-my-table l=~ r=~]]
++  gen2-data
  [%data ship=~zod agent=%agent tmsp=~2023.7.9..22.35.34..7e90 files=[n=file-my-table l=[n=file-my-table-3 l=~ r=~] r=~]]
::
++  start-db1-row
  [%db-row name=%db1 created-by-agent=%agent created-tmsp=~2023.7.9..22.24.54..4b8a sys=~[gen2-intrnl gen1-intrnl gen0-intrnl] user-data=~[gen2-data gen1-data gen0-data]]
++  start-dbs
[n=[p=%db1 q=start-db1-row] l=~ r=~]
::


++  test-tape-create-db
  =|  run=@ud 
::  =^  move  agent  
::    (~(on-poke agent (bowl [run ~2000.1.1])) %obelisk-action !>([%tape-create-db "CREATE DATABASE db1"]))
::  =+  !<(=state on-save:agent)
  ;:  weld
  %+  expect-eq                         :: expected results
    !>  [%results ~['success']]
    !>  ->+>+>.move
  %+  expect-eq                         :: expected state
    !>  db1
    !>  databases.state
  ==
