::  Demonstrate unit testing on a Gall agent with %obelisk.
::
/-  ast, *obelisk
/+  *test
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
::  databases
++  db1
  :+  :-  %db1
          :*  %database
              name=%db1
              created-provenance=`path`/test-agent
              created-tmsp=~2000.1.1
              sys=(gas:schema-key *((mop @da schema) gth) ~[sys1])
              content=(gas:data-key *((mop @da data) gth) ~[content-1])
          ==
      ~
      ~
++  db2
  :+  :-  %db1
          :*  %database
              name=%db1
              created-provenance=`path`/test-agent
              created-tmsp=~2000.1.1
              sys=(gas:schema-key *((mop @da schema) gth) ~[sys2 sys1])
              content=(gas:data-key *((mop @da data) gth) ~[content-1])
          ==
      ~
      ~
++  one-col-tbl-db
  :+  :-  %db1
          :*  %database
              name=%db1
              created-provenance=`path`/test-agent
              created-tmsp=~2000.1.1
              (gas:schema-key *((mop @da schema) gth) ~[one-col-tbl-sys sys1])
              (gas:data-key *((mop @da data) gth) ~[content-2 content-1])
          ==
      ~
      ~
++  two-col-tbl-db
  :+  :-  %db1
          :*  %database
              name=%db1
              created-provenance=`path`/test-agent
              created-tmsp=~2000.1.1
              %+  gas:schema-key  *((mop @da schema) gth)
                                  ~[two-col-tbl-sys one-col-tbl-sys sys1]
              %+  gas:data-key  *((mop @da data) gth)
                                ~[content-3 content-2 content-1]
          ==
      ~
      ~
++  two-comb-col-tbl-db
  :+  :-  %db1
          :*  %database
              name=%db1
              created-provenance=`path`/test-agent
              created-tmsp=~2000.1.1
              %+  gas:schema-key  *((mop @da schema) gth)
                                  ~[two-comb-col-tbl-sys sys1]
              %+  gas:data-key  *((mop @da data) gth)
                                ~[content-3-a content-1]
          ==
       ~
       ~
++  dropped-tbl-db
  :+  :-  %db1
          :*  %database
              name=%db1
              created-provenance=`path`/test-agent
              created-tmsp=~2000.1.1
              %+  gas:schema-key  *((mop @da schema) gth)
                                  ~[sys3 one-col-tbl-sys sys1]
              %+  gas:data-key  *((mop @da data) gth)
                                ~[content-1-a content-2 content-1]
          ==
      ~
      ~
++  dropped-tbl-db-force
  :+  :-  %db1
          :*  %database
              name=%db1
              created-provenance=`path`/test-agent
              created-tmsp=~2000.1.1
              %+  gas:schema-key  *((mop @da schema) gth)
                                  ~[sys4 one-col-tbl-sys sys1]
              %+  gas:data-key  *((mop @da data) gth)
                                ~[content-4 content-1b content-2 content-1]
          ==
      ~
      ~
++  db-time-create-ns
  :+  :-  %db1
          :*  %database
              name=%db1
              created-provenance=`path`/test-agent
              created-tmsp=~2000.1.1
              sys=(gas:schema-key *((mop @da schema) gth) ~[sys-time-create-ns my-table-2-sys sys1])
              content=(gas:data-key *((mop @da data) gth) ~[content-time-2 content-1])
          ==
      ~
      ~
::
::  schemas
++  schema-key  ((on @da schema) gth)
++  sys1
  :-  ~2000.1.1
  :*  %schema
      provenance=`path`/test-agent
      tmsp=~2000.1.1
      namespaces=[[p=%dbo q=~2000.1.1] ~ [[p=%sys q=~2000.1.1] ~ ~]]
      tables=~
  ==
++  sys2
  :-  ~2000.1.2
    :*  %schema
        provenance=`path`/test-agent
        tmsp=~2000.1.2
        :+  [p=%ns1 q=~2000.1.2]
            ~
            [[p=%dbo q=~2000.1.1] ~ [[p=%sys q=~2000.1.1] ~ ~]]
        tables=~
    ==
++  one-col-tbl-sys
  :-  ~2000.1.2
    :*  %schema
        provenance=`path`/test-agent
        tmsp=~2000.1.2
        namespaces=[[p=%dbo q=~2000.1.1] ~ [[p=%sys q=~2000.1.1] ~ ~]]
        tables=one-col-tbls
    ==
++  two-col-tbl-sys
  :-  ~2000.1.3
    :*  %schema
        provenance=`path`/test-agent
        tmsp=~2000.1.3
        namespaces=[[%dbo ~2000.1.1] ~ [[%sys ~2000.1.1] ~ ~]]
        tables=two-col-tbls
    ==
++  two-comb-col-tbl-sys
  :-  ~2000.1.2
    :*  %schema
        provenance=`path`/test-agent
        tmsp=~2000.1.2
        namespaces=[[%dbo ~2000.1.1] ~ [[%sys ~2000.1.1] ~ ~]]
        tables=two-comb-col-tbls
    ==
++  my-table-2-sys
  :-  ~2000.1.2
    :*  %schema
        provenance=`path`/test-agent
        tmsp=~2000.1.2
        namespaces=[[%dbo ~2000.1.1] ~ [[%sys ~2000.1.1] ~ ~]]
        tables=my-table-2
    ==
++  sys3
  :-  ~2000.1.3
    :*  %schema
        provenance=`path`/test-agent
        tmsp=~2000.1.3
        namespaces=[[[p=%dbo q=~2000.1.1] ~ [[p=%sys q=~2000.1.1] ~ ~]]]
        tables=~
    ==
++  sys4
  :-  ~2000.1.4
    :*  %schema
        provenance=`path`/test-agent
        tmsp=~2000.1.4
        namespaces=[[[p=%dbo q=~2000.1.1] ~ [[p=%sys q=~2000.1.1] ~ ~]]]
        tables=~
    ==

++  sys-time-create-ns
  :-  ~2023.7.9..22.35.35..7e90
    :*  %schema
        provenance=`path`/test-agent
        tmsp=~2023.7.9..22.35.35..7e90
        :+  [p=%ns1 q=~2023.7.9..22.35.35..7e90]
            ~
            [[p=%dbo q=~2000.1.1] ~ [[p=%sys q=~2000.1.1] ~ ~]]
        tables=my-table-2
    ==
::
::  content
++  data-key  ((on @da data) gth)
++  content-1
  [~2000.1.1 [%data ~zod provenance=`path`/test-agent tmsp=~2000.1.1 ~]]
++  content-1-a
  :-  ~2000.1.3
    :*  %data
        ~zod
        provenance=`path`/test-agent
        tmsp=~2000.1.3
        ~
    ==
++  content-2
  :-  ~2000.1.2
    :*  %data
        ~zod
        `path`/test-agent
        ~2000.1.2
        [[[%dbo %my-table] file-1col-1-2] ~ ~]
    ==
++  content-time-2
  :-  ~2000.1.2
    :*  %data
        ~zod
        `path`/test-agent
        ~2000.1.2
        [[[%dbo %my-table-2] file-time-2] ~ ~]
    ==
++  content-3
  :-  ~2000.1.3
    :*  %data
        ~zod
        `path`/test-agent
        ~2000.1.3
        :+  [[%dbo %my-table-2] file-2col-1-3]
            ~
            [[[%dbo %my-table] file-1col-1-2] ~ ~]
    ==
++  content-3-a
  :-  ~2000.1.2
    :*  %data
        ~zod
        `path`/test-agent
        ~2000.1.2
        :+  [[%dbo %my-table-2] file-2col-1-2]
            ~
            [[[%dbo %my-table] file-1col-1-2] ~ ~]
    ==
++  content-4
  [~2000.1.4 [%data ~zod provenance=`path`/test-agent tmsp=~2000.1.4 ~]]
