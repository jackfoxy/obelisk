::  unit tests on %obelisk library simulating pokes
::
/-  ast, *obelisk
/+  *test, *obelisk, parse
|%
::
::  Build an example bowl manually.
++  bowl
  |=  [run=@ud now=@da]
  ^-  bowl:gall
  :*  [~zod ~zod %obelisk `path`(limo `path`/test-agent)] :: (our src dap sap)
      [~ ~ ~]                                          :: (wex sup sky)
      [run `@uvJ`(shax run) now [~zod %base ud+run]]   :: (act eny now byk)
  ==
::
::  Build a reference state mold.
+$  state
  $:  %0 
      =databases
      ==
--
|%
::
::  databases
++  start-dbs
  :+
    :-  %db1
      :*  %database
          name=%db1
          created-provenance=`path`/test-agent
          created-tmsp=~2023.7.9..22.24.54..4b8a
          %+  gas:schema-key  *((mop @da schema) gth)
                              ~[gen2-sys gen1-sys gen0-sys]
          %+  gas:data-key  *((mop @da data) gth)
                            ~[gen2-data gen1-data gen0-data]
      ==
    ~
    ~
++  gen3-dbs
  :+
    :-  %db1
      :*  %database
          name=%db1
          created-by-provenance=`path`/test-agent
          created-tmsp=~2023.7.9..22.24.54..4b8a
          %+  gas:schema-key  *((mop @da schema) gth)
                              ~[gen2-sys gen1-sys gen0-sys]
          %+  gas:data-key  *((mop @da data) gth)
                            ~[gen3-data gen2-data gen1-data gen0-data]
      ==
    ~
    ~
++  gen4-dbs
  :+
    :-  %db1
      :*  %database
          name=%db1
          created-by-provenance=`path`/test-agent
          created-tmsp=~2023.7.9..22.24.54..4b8a
          %+  gas:schema-key  *((mop @da schema) gth)
                              ~[gen2-sys gen1-sys gen0-sys]
          %+  gas:data-key  *((mop @da data) gth)
                            ~[gen4-data gen3-data gen2-data gen1-data gen0-data]
      ==
    ~
    ~
++  dbs-time-1
  :+
    :-  %db1
      :*  %database
          name=%db1
          created-by-provenance=`path`/test-agent
          created-tmsp=~2023.7.9..22.24.54..4b8a
          %+  gas:schema-key  *((mop @da schema) gth)
                              ~[sys-time-1 gen2-sys gen1-sys gen0-sys]
          %+  gas:data-key  *((mop @da data) gth)
                            ~[gen3-data gen2-data gen1-data gen0-data]
      ==
    ~
    ~
++  dbs-time-2
  :+
    :-  %db1
      :*  %database
          name=%db1
          created-by-provenance=`path`/test-agent
          created-tmsp=~2023.7.9..22.24.54..4b8a
          %+  gas:schema-key  *((mop @da schema) gth)
                              ~[sys-time-2 gen2-sys gen1-sys gen0-sys]
          %+  gas:data-key  *((mop @da data) gth)
                            ~[time2-data gen3-data gen2-data gen1-data gen0-data]
      ==
    ~
    ~
::
::  schemas
++  schema-key  ((on @da schema) gth)
++  gen0-sys
  :-  ~2023.7.9..22.24.54..4b8a
    :*  %schema
        provenance=`path`/test-agent
        tmsp=~2023.7.9..22.24.54..4b8a
        namespaces=schema-ns
        tables=~
    ==
++  gen1-sys
  :-  ~2023.7.9..22.27.32..49e3
    :*  %schema
        provenance=`path`/test-agent
        tmsp=~2023.7.9..22.27.32..49e3
        namespaces=schema-ns
        tables=[n=schema-my-table l=~ r=~]
    ==
++  gen2-sys
  :-  ~2023.7.9..22.35.34..7e90
    :*  %schema
        provenance=`path`/test-agent
        tmsp=~2023.7.9..22.35.34..7e90
        namespaces=schema-ns
        tables=[n=schema-my-table l=[n=schema-table-3 l=~ r=~] r=~]
    ==
