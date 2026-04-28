/-  ast, *obelisk
/+  *scalars,  *test,  *main,  *test-helpers
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
++  literal-zod            [p=%p q=0]
++  literal-1              [p=~.ud q=1]
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
              relation=~
              schema-tmsp=~
              data-tmsp=~
              columns=columns
              predicate=~
              rowcount=1
              map-meta=[%unqualified-map-meta (mk-unqualified-typ-addr-lookup columns)]
              pri-indx=~
              pri-indexed=*(tree [(list @) (map @tas @)])
              indexed-rows=~[row]
              joined-rows=~
              ==
      ==
      (mk-cte-map-meta cte columns)
      ~
      ==
::
++  q-col-1             [%qualified-column qualified-table-1 %col1 ~]
++  q-col-2             [%qualified-column qualified-table-1 %col2 ~]
++  q-col-3             [%qualified-column qualified-table-1 %col3 ~]
::
++  u-col-4             [%unqualified-column %col4 ~]
++  u-col-5             [%unqualified-column %col5 ~]
++  u-col-6             [%unqualified-column %col6 ~]
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
++  unqual-map-meta  :-  %unqualified-map-meta
                         %-  mk-unqualified-typ-addr-lookup
                             %-  addr-columns
                                  :~  [%column %col1 ~.ud 0]
                                      [%column %col2 ~.ud 0]
                                      [%column %col3 ~.ud 0]
                                      [%column %col4 ~.ud 0]
                                      [%column %col5 ~.ud 0]
                                      [%column %col6 ~.ud 0]
                                      ==
::
++  qual-lookup  %-  malt
                           %-  limo
                           :~
                             [%col4 ~[qualified-table-1]]
                             [%col5 ~[qualified-table-1]]
                             [%col6 ~[qualified-table-1]]
                           ==
::
++  if-cte-columns
  %-  addr-columns
  :~  [%column %value ~.ud 0]
      ==
::
++  if-cte-row
  %-  mk-indexed-row
  :~  [%value 3]
      ==
::
++  if-cte-value  [%cte-column %if-cte %value]
::
++  table-named-ctes
  %-  malt
  %-  limo
  :~  [%if-cte (mk-single-row-cte %if-cte if-cte-columns if-cte-row)]
  ==
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
++  resolved-scalars
  ^-  (map @tas resolved-scalar)
  %-  malt  %-  limo  :~  :-  %scalar1
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
++  test-qual-if-predicate-eq
  %:  run-scalar-tests
    table-named-ctes
    qual-lookup
    qual-map-meta
    resolved-scalars
    table-row
    :~
    :-  %eq-dimes
        :-  [%if-then-else [%eq [[~.ud 1] ~ ~] [[~.ud 1] ~ ~]] q-col-1 q-col-2]
            [~.ud 1]
    :-  %eq-qualified-columns
        :-  [%if-then-else [%eq [q-col-1 ~ ~] [q-col-2 ~ ~]] q-col-1 q-col-2]
            [~.ud 2]
    :-  %eq-qualified-column-and-dime
        :-  [%if-then-else [%eq [q-col-1 ~ ~] [[~.ud 1] ~ ~]] q-col-1 q-col-2]
            [~.ud 1]
    :-  %eq-dime-and-qualified-column
        :-  [%if-then-else [%eq [[~.ud 1] ~ ~] [q-col-1 ~ ~]] q-col-1 q-col-2]
            [~.ud 1]
  ==
  ==
::
::  %neq tests
++  test-qual-if-predicate-neq
  %:  run-scalar-tests
    table-named-ctes
    qual-lookup
    qual-map-meta
    resolved-scalars
    table-row
    :~
    :-  %neq-dimes
        :-  [%if-then-else [%neq [[~.ud 1] ~ ~] [[~.ud 1] ~ ~]] q-col-1 q-col-2]
            [~.ud 2]
    :-  %neq-qualified-columns
        :-  [%if-then-else [%neq [q-col-1 ~ ~] [q-col-2 ~ ~]] q-col-1 q-col-2]
            [~.ud 1]
    :-  %neq-qualified-column-and-dime
        :-  [%if-then-else [%neq [q-col-1 ~ ~] [[~.ud 1] ~ ~]] q-col-1 q-col-2]
            [~.ud 2]
    :-  %neq-dime-and-qualified-column
        :-  [%if-then-else [%neq [[~.ud 1] ~ ~] [q-col-1 ~ ~]] q-col-1 q-col-2]
            [~.ud 2]
  ==
  ==
