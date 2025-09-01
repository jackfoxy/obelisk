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
++  case-predicate         [%when [%eq [literal-1 0 0] literal-1 0 0] %then column-foo]
++  case-datum             [%when column-foo2 %then column-foo]
::++  case-coalesce          [%when column-foo3 %then naked-coalesce]
++  case-1                 [%scalar [%case column-foo3 ~[[simple-true-pred column-foo3]] (some column-foo3)] 'foobar']
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
  |=  [scalars=(list scalar:ast) table=(unit qualified-table:ast)]
  ^-  (list command:ast)
  =/  select  [%select top=~ bottom=~ columns=~[column-foo2 column-foo3]]
  =/  table-set  ?~(table table-set-foo [%table-set object=(need table)])
  =/  from  [%from object=table-set as-of=~ joins=~]
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
::  TODO: to do this we also need to have a query that defines a table alias
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
++  unqualified-col-1   [%unqualified-column column=%foo3 alias=~]
::
++  simple-true-pred       [%eq [[p=~.ud q=1] ~ ~] [[p=~.ud q=1] ~ ~]]
++  simple-false-pred      [%eq [[p=~.ud q=1] ~ ~] [[p=~.ud q=0] ~ ~]]
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
    "SCALARS foo COALESCE ~sampel-palnet.db2.dba.table1.bar,~zod,1,foo3 ".
    "SELECT foo2,foo3"
  ::
  =/  coalesce-1
    [%coalesce data=~[qualified-col-1 literal-zod literal-1 column-foo3]]
  =/  scalars
    :~
      [%scalar coalesce-1 'foo']
    ==
  =/  expected=(list command:ast)  (mk-selection scalars ~)
  %+  expect-eq
    !>  expected
    !>  (parse:parse(default-database default-db) query-string)
::
:: qualified column coalesce with ship.database..table.column (default namespace)
++  test-coalesce-04
  ::
  =/  query-string
    "FROM foo ".
    "SCALARS foo COALESCE ~sampel-palnet.db2..table1.bar,~zod,1,foo3 ".
    "SELECT foo2,foo3"
  ::
  =/  coalesce-1
    ~[%coalesce qualified-col-2 literal-zod literal-1 column-foo3]
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
    "SCALARS foo COALESCE db2.dba.table1.bar,~zod,1,foo3 ".
    "SELECT foo2,foo3"
  ::
  =/  coalesce-1
    ~[%coalesce qualified-col-3 literal-zod literal-1 column-foo3]
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
    "SCALARS foo COALESCE db2..table1.bar,~zod,1,foo3 ".
    "SELECT foo2,foo3"
  ::
  =/  coalesce-1
    ~[%coalesce qualified-col-4 literal-zod literal-1 column-foo3]
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
    "SCALARS foo COALESCE dba.table1.bar,~zod,1,foo3 ".
    "SELECT foo2,foo3"
  ::
  =/  coalesce-1
    ~[%coalesce qualified-col-5 literal-zod literal-1 column-foo3]
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
    "SCALARS foo COALESCE MyTable.bar,~zod,1,foo3 ".
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
    ~[%coalesce qualified-col-6 literal-zod literal-1 column-foo3]
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
    "SCALARS foo COALESCE MyTable.bar,~zod,1,foo3 ".
    "SELECT foo2,foo3"
  ::
  =/  coalesce-1
    ~[%coalesce qualified-col-6 literal-zod literal-1 column-foo3]
  =/  scalars
    :~
      [%scalar coalesce-1 'foo']
    ==
  =/  expected  (mk-selection scalars ~)
  %-  expect-fail
    |.  (parse:parse(default-database default-db) query-string)
::
::  todo: add test cases for when arg is a scalar, currently only testing datums
::  simple if
++  test-if-01
  ::
  =/  query-string
    "FROM foo ".
    "SCALARS foo IF 1 = 1 THEN foo3 ELSE foo2 ENDIF ".
    "SELECT foo2,foo3"
  ::
  =/  simple-if-naked 
    [%if-then-else if=simple-true-pred then=[column-foo3] else=[column-foo2]]
  =/  scalars  ~[[%scalar simple-if-naked 'foo']]
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
  =/  simple-if-naked 
    [%if-then-else if=simple-true-pred then=[column-foo3] else=[column-foo2]]
  =/  scalars
    :~
      [%scalar simple-if-naked 'foo']
      [%scalar simple-if-naked 'baz']
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
  =/  simple-if-naked 
    :*  %if-then-else
      if=simple-true-pred 
      then=[qualified-col-1]
      else=[qualified-col-1]
    ==
  =/  scalars  ~[[%scalar simple-if-naked 'foo']]
  =/  expected  (mk-selection scalars ~)
  %+  expect-eq
    !>  expected
    !>  (parse:parse(default-database default-db) query-string)
