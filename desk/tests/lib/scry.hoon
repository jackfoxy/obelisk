::  Tests for %obelisk scries and subscriptions.
::
/-  ast=obelisk-ast, *server-state-1
/+  *test
/=  agent  /app/obelisk
|%
::
::  Build an example bowl manually
++  bowl
  |=  [run=@ud now=@da]
  ^-  bowl:gall
  (bowl-src run ~zod now)
::
::  Build a bowl with a foreign source ship
++  bowl-src
  |=  [run=@ud src=@p now=@da]
  ^-  bowl:gall
  :*  [~zod src %obelisk `path`(limo `path`/test-agent)]  :: (our src dap sap)
      [~ ~ ~]                                             :: (wex sup sky)
      [run `@uvJ`(shax run) now [~zod %base ud+run]]      :: (act eny now byk)
  ==
--
|%
::
++  setup
  ^-  tape
  %-  zing
  :~  "CREATE DATABASE db1;"
      "CREATE TABLE db1..my-table (col1 @t, col2 @ud) PRIMARY KEY (col1);"
      "INSERT INTO db1..my-table (col1, col2) VALUES ('alpha', 1) ('beta', 2)"
  ==
::
++  insert-3  "INSERT INTO db1..my-table (col1, col2) VALUES ('gamma', 3)"
::
++  row-alpha
  ^-  data-row:ast
  :+  %indexed-row  ~['alpha']
  (~(gas by *(map @tas @)) ~[[%col1 'alpha'] [%col2 1]])
::
++  row-beta
  ^-  data-row:ast
  :+  %indexed-row  ~['beta']
  (~(gas by *(map @tas @)) ~[[%col1 'beta'] [%col2 2]])
::
++  row-gamma
  ^-  data-row:ast
  :+  %indexed-row  ~['gamma']
  (~(gas by *(map @tas @)) ~[[%col1 'gamma'] [%col2 3]])
::
++  rows-2  ^-  (list data-row:ast)  ~[row-alpha row-beta]
++  rows-3  ^-  (list data-row:ast)  ~[row-alpha row-beta row-gamma]
::
++  exec
  ::  poke urQL into an agent, producing the updated agent
  |=  [ag=_agent run=@ud tmsp=@da db=@tas uql=tape]
  ^+  agent
  =^  mov  ag
    (~(on-poke ag (bowl run tmsp)) %obelisk-action !>([%tape db uql]))
  ag
::
++  scry-noun
  ::  unwrap the raw noun of a successful scry
  |=  res=(unit (unit cage))
  ^-  *
  ?~  res  ~|("scry blocked" !!)
  ?~  u.res  ~|("scry failed" !!)
  q.q.u.u.res
::
++  scry-relation
  ::  unwrap a relation-level scry result
  |=  res=(unit (unit cage))
  ^-  relation:ast
  ;;(relation:ast (scry-noun res))
::
++  row-data
  ::  the data map of a single-table row
  |=  row=data-row:ast
  ^-  (map @tas @)
  ?>  ?=(%indexed-row -.row)
  data.row
::
++  project
  ::  restrict a row's data map to the given columns;
  ::  relation data-rows retain all columns regardless of selection
  |=  [row=data-row:ast cols=(list @tas)]
  ^-  (map @tas @)
  =/  data  (row-data row)
  %-  ~(gas by *(map @tas @))
  (turn cols |=(col=@tas [col (~(got by data) col)]))
::
::  scry a table: FROM db1.dbo.my-table SELECT *
++  test-scry-relation-00
  =|  run=@ud
  =/  ag  (exec agent run ~2012.4.30 %db1 setup)
  =/  rel
    %-  scry-relation
    (~(on-peek ag (bowl run ~2012.5.1)) /x/obelisk/db1/dbo/my-table)
  %+  expect-eq
    !>  (sy rows-2)
  !>  (sy data-rows.rel)
