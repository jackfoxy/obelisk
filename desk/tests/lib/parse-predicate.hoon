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
++  select-all-columns  [%select top=~ columns=~[[%all %all]]]
++  foo
  [[%unqualified-column 'foo' ~] ~ ~]
++  t1-foo
  :+  :^  %qualified-column
          [%qualified-table ~ %db1 %dbo %adoptions alias=[~ 'T1']]
          'foo'
          ~
      ~
      ~
++  a1-foo
  :+  :^  %qualified-column
          [%qualified-table ~ %db1 %dbo %adoptions alias=[~ 'A1']]
          'foo'
          ~
      ~
      ~
++  foo2
  [[%unqualified-column 'foo2' ~] ~ ~]
++  t1-foo2
  :+  :^  %qualified-column
          [%qualified-table ~ %db1 %dbo %adoptions alias=[~ 'T1']]
          'foo2'
          ~
      ~
      ~
++  foo3
  [[%unqualified-column 'foo3' ~] ~ ~]
++  t1-foo3
  :+  :^  %qualified-column
          [%qualified-table ~ %db1 %dbo %adoptions alias=[~ 'T1']]
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
          [%qualified-table ~ %db1 %dbo %adoptions alias=[~ 'T2']]
          'bar'
          ~
      ~
      ~
++  a2-bar
  :+  :^  %qualified-column
          [%qualified-table ~ %db1 %dbo %adoptions alias=[~ 'A2']]
          'bar'
          ~
      ~
      ~
++  foobar
  [[%unqualified-column 'foobar' ~] ~ ~]
++  left-scalar
  [[%unqualified-column 'left-scalar' ~] ~ ~]
++  a1-adoption-email
  :+  :^  %qualified-column
          [%qualified-table ~ %db1 %dbo %adoptions alias=[~ 'A1']]
          'adoption-email'
          alias=~
      ~
      ~
++  a2-adoption-email
  :+  :^  %qualified-column
          [%qualified-table ~ %db1 %dbo %adoptions alias=[~ 'A2']]
          'adoption-email'
          alias=~
      ~
      ~
++  a1-adoption-date
  :+  :^  %qualified-column
          [%qualified-table ~ %db1 %dbo %adoptions alias=[~ 'A1']]
          'adoption-date'
          alias=~
      ~
      ~
++  a2-adoption-date
  :+  :^  %qualified-column
          [%qualified-table ~ %db1 %dbo %adoptions alias=[~ 'A2']]
          'adoption-date'
          alias=~
      ~
      ~
++  a1-name
  :+  :^  %qualified-column
          [%qualified-table ~ %db1 %dbo %adoptions alias=[~ 'A1']]
          'name'
          alias=~
      ~
      ~
++  a2-name
  :+  :^  %qualified-column
          [%qualified-table ~ %db1 %dbo %adoptions alias=[~ 'A2']]
          'name'
          alias=~
      ~
      ~
++  a1-species
  :+  :^  %qualified-column
          [%qualified-table ~ %db1 %dbo %adoptions alias=[~ 'A1']]
          'species'
          alias=~
      ~
      ~
++  a2-species
  :+  :^  %qualified-column
          [%qualified-table ~ %db1 %dbo %adoptions alias=[~ 'A2']]
          'species'
          alias=~
      ~
      ~
++  value-literals   [[%value-literals %ud '3;2;1'] ~ ~]
++  aggregate-count-foobar
  :+  %aggregate
      function='count'
      [%unqualified-column name='foobar' alias=~]
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
++  select-top-10-all  [%select top=[~ 10] columns=~[[%all %all]]]
++  foo-table
  [%qualified-table ship=~ database='db1' namespace='dbo' name='foo' alias=~]
++  foo-table-f1
  :*  %qualified-table
      ship=~
      database='db1'
      namespace='dbo'
      name='foo'
      alias=[~ 'F1']
      ==
++  from-foo
  [~ [%from relation=foo-table as-of=~ joins=~]]
++  from-foo-aliased
  [~ [%from relation=foo-table-f1 as-of=~ joins=~]]
++  simple-from-foo
  [%query from-foo scalars=~ ~ group-by=~ having=~ select-top-10-all ~]
++  aliased-from-foo
  [%query from-foo-aliased scalars=~ ~ group-by=~ having=~ select-top-10-all ~]
++  foo-table-row  [%query-row ~['col1' 'col2' 'col3']]
++  foo-alias-y
  :*  %qualified-table
          ship=~
          database='db1'
          namespace='dbo'
          name='foo'
          alias=[~ 'y']
          ==
++  bar-alias-x
  :*  %qualified-table
          ship=~
          database='db1'
          namespace='dbo'
          name='bar'
          alias=[~ 'x']
          ==
++  foo-unaliased
  :*  %qualified-table
          ship=~
          database='db1'
          namespace='dbo'
          name='foo'
          alias=~
          ==
++  bar-unaliased
  :*  %qualified-table
          ship=~
          database='db1'
          namespace='dbo'
          name='bar'
          alias=~
          ==
++  adoptions
  :*  %qualified-table
          ship=~
          database='db1'
          namespace='dbo'
          name='adoptions'
          alias=[~ 'T1']
          ==
++  adoptions-t2
  :*  %qualified-table
          ship=~
          database='db1'
          namespace='dbo'
          name='adoptions'
          alias=[~ 'T2']
          ==
++  passthru-row-y
  [%query-row alias=[~ 'y'] ~['col1' 'col2' 'col3']]
++  passthru-row-x
  [%query-row alias=[~ 'x'] ~['col1' 'col2' 'col3']]
++  passthru-unaliased
  [%query-row alias=~ ~['col1' 'col2' 'col3']]
::
::  test binary operators, varying spacing
++  test-predicate-01
  =/  query
        "FROM adoptions AS T1 JOIN adoptions AS T2 ON T1.foo = T2.bar SELECT *"
  =/  pred=(tree predicate-component:ast)  [%eq t1-foo t2-bar]
  =/  expected
        :+  %selection
            ctes=~
            :-  %query
                :*  %query
                    :-  ~
                        :^  %from
                            relation=adoptions
                            as-of=~
                            :~  :*  %joined-relation
                                    join=%join
                                    relation=adoptions-t2
                                    as-of=~
                                    predicate=pred
                                    ==
                                ==
                    scalars=~
                    ~
                    group-by=~
                    having=~
                    select-all-columns
                    ~
                    ==
  %+  expect-eq
    !>  ~[expected]
    !>  (parse:parse(default-database 'db1') query)
++  test-predicate-02
  =/  query  "FROM adoptions AS T1 JOIN adoptions AS T2 ON foo<>bar SELECT *"
  =/  pred=(tree predicate-component:ast)  [%neq foo bar]
  =/  expected
        :+  %selection
            ctes=~
            :-  %query
                :*  %query
                    :-  ~
                        :^  %from
                            relation=adoptions
                            as-of=~
                            :~  :*  %joined-relation
                                    join=%join
                                    relation=adoptions-t2
                                    as-of=~
                                    predicate=pred
                                    ==
                                ==
                    scalars=~
                    ~
                    group-by=~
                    having=~
                    select-all-columns
                    ~
                    ==
  %+  expect-eq
    !>  ~[expected]
    !>  (parse:parse(default-database 'db1') query)