::
::  %gte tests
++  test-qual-if-predicate-gte
  %:  run-scalar-tests
    table-named-ctes
    qual-lookup
    qual-map-meta
    resolved-scalars
    table-row
    :~
    :-  %gte-dimes-gt
        :-  [%if-then-else [%gte [[~.ud 2] ~ ~] [[~.ud 1] ~ ~]] q-col-1 q-col-2]
            [~.ud 1]
    :-  %gte-dimes-eq
        :-  [%if-then-else [%gte [[~.ud 1] ~ ~] [[~.ud 1] ~ ~]] q-col-1 q-col-2]
            [~.ud 1]
    :-  %gte-dimes-false
        :-  [%if-then-else [%gte [[~.ud 1] ~ ~] [[~.ud 2] ~ ~]] q-col-1 q-col-2]
            [~.ud 2]
    :-  %gte-qualified-columns-gt
        :-  [%if-then-else [%gte [q-col-2 ~ ~] [q-col-1 ~ ~]] q-col-1 q-col-2]
            [~.ud 1]
    :-  %gte-qualified-columns-eq
        :-  [%if-then-else [%gte [q-col-1 ~ ~] [q-col-1 ~ ~]] q-col-1 q-col-2]
            [~.ud 1]
    :-  %gte-qualified-columns-false
        :-  [%if-then-else [%gte [q-col-1 ~ ~] [q-col-2 ~ ~]] q-col-1 q-col-2]
            [~.ud 2]
    :-  %gte-qualified-column-and-dime-gt
        :-  [%if-then-else [%gte [q-col-2 ~ ~] [[~.ud 1] ~ ~]] q-col-1 q-col-2]
            [~.ud 1]
    :-  %gte-qualified-column-and-dime-eq
        :-  [%if-then-else [%gte [q-col-1 ~ ~] [[~.ud 1] ~ ~]] q-col-1 q-col-2]
            [~.ud 1]
    :-  %gte-qualified-column-and-dime-false
        :-  [%if-then-else [%gte [q-col-1 ~ ~] [[~.ud 2] ~ ~]] q-col-1 q-col-2]
            [~.ud 2]
    :-  %gte-dime-and-qualified-column-gt
        :-  [%if-then-else [%gte [[~.ud 2] ~ ~] [q-col-1 ~ ~]] q-col-1 q-col-2]
            [~.ud 1]
    :-  %gte-dime-and-qualified-column-eq
        :-  [%if-then-else [%gte [[~.ud 1] ~ ~] [q-col-1 ~ ~]] q-col-1 q-col-2]
            [~.ud 1]
    :-  %gte-dime-and-qualified-column-false
        :-  [%if-then-else [%gte [[~.ud 1] ~ ~] [q-col-2 ~ ~]] q-col-1 q-col-2]
            [~.ud 2]
  ==
  ==
::
::  %gt tests
++  test-qual-if-predicate-gt
  %:  run-scalar-tests
    table-named-ctes
    qual-lookup
    qual-map-meta
    resolved-scalars
    table-row
    :~
    :-  %gt-dimes-gt
        :-  [%if-then-else [%gt [[~.ud 2] ~ ~] [[~.ud 1] ~ ~]] q-col-1 q-col-2]
            [~.ud 1]
    :-  %gt-dimes-false
        :-  [%if-then-else [%gt [[~.ud 1] ~ ~] [[~.ud 2] ~ ~]] q-col-1 q-col-2]
            [~.ud 2]
    :-  %gt-qualified-columns-gt
        :-  [%if-then-else [%gt [q-col-2 ~ ~] [q-col-1 ~ ~]] q-col-1 q-col-2]
            [~.ud 1]
    :-  %gt-qualified-columns-false
        :-  [%if-then-else [%gt [q-col-1 ~ ~] [q-col-2 ~ ~]] q-col-1 q-col-2]
            [~.ud 2]
    :-  %gt-qualified-column-and-dime-gt
        :-  [%if-then-else [%gt [q-col-2 ~ ~] [[~.ud 1] ~ ~]] q-col-1 q-col-2]
            [~.ud 1]
    :-  %gt-qualified-column-and-dime-false
        :-  [%if-then-else [%gt [q-col-1 ~ ~] [[~.ud 2] ~ ~]] q-col-1 q-col-2]
            [~.ud 2]
    :-  %gt-dime-and-qualified-column-gt
        :-  [%if-then-else [%gt [[~.ud 2] ~ ~] [q-col-1 ~ ~]] q-col-1 q-col-2]
            [~.ud 1]
    :-  %gt-dime-and-qualified-column-false
        :-  [%if-then-else [%gt [[~.ud 1] ~ ~] [q-col-2 ~ ~]] q-col-1 q-col-2]
            [~.ud 2]
  ==
  ==
::
::  %lte tests
++  test-qual-if-predicate-lte
  %:  run-scalar-tests
    table-named-ctes
    qual-lookup
    qual-map-meta
    resolved-scalars
    table-row
    :~
    :-  %lte-dimes-lt
        :-  [%if-then-else [%lte [[~.ud 1] ~ ~] [[~.ud 2] ~ ~]] q-col-1 q-col-2]
            [~.ud 1]
    :-  %lte-dimes-eq
        :-  [%if-then-else [%lte [[~.ud 1] ~ ~] [[~.ud 1] ~ ~]] q-col-1 q-col-2]
            [~.ud 1]
    :-  %lte-dimes-false
        :-  [%if-then-else [%lte [[~.ud 2] ~ ~] [[~.ud 1] ~ ~]] q-col-1 q-col-2]
            [~.ud 2]
    :-  %lte-qualified-columns-lt
        :-  [%if-then-else [%lte [q-col-1 ~ ~] [q-col-2 ~ ~]] q-col-1 q-col-2]
            [~.ud 1]
    :-  %lte-qualified-columns-eq
        :-  [%if-then-else [%lte [q-col-1 ~ ~] [q-col-1 ~ ~]] q-col-1 q-col-2]
            [~.ud 1]
    :-  %lte-qualified-columns-false
        :-  [%if-then-else [%lte [q-col-2 ~ ~] [q-col-1 ~ ~]] q-col-1 q-col-2]
            [~.ud 2]
    :-  %lte-qualified-column-and-dime-lt
        :-  [%if-then-else [%lte [q-col-1 ~ ~] [[~.ud 2] ~ ~]] q-col-1 q-col-2]
            [~.ud 1]
    :-  %lte-qualified-column-and-dime-eq
        :-  [%if-then-else [%lte [q-col-1 ~ ~] [[~.ud 1] ~ ~]] q-col-1 q-col-2]
            [~.ud 1]
    :-  %lte-qualified-column-and-dime-false
        :-  [%if-then-else [%lte [q-col-2 ~ ~] [[~.ud 1] ~ ~]] q-col-1 q-col-2]
            [~.ud 2]
    :-  %lte-dime-and-qualified-column-lt
        :-  [%if-then-else [%lte [[~.ud 1] ~ ~] [q-col-2 ~ ~]] q-col-1 q-col-2]
            [~.ud 1]
    :-  %lte-dime-and-qualified-column-eq
        :-  [%if-then-else [%lte [[~.ud 1] ~ ~] [q-col-1 ~ ~]] q-col-1 q-col-2]
            [~.ud 1]
    :-  %lte-dime-and-qualified-column-false
        :-  [%if-then-else [%lte [[~.ud 2] ~ ~] [q-col-1 ~ ~]] q-col-1 q-col-2]
            [~.ud 2]
  ==
  ==
