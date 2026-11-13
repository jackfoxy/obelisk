::  inline scalars: scalar functions invoked in place in SELECT, WHERE,
::  UPDATE SET and DELETE, outside the SCALARS clause
::
/+  *test-helpers
::
|%
::
::  row 1 matches every generated WHERE predicate unless noted; row 2
::  differs in every column so a predicate filters it out
++  init-inl
  %-  zing
  :~  "CREATE DATABASE db1;"
      "CREATE TABLE inl ".
      "(id @ud, nud @ud, nsd @sd, nrd @rd, nrd2 @rd, nu @rd, t @t, ".
      "tpad @t, d @da, dr @dr) ".
      "PRIMARY KEY (id);"
      "INSERT INTO inl VALUES ".
      "(1, 5, -1, .~1, .~1.5, .~1, 'hello', '  hello  ', ".
      "~2026.3.15..10.30.45, ~d1) ".
      "(2, 9, --4, .~4, .~2.5, .~0, 'WORLD', 'abc', ".
      "~2010.4.16..11.31.46, ~d2);"
      ==
::
++  init-inl-join
  %+  weld  init-inl
  " CREATE TABLE inl2 (id @ud, x @t) PRIMARY KEY (id); ".
  "INSERT INTO inl2 VALUES (1, 'a') (2, 'b');"
::
++  inl-meta
  |=  count=@ud
  :~  [%server-time ~2012.5.3]
      [%relation-name 'db1.dbo.inl']
      [%schema-time ~2012.4.30]
      [%data-time ~2012.4.30]
      [%vector-count count]
      ==
::
++  no-from-meta
  |=  count=@ud
  :~  [%server-time ~2012.5.3]
      [%schema-time ~2012.4.30]
      [%data-time ~2012.4.30]
      [%vector-count count]
      ==
::
++  rand-warning  [%message 'warning: results are non-deterministic']
::
::  edge cases
::
::  unaliased inline scalars are named by SELECT position, as literals are
++  test-inline-select-positions
  =|  run=@ud
  %-  exec-0-1
  :*  run
      [~2012.4.30 %sys "CREATE DATABASE db1"]
      ::
      [~2012.5.3 %sys "SELECT 1, ABS(-1), 'x' AS t, PI()"]
      ::
      :-  %results
          :*  [%action 'SELECT']
              :-  %result-set
                  :~  :-  %vector
                          :~  [%literal-0 [~.ud 1]]
                              [%scalar-1 [~.sd --1]]
                              [%t [~.t 'x']]
                              [%scalar-3 [~.rd .~3.141592653589793]]
                              ==
                      ==
              (no-from-meta 1)
              ==
      ==
::
++  test-inline-select-alias
  =|  run=@ud
  %-  exec-0-1
  :*  run
      [~2012.4.30 %sys "CREATE DATABASE db1"]
      ::
      [~2012.5.3 %sys "select abs(-1) as Answer"]
      ::
      :-  %results
          :*  [%action 'SELECT']
              [%result-set ~[[%vector ~[[%answer [~.sd --1]]]]]]
              (no-from-meta 1)
              ==
      ==
::
++  test-inline-select-with-scalars
  =|  run=@ud
  %-  exec-0-1
  :*  run
      [~2012.4.30 %sys "CREATE DATABASE db1"]
      ::
      [~2012.5.3 %sys "SCALARS sc1 ABS(-5) SELECT sc1, ABS(sc1)"]
      ::
      :-  %results
          :*  [%action 'SELECT']
              :-  %result-set
                  ~[[%vector ~[[%sc1 [~.sd --5]] [%scalar-1 [~.sd --5]]]]]
              (no-from-meta 1)
              ==
      ==
::
++  test-inline-select-nested
  =|  run=@ud
  %-  exec-0-1
  :*  run
      [~2012.4.30 %sys "CREATE DATABASE db1"]
      ::
      [~2012.5.3 %sys "SELECT LEN(TRIM('  a  '))"]
      ::
      :-  %results
          :*  [%action 'SELECT']
              [%result-set ~[[%vector ~[[%scalar-0 [~.ud 1]]]]]]
              (no-from-meta 1)
              ==
      ==
::
++  test-inline-select-fn-arithmetic
  =|  run=@ud
  %-  exec-0-1
  :*  run
      [~2012.4.30 %sys "CREATE DATABASE db1"]
      ::
      [~2012.5.3 %sys "SELECT ABS(-5) + --1"]
      ::
      :-  %results
          :*  [%action 'SELECT']
              [%result-set ~[[%vector ~[[%scalar-0 [~.sd --6]]]]]]
              (no-from-meta 1)
              ==
      ==
::
++  test-inline-select-if-arithmetic
  =|  run=@ud
  %-  exec-0-1
  :*  run
      [~2012.4.30 %sys "CREATE DATABASE db1"]
      ::
      [~2012.5.3 %sys "SELECT IF 1 = 1 THEN 1 ELSE 0 ENDIF + 1"]
      ::
      :-  %results
          :*  [%action 'SELECT']
              [%result-set ~[[%vector ~[[%scalar-0 [~.ud 2]]]]]]
              (no-from-meta 1)
              ==
      ==
::
++  test-inline-select-bare-constant
  =|  run=@ud
  %-  exec-0-1
  :*  run
      [~2012.4.30 %sys "CREATE DATABASE db1"]
      ::
      [~2012.5.3 %sys "SELECT .~1 * PI"]
      ::
      :-  %results
          :*  [%action 'SELECT']
              :-  %result-set
                  ~[[%vector ~[[%scalar-0 [~.rd .~3.141592653589793]]]]]
              (no-from-meta 1)
              ==
      ==
::
::  GETUTCDATE is the query time wherever it appears
++  test-inline-select-getutcdate-twice
  =|  run=@ud
  %-  exec-0-1
  :*  run
      [~2012.4.30 %sys "CREATE DATABASE db1"]
      ::
      [~2012.5.3 %sys "SELECT GETUTCDATE(), GETUTCDATE()"]
      ::
      :-  %results
          :*  [%action 'SELECT']
              :-  %result-set
                  :~  :-  %vector
                          :~  [%scalar-0 [~.da ~2012.5.3]]
                              [%scalar-1 [~.da ~2012.5.3]]
                              ==
                      ==
              (no-from-meta 1)
              ==
      ==
::
::  each RAND is evaluated separately, within its own range
++  test-inline-select-rand-twice
  =|  run=@ud
  %-  exec-rand-0-1
  :*  run
      [~2012.4.30 %sys "CREATE DATABASE db1"]
      ::
      [~2012.5.3 %sys "SELECT RAND(1, 10), RAND(-5, -2)"]
      ::
      [%results [rand-warning [%action 'SELECT'] (no-from-meta 1)]]
      ::
      ~[[%scalar-0 %ud 1 10] [%scalar-1 %sd -5 -2]]
      ==
::
++  test-inline-select-col-rand
  =|  run=@ud
  %-  exec-rand-0-1
  :*  run
      [~2012.4.30 %db1 init-inl]
      ::
      [~2012.5.3 %db1 "FROM inl SELECT id, RAND(1, 10)"]
      ::
      [%results [rand-warning [%action 'SELECT'] (inl-meta 2)]]
      ::
      ~[[%scalar-1 %ud 1 10]]
      ==
::
++  test-inline-where-rand
  =|  run=@ud
  %-  exec-0-1
  :*  run
      [~2012.4.30 %db1 init-inl]
      ::
      [~2012.5.3 %db1 "FROM inl WHERE RAND(1, 10) > 0 SELECT id"]
      ::
      :-  %results
          :*  rand-warning
              [%action 'SELECT']
              :-  %result-set
                  :~  [%vector ~[[%id [~.ud 1]]]]
                      [%vector ~[[%id [~.ud 2]]]]
                      ==
              (inl-meta 2)
              ==
      ==
::
++  test-inline-where-no-whitespace
  =|  run=@ud
  %-  exec-0-1
  :*  run
      [~2012.4.30 %db1 init-inl]
      ::
      [~2012.5.3 %db1 "FROM inl WHERE nud*2 = 10 SELECT id"]
      ::
      :-  %results
          :*  [%action 'SELECT']
              [%result-set ~[[%vector ~[[%id [~.ud 1]]]]]]
              (inl-meta 1)
              ==
      ==
::
++  test-inline-where-both-sides
  =|  run=@ud
  %-  exec-0-1
  :*  run
      [~2012.4.30 %db1 init-inl]
      ::
      :+  ~2012.5.3
          %db1
          "FROM inl WHERE LEN(t) + 4 = LEN(tpad) SELECT UPPER(t)"
      ::
      :-  %results
          :*  [%action 'SELECT']
              [%result-set ~[[%vector ~[[%scalar-0 [~.t 'HELLO']]]]]]
              (inl-meta 1)
              ==
      ==
::
++  test-inline-where-grouping
  =|  run=@ud
  %-  exec-0-1
  :*  run
      [~2012.4.30 %db1 init-inl]
      ::
      :+  ~2012.5.3
          %db1
          "FROM inl WHERE (LEN(t) = 5 OR nud = 9) AND id < 2 SELECT id"
      ::
      :-  %results
          :*  [%action 'SELECT']
              [%result-set ~[[%vector ~[[%id [~.ud 1]]]]]]
              (inl-meta 1)
              ==
      ==
::
++  test-inline-where-in
  =|  run=@ud
  %-  exec-0-1
  :*  run
      [~2012.4.30 %db1 init-inl]
      ::
      [~2012.5.3 %db1 "FROM inl WHERE LEN(tpad) IN (3,7) SELECT id"]
      ::
      :-  %results
          :*  [%action 'SELECT']
              [%result-set ~[[%vector ~[[%id [~.ud 2]]]]]]
              (inl-meta 1)
              ==
      ==
::
++  test-inline-where-between
  =|  run=@ud
  %-  exec-0-1
  :*  run
      [~2012.4.30 %db1 init-inl]
      ::
      :+  ~2012.5.3
          %db1
          "FROM inl WHERE nud BETWEEN LEN(t) AND LEN(tpad) SELECT id"
      ::
      :-  %results
          :*  [%action 'SELECT']
              [%result-set ~[[%vector ~[[%id [~.ud 1]]]]]]
              (inl-meta 1)
              ==
      ==
::
++  test-inline-where-not
  =|  run=@ud
  %-  exec-0-1
  :*  run
      [~2012.4.30 %db1 init-inl]
      ::
      [~2012.5.3 %db1 "FROM inl WHERE NOT UPPER(t) = 'HELLO' SELECT id"]
      ::
      :-  %results
          :*  [%action 'SELECT']
              [%result-set ~[[%vector ~[[%id [~.ud 2]]]]]]
              (inl-meta 1)
              ==
      ==
::
++  test-inline-where-nested-if
  =|  run=@ud
  %-  exec-0-1
  :*  run
      [~2012.4.30 %db1 init-inl]
      ::
      :+  ~2012.5.3
          %db1
          "FROM inl WHERE IF LEN(tpad) > 4 THEN 1 ELSE 0 ENDIF = 1 ".
          "SELECT id"
      ::
      :-  %results
          :*  [%action 'SELECT']
              [%result-set ~[[%vector ~[[%id [~.ud 1]]]]]]
              (inl-meta 1)
              ==
      ==
::
++  test-inline-where-references-scalar
  =|  run=@ud
  %-  exec-0-1
  :*  run
      [~2012.4.30 %db1 init-inl]
      ::
      :+  ~2012.5.3
          %db1
          "FROM inl SCALARS s1 nud + 1 END WHERE ABS(s1) = 6 SELECT id"
      ::
      :-  %results
          :*  [%action 'SELECT']
              [%result-set ~[[%vector ~[[%id [~.ud 1]]]]]]
              (inl-meta 1)
              ==
      ==
::
++  test-inline-in-scalars-if
  =|  run=@ud
  %-  exec-0-1
  :*  run
      [~2012.4.30 %db1 init-inl]
      ::
      :+  ~2012.5.3
          %db1
          "FROM inl SCALARS s1 IF LEN(tpad) > 4 THEN 'long' ELSE 'short' ".
          "ENDIF SELECT id, s1"
      ::
      :-  %results
          :*  [%action 'SELECT']
              :-  %result-set
                  :~  [%vector ~[[%id [~.ud 1]] [%s1 [~.t 'long']]]]
                      [%vector ~[[%id [~.ud 2]] [%s1 [~.t 'short']]]]
                      ==
              (inl-meta 2)
              ==
      ==
::
++  test-inline-in-scalars-case
  =|  run=@ud
  %-  exec-0-1
  :*  run
      [~2012.4.30 %db1 init-inl]
      ::
      :+  ~2012.5.3
          %db1
          "FROM inl SCALARS s1 CASE WHEN UPPER(t) = 'HELLO' THEN 1 ".
          "ELSE 0 END SELECT id, s1"
      ::
      :-  %results
          :*  [%action 'SELECT']
              :-  %result-set
                  :~  [%vector ~[[%id [~.ud 1]] [%s1 [~.ud 1]]]]
                      [%vector ~[[%id [~.ud 2]] [%s1 [~.ud 0]]]]
                      ==
              (inl-meta 2)
              ==
      ==
::
::  an unaliased inline scalar is a CTE column named by position
++  test-inline-cte
  =|  run=@ud
  %-  exec-0-1
  :*  run
      [~2012.4.30 %db1 init-inl]
      ::
      :+  ~2012.5.3
          %db1
          "WITH (FROM inl SELECT id, LEN(tpad)) AS c FROM c SELECT scalar-1"
      ::
      :-  %results
          :*  [%action 'SELECT']
              :-  %result-set
                  :~  [%vector ~[[%scalar-1 [~.ud 9]]]]
                      [%vector ~[[%scalar-1 [~.ud 3]]]]
                      ==
              (inl-meta 2)
              ==
      ==
::
++  test-inline-join
  =|  run=@ud
  %-  exec-0-1
  :*  run
      [~2012.4.30 %db1 init-inl-join]
      ::
      :+  ~2012.5.3
          %db1
          "FROM inl T1 JOIN inl2 T2 ON T1.id = T2.id ".
          "WHERE ABS(T1.nsd) = --1 SELECT T1.id, UPPER(T2.x)"
      ::
      :-  %results
          :~  [%action 'SELECT']
              :-  %result-set
                  ~[[%vector ~[[%id [~.ud 1]] [%scalar-1 [~.t 'A']]]]]
              [%server-time ~2012.5.3]
              [%relation-name 'db1.dbo.inl']
              [%schema-time ~2012.4.30]
              [%data-time ~2012.4.30]
              [%relation-name 'db1.dbo.inl2']
              [%schema-time ~2012.4.30]
              [%data-time ~2012.4.30]
              [%vector-count 1]
              ==
      ==
::
++  test-inline-update
  =|  run=@ud
  %-  exec-0-2
  :*  run
      [~2012.4.30 %db1 init-inl]
      ::
      :+  ~2012.5.1
          %db1
          "UPDATE inl SET nud = nud + 1, t = UPPER(t) WHERE LEN(tpad) = 9"
      ::
      [~2012.5.3 %db1 "FROM inl SELECT id, nud, t"]
      ::
      :-  %results
          :~  [%action 'UPDATE db1.dbo.inl']
              [%server-time ~2012.5.1]
              [%schema-time ~2012.4.30]
              [%data-time ~2012.4.30]
              [%message 'updated:']
              [%vector-count 1]
              [%message 'table data:']
              [%vector-count 2]
              ==
      ::
      :-  %results
          :~  [%action 'SELECT']
              :-  %result-set
                  :~  :-  %vector
                          ~[[%id [~.ud 1]] [%nud [~.ud 6]] [%t [~.t 'HELLO']]]
                      :-  %vector
                          ~[[%id [~.ud 2]] [%nud [~.ud 9]] [%t [~.t 'WORLD']]]
                      ==
              [%server-time ~2012.5.3]
              [%relation-name 'db1.dbo.inl']
              [%schema-time ~2012.4.30]
              [%data-time ~2012.5.1]
              [%vector-count 2]
              ==
      ==
