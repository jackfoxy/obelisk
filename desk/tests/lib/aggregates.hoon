::  aggregate functions, GROUP BY, and HAVING
::
/-  ast=obelisk-ast, *obelisk
/+  *test, *test-helpers
|%
::
::  eng pay 100 300 300 100, rate sums to 8, one not remote; ops pay 40 60
::  80, rate sums to 3, all remote; dept hr has no emp
++  init-agg
  "CREATE DATABASE db1; ".
  "CREATE TABLE emp (id @ud, dept @t, pay @ud, bonus @sd, rate @rd, ".
  "remote @f) PRIMARY KEY (id); ".
  "INSERT INTO emp VALUES ".
  "(1, 'eng', 100, --10, .~1.5, Y) (2, 'eng', 300, -5, .~2.5, Y) ".
  "(3, 'eng', 300, --1, .~3.5, N) (4, 'eng', 100, -6, .~0.5, Y) ".
  "(5, 'ops', 40, --5, .~0.5, Y) (6, 'ops', 60, -15, .~1.5, Y) ".
  "(7, 'ops', 80, --4, .~1, Y); ".
  "CREATE TABLE dept (dept @t, floor @ud) PRIMARY KEY (dept); ".
  "INSERT INTO dept VALUES ('eng', 1) ('ops', 2) ('hr', 3);"
::
::  SELECT results of rows from the relations named
++  agg-results
  |=  [names=(list @t) rows=(list vector:ast)]
  ^-  cmd-result:ast
  =/  head=(list result:ast)
    :~  [%action 'SELECT']
        [%result-set rows]
        [%server-time ~2012.5.3]
    ==
  =/  relations=(list (list result:ast))
    %+  turn  names
    |=  name=@t
    ^-  (list result:ast)
    :~  [%relation-name name]
        [%schema-time ~2012.4.30]
        [%data-time ~2012.4.30]
    ==
  =/  relation-results=(list result:ast)  (zing relations)
  =/  count=(list result:ast)  ~[[%vector-count (lent rows)]]
  =/  tail=(list result:ast)  (weld relation-results count)
  =/  results=(list result:ast)  (weld head tail)
  [%results results]
::
++  emp-results  (cury agg-results ~['db1.dbo.emp'])
::
++  agg-test
  |=  [run=@ud urql=tape expect=cmd-result:ast]
  %-  exec-0-1
  [run [~2012.4.30 %db1 init-agg] [~2012.5.3 %db1 urql] expect]
::
++  agg-fail
  |=  [run=@ud urql=tape message=@t]
  %-  failon-1
  [run [~2012.4.30 %db1 init-agg] [~2012.5.3 %db1 urql] message]
::
::  aggregates of each group; unaliased aggregates are <function>-<n>
++  test-group-by-00
  =|  run=@ud
  %^  agg-test  run
    "FROM emp GROUP BY dept ".
    "SELECT dept, COUNT(*), SUM(pay), MIN(pay), MAX(pay) ORDER BY dept"
  %-  emp-results
  :~  :-  %vector
          :~  [%dept [~.t 'eng']]
              [%count-1 [~.ud 4]]
              [%sum-2 [~.ud 800]]
              [%min-3 [~.ud 100]]
              [%max-4 [~.ud 300]]
          ==
      :-  %vector
          :~  [%dept [~.t 'ops']]
              [%count-1 [~.ud 3]]
              [%sum-2 [~.ud 180]]
              [%min-3 [~.ud 40]]
              [%max-4 [~.ud 80]]
          ==
  ==
::
::  AVG computes in @rd; DISTINCT counts and sums each value once; SUM of
::  a signed column is signed
++  test-group-by-01
  =|  run=@ud
  %^  agg-test  run
    "FROM emp GROUP BY dept ".
    "SELECT dept, AVG(pay) AS avg-pay, COUNT(DISTINCT pay) AS pays, ".
    "SUM(DISTINCT pay) AS pay-sum, AVG(rate) AS avg-rate, ".
    "SUM(bonus) AS bonus ORDER BY dept"
  %-  emp-results
  :~  :-  %vector
          :~  [%dept [~.t 'eng']]
              [%avg-pay [~.rd .~200]]
              [%pays [~.ud 2]]
              [%pay-sum [~.ud 400]]
              [%avg-rate [~.rd .~2]]
              [%bonus [~.sd --0]]
          ==
      :-  %vector
          :~  [%dept [~.t 'ops']]
              [%avg-pay [~.rd .~60]]
              [%pays [~.ud 3]]
              [%pay-sum [~.ud 180]]
              [%avg-rate [~.rd .~1]]
              [%bonus [~.sd -6]]
          ==
  ==
