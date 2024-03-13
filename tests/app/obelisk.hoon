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
      =databases
      ==
--
|%
::
::  databases
++  mk-db
  |=  [name=@tas sys-time=@da schemas=(list [@da =schema]) contents=(list [@da =data])]
  %-  ~(gas by `(map @tas database)`~)
  :~  :-  name
          :*  %database
              name=name
              created-provenance=`path`/test-agent
              created-tmsp=sys-time
              sys=(gas:schema-key *((mop @da schema) gth) schemas)
              content=(gas:data-key *((mop @da data) gth) contents)
          ==
      (sys-database sys-time)
      ==
::
++  sys-database
  |=  sys-time=@da
  :-  %sys
          :*  %database
              %sys
              `path`/test-agent
              sys-time
              %+  gas:schema-key  *((mop @da schema) gth)
                                  :~  :-  sys-time
                                        :*  %schema
                                            `path`/test-agent
                                            sys-time
                                            [[%sys sys-time] ~ ~]
                                            ~
                                            %+  gas:ns-objs-key  *((mop data-obj-key view) ns-obj-comp)
                                                                 (limo ~[(sys-sys-databases-view sys-time)])
                                            ==
                                      ==
              %+  gas:data-key  *((mop @da data) gth)
                            ~[[sys-time %data ~zod `path`/test-agent sys-time ~]]
              ==
::
::  views
++  db-views
    |=  [db=@tas sys-time=@da]
    ^-  (list [[@tas @tas @da] view])
    %-  limo
    :~  :-  [%sys %sys-namespaces sys-time]
            %-  apply-ordering 
                (sys-namespaces-view db `path`(limo `path`/test-agent) sys-time)
        :-  [%sys %sys-tables sys-time]
            %-  apply-ordering
                (sys-tables-view db `path`(limo `path`/test-agent) sys-time)
        :-  [%sys %sys-columns sys-time]
            %-  apply-ordering
                (sys-columns-view db `path`(limo `path`/test-agent) sys-time)
        :-  [%sys %sys-sys-log sys-time]
            %-  apply-ordering
                (sys-sys-log-view db `path`(limo `path`/test-agent) sys-time)
        :-  [%sys %sys-data-log sys-time]
            %-  apply-ordering
                (sys-data-log-view db `path`(limo `path`/test-agent) sys-time)
        ==
++  sys-sys-databases-view
  |=  sys-time=@da
  :-  [%sys %sys-databases sys-time]
      :*  %view
          [~.test-agent /]
          sys-time
          %.y
          %.n
          :+  %transform
              ~
              sys-sys-dbs-query
          :~  [%column %database ~.tas]
              [%column name=%sys-agent type=~.tas]
              [%column name=%sys-tmsp type=~.da]
              [%column name=%data-ship type=~.p]
              [%column name=%data-agent type=~.tas]
              [%column name=%data-tmsp type=~.da]
              ==
          :~  [aor=%.y ascending=%.y offset=0]
              [aor=%.n ascending=%.y offset=2]
              [aor=%.n ascending=%.y offset=5]
              ==
          ~
          ==
++  ns-sys-views
    |*  [db=@tas sys-time=@da]
    ^-  views
    %+  gas:ns-objs-key  *((mop data-obj-key view) ns-obj-comp)
                         (limo (db-views db sys-time))
++  ns-sys-2views
    |*  [db=@tas sys-time1=@da sys-time2=@da]
    ^-  views
    %+  gas:ns-objs-key  *((mop data-obj-key view) ns-obj-comp)
                         (weld (db-views db sys-time1) (db-views db sys-time2))
++  ns-sys-3views
    |*  [db=@tas sys-time1=@da sys-time2=@da sys-time3=@da]
    ^-  views
    %+  gas:ns-objs-key  *((mop data-obj-key view) ns-obj-comp)
                         (weld (weld (db-views db sys-time1) (db-views db sys-time2)) (db-views db sys-time3))
++  ns-2-ns-sys-views
    |*  [db=@tas sys-time1=@da sys-time2=@da]
    ^-  views
    =/  ns-views=(list [[@tas @tas @da] view])  %-  limo  :~  
         :-  [%sys %sys-namespaces sys-time2]
            %-  apply-ordering 
                (sys-namespaces-view db `path`(limo `path`/test-agent) sys-time2)
        :-  [%sys %sys-sys-log sys-time2]
            %-  apply-ordering
                (sys-sys-log-view db `path`(limo `path`/test-agent) sys-time2)
        ==
    %+  gas:ns-objs-key  *((mop data-obj-key view) ns-obj-comp)
                         (weld (db-views db sys-time1) ns-views)
