/-  ast, *obelisk
/+  *test
/=  agent  /app/obelisk
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
++  user-data-2  
  [%data ~zod %agent ~2000.1.2 [[[%dbo %my-table] file-1col-1-2] ~ ~]]
++  user-data-1
  [%data ~zod agent=%agent tmsp=~2000.1.1 ~]
++  file-1col-1-2
  [%file ~zod %agent ~2000.1.2 %.y ~[[%t %.y]] ~ 0 [[%col1 [%t 0]] ~ ~] ~]
++  sys1
  [%internals agent=%agent tmsp=~2000.1.1 namespaces=[[p=%dbo q=%dbo] ~ [[p=%sys q=%sys] ~ ~]] tables=~]
::  Create table
++  one-col-tbl-db
  [[%db1 [%db-row name=%db1 created-by-agent=%agent created-tmsp=~2000.1.1 sys=~[one-col-tbl-sys sys1] user-data=~[user-data-2 user-data-1]]] ~ ~]
++  one-col-tbl-sys
  [%internals agent=%agent tmsp=~2000.1.2 namespaces=[[p=%dbo q=%dbo] ~ [[p=%sys q=%sys] ~ ~]] tables=one-col-tbls]
++  one-col-tbls
 [[one-col-tbl-key one-col-tbl] ~ ~]
++  one-col-tbl-key
 [%dbo %my-table]
++  one-col-tbl
  [%table [%index unique=%.y clustered=%.y ~[[%ordered-column name=%col1 ascending=%.y]]] ~[[%column name=%col1 column-type=%t]] ~]
++  cmd-one-col
    [%create-table [%qualified-object ~ 'db1' 'dbo' 'my-table'] ~[[%column 'col1' %t]] %.y ~[[%ordered-column 'col1' %.y]] ~]
::
++  test-cmd-create-1-col-tbl
  =|  run=@ud
  =^  mov1  agent  
    (~(on-poke agent (bowl [run ~2000.1.1])) %obelisk-action !>([%cmd-create-db [%create-database 'db1']]))
  =.  run  +(run)
  =^  mov2  agent  
    (~(on-poke agent (bowl [run ~2000.1.2])) %obelisk-action !>([%commands ~[cmd-one-col]]))
  =+  !<(=state on-save:agent)
  ;:  weld
  %+  expect-eq                         :: expected results
    !>  [%results ~[[%result-da 'system time' ~2000.1.2]]]
    !>  ->+>+>.mov2
  %+  expect-eq                         :: expected state
    !>  one-col-tbl-db
    !>  databases.state
  ==
--