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
++  test-if-predicate-eq
  %-  pred-row-test
  :~
    :-  %eq-dimes
    :*  [%eq [[~.ud 1] ~ ~] [[~.ud 1] ~ ~]]
      pred-q-col-1
      pred-q-col-2
      [~.ud 1]
    ==
    :-  %eq-qualified-columns
    :*  [%eq [pred-q-col-1 ~ ~] [pred-q-col-2 ~ ~]]
      pred-q-col-1
      pred-q-col-2
      [~.ud 2]
    ==
    :-  %eq-qualified-column-and-dime
    :*  [%eq [pred-q-col-1 ~ ~] [[~.ud 1] ~ ~]]
      pred-q-col-1
      pred-q-col-2
      [~.ud 1]
    ==
    :-  %eq-dime-and-qualified-column
    :*  [%eq [[~.ud 1] ~ ~] [pred-q-col-1 ~ ~]]
      pred-q-col-1
      pred-q-col-2
      [~.ud 1]
    ==
    :-  %eq-unqualified-columns
    :*  [%eq [pred-u-col-4 ~ ~] [pred-u-col-5 ~ ~]]
      pred-u-col-4
      pred-u-col-5
      [~.ud 5]
    ==
    :-  %eq-unqualified-column-and-dime
    :*  [%eq [pred-u-col-4 ~ ~] [[~.ud 4] ~ ~]]
      pred-u-col-4
      pred-u-col-5
      [~.ud 4]
    ==
    :-  %eq-dime-and-unqualified-column
    :*  [%eq [[~.ud 4] ~ ~] [pred-u-col-4 ~ ~]]
      pred-u-col-4
      pred-u-col-5
      [~.ud 4]
    ==
  ==
::
::  %neq tests
++  test-if-predicate-neq
  %-  pred-row-test
  :~
    :-  %neq-dimes
    :*  [%neq [[~.ud 1] ~ ~] [[~.ud 1] ~ ~]]
      pred-q-col-1
      pred-q-col-2
      [~.ud 2]
    ==
    :-  %neq-qualified-columns
    :*  [%neq [pred-q-col-1 ~ ~] [pred-q-col-2 ~ ~]]
      pred-q-col-1
      pred-q-col-2
      [~.ud 1]
    ==
    :-  %neq-qualified-column-and-dime
    :*  [%neq [pred-q-col-1 ~ ~] [[~.ud 1] ~ ~]]
      pred-q-col-1
      pred-q-col-2
      [~.ud 2]
    ==
    :-  %neq-dime-and-qualified-column
    :*  [%neq [[~.ud 1] ~ ~] [pred-q-col-1 ~ ~]]
      pred-q-col-1
      pred-q-col-2
      [~.ud 2]
    ==
    :-  %neq-unqualified-columns
    :*  [%neq [pred-u-col-4 ~ ~] [pred-u-col-5 ~ ~]]
      pred-u-col-4
      pred-u-col-5
      [~.ud 4]
    ==
    :-  %neq-unqualified-column-and-dime
    :*  [%neq [pred-u-col-4 ~ ~] [[~.ud 4] ~ ~]]
      pred-u-col-4
      pred-u-col-5
      [~.ud 5]
    ==
    :-  %neq-dime-and-unqualified-column
    :*  [%neq [[~.ud 4] ~ ~] [pred-u-col-4 ~ ~]]
      pred-u-col-4
      pred-u-col-5
      [~.ud 5]
    ==
  ==