::
++  test-inline-delete
  =|  run=@ud
  %-  exec-0-1
  :*  run
      [~2012.4.30 %db1 init-inl]
      ::
      [~2012.5.3 %db1 "DELETE FROM inl WHERE ABS(nsd) = --1"]
      ::
      :~  %results
          [%action 'DELETE FROM db1.dbo.inl']
          [%server-time ~2012.5.3]
          [%schema-time ~2012.4.30]
          [%data-time ~2012.4.30]
          [%message 'deleted:']
          [%vector-count 1]
          [%message 'table data:']
          [%vector-count 1]
          ==
      ==
::
::  JOIN ON predicates do not support scalar functions
++  test-fail-inline-join-on
  =|  run=@ud
  %-  failon-1
  :*  run
      [~2012.4.30 %db1 init-inl-join]
      ::
      :+  ~2012.5.3
          %db1
          "FROM inl T1 JOIN inl2 T2 ON ABS(T1.nsd) = T2.id SELECT T1.id"
      ::
      'scalar functions are not supported in this predicate'
      ==
::
::  inline scalars are type checked like SCALARS definitions
++  test-fail-inline-where-type
  =|  run=@ud
  %-  failon-1
  :*  run
      [~2012.4.30 %db1 init-inl]
      ::
      [~2012.5.3 %db1 "FROM inl WHERE ABS(nsd) = 1 SELECT id"]
      ::
      'comparing scalar to literal of different aura'
      ==
::
::  generated: each function in SELECT with literal arguments, in SELECT
::  with column arguments and in WHERE with column arguments
::
++  test-inline-select-abs
  =|  run=@ud
  %-  exec-0-1
  :*  run
      [~2012.4.30 %sys "CREATE DATABASE db1"]
      ::
      :+  ~2012.5.3
          %sys
          "SELECT ABS(-1)"
      ::
      :-  %results
          :~  [%action 'SELECT']
              :-  %result-set
                  ~[[%vector ~[[%scalar-0 [~.sd --1]]]]]
              [%server-time ~2012.5.3]
              [%schema-time ~2012.4.30]
              [%data-time ~2012.4.30]
              [%vector-count 1]
              ==
      ==
::
++  test-inline-select-col-abs
  =|  run=@ud
  %-  exec-0-1
  :*  run
      [~2012.4.30 %db1 init-inl]
      ::
      :+  ~2012.5.3
          %db1
          "FROM inl WHERE id = 1 SELECT id, ABS(nsd)"
      ::
      :-  %results
          :~  [%action 'SELECT']
              :-  %result-set
                  :~  :-  %vector
                          :~  [%id [~.ud 1]]
                              [%scalar-1 [~.sd --1]]
                              ==
                      ==
              [%server-time ~2012.5.3]
              [%relation-name 'db1.dbo.inl']
              [%schema-time ~2012.4.30]
              [%data-time ~2012.4.30]
              [%vector-count 1]
              ==
      ==
::
++  test-inline-where-abs
  =|  run=@ud
  %-  exec-0-1
  :*  run
      [~2012.4.30 %db1 init-inl]
      ::
      :+  ~2012.5.3
          %db1
          "FROM inl WHERE ABS(nsd) = --1 SELECT id"
      ::
      :-  %results
          :~  [%action 'SELECT']
              :-  %result-set
                  :~
                      [%vector ~[[%id [~.ud 1]]]]
                      ==
              [%server-time ~2012.5.3]
              [%relation-name 'db1.dbo.inl']
              [%schema-time ~2012.4.30]
              [%data-time ~2012.4.30]
              [%vector-count 1]
              ==
      ==
::
++  test-inline-select-sign
  =|  run=@ud
  %-  exec-0-1
  :*  run
      [~2012.4.30 %sys "CREATE DATABASE db1"]
      ::
      :+  ~2012.5.3
          %sys
          "SELECT SIGN(-1)"
      ::
      :-  %results
          :~  [%action 'SELECT']
              :-  %result-set
                  ~[[%vector ~[[%scalar-0 [~.sd -1]]]]]
              [%server-time ~2012.5.3]
              [%schema-time ~2012.4.30]
              [%data-time ~2012.4.30]
              [%vector-count 1]
              ==
      ==
::
++  test-inline-select-col-sign
  =|  run=@ud
  %-  exec-0-1
  :*  run
      [~2012.4.30 %db1 init-inl]
      ::
      :+  ~2012.5.3
          %db1
          "FROM inl WHERE id = 1 SELECT id, SIGN(nsd)"
      ::
      :-  %results
          :~  [%action 'SELECT']
              :-  %result-set
                  :~  :-  %vector
                          :~  [%id [~.ud 1]]
                              [%scalar-1 [~.sd -1]]
                              ==
                      ==
              [%server-time ~2012.5.3]
              [%relation-name 'db1.dbo.inl']
              [%schema-time ~2012.4.30]
              [%data-time ~2012.4.30]
              [%vector-count 1]
              ==
      ==
::
++  test-inline-where-sign
  =|  run=@ud
  %-  exec-0-1
  :*  run
      [~2012.4.30 %db1 init-inl]
      ::
      :+  ~2012.5.3
          %db1
          "FROM inl WHERE SIGN(nsd) = -1 SELECT id"
      ::
      :-  %results
          :~  [%action 'SELECT']
              :-  %result-set
                  :~
                      [%vector ~[[%id [~.ud 1]]]]
                      ==
              [%server-time ~2012.5.3]
              [%relation-name 'db1.dbo.inl']
              [%schema-time ~2012.4.30]
              [%data-time ~2012.4.30]
              [%vector-count 1]
              ==
      ==
::
++  test-inline-select-sqrt
  =|  run=@ud
  %-  exec-0-1
  :*  run
      [~2012.4.30 %sys "CREATE DATABASE db1"]
      ::
      :+  ~2012.5.3
          %sys
          "SELECT SQRT(.~4)"
      ::
      :-  %results
          :~  [%action 'SELECT']
              :-  %result-set
                  ~[[%vector ~[[%scalar-0 [~.rd .~2]]]]]
              [%server-time ~2012.5.3]
              [%schema-time ~2012.4.30]
              [%data-time ~2012.4.30]
              [%vector-count 1]
              ==
      ==
::
++  test-inline-select-col-sqrt
  =|  run=@ud
  %-  exec-0-1
  :*  run
      [~2012.4.30 %db1 init-inl]
      ::
      :+  ~2012.5.3
          %db1
          "FROM inl WHERE id = 1 SELECT id, SQRT(nrd)"
      ::
      :-  %results
          :~  [%action 'SELECT']
              :-  %result-set
                  :~  :-  %vector
                          :~  [%id [~.ud 1]]
                              [%scalar-1 [~.rd .~1]]
                              ==
                      ==
              [%server-time ~2012.5.3]
              [%relation-name 'db1.dbo.inl']
              [%schema-time ~2012.4.30]
              [%data-time ~2012.4.30]
              [%vector-count 1]
              ==
      ==
::
++  test-inline-where-sqrt
  =|  run=@ud
  %-  exec-0-1
  :*  run
      [~2012.4.30 %db1 init-inl]
      ::
      :+  ~2012.5.3
          %db1
          "FROM inl WHERE SQRT(nrd) = .~2 SELECT id"
      ::
      :-  %results
          :~  [%action 'SELECT']
              :-  %result-set
                  :~
                      [%vector ~[[%id [~.ud 2]]]]
                      ==
              [%server-time ~2012.5.3]
              [%relation-name 'db1.dbo.inl']
              [%schema-time ~2012.4.30]
              [%data-time ~2012.4.30]
              [%vector-count 1]
              ==
      ==
::
++  test-inline-select-floor
  =|  run=@ud
  %-  exec-0-1
  :*  run
      [~2012.4.30 %sys "CREATE DATABASE db1"]
      ::
      :+  ~2012.5.3
          %sys
          "SELECT FLOOR(.~1.5)"
      ::
      :-  %results
          :~  [%action 'SELECT']
              :-  %result-set
                  ~[[%vector ~[[%scalar-0 [~.rd .~1]]]]]
              [%server-time ~2012.5.3]
              [%schema-time ~2012.4.30]
              [%data-time ~2012.4.30]
              [%vector-count 1]
              ==
      ==
::
++  test-inline-select-col-floor
  =|  run=@ud
  %-  exec-0-1
  :*  run
      [~2012.4.30 %db1 init-inl]
      ::
      :+  ~2012.5.3
          %db1
          "FROM inl WHERE id = 1 SELECT id, FLOOR(nrd2)"
      ::
      :-  %results
          :~  [%action 'SELECT']
              :-  %result-set
                  :~  :-  %vector
                          :~  [%id [~.ud 1]]
                              [%scalar-1 [~.rd .~1]]
                              ==
                      ==
              [%server-time ~2012.5.3]
              [%relation-name 'db1.dbo.inl']
              [%schema-time ~2012.4.30]
              [%data-time ~2012.4.30]
              [%vector-count 1]
              ==
      ==
::
++  test-inline-where-floor
  =|  run=@ud
  %-  exec-0-1
  :*  run
      [~2012.4.30 %db1 init-inl]
      ::
      :+  ~2012.5.3
          %db1
          "FROM inl WHERE FLOOR(nrd2) = .~1 SELECT id"
      ::
      :-  %results
          :~  [%action 'SELECT']
              :-  %result-set
                  :~
                      [%vector ~[[%id [~.ud 1]]]]
                      ==
              [%server-time ~2012.5.3]
              [%relation-name 'db1.dbo.inl']
              [%schema-time ~2012.4.30]
              [%data-time ~2012.4.30]
              [%vector-count 1]
              ==
      ==
::
++  test-inline-select-ceiling
  =|  run=@ud
  %-  exec-0-1
  :*  run
      [~2012.4.30 %sys "CREATE DATABASE db1"]
      ::
      :+  ~2012.5.3
          %sys
          "SELECT CEILING(.~1.5)"
      ::
      :-  %results
          :~  [%action 'SELECT']
              :-  %result-set
                  ~[[%vector ~[[%scalar-0 [~.rd .~2]]]]]
              [%server-time ~2012.5.3]
              [%schema-time ~2012.4.30]
              [%data-time ~2012.4.30]
              [%vector-count 1]
              ==
      ==
::
++  test-inline-select-col-ceiling
  =|  run=@ud
  %-  exec-0-1
  :*  run
      [~2012.4.30 %db1 init-inl]
      ::
      :+  ~2012.5.3
          %db1
          "FROM inl WHERE id = 1 SELECT id, CEILING(nrd2)"
      ::
      :-  %results
          :~  [%action 'SELECT']
              :-  %result-set
                  :~  :-  %vector
                          :~  [%id [~.ud 1]]
                              [%scalar-1 [~.rd .~2]]
                              ==
                      ==
              [%server-time ~2012.5.3]
              [%relation-name 'db1.dbo.inl']
              [%schema-time ~2012.4.30]
              [%data-time ~2012.4.30]
              [%vector-count 1]
              ==
      ==
::
++  test-inline-where-ceiling
  =|  run=@ud
  %-  exec-0-1
  :*  run
      [~2012.4.30 %db1 init-inl]
      ::
      :+  ~2012.5.3
          %db1
          "FROM inl WHERE CEILING(nrd2) = .~2 SELECT id"
      ::
      :-  %results
          :~  [%action 'SELECT']
              :-  %result-set
                  :~
                      [%vector ~[[%id [~.ud 1]]]]
                      ==
              [%server-time ~2012.5.3]
              [%relation-name 'db1.dbo.inl']
              [%schema-time ~2012.4.30]
              [%data-time ~2012.4.30]
              [%vector-count 1]
              ==
      ==
::
++  test-inline-select-round
  =|  run=@ud
  %-  exec-0-1
  :*  run
      [~2012.4.30 %sys "CREATE DATABASE db1"]
      ::
      :+  ~2012.5.3
          %sys
          "SELECT ROUND(.~1.5, 0)"
      ::
      :-  %results
          :~  [%action 'SELECT']
              :-  %result-set
                  ~[[%vector ~[[%scalar-0 [~.rd .~2]]]]]
              [%server-time ~2012.5.3]
              [%schema-time ~2012.4.30]
              [%data-time ~2012.4.30]
              [%vector-count 1]
              ==
      ==
::
++  test-inline-select-col-round
  =|  run=@ud
  %-  exec-0-1
  :*  run
      [~2012.4.30 %db1 init-inl]
      ::
      :+  ~2012.5.3
          %db1
          "FROM inl WHERE id = 1 SELECT id, ROUND(nrd2, 0)"
      ::
      :-  %results
          :~  [%action 'SELECT']
              :-  %result-set
                  :~  :-  %vector
                          :~  [%id [~.ud 1]]
                              [%scalar-1 [~.rd .~2]]
                              ==
                      ==
              [%server-time ~2012.5.3]
              [%relation-name 'db1.dbo.inl']
              [%schema-time ~2012.4.30]
              [%data-time ~2012.4.30]
              [%vector-count 1]
              ==
      ==
::
++  test-inline-where-round
  =|  run=@ud
  %-  exec-0-1
  :*  run
      [~2012.4.30 %db1 init-inl]
      ::
      :+  ~2012.5.3
          %db1
          "FROM inl WHERE ROUND(nrd2, 0) = .~2 SELECT id"
      ::
      :-  %results
          :~  [%action 'SELECT']
              :-  %result-set
                  :~
                      [%vector ~[[%id [~.ud 1]]]]
                      ==
              [%server-time ~2012.5.3]
              [%relation-name 'db1.dbo.inl']
              [%schema-time ~2012.4.30]
              [%data-time ~2012.4.30]
              [%vector-count 1]
              ==
      ==
::
++  test-inline-select-max
  =|  run=@ud
  %-  exec-0-1
  :*  run
      [~2012.4.30 %sys "CREATE DATABASE db1"]
      ::
      :+  ~2012.5.3
          %sys
          "SELECT MAX(.~1, .~2)"
      ::
      :-  %results
          :~  [%action 'SELECT']
              :-  %result-set
                  ~[[%vector ~[[%scalar-0 [~.rd .~2]]]]]
              [%server-time ~2012.5.3]
              [%schema-time ~2012.4.30]
              [%data-time ~2012.4.30]
              [%vector-count 1]
              ==
      ==
::
++  test-inline-select-col-max
  =|  run=@ud
  %-  exec-0-1
  :*  run
      [~2012.4.30 %db1 init-inl]
      ::
      :+  ~2012.5.3
          %db1
          "FROM inl WHERE id = 1 SELECT id, MAX(nrd, .~2)"
      ::
      :-  %results
          :~  [%action 'SELECT']
              :-  %result-set
                  :~  :-  %vector
                          :~  [%id [~.ud 1]]
                              [%scalar-1 [~.rd .~2]]
                              ==
                      ==
              [%server-time ~2012.5.3]
              [%relation-name 'db1.dbo.inl']
              [%schema-time ~2012.4.30]
              [%data-time ~2012.4.30]
              [%vector-count 1]
              ==
      ==
::
++  test-inline-where-max
  =|  run=@ud
  %-  exec-0-1
  :*  run
      [~2012.4.30 %db1 init-inl]
      ::
      :+  ~2012.5.3
          %db1
          "FROM inl WHERE MAX(nrd, .~2) = .~2 SELECT id"
      ::
      :-  %results
          :~  [%action 'SELECT']
              :-  %result-set
                  :~
                      [%vector ~[[%id [~.ud 1]]]]
                      ==
              [%server-time ~2012.5.3]
              [%relation-name 'db1.dbo.inl']
              [%schema-time ~2012.4.30]
              [%data-time ~2012.4.30]
              [%vector-count 1]
              ==
      ==
