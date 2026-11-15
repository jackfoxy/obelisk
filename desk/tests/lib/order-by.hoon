::  Unit testing ORDER BY and TOP execution on a Gall agent with %obelisk.
::
/-  ast=obelisk-ast
/+  *test-helpers
|%
::
++  create-tbl
  "CREATE TABLE tbl (id @ud, name @t, score @sd, ratio @rd, grp @ud) ".
  "PRIMARY KEY (id);"
++  create-tbl2
  "CREATE TABLE tbl2 (id @ud, label @t) PRIMARY KEY (id);"
::
::  name: lower case sorts before upper case among equal letters
::  score, ratio: negative values sort before positive ones by aura
++  insert-tbl
  "INSERT INTO tbl VALUES ".
  "(1, 'beta', -5, .~1.5, 1) ".
  "(2, 'Alpha', --3, .~-2.5, 1) ".
  "(3, 'alpha', -10, .~0.5, 2) ".
  "(4, 'gamma', --3, .~10, 2);"
++  insert-tbl2
  "INSERT INTO tbl2 VALUES (1, 'one') (2, 'two') (3, 'three');"
::
++  setup
  %-  zing
  :~  "CREATE DATABASE db1;"
      create-tbl
      create-tbl2
      insert-tbl
      insert-tbl2
      ==
::
++  id-name
  |=  [id=@ud name=@t]
  ^-  vector:ast
  [%vector ~[[%id [~.ud id]] [%name [~.t name]]]]
::
++  id-label
  |=  [id=@ud label=@t]
  ^-  vector:ast
  [%vector ~[[%id [~.ud id]] [%label [~.t label]]]]
::
++  id-only
  |=  id=@ud
  ^-  vector:ast
  [%vector ~[[%id [~.ud id]]]]
::
++  tbl-result
  |=  vectors=(list vector:ast)
  ^-  cmd-result:ast
  :-  %results
      :~  [%action 'SELECT']
          [%result-set vectors]
          [%server-time ~2012.5.3]
          [%relation-name 'db1.dbo.tbl']
          [%schema-time ~2012.4.30]
          [%data-time ~2012.4.30]
          [%vector-count (lent vectors)]
          ==
::
++  tbl-tbl2-result
  |=  vectors=(list vector:ast)
  ^-  cmd-result:ast
  :-  %results
      :~  [%action 'SELECT']
          [%result-set vectors]
          [%server-time ~2012.5.3]
          [%relation-name 'db1.dbo.tbl']
          [%schema-time ~2012.4.30]
          [%data-time ~2012.4.30]
          [%relation-name 'db1.dbo.tbl2']
          [%schema-time ~2012.4.30]
          [%data-time ~2012.4.30]
          [%vector-count (lent vectors)]
          ==
::
::  @t ascending: case insensitive, then lower case first
++  test-order-by-00
  =|  run=@ud
  %-  exec-0-1-ordered
  :*  run
      [~2012.4.30 %db1 setup]
      [~2012.5.3 %db1 "FROM tbl SELECT id, name ORDER BY name"]
      %-  tbl-result
      :~  (id-name 3 'alpha')
          (id-name 2 'Alpha')
          (id-name 1 'beta')
          (id-name 4 'gamma')
          ==
      ==
::
::  @sd descending, ties broken by a second column
++  test-order-by-01
  =|  run=@ud
  %-  exec-0-1-ordered
  :*  run
      [~2012.4.30 %db1 setup]
      :+  ~2012.5.3
          %db1
          "FROM tbl SELECT id, score ORDER BY score DESC, id"
      %-  tbl-result
      :~  [%vector ~[[%id [~.ud 2]] [%score [~.sd --3]]]]
          [%vector ~[[%id [~.ud 4]] [%score [~.sd --3]]]]
          [%vector ~[[%id [~.ud 1]] [%score [~.sd -5]]]]
          [%vector ~[[%id [~.ud 3]] [%score [~.sd -10]]]]
          ==
      ==
::
::  @rd ascending, by a column not selected
++  test-order-by-02
  =|  run=@ud
  %-  exec-0-1-ordered
  :*  run
      [~2012.4.30 %db1 setup]
      [~2012.5.3 %db1 "FROM tbl SELECT id ORDER BY ratio"]
      (tbl-result ~[(id-only 2) (id-only 3) (id-only 1) (id-only 4)])
      ==