++  test-predicate-03
  =/  query  "FROM adoptions AS T1 JOIN adoptions AS T2 ON foo!= bar SELECT *"
  =/  pred=(tree predicate-component:ast)  [%neq foo bar]
  =/  expected
        :+  %selection
            ctes=~
            :-  %query
                :*  %query
                    :-  ~
                        :^  %from
                            relation=adoptions
                            as-of=~
                            :~  :*  %joined-relation
                                    join=%join
                                    relation=adoptions-t2
                                    as-of=~
                                    predicate=pred
                                    ==
                                ==
                    scalars=~
                    ~
                    group-by=~
                    having=~
                    select-all-columns
                    ~
                    ==
  %+  expect-eq
    !>  ~[expected]
    !>  (parse:parse(default-database 'db1') query)
++  test-predicate-04
  =/  query  "FROM adoptions AS T1 JOIN adoptions AS T2 ON foo >bar SELECT *"
  =/  pred=(tree predicate-component:ast)  [%gt foo bar]
  =/  expected
        :+  %selection
            ctes=~
            :-  %query
                :*  %query
                    :-  ~
                        :^  %from
                            relation=adoptions
                            as-of=~
                            :~  :*  %joined-relation
                                    join=%join
                                    relation=adoptions-t2
                                    as-of=~
                                    predicate=pred
                                    ==
                                ==
                    scalars=~
                    ~
                    group-by=~
                    having=~
                    select-all-columns
                    order-by=~
                    ==
  %+  expect-eq
    !>  ~[expected]
    !>  (parse:parse(default-database 'db1') query)
++  test-predicate-05
  =/  query  "FROM adoptions AS T1 JOIN adoptions AS T2 ON foo <bar SELECT *"
  =/  pred=(tree predicate-component:ast)  [%lt foo bar]
  =/  expected
        :+  %selection
            ctes=~
            :-  %query
                :*  %query
                    :-  ~
                        :^  %from
                            relation=adoptions
                            as-of=~
                            :~  :*  %joined-relation
                                    join=%join
                                    relation=adoptions-t2
                                    as-of=~
                                    predicate=pred
                                    ==
                                ==
                    scalars=~
                    ~
                    group-by=~
                    having=~
                    select-all-columns
                    order-by=~
                    ==
  %+  expect-eq
    !>  ~[expected]
    !>  (parse:parse(default-database 'db1') query)
++  test-predicate-06
  =/  query  "FROM adoptions AS T1 JOIN adoptions AS T2 ON foo>= bar SELECT *"
  =/  pred=(tree predicate-component:ast)  [%gte foo bar]
  =/  expected
        :+  %selection
            ctes=~
            :-  %query
                :*  %query
                    :-  ~
                        :^  %from
                            relation=adoptions
                            as-of=~
                            :~  :*  %joined-relation
                                    join=%join
                                    relation=adoptions-t2
                                    as-of=~
                                    predicate=pred
                                    ==
                                ==
                    scalars=~
                    ~
                    group-by=~
                    having=~
                    select-all-columns
                    order-by=~
                    ==
  %+  expect-eq
    !>  ~[expected]
    !>  (parse:parse(default-database 'db1') query)
++  test-predicate-07
  =/  query  "FROM adoptions AS T1 JOIN adoptions AS T2 ON foo!< bar SELECT *"
  =/  pred=(tree predicate-component:ast)  [%gte foo bar]
  =/  expected
        :+  %selection
            ctes=~
            :-  %query
                :*  %query
                    :-  ~
                        :^  %from
                            relation=adoptions
                            as-of=~
                            :~  :*  %joined-relation
                                    join=%join
                                    relation=adoptions-t2
                                    as-of=~
                                    predicate=pred
                                    ==
                                ==
                    scalars=~
                    ~
                    group-by=~
                    having=~
                    select-all-columns
                    order-by=~
                    ==
  %+  expect-eq
    !>  ~[expected]
    !>  (parse:parse(default-database 'db1') query)
++  test-predicate-08
  =/  query  "FROM adoptions AS T1 JOIN adoptions AS T2 ON foo <= bar SELECT *"
  =/  pred=(tree predicate-component:ast)  [%lte foo bar]
  =/  expected
        :+  %selection
            ctes=~
            :-  %query
                :*  %query
                    :-  ~
                        :^  %from
                            relation=adoptions
                            as-of=~
                            :~  :*  %joined-relation
                                    join=%join
                                    relation=adoptions-t2
                                    as-of=~
                                    predicate=pred
                                    ==
                                ==
                    scalars=~
                    ~
                    group-by=~
                    having=~
                    select-all-columns
                    order-by=~
                    ==
  %+  expect-eq
    !>  ~[expected]
    !>  (parse:parse(default-database 'db1') query)
++  test-predicate-09
  =/  query  "FROM adoptions AS T1 JOIN adoptions AS T2 ON foo !> bar SELECT *"
  =/  pred=(tree predicate-component:ast)  [%lte foo bar]
  =/  expected
        :+  %selection
            ctes=~
            :-  %query
                :*  %query
                    :-  ~
                        :^  %from
                            relation=adoptions
                            as-of=~
                            :~  :*  %joined-relation
                                    join=%join
                                    relation=adoptions-t2
                                    as-of=~
                                    predicate=pred
                                    ==
                                ==
                    scalars=~
                    ~
                    group-by=~
                    having=~
                    select-all-columns
                    order-by=~
                    ==
  %+  expect-eq
    !>  ~[expected]
    !>  (parse:parse(default-database 'db1') query)
++  test-predicate-10
  =/  query  "FROM foo WHERE foobar EQUIV bar SELECT *"
  =/  pred=(tree predicate-component:ast)  [%equiv foobar bar]
  =/  expected
        :+  %selection
            ctes=~
            :-  %query
                :*  %query
                    from-foo
                    scalars=~
                    pred
                    group-by=~
                    having=~
                    [%select top=~ columns=~[[%all %all]]]
                    ~
                    ==
  %+  expect-eq
    !>  ~[expected]
    !>  (parse:parse(default-database 'db1') query)