::
++  test-inline-select-min
  =|  run=@ud
  %-  exec-0-1
  :*  run
      [~2012.4.30 %sys "CREATE DATABASE db1"]
      ::
      :+  ~2012.5.3
          %sys
          "SELECT MIN(.~1, .~2)"
      ::
      :-  %results
          :~  [%action 'SELECT']
              :-  %result-set
                  ~[[%vector ~[[%scalar-0 [~.rd .~1]]]]]
              [%server-time ~2012.5.3]
              [%schema-time ~2012.4.30]
              [%data-time ~2012.4.30]
              [%vector-count 1]
              ==
      ==
::
++  test-inline-select-col-min
  =|  run=@ud
  %-  exec-0-1
  :*  run
      [~2012.4.30 %db1 init-inl]
      ::
      :+  ~2012.5.3
          %db1
          "FROM inl WHERE id = 1 SELECT id, MIN(nrd, .~2)"
      ::
      :-  %results
          :~  [%action 'SELECT']
              :-  %result-set
                  :~  :-  %vector
                          :~  [%id [~.ud 1]]
                              [%scalar-1 [~.rd .~1]]
                              ==
                      ==
              [%server-time ~2012.5.3]
              [%relation-name 'db1.dbo.inl']
              [%schema-time ~2012.4.30]
              [%data-time ~2012.4.30]
              [%vector-count 1]
              ==
      ==
::
++  test-inline-where-min
  =|  run=@ud
  %-  exec-0-1
  :*  run
      [~2012.4.30 %db1 init-inl]
      ::
      :+  ~2012.5.3
          %db1
          "FROM inl WHERE MIN(nrd, .~2) = .~1 SELECT id"
      ::
      :-  %results
          :~  [%action 'SELECT']
              :-  %result-set
                  :~
                      [%vector ~[[%id [~.ud 1]]]]
                      ==
              [%server-time ~2012.5.3]
              [%relation-name 'db1.dbo.inl']
              [%schema-time ~2012.4.30]
              [%data-time ~2012.4.30]
              [%vector-count 1]
              ==
      ==
::
++  test-inline-select-log
  =|  run=@ud
  %-  exec-0-1
  :*  run
      [~2012.4.30 %sys "CREATE DATABASE db1"]
      ::
      :+  ~2012.5.3
          %sys
          "SELECT LOG(.~1)"
      ::
      :-  %results
          :~  [%action 'SELECT']
              :-  %result-set
                  ~[[%vector ~[[%scalar-0 [~.rd .~0]]]]]
              [%server-time ~2012.5.3]
              [%schema-time ~2012.4.30]
              [%data-time ~2012.4.30]
              [%vector-count 1]
              ==
      ==
::
++  test-inline-select-col-log
  =|  run=@ud
  %-  exec-0-1
  :*  run
      [~2012.4.30 %db1 init-inl]
      ::
      :+  ~2012.5.3
          %db1
          "FROM inl WHERE id = 1 SELECT id, LOG(nrd)"
      ::
      :-  %results
          :~  [%action 'SELECT']
              :-  %result-set
                  :~  :-  %vector
                          :~  [%id [~.ud 1]]
                              [%scalar-1 [~.rd .~0]]
                              ==
                      ==
              [%server-time ~2012.5.3]
              [%relation-name 'db1.dbo.inl']
              [%schema-time ~2012.4.30]
              [%data-time ~2012.4.30]
              [%vector-count 1]
              ==
      ==
::
++  test-inline-where-log
  =|  run=@ud
  %-  exec-0-1
  :*  run
      [~2012.4.30 %db1 init-inl]
      ::
      :+  ~2012.5.3
          %db1
          "FROM inl WHERE LOG(nrd) = .~0 SELECT id"
      ::
      :-  %results
          :~  [%action 'SELECT']
              :-  %result-set
                  :~
                      [%vector ~[[%id [~.ud 1]]]]
                      ==
              [%server-time ~2012.5.3]
              [%relation-name 'db1.dbo.inl']
              [%schema-time ~2012.4.30]
              [%data-time ~2012.4.30]
              [%vector-count 1]
              ==
      ==
::
++  test-inline-select-sin
  =|  run=@ud
  %-  exec-0-1
  :*  run
      [~2012.4.30 %sys "CREATE DATABASE db1"]
      ::
      :+  ~2012.5.3
          %sys
          "SELECT SIN(.~1)"
      ::
      :-  %results
          :~  [%action 'SELECT']
              :-  %result-set
                  ~[[%vector ~[[%scalar-0 [~.rd .~0.84147098480789606]]]]]
              [%server-time ~2012.5.3]
              [%schema-time ~2012.4.30]
              [%data-time ~2012.4.30]
              [%vector-count 1]
              ==
      ==
::
++  test-inline-select-col-sin
  =|  run=@ud
  %-  exec-0-1
  :*  run
      [~2012.4.30 %db1 init-inl]
      ::
      :+  ~2012.5.3
          %db1
          "FROM inl WHERE id = 1 SELECT id, SIN(nrd)"
      ::
      :-  %results
          :~  [%action 'SELECT']
              :-  %result-set
                  :~  :-  %vector
                          :~  [%id [~.ud 1]]
                              [%scalar-1 [~.rd .~0.84147098480789606]]
                              ==
                      ==
              [%server-time ~2012.5.3]
              [%relation-name 'db1.dbo.inl']
              [%schema-time ~2012.4.30]
              [%data-time ~2012.4.30]
              [%vector-count 1]
              ==
      ==
::
++  test-inline-where-sin
  =|  run=@ud
  %-  exec-0-1
  :*  run
      [~2012.4.30 %db1 init-inl]
      ::
      :+  ~2012.5.3
          %db1
          "FROM inl WHERE SIN(nrd) = .~0.84147098480789606 SELECT id"
      ::
      :-  %results
          :~  [%action 'SELECT']
              :-  %result-set
                  :~
                      [%vector ~[[%id [~.ud 1]]]]
                      ==
              [%server-time ~2012.5.3]
              [%relation-name 'db1.dbo.inl']
              [%schema-time ~2012.4.30]
              [%data-time ~2012.4.30]
              [%vector-count 1]
              ==
      ==
::
++  test-inline-select-cos
  =|  run=@ud
  %-  exec-0-1
  :*  run
      [~2012.4.30 %sys "CREATE DATABASE db1"]
      ::
      :+  ~2012.5.3
          %sys
          "SELECT COS(.~1)"
      ::
      :-  %results
          :~  [%action 'SELECT']
              :-  %result-set
                  ~[[%vector ~[[%scalar-0 [~.rd .~0.54030230586813921]]]]]
              [%server-time ~2012.5.3]
              [%schema-time ~2012.4.30]
              [%data-time ~2012.4.30]
              [%vector-count 1]
              ==
      ==
::
++  test-inline-select-col-cos
  =|  run=@ud
  %-  exec-0-1
  :*  run
      [~2012.4.30 %db1 init-inl]
      ::
      :+  ~2012.5.3
          %db1
          "FROM inl WHERE id = 1 SELECT id, COS(nrd)"
      ::
      :-  %results
          :~  [%action 'SELECT']
              :-  %result-set
                  :~  :-  %vector
                          :~  [%id [~.ud 1]]
                              [%scalar-1 [~.rd .~0.54030230586813921]]
                              ==
                      ==
              [%server-time ~2012.5.3]
              [%relation-name 'db1.dbo.inl']
              [%schema-time ~2012.4.30]
              [%data-time ~2012.4.30]
              [%vector-count 1]
              ==
      ==
::
++  test-inline-where-cos
  =|  run=@ud
  %-  exec-0-1
  :*  run
      [~2012.4.30 %db1 init-inl]
      ::
      :+  ~2012.5.3
          %db1
          "FROM inl WHERE COS(nrd) = .~0.54030230586813921 SELECT id"
      ::
      :-  %results
          :~  [%action 'SELECT']
              :-  %result-set
                  :~
                      [%vector ~[[%id [~.ud 1]]]]
                      ==
              [%server-time ~2012.5.3]
              [%relation-name 'db1.dbo.inl']
              [%schema-time ~2012.4.30]
              [%data-time ~2012.4.30]
              [%vector-count 1]
              ==
      ==
::
++  test-inline-select-tan
  =|  run=@ud
  %-  exec-0-1
  :*  run
      [~2012.4.30 %sys "CREATE DATABASE db1"]
      ::
      :+  ~2012.5.3
          %sys
          "SELECT TAN(.~1)"
      ::
      :-  %results
          :~  [%action 'SELECT']
              :-  %result-set
                  ~[[%vector ~[[%scalar-0 [~.rd .~1.5574077246549027]]]]]
              [%server-time ~2012.5.3]
              [%schema-time ~2012.4.30]
              [%data-time ~2012.4.30]
              [%vector-count 1]
              ==
      ==
::
++  test-inline-select-col-tan
  =|  run=@ud
  %-  exec-0-1
  :*  run
      [~2012.4.30 %db1 init-inl]
      ::
      :+  ~2012.5.3
          %db1
          "FROM inl WHERE id = 1 SELECT id, TAN(nrd)"
      ::
      :-  %results
          :~  [%action 'SELECT']
              :-  %result-set
                  :~  :-  %vector
                          :~  [%id [~.ud 1]]
                              [%scalar-1 [~.rd .~1.5574077246549027]]
                              ==
                      ==
              [%server-time ~2012.5.3]
              [%relation-name 'db1.dbo.inl']
              [%schema-time ~2012.4.30]
              [%data-time ~2012.4.30]
              [%vector-count 1]
              ==
      ==
::
++  test-inline-where-tan
  =|  run=@ud
  %-  exec-0-1
  :*  run
      [~2012.4.30 %db1 init-inl]
      ::
      :+  ~2012.5.3
          %db1
          "FROM inl WHERE TAN(nrd) = .~1.5574077246549027 SELECT id"
      ::
      :-  %results
          :~  [%action 'SELECT']
              :-  %result-set
                  :~
                      [%vector ~[[%id [~.ud 1]]]]
                      ==
              [%server-time ~2012.5.3]
              [%relation-name 'db1.dbo.inl']
              [%schema-time ~2012.4.30]
              [%data-time ~2012.4.30]
              [%vector-count 1]
              ==
      ==
::
++  test-inline-select-asin
  =|  run=@ud
  %-  exec-0-1
  :*  run
      [~2012.4.30 %sys "CREATE DATABASE db1"]
      ::
      :+  ~2012.5.3
          %sys
          "SELECT ASIN(.~1)"
      ::
      :-  %results
          :~  [%action 'SELECT']
              :-  %result-set
                  ~[[%vector ~[[%scalar-0 [~.rd .~1.5707963267948966]]]]]
              [%server-time ~2012.5.3]
              [%schema-time ~2012.4.30]
              [%data-time ~2012.4.30]
              [%vector-count 1]
              ==
      ==
::
++  test-inline-select-col-asin
  =|  run=@ud
  %-  exec-0-1
  :*  run
      [~2012.4.30 %db1 init-inl]
      ::
      :+  ~2012.5.3
          %db1
          "FROM inl WHERE id = 1 SELECT id, ASIN(nu)"
      ::
      :-  %results
          :~  [%action 'SELECT']
              :-  %result-set
                  :~  :-  %vector
                          :~  [%id [~.ud 1]]
                              [%scalar-1 [~.rd .~1.5707963267948966]]
                              ==
                      ==
              [%server-time ~2012.5.3]
              [%relation-name 'db1.dbo.inl']
              [%schema-time ~2012.4.30]
              [%data-time ~2012.4.30]
              [%vector-count 1]
              ==
      ==
::
++  test-inline-where-asin
  =|  run=@ud
  %-  exec-0-1
  :*  run
      [~2012.4.30 %db1 init-inl]
      ::
      :+  ~2012.5.3
          %db1
          "FROM inl WHERE ASIN(nu) = .~1.5707963267948966 SELECT id"
      ::
      :-  %results
          :~  [%action 'SELECT']
              :-  %result-set
                  :~
                      [%vector ~[[%id [~.ud 1]]]]
                      ==
              [%server-time ~2012.5.3]
              [%relation-name 'db1.dbo.inl']
              [%schema-time ~2012.4.30]
              [%data-time ~2012.4.30]
              [%vector-count 1]
              ==
      ==
::
++  test-inline-select-acos
  =|  run=@ud
  %-  exec-0-1
  :*  run
      [~2012.4.30 %sys "CREATE DATABASE db1"]
      ::
      :+  ~2012.5.3
          %sys
          "SELECT ACOS(.~0)"
      ::
      :-  %results
          :~  [%action 'SELECT']
              :-  %result-set
                  ~[[%vector ~[[%scalar-0 [~.rd .~1.5707963267948966]]]]]
              [%server-time ~2012.5.3]
              [%schema-time ~2012.4.30]
              [%data-time ~2012.4.30]
              [%vector-count 1]
              ==
      ==
::
++  test-inline-select-col-acos
  =|  run=@ud
  %-  exec-0-1
  :*  run
      [~2012.4.30 %db1 init-inl]
      ::
      :+  ~2012.5.3
          %db1
          "FROM inl WHERE id = 1 SELECT id, ACOS(nu)"
      ::
      :-  %results
          :~  [%action 'SELECT']
              :-  %result-set
                  :~  :-  %vector
                          :~  [%id [~.ud 1]]
                              [%scalar-1 [~.rd .~0]]
                              ==
                      ==
              [%server-time ~2012.5.3]
              [%relation-name 'db1.dbo.inl']
              [%schema-time ~2012.4.30]
              [%data-time ~2012.4.30]
              [%vector-count 1]
              ==
      ==
::
++  test-inline-where-acos
  =|  run=@ud
  %-  exec-0-1
  :*  run
      [~2012.4.30 %db1 init-inl]
      ::
      :+  ~2012.5.3
          %db1
          "FROM inl WHERE ACOS(nu) = .~0 SELECT id"
      ::
      :-  %results
          :~  [%action 'SELECT']
              :-  %result-set
                  :~
                      [%vector ~[[%id [~.ud 1]]]]
                      ==
              [%server-time ~2012.5.3]
              [%relation-name 'db1.dbo.inl']
              [%schema-time ~2012.4.30]
              [%data-time ~2012.4.30]
              [%vector-count 1]
              ==
      ==
::
++  test-inline-select-atan
  =|  run=@ud
  %-  exec-0-1
  :*  run
      [~2012.4.30 %sys "CREATE DATABASE db1"]
      ::
      :+  ~2012.5.3
          %sys
          "SELECT ATAN(.~1)"
      ::
      :-  %results
          :~  [%action 'SELECT']
              :-  %result-set
                  ~[[%vector ~[[%scalar-0 [~.rd .~0.78539816339745139]]]]]
              [%server-time ~2012.5.3]
              [%schema-time ~2012.4.30]
              [%data-time ~2012.4.30]
              [%vector-count 1]
              ==
      ==
::
++  test-inline-select-col-atan
  =|  run=@ud
  %-  exec-0-1
  :*  run
      [~2012.4.30 %db1 init-inl]
      ::
      :+  ~2012.5.3
          %db1
          "FROM inl WHERE id = 1 SELECT id, ATAN(nrd)"
      ::
      :-  %results
          :~  [%action 'SELECT']
              :-  %result-set
                  :~  :-  %vector
                          :~  [%id [~.ud 1]]
                              [%scalar-1 [~.rd .~0.78539816339745139]]
                              ==
                      ==
              [%server-time ~2012.5.3]
              [%relation-name 'db1.dbo.inl']
              [%schema-time ~2012.4.30]
              [%data-time ~2012.4.30]
              [%vector-count 1]
              ==
      ==
