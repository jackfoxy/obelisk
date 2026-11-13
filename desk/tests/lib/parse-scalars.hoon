/-  ast=obelisk-ast
/+  parse,  *test
::
|%
::
::  helper gates
::
::  mk-crud-txn
::  returns a constant crud-txn with scalars set to arg
++  mk-crud-txn
  |=  [scalars=(list scalar:ast) table=(unit qualified-table:ast)]
  ^-  (list command:ast)
  =/  columns  ~[unqualified-foo-2 unqualified-foo-3]
  (mk-crud-txn-columns scalars table columns)
::  same as mk-crud-txn, but with explicit selected columns
++  mk-crud-txn-columns
  |=  [scalars=(list scalar:ast) table=(unit qualified-table:ast) columns=(list selected-column:ast)]
  ^-  (list command:ast)
  =/  select  [%select top=~ columns=columns]
  =/  relation  ?~(table relation-1 (need table))
  =/  from  [%from relation-id=relation as-of=~ joins=~]
  =/  query
    :*
      %query
      from=[~ from]
      scalars=scalars
      ~
      group-by=~
      having=~
      select=select
      ~
    ==
  ~[[%crud-txn ctes=~ body=[%query query]]]
::  same as mk-crud-txn, but without a FROM clause
++  mk-crud-txn-no-from-columns
  |=  [scalars=(list scalar:ast) columns=(list selected-column:ast)]
  ^-  (list command:ast)
  =/  select  [%select top=~ columns=columns]
  =/  query
    :*
      %query
      from=~
      scalars=scalars
      ~
      group-by=~
      having=~
      select=select
      ~
    ==
  ~[[%crud-txn ctes=~ body=[%query query]]]
::  same as mk-crud-txn, but with explicit ctes
++  mk-crud-txn-with-ctes
  |=  [ctes=(list cte:ast) scalars=(list scalar:ast) table=(unit qualified-table:ast)]
  ^-  (list command:ast)
  =/  columns  ~[unqualified-foo-2 unqualified-foo-3]
  (mk-crud-txn-with-ctes-columns ctes scalars table columns)
::  same as mk-crud-txn-with-ctes, but with explicit selected columns
++  mk-crud-txn-with-ctes-columns
  |=  [ctes=(list cte:ast) scalars=(list scalar:ast) table=(unit qualified-table:ast) columns=(list selected-column:ast)]
  ^-  (list command:ast)
  =/  select  [%select top=~ columns=columns]
  =/  relation  ?~(table relation-1 (need table))
  =/  from  [%from relation-id=relation as-of=~ joins=~]
  =/  query
    :*
      %query
      from=[~ from]
      scalars=scalars
      ~
      group-by=~
      having=~
      select=select
      ~
    ==
  ~[[%crud-txn ctes=ctes body=[%query query]]]
::
::  helper-objects
::
++  default-db           'db1'
++  default-namespace    %dbo
::
++  relation-1          :*  %qualified-table
                            ship=~
                            database=%db1
                            namespace=%dbo
                            name=%foo
                            alias=~
                            ==
::  CTE helpers
++  my-cte-foo-2        [%cte-column 'my-cte' 'foo2']
++  my-cte-foo-3        [%cte-column 'my-cte' 'foo3']
++  cte-my-cte
  =/  from-clause  [%from relation-id=relation-1 as-of=~ joins=~]
  =/  select  [%select top=~ columns=~[unqualified-foo-2 unqualified-foo-3]]
  =/  q
    :*  %query  [~ from-clause]  scalars=~  ~
        group-by=~  having=~  select  ~
        ==
  :*  %cte  name='my-cte'
      body=[%query q]
      ==
::
::  @p.<database>.<namespace>.<table-or-view>.<column-name>
::  ~sampel-palnet.db2.dba.table1.bar
++  qualified-col-1  :^  %qualified-column
                       :*  %qualified-table
                           ship=(some ~sampel-palnet)
                           database=%db2
                           namespace=%dba
                           name=%table1
                           alias=~
                           ==
                       name=%bar
                       alias=~
::  @p.<database>..<table-or-view>.<column-name>
::  ~sampel-palnet.db2..table1.bar
++  qualified-col-2  :^  %qualified-column
                       :*  %qualified-table
                           ship=(some ~sampel-palnet)
                           database=%db2
                           namespace=default-namespace
                           name=%table1
                           alias=~
                           ==
                       name=%bar
                       alias=~
::  <database>.<namespace>.<table-or-view>.<column-name>
::  db2.dba.table1.bar
++  qualified-col-3  :^  %qualified-column
                       :*  %qualified-table
                           ship=~
                           database=%db2
                           namespace=%dba
                           name=%table1
                           alias=~
                           ==
                       name=%bar
                       alias=~
::  <database>..<table-or-view>.<column-name>
::  db2..table1.bar
++  qualified-col-4  :^  %qualified-column
                       :*  %qualified-table
                           ship=~
                           database=%db2
                           namespace=default-namespace
                           name=%table1
                           alias=~
                           ==
                       name=%bar
                       alias=~
::  <namespace>.<table-or-view>.<column-name>
::  dba.table1.bar
++  qualified-col-5  :^  %qualified-column
                       :*  %qualified-table
                           ship=~
                           database=default-db
                           namespace=%dba
                           name=%table1
                           alias=~
                           ==
                       name=%bar
                       alias=~
::  <alias>.<column-name>
::  MyTable.bar
++  qualified-col-6  :^  %qualified-column
                       :*  %qualified-table
                           ship=(some ~sampel-palnet)
                           database=%db2
                           namespace=%dba
                           name=%table1
                           alias=(some 'MyTable')
                           ==
                       name=%bar
                       alias=~
::  <column-name>
::  bar
++  unqualified-foo-3   [%unqualified-column name=%foo3 alias=~]
++  unqualified-foo-2   [%unqualified-column name=%foo2 alias=~]
++  unqualified-foo-1   [%unqualified-column name=%foo1 alias=~]
++  selected-scalar-foo-3  [%selected-scalar name=%foo3 alias=~]
++  selected-scalar-foo-2  [%selected-scalar name=%foo2 alias=~]
::
++  simple-true-pred       [%eq [[p=~.ud q=1] ~ ~] [[p=~.ud q=1] ~ ~]]
++  simple-false-pred      [%eq [[p=~.ud q=1] ~ ~] [[p=~.ud q=0] ~ ~]]
::
++  literal-zod            [p=%p q=0]
++  literal-1              [p=~.ud q=1]
::
::  generic scalar-agnostic tests
::
::  test defining scalars in lowercase, uppercase, mixed-case
++  test-scalars-01
  =/  query-string
    "FROM foo ".
    "SCALARS foo-co COALESCE(foo3,~zod,1,foo3)".
    "        bar-co coalesce(foo3,~zod,1,foo3)".
    "        baz-co CoaLeSce(foo3,~zod,1,foo3)".
    "        baz-if IF 1 = 1 THEN foo3 ELSE foo2 ENDIF ".
    "        bar-if if 1 = 1 then foo3 else foo2 endif ".
    "        foo-if If 1 = 1 TheN foo3 ElsE foo2 EndiF ".
    "        baz-ca CASE WHEN 1 = 1 THEN foo3 ELSE foo2 END ".
    "        bar-ca case when 1 = 1 then foo3 else foo2 end ".
    "        foo-ca CasE WheN 1 = 1 TheN foo3 ElsE foo2 EnD ".
    "SELECT foo2,foo3"
  ::
  =/  coalesce
    [%coalesce ~[unqualified-foo-3 literal-zod literal-1 unqualified-foo-3]]
  =/  if
    :*  %if-then-else
      if=simple-true-pred
      then=[unqualified-foo-3]
      else=[unqualified-foo-2]
    ==
  =/  case
    :*
      %case
      target=~
      cases=~[[%case-when-then simple-true-pred unqualified-foo-3]]
      else=(some unqualified-foo-2)
    ==
  =/  scalars
    :~
      [%scalar 'foo-co' coalesce]
      [%scalar 'bar-co' coalesce]
      [%scalar 'baz-co' coalesce]
      [%scalar 'baz-if' if]
      [%scalar 'bar-if' if]
      [%scalar 'foo-if' if]
      [%scalar 'baz-ca' case]
      [%scalar 'bar-ca' case]
      [%scalar 'foo-ca' case]
    ==
  =/  expected  (mk-crud-txn scalars ~)
  %+  expect-eq
    !>  expected
    !>  (parse:parse(default-database default-db) query-string)
::
::  test-scalars-02 test mixed-case keyword and unqualified columns
++  test-scalars-02
  =/  query-string
    "FROM foo ".
    "SCalARS bar1 COALESCE(foo3,~zod,1,foo2) ".
    "        bar2 COALESCE(foo2,~zod,1,foo3) ".
    "SELECT foo2,foo3"
  ::
  =/  coalesce-1
    [%coalesce ~[unqualified-foo-3 literal-zod literal-1 unqualified-foo-2]]
  =/  coalesce-2
    [%coalesce ~[unqualified-foo-2 literal-zod literal-1 unqualified-foo-3]]
  =/  scalars
    :~
      [%scalar 'bar1' coalesce-1]
      [%scalar 'bar2' coalesce-2]
    ==
  =/  expected  (mk-crud-txn scalars ~)
  %+  expect-eq
    !>  expected
    !>  (parse:parse(default-database default-db) query-string)
::
::  select a scalar-name directly in the SELECT clause
++  test-scalars-select-01
  =/  query-string
    "SCALARS sc1 ABS(-5) ".
    "SELECT sc1"
  ::
  =/  literal-neg5  [p=~.sd q=-5]
  =/  scalars
    ~[[%scalar 'sc1' [%abs literal-neg5]]]
  =/  expected
    (mk-crud-txn-no-from-columns scalars ~[[%selected-scalar name=%sc1 alias=~]])
  %+  expect-eq
    !>  expected
    !>  (parse:parse(default-database default-db) query-string)
::
::  select a scalar-name directly in the SELECT clause with alias
++  test-scalars-select-02
  =/  query-string
    "SCALARS sc1 ABS(-5) ".
    "SELECT sc1 AS answer"
  ::
  =/  literal-neg5  [p=~.sd q=-5]
  =/  scalars
    ~[[%scalar 'sc1' [%abs literal-neg5]]]
  =/  expected
    %-  mk-crud-txn-no-from-columns
    :*  scalars
        ~[[%selected-scalar name=%sc1 alias=[~ 'answer']]]
        ==
  %+  expect-eq
    !>  expected
    !>  (parse:parse(default-database default-db) query-string)
::
::  select multiple scalar-names directly in a no-from query
++  test-scalars-select-03
  =/  query-string
    "SCALARS sc1 CONCAT('hello',' world') ".
    "        sc2 IF 1 = 1 THEN 42 ELSE 0 ENDIF ".
    "        sc3 20 + 22 END ".
    "SELECT sc1, sc2, sc3"
  ::
  =/  literal-hello  [p=~.t q='hello']
  =/  literal-world  [p=~.t q=' world']
  =/  literal-42     [p=~.ud q=42]
  =/  literal-0      [p=~.ud q=0]
  =/  literal-20     [p=~.ud q=20]
  =/  literal-22     [p=~.ud q=22]
  =/  if-scalar
    :*  %if-then-else
      if=simple-true-pred
      then=literal-42
      else=literal-0
    ==
  =/  arithmetic-scalar
    [%arithmetic operator=%lus left=literal-20 right=literal-22]
  =/  scalars
    :~
      [%scalar 'sc1' [%concat ~[literal-hello literal-world]]]
      [%scalar 'sc2' if-scalar]
      [%scalar 'sc3' arithmetic-scalar]
    ==
  =/  expected
    %-  mk-crud-txn-no-from-columns
    :*  scalars
        :~  [%selected-scalar name=%sc1 alias=~]
            [%selected-scalar name=%sc2 alias=~]
            [%selected-scalar name=%sc3 alias=~]
            ==
        ==
  %+  expect-eq
    !>  expected
    !>  (parse:parse(default-database default-db) query-string)
::
::  no-from scalar select with text and date IF literal branches
++  test-scalars-select-03-literals
  =/  query-string
    "SCALARS sc1 CONCAT('hello',' world') ".
    "        sc2 IF 1 = 1 THEN 'yes' ELSE 'no' ENDIF ".
    "        sc3 IF 1 = 1 THEN ~2024.12.25 ELSE ~2024.12.26 ENDIF ".
    "        sc4 20 + 22 END ".
    "SELECT sc1, sc2, sc3, sc4"
  ::
  =/  literal-hello  [p=~.t q='hello']
  =/  literal-world  [p=~.t q=' world']
  =/  literal-yes    [p=~.t q='yes']
  =/  literal-no     [p=~.t q='no']
  =/  literal-date1  [p=~.da q=~2024.12.25]
  =/  literal-date2  [p=~.da q=~2024.12.26]
  =/  literal-20     [p=~.ud q=20]
  =/  literal-22     [p=~.ud q=22]
  =/  text-if-scalar
    :*  %if-then-else
      if=simple-true-pred
      then=literal-yes
      else=literal-no
    ==
  =/  date-if-scalar
    :*  %if-then-else
      if=simple-true-pred
      then=literal-date1
      else=literal-date2
    ==
  =/  arithmetic-scalar
    [%arithmetic operator=%lus left=literal-20 right=literal-22]
  =/  scalars
    :~
      [%scalar 'sc1' [%concat ~[literal-hello literal-world]]]
      [%scalar 'sc2' text-if-scalar]
      [%scalar 'sc3' date-if-scalar]
      [%scalar 'sc4' arithmetic-scalar]
    ==
  =/  expected
    %-  mk-crud-txn-no-from-columns
    :*  scalars
        :~  [%selected-scalar name=%sc1 alias=~]
            [%selected-scalar name=%sc2 alias=~]
            [%selected-scalar name=%sc3 alias=~]
            [%selected-scalar name=%sc4 alias=~]
            ==
        ==
  %+  expect-eq
    !>  expected
    !>  (parse:parse(default-database default-db) query-string)
::
::  when a FROM exists, scalar names resolve as selected-scalar
++  test-scalars-select-04
  =/  query-string
    "FROM foo ".
    "SCALARS foo2 ABS(-5) ".
    "SELECT foo2"
  ::
  =/  literal-neg5  [p=~.sd q=-5]
  =/  scalars
    ~[[%scalar 'foo2' [%abs literal-neg5]]]
  =/  expected
    %-  mk-crud-txn-columns
    :*  scalars
        ~
        ~[selected-scalar-foo-2]
        ==
  %+  expect-eq
    !>  expected
    !>  (parse:parse(default-database default-db) query-string)
::
::  selected-scalar with alias inside a CTE should produce a selectable CTE column
++  test-scalars-select-05
  =/  query-string
    "WITH (SCALARS sc1 ABS(-5) SELECT sc1 AS sc-out) AS my-cte ".
    "FROM my-cte ".
    "SELECT sc-out"
  ::
  =/  literal-neg5  [p=~.sd q=-5]
  =/  cte-scalars
    ~[[%scalar 'sc1' [%abs literal-neg5]]]
  =/  cte-query
    =/  select  [%select top=~ columns=~[[%selected-scalar name=%sc1 alias=[~ 'sc-out']]]]
    :*  %query  from=~  scalars=cte-scalars  ~
        group-by=~  having=~  select  ~
        ==
  =/  ctes
    ~[[%cte name='my-cte' body=[%query cte-query]]]
  =/  outer-query
    :*  %query
        from=[~ [%from relation-id=[%cte-name name='my-cte' alias=~] as-of=~ joins=~]]
        scalars=~
        ~
        group-by=~
        having=~
        select=[%select top=~ columns=~[[%unqualified-column name='sc-out' alias=~]]]
        ~
        ==
  =/  expected
    ~[[%crud-txn ctes=ctes body=[%query outer-query]]]
  %+  expect-eq
    !>  expected
    !>  (parse:parse(default-database default-db) query-string)
::
::  selected-value with alias inside a CTE should produce a selectable CTE column
++  test-scalars-select-06
  =/  query-string
    "WITH (FROM foo SELECT foo2, foo3, 'US' AS country) AS my-cte ".
    "FROM my-cte ".
    "SELECT foo2, country"
  ::
  =/  literal-us  [p=~.t q='US']
  =/  cte-query
    =/  select
      [%select top=~ columns=~[unqualified-foo-2 unqualified-foo-3 [%selected-value value=literal-us alias=[~ 'country']]]]
    :*  %query  from=[~ [%from relation-id=relation-1 as-of=~ joins=~]]  scalars=~  ~
        group-by=~  having=~  select  ~
        ==
  =/  ctes
    ~[[%cte name='my-cte' body=[%query cte-query]]]
  =/  outer-query
    :*  %query
        from=[~ [%from relation-id=[%cte-name name='my-cte' alias=~] as-of=~ joins=~]]
        scalars=~
        ~
        group-by=~
        having=~
        select=[%select top=~ columns=~[[%unqualified-column name='foo2' alias=~] [%unqualified-column name='country' alias=~]]]
        ~
        ==
  =/  expected
    ~[[%crud-txn ctes=ctes body=[%query outer-query]]]
  %+  expect-eq
    !>  expected
    !>  (parse:parse(default-database default-db) query-string)
::
::  test mixing arithmetic with builtin functions
++  test-scalars-03
  =/  query-string
    "FROM foo ".
    "SCALARS sc1 ABS(-5) + 1 END ".
    "        sc2 FLOOR(.2.8) - CEILING(.1.2) END ".
    "        sc4 LOG(10) / ABS(-5) END ".
    "        sc5 ROUND(.3.7, 0) ^ 2 END ".
    "        sc6 LEN('hello') + DAY(2023.1.15) END ".
    "        sc7 (ABS(-3) + FLOOR(.2.9)) * SQRT(16) END ".
    "        sc9 YEAR(2023.6.20) - MONTH(2023.6.20) END ".
    "        sc10 (LOG(100) + SIGN(-5)) / (SQRT(9) - 1) END ".
    "SELECT foo2,foo3"
  ::
  =/  literal-05             [p=~.rs q=.5]
  =/  literal-1              [p=~.ud q=1]
  =/  literal-28             [p=~.rs q=.2.8]
  =/  literal-12             [p=~.rs q=.1.2]
  =/  literal-4              [p=~.ud q=4]
  =/  literal-2              [p=~.ud q=2]
  =/  literal-3              [p=~.ud q=3]
  =/  literal-10             [p=~.ud q=10]
  =/  literal-neg5           [p=~.sd q=-5]
  =/  literal-37             [p=~.rs q=.3.7]
  =/  literal-0              [p=~.ud q=0]
  =/  literal-hello          [p=~.t q='hello']
  =/  literal-date1          [p=~.da q=~2023.1.15]
  =/  literal-neg3           [p=~.sd q=-3]
  =/  literal-29             [p=~.rs q=.2.9]
  =/  literal-16             [p=~.ud q=16]
  =/  literal-15             [p=~.rs q=.1.5]
  =/  literal-neg2           [p=~.sd q=-2]
  =/  literal-date2          [p=~.da q=~2023.6.20]
  =/  literal-100            [p=~.ud q=100]
  =/  literal-9              [p=~.ud q=9]
  ::
  =/  sc1
    [%arithmetic operator=%lus left=[%abs literal-neg5] right=literal-1]
  =/  sc2
    :*
      %arithmetic
      operator=%hep
      left=[%floor literal-28]
      right=[%ceiling literal-12]
    ==
  =/  sc4
    :*
      %arithmetic
      operator=%fas
      left=[%log literal-10 ~]
      right=[%abs literal-neg5]
    ==
  =/  sc5
    :*
      %arithmetic
      operator=%ket
      left=[%round literal-37 literal-0]
      right=literal-2
    ==
  =/  sc6
    :*
      %arithmetic
      operator=%lus
      left=[%len literal-hello]
      right=[%day literal-date1]
    ==
  =/  sc7
    :*
      %arithmetic
      operator=%tar
      :^  %arithmetic
          operator=%lus
          left=[%abs literal-neg3]
          right=[%floor literal-29]
      right=[%sqrt literal-16]
    ==
  =/  sc9
    :*
      %arithmetic
      operator=%hep
      left=[%year literal-date2]
      right=[%month literal-date2]
    ==
  =/  sc10
    :*
      %arithmetic
      operator=%fas
      :^  %arithmetic
          operator=%lus
          left=[%log literal-100 ~]
          right=[%sign literal-neg5]
      right=[%arithmetic operator=%hep left=[%sqrt literal-9] right=literal-1]
    ==
  =/  scalars
    :~
      [%scalar 'sc1' sc1]
      [%scalar 'sc2' sc2]
      [%scalar 'sc4' sc4]
      [%scalar 'sc5' sc5]
      [%scalar 'sc6' sc6]
      [%scalar 'sc7' sc7]
      [%scalar 'sc9' sc9]
      [%scalar 'sc10' sc10]
    ==
  =/  expected  (mk-crud-txn scalars ~)
  %+  expect-eq
    !>  expected
    !>  (parse:parse(default-database default-db) query-string)
::
::  test-fail-scalars-01 tests that parsing fails when there are two scalars
::  with the same alias
++  test-fail-scalars-01
  =/  query-string
    "FROM foo ".
    "SCALARS bar1 COALESCE(foo3,~zod,1,foo3) ".
    "        bar1 COALESCE(foo1,~zod,1,foo3) ".
    "SELECT foo2,foo3"
  ::
  %+  expect-fail-message
    'there is already a scalar named %bar1'
    |.  (parse:parse(default-database default-db) query-string)
::  test-fail-scalars-02 tests that parsing fails when scalars are defined
::  without a select statement after
++  test-fail-scalars-02
  =/  query-string
    "FROM foo ".
    "SCALARS bar1 COALESCE(foo3,~zod,1,foo3) ".
    "        bar1 COALESCE(foo1,~zod,1,foo3) "
  ::
  %+  expect-fail-message
    'PARSER: '
    |.  (parse:parse(default-database default-db) query-string)
::
::  builtin scalar functions
::  spaces after parameters, also test for optional parameters
++  test-builtins-01
::  randomized spacing
  =/  query-string
    "FROM foo ".
    "SCALARS dt1 GETUTCDATE() ".
    "        dt3 DAY( 2023.1.15  ) ".
    "        dt4 MONTH(  2023.1.15) ".
    "        dt5 YEAR(2023.1.15   ) ".
    "        mt1 ABS(   -5 ) ".
    "        mt2 LOG(.5  , 2   ) ".
    "        mt21 LOG(  .5) ".
    "        mt3 FLOOR( .5    ) ".
    "        mt5 CEILING(.5  ) ".
    "        mt6 ROUND(  .5 ,2   ) ".
    "        mt61 ROUND(.5   ,  2) ".
    "        mt7 SIGN(   -5   ) ".
    "        mt8 SQRT( .5 ) ".
    "        st1 LEN(  'hello'   ) ".
    "        st2 LEFT('hello'  ,  3   ) ".
    "        st3 RIGHT(   'hello',3 ) ".
    "        st4 SUBSTRING( 'hello'   , 2  ,3    ) ".
    "        st5 TRIM(  ' ' ,'hello'  ) ".
    "        st51 TRIM(   'hello'    ) ".
    "        st6 CONCAT(  'hello'    ,  'world' ) ".
    "        dq1 DAY( ~sampel-palnet.db2.dba.table1.bar  ) ".
    "        dq2 DAY(  db2.dba.table1.bar ) ".
    "        dq3 DAY(   dba.table1.bar) ".
    "        du1 DAY( foo3  ) ".
    "        ds1 DAY(  dt3 ) ".
    "        aq1 ABS(   ~sampel-palnet.db2.dba.table1.bar ) ".
    "        au1 ABS( foo3   ) ".
    "        as1 ABS(  mt1  ) ".
    "        lq1 LEN(  ~sampel-palnet.db2.dba.table1.bar   ) ".
    "        lu1 LEN(   foo3 ) ".
    "        ls1 LEN( st1   ) ".
    "SELECT foo2,foo3"
  ::
  =/  literal-date           [p=~.da q=~2023.1.15]
  =/  literal-float          [p=~.rs q=.5]
  =/  literal-float2         [p=~.rs q=.2]
  =/  literal-2              [p=~.ud q=2]
  =/  literal-3              [p=~.ud q=3]
  =/  literal-1              [p=~.ud q=1]
  =/  literal-hello          [p=~.t q='hello']
  =/  literal-world          [p=~.t q='world']
  =/  literal-space          [p=~.t q=' ']
  =/  literal-neg5           [p=~.sd q=-5]
  ::              
  =/  scalars
    :~
      [%scalar 'dt1' [%getutcdate ~]]
      [%scalar 'dt3' [%day literal-date]]
      [%scalar 'dt4' [%month literal-date]]
      [%scalar 'dt5' [%year literal-date]]
      [%scalar 'mt1' [%abs literal-neg5]]
      [%scalar 'mt2' [%log literal-float `literal-2]]
      [%scalar 'mt21' [%log literal-float ~]]
      [%scalar 'mt3' [%floor literal-float]]
      [%scalar 'mt5' [%ceiling literal-float]]
      [%scalar 'mt6' [%round literal-float literal-2]]
      [%scalar 'mt61' [%round literal-float literal-2]]
      [%scalar 'mt7' [%sign literal-neg5]]
      [%scalar 'mt8' [%sqrt literal-float]]
      [%scalar 'st1' [%len literal-hello]]
      [%scalar 'st2' [%left literal-hello literal-3]]
      [%scalar 'st3' [%right literal-hello literal-3]]
      [%scalar 'st4' [%substring literal-hello literal-2 `literal-3]]
      [%scalar 'st5' [%trim literal-space `literal-hello]]
      [%scalar 'st51' [%trim literal-hello ~]]
      [%scalar 'st6' [%concat ~[literal-hello literal-world]]]
      [%scalar 'dq1' [%day qualified-col-1]]
      [%scalar 'dq2' [%day qualified-col-3]]
      [%scalar 'dq3' [%day qualified-col-5]]
      [%scalar 'du1' [%day unqualified-foo-3]]
      [%scalar 'ds1' [%day [%scalar-name name=%dt3]]]
      [%scalar 'aq1' [%abs qualified-col-1]]
      [%scalar 'au1' [%abs unqualified-foo-3]]
      [%scalar 'as1' [%abs [%scalar-name name=%mt1]]]
      [%scalar 'lq1' [%len qualified-col-1]]
      [%scalar 'lu1' [%len unqualified-foo-3]]
      [%scalar 'ls1' [%len [%scalar-name name=%st1]]]
    ==
  =/  expected  (mk-crud-txn scalars ~)
  %+  expect-eq
    !>  expected
    !>  (parse:parse(default-database default-db) query-string)
::
::  spaces before parameters
++  test-builtins-02
  =/  query-string
    "FROM ~sampel-palnet.db2.dba.table1 AS MyTable ".
    "SCALARS dt1 GETUTCDATE() ".
    "        dt3 DAY(  2023.1.15) ".
    "        dt4 MONTH(   2023.1.15) ".
    "        dt5 YEAR( 2023.1.15) ".
    "        mt1 ABS(    -5) ".
    "        mt2 LOG( .5,   2) ".
    "        mt3 FLOOR(  .5) ".
    "        mt5 CEILING( .5) ".
    "        mt6 ROUND(    .5,  2) ".
    "        mt7 SIGN(  -5) ".
    "        mt8 SQRT(   .5) ".
    "        st1 LEN( 'hello') ".
    "        st2 LEFT(    'hello',  3) ".
    "        st3 RIGHT(  'hello',   3) ".
    "        st4 SUBSTRING( 'hello',    2,  3) ".
    "        st5 TRIM(   ' ', 'hello') ".
    "        st6 CONCAT(  'hello',    'world') ".
    "        mq1 MONTH( ~sampel-palnet.db2..table1.bar) ".
    "        mu1 MONTH(  foo3) ".
    "        ms1 MONTH(   dt4 ) ".
    "        fq1 FLOOR(   db2..table1.bar) ".
    "        fu1 FLOOR( foo3) ".
    "        fs1 FLOOR(  mt3  ) ".
    "SELECT foo2,foo3"
  ::
  =/  literal-date           [p=~.da q=~2023.1.15]
  =/  literal-float          [p=~.rs q=.5]
  =/  literal-float2         [p=~.rs q=.2]
  =/  literal-2              [p=~.ud q=2]
  =/  literal-3              [p=~.ud q=3]
  =/  literal-1              [p=~.ud q=1]
  =/  literal-hello          [p=~.t q='hello']
  =/  literal-world          [p=~.t q='world']
  =/  literal-space          [p=~.t q=' ']
  =/  literal-neg5           [p=~.sd q=-5]
  ::
  =/  scalars
    :~
      [%scalar 'dt1' [%getutcdate ~]]
      [%scalar 'dt3' [%day literal-date]]
      [%scalar 'dt4' [%month literal-date]]
      [%scalar 'dt5' [%year literal-date]]
      [%scalar 'mt1' [%abs literal-neg5]]
      [%scalar 'mt2' [%log literal-float `literal-2]]
      [%scalar 'mt3' [%floor literal-float]]
      [%scalar 'mt5' [%ceiling literal-float]]
      [%scalar 'mt6' [%round literal-float literal-2]]
      [%scalar 'mt7' [%sign literal-neg5]]
      [%scalar 'mt8' [%sqrt literal-float]]
      [%scalar 'st1' [%len literal-hello]]
      [%scalar 'st2' [%left literal-hello literal-3]]
      [%scalar 'st3' [%right literal-hello literal-3]]
      [%scalar 'st4' [%substring literal-hello literal-2 `literal-3]]
      [%scalar 'st5' [%trim literal-space `literal-hello]]
      [%scalar 'st6' [%concat ~[literal-hello literal-world]]]
      [%scalar 'mq1' [%month qualified-col-2]]
      [%scalar 'mu1' [%month unqualified-foo-3]]
      [%scalar 'ms1' [%month [%scalar-name name=%dt4]]]
      [%scalar 'fq1' [%floor qualified-col-4]]
      [%scalar 'fu1' [%floor unqualified-foo-3]]
      [%scalar 'fs1' [%floor [%scalar-name name=%mt3]]]
    ==
  =/  table
    :*  %qualified-table
      ship=[~ ~sampel-palnet]
      database=%db2
      namespace=%dba
      name=%table1
      alias=[~ 'MyTable']
    ==
  =/  expected  (mk-crud-txn scalars (some table))
  %+  expect-eq
    !>  expected
    !>  (parse:parse(default-database default-db) query-string)