::
::  column ordinal, descending
++  test-order-by-03
  =|  run=@ud
  %-  exec-0-1-ordered
  :*  run
      [~2012.4.30 %db1 setup]
      [~2012.5.3 %db1 "FROM tbl SELECT name, id ORDER BY 2 DESC"]
      %-  tbl-result
      :~  [%vector ~[[%name [~.t 'gamma']] [%id [~.ud 4]]]]
          [%vector ~[[%name [~.t 'alpha']] [%id [~.ud 3]]]]
          [%vector ~[[%name [~.t 'Alpha']] [%id [~.ud 2]]]]
          [%vector ~[[%name [~.t 'beta']] [%id [~.ud 1]]]]
          ==
      ==
::
::  column ordinals over *
++  test-order-by-04
  =|  run=@ud
  %-  exec-0-1-ordered
  :*  run
      [~2012.4.30 %db1 setup]
      [~2012.5.3 %db1 "FROM tbl SELECT * ORDER BY 3, 1"]
      %-  tbl-result
      :~  :-  %vector
              :~  [%id [~.ud 3]]
                  [%name [~.t 'alpha']]
                  [%score [~.sd -10]]
                  [%ratio [~.rd .~0.5]]
                  [%grp [~.ud 2]]
                  ==
          :-  %vector
              :~  [%id [~.ud 1]]
                  [%name [~.t 'beta']]
                  [%score [~.sd -5]]
                  [%ratio [~.rd .~1.5]]
                  [%grp [~.ud 1]]
                  ==
          :-  %vector
              :~  [%id [~.ud 2]]
                  [%name [~.t 'Alpha']]
                  [%score [~.sd --3]]
                  [%ratio [~.rd .~-2.5]]
                  [%grp [~.ud 1]]
                  ==
          :-  %vector
              :~  [%id [~.ud 4]]
                  [%name [~.t 'gamma']]
                  [%score [~.sd --3]]
                  [%ratio [~.rd .~10]]
                  [%grp [~.ud 2]]
                  ==
          ==
      ==
::
::  SELECT alias
++  test-order-by-05
  =|  run=@ud
  %-  exec-0-1-ordered
  :*  run
      [~2012.4.30 %db1 setup]
      :+  ~2012.5.3
          %db1
          "FROM tbl SELECT id AS ident, name ORDER BY ident DESC"
      %-  tbl-result
      :~  [%vector ~[[%ident [~.ud 4]] [%name [~.t 'gamma']]]]
          [%vector ~[[%ident [~.ud 3]] [%name [~.t 'alpha']]]]
          [%vector ~[[%ident [~.ud 2]] [%name [~.t 'Alpha']]]]
          [%vector ~[[%ident [~.ud 1]] [%name [~.t 'beta']]]]
          ==
      ==
::
::  aliased inline scalar
++  test-order-by-06
  =|  run=@ud
  %-  exec-0-1-ordered
  :*  run
      [~2012.4.30 %db1 setup]
      :+  ~2012.5.3
          %db1
          "FROM tbl SELECT id, ABS(score) AS mag ORDER BY mag DESC, id"
      %-  tbl-result
      :~  [%vector ~[[%id [~.ud 3]] [%mag [~.sd --10]]]]
          [%vector ~[[%id [~.ud 1]] [%mag [~.sd --5]]]]
          [%vector ~[[%id [~.ud 2]] [%mag [~.sd --3]]]]
          [%vector ~[[%id [~.ud 4]] [%mag [~.sd --3]]]]
          ==
      ==
::
::  TOP
++  test-order-by-07
  =|  run=@ud
  %-  exec-0-1-ordered
  :*  run
      [~2012.4.30 %db1 setup]
      :+  ~2012.5.3
          %db1
          "FROM tbl SELECT TOP 2 id, name ORDER BY name DESC"
      (tbl-result ~[(id-name 4 'gamma') (id-name 1 'beta')])
      ==
::
::  TOP greater than the row count
++  test-order-by-08
  =|  run=@ud
  %-  exec-0-1-ordered
  :*  run
      [~2012.4.30 %db1 setup]
      [~2012.5.3 %db1 "FROM tbl SELECT TOP 9 id ORDER BY id DESC"]
      (tbl-result ~[(id-only 4) (id-only 3) (id-only 2) (id-only 1)])
      ==
