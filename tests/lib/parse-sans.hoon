/-  ast
/+  parse,  *test
|%

++  column-foo       [%qualified-column qualifier=[%qualified-object ship=~ database='UNKNOWN' namespace='COLUMN-OR-CTE' name='foo'] column='foo' alias=~]
++  column-bar       [%qualified-column qualifier=[%qualified-object ship=~ database='UNKNOWN' namespace='COLUMN-OR-CTE' name='bar'] column='bar' alias=~]
++  all-columns  [%qualified-object ship=~ database='ALL' namespace='ALL' name='ALL']
++  select-all-columns  [%select top=~ bottom=~ columns=~[all-columns]]
++  col1
  [%qualified-column qualifier=[%qualified-object ship=~ database='UNKNOWN' namespace='COLUMN-OR-CTE' name='col1'] column='col1' alias=~]
++  col2
  [%qualified-column qualifier=[%qualified-object ship=~ database='UNKNOWN' namespace='COLUMN-OR-CTE' name='col2'] column='col2' alias=~]
++  col3
  [%qualified-column qualifier=[%qualified-object ship=~ database='UNKNOWN' namespace='COLUMN-OR-CTE' name='col3'] column='col3' alias=~]
++  col4
  [%qualified-column qualifier=[%qualified-object ship=~ database='UNKNOWN' namespace='COLUMN-OR-CTE' name='col4'] column='col4' alias=~]
++  delete-pred
  `[%eq [column-foo ~ ~] [column-bar ~ ~]]
++  cte-t1
  [%cte name='t1' [%query ~ scalars=~ predicate=~ group-by=~ having=~ selection=select-all-columns ~]]
++  cte-foobar
  [%cte name='foobar' [%query [~ [%from object=[%table-set object=[%qualified-object ship=~ database='db1' namespace='dbo' name='foobar'] alias=~] joins=~]] scalars=~ `[%eq [col1 ~ ~] [[value-type=%ud value=2] ~ ~]] group-by=~ having=~ [%select top=~ bottom=~ columns=~[col3 col4]] ~]]
++  cte-bar
  [%cte name='bar' [%query [~ [%from object=[%table-set object=[%qualified-object ship=~ database='db1' namespace='dbo' name='bar'] alias=~] joins=~]] scalars=~ `[%eq [col1 ~ ~] [col2 ~ ~]] group-by=~ having=~ [%select top=~ bottom=~ columns=~[col2]] ~]]
++  foo-table
  [%qualified-object ship=~ database='db1' namespace='dbo' name='foo']
++  update-pred
  [%and one-eq-1 [%eq [col2 ~ ~] [[value-type=%ud value=4] ~ ~]]]
++  one-eq-1
  [%eq [literal-1 ~ ~] [literal-1 ~ ~]]
++  literal-1        [value-type=%ud value=1]
::@@@@@@@@@@@@@@@@@@@@@@@@@

::
:: update one column, no predicate
++  test-update-00
  %+  expect-eq
    !>  ~[[%transform ctes=~ [[%update table=foo-table columns=~['col1'] values=~[[value-type=%t value='hello']] predicate=~ as-of=~] ~ ~]]]
    !>  (parse:parse(default-database 'db1') "update foo set col1='hello'")
::
:: update one column, no predicate as of now
++  test-update-01
  %+  expect-eq
    !>  ~[[%transform ctes=~ [[%update table=foo-table columns=~['col1'] values=~[[value-type=%t value='hello']] predicate=~ as-of=~] ~ ~]]]
    !>  (parse:parse(default-database 'db1') "update foo set col1='hello' as of now")
::
:: update one column, no predicate as of ~2023.12.25..7.15.0..1ef5
++  test-update-02
  %+  expect-eq
    !>  ~[[%transform ctes=~ [[%update table=foo-table columns=~['col1'] values=~[[value-type=%t value='hello']] predicate=~ as-of=[~ ~2023.12.25..7.15.0..1ef5]] ~ ~]]]
    !>  (parse:parse(default-database 'db1') "update foo set col1='hello' as of ~2023.12.25..7.15.0..1ef5")
::
:: update one column, no predicate as of 4 seconds ago
++  test-update-03
  %+  expect-eq
    !>  ~[[%transform ctes=~ [[%update table=foo-table columns=~['col1'] values=~[[value-type=%t value='hello']] predicate=~ as-of=[~ [%as-of-offset 4 %seconds]]] ~ ~]]]
    !>  (parse:parse(default-database 'db1') "update foo set col1='hello' as of 4 seconds ago")
::
:: update two columns, no predicate
++  test-update-04
  %+  expect-eq
    !>  ~[[%transform ctes=~ [[%update table=foo-table columns=~['col3' 'col1'] values=~[[value-type=%t value='hello'] col2] predicate=~ as-of=~] ~ ~]]]
    !>  (parse:parse(default-database 'db1') "update foo set col1=col2, col3 = 'hello'")
::
:: update two columns, no predicate as of now
++  test-update-05
  %+  expect-eq
    !>  ~[[%transform ctes=~ [[%update table=foo-table columns=~['col3' 'col1'] values=~[[value-type=%t value='hello'] col2] predicate=~ as-of=~] ~ ~]]]
    !>  (parse:parse(default-database 'db1') "update foo set col1=col2, col3 = 'hello' as of now")
::
:: update two columns, no predicate as of ~2023.12.25..7.15.0..1ef5
++  test-update-06
  %+  expect-eq
    !>  ~[[%transform ctes=~ [[%update table=foo-table columns=~['col3' 'col1'] values=~[[value-type=%t value='hello'] col2] predicate=~ as-of=[~ ~2023.12.25..7.15.0..1ef5]] ~ ~]]]
    !>  (parse:parse(default-database 'db1') "update foo set col1=col2, col3 = 'hello' as of ~2023.12.25..7.15.0..1ef5")
::
:: update two columns, no predicate as of 4 seconds ago
++  test-update-07
  %+  expect-eq
    !>  ~[[%transform ctes=~ [[%update table=foo-table columns=~['col3' 'col1'] values=~[[value-type=%t value='hello'] col2] predicate=~ as-of=[~ [%as-of-offset 4 %seconds]]] ~ ~]]]
    !>  (parse:parse(default-database 'db1') "update foo set col1=col2, col3 = 'hello' as of 4 seconds ago")
::
:: update two columns, with predicate
++  test-update-08
  %+  expect-eq
    !>  ~[[%transform ctes=~ [[%update table=foo-table columns=~['col3' 'col1'] values=~[[value-type=%t value='hello'] col2] predicate=`update-pred as-of=~] ~ ~]]]
    !>  (parse:parse(default-database 'db1') "update foo set col1=col2, col3 = 'hello' where 1 = 1 and col2 = 4")
