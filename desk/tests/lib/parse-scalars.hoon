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
  =/  columns  ~[unqualified-col-2 unqualified-col-1]
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
++  unqualified-col-1   [%unqualified-column name=%foo3 alias=~]
++  unqualified-col-2   [%unqualified-column name=%foo2 alias=~]
::
++  simple-true-pred       [%eq [[p=~.ud q=1] ~ ~] [[p=~.ud q=1] ~ ~]]
++  simple-false-pred      [%eq [[p=~.ud q=1] ~ ~] [[p=~.ud q=0] ~ ~]]
::
++  literal-zod            [%literal-value dime=[p=%p q=0]]
++  literal-1              [%literal-value dime=[p=~.ud q=1]]
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
    "        baz-ca CASE foo3 WHEN 1 = 1 THEN foo3 ELSE foo2 END ".
    "        bar-ca case foo3 when 1 = 1 then foo3 else foo2 end ".
    "        foo-ca CasE foo3 WheN 1 = 1 TheN foo3 ElsE foo2 EnD ".
    "SELECT foo2,foo3"
  ::
  =/  coalesce
    ~[%coalesce unqualified-col-1 literal-zod literal-1 unqualified-col-1]
  =/  if
    :*  %if-then-else
      if=simple-true-pred
      then=[unqualified-col-1]
      else=[unqualified-col-2]
    ==
  =/  case
    :*
      %case
      target=unqualified-col-1
      cases=~[[%case-when-then simple-true-pred unqualified-col-1]]
      else=(some unqualified-col-2)
    ==
  =/  scalars
    :~
      [%scalar coalesce 'foo-co']
      [%scalar coalesce 'bar-co']
      [%scalar coalesce 'baz-co']
      [%scalar if 'baz-if']
      [%scalar if 'bar-if']
      [%scalar if 'foo-if']
      [%scalar case 'baz-ca']
      [%scalar case 'bar-ca']
      [%scalar case 'foo-ca']
    ==
  =/  expected  (mk-selection scalars ~)
  %+  expect-eq
    !>  expected
    !>  (parse:parse(default-database default-db) query-string)
::
::  test defining scalars with aliases in one case and referencing in another
++  test-scalars-02
  =/  query-string
    "FROM foo ".
    "SCALARS bar1 COALESCE(foo3,~zod,1,foo3) ".
    "        bar2 COALESCE(BAR1,~zod,1,foo3) ".
    "        BAR3 COALESCE(foo3,~zod,1,foo3) ".
    "        bar4 COALESCE(bar3,~zod,1,foo3) ".
    "        bar5 COALESCE(foo3,~zod,1,foo3) ".
    "        bar6 COALESCE(BAr5,~zod,1,foo3) ".
    "        Bar7 COALESCE(foo3,~zod,1,foo3) ".
    "        bar8 COALESCE(bar7,~zod,1,foo3) ".
    "SELECT foo2,foo3"
  ::
  =/  coalesce-1
    ~[%coalesce unqualified-col-1 literal-zod literal-1 unqualified-col-1]
  =/  coalesce-2
    ~[%coalesce coalesce-1 literal-zod literal-1 unqualified-col-1]
  =/  scalars
    :~
      [%scalar coalesce-1 'bar1']
      [%scalar coalesce-2 'bar2']
      [%scalar coalesce-1 'bar3']
      [%scalar coalesce-2 'bar4']
      [%scalar coalesce-1 'bar5']
      [%scalar coalesce-2 'bar6']
      [%scalar coalesce-1 'bar7']
      [%scalar coalesce-2 'bar8']
    ==
  =/  expected  (mk-selection scalars ~)
  %+  expect-eq
    !>  expected
    !>  (parse:parse(default-database default-db) query-string)
::
::  test-scalars-03 test cte-aliases (just that they are parsed correctly)
++  test-scalars-03
  =/  query-string
    "FROM foo ".
    "SCALARS bar1 COALESCE(foo3,~zod,1,foo3) ".
    "        bar2 COALESCE(Foo1,~zod,1,foo3) ".
    "SELECT foo2,foo3"
  ::
  =/  cte-alias
    [%cte-alias alias='foo1']
  =/  coalesce-1
    ~[%coalesce unqualified-col-1 literal-zod literal-1 unqualified-col-1]
  =/  coalesce-2
    ~[%coalesce cte-alias literal-zod literal-1 unqualified-col-1]
  =/  scalars
    :~
      [%scalar coalesce-1 'bar1']
      [%scalar coalesce-2 'bar2']
    ==
  =/  expected  (mk-selection scalars ~)
  %+  expect-eq
    !>  expected
    !>  (parse:parse(default-database default-db) query-string)
::
:: one of these makes it type crash
::  test mixing arithmetic with builtin functions
::     not sure if we want this to work
::    "        sc8 BEGIN POWER(CEILING(1.5), ABS(-2)) END ".
++  test-scalars-4
  =/  query-string
    "FROM foo ".
    "SCALARS sc1 BEGIN ABS(-5) + 1 END ".
    "        sc2 BEGIN FLOOR(.2.8) - CEILING(.1.2) END ".
    "        sc3 BEGIN SQRT(4) * POWER(2, 3) END ".
    "        sc4 BEGIN LOG(10) / ABS(-5) END ".
    "        sc5 BEGIN ROUND(.3.7, 0) ^ 2 END ".
    "        sc6 BEGIN LEN('hello') + DAY(2023.1.15) END ".
    "        sc7 BEGIN (ABS(-3) + FLOOR(.2.9)) * SQRT(16) END ".
    "        sc9 BEGIN YEAR(2023.6.20) - MONTH(2023.6.20) END ".
    "        sc10 BEGIN (LOG(100) + SIGN(-5)) / (SQRT(9) - 1) END ".
    "SELECT foo2,foo3"
  ::
  =/  literal-05             [%literal-value dime=[p=~.rs q=.5]]
  =/  literal-1              [%literal-value dime=[p=~.ud q=1]]
  =/  literal-28             [%literal-value dime=[p=~.rs q=.2.8]]
  =/  literal-12             [%literal-value dime=[p=~.rs q=.1.2]]
  =/  literal-4              [%literal-value dime=[p=~.ud q=4]]
  =/  literal-2              [%literal-value dime=[p=~.ud q=2]]
  =/  literal-3              [%literal-value dime=[p=~.ud q=3]]
  =/  literal-10             [%literal-value dime=[p=~.ud q=10]]
  =/  literal-neg5           [%literal-value dime=[p=~.sd q=-5]]
  =/  literal-37             [%literal-value dime=[p=~.rs q=.3.7]]
  =/  literal-0              [%literal-value dime=[p=~.ud q=0]]
  =/  literal-hello          [%literal-value dime=[p=~.t q='hello']]
  =/  literal-date1          [%literal-value dime=[p=~.da q=~2023.1.15]]
  =/  literal-neg3           [%literal-value dime=[p=~.sd q=-3]]
  =/  literal-29             [%literal-value dime=[p=~.rs q=.2.9]]
  =/  literal-16             [%literal-value dime=[p=~.ud q=16]]
  =/  literal-15             [%literal-value dime=[p=~.rs q=.1.5]]
  =/  literal-neg2           [%literal-value dime=[p=~.sd q=-2]]
  =/  literal-date2          [%literal-value dime=[p=~.da q=~2023.6.20]]
  =/  literal-100            [%literal-value dime=[p=~.ud q=100]]
  =/  literal-9              [%literal-value dime=[p=~.ud q=9]]
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
  =/  sc3
    :*
      %arithmetic
      operator=%tar
      left=[%sqrt literal-4]
      right=[%power literal-2 literal-3]
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
      left=[%round literal-37 literal-0 ~]
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
      left=[%arithmetic operator=%lus left=[%abs literal-neg3] right=[%floor literal-29]]
      right=[%sqrt literal-16]
    ==
  =/  sc8
    [%power [%ceiling literal-15] [%abs literal-neg2]]
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
      left=[%arithmetic operator=%lus left=[%log literal-100 ~] right=[%sign literal-neg5]]
      right=[%arithmetic operator=%hep left=[%sqrt literal-9] right=literal-1]
    ==
  =/  scalars
    :~
      [%scalar sc1 'sc1']
      [%scalar sc2 'sc2']
      [%scalar sc3 'sc3']
      [%scalar sc4 'sc4']
      [%scalar sc5 'sc5']
      [%scalar sc6 'sc6']
      [%scalar sc7 'sc7']