::
::  an order not total warns
++  test-order-by-09
  =|  run=@ud
  %-  exec-0-1
  :*  run
      [~2012.4.30 %db1 setup]
      [~2012.5.3 %db1 "FROM tbl SELECT id, grp ORDER BY grp"]
      :-  %results
          :~  [%message 'warning: result set order is non-deterministic']
              [%action 'SELECT']
              :-  %result-set
                  :~  [%vector ~[[%id [~.ud 1]] [%grp [~.ud 1]]]]
                      [%vector ~[[%id [~.ud 2]] [%grp [~.ud 1]]]]
                      [%vector ~[[%id [~.ud 3]] [%grp [~.ud 2]]]]
                      [%vector ~[[%id [~.ud 4]] [%grp [~.ud 2]]]]
                      ==
              [%server-time ~2012.5.3]
              [%relation-name 'db1.dbo.tbl']
              [%schema-time ~2012.4.30]
              [%data-time ~2012.4.30]
              [%vector-count 4]
              ==
      ==
::
::  rows shown alike are one row, so an order over them is total
++  test-order-by-10
  =|  run=@ud
  %-  exec-0-1-ordered
  :*  run
      [~2012.4.30 %db1 setup]
      [~2012.5.3 %db1 "FROM tbl SELECT grp ORDER BY grp DESC"]
      %-  tbl-result
      :~  [%vector ~[[%grp [~.ud 2]]]]
          [%vector ~[[%grp [~.ud 1]]]]
          ==
      ==
::
::  join, qualified column descending
++  test-order-by-11
  =|  run=@ud
  %-  exec-0-1-ordered
  :*  run
      [~2012.4.30 %db1 setup]
      :+  ~2012.5.3
          %db1
          "FROM tbl T1 JOIN tbl2 T2 SELECT T1.id, T2.label ".
          "ORDER BY T2.label DESC"
      %-  tbl-tbl2-result
      :~  (id-label 2 'two')
          (id-label 3 'three')
          (id-label 1 'one')
          ==
      ==
::
::  LEFT JOIN: a row missing the ORDER BY column sorts last ascending
++  test-order-by-12
  =|  run=@ud
  %-  exec-0-1-ordered
  :*  run
      [~2012.4.30 %db1 setup]
      :+  ~2012.5.3
          %db1
          "FROM tbl T1 LEFT JOIN tbl2 T2 SELECT T1.id, T2.label ".
          "ORDER BY T2.label"
      %-  tbl-tbl2-result
      :~  (id-label 1 'one')
          (id-label 3 'three')
          (id-label 2 'two')
          (id-only 4)
          ==
      ==
::
::  LEFT JOIN: a row missing the ORDER BY column sorts first descending
++  test-order-by-13
  =|  run=@ud
  %-  exec-0-1-ordered
  :*  run
      [~2012.4.30 %db1 setup]
      :+  ~2012.5.3
          %db1
          "FROM tbl T1 LEFT JOIN tbl2 T2 SELECT T1.id, T2.label ".
          "ORDER BY T2.label DESC"
      %-  tbl-tbl2-result
      :~  (id-only 4)
          (id-label 2 'two')
          (id-label 3 'three')
          (id-label 1 'one')
          ==
      ==
::
::  UNION: ORDER BY orders the combined result
++  test-order-by-14
  =|  run=@ud
  %-  exec-0-1-ordered
  :*  run
      [~2012.4.30 %db1 setup]
      :+  ~2012.5.3
          %db1
          "FROM tbl SELECT id, name ".
          "UNION ".
          "FROM tbl2 SELECT id, label AS name ".
          "ORDER BY name"
      %-  tbl-tbl2-result
      :~  (id-name 3 'alpha')
          (id-name 2 'Alpha')
          (id-name 1 'beta')
          (id-name 4 'gamma')
          (id-name 1 'one')
          (id-name 3 'three')
          (id-name 2 'two')
          ==
      ==
::
::  UNION: an operand with TOP keeps its top rows
++  test-order-by-15
  =|  run=@ud
  %-  exec-0-1-ordered
  :*  run
      [~2012.4.30 %db1 setup]
      :+  ~2012.5.3
          %db1
          "FROM tbl SELECT TOP 1 id ORDER BY id DESC ".
          "UNION ".
          "FROM tbl2 SELECT id ".
          "ORDER BY 1 DESC"
      %-  tbl-tbl2-result
      :~  (id-only 4)
          (id-only 3)
          (id-only 2)
          (id-only 1)
          ==
      ==