::
++  test-inline-where-atan
  =|  run=@ud
  %-  exec-0-1
  :*  run
      [~2012.4.30 %db1 init-inl]
      ::
      :+  ~2012.5.3
          %db1
          "FROM inl WHERE ATAN(nrd) = .~0.78539816339745139 SELECT id"
      ::
      :-  %results
          :~  [%action 'SELECT']
              :-  %result-set
                  :~
                      [%vector ~[[%id [~.ud 1]]]]
                      ==
              [%server-time ~2012.5.3]
              [%relation-name 'db1.dbo.inl']
              [%schema-time ~2012.4.30]
              [%data-time ~2012.4.30]
              [%vector-count 1]
              ==
      ==
::
++  test-inline-select-atan2
  =|  run=@ud
  %-  exec-0-1
  :*  run
      [~2012.4.30 %sys "CREATE DATABASE db1"]
      ::
      :+  ~2012.5.3
          %sys
          "SELECT ATAN2(.~1, .~2)"
      ::
      :-  %results
          :~  [%action 'SELECT']
              :-  %result-set
                  ~[[%vector ~[[%scalar-0 [~.rd .~0.46364760900080748]]]]]
              [%server-time ~2012.5.3]
              [%schema-time ~2012.4.30]
              [%data-time ~2012.4.30]
              [%vector-count 1]
              ==
      ==
::
++  test-inline-select-col-atan2
  =|  run=@ud
  %-  exec-0-1
  :*  run
      [~2012.4.30 %db1 init-inl]
      ::
      :+  ~2012.5.3
          %db1
          "FROM inl WHERE id = 1 SELECT id, ATAN2(nrd, .~2)"
      ::
      :-  %results
          :~  [%action 'SELECT']
              :-  %result-set
                  :~  :-  %vector
                          :~  [%id [~.ud 1]]
                              [%scalar-1 [~.rd .~0.46364760900080748]]
                              ==
                      ==
              [%server-time ~2012.5.3]
              [%relation-name 'db1.dbo.inl']
              [%schema-time ~2012.4.30]
              [%data-time ~2012.4.30]
              [%vector-count 1]
              ==
      ==
::
++  test-inline-where-atan2
  =|  run=@ud
  %-  exec-0-1
  :*  run
      [~2012.4.30 %db1 init-inl]
      ::
      :+  ~2012.5.3
          %db1
          "FROM inl WHERE ATAN2(nrd, .~2) = .~0.46364760900080748 SELECT id"
      ::
      :-  %results
          :~  [%action 'SELECT']
              :-  %result-set
                  :~
                      [%vector ~[[%id [~.ud 1]]]]
                      ==
              [%server-time ~2012.5.3]
              [%relation-name 'db1.dbo.inl']
              [%schema-time ~2012.4.30]
              [%data-time ~2012.4.30]
              [%vector-count 1]
              ==
      ==
::
++  test-inline-select-degrees
  =|  run=@ud
  %-  exec-0-1
  :*  run
      [~2012.4.30 %sys "CREATE DATABASE db1"]
      ::
      :+  ~2012.5.3
          %sys
          "SELECT DEGREES(.~1)"
      ::
      :-  %results
          :~  [%action 'SELECT']
              :-  %result-set
                  ~[[%vector ~[[%scalar-0 [~.rd .~57.29577951308232]]]]]
              [%server-time ~2012.5.3]
              [%schema-time ~2012.4.30]
              [%data-time ~2012.4.30]
              [%vector-count 1]
              ==
      ==
::
++  test-inline-select-col-degrees
  =|  run=@ud
  %-  exec-0-1
  :*  run
      [~2012.4.30 %db1 init-inl]
      ::
      :+  ~2012.5.3
          %db1
          "FROM inl WHERE id = 1 SELECT id, DEGREES(nrd)"
      ::
      :-  %results
          :~  [%action 'SELECT']
              :-  %result-set
                  :~  :-  %vector
                          :~  [%id [~.ud 1]]
                              [%scalar-1 [~.rd .~57.29577951308232]]
                              ==
                      ==
              [%server-time ~2012.5.3]
              [%relation-name 'db1.dbo.inl']
              [%schema-time ~2012.4.30]
              [%data-time ~2012.4.30]
              [%vector-count 1]
              ==
      ==
::
++  test-inline-where-degrees
  =|  run=@ud
  %-  exec-0-1
  :*  run
      [~2012.4.30 %db1 init-inl]
      ::
      :+  ~2012.5.3
          %db1
          "FROM inl WHERE DEGREES(nrd) = .~57.29577951308232 SELECT id"
      ::
      :-  %results
          :~  [%action 'SELECT']
              :-  %result-set
                  :~
                      [%vector ~[[%id [~.ud 1]]]]
                      ==
              [%server-time ~2012.5.3]
              [%relation-name 'db1.dbo.inl']
              [%schema-time ~2012.4.30]
              [%data-time ~2012.4.30]
              [%vector-count 1]
              ==
      ==
::
++  test-inline-select-e
  =|  run=@ud
  %-  exec-0-1
  :*  run
      [~2012.4.30 %sys "CREATE DATABASE db1"]
      ::
      :+  ~2012.5.3
          %sys
          "SELECT E()"
      ::
      :-  %results
          :~  [%action 'SELECT']
              :-  %result-set
                  ~[[%vector ~[[%scalar-0 [~.rd .~2.718281828459045]]]]]
              [%server-time ~2012.5.3]
              [%schema-time ~2012.4.30]
              [%data-time ~2012.4.30]
              [%vector-count 1]
              ==
      ==
::
++  test-inline-select-col-e
  =|  run=@ud
  %-  exec-0-1
  :*  run
      [~2012.4.30 %db1 init-inl]
      ::
      :+  ~2012.5.3
          %db1
          "FROM inl WHERE id = 1 SELECT id, nrd * E()"
      ::
      :-  %results
          :~  [%action 'SELECT']
              :-  %result-set
                  :~  :-  %vector
                          :~  [%id [~.ud 1]]
                              [%scalar-1 [~.rd .~2.718281828459045]]
                              ==
                      ==
              [%server-time ~2012.5.3]
              [%relation-name 'db1.dbo.inl']
              [%schema-time ~2012.4.30]
              [%data-time ~2012.4.30]
              [%vector-count 1]
              ==
      ==
::
++  test-inline-where-e
  =|  run=@ud
  %-  exec-0-1
  :*  run
      [~2012.4.30 %db1 init-inl]
      ::
      :+  ~2012.5.3
          %db1
          "FROM inl WHERE nrd < E() SELECT id"
      ::
      :-  %results
          :~  [%action 'SELECT']
              :-  %result-set
                  :~
                      [%vector ~[[%id [~.ud 1]]]]
                      ==
              [%server-time ~2012.5.3]
              [%relation-name 'db1.dbo.inl']
              [%schema-time ~2012.4.30]
              [%data-time ~2012.4.30]
              [%vector-count 1]
              ==
      ==
::
++  test-inline-select-phi
  =|  run=@ud
  %-  exec-0-1
  :*  run
      [~2012.4.30 %sys "CREATE DATABASE db1"]
      ::
      :+  ~2012.5.3
          %sys
          "SELECT PHI()"
      ::
      :-  %results
          :~  [%action 'SELECT']
              :-  %result-set
                  ~[[%vector ~[[%scalar-0 [~.rd .~1.618033988749895]]]]]
              [%server-time ~2012.5.3]
              [%schema-time ~2012.4.30]
              [%data-time ~2012.4.30]
              [%vector-count 1]
              ==
      ==
::
++  test-inline-select-col-phi
  =|  run=@ud
  %-  exec-0-1
  :*  run
      [~2012.4.30 %db1 init-inl]
      ::
      :+  ~2012.5.3
          %db1
          "FROM inl WHERE id = 1 SELECT id, nrd * PHI()"
      ::
      :-  %results
          :~  [%action 'SELECT']
              :-  %result-set
                  :~  :-  %vector
                          :~  [%id [~.ud 1]]
                              [%scalar-1 [~.rd .~1.618033988749895]]
                              ==
                      ==
              [%server-time ~2012.5.3]
              [%relation-name 'db1.dbo.inl']
              [%schema-time ~2012.4.30]
              [%data-time ~2012.4.30]
              [%vector-count 1]
              ==
      ==
::
++  test-inline-where-phi
  =|  run=@ud
  %-  exec-0-1
  :*  run
      [~2012.4.30 %db1 init-inl]
      ::
      :+  ~2012.5.3
          %db1
          "FROM inl WHERE nrd < PHI() SELECT id"
      ::
      :-  %results
          :~  [%action 'SELECT']
              :-  %result-set
                  :~
                      [%vector ~[[%id [~.ud 1]]]]
                      ==
              [%server-time ~2012.5.3]
              [%relation-name 'db1.dbo.inl']
              [%schema-time ~2012.4.30]
              [%data-time ~2012.4.30]
              [%vector-count 1]
              ==
      ==
::
++  test-inline-select-pi
  =|  run=@ud
  %-  exec-0-1
  :*  run
      [~2012.4.30 %sys "CREATE DATABASE db1"]
      ::
      :+  ~2012.5.3
          %sys
          "SELECT PI()"
      ::
      :-  %results
          :~  [%action 'SELECT']
              :-  %result-set
                  ~[[%vector ~[[%scalar-0 [~.rd .~3.141592653589793]]]]]
              [%server-time ~2012.5.3]
              [%schema-time ~2012.4.30]
              [%data-time ~2012.4.30]
              [%vector-count 1]
              ==
      ==
::
++  test-inline-select-col-pi
  =|  run=@ud
  %-  exec-0-1
  :*  run
      [~2012.4.30 %db1 init-inl]
      ::
      :+  ~2012.5.3
          %db1
          "FROM inl WHERE id = 1 SELECT id, nrd * PI()"
      ::
      :-  %results
          :~  [%action 'SELECT']
              :-  %result-set
                  :~  :-  %vector
                          :~  [%id [~.ud 1]]
                              [%scalar-1 [~.rd .~3.141592653589793]]
                              ==
                      ==
              [%server-time ~2012.5.3]
              [%relation-name 'db1.dbo.inl']
              [%schema-time ~2012.4.30]
              [%data-time ~2012.4.30]
              [%vector-count 1]
              ==
      ==
::
++  test-inline-where-pi
  =|  run=@ud
  %-  exec-0-1
  :*  run
      [~2012.4.30 %db1 init-inl]
      ::
      :+  ~2012.5.3
          %db1
          "FROM inl WHERE nrd < PI() SELECT id"
      ::
      :-  %results
          :~  [%action 'SELECT']
              :-  %result-set
                  :~
                      [%vector ~[[%id [~.ud 1]]]]
                      ==
              [%server-time ~2012.5.3]
              [%relation-name 'db1.dbo.inl']
              [%schema-time ~2012.4.30]
              [%data-time ~2012.4.30]
              [%vector-count 1]
              ==
      ==
::
++  test-inline-select-tau
  =|  run=@ud
  %-  exec-0-1
  :*  run
      [~2012.4.30 %sys "CREATE DATABASE db1"]
      ::
      :+  ~2012.5.3
          %sys
          "SELECT TAU()"
      ::
      :-  %results
          :~  [%action 'SELECT']
              :-  %result-set
                  ~[[%vector ~[[%scalar-0 [~.rd .~6.283185307179586]]]]]
              [%server-time ~2012.5.3]
              [%schema-time ~2012.4.30]
              [%data-time ~2012.4.30]
              [%vector-count 1]
              ==
      ==
::
++  test-inline-select-col-tau
  =|  run=@ud
  %-  exec-0-1
  :*  run
      [~2012.4.30 %db1 init-inl]
      ::
      :+  ~2012.5.3
          %db1
          "FROM inl WHERE id = 1 SELECT id, nrd * TAU()"
      ::
      :-  %results
          :~  [%action 'SELECT']
              :-  %result-set
                  :~  :-  %vector
                          :~  [%id [~.ud 1]]
                              [%scalar-1 [~.rd .~6.283185307179586]]
                              ==
                      ==
              [%server-time ~2012.5.3]
              [%relation-name 'db1.dbo.inl']
              [%schema-time ~2012.4.30]
              [%data-time ~2012.4.30]
              [%vector-count 1]
              ==
      ==
::
++  test-inline-where-tau
  =|  run=@ud
  %-  exec-0-1
  :*  run
      [~2012.4.30 %db1 init-inl]
      ::
      :+  ~2012.5.3
          %db1
          "FROM inl WHERE nrd < TAU() SELECT id"
      ::
      :-  %results
          :~  [%action 'SELECT']
              :-  %result-set
                  :~
                      [%vector ~[[%id [~.ud 1]]]]
                      [%vector ~[[%id [~.ud 2]]]]
                      ==
              [%server-time ~2012.5.3]
              [%relation-name 'db1.dbo.inl']
              [%schema-time ~2012.4.30]
              [%data-time ~2012.4.30]
              [%vector-count 2]
              ==
      ==
::
++  test-inline-select-getutcdate
  =|  run=@ud
  %-  exec-0-1
  :*  run
      [~2012.4.30 %sys "CREATE DATABASE db1"]
      ::
      :+  ~2012.5.3
          %sys
          "SELECT GETUTCDATE()"
      ::
      :-  %results
          :~  [%action 'SELECT']
              :-  %result-set
                  ~[[%vector ~[[%scalar-0 [~.da ~2012.5.3]]]]]
              [%server-time ~2012.5.3]
              [%schema-time ~2012.4.30]
              [%data-time ~2012.4.30]
              [%vector-count 1]
              ==
      ==
::
++  test-inline-select-col-getutcdate
  =|  run=@ud
  %-  exec-0-1
  :*  run
      [~2012.4.30 %db1 init-inl]
      ::
      :+  ~2012.5.3
          %db1
          "FROM inl WHERE id = 1 SELECT id, GETUTCDATE()"
      ::
      :-  %results
          :~  [%action 'SELECT']
              :-  %result-set
                  :~  :-  %vector
                          :~  [%id [~.ud 1]]
                              [%scalar-1 [~.da ~2012.5.3]]
                              ==
                      ==
              [%server-time ~2012.5.3]
              [%relation-name 'db1.dbo.inl']
              [%schema-time ~2012.4.30]
              [%data-time ~2012.4.30]
              [%vector-count 1]
              ==
      ==
::
++  test-inline-where-getutcdate
  =|  run=@ud
  %-  exec-0-1
  :*  run
      [~2012.4.30 %db1 init-inl]
      ::
      :+  ~2012.5.3
          %db1
          "FROM inl WHERE d > GETUTCDATE() SELECT id"
      ::
      :-  %results
          :~  [%action 'SELECT']
              :-  %result-set
                  :~
                      [%vector ~[[%id [~.ud 1]]]]
                      ==
              [%server-time ~2012.5.3]
              [%relation-name 'db1.dbo.inl']
              [%schema-time ~2012.4.30]
              [%data-time ~2012.4.30]
              [%vector-count 1]
              ==
      ==
::
++  test-inline-select-year
  =|  run=@ud
  %-  exec-0-1
  :*  run
      [~2012.4.30 %sys "CREATE DATABASE db1"]
      ::
      :+  ~2012.5.3
          %sys
          "SELECT YEAR(~2026.3.15..10.30.45)"
      ::
      :-  %results
          :~  [%action 'SELECT']
              :-  %result-set
                  ~[[%vector ~[[%scalar-0 [~.ud 2.026]]]]]
              [%server-time ~2012.5.3]
              [%schema-time ~2012.4.30]
              [%data-time ~2012.4.30]
              [%vector-count 1]
              ==
      ==
