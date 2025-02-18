::  Demonstrate unit testing on a Gall agent with %obelisk.
::
/-  ast, *obelisk
/+  *test, *sys-views
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
      =server
      ==
--
|%
::
::  databases
++  mk-db
  |=  $:  name=@tas
          sys-time=@da
          schemas=(list [@da =schema])
          contents=(list [@da =data])
          view-caches=(list data-obj-key)
          sys-caches=(list @da)
          ==
  %-  ~(gas by `(map @tas database)`~)
    :~
      :-  name
        :*  %database
            name=name
            created-provenance=`path`/test-agent
            created-tmsp=sys-time
            sys=(gas:schema-key *((mop @da schema) gth) schemas)
            content=(gas:data-key *((mop @da data) gth) contents)
            %+  gas:view-cache-key
              %+  gas:view-cache-key
                    *((mop data-obj-key cache) ns-obj-comp)
                    %+  turn  (db-views name sys-time)
                        |=([p=data-obj-key q=view] [p (cache %cache time.p ~)])
              %+  turn  view-caches
                        |=(p=data-obj-key [p (cache %cache time.p ~)])
            ==
      (sys-database sys-time sys-caches)
      ==
::
++  sys-database
  |=  [sys-time=@da sys-caches=(list @da)]
  :-  %sys
        :*  %database
            %sys
            `path`/test-agent
            sys-time
            %+  gas:schema-key
                  *((mop @da schema) gth)
                  :~  :-  sys-time
                        :*  %schema
                            `path`/test-agent
                            sys-time
                            [[%sys sys-time] ~ ~]
                            ~
                            %+  gas:view-key  *((mop data-obj-key view) ns-obj-comp)
                                              (limo ~[(sys-sys-databases-view sys-time)])
                            ==
                      ==
            %+  gas:data-key  *((mop @da data) gth)
                          ~[[sys-time %data ~zod `path`/test-agent sys-time ~]]
            %+  gas:view-cache-key  *((mop data-obj-key cache) ns-obj-comp)
                  (turn sys-caches |=(a=@da [[%sys %databases a] [%cache a ~]]))
            ==
::
::  views
++  db-views
    |=  [db=@tas sys-time=@da]
    ^-  (list [[@tas @tas @da] view])
    %-  limo
    :~  :-  [%sys %namespaces sys-time]
            %-  apply-ordering
                (sys-namespaces-view db `path`(limo `path`/test-agent) sys-time)
        :-  [%sys %tables sys-time]
            %-  apply-ordering
                (sys-tables-view db `path`(limo `path`/test-agent) sys-time)
        :-  [%sys %columns sys-time]
            %-  apply-ordering
                (sys-columns-view db `path`(limo `path`/test-agent) sys-time)
        :-  [%sys %sys-log sys-time]
            %-  apply-ordering
                (sys-sys-log-view db `path`(limo `path`/test-agent) sys-time)
        :-  [%sys %data-log sys-time]
            %-  apply-ordering
                (sys-data-log-view db `path`(limo `path`/test-agent) sys-time)
        ==
++  sys-sys-databases-view
  |=  sys-time=@da
  =/  columns=(list column:ast)    :~  [%column %database ~.tas]
                                       [%column name=%sys-agent type=~.ta]
                                       [%column name=%sys-tmsp type=~.da]
                                       [%column name=%data-ship type=~.p]
                                       [%column name=%data-agent type=~.ta]
                                       [%column name=%data-tmsp type=~.da]
                                       ==
  :-  [%sys %databases sys-time]
      :*  %view
          [~.test-agent /]
          sys-time
          :+  %selection
              ~
              sys-sys-dbs-query
          (malt (spun columns make-col-lu-data))
          columns
          :~  [aor=%.y ascending=%.y offset=0]
              [aor=%.n ascending=%.y offset=2]
              [aor=%.n ascending=%.y offset=5]
              ==
          ==
++  ns-sys-views
    |*  [db=@tas sys-time=@da]
    ^-  views
    %+  gas:view-key  *((mop data-obj-key view) ns-obj-comp)
                      (limo (db-views db sys-time))
::
::  schemas
++  sys1
  |=  sys-time=@da
  ^-  [@da =schema]
  :-  sys-time
      :*  %schema
          provenance=`path`/test-agent
          tmsp=sys-time
          namespaces=[[p=%dbo q=sys-time] ~ [[p=%sys q=sys-time] ~ ~]]
          tables=~
          views=(ns-sys-views %db1 sys-time)
      ==
:: ~> %ns1 ~> %ns2
++  sys-ns1-ns2
  |=  [sys-time1=@da sys-time2=@da sys-time3=@da]
  :-  sys-time3
    :*  %schema
        provenance=`path`/test-agent
        tmsp=sys-time3
        :+  [%ns1 sys-time2]
            ~
            :+  [%dbo sys-time1]
                ~
                [[%ns2 sys-time3] ~ [[%sys sys-time1] ~ ~]]
        tables=~
        views=(ns-sys-views %db1 sys-time1)
    ==
:: ~> tbl
++  one-col-tbl-sys
  |=  [sys-time1=@da sys-time2=@da]  ^-  [@da schema]  :-  sys-time2
    :*  %schema
        provenance=`path`/test-agent
        tmsp=sys-time2
        namespaces=[[p=%dbo q=sys-time1] ~ [[p=%sys q=sys-time1] ~ ~]]
        tables=`(map [@tas @tas] table)`[one-col-tbl ~ ~]
        views=(ns-sys-views %db1 sys-time1)
    ==
