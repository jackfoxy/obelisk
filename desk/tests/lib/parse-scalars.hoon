/-  ast
/+  parse,  *test
::
|%
::  scalar
::
++  column-foo             :^  %qualified-column
                               :*  %qualified-table
                                   ship=~
                                   database=%db1
                                   namespace=%dbo
                                   name=%foo
                                   alias=~
                                 ==
                               name=%foo
                               alias=~
++  column-foo2            [%unqualified-column column='foo2' alias=~]
++  column-foo3            [%unqualified-column column='foo3' alias=~]
++  column-bar             :^  %qualified-column
                               :*  %qualified-table
                                   ship=~
                                   database=%db1
                                   namespace=%dbo
                                   name=%foo
                                   alias=~
                                   ==
                               name=%bar
                               alias=~
++  column-baz             :^  %qualified-column
                               :*  %qualified-table
                                   ship=~
                                   database=%db1
                                   namespace=%dbo
                                   name=%baz
                                   alias=~
                                   ==
                               name=%baz
                               alias=~
++  table-set-foo          :-  %table-set
                               :*  %qualified-table
                                   ship=~
                                   database=%db1
                                   namespace=%dbo
                                   name=%foo
                                   alias=~
                                   ==
++  literal-zod            [p=%p q=0]
++  literal-1              [p=%ud q=1]
++  naked-coalesce-1       ~[%coalesce column-foo2 literal-zod literal-1 column-foo3]
:: [%eq [literal-1 0 0] [literal-1 0 0]]
++  simple-true-pred       [%eq [[p=~.ud q=1] ~ ~] [[p=~.ud q=1] ~ ~]]
++  simple-false-pred      [%eq [[p=~.ud q=1] ~ ~] [[p=~.ud q=0] ~ ~]]
++  simple-if-naked-true   [%if-then-else if=simple-true-pred then=[column-foo3] else=[column-foo2]]
++  simple-if-naked-false  [%if-then-else if=simple-false-pred then=[column-foo3] else=[column-foo2]]
++  if-foo                 [%scalar simple-if-naked-true 'foo']
++  if-baz                 [%scalar simple-if-naked-false 'baz']
++  case-predicate         [%when [%eq [literal-1 0 0] literal-1 0 0] %then column-foo]
++  case-datum             [%when column-foo2 %then column-foo]
::++  case-coalesce          [%when column-foo3 %then naked-coalesce]
++  case-1                 [%scalar [%case column-foo3 ~[[simple-true-pred column-foo3]] (some column-foo2)] 'foobar']
++  case-2                 [%scalar [%case column-foo3 ~[[simple-true-pred column-foo3]] ~] 'foobaz']
::++  case-2                 [%scalar [%case column-foo3 ~[case-datum] %else column-bar %end]]
::++  case-3                 [%scalar [%case column-foo3 ~[case-datum case-predicate] %else column-bar %end]]
::++  case-4                 [%scalar [%case column-foo3 ~[case-datum case-predicate] %else simple-if-naked-true %end]]
::++  case-5                 [%scalar [%case column-foo3 ~[case-datum case-predicate case-coalesce] %else simple-if-naked-true %end]]
::++  case-aggregate         [%scalar [%case [%qualified-column [%qualified-table 0 'UNKNOWN' 'COLUMN-OR-CTE' %foo3 alias=~] %foo3 0] [[%when [%qualified-column [%qualified-table 0 'UNKNOWN' 'COLUMN-OR-CTE' %foo2 alias=~] %foo2 0] %then %aggregate %count %qualified-column [%qualified-table 0 'UNKNOWN' 'COLUMN-OR-CTE' %foo alias=~] %foo 0] 0] %else [%aggregate %count %qualified-column [%qualified-table 0 'UNKNOWN' 'COLUMN-OR-CTE' %foo alias=~] %foo 0] %end]]
::  coalesce
::  todo: add test cases for when arg is a scalar, currently only testing datums
::  todo: error message when scalars are defined without a select statement after?
::  todo: the parsers produce qualified columns where the qualified object's
::        name is always the same as the column's name
::
::  probably need for each scalar to test for every possible kind of qualifier
::
::
::  helper gates
::
::  mk-selection
::  returns a constant selection with scalars set to arg
++  mk-selection
  |=  scalars=(list scalar:ast)
  ^-  (list command:ast)
  =/  select  [%select top=~ bottom=~ columns=~[column-foo2 column-foo3]]
  =/  from  [%from object=table-set-foo as-of=~ joins=~]
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
++  default-db           'db1'
++  default-namespace    %dbo
::
::  @p.<database>.<namespace>.<table-or-view-alias>.<column-name>
::  ~sampel-palnet.db2.dba.my-table.bar
++  qualified-col-1  :^  %qualified-column
                       :*  %qualified-table
                           ship=~sampel-palnet
                           database=%db2
                           namespace=%dba
                           name=%foo
                           alias='my-table'
                           ==
                       name=%bar
                       alias=~
::  @p.<database>..<table-or-view-alias>.<column-name>
::  ~sampel-palnet.db2..my-table.bar
++  qualified-col-2  :^  %qualified-column
                       :*  %qualified-table
                           ship=~sampel-palnet
                           database=%db2
                           namespace=default-namespace
                           name=%foo
                           alias='my-table'
                           ==
                       name=%bar
                       alias=~