::
::  %lt tests
++  test-qual-if-predicate-lt
  %:  run-scalar-tests
    table-named-ctes
    qual-lookup
    qual-map-meta
    resolved-scalars
    table-row
    :~
    :-  %lt-dimes-lt
        :-  [%if-then-else [%lt [[~.ud 1] ~ ~] [[~.ud 2] ~ ~]] q-col-1 q-col-2]
            [~.ud 1]
    :-  %lt-dimes-false
        :-  [%if-then-else [%lt [[~.ud 2] ~ ~] [[~.ud 1] ~ ~]] q-col-1 q-col-2]
            [~.ud 2]
    :-  %lt-qualified-columns-lt
        :-  [%if-then-else [%lt [q-col-1 ~ ~] [q-col-2 ~ ~]] q-col-1 q-col-2]
            [~.ud 1]
    :-  %lt-qualified-columns-false
        :-  [%if-then-else [%lt [q-col-2 ~ ~] [q-col-1 ~ ~]] q-col-1 q-col-2]
            [~.ud 2]
    :-  %lt-qualified-column-and-dime-lt
        :-  [%if-then-else [%lt [q-col-1 ~ ~] [[~.ud 2] ~ ~]] q-col-1 q-col-2]
            [~.ud 1]
    :-  %lt-qualified-column-and-dime-false
        :-  [%if-then-else [%lt [q-col-2 ~ ~] [[~.ud 1] ~ ~]] q-col-1 q-col-2]
            [~.ud 2]
    :-  %lt-dime-and-qualified-column-lt
        :-  [%if-then-else [%lt [[~.ud 1] ~ ~] [q-col-2 ~ ~]] q-col-1 q-col-2]
            [~.ud 1]
    :-  %lt-dime-and-qualified-column-false
        :-  [%if-then-else [%lt [[~.ud 2] ~ ~] [q-col-1 ~ ~]] q-col-1 q-col-2]
            [~.ud 2]
  ==
  ==
::
::  %in tests
++  test-qual-if-predicate-in
  %:  run-scalar-tests
    table-named-ctes
    qual-lookup
    qual-map-meta
    resolved-scalars
    table-row
    :~
    :-  %in-dime
        :-  [%if-then-else [%in [[~.ud 1] ~ ~] [[%value-literals [~.ud '1;2;4;5']] ~ ~]] q-col-1 q-col-2]
            [~.ud 1]
    :-  %in-dime-false
        :-  [%if-then-else [%in [[~.ud 3] ~ ~] [[%value-literals [~.ud '1;2;4;5']] ~ ~]] q-col-1 q-col-2]
            [~.ud 2]
    :-  %in-qualified-column
        :-  [%if-then-else [%in [q-col-1 ~ ~] [[%value-literals [~.ud '1;2;4;5']] ~ ~]] q-col-1 q-col-2]
            [~.ud 1]
    :-  %in-qualified-column-false
        :-  [%if-then-else [%in [q-col-3 ~ ~] [[%value-literals [~.ud '1;2;4;5']] ~ ~]] q-col-1 q-col-2]
            [~.ud 2]
  ==
  ==
::
::  %not-in tests
++  test-qual-if-predicate-not-in
  %:  run-scalar-tests
    table-named-ctes
    qual-lookup
    qual-map-meta
    resolved-scalars
    table-row
    :~
    :-  %not-in-dime
        :-  [%if-then-else [%not-in [[~.ud 3] ~ ~] [[%value-literals [~.ud '1;2;4;5']] ~ ~]] q-col-1 q-col-2]
            [~.ud 1]
    :-  %not-in-dime-false
        :-  [%if-then-else [%not-in [[~.ud 1] ~ ~] [[%value-literals [~.ud '1;2;4;5']] ~ ~]] q-col-1 q-col-2]
            [~.ud 2]
    :-  %not-in-qualified-column
        :-  [%if-then-else [%not-in [q-col-3 ~ ~] [[%value-literals [~.ud '1;2;4;5']] ~ ~]] q-col-1 q-col-2]
            [~.ud 1]
    :-  %not-in-qualified-column-false
        :-  [%if-then-else [%not-in [q-col-1 ~ ~] [[%value-literals [~.ud '1;2;4;5']] ~ ~]] q-col-1 q-col-2]
            [~.ud 2]
  ==
  ==