++  ns-sys-views3
    |*  [db=@tas sys-time1=@da sys-time2=@da sys-time3=@da]
    ^-  views
    =/  ns-views=(list [[@tas @tas @da] view])  %-  limo  :~  
        :-  [%sys %sys-namespaces sys-time1]
            %-  apply-ordering 
                (sys-namespaces-view db `path`(limo `path`/test-agent) sys-time1)
        :-  [%sys %sys-sys-log sys-time1]
            %-  apply-ordering
                (sys-sys-log-view db `path`(limo `path`/test-agent) sys-time1)
        :-  [%sys %sys-namespaces sys-time3]
            %-  apply-ordering 
                (sys-namespaces-view db `path`(limo `path`/test-agent) sys-time3)
        :-  [%sys %sys-sys-log sys-time3]
            %-  apply-ordering
                (sys-sys-log-view db `path`(limo `path`/test-agent) sys-time3)

        :-  [%sys %sys-namespaces sys-time2]
            %-  apply-ordering 
                (sys-namespaces-view db `path`(limo `path`/test-agent) sys-time2)
        :-  [%sys %sys-sys-log sys-time2]
            %-  apply-ordering
                (sys-sys-log-view db `path`(limo `path`/test-agent) sys-time2)
        :-  [%sys %sys-namespaces sys-time3]
            %-  apply-ordering 
                (sys-namespaces-view db `path`(limo `path`/test-agent) sys-time3)
        :-  [%sys %sys-sys-log sys-time3]
            %-  apply-ordering
                (sys-sys-log-view db `path`(limo `path`/test-agent) sys-time3)
        ==
    %+  gas:ns-objs-key  *((mop data-obj-key view) ns-obj-comp)
                         (weld (db-views db sys-time1) ns-views)
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
        views=(ns-sys-views %db1 sys-time3)
    ==
:: ~> tbl
++  one-col-tbl-sys
  |=  [sys-time1=@da sys-time2=@da]  ^-  [@da schema]  :-  sys-time2
    :*  %schema
        provenance=`path`/test-agent
        tmsp=sys-time2
        namespaces=[[p=%dbo q=sys-time1] ~ [[p=%sys q=sys-time1] ~ ~]]
        tables=`(map [@tas @tas] table)`[one-col-tbl ~ ~]
        views=(ns-sys-views %db1 sys-time2)
    ==
:: ~> tbl ~> drop
++  one-col-tbl-drop-sys
  |=  [sys-time1=@da sys-time2=@da sys-time3=@da]  ^-  [@da schema]  :-  sys-time3
    :*  %schema
        provenance=`path`/test-agent
        tmsp=sys-time3
        namespaces=[[p=%dbo q=sys-time1] ~ [[p=%sys q=sys-time1] ~ ~]]
        tables=~
        views=(ns-sys-views %db1 sys-time3)
    ==
:: ~> tbl ~> insert ~> drop
++  sys4
  |=  [sys-time1=@da sys-time2=@da sys-time3=@da]  ^-  [@da schema]  :-  sys-time3
    :*  %schema
        provenance=`path`/test-agent
        tmsp=sys-time3
        namespaces=[[p=%dbo q=sys-time1] ~ [[p=%sys q=sys-time1] ~ ~]]
        tables=~
        views=(ns-sys-views %db1 sys-time3)
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
        views=(ns-sys-views %db1 sys-time2)
    ==
::  ~> tbl
++  time-3-sys
  |=  [sys-time1=@da sys-time2=@da]  ^-  [@da schema]  :-  sys-time2
    :*  %schema
        provenance=`path`/test-agent
        tmsp=sys-time2
        namespaces=[[%dbo sys-time1] ~ [[%sys sys-time1] ~ ~]]
        tables=[time-3-tbl ~ ~]
        views=(ns-sys-views %db1 sys-time2)
    ==
::  ~> tbl ~> tbl
++  two-col-tbl-sys
  |=  [sys-time1=@da sys-time2=@da sys-time3=@da]  ^-  [@da schema]  :-  sys-time3
    :*  %schema
        provenance=`path`/test-agent
        tmsp=sys-time3
        namespaces=[[%dbo sys-time1] ~ [[%sys sys-time1] ~ ~]]
        tables=[two-col-tbl ~ [one-col-tbl ~ ~]]
        views=(ns-sys-views %db1 sys-time3)
    ==
::  ~> tbl ~> tbl
++  two-comb-col-tbl-sys
  |=  [sys-time1=@da sys-time2=@da]  ^-  [@da schema]  :-  sys-time2
    :*  %schema
        provenance=`path`/test-agent
        tmsp=sys-time2
        namespaces=[[%dbo sys-time1] ~ [[%sys sys-time1] ~ ~]]
        tables=[[two-comb-col-tbl] ~ [one-col-tbl ~ ~]]
        views=(ns-sys-views %db1 sys-time2)
    ==
++  time-3a-sys
  |=  [sys-time1=@da sys-time2=@da]  ^-  [@da schema]  :-  sys-time2
    :*  %schema
        provenance=`path`/test-agent
        tmsp=sys-time2
        namespaces=[[p=%dbo q=sys-time1] ~ [[p=%sys q=sys-time1] ~ ~]]
        tables=[time-3-tbl ~ ~]
        views=(ns-sys-views %db1 sys-time2)
    ==
++  time-4-sys
  |=  [sys-time1=@da sys-time2=@da sys-time3=@da]  ^-  [@da schema]  :-  sys-time3
    :*  %schema
        provenance=`path`/test-agent
        tmsp=sys-time3
        :+  [%ns1 sys-time3]
            ~
            [[%dbo sys-time1] l=~ r=[[%sys sys-time1] ~ ~]]
        tables=[time-3-tbl ~ ~]
        views=(ns-sys-views %db1 sys-time3)
    ==
