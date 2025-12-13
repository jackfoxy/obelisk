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
++  true-predicate         [n=%eq [n=[~.ud 1] ~ ~] [n=[~.ud 1] ~ ~]]
++  false-predicate         [n=%eq [n=[~.ud 1] ~ ~] [n=[~.ud 0] ~ ~]]
::
++  literal-1             [%literal-value [~.ud 1]]
++  literal-2             [%literal-value [~.ud 2]]
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
::  - DONE:              
::  - MISSING:          %eq %neq %gte %gt %lte %lt %in %not-in %between
::                      %not-between %and %or
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
+$  pred-test-row  $:  target=(unit datum-or-scalar:ast)
                     case=case-when-then:ast     
                     else=(unit datum-or-scalar:ast)
                     expected=dime
                   ==
::
++  pred-test-helper
  |=  [row=pred-test-row]
  =/  pred-lookups  [pred-qualifier-lookup pred-qual-type-lookup]
  =/  case-expr=case:ast  [%case target=target.row cases=~[case.row] else=else.row]
  =/  scalar-to-apply
    (prepare-scalar case-expr pred-named-ctes pred-lookups pred-scalars)
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
++  test-case-predicate-eq
  %-  pred-row-test
  :~
    :-  %searched-eq-dime-dime
    :*  ~
      [%case-when-then [%eq [[~.ud 1] ~ ~] [[~.ud 1] ~ ~]] then-q-col-1]
      (some then-q-col-2)
      [~.ud 1]
    ==
    :-  %searched-eq-qualified-col-dime
    :*  ~
      [%case-when-then [%eq [pred-q-col-1 ~ ~] [[~.ud 1] ~ ~]] then-q-col-1]
      (some then-q-col-2)
      [~.ud 1]
    ==
    :-  %searched-eq-dime-qualified-col
    :*  ~
      [%case-when-then [%eq [[~.ud 1] ~ ~] [pred-q-col-1 ~ ~]] then-q-col-1]
      (some then-q-col-2)
      [~.ud 1]
    ==
    :-  %searched-eq-unqualified-col-dime
    :*  ~
      [%case-when-then [%eq [pred-u-col-4 ~ ~] [[~.ud 4] ~ ~]] then-u-col-4]
      (some then-u-col-5)
      [~.ud 4]
    ==
    :-  %searched-eq-dime-unqualified-col
    :*  ~
      [%case-when-then [%eq [[~.ud 4] ~ ~] [pred-u-col-4 ~ ~]] then-u-col-4]
      (some then-u-col-5)
      [~.ud 4]
    ==
    :-  %simple-eq-dime-dime
    :*  (some [%literal-value [~.ud 1]])
      [%case-when-then literal-1 then-q-col-1]
      (some then-q-col-2)
      [~.ud 1]
    ==
    :-  %simple-eq-qualified-col-dime
    :*  (some pred-q-col-1)
      [%case-when-then literal-1 then-q-col-1]
      (some then-q-col-2)
      [~.ud 1]
    ==
    :-  %simple-eq-dime-qualified-col
    :*  (some [%literal-value [~.ud 1]])
      [%case-when-then pred-q-col-1 then-q-col-1]
      (some then-q-col-2)
      [~.ud 1]
    ==
    :-  %simple-eq-unqualified-col-dime
    :*  (some pred-u-col-4)
      [%case-when-then [%literal-value [~.ud 4]] then-u-col-4]
      (some then-u-col-5)
      [~.ud 4]
    ==
    :-  %simple-eq-dime-unqualified-col
    :*  (some [%literal-value [~.ud 4]])
      [%case-when-then pred-u-col-4 then-u-col-4]
      (some then-u-col-5)
      [~.ud 4]
    ==
  ==
::
::  %neq tests
::
++  test-case-predicate-neq
  %-  pred-row-test
  :~
    :-  %searched-neq-dimes
    :*  ~
      [%case-when-then [%neq [[~.ud 1] ~ ~] [[~.ud 2] ~ ~]] then-q-col-1]
      (some then-q-col-2)
      [~.ud 1]
    ==
    :-  %searched-neq-qualified-columns
    :*  ~
      [%case-when-then [%neq [pred-q-col-1 ~ ~] [pred-q-col-2 ~ ~]] then-q-col-1]
      (some then-q-col-2)
      [~.ud 1]
    ==
    :-  %searched-neq-qualified-col-dime
    :*  ~
      [%case-when-then [%neq [pred-q-col-1 ~ ~] [[~.ud 2] ~ ~]] then-q-col-1]
      (some then-q-col-2)
      [~.ud 1]
    ==
    :-  %searched-neq-dime-qualified-col
    :*  ~
      [%case-when-then [%neq [[~.ud 2] ~ ~] [pred-q-col-1 ~ ~]] then-q-col-1]
      (some then-q-col-2)
      [~.ud 1]
    ==
    :-  %searched-neq-unqualified-columns
    :*  ~
      [%case-when-then [%neq [pred-u-col-4 ~ ~] [pred-u-col-5 ~ ~]] then-u-col-4]
      (some then-u-col-5)
      [~.ud 4]
    ==
    :-  %searched-neq-unqualified-col-dime
    :*  ~
      [%case-when-then [%neq [pred-u-col-4 ~ ~] [[~.ud 5] ~ ~]] then-u-col-4]
      (some then-u-col-5)
      [~.ud 4]
    ==
    :-  %searched-neq-dime-unqualified-col
    :*  ~
      [%case-when-then [%neq [[~.ud 5] ~ ~] [pred-u-col-4 ~ ~]] then-u-col-4]
      (some then-u-col-5)
      [~.ud 4]
    ==
    :-  %simple-neq-dimes
    :*  (some [%literal-value [~.ud 1]])
      [%case-when-then [%literal-value [~.ud 2]] then-q-col-1]
      (some then-q-col-2)
      [~.ud 1]
    ==
    :-  %simple-neq-qualified-columns
    :*  (some pred-q-col-1)
      [%case-when-then pred-q-col-2 then-q-col-1]
      (some then-q-col-2)
      [~.ud 1]
    ==
    :-  %simple-neq-qualified-col-dime
    :*  (some pred-q-col-1)
      [%case-when-then [%literal-value [~.ud 2]] then-q-col-1]
      (some then-q-col-2)
      [~.ud 1]
    ==
    :-  %simple-neq-dime-qualified-col
    :*  (some [%literal-value [~.ud 2]])
      [%case-when-then pred-q-col-1 then-q-col-1]
      (some then-q-col-2)
      [~.ud 1]
    ==
    :-  %simple-neq-unqualified-columns
    :*  (some pred-u-col-4)
      [%case-when-then pred-u-col-5 then-u-col-4]
      (some then-u-col-5)
      [~.ud 4]
    ==
    :-  %simple-neq-unqualified-col-dime
    :*  (some pred-u-col-4)
      [%case-when-then [%literal-value [~.ud 5]] then-u-col-4]
      (some then-u-col-5)
      [~.ud 4]
    ==
    :-  %simple-neq-dime-unqualified-col
    :*  (some [%literal-value [~.ud 5]])
      [%case-when-then pred-u-col-4 then-u-col-4]
      (some then-u-col-5)
      [~.ud 4]
    ==
  ==
