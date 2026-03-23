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
::  @rd test values
::
++  rd-literal-1  [~.rd .~1]  :: .~1
++  rd-literal-2  [~.rd .~2]  :: .~2
::
++  rd-qual-map-meta
  %-  mk-qualified-map-meta
  :~  :-  qualified-table-1
          %-  addr-columns
              :~  [%column %col1 ~.rd 0]
                  [%column %col2 ~.rd 0]
                  [%column %col3 ~.rd 0]
                  ==
      ==
::
++  rd-table-row
  %-  mk-indexed-row
  :~  [%col1 .~1]
      [%col2 .~2]
      [%col3 .~3]
      [%col4 .~4]
      [%col5 .~5]
      [%col6 .~6]
      ==
::
++  rd-resolved-scalars
  ^-  (map @tas resolved-scalar)
  %-  malt  %-  limo  :~  :-  %scalar1
                              %:  prepare-scalar
                                    ^-  scalar-function:ast
                                    :*  %if-then-else
                                      if=true-predicate
                                      then=arithmetic-q-col-3
                                      else=arithmetic-q-col-2
                                    ==
                                    ctes
                                    qual-lookup
                                    rd-qual-map-meta
                                    *(map @tas resolved-scalar)
                                    ==
                          ==
::
++  rd-unqual-map-meta
  :-  %unqualified-map-meta
      %-  mk-unqualified-typ-addr-lookup
          %-  addr-columns  :~  [%column %col4 ~.rd 0]
                                [%column %col5 ~.rd 0]
                                [%column %col6 ~.rd 0]
                                ==
::
::  @sd test values
::
++  sd-literal-1  [~.sd --1]  :: --1
++  sd-literal-2  [~.sd --2]  :: --2
::
++  sd-qual-map-meta
  %-  mk-qualified-map-meta
  :~  :-  qualified-table-1
          %-  addr-columns
              :~  [%column %col1 ~.sd 0]
                  [%column %col2 ~.sd 0]
                  [%column %col3 ~.sd 0]
                  ==
      ==
::
++  sd-table-row
  %-  mk-indexed-row
  :~  [%col1 2]   :: --1
      [%col2 4]   :: --2
      [%col3 6]   :: --3
      [%col4 8]   :: --4
      [%col5 10]  :: --5
      [%col6 12]  :: --6
      ==
::
++  sd-resolved-scalars
  ^-  (map @tas resolved-scalar)
  %-  malt  %-  limo  :~  :-  %scalar1
                              %:  prepare-scalar
                                    ^-  scalar-function:ast
                                    :*  %if-then-else
                                      if=true-predicate
                                      then=arithmetic-q-col-3
                                      else=arithmetic-q-col-2
                                    ==
                                    ctes
                                    qual-lookup
                                    sd-qual-map-meta
                                    *(map @tas resolved-scalar)
                                    ==
                          ==
::
++  sd-unqual-map-meta
  :-  %unqualified-map-meta
      %-  mk-unqualified-typ-addr-lookup
          %-  addr-columns  :~  [%column %col4 ~.sd 0]
                                [%column %col5 ~.sd 0]
                                [%column %col6 ~.sd 0]
                                ==
::
::  tests
::
++  test-qual-addition-rd
  %:  run-scalar-tests
    ctes
    qual-lookup
    rd-qual-map-meta
    rd-resolved-scalars
    rd-table-row
    :~
    :-  %addition-literal-literal
        :-  :*  %arithmetic
              %lus
              rd-literal-1
              rd-literal-1
              ==
            [~.rd .~2]  :: .~2
    :-  %addition-qualified-col-literal
        :-  :*  %arithmetic
              %lus
              arithmetic-q-col-1
              rd-literal-1
              ==
            [~.rd .~2]  :: .~1+.~1=.~2
    :-  %addition-scalar-name-literal
        :-  :*  %arithmetic
              %lus
              [%scalar-name %scalar1]
              rd-literal-1
              ==
            [~.rd .~4]  :: .~3+.~1=.~4
    :-  %addition-literal-qualified-col
        :-  :*  %arithmetic
              %lus
              rd-literal-1
              arithmetic-q-col-1
              ==
            [~.rd .~2]  :: .~1+.~1=.~2
    :-  %addition-literal-scalar-name
        :-  :*  %arithmetic
              %lus
              rd-literal-1
              [%scalar-name %scalar1]
              ==
            [~.rd .~4]  :: .~1+.~3=.~4
  ==
  ==
::
++  test-qual-addition-sd
  %:  run-scalar-tests
    ctes
    qual-lookup
    sd-qual-map-meta
    sd-resolved-scalars
    sd-table-row
    :~
    :-  %addition-literal-literal
        :-  :*  %arithmetic
              %lus
              sd-literal-1
              sd-literal-1
              ==
            [~.sd --2]  :: --1+--1=--2
    :-  %addition-qualified-col-literal
        :-  :*  %arithmetic
              %lus
              arithmetic-q-col-1
              sd-literal-1
              ==
            [~.sd --2]  :: --1+--1=--2
    :-  %addition-scalar-name-literal
        :-  :*  %arithmetic
              %lus
              [%scalar-name %scalar1]
              sd-literal-1
              ==
            [~.sd --4]  :: --3+--1=--4
    :-  %addition-literal-qualified-col
        :-  :*  %arithmetic
              %lus
              sd-literal-1
              arithmetic-q-col-1
              ==
            [~.sd --2]  :: --1+--1=--2
    :-  %addition-literal-scalar-name
        :-  :*  %arithmetic
              %lus
              sd-literal-1
              [%scalar-name %scalar1]
              ==
            [~.sd --4]  :: --1+--3=--4
  ==
  ==