++  time-5-sys
  |=  [sys-time1=@da sys-time2=@da sys-time3=@da sys-time4=@da]  ^-  [@da schema]  :-  sys-time4
    :*  %schema
        provenance=`path`/test-agent
        tmsp=sys-time4
        :+  [%ns1 sys-time3]
            ~
            [[%dbo sys-time1] l=~ r=[[%sys sys-time1] ~ ~]]
        tables=~
        views=(ns-sys-views %db1 sys-time4)
    ==
++  time-2-sys1
  |=  [sys-time1=@da sys-time2=@da]  ^-  [@da schema]  :-  sys-time2
      :*  %schema
          provenance=`path`/test-agent
          tmsp=sys-time2
          namespaces=[[p=%dbo q=sys-time1] ~ [[p=%sys q=sys-time1] ~ ~]]
          tables=[time-one-col-tbl ~ ~]
          views=(ns-sys-views %db1 sys-time2)
      ==
::++  sys2
::  :-  ~2000.1.2
::    :*  %schema
::        provenance=`path`/test-agent
::        tmsp=~2000.1.2
::        :+  [p=%ns1 q=~2000.1.2]
::            ~
::            [[p=%dbo q=~2000.1.1] ~ [[p=%sys q=~2000.1.1] ~ ~]]
::        tables=~
::        views=(ns-sys-views %db1 ~2000.1.1)
::    ==
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
  :-  ~2023.7.9..22.35.36..7e90
    :*  %data
        ~zod
        `path`/test-agent
        ~2023.7.9..22.35.36..7e90
        :+  file-insert
            ~
            ~
    ==
++  content-4
  [~2000.1.4 [%data ~zod provenance=`path`/test-agent tmsp=~2000.1.4 ~]]
++  content-1b
  [~2000.1.3 [%data ~zod provenance=`path`/test-agent tmsp=~2000.1.3 file-4]]
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
++  file-5
  :+  :-  p=[%dbo %my-table]
          :*  %file
              ship=~zod
              provenance=`path`/test-agent
              tmsp=~2000.1.4
              clustered=%.y
              length=0
              column-lookup=[n=[p=%col1 q=[%t 0]] l=~ r=~]
              key=~[[%t %.y]]
              pri-idx=file-4-pri-idx
              data=~
          ==
      l=~
      r=~
++  file-my-table
  :-  p=[%dbo %my-table]
      :*  %file
          ship=~zod
          provenance=`path`/test-agent
          tmsp=~2023.7.9..22.35.35..7e90
          clustered=%.y
          length=0
          column-lookup=[n=[p=%col1 q=[%t 0]] l=~ r=~]
          key=~[[%t %.y]]
          pri-idx=~
          data=~
      ==
++  file-insert
  :-  p=[%dbo %my-table]
      :*  %file
          ship=~zod
          provenance=`path`/test-agent
          tmsp=~2023.7.9..22.35.36..7e90
          clustered=%.y
          length=1
          column-lookup=[n=[p=%col1 q=[%t 0]] l=~ r=~]
          key=~[[%t %.y]]
          pri-idx=file-4-pri-idx
          data=~[[n=[p=%col1 q=1.685.221.219] l=~ r=~]]
      ==
++  file-4-pri-idx
  [n=[[~[1.685.221.219] [n=[p=%col1 q=1.685.221.219] l=~ r=~]]] l=~ r=~]
::
::  tables
++  one-col-tbl
::  ^-  [[@tas @tas] @table]
  :-  [%dbo %my-table]
      :*  %table
          provenance=`path`/test-agent
          tmsp=~2000.1.2
          :^  %index
              unique=%.y
              clustered=%.y
              ~[`ordered-column:ast`[%ordered-column name=%col1 ascending=%.y]]
          ~[`column:ast`[%column name=%col1 column-type=%t]]
          ~
      ==
