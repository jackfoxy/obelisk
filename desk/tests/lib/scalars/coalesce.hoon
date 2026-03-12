/-  ast, *obelisk
/+  *scalars, *test, *server, *utils,  *test-helpers
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
++  literal-value-1             literal-1
++  literal-value-2             literal-2
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
  :-  %unqualified-map-meta
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
++  unqual-map-meta  :-  %unqualified-map-meta
                         %-  mk-unqualified-typ-addr-lookup
                             %-  addr-columns  :~  [%column %col1 ~.ud 0]
                                                   [%column %col4 ~.ud 0]
                                                   ==
::
++  qual-lookup  %-  malt
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
++  resolved-scalars
  ^-  (map @tas resolved-scalar)
  %-  malt  %-  limo  :~  :-  %scalar1
                              %:  prepare-scalar
                                    ^-  scalar-function:ast
                                    :*  %if-then-else
                                      if=true-predicate
                                      then=[~.ud 3]
                                      else=[~.ud 2]
                                    ==
                                    table-named-ctes
                                    qual-lookup
                                    qual-map-meta
                                    *(map @tas resolved-scalar)
                                    ==
                          :-  %scalar2
                              %:  prepare-scalar
                                    ^-  scalar-function:ast
                                    :*  %if-then-else
                                      if=true-predicate
                                      then=literal-value-1
                                      else=literal-value-2
                                    ==
                                    table-named-ctes
                                    qual-lookup
                                    qual-map-meta
                                    *(map @tas resolved-scalar)
                                    ==
                          ==
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
  %:  run-scalar-tests
    table-named-ctes
    qual-lookup
    qual-map-meta
    resolved-scalars
    table-row
    :~
    :-  %qualified-column
    :-  [%coalesce ~[q-col-1]]
      [~.ud 1]
    :::::-  %unqualified-column
    :::::*  ~[u-col-4]
    ::::  [~.ud 4]
    ::::==
    :::::-  %coalesce-3-q-unresolved-1-resolved-u
    :::::*  ~[q-col-2 q-col-3 q-col-2 u-col-4]
    ::::  [~.ud 4]
    ::::==
    :::::-  %unqualified-column
    :::::*  ~[u-col-5 u-col-6 u-col-5 q-col-1]
    ::::  [~.ud 1]
    ::::==
  ==
  ==
::::::
:::::: test what happens if no column matches
::::++  test-fail-coalesce-01
::::  ::
::::  =/  datums  ~[u-col-5 u-col-6 q-col-2 q-col-3]
::::  =/  coalesce-expr  [%coalesce data=datums]
::::  =/  scalar-to-apply  %:  prepare-scalar  coalesce-expr
::::                                           table-named-ctes
::::                                           qual-lookup
::::                                           qual-map-meta
::::                                           *(map @tas resolved-scalar)  ::
::::                                           ==
::::  %+  expect-fail-message
::::    'coalesce: couldn\'t resolve any column'
::::    |.  (apply-scalar table-row scalar-to-apply)
::::::
:::::: test with scalar-name
::::++  test-fail-coalesce-02
::::  ::
::::  =/  datums  ~[[%scalar-name %scalar1]]
::::  =/  coalesce-expr  [%coalesce data=datums]
::::  =/  scalar-to-apply  %:  prepare-scalar  coalesce-expr
::::                                           table-named-ctes
::::                                           qual-lookup
::::                                           qual-map-meta
::::                                           table-scalars
::::                                           ==
::::  %+  expect-fail-message
::::    'coalesce: can only use columns'
::::    |.  (apply-scalar table-row scalar-to-apply)
::::::
:::::: test with embedded scalar
::::++  test-fail-coalesce-03
::::  ::
::::  =/  datums  ~[(~(got by table-scalars) %scalar1)]
::::  =/  coalesce-expr  [%coalesce data=datums]
::::  =/  scalar-to-apply  %:  prepare-scalar  coalesce-expr
::::                                           table-named-ctes
::::                                           qual-lookup
::::                                           qual-map-meta
::::                                           table-scalars
::::                                           ==
::::  %+  expect-fail-message
::::    'coalesce: can only use columns'
::::    |.  (apply-scalar table-row scalar-to-apply)
::::::
:::::: test with literal-value
::::++  test-fail-coalesce-04
::::  ::
::::  =/  datums  ~[[~.ud 1]]
::::  =/  coalesce-expr  [%coalesce data=datums]
::::  =/  scalar-to-apply  %:  prepare-scalar  coalesce-expr
::::                                           table-named-ctes
::::                                           qual-lookup
::::                                           qual-map-meta
::::                                           table-scalars
::::                                           ==
::::  %+  expect-fail-message
::::    'coalesce: can only use columns'
::::    |.  (apply-scalar table-row scalar-to-apply)
--
