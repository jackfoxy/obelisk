/-  ast
/+  parse,  *test
::
|%
::
::  todo: error message when scalars are defined without a select statement after?
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
  =/  relation  ?~(table relation-1 [%relation object=(need table)])
  =/  from  [%from object=relation as-of=~ joins=~]
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
++  relation-1          :-  %relation
                           :*  %qualified-table
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
++  literal-1              [%literal-value dime=[p=%ud q=1]]
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
::  builtin scalar functions
::  test for optional params
++  test-builtins-01
::  spaces after parameters
  =/  query-string
    "FROM foo ".
    "SCALARS dt1 GETDATE() ".
    "        dt2 SYSDATETIMEOFFSET() ".
    "        dt3 DAY(2023.1.15) ".
    "        dt4 MONTH(2023.1.15) ".
    "        dt5 YEAR(2023.1.15) ".
    "        mt1 ABS(.5) ".
    "        mt2 LOG(.5,.2) ".
    "        mt21 LOG(.5) ".
    "        mt3 FLOOR(.5) ".
    "        mt4 POWER(.5, .2) ".
    "        mt5 CEILING(.5) ".
    "        mt6 ROUND(.5,2,1) ".
    "        mt61 ROUND(.5,2) ".
    "        mt7 SIGN(.5) ".
    "        mt8 SQRT(.5) ".
    "        st1 LEN('hello') ".
    "        st2 LEFT('hello',3) ".
    "        st3 RIGHT('hello',3) ".
    "        st4 SUBSTRING('hello',2,3) ".
    "        st5 TRIM(' ','hello') ".
    "        st51 TRIM('hello') ".
    "        st6 CONCAT('hello','world') ".
    "SELECT foo2,foo3"
  ::
  =/  literal-date           [%literal-value dime=[p=%da q=~2023.1.15]]
  =/  literal-float          [%literal-value dime=[p=%rs q=.5]]
  =/  literal-float2         [%literal-value dime=[p=%rs q=.2]]
  =/  literal-2              [%literal-value dime=[p=%ud q=2]]
  =/  literal-3              [%literal-value dime=[p=%ud q=3]]
  =/  literal-1              [%literal-value dime=[p=%ud q=1]]
  =/  literal-hello          [%literal-value dime=[p=%t q='hello']]
  =/  literal-world          [%literal-value dime=[p=%t q='world']]
  =/  literal-space          [%literal-value dime=[p=%t q=' ']]
  ::
  =/  getdate-fn             [%getdate ~]
  =/  sysdatetimeoffset-fn   [%sysdatetimeoffset ~]
  =/  day-fn                 [%day literal-date]
  =/  month-fn               [%month literal-date]
  =/  year-fn                [%year literal-date]
  =/  abs-fn                 [%abs literal-float]
  =/  floor-fn               [%floor literal-float]
  =/  ceiling-fn             [%ceiling literal-float]
  =/  sign-fn                [%sign literal-float]
  =/  sqrt-fn                [%sqrt literal-float]
  =/  len-fn                 [%len literal-hello]
  =/  left-fn                [%left literal-hello literal-3]
  =/  right-fn               [%right literal-hello literal-3]
  =/  power-fn               [%power literal-float literal-float2]
  =/  log-fn-1               [%log literal-float `literal-float2]
  =/  log-fn-2               [%log literal-float ~]
  =/  trim-fn-1              [%trim `literal-space literal-hello]
  =/  trim-fn-2              [%trim ~ literal-hello]
  =/  concat-fn              [%concat ~[literal-hello literal-world]]
  =/  round-fn-1             [%round literal-float literal-2 `literal-1]
  =/  round-fn-2             [%round literal-float literal-2 ~]
  =/  substring-fn           [%substring literal-hello literal-2 literal-3]
  =/  scalars
    :~
      [%scalar getdate-fn 'dt1']
      [%scalar sysdatetimeoffset-fn 'dt2']
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
    "SCALARS dt1 GETDATE() ".
    "        dt2 SYSDATETIMEOFFSET() ".
    "        dt3 DAY( 2023.1.15) ".
    "        dt4 MONTH( 2023.1.15) ".
    "        dt5 YEAR( 2023.1.15) ".
    "        mt1 ABS( .5) ".
    "        mt2 LOG( .5, .2) ".
    "        mt3 FLOOR( .5) ".
    "        mt4 POWER( .5, .2) ".
    "        mt5 CEILING( .5) ".
    "        mt6 ROUND( .5, 2, 1) ".
    "        mt7 SIGN( .5) ".
    "        mt8 SQRT( .5) ".
    "        st1 LEN( 'hello') ".
    "        st2 LEFT( 'hello', 3) ".
    "        st3 RIGHT( 'hello', 3) ".
    "        st4 SUBSTRING( 'hello', 2, 3) ".
    "        st5 TRIM( ' ', 'hello') ".
    "        st6 CONCAT( 'hello', 'world') ".
    "SELECT foo2,foo3"
  ::
  =/  literal-date           [%literal-value dime=[p=%da q=~2023.1.15]]
  =/  literal-float          [%literal-value dime=[p=%rs q=.5]]
  =/  literal-float2         [%literal-value dime=[p=%rs q=.2]]
  =/  literal-2              [%literal-value dime=[p=%ud q=2]]
  =/  literal-3              [%literal-value dime=[p=%ud q=3]]
  =/  literal-1              [%literal-value dime=[p=%ud q=1]]
  =/  literal-hello          [%literal-value dime=[p=%t q='hello']]
  =/  literal-world          [%literal-value dime=[p=%t q='world']]
  =/  literal-space          [%literal-value dime=[p=%t q=' ']]
  ::
  =/  getdate-fn             [%getdate ~]
  =/  sysdatetimeoffset-fn   [%sysdatetimeoffset ~]
  =/  day-fn                 [%day literal-date]
  =/  month-fn               [%month literal-date]
  =/  year-fn                [%year literal-date]
  =/  abs-fn                 [%abs literal-float]
  =/  floor-fn               [%floor literal-float]
  =/  ceiling-fn             [%ceiling literal-float]
  =/  sign-fn                [%sign literal-float]
  =/  sqrt-fn                [%sqrt literal-float]
  =/  len-fn                 [%len literal-hello]
  =/  left-fn                [%left literal-hello literal-3]
  =/  right-fn               [%right literal-hello literal-3]
  =/  power-fn               [%power literal-float literal-float2]
  =/  log-fn                 [%log literal-float `literal-float2]
  =/  trim-fn                [%trim `literal-space literal-hello]
  =/  concat-fn              [%concat ~[literal-hello literal-world]]
  =/  round-fn               [%round literal-float literal-2 `literal-1]
  =/  substring-fn           [%substring literal-hello literal-2 literal-3]
  =/  scalars
    :~
      [%scalar getdate-fn 'dt1']
      [%scalar sysdatetimeoffset-fn 'dt2']
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
    "SCALARS dt1 GETDATE() ".
    "        dt2 SYSDATETIMEOFFSET() ".
    "        dt3 DAY(2023.1.15 ) ".
    "        dt4 MONTH(2023.1.15 ) ".
    "        dt5 YEAR(2023.1.15 ) ".
    "        mt1 ABS(.5 ) ".
    "        mt2 LOG(.5 ,.2 ) ".
    "        mt3 FLOOR(.5 ) ".
    "        mt4 POWER(.5 ,.2 ) ".
    "        mt5 CEILING(.5 ) ".
    "        mt6 ROUND(.5 ,2 ,1 ) ".
    "        mt7 SIGN(.5 ) ".
    "        mt8 SQRT(.5 ) ".
    "        st1 LEN('hello' ) ".
    "        st2 LEFT('hello' ,3 ) ".
    "        st3 RIGHT('hello' ,3 ) ".
    "        st4 SUBSTRING('hello' ,2 ,3 ) ".
    "        st5 TRIM(' ' ,'hello' ) ".
    "        st6 CONCAT('hello' ,'world' ) ".
    "SELECT foo2,foo3"
  ::
  =/  literal-date           [%literal-value dime=[p=%da q=~2023.1.15]]
  =/  literal-float          [%literal-value dime=[p=%rs q=.5]]
  =/  literal-float2         [%literal-value dime=[p=%rs q=.2]]
  =/  literal-2              [%literal-value dime=[p=%ud q=2]]
  =/  literal-3              [%literal-value dime=[p=%ud q=3]]
  =/  literal-1              [%literal-value dime=[p=%ud q=1]]
  =/  literal-hello          [%literal-value dime=[p=%t q='hello']]
  =/  literal-world          [%literal-value dime=[p=%t q='world']]
  =/  literal-space          [%literal-value dime=[p=%t q=' ']]
  ::
  =/  getdate-fn             [%getdate ~]
  =/  sysdatetimeoffset-fn   [%sysdatetimeoffset ~]
  =/  day-fn                 [%day literal-date]
  =/  month-fn               [%month literal-date]
  =/  year-fn                [%year literal-date]
  =/  abs-fn                 [%abs literal-float]
  =/  floor-fn               [%floor literal-float]
  =/  ceiling-fn             [%ceiling literal-float]
  =/  sign-fn                [%sign literal-float]
  =/  sqrt-fn                [%sqrt literal-float]
  =/  len-fn                 [%len literal-hello]
  =/  left-fn                [%left literal-hello literal-3]
  =/  right-fn               [%right literal-hello literal-3]
  =/  power-fn               [%power literal-float literal-float2]
  =/  log-fn                 [%log literal-float `literal-float2]
  =/  trim-fn                [%trim `literal-space literal-hello]
  =/  concat-fn              [%concat ~[literal-hello literal-world]]
  =/  round-fn               [%round literal-float literal-2 `literal-1]
  =/  substring-fn           [%substring literal-hello literal-2 literal-3]
  =/  scalars
    :~
      [%scalar getdate-fn 'dt1']
      [%scalar sysdatetimeoffset-fn 'dt2']
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
    "SCALARS dt1 GETDATE() ".
    "        dt2 SYSDATETIMEOFFSET() ".
    "        dt3 DAY( 2023.1.15 ) ".
    "        dt4 MONTH( 2023.1.15 ) ".
    "        dt5 YEAR( 2023.1.15 ) ".
    "        mt1 ABS( .5 ) ".
    "        mt2 LOG( .5 , .2 ) ".
    "        mt3 FLOOR( .5 ) ".
    "        mt4 POWER( .5 , .2 ) ".
    "        mt5 CEILING( .5 ) ".
    "        mt6 ROUND( .5 , 2 , 1 ) ".
    "        mt7 SIGN( .5 ) ".
    "        mt8 SQRT( .5 ) ".
    "        st1 LEN( 'hello' ) ".
    "        st2 LEFT( 'hello' , 3 ) ".
    "        st3 RIGHT( 'hello' , 3 ) ".
    "        st4 SUBSTRING( 'hello' , 2 , 3 ) ".
    "        st5 TRIM( ' ' , 'hello' ) ".
    "        st6 CONCAT( 'hello' , 'world' ) ".
    "SELECT foo2,foo3"
  ::
  =/  literal-date           [%literal-value dime=[p=%da q=~2023.1.15]]
  =/  literal-float          [%literal-value dime=[p=%rs q=.5]]
  =/  literal-float2         [%literal-value dime=[p=%rs q=.2]]
  =/  literal-2              [%literal-value dime=[p=%ud q=2]]
  =/  literal-3              [%literal-value dime=[p=%ud q=3]]
  =/  literal-1              [%literal-value dime=[p=%ud q=1]]
  =/  literal-hello          [%literal-value dime=[p=%t q='hello']]
  =/  literal-world          [%literal-value dime=[p=%t q='world']]
  =/  literal-space          [%literal-value dime=[p=%t q=' ']]
  ::
  =/  getdate-fn             [%getdate ~]
  =/  sysdatetimeoffset-fn   [%sysdatetimeoffset ~]
  =/  day-fn                 [%day literal-date]
  =/  month-fn               [%month literal-date]
  =/  year-fn                [%year literal-date]
  =/  abs-fn                 [%abs literal-float]
  =/  floor-fn               [%floor literal-float]
  =/  ceiling-fn             [%ceiling literal-float]
  =/  sign-fn                [%sign literal-float]
  =/  sqrt-fn                [%sqrt literal-float]
  =/  len-fn                 [%len literal-hello]
  =/  left-fn                [%left literal-hello literal-3]
  =/  right-fn               [%right literal-hello literal-3]
  =/  power-fn               [%power literal-float literal-float2]
  =/  log-fn                 [%log literal-float `literal-float2]
  =/  trim-fn                [%trim `literal-space literal-hello]
  =/  concat-fn              [%concat ~[literal-hello literal-world]]
  =/  round-fn               [%round literal-float literal-2 `literal-1]
  =/  substring-fn           [%substring literal-hello literal-2 literal-3]
  =/  scalars
    :~
      [%scalar getdate-fn 'dt1']
      [%scalar sysdatetimeoffset-fn 'dt2']
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
:: should fail, column alias is not defined
++  test-coalesce-09
  ::
  =/  query-string
    "FROM foo ".
    "SCALARS foo COALESCE(MyTable.bar,~zod,1,foo3) ".
    "SELECT foo2,foo3"
  ::
  =/  coalesce-1
    ~[%coalesce qualified-col-6 literal-zod literal-1 unqualified-col-1]
  =/  scalars
    :~
      [%scalar coalesce-1 'foo']
    ==
  =/  expected  (mk-selection scalars ~)
  %-  expect-fail
    |.  (parse:parse(default-database default-db) query-string)