::
::  %gte tests
++  test-if-predicate-gte
  %-  pred-row-test
  :~
    :-  %gte-dimes-gt
    :*  [%gte [[~.ud 2] ~ ~] [[~.ud 1] ~ ~]]
      pred-q-col-1
      pred-q-col-2
      [~.ud 1]
    ==
    :-  %gte-dimes-eq
    :*  [%gte [[~.ud 1] ~ ~] [[~.ud 1] ~ ~]]
      pred-q-col-1
      pred-q-col-2
      [~.ud 1]
    ==
    :-  %gte-dimes-false
    :*  [%gte [[~.ud 1] ~ ~] [[~.ud 2] ~ ~]]
      pred-q-col-1
      pred-q-col-2
      [~.ud 2]
    ==
    :-  %gte-qualified-columns-gt
    :*  [%gte [pred-q-col-2 ~ ~] [pred-q-col-1 ~ ~]]
      pred-q-col-1
      pred-q-col-2
      [~.ud 1]
    ==
    :-  %gte-qualified-columns-eq
    :*  [%gte [pred-q-col-1 ~ ~] [pred-q-col-1 ~ ~]]
      pred-q-col-1
      pred-q-col-2
      [~.ud 1]
    ==
    :-  %gte-qualified-columns-false
    :*  [%gte [pred-q-col-1 ~ ~] [pred-q-col-2 ~ ~]]
      pred-q-col-1
      pred-q-col-2
      [~.ud 2]
    ==
    :-  %gte-qualified-column-and-dime-gt
    :*  [%gte [pred-q-col-2 ~ ~] [[~.ud 1] ~ ~]]
      pred-q-col-1
      pred-q-col-2
      [~.ud 1]
    ==
    :-  %gte-qualified-column-and-dime-eq
    :*  [%gte [pred-q-col-1 ~ ~] [[~.ud 1] ~ ~]]
      pred-q-col-1
      pred-q-col-2
      [~.ud 1]
    ==
    :-  %gte-qualified-column-and-dime-false
    :*  [%gte [pred-q-col-1 ~ ~] [[~.ud 2] ~ ~]]
      pred-q-col-1
      pred-q-col-2
      [~.ud 2]
    ==
    :-  %gte-dime-and-qualified-column-gt
    :*  [%gte [[~.ud 2] ~ ~] [pred-q-col-1 ~ ~]]
      pred-q-col-1
      pred-q-col-2
      [~.ud 1]
    ==
    :-  %gte-dime-and-qualified-column-eq
    :*  [%gte [[~.ud 1] ~ ~] [pred-q-col-1 ~ ~]]
      pred-q-col-1
      pred-q-col-2
      [~.ud 1]
    ==
    :-  %gte-dime-and-qualified-column-false
    :*  [%gte [[~.ud 1] ~ ~] [pred-q-col-2 ~ ~]]
      pred-q-col-1
      pred-q-col-2
      [~.ud 2]
    ==
    :-  %gte-unqualified-columns-gt
    :*  [%gte [pred-u-col-5 ~ ~] [pred-u-col-4 ~ ~]]
      pred-u-col-4
      pred-u-col-5
      [~.ud 4]
    ==
    :-  %gte-unqualified-columns-eq
    :*  [%gte [pred-u-col-4 ~ ~] [pred-u-col-4 ~ ~]]
      pred-u-col-4
      pred-u-col-5
      [~.ud 4]
    ==
    :-  %gte-unqualified-columns-false
    :*  [%gte [pred-u-col-4 ~ ~] [pred-u-col-5 ~ ~]]
      pred-u-col-4
      pred-u-col-5
      [~.ud 5]
    ==
    :-  %gte-unqualified-column-and-dime-gt
    :*  [%gte [pred-u-col-5 ~ ~] [[~.ud 4] ~ ~]]
      pred-u-col-4
      pred-u-col-5
      [~.ud 4]
    ==
    :-  %gte-unqualified-column-and-dime-eq
    :*  [%gte [pred-u-col-4 ~ ~] [[~.ud 4] ~ ~]]
      pred-u-col-4
      pred-u-col-5
      [~.ud 4]
    ==
    :-  %gte-unqualified-column-and-dime-false
    :*  [%gte [pred-u-col-4 ~ ~] [[~.ud 5] ~ ~]]
      pred-u-col-4
      pred-u-col-5
      [~.ud 5]
    ==
    :-  %gte-dime-and-unqualified-column-gt
    :*  [%gte [[~.ud 5] ~ ~] [pred-u-col-4 ~ ~]]
      pred-u-col-4
      pred-u-col-5
      [~.ud 4]
    ==
    :-  %gte-dime-and-unqualified-column-eq
    :*  [%gte [[~.ud 4] ~ ~] [pred-u-col-4 ~ ~]]
      pred-u-col-4
      pred-u-col-5
      [~.ud 4]
    ==
    :-  %gte-dime-and-unqualified-column-false
    :*  [%gte [[~.ud 4] ~ ~] [pred-u-col-5 ~ ~]]
      pred-u-col-4
      pred-u-col-5
      [~.ud 5]
    ==
  ==