::
::  %gte tests
::
++  test-case-predicate-gte
  %-  pred-row-test
  :~
    :-  %searched-gte-dimes-gt
    :*  ~
      [%case-when-then [%gte [[~.ud 2] ~ ~] [[~.ud 1] ~ ~]] then-q-col-1]
      (some then-q-col-2)
      [~.ud 1]
    ==
    :-  %searched-gte-dimes-eq
    :*  ~
      [%case-when-then [%gte [[~.ud 1] ~ ~] [[~.ud 1] ~ ~]] then-q-col-1]
      (some then-q-col-2)
      [~.ud 1]
    ==
    :-  %searched-gte-qualified-columns-gt
    :*  ~
      [%case-when-then [%gte [pred-q-col-2 ~ ~] [pred-q-col-1 ~ ~]] then-q-col-1]
      (some then-q-col-2)
      [~.ud 1]
    ==
    :-  %searched-gte-qualified-columns-eq
    :*  ~
      [%case-when-then [%gte [pred-q-col-1 ~ ~] [pred-q-col-1 ~ ~]] then-q-col-1]
      (some then-q-col-2)
      [~.ud 1]
    ==
    :-  %searched-gte-qualified-col-dime-gt
    :*  ~
      [%case-when-then [%gte [pred-q-col-2 ~ ~] [[~.ud 1] ~ ~]] then-q-col-1]
      (some then-q-col-2)
      [~.ud 1]
    ==
    :-  %searched-gte-qualified-col-dime-eq
    :*  ~
      [%case-when-then [%gte [pred-q-col-1 ~ ~] [[~.ud 1] ~ ~]] then-q-col-1]
      (some then-q-col-2)
      [~.ud 1]
    ==
    :-  %searched-gte-dime-qualified-col-gt
    :*  ~
      [%case-when-then [%gte [[~.ud 2] ~ ~] [pred-q-col-1 ~ ~]] then-q-col-1]
      (some then-q-col-2)
      [~.ud 1]
    ==
    :-  %searched-gte-dime-qualified-col-eq
    :*  ~
      [%case-when-then [%gte [[~.ud 1] ~ ~] [pred-q-col-1 ~ ~]] then-q-col-1]
      (some then-q-col-2)
      [~.ud 1]
    ==
    :-  %searched-gte-unqualified-columns-gt
    :*  ~
      [%case-when-then [%gte [pred-u-col-5 ~ ~] [pred-u-col-4 ~ ~]] then-u-col-4]
      (some then-u-col-5)
      [~.ud 4]
    ==
    :-  %searched-gte-unqualified-columns-eq
    :*  ~
      [%case-when-then [%gte [pred-u-col-4 ~ ~] [pred-u-col-4 ~ ~]] then-u-col-4]
      (some then-u-col-5)
      [~.ud 4]
    ==
    :-  %searched-gte-unqualified-col-dime-gt
    :*  ~
      [%case-when-then [%gte [pred-u-col-5 ~ ~] [[~.ud 4] ~ ~]] then-u-col-4]
      (some then-u-col-5)
      [~.ud 4]
    ==
    :-  %searched-gte-unqualified-col-dime-eq
    :*  ~
      [%case-when-then [%gte [pred-u-col-4 ~ ~] [[~.ud 4] ~ ~]] then-u-col-4]
      (some then-u-col-5)
      [~.ud 4]
    ==
    :-  %searched-gte-dime-unqualified-col-gt
    :*  ~
      [%case-when-then [%gte [[~.ud 5] ~ ~] [pred-u-col-4 ~ ~]] then-u-col-4]
      (some then-u-col-5)
      [~.ud 4]
    ==
    :-  %searched-gte-dime-unqualified-col-eq
    :*  ~
      [%case-when-then [%gte [[~.ud 4] ~ ~] [pred-u-col-4 ~ ~]] then-u-col-4]
      (some then-u-col-5)
      [~.ud 4]
    ==
    :-  %simple-gte-dimes-gt
    :*  (some [%literal-value [~.ud 2]])
      [%case-when-then [%literal-value [~.ud 1]] then-q-col-1]
      (some then-q-col-2)
      [~.ud 1]
    ==
    :-  %simple-gte-dimes-eq
    :*  (some [%literal-value [~.ud 1]])
      [%case-when-then [%literal-value [~.ud 1]] then-q-col-1]
      (some then-q-col-2)
      [~.ud 1]
    ==
    :-  %simple-gte-qualified-columns-gt
    :*  (some pred-q-col-2)
      [%case-when-then pred-q-col-1 then-q-col-1]
      (some then-q-col-2)
      [~.ud 1]
    ==
    :-  %simple-gte-qualified-columns-eq
    :*  (some pred-q-col-1)
      [%case-when-then pred-q-col-1 then-q-col-1]
      (some then-q-col-2)
      [~.ud 1]
    ==
    :-  %simple-gte-qualified-col-dime-gt
    :*  (some pred-q-col-2)
      [%case-when-then [%literal-value [~.ud 1]] then-q-col-1]
      (some then-q-col-2)
      [~.ud 1]
    ==
    :-  %simple-gte-qualified-col-dime-eq
    :*  (some pred-q-col-1)
      [%case-when-then [%literal-value [~.ud 1]] then-q-col-1]
      (some then-q-col-2)
      [~.ud 1]
    ==
    :-  %simple-gte-dime-qualified-col-gt
    :*  (some [%literal-value [~.ud 2]])
      [%case-when-then pred-q-col-1 then-q-col-1]
      (some then-q-col-2)
      [~.ud 1]
    ==
    :-  %simple-gte-dime-qualified-col-eq
    :*  (some [%literal-value [~.ud 1]])
      [%case-when-then pred-q-col-1 then-q-col-1]
      (some then-q-col-2)
      [~.ud 1]
    ==
    :-  %simple-gte-unqualified-columns-gt
    :*  (some pred-u-col-5)
      [%case-when-then pred-u-col-4 then-u-col-4]
      (some then-u-col-5)
      [~.ud 4]
    ==
    :-  %simple-gte-unqualified-columns-eq
    :*  (some pred-u-col-4)
      [%case-when-then pred-u-col-4 then-u-col-4]
      (some then-u-col-5)
      [~.ud 4]
    ==
    :-  %simple-gte-unqualified-col-dime-gt
    :*  (some pred-u-col-5)
      [%case-when-then [%literal-value [~.ud 4]] then-u-col-4]
      (some then-u-col-5)
      [~.ud 4]
    ==
    :-  %simple-gte-unqualified-col-dime-eq
    :*  (some pred-u-col-4)
      [%case-when-then [%literal-value [~.ud 4]] then-u-col-4]
      (some then-u-col-5)
      [~.ud 4]
    ==
    :-  %simple-gte-dime-unqualified-col-gt
    :*  (some [%literal-value [~.ud 5]])
      [%case-when-then pred-u-col-4 then-u-col-4]
      (some then-u-col-5)
      [~.ud 4]
    ==
    :-  %simple-gte-dime-unqualified-col-eq
    :*  (some [%literal-value [~.ud 4]])
      [%case-when-then pred-u-col-4 then-u-col-4]
      (some then-u-col-5)
      [~.ud 4]
    ==
  ==