::      [%scalar `scalar-function:ast`sc8 'sc8']
      [%scalar sc9 'sc9']
      [%scalar sc10 'sc10']
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
    "        bar1 COALESCE(Foo1,~zod,1,foo3) ".
    "SELECT foo2,foo3"
  ::
  %+  expect-fail-message
    'there is already a scalar named \'bar1\''
    |.  (parse:parse(default-database default-db) query-string)
::  test-fail-scalars-02 tests that parsing fails when scalars are defined
::  without a select statement after
++  test-fail-scalars-02
  =/  query-string
    "FROM foo ".
    "SCALARS bar1 COALESCE(foo3,~zod,1,foo3) ".
    "        bar1 COALESCE(Foo1,~zod,1,foo3) "
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
    "        mt4 POWER(    .5,  2) ".
    "        mt5 CEILING(.5  ) ".
    "        mt6 ROUND(  .5 ,2   , 1  ) ".
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
    "SELECT foo2,foo3"
  ::
  =/  literal-date           [%literal-value dime=[p=~.da q=~2023.1.15]]
  =/  literal-float          [%literal-value dime=[p=~.rs q=.5]]
  =/  literal-float2         [%literal-value dime=[p=~.rs q=.2]]
  =/  literal-2              [%literal-value dime=[p=~.ud q=2]]
  =/  literal-3              [%literal-value dime=[p=~.ud q=3]]
  =/  literal-1              [%literal-value dime=[p=~.ud q=1]]
  =/  literal-hello          [%literal-value dime=[p=~.t q='hello']]
  =/  literal-world          [%literal-value dime=[p=~.t q='world']]
  =/  literal-space          [%literal-value dime=[p=~.t q=' ']]
  =/  literal-neg5           [%literal-value dime=[p=~.sd q=-5]]
  ::
  =/  getutcdate-fn          [%getutcdate ~]
  =/  day-fn                 [%day literal-date]
  =/  month-fn               [%month literal-date]
  =/  year-fn                [%year literal-date]
  =/  abs-fn                 [%abs literal-neg5]
  =/  floor-fn               [%floor literal-float]
  =/  ceiling-fn             [%ceiling literal-float]
  =/  sign-fn                [%sign literal-neg5]
  =/  sqrt-fn                [%sqrt literal-float]
  =/  len-fn                 [%len literal-hello]
  =/  left-fn                [%left literal-hello literal-3]
  =/  right-fn               [%right literal-hello literal-3]
  =/  power-fn               [%power literal-float literal-2]
  =/  log-fn-1               [%log literal-float `literal-2]
  =/  log-fn-2               [%log literal-float ~]
  =/  trim-fn-1              [%trim `literal-space literal-hello]
  =/  trim-fn-2              [%trim ~ literal-hello]
  =/  concat-fn              [%concat ~[literal-hello literal-world]]
  =/  round-fn-1             [%round literal-float literal-2 `literal-1]
  =/  round-fn-2             [%round literal-float literal-2 ~]
  =/  substring-fn           [%substring literal-hello literal-2 literal-3]
  =/  scalars
    :~
      [%scalar getutcdate-fn 'dt1']
      [%scalar day-fn 'dt3']
      [%scalar month-fn 'dt4']
      [%scalar year-fn 'dt5']
      [%scalar abs-fn 'mt1']
      [%scalar log-fn-1 'mt2']
      [%scalar log-fn-2 'mt21']
      [%scalar floor-fn 'mt3']
      [%scalar power-fn 'mt4']
      [%scalar ceiling-fn 'mt5']
      [%scalar round-fn-1 'mt6']
      [%scalar round-fn-2 'mt61']
      [%scalar sign-fn 'mt7']
      [%scalar sqrt-fn 'mt8']
      [%scalar len-fn 'st1']
      [%scalar left-fn 'st2']
      [%scalar right-fn 'st3']
      [%scalar substring-fn 'st4']
      [%scalar trim-fn-1 'st5']
      [%scalar trim-fn-2 'st51']
      [%scalar concat-fn 'st6']
    ==
  =/  expected  (mk-selection scalars ~)
  %+  expect-eq
    !>  expected
    !>  (parse:parse(default-database default-db) query-string)
::
::  spaces before parameters
++  test-builtins-02
  =/  query-string
    "FROM foo ".
    "SCALARS dt1 GETUTCDATE() ".
    "        dt3 DAY(  2023.1.15) ".
    "        dt4 MONTH(   2023.1.15) ".
    "        dt5 YEAR( 2023.1.15) ".
    "        mt1 ABS(    -5) ".
    "        mt2 LOG( .5,   2) ".
    "        mt3 FLOOR(  .5) ".
    "        mt4 POWER(   .5, 2) ".
    "        mt5 CEILING( .5) ".
    "        mt6 ROUND(    .5,  2, 1) ".
    "        mt7 SIGN(  -5) ".
    "        mt8 SQRT(   .5) ".
    "        st1 LEN( 'hello') ".
    "        st2 LEFT(    'hello',  3) ".
    "        st3 RIGHT(  'hello',   3) ".
    "        st4 SUBSTRING( 'hello',    2,  3) ".
    "        st5 TRIM(   ' ', 'hello') ".
    "        st6 CONCAT(  'hello',    'world') ".
    "SELECT foo2,foo3"
  ::
  =/  literal-date           [%literal-value dime=[p=~.da q=~2023.1.15]]
  =/  literal-float          [%literal-value dime=[p=~.rs q=.5]]
  =/  literal-float2         [%literal-value dime=[p=~.rs q=.2]]
  =/  literal-2              [%literal-value dime=[p=~.ud q=2]]
  =/  literal-3              [%literal-value dime=[p=~.ud q=3]]
  =/  literal-1              [%literal-value dime=[p=~.ud q=1]]
  =/  literal-hello          [%literal-value dime=[p=~.t q='hello']]
  =/  literal-world          [%literal-value dime=[p=~.t q='world']]
  =/  literal-space          [%literal-value dime=[p=~.t q=' ']]
  =/  literal-neg5           [%literal-value dime=[p=~.sd q=-5]]
  ::
  =/  getutcdate-fn          [%getutcdate ~]
  =/  day-fn                 [%day literal-date]
  =/  month-fn               [%month literal-date]
  =/  year-fn                [%year literal-date]
  =/  abs-fn                 [%abs literal-neg5]
  =/  floor-fn               [%floor literal-float]
  =/  ceiling-fn             [%ceiling literal-float]
  =/  sign-fn                [%sign literal-neg5]
  =/  sqrt-fn                [%sqrt literal-float]
  =/  len-fn                 [%len literal-hello]
  =/  left-fn                [%left literal-hello literal-3]
  =/  right-fn               [%right literal-hello literal-3]
  =/  power-fn               [%power literal-float literal-2]
  =/  log-fn                 [%log literal-float `literal-2]
  =/  trim-fn                [%trim `literal-space literal-hello]
  =/  concat-fn              [%concat ~[literal-hello literal-world]]
  =/  round-fn               [%round literal-float literal-2 `literal-1]
  =/  substring-fn           [%substring literal-hello literal-2 literal-3]
  =/  scalars
    :~
      [%scalar getutcdate-fn 'dt1']
      [%scalar day-fn 'dt3']
      [%scalar month-fn 'dt4']
      [%scalar year-fn 'dt5']
      [%scalar abs-fn 'mt1']
      [%scalar log-fn 'mt2']
      [%scalar floor-fn 'mt3']
      [%scalar power-fn 'mt4']
      [%scalar ceiling-fn 'mt5']
      [%scalar round-fn 'mt6']
      [%scalar sign-fn 'mt7']
      [%scalar sqrt-fn 'mt8']
      [%scalar len-fn 'st1']
      [%scalar left-fn 'st2']
      [%scalar right-fn 'st3']
      [%scalar substring-fn 'st4']
      [%scalar trim-fn 'st5']
      [%scalar concat-fn 'st6']
    ==
  =/  expected  (mk-selection scalars ~)
  %+  expect-eq
    !>  expected
    !>  (parse:parse(default-database default-db) query-string)