:: ~> tbl ~> drop
++  one-col-tbl-drop-sys
  |=  [sys-time1=@da sys-time2=@da sys-time3=@da]  ^-  [@da schema]  :-  sys-time3
    :*  %schema
        provenance=`path`/test-agent
        tmsp=sys-time3
        namespaces=[[p=%dbo q=sys-time1] ~ [[p=%sys q=sys-time1] ~ ~]]
        tables=~
        views=(ns-sys-views %db1 sys-time1)
    ==
:: ~> tbl ~> insert ~> drop
++  sys4
  |=  [sys-time1=@da sys-time2=@da sys-time3=@da]
  ^-  [@da schema]  :-  sys-time3
    :*  %schema
        provenance=`path`/test-agent
        tmsp=sys-time3
        namespaces=[[p=%dbo q=sys-time1] ~ [[p=%sys q=sys-time1] ~ ~]]
        tables=~
        views=(ns-sys-views %db1 sys-time1)
    ==
::  ~> %ns1
++  sys-ns1-time2
  |=  [sys-time1=@da sys-time2=@da]  ^-  [@da schema]  :-  sys-time2
    :*  %schema
        provenance=`path`/test-agent
        tmsp=sys-time2
        :+  [%ns1 sys-time2]
            ~
            [[%dbo sys-time1] l=~ r=[[%sys sys-time1] ~ ~]]
        tables=~
        views=(ns-sys-views %db1 sys-time1)
    ==
::  ~> tbl
++  time-3-sys
  |=  [sys-time1=@da sys-time2=@da]  ^-  [@da schema]  :-  sys-time2
    :*  %schema
        provenance=`path`/test-agent
        tmsp=sys-time2
        namespaces=[[%dbo sys-time1] ~ [[%sys sys-time1] ~ ~]]
        tables=[time-3-tbl ~ ~]
        views=(ns-sys-views %db1 sys-time1)
    ==
::  ~> tbl ~> tbl
++  two-col-tbl-sys
  |=  [sys-time1=@da sys-time2=@da sys-time3=@da]
  ^-  [@da schema]  :-  sys-time3
    :*  %schema
        provenance=`path`/test-agent
        tmsp=sys-time3
        namespaces=[[%dbo sys-time1] ~ [[%sys sys-time1] ~ ~]]
        tables=[two-col-tbl ~ [one-col-tbl ~ ~]]
        views=(ns-sys-views %db1 sys-time1)
    ==
::  ~> tbl ~> tbl
++  two-comb-col-tbl-sys
  |=  [sys-time1=@da sys-time2=@da]  ^-  [@da schema]  :-  sys-time2
    :*  %schema
        provenance=`path`/test-agent
        tmsp=sys-time2
        namespaces=[[%dbo sys-time1] ~ [[%sys sys-time1] ~ ~]]
        tables=[[two-comb-col-tbl] ~ [one-col-tbl ~ ~]]
        views=(ns-sys-views %db1 sys-time1)
    ==
++  time-3a-sys
  |=  [sys-time1=@da sys-time2=@da]  ^-  [@da schema]  :-  sys-time2
    :*  %schema
        provenance=`path`/test-agent
        tmsp=sys-time2
        namespaces=[[p=%dbo q=sys-time1] ~ [[p=%sys q=sys-time1] ~ ~]]
        tables=[time-3-tbl ~ ~]
        views=(ns-sys-views %db1 sys-time1)
    ==
++  time-4-sys
  |=  [sys-time1=@da sys-time2=@da sys-time3=@da]
  ^-  [@da schema]  :-  sys-time3
    :*  %schema
        provenance=`path`/test-agent
        tmsp=sys-time3
        :+  [%ns1 sys-time3]
            ~
            [[%dbo sys-time1] l=~ r=[[%sys sys-time1] ~ ~]]
        tables=[time-3-tbl ~ ~]
        views=(ns-sys-views %db1 sys-time1)
    ==
++  time-5-sys
  |=  [sys-time1=@da sys-time2=@da sys-time3=@da sys-time4=@da]
  ^-  [@da schema]  :-  sys-time4
    :*  %schema
        provenance=`path`/test-agent
        tmsp=sys-time4
        :+  [%ns1 sys-time3]
            ~
            [[%dbo sys-time1] l=~ r=[[%sys sys-time1] ~ ~]]
        tables=~
        views=(ns-sys-views %db1 sys-time1)
    ==
++  time-2-sys1
  |=  [sys-time1=@da sys-time2=@da]  ^-  [@da schema]  :-  sys-time2
      :*  %schema
          provenance=`path`/test-agent
          tmsp=sys-time2
          namespaces=[[p=%dbo q=sys-time1] ~ [[p=%sys q=sys-time1] ~ ~]]
          tables=[time-one-col-tbl ~ ~]
          views=(ns-sys-views %db1 sys-time1)
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
++  content-my-table
  :-  ~2023.7.9..22.35.35..7e90
    :*  %data
        ~zod
        `path`/test-agent
        ~2023.7.9..22.35.35..7e90
        :+  file-my-table
            ~
            ~
    ==
++  content-insert
  ^-  [@da =data]
  :-  ~2023.7.9..22.35.36..7e90
    :*  %data
        ~zod
        `path`/test-agent
        ~2023.7.9..22.35.36..7e90
        file-insert
    ==
++  content-4
  [~2000.1.4 [%data ~zod provenance=`path`/test-agent tmsp=~2000.1.4 ~]]
