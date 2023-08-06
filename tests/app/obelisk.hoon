::  Demonstrate unit testing on a Gall agent with %obelisk.
::
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
++  db1
  [[%db1 [%db-row name=%db1 created-by-agent=%agent created-tmsp=~2000.1.1 sys=~[sys1] user-data=~[user-data-1]]] ~ ~]
++  sys1
  [%internals agent=%agent tmsp=~2000.1.1 namespaces=[[p=%dbo q=~2000.1.1] ~ [[p=%sys q=~2000.1.1] ~ ~]] tables=~]
++  sys2
  [%internals agent=%agent tmsp=~2000.1.2 namespaces=[[p=%ns1 q=~2000.1.2] ~ [[p=%dbo q=~2000.1.1] ~ [[p=%sys q=~2000.1.1] ~ ~]]] tables=~]
++  user-data-1
  [%data ~zod agent=%agent tmsp=~2000.1.1 ~]
++  user-data-1-a
  [%data ~zod agent=%agent tmsp=~2000.1.3 ~]
++  user-data-2  
  [%data ~zod %agent ~2000.1.2 [[[%dbo %my-table] file-1col-1-2] ~ ~]]
++  user-data-3  
  [%data ~zod %agent ~2000.1.3 [[[%dbo %my-table-2] file-2col-1-3] ~ [[[%dbo %my-table] file-1col-1-2] ~ ~]]]
++  user-data-3-a
  [%data ~zod %agent ~2000.1.2 [[[%dbo %my-table-2] file-2col-1-2] ~ [[[%dbo %my-table] file-1col-1-2] ~ ~]]]

++  file-1col-1-2
  [%file ~zod %agent ~2000.1.2 %.y 0 [[%col1 [%t 0]] ~ ~] ~[[%t %.y]] ~ ~]

++  file-2col-1-2
  [%file ~zod %agent ~2000.1.2 %.n 0 [[%col2 [%p 1]] ~ [[%col1 [%t 0]] ~ ~]] ~[[%t %.y] [%p %.y]] ~ ~]

++  file-2col-1-3
  [%file ~zod %agent ~2000.1.3 %.n 0 [[%col2 [%p 1]] ~ [[%col1 [%t 0]] ~ ~]] ~[[%t %.y] [%p %.y]] ~ ~]

++  db2
  [[%db1 [%db-row name=%db1 created-by-agent=%agent created-tmsp=~2000.1.1 sys=~[sys2 sys1] user-data=~[user-data-1]]] ~ ~]
::  Create database
++  test-tape-create-db
  =|  run=@ud 
  =^  move  agent  
    (~(on-poke agent (bowl [run ~2000.1.1])) %obelisk-action !>([%tape-create-db "CREATE DATABASE db1"]))
  =+  !<(=state on-save:agent)
  ;:  weld
  %+  expect-eq                         :: expected results
    !>  [%result-da 'system time' ~2000.1.1]
    !>  ->+>+>.move
  %+  expect-eq                         :: expected state
    !>  db1
    !>  databases.state
  ==
++  test-cmd-create-db
  =|  run=@ud 
  =^  move  agent  
    (~(on-poke agent (bowl [run ~2000.1.1])) %obelisk-action !>([%cmd-create-db [%create-database 'db1']]))
  =+  !<(=state on-save:agent)
  ;:  weld
  %+  expect-eq                         :: expected results
    !>  [%result-da 'system time' ~2000.1.1]
    !>  ->+>+>.move
  %+  expect-eq                         :: expected state
    !>  db1
    !>  databases.state
  ==
++  test-fail-tape-create-dup-db
  =|  run=@ud 
  =^  move  agent  
    (~(on-poke agent (bowl [run ~2000.1.1])) %obelisk-action !>([%tape-create-db "CREATE DATABASE db1"]))
  %-  expect-fail
  |.  (~(on-poke agent (bowl [run ~2000.1.2])) %obelisk-action !>([%tape-create-db "CREATE DATABASE db1"]))