::
::  %gt tests
++  test-if-predicate-gt
  %-  pred-row-test
  :~
    :-  %gt-dimes-gt
    :*  [%gt [[~.ud 2] ~ ~] [[~.ud 1] ~ ~]]
      pred-q-col-1
      pred-q-col-2
      [~.ud 1]
    ==
    :-  %gt-dimes-false
    :*  [%gt [[~.ud 1] ~ ~] [[~.ud 2] ~ ~]]
      pred-q-col-1
      pred-q-col-2
      [~.ud 2]
    ==
    :-  %gt-qualified-columns-gt
    :*  [%gt [pred-q-col-2 ~ ~] [pred-q-col-1 ~ ~]]
      pred-q-col-1
      pred-q-col-2
      [~.ud 1]
    ==
    :-  %gt-qualified-columns-false
    :*  [%gt [pred-q-col-1 ~ ~] [pred-q-col-2 ~ ~]]
      pred-q-col-1
      pred-q-col-2
      [~.ud 2]
    ==
    :-  %gt-qualified-column-and-dime-gt
    :*  [%gt [pred-q-col-2 ~ ~] [[~.ud 1] ~ ~]]
      pred-q-col-1
      pred-q-col-2
      [~.ud 1]
    ==
    :-  %gt-qualified-column-and-dime-false
    :*  [%gt [pred-q-col-1 ~ ~] [[~.ud 2] ~ ~]]
      pred-q-col-1
      pred-q-col-2
      [~.ud 2]
    ==
    :-  %gt-dime-and-qualified-column-gt
    :*  [%gt [[~.ud 2] ~ ~] [pred-q-col-1 ~ ~]]
      pred-q-col-1
      pred-q-col-2
      [~.ud 1]
    ==
    :-  %gt-dime-and-qualified-column-false
    :*  [%gt [[~.ud 1] ~ ~] [pred-q-col-2 ~ ~]]
      pred-q-col-1
      pred-q-col-2
      [~.ud 2]
    ==
    :-  %gt-unqualified-columns-gt
    :*  [%gt [pred-u-col-5 ~ ~] [pred-u-col-4 ~ ~]]
      pred-u-col-4
      pred-u-col-5
      [~.ud 4]
    ==
    :-  %gt-unqualified-columns-false
    :*  [%gt [pred-u-col-4 ~ ~] [pred-u-col-5 ~ ~]]
      pred-u-col-4
      pred-u-col-5
      [~.ud 5]
    ==
    :-  %gt-unqualified-column-and-dime-gt
    :*  [%gt [pred-u-col-5 ~ ~] [[~.ud 4] ~ ~]]
      pred-u-col-4
      pred-u-col-5
      [~.ud 4]
    ==
    :-  %gt-unqualified-column-and-dime-false
    :*  [%gt [pred-u-col-4 ~ ~] [[~.ud 5] ~ ~]]
      pred-u-col-4
      pred-u-col-5
      [~.ud 5]
    ==
    :-  %gt-dime-and-unqualified-column-gt
    :*  [%gt [[~.ud 5] ~ ~] [pred-u-col-4 ~ ~]]
      pred-u-col-4
      pred-u-col-5
      [~.ud 4]
    ==
    :-  %gt-dime-and-unqualified-column-false
    :*  [%gt [[~.ud 4] ~ ~] [pred-u-col-5 ~ ~]]
      pred-u-col-4
      pred-u-col-5
      [~.ud 5]
    ==
  ==
::
::  %lte tests
++  test-if-predicate-lte
  %-  pred-row-test
  :~
    :-  %lte-dimes-lt
    :*  [%lte [[~.ud 1] ~ ~] [[~.ud 2] ~ ~]]
      pred-q-col-1
      pred-q-col-2
      [~.ud 1]
    ==
    :-  %lte-dimes-eq
    :*  [%lte [[~.ud 1] ~ ~] [[~.ud 1] ~ ~]]
      pred-q-col-1
      pred-q-col-2
      [~.ud 1]
    ==
    :-  %lte-dimes-false
    :*  [%lte [[~.ud 2] ~ ~] [[~.ud 1] ~ ~]]
      pred-q-col-1
      pred-q-col-2
      [~.ud 2]
    ==
    :-  %lte-qualified-columns-lt
    :*  [%lte [pred-q-col-1 ~ ~] [pred-q-col-2 ~ ~]]
      pred-q-col-1
      pred-q-col-2
      [~.ud 1]
    ==
    :-  %lte-qualified-columns-eq
    :*  [%lte [pred-q-col-1 ~ ~] [pred-q-col-1 ~ ~]]
      pred-q-col-1
      pred-q-col-2
      [~.ud 1]
    ==
    :-  %lte-qualified-columns-false
    :*  [%lte [pred-q-col-2 ~ ~] [pred-q-col-1 ~ ~]]
      pred-q-col-1
      pred-q-col-2
      [~.ud 2]
    ==
    :-  %lte-qualified-column-and-dime-lt
    :*  [%lte [pred-q-col-1 ~ ~] [[~.ud 2] ~ ~]]
      pred-q-col-1
      pred-q-col-2
      [~.ud 1]
    ==
    :-  %lte-qualified-column-and-dime-eq
    :*  [%lte [pred-q-col-1 ~ ~] [[~.ud 1] ~ ~]]
      pred-q-col-1
      pred-q-col-2
      [~.ud 1]
    ==
    :-  %lte-qualified-column-and-dime-false
    :*  [%lte [pred-q-col-2 ~ ~] [[~.ud 1] ~ ~]]
      pred-q-col-1
      pred-q-col-2
      [~.ud 2]
    ==
    :-  %lte-dime-and-qualified-column-lt
    :*  [%lte [[~.ud 1] ~ ~] [pred-q-col-2 ~ ~]]
      pred-q-col-1
      pred-q-col-2
      [~.ud 1]
    ==
    :-  %lte-dime-and-qualified-column-eq
    :*  [%lte [[~.ud 1] ~ ~] [pred-q-col-1 ~ ~]]
      pred-q-col-1
      pred-q-col-2
      [~.ud 1]
    ==
    :-  %lte-dime-and-qualified-column-false
    :*  [%lte [[~.ud 2] ~ ~] [pred-q-col-1 ~ ~]]
      pred-q-col-1
      pred-q-col-2
      [~.ud 2]
    ==
    :-  %lte-unqualified-columns-lt
    :*  [%lte [pred-u-col-4 ~ ~] [pred-u-col-5 ~ ~]]
      pred-u-col-4
      pred-u-col-5
      [~.ud 4]
    ==
    :-  %lte-unqualified-columns-eq
    :*  [%lte [pred-u-col-4 ~ ~] [pred-u-col-4 ~ ~]]
      pred-u-col-4
      pred-u-col-5
      [~.ud 4]
    ==
    :-  %lte-unqualified-columns-false
    :*  [%lte [pred-u-col-5 ~ ~] [pred-u-col-4 ~ ~]]
      pred-u-col-4
      pred-u-col-5
      [~.ud 5]
    ==
    :-  %lte-unqualified-column-and-dime-lt
    :*  [%lte [pred-u-col-4 ~ ~] [[~.ud 5] ~ ~]]
      pred-u-col-4
      pred-u-col-5
      [~.ud 4]
    ==
    :-  %lte-unqualified-column-and-dime-eq
    :*  [%lte [pred-u-col-4 ~ ~] [[~.ud 4] ~ ~]]
      pred-u-col-4
      pred-u-col-5
      [~.ud 4]
    ==
    :-  %lte-unqualified-column-and-dime-false
    :*  [%lte [pred-u-col-5 ~ ~] [[~.ud 4] ~ ~]]
      pred-u-col-4
      pred-u-col-5
      [~.ud 5]
    ==
    :-  %lte-dime-and-unqualified-column-lt
    :*  [%lte [[~.ud 4] ~ ~] [pred-u-col-5 ~ ~]]
      pred-u-col-4
      pred-u-col-5
      [~.ud 4]
    ==
    :-  %lte-dime-and-unqualified-column-eq
    :*  [%lte [[~.ud 4] ~ ~] [pred-u-col-4 ~ ~]]
      pred-u-col-4
      pred-u-col-5
      [~.ud 4]
    ==
    :-  %lte-dime-and-unqualified-column-false
    :*  [%lte [[~.ud 5] ~ ~] [pred-u-col-4 ~ ~]]
      pred-u-col-4
      pred-u-col-5
      [~.ud 5]
    ==
  ==