++  time-one-col-tbl
  :-  [%dbo %my-table]
      :*  %table
          provenance=`path`/test-agent
          tmsp=~2023.7.9..22.35.35..7e90
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
    !>  (mk-db %db1 ~2000.1.1 ~[(sys1 ~2000.1.1)] ~[content-1])
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
    !>  (mk-db %db1 ~2000.1.1 ~[(sys1 ~2000.1.1)] ~[content-1])
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
    !>  ->+>+>-<.mov2
  %+  expect-eq
    !>  [%result-da 'system time' ~2000.1.2]
    !>  ->+>+>->-.mov2
  %+  expect-eq
    !>  (mk-db %db1 ~2000.1.1 ~[(sys-ns1-time2 ~2000.1.1 ~2000.1.2) (sys1 ~2000.1.1)] ~[content-1])
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
    !>  ->+>+>-<.mov2
  %+  expect-eq
    !>  [%result-da 'system time' ~2000.1.2]
    !>  ->+>+>->-.mov2
  %+  expect-eq
    !>  (mk-db %db1 ~2000.1.1 ~[(sys-ns1-time2 ~2000.1.1 ~2000.1.2) (sys1 ~2000.1.1)] ~[content-1])
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
    !>  ->+>+>-<.mov2
  %+  expect-eq
    !>  [%result-da 'system time' ~2000.1.2]
    !>  ->+>+>->-.mov2
  %+  expect-eq
    !>  (mk-db %db1 ~2000.1.1 ~[(one-col-tbl-sys ~2000.1.1 ~2000.1.2) (sys1 ~2000.1.1)] ~[content-2 content-1])
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
    !>  ->+>+>-<.mov2
  %+  expect-eq
    !>  [%result-da 'system time' ~2000.1.2]
    !>  ->+>+>->-.mov2
  %+  expect-eq
    !>  (mk-db %db1 ~2000.1.1 ~[(one-col-tbl-sys ~2000.1.1 ~2000.1.2) (sys1 ~2000.1.1)] ~[content-2 content-1])
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
    !>  ->+>+>-<.mov3
  %+  expect-eq
    !>  [%result-da 'system time' ~2000.1.3]
    !>  ->+>+>->-.mov3
  %+  expect-eq
    !>  (mk-db %db1 ~2000.1.1 ~[(two-col-tbl-sys ~2000.1.1 ~2000.1.2 ~2000.1.3) (one-col-tbl-sys ~2000.1.1 ~2000.1.2) (sys1 ~2000.1.1)] ~[content-3 content-2 content-1])
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
    !>  ->+>+>-<.mov3
  %+  expect-eq
    !>  [%result-da 'system time' ~2000.1.3]
    !>  ->+>+>->-.mov3
  %+  expect-eq
    !>  (mk-db %db1 ~2000.1.1 ~[(two-col-tbl-sys ~2000.1.1 ~2000.1.2 ~2000.1.3) (one-col-tbl-sys ~2000.1.1 ~2000.1.2) (sys1 ~2000.1.1)] ~[content-3 content-2 content-1])
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
    !>  ->+>+>-<.mov2
  %+  expect-eq
    !>  [%result-da 'system time' ~2000.1.2]
    !>  ->+>+>->-.mov2
  %+  expect-eq
    !>  (mk-db %db1 ~2000.1.1 ~[(two-comb-col-tbl-sys ~2000.1.1 ~2000.1.2) (sys1 ~2000.1.1)] ~[content-3-a content-1])
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
    !>  ->+>+>-<.mov2
  %+  expect-eq
    !>  [%result-da 'system time' ~2000.1.2]
    !>  ->+>+>->-.mov2
  %+  expect-eq
    !>  (mk-db %db1 ~2000.1.1 ~[(two-comb-col-tbl-sys ~2000.1.1 ~2000.1.2) (sys1 ~2000.1.1)] ~[content-3-a content-1])
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
    !>  ->+>+>-<.mov3
  %+  expect-eq
    !>  [%result-da 'system time' ~2000.1.3]
    !>  ->+>+>->-.mov3
  %+  expect-eq
    !>  (mk-db %db1 ~2000.1.1 ~[(one-col-tbl-drop-sys ~2000.1.1 ~2000.1.2 ~2000.1.3) (one-col-tbl-sys ~2000.1.1 ~2000.1.2) (sys1 ~2000.1.1)] ~[content-1-a content-2 content-1])
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
    !>  ->+>+>-<.mov4
  %+  expect-eq
    !>  :~  [%result-da 'system time' ~2000.1.4]
            [%result-da 'data time' ~2000.1.4]
            [%result-ud 'row count' 1]
            ==
    !>  ->+>+>->.mov4
  %+  expect-eq
    !>  (mk-db %db1 ~2000.1.1 ~[(sys4 ~2000.1.1 ~2000.1.2 ~2000.1.4) (one-col-tbl-sys ~2000.1.1 ~2000.1.2) (sys1 ~2000.1.1)] ~[content-4 content-1b content-2 content-1])
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
        ==
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
    !>  ->+>+>-<.mov3
  %+  expect-eq
    !>  [%message 'no data in table to truncate']
    !>  ->+>+>->-.mov3
  %+  expect-eq
    !>  (mk-db %db1 ~2000.1.1 ~[(one-col-tbl-sys ~2000.1.1 ~2000.1.2) (sys1 ~2000.1.1)] ~[content-2 content-1])
    !>  databases.state
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
        ==
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
    !>  ->+>+>-<.mov4
  %+  expect-eq
    !>  :~  [%result-da 'data time' ~2000.1.4]
            [%result-ud 'row count' 1]
            ==
    !>  ->+>+>->.mov4
  %+  expect-eq
    !>  (mk-db %db1 ~2000.1.1 ~[(one-col-tbl-sys ~2000.1.1 ~2000.1.2) (sys1 ~2000.1.1)] ~[content-1c content-1b content-2 content-1])
    !>  databases.state
  ==