::
:: update two columns, with predicate as of now
++  test-update-09
  %+  expect-eq
    !>  ~[[%transform ctes=~ [[%update table=foo-table columns=~['col3' 'col1'] values=~[[value-type=%t value='hello'] col2] predicate=`update-pred as-of=~] ~ ~]]]
    !>  (parse:parse(default-database 'db1') "update foo set col1=col2, col3 = 'hello' where 1 = 1 and col2 = 4 as of now")
::
:: update two columns, with predicate as of ~2023.12.25..7.15.0..1ef5
++  test-update-10
  %+  expect-eq
    !>  ~[[%transform ctes=~ [[%update table=foo-table columns=~['col3' 'col1'] values=~[[value-type=%t value='hello'] col2] predicate=`update-pred as-of=[~ ~2023.12.25..7.15.0..1ef5]] ~ ~]]]
    !>  (parse:parse(default-database 'db1') "update foo set col1=col2, col3 = 'hello' where 1 = 1 and col2 = 4 as of ~2023.12.25..7.15.0..1ef5")
::
:: update two columns, with predicate as of 4 seconds ago
++  test-update-11
  %+  expect-eq
    !>  ~[[%transform ctes=~ [[%update table=foo-table columns=~['col3' 'col1'] values=~[[value-type=%t value='hello'] col2] predicate=`update-pred as-of=[~ [%as-of-offset 4 %seconds]]] ~ ~]]]
    !>  (parse:parse(default-database 'db1') "update foo set col1=col2, col3 = 'hello' where 1 = 1 and col2 = 4 as of 4 seconds ago")
::
:: update with one cte and predicate
++  test-update-12
  %+  expect-eq
    !>  ~[[%transform ctes=~[cte-t1] [[%update table=foo-table columns=~['col3' 'col1'] values=~[[value-type=%t value='hello'] col2] predicate=`update-pred as-of=~] ~ ~]]]
    !>  (parse:parse(default-database 'db1') "with (select *) as t1 update foo set col1=col2, col3 = 'hello' where 1 = 1 and col2 = 4")
::
:: update with one cte and predicate as of now
++  test-update-13
  %+  expect-eq
    !>  ~[[%transform ctes=~[cte-t1] [[%update table=foo-table columns=~['col3' 'col1'] values=~[[value-type=%t value='hello'] col2] predicate=`update-pred as-of=~] ~ ~]]]
    !>  (parse:parse(default-database 'db1') "with (select *) as t1 update foo set col1=col2, col3 = 'hello' where 1 = 1 and col2 = 4 as of now")
::
:: update with one cte and predicate as of ~2023.12.25..7.15.0..1ef5
++  test-update-14
  %+  expect-eq
    !>  ~[[%transform ctes=~[cte-t1] [[%update table=foo-table columns=~['col3' 'col1'] values=~[[value-type=%t value='hello'] col2] predicate=`update-pred as-of=[~ ~2023.12.25..7.15.0..1ef5]] ~ ~]]]
    !>  (parse:parse(default-database 'db1') "with (select *) as t1 update foo set col1=col2, col3 = 'hello' where 1 = 1 and col2 = 4 as of ~2023.12.25..7.15.0..1ef5")