::
++  test-inline-select-col-year
  =|  run=@ud
  %-  exec-0-1
  :*  run
      [~2012.4.30 %db1 init-inl]
      ::
      :+  ~2012.5.3
          %db1
          "FROM inl WHERE id = 1 SELECT id, YEAR(d)"
      ::
      :-  %results
          :~  [%action 'SELECT']
              :-  %result-set
                  :~  :-  %vector
                          :~  [%id [~.ud 1]]
                              [%scalar-1 [~.ud 2.026]]
                              ==
                      ==
              [%server-time ~2012.5.3]
              [%relation-name 'db1.dbo.inl']
              [%schema-time ~2012.4.30]
              [%data-time ~2012.4.30]
              [%vector-count 1]
              ==
      ==
::
++  test-inline-where-year
  =|  run=@ud
  %-  exec-0-1
  :*  run
      [~2012.4.30 %db1 init-inl]
      ::
      :+  ~2012.5.3
          %db1
          "FROM inl WHERE YEAR(d) = 2026 SELECT id"
      ::
      :-  %results
          :~  [%action 'SELECT']
              :-  %result-set
                  :~
                      [%vector ~[[%id [~.ud 1]]]]
                      ==
              [%server-time ~2012.5.3]
              [%relation-name 'db1.dbo.inl']
              [%schema-time ~2012.4.30]
              [%data-time ~2012.4.30]
              [%vector-count 1]
              ==
      ==
::
++  test-inline-select-month
  =|  run=@ud
  %-  exec-0-1
  :*  run
      [~2012.4.30 %sys "CREATE DATABASE db1"]
      ::
      :+  ~2012.5.3
          %sys
          "SELECT MONTH(~2026.3.15..10.30.45)"
      ::
      :-  %results
          :~  [%action 'SELECT']
              :-  %result-set
                  ~[[%vector ~[[%scalar-0 [~.ud 3]]]]]
              [%server-time ~2012.5.3]
              [%schema-time ~2012.4.30]
              [%data-time ~2012.4.30]
              [%vector-count 1]
              ==
      ==
::
++  test-inline-select-col-month
  =|  run=@ud
  %-  exec-0-1
  :*  run
      [~2012.4.30 %db1 init-inl]
      ::
      :+  ~2012.5.3
          %db1
          "FROM inl WHERE id = 1 SELECT id, MONTH(d)"
      ::
      :-  %results
          :~  [%action 'SELECT']
              :-  %result-set
                  :~  :-  %vector
                          :~  [%id [~.ud 1]]
                              [%scalar-1 [~.ud 3]]
                              ==
                      ==
              [%server-time ~2012.5.3]
              [%relation-name 'db1.dbo.inl']
              [%schema-time ~2012.4.30]
              [%data-time ~2012.4.30]
              [%vector-count 1]
              ==
      ==
::
++  test-inline-where-month
  =|  run=@ud
  %-  exec-0-1
  :*  run
      [~2012.4.30 %db1 init-inl]
      ::
      :+  ~2012.5.3
          %db1
          "FROM inl WHERE MONTH(d) = 3 SELECT id"
      ::
      :-  %results
          :~  [%action 'SELECT']
              :-  %result-set
                  :~
                      [%vector ~[[%id [~.ud 1]]]]
                      ==
              [%server-time ~2012.5.3]
              [%relation-name 'db1.dbo.inl']
              [%schema-time ~2012.4.30]
              [%data-time ~2012.4.30]
              [%vector-count 1]
              ==
      ==
::
++  test-inline-select-day
  =|  run=@ud
  %-  exec-0-1
  :*  run
      [~2012.4.30 %sys "CREATE DATABASE db1"]
      ::
      :+  ~2012.5.3
          %sys
          "SELECT DAY(~2026.3.15..10.30.45)"
      ::
      :-  %results
          :~  [%action 'SELECT']
              :-  %result-set
                  ~[[%vector ~[[%scalar-0 [~.ud 15]]]]]
              [%server-time ~2012.5.3]
              [%schema-time ~2012.4.30]
              [%data-time ~2012.4.30]
              [%vector-count 1]
              ==
      ==
::
++  test-inline-select-col-day
  =|  run=@ud
  %-  exec-0-1
  :*  run
      [~2012.4.30 %db1 init-inl]
      ::
      :+  ~2012.5.3
          %db1
          "FROM inl WHERE id = 1 SELECT id, DAY(d)"
      ::
      :-  %results
          :~  [%action 'SELECT']
              :-  %result-set
                  :~  :-  %vector
                          :~  [%id [~.ud 1]]
                              [%scalar-1 [~.ud 15]]
                              ==
                      ==
              [%server-time ~2012.5.3]
              [%relation-name 'db1.dbo.inl']
              [%schema-time ~2012.4.30]
              [%data-time ~2012.4.30]
              [%vector-count 1]
              ==
      ==
::
++  test-inline-where-day
  =|  run=@ud
  %-  exec-0-1
  :*  run
      [~2012.4.30 %db1 init-inl]
      ::
      :+  ~2012.5.3
          %db1
          "FROM inl WHERE DAY(d) = 15 SELECT id"
      ::
      :-  %results
          :~  [%action 'SELECT']
              :-  %result-set
                  :~
                      [%vector ~[[%id [~.ud 1]]]]
                      ==
              [%server-time ~2012.5.3]
              [%relation-name 'db1.dbo.inl']
              [%schema-time ~2012.4.30]
              [%data-time ~2012.4.30]
              [%vector-count 1]
              ==
      ==
::
++  test-inline-select-hour
  =|  run=@ud
  %-  exec-0-1
  :*  run
      [~2012.4.30 %sys "CREATE DATABASE db1"]
      ::
      :+  ~2012.5.3
          %sys
          "SELECT HOUR(~2026.3.15..10.30.45)"
      ::
      :-  %results
          :~  [%action 'SELECT']
              :-  %result-set
                  ~[[%vector ~[[%scalar-0 [~.ud 10]]]]]
              [%server-time ~2012.5.3]
              [%schema-time ~2012.4.30]
              [%data-time ~2012.4.30]
              [%vector-count 1]
              ==
      ==
::
++  test-inline-select-col-hour
  =|  run=@ud
  %-  exec-0-1
  :*  run
      [~2012.4.30 %db1 init-inl]
      ::
      :+  ~2012.5.3
          %db1
          "FROM inl WHERE id = 1 SELECT id, HOUR(d)"
      ::
      :-  %results
          :~  [%action 'SELECT']
              :-  %result-set
                  :~  :-  %vector
                          :~  [%id [~.ud 1]]
                              [%scalar-1 [~.ud 10]]
                              ==
                      ==
              [%server-time ~2012.5.3]
              [%relation-name 'db1.dbo.inl']
              [%schema-time ~2012.4.30]
              [%data-time ~2012.4.30]
              [%vector-count 1]
              ==
      ==
::
++  test-inline-where-hour
  =|  run=@ud
  %-  exec-0-1
  :*  run
      [~2012.4.30 %db1 init-inl]
      ::
      :+  ~2012.5.3
          %db1
          "FROM inl WHERE HOUR(d) = 10 SELECT id"
      ::
      :-  %results
          :~  [%action 'SELECT']
              :-  %result-set
                  :~
                      [%vector ~[[%id [~.ud 1]]]]
                      ==
              [%server-time ~2012.5.3]
              [%relation-name 'db1.dbo.inl']
              [%schema-time ~2012.4.30]
              [%data-time ~2012.4.30]
              [%vector-count 1]
              ==
      ==
::
++  test-inline-select-minute
  =|  run=@ud
  %-  exec-0-1
  :*  run
      [~2012.4.30 %sys "CREATE DATABASE db1"]
      ::
      :+  ~2012.5.3
          %sys
          "SELECT MINUTE(~2026.3.15..10.30.45)"
      ::
      :-  %results
          :~  [%action 'SELECT']
              :-  %result-set
                  ~[[%vector ~[[%scalar-0 [~.ud 30]]]]]
              [%server-time ~2012.5.3]
              [%schema-time ~2012.4.30]
              [%data-time ~2012.4.30]
              [%vector-count 1]
              ==
      ==
::
++  test-inline-select-col-minute
  =|  run=@ud
  %-  exec-0-1
  :*  run
      [~2012.4.30 %db1 init-inl]
      ::
      :+  ~2012.5.3
          %db1
          "FROM inl WHERE id = 1 SELECT id, MINUTE(d)"
      ::
      :-  %results
          :~  [%action 'SELECT']
              :-  %result-set
                  :~  :-  %vector
                          :~  [%id [~.ud 1]]
                              [%scalar-1 [~.ud 30]]
                              ==
                      ==
              [%server-time ~2012.5.3]
              [%relation-name 'db1.dbo.inl']
              [%schema-time ~2012.4.30]
              [%data-time ~2012.4.30]
              [%vector-count 1]
              ==
      ==
::
++  test-inline-where-minute
  =|  run=@ud
  %-  exec-0-1
  :*  run
      [~2012.4.30 %db1 init-inl]
      ::
      :+  ~2012.5.3
          %db1
          "FROM inl WHERE MINUTE(d) = 30 SELECT id"
      ::
      :-  %results
          :~  [%action 'SELECT']
              :-  %result-set
                  :~
                      [%vector ~[[%id [~.ud 1]]]]
                      ==
              [%server-time ~2012.5.3]
              [%relation-name 'db1.dbo.inl']
              [%schema-time ~2012.4.30]
              [%data-time ~2012.4.30]
              [%vector-count 1]
              ==
      ==
::
++  test-inline-select-second
  =|  run=@ud
  %-  exec-0-1
  :*  run
      [~2012.4.30 %sys "CREATE DATABASE db1"]
      ::
      :+  ~2012.5.3
          %sys
          "SELECT SECOND(~2026.3.15..10.30.45)"
      ::
      :-  %results
          :~  [%action 'SELECT']
              :-  %result-set
                  ~[[%vector ~[[%scalar-0 [~.ud 45]]]]]
              [%server-time ~2012.5.3]
              [%schema-time ~2012.4.30]
              [%data-time ~2012.4.30]
              [%vector-count 1]
              ==
      ==
::
++  test-inline-select-col-second
  =|  run=@ud
  %-  exec-0-1
  :*  run
      [~2012.4.30 %db1 init-inl]
      ::
      :+  ~2012.5.3
          %db1
          "FROM inl WHERE id = 1 SELECT id, SECOND(d)"
      ::
      :-  %results
          :~  [%action 'SELECT']
              :-  %result-set
                  :~  :-  %vector
                          :~  [%id [~.ud 1]]
                              [%scalar-1 [~.ud 45]]
                              ==
                      ==
              [%server-time ~2012.5.3]
              [%relation-name 'db1.dbo.inl']
              [%schema-time ~2012.4.30]
              [%data-time ~2012.4.30]
              [%vector-count 1]
              ==
      ==
::
++  test-inline-where-second
  =|  run=@ud
  %-  exec-0-1
  :*  run
      [~2012.4.30 %db1 init-inl]
      ::
      :+  ~2012.5.3
          %db1
          "FROM inl WHERE SECOND(d) = 45 SELECT id"
      ::
      :-  %results
          :~  [%action 'SELECT']
              :-  %result-set
                  :~
                      [%vector ~[[%id [~.ud 1]]]]
                      ==
              [%server-time ~2012.5.3]
              [%relation-name 'db1.dbo.inl']
              [%schema-time ~2012.4.30]
              [%data-time ~2012.4.30]
              [%vector-count 1]
              ==
      ==
::
++  test-inline-select-add-time
  =|  run=@ud
  %-  exec-0-1
  :*  run
      [~2012.4.30 %sys "CREATE DATABASE db1"]
      ::
      :+  ~2012.5.3
          %sys
          "SELECT ADD-TIME(~2026.3.15..10.30.45, ~d1)"
      ::
      :-  %results
          :~  [%action 'SELECT']
              :-  %result-set
                  ~[[%vector ~[[%scalar-0 [~.da ~2026.3.16..10.30.45]]]]]
              [%server-time ~2012.5.3]
              [%schema-time ~2012.4.30]
              [%data-time ~2012.4.30]
              [%vector-count 1]
              ==
      ==
::
++  test-inline-select-col-add-time
  =|  run=@ud
  %-  exec-0-1
  :*  run
      [~2012.4.30 %db1 init-inl]
      ::
      :+  ~2012.5.3
          %db1
          "FROM inl WHERE id = 1 SELECT id, ADD-TIME(d, dr)"
      ::
      :-  %results
          :~  [%action 'SELECT']
              :-  %result-set
                  :~  :-  %vector
                          :~  [%id [~.ud 1]]
                              [%scalar-1 [~.da ~2026.3.16..10.30.45]]
                              ==
                      ==
              [%server-time ~2012.5.3]
              [%relation-name 'db1.dbo.inl']
              [%schema-time ~2012.4.30]
              [%data-time ~2012.4.30]
              [%vector-count 1]
              ==
      ==
::
++  test-inline-where-add-time
  =|  run=@ud
  %-  exec-0-1
  :*  run
      [~2012.4.30 %db1 init-inl]
      ::
      :+  ~2012.5.3
          %db1
          "FROM inl WHERE ADD-TIME(d, dr) = ~2026.3.16..10.30.45 SELECT id"
      ::
      :-  %results
          :~  [%action 'SELECT']
              :-  %result-set
                  :~
                      [%vector ~[[%id [~.ud 1]]]]
                      ==
              [%server-time ~2012.5.3]
              [%relation-name 'db1.dbo.inl']
              [%schema-time ~2012.4.30]
              [%data-time ~2012.4.30]
              [%vector-count 1]
              ==
      ==
::
++  test-inline-select-subtract-time
  =|  run=@ud
  %-  exec-0-1
  :*  run
      [~2012.4.30 %sys "CREATE DATABASE db1"]
      ::
      :+  ~2012.5.3
          %sys
          "SELECT SUBTRACT-TIME(~2026.3.15..10.30.45, ~d1)"
      ::
      :-  %results
          :~  [%action 'SELECT']
              :-  %result-set
                  ~[[%vector ~[[%scalar-0 [~.da ~2026.3.14..10.30.45]]]]]
              [%server-time ~2012.5.3]
              [%schema-time ~2012.4.30]
              [%data-time ~2012.4.30]
              [%vector-count 1]
              ==
      ==
::
++  test-inline-select-col-subtract-time
  =|  run=@ud
  %-  exec-0-1
  :*  run
      [~2012.4.30 %db1 init-inl]
      ::
      :+  ~2012.5.3
          %db1
          "FROM inl WHERE id = 1 SELECT id, SUBTRACT-TIME(d, dr)"
      ::
      :-  %results
          :~  [%action 'SELECT']
              :-  %result-set
                  :~  :-  %vector
                          :~  [%id [~.ud 1]]
                              [%scalar-1 [~.da ~2026.3.14..10.30.45]]
                              ==
                      ==
              [%server-time ~2012.5.3]
              [%relation-name 'db1.dbo.inl']
              [%schema-time ~2012.4.30]
              [%data-time ~2012.4.30]
              [%vector-count 1]
              ==
      ==
::
++  test-inline-where-subtract-time
  =|  run=@ud
  %-  exec-0-1
  :*  run
      [~2012.4.30 %db1 init-inl]
      ::
      :+  ~2012.5.3
          %db1
          "FROM inl WHERE SUBTRACT-TIME(d, dr) = ~2026.3.14..10.30.45 ".
          "SELECT id"
      ::
      :-  %results
          :~  [%action 'SELECT']
              :-  %result-set
                  :~
                      [%vector ~[[%id [~.ud 1]]]]
                      ==
              [%server-time ~2012.5.3]
              [%relation-name 'db1.dbo.inl']
              [%schema-time ~2012.4.30]
              [%data-time ~2012.4.30]
              [%vector-count 1]
              ==
      ==