::  <database>.<namespace>.<table-or-view-alias>.<column-name>
::  db2.dba.my-table.bar
++  qualified-col-3  :^  %qualified-column
                       :*  %qualified-table
                           ship=~
                           database=%db2
                           namespace=%dba
                           name=%foo
                           alias='my-table'
                           ==
                       name=%bar
                       alias=~
::  <database>..<table-or-view-alias>.<column-name>
::  db2.dba.my-table.bar
++  qualified-col-4  :^  %qualified-column
                       :*  %qualified-table
                           ship=~
                           database=%db2
                           namespace=default-namespace
                           name=%foo
                           alias='my-table'
                           ==
                       name=%bar
                       alias=~
::  <namespace>.<table-or-view-alias>.<column-name>
::  dba.'my-table'.bar
++  qualified-col-5  :^  %qualified-column
                       :*  %qualified-table
                           ship=~
                           database=default-database
                           namespace=%dba
                           name=%foo
                           alias='my-table'
                           ==
                       name=%bar
                       alias=~
::  <table-or-view-alias>.<column-name>
::  <column-name>
::  helper objects
::
:: simple coalesce
++  test-coalesce-01
  ::
  =/  query-string
    "FROM foo ".
    "SCALARS foo COALESCE foo2,~zod,1,foo3 ".
    "SELECT foo2,foo3"
  ::
  =/  coalesce-1
    ~[%coalesce column-foo2 literal-zod literal-1 column-foo3]
  =/  scalars
    :~
      [%scalar coalesce-1 'foo']
    ==
  =/  expected  (mk-selection scalars)
  %+  expect-eq
    !>  expected
    !>  (parse:parse(default-database 'db1') query-string)
::
:: coalesce, 2 scalars
++  test-coalesce-02
  ::
  =/  query-string
    "FROM foo ".
    "SCALARS foo COALESCE foo2,~zod,1,foo3 ".
    "        baz COALESCE foo2,~zod,1,foo3 ".
    "SELECT foo2,foo3"
  ::
  =/  coalesce-1
    ~[%coalesce column-foo2 literal-zod literal-1 column-foo3]
  =/  scalars
    :~
      [%scalar coalesce-1 'foo']
      [%scalar coalesce-1 'baz']
    ==
  =/  expected  (mk-selection scalars)
  %+  expect-eq
    !>  expected
    !>  (parse:parse(default-database 'db1') query-string)
::
::
::  simple if
::  todo: add test cases for when arg is a scalar, currently only testing datums
++  test-if-03
  ::
  =/  query-string
    "FROM foo ".
    "SCALARS foo IF 1 = 1 THEN foo3 ELSE foo2 ENDIF ".
    "        baz IF 1 = 0 THEN foo3 ELSE foo2 ENDIF ".
    "SELECT foo2,foo3"
  ::
  =/  scalars  ~[if-foo if-baz]
  =/  expected  (mk-selection scalars)
  %+  expect-eq
    !>  expected
    !>  (parse:parse(default-database 'db1') query-string)

::  simple if as
::++  test-scalar-04
::  =/  scalar  "SCALAR foobar AS IF 1 = 1 THEN foo ELSE bar ENDIF"
::  %+  expect-eq
::    !>  simple-if
::    !>  (wonk (parse-scalar:parse [[1 1] scalar]))
::
::  simple case with predicate
++  test-case-05
  ::
  =/  query-string
    "FROM foo ".
    "SCALARS foobar CASE foo3 WHEN 1 = 1 THEN foo3 ELSE foo2 END ".
    "SELECT foo2,foo3"
  ::
  =/  scalars  ~[case-1]
  =/  expected  (mk-selection scalars)
  %+  expect-eq
    !>  expected
    !>  (parse:parse(default-database 'db1') query-string)

::  simple case with predicate, no else
++  test-case-051
  ::
  =/  query-string
    "FROM foo ".
    "SCALARS foobaz CASE foo3 WHEN 1 = 1 THEN foo3 END ".
    "SELECT foo2,foo3"
  ::
  =/  scalars  ~[case-2]
  =/  expected  (mk-selection scalars)
  %+  expect-eq
    !>  expected
    !>  (parse:parse(default-database 'db1') query-string)

::  simple case with predicate, two cases, one with else, the other with no else
++  test-case-052
  ::
  =/  query-string
    "FROM foo ".
    "SCALARS foobaz CASE foo3 WHEN 1 = 1 THEN foo3 END ".
    "        foobar CASE foo3 WHEN 1 = 1 THEN foo3 ELSE foo2 END ".
    "SELECT foo2,foo3"
  ::
  =/  scalars  ~[case-2 case-1]
  =/  expected  (mk-selection scalars)
  %+  expect-eq
    !>  expected
    !>  (parse:parse(default-database 'db1') query-string)
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
::    !>  [[%scalar %foobar] [%if [%eq [aggregate-count-foobar 0 0] literal-1 0 0] %then column-foo3 %else column-bar %endif]]
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