++  test-predicate-11
  =/  query  "FROM foo WHERE foobar NOT EQUIV bar SELECT *"
  =/  pred=(tree predicate-component:ast)  [%not-equiv foobar bar]
  =/  expected
        :+  %selection
            ctes=~
            :-  %query
                :*  %query
                    from-foo
                    scalars=~
                    pred
                    group-by=~
                    having=~
                    select-all-columns
                    order-by=~
                    ==
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
            :-  %query
                :*  %query
                    :-  ~
                        :^  %from
                            relation=adoptions
                            as-of=~
                            :~  :*  %joined-relation
                                    join=%join
                                    relation=adoptions-t2
                                    as-of=~
                                    predicate=joinpred
                                    ==
                                ==
                    scalars=~
                    pred
                    group-by=~
                    having=~
                    select-all-columns
                    order-by=~
                    ==
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
            :-  %query
                :*  %query
                    :-  ~
                        :^  %from
                            relation=adoptions
                            as-of=~
                            :~  :*  %joined-relation
                                    join=%join
                                    relation=adoptions-t2
                                    as-of=~
                                    predicate=joinpred
                                    ==
                                ==
                    scalars=~
                    pred
                    group-by=~
                    having=~
                    select-all-columns
                    order-by=~
                    ==
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
            :-  %query
                :*  %query
                    :-  ~
                        :^  %from
                            relation=adoptions
                            as-of=~
                            :~  :*  %joined-relation
                                    join=%join
                                    relation=adoptions-t2
                                    as-of=~
                                    predicate=joinpred
                                    ==
                                ==
                    scalars=~
                    pred
                    group-by=~
                    having=~
                    select-all-columns
                    order-by=~
                    ==
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
            :-  %query
                :*  %query
                    :-  ~
                        :^  %from
                            relation=adoptions
                            as-of=~
                            :~  :*  %joined-relation
                                    join=%join
                                    relation=adoptions-t2
                                    as-of=~
                                    predicate=joinpred
                                    ==
                                ==
                    scalars=~
                    pred
                    group-by=~
                    having=~
                    select-all-columns
                    order-by=~
                    ==
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
            :-  %query
                :*  %query
                    :-  ~
                        :^  %from
                            relation=adoptions
                            as-of=~
                            :~  :*  %joined-relation
                                    join=%join
                                    relation=adoptions-t2
                                    as-of=~
                                    predicate=joinpred
                                    ==
                                ==
                    scalars=~
                    pred
                    group-by=~
                    having=~
                    select-all-columns
                    order-by=~
                    ==
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
            :-  %query
                :*  %query
                    :-  ~
                        :^  %from
                            relation=adoptions
                            as-of=~
                            :~  :*  %joined-relation
                                    join=%join
                                    relation=adoptions-t2
                                    as-of=~
                                    predicate=joinpred
                                    ==
                                ==
                    scalars=~
                    pred
                    group-by=~
                    having=~
                    select-all-columns
                    order-by=~
                    ==
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
            :-  %query
                :*  %query
                    :-  ~
                        :^  %from
                            relation=adoptions
                            as-of=~
                            :~  :*  %joined-relation
                                    join=%join
                                    relation=adoptions-t2
                                    as-of=~
                                    predicate=joinpred
                                    ==
                                ==
                    scalars=~
                    pred
                    group-by=~
                    having=~
                    select-all-columns
                    order-by=~
                    ==
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
            :-  %query
                :*  %query
                    :-  ~
                        :^  %from
                            relation=adoptions
                            as-of=~
                            :~  :*  %joined-relation
                                    join=%join
                                    relation=adoptions-t2
                                    as-of=~
                                    predicate=joinpred
                                    ==
                                ==
                    scalars=~
                    pred
                    group-by=~
                    having=~
                    select-all-columns
                    order-by=~
                    ==
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
            :-  %query
                :*  %query
                    :-  ~
                        :^  %from
                            relation=adoptions
                            as-of=~
                            :~  :*  %joined-relation
                                    join=%join
                                    relation=adoptions-t2
                                    as-of=~
                                    predicate=joinpred
                                    ==
                                ==
                    scalars=~
                    pred
                    group-by=~
                    having=~
                    select-all-columns
                    order-by=~
                    ==
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
            :-  %query
                :*  %query
                    :-  ~
                        :^  %from
                            relation=adoptions
                            as-of=~
                            :~  :*  %joined-relation
                                    join=%join
                                    relation=adoptions-t2
                                    as-of=~
                                    predicate=joinpred
                                    ==
                                ==
                    scalars=~
                    pred
                    group-by=~
                    having=~
                    select-all-columns
                    order-by=~
                    ==
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
            :-  %query
                :*  %query
                    :-  ~
                        :^  %from
                            relation=adoptions
                            as-of=~
                            :~  :*  %joined-relation
                                    join=%join
                                    relation=adoptions-t2
                                    as-of=~
                                    predicate=joinpred
                                    ==
                                ==
                    scalars=~
                    pred
                    group-by=~
                    having=~
                    select-all-columns
                    order-by=~
                    ==
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
            :-  %query
                :*  %query
                    :-  ~
                        :^  %from
                            relation=adoptions
                            as-of=~
                            :~  :*  %joined-relation
                                    join=%join
                                    relation=adoptions-t2
                                    as-of=~
                                    predicate=joinpred
                                    ==
                                ==
                    scalars=~
                    pred
                    group-by=~
                    having=~
                    select-all-columns
                    order-by=~
                    ==
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
            :-  %query
                :*  %query
                    :-  ~
                        :^  %from
                            relation=adoptions
                            as-of=~
                            :~  :*  %joined-relation
                                    join=%join
                                    relation=adoptions-t2
                                    as-of=~
                                    predicate=joinpred
                                    ==
                                ==
                    scalars=~
                    pred
                    group-by=~
                    having=~
                    select-all-columns
                    order-by=~
                    ==
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
            :-  %query
                :*  %query
                    :-  ~
                        :^  %from
                            relation=adoptions
                            as-of=~
                            :~  :*  %joined-relation
                                    join=%join
                                    relation=adoptions-t2
                                    as-of=~
                                    predicate=joinpred
                                    ==
                                ==
                    scalars=~
                    pred
                    group-by=~
                    having=~
                    select-all-columns
                    order-by=~
                    ==
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
            :-  %query
                :*  %query
                    :-  ~
                        :^  %from
                            relation=adoptions
                            as-of=~
                            :~  :*  %joined-relation
                                    join=%join
                                    relation=adoptions-t2
                                    as-of=~
                                    predicate=joinpred
                                    ==
                                ==
                    scalars=~
                    pred
                    group-by=~
                    having=~
                    select-all-columns
                    order-by=~
                    ==
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
            :-  %query
                :*  %query
                    :-  ~
                        :^  %from
                            relation=adoptions
                            as-of=~
                            :~  :*  %joined-relation
                                    join=%join
                                    relation=adoptions-t2
                                    as-of=~
                                    predicate=joinpred
                                    ==
                                ==
                    scalars=~
                    pred
                    group-by=~
                    having=~
                    select-all-columns
                    order-by=~
                    ==
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
            :-  %query
                :*  %query
                    :-  ~
                        :^  %from
                            relation=adoptions
                            as-of=~
                            :~  :*  %joined-relation
                                    join=%join
                                    relation=adoptions-t2
                                    as-of=~
                                    predicate=joinpred
                                    ==
                                ==
                    scalars=~
                    pred
                    group-by=~
                    having=~
                    select-all-columns
                    order-by=~
                    ==
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
            :-  %query
                :*  %query
                    :-  ~
                        :^  %from
                            relation=adoptions
                            as-of=~
                            :~  :*  %joined-relation
                                    join=%join
                                    relation=adoptions-t2
                                    as-of=~
                                    predicate=joinpred
                                    ==
                                ==
                    scalars=~
                    pred
                    group-by=~
                    having=~
                    select-all-columns
                    order-by=~
                    ==
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
            :-  %query
                :*  %query
                    :-  ~
                        :^  %from
                            relation=adoptions
                            as-of=~
                            :~  :*  %joined-relation
                                    join=%join
                                    relation=adoptions-t2
                                    as-of=~
                                    predicate=joinpred
                                    ==
                                ==
                    scalars=~
                    pred
                    group-by=~
                    having=~
                    select-all-columns
                    order-by=~
                    ==
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
            :-  %query
                :*  %query
                    :-  ~
                        :^  %from
                            relation=adoptions
                            as-of=~
                            :~  :*  %joined-relation
                                    join=%join
                                    relation=adoptions-t2
                                    as-of=~
                                    predicate=joinpred
                                    ==
                                ==
                    scalars=~
                    pred
                    group-by=~
                    having=~
                    select-all-columns
                    order-by=~
                    ==
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
            :-  %query
                :*  %query
                    :-  ~
                        :^  %from
                            relation=adoptions
                            as-of=~
                            :~  :*  %joined-relation
                                    join=%join
                                    relation=adoptions-t2
                                    as-of=~
                                    predicate=joinpred
                                    ==
                                ==
                    scalars=~
                    pred
                    group-by=~
                    having=~
                    select-all-columns
                    order-by=~
                    ==
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
            :-  %query
                :*  %query
                    from-foo
                    scalars=~
                    pred
                    group-by=~
                    having=~
                    select-all-columns
                    order-by=~
                    ==
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
            :-  %query
                :*  %query
                    from-foo
                    scalars=~
                    pred
                    group-by=~
                    having=~
                    select-all-columns
                    order-by=~
                    ==
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
            :-  %query
                :*  %query
                    from-foo
                    scalars=~
                    pred
                    group-by=~
                    having=~
                    select-all-columns
                    order-by=~
                    ==
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
            :-  %query
                :*  %query
                    :-  ~
                        :^  %from
                            :*  %qualified-table
                                ship=~
                                database='db1'
                                namespace='dbo'
                                name='adoptions'
                                alias=[~ 'A1']
                                ==
                            as-of=~
                            :~  :*  %joined-relation
                                    join=%join
                                            :*  %qualified-table
                                            ship=~
                                            database='db1'
                                            namespace='dbo'
                                            name='adoptions'
                                            alias=[~ 'A2']
                                            ==
                                    as-of=~
                                    predicate=joinpred
                                    ==
                                ==
                    scalars=~
                    pred
                    group-by=~
                    having=~
                    select-all-columns
                    order-by=~
                    ==
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
            :-  %query
                :*  %query
                    :-  ~
                        :^  %from
                            relation=adoptions
                            as-of=~
                            :~  :*  %joined-relation
                                    join=%join
                                    relation=adoptions-t2
                                    as-of=~
                                    predicate=pred
                                    ==
                                ==
                    scalars=~
                    ~
                    group-by=~
                    having=~
                    select-all-columns
                    order-by=~
                    ==
  %+  expect-eq
    !>  ~[expected]
    !>  (parse:parse(default-database 'db1') query)