::
++  test-inline-select-concat
  =|  run=@ud
  %-  exec-0-1
  :*  run
      [~2012.4.30 %sys "CREATE DATABASE db1"]
      ::
      :+  ~2012.5.3
          %sys
          "SELECT CONCAT('hello', 'world')"
      ::
      :-  %results
          :~  [%action 'SELECT']
              :-  %result-set
                  ~[[%vector ~[[%scalar-0 [~.t 'helloworld']]]]]
              [%server-time ~2012.5.3]
              [%schema-time ~2012.4.30]
              [%data-time ~2012.4.30]
              [%vector-count 1]
              ==
      ==
::
++  test-inline-select-col-concat
  =|  run=@ud
  %-  exec-0-1
  :*  run
      [~2012.4.30 %db1 init-inl]
      ::
      :+  ~2012.5.3
          %db1
          "FROM inl WHERE id = 1 SELECT id, CONCAT(t, 'world')"
      ::
      :-  %results
          :~  [%action 'SELECT']
              :-  %result-set
                  :~  :-  %vector
                          :~  [%id [~.ud 1]]
                              [%scalar-1 [~.t 'helloworld']]
                              ==
                      ==
              [%server-time ~2012.5.3]
              [%relation-name 'db1.dbo.inl']
              [%schema-time ~2012.4.30]
              [%data-time ~2012.4.30]
              [%vector-count 1]
              ==
      ==
::
++  test-inline-where-concat
  =|  run=@ud
  %-  exec-0-1
  :*  run
      [~2012.4.30 %db1 init-inl]
      ::
      :+  ~2012.5.3
          %db1
          "FROM inl WHERE CONCAT(t, 'world') = 'helloworld' SELECT id"
      ::
      :-  %results
          :~  [%action 'SELECT']
              :-  %result-set
                  :~
                      [%vector ~[[%id [~.ud 1]]]]
                      ==
              [%server-time ~2012.5.3]
              [%relation-name 'db1.dbo.inl']
              [%schema-time ~2012.4.30]
              [%data-time ~2012.4.30]
              [%vector-count 1]
              ==
      ==
::
++  test-inline-select-left
  =|  run=@ud
  %-  exec-0-1
  :*  run
      [~2012.4.30 %sys "CREATE DATABASE db1"]
      ::
      :+  ~2012.5.3
          %sys
          "SELECT LEFT('hello', 3)"
      ::
      :-  %results
          :~  [%action 'SELECT']
              :-  %result-set
                  ~[[%vector ~[[%scalar-0 [~.t 'hel']]]]]
              [%server-time ~2012.5.3]
              [%schema-time ~2012.4.30]
              [%data-time ~2012.4.30]
              [%vector-count 1]
              ==
      ==
::
++  test-inline-select-col-left
  =|  run=@ud
  %-  exec-0-1
  :*  run
      [~2012.4.30 %db1 init-inl]
      ::
      :+  ~2012.5.3
          %db1
          "FROM inl WHERE id = 1 SELECT id, LEFT(t, 3)"
      ::
      :-  %results
          :~  [%action 'SELECT']
              :-  %result-set
                  :~  :-  %vector
                          :~  [%id [~.ud 1]]
                              [%scalar-1 [~.t 'hel']]
                              ==
                      ==
              [%server-time ~2012.5.3]
              [%relation-name 'db1.dbo.inl']
              [%schema-time ~2012.4.30]
              [%data-time ~2012.4.30]
              [%vector-count 1]
              ==
      ==
::
++  test-inline-where-left
  =|  run=@ud
  %-  exec-0-1
  :*  run
      [~2012.4.30 %db1 init-inl]
      ::
      :+  ~2012.5.3
          %db1
          "FROM inl WHERE LEFT(t, 3) = 'hel' SELECT id"
      ::
      :-  %results
          :~  [%action 'SELECT']
              :-  %result-set
                  :~
                      [%vector ~[[%id [~.ud 1]]]]
                      ==
              [%server-time ~2012.5.3]
              [%relation-name 'db1.dbo.inl']
              [%schema-time ~2012.4.30]
              [%data-time ~2012.4.30]
              [%vector-count 1]
              ==
      ==
::
++  test-inline-select-len
  =|  run=@ud
  %-  exec-0-1
  :*  run
      [~2012.4.30 %sys "CREATE DATABASE db1"]
      ::
      :+  ~2012.5.3
          %sys
          "SELECT LEN('hello')"
      ::
      :-  %results
          :~  [%action 'SELECT']
              :-  %result-set
                  ~[[%vector ~[[%scalar-0 [~.ud 5]]]]]
              [%server-time ~2012.5.3]
              [%schema-time ~2012.4.30]
              [%data-time ~2012.4.30]
              [%vector-count 1]
              ==
      ==
::
++  test-inline-select-col-len
  =|  run=@ud
  %-  exec-0-1
  :*  run
      [~2012.4.30 %db1 init-inl]
      ::
      :+  ~2012.5.3
          %db1
          "FROM inl WHERE id = 1 SELECT id, LEN(tpad)"
      ::
      :-  %results
          :~  [%action 'SELECT']
              :-  %result-set
                  :~  :-  %vector
                          :~  [%id [~.ud 1]]
                              [%scalar-1 [~.ud 9]]
                              ==
                      ==
              [%server-time ~2012.5.3]
              [%relation-name 'db1.dbo.inl']
              [%schema-time ~2012.4.30]
              [%data-time ~2012.4.30]
              [%vector-count 1]
              ==
      ==
::
++  test-inline-where-len
  =|  run=@ud
  %-  exec-0-1
  :*  run
      [~2012.4.30 %db1 init-inl]
      ::
      :+  ~2012.5.3
          %db1
          "FROM inl WHERE LEN(tpad) = 9 SELECT id"
      ::
      :-  %results
          :~  [%action 'SELECT']
              :-  %result-set
                  :~
                      [%vector ~[[%id [~.ud 1]]]]
                      ==
              [%server-time ~2012.5.3]
              [%relation-name 'db1.dbo.inl']
              [%schema-time ~2012.4.30]
              [%data-time ~2012.4.30]
              [%vector-count 1]
              ==
      ==
::
++  test-inline-select-lower
  =|  run=@ud
  %-  exec-0-1
  :*  run
      [~2012.4.30 %sys "CREATE DATABASE db1"]
      ::
      :+  ~2012.5.3
          %sys
          "SELECT LOWER('HELLO')"
      ::
      :-  %results
          :~  [%action 'SELECT']
              :-  %result-set
                  ~[[%vector ~[[%scalar-0 [~.t 'hello']]]]]
              [%server-time ~2012.5.3]
              [%schema-time ~2012.4.30]
              [%data-time ~2012.4.30]
              [%vector-count 1]
              ==
      ==
::
++  test-inline-select-col-lower
  =|  run=@ud
  %-  exec-0-1
  :*  run
      [~2012.4.30 %db1 init-inl]
      ::
      :+  ~2012.5.3
          %db1
          "FROM inl WHERE id = 1 SELECT id, LOWER(t)"
      ::
      :-  %results
          :~  [%action 'SELECT']
              :-  %result-set
                  :~  :-  %vector
                          :~  [%id [~.ud 1]]
                              [%scalar-1 [~.t 'hello']]
                              ==
                      ==
              [%server-time ~2012.5.3]
              [%relation-name 'db1.dbo.inl']
              [%schema-time ~2012.4.30]
              [%data-time ~2012.4.30]
              [%vector-count 1]
              ==
      ==
::
++  test-inline-where-lower
  =|  run=@ud
  %-  exec-0-1
  :*  run
      [~2012.4.30 %db1 init-inl]
      ::
      :+  ~2012.5.3
          %db1
          "FROM inl WHERE LOWER(t) = 'world' SELECT id"
      ::
      :-  %results
          :~  [%action 'SELECT']
              :-  %result-set
                  :~
                      [%vector ~[[%id [~.ud 2]]]]
                      ==
              [%server-time ~2012.5.3]
              [%relation-name 'db1.dbo.inl']
              [%schema-time ~2012.4.30]
              [%data-time ~2012.4.30]
              [%vector-count 1]
              ==
      ==
::
++  test-inline-select-ltrim
  =|  run=@ud
  %-  exec-0-1
  :*  run
      [~2012.4.30 %sys "CREATE DATABASE db1"]
      ::
      :+  ~2012.5.3
          %sys
          "SELECT LTRIM('  hello  ')"
      ::
      :-  %results
          :~  [%action 'SELECT']
              :-  %result-set
                  ~[[%vector ~[[%scalar-0 [~.t 'hello  ']]]]]
              [%server-time ~2012.5.3]
              [%schema-time ~2012.4.30]
              [%data-time ~2012.4.30]
              [%vector-count 1]
              ==
      ==
::
++  test-inline-select-col-ltrim
  =|  run=@ud
  %-  exec-0-1
  :*  run
      [~2012.4.30 %db1 init-inl]
      ::
      :+  ~2012.5.3
          %db1
          "FROM inl WHERE id = 1 SELECT id, LTRIM(tpad)"
      ::
      :-  %results
          :~  [%action 'SELECT']
              :-  %result-set
                  :~  :-  %vector
                          :~  [%id [~.ud 1]]
                              [%scalar-1 [~.t 'hello  ']]
                              ==
                      ==
              [%server-time ~2012.5.3]
              [%relation-name 'db1.dbo.inl']
              [%schema-time ~2012.4.30]
              [%data-time ~2012.4.30]
              [%vector-count 1]
              ==
      ==
::
++  test-inline-where-ltrim
  =|  run=@ud
  %-  exec-0-1
  :*  run
      [~2012.4.30 %db1 init-inl]
      ::
      :+  ~2012.5.3
          %db1
          "FROM inl WHERE LTRIM(tpad) = 'hello  ' SELECT id"
      ::
      :-  %results
          :~  [%action 'SELECT']
              :-  %result-set
                  :~
                      [%vector ~[[%id [~.ud 1]]]]
                      ==
              [%server-time ~2012.5.3]
              [%relation-name 'db1.dbo.inl']
              [%schema-time ~2012.4.30]
              [%data-time ~2012.4.30]
              [%vector-count 1]
              ==
      ==
::
++  test-inline-select-patindex
  =|  run=@ud
  %-  exec-0-1
  :*  run
      [~2012.4.30 %sys "CREATE DATABASE db1"]
      ::
      :+  ~2012.5.3
          %sys
          "SELECT PATINDEX('hello', 'ell')"
      ::
      :-  %results
          :~  [%action 'SELECT']
              :-  %result-set
                  ~[[%vector ~[[%scalar-0 [~.ud 2]]]]]
              [%server-time ~2012.5.3]
              [%schema-time ~2012.4.30]
              [%data-time ~2012.4.30]
              [%vector-count 1]
              ==
      ==
::
++  test-inline-select-col-patindex
  =|  run=@ud
  %-  exec-0-1
  :*  run
      [~2012.4.30 %db1 init-inl]
      ::
      :+  ~2012.5.3
          %db1
          "FROM inl WHERE id = 1 SELECT id, PATINDEX(t, 'ell')"
      ::
      :-  %results
          :~  [%action 'SELECT']
              :-  %result-set
                  :~  :-  %vector
                          :~  [%id [~.ud 1]]
                              [%scalar-1 [~.ud 2]]
                              ==
                      ==
              [%server-time ~2012.5.3]
              [%relation-name 'db1.dbo.inl']
              [%schema-time ~2012.4.30]
              [%data-time ~2012.4.30]
              [%vector-count 1]
              ==
      ==
::
++  test-inline-where-patindex
  =|  run=@ud
  %-  exec-0-1
  :*  run
      [~2012.4.30 %db1 init-inl]
      ::
      :+  ~2012.5.3
          %db1
          "FROM inl WHERE PATINDEX(t, 'ell') = 2 SELECT id"
      ::
      :-  %results
          :~  [%action 'SELECT']
              :-  %result-set
                  :~
                      [%vector ~[[%id [~.ud 1]]]]
                      ==
              [%server-time ~2012.5.3]
              [%relation-name 'db1.dbo.inl']
              [%schema-time ~2012.4.30]
              [%data-time ~2012.4.30]
              [%vector-count 1]
              ==
      ==
::
++  test-inline-select-quotestring
  =|  run=@ud
  %-  exec-0-1
  :*  run
      [~2012.4.30 %sys "CREATE DATABASE db1"]
      ::
      :+  ~2012.5.3
          %sys
          "SELECT QUOTESTRING('hello')"
      ::
      :-  %results
          :~  [%action 'SELECT']
              :-  %result-set
                  ~[[%vector ~[[%scalar-0 [~.t '[hello]']]]]]
              [%server-time ~2012.5.3]
              [%schema-time ~2012.4.30]
              [%data-time ~2012.4.30]
              [%vector-count 1]
              ==
      ==
::
++  test-inline-select-col-quotestring
  =|  run=@ud
  %-  exec-0-1
  :*  run
      [~2012.4.30 %db1 init-inl]
      ::
      :+  ~2012.5.3
          %db1
          "FROM inl WHERE id = 1 SELECT id, QUOTESTRING(t)"
      ::
      :-  %results
          :~  [%action 'SELECT']
              :-  %result-set
                  :~  :-  %vector
                          :~  [%id [~.ud 1]]
                              [%scalar-1 [~.t '[hello]']]
                              ==
                      ==
              [%server-time ~2012.5.3]
              [%relation-name 'db1.dbo.inl']
              [%schema-time ~2012.4.30]
              [%data-time ~2012.4.30]
              [%vector-count 1]
              ==
      ==
::
++  test-inline-where-quotestring
  =|  run=@ud
  %-  exec-0-1
  :*  run
      [~2012.4.30 %db1 init-inl]
      ::
      :+  ~2012.5.3
          %db1
          "FROM inl WHERE QUOTESTRING(t) = '[hello]' SELECT id"
      ::
      :-  %results
          :~  [%action 'SELECT']
              :-  %result-set
                  :~
                      [%vector ~[[%id [~.ud 1]]]]
                      ==
              [%server-time ~2012.5.3]
              [%relation-name 'db1.dbo.inl']
              [%schema-time ~2012.4.30]
              [%data-time ~2012.4.30]
              [%vector-count 1]
              ==
      ==
::
++  test-inline-select-replace
  =|  run=@ud
  %-  exec-0-1
  :*  run
      [~2012.4.30 %sys "CREATE DATABASE db1"]
      ::
      :+  ~2012.5.3
          %sys
          "SELECT REPLACE('hello world', 'world', 'there')"
      ::
      :-  %results
          :~  [%action 'SELECT']
              :-  %result-set
                  ~[[%vector ~[[%scalar-0 [~.t 'hello there']]]]]
              [%server-time ~2012.5.3]
              [%schema-time ~2012.4.30]
              [%data-time ~2012.4.30]
              [%vector-count 1]
              ==
      ==
::
++  test-inline-select-col-replace
  =|  run=@ud
  %-  exec-0-1
  :*  run
      [~2012.4.30 %db1 init-inl]
      ::
      :+  ~2012.5.3
          %db1
          "FROM inl WHERE id = 1 SELECT id, REPLACE(t, 'ell', 'ELL')"
      ::
      :-  %results
          :~  [%action 'SELECT']
              :-  %result-set
                  :~  :-  %vector
                          :~  [%id [~.ud 1]]
                              [%scalar-1 [~.t 'hELLo']]
                              ==
                      ==
              [%server-time ~2012.5.3]
              [%relation-name 'db1.dbo.inl']
              [%schema-time ~2012.4.30]
              [%data-time ~2012.4.30]
              [%vector-count 1]
              ==
      ==