::  spaces after parameters
++  test-builtins-03
  =/  query-string
    "FROM ~sampel-palnet.db2.dba.table1 AS MyTable ".
    "SCALARS dt1 GETUTCDATE() ".
    "        dt3 DAY(2023.1.15  ) ".
    "        dt4 MONTH(2023.1.15    ) ".
    "        dt5 YEAR(2023.1.15 ) ".
    "        mt1 ABS(-5     ) ".
    "        mt2 LOG(.5  ,2   ) ".
    "        mt3 FLOOR(.5   ) ".
    "        mt5 CEILING(.5  ) ".
    "        mt6 ROUND(.5     ,2  ) ".
    "        mt7 SIGN(-5   ) ".
    "        mt8 SQRT(.5    ) ".
    "        st1 LEN('hello'  ) ".
    "        st2 LEFT('hello'     ,3  ) ".
    "        st3 RIGHT('hello'   ,3    ) ".
    "        st4 SUBSTRING('hello'  ,2     ,3   ) ".
    "        st5 TRIM(' '    ,'hello'  ) ".
    "        st6 CONCAT('hello'   ,'world'     ) ".
    "        yq1 YEAR(~sampel-palnet.db2.dba.table1.bar  ) ".
    "        yu1 YEAR(foo3 ) ".
    "        ys1 YEAR(dt5 ) ".
    "        cq1 CEILING(db2.dba.table1.bar   ) ".
    "        cu1 CEILING(foo3  ) ".
    "        cs1 CEILING(mt5  ) ".
    "        rq1 ROUND(dba.table1.bar    ,2  ) ".
    "        ru1 ROUND(foo3  ,2     ) ".
    "        rs1 ROUND(mt6, 2) ".
    "SELECT foo2,foo3"
  ::
  =/  literal-date           [p=~.da q=~2023.1.15]
  =/  literal-float          [p=~.rs q=.5]
  =/  literal-float2         [p=~.rs q=.2]
  =/  literal-2              [p=~.ud q=2]
  =/  literal-3              [p=~.ud q=3]
  =/  literal-1              [p=~.ud q=1]
  =/  literal-hello          [p=~.t q='hello']
  =/  literal-world          [p=~.t q='world']
  =/  literal-space          [p=~.t q=' ']
  =/  literal-neg5           [p=~.sd q=-5]
  ::
  =/  scalars
    :~
      [%scalar 'dt1' [%getutcdate ~]]
      [%scalar 'dt3' [%day literal-date]]
      [%scalar 'dt4' [%month literal-date]]
      [%scalar 'dt5' [%year literal-date]]
      [%scalar 'mt1' [%abs literal-neg5]]
      [%scalar 'mt2' [%log literal-float `literal-2]]
      [%scalar 'mt3' [%floor literal-float]]
      [%scalar 'mt5' [%ceiling literal-float]]
      [%scalar 'mt6' [%round literal-float literal-2]]
      [%scalar 'mt7' [%sign literal-neg5]]
      [%scalar 'mt8' [%sqrt literal-float]]
      [%scalar 'st1' [%len literal-hello]]
      [%scalar 'st2' [%left literal-hello literal-3]]
      [%scalar 'st3' [%right literal-hello literal-3]]
      [%scalar 'st4' [%substring literal-hello literal-2 `literal-3]]
      [%scalar 'st5' [%trim literal-space `literal-hello]]
      [%scalar 'st6' [%concat ~[literal-hello literal-world]]]
      [%scalar 'yq1' [%year qualified-col-1]]
      [%scalar 'yu1' [%year unqualified-foo-3]]
      [%scalar 'ys1' [%year [%scalar-name name=%dt5]]]
      [%scalar 'cq1' [%ceiling qualified-col-3]]
      [%scalar 'cu1' [%ceiling unqualified-foo-3]]
      [%scalar 'cs1' [%ceiling [%scalar-name name=%mt5]]]
      [%scalar 'rq1' [%round qualified-col-5 literal-2]]
      [%scalar 'ru1' [%round unqualified-foo-3 literal-2]]
      [%scalar 'rs1' [%round [%scalar-name name=%mt6] literal-2]]
    ==
  =/  table
    :*  %qualified-table
      ship=[~ ~sampel-palnet]
      database=%db2
      namespace=%dba
      name=%table1
      alias=[~ 'MyTable']
    ==
  =/  expected  (mk-crud-txn scalars (some table))
  %+  expect-eq
    !>  expected
    !>  (parse:parse(default-database default-db) query-string)
::
::  spaces before and after parameters
++  test-builtins-04
  =/  query-string
    "FROM ~sampel-palnet.db2.dba.table1 AS MyTable ".
    "SCALARS dt1 GETUTCDATE() ".
    "        dt3 DAY(  2023.1.15    ) ".
    "        dt4 MONTH(   2023.1.15  ) ".
    "        dt5 YEAR( 2023.1.15     ) ".
    "        mt1 ABS(    -5  ) ".
    "        mt2 LOG(  .5   ,   2    ) ".
    "        mt3 FLOOR(   .5     ) ".
    "        mt5 CEILING(    .5   ) ".
    "        mt6 ROUND(  .5     ,   2  ) ".
    "        mt7 SIGN(   -5    ) ".
    "        mt8 SQRT( .5     ) ".
    "        st1 LEN(    'hello'  ) ".
    "        st2 LEFT(  'hello'    ,   3   ) ".
    "        st3 RIGHT(   'hello'  ,    3     ) ".
    "        st4 SUBSTRING( 'hello'     ,  2    ,   3  ) ".
    "        st5 TRIM(    ' '   ,  'hello'     ) ".
    "        st6 CONCAT(  'hello'     ,    'world'  ) ".
    "        sq1 SIGN(  ~sampel-palnet.db2..table1.bar   ) ".
    "        su1 SIGN( foo3    ) ".
    "        ss1 SIGN(   mt7  ) ".
    "        sqq1 SQRT(   db2..table1.bar  ) ".
    "        squ1 SQRT(  foo3    ) ".
    "        sqs1 SQRT(    mt8   ) ".
    "        lfq1 LEFT( MyTable.bar   ,  3    ) ".
    "        lfu1 LEFT(   foo3    ,   3  ) ".
    "        lfs1 LEFT(  st2   ,   3   ) ".
    "SELECT foo2,foo3"
  ::
  =/  literal-date           [p=~.da q=~2023.1.15]
  =/  literal-float          [p=~.rs q=.5]
  =/  literal-float2         [p=~.rs q=.2]
  =/  literal-2              [p=~.ud q=2]
  =/  literal-3              [p=~.ud q=3]
  =/  literal-1              [p=~.ud q=1]
  =/  literal-hello          [p=~.t q='hello']
  =/  literal-world          [p=~.t q='world']
  =/  literal-space          [p=~.t q=' ']
  =/  literal-neg5           [p=~.sd q=-5]
  ::
  =/  scalars
    :~
      [%scalar 'dt1' [%getutcdate ~]]
      [%scalar 'dt3' [%day literal-date]]
      [%scalar 'dt4' [%month literal-date]]
      [%scalar 'dt5' [%year literal-date]]
      [%scalar 'mt1' [%abs literal-neg5]]
      [%scalar 'mt2' [%log literal-float `literal-2]]
      [%scalar 'mt3' [%floor literal-float]]
      [%scalar 'mt5' [%ceiling literal-float]]
      [%scalar 'mt6' [%round literal-float literal-2]]
      [%scalar 'mt7' [%sign literal-neg5]]
      [%scalar 'mt8' [%sqrt literal-float]]
      [%scalar 'st1' [%len literal-hello]]
      [%scalar 'st2' [%left literal-hello literal-3]]
      [%scalar 'st3' [%right literal-hello literal-3]]
      [%scalar 'st4' [%substring literal-hello literal-2 `literal-3]]
      [%scalar 'st5' [%trim literal-space `literal-hello]]
      [%scalar 'st6' [%concat ~[literal-hello literal-world]]]
      [%scalar 'sq1' [%sign qualified-col-2]]
      [%scalar 'su1' [%sign unqualified-foo-3]]
      [%scalar 'ss1' [%sign [%scalar-name name=%mt7]]]
      [%scalar 'sqq1' [%sqrt qualified-col-4]]
      [%scalar 'squ1' [%sqrt unqualified-foo-3]]
      [%scalar 'sqs1' [%sqrt [%scalar-name name=%mt8]]]
      [%scalar 'lfq1' [%left qualified-col-6 literal-3]]
      [%scalar 'lfu1' [%left unqualified-foo-3 literal-3]]
      [%scalar 'lfs1' [%left [%scalar-name name=%st2] literal-3]]
    ==
  =/  table
    :*  %qualified-table
      ship=[~ ~sampel-palnet]
      database=%db2
      namespace=%dba
      name=%table1
      alias=[~ 'MyTable']
    ==
  =/  expected  (mk-crud-txn scalars (some table))
  %+  expect-eq
    !>  expected
    !>  (parse:parse(default-database default-db) query-string)
::
::  coalesce
::
:: simple coalesce
++  test-coalesce-01
::
=/  query-string
  "FROM foo ".
  "SCALARS foo COALESCE(foo2,~zod,1,foo3) ".
  "SELECT foo2,foo3"
::
=/  coalesce-1
  [%coalesce ~[unqualified-foo-2 literal-zod literal-1 unqualified-foo-3]]
=/  scalars
  :~
    [%scalar 'foo' coalesce-1]
  ==
=/  expected  (mk-crud-txn scalars ~)
%+  expect-eq
  !>  expected
  !>  (parse:parse(default-database default-db) query-string)
::
:: coalesce, 2 scalars
++  test-coalesce-02
::
=/  query-string
  "FROM foo ".
  "SCALARS foo COALESCE(foo2,~zod,1,foo3) ".
  "        baz COALESCE(foo2,~zod,1,foo3) ".
  "SELECT foo2,foo3"
::
=/  coalesce-1
  [%coalesce ~[unqualified-foo-2 literal-zod literal-1 unqualified-foo-3]]
=/  scalars
  :~
    [%scalar 'foo' coalesce-1]
    [%scalar 'baz' coalesce-1]
  ==
=/  expected  (mk-crud-txn scalars ~)
%+  expect-eq
  !>  expected
  !>  (parse:parse(default-database default-db) query-string)
::
:: qualified column coalesce with ship.database.namespace.table.column
++  test-coalesce-03
::
=/  query-string
  "FROM foo ".
  "SCALARS foo COALESCE(~sampel-palnet.db2.dba.table1.bar,~zod,1,foo3) ".
  "SELECT foo2,foo3"
::
=/  coalesce-1
  [%coalesce data=~[qualified-col-1 literal-zod literal-1 unqualified-foo-3]]
=/  scalars
  :~
    [%scalar 'foo' coalesce-1]
  ==
=/  expected=(list command:ast)  (mk-crud-txn scalars ~)
%+  expect-eq
  !>  expected
  !>  (parse:parse(default-database default-db) query-string)
::
:: qualified column coalesce with ship.database..table.column (default ns)
++  test-coalesce-04
  ::
  =/  query-string
    "FROM foo ".
    "SCALARS foo COALESCE(~sampel-palnet.db2..table1.bar,~zod,1,foo3) ".
    "SELECT foo2,foo3"
  ::
  =/  coalesce-1
    [%coalesce ~[qualified-col-2 literal-zod literal-1 unqualified-foo-3]]
  =/  scalars
    :~
      [%scalar 'foo' coalesce-1]
    ==
  =/  expected  (mk-crud-txn scalars ~)
  %+  expect-eq
    !>  expected
    !>  (parse:parse(default-database default-db) query-string)
::
:: qualified column coalesce with database.namespace.table.column
++  test-coalesce-05
  ::
  =/  query-string
    "FROM foo ".
    "SCALARS foo COALESCE(db2.dba.table1.bar,~zod,1,foo3) ".
    "SELECT foo2,foo3"
  ::
  =/  coalesce-1
    [%coalesce ~[qualified-col-3 literal-zod literal-1 unqualified-foo-3]]
  =/  scalars
    :~
      [%scalar 'foo' coalesce-1]
    ==
  =/  expected  (mk-crud-txn scalars ~)
  %+  expect-eq
    !>  expected
    !>  (parse:parse(default-database default-db) query-string)
::
:: qualified column coalesce with database..table.column (default namespace)
++  test-coalesce-06
  ::
  =/  query-string
    "FROM foo ".
    "SCALARS foo COALESCE(db2..table1.bar,~zod,1,foo3) ".
    "SELECT foo2,foo3"
  ::
  =/  coalesce-1
    [%coalesce ~[qualified-col-4 literal-zod literal-1 unqualified-foo-3]]
  =/  scalars
    :~
      [%scalar 'foo' coalesce-1]
    ==
  =/  expected  (mk-crud-txn scalars ~)
  %+  expect-eq
    !>  expected
    !>  (parse:parse(default-database default-db) query-string)
::
:: qualified column coalesce with namespace.table.column (default database)
++  test-coalesce-07
  ::
  =/  query-string
    "FROM foo ".
    "SCALARS foo COALESCE(dba.table1.bar,~zod,1,foo3) ".
    "SELECT foo2,foo3"
  ::
  =/  coalesce-1
    [%coalesce ~[qualified-col-5 literal-zod literal-1 unqualified-foo-3]]
  =/  scalars
    :~
      [%scalar 'foo' coalesce-1]
    ==
  =/  expected  (mk-crud-txn scalars ~)
  %+  expect-eq
    !>  expected
    !>  (parse:parse(default-database default-db) query-string)
::
:: qualified column coalesce with alias.column (default database)
++  test-coalesce-08
  ::
  =/  query-string
    "FROM ~sampel-palnet.db2.dba.table1 AS MyTable ".
    "SCALARS foo COALESCE(MyTable.bar,~zod,1,foo3) ".
    "SELECT foo2,foo3"
  ::
  =/  table
    :*  %qualified-table
      ship=[~ ~sampel-palnet]
      database=%db2
      namespace=%dba
      name=%table1
      alias=[~ 'MyTable']
    ==
  =/  coalesce-1
    [%coalesce ~[qualified-col-6 literal-zod literal-1 unqualified-foo-3]]
  =/  scalars
    :~
      [%scalar 'foo' coalesce-1]
    ==
  =/  expected  (mk-crud-txn scalars (some table))
  %+  expect-eq
    !>  expected
    !>  (parse:parse(default-database default-db) query-string)
::
:: qualified column coalesce with alias.column (default database)
:: should fail, table alias is not defined
:: test coalesce with if scalar inline
++  test-coalesce-09
  ::
  =/  query-string
    "FROM foo ".
    "SCALARS foo IF 1 = 1 THEN foo3 ELSE foo2 ENDIF ".
    "        bar COALESCE(foo,foo2,1,foo3) ".
    "SELECT foo2,foo3"
  ::
  =/  naked-if 
    :*
      %if-then-else
      if=simple-true-pred
      then=[unqualified-foo-3]
      else=[unqualified-foo-2]
    ==
  =/  coalesce-1  :-  %coalesce
                      :~  [%scalar-name name=%foo]
                          unqualified-foo-2
                          literal-1
                          unqualified-foo-3
                          ==
  =/  scalars
    :~
      [%scalar 'foo' naked-if]
      [%scalar 'bar' coalesce-1]
    ==
  =/  expected  (mk-crud-txn scalars ~)
  %+  expect-eq
    !>  expected
    !>  (parse:parse(default-database default-db) query-string)
::
:: test coalesce with case scalar inline
++  test-coalesce-10
  ::
  =/  query-string
    "FROM foo ".
    "SCALARS foo CASE foo3 WHEN 1 THEN foo3 END ".
    "        bar COALESCE(foo,foo2,1,foo3) ".
    "SELECT foo2,foo3"
  ::
  =/  naked-case  :^  %case
                      (some unqualified-foo-3)
                      ~[[%case-when-then literal-1 unqualified-foo-3]]
                      ~
  =/  coalesce-1  :-  %coalesce
                      :~  [%scalar-name name=%foo]
                          unqualified-foo-2
                          literal-1
                          unqualified-foo-3
                          ==
  =/  scalars
    :~
      [%scalar 'foo' naked-case]
      [%scalar 'bar' coalesce-1]
    ==
  =/  expected  (mk-crud-txn scalars ~)
  %+  expect-eq
    !>  expected
    !>  (parse:parse(default-database default-db) query-string)
::
:: test coalesce with coalesce scalar inline
++  test-coalesce-11
  ::
  =/  query-string
    "FROM foo ".
    "SCALARS foo COALESCE(~zod,foo2,1,foo3) ".
    "        bar COALESCE(foo,foo2,1,foo3) ".
    "SELECT foo2,foo3"
  ::
  =/  naked-coalesce
    [%coalesce ~[literal-zod unqualified-foo-2 literal-1 unqualified-foo-3]]
  =/  coalesce-1  :-  %coalesce
                      :~  [%scalar-name name=%foo]
                          unqualified-foo-2
                          literal-1
                          unqualified-foo-3
                          ==
  =/  scalars
    :~
      [%scalar 'foo' naked-coalesce]
      [%scalar 'bar' coalesce-1]
    ==
  =/  expected  (mk-crud-txn scalars ~)
  %+  expect-eq
    !>  expected
    !>  (parse:parse(default-database default-db) query-string)
::
:: test coalesce with a coalesce nested in a coalesce
++  test-coalesce-12
  ::
  =/  query-string
    "FROM foo ".
    "SCALARS baz COALESCE(~zod,foo2,1,foo3) ".
    "        bar COALESCE(baz,foo2,1,foo3) ".
    "        foo COALESCE(bar,foo2,1,foo3) ".
    "SELECT foo2,foo3"
  ::
  =/  second-coalesce
    [%coalesce ~[literal-zod unqualified-foo-2 literal-1 unqualified-foo-3]]
  =/  first-coalesce  :-  %coalesce
                          :~  [%scalar-name name=%baz]
                              unqualified-foo-2
                              literal-1
                              unqualified-foo-3
                              ==
  =/  coalesce-1  :-  %coalesce
                      :~  [%scalar-name name=%bar]
                          unqualified-foo-2
                          literal-1
                          unqualified-foo-3
                          ==
  =/  scalars
    :~
      [%scalar 'baz' second-coalesce]
      [%scalar 'bar' first-coalesce]
      [%scalar 'foo' coalesce-1]
    ==
  =/  expected  (mk-crud-txn scalars ~)
  %+  expect-eq
    !>  expected
    !>  (parse:parse(default-database default-db) query-string)
::
:: coalesce with space between name and arguments
++  test-coalesce-13
  ::
  =/  query-string
    "FROM foo ".
    "SCALARS foo COALESCE (foo3,~zod,1,foo3) ".
    "SELECT foo2,foo3"
  ::
  =/  coalesce-1
    [%coalesce ~[unqualified-foo-3 literal-zod literal-1 unqualified-foo-3]]
  =/  scalars
    :~
      [%scalar 'foo' coalesce-1]
    ==
  =/  expected  (mk-crud-txn scalars ~)
  %+  expect-eq
    !>  expected
    !>  (parse:parse(default-database default-db) query-string)
::
:: coalesce with last element as scalar-name
++  test-coalesce-14
  ::
  =/  query-string
    "FROM foo ".
    "SCALARS foo COALESCE(~zod,1,foo3) ".
    "        bar COALESCE(foo2,1,foo) ".
    "SELECT foo2,foo3"
  ::
  =/  naked-coalesce
    [%coalesce ~[literal-zod literal-1 unqualified-foo-3]]
  =/  coalesce-1
    [%coalesce ~[unqualified-foo-2 literal-1 [%scalar-name name=%foo]]]
  =/  scalars
    :~
      [%scalar 'foo' naked-coalesce]
      [%scalar 'bar' coalesce-1]
    ==
  =/  expected  (mk-crud-txn scalars ~)
  %+  expect-eq
    !>  expected
    !>  (parse:parse(default-database default-db) query-string)
::
:: coalesce with cte-column elements
++  test-coalesce-15
  ::
  =/  query-string
    "WITH (FROM foo SELECT foo2,foo3) AS my-cte ".
    "FROM foo ".
    "SCALARS bar COALESCE(my-cte.foo2,foo2,my-cte.foo3) ".
    "SELECT foo2,foo3"
  ::
  =/  coalesce-1
    [%coalesce ~[my-cte-foo-2 unqualified-foo-2 my-cte-foo-3]]
  =/  scalars  ~[[%scalar 'bar' coalesce-1]]
  =/  expected  (mk-crud-txn-with-ctes ~[cte-my-cte] scalars ~)
  %+  expect-eq
    !>  expected
    !>  (parse:parse(default-database default-db) query-string)
::
:: coalesce with inline if scalar element
++  test-coalesce-16
  ::
  =/  query-string
    "FROM foo ".
    "SCALARS bar COALESCE(IF 1 = 1 THEN foo3 ELSE foo2 ENDIF,foo2,1) ".
    "SELECT foo2,foo3"
  ::
  =/  inline-if
    :*
      %if-then-else
      if=simple-true-pred
      then=[unqualified-foo-3]
      else=[unqualified-foo-2]
    ==
  =/  coalesce-1
    [%coalesce ~[inline-if unqualified-foo-2 literal-1]]
  =/  scalars  ~[[%scalar 'bar' coalesce-1]]
  =/  expected  (mk-crud-txn scalars ~)
  %+  expect-eq
    !>  expected
    !>  (parse:parse(default-database default-db) query-string)
::
::  fail on relation not defined
++  test-fail-coalesce-01
  ::
  =/  query-string
    "FROM foo ".
    "SCALARS foo COALESCE(MyTable.bar,~zod,1,foo3) ".
    "SELECT foo2,foo3"
  ::
  =/  coalesce-1
    [%coalesce ~[qualified-col-6 literal-zod literal-1 unqualified-foo-3]]
  %+  expect-fail-message
    'table alias \'MyTable\' is not defined'
    |.  (parse:parse(default-database default-db) query-string)
::
:: coalesce without parens - should fail
++  test-fail-coalesce-02
  ::
  =/  query-string
    "FROM foo ".
    "SCALARS foo COALESCE foo3,~zod,1,foo3 ".
    "SELECT foo2,foo3"
  ::
  %+  expect-fail-message
    'PARSER: '
    |.  (parse:parse(default-database default-db) query-string)
::
:: coalesce without parens - should fail
++  test-fail-coalesce-03
  ::
  =/  query-string
    "FROM foo ".
    "SCALARS foo COALESCE foo3,~zod,1,foo3 ".
    "SELECT foo2,foo3"
  ::
  %+  expect-fail-message
    'PARSER: '
    |.  (parse:parse(default-database default-db) query-string)
::
:: fail on coalesce with 1 param
++  test-fail-coalesce-04
  ::
  =/  query-string
    "FROM foo ".
    "SCALARS foo COALESCE(foo3) ".
    "SELECT foo2,foo3"
  ::
  %+  expect-fail-message
    'COALESCE requires at least 2 parameters'
    |.  (parse:parse(default-database default-db) query-string)
::
::  simple if
++  test-if-01
  ::
  =/  query-string
    "FROM foo ".
    "SCALARS foo IF 1 = 1 THEN foo3 ELSE foo2 ENDIF ".
    "SELECT foo2,foo3"
  ::
  =/  naked-if 
    :*
      %if-then-else
      if=simple-true-pred
      then=[unqualified-foo-3]
      else=[unqualified-foo-2]
    ==
  =/  scalars  ~[[%scalar 'foo' naked-if]]
  =/  expected  (mk-crud-txn scalars ~)
  %+  expect-eq
    !>  expected
    !>  (parse:parse(default-database default-db) query-string)
::
:: if with two scalars
++  test-if-02
  ::
  =/  query-string
    "FROM foo ".
    "SCALARS foo IF 1 = 1 THEN foo3 ELSE foo2 ENDIF ".
    "        baz IF 1 = 1 THEN foo3 ELSE foo2 ENDIF ".
    "SELECT foo2,foo3"
  ::
  =/  naked-if 
    :*
      %if-then-else
      if=simple-true-pred
      then=[unqualified-foo-3]
      else=[unqualified-foo-2]
    ==
  =/  scalars
    :~
      [%scalar 'foo' naked-if]
      [%scalar 'baz' naked-if]
    ==
  =/  expected  (mk-crud-txn scalars ~)
  %+  expect-eq
    !>  expected
    !>  (parse:parse(default-database default-db) query-string)
::
:: qualified column if scalar with ship.database.namespace.table.column
++  test-if-03
  ::
  =/  query-string
    "FROM foo ".
    "SCALARS foo ".
    "IF 1 = 1 ".
    " THEN ~sampel-palnet.db2.dba.table1.bar ".
    " ELSE ~sampel-palnet.db2.dba.table1.bar ".
    "ENDIF ".
    "SELECT foo2,foo3"
  ::
  =/  naked-if 
    :*  %if-then-else
      if=simple-true-pred 
      then=[qualified-col-1]
      else=[qualified-col-1]
    ==
  =/  scalars  ~[[%scalar 'foo' naked-if]]
  =/  expected  (mk-crud-txn scalars ~)
  %+  expect-eq
    !>  expected
    !>  (parse:parse(default-database default-db) query-string)
::
:: qualified column if scalar with ship.database..table.column (default ns)
++  test-if-04
  ::
  =/  query-string
    "FROM foo ".
    "SCALARS foo ".
    "IF 1 = 1 ".
    " THEN ~sampel-palnet.db2..table1.bar ".
    " ELSE ~sampel-palnet.db2..table1.bar ".
    "ENDIF ".
    "SELECT foo2,foo3"
  ::
  =/  naked-if 
    :*  %if-then-else
      if=simple-true-pred 
      then=[qualified-col-2]
      else=[qualified-col-2]
    ==
  =/  scalars  ~[[%scalar 'foo' naked-if]]
  =/  expected  (mk-crud-txn scalars ~)
  %+  expect-eq
    !>  expected
    !>  (parse:parse(default-database default-db) query-string)
::
:: qualified column if scalar with database.namespace.table.column
++  test-if-05
  ::
  =/  query-string
    "FROM foo ".
    "SCALARS foo ".
    "IF 1 = 1 ".
    " THEN db2.dba.table1.bar ".
    " ELSE db2.dba.table1.bar ".
    "ENDIF ".
    "SELECT foo2,foo3"
  ::
  =/  naked-if 
    :*  %if-then-else
      if=simple-true-pred 
      then=[qualified-col-3]
      else=[qualified-col-3]
    ==
  =/  scalars  ~[[%scalar 'foo' naked-if]]
  =/  expected  (mk-crud-txn scalars ~)
  %+  expect-eq
    !>  expected
    !>  (parse:parse(default-database default-db) query-string)
::
:: qualified column if scalar with database..table.column (default namespace)
++  test-if-06
  ::
  =/  query-string
    "FROM foo ".
    "SCALARS foo ".
    "IF 1 = 1 ".
    " THEN db2..table1.bar ".
    " ELSE db2..table1.bar ".
    "ENDIF ".
    "SELECT foo2,foo3"
  ::
  =/  naked-if 
    :*  %if-then-else
      if=simple-true-pred 
      then=[qualified-col-4]
      else=[qualified-col-4]
    ==
  =/  scalars  ~[[%scalar 'foo' naked-if]]
  =/  expected  (mk-crud-txn scalars ~)
  %+  expect-eq
    !>  expected
    !>  (parse:parse(default-database default-db) query-string)
::
:: qualified column if scalar with namespace.table.column (default database)
++  test-if-07
  ::
  =/  query-string
    "FROM foo ".
    "SCALARS foo ".
    "IF 1 = 1 ".
    " THEN dba.table1.bar ".
    " ELSE dba.table1.bar ".
    "ENDIF ".
    "SELECT foo2,foo3"
  ::
  =/  naked-if 
    :*  %if-then-else
      if=simple-true-pred 
      then=[qualified-col-5]
      else=[qualified-col-5]
    ==
  =/  scalars  ~[[%scalar 'foo' naked-if]]
  =/  expected  (mk-crud-txn scalars ~)
  %+  expect-eq
    !>  expected
    !>  (parse:parse(default-database default-db) query-string)
::
:: qualified column if scalar with alias.column (default database)
++  test-if-08
  ::
  =/  query-string
    "FROM ~sampel-palnet.db2.dba.table1 AS MyTable ".
    "SCALARS foo ".
    "IF 1 = 1 ".
    " THEN MyTable.bar ".
    " ELSE MyTable.bar ".
    "ENDIF ".
    "SELECT foo2,foo3"
  ::
  =/  table
    :*  %qualified-table
      ship=[~ ~sampel-palnet]
      database=%db2
      namespace=%dba
      name=%table1
      alias=[~ 'MyTable']
    ==
  =/  naked-if 
    :*  %if-then-else
      if=simple-true-pred 
      then=[qualified-col-6]
      else=[qualified-col-6]
    ==
  =/  scalars  ~[[%scalar 'foo' naked-if]]
  =/  expected  (mk-crud-txn scalars (some table))
  %+  expect-eq
    !>  expected
    !>  (parse:parse(default-database default-db) query-string)
::
:: qualified column if scalar with alias.column (should fail - undefined alias)
++  test-if-09
  ::
  =/  query-string
    "FROM foo ".
    "SCALARS foo COALESCE(foo2,1,foo2) ".
    "        bar IF 1 = 1 THEN foo ELSE foo2 ENDIF ".
    "SELECT foo2,foo3"
  ::
  =/  naked-coalesce
    [%coalesce ~[unqualified-foo-2 literal-1 unqualified-foo-2]]
  =/  if-1
    :*
      %if-then-else
      if=simple-true-pred
      then=[%scalar-name name=%foo]
      else=[unqualified-foo-2]
    ==
  =/  scalars
    :~
      [%scalar 'foo' naked-coalesce]
      [%scalar 'bar' if-1]
    ==
  =/  expected  (mk-crud-txn scalars ~)
  %+  expect-eq
    !>  expected
    !>  (parse:parse(default-database default-db) query-string)
::
:: test if with case scalar inline
++  test-if-10
  ::
  =/  query-string
    "FROM foo ".
    "SCALARS foo CASE foo3 WHEN 1 THEN foo3 END ".
    "        bar IF 1 = 1 THEN foo ELSE foo2 ENDIF ".
    "SELECT foo2,foo3"
  ::
  =/  naked-case
    :*  %case
      (some unqualified-foo-3)
      ~[[%case-when-then literal-1 unqualified-foo-3]]
      ~
    ==
  =/  if-1
    :*
      %if-then-else
      if=simple-true-pred
      then=[%scalar-name name=%foo]
      else=[unqualified-foo-2]
    ==
  =/  scalars
    :~
      [%scalar 'foo' naked-case]
      [%scalar 'bar' if-1]
    ==
  =/  expected  (mk-crud-txn scalars ~)
  %+  expect-eq
    !>  expected
    !>  (parse:parse(default-database default-db) query-string)