++  content-1b
  [~2000.1.3 [%data ~zod provenance=`path`/test-agent tmsp=~2000.1.3 ;;((map [@tas @tas] file) file-4)]]
++  content-1c
  [~2000.1.4 [%data ~zod provenance=`path`/test-agent tmsp=~2000.1.4 file-5]]
++  content-time-5
      :-  ~2023.7.9..22.35.38..7e90
          :*  %data
              ~zod
              provenance=`path`/test-agent
              tmsp=~2023.7.9..22.35.38..7e90
              ~
          ==
::
::  files
++  file-1col-1-2
  :-  [%dbo %my-table]
      :*  %file
          ~zod
          `path`/test-agent
          ~2000.1.2
          0
          ~
          ~
      ==
++  file-2col-1-2
  :-  [%dbo %my-table-2]
      :*  %file
          ~zod
          `path`/test-agent
          ~2000.1.2
          0
          ~
          ~
      ==
++  file-time-2
  :-  [%dbo %my-table-2]
      :*  %file
          ~zod
          `path`/test-agent
          ~2000.1.2
          0
          ~
          ~
      ==
++  file-time-3
  :-  [%dbo %my-table-2]
      :*  %file
          ~zod
          `path`/test-agent
          ~2023.7.9..22.35.36..7e90
          0
          ~
          ~
      ==
++  file-2col-1-3
  :-  [%dbo %my-table-2]
      :*  %file
          ~zod
          `path`/test-agent
          ~2000.1.3
          0
          ~
          ~
      ==
++  file-4
  ^-  (map [@tas @tas] file)
  :+  :-  [%dbo %my-table]
          :*  %file
              ship=~zod
              provenance=`path`/test-agent
              tmsp=~2000.1.3
              rowcount=1
              pri-idx=file-4-pri-idx
              ^-  (list [(list @) (map @tas @)])
                  ~[[~[1.685.221.219] [n=[p=%col1 q=1.685.221.219] l=~ r=~]]]
              ==
      l=~
      r=~
++  file-5
  :+  :-  p=[%dbo %my-table]
          :*  %file
              ship=~zod
              provenance=`path`/test-agent
              tmsp=~2000.1.4
              rowcount=0
              pri-idx=~
              indexed-rows=~
          ==
      l=~
      r=~
++  file-my-table
  :-  p=[%dbo %my-table]
      :*  %file
          ship=~zod
          provenance=`path`/test-agent
          tmsp=~2023.7.9..22.35.35..7e90
          rowcount=0
          pri-idx=~
          indexed-rows=~
      ==
++  file-insert
  ^-  (map [@tas @tas] file)
  :+  :-  p=[%dbo %my-table]
          :*  %file
              ship=~zod
              provenance=`path`/test-agent
              tmsp=~2023.7.9..22.35.36..7e90
              rowcount=1
              pri-idx=file-4-pri-idx
              ^-  (list [(list @) (map @tas @)])
                  ~[[~[1.685.221.219] [n=[p=%col1 q=1.685.221.219] l=~ r=~]]]
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
          [[%col1 [%t 0]] ~ ~]
          ~[[%t %.y]]
          :+  %index
              unique=%.y
              ~[[%ordered-column name=%col1 ascending=%.y]]
          ~[[%column name=%col1 column-type=%t]]
          ~
      ==
++  time-one-col-tbl
  :-  [%dbo %my-table]
      :*  %table
          provenance=`path`/test-agent
          tmsp=~2023.7.9..22.35.35..7e90
          [[%col1 [%t 0]] ~ ~]
          ~[[%t %.y]]
          :+  %index
              unique=%.y
              ~[[%ordered-column name=%col1 ascending=%.y]]
          ~[[%column name=%col1 column-type=%t]]
          ~
      ==
++  two-col-tbl
  :-  [%dbo %my-table-2]
      :*  %table
          provenance=`path`/test-agent
          tmsp=~2000.1.3
          [[%col2 [%p 1]] ~ [[%col1 [%t 0]] ~ ~]]
          ~[[%t %.y] [%p %.y]]
          :+  %index
              %.y
              ~[[%ordered-column %col1 %.y] [%ordered-column %col2 %.y]]
          ~[[%column %col1 %t] [%column %col2 %p]]
          ~
      ==
++  two-comb-col-tbl
  :-  [%dbo %my-table-2]
      :*  %table
          provenance=`path`/test-agent
          tmsp=~2000.1.2
          [[%col2 [%p 1]] ~ [[%col1 [%t 0]] ~ ~]]
          ~[[%t %.y] [%p %.y]]
          :+  %index
              %.y
              ~[[%ordered-column %col1 %.y] [%ordered-column %col2 %.y]]
          ~[[%column %col1 %t] [%column %col2 %p]]
          ~
      ==
++  time-3-tbl
  :-  [%dbo %my-table-2]
      :*  %table
          provenance=`path`/test-agent
          tmsp=~2023.7.9..22.35.36..7e90
          [[%col2 [%p 1]] ~ [[%col1 [%t 0]] ~ ~]]
          ~[[%t %.y] [%p %.y]]
          :+  %index
              %.y
              ~[[%ordered-column %col1 %.y] [%ordered-column %col2 %.y]]
          ~[[%column %col1 %t] [%column %col2 %p]]
          ~
      ==
::
::  commands
++  cmd-two-col
  :*  %create-table
      [%qualified-object ~ 'db1' 'dbo' 'my-table-2' ~]
      ~[[%column 'col1' %t] [%column 'col2' %p]]
      ~[[%ordered-column 'col1' %.y] [%ordered-column 'col2' %.y]]
      ~
      ~
  ==