::
::  scry selected columns: FROM db1.dbo.my-table SELECT col2
++  test-scry-columns-01
  =|  run=@ud
  =/  ag  (exec agent run ~2012.4.30 %db1 setup)
  =/  rel
    %-  scry-relation
    (~(on-peek ag (bowl run ~2012.5.1)) /x/obelisk/db1/dbo/my-table/col2)
  %+  expect-eq
    !>  %-  sy
        ^-  (list (map @tas @))
        :~  (~(gas by *(map @tas @)) ~[[%col2 1]])
            (~(gas by *(map @tas @)) ~[[%col2 2]])
        ==
  !>  (sy (turn data-rows.rel |=(r=data-row:ast (project r ~[%col2]))))
::
::  scry a namespace: name -> relation
++  test-scry-namespace-02
  =|  run=@ud
  =/  ag  (exec agent run ~2012.4.30 %db1 setup)
  =/  res  (~(on-peek ag (bowl run ~2012.5.1)) /x/obelisk/db1/dbo)
  =/  rels  ;;((map @tas relation:ast) (scry-noun res))
  ;:  weld
    %+  expect-eq
      !>  (sy `(list @tas)`~[%my-table])
    !>  ~(key by rels)
  ::
    %+  expect-eq
      !>  (sy rows-2)
    !>  (sy data-rows:(~(got by rels) %my-table))
  ==
::
::  '..' is the %dbo namespace
++  test-scry-dbo-shorthand-03
  =|  run=@ud
  =/  ag  (exec agent run ~2012.4.30 %db1 setup)
  =/  named  (~(on-peek ag (bowl run ~2012.5.1)) /x/obelisk/db1/dbo)
  =/  dotted  (~(on-peek ag (bowl run ~2012.5.1)) /x/obelisk/db1/'..')
  %-  expect
  !>  =((scry-noun named) (scry-noun dotted))
::
::  scry a database: namespace -> name -> relation, sys views included
++  test-scry-database-04
  =|  run=@ud
  =/  ag  (exec agent run ~2012.4.30 %db1 setup)
  =/  res  (~(on-peek ag (bowl run ~2012.5.1)) /x/obelisk/db1)
  =/  rels  ;;((map @tas (map @tas relation:ast)) (scry-noun res))
  ;:  weld
    %+  expect-eq
      !>  (sy `(list @tas)`~[%dbo %sys])
    !>  ~(key by rels)
  ::
    %+  expect-eq
      !>  (sy `(list @tas)`~[%my-table])
    !>  ~(key by (~(got by rels) %dbo))
  ::
    %+  expect-eq
      !>  %-  sy
          ^-  (list @tas)
          :~  %columns  %data-log  %foreign-keys  %namespaces
              %sys-log  %table-keys  %tables
          ==
    !>  ~(key by (~(got by rels) %sys))
  ::
    %+  expect-eq
      !>  (sy rows-2)
    !>  (sy data-rows:(~(got by (~(got by rels) %dbo)) %my-table))
  ==
::
::  scry a sys view with selected columns:
::  FROM db1.sys.tables SELECT namespace, name, row-count
++  test-scry-sys-view-05
  =|  run=@ud
  =/  ag  (exec agent run ~2012.4.30 %db1 setup)
  =/  rel
    %-  scry-relation
    %-  ~(on-peek ag (bowl run ~2012.5.1))
    /x/obelisk/db1/sys/tables/namespace/name/row-count
  =/  cols=(list @tas)  ~[%namespace %name %row-count]
  %+  expect-eq
    !>  %-  sy
        ^-  (list (map @tas @))
        :~  %-  ~(gas by *(map @tas @))
            ~[[%namespace %dbo] [%name %my-table] [%row-count 2]]
        ==
  !>  (sy (turn data-rows.rel |=(r=data-row:ast (project r cols))))