::
:: qualified column if scalar with ship.database..table.column (default namespace)
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
  =/  simple-if-naked 
    :*  %if-then-else
      if=simple-true-pred 
      then=[qualified-col-2]
      else=[qualified-col-2]
    ==
  =/  scalars  ~[[%scalar simple-if-naked 'foo']]
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
  =/  simple-if-naked 
    :*  %if-then-else
      if=simple-true-pred 
      then=[qualified-col-3]
      else=[qualified-col-3]
    ==
  =/  scalars  ~[[%scalar simple-if-naked 'foo']]
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
  =/  simple-if-naked 
    :*  %if-then-else
      if=simple-true-pred 
      then=[qualified-col-4]
      else=[qualified-col-4]
    ==
  =/  scalars  ~[[%scalar simple-if-naked 'foo']]
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
  =/  simple-if-naked 
    :*  %if-then-else
      if=simple-true-pred 
      then=[qualified-col-5]
      else=[qualified-col-5]
    ==
  =/  scalars  ~[[%scalar simple-if-naked 'foo']]
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
  =/  simple-if-naked 
    :*  %if-then-else
      if=simple-true-pred 
      then=[qualified-col-6]
      else=[qualified-col-6]
    ==
  =/  scalars  ~[[%scalar simple-if-naked 'foo']]
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
  =/  simple-if-naked 
    :*  %if-then-else
      if=simple-true-pred 
      then=[qualified-col-6]
      else=[qualified-col-6]
    ==
  =/  scalars  ~[[%scalar simple-if-naked 'foo']]
  =/  expected  (mk-selection scalars ~)
  %-  expect-fail
    |.  (parse:parse(default-database default-db) query-string)
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
      column-foo3
      ~[[simple-true-pred unqualified-col-1]]
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
  =/  scalars  ~[case-2]
  =/  expected  (mk-selection scalars ~)
  %+  expect-eq
    !>  expected
    !>  (parse:parse(default-database default-db) query-string)

::  simple case with predicate, two cases, one with else, the other with no else
++  test-case-03
  ::
  =/  query-string
    "FROM foo ".
    "SCALARS foobaz CASE foo3 WHEN 1 = 1 THEN foo3 END ".
    "        foobar CASE foo3 WHEN 1 = 1 THEN foo3 ELSE foo2 END ".
    "SELECT foo2,foo3"
  ::
  =/  case-1
    [%case column-foo3 ~[[simple-true-pred unqualified-col-1]] ~]
  =/  case-2
    :*  %case
      column-foo3
      ~[[simple-true-pred unqualified-col-1]]
      (some unqualified-col-1)
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
      ~[[simple-true-pred qualified-col-1]]
      (some qualified-col-1)
    ==
  =/  scalars  ~[[%scalar case-qualified 'foo']]
  =/  expected  (mk-selection scalars ~)
  %+  expect-eq
    !>  expected
    !>  (parse:parse(default-database default-db) query-string)
::
:: qualified column case scalar with ship.database..table.column (default namespace)
++  test-case-05
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
      ~[[simple-true-pred qualified-col-2]]
      (some qualified-col-2)
    ==
  =/  scalars  ~[[%scalar case-qualified 'foo']]
  =/  expected  (mk-selection scalars ~)
  %+  expect-eq
    !>  expected
    !>  (parse:parse(default-database default-db) query-string)
::
:: qualified column case scalar with database.namespace.table.column
++  test-case-06
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
      ~[[simple-true-pred qualified-col-3]]
      (some qualified-col-3)
    ==
  =/  scalars  ~[[%scalar case-qualified 'foo']]
  =/  expected  (mk-selection scalars ~)
  %+  expect-eq
    !>  expected
    !>  (parse:parse(default-database default-db) query-string)
::
:: qualified column case scalar with database..table.column (default namespace)
++  test-case-07
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
      ~[[simple-true-pred qualified-col-4]]
      (some qualified-col-4)
    ==
  =/  scalars  ~[[%scalar case-qualified 'foo']]
  =/  expected  (mk-selection scalars ~)
  %+  expect-eq
    !>  expected
    !>  (parse:parse(default-database default-db) query-string)
::
:: qualified column case scalar with namespace.table.column (default database)
++  test-case-08
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
      ~[[simple-true-pred qualified-col-5]]
      (some qualified-col-5)
    ==
  =/  scalars  ~[[%scalar case-qualified 'foo']]
  =/  expected  (mk-selection scalars ~)
  %+  expect-eq
    !>  expected
    !>  (parse:parse(default-database default-db) query-string)
::
:: qualified column case scalar with alias.column (default database)
++  test-case-09
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
      ~[[simple-true-pred qualified-col-6]]
      (some qualified-col-6)
    ==
  =/  scalars  ~[[%scalar case-qualified 'foo']]
  =/  expected  (mk-selection scalars (some table))
  %+  expect-eq
    !>  expected
    !>  (parse:parse(default-database default-db) query-string)
::
:: qualified column case scalar with alias.column (should fail - undefined alias)
++  test-case-10
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
      ~[[simple-true-pred qualified-col-6]]
      (some qualified-col-6)
    ==
  =/  scalars  ~[[%scalar case-qualified 'foo']]
  =/  expected  (mk-selection scalars ~)
  %-  expect-fail
    |.  (parse:parse(default-database default-db) query-string)
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
