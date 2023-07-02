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
  [[%db1 [%db-row name=%db1 created-by-agent=%agent created-tmsp=~2000.1.1 sys=~[sys1]]] ~ ~]
++  sys1
  [%db-internals agent=%agent tmsp=~2000.1.1 namespaces=[[p=%dbo q=%dbo] ~ [[p=%sys q=%sys] ~ ~]] tables=~]
++  sys2
  [%db-internals agent=%agent tmsp=~2000.1.2 namespaces=[[p=%ns1 q=%ns1] ~ [[p=%dbo q=%dbo] ~ [[p=%sys q=%sys] ~ ~]]] tables=~]
++  db2
  [[%db1 [%db-row name=%db1 created-by-agent=%agent created-tmsp=~2000.1.1 sys=~[sys2 sys1]]] ~ ~]
::  Create database
++  test-tape-create-db
  =|  run=@ud 
  =^  move  agent  
    (~(on-poke agent (bowl [run ~2000.1.1])) %obelisk-action !>([%tape-create-db "CREATE DATABASE db1"]))
  =+  !<(=state on-save:agent)
  ;:  weld
  %+  expect-eq                         :: expected results
    !>  [%results ~['success']]
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
    !>  [%results ~['success']]
    !>  ->+>+>.move
  %+  expect-eq                         :: expected state
    !>  db1
    !>  databases.state
  ==
++  test-fail-tape-create-duplicate-db
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
    !>  [%results ~['success']]
    !>  ->+>+>.mov2
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
    !>  [%results ~['success']]
    !>  ->+>+>.mov2
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
  [[%db1 [%db-row name=%db1 created-by-agent=%agent created-tmsp=~2000.1.1 sys=~[one-col-tbl-sys sys1]]] ~ ~]
++  one-col-tbl-sys
  [%db-internals agent=%agent tmsp=~2000.1.2 namespaces=[[p=%dbo q=%dbo] ~ [[p=%sys q=%sys] ~ ~]] tables=one-col-tbls]
++  one-col-tbl-key
 [%dbo %my-table]
++  one-col-tbl
  [%table [%index unique=%.y clustered=%.y ~[[%ordered-column name=%col1 is-ascending=%.y]]] ~[[%column name=%col1 column-type='@t']] ~]
++  one-col-tbls
 [[one-col-tbl-key one-col-tbl] ~ ~]
++  cmd-one-col
    [%create-table [%qualified-object ~ 'db1' 'dbo' 'my-table'] ~[[%column 'col1' '@t']] %.y ~[[%ordered-column 'col1' %.y]] ~]
::
++  two-col-tbl-db
  [[%db1 [%db-row name=%db1 created-by-agent=%agent created-tmsp=~2000.1.1 sys=~[two-col-tbl-sys one-col-tbl-sys sys1]]] ~ ~]
++  two-col-tbl-sys
  [%db-internals agent=%agent tmsp=~2000.1.3 namespaces=[[%dbo %dbo] ~ [[%sys %sys] ~ ~]] tables=two-col-tbls]
++  two-col-tbl-key
  [%dbo %my-table-2]
++  two-col-tbl
  [%table [%index %.y %.n ~[[%ordered-column %col1 %.y] [%ordered-column %col2 %.y]]] ~[[%column %col1 '@t'] [%column %col2 '@p']] ~]
++  two-col-tbls
 [[two-col-tbl-key two-col-tbl] ~ [[one-col-tbl-key one-col-tbl] ~ ~]]
++  cmd-two-col
    [%create-table [%qualified-object ~ 'db1' 'dbo' 'my-table-2'] ~[[%column 'col1' '@t'] [%column 'col2' '@p']] %.n ~[[%ordered-column 'col1' %.y] [%ordered-column 'col2' %.y]] ~]
::
++  two-comb-col-tbl-db
  [[%db1 [%db-row name=%db1 created-by-agent=%agent created-tmsp=~2000.1.1 sys=~[two-comb-col-tbl-sys sys1]]] ~ ~]