++  content-1b
  [~2000.1.3 [%data ~zod provenance=`path`/test-agent tmsp=~2000.1.3 files=files-4]]
::
::  files
++  file-1col-1-2
  :*  %file
      ~zod
      `path`/test-agent
      ~2000.1.2
      %.y
      0
      [[%col1 [%t 0]] ~ ~]
      ~[[%t %.y]]
      ~
      ~
  ==
++  file-2col-1-2
  :*  %file
      ~zod
      `path`/test-agent
      ~2000.1.2
      %.n
      0
      [[%col2 [%p 1]] ~ [[%col1 [%t 0]] ~ ~]]
      ~[[%t %.y] [%p %.y]]
      ~
      ~
  ==
++  file-time-2
  :*  %file
      ~zod
      `path`/test-agent
      ~2000.1.2
      %.y
      0
      [[%col2 [%p 1]] ~ [[%col1 [%t 0]] ~ ~]]
      ~[[%t %.y] [%p %.y]]
      ~
      ~
  ==
++  file-2col-1-3
  :*  %file
      ~zod
      `path`/test-agent
      ~2000.1.3
      %.n
      0
      [[%col2 [%p 1]] ~ [[%col1 [%t 0]] ~ ~]]
      ~[[%t %.y] [%p %.y]]
      ~
      ~
  ==
++  files-4
  :+  :-  p=[%dbo %my-table]
          :*  %file
              ship=~zod
              provenance=`path`/test-agent
              tmsp=~2000.1.3
              clustered=%.y
              length=1
              column-lookup=[n=[p=%col1 q=[%t 0]] l=~ r=~]
              key=~[[%t %.y]]
              pri-idx=files-4-pri-idx
              data=~[[n=[p=%col1 q=1.685.221.219] l=~ r=~]]
          ==
      l=~
      r=~
++  files-4-pri-idx
  [n=[[~[1.685.221.219] [n=[p=%col1 q=1.685.221.219] l=~ r=~]]] l=~ r=~]
::
::  tables
++  one-col-tbl
  :*  %table
      provenance=`path`/test-agent
      tmsp=~2000.1.2
      :^  %index
          unique=%.y
          clustered=%.y
          ~[[%ordered-column name=%col1 ascending=%.y]]
      ~[[%column name=%col1 column-type=%t]]
      ~
  ==
++  two-col-tbl
  :*  %table
      provenance=`path`/test-agent
      tmsp=~2000.1.3
      :*  %index
          %.y
          %.n
          ~[[%ordered-column %col1 %.y] [%ordered-column %col2 %.y]]
      ==
      ~[[%column %col1 %t] [%column %col2 %p]]
      ~
  ==
++  two-comb-col-tbl
  :*  %table
      provenance=`path`/test-agent
      tmsp=~2000.1.2
      :*  %index
          %.y
          %.n
          ~[[%ordered-column %col1 %.y] [%ordered-column %col2 %.y]]
      ==
      ~[[%column %col1 %t] [%column %col2 %p]]
      ~
  ==
++  time-2-tbl
  :*  %table
      provenance=`path`/test-agent
      tmsp=~2000.1.2
      :*  %index
          %.y
          %.y
          ~[[%ordered-column %col1 %.y] [%ordered-column %col2 %.y]]
      ==
      ~[[%column %col1 %t] [%column %col2 %p]]
      ~
  ==
++  cmd-two-col
  :*  %create-table
      [%qualified-object ~ 'db1' 'dbo' 'my-table-2']
      ~[[%column 'col1' %t] [%column 'col2' %p]]
      %.n
      ~[[%ordered-column 'col1' %.y] [%ordered-column 'col2' %.y]]
      ~
      ~
  ==
++  cmd-one-col
  :*  %create-table
      [%qualified-object ~ 'db1' 'dbo' 'my-table']
      ~[[%column 'col1' %t]]
      %.y
      ~[[%ordered-column 'col1' %.y]]
      ~
      ~
  ==
++  one-col-tbls     [[[%dbo %my-table] one-col-tbl] ~ ~]
++  two-col-tbls
  [[[%dbo %my-table-2] two-col-tbl] ~ [[[%dbo %my-table] one-col-tbl] ~ ~]]
++  my-table-2  [[[%dbo %my-table-2] time-2-tbl] ~ ~]
++  two-comb-col-tbls
  :+  [[%dbo %my-table-2] two-comb-col-tbl]
      ~
      [[[%dbo %my-table] one-col-tbl] ~ ~]
::
::  Create database
++  test-tape-create-db
  =|  run=@ud 
  =^  move  agent  
    %:  ~(on-poke agent (bowl [run ~2000.1.1]))
        %obelisk-action
        !>([%tape-create-db "CREATE DATABASE db1"])
    ==
  =+  !<(=state on-save:agent)
  ;:  weld
  %+  expect-eq
    !>  [%result-da 'system time' ~2000.1.1]
    !>  ->+>+>.move
  %+  expect-eq
    !>  db1
    !>  databases.state
  ==
::
++  test-cmd-create-db
  =|  run=@ud 
  =^  move  agent  
    %:  ~(on-poke agent (bowl [run ~2000.1.1]))
        %obelisk-action
        !>([%cmd-create-db [%create-database 'db1' ~]])
    ==
  =+  !<(=state on-save:agent)
  ;:  weld
  %+  expect-eq
    !>  [%result-da 'system time' ~2000.1.1]
    !>  ->+>+>.move
  %+  expect-eq
    !>  db1
    !>  databases.state
  ==
::
++  test-fail-tape-create-dup-db
  =|  run=@ud 
  =^  move  agent  
    %:  ~(on-poke agent (bowl [run ~2000.1.1]))
        %obelisk-action
        !>([%tape-create-db "CREATE DATABASE db1"])
    ==
  %-  expect-fail
  |.  %:  ~(on-poke agent (bowl [run ~2000.1.2]))
          %obelisk-action
          !>([%tape-create-db "CREATE DATABASE db1"])
      ==
::
::  Create namespace
++  test-tape-create-ns
  =|  run=@ud 
  =^  mov1  agent  
    %:  ~(on-poke agent (bowl [run ~2000.1.1]))
        %obelisk-action
        !>([%tape-create-db "CREATE DATABASE db1"])
    ==
  =.  run  +(run)
  =^  mov2  agent  
    %:  ~(on-poke agent (bowl [run ~2000.1.2]))
        %obelisk-action
        !>([%tape %db1 "CREATE NAMESPACE ns1"])
    ==
  =+  !<(=state on-save:agent)
  ;:  weld
%+  expect-eq
    !>  %results
    !>  ->+>+>-.mov2
  %+  expect-eq
    !>  [%result-da 'system time' ~2000.1.2]
    !>  ->+>+>+<.mov2
  %+  expect-eq
    !>  db2
    !>  databases.state
  ==
::
++  test-cmd-create-ns
  =|  run=@ud 
  =^  mov1  agent  
    %:  ~(on-poke agent (bowl [run ~2000.1.1]))
        %obelisk-action
        !>([%cmd-create-db [%create-database 'db1' ~]])
    ==
  =.  run  +(run)
  =^  mov2  agent  
    %:  ~(on-poke agent (bowl [run ~2000.1.2]))
        %obelisk-action
        !>([%commands ~[[%create-namespace %db1 %ns1 ~]]])
    ==
  =+  !<(=state on-save:agent)
  ;:  weld
  %+  expect-eq
    !>  %results
    !>  ->+>+>-.mov2
  %+  expect-eq
    !>  [%result-da 'system time' ~2000.1.2]
    !>  ->+>+>+<.mov2
  %+  expect-eq
    !>  db2
    !>  databases.state
  ==