++  sys-time-1
  :-  ~2023.7.9..22.35.35..7e90
    :*  %schema
        provenance=`path`/test-agent
        tmsp=~2023.7.9..22.35.35..7e90
        namespaces=schema-ns-2
        tables=[n=schema-my-table l=[n=schema-table-3 l=~ r=~] r=~]
    ==
++  sys-time-2
  :-  ~2023.7.9..22.35.35..7e90
    :*  %schema
        provenance=`path`/test-agent
        tmsp=~2023.7.9..22.35.35..7e90
        namespaces=schema-ns
        tables=[n=schema-my-table-2 l=[n=schema-table-3 l=~ r=~] r=[schema-my-table ~ ~]]
    ==
++  schema-ns
  :+  n=[p=%dbo q=~2023.7.9..22.24.54..4b8a]
      l=~
      r=[n=[p=%sys q=~2023.7.9..22.24.54..4b8a] l=~ r=~]
++  schema-ns-2
  :+  n=[p=%ns1 q=~2023.7.9..22.35.35..7e90]
      l=~
      :+  n=[p=%dbo q=~2023.7.9..22.24.54..4b8a] 
          l=~ 
          r=[n=[p=%sys q=~2023.7.9..22.24.54..4b8a] ~ ~]
::
::  content
++  data-key  ((on @da data) gth)
++  gen0-data
  :-  ~2023.7.9..22.24.54..4b8a
    :*  %data
        ship=~zod
        provenance=`path`/test-agent
        tmsp=~2023.7.9..22.24.54..4b8a
        files=~
    ==
++  gen1-data
  :-  ~2023.7.9..22.27.32..49e3
    :*  %data
        ship=~zod
        provenance=`path`/test-agent
        tmsp=~2023.7.9..22.27.32..49e3
        files=[n=file-my-table l=~ r=~]
    ==
++  gen2-data
  :-  ~2023.7.9..22.35.34..7e90
    :*  %data
        ship=~zod
        provenance=`path`/test-agent
        tmsp=~2023.7.9..22.35.34..7e90
        files=[n=file-my-table l=[n=file-my-table-3 l=~ r=~] r=~]
    ==
++  gen3-data
  :-  ~2030.1.1
    :*  %data
        ship=~zod
        provenance=`path`/test-agent
        tmsp=~2030.1.1
        files=[n=file-my-table l=[n=gen3-file-my-table-3 l=~ r=~] r=~]
    ==
++  gen4-data
  :-  ~2030.2.1
    :*  %data
        ship=~zod
        provenance=`path`/test-agent
        tmsp=~2030.2.1
        files=[n=file-my-table l=[n=gen4-file-my-table-3 l=~ r=~] r=~]
    ==
++  time2-data
  :-  ~2023.7.9..22.35.35..7e90
    :*  %data
        ship=~zod
        provenance=`path`/test-agent
        tmsp=~2023.7.9..22.35.35..7e90
        files=[n=file-my-table-2 l=[n=gen3-file-my-table-3 l=~ r=~] r=[file-my-table ~ ~]]
    ==
::
::  files
++  file-my-table
  :-  p=[%dbo %my-table] 
      :*  %file
          ship=~zod
          provenance=`path`/test-agent
          tmsp=~2023.7.9..22.27.32..49e3
          clustered=%.y
          length=0
          column-lookup=[n=[p=%col1 q=[%t 0]] l=~ r=~]
          key=~[[%t %.y]]
          pri-idx=~
          data=~
      ==
++  file-my-table-2
  :-  p=[%dbo %my-table-2]
      :*  %file
          ship=~zod
          provenance=/test-agent
          tmsp=~2023.7.9..22.35.35..7e90
          clustered=%.y
          length=0
          [n=[p=%col3 q=[%ud 2]] l=[n=[p=%col2 q=[%p 1]] l=~ r=~] r=[n=[p=%col1 q=[%t 0]] l=~ r=~]]
          key=~[[%t %.y] [%p %.y]]
          pri-idx=~
          data=~
      ==