::
++  test-qual-addition-ud
  %:  run-scalar-tests
    ctes
    qual-lookup
    qual-map-meta
    resolved-scalars
    table-row
    :~
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
  ==
  ==
::
++  test-qual-subtraction-rd
  %:  run-scalar-tests
    ctes
    qual-lookup
    rd-qual-map-meta
    rd-resolved-scalars
    rd-table-row
    :~
    :-  %subtraction-literal-literal
        :-  :*  %arithmetic
              %hep
              rd-literal-2
              rd-literal-1
              ==
            [~.rd .~1]  :: .~2-.~1=.~1
    :-  %subtraction-qualified-col-literal
        :-  :*  %arithmetic
              %hep
              arithmetic-q-col-1
              rd-literal-1
              ==
            [~.rd .~0]  :: .~1-.~1=.~0
    :-  %subtraction-scalar-name-literal
        :-  :*  %arithmetic
              %hep
              [%scalar-name %scalar1]
              rd-literal-1
              ==
            [~.rd .~2]  :: .~3-.~1=.~2
    :-  %subtraction-literal-qualified-col
        :-  :*  %arithmetic
              %hep
              rd-literal-1
              arithmetic-q-col-1
              ==
            [~.rd .~0]  :: .~1-.~1=.~0
    :-  %subtraction-literal-scalar-name
        :-  :*  %arithmetic
              %hep
              [~.rd .~5]
              [%scalar-name %scalar1]
              ==
            [~.rd .~2]  :: .~5-.~3=.~2
  ==
  ==
::
++  test-qual-subtraction-sd
  %:  run-scalar-tests
    ctes
    qual-lookup
    sd-qual-map-meta
    sd-resolved-scalars
    sd-table-row
    :~
    :-  %subtraction-literal-literal
        :-  :*  %arithmetic
              %hep
              sd-literal-2
              sd-literal-1
              ==
            [~.sd --1]  :: --2---1=--1
    :-  %subtraction-qualified-col-literal
        :-  :*  %arithmetic
              %hep
              arithmetic-q-col-1
              sd-literal-1
              ==
            [~.sd --0]  :: --1---1=--0
    :-  %subtraction-scalar-name-literal
        :-  :*  %arithmetic
              %hep
              [%scalar-name %scalar1]
              sd-literal-1
              ==
            [~.sd --2]  :: --3---1=--2
    :-  %subtraction-literal-qualified-col
        :-  :*  %arithmetic
              %hep
              sd-literal-1
              arithmetic-q-col-1
              ==
            [~.sd --0]  :: --1---1=--0
    :-  %subtraction-literal-scalar-name
        :-  :*  %arithmetic
              %hep
              [~.sd --5]
              [%scalar-name %scalar1]
              ==
            [~.sd --2]  :: --5---3=--2
  ==
  ==
::
++  test-qual-subtraction-ud
  %:  run-scalar-tests
    ctes
    qual-lookup
    qual-map-meta
    resolved-scalars
    table-row
    :~
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
              [~.ud 5]
              [%scalar-name %scalar1]
              ==
            [~.ud 2]
  ==
  ==
::
++  test-qual-multiplication-rd
  %:  run-scalar-tests
    ctes
    qual-lookup
    rd-qual-map-meta
    rd-resolved-scalars
    rd-table-row
    :~
    :-  %multiplication-literal-literal
        :-  :*  %arithmetic
              %tar
              rd-literal-2
              rd-literal-2
              ==
            [~.rd .~4]  :: .~2×.~2=.~4
    :-  %multiplication-qualified-col-literal
        :-  :*  %arithmetic
              %tar
              arithmetic-q-col-2
              rd-literal-1
              ==
            [~.rd .~2]  :: .~2×.~1=.~2
    :-  %multiplication-scalar-name-literal
        :-  :*  %arithmetic
              %tar
              [%scalar-name %scalar1]
              rd-literal-1
              ==
            [~.rd .~3]  :: .~3×.~1=.~3
    :-  %multiplication-literal-qualified-col
        :-  :*  %arithmetic
              %tar
              rd-literal-1
              arithmetic-q-col-2
              ==
            [~.rd .~2]  :: .~1×.~2=.~2
    :-  %multiplication-literal-scalar-name
        :-  :*  %arithmetic
              %tar
              rd-literal-1
              [%scalar-name %scalar1]
              ==
            [~.rd .~3]  :: .~1×.~3=.~3
  ==
  ==