++  cmd-one-col
  :*  %create-table
      [%qualified-object ~ 'db1' 'dbo' 'my-table' ~]
      ~[[%column 'col1' %t]]
      ~[[%ordered-column 'col1' %.y]]
      ~
      ~
  ==
::
::  Create namespace
++  test-tape-create-ns
  =|  run=@ud
  =^  mov1  agent
    %:  ~(on-poke agent (bowl [run ~2000.1.1]))
        %obelisk-action
        !>([%tape %sys "CREATE DATABASE db1"])
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
    !>  :-  %results
            :~  [%message 'CREATE NAMESPACE %ns1']
                [%server-time ~2000.1.2]
                [%schema-time ~2000.1.2]
                ==
    !>  ;;(cmd-result ->+>+>+<.mov2)
  %+  expect-eq
    !>  %:  mk-db  %db1
                   ~2000.1.1
                   ~[(sys-ns1-time2 ~2000.1.1 ~2000.1.2) (sys1 ~2000.1.1)]
                   ~[content-1]
                   ~[[%sys %namespaces ~2000.1.2]]
                   ~[~2000.1.1]
                   ==
    !>  server.state
  ==
::
++  test-cmd-create-ns
  =|  run=@ud
  =^  mov1  agent
    %:  ~(on-poke agent (bowl [run ~2000.1.1]))
        %obelisk-action
        !>([%commands ~[[%create-database 'db1' ~]]])
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
    !>  :-  %results
            :~  [%message 'CREATE NAMESPACE %ns1']
                [%server-time ~2000.1.2]
                [%schema-time ~2000.1.2]
                ==
    !>  ;;(cmd-result ->+>+>-.mov2)
  %+  expect-eq
    !>  %:  mk-db  %db1
                   ~2000.1.1
                   ~[(sys-ns1-time2 ~2000.1.1 ~2000.1.2) (sys1 ~2000.1.1)]
                   ~[content-1]
                   ~[[%sys %namespaces ~2000.1.2]]
                   ~[~2000.1.1]
                   ==
    !>  server.state
  ==
::
::  CREATE TABLE
++  test-cmd-create-1-col-tbl
  =|  run=@ud
  =^  mov1  agent
    %:  ~(on-poke agent (bowl [run ~2000.1.1]))
        %obelisk-action
        !>([%commands ~[[%create-database 'db1' ~]]])
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
    !>  :-  %results
            :~  [%message 'CREATE TABLE %my-table']
                [%server-time ~2000.1.2]
                [%schema-time ~2000.1.2]
                ==
    !>  ;;(cmd-result ->+>+>-.mov2)
  %+  expect-eq
    !>  %:  mk-db  %db1
                   ~2000.1.1
                   ~[(one-col-tbl-sys ~2000.1.1 ~2000.1.2) (sys1 ~2000.1.1)]
                   ~[content-2 content-1]
                   :~  [%sys %columns ~2000.1.2]
                       [%sys %tables ~2000.1.2]
                       [%sys %sys-log ~2000.1.2]
                       [%sys %data-log ~2000.1.2]
                       ==
                   ~[~2000.1.1 ~2000.1.2]
                   ==
    !>  server.state
  ==
::
++  test-tape-create-1-col-tbl
  =|  run=@ud
  =^  mov1  agent
    %:  ~(on-poke agent (bowl [run ~2000.1.1]))
        %obelisk-action
        !>([%tape %sys "CREATE DATABASE db1"])
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
    !>  :-  %results
            :~  [%message 'CREATE TABLE %my-table']
                [%server-time ~2000.1.2]
                [%schema-time ~2000.1.2]
                ==
    !>  ;;(cmd-result ->+>+>+<.mov2)
  %+  expect-eq
    !>  %:  mk-db  %db1
                   ~2000.1.1
                   ~[(one-col-tbl-sys ~2000.1.1 ~2000.1.2) (sys1 ~2000.1.1)]
                   ~[content-2 content-1]
                   :~  [%sys %columns ~2000.1.2]
                       [%sys %tables ~2000.1.2]
                       [%sys %sys-log ~2000.1.2]
                       [%sys %data-log ~2000.1.2]
                       ==
                   ~[~2000.1.1 ~2000.1.2]
                   ==
    !>  server.state
  ==
::
++  test-cmd-create-2-col-tbl
  =|  run=@ud
  =^  mov1  agent
    %:  ~(on-poke agent (bowl [run ~2000.1.1]))
        %obelisk-action
        !>([%commands ~[[%create-database 'db1' ~]]])
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
    !>  :-  %results
            :~  [%message 'CREATE TABLE %my-table-2']
                [%server-time ~2000.1.3]
                [%schema-time ~2000.1.3]
                ==
    !>  ;;(cmd-result ->+>+>-.mov3)
  %+  expect-eq
    !>  %:  mk-db  %db1
                   ~2000.1.1
                   ~[(two-col-tbl-sys ~2000.1.1 ~2000.1.2 ~2000.1.3) (one-col-tbl-sys ~2000.1.1 ~2000.1.2) (sys1 ~2000.1.1)]
                   ~[content-3 content-2 content-1]
                   :~  [%sys %columns ~2000.1.2]
                       [%sys %tables ~2000.1.2]
                       [%sys %sys-log ~2000.1.2]
                       [%sys %columns ~2000.1.3]
                       [%sys %tables ~2000.1.3]
                       [%sys %sys-log ~2000.1.3]
                       [%sys %data-log ~2000.1.2]
                       [%sys %data-log ~2000.1.3]
                       ==
                   ~[~2000.1.1 ~2000.1.2 ~2000.1.3]
                   ==
    !>  server.state
  ==
