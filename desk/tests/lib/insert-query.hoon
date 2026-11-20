::  INSERT and UPSERT from a query source.
::
/-  ast=obelisk-ast
/+  *test-helpers
|%
::
++  setup
  ^-  tape
  %-  zing
  :~  "CREATE DATABASE db1;"
      "CREATE TABLE src (id @ud, name @t, score @sd) PRIMARY KEY (id);"
      "CREATE TABLE src2 (id @ud, name @t) PRIMARY KEY (id);"
      "CREATE TABLE tgt (id @ud, name @t) PRIMARY KEY (id);"
      "INSERT INTO src VALUES (1, 'one', -1) (2, 'two', --2) (3, 'three', --3);"
      "INSERT INTO src2 VALUES (3, 'three') (4, 'four');"
      ==
::
++  iq-init  `[@da @tas tape]`[~2012.4.30 %db1 setup]
::
++  tgt-row
  |=  [id=@ud name=@t]
  ^-  vector:ast
  [%vector ~[[%id [~.ud id]] [%name [~.t name]]]]
::
::  result of an INSERT or UPSERT into tgt at ~2012.5.1
++  inserted
  |=  [message=@t count=@ud total=@ud]
  ^-  cmd-result:ast
  =/  action=@t
    ?:  =('inserted:' message)
      'INSERT INTO db1.dbo.tgt'
    'UPSERT INTO db1.dbo.tgt'
  :-  %results
      :~  [%action action]
          [%server-time ~2012.5.1]
          [%schema-time ~2012.4.30]
          [%data-time ~2012.4.30]
          [%message message]
          [%vector-count count]
          [%message 'table data:']
          [%vector-count total]
          ==
::
::  result of FROM tgt SELECT * at ~2012.5.2
++  tgt-rows
  |=  [data-time=@da rows=(list vector:ast)]
  ^-  cmd-result:ast
  :-  %results
      :~  [%action 'SELECT']
          [%result-set rows]
          [%server-time ~2012.5.2]
          [%relation-name 'db1.dbo.tgt']
          [%schema-time ~2012.4.30]
          [%data-time data-time]
          [%vector-count (lent rows)]
          ==
::
++  select-tgt  `[@da @tas tape]`[~2012.5.2 %db1 "FROM tgt SELECT *"]
::
::  insert the rows of a query
++  test-insert-query-00
  =|  run=@ud
  %-  exec-0-2
  :*  run
      iq-init
      [~2012.5.1 %db1 "INSERT INTO tgt FROM src SELECT id, name"]
      select-tgt
      (inserted 'inserted:' 3 3)
      %+  tgt-rows  ~2012.5.1
      ~[(tgt-row 1 'one') (tgt-row 2 'two') (tgt-row 3 'three')]
      ==
::
::  a column list maps query columns to target columns by position
++  test-insert-query-01
  =|  run=@ud
  %-  exec-0-2
  :*  run
      iq-init
      [~2012.5.1 %db1 "INSERT INTO tgt (name, id) FROM src SELECT name, id"]
      select-tgt
      (inserted 'inserted:' 3 3)
      %+  tgt-rows  ~2012.5.1
      ~[(tgt-row 1 'one') (tgt-row 2 'two') (tgt-row 3 'three')]
      ==
::
::  WHERE filters the query rows
++  test-insert-query-02
  =|  run=@ud
  %-  exec-0-2
  :*  run
      iq-init
      [~2012.5.1 %db1 "INSERT INTO tgt FROM src WHERE id > 1 SELECT id, name"]
      select-tgt
      (inserted 'inserted:' 2 2)
      %+  tgt-rows  ~2012.5.1
      ~[(tgt-row 2 'two') (tgt-row 3 'three')]
      ==
::
::  SELECT without FROM
++  test-insert-query-03
  =|  run=@ud
  %-  exec-0-2
  :*  run
      iq-init
      [~2012.5.1 %db1 "INSERT INTO tgt SELECT 9, 'nine'"]
      select-tgt
      (inserted 'inserted:' 1 1)
      (tgt-rows ~2012.5.1 ~[(tgt-row 9 'nine')])
      ==
::
::  set query source; a row in both operands is one row
++  test-insert-query-04
  =|  run=@ud
  %-  exec-0-2
  :*  run
      iq-init
      :+  ~2012.5.1
          %db1
          "INSERT INTO tgt FROM src SELECT id, name ".
          "UNION FROM src2 SELECT id, name"
      select-tgt
      (inserted 'inserted:' 4 4)
      %+  tgt-rows  ~2012.5.1
      :~  (tgt-row 1 'one')
          (tgt-row 2 'two')
          (tgt-row 3 'three')
          (tgt-row 4 'four')
          ==
      ==