::
::  %between tests
++  test-qual-if-predicate-between
  =/  mk-between-pred
    |*  [val-to-test=* lower-bound=* upper-bound=*]
    :+  %between
      [%gte [val-to-test ~ ~] [lower-bound ~ ~]]
    [%lte [val-to-test ~ ~] [upper-bound ~ ~]]
  %:  run-scalar-tests
    table-named-ctes
    qual-lookup
    qual-map-meta
    resolved-scalars
    table-row
    :~
    :-  %between-dime-dimes
        :-  :*  %if-then-else
              (mk-between-pred [~.ud 2] [~.ud 1] [~.ud 3])
              q-col-1
              q-col-2
              ==
            [~.ud 1]
    :-  %between-qualified-column-qualified-columns
        :-  :*  %if-then-else
              (mk-between-pred q-col-2 q-col-1 q-col-3)
              q-col-1
              q-col-2
              ==
            [~.ud 1]
    :-  %between-qualified-column-dime-and-qualified-column
        :-  :*  %if-then-else
              (mk-between-pred q-col-2 [~.ud 1] q-col-3)
              q-col-1
              q-col-2
              ==
            [~.ud 1]
    :-  %between-qualified-column-qualified-column-and-dime
        :-  :*  %if-then-else
              (mk-between-pred q-col-2 q-col-1 [~.ud 3])
              q-col-1
              q-col-2
              ==
            [~.ud 1]
    :-  %between-qualified-column-dimes
        :-  :*  %if-then-else
              (mk-between-pred q-col-2 [~.ud 1] [~.ud 3])
              q-col-1
              q-col-2
              ==
            [~.ud 1]
    :-  %between-dime-dimes-false
        :-  :*  %if-then-else
              (mk-between-pred [~.ud 5] [~.ud 1] [~.ud 3])
              q-col-1
              q-col-2
              ==
            [~.ud 2]
    :-  %between-qualified-column-dimes-false
        :-  :*  %if-then-else
              (mk-between-pred q-col-1 [~.ud 2] [~.ud 4])
              q-col-1
              q-col-2
              ==
            [~.ud 2]
  ==
  ==
::
::  %not-between tests
++  test-qual-if-predicate-not-between
  =/  mk-not-between-pred
    |*  [val-to-test=* lower-bound=* upper-bound=*]
    :+  %not-between
      [%gte [val-to-test ~ ~] [lower-bound ~ ~]]
    [%lte [val-to-test ~ ~] [upper-bound ~ ~]]
  %:  run-scalar-tests
    table-named-ctes
    qual-lookup
    qual-map-meta
    resolved-scalars
    table-row
    :~
    :-  %not-between-dime-dimes
        :-  :*  %if-then-else
              (mk-not-between-pred [~.ud 5] [~.ud 1] [~.ud 3])
              q-col-1
              q-col-2
              ==
            [~.ud 1]
    :-  %not-between-qualified-column-qualified-columns
        :-  :*  %if-then-else
              (mk-not-between-pred q-col-1 q-col-2 q-col-3)
              q-col-1
              q-col-2
              ==
            [~.ud 1]
    :-  %not-between-qualified-column-dime-and-qualified-column
        :-  :*  %if-then-else
              (mk-not-between-pred q-col-1 [~.ud 2] q-col-3)
              q-col-1
              q-col-2
              ==
            [~.ud 1]
    :-  %not-between-qualified-column-qualified-column-and-dime
        :-  :*  %if-then-else
              (mk-not-between-pred q-col-1 q-col-2 [~.ud 3])
              q-col-1
              q-col-2
              ==
            [~.ud 1]
    :-  %not-between-qualified-column-dimes
        :-  :*  %if-then-else
              (mk-not-between-pred q-col-1 [~.ud 2] [~.ud 4])
              q-col-1
              q-col-2
              ==
            [~.ud 1]
    :-  %not-between-dime-dimes-false
        :-  :*  %if-then-else
              (mk-not-between-pred [~.ud 2] [~.ud 1] [~.ud 3])
              q-col-1
              q-col-2
              ==
            [~.ud 2]
    :-  %not-between-qualified-column-dimes-false
        :-  :*  %if-then-else
              (mk-not-between-pred q-col-2 [~.ud 1] [~.ud 3])
              q-col-1
              q-col-2
              ==
            [~.ud 2]
  ==
  ==
::
::  %and tests
++  test-qual-if-predicate-and
  %:  run-scalar-tests
    table-named-ctes
    qual-lookup
    qual-map-meta
    resolved-scalars
    table-row
    :~
    :-  %and-true
        :-  :*  %if-then-else
              :+  %and
                [%eq [[~.ud 1] ~ ~] [[~.ud 1] ~ ~]]
              [%eq [[~.ud 1] ~ ~] [[~.ud 1] ~ ~]]
              q-col-1
              q-col-2
              ==
            [~.ud 1]
    :-  %and-false
        :-  :*  %if-then-else
              :+  %and
                [%eq [[~.ud 1] ~ ~] [[~.ud 1] ~ ~]]
              [%eq [[~.ud 0] ~ ~] [[~.ud 1] ~ ~]]
              q-col-1
              q-col-2
              ==
            [~.ud 2]
  ==
  ==
