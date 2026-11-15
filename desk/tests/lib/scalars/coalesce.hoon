/-  ast=obelisk-ast, *obelisk
/+  *scalars, *test, *main, *utils,  *test-helpers
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
::  make a CTE map-meta keyed by cte name + column name
++  mk-cte-map-meta
  |=  [cte=@tas columns=(list column:ast)]
  ^-  qualified-map-meta
  %+  roll  columns
  |=  [col=column:ast map-meta=qualified-map-meta]
  ^-  qualified-map-meta
  :-  %qualified-map-meta
  %^  ~(put bi:mip +.map-meta)
      [%cte-name cte ~]
      name.col
      [type.col addr.col]
::
::  wrap a single indexed row as a one-row CTE relation
++  mk-single-row-cte
  |=  [cte=@tas columns=(list column:ast) row=indexed-row]
  ^-  full-relation
  :*  %full-relation
      [%cte-name cte ~]
      :~  :*  %set-table
              join=~
              relation-id=~
              schema-tmsp=~
              data-tmsp=~
              columns=columns
              predicate=~
              rowcount=1
              :-  %unqualified-map-meta
                  (mk-unqualified-typ-addr-lookup columns)
              pri-indx=~
              ordered=%.n
              pri-indexed=*(tree [(list @) (map @tas @)])
              indexed-rows=~[row]
              joined-rows=~
              ==
      ==
      (mk-cte-map-meta cte columns)
      ~
      ==
::
++  q-col-1           [%qualified-column qualified-table-1 %col1 ~]
++  q-col-2           [%qualified-column qualified-table-1 %col2 ~]
++  q-col-3           [%qualified-column qualified-table-1 %col3 ~]
::
++  u-col-4           [%unqualified-column %col4 ~]
++  u-col-5           [%unqualified-column %col5 ~]
++  u-col-6           [%unqualified-column %col6 ~]
::
++  qual-map-meta  %-  mk-qualified-map-meta
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
++  qual-lookup  %-  malt
                 %-  limo
                 :~  [%col4 ~[qualified-table-1]]
                     [%col5 ~[qualified-table-1]]
                     [%col6 ~[qualified-table-1]]
                     ==
::
++  co-cte-columns  (addr-columns ~[[%column %value ~.ud 0]])
++  co-cte-row      (mk-indexed-row ~[[%value 7]])
++  co-cte-value    [%cte-column %co-cte %value]
::
++  table-named-ctes
  %-  malt
  %-  limo
  :~  [%co-cte (mk-single-row-cte %co-cte co-cte-columns co-cte-row)]
      ==
::
++  table-row               %-  mk-indexed-row
                            :~  [%col1 1]
                                [%col2 2]
                                [%col3 3]
                                [%col4 4]
                                [%col5 5]
                                [%col6 6]
                                ==
::
::  scalar1 is a constant, scalar2 reads a column
++  resolved-scalars
  ^-  (map @tas resolved-scalar)
  %-  malt  %-  limo  :~  :-  %scalar1
                              =<  +
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
                                    (bowl [0 ~2026.4.21])
                                    eny:(bowl [0 ~2026.4.21])
                                    ==
                          :-  %scalar2
                              =<  +
                              %:  prepare-scalar
                                    ^-  scalar-function:ast
                                    :*  %if-then-else
                                      if=true-predicate
                                      then=q-col-3
                                      else=q-col-2
                                    ==
                                    table-named-ctes
                                    qual-lookup
                                    qual-map-meta
                                    *(map @tas resolved-scalar)
                                    (bowl [0 ~2026.4.21])
                                    eny:(bowl [0 ~2026.4.21])
                                    ==
                          ==
::
::  prepare COALESCE of datums, expecting a crash
++  fail-coalesce
  |=  [msg=@t data=(list scalar-node:ast)]
  ^-  tang
  %+  expect-fail-message
    msg
    |.  %:  prepare-scalar
              ^-  scalar-function:ast
              [%coalesce data]
              table-named-ctes
              qual-lookup
              qual-map-meta
              resolved-scalars
              (bowl [0 ~2026.4.21])
              eny:(bowl [0 ~2026.4.21])
              ==