::
::  BOOL-AND is %.y when every value is, BOOL-OR when any is
++  test-bool-aggregates
  =|  run=@ud
  %^  agg-test  run
    "FROM emp GROUP BY dept ".
    "SELECT dept, BOOL-AND(remote) AS all-remote, ".
    "BOOL-OR(remote) AS any-remote ORDER BY dept"
  %-  emp-results
  :~  :-  %vector
          :~  [%dept [~.t 'eng']]
              [%all-remote [~.f %.n]]
              [%any-remote [~.f %.y]]
          ==
      :-  %vector
          :~  [%dept [~.t 'ops']]
              [%all-remote [~.f %.y]]
              [%any-remote [~.f %.y]]
          ==
  ==
::
::  a loobean aggregate compared with a %.y literal in HAVING; unaliased,
::  named bool-or-<n>
++  test-bool-having
  =|  run=@ud
  %^  agg-test  run
    "FROM emp GROUP BY dept HAVING BOOL-AND(remote) = %.y ".
    "SELECT dept, BOOL-OR(remote)"
  %-  emp-results
  :~  [%vector ~[[%dept [~.t 'ops']] [%bool-or-1 [~.f %.y]]]]
  ==
::
::  rows lacking the argument are skipped; with none, the aggregate does
::  not exist
++  test-bool-missing
  =|  run=@ud
  %^  agg-test  run
    "FROM dept D LEFT JOIN emp E ON D.dept = E.dept GROUP BY D.dept ".
    "SELECT D.dept, BOOL-AND(E.remote) AS all-remote ORDER BY D.dept"
  %+  agg-results  ~['db1.dbo.dept' 'db1.dbo.emp']
  :~  [%vector ~[[%dept [~.t 'eng']] [%all-remote [~.f %.n]]]]
      [%vector ~[[%dept [~.t 'hr']]]]
      [%vector ~[[%dept [~.t 'ops']] [%all-remote [~.f %.y]]]]
  ==
::
::  the legacy Y and N are loobean literals as IF branches
++  test-bool-literal-argument
  =|  run=@ud
  %^  agg-test  run
    "FROM emp GROUP BY dept ".
    "SELECT dept, BOOL-OR(IF pay > 250 THEN Y ELSE N ENDIF) AS big ".
    "ORDER BY dept"
  %-  emp-results
  :~  [%vector ~[[%dept [~.t 'eng']] [%big [~.f %.y]]]]
      [%vector ~[[%dept [~.t 'ops']] [%big [~.f %.n]]]]
  ==
::
++  test-fail-bool-number
  =|  run=@ud
  %^  agg-fail  run
    "FROM emp SELECT BOOL-OR(pay)"
  'BOOL-OR: requires a loobean argument, not @ud'
::
::  %.y and %.n as IF branches, and in INSERT values
++  test-bool-hoon-literals
  =|  run=@ud
  %-  exec-1-1
  :*  run
      [~2012.4.30 %db1 init-agg]
      [~2012.5.1 %db1 "INSERT INTO emp VALUES (8, 'hr', 10, --0, .~0, %.n)"]
      :+  ~2012.5.3
          %db1
          "FROM emp WHERE dept = 'hr' ".
          "SELECT BOOL-OR(remote) AS remote, ".
          "BOOL-AND(IF pay < 20 THEN %.y ELSE %.n ENDIF) AS small"
      :-  %results
          :~  [%action 'SELECT']
              :-  %result-set
                  ~[[%vector ~[[%remote [~.f %.n]] [%small [~.f %.y]]]]]
              [%server-time ~2012.5.3]
              [%relation-name 'db1.dbo.emp']
              [%schema-time ~2012.4.30]
              [%data-time ~2012.5.1]
              [%vector-count 1]
          ==
  ==
