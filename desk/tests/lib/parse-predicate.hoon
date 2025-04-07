/-  ast
/+  parse,  *test
::
:: we frequently break the rules of unit and regression tests here
:: by testing more than one thing per result, otherwise there would
:: just be too many tests
::
:: each arm tests one urql command
::
:: common things to test
:: 1) basic command works producing AST object
:: 2) multiple ASTs
:: 3) all keywords are case ambivalent
:: 4) all names follow rules for faces
:: 5) all qualifier combinations work
::
:: -test /=urql=/tests/lib/parse/hoon ~
|%
::
::  predicate
::
::  re-used components
++  select-all-columns  [%select top=~ bottom=~ columns=~[[%all %all]]]
++  foo
  [[%unqualified-column 'foo' ~] ~ ~]
++  t1-foo
  :+  :^  %qualified-column
          [%qualified-object ~ %db1 %dbo %adoptions alias=[~ 'T1']]
          'foo'
          ~
      ~
      ~
++  a1-foo
  :+  :^  %qualified-column
          [%qualified-object ~ %db1 %dbo %adoptions alias=[~ 'A1']]
          'foo'
          ~
      ~
      ~
++  foo2
  [[%unqualified-column 'foo2' ~] ~ ~]
++  t1-foo2
  :+  :^  %qualified-column
          [%qualified-object ~ %db1 %dbo %adoptions alias=[~ 'T1']]
          'foo2'
          ~
      ~
      ~
++  foo3
  [[%unqualified-column 'foo3' ~] ~ ~]
++  t1-foo3
  :+  :^  %qualified-column
          [%qualified-object ~ %db1 %dbo %adoptions alias=[~ 'T1']]
          'foo3'
          ~
      ~
      ~
++  foo4
  [[%unqualified-column 'foo4' ~] ~ ~]
++  foo5
  [[%unqualified-column 'foo5' ~] ~ ~]
++  foo6
  [[%unqualified-column 'foo6' ~] ~ ~]
++  foo7
  [[%unqualified-column 'foo7' ~] ~ ~]
++  bar
  [[%unqualified-column 'bar' ~] ~ ~]
++  t2-bar
  :+  :^  %qualified-column
          [%qualified-object ~ %db1 %dbo %adoptions alias=[~ 'T2']]
          'bar'
          ~
      ~
      ~
++  a2-bar
  :+  :^  %qualified-column
          [%qualified-object ~ %db1 %dbo %adoptions alias=[~ 'A2']]
          'bar'
          ~
      ~
      ~
++  foobar
  [[%unqualified-column 'foobar' ~] ~ ~]
++  a1-adoption-email
  :+  :^  %qualified-column
          [%qualified-object ~ %db1 %dbo %adoptions alias=[~ 'A1']]
          'adoption-email'
          alias=~
      ~
      ~
++  a2-adoption-email
  :+  :^  %qualified-column
          [%qualified-object ~ %db1 %dbo %adoptions alias=[~ 'A2']]
          'adoption-email'
          alias=~
      ~
      ~
++  a1-adoption-date
  :+  :^  %qualified-column
          [%qualified-object ~ %db1 %dbo %adoptions alias=[~ 'A1']]
          'adoption-date'
          alias=~
      ~
      ~
++  a2-adoption-date
  :+  :^  %qualified-column
          [%qualified-object ~ %db1 %dbo %adoptions alias=[~ 'A2']]
          'adoption-date'
          alias=~
      ~
      ~
++  a1-name
  :+  :^  %qualified-column
          [%qualified-object ~ %db1 %dbo %adoptions alias=[~ 'A1']]
          'name'
          alias=~
      ~
      ~
++  a2-name
  :+  :^  %qualified-column
          [%qualified-object ~ %db1 %dbo %adoptions alias=[~ 'A2']]
          'name'
          alias=~
      ~
      ~
++  a1-species
  :+  :^  %qualified-column
          [%qualified-object ~ %db1 %dbo %adoptions alias=[~ 'A1']]
          'species'
          alias=~
      ~
      ~
++  a2-species
  :+  :^  %qualified-column
          [%qualified-object ~ %db1 %dbo %adoptions alias=[~ 'A2']]
          'species'
          alias=~
      ~
      ~
++  value-literals   [[%value-literals %ud '3;2;1'] ~ ~]
++  aggregate-count-foobar
  :+  %aggregate
      function='count'
      :^  %qualified-column
          :*  %qualified-object
              ship=~
              database='UNKNOWN'
              namespace='COLUMN-OR-CTE'
              name='foobar'
              alias=~
              ==
          column='foobar'
          alias=~
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
++  or2
      [%and [%and t1-foo3-lt-any-list t1-foo2-eq-zod] foo-eq-1]
++  or3                      [%and [%eq foo3 foo4] [%eq foo5 foo6]]
++  big-or
      [%or [%or [%or and-t1f-gt-f2--t2b-in-l or2] or3] [%eq foo4 foo5]]
++  big-and                  [%and and-fb-gt-f--fb-lt-b big-or]
++  a-a-l-a-o-l-a-a-r-o-r-a-l-o-r-a
                             [%and big-and [%eq foo6 foo7]]
++  first-or                 [%or [%gt foobar foo] [%lt foobar bar]]
++  last-or
      [%or t1-foo3-lt-any-list [%and t1-foo2-eq-zod foo-eq-1]]