::
++  test-fail-create-duplicate-ns
  =|  run=@ud 
  =^  mov1  agent  
    %:  ~(on-poke agent (bowl [run ~2000.1.1]))
        %obelisk-action
        !>([%cmd-create-db [%create-database 'db1' ~]])
    ==
  =.  run  +(run)
  =^  mov2  agent  
    %:  ~(on-poke agent (bowl [run ~2000.1.2]))
        %obelisk-action
        !>([%commands ~[[%create-namespace %db1 %ns1 ~]]])
    ==
  =.  run  +(run)
  %-  expect-fail
  |.  %:  ~(on-poke agent (bowl [run ~2000.1.3]))
          %obelisk-action
          !>([%commands ~[[%create-namespace %db1 %ns1 ~]]])
      ==
::
++  test-fail-ns-db-does-not-exist
  =|  run=@ud 
  =^  mov1  agent  
    %:  ~(on-poke agent (bowl [run ~2000.1.1]))
        %obelisk-action
        !>([%cmd-create-db [%create-database 'db1' ~]])
    ==
  =.  run  +(run)
  %-  expect-fail
  |.  %:  ~(on-poke agent (bowl [run ~2000.1.3]))
          %obelisk-action
          !>([%commands ~[[%create-namespace %db2 %ns1 ~]]])
      ==
::
::  Create table
++  test-cmd-create-1-col-tbl
  =|  run=@ud
  =^  mov1  agent  
    %:  ~(on-poke agent (bowl [run ~2000.1.1]))
        %obelisk-action
        !>([%cmd-create-db [%create-database 'db1' ~]])
    ==
  =.  run  +(run)
  =^  mov2  agent  
    %:  ~(on-poke agent (bowl [run ~2000.1.2]))
        %obelisk-action
        !>([%commands ~[cmd-one-col]])
    ==
  =+  !<(=state on-save:agent)
  ;:  weld
  %+  expect-eq
    !>  %results
    !>  ->+>+>-.mov2
  %+  expect-eq
    !>  [%result-da 'system time' ~2000.1.2]
    !>  ->+>+>+<.mov2
  %+  expect-eq
    !>  one-col-tbl-db
    !>  databases.state
  ==
::
++  test-tape-create-1-col-tbl
  =|  run=@ud
  =^  mov1  agent  
    %:  ~(on-poke agent (bowl [run ~2000.1.1]))
        %obelisk-action
        !>([%tape-create-db "CREATE DATABASE db1"])
    ==
  =.  run  +(run)
  =^  mov2  agent  
    %:  ~(on-poke agent (bowl [run ~2000.1.2]))
        %obelisk-action
        !>  :+  %tape
                %db1
                "CREATE TABLE db1..my-table (col1 @t) PRIMARY KEY (col1)"
    ==
  =+  !<(=state on-save:agent)
  ;:  weld
  %+  expect-eq
    !>  %results
    !>  ->+>+>-.mov2
  %+  expect-eq
    !>  [%result-da 'system time' ~2000.1.2]
    !>  ->+>+>+<.mov2
  %+  expect-eq
    !>  one-col-tbl-db
    !>  databases.state
  ==
::
++  test-cmd-create-2-col-tbl
  =|  run=@ud
 =^  mov1  agent  
    %:  ~(on-poke agent (bowl [run ~2000.1.1]))
        %obelisk-action
        !>([%cmd-create-db [%create-database 'db1' ~]])
    ==
  =.  run  +(run)
  =^  mov2  agent  
    %:  ~(on-poke agent (bowl [run ~2000.1.2]))
        %obelisk-action
        !>([%commands ~[cmd-one-col]])
    ==
  =^  mov3  agent  
    %:  ~(on-poke agent (bowl [run ~2000.1.3]))
        %obelisk-action
        !>([%commands ~[cmd-two-col]])
    ==
  =+  !<(=state on-save:agent)
  ;:  weld
  %+  expect-eq
    !>  %results
    !>  ->+>+>-.mov3
  %+  expect-eq
    !>  [%result-da 'system time' ~2000.1.3]
    !>  ->+>+>+<.mov3
  %+  expect-eq
    !>  two-col-tbl-db
    !>  databases.state
  ==
::
++  test-tape-create-2-col-tbl
  =|  run=@ud
 =^  mov1  agent  
    %:  ~(on-poke agent (bowl [run ~2000.1.1]))
        %obelisk-action
        !>([%tape-create-db "CREATE DATABASE db1"])
    ==
  =.  run  +(run)
  =^  mov2  agent  
    %:  ~(on-poke agent (bowl [run ~2000.1.2]))
        %obelisk-action
        !>  :+  %tape
                %db1
                "CREATE TABLE db1..my-table (col1 @t) ".
                "PRIMARY KEY CLUSTERED (col1)"
    ==
  =^  mov3  agent  
    %:  ~(on-poke agent (bowl [run ~2000.1.3]))
        %obelisk-action
        !>  :+  %tape
                %db1
                "CREATE TABLE db1..my-table-2 (col1 @t, col2 @p) ".
                "PRIMARY KEY LOOK-UP (col1, col2)"
    ==
  =+  !<(=state on-save:agent)
  ;:  weld
  %+  expect-eq
    !>  %results
    !>  ->+>+>-.mov3
  %+  expect-eq
    !>  [%result-da 'system time' ~2000.1.3]
    !>  ->+>+>+<.mov3
  %+  expect-eq
    !>  two-col-tbl-db
    !>  databases.state
  ==
::
++  test-cmd-create-comb-2-col-tbl
  =|  run=@ud
 =^  mov1  agent  
    %:  ~(on-poke agent (bowl [run ~2000.1.1]))
        %obelisk-action
        !>([%cmd-create-db [%create-database 'db1' ~]])
    ==
  =.  run  +(run)
  =^  mov2  agent  
    %:  ~(on-poke agent (bowl [run ~2000.1.2]))
        %obelisk-action
        !>([%commands ~[cmd-two-col cmd-one-col]])
    ==
  =+  !<(=state on-save:agent)
  ;:  weld
  %+  expect-eq
    !>  %results
    !>  ->+>+>-.mov2
  %+  expect-eq
    !>  [%result-da 'system time' ~2000.1.2]
    !>  ->+>+>+<.mov2
  %+  expect-eq
    !>  two-comb-col-tbl-db
    !>  databases.state
  ==
::
++  test-tape-create-comb-2-col-tbl
  =|  run=@ud
 =^  mov1  agent  
    %:  ~(on-poke agent (bowl [run ~2000.1.1]))
        %obelisk-action
        !>([%tape-create-db "CREATE DATABASE db1"])
    ==
  =.  run  +(run)
  =^  mov2  agent  
    %:  ~(on-poke agent (bowl [run ~2000.1.2]))
        %obelisk-action
        !>  :+  %tape
                %db1
                "CREATE TABLE db1..my-table (col1 @t) PRIMARY KEY (col1); ".
                "CREATE TABLE db1..my-table-2 (col1 @t, col2 @p) ".
                "PRIMARY KEY LOOK-UP (col1, col2)"
    ==
  =+  !<(=state on-save:agent)
  ;:  weld
  %+  expect-eq
    !>  %results
    !>  ->+>+>-.mov2
  %+  expect-eq
    !>  [%result-da 'system time' ~2000.1.2]
    !>  ->+>+>+<.mov2
  %+  expect-eq
    !>  two-comb-col-tbl-db
    !>  databases.state
  ==

:: to do: create table with foreign keys
::        fail on referenced table does not exist
::        fail on referenced table columns not a unique key
::        fail on fk columns not in table def columns
::        fail on fk column auras do not match referenced column auras