::
::  spaces after parameters
++  test-builtins-03
  =/  query-string
    "FROM foo ".
    "SCALARS dt1 GETUTCDATE() ".
    "        dt3 DAY(2023.1.15  ) ".
    "        dt4 MONTH(2023.1.15    ) ".
    "        dt5 YEAR(2023.1.15 ) ".
    "        mt1 ABS(-5     ) ".
    "        mt2 LOG(.5  ,2   ) ".
    "        mt3 FLOOR(.5   ) ".
    "        mt4 POWER(.5    ,2 ) ".
    "        mt5 CEILING(.5  ) ".
    "        mt6 ROUND(.5     ,2  ,1    ) ".
    "        mt7 SIGN(-5   ) ".
    "        mt8 SQRT(.5    ) ".
    "        st1 LEN('hello'  ) ".
    "        st2 LEFT('hello'     ,3  ) ".
    "        st3 RIGHT('hello'   ,3    ) ".
    "        st4 SUBSTRING('hello'  ,2     ,3   ) ".
    "        st5 TRIM(' '    ,'hello'  ) ".
    "        st6 CONCAT('hello'   ,'world'     ) ".
    "SELECT foo2,foo3"
  ::
  =/  literal-date           [%literal-value dime=[p=~.da q=~2023.1.15]]
  =/  literal-float          [%literal-value dime=[p=~.rs q=.5]]
  =/  literal-float2         [%literal-value dime=[p=~.rs q=.2]]
  =/  literal-2              [%literal-value dime=[p=~.ud q=2]]
  =/  literal-3              [%literal-value dime=[p=~.ud q=3]]
  =/  literal-1              [%literal-value dime=[p=~.ud q=1]]
  =/  literal-hello          [%literal-value dime=[p=~.t q='hello']]
  =/  literal-world          [%literal-value dime=[p=~.t q='world']]
  =/  literal-space          [%literal-value dime=[p=~.t q=' ']]
  =/  literal-neg5           [%literal-value dime=[p=~.sd q=-5]]
  ::
  =/  getutcdate-fn          [%getutcdate ~]
  =/  day-fn                 [%day literal-date]
  =/  month-fn               [%month literal-date]
  =/  year-fn                [%year literal-date]
  =/  abs-fn                 [%abs literal-neg5]
  =/  floor-fn               [%floor literal-float]
  =/  ceiling-fn             [%ceiling literal-float]
  =/  sign-fn                [%sign literal-neg5]
  =/  sqrt-fn                [%sqrt literal-float]
  =/  len-fn                 [%len literal-hello]
  =/  left-fn                [%left literal-hello literal-3]
  =/  right-fn               [%right literal-hello literal-3]
  =/  power-fn               [%power literal-float literal-2]
  =/  log-fn                 [%log literal-float `literal-2]
  =/  trim-fn                [%trim `literal-space literal-hello]
  =/  concat-fn              [%concat ~[literal-hello literal-world]]
  =/  round-fn               [%round literal-float literal-2 `literal-1]
  =/  substring-fn           [%substring literal-hello literal-2 literal-3]
  =/  scalars
    :~
      [%scalar getutcdate-fn 'dt1']
      [%scalar day-fn 'dt3']
      [%scalar month-fn 'dt4']
      [%scalar year-fn 'dt5']
      [%scalar abs-fn 'mt1']
      [%scalar log-fn 'mt2']
      [%scalar floor-fn 'mt3']
      [%scalar power-fn 'mt4']
      [%scalar ceiling-fn 'mt5']
      [%scalar round-fn 'mt6']
      [%scalar sign-fn 'mt7']
      [%scalar sqrt-fn 'mt8']
      [%scalar len-fn 'st1']
      [%scalar left-fn 'st2']
      [%scalar right-fn 'st3']
      [%scalar substring-fn 'st4']
      [%scalar trim-fn 'st5']
      [%scalar concat-fn 'st6']
    ==
  =/  expected  (mk-selection scalars ~)
  %+  expect-eq
    !>  expected
     !>  (parse:parse(default-database default-db) query-string)
::
::  spaces before and after parameters
++  test-builtins-04
  =/  query-string
    "FROM foo ".
    "SCALARS dt1 GETUTCDATE() ".
    "        dt3 DAY(  2023.1.15    ) ".
    "        dt4 MONTH(   2023.1.15  ) ".
    "        dt5 YEAR( 2023.1.15     ) ".
    "        mt1 ABS(    -5  ) ".
    "        mt2 LOG(  .5   ,   2    ) ".
    "        mt3 FLOOR(   .5     ) ".
    "        mt4 POWER( .5    ,  2  ) ".
    "        mt5 CEILING(    .5   ) ".
    "        mt6 ROUND(  .5     ,   2  ,  1     ) ".
    "        mt7 SIGN(   -5    ) ".
    "        mt8 SQRT( .5     ) ".
    "        st1 LEN(    'hello'  ) ".
    "        st2 LEFT(  'hello'    ,   3   ) ".
    "        st3 RIGHT(   'hello'  ,    3     ) ".
    "        st4 SUBSTRING( 'hello'     ,  2    ,   3  ) ".
    "        st5 TRIM(    ' '   ,  'hello'     ) ".
    "        st6 CONCAT(  'hello'     ,    'world'  ) ".
    "SELECT foo2,foo3"
  ::
  =/  literal-date           [%literal-value dime=[p=~.da q=~2023.1.15]]
  =/  literal-float          [%literal-value dime=[p=~.rs q=.5]]
  =/  literal-float2         [%literal-value dime=[p=~.rs q=.2]]
  =/  literal-2              [%literal-value dime=[p=~.ud q=2]]
  =/  literal-3              [%literal-value dime=[p=~.ud q=3]]
  =/  literal-1              [%literal-value dime=[p=~.ud q=1]]
  =/  literal-hello          [%literal-value dime=[p=~.t q='hello']]
  =/  literal-world          [%literal-value dime=[p=~.t q='world']]
  =/  literal-space          [%literal-value dime=[p=~.t q=' ']]
  =/  literal-neg5           [%literal-value dime=[p=~.sd q=-5]]
  ::
  =/  getutcdate-fn          [%getutcdate ~]
  =/  day-fn                 [%day literal-date]
  =/  month-fn               [%month literal-date]
  =/  year-fn                [%year literal-date]
  =/  abs-fn                 [%abs literal-neg5]
  =/  floor-fn               [%floor literal-float]
  =/  ceiling-fn             [%ceiling literal-float]
  =/  sign-fn                [%sign literal-neg5]
  =/  sqrt-fn                [%sqrt literal-float]
  =/  len-fn                 [%len literal-hello]
  =/  left-fn                [%left literal-hello literal-3]
  =/  right-fn               [%right literal-hello literal-3]
  =/  power-fn               [%power literal-float literal-2]
  =/  log-fn                 [%log literal-float `literal-2]
  =/  trim-fn                [%trim `literal-space literal-hello]
  =/  concat-fn              [%concat ~[literal-hello literal-world]]
  =/  round-fn               [%round literal-float literal-2 `literal-1]
  =/  substring-fn           [%substring literal-hello literal-2 literal-3]
  =/  scalars
    :~
      [%scalar getutcdate-fn 'dt1']
      [%scalar day-fn 'dt3']
      [%scalar month-fn 'dt4']
      [%scalar year-fn 'dt5']
      [%scalar abs-fn 'mt1']
      [%scalar log-fn 'mt2']
      [%scalar floor-fn 'mt3']
      [%scalar power-fn 'mt4']
      [%scalar ceiling-fn 'mt5']
      [%scalar round-fn 'mt6']
      [%scalar sign-fn 'mt7']
      [%scalar sqrt-fn 'mt8']
      [%scalar len-fn 'st1']
      [%scalar left-fn 'st2']
      [%scalar right-fn 'st3']
      [%scalar substring-fn 'st4']
      [%scalar trim-fn 'st5']
      [%scalar concat-fn 'st6']
    ==
  =/  expected  (mk-selection scalars ~)
  %+  expect-eq
    !>  expected
    !>  (parse:parse(default-database default-db) query-string)