::
++  test-tape-create-2-col-tbl
  =|  run=@ud
  =^  mov1  agent
    %:  ~(on-poke agent (bowl [run ~2000.1.1]))
        %obelisk-action
        !>([%tape %sys "CREATE DATABASE db1"])
    ==
  =.  run  +(run)
  =^  mov2  agent
    %:  ~(on-poke agent (bowl [run ~2000.1.2]))
        %obelisk-action
        !>  :+  %tape
                %db1
                "CREATE TABLE db1..my-table (col1 @t) ".
                "PRIMARY KEY (col1)"
    ==
  =^  mov3  agent
    %:  ~(on-poke agent (bowl [run ~2000.1.3]))
        %obelisk-action
        !>  :+  %tape
                %db1
                "CREATE TABLE db1..my-table-2 (col1 @t, col2 @p) ".
                "PRIMARY KEY (col1, col2)"
    ==
  =+  !<(=state on-save:agent)
  ;:  weld
  %+  expect-eq
    !>  :-  %results
            :~  [%message 'CREATE TABLE %my-table-2']
                [%server-time ~2000.1.3]
                [%schema-time ~2000.1.3]
                ==
    !>  ;;(cmd-result ->+>+>+<.mov3)
  %+  expect-eq
    !>  %:  mk-db  %db1
                   ~2000.1.1
                   ~[(two-col-tbl-sys ~2000.1.1 ~2000.1.2 ~2000.1.3) (one-col-tbl-sys ~2000.1.1 ~2000.1.2) (sys1 ~2000.1.1)]
                   ~[content-3 content-2 content-1]
                   :~  [%sys %columns ~2000.1.2]
                       [%sys %tables ~2000.1.2]
                       [%sys %sys-log ~2000.1.2]
                       [%sys %columns ~2000.1.3]
                       [%sys %tables ~2000.1.3]
                       [%sys %sys-log ~2000.1.3]
                       [%sys %data-log ~2000.1.2]
                       [%sys %data-log ~2000.1.3]
                       ==
                   ~[~2000.1.1 ~2000.1.2 ~2000.1.3]
                   ==
    !>  server.state
  ==
::
++  test-cmd-create-comb-2-col-tbl
  =|  run=@ud
  =^  mov1  agent
    %:  ~(on-poke agent (bowl [run ~2000.1.1]))
        %obelisk-action
        !>([%commands ~[[%create-database 'db1' ~]]])
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
  !>  :~    
        :-  %results
            :~  [%message 'CREATE TABLE %my-table-2']
                [%server-time ~2000.1.2]
                [%schema-time ~2000.1.2]
                ==
        :-  %results
            :~  [%message 'CREATE TABLE %my-table']
                [%server-time ~2000.1.2]
                [%schema-time ~2000.1.2]
                ==
        ==
    !>  ;;((list cmd-result) ->+>+>.mov2)
  %+  expect-eq
    !>  %:  mk-db  %db1
                   ~2000.1.1
                   ~[(two-comb-col-tbl-sys ~2000.1.1 ~2000.1.2) (sys1 ~2000.1.1)]
                   ~[content-3-a content-1]
                   :~  [%sys %columns ~2000.1.2]
                       [%sys %tables ~2000.1.2]
                       [%sys %sys-log ~2000.1.2]
                       [%sys %data-log ~2000.1.2]
                       ==
                   ~[~2000.1.1 ~2000.1.2]
                   ==
    !>  server.state
  ==
::
++  test-tape-create-comb-2-col-tbl
  =|  run=@ud
  =^  mov1  agent
    %:  ~(on-poke agent (bowl [run ~2000.1.1]))
        %obelisk-action
        !>([%tape %sys "CREATE DATABASE db1"])
    ==
  =.  run  +(run)
  =^  mov2  agent
    %:  ~(on-poke agent (bowl [run ~2000.1.2]))
        %obelisk-action
        !>  :+  %tape
                %db1
                "CREATE TABLE db1..my-table (col1 @t) PRIMARY KEY (col1); ".
                "CREATE TABLE db1..my-table-2 (col1 @t, col2 @p) ".
                "PRIMARY KEY (col1, col2)"
    ==
  =+  !<(=state on-save:agent)
  ;:  weld
  %+  expect-eq
    !>  :~    
        :-  %results
            :~  [%message 'CREATE TABLE %my-table']
                [%server-time ~2000.1.2]
                [%schema-time ~2000.1.2]
                ==
        :-  %results
            :~  [%message 'CREATE TABLE %my-table-2']
                [%server-time ~2000.1.2]
                [%schema-time ~2000.1.2]
                ==
        ==
    !>  ;;((list cmd-result) ->+>+>+.mov2)
  %+  expect-eq
    !>  %:  mk-db  %db1
                   ~2000.1.1
                   ~[(two-comb-col-tbl-sys ~2000.1.1 ~2000.1.2) (sys1 ~2000.1.1)]
                   ~[content-3-a content-1]
                   :~  [%sys %columns ~2000.1.2]
                       [%sys %tables ~2000.1.2]
                       [%sys %sys-log ~2000.1.2]
                       [%sys %data-log ~2000.1.2]
                       ==
                   ~[~2000.1.1 ~2000.1.2]
                   ==
    !>  server.state
  ==