::
::  sample statistics: ops pay 40 60 80
++  test-statistics-sample
  =|  run=@ud
  %^  agg-test  run
    "FROM emp WHERE dept = 'ops' SELECT STDEV(pay), VAR(pay)"
  %-  emp-results
  :~  :-  %vector
          :~  [%stdev-0 [~.rd .~20]]
              [%var-1 [~.rd .~400]]
          ==
  ==
::
::  population statistics: eng pay 100 300 300 100
++  test-statistics-population
  =|  run=@ud
  %^  agg-test  run
    "FROM emp WHERE dept = 'eng' SELECT STDEVP(pay), VARP(pay)"
  %-  emp-results
  :~  :-  %vector
          :~  [%stdevp-0 [~.rd .~100]]
              [%varp-1 [~.rd .~10000]]
          ==
  ==
::
::  HAVING filters groups by an aggregate not selected; arithmetic of
::  aggregates, and an aggregate the argument of a scalar function
++  test-having-00
  =|  run=@ud
  %^  agg-test  run
    "FROM emp GROUP BY dept HAVING SUM(bonus) < --0 ".
    "SELECT dept, SUM(pay) / COUNT(*) AS mean, ABS(SUM(bonus)) AS b"
  %-  emp-results
  :~  :-  %vector
          :~  [%dept [~.t 'ops']]
              [%mean [~.ud 60]]
              [%b [~.sd --6]]
          ==
  ==
::
::  without GROUP BY all rows are one group; MAX of text, MIN of @rd
++  test-whole-table
  =|  run=@ud
  %^  agg-test  run
    "FROM emp SELECT COUNT(*), SUM(pay), MAX(dept), MIN(rate), ".
    "COUNT(DISTINCT dept)"
  %-  emp-results
  :~  :-  %vector
          :~  [%count-0 [~.ud 7]]
              [%sum-1 [~.ud 980]]
              [%max-2 [~.t 'ops']]
              [%min-3 [~.rd .~0.5]]
              [%count-4 [~.ud 2]]
          ==
  ==
::
::  no rows without GROUP BY: COUNT is 0, SUM does not exist
++  test-empty-whole-table
  =|  run=@ud
  %^  agg-test  run
    "FROM emp WHERE pay > 1000 SELECT COUNT(*), SUM(pay)"
  (emp-results ~[[%vector ~[[%count-0 [~.ud 0]]]]])
::
::  no rows with GROUP BY: no groups
++  test-empty-groups
  =|  run=@ud
  %^  agg-test  run
    "FROM emp WHERE pay > 1000 GROUP BY dept SELECT dept, COUNT(*)"
  (emp-results ~)
::
::  STDEV of one value does not exist
++  test-statistics-one-value
  =|  run=@ud
  %^  agg-test  run
    "FROM emp WHERE id = 1 SELECT COUNT(*), STDEV(pay), STDEVP(pay)"
  %-  emp-results
  :~  :-  %vector
          :~  [%count-0 [~.ud 1]]
              [%stdevp-2 [~.rd .~0]]
          ==
  ==
::
::  GROUP BY a joined relation's column, ORDER BY a grouped column
++  test-group-by-join
  =|  run=@ud
  %^  agg-test  run
    "FROM emp E JOIN dept D ON E.dept = D.dept GROUP BY D.floor ".
    "SELECT D.floor, COUNT(*) ORDER BY D.floor"
  %+  agg-results  ~['db1.dbo.dept' 'db1.dbo.emp']
  :~  [%vector ~[[%floor [~.ud 1]] [%count-1 [~.ud 4]]]]
      [%vector ~[[%floor [~.ud 2]] [%count-1 [~.ud 3]]]]
  ==