::
::  fail on database does not exist
++  test-fail-tbl-db-does-not-exist
  =|  run=@ud
  =/  cmd
    :*  %create-table
        [%qualified-object ship=~ database='db' namespace='dbo' name='my-table']
        :~  [%column name='col1' column-type=%t]
            [%column name='col2' column-type=%p]
            [%column name='col3' column-type=%ud]
        ==
        clustered=%.n
        pri-indx=~[[%ordered-column column-name='col1' ascending=%.y]]
        foreign-keys=~
        as-of=~
    ==
  =^  mov1  agent  
    %:  ~(on-poke agent (bowl [run ~2000.1.1]))
        %obelisk-action
        !>([%cmd-create-db [%create-database 'db1' ~]])
    ==
  =.  run  +(run)
  %-  expect-fail
  |.  %:  ~(on-poke agent (bowl [run ~2000.1.3]))
          %obelisk-action
          !>([%commands ~[cmd]])
    ==
::
::  fail on namespace does not exist
++  test-fail-tbl-ns-does-not-exist
  =|  run=@ud
  =/  cmd
    :*  %create-table
        :*  %qualified-object
            ship=~
            database='db1'
            namespace='ns1'
            name='my-table'
        ==
        :~  [%column name='col1' column-type=%t]
            [%column name='col2' column-type=%p]
            [%column name='col3' column-type=%ud]
        ==
        clustered=%.n
        pri-indx=~[[%ordered-column column-name='col1' ascending=%.y]]
        foreign-keys=~
        as-of=~
    == 
  =^  mov1  agent  
    %:  ~(on-poke agent (bowl [run ~2000.1.1]))
        %obelisk-action
        !>([%cmd-create-db [%create-database 'db1' ~]])
    ==
  =.  run  +(run)
  %-  expect-fail
  |.  %:  ~(on-poke agent (bowl [run ~2000.1.3]))
          %obelisk-action
          !>([%commands ~[cmd]])
    ==
::
::  fail on duplicate table name
++  test-fail-duplicate-tbl
  =|  run=@ud
  =/  cmd
    :*  %create-table
        :*  %qualified-object
            ship=~
            database='db1'
            namespace='dbo'
            name='my-table'
        ==
        :~  [%column name='col1' column-type=%t]
            [%column name='col2' column-type=%p]
            [%column name='col3' column-type=%ud]
        ==
        clustered=%.n
        pri-indx=~[[%ordered-column column-name='col1' ascending=%.y]]
        foreign-keys=~
        as-of=~
    ==
  =^  mov1  agent  
    %:  ~(on-poke agent (bowl [run ~2000.1.1]))
        %obelisk-action
        !>([%cmd-create-db [%create-database 'db1' ~]])
    ==
  =.  run  +(run)
  =^  mov2  agent  
    %:  ~(on-poke agent (bowl [run ~2000.1.2]))
        %obelisk-action
        !>([%commands ~[cmd]])
    ==
  =.  run  +(run)
  %-  expect-fail
  |.  %:  ~(on-poke agent (bowl [run ~2000.1.3]))
          %obelisk-action
          !>([%commands ~[cmd]])
    ==
::
::  fail on duplicate column names
++  test-fail-tbl-dup-cols
  =|  run=@ud
  =/  cmd
    :*  %create-table
        :*  %qualified-object
            ship=~
            database='db1'
            namespace='dbo'
            name='my-table'
        ==
        :~  [%column name='col1' column-type=%t]
            [%column name='col2' column-type=%p]
            [%column name='col1' column-type=%t]
        ==
        clustered=%.n
        pri-indx=~[[%ordered-column column-name='col1' ascending=%.y]]
        foreign-keys=~
        as-of=~
    ==
  =^  mov1  agent  
    %:  ~(on-poke agent (bowl [run ~2000.1.1]))
        %obelisk-action
        !>([%cmd-create-db [%create-database 'db1' ~]])
    ==
  =.  run  +(run)
  %-  expect-fail
  |.  %:  ~(on-poke agent (bowl [run ~2000.1.3]))
          %obelisk-action
          !>([%commands ~[cmd]])
    ==
  ::
  ::  fail on duplicate column names in key
  ++  test-fail-tbl-dup-key-cols
  =|  run=@ud
  =/  cmd
    :*  %create-table
        :*  %qualified-object
            ship=~
            database='db1'
            namespace='dbo'
            name='my-table'
        ==
        :~  [%column name='col1' column-type=%t]
            [%column name='col2' column-type=%p]
            [%column name='col3' column-type=%ud]
        ==
        clustered=%.n
        :~  [%ordered-column column-name='col1' ascending=%.y]
            [%ordered-column column-name='col1' ascending=%.y]
        ==
        foreign-keys=~
        as-of=~
    ==
  =^  mov1  agent  
    %:  ~(on-poke agent (bowl [run ~2000.1.1]))
        %obelisk-action
        !>([%cmd-create-db [%create-database 'db1' ~]])
    ==
  =.  run  +(run)
  %-  expect-fail
  |.  %:  ~(on-poke agent (bowl [run ~2000.1.3]))
          %obelisk-action
          !>([%commands ~[cmd]])
    ==
  ::
  ::  fail on key column not in column definitions
  ++  test-fail-tbl-key-col-not-exists
  =|  run=@ud
  =/  cmd
    :*  %create-table
        :*  %qualified-object
            ship=~
            database='db1'
            namespace='dbo'
            name='my-table'
        ==
        :~  [%column name='col1' column-type=%t]
            [%column name='col2' column-type=%p]
            [%column name='col3' column-type=%ud]
        ==
        clustered=%.n
        :~  [%ordered-column column-name='col1' ascending=%.y]
            [%ordered-column column-name='col4' ascending=%.y]
        ==
        foreign-keys=~
        as-of=~
    == 
  =^  mov1  agent  
    %:  ~(on-poke agent (bowl [run ~2000.1.1]))
        %obelisk-action
        !>([%cmd-create-db [%create-database 'db1' ~]])
    ==
  =.  run  +(run)
  %-  expect-fail
  |.  %:  ~(on-poke agent (bowl [run ~2000.1.3]))
          %obelisk-action
          !>([%commands ~[cmd]])
    ==
::
::  Drop table
::
::  drop table no data
++  test-drop-tbl
  =|  run=@ud
  =/  cmd
    :^  %drop-table
        :*  %qualified-object
            ship=~
            database='db1'
            namespace='dbo'
            name='my-table'
        ==
        %.n
        ~
  =^  mov1  agent  
    %:  ~(on-poke agent (bowl [run ~2000.1.1]))
        %obelisk-action
        !>([%tape-create-db "CREATE DATABASE db1"])
    ==
  =.  run  +(run)
  =^  mov2  agent  
    %:  ~(on-poke agent (bowl [run ~2000.1.2]))
        %obelisk-action
        !>  :+  %tape
                %db1
                "CREATE TABLE db1..my-table (col1 @t) PRIMARY KEY (col1)"
    ==
  =.  run  +(run)
  =^  mov3  agent  
    %:  ~(on-poke agent (bowl [run ~2000.1.3]))
        %obelisk-action
        !>([%commands ~[cmd]])
    ==
  =+  !<(=state on-save:agent)
  ;:  weld
  %+  expect-eq
    !>  %results
    !>  ->+>+>-.mov3
  %+  expect-eq
    !>  [%result-da 'system time' ~2000.1.3]
    !>  ->+>+>+<.mov3
  %+  expect-eq
    !>  dropped-tbl-db
    !>  databases.state
  ==