++  file-my-table-3
  :-  p=[%dbo %my-table-3] 
      :*  %file
          ship=~zod
          provenance=`path`/test-agent
          tmsp=~2023.7.9..22.35.34..7e90
          clustered=%.y
          length=0
          column-lookup=col-lu-table-3
          key=~[[%t %.y] [%ud %.n]]
          pri-idx=~
          data=~
      ==
  ++  gen3-file-my-table-3
  :-  p=[%dbo %my-table-3] 
  :*  %file
      ship=~zod
      provenance=`path`/test-agent
      tmsp=~2030.1.1
      clustered=%.y
      length=2
      column-lookup=col-lu-table-3
      key=~[[%t %.y] [%ud %.n]]
      pri-idx=file-pri-idx-my-table-3
      data=file-data-my-table-3
  ==
++  gen4-file-my-table-3
  :-  p=[%dbo %my-table-3]
      :*  %file
          ship=~zod
          provenance=`path`/test-agent
          tmsp=~2030.2.1
          clustered=%.y
          length=4
          column-lookup=col-lu-table-3
          key=~[[%t %.y] [%ud %.n]]
          pri-idx=gen4-file-pri-idx-my-table-3
          data=gen4-file-data-my-table-3
      ==
::
::  tables
++  schema-my-table
  :-  p=[%dbo %my-table] 
      :*  %table
          provenance=`path`/test-agent
          tmsp=~2023.7.9..22.24.54..4b8a
          :*  %index
              unique=%.y
              clustered=%.y
              columns=~[[%ordered-column name=%col1 ascending=%.y]]
          ==
          columns=~[[%column name=%col1 type=%t]]
          indices=~
      ==
++  schema-my-table-2
  :-  p=[%dbo %my-table-2] 
      :*  %table
          provenance=`path`/test-agent
          tmsp=~2023.7.9..22.35.35..7e90
          :*  %index
              unique=%.y
              clustered=%.y
              columns=~[[%ordered-column name=%col1 ascending=%.y] [%ordered-column name=%col2 ascending=%.y]]
          ==
          columns=~[[%column name=%col1 type=%t] [%column name=%col2 type=%p] [%column name=%col3 type=%ud]]
          indices=~
      ==
++  schema-table-3
  :-  p=[%dbo %my-table-3] 
      :*  %table
          provenance=`path`/test-agent
          tmsp=~2023.7.9..22.24.54..4b8a
          pri-indx=pri-indx-table-3
          :~  [%column name=%col1 type=%t]
              [%column name=%col2 type=%p]
              [%column name=%col3 type=%ud]
          ==
          indices=~
      ==
::
++  pri-indx-table-3
  :*  %index
      unique=%.y
      clustered=%.y
      :~  [%ordered-column name=%col1 ascending=%.y]
          [%ordered-column name=%col3 ascending=%.n]
      ==
  ==
::
++  col-lu-table-3
  :+  n=[p=%col3 q=[%ud 2]]
      l=[n=[p=%col2 q=[%p 1]] l=~ r=~]
      r=[n=[p=%col1 q=[%t 0]] l=~ r=~]
::
++  row1
  :+  n=[p=%col3 q=20]
      l=[n=[p=%col2 q=28.242.037] l=~ r=~]
      r=[n=[p=%col1 q=1.685.221.219] l=~ r=~]
++  row1-idx
  [~[1.685.221.219 20] row1]
++  row2
  :+  n=[p=%col3 q=0]
      l=[n=[p=%col2 q=0] l=~ r=~]
      r=[n=[p=%col1 q=32.770.348.699.510.084] l=~ r=~]
++  row2-idx
  [~[32.770.348.699.510.084 0] row2]
++  file-pri-idx-my-table-3
  [n=row2-idx l=~ r=[row1-idx ~ ~]]
++  file-data-my-table-3
  ~[row2 row1]
++  row3
  :+  n=[p=%col3 q=21]
      l=[n=[p=%col2 q=1] l=~ r=~]
      r=[n=[p=%col1 q=216.433.586.019] l=~ r=~]