::
::  NOT unary operator
::
++  test-predicate-38
  =/  query
        "FROM adoptions T1 WHERE NOT foo = bar SELECT *"
  =/  pred=(tree predicate-component:ast)
        :+  %not
            :+  %eq
                :+  [%unqualified-column name=%foo alias=~]
                    ~
                    ~
                :+  [%unqualified-column name=%bar alias=~]
                    ~
                    ~
            ~
  =/  expected
        :+  %selection
            ctes=~
            :-  %query
                :*  %query
                    :-  ~
                        :^  %from
                            relation=adoptions
                            as-of=~
                            ~
                    scalars=~
                    pred
                    group-by=~
                    having=~
                    select-all-columns
                    ~
                    ==
  %+  expect-eq
    !>  ~[expected]
    !>  (parse:parse(default-database 'db1') query)
++  test-predicate-39
  =/  query
        "FROM adoptions T1 WHERE NOT (foo = bar) SELECT *"
  =/  pred=(tree predicate-component:ast)
        :+  %not
            :+  %eq
                :+  [%unqualified-column name=%foo alias=~]
                    ~
                    ~
                :+  [%unqualified-column name=%bar alias=~]
                    ~
                    ~
            ~
  =/  expected
        :+  %selection
            ctes=~
            :-  %query
                :*  %query
                    :-  ~
                        :^  %from
                            relation=adoptions
                            as-of=~
                            ~
                    scalars=~
                    pred
                    group-by=~
                    having=~
                    select-all-columns
                    ~
                    ==
  %+  expect-eq
    !>  ~[expected]
    !>  (parse:parse(default-database 'db1') query)
::
++  test-predicate-40
  =/  query
        "FROM adoptions T1 WHERE NOT NOT foo = bar SELECT *"
  =/  pred=(tree predicate-component:ast)
        :+  %not
            :+  %not
                :+  %eq
                    :+  [%unqualified-column name=%foo alias=~]
                        ~
                        ~
                    :+  [%unqualified-column name=%bar alias=~]
                        ~
                        ~
                ~
            ~
  =/  expected
        :+  %selection
            ctes=~
            :-  %query
                :*  %query
                    :-  ~
                        :^  %from
                            relation=adoptions
                            as-of=~
                            ~
                    scalars=~
                    pred
                    group-by=~
                    having=~
                    select-all-columns
                    ~
                    ==
  %+  expect-eq
    !>  ~[expected]
    !>  (parse:parse(default-database 'db1') query)
::
++  test-predicate-41
  =/  query
        "FROM adoptions T1 WHERE NOT NOT (foo = bar) SELECT *"
  =/  pred=(tree predicate-component:ast)
        :+  %not
            :+  %not
                :+  %eq
                    :+  [%unqualified-column name=%foo alias=~]
                        ~
                        ~
                    :+  [%unqualified-column name=%bar alias=~]
                        ~
                        ~
                ~
            ~
  =/  expected
        :+  %selection
            ctes=~
            :-  %query
                :*  %query
                    :-  ~
                        :^  %from
                            relation=adoptions
                            as-of=~
                            ~
                    scalars=~
                    pred
                    group-by=~
                    having=~
                    select-all-columns
                    ~
                    ==
  %+  expect-eq
    !>  ~[expected]
    !>  (parse:parse(default-database 'db1') query)
++  test-predicate-42
  =/  query  "FROM adoptions AS T1 ".
    " WHERE not NOT  EXISTS  T1.foo ".
    " SELECT *"
  =/  pred=(tree predicate-component:ast)  [%not [%not-exists t1-foo ~] ~]
  =/  expected
        :+  %selection
            ctes=~
            :-  %query
                :*  %query
                    :-  ~
                        :^  %from
                            relation=adoptions
                            as-of=~
                            ~
                    scalars=~
                    pred
                    group-by=~
                    having=~
                    select-all-columns
                    order-by=~
                    ==
  %+  expect-eq
    !>  ~[expected]
    !>  (parse:parse(default-database 'db1') query)