::
::  drop table with data force
++  test-drop-tbl-force
  =|  run=@ud
  =/  cmd
    :^  %drop-table
        :*  %qualified-object
            ship=~
            database='db1'
            namespace='dbo'
            name='my-table'
        ==
        %.y
        ~
  =^  mov1  agent  
    %:  ~(on-poke agent (bowl [run ~2000.1.1]))
        %obelisk-action
        !>([%tape-create-db "CREATE DATABASE db1"])
    ==
  =.  run  +(run)
  =^  mov2  agent  
    %:  ~(on-poke agent (bowl [run ~2000.1.2]))
        %obelisk-action
        !>  :+  %tape
                %db1
                "CREATE TABLE db1..my-table (col1 @t) PRIMARY KEY (col1)"
    ==
  =.  run  +(run)
  =^  mov3  agent  
    %:  ~(on-poke agent (bowl [run ~2000.1.3]))
        %obelisk-action
        !>([%tape %db1 "INSERT INTO db1..my-table (col1) VALUES ('cord')"])
    ==
  =.  run  +(run)
  =^  mov4  agent  
    %:  ~(on-poke agent (bowl [run ~2000.1.4]))
        %obelisk-action
        !>([%commands ~[cmd]])
    ==
  =+  !<(=state on-save:agent)
  ;:  weld
  %+  expect-eq
    !>  %results
    !>  ->+>+>-.mov4
  %+  expect-eq
    !>  [%result-da 'system time' ~2000.1.4]
    !>  ->+>+>+<.mov4
  %+  expect-eq
    !>  dropped-tbl-db-force
    !>  databases.state
  ==
::
::  fail drop table with data no force
++  test-fail-drop-tbl-with-data
  =|  run=@ud
  =/  cmd
    :^  %drop-table
        :*  %qualified-object
            ship=~
            database='db1'
            namespace='dbo'
            name='my-table'
        ==
        %.n
        ~
  =^  mov1  agent  
    %:  ~(on-poke agent (bowl [run ~2000.1.1]))
        %obelisk-action
        !>([%tape-create-db "CREATE DATABASE db1"])
    ==
  =.  run  +(run)
  =^  mov2  agent  
    %:  ~(on-poke agent (bowl [run ~2000.1.2]))
        %obelisk-action
        !>  :+  %tape
                %db1
                "CREATE TABLE db1..my-table (col1 @t) PRIMARY KEY (col1)"
    ==
  =.  run  +(run)
  =^  mov3  agent  
    %:  ~(on-poke agent (bowl [run ~2000.1.3]))
        %obelisk-action
        !>([%tape %db1 "INSERT INTO db1..my-table (col1) VALUES ('cord')"])
    ==
  =.  run  +(run)
  %-  expect-fail
  |.  %:  ~(on-poke agent (bowl [run ~2000.1.4]))
          %obelisk-action
          !>([%commands ~[cmd]])
      ==
::
::  fail on database does not exist
++  test-fail-drop-tbl-db-not-exist     
  =|  run=@ud
  =/  cmd
    :^  %drop-table
        [%qualified-object ship=~ database='db' namespace='dbo' name='my-table']
        %.n
        ~
  =^  mov1  agent  
    %:  ~(on-poke agent (bowl [run ~2000.1.1]))
        %obelisk-action
        !>([%cmd-create-db [%create-database 'db1' ~]])
    ==
  =.  run  +(run)
  %-  expect-fail
  |.  %:  ~(on-poke agent (bowl [run ~2000.1.3]))
      %obelisk-action
      !>([%commands ~[cmd]])
    ==
::
::  fail on namespace does not exist
++  test-fail-drop-tbl-ns-not-exist     
  =|  run=@ud
  =/  cmd
    :^  %drop-table
        :*  %qualified-object
            ship=~
            database='db1'
            namespace='ns1'
            name='my-table'
        ==
        %.n
        ~
  =^  mov1  agent  
    %:  ~(on-poke agent (bowl [run ~2000.1.1]))
        %obelisk-action
        !>([%cmd-create-db [%create-database 'db1' ~]])
    ==
  =.  run  +(run)
  %-  expect-fail
  |.  %:  ~(on-poke agent (bowl [run ~2000.1.3]))
      %obelisk-action
      !>([%commands ~[cmd]])
    ==
::
::  fail on table name does not exist
++  test-fail-drop-tbl-not-exist        
  =|  run=@ud
  =/  cmd
    :^  %drop-table
        :*  %qualified-object
            ship=~
            database='db1'
            namespace='dbo'
            name='my-table'
        ==
        %.n
        ~
  =^  mov1  agent  
    %:  ~(on-poke agent (bowl [run ~2000.1.1]))
        %obelisk-action
        !>([%cmd-create-db [%create-database 'db1' ~]])
    ==
  =.  run  +(run)
  %-  expect-fail
  |.  %:  ~(on-poke agent (bowl [run ~2000.1.3]))
          %obelisk-action
          !>([%commands ~[cmd]])
    ==
::
:: system views
++  test-sys-sys-databases
  =|  run=@ud
  =/  col-row  :~  [%database %tas]
                  [%sys-agent %tas]
                  [%sys-tmsp %da]
                  [%data-ship %p]
                  [%data-agent %tas]
                  [%data-tmsp %da]
                ==
  =/  row1  ~[%db1 '/test-agent' ~2000.1.1 0 '/test-agent' ~2000.1.1]
  =/  row2  ~[%db1 '/test-agent' ~2000.1.2 0 '/test-agent' ~2000.1.2]
  =/  row3  ~[%db1 '/test-agent' ~2000.1.2 0 '/test-agent' ~2000.1.3]
  =/  row4  ~[%db2 '/test-agent' ~2000.1.4 0 '/test-agent' ~2000.1.4]
  =/  row5  ~[%db2 '/test-agent' ~2000.1.5 0 '/test-agent' ~2000.1.5]
  =/  expected  :~  %results
                    :~  %result-set
                        'sys.sys.databases'
                        col-row
                        row1
                        row2
                        row3
                        row4
                        row5
                    ==
                ==
  =/  cmd
    :^  %drop-table
        :*  %qualified-object
            ship=~
            database='db1'
            namespace='dbo'
            name='my-table'
        ==
        %.y
        ~
  =^  mov1  agent  
    %:  ~(on-poke agent (bowl [run ~2000.1.1]))
        %obelisk-action
        !>([%tape-create-db "CREATE DATABASE db1"])
    ==
  =.  run  +(run)
  =^  mov2  agent  
    %:  ~(on-poke agent (bowl [run ~2000.1.2]))
        %obelisk-action
        !>  :+  %tape
                %db1
                "CREATE TABLE db1..my-table (col1 @t) PRIMARY KEY (col1)"
    ==
  =.  run  +(run)
  =^  mov3  agent  
    %:  ~(on-poke agent (bowl [run ~2000.1.3]))
        %obelisk-action
        !>([%tape %db1 "INSERT INTO db1..my-table (col1) VALUES ('cord')"])
    ==
  =.  run  +(run)
  =^  mov4  agent  
    %:  ~(on-poke agent (bowl [run ~2000.1.4]))
        %obelisk-action
        !>([%tape-create-db "CREATE DATABASE db2"])
    ==
  =.  run  +(run)
  =^  mov5  agent  
    %:  ~(on-poke agent (bowl [run ~2000.1.5]))
        %obelisk-action
        !>  :+  %tape
                %db1
                "CREATE TABLE db2..my-table (col1 @t) PRIMARY KEY (col1)"
    ==
  =.  run  +(run)
  =^  mov6  agent  
    %:  ~(on-poke agent (bowl [run ~2000.1.5]))
        %obelisk-action
        !>([%tape %db1 "FROM sys.sys.databases SELECT *"])
    ==
  %+  expect-eq
    !>  expected
    !>  ->+>+>.mov6
