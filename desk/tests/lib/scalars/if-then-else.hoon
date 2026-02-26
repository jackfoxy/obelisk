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
++  unqualified-col-1   [%unqualified-column name=%foo3 alias=~]
++  unqualified-col-2   [%unqualified-column name=%foo2 alias=~]
::
++  literal-zod            [%literal-value dime=[p=%p q=0]]
++  literal-1              [%literal-value dime=[p=~.ud q=1]]
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
::  table testing harness
+$  table-test-row  $:  pred=predicate:ast     
                    then=datum-or-scalar:ast
                    else=datum-or-scalar:ast
                    expected=dime
                   ==
::
++  table-test-helper
  |=  [row=table-test-row]
  =/  pred-lookups  [qualifier-lookup qual-type-lookup]
  =/  if-expr       [%if-then-else if=pred.row then=then.row else=else.row]
  =/  scalar-to-apply
    (prepare-scalar if-expr table-named-ctes pred-lookups embedded-scalars)
  %+  expect-eq
    !>  expected.row
    !>  (apply-scalar table-row scalar-to-apply)
::
++  q-col-1             [%qualified-column qualified-table-1 %col1 ~]
++  q-col-2             [%qualified-column qualified-table-1 %col2 ~]
++  q-col-3             [%qualified-column qualified-table-1 %col3 ~]
::
++  u-col-4             [%unqualified-column %col4 ~]
++  u-col-5             [%unqualified-column %col5 ~]
++  u-col-6             [%unqualified-column %col6 ~]
::
++  qual-type-lookup  %-  mk-qualified-map-meta
                          :~  :-  qualified-table-1
                              %-  addr-columns  :~  [%column %col1 ~.ud 0]
                                                    [%column %col2 ~.ud 0]
                                                    [%column %col3 ~.ud 0]
                                                    [%column %col4 ~.ud 0]
                                                    [%column %col5 ~.ud 0]
                                                    [%column %col6 ~.ud 0]
                                                    ==
                              ==
::
++  unqual-type-lookup  :-  %unqualified-lookup-type
                            %-  mk-unqualified-typ-addr-lookup
                                %-  addr-columns
                                    :~  [%column %col4 ~.ud 0]
                                        [%column %col5 ~.ud 0]
                                        [%column %col6 ~.ud 0]
                                        ==
::
++  qualifier-lookup  %-  malt
                           %-  limo
                           :~
                             [%col4 ~[qualified-table-1]]
                             [%col5 ~[qualified-table-1]]
                             [%col6 ~[qualified-table-1]]
                           ==
::
++  table-named-ctes        *named-ctes
::
++  table-row               %-  mk-indexed-row
                           :~
                             [%col1 1]
                             [%col2 2]
                             [%col3 3]
                             [%col4 4]
                             [%col5 5]
                             [%col6 6]
                           ==
::
++  embedded-scalars           %-  malt
                           %-  limo
                           :~
                             :-  %scalar1
                             :*  %if-then-else
                               if=true-predicate
                               then=[q-col-3]
                               else=[q-col-2]
                             ==
                           ==
::
::  row structure:
::  [@tas(test-name) [predicate then-branch else-branch expected]]
::
++  run-tests
  |=  [rows=(list [@tas table-test-row])]
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
    ~|((weld "CRASH - " (trip -.row)) (table-test-helper +.row))
  :-  result
  $(rows +.rows)
