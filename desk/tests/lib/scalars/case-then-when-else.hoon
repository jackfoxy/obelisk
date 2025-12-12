/-  ast
/+  *scalars,  *test,  *server
::
|%
::
::  helper-objects
::
++  default-db           'db1'
++  default-namespace    %dbo
::
::  @p.<database>.<namespace>.<table-or-view>
::  ~sampel-palnet.db2.dba.table1
++  qualified-table-1  :*  %qualified-table
                           ship=(some ~sampel-palnet)
                           database=%db2
                           namespace=%dba
                           name=%table1
                           alias=~
                       ==
::  <column-name>
::  bar
::
++  true-predicate         [n=%eq [n=[~.ud 1] ~ ~] [n=[~.ud 1] ~ ~]]
++  false-predicate         [n=%eq [n=[~.ud 1] ~ ~] [n=[~.ud 0] ~ ~]]
::
::  helper gates
::
::  make a qualified column
++  mk-qualified-col
  |=  [tbl=qualified-table name=@tas alias=(unit @t)]
  [%qualified-column tbl name alias]
::
::  make an indexed row
++  mk-indexed-row
  |=  [kvp=(lest [@tas @])]
  :*  %indexed-row
    key=(turn kvp |=(e=[@tas @] +.e))
    data=(malt (limo kvp))
  ==
::
::  make a qualified-type-lookup
++  mk-qualified-type-lookup
  |=  [kvp=(lest [qualified-table (lest [@tas @])])]
  :-  %qualified-lookup-type
  %-  malt
  %-  limo
  (turn kvp |=(e=[qualified-table (lest [@tas @])] [-.e (malt (limo +.e))]))
::
::  make an unqualified-type-lookup
++  mk-unqualified-type-lookup
  |=  [kvp=(lest [@tas @ta])]
  :-  %unqualified-lookup-type
  (malt kvp)
