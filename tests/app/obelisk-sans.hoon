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
++  db-time-create-db
  :+  :-  %db1
          :*  %database
              name=%db1
              created-provenance=`path`/test-agent
              created-tmsp=~2023.7.9..22.35.35..7e90
              %+  gas:schema-key  *((mop @da schema) gth)
                                  ~[time-1-sys1]
              %+  gas:data-key  *((mop @da data) gth)
                                ~[content-time-1]
          ==
      ~
      ~
++  db-time-create-ns
  :+  :-  %db1
          :*  %database
              name=%db1
              created-provenance=`path`/test-agent
              created-tmsp=~2000.1.1
              %+  gas:schema-key  *((mop @da schema) gth)
                                  ~[sys-time-create-ns time-2-sys sys1]
              %+  gas:data-key  *((mop @da data) gth)
                                ~[content-time-2 content-1]
          ==
      ~
      ~
++  db-time-create-tbl
  :+  :-  %db1
          :*  %database
              name=%db1
              created-provenance=`path`/test-agent
              created-tmsp=~2023.7.9..22.35.35..7e90
              %+  gas:schema-key  *((mop @da schema) gth)
                                  ~[time-3-sys time-1-sys1]
              %+  gas:data-key  *((mop @da data) gth)
                                ~[content-time-3 content-time-1]
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
++  time-1-sys1
  :-  ~2023.7.9..22.35.35..7e90
      :*  %schema
          provenance=`path`/test-agent
          tmsp=~2023.7.9..22.35.35..7e90
          namespaces=[[p=%dbo q=~2023.7.9..22.35.35..7e90] ~ [[p=%sys q=~2023.7.9..22.35.35..7e90] ~ ~]]
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
        tables=[one-col-tbl ~ ~]
    ==
++  two-col-tbl-sys
  :-  ~2000.1.3
    :*  %schema
        provenance=`path`/test-agent
        tmsp=~2000.1.3
        namespaces=[[%dbo ~2000.1.1] ~ [[%sys ~2000.1.1] ~ ~]]
        tables=[two-col-tbl ~ [one-col-tbl ~ ~]]
    ==
++  two-comb-col-tbl-sys
  :-  ~2000.1.2
    :*  %schema
        provenance=`path`/test-agent
        tmsp=~2000.1.2
        namespaces=[[%dbo ~2000.1.1] ~ [[%sys ~2000.1.1] ~ ~]]
        tables=[[two-comb-col-tbl] ~ [one-col-tbl ~ ~]]
    ==
++  time-2-sys
  :-  ~2000.1.2
    :*  %schema
        provenance=`path`/test-agent
        tmsp=~2000.1.2
        namespaces=[[%dbo ~2000.1.1] ~ [[%sys ~2000.1.1] ~ ~]]
        tables=[time-2-tbl ~ ~]
    ==
++  time-3-sys
  :-  ~2023.7.9..22.35.36..7e90
    :*  %schema
        provenance=`path`/test-agent
        tmsp=~2023.7.9..22.35.36..7e90
        namespaces=[[%dbo ~2023.7.9..22.35.35..7e90] ~ [[%sys ~2023.7.9..22.35.35..7e90] ~ ~]]
        tables=[time-3-tbl ~ ~]
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
        tables=[time-2-tbl ~ ~]
    ==
::
::  content
++  data-key  ((on @da data) gth)
++  content-1
  [~2000.1.1 [%data ~zod provenance=`path`/test-agent tmsp=~2000.1.1 ~]]
++  content-time-1
  :-  ~2023.7.9..22.35.35..7e90
      [%data ~zod provenance=`path`/test-agent tmsp=~2023.7.9..22.35.35..7e90 ~]
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
        [file-1col-1-2 ~ ~]
    ==
++  content-time-2
  :-  ~2000.1.2
    :*  %data
        ~zod
        `path`/test-agent
        ~2000.1.2
        [file-time-2 ~ ~]
    ==
++  content-time-3
  :-  ~2023.7.9..22.35.36..7e90
    :*  %data
        ~zod
        `path`/test-agent
        ~2023.7.9..22.35.36..7e90
        [file-time-3 ~ ~]
    ==
++  content-3
  :-  ~2000.1.3
    :*  %data
        ~zod
        `path`/test-agent
        ~2000.1.3
        :+  file-2col-1-3
            ~
            [file-1col-1-2 ~ ~]
    ==