::  Create namespace
++  test-tape-create-ns
  =|  run=@ud 
  =^  mov1  agent  
    (~(on-poke agent (bowl [run ~2000.1.1])) %obelisk-action !>([%tape-create-db "CREATE DATABASE db1"]))
  =.  run  +(run)
  =^  mov2  agent  
    (~(on-poke agent (bowl [run ~2000.1.2])) %obelisk-action !>([%tape %db1 "CREATE NAMESPACE ns1"]))
  =+  !<(=state on-save:agent)
  ;:  weld
%+  expect-eq                         :: expected results
    !>  %results
    !>  ->+>+>-.mov2
  %+  expect-eq                         :: expected results
    !>  [%result-da 'system time' ~2000.1.2]
    !>  ->+>+>+<.mov2
  %+  expect-eq                         :: expected state
    !>  db2
    !>  databases.state
  ==
++  test-cmd-create-ns
  =|  run=@ud 
  =^  mov1  agent  
    (~(on-poke agent (bowl [run ~2000.1.1])) %obelisk-action !>([%cmd-create-db [%create-database 'db1']]))
  =.  run  +(run)
  =^  mov2  agent  
    (~(on-poke agent (bowl [run ~2000.1.2])) %obelisk-action !>([%commands ~[[%create-namespace %db1 %ns1]]]))
  =+  !<(=state on-save:agent)
  ;:  weld
  %+  expect-eq                         :: expected results
    !>  %results
    !>  ->+>+>-.mov2
  %+  expect-eq                         :: expected results
    !>  [%result-da 'system time' ~2000.1.2]
    !>  ->+>+>+<.mov2
  %+  expect-eq                         :: expected state
    !>  db2
    !>  databases.state
  ==
++  test-fail-create-duplicate-ns
  =|  run=@ud 
  =^  mov1  agent  
    (~(on-poke agent (bowl [run ~2000.1.1])) %obelisk-action !>([%cmd-create-db [%create-database 'db1']]))
  =.  run  +(run)
  =^  mov2  agent  
    (~(on-poke agent (bowl [run ~2000.1.2])) %obelisk-action !>([%commands ~[[%create-namespace %db1 %ns1]]]))
  =.  run  +(run)
  %-  expect-fail
  |.  (~(on-poke agent (bowl [run ~2000.1.3])) %obelisk-action !>([%commands ~[[%create-namespace %db1 %ns1]]]))
++  test-fail-ns-db-does-not-exist
  =|  run=@ud 
  =^  mov1  agent  
    (~(on-poke agent (bowl [run ~2000.1.1])) %obelisk-action !>([%cmd-create-db [%create-database 'db1']]))
  =.  run  +(run)
  %-  expect-fail
  |.  (~(on-poke agent (bowl [run ~2000.1.3])) %obelisk-action !>([%commands ~[[%create-namespace %db2 %ns1]]]))
::  Create table
++  one-col-tbl-db
  [[%db1 [%db-row name=%db1 created-by-agent=%agent created-tmsp=~2000.1.1 sys=~[one-col-tbl-sys sys1] user-data=~[user-data-2 user-data-1]]] ~ ~]
++  one-col-tbl-sys
  [%internals agent=%agent tmsp=~2000.1.2 namespaces=[[p=%dbo q=~2000.1.1] ~ [[p=%sys q=~2000.1.1] ~ ~]] tables=one-col-tbls]
++  one-col-tbl-key
 [%dbo %my-table]
++  one-col-tbl
  [%table agent=%agent tmsp=~2000.1.2 [%index unique=%.y clustered=%.y ~[[%ordered-column name=%col1 ascending=%.y]]] ~[[%column name=%col1 column-type=%t]] ~]
++  one-col-tbls
 [[one-col-tbl-key one-col-tbl] ~ ~]
++  cmd-one-col
    [%create-table [%qualified-object ~ 'db1' 'dbo' 'my-table'] ~[[%column 'col1' %t]] %.y ~[[%ordered-column 'col1' %.y]] ~]
::
++  two-col-tbl-db
  [[%db1 [%db-row name=%db1 created-by-agent=%agent created-tmsp=~2000.1.1 sys=~[two-col-tbl-sys one-col-tbl-sys sys1] user-data=~[user-data-3 user-data-2 user-data-1]]] ~ ~]