::
::  test type mistmatch for %day
++  test-fail-builtins-day-01
  ::
  =/  query-string
    "FROM foo ".
    "SCALARS foo DAY('hello') ".
    "SELECT foo2,foo3"
  ::
  %+  expect-fail-message
    'mismatched type for day builtin, have: ~.t, need: ~.da'
    |.  (parse:parse(default-database default-db) query-string)
::
::  test type mismatch for %month
++  test-fail-builtins-month-01
  ::
  =/  query-string
    "FROM foo ".
    "SCALARS foo MONTH('hello') ".
    "SELECT foo2,foo3"
  ::
  %+  expect-fail-message
    'mismatched type for month builtin, have: ~.t, need: ~.da'
    |.  (parse:parse(default-database default-db) query-string)
::
::  test type mismatch for %year
++  test-fail-builtins-year-01
  ::
  =/  query-string
    "FROM foo ".
    "SCALARS foo YEAR(123) ".
    "SELECT foo2,foo3"
  ::
  %+  expect-fail-message
    'mismatched type for year builtin, have: ~.ud, need: ~.da'
    |.  (parse:parse(default-database default-db) query-string)
::
::  test type mismatch for %abs
++  test-fail-builtins-abs-01
  ::
  =/  query-string
    "FROM foo ".
    "SCALARS foo ABS('hello') ".
    "SELECT foo2,foo3"
  ::
  %+  expect-fail-message
    'mismatched type for abs builtin, have: ~.t, need: ~.sd'
    |.  (parse:parse(default-database default-db) query-string)
::
::  test type mismatch for %floor
++  test-fail-builtins-floor-01
  ::
  =/  query-string
    "FROM foo ".
    "SCALARS foo FLOOR('hello') ".
    "SELECT foo2,foo3"
  ::
  %+  expect-fail-message
    'mismatched type for floor builtin, have: ~.t, need: ~.rs'
    |.  (parse:parse(default-database default-db) query-string)
::
::  test type mismatch for %ceiling
++  test-fail-builtins-ceiling-01
  ::
  =/  query-string
    "FROM foo ".
    "SCALARS foo CEILING('hello') ".
    "SELECT foo2,foo3"
  ::
  %+  expect-fail-message
    'mismatched type for ceiling builtin, have: ~.t, need: [~.rs ~.sd ~]'
    |.  (parse:parse(default-database default-db) query-string)
::
::  test type mismatch for %sign
++  test-fail-builtins-sign-01
  ::
  =/  query-string
    "FROM foo ".
    "SCALARS foo SIGN(2023.1.15) ".
    "SELECT foo2,foo3"
  ::
  %+  expect-fail-message
    'mismatched type for sign builtin, have: ~.da, need: ~.sd'
    |.  (parse:parse(default-database default-db) query-string)
::
::  test type mismatch for %sqrt
++  test-fail-builtins-sqrt-01
  ::
  =/  query-string
    "FROM foo ".
    "SCALARS foo SQRT('hello') ".
    "SELECT foo2,foo3"
  ::
  %+  expect-fail-message
    'mismatched type for sqrt builtin, have: ~.t, need: [~.rs ~.ud ~]'
    |.  (parse:parse(default-database default-db) query-string)
::
::  test type mismatch for %len
++  test-fail-builtins-len-01
  ::
  =/  query-string
    "FROM foo ".
    "SCALARS foo LEN(123) ".
    "SELECT foo2,foo3"
  ::
  %+  expect-fail-message
    'mismatched type for len builtin, have: ~.ud, need: ~.t'
    |.  (parse:parse(default-database default-db) query-string)
::
::  test type mismatch for %log first parameter
++  test-fail-builtins-log-01
  ::
  =/  query-string
    "FROM foo ".
    "SCALARS foo LOG('hello') ".
    "SELECT foo2,foo3"
  ::
  %+  expect-fail-message 
    'mismatched type for log builtin, have: ~.t, need: [~.rs ~.ud ~]'
    |.  (parse:parse(default-database default-db) query-string)
::
::  test type mismatch for %log second parameter
++  test-fail-builtins-log-02
  ::
  =/  query-string
    "FROM foo ".
    "SCALARS foo LOG(10, 'hello') ".
    "SELECT foo2,foo3"
  ::
  %+  expect-fail-message
    'mismatched type for log builtin, \
    /have: [~.ud ~.t ~], need: [[~.rs ~.ud ~] ~.ud ~]'
    |.  (parse:parse(default-database default-db) query-string)
::
::  test type mismatch for %power first parameter
++  test-fail-builtins-power-01
  ::
  =/  query-string
    "FROM foo ".
    "SCALARS foo POWER('hello', 2) ".
    "SELECT foo2,foo3"
  ::
  %+  expect-fail-message
    'mismatched type for power builtin, \
    /have: [~.t ~.ud ~], need: [[~.rs ~.ud ~] ~.ud ~]'
    |.  (parse:parse(default-database default-db) query-string)
::
::  test type mismatch for %power second parameter
++  test-fail-builtins-power-02
  ::
  =/  query-string
    "FROM foo ".
    "SCALARS foo POWER(2, 'hello') ".
    "SELECT foo2,foo3"
  ::
  %+  expect-fail-message
    'mismatched type for power builtin, \
    /have: [~.ud ~.t ~], need: [[~.rs ~.ud ~] ~.ud ~]'
    |.  (parse:parse(default-database default-db) query-string)
::
::  test type mismatch for %left first parameter
++  test-fail-builtins-left-01
  ::
  =/  query-string
    "FROM foo ".
    "SCALARS foo LEFT(123, 3) ".
    "SELECT foo2,foo3"
  ::
  %+  expect-fail-message
    'mismatched type for left builtin, have: [~.ud ~.ud ~], need: [~.t ~.ud ~]'
    |.  (parse:parse(default-database default-db) query-string)
::
::  test type mismatch for %left second parameter
++  test-fail-builtins-left-02
  ::
  =/  query-string
    "FROM foo ".
    "SCALARS foo LEFT('hello', 'world') ".
    "SELECT foo2,foo3"
  ::
  %+  expect-fail-message
    'mismatched type for left builtin, have: [~.t ~.t ~], need: [~.t ~.ud ~]'
    |.  (parse:parse(default-database default-db) query-string)
::
::  test type mismatch for %right first parameter
++  test-fail-builtins-right-01
  ::
  =/  query-string
    "FROM foo ".
    "SCALARS foo RIGHT(2023.1.15, 3) ".
    "SELECT foo2,foo3"
  ::
  %+  expect-fail-message
    'mismatched type for right builtin, have: [~.da ~.ud ~], need: [~.t ~.ud ~]'
    |.  (parse:parse(default-database default-db) query-string)
::
::  test type mismatch for %right second parameter
++  test-fail-builtins-right-02
  ::
  =/  query-string
    "FROM foo ".
    "SCALARS foo RIGHT('hello', .5) ".
    "SELECT foo2,foo3"
  ::
  %+  expect-fail-message
    'mismatched type for right builtin, have: [~.t ~.rs ~], need: [~.t ~.ud ~]'
    |.  (parse:parse(default-database default-db) query-string)
