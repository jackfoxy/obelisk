/-  ast, *obelisk
/+  *test
/=  agent  /app/obelisk
|%
::  Build an example bowl manually.
::
++  bowl
  |=  [run=@ud now=@da]
  ^-  bowl:gall
  :*  [~zod ~zod %obelisk `path`(limo `path`/test-agent)] :: (our src dap sap)
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
  :+  :-  %db1
          :*  %database
              name=%db1
              created-provenance=`path`/test-agent
              created-tmsp=~2000.1.1
              sys=~[sys1]
              user-data=~[user-data-1]
          ==
      ~
      ~
++  sys1
  :*  %schema
      provenance=`path`/test-agent
      tmsp=~2000.1.1
      namespaces=[[p=%dbo q=~2000.1.1] ~ [[p=%sys q=~2000.1.1] ~ ~]]
      tables=~
  ==
++  sys2
  :*  %schema
      provenance=`path`/test-agent
      tmsp=~2000.1.2
      :+  [p=%ns1 q=~2000.1.2]
          ~
          [[p=%dbo q=~2000.1.1] ~ [[p=%sys q=~2000.1.1] ~ ~]]
      tables=~
  ==
++  dropped-tbl-db-force
  :+  :-  %db1
          :*  %database
              name=%db1
              created-provenance=`path`/test-agent
              created-tmsp=~2000.1.1
              sys=~[sys4 one-col-tbl-sys sys1]
              user-data=~[user-data-4 user-data-1b user-data-2 user-data-1]
          ==
      ~
      ~
++  user-data-1
  [%data ~zod provenance=`path`/test-agent tmsp=~2000.1.1 ~]
++  user-data-1-a
  [%data ~zod provenance=`path`/test-agent tmsp=~2000.1.3 ~]
++  user-data-2  
  [%data ~zod `path`/test-agent ~2000.1.2 [[[%dbo %my-table] file-1col-1-2] ~ ~]]
++  user-data-3  
  :*  %data
      ~zod
      `path`/test-agent
      ~2000.1.3
      :+  [[%dbo %my-table-2] file-2col-1-3]
          ~
          [[[%dbo %my-table] file-1col-1-2] ~ ~]
  ==
++  user-data-3-a
  :*  %data
      ~zod
      `path`/test-agent
      ~2000.1.2
      :+  [[%dbo %my-table-2] file-2col-1-2]
          ~
          [[[%dbo %my-table] file-1col-1-2] ~ ~]
  ==
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
++  db2
  :+  :-  %db1
          :*  %database
              name=%db1
              created-provenance=`path`/test-agent
              created-tmsp=~2000.1.1
              sys=~[sys2 sys1]
              user-data=~[user-data-1]
          ==
      ~
      ~
::
::  Create table
++  one-col-tbl-db
  :+  :-  %db1
          :*  %database
              name=%db1
              created-provenance=`path`/test-agent
              created-tmsp=~2000.1.1
              sys=~[one-col-tbl-sys sys1]
              user-data=~[user-data-2 user-data-1]
          ==
      ~
      ~
++  one-col-tbl-sys
  :*  %schema
      provenance=`path`/test-agent
      tmsp=~2000.1.2
      namespaces=[[p=%dbo q=~2000.1.1] ~ [[p=%sys q=~2000.1.1] ~ ~]]
      tables=one-col-tbls
  ==
++  one-col-tbl-key
  [%dbo %my-table]
++  one-col-tbl
  :*  %table
      provenance=`path`/test-agent
      tmsp=~2000.1.2
      [%index unique=%.y clustered=%.y ~[[%ordered-column name=%col1 ascending=%.y]]]
      ~[[%column name=%col1 column-type=%t]]
      ~
  ==
++  one-col-tbls
  [[one-col-tbl-key one-col-tbl] ~ ~]
++  cmd-one-col
  :*  %create-table
      [%qualified-object ~ 'db1' 'dbo' 'my-table']
      ~[[%column 'col1' %t]]
      %.y
      ~[[%ordered-column 'col1' %.y]]
      ~
      ~
  ==
::
++  two-col-tbl-db
  :+  :-  %db1
          :*  %database
              name=%db1
              created-provenance=`path`/test-agent
              created-tmsp=~2000.1.1
              sys=~[two-col-tbl-sys one-col-tbl-sys sys1]
              user-data=~[user-data-3 user-data-2 user-data-1]
          ==
      ~
      ~
++  two-col-tbl-sys
  :*  %schema
      provenance=`path`/test-agent
      tmsp=~2000.1.3
      namespaces=[[%dbo ~2000.1.1] ~ [[%sys ~2000.1.1] ~ ~]]
      tables=two-col-tbls
  ==
++  two-col-tbl-key
  [%dbo %my-table-2]
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
++  two-col-tbls
  [[two-col-tbl-key two-col-tbl] ~ [[one-col-tbl-key one-col-tbl] ~ ~]]
++  cmd-two-col
  :*  %create-table
      [%qualified-object ~ 'db1' 'dbo' 'my-table-2']
      ~[[%column 'col1' %t] [%column 'col2' %p]]
      %.n
      ~[[%ordered-column 'col1' %.y] [%ordered-column 'col2' %.y]]
      ~
      ~
  ==
::
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
++  two-comb-col-tbls
  :+  [two-col-tbl-key two-comb-col-tbl]
      ~
      [[one-col-tbl-key one-col-tbl] ~ ~]
++  two-comb-col-tbl-db
  :+  :-  %db1
          :*  %database
              name=%db1
              created-provenance=`path`/test-agent
              created-tmsp=~2000.1.1
              sys=~[two-comb-col-tbl-sys sys1]
              user-data=~[user-data-3-a user-data-1]
          ==
       ~
       ~
++  two-comb-col-tbl-sys
  :*  %schema
      provenance=`path`/test-agent
      tmsp=~2000.1.2
      namespaces=[[%dbo ~2000.1.1] ~ [[%sys ~2000.1.1] ~ ~]]
      tables=two-comb-col-tbls
  ==
::
::  Drop table
++  dropped-tbl-db
  :+  :-  %db1
          :*  %database
              name=%db1
              created-provenance=`path`/test-agent
              created-tmsp=~2000.1.1
              sys=~[sys3 one-col-tbl-sys sys1]
              user-data=~[user-data-1-a user-data-2 user-data-1]
          ==
      ~
      ~
++  sys3
  :*  %schema
      provenance=`path`/test-agent
      tmsp=~2000.1.3
      namespaces=[[[p=%dbo q=~2000.1.1] ~ [[p=%sys q=~2000.1.1] ~ ~]]]
      tables=~
  ==
++  user-data-1b
  [%data ~zod provenance=`path`/test-agent tmsp=~2000.1.3 files=files-4]
++  user-data-4
  [%data ~zod provenance=`path`/test-agent tmsp=~2000.1.4 ~]
++  sys4
  :*  %schema
      provenance=`path`/test-agent
      tmsp=~2000.1.4
      namespaces=[[[p=%dbo q=~2000.1.1] ~ [[p=%sys q=~2000.1.1] ~ ~]]]
      tables=~
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
--