++  two-col-tbl-sys
  [%internals agent=%agent tmsp=~2000.1.3 namespaces=[[%dbo ~2000.1.1] ~ [[%sys ~2000.1.1] ~ ~]] tables=two-col-tbls]
++  two-col-tbl-key
  [%dbo %my-table-2]
++  two-col-tbl
  [%table agent=%agent tmsp=~2000.1.3 [%index %.y %.n ~[[%ordered-column %col1 %.y] [%ordered-column %col2 %.y]]] ~[[%column %col1 %t] [%column %col2 %p]] ~]
++  two-col-tbls
 [[two-col-tbl-key two-col-tbl] ~ [[one-col-tbl-key one-col-tbl] ~ ~]]
++  cmd-two-col
    [%create-table [%qualified-object ~ 'db1' 'dbo' 'my-table-2'] ~[[%column 'col1' %t] [%column 'col2' %p]] %.n ~[[%ordered-column 'col1' %.y] [%ordered-column 'col2' %.y]] ~]
::
++  two-comb-col-tbl
  [%table agent=%agent tmsp=~2000.1.2 [%index %.y %.n ~[[%ordered-column %col1 %.y] [%ordered-column %col2 %.y]]] ~[[%column %col1 %t] [%column %col2 %p]] ~]
++  two-comb-col-tbls
 [[two-col-tbl-key two-comb-col-tbl] ~ [[one-col-tbl-key one-col-tbl] ~ ~]]
++  two-comb-col-tbl-db
  [[%db1 [%db-row name=%db1 created-by-agent=%agent created-tmsp=~2000.1.1 sys=~[two-comb-col-tbl-sys sys1] user-data=~[user-data-3-a user-data-1]]] ~ ~]
++  two-comb-col-tbl-sys
  [%internals agent=%agent tmsp=~2000.1.2 namespaces=[[%dbo ~2000.1.1] ~ [[%sys ~2000.1.1] ~ ~]] tables=two-comb-col-tbls]
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
    !>  %results
    !>  ->+>+>-.mov2
  %+  expect-eq                         :: expected results
    !>  [%result-da 'system time' ~2000.1.2]
    !>  ->+>+>+<.mov2
  %+  expect-eq                         :: expected state
    !>  one-col-tbl-db
    !>  databases.state
  ==
++  test-tape-create-1-col-tbl
  =|  run=@ud
  =^  mov1  agent  
    (~(on-poke agent (bowl [run ~2000.1.1])) %obelisk-action !>([%tape-create-db "CREATE DATABASE db1"]))
  =.  run  +(run)
  =^  mov2  agent  
    (~(on-poke agent (bowl [run ~2000.1.2])) %obelisk-action !>([%tape %db1 "CREATE TABLE db1..my-table (col1 @t) PRIMARY KEY (col1)"]))
  =+  !<(=state on-save:agent)
  ;:  weld
  %+  expect-eq                         :: expected results
    !>  %results
    !>  ->+>+>-.mov2
  %+  expect-eq                         :: expected results
    !>  [%result-da 'system time' ~2000.1.2]
    !>  ->+>+>+<.mov2
  %+  expect-eq                         :: expected state
    !>  one-col-tbl-db
    !>  databases.state
  ==
++  test-cmd-create-2-col-tbl
  =|  run=@ud
 =^  mov1  agent  
    (~(on-poke agent (bowl [run ~2000.1.1])) %obelisk-action !>([%cmd-create-db [%create-database 'db1']]))
  =.  run  +(run)
  =^  mov2  agent  
    (~(on-poke agent (bowl [run ~2000.1.2])) %obelisk-action !>([%commands ~[cmd-one-col]]))
  =^  mov3  agent  
    (~(on-poke agent (bowl [run ~2000.1.3])) %obelisk-action !>([%commands ~[cmd-two-col]]))
  =+  !<(=state on-save:agent)
  ;:  weld
  %+  expect-eq                         :: expected results
    !>  %results
    !>  ->+>+>-.mov3
  %+  expect-eq                         :: expected results
    !>  [%result-da 'system time' ~2000.1.3]
    !>  ->+>+>+<.mov3
  %+  expect-eq                         :: expected state
    !>  two-col-tbl-db
    !>  databases.state
  ==