::
::  %or tests
++  test-qual-if-predicate-or
  %:  run-scalar-tests
    table-named-ctes
    qual-lookup
    qual-map-meta
    resolved-scalars
    table-row
    :~
    :-  %or-true-true
        :-  :*  %if-then-else
              :+  %or
                [%eq [[~.ud 1] ~ ~] [[~.ud 1] ~ ~]]
              [%eq [[~.ud 1] ~ ~] [[~.ud 1] ~ ~]]
              q-col-1
              q-col-2
              ==
            [~.ud 1]
    :-  %or-true-false
        :-  :*  %if-then-else
              :+  %or
                [%eq [[~.ud 0] ~ ~] [[~.ud 1] ~ ~]]
              [%eq [[~.ud 1] ~ ~] [[~.ud 1] ~ ~]]
              q-col-1
              q-col-2
              ==
            [~.ud 1]
    :-  %or-false-false
        :-  :*  %if-then-else
              :+  %or
                [%eq [[~.ud 0] ~ ~] [[~.ud 1] ~ ~]]
              [%eq [[~.ud 0] ~ ~] [[~.ud 1] ~ ~]]
              q-col-1
              q-col-2
              ==
            [~.ud 2]
  ==
  ==
::
::  %not tests
++  test-qual-if-predicate-not
  %:  run-scalar-tests
    table-named-ctes
    qual-lookup
    qual-map-meta
    resolved-scalars
    table-row
    :~
    :-  %not-true-expression
        :-  [%if-then-else [%not [%eq [[~.ud 1] ~ ~] [[~.ud 1] ~ ~]] ~] q-col-1 q-col-2]
            [~.ud 2]
    :-  %not-false-expression
        :-  [%if-then-else [%not [%eq [[~.ud 0] ~ ~] [[~.ud 1] ~ ~]] ~] q-col-1 q-col-2]
            [~.ud 1]
  ==
  ==
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
++  test-qual-if-then
  %:  run-scalar-tests
    table-named-ctes
    qual-lookup
    qual-map-meta
    resolved-scalars
    table-row
    :~
    :-  %qualified-col
        :-  [%if-then-else true-predicate q-col-1 q-col-2]
            [~.ud 1]
    :-  %dime
        :-  [%if-then-else true-predicate [~.t 'foo'] [~.t 'bar']]
            [~.t 'foo']
    :-  %scalar-name
        :-  [%if-then-else true-predicate [%scalar-name %scalar1] q-col-2]
            [~.ud 3]
  ==
  ==
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
++  test-qual-if-else
  %:  run-scalar-tests
    table-named-ctes
    qual-lookup
    qual-map-meta
    resolved-scalars
    table-row
    :~
    :-  %qualified-col
        :-  [%if-then-else false-predicate q-col-1 q-col-2]
            [~.ud 2]
    :-  %dime
        :-  [%if-then-else false-predicate [~.t 'foo'] [~.t 'bar']]
            [~.t 'bar']
    :-  %scalar-name
        :-  [%if-then-else false-predicate q-col-2 [%scalar-name %scalar1]]
            [~.ud 3]
  ==
  ==
::
::  %eq unqualified tests
++  test-unqual-if-predicate-eq
  %:  run-scalar-tests
    table-named-ctes
    qual-lookup
    unqual-map-meta
    resolved-scalars
    table-row
    :~
    :-  %eq-unqualified-columns
        :-  [%if-then-else [%eq [u-col-4 ~ ~] [u-col-5 ~ ~]] u-col-4 u-col-5]
            [~.ud 5]
    :-  %eq-unqualified-column-and-dime
        :-  [%if-then-else [%eq [u-col-4 ~ ~] [[~.ud 4] ~ ~]] u-col-4 u-col-5]
            [~.ud 4]
    :-  %eq-dime-and-unqualified-column
        :-  [%if-then-else [%eq [[~.ud 4] ~ ~] [u-col-4 ~ ~]] u-col-4 u-col-5]
            [~.ud 4]
  ==
  ==
::
::  %neq unqualified tests
++  test-unqual-if-predicate-neq
  %:  run-scalar-tests
    table-named-ctes
    qual-lookup
    unqual-map-meta
    resolved-scalars
    table-row
    :~
    :-  %neq-unqualified-columns
        :-  [%if-then-else [%neq [u-col-4 ~ ~] [u-col-5 ~ ~]] u-col-4 u-col-5]
            [~.ud 4]
    :-  %neq-unqualified-column-and-dime
        :-  [%if-then-else [%neq [u-col-4 ~ ~] [[~.ud 4] ~ ~]] u-col-4 u-col-5]
            [~.ud 5]
    :-  %neq-dime-and-unqualified-column
        :-  [%if-then-else [%neq [[~.ud 4] ~ ~] [u-col-4 ~ ~]] u-col-4 u-col-5]
            [~.ud 5]
  ==
  ==
