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
::
++  schema-ns
  [n=[p=%dbo q=~2023.7.9..22.24.54..4b8a] l=~ r=[n=[p=%sys q=~2023.7.9..22.24.54..4b8a] l=~ r=~]]
++  schema-my-table
  [p=[%dbo %my-table] q=[%table provenance=`path`/test-agent tmsp=~2023.7.9..22.24.54..4b8a pri-indx=[%index unique=%.y clustered=%.y columns=~[[%ordered-column name=%col1 ascending=%.y]]] columns=~[[%column name=%col1 type=%t]] indices=~]]
++  schema-table-3
  [p=[%dbo %my-table-3] q=[%table provenance=`path`/test-agent tmsp=~2023.7.9..22.24.54..4b8a pri-indx=pri-indx-table-3 columns=~[[%column name=%col1 type=%t] [%column name=%col2 type=%p] [%column name=%col3 type=%ud]] indices=~]]
++  pri-indx-table-3
  [%index unique=%.y clustered=%.y columns=~[[%ordered-column name=%col1 ascending=%.y] [%ordered-column name=%col3 ascending=%.n]]]
::
++  file-my-table
  [p=[%dbo %my-table] q=[%file ship=~zod provenance=`path`/test-agent tmsp=~2023.7.9..22.27.32..49e3 clustered=%.y length=0 column-lookup=[n=[p=%col1 q=[%t 0]] l=~ r=~] key=~[[%t %.y]] pri-idx=~ data=~]]
++  file-my-table-3
  [p=[%dbo %my-table-3] q=[%file ship=~zod provenance=`path`/test-agent tmsp=~2023.7.9..22.35.34..7e90 clustered=%.y length=0 column-lookup=col-lu-table-3 key=~[[%t %.y] [%ud %.n]] pri-idx=~ data=~]]
++  col-lu-table-3
  [n=[p=%col3 q=[%ud 2]] l=[n=[p=%col2 q=[%p 1]] l=~ r=~] r=[n=[p=%col1 q=[%t 0]] l=~ r=~]]
::
++  gen0-intrnl
  :-  ~2023.7.9..22.24.54..4b8a
    :*  %schema
        provenance=`path`/test-agent
        tmsp=~2023.7.9..22.24.54..4b8a
        namespaces=schema-ns
        tables=~
    ==
++  gen1-intrnl
  :-  ~2023.7.9..22.27.32..49e3
    :*  %schema
        provenance=`path`/test-agent
        tmsp=~2023.7.9..22.27.32..49e3
        namespaces=schema-ns
        tables=[n=schema-my-table l=~ r=~]
    ==
++  gen2-intrnl
  :-  ~2023.7.9..22.35.34..7e90
    :*  %schema
        provenance=`path`/test-agent
        tmsp=~2023.7.9..22.35.34..7e90
        namespaces=schema-ns
        tables=[n=schema-my-table l=[n=schema-table-3 l=~ r=~] r=~]
    ==
::
++  gen0-data
  [%data ship=~zod provenance=`path`/test-agent tmsp=~2023.7.9..22.24.54..4b8a files=~]
++  gen1-data
  [%data ship=~zod provenance=`path`/test-agent tmsp=~2023.7.9..22.27.32..49e3 files=[n=file-my-table l=~ r=~]]
++  gen2-data
  [%data ship=~zod provenance=`path`/test-agent tmsp=~2023.7.9..22.35.34..7e90 files=[n=file-my-table l=[n=file-my-table-3 l=~ r=~] r=~]]
::
++  start-db1-row
  :*  %database
      name=%db1
      created-provenance=`path`/test-agent
      created-tmsp=~2023.7.9..22.24.54..4b8a
      sys=(gas:schema-key *((mop @da schema) gth) ~[gen2-intrnl gen1-intrnl gen0-intrnl])
      content=~[gen2-data gen1-data gen0-data]
      ==
::
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
++  gen3-data
  :*  %data
      ship=~zod
      provenance=`path`/test-agent
      tmsp=~2030.1.1
      files=[n=file-my-table l=[n=gen3-file-my-table-3 l=~ r=~] r=~]
  ==
::
++  schema-key  ((on @da schema) gth)
++  gen3-db1-row
  :*  %database
      name=%db1
      created-by-provenance=`path`/test-agent
      created-tmsp=~2023.7.9..22.24.54..4b8a
      sys=(gas:schema-key *((mop @da schema) gth) ~[gen2-intrnl gen1-intrnl gen0-intrnl])
      content=~[gen3-data gen2-data gen1-data gen0-data]
  ==
++  gen3-dbs
  [n=[p=%db1 q=gen3-db1-row] l=~ r=~]
::
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
++  gen4-data
  :*  %data
      ship=~zod
      provenance=`path`/test-agent
      tmsp=~2030.2.1
      files=[n=file-my-table l=[n=gen4-file-my-table-3 l=~ r=~] r=~]
  ==
++  gen4-db1-row
  :*  %database
      name=%db1
      created-by-provenance=`path`/test-agent
      created-tmsp=~2023.7.9..22.24.54..4b8a
      sys=(gas:schema-key *((mop @da schema) gth) ~[gen2-intrnl gen1-intrnl gen0-intrnl])
      content=~[gen4-data gen3-data gen2-data gen1-data gen0-data]
  ==
++  gen4-dbs
  [n=[p=%db1 q=gen4-db1-row] l=~ r=~]

++  start-dbs
[n=[p=%db1 q=start-db1-row] l=~ r=~]
::
::

::
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

--