::
::  %lt tests
++  test-if-predicate-lt
  %-  pred-row-test
  :~
    :-  %lt-dimes-lt
    :*  [%lt [[~.ud 1] ~ ~] [[~.ud 2] ~ ~]]
      pred-q-col-1
      pred-q-col-2
      [~.ud 1]
    ==
    :-  %lt-dimes-false
    :*  [%lt [[~.ud 2] ~ ~] [[~.ud 1] ~ ~]]
      pred-q-col-1
      pred-q-col-2
      [~.ud 2]
    ==
    :-  %lt-qualified-columns-lt
    :*  [%lt [pred-q-col-1 ~ ~] [pred-q-col-2 ~ ~]]
      pred-q-col-1
      pred-q-col-2
      [~.ud 1]
    ==
    :-  %lt-qualified-columns-false
    :*  [%lt [pred-q-col-2 ~ ~] [pred-q-col-1 ~ ~]]
      pred-q-col-1
      pred-q-col-2
      [~.ud 2]
    ==
    :-  %lt-qualified-column-and-dime-lt
    :*  [%lt [pred-q-col-1 ~ ~] [[~.ud 2] ~ ~]]
      pred-q-col-1
      pred-q-col-2
      [~.ud 1]
    ==
    :-  %lt-qualified-column-and-dime-false
    :*  [%lt [pred-q-col-2 ~ ~] [[~.ud 1] ~ ~]]
      pred-q-col-1
      pred-q-col-2
      [~.ud 2]
    ==
    :-  %lt-dime-and-qualified-column-lt
    :*  [%lt [[~.ud 1] ~ ~] [pred-q-col-2 ~ ~]]
      pred-q-col-1
      pred-q-col-2
      [~.ud 1]
    ==
    :-  %lt-dime-and-qualified-column-false
    :*  [%lt [[~.ud 2] ~ ~] [pred-q-col-1 ~ ~]]
      pred-q-col-1
      pred-q-col-2
      [~.ud 2]
    ==
    :-  %lt-unqualified-columns-lt
    :*  [%lt [pred-u-col-4 ~ ~] [pred-u-col-5 ~ ~]]
      pred-u-col-4
      pred-u-col-5
      [~.ud 4]
    ==
    :-  %lt-unqualified-columns-false
    :*  [%lt [pred-u-col-5 ~ ~] [pred-u-col-4 ~ ~]]
      pred-u-col-4
      pred-u-col-5
      [~.ud 5]
    ==
    :-  %lt-unqualified-column-and-dime-lt
    :*  [%lt [pred-u-col-4 ~ ~] [[~.ud 5] ~ ~]]
      pred-u-col-4
      pred-u-col-5
      [~.ud 4]
    ==
    :-  %lt-unqualified-column-and-dime-false
    :*  [%lt [pred-u-col-5 ~ ~] [[~.ud 4] ~ ~]]
      pred-u-col-4
      pred-u-col-5
      [~.ud 5]
    ==
    :-  %lt-dime-and-unqualified-column-lt
    :*  [%lt [[~.ud 4] ~ ~] [pred-u-col-5 ~ ~]]
      pred-u-col-4
      pred-u-col-5
      [~.ud 4]
    ==
    :-  %lt-dime-and-unqualified-column-false
    :*  [%lt [[~.ud 5] ~ ~] [pred-u-col-4 ~ ~]]
      pred-u-col-4
      pred-u-col-5
      [~.ud 5]
    ==
  ==