::
++  test-sys-tables
  =|  run=@ud
  =/  col-row  :~  [%namespace %tas]
                  [%name %tas]
                  [%ship %p]
                  [%agent %tas]
                  [%tmsp %da]
                  [%row-count %ud]
                  [%clustered %f]
                  [%key-ordinal %ud]
                  [%key %tas]
                  [%key-ascending %f]
                  [%col-ordinal %ud]
                  [%col-name %tas]
                  [%col-type %tas]
                ==
  =/  row1  ~[%dbo %my-table 0 '/test-agent' ~2000.1.3 1 0 1 %col1 0 1 %col1 %t]
  =/  row2  ~[%dbo %my-table 0 '/test-agent' ~2000.1.3 1 0 1 %col1 0 2 %col2 %t]
  =/  row3  ~[%dbo %my-table 0 '/test-agent' ~2000.1.3 1 0 2 %col2 1 1 %col1 %t]
  =/  row4  ~[%dbo %my-table 0 '/test-agent' ~2000.1.3 1 0 2 %col2 1 2 %col2 %t]
  =/  row5  :~  %dbo
                %my-table-2
                0
                '/test-agent'
                ~2000.1.4
                0
                0
                1
                %col1
                1
                1
                %col1
                %p
              ==
  =/  row6  :~  %dbo
                %my-table-2
                0
                '/test-agent'
                ~2000.1.4
                0
                0
                1
                %col1
                1
                2
                %col2
                %t
              ==
  =/  row7  :~  %dbo
                %my-table-2
                0
                '/test-agent'
                ~2000.1.4
                0
                0
                2
                %col2
                0
                1
                %col1
                %p
              ==
  =/  row8  :~  %dbo
                %my-table-2
                0
                '/test-agent'
                ~2000.1.4
                0
                0
                2
                %col2
                0
                2
                %col2
                %t
              ==
  =/  row9  :~  %dbo
                %my-table-3
                0
                '/test-agent'
                ~2000.1.4
                0
                0
                1
                %col1
                0
                1
                %col1
                %p
              ==
  =/  row10  :~  %dbo
                %my-table-3
                0
                '/test-agent'
                ~2000.1.4
                0
                0
                1
                %col1
                0
                2
                %col2
                %t
              ==
  =/  row11  :~  %dbo
                %my-table-3
                0
                '/test-agent'
                ~2000.1.4
                0
                0
                1
                %col1
                0
                3
                %col3
                %ud
              ==
  =/  row12  :~  %dbo
                %my-table-4
                0
                '/test-agent'
                ~2000.1.6
                0
                0
                1
                %col1
                0
                1
                %col1
                %p
              ==
  =/  row13  :~  %dbo
                %my-table-4
                0
                '/test-agent'
                ~2000.1.6
                0
                0
                1
                %col1
                0
                2
                %col2
                %t
              ==
  =/  row14  :~  %dbo
                %my-table-4
                0
                '/test-agent'
                ~2000.1.6
                0
                0
                1
                %col1
                0
                3
                %col3
                %ud
              ==
  =/  row15  :~  %dbo
                %my-table-4
                0
                '/test-agent'
                ~2000.1.6
                0
                0
                2
                %col3
                0
                1
                %col1
                %p
              ==
  =/  row16  :~  %dbo
                %my-table-4
                0
                '/test-agent'
                ~2000.1.6
                0
                0
                2
                %col3
                0
                2
                %col2
                %t
              ==
  =/  row17  :~  %dbo
                %my-table-4
                0
                '/test-agent'
                ~2000.1.6
                0
                0
                2
                %col3
                0
                3
                %col3
                %ud
              ==
  =/  row18  :~  %ref
                %my-table-4
                0
                '/test-agent'
                ~2000.1.7
                0
                0
                1
                %col1
                0
                1
                %col1
                %p
              ==
  =/  row19  :~  %ref
                %my-table-4
                0
                '/test-agent'
                ~2000.1.7
                0
                0
                1
                %col1
                0
                2
                %col2
                %t
              ==
  =/  row20  :~  %ref
                %my-table-4
                0
                '/test-agent'
                ~2000.1.7
                0
                0
                1
                %col1
                0
                3
                %col3
                %ud
              ==
  =/  row21  :~  %ref
                %my-table-4
                0
                '/test-agent'
                ~2000.1.7
                0
                0
                2
                %col3
                0
                1
                %col1
                %p
              ==
  =/  row22  :~  %ref
                %my-table-4
                0
                '/test-agent'
                ~2000.1.7
                0
                0
                2
                %col3
                0
                2
                %col2
                %t
              ==
  =/  row23  :~  %ref
                %my-table-4
                0
                '/test-agent'
                ~2000.1.7
                0
                0
                2
                %col3
                0
                3
                %col3
                %ud
              ==
  =/  expected  :~  %results
                    :~  %result-set
                        ~.db1.sys.tables
                        col-row
                        row1
                        row2
                        row3
                        row4
                        row5
                        row6
                        row7
                        row8
                        row9
                        row10
                        row11
                        row12
                        row13
                        row14
                        row15
                        row16
                        row17
                        row18
                        row19
                        row20
                        row21
                        row22
                        row23
                    ==
                ==
  =/  cmd
    :^  %drop-table
        :*  %qualified-object
            ship=~
            database='db1'
            namespace='dbo'
            name='my-table'
        ==
        %.y
        ~
  =^  mov1  agent  
    %:  ~(on-poke agent (bowl [run ~2000.1.1]))
        %obelisk-action
        !>([%tape-create-db "CREATE DATABASE db1"])
    ==
  =.  run  +(run)
  =^  mov2  agent  
    %:  ~(on-poke agent (bowl [run ~2000.1.2]))
        %obelisk-action
        !>  :+  %tape
                %db1
                "CREATE TABLE db1..my-table (col1 @t, col2 @t) ".
                "PRIMARY KEY (col1, col2 DESC)"
    ==
  =.  run  +(run)
  =^  mov3  agent  
    %:  ~(on-poke agent (bowl [run ~2000.1.3]))
        %obelisk-action
        !>  :+  %tape
                %db1
                "INSERT INTO db1..my-table (col1, col2) ".
                "VALUES ('cord', 'cord2')"
    ==
  =.  run  +(run)
  =^  mov4  agent  
    %:  ~(on-poke agent (bowl [run ~2000.1.4]))
        %obelisk-action
        !>  :+  %tape
                %db1
                "CREATE TABLE db1..my-table-2 (col1 @p, col2 @t) ".
                "PRIMARY KEY (col1 desc, col2); ".
                "CREATE TABLE db1..my-table-3 (col1 @p, col2 @t, col3 @ud) ".
                "PRIMARY KEY (col1)"
    ==
  =.  run  +(run)
  =^  mov5  agent  
    %:  ~(on-poke agent (bowl [run ~2000.1.5]))
        %obelisk-action
        !>([%tape %db1 "CREATE NAMESPACE ref"])
    ==
  =.  run  +(run)
  =^  mov6  agent  
    %:  ~(on-poke agent (bowl [run ~2000.1.6]))
        %obelisk-action
        !>  :+  %tape
                %db1
                "CREATE TABLE db1..my-table-4 (col1 @p, col2 @t, col3 @ud) ".
                "PRIMARY KEY (col1, col3)"
    ==
  =.  run  +(run)
  =^  mov7  agent  
    %:  ~(on-poke agent (bowl [run ~2000.1.7]))
        %obelisk-action
        !>  :+  %tape
                %db1
                "CREATE TABLE db1.ref.my-table-4 (col1 @p, col2 @t, col3 @ud) ".
                "PRIMARY KEY (col1, col3)"
    ==
  =.  run  +(run)
  =^  mov8  agent  
    %:  ~(on-poke agent (bowl [run ~2000.1.8]))
        %obelisk-action
        !>([%tape %db1 "FROM sys.tables SELECT *"])
    ==
  %+  expect-eq
    !>  expected
    !>  ->+>+>.mov8