::
::  %gte unqualified tests
++  test-unqual-if-predicate-gte
  %:  run-scalar-tests
    table-named-ctes
    qual-lookup
    unqual-map-meta
    resolved-scalars
    table-row
    :~
    :-  %gte-unqualified-columns-gt
        :-  [%if-then-else [%gte [u-col-5 ~ ~] [u-col-4 ~ ~]] u-col-4 u-col-5]
            [~.ud 4]
    :-  %gte-unqualified-columns-eq
        :-  [%if-then-else [%gte [u-col-4 ~ ~] [u-col-4 ~ ~]] u-col-4 u-col-5]
            [~.ud 4]
    :-  %gte-unqualified-columns-false
        :-  [%if-then-else [%gte [u-col-4 ~ ~] [u-col-5 ~ ~]] u-col-4 u-col-5]
            [~.ud 5]
    :-  %gte-unqualified-column-and-dime-gt
        :-  [%if-then-else [%gte [u-col-5 ~ ~] [[~.ud 4] ~ ~]] u-col-4 u-col-5]
            [~.ud 4]
    :-  %gte-unqualified-column-and-dime-eq
        :-  [%if-then-else [%gte [u-col-4 ~ ~] [[~.ud 4] ~ ~]] u-col-4 u-col-5]
            [~.ud 4]
    :-  %gte-unqualified-column-and-dime-false
        :-  [%if-then-else [%gte [u-col-4 ~ ~] [[~.ud 5] ~ ~]] u-col-4 u-col-5]
            [~.ud 5]
    :-  %gte-dime-and-unqualified-column-gt
        :-  [%if-then-else [%gte [[~.ud 5] ~ ~] [u-col-4 ~ ~]] u-col-4 u-col-5]
            [~.ud 4]
    :-  %gte-dime-and-unqualified-column-eq
        :-  [%if-then-else [%gte [[~.ud 4] ~ ~] [u-col-4 ~ ~]] u-col-4 u-col-5]
            [~.ud 4]
    :-  %gte-dime-and-unqualified-column-false
        :-  [%if-then-else [%gte [[~.ud 4] ~ ~] [u-col-5 ~ ~]] u-col-4 u-col-5]
            [~.ud 5]
  ==
  ==
::
::  %gt unqualified tests
++  test-unqual-if-predicate-gt
  %:  run-scalar-tests
    table-named-ctes
    qual-lookup
    unqual-map-meta
    resolved-scalars
    table-row
    :~
    :-  %gt-unqualified-columns-gt
        :-  [%if-then-else [%gt [u-col-5 ~ ~] [u-col-4 ~ ~]] u-col-4 u-col-5]
            [~.ud 4]
    :-  %gt-unqualified-columns-false
        :-  [%if-then-else [%gt [u-col-4 ~ ~] [u-col-5 ~ ~]] u-col-4 u-col-5]
            [~.ud 5]
    :-  %gt-unqualified-column-and-dime-gt
        :-  [%if-then-else [%gt [u-col-5 ~ ~] [[~.ud 4] ~ ~]] u-col-4 u-col-5]
            [~.ud 4]
    :-  %gt-unqualified-column-and-dime-false
        :-  [%if-then-else [%gt [u-col-4 ~ ~] [[~.ud 5] ~ ~]] u-col-4 u-col-5]
            [~.ud 5]
    :-  %gt-dime-and-unqualified-column-gt
        :-  [%if-then-else [%gt [[~.ud 5] ~ ~] [u-col-4 ~ ~]] u-col-4 u-col-5]
            [~.ud 4]
    :-  %gt-dime-and-unqualified-column-false
        :-  [%if-then-else [%gt [[~.ud 4] ~ ~] [u-col-5 ~ ~]] u-col-4 u-col-5]
            [~.ud 5]
  ==
  ==
::
::  %lte unqualified tests
++  test-unqual-if-predicate-lte
  %:  run-scalar-tests
    table-named-ctes
    qual-lookup
    unqual-map-meta
    resolved-scalars
    table-row
    :~
    :-  %lte-unqualified-columns-lt
        :-  [%if-then-else [%lte [u-col-4 ~ ~] [u-col-5 ~ ~]] u-col-4 u-col-5]
            [~.ud 4]
    :-  %lte-unqualified-columns-eq
        :-  [%if-then-else [%lte [u-col-4 ~ ~] [u-col-4 ~ ~]] u-col-4 u-col-5]
            [~.ud 4]
    :-  %lte-unqualified-columns-false
        :-  [%if-then-else [%lte [u-col-5 ~ ~] [u-col-4 ~ ~]] u-col-4 u-col-5]
            [~.ud 5]
    :-  %lte-unqualified-column-and-dime-lt
        :-  [%if-then-else [%lte [u-col-4 ~ ~] [[~.ud 5] ~ ~]] u-col-4 u-col-5]
            [~.ud 4]
    :-  %lte-unqualified-column-and-dime-eq
        :-  [%if-then-else [%lte [u-col-4 ~ ~] [[~.ud 4] ~ ~]] u-col-4 u-col-5]
            [~.ud 4]
    :-  %lte-unqualified-column-and-dime-false
        :-  [%if-then-else [%lte [u-col-5 ~ ~] [[~.ud 4] ~ ~]] u-col-4 u-col-5]
            [~.ud 5]
    :-  %lte-dime-and-unqualified-column-lt
        :-  [%if-then-else [%lte [[~.ud 4] ~ ~] [u-col-5 ~ ~]] u-col-4 u-col-5]
            [~.ud 4]
    :-  %lte-dime-and-unqualified-column-eq
        :-  [%if-then-else [%lte [[~.ud 4] ~ ~] [u-col-4 ~ ~]] u-col-4 u-col-5]
            [~.ud 4]
    :-  %lte-dime-and-unqualified-column-false
        :-  [%if-then-else [%lte [[~.ud 5] ~ ~] [u-col-4 ~ ~]] u-col-4 u-col-5]
            [~.ud 5]
  ==
  ==