++  test-tape-create-2-col-tbl
  =|  run=@ud
 =^  mov1  agent  
    (~(on-poke agent (bowl [run ~2000.1.1])) %obelisk-action !>([%tape-create-db "CREATE DATABASE db1"]))
  =.  run  +(run)
  =^  mov2  agent  
    (~(on-poke agent (bowl [run ~2000.1.2])) %obelisk-action !>([%tape %db1 "CREATE TABLE db1..my-table (col1 @t) PRIMARY KEY CLUSTERED (col1)"]))
  =^  mov3  agent  
    (~(on-poke agent (bowl [run ~2000.1.3])) %obelisk-action !>([%tape %db1 "CREATE TABLE db1..my-table-2 (col1 @t, col2 @p) PRIMARY KEY LOOK-UP (col1, col2)"]))
  =+  !<(=state on-save:agent)
  ;:  weld
  %+  expect-eq                         :: expected results
    !>  %results
    !>  ->+>+>-.mov3
  %+  expect-eq                         :: expected results
    !>  [%result-da 'system time' ~2000.1.3]
    !>  ->+>+>+<.mov3
  %+  expect-eq                         :: expected state
    !>  two-col-tbl-db
    !>  databases.state
  ==
++  test-cmd-create-comb-2-col-tbl
  =|  run=@ud
 =^  mov1  agent  
    (~(on-poke agent (bowl [run ~2000.1.1])) %obelisk-action !>([%cmd-create-db [%create-database 'db1']]))
  =.  run  +(run)
  =^  mov2  agent  
    (~(on-poke agent (bowl [run ~2000.1.2])) %obelisk-action !>([%commands ~[cmd-two-col cmd-one-col]]))
  =+  !<(=state on-save:agent)
  ;:  weld
  %+  expect-eq                         :: expected results
    !>  %results
    !>  ->+>+>-.mov2
  %+  expect-eq                         :: expected results
    !>  [%result-da 'system time' ~2000.1.2]
    !>  ->+>+>+<.mov2
  %+  expect-eq                         :: expected state
    !>  two-comb-col-tbl-db
    !>  databases.state
  ==
++  test-tape-create-comb-2-col-tbl
  =|  run=@ud
 =^  mov1  agent  
    (~(on-poke agent (bowl [run ~2000.1.1])) %obelisk-action !>([%tape-create-db "CREATE DATABASE db1"]))
  =.  run  +(run)
  =^  mov2  agent  
    (~(on-poke agent (bowl [run ~2000.1.2])) %obelisk-action !>([%tape %db1 "CREATE TABLE db1..my-table (col1 @t) PRIMARY KEY (col1); CREATE TABLE db1..my-table-2 (col1 @t, col2 @p) PRIMARY KEY LOOK-UP (col1, col2)"]))
  =+  !<(=state on-save:agent)
  ;:  weld
  %+  expect-eq                         :: expected results
    !>  %results
    !>  ->+>+>-.mov2
  %+  expect-eq                         :: expected results
    !>  [%result-da 'system time' ~2000.1.2]
    !>  ->+>+>+<.mov2
  %+  expect-eq                         :: expected state
    !>  two-comb-col-tbl-db
    !>  databases.state
  ==

:: to do: create table with foreign keys
::        fail on referenced table does not exist
::        fail on referenced table columns not a unique key
::        fail on fk columns not in table def columns
::        fail on fk column auras do not match referenced column auras

++  test-fail-tbl-db-does-not-exist     :: fail on database does not exist
  =|  run=@ud
  =/  cmd
    [%create-table table=[%qualified-object ship=~ database='db' namespace='dbo' name='my-table'] columns=~[[%column name='col1' column-type=%t] [%column name='col2' column-type=%p] [%column name='col3' column-type='@ud']] clustered=%.n primary-key=~[[%ordered-column column-name='col1' ascending=%.y]] foreign-keys=~]  
  =^  mov1  agent  
    (~(on-poke agent (bowl [run ~2000.1.1])) %obelisk-action !>([%cmd-create-db [%create-database 'db1']]))
  =.  run  +(run)
  %-  expect-fail
  |.  (~(on-poke agent (bowl [run ~2000.1.3])) %obelisk-action !>([%commands ~[cmd]]))