::
::  ::::::::::::::::::::::::
::  :::: COALESCE TESTS ::::
::  ::::::::::::::::::::::::
::
::  Every datum of a row is present here: COALESCE returns its first
::  argument.  Arguments absent from a row type are pruned before COALESCE
::  is prepared (+prune-scalar-node in lib/crud), so existence is tested
::  by the outer join tests in tests/lib/queries.
::
::  columns
++  test-coalesce-00
  %:  run-scalar-tests
    table-named-ctes
    qual-lookup
    qual-map-meta
    resolved-scalars
    table-row
    :~
    :-  %one-qualified-column
        :-  [%coalesce ~[q-col-1]]
            [~.ud 1]
    :-  %one-unqualified-column
        :-  [%coalesce ~[u-col-4]]
            [~.ud 4]
    :-  %qualified-columns
        :-  [%coalesce ~[q-col-2 q-col-3 q-col-1]]
            [~.ud 2]
    :-  %unqualified-columns
        :-  [%coalesce ~[u-col-6 u-col-5 u-col-4]]
            [~.ud 6]
    :-  %unqualified-then-qualified
        :-  [%coalesce ~[u-col-5 q-col-1]]
            [~.ud 5]
    :-  %qualified-then-unqualified
        :-  [%coalesce ~[q-col-3 u-col-4]]
            [~.ud 3]
    :-  %repeated-column
        :-  [%coalesce ~[q-col-2 q-col-2]]
            [~.ud 2]
  ==
  ==
::
::  literals
++  test-coalesce-01
  %:  run-scalar-tests
    table-named-ctes
    qual-lookup
    qual-map-meta
    resolved-scalars
    table-row
    :~
    :-  %one-literal
        :-  [%coalesce ~[literal-1]]
            [~.ud 1]
    :-  %literal-then-column
        :-  [%coalesce ~[literal-2 q-col-1]]
            [~.ud 2]
    :-  %column-then-literal
        :-  [%coalesce ~[q-col-3 literal-1]]
            [~.ud 3]
    :-  %literals
        :-  [%coalesce ~[literal-2 literal-1]]
            [~.ud 2]
    :-  %cord-literal
        :-  [%coalesce ~[[~.t 'abc'] [~.t 'def']]]
            [~.t 'abc']
  ==
  ==
::
::  scalar names, CTE columns, and nested scalar functions
++  test-coalesce-02
  %:  run-scalar-tests
    table-named-ctes
    qual-lookup
    qual-map-meta
    resolved-scalars
    table-row
    :~
    :-  %constant-scalar-name
        :-  [%coalesce ~[[%scalar-name %scalar1] q-col-1]]
            [~.ud 3]
    :-  %column-scalar-name
        :-  [%coalesce ~[[%scalar-name %scalar2] q-col-1]]
            [~.ud 3]
    :-  %column-then-scalar-name
        :-  [%coalesce ~[q-col-1 [%scalar-name %scalar1]]]
            [~.ud 1]
    :-  %cte-column
        :-  [%coalesce ~[co-cte-value q-col-1]]
            [~.ud 7]
    :-  %column-then-cte-column
        :-  [%coalesce ~[q-col-2 co-cte-value]]
            [~.ud 2]
    :-  %nested-coalesce
        :-  [%coalesce ~[[%coalesce ~[q-col-3 q-col-1]] q-col-2]]
            [~.ud 3]
    :-  %nested-if
        :-  :-  %coalesce
                :~  [%if-then-else false-predicate q-col-1 u-col-5]
                    q-col-2
                    ==
            [~.ud 5]
  ==
  ==
::
++  test-fail-coalesce-00
  %+  fail-coalesce  'check-consistent-types: empty argument list'
                     ~
::
++  test-fail-coalesce-01
  %+  fail-coalesce  'check-consistent-types: inconsistent types'
                     ~[q-col-1 [~.t 'abc']]
::
++  test-fail-coalesce-02
  %+  fail-coalesce  'check-consistent-types: inconsistent types'
                     ~[[~.t 'abc'] u-col-4]
::
++  test-fail-coalesce-03
  %+  fail-coalesce  'scalar %nope not found'
                     ~[[%scalar-name %nope] q-col-1]
::
++  test-fail-coalesce-04
  =/  empty-lookup
    ^-  qualifier-lookup
    (malt (limo ~[[%col4 `(list qualified-table)`~]]))
  %+  expect-fail-message
    'no table!'
    |.  %:  prepare-scalar
              ^-  scalar-function:ast
              [%coalesce ~[u-col-4 q-col-1]]
              table-named-ctes
              empty-lookup
              qual-map-meta
              resolved-scalars
              (bowl [0 ~2026.4.21])
              eny:(bowl [0 ~2026.4.21])
              ==
--