::
++  test-sys-columns
  =|  run=@ud
  =/  col-row  :~  [%namespace %tas]
                  [%name %tas]
                  [%col-ordinal %ud]
                  [%col-name %tas]
                  [%col-type %tas]
                ==
  =/  row1  ~[%dbo %my-table-2 1 %col1 %p]
  =/  row2  ~[%dbo %my-table-2 2 %col2 %t]
  =/  row3  ~[%dbo %my-table-3 1 %col1 %p]
  =/  row4  ~[%dbo %my-table-3 2 %col2 %t]
  =/  row5  ~[%dbo %my-table-3 3 %col3 %ud]
  =/  row6  ~[%dbo %my-table-4 1 %col1 %p]
  =/  row7  ~[%dbo %my-table-4 2 %col2 %t]
  =/  row8  ~[%dbo %my-table-4 3 %col3 %ud]
  =/  row9  ~[%ref %my-table 1 %col1 %t]
  =/  row10  ~[%ref %my-table 2 %col2 %t]
  =/  expected  :~  %results
                    :~  %result-set
                        ~.db1.sys.columns
                        col-row
                        row1
                        row2
                        row3
                        row4
                        row5
                        row6
                        row7
                        row8
                        row9
                        row10
                    ==
                ==
  =/  cmd  :^  %drop-table
              :*  %qualified-object
                  ship=~
                  database='db1'
                  namespace='dbo'
                  name='my-table'
              ==
              %.y
              ~
  =^  mov1  agent  
    %:  ~(on-poke agent (bowl [run ~2000.1.1]))
        %obelisk-action
        !>([%tape-create-db "CREATE DATABASE db1"])
    ==
  =.  run  +(run)
  =^  mov2  agent  
    %:  ~(on-poke agent (bowl [run ~2000.1.2]))
        %obelisk-action
        !>([%tape %db1 "CREATE NAMESPACE db1.ref"])
    ==
  =.  run  +(run)
  =^  mov3  agent  
    %:  ~(on-poke agent (bowl [run ~2000.1.3]))
        %obelisk-action
        !>  :+  %tape
                %db1
                "CREATE TABLE db1.ref.my-table (col1 @t, col2 @t) ".
                "PRIMARY KEY (col1, col2 DESC)"
    ==
  =.  run  +(run)
  =^  mov4  agent  
    %:  ~(on-poke agent (bowl [run ~2000.1.4]))
        %obelisk-action
        !>  :+  %tape
                %db1
                "CREATE TABLE db1..my-table-2 (col1 @p, col2 @t) ".
                "PRIMARY KEY (col1 desc, col2); ".
                "CREATE TABLE db1..my-table-3 (col1 @p, col2 @t, col3 @ud) ".
                "PRIMARY KEY (col1)"
    ==
  =.  run  +(run)
  =^  mov5  agent  
    %:  ~(on-poke agent (bowl [run ~2000.1.5]))
        %obelisk-action
        !>  :+  %tape
                %db1
                "CREATE TABLE db1..my-table-4 (col1 @p, col2 @t, col3 @ud) ".
                "PRIMARY KEY (col1, col3)"
    ==
  =.  run  +(run)
  =^  mov6  agent  
    %:  ~(on-poke agent (bowl [run ~2000.1.6]))
        %obelisk-action
        !>([%tape %db1 "FROM sys.columns SELECT *"])
    ==
  %+  expect-eq
    !>  expected
    !>  ->+>+>.mov6
::
++  test-sys-log
  =|  run=@ud
  =/  col-row  ~[[%tmsp %da] [%agent %tas] [%component %tas] [%name %tas]]
  =/  row1  ~[~2000.1.7 '/test-agent' %ref %my-table-4]
  =/  row2  ~[~2000.1.6 '/test-agent' %dbo %my-table-4]
  =/  row3  ~[~2000.1.5 '/test-agent' %namespace %ref]
  =/  row4  ~[~2000.1.4 '/test-agent' %dbo %my-table-2]
  =/  row5  ~[~2000.1.4 '/test-agent' %dbo %my-table-3]
  =/  row6  ~[~2000.1.2 '/test-agent' %dbo %my-table]
  =/  row7  ~[~2000.1.1 '/test-agent' %namespace %dbo]
  =/  row8  ~[~2000.1.1 '/test-agent' %namespace %sys]
  =/  expected  :~  %results
                    :~  %result-set
                        ~.db1.sys.sys-log
                        col-row
                        row1
                        row2
                        row3
                        row4
                        row5
                        row6
                        row7
                        row8
                    ==
                ==
  =/  cmd
    :^  %drop-table
        :*  %qualified-object
            ship=~
            database='db1'
            namespace='dbo'
            name='my-table'
        ==
        %.y
        ~
  =^  mov1  agent  
    %:  ~(on-poke agent (bowl [run ~2000.1.1]))
        %obelisk-action
        !>([%tape-create-db "CREATE DATABASE db1"])
    ==
  =.  run  +(run)
  =^  mov2  agent  
    %:  ~(on-poke agent (bowl [run ~2000.1.2]))
        %obelisk-action
        !>  :+  %tape
                %db1
                "CREATE TABLE db1..my-table (col1 @t, col2 @t) ".
                "PRIMARY KEY (col1, col2 DESC)"
    ==
  =.  run  +(run)
  =^  mov3  agent  
    %:  ~(on-poke agent (bowl [run ~2000.1.4]))
        %obelisk-action
        !>  :+  %tape
                %db1
                "CREATE TABLE db1..my-table-2 (col1 @p, col2 @t) ".
                "PRIMARY KEY (col1 desc, col2); ".
                "CREATE TABLE db1..my-table-3 (col1 @p, col2 @t, col3 @ud) ".
                "PRIMARY KEY (col1)"
    ==
  =.  run  +(run)
  =^  mov4  agent  
    %:  ~(on-poke agent (bowl [run ~2000.1.5]))
        %obelisk-action
        !>([%tape %db1 "CREATE NAMESPACE ref"])
    ==
  =.  run  +(run)
  =^  mov5  agent  
    %:  ~(on-poke agent (bowl [run ~2000.1.6]))
        %obelisk-action
        !>  :+  %tape
                %db1
                "CREATE TABLE db1..my-table-4 (col1 @p, col2 @t, col3 @ud) ".
                "PRIMARY KEY (col1, col3)"
    ==
  =.  run  +(run)
  =^  mov6  agent  
    %:  ~(on-poke agent (bowl [run ~2000.1.7]))
        %obelisk-action
        !>  :+  %tape
                %db1
                "CREATE TABLE db1.ref.my-table-4 (col1 @p, col2 @t, col3 @ud) ".
                "PRIMARY KEY (col1, col3)"
    ==
  =.  run  +(run)
  =^  mov7  agent  
    %:  ~(on-poke agent (bowl [run ~2000.1.8]))
        %obelisk-action
        !>([%tape %db1 "FROM sys.sys-log SELECT *"])
    ==
  %+  expect-eq
    !>  expected
    !>  ->+>+>.mov7