++  content-3-a
  :-  ~2000.1.2
    :*  %data
        ~zod
        `path`/test-agent
        ~2000.1.2
        :+  file-2col-1-2
            ~
            [file-1col-1-2 ~ ~]
    ==
++  content-4
  [~2000.1.4 [%data ~zod provenance=`path`/test-agent tmsp=~2000.1.4 ~]]
++  content-1b
  [~2000.1.3 [%data ~zod provenance=`path`/test-agent tmsp=~2000.1.3 file-4]]
::
::  files
++  file-1col-1-2
  :-  [%dbo %my-table]
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
  :-  [%dbo %my-table-2]
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
  :-  [%dbo %my-table-2]
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
++  file-time-3
  :-  [%dbo %my-table-2]
      :*  %file
          ~zod
          `path`/test-agent
          ~2023.7.9..22.35.36..7e90
          %.y
          0
          [[%col2 [%p 1]] ~ [[%col1 [%t 0]] ~ ~]]
          ~[[%t %.y] [%p %.y]]
          ~
          ~
      ==
++  file-2col-1-3
  :-  [%dbo %my-table-2]
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
++  file-4
  :+  :-  p=[%dbo %my-table]
          :*  %file
              ship=~zod
              provenance=`path`/test-agent
              tmsp=~2000.1.3
              clustered=%.y
              length=1
              column-lookup=[n=[p=%col1 q=[%t 0]] l=~ r=~]
              key=~[[%t %.y]]
              pri-idx=file-4-pri-idx
              data=~[[n=[p=%col1 q=1.685.221.219] l=~ r=~]]
          ==
      l=~
      r=~
++  file-4-pri-idx
  [n=[[~[1.685.221.219] [n=[p=%col1 q=1.685.221.219] l=~ r=~]]] l=~ r=~]
::
::  tables
++  one-col-tbl
  :-  [%dbo %my-table]
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
  :-  [%dbo %my-table-2]
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
  :-  [%dbo %my-table-2]
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
  :-  [%dbo %my-table-2]
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
++  time-3-tbl
  :-  [%dbo %my-table-2]
    :*  %table
        provenance=`path`/test-agent
        tmsp=~2023.7.9..22.35.36..7e90
        :*  %index
            %.y
            %.y
            ~[[%ordered-column %col1 %.y] [%ordered-column %col2 %.y]]
        ==
        ~[[%column %col1 %t] [%column %col2 %p]]
        ~
    ==
::
::  commands
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

::
::  time, create database
++  test-time-create-database
  =|  run=@ud
  =^  mov1  agent  
    %:  ~(on-poke agent (bowl [run ~2000.1.1]))
        %obelisk-action
        !>([%tape-create-db "CREATE DATABASE db1 as of ~2023.7.9..22.35.35..7e90"])
    ==
  =+  !<(=state on-save:agent)
  ;:  weld
  %+  expect-eq
    !>  %obelisk-result
    !>  ->+>-.mov1
  %+  expect-eq
    !>  [%result-da 'system time' ~2023.7.9..22.35.35..7e90]
    !>  ->+>+>.mov1
  %+  expect-eq
    !>  db-time-create-db
    !>  databases.state
  ==

::
::  time, create table as of 1 second > content
++  test-time-create-table-gt-content
  =|  run=@ud
  =^  mov1  agent  
    %:  ~(on-poke agent (bowl [run ~2000.1.1]))
        %obelisk-action
        !>([%tape-create-db "CREATE DATABASE db1 as of ~2023.7.9..22.35.35..7e90"])
    ==
  =.  run  +(run)

  =^  mov2  agent  
    %:  ~(on-poke agent (bowl [run ~2000.1.2]))
        %obelisk-action
        !>  :+  %tape
                %db1
                "CREATE TABLE db1..my-table-2 (col1 @t, col2 @p) ".
                "PRIMARY KEY (col1, col2) ".
                "as of ~2023.7.9..22.35.36..7e90"
    ==
  =+  !<(=state on-save:agent)
  ;:  weld
  %+  expect-eq
    !>  %results
    !>  ->+>+>-.mov2
  %+  expect-eq
    !>  [%result-da 'system time' ~2023.7.9..22.35.36..7e90]
    !>  ->+>+>+<.mov2
  %+  expect-eq
    !>  db-time-create-tbl
    !>  databases.state
  ==

--