::
::
::  tests
::  - DONE:             %eq %neq %gte %gt %lte %lt %in %not-in %between %not-between %and %or
::  - MISSING:          
::  - ???:              %not (doesn't work for qualified/unqualified col)
::  - NOT IMPLEMENTED:  %equiv %not-equiv %exists %not-%exists %all %any
::

::  :::::::::::::::::::::::::
::  :::: PREDICATE TESTS ::::
::  :::::::::::::::::::::::::
::
::  set up some costant context for tests
::
::  %eq tests
::
::++  test-if-predicate-eq
::  %-  run-tests
::  :~
::    :-  %eq-dimes
::    :*  [%eq [[~.ud 1] ~ ~] [[~.ud 1] ~ ~]]
::      q-col-1
::      q-col-2
::      [~.ud 1]
::    ==
::    :-  %eq-qualified-columns
::    :*  [%eq [q-col-1 ~ ~] [q-col-2 ~ ~]]
::      q-col-1
::      q-col-2
::      [~.ud 2]
::    ==
::    :-  %eq-qualified-column-and-dime
::    :*  [%eq [q-col-1 ~ ~] [[~.ud 1] ~ ~]]
::      q-col-1
::      q-col-2
::      [~.ud 1]
::    ==
::    :-  %eq-dime-and-qualified-column
::    :*  [%eq [[~.ud 1] ~ ~] [q-col-1 ~ ~]]
::      q-col-1
::      q-col-2
::      [~.ud 1]
::    ==
::    :-  %eq-unqualified-columns
::    :*  [%eq [u-col-4 ~ ~] [u-col-5 ~ ~]]
::      u-col-4
::      u-col-5
::      [~.ud 5]
::    ==
::    :-  %eq-unqualified-column-and-dime
::    :*  [%eq [u-col-4 ~ ~] [[~.ud 4] ~ ~]]
::      u-col-4
::      u-col-5
::      [~.ud 4]
::    ==
::    :-  %eq-dime-and-unqualified-column
::    :*  [%eq [[~.ud 4] ~ ~] [u-col-4 ~ ~]]
::      u-col-4
::      u-col-5
::      [~.ud 4]
::    ==
::  ==
::::
::::  %neq tests
::++  test-if-predicate-neq
::  %-  run-tests
::  :~
::    :-  %neq-dimes
::    :*  [%neq [[~.ud 1] ~ ~] [[~.ud 1] ~ ~]]
::      q-col-1
::      q-col-2
::      [~.ud 2]
::    ==
::    :-  %neq-qualified-columns
::    :*  [%neq [q-col-1 ~ ~] [q-col-2 ~ ~]]
::      q-col-1
::      q-col-2
::      [~.ud 1]
::    ==
::    :-  %neq-qualified-column-and-dime
::    :*  [%neq [q-col-1 ~ ~] [[~.ud 1] ~ ~]]
::      q-col-1
::      q-col-2
::      [~.ud 2]
::    ==
::    :-  %neq-dime-and-qualified-column
::    :*  [%neq [[~.ud 1] ~ ~] [q-col-1 ~ ~]]
::      q-col-1
::      q-col-2
::      [~.ud 2]
::    ==
::    :-  %neq-unqualified-columns
::    :*  [%neq [u-col-4 ~ ~] [u-col-5 ~ ~]]
::      u-col-4
::      u-col-5
::      [~.ud 4]
::    ==
::    :-  %neq-unqualified-column-and-dime
::    :*  [%neq [u-col-4 ~ ~] [[~.ud 4] ~ ~]]
::      u-col-4
::      u-col-5
::      [~.ud 5]
::    ==
::    :-  %neq-dime-and-unqualified-column
::    :*  [%neq [[~.ud 4] ~ ~] [u-col-4 ~ ~]]
::      u-col-4
::      u-col-5
::      [~.ud 5]
::    ==
::  ==
::::
::::  %gte tests
::++  test-if-predicate-gte
::  %-  run-tests
::  :~
::    :-  %gte-dimes-gt
::    :*  [%gte [[~.ud 2] ~ ~] [[~.ud 1] ~ ~]]
::      q-col-1
::      q-col-2
::      [~.ud 1]
::    ==
::    :-  %gte-dimes-eq
::    :*  [%gte [[~.ud 1] ~ ~] [[~.ud 1] ~ ~]]
::      q-col-1
::      q-col-2
::      [~.ud 1]
::    ==
::    :-  %gte-dimes-false
::    :*  [%gte [[~.ud 1] ~ ~] [[~.ud 2] ~ ~]]
::      q-col-1
::      q-col-2
::      [~.ud 2]
::    ==
::    :-  %gte-qualified-columns-gt
::    :*  [%gte [q-col-2 ~ ~] [q-col-1 ~ ~]]
::      q-col-1
::      q-col-2
::      [~.ud 1]
::    ==
::    :-  %gte-qualified-columns-eq
::    :*  [%gte [q-col-1 ~ ~] [q-col-1 ~ ~]]
::      q-col-1
::      q-col-2
::      [~.ud 1]
::    ==
::    :-  %gte-qualified-columns-false
::    :*  [%gte [q-col-1 ~ ~] [q-col-2 ~ ~]]
::      q-col-1
::      q-col-2
::      [~.ud 2]
::    ==
::    :-  %gte-qualified-column-and-dime-gt
::    :*  [%gte [q-col-2 ~ ~] [[~.ud 1] ~ ~]]
::      q-col-1
::      q-col-2
::      [~.ud 1]
::    ==
::    :-  %gte-qualified-column-and-dime-eq
::    :*  [%gte [q-col-1 ~ ~] [[~.ud 1] ~ ~]]
::      q-col-1
::      q-col-2
::      [~.ud 1]
::    ==
::    :-  %gte-qualified-column-and-dime-false
::    :*  [%gte [q-col-1 ~ ~] [[~.ud 2] ~ ~]]
::      q-col-1
::      q-col-2
::      [~.ud 2]
::    ==
::    :-  %gte-dime-and-qualified-column-gt
::    :*  [%gte [[~.ud 2] ~ ~] [q-col-1 ~ ~]]
::      q-col-1
::      q-col-2
::      [~.ud 1]
::    ==
::    :-  %gte-dime-and-qualified-column-eq
::    :*  [%gte [[~.ud 1] ~ ~] [q-col-1 ~ ~]]
::      q-col-1
::      q-col-2
::      [~.ud 1]
::    ==
::    :-  %gte-dime-and-qualified-column-false
::    :*  [%gte [[~.ud 1] ~ ~] [q-col-2 ~ ~]]
::      q-col-1
::      q-col-2
::      [~.ud 2]
::    ==
::    :-  %gte-unqualified-columns-gt
::    :*  [%gte [u-col-5 ~ ~] [u-col-4 ~ ~]]
::      u-col-4
::      u-col-5
::      [~.ud 4]
::    ==
::    :-  %gte-unqualified-columns-eq
::    :*  [%gte [u-col-4 ~ ~] [u-col-4 ~ ~]]
::      u-col-4
::      u-col-5
::      [~.ud 4]
::    ==
::    :-  %gte-unqualified-columns-false
::    :*  [%gte [u-col-4 ~ ~] [u-col-5 ~ ~]]
::      u-col-4
::      u-col-5
::      [~.ud 5]
::    ==
::    :-  %gte-unqualified-column-and-dime-gt
::    :*  [%gte [u-col-5 ~ ~] [[~.ud 4] ~ ~]]
::      u-col-4
::      u-col-5
::      [~.ud 4]
::    ==
::    :-  %gte-unqualified-column-and-dime-eq
::    :*  [%gte [u-col-4 ~ ~] [[~.ud 4] ~ ~]]
::      u-col-4
::      u-col-5
::      [~.ud 4]
::    ==
::    :-  %gte-unqualified-column-and-dime-false
::    :*  [%gte [u-col-4 ~ ~] [[~.ud 5] ~ ~]]
::      u-col-4
::      u-col-5
::      [~.ud 5]
::    ==
::    :-  %gte-dime-and-unqualified-column-gt
::    :*  [%gte [[~.ud 5] ~ ~] [u-col-4 ~ ~]]
::      u-col-4
::      u-col-5
::      [~.ud 4]
::    ==
::    :-  %gte-dime-and-unqualified-column-eq
::    :*  [%gte [[~.ud 4] ~ ~] [u-col-4 ~ ~]]
::      u-col-4
::      u-col-5
::      [~.ud 4]
::    ==
::    :-  %gte-dime-and-unqualified-column-false
::    :*  [%gte [[~.ud 4] ~ ~] [u-col-5 ~ ~]]
::      u-col-4
::      u-col-5
::      [~.ud 5]
::    ==
::  ==
::::
::::  %gt tests
::++  test-if-predicate-gt
::  %-  run-tests
::  :~
::    :-  %gt-dimes-gt
::    :*  [%gt [[~.ud 2] ~ ~] [[~.ud 1] ~ ~]]
::      q-col-1
::      q-col-2
::      [~.ud 1]
::    ==
::    :-  %gt-dimes-false
::    :*  [%gt [[~.ud 1] ~ ~] [[~.ud 2] ~ ~]]
::      q-col-1
::      q-col-2
::      [~.ud 2]
::    ==
::    :-  %gt-qualified-columns-gt
::    :*  [%gt [q-col-2 ~ ~] [q-col-1 ~ ~]]
::      q-col-1
::      q-col-2
::      [~.ud 1]
::    ==
::    :-  %gt-qualified-columns-false
::    :*  [%gt [q-col-1 ~ ~] [q-col-2 ~ ~]]
::      q-col-1
::      q-col-2
::      [~.ud 2]
::    ==
::    :-  %gt-qualified-column-and-dime-gt
::    :*  [%gt [q-col-2 ~ ~] [[~.ud 1] ~ ~]]
::      q-col-1
::      q-col-2
::      [~.ud 1]
::    ==
::    :-  %gt-qualified-column-and-dime-false
::    :*  [%gt [q-col-1 ~ ~] [[~.ud 2] ~ ~]]
::      q-col-1
::      q-col-2
::      [~.ud 2]
::    ==
::    :-  %gt-dime-and-qualified-column-gt
::    :*  [%gt [[~.ud 2] ~ ~] [q-col-1 ~ ~]]
::      q-col-1
::      q-col-2
::      [~.ud 1]
::    ==
::    :-  %gt-dime-and-qualified-column-false
::    :*  [%gt [[~.ud 1] ~ ~] [q-col-2 ~ ~]]
::      q-col-1
::      q-col-2
::      [~.ud 2]
::    ==
::    :-  %gt-unqualified-columns-gt
::    :*  [%gt [u-col-5 ~ ~] [u-col-4 ~ ~]]
::      u-col-4
::      u-col-5
::      [~.ud 4]
::    ==
::    :-  %gt-unqualified-columns-false
::    :*  [%gt [u-col-4 ~ ~] [u-col-5 ~ ~]]
::      u-col-4
::      u-col-5
::      [~.ud 5]
::    ==
::    :-  %gt-unqualified-column-and-dime-gt
::    :*  [%gt [u-col-5 ~ ~] [[~.ud 4] ~ ~]]
::      u-col-4
::      u-col-5
::      [~.ud 4]
::    ==
::    :-  %gt-unqualified-column-and-dime-false
::    :*  [%gt [u-col-4 ~ ~] [[~.ud 5] ~ ~]]
::      u-col-4
::      u-col-5
::      [~.ud 5]
::    ==
::    :-  %gt-dime-and-unqualified-column-gt
::    :*  [%gt [[~.ud 5] ~ ~] [u-col-4 ~ ~]]
::      u-col-4
::      u-col-5
::      [~.ud 4]
::    ==
::    :-  %gt-dime-and-unqualified-column-false
::    :*  [%gt [[~.ud 4] ~ ~] [u-col-5 ~ ~]]
::      u-col-4
::      u-col-5
::      [~.ud 5]
::    ==
::  ==
::::
::::  %lte tests
::++  test-if-predicate-lte
::  %-  run-tests
::  :~
::    :-  %lte-dimes-lt
::    :*  [%lte [[~.ud 1] ~ ~] [[~.ud 2] ~ ~]]
::      q-col-1
::      q-col-2
::      [~.ud 1]
::    ==
::    :-  %lte-dimes-eq
::    :*  [%lte [[~.ud 1] ~ ~] [[~.ud 1] ~ ~]]
::      q-col-1
::      q-col-2
::      [~.ud 1]
::    ==
::    :-  %lte-dimes-false
::    :*  [%lte [[~.ud 2] ~ ~] [[~.ud 1] ~ ~]]
::      q-col-1
::      q-col-2
::      [~.ud 2]
::    ==
::    :-  %lte-qualified-columns-lt
::    :*  [%lte [q-col-1 ~ ~] [q-col-2 ~ ~]]
::      q-col-1
::      q-col-2
::      [~.ud 1]
::    ==
::    :-  %lte-qualified-columns-eq
::    :*  [%lte [q-col-1 ~ ~] [q-col-1 ~ ~]]
::      q-col-1
::      q-col-2
::      [~.ud 1]
::    ==
::    :-  %lte-qualified-columns-false
::    :*  [%lte [q-col-2 ~ ~] [q-col-1 ~ ~]]
::      q-col-1
::      q-col-2
::      [~.ud 2]
::    ==
::    :-  %lte-qualified-column-and-dime-lt
::    :*  [%lte [q-col-1 ~ ~] [[~.ud 2] ~ ~]]
::      q-col-1
::      q-col-2
::      [~.ud 1]
::    ==
::    :-  %lte-qualified-column-and-dime-eq
::    :*  [%lte [q-col-1 ~ ~] [[~.ud 1] ~ ~]]
::      q-col-1
::      q-col-2
::      [~.ud 1]
::    ==
::    :-  %lte-qualified-column-and-dime-false
::    :*  [%lte [q-col-2 ~ ~] [[~.ud 1] ~ ~]]
::      q-col-1
::      q-col-2
::      [~.ud 2]
::    ==
::    :-  %lte-dime-and-qualified-column-lt
::    :*  [%lte [[~.ud 1] ~ ~] [q-col-2 ~ ~]]
::      q-col-1
::      q-col-2
::      [~.ud 1]
::    ==
::    :-  %lte-dime-and-qualified-column-eq
::    :*  [%lte [[~.ud 1] ~ ~] [q-col-1 ~ ~]]
::      q-col-1
::      q-col-2
::      [~.ud 1]
::    ==
::    :-  %lte-dime-and-qualified-column-false
::    :*  [%lte [[~.ud 2] ~ ~] [q-col-1 ~ ~]]
::      q-col-1
::      q-col-2
::      [~.ud 2]
::    ==
::    :-  %lte-unqualified-columns-lt
::    :*  [%lte [u-col-4 ~ ~] [u-col-5 ~ ~]]
::      u-col-4
::      u-col-5
::      [~.ud 4]
::    ==
::    :-  %lte-unqualified-columns-eq
::    :*  [%lte [u-col-4 ~ ~] [u-col-4 ~ ~]]
::      u-col-4
::      u-col-5
::      [~.ud 4]
::    ==
::    :-  %lte-unqualified-columns-false
::    :*  [%lte [u-col-5 ~ ~] [u-col-4 ~ ~]]
::      u-col-4
::      u-col-5
::      [~.ud 5]
::    ==
::    :-  %lte-unqualified-column-and-dime-lt
::    :*  [%lte [u-col-4 ~ ~] [[~.ud 5] ~ ~]]
::      u-col-4
::      u-col-5
::      [~.ud 4]
::    ==
::    :-  %lte-unqualified-column-and-dime-eq
::    :*  [%lte [u-col-4 ~ ~] [[~.ud 4] ~ ~]]
::      u-col-4
::      u-col-5
::      [~.ud 4]
::    ==
::    :-  %lte-unqualified-column-and-dime-false
::    :*  [%lte [u-col-5 ~ ~] [[~.ud 4] ~ ~]]
::      u-col-4
::      u-col-5
::      [~.ud 5]
::    ==
::    :-  %lte-dime-and-unqualified-column-lt
::    :*  [%lte [[~.ud 4] ~ ~] [u-col-5 ~ ~]]
::      u-col-4
::      u-col-5
::      [~.ud 4]
::    ==
::    :-  %lte-dime-and-unqualified-column-eq
::    :*  [%lte [[~.ud 4] ~ ~] [u-col-4 ~ ~]]
::      u-col-4
::      u-col-5
::      [~.ud 4]
::    ==
::    :-  %lte-dime-and-unqualified-column-false
::    :*  [%lte [[~.ud 5] ~ ~] [u-col-4 ~ ~]]
::      u-col-4
::      u-col-5
::      [~.ud 5]
::    ==
::  ==
::::
::::  %lt tests
::++  test-if-predicate-lt
::  %-  run-tests
::  :~
::    :-  %lt-dimes-lt
::    :*  [%lt [[~.ud 1] ~ ~] [[~.ud 2] ~ ~]]
::      q-col-1
::      q-col-2
::      [~.ud 1]
::    ==
::    :-  %lt-dimes-false
::    :*  [%lt [[~.ud 2] ~ ~] [[~.ud 1] ~ ~]]
::      q-col-1
::      q-col-2
::      [~.ud 2]
::    ==
::    :-  %lt-qualified-columns-lt
::    :*  [%lt [q-col-1 ~ ~] [q-col-2 ~ ~]]
::      q-col-1
::      q-col-2
::      [~.ud 1]
::    ==
::    :-  %lt-qualified-columns-false
::    :*  [%lt [q-col-2 ~ ~] [q-col-1 ~ ~]]
::      q-col-1
::      q-col-2
::      [~.ud 2]
::    ==
::    :-  %lt-qualified-column-and-dime-lt
::    :*  [%lt [q-col-1 ~ ~] [[~.ud 2] ~ ~]]
::      q-col-1
::      q-col-2
::      [~.ud 1]
::    ==
::    :-  %lt-qualified-column-and-dime-false
::    :*  [%lt [q-col-2 ~ ~] [[~.ud 1] ~ ~]]
::      q-col-1
::      q-col-2
::      [~.ud 2]
::    ==
::    :-  %lt-dime-and-qualified-column-lt
::    :*  [%lt [[~.ud 1] ~ ~] [q-col-2 ~ ~]]
::      q-col-1
::      q-col-2
::      [~.ud 1]
::    ==
::    :-  %lt-dime-and-qualified-column-false
::    :*  [%lt [[~.ud 2] ~ ~] [q-col-1 ~ ~]]
::      q-col-1
::      q-col-2
::      [~.ud 2]
::    ==
::    :-  %lt-unqualified-columns-lt
::    :*  [%lt [u-col-4 ~ ~] [u-col-5 ~ ~]]
::      u-col-4
::      u-col-5
::      [~.ud 4]
::    ==
::    :-  %lt-unqualified-columns-false
::    :*  [%lt [u-col-5 ~ ~] [u-col-4 ~ ~]]
::      u-col-4
::      u-col-5
::      [~.ud 5]
::    ==
::    :-  %lt-unqualified-column-and-dime-lt
::    :*  [%lt [u-col-4 ~ ~] [[~.ud 5] ~ ~]]
::      u-col-4
::      u-col-5
::      [~.ud 4]
::    ==
::    :-  %lt-unqualified-column-and-dime-false
::    :*  [%lt [u-col-5 ~ ~] [[~.ud 4] ~ ~]]
::      u-col-4
::      u-col-5
::      [~.ud 5]
::    ==
::    :-  %lt-dime-and-unqualified-column-lt
::    :*  [%lt [[~.ud 4] ~ ~] [u-col-5 ~ ~]]
::      u-col-4
::      u-col-5
::      [~.ud 4]
::    ==
::    :-  %lt-dime-and-unqualified-column-false
::    :*  [%lt [[~.ud 5] ~ ~] [u-col-4 ~ ~]]
::      u-col-4
::      u-col-5
::      [~.ud 5]
::    ==
::  ==
::::
::::  %in tests
::++  test-if-predicate-in
::  %-  run-tests
::  :~
::    :-  %in-dime
::    :*  [%in [[~.ud 1] ~ ~] [[%value-literals [~.ud '1;2;4;5']] ~ ~]]
::      q-col-1
::      q-col-2
::      [~.ud 1]
::    ==
::    :-  %in-dime-false
::    :*  [%in [[~.ud 3] ~ ~] [[%value-literals [~.ud '1;2;4;5']] ~ ~]]
::      q-col-1
::      q-col-2
::      [~.ud 2]
::    ==
::    :-  %in-qualified-column
::    :*  [%in [q-col-1 ~ ~] [[%value-literals [~.ud '1;2;4;5']] ~ ~]]
::      q-col-1
::      q-col-2
::      [~.ud 1]
::    ==
::    :-  %in-qualified-column-false
::    :*  [%in [q-col-3 ~ ~] [[%value-literals [~.ud '1;2;4;5']] ~ ~]]
::      q-col-1
::      q-col-2
::      [~.ud 2]
::    ==
::    :-  %in-unqualified-column
::    :*  [%in [u-col-4 ~ ~] [[%value-literals [~.ud '1;2;4;5']] ~ ~]]
::      u-col-4
::      u-col-5
::      [~.ud 4]
::    ==
::    :-  %in-unqualified-column-false
::    :*  [%in [u-col-6 ~ ~] [[%value-literals [~.ud '1;2;4;5']] ~ ~]]
::      u-col-4
::      u-col-5
::      [~.ud 5]
::    ==
::  ==
::::
::::  %not-in tests
::++  test-if-predicate-not-in
::  %-  run-tests
::  :~
::    :-  %not-in-dime
::    :*  [%not-in [[~.ud 3] ~ ~] [[%value-literals [~.ud '1;2;4;5']] ~ ~]]
::      q-col-1
::      q-col-2
::      [~.ud 1]
::    ==
::    :-  %not-in-dime-false
::    :*  [%not-in [[~.ud 1] ~ ~] [[%value-literals [~.ud '1;2;4;5']] ~ ~]]
::      q-col-1
::      q-col-2
::      [~.ud 2]
::    ==
::    :-  %not-in-qualified-column
::    :*  [%not-in [q-col-3 ~ ~] [[%value-literals [~.ud '1;2;4;5']] ~ ~]]
::      q-col-1
::      q-col-2
::      [~.ud 1]
::    ==
::    :-  %not-in-qualified-column-false
::    :*  [%not-in [q-col-1 ~ ~] [[%value-literals [~.ud '1;2;4;5']] ~ ~]]
::      q-col-1
::      q-col-2
::      [~.ud 2]
::    ==
::    :-  %not-in-unqualified-column
::    :*  [%not-in [u-col-6 ~ ~] [[%value-literals [~.ud '1;2;4;5']] ~ ~]]
::      u-col-4
::      u-col-5
::      [~.ud 4]
::    ==
::    :-  %not-in-unqualified-column-false
::    :*  [%not-in [u-col-4 ~ ~] [[%value-literals [~.ud '1;2;4;5']] ~ ~]]
::      u-col-4
::      u-col-5
::      [~.ud 5]
::    ==
::  ==
::::
::::  %between tests
::++  test-if-predicate-between
::  =/  mk-between-pred
::    |*  [val-to-test=* lower-bound=* upper-bound=*]
::    :+  %between
::      [%gte [val-to-test ~ ~] [lower-bound ~ ~]]
::    [%lte [val-to-test ~ ~] [upper-bound ~ ~]]
::  %-  run-tests
::  :~
::    :-  %between-dime-dimes
::    :*  (mk-between-pred [~.ud 2] [~.ud 1] [~.ud 3])
::      q-col-1
::      q-col-2
::      [~.ud 1]
::    ==
::    :-  %between-qualified-column-qualified-columns
::    :*  (mk-between-pred q-col-2 q-col-1 q-col-3)
::      q-col-1
::      q-col-2
::      [~.ud 1]
::    ==
::    :-  %between-qualified-column-dime-and-qualified-column
::    :*  (mk-between-pred q-col-2 [~.ud 1] q-col-3)
::      q-col-1
::      q-col-2
::      [~.ud 1]
::    ==
::    :-  %between-qualified-column-qualified-column-and-dime
::    :*  (mk-between-pred q-col-2 q-col-1 [~.ud 3])
::      q-col-1
::      q-col-2
::      [~.ud 1]
::    ==
::    :-  %between-qualified-column-dimes
::    :*  (mk-between-pred q-col-2 [~.ud 1] [~.ud 3])
::      q-col-1
::      q-col-2
::      [~.ud 1]
::    ==
::    :-  %between-unqualified-column-unqualified-columns
::    :*  (mk-between-pred u-col-5 u-col-4 u-col-6)
::      u-col-4
::      u-col-5
::      [~.ud 4]
::    ==
::    :-  %between-unqualified-column-dime-and-unqualified-column
::    :*  (mk-between-pred u-col-5 [~.ud 4] u-col-6)
::      u-col-4
::      u-col-5
::      [~.ud 4]
::    ==
::    :-  %between-unqualified-column-unqualified-column-and-dime
::    :*  (mk-between-pred u-col-5 u-col-4 [~.ud 6])
::      u-col-4
::      u-col-5
::      [~.ud 4]
::    ==
::    :-  %between-unqualified-column-dimes
::    :*  (mk-between-pred u-col-5 [~.ud 4] [~.ud 6])
::      u-col-4
::      u-col-5
::      [~.ud 4]
::    ==
::    :-  %between-dime-dimes-false
::    :*  (mk-between-pred [~.ud 5] [~.ud 1] [~.ud 3])
::      q-col-1
::      q-col-2
::      [~.ud 2]
::    ==
::    :-  %between-qualified-column-dimes-false
::    :*  (mk-between-pred q-col-1 [~.ud 2] [~.ud 4])
::      q-col-1
::      q-col-2
::      [~.ud 2]
::    ==
::    :-  %between-unqualified-column-dimes-false
::    :*  (mk-between-pred u-col-4 [~.ud 5] [~.ud 7])
::      u-col-4
::      u-col-5
::      [~.ud 5]
::    ==
::  ==
::::
::::  %not-between tests
::++  test-if-predicate-not-between
::  =/  mk-not-between-pred
::    |*  [val-to-test=* lower-bound=* upper-bound=*]
::    :+  %not-between
::      [%gte [val-to-test ~ ~] [lower-bound ~ ~]]
::    [%lte [val-to-test ~ ~] [upper-bound ~ ~]]
::  %-  run-tests
::  :~
::    :-  %not-between-dime-dimes
::    :*  (mk-not-between-pred [~.ud 5] [~.ud 1] [~.ud 3])
::      q-col-1
::      q-col-2
::      [~.ud 1]
::    ==
::    :-  %not-between-qualified-column-qualified-columns
::    :*  (mk-not-between-pred q-col-1 q-col-2 q-col-3)
::      q-col-1
::      q-col-2
::      [~.ud 1]
::    ==
::    :-  %not-between-qualified-column-dime-and-qualified-column
::    :*  (mk-not-between-pred q-col-1 [~.ud 2] q-col-3)
::      q-col-1
::      q-col-2
::      [~.ud 1]
::    ==
::    :-  %not-between-qualified-column-qualified-column-and-dime
::    :*  (mk-not-between-pred q-col-1 q-col-2 [~.ud 3])
::      q-col-1
::      q-col-2
::      [~.ud 1]
::    ==
::    :-  %not-between-qualified-column-dimes
::    :*  (mk-not-between-pred q-col-1 [~.ud 2] [~.ud 4])
::      q-col-1
::      q-col-2
::      [~.ud 1]
::    ==
::    :-  %not-between-unqualified-column-unqualified-columns
::    :*  (mk-not-between-pred u-col-4 u-col-5 u-col-6)
::      u-col-4
::      u-col-5
::      [~.ud 4]
::    ==
::    :-  %not-between-unqualified-column-dime-and-unqualified-column
::    :*  (mk-not-between-pred u-col-4 [~.ud 5] u-col-6)
::      u-col-4
::      u-col-5
::      [~.ud 4]
::    ==
::    :-  %not-between-unqualified-column-unqualified-column-and-dime
::    :*  (mk-not-between-pred u-col-4 u-col-5 [~.ud 6])
::      u-col-4
::      u-col-5
::      [~.ud 4]
::    ==
::    :-  %not-between-unqualified-column-dimes
::    :*  (mk-not-between-pred u-col-4 [~.ud 5] [~.ud 7])
::      u-col-4
::      u-col-5
::      [~.ud 4]
::    ==
::    :-  %not-between-dime-dimes-false
::    :*  (mk-not-between-pred [~.ud 2] [~.ud 1] [~.ud 3])
::      q-col-1
::      q-col-2
::      [~.ud 2]
::    ==
::    :-  %not-between-qualified-column-dimes-false
::    :*  (mk-not-between-pred q-col-2 [~.ud 1] [~.ud 3])
::      q-col-1
::      q-col-2
::      [~.ud 2]
::    ==
::    :-  %not-between-unqualified-column-dimes-false
::    :*  (mk-not-between-pred u-col-5 [~.ud 4] [~.ud 6])
::      u-col-4
::      u-col-5
::      [~.ud 5]
::    ==
::  ==
::::
::::  %and tests
::++  test-if-predicate-and
::  %-  run-tests
::  :~
::    :-  %and-true
::    :*  :+  %and
::          [%eq [[~.ud 1] ~ ~] [[~.ud 1] ~ ~]]
::        [%eq [[~.ud 1] ~ ~] [[~.ud 1] ~ ~]]
::      q-col-1
::      q-col-2
::      [~.ud 1]
::    ==
::    :-  %and-false
::    :*  :+  %and
::          [%eq [[~.ud 1] ~ ~] [[~.ud 1] ~ ~]]
::        [%eq [[~.ud 0] ~ ~] [[~.ud 1] ~ ~]]
::      q-col-1
::      q-col-2
::      [~.ud 2]
::    ==
::  ==
::::
::::  %or tests
::++  test-if-predicate-or
::  %-  run-tests
::  :~
::    :-  %or-true-true
::    :*  :+  %or
::          [%eq [[~.ud 1] ~ ~] [[~.ud 1] ~ ~]]
::        [%eq [[~.ud 1] ~ ~] [[~.ud 1] ~ ~]]
::      q-col-1
::      q-col-2
::      [~.ud 1]
::    ==
::    :-  %or-true-false
::    :*  :+  %or
::          [%eq [[~.ud 0] ~ ~] [[~.ud 1] ~ ~]]
::        [%eq [[~.ud 1] ~ ~] [[~.ud 1] ~ ~]]
::      q-col-1
::      q-col-2
::      [~.ud 1]
::    ==
::    :-  %or-false-false
::    :*  :+  %or
::          [%eq [[~.ud 0] ~ ~] [[~.ud 1] ~ ~]]
::        [%eq [[~.ud 0] ~ ~] [[~.ud 1] ~ ~]]
::      q-col-1
::      q-col-2
::      [~.ud 2]
::    ==
::  ==
::::
::::  %not tests
::++  test-if-predicate-not
::  %-  run-tests
::  :~
::    :-  %not-true-expression
::    :*  [%not [%eq [[~.ud 1] ~ ~] [[~.ud 1] ~ ~]] ~]
::      q-col-1
::      q-col-2
::      [~.ud 2]
::    ==
::    :-  %not-false-expression
::    :*  [%not [%eq [[~.ud 0] ~ ~] [[~.ud 1] ~ ~]] ~]
::      q-col-1
::      q-col-2
::      [~.ud 1]
::    ==
::::    :-  %not-true-qualified-column
::::    :*  [%not [q-col-2 ~ ~] ~]
::::      q-col-1
::::      q-col-2
::::      [~.ud 1]
::::    ==
::::    :-  %not-false-qualified-column
::::    :*  [%not [q-col-2 ~ ~] ~]
::::      q-col-1
::::      q-col-2
::::      [~.ud 1]
::::    ==
::::    :-  %not-true-unqualified-column
::::    :*  [%not [q-col-2 ~ ~] ~]
::::      q-col-1
::::      q-col-2
::::      [~.ud 1]
::::    ==
::::    :-  %not-false-unqualified-column
::::    :*  [%not [q-col-2 ~ ~] ~]
::::      q-col-1
::::      q-col-2
::::      [~.ud 1]
::::    ==
::  ==
::::
::::  ::::::::::::::::::::
::::  :::: THEN TESTS ::::
::::  ::::::::::::::::::::
::::
::::  set up some costant context for tests
::::
::::  tests for all possible then return types
::::  fail scenarios to test later:
::::    - qualified column: no table with column
::::    - unqualified column: no table with column
::::    - scalar alias: no scalar with alias
::::    - embedded scalar: no scalar with alias
::::
::++  test-if-then
::  %-  run-tests
::  :~
::    :-  %qualified-col
::    :*  true-predicate
::      q-col-1
::      q-col-2
::      [~.ud 1]
::    ==
::    :-  %unqualified-col
::    :*  true-predicate
::      u-col-4
::      u-col-5
::      [~.ud 4]
::    ==
::    :-  %literal-value
::    :*  true-predicate
::      [%literal-value [~.t 'foo']]
::      [%literal-value [~.t 'bar']]
::      [~.t 'foo']
::    ==
::    :-  %scalar-name
::    :*  true-predicate
::      [%scalar-name %scalar1]
::      q-col-2
::      [~.ud 3]
::    ==
::    :-  %embedded-scalar
::    :*  true-predicate
::      (~(got by embedded-scalars) %scalar1)
::      q-col-2
::      [~.ud 3]
::    ==
::  ==
::::
::::  ::::::::::::::::::::
::::  :::: ELSE TESTS ::::
::::  ::::::::::::::::::::
::::
::::  set up some costant context for tests
::::
::::  tests for all possible else return types
::::  fail scenarios to test later:
::::    - qualified column: no table with column
::::    - unqualified column: no table with column
::::    - scalar alias: no scalar with alias
::::    - embedded scalar: no scalar with alias
::::
::++  test-if-else
::  %-  run-tests
::  :~
::    :-  %qualified-col
::    :*  false-predicate
::      q-col-1
::      q-col-2
::      [~.ud 2]
::    ==
::    :-  %unqualified-col
::    :*  false-predicate
::      u-col-4
::      u-col-5
::      [~.ud 5]
::    ==
::    :-  %literal-value
::    :*  false-predicate
::      [%literal-value [~.t 'foo']]
::      [%literal-value [~.t 'bar']]
::      [~.t 'bar']
::    ==
::    :-  %scalar-name
::    :*  false-predicate
::      q-col-2
::      [%scalar-name %scalar1]
::      [~.ud 3]
::    ==
::    :-  %embedded-scalar
::    :*  false-predicate
::      q-col-2
::      (~(got by embedded-scalars) %scalar1)
::      [~.ud 3]
::    ==
::  ==
--