::
++  test-qual-multiplication-sd
  %:  run-scalar-tests
    ctes
    qual-lookup
    sd-qual-map-meta
    sd-resolved-scalars
    sd-table-row
    :~
    :-  %multiplication-literal-literal
        :-  :*  %arithmetic
              %tar
              sd-literal-2
              sd-literal-2
              ==
            [~.sd --4]  :: --2×--2=--4
    :-  %multiplication-qualified-col-literal
        :-  :*  %arithmetic
              %tar
              arithmetic-q-col-2
              sd-literal-1
              ==
            [~.sd --2]  :: --2×--1=--2
    :-  %multiplication-scalar-name-literal
        :-  :*  %arithmetic
              %tar
              [%scalar-name %scalar1]
              sd-literal-1
              ==
            [~.sd --3]  :: --3×--1=--3
    :-  %multiplication-literal-qualified-col
        :-  :*  %arithmetic
              %tar
              sd-literal-1
              arithmetic-q-col-2
              ==
            [~.sd --2]  :: --1×--2=--2
    :-  %multiplication-literal-scalar-name
        :-  :*  %arithmetic
              %tar
              sd-literal-1
              [%scalar-name %scalar1]
              ==
            [~.sd --3]  :: --1×--3=--3
  ==
  ==
::
++  test-qual-multiplication-ud
  %:  run-scalar-tests
    ctes
    qual-lookup
    qual-map-meta
    resolved-scalars
    table-row
    :~
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
  ==
  ==
::
++  test-qual-division-rd
  %:  run-scalar-tests
    ctes
    qual-lookup
    rd-qual-map-meta
    rd-resolved-scalars
    rd-table-row
    :~
    :-  %division-literal-literal
        :-  :*  %arithmetic
              %fas
              rd-literal-2
              rd-literal-2
              ==
            [~.rd .~1]  :: .~2÷.~2=.~1
    :-  %division-qualified-col-literal
        :-  :*  %arithmetic
              %fas
              arithmetic-q-col-2
              rd-literal-1
              ==
            [~.rd .~2]  :: .~2÷.~1=.~2
    :-  %division-scalar-name-literal
        :-  :*  %arithmetic
              %fas
              [%scalar-name %scalar1]
              rd-literal-1
              ==
            [~.rd .~3]  :: .~3÷.~1=.~3
    :-  %division-literal-qualified-col
        :-  :*  %arithmetic
              %fas
              rd-literal-1
              arithmetic-q-col-2
              ==
            [~.rd .~0.5]  :: .~1÷.~2=.~0.5
    :-  %division-literal-scalar-name
        :-  :*  %arithmetic
              %fas
              rd-literal-1
              [%scalar-name %scalar1]
              ==
            [~.rd .~0.33333333333333331]  :: .~1÷.~3=0.333...
  ==
  ==
::
++  test-qual-division-sd
  %:  run-scalar-tests
    ctes
    qual-lookup
    sd-qual-map-meta
    sd-resolved-scalars
    sd-table-row
    :~
    :-  %division-literal-literal
        :-  :*  %arithmetic
              %fas
              sd-literal-2
              sd-literal-2
              ==
            [~.sd --1]  :: --2÷--2=--1
    :-  %division-qualified-col-literal
        :-  :*  %arithmetic
              %fas
              arithmetic-q-col-2
              sd-literal-1
              ==
            [~.sd --2]  :: --2÷--1=--2
    :-  %division-scalar-name-literal
        :-  :*  %arithmetic
              %fas
              [%scalar-name %scalar1]
              sd-literal-1
              ==
            [~.sd --3]  :: --3÷--1=--3
    :-  %division-literal-qualified-col
        :-  :*  %arithmetic
              %fas
              sd-literal-1
              arithmetic-q-col-2
              ==
            [~.sd --0]  :: --1÷--2=--0
    :-  %division-literal-scalar-name
        :-  :*  %arithmetic
              %fas
              sd-literal-1
              [%scalar-name %scalar1]
              ==
            [~.sd --0]  :: --1÷--3=--0
  ==
  ==
::
++  test-qual-division-ud
  %:  run-scalar-tests
    ctes
    qual-lookup
    qual-map-meta
    resolved-scalars
    table-row
    :~
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
  ==
  ==
::
++  test-qual-exponentiation-rd
  %:  run-scalar-tests
    ctes
    qual-lookup
    rd-qual-map-meta
    rd-resolved-scalars
    rd-table-row
    :~
    :-  %exponentiation-literal-literal
        :-  :*  %arithmetic
              %ket
              rd-literal-2
              rd-literal-2
              ==
            [~.rd .~4]  :: .~2^.~2=.~4
    :-  %exponentiation-qualified-col-literal
        :-  :*  %arithmetic
              %ket
              arithmetic-q-col-2
              rd-literal-2
              ==
            [~.rd .~4]  :: .~2^.~2=.~4
    :-  %exponentiation-literal-qualified-col
        :-  :*  %arithmetic
              %ket
              rd-literal-2
              arithmetic-q-col-3
              ==
            [~.rd .~8]  :: .~2^.~3=.~8
    :-  %exponentiation-qualified-col-qualified-col
        :-  :*  %arithmetic
              %ket
              arithmetic-q-col-3
              arithmetic-q-col-2
              ==
            [~.rd .~9]  :: .~3^.~2=.~9
    :-  %exponentiation-literal-ud-exponent
        :-  :*  %arithmetic
              %ket
              rd-literal-2
              [~.ud 3]
              ==
            [~.rd .~8]  :: .~2^3=.~8
    :-  %exponentiation-literal-sd-exponent
        :-  :*  %arithmetic
              %ket
              rd-literal-2
              [~.sd --3]
              ==
            [~.rd .~8]  :: .~2^--3=.~8
    :-  %exponentiation-qualified-col-ud-exponent
        :-  :*  %arithmetic
              %ket
              arithmetic-q-col-3
              [~.ud 2]
              ==
            [~.rd .~9]  :: .~3^2=.~9
    :-  %exponentiation-negative-numerand-literal
        :-  :*  %arithmetic
              %ket
              [~.rd .~-2]
              rd-literal-2
              ==
            [~.rd .~4]  :: .~-2^.~2=.~4
    :-  %exponentiation-negative-numerand-ud-exponent
        :-  :*  %arithmetic
              %ket
              [~.rd .~-2]
              [~.ud 3]
              ==
            [~.rd .~-8]  :: .~-2^3=.~-8
  ==
  ==