::
::  fail on database does not exist
++  test-fail-truncate-tbl-db-not-exist     
  =|  run=@ud
  =/  cmd
    :+  %truncate-table
        [%qualified-object ship=~ database='db' namespace='dbo' name='my-table']
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
++  test-fail-truncate-tbl-ns-not-exist     
  =|  run=@ud
  =/  cmd
    :+  %truncate-table
        :*  %qualified-object
            ship=~
            database='db1'
            namespace='ns1'
            name='my-table'
        ==
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
++  test-fail-truncate-tbl-not-exist        
  =|  run=@ud
  =/  cmd
    :+  %truncate-table
        :*  %qualified-object
            ship=~
            database='db1'
            namespace='dbo'
            name='my-table'
        ==
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
  =/  row1  `(list @)`~[%db1 '/test-agent' ~2000.1.1 0 '/test-agent' ~2000.1.1]
  =/  row2  `(list @)`~[%db1 '/test-agent' ~2000.1.2 0 '/test-agent' ~2000.1.2]
  =/  row3  `(list @)`~[%db1 '/test-agent' ~2000.1.2 0 '/test-agent' ~2000.1.3]
  =/  row4  `(list @)`~[%db2 '/test-agent' ~2000.1.4 0 '/test-agent' ~2000.1.4]
  =/  row5  `(list @)`~[%db2 '/test-agent' ~2000.1.5 0 '/test-agent' ~2000.1.5]
  =/  expected  :~  %results
                    :^  %result-set
                        'sys.sys.databases'
                        (limo col-row)
                        (limo ~[row1 row2 row3 row4 row5])
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
    !>  ->+>+>-.mov6
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
                    :^  %result-set
                        ~.db1.sys.tables
                        (limo col-row)
                        %-  limo  :~  `(list @)`row1
                                      `(list @)`row2
                                      `(list @)`row3
                                      `(list @)`row4
                                      `(list @)`row5
                                      `(list @)`row6
                                      `(list @)`row7
                                      `(list @)`row8
                                      `(list @)`row9
                                      `(list @)`row10
                                      `(list @)`row11
                                      `(list @)`row12
                                      `(list @)`row13
                                      `(list @)`row14
                                      `(list @)`row15
                                      `(list @)`row16
                                      `(list @)`row17
                                      `(list @)`row18
                                      `(list @)`row19
                                      `(list @)`row20
                                      `(list @)`row21
                                      `(list @)`row22
                                      `(list @)`row23
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
    !>  ->+>+>-.mov8
::
++  test-sys-columns
  =|  run=@ud
  =/  col-row  :~  [%namespace %tas]
                   [%name %tas]
                   [%col-ordinal %ud]
                   [%col-name %tas]
                   [%col-type %tas]
                ==
  =/  row1   `(list @)`~[%dbo %my-table-2 1 %col1 %p]
  =/  row2   `(list @)`~[%dbo %my-table-2 2 %col2 %t]
  =/  row3   `(list @)`~[%dbo %my-table-3 1 %col1 %p]
  =/  row4   `(list @)`~[%dbo %my-table-3 2 %col2 %t]
  =/  row5   `(list @)`~[%dbo %my-table-3 3 %col3 %ud]
  =/  row6   `(list @)`~[%dbo %my-table-4 1 %col1 %p]
  =/  row7   `(list @)`~[%dbo %my-table-4 2 %col2 %t]
  =/  row8   `(list @)`~[%dbo %my-table-4 3 %col3 %ud]
  =/  row9   `(list @)`~[%ref %my-table 1 %col1 %t]
  =/  row10  `(list @)`~[%ref %my-table 2 %col2 %t]
  =/  expected  :~  %results
                    :^  %result-set
                        ~.db1.sys.columns
                        (limo col-row)
                        %-  limo  :~  row1
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
    !>  ->+>+>-.mov6
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
                    :^  %result-set
                        ~.db1.sys.sys-log
                        (limo col-row)
                        %-  limo  :~  `(list @)`row1
                                      `(list @)`row2
                                      `(list @)`row3
                                      `(list @)`row4
                                      `(list @)`row5
                                      `(list @)`row6
                                      `(list @)`row7
                                      `(list @)`row8
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
    !>  ->+>+>-.mov7
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
                    :^  %result-set
                        ~.db1.sys.data-log
                        (limo col-row)
                        %-  limo  :~  `(list @)`row1
                                      `(list @)`row2
                                      `(list @)`row3
                                      `(list @)`row4
                                      `(list @)`row5
                                      `(list @)`row6
                                      `(list @)`row7
                                      `(list @)`row8
                                      `(list @)`row9
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
    %:  ~(on-poke agent (bowl [run ~2000.1.1]))
        %obelisk-action
        !>([%tape %db1 "FROM sys.data-log SELECT *"])
    ==
  %+  expect-eq
    !>  expected
    !>  ->+>+>-.mov11
::
::  TIME
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
    !>  (mk-db %db1 ~2023.7.9..22.35.35..7e90 ~[(sys1 ~2023.7.9..22.35.35..7e90)] ~[content-time-1])
    !>  databases.state
  ==
::
::  time, create ns as of 1 second > schema
::  to do: think through system view creation
++  test-time-create-ns-gt-schema
  =|  run=@ud
  =^  mov1  agent  
    %:  ~(on-poke agent (bowl [run ~2000.1.1]))
        %obelisk-action
        !>([%tape-create-db "CREATE DATABASE db1"])
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
    !>  %results
    !>  ->+>+>-<.mov3
  %+  expect-eq
    !>  [%result-da 'system time' ~2023.7.9..22.35.36..7e90]
    !>  ->+>+>->-.mov3
  %+  expect-eq
    !>  (mk-db %db1 ~2000.1.1 ~[(sys-ns1-ns2 ~2000.1.1 ~2023.7.9..22.35.35..7e90 ~2023.7.9..22.35.36..7e90) (sys-ns1-time2 ~2000.1.1 ~2023.7.9..22.35.35..7e90) (sys1 ~2000.1.1)] ~[content-1])
    !>  databases.state
  ==