++  two-comb-col-tbl-sys
  [%db-internals agent=%agent tmsp=~2000.1.2 namespaces=[[%dbo %dbo] ~ [[%sys %sys] ~ ~]] tables=two-col-tbls]
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
    !>  [%results ~['success']]
    !>  ->+>+>.mov2
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
    !>  [%results ~['success']]
    !>  ->+>+>.mov2
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
    !>  [%results ~['success']]
    !>  ->+>+>.mov3
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
    (~(on-poke agent (bowl [run ~2000.1.3])) %obelisk-action !>([%tape %db1 "CREATE TABLE db1..my-table-2 (col1 @t, col2 @p) PRIMARY KEY NONCLUSTERED (col1, col2)"]))
  =+  !<(=state on-save:agent)
  ;:  weld
  %+  expect-eq                         :: expected results
    !>  [%results ~['success']]
    !>  ->+>+>.mov3
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
    !>  [%results ~['success']]
    !>  ->+>+>.mov2
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
    (~(on-poke agent (bowl [run ~2000.1.2])) %obelisk-action !>([%tape %db1 "CREATE TABLE db1..my-table (col1 @t) PRIMARY KEY (col1); CREATE TABLE db1..my-table-2 (col1 @t, col2 @p) PRIMARY KEY NONCLUSTERED (col1, col2)"]))
  =+  !<(=state on-save:agent)
  ;:  weld
  %+  expect-eq                         :: expected results
    !>  [%results ~['success']]
    !>  ->+>+>.mov2
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
    [%create-table table=[%qualified-object ship=~ database='db' namespace='dbo' name='my-table'] columns=~[[%column name='col1' column-type='@t'] [%column name='col2' column-type='@p'] [%column name='col3' column-type='@ud']] clustered=%.n primary-key=~[[%ordered-column column-name='col1' is-ascending=%.y]] foreign-keys=~]  
  =^  mov1  agent  
    (~(on-poke agent (bowl [run ~2000.1.1])) %obelisk-action !>([%cmd-create-db [%create-database 'db1']]))
  =.  run  +(run)
  %-  expect-fail
  |.  (~(on-poke agent (bowl [run ~2000.1.3])) %obelisk-action !>([%commands ~[cmd]]))
++  test-fail-tbl-ns-does-not-exist     :: fail on namespace does not exist
  =|  run=@ud
  =/  cmd
    [%create-table table=[%qualified-object ship=~ database='db1' namespace='ns1' name='my-table'] columns=~[[%column name='col1' column-type='@t'] [%column name='col2' column-type='@p'] [%column name='col3' column-type='@ud']] clustered=%.n primary-key=~[[%ordered-column column-name='col1' is-ascending=%.y]] foreign-keys=~]  
  =^  mov1  agent  
    (~(on-poke agent (bowl [run ~2000.1.1])) %obelisk-action !>([%cmd-create-db [%create-database 'db1']]))
  =.  run  +(run)
  %-  expect-fail
  |.  (~(on-poke agent (bowl [run ~2000.1.3])) %obelisk-action !>([%commands ~[cmd]]))
