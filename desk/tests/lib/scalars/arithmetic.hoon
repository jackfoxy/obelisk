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
::  table testing harness
::
++  qual-map-meta  %-  mk-qualified-map-meta
                  :~  :-  qualified-table-1
                          %-  addr-columns
                              :~  [%column %col1 ~.ud 0]
                                  [%column %col2 ~.ud 0]
                                  [%column %col3 ~.ud 0]
                                  ==
                      ==
::
++  unqual-map-meta  :-  %unqualified-map-meta
                         %-  mk-unqualified-typ-addr-lookup
                             %-  addr-columns  :~  [%column %col4 ~.ud 0]
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
++  ctes        *named-ctes
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
                              %:  prepare-scalar
                                    :: evals to 3
                                    ^-  scalar-function:ast
                                    :*  %if-then-else
                                      if=true-predicate
                                      then=arithmetic-q-col-3
                                      else=arithmetic-q-col-2
                                    ==
                                    ctes
                                    qual-lookup
                                    qual-map-meta
                                    *(map @tas resolved-scalar)
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
::  set up some costant context for tests
::
++  arithmetic-q-col-1  [%qualified-column qualified-table-1 %col1 ~]
++  arithmetic-q-col-2  [%qualified-column qualified-table-1 %col2 ~]
++  arithmetic-q-col-3  [%qualified-column qualified-table-1 %col3 ~]
::
++  arithmetic-u-col-4  [%unqualified-column %col4 ~]
++  arithmetic-u-col-5  [%unqualified-column %col5 ~]
++  arithmetic-u-col-6  [%unqualified-column %col6 ~]
::
::
::
++  test-qual-arithmetic
  %:  run-scalar-tests
    ctes
    qual-lookup
    qual-map-meta
    resolved-scalars
    table-row
    :~
    ::  addition tests
    :-  %addition-literal-literal
        :-  :*  %arithmetic
              %lus
              literal-value-1
              literal-value-1
              ==
            [~.ud 2]
    :-  %addition-qualified-col-literal
        :-  :*  %arithmetic
              %lus
              arithmetic-q-col-1
              literal-value-1
              ==
            [~.ud 2]
    :-  %addition-scalar-name-literal
        :-  :*  %arithmetic
              %lus
              [%scalar-name %scalar1]
              literal-value-1
              ==
            [~.ud 4]
    :-  %addition-literal-qualified-col
        :-  :*  %arithmetic
              %lus
              literal-value-1
              arithmetic-q-col-1
              ==
            [~.ud 2]
    :-  %addition-literal-scalar-name
        :-  :*  %arithmetic
              %lus
              literal-value-1
              [%scalar-name %scalar1]
              ==
            [~.ud 4]
    ::  subtraction tests
    :-  %subtraction-literal-literal
        :-  :*  %arithmetic
              %hep
              literal-value-2
              literal-value-1
              ==
            [~.ud 1]
    :-  %subtraction-qualified-col-literal
        :-  :*  %arithmetic
              %hep
              arithmetic-q-col-1
              literal-value-1
              ==
            [~.ud 0]
    :-  %subtraction-scalar-name-literal
        :-  :*  %arithmetic
              %hep
              [%scalar-name %scalar1]
              literal-value-1
              ==
            [~.ud 2]
    :-  %subtraction-literal-qualified-col
        :-  :*  %arithmetic
              %hep
              literal-value-1
              arithmetic-q-col-1
              ==
            [~.ud 0]
    :-  %subtraction-literal-scalar-name
        :-  :*  %arithmetic
              %hep
              [%literal-value [~.ud 5]]
              [%scalar-name %scalar1]
              ==
            [~.ud 2]
    ::  multiplication tests
    :-  %multiplication-literal-literal
        :-  :*  %arithmetic
              %tar
              literal-value-2
              literal-value-2
              ==
            [~.ud 4]
    :-  %multiplication-qualified-col-literal
        :-  :*  %arithmetic
              %tar
              arithmetic-q-col-2
              literal-value-1
              ==
            [~.ud 2]
    :-  %multiplication-scalar-name-literal
        :-  :*  %arithmetic
              %tar
              [%scalar-name %scalar1]
              literal-value-1
              ==
            [~.ud 3]
    :-  %multiplication-literal-qualified-col
        :-  :*  %arithmetic
              %tar
              literal-value-1
              arithmetic-q-col-2
              ==
            [~.ud 2]
    :-  %multiplication-literal-scalar-name
        :-  :*  %arithmetic
              %tar
              literal-value-1
              [%scalar-name %scalar1]
              ==
            [~.ud 3]
    ::  division tests
    :-  %division-literal-literal
        :-  :*  %arithmetic
              %fas
              literal-value-2
              literal-value-2
              ==
            [~.ud 1]
    :-  %division-qualified-col-literal
        :-  :*  %arithmetic
              %fas
              arithmetic-q-col-2
              literal-value-1
              ==
            [~.ud 2]
    :-  %division-scalar-name-literal
        :-  :*  %arithmetic
              %fas
              [%scalar-name %scalar1]
              literal-value-1
              ==
            [~.ud 3]
    :-  %division-literal-qualified-col
        :-  :*  %arithmetic
              %fas
              literal-value-1
              arithmetic-q-col-2
              ==
            [~.ud 0]
    :-  %division-literal-scalar-name
        :-  :*  %arithmetic
              %fas
              literal-value-1
              [%scalar-name %scalar1]
              ==
            [~.ud 0]
    ::  exponentiation tests
    :-  %exponentiation-literal-literal
        :-  :*  %arithmetic
              %ket
              [%literal-value [~.ud 3]]
              literal-value-2
              ==
            [~.ud 9]
    :-  %exponentiation-qualified-col-literal
        :-  :*  %arithmetic
              %ket
              arithmetic-q-col-2
              literal-value-1
              ==
            [~.ud 2]
    :-  %exponentiation-scalar-name-literal
        :-  :*  %arithmetic
              %ket
              [%scalar-name %scalar1]
              literal-value-2
              ==
            [~.ud 9]
    :-  %exponentiation-literal-qualified-col
        :-  :*  %arithmetic
              %ket
              literal-value-2
              arithmetic-q-col-2
              ==
            [~.ud 4]
    :-  %exponentiation-literal-scalar-name
        :-  :*  %arithmetic
              %ket
              literal-value-2
              [%scalar-name %scalar1]
              ==
            [~.ud 8]
  ==
  ==