::
:: update with one cte and predicate as of 4 seconds ago
++  test-update-15
  %+  expect-eq
    !>  ~[[%transform ctes=~[cte-t1] [[%update table=foo-table columns=~['col3' 'col1'] values=~[[value-type=%t value='hello'] col2] predicate=`update-pred as-of=[~ [%as-of-offset 4 %seconds]]] ~ ~]]]
    !>  (parse:parse(default-database 'db1') "with (select *) as t1 update foo set col1=col2, col3 = 'hello' where 1 = 1 and col2 = 4 as of 4 seconds ago")
::
:: update with three ctes and predicate
++  test-update-16
  %+  expect-eq
    !>  ~[[%transform ctes=~[cte-t1 cte-foobar cte-bar] [[%update table=foo-table columns=~['col3' 'col1'] values=~[[value-type=%t value='hello'] col2] predicate=`update-pred as-of=~] ~ ~]]]
    !>  (parse:parse(default-database 'db1') "with (select *) as t1, (from foobar where col1=2 select col3, col4) as foobar, (from bar where col1=col2 select col2) as bar update foo set col1=col2, col3 = 'hello' where 1 = 1 and col2 = 4")
::
:: update with three ctes and predicate as of now
++  test-update-17
  %+  expect-eq
    !>  ~[[%transform ctes=~[cte-t1 cte-foobar cte-bar] [[%update table=foo-table columns=~['col3' 'col1'] values=~[[value-type=%t value='hello'] col2] predicate=`update-pred as-of=~] ~ ~]]]
    !>  (parse:parse(default-database 'db1') "with (select *) as t1, (from foobar where col1=2 select col3, col4) as foobar, (from bar where col1=col2 select col2) as bar update foo set col1=col2, col3 = 'hello' where 1 = 1 and col2 = 4 as of now")
::
:: update with three ctes and predicate as of ~2023.12.25..7.15.0..1ef5
++  test-update-18
  %+  expect-eq
    !>  ~[[%transform ctes=~[cte-t1 cte-foobar cte-bar] [[%update table=foo-table columns=~['col3' 'col1'] values=~[[value-type=%t value='hello'] col2] predicate=`update-pred as-of=[~ ~2023.12.25..7.15.0..1ef5]] ~ ~]]]
    !>  (parse:parse(default-database 'db1') "with (select *) as t1, (from foobar where col1=2 select col3, col4) as foobar, (from bar where col1=col2 select col2) as bar update foo set col1=col2, col3 = 'hello' where 1 = 1 and col2 = 4 as of ~2023.12.25..7.15.0..1ef5")
::
:: update with three ctes and predicate as of 4 seconds ago
++  test-update-19
  %+  expect-eq
    !>  ~[[%transform ctes=~[cte-t1 cte-foobar cte-bar] [[%update table=foo-table columns=~['col3' 'col1'] values=~[[value-type=%t value='hello'] col2] predicate=`update-pred as-of=[~ [%as-of-offset 4 %seconds]]] ~ ~]]]
    !>  (parse:parse(default-database 'db1') "with (select *) as t1, (from foobar where col1=2 select col3, col4) as foobar, (from bar where col1=col2 select col2) as bar update foo set col1=col2, col3 = 'hello' where 1 = 1 and col2 = 4 as of 4 seconds ago")


::@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
::
:: expected/actual match
::++  test-predicate-26
::  =/  query  "FROM adoptions AS T1 JOIN adoptions AS T2 ON T1.foo = T2.bar ".
::    " WHERE foobar >=foo And foobar<=bar ".
::    " and T1.foo2 = ~zod ".
::    " SELECT *"
::  =/  joinpred=(tree predicate-component:ast)  [%eq t1-foo t2-bar]
::  =/  pred=(tree predicate-component:ast)      and-and
::  =/  expected=simple-query:ast
::    [%simple-query [~ [%from object=[%query-object object=[%qualified-object ship=~ database='db1' namespace='dbo' name='adoptions'] alias=[~ 'T1']] joins=~[[%joined-object join=%join object=[%query-object object=[%qualified-object ship=~ database='db1' namespace='dbo' name='adoptions'] alias=[~ 'T2']] predicate=`joinpred]]]] scalars=~ `pred group-by=~ having=~ select-all-columns ~]
::  %+  expect-eq
::    !>  ~[expected]
::    !>  (parse:parse(current-database 'db1') query)


--
