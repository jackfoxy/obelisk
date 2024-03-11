::  Demonstrate unit testing on a Gall agent with %obelisk.
::
/-  ast, *obelisk
/+  *test, *sys-views, *utils
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
::++  ns-sys-2views
::    |*  [db=@tas sys-time1=@da sys-time2=@da]
::    ^-  views
::    %+  gas:ns-objs-key  *((mop data-obj-key view) ns-obj-comp)
::                         (weld (db-views db sys-time1) (db-views db sys-time2))
::++  ns-sys-3views
::    |*  [db=@tas sys-time1=@da sys-time2=@da sys-time3=@da]
::    ^-  views
::    %+  gas:ns-objs-key  *((mop data-obj-key view) ns-obj-comp)
::                         (weld (weld (db-views db sys-time1) (db-views db sys-time2)) (db-views db sys-time3))
::++  ns-sys-4views
::    |*  [db=@tas sys-time1=@da sys-time2=@da sys-time3=@da sys-time4=@da]
::    ^-  views
::    %+  gas:ns-objs-key  *((mop data-obj-key view) ns-obj-comp)
::                         (weld (weld (weld (db-views db sys-time1) (db-views db sys-time2)) (db-views db sys-time3)) (db-views db sys-time4))                 
::++  ns-2-ns-sys-views
::    |*  [db=@tas sys-time1=@da sys-time2=@da]
::    ^-  views
::    =/  ns-views=(list [[@tas @tas @da] view])  %-  limo  :~  
::         :-  [%sys %sys-namespaces sys-time2]
::            %-  apply-ordering 
::                (sys-namespaces-view db `path`(limo `path`/test-agent) sys-time2)
::        :-  [%sys %sys-sys-log sys-time2]
::            %-  apply-ordering
::                (sys-sys-log-view db `path`(limo `path`/test-agent) sys-time2)
::        ==
::    %+  gas:ns-objs-key  *((mop data-obj-key view) ns-obj-comp)
::                         (weld (db-views db sys-time1) ns-views)
::++  ns-sys-views3
::    |*  [db=@tas sys-time1=@da sys-time2=@da sys-time3=@da]
::    ^-  views
::    =/  ns-views=(list [[@tas @tas @da] view])  %-  limo  :~  
::        :-  [%sys %sys-namespaces sys-time1]
::            %-  apply-ordering 
::                (sys-namespaces-view db `path`(limo `path`/test-agent) sys-time1)
::        :-  [%sys %sys-sys-log sys-time1]
::            %-  apply-ordering
::                (sys-sys-log-view db `path`(limo `path`/test-agent) sys-time1)
::        :-  [%sys %sys-namespaces sys-time3]
::            %-  apply-ordering 
::                (sys-namespaces-view db `path`(limo `path`/test-agent) sys-time3)
::        :-  [%sys %sys-sys-log sys-time3]
::            %-  apply-ordering
::                (sys-sys-log-view db `path`(limo `path`/test-agent) sys-time3)
::
::        :-  [%sys %sys-namespaces sys-time2]
::            %-  apply-ordering 
::                (sys-namespaces-view db `path`(limo `path`/test-agent) sys-time2)
::        :-  [%sys %sys-sys-log sys-time2]
::            %-  apply-ordering
::                (sys-sys-log-view db `path`(limo `path`/test-agent) sys-time2)
::        :-  [%sys %sys-namespaces sys-time3]
::            %-  apply-ordering 
::                (sys-namespaces-view db `path`(limo `path`/test-agent) sys-time3)
::        :-  [%sys %sys-sys-log sys-time3]
::            %-  apply-ordering
::                (sys-sys-log-view db `path`(limo `path`/test-agent) sys-time3)
::        ==
::    %+  gas:ns-objs-key  *((mop data-obj-key view) ns-obj-comp)
::                         (weld (db-views db sys-time1) ns-views)
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
::        views=(ns-sys-views3 %db1 sys-time1 sys-time2 sys-time3)
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
::        views=(ns-sys-2views %db1 sys-time1 sys-time2)
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
::        views=(ns-sys-3views %db1 sys-time1 sys-time2 sys-time3)
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
::        views=(ns-sys-3views %db1 sys-time1 sys-time2 sys-time3)
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
::        views=(ns-2-ns-sys-views %db1 sys-time1 sys-time2)
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
::        views=(ns-sys-2views %db1 sys-time1 sys-time2)
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
::        views=(ns-sys-3views %db1 sys-time1 sys-time2 sys-time3)
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
::        views=(ns-sys-2views %db1 sys-time1 sys-time2)
        views=(ns-sys-views %db1 sys-time2)
    ==
++  time-3a-sys
  |=  [sys-time1=@da sys-time2=@da]  ^-  [@da schema]  :-  sys-time2
    :*  %schema
        provenance=`path`/test-agent
        tmsp=sys-time2
        namespaces=[[p=%dbo q=sys-time1] ~ [[p=%sys q=sys-time1] ~ ~]]
        tables=[time-3-tbl ~ ~]
::        views=(ns-sys-2views %db1 sys-time1 sys-time2)
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
::        views=(ns-sys-3views %db1 sys-time1 sys-time2 sys-time3)
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
::        views=(ns-sys-4views %db1 sys-time1 sys-time2 sys-time3 sys-time4)
        views=(ns-sys-views %db1 sys-time4)
    ==
::++  time-2-sys1
::  :-  ~2023.7.9..22.35.35..7e90
::      :*  %schema
::          provenance=`path`/test-agent
::          tmsp=~2023.7.9..22.35.35..7e90
::          namespaces=[[p=%dbo q=sys-time] ~ [[p=%sys q=sys-time] ~ ~]]
::          tables=[time-one-col-tbl ~ ~]
::          views=(ns-sys-views %db1 ~2000.1.1)
::      ==
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
::  time, create ns as of 1 second > schema
::  to do: think through system view creation
::++  test-time-create-ns-gt-schema
::  =|  run=@ud
::  =^  mov1  agent  
::    %:  ~(on-poke agent (bowl [run ~2000.1.1]))
::        %obelisk-action
::        !>([%tape-create-db "CREATE DATABASE db1"])
::    ==
::  =.  run  +(run)
::  =^  mov2  agent  
::    %:  ~(on-poke agent (bowl [run ~2000.1.3]))
::        %obelisk-action
::        !>([%tape %db1 "CREATE NAMESPACE ns1 as of ~2023.7.9..22.35.35..7e90"])
::    ==
::  =.  run  +(run)
::  =^  mov3  agent  
::    %:  ~(on-poke agent (bowl [run ~2000.1.3]))
::        %obelisk-action
::        !>([%tape %db1 "CREATE NAMESPACE ns2 as of ~2023.7.9..22.35.36..7e90"])
::    ==
::  =+  !<(=state on-save:agent)
::  ;:  weld
::  %+  expect-eq
::    !>  %results
::    !>  ->+>+>-<.mov3
::  %+  expect-eq
::    !>  [%result-da 'system time' ~2023.7.9..22.35.36..7e90]
::    !>  ->+>+>->-.mov3
::  %+  expect-eq
::    !>  (db-time-create-ns ~2000.1.1)   ****
::    !>  databases.state
::  ==

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
--