::
:: fail on time, create ns = schema
++  test-fail-time-create-ns-eq-schema
  =|  run=@ud
  =^  mov1  agent  
    %:  ~(on-poke agent (bowl [run ~2000.1.1]))
        %obelisk-action
        !>  :-  %tape-create-db 
                "CREATE DATABASE db1 as of ~2023.7.9..22.35.35..7e90"
    ==
  =.  run  +(run)
  %-  expect-fail
  |.  %:  ~(on-poke agent (bowl [run ~2000.1.2]))
          %obelisk-action
          !>  :-  %tape-create-db
                  "CREATE NAMESPACE ns1 as of ~2023.7.9..22.35.35..7e90"
      ==
::
:: fail on time, create ns lt schema
++  test-fail-time-create-ns-lt-schema
  =|  run=@ud
  =^  mov1  agent  
    %:  ~(on-poke agent (bowl [run ~2000.1.1]))
        %obelisk-action
        !>  :-  %tape-create-db 
                "CREATE DATABASE db1 as of ~2023.7.9..22.35.35..7e90"
    ==
  =.  run  +(run)
  %-  expect-fail
::  %+  expect-fail-message    :: To Do: crash messages
::      'namespace %ns1 as-of schema time out of order'
      |.  %:  ~(on-poke agent (bowl [run ~2000.1.2]))
              %obelisk-action
              !>  :-  %tape-create-db
                      "CREATE NAMESPACE ns1 as of ~2023.7.9..22.35.34..7e90"
          ==
::
::  fail on time, create ns = content
++  test-fail-time-create-ns-eq-content
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
  =.  run  +(run)
  =^  mov3  agent  
    %:  ~(on-poke agent (bowl [run ~2023.7.9..22.35.35..7e90]))
        %obelisk-action
        !>  :+  %tape
                %db1
                "INSERT INTO db1..my-table (col1) VALUES ('cord') ".
                "AS OF ~2023.7.9..22.35.35..7e90"
    ==
  =.  run  +(run)
  %-  expect-fail
  |.  %:  ~(on-poke agent (bowl [run ~2000.1.2]))
          %obelisk-action
          !>  :+  %tape
                  %db1
                  "CREATE NAMESPACE ns1 as of ~2023.7.9..22.35.35..7e90"
      ==
::
::  fail on time, create ns lt content
++  test-fail-time-create-ns-lt-content
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
  =.  run  +(run)
  =^  mov3  agent  
    %:  ~(on-poke agent (bowl [run ~2023.7.9..22.35.35..7e90]))
        %obelisk-action
        !>  :+  %tape
                %db1
                "INSERT INTO db1..my-table (col1) VALUES ('cord') ".
                "AS OF ~2023.7.9..22.35.35..7e90"
    ==
  =.  run  +(run)
  %-  expect-fail
  |.  %:  ~(on-poke agent (bowl [run ~2000.1.2]))
          %obelisk-action
          !>  :+  %tape
                  %db1
                  "CREATE NAMESPACE ns1 as of ~2023.7.9..22.35.34..7e90"
      ==
::
::  time, create table as of 1 second > content
::  to do: sys view creation
++  test-time-create-table-gt-schema
  =|  run=@ud
  =^  mov1  agent  
    %:  ~(on-poke agent (bowl [run ~2000.1.1]))
        %obelisk-action
        !>  :-  %tape-create-db
                "CREATE DATABASE db1 as of ~2023.7.9..22.35.35..7e90"
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
    !>  ->+>+>-<.mov2
  %+  expect-eq
    !>  [%result-da 'system time' ~2023.7.9..22.35.36..7e90]
    !>  ->+>+>->-.mov2
  %+  expect-eq
    !>  (mk-db %db1 ~2023.7.9..22.35.35..7e90 ~[(time-3-sys ~2023.7.9..22.35.35..7e90 ~2023.7.9..22.35.36..7e90) (sys1 ~2023.7.9..22.35.35..7e90)] ~[content-time-3 content-time-1])
    !>  databases.state
  ==
::
::  fail on time, create table = schema
++  test-fail-time-create-table-eq-schema
  =|  run=@ud
  =^  mov1  agent  
    %:  ~(on-poke agent (bowl [run ~2000.1.1]))
        %obelisk-action
        !>  :-  %tape-create-db
                "CREATE DATABASE db1 as of ~2023.7.9..22.35.35..7e90"
    ==
  =.  run  +(run)
  %-  expect-fail
  |.  %:  ~(on-poke agent (bowl [run ~2000.1.2]))
        %obelisk-action
        !>  :+  %tape
                %db1
                "CREATE TABLE db1..my-table-2 (col1 @t, col2 @p) ".
                "PRIMARY KEY (col1, col2) ".
                "as of ~2023.7.9..22.35.35..7e90"
    ==
::
::  fail on time, create table lt schema
++  test-fail-time-create-table-lt-schema
  =|  run=@ud
  =^  mov1  agent  
    %:  ~(on-poke agent (bowl [run ~2000.1.1]))
        %obelisk-action
        !>  :-  %tape-create-db
                "CREATE DATABASE db1 as of ~2023.7.9..22.35.35..7e90"
    ==
  =.  run  +(run)
  %-  expect-fail
  |.  %:  ~(on-poke agent (bowl [run ~2000.1.2]))
        %obelisk-action
        !>  :+  %tape
                %db1
                "CREATE TABLE db1..my-table-2 (col1 @t, col2 @p) ".
                "PRIMARY KEY (col1, col2) ".
                "as of ~2023.7.9..22.35.34..7e90"
    ==
