/-  ast
/+  *scalars, *test, *server, *utils
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
::  make an unqualified-type-lookup
++  mk-unqualified-type-lookup
  |=  [kvp=(lest [@tas @ta])]
  :-  %unqualified-lookup-type
  (malt kvp)
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
++  qual-map-meta  %-  mk-qualified-map-meta
                          :~  :-  qualified-table-1
                                  %-  addr-columns  :~  [%column %col1 ~.ud 0]
                                                        [%column %col4 ~.ud 0]
                                                        ==
                              ==
::
++  unqual-map-meta  %-  mk-unqualified-typ-addr-lookup
                            %-  addr-columns  :~  [%column %col4 ~.ud 0]
                                                  ==
::
++  qualifier-lookup  %-  malt
                               %-  limo
                               :~
                                 [%col4 ~[qualified-table-1]]
                               ==
::
++  table-named-ctes        *named-ctes
::
++  table-row               %-  mk-indexed-row
                           :~
                             [%col1 1]
                             [%col4 4]
                           ==
::
++  table-scalars          %-  malt
                              %-  limo
                              :~
                                :-  %scalar1
                                :*  %if-then-else
                                  if=true-predicate
                                  then=[q-col-3]
                                  else=[q-col-2]
                                ==
                                :-  %scalar2
                                :*  %if-then-else
                                  if=true-predicate
                                  then=[literal-value-1]
                                  else=[literal-value-2]
                                ==
                              ==
::
::  table testing harness
+$  table-test-row  $:  datums=(list datum-or-scalar:ast)
                     expected=dime
                   ==
::
++  table-test-helper
  |=  [row=table-test-row]
  =/  coalesce-expr  [%scalar %my-scalar [%coalesce data=datums.row]]
  =/  scalar-to-apply
      %:  prepare-scalar  coalesce-expr
                          table-named-ctes
                          qualifier-lookup
                          qual-map-meta
                          table-scalars
                          ==
  %+  expect-eq
    !>  expected.row
    !>  (apply-scalar table-row scalar-to-apply)
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
::
:: coalesce tests
++  test-coalesce
  %-  run-tests
  :~
    :-  %qualified-column
    :*  ~[q-col-1]
      [~.ud 1]
    ==
    :-  %unqualified-column
    :*  ~[u-col-4]
      [~.ud 4]
    ==
    :-  %coalesce-3-q-unresolved-1-resolved-u
    :*  ~[q-col-2 q-col-3 q-col-2 u-col-4]
      [~.ud 4]
    ==
    :-  %unqualified-column
    :*  ~[u-col-5 u-col-6 u-col-5 q-col-1]
      [~.ud 1]
    ==
  ==
::
:: test what happens if no column matches
++  test-fail-coalesce-01
  ::
  =/  datums  ~[u-col-5 u-col-6 q-col-2 q-col-3]
  =/  coalesce-expr  [%scalar %my-scalar [%coalesce data=datums]]
  =/  scalar-to-apply  %:  prepare-scalar  coalesce-expr
                                           table-named-ctes
                                           qualifier-lookup
                                           qual-map-meta
                                           table-scalars
                                           ==
  %+  expect-fail-message
    'coalesce: couldn\'t resolve any column'
    |.  (apply-scalar table-row scalar-to-apply)
::
:: test with scalar-name
++  test-fail-coalesce-02
  ::
  =/  datums  ~[[%scalar-name %scalar1]]
  =/  coalesce-expr  [%scalar %my-scalar [%coalesce data=datums]]
  =/  scalar-to-apply  %:  prepare-scalar  coalesce-expr
                                           table-named-ctes
                                           qualifier-lookup
                                           qual-map-meta
                                           table-scalars
                                           ==
  %+  expect-fail-message
    'coalesce: can only use columns'
    |.  (apply-scalar table-row scalar-to-apply)
::
:: test with embedded scalar
++  test-fail-coalesce-03
  ::
  =/  datums  ~[(~(got by table-scalars) %scalar1)]
  =/  coalesce-expr  [%scalar %my-scalar [%coalesce data=datums]]
  =/  scalar-to-apply  %:  prepare-scalar  coalesce-expr
                                           table-named-ctes
                                           qualifier-lookup
                                           qual-map-meta
                                           table-scalars
                                           ==
  %+  expect-fail-message
    'coalesce: can only use columns'
    |.  (apply-scalar table-row scalar-to-apply)
::
:: test with literal-value
++  test-fail-coalesce-04
  ::
  =/  datums  ~[[%literal-value [~.ud 1]]]
  =/  coalesce-expr  [%scalar %my-scalar [%coalesce data=datums]]
  =/  scalar-to-apply  %:  prepare-scalar  coalesce-expr
                                           table-named-ctes
                                           qualifier-lookup
                                           qual-map-meta
                                           table-scalars
                                           ==
  %+  expect-fail-message
    'coalesce: can only use columns'
    |.  (apply-scalar table-row scalar-to-apply)
--