++  test-fail-tbl-ns-does-not-exist     :: fail on namespace does not exist
  =|  run=@ud
  =/  cmd
    [%create-table table=[%qualified-object ship=~ database='db1' namespace='ns1' name='my-table'] columns=~[[%column name='col1' column-type=%t] [%column name='col2' column-type=%p] [%column name='col3' column-type='@ud']] clustered=%.n primary-key=~[[%ordered-column column-name='col1' ascending=%.y]] foreign-keys=~]  
  =^  mov1  agent  
    (~(on-poke agent (bowl [run ~2000.1.1])) %obelisk-action !>([%cmd-create-db [%create-database 'db1']]))
  =.  run  +(run)
  %-  expect-fail
  |.  (~(on-poke agent (bowl [run ~2000.1.3])) %obelisk-action !>([%commands ~[cmd]]))
++  test-fail-duplicate-tbl             :: fail on duplicate table name
  =|  run=@ud
  =/  cmd
    [%create-table table=[%qualified-object ship=~ database='db1' namespace='dbo' name='my-table'] columns=~[[%column name='col1' column-type=%t] [%column name='col2' column-type=%p] [%column name='col3' column-type='@ud']] clustered=%.n primary-key=~[[%ordered-column column-name='col1' ascending=%.y]] foreign-keys=~]  
  =^  mov1  agent  
    (~(on-poke agent (bowl [run ~2000.1.1])) %obelisk-action !>([%cmd-create-db [%create-database 'db1']]))
  =.  run  +(run)
  =^  mov2  agent  
    (~(on-poke agent (bowl [run ~2000.1.2])) %obelisk-action !>([%commands ~[cmd]]))
  =.  run  +(run)
  %-  expect-fail
  |.  (~(on-poke agent (bowl [run ~2000.1.3])) %obelisk-action !>([%commands ~[cmd]]))
  ++  test-fail-tbl-dup-cols     :: fail on dulicate column names
  =|  run=@ud
  =/  cmd
    [%create-table table=[%qualified-object ship=~ database='db1' namespace='dbo' name='my-table'] columns=~[[%column name='col1' column-type=%t] [%column name='col2' column-type=%p] [%column name='col1' column-type=%t]] clustered=%.n primary-key=~[[%ordered-column column-name='col1' ascending=%.y]] foreign-keys=~]  
  =^  mov1  agent  
    (~(on-poke agent (bowl [run ~2000.1.1])) %obelisk-action !>([%cmd-create-db [%create-database 'db1']]))
  =.  run  +(run)
  %-  expect-fail
  |.  (~(on-poke agent (bowl [run ~2000.1.3])) %obelisk-action !>([%commands ~[cmd]]))
  ++  test-fail-tbl-dup-key-cols     :: fail on dulicate column names in key
  =|  run=@ud
  =/  cmd
    [%create-table table=[%qualified-object ship=~ database='db1' namespace='dbo' name='my-table'] columns=~[[%column name='col1' column-type=%t] [%column name='col2' column-type=%p] [%column name='col3' column-type='@ud']] clustered=%.n primary-key=~[[%ordered-column column-name='col1' ascending=%.y] [%ordered-column column-name='col1' ascending=%.y]] foreign-keys=~]  
  =^  mov1  agent  
    (~(on-poke agent (bowl [run ~2000.1.1])) %obelisk-action !>([%cmd-create-db [%create-database 'db1']]))
  =.  run  +(run)
  %-  expect-fail
  |.  (~(on-poke agent (bowl [run ~2000.1.3])) %obelisk-action !>([%commands ~[cmd]]))
  ++  test-fail-tbl-key-col-not-exist     :: fail on key column not in column definitions
  =|  run=@ud
  =/  cmd
    [%create-table table=[%qualified-object ship=~ database='db1' namespace='dbo' name='my-table'] columns=~[[%column name='col1' column-type=%t] [%column name='col2' column-type=%p] [%column name='col3' column-type='@ud']] clustered=%.n primary-key=~[[%ordered-column column-name='col1' ascending=%.y] [%ordered-column column-name='col4' ascending=%.y]] foreign-keys=~]  
  =^  mov1  agent  
    (~(on-poke agent (bowl [run ~2000.1.1])) %obelisk-action !>([%cmd-create-db [%create-database 'db1']]))
  =.  run  +(run)
  %-  expect-fail
  |.  (~(on-poke agent (bowl [run ~2000.1.3])) %obelisk-action !>([%commands ~[cmd]]))