::
::  %gt tests
::
++  test-case-predicate-gt
  %-  pred-row-test
  :~
    :-  %searched-gt-dimes-gt
    :*  ~
      [%case-when-then [%gt [[~.ud 2] ~ ~] [[~.ud 1] ~ ~]] then-q-col-1]
      (some then-q-col-2)
      [~.ud 1]
    ==
    :-  %searched-gt-qualified-columns-gt
    :*  ~
      [%case-when-then [%gt [pred-q-col-2 ~ ~] [pred-q-col-1 ~ ~]] then-q-col-1]
      (some then-q-col-2)
      [~.ud 1]
    ==
    :-  %searched-gt-qualified-col-dime-gt
    :*  ~
      [%case-when-then [%gt [pred-q-col-2 ~ ~] [[~.ud 1] ~ ~]] then-q-col-1]
      (some then-q-col-2)
      [~.ud 1]
    ==
    :-  %searched-gt-dime-qualified-col-gt
    :*  ~
      [%case-when-then [%gt [[~.ud 2] ~ ~] [pred-q-col-1 ~ ~]] then-q-col-1]
      (some then-q-col-2)
      [~.ud 1]
    ==
    :-  %searched-gt-unqualified-columns-gt
    :*  ~
      [%case-when-then [%gt [pred-u-col-5 ~ ~] [pred-u-col-4 ~ ~]] then-u-col-4]
      (some then-u-col-5)
      [~.ud 4]
    ==
    :-  %searched-gt-unqualified-col-dime-gt
    :*  ~
      [%case-when-then [%gt [pred-u-col-5 ~ ~] [[~.ud 4] ~ ~]] then-u-col-4]
      (some then-u-col-5)
      [~.ud 4]
    ==
    :-  %searched-gt-dime-unqualified-col-gt
    :*  ~
      [%case-when-then [%gt [[~.ud 5] ~ ~] [pred-u-col-4 ~ ~]] then-u-col-4]
      (some then-u-col-5)
      [~.ud 4]
    ==
    :-  %simple-gt-dimes-gt
    :*  (some [%literal-value [~.ud 2]])
      [%case-when-then [%literal-value [~.ud 1]] then-q-col-1]
      (some then-q-col-2)
      [~.ud 1]
    ==
    :-  %simple-gt-qualified-columns-gt
    :*  (some pred-q-col-2)
      [%case-when-then pred-q-col-1 then-q-col-1]
      (some then-q-col-2)
      [~.ud 1]
    ==
    :-  %simple-gt-qualified-col-dime-gt
    :*  (some pred-q-col-2)
      [%case-when-then [%literal-value [~.ud 1]] then-q-col-1]
      (some then-q-col-2)
      [~.ud 1]
    ==
    :-  %simple-gt-dime-qualified-col-gt
    :*  (some [%literal-value [~.ud 2]])
      [%case-when-then pred-q-col-1 then-q-col-1]
      (some then-q-col-2)
      [~.ud 1]
    ==
    :-  %simple-gt-unqualified-columns-gt
    :*  (some pred-u-col-5)
      [%case-when-then pred-u-col-4 then-u-col-4]
      (some then-u-col-5)
      [~.ud 4]
    ==
    :-  %simple-gt-unqualified-col-dime-gt
    :*  (some pred-u-col-5)
      [%case-when-then [%literal-value [~.ud 4]] then-u-col-4]
      (some then-u-col-5)
      [~.ud 4]
    ==
    :-  %simple-gt-dime-unqualified-col-gt
    :*  (some [%literal-value [~.ud 5]])
      [%case-when-then pred-u-col-4 then-u-col-4]
      (some then-u-col-5)
      [~.ud 4]
    ==
  ==
::
::  %lte tests
::
++  test-case-predicate-lte
  %-  pred-row-test
  :~
    :-  %searched-lte-dimes-lt
    :*  ~
      [%case-when-then [%lte [[~.ud 1] ~ ~] [[~.ud 2] ~ ~]] then-q-col-1]
      (some then-q-col-2)
      [~.ud 1]
    ==
    :-  %searched-lte-dimes-eq
    :*  ~
      [%case-when-then [%lte [[~.ud 1] ~ ~] [[~.ud 1] ~ ~]] then-q-col-1]
      (some then-q-col-2)
      [~.ud 1]
    ==
    :-  %searched-lte-qualified-columns-lt
    :*  ~
      [%case-when-then [%lte [pred-q-col-1 ~ ~] [pred-q-col-2 ~ ~]] then-q-col-1]
      (some then-q-col-2)
      [~.ud 1]
    ==
    :-  %searched-lte-qualified-columns-eq
    :*  ~
      [%case-when-then [%lte [pred-q-col-1 ~ ~] [pred-q-col-1 ~ ~]] then-q-col-1]
      (some then-q-col-2)
      [~.ud 1]
    ==
    :-  %searched-lte-qualified-col-dime-lt
    :*  ~
      [%case-when-then [%lte [pred-q-col-1 ~ ~] [[~.ud 2] ~ ~]] then-q-col-1]
      (some then-q-col-2)
      [~.ud 1]
    ==
    :-  %searched-lte-qualified-col-dime-eq
    :*  ~
      [%case-when-then [%lte [pred-q-col-1 ~ ~] [[~.ud 1] ~ ~]] then-q-col-1]
      (some then-q-col-2)
      [~.ud 1]
    ==
    :-  %searched-lte-dime-qualified-col-lt
    :*  ~
      [%case-when-then [%lte [[~.ud 1] ~ ~] [pred-q-col-2 ~ ~]] then-q-col-1]
      (some then-q-col-2)
      [~.ud 1]
    ==
    :-  %searched-lte-dime-qualified-col-eq
    :*  ~
      [%case-when-then [%lte [[~.ud 1] ~ ~] [pred-q-col-1 ~ ~]] then-q-col-1]
      (some then-q-col-2)
      [~.ud 1]
    ==
    :-  %searched-lte-unqualified-columns-lt
    :*  ~
      [%case-when-then [%lte [pred-u-col-4 ~ ~] [pred-u-col-5 ~ ~]] then-u-col-4]
      (some then-u-col-5)
      [~.ud 4]
    ==
    :-  %searched-lte-unqualified-columns-eq
    :*  ~
      [%case-when-then [%lte [pred-u-col-4 ~ ~] [pred-u-col-4 ~ ~]] then-u-col-4]
      (some then-u-col-5)
      [~.ud 4]
    ==
    :-  %searched-lte-unqualified-col-dime-lt
    :*  ~
      [%case-when-then [%lte [pred-u-col-4 ~ ~] [[~.ud 5] ~ ~]] then-u-col-4]
      (some then-u-col-5)
      [~.ud 4]
    ==
    :-  %searched-lte-unqualified-col-dime-eq
    :*  ~
      [%case-when-then [%lte [pred-u-col-4 ~ ~] [[~.ud 4] ~ ~]] then-u-col-4]
      (some then-u-col-5)
      [~.ud 4]
    ==
    :-  %searched-lte-dime-unqualified-col-lt
    :*  ~
      [%case-when-then [%lte [[~.ud 4] ~ ~] [pred-u-col-5 ~ ~]] then-u-col-4]
      (some then-u-col-5)
      [~.ud 4]
    ==
    :-  %searched-lte-dime-unqualified-col-eq
    :*  ~
      [%case-when-then [%lte [[~.ud 4] ~ ~] [pred-u-col-4 ~ ~]] then-u-col-4]
      (some then-u-col-5)
      [~.ud 4]
    ==
    :-  %simple-lte-dimes-lt
    :*  (some [%literal-value [~.ud 1]])
      [%case-when-then [%literal-value [~.ud 2]] then-q-col-1]
      (some then-q-col-2)
      [~.ud 1]
    ==
    :-  %simple-lte-dimes-eq
    :*  (some [%literal-value [~.ud 1]])
      [%case-when-then [%literal-value [~.ud 1]] then-q-col-1]
      (some then-q-col-2)
      [~.ud 1]
    ==
    :-  %simple-lte-qualified-columns-lt
    :*  (some pred-q-col-1)
      [%case-when-then pred-q-col-2 then-q-col-1]
      (some then-q-col-2)
      [~.ud 1]
    ==
    :-  %simple-lte-qualified-columns-eq
    :*  (some pred-q-col-1)
      [%case-when-then pred-q-col-1 then-q-col-1]
      (some then-q-col-2)
      [~.ud 1]
    ==
    :-  %simple-lte-qualified-col-dime-lt
    :*  (some pred-q-col-1)
      [%case-when-then [%literal-value [~.ud 2]] then-q-col-1]
      (some then-q-col-2)
      [~.ud 1]
    ==
    :-  %simple-lte-qualified-col-dime-eq
    :*  (some pred-q-col-1)
      [%case-when-then [%literal-value [~.ud 1]] then-q-col-1]
      (some then-q-col-2)
      [~.ud 1]
    ==
    :-  %simple-lte-dime-qualified-col-lt
    :*  (some [%literal-value [~.ud 1]])
      [%case-when-then pred-q-col-2 then-q-col-1]
      (some then-q-col-2)
      [~.ud 1]
    ==
    :-  %simple-lte-dime-qualified-col-eq
    :*  (some [%literal-value [~.ud 1]])
      [%case-when-then pred-q-col-1 then-q-col-1]
      (some then-q-col-2)
      [~.ud 1]
    ==
    :-  %simple-lte-unqualified-columns-lt
    :*  (some pred-u-col-4)
      [%case-when-then pred-u-col-5 then-u-col-4]
      (some then-u-col-5)
      [~.ud 4]
    ==
    :-  %simple-lte-unqualified-columns-eq
    :*  (some pred-u-col-4)
      [%case-when-then pred-u-col-4 then-u-col-4]
      (some then-u-col-5)
      [~.ud 4]
    ==
    :-  %simple-lte-unqualified-col-dime-lt
    :*  (some pred-u-col-4)
      [%case-when-then [%literal-value [~.ud 5]] then-u-col-4]
      (some then-u-col-5)
      [~.ud 4]
    ==
    :-  %simple-lte-unqualified-col-dime-eq
    :*  (some pred-u-col-4)
      [%case-when-then [%literal-value [~.ud 4]] then-u-col-4]
      (some then-u-col-5)
      [~.ud 4]
    ==
    :-  %simple-lte-dime-unqualified-col-lt
    :*  (some [%literal-value [~.ud 4]])
      [%case-when-then pred-u-col-5 then-u-col-4]
      (some then-u-col-5)
      [~.ud 4]
    ==
    :-  %simple-lte-dime-unqualified-col-eq
    :*  (some [%literal-value [~.ud 4]])
      [%case-when-then pred-u-col-4 then-u-col-4]
      (some then-u-col-5)
      [~.ud 4]
    ==
  ==