::
::  fail on time, create table = content
++  test-fail-time-create-table-eq-content
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
  =.  run  +(run)
  =^  mov3  agent  
    %:  ~(on-poke agent (bowl [run ~2023.7.9..22.35.35..7e90]))
        %obelisk-action
        !>  :+  %tape
                %db1
                "INSERT INTO db1..my-table (col1) VALUES ('cord') ".
                "AS OF ~2023.7.9..22.35.35..7e90"
    ==
  =.  run  +(run)
  %-  expect-fail
  |.  %:  ~(on-poke agent (bowl [run ~2000.1.2]))
          %obelisk-action
          !>  :+  %tape
                  %db1
                  "CREATE TABLE db1..my-table-2 (col1 @t) PRIMARY KEY (col1) ".
                  "AS OF ~2023.7.9..22.35.35..7e90"
      ==
::
::  fail on time, create table < content
++  test-fail-time-create-table-lt-content
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
  =.  run  +(run)
  =^  mov3  agent  
    %:  ~(on-poke agent (bowl [run ~2023.7.9..22.35.35..7e90]))
        %obelisk-action
        !>  :+  %tape
                %db1
                "INSERT INTO db1..my-table (col1) VALUES ('cord') ".
                "AS OF ~2023.7.9..22.35.35..7e90"
    ==
  =.  run  +(run)
  %-  expect-fail
  |.  %:  ~(on-poke agent (bowl [run ~2000.1.2]))
          %obelisk-action
          !>  :+  %tape
                  %db1
                  "CREATE TABLE db1..my-table-2 (col1 @t) PRIMARY KEY (col1) ".
                  "AS OF ~2023.7.9..22.35.35..7e90"
      ==
::
::  time, drop table as of 1 second > content
++  test-time-drop-table-gt-schema
  =|  run=@ud
  =^  mov1  agent  
    %:  ~(on-poke agent (bowl [run ~2000.1.1]))
        %obelisk-action
        !>  :-  %tape-create-db
                "CREATE DATABASE db1"
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
    !>  %results
    !>  ->+>+>-<.mov3
  %+  expect-eq
    !>  [%result-da 'system time' ~2023.7.9..22.35.38..7e90]
    !>  ->+>+>->-.mov3
  %+  expect-eq
    !>  (mk-db %db1 ~2000.1.1 ~[(time-5-sys ~2000.1.1 ~2023.7.9..22.35.36..7e90 ~2023.7.9..22.35.37..7e90 ~2023.7.9..22.35.38..7e90) (time-4-sys ~2000.1.1 ~2023.7.9..22.35.36..7e90 ~2023.7.9..22.35.37..7e90) (time-3a-sys ~2000.1.1 ~2023.7.9..22.35.36..7e90) (sys1 ~2000.1.1)] ~[content-time-5 content-time-3 content-1])
    !>  databases.state
  ==
::
::  fail on time, drop table = schema
++  test-fail-time-drop-table-eq-schema
  =|  run=@ud
  =^  mov1  agent  
    %:  ~(on-poke agent (bowl [run ~2000.1.1]))
        %obelisk-action
        !>  :-  %tape-create-db
                "CREATE DATABASE db1 as of ~2023.7.9..22.35.35..7e90"
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
  %-  expect-fail
  |.  %:  ~(on-poke agent (bowl [run ~2000.1.2]))
        %obelisk-action
        !>  :+  %tape
                %db1
                "DROP TABLE db1..my-table-2 ".
                "AS OF ~2023.7.9..22.35.37..7e90"
    ==
::
::  fail on time, drop table lt schema
++  test-fail-time-drop-table-lt-schema
  =|  run=@ud
  =^  mov1  agent  
    %:  ~(on-poke agent (bowl [run ~2000.1.1]))
        %obelisk-action
        !>  :-  %tape-create-db
                "CREATE DATABASE db1 as of ~2023.7.9..22.35.35..7e90"
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
  %-  expect-fail
  |.  %:  ~(on-poke agent (bowl [run ~2000.1.2]))
        %obelisk-action
        !>  :+  %tape
                %db1
                "DROP TABLE db1..my-table-2 ".
                "AS OF ~2023.7.9..22.35.36..7e90"
    ==
::
::  fail on time, drop table = content
++  test-fail-time-drop-table-eq-content
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
  =.  run  +(run)
  =^  mov3  agent  
    %:  ~(on-poke agent (bowl [run ~2023.7.9..22.35.35..7e90]))
        %obelisk-action
        !>  :+  %tape
                %db1
                "INSERT INTO db1..my-table (col1) VALUES ('cord') ".
                "AS OF ~2023.7.9..22.35.35..7e90"
    ==
  =.  run  +(run)
  %-  expect-fail
  |.  %:  ~(on-poke agent (bowl [run ~2000.1.2]))
          %obelisk-action
          !>  :+  %tape
                  %db1
                  "DROP TABLE db1..my-table as of ~2023.7.9..22.35.35..7e90"
      ==
::
::  fail on time, drop table < content
++  test-fail-time-drop-table-lt-content
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
  =.  run  +(run)
  =^  mov3  agent  
    %:  ~(on-poke agent (bowl [run ~2023.7.9..22.35.35..7e90]))
        %obelisk-action
        !>  :+  %tape
                %db1
                "INSERT INTO db1..my-table (col1) VALUES ('cord') ".
                "AS OF ~2023.7.9..22.35.35..7e90"
    ==
  =.  run  +(run)
  %-  expect-fail
  |.  %:  ~(on-poke agent (bowl [run ~2000.1.2]))
          %obelisk-action
          !>  :+  %tape
                  %db1
                  "DROP TABLE db1..my-table as of ~2023.7.9..22.35.34..7e90"
      ==