::
::  test type mismatch for %trim first parameter
++  test-fail-builtins-trim-01
  ::
  =/  query-string
    "FROM foo ".
    "SCALARS foo TRIM(123, 'hello') ".
    "SELECT foo2,foo3"
  ::
  %+  expect-fail-message
    'mismatched type for trim builtin, have: [~.ud ~.t ~], need: [~.t ~.t ~]'
    |.  (parse:parse(default-database default-db) query-string)
::
::  test type mismatch for %trim second parameter
++  test-fail-builtins-trim-02
  ::
  =/  query-string
    "FROM foo ".
    "SCALARS foo TRIM(' ', 123) ".
    "SELECT foo2,foo3"
  ::
  %+  expect-fail-message
    'mismatched type for trim builtin, have: [~.t ~.ud ~], need: [~.t ~.t ~]'
    |.  (parse:parse(default-database default-db) query-string)
::
::  test type mismatch for %round first parameter
++  test-fail-builtins-round-01
  ::
  =/  query-string
    "FROM foo ".
    "SCALARS foo ROUND('hello', 2) ".
    "SELECT foo2,foo3"
  ::
  %+  expect-fail-message
    'mismatched type for round builtin, have: [~.t ~.ud ~], need: [~.rs ~.ud ~]'
    |.  (parse:parse(default-database default-db) query-string)
::
::  test type mismatch for %round second parameter
++  test-fail-builtins-round-02
  ::
  =/  query-string
    "FROM foo ".
    "SCALARS foo ROUND(.3.14, 'hello') ".
    "SELECT foo2,foo3"
  ::
  %+  expect-fail-message
    'mismatched type for round builtin, have: [~.rs ~.t ~], need: [~.rs ~.ud ~]'
    |.  (parse:parse(default-database default-db) query-string)
::
::  test type mismatch for %round third parameter
++  test-fail-builtins-round-03
  ::
  =/  query-string
    "FROM foo ".
    "SCALARS foo ROUND(.3.14, 2, 'h') ".
    "SELECT foo2,foo3"
  ::
  %+  expect-fail-message
    'mismatched type for round builtin, have: [~.rs ~.ud ~.t ~], need: [~.rs ~.ud ~.ud ~]'
    |.  (parse:parse(default-database default-db) query-string)
::
::  test type mismatch for %substring first parameter
++  test-fail-builtins-substring-01
  ::
  =/  query-string
    "FROM foo ".
    "SCALARS foo SUBSTRING(123, 2, 3) ".
    "SELECT foo2,foo3"
  ::
  %+  expect-fail-message
    'mismatched type for substring builtin, have: [~.ud ~.ud ~.ud ~], need: [~.t ~.ud ~.ud ~]'
    |.  (parse:parse(default-database default-db) query-string)
::
::  test type mismatch for %substring second parameter
++  test-fail-builtins-substring-02
  ::
  =/  query-string
    "FROM foo ".
    "SCALARS foo SUBSTRING('hello', 'world', 3) ".
    "SELECT foo2,foo3"
  ::
  %+  expect-fail-message
    'mismatched type for substring builtin, have: [~.t ~.t ~.ud ~], need: [~.t ~.ud ~.ud ~]'
    |.  (parse:parse(default-database default-db) query-string)
::
::  test type mismatch for %substring third parameter
++  test-fail-builtins-substring-03
  ::
  =/  query-string
    "FROM foo ".
    "SCALARS foo SUBSTRING('hello', 2, .5) ".
    "SELECT foo2,foo3"
  ::
  %+  expect-fail-message
    'mismatched type for substring builtin, have: [~.t ~.ud ~.rs ~], need: [~.t ~.ud ~.ud ~]'
    |.  (parse:parse(default-database default-db) query-string)
::
::  test type mismatch for %concat
++  test-fail-builtins-concat-01
  ::
  =/  query-string
    "FROM foo ".
    "SCALARS foo CONCAT('hello', 123, 'world') ".
    "SELECT foo2,foo3"
  ::
  %+  expect-fail-message
    'mismatched type for concat builtin, have: ~.ud, need: ~.t'
    |.  (parse:parse(default-database default-db) query-string)
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
    ~[%coalesce unqualified-col-2 literal-zod literal-1 unqualified-col-1]
  =/  scalars
    :~
      [%scalar coalesce-1 'foo']
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
    ~[%coalesce unqualified-col-2 literal-zod literal-1 unqualified-col-1]
  =/  scalars
    :~
      [%scalar coalesce-1 'foo']
      [%scalar coalesce-1 'baz']
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
    [%coalesce data=~[qualified-col-1 literal-zod literal-1 unqualified-col-1]]
  =/  scalars
    :~
      [%scalar coalesce-1 'foo']
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
    ~[%coalesce qualified-col-2 literal-zod literal-1 unqualified-col-1]
  =/  scalars
    :~
      [%scalar coalesce-1 'foo']
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
    ~[%coalesce qualified-col-3 literal-zod literal-1 unqualified-col-1]
  =/  scalars
    :~
      [%scalar coalesce-1 'foo']
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
    ~[%coalesce qualified-col-4 literal-zod literal-1 unqualified-col-1]
  =/  scalars
    :~
      [%scalar coalesce-1 'foo']
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
    ~[%coalesce qualified-col-5 literal-zod literal-1 unqualified-col-1]
  =/  scalars
    :~
      [%scalar coalesce-1 'foo']
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
    ~[%coalesce qualified-col-6 literal-zod literal-1 unqualified-col-1]
  =/  scalars
    :~
      [%scalar coalesce-1 'foo']
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
      then=[unqualified-col-1]
      else=[unqualified-col-2]
    ==
  =/  coalesce-1
    ~[%coalesce naked-if unqualified-col-2 literal-1 unqualified-col-1]
  =/  scalars
    :~
      [%scalar naked-if 'foo']
      [%scalar coalesce-1 'bar']
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
    "SCALARS foo CASE foo3 WHEN 1 = 1 THEN foo3 END ".
    "        bar COALESCE(foo,foo2,1,foo3) ".
    "SELECT foo2,foo3"
  ::
  =/  naked-case
    [%case unqualified-col-1 ~[[%case-when-then simple-true-pred unqualified-col-1]] ~]
  =/  coalesce-1
    ~[%coalesce naked-case unqualified-col-2 literal-1 unqualified-col-1]
  =/  scalars
    :~
      [%scalar naked-case 'foo']
      [%scalar coalesce-1 'bar']
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
    ~[%coalesce literal-zod unqualified-col-2 literal-1 unqualified-col-1]
  =/  coalesce-1
    ~[%coalesce naked-coalesce unqualified-col-2 literal-1 unqualified-col-1]
  =/  scalars
    :~
      [%scalar naked-coalesce 'foo']
      [%scalar coalesce-1 'bar']
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
    ~[%coalesce literal-zod unqualified-col-2 literal-1 unqualified-col-1]
  =/  first-coalesce
    ~[%coalesce second-coalesce unqualified-col-2 literal-1 unqualified-col-1]
  =/  coalesce-1
    ~[%coalesce first-coalesce unqualified-col-2 literal-1 unqualified-col-1]
  =/  scalars
    :~
      [%scalar second-coalesce 'baz']
      [%scalar first-coalesce 'bar']
      [%scalar coalesce-1 'foo']
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
    ~[%coalesce unqualified-col-1 literal-zod literal-1 unqualified-col-1]
  =/  scalars
    :~
      [%scalar coalesce-1 'foo']
    ==
  =/  expected  (mk-selection scalars ~)
  %+  expect-eq
    !>  expected
    !>  (parse:parse(default-database default-db) query-string)