::
::  %in tests
++  test-if-predicate-in
  %-  pred-row-test
  :~
    :-  %in-dime
    :*  [%in [[~.ud 1] ~ ~] [[%value-literals [~.ud '1;2;4;5']] ~ ~]]
      pred-q-col-1
      pred-q-col-2
      [~.ud 1]
    ==
    :-  %in-dime-false
    :*  [%in [[~.ud 3] ~ ~] [[%value-literals [~.ud '1;2;4;5']] ~ ~]]
      pred-q-col-1
      pred-q-col-2
      [~.ud 2]
    ==
    :-  %in-qualified-column
    :*  [%in [pred-q-col-1 ~ ~] [[%value-literals [~.ud '1;2;4;5']] ~ ~]]
      pred-q-col-1
      pred-q-col-2
      [~.ud 1]
    ==
    :-  %in-qualified-column-false
    :*  [%in [pred-q-col-3 ~ ~] [[%value-literals [~.ud '1;2;4;5']] ~ ~]]
      pred-q-col-1
      pred-q-col-2
      [~.ud 2]
    ==
    :-  %in-unqualified-column
    :*  [%in [pred-u-col-4 ~ ~] [[%value-literals [~.ud '1;2;4;5']] ~ ~]]
      pred-u-col-4
      pred-u-col-5
      [~.ud 4]
    ==
    :-  %in-unqualified-column-false
    :*  [%in [pred-u-col-6 ~ ~] [[%value-literals [~.ud '1;2;4;5']] ~ ~]]
      pred-u-col-4
      pred-u-col-5
      [~.ud 5]
    ==
  ==
::
::  %not-in tests
++  test-if-predicate-not-in
  %-  pred-row-test
  :~
    :-  %not-in-dime
    :*  [%not-in [[~.ud 3] ~ ~] [[%value-literals [~.ud '1;2;4;5']] ~ ~]]
      pred-q-col-1
      pred-q-col-2
      [~.ud 1]
    ==
    :-  %not-in-dime-false
    :*  [%not-in [[~.ud 1] ~ ~] [[%value-literals [~.ud '1;2;4;5']] ~ ~]]
      pred-q-col-1
      pred-q-col-2
      [~.ud 2]
    ==
    :-  %not-in-qualified-column
    :*  [%not-in [pred-q-col-3 ~ ~] [[%value-literals [~.ud '1;2;4;5']] ~ ~]]
      pred-q-col-1
      pred-q-col-2
      [~.ud 1]
    ==
    :-  %not-in-qualified-column-false
    :*  [%not-in [pred-q-col-1 ~ ~] [[%value-literals [~.ud '1;2;4;5']] ~ ~]]
      pred-q-col-1
      pred-q-col-2
      [~.ud 2]
    ==
    :-  %not-in-unqualified-column
    :*  [%not-in [pred-u-col-6 ~ ~] [[%value-literals [~.ud '1;2;4;5']] ~ ~]]
      pred-u-col-4
      pred-u-col-5
      [~.ud 4]
    ==
    :-  %not-in-unqualified-column-false
    :*  [%not-in [pred-u-col-4 ~ ~] [[%value-literals [~.ud '1;2;4;5']] ~ ~]]
      pred-u-col-4
      pred-u-col-5
      [~.ud 5]
    ==
  ==