++  first-and                [%and first-or t1-foo-gt-foo2]
++  second-and               [%and first-and t2-bar-in-list]
++  king-and                 [%and [second-and] last-or]
::
++  select-top-10-all  [%select top=[~ 10] bottom=~ columns=~[[%all %all]]]
++  foo-table
  [%qualified-object ship=~ database='db1' namespace='dbo' name='foo' alias=~]
++  foo-table-f1
  :*  %qualified-object
      ship=~
      database='db1'
      namespace='dbo'
      name='foo'
      alias=[~ 'F1']
      ==
++  from-foo
  [~ [%from object=[%table-set object=foo-table] as-of=~ joins=~]]
++  from-foo-aliased
  [~ [%from object=[%table-set object=foo-table-f1] as-of=~ joins=~]]
++  simple-from-foo
  [%query from-foo scalars=~ ~ group-by=~ having=~ select-top-10-all ~]
++  aliased-from-foo
  [%query from-foo-aliased scalars=~ ~ group-by=~ having=~ select-top-10-all ~]
++  foo-table-row  [%query-row ~['col1' 'col2' 'col3']]
++  foo-alias-y
  :-  %table-set
      :*  %qualified-object
          ship=~
          database='db1'
          namespace='dbo'
          name='foo'
          alias=[~ 'y']
          ==
++  bar-alias-x
  :-  %table-set
      :*  %qualified-object
          ship=~
          database='db1'
          namespace='dbo'
          name='bar'
          alias=[~ 'x']
          ==
++  foo-unaliased
  :-  %table-set
      :*  %qualified-object
          ship=~
          database='db1'
          namespace='dbo'
          name='foo'
          alias=~
          ==
++  bar-unaliased
  :-  %table-set
      :*  %qualified-object
          ship=~
          database='db1'
          namespace='dbo'
          name='bar'
          alias=~
          ==
++  adoptions
  :-  %table-set
      :*  %qualified-object
          ship=~
          database='db1'
          namespace='dbo'
          name='adoptions'
          alias=[~ 'T1']
          ==
++  adoptions-t2
  :-  %table-set
      :*  %qualified-object
          ship=~
          database='db1'
          namespace='dbo'
          name='adoptions'
          alias=[~ 'T2']
          ==
++  passthru-row-y
  [%table-set object=[%query-row alias=[~ 'y'] ~['col1' 'col2' 'col3']]]
++  passthru-row-x
  [%table-set object=[%query-row alias=[~ 'x'] ~['col1' 'col2' 'col3']]]
++  passthru-unaliased
  [%table-set object=[%query-row alias=~ ~['col1' 'col2' 'col3']]]
::
::  test binary operators, varying spacing
++  test-predicate-01
  =/  query
        "FROM adoptions AS T1 JOIN adoptions AS T2 ON T1.foo = T2.bar SELECT *"
  =/  pred=(tree predicate-component:ast)  [%eq t1-foo t2-bar]
  =/  expected
        :+  %selection
            ctes=~
            :+  :*  %query
                    :-  ~
                        :^  %from
                            object=adoptions
                            as-of=~
                            :~  :*  %joined-object
                                    join=%join
                                    object=adoptions-t2
                                    as-of=~
                                    predicate=`pred
                                    ==
                                ==
                    scalars=~
                    ~
                    group-by=~
                    having=~
                    select-all-columns
                    ~
                    ==
                ~
                ~
  %+  expect-eq
    !>  ~[expected]
    !>  (parse:parse(default-database 'db1') query)
++  test-predicate-02
  =/  query  "FROM adoptions AS T1 JOIN adoptions AS T2 ON foo<>bar SELECT *"
  =/  pred=(tree predicate-component:ast)  [%neq foo bar]
  =/  expected
        :+  %selection
            ctes=~
            :+  :*  %query
                    :-  ~
                        :^  %from
                            object=adoptions
                            as-of=~
                            :~  :*  %joined-object
                                    join=%join
                                    object=adoptions-t2
                                    as-of=~
                                    predicate=`pred
                                    ==
                                ==
                    scalars=~
                    ~
                    group-by=~
                    having=~
                    select-all-columns
                    ~
                    ==
                ~
                ~
  %+  expect-eq
    !>  ~[expected]
    !>  (parse:parse(default-database 'db1') query)
++  test-predicate-03
  =/  query  "FROM adoptions AS T1 JOIN adoptions AS T2 ON foo!= bar SELECT *"
  =/  pred=(tree predicate-component:ast)  [%neq foo bar]
  =/  expected
        :+  %selection
            ctes=~
            :+  :*  %query
                    :-  ~
                        :^  %from
                            object=adoptions
                            as-of=~
                            :~  :*  %joined-object
                                    join=%join
                                    object=adoptions-t2
                                    as-of=~
                                    predicate=`pred
                                    ==
                                ==
                    scalars=~
                    ~
                    group-by=~
                    having=~
                    select-all-columns
                    ~
                    ==
                ~
                ~
  %+  expect-eq
    !>  ~[expected]
    !>  (parse:parse(default-database 'db1') query)
++  test-predicate-04
  =/  query  "FROM adoptions AS T1 JOIN adoptions AS T2 ON foo >bar SELECT *"
  =/  pred=(tree predicate-component:ast)  [%gt foo bar]
  =/  expected
        :+  %selection
            ctes=~
            :+  :*  %query
                    :-  ~
                        :^  %from
                            object=adoptions
                            as-of=~
                            :~  :*  %joined-object
                                    join=%join
                                    object=adoptions-t2
                                    as-of=~
                                    predicate=`pred
                                    ==
                                ==
                    scalars=~
                    ~
                    group-by=~
                    having=~
                    select-all-columns
                    order-by=~
                    ==
                ~
                ~
  %+  expect-eq
    !>  ~[expected]
    !>  (parse:parse(default-database 'db1') query)