::
:: test if with if scalar inline
++  test-if-11
  ::
  =/  query-string
    "FROM foo ".
    "SCALARS foo IF 1 = 1 THEN foo3 ELSE foo2 ENDIF ".
    "        bar IF 1 = 1 THEN foo ELSE foo2 ENDIF ".
    "SELECT foo2,foo3"
  ::
  =/  naked-if
    :*
      %if-then-else
      if=simple-true-pred
      then=[unqualified-foo-3]
      else=[unqualified-foo-2]
    ==
  =/  if-1
    :*
      %if-then-else
      if=simple-true-pred
      then=[%scalar-name name=%foo]
      else=[unqualified-foo-2]
    ==
  =/  scalars
    :~
      [%scalar 'foo' naked-if]
      [%scalar 'bar' if-1]
    ==
  =/  expected  (mk-crud-txn scalars ~)
  %+  expect-eq
    !>  expected
    !>  (parse:parse(default-database default-db) query-string)
::
:: test if with a if nested in a if
++  test-if-12
  ::
  =/  query-string
    "FROM foo ".
    "SCALARS baz IF 1 = 1 THEN foo3 ELSE foo2 ENDIF ".
    "        bar IF 1 = 1 THEN baz ELSE foo2 ENDIF ".
    "        foo IF 1 = 1 THEN bar ELSE foo2 ENDIF ".
    "SELECT foo2,foo3"
  ::
  =/  second-if
    :*
      %if-then-else
      if=simple-true-pred
      then=[unqualified-foo-3]
      else=[unqualified-foo-2]
    ==
  =/  first-if
    :*
      %if-then-else
      if=simple-true-pred
      then=[%scalar-name name=%baz]
      else=[unqualified-foo-2]
    ==
  =/  if-1
    :*
      %if-then-else
      if=simple-true-pred
      then=[%scalar-name name=%bar]
      else=[unqualified-foo-2]
    ==
  =/  scalars
    :~
      [%scalar 'baz' second-if]
      [%scalar 'bar' first-if]
      [%scalar 'foo' if-1]
    ==
  =/  expected  (mk-crud-txn scalars ~)
  %+  expect-eq
    !>  expected
    !>  (parse:parse(default-database default-db) query-string)
::
:: test if with scalar-name as else element
++  test-if-13
  ::
  =/  query-string
    "FROM foo ".
    "SCALARS foo IF 1 = 1 THEN foo3 ELSE foo2 ENDIF ".
    "        bar IF 1 = 1 THEN foo3 ELSE foo ENDIF ".
    "SELECT foo2,foo3"
  ::
  =/  naked-if
    :*
      %if-then-else
      if=simple-true-pred
      then=[unqualified-foo-3]
      else=[unqualified-foo-2]
    ==
  =/  if-1
    :*
      %if-then-else
      if=simple-true-pred
      then=[unqualified-foo-3]
      else=[%scalar-name name=%foo]
    ==
  =/  scalars
    :~
      [%scalar 'foo' naked-if]
      [%scalar 'bar' if-1]
    ==
  =/  expected  (mk-crud-txn scalars ~)
  %+  expect-eq
    !>  expected
    !>  (parse:parse(default-database default-db) query-string)
::
:: test if with cte-column branches
++  test-if-14
  ::
  =/  query-string
    "WITH (FROM foo SELECT foo2,foo3) AS my-cte ".
    "FROM foo ".
    "SCALARS bar IF 1 = 1 THEN my-cte.foo2 ELSE my-cte.foo3 ENDIF ".
    "SELECT foo2,foo3"
  ::
  =/  if-1
    :*
      %if-then-else
      if=simple-true-pred
      then=my-cte-foo-2
      else=my-cte-foo-3
    ==
  =/  scalars  ~[[%scalar 'bar' if-1]]
  =/  expected  (mk-crud-txn-with-ctes ~[cte-my-cte] scalars ~)
  %+  expect-eq
    !>  expected
    !>  (parse:parse(default-database default-db) query-string)
::
:: test if with inline scalar-node branches
++  test-if-15
  ::
  =/  query-string
    "FROM foo ".
    "SCALARS bar IF 1 = 1 ".
    "        THEN COALESCE(foo2,1,foo3) ".
    "        ELSE CASE foo3 WHEN 1 THEN foo2 END ".
    "        ENDIF ".
    "SELECT foo2,foo3"
  ::
  =/  inline-coalesce
    [%coalesce ~[unqualified-foo-2 literal-1 unqualified-foo-3]]
  =/  inline-case
    :*
      %case
      target=(some unqualified-foo-3)
      cases=~[[%case-when-then literal-1 unqualified-foo-2]]
      else=~
    ==
  =/  if-1
    :*
      %if-then-else
      if=simple-true-pred
      then=inline-coalesce
      else=inline-case
    ==
  =/  scalars  ~[[%scalar 'bar' if-1]]
  =/  expected  (mk-crud-txn scalars ~)
  %+  expect-eq
    !>  expected
    !>  (parse:parse(default-database default-db) query-string)
::
++  test-fail-if-01
  ::
  =/  query-string
    "FROM foo ".
    "SCALARS foo ".
    "        IF 1 = 1 THEN MyTable.bar ELSE MyTable.bar ENDIF ".
    "SELECT foo2,foo3"
  ::
  %+  expect-fail-message
    'table alias \'MyTable\' is not defined'
    |.  (parse:parse(default-database default-db) query-string)
::
:: simple case expression with expression
++  test-case-simple-01
  ::
  =/  query-string
    "FROM foo ".
    "SCALARS foobar CASE foo3 WHEN 1 THEN foo3 ELSE foo3 END ".
    "SELECT foo2,foo3"
  ::
  =/  case
    :*  %case
      (some unqualified-foo-3)
      ~[[%case-when-then literal-1 unqualified-foo-3]]
      (some unqualified-foo-3)
    ==
  =/  scalars  ~[[%scalar 'foobar' case]]
  =/  expected  (mk-crud-txn scalars ~)
  %+  expect-eq
    !>  expected
    !>  (parse:parse(default-database default-db) query-string)
::
:: simple case expression with arithmetic else
++  test-case-simple-arithmetic-01
  ::
  =/  query-string
    "FROM foo ".
    "SCALARS foobar CASE foo3 WHEN 1 THEN foo3 ELSE foo2 + 1 END ".
    "SELECT foo2,foo3"
  ::
  =/  else-expr
    [%arithmetic operator=%lus left=unqualified-foo-2 right=literal-1]
  =/  case
    :*  %case
      (some unqualified-foo-3)
      ~[[%case-when-then literal-1 unqualified-foo-3]]
      (some else-expr)
    ==
  =/  scalars  ~[[%scalar 'foobar' case]]
  =/  expected  (mk-crud-txn scalars ~)
  %+  expect-eq
    !>  expected
    !>  (parse:parse(default-database default-db) query-string)
::
:: simple case expression with expression, no else
++  test-case-simple-02
  ::
  =/  query-string
    "FROM foo ".
    "SCALARS foobaz CASE foo3 WHEN 1 THEN foo3 END ".
    "SELECT foo2,foo3"
  ::
  =/  case-when-then  [%case-when-then literal-1 unqualified-foo-3] 
  =/  case
    :+  %scalar
        'foobaz'
        [%case (some unqualified-foo-3) ~[case-when-then] ~]
  =/  scalars  ~[case]
  =/  expected  (mk-crud-txn scalars ~)
  %+  expect-eq
    !>  expected
    !>  (parse:parse(default-database default-db) query-string)

:: simple case expression with expression, two cases, one with else
:: the other without
++  test-case-simple-03
  ::
  =/  query-string
    "FROM foo ".
    "SCALARS foobaz CASE foo3 WHEN 1 THEN foo3 END ".
    "        foobar CASE foo3 WHEN ~zod THEN foo3 ELSE foo2 END ".
    "SELECT foo2,foo3"
  ::
  =/  case-1
    :*  %case
      (some unqualified-foo-3)
      ~[[%case-when-then literal-1 unqualified-foo-3]]
      ~
    ==
  =/  case-2
    :*  %case
      (some unqualified-foo-3)
      ~[[%case-when-then literal-zod unqualified-foo-3]]
      (some unqualified-foo-2)
    ==
  =/  scalars  ~[[%scalar 'foobaz' case-1] [%scalar 'foobar' case-2]]
  =/  expected  (mk-crud-txn scalars ~)
  %+  expect-eq
    !>  expected
    !>  (parse:parse(default-database default-db) query-string)
::
:: simple case expression with expression, two cases in the same scalar
++  test-case-simple-04
  ::
  =/  query-string
    "FROM foo ".
    "SCALARS foobaz CASE foo3 ".
    "                 WHEN 1 THEN foo3".
    "                 WHEN 1 THEN foo3".
    "                END ".
    "        foobar CASE foo3 ".
    "                 WHEN 1 THEN foo3".
    "                 WHEN 1 THEN foo3".
    "               ELSE foo2 END ".
    "SELECT foo2,foo3"
  ::
  =/  case-1
    :*  %case
      (some unqualified-foo-3)
      :~  [%case-when-then literal-1 unqualified-foo-3]
          [%case-when-then literal-1 unqualified-foo-3]
      ==
      ~
    ==
  =/  case-2
    :*  %case
      (some unqualified-foo-3)
      :~  [%case-when-then literal-1 unqualified-foo-3]
          [%case-when-then literal-1 unqualified-foo-3]
      ==
      (some unqualified-foo-2)
    ==
  =/  scalars  ~[[%scalar 'foobaz' case-1] [%scalar 'foobar' case-2]]
  =/  expected  (mk-crud-txn scalars ~)
  %+  expect-eq
    !>  expected
    !>  (parse:parse(default-database default-db) query-string)
::
:: simple case expression: qualified column case scalar with
:: ship.database.namespace.table.column
++  test-case-simple-05
  ::
  =/  query-string
    "FROM foo ".
    "SCALARS foo ".
    "CASE ~sampel-palnet.db2.dba.table1.bar ".
    "WHEN ~sampel-palnet.db2.dba.table1.bar ".
    "THEN ~sampel-palnet.db2.dba.table1.bar ".
    "ELSE ~sampel-palnet.db2.dba.table1.bar ".
    "END ".
    "SELECT foo2,foo3"
  ::
  =/  case-qualified
    :*  %case
      (some qualified-col-1)
      ~[[%case-when-then qualified-col-1 qualified-col-1]]
      (some qualified-col-1)
    ==
  =/  scalars  ~[[%scalar 'foo' case-qualified]]
  =/  expected  (mk-crud-txn scalars ~)
  %+  expect-eq
    !>  expected
    !>  (parse:parse(default-database default-db) query-string)
::
:: simple case expression: qualified column case scalar with
:: ship.database..table.column (default ns)
++  test-case-simple-06
  ::
  =/  query-string
    "FROM foo ".
    "SCALARS foo ".
    "CASE ~sampel-palnet.db2..table1.bar ".
    "WHEN ~sampel-palnet.db2..table1.bar ".
    "THEN ~sampel-palnet.db2..table1.bar ".
    "ELSE ~sampel-palnet.db2..table1.bar ".
    "END ".
    "SELECT foo2,foo3"
  ::
  =/  case-qualified
    :*  %case
      (some qualified-col-2)
      ~[[%case-when-then qualified-col-2 qualified-col-2]]
      (some qualified-col-2)
    ==
  =/  scalars  ~[[%scalar 'foo' case-qualified]]
  =/  expected  (mk-crud-txn scalars ~)
  %+  expect-eq
    !>  expected
    !>  (parse:parse(default-database default-db) query-string)
::
:: simple case expression: qualified column case scalar with
:: database.namespace.table.column
++  test-case-simple-07
  ::
  =/  query-string
    "FROM foo ".
    "SCALARS foo ".
    "CASE db2.dba.table1.bar ".
    "WHEN db2.dba.table1.bar ".
    "THEN db2.dba.table1.bar ".
    "ELSE db2.dba.table1.bar ".
    "END ".
    "SELECT foo2,foo3"
  ::
  =/  case-qualified
    :*  %case
      (some qualified-col-3)
      ~[[%case-when-then qualified-col-3 qualified-col-3]]
      (some qualified-col-3)
    ==
  =/  scalars  ~[[%scalar 'foo' case-qualified]]
  =/  expected  (mk-crud-txn scalars ~)
  %+  expect-eq
    !>  expected
    !>  (parse:parse(default-database default-db) query-string)
::
:: simple case expression: qualified column case scalar with
:: database..table.column (default ns)
++  test-case-simple-08
  ::
  =/  query-string
    "FROM foo ".
    "SCALARS foo ".
    "CASE db2..table1.bar ".
    "WHEN db2..table1.bar ".
    "THEN db2..table1.bar ".
    "ELSE db2..table1.bar ".
    "END ".
    "SELECT foo2,foo3"
  ::
  =/  case-qualified
    :*  %case
      (some qualified-col-4)
      ~[[%case-when-then qualified-col-4 qualified-col-4]]
      (some qualified-col-4)
    ==
  =/  scalars  ~[[%scalar 'foo' case-qualified]]
  =/  expected  (mk-crud-txn scalars ~)
  %+  expect-eq
    !>  expected
    !>  (parse:parse(default-database default-db) query-string)
::
:: simple case expression: qualified column case scalar with
:: namespace.table.column (default database)
++  test-case-simple-09
  ::
  =/  query-string
    "FROM foo ".
    "SCALARS foo ".
    "CASE dba.table1.bar ".
    "WHEN dba.table1.bar ".
    "THEN dba.table1.bar ".
    "ELSE dba.table1.bar ".
    "END ".
    "SELECT foo2,foo3"
  ::
  =/  case-qualified
    :*  %case
      (some qualified-col-5)
      ~[[%case-when-then qualified-col-5 qualified-col-5]]
      (some qualified-col-5)
    ==
  =/  scalars  ~[[%scalar 'foo' case-qualified]]
  =/  expected  (mk-crud-txn scalars ~)
  %+  expect-eq
    !>  expected
    !>  (parse:parse(default-database default-db) query-string)
::
:: simple case expression: qualified column case scalar with
:: alias.column (default database)
++  test-case-simple-10
  ::
  =/  query-string
    "FROM ~sampel-palnet.db2.dba.table1 AS MyTable ".
    "SCALARS foo ".
    "CASE MyTable.bar ".
    "WHEN MyTable.bar ".
    "THEN MyTable.bar ".
    "ELSE MyTable.bar ".
    "END ".
    "SELECT foo2,foo3"
  ::
  =/  table
    :*  %qualified-table
      ship=[~ ~sampel-palnet]
      database=%db2
      namespace=%dba
      name=%table1
      alias=[~ 'MyTable']
    ==
  =/  case-qualified
    :*  %case
      (some qualified-col-6)
      ~[[%case-when-then qualified-col-6 qualified-col-6]]
      (some qualified-col-6)
    ==
  =/  scalars  ~[[%scalar 'foo' case-qualified]]
  =/  expected  (mk-crud-txn scalars (some table))
  %+  expect-eq
    !>  expected
    !>  (parse:parse(default-database default-db) query-string)
::
:: simple case expression: test case with coalesce scalar inline
++  test-case-simple-11
  ::
  =/  query-string
    "FROM foo ".
    "SCALARS foo COALESCE(foo2,1,foo2) ".
    "        bar CASE foo3 WHEN 1 THEN foo ELSE foo2 END ".
    "SELECT foo2,foo3"
  ::
  =/  naked-coalesce
    [%coalesce ~[unqualified-foo-2 literal-1 unqualified-foo-2]]
  =/  case-1
    :*
      %case
      target=(some unqualified-foo-3)
      cases=~[[%case-when-then literal-1 [%scalar-name name=%foo]]]
      else=(some unqualified-foo-2)
    ==
  =/  scalars
    :~
      [%scalar 'foo' naked-coalesce]
      [%scalar 'bar' case-1]
    ==
  =/  expected  (mk-crud-txn scalars ~)
  %+  expect-eq
    !>  expected
    !>  (parse:parse(default-database default-db) query-string)
::
:: simple case expression: test case with if scalar inline
++  test-case-simple-12
  ::
  =/  query-string
    "FROM foo ".
    "SCALARS foo IF 1 = 1 THEN foo3 ELSE foo2 ENDIF ".
    "        bar CASE foo3 WHEN 1 THEN foo ELSE foo2 END ".
    "SELECT foo2,foo3"
  ::
  =/  naked-if
    :*
      %if-then-else
      if=simple-true-pred
      then=[unqualified-foo-3]
      else=[unqualified-foo-2]
    ==
  =/  case-1
    :*
      %case
      target=(some unqualified-foo-3)
      cases=~[[%case-when-then literal-1 [%scalar-name name=%foo]]]
      else=(some unqualified-foo-2)
    ==
  =/  scalars
    :~
      [%scalar 'foo' naked-if]
      [%scalar 'bar' case-1]
    ==
  =/  expected  (mk-crud-txn scalars ~)
  %+  expect-eq
    !>  expected
    !>  (parse:parse(default-database default-db) query-string)
::
:: simple case expression: test case with case scalar inline
++  test-case-simple-13
  ::
  =/  query-string
    "FROM foo ".
    "SCALARS foo CASE foo3 WHEN 1 THEN foo3 END ".
    "        bar CASE foo3 WHEN 1 THEN foo ELSE foo2 END ".
    "SELECT foo2,foo3"
  ::
  =/  naked-case
    :*
      %case
      target=(some unqualified-foo-3)
      cases=~[[%case-when-then literal-1 unqualified-foo-3]]
      else=~
    ==
  =/  case-1
    :*
      %case
      target=(some unqualified-foo-3)
      cases=~[[%case-when-then literal-1 [%scalar-name name=%foo]]]
      else=(some unqualified-foo-2)
    ==
  =/  scalars
    :~
      [%scalar 'foo' naked-case]
      [%scalar 'bar' case-1]
    ==
  =/  expected  (mk-crud-txn scalars ~)
  %+  expect-eq
    !>  expected
    !>  (parse:parse(default-database default-db) query-string)
::
:: simple case expression: test case with a case nested in a case
++  test-case-simple-14
  ::
  =/  query-string
    "FROM foo ".
    "SCALARS baz CASE foo3 WHEN 1 THEN foo3 END ".
    "        bar CASE foo3 WHEN 1 THEN baz END ".
    "        foo CASE foo3 WHEN 1 THEN bar ELSE foo2 END ".
    "SELECT foo2,foo3"
  ::
  =/  second-case
    :*
      %case
      target=(some unqualified-foo-3)
      cases=~[[%case-when-then literal-1 unqualified-foo-3]]
      else=~
    ==
  =/  first-case
    :*
      %case
      target=(some unqualified-foo-3)
      cases=~[[%case-when-then literal-1 [%scalar-name name=%baz]]]
      else=~
    ==
  =/  case-1
    :*
      %case
      target=(some unqualified-foo-3)
      cases=~[[%case-when-then literal-1 [%scalar-name name=%bar]]]
      else=(some unqualified-foo-2)
    ==
  =/  scalars
    :~
      [%scalar 'baz' second-case]
      [%scalar 'bar' first-case]
      [%scalar 'foo' case-1]
    ==
  =/  expected  (mk-crud-txn scalars ~)
  %+  expect-eq
    !>  expected
    !>  (parse:parse(default-database default-db) query-string)
::
:: simple case expression: test case with scalar-name as else element
++  test-case-simple-15
  ::
  =/  query-string
    "FROM foo ".
    "SCALARS foo CASE foo3 WHEN 1 THEN foo3 END ".
    "        bar CASE foo3 WHEN 1 THEN foo3 ELSE foo END ".
    "SELECT foo2,foo3"
  ::
  =/  naked-case
    :*
      %case
      target=(some unqualified-foo-3)
      cases=~[[%case-when-then literal-1 unqualified-foo-3]]
      else=~
    ==
  =/  case-1
    :*
      %case
      target=(some unqualified-foo-3)
      cases=~[[%case-when-then literal-1 unqualified-foo-3]]
      else=(some [%scalar-name name=%foo])
    ==
  =/  scalars
    :~
      [%scalar 'foo' naked-case]
      [%scalar 'bar' case-1]
    ==
  =/  expected  (mk-crud-txn scalars ~)
  %+  expect-eq
    !>  expected
    !>  (parse:parse(default-database default-db) query-string)
::
:: simple case expression: test case with scalar-name as target element
++  test-case-simple-16
  ::
  =/  query-string
    "FROM foo ".
    "SCALARS foo COALESCE(foo2,1,foo3) ".
    "        bar CASE foo WHEN 1 THEN foo3 ELSE foo2 END ".
    "SELECT foo2,foo3"
  ::
  =/  naked-coalesce
    [%coalesce ~[unqualified-foo-2 literal-1 unqualified-foo-3]]
  =/  case-1
    :*
      %case
      target=(some [%scalar-name name=%foo])
      cases=~[[%case-when-then literal-1 unqualified-foo-3]]
      else=(some unqualified-foo-2)
    ==
  =/  scalars
    :~
      [%scalar 'foo' naked-coalesce]
      [%scalar 'bar' case-1]
    ==
  =/  expected  (mk-crud-txn scalars ~)
  %+  expect-eq
    !>  expected
    !>  (parse:parse(default-database default-db) query-string)
::
:: simple case expression: inline IF as target element
++  test-case-simple-17
  ::
  =/  query-string
    "FROM foo ".
    "SCALARS bar CASE IF 1 = 1 THEN foo3 ELSE foo2 ENDIF ".
    "            WHEN foo3 THEN foo2 ".
    "            ELSE foo3 END ".
    "SELECT foo2,foo3"
  ::
  =/  target-if
    :*
      %if-then-else
      if=simple-true-pred
      then=[unqualified-foo-3]
      else=[unqualified-foo-2]
    ==
  =/  case-1
    :*
      %case
      target=(some target-if)
      cases=~[[%case-when-then unqualified-foo-3 unqualified-foo-2]]
      else=(some unqualified-foo-3)
    ==
  =/  scalars  ~[[%scalar 'bar' case-1]]
  =/  expected  (mk-crud-txn scalars ~)
  %+  expect-eq
    !>  expected
    !>  (parse:parse(default-database default-db) query-string)
::
:: simple case expression: cte-column as target and else element
++  test-case-simple-18
  ::
  =/  query-string
    "WITH (FROM foo SELECT foo2,foo3) AS my-cte ".
    "FROM foo ".
    "SCALARS bar CASE my-cte.foo2 WHEN foo2 THEN foo3 ELSE my-cte.foo3 END ".
    "SELECT foo2,foo3"
  ::
  =/  case-1
    :*
      %case
      target=(some my-cte-foo-2)
      cases=~[[%case-when-then unqualified-foo-2 unqualified-foo-3]]
      else=(some my-cte-foo-3)
    ==
  =/  scalars  ~[[%scalar 'bar' case-1]]
  =/  expected  (mk-crud-txn-with-ctes ~[cte-my-cte] scalars ~)
  %+  expect-eq
    !>  expected
    !>  (parse:parse(default-database default-db) query-string)
::
:: simple case expression: scalar-name in when position
++  test-case-simple-19
  ::
  =/  query-string
    "FROM foo ".
    "SCALARS foo COALESCE(foo2,1,foo3) ".
    "        bar CASE foo3 WHEN foo THEN foo2 ELSE foo3 END ".
    "SELECT foo2,foo3"
  ::
  =/  naked-coalesce
    [%coalesce ~[unqualified-foo-2 literal-1 unqualified-foo-3]]
  =/  case-1
    :*
      %case
      target=(some unqualified-foo-3)
      cases=~[[%case-when-then [%scalar-name name=%foo] unqualified-foo-2]]
      else=(some unqualified-foo-3)
    ==
  =/  scalars
    :~
      [%scalar 'foo' naked-coalesce]
      [%scalar 'bar' case-1]
    ==
  =/  expected  (mk-crud-txn scalars ~)
  %+  expect-eq
    !>  expected
    !>  (parse:parse(default-database default-db) query-string)
::
:: simple case expression: inline scalar-node then and else elements
++  test-case-simple-20
  ::
  =/  query-string
    "FROM foo ".
    "SCALARS bar CASE foo3 ".
    "            WHEN 1 THEN IF 1 = 1 THEN foo2 ELSE foo3 ENDIF ".
    "            ELSE COALESCE(foo2,1,foo3) END ".
    "SELECT foo2,foo3"
  ::
  =/  inline-if
    :*
      %if-then-else
      if=simple-true-pred
      then=[unqualified-foo-2]
      else=[unqualified-foo-3]
    ==
  =/  inline-coalesce
    [%coalesce ~[unqualified-foo-2 literal-1 unqualified-foo-3]]
  =/  case-1
    :*
      %case
      target=(some unqualified-foo-3)
      cases=~[[%case-when-then literal-1 inline-if]]
      else=(some inline-coalesce)
    ==
  =/  scalars  ~[[%scalar 'bar' case-1]]
  =/  expected  (mk-crud-txn scalars ~)
  %+  expect-eq
    !>  expected
    !>  (parse:parse(default-database default-db) query-string)
::
:: searched case expression with predicate
++  test-case-searched-01
  ::
  =/  query-string
    "FROM foo ".
    "SCALARS foobar CASE WHEN 1 = 1 THEN foo3 ELSE foo3 END ".
    "SELECT foo2,foo3"
  ::
  =/  case
    :*  %case
      ~
      ~[[%case-when-then simple-true-pred unqualified-foo-3]]
      (some unqualified-foo-3)
    ==
  =/  scalars  ~[[%scalar 'foobar' case]]
  =/  expected  (mk-crud-txn scalars ~)
  %+  expect-eq
    !>  expected
    !>  (parse:parse(default-database default-db) query-string)
::
:: searched case expression with arithmetic else
++  test-case-searched-arithmetic-01
  ::
  =/  query-string
    "FROM foo ".
    "SCALARS foobar CASE WHEN 1 = 1 THEN foo3 ELSE foo2 + 1 END ".
    "SELECT foo2,foo3"
  ::
  =/  else-expr
    [%arithmetic operator=%lus left=unqualified-foo-2 right=literal-1]
  =/  case
    :*  %case
      ~
      ~[[%case-when-then simple-true-pred unqualified-foo-3]]
      (some else-expr)
    ==
  =/  scalars  ~[[%scalar 'foobar' case]]
  =/  expected  (mk-crud-txn scalars ~)
  %+  expect-eq
    !>  expected
    !>  (parse:parse(default-database default-db) query-string)
::
:: searched case expression with predicate, no else
++  test-case-searched-02
  ::
  =/  query-string
    "FROM foo ".
    "SCALARS foobaz CASE WHEN 1 = 1 THEN foo3 END ".
    "SELECT foo2,foo3"
  ::
  =/  case-when-then  [%case-when-then simple-true-pred unqualified-foo-3] 
  =/  case
    :+  %scalar
        'foobaz'
        [%case ~ ~[case-when-then] ~]
    
  =/  scalars  ~[case]
  =/  expected  (mk-crud-txn scalars ~)
  %+  expect-eq
    !>  expected
    !>  (parse:parse(default-database default-db) query-string)
::
:: searched case expression with predicate, two cases, one with else
:: the other without
++  test-case-searched-03
  ::
  =/  query-string
    "FROM foo ".
    "SCALARS foobaz CASE WHEN 1 = 1 THEN foo3 END ".
    "        foobar CASE WHEN 1 = 1 THEN foo3 ELSE foo2 END ".
    "SELECT foo2,foo3"
  ::
  =/  case-1
    :*  %case
      ~
      ~[[%case-when-then simple-true-pred unqualified-foo-3]]
      ~
    ==
  =/  case-2
    :*  %case
      ~
      ~[[%case-when-then simple-true-pred unqualified-foo-3]]
      (some unqualified-foo-2)
    ==
  =/  scalars  ~[[%scalar 'foobaz' case-1] [%scalar 'foobar' case-2]]
  =/  expected  (mk-crud-txn scalars ~)
  %+  expect-eq
    !>  expected
    !>  (parse:parse(default-database default-db) query-string)
::
:: searched case expression with predicate, two cases in the same scalar
++  test-case-searched-04
  ::
  =/  query-string
    "FROM foo ".
    "SCALARS foobaz CASE ".
    "                 WHEN 1 = 1 THEN foo3".
    "                 WHEN 1 = 1 THEN foo3".
    "                END ".
    "        foobar CASE ".
    "                 WHEN 1 = 1 THEN foo3".
    "                 WHEN 1 = 1 THEN foo3".
    "               ELSE foo2 END ".
    "SELECT foo2,foo3"
  ::
  =/  case-1
    :*  %case
      ~
      :~  [%case-when-then simple-true-pred unqualified-foo-3]
          [%case-when-then simple-true-pred unqualified-foo-3]
      ==
      ~
    ==
  =/  case-2
    :*  %case
      ~
      :~  [%case-when-then simple-true-pred unqualified-foo-3]
          [%case-when-then simple-true-pred unqualified-foo-3]
      ==
      (some unqualified-foo-2)
    ==
  =/  scalars  ~[[%scalar 'foobaz' case-1] [%scalar 'foobar' case-2]]
  =/  expected  (mk-crud-txn scalars ~)
  %+  expect-eq
    !>  expected
    !>  (parse:parse(default-database default-db) query-string)
::
:: qualified column case scalar with ship.database.namespace.table.column
++  test-case-searched-05
  ::
  =/  query-string
    "FROM foo ".
    "SCALARS foo ".
    "CASE ".
    "WHEN 1 = 1 ".
    "THEN ~sampel-palnet.db2.dba.table1.bar ".
    "ELSE ~sampel-palnet.db2.dba.table1.bar ".
    "END ".
    "SELECT foo2,foo3"
  ::
  =/  case-qualified
    :*  %case
      ~
      ~[[%case-when-then simple-true-pred qualified-col-1]]
      (some qualified-col-1)
    ==
  =/  scalars  ~[[%scalar 'foo' case-qualified]]
  =/  expected  (mk-crud-txn scalars ~)
  %+  expect-eq
    !>  expected
    !>  (parse:parse(default-database default-db) query-string)