::
::  CTE with TOP keeps its top rows
++  test-order-by-16
  =|  run=@ud
  %-  exec-0-1-ordered
  :*  run
      [~2012.4.30 %db1 setup]
      :+  ~2012.5.3
          %db1
          "WITH (FROM tbl SELECT TOP 2 id, name ORDER BY id DESC) AS c ".
          "FROM c SELECT id, name ORDER BY id"
      (tbl-result ~[(id-name 3 'alpha') (id-name 4 'gamma')])
      ==
::
::  TOP over an order not total
++  test-fail-order-by-00
  =|  run=@ud
  %-  failon-1
  :*  run
      [~2012.4.30 %db1 setup]
      [~2012.5.3 %db1 "FROM tbl SELECT TOP 2 id, grp ORDER BY grp"]
      'TOP 2: ORDER BY is not a total ordering of the result'
      ==
::
::  unqualified ORDER BY column in several joined relations
++  test-fail-order-by-01
  =|  run=@ud
  %-  failon-1
  :*  run
      [~2012.4.30 %db1 setup]
      :+  ~2012.5.3
          %db1
          "FROM tbl T1 JOIN tbl2 T2 SELECT T1.id, T2.label ORDER BY id"
      'ORDER BY: column %id must be qualified'
      ==
::
::  ORDER BY column not found
++  test-fail-order-by-02
  =|  run=@ud
  %-  failon-1
  :*  run
      [~2012.4.30 %db1 setup]
      [~2012.5.3 %db1 "FROM tbl SELECT id ORDER BY nope"]
      'ORDER BY: column %nope not found'
      ==
::
::  TOP requires ORDER BY
++  test-fail-order-by-03
  =|  run=@ud
  %-  failon-1
  :*  run
      [~2012.4.30 %db1 setup]
      [~2012.5.3 %db1 "FROM tbl SELECT TOP 2 id"]
      'TOP requires ORDER BY'
      ==
::
::  TOP not allowed on the last query of a set operation
++  test-fail-order-by-04
  =|  run=@ud
  %-  failon-1
  :*  run
      [~2012.4.30 %db1 setup]
      :+  ~2012.5.3
          %db1
          "FROM tbl SELECT id UNION FROM tbl2 SELECT TOP 2 id ORDER BY id"
      'TOP is not allowed on the last query of a set operation'
      ==
::
::  ORDER BY of a set operation names output columns
++  test-fail-order-by-05
  =|  run=@ud
  %-  failon-1
  :*  run
      [~2012.4.30 %db1 setup]
      :+  ~2012.5.3
          %db1
          "FROM tbl T1 SELECT id UNION FROM tbl2 T2 SELECT id ORDER BY T2.id"
      'ORDER BY of a set operation must name an output column or ordinal'
      ==
::
::  column ordinal beyond the selected columns
++  test-fail-order-by-06
  =|  run=@ud
  %-  failon-1
  :*  run
      [~2012.4.30 %db1 setup]
      [~2012.5.3 %db1 "FROM tbl SELECT id ORDER BY 2"]
      'ORDER BY: column ordinal 2 exceeds the selected columns'
      ==
::
::  column ordinal beyond the columns of *
++  test-fail-order-by-07
  =|  run=@ud
  %-  failon-1
  :*  run
      [~2012.4.30 %db1 setup]
      [~2012.5.3 %db1 "FROM tbl2 SELECT * ORDER BY 3"]
      'ORDER BY: column ordinal 3 exceeds the selected columns'
      ==
::
::  TOP 0
++  test-fail-order-by-08
  =|  run=@ud
  %-  failon-1
  :*  run
      [~2012.4.30 %db1 setup]
      [~2012.5.3 %db1 "FROM tbl SELECT TOP 0 id ORDER BY id"]
      'TOP must be 1 or greater'
      ==
::
::  column ordinal 0
++  test-fail-order-by-09
  =|  run=@ud
  %-  failon-1
  :*  run
      [~2012.4.30 %db1 setup]
      [~2012.5.3 %db1 "FROM tbl SELECT id ORDER BY 0"]
      'ORDER BY: column ordinal must be 1 or greater'
      ==
--
