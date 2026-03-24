/-  ast
/+  parse,  *test
::
|%
::
::  helper gates
::
::  mk-selection
::  returns a constant selection with scalars set to arg
++  mk-selection
  |=  [scalars=(list scalar:ast) table=(unit qualified-table:ast)]
  ^-  (list command:ast)
  =/  columns  ~[unqualified-foo-2 unqualified-foo-3]
  =/  select  [%select top=~ columns=columns]
  =/  relation  ?~(table relation-1 (need table))
  =/  from  [%from relation=relation as-of=~ joins=~]
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
  ~[[%selection ctes=~ set-functions=[query ~ ~]]]
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
  =/  expected  (mk-selection scalars ~)
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
  =/  expected  (mk-selection scalars ~)
  %+  expect-eq
    !>  expected
    !>  (parse:parse(default-database default-db) query-string)
::
::  test mixing arithmetic with builtin functions
++  test-scalars-03
  =/  query-string
    "FROM foo ".
    "SCALARS sc1 BEGIN ABS(-5) + 1 END ".
    "        sc2 BEGIN FLOOR(.2.8) - CEILING(.1.2) END ".
    "        sc4 BEGIN LOG(10) / ABS(-5) END ".
    "        sc5 BEGIN ROUND(.3.7, 0) ^ 2 END ".
    "        sc6 BEGIN LEN('hello') + DAY(2023.1.15) END ".
    "        sc7 BEGIN (ABS(-3) + FLOOR(.2.9)) * SQRT(16) END ".
    "        sc9 BEGIN YEAR(2023.6.20) - MONTH(2023.6.20) END ".
    "        sc10 BEGIN (LOG(100) + SIGN(-5)) / (SQRT(9) - 1) END ".
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
  =/  expected  (mk-selection scalars ~)
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
      [%scalar 'st4' [%substring literal-hello literal-2 literal-3]]
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
  =/  expected  (mk-selection scalars ~)
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
      [%scalar 'st4' [%substring literal-hello literal-2 literal-3]]
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
  =/  expected  (mk-selection scalars (some table))
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
      [%scalar 'st4' [%substring literal-hello literal-2 literal-3]]
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
  =/  expected  (mk-selection scalars (some table))
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
      [%scalar 'st4' [%substring literal-hello literal-2 literal-3]]
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
  =/  expected  (mk-selection scalars (some table))
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
=/  expected  (mk-selection scalars ~)
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
=/  expected  (mk-selection scalars ~)
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
=/  expected=(list command:ast)  (mk-selection scalars ~)
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
  =/  expected  (mk-selection scalars ~)
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
  =/  expected  (mk-selection scalars ~)
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
  =/  expected  (mk-selection scalars ~)
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
  =/  expected  (mk-selection scalars ~)
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
  =/  expected  (mk-selection scalars (some table))
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
  =/  expected  (mk-selection scalars ~)
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
  =/  expected  (mk-selection scalars ~)
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
  =/  expected  (mk-selection scalars ~)
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
  =/  expected  (mk-selection scalars ~)
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
  =/  expected  (mk-selection scalars ~)
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
  =/  expected  (mk-selection scalars ~)
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
  =/  expected  (mk-selection scalars ~)
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
  =/  expected  (mk-selection scalars ~)
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
  =/  expected  (mk-selection scalars ~)
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
  =/  expected  (mk-selection scalars ~)
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
  =/  expected  (mk-selection scalars ~)
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
  =/  expected  (mk-selection scalars ~)
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
  =/  expected  (mk-selection scalars ~)
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
  =/  expected  (mk-selection scalars (some table))
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
  =/  expected  (mk-selection scalars ~)
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
  =/  expected  (mk-selection scalars ~)
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
  =/  expected  (mk-selection scalars ~)
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
  =/  expected  (mk-selection scalars ~)
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
  =/  expected  (mk-selection scalars ~)
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
  =/  expected  (mk-selection scalars ~)
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
  =/  expected  (mk-selection scalars ~)
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
  =/  expected  (mk-selection scalars ~)
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
  =/  expected  (mk-selection scalars ~)
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
  =/  expected  (mk-selection scalars ~)
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
  =/  expected  (mk-selection scalars ~)
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
  =/  expected  (mk-selection scalars ~)
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
  =/  expected  (mk-selection scalars ~)
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
  =/  expected  (mk-selection scalars ~)
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
  =/  expected  (mk-selection scalars (some table))
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
  =/  expected  (mk-selection scalars ~)
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
  =/  expected  (mk-selection scalars ~)
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
  =/  expected  (mk-selection scalars ~)
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
  =/  expected  (mk-selection scalars ~)
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
  =/  expected  (mk-selection scalars ~)
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
  =/  expected  (mk-selection scalars ~)
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
  =/  expected  (mk-selection scalars ~)
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
  =/  expected  (mk-selection scalars ~)
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
  =/  expected  (mk-selection scalars ~)
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
  =/  expected  (mk-selection scalars ~)
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
  =/  expected  (mk-selection scalars ~)
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
  =/  expected  (mk-selection scalars ~)
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
  =/  expected  (mk-selection scalars ~)
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
  =/  expected  (mk-selection scalars ~)
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
  =/  expected  (mk-selection scalars ~)
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
  =/  expected  (mk-selection scalars (some table))
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
  =/  expected  (mk-selection scalars ~)
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
  =/  expected  (mk-selection scalars ~)
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
  =/  expected  (mk-selection scalars ~)
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
  =/  expected  (mk-selection scalars ~)
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
    "SCALARS foo1 BEGIN 1 + 1 END ".
    "        foo2 BEGIN 1 - 1 END ".
    "        foo3 BEGIN 1 / 1 END ".
    "        foo4 BEGIN 1 * 1 END ".
    "        foo5 BEGIN 1 ^ 1 END ".
    "        foo6 BEGIN 1 % 1 END ".
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
  =/  expected  (mk-selection scalars ~)
  %+  expect-eq
    !>  expected
    !>  (parse:parse(default-database default-db) query-string)
