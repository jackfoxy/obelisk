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

++  test-create-table-3
  =/  expected  [%create-table table=[%qualified-object ship=~ database='db1' namespace='dbo' name='my-table'] columns=~[[%column name='col1' column-type=%t] [%column name='col2' column-type=%p] [%column name='col3' column-type=%ud]] clustered=%.n pri-indx=~[[%ordered-column name='col1' is-ascending=%.y] [%ordered-column name='col2' is-ascending=%.y]] foreign-keys=~[[%foreign-key name='fk' table=[%qualified-object ship=~ database='db1' namespace='dbo' name='my-table'] columns=~[[%ordered-column name='col1' is-ascending=%.y] [%ordered-column name='col2' is-ascending=%.n]] reference-table=[%qualified-object ship=~ database='db1' namespace='ns' name='fk-table'] reference-columns=~['col19' 'col20'] referential-integrity=~[%delete-cascade]]]]
  =/  urql  "create table my-table (col1 %t,col2 %p,col3 %ud) primary key (col1, col2) foreign key fk (col1,col2 desc) reFerences ns.fk-table (col19, col20) on update no action on delete cascade"
  %+  expect-eq
    !>  ~[expected]
    !>  (parse:parse(default-database 'db1') urql)


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