++  test-predicate-05
  =/  query  "FROM adoptions AS T1 JOIN adoptions AS T2 ON foo <bar SELECT *"
  =/  pred=(tree predicate-component:ast)  [%lt foo bar]
  =/  expected
        :+  %selection
            ctes=~
            :+  :*  %query
                    :-  ~
                        :^  %from
                            object=adoptions
                            as-of=~
                            :~  :*  %joined-object
                                    join=%join
                                    object=adoptions-t2
                                    as-of=~
                                    predicate=`pred
                                    ==
                                ==
                    scalars=~
                    ~
                    group-by=~
                    having=~
                    select-all-columns
                    order-by=~
                    ==
                ~
                ~
  %+  expect-eq
    !>  ~[expected]
    !>  (parse:parse(default-database 'db1') query)
++  test-predicate-06
  =/  query  "FROM adoptions AS T1 JOIN adoptions AS T2 ON foo>= bar SELECT *"
  =/  pred=(tree predicate-component:ast)  [%gte foo bar]
  =/  expected
        :+  %selection
            ctes=~
            :+  :*  %query
                    :-  ~
                        :^  %from
                            object=adoptions
                            as-of=~
                            :~  :*  %joined-object
                                    join=%join
                                    object=adoptions-t2
                                    as-of=~
                                    predicate=`pred
                                    ==
                                ==
                    scalars=~
                    ~
                    group-by=~
                    having=~
                    select-all-columns
                    order-by=~
                    ==
                ~
                ~
  %+  expect-eq
    !>  ~[expected]
    !>  (parse:parse(default-database 'db1') query)
++  test-predicate-07
  =/  query  "FROM adoptions AS T1 JOIN adoptions AS T2 ON foo!< bar SELECT *"
  =/  pred=(tree predicate-component:ast)  [%gte foo bar]
  =/  expected
        :+  %selection
            ctes=~
            :+  :*  %query
                    :-  ~
                        :^  %from
                            object=adoptions
                            as-of=~
                            :~  :*  %joined-object
                                    join=%join
                                    object=adoptions-t2
                                    as-of=~
                                    predicate=`pred
                                    ==
                                ==
                    scalars=~
                    ~
                    group-by=~
                    having=~
                    select-all-columns
                    order-by=~
                    ==
                ~
                ~
  %+  expect-eq
    !>  ~[expected]
    !>  (parse:parse(default-database 'db1') query)
++  test-predicate-08
  =/  query  "FROM adoptions AS T1 JOIN adoptions AS T2 ON foo <= bar SELECT *"
  =/  pred=(tree predicate-component:ast)  [%lte foo bar]
  =/  expected
        :+  %selection
            ctes=~
            :+  :*  %query
                    :-  ~
                        :^  %from
                            object=adoptions
                            as-of=~
                            :~  :*  %joined-object
                                    join=%join
                                    object=adoptions-t2
                                    as-of=~
                                    predicate=`pred
                                    ==
                                ==
                    scalars=~
                    ~
                    group-by=~
                    having=~
                    select-all-columns
                    order-by=~
                    ==
                ~
                ~
  %+  expect-eq
    !>  ~[expected]
    !>  (parse:parse(default-database 'db1') query)
++  test-predicate-09
  =/  query  "FROM adoptions AS T1 JOIN adoptions AS T2 ON foo !> bar SELECT *"
  =/  pred=(tree predicate-component:ast)  [%lte foo bar]
  =/  expected
        :+  %selection
            ctes=~
            :+  :*  %query
                    :-  ~
                        :^  %from
                            object=adoptions
                            as-of=~
                            :~  :*  %joined-object
                                    join=%join
                                    object=adoptions-t2
                                    as-of=~
                                    predicate=`pred
                                    ==
                                ==
                    scalars=~
                    ~
                    group-by=~
                    having=~
                    select-all-columns
                    order-by=~
                    ==
                ~
                ~
  %+  expect-eq
    !>  ~[expected]
    !>  (parse:parse(default-database 'db1') query)
++  test-predicate-10
  =/  query  "FROM foo WHERE foobar EQUIV bar SELECT *"
  =/  pred=(tree predicate-component:ast)  [%equiv foobar bar]
  =/  expected
        :+  %selection
            ctes=~
            :+  :*  %query
                    from-foo
                    scalars=~
                    `pred
                    group-by=~
                    having=~
                    [%select top=~ bottom=~ columns=~[[%all %all]]]
                    ~
                    ==
                ~
                ~
  %+  expect-eq
    !>  ~[expected]
    !>  (parse:parse(default-database 'db1') query)