::
::  an outer join row lacking the argument is not counted by COUNT(E.id)
++  test-group-by-outer-join
  =|  run=@ud
  %^  agg-test  run
    "FROM dept D LEFT JOIN emp E ON D.dept = E.dept GROUP BY D.dept ".
    "SELECT D.dept, COUNT(E.id) AS ids, COUNT(*) AS n ORDER BY D.dept"
  %+  agg-results  ~['db1.dbo.dept' 'db1.dbo.emp']
  :~  [%vector ~[[%dept [~.t 'eng']] [%ids [~.ud 4]] [%n [~.ud 4]]]]
      [%vector ~[[%dept [~.t 'hr']] [%ids [~.ud 0]] [%n [~.ud 1]]]]
      [%vector ~[[%dept [~.t 'ops']] [%ids [~.ud 3]] [%n [~.ud 3]]]]
  ==
::
::  rows lacking a GROUP BY column are a group lacking it
++  test-group-by-missing-value
  =|  run=@ud
  %^  agg-test  run
    "FROM dept D LEFT JOIN emp E ON D.dept = E.dept GROUP BY E.dept ".
    "SELECT E.dept, COUNT(*) AS n ORDER BY E.dept"
  %+  agg-results  ~['db1.dbo.dept' 'db1.dbo.emp']
  :~  [%vector ~[[%dept [~.t 'eng']] [%n [~.ud 4]]]]
      [%vector ~[[%dept [~.t 'ops']] [%n [~.ud 3]]]]
      [%vector ~[[%n [~.ud 1]]]]
  ==
::
::  GROUP BY the output name of a scalar
++  test-group-by-scalar
  =|  run=@ud
  %^  agg-test  run
    "FROM emp GROUP BY size ".
    "SELECT IF pay > 90 THEN 'big' ELSE 'small' ENDIF AS size, COUNT(*) ".
    "ORDER BY size"
  %-  emp-results
  :~  [%vector ~[[%size [~.t 'big']] [%count-1 [~.ud 4]]]]
      [%vector ~[[%size [~.t 'small']] [%count-1 [~.ud 3]]]]
  ==
::
::  GROUP BY an ordinal
++  test-group-by-ordinal
  =|  run=@ud
  %^  agg-test  run
    "FROM emp GROUP BY 1 SELECT dept, MAX(bonus) ORDER BY 1"
  %-  emp-results
  :~  [%vector ~[[%dept [~.t 'eng']] [%max-1 [~.sd --10]]]]
      [%vector ~[[%dept [~.t 'ops']] [%max-1 [~.sd --5]]]]
  ==
::
::  a grouped CTE
++  test-group-by-cte
  =|  run=@ud
  %^  agg-test  run
    "WITH (FROM emp GROUP BY dept SELECT dept, COUNT(*) AS staff) AS c ".
    "FROM c WHERE staff > 3 SELECT dept, staff"
  (emp-results ~[[%vector ~[[%dept [~.t 'eng']] [%staff [~.ud 4]]]]])
::
++  test-fail-ungrouped-column
  =|  run=@ud
  %^  agg-fail  run
    "FROM emp GROUP BY dept SELECT dept, pay"
  'column %pay must be in GROUP BY or in an aggregate function'
::
++  test-fail-ungrouped-aggregate-query
  =|  run=@ud
  %^  agg-fail  run
    "FROM emp SELECT dept, COUNT(*)"
  'column %dept must be in GROUP BY or in an aggregate function'
::
++  test-fail-select-all
  =|  run=@ud
  %^  agg-fail  run
    "FROM emp GROUP BY dept SELECT *"
  'SELECT * is not allowed with GROUP BY or aggregates'
::
++  test-fail-sum-text
  =|  run=@ud
  %^  agg-fail  run
    "FROM emp SELECT SUM(dept)"
  'SUM: requires a numeric argument, not @t'
::
++  test-fail-no-from
  =|  run=@ud
  %^  agg-fail  run
    "SELECT COUNT(*)"
  'GROUP BY, HAVING, and aggregate functions require FROM'
::
++  test-fail-group-by-ordinal
  =|  run=@ud
  %^  agg-fail  run
    "FROM emp GROUP BY 9 SELECT dept"
  'GROUP BY: column ordinal 9 exceeds the selected columns'
::
++  test-fail-group-by-aggregate
  =|  run=@ud
  %^  agg-fail  run
    "FROM emp GROUP BY n SELECT COUNT(*) AS n"
  'GROUP BY: cannot group by an aggregate function'
--