::
:: searched case expression: qualified column case scalar
:: with ship.database..table.column (default ns)
++  test-case-searched-06
  ::
  =/  query-string
    "FROM foo ".
    "SCALARS foo ".
    "CASE ".
    "WHEN 1 = 1 ".
    "THEN ~sampel-palnet.db2..table1.bar ".
    "ELSE ~sampel-palnet.db2..table1.bar ".
    "END ".
    "SELECT foo2,foo3"
  ::
  =/  case-qualified
    :*  %case
      ~
      ~[[%case-when-then simple-true-pred qualified-col-2]]
      (some qualified-col-2)
    ==
  =/  scalars  ~[[%scalar 'foo' case-qualified]]
  =/  expected  (mk-crud-txn scalars ~)
  %+  expect-eq
    !>  expected
    !>  (parse:parse(default-database default-db) query-string)
::
:: searched case expression: qualified column case scalar
:: with database.namespace.table.column
++  test-case-searched-07
  ::
  =/  query-string
    "FROM foo ".
    "SCALARS foo ".
    "CASE ".
    "WHEN 1 = 1 ".
    "THEN db2.dba.table1.bar ".
    "ELSE db2.dba.table1.bar ".
    "END ".
    "SELECT foo2,foo3"
  ::
  =/  case-qualified
    :*  %case
      ~
      ~[[%case-when-then simple-true-pred qualified-col-3]]
      (some qualified-col-3)
    ==
  =/  scalars  ~[[%scalar 'foo' case-qualified]]
  =/  expected  (mk-crud-txn scalars ~)
  %+  expect-eq
    !>  expected
    !>  (parse:parse(default-database default-db) query-string)
::
:: searched case expression: qualified column case scalar with
:: database..table.column (default ns)
++  test-case-searched-08
  ::
  =/  query-string
    "FROM foo ".
    "SCALARS foo ".
    "CASE ".
    "WHEN 1 = 1 ".
    "THEN db2..table1.bar ".
    "ELSE db2..table1.bar ".
    "END ".
    "SELECT foo2,foo3"
  ::
  =/  case-qualified
    :*  %case
      ~
      ~[[%case-when-then simple-true-pred qualified-col-4]]
      (some qualified-col-4)
    ==
  =/  scalars  ~[[%scalar 'foo' case-qualified]]
  =/  expected  (mk-crud-txn scalars ~)
  %+  expect-eq
    !>  expected
    !>  (parse:parse(default-database default-db) query-string)
::
:: searched case expression: qualified column case scalar with
:: namespace.table.column (default database)
++  test-case-searched-09
  ::
  =/  query-string
    "FROM foo ".
    "SCALARS foo ".
    "CASE ".
    "WHEN 1 = 1 ".
    "THEN dba.table1.bar ".
    "ELSE dba.table1.bar ".
    "END ".
    "SELECT foo2,foo3"
  ::
  =/  case-qualified
    :*  %case
      ~
      ~[[%case-when-then simple-true-pred qualified-col-5]]
      (some qualified-col-5)
    ==
  =/  scalars  ~[[%scalar 'foo' case-qualified]]
  =/  expected  (mk-crud-txn scalars ~)
  %+  expect-eq
    !>  expected
    !>  (parse:parse(default-database default-db) query-string)
::
:: searched case expression: qualified column case scalar with
:: alias.column (default database)
++  test-case-searched-10
  ::
  =/  query-string
    "FROM ~sampel-palnet.db2.dba.table1 AS MyTable ".
    "SCALARS foo ".
    "CASE ".
    "WHEN 1 = 1 ".
    "THEN MyTable.bar ".
    "ELSE MyTable.bar ".
    "END ".
    "SELECT foo2,foo3"
  ::
  =/  table
    :*  %qualified-table
      ship=[~ ~sampel-palnet]
      database=%db2
      namespace=%dba
      name=%table1
      alias=[~ 'MyTable']
    ==
  =/  case-qualified
    :*  %case
      ~
      ~[[%case-when-then simple-true-pred qualified-col-6]]
      (some qualified-col-6)
    ==
  =/  scalars  ~[[%scalar 'foo' case-qualified]]
  =/  expected  (mk-crud-txn scalars (some table))
  %+  expect-eq
    !>  expected
    !>  (parse:parse(default-database default-db) query-string)
::
:: searched case expression: test case with coalesce scalar inline
++  test-case-searched-11
  ::
  =/  query-string
    "FROM foo ".
    "SCALARS foo COALESCE(foo2,1,foo2) ".
    "        bar CASE WHEN 1 = 1 THEN foo ELSE foo2 END ".
    "SELECT foo2,foo3"
  ::
  =/  naked-coalesce
    [%coalesce ~[unqualified-foo-2 literal-1 unqualified-foo-2]]
  =/  case-1
    :*
      %case
      target=~
      cases=~[[%case-when-then simple-true-pred [%scalar-name name=%foo]]]
      else=(some unqualified-foo-2)
    ==
  =/  scalars
    :~
      [%scalar 'foo' naked-coalesce]
      [%scalar 'bar' case-1]
    ==
  =/  expected  (mk-crud-txn scalars ~)
  %+  expect-eq
    !>  expected
    !>  (parse:parse(default-database default-db) query-string)
::
:: searched case expression: test case with if scalar inline
++  test-case-searched-12
  ::
  =/  query-string
    "FROM foo ".
    "SCALARS foo IF 1 = 1 THEN foo3 ELSE foo2 ENDIF ".
    "        bar CASE WHEN 1 = 1 THEN foo ELSE foo2 END ".
    "SELECT foo2,foo3"
  ::
  =/  naked-if
    :*
      %if-then-else
      if=simple-true-pred
      then=[unqualified-foo-3]
      else=[unqualified-foo-2]
    ==
  =/  case-1
    :*
      %case
      target=~
      cases=~[[%case-when-then simple-true-pred [%scalar-name name=%foo]]]
      else=(some unqualified-foo-2)
    ==
  =/  scalars
    :~
      [%scalar 'foo' naked-if]
      [%scalar 'bar' case-1]
    ==
  =/  expected  (mk-crud-txn scalars ~)
  %+  expect-eq
    !>  expected
    !>  (parse:parse(default-database default-db) query-string)
::
:: searched case expression: test case with case scalar inline
++  test-case-searched-13
  ::
  =/  query-string
    "FROM foo ".
    "SCALARS foo CASE WHEN 1 = 1 THEN foo3 END ".
    "        bar CASE WHEN 1 = 1 THEN foo ELSE foo2 END ".
    "SELECT foo2,foo3"
  ::
  =/  naked-case
    :*
      %case
      target=~
      cases=~[[%case-when-then simple-true-pred unqualified-foo-3]]
      else=~
    ==
  =/  case-1
    :*
      %case
      target=~
      cases=~[[%case-when-then simple-true-pred [%scalar-name name=%foo]]]
      else=(some unqualified-foo-2)
    ==
  =/  scalars
    :~
      [%scalar 'foo' naked-case]
      [%scalar 'bar' case-1]
    ==
  =/  expected  (mk-crud-txn scalars ~)
  %+  expect-eq
    !>  expected
    !>  (parse:parse(default-database default-db) query-string)
::
:: searched case expression: test case with a case nested in a case
++  test-case-searched-14
  ::
  =/  query-string
    "FROM foo ".
    "SCALARS baz CASE WHEN 1 = 1 THEN foo3 END ".
    "        bar CASE WHEN 1 = 1 THEN baz END ".
    "        foo CASE WHEN 1 = 1 THEN bar ELSE foo2 END ".
    "SELECT foo2,foo3"
  ::
  =/  second-case
    :*
      %case
      target=~
      cases=~[[%case-when-then simple-true-pred unqualified-foo-3]]
      else=~
    ==
  =/  first-case
    :*
      %case
      target=~
      cases=~[[%case-when-then simple-true-pred [%scalar-name name=%baz]]]
      else=~
    ==
  =/  case-1
    :*
      %case
      target=~
      cases=~[[%case-when-then simple-true-pred [%scalar-name name=%bar]]]
      else=(some unqualified-foo-2)
    ==
  =/  scalars
    :~
      [%scalar 'baz' second-case]
      [%scalar 'bar' first-case]
      [%scalar 'foo' case-1]
    ==
  =/  expected  (mk-crud-txn scalars ~)
  %+  expect-eq
    !>  expected
    !>  (parse:parse(default-database default-db) query-string)
::
::  arithmetic
::
++  test-fail-case-01
  ::
  =/  query-string
    "FROM foo ".
    "SCALARS foo CASE MyTable.bar ".
    "              WHEN 1 THEN MyTable.bar".
    "            ELSE MyTable.bar END ".
    "SELECT foo2,foo3"
  ::
  %+  expect-fail-message
    'table alias \'MyTable\' is not defined'
    |.  (parse:parse(default-database default-db) query-string)
::
:: simple math expression
++  test-arithmetic-1
  ::
  =/  query-string
    "FROM foo ".
    "SCALARS foo1 1 + 1 END ".
    "        foo2 1 - 1 END ".
    "        foo3 1 / 1 END ".
    "        foo4 1 * 1 END ".
    "        foo5 1 ^ 1 END ".
    "        foo6 1 % 1 END ".
    "SELECT foo2,foo3"
  ::
  =/  scalars
    :~
     [%scalar 'foo1' [%arithmetic operator=%lus left=literal-1 right=literal-1]]
     [%scalar 'foo2' [%arithmetic operator=%hep left=literal-1 right=literal-1]]
     [%scalar 'foo3' [%arithmetic operator=%fas left=literal-1 right=literal-1]]
     [%scalar 'foo4' [%arithmetic operator=%tar left=literal-1 right=literal-1]]
     [%scalar 'foo5' [%arithmetic operator=%ket left=literal-1 right=literal-1]]
     [%scalar 'foo6' [%arithmetic operator=%cen left=literal-1 right=literal-1]]
    ==
  =/  expected
    %-  mk-crud-txn-columns
    :*  scalars  ~  ~[selected-scalar-foo-2 selected-scalar-foo-3]  ==
  %+  expect-eq
    !>  expected
    !>  (parse:parse(default-database default-db) query-string)
::
:: singly nested math expressions
++  test-arithmetic-2
  ::
  =/  query-string
    "FROM foo ".
    "SCALARS foo1 (1 + 1) + 1 END ".
    "        foo2 (1 - 1) - 1 END ".
    "        foo3 (1 / 1) / 1 END ".
    "        foo4 (1 * 1) * 1 END ".
    "        foo5 (1 ^ 1) ^ 1 END ".
    "        foo6 (1 % 1) % 1 END ".
    "SELECT foo2,foo3"
  ::
  =/  addition
    :*
      %arithmetic
      operator=%lus
      left=[%arithmetic operator=%lus left=literal-1 right=literal-1]
      right=literal-1
    ==
  =/  subtraction
    :*
      %arithmetic
      operator=%hep
      left=[%arithmetic operator=%hep left=literal-1 right=literal-1]
      right=literal-1
    ==
  =/  division
    :*
      %arithmetic
      operator=%fas
      left=[%arithmetic operator=%fas left=literal-1 right=literal-1]
      right=literal-1
    ==
  =/  multiplication
    :*
      %arithmetic
      operator=%tar
      left=[%arithmetic operator=%tar left=literal-1 right=literal-1]
      right=literal-1
    ==
  =/  exponentiation
    :*
      %arithmetic
      operator=%ket
      left=[%arithmetic operator=%ket left=literal-1 right=literal-1]
      right=literal-1
    ==
  =/  modulo
    :*
      %arithmetic
      operator=%cen
      left=[%arithmetic operator=%cen left=literal-1 right=literal-1]
      right=literal-1
    ==
  =/  scalars
    :~
      [%scalar 'foo1' addition]
      [%scalar 'foo2' subtraction]
      [%scalar 'foo3' division]
      [%scalar 'foo4' multiplication]
      [%scalar 'foo5' exponentiation]
      [%scalar 'foo6' modulo]
    ==
  =/  expected
    %-  mk-crud-txn-columns
    :*  scalars  ~  ~[selected-scalar-foo-2 selected-scalar-foo-3]  ==
  %+  expect-eq
    !>  expected
    !>  (parse:parse(default-database default-db) query-string)
::
:: singly nested math expressions (right side)
++  test-arithmetic-3
  ::
  =/  query-string
    "FROM foo ".
    "SCALARS foo1 1 + (1 + 1) END ".
    "        foo2 1 - (1 - 1) END ".
    "        foo3 1 / (1 / 1) END ".
    "        foo4 1 * (1 * 1) END ".
    "        foo5 1 ^ (1 ^ 1) END ".
    "        foo6 1 % (1 % 1) END ".
    "SELECT foo2,foo3"
  ::
  =/  addition
    :*
      %arithmetic
      operator=%lus
      left=literal-1
      right=[%arithmetic operator=%lus left=literal-1 right=literal-1]
    ==
  =/  subtraction
    :*
      %arithmetic
      operator=%hep
      left=literal-1
      right=[%arithmetic operator=%hep left=literal-1 right=literal-1]
    ==
  =/  division
    :*
      %arithmetic
      operator=%fas
      left=literal-1
      right=[%arithmetic operator=%fas left=literal-1 right=literal-1]
    ==
  =/  multiplication
    :*
      %arithmetic
      operator=%tar
      left=literal-1
      right=[%arithmetic operator=%tar left=literal-1 right=literal-1]
    ==
  =/  exponentiation
    :*
      %arithmetic
      operator=%ket
      left=literal-1
      right=[%arithmetic operator=%ket left=literal-1 right=literal-1]
    ==
  =/  modulo
    :*
      %arithmetic
      operator=%cen
      left=literal-1
      right=[%arithmetic operator=%cen left=literal-1 right=literal-1]
    ==
  =/  scalars
    :~
      [%scalar 'foo1' addition]
      [%scalar 'foo2' subtraction]
      [%scalar 'foo3' division]
      [%scalar 'foo4' multiplication]
      [%scalar 'foo5' exponentiation]
      [%scalar 'foo6' modulo]
    ==
  =/  expected
    %-  mk-crud-txn-columns
    :*  scalars  ~  ~[selected-scalar-foo-2 selected-scalar-foo-3]  ==
  %+  expect-eq
    !>  expected
    !>  (parse:parse(default-database default-db) query-string)
::
:: doubly nested math expressions
++  test-arithmetic-4
  ::
  =/  query-string
    "FROM foo ".
    "SCALARS foo1 ((1 * 1) - 1) + 1 END ".
    "        foo2 ((1 + 1) ^ 1) - 1 END ".
    "        foo3 ((1 - 1) * 1) / 1 END ".
    "        foo4 ((1 / 1) + 1) * 1 END ".
    "        foo5 ((1 ^ 1) / 1) ^ 1 END ".
    "        foo6 ((1 % 1) % 1) % 1 END ".
    "SELECT foo2,foo3"
  ::
  =/  inner-multiplication
    [%arithmetic operator=%tar left=literal-1 right=literal-1]
  =/  middle-subtraction
    [%arithmetic operator=%hep left=inner-multiplication right=literal-1]
  =/  addition
    :*
      %arithmetic
      operator=%lus
      left=middle-subtraction
      right=literal-1
    ==
  =/  inner-addition
    [%arithmetic operator=%lus left=literal-1 right=literal-1]
  =/  middle-exponentiation
    [%arithmetic operator=%ket left=inner-addition right=literal-1]
  =/  subtraction
    :*
      %arithmetic
      operator=%hep
      left=middle-exponentiation
      right=literal-1
    ==
  =/  inner-subtraction
    [%arithmetic operator=%hep left=literal-1 right=literal-1]
  =/  middle-multiplication
    [%arithmetic operator=%tar left=inner-subtraction right=literal-1]
  =/  division
    :*
      %arithmetic
      operator=%fas
      left=middle-multiplication
      right=literal-1
    ==
  =/  inner-division
    [%arithmetic operator=%fas left=literal-1 right=literal-1]
  =/  middle-addition
    [%arithmetic operator=%lus left=inner-division right=literal-1]
  =/  multiplication
    :*
      %arithmetic
      operator=%tar
      left=middle-addition
      right=literal-1
    ==
  =/  inner-exponentiation
    [%arithmetic operator=%ket left=literal-1 right=literal-1]
  =/  middle-division
    [%arithmetic operator=%fas left=inner-exponentiation right=literal-1]
  =/  exponentiation
    :*
      %arithmetic
      operator=%ket
      left=middle-division
      right=literal-1
    ==
  =/  modulo
    :*
      %arithmetic
      operator=%cen
      :*  %arithmetic
          operator=%cen
          left=[%arithmetic operator=%cen left=literal-1 right=literal-1]
          right=literal-1
          ==
      right=literal-1
    ==
  =/  scalars
    :~
      [%scalar 'foo1' addition]
      [%scalar 'foo2' subtraction]
      [%scalar 'foo3' division]
      [%scalar 'foo4' multiplication]
      [%scalar 'foo5' exponentiation]
      [%scalar 'foo6' modulo]
    ==
  =/  expected
    %-  mk-crud-txn-columns
    :*  scalars  ~  ~[selected-scalar-foo-2 selected-scalar-foo-3]  ==
  %+  expect-eq
    !>  expected
    !>  (parse:parse(default-database default-db) query-string)
::
:: doubly nested math expressions (right side)
++  test-arithmetic-5
  ::
  =/  query-string
    "FROM foo ".
    "SCALARS foo1 1 + (1 - (1 * 1)) END ".
    "        foo2 1 - (1 ^ (1 + 1)) END ".
    "        foo3 1 / (1 * (1 - 1)) END ".
    "        foo4 1 * (1 + (1 / 1)) END ".
    "        foo5 1 ^ (1 / (1 ^ 1)) END ".
    "        foo6 1 % (1 % (1 % 1)) END ".
    "SELECT foo2,foo3"
  ::
  =/  inner-multiplication
    [%arithmetic operator=%tar left=literal-1 right=literal-1]
  =/  middle-subtraction
    [%arithmetic operator=%hep left=literal-1 right=inner-multiplication]
  =/  addition
    :*
      %arithmetic
      operator=%lus
      left=literal-1
      right=middle-subtraction
    ==
  =/  inner-addition
    [%arithmetic operator=%lus left=literal-1 right=literal-1]
  =/  middle-exponentiation
    [%arithmetic operator=%ket left=literal-1 right=inner-addition]
  =/  subtraction
    :*
      %arithmetic
      operator=%hep
      left=literal-1
      right=middle-exponentiation
    ==
  =/  inner-subtraction
    [%arithmetic operator=%hep left=literal-1 right=literal-1]
  =/  middle-multiplication
    [%arithmetic operator=%tar left=literal-1 right=inner-subtraction]
  =/  division
    :*
      %arithmetic
      operator=%fas
      left=literal-1
      right=middle-multiplication
    ==
  =/  inner-division
    [%arithmetic operator=%fas left=literal-1 right=literal-1]
  =/  middle-addition
    [%arithmetic operator=%lus left=literal-1 right=inner-division]
  =/  multiplication
    :*
      %arithmetic
      operator=%tar
      left=literal-1
      right=middle-addition
    ==
  =/  inner-exponentiation
    [%arithmetic operator=%ket left=literal-1 right=literal-1]
  =/  middle-division
    [%arithmetic operator=%fas left=literal-1 right=inner-exponentiation]
  =/  exponentiation
    :*
      %arithmetic
      operator=%ket
      left=literal-1
      right=middle-division
    ==
  =/  modulo
    :*
      %arithmetic
      operator=%cen
      left=literal-1
      :*  %arithmetic
          operator=%cen
          left=literal-1
          right=[%arithmetic operator=%cen left=literal-1 right=literal-1]
          ==
      ==
  =/  scalars
    :~
      [%scalar 'foo1' addition]
      [%scalar 'foo2' subtraction]
      [%scalar 'foo3' division]
      [%scalar 'foo4' multiplication]
      [%scalar 'foo5' exponentiation]
      [%scalar 'foo6' modulo]
    ==
  =/  expected
    %-  mk-crud-txn-columns
    :*  scalars  ~  ~[selected-scalar-foo-2 selected-scalar-foo-3]  ==
  %+  expect-eq
    !>  expected
    !>  (parse:parse(default-database default-db) query-string)
::
:: arithmetic expressions with spacing variations
++  test-arithmetic-6
  =/  query-string
    "FROM foo ".
    "SCALARS foo1 1 +1 END ".
    "        foo2 1  -  1 END ".
    "        foo3 1 /1 END ".
    "        foo4 1 *1 END ".
    "        foo5 1   ^   1 END ".
    "        foo6 (1 +1)+1 END ".
    "        foo7 ( 1 -1 ) - 1 END ".
    "        foo8 (1 / 1)/  1 END ".
    "        foo9 1 +( 1 + 1 ) END ".
    "        foo10 1 -(1 -1) END ".
    "        foo11 1  /  (1 / 1) END ".
    "        foo12 ((1 *1) -1) +1 END ".
    "        foo13 ( ( 1 + 1 ) ^ 1 ) - 1 END ".
    "        foo14 1 +  (1 -(1 *1)) END ".
    "        foo15 1 *(  1 +(1 /1)  ) END ".
    "SELECT foo2,foo3"
  ::
  =/  addition-no-space
    [%arithmetic operator=%lus left=literal-1 right=literal-1]
  =/  subtraction-extra-space
    [%arithmetic operator=%hep left=literal-1 right=literal-1]
  =/  division-mixed-space
    [%arithmetic operator=%fas left=literal-1 right=literal-1]
  =/  multiplication-mixed-space
    [%arithmetic operator=%tar left=literal-1 right=literal-1]
  =/  exponentiation-multi-space
    [%arithmetic operator=%ket left=literal-1 right=literal-1]
  =/  nested-left-no-space
    :*
      %arithmetic
      operator=%lus
      left=[%arithmetic operator=%lus left=literal-1 right=literal-1]
      right=literal-1
    ==
  =/  nested-left-paren-space
    :*
      %arithmetic
      operator=%hep
      left=[%arithmetic operator=%hep left=literal-1 right=literal-1]
      right=literal-1
    ==
  =/  nested-left-mixed
    :*
      %arithmetic
      operator=%fas
      left=[%arithmetic operator=%fas left=literal-1 right=literal-1]
      right=literal-1
    ==
  =/  nested-right-paren-space
    :*
      %arithmetic
      operator=%lus
      left=literal-1
      right=[%arithmetic operator=%lus left=literal-1 right=literal-1]
    ==
  =/  nested-right-no-paren-space
    :*
      %arithmetic
      operator=%hep
      left=literal-1
      right=[%arithmetic operator=%hep left=literal-1 right=literal-1]
    ==
  =/  nested-right-extra-space
    :*
      %arithmetic
      operator=%fas
      left=literal-1
      right=[%arithmetic operator=%fas left=literal-1 right=literal-1]
    ==
  =/  double-nested-minimal
    :*  %arithmetic
        %lus
        [%arithmetic %hep [%arithmetic %tar literal-1 literal-1] literal-1]
        literal-1
    ==
  =/  double-nested-maximal
    :*  %arithmetic
        %hep
        [%arithmetic %ket [%arithmetic %lus literal-1 literal-1] literal-1]
        literal-1
    ==
  =/  double-nested-right-mixed
    :*  %arithmetic
        %lus
        literal-1
        [%arithmetic %hep literal-1 [%arithmetic %tar literal-1 literal-1]]
    ==
  =/  double-nested-right-paren-space
    :*  %arithmetic
        %tar
        literal-1
        [%arithmetic %lus literal-1 [%arithmetic %fas literal-1 literal-1]]
    ==
  =/  scalars
    :~
      [%scalar 'foo1' addition-no-space]
      [%scalar 'foo2' subtraction-extra-space]
      [%scalar 'foo3' division-mixed-space]
      [%scalar 'foo4' multiplication-mixed-space]
      [%scalar 'foo5' exponentiation-multi-space]
      [%scalar 'foo6' nested-left-no-space]
      [%scalar 'foo7' nested-left-paren-space]
      [%scalar 'foo8' nested-left-mixed]
      [%scalar 'foo9' nested-right-paren-space]
      [%scalar 'foo10' nested-right-no-paren-space]
      [%scalar 'foo11' nested-right-extra-space]
      [%scalar 'foo12' double-nested-minimal]
      [%scalar 'foo13' double-nested-maximal]
      [%scalar 'foo14' double-nested-right-mixed]
      [%scalar 'foo15' double-nested-right-paren-space]
    ==
  =/  expected
    %-  mk-crud-txn-columns
    :*  scalars  ~  ~[selected-scalar-foo-2 selected-scalar-foo-3]  ==
  %+  expect-eq
    !>  expected
    !>  (parse:parse(default-database default-db) query-string)
::
:: test operator associativity
++  test-arithmetic-7
  =/  query-string
    "FROM foo ".
    "SCALARS foo1  2 ^ 3 ^ 3 END ".
    "        foo2  2 ^ (3 ^ 3) END ".
    "        foo3  (2 ^ 3) ^ 3 END ".
    "        foo4  2 + 3 + 4 END ".
    "        foo5  2 + (3 + 4) END ".
    "        foo6  (2 + 3) + 4 END ".
    "        foo7  2 - 3 - 4 END ".
    "        foo8  2 - (3 - 4) END ".
    "        foo9  (2 - 3) - 4 END ".
    "        foo10 2 * 3 * 4 END ".
    "        foo11 2 * (3 * 4) END ".
    "        foo12 (2 * 3) * 4 END ".
    "        foo13 2 / 3 / 4 END ".
    "        foo14 2 / (3 / 4) END ".
    "        foo15 (2 / 3) / 4 END ".
    "        foo16 2 + 3 * 4 END ".
    "        foo17 (2 + 3) * 4 END ".
    "        foo18 2 * 3 + 4 END ".
    "        foo19 2 * 3 ^ 4 END ".
    "        foo20 (2 * 3) ^ 4 END ".
    "        foo21 2 ^ 3 * 4 END ".
    "        foo22 2 + 3 - 4 * 5 / 2 END ".
    "        foo23 2 ^ 3 + 4 * 5 - 6 / 2 END ".
    "        foo24 2 % 3 % 4 END ".
    "        foo25 2 % (3 % 4) END ".
    "        foo26 (2 % 3) % 4 END ".
    "        foo27 2 + 3 % 4 END ".
    "        foo28 2 % 3 + 4 END ".
    "        foo29 2 * 3 % 4 END ".
    "        foo30 2 % 3 * 4 END ".
    "        foo31 2 ^ 3 % 4 END ".
    "        foo32 2 % 3 ^ 4 END ".
    "SELECT foo2,foo3"
  ::
  =/  literal-2              [p=~.ud q=2]
  =/  literal-3              [p=~.ud q=3]
  =/  literal-4              [p=~.ud q=4]
  =/  literal-5              [p=~.ud q=5]
  =/  literal-6              [p=~.ud q=6]
  =/  exponentiation-1
    :*  %arithmetic
      %ket
      literal-2
      :*  %arithmetic
        %ket
        literal-3
        literal-3
      ==
    ==
  =/  exponentiation-2
    :*  %arithmetic
      %ket
      literal-2
      :*  %arithmetic
        %ket
        literal-3
        literal-3
      ==
    ==
  =/  exponentiation-3
    :*  %arithmetic
      %ket
      :*  %arithmetic
        %ket
        literal-2
        literal-3
      ==
      literal-3
    ==
  =/  addition-left-assoc
    :*  %arithmetic
      %lus
      :*  %arithmetic
        %lus
        literal-2
        literal-3
      ==
      literal-4
    ==
  =/  addition-right-assoc
    :*  %arithmetic
      %lus
      literal-2
      :*  %arithmetic
        %lus
        literal-3
        literal-4
      ==
    ==
  =/  addition-left-assoc-explicit
    :*  %arithmetic
      %lus
      :*  %arithmetic
        %lus
        literal-2
        literal-3
      ==
      literal-4
    ==
  =/  subtraction-left-assoc
    :*  %arithmetic
      %hep
      :*  %arithmetic
        %hep
        literal-2
        literal-3
      ==
      literal-4
    ==
  =/  subtraction-right-assoc
    :*  %arithmetic
      %hep
      literal-2
      :*  %arithmetic
        %hep
        literal-3
        literal-4
      ==
    ==
  =/  subtraction-left-assoc-explicit
    :*  %arithmetic
      %hep
      :*  %arithmetic
        %hep
        literal-2
        literal-3
      ==
      literal-4
    ==
  =/  multiplication-left-assoc
    :*  %arithmetic
      %tar
      :*  %arithmetic
        %tar
        literal-2
        literal-3
      ==
      literal-4
    ==
  =/  multiplication-right-assoc
    :*  %arithmetic
      %tar
      literal-2
      :*  %arithmetic
        %tar
        literal-3
        literal-4
      ==
    ==
  =/  multiplication-left-assoc-explicit
    :*  %arithmetic
      %tar
      :*  %arithmetic
        %tar
        literal-2
        literal-3
      ==
      literal-4
    ==
  =/  division-left-assoc
    :*  %arithmetic
      %fas
      :*  %arithmetic
        %fas
        literal-2
        literal-3
      ==
      literal-4
    ==
  =/  division-right-assoc
    :*  %arithmetic
      %fas
      literal-2
      :*  %arithmetic
        %fas
        literal-3
        literal-4
      ==
    ==
  =/  division-left-assoc-explicit
    :*  %arithmetic
      %fas
      :*  %arithmetic
        %fas
        literal-2
        literal-3
      ==
      literal-4
    ==
  =/  mixed-precedence-1
    :*  %arithmetic
      %lus
      literal-2
      :*  %arithmetic
        %tar
        literal-3
        literal-4
      ==
    ==
  =/  mixed-precedence-2
    :*  %arithmetic
      %tar
      :*  %arithmetic
        %lus
        literal-2
        literal-3
      ==
      literal-4
    ==
  =/  mixed-precedence-3
    :*  %arithmetic
      %lus
      :*  %arithmetic
        %tar
        literal-2
        literal-3
      ==
      literal-4
    ==
  =/  mixed-precedence-4
    :*  %arithmetic
      %tar
      literal-2
      :*  %arithmetic
        %ket
        literal-3
        literal-4
      ==
    ==
  =/  mixed-precedence-5
    :*  %arithmetic
      %ket
      :*  %arithmetic
        %tar
        literal-2
        literal-3
      ==
      literal-4
    ==
  =/  mixed-precedence-6
    :*  %arithmetic
      %tar
      :*  %arithmetic
        %ket
        literal-2
        literal-3
      ==
      literal-4
    ==
  =/  mixed-precedence-7
    :*  %arithmetic
      %hep
      :*  %arithmetic
        %lus
        literal-2
        literal-3
      ==
      :*  %arithmetic
        %fas
        :*  %arithmetic
          %tar
          literal-4
          literal-5
        ==
        literal-2
      ==
    ==
  =/  mixed-precedence-8
    :*  %arithmetic
      %hep
      :*  %arithmetic
        %lus
        :*  %arithmetic
          %ket
          literal-2
          literal-3
        ==
        :*  %arithmetic
          %tar
          literal-4
          literal-5
        ==
      ==
      :*  %arithmetic
        %fas
        literal-6
        literal-2
      ==
    ==
  ::  modulo associativity: 2 % 3 % 4 -> (2 % 3) % 4
  =/  modulo-left-assoc
    :*  %arithmetic
      %cen
      :*  %arithmetic
        %cen
        literal-2
        literal-3
      ==
      literal-4
    ==
  ::  modulo explicit right-assoc: 2 % (3 % 4)
  =/  modulo-right-assoc
    :*  %arithmetic
      %cen
      literal-2
      :*  %arithmetic
        %cen
        literal-3
        literal-4
      ==
    ==
  ::  modulo explicit left-assoc: (2 % 3) % 4 -- same AST as implicit
  =/  modulo-left-assoc-explicit
    :*  %arithmetic
      %cen
      :*  %arithmetic
        %cen
        literal-2
        literal-3
      ==
      literal-4
    ==
  ::  2 + 3 % 4 -> 2 + (3 % 4)  (% higher precedence than +)
  =/  mixed-modulo-1
    :*  %arithmetic
      %lus
      literal-2
      :*  %arithmetic
        %cen
        literal-3
        literal-4
      ==
    ==
  ::  2 % 3 + 4 -> (2 % 3) + 4
  =/  mixed-modulo-2
    :*  %arithmetic
      %lus
      :*  %arithmetic
        %cen
        literal-2
        literal-3
      ==
      literal-4
    ==
  ::  2 * 3 % 4 -> (2 * 3) % 4  (same precedence, left-assoc)
  =/  mixed-modulo-3
    :*  %arithmetic
      %cen
      :*  %arithmetic
        %tar
        literal-2
        literal-3
      ==
      literal-4
    ==
  ::  2 % 3 * 4 -> (2 % 3) * 4  (same precedence, left-assoc)
  =/  mixed-modulo-4
    :*  %arithmetic
      %tar
      :*  %arithmetic
        %cen
        literal-2
        literal-3
      ==
      literal-4
    ==
  ::  2 ^ 3 % 4 -> (2 ^ 3) % 4  (^ higher precedence than %)
  =/  mixed-modulo-5
    :*  %arithmetic
      %cen
      :*  %arithmetic
        %ket
        literal-2
        literal-3
      ==
      literal-4
    ==
  ::  2 % 3 ^ 4 -> 2 % (3 ^ 4)  (^ higher precedence than %)
  =/  mixed-modulo-6
    :*  %arithmetic
      %cen
      literal-2
      :*  %arithmetic
        %ket
        literal-3
        literal-4
      ==
    ==
  =/  scalars
    :~
      [%scalar 'foo1' exponentiation-1]
      [%scalar 'foo2' exponentiation-2]
      [%scalar 'foo3' exponentiation-3]
      [%scalar 'foo4' addition-left-assoc]
      [%scalar 'foo5' addition-right-assoc]
      [%scalar 'foo6' addition-left-assoc-explicit]
      [%scalar 'foo7' subtraction-left-assoc]
      [%scalar 'foo8' subtraction-right-assoc]
      [%scalar 'foo9' subtraction-left-assoc-explicit]
      [%scalar 'foo10' multiplication-left-assoc]
      [%scalar 'foo11' multiplication-right-assoc]
      [%scalar 'foo12' multiplication-left-assoc-explicit]
      [%scalar 'foo13' division-left-assoc]
      [%scalar 'foo14' division-right-assoc]
      [%scalar 'foo15' division-left-assoc-explicit]
      [%scalar 'foo16' mixed-precedence-1]
      [%scalar 'foo17' mixed-precedence-2]
      [%scalar 'foo18' mixed-precedence-3]
      [%scalar 'foo19' mixed-precedence-4]
      [%scalar 'foo20' mixed-precedence-5]
      [%scalar 'foo21' mixed-precedence-6]
      [%scalar 'foo22' mixed-precedence-7]
      [%scalar 'foo23' mixed-precedence-8]
      [%scalar 'foo24' modulo-left-assoc]
      [%scalar 'foo25' modulo-right-assoc]
      [%scalar 'foo26' modulo-left-assoc-explicit]
      [%scalar 'foo27' mixed-modulo-1]
      [%scalar 'foo28' mixed-modulo-2]
      [%scalar 'foo29' mixed-modulo-3]
      [%scalar 'foo30' mixed-modulo-4]
      [%scalar 'foo31' mixed-modulo-5]
      [%scalar 'foo32' mixed-modulo-6]
    ==
  =/  expected
    %-  mk-crud-txn-columns
    :*  scalars  ~  ~[selected-scalar-foo-2 selected-scalar-foo-3]  ==
  %+  expect-eq
    !>  expected
    !>  (parse:parse(default-database default-db) query-string)
