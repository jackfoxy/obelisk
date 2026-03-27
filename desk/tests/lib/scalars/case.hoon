/-  ast, *obelisk
/+  *scalars,  *test,  *server,  *test-helpers
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
++  q-col-1           [%qualified-column qualified-table-1 %col1 ~]
++  q-col-2           [%qualified-column qualified-table-1 %col2 ~]
++  q-col-3           [%qualified-column qualified-table-1 %col3 ~]
++  q-col-4           [%qualified-column qualified-table-1 %other-col4 ~]
::
::
++  u-col-4           [%unqualified-column %col4 ~]
++  u-col-5           [%unqualified-column %col5 ~]
++  u-col-6           [%unqualified-column %col6 ~]
::
++  qual-map-meta  %-  mk-qualified-map-meta
                       :~  :-  qualified-table-1
                               %-  addr-columns
                                   :~  [%column %col1 ~.ud 0]
                                       [%column %col2 ~.ud 0]
                                       [%column %col3 ~.ud 0]
                                       [%column %col4 ~.ud 0]
                                       [%column %other-col4 ~.ud 0]
                                       [%column %col5 ~.ud 0]
                                       [%column %col6 ~.ud 0]
                                       ==
                           ==
::
++  unqual-map-meta  :-  %unqualified-map-meta
                         %-  mk-unqualified-typ-addr-lookup
                             %-  addr-columns  :~  [%column %col1 ~.ud 0]
                                                   [%column %col2 ~.ud 0]
                                                   [%column %col3 ~.ud 0]
                                                   [%column %col4 ~.ud 0]
                                                   [%column %other-col4 ~.ud 0]
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
++  table-named-ctes        *named-ctes
::
++  table-row               %-  mk-indexed-row
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
++  resolved-scalars
  ^-  (map @tas resolved-scalar)
  %-  malt  %-  limo  :~  :-  %scalar1
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
                                    ==
                          :-  %scalar2
                              %:  prepare-scalar
                                    ^-  scalar-function:ast
                                    :*  %if-then-else
                                      if=true-predicate
                                      then=u-col-4
                                      else=u-col-5
                                    ==
                                    table-named-ctes
                                    qual-lookup
                                    unqual-map-meta
                                    *(map @tas resolved-scalar)
                                    (bowl [0 ~2026.4.21])
                                    ==
                          ==