::
::  CTE source
++  test-insert-query-05
  =|  run=@ud
  %-  exec-0-2
  :*  run
      iq-init
      :+  ~2012.5.1
          %db1
          "WITH (FROM src WHERE id < 3 SELECT id, name) AS c1 ".
          "INSERT INTO tgt FROM c1 SELECT id, name"
      select-tgt
      (inserted 'inserted:' 2 2)
      %+  tgt-rows  ~2012.5.1
      ~[(tgt-row 1 'one') (tgt-row 2 'two')]
      ==
::
::  TOP keeps the top rows by ORDER BY
++  test-insert-query-06
  =|  run=@ud
  %-  exec-0-2
  :*  run
      iq-init
      :+  ~2012.5.1
          %db1
          "INSERT INTO tgt FROM src SELECT TOP 2 id, name ORDER BY id DESC"
      select-tgt
      (inserted 'inserted:' 2 2)
      %+  tgt-rows  ~2012.5.1
      ~[(tgt-row 2 'two') (tgt-row 3 'three')]
      ==
::
::  ORDER BY without TOP is ignored
++  test-insert-query-07
  =|  run=@ud
  %-  exec-0-2
  :*  run
      iq-init
      :+  ~2012.5.1
          %db1
          "INSERT INTO tgt FROM src SELECT id, name ORDER BY score"
      select-tgt
      (inserted 'inserted:' 3 3)
      %+  tgt-rows  ~2012.5.1
      ~[(tgt-row 1 'one') (tgt-row 2 'two') (tgt-row 3 'three')]
      ==
::
::  an empty query source changes nothing, not even the data time
++  test-insert-query-08
  =|  run=@ud
  %-  exec-0-2
  :*  run
      iq-init
      [~2012.5.1 %db1 "INSERT INTO tgt FROM src WHERE id > 9 SELECT id, name"]
      select-tgt
      (inserted 'inserted:' 0 0)
      (tgt-rows ~2012.4.30 ~)
      ==
::
::  UPSERT overwrites rows of existing keys
++  test-upsert-query-00
  =|  run=@ud
  %-  exec-0-2
  :*  run
      [~2012.4.30 %db1 (weld setup "INSERT INTO tgt VALUES (1, 'old');")]
      [~2012.5.1 %db1 "UPSERT INTO tgt FROM src WHERE id < 3 SELECT id, name"]
      select-tgt
      (inserted 'upserted:' 2 2)
      %+  tgt-rows  ~2012.5.1
      ~[(tgt-row 1 'one') (tgt-row 2 'two')]
      ==
::
::  query aura must match the target column aura
++  test-fail-insert-query-00
  =|  run=@ud
  %-  failon-1
  :*  run
      iq-init
      [~2012.5.1 %db1 "INSERT INTO tgt FROM src SELECT id, score"]
      'does not match input value type'
      ==
::
::  a query row with too few columns
++  test-fail-insert-query-01
  =|  run=@ud
  %-  failon-1
  :*  run
      iq-init
      [~2012.5.1 %db1 "INSERT INTO tgt FROM src SELECT id"]
      'INSERT: query row lacks column %name'
      ==
::
::  a query row with too many columns
++  test-fail-insert-query-02
  =|  run=@ud
  %-  failon-1
  :*  run
      iq-init
      [~2012.5.1 %db1 "INSERT INTO tgt FROM src SELECT id, name, score"]
      'INSERT: query row has 3 columns, target has 2'
      ==
::
::  UPSERT of query rows sharing a key is not deterministic
++  test-fail-insert-query-03
  =|  run=@ud
  %-  failon-1
  :*  run
      iq-init
      [~2012.5.1 %db1 "UPSERT INTO tgt FROM src SELECT 1, name"]
      'UPSERT: query rows have duplicate key: ~[1]'
      ==
::
::  INSERT of query rows sharing a key
++  test-fail-insert-query-04
  =|  run=@ud
  %-  failon-1
  :*  run
      iq-init
      [~2012.5.1 %db1 "INSERT INTO tgt FROM src SELECT 1, name"]
      'INSERT: query rows have duplicate key: ~[1]'
      ==
::
::  rows of an outer join that lack a target column
++  test-fail-insert-query-05
  =|  run=@ud
  %-  failon-1
  :*  run
      iq-init
      :+  ~2012.5.1
          %db1
          "INSERT INTO tgt FROM src T1 LEFT JOIN src2 T2 SELECT T1.id, T2.name"
      'INSERT: query row lacks column %name'
      ==
::
::  the source is read before the insert, so its own keys are duplicates
++  test-fail-insert-query-06
  =|  run=@ud
  %-  failon-1
  :*  run
      iq-init
      [~2012.5.1 %db1 "INSERT INTO src2 FROM src2 SELECT id, name"]
      'INSERT: cannot add duplicate key'
      ==
--
