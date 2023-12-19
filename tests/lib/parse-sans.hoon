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
:: drop namespace
::
:: tests 1, 2, 3, 5, and extra whitespace characters, force db.name, name
++  test-drop-namespace-00
  =/  expected1  [%drop-namespace database-name='db' name='name' force=%.n as-of=~]
  =/  expected2  [%drop-namespace database-name='other-db' name='name' force=%.y as-of=~]
  %+  expect-eq
    !>  ~[expected1 expected2]
    !>  (parse:parse(default-database 'other-db') "droP  Namespace  db.name;droP \0d\09 Namespace FORce  \0a name")
::
:: leading and trailing whitespace characters, end delimiter not required on single, force name
++  test-drop-namespace-01
  %+  expect-eq
    !>  ~[[%drop-namespace database-name='other-db' name='name' force=%.y as-of=~]]
    !>  (parse:parse(default-database 'other-db') "   \09drOp\0d\09  naMespace\0a force name ")
::
:: db.name
++  test-drop-namespace-02
  %+  expect-eq
    !>  ~[[%drop-namespace database-name='db' name='name' force=%.n as-of=~]]
    !>  (parse:parse(default-database 'other-db') "drop namespace db.name")
::
::  name, as of now
++  test-drop-namespace-03
  %+  expect-eq
    !>  ~[[%drop-namespace database-name='other-db' name='ns1' force=%.n as-of=~]]
    !>  (parse:parse(default-database 'other-db') "drop namespace ns1 as of now")
::
::  name, as of date
++  test-drop-namespace-04
  %+  expect-eq
    !>  ~[[%drop-namespace database-name='other-db' name='ns1' force=%.n as-of=[~ [%da ~2023.12.25..7.15.0..1ef5]]]]
    !>  (parse:parse(default-database 'other-db') "drop namespace ns1 as of ~2023.12.25..7.15.0..1ef5")
::
::  name, as of 5 seconds ago
++  test-drop-namespace-05
  %+  expect-eq
    !>  ~[[%drop-namespace database-name='other-db' name='ns1' force=%.n as-of=[~ [%as-of-offset 5 %seconds]]]]
    !>  (parse:parse(default-database 'other-db') "drop namespace ns1 as of 5 seconds ago")
::
::  force name as of now
++  test-drop-namespace-06
  %+  expect-eq
    !>  ~[[%drop-namespace database-name='other-db' name='ns1' force=%.y as-of=~]]
    !>  (parse:parse(default-database 'other-db') "drop namespace force ns1 as of now")
::
::  force name as of date
++  test-drop-namespace-07
  %+  expect-eq
    !>  ~[[%drop-namespace database-name='other-db' name='ns1' force=%.y as-of=[~ [%da ~2023.12.25..7.15.0..1ef5]]]]
    !>  (parse:parse(default-database 'other-db') "drop namespace force ns1 as of ~2023.12.25..7.15.0..1ef5")
::
::  force name as of 5 seconds ago
++  test-drop-namespace-08
  %+  expect-eq
    !>  ~[[%drop-namespace database-name='other-db' name='ns1' force=%.y as-of=[~ [%as-of-offset 5 %seconds]]]]
    !>  (parse:parse(default-database 'other-db') "drop namespace force ns1 as of 5 seconds ago")
::
:: db name as of now
++  test-drop-namespace-09
  %+  expect-eq
    !>  ~[[%drop-namespace database-name='db1' name='ns1' force=%.n as-of=~]]
    !>  (parse:parse(default-database 'other-db') "drop namespace db1.ns1 as of now")
::
:: db name as of date
++  test-drop-namespace-10
  %+  expect-eq
    !>  ~[[%drop-namespace database-name='db1' name='ns1' force=%.n as-of=[~ [%da ~2023.12.25..7.15.0..1ef5]]]]
    !>  (parse:parse(default-database 'other-db') "drop namespace db1.ns1 as of ~2023.12.25..7.15.0..1ef5")
::
:: db name as of 5 seconds ago
++  test-drop-namespace-11
  %+  expect-eq
    !>  ~[[%drop-namespace database-name='db1' name='ns1' force=%.n as-of=[~ [%as-of-offset 5 %seconds]]]]
    !>  (parse:parse(default-database 'other-db') "drop namespace db1.ns1 as of 5 seconds ago")
::
:: force db name as of
++  test-drop-namespace-12
  %+  expect-eq
    !>  ~[[%drop-namespace database-name='db1' name='ns1' force=%.y as-of=~]]
    !>  (parse:parse(default-database 'other-db') "drop namespace force db1.ns1 as of now")
::
:: force db name as of
++  test-drop-namespace-13
  %+  expect-eq
    !>  ~[[%drop-namespace database-name='db1' name='ns1' force=%.y as-of=[~ [%da ~2023.12.25..7.15.0..1ef5]]]]
    !>  (parse:parse(default-database 'other-db') "drop namespace force db1.ns1 as of ~2023.12.25..7.15.0..1ef5")
::
:: force db name as of
++  test-drop-namespace-14
  %+  expect-eq
    !>  ~[[%drop-namespace database-name='db1' name='ns1' force=%.y as-of=[~ [%as-of-offset 15 %minutes]]]]
    !>  (parse:parse(default-database 'other-db') "drop namespace force db1.ns1 as of 15 minutes ago")
::
:: fail when database qualifier is not a term
++  test-fail-drop-namespace-15
  %-  expect-fail
  |.  (parse:parse(default-database 'other-db') "DROP NAMESPACE Db.name")
::
:: fail when namespace is not a term
++  test-fail-drop-namespace-16
  %-  expect-fail
  |.  (parse:parse(default-database 'other-db') "DROP NAMESPACE nAme")

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