++  test-fail-duplicate-tbl             :: fail on duplicate table name
  =|  run=@ud
  =/  cmd
    [%create-table table=[%qualified-object ship=~ database='db1' namespace='dbo' name='my-table'] columns=~[[%column name='col1' column-type='@t'] [%column name='col2' column-type='@p'] [%column name='col3' column-type='@ud']] clustered=%.n primary-key=~[[%ordered-column column-name='col1' is-ascending=%.y]] foreign-keys=~]  
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
    [%create-table table=[%qualified-object ship=~ database='db1' namespace='dbo' name='my-table'] columns=~[[%column name='col1' column-type='@t'] [%column name='col2' column-type='@p'] [%column name='col1' column-type='@t']] clustered=%.n primary-key=~[[%ordered-column column-name='col1' is-ascending=%.y]] foreign-keys=~]  
  =^  mov1  agent  
    (~(on-poke agent (bowl [run ~2000.1.1])) %obelisk-action !>([%cmd-create-db [%create-database 'db1']]))
  =.  run  +(run)
  %-  expect-fail
  |.  (~(on-poke agent (bowl [run ~2000.1.3])) %obelisk-action !>([%commands ~[cmd]]))
  ++  test-fail-tbl-dup-key-cols     :: fail on dulicate column names in key
  =|  run=@ud
  =/  cmd
    [%create-table table=[%qualified-object ship=~ database='db1' namespace='dbo' name='my-table'] columns=~[[%column name='col1' column-type='@t'] [%column name='col2' column-type='@p'] [%column name='col3' column-type='@ud']] clustered=%.n primary-key=~[[%ordered-column column-name='col1' is-ascending=%.y] [%ordered-column column-name='col1' is-ascending=%.y]] foreign-keys=~]  
  =^  mov1  agent  
    (~(on-poke agent (bowl [run ~2000.1.1])) %obelisk-action !>([%cmd-create-db [%create-database 'db1']]))
  =.  run  +(run)
  %-  expect-fail
  |.  (~(on-poke agent (bowl [run ~2000.1.3])) %obelisk-action !>([%commands ~[cmd]]))
  ++  test-fail-tbl-key-col-not-exist     :: fail on key column not in column definitions
  =|  run=@ud
  =/  cmd
    [%create-table table=[%qualified-object ship=~ database='db1' namespace='dbo' name='my-table'] columns=~[[%column name='col1' column-type='@t'] [%column name='col2' column-type='@p'] [%column name='col3' column-type='@ud']] clustered=%.n primary-key=~[[%ordered-column column-name='col1' is-ascending=%.y] [%ordered-column column-name='col4' is-ascending=%.y]] foreign-keys=~]  
  =^  mov1  agent  
    (~(on-poke agent (bowl [run ~2000.1.1])) %obelisk-action !>([%cmd-create-db [%create-database 'db1']]))
  =.  run  +(run)
  %-  expect-fail
  |.  (~(on-poke agent (bowl [run ~2000.1.3])) %obelisk-action !>([%commands ~[cmd]]))
::  Drop table
++  dropped-tbl-db
  [[%db1 [%db-row name=%db1 created-by-agent=%agent created-tmsp=~2000.1.1 sys=~[sys3 one-col-tbl-sys sys1]]] ~ ~]
++  sys3
  [%db-internals agent=%agent tmsp=~2000.1.3 namespaces=[[[p=%dbo q=%dbo] ~ [[p=%sys q=%sys] ~ ~]]] tables=~]
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
    !>  [%results ~['success']]
    !>  ->+>+>.mov2
  %+  expect-eq                         :: expected state
    !>  dropped-tbl-db
    !>  databases.state
  ==
++  test-fail-drop-tbl-db-does-not-exist     :: fail on database does not exist
  =|  run=@ud
  =/  cmd
    [%drop-table table=[%qualified-object ship=~ database='db' namespace='dbo' name='my-table'] %.n]
  =^  mov1  agent  
    (~(on-poke agent (bowl [run ~2000.1.1])) %obelisk-action !>([%cmd-create-db [%create-database 'db1']]))
  =.  run  +(run)
  %-  expect-fail
  |.  (~(on-poke agent (bowl [run ~2000.1.3])) %obelisk-action !>([%commands ~[cmd]]))
++  test-fail-drop-tbl-ns-does-not-exist     :: fail on namespace does not exist
  =|  run=@ud
  =/  cmd
    [%drop-table table=[%qualified-object ship=~ database='db1' namespace='ns1' name='my-table'] %.n]
  =^  mov1  agent  
    (~(on-poke agent (bowl [run ~2000.1.1])) %obelisk-action !>([%cmd-create-db [%create-database 'db1']]))
  =.  run  +(run)
  %-  expect-fail
  |.  (~(on-poke agent (bowl [run ~2000.1.3])) %obelisk-action !>([%commands ~[cmd]]))
++  test-fail-drop-tbl-not-exist            :: fail on table name does not exist
  =|  run=@ud
  =/  cmd
    [%drop-table table=[%qualified-object ship=~ database='db1' namespace='dbo' name='my-table'] %.n]
  =^  mov1  agent  
    (~(on-poke agent (bowl [run ~2000.1.1])) %obelisk-action !>([%cmd-create-db [%create-database 'db1']]))
  =.  run  +(run)
  %-  expect-fail
  |.  (~(on-poke agent (bowl [run ~2000.1.3])) %obelisk-action !>([%commands ~[cmd]]))

::  To Do: test drop table force

--