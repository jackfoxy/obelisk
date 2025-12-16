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
++  true-predicate         [n=%eq [n=literal-1 ~ ~] [n=literal-1 ~ ~]]
++  false-predicate         [n=%eq [n=literal-1 ~ ~] [n=[~.ud 0] ~ ~]]
::
++  literal-value-1             [%literal-value literal-1]
++  literal-value-2             [%literal-value literal-2]
::
++  literal-1             [~.ud 1]
++  literal-2             [~.ud 2]
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
::  table testing harness
+$  table-test-row  $:  datum=datum-or-scalar:ast
                     expected=dime
                   ==
::
++  table-test-helper
  |=  [row=table-test-row]
  =/  when-lookups  [when-qualifier-lookup when-qual-type-lookup]
  =/  case-expr=coalesce:ast  [%coalesce data=~[datum.row]]
  =/  scalar-to-apply
    (prepare-scalar case-expr when-named-ctes when-lookups when-scalars)
  %+  expect-eq
    !>  expected.row
    !>  (apply-scalar when-row scalar-to-apply)
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
::  - DONE:             %eq %neq %gte %gt %lte %lt %in %not-in %between
::                      %not-between %and %or 
::  - MISSING:          
::  - ???:              %not (doesn't work for qualified/unqualified col)
::  - NOT IMPLEMENTED:  %equiv %not-equiv %exists %not-%exists %all %any
::

::  ::::::::::::::::::::::::
::  :::: COALESCE TESTS ::::
::  ::::::::::::::::::::::::
::
::  set up some costant context for tests
::
++  q-col-1           [%qualified-column qualified-table-1 %col1 ~]
++  q-col-2           [%qualified-column qualified-table-1 %col2 ~]
++  q-col-3           [%qualified-column qualified-table-1 %col3 ~]
++  q-col-4           [%qualified-column qualified-table-1 %other-col4 ~]
::
++  u-col-4           [%unqualified-column %col4 ~]
++  u-col-5           [%unqualified-column %col5 ~]
++  u-col-6           [%unqualified-column %col6 ~]
::
++  qual-type-lookup       %-  mk-qualified-type-lookup
                                :~
                                  :-  qualified-table-1
                                  :~
                                    [%col1 ~.ud]
                                    [%col2 ~.ud]
                                    [%col3 ~.ud]
                                    [%col4 ~.ud]
                                    [%other-col4 ~.ud]
                                    [%col5 ~.ud]
                                    [%col6 ~.ud]
                                    [%col7 ~.ud]
                                  ==
                                ==
::
++  unqual-type-lookup       %-  mk-unqualified-type-lookup
                                  :~
                                    [%col4 ~.ud]
                                    [%col5 ~.ud]
                                    [%col6 ~.ud]
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
++  named-ctes        *named-ctes
::
++  row               %-  mk-indexed-row
                           :~
                             [%col1 1]
                             [%col2 2]
                             [%col3 3]
                             [%col4 4]
                             [%other-col4 4]
                             [%col5 5]
                             [%col6 6]
                           ==
::
++  scalars           %-  malt
                           %-  limo
                           :~
                             :-  %scalar1
                             :*  %if-then-else
                               if=true-predicate
                               then=[when-q-col-3]
                               else=[when-q-col-2]
                             ==
                             :-  %scalar2
                             :*  %if-then-else
                               if=true-predicate
                               then=[when-u-col-4]
                               else=[when-u-col-5]
                             ==
                           ==
::
:: coalesce tests
++  test-if-predicate-eq
  %-  run-tests
  :~
    :-  %eq-dimes
    :*  
      pred-q-col-2
      [~.ud 1]
    ==
  ==
--
