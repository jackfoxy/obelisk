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
::  table testing harness
::
++  type-lookup  %-  mk-qualified-type-lookup
                          :~  :-  qualified-table-1
                                  %-  addr-columns
                                      :~  [%column %col1 ~.ud 0]
                                          [%column %col2 ~.ud 0]
                                          [%column %col3 ~.ud 0]
                                          [%column %col4 ~.ud 0]
                                          [%column %col5 ~.ud 0]
                                          [%column %col6 ~.ud 0]
                                          ==
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
++  scalars           %-  malt
                           %-  limo
                           :~
                             :: evals to 3
                             :-  %scalar1
                             :*  %if-then-else
                               if=true-predicate
                               then=[arithmetic-q-col-3]
                               else=[arithmetic-q-col-2]
                             ==
                           ==
::
+$  table-test-row  $:  operator=arithmetic-op:ast
                      left=datum-or-scalar:ast
                      right=datum-or-scalar:ast
                      expected=dime
                    ==
::
++  table-test-helper
  |=  [row=table-test-row]
  =/  when-lookups  [qualifier-lookup type-lookup]
  =/  expr=arithmetic:ast  :*  %arithmetic
                             operator=operator.row
                             left=left.row
                             right=right.row
                           ==
  =/  scalar-to-apply
    (prepare-scalar expr ctes when-lookups scalars)
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
++  arithmetic-q-col-1                  [%qualified-column qualified-table-1 %col1 ~]
++  arithmetic-q-col-2                  [%qualified-column qualified-table-1 %col2 ~]
++  arithmetic-q-col-3                  [%qualified-column qualified-table-1 %col3 ~]
::
++  arithmetic-u-col-4                  [%unqualified-column %col4 ~]
++  arithmetic-u-col-5                  [%unqualified-column %col5 ~]
++  arithmetic-u-col-6                  [%unqualified-column %col6 ~]
::
::
::
::++  test-arithmetic
::  %-  run-tests
::  :~
::    ::  addition tests
::    :-  %addition-literal-literal
::    :*  %lus
::      literal-value-1
::      literal-value-1
::      [~.ud 2]
::    ==
::    :-  %addition-qualified-col-literal
::    :*  %lus
::      arithmetic-q-col-1
::      literal-value-1
::      [~.ud 2]
::    ==
::    :-  %addition-unqualified-col-literal
::    :*  %lus
::      arithmetic-u-col-4
::      literal-value-1
::      [~.ud 5]
::    ==
::    :-  %addition-scalar-name-literal
::    :*  %lus
::      [%scalar-name %scalar1]
::      literal-value-1
::      [~.ud 4]
::    ==
::    :-  %addition-embedded-scalar-literal
::    :*  %lus
::      (~(got by scalars) %scalar1)
::      literal-value-1
::      [~.ud 4]
::    ==
::    :-  %addition-literal-qualified-col
::    :*  %lus
::      literal-value-1
::      arithmetic-q-col-1
::      [~.ud 2]
::    ==
::    :-  %addition-literal-unqualified-col
::    :*  %lus
::      literal-value-1
::      arithmetic-u-col-4
::      [~.ud 5]
::    ==
::    :-  %addition-literal-scalar-name
::    :*  %lus
::      literal-value-1
::      [%scalar-name %scalar1]
::      [~.ud 4]
::    ==
::    :-  %addition-literal-embedded-scalar
::    :*  %lus
::      literal-value-1
::      (~(got by scalars) %scalar1)
::      [~.ud 4]
::    ==
::    ::  subtraction tests
::    :-  %subtraction-literal-literal
::    :*  %hep
::      literal-value-2
::      literal-value-1
::      [~.ud 1]
::    ==
::    :-  %subtraction-qualified-col-literal
::    :*  %hep
::      arithmetic-q-col-1
::      literal-value-1
::      [~.ud 0]
::    ==
::    :-  %subtraction-unqualified-col-literal
::    :*  %hep
::      arithmetic-u-col-5
::      literal-value-1
::      [~.ud 4]
::    ==
::    :-  %subtraction-scalar-name-literal
::    :*  %hep
::      [%scalar-name %scalar1]
::      literal-value-1
::      [~.ud 2]
::    ==
::    :-  %subtraction-embedded-scalar-literal
::    :*  %hep
::      (~(got by scalars) %scalar1)
::      literal-value-1
::      [~.ud 2]
::    ==
::    :-  %subtraction-literal-qualified-col
::    :*  %hep
::      literal-value-1
::      arithmetic-q-col-1
::      [~.ud 0]
::    ==
::    :-  %subtraction-literal-unqualified-col
::    :*  %hep
::      [%literal-value [~.ud 9]]
::      arithmetic-u-col-5
::      [~.ud 4]
::    ==
::    :-  %subtraction-literal-scalar-name
::    :*  %hep
::      [%literal-value [~.ud 5]]
::      [%scalar-name %scalar1]
::      [~.ud 2]
::    ==
::    :-  %subtraction-literal-embedded-scalar
::    :*  %hep
::      [%literal-value [~.ud 5]]
::      (~(got by scalars) %scalar1)
::      [~.ud 2]
::    ==
::    ::  multiplication tests
::    :-  %multiplication-literal-literal
::    :*  %tar
::      literal-value-2
::      literal-value-2
::      [~.ud 4]
::    ==
::    :-  %multiplication-qualified-col-literal
::    :*  %tar
::      arithmetic-q-col-2
::      literal-value-1
::      [~.ud 2]
::    ==
::    :-  %multiplication-unqualified-col-literal
::    :*  %tar
::      arithmetic-u-col-5
::      literal-value-1
::      [~.ud 5]
::    ==
::    :-  %multiplication-scalar-name-literal
::    :*  %tar
::      [%scalar-name %scalar1]
::      literal-value-1
::      [~.ud 3]
::    ==
::    :-  %multiplication-embedded-scalar-literal
::    :*  %tar
::      (~(got by scalars) %scalar1)
::      literal-value-1
::      [~.ud 3]
::    ==
::    :-  %multiplication-literal-qualified-col
::    :*  %tar
::      literal-value-1
::      arithmetic-q-col-2
::      [~.ud 2]
::    ==
::    :-  %multiplication-literal-unqualified-col
::    :*  %tar
::      literal-value-1
::      arithmetic-u-col-5
::      [~.ud 5]
::    ==
::    :-  %multiplication-literal-scalar-name
::    :*  %tar
::      literal-value-1
::      [%scalar-name %scalar1]
::      [~.ud 3]
::    ==
::    :-  %multiplication-literal-embedded-scalar
::    :*  %tar
::      literal-value-1
::      (~(got by scalars) %scalar1)
::      [~.ud 3]
::    ==
::    ::  division tests
::    :-  %division-literal-literal
::    :*  %fas
::      literal-value-2
::      literal-value-2
::      [~.ud 1]
::    ==
::    :-  %division-qualified-col-literal
::    :*  %fas
::      arithmetic-q-col-2
::      literal-value-1
::      [~.ud 2]
::    ==
::    :-  %division-unqualified-col-literal
::    :*  %fas
::      arithmetic-u-col-5
::      literal-value-1
::      [~.ud 5]
::    ==
::    :-  %division-scalar-name-literal
::    :*  %fas
::      [%scalar-name %scalar1]
::      literal-value-1
::      [~.ud 3]
::    ==
::    :-  %division-embedded-scalar-literal
::    :*  %fas
::      (~(got by scalars) %scalar1)
::      literal-value-1
::      [~.ud 3]
::    ==
::    :-  %division-literal-qualified-col
::    :*  %fas
::      literal-value-1
::      arithmetic-q-col-2
::      [~.ud 0]
::    ==
::    :-  %division-literal-unqualified-col
::    :*  %fas
::      literal-value-1
::      arithmetic-u-col-5
::      [~.ud 0]
::    ==
::    :-  %division-literal-scalar-name
::    :*  %fas
::      literal-value-1
::      [%scalar-name %scalar1]
::      [~.ud 0]
::    ==
::    :-  %division-literal-embedded-scalar
::    :*  %fas
::      literal-value-1
::      (~(got by scalars) %scalar1)
::      [~.ud 0]
::    ==
::    ::  exponentiation tests
::    :-  %exponentiation-literal-literal
::    :*  %ket
::      [%literal-value [~.ud 3]]
::      literal-value-2
::      [~.ud 9]
::    ==
::    :-  %exponentiation-qualified-col-literal
::    :*  %ket
::      arithmetic-q-col-2
::      literal-value-1
::      [~.ud 2]
::    ==
::    :-  %exponentiation-unqualified-col-literal
::    :*  %ket
::      arithmetic-u-col-5
::      literal-value-2
::      [~.ud 25]
::    ==
::    :-  %exponentiation-scalar-name-literal
::    :*  %ket
::      [%scalar-name %scalar1]
::      literal-value-2
::      [~.ud 9]
::    ==
::    :-  %exponentiation-embedded-scalar-literal
::    :*  %ket
::      (~(got by scalars) %scalar1)
::      literal-value-2
::      [~.ud 9]
::    ==
::    :-  %exponentiation-literal-qualified-col
::    :*  %ket
::      literal-value-2
::      arithmetic-q-col-2
::      [~.ud 4]
::    ==
::    :-  %exponentiation-literal-unqualified-col
::    :*  %ket
::      literal-value-2
::      arithmetic-u-col-5
::      [~.ud 32]
::    ==
::    :-  %exponentiation-literal-scalar-name
::    :*  %ket
::      literal-value-2
::      [%scalar-name %scalar1]
::      [~.ud 8]
::    ==
::    :-  %exponentiation-literal-embedded-scalar
::    :*  %ket
::      literal-value-2
::      (~(got by scalars) %scalar1)
::      [~.ud 8]
::    ==
::  ==
--