::
++  test-inline-where-replace
  =|  run=@ud
  %-  exec-0-1
  :*  run
      [~2012.4.30 %db1 init-inl]
      ::
      :+  ~2012.5.3
          %db1
          "FROM inl WHERE REPLACE(t, 'ell', 'ELL') = 'hELLo' SELECT id"
      ::
      :-  %results
          :~  [%action 'SELECT']
              :-  %result-set
                  :~
                      [%vector ~[[%id [~.ud 1]]]]
                      ==
              [%server-time ~2012.5.3]
              [%relation-name 'db1.dbo.inl']
              [%schema-time ~2012.4.30]
              [%data-time ~2012.4.30]
              [%vector-count 1]
              ==
      ==
::
++  test-inline-select-replicate
  =|  run=@ud
  %-  exec-0-1
  :*  run
      [~2012.4.30 %sys "CREATE DATABASE db1"]
      ::
      :+  ~2012.5.3
          %sys
          "SELECT REPLICATE('ha', 2)"
      ::
      :-  %results
          :~  [%action 'SELECT']
              :-  %result-set
                  ~[[%vector ~[[%scalar-0 [~.t 'haha']]]]]
              [%server-time ~2012.5.3]
              [%schema-time ~2012.4.30]
              [%data-time ~2012.4.30]
              [%vector-count 1]
              ==
      ==
::
++  test-inline-select-col-replicate
  =|  run=@ud
  %-  exec-0-1
  :*  run
      [~2012.4.30 %db1 init-inl]
      ::
      :+  ~2012.5.3
          %db1
          "FROM inl WHERE id = 1 SELECT id, REPLICATE(t, 2)"
      ::
      :-  %results
          :~  [%action 'SELECT']
              :-  %result-set
                  :~  :-  %vector
                          :~  [%id [~.ud 1]]
                              [%scalar-1 [~.t 'hellohello']]
                              ==
                      ==
              [%server-time ~2012.5.3]
              [%relation-name 'db1.dbo.inl']
              [%schema-time ~2012.4.30]
              [%data-time ~2012.4.30]
              [%vector-count 1]
              ==
      ==
::
++  test-inline-where-replicate
  =|  run=@ud
  %-  exec-0-1
  :*  run
      [~2012.4.30 %db1 init-inl]
      ::
      :+  ~2012.5.3
          %db1
          "FROM inl WHERE REPLICATE(t, 2) = 'hellohello' SELECT id"
      ::
      :-  %results
          :~  [%action 'SELECT']
              :-  %result-set
                  :~
                      [%vector ~[[%id [~.ud 1]]]]
                      ==
              [%server-time ~2012.5.3]
              [%relation-name 'db1.dbo.inl']
              [%schema-time ~2012.4.30]
              [%data-time ~2012.4.30]
              [%vector-count 1]
              ==
      ==
::
++  test-inline-select-reverse
  =|  run=@ud
  %-  exec-0-1
  :*  run
      [~2012.4.30 %sys "CREATE DATABASE db1"]
      ::
      :+  ~2012.5.3
          %sys
          "SELECT REVERSE('hello')"
      ::
      :-  %results
          :~  [%action 'SELECT']
              :-  %result-set
                  ~[[%vector ~[[%scalar-0 [~.t 'olleh']]]]]
              [%server-time ~2012.5.3]
              [%schema-time ~2012.4.30]
              [%data-time ~2012.4.30]
              [%vector-count 1]
              ==
      ==
::
++  test-inline-select-col-reverse
  =|  run=@ud
  %-  exec-0-1
  :*  run
      [~2012.4.30 %db1 init-inl]
      ::
      :+  ~2012.5.3
          %db1
          "FROM inl WHERE id = 1 SELECT id, REVERSE(t)"
      ::
      :-  %results
          :~  [%action 'SELECT']
              :-  %result-set
                  :~  :-  %vector
                          :~  [%id [~.ud 1]]
                              [%scalar-1 [~.t 'olleh']]
                              ==
                      ==
              [%server-time ~2012.5.3]
              [%relation-name 'db1.dbo.inl']
              [%schema-time ~2012.4.30]
              [%data-time ~2012.4.30]
              [%vector-count 1]
              ==
      ==
::
++  test-inline-where-reverse
  =|  run=@ud
  %-  exec-0-1
  :*  run
      [~2012.4.30 %db1 init-inl]
      ::
      :+  ~2012.5.3
          %db1
          "FROM inl WHERE REVERSE(t) = 'olleh' SELECT id"
      ::
      :-  %results
          :~  [%action 'SELECT']
              :-  %result-set
                  :~
                      [%vector ~[[%id [~.ud 1]]]]
                      ==
              [%server-time ~2012.5.3]
              [%relation-name 'db1.dbo.inl']
              [%schema-time ~2012.4.30]
              [%data-time ~2012.4.30]
              [%vector-count 1]
              ==
      ==
::
++  test-inline-select-right
  =|  run=@ud
  %-  exec-0-1
  :*  run
      [~2012.4.30 %sys "CREATE DATABASE db1"]
      ::
      :+  ~2012.5.3
          %sys
          "SELECT RIGHT('hello', 3)"
      ::
      :-  %results
          :~  [%action 'SELECT']
              :-  %result-set
                  ~[[%vector ~[[%scalar-0 [~.t 'llo']]]]]
              [%server-time ~2012.5.3]
              [%schema-time ~2012.4.30]
              [%data-time ~2012.4.30]
              [%vector-count 1]
              ==
      ==
::
++  test-inline-select-col-right
  =|  run=@ud
  %-  exec-0-1
  :*  run
      [~2012.4.30 %db1 init-inl]
      ::
      :+  ~2012.5.3
          %db1
          "FROM inl WHERE id = 1 SELECT id, RIGHT(t, 3)"
      ::
      :-  %results
          :~  [%action 'SELECT']
              :-  %result-set
                  :~  :-  %vector
                          :~  [%id [~.ud 1]]
                              [%scalar-1 [~.t 'llo']]
                              ==
                      ==
              [%server-time ~2012.5.3]
              [%relation-name 'db1.dbo.inl']
              [%schema-time ~2012.4.30]
              [%data-time ~2012.4.30]
              [%vector-count 1]
              ==
      ==
::
++  test-inline-where-right
  =|  run=@ud
  %-  exec-0-1
  :*  run
      [~2012.4.30 %db1 init-inl]
      ::
      :+  ~2012.5.3
          %db1
          "FROM inl WHERE RIGHT(t, 3) = 'llo' SELECT id"
      ::
      :-  %results
          :~  [%action 'SELECT']
              :-  %result-set
                  :~
                      [%vector ~[[%id [~.ud 1]]]]
                      ==
              [%server-time ~2012.5.3]
              [%relation-name 'db1.dbo.inl']
              [%schema-time ~2012.4.30]
              [%data-time ~2012.4.30]
              [%vector-count 1]
              ==
      ==
::
++  test-inline-select-rtrim
  =|  run=@ud
  %-  exec-0-1
  :*  run
      [~2012.4.30 %sys "CREATE DATABASE db1"]
      ::
      :+  ~2012.5.3
          %sys
          "SELECT RTRIM('  hello  ')"
      ::
      :-  %results
          :~  [%action 'SELECT']
              :-  %result-set
                  ~[[%vector ~[[%scalar-0 [~.t '  hello']]]]]
              [%server-time ~2012.5.3]
              [%schema-time ~2012.4.30]
              [%data-time ~2012.4.30]
              [%vector-count 1]
              ==
      ==
::
++  test-inline-select-col-rtrim
  =|  run=@ud
  %-  exec-0-1
  :*  run
      [~2012.4.30 %db1 init-inl]
      ::
      :+  ~2012.5.3
          %db1
          "FROM inl WHERE id = 1 SELECT id, RTRIM(tpad)"
      ::
      :-  %results
          :~  [%action 'SELECT']
              :-  %result-set
                  :~  :-  %vector
                          :~  [%id [~.ud 1]]
                              [%scalar-1 [~.t '  hello']]
                              ==
                      ==
              [%server-time ~2012.5.3]
              [%relation-name 'db1.dbo.inl']
              [%schema-time ~2012.4.30]
              [%data-time ~2012.4.30]
              [%vector-count 1]
              ==
      ==
::
++  test-inline-where-rtrim
  =|  run=@ud
  %-  exec-0-1
  :*  run
      [~2012.4.30 %db1 init-inl]
      ::
      :+  ~2012.5.3
          %db1
          "FROM inl WHERE RTRIM(tpad) = '  hello' SELECT id"
      ::
      :-  %results
          :~  [%action 'SELECT']
              :-  %result-set
                  :~
                      [%vector ~[[%id [~.ud 1]]]]
                      ==
              [%server-time ~2012.5.3]
              [%relation-name 'db1.dbo.inl']
              [%schema-time ~2012.4.30]
              [%data-time ~2012.4.30]
              [%vector-count 1]
              ==
      ==
::
++  test-inline-select-string
  =|  run=@ud
  %-  exec-0-1
  :*  run
      [~2012.4.30 %sys "CREATE DATABASE db1"]
      ::
      :+  ~2012.5.3
          %sys
          "SELECT STRING(42)"
      ::
      :-  %results
          :~  [%action 'SELECT']
              :-  %result-set
                  ~[[%vector ~[[%scalar-0 [~.t '42']]]]]
              [%server-time ~2012.5.3]
              [%schema-time ~2012.4.30]
              [%data-time ~2012.4.30]
              [%vector-count 1]
              ==
      ==
::
++  test-inline-select-col-string
  =|  run=@ud
  %-  exec-0-1
  :*  run
      [~2012.4.30 %db1 init-inl]
      ::
      :+  ~2012.5.3
          %db1
          "FROM inl WHERE id = 1 SELECT id, STRING(nud)"
      ::
      :-  %results
          :~  [%action 'SELECT']
              :-  %result-set
                  :~  :-  %vector
                          :~  [%id [~.ud 1]]
                              [%scalar-1 [~.t '5']]
                              ==
                      ==
              [%server-time ~2012.5.3]
              [%relation-name 'db1.dbo.inl']
              [%schema-time ~2012.4.30]
              [%data-time ~2012.4.30]
              [%vector-count 1]
              ==
      ==
::
++  test-inline-where-string
  =|  run=@ud
  %-  exec-0-1
  :*  run
      [~2012.4.30 %db1 init-inl]
      ::
      :+  ~2012.5.3
          %db1
          "FROM inl WHERE STRING(nud) = '5' SELECT id"
      ::
      :-  %results
          :~  [%action 'SELECT']
              :-  %result-set
                  :~
                      [%vector ~[[%id [~.ud 1]]]]
                      ==
              [%server-time ~2012.5.3]
              [%relation-name 'db1.dbo.inl']
              [%schema-time ~2012.4.30]
              [%data-time ~2012.4.30]
              [%vector-count 1]
              ==
      ==
::
++  test-inline-select-string-concat
  =|  run=@ud
  %-  exec-0-1
  :*  run
      [~2012.4.30 %sys "CREATE DATABASE db1"]
      ::
      :+  ~2012.5.3
          %sys
          "SELECT STRING-CONCAT('hello', 'world', ', ')"
      ::
      :-  %results
          :~  [%action 'SELECT']
              :-  %result-set
                  ~[[%vector ~[[%scalar-0 [~.t 'hello, world']]]]]
              [%server-time ~2012.5.3]
              [%schema-time ~2012.4.30]
              [%data-time ~2012.4.30]
              [%vector-count 1]
              ==
      ==
::
++  test-inline-select-col-string-concat
  =|  run=@ud
  %-  exec-0-1
  :*  run
      [~2012.4.30 %db1 init-inl]
      ::
      :+  ~2012.5.3
          %db1
          "FROM inl WHERE id = 1 SELECT id, STRING-CONCAT(t, 'world', ', ')"
      ::
      :-  %results
          :~  [%action 'SELECT']
              :-  %result-set
                  :~  :-  %vector
                          :~  [%id [~.ud 1]]
                              [%scalar-1 [~.t 'hello, world']]
                              ==
                      ==
              [%server-time ~2012.5.3]
              [%relation-name 'db1.dbo.inl']
              [%schema-time ~2012.4.30]
              [%data-time ~2012.4.30]
              [%vector-count 1]
              ==
      ==
::
++  test-inline-where-string-concat
  =|  run=@ud
  %-  exec-0-1
  :*  run
      [~2012.4.30 %db1 init-inl]
      ::
      :+  ~2012.5.3
          %db1
          "FROM inl WHERE STRING-CONCAT(t, 'world', ', ') = 'hello, ".
          "world' SELECT id"
      ::
      :-  %results
          :~  [%action 'SELECT']
              :-  %result-set
                  :~
                      [%vector ~[[%id [~.ud 1]]]]
                      ==
              [%server-time ~2012.5.3]
              [%relation-name 'db1.dbo.inl']
              [%schema-time ~2012.4.30]
              [%data-time ~2012.4.30]
              [%vector-count 1]
              ==
      ==
::
++  test-inline-select-stuff
  =|  run=@ud
  %-  exec-0-1
  :*  run
      [~2012.4.30 %sys "CREATE DATABASE db1"]
      ::
      :+  ~2012.5.3
          %sys
          "SELECT STUFF('hello world', 7, 5, 'there')"
      ::
      :-  %results
          :~  [%action 'SELECT']
              :-  %result-set
                  ~[[%vector ~[[%scalar-0 [~.t 'hello there']]]]]
              [%server-time ~2012.5.3]
              [%schema-time ~2012.4.30]
              [%data-time ~2012.4.30]
              [%vector-count 1]
              ==
      ==
::
++  test-inline-select-col-stuff
  =|  run=@ud
  %-  exec-0-1
  :*  run
      [~2012.4.30 %db1 init-inl]
      ::
      :+  ~2012.5.3
          %db1
          "FROM inl WHERE id = 1 SELECT id, STUFF(t, 2, 3, 'ELL')"
      ::
      :-  %results
          :~  [%action 'SELECT']
              :-  %result-set
                  :~  :-  %vector
                          :~  [%id [~.ud 1]]
                              [%scalar-1 [~.t 'hELLo']]
                              ==
                      ==
              [%server-time ~2012.5.3]
              [%relation-name 'db1.dbo.inl']
              [%schema-time ~2012.4.30]
              [%data-time ~2012.4.30]
              [%vector-count 1]
              ==
      ==
::
++  test-inline-where-stuff
  =|  run=@ud
  %-  exec-0-1
  :*  run
      [~2012.4.30 %db1 init-inl]
      ::
      :+  ~2012.5.3
          %db1
          "FROM inl WHERE STUFF(t, 2, 3, 'ELL') = 'hELLo' SELECT id"
      ::
      :-  %results
          :~  [%action 'SELECT']
              :-  %result-set
                  :~
                      [%vector ~[[%id [~.ud 1]]]]
                      ==
              [%server-time ~2012.5.3]
              [%relation-name 'db1.dbo.inl']
              [%schema-time ~2012.4.30]
              [%data-time ~2012.4.30]
              [%vector-count 1]
              ==
      ==
::
++  test-inline-select-substring
  =|  run=@ud
  %-  exec-0-1
  :*  run
      [~2012.4.30 %sys "CREATE DATABASE db1"]
      ::
      :+  ~2012.5.3
          %sys
          "SELECT SUBSTRING('hello', 2, 3)"
      ::
      :-  %results
          :~  [%action 'SELECT']
              :-  %result-set
                  ~[[%vector ~[[%scalar-0 [~.t 'ell']]]]]
              [%server-time ~2012.5.3]
              [%schema-time ~2012.4.30]
              [%data-time ~2012.4.30]
              [%vector-count 1]
              ==
      ==