::
::  %between tests
++  test-if-predicate-between
  =/  mk-between-pred
    |*  [val-to-test=* lower-bound=* upper-bound=*]
    :+  %between
      [%gte [val-to-test ~ ~] [lower-bound ~ ~]]
    [%lte [val-to-test ~ ~] [upper-bound ~ ~]]
  %-  pred-row-test
  :~
    :-  %between-dime-dimes
    :*  (mk-between-pred [~.ud 2] [~.ud 1] [~.ud 3])
      pred-q-col-1
      pred-q-col-2
      [~.ud 1]
    ==
    :-  %between-qualified-column-qualified-columns
    :*  (mk-between-pred pred-q-col-2 pred-q-col-1 pred-q-col-3)
      pred-q-col-1
      pred-q-col-2
      [~.ud 1]
    ==
    :-  %between-qualified-column-dime-and-qualified-column
    :*  (mk-between-pred pred-q-col-2 [~.ud 1] pred-q-col-3)
      pred-q-col-1
      pred-q-col-2
      [~.ud 1]
    ==
    :-  %between-qualified-column-qualified-column-and-dime
    :*  (mk-between-pred pred-q-col-2 pred-q-col-1 [~.ud 3])
      pred-q-col-1
      pred-q-col-2
      [~.ud 1]
    ==
    :-  %between-qualified-column-dimes
    :*  (mk-between-pred pred-q-col-2 [~.ud 1] [~.ud 3])
      pred-q-col-1
      pred-q-col-2
      [~.ud 1]
    ==
    :-  %between-unqualified-column-unqualified-columns
    :*  (mk-between-pred pred-u-col-5 pred-u-col-4 pred-u-col-6)
      pred-u-col-4
      pred-u-col-5
      [~.ud 4]
    ==
    :-  %between-unqualified-column-dime-and-unqualified-column
    :*  (mk-between-pred pred-u-col-5 [~.ud 4] pred-u-col-6)
      pred-u-col-4
      pred-u-col-5
      [~.ud 4]
    ==
    :-  %between-unqualified-column-unqualified-column-and-dime
    :*  (mk-between-pred pred-u-col-5 pred-u-col-4 [~.ud 6])
      pred-u-col-4
      pred-u-col-5
      [~.ud 4]
    ==
    :-  %between-unqualified-column-dimes
    :*  (mk-between-pred pred-u-col-5 [~.ud 4] [~.ud 6])
      pred-u-col-4
      pred-u-col-5
      [~.ud 4]
    ==
    :-  %between-dime-dimes-false
    :*  (mk-between-pred [~.ud 5] [~.ud 1] [~.ud 3])
      pred-q-col-1
      pred-q-col-2
      [~.ud 2]
    ==
    :-  %between-qualified-column-dimes-false
    :*  (mk-between-pred pred-q-col-1 [~.ud 2] [~.ud 4])
      pred-q-col-1
      pred-q-col-2
      [~.ud 2]
    ==
    :-  %between-unqualified-column-dimes-false
    :*  (mk-between-pred pred-u-col-4 [~.ud 5] [~.ud 7])
      pred-u-col-4
      pred-u-col-5
      [~.ud 5]
    ==
  ==
::
::  %not-between tests
++  test-if-predicate-not-between
  =/  mk-not-between-pred
    |*  [val-to-test=* lower-bound=* upper-bound=*]
    :+  %not-between
      [%gte [val-to-test ~ ~] [lower-bound ~ ~]]
    [%lte [val-to-test ~ ~] [upper-bound ~ ~]]
  %-  pred-row-test
  :~
    :-  %not-between-dime-dimes
    :*  (mk-not-between-pred [~.ud 5] [~.ud 1] [~.ud 3])
      pred-q-col-1
      pred-q-col-2
      [~.ud 1]
    ==
    :-  %not-between-qualified-column-qualified-columns
    :*  (mk-not-between-pred pred-q-col-1 pred-q-col-2 pred-q-col-3)
      pred-q-col-1
      pred-q-col-2
      [~.ud 1]
    ==
    :-  %not-between-qualified-column-dime-and-qualified-column
    :*  (mk-not-between-pred pred-q-col-1 [~.ud 2] pred-q-col-3)
      pred-q-col-1
      pred-q-col-2
      [~.ud 1]
    ==
    :-  %not-between-qualified-column-qualified-column-and-dime
    :*  (mk-not-between-pred pred-q-col-1 pred-q-col-2 [~.ud 3])
      pred-q-col-1
      pred-q-col-2
      [~.ud 1]
    ==
    :-  %not-between-qualified-column-dimes
    :*  (mk-not-between-pred pred-q-col-1 [~.ud 2] [~.ud 4])
      pred-q-col-1
      pred-q-col-2
      [~.ud 1]
    ==
    :-  %not-between-unqualified-column-unqualified-columns
    :*  (mk-not-between-pred pred-u-col-4 pred-u-col-5 pred-u-col-6)
      pred-u-col-4
      pred-u-col-5
      [~.ud 4]
    ==
    :-  %not-between-unqualified-column-dime-and-unqualified-column
    :*  (mk-not-between-pred pred-u-col-4 [~.ud 5] pred-u-col-6)
      pred-u-col-4
      pred-u-col-5
      [~.ud 4]
    ==
    :-  %not-between-unqualified-column-unqualified-column-and-dime
    :*  (mk-not-between-pred pred-u-col-4 pred-u-col-5 [~.ud 6])
      pred-u-col-4
      pred-u-col-5
      [~.ud 4]
    ==
    :-  %not-between-unqualified-column-dimes
    :*  (mk-not-between-pred pred-u-col-4 [~.ud 5] [~.ud 7])
      pred-u-col-4
      pred-u-col-5
      [~.ud 4]
    ==
    :-  %not-between-dime-dimes-false
    :*  (mk-not-between-pred [~.ud 2] [~.ud 1] [~.ud 3])
      pred-q-col-1
      pred-q-col-2
      [~.ud 2]
    ==
    :-  %not-between-qualified-column-dimes-false
    :*  (mk-not-between-pred pred-q-col-2 [~.ud 1] [~.ud 3])
      pred-q-col-1
      pred-q-col-2
      [~.ud 2]
    ==
    :-  %not-between-unqualified-column-dimes-false
    :*  (mk-not-between-pred pred-u-col-5 [~.ud 4] [~.ud 6])
      pred-u-col-4
      pred-u-col-5
      [~.ud 5]
    ==
  ==