::
:: singly nested math expressions
++  test-arithmetic-2
  ::
  =/  query-string
    "FROM foo ".
    "SCALARS foo1 BEGIN (1 + 1) + 1 END ".
    "        foo2 BEGIN (1 - 1) - 1 END ".
    "        foo3 BEGIN (1 / 1) / 1 END ".
    "        foo4 BEGIN (1 * 1) * 1 END ".
    "        foo5 BEGIN (1 ^ 1) ^ 1 END ".
    "        foo6 BEGIN (1 % 1) % 1 END ".
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
  =/  expected  (mk-selection scalars ~)
  %+  expect-eq
    !>  expected
    !>  (parse:parse(default-database default-db) query-string)
::
:: singly nested math expressions (right side)
++  test-arithmetic-3
  ::
  =/  query-string
    "FROM foo ".
    "SCALARS foo1 BEGIN 1 + (1 + 1) END ".
    "        foo2 BEGIN 1 - (1 - 1) END ".
    "        foo3 BEGIN 1 / (1 / 1) END ".
    "        foo4 BEGIN 1 * (1 * 1) END ".
    "        foo5 BEGIN 1 ^ (1 ^ 1) END ".
    "        foo6 BEGIN 1 % (1 % 1) END ".
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
  =/  expected  (mk-selection scalars ~)
  %+  expect-eq
    !>  expected
    !>  (parse:parse(default-database default-db) query-string)
