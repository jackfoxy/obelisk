/-  ast
/+  parse,  *test
|%

::@@@@@@@@@@@@@@@@@@@@@@@@@

::  re-used components
++  all-columns  [%qualified-object ship=~ database='ALL' namespace='ALL' name='ALL']
++  select-all-columns  [%select top=~ bottom=~ columns=~[all-columns]]
++  foo
  [[%qualified-column [%qualified-object ~ 'UNKNOWN' 'COLUMN-OR-CTE' 'foo'] 'foo' ~] ~ ~]
++  t1-foo
  [[%qualified-column [%qualified-object ~ 'UNKNOWN' 'COLUMN' 'T1'] 'foo' ~] ~ ~]

++  foo2
  [[%qualified-column [%qualified-object ~ 'UNKNOWN' 'COLUMN-OR-CTE' 'foo2'] 'foo2' ~] ~ ~]
++  t1-foo2
  [[%qualified-column [%qualified-object ~ 'UNKNOWN' 'COLUMN' 'T1'] 'foo2' ~] ~ ~]
++  foo3
  [[%qualified-column [%qualified-object ~ 'UNKNOWN' 'COLUMN-OR-CTE' 'foo3'] 'foo3' ~] ~ ~]
++  t1-foo3
  [[%qualified-column [%qualified-object ~ 'UNKNOWN' 'COLUMN' 'T1'] 'foo3' ~] ~ ~]
++  foo4
  [[%qualified-column [%qualified-object ~ 'UNKNOWN' 'COLUMN-OR-CTE' 'foo4'] 'foo4' ~] ~ ~]
++  foo5
  [[%qualified-column [%qualified-object ~ 'UNKNOWN' 'COLUMN-OR-CTE' 'foo5'] 'foo5' ~] ~ ~]
++  foo6
  [[%qualified-column [%qualified-object ~ 'UNKNOWN' 'COLUMN-OR-CTE' 'foo6'] 'foo6' ~] ~ ~]
++  foo7
  [[%qualified-column [%qualified-object ~ 'UNKNOWN' 'COLUMN-OR-CTE' 'foo7'] 'foo7' ~] ~ ~]
++  bar
  [[%qualified-column [%qualified-object ~ 'UNKNOWN' 'COLUMN-OR-CTE' 'bar'] 'bar' ~] ~ ~]
++  t2-bar
  [[%qualified-column [%qualified-object ~ 'UNKNOWN' 'COLUMN' 'T2'] 'bar' ~] ~ ~]
++  foobar
  [[%qualified-column [%qualified-object ~ 'UNKNOWN' 'COLUMN-OR-CTE' 'foobar'] 'foobar' ~] ~ ~]
++  a1-adoption-email
  [[%qualified-column [%qualified-object ~ 'UNKNOWN' 'COLUMN' 'A1'] 'adoption-email' ~] ~ ~]
++  a2-adoption-email
  [[%qualified-column [%qualified-object ~ 'UNKNOWN' 'COLUMN' 'A2'] 'adoption-email' ~] ~ ~]
++  a1-adoption-date
  [[%qualified-column [%qualified-object ~ 'UNKNOWN' 'COLUMN' 'A1'] 'adoption-date' ~] ~ ~]
++  a2-adoption-date
  [[%qualified-column [%qualified-object ~ 'UNKNOWN' 'COLUMN' 'A2'] 'adoption-date' ~] ~ ~]
++  a1-name
  [[%qualified-column [%qualified-object ~ 'UNKNOWN' 'COLUMN' 'A1'] 'name' ~] ~ ~]
++  a2-name
  [[%qualified-column [%qualified-object ~ 'UNKNOWN' 'COLUMN' 'A2'] 'name' ~] ~ ~]
++  a1-species
  [[%qualified-column [%qualified-object ~ 'UNKNOWN' 'COLUMN' 'A1'] 'species' ~] ~ ~]
++  a2-species
  [[%qualified-column [%qualified-object ~ 'UNKNOWN' 'COLUMN' 'A2'] 'species' ~] ~ ~]
++  value-literals   [[%value-literals %ud '3;2;1'] ~ ~]
++  aggregate-count-foobar
  [%aggregate function='count' source=[%qualified-column qualifier=[%qualified-object ship=~ database='UNKNOWN' namespace='COLUMN-OR-CTE' name='foobar'] column='foobar' alias=~]]
++  literal-10           [[%ud 10] ~ ~]

::
::  re-used simple predicates
++  foobar-gte-foo       [%gte foobar foo]
++  foobar-lte-bar       [%lte foobar bar]
++  foo-eq-1             [%eq foo [[%ud 1] ~ ~]]
++  t1-foo-gt-foo2       [%gt t1-foo foo2]
++  t2-bar-in-list       [%in t2-bar value-literals]
++  t1-foo2-eq-zod       [%eq t1-foo2 [[%p 0] ~ ~]]
++  t1-foo3-lt-any-list  [%lt t1-foo3 [%any value-literals ~]]
::
::  re-used predicates with conjunctions
++  and-fb-gte-f--fb-lte-b   [%and foobar-gte-foo foobar-lte-bar]
++  and-fb-gte-f--t1f2-eq-z  [%and foobar-gte-foo t1-foo2-eq-zod]
++  and-f-eq-1--t1f3-lt-any  [%and foo-eq-1 t1-foo3-lt-any-list]
++  and-and                  [%and and-fb-gte-f--fb-lte-b t1-foo2-eq-zod]
++  and-and-or               [%or and-and t2-bar-in-list]
++  and-and-or-and           [%or and-and and-fb-gte-f--t1f2-eq-z]
++  and-and-or-and-or-and    [%or and-and-or-and and-f-eq-1--t1f3-lt-any]
::
::  predicates with conjunctions and nesting
++  and-fb-gt-f--fb-lt-b     [%and [%gt foobar foo] [%lt foobar bar]]
++  and-t1f-gt-f2--t2b-in-l  [%and t1-foo-gt-foo2 t2-bar-in-list]
++  or2                      [%and [%and t1-foo3-lt-any-list t1-foo2-eq-zod] foo-eq-1]
++  or3                      [%and [%eq foo3 foo4] [%eq foo5 foo6]]
++  big-or                   [%or [%or [%or and-t1f-gt-f2--t2b-in-l or2] or3] [%eq foo4 foo5]]
++  big-and                  [%and and-fb-gt-f--fb-lt-b big-or]
++  a-a-l-a-o-l-a-a-r-o-r-a-l-o-r-a
                             [%and big-and [%eq foo6 foo7]]
++  first-or                 [%or [%gt foobar foo] [%lt foobar bar]]
++  last-or                  [%or t1-foo3-lt-any-list [%and t1-foo2-eq-zod foo-eq-1]]
++  first-and                [%and first-or t1-foo-gt-foo2]
++  second-and               [%and first-and t2-bar-in-list]
++  king-and                 [%and [second-and] last-or]

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
::  =/  expected
::    [%transform ctes=~ [[%query [~ [%from object=[%table-set object=[%qualified-object ship=~ database='db1' namespace='dbo' name='adoptions'] alias=[~ 'T1']] joins=~[[%joined-object join=%join object=[%table-set object=[%qualified-object ship=~ database='db1' namespace='dbo' name='adoptions'] alias=[~ 'T2']] predicate=`joinpred]]]] scalars=~ `pred group-by=~ having=~ select-all-columns ~] ~ ~]]
::  %+  expect-eq
::    !>  ~[expected]
::    !>  (parse:parse(default-database 'db1') query)


--