::
++  test-qual-exponentiation-ud
  %:  run-scalar-tests
    ctes
    qual-lookup
    qual-map-meta
    resolved-scalars
    table-row
    :~
    :-  %exponentiation-literal-literal
        :-  :*  %arithmetic
              %ket
              [~.ud 3]
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
    :-  %exponentiation-literal-sd-exponent
        :-  :*  %arithmetic
              %ket
              [~.ud 3]
              [~.sd --2]
              ==
            [~.ud 9]  :: 3^--2=9
    :-  %exponentiation-literal-rd-exponent
        :-  :*  %arithmetic
              %ket
              literal-value-2
              rd-literal-2
              ==
            [~.ud 4]  :: 2^.~2=4
    :-  %exponentiation-qualified-col-sd-exponent
        :-  :*  %arithmetic
              %ket
              arithmetic-q-col-3
              [~.sd --2]
              ==
            [~.ud 9]  :: 3^--2=9
    :-  %exponentiation-qualified-col-rd-exponent
        :-  :*  %arithmetic
              %ket
              arithmetic-q-col-3
              rd-literal-2
              ==
            [~.ud 9]  :: 3^.~2=9
  ==
  ==
::
++  test-qual-exponentiation-sd
  %:  run-scalar-tests
    ctes
    qual-lookup
    sd-qual-map-meta
    sd-resolved-scalars
    sd-table-row
    :~
    :-  %exponentiation-literal-literal
        :-  :*  %arithmetic
              %ket
              sd-literal-2
              sd-literal-2
              ==
            [~.sd --4]  :: --2^--2=--4
    :-  %exponentiation-qualified-col-literal
        :-  :*  %arithmetic
              %ket
              arithmetic-q-col-3
              sd-literal-2
              ==
            [~.sd --9]  :: --3^--2=--9
    :-  %exponentiation-literal-qualified-col
        :-  :*  %arithmetic
              %ket
              sd-literal-2
              arithmetic-q-col-3
              ==
            [~.sd --8]  :: --2^--3=--8
    :-  %exponentiation-qualified-col-qualified-col
        :-  :*  %arithmetic
              %ket
              arithmetic-q-col-3
              arithmetic-q-col-2
              ==
            [~.sd --9]  :: --3^--2=--9
    :-  %exponentiation-negative-numerand-literal
        :-  :*  %arithmetic
              %ket
              [~.sd -3]
              arithmetic-q-col-2
              ==
            [~.sd --9]  :: -3^--2=--9
    :-  %exponentiation-literal-ud-exponent
        :-  :*  %arithmetic
              %ket
              sd-literal-2
              [~.ud 3]
              ==
            [~.sd --8]  :: --2^3=--8
    :-  %exponentiation-literal-rd-exponent
        :-  :*  %arithmetic
              %ket
              sd-literal-2
              rd-literal-2
              ==
            [~.sd --4]  :: --2^.~2=--4
    :-  %exponentiation-qualified-col-ud-exponent
        :-  :*  %arithmetic
              %ket
              arithmetic-q-col-3
              [~.ud 2]
              ==
            [~.sd --9]  :: --3^2=--9
    :-  %exponentiation-qualified-col-rd-exponent
        :-  :*  %arithmetic
              %ket
              arithmetic-q-col-3
              rd-literal-2
              ==
            [~.sd --9]  :: --3^.~2=--9
    :-  %exponentiation-negative-numerand-ud-exponent
        :-  :*  %arithmetic
              %ket
              [~.sd -3]
              [~.ud 2]
              ==
            [~.sd --9]  :: -3^2=--9
    :-  %exponentiation-negative-numerand-rd-exponent
        :-  :*  %arithmetic
              %ket
              [~.sd -3]
              rd-literal-2
              ==
            [~.sd --9]  :: -3^.~2=--9
  ==
  ==
::
++  test-qual-remainder-sd
  %:  run-scalar-tests
    ctes
    qual-lookup
    sd-qual-map-meta
    sd-resolved-scalars
    sd-table-row
    :~
    :-  %remainder-literal-literal
        :-  :*  %arithmetic
              %cen
              [~.sd --5]
              sd-literal-2
              ==
            [~.sd --1]  :: --5 rem --2 = --1
    :-  %remainder-qualified-col-literal
        :-  :*  %arithmetic
              %cen
              arithmetic-q-col-3
              sd-literal-2
              ==
            [~.sd --1]  :: --3 rem --2 = --1
    :-  %remainder-literal-qualified-col
        :-  :*  %arithmetic
              %cen
              [~.sd --5]
              arithmetic-q-col-3
              ==
            [~.sd --2]  :: --5 rem --3 = --2
    :-  %remainder-qualified-col-qualified-col
        :-  :*  %arithmetic
              %cen
              arithmetic-q-col-3
              arithmetic-q-col-2
              ==
            [~.sd --1]  :: --3 rem --2 = --1
  ==
  ==