::
:: test coalesce with if scalar inline
++  test-coalesce-10
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
++  test-coalesce-11
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
++  test-coalesce-12
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
++  test-coalesce-13
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
++  test-coalesce-14
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
:: coalesce without parens - should fail
++  test-coalesce-15
  ::
  =/  query-string
    "FROM foo ".
    "SCALARS foo COALESCE foo3,~zod,1,foo3 ".
    "SELECT foo2,foo3"
  ::
  %-  expect-fail
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
    "SCALARS foo ".
    "IF 1 = 1 ".
    " THEN MyTable.bar ".
    " ELSE MyTable.bar ".
    "ENDIF ".
    "SELECT foo2,foo3"
  ::
  =/  naked-if 
    :*  %if-then-else
      if=simple-true-pred 
      then=[qualified-col-6]
      else=[qualified-col-6]
    ==
  =/  scalars  ~[[%scalar naked-if 'foo']]
  =/  expected  (mk-selection scalars ~)
  %-  expect-fail
    |.  (parse:parse(default-database default-db) query-string)
::
:: test if with coalesce scalar inline
++  test-if-10
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
++  test-if-11
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
++  test-if-12
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
++  test-if-13
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
:: qualified column case scalar with ship.database.namespace.table.column
++  test-case-04
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
:: qualified column case scalar with alias.column (should fail - undefined alias)
++  test-case-11
  ::
  =/  query-string
    "FROM foo ".
    "SCALARS foo ".
    "CASE MyTable.bar ".
    "WHEN 1 = 1 ".
    "THEN MyTable.bar ".
    "ELSE MyTable.bar ".
    "END ".
    "SELECT foo2,foo3"
  ::
  =/  case-qualified
    :*  %case
      qualified-col-6
      ~[[%case-when-then simple-true-pred qualified-col-6]]
      (some qualified-col-6)
    ==
  =/  scalars  ~[[%scalar case-qualified 'foo']]
  =/  expected  (mk-selection scalars ~)
  %-  expect-fail
    |.  (parse:parse(default-database default-db) query-string)
