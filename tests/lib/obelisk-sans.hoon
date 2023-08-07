::  unit tests on %obelisk library simulating pokes
::
/-  ast, *obelisk
/+  *test, *obelisk, parse
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
::
::
++  internals-ns
  [n=[p=%dbo q=~2023.7.9..22.24.54..4b8a] l=~ r=[n=[p=%sys q=~2023.7.9..22.24.54..4b8a] l=~ r=~]]
++  internals-my-table
  [p=[%dbo %my-table] q=[%table agent=%agent tmsp=~2023.7.9..22.24.54..4b8a pri-indx=[%index unique=%.y clustered=%.y columns=~[[%ordered-column name=%col1 is-ascending=%.y]]] columns=~[[%column name=%col1 type=%t]] indices=~]]
++  internals-table-3
  [p=[%dbo %my-table-3] q=[%table agent=%agent tmsp=~2023.7.9..22.24.54..4b8a pri-indx=pri-indx-table-3 columns=~[[%column name=%col1 type=%t] [%column name=%col2 type=%p] [%column name=%col3 type=%ud]] indices=~]]
++  pri-indx-table-3
  [%index unique=%.y clustered=%.y columns=~[[%ordered-column name=%col1 is-ascending=%.y] [%ordered-column name=%col3 is-ascending=%.n]]]
::
++  file-my-table
  [p=[%dbo %my-table] q=[%file ship=~zod agent=%agent tmsp=~2023.7.9..22.27.32..49e3 clustered=%.y length=0 column-lookup=[n=[p=%col1 q=[%t 0]] l=~ r=~] key=~[[%t %.y]] pri-idx=~ data=~]]
++  file-my-table-3
  [p=[%dbo %my-table-3] q=[%file ship=~zod agent=%agent tmsp=~2023.7.9..22.35.34..7e90 clustered=%.y length=0 column-lookup=col-lu-table-3 key=~[[%t %.y] [%ud %.n]] pri-idx=~ data=~]]
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
::

::
::  select one literal 
++  test-select-1-literal
  =|  run=@ud 
  =/  my-select  "SELECT 0"
  =/  x  (process-cmds [start-dbs (bowl [run ~2023.2.1]) (parse:parse(default-database 'db1') my-select)])
  %+  expect-eq                         
    !>  [%results ~[[%result-set qualifier=~.literals columns=~[[%literal-0 %ud]] data=[i=~[0] t=~]]]]         :: expected results
    !>  -.x
::
::  select all literals mixed with aliases
++  test-select-literals
  =|  run=@ud 
  =/  my-select  "SELECT 'cord',~nomryg-nilref,nomryg-nilref,~2020.12.25..7.15.0..1ef5,2020.12.25..7.15.0..1ef5,".
"~d71.h19.m26.s24..9d55, d71.h19.m26.s24..9d55,.195.198.143.90,.0.0.0.0.0.1c.c3c6.8f5a,y,n,Y,N,".
"2.222,2222,195.198.143.900,.3.14,.-3.14,~3.14,~-3.14,0x12.6401,10.1011,-20,--20,e2O.l4Xpm,pm.l4e2O.l4Xpm"
  =/  x  (process-cmds [start-dbs (bowl [run ~2023.2.1]) (parse:parse(default-database 'db1') my-select)])
  ~&  >  -.x
  %+  expect-eq                         
    !>  [%results ~[[%result-set qualifier=~.literals columns=~[[%literal-0 %ud]] data=[i=~[0] t=~]]]]         :: expected results
    !>  -.x
--