::
++  test-qual-remainder-ud
  %:  run-scalar-tests
    ctes
    qual-lookup
    qual-map-meta
    resolved-scalars
    table-row
    :~
    :-  %remainder-literal-literal
        :-  :*  %arithmetic
              %cen
              [~.ud 5]
              literal-value-2
              ==
            [~.ud 1]
    :-  %remainder-qualified-col-literal
        :-  :*  %arithmetic
              %cen
              arithmetic-q-col-3
              literal-value-2
              ==
            [~.ud 1]
    :-  %remainder-literal-qualified-col
        :-  :*  %arithmetic
              %cen
              [~.ud 5]
              arithmetic-q-col-3
              ==
            [~.ud 2]
    :-  %remainder-qualified-col-qualified-col
        :-  :*  %arithmetic
              %cen
              arithmetic-q-col-3
              arithmetic-q-col-2
              ==
            [~.ud 1]
  ==
  ==
::
++  test-unqual-addition-rd
  %:  run-scalar-tests
    ctes
    qual-lookup
    rd-unqual-map-meta
    rd-resolved-scalars
    rd-table-row
    :~
    :-  %addition-unqualified-col-literal
        :-  :*  %arithmetic
              %lus
              arithmetic-u-col-4
              rd-literal-1
              ==
            [~.rd .~5]  :: .~4+.~1=.~5
    :-  %addition-literal-unqualified-col
        :-  :*  %arithmetic
              %lus
              rd-literal-1
              arithmetic-u-col-4
              ==
            [~.rd .~5]  :: .~1+.~4=.~5
  ==
  ==
::
++  test-unqual-addition-sd
  %:  run-scalar-tests
    ctes
    qual-lookup
    sd-unqual-map-meta
    sd-resolved-scalars
    sd-table-row
    :~
    :-  %addition-unqualified-col-literal
        :-  :*  %arithmetic
              %lus
              arithmetic-u-col-4
              sd-literal-1
              ==
            [~.sd --5]  :: --4+--1=--5
    :-  %addition-literal-unqualified-col
        :-  :*  %arithmetic
              %lus
              sd-literal-1
              arithmetic-u-col-4
              ==
            [~.sd --5]  :: --1+--4=--5
  ==
  ==
::
++  test-unqual-addition-ud
  %:  run-scalar-tests
    ctes
    qual-lookup
    unqual-map-meta
    resolved-scalars
    table-row
    :~
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
  ==
  ==
::
++  test-unqual-subtraction-rd
  %:  run-scalar-tests
    ctes
    qual-lookup
    rd-unqual-map-meta
    rd-resolved-scalars
    rd-table-row
    :~
    :-  %subtraction-unqualified-col-literal
        :-  :*  %arithmetic
              %hep
              arithmetic-u-col-5
              rd-literal-1
              ==
            [~.rd .~4]  :: .~5-.~1=.~4
    :-  %subtraction-literal-unqualified-col
        :-  :*  %arithmetic
              %hep
              [~.rd .~9]
              arithmetic-u-col-5
              ==
            [~.rd .~4]  :: .~9-.~5=.~4
  ==
  ==
::
++  test-unqual-subtraction-sd
  %:  run-scalar-tests
    ctes
    qual-lookup
    sd-unqual-map-meta
    sd-resolved-scalars
    sd-table-row
    :~
    :-  %subtraction-unqualified-col-literal
        :-  :*  %arithmetic
              %hep
              arithmetic-u-col-5
              sd-literal-1
              ==
            [~.sd --4]  :: --5---1=--4
    :-  %subtraction-literal-unqualified-col
        :-  :*  %arithmetic
              %hep
              [~.sd --9]
              arithmetic-u-col-5
              ==
            [~.sd --4]  :: --9---5=--4
  ==
  ==
::
++  test-unqual-subtraction-ud
  %:  run-scalar-tests
    ctes
    qual-lookup
    unqual-map-meta
    resolved-scalars
    table-row
    :~
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
              [~.ud 9]
              arithmetic-u-col-5
              ==
            [~.ud 4]
  ==
  ==
::
++  test-unqual-multiplication-rd
  %:  run-scalar-tests
    ctes
    qual-lookup
    rd-unqual-map-meta
    rd-resolved-scalars
    rd-table-row
    :~
    :-  %multiplication-unqualified-col-literal
        :-  :*  %arithmetic
              %tar
              arithmetic-u-col-5
              rd-literal-1
              ==
            [~.rd .~5]  :: .~5×.~1=.~5
    :-  %multiplication-literal-unqualified-col
        :-  :*  %arithmetic
              %tar
              rd-literal-1
              arithmetic-u-col-5
              ==
            [~.rd .~5]  :: .~1×.~5=.~5
  ==
  ==