::
++  test-fail-coalesce-01
  ::
  =/  query-string
    "FROM foo ".
    "SCALARS foo COALESCE(MyTable.bar,~zod,1,foo3) ".
    "SELECT foo2,foo3"
  ::
  =/  coalesce-1
    ~[%coalesce qualified-col-6 literal-zod literal-1 unqualified-col-1]
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
      then=[unqualified-col-1]
      else=[unqualified-col-2]
    ==
  =/  scalars  ~[[%scalar naked-if 'foo']]
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
      then=[unqualified-col-1]
      else=[unqualified-col-2]
    ==
  =/  scalars
    :~
      [%scalar naked-if 'foo']
      [%scalar naked-if 'baz']
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
  =/  scalars  ~[[%scalar naked-if 'foo']]
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
  =/  scalars  ~[[%scalar naked-if 'foo']]
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
  =/  scalars  ~[[%scalar naked-if 'foo']]
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
  =/  scalars  ~[[%scalar naked-if 'foo']]
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
  =/  scalars  ~[[%scalar naked-if 'foo']]
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
  =/  scalars  ~[[%scalar naked-if 'foo']]
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
    ~[%coalesce unqualified-col-2 literal-1 unqualified-col-2]
  =/  if-1
    :*
      %if-then-else
      if=simple-true-pred
      then=[naked-coalesce]
      else=[unqualified-col-2]
    ==
  =/  scalars
    :~
      [%scalar naked-coalesce 'foo']
      [%scalar if-1 'bar']
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
    "SCALARS foo CASE foo3 WHEN 1 = 1 THEN foo3 END ".
    "        bar IF 1 = 1 THEN foo ELSE foo2 ENDIF ".
    "SELECT foo2,foo3"
  ::
  =/  naked-case
    :*  %case
      unqualified-col-1
      ~[[%case-when-then simple-true-pred unqualified-col-1]]
      ~
    ==
  =/  if-1
    :*
      %if-then-else
      if=simple-true-pred
      then=[naked-case]
      else=[unqualified-col-2]
    ==
  =/  scalars
    :~
      [%scalar naked-case 'foo']
      [%scalar if-1 'bar']
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
      then=[unqualified-col-1]
      else=[unqualified-col-2]
    ==
  =/  if-1
    :*
      %if-then-else
      if=simple-true-pred
      then=[naked-if]
      else=[unqualified-col-2]
    ==
  =/  scalars
    :~
      [%scalar naked-if 'foo']
      [%scalar if-1 'bar']
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
      then=[unqualified-col-1]
      else=[unqualified-col-2]
    ==
  =/  first-if
    :*
      %if-then-else
      if=simple-true-pred
      then=[second-if]
      else=[unqualified-col-2]
    ==
  =/  if-1
    :*
      %if-then-else
      if=simple-true-pred
      then=[first-if]
      else=[unqualified-col-2]
    ==
  =/  scalars
    :~
      [%scalar second-if 'baz']
      [%scalar first-if 'bar']
      [%scalar if-1 'foo']
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
:: test if with coalesce scalar inline
::  simple case with predicate
++  test-case-01
  ::
  =/  query-string
    "FROM foo ".
    "SCALARS foobar CASE foo3 WHEN 1 = 1 THEN foo3 ELSE foo3 END ".
    "SELECT foo2,foo3"
  ::
  =/  case
    :*  %case
      unqualified-col-1
      ~[[%case-when-then simple-true-pred unqualified-col-1]]
      (some unqualified-col-1)
    ==
  =/  scalars  ~[[%scalar case 'foobar']]
  =/  expected  (mk-selection scalars ~)
  %+  expect-eq
    !>  expected
    !>  (parse:parse(default-database default-db) query-string)

::  simple case with predicate, no else
++  test-case-02
  ::
  =/  query-string
    "FROM foo ".
    "SCALARS foobaz CASE foo3 WHEN 1 = 1 THEN foo3 END ".
    "SELECT foo2,foo3"
  ::
  =/  case-when-then  [%case-when-then simple-true-pred unqualified-col-1] 
  =/  case
    :+  %scalar
      [%case unqualified-col-1 ~[case-when-then] ~]
    'foobaz'
  =/  scalars  ~[case]
  =/  expected  (mk-selection scalars ~)
  %+  expect-eq
    !>  expected
    !>  (parse:parse(default-database default-db) query-string)

::  simple case with predicate, two cases, one with else, the other without
++  test-case-03
  ::
  =/  query-string
    "FROM foo ".
    "SCALARS foobaz CASE foo3 WHEN 1 = 1 THEN foo3 END ".
    "        foobar CASE foo3 WHEN 1 = 1 THEN foo3 ELSE foo2 END ".
    "SELECT foo2,foo3"
  ::
  =/  case-1
    :*  %case
      unqualified-col-1
      ~[[%case-when-then simple-true-pred unqualified-col-1]]
      ~
    ==
  =/  case-2
    :*  %case
      unqualified-col-1
      ~[[%case-when-then simple-true-pred unqualified-col-1]]
      (some unqualified-col-2)
    ==
  =/  scalars  ~[[%scalar case-1 'foobaz'] [%scalar case-2 'foobar']]
  =/  expected  (mk-selection scalars ~)
  %+  expect-eq
    !>  expected
    !>  (parse:parse(default-database default-db) query-string)
::
::  simple case with predicate, two cases in the same scalar
++  test-case-04
  ::
  =/  query-string
    "FROM foo ".
    "SCALARS foobaz CASE foo3 ".
    "                 WHEN 1 = 1 THEN foo3".
    "                 WHEN 1 = 1 THEN foo3".
    "                END ".
    "        foobar CASE foo3 ".
    "                 WHEN 1 = 1 THEN foo3".
    "                 WHEN 1 = 1 THEN foo3".
    "               ELSE foo2 END ".
    "SELECT foo2,foo3"
  ::
  =/  case-1
    :*  %case
      unqualified-col-1
      :~  [%case-when-then simple-true-pred unqualified-col-1]
          [%case-when-then simple-true-pred unqualified-col-1]
      ==
      ~
    ==
  =/  case-2
    :*  %case
      unqualified-col-1
      :~  [%case-when-then simple-true-pred unqualified-col-1]
          [%case-when-then simple-true-pred unqualified-col-1]
      ==
      (some unqualified-col-2)
    ==
  =/  scalars  ~[[%scalar case-1 'foobaz'] [%scalar case-2 'foobar']]
  =/  expected  (mk-selection scalars ~)
  %+  expect-eq
    !>  expected
    !>  (parse:parse(default-database default-db) query-string)
::
:: qualified column case scalar with ship.database.namespace.table.column
++  test-case-05
  ::
  =/  query-string
    "FROM foo ".
    "SCALARS foo ".
    "CASE ~sampel-palnet.db2.dba.table1.bar ".
    "WHEN 1 = 1 ".
    "THEN ~sampel-palnet.db2.dba.table1.bar ".
    "ELSE ~sampel-palnet.db2.dba.table1.bar ".
    "END ".
    "SELECT foo2,foo3"
  ::
  =/  case-qualified
    :*  %case
      qualified-col-1
      ~[[%case-when-then simple-true-pred qualified-col-1]]
      (some qualified-col-1)
    ==
  =/  scalars  ~[[%scalar case-qualified 'foo']]
  =/  expected  (mk-selection scalars ~)
  %+  expect-eq
    !>  expected
    !>  (parse:parse(default-database default-db) query-string)