::
::  %and tests
++  test-if-predicate-and
  %-  pred-row-test
  :~
    :-  %and-true
    :*  :+  %and
          [%eq [[~.ud 1] ~ ~] [[~.ud 1] ~ ~]]
        [%eq [[~.ud 1] ~ ~] [[~.ud 1] ~ ~]]
      pred-q-col-1
      pred-q-col-2
      [~.ud 1]
    ==
    :-  %and-false
    :*  :+  %and
          [%eq [[~.ud 1] ~ ~] [[~.ud 1] ~ ~]]
        [%eq [[~.ud 0] ~ ~] [[~.ud 1] ~ ~]]
      pred-q-col-1
      pred-q-col-2
      [~.ud 2]
    ==
  ==
::
::  %or tests
++  test-if-predicate-or
  %-  pred-row-test
  :~
    :-  %or-true-true
    :*  :+  %or
          [%eq [[~.ud 1] ~ ~] [[~.ud 1] ~ ~]]
        [%eq [[~.ud 1] ~ ~] [[~.ud 1] ~ ~]]
      pred-q-col-1
      pred-q-col-2
      [~.ud 1]
    ==
    :-  %or-true-false
    :*  :+  %or
          [%eq [[~.ud 0] ~ ~] [[~.ud 1] ~ ~]]
        [%eq [[~.ud 1] ~ ~] [[~.ud 1] ~ ~]]
      pred-q-col-1
      pred-q-col-2
      [~.ud 1]
    ==
    :-  %or-false-false
    :*  :+  %or
          [%eq [[~.ud 0] ~ ~] [[~.ud 1] ~ ~]]
        [%eq [[~.ud 0] ~ ~] [[~.ud 1] ~ ~]]
      pred-q-col-1
      pred-q-col-2
      [~.ud 2]
    ==
  ==
::
::  %not tests
++  test-if-predicate-not
  %-  pred-row-test
  :~
    :-  %not-true-expression
    :*  [%not [%eq [[~.ud 1] ~ ~] [[~.ud 1] ~ ~]] ~]
      pred-q-col-1
      pred-q-col-2
      [~.ud 2]
    ==
    :-  %not-false-expression
    :*  [%not [%eq [[~.ud 0] ~ ~] [[~.ud 1] ~ ~]] ~]
      pred-q-col-1
      pred-q-col-2
      [~.ud 1]
    ==
::    :-  %not-true-qualified-column
::    :*  [%not [pred-q-col-2 ~ ~] ~]
::      pred-q-col-1
::      pred-q-col-2
::      [~.ud 1]
::    ==
::    :-  %not-false-qualified-column
::    :*  [%not [pred-q-col-2 ~ ~] ~]
::      pred-q-col-1
::      pred-q-col-2
::      [~.ud 1]
::    ==
::    :-  %not-true-unqualified-column
::    :*  [%not [pred-q-col-2 ~ ~] ~]
::      pred-q-col-1
::      pred-q-col-2
::      [~.ud 1]
::    ==
::    :-  %not-false-unqualified-column
::    :*  [%not [pred-q-col-2 ~ ~] ~]
::      pred-q-col-1
::      pred-q-col-2
::      [~.ud 1]
::    ==
  ==
::
:: TODO: value-literals cte-alias scalar-alias aggregate

::  ::::::::::::::::::::
::  :::: THEN TESTS ::::
::  ::::::::::::::::::::
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
++  test-if-then-qualified-col-01
  =/  if-expr
    :*  %if-then-else
      if=true-predicate
      then=[then-q-col-1]
      else=[then-q-col-2]
    ==
  =/  scalar-to-apply
    (prepare-scalar if-expr then-named-ctes then-lookups then-scalars)
  %+  expect-eq
    !>  [~.ud 1]
    !>  (apply-scalar then-row scalar-to-apply)
::
::  test return unqualified column
::  fail scenario: no table with column
++  test-if-then-unqualified-col-01
  =/  if-expr
    :*  %if-then-else
      if=true-predicate
      then=[then-u-col-4]
      else=[then-u-col-5]
    ==
  =/  scalar-to-apply
    (prepare-scalar if-expr then-named-ctes then-lookups then-scalars)
  %+  expect-eq
    !>  [~.ud 4]
    !>  (apply-scalar then-row scalar-to-apply)