++  test-predicate-11
  =/  query  "FROM foo WHERE foobar NOT EQUIV bar SELECT *"
  =/  pred=(tree predicate-component:ast)  [%not-equiv foobar bar]
  =/  expected
        :+  %selection
            ctes=~
            :+  :*  %query
                    from-foo
                    scalars=~
                    `pred
                    group-by=~
                    having=~
                    select-all-columns
                    order-by=~
                    ==
                ~
                ~
  %+  expect-eq
    !>  ~[expected]
    !>  (parse:parse(default-database 'db1') query)
::
::  remaining simple predicates, varying spacing and keywork casing
++  test-predicate-12
  =/  query  "FROM adoptions AS T1 JOIN adoptions AS T2 ON T1.foo = T2.bar ".
    " WHERE foobar  Not  Between foo  And bar ".
    " SELECT *"
  =/  joinpred=(tree predicate-component:ast)  [%eq t1-foo t2-bar]
  =/  pred=(tree predicate-component:ast)
        [%not-between foobar-gte-foo foobar-lte-bar]
  =/  expected
        :+  %selection
            ctes=~
            :+  :*  %query
                    :-  ~
                        :^  %from
                            object=adoptions
                            as-of=~
                            :~  :*  %joined-object
                                    join=%join
                                    object=adoptions-t2
                                    as-of=~
                                    predicate=`joinpred
                                    ==
                                ==
                    scalars=~
                    `pred
                    group-by=~
                    having=~
                    select-all-columns
                    order-by=~
                    ==
                ~
                ~
  %+  expect-eq
    !>  ~[expected]
    !>  (parse:parse(default-database 'db1') query)
++  test-predicate-13
  =/  query  "FROM adoptions AS T1 JOIN adoptions AS T2 ON T1.foo = T2.bar ".
    " WHERE foobar  Not  Between foo   bar ".
    " SELECT *"
  =/  joinpred=(tree predicate-component:ast)  [%eq t1-foo t2-bar]
  =/  pred=(tree predicate-component:ast)
        [%not-between foobar-gte-foo foobar-lte-bar]
  =/  expected
        :+  %selection
            ctes=~
            :+  :*  %query
                    :-  ~
                        :^  %from
                            object=adoptions
                            as-of=~
                            :~  :*  %joined-object
                                    join=%join
                                    object=adoptions-t2
                                    as-of=~
                                    predicate=`joinpred
                                    ==
                                ==
                    scalars=~
                    `pred
                    group-by=~
                    having=~
                    select-all-columns
                    order-by=~
                    ==
                ~
                ~
  %+  expect-eq
    !>  ~[expected]
    !>  (parse:parse(default-database 'db1') query)
++  test-predicate-14
  =/  query  "FROM adoptions AS T1 JOIN adoptions AS T2 ON T1.foo = T2.bar ".
    " WHERE foobar  Between foo  And bar ".
    " SELECT *"
  =/  joinpred=(tree predicate-component:ast)  [%eq t1-foo t2-bar]
  =/  pred=(tree predicate-component:ast)
        [%between foobar-gte-foo foobar-lte-bar]
  =/  expected
        :+  %selection
            ctes=~
            :+  :*  %query
                    :-  ~
                        :^  %from
                            object=adoptions
                            as-of=~
                            :~  :*  %joined-object
                                    join=%join
                                    object=adoptions-t2
                                    as-of=~
                                    predicate=`joinpred
                                    ==
                                ==
                    scalars=~
                    `pred
                    group-by=~
                    having=~
                    select-all-columns
                    order-by=~
                    ==
                ~
                ~
  %+  expect-eq
    !>  ~[expected]
    !>  (parse:parse(default-database 'db1') query)
++  test-predicate-15
  =/  query  "FROM adoptions AS T1 JOIN adoptions AS T2 ON T1.foo = T2.bar ".
    " WHERE foobar between foo  And bar ".
    " SELECT *"
  =/  joinpred=(tree predicate-component:ast)  [%eq t1-foo t2-bar]
  =/  pred=(tree predicate-component:ast)
        [%between foobar-gte-foo foobar-lte-bar]
  =/  expected
        :+  %selection
            ctes=~
            :+  :*  %query
                    :-  ~
                        :^  %from
                            object=adoptions
                            as-of=~
                            :~  :*  %joined-object
                                    join=%join
                                    object=adoptions-t2
                                    as-of=~
                                    predicate=`joinpred
                                    ==
                                ==
                    scalars=~
                    `pred
                    group-by=~
                    having=~
                    select-all-columns
                    order-by=~
                    ==
                ~
                ~
  %+  expect-eq
    !>  ~[expected]
    !>  (parse:parse(default-database 'db1') query)
++  test-predicate-16
  =/  query  "FROM adoptions AS T1 JOIN adoptions AS T2 ON T1.foo = T2.bar ".
    " WHERE T1.foo>=aLl bar ".
    " SELECT *"
  =/  joinpred=(tree predicate-component:ast)  [%eq t1-foo t2-bar]
  =/  pred=(tree predicate-component:ast)      [%gte t1-foo [%all bar ~]]
  =/  expected
        :+  %selection
            ctes=~
            :+  :*  %query
                    :-  ~
                        :^  %from
                            object=adoptions
                            as-of=~
                            :~  :*  %joined-object
                                    join=%join
                                    object=adoptions-t2
                                    as-of=~
                                    predicate=`joinpred
                                    ==
                                ==
                    scalars=~
                    `pred
                    group-by=~
                    having=~
                    select-all-columns
                    order-by=~
                    ==
                ~
                ~
  %+  expect-eq
    !>  ~[expected]
    !>  (parse:parse(default-database 'db1') query)
++  test-predicate-17
  =/  query  "FROM adoptions AS T1 JOIN adoptions AS T2 ON T1.foo = T2.bar ".
    " WHERE T1.foo nOt In bar ".
    " SELECT *"
  =/  joinpred=(tree predicate-component:ast)  [%eq t1-foo t2-bar]
  =/  pred=(tree predicate-component:ast)      [%not-in t1-foo bar]
  =/  expected
        :+  %selection
            ctes=~
            :+  :*  %query
                    :-  ~
                        :^  %from
                            object=adoptions
                            as-of=~
                            :~  :*  %joined-object
                                    join=%join
                                    object=adoptions-t2
                                    as-of=~
                                    predicate=`joinpred
                                    ==
                                ==
                    scalars=~
                    `pred
                    group-by=~
                    having=~
                    select-all-columns
                    order-by=~
                    ==
                ~
                ~
  %+  expect-eq
    !>  ~[expected]
    !>  (parse:parse(default-database 'db1') query)
++  test-predicate-18
  =/  query  "FROM adoptions AS T1 JOIN adoptions AS T2 ON T1.foo = T2.bar ".
    " WHERE T1.foo not in (1,2,3) ".
    " SELECT *"
  =/  joinpred=(tree predicate-component:ast)  [%eq t1-foo t2-bar]
  =/  pred=(tree predicate-component:ast)      [%not-in t1-foo value-literals]
  =/  expected
        :+  %selection
            ctes=~
            :+  :*  %query
                    :-  ~
                        :^  %from
                            object=adoptions
                            as-of=~
                            :~  :*  %joined-object
                                    join=%join
                                    object=adoptions-t2
                                    as-of=~
                                    predicate=`joinpred
                                    ==
                                ==
                    scalars=~
                    `pred
                    group-by=~
                    having=~
                    select-all-columns
                    order-by=~
                    ==
                ~
                ~
  %+  expect-eq
    !>  ~[expected]
    !>  (parse:parse(default-database 'db1') query)
++  test-predicate-19
  =/  query  "FROM adoptions AS T1 JOIN adoptions AS T2 ON T1.foo = T2.bar ".
    " WHERE T1.foo in bar ".
    " SELECT *"
  =/  joinpred=(tree predicate-component:ast)  [%eq t1-foo t2-bar]
  =/  pred=(tree predicate-component:ast)      [%in t1-foo bar]
  =/  expected
        :+  %selection
            ctes=~
            :+  :*  %query
                    :-  ~
                        :^  %from
                            object=adoptions
                            as-of=~
                            :~  :*  %joined-object
                                    join=%join
                                    object=adoptions-t2
                                    as-of=~
                                    predicate=`joinpred
                                    ==
                                ==
                    scalars=~
                    `pred
                    group-by=~
                    having=~
                    select-all-columns
                    order-by=~
                    ==
                ~
                ~
  %+  expect-eq
    !>  ~[expected]
    !>  (parse:parse(default-database 'db1') query)
++  test-predicate-20
  =/  query  "FROM adoptions AS T1 JOIN adoptions AS T2 ON T1.foo = T2.bar ".
    " WHERE T1.foo in (1,2,3) ".
    " SELECT *"
  =/  joinpred=(tree predicate-component:ast)  [%eq t1-foo t2-bar]
  =/  pred=(tree predicate-component:ast)      [%in t1-foo value-literals]
  =/  expected
        :+  %selection
            ctes=~
            :+  :*  %query
                    :-  ~
                        :^  %from
                            object=adoptions
                            as-of=~
                            :~  :*  %joined-object
                                    join=%join
                                    object=adoptions-t2
                                    as-of=~
                                    predicate=`joinpred
                                    ==
                                ==
                    scalars=~
                    `pred
                    group-by=~
                    having=~
                    select-all-columns
                    order-by=~
                    ==
                ~
                ~
  %+  expect-eq
    !>  ~[expected]
    !>  (parse:parse(default-database 'db1') query)
++  test-predicate-21
  =/  query  "FROM adoptions AS T1 JOIN adoptions AS T2 ON T1.foo = T2.bar ".
    " WHERE NOT  EXISTS  T1.foo ".
    " SELECT *"
  =/  joinpred=(tree predicate-component:ast)  [%eq t1-foo t2-bar]
  =/  pred=(tree predicate-component:ast)      [%not-exists t1-foo ~]
  =/  expected
        :+  %selection
            ctes=~
            :+  :*  %query
                    :-  ~
                        :^  %from
                            object=adoptions
                            as-of=~
                            :~  :*  %joined-object
                                    join=%join
                                    object=adoptions-t2
                                    as-of=~
                                    predicate=`joinpred
                                    ==
                                ==
                    scalars=~
                    `pred
                    group-by=~
                    having=~
                    select-all-columns
                    order-by=~
                    ==
                ~
                ~
  %+  expect-eq
    !>  ~[expected]
    !>  (parse:parse(default-database 'db1') query)
++  test-predicate-22
  =/  query  "FROM adoptions AS T1 JOIN adoptions AS T2 ON T1.foo = T2.bar ".
    " WHERE NOT  exists  foo ".
    " SELECT *"
  =/  joinpred=(tree predicate-component:ast)  [%eq t1-foo t2-bar]
  =/  pred=(tree predicate-component:ast)      [%not-exists foo ~]
  =/  expected
        :+  %selection
            ctes=~
            :+  :*  %query
                    :-  ~
                        :^  %from
                            object=adoptions
                            as-of=~
                            :~  :*  %joined-object
                                    join=%join
                                    object=adoptions-t2
                                    as-of=~
                                    predicate=`joinpred
                                    ==
                                ==
                    scalars=~
                    `pred
                    group-by=~
                    having=~
                    select-all-columns
                    order-by=~
                    ==
                ~
                ~
  %+  expect-eq
    !>  ~[expected]
    !>  (parse:parse(default-database 'db1') query)
++  test-predicate-23
  =/  query  "FROM adoptions AS T1 JOIN adoptions AS T2 ON T1.foo = T2.bar ".
    " WHERE EXISTS T1.foo ".
    " SELECT *"
  =/  joinpred=(tree predicate-component:ast)  [%eq t1-foo t2-bar]
  =/  pred=(tree predicate-component:ast)      [%exists t1-foo ~]
  =/  expected
        :+  %selection
            ctes=~
            :+  :*  %query
                    :-  ~
                        :^  %from
                            object=adoptions
                            as-of=~
                            :~  :*  %joined-object
                                    join=%join
                                    object=adoptions-t2
                                    as-of=~
                                    predicate=`joinpred
                                    ==
                                ==
                    scalars=~
                    `pred
                    group-by=~
                    having=~
                    select-all-columns
                    order-by=~
                    ==
                ~
                ~
  %+  expect-eq
    !>  ~[expected]
    !>  (parse:parse(default-database 'db1') query)
++  test-predicate-24
  =/  query  "FROM adoptions AS T1 JOIN adoptions AS T2 ON T1.foo = T2.bar ".
    " WHERE EXISTS  foo ".
    " SELECT *"
  =/  joinpred=(tree predicate-component:ast)  [%eq t1-foo t2-bar]
  =/  pred=(tree predicate-component:ast)      [%exists foo ~]
  =/  expected
        :+  %selection
            ctes=~
            :+  :*  %query
                    :-  ~
                        :^  %from
                            object=adoptions
                            as-of=~
                            :~  :*  %joined-object
                                    join=%join
                                    object=adoptions-t2
                                    as-of=~
                                    predicate=`joinpred
                                    ==
                                ==
                    scalars=~
                    `pred
                    group-by=~
                    having=~
                    select-all-columns
                    order-by=~
                    ==
                ~
                ~
  %+  expect-eq
    !>  ~[expected]
    !>  (parse:parse(default-database 'db1') query)
::
::  test conjunctions, varying spacing and keyword casing
++  test-predicate-25
  =/  query  "FROM adoptions AS T1 JOIN adoptions AS T2 ON T1.foo = T2.bar ".
    " WHERE foobar >=foo And foobar<=bar ".
    " SELECT *"
  =/  joinpred=(tree predicate-component:ast)  [%eq t1-foo t2-bar]
  =/  pred=(tree predicate-component:ast)      and-fb-gte-f--fb-lte-b
  =/  expected
        :+  %selection
            ctes=~
            :+  :*  %query
                    :-  ~
                        :^  %from
                            object=adoptions
                            as-of=~
                            :~  :*  %joined-object
                                    join=%join
                                    object=adoptions-t2
                                    as-of=~
                                    predicate=`joinpred
                                    ==
                                ==
                    scalars=~
                    `pred
                    group-by=~
                    having=~
                    select-all-columns
                    order-by=~
                    ==
                ~
                ~
  %+  expect-eq
    !>  ~[expected]
    !>  (parse:parse(default-database 'db1') query)
::
:: expected/actual match
++  test-predicate-26
  =/  query  "FROM adoptions AS T1 JOIN adoptions AS T2 ON T1.foo = T2.bar ".
    " WHERE foobar >=foo And foobar<=bar ".
    " and T1.foo2 = ~zod ".
    " SELECT *"
  =/  joinpred=(tree predicate-component:ast)  [%eq t1-foo t2-bar]
  =/  pred=(tree predicate-component:ast)
        :+  %and
            :+  %and
                [%gte foobar foo]
                [%lte foobar bar]
            :+  %eq
                t1-foo2
                [[%p 0] ~ ~]
  =/  expected
        :+  %selection
            ctes=~
            :+  :*  %query
                    :-  ~
                        :^  %from
                            object=adoptions
                            as-of=~
                            :~  :*  %joined-object
                                    join=%join
                                    object=adoptions-t2
                                    as-of=~
                                    predicate=`joinpred
                                    ==
                                ==
                    scalars=~
                    `pred
                    group-by=~
                    having=~
                    select-all-columns
                    order-by=~
                    ==
                ~
                ~
  %+  expect-eq
    !>  ~[expected]
    !>  (parse:parse(default-database 'db1') query)
::
:: expected/actual match
++  test-predicate-27
  =/  query  "FROM adoptions AS T1 JOIN adoptions AS T2 ON T1.foo = T2.bar ".
    " WHERE foobar >=foo And foobar<=bar ".
    " and T1.foo2 = ~zod ".
    " or T2.bar in (1,2,3)".
    " SELECT *"
  =/  joinpred=(tree predicate-component:ast)  [%eq t1-foo t2-bar]
  =/  pred=(tree predicate-component:ast)      and-and-or
  =/  expected
        :+  %selection
            ctes=~
            :+  :*  %query
                    :-  ~
                        :^  %from
                            object=adoptions
                            as-of=~
                            :~  :*  %joined-object
                                    join=%join
                                    object=adoptions-t2
                                    as-of=~
                                    predicate=`joinpred
                                    ==
                                ==
                    scalars=~
                    `pred
                    group-by=~
                    having=~
                    select-all-columns
                    order-by=~
                    ==
                ~
                ~
  %+  expect-eq
    !>  ~[expected]
    !>  (parse:parse(default-database 'db1') query)
::
:: expected/actual match
++  test-predicate-28
  =/  query  "FROM adoptions AS T1 JOIN adoptions AS T2 ON T1.foo = T2.bar ".
    " WHERE foobar >=foo And foobar<=bar ".
    " and T1.foo2 = ~zod ".
    " or  ".
    " foobar>=foo ".
    " AND   T1.foo2=~zod ".
    " SELECT *"
  =/  joinpred=(tree predicate-component:ast)  [%eq t1-foo t2-bar]
  =/  pred=(tree predicate-component:ast)      and-and-or-and
  =/  expected
        :+  %selection
            ctes=~
            :+  :*  %query
                    :-  ~
                        :^  %from
                            object=adoptions
                            as-of=~
                            :~  :*  %joined-object
                                    join=%join
                                    object=adoptions-t2
                                    as-of=~
                                    predicate=`joinpred
                                    ==
                                ==
                    scalars=~
                    `pred
                    group-by=~
                    having=~
                    select-all-columns
                    order-by=~
                    ==
                ~
                ~
  %+  expect-eq
    !>  ~[expected]
    !>  (parse:parse(default-database 'db1') query)
::
:: expected/actual match
++  test-predicate-29
  =/  query  "FROM adoptions AS T1 JOIN adoptions AS T2 ON T1.foo = T2.bar ".
    " WHERE foobar >=foo And foobar<=bar ".
    " and T1.foo2 = ~zod ".
    " or  ".
    " foobar>=foo ".
    " AND   T1.foo2=~zod ".
    "  OR ".
    " foo = 1 ".
    " AND T1.foo3 < any (1,2,3) ".
    " SELECT *"
  =/  joinpred=(tree predicate-component:ast)  [%eq t1-foo t2-bar]
  =/  pred=(tree predicate-component:ast)      and-and-or-and-or-and
  =/  expected
        :+  %selection
            ctes=~
            :+  :*  %query
                    :-  ~
                        :^  %from
                            object=adoptions
                            as-of=~
                            :~  :*  %joined-object
                                    join=%join
                                    object=adoptions-t2
                                    as-of=~
                                    predicate=`joinpred
                                    ==
                                ==
                    scalars=~
                    `pred
                    group-by=~
                    having=~
                    select-all-columns
                    order-by=~
                    ==
                ~
                ~
  %+  expect-eq
    !>  ~[expected]
    !>  (parse:parse(default-database 'db1') query)
::
:: simple nesting
++  test-predicate-30
  =/  query  "FROM adoptions AS T1 JOIN adoptions AS T2 ON T1.foo = T2.bar ".
    " WHERE (foobar > foo OR foobar < bar) ".
    " AND T1.foo>foo2 ".
    " AND T2.bar IN (1,2,3) ".
    " AND (T1.foo3< any (1,2,3) OR T1.foo2=~zod AND foo=1 ) ".
    " SELECT *"
  =/  joinpred=(tree predicate-component:ast)  [%eq t1-foo t2-bar]
  =/  pred=(tree predicate-component:ast)
        :+  %and
            :+  %and
                :+  %and
                    first-or
                    t1-foo-gt-foo2
                :+  %in
                    t2-bar
                    value-literals
            :+  %or
                t1-foo3-lt-any-list
                :+  %and
                    t1-foo2-eq-zod
                    foo-eq-1
  =/  expected
        :+  %selection
            ctes=~
            :+  :*  %query
                    :-  ~
                        :^  %from
                            object=adoptions
                            as-of=~
                            :~  :*  %joined-object
                                    join=%join
                                    object=adoptions-t2
                                    as-of=~
                                    predicate=`joinpred
                                    ==
                                ==
                    scalars=~
                    `pred
                    group-by=~
                    having=~
                    select-all-columns
                    order-by=~
                    ==
                ~
                ~
  %+  expect-eq
    !>  ~[expected]
    !>  (parse:parse(default-database 'db1') query)
::
::  nesting
++  test-predicate-31
  =/  query  "FROM adoptions AS T1 JOIN adoptions AS T2 ON T1.foo = T2.bar ".
    " WHERE foobar > foo AND foobar < bar ".
    " AND ( T1.foo>foo2 AND T2.bar IN (1,2,3) ".
    "       OR (T1.foo3< any (1,2,3) AND T1.foo2=~zod AND foo=1 ) ".
    "       OR (foo3=foo4 AND foo5=foo6) ".
    "       OR foo4=foo5 ".
    "      ) ".
    " AND foo6=foo7".
    " SELECT *"
  =/  joinpred=(tree predicate-component:ast)  [%eq t1-foo t2-bar]
  =/  pred=(tree predicate-component:ast)      a-a-l-a-o-l-a-a-r-o-r-a-l-o-r-a
  =/  expected
        :+  %selection
            ctes=~
            :+  :*  %query
                    :-  ~
                        :^  %from
                            object=adoptions
                            as-of=~
                            :~  :*  %joined-object
                                    join=%join
                                    object=adoptions-t2
                                    as-of=~
                                    predicate=`joinpred
                                    ==
                                ==
                    scalars=~
                    `pred
                    group-by=~
                    having=~
                    select-all-columns
                    order-by=~
                    ==
                ~
                ~
  %+  expect-eq
    !>  ~[expected]
    !>  (parse:parse(default-database 'db1') query)
::
::  simple nesting, superfluous () around entire predicate
++  test-predicate-32
  =/  query  "FROM adoptions AS T1 JOIN adoptions AS T2 ON T1.foo = T2.bar ".
    " WHERE ((foobar > foo OR foobar < bar) ".
    " AND T1.foo>foo2 ".
    " AND T2.bar IN (1,2,3) ".
    " AND (T1.foo3< any (1,2,3) OR T1.foo2=~zod AND foo=1 )) ".
    " SELECT *"
  =/  joinpred=(tree predicate-component:ast)  [%eq t1-foo t2-bar]
  =/  pred=(tree predicate-component:ast)      king-and
  =/  expected
        :+  %selection
            ctes=~
            :+  :*  %query
                    :-  ~
                        :^  %from
                            object=adoptions
                            as-of=~
                            :~  :*  %joined-object
                                    join=%join
                                    object=adoptions-t2
                                    as-of=~
                                    predicate=`joinpred
                                    ==
                                ==
                    scalars=~
                    `pred
                    group-by=~
                    having=~
                    select-all-columns
                    order-by=~
                    ==
                ~
                ~
  %+  expect-eq
    !>  ~[expected]
    !>  (parse:parse(default-database 'db1') query)
::
::  aggregate inequality
++  test-predicate-33
  =/  select  "from foo where  count( foobar )  > 10 select * "
  =/  pred=(tree predicate-component:ast)
        [%gt [aggregate-count-foobar ~ ~] literal-10]
  =/  expected
        :+  %selection
            ctes=~
            :+  :*  %query
                    from-foo
                    scalars=~
                    `pred
                    group-by=~
                    having=~
                    select-all-columns
                    order-by=~
                    ==
                ~
                ~
  %+  expect-eq
    !>  ~[expected]
    !>  (parse:parse(default-database 'db1') select)