::
++  test-unqual-multiplication-sd
  %:  run-scalar-tests
    ctes
    qual-lookup
    sd-unqual-map-meta
    sd-resolved-scalars
    sd-table-row
    :~
    :-  %multiplication-unqualified-col-literal
        :-  :*  %arithmetic
              %tar
              arithmetic-u-col-5
              sd-literal-1
              ==
            [~.sd --5]  :: --5×--1=--5
    :-  %multiplication-literal-unqualified-col
        :-  :*  %arithmetic
              %tar
              sd-literal-1
              arithmetic-u-col-5
              ==
            [~.sd --5]  :: --1×--5=--5
  ==
  ==
::
++  test-unqual-multiplication-ud
  %:  run-scalar-tests
    ctes
    qual-lookup
    unqual-map-meta
    resolved-scalars
    table-row
    :~
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
  ==
  ==
::
++  test-unqual-division-rd
  %:  run-scalar-tests
    ctes
    qual-lookup
    rd-unqual-map-meta
    rd-resolved-scalars
    rd-table-row
    :~
    :-  %division-unqualified-col-literal
        :-  :*  %arithmetic
              %fas
              arithmetic-u-col-5
              rd-literal-1
              ==
            [~.rd .~5]  :: .~5÷.~1=.~5
    :-  %division-literal-unqualified-col
        :-  :*  %arithmetic
              %fas
              rd-literal-1
              arithmetic-u-col-5
              ==
            [~.rd .~0.19999999999999998]  :: .~1÷.~5=.~0.2
  ==
  ==
::
++  test-unqual-division-sd
  %:  run-scalar-tests
    ctes
    qual-lookup
    sd-unqual-map-meta
    sd-resolved-scalars
    sd-table-row
    :~
    :-  %division-unqualified-col-literal
        :-  :*  %arithmetic
              %fas
              arithmetic-u-col-5
              sd-literal-1
              ==
            [~.sd --5]  :: --5÷--1=--5
    :-  %division-literal-unqualified-col
        :-  :*  %arithmetic
              %fas
              sd-literal-1
              arithmetic-u-col-5
              ==
            [~.sd --0]  :: --1÷--5=--0
  ==
  ==
::
++  test-unqual-division-ud
  %:  run-scalar-tests
    ctes
    qual-lookup
    unqual-map-meta
    resolved-scalars
    table-row
    :~
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
  ==
  ==
::
++  test-unqual-exponentiation-rd
  %:  run-scalar-tests
    ctes
    qual-lookup
    rd-unqual-map-meta
    rd-resolved-scalars
    rd-table-row
    :~
    :-  %exponentiation-literal-literal
        :-  :*  %arithmetic
              %ket
              rd-literal-2
              rd-literal-2
              ==
            [~.rd .~4]  :: .~2^.~2=.~4
    :-  %exponentiation-unqualified-col-literal
        :-  :*  %arithmetic
              %ket
              arithmetic-u-col-4
              rd-literal-2
              ==
            [~.rd .~16]  :: .~4^.~2=.~16
    :-  %exponentiation-literal-unqualified-col
        :-  :*  %arithmetic
              %ket
              rd-literal-2
              arithmetic-u-col-5
              ==
            [~.rd .~32]  :: .~2^.~5=.~32
    :-  %exponentiation-unqualified-col-unqualified-col
        :-  :*  %arithmetic
              %ket
              arithmetic-u-col-4
              arithmetic-u-col-5
              ==
            [~.rd .~1024]  :: .~4^.~5=.~1024
    :-  %exponentiation-literal-ud-exponent
        :-  :*  %arithmetic
              %ket
              rd-literal-2
              [~.ud 3]
              ==
            [~.rd .~8]  :: .~2^3=.~8
    :-  %exponentiation-literal-sd-exponent
        :-  :*  %arithmetic
              %ket
              rd-literal-2
              [~.sd --3]
              ==
            [~.rd .~8]  :: .~2^--3=.~8
    :-  %exponentiation-unqualified-col-ud-exponent
        :-  :*  %arithmetic
              %ket
              arithmetic-u-col-4
              [~.ud 2]
              ==
            [~.rd .~16]  :: .~4^2=.~16
    :-  %exponentiation-negative-numerand-literal
        :-  :*  %arithmetic
              %ket
              [~.rd .~-2]
              rd-literal-2
              ==
            [~.rd .~4]  :: .~-2^.~2=.~4
    :-  %exponentiation-negative-numerand-ud-exponent
        :-  :*  %arithmetic
              %ket
              [~.rd .~-2]
              [~.ud 3]
              ==
            [~.rd .~-8]  :: .~-2^3=.~-8
  ==
  ==
::
++  test-unqual-exponentiation-ud
  %:  run-scalar-tests
    ctes
    qual-lookup
    unqual-map-meta
    resolved-scalars
    table-row
    :~
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
    :-  %exponentiation-literal-sd-exponent
        :-  :*  %arithmetic
              %ket
              literal-value-2
              [~.sd --3]
              ==
            [~.ud 8]  :: 2^--3=8
    :-  %exponentiation-literal-rd-exponent
        :-  :*  %arithmetic
              %ket
              literal-value-2
              rd-literal-2
              ==
            [~.ud 4]  :: 2^.~2=4
    :-  %exponentiation-unqualified-col-sd-exponent
        :-  :*  %arithmetic
              %ket
              arithmetic-u-col-5
              [~.sd --2]
              ==
            [~.ud 25]  :: 5^--2=25
    :-  %exponentiation-unqualified-col-rd-exponent
        :-  :*  %arithmetic
              %ket
              arithmetic-u-col-5
              rd-literal-2
              ==
            [~.ud 25]  :: 5^.~2=25
  ==
  ==