::
::  %lt unqualified tests
++  test-unqual-if-predicate-lt
  %:  run-scalar-tests
    table-named-ctes
    qual-lookup
    unqual-map-meta
    resolved-scalars
    table-row
    :~
    :-  %lt-unqualified-columns-lt
        :-  [%if-then-else [%lt [u-col-4 ~ ~] [u-col-5 ~ ~]] u-col-4 u-col-5]
            [~.ud 4]
    :-  %lt-unqualified-columns-false
        :-  [%if-then-else [%lt [u-col-5 ~ ~] [u-col-4 ~ ~]] u-col-4 u-col-5]
            [~.ud 5]
    :-  %lt-unqualified-column-and-dime-lt
        :-  [%if-then-else [%lt [u-col-4 ~ ~] [[~.ud 5] ~ ~]] u-col-4 u-col-5]
            [~.ud 4]
    :-  %lt-unqualified-column-and-dime-false
        :-  [%if-then-else [%lt [u-col-5 ~ ~] [[~.ud 4] ~ ~]] u-col-4 u-col-5]
            [~.ud 5]
    :-  %lt-dime-and-unqualified-column-lt
        :-  [%if-then-else [%lt [[~.ud 4] ~ ~] [u-col-5 ~ ~]] u-col-4 u-col-5]
            [~.ud 4]
    :-  %lt-dime-and-unqualified-column-false
        :-  [%if-then-else [%lt [[~.ud 5] ~ ~] [u-col-4 ~ ~]] u-col-4 u-col-5]
            [~.ud 5]
  ==
  ==
::
::  %in unqualified tests
++  test-unqual-if-predicate-in
  %:  run-scalar-tests
    table-named-ctes
    qual-lookup
    unqual-map-meta
    resolved-scalars
    table-row
    :~
    :-  %in-unqualified-column
        :-  [%if-then-else [%in [u-col-4 ~ ~] [[%value-literals [~.ud '1;2;4;5']] ~ ~]] u-col-4 u-col-5]
            [~.ud 4]
    :-  %in-unqualified-column-false
        :-  [%if-then-else [%in [u-col-6 ~ ~] [[%value-literals [~.ud '1;2;4;5']] ~ ~]] u-col-4 u-col-5]
            [~.ud 5]
  ==
  ==
::
::  %not-in unqualified tests
++  test-unqual-if-predicate-not-in
  %:  run-scalar-tests
    table-named-ctes
    qual-lookup
    unqual-map-meta
    resolved-scalars
    table-row
    :~
    :-  %not-in-unqualified-column
        :-  [%if-then-else [%not-in [u-col-6 ~ ~] [[%value-literals [~.ud '1;2;4;5']] ~ ~]] u-col-4 u-col-5]
            [~.ud 4]
    :-  %not-in-unqualified-column-false
        :-  [%if-then-else [%not-in [u-col-4 ~ ~] [[%value-literals [~.ud '1;2;4;5']] ~ ~]] u-col-4 u-col-5]
            [~.ud 5]
  ==
  ==
::
::  %between unqualified tests
++  test-unqual-if-predicate-between
  =/  mk-between-pred
    |*  [val-to-test=* lower-bound=* upper-bound=*]
    :+  %between
      [%gte [val-to-test ~ ~] [lower-bound ~ ~]]
    [%lte [val-to-test ~ ~] [upper-bound ~ ~]]
  %:  run-scalar-tests
    table-named-ctes
    qual-lookup
    unqual-map-meta
    resolved-scalars
    table-row
    :~
    :-  %between-unqualified-column-unqualified-columns
        :-  :*  %if-then-else
              (mk-between-pred u-col-5 u-col-4 u-col-6)
              u-col-4
              u-col-5
              ==
            [~.ud 4]
    :-  %between-unqualified-column-dime-and-unqualified-column
        :-  :*  %if-then-else
              (mk-between-pred u-col-5 [~.ud 4] u-col-6)
              u-col-4
              u-col-5
              ==
            [~.ud 4]
    :-  %between-unqualified-column-unqualified-column-and-dime
        :-  :*  %if-then-else
              (mk-between-pred u-col-5 u-col-4 [~.ud 6])
              u-col-4
              u-col-5
              ==
            [~.ud 4]
    :-  %between-unqualified-column-dimes
        :-  :*  %if-then-else
              (mk-between-pred u-col-5 [~.ud 4] [~.ud 6])
              u-col-4
              u-col-5
              ==
            [~.ud 4]
    :-  %between-unqualified-column-dimes-false
        :-  :*  %if-then-else
              (mk-between-pred u-col-4 [~.ud 5] [~.ud 7])
              u-col-4
              u-col-5
              ==
            [~.ud 5]
  ==
  ==
::
::  %not-between unqualified tests
++  test-unqual-if-predicate-not-between
  =/  mk-not-between-pred
    |*  [val-to-test=* lower-bound=* upper-bound=*]
    :+  %not-between
      [%gte [val-to-test ~ ~] [lower-bound ~ ~]]
    [%lte [val-to-test ~ ~] [upper-bound ~ ~]]
  %:  run-scalar-tests
    table-named-ctes
    qual-lookup
    unqual-map-meta
    resolved-scalars
    table-row
    :~
    :-  %not-between-unqualified-column-unqualified-columns
        :-  :*  %if-then-else
              (mk-not-between-pred u-col-4 u-col-5 u-col-6)
              u-col-4
              u-col-5
              ==
            [~.ud 4]
    :-  %not-between-unqualified-column-dime-and-unqualified-column
        :-  :*  %if-then-else
              (mk-not-between-pred u-col-4 [~.ud 5] u-col-6)
              u-col-4
              u-col-5
              ==
            [~.ud 4]
    :-  %not-between-unqualified-column-unqualified-column-and-dime
        :-  :*  %if-then-else
              (mk-not-between-pred u-col-4 u-col-5 [~.ud 6])
              u-col-4
              u-col-5
              ==
            [~.ud 4]
    :-  %not-between-unqualified-column-dimes
        :-  :*  %if-then-else
              (mk-not-between-pred u-col-4 [~.ud 5] [~.ud 7])
              u-col-4
              u-col-5
              ==
            [~.ud 4]
    :-  %not-between-unqualified-column-dimes-false
        :-  :*  %if-then-else
              (mk-not-between-pred u-col-5 [~.ud 4] [~.ud 6])
              u-col-4
              u-col-5
              ==
            [~.ud 5]
  ==
  ==