::
::  %lt tests
::
++  test-case-predicate-lt
  %-  pred-row-test
  :~
    :-  %searched-lt-dimes-lt
    :*  ~
      [%case-when-then [%lt [[~.ud 1] ~ ~] [[~.ud 2] ~ ~]] then-q-col-1]
      (some then-q-col-2)
      [~.ud 1]
    ==
    :-  %searched-lt-qualified-columns-lt
    :*  ~
      [%case-when-then [%lt [pred-q-col-1 ~ ~] [pred-q-col-2 ~ ~]] then-q-col-1]
      (some then-q-col-2)
      [~.ud 1]
    ==
    :-  %searched-lt-qualified-col-dime-lt
    :*  ~
      [%case-when-then [%lt [pred-q-col-1 ~ ~] [[~.ud 2] ~ ~]] then-q-col-1]
      (some then-q-col-2)
      [~.ud 1]
    ==
    :-  %searched-lt-dime-qualified-col-lt
    :*  ~
      [%case-when-then [%lt [[~.ud 1] ~ ~] [pred-q-col-2 ~ ~]] then-q-col-1]
      (some then-q-col-2)
      [~.ud 1]
    ==
    :-  %searched-lt-unqualified-columns-lt
    :*  ~
      [%case-when-then [%lt [pred-u-col-4 ~ ~] [pred-u-col-5 ~ ~]] then-u-col-4]
      (some then-u-col-5)
      [~.ud 4]
    ==
    :-  %searched-lt-unqualified-col-dime-lt
    :*  ~
      [%case-when-then [%lt [pred-u-col-4 ~ ~] [[~.ud 5] ~ ~]] then-u-col-4]
      (some then-u-col-5)
      [~.ud 4]
    ==
    :-  %searched-lt-dime-unqualified-col-lt
    :*  ~
      [%case-when-then [%lt [[~.ud 4] ~ ~] [pred-u-col-5 ~ ~]] then-u-col-4]
      (some then-u-col-5)
      [~.ud 4]
    ==
    :-  %simple-lt-dimes-lt
    :*  (some [%literal-value [~.ud 1]])
      [%case-when-then [%literal-value [~.ud 2]] then-q-col-1]
      (some then-q-col-2)
      [~.ud 1]
    ==
    :-  %simple-lt-qualified-columns-lt
    :*  (some pred-q-col-1)
      [%case-when-then pred-q-col-2 then-q-col-1]
      (some then-q-col-2)
      [~.ud 1]
    ==
    :-  %simple-lt-qualified-col-dime-lt
    :*  (some pred-q-col-1)
      [%case-when-then [%literal-value [~.ud 2]] then-q-col-1]
      (some then-q-col-2)
      [~.ud 1]
    ==
    :-  %simple-lt-dime-qualified-col-lt
    :*  (some [%literal-value [~.ud 1]])
      [%case-when-then pred-q-col-2 then-q-col-1]
      (some then-q-col-2)
      [~.ud 1]
    ==
    :-  %simple-lt-unqualified-columns-lt
    :*  (some pred-u-col-4)
      [%case-when-then pred-u-col-5 then-u-col-4]
      (some then-u-col-5)
      [~.ud 4]
    ==
    :-  %simple-lt-unqualified-col-dime-lt
    :*  (some pred-u-col-4)
      [%case-when-then [%literal-value [~.ud 5]] then-u-col-4]
      (some then-u-col-5)
      [~.ud 4]
    ==
    :-  %simple-lt-dime-unqualified-col-lt
    :*  (some [%literal-value [~.ud 4]])
      [%case-when-then pred-u-col-5 then-u-col-4]
      (some then-u-col-5)
      [~.ud 4]
    ==
  ==
::
::  %in tests
::
++  test-case-predicate-in
  %-  pred-row-test
  :~
    :-  %searched-in-dime
    :*  ~
      [%case-when-then [%in [[~.ud 1] ~ ~] [[%value-literals [~.ud '1;2;4;5']] ~ ~]] then-q-col-1]
      (some then-q-col-2)
      [~.ud 1]
    ==
    :-  %searched-in-qualified-col
    :*  ~
      [%case-when-then [%in [pred-q-col-1 ~ ~] [[%value-literals [~.ud '1;2;4;5']] ~ ~]] then-q-col-1]
      (some then-q-col-2)
      [~.ud 1]
    ==
    :-  %searched-in-unqualified-col
    :*  ~
      [%case-when-then [%in [pred-u-col-4 ~ ~] [[%value-literals [~.ud '1;2;4;5']] ~ ~]] then-u-col-4]
      (some then-u-col-5)
      [~.ud 4]
    ==