::
:: test case with coalesce scalar inline
++  test-case-12
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
++  test-case-13
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
++  test-case-14
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
++  test-case-15
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

::  simple case AS with datum
::++  test-scalar-06
::  =/  scalar  "SCALAR foobar AS CASE foo3 WHEN foo2 THEN foo ELSE bar END"
::  %+  expect-eq
::    !>  case-2
::    !>  (wonk (parse-scalar:parse [[1 1] scalar]))
::
::  simple case, 2 whens
::++  test-scalar-07
::  =/  scalar  "SCALAR foobar AS CASE foo3 WHEN foo2 THEN foo WHEN 1 = 1 THEN foo ELSE bar END"
::  %+  expect-eq
::    !>  case-3
::    !>  (wonk (parse-scalar:parse [[1 1] scalar]))
::
::  2 whens, embedded if for else
::++  test-scalar-08
::  =/  scalar  "SCALAR foobar AS CASE foo3 ".
::" WHEN foo2 THEN foo WHEN 1 = 1 THEN foo ".
::" ELSE IF 1 = 1 THEN foo ELSE bar ENDIF END"
::  %+  expect-eq
::    !>  case-4
::    !>  (wonk (parse-scalar:parse [[1 1] scalar]))
::
::  3 whens, coalesce, embedded if for else
::++  test-scalar-09
::  =/  scalar  "SCALAR foobar AS CASE foo3 ".
::" WHEN foo2 THEN foo ".
::" WHEN 1 = 1 THEN foo ".
::" WHEN foo3 THEN COALESCE bar,~zod,1,foo ".
::" ELSE IF 1 = 1 THEN foo ELSE bar ENDIF END"
::  %+  expect-eq
::    !>  case-5
::    !>  (wonk (parse-scalar:parse [[1 1] scalar]))
::
::  if aggragate
::++  test-scalar-10
::  =/  scalar  "SCALAR foobar IF count(foo)=1 THEN foo3 else bar ENDIF"
::  %+  expect-eq
::    !>  [[%scalar %foobar] [%if [%eq [aggregate-count-foobar 0 0] literal-1 0 0] %then unqualified-col-1 %else column-bar %endif]]
::    !>  (wonk (parse-scalar:parse [[1 1] scalar]))
::
::  coalesce aggragate
::++  test-scalar-11
::  =/  scalar  "SCALAR foobar AS COALESCE count(foo),~zod,1,foo"
::  %+  expect-eq
::    !>  [[%scalar %foobar] ~[%coalesce aggregate-count-foobar literal-zod literal-1 column-foo]]
::    !>  (wonk (parse-scalar:parse [[1 1] scalar]))
::
::  case aggregate
::++  test-scalar-12
::  =/  scalar  "SCALAR foobar AS CASE foo3 WHEN foo2 THEN count(foo) ELSE count(foo) END"
::  %+  expect-eq
::    !>  case-aggregate
::    !>  (wonk (parse-scalar:parse [[1 1] scalar]))
::
--