::
:: doubly nested math expressions
++  test-arithmetic-4
  ::
  =/  query-string
    "FROM foo ".
    "SCALARS foo1 BEGIN ((1 * 1) - 1) + 1 END ".
    "        foo2 BEGIN ((1 + 1) ^ 1) - 1 END ".
    "        foo3 BEGIN ((1 - 1) * 1) / 1 END ".
    "        foo4 BEGIN ((1 / 1) + 1) * 1 END ".
    "        foo5 BEGIN ((1 ^ 1) / 1) ^ 1 END ".
    "        foo6 BEGIN ((1 % 1) % 1) % 1 END ".
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
  =/  expected  (mk-selection scalars ~)
  %+  expect-eq
    !>  expected
    !>  (parse:parse(default-database default-db) query-string)
::
:: doubly nested math expressions (right side)
++  test-arithmetic-5
  ::
  =/  query-string
    "FROM foo ".
    "SCALARS foo1 BEGIN 1 + (1 - (1 * 1)) END ".
    "        foo2 BEGIN 1 - (1 ^ (1 + 1)) END ".
    "        foo3 BEGIN 1 / (1 * (1 - 1)) END ".
    "        foo4 BEGIN 1 * (1 + (1 / 1)) END ".
    "        foo5 BEGIN 1 ^ (1 / (1 ^ 1)) END ".
    "        foo6 BEGIN 1 % (1 % (1 % 1)) END ".
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
  =/  expected  (mk-selection scalars ~)
  %+  expect-eq
    !>  expected
    !>  (parse:parse(default-database default-db) query-string)
::
:: arithmetic expressions with spacing variations
++  test-arithmetic-6
  =/  query-string
    "FROM foo ".
    "SCALARS foo1 BEGIN 1 +1 END ".
    "        foo2 BEGIN 1  -  1 END ".
    "        foo3 BEGIN 1 /1 END ".
    "        foo4 BEGIN 1 *1 END ".
    "        foo5 BEGIN 1   ^   1 END ".
    "        foo6 BEGIN (1 +1)+1 END ".
    "        foo7 BEGIN ( 1 -1 ) - 1 END ".
    "        foo8 BEGIN (1 / 1)/  1 END ".
    "        foo9 BEGIN 1 +( 1 + 1 ) END ".
    "        foo10 BEGIN 1 -(1 -1) END ".
    "        foo11 BEGIN 1  /  (1 / 1) END ".
    "        foo12 BEGIN ((1 *1) -1) +1 END ".
    "        foo13 BEGIN ( ( 1 + 1 ) ^ 1 ) - 1 END ".
    "        foo14 BEGIN 1 +  (1 -(1 *1)) END ".
    "        foo15 BEGIN 1 *(  1 +(1 /1)  ) END ".
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
  =/  expected  (mk-selection scalars ~)
  %+  expect-eq
    !>  expected
    !>  (parse:parse(default-database default-db) query-string)