::
::  complext predicate with NOT
++  test-predicate-43
  =/  query  "FROM adoptions AS A1 JOIN adoptions AS A2 ON A1.foo = A2.bar ".
    " WHERE  A1.adoption-email = A2.adoption-email  ".
    "  AND     A1.adoption-date = A2.adoption-date  ".
    "  AND    foo = bar  ".
    "  AND NOT ( NOT (A1.name = A2.name AND NOT A1.species > A2.species) ".
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
            :+  %not
                :+  %or
                    :+  %or
                        :+  %not
                            :+  %and
                                [%eq a1-name a2-name]
                                [%not [%gt a1-species a2-species] ~]
                            ~
                        :+  %and
                            [%gt a1-name a2-name]
                            [%eq a1-species a2-species]
                    [%and [%gt a1-name a2-name] [%gt a1-species a2-species]]
                ~
  =/  expected
        :+  %selection
            ctes=~
            :-  %query
                :*  %query
                    :-  ~
                        :^  %from
                            :*  %qualified-table
                                ship=~
                                database='db1'
                                namespace='dbo'
                                name='adoptions'
                                alias=[~ 'A1']
                                ==
                            as-of=~
                            :~  :*  %joined-relation
                                    join=%join
                                    :*  %qualified-table
                                        ship=~
                                        database='db1'
                                        namespace='dbo'
                                        name='adoptions'
                                        alias=[~ 'A2']
                                        ==
                                    as-of=~
                                    predicate=joinpred
                                    ==
                                ==
                    scalars=~
                    pred
                    group-by=~
                    having=~
                    select-all-columns
                    order-by=~
                    ==
  %+  expect-eq
    !>  ~[expected]
    !>  (parse:parse(default-database 'db1') query)
::
::  cte column predicate helpers
::
++  my-cte-col1  [[%cte-column 'my-cte' 'col1'] ~ ~]
++  my-cte-col2  [[%cte-column 'my-cte' 'col2'] ~ ~]
++  cte1-col1    [[%cte-column 'cte1' 'col1'] ~ ~]
++  cte2-col1    [[%cte-column 'cte2' 'col1'] ~ ~]
++  cte2-col2    [[%cte-column 'cte2' 'col2'] ~ ~]
++  unq-col1     [[%unqualified-column 'col1' ~] ~ ~]
++  unq-col2     [[%unqualified-column 'col2' ~] ~ ~]
++  my-cte-table
  [%cte-name name='my-cte' alias=~]
++  cte1-table
  [%cte-name name='cte1' alias=~]
++  cte2-table
  [%cte-name name='cte2' alias=~]
++  cte-my-cte
  =/  from-clause  [%from relation=foo-unaliased as-of=~ joins=~]
  :*  %cte  name='my-cte'
      :-  %query
          :*  %query  [~ from-clause]  scalars=~  ~
              group-by=~  having=~  select-all-columns  ~
              ==
      ==
++  cte-cte1
  =/  from-clause  [%from relation=foo-unaliased as-of=~ joins=~]
  :*  %cte  name='cte1'
      :-  %query
          :*  %query  [~ from-clause]  scalars=~  ~
              group-by=~  having=~  select-all-columns  ~
              ==
      ==
++  cte-cte2
  =/  from-clause  [%from relation=bar-unaliased as-of=~ joins=~]
  :*  %cte  name='cte2'
      :-  %query
          :*  %query  [~ from-clause]  scalars=~  ~
              group-by=~  having=~  select-all-columns  ~
              ==
      ==
++  from-my-cte-outer
  [~ [%from relation=my-cte-table as-of=~ joins=~]]
++  from-cte1-join-cte2
  :-  ~
  :^  %from
      relation=cte1-table
      as-of=~
      :~  :*  %joined-relation
              join=%join
              relation=cte2-table
              as-of=~
              predicate=[%eq cte1-col1 cte2-col1]
              ==
          ==
::
::  test cte column in predicate, single table
::
::  1: <cte>.<col> = <cte>.<col>
++  test-predicate-44
  =/  query
        "WITH (FROM foo SELECT *) AS my-cte ".
        "FROM my-cte WHERE my-cte.col1 = my-cte.col2 SELECT *"
  =/  pred=(tree predicate-component:ast)
        [%eq my-cte-col1 my-cte-col2]
  =/  expected
        :+  %selection
            ctes=~[cte-my-cte]
            :-  %query
                :*  %query
                    from-my-cte-outer
                    scalars=~
                    pred
                    group-by=~
                    having=~
                    select-all-columns
                    order-by=~
                    ==
  %+  expect-eq
    !>  ~[expected]
    !>  (parse:parse(default-database 'db1') query)
::
::  2: <cte>.<col> = <literal>
++  test-predicate-45
  =/  query
        "WITH (FROM foo SELECT *) AS my-cte ".
        "FROM my-cte WHERE my-cte.col1 = 10 SELECT *"
  =/  pred=(tree predicate-component:ast)
        [%eq my-cte-col1 literal-10]
  =/  expected
        :+  %selection
            ctes=~[cte-my-cte]
            :-  %query
                :*  %query
                    from-my-cte-outer
                    scalars=~
                    pred
                    group-by=~
                    having=~
                    select-all-columns
                    order-by=~
                    ==
  %+  expect-eq
    !>  ~[expected]
    !>  (parse:parse(default-database 'db1') query)
::
::  3: <literal> = <cte>.<col>
++  test-predicate-46
  =/  query
        "WITH (FROM foo SELECT *) AS my-cte ".
        "FROM my-cte WHERE 10 = my-cte.col1 SELECT *"
  =/  pred=(tree predicate-component:ast)
        [%eq literal-10 my-cte-col1]
  =/  expected
        :+  %selection
            ctes=~[cte-my-cte]
            :-  %query
                :*  %query
                    from-my-cte-outer
                    scalars=~
                    pred
                    group-by=~
                    having=~
                    select-all-columns
                    order-by=~
                    ==
  %+  expect-eq
    !>  ~[expected]
    !>  (parse:parse(default-database 'db1') query)
::
::  4: <cte>.<col> = <column>
++  test-predicate-47
  =/  query
        "WITH (FROM foo SELECT *) AS my-cte ".
        "FROM my-cte WHERE my-cte.col1 = col2 SELECT *"
  =/  pred=(tree predicate-component:ast)
        [%eq my-cte-col1 unq-col2]
  =/  expected
        :+  %selection
            ctes=~[cte-my-cte]
            :-  %query
                :*  %query
                    from-my-cte-outer
                    scalars=~
                    pred
                    group-by=~
                    having=~
                    select-all-columns
                    order-by=~
                    ==
  %+  expect-eq
    !>  ~[expected]
    !>  (parse:parse(default-database 'db1') query)