++  row3-idx
  [~[216.433.586.019 21] row3]
++  row4
  :+  n=[p=%col3 q=1]
      l=[n=[p=%col2 q=182] l=~ r=~]
      r=[n=[p=%col1 q=216.433.586.019] l=~ r=~]
++  row4-idx
  [~[216.433.586.019 1] row4]
++  gen4-file-pri-idx-my-table-3
  :+  n=row2-idx
      ~
      r=[row4-idx l=[row1-idx ~ r=[row3-idx ~ ~]] ~]
++  gen4-file-data-my-table-3
  ~[row4 row3 row2 row1]
::
::  set-tmsp back 0 seconds
++  test-set-tmsp-00
  %+  expect-eq                         
    !>  ~2023.12.25..7.15.0..1ef5
    !>  %-  set-tmsp
            :-  `(as-of-offset:ast %as-of-offset 0 %seconds)
                ~2023.12.25..7.15.0..1ef5
::
::  set-tmsp back 65 seconds
++  test-set-tmsp-01
  %+  expect-eq                         
    !>  ~2023.12.25..7.13.55..1ef5
    !>  %-  set-tmsp
          :-  `(as-of-offset:ast %as-of-offset 65 %seconds)
              ~2023.12.25..7.15.0..1ef5
::
::  set-tmsp back 0 minutes
++  test-set-tmsp-02
  %+  expect-eq                         
    !>  ~2023.12.25..7.15.0..1ef5
    !>  %-  set-tmsp
            :-  `(as-of-offset:ast %as-of-offset 0 %minutes)
                ~2023.12.25..7.15.0..1ef5
::
::  set-tmsp back 65 minutes
++  test-set-tmsp-03
  %+  expect-eq                         
    !>  ~2023.12.25..6.10.0..1ef5
    !>  %-  set-tmsp
            :-  `(as-of-offset:ast %as-of-offset 65 %minutes)
                ~2023.12.25..7.15.0..1ef5
::
::  set-tmsp back 0 hours
++  test-set-tmsp-04
  %+  expect-eq                         
    !>  ~2023.12.25..7.15.0..1ef5
    !>  %-  set-tmsp
            :-  `(as-of-offset:ast %as-of-offset 0 %hours)
                ~2023.12.25..7.15.0..1ef5
::
::  set-tmsp back 65 hours
++  test-set-tmsp-05
  %+  expect-eq                         
    !>  ~2023.12.22..14.15.0..1ef5
    !>  %-  set-tmsp
            :-  `(as-of-offset:ast %as-of-offset 65 %hours)
                ~2023.12.25..7.15.0..1ef5
::
::  set-tmsp back 0 days
++  test-set-tmsp-06
  %+  expect-eq                         
    !>  ~2023.12.25..7.15.0..1ef5
    !>  %-  set-tmsp
            :-  `(as-of-offset:ast %as-of-offset 0 %days)
                ~2023.12.25..7.15.0..1ef5
::
::  set-tmsp back 65 days
++  test-set-tmsp-07
  %+  expect-eq                         
    !>  ~2023.10.21..7.15.0..1ef5
    !>  %-  set-tmsp
            :-  `(as-of-offset:ast %as-of-offset 65 %days)
                ~2023.12.25..7.15.0..1ef5
::
::  set-tmsp back 0 weeks
++  test-set-tmsp-08
  %+  expect-eq                         
    !>  ~2023.12.25..7.15.0..1ef5
    !>  %-  set-tmsp
            :-  `(as-of-offset:ast %as-of-offset 0 %weeks)
                ~2023.12.25..7.15.0..1ef5
::
::  set-tmsp back 65 weeks
++  test-set-tmsp-09
  %+  expect-eq                         
    !>  ~2022.9.26..7.15.0..1ef5
    !>  %-  set-tmsp
            :-  `(as-of-offset:ast %as-of-offset 65 %weeks)
                ~2023.12.25..7.15.0..1ef5