:: to do: create table with foreign keys
::        fail on referenced table does not exist
::        fail on referenced table columns not a unique key
::        fail on fk columns not in table def columns
::        fail on fk column auras do not match referenced column auras
::
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
            alias=~
        ==
        %.n
        ~
  =^  mov1  agent
    %:  ~(on-poke agent (bowl [run ~2000.1.1]))
        %obelisk-action
        !>([%tape %sys "CREATE DATABASE db1"])
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
    !>  :-  %results
            :~  [%message 'DROP TABLE %my-table']
                [%server-time ~2000.1.3]
                [%schema-time ~2000.1.3]
                ==
    !>  ;;(cmd-result ->+>+>-.mov3)
  %+  expect-eq
    !>  %:  mk-db  %db1
                   ~2000.1.1
                   ~[(one-col-tbl-drop-sys ~2000.1.1 ~2000.1.2 ~2000.1.3) (one-col-tbl-sys ~2000.1.1 ~2000.1.2) (sys1 ~2000.1.1)]
                   ~[content-1-a content-2 content-1]
                   :~  [%sys %columns ~2000.1.2]
                       [%sys %tables ~2000.1.2]
                       [%sys %sys-log ~2000.1.2]
                       [%sys %columns ~2000.1.3]
                       [%sys %tables ~2000.1.3]
                       [%sys %sys-log ~2000.1.3]
                       [%sys %data-log ~2000.1.2]
                       [%sys %data-log ~2000.1.3]
                       ==
                   ~[~2000.1.1 ~2000.1.2 ~2000.1.3]
                   ==
    !>  server.state
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
            alias=~
        ==
        %.y
        ~
  =^  mov1  agent
    %:  ~(on-poke agent (bowl [run ~2000.1.1]))
        %obelisk-action
        !>([%tape %sys "CREATE DATABASE db1"])
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
    !>  :-  %results
            :~  [%message 'DROP TABLE %my-table']
                [%server-time ~2000.1.4]
                [%schema-time ~2000.1.4]
                [%data-time ~2000.1.4]
                [%vector-count 1]
                ==
    !>  ;;(cmd-result ->+>+>-.mov4)
  %+  expect-eq
    !>  %:  mk-db  %db1
                   ~2000.1.1
                   ~[(sys4 ~2000.1.1 ~2000.1.2 ~2000.1.4) (one-col-tbl-sys ~2000.1.1 ~2000.1.2) (sys1 ~2000.1.1)]
                   ~[;;([@da =data] content-4) ;;([@da =data] content-1b) ;;([@da =data] content-2) ;;([@da =data] content-1)]
                   :~  [%sys %tables ~2000.1.2]
                       [%sys %columns ~2000.1.2]
                       [%sys %data-log ~2000.1.2]
                       [%sys %sys-log ~2000.1.2]
                       [%sys %data-log ~2000.1.3]
                       [%sys %tables ~2000.1.3]
                       [%sys %tables ~2000.1.4]
                       [%sys %columns ~2000.1.4]
                       [%sys %sys-log ~2000.1.4]
                       [%sys %data-log ~2000.1.4]
                       ==
                   ~[~2000.1.1 ~2000.1.2 ~2000.1.3 ~2000.1.4]
                   ==
    !>  server.state
  ==
::
::
::  Truncate table
::
::  truncate table with no data
++  test-truncate-tbl-no-data
  =|  run=@ud
  =/  cmd
    :+  %truncate-table
        :*  %qualified-object
            ship=~
            database='db1'
            namespace='dbo'
            name='my-table'
            alias=~
        ==
        ~
  =^  mov1  agent
    %:  ~(on-poke agent (bowl [run ~2000.1.1]))
        %obelisk-action
        !>([%tape %sys "CREATE DATABASE db1"])
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
    !>  :-  %results
            :~  [%message 'TRUNCATE TABLE %dbo.%my-table']
                [%message 'no data in table to truncate']
                ==
    !>  ;;(cmd-result ->+>+>-.mov3)
  %+  expect-eq
    !>  %:  mk-db  %db1
                   ~2000.1.1
                   ~[(one-col-tbl-sys ~2000.1.1 ~2000.1.2) (sys1 ~2000.1.1)]
                   ~[content-2 content-1]
                   :~  [%sys %columns ~2000.1.2]
                       [%sys %tables ~2000.1.2]
                       [%sys %sys-log ~2000.1.2]
                       [%sys %data-log ~2000.1.2]
                       ==
                   ~[~2000.1.1 ~2000.1.2]
                   ==
    !>  server.state
  ==
::
::  truncate table with data
++  test-truncate-tbl
  =|  run=@ud
  =/  cmd
    :+  %truncate-table
        :*  %qualified-object
            ship=~
            database='db1'
            namespace='dbo'
            name='my-table'
            alias=~
        ==
        ~
  =^  mov1  agent
    %:  ~(on-poke agent (bowl [run ~2000.1.1]))
        %obelisk-action
        !>([%tape %sys "CREATE DATABASE db1"])
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
    !>  :-  %results
            :~  [%message 'TRUNCATE TABLE %dbo.%my-table']
                [%server-time ~2000.1.4]
                [%data-time ~2000.1.4]
                [%vector-count 1]
                ==
    !>  ;;(cmd-result ->+>+>-.mov4)
  %+  expect-eq
    !>  %:  mk-db  %db1
                  ~2000.1.1
                  ~[(one-col-tbl-sys ~2000.1.1 ~2000.1.2) (sys1 ~2000.1.1)]
                  ~[;;([@da =data] content-1c) ;;([@da =data] content-1b) ;;([@da =data] content-2) ;;([@da =data] content-1)]
                  :~  [%sys %columns ~2000.1.2]
                       [%sys %tables ~2000.1.2]
                       [%sys %tables ~2000.1.3]
                       [%sys %sys-log ~2000.1.2]
                       [%sys %data-log ~2000.1.2]
                       [%sys %data-log ~2000.1.3]
                       [%sys %tables ~2000.1.4]
                       [%sys %data-log ~2000.1.4]
                       ==
                  ~[~2000.1.1 ~2000.1.2 ~2000.1.3 ~2000.1.4]
                  ==
    !>  server.state
  ==