::
::  5: <column> = <cte>.<col>
++  test-predicate-48
  =/  query
        "WITH (FROM foo SELECT *) AS my-cte ".
        "FROM my-cte WHERE col1 = my-cte.col2 SELECT *"
  =/  pred=(tree predicate-component:ast)
        [%eq unq-col1 my-cte-col2]
  =/  expected
        :+  %selection
            ctes=~[cte-my-cte]
            :-  %query
                :*  %query
                    from-my-cte-outer
                    scalars=~
                    pred
                    group-by=~
                    having=~
                    select-all-columns
                    order-by=~
                    ==
  %+  expect-eq
    !>  ~[expected]
    !>  (parse:parse(default-database 'db1') query)
::
::  6: <literal> in <cte>.<col>
++  test-predicate-49
  =/  query
        "WITH (FROM foo SELECT *) AS my-cte ".
        "FROM my-cte WHERE 10 in my-cte.col1 SELECT *"
  =/  pred=(tree predicate-component:ast)
        [%in literal-10 my-cte-col1]
  =/  expected
        :+  %selection
            ctes=~[cte-my-cte]
            :-  %query
                :*  %query
                    from-my-cte-outer
                    scalars=~
                    pred
                    group-by=~
                    having=~
                    select-all-columns
                    order-by=~
                    ==
  %+  expect-eq
    !>  ~[expected]
    !>  (parse:parse(default-database 'db1') query)
::
::  7: <column> in <cte>.<col>
++  test-predicate-50
  =/  query
        "WITH (FROM foo SELECT *) AS my-cte ".
        "FROM my-cte WHERE col1 in my-cte.col2 SELECT *"
  =/  pred=(tree predicate-component:ast)
        [%in unq-col1 my-cte-col2]
  =/  expected
        :+  %selection
            ctes=~[cte-my-cte]
            :-  %query
                :*  %query
                    from-my-cte-outer
                    scalars=~
                    pred
                    group-by=~
                    having=~
                    select-all-columns
                    order-by=~
                    ==
  %+  expect-eq
    !>  ~[expected]
    !>  (parse:parse(default-database 'db1') query)
::
::  test cte column in predicate, joined tables
::
::  1: <cte1>.<col> = <cte2>.<col>
++  test-predicate-51
  =/  query
        "WITH (FROM foo SELECT *) AS cte1, ".
        "(FROM bar SELECT *) AS cte2 ".
        "FROM cte1 JOIN cte2 ON cte1.col1 = cte2.col1 ".
        "WHERE cte1.col1 = cte2.col2 SELECT *"
  =/  pred=(tree predicate-component:ast)
        [%eq cte1-col1 cte2-col2]
  =/  expected
        :+  %selection
            ctes=~[cte-cte1 cte-cte2]
            :-  %query
                :*  %query
                    from-cte1-join-cte2
                    scalars=~
                    pred
                    group-by=~
                    having=~
                    select-all-columns
                    order-by=~
                    ==
  %+  expect-eq
    !>  ~[expected]
    !>  (parse:parse(default-database 'db1') query)
::
::  2: <cte1>.<col> = <literal>
++  test-predicate-52
  =/  query
        "WITH (FROM foo SELECT *) AS cte1, ".
        "(FROM bar SELECT *) AS cte2 ".
        "FROM cte1 JOIN cte2 ON cte1.col1 = cte2.col1 ".
        "WHERE cte1.col1 = 10 SELECT *"
  =/  pred=(tree predicate-component:ast)
        [%eq cte1-col1 literal-10]
  =/  expected
        :+  %selection
            ctes=~[cte-cte1 cte-cte2]
            :-  %query
                :*  %query
                    from-cte1-join-cte2
                    scalars=~
                    pred
                    group-by=~
                    having=~
                    select-all-columns
                    order-by=~
                    ==
  %+  expect-eq
    !>  ~[expected]
    !>  (parse:parse(default-database 'db1') query)
::
::  3: <literal> = <cte1>.<col>
++  test-predicate-53
  =/  query
        "WITH (FROM foo SELECT *) AS cte1, ".
        "(FROM bar SELECT *) AS cte2 ".
        "FROM cte1 JOIN cte2 ON cte1.col1 = cte2.col1 ".
        "WHERE 10 = cte1.col1 SELECT *"
  =/  pred=(tree predicate-component:ast)
        [%eq literal-10 cte1-col1]
  =/  expected
        :+  %selection
            ctes=~[cte-cte1 cte-cte2]
            :-  %query
                :*  %query
                    from-cte1-join-cte2
                    scalars=~
                    pred
                    group-by=~
                    having=~
                    select-all-columns
                    order-by=~
                    ==
  %+  expect-eq
    !>  ~[expected]
    !>  (parse:parse(default-database 'db1') query)
::
::  4: <cte1>.<col> = <column>
++  test-predicate-54
  =/  query
        "WITH (FROM foo SELECT *) AS cte1, ".
        "(FROM bar SELECT *) AS cte2 ".
        "FROM cte1 JOIN cte2 ON cte1.col1 = cte2.col1 ".
        "WHERE cte1.col1 = col2 SELECT *"
  =/  pred=(tree predicate-component:ast)
        [%eq cte1-col1 unq-col2]
  =/  expected
        :+  %selection
            ctes=~[cte-cte1 cte-cte2]
            :-  %query
                :*  %query
                    from-cte1-join-cte2
                    scalars=~
                    pred
                    group-by=~
                    having=~
                    select-all-columns
                    order-by=~
                    ==
  %+  expect-eq
    !>  ~[expected]
    !>  (parse:parse(default-database 'db1') query)
::
::  5: <column> = <cte2>.<col>
++  test-predicate-55
  =/  query
        "WITH (FROM foo SELECT *) AS cte1, ".
        "(FROM bar SELECT *) AS cte2 ".
        "FROM cte1 JOIN cte2 ON cte1.col1 = cte2.col1 ".
        "WHERE col1 = cte2.col2 SELECT *"
  =/  pred=(tree predicate-component:ast)
        [%eq unq-col1 cte2-col2]
  =/  expected
        :+  %selection
            ctes=~[cte-cte1 cte-cte2]
            :-  %query
                :*  %query
                    from-cte1-join-cte2
                    scalars=~
                    pred
                    group-by=~
                    having=~
                    select-all-columns
                    order-by=~
                    ==
  %+  expect-eq
    !>  ~[expected]
    !>  (parse:parse(default-database 'db1') query)
::
::  6: <literal> in <cte1>.<col>
++  test-predicate-56
  =/  query
        "WITH (FROM foo SELECT *) AS cte1, ".
        "(FROM bar SELECT *) AS cte2 ".
        "FROM cte1 JOIN cte2 ON cte1.col1 = cte2.col1 ".
        "WHERE 10 in cte1.col1 SELECT *"
  =/  pred=(tree predicate-component:ast)
        [%in literal-10 cte1-col1]
  =/  expected
        :+  %selection
            ctes=~[cte-cte1 cte-cte2]
            :-  %query
                :*  %query
                    from-cte1-join-cte2
                    scalars=~
                    pred
                    group-by=~
                    having=~
                    select-all-columns
                    order-by=~
                    ==
  %+  expect-eq
    !>  ~[expected]
    !>  (parse:parse(default-database 'db1') query)