::
:: qualified column case scalar with WHEN clause using a datum
::++  test-case-05
::  ::
::  =/  query-string
::    "FROM foo ".
::    "SCALARS foo ".
::    "CASE ~sampel-palnet.db2.dba.table1.bar ".
::    "WHEN 1 ".
::    "THEN ~sampel-palnet.db2.dba.table1.bar ".
::    "ELSE ~sampel-palnet.db2.dba.table1.bar ".
::    "END ".
::    "SELECT foo2,foo3"
::  ::
::  =/  case-qualified
::    :*  %case
::      qualified-col-1
::      ~[`case-when-then:ast`[literal-1 qualified-col-1]]
::      (some qualified-col-1)
::    ==
::  =/  scalars  ~[[%scalar case-qualified 'foo']]
::  =/  expected  (mk-selection scalars ~)
::  %+  expect-eq
::    !>  expected
::    !>  (parse:parse(default-database default-db) query-string)
::
:: qualified column case scalar with ship.database..table.column (default ns)
++  test-case-06
  ::
  =/  query-string
    "FROM foo ".
    "SCALARS foo ".
    "CASE ~sampel-palnet.db2..table1.bar ".
    "WHEN 1 = 1 ".
    "THEN ~sampel-palnet.db2..table1.bar ".
    "ELSE ~sampel-palnet.db2..table1.bar ".
    "END ".
    "SELECT foo2,foo3"
  ::
  =/  case-qualified
    :*  %case
      qualified-col-2
      ~[[%case-when-then simple-true-pred qualified-col-2]]
      (some qualified-col-2)
    ==
  =/  scalars  ~[[%scalar case-qualified 'foo']]
  =/  expected  (mk-selection scalars ~)
  %+  expect-eq
    !>  expected
    !>  (parse:parse(default-database default-db) query-string)
::
:: qualified column case scalar with database.namespace.table.column
++  test-case-07
  ::
  =/  query-string
    "FROM foo ".
    "SCALARS foo ".
    "CASE db2.dba.table1.bar ".
    "WHEN 1 = 1 ".
    "THEN db2.dba.table1.bar ".
    "ELSE db2.dba.table1.bar ".
    "END ".
    "SELECT foo2,foo3"
  ::
  =/  case-qualified
    :*  %case
      qualified-col-3
      ~[[%case-when-then simple-true-pred qualified-col-3]]
      (some qualified-col-3)
    ==
  =/  scalars  ~[[%scalar case-qualified 'foo']]
  =/  expected  (mk-selection scalars ~)
  %+  expect-eq
    !>  expected
    !>  (parse:parse(default-database default-db) query-string)
::
:: qualified column case scalar with database..table.column (default ns)
++  test-case-08
  ::
  =/  query-string
    "FROM foo ".
    "SCALARS foo ".
    "CASE db2..table1.bar ".
    "WHEN 1 = 1 ".
    "THEN db2..table1.bar ".
    "ELSE db2..table1.bar ".
    "END ".
    "SELECT foo2,foo3"
  ::
  =/  case-qualified
    :*  %case
      qualified-col-4
      ~[[%case-when-then simple-true-pred qualified-col-4]]
      (some qualified-col-4)
    ==
  =/  scalars  ~[[%scalar case-qualified 'foo']]
  =/  expected  (mk-selection scalars ~)
  %+  expect-eq
    !>  expected
    !>  (parse:parse(default-database default-db) query-string)
::
:: qualified column case scalar with namespace.table.column (default database)
++  test-case-09
  ::
  =/  query-string
    "FROM foo ".
    "SCALARS foo ".
    "CASE dba.table1.bar ".
    "WHEN 1 = 1 ".
    "THEN dba.table1.bar ".
    "ELSE dba.table1.bar ".
    "END ".
    "SELECT foo2,foo3"
  ::
  =/  case-qualified
    :*  %case
      qualified-col-5
      ~[[%case-when-then simple-true-pred qualified-col-5]]
      (some qualified-col-5)
    ==
  =/  scalars  ~[[%scalar case-qualified 'foo']]
  =/  expected  (mk-selection scalars ~)
  %+  expect-eq
    !>  expected
    !>  (parse:parse(default-database default-db) query-string)
::
:: qualified column case scalar with alias.column (default database)
++  test-case-10
  ::
  =/  query-string
    "FROM ~sampel-palnet.db2.dba.table1 AS MyTable ".
    "SCALARS foo ".
    "CASE MyTable.bar ".
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
      qualified-col-6
      ~[[%case-when-then simple-true-pred qualified-col-6]]
      (some qualified-col-6)
    ==
  =/  scalars  ~[[%scalar case-qualified 'foo']]
  =/  expected  (mk-selection scalars (some table))
  %+  expect-eq
    !>  expected
    !>  (parse:parse(default-database default-db) query-string)
::
:: qualified column case scalar with alias.column (must fail - undefined alias)
:: test case with coalesce scalar inline
++  test-case-11
  ::
  =/  query-string
    "FROM foo ".
    "SCALARS foo COALESCE(foo2,1,foo2) ".
    "        bar CASE foo3 WHEN 1 = 1 THEN foo ELSE foo2 END ".
    "SELECT foo2,foo3"
  ::
  =/  naked-coalesce
    ~[%coalesce unqualified-col-2 literal-1 unqualified-col-2]
  =/  case-1
    :*
      %case
      target=unqualified-col-1
      cases=~[[%case-when-then simple-true-pred naked-coalesce]]
      else=(some unqualified-col-2)
    ==
  =/  scalars
    :~
      [%scalar naked-coalesce 'foo']
      [%scalar case-1 'bar']
    ==
  =/  expected  (mk-selection scalars ~)
  %+  expect-eq
    !>  expected
    !>  (parse:parse(default-database default-db) query-string)
::
:: test case with if scalar inline
++  test-case-12
  ::
  =/  query-string
    "FROM foo ".
    "SCALARS foo IF 1 = 1 THEN foo3 ELSE foo2 ENDIF ".
    "        bar CASE foo3 WHEN 1 = 1 THEN foo ELSE foo2 END ".
    "SELECT foo2,foo3"
  ::
  =/  naked-if
    :*
      %if-then-else
      if=simple-true-pred
      then=[unqualified-col-1]
      else=[unqualified-col-2]
    ==
  =/  case-1
    :*
      %case
      target=unqualified-col-1
      cases=~[[%case-when-then simple-true-pred naked-if]]
      else=(some unqualified-col-2)
    ==
  =/  scalars
    :~
      [%scalar naked-if 'foo']
      [%scalar case-1 'bar']
    ==
  =/  expected  (mk-selection scalars ~)
  %+  expect-eq
    !>  expected
    !>  (parse:parse(default-database default-db) query-string)
::
:: test case with case scalar inline
++  test-case-13
  ::
  =/  query-string
    "FROM foo ".
    "SCALARS foo CASE foo3 WHEN 1 = 1 THEN foo3 END ".
    "        bar CASE foo3 WHEN 1 = 1 THEN foo ELSE foo2 END ".
    "SELECT foo2,foo3"
  ::
  =/  naked-case
    :*
      %case
      target=unqualified-col-1
      cases=~[[%case-when-then simple-true-pred unqualified-col-1]]
      else=~
    ==
  =/  case-1
    :*
      %case
      target=unqualified-col-1
      cases=~[[%case-when-then simple-true-pred naked-case]]
      else=(some unqualified-col-2)
    ==
  =/  scalars
    :~
      [%scalar naked-case 'foo']
      [%scalar case-1 'bar']
    ==
  =/  expected  (mk-selection scalars ~)
  %+  expect-eq
    !>  expected
    !>  (parse:parse(default-database default-db) query-string)
::
:: test case with a case nested in a case
++  test-case-14
  ::
  =/  query-string
    "FROM foo ".
    "SCALARS baz CASE foo3 WHEN 1 = 1 THEN foo3 END ".
    "        bar CASE foo3 WHEN 1 = 1 THEN baz END ".
    "        foo CASE foo3 WHEN 1 = 1 THEN bar ELSE foo2 END ".
    "SELECT foo2,foo3"
  ::
  =/  second-case
    :*
      %case
      target=unqualified-col-1
      cases=~[[%case-when-then simple-true-pred unqualified-col-1]]
      else=~
    ==
  =/  first-case
    :*
      %case
      target=unqualified-col-1
      cases=~[[%case-when-then simple-true-pred second-case]]
      else=~
    ==
  =/  case-1
    :*
      %case
      target=unqualified-col-1
      cases=~[[%case-when-then simple-true-pred first-case]]
      else=(some unqualified-col-2)
    ==
  =/  scalars
    :~
      [%scalar second-case 'baz']
      [%scalar first-case 'bar']
      [%scalar case-1 'foo']
    ==
  =/  expected  (mk-selection scalars ~)
  %+  expect-eq
    !>  expected
    !>  (parse:parse(default-database default-db) query-string)