::
::  scry the sys.sys.databases sys view
++  test-scry-sys-databases-06
  =|  run=@ud
  =/  ag  (exec agent run ~2012.4.30 %db1 setup)
  =/  rel
    %-  scry-relation
    %-  ~(on-peek ag (bowl run ~2012.5.1))
    /x/obelisk/sys/sys/databases/database
  =/  dbs=(list (map @tas @))
    (turn data-rows.rel |=(r=data-row:ast (project r ~[%database])))
  %-  expect
  !>  (~(has in (sy dbs)) (~(gas by *(map @tas @)) ~[[%database %db1]]))
::
::  AS OF @da reads the past; no AS OF reads now
++  test-scry-as-of-07
  =|  run=@ud
  =/  ag  (exec agent run ~2012.4.30 %db1 setup)
  =.  ag  (exec ag run ~2012.5.2 %db1 insert-3)
  =/  past
    %-  scry-relation
    %-  ~(on-peek ag (bowl run ~2012.5.5))
    /x/obelisk/(scot %da ~2012.5.1)/db1/dbo/my-table
  =/  current
    %-  scry-relation
    (~(on-peek ag (bowl run ~2012.5.5)) /x/obelisk/db1/dbo/my-table)
  ;:  weld
    %+  expect-eq
      !>  (sy rows-2)
    !>  (sy data-rows.past)
  ::
    %+  expect-eq
      !>  (sy rows-3)
    !>  (sy data-rows.current)
  ==
::
::  AS OF @dr reads a timespan back from now: ~2012.5.10 - ~d9 = ~2012.5.1
++  test-scry-as-of-dr-08
  =|  run=@ud
  =/  ag  (exec agent run ~2012.4.30 %db1 setup)
  =.  ag  (exec ag run ~2012.5.2 %db1 insert-3)
  =/  past
    %-  scry-relation
    %-  ~(on-peek ag (bowl run ~2012.5.10))
    /x/obelisk/(scot %dr ~d9)/db1/dbo/my-table
  %+  expect-eq
    !>  (sy rows-2)
  !>  (sy data-rows.past)
::
::  malformed and unknown paths produce [~ ~]
++  test-scry-bad-path-09
  =|  run=@ud
  =/  ag  (exec agent run ~2012.4.30 %db1 setup)
  =/  peek  ~(on-peek ag (bowl run ~2012.5.1))
  ;:  weld
    (expect !>(=([~ ~] (peek /x/obelisk/no-such-db))))
    (expect !>(=([~ ~] (peek /x/obelisk/db1/dbo/no-such-table))))
    (expect !>(=([~ ~] (peek /x/obelisk/db1/no-such-ns/my-table))))
    (expect !>(=([~ ~] (peek /x/obelisk))))
  ==
::
::  subscription gives the relation as a fact, then kicks
++  test-watch-relation-10
  =|  run=@ud
  =/  ag  (exec agent run ~2012.4.30 %db1 setup)
  =^  mov  ag
    (~(on-watch ag (bowl run ~2012.5.1)) /obelisk/db1/dbo/my-table)
  ?>  ?=([* * ~] mov)
  ?>  ?=([%give %fact ~ %noun *] i.mov)
  =/  rel  ;;(relation:ast q.q.cage.p.i.mov)
  ;:  weld
    %+  expect-eq
      !>  (sy rows-2)
    !>  (sy data-rows.rel)
  ::
    (expect !>(=([%give %kick ~ ~] i.t.mov)))
  ==
::
::  foreign ships fail /lib/main security and are nacked
++  test-fail-watch-foreign-11
  =|  run=@ud
  =/  ag  (exec agent run ~2012.4.30 %db1 setup)
  %-  expect-fail
  |.  %-  ~(on-watch ag (bowl-src run ~nec ~2012.5.1))
      /obelisk/db1/dbo/my-table
::
::  invalid subscription paths are nacked
++  test-fail-watch-bad-path-12
  =|  run=@ud
  =/  ag  (exec agent run ~2012.4.30 %db1 setup)
  %-  expect-fail
  |.  (~(on-watch ag (bowl run ~2012.5.1)) /obelisk/no-such-db)
--