::
++  test-unqual-exponentiation-sd
  %:  run-scalar-tests
    ctes
    qual-lookup
    sd-unqual-map-meta
    sd-resolved-scalars
    sd-table-row
    :~
    :-  %exponentiation-literal-literal
        :-  :*  %arithmetic
              %ket
              sd-literal-2
              sd-literal-2
              ==
            [~.sd --4]  :: --2^--2=--4
    :-  %exponentiation-unqualified-col-literal
        :-  :*  %arithmetic
              %ket
              arithmetic-u-col-4
              sd-literal-2
              ==
            [~.sd --16]  :: --4^--2=--16
    :-  %exponentiation-literal-unqualified-col
        :-  :*  %arithmetic
              %ket
              sd-literal-2
              arithmetic-u-col-5
              ==
            [~.sd --32]  :: --2^--5=--32
    :-  %exponentiation-unqualified-col-unqualified-col
        :-  :*  %arithmetic
              %ket
              arithmetic-u-col-4
              arithmetic-u-col-5
              ==
            [~.sd --1.024]  :: --4^--5=--1.024
    :-  %exponentiation-negative-numerand-literal
        :-  :*  %arithmetic
              %ket
              [~.sd -2]
              arithmetic-u-col-5
              ==
            [~.sd -32]  :: -2^--5=-32
    :-  %exponentiation-literal-ud-exponent
        :-  :*  %arithmetic
              %ket
              sd-literal-2
              [~.ud 3]
              ==
            [~.sd --8]  :: --2^3=--8
    :-  %exponentiation-literal-rd-exponent
        :-  :*  %arithmetic
              %ket
              sd-literal-2
              rd-literal-2
              ==
            [~.sd --4]  :: --2^.~2=--4
    :-  %exponentiation-unqualified-col-ud-exponent
        :-  :*  %arithmetic
              %ket
              arithmetic-u-col-4
              [~.ud 2]
              ==
            [~.sd --16]  :: --4^2=--16
    :-  %exponentiation-unqualified-col-rd-exponent
        :-  :*  %arithmetic
              %ket
              arithmetic-u-col-4
              rd-literal-2
              ==
            [~.sd --16]  :: --4^.~2=--16
    :-  %exponentiation-negative-numerand-ud-exponent
        :-  :*  %arithmetic
              %ket
              [~.sd -2]
              [~.ud 3]
              ==
            [~.sd -8]  :: -2^3=-8
    :-  %exponentiation-negative-numerand-rd-exponent
        :-  :*  %arithmetic
              %ket
              [~.sd -2]
              rd-literal-2
              ==
            [~.sd --4]  :: -2^.~2=--4
  ==
  ==
::
++  test-unqual-remainder-sd
  %:  run-scalar-tests
    ctes
    qual-lookup
    sd-unqual-map-meta
    sd-resolved-scalars
    sd-table-row
    :~
    :-  %remainder-literal-literal
        :-  :*  %arithmetic
              %cen
              [~.sd --5]
              sd-literal-2
              ==
            [~.sd --1]  :: --5 rem --2 = --1
    :-  %remainder-unqualified-col-literal
        :-  :*  %arithmetic
              %cen
              arithmetic-u-col-5
              sd-literal-2
              ==
            [~.sd --1]  :: --5 rem --2 = --1
    :-  %remainder-literal-unqualified-col
        :-  :*  %arithmetic
              %cen
              sd-literal-2
              arithmetic-u-col-4
              ==
            [~.sd --2]  :: --2 rem --4 = --2
    :-  %remainder-unqualified-col-unqualified-col
        :-  :*  %arithmetic
              %cen
              arithmetic-u-col-5
              arithmetic-u-col-4
              ==
            [~.sd --1]  :: --5 rem --4 = --1
  ==
  ==
::
++  test-unqual-remainder-ud
  %:  run-scalar-tests
    ctes
    qual-lookup
    unqual-map-meta
    resolved-scalars
    table-row
    :~
    :-  %remainder-literal-literal
        :-  :*  %arithmetic
              %cen
              [~.ud 5]
              literal-value-2
              ==
            [~.ud 1]
    :-  %remainder-unqualified-col-literal
        :-  :*  %arithmetic
              %cen
              arithmetic-u-col-5
              literal-value-2
              ==
            [~.ud 1]
    :-  %remainder-literal-unqualified-col
        :-  :*  %arithmetic
              %cen
              literal-value-2
              arithmetic-u-col-4
              ==
            [~.ud 2]
    :-  %remainder-unqualified-col-unqualified-col
        :-  :*  %arithmetic
              %cen
              arithmetic-u-col-5
              arithmetic-u-col-4
              ==
            [~.ud 1]
  ==
  ==