::
++  test-data-log
  =|  run=@ud
  =/  col-row  :~  [%tmsp %da]
                  [%ship %p]
                  [%agent %tas]
                  [%namespace %tas]
                  [%table %tas]
                ==
  =/  row1  ~[~2000.1.10 0 '/test-agent' %ref %my-table-4]
  =/  row2  ~[~2000.1.9 0 '/test-agent' %ref %my-table-4]
  =/  row3  ~[~2000.1.8 0 '/test-agent' %dbo %my-table-4]
  =/  row4  ~[~2000.1.7 0 '/test-agent' %dbo %my-table-4]
  =/  row5  ~[~2000.1.5 0 '/test-agent' %dbo %my-table-2]
  =/  row6  ~[~2000.1.4 0 '/test-agent' %dbo %my-table-2]
  =/  row7  ~[~2000.1.4 0 '/test-agent' %dbo %my-table-3]
  =/  row8  ~[~2000.1.3 0 '/test-agent' %dbo %my-table]
  =/  row9  ~[~2000.1.2 0 '/test-agent' %dbo %my-table]
  =/  expected  :~  %results
                    :~  %result-set
                        ~.db1.sys.data-log
                        col-row
                        row1
                        row2
                        row3
                        row4
                        row5
                        row6
                        row7
                        row8
                        row9
                    ==
                ==
  =/  cmd
    :^  %drop-table
        :*  %qualified-object
            ship=~
            database='db1'
            namespace='dbo'
            name='my-table'
        ==
        %.y
        ~
  =^  mov1  agent  
    %:  ~(on-poke agent (bowl [run ~2000.1.1]))
        %obelisk-action
        !>([%tape-create-db "CREATE DATABASE db1"])
    ==
  =.  run  +(run)
  =^  mov2  agent  
    %:  ~(on-poke agent (bowl [run ~2000.1.2]))
        %obelisk-action
        !>  :+  %tape
                %db1
                "CREATE TABLE db1..my-table (col1 @t, col2 @t) ".
                "PRIMARY KEY (col1, col2 DESC)"
    ==
    =.  run  +(run)
  =^  mov3  agent  
    %:  ~(on-poke agent (bowl [run ~2000.1.3]))
        %obelisk-action
        !>  :+  %tape
                %db1
                "INSERT INTO db1..my-table (col1, col2) ".
                "VALUES ('cord', 'cord2')"
    ==
  =.  run  +(run)
  =^  mov4  agent  
    %:  ~(on-poke agent (bowl [run ~2000.1.4]))
        %obelisk-action
        !>  :+  %tape
                %db1
                "CREATE TABLE db1..my-table-2 (col1 @p, col2 @t) ".
                "PRIMARY KEY (col1 desc, col2); ".
                "CREATE TABLE db1..my-table-3 (col1 @p, col2 @t, col3 @ud) ".
                "PRIMARY KEY (col1)"
    ==
    =.  run  +(run)
  =^  mov5  agent  
    %:  ~(on-poke agent (bowl [run ~2000.1.5]))
        %obelisk-action
        !>  :+  %tape
                %db1
                "INSERT INTO db1..my-table-2 (col1, col2) ".
                "VALUES (~zod, 'cord2')"
    ==
  =.  run  +(run)
  =^  mov6  agent  
    %:  ~(on-poke agent (bowl [run ~2000.1.6]))
        %obelisk-action
        !>([%tape %db1 "CREATE NAMESPACE ref"])
    ==
  =.  run  +(run)
  =^  mov7  agent  
    %:  ~(on-poke agent (bowl [run ~2000.1.7]))
        %obelisk-action
        !>  :+  %tape
                %db1
                "CREATE TABLE db1..my-table-4 (col1 @p, col2 @t, col3 @ud) ".
                "PRIMARY KEY (col1, col3)"
    ==
    =.  run  +(run)
  =^  mov8  agent  
    %:  ~(on-poke agent (bowl [run ~2000.1.8]))
        %obelisk-action
        !>  :+  %tape
                %db1
                "INSERT INTO db1..my-table-4 (col1, col2, col3) ".
                "VALUES (~zod, 'cord2', 42)"
    ==
  =.  run  +(run)
  =^  mov9  agent  
    %:  ~(on-poke agent (bowl [run ~2000.1.9]))
        %obelisk-action
        !>  :+  %tape
                %db1
                "CREATE TABLE db1.ref.my-table-4 (col1 @p, col2 @t, col3 @ud) ".
                "PRIMARY KEY (col1, col3)"
    ==
    =.  run  +(run)
  =^  mov10  agent  
    %:  ~(on-poke agent (bowl [run ~2000.1.10]))
        %obelisk-action
        !>  :+  %tape
                %db1
                "INSERT INTO db1.ref.my-table-4 (col1, col2, col3) ".
                "VALUES (~zod, 'cord2', 16)"
    ==
  =.  run  +(run)
  =^  mov11  agent  
    %:  ~(on-poke agent (bowl [run ~2000.1.11]))
        %obelisk-action
        !>([%tape %db1 "FROM sys.data-log SELECT *"])
    ==
  %+  expect-eq
    !>  expected
    !>  ->+>+>.mov11
::
::  TIME
::
::  To DO:  create namespace  > content
::                            fail content =, <
::          create table      > schema , > content
::                            fail schema =, <, content =, <
::          drop table        > schema , > content
::                            fail schema =, <, content =, <
::          insert            > schema , > content
::                            fail schema =, <, content =, <

::
::  time, create ns as of 1 second > schema
++  test-time-create-ns-gt-schema
  =|  run=@ud
  =^  mov1  agent  
    %:  ~(on-poke agent (bowl [run ~2000.1.1]))
        %obelisk-action
        !>([%tape-create-db "CREATE DATABASE db1"])
    ==
  =.  run  +(run)
  =^  mov2  agent  
    %:  ~(on-poke agent (bowl [run ~2000.1.2]))
        %obelisk-action
        !>  :+  %tape
                %db1
                "CREATE TABLE db1..my-table-2 (col1 @t, col2 @p) ".
                "PRIMARY KEY (col1, col2)"
    ==
    =.  run  +(run)
      =^  mov2  agent  
    %:  ~(on-poke agent (bowl [run ~2000.1.3]))
        %obelisk-action
        !>([%tape %db1 "CREATE NAMESPACE ns1 as of ~2023.7.9..22.35.35..7e90"])
    ==
  =+  !<(=state on-save:agent)
  ;:  weld
%+  expect-eq
    !>  %results
    !>  ->+>+>-.mov2
  %+  expect-eq
    !>  [%result-da 'system time' ~2023.7.9..22.35.35..7e90]
    !>  ->+>+>+<.mov2
  %+  expect-eq
    !>  db-time-create-ns
    !>  databases.state
  ==

::  =|  run=@ud 
::  =/  my-cmd
::        "CREATE NAMESPACE ns1 as of ~2023.7.9..22.35.35..7e90"
::  =/  x  %-  process-cmds
::            :+  gen3-dbs
::                (bowl [run ~2030.2.1])
::                (parse:parse(default-database 'db1') my-cmd)
::  ;:  weld
::  %+  expect-eq                         
::    !>  :-  %results
::            :~  [%result-da msg='system time' date=~2023.7.9..22.35.35..7e90]
::            ==
::    !>  -.x
::  %+  expect-eq
::    !>  dbs-time-1
::    !>  +.x
::  ==
::
:: fail on time, create ns = schema
::++  test-fail-time-create-ns-eq-schema
::  =|  run=@ud
::  =/  my-cmd  "CREATE NAMESPACE ns1 as of ~2023.7.9..22.35.34..7e90"
::  %-  expect-fail
::  |.  %-  process-cmds 
::          :+  gen3-dbs
::              (bowl [run ~2031.1.1])
::              (parse:parse(default-database 'db1') my-cmd)
::
:: fail on time, create ns lt schema
::++  test-fail-time-create-ns-lt-schema
::  =|  run=@ud
::  =/  my-cmd  "CREATE NAMESPACE ns1 as of ~2023.7.9..22.35.33..7e90"
::  %-  expect-fail
::  |.  %-  process-cmds 
::          :+  gen3-dbs
::              (bowl [run ~2031.1.1])
::              (parse:parse(default-database 'db1') my-cmd)
::
::  time, create table as of 1 second > schema
::++  test-time-create-table-gt-schema
::  =|  run=@ud 
::  =/  my-cmd
::        "create table my-table-2 (col1 @t,col2 @p,col3 @ud) primary key (col1, col2) as of ~2023.7.9..22.35.35..7e90"
::  =/  x  %-  process-cmds
::            :+  gen3-dbs
::                (bowl [run ~2030.2.1])
::                (parse:parse(default-database 'db1') my-cmd)
::  ;:  weld
::  %+  expect-eq                         
::    !>  :-  %results
::            :~  [%result-da msg='system time' date=~2023.7.9..22.35.35..7e90]
::            ==
::    !>  -.x
::  %+  expect-eq
::    !>  dbs-time-2
::    !>  +.x
::  ==

--