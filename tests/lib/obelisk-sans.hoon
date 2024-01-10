::  unit tests on %obelisk library simulating pokes
::
/-  ast, *obelisk
/+  *test, *obelisk, parse
|%
::  Build an example bowl manually.
::
++  bowl
  |=  [run=@ud now=@da]
  ^-  bowl:gall
  :*  [~zod ~zod %obelisk `path`(limo `path`/test-agent)] :: (our src dap sap)
      [~ ~ ~]                                          :: (wex sup sky)
      [run `@uvJ`(shax run) now [~zod %base ud+run]]   :: (act eny now byk)
  ==
::  Build a reference state mold.
::
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
        files=[n=file-my-table-2 l=[n=gen4-file-my-table-3 l=~ r=~] r=[file-my-table ~ ~]]
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
:: fail on time, create ns lt schema
++  test-fail-time-create-ns-lt-schema
  =|  run=@ud
  =/  my-cmd  "CREATE NAMESPACE ns1 as of ~2023.7.9..22.35.33..7e90"
  %-  expect-fail
  |.  %-  process-cmds 
          :+  gen3-dbs
              (bowl [run ~2031.1.1])
              (parse:parse(default-database 'db1') my-cmd)

--