::
::  TIME
::
::  time, create database
++  test-time-create-database
  =|  run=@ud
  =^  mov1  agent
    %:  ~(on-poke agent (bowl [run ~2000.1.1]))
        %obelisk-action
        !>([%tape %sys "CREATE DATABASE db1 as of ~2023.7.9..22.35.35..7e90"])
    ==
  =+  !<(=state on-save:agent)
  ;:  weld
  %+  expect-eq
    !>  :-  %results
            :~  [%message 'created database %db1']
                [%server-time ~2000.1.1]
                [%schema-time ~2023.7.9..22.35.35..7e90]
                ==
    !>  ->+>+>+<.mov1
  %+  expect-eq
    !>  %:  mk-db  %db1
                   ~2023.7.9..22.35.35..7e90
                   ~[(sys1 ~2023.7.9..22.35.35..7e90)]
                   ~[content-time-1]
                   ~
                   ~[~2023.7.9..22.35.35..7e90]
                   ==
    !>  server.state
  ==
::
::  time, create ns as of 1 second > schema
++  test-time-create-ns-gt-schema
  =|  run=@ud
  =^  mov1  agent
    %:  ~(on-poke agent (bowl [run ~2000.1.1]))
        %obelisk-action
        !>([%tape %sys "CREATE DATABASE db1"])
    ==
  =.  run  +(run)
  =^  mov2  agent
    %:  ~(on-poke agent (bowl [run ~2000.1.3]))
        %obelisk-action
        !>([%tape %db1 "CREATE NAMESPACE ns1 as of ~2023.7.9..22.35.35..7e90"])
    ==
  =.  run  +(run)
  =^  mov3  agent
    %:  ~(on-poke agent (bowl [run ~2000.1.3]))
        %obelisk-action
        !>([%tape %db1 "CREATE NAMESPACE ns2 as of ~2023.7.9..22.35.36..7e90"])
    ==
  =+  !<(=state on-save:agent)
  ;:  weld
  %+  expect-eq
    !>  :-  %results
            :~  [%message 'CREATE NAMESPACE %ns2']
                [%server-time ~2000.1.3]
                [%schema-time ~2023.7.9..22.35.36..7e90]
                ==
    !>  ;;(cmd-result ->+>+>+<.mov3)
  %+  expect-eq
    !>  %:  mk-db  %db1
                   ~2000.1.1
                   :~  (sys-ns1-ns2 ~2000.1.1 ~2023.7.9..22.35.35..7e90 ~2023.7.9..22.35.36..7e90)
                       (sys-ns1-time2 ~2000.1.1 ~2023.7.9..22.35.35..7e90)
                       (sys1 ~2000.1.1)
                       ==
                   ~[content-1]
                   :~  [%sys %namespaces ~2023.7.9..22.35.35..7e90]
                       [%sys %namespaces ~2023.7.9..22.35.36..7e90]
                       ==
                   ~[~2000.1.1]
                   ==
    !>  server.state
  ==
::
::  time, create table as of 1 second > content
++  test-time-create-table-gt-schema
  =|  run=@ud
  =^  mov1  agent
    %:  ~(on-poke agent (bowl [run ~2000.1.1]))
        %obelisk-action
        !>([%tape %sys "CREATE DATABASE db1 as of ~2023.7.9..22.35.35..7e90"])
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
    !>  :-  %results
            :~  [%message 'CREATE TABLE %my-table-2']
                [%server-time ~2000.1.2]
                [%schema-time ~2023.7.9..22.35.36..7e90]
                ==
    !>  ;;(cmd-result ->+>+>+<.mov2)
  %+  expect-eq
    !>  %:  mk-db  %db1
                   ~2023.7.9..22.35.35..7e90
                   :~  (time-3-sys ~2023.7.9..22.35.35..7e90 ~2023.7.9..22.35.36..7e90)
                       (sys1 ~2023.7.9..22.35.35..7e90)
                       ==
                   ~[content-time-3 content-time-1]
                   :~  [%sys %sys-log ~2023.7.9..22.35.36..7e90]
                       [%sys %columns ~2023.7.9..22.35.36..7e90]
                       [%sys %tables ~2023.7.9..22.35.36..7e90]
                       [%sys %data-log ~2023.7.9..22.35.36..7e90]
                       ==
                   ~[~2023.7.9..22.35.35..7e90 ~2023.7.9..22.35.36..7e90]
                   ==
    !>  server.state
  ==
