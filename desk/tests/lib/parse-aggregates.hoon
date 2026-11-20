::  parsing aggregate functions, GROUP BY, and HAVING: each aggregate is a
::  generated scalar, aggregate.<i>, referenced by SELECT and HAVING
::
/-  ast=obelisk-ast
/+  parse,  *test
::
|%
::
++  foo-table
  [%qualified-table ship=~ database='db1' namespace='dbo' name='foo' alias=~]
::
++  pay   [%unqualified-column name=%pay alias=~]
++  dept  [%unqualified-column name=%dept alias=~]
::
++  mk-query
  |=  $:  scalars=(list scalar:ast)
          group-by=(list grouping-column:ast)
          having=predicate:ast
          columns=(list selected-column:ast)
          ==
  ^-  (list command:ast)
  :~  :+  %crud-txn
          ctes=~
          :-  %query
              :*  %query
                  from=`[%from foo-table ~ ~]
                  scalars
                  predicate=~
                  group-by
                  having
                  [%select top=~ columns=columns]
                  order-by=~
              ==
  ==
::
++  parse-db1
  |=  urql=tape
  (parse:parse(default-database 'db1') urql)
::
::  unaliased aggregates are named <function>-<position>; DISTINCT, ALL,
::  COUNT(*), and an expression argument
++  test-aggregate-select-00
  %+  expect-eq
    !>  %:  mk-query
            :~  [%scalar 'aggregate.0' [%aggregate %count %.n ~]]
                [%scalar 'aggregate.1' [%aggregate %sum %.y `pay]]
                :+  %scalar
                    'aggregate.2'
                    :^  %aggregate
                        %avg
                        %.n
                        `[%arithmetic %tar pay [~.ud 2]]
                ==
            ~[dept]
            ~
            :~  dept
                [%selected-scalar 'aggregate.0' `'count-1']
                [%selected-scalar 'aggregate.1' `'total']
                [%selected-scalar 'aggregate.2' `'avg-3']
            ==
        ==
    !>  %-  parse-db1
        "FROM foo GROUP BY dept SELECT dept, COUNT(*), ".
        "SUM(DISTINCT pay) AS total, AVG(ALL pay * 2)"
::
::  HAVING aggregates are defined before those of SELECT; an aggregate is
::  the argument of a scalar function
++  test-aggregate-having-00
  =/  having=predicate:ast
    :+  %and
      [%gt [[%scalar-name 'aggregate.0'] ~ ~] [[%ud 1] ~ ~]]
    [%lt [[%scalar-name 'aggregate.1'] ~ ~] [[%ud 100] ~ ~]]
  %+  expect-eq
    !>  %:  mk-query
            :~  [%scalar 'aggregate.0' [%aggregate %count %.n ~]]
                [%scalar 'aggregate.1' [%aggregate %max %.n `pay]]
                [%scalar 'aggregate.2' [%aggregate %avg %.n `pay]]
                :+  %scalar
                    'inline.3'
                    [%round [%scalar-name 'aggregate.2'] [~.sd --2]]
            ==
            ~[dept]
            having
            ~[dept [%selected-scalar 'inline.3' `'scalar-1']]
        ==
    !>  %-  parse-db1
        "FROM foo GROUP BY dept HAVING COUNT(*) > 1 AND MAX(pay) < 100 ".
        "SELECT dept, ROUND(AVG(pay), --2)"
::
::  two-argument MIN is a scalar function, one-argument MIN an aggregate
++  test-aggregate-min-00
  %+  expect-eq
    !>  %:  mk-query
            :~  [%scalar 'aggregate.0' [%aggregate %min %.n `pay]]
                [%scalar 'inline.1' [%min pay dept]]
            ==
            ~
            ~
            :~  [%selected-scalar 'inline.1' `'scalar-0']
                [%selected-scalar 'aggregate.0' `'min-1']
            ==
        ==
    !>  (parse-db1 "FROM foo SELECT MIN(pay, dept), MIN(pay)")
::
::  arithmetic of aggregates; GROUP BY an ordinal
++  test-aggregate-arithmetic-00
  %+  expect-eq
    !>  %:  mk-query
            :~  [%scalar 'aggregate.0' [%aggregate %sum %.n `pay]]
                [%scalar 'aggregate.1' [%aggregate %count %.n `pay]]
                :+  %scalar
                    'inline.2'
                    :^  %arithmetic
                        %fas
                        [%scalar-name 'aggregate.0']
                        [%scalar-name 'aggregate.1']
            ==
            ~[1]
            ~
            ~[dept [%selected-scalar 'inline.2' `'mean']]
        ==
    !>  %-  parse-db1
        "FROM foo GROUP BY 1 SELECT dept, SUM(pay) / COUNT(pay) AS mean"
::
::  HAVING without GROUP BY
++  test-aggregate-having-01
  %+  expect-eq
    !>  %:  mk-query
            :~  [%scalar 'aggregate.0' [%aggregate %count %.n ~]]
                [%scalar 'aggregate.1' [%aggregate %count %.n ~]]
            ==
            ~
            [%gt [[%scalar-name 'aggregate.0'] ~ ~] [[%ud 0] ~ ~]]
            ~[[%selected-scalar 'aggregate.1' `'n']]
        ==
    !>  (parse-db1 "FROM foo HAVING COUNT(*) > 0 SELECT COUNT(*) AS n")
::
::  the loobean aggregates
++  test-aggregate-bool-00
  =/  flag  [%unqualified-column name=%flag alias=~]
  %+  expect-eq
    !>  %:  mk-query
            :~  [%scalar 'aggregate.0' [%aggregate %bool-or %.n `flag]]
                [%scalar 'aggregate.1' [%aggregate %bool-and %.n `flag]]
                [%scalar 'aggregate.2' [%aggregate %bool-and %.n `flag]]
            ==
            ~[dept]
            :+  %eq
              [[%scalar-name 'aggregate.0'] ~ ~]
            [[%scalar-name 'aggregate.1'] ~ ~]
            ~[dept [%selected-scalar 'aggregate.2' `'bool-and-1']]
        ==
    !>  %-  parse-db1
        "FROM foo GROUP BY dept HAVING BOOL-OR(flag) = BOOL-AND(flag) ".
        "SELECT dept, bool-and(flag)"
::
++  test-fail-aggregate-nested-00
  %+  expect-fail-message
    'an aggregate function cannot be the argument of an aggregate function'
  |.  (parse-db1 "FROM foo SELECT SUM(COUNT(*))")
::
++  test-fail-aggregate-star-00
  %+  expect-fail-message
    'SUM(*) is not allowed, only COUNT(*)'
  |.  (parse-db1 "FROM foo SELECT SUM(*)")
::
++  test-fail-aggregate-scalars-00
  %+  expect-fail-message
    'aggregate functions are only allowed in SELECT and HAVING'
  |.  (parse-db1 "FROM foo SCALARS s ABS(SUM(pay)) SELECT s")
::
++  test-fail-aggregate-where-00
  %+  expect-fail-message
    'aggregate functions are only allowed in SELECT and HAVING'
  |.  (parse-db1 "FROM foo WHERE COUNT(*) > 1 SELECT dept")
::
++  test-fail-group-by-ordinal-00
  %+  expect-fail-message
    'GROUP BY: column ordinal must be 1 or greater'
  |.  (parse-db1 "FROM foo GROUP BY 0 SELECT dept")
--