::
++  test-embedded-by-name-arithmetic
  %:  run-scalar-tests
    ctes
    qual-lookup
    qual-map-meta
    resolved-scalars
    table-row
    :~
    ::  addition tests
    :-  %addition-embedded-scalar-literal
        :-  :*  %arithmetic
              %lus
              [%scalar-name %scalar1]
              literal-value-1
              ==
            [~.ud 4]
    :-  %addition-literal-embedded-scalar
        :-  :*  %arithmetic
              %lus
              literal-value-1
              [%scalar-name %scalar1]
              ==
            [~.ud 4]
    ::  subtraction tests
    :-  %subtraction-embedded-scalar-literal
        :-  :*  %arithmetic
              %hep
              [%scalar-name %scalar1]
              literal-value-1
              ==
            [~.ud 2]
    :-  %subtraction-literal-embedded-scalar
        :-  :*  %arithmetic
              %hep
              [~.ud 5]
              [%scalar-name %scalar1]
              ==
            [~.ud 2]
    ::  multiplication tests
    :-  %multiplication-embedded-scalar-literal
        :-  :*  %arithmetic
              %tar
              [%scalar-name %scalar1]
              literal-value-1
              ==
            [~.ud 3]
    :-  %multiplication-literal-embedded-scalar
        :-  :*  %arithmetic
              %tar
              literal-value-1
              [%scalar-name %scalar1]
              ==
            [~.ud 3]
    ::  division tests
    :-  %division-embedded-scalar-literal
        :-  :*  %arithmetic
              %fas
              [%scalar-name %scalar1]
              literal-value-1
              ==
            [~.ud 3]
    :-  %division-literal-embedded-scalar
        :-  :*  %arithmetic
              %fas
              literal-value-1
              [%scalar-name %scalar1]
              ==
            [~.ud 0]
    ::  exponentiation tests
    :-  %exponentiation-embedded-scalar-literal
        :-  :*  %arithmetic
              %ket
              [%scalar-name %scalar1]
              literal-value-2
              ==
            [~.ud 9]
    :-  %exponentiation-literal-embedded-scalar
        :-  :*  %arithmetic
              %ket
              literal-value-2
              [%scalar-name %scalar1]
              ==
            [~.ud 8]
  ==
  ==
::
++  test-embedded-by-node-arithmetic
  %:  run-scalar-tests
    ctes
    qual-lookup
    qual-map-meta
    resolved-scalars
    table-row
    :~
    ::  addition tests
    :-  %addition-embedded-scalar-literal
        :-  :*  %arithmetic
              %lus
              :^  %if-then-else
                  if=[n=%eq [n=literal-1 ~ ~] [n=literal-1 ~ ~]]
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
              literal-value-1
              ==
            [~.ud 4]
    :-  %addition-literal-embedded-scalar
        :-  :*  %arithmetic
              %lus
              literal-value-1
              :^  %if-then-else
                  if=[n=%eq [n=literal-1 ~ ~] [n=literal-1 ~ ~]]
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
            [~.ud 4]
    ::  subtraction tests
    :-  %subtraction-embedded-scalar-literal
        :-  :*  %arithmetic
              %hep
              :^  %if-then-else
                  if=[n=%eq [n=literal-1 ~ ~] [n=literal-1 ~ ~]]
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
              literal-value-1
              ==
            [~.ud 2]
    :-  %subtraction-literal-embedded-scalar
        :-  :*  %arithmetic
              %hep
              [~.ud 5]
              :^  %if-then-else
                  if=[n=%eq [n=literal-1 ~ ~] [n=literal-1 ~ ~]]
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
            [~.ud 2]
    ::  multiplication tests
    :-  %multiplication-embedded-scalar-literal
        :-  :*  %arithmetic
              %tar
              :^  %if-then-else
                  if=[n=%eq [n=literal-1 ~ ~] [n=literal-1 ~ ~]]
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
              literal-value-1
              ==
            [~.ud 3]
    :-  %multiplication-literal-embedded-scalar
        :-  :*  %arithmetic
              %tar
              literal-value-1
              :^  %if-then-else
                  if=[n=%eq [n=literal-1 ~ ~] [n=literal-1 ~ ~]]
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
    ::  division tests
    :-  %division-embedded-scalar-literal
        :-  :*  %arithmetic
              %fas
              :^  %if-then-else
                  if=[n=%eq [n=literal-1 ~ ~] [n=literal-1 ~ ~]]
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
              literal-value-1
              ==
            [~.ud 3]
    :-  %division-literal-embedded-scalar
        :-  :*  %arithmetic
              %fas
              literal-value-1
              :^  %if-then-else
                  if=[n=%eq [n=literal-1 ~ ~] [n=literal-1 ~ ~]]
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
            [~.ud 0]
    ::  exponentiation tests
    :-  %exponentiation-embedded-scalar-literal
        :-  :*  %arithmetic
              %ket
              :^  %if-then-else
                  if=[n=%eq [n=literal-1 ~ ~] [n=literal-1 ~ ~]]
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
              literal-value-2
              ==
            [~.ud 9]
    :-  %exponentiation-literal-embedded-scalar
        :-  :*  %arithmetic
              %ket
              literal-value-2
              :^  %if-then-else
                  if=[n=%eq [n=literal-1 ~ ~] [n=literal-1 ~ ~]]
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
            [~.ud 8]
    ==
  ==
--