::    :-  %simple-in-dime
::    :*  (some [%literal-value [~.ud 1]])
::      [%case-when-then [%value-literals [~.ud '1;2;4;5']] then-q-col-1]
::      (some then-q-col-2)
::      [~.ud 1]
::    ==
::    :-  %simple-in-qualified-col
::    :*  (some pred-q-col-1)
::      [%case-when-then [%value-literals [~.ud '1;2;4;5']] then-q-col-1]
::      (some then-q-col-2)
::      [~.ud 1]
::    ==
::    :-  %simple-in-unqualified-col
::    :*  (some pred-u-col-4)
::      [%case-when-then [%value-literals [~.ud '1;2;4;5']] then-u-col-4]
::      (some then-u-col-5)
::      [~.ud 4]
::    ==
  ==
::
::  %not-in tests
::
++  test-case-predicate-not-in
  %-  pred-row-test
  :~
    :-  %searched-not-in-dime
    :*  ~
      [%case-when-then [%not-in [[~.ud 3] ~ ~] [[%value-literals [~.ud '1;2;4;5']] ~ ~]] then-q-col-1]
      (some then-q-col-2)
      [~.ud 1]
    ==
    :-  %searched-not-in-qualified-col
    :*  ~
      [%case-when-then [%not-in [pred-q-col-3 ~ ~] [[%value-literals [~.ud '1;2;4;5']] ~ ~]] then-q-col-1]
      (some then-q-col-2)
      [~.ud 1]
    ==
    :-  %searched-not-in-unqualified-col
    :*  ~
      [%case-when-then [%not-in [pred-u-col-6 ~ ~] [[%value-literals [~.ud '1;2;4;5']] ~ ~]] then-u-col-4]
      (some then-u-col-5)
      [~.ud 4]
    ==
::    :-  %simple-not-in-dime
::    :*  (some [%literal-value [~.ud 3]])
::      [%case-when-then [%value-literals [~.ud '1;2;4;5']] then-q-col-1]
::      (some then-q-col-2)
::      [~.ud 1]
::    ==
::    :-  %simple-not-in-qualified-col
::    :*  (some pred-q-col-3)
::      [%case-when-then [%value-literals [~.ud '1;2;4;5']] then-q-col-1]
::      (some then-q-col-2)
::      [~.ud 1]
::    ==
::    :-  %simple-not-in-unqualified-col
::    :*  (some pred-u-col-6)
::      [%case-when-then [%value-literals [~.ud '1;2;4;5']] then-u-col-4]
::      (some then-u-col-5)
::      [~.ud 4]
::    ==
  ==
::
::  %between tests
::
++  test-case-predicate-between
  =/  mk-between-pred
    |*  [val-to-test=* lower-bound=* upper-bound=*]
    :+  %between
      [%gte [val-to-test ~ ~] [lower-bound ~ ~]]
    [%lte [val-to-test ~ ~] [upper-bound ~ ~]]
  %-  pred-row-test
  :~
    :-  %searched-between-dime-dimes
    :*  ~
      [%case-when-then (mk-between-pred [~.ud 2] [~.ud 1] [~.ud 3]) then-q-col-1]
      (some then-q-col-2)
      [~.ud 1]
    ==
    :-  %searched-between-qualified-col-qualified-cols
    :*  ~
      [%case-when-then (mk-between-pred pred-q-col-2 pred-q-col-1 pred-q-col-3) then-q-col-1]
      (some then-q-col-2)
      [~.ud 1]
    ==
    :-  %searched-between-qualified-col-dime-and-qualified-col
    :*  ~
      [%case-when-then (mk-between-pred pred-q-col-2 [~.ud 1] pred-q-col-3) then-q-col-1]
      (some then-q-col-2)
      [~.ud 1]
    ==
    :-  %searched-between-qualified-col-qualified-col-and-dime
    :*  ~
      [%case-when-then (mk-between-pred pred-q-col-2 pred-q-col-1 [~.ud 3]) then-q-col-1]
      (some then-q-col-2)
      [~.ud 1]
    ==
    :-  %searched-between-qualified-col-dimes
    :*  ~
      [%case-when-then (mk-between-pred pred-q-col-2 [~.ud 1] [~.ud 3]) then-q-col-1]
      (some then-q-col-2)
      [~.ud 1]
    ==
    :-  %searched-between-unqualified-col-unqualified-cols
    :*  ~
      [%case-when-then (mk-between-pred pred-u-col-5 pred-u-col-4 pred-u-col-6) then-u-col-4]
      (some then-u-col-5)
      [~.ud 4]
    ==
    :-  %searched-between-unqualified-col-dime-and-unqualified-col
    :*  ~
      [%case-when-then (mk-between-pred pred-u-col-5 [~.ud 4] pred-u-col-6) then-u-col-4]
      (some then-u-col-5)
      [~.ud 4]
    ==
    :-  %searched-between-unqualified-col-unqualified-col-and-dime
    :*  ~
      [%case-when-then (mk-between-pred pred-u-col-5 pred-u-col-4 [~.ud 6]) then-u-col-4]
      (some then-u-col-5)
      [~.ud 4]
    ==
    :-  %searched-between-unqualified-col-dimes
    :*  ~
      [%case-when-then (mk-between-pred pred-u-col-5 [~.ud 4] [~.ud 6]) then-u-col-4]
      (some then-u-col-5)
      [~.ud 4]
    ==
    :-  %simple-between-dime-dimes
    :*  (some [%literal-value [~.ud 2]])
      [%case-when-then (mk-between-pred [~.ud 2] [~.ud 1] [~.ud 3]) then-q-col-1]
      (some then-q-col-2)
      [~.ud 1]
    ==
    :-  %simple-between-qualified-col-qualified-cols
    :*  (some pred-q-col-2)
      [%case-when-then (mk-between-pred pred-q-col-2 pred-q-col-1 pred-q-col-3) then-q-col-1]
      (some then-q-col-2)
      [~.ud 1]
    ==
    :-  %simple-between-qualified-col-dime-and-qualified-col
    :*  (some pred-q-col-2)
      [%case-when-then (mk-between-pred pred-q-col-2 [~.ud 1] pred-q-col-3) then-q-col-1]
      (some then-q-col-2)
      [~.ud 1]
    ==
    :-  %simple-between-qualified-col-qualified-col-and-dime
    :*  (some pred-q-col-2)
      [%case-when-then (mk-between-pred pred-q-col-2 pred-q-col-1 [~.ud 3]) then-q-col-1]
      (some then-q-col-2)
      [~.ud 1]
    ==
    :-  %simple-between-qualified-col-dimes
    :*  (some pred-q-col-2)
      [%case-when-then (mk-between-pred pred-q-col-2 [~.ud 1] [~.ud 3]) then-q-col-1]
      (some then-q-col-2)
      [~.ud 1]
    ==
    :-  %simple-between-unqualified-col-unqualified-cols
    :*  (some pred-u-col-5)
      [%case-when-then (mk-between-pred pred-u-col-5 pred-u-col-4 pred-u-col-6) then-u-col-4]
      (some then-u-col-5)
      [~.ud 4]
    ==
    :-  %simple-between-unqualified-col-dime-and-unqualified-col
    :*  (some pred-u-col-5)
      [%case-when-then (mk-between-pred pred-u-col-5 [~.ud 4] pred-u-col-6) then-u-col-4]
      (some then-u-col-5)
      [~.ud 4]
    ==
    :-  %simple-between-unqualified-col-unqualified-col-and-dime
    :*  (some pred-u-col-5)
      [%case-when-then (mk-between-pred pred-u-col-5 pred-u-col-4 [~.ud 6]) then-u-col-4]
      (some then-u-col-5)
      [~.ud 4]
    ==
    :-  %simple-between-unqualified-col-dimes
    :*  (some pred-u-col-5)
      [%case-when-then (mk-between-pred pred-u-col-5 [~.ud 4] [~.ud 6]) then-u-col-4]
      (some then-u-col-5)
      [~.ud 4]
    ==
  ==