::
::  7: <column> in <cte2>.<col>
++  test-predicate-57
  =/  query
        "WITH (FROM foo SELECT *) AS cte1, ".
        "(FROM bar SELECT *) AS cte2 ".
        "FROM cte1 JOIN cte2 ON cte1.col1 = cte2.col1 ".
        "WHERE col1 in cte2.col2 SELECT *"
  =/  pred=(tree predicate-component:ast)
        [%in unq-col1 cte2-col2]
  =/  expected
        :+  %selection
            ctes=~[cte-cte1 cte-cte2]
            :-  %query
                :*  %query
                    from-cte1-join-cte2
                    scalars=~
                    pred
                    group-by=~
                    having=~
                    select-all-columns
                    order-by=~
                    ==
  %+  expect-eq
    !>  ~[expected]
    !>  (parse:parse(default-database 'db1') query)
::
::  cte with named columns helpers
::
++  select-col1-col2
  [%select top=~ columns=~[[%unqualified-column 'col1' ~] [%unqualified-column 'col2' ~]]]
++  cte-my-cte-cols
  =/  from-clause  [%from relation=foo-unaliased as-of=~ joins=~]
  :*  %cte  name='my-cte'
      :-  %query
          :*  %query  [~ from-clause]  scalars=~  ~
              group-by=~  having=~  select-col1-col2  ~
              ==
      ==
++  cte-cte1-cols
  =/  from-clause  [%from relation=foo-unaliased as-of=~ joins=~]
  :*  %cte  name='cte1'
      :-  %query
          :*  %query  [~ from-clause]  scalars=~  ~
              group-by=~  having=~  select-col1-col2  ~
              ==
      ==
++  cte-cte2-cols
  =/  from-clause  [%from relation=bar-unaliased as-of=~ joins=~]
  :*  %cte  name='cte2'
      :-  %query
          :*  %query  [~ from-clause]  scalars=~  ~
              group-by=~  having=~  select-col1-col2  ~
              ==
      ==
::
::  test cte column in predicate, single table, named cte columns
::
::  1: <cte>.<col> = <cte>.<col>
++  test-predicate-58
  =/  query
        "WITH (FROM foo SELECT col1, col2) AS my-cte ".
        "FROM my-cte WHERE my-cte.col1 = my-cte.col2 SELECT *"
  =/  pred=(tree predicate-component:ast)
        [%eq my-cte-col1 my-cte-col2]
  =/  expected
        :+  %selection
            ctes=~[cte-my-cte-cols]
            :-  %query
                :*  %query
                    from-my-cte-outer
                    scalars=~
                    pred
                    group-by=~
                    having=~
                    select-all-columns
                    order-by=~
                    ==
  %+  expect-eq
    !>  ~[expected]
    !>  (parse:parse(default-database 'db1') query)
::
::  2: <cte>.<col> = <literal>
++  test-predicate-59
  =/  query
        "WITH (FROM foo SELECT col1, col2) AS my-cte ".
        "FROM my-cte WHERE my-cte.col1 = 10 SELECT *"
  =/  pred=(tree predicate-component:ast)
        [%eq my-cte-col1 literal-10]
  =/  expected
        :+  %selection
            ctes=~[cte-my-cte-cols]
            :-  %query
                :*  %query
                    from-my-cte-outer
                    scalars=~
                    pred
                    group-by=~
                    having=~
                    select-all-columns
                    order-by=~
                    ==
  %+  expect-eq
    !>  ~[expected]
    !>  (parse:parse(default-database 'db1') query)
::
::  3: <literal> = <cte>.<col>
++  test-predicate-60
  =/  query
        "WITH (FROM foo SELECT col1, col2) AS my-cte ".
        "FROM my-cte WHERE 10 = my-cte.col1 SELECT *"
  =/  pred=(tree predicate-component:ast)
        [%eq literal-10 my-cte-col1]
  =/  expected
        :+  %selection
            ctes=~[cte-my-cte-cols]
            :-  %query
                :*  %query
                    from-my-cte-outer
                    scalars=~
                    pred
                    group-by=~
                    having=~
                    select-all-columns
                    order-by=~
                    ==
  %+  expect-eq
    !>  ~[expected]
    !>  (parse:parse(default-database 'db1') query)
::
::  4: <cte>.<col> = <column>
++  test-predicate-61
  =/  query
        "WITH (FROM foo SELECT col1, col2) AS my-cte ".
        "FROM my-cte WHERE my-cte.col1 = col2 SELECT *"
  =/  pred=(tree predicate-component:ast)
        [%eq my-cte-col1 unq-col2]
  =/  expected
        :+  %selection
            ctes=~[cte-my-cte-cols]
            :-  %query
                :*  %query
                    from-my-cte-outer
                    scalars=~
                    pred
                    group-by=~
                    having=~
                    select-all-columns
                    order-by=~
                    ==
  %+  expect-eq
    !>  ~[expected]
    !>  (parse:parse(default-database 'db1') query)
::
::  5: <column> = <cte>.<col>
++  test-predicate-62
  =/  query
        "WITH (FROM foo SELECT col1, col2) AS my-cte ".
        "FROM my-cte WHERE col1 = my-cte.col2 SELECT *"
  =/  pred=(tree predicate-component:ast)
        [%eq unq-col1 my-cte-col2]
  =/  expected
        :+  %selection
            ctes=~[cte-my-cte-cols]
            :-  %query
                :*  %query
                    from-my-cte-outer
                    scalars=~
                    pred
                    group-by=~
                    having=~
                    select-all-columns
                    order-by=~
                    ==
  %+  expect-eq
    !>  ~[expected]
    !>  (parse:parse(default-database 'db1') query)
::
::  6: <literal> in <cte>.<col>
++  test-predicate-63
  =/  query
        "WITH (FROM foo SELECT col1, col2) AS my-cte ".
        "FROM my-cte WHERE 10 in my-cte.col1 SELECT *"
  =/  pred=(tree predicate-component:ast)
        [%in literal-10 my-cte-col1]
  =/  expected
        :+  %selection
            ctes=~[cte-my-cte-cols]
            :-  %query
                :*  %query
                    from-my-cte-outer
                    scalars=~
                    pred
                    group-by=~
                    having=~
                    select-all-columns
                    order-by=~
                    ==
  %+  expect-eq
    !>  ~[expected]
    !>  (parse:parse(default-database 'db1') query)
::
::  7: <column> in <cte>.<col>
++  test-predicate-64
  =/  query
        "WITH (FROM foo SELECT col1, col2) AS my-cte ".
        "FROM my-cte WHERE col1 in my-cte.col2 SELECT *"
  =/  pred=(tree predicate-component:ast)
        [%in unq-col1 my-cte-col2]
  =/  expected
        :+  %selection
            ctes=~[cte-my-cte-cols]
            :-  %query
                :*  %query
                    from-my-cte-outer
                    scalars=~
                    pred
                    group-by=~
                    having=~
                    select-all-columns
                    order-by=~
                    ==
  %+  expect-eq
    !>  ~[expected]
    !>  (parse:parse(default-database 'db1') query)