::
::  test return literal-value
++  test-if-then-literal-value-01
  =/  if-expr
    :*  %if-then-else
      if=true-predicate
      then=[[%literal-value [~.t 'foo']]]
      else=[[%literal-value [~.t 'bar']]]
    ==
  =/  scalar-to-apply
    (prepare-scalar if-expr then-named-ctes then-lookups then-scalars)
  %+  expect-eq
    !>  [~.t 'foo']
    !>  (apply-scalar then-row scalar-to-apply)
::
::  test return cte-alias
::++  test-if-then-cte-alias-01
::  =/  if-expr
::    :*  %if-then-else
::      if=true-predicate
::      then=[then-q-col-1]
::      else=[then-q-col-2]
::    ==
::  =/  scalar-to-apply  (prepare-scalar if-expr then-named-ctes then-lookups)
::  %+  expect-eq
::    !>  1
::    !>  (apply-scalar then-row scalar-to-apply)
::
::  test return scalar-alias
::  fail scenario: no scalar with alias
++  test-if-then-scalar-alias-01
  =/  if-expr
    :*  %if-then-else
      if=true-predicate
      then=[[%scalar-alias %scalar1]]
      else=[then-q-col-2]
    ==
  =/  scalar-to-apply
    (prepare-scalar if-expr then-named-ctes then-lookups then-scalars)
  %+  expect-eq
    !>  [~.ud 3]
    !>  (apply-scalar then-row scalar-to-apply)
::
::  test return embedded scalar
::  fail scenario: no scalar with alias
++  test-if-then-embedded-scalar-01
  =/  if-expr
    :*  %if-then-else
      if=true-predicate
      then=[(~(got by then-scalars) %scalar1)]
      else=[then-q-col-2]
    ==
  =/  scalar-to-apply
    (prepare-scalar if-expr then-named-ctes then-lookups then-scalars)
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
::  tests for all possible then return types
::
::  test return qualified column
::  fail scenario: no table with column
++  test-if-else-qualified-col-01
  =/  if-expr
    :*  %if-then-else
      if=false-predicate
      then=[else-q-col-1]
      else=[else-q-col-2]
    ==
  =/  scalar-to-apply
    (prepare-scalar if-expr else-named-ctes else-lookups else-scalars)
  %+  expect-eq
    !>  [~.ud 2]
    !>  (apply-scalar else-row scalar-to-apply)
::
::  test return unqualified column
::  fail scenario: no table with column
++  test-if-else-unqualified-col-01
  =/  if-expr
    :*  %if-then-else
      if=false-predicate
      then=[else-u-col-4]
      else=[else-u-col-5]
    ==
  =/  scalar-to-apply
    (prepare-scalar if-expr else-named-ctes else-lookups else-scalars)
  %+  expect-eq
    !>  [~.ud 5]
    !>  (apply-scalar else-row scalar-to-apply)
::
::  test return literal-value
++  test-if-else-literal-value-01
  =/  if-expr
    :*  %if-then-else
      if=false-predicate
      then=[[%literal-value [~.t 'foo']]]
      else=[[%literal-value [~.t 'bar']]]
    ==
  =/  scalar-to-apply
    (prepare-scalar if-expr else-named-ctes else-lookups else-scalars)
  %+  expect-eq
    !>  [~.t 'bar']
    !>  (apply-scalar else-row scalar-to-apply)
::
::  test return cte-alias
::++  test-if-else-cte-alias-01
::  =/  if-expr
::    :*  %if-then-else
::      if=false-predicate
::      then=[else-q-col-1]
::      else=[else-q-col-2]
::    ==
::  =/  scalar-to-apply  (prepare-scalar if-expr else-named-ctes else-lookups)
::  %+  expect-eq
::    !>  1
::    !>  (apply-scalar else-row scalar-to-apply)
::
::  test return scalar-alias
::  fail scenario: no scalar with alias
++  test-if-else-scalar-alias-01
  =/  if-expr
    :*  %if-then-else
      if=false-predicate
      then=[else-q-col-2]
      else=[[%scalar-alias %scalar1]]
    ==
  =/  scalar-to-apply
    (prepare-scalar if-expr else-named-ctes else-lookups else-scalars)
  %+  expect-eq
    !>  [~.ud 3]
    !>  (apply-scalar else-row scalar-to-apply)
::
::  test return embedded scalar
::  fail scenario: no scalar with alias
++  test-if-else-embedded-scalar-01
  =/  if-expr
    :*  %if-then-else
      if=false-predicate
      then=[else-q-col-2]
      else=[(~(got by else-scalars) %scalar1)]
    ==
  =/  scalar-to-apply
    (prepare-scalar if-expr else-named-ctes else-lookups else-scalars)
  %+  expect-eq
    !>  [~.ud 3]
    !>  (apply-scalar else-row scalar-to-apply)
::
--