::
++  test-fail-case-01
  ::
  =/  query-string
    "FROM foo ".
    "SCALARS foo CASE MyTable.bar ".
    "              WHEN 1 = 1 THEN MyTable.bar".
    "            ELSE MyTable.bar END ".
    "SELECT foo2,foo3"
  ::
  %+  expect-fail-message
    'table alias \'MyTable\' is not defined'
    |.  (parse:parse(default-database default-db) query-string)
::
:: math
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
    "SELECT foo2,foo3"
  ::
  =/  addition
    [%arithmetic operator=%lus left=literal-1 right=literal-1]
  =/  subtraction
    [%arithmetic operator=%hep left=literal-1 right=literal-1]
  =/  division
    [%arithmetic operator=%fas left=literal-1 right=literal-1]
  =/  multiplication
    [%arithmetic operator=%tar left=literal-1 right=literal-1]
  =/  exponentiation
    [%arithmetic operator=%ket left=literal-1 right=literal-1]
  =/  scalars
    :~
      [%scalar addition 'foo1']
      [%scalar subtraction 'foo2']
      [%scalar division 'foo3']
      [%scalar multiplication 'foo4']
      [%scalar exponentiation 'foo5']
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
  =/  scalars
    :~
      [%scalar addition 'foo1']
      [%scalar subtraction 'foo2']
      [%scalar division 'foo3']
      [%scalar multiplication 'foo4']
      [%scalar exponentiation 'foo5']
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
  =/  scalars
    :~
      [%scalar addition 'foo1']
      [%scalar subtraction 'foo2']
      [%scalar division 'foo3']
      [%scalar multiplication 'foo4']
      [%scalar exponentiation 'foo5']
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
  =/  scalars
    :~
      [%scalar addition 'foo1']
      [%scalar subtraction 'foo2']
      [%scalar division 'foo3']
      [%scalar multiplication 'foo4']
      [%scalar exponentiation 'foo5']
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
  =/  scalars
    :~
      [%scalar addition 'foo1']
      [%scalar subtraction 'foo2']
      [%scalar division 'foo3']
      [%scalar multiplication 'foo4']
      [%scalar exponentiation 'foo5']
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
      [%scalar addition-no-space 'foo1']
      [%scalar subtraction-extra-space 'foo2']
      [%scalar division-mixed-space 'foo3']
      [%scalar multiplication-mixed-space 'foo4']
      [%scalar exponentiation-multi-space 'foo5']
      [%scalar nested-left-no-space 'foo6']
      [%scalar nested-left-paren-space 'foo7']
      [%scalar nested-left-mixed 'foo8']
      [%scalar nested-right-paren-space 'foo9']
      [%scalar nested-right-no-paren-space 'foo10']
      [%scalar nested-right-extra-space 'foo11']
      [%scalar double-nested-minimal 'foo12']
      [%scalar double-nested-maximal 'foo13']
      [%scalar double-nested-right-mixed 'foo14']
      [%scalar double-nested-right-paren-space 'foo15']
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
    "SCALARS foo1 BEGIN 2 ^ 3 ^ 3 END ".
    "        foo2 BEGIN 2 ^ (3 ^ 3) END ".
    "        foo3 BEGIN (2 ^ 3) ^ 3 END ".
    "        foo4 BEGIN 2 ^ 3 ^ 3 ^ 2 END ".
    "        foo5 BEGIN 2 + 3 + 4 END ".
    "        foo6 BEGIN 2 - 3 - 4 END ".
    "        foo7 BEGIN 2 * 3 * 4 END ".
    "        foo8 BEGIN 2 / 3 / 4 END ".
    "        foo9 BEGIN 2 + 3 + 4 + 5 END ".
    "SELECT foo2,foo3"
  ::
  =/  literal-2              [%literal-value dime=[p=~.ud q=2]]
  =/  literal-3              [%literal-value dime=[p=~.ud q=3]]
  =/  literal-4              [%literal-value dime=[p=~.ud q=4]]
  =/  literal-5              [%literal-value dime=[p=~.ud q=5]]
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
::
::    ^
::   /  
::  2    
::          
::    ^
::   / \
::  2   ^
::     3 
::
::    ^
::   / \
::  2   ^
::     3 3  
:: ---------
::    2
::      
::    ^
::   / \
::  2   3
::       
::
::    ^
::   / \
::  2   ^
::     3 3  
::
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
:: right assoc algo:
::
::    2
::      
::    ^
::   / \
::  2   3
::       
:: find the rightmost leaf and in its place put a new tree with the left leaf
:: the old leaf and the right leaf the new operand
::
::    ^
::   / \
::  2   ^
::     3 3  
::
::    ^
::   / \
::  2   ^
::     3 \
::        ^
::       3 2
::
  =/  exponentiation-4
    :*  %arithmetic
      %ket
      literal-2
      :*  %arithmetic
        %ket
        literal-3
        :*  %arithmetic
          %ket
          literal-3
          literal-2
        ==
      ==
    ==
:: ---------
:: left assoc algo
::
::    2
::
:: grab everything and make it the left node of a new tree
::      
::    +
::   / \
::  2   3
::       
::
::    +
::   / \
::  +   4
:: 2 3  
::
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
::
::    -
::   / \
::  -   4
:: 2 3  
::
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
  =/  addition-triple-left-assoc
    :*  %arithmetic
      %lus
      :*  %arithmetic
        %lus
        :*  %arithmetic
          %lus
          literal-2
          literal-3
        ==
        literal-4
      ==
      literal-5
    ==
  =/  scalars
    :~
      [%scalar exponentiation-1 'foo1']
      [%scalar exponentiation-2 'foo2']
      [%scalar exponentiation-3 'foo3']
      [%scalar exponentiation-4 'foo4']
      [%scalar addition-left-assoc 'foo5']
      [%scalar subtraction-left-assoc 'foo6']
      [%scalar multiplication-left-assoc 'foo7']
      [%scalar division-left-assoc 'foo8']
      [%scalar addition-triple-left-assoc 'foo9']
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
++  test-fail-arithmetic-1
  ::
  ::
  ::    "        foo14 BEGIN 1 +  (1-(1*1)) END ".
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
    'cannot use scalar %concat in arithmetic expression, allowed scalars: %abs\
    / %ceiling %day %floor %len %log %month %power %round %sign %sqrt %year'
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
    'cannot use scalar %left in arithmetic expression, allowed scalars: %abs\
    / %ceiling %day %floor %len %log %month %power %round %sign %sqrt %year'
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
    'cannot use scalar %right in arithmetic expression, allowed scalars: %abs\
    / %ceiling %day %floor %len %log %month %power %round %sign %sqrt %year'
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
    'cannot use scalar %substring in arithmetic expression, allowed scalars:\
    / %abs %ceiling %day %floor %len %log %month %power %round %sign %sqrt\
    / %year'
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
    'cannot use scalar %trim in arithmetic expression, allowed scalars: %abs\
    / %ceiling %day %floor %len %log %month %power %round %sign %sqrt %year'
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
    'cannot use scalar %getutcdate in arithmetic expression, allowed scalars:\
    / %abs %ceiling %day %floor %len %log %month %power %round %sign %sqrt\
    / %year'
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
    'cannot use scalar %left in arithmetic expression, allowed scalars: %abs\
    / %ceiling %day %floor %len %log %month %power %round %sign %sqrt %year'
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
    'cannot use scalar %concat in arithmetic expression, allowed scalars: %abs\
    / %ceiling %day %floor %len %log %month %power %round %sign %sqrt %year'
    |.  (parse:parse(default-database default-db) query-string)
--