::
::  time, drop table as of 1 second > content
++  test-time-drop-table-gt-schema
  =|  run=@ud
  =^  mov1  agent
    %:  ~(on-poke agent (bowl [run ~2000.1.1]))
        %obelisk-action
        !>([%tape %sys "CREATE DATABASE db1"])
    ==
  =.  run  +(run)
  =^  mov2  agent
    %:  ~(on-poke agent (bowl [run ~2000.1.2]))
        %obelisk-action
        !>  :+  %tape
                %db1
                "CREATE TABLE db1..my-table-2 (col1 @t, col2 @p) ".
                "PRIMARY KEY (col1, col2) ".
                "AS OF ~2023.7.9..22.35.36..7e90"
    ==
  =.  run  +(run)
  =^  mov2  agent
    %:  ~(on-poke agent (bowl [run ~2000.1.3]))
        %obelisk-action
        !>([%tape %db1 "CREATE NAMESPACE ns1 as of ~2023.7.9..22.35.37..7e90"])
    ==
  =.  run  +(run)
  =^  mov3  agent
    %:  ~(on-poke agent (bowl [run ~2000.1.2]))
        %obelisk-action
        !>  :+  %tape
                %db1
                "DROP TABLE db1..my-table-2 ".
                "AS OF ~2023.7.9..22.35.38..7e90"
    ==
  =+  !<(=state on-save:agent)
  ;:  weld
  %+  expect-eq
    !>  :-  %results
            :~  [%message 'DROP TABLE %my-table-2']
                [%server-time ~2000.1.2]
                [%schema-time ~2023.7.9..22.35.38..7e90]
                ==
    !>  ;;(cmd-result ->+>+>+<.mov3)
  %+  expect-eq
    !>  %:  mk-db  %db1
                   ~2000.1.1
                   :~  (time-5-sys ~2000.1.1 ~2023.7.9..22.35.36..7e90 ~2023.7.9..22.35.37..7e90 ~2023.7.9..22.35.38..7e90)
                       (time-4-sys ~2000.1.1 ~2023.7.9..22.35.36..7e90 ~2023.7.9..22.35.37..7e90)
                       (time-3a-sys ~2000.1.1 ~2023.7.9..22.35.36..7e90)
                       (sys1 ~2000.1.1)
                       ==
                   ~[content-time-5 content-time-3 content-1]
                   :~  [%sys %sys-log ~2023.7.9..22.35.36..7e90]
                       [%sys %columns ~2023.7.9..22.35.36..7e90]
                       [%sys %tables ~2023.7.9..22.35.36..7e90]
                       [%sys %data-log ~2023.7.9..22.35.36..7e90]
                       [%sys %data-log ~2023.7.9..22.35.38..7e90]
                       [%sys %namespaces ~2023.7.9..22.35.37..7e90]
                       [%sys %sys-log ~2023.7.9..22.35.38..7e90]
                       [%sys %columns ~2023.7.9..22.35.38..7e90]
                       [%sys %tables ~2023.7.9..22.35.38..7e90]
                       ==
                   ~[~2000.1.1 ~2023.7.9..22.35.36..7e90 ~2023.7.9..22.35.38..7e90]
                   ==
    !>  server.state
  ==
::
::
::::  time, insert as of 1 second > schema
++  test-time-insert-gt-schema
  =|  run=@ud
  =^  mov1  agent
    %:  ~(on-poke agent (bowl [run ~2000.1.1]))
        %obelisk-action
        !>([%tape %sys "CREATE DATABASE db1"])
    ==
  =.  run  +(run)
  =^  mov2  agent
    %:  ~(on-poke agent (bowl [run ~2000.1.2]))
        %obelisk-action
        !>  :+  %tape
                %db1
                "CREATE TABLE db1..my-table (col1 @t) PRIMARY KEY (col1) ".
                "AS OF ~2023.7.9..22.35.35..7e90"
    ==
  =.  run  +(run)
  =^  mov3  agent
    %:  ~(on-poke agent (bowl [run ~2023.7.9..22.35.35..7e90]))
        %obelisk-action
        !>  :+  %tape
                %db1
                "INSERT INTO db1..my-table (col1) VALUES ('cord') ".
                "AS OF ~2023.7.9..22.35.36..7e90"
    ==
  =+  !<(=state on-save:agent)
  ;:  weld
  %+  expect-eq
    !>  :-  %results
          :~  [%message 'INSERT INTO %dbo.%my-table']
              [%server-time ~2023.7.9..22.35.35..7e90]
              [%schema-time ~2023.7.9..22.35.35..7e90]
              [%data-time ~2023.7.9..22.35.36..7e90]
              [%message 'inserted:']
              [%vector-count 1]
              [%message 'table data:']
              [%vector-count 1]
              ==
    !>  ;;(cmd-result ->+>+>+<.mov3)
  %+  expect-eq
    !>  %:  mk-db  %db1
                   ~2000.1.1
                   :~  (time-2-sys1 ~2000.1.1 ~2023.7.9..22.35.35..7e90)
                       (sys1 ~2000.1.1)
                       ==
                   ~[;;([@da =data] content-insert) ;;([@da =data] content-my-table) ;;([@da =data] content-1)]
                   :~  [%sys %sys-log ~2023.7.9..22.35.35..7e90]
                       [%sys %columns ~2023.7.9..22.35.35..7e90]
                       [%sys %tables ~2023.7.9..22.35.35..7e90]
                       [%sys %tables ~2023.7.9..22.35.36..7e90]
                       [%sys %data-log ~2023.7.9..22.35.35..7e90]
                       [%sys %data-log ~2023.7.9..22.35.36..7e90]
                       ==
                   ~[~2000.1.1 ~2023.7.9..22.35.35..7e90 ~2023.7.9..22.35.36..7e90]
                   ==
    !>  server.state
  ==

--