::
::  set-tmsp leap year
++  test-set-tmsp-10
  %+  expect-eq                         
    !>  ~2020.2.27..7.15.0..1ef5
    !>  %-  set-tmsp
            :-  `(as-of-offset:ast %as-of-offset 7 %days)
                ~2020.3.5..7.15.0..1ef5
::
::  set-tmsp back 0 months
++  test-set-tmsp-11
  %+  expect-eq                         
    !>  ~2023.12.25..7.15.0..1ef5
    !>  %-  set-tmsp
            :-  `(as-of-offset:ast %as-of-offset 0 %months)
                ~2023.12.25..7.15.0..1ef5
::
::  set-tmsp back 65 months
++  test-set-tmsp-12
  %+  expect-eq                         
    !>  ~2018.7.25..7.15.0..1ef5
    !>  %-  set-tmsp
            :-  `(as-of-offset:ast %as-of-offset 65 %months)
                ~2023.12.25..7.15.0..1ef5
::
::  set-tmsp back 3 months
++  test-set-tmsp-13
  %+  expect-eq                         
    !>  ~2019.12.5..7.15.0..1ef5
    !>  %-  set-tmsp
            :-  `(as-of-offset:ast %as-of-offset 3 %months)
                ~2020.3.5..7.15.0..1ef5
::
::  set-tmsp back 2 months
++  test-set-tmsp-14
  %+  expect-eq                         
    !>  ~2020.1.5..7.15.0..1ef5
    !>  %-  set-tmsp
            :-  `(as-of-offset:ast %as-of-offset 2 %months)
                ~2020.3.5..7.15.0..1ef5
::
::  set-tmsp back 0 years
++  test-set-tmsp-15
  %+  expect-eq                         
    !>  ~2023.12.25..7.15.0..1ef5
    !>  %-  set-tmsp
            :-  `(as-of-offset:ast %as-of-offset 0 %years)
                ~2023.12.25..7.15.0..1ef5
::
::  set-tmsp back 65 years
++  test-set-tmsp-16
  %+  expect-eq                         
    !>  ~1958.12.25..7.15.0..1ef5
    !>  %-  set-tmsp
            :-  `(as-of-offset:ast %as-of-offset 65 %years)
                ~2023.12.25..7.15.0..1ef5
::
::  set-tmsp to ~1962.2.2..7.15.0..1ef5
++  test-set-tmsp-17
  %+  expect-eq                         
    !>  ~1962.2.2..7.15.0..1ef5
    !>  (set-tmsp [`[%da ~1962.2.2..7.15.0..1ef5] ~2023.12.25..7.15.0..1ef5])
::
::  set-tmsp back ~s65
++  test-set-tmsp-18
  %+  expect-eq                         
    !>  ~2023.12.25..7.13.55..1ef5
    !>  (set-tmsp [`[%dr ~s65] ~2023.12.25..7.15.0..1ef5])
::
::  set-tmsp back ~m65
++  test-set-tmsp-19
  %+  expect-eq                         
    !>  ~2023.12.25..6.10.0..1ef5
    !>  (set-tmsp [`[%dr ~m65] ~2023.12.25..7.15.0..1ef5])
::
::  set-tmsp back ~m65.s65
++  test-set-tmsp-20
  %+  expect-eq                         
    !>  ~2023.12.25..6.8.55..1ef5
    !>  (set-tmsp [`[%dr ~m65.s65] ~2023.12.25..7.15.0..1ef5])
::
::  set-tmsp back ~h2.m12.s5
++  test-set-tmsp-21
  %+  expect-eq                         
    !>  ~2023.12.25..5.2.55..1ef5
    !>  (set-tmsp [`[%dr ~h2.m12.s5] ~2023.12.25..7.15.0..1ef5])
::
::  set-tmsp back ~d5.h2.m12.s5
++  test-set-tmsp-22
  %+  expect-eq                         
    !>  ~2023.12.20..5.2.55..1ef5
    !>  (set-tmsp [`[%dr ~d5.h2.m12.s5] ~2023.12.25..7.15.0..1ef5])
::
::  set-tmsp back ~s0
++  test-set-tmsp-23
  %+  expect-eq                         
    !>  ~2023.12.25..7.15.0..1ef5
    !>  (set-tmsp [`[%dr ~s0] ~2023.12.25..7.15.0..1ef5])