::
:: arithmetic expressions with bare constants and datetime extractors
++  test-arithmetic-8
  =/  query-string
    "FROM foo ".
    "SCALARS foo1 TAU / 2 END ".
    "        foo2 E ^ .~2.0 END ".
    "        foo3 DEGREES(TAU) + HOUR(~h3) END ".
    "        foo4 MINUTE(~h1.m30) - SECOND(~s30) END ".
    "SELECT foo2,foo3"
  ::
  =/  literal-2       [p=~.ud q=2]
  =/  literal-rd-20   [p=~.rd q=.~2.0]
  =/  literal-h3      [p=~.dr q=~h3]
  =/  literal-h1-m30  [p=~.dr q=~h1.m30]
  =/  literal-s30     [p=~.dr q=~s30]
  =/  tau-div
    [%arithmetic operator=%fas left=[%tau ~] right=literal-2]
  =/  e-pow
    [%arithmetic operator=%ket left=[%e ~] right=literal-rd-20]
  =/  degrees-plus-hour
    :*
      %arithmetic
      operator=%lus
      left=[%degrees [%tau ~]]
      right=[%hour literal-h3]
    ==
  =/  minute-minus-second
    :*
      %arithmetic
      operator=%hep
      left=[%minute literal-h1-m30]
      right=[%second literal-s30]
    ==
  =/  scalars
    :~
      [%scalar 'foo1' tau-div]
      [%scalar 'foo2' e-pow]
      [%scalar 'foo3' degrees-plus-hour]
      [%scalar 'foo4' minute-minus-second]
    ==
  =/  expected
    %-  mk-crud-txn-columns
    :*  scalars  ~  ~[selected-scalar-foo-2 selected-scalar-foo-3]  ==
  %+  expect-eq
    !>  expected
    !>  (parse:parse(default-database default-db) query-string)
::
:: arithmetic expressions with scalar-name operands
++  test-arithmetic-scalar-node-01
  ::
  =/  query-string
    "FROM foo ".
    "SCALARS sc1 COALESCE(foo2,1,foo3) ".
    "        suma sc1 + 1 END ".
    "        sumb 1 + sc1 END ".
    "SELECT foo2,foo3"
  ::
  =/  sc1-coalesce
    [%coalesce ~[unqualified-foo-2 literal-1 unqualified-foo-3]]
  =/  left-add
    [%arithmetic operator=%lus left=[%scalar-name name=%sc1] right=literal-1]
  =/  right-add
    [%arithmetic operator=%lus left=literal-1 right=[%scalar-name name=%sc1]]
  =/  scalars
    :~
      [%scalar 'sc1' sc1-coalesce]
      [%scalar 'suma' left-add]
      [%scalar 'sumb' right-add]
    ==
  =/  expected  (mk-crud-txn scalars ~)
  %+  expect-eq
    !>  expected
    !>  (parse:parse(default-database default-db) query-string)
::
:: test that there can't be an operator right after an operand
::
:: explaination: due to parsing rules there always need to be a space before an
:: operator, otherwise it tries to parse it with value-literal rule. see
:: cord-literal
++  test-fail-arithmetic-00
  ::
  =/  query-string
    :: commented some out because not sure that we want double spacing
    "FROM foo ".
    "SCALARS foo1 1+1 END ".
    "SELECT foo2,foo3"
  ::
  %+  expect-fail-message
    'PARSER: '
    |.  (parse:parse(default-database default-db) query-string)
::
::  test single operand in arithmetic expression
++  test-fail-arithmetic-01
  ::
  =/  query-string
    "FROM foo ".
    "SCALARS foo 42 END ".
    "SELECT foo"
  ::
  %+  expect-fail-message
    'can\'t do arithmetic with only a single operand:\
    / [p=~.ud q=42]'
    |.  (parse:parse(default-database default-db) query-string)
::
::  new math and trig builtins
::
::  randomized spacing
++  test-builtins-05
  =/  query-string
    "FROM foo ".
    "SCALARS mt-e   E() ".
    "        mt-phi PHI() ".
    "        mt-pi  PI() ".
    "        mt-tau TAU() ".
    "        mt-max MAX(   .5 ,  .2   ) ".
    "        mt-min MIN(  .5  ,   .2 ) ".
    "        mt-rnd RAND(  .2  , .5   ) ".
    "        mt-deg DEGREES(  .5   ) ".
    "        mt-sin SIN(   .5 ) ".
    "        mt-cos COS(  .5  ) ".
    "        mt-tan TAN(   .5   ) ".
    "        mt-asi ASIN( .5  ) ".
    "        mt-aco ACOS(  .5 ) ".
    "        mt-atn ATAN(  .5   ) ".
    "        mt-at2 ATAN2(   .5 ,  .2   ) ".
    "SELECT foo2,foo3"
  ::
  =/  literal-float   [p=~.rs q=.5]
  =/  literal-float2  [p=~.rs q=.2]
  ::
  =/  scalars
    :~
      [%scalar 'mt-e' [%e ~]]
      [%scalar 'mt-phi' [%phi ~]]
      [%scalar 'mt-pi' [%pi ~]]
      [%scalar 'mt-tau' [%tau ~]]
      [%scalar 'mt-max' [%max literal-float literal-float2]]
      [%scalar 'mt-min' [%min literal-float literal-float2]]
      [%scalar 'mt-rnd' [%rand literal-float2 literal-float]]
      [%scalar 'mt-deg' [%degrees literal-float]]
      [%scalar 'mt-sin' [%sin literal-float]]
      [%scalar 'mt-cos' [%cos literal-float]]
      [%scalar 'mt-tan' [%tan literal-float]]
      [%scalar 'mt-asi' [%asin literal-float]]
      [%scalar 'mt-aco' [%acos literal-float]]
      [%scalar 'mt-atn' [%atan literal-float]]
      [%scalar 'mt-at2' [%atan2 literal-float literal-float2]]
    ==
  =/  expected  (mk-crud-txn scalars ~)
  %+  expect-eq
    !>  expected
    !>  (parse:parse(default-database default-db) query-string)
::
::  spaces before parameters
++  test-builtins-06
  =/  query-string
    "FROM ~sampel-palnet.db2.dba.table1 AS MyTable ".
    "SCALARS mt-e   E() ".
    "        mt-phi PHI() ".
    "        mt-pi  PI() ".
    "        mt-tau TAU() ".
    "        mt-max MAX(  .5,   .2) ".
    "        mt-min MIN(   .5,  .2) ".
    "        mt-rnd RAND(  .2,   .5) ".
    "        mt-deg DEGREES(  .5) ".
    "        mt-sin SIN(   .5) ".
    "        mt-cos COS(  .5) ".
    "        mt-tan TAN(   .5) ".
    "        mt-asi ASIN( .5) ".
    "        mt-aco ACOS(  .5) ".
    "        mt-atn ATAN(   .5) ".
    "        mt-at2 ATAN2(  .5,   .2) ".
    "        mxq1 MAX(   ~sampel-palnet.db2.dba.table1.bar,  .2) ".
    "        mxu1 MAX(  foo3,   .2) ".
    "        mxs1 MAX(   mt-max,  .2) ".
    "        snq1 SIN(  ~sampel-palnet.db2..table1.bar) ".
    "        snu1 SIN(   foo3) ".
    "        sns1 SIN(   mt-sin) ".
    "SELECT foo2,foo3"
  ::
  =/  literal-float   [p=~.rs q=.5]
  =/  literal-float2  [p=~.rs q=.2]
  ::
  =/  scalars
    :~
      [%scalar 'mt-e' [%e ~]]
      [%scalar 'mt-phi' [%phi ~]]
      [%scalar 'mt-pi' [%pi ~]]
      [%scalar 'mt-tau' [%tau ~]]
      [%scalar 'mt-max' [%max literal-float literal-float2]]
      [%scalar 'mt-min' [%min literal-float literal-float2]]
      [%scalar 'mt-rnd' [%rand literal-float2 literal-float]]
      [%scalar 'mt-deg' [%degrees literal-float]]
      [%scalar 'mt-sin' [%sin literal-float]]
      [%scalar 'mt-cos' [%cos literal-float]]
      [%scalar 'mt-tan' [%tan literal-float]]
      [%scalar 'mt-asi' [%asin literal-float]]
      [%scalar 'mt-aco' [%acos literal-float]]
      [%scalar 'mt-atn' [%atan literal-float]]
      [%scalar 'mt-at2' [%atan2 literal-float literal-float2]]
      [%scalar 'mxq1' [%max qualified-col-1 literal-float2]]
      [%scalar 'mxu1' [%max unqualified-foo-3 literal-float2]]
      [%scalar 'mxs1' [%max [%scalar-name name=%mt-max] literal-float2]]
      [%scalar 'snq1' [%sin qualified-col-2]]
      [%scalar 'snu1' [%sin unqualified-foo-3]]
      [%scalar 'sns1' [%sin [%scalar-name name=%mt-sin]]]
    ==
  =/  table
    :*  %qualified-table
      ship=[~ ~sampel-palnet]
      database=%db2
      namespace=%dba
      name=%table1
      alias=[~ 'MyTable']
    ==
  =/  expected  (mk-crud-txn scalars (some table))
  %+  expect-eq
    !>  expected
    !>  (parse:parse(default-database default-db) query-string)
::
::  spaces after parameters
++  test-builtins-07
  =/  query-string
    "FROM ~sampel-palnet.db2.dba.table1 AS MyTable ".
    "SCALARS mt-e   E() ".
    "        mt-phi PHI() ".
    "        mt-pi  PI() ".
    "        mt-tau TAU() ".
    "        mt-max MAX(.5  ,.2   ) ".
    "        mt-min MIN(.5   ,.2  ) ".
    "        mt-rnd RAND(.2  ,.5   ) ".
    "        mt-deg DEGREES(.5   ) ".
    "        mt-sin SIN(.5    ) ".
    "        mt-cos COS(.5   ) ".
    "        mt-tan TAN(.5    ) ".
    "        mt-asi ASIN(.5   ) ".
    "        mt-aco ACOS(.5    ) ".
    "        mt-atn ATAN(.5   ) ".
    "        mt-at2 ATAN2(.5   ,.2   ) ".
    "        mnq1 MIN(~sampel-palnet.db2.dba.table1.bar  ,.2 ) ".
    "        mnu1 MIN(foo3   ,.2  ) ".
    "        mns1 MIN(mt-min   ,.2  ) ".
    "        csq1 COS(db2.dba.table1.bar   ) ".
    "        csu1 COS(foo3  ) ".
    "        css1 COS(mt-cos   ) ".
    "SELECT foo2,foo3"
  ::
  =/  literal-float   [p=~.rs q=.5]
  =/  literal-float2  [p=~.rs q=.2]
  ::
  =/  scalars
    :~
      [%scalar 'mt-e' [%e ~]]
      [%scalar 'mt-phi' [%phi ~]]
      [%scalar 'mt-pi' [%pi ~]]
      [%scalar 'mt-tau' [%tau ~]]
      [%scalar 'mt-max' [%max literal-float literal-float2]]
      [%scalar 'mt-min' [%min literal-float literal-float2]]
      [%scalar 'mt-rnd' [%rand literal-float2 literal-float]]
      [%scalar 'mt-deg' [%degrees literal-float]]
      [%scalar 'mt-sin' [%sin literal-float]]
      [%scalar 'mt-cos' [%cos literal-float]]
      [%scalar 'mt-tan' [%tan literal-float]]
      [%scalar 'mt-asi' [%asin literal-float]]
      [%scalar 'mt-aco' [%acos literal-float]]
      [%scalar 'mt-atn' [%atan literal-float]]
      [%scalar 'mt-at2' [%atan2 literal-float literal-float2]]
      [%scalar 'mnq1' [%min qualified-col-1 literal-float2]]
      [%scalar 'mnu1' [%min unqualified-foo-3 literal-float2]]
      [%scalar 'mns1' [%min [%scalar-name name=%mt-min] literal-float2]]
      [%scalar 'csq1' [%cos qualified-col-3]]
      [%scalar 'csu1' [%cos unqualified-foo-3]]
      [%scalar 'css1' [%cos [%scalar-name name=%mt-cos]]]
    ==
  =/  table
    :*  %qualified-table
      ship=[~ ~sampel-palnet]
      database=%db2
      namespace=%dba
      name=%table1
      alias=[~ 'MyTable']
    ==
  =/  expected  (mk-crud-txn scalars (some table))
  %+  expect-eq
    !>  expected
    !>  (parse:parse(default-database default-db) query-string)
::
::  spaces before and after parameters
++  test-builtins-08
  =/  query-string
    "FROM ~sampel-palnet.db2.dba.table1 AS MyTable ".
    "SCALARS mt-e   E() ".
    "        mt-phi PHI() ".
    "        mt-pi  PI() ".
    "        mt-tau TAU() ".
    "        mt-max MAX(  .5   ,   .2  ) ".
    "        mt-min MIN(   .5  ,  .2   ) ".
    "        mt-rnd RAND(  .2   ,   .5  ) ".
    "        mt-deg DEGREES(   .5  ) ".
    "        mt-sin SIN(  .5    ) ".
    "        mt-cos COS(   .5   ) ".
    "        mt-tan TAN(  .5    ) ".
    "        mt-asi ASIN(   .5   ) ".
    "        mt-aco ACOS(  .5    ) ".
    "        mt-atn ATAN(   .5   ) ".
    "        mt-at2 ATAN2(  .5   ,   .2  ) ".
    "        rdq1 RAND(  ~sampel-palnet.db2..table1.bar   ,  .5   ) ".
    "        rdu1 RAND(  foo3   ,   .5  ) ".
    "        rds1 RAND(  mt-rnd   ,   .5  ) ".
    "        tnq1 TAN(   db2..table1.bar  ) ".
    "        tnu1 TAN(  foo3   ) ".
    "        tns1 TAN(   mt-tan  ) ".
    "SELECT foo2,foo3"
  ::
  =/  literal-float   [p=~.rs q=.5]
  =/  literal-float2  [p=~.rs q=.2]
  ::
  =/  scalars
    :~
      [%scalar 'mt-e' [%e ~]]
      [%scalar 'mt-phi' [%phi ~]]
      [%scalar 'mt-pi' [%pi ~]]
      [%scalar 'mt-tau' [%tau ~]]
      [%scalar 'mt-max' [%max literal-float literal-float2]]
      [%scalar 'mt-min' [%min literal-float literal-float2]]
      [%scalar 'mt-rnd' [%rand literal-float2 literal-float]]
      [%scalar 'mt-deg' [%degrees literal-float]]
      [%scalar 'mt-sin' [%sin literal-float]]
      [%scalar 'mt-cos' [%cos literal-float]]
      [%scalar 'mt-tan' [%tan literal-float]]
      [%scalar 'mt-asi' [%asin literal-float]]
      [%scalar 'mt-aco' [%acos literal-float]]
      [%scalar 'mt-atn' [%atan literal-float]]
      [%scalar 'mt-at2' [%atan2 literal-float literal-float2]]
      [%scalar 'rdq1' [%rand qualified-col-2 literal-float]]
      [%scalar 'rdu1' [%rand unqualified-foo-3 literal-float]]
      [%scalar 'rds1' [%rand [%scalar-name name=%mt-rnd] literal-float]]
      [%scalar 'tnq1' [%tan qualified-col-4]]
      [%scalar 'tnu1' [%tan unqualified-foo-3]]
      [%scalar 'tns1' [%tan [%scalar-name name=%mt-tan]]]
    ==
  =/  table
    :*  %qualified-table
      ship=[~ ~sampel-palnet]
      database=%db2
      namespace=%dba
      name=%table1
      alias=[~ 'MyTable']
    ==
  =/  expected  (mk-crud-txn scalars (some table))
  %+  expect-eq
    !>  expected
    !>  (parse:parse(default-database default-db) query-string)
