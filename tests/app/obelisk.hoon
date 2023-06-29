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


++  test-fail-tbl-db-does-not-exist     :: fail on database does not exist
  =|  run=@ud
  =/  cmd
    [%create-table table=[%qualified-object ship=~ database='db' namespace='dbo' name='my-table'] columns=~[[%column name='col1' column-type='@t'] [%column name='col2' column-type='@p'] [%column name='col3' column-type='@ud']] primary-key=[%create-index name='ix-primary-dbo-my-table' object-name=[%qualified-object ship=~ database='db' namespace='dbo' name='my-table'] is-unique=%.y is-clustered=%.n columns=~[[%ordered-column column-name='col1' is-ascending=%.y]]] foreign-keys=~]  
  =^  mov1  agent  
    (~(on-poke agent (bowl [run ~2000.1.1])) %obelisk-action !>([%cmd-create-db [%create-database 'db1']]))
  =.  run  +(run)
  %-  expect-fail
  |.  (~(on-poke agent (bowl [run ~2000.1.3])) %obelisk-action !>([%commands ~[cmd]]))
++  test-fail-tbl-ns-does-not-exist     :: fail on namespace does not exist
  =|  run=@ud
  =/  cmd
    [%create-table table=[%qualified-object ship=~ database='db1' namespace='ns1' name='my-table'] columns=~[[%column name='col1' column-type='@t'] [%column name='col2' column-type='@p'] [%column name='col3' column-type='@ud']] primary-key=[%create-index name='ix-primary-dbo-my-table' object-name=[%qualified-object ship=~ database='db1' namespace='ns1' name='my-table'] is-unique=%.y is-clustered=%.n columns=~[[%ordered-column column-name='col1' is-ascending=%.y]]] foreign-keys=~]  
  =^  mov1  agent  
    (~(on-poke agent (bowl [run ~2000.1.1])) %obelisk-action !>([%cmd-create-db [%create-database 'db1']]))
  =.  run  +(run)
  %-  expect-fail
  |.  (~(on-poke agent (bowl [run ~2000.1.3])) %obelisk-action !>([%commands ~[cmd]]))
++  test-fail-duplicate-tbl             :: fail on duplicate table name
  =|  run=@ud
  =/  cmd
    [%create-table table=[%qualified-object ship=~ database='db1' namespace='dbo' name='my-table'] columns=~[[%column name='col1' column-type='@t'] [%column name='col2' column-type='@p'] [%column name='col3' column-type='@ud']] primary-key=[%create-index name='ix-primary-dbo-my-table' object-name=[%qualified-object ship=~ database='db1' namespace='dbo' name='my-table'] is-unique=%.y is-clustered=%.n columns=~[[%ordered-column column-name='col1' is-ascending=%.y]]] foreign-keys=~]  
  =^  mov1  agent  
    (~(on-poke agent (bowl [run ~2000.1.1])) %obelisk-action !>([%cmd-create-db [%create-database 'db1']]))
  =.  run  +(run)
  =^  mov2  agent  
    (~(on-poke agent (bowl [run ~2000.1.2])) %obelisk-action !>([%commands ~[cmd]]))
  =.  run  +(run)
  %-  expect-fail
  |.  (~(on-poke agent (bowl [run ~2000.1.3])) %obelisk-action !>([%commands ~[cmd]]))


  ++  test-fail-tbl-dup-columns     :: fail on dulicate column definitions
  =|  run=@ud
  =/  cmd
    [%create-table table=[%qualified-object ship=~ database='db1' namespace='dbo' name='my-table'] columns=~[[%column name='col1' column-type='@t'] [%column name='col2' column-type='@p'] [%column name='col1' column-type='@ud']] primary-key=[%create-index name='ix-primary-dbo-my-table' object-name=[%qualified-object ship=~ database='db1' namespace='dbo' name='my-table'] is-unique=%.y is-clustered=%.n columns=~[[%ordered-column column-name='col1' is-ascending=%.y]]] foreign-keys=~]  
  =^  mov1  agent  
    (~(on-poke agent (bowl [run ~2000.1.1])) %obelisk-action !>([%cmd-create-db [%create-database 'db1']]))
  =.  run  +(run)
  %-  expect-fail
  |.  (~(on-poke agent (bowl [run ~2000.1.3])) %obelisk-action !>([%commands ~[cmd]]))

  ++  test-fail-tbl-dup-key-columns     :: fail on dulicate column definitions in key
  =|  run=@ud
  =/  cmd
    [%create-table table=[%qualified-object ship=~ database='db1' namespace='dbo' name='my-table'] columns=~[[%column name='col1' column-type='@t'] [%column name='col2' column-type='@p'] [%column name='col3' column-type='@ud']] primary-key=[%create-index name='ix-primary-dbo-my-table' object-name=[%qualified-object ship=~ database='db1' namespace='dbo' name='my-table'] is-unique=%.y is-clustered=%.n columns=~[[%ordered-column column-name='col1' is-ascending=%.y]] [%ordered-column column-name='col1' is-ascending=%.y]]] foreign-keys=~]  
  =^  mov1  agent  
    (~(on-poke agent (bowl [run ~2000.1.1])) %obelisk-action !>([%cmd-create-db [%create-database 'db1']]))
  =.  run  +(run)
  %-  expect-fail
  |.  (~(on-poke agent (bowl [run ~2000.1.3])) %obelisk-action !>([%commands ~[cmd]]))

  ~|(" {<columns.pri-indx.create-table>}" !!)
  ++  test-fail-tbl-key-column-not-exist     :: fail on key column not in column definitions
  =|  run=@ud
  =/  cmd
    [%create-table table=[%qualified-object ship=~ database='db1' namespace='dbo' name='my-table'] columns=~[[%column name='col1' column-type='@t'] [%column name='col2' column-type='@p'] [%column name='col3' column-type='@ud']] primary-key=[%create-index name='ix-primary-dbo-my-table' object-name=[%qualified-object ship=~ database='db1' namespace='dbo' name='my-table'] is-unique=%.y is-clustered=%.n columns=~[[%ordered-column column-name='col1' is-ascending=%.y]] [%ordered-column column-name='col4' is-ascending=%.y]]] foreign-keys=~]  
  =^  mov1  agent  
    (~(on-poke agent (bowl [run ~2000.1.1])) %obelisk-action !>([%cmd-create-db [%create-database 'db1']]))
  =.  run  +(run)
  %-  expect-fail
  |.  (~(on-poke agent (bowl [run ~2000.1.3])) %obelisk-action !>([%commands ~[cmd]]))




:: fail on referenced table does not exist
:: fail on referenced table columns not a unique key
:: fail on fk columns not in table def columns
:: fail on fk column auras do not match referenced column auras
--