::
::
::
::  tests
::  - DONE:              
::  - MISSING:          %eq %neq %gte %gt %lte %lt %in %not-in %between
::                      %not-between %and %or
::  - ???:              %not (doesn't work for qualified/unqualified col)
::  - NOT IMPLEMENTED:  %equiv %not-equiv %exists %not-%exists %all %any
::

::  :::::::::::::::::::::::::
::  :::: PREDICATE TESTS ::::
::  :::::::::::::::::::::::::
::
::  set up some costant context for tests
::
++  pred-q-col-1             [%qualified-column qualified-table-1 %col1 ~]
++  pred-q-col-2             [%qualified-column qualified-table-1 %col2 ~]
++  pred-q-col-3             [%qualified-column qualified-table-1 %col3 ~]
::
++  pred-u-col-4             [%unqualified-column %col4 ~]
++  pred-u-col-5             [%unqualified-column %col5 ~]
++  pred-u-col-6             [%unqualified-column %col6 ~]
::
++  pred-qual-type-lookup       %-  mk-qualified-type-lookup
                                :~
                                  :-  qualified-table-1
                                  :~
                                    [%col1 ~.ud]
                                    [%col2 ~.ud]
                                    [%col3 ~.ud]
                                    [%col4 ~.ud]
                                    [%col5 ~.ud]
                                    [%col6 ~.ud]
                                  ==
                                ==
::
++  pred-unqual-type-lookup       %-  mk-unqualified-type-lookup
                                  :~
                                    [%col4 ~.ud]
                                    [%col5 ~.ud]
                                    [%col6 ~.ud]
                                  ==
::
++  pred-qualifier-lookup  %-  malt
                           %-  limo
                           :~
                             [%col4 ~[qualified-table-1]]
                             [%col5 ~[qualified-table-1]]
                             [%col6 ~[qualified-table-1]]
                           ==
::
++  pred-named-ctes        *named-ctes
::
++  pred-row               %-  mk-indexed-row
                           :~
                             [%col1 1]
                             [%col2 2]
                             [%col3 3]
                             [%col4 4]
                             [%col5 5]
                             [%col6 6]
                           ==
::
++  pred-scalars           %-  malt
                           %-  limo
                           :~
                             :-  %scalar1
                             :*  %if-then-else
                               if=true-predicate
                               then=[pred-q-col-3]
                               else=[pred-q-col-2]
                             ==
                           ==
::
+$  pred-test-row  $:  pred=predicate:ast     
                    then=datum-or-scalar:ast
                    else=datum-or-scalar:ast
                    expected=dime
                   ==
::
++  pred-test-helper
  |=  [row=pred-test-row]
  =/  pred-lookups  [pred-qualifier-lookup pred-qual-type-lookup]
  =/  if-expr       [%if-then-else if=pred.row then=then.row else=else.row]
  =/  scalar-to-apply
    (prepare-scalar if-expr pred-named-ctes pred-lookups pred-scalars)
  %+  expect-eq
    !>  expected.row
    !>  (apply-scalar pred-row scalar-to-apply)
::
::  row structure:
::  [@tas(test-name) [predicate then-branch else-branch expected]]
::
++  pred-row-test
  |=  [rows=(list [@tas pred-test-row])]
  ^-  tang
  %-  zing
  |-
  ?~  rows
    ~
  =/  row  -.rows
  ::  category to prepend the test name in case of result mismatch
  ::  the ~| to prepend test name in case of crash
  =/  result
    %+  category
      (trip -.row)
    ~|((weld "CRASH - " (trip -.row)) (pred-test-helper +.row))
  :-  result
  $(rows +.rows)
::
::  %eq tests
::
++  test-case-eq-dime-dime
  =/  cases
    :~
      [%case-when-then [%eq [[~.ud 1] ~ ~] [[~.ud 1] ~ ~]] then-q-col-1]
    ==
  =/  case-expr=case:ast
    :*  %case
      target=~
      cases=cases
      else=(some then-q-col-2)
    ==
  =/  scalar-to-apply
    (prepare-scalar case-expr then-named-ctes then-lookups then-scalars)
  %+  expect-eq
    !>  [~.ud 1]
    !>  (apply-scalar then-row scalar-to-apply)
::
++  test-case-eq-qualified-col-dime
  =/  cases
    :~
      [%case-when-then [%eq [pred-q-col-1 ~ ~] [[~.ud 1] ~ ~]] then-q-col-1]
    ==
  =/  case-expr=case:ast
    :*  %case
      target=~
      cases=cases
      else=(some then-q-col-2)
    ==
  =/  scalar-to-apply
    (prepare-scalar case-expr then-named-ctes then-lookups then-scalars)
  %+  expect-eq
    !>  [~.ud 1]
    !>  (apply-scalar then-row scalar-to-apply)
::
++  test-case-eq-dime-qualified-col
  =/  cases
    :~
      [%case-when-then [%eq [[~.ud 1] ~ ~] [pred-q-col-1 ~ ~]] then-q-col-1]
    ==
  =/  case-expr=case:ast
    :*  %case
      target=~
      cases=cases
      else=(some then-q-col-2)
    ==
  =/  scalar-to-apply
    (prepare-scalar case-expr then-named-ctes then-lookups then-scalars)
  %+  expect-eq
    !>  [~.ud 1]
    !>  (apply-scalar then-row scalar-to-apply)
::
++  test-case-eq-unqualified-col-dime
  =/  cases
    :~
      [%case-when-then [%eq [pred-u-col-4 ~ ~] [[~.ud 4] ~ ~]] then-u-col-4]
    ==
  =/  case-expr=case:ast
    :*  %case
      target=~
      cases=cases
      else=(some then-u-col-5)
    ==
  =/  scalar-to-apply
    (prepare-scalar case-expr then-named-ctes then-lookups then-scalars)
  %+  expect-eq
    !>  [~.ud 4]
    !>  (apply-scalar then-row scalar-to-apply)
::
++  test-case-eq-dime-unqualified-col
  =/  cases
    :~
      [%case-when-then [%eq [[~.ud 4] ~ ~] [pred-u-col-4 ~ ~]] then-u-col-4]
    ==
  =/  case-expr=case:ast
    :*  %case
      target=~
      cases=cases
      else=(some then-u-col-5)
    ==
  =/  scalar-to-apply
    (prepare-scalar case-expr then-named-ctes then-lookups then-scalars)
  %+  expect-eq
    !>  [~.ud 4]
    !>  (apply-scalar then-row scalar-to-apply)
::
::  %neq tests

::
::  %gte tests

::
::  %gt tests

::
::  %lte tests

::
::  %lt tests

::
::  %in tests

::
::  %not-in tests

::
::  %between tests

::
::  %not-between tests

::
::  %and tests

::
::  %or tests

::
::  %not tests

::  ::::::::::::::::::::::
::  :::: TARGET TESTS ::::
::  ::::::::::::::::::::::

::  TODO: do tests for target

::  ::::::::::::::::::::
::  :::: THEN TESTS ::::
::  ::::::::::::::::::::
::  TODO: interesting test case, what if two whens match? which one do we pick?
::
::  set up some costant context for tests
::
++  then-q-col-1                  [%qualified-column qualified-table-1 %col1 ~]
++  then-q-col-2                  [%qualified-column qualified-table-1 %col2 ~]
++  then-q-col-3                  [%qualified-column qualified-table-1 %col3 ~]
::
++  then-u-col-4                  [%unqualified-column %col4 ~]
++  then-u-col-5                  [%unqualified-column %col5 ~]
++  then-u-col-6                  [%unqualified-column %col6 ~]
::
++  then-type-lookup       %-  mk-qualified-type-lookup
                           :~
                             :-  qualified-table-1
                             :~
                               [%col1 ~.ud]
                               [%col2 ~.ud]
                               [%col3 ~.ud]
                               [%col4 ~.ud]
                               [%col5 ~.ud]
                               [%col6 ~.ud]
                             ==
                           ==
::
++  then-qualifier-lookup  %-  malt
                           %-  limo
                           :~
                             [%col4 ~[qualified-table-1]]
                             [%col5 ~[qualified-table-1]]
                             [%col6 ~[qualified-table-1]]
                           ==
::
++  then-lookups           [then-qualifier-lookup then-type-lookup]
::
++  then-named-ctes        *named-ctes
::
++  then-row               %-  mk-indexed-row
                           :~
                             [%col1 1]
                             [%col2 2]
                             [%col3 3]
                             [%col4 4]
                             [%col5 5]
                             [%col6 6]
                           ==
::
++  then-scalars           %-  malt
                           %-  limo
                           :~
                             :-  %scalar1
                             :*  %if-then-else
                               if=true-predicate
                               then=[then-q-col-3]
                               else=[then-q-col-2]
                             ==
                           ==
::  test return qualified column
::  fail scenario: no table with column
++  test-case-then-qualified-col-01
  =/  cases
    :~
      [%case-when-then true-predicate then-q-col-1]
      [%case-when-then true-predicate then-q-col-1]
    ==
  =/  case-expr=case:ast
    :*  %case
      target=~
      cases=cases
      else=(some then-q-col-2)
    ==
  =/  scalar-to-apply
    (prepare-scalar case-expr then-named-ctes then-lookups then-scalars)
  %+  expect-eq
    !>  [~.ud 1]
    !>  (apply-scalar then-row scalar-to-apply)
::
::  test return unqualified column
::  fail scenario: no table with column
++  test-case-then-unqualified-col-01
  =/  cases
    :~
      [%case-when-then true-predicate then-u-col-4]
      [%case-when-then true-predicate then-u-col-4]
    ==
  =/  case-expr=case:ast
    :*  %case
      target=~
      cases=cases
      else=(some then-u-col-5)
    ==
  =/  scalar-to-apply
    (prepare-scalar case-expr then-named-ctes then-lookups then-scalars)
  %+  expect-eq
    !>  [~.ud 4]
    !>  (apply-scalar then-row scalar-to-apply)
::
::  test return literal-value
++  test-case-then-literal-value-01
  =/  cases
    :~
      [%case-when-then true-predicate [%literal-value [~.t 'foo']]]
      [%case-when-then true-predicate [%literal-value [~.t 'foo']]]
    ==
  =/  case-expr=case:ast
    :*  %case
      target=~
      cases=cases
      else=(some [%literal-value [~.t 'bar']])
    ==
  =/  scalar-to-apply
    (prepare-scalar case-expr then-named-ctes then-lookups then-scalars)
  %+  expect-eq
    !>  [~.t 'foo']
    !>  (apply-scalar then-row scalar-to-apply)
::
::  test return scalar-alias
::  fail scenario: no scalar with alias
++  test-case-then-scalar-alias-01
  =/  cases
    :~
      [%case-when-then true-predicate [%scalar-alias %scalar1]]
      [%case-when-then true-predicate [%scalar-alias %scalar1]]
    ==
  =/  case-expr=case:ast
    :*  %case
      target=~
      cases=cases
      else=(some then-q-col-2)
    ==
  =/  scalar-to-apply
    (prepare-scalar case-expr then-named-ctes then-lookups then-scalars)
  %+  expect-eq
    !>  [~.ud 3]
    !>  (apply-scalar then-row scalar-to-apply)
::
::  test return embedded scalar
::  fail scenario: no scalar with alias
++  test-case-then-embedded-scalar-01
  =/  cases
    :~
      [%case-when-then true-predicate (~(got by then-scalars) %scalar1)]
      [%case-when-then true-predicate (~(got by then-scalars) %scalar1)]
    ==
  =/  case-expr=case:ast
    :*  %case
      target=~
      cases=cases
      else=(some then-q-col-2)
    ==
  =/  scalar-to-apply
    (prepare-scalar case-expr then-named-ctes then-lookups then-scalars)
  %+  expect-eq
    !>  [~.ud 3]
    !>  (apply-scalar then-row scalar-to-apply)
::
::  ::::::::::::::::::::
::  :::: ELSE TESTS ::::
::  ::::::::::::::::::::
::
::  set up some costant context for tests
::
++  else-q-col-1                  [%qualified-column qualified-table-1 %col1 ~]
++  else-q-col-2                  [%qualified-column qualified-table-1 %col2 ~]
++  else-q-col-3                  [%qualified-column qualified-table-1 %col3 ~]
::
++  else-u-col-4                  [%unqualified-column %col4 ~]
++  else-u-col-5                  [%unqualified-column %col5 ~]
++  else-u-col-6                  [%unqualified-column %col6 ~]
::
++  else-type-lookup       %-  mk-qualified-type-lookup
                           :~
                             :-  qualified-table-1
                             :~
                               [%col1 ~.ud]
                               [%col2 ~.ud]
                               [%col3 ~.ud]
                               [%col4 ~.ud]
                               [%col5 ~.ud]
                               [%col6 ~.ud]
                             ==
                           ==
::
++  else-qualifier-lookup  %-  malt
                           %-  limo
                           :~
                             [%col4 ~[qualified-table-1]]
                             [%col5 ~[qualified-table-1]]
                             [%col6 ~[qualified-table-1]]
                           ==
::
++  else-lookups           [else-qualifier-lookup else-type-lookup]
::
++  else-named-ctes        *named-ctes
::
++  else-row               %-  mk-indexed-row
                           :~
                             [%col1 1]
                             [%col2 2]
                             [%col3 3]
                             [%col4 4]
                             [%col5 5]
                             [%col6 6]
                           ==
::
++  else-scalars           %-  malt
                           %-  limo
                           :~
                             :-  %scalar1
                             :*  %if-then-else
                               if=true-predicate
                               then=[else-q-col-3]
                               else=[else-q-col-2]
                             ==
                           ==
::  tests for all possible else return types
::
::  test return qualified column
::  fail scenario: no table with column
++  test-searched-case-else-qualified-col-01
  =/  cases
    :~
      [%case-when-then false-predicate else-q-col-1]
      [%case-when-then false-predicate else-q-col-1]
    ==
  =/  case-expr=case:ast
    :*  %case
      target=~
      cases=cases
      else=(some else-q-col-2)
    ==
  =/  scalar-to-apply
    (prepare-scalar case-expr else-named-ctes else-lookups else-scalars)
  %+  expect-eq
    !>  [~.ud 2]
    !>  (apply-scalar else-row scalar-to-apply)
::
::  test return unqualified column
::  fail scenario: no table with column
++  test-searched-case-else-unqualified-col-01
  =/  cases
    :~
      [%case-when-then false-predicate else-u-col-4]
      [%case-when-then false-predicate else-u-col-4]
    ==
  =/  case-expr=case:ast
    :*  %case
      target=~
      cases=cases
      else=(some else-u-col-5)
    ==
  =/  scalar-to-apply
    (prepare-scalar case-expr else-named-ctes else-lookups else-scalars)
  %+  expect-eq
    !>  [~.ud 5]
    !>  (apply-scalar else-row scalar-to-apply)
::
::  test return literal-value
++  test-searched-case-else-literal-value-01
  =/  cases
    :~
      [%case-when-then false-predicate [%literal-value [~.t 'foo']]]
      [%case-when-then false-predicate [%literal-value [~.t 'foo']]]
    ==
  =/  case-expr=case:ast
    :*  %case
      target=~
      cases=cases
      else=(some [%literal-value [~.t 'bar']])
    ==
  =/  scalar-to-apply
    (prepare-scalar case-expr else-named-ctes else-lookups else-scalars)
  %+  expect-eq
    !>  [~.t 'bar']
    !>  (apply-scalar else-row scalar-to-apply)
::
::  test return scalar-alias
::  fail scenario: no scalar with alias
++  test-searched-case-else-scalar-alias-01
  =/  cases
    :~
      [%case-when-then false-predicate else-q-col-2]
      [%case-when-then false-predicate else-q-col-2]
    ==
  =/  case-expr=case:ast
    :*  %case
      target=~
      cases=cases
      else=(some [%scalar-alias %scalar1])
    ==
  =/  scalar-to-apply
    (prepare-scalar case-expr else-named-ctes else-lookups else-scalars)
  %+  expect-eq
    !>  [~.ud 3]
    !>  (apply-scalar else-row scalar-to-apply)
::
::  test return embedded scalar
::  fail scenario: no scalar with alias
++  test-searched-case-else-embedded-scalar-01
  =/  cases
    :~
      [%case-when-then false-predicate else-q-col-2]
      [%case-when-then false-predicate else-q-col-2]
    ==
  =/  case-expr=case:ast
    :*  %case
      target=~
      cases=cases
      else=(some (~(got by else-scalars) %scalar1))
    ==
  =/  scalar-to-apply
    (prepare-scalar case-expr else-named-ctes else-lookups else-scalars)
  %+  expect-eq
    !>  [~.ud 3]
    !>  (apply-scalar else-row scalar-to-apply)
::
++  test-simple-case-else-qualified-col-01
  =/  cases
    :~
      [%case-when-then [%literal-value [~.ud 1]] else-q-col-2]
    ==
  =/  case-expr=case:ast
    :*  %case
      target=(some else-q-col-1)
      cases=cases
      else=(some else-q-col-2)
    ==
  =/  scalar-to-apply
    (prepare-scalar case-expr else-named-ctes else-lookups else-scalars)
  %+  expect-eq
    !>  [~.ud 2]
    !>  (apply-scalar else-row scalar-to-apply)
--
