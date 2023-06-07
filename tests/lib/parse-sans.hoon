/-  ast
/+  parse,  *test
|%


++  foo-table        [%qualified-object ship=~ database='db1' namespace='dbo' name='foo']
++  column-foo       [%qualified-column qualifier=[%qualified-object ship=~ database='UNKNOWN' namespace='COLUMN-OR-CTE' name='foo'] column='foo' alias=~]
++  column-bar       [%qualified-column qualifier=[%qualified-object ship=~ database='UNKNOWN' namespace='COLUMN-OR-CTE' name='bar'] column='bar' alias=~]
++  all-columns         [%qualified-object ship=~ database='ALL' namespace='ALL' name='ALL']
++  select-all-columns  [%select top=~ bottom=~ distinct=%.n columns=~[all-columns]]
++  cte-t1              [%cte name='t1' [%query ~ scalars=~ predicate=~ group-by=~ having=~ selection=select-all-columns ~]]
++  foo-table-row       [%query-row ~['col1' 'col2' 'col3']]
++  delete-pred         `[%eq [column-foo ~ ~] [column-bar ~ ~]]

++  predicate-bar-eq-bar
  [%eq [[%qualified-column qualifier=[%qualified-object ship=~ database='UNKNOWN' namespace='COLUMN' name='tgt'] column='bar' alias=~] ~ ~] [[%qualified-column qualifier=[%qualified-object ship=~ database='UNKNOWN' namespace='COLUMN' name='src'] column='bar' alias=~] ~ ~]]
++  cte-bar-foobar
  [%cte name='T1' %query from=~ scalars=~ predicate=~ group-by=~ having=~ selection=[%select top=~ bottom=~ distinct=%.n columns=~[[%qualified-column qualifier=[%qualified-object ship=~ database='UNKNOWN' namespace='COLUMN-OR-CTE' name='bar'] column='bar' alias=~] [%qualified-column qualifier=[%qualified-object ship=~ database='UNKNOWN' namespace='COLUMN-OR-CTE' name='foobar'] column='foobar' alias=~]]] order-by=~]
++  cte-bar-foobar-src
  [%cte name='src' %query from=~ scalars=~ predicate=~ group-by=~ having=~ selection=[%select top=~ bottom=~ distinct=%.n columns=~[[%qualified-column qualifier=[%qualified-object ship=~ database='UNKNOWN' namespace='COLUMN-OR-CTE' name='bar'] column='bar' alias=~] [%qualified-column qualifier=[%qualified-object ship=~ database='UNKNOWN' namespace='COLUMN-OR-CTE' name='foobar'] column='foobar' alias=~]]] order-by=~]
++  column-src-foo
  [%qualified-column qualifier=[%qualified-object ship=~ database='UNKNOWN' namespace='COLUMN' name='src'] column='foo' alias=~]
++  column-src-bar
  [%qualified-column qualifier=[%qualified-object ship=~ database='UNKNOWN' namespace='COLUMN' name='src'] column='bar' alias=~]
++  column-src-foobar
  [%qualified-column qualifier=[%qualified-object ship=~ database='UNKNOWN' namespace='COLUMN' name='src'] column='foobar' alias=~]
++  passthru-tgt
  [%table-set object=[%query-row ~['col1' 'col2' 'col3']] alias=[~ 'tgt']]
++  passthru-src
  [%table-set object=[%query-row ~['col1' 'col2' 'col3']] alias=[~ 'src']]
++  col1
  [%qualified-column qualifier=[%qualified-object ship=~ database='UNKNOWN' namespace='COLUMN-OR-CTE' name='col1'] column='col1' alias=~]
++  col2
  [%qualified-column qualifier=[%qualified-object ship=~ database='UNKNOWN' namespace='COLUMN-OR-CTE' name='col2'] column='col2' alias=~]
++  col3
  [%qualified-column qualifier=[%qualified-object ship=~ database='UNKNOWN' namespace='COLUMN-OR-CTE' name='col3'] column='col3' alias=~]
++  col4
  [%qualified-column qualifier=[%qualified-object ship=~ database='UNKNOWN' namespace='COLUMN-OR-CTE' name='col4'] column='col4' alias=~]
++  cte-bar
  [%cte name='bar' [%query [~ [%from object=[%table-set object=[%qualified-object ship=~ database='db1' namespace='dbo' name='bar'] alias=~] joins=~]] scalars=~ `[%eq [col1 ~ ~] [col2 ~ ~]] group-by=~ having=~ [%select top=~ bottom=~ distinct=%.n columns=~[col2]] ~]]

++  cte-foobar
  [%cte name='foobar' [%query [~ [%from object=[%table-set object=[%qualified-object ship=~ database='db1' namespace='dbo' name='foobar'] alias=~] joins=~]] scalars=~ `[%eq [col1 ~ ~] [[value-type=%ud value=2] ~ ~]] group-by=~ having=~ [%select top=~ bottom=~ distinct=%.n columns=~[col3 col4]] ~]]


++  one-eq-1            [%eq [literal-1 ~ ~] [literal-1 ~ ~]]
++  literal-1           [value-type=%ud value=1]
++  passthru-unaliased  [%table-set object=[%query-row ~['col1' 'col2' 'col3']] alias=~]
++  update-pred
  [%and one-eq-1 [%eq [col2 ~ ~] [[value-type=%ud value=4] ~ ~]]]

++  test-update-04
  %+  expect-eq
    !>  ~[[%transform ctes=~[cte-t1] [[%update table=foo-table columns=~['col3' 'col1'] values=~[[value-type=%t value='hello'] col2] predicate=`update-pred] ~ ~]]]
    !>  (parse:parse(current-database 'db1') "with (select *) as t1 update foo set col1=col2, col3 = 'hello' where 1 = 1 and col2 = 4")
::
:: update with three ctes and predicate
++  test-update-05
  %+  expect-eq
    !>  ~[[%transform ctes=~[cte-t1 cte-foobar cte-bar] [[%update table=foo-table columns=~['col3' 'col1'] values=~[[value-type=%t value='hello'] col2] predicate=`update-pred] ~ ~]]]
    !>  (parse:parse(current-database 'db1') "with (select *) as t1, (from foobar where col1=2 select col3, col4) as foobar, (from bar where col1=col2 select col2) as bar update foo set col1=col2, col3 = 'hello' where 1 = 1 and col2 = 4")



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