::
::  %not-between tests
::
++  test-case-predicate-not-between
  =/  mk-not-between-pred
    |*  [val-to-test=* lower-bound=* upper-bound=*]
    :+  %not-between
      [%gte [val-to-test ~ ~] [lower-bound ~ ~]]
    [%lte [val-to-test ~ ~] [upper-bound ~ ~]]
  %-  pred-row-test
  :~
    :-  %searched-not-between-dime-dimes
    :*  ~
      [%case-when-then (mk-not-between-pred [~.ud 5] [~.ud 1] [~.ud 3]) then-q-col-1]
      (some then-q-col-2)
      [~.ud 1]
    ==
    :-  %searched-not-between-qualified-col-qualified-cols
    :*  ~
      [%case-when-then (mk-not-between-pred pred-q-col-1 pred-q-col-2 pred-q-col-3) then-q-col-1]
      (some then-q-col-2)
      [~.ud 1]
    ==
    :-  %searched-not-between-qualified-col-dime-and-qualified-col
    :*  ~
      [%case-when-then (mk-not-between-pred pred-q-col-1 [~.ud 2] pred-q-col-3) then-q-col-1]
      (some then-q-col-2)
      [~.ud 1]
    ==
    :-  %searched-not-between-qualified-col-qualified-col-and-dime
    :*  ~
      [%case-when-then (mk-not-between-pred pred-q-col-1 pred-q-col-2 [~.ud 3]) then-q-col-1]
      (some then-q-col-2)
      [~.ud 1]
    ==
    :-  %searched-not-between-qualified-col-dimes
    :*  ~
      [%case-when-then (mk-not-between-pred pred-q-col-1 [~.ud 2] [~.ud 4]) then-q-col-1]
      (some then-q-col-2)
      [~.ud 1]
    ==
    :-  %searched-not-between-unqualified-col-unqualified-cols
    :*  ~
      [%case-when-then (mk-not-between-pred pred-u-col-4 pred-u-col-5 pred-u-col-6) then-u-col-4]
      (some then-u-col-5)
      [~.ud 4]
    ==
    :-  %searched-not-between-unqualified-col-dime-and-unqualified-col
    :*  ~
      [%case-when-then (mk-not-between-pred pred-u-col-4 [~.ud 5] pred-u-col-6) then-u-col-4]
      (some then-u-col-5)
      [~.ud 4]
    ==
    :-  %searched-not-between-unqualified-col-unqualified-col-and-dime
    :*  ~
      [%case-when-then (mk-not-between-pred pred-u-col-4 pred-u-col-5 [~.ud 6]) then-u-col-4]
      (some then-u-col-5)
      [~.ud 4]
    ==
    :-  %searched-not-between-unqualified-col-dimes
    :*  ~
      [%case-when-then (mk-not-between-pred pred-u-col-4 [~.ud 5] [~.ud 7]) then-u-col-4]
      (some then-u-col-5)
      [~.ud 4]
    ==
    :-  %simple-not-between-dime-dimes
    :*  (some [%literal-value [~.ud 5]])
      [%case-when-then (mk-not-between-pred [~.ud 5] [~.ud 1] [~.ud 3]) then-q-col-1]
      (some then-q-col-2)
      [~.ud 1]
    ==
    :-  %simple-not-between-qualified-col-qualified-cols
    :*  (some pred-q-col-1)
      [%case-when-then (mk-not-between-pred pred-q-col-1 pred-q-col-2 pred-q-col-3) then-q-col-1]
      (some then-q-col-2)
      [~.ud 1]
    ==
    :-  %simple-not-between-qualified-col-dime-and-qualified-col
    :*  (some pred-q-col-1)
      [%case-when-then (mk-not-between-pred pred-q-col-1 [~.ud 2] pred-q-col-3) then-q-col-1]
      (some then-q-col-2)
      [~.ud 1]
    ==
    :-  %simple-not-between-qualified-col-qualified-col-and-dime
    :*  (some pred-q-col-1)
      [%case-when-then (mk-not-between-pred pred-q-col-1 pred-q-col-2 [~.ud 3]) then-q-col-1]
      (some then-q-col-2)
      [~.ud 1]
    ==
    :-  %simple-not-between-qualified-col-dimes
    :*  (some pred-q-col-1)
      [%case-when-then (mk-not-between-pred pred-q-col-1 [~.ud 2] [~.ud 4]) then-q-col-1]
      (some then-q-col-2)
      [~.ud 1]
    ==
    :-  %simple-not-between-unqualified-col-unqualified-cols
    :*  (some pred-u-col-4)
      [%case-when-then (mk-not-between-pred pred-u-col-4 pred-u-col-5 pred-u-col-6) then-u-col-4]
      (some then-u-col-5)
      [~.ud 4]
    ==
    :-  %simple-not-between-unqualified-col-dime-and-unqualified-col
    :*  (some pred-u-col-4)
      [%case-when-then (mk-not-between-pred pred-u-col-4 [~.ud 5] pred-u-col-6) then-u-col-4]
      (some then-u-col-5)
      [~.ud 4]
    ==
    :-  %simple-not-between-unqualified-col-unqualified-col-and-dime
    :*  (some pred-u-col-4)
      [%case-when-then (mk-not-between-pred pred-u-col-4 pred-u-col-5 [~.ud 6]) then-u-col-4]
      (some then-u-col-5)
      [~.ud 4]
    ==
    :-  %simple-not-between-unqualified-col-dimes
    :*  (some pred-u-col-4)
      [%case-when-then (mk-not-between-pred pred-u-col-4 [~.ud 5] [~.ud 7]) then-u-col-4]
      (some then-u-col-5)
      [~.ud 4]
    ==
  ==
::
::  %and tests
::
++  test-case-predicate-and
  %-  pred-row-test
  :~
    :-  %searched-and-true
    :*  ~
      [%case-when-then [%and [%eq [[~.ud 1] ~ ~] [[~.ud 1] ~ ~]] [%eq [[~.ud 1] ~ ~] [[~.ud 1] ~ ~]]] then-q-col-1]
      (some then-q-col-2)
      [~.ud 1]
    ==
    :-  %simple-and-true
    :*  (some [%literal-value [~.ud 1]])
      [%case-when-then [%and [%eq [[~.ud 1] ~ ~] [[~.ud 1] ~ ~]] [%eq [[~.ud 1] ~ ~] [[~.ud 1] ~ ~]]] then-q-col-1]
      (some then-q-col-2)
      [~.ud 1]
    ==
  ==