::
::  set-tmsp back ~d0.h0.m0.s0
++  test-set-tmsp-24
  %+  expect-eq                         
    !>  ~2023.12.25..7.15.0..1ef5
    !>  (set-tmsp [`[%dr ~d0.h0.m0.s0] ~2023.12.25..7.15.0..1ef5])
::
::  insert rows to table
++  test-insert-db
  =|  run=@ud 
  =/  my-insert  "INSERT INTO db1..my-table-3 (col1, col2, col3)  ".
                "VALUES ('cord',~nomryg-nilref,20) ('Default',Default, 0)"
  =/  x  %-  process-cmds 
            :+  start-dbs
                (bowl [run ~2030.1.1])
                (parse:parse(default-database 'db1') my-insert)
  ;:  weld
  %+  expect-eq                         
    !>  :-  %results
            :~  [%result-da msg='data time' date=~2030.1.1]
                [%result-ud msg='row count' count=2]
            ==
    !>  -.x
  %+  expect-eq
    !>  gen3-dbs
    !>  +.x
  ==
::
::  insert rows without columns to populated table 
++  test-insert-no-cols
  =|  run=@ud 
  =/  my-insert
        "INSERT INTO db1..my-table-3 VALUES ('cord2',~nec,21) ('cord2',~bus, 1)"
  =/  x  %-  process-cmds
            :+  gen3-dbs
                (bowl [run ~2030.2.1])
                (parse:parse(default-database 'db1') my-insert)
  ;:  weld
  %+  expect-eq                         
    !>  :-  %results
            :~  [%result-da msg='data time' date=~2030.2.1]
                [%result-ud msg='row count' count=2]
            ==
    !>  -.x
  %+  expect-eq
    !>  gen4-dbs
    !>  +.x
  ==
::
:: INSERT
::
:: insert rows without columns to populated table fail on col wrong type
++  test-fail-ins-no-cols-col-type
  =|  run=@ud
  =/  my-insert
        "INSERT INTO db1..my-table-3 VALUES ('cord2',~nec,21) ('cord2',1, ~bus)"
  %-  expect-fail
  |.  %-  process-cmds
          :+  gen3-dbs
              (bowl [run ~2030.2.1])
              (parse:parse(default-database 'db1') my-insert)
::
:: fail on dup rows
++  test-fail-insert-dup-rows
  =|  run=@ud
  =/  my-insert  "INSERT INTO db1..my-table-3 (col1, col2, col3)  ".
                "VALUES ('cord',~nomryg-nilref,20) ('Default',Default, 0)"
  %-  expect-fail
  |.  %-  process-cmds
          :+  gen3-dbs
              (bowl [run ~2031.1.1])
              (parse:parse(default-database 'db1') my-insert)
::
:: fail on dup col names
++  test-fail-insert-dup-cols
  =|  run=@ud
  =/  my-insert  "INSERT INTO db1..my-table-3 (col1, col2, col2)  ".
                "VALUES ('cord',~nomryg-nilref,20) ('Default',Default, 0)"
  %-  expect-fail
  |.  %-  process-cmds
          :+  start-dbs
              (bowl [run ~2031.1.1])
              (parse:parse(default-database 'db1') my-insert)
::
:: fail on too few cols
++  test-fail-insert-few-cols
  =|  run=@ud
  =/  my-insert  "INSERT INTO db1..my-table-3 (col1, col2)  ".
                "VALUES ('cord',~nomryg-nilref) ('Default',Default)"
  %-  expect-fail
  |.  %-  process-cmds
          :+  start-dbs
              (bowl [run ~2031.1.1])
              (parse:parse(default-database 'db1') my-insert)
::
:: fail on too many cols
++  test-fail-insert-more-cols
  =|  run=@ud
  =/  my-insert  "INSERT INTO db1..my-table-3 (col1, col2, col3, col4)  ".
                "VALUES ('cord',~nomryg-nilref,20, 1) ('Default',Default, 0, 2)"
  %-  expect-fail
  |.  %-  process-cmds
          :+  start-dbs
              (bowl [run ~2031.1.1])
              (parse:parse(default-database 'db1') my-insert)
::
:: fail on col wrong type
++  test-fail-insert-col-type
  =|  run=@ud
  =/  my-insert  "INSERT INTO db1..my-table-3 (col1, col2, col3)  ".
                "VALUES (1,~nomryg-nilref,20) (2,Default, 0)"
  %-  expect-fail
  |.  %-  process-cmds
          :+  start-dbs
              (bowl [run ~2031.1.1])
              (parse:parse(default-database 'db1') my-insert)
::
:: fail on bad col name
++  test-fail-insert-col-name     
  =|  run=@ud
  =/  my-insert  "INSERT INTO db1..my-table-3 (col1a, col2, col3)  ".
                "VALUES ('cord',~nomryg-nilref,20) ('Default',Default, 0)"
  %-  expect-fail
  |.  %-  process-cmds
          :+  start-dbs
              (bowl [run ~2031.1.1])
              (parse:parse(default-database 'db1') my-insert)
::
:: fail on bad tbl name
++  test-fail-insert-tbl-name
  =|  run=@ud
  =/  my-insert  "INSERT INTO db1..my-table-2 (col1, col2, col3)  ".
                "VALUES ('cord',~nomryg-nilref,20) ('Default',Default, 0)"
  %-  expect-fail
  |.  %-  process-cmds
          :+  start-dbs
              (bowl [run ~2031.1.1])
              (parse:parse(default-database 'db1') my-insert)
::
:: fail on bad namespace name
++  test-fail-insert-ns-name
  =|  run=@ud
  =/  my-insert  "INSERT INTO db1.ns.my-table-3 (col1, col2, col3)  ".
                "VALUES ('cord',~nomryg-nilref,20) ('Default',Default, 0)"
  %-  expect-fail
  |.  %-  process-cmds 
          :+  start-dbs
              (bowl [run ~2031.1.1])
              (parse:parse(default-database 'db1') my-insert)
::
::  SELECT
::
::  select one literal 
++  test-select-1-literal
  =|  run=@ud 
  =/  my-select  "SELECT 0"
  =/  x  %-  process-cmds
            :+  start-dbs
                (bowl [run ~2023.2.1])
                (parse:parse(default-database 'db1') my-select)
  %+  expect-eq                         
    !>  :-  %results
            :~  :*  %result-set
                    qualifier=~.literals
                    columns=~[[%literal-0 %ud]]
                    data=[i=~[0] t=~]
                ==
            ==
    !>  -.x
::
::  select all literals mixed with aliases
++  test-select-literals
  =|  run=@ud 
  =/  rslt-cols  :~  [%date %da]
                    [%literal-1 %da]
                    [%literal-2 %da]
                    [%literal-3 %da]
                    [%literal-4 %da]
                    [%literal-5 %da]
                    [%timespan %dr]
                    [%literal-7 %dr]
                    [%literal-8 %dr]
                    [%literal-9 %dr]
                    [%literal-10 %dr]
                    [%loobean %f]
                    [%literal-12 %f]
                    [%ipv4-address %if]
                    [%ipv6-address %is]
                    [%ship %p]
                    [%single-float %rs]
                    [%literal-17 %rs]
                    [%double-float %rd]
                    [%literal-19 %rd]
                    [%signed-binary %sb]
                    [%literal-21 %sb]
                    [%signed-decimal %sd]
                    [%literal-23 %sd]
                    [%signed-base32 %sv]
                    [%literal-25 %sv]
                    [%signed-base64 %sw]
                    [%literal-27 %sw]
                    [%signed-hexadecimal %sx]
                    [%literal-29 %sx]
                    [%unsigned-binary %ub]
                    [%unsigned-decimal %ud]
                    [%literal-32 %ud]
                    [%unsigned-hexadecimal %ux]
                  ==
  =/  rslt-data  :~  :~  ~2020.12.25
                        ~2020.12.25..7.15.0
                        ~2020.12.25..7.15.0..1ef5
                        ~2020.12.25
                        ~2020.12.25..7.15.0
                        ~2020.12.25..7.15.0..1ef5
                        ~d71.h19.m26.s24..9d55
                        ~d71.h19.m26.s24
                        ~d71.h19.m26
                        ~d71.h19
                        ~d71
                        %.y
                        %.n
                        .195.198.143.90
                        .0.0.0.0.0.1c.c3c6.8f5a
                        ~sampel-palnet
                        .3.14
                        .-3.14
                        .~3.14
                        .~-3.14
                        --0b10.0000
                        -0b10.0000
                        --20
                        -20
                        --0v201.4gvml.245kc
                        -0v201.4gvml.245kc
                        --0w2.04AfS.G8xqc
                        -0w2.04AfS.G8xqc
                        --0x2004.90fd
                        -0x2004.90fd
                        0b10.1011
                        2.222
                        2.222
                        0x12.6401
                      ==
                ==
  =/  my-select  "SELECT ~2020.12.25 AS Date, ~2020.12.25..7.15.0, ".
  "~2020.12.25..7.15.0..1ef5, 2020.12.25, 2020.12.25..7.15.0, ".
  "2020.12.25..7.15.0..1ef5, ~d71.h19.m26.s24..9d55 AS Timespan, ".
  "~d71.h19.m26.s24, ~d71.h19.m26, ~d71.h19, ~d71, Y AS Loobean, N,  ".
  ".195.198.143.90 AS IPv4-address, .0.0.0.0.0.1c.c3c6.8f5a as IPv6-address, ".
  "~sampel-palnet AS Ship, .3.14 AS Single-float, .-3.14,  ".
  "~3.14 AS Double-float, ~-3.14, --0b10.0000 AS Signed-binary, -0b10.0000, ".
  "--20 AS Signed-decimal, -20, --0v201.4gvml.245kc AS Signed-base32, ".
  "-0v201.4gvml.245kc, --0w2.04AfS.G8xqc AS Signed-base64, -0w2.04AfS.G8xqc, ".
  "--0x2004.90fd AS Signed-hexadecimal, -0x2004.90fd,  ".
  "10.1011 AS Unsigned-binary, 2.222 AS Unsigned-decimal, 2222,  ".
  "0x12.6401 AS Unsigned-hexadecimal"
  =/  x  %-  process-cmds  :+  start-dbs 
                              (bowl [run ~2023.2.1])
                              (parse:parse(default-database 'db1') my-select)
  %+  expect-eq                         
    !>  [%results ~[[%result-set qualifier=~.literals rslt-cols rslt-data]]]
    !>  -.x
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
  =/  my-cmd
        "CREATE NAMESPACE ns1 as of ~2023.7.9..22.35.35..7e90"
  =/  x  %-  process-cmds
            :+  gen3-dbs
                (bowl [run ~2030.2.1])
                (parse:parse(default-database 'db1') my-cmd)
  ;:  weld
  %+  expect-eq                         
    !>  :-  %results
            :~  [%result-da msg='system time' date=~2023.7.9..22.35.35..7e90]
            ==
    !>  -.x
  %+  expect-eq
    !>  dbs-time-1
    !>  +.x
  ==
::
:: fail on time, create ns = schema
++  test-fail-time-create-ns-eq-schema
  =|  run=@ud
  =/  my-cmd  "CREATE NAMESPACE ns1 as of ~2023.7.9..22.35.34..7e90"
  %-  expect-fail
  |.  %-  process-cmds 
          :+  gen3-dbs
              (bowl [run ~2031.1.1])
              (parse:parse(default-database 'db1') my-cmd)
::
:: fail on time, create ns lt schema
++  test-fail-time-create-ns-lt-schema
  =|  run=@ud
  =/  my-cmd  "CREATE NAMESPACE ns1 as of ~2023.7.9..22.35.33..7e90"
  %-  expect-fail
  |.  %-  process-cmds 
          :+  gen3-dbs
              (bowl [run ~2031.1.1])
              (parse:parse(default-database 'db1') my-cmd)
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