::
::  time, insert as of 1 second > schema
++  test-time-insert-gt-schema
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
          :~  [%result-ud 'row count' 1]
              [%result-da 'data time' ~2023.7.9..22.35.36..7e90]
              ==
    !>  ->+>+>-.mov3
  %+  expect-eq
    !>  (mk-db %db1 ~2000.1.1 ~[(time-2-sys1 ~2000.1.1 ~2023.7.9..22.35.36..7e90) (sys1 ~2000.1.1)] ~[content-insert content-my-table content-1])
    !>  databases.state
  ==
::
::  fail on time,  insert = schema
++  test-fail-insert-eq-schema
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
                "CREATE TABLE db1..my-table (col1 @t) PRIMARY KEY (col1) ".
                "AS OF ~2023.7.9..22.35.35..7e90"
    ==
  =.  run  +(run)
  =^  mov3  agent  
    %:  ~(on-poke agent (bowl [run ~2000.1.3]))
        %obelisk-action
        !>([%tape %db1 "CREATE NAMESPACE ns1 as of ~2023.7.9..22.35.36..7e90"])
    ==
  =.  run  +(run)
  %-  expect-fail
  |.  %:  ~(on-poke agent (bowl [run ~2000.1.2]))
        %obelisk-action
        !>  :+  %tape 
                %db1 
                "INSERT INTO db1..my-table (col1) VALUES ('cord') ".
                "AS OF ~2023.7.9..22.35.36..7e90"
    ==
::
::  fail on time,  insert < schema
++  test-fail-insert-lt-schema
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
                "CREATE TABLE db1..my-table (col1 @t) PRIMARY KEY (col1) ".
                "AS OF ~2023.7.9..22.35.34..7e90"
    ==
  =.  run  +(run)
  =^  mov3  agent  
    %:  ~(on-poke agent (bowl [run ~2000.1.3]))
        %obelisk-action
        !>([%tape %db1 "CREATE NAMESPACE ns1 as of ~2023.7.9..22.35.36..7e90"])
    ==
  =.  run  +(run)
  %-  expect-fail
  |.  %:  ~(on-poke agent (bowl [run ~2000.1.2]))
        %obelisk-action
        !>  :+  %tape 
                %db1 
                "INSERT INTO db1..my-table (col1) VALUES ('cord') ".
                "AS OF ~2023.7.9..22.35.35..7e90"
    ==
::
::  fail on time,  insert = data
++  test-fail-insert-eq-data
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
                "CREATE TABLE db1..my-table (col1 @t) PRIMARY KEY (col1) ".
                "AS OF ~2023.7.9..22.35.34..7e90"
    ==
  =.  run  +(run)
  =^  mov3  agent  
    %:  ~(on-poke agent (bowl [run ~2000.1.3]))
        %obelisk-action
        !>  :+  %tape 
                %db1 
                "INSERT INTO db1..my-table (col1) VALUES ('cord') ".
                "AS OF ~2023.7.9..22.35.35..7e90"
    ==
  =.  run  +(run)
  %-  expect-fail
  |.  %:  ~(on-poke agent (bowl [run ~2000.1.2]))
        %obelisk-action
        !>  :+  %tape 
                %db1 
                "INSERT INTO db1..my-table (col1) VALUES ('foo') ".
                "AS OF ~2023.7.9..22.35.35..7e90"
    ==
::
::  fail on time,  insert < data
++  test-fail-insert-lt-data
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
                "CREATE TABLE db1..my-table (col1 @t) PRIMARY KEY (col1) ".
                "AS OF ~2023.7.9..22.35.33..7e90"
    ==
  =.  run  +(run)
  =^  mov3  agent  
    %:  ~(on-poke agent (bowl [run ~2000.1.3]))
        %obelisk-action
        !>  :+  %tape 
                %db1 
                "INSERT INTO db1..my-table (col1) VALUES ('cord') ".
                "AS OF ~2023.7.9..22.35.35..7e90"
    ==
  =.  run  +(run)
  %-  expect-fail
  |.  %:  ~(on-poke agent (bowl [run ~2000.1.2]))
        %obelisk-action
        !>  :+  %tape 
                %db1 
                "INSERT INTO db1..my-table (col1) VALUES ('foo') ".
                "AS OF ~2023.7.9..22.35.34..7e90"
    ==
::
::  fail on changing state after select in script
++  test-fail-state-update-action-after-select
  =|  run=@ud
  =^  mov1  agent  
    %:  ~(on-poke agent (bowl [run ~2000.1.1]))
        %obelisk-action
        !>([%tape-create-db "CREATE DATABASE db1"])
    ==
  =.  run  +(run)
  %-  expect-fail
  |.  %:  ~(on-poke agent (bowl [run ~2000.1.2]))
        %obelisk-action
        !>  :+  %tape
                %db1 
                "CREATE TABLE db1..my-table (col1 @t) PRIMARY KEY (col1); ".
                "SELECT 0;".
                "INSERT INTO db1..my-table (col1) VALUES ('cord') "
    ==
--