::
::  %or tests
::
++  test-case-predicate-or
  %-  pred-row-test
  :~
    :-  %searched-or-true-true
    :*  ~
      [%case-when-then [%or [%eq [[~.ud 1] ~ ~] [[~.ud 1] ~ ~]] [%eq [[~.ud 1] ~ ~] [[~.ud 1] ~ ~]]] then-q-col-1]
      (some then-q-col-2)
      [~.ud 1]
    ==
    :-  %searched-or-true-false
    :*  ~
      [%case-when-then [%or [%eq [[~.ud 0] ~ ~] [[~.ud 1] ~ ~]] [%eq [[~.ud 1] ~ ~] [[~.ud 1] ~ ~]]] then-q-col-1]
      (some then-q-col-2)
      [~.ud 1]
    ==
    :-  %simple-or-true-true
    :*  (some [%literal-value [~.ud 1]])
      [%case-when-then [%or [%eq [[~.ud 1] ~ ~] [[~.ud 1] ~ ~]] [%eq [[~.ud 1] ~ ~] [[~.ud 1] ~ ~]]] then-q-col-1]
      (some then-q-col-2)
      [~.ud 1]
    ==
    :-  %simple-or-true-false
    :*  (some [%literal-value [~.ud 1]])
      [%case-when-then [%or [%eq [[~.ud 0] ~ ~] [[~.ud 1] ~ ~]] [%eq [[~.ud 1] ~ ~] [[~.ud 1] ~ ~]]] then-q-col-1]
      (some then-q-col-2)
      [~.ud 1]
    ==
  ==
::
::  %not tests
::
++  test-case-predicate-not
  %-  pred-row-test
  :~
    :-  %searched-not-false-expression
    :*  ~
      [%case-when-then [%not [%eq [[~.ud 0] ~ ~] [[~.ud 1] ~ ~]] ~] then-q-col-1]
      (some then-q-col-2)
      [~.ud 1]
    ==
 ::   :-  %simple-not-false-expression
 ::   :*  (some [%literal-value [~.ud 1]])
 ::     [%case-when-then [%not [%eq [[%literal-value [~.ud 0]] ~ ~] [[~.ud 1] ~ ~]]] then-q-col-1]
 ::     (some then-q-col-2)
 ::     [~.ud 1]
 ::   ==
  ==

::  ::::::::::::::::::::::
::  :::: TARGET TESTS ::::
::  ::::::::::::::::::::::

::  TODO: do tests for target

::  ::::::::::::::::::::
::  :::: THEN TESTS ::::
::  ::::::::::::::::::::
::  TODO: interesting test case, what if two whens match? which one do we pick?
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
::  tests for all possible then return types
::
::  test return qualified column
::  fail scenario: no table with column
++  test-case-searched-then-qualified-col-01
  =/  cases
    :~
      [%case-when-then true-predicate then-q-col-1]
      [%case-when-then false-predicate then-q-col-2]
    ==
  =/  case-expr=case:ast
    :*  %case
      target=~
      cases=cases
      else=~
    ==
  =/  scalar-to-apply
    (prepare-scalar case-expr then-named-ctes then-lookups then-scalars)
  %+  expect-eq
    !>  [~.ud 1]
    !>  (apply-scalar then-row scalar-to-apply)
::
::  test return unqualified column
::  fail scenario: no table with column
++  test-case-searched-then-unqualified-col-01
  =/  cases
    :~
      [%case-when-then true-predicate then-u-col-4]
      [%case-when-then false-predicate then-u-col-5]
    ==
  =/  case-expr=case:ast
    :*  %case
      target=~
      cases=cases
      else=~
    ==
  =/  scalar-to-apply
    (prepare-scalar case-expr then-named-ctes then-lookups then-scalars)
  %+  expect-eq
    !>  [~.ud 4]
    !>  (apply-scalar then-row scalar-to-apply)
::
::  test return literal-value
++  test-case-searched-then-literal-value-01
  =/  cases
    :~
      [%case-when-then true-predicate [%literal-value [~.t 'foo']]]
      [%case-when-then false-predicate [%literal-value [~.t 'baz']]]
    ==
  =/  case-expr=case:ast
    :*  %case
      target=~
      cases=cases
      else=~
    ==
  =/  scalar-to-apply
    (prepare-scalar case-expr then-named-ctes then-lookups then-scalars)
  %+  expect-eq
    !>  [~.t 'foo']
    !>  (apply-scalar then-row scalar-to-apply)
::
::  test return scalar-alias
::  fail scenario: no scalar with alias
++  test-case-searched-then-scalar-alias-01
  =/  cases
    :~
      [%case-when-then true-predicate [%scalar-alias %scalar1]]
      [%case-when-then false-predicate then-q-col-2]
    ==
  =/  case-expr=case:ast
    :*  %case
      target=~
      cases=cases
      else=~
    ==
  =/  scalar-to-apply
    (prepare-scalar case-expr then-named-ctes then-lookups then-scalars)
  %+  expect-eq
    !>  [~.ud 3]
    !>  (apply-scalar then-row scalar-to-apply)
::
::  test return embedded scalar
::  fail scenario: no scalar with alias
++  test-case-searched-then-embedded-scalar-01
  =/  cases
    :~
      [%case-when-then true-predicate (~(got by then-scalars) %scalar1)]
      [%case-when-then false-predicate then-q-col-2]
    ==
  =/  case-expr=case:ast
    :*  %case
      target=~
      cases=cases
      else=~
    ==
  =/  scalar-to-apply
    (prepare-scalar case-expr then-named-ctes then-lookups then-scalars)
  %+  expect-eq
    !>  [~.ud 3]
    !>  (apply-scalar then-row scalar-to-apply)
::
++  test-case-simple-then-qualified-col-01
  =/  cases
    :~
      [%case-when-then literal-1 then-q-col-1]
      [%case-when-then literal-2 then-q-col-2]
    ==
  =/  case-expr=case:ast
    :*  %case
      target=(some then-q-col-1)
      cases=cases
      else=~
    ==
  =/  scalar-to-apply
    (prepare-scalar case-expr then-named-ctes then-lookups then-scalars)
  %+  expect-eq
    !>  [~.ud 1]
    !>  (apply-scalar then-row scalar-to-apply)
::
++  test-case-simple-then-unqualified-col-01
  =/  cases
    :~
      [%case-when-then literal-1 then-u-col-4]
      [%case-when-then literal-2 then-u-col-5]
    ==
  =/  case-expr=case:ast
    :*  %case
      target=(some then-q-col-1)
      cases=cases
      else=~
    ==
  =/  scalar-to-apply
    (prepare-scalar case-expr then-named-ctes then-lookups then-scalars)
  %+  expect-eq
    !>  [~.ud 4]
    !>  (apply-scalar then-row scalar-to-apply)
::
::  test return literal-value
++  test-case-simple-then-literal-value-01
  =/  cases
    :~
      [%case-when-then literal-1 [%literal-value [~.t 'foo']]]
      [%case-when-then literal-2 [%literal-value [~.t 'baz']]]
    ==
  =/  case-expr=case:ast
    :*  %case
      target=(some then-q-col-1)
      cases=cases
      else=~
    ==
  =/  scalar-to-apply
    (prepare-scalar case-expr then-named-ctes then-lookups then-scalars)
  %+  expect-eq
    !>  [~.t 'foo']
    !>  (apply-scalar then-row scalar-to-apply)