::
++  test-inline-select-col-substring
  =|  run=@ud
  %-  exec-0-1
  :*  run
      [~2012.4.30 %db1 init-inl]
      ::
      :+  ~2012.5.3
          %db1
          "FROM inl WHERE id = 1 SELECT id, SUBSTRING(t, 2, 3)"
      ::
      :-  %results
          :~  [%action 'SELECT']
              :-  %result-set
                  :~  :-  %vector
                          :~  [%id [~.ud 1]]
                              [%scalar-1 [~.t 'ell']]
                              ==
                      ==
              [%server-time ~2012.5.3]
              [%relation-name 'db1.dbo.inl']
              [%schema-time ~2012.4.30]
              [%data-time ~2012.4.30]
              [%vector-count 1]
              ==
      ==
::
++  test-inline-where-substring
  =|  run=@ud
  %-  exec-0-1
  :*  run
      [~2012.4.30 %db1 init-inl]
      ::
      :+  ~2012.5.3
          %db1
          "FROM inl WHERE SUBSTRING(t, 2, 3) = 'ell' SELECT id"
      ::
      :-  %results
          :~  [%action 'SELECT']
              :-  %result-set
                  :~
                      [%vector ~[[%id [~.ud 1]]]]
                      ==
              [%server-time ~2012.5.3]
              [%relation-name 'db1.dbo.inl']
              [%schema-time ~2012.4.30]
              [%data-time ~2012.4.30]
              [%vector-count 1]
              ==
      ==
::
++  test-inline-select-trim
  =|  run=@ud
  %-  exec-0-1
  :*  run
      [~2012.4.30 %sys "CREATE DATABASE db1"]
      ::
      :+  ~2012.5.3
          %sys
          "SELECT TRIM('  hello  ')"
      ::
      :-  %results
          :~  [%action 'SELECT']
              :-  %result-set
                  ~[[%vector ~[[%scalar-0 [~.t 'hello']]]]]
              [%server-time ~2012.5.3]
              [%schema-time ~2012.4.30]
              [%data-time ~2012.4.30]
              [%vector-count 1]
              ==
      ==
::
++  test-inline-select-col-trim
  =|  run=@ud
  %-  exec-0-1
  :*  run
      [~2012.4.30 %db1 init-inl]
      ::
      :+  ~2012.5.3
          %db1
          "FROM inl WHERE id = 1 SELECT id, TRIM(tpad)"
      ::
      :-  %results
          :~  [%action 'SELECT']
              :-  %result-set
                  :~  :-  %vector
                          :~  [%id [~.ud 1]]
                              [%scalar-1 [~.t 'hello']]
                              ==
                      ==
              [%server-time ~2012.5.3]
              [%relation-name 'db1.dbo.inl']
              [%schema-time ~2012.4.30]
              [%data-time ~2012.4.30]
              [%vector-count 1]
              ==
      ==
::
++  test-inline-where-trim
  =|  run=@ud
  %-  exec-0-1
  :*  run
      [~2012.4.30 %db1 init-inl]
      ::
      :+  ~2012.5.3
          %db1
          "FROM inl WHERE TRIM(tpad) = 'hello' SELECT id"
      ::
      :-  %results
          :~  [%action 'SELECT']
              :-  %result-set
                  :~
                      [%vector ~[[%id [~.ud 1]]]]
                      ==
              [%server-time ~2012.5.3]
              [%relation-name 'db1.dbo.inl']
              [%schema-time ~2012.4.30]
              [%data-time ~2012.4.30]
              [%vector-count 1]
              ==
      ==
::
++  test-inline-select-upper
  =|  run=@ud
  %-  exec-0-1
  :*  run
      [~2012.4.30 %sys "CREATE DATABASE db1"]
      ::
      :+  ~2012.5.3
          %sys
          "SELECT UPPER('hello')"
      ::
      :-  %results
          :~  [%action 'SELECT']
              :-  %result-set
                  ~[[%vector ~[[%scalar-0 [~.t 'HELLO']]]]]
              [%server-time ~2012.5.3]
              [%schema-time ~2012.4.30]
              [%data-time ~2012.4.30]
              [%vector-count 1]
              ==
      ==
::
++  test-inline-select-col-upper
  =|  run=@ud
  %-  exec-0-1
  :*  run
      [~2012.4.30 %db1 init-inl]
      ::
      :+  ~2012.5.3
          %db1
          "FROM inl WHERE id = 1 SELECT id, UPPER(t)"
      ::
      :-  %results
          :~  [%action 'SELECT']
              :-  %result-set
                  :~  :-  %vector
                          :~  [%id [~.ud 1]]
                              [%scalar-1 [~.t 'HELLO']]
                              ==
                      ==
              [%server-time ~2012.5.3]
              [%relation-name 'db1.dbo.inl']
              [%schema-time ~2012.4.30]
              [%data-time ~2012.4.30]
              [%vector-count 1]
              ==
      ==
::
++  test-inline-where-upper
  =|  run=@ud
  %-  exec-0-1
  :*  run
      [~2012.4.30 %db1 init-inl]
      ::
      :+  ~2012.5.3
          %db1
          "FROM inl WHERE UPPER(t) = 'HELLO' SELECT id"
      ::
      :-  %results
          :~  [%action 'SELECT']
              :-  %result-set
                  :~
                      [%vector ~[[%id [~.ud 1]]]]
                      ==
              [%server-time ~2012.5.3]
              [%relation-name 'db1.dbo.inl']
              [%schema-time ~2012.4.30]
              [%data-time ~2012.4.30]
              [%vector-count 1]
              ==
      ==
::
++  test-inline-select-coalesce
  =|  run=@ud
  %-  exec-0-1
  :*  run
      [~2012.4.30 %sys "CREATE DATABASE db1"]
      ::
      :+  ~2012.5.3
          %sys
          "SELECT COALESCE(1, 2)"
      ::
      :-  %results
          :~  [%action 'SELECT']
              :-  %result-set
                  ~[[%vector ~[[%scalar-0 [~.ud 1]]]]]
              [%server-time ~2012.5.3]
              [%schema-time ~2012.4.30]
              [%data-time ~2012.4.30]
              [%vector-count 1]
              ==
      ==
::
++  test-inline-select-col-coalesce
  =|  run=@ud
  %-  exec-0-1
  :*  run
      [~2012.4.30 %db1 init-inl]
      ::
      :+  ~2012.5.3
          %db1
          "FROM inl WHERE id = 1 SELECT id, COALESCE(nud, 1)"
      ::
      :-  %results
          :~  [%action 'SELECT']
              :-  %result-set
                  :~  :-  %vector
                          :~  [%id [~.ud 1]]
                              [%scalar-1 [~.ud 5]]
                              ==
                      ==
              [%server-time ~2012.5.3]
              [%relation-name 'db1.dbo.inl']
              [%schema-time ~2012.4.30]
              [%data-time ~2012.4.30]
              [%vector-count 1]
              ==
      ==
::
++  test-inline-where-coalesce
  =|  run=@ud
  %-  exec-0-1
  :*  run
      [~2012.4.30 %db1 init-inl]
      ::
      :+  ~2012.5.3
          %db1
          "FROM inl WHERE COALESCE(nud, 1) = 5 SELECT id"
      ::
      :-  %results
          :~  [%action 'SELECT']
              :-  %result-set
                  :~
                      [%vector ~[[%id [~.ud 1]]]]
                      ==
              [%server-time ~2012.5.3]
              [%relation-name 'db1.dbo.inl']
              [%schema-time ~2012.4.30]
              [%data-time ~2012.4.30]
              [%vector-count 1]
              ==
      ==
::
++  test-inline-select-if
  =|  run=@ud
  %-  exec-0-1
  :*  run
      [~2012.4.30 %sys "CREATE DATABASE db1"]
      ::
      :+  ~2012.5.3
          %sys
          "SELECT IF 1 = 1 THEN 'yes' ELSE 'no' ENDIF"
      ::
      :-  %results
          :~  [%action 'SELECT']
              :-  %result-set
                  ~[[%vector ~[[%scalar-0 [~.t 'yes']]]]]
              [%server-time ~2012.5.3]
              [%schema-time ~2012.4.30]
              [%data-time ~2012.4.30]
              [%vector-count 1]
              ==
      ==
::
++  test-inline-select-col-if
  =|  run=@ud
  %-  exec-0-1
  :*  run
      [~2012.4.30 %db1 init-inl]
      ::
      :+  ~2012.5.3
          %db1
          "FROM inl WHERE id = 1 SELECT id, IF nud > 6 THEN 'big' ELSE ".
          "'small' ENDIF"
      ::
      :-  %results
          :~  [%action 'SELECT']
              :-  %result-set
                  :~  :-  %vector
                          :~  [%id [~.ud 1]]
                              [%scalar-1 [~.t 'small']]
                              ==
                      ==
              [%server-time ~2012.5.3]
              [%relation-name 'db1.dbo.inl']
              [%schema-time ~2012.4.30]
              [%data-time ~2012.4.30]
              [%vector-count 1]
              ==
      ==
::
++  test-inline-where-if
  =|  run=@ud
  %-  exec-0-1
  :*  run
      [~2012.4.30 %db1 init-inl]
      ::
      :+  ~2012.5.3
          %db1
          "FROM inl WHERE IF nud > 6 THEN 'big' ELSE 'small' ENDIF = ".
          "'small' SELECT id"
      ::
      :-  %results
          :~  [%action 'SELECT']
              :-  %result-set
                  :~
                      [%vector ~[[%id [~.ud 1]]]]
                      ==
              [%server-time ~2012.5.3]
              [%relation-name 'db1.dbo.inl']
              [%schema-time ~2012.4.30]
              [%data-time ~2012.4.30]
              [%vector-count 1]
              ==
      ==
::
++  test-inline-select-case-simple
  =|  run=@ud
  %-  exec-0-1
  :*  run
      [~2012.4.30 %sys "CREATE DATABASE db1"]
      ::
      :+  ~2012.5.3
          %sys
          "SELECT CASE 2 WHEN 1 THEN 'one' WHEN 2 THEN 'two' ELSE 'other' END"
      ::
      :-  %results
          :~  [%action 'SELECT']
              :-  %result-set
                  ~[[%vector ~[[%scalar-0 [~.t 'two']]]]]
              [%server-time ~2012.5.3]
              [%schema-time ~2012.4.30]
              [%data-time ~2012.4.30]
              [%vector-count 1]
              ==
      ==
::
++  test-inline-select-col-case-simple
  =|  run=@ud
  %-  exec-0-1
  :*  run
      [~2012.4.30 %db1 init-inl]
      ::
      :+  ~2012.5.3
          %db1
          "FROM inl WHERE id = 1 SELECT id, CASE nud WHEN 5 THEN 'five' ".
          "ELSE 'other' END"
      ::
      :-  %results
          :~  [%action 'SELECT']
              :-  %result-set
                  :~  :-  %vector
                          :~  [%id [~.ud 1]]
                              [%scalar-1 [~.t 'five']]
                              ==
                      ==
              [%server-time ~2012.5.3]
              [%relation-name 'db1.dbo.inl']
              [%schema-time ~2012.4.30]
              [%data-time ~2012.4.30]
              [%vector-count 1]
              ==
      ==
::
++  test-inline-where-case-simple
  =|  run=@ud
  %-  exec-0-1
  :*  run
      [~2012.4.30 %db1 init-inl]
      ::
      :+  ~2012.5.3
          %db1
          "FROM inl WHERE CASE nud WHEN 5 THEN 'five' ELSE 'other' END = ".
          "'five' SELECT id"
      ::
      :-  %results
          :~  [%action 'SELECT']
              :-  %result-set
                  :~
                      [%vector ~[[%id [~.ud 1]]]]
                      ==
              [%server-time ~2012.5.3]
              [%relation-name 'db1.dbo.inl']
              [%schema-time ~2012.4.30]
              [%data-time ~2012.4.30]
              [%vector-count 1]
              ==
      ==
::
++  test-inline-select-case-searched
  =|  run=@ud
  %-  exec-0-1
  :*  run
      [~2012.4.30 %sys "CREATE DATABASE db1"]
      ::
      :+  ~2012.5.3
          %sys
          "SELECT CASE WHEN 1 = 2 THEN 'a' WHEN 1 = 1 THEN 'b' END"
      ::
      :-  %results
          :~  [%action 'SELECT']
              :-  %result-set
                  ~[[%vector ~[[%scalar-0 [~.t 'b']]]]]
              [%server-time ~2012.5.3]
              [%schema-time ~2012.4.30]
              [%data-time ~2012.4.30]
              [%vector-count 1]
              ==
      ==
::
++  test-inline-select-col-case-searched
  =|  run=@ud
  %-  exec-0-1
  :*  run
      [~2012.4.30 %db1 init-inl]
      ::
      :+  ~2012.5.3
          %db1
          "FROM inl WHERE id = 1 SELECT id, CASE WHEN nud > 6 THEN 'big' ".
          "ELSE 'small' END"
      ::
      :-  %results
          :~  [%action 'SELECT']
              :-  %result-set
                  :~  :-  %vector
                          :~  [%id [~.ud 1]]
                              [%scalar-1 [~.t 'small']]
                              ==
                      ==
              [%server-time ~2012.5.3]
              [%relation-name 'db1.dbo.inl']
              [%schema-time ~2012.4.30]
              [%data-time ~2012.4.30]
              [%vector-count 1]
              ==
      ==
::
++  test-inline-where-case-searched
  =|  run=@ud
  %-  exec-0-1
  :*  run
      [~2012.4.30 %db1 init-inl]
      ::
      :+  ~2012.5.3
          %db1
          "FROM inl WHERE CASE WHEN nud > 6 THEN 'big' ELSE 'small' END = ".
          "'big' SELECT id"
      ::
      :-  %results
          :~  [%action 'SELECT']
              :-  %result-set
                  :~
                      [%vector ~[[%id [~.ud 2]]]]
                      ==
              [%server-time ~2012.5.3]
              [%relation-name 'db1.dbo.inl']
              [%schema-time ~2012.4.30]
              [%data-time ~2012.4.30]
              [%vector-count 1]
              ==
      ==
::
++  test-inline-select-arithmetic
  =|  run=@ud
  %-  exec-0-1
  :*  run
      [~2012.4.30 %sys "CREATE DATABASE db1"]
      ::
      :+  ~2012.5.3
          %sys
          "SELECT 1 + 2 * 3"
      ::
      :-  %results
          :~  [%action 'SELECT']
              :-  %result-set
                  ~[[%vector ~[[%scalar-0 [~.ud 7]]]]]
              [%server-time ~2012.5.3]
              [%schema-time ~2012.4.30]
              [%data-time ~2012.4.30]
              [%vector-count 1]
              ==
      ==
::
++  test-inline-select-col-arithmetic
  =|  run=@ud
  %-  exec-0-1
  :*  run
      [~2012.4.30 %db1 init-inl]
      ::
      :+  ~2012.5.3
          %db1
          "FROM inl WHERE id = 1 SELECT id, (nud + 1) * 2"
      ::
      :-  %results
          :~  [%action 'SELECT']
              :-  %result-set
                  :~  :-  %vector
                          :~  [%id [~.ud 1]]
                              [%scalar-1 [~.ud 12]]
                              ==
                      ==
              [%server-time ~2012.5.3]
              [%relation-name 'db1.dbo.inl']
              [%schema-time ~2012.4.30]
              [%data-time ~2012.4.30]
              [%vector-count 1]
              ==
      ==
::
++  test-inline-where-arithmetic
  =|  run=@ud
  %-  exec-0-1
  :*  run
      [~2012.4.30 %db1 init-inl]
      ::
      :+  ~2012.5.3
          %db1
          "FROM inl WHERE (nud + 1) * 2 = 20 SELECT id"
      ::
      :-  %results
          :~  [%action 'SELECT']
              :-  %result-set
                  :~
                      [%vector ~[[%id [~.ud 2]]]]
                      ==
              [%server-time ~2012.5.3]
              [%relation-name 'db1.dbo.inl']
              [%schema-time ~2012.4.30]
              [%data-time ~2012.4.30]
              [%vector-count 1]
              ==
      ==
--