::
:: test operator associativity
++  test-arithmetic-7
  =/  query-string
    "FROM foo ".
    "SCALARS foo1  BEGIN 2 ^ 3 ^ 3 END ".
    "        foo2  BEGIN 2 ^ (3 ^ 3) END ".
    "        foo3  BEGIN (2 ^ 3) ^ 3 END ".
    "        foo4  BEGIN 2 + 3 + 4 END ".
    "        foo5  BEGIN 2 + (3 + 4) END ".
    "        foo6  BEGIN (2 + 3) + 4 END ".
    "        foo7  BEGIN 2 - 3 - 4 END ".
    "        foo8  BEGIN 2 - (3 - 4) END ".
    "        foo9  BEGIN (2 - 3) - 4 END ".
    "        foo10 BEGIN 2 * 3 * 4 END ".
    "        foo11 BEGIN 2 * (3 * 4) END ".
    "        foo12 BEGIN (2 * 3) * 4 END ".
    "        foo13 BEGIN 2 / 3 / 4 END ".
    "        foo14 BEGIN 2 / (3 / 4) END ".
    "        foo15 BEGIN (2 / 3) / 4 END ".
    "        foo16 BEGIN 2 + 3 * 4 END ".
    "        foo17 BEGIN (2 + 3) * 4 END ".
    "        foo18 BEGIN 2 * 3 + 4 END ".
    "        foo19 BEGIN 2 * 3 ^ 4 END ".
    "        foo20 BEGIN (2 * 3) ^ 4 END ".
    "        foo21 BEGIN 2 ^ 3 * 4 END ".
    "        foo22 BEGIN 2 + 3 - 4 * 5 / 2 END ".
    "        foo23 BEGIN 2 ^ 3 + 4 * 5 - 6 / 2 END ".
    "        foo24 BEGIN 2 % 3 % 4 END ".
    "        foo25 BEGIN 2 % (3 % 4) END ".
    "        foo26 BEGIN (2 % 3) % 4 END ".
    "        foo27 BEGIN 2 + 3 % 4 END ".
    "        foo28 BEGIN 2 % 3 + 4 END ".
    "        foo29 BEGIN 2 * 3 % 4 END ".
    "        foo30 BEGIN 2 % 3 * 4 END ".
    "        foo31 BEGIN 2 ^ 3 % 4 END ".
    "        foo32 BEGIN 2 % 3 ^ 4 END ".
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
  =/  expected  (mk-selection scalars ~)
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
    "SCALARS foo1 BEGIN 1+1 END ".
    "SELECT foo2,foo3"
  ::
  %+  expect-fail-message
    'PARSER: '
    |.  (parse:parse(default-database default-db) query-string)
::
::  test-fail-arithmetic-* tests verify that non-arithmetic builtin functions
::  (one that return string and date) can't be used with arithmetic operators
::
::  test mixing string function CONCAT with addition operator
++  test-fail-arithmetic-01
  ::
  =/  query-string
    "FROM foo ".
    "SCALARS foo BEGIN CONCAT('hello', 'world') + 1 END ".
    "SELECT foo2,foo3"
  ::
  %+  expect-fail-message
    'finalize-math-builtin-fn: cannot use %concat in arithmetic expression'
    |.  (parse:parse(default-database default-db) query-string)
::
::  test mixing string function LEFT with subtraction operator
++  test-fail-arithmetic-02
  ::
  =/  query-string
    "FROM foo ".
    "SCALARS foo BEGIN LEFT('hello', 2) - 5 END ".
    "SELECT foo2,foo3"
  ::
  %+  expect-fail-message
    'finalize-math-builtin-fn: cannot use %left in arithmetic expression'
    |.  (parse:parse(default-database default-db) query-string)
::
::  test mixing string function RIGHT with multiplication operator
++  test-fail-arithmetic-03
  ::
  =/  query-string
    "FROM foo ".
    "SCALARS foo BEGIN 10 * RIGHT('world', 3) END ".
    "SELECT foo2,foo3"
  ::
  %+  expect-fail-message
    'finalize-math-builtin-fn: cannot use %right in arithmetic expression'
    |.  (parse:parse(default-database default-db) query-string)
::
::  test mixing string function SUBSTRING with division operator
++  test-fail-arithmetic-04
  ::
  =/  query-string
    "FROM foo ".
    "SCALARS foo BEGIN SUBSTRING('hello', 1, 3) / 2 END ".
    "SELECT foo2,foo3"
  ::
  %+  expect-fail-message
    'finalize-math-builtin-fn: cannot use %substring in arithmetic expression'
    |.  (parse:parse(default-database default-db) query-string)
::
::  test mixing string function TRIM with exponentiation operator
++  test-fail-arithmetic-05
  ::
  =/  query-string
    "FROM foo ".
    "SCALARS foo BEGIN 2 ^ TRIM('  hello  ') END ".
    "SELECT foo2,foo3"
  ::
  %+  expect-fail-message
    'finalize-math-builtin-fn: cannot use %trim in arithmetic expression'
    |.  (parse:parse(default-database default-db) query-string)