::
::
::  tests
::  - DONE:             %eq %neq %gte %gt %lte %lt %in %not-in %between
::                      %not-between %and %or
::  - MISSING:
::  - ???:              %not (doesn't work for qualified/unqualified col)
::  - NOT IMPLEMENTED:  %equiv %not-equiv %exists %not-%exists %all %any
::

::  ::::::::::::::::::::
::  :::: WHEN TESTS ::::
::  ::::::::::::::::::::
::  TODO: test that if we have a target then the whens are datums (and viceversa)
::  TODO: test that all the whens are of the same kind
::
::  %eq tests
::
++  test-qual-case-when-searched-eq
  %:  run-scalar-tests
    table-named-ctes
    qual-lookup
    qual-map-meta
    resolved-scalars
    table-row
    :~
    :-  %searched-eq-dime-dime
        :-  :*  %case
              ~
              ~[[%case-when-then [%eq [literal-1 ~ ~] [literal-1 ~ ~]] q-col-1]]
              ~
              ==
            literal-1
    :-  %searched-eq-qualified-col-dime
        :-  :*  %case
              ~
              ~[[%case-when-then [%eq [q-col-1 ~ ~] [literal-1 ~ ~]] q-col-1]]
              ~
              ==
            literal-1
    :-  %searched-eq-dime-qualified-col
        :-  :*  %case
              ~
              ~[[%case-when-then [%eq [literal-1 ~ ~] [q-col-1 ~ ~]] q-col-1]]
              ~
              ==
            literal-1
  ==
  ==
::::
::::  %neq tests
::::
++  test-qual-case-when-searched-neq
  %:  run-scalar-tests
    table-named-ctes
    qual-lookup
    qual-map-meta
    resolved-scalars
    table-row
    :~
    :-  %searched-neq-dimes
        :-  :*  %case
              ~
              ~[[%case-when-then [%neq [literal-1 ~ ~] [literal-2 ~ ~]] q-col-1]]
              ~
              ==
            literal-1
    :-  %searched-neq-qualified-columns
        :-  :*  %case
              ~
              ~[[%case-when-then [%neq [q-col-1 ~ ~] [q-col-2 ~ ~]] q-col-1]]
              ~
              ==
            literal-1
    :-  %searched-neq-qualified-col-dime
        :-  :*  %case
              ~
              ~[[%case-when-then [%neq [q-col-1 ~ ~] [literal-2 ~ ~]] q-col-1]]
              ~
              ==
            literal-1
    :-  %searched-neq-dime-qualified-col
        :-  :*  %case
              ~
              ~[[%case-when-then [%neq [literal-2 ~ ~] [q-col-1 ~ ~]] q-col-1]]
              ~
              ==
            literal-1
  ==
  ==
::::
::::  %gte tests
::::
++  test-qual-case-when-searched-gte
  %:  run-scalar-tests
    table-named-ctes
    qual-lookup
    qual-map-meta
    resolved-scalars
    table-row
    :~
    :-  %searched-gte-dimes-gt
        :-  :*  %case
              ~
              ~[[%case-when-then [%gte [literal-2 ~ ~] [literal-1 ~ ~]] q-col-1]]
              ~
              ==
            literal-1
    :-  %searched-gte-dimes-eq
        :-  :*  %case
              ~
              ~[[%case-when-then [%gte [literal-1 ~ ~] [literal-1 ~ ~]] q-col-1]]
              ~
              ==
            literal-1
    :-  %searched-gte-qualified-columns-gt
        :-  :*  %case
              ~
              ~[[%case-when-then [%gte [q-col-2 ~ ~] [q-col-1 ~ ~]] q-col-1]]
              ~
              ==
            literal-1
    :-  %searched-gte-qualified-columns-eq
        :-  :*  %case
              ~
              ~[[%case-when-then [%gte [q-col-1 ~ ~] [q-col-1 ~ ~]] q-col-1]]
              ~
              ==
            literal-1
    :-  %searched-gte-qualified-col-dime-gt
        :-  :*  %case
              ~
              ~[[%case-when-then [%gte [q-col-2 ~ ~] [literal-1 ~ ~]] q-col-1]]
              ~
              ==
            literal-1
    :-  %searched-gte-qualified-col-dime-eq
        :-  :*  %case
              ~
              ~[[%case-when-then [%gte [q-col-1 ~ ~] [literal-1 ~ ~]] q-col-1]]
              ~
              ==
            literal-1
    :-  %searched-gte-dime-qualified-col-gt
        :-  :*  %case
              ~
              ~[[%case-when-then [%gte [literal-2 ~ ~] [q-col-1 ~ ~]] q-col-1]]
              ~
              ==
            literal-1
    :-  %searched-gte-dime-qualified-col-eq
        :-  :*  %case
              ~
              ~[[%case-when-then [%gte [literal-1 ~ ~] [q-col-1 ~ ~]] q-col-1]]
              ~
              ==
            literal-1
  ==
  ==
::::
::::  %gt tests
::::
++  test-qual-case-when-searched-gt
  %:  run-scalar-tests
    table-named-ctes
    qual-lookup
    qual-map-meta
    resolved-scalars
    table-row
    :~
    :-  %searched-gt-dimes-gt
        :-  :*  %case
              ~
              ~[[%case-when-then [%gt [literal-2 ~ ~] [literal-1 ~ ~]] q-col-1]]
              ~
              ==
            literal-1
    :-  %searched-gt-qualified-columns-gt
        :-  :*  %case
              ~
              ~[[%case-when-then [%gt [q-col-2 ~ ~] [q-col-1 ~ ~]] q-col-1]]
              ~
              ==
            literal-1
    :-  %searched-gt-qualified-col-dime-gt
        :-  :*  %case
              ~
              ~[[%case-when-then [%gt [q-col-2 ~ ~] [literal-1 ~ ~]] q-col-1]]
              ~
              ==
            literal-1
    :-  %searched-gt-dime-qualified-col-gt
        :-  :*  %case
              ~
              ~[[%case-when-then [%gt [literal-2 ~ ~] [q-col-1 ~ ~]] q-col-1]]
              ~
              ==
            literal-1
  ==
  ==
::::
::::  %lte tests
::::
++  test-qual-case-when-searched-lte
  %:  run-scalar-tests
    table-named-ctes
    qual-lookup
    qual-map-meta
    resolved-scalars
    table-row
    :~
    :-  %searched-lte-dimes-lt
        :-  :*  %case
              ~
              ~[[%case-when-then [%lte [literal-1 ~ ~] [literal-2 ~ ~]] q-col-1]]
              ~
              ==
            literal-1
    :-  %searched-lte-dimes-eq
        :-  :*  %case
              ~
              ~[[%case-when-then [%lte [literal-1 ~ ~] [literal-1 ~ ~]] q-col-1]]
              ~
              ==
            literal-1
    :-  %searched-lte-qualified-columns-lt
        :-  :*  %case
              ~
              ~[[%case-when-then [%lte [q-col-1 ~ ~] [q-col-2 ~ ~]] q-col-1]]
              ~
              ==
            literal-1
    :-  %searched-lte-qualified-columns-eq
        :-  :*  %case
              ~
              ~[[%case-when-then [%lte [q-col-1 ~ ~] [q-col-1 ~ ~]] q-col-1]]
              ~
              ==
            literal-1
    :-  %searched-lte-qualified-col-dime-lt
        :-  :*  %case
              ~
              ~[[%case-when-then [%lte [q-col-1 ~ ~] [literal-2 ~ ~]] q-col-1]]
              ~
              ==
            literal-1
    :-  %searched-lte-qualified-col-dime-eq
        :-  :*  %case
              ~
              ~[[%case-when-then [%lte [q-col-1 ~ ~] [literal-1 ~ ~]] q-col-1]]
              ~
              ==
            literal-1
    :-  %searched-lte-dime-qualified-col-lt
        :-  :*  %case
              ~
              ~[[%case-when-then [%lte [literal-1 ~ ~] [q-col-2 ~ ~]] q-col-1]]
              ~
              ==
            literal-1
    :-  %searched-lte-dime-qualified-col-eq
        :-  :*  %case
              ~
              ~[[%case-when-then [%lte [literal-1 ~ ~] [q-col-1 ~ ~]] q-col-1]]
              ~
              ==
            literal-1
  ==
  ==
::::
::::  %lt tests
::::
++  test-qual-case-when-searched-lt
  %:  run-scalar-tests
    table-named-ctes
    qual-lookup
    qual-map-meta
    resolved-scalars
    table-row
    :~
    :-  %searched-lt-dimes-lt
        :-  :*  %case
              ~
              ~[[%case-when-then [%lt [literal-1 ~ ~] [literal-2 ~ ~]] q-col-1]]
              ~
              ==
            literal-1
    :-  %searched-lt-qualified-columns-lt
        :-  :*  %case
              ~
              ~[[%case-when-then [%lt [q-col-1 ~ ~] [q-col-2 ~ ~]] q-col-1]]
              ~
              ==
            literal-1
    :-  %searched-lt-qualified-col-dime-lt
        :-  :*  %case
              ~
              ~[[%case-when-then [%lt [q-col-1 ~ ~] [literal-2 ~ ~]] q-col-1]]
              ~
              ==
            literal-1
    :-  %searched-lt-dime-qualified-col-lt
        :-  :*  %case
              ~
              ~[[%case-when-then [%lt [literal-1 ~ ~] [q-col-2 ~ ~]] q-col-1]]
              ~
              ==
            literal-1
  ==
  ==
::::
::::  %in tests
::::
++  test-qual-case-when-searched-in
  %:  run-scalar-tests
    table-named-ctes
    qual-lookup
    qual-map-meta
    resolved-scalars
    table-row
    :~
    :-  %searched-in-dime
        :-  :*  %case
              ~
              ~[[%case-when-then [%in [literal-1 ~ ~] [[%value-literals [~.ud '1;2;4;5']] ~ ~]] q-col-1]]
              ~
              ==
            literal-1
    :-  %searched-in-qualified-col
        :-  :*  %case
              ~
              ~[[%case-when-then [%in [q-col-1 ~ ~] [[%value-literals [~.ud '1;2;4;5']] ~ ~]] q-col-1]]
              ~
              ==
            literal-1
  ==
  ==
::::
::::  %not-in tests
::::
++  test-qual-case-when-searched-not-in
  %:  run-scalar-tests
    table-named-ctes
    qual-lookup
    qual-map-meta
    resolved-scalars
    table-row
    :~
    :-  %searched-not-in-dime
        :-  :*  %case
              ~
              ~[[%case-when-then [%not-in [[~.ud 3] ~ ~] [[%value-literals [~.ud '1;2;4;5']] ~ ~]] q-col-1]]
              ~
              ==
            literal-1
    :-  %searched-not-in-qualified-col
        :-  :*  %case
              ~
              ~[[%case-when-then [%not-in [q-col-3 ~ ~] [[%value-literals [~.ud '1;2;4;5']] ~ ~]] q-col-1]]
              ~
              ==
            literal-1
  ==
  ==
::::
::::  %between tests
::::
++  test-qual-case-when-searched-between
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
    :-  %searched-between-dime-dimes
        :-  :*  %case
              ~
              ~[[%case-when-then (mk-between-pred literal-2 literal-1 [~.ud 3]) q-col-1]]
              ~
              ==
            literal-1
    :-  %searched-between-qualified-col-qualified-cols
        :-  :*  %case
              ~
              ~[[%case-when-then (mk-between-pred q-col-2 q-col-1 q-col-3) q-col-1]]
              ~
              ==
            literal-1
    :-  %searched-between-qualified-col-dime-and-qualified-col
        :-  :*  %case
              ~
              ~[[%case-when-then (mk-between-pred q-col-2 literal-1 q-col-3) q-col-1]]
              ~
              ==
            literal-1
    :-  %searched-between-qualified-col-qualified-col-and-dime
        :-  :*  %case
              ~
              ~[[%case-when-then (mk-between-pred q-col-2 q-col-1 [~.ud 3]) q-col-1]]
              ~
              ==
            literal-1
    :-  %searched-between-qualified-col-dimes
        :-  :*  %case
              ~
              ~[[%case-when-then (mk-between-pred q-col-2 literal-1 [~.ud 3]) q-col-1]]
              ~
              ==
            literal-1
  ==
  ==
::::
::::  %not-between tests
::::
++  test-qual-case-when-searched-not-between
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
    :-  %searched-not-between-dime-dimes
        :-  :*  %case
              ~
              ~[[%case-when-then (mk-not-between-pred [~.ud 5] literal-1 [~.ud 3]) q-col-1]]
              ~
              ==
            literal-1
    :-  %searched-not-between-qualified-col-qualified-cols
        :-  :*  %case
              ~
              ~[[%case-when-then (mk-not-between-pred q-col-1 q-col-2 q-col-3) q-col-1]]
              ~
              ==
            literal-1
    :-  %searched-not-between-qualified-col-dime-and-qualified-col
        :-  :*  %case
              ~
              ~[[%case-when-then (mk-not-between-pred q-col-1 literal-2 q-col-3) q-col-1]]
              ~
              ==
            literal-1
    :-  %searched-not-between-qualified-col-qualified-col-and-dime
        :-  :*  %case
              ~
              ~[[%case-when-then (mk-not-between-pred q-col-1 q-col-2 [~.ud 3]) q-col-1]]
              ~
              ==
            literal-1
    :-  %searched-not-between-qualified-col-dimes
        :-  :*  %case
              ~
              ~[[%case-when-then (mk-not-between-pred q-col-1 literal-2 [~.ud 4]) q-col-1]]
              ~
              ==
            literal-1
  ==
  ==
::::
::::  %and tests
::::
++  test-qual-case-when-searched-and
  %:  run-scalar-tests
    table-named-ctes
    qual-lookup
    qual-map-meta
    resolved-scalars
    table-row
    :~
    :-  %searched-and-true
        :-  :*  %case
              ~
              ~[[%case-when-then [%and [%eq [literal-1 ~ ~] [literal-1 ~ ~]] [%eq [literal-1 ~ ~] [literal-1 ~ ~]]] q-col-1]]
              ~
              ==
            literal-1
  ==
  ==
::::
::::  %or tests
::::
++  test-qual-case-when-searched-or
  %:  run-scalar-tests
    table-named-ctes
    qual-lookup
    qual-map-meta
    resolved-scalars
    table-row
    :~
    :-  %searched-or-true-true
        :-  :*  %case
              ~
              ~[[%case-when-then [%or [%eq [literal-1 ~ ~] [literal-1 ~ ~]] [%eq [literal-1 ~ ~] [literal-1 ~ ~]]] q-col-1]]
              ~
              ==
            literal-1
    :-  %searched-or-true-false
        :-  :*  %case
              ~
              ~[[%case-when-then [%or [%eq [[~.ud 0] ~ ~] [literal-1 ~ ~]] [%eq [literal-1 ~ ~] [literal-1 ~ ~]]] q-col-1]]
              ~
              ==
            literal-1
    :-  %searched-or-false-false
        :-  :*  %case
              ~
              ~[[%case-when-then [%or [%eq [[~.ud 0] ~ ~] [literal-1 ~ ~]] [%eq [[~.ud 0] ~ ~] [literal-1 ~ ~]]] q-col-1]]
              (some literal-value-2)
              ==
            literal-2
  ==
  ==
::::
::::  %not tests
::::
++  test-qual-case-when-searched-not
  %:  run-scalar-tests
    table-named-ctes
    qual-lookup
    qual-map-meta
    resolved-scalars
    table-row
    :~
    :-  %searched-not-false-predicate
        :-  :*  %case
              ~
              ~[[%case-when-then [%not [%eq [[~.ud 0] ~ ~] [literal-1 ~ ~]] ~] q-col-1]]
              ~
              ==
            literal-1
    :-  %searched-not-true-predicate
        :-  :*  %case
              ~
              ~[[%case-when-then [%not [%eq [literal-1 ~ ~] [literal-1 ~ ~]] ~] q-col-1]]
              (some literal-value-2)
              ==
            literal-2
  ==
  ==
::::
::::  ::::::::::::::::::::::
::::  :::: TARGET TESTS ::::
::::  ::::::::::::::::::::::
::
::::  simple case expression tests
::::
++  test-qual-case-when-simple
  %:  run-scalar-tests
    table-named-ctes
    qual-lookup
    qual-map-meta
    resolved-scalars
    table-row
    :~
    ::  target = literal value
    :-  %simple-case-target-dime-when-dime
        :-  :*  %case
              (some literal-value-1)
              ~[[%case-when-then literal-value-1 q-col-1]]
              ~
              ==
            literal-1
    :-  %simple-case-target-dime-when-qualified-column
        :-  :*  %case
              (some literal-value-1)
              ~[[%case-when-then q-col-1 q-col-1]]
              ~
              ==
            literal-1
    :-  %simple-case-target-dime-when-scalar-name
        :-  :*  %case
              (some [~.ud 3])
              ~[[%case-when-then [%scalar-name %scalar1] q-col-1]]
              ~
              ==
            literal-1
    ::  target = qualified column
    :-  %simple-case-target-qualified-when-dime
        :-  :*  %case
              (some q-col-1)
              ~[[%case-when-then literal-value-1 q-col-1]]
              ~
              ==
            literal-1
    :-  %simple-case-target-qualified-when-qualified-column
        :-  :*  %case
              (some q-col-1)
              ~[[%case-when-then q-col-1 q-col-1]]
              ~
              ==
            literal-1
    :-  %simple-case-target-qualified-when-unqualified-column
        :-  :*  %case
              (some q-col-1)
              ~[[%case-when-then [~.ud 1] q-col-1]]
              ~
              ==
            literal-1
    :-  %simple-case-target-qualified-when-scalar-name
        :-  :*  %case
              (some q-col-3)
              ~[[%case-when-then [%scalar-name %scalar1] q-col-1]]
              ~
              ==
            literal-1
    ::  target = scalar alias
    :-  %simple-case-target-scalar-name-when-dime
        :-  :*  %case
              (some [%scalar-name %scalar1])
              ~[[%case-when-then [~.ud 3] q-col-1]]
              ~
              ==
            literal-1
    :-  %simple-case-target-scalar-name-when-qualified-column
        :-  :*  %case
              (some [%scalar-name %scalar1])
              ~[[%case-when-then q-col-3 q-col-1]]
              ~
              ==
            literal-1
    :-  %simple-case-target-scalar-name-when-scalar-name
        :-  :*  %case
              (some [%scalar-name %scalar1])
              ~[[%case-when-then [%scalar-name %scalar1] q-col-1]]
              ~
              ==
            literal-1
  ==
  ==
::
::::  ::::::::::::::::::::::
::::  :::: TARGET TESTS ::::
::::  ::::::::::::::::::::::
::::  TODO: target is not null-checked -- add test
::::
::::  set up some costant context for tests
::::
++  test-qual-case-target
  %:  run-scalar-tests
    table-named-ctes
    qual-lookup
    qual-map-meta
    resolved-scalars
    table-row
    :~
    :-  %dime
        :-  :*  %case
              (some [~.ud 1])
              ~[[%case-when-then [~.ud 1] q-col-1]]
              ~
              ==
            [~.ud 1]
    :-  %qualified-col
        :-  :*  %case
              (some q-col-1)
              ~[[%case-when-then [~.ud 1] q-col-1]]
              ~
              ==
            [~.ud 1]
    :-  %scalar-name
        :-  :*  %case
              (some [%scalar-name %scalar1])
              ~[[%case-when-then [~.ud 3] q-col-1]]
              ~
              ==
            [~.ud 1]
  ==
  ==
::
::::  ::::::::::::::::::::
::::  :::: THEN TESTS ::::
::::  ::::::::::::::::::::
::::  TODO: interesting test case, what if two whens match? which one do we pick?
::::
::::  set up some costant context for tests
::::
::::
::::  tests for all possible then return types
::::  fail scenarios to test later:
::::    - qualified column: no table with column
::::    - unqualified column: no table with column
::::    - scalar alias: no scalar with alias
::::    - embedded scalar: no scalar with alias
::::
++  test-qual-case-then
  %:  run-scalar-tests
    table-named-ctes
    qual-lookup
    qual-map-meta
    resolved-scalars
    table-row
    :~
    :-  %searched-qualified-col
        :-  :*  %case
              ~
              ~[[%case-when-then true-predicate q-col-1]]
              ~
              ==
            [~.ud 1]
    :-  %searched-literal-value
        :-  :*  %case
              ~
              ~[[%case-when-then true-predicate [~.t 'foo']]]
              ~
              ==
            [~.t 'foo']
    :-  %searched-scalar-name
        :-  :*  %case
              ~
              ~[[%case-when-then true-predicate [%scalar-name %scalar1]]]
              ~
              ==
            [~.ud 3]
    :-  %simple-qualified-col
        :-  :*  %case
              (some q-col-1)
              ~[[%case-when-then literal-value-1 q-col-1]]
              ~
              ==
            [~.ud 1]
    :-  %simple-literal-value
        :-  :*  %case
              (some q-col-1)
              ~[[%case-when-then literal-value-1 [~.t 'foo']]]
              ~
              ==
            [~.t 'foo']
    :-  %simple-scalar-name
        :-  :*  %case
              (some q-col-1)
              ~[[%case-when-then literal-value-1 [%scalar-name %scalar1]]]
              ~
              ==
            [~.ud 3]
  ==
  ==
::::
::::  ::::::::::::::::::::
::::  :::: ELSE TESTS ::::
::::  ::::::::::::::::::::
::::
::::  tests for all possible else return types
::::  fail scenarios to test later:
::::    - qualified column: no table with column
::::    - unqualified column: no table with column
::::    - scalar alias: no scalar with alias
::::    - embedded scalar: no scalar with alias
::::
++  test-qual-case-else
  %:  run-scalar-tests
    table-named-ctes
    qual-lookup
    qual-map-meta
    resolved-scalars
    table-row
    :~
    :-  %searched-qualified-col
        :-  :*  %case
              ~
              ~[[%case-when-then false-predicate q-col-1]]
              (some q-col-2)
              ==
            [~.ud 2]
    :-  %searched-literal-value
        :-  :*  %case
              ~
              ~[[%case-when-then false-predicate [~.t 'foo']]]
              (some [~.t 'bar'])
              ==
            [~.t 'bar']
    :-  %searched-scalar-name
        :-  :*  %case
              ~
              ~[[%case-when-then false-predicate q-col-2]]
              (some [%scalar-name %scalar1])
              ==
            [~.ud 3]
    :-  %simple-qualified-col
        :-  :*  %case
              (some q-col-1)
              ~[[%case-when-then literal-value-2 q-col-2]]
              (some q-col-2)
              ==
            [~.ud 2]
    :-  %simple-literal-value
        :-  :*  %case
              (some q-col-1)
              ~[[%case-when-then literal-value-2 [~.t 'foo']]]
              (some [~.t 'bar'])
              ==
            [~.t 'bar']
    :-  %simple-scalar-name
        :-  :*  %case
              (some q-col-1)
              ~[[%case-when-then literal-value-2 q-col-2]]
              (some [%scalar-name %scalar1])
              ==
            [~.ud 3]
  ==
  ==
::
::  %eq unqualified tests
++  test-unqual-case-when-searched-eq
  %:  run-scalar-tests
    table-named-ctes
    qual-lookup
    unqual-map-meta
    resolved-scalars
    table-row
    :~
    :-  %searched-eq-unqualified-col-dime
        :-  :*  %case
              ~
              ~[[%case-when-then [%eq [u-col-4 ~ ~] [[~.ud 4] ~ ~]] u-col-4]]
              ~
              ==
            [~.ud 4]
    :-  %searched-eq-dime-unqualified-col
        :-  :*  %case
              ~
              ~[[%case-when-then [%eq [[~.ud 4] ~ ~] [u-col-4 ~ ~]] u-col-4]]
              ~
              ==
            [~.ud 4]
  ==
  ==
::
::  %neq unqualified tests
++  test-unqual-case-when-searched-neq
  %:  run-scalar-tests
    table-named-ctes
    qual-lookup
    unqual-map-meta
    resolved-scalars
    table-row
    :~
    :-  %searched-neq-unqualified-columns
        :-  :*  %case
              ~
              ~[[%case-when-then [%neq [u-col-4 ~ ~] [u-col-5 ~ ~]] u-col-4]]
              ~
              ==
            [~.ud 4]
    :-  %searched-neq-unqualified-col-dime
        :-  :*  %case
              ~
              ~[[%case-when-then [%neq [u-col-4 ~ ~] [[~.ud 5] ~ ~]] u-col-4]]
              ~
              ==
            [~.ud 4]
    :-  %searched-neq-dime-unqualified-col
        :-  :*  %case
              ~
              ~[[%case-when-then [%neq [[~.ud 5] ~ ~] [u-col-4 ~ ~]] u-col-4]]
              ~
              ==
            [~.ud 4]
  ==
  ==
::
::  %gte unqualified tests
++  test-unqual-case-when-searched-gte
  %:  run-scalar-tests
    table-named-ctes
    qual-lookup
    unqual-map-meta
    resolved-scalars
    table-row
    :~
    :-  %searched-gte-unqualified-columns-gt
        :-  :*  %case
              ~
              ~[[%case-when-then [%gte [u-col-5 ~ ~] [u-col-4 ~ ~]] u-col-4]]
              ~
              ==
            [~.ud 4]
    :-  %searched-gte-unqualified-columns-eq
        :-  :*  %case
              ~
              ~[[%case-when-then [%gte [u-col-4 ~ ~] [u-col-4 ~ ~]] u-col-4]]
              ~
              ==
            [~.ud 4]
    :-  %searched-gte-unqualified-col-dime-gt
        :-  :*  %case
              ~
              ~[[%case-when-then [%gte [u-col-5 ~ ~] [[~.ud 4] ~ ~]] u-col-4]]
              ~
              ==
            [~.ud 4]
    :-  %searched-gte-unqualified-col-dime-eq
        :-  :*  %case
              ~
              ~[[%case-when-then [%gte [u-col-4 ~ ~] [[~.ud 4] ~ ~]] u-col-4]]
              ~
              ==
            [~.ud 4]
    :-  %searched-gte-dime-unqualified-col-gt
        :-  :*  %case
              ~
              ~[[%case-when-then [%gte [[~.ud 5] ~ ~] [u-col-4 ~ ~]] u-col-4]]
              ~
              ==
            [~.ud 4]
    :-  %searched-gte-dime-unqualified-col-eq
        :-  :*  %case
              ~
              ~[[%case-when-then [%gte [[~.ud 4] ~ ~] [u-col-4 ~ ~]] u-col-4]]
              ~
              ==
            [~.ud 4]
  ==
  ==
::
::  %gt unqualified tests
++  test-unqual-case-when-searched-gt
  %:  run-scalar-tests
    table-named-ctes
    qual-lookup
    unqual-map-meta
    resolved-scalars
    table-row
    :~
    :-  %searched-gt-unqualified-columns-gt
        :-  :*  %case
              ~
              ~[[%case-when-then [%gt [u-col-5 ~ ~] [u-col-4 ~ ~]] u-col-4]]
              ~
              ==
            [~.ud 4]
    :-  %searched-gt-unqualified-col-dime-gt
        :-  :*  %case
              ~
              ~[[%case-when-then [%gt [u-col-5 ~ ~] [[~.ud 4] ~ ~]] u-col-4]]
              ~
              ==
            [~.ud 4]
    :-  %searched-gt-dime-unqualified-col-gt
        :-  :*  %case
              ~
              ~[[%case-when-then [%gt [[~.ud 5] ~ ~] [u-col-4 ~ ~]] u-col-4]]
              ~
              ==
            [~.ud 4]
  ==
  ==
::
::  %lte unqualified tests
++  test-unqual-case-when-searched-lte
  %:  run-scalar-tests
    table-named-ctes
    qual-lookup
    unqual-map-meta
    resolved-scalars
    table-row
    :~
    :-  %searched-lte-unqualified-columns-lt
        :-  :*  %case
              ~
              ~[[%case-when-then [%lte [u-col-4 ~ ~] [u-col-5 ~ ~]] u-col-4]]
              ~
              ==
            [~.ud 4]
    :-  %searched-lte-unqualified-columns-eq
        :-  :*  %case
              ~
              ~[[%case-when-then [%lte [u-col-4 ~ ~] [u-col-4 ~ ~]] u-col-4]]
              ~
              ==
            [~.ud 4]
    :-  %searched-lte-unqualified-col-dime-lt
        :-  :*  %case
              ~
              ~[[%case-when-then [%lte [u-col-4 ~ ~] [[~.ud 5] ~ ~]] u-col-4]]
              ~
              ==
            [~.ud 4]
    :-  %searched-lte-unqualified-col-dime-eq
        :-  :*  %case
              ~
              ~[[%case-when-then [%lte [u-col-4 ~ ~] [[~.ud 4] ~ ~]] u-col-4]]
              ~
              ==
            [~.ud 4]
    :-  %searched-lte-dime-unqualified-col-lt
        :-  :*  %case
              ~
              ~[[%case-when-then [%lte [[~.ud 4] ~ ~] [u-col-5 ~ ~]] u-col-4]]
              ~
              ==
            [~.ud 4]
    :-  %searched-lte-dime-unqualified-col-eq
        :-  :*  %case
              ~
              ~[[%case-when-then [%lte [[~.ud 4] ~ ~] [u-col-4 ~ ~]] u-col-4]]
              ~
              ==
            [~.ud 4]
  ==
  ==
::
::  %lt unqualified tests
++  test-unqual-case-when-searched-lt
  %:  run-scalar-tests
    table-named-ctes
    qual-lookup
    unqual-map-meta
    resolved-scalars
    table-row
    :~
    :-  %searched-lt-unqualified-columns-lt
        :-  :*  %case
              ~
              ~[[%case-when-then [%lt [u-col-4 ~ ~] [u-col-5 ~ ~]] u-col-4]]
              ~
              ==
            [~.ud 4]
    :-  %searched-lt-unqualified-col-dime-lt
        :-  :*  %case
              ~
              ~[[%case-when-then [%lt [u-col-4 ~ ~] [[~.ud 5] ~ ~]] u-col-4]]
              ~
              ==
            [~.ud 4]
    :-  %searched-lt-dime-unqualified-col-lt
        :-  :*  %case
              ~
              ~[[%case-when-then [%lt [[~.ud 4] ~ ~] [u-col-5 ~ ~]] u-col-4]]
              ~
              ==
            [~.ud 4]
  ==
  ==
::
::  %in unqualified tests
++  test-unqual-case-when-searched-in
  %:  run-scalar-tests
    table-named-ctes
    qual-lookup
    unqual-map-meta
    resolved-scalars
    table-row
    :~
    :-  %searched-in-unqualified-col
        :-  :*  %case
              ~
              ~[[%case-when-then [%in [u-col-4 ~ ~] [[%value-literals [~.ud '1;2;4;5']] ~ ~]] u-col-4]]
              ~
              ==
            [~.ud 4]
  ==
  ==
::
::  %not-in unqualified tests
++  test-unqual-case-when-searched-not-in
  %:  run-scalar-tests
    table-named-ctes
    qual-lookup
    unqual-map-meta
    resolved-scalars
    table-row
    :~
    :-  %searched-not-in-unqualified-col
        :-  :*  %case
              ~
              ~[[%case-when-then [%not-in [u-col-6 ~ ~] [[%value-literals [~.ud '1;2;4;5']] ~ ~]] u-col-4]]
              ~
              ==
            [~.ud 4]
  ==
  ==
::
::  %between unqualified tests
++  test-unqual-case-when-searched-between
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
    :-  %searched-between-unqualified-col-unqualified-cols
        :-  :*  %case
              ~
              ~[[%case-when-then (mk-between-pred u-col-5 u-col-4 u-col-6) u-col-4]]
              ~
              ==
            [~.ud 4]
    :-  %searched-between-unqualified-col-dime-and-unqualified-col
        :-  :*  %case
              ~
              ~[[%case-when-then (mk-between-pred u-col-5 [~.ud 4] u-col-6) u-col-4]]
              ~
              ==
            [~.ud 4]
    :-  %searched-between-unqualified-col-unqualified-col-and-dime
        :-  :*  %case
              ~
              ~[[%case-when-then (mk-between-pred u-col-5 u-col-4 [~.ud 6]) u-col-4]]
              ~
              ==
            [~.ud 4]
    :-  %searched-between-unqualified-col-dimes
        :-  :*  %case
              ~
              ~[[%case-when-then (mk-between-pred u-col-5 [~.ud 4] [~.ud 6]) u-col-4]]
              ~
              ==
            [~.ud 4]
  ==
  ==
::
::  %not-between unqualified tests
++  test-unqual-case-when-searched-not-between
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
    :-  %searched-not-between-unqualified-col-unqualified-cols
        :-  :*  %case
              ~
              ~[[%case-when-then (mk-not-between-pred u-col-4 u-col-5 u-col-6) u-col-4]]
              ~
              ==
            [~.ud 4]
    :-  %searched-not-between-unqualified-col-dime-and-unqualified-col
        :-  :*  %case
              ~
              ~[[%case-when-then (mk-not-between-pred u-col-4 [~.ud 5] u-col-6) u-col-4]]
              ~
              ==
            [~.ud 4]
    :-  %searched-not-between-unqualified-col-unqualified-col-and-dime
        :-  :*  %case
              ~
              ~[[%case-when-then (mk-not-between-pred u-col-4 u-col-5 [~.ud 6]) u-col-4]]
              ~
              ==
            [~.ud 4]
    :-  %searched-not-between-unqualified-col-dimes
        :-  :*  %case
              ~
              ~[[%case-when-then (mk-not-between-pred u-col-4 [~.ud 5] [~.ud 7]) u-col-4]]
              ~
              ==
            [~.ud 4]
  ==
  ==
::
::  simple case unqualified tests
++  test-unqual-case-when-simple
  %:  run-scalar-tests
    table-named-ctes
    qual-lookup
    unqual-map-meta
    resolved-scalars
    table-row
    :~
    :-  %simple-case-target-dime-when-unqualified-column
        :-  :*  %case
              (some [~.ud 4])
              ~[[%case-when-then u-col-4 q-col-1]]
              ~
              ==
            literal-1
    ::  target = unqualified column
    :-  %simple-case-target-unqualified-when-dime
        :-  :*  %case
              (some u-col-4)
              ~[[%case-when-then [~.ud 4] q-col-1]]
              ~
              ==
            literal-1
    :-  %simple-case-target-unqualified-when-qualified-column
        :-  :*  %case
              (some u-col-4)
              ~[[%case-when-then q-col-4 q-col-1]]
              ~
              ==
            literal-1
    :-  %simple-case-target-unqualified-when-unqualified-column
        :-  :*  %case
              (some u-col-4)
              ~[[%case-when-then u-col-4 q-col-1]]
              ~
              ==
            literal-1
    :-  %simple-case-target-unqualified-when-scalar-name
        :-  :*  %case
              (some u-col-4)
              ~[[%case-when-then [%scalar-name %scalar2] u-col-4]]
              ~
              ==
            [~.ud 4]
    :-  %simple-case-target-scalar-name-when-unqualified-column
        :-  :*  %case
              (some [%scalar-name %scalar2])
              ~[[%case-when-then u-col-4 q-col-1]]
              ~
              ==
            literal-1
  ==
  ==
::
::  case target unqualified tests
++  test-unqual-case-target
  %:  run-scalar-tests
    table-named-ctes
    qual-lookup
    unqual-map-meta
    resolved-scalars
    table-row
    :~
    :-  %unqualified-col
        :-  :*  %case
              (some u-col-4)
              ~[[%case-when-then [~.ud 4] u-col-4]]
              ~
              ==
            [~.ud 4]
  ==
  ==
::
::  case then unqualified tests
++  test-unqual-case-then
  %:  run-scalar-tests
    table-named-ctes
    qual-lookup
    unqual-map-meta
    resolved-scalars
    table-row
    :~
    :-  %searched-unqualified-col
        :-  :*  %case
              ~
              ~[[%case-when-then true-predicate u-col-4]]
              ~
              ==
            [~.ud 4]
    :-  %simple-unqualified-col
        :-  :*  %case
              (some q-col-1)
              ~[[%case-when-then literal-value-1 u-col-4]]
              ~
              ==
            [~.ud 4]
  ==
  ==
::
::  case else unqualified tests
++  test-unqual-case-else
  %:  run-scalar-tests
    table-named-ctes
    qual-lookup
    unqual-map-meta
    resolved-scalars
    table-row
    :~
    :-  %searched-unqualified-col
        :-  :*  %case
              ~
              ~[[%case-when-then false-predicate u-col-4]]
              (some u-col-5)
              ==
            [~.ud 5]
    :-  %simple-unqualified-col
        :-  :*  %case
              (some q-col-1)
              ~[[%case-when-then literal-value-2 u-col-4]]
              (some u-col-5)
              ==
            [~.ud 5]
  ==
  ==
::
++  test-qual-embedded-by-name-case
  %:  run-scalar-tests
    table-named-ctes
    qual-lookup
    qual-map-meta
    resolved-scalars
    table-row
    :~
    ::  simple case when - embedded scalar in when position
    :-  %simple-case-target-dime-when-embedded-scalar
        :-  :*  %case
              (some [~.ud 3])
              ~[[%case-when-then [%scalar-name %scalar1] q-col-1]]
              ~
              ==
            literal-1
    :-  %simple-case-target-qualified-when-embedded-scalar
        :-  :*  %case
              (some q-col-3)
              ~[[%case-when-then [%scalar-name %scalar1] q-col-1]]
              ~
              ==
            literal-1
    :-  %simple-case-target-scalar-name-when-embedded-scalar
        :-  :*  %case
              (some [%scalar-name %scalar1])
              ~[[%case-when-then [%scalar-name %scalar1] q-col-1]]
              ~
              ==
            literal-1
    ::  simple case when - embedded scalar as target
    ::  target = embedded scalar
    :-  %simple-case-target-embedded-scalar-when-dime
        :-  :*  %case
              (some [%scalar-name %scalar1])
              ~[[%case-when-then [~.ud 3] q-col-1]]
              ~
              ==
            literal-1
    :-  %simple-case-target-embedded-scalar-when-qualified-column
        :-  :*  %case
              (some [%scalar-name %scalar1])
              ~[[%case-when-then q-col-3 q-col-1]]
              ~
              ==
            literal-1
    :-  %simple-case-target-embedded-scalar-when-scalar-name
        :-  :*  %case
              (some [%scalar-name %scalar1])
              ~[[%case-when-then [%scalar-name %scalar1] q-col-1]]
              ~
              ==
            literal-1
    :-  %simple-case-target-embedded-scalar-when-embedded-scalar
        :-  :*  %case
              (some [%scalar-name %scalar1])
              ~[[%case-when-then [%scalar-name %scalar1] q-col-1]]
              ~
              ==
            literal-1
    ::  target - embedded scalar
    :-  %embedded-scalar
        :-  :*  %case
              (some [%scalar-name %scalar1])
              ~[[%case-when-then [~.ud 3] q-col-2]]
              ~
              ==
            [~.ud 2]
    ::  then - embedded scalar
    :-  %searched-embedded-scalar
        :-  :*  %case
              ~
              ~[[%case-when-then true-predicate [%scalar-name %scalar1]]]
              ~
              ==
            [~.ud 3]
    :-  %simple-embedded-scalar
        :-  :*  %case
              (some q-col-1)
              ~[[%case-when-then literal-value-1 [%scalar-name %scalar1]]]
              ~
              ==
            [~.ud 3]
    ::  else - embedded scalar
    :-  %searched-embedded-scalar
        :-  :*  %case
              ~
              ~[[%case-when-then false-predicate q-col-2]]
              (some [%scalar-name %scalar1])
              ==
            [~.ud 3]
    :-  %simple-embedded-scalar
        :-  :*  %case
              (some q-col-1)
              ~[[%case-when-then literal-value-2 q-col-2]]
              (some [%scalar-name %scalar1])
              ==
            [~.ud 3]
  ==
  ==
::
++  test-unqual-embedded-by-name-case
  %:  run-scalar-tests
    table-named-ctes
    qual-lookup
    unqual-map-meta
    resolved-scalars
    table-row
    :~
    :-  %simple-case-target-embedded-scalar-when-unqualified-column
        :-  :*  %case
              (some [%scalar-name %scalar2])
              ~[[%case-when-then u-col-4 q-col-1]]
              ~
              ==
            literal-1
    ==
    ==
::
++  test-qual-embedded-by-node-case
  %:  run-scalar-tests
    table-named-ctes
    qual-lookup
    qual-map-meta
    resolved-scalars
    table-row
    :~
    ::  simple case when - embedded scalar in when position
    :-  %simple-case-target-dime-when-embedded-scalar
        :-  :*  %case
              (some [~.ud 3])
              :~  :+  %case-when-then
                      :^  %if-then-else
                          if=[n=%eq [n=[~.ud 1] ~ ~] [n=[~.ud 1] ~ ~]]
                          then=q-col-3
                          else=q-col-2
                      q-col-1
                  ==
              ~
              ==
            literal-1
    :-  %simple-case-target-qualified-when-embedded-scalar
        :-  :*  %case
              (some q-col-3)
              :~  :+  %case-when-then
                      :^  %if-then-else
                          if=[n=%eq [n=[~.ud 1] ~ ~] [n=[~.ud 1] ~ ~]]
                          then=q-col-3
                          else=q-col-2
                      q-col-1
                  ==
              ~
              ==
            literal-1
    :-  %simple-case-target-scalar-name-when-embedded-scalar
        :-  :*  %case
              :-  ~
                  :^  %if-then-else
                      if=[n=%eq [n=[~.ud 1] ~ ~] [n=[~.ud 1] ~ ~]]
                      then=q-col-3
                      else=q-col-2
              :~  :+  %case-when-then
                      :^  %if-then-else
                          if=[n=%eq [n=[~.ud 1] ~ ~] [n=[~.ud 1] ~ ~]]
                          then=q-col-3
                          else=q-col-2
                      q-col-1
                  ==
              ~
              ==
            literal-1
    ::  simple case when - embedded scalar as target
    ::  target = embedded scalar
    :-  %simple-case-target-embedded-scalar-when-dime
        :-  :*  %case
              :-  ~
                  :^  %if-then-else
                      if=[n=%eq [n=[~.ud 1] ~ ~] [n=[~.ud 1] ~ ~]]
                      then=q-col-3
                      else=q-col-2
              ~[[%case-when-then [~.ud 3] q-col-1]]
              ~
              ==
            literal-1
    :-  %simple-case-target-embedded-scalar-when-qualified-column
        :-  :*  %case
              :-  ~
                  :^  %if-then-else
                      if=[n=%eq [n=[~.ud 1] ~ ~] [n=[~.ud 1] ~ ~]]
                      then=q-col-3
                      else=q-col-2
              ~[[%case-when-then q-col-3 q-col-1]]
              ~
              ==
            literal-1
    :-  %simple-case-target-embedded-scalar-when-scalar-name
        :-  :*  %case
              :-  ~
                  :^  %if-then-else
                      if=[n=%eq [n=[~.ud 1] ~ ~] [n=[~.ud 1] ~ ~]]
                      then=q-col-3
                      else=q-col-2
              :~  :+  %case-when-then
                      :^  %if-then-else
                          if=[n=%eq [n=[~.ud 1] ~ ~] [n=[~.ud 1] ~ ~]]
                          then=q-col-3
                          else=q-col-2
                      q-col-1
                  ==
              ~
              ==
            literal-1
    :-  %simple-case-target-embedded-scalar-when-embedded-scalar
        :-  :*  %case
              :-  ~
                  :^  %if-then-else
                      if=[n=%eq [n=[~.ud 1] ~ ~] [n=[~.ud 1] ~ ~]]
                      then=q-col-3
                      else=q-col-2
              :~  :+  %case-when-then
                      :^  %if-then-else
                          if=[n=%eq [n=[~.ud 1] ~ ~] [n=[~.ud 1] ~ ~]]
                          then=q-col-3
                          else=q-col-2
                      q-col-1
                  ==
              ~
              ==
            literal-1
    ::  target - embedded scalar
    :-  %embedded-scalar
        :-  :*  %case
              :-  ~
                  :^  %if-then-else
                      if=[n=%eq [n=[~.ud 1] ~ ~] [n=[~.ud 1] ~ ~]]
                      then=q-col-3
                      else=q-col-2
              ~[[%case-when-then [~.ud 3] q-col-2]]
              ~
              ==
            [~.ud 2]
    ::  then - embedded scalar
    :-  %searched-embedded-scalar
        :-  :*  %case
              ~
              :~  :+  %case-when-then
                      true-predicate
                      :^  %if-then-else
                          if=[n=%eq [n=[~.ud 1] ~ ~] [n=[~.ud 1] ~ ~]]
                          then=q-col-3
                          else=q-col-2
                  ==
              ~
              ==
            [~.ud 3]
    :-  %simple-embedded-scalar
        :-  :*  %case
              (some q-col-1)
              :~  :+  %case-when-then
                      literal-value-1
                      :^  %if-then-else
                          if=[n=%eq [n=[~.ud 1] ~ ~] [n=[~.ud 1] ~ ~]]
                          then=q-col-3
                          else=q-col-2
                  ==
              ~
              ==
            [~.ud 3]
    ::  else - embedded scalar
    :-  %searched-embedded-scalar
        :-  :*  %case
              ~
              ~[[%case-when-then false-predicate q-col-2]]
              :-  ~
                  :^  %if-then-else
                      if=[n=%eq [n=[~.ud 1] ~ ~] [n=[~.ud 1] ~ ~]]
                      then=q-col-3
                      else=q-col-2
              ==
            [~.ud 3]
    :-  %simple-embedded-scalar
        :-  :*  %case
              (some q-col-1)
              ~[[%case-when-then literal-value-2 q-col-2]]
              :-  ~
                  :^  %if-then-else
                      if=[n=%eq [n=[~.ud 1] ~ ~] [n=[~.ud 1] ~ ~]]
                      then=q-col-3
                      else=q-col-2
              ==
            [~.ud 3]
  ==
  ==
::
++  test-unqual-embedded-by-node-case
  %:  run-scalar-tests
    table-named-ctes
    qual-lookup
    unqual-map-meta
    resolved-scalars
    table-row
    :~
    :-  %simple-case-target-embedded-scalar-when-unqualified-column
        :-  :*  %case
              :-  ~
                  :^  %if-then-else
                      if=[n=%eq [n=[~.ud 1] ~ ~] [n=[~.ud 1] ~ ~]]
                      then=[%unqualified-column %col4 ~]
                      else=[%unqualified-column %col5 ~]             
              ~[[%case-when-then u-col-4 q-col-1]]
              ~
              ==
            literal-1
    ==
    ==
::
++  test-fail-searched-empty-cases
  %+  expect-fail-message
    'cases can\'t be empty'
    |.  %:  prepare-scalar
              ^-  scalar-function:ast
              [%case ~ ~ ~]
              table-named-ctes
              qual-lookup
              qual-map-meta
              resolved-scalars
              (bowl [0 ~2026.4.21])
              ==
::
++  test-fail-simple-empty-cases
  %+  expect-fail-message
    'cases can\'t be empty'
    |.  %:  prepare-scalar
              ^-  scalar-function:ast
              [%case (some literal-1) ~ ~]
              table-named-ctes
              qual-lookup
              qual-map-meta
              resolved-scalars
              (bowl [0 ~2026.4.21])
              ==
::
++  test-fail-simple-when-predicate
  %+  expect-fail-message
    'when predicate not allowed in simple case'
    |.  %:  prepare-scalar
              ^-  scalar-function:ast
              :*  %case
                (some literal-1)
                ~[[%case-when-then true-predicate [~.ud 1]]]
                ~
                ==
              table-named-ctes
              qual-lookup
              qual-map-meta
              resolved-scalars
              (bowl [0 ~2026.4.21])
              ==
::
++  test-fail-searched-no-match
  =/  fn
    %:  prepare-scalar
          ^-  scalar-function:ast
          :*  %case
            ~
            ~[[%case-when-then false-predicate [~.ud 1]]]
            ~
            ==
          table-named-ctes
          qual-lookup
          qual-map-meta
          resolved-scalars
          (bowl [0 ~2026.4.21])
          ==
  %+  expect-fail-message
    'no case matched'
    |.  (apply-scalar table-row fn)
::
++  test-fail-simple-no-match
  =/  fn
    %:  prepare-scalar
          ^-  scalar-function:ast
          :*  %case
            (some literal-1)
            ~[[%case-when-then literal-2 literal-2]]
            ~
            ==
          table-named-ctes
          qual-lookup
          qual-map-meta
          resolved-scalars
          (bowl [0 ~2026.4.21])
          ==
  %+  expect-fail-message
    'no case matched'
    |.  (apply-scalar table-row fn)
::
++  test-fail-inconsistent-then-types
  %+  expect-fail-message
    %-  crip  "check-consistent-types: inconsistent types, expected ~.ud ".
              "but got ~.t at [p=~.t q=7.303.014]"
    |.  %:  prepare-scalar
              ^-  scalar-function:ast
              :*  %case
                ~
                :~  [%case-when-then true-predicate [~.ud 1]]
                    [%case-when-then false-predicate [~.t 'foo']]
                ==
                ~
                ==
              table-named-ctes
              qual-lookup
              qual-map-meta
              resolved-scalars
              (bowl [0 ~2026.4.21])
              ==
::
++  test-fail-case-no-table
  =/  empty-lookup
    ^-  qualifier-lookup
    (malt (limo ~[[%col4 `(list qualified-table)`~]]))
  %+  expect-fail-message
    'no table!'
    |.  %:  prepare-scalar
              ^-  scalar-function:ast
              :*  %case
                ~
                ~[[%case-when-then true-predicate u-col-4]]
                ~
                ==
              table-named-ctes
              empty-lookup
              qual-map-meta
              resolved-scalars
              (bowl [0 ~2026.4.21])
              ==
::
++  test-fail-case-too-many-tables
  =/  multi-lookup
    ^-  qualifier-lookup
    (malt (limo ~[[%col4 ~[qualified-table-1 qualified-table-1]]]))
  %+  expect-fail-message
    'too many tables!'
    |.  %:  prepare-scalar
              ^-  scalar-function:ast
              :*  %case
                ~
                ~[[%case-when-then true-predicate u-col-4]]
                ~
                ==
              table-named-ctes
              multi-lookup
              qual-map-meta
              resolved-scalars
              (bowl [0 ~2026.4.21])
              ==
--