::
::  Drop table
++  dropped-tbl-db
  [[%db1 [%db-row name=%db1 created-by-agent=%agent created-tmsp=~2000.1.1 sys=~[sys3 one-col-tbl-sys sys1] user-data=~[user-data-1-a user-data-2 user-data-1]]] ~ ~]
++  dropped-tbl-db-force
  [[%db1 [%db-row name=%db1 created-by-agent=%agent created-tmsp=~2000.1.1 sys=~[sys4 one-col-tbl-sys sys1] user-data=~[user-data-4 user-data-1b user-data-2 user-data-1]]] ~ ~]
++  sys3
  [%internals agent=%agent tmsp=~2000.1.3 namespaces=[[[p=%dbo q=~2000.1.1] ~ [[p=%sys q=~2000.1.1] ~ ~]]] tables=~]
++  sys4
  [%internals agent=%agent tmsp=~2000.1.4 namespaces=[[[p=%dbo q=~2000.1.1] ~ [[p=%sys q=~2000.1.1] ~ ~]]] tables=~]
++  user-data-4
  [%data ~zod agent=%agent tmsp=~2000.1.4 ~]
++  user-data-1b
  [%data ~zod agent=%agent tmsp=~2000.1.3 files=files-4]
++  files-4
 [n=[p=[%dbo %my-table] q=[%file ship=~zod agent=%agent tmsp=~2000.1.3 clustered=%.y length=1 column-lookup=[n=[p=%col1 q=[%t 0]] l=~ r=~] key=~[[%t %.y]] pri-idx=files-4-pri-idx data=~[[n=[p=%col1 q=1.685.221.219] l=~ r=~]]]] l=~ r=~]
++  files-4-pri-idx
  [n=[[~[1.685.221.219] [n=[p=%col1 q=1.685.221.219] l=~ r=~]]] l=~ r=~]
::
::  drop table no data
++  test-drop-tbl
  =|  run=@ud
  =/  cmd
    [%drop-table table=[%qualified-object ship=~ database='db1' namespace='dbo' name='my-table'] %.n]
  =^  mov1  agent  
    (~(on-poke agent (bowl [run ~2000.1.1])) %obelisk-action !>([%tape-create-db "CREATE DATABASE db1"]))
  =.  run  +(run)
  =^  mov2  agent  
    (~(on-poke agent (bowl [run ~2000.1.2])) %obelisk-action !>([%tape %db1 "CREATE TABLE db1..my-table (col1 @t) PRIMARY KEY (col1)"]))
  =.  run  +(run)
  =^  mov3  agent  
    (~(on-poke agent (bowl [run ~2000.1.3])) %obelisk-action !>([%commands ~[cmd]]))
  =+  !<(=state on-save:agent)
  ;:  weld
  %+  expect-eq                         :: expected results
    !>  %results
    !>  ->+>+>-.mov3
  %+  expect-eq                         :: expected results
    !>  [%result-da 'system time' ~2000.1.3]
    !>  ->+>+>+<.mov3
  %+  expect-eq                         :: expected state
    !>  dropped-tbl-db
    !>  databases.state
  ==