::
::  test return scalar-alias
::  fail scenario: no scalar with alias
++  test-case-simple-then-scalar-alias-01
  =/  cases
    :~
      [%case-when-then literal-1 [%scalar-alias %scalar1]]
      [%case-when-then literal-2 then-q-col-2]
    ==
  =/  case-expr=case:ast
    :*  %case
      target=(some then-q-col-1)
      cases=cases
      else=~
    ==
  =/  scalar-to-apply
    (prepare-scalar case-expr then-named-ctes then-lookups then-scalars)
  %+  expect-eq
    !>  [~.ud 3]
    !>  (apply-scalar then-row scalar-to-apply)
::
::  test return embedded scalar
::  fail scenario: no scalar with alias
++  test-case-simple-then-embedded-scalar-01
  =/  cases
    :~
      [%case-when-then literal-1 (~(got by then-scalars) %scalar1)]
      [%case-when-then literal-2 then-q-col-2]
    ==
  =/  case-expr=case:ast
    :*  %case
      target=(some then-q-col-1)
      cases=cases
      else=~
    ==
  =/  scalar-to-apply
    (prepare-scalar case-expr then-named-ctes then-lookups then-scalars)
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
::  tests for all possible else return types
::
::  test return qualified column
::  fail scenario: no table with column
++  test-case-searched-else-qualified-col-01
  =/  cases
    :~
      [%case-when-then false-predicate else-q-col-1]
      [%case-when-then false-predicate else-q-col-1]
    ==
  =/  case-expr=case:ast
    :*  %case
      target=~
      cases=cases
      else=(some else-q-col-2)
    ==
  =/  scalar-to-apply
    (prepare-scalar case-expr else-named-ctes else-lookups else-scalars)
  %+  expect-eq
    !>  [~.ud 2]
    !>  (apply-scalar else-row scalar-to-apply)
::
::  test return unqualified column
::  fail scenario: no table with column
++  test-case-searched-else-unqualified-col-01
  =/  cases
    :~
      [%case-when-then false-predicate else-u-col-4]
      [%case-when-then false-predicate else-u-col-4]
    ==
  =/  case-expr=case:ast
    :*  %case
      target=~
      cases=cases
      else=(some else-u-col-5)
    ==
  =/  scalar-to-apply
    (prepare-scalar case-expr else-named-ctes else-lookups else-scalars)
  %+  expect-eq
    !>  [~.ud 5]
    !>  (apply-scalar else-row scalar-to-apply)
::
::  test return literal-value
++  test-case-searched-else-literal-value-01
  =/  cases
    :~
      [%case-when-then false-predicate [%literal-value [~.t 'foo']]]
      [%case-when-then false-predicate [%literal-value [~.t 'foo']]]
    ==
  =/  case-expr=case:ast
    :*  %case
      target=~
      cases=cases
      else=(some [%literal-value [~.t 'bar']])
    ==
  =/  scalar-to-apply
    (prepare-scalar case-expr else-named-ctes else-lookups else-scalars)
  %+  expect-eq
    !>  [~.t 'bar']
    !>  (apply-scalar else-row scalar-to-apply)
::
::  test return scalar-alias
::  fail scenario: no scalar with alias
++  test-case-searched-else-scalar-alias-01
  =/  cases
    :~
      [%case-when-then false-predicate else-q-col-2]
      [%case-when-then false-predicate else-q-col-2]
    ==
  =/  case-expr=case:ast
    :*  %case
      target=~
      cases=cases
      else=(some [%scalar-alias %scalar1])
    ==
  =/  scalar-to-apply
    (prepare-scalar case-expr else-named-ctes else-lookups else-scalars)
  %+  expect-eq
    !>  [~.ud 3]
    !>  (apply-scalar else-row scalar-to-apply)
::
::  test return embedded scalar
::  fail scenario: no scalar with alias
++  test-case-searched-else-embedded-scalar-01
  =/  cases
    :~
      [%case-when-then false-predicate else-q-col-2]
      [%case-when-then false-predicate else-q-col-2]
    ==
  =/  case-expr=case:ast
    :*  %case
      target=~
      cases=cases
      else=(some (~(got by else-scalars) %scalar1))
    ==
  =/  scalar-to-apply
    (prepare-scalar case-expr else-named-ctes else-lookups else-scalars)
  %+  expect-eq
    !>  [~.ud 3]
    !>  (apply-scalar else-row scalar-to-apply)
::
++  test-case-simple-else-qualified-col-01
  =/  cases
    :~
      [%case-when-then literal-2 else-q-col-2]
    ==
  =/  case-expr=case:ast
    :*  %case
      target=(some else-q-col-1)
      cases=cases
      else=(some else-q-col-2)
    ==
  =/  scalar-to-apply
    (prepare-scalar case-expr else-named-ctes else-lookups else-scalars)
  %+  expect-eq
    !>  [~.ud 2]
    !>  (apply-scalar else-row scalar-to-apply)
::
++  test-case-simple-else-unqualified-col-01
  =/  cases
    :~
      [%case-when-then literal-2 else-u-col-4]
    ==
  =/  case-expr=case:ast
    :*  %case
      target=(some else-q-col-1)
      cases=cases
      else=(some else-u-col-5)
    ==
  =/  scalar-to-apply
    (prepare-scalar case-expr else-named-ctes else-lookups else-scalars)
  %+  expect-eq
    !>  [~.ud 5]
    !>  (apply-scalar else-row scalar-to-apply)
::
::  test return literal-value
++  test-case-simple-else-literal-value-01
  =/  cases
    :~
      [%case-when-then literal-2 [%literal-value [~.t 'foo']]]
    ==
  =/  case-expr=case:ast
    :*  %case
      target=(some else-q-col-1)
      cases=cases
      else=(some [%literal-value [~.t 'bar']])
    ==
  =/  scalar-to-apply
    (prepare-scalar case-expr else-named-ctes else-lookups else-scalars)
  %+  expect-eq
    !>  [~.t 'bar']
    !>  (apply-scalar else-row scalar-to-apply)
::
::  test return scalar-alias
::  fail scenario: no scalar with alias
++  test-case-simple-else-scalar-alias-01
  =/  cases
    :~
      [%case-when-then literal-2 else-q-col-2]
    ==
  =/  case-expr=case:ast
    :*  %case
      target=(some else-q-col-1)
      cases=cases
      else=(some [%scalar-alias %scalar1])
    ==
  =/  scalar-to-apply
    (prepare-scalar case-expr else-named-ctes else-lookups else-scalars)
  %+  expect-eq
    !>  [~.ud 3]
    !>  (apply-scalar else-row scalar-to-apply)
::
::  test return embedded scalar
::  fail scenario: no scalar with alias
++  test-case-simple-else-embedded-scalar-01
  =/  cases
    :~
      [%case-when-then literal-2 else-q-col-2]
    ==
  =/  case-expr=case:ast
    :*  %case
      target=(some else-q-col-1)
      cases=cases
      else=(some (~(got by else-scalars) %scalar1))
    ==
  =/  scalar-to-apply
    (prepare-scalar case-expr else-named-ctes else-lookups else-scalars)
  %+  expect-eq
    !>  [~.ud 3]
    !>  (apply-scalar else-row scalar-to-apply)
--