::
::  test mixing date function GETUTCDATE with addition operator
++  test-fail-arithmetic-06
  ::
  =/  query-string
    "FROM foo ".
    "SCALARS foo BEGIN GETUTCDATE() + 100 END ".
    "SELECT foo2,foo3"
  ::
  %+  expect-fail-message
    'finalize-math-builtin-fn: cannot use %getutcdate in arithmetic expression'
    |.  (parse:parse(default-database default-db) query-string)
::
::  test mixing string on both sides of operator
++  test-fail-arithmetic-07
  ::
  =/  query-string
    "FROM foo ".
    "SCALARS foo BEGIN LEFT('abc', 1) + RIGHT('xyz', 1) END ".
    "SELECT foo2,foo3"
  ::
  %+  expect-fail-message
    'finalize-math-builtin-fn: cannot use %left in arithmetic expression'
    |.  (parse:parse(default-database default-db) query-string)
::
::  test nested arithmetic with string function
++  test-fail-arithmetic-08
  ::
  =/  query-string
    "FROM foo ".
    "SCALARS foo BEGIN (5 + CONCAT('a', 'b')) * 2 END ".
    "SELECT foo2,foo3"
  ::
  %+  expect-fail-message
    'finalize-math-builtin-fn: cannot use %concat in arithmetic expression'
    |.  (parse:parse(default-database default-db) query-string)
::
::  test single operand in arithmetic expression
++  test-fail-arithmetic-09
  ::
  =/  query-string
    "FROM foo ".
    "SCALARS foo BEGIN 42 END ".
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
  =/  expected  (mk-selection scalars ~)
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
  =/  expected  (mk-selection scalars (some table))
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
  =/  expected  (mk-selection scalars (some table))
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
  =/  expected  (mk-selection scalars (some table))
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
    "        st-sc2 STRING-CONCAT(' ') ".
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
      [%scalar 'st-qs3' [%quotestring literal-hello `[literal-open literal-close]]]
      [%scalar 'st-str' [%string literal-3]]
      [%scalar 'st-sc1' [%string ~[literal-hello literal-world] literal-space]]
      [%scalar 'st-sc2' [%string ~ literal-space]]
      [%scalar 'st-stf' [%stuff literal-hello literal-2 literal-3 literal-xx]]
      [%scalar 'loq1' [%lower qualified-col-1]]
      [%scalar 'lou1' [%lower unqualified-foo-3]]
      [%scalar 'los1' [%lower [%scalar-name name=%st-low]]]
    ==
  =/  expected  (mk-selection scalars ~)
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
    "        st-sc2 STRING-CONCAT(  ' ') ".
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
      [%scalar 'st-qs3' [%quotestring literal-hello `[literal-open literal-close]]]
      [%scalar 'st-str' [%string literal-3]]
      [%scalar 'st-sc1' [%string ~[literal-hello literal-world] literal-space]]
      [%scalar 'st-sc2' [%string ~ literal-space]]
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
  =/  expected  (mk-selection scalars (some table))
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
    "        st-sc2 STRING-CONCAT(' '  ) ".
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
      [%scalar 'st-qs3' [%quotestring literal-hello `[literal-open literal-close]]]
      [%scalar 'st-str' [%string literal-3]]
      [%scalar 'st-sc1' [%string ~[literal-hello literal-world] literal-space]]
      [%scalar 'st-sc2' [%string ~ literal-space]]
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
  =/  expected  (mk-selection scalars (some table))
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
    "        st-sc2 STRING-CONCAT(  ' '  ) ".
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
      [%scalar 'st-qs3' [%quotestring literal-hello `[literal-open literal-close]]]
      [%scalar 'st-str' [%string literal-3]]
      [%scalar 'st-sc1' [%string ~[literal-hello literal-world] literal-space]]
      [%scalar 'st-sc2' [%string ~ literal-space]]
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
  =/  expected  (mk-selection scalars (some table))
  %+  expect-eq
    !>  expected
    !>  (parse:parse(default-database default-db) query-string)
--