::
::  drop table with data force
++  test-drop-tbl-force
  =|  run=@ud
  =/  cmd
    [%drop-table table=[%qualified-object ship=~ database='db1' namespace='dbo' name='my-table'] %.y]
  =^  mov1  agent  
    (~(on-poke agent (bowl [run ~2000.1.1])) %obelisk-action !>([%tape-create-db "CREATE DATABASE db1"]))
  =.  run  +(run)
  =^  mov2  agent  
    (~(on-poke agent (bowl [run ~2000.1.2])) %obelisk-action !>([%tape %db1 "CREATE TABLE db1..my-table (col1 @t) PRIMARY KEY (col1)"]))

  =.  run  +(run)
  =^  mov3  agent  
    (~(on-poke agent (bowl [run ~2000.1.3])) %obelisk-action !>([%tape %db1 "INSERT INTO db1..my-table (col1) VALUES ('cord')"]))
  =.  run  +(run)
  =^  mov4  agent  
    (~(on-poke agent (bowl [run ~2000.1.4])) %obelisk-action !>([%commands ~[cmd]]))
  =+  !<(=state on-save:agent)
  ;:  weld
  %+  expect-eq                         :: expected results
    !>  %results
    !>  ->+>+>-.mov4
  %+  expect-eq                         :: expected results
    !>  [%result-da 'system time' ~2000.1.4]
    !>  ->+>+>+<.mov4
  %+  expect-eq                         :: expected state
    !>  dropped-tbl-db-force
    !>  databases.state
  ==
::
::  fail drop table with data no force
++  test-fail-drop-tbl-with-data
  =|  run=@ud
  =/  cmd
    [%drop-table table=[%qualified-object ship=~ database='db1' namespace='dbo' name='my-table'] %.n]
  =^  mov1  agent  
    (~(on-poke agent (bowl [run ~2000.1.1])) %obelisk-action !>([%tape-create-db "CREATE DATABASE db1"]))
  =.  run  +(run)
  =^  mov2  agent  
    (~(on-poke agent (bowl [run ~2000.1.2])) %obelisk-action !>([%tape %db1 "CREATE TABLE db1..my-table (col1 @t) PRIMARY KEY (col1)"]))

  =.  run  +(run)
  =^  mov3  agent  
    (~(on-poke agent (bowl [run ~2000.1.3])) %obelisk-action !>([%tape %db1 "INSERT INTO db1..my-table (col1) VALUES ('cord')"]))
  =.  run  +(run)
  %-  expect-fail
  |.  (~(on-poke agent (bowl [run ~2000.1.4])) %obelisk-action !>([%commands ~[cmd]]))
++  test-fail-drop-tbl-db-not-exist     :: fail on database does not exist
  =|  run=@ud
  =/  cmd
    [%drop-table table=[%qualified-object ship=~ database='db' namespace='dbo' name='my-table'] %.n]
  =^  mov1  agent  
    (~(on-poke agent (bowl [run ~2000.1.1])) %obelisk-action !>([%cmd-create-db [%create-database 'db1']]))
  =.  run  +(run)
  %-  expect-fail
  |.  (~(on-poke agent (bowl [run ~2000.1.3])) %obelisk-action !>([%commands ~[cmd]]))
++  test-fail-drop-tbl-ns-not-exist     :: fail on namespace does not exist
  =|  run=@ud
  =/  cmd
    [%drop-table table=[%qualified-object ship=~ database='db1' namespace='ns1' name='my-table'] %.n]
  =^  mov1  agent  
    (~(on-poke agent (bowl [run ~2000.1.1])) %obelisk-action !>([%cmd-create-db [%create-database 'db1']]))
  =.  run  +(run)
  %-  expect-fail
  |.  (~(on-poke agent (bowl [run ~2000.1.3])) %obelisk-action !>([%commands ~[cmd]]))
++  test-fail-drop-tbl-not-exist        :: fail on table name does not exist
  =|  run=@ud
  =/  cmd
    [%drop-table table=[%qualified-object ship=~ database='db1' namespace='dbo' name='my-table'] %.n]
  =^  mov1  agent  
    (~(on-poke agent (bowl [run ~2000.1.1])) %obelisk-action !>([%cmd-create-db [%create-database 'db1']]))
  =.  run  +(run)
  %-  expect-fail
  |.  (~(on-poke agent (bowl [run ~2000.1.3])) %obelisk-action !>([%commands ~[cmd]]))

--