::
::  then/else unqualified tests
++  test-unqual-if-then
  %:  run-scalar-tests
    table-named-ctes
    qual-lookup
    unqual-map-meta
    resolved-scalars
    table-row
    :~
    :-  %unqualified-col
        :-  [%if-then-else true-predicate u-col-4 u-col-5]
            [~.ud 4]
  ==
  ==
::
++  test-unqual-if-else
  %:  run-scalar-tests
    table-named-ctes
    qual-lookup
    unqual-map-meta
    resolved-scalars
    table-row
    :~
    :-  %unqualified-col
        :-  [%if-then-else false-predicate u-col-4 u-col-5]
            [~.ud 5]
  ==
  ==
::
++  test-embedded-by-name-if
  %:  run-scalar-tests
    table-named-ctes
    qual-lookup
    qual-map-meta
    resolved-scalars
    table-row
    :~
    ::  then - embedded scalar
    :-  %embedded-scalar
        :-  [%if-then-else true-predicate [%scalar-name %scalar1] q-col-2]
            [~.ud 3]
    ::  else - embedded scalar
    :-  %embedded-scalar
        :-  [%if-then-else false-predicate q-col-2 [%scalar-name %scalar1]]
            [~.ud 3]
  ==
  ==
++  test-embedded-by-node-if
  %:  run-scalar-tests
    table-named-ctes
    qual-lookup
    qual-map-meta
    resolved-scalars
    table-row
    :~
    ::  then - embedded scalar
    :-  %embedded-scalar
        :-  :*  %if-then-else
              true-predicate
              :^  %if-then-else
                  if=[n=%eq [n=[~.ud 1] ~ ~] [n=[~.ud 1] ~ ~]]
                  :^  %qualified-column
                      :*  %qualified-table
                           ship=(some ~sampel-palnet)
                           database=%db2
                           namespace=%dba
                           name=%table1
                           alias=~
                           ==
                      %col3
                      ~
                  :^  %qualified-column
                      :*  %qualified-table
                           ship=(some ~sampel-palnet)
                           database=%db2
                           namespace=%dba
                           name=%table1
                           alias=~
                           ==
                      %col2
                      ~
              q-col-2
              ==
            [~.ud 3]
    ::  else - embedded scalar
    :-  %embedded-scalar
        :-  :*  %if-then-else
              false-predicate
              q-col-2
              :^  %if-then-else
                  if=[n=%eq [n=[~.ud 1] ~ ~] [n=[~.ud 1] ~ ~]]
                  :^  %qualified-column
                      :*  %qualified-table
                           ship=(some ~sampel-palnet)
                           database=%db2
                           namespace=%dba
                           name=%table1
                           alias=~
                           ==
                      %col3
                      ~
                  :^  %qualified-column
                      :*  %qualified-table
                           ship=(some ~sampel-palnet)
                           database=%db2
                           namespace=%dba
                           name=%table1
                           alias=~
                           ==
                      %col2
                      ~
              ==
            [~.ud 3]
  ==
  ==
::
++  test-embedded-by-cte-column-if
  %:  run-scalar-tests
    table-named-ctes
    qual-lookup
    qual-map-meta
    resolved-scalars
    table-row
    :~
    ::  then - embedded cte column
    :-  %embedded-cte-column
        :-  [%if-then-else true-predicate if-cte-value q-col-2]
            [~.ud 3]
    ::  else - embedded cte column
    :-  %embedded-cte-column
        :-  [%if-then-else false-predicate q-col-2 if-cte-value]
            [~.ud 3]
  ==
  ==
::
++  test-fail-no-table
  =/  empty-lookup
    ^-  qualifier-lookup
    (malt (limo ~[[%col4 `(list qualified-table)`~]]))
  %+  expect-fail-message
    'no table!'
    |.  %:  prepare-scalar
              ^-  scalar-function:ast
              [%if-then-else true-predicate u-col-4 [~.ud 0]]
              table-named-ctes
              empty-lookup
              qual-map-meta
              resolved-scalars
              (bowl [0 ~2026.4.21])
              eny:(bowl [0 ~2026.4.21])
              ==
::
++  test-fail-too-many-tables
  =/  multi-lookup
    ^-  qualifier-lookup
    (malt (limo ~[[%col4 ~[qualified-table-1 qualified-table-1]]]))
  %+  expect-fail-message
    'too many tables!'
    |.  %:  prepare-scalar
              ^-  scalar-function:ast
              [%if-then-else true-predicate u-col-4 [~.ud 0]]
              table-named-ctes
              multi-lookup
              qual-map-meta
              resolved-scalars
              (bowl [0 ~2026.4.21])
              eny:(bowl [0 ~2026.4.21])
              ==
--