::
::  test cte column in predicate, joined tables, named cte columns
::
::  1: <cte1>.<col> = <cte2>.<col>
++  test-predicate-65
  =/  query
        "WITH (FROM foo SELECT col1, col2) AS cte1, ".
        "(FROM bar SELECT col1, col2) AS cte2 ".
        "FROM cte1 JOIN cte2 ON cte1.col1 = cte2.col1 ".
        "WHERE cte1.col1 = cte2.col2 SELECT *"
  =/  pred=(tree predicate-component:ast)
        [%eq cte1-col1 cte2-col2]
  =/  expected
        :+  %selection
            ctes=~[cte-cte1-cols cte-cte2-cols]
            :-  %query
                :*  %query
                    from-cte1-join-cte2
                    scalars=~
                    pred
                    group-by=~
                    having=~
                    select-all-columns
                    order-by=~
                    ==
  %+  expect-eq
    !>  ~[expected]
    !>  (parse:parse(default-database 'db1') query)
::
::  2: <cte1>.<col> = <literal>
++  test-predicate-66
  =/  query
        "WITH (FROM foo SELECT col1, col2) AS cte1, ".
        "(FROM bar SELECT col1, col2) AS cte2 ".
        "FROM cte1 JOIN cte2 ON cte1.col1 = cte2.col1 ".
        "WHERE cte1.col1 = 10 SELECT *"
  =/  pred=(tree predicate-component:ast)
        [%eq cte1-col1 literal-10]
  =/  expected
        :+  %selection
            ctes=~[cte-cte1-cols cte-cte2-cols]
            :-  %query
                :*  %query
                    from-cte1-join-cte2
                    scalars=~
                    pred
                    group-by=~
                    having=~
                    select-all-columns
                    order-by=~
                    ==
  %+  expect-eq
    !>  ~[expected]
    !>  (parse:parse(default-database 'db1') query)
::
::  3: <literal> = <cte1>.<col>
++  test-predicate-67
  =/  query
        "WITH (FROM foo SELECT col1, col2) AS cte1, ".
        "(FROM bar SELECT col1, col2) AS cte2 ".
        "FROM cte1 JOIN cte2 ON cte1.col1 = cte2.col1 ".
        "WHERE 10 = cte1.col1 SELECT *"
  =/  pred=(tree predicate-component:ast)
        [%eq literal-10 cte1-col1]
  =/  expected
        :+  %selection
            ctes=~[cte-cte1-cols cte-cte2-cols]
            :-  %query
                :*  %query
                    from-cte1-join-cte2
                    scalars=~
                    pred
                    group-by=~
                    having=~
                    select-all-columns
                    order-by=~
                    ==
  %+  expect-eq
    !>  ~[expected]
    !>  (parse:parse(default-database 'db1') query)
::
::  4: <cte1>.<col> = <column>
++  test-predicate-68
  =/  query
        "WITH (FROM foo SELECT col1, col2) AS cte1, ".
        "(FROM bar SELECT col1, col2) AS cte2 ".
        "FROM cte1 JOIN cte2 ON cte1.col1 = cte2.col1 ".
        "WHERE cte1.col1 = col2 SELECT *"
  =/  pred=(tree predicate-component:ast)
        [%eq cte1-col1 unq-col2]
  =/  expected
        :+  %selection
            ctes=~[cte-cte1-cols cte-cte2-cols]
            :-  %query
                :*  %query
                    from-cte1-join-cte2
                    scalars=~
                    pred
                    group-by=~
                    having=~
                    select-all-columns
                    order-by=~
                    ==
  %+  expect-eq
    !>  ~[expected]
    !>  (parse:parse(default-database 'db1') query)
::
::  5: <column> = <cte2>.<col>
++  test-predicate-69
  =/  query
        "WITH (FROM foo SELECT col1, col2) AS cte1, ".
        "(FROM bar SELECT col1, col2) AS cte2 ".
        "FROM cte1 JOIN cte2 ON cte1.col1 = cte2.col1 ".
        "WHERE col1 = cte2.col2 SELECT *"
  =/  pred=(tree predicate-component:ast)
        [%eq unq-col1 cte2-col2]
  =/  expected
        :+  %selection
            ctes=~[cte-cte1-cols cte-cte2-cols]
            :-  %query
                :*  %query
                    from-cte1-join-cte2
                    scalars=~
                    pred
                    group-by=~
                    having=~
                    select-all-columns
                    order-by=~
                    ==
  %+  expect-eq
    !>  ~[expected]
    !>  (parse:parse(default-database 'db1') query)
::
::  6: <literal> in <cte1>.<col>
++  test-predicate-70
  =/  query
        "WITH (FROM foo SELECT col1, col2) AS cte1, ".
        "(FROM bar SELECT col1, col2) AS cte2 ".
        "FROM cte1 JOIN cte2 ON cte1.col1 = cte2.col1 ".
        "WHERE 10 in cte1.col1 SELECT *"
  =/  pred=(tree predicate-component:ast)
        [%in literal-10 cte1-col1]
  =/  expected
        :+  %selection
            ctes=~[cte-cte1-cols cte-cte2-cols]
            :-  %query
                :*  %query
                    from-cte1-join-cte2
                    scalars=~
                    pred
                    group-by=~
                    having=~
                    select-all-columns
                    order-by=~
                    ==
  %+  expect-eq
    !>  ~[expected]
    !>  (parse:parse(default-database 'db1') query)
::
::  7: <column> in <cte2>.<col>
++  test-predicate-71
  =/  query
        "WITH (FROM foo SELECT col1, col2) AS cte1, ".
        "(FROM bar SELECT col1, col2) AS cte2 ".
        "FROM cte1 JOIN cte2 ON cte1.col1 = cte2.col1 ".
        "WHERE col1 in cte2.col2 SELECT *"
  =/  pred=(tree predicate-component:ast)
        [%in unq-col1 cte2-col2]
  =/  expected
        :+  %selection
            ctes=~[cte-cte1-cols cte-cte2-cols]
            :-  %query
                :*  %query
                    from-cte1-join-cte2
                    scalars=~
                    pred
                    group-by=~
                    having=~
                    select-all-columns
                    order-by=~
                    ==
  %+  expect-eq
    !>  ~[expected]
    !>  (parse:parse(default-database 'db1') query)
::
::  bare hyphenated unqualified column in predicate
++  test-predicate-72
  =/  query
        "FROM foo WHERE left-scalar = 10 SELECT *"
  =/  pred=(tree predicate-component:ast)
        [%eq left-scalar literal-10]
  =/  expected
        :+  %selection
            ctes=~
            :-  %query
                :*  %query
                    from-foo
                    scalars=~
                    pred
                    group-by=~
                    having=~
                    select-all-columns
                    order-by=~
                    ==
  %+  expect-eq
    !>  ~[expected]
    !>  (parse:parse(default-database 'db1') query)
--