::
::  aggregate inequality, no whitespace
++  test-predicate-34
  =/  select  "from foo where count(foobar) > 10 select *"
  =/  pred=(tree predicate-component:ast)
        [%gt [aggregate-count-foobar ~ ~] literal-10]
  =/  expected
        :+  %selection
            ctes=~
            :+  :*  %query
                    from-foo
                    scalars=~
                    `pred
                    group-by=~
                    having=~
                    select-all-columns
                    order-by=~
                    ==
                ~
                ~
  %+  expect-eq
    !>  ~[expected]
    !>  (parse:parse(default-database 'db1') select)
::
::  aggregate equality
++  test-predicate-35
  =/  select  "from foo where bar = count(foobar) select *"
  =/  pred=(tree predicate-component:ast)
        [%eq bar [aggregate-count-foobar ~ ~]]
  =/  expected
        :+  %selection
            ctes=~
            :+  :*  %query
                    from-foo
                    scalars=~
                    `pred
                    group-by=~
                    having=~
                    select-all-columns
                    order-by=~
                    ==
                ~
                ~
  %+  expect-eq
    !>  ~[expected]
    !>  (parse:parse(default-database 'db1') select)
::
::  complext predicate, bug test
++  test-predicate-36
  =/  query  "FROM adoptions AS A1 JOIN adoptions AS A2 ON A1.foo = A2.bar ".
    " WHERE  A1.adoption-email = A2.adoption-email  ".
    "  AND     A1.adoption-date = A2.adoption-date  ".
    "  AND    foo = bar  ".
    "  AND ((A1.name = A2.name AND A1.species > A2.species) ".
    "       OR ".
    "       (A1.name > A2.name AND A1.species = A2.species) ".
    "       OR ".
    "      (A1.name > A2.name AND A1.species > A2.species) ".
    "     ) ".
    " SELECT *"
  =/  joinpred=(tree predicate-component:ast)  [%eq a1-foo a2-bar]
  =/  pred=(tree predicate-component:ast)
        :+  %and
            :+  %and
                :+  %and
                    [%eq a1-adoption-email a2-adoption-email]
                    [%eq a1-adoption-date a2-adoption-date]
                [%eq foo bar]
            :+  %or
                :+  %or
                    [%and [%eq a1-name a2-name] [%gt a1-species a2-species]]
                    [%and [%gt a1-name a2-name] [%eq a1-species a2-species]]
                [%and [%gt a1-name a2-name] [%gt a1-species a2-species]]
  =/  expected
        :+  %selection
            ctes=~
            :+  :*  %query
                    :-  ~
                        :^  %from
                            :-  %table-set
                                :*  %qualified-object
                                    ship=~
                                    database='db1'
                                    namespace='dbo'
                                    name='adoptions'
                                    alias=[~ 'A1']
                                    ==
                            as-of=~
                            :~  :*  %joined-object
                                    join=%join
                                    :-  %table-set
                                        :*  %qualified-object
                                            ship=~
                                            database='db1'
                                            namespace='dbo'
                                            name='adoptions'
                                            alias=[~ 'A2']
                                            ==
                                    as-of=~
                                    predicate=`joinpred
                                    ==
                                ==
                    scalars=~
                    `pred
                    group-by=~
                    having=~
                    select-all-columns
                    order-by=~
                    ==
                ~
                ~
  %+  expect-eq
    !>  ~[expected]
    !>  (parse:parse(default-database 'db1') query)
::
::  outer parens
++  test-predicate-37
  =/  query
        "FROM adoptions AS T1 JOIN adoptions AS T2 ON (T1.foo = T2.bar) ".
        "SELECT *"
  =/  pred=(tree predicate-component:ast)  [%eq t1-foo t2-bar]
  =/  expected
        :+  %selection
            ctes=~
            :+  :*  %query
                    :-  ~
                        :^  %from
                            object=adoptions
                            as-of=~
                            :~  :*  %joined-object
                                    join=%join
                                    object=adoptions-t2
                                    as-of=~
                                    predicate=`pred
                                    ==
                                ==
                    scalars=~
                    ~
                    group-by=~
                    having=~
                    select-all-columns
                    order-by=~
                    ==
                ~
                ~
  %+  expect-eq
    !>  ~[expected]
    !>  (parse:parse(default-database 'db1') query)
--