::
++  test-unqual-arithmetic
  %:  run-scalar-tests
    ctes
    qual-lookup
    unqual-map-meta
    resolved-scalars
    table-row
    :~
    ::  addition tests
    :-  %addition-unqualified-col-literal
        :-  :*  %arithmetic
              %lus
              arithmetic-u-col-4
              literal-value-1
              ==
            [~.ud 5]
    :-  %addition-literal-unqualified-col
        :-  :*  %arithmetic
              %lus
              literal-value-1
              arithmetic-u-col-4
              ==
            [~.ud 5]
    ::  subtraction tests
    :-  %subtraction-unqualified-col-literal
        :-  :*  %arithmetic
              %hep
              arithmetic-u-col-5
              literal-value-1
              ==
            [~.ud 4]
    :-  %subtraction-literal-unqualified-col
        :-  :*  %arithmetic
              %hep
              [%literal-value [~.ud 9]]
              arithmetic-u-col-5
              ==
            [~.ud 4]
    ::  multiplication tests
    :-  %multiplication-unqualified-col-literal
        :-  :*  %arithmetic
              %tar
              arithmetic-u-col-5
              literal-value-1
              ==
            [~.ud 5]
    :-  %multiplication-literal-unqualified-col
        :-  :*  %arithmetic
              %tar
              literal-value-1
              arithmetic-u-col-5
              ==
            [~.ud 5]
    ::  division tests
    :-  %division-unqualified-col-literal
        :-  :*  %arithmetic
              %fas
              arithmetic-u-col-5
              literal-value-1
              ==
            [~.ud 5]
    :-  %division-literal-unqualified-col
        :-  :*  %arithmetic
              %fas
              literal-value-1
              arithmetic-u-col-5
              ==
            [~.ud 0]
    ::  exponentiation tests
    :-  %exponentiation-unqualified-col-literal
        :-  :*  %arithmetic
              %ket
              arithmetic-u-col-5
              literal-value-2
              ==
            [~.ud 25]
    :-  %exponentiation-literal-unqualified-col
        :-  :*  %arithmetic
              %ket
              literal-value-2
              arithmetic-u-col-5
              ==
            [~.ud 32]
  ==
  ==
::
::++  test-embedded-arithmetic
::  %:  run-scalar-tests
::    ctes
::    qual-lookup
::    qual-map-meta
::    resolved-scalars
::    table-row
::    :~
::    ::  addition tests
::    :-  %addition-embedded-scalar-literal
::        :-  :*  %arithmetic
::              %lus
::              (~(got by scalars) %scalar1)
::              literal-value-1
::              ==
::            [~.ud 4]
::    :-  %addition-literal-embedded-scalar
::        :-  :*  %arithmetic
::              %lus
::              literal-value-1
::              (~(got by scalars) %scalar1)
::              ==
::            [~.ud 4]
::    ::  subtraction tests
::    :-  %subtraction-embedded-scalar-literal
::        :-  :*  %arithmetic
::              %hep
::              (~(got by scalars) %scalar1)
::              literal-value-1
::              ==
::            [~.ud 2]
::    :-  %subtraction-literal-embedded-scalar
::        :-  :*  %arithmetic
::              %hep
::              [%literal-value [~.ud 5]]
::              (~(got by scalars) %scalar1)
::              ==
::            [~.ud 2]
::    ::  multiplication tests
::    :-  %multiplication-embedded-scalar-literal
::        :-  :*  %arithmetic
::              %tar
::              (~(got by scalars) %scalar1)
::              literal-value-1
::              ==
::            [~.ud 3]
::    :-  %multiplication-literal-embedded-scalar
::        :-  :*  %arithmetic
::              %tar
::              literal-value-1
::              (~(got by scalars) %scalar1)
::              ==
::            [~.ud 3]
::    ::  division tests
::    :-  %division-embedded-scalar-literal
::        :-  :*  %arithmetic
::              %fas
::              (~(got by scalars) %scalar1)
::              literal-value-1
::              ==
::            [~.ud 3]
::    :-  %division-literal-embedded-scalar
::        :-  :*  %arithmetic
::              %fas
::              literal-value-1
::              (~(got by scalars) %scalar1)
::              ==
::            [~.ud 0]
::    ::  exponentiation tests
::    :-  %exponentiation-embedded-scalar-literal
::        :-  :*  %arithmetic
::              %ket
::              (~(got by scalars) %scalar1)
::              literal-value-2
::              ==
::            [~.ud 9]
::    :-  %exponentiation-literal-embedded-scalar
::        :-  :*  %arithmetic
::              %ket
::              literal-value-2
::              (~(got by scalars) %scalar1)
::              ==
::            [~.ud 8]
::  ==
::  ==
--