::
::  new string scalar builtins
::
::  no spacing
++  test-builtins-09
  =/  query-string
    "FROM foo ".
    "SCALARS st-low LOWER('hello') ".
    "        st-upr UPPER('hello') ".
    "        st-rev REVERSE('hello') ".
    "        st-lt1 LTRIM('hello') ".
    "        st-lt2 LTRIM('hello',' ') ".
    "        st-rt1 RTRIM('hello') ".
    "        st-rt2 RTRIM('hello',' ') ".
    "        st-pat PATINDEX('hello','ell') ".
    "        st-rep REPLACE('hello','ell','ELL') ".
    "        st-rpl REPLICATE('hello',3) ".
    "        st-qs1 QUOTESTRING('hello') ".
    "        st-qs2 QUOTESTRING('hello','\\'') ".
    "        st-qs3 QUOTESTRING('hello','[',']') ".
    "        st-str STRING(3) ".
    "        st-sc1 STRING-CONCAT('hello','world',' ') ".
    "        st-stf STUFF('hello',2,3,'xx') ".
    "        loq1 LOWER(~sampel-palnet.db2.dba.table1.bar) ".
    "        lou1 LOWER(foo3) ".
    "        los1 LOWER(st-low) ".
    "SELECT foo2,foo3"
  ::
  =/  literal-hello    [p=~.t q='hello']
  =/  literal-world    [p=~.t q='world']
  =/  literal-space    [p=~.t q=' ']
  =/  literal-ell      [p=~.t q='ell']
  =/  literal-ell-up      [p=~.t q='ELL']
  =/  literal-xx       [p=~.t q='xx']
  =/  literal-sq       [p=~.t q='\'']
  =/  literal-open     [p=~.t q='[']
  =/  literal-close    [p=~.t q=']']
  =/  literal-3        [p=~.ud q=3]
  =/  literal-2        [p=~.ud q=2]
  ::
  =/  scalars
    :~
      [%scalar 'st-low' [%lower literal-hello]]
      [%scalar 'st-upr' [%upper literal-hello]]
      [%scalar 'st-rev' [%reverse literal-hello]]
      [%scalar 'st-lt1' [%ltrim literal-hello ~]]
      [%scalar 'st-lt2' [%ltrim literal-hello `literal-space]]
      [%scalar 'st-rt1' [%rtrim literal-hello ~]]
      [%scalar 'st-rt2' [%rtrim literal-hello `literal-space]]
      [%scalar 'st-pat' [%patindex literal-hello literal-ell]]
      [%scalar 'st-rep' [%replace literal-hello literal-ell literal-ell-up]]
      [%scalar 'st-rpl' [%replicate literal-hello literal-3]]
      [%scalar 'st-qs1' [%quotestring literal-hello ~]]
      [%scalar 'st-qs2' [%quotestring literal-hello `[literal-sq literal-sq]]]
      :+  %scalar
          'st-qs3'
          [%quotestring literal-hello `[literal-open literal-close]]
      [%scalar 'st-str' [%string literal-3]]
      :+  %scalar
          'st-sc1'
          [%string-concat ~[literal-hello literal-world] literal-space]
      [%scalar 'st-stf' [%stuff literal-hello literal-2 literal-3 literal-xx]]
      [%scalar 'loq1' [%lower qualified-col-1]]
      [%scalar 'lou1' [%lower unqualified-foo-3]]
      [%scalar 'los1' [%lower [%scalar-name name=%st-low]]]
    ==
  =/  expected  (mk-crud-txn scalars ~)
  %+  expect-eq
    !>  expected
    !>  (parse:parse(default-database default-db) query-string)
::
::  spaces before params
++  test-builtins-10
  =/  query-string
    "FROM ~sampel-palnet.db2.dba.table1 AS MyTable ".
    "SCALARS st-low LOWER(  'hello') ".
    "        st-upr UPPER(  'hello') ".
    "        st-rev REVERSE(  'hello') ".
    "        st-lt1 LTRIM(  'hello') ".
    "        st-lt2 LTRIM(  'hello',  ' ') ".
    "        st-rt1 RTRIM(  'hello') ".
    "        st-rt2 RTRIM(  'hello',  ' ') ".
    "        st-pat PATINDEX(  'hello',  'ell') ".
    "        st-rep REPLACE(  'hello',  'ell',  'ELL') ".
    "        st-rpl REPLICATE(  'hello',  3) ".
    "        st-qs1 QUOTESTRING(  'hello') ".
    "        st-qs2 QUOTESTRING(  'hello',  '\\'') ".
    "        st-qs3 QUOTESTRING(  'hello',  '[',  ']') ".
    "        st-str STRING(  3) ".
    "        st-sc1 STRING-CONCAT(  'hello',  'world',  ' ') ".
    "        st-stf STUFF(  'hello',  2,  3,  'xx') ".
    "        loq1 LOWER(  ~sampel-palnet.db2.dba.table1.bar) ".
    "        lou1 LOWER(  foo3) ".
    "        los1 LOWER(  st-low) ".
    "SELECT foo2,foo3"
  ::
  =/  literal-hello    [p=~.t q='hello']
  =/  literal-world    [p=~.t q='world']
  =/  literal-space    [p=~.t q=' ']
  =/  literal-ell      [p=~.t q='ell']
  =/  literal-ell-up      [p=~.t q='ELL']
  =/  literal-xx       [p=~.t q='xx']
  =/  literal-sq       [p=~.t q='\'']
  =/  literal-open     [p=~.t q='[']
  =/  literal-close    [p=~.t q=']']
  =/  literal-3        [p=~.ud q=3]
  =/  literal-2        [p=~.ud q=2]
  ::
  =/  scalars
    :~
      [%scalar 'st-low' [%lower literal-hello]]
      [%scalar 'st-upr' [%upper literal-hello]]
      [%scalar 'st-rev' [%reverse literal-hello]]
      [%scalar 'st-lt1' [%ltrim literal-hello ~]]
      [%scalar 'st-lt2' [%ltrim literal-hello `literal-space]]
      [%scalar 'st-rt1' [%rtrim literal-hello ~]]
      [%scalar 'st-rt2' [%rtrim literal-hello `literal-space]]
      [%scalar 'st-pat' [%patindex literal-hello literal-ell]]
      [%scalar 'st-rep' [%replace literal-hello literal-ell literal-ell-up]]
      [%scalar 'st-rpl' [%replicate literal-hello literal-3]]
      [%scalar 'st-qs1' [%quotestring literal-hello ~]]
      [%scalar 'st-qs2' [%quotestring literal-hello `[literal-sq literal-sq]]]
      :+  %scalar
          'st-qs3'
          [%quotestring literal-hello `[literal-open literal-close]]
      [%scalar 'st-str' [%string literal-3]]
      :+  %scalar
          'st-sc1'
          [%string-concat ~[literal-hello literal-world] literal-space]
      [%scalar 'st-stf' [%stuff literal-hello literal-2 literal-3 literal-xx]]
      [%scalar 'loq1' [%lower qualified-col-1]]
      [%scalar 'lou1' [%lower unqualified-foo-3]]
      [%scalar 'los1' [%lower [%scalar-name name=%st-low]]]
    ==
  =/  table
    :*  %qualified-table
      ship=[~ ~sampel-palnet]
      database=%db2
      namespace=%dba
      name=%table1
      alias=[~ 'MyTable']
    ==
  =/  expected  (mk-crud-txn scalars (some table))
  %+  expect-eq
    !>  expected
    !>  (parse:parse(default-database default-db) query-string)
::
::  spaces after params
++  test-builtins-11
  =/  query-string
    "FROM ~sampel-palnet.db2.dba.table1 AS MyTable ".
    "SCALARS st-low LOWER('hello'  ) ".
    "        st-upr UPPER('hello'  ) ".
    "        st-rev REVERSE('hello'  ) ".
    "        st-lt1 LTRIM('hello'  ) ".
    "        st-lt2 LTRIM('hello'  ,' '  ) ".
    "        st-rt1 RTRIM('hello'  ) ".
    "        st-rt2 RTRIM('hello'  ,' '  ) ".
    "        st-pat PATINDEX('hello'  ,'ell'  ) ".
    "        st-rep REPLACE('hello'  ,'ell'  ,'ELL'  ) ".
    "        st-rpl REPLICATE('hello'  ,3  ) ".
    "        st-qs1 QUOTESTRING('hello'  ) ".
    "        st-qs2 QUOTESTRING('hello'  ,'\\''  ) ".
    "        st-qs3 QUOTESTRING('hello'  ,'['  ,']'  ) ".
    "        st-str STRING(3  ) ".
    "        st-sc1 STRING-CONCAT('hello'  ,'world'  ,' '  ) ".
    "        st-stf STUFF('hello'  ,2  ,3  ,'xx'  ) ".
    "        loq1 LOWER(~sampel-palnet.db2.dba.table1.bar  ) ".
    "        lou1 LOWER(foo3  ) ".
    "        los1 LOWER(st-low  ) ".
    "SELECT foo2,foo3"
  ::
  =/  literal-hello    [p=~.t q='hello']
  =/  literal-world    [p=~.t q='world']
  =/  literal-space    [p=~.t q=' ']
  =/  literal-ell      [p=~.t q='ell']
  =/  literal-ell-up      [p=~.t q='ELL']
  =/  literal-xx       [p=~.t q='xx']
  =/  literal-sq       [p=~.t q='\'']
  =/  literal-open     [p=~.t q='[']
  =/  literal-close    [p=~.t q=']']
  =/  literal-3        [p=~.ud q=3]
  =/  literal-2        [p=~.ud q=2]
  ::
  =/  scalars
    :~
      [%scalar 'st-low' [%lower literal-hello]]
      [%scalar 'st-upr' [%upper literal-hello]]
      [%scalar 'st-rev' [%reverse literal-hello]]
      [%scalar 'st-lt1' [%ltrim literal-hello ~]]
      [%scalar 'st-lt2' [%ltrim literal-hello `literal-space]]
      [%scalar 'st-rt1' [%rtrim literal-hello ~]]
      [%scalar 'st-rt2' [%rtrim literal-hello `literal-space]]
      [%scalar 'st-pat' [%patindex literal-hello literal-ell]]
      [%scalar 'st-rep' [%replace literal-hello literal-ell literal-ell-up]]
      [%scalar 'st-rpl' [%replicate literal-hello literal-3]]
      [%scalar 'st-qs1' [%quotestring literal-hello ~]]
      [%scalar 'st-qs2' [%quotestring literal-hello `[literal-sq literal-sq]]]
      :+  %scalar
          'st-qs3'
          [%quotestring literal-hello `[literal-open literal-close]]
      [%scalar 'st-str' [%string literal-3]]
      :+  %scalar
          'st-sc1'
          [%string-concat ~[literal-hello literal-world] literal-space]
      [%scalar 'st-stf' [%stuff literal-hello literal-2 literal-3 literal-xx]]
      [%scalar 'loq1' [%lower qualified-col-1]]
      [%scalar 'lou1' [%lower unqualified-foo-3]]
      [%scalar 'los1' [%lower [%scalar-name name=%st-low]]]
    ==
  =/  table
    :*  %qualified-table
      ship=[~ ~sampel-palnet]
      database=%db2
      namespace=%dba
      name=%table1
      alias=[~ 'MyTable']
    ==
  =/  expected  (mk-crud-txn scalars (some table))
  %+  expect-eq
    !>  expected
    !>  (parse:parse(default-database default-db) query-string)
::
::  spaces before and after params
++  test-builtins-12
  =/  query-string
    "FROM ~sampel-palnet.db2.dba.table1 AS MyTable ".
    "SCALARS st-low LOWER(  'hello'  ) ".
    "        st-upr UPPER(  'hello'  ) ".
    "        st-rev REVERSE(  'hello'  ) ".
    "        st-lt1 LTRIM(  'hello'  ) ".
    "        st-lt2 LTRIM(  'hello'  ,  ' '  ) ".
    "        st-rt1 RTRIM(  'hello'  ) ".
    "        st-rt2 RTRIM(  'hello'  ,  ' '  ) ".
    "        st-pat PATINDEX(  'hello'  ,  'ell'  ) ".
    "        st-rep REPLACE(  'hello'  ,  'ell'  ,  'ELL'  ) ".
    "        st-rpl REPLICATE(  'hello'  ,  3  ) ".
    "        st-qs1 QUOTESTRING(  'hello'  ) ".
    "        st-qs2 QUOTESTRING(  'hello'  ,  '\\''  ) ".
    "        st-qs3 QUOTESTRING(  'hello'  ,  '['  ,  ']'  ) ".
    "        st-str STRING(  3  ) ".
    "        st-sc1 STRING-CONCAT(  'hello'  ,  'world'  ,  ' '  ) ".
    "        st-stf STUFF(  'hello'  ,  2  ,  3  ,  'xx'  ) ".
    "        loq1 LOWER(  ~sampel-palnet.db2.dba.table1.bar  ) ".
    "        lou1 LOWER(  foo3  ) ".
    "        los1 LOWER(  st-low  ) ".
    "SELECT foo2,foo3"
  ::
  =/  literal-hello    [p=~.t q='hello']
  =/  literal-world    [p=~.t q='world']
  =/  literal-space    [p=~.t q=' ']
  =/  literal-ell      [p=~.t q='ell']
  =/  literal-ell-up      [p=~.t q='ELL']
  =/  literal-xx       [p=~.t q='xx']
  =/  literal-sq       [p=~.t q='\'']
  =/  literal-open     [p=~.t q='[']
  =/  literal-close    [p=~.t q=']']
  =/  literal-3        [p=~.ud q=3]
  =/  literal-2        [p=~.ud q=2]
  ::
  =/  scalars
    :~
      [%scalar 'st-low' [%lower literal-hello]]
      [%scalar 'st-upr' [%upper literal-hello]]
      [%scalar 'st-rev' [%reverse literal-hello]]
      [%scalar 'st-lt1' [%ltrim literal-hello ~]]
      [%scalar 'st-lt2' [%ltrim literal-hello `literal-space]]
      [%scalar 'st-rt1' [%rtrim literal-hello ~]]
      [%scalar 'st-rt2' [%rtrim literal-hello `literal-space]]
      [%scalar 'st-pat' [%patindex literal-hello literal-ell]]
      [%scalar 'st-rep' [%replace literal-hello literal-ell literal-ell-up]]
      [%scalar 'st-rpl' [%replicate literal-hello literal-3]]
      [%scalar 'st-qs1' [%quotestring literal-hello ~]]
      [%scalar 'st-qs2' [%quotestring literal-hello `[literal-sq literal-sq]]]
      :+  %scalar
          'st-qs3'
          [%quotestring literal-hello `[literal-open literal-close]]
      [%scalar 'st-str' [%string literal-3]]
      :+  %scalar
          'st-sc1'
          [%string-concat ~[literal-hello literal-world] literal-space]
      [%scalar 'st-stf' [%stuff literal-hello literal-2 literal-3 literal-xx]]
      [%scalar 'loq1' [%lower qualified-col-1]]
      [%scalar 'lou1' [%lower unqualified-foo-3]]
      [%scalar 'los1' [%lower [%scalar-name name=%st-low]]]
    ==
  =/  table
    :*  %qualified-table
      ship=[~ ~sampel-palnet]
      database=%db2
      namespace=%dba
      name=%table1
      alias=[~ 'MyTable']
    ==
  =/  expected  (mk-crud-txn scalars (some table))
  %+  expect-eq
    !>  expected
    !>  (parse:parse(default-database default-db) query-string)
::
:: datetime scalar builtins beyond DAY/MONTH/YEAR
++  test-builtins-13
  =/  query-string
    "FROM foo ".
    "SCALARS dt-hour-date HOUR(~2024.10.27..15.30.45) ".
    "        dt-hour-duration HOUR(~d1.h3) ".
    "        dt-minute-date MINUTE(~2024.10.27..15.30.45) ".
    "        dt-minute-duration MINUTE(~h1.m30) ".
    "        dt-second-date SECOND(~2024.10.27..15.30.45) ".
    "        dt-second-duration SECOND(~m1.s45) ".
    "SELECT foo2,foo3"
  ::
  =/  literal-date        [p=~.da q=~2024.10.27..15.30.45]
  =/  literal-dur-hour    [p=~.dr q=~d1.h3]
  =/  literal-dur-minute  [p=~.dr q=~h1.m30]
  =/  literal-dur-second  [p=~.dr q=~m1.s45]
  =/  scalars
    :~
      [%scalar 'dt-hour-date' [%hour literal-date]]
      [%scalar 'dt-hour-duration' [%hour literal-dur-hour]]
      [%scalar 'dt-minute-date' [%minute literal-date]]
      [%scalar 'dt-minute-duration' [%minute literal-dur-minute]]
      [%scalar 'dt-second-date' [%second literal-date]]
      [%scalar 'dt-second-duration' [%second literal-dur-second]]
    ==
  =/  expected  (mk-crud-txn scalars ~)
  %+  expect-eq
    !>  expected
    !>  (parse:parse(default-database default-db) query-string)
::
:: datetime arithmetic scalar builtins
++  test-builtins-14
  =/  query-string
    "FROM foo ".
    "SCALARS dt-add-date ADD-TIME(~2024.10.27,~d1) ".
    "        dt-add-duration ADD-TIME(~d5,~d3) ".
    "        dt-sub-date SUBTRACT-TIME(~2024.10.27,~d1) ".
    "        dt-sub-duration SUBTRACT-TIME(~d10,~d3) ".
    "SELECT foo2,foo3"
  ::
  =/  literal-date  [p=~.da q=~2024.10.27]
  =/  literal-d1    [p=~.dr q=~d1]
  =/  literal-d3    [p=~.dr q=~d3]
  =/  literal-d5    [p=~.dr q=~d5]
  =/  literal-d10   [p=~.dr q=~d10]
  =/  scalars
    :~
      [%scalar 'dt-add-date' [%add-time literal-date literal-d1]]
      [%scalar 'dt-add-duration' [%add-time literal-d5 literal-d3]]
      [%scalar 'dt-sub-date' [%subtract-time literal-date literal-d1]]
      [%scalar 'dt-sub-duration' [%subtract-time literal-d10 literal-d3]]
    ==
  =/  expected  (mk-crud-txn scalars ~)
  %+  expect-eq
    !>  expected
    !>  (parse:parse(default-database default-db) query-string)
::
:: documented @rd literal syntax
++  test-builtins-15
  =/  query-string
    "FROM foo ".
    "SCALARS rd-abs ABS(.~-3.7) ".
    "        rd-round ROUND(.~123.4,-1) ".
    "        rd-max MAX(.~3.5,.~2.1) ".
    "        rd-rand RAND(.~1.5,.~10.8) ".
    "        rd-sign SIGN(.~0.0) ".
    "SELECT foo2,foo3"
  ::
  =/  literal-rd-neg37  [p=~.rd q=.~-3.7]
  =/  literal-rd-1234   [p=~.rd q=.~123.4]
  =/  literal-rd-35     [p=~.rd q=.~3.5]
  =/  literal-rd-21     [p=~.rd q=.~2.1]
  =/  literal-rd-15     [p=~.rd q=.~1.5]
  =/  literal-rd-108    [p=~.rd q=.~10.8]
  =/  literal-rd-zero   [p=~.rd q=.~0.0]
  =/  literal-neg1      [p=~.sd q=-1]
  =/  scalars
    :~
      [%scalar 'rd-abs' [%abs literal-rd-neg37]]
      [%scalar 'rd-round' [%round literal-rd-1234 literal-neg1]]
      [%scalar 'rd-max' [%max literal-rd-35 literal-rd-21]]
      [%scalar 'rd-rand' [%rand literal-rd-15 literal-rd-108]]
      [%scalar 'rd-sign' [%sign literal-rd-zero]]
    ==
  =/  expected  (mk-crud-txn scalars ~)
  %+  expect-eq
    !>  expected
    !>  (parse:parse(default-database default-db) query-string)
::
:: documented bare math constants
++  test-builtins-16
  =/  query-string
    "FROM foo ".
    "SCALARS mt-e E ".
    "        mt-phi PHI ".
    "        mt-pi PI ".
    "        mt-tau TAU ".
    "SELECT foo2,foo3"
  ::
  =/  scalars
    :~
      [%scalar 'mt-e' [%e ~]]
      [%scalar 'mt-phi' [%phi ~]]
      [%scalar 'mt-pi' [%pi ~]]
      [%scalar 'mt-tau' [%tau ~]]
    ==
  =/  expected  (mk-crud-txn scalars ~)
  %+  expect-eq
    !>  expected
    !>  (parse:parse(default-database default-db) query-string)
::
:: variadic string scalar builtins beyond the minimum arity
++  test-builtins-17
  =/  query-string
    "FROM foo ".
    "SCALARS st-concat CONCAT('hello',' ','world') ".
    "        st-string-concat STRING-CONCAT('red','green','blue',',') ".
    "SELECT foo2,foo3"
  ::
  =/  literal-hello  [p=~.t q='hello']
  =/  literal-space  [p=~.t q=' ']
  =/  literal-world  [p=~.t q='world']
  =/  literal-red    [p=~.t q='red']
  =/  literal-green  [p=~.t q='green']
  =/  literal-blue   [p=~.t q='blue']
  =/  literal-comma  [p=~.t q=',']
  =/  scalars
    :~
      [%scalar 'st-concat' [%concat ~[literal-hello literal-space literal-world]]]
      :+  %scalar
          'st-string-concat'
          [%string-concat ~[literal-red literal-green literal-blue] literal-comma]
    ==
  =/  expected  (mk-crud-txn scalars ~)
  %+  expect-eq
    !>  expected
    !>  (parse:parse(default-database default-db) query-string)
::
::  CONCAT requires at least 2 parameters
++  test-fail-concat-01
  =/  query-string
    "FROM foo ".
    "SCALARS foo CONCAT('hello') ".
    "SELECT foo2,foo3"
  ::
  %+  expect-fail-message
    'CONCAT requires at least 2 parameters'
    |.  (parse:parse(default-database default-db) query-string)
::
::  CONCAT with 0 args also requires at least 2 parameters
++  test-fail-concat-02
  =/  query-string
    "FROM foo ".
    "SCALARS foo CONCAT() ".
    "SELECT foo2,foo3"
  ::
  %+  expect-fail-message
    'CONCAT requires at least 2 parameters'
    |.  (parse:parse(default-database default-db) query-string)
::
::  STRING-CONCAT requires at least 3 parameters (1 given)
++  test-fail-string-concat-01
  =/  query-string
    "FROM foo ".
    "SCALARS foo STRING-CONCAT('hello') ".
    "SELECT foo2,foo3"
  ::
  %+  expect-fail-message
    'STRING-CONCAT requires at least 3 parameters'
    |.  (parse:parse(default-database default-db) query-string)
::
::  STRING-CONCAT requires at least 3 parameters (2 given)
++  test-fail-string-concat-02
  =/  query-string
    "FROM foo ".
    "SCALARS foo STRING-CONCAT('hello','world') ".
    "SELECT foo2,foo3"
  ::
  %+  expect-fail-message
    'STRING-CONCAT requires at least 3 parameters'
    |.  (parse:parse(default-database default-db) query-string)
::
::  COALESCE with 0 params requires at least 2 parameters
++  test-fail-coalesce-05
  =/  query-string
    "FROM foo ".
    "SCALARS foo COALESCE() ".
    "SELECT foo2,foo3"
  ::
  %+  expect-fail-message
    'COALESCE requires at least 2 parameters'
    |.  (parse:parse(default-database default-db) query-string)
::
::  wrong param count tests — parser rejects before reaching cook,
::  which is why these produce PARSER errors rather than the cook messages.
::  they serve as regression tests confirming param-count enforcement.
::
::  ATAN2 requires 2 params
++  test-fail-params-01
  =/  query-string
    "FROM foo ".
    "SCALARS foo ATAN2(.5) ".
    "SELECT foo2,foo3"
  ::
  %+  expect-fail-message
    'PARSER: '
    |.  (parse:parse(default-database default-db) query-string)
::
::  LOG requires 1 or 2 params
++  test-fail-params-02
  =/  query-string
    "FROM foo ".
    "SCALARS foo LOG(.5,.2,.1) ".
    "SELECT foo2,foo3"
  ::
  %+  expect-fail-message
    'PARSER: '
    |.  (parse:parse(default-database default-db) query-string)
::
::  TRIM requires 1 or 2 params
++  test-fail-params-03
  =/  query-string
    "FROM foo ".
    "SCALARS foo TRIM('hello','x','y') ".
    "SELECT foo2,foo3"
  ::
  %+  expect-fail-message
    'PARSER: '
    |.  (parse:parse(default-database default-db) query-string)
::
::  ROUND requires 2 params
++  test-fail-params-04
  =/  query-string
    "FROM foo ".
    "SCALARS foo ROUND(42) ".
    "SELECT foo2,foo3"
  ::
  %+  expect-fail-message
    'PARSER: '
    |.  (parse:parse(default-database default-db) query-string)
::
::  LTRIM requires 1 or 2 params
++  test-fail-params-05
  =/  query-string
    "FROM foo ".
    "SCALARS foo LTRIM('hello',' ','x') ".
    "SELECT foo2,foo3"
  ::
  %+  expect-fail-message
    'PARSER: '
    |.  (parse:parse(default-database default-db) query-string)
::
::  RTRIM requires 1 or 2 params
++  test-fail-params-06
  =/  query-string
    "FROM foo ".
    "SCALARS foo RTRIM('hello',' ','x') ".
    "SELECT foo2,foo3"
  ::
  %+  expect-fail-message
    'PARSER: '
    |.  (parse:parse(default-database default-db) query-string)
::
::  PATINDEX requires 2 params
++  test-fail-params-07
  =/  query-string
    "FROM foo ".
    "SCALARS foo PATINDEX('hello') ".
    "SELECT foo2,foo3"
  ::
  %+  expect-fail-message
    'PARSER: '
    |.  (parse:parse(default-database default-db) query-string)
::
::  REPLACE requires 3 params
++  test-fail-params-08
  =/  query-string
    "FROM foo ".
    "SCALARS foo REPLACE('hello','ll') ".
    "SELECT foo2,foo3"
  ::
  %+  expect-fail-message
    'PARSER: '
    |.  (parse:parse(default-database default-db) query-string)
::
::  REPLICATE requires 2 params
++  test-fail-params-09
  =/  query-string
    "FROM foo ".
    "SCALARS foo REPLICATE('hello') ".
    "SELECT foo2,foo3"
  ::
  %+  expect-fail-message
    'PARSER: '
    |.  (parse:parse(default-database default-db) query-string)
::
::  STUFF requires 4 params
++  test-fail-params-10
  =/  query-string
    "FROM foo ".
    "SCALARS foo STUFF('hello',2,3) ".
    "SELECT foo2,foo3"
  ::
  %+  expect-fail-message
    'PARSER: '
    |.  (parse:parse(default-database default-db) query-string)
::
::  QUOTESTRING requires 1, 2, or 3 params
++  test-fail-params-11
  =/  query-string
    "FROM foo ".
    "SCALARS foo QUOTESTRING('hello','[',']','extra') ".
    "SELECT foo2,foo3"
  ::
  %+  expect-fail-message
    'PARSER: '
    |.  (parse:parse(default-database default-db) query-string)
::  SUBSTRING requires 1 param only
++  test-fail-params-12
  =/  query-string
    "FROM foo ".
    "SCALARS foo SUBSTRING('hello') ".
    "SELECT foo2,foo3"
  ::
  %+  expect-fail-message
    'PARSER: '
    |.  (parse:parse(default-database default-db) query-string)
::
::  SUBSTRING without length (2-param)
++  test-builtins-substring
  =/  query-string
    "FROM foo ".
    "SCALARS st4 SUBSTRING('hello',2) ".
    "SELECT foo2,foo3"
  ::
  =/  literal-hello  [p=~.t q='hello']
  =/  literal-2      [p=~.ud q=2]
  =/  scalars
    :~
      [%scalar 'st4' [%substring literal-hello literal-2 ~]]
    ==
  =/  expected  (mk-crud-txn scalars ~)
  %+  expect-eq
    !>  expected
    !>  (parse:parse(default-database default-db) query-string)
::
::  nested scalar-node builtin params
++  test-builtins-nested-scalar-nodes
  =/  query-string
    "FROM foo ".
    "SCALARS mt-log LOG(ABS(-5),MAX(1,2)) ".
    "        st-sub SUBSTRING(CASE WHEN 1 = 1 THEN LOWER('hello') ELSE UPPER('world') END,COALESCE(1,2),IF 1 = 1 THEN ABS(3) ELSE ABS(2) ENDIF) ".
    "        st-sc1 STRING-CONCAT(LOWER('hello'),UPPER('world'),CASE WHEN 1 = 1 THEN ' ' ELSE '-' END) ".
    "        st-stf STUFF(LOWER('hello'),COALESCE(2,3),IF 1 = 1 THEN 3 ELSE 2 ENDIF,UPPER('xx')) ".
    "SELECT foo2,foo3"
  ::
  =/  literal-neg5      [p=~.sd q=-5]
  =/  literal-1         [p=~.ud q=1]
  =/  literal-2         [p=~.ud q=2]
  =/  literal-3         [p=~.ud q=3]
  =/  literal-hello     [p=~.t q='hello']
  =/  literal-world     [p=~.t q='world']
  =/  literal-space     [p=~.t q=' ']
  =/  literal-dash      [p=~.t q='-']
  =/  literal-xx        [p=~.t q='xx']
  =/  substring-case
    :*
      %case
      target=~
      cases=~[[%case-when-then simple-true-pred [%lower literal-hello]]]
      else=(some [%upper literal-world])
    ==
  =/  substring-start
    [%coalesce ~[literal-1 literal-2]]
  =/  substring-length
    :*
      %if-then-else
      if=simple-true-pred
      then=[%abs literal-3]
      else=[%abs literal-2]
    ==
  =/  string-concat-delim
    :*
      %case
      target=~
      cases=~[[%case-when-then simple-true-pred literal-space]]
      else=(some literal-dash)
    ==
  =/  stuff-start
    [%coalesce ~[literal-2 literal-3]]
  =/  stuff-length
    :*
      %if-then-else
      if=simple-true-pred
      then=literal-3
      else=literal-2
    ==
  =/  scalars
    :~
      [%scalar 'mt-log' [%log [%abs literal-neg5] `[%max literal-1 literal-2]]]
      [%scalar 'st-sub' [%substring substring-case substring-start `substring-length]]
      :+  %scalar
          'st-sc1'
          [%string-concat ~[[%lower literal-hello] [%upper literal-world]] string-concat-delim]
      [%scalar 'st-stf' [%stuff [%lower literal-hello] stuff-start stuff-length [%upper literal-xx]]]
    ==
  =/  expected  (mk-crud-txn scalars ~)
  %+  expect-eq
    !>  expected
    !>  (parse:parse(default-database default-db) query-string)
::
:: @da literals in IF, CASE, and function arguments,
:: leading zeros and no leading zeros
++  test-scalars-da-00
  =/  date-1       [p=~.da q=~2024.1.5]
  =/  date-2       [p=~.da q=~2024.2.6]
  =/  date-time-1  [p=~.da q=~2024.1.5..7.5.9]
  =/  literal-d1   [p=~.dr q=~d1]
  =/  if-scalar
    [%if-then-else if=simple-true-pred then=date-1 else=date-2]
  =/  case-scalar
    :*  %case
        (some unqualified-foo-3)
        ~[[%case-when-then date-1 date-time-1]]
        (some date-2)
        ==
  =/  scalars
    :~  [%scalar 'sc1' if-scalar]
        [%scalar 'sc2' case-scalar]
        [%scalar 'sc3' [%add-time date-time-1 literal-d1]]
        [%scalar 'sc4' [%hour date-time-1]]
        ==
  =/  expected  (mk-crud-txn scalars ~)
  %+  expect-eq
    !>  (weld expected expected)
    !>  %-  parse:parse(default-database default-db)
        "FROM foo ".
        "SCALARS sc1 IF 1 = 1 THEN ~2024.01.05 ELSE ~2024.02.06 ENDIF ".
        "        sc2 CASE foo3 WHEN ~2024.01.05 ".
        "              THEN ~2024.01.05..07.05.09 ELSE ~2024.02.06 END ".
        "        sc3 ADD-TIME(~2024.01.05..07.05.09,~d1) ".
        "        sc4 HOUR(~2024.01.05..07.05.09) ".
        "SELECT foo2,foo3; ".
        "FROM foo ".
        "SCALARS sc1 IF 1 = 1 THEN ~2024.1.5 ELSE ~2024.2.6 ENDIF ".
        "        sc2 CASE foo3 WHEN ~2024.1.5 ".
        "              THEN ~2024.1.5..7.5.9 ELSE ~2024.2.6 END ".
        "        sc3 ADD-TIME(~2024.1.5..7.5.9,~d1) ".
        "        sc4 HOUR(~2024.1.5..7.5.9) ".
        "SELECT foo2,foo3"
::
::  ::::::::::::::::::::::::::::::::::::::::::::::::::
::  ::::  inline scalars: functions outside SCALARS  ::::
::  ::::::::::::::::::::::::::::::::::::::::::::::::::
::
::  each inline invocation becomes a generated scalar, appended to the
::  query's scalars, named inline.<index in that list>; an unaliased
::  SELECT item is named scalar-<position>
::
++  relation-inl
  :*  %qualified-table
      ship=~
      database=%db1
      namespace=%dbo
      name=%inl
      alias=~
      ==
++  u-id    [%unqualified-column name=%id alias=~]
++  u-nud   [%unqualified-column name=%nud alias=~]
++  u-nsd   [%unqualified-column name=%nsd alias=~]
++  u-nrd   [%unqualified-column name=%nrd alias=~]
++  u-nrd2  [%unqualified-column name=%nrd2 alias=~]
++  u-nu    [%unqualified-column name=%nu alias=~]
++  u-t     [%unqualified-column name=%t alias=~]
++  u-tpad  [%unqualified-column name=%tpad alias=~]
++  u-d     [%unqualified-column name=%d alias=~]
++  u-dr    [%unqualified-column name=%dr alias=~]
::
++  inline-name
  |=  i=@ud
  ^-  @tas
  (@tas (crip "inline.{<i>}"))
::
++  inline-ref
  |=  i=@ud
  ^-  scalar-name:ast
  [%scalar-name (inline-name i)]
::
++  inline-col
  ::  selected inline scalar i at SELECT position pos, unaliased
  |=  [i=@ud pos=@ud]
  ^-  selected-scalar:ast
  [%selected-scalar (inline-name i) `(crip "scalar-{<pos>}")]
::
++  mk-inl-where
  ::  FROM inl query with scalars, predicate and selected columns
  |=  $:  scalars=(list scalar:ast)
          =predicate:ast
          columns=(list selected-column:ast)
          ==
  ^-  (list command:ast)
  =/  from  [%from relation-id=relation-inl as-of=~ joins=~]
  =/  query
    :*  %query
        from=[~ from]
        scalars=scalars
        predicate=predicate
        group-by=~
        having=~
        select=[%select top=~ columns=columns]
        ~
        ==
  ~[[%crud-txn ctes=~ body=[%query query]]]
::
++  inl-col
  |=  name=@tas
  ^-  qualified-column:ast
  [%qualified-column relation-inl name ~]
::
++  nud-gt-6  [%gt [u-nud ~ ~] [[~.ud 6] ~ ~]]
++  one-eq-2  [%eq [[~.ud 1] ~ ~] [[~.ud 2] ~ ~]]
::
++  case-simple-lit
  :*  %case
      `[~.ud 2]
      :~  [%case-when-then [~.ud 1] [~.t 'one']]
          [%case-when-then [~.ud 2] [~.t 'two']]
          ==
      `[~.t 'other']
      ==
++  case-simple-col
  :*  %case
      `u-nud
      ~[[%case-when-then [~.ud 5] [~.t 'five']]]
      `[~.t 'other']
      ==
++  case-searched-lit
  :*  %case
      ~
      :~  [%case-when-then one-eq-2 [~.t 'a']]
          [%case-when-then simple-true-pred [~.t 'b']]
          ==
      ~
      ==
++  case-searched-col
  :*  %case
      ~
      ~[[%case-when-then nud-gt-6 [~.t 'big']]]
      `[~.t 'small']
      ==
::
::  edge cases
::
::  AS alias on an inline scalar
++  test-inline-select-alias
  =/  scalars  ~[[%scalar (inline-name 0) [%abs [~.sd -1]]]]
  =/  columns  ~[[%selected-scalar (inline-name 0) `'answer']]
  %+  expect-eq
    !>  (mk-crud-txn-no-from-columns scalars columns)
    !>  %-  parse:parse(default-database default-db)
            "SELECT ABS(-1) AS answer"
::
::  keywords and function names are case agnostic
++  test-inline-select-lowercase
  =/  scalars  ~[[%scalar (inline-name 0) [%abs [~.sd -1]]]]
  =/  columns  ~[[%selected-scalar (inline-name 0) `'a']]
  %+  expect-eq
    !>  (mk-crud-txn-no-from-columns scalars columns)
    !>  %-  parse:parse(default-database default-db)
            "select abs(-1) as a"
::
::  unaliased inline scalars are named by SELECT position, as literals are
++  test-inline-select-positions
  =/  scalars
    :~  [%scalar (inline-name 0) [%abs [~.sd -1]]]
        [%scalar (inline-name 1) [%pi ~]]
        ==
  =/  columns
    :~  [%selected-value [~.ud 1] ~]
        (inline-col 0 1)
        [%selected-value [~.t 'x'] `'t']
        (inline-col 1 3)
        ==
  %+  expect-eq
    !>  (mk-crud-txn-no-from-columns scalars columns)
    !>  %-  parse:parse(default-database default-db)
            "SELECT 1, ABS(-1), 'x' AS t, PI()"
::
::  inline scalars follow SCALARS definitions and may reference them
++  test-inline-select-with-scalars
  =/  scalars
    :~  [%scalar 'sc1' [%abs [~.sd -5]]]
        [%scalar (inline-name 1) [%abs [%scalar-name 'sc1']]]
        ==
  =/  columns
    :~  [%selected-scalar 'sc1' ~]
        (inline-col 1 1)
        ==
  %+  expect-eq
    !>  (mk-crud-txn-no-from-columns scalars columns)
    !>  %-  parse:parse(default-database default-db)
            "SCALARS sc1 ABS(-5) SELECT sc1, ABS(sc1)"
::
::  nested functions are one inline scalar
++  test-inline-select-nested
  =/  scalars  ~[[%scalar (inline-name 0) [%len [%trim [~.t '  a  '] ~]]]]
  %+  expect-eq
    !>  (mk-crud-txn-no-from-columns scalars ~[(inline-col 0 0)])
    !>  %-  parse:parse(default-database default-db)
            "SELECT LEN(TRIM('  a  '))"
::
::  a function leading an arithmetic expression is an operand
++  test-inline-select-fn-arithmetic
  =/  f  [%arithmetic %lus [%abs [~.sd -5]] [~.sd --1]]
  =/  scalars  ~[[%scalar (inline-name 0) f]]
  %+  expect-eq
    !>  (mk-crud-txn-no-from-columns scalars ~[(inline-col 0 0)])
    !>  %-  parse:parse(default-database default-db)
            "SELECT ABS(-5) + --1"
::
::  IF leading an arithmetic expression is an operand
++  test-inline-select-if-arithmetic
  =/  if  [%if-then-else simple-true-pred [~.ud 1] [~.ud 0]]
  =/  scalars  ~[[%scalar (inline-name 0) [%arithmetic %lus if [~.ud 1]]]]
  %+  expect-eq
    !>  (mk-crud-txn-no-from-columns scalars ~[(inline-col 0 0)])
    !>  %-  parse:parse(default-database default-db)
            "SELECT IF 1 = 1 THEN 1 ELSE 0 ENDIF + 1"
::
::  a bare constant is an arithmetic operand, also at end of input
++  test-inline-select-bare-constant
  =/  f  [%arithmetic %tar [~.rd .~2] [%pi ~]]
  =/  scalars  ~[[%scalar (inline-name 0) f]]
  %+  expect-eq
    !>  (mk-crud-txn-no-from-columns scalars ~[(inline-col 0 0)])
    !>  %-  parse:parse(default-database default-db)
            "SELECT .~2 * PI"
::
::  arithmetic without whitespace around an operator after a column
++  test-inline-where-no-whitespace
  =/  scalars  ~[[%scalar (inline-name 0) [%arithmetic %tar u-nud [~.ud 2]]]]
  =/  pred  [%eq [(inline-ref 0) ~ ~] [[~.ud 10] ~ ~]]
  %+  expect-eq
    !>  (mk-inl-where scalars pred ~[u-id])
    !>  %-  parse:parse(default-database default-db)
            "FROM inl WHERE nud*2 = 10 SELECT id"
::
::  each RAND is a separate scalar, evaluated separately
++  test-inline-select-rand-twice
  =/  f  [%rand [~.ud 1] [~.ud 10]]
  =/  scalars
    :~  [%scalar (inline-name 0) f]
        [%scalar (inline-name 1) f]
        ==
  %+  expect-eq
    !>  %+  mk-crud-txn-no-from-columns
          scalars
        ~[(inline-col 0 0) (inline-col 1 1)]
    !>  %-  parse:parse(default-database default-db)
            "SELECT RAND(1, 10), RAND(1, 10)"
::
++  test-inline-select-getutcdate-twice
  =/  scalars
    :~  [%scalar (inline-name 0) [%getutcdate ~]]
        [%scalar (inline-name 1) [%getutcdate ~]]
        ==
  %+  expect-eq
    !>  %+  mk-crud-txn-no-from-columns
          scalars
        ~[(inline-col 0 0) (inline-col 1 1)]
    !>  %-  parse:parse(default-database default-db)
            "SELECT GETUTCDATE(), GETUTCDATE()"
::
::  names that begin like functions or constants remain columns
++  test-inline-columns-like-functions
  =/  pred
    :+  %and
        :+  %and
            [%eq [[%unqualified-column 'ifx' ~] ~ ~] [[~.ud 1] ~ ~]]
            [%eq [[%unqualified-column 'casey' ~] ~ ~] [[~.ud 2] ~ ~]]
        [%eq [[%unqualified-column 'abs' ~] ~ ~] [[~.ud 3] ~ ~]]
  =/  columns
    :~  [%unqualified-column 'e' ~]
        [%unqualified-column 'pi' ~]
        ==
  %+  expect-eq
    !>  (mk-inl-where ~ pred columns)
    !>  %-  parse:parse(default-database default-db)
            "FROM inl WHERE ifx = 1 AND casey = 2 AND abs = 3 SELECT e, pi"
::
::  keyword operators read as @uw literals; one followed by % must not
::  start an arithmetic operand
++  test-inline-where-keyword-before-term
  =/  pred
    :+  %or
        :+  %and
            [%eq [[%ta ~.a.b] ~ ~] [[%unqualified-column 'path' ~] ~ ~]]
            [%eq [[%tas %x] ~ ~] [[%unqualified-column 'term' ~] ~ ~]]
        [%eq [[%sd -1] ~ ~] [[%unqualified-column 'nsd' ~] ~ ~]]
  %+  expect-eq
    !>  (mk-inl-where ~ pred ~[[%all %all]])
    !>  %-  parse:parse(default-database default-db)
            "FROM inl WHERE ~.a.b=path AND %x=term OR -1 = nsd SELECT *"
::
::  a function starting with AS does not end the predicate
++  test-inline-where-as-prefix
  =/  scalars  ~[[%scalar (inline-name 0) [%asin u-nu]]]
  =/  pred  [%eq [(inline-ref 0) ~ ~] [[~.rd .~0] ~ ~]]
  %+  expect-eq
    !>  (mk-inl-where scalars pred ~[u-id])
    !>  %-  parse:parse(default-database default-db)
            "FROM inl WHERE ASIN(nu) = .~0 SELECT id"
::
::  inline scalars on both sides of a predicate and in SELECT, numbered in
::  order of appearance
++  test-inline-where-both-sides
  =/  scalars
    :~  :+  %scalar
            (inline-name 0)
            [%arithmetic %lus [%len u-t] [~.ud 4]]
        [%scalar (inline-name 1) [%len u-tpad]]
        [%scalar (inline-name 2) [%upper u-t]]
        ==
  =/  pred  [%eq [(inline-ref 0) ~ ~] [(inline-ref 1) ~ ~]]
  %+  expect-eq
    !>  (mk-inl-where scalars pred ~[(inline-col 2 0)])
    !>  %-  parse:parse(default-database default-db)
            "FROM inl WHERE LEN(t) + 4 = LEN(tpad) SELECT UPPER(t)"
::
::  inline scalars inside parenthesized predicate groups
++  test-inline-where-grouping
  =/  scalars  ~[[%scalar (inline-name 0) [%len u-t]]]
  =/  pred
    :+  %and
        :+  %or
            [%eq [(inline-ref 0) ~ ~] [[~.ud 5] ~ ~]]
            [%eq [u-nud ~ ~] [[~.ud 9] ~ ~]]
        [%lt [u-id ~ ~] [[~.ud 2] ~ ~]]
  %+  expect-eq
    !>  (mk-inl-where scalars pred ~[u-id])
    !>  %-  parse:parse(default-database default-db)
            "FROM inl WHERE (LEN(t) = 5 OR nud = 9) AND id < 2 SELECT id"
::
++  test-inline-where-in
  =/  scalars  ~[[%scalar (inline-name 0) [%len u-tpad]]]
  =/  pred  [%in [(inline-ref 0) ~ ~] [[%value-literals %ud '7;3'] ~ ~]]
  %+  expect-eq
    !>  (mk-inl-where scalars pred ~[u-id])
    !>  %-  parse:parse(default-database default-db)
            "FROM inl WHERE LEN(tpad) IN (3,7) SELECT id"
::
++  test-inline-where-between
  =/  scalars
    :~  [%scalar (inline-name 0) [%len u-t]]
        [%scalar (inline-name 1) [%len u-tpad]]
        ==
  =/  pred
    :+  %between
        [%gte [u-nud ~ ~] [(inline-ref 0) ~ ~]]
        [%lte [u-nud ~ ~] [(inline-ref 1) ~ ~]]
  %+  expect-eq
    !>  (mk-inl-where scalars pred ~[u-id])
    !>  %-  parse:parse(default-database default-db)
            "FROM inl WHERE nud BETWEEN LEN(t) AND LEN(tpad) SELECT id"
::
++  test-inline-where-not
  =/  scalars  ~[[%scalar (inline-name 0) [%upper u-t]]]
  =/  pred  [%not [%eq [(inline-ref 0) ~ ~] [[~.t 'HELLO'] ~ ~]] ~]
  %+  expect-eq
    !>  (mk-inl-where scalars pred ~[u-id])
    !>  %-  parse:parse(default-database default-db)
            "FROM inl WHERE NOT UPPER(t) = 'HELLO' SELECT id"
::
::  an inline scalar in an inline IF predicate is defined first
++  test-inline-where-nested-if
  =/  if
    :^  %if-then-else
        [%gt [(inline-ref 0) ~ ~] [[~.ud 4] ~ ~]]
        [~.ud 1]
        [~.ud 0]
  =/  scalars
    :~  [%scalar (inline-name 0) [%len u-tpad]]
        [%scalar (inline-name 1) if]
        ==
  =/  pred  [%eq [(inline-ref 1) ~ ~] [[~.ud 1] ~ ~]]
  %+  expect-eq
    !>  (mk-inl-where scalars pred ~[u-id])
    !>  %-  parse:parse(default-database default-db)
            "FROM inl WHERE IF LEN(tpad) > 4 THEN 1 ELSE 0 ENDIF = 1 ".
            "SELECT id"
::
::  an inline scalar may reference a SCALARS definition
++  test-inline-where-references-scalar
  =/  scalars
    :~  [%scalar 's1' [%arithmetic %lus u-nud [~.ud 1]]]
        [%scalar (inline-name 1) [%abs [%scalar-name 's1']]]
        ==
  =/  pred  [%eq [(inline-ref 1) ~ ~] [[~.ud 6] ~ ~]]
  %+  expect-eq
    !>  (mk-inl-where scalars pred ~[u-id])
    !>  %-  parse:parse(default-database default-db)
            "FROM inl SCALARS s1 nud + 1 END WHERE ABS(s1) = 6 SELECT id"
::
::  an inline scalar in a SCALARS IF predicate is defined before it
++  test-inline-in-scalars-if
  =/  if
    :^  %if-then-else
        [%gt [(inline-ref 0) ~ ~] [[~.ud 4] ~ ~]]
        [~.t 'long']
        [~.t 'short']
  =/  scalars
    :~  [%scalar (inline-name 0) [%len u-tpad]]
        [%scalar 's1' if]
        ==
  =/  columns  ~[u-id [%selected-scalar 's1' ~]]
  %+  expect-eq
    !>  (mk-inl-where scalars ~ columns)
    !>  %-  parse:parse(default-database default-db)
            "FROM inl SCALARS s1 IF LEN(tpad) > 4 THEN 'long' ELSE 'short' ".
            "ENDIF SELECT id, s1"
::
::  an inline scalar in a SCALARS searched CASE predicate
++  test-inline-in-scalars-case
  =/  case
    :*  %case
        ~
        :~  :+  %case-when-then
                [%eq [(inline-ref 0) ~ ~] [[~.t 'HELLO'] ~ ~]]
                [~.ud 1]
            ==
        `[~.ud 0]
        ==
  =/  scalars
    :~  [%scalar (inline-name 0) [%upper u-t]]
        [%scalar 's1' case]
        ==
  =/  columns  ~[u-id [%selected-scalar 's1' ~]]
  %+  expect-eq
    !>  (mk-inl-where scalars ~ columns)
    !>  %-  parse:parse(default-database default-db)
            "FROM inl SCALARS s1 CASE WHEN UPPER(t) = 'HELLO' THEN 1 ".
            "ELSE 0 END SELECT id, s1"
::
++  test-inline-select-top
  =/  scalars  ~[[%scalar (inline-name 0) [%abs u-nsd]]]
  =/  query
    :*  %query
        from=[~ [%from relation-id=relation-inl as-of=~ joins=~]]
        scalars=scalars
        predicate=~
        group-by=~
        having=~
        select=[%select top=[~ 2] columns=~[(inline-col 0 0)]]
        ~
        ==
  %+  expect-eq
    !>  ~[[%crud-txn ctes=~ body=[%query query]]]
    !>  %-  parse:parse(default-database default-db)
            "FROM inl SELECT TOP 2 ABS(nsd)"
::
::  UPDATE SET values and WHERE; SET lists are produced last to first
++  test-inline-update
  =/  scalars
    :~  [%scalar (inline-name 0) [%arithmetic %lus u-nud [~.ud 1]]]
        [%scalar (inline-name 1) [%upper u-t]]
        [%scalar (inline-name 2) [%len u-tpad]]
        ==
  =/  pred  [%eq [(inline-ref 2) ~ ~] [[~.ud 9] ~ ~]]
  =/  expected
    :*  %crud-txn
        ctes=~
        :-  %update
        :*  %update
            scalars=scalars
            table=relation-inl
            as-of=~
            :-  columns=~[(inl-col %t) (inl-col %nud)]
                values=~[(inline-ref 1) (inline-ref 0)]
            predicate=pred
            ==
        ==
  %+  expect-eq
    !>  ~[expected]
    !>  %-  parse:parse(default-database default-db)
            "UPDATE inl SET nud = nud + 1, t = UPPER(t) WHERE LEN(tpad) = 9"
::
++  test-inline-delete
  =/  scalars  ~[[%scalar (inline-name 0) [%abs u-nsd]]]
  =/  pred  [%eq [(inline-ref 0) ~ ~] [[~.sd --1] ~ ~]]
  =/  expected
    :*  %crud-txn
        ctes=~
        [%delete [%delete scalars=scalars table=relation-inl ~ pred]]
        ==
  %+  expect-eq
    !>  ~[expected]
    !>  %-  parse:parse(default-database default-db)
            "DELETE FROM inl WHERE ABS(nsd) = --1"
::
::  an unaliased inline scalar is a CTE column named by position
++  test-inline-cte
  =/  cte-query
    :*  %query
        from=[~ [%from relation-id=relation-inl as-of=~ joins=~]]
        scalars=~[[%scalar (inline-name 0) [%len u-tpad]]]
        predicate=~
        group-by=~
        having=~
        select=[%select top=~ columns=~[u-id (inline-col 0 1)]]
        ~
        ==
  =/  outer-query
    :*  %query
        from=[~ [%from relation-id=[%cte-name 'c' ~] as-of=~ joins=~]]
        scalars=~
        predicate=~
        group-by=~
        having=~
        :+  %select
            top=~
            columns=~[[%unqualified-column 'scalar-1' ~]]
        ~
        ==
  =/  ctes  ~[[%cte name='c' body=[%query cte-query]]]
  %+  expect-eq
    !>  ~[[%crud-txn ctes=ctes body=[%query outer-query]]]
    !>  %-  parse:parse(default-database default-db)
            "WITH (FROM inl SELECT id, LEN(tpad)) AS c FROM c SELECT scalar-1"
::
::  JOIN ON predicates do not support scalar functions
++  test-fail-inline-join-on
  %+  expect-fail-message
    'scalar functions are not supported in this predicate'
    |.  %-  parse:parse(default-database default-db)
            "FROM inl AS T1 JOIN inl AS T2 ON ABS(T1.nsd) = T2.nsd ".
            "SELECT T1.id"
::
::  an operator needs a following operand
++  test-fail-inline-arithmetic-incomplete
  %+  expect-fail-message
    'PARSER: '
    |.  %-  parse:parse(default-database default-db)
            "SELECT 1 +"
::
::  generated: each function in SELECT with literal arguments and in WHERE
::  with column arguments
::
++  test-inline-select-abs
  =/  f  [%abs [~.sd -1]]
  =/  scalars  ~[[%scalar (inline-name 0) f]]
  %+  expect-eq
    !>  (mk-crud-txn-no-from-columns scalars ~[(inline-col 0 0)])
    !>  %-  parse:parse(default-database default-db)
            "SELECT ABS(-1)"
::
++  test-inline-where-abs
  =/  f  [%abs u-nsd]
  =/  scalars  ~[[%scalar (inline-name 0) f]]
  =/  pred  [%eq [(inline-ref 0) ~ ~] [[~.sd --1] ~ ~]]
  %+  expect-eq
    !>  (mk-inl-where scalars pred ~[u-id])
    !>  %-  parse:parse(default-database default-db)
            "FROM inl WHERE ABS(nsd) = --1 SELECT id"
::
++  test-inline-select-sign
  =/  f  [%sign [~.sd -1]]
  =/  scalars  ~[[%scalar (inline-name 0) f]]
  %+  expect-eq
    !>  (mk-crud-txn-no-from-columns scalars ~[(inline-col 0 0)])
    !>  %-  parse:parse(default-database default-db)
            "SELECT SIGN(-1)"
::
++  test-inline-where-sign
  =/  f  [%sign u-nsd]
  =/  scalars  ~[[%scalar (inline-name 0) f]]
  =/  pred  [%eq [(inline-ref 0) ~ ~] [[~.sd -1] ~ ~]]
  %+  expect-eq
    !>  (mk-inl-where scalars pred ~[u-id])
    !>  %-  parse:parse(default-database default-db)
            "FROM inl WHERE SIGN(nsd) = -1 SELECT id"
::
++  test-inline-select-sqrt
  =/  f  [%sqrt [~.rd .~4]]
  =/  scalars  ~[[%scalar (inline-name 0) f]]
  %+  expect-eq
    !>  (mk-crud-txn-no-from-columns scalars ~[(inline-col 0 0)])
    !>  %-  parse:parse(default-database default-db)
            "SELECT SQRT(.~4)"
::
++  test-inline-where-sqrt
  =/  f  [%sqrt u-nrd]
  =/  scalars  ~[[%scalar (inline-name 0) f]]
  =/  pred  [%eq [(inline-ref 0) ~ ~] [[~.rd .~2] ~ ~]]
  %+  expect-eq
    !>  (mk-inl-where scalars pred ~[u-id])
    !>  %-  parse:parse(default-database default-db)
            "FROM inl WHERE SQRT(nrd) = .~2 SELECT id"
::
++  test-inline-select-floor
  =/  f  [%floor [~.rd .~1.5]]
  =/  scalars  ~[[%scalar (inline-name 0) f]]
  %+  expect-eq
    !>  (mk-crud-txn-no-from-columns scalars ~[(inline-col 0 0)])
    !>  %-  parse:parse(default-database default-db)
            "SELECT FLOOR(.~1.5)"
::
++  test-inline-where-floor
  =/  f  [%floor u-nrd2]
  =/  scalars  ~[[%scalar (inline-name 0) f]]
  =/  pred  [%eq [(inline-ref 0) ~ ~] [[~.rd .~1] ~ ~]]
  %+  expect-eq
    !>  (mk-inl-where scalars pred ~[u-id])
    !>  %-  parse:parse(default-database default-db)
            "FROM inl WHERE FLOOR(nrd2) = .~1 SELECT id"
::
++  test-inline-select-ceiling
  =/  f  [%ceiling [~.rd .~1.5]]
  =/  scalars  ~[[%scalar (inline-name 0) f]]
  %+  expect-eq
    !>  (mk-crud-txn-no-from-columns scalars ~[(inline-col 0 0)])
    !>  %-  parse:parse(default-database default-db)
            "SELECT CEILING(.~1.5)"
::
++  test-inline-where-ceiling
  =/  f  [%ceiling u-nrd2]
  =/  scalars  ~[[%scalar (inline-name 0) f]]
  =/  pred  [%eq [(inline-ref 0) ~ ~] [[~.rd .~2] ~ ~]]
  %+  expect-eq
    !>  (mk-inl-where scalars pred ~[u-id])
    !>  %-  parse:parse(default-database default-db)
            "FROM inl WHERE CEILING(nrd2) = .~2 SELECT id"
::
++  test-inline-select-round
  =/  f  [%round [~.rd .~1.5] [~.ud 0]]
  =/  scalars  ~[[%scalar (inline-name 0) f]]
  %+  expect-eq
    !>  (mk-crud-txn-no-from-columns scalars ~[(inline-col 0 0)])
    !>  %-  parse:parse(default-database default-db)
            "SELECT ROUND(.~1.5, 0)"
::
++  test-inline-where-round
  =/  f  [%round u-nrd2 [~.ud 0]]
  =/  scalars  ~[[%scalar (inline-name 0) f]]
  =/  pred  [%eq [(inline-ref 0) ~ ~] [[~.rd .~2] ~ ~]]
  %+  expect-eq
    !>  (mk-inl-where scalars pred ~[u-id])
    !>  %-  parse:parse(default-database default-db)
            "FROM inl WHERE ROUND(nrd2, 0) = .~2 SELECT id"
::
++  test-inline-select-max
  =/  f  [%max [~.rd .~1] [~.rd .~2]]
  =/  scalars  ~[[%scalar (inline-name 0) f]]
  %+  expect-eq
    !>  (mk-crud-txn-no-from-columns scalars ~[(inline-col 0 0)])
    !>  %-  parse:parse(default-database default-db)
            "SELECT MAX(.~1, .~2)"
::
++  test-inline-where-max
  =/  f  [%max u-nrd [~.rd .~2]]
  =/  scalars  ~[[%scalar (inline-name 0) f]]
  =/  pred  [%eq [(inline-ref 0) ~ ~] [[~.rd .~2] ~ ~]]
  %+  expect-eq
    !>  (mk-inl-where scalars pred ~[u-id])
    !>  %-  parse:parse(default-database default-db)
            "FROM inl WHERE MAX(nrd, .~2) = .~2 SELECT id"
::
++  test-inline-select-min
  =/  f  [%min [~.rd .~1] [~.rd .~2]]
  =/  scalars  ~[[%scalar (inline-name 0) f]]
  %+  expect-eq
    !>  (mk-crud-txn-no-from-columns scalars ~[(inline-col 0 0)])
    !>  %-  parse:parse(default-database default-db)
            "SELECT MIN(.~1, .~2)"
::
++  test-inline-where-min
  =/  f  [%min u-nrd [~.rd .~2]]
  =/  scalars  ~[[%scalar (inline-name 0) f]]
  =/  pred  [%eq [(inline-ref 0) ~ ~] [[~.rd .~1] ~ ~]]
  %+  expect-eq
    !>  (mk-inl-where scalars pred ~[u-id])
    !>  %-  parse:parse(default-database default-db)
            "FROM inl WHERE MIN(nrd, .~2) = .~1 SELECT id"
::
++  test-inline-select-log
  =/  f  [%log [~.rd .~1] ~]
  =/  scalars  ~[[%scalar (inline-name 0) f]]
  %+  expect-eq
    !>  (mk-crud-txn-no-from-columns scalars ~[(inline-col 0 0)])
    !>  %-  parse:parse(default-database default-db)
            "SELECT LOG(.~1)"
::
++  test-inline-where-log
  =/  f  [%log u-nrd ~]
  =/  scalars  ~[[%scalar (inline-name 0) f]]
  =/  pred  [%eq [(inline-ref 0) ~ ~] [[~.rd .~0] ~ ~]]
  %+  expect-eq
    !>  (mk-inl-where scalars pred ~[u-id])
    !>  %-  parse:parse(default-database default-db)
            "FROM inl WHERE LOG(nrd) = .~0 SELECT id"
::
++  test-inline-select-sin
  =/  f  [%sin [~.rd .~1]]
  =/  scalars  ~[[%scalar (inline-name 0) f]]
  %+  expect-eq
    !>  (mk-crud-txn-no-from-columns scalars ~[(inline-col 0 0)])
    !>  %-  parse:parse(default-database default-db)
            "SELECT SIN(.~1)"
::
++  test-inline-where-sin
  =/  f  [%sin u-nrd]
  =/  scalars  ~[[%scalar (inline-name 0) f]]
  =/  pred  [%eq [(inline-ref 0) ~ ~] [[~.rd .~0.84147098480789606] ~ ~]]
  %+  expect-eq
    !>  (mk-inl-where scalars pred ~[u-id])
    !>  %-  parse:parse(default-database default-db)
            "FROM inl WHERE SIN(nrd) = .~0.84147098480789606 SELECT id"
::
++  test-inline-select-cos
  =/  f  [%cos [~.rd .~1]]
  =/  scalars  ~[[%scalar (inline-name 0) f]]
  %+  expect-eq
    !>  (mk-crud-txn-no-from-columns scalars ~[(inline-col 0 0)])
    !>  %-  parse:parse(default-database default-db)
            "SELECT COS(.~1)"
::
++  test-inline-where-cos
  =/  f  [%cos u-nrd]
  =/  scalars  ~[[%scalar (inline-name 0) f]]
  =/  pred  [%eq [(inline-ref 0) ~ ~] [[~.rd .~0.54030230586813921] ~ ~]]
  %+  expect-eq
    !>  (mk-inl-where scalars pred ~[u-id])
    !>  %-  parse:parse(default-database default-db)
            "FROM inl WHERE COS(nrd) = .~0.54030230586813921 SELECT id"
::
++  test-inline-select-tan
  =/  f  [%tan [~.rd .~1]]
  =/  scalars  ~[[%scalar (inline-name 0) f]]
  %+  expect-eq
    !>  (mk-crud-txn-no-from-columns scalars ~[(inline-col 0 0)])
    !>  %-  parse:parse(default-database default-db)
            "SELECT TAN(.~1)"
::
++  test-inline-where-tan
  =/  f  [%tan u-nrd]
  =/  scalars  ~[[%scalar (inline-name 0) f]]
  =/  pred  [%eq [(inline-ref 0) ~ ~] [[~.rd .~1.5574077246549027] ~ ~]]
  %+  expect-eq
    !>  (mk-inl-where scalars pred ~[u-id])
    !>  %-  parse:parse(default-database default-db)
            "FROM inl WHERE TAN(nrd) = .~1.5574077246549027 SELECT id"
::
++  test-inline-select-asin
  =/  f  [%asin [~.rd .~1]]
  =/  scalars  ~[[%scalar (inline-name 0) f]]
  %+  expect-eq
    !>  (mk-crud-txn-no-from-columns scalars ~[(inline-col 0 0)])
    !>  %-  parse:parse(default-database default-db)
            "SELECT ASIN(.~1)"
::
++  test-inline-where-asin
  =/  f  [%asin u-nu]
  =/  scalars  ~[[%scalar (inline-name 0) f]]
  =/  pred  [%eq [(inline-ref 0) ~ ~] [[~.rd .~1.5707963267948966] ~ ~]]
  %+  expect-eq
    !>  (mk-inl-where scalars pred ~[u-id])
    !>  %-  parse:parse(default-database default-db)
            "FROM inl WHERE ASIN(nu) = .~1.5707963267948966 SELECT id"
::
++  test-inline-select-acos
  =/  f  [%acos [~.rd .~0]]
  =/  scalars  ~[[%scalar (inline-name 0) f]]
  %+  expect-eq
    !>  (mk-crud-txn-no-from-columns scalars ~[(inline-col 0 0)])
    !>  %-  parse:parse(default-database default-db)
            "SELECT ACOS(.~0)"
::
++  test-inline-where-acos
  =/  f  [%acos u-nu]
  =/  scalars  ~[[%scalar (inline-name 0) f]]
  =/  pred  [%eq [(inline-ref 0) ~ ~] [[~.rd .~0] ~ ~]]
  %+  expect-eq
    !>  (mk-inl-where scalars pred ~[u-id])
    !>  %-  parse:parse(default-database default-db)
            "FROM inl WHERE ACOS(nu) = .~0 SELECT id"
::
++  test-inline-select-atan
  =/  f  [%atan [~.rd .~1]]
  =/  scalars  ~[[%scalar (inline-name 0) f]]
  %+  expect-eq
    !>  (mk-crud-txn-no-from-columns scalars ~[(inline-col 0 0)])
    !>  %-  parse:parse(default-database default-db)
            "SELECT ATAN(.~1)"
::
++  test-inline-where-atan
  =/  f  [%atan u-nrd]
  =/  scalars  ~[[%scalar (inline-name 0) f]]
  =/  pred  [%eq [(inline-ref 0) ~ ~] [[~.rd .~0.78539816339745139] ~ ~]]
  %+  expect-eq
    !>  (mk-inl-where scalars pred ~[u-id])
    !>  %-  parse:parse(default-database default-db)
            "FROM inl WHERE ATAN(nrd) = .~0.78539816339745139 SELECT id"
::
++  test-inline-select-atan2
  =/  f  [%atan2 [~.rd .~1] [~.rd .~2]]
  =/  scalars  ~[[%scalar (inline-name 0) f]]
  %+  expect-eq
    !>  (mk-crud-txn-no-from-columns scalars ~[(inline-col 0 0)])
    !>  %-  parse:parse(default-database default-db)
            "SELECT ATAN2(.~1, .~2)"
::
++  test-inline-where-atan2
  =/  f  [%atan2 u-nrd [~.rd .~2]]
  =/  scalars  ~[[%scalar (inline-name 0) f]]
  =/  pred  [%eq [(inline-ref 0) ~ ~] [[~.rd .~0.46364760900080748] ~ ~]]
  %+  expect-eq
    !>  (mk-inl-where scalars pred ~[u-id])
    !>  %-  parse:parse(default-database default-db)
            "FROM inl WHERE ATAN2(nrd, .~2) = .~0.46364760900080748 SELECT id"
::
++  test-inline-select-degrees
  =/  f  [%degrees [~.rd .~1]]
  =/  scalars  ~[[%scalar (inline-name 0) f]]
  %+  expect-eq
    !>  (mk-crud-txn-no-from-columns scalars ~[(inline-col 0 0)])
    !>  %-  parse:parse(default-database default-db)
            "SELECT DEGREES(.~1)"
::
++  test-inline-where-degrees
  =/  f  [%degrees u-nrd]
  =/  scalars  ~[[%scalar (inline-name 0) f]]
  =/  pred  [%eq [(inline-ref 0) ~ ~] [[~.rd .~57.29577951308232] ~ ~]]
  %+  expect-eq
    !>  (mk-inl-where scalars pred ~[u-id])
    !>  %-  parse:parse(default-database default-db)
            "FROM inl WHERE DEGREES(nrd) = .~57.29577951308232 SELECT id"
::
++  test-inline-select-e
  =/  f  [%e ~]
  =/  scalars  ~[[%scalar (inline-name 0) f]]
  %+  expect-eq
    !>  (mk-crud-txn-no-from-columns scalars ~[(inline-col 0 0)])
    !>  %-  parse:parse(default-database default-db)
            "SELECT E()"
::
++  test-inline-where-e
  =/  f  [%e ~]
  =/  scalars  ~[[%scalar (inline-name 0) f]]
  =/  pred  [%lt [u-nrd ~ ~] [(inline-ref 0) ~ ~]]
  %+  expect-eq
    !>  (mk-inl-where scalars pred ~[u-id])
    !>  %-  parse:parse(default-database default-db)
            "FROM inl WHERE nrd < E() SELECT id"
::
++  test-inline-select-phi
  =/  f  [%phi ~]
  =/  scalars  ~[[%scalar (inline-name 0) f]]
  %+  expect-eq
    !>  (mk-crud-txn-no-from-columns scalars ~[(inline-col 0 0)])
    !>  %-  parse:parse(default-database default-db)
            "SELECT PHI()"
::
++  test-inline-where-phi
  =/  f  [%phi ~]
  =/  scalars  ~[[%scalar (inline-name 0) f]]
  =/  pred  [%lt [u-nrd ~ ~] [(inline-ref 0) ~ ~]]
  %+  expect-eq
    !>  (mk-inl-where scalars pred ~[u-id])
    !>  %-  parse:parse(default-database default-db)
            "FROM inl WHERE nrd < PHI() SELECT id"
::
++  test-inline-select-pi
  =/  f  [%pi ~]
  =/  scalars  ~[[%scalar (inline-name 0) f]]
  %+  expect-eq
    !>  (mk-crud-txn-no-from-columns scalars ~[(inline-col 0 0)])
    !>  %-  parse:parse(default-database default-db)
            "SELECT PI()"
::
++  test-inline-where-pi
  =/  f  [%pi ~]
  =/  scalars  ~[[%scalar (inline-name 0) f]]
  =/  pred  [%lt [u-nrd ~ ~] [(inline-ref 0) ~ ~]]
  %+  expect-eq
    !>  (mk-inl-where scalars pred ~[u-id])
    !>  %-  parse:parse(default-database default-db)
            "FROM inl WHERE nrd < PI() SELECT id"
::
++  test-inline-select-tau
  =/  f  [%tau ~]
  =/  scalars  ~[[%scalar (inline-name 0) f]]
  %+  expect-eq
    !>  (mk-crud-txn-no-from-columns scalars ~[(inline-col 0 0)])
    !>  %-  parse:parse(default-database default-db)
            "SELECT TAU()"
::
++  test-inline-where-tau
  =/  f  [%tau ~]
  =/  scalars  ~[[%scalar (inline-name 0) f]]
  =/  pred  [%lt [u-nrd ~ ~] [(inline-ref 0) ~ ~]]
  %+  expect-eq
    !>  (mk-inl-where scalars pred ~[u-id])
    !>  %-  parse:parse(default-database default-db)
            "FROM inl WHERE nrd < TAU() SELECT id"
::
++  test-inline-select-getutcdate
  =/  f  [%getutcdate ~]
  =/  scalars  ~[[%scalar (inline-name 0) f]]
  %+  expect-eq
    !>  (mk-crud-txn-no-from-columns scalars ~[(inline-col 0 0)])
    !>  %-  parse:parse(default-database default-db)
            "SELECT GETUTCDATE()"
::
++  test-inline-where-getutcdate
  =/  f  [%getutcdate ~]
  =/  scalars  ~[[%scalar (inline-name 0) f]]
  =/  pred  [%gt [u-d ~ ~] [(inline-ref 0) ~ ~]]
  %+  expect-eq
    !>  (mk-inl-where scalars pred ~[u-id])
    !>  %-  parse:parse(default-database default-db)
            "FROM inl WHERE d > GETUTCDATE() SELECT id"
::
++  test-inline-select-year
  =/  f  [%year [~.da ~2026.3.15..10.30.45]]
  =/  scalars  ~[[%scalar (inline-name 0) f]]
  %+  expect-eq
    !>  (mk-crud-txn-no-from-columns scalars ~[(inline-col 0 0)])
    !>  %-  parse:parse(default-database default-db)
            "SELECT YEAR(~2026.3.15..10.30.45)"
::
++  test-inline-where-year
  =/  f  [%year u-d]
  =/  scalars  ~[[%scalar (inline-name 0) f]]
  =/  pred  [%eq [(inline-ref 0) ~ ~] [[~.ud 2.026] ~ ~]]
  %+  expect-eq
    !>  (mk-inl-where scalars pred ~[u-id])
    !>  %-  parse:parse(default-database default-db)
            "FROM inl WHERE YEAR(d) = 2026 SELECT id"
::
++  test-inline-select-month
  =/  f  [%month [~.da ~2026.3.15..10.30.45]]
  =/  scalars  ~[[%scalar (inline-name 0) f]]
  %+  expect-eq
    !>  (mk-crud-txn-no-from-columns scalars ~[(inline-col 0 0)])
    !>  %-  parse:parse(default-database default-db)
            "SELECT MONTH(~2026.3.15..10.30.45)"
::
++  test-inline-where-month
  =/  f  [%month u-d]
  =/  scalars  ~[[%scalar (inline-name 0) f]]
  =/  pred  [%eq [(inline-ref 0) ~ ~] [[~.ud 3] ~ ~]]
  %+  expect-eq
    !>  (mk-inl-where scalars pred ~[u-id])
    !>  %-  parse:parse(default-database default-db)
            "FROM inl WHERE MONTH(d) = 3 SELECT id"
::
++  test-inline-select-day
  =/  f  [%day [~.da ~2026.3.15..10.30.45]]
  =/  scalars  ~[[%scalar (inline-name 0) f]]
  %+  expect-eq
    !>  (mk-crud-txn-no-from-columns scalars ~[(inline-col 0 0)])
    !>  %-  parse:parse(default-database default-db)
            "SELECT DAY(~2026.3.15..10.30.45)"
::
++  test-inline-where-day
  =/  f  [%day u-d]
  =/  scalars  ~[[%scalar (inline-name 0) f]]
  =/  pred  [%eq [(inline-ref 0) ~ ~] [[~.ud 15] ~ ~]]
  %+  expect-eq
    !>  (mk-inl-where scalars pred ~[u-id])
    !>  %-  parse:parse(default-database default-db)
            "FROM inl WHERE DAY(d) = 15 SELECT id"
::
++  test-inline-select-hour
  =/  f  [%hour [~.da ~2026.3.15..10.30.45]]
  =/  scalars  ~[[%scalar (inline-name 0) f]]
  %+  expect-eq
    !>  (mk-crud-txn-no-from-columns scalars ~[(inline-col 0 0)])
    !>  %-  parse:parse(default-database default-db)
            "SELECT HOUR(~2026.3.15..10.30.45)"
::
++  test-inline-where-hour
  =/  f  [%hour u-d]
  =/  scalars  ~[[%scalar (inline-name 0) f]]
  =/  pred  [%eq [(inline-ref 0) ~ ~] [[~.ud 10] ~ ~]]
  %+  expect-eq
    !>  (mk-inl-where scalars pred ~[u-id])
    !>  %-  parse:parse(default-database default-db)
            "FROM inl WHERE HOUR(d) = 10 SELECT id"
::
++  test-inline-select-minute
  =/  f  [%minute [~.da ~2026.3.15..10.30.45]]
  =/  scalars  ~[[%scalar (inline-name 0) f]]
  %+  expect-eq
    !>  (mk-crud-txn-no-from-columns scalars ~[(inline-col 0 0)])
    !>  %-  parse:parse(default-database default-db)
            "SELECT MINUTE(~2026.3.15..10.30.45)"
::
++  test-inline-where-minute
  =/  f  [%minute u-d]
  =/  scalars  ~[[%scalar (inline-name 0) f]]
  =/  pred  [%eq [(inline-ref 0) ~ ~] [[~.ud 30] ~ ~]]
  %+  expect-eq
    !>  (mk-inl-where scalars pred ~[u-id])
    !>  %-  parse:parse(default-database default-db)
            "FROM inl WHERE MINUTE(d) = 30 SELECT id"
::
++  test-inline-select-second
  =/  f  [%second [~.da ~2026.3.15..10.30.45]]
  =/  scalars  ~[[%scalar (inline-name 0) f]]
  %+  expect-eq
    !>  (mk-crud-txn-no-from-columns scalars ~[(inline-col 0 0)])
    !>  %-  parse:parse(default-database default-db)
            "SELECT SECOND(~2026.3.15..10.30.45)"
::
++  test-inline-where-second
  =/  f  [%second u-d]
  =/  scalars  ~[[%scalar (inline-name 0) f]]
  =/  pred  [%eq [(inline-ref 0) ~ ~] [[~.ud 45] ~ ~]]
  %+  expect-eq
    !>  (mk-inl-where scalars pred ~[u-id])
    !>  %-  parse:parse(default-database default-db)
            "FROM inl WHERE SECOND(d) = 45 SELECT id"
::
++  test-inline-select-add-time
  =/  f  [%add-time [~.da ~2026.3.15..10.30.45] [~.dr ~d1]]
  =/  scalars  ~[[%scalar (inline-name 0) f]]
  %+  expect-eq
    !>  (mk-crud-txn-no-from-columns scalars ~[(inline-col 0 0)])
    !>  %-  parse:parse(default-database default-db)
            "SELECT ADD-TIME(~2026.3.15..10.30.45, ~d1)"
::
++  test-inline-where-add-time
  =/  f  [%add-time u-d u-dr]
  =/  scalars  ~[[%scalar (inline-name 0) f]]
  =/  pred  [%eq [(inline-ref 0) ~ ~] [[~.da ~2026.3.16..10.30.45] ~ ~]]
  %+  expect-eq
    !>  (mk-inl-where scalars pred ~[u-id])
    !>  %-  parse:parse(default-database default-db)
            "FROM inl WHERE ADD-TIME(d, dr) = ~2026.3.16..10.30.45 SELECT id"
::
++  test-inline-select-subtract-time
  =/  f  [%subtract-time [~.da ~2026.3.15..10.30.45] [~.dr ~d1]]
  =/  scalars  ~[[%scalar (inline-name 0) f]]
  %+  expect-eq
    !>  (mk-crud-txn-no-from-columns scalars ~[(inline-col 0 0)])
    !>  %-  parse:parse(default-database default-db)
            "SELECT SUBTRACT-TIME(~2026.3.15..10.30.45, ~d1)"
::
++  test-inline-where-subtract-time
  =/  f  [%subtract-time u-d u-dr]
  =/  scalars  ~[[%scalar (inline-name 0) f]]
  =/  pred  [%eq [(inline-ref 0) ~ ~] [[~.da ~2026.3.14..10.30.45] ~ ~]]
  %+  expect-eq
    !>  (mk-inl-where scalars pred ~[u-id])
    !>  %-  parse:parse(default-database default-db)
            "FROM inl WHERE SUBTRACT-TIME(d, dr) = ~2026.3.14..10.30.45 ".
            "SELECT id"
::
++  test-inline-select-concat
  =/  f  [%concat ~[[~.t 'hello'] [~.t 'world']]]
  =/  scalars  ~[[%scalar (inline-name 0) f]]
  %+  expect-eq
    !>  (mk-crud-txn-no-from-columns scalars ~[(inline-col 0 0)])
    !>  %-  parse:parse(default-database default-db)
            "SELECT CONCAT('hello', 'world')"
::
++  test-inline-where-concat
  =/  f  [%concat ~[u-t [~.t 'world']]]
  =/  scalars  ~[[%scalar (inline-name 0) f]]
  =/  pred  [%eq [(inline-ref 0) ~ ~] [[~.t 'helloworld'] ~ ~]]
  %+  expect-eq
    !>  (mk-inl-where scalars pred ~[u-id])
    !>  %-  parse:parse(default-database default-db)
            "FROM inl WHERE CONCAT(t, 'world') = 'helloworld' SELECT id"
::
++  test-inline-select-left
  =/  f  [%left [~.t 'hello'] [~.ud 3]]
  =/  scalars  ~[[%scalar (inline-name 0) f]]
  %+  expect-eq
    !>  (mk-crud-txn-no-from-columns scalars ~[(inline-col 0 0)])
    !>  %-  parse:parse(default-database default-db)
            "SELECT LEFT('hello', 3)"
::
++  test-inline-where-left
  =/  f  [%left u-t [~.ud 3]]
  =/  scalars  ~[[%scalar (inline-name 0) f]]
  =/  pred  [%eq [(inline-ref 0) ~ ~] [[~.t 'hel'] ~ ~]]
  %+  expect-eq
    !>  (mk-inl-where scalars pred ~[u-id])
    !>  %-  parse:parse(default-database default-db)
            "FROM inl WHERE LEFT(t, 3) = 'hel' SELECT id"
::
++  test-inline-select-len
  =/  f  [%len [~.t 'hello']]
  =/  scalars  ~[[%scalar (inline-name 0) f]]
  %+  expect-eq
    !>  (mk-crud-txn-no-from-columns scalars ~[(inline-col 0 0)])
    !>  %-  parse:parse(default-database default-db)
            "SELECT LEN('hello')"
::
++  test-inline-where-len
  =/  f  [%len u-tpad]
  =/  scalars  ~[[%scalar (inline-name 0) f]]
  =/  pred  [%eq [(inline-ref 0) ~ ~] [[~.ud 9] ~ ~]]
  %+  expect-eq
    !>  (mk-inl-where scalars pred ~[u-id])
    !>  %-  parse:parse(default-database default-db)
            "FROM inl WHERE LEN(tpad) = 9 SELECT id"
::
++  test-inline-select-lower
  =/  f  [%lower [~.t 'HELLO']]
  =/  scalars  ~[[%scalar (inline-name 0) f]]
  %+  expect-eq
    !>  (mk-crud-txn-no-from-columns scalars ~[(inline-col 0 0)])
    !>  %-  parse:parse(default-database default-db)
            "SELECT LOWER('HELLO')"
::
++  test-inline-where-lower
  =/  f  [%lower u-t]
  =/  scalars  ~[[%scalar (inline-name 0) f]]
  =/  pred  [%eq [(inline-ref 0) ~ ~] [[~.t 'world'] ~ ~]]
  %+  expect-eq
    !>  (mk-inl-where scalars pred ~[u-id])
    !>  %-  parse:parse(default-database default-db)
            "FROM inl WHERE LOWER(t) = 'world' SELECT id"
::
++  test-inline-select-ltrim
  =/  f  [%ltrim [~.t '  hello  '] ~]
  =/  scalars  ~[[%scalar (inline-name 0) f]]
  %+  expect-eq
    !>  (mk-crud-txn-no-from-columns scalars ~[(inline-col 0 0)])
    !>  %-  parse:parse(default-database default-db)
            "SELECT LTRIM('  hello  ')"
::
++  test-inline-where-ltrim
  =/  f  [%ltrim u-tpad ~]
  =/  scalars  ~[[%scalar (inline-name 0) f]]
  =/  pred  [%eq [(inline-ref 0) ~ ~] [[~.t 'hello  '] ~ ~]]
  %+  expect-eq
    !>  (mk-inl-where scalars pred ~[u-id])
    !>  %-  parse:parse(default-database default-db)
            "FROM inl WHERE LTRIM(tpad) = 'hello  ' SELECT id"
::
++  test-inline-select-patindex
  =/  f  [%patindex [~.t 'hello'] [~.t 'ell']]
  =/  scalars  ~[[%scalar (inline-name 0) f]]
  %+  expect-eq
    !>  (mk-crud-txn-no-from-columns scalars ~[(inline-col 0 0)])
    !>  %-  parse:parse(default-database default-db)
            "SELECT PATINDEX('hello', 'ell')"
::
++  test-inline-where-patindex
  =/  f  [%patindex u-t [~.t 'ell']]
  =/  scalars  ~[[%scalar (inline-name 0) f]]
  =/  pred  [%eq [(inline-ref 0) ~ ~] [[~.ud 2] ~ ~]]
  %+  expect-eq
    !>  (mk-inl-where scalars pred ~[u-id])
    !>  %-  parse:parse(default-database default-db)
            "FROM inl WHERE PATINDEX(t, 'ell') = 2 SELECT id"
::
++  test-inline-select-quotestring
  =/  f  [%quotestring [~.t 'hello'] ~]
  =/  scalars  ~[[%scalar (inline-name 0) f]]
  %+  expect-eq
    !>  (mk-crud-txn-no-from-columns scalars ~[(inline-col 0 0)])
    !>  %-  parse:parse(default-database default-db)
            "SELECT QUOTESTRING('hello')"
::
++  test-inline-where-quotestring
  =/  f  [%quotestring u-t ~]
  =/  scalars  ~[[%scalar (inline-name 0) f]]
  =/  pred  [%eq [(inline-ref 0) ~ ~] [[~.t '[hello]'] ~ ~]]
  %+  expect-eq
    !>  (mk-inl-where scalars pred ~[u-id])
    !>  %-  parse:parse(default-database default-db)
            "FROM inl WHERE QUOTESTRING(t) = '[hello]' SELECT id"
::
++  test-inline-select-replace
  =/  f  [%replace [~.t 'hello world'] [~.t 'world'] [~.t 'there']]
  =/  scalars  ~[[%scalar (inline-name 0) f]]
  %+  expect-eq
    !>  (mk-crud-txn-no-from-columns scalars ~[(inline-col 0 0)])
    !>  %-  parse:parse(default-database default-db)
            "SELECT REPLACE('hello world', 'world', 'there')"
::
++  test-inline-where-replace
  =/  f  [%replace u-t [~.t 'ell'] [~.t 'ELL']]
  =/  scalars  ~[[%scalar (inline-name 0) f]]
  =/  pred  [%eq [(inline-ref 0) ~ ~] [[~.t 'hELLo'] ~ ~]]
  %+  expect-eq
    !>  (mk-inl-where scalars pred ~[u-id])
    !>  %-  parse:parse(default-database default-db)
            "FROM inl WHERE REPLACE(t, 'ell', 'ELL') = 'hELLo' SELECT id"
::
++  test-inline-select-replicate
  =/  f  [%replicate [~.t 'ha'] [~.ud 2]]
  =/  scalars  ~[[%scalar (inline-name 0) f]]
  %+  expect-eq
    !>  (mk-crud-txn-no-from-columns scalars ~[(inline-col 0 0)])
    !>  %-  parse:parse(default-database default-db)
            "SELECT REPLICATE('ha', 2)"
::
++  test-inline-where-replicate
  =/  f  [%replicate u-t [~.ud 2]]
  =/  scalars  ~[[%scalar (inline-name 0) f]]
  =/  pred  [%eq [(inline-ref 0) ~ ~] [[~.t 'hellohello'] ~ ~]]
  %+  expect-eq
    !>  (mk-inl-where scalars pred ~[u-id])
    !>  %-  parse:parse(default-database default-db)
            "FROM inl WHERE REPLICATE(t, 2) = 'hellohello' SELECT id"
::
++  test-inline-select-reverse
  =/  f  [%reverse [~.t 'hello']]
  =/  scalars  ~[[%scalar (inline-name 0) f]]
  %+  expect-eq
    !>  (mk-crud-txn-no-from-columns scalars ~[(inline-col 0 0)])
    !>  %-  parse:parse(default-database default-db)
            "SELECT REVERSE('hello')"
::
++  test-inline-where-reverse
  =/  f  [%reverse u-t]
  =/  scalars  ~[[%scalar (inline-name 0) f]]
  =/  pred  [%eq [(inline-ref 0) ~ ~] [[~.t 'olleh'] ~ ~]]
  %+  expect-eq
    !>  (mk-inl-where scalars pred ~[u-id])
    !>  %-  parse:parse(default-database default-db)
            "FROM inl WHERE REVERSE(t) = 'olleh' SELECT id"
::
++  test-inline-select-right
  =/  f  [%right [~.t 'hello'] [~.ud 3]]
  =/  scalars  ~[[%scalar (inline-name 0) f]]
  %+  expect-eq
    !>  (mk-crud-txn-no-from-columns scalars ~[(inline-col 0 0)])
    !>  %-  parse:parse(default-database default-db)
            "SELECT RIGHT('hello', 3)"
::
++  test-inline-where-right
  =/  f  [%right u-t [~.ud 3]]
  =/  scalars  ~[[%scalar (inline-name 0) f]]
  =/  pred  [%eq [(inline-ref 0) ~ ~] [[~.t 'llo'] ~ ~]]
  %+  expect-eq
    !>  (mk-inl-where scalars pred ~[u-id])
    !>  %-  parse:parse(default-database default-db)
            "FROM inl WHERE RIGHT(t, 3) = 'llo' SELECT id"
::
++  test-inline-select-rtrim
  =/  f  [%rtrim [~.t '  hello  '] ~]
  =/  scalars  ~[[%scalar (inline-name 0) f]]
  %+  expect-eq
    !>  (mk-crud-txn-no-from-columns scalars ~[(inline-col 0 0)])
    !>  %-  parse:parse(default-database default-db)
            "SELECT RTRIM('  hello  ')"
::
++  test-inline-where-rtrim
  =/  f  [%rtrim u-tpad ~]
  =/  scalars  ~[[%scalar (inline-name 0) f]]
  =/  pred  [%eq [(inline-ref 0) ~ ~] [[~.t '  hello'] ~ ~]]
  %+  expect-eq
    !>  (mk-inl-where scalars pred ~[u-id])
    !>  %-  parse:parse(default-database default-db)
            "FROM inl WHERE RTRIM(tpad) = '  hello' SELECT id"
::
++  test-inline-select-string
  =/  f  [%string [~.ud 42]]
  =/  scalars  ~[[%scalar (inline-name 0) f]]
  %+  expect-eq
    !>  (mk-crud-txn-no-from-columns scalars ~[(inline-col 0 0)])
    !>  %-  parse:parse(default-database default-db)
            "SELECT STRING(42)"
::
++  test-inline-where-string
  =/  f  [%string u-nud]
  =/  scalars  ~[[%scalar (inline-name 0) f]]
  =/  pred  [%eq [(inline-ref 0) ~ ~] [[~.t '5'] ~ ~]]
  %+  expect-eq
    !>  (mk-inl-where scalars pred ~[u-id])
    !>  %-  parse:parse(default-database default-db)
            "FROM inl WHERE STRING(nud) = '5' SELECT id"
::
++  test-inline-select-string-concat
  =/  f  [%string-concat ~[[~.t 'hello'] [~.t 'world']] [~.t ', ']]
  =/  scalars  ~[[%scalar (inline-name 0) f]]
  %+  expect-eq
    !>  (mk-crud-txn-no-from-columns scalars ~[(inline-col 0 0)])
    !>  %-  parse:parse(default-database default-db)
            "SELECT STRING-CONCAT('hello', 'world', ', ')"
::
++  test-inline-where-string-concat
  =/  f  [%string-concat ~[u-t [~.t 'world']] [~.t ', ']]
  =/  scalars  ~[[%scalar (inline-name 0) f]]
  =/  pred  [%eq [(inline-ref 0) ~ ~] [[~.t 'hello, world'] ~ ~]]
  %+  expect-eq
    !>  (mk-inl-where scalars pred ~[u-id])
    !>  %-  parse:parse(default-database default-db)
            "FROM inl WHERE STRING-CONCAT(t, 'world', ', ') = 'hello, ".
            "world' SELECT id"
::
++  test-inline-select-stuff
  =/  f  [%stuff [~.t 'hello world'] [~.ud 7] [~.ud 5] [~.t 'there']]
  =/  scalars  ~[[%scalar (inline-name 0) f]]
  %+  expect-eq
    !>  (mk-crud-txn-no-from-columns scalars ~[(inline-col 0 0)])
    !>  %-  parse:parse(default-database default-db)
            "SELECT STUFF('hello world', 7, 5, 'there')"
::
++  test-inline-where-stuff
  =/  f  [%stuff u-t [~.ud 2] [~.ud 3] [~.t 'ELL']]
  =/  scalars  ~[[%scalar (inline-name 0) f]]
  =/  pred  [%eq [(inline-ref 0) ~ ~] [[~.t 'hELLo'] ~ ~]]
  %+  expect-eq
    !>  (mk-inl-where scalars pred ~[u-id])
    !>  %-  parse:parse(default-database default-db)
            "FROM inl WHERE STUFF(t, 2, 3, 'ELL') = 'hELLo' SELECT id"
::
++  test-inline-select-substring
  =/  f  [%substring [~.t 'hello'] [~.ud 2] `[~.ud 3]]
  =/  scalars  ~[[%scalar (inline-name 0) f]]
  %+  expect-eq
    !>  (mk-crud-txn-no-from-columns scalars ~[(inline-col 0 0)])
    !>  %-  parse:parse(default-database default-db)
            "SELECT SUBSTRING('hello', 2, 3)"
::
++  test-inline-where-substring
  =/  f  [%substring u-t [~.ud 2] `[~.ud 3]]
  =/  scalars  ~[[%scalar (inline-name 0) f]]
  =/  pred  [%eq [(inline-ref 0) ~ ~] [[~.t 'ell'] ~ ~]]
  %+  expect-eq
    !>  (mk-inl-where scalars pred ~[u-id])
    !>  %-  parse:parse(default-database default-db)
            "FROM inl WHERE SUBSTRING(t, 2, 3) = 'ell' SELECT id"
::
++  test-inline-select-trim
  =/  f  [%trim [~.t '  hello  '] ~]
  =/  scalars  ~[[%scalar (inline-name 0) f]]
  %+  expect-eq
    !>  (mk-crud-txn-no-from-columns scalars ~[(inline-col 0 0)])
    !>  %-  parse:parse(default-database default-db)
            "SELECT TRIM('  hello  ')"
::
++  test-inline-where-trim
  =/  f  [%trim u-tpad ~]
  =/  scalars  ~[[%scalar (inline-name 0) f]]
  =/  pred  [%eq [(inline-ref 0) ~ ~] [[~.t 'hello'] ~ ~]]
  %+  expect-eq
    !>  (mk-inl-where scalars pred ~[u-id])
    !>  %-  parse:parse(default-database default-db)
            "FROM inl WHERE TRIM(tpad) = 'hello' SELECT id"
::
++  test-inline-select-upper
  =/  f  [%upper [~.t 'hello']]
  =/  scalars  ~[[%scalar (inline-name 0) f]]
  %+  expect-eq
    !>  (mk-crud-txn-no-from-columns scalars ~[(inline-col 0 0)])
    !>  %-  parse:parse(default-database default-db)
            "SELECT UPPER('hello')"
::
++  test-inline-where-upper
  =/  f  [%upper u-t]
  =/  scalars  ~[[%scalar (inline-name 0) f]]
  =/  pred  [%eq [(inline-ref 0) ~ ~] [[~.t 'HELLO'] ~ ~]]
  %+  expect-eq
    !>  (mk-inl-where scalars pred ~[u-id])
    !>  %-  parse:parse(default-database default-db)
            "FROM inl WHERE UPPER(t) = 'HELLO' SELECT id"
::
++  test-inline-select-coalesce
  =/  f  [%coalesce ~[[~.ud 1] [~.ud 2]]]
  =/  scalars  ~[[%scalar (inline-name 0) f]]
  %+  expect-eq
    !>  (mk-crud-txn-no-from-columns scalars ~[(inline-col 0 0)])
    !>  %-  parse:parse(default-database default-db)
            "SELECT COALESCE(1, 2)"
::
++  test-inline-where-coalesce
  =/  f  [%coalesce ~[u-nud [~.ud 1]]]
  =/  scalars  ~[[%scalar (inline-name 0) f]]
  =/  pred  [%eq [(inline-ref 0) ~ ~] [[~.ud 5] ~ ~]]
  %+  expect-eq
    !>  (mk-inl-where scalars pred ~[u-id])
    !>  %-  parse:parse(default-database default-db)
            "FROM inl WHERE COALESCE(nud, 1) = 5 SELECT id"
::
++  test-inline-select-if
  =/  f  [%if-then-else simple-true-pred [~.t 'yes'] [~.t 'no']]
  =/  scalars  ~[[%scalar (inline-name 0) f]]
  %+  expect-eq
    !>  (mk-crud-txn-no-from-columns scalars ~[(inline-col 0 0)])
    !>  %-  parse:parse(default-database default-db)
            "SELECT IF 1 = 1 THEN 'yes' ELSE 'no' ENDIF"
::
++  test-inline-where-if
  =/  f  [%if-then-else nud-gt-6 [~.t 'big'] [~.t 'small']]
  =/  scalars  ~[[%scalar (inline-name 0) f]]
  =/  pred  [%eq [(inline-ref 0) ~ ~] [[~.t 'small'] ~ ~]]
  %+  expect-eq
    !>  (mk-inl-where scalars pred ~[u-id])
    !>  %-  parse:parse(default-database default-db)
            "FROM inl WHERE IF nud > 6 THEN 'big' ELSE 'small' ENDIF = ".
            "'small' SELECT id"
::
++  test-inline-select-case-simple
  =/  f  case-simple-lit
  =/  scalars  ~[[%scalar (inline-name 0) f]]
  %+  expect-eq
    !>  (mk-crud-txn-no-from-columns scalars ~[(inline-col 0 0)])
    !>  %-  parse:parse(default-database default-db)
            "SELECT CASE 2 WHEN 1 THEN 'one' WHEN 2 THEN 'two' ELSE ".
            "'other' END"
::
++  test-inline-where-case-simple
  =/  f  case-simple-col
  =/  scalars  ~[[%scalar (inline-name 0) f]]
  =/  pred  [%eq [(inline-ref 0) ~ ~] [[~.t 'five'] ~ ~]]
  %+  expect-eq
    !>  (mk-inl-where scalars pred ~[u-id])
    !>  %-  parse:parse(default-database default-db)
            "FROM inl WHERE CASE nud WHEN 5 THEN 'five' ELSE 'other' END ".
            "= 'five' SELECT id"
::
++  test-inline-select-case-searched
  =/  f  case-searched-lit
  =/  scalars  ~[[%scalar (inline-name 0) f]]
  %+  expect-eq
    !>  (mk-crud-txn-no-from-columns scalars ~[(inline-col 0 0)])
    !>  %-  parse:parse(default-database default-db)
            "SELECT CASE WHEN 1 = 2 THEN 'a' WHEN 1 = 1 THEN 'b' END"
::
++  test-inline-where-case-searched
  =/  f  case-searched-col
  =/  scalars  ~[[%scalar (inline-name 0) f]]
  =/  pred  [%eq [(inline-ref 0) ~ ~] [[~.t 'big'] ~ ~]]
  %+  expect-eq
    !>  (mk-inl-where scalars pred ~[u-id])
    !>  %-  parse:parse(default-database default-db)
            "FROM inl WHERE CASE WHEN nud > 6 THEN 'big' ELSE 'small' END ".
            "= 'big' SELECT id"
::
++  test-inline-select-arithmetic
  =/  f  [%arithmetic %lus [~.ud 1] [%arithmetic %tar [~.ud 2] [~.ud 3]]]
  =/  scalars  ~[[%scalar (inline-name 0) f]]
  %+  expect-eq
    !>  (mk-crud-txn-no-from-columns scalars ~[(inline-col 0 0)])
    !>  %-  parse:parse(default-database default-db)
            "SELECT 1 + 2 * 3"
::
++  test-inline-where-arithmetic
  =/  f  [%arithmetic %tar [%arithmetic %lus u-nud [~.ud 1]] [~.ud 2]]
  =/  scalars  ~[[%scalar (inline-name 0) f]]
  =/  pred  [%eq [(inline-ref 0) ~ ~] [[~.ud 20] ~ ~]]
  %+  expect-eq
    !>  (mk-inl-where scalars pred ~[u-id])
    !>  %-  parse:parse(default-database default-db)
            "FROM inl WHERE (nud + 1) * 2 = 20 SELECT id"
::
::  VERSION
::
++  test-inline-select-version
  =/  scalars  ~[[%scalar (inline-name 0) [%version ~]]]
  %+  expect-eq
    !>  (mk-crud-txn-no-from-columns scalars ~[(inline-col 0 0)])
    !>  %-  parse:parse(default-database default-db)
            "SELECT version()"
::
++  test-scalars-version
  =/  scalars  ~[[%scalar 'v' [%version ~]]]
  =/  columns  ~[[%selected-scalar 'v' ~]]
  %+  expect-eq
    !>  (mk-crud-txn-no-from-columns scalars columns)
    !>  %-  parse:parse(default-database default-db)
            "SCALARS v VERSION() SELECT v"
::
++  test-inline-where-version
  =/  f  [%concat ~[[~.t 'v'] [%version ~]]]
  =/  scalars  ~[[%scalar (inline-name 0) f]]
  =/  pred  [%eq [(inline-ref 0) ~ ~] [[~.t 'v1'] ~ ~]]
  %+  expect-eq
    !>  (mk-inl-where scalars pred ~[u-id])
    !>  %-  parse:parse(default-database default-db)
            "FROM inl WHERE CONCAT('v', VERSION()) = 'v1' SELECT id"
::
::  VERSION takes no arguments
++  test-fail-version-argument
  %+  expect-fail-message
    'PARSER: '
    |.  %-  parse:parse(default-database default-db)
            "SELECT VERSION(1)"
--
