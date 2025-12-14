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
::  set up some costant context for tests
::
++  when-q-col-1           [%qualified-column qualified-table-1 %col1 ~]
++  when-q-col-2           [%qualified-column qualified-table-1 %col2 ~]
++  when-q-col-3           [%qualified-column qualified-table-1 %col3 ~]
++  when-q-col-4           [%qualified-column qualified-table-1 %other-col4 ~]
::
++  when-u-col-4           [%unqualified-column %col4 ~]
++  when-u-col-5           [%unqualified-column %col5 ~]
++  when-u-col-6           [%unqualified-column %col6 ~]
::
++  when-qual-type-lookup       %-  mk-qualified-type-lookup
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
++  when-unqual-type-lookup       %-  mk-unqualified-type-lookup
                                  :~
                                    [%col4 ~.ud]
                                    [%col5 ~.ud]
                                    [%col6 ~.ud]
                                  ==
::
++  when-qualifier-lookup  %-  malt
                           %-  limo
                           :~
                             [%col4 ~[qualified-table-1]]
                             [%col5 ~[qualified-table-1]]
                             [%col6 ~[qualified-table-1]]
                           ==
::
++  when-named-ctes        *named-ctes
::
++  when-row               %-  mk-indexed-row
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
++  when-scalars           %-  malt
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
+$  when-test-row  $:  target=(unit datum-or-scalar:ast)
                     case=case-when-then:ast     
                     else=(unit datum-or-scalar:ast)
                     expected=dime
                   ==
::
++  when-test-helper
  |=  [row=when-test-row]
  =/  when-lookups  [when-qualifier-lookup when-qual-type-lookup]
  =/  case-expr=case:ast  [%case target=target.row cases=~[case.row] else=else.row]
  =/  scalar-to-apply
    (prepare-scalar case-expr when-named-ctes when-lookups when-scalars)
  %+  expect-eq
    !>  expected.row
    !>  (apply-scalar when-row scalar-to-apply)
::
::  row structure:
::  [@tas(test-name) [predicate then-branch else-branch expected]]
::
++  when-row-test
  |=  [rows=(list [@tas when-test-row])]
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
    ~|((weld "CRASH - " (trip -.row)) (when-test-helper +.row))
  :-  result
  $(rows +.rows)
::
::  %eq tests
::
++  test-case-searched-when-eq
  %-  when-row-test
  :~
    :-  %searched-eq-dime-dime
    :*  ~
      [%case-when-then [%eq [literal-1 ~ ~] [literal-1 ~ ~]] then-q-col-1]
      (some then-q-col-2)
      literal-1
    ==
    :-  %searched-eq-qualified-col-dime
    :*  ~
      [%case-when-then [%eq [when-q-col-1 ~ ~] [literal-1 ~ ~]] then-q-col-1]
      (some then-q-col-2)
      literal-1
    ==
    :-  %searched-eq-dime-qualified-col
    :*  ~
      [%case-when-then [%eq [literal-1 ~ ~] [when-q-col-1 ~ ~]] then-q-col-1]
      (some then-q-col-2)
      literal-1
    ==
    :-  %searched-eq-unqualified-col-dime
    :*  ~
      [%case-when-then [%eq [when-u-col-4 ~ ~] [[~.ud 4] ~ ~]] then-u-col-4]
      (some then-u-col-5)
      [~.ud 4]
    ==
    :-  %searched-eq-dime-unqualified-col
    :*  ~
      [%case-when-then [%eq [[~.ud 4] ~ ~] [when-u-col-4 ~ ~]] then-u-col-4]
      (some then-u-col-5)
      [~.ud 4]
    ==
  ==
::
::  %neq tests
::
++  test-case-searched-when-neq
  %-  when-row-test
  :~
    :-  %searched-neq-dimes
    :*  ~
      [%case-when-then [%neq [literal-1 ~ ~] [literal-2 ~ ~]] then-q-col-1]
      (some then-q-col-2)
      literal-1
    ==
    :-  %searched-neq-qualified-columns
    :*  ~
      [%case-when-then [%neq [when-q-col-1 ~ ~] [when-q-col-2 ~ ~]] then-q-col-1]
      (some then-q-col-2)
      literal-1
    ==
    :-  %searched-neq-qualified-col-dime
    :*  ~
      [%case-when-then [%neq [when-q-col-1 ~ ~] [literal-2 ~ ~]] then-q-col-1]
      (some then-q-col-2)
      literal-1
    ==
    :-  %searched-neq-dime-qualified-col
    :*  ~
      [%case-when-then [%neq [literal-2 ~ ~] [when-q-col-1 ~ ~]] then-q-col-1]
      (some then-q-col-2)
      literal-1
    ==
    :-  %searched-neq-unqualified-columns
    :*  ~
      [%case-when-then [%neq [when-u-col-4 ~ ~] [when-u-col-5 ~ ~]] then-u-col-4]
      (some then-u-col-5)
      [~.ud 4]
    ==
    :-  %searched-neq-unqualified-col-dime
    :*  ~
      [%case-when-then [%neq [when-u-col-4 ~ ~] [[~.ud 5] ~ ~]] then-u-col-4]
      (some then-u-col-5)
      [~.ud 4]
    ==
    :-  %searched-neq-dime-unqualified-col
    :*  ~
      [%case-when-then [%neq [[~.ud 5] ~ ~] [when-u-col-4 ~ ~]] then-u-col-4]
      (some then-u-col-5)
      [~.ud 4]
    ==
  ==
::
::  %gte tests
::
++  test-case-searched-when-gte
  %-  when-row-test
  :~
    :-  %searched-gte-dimes-gt
    :*  ~
      [%case-when-then [%gte [literal-2 ~ ~] [literal-1 ~ ~]] then-q-col-1]
      (some then-q-col-2)
      literal-1
    ==
    :-  %searched-gte-dimes-eq
    :*  ~
      [%case-when-then [%gte [literal-1 ~ ~] [literal-1 ~ ~]] then-q-col-1]
      (some then-q-col-2)
      literal-1
    ==
    :-  %searched-gte-qualified-columns-gt
    :*  ~
      [%case-when-then [%gte [when-q-col-2 ~ ~] [when-q-col-1 ~ ~]] then-q-col-1]
      (some then-q-col-2)
      literal-1
    ==
    :-  %searched-gte-qualified-columns-eq
    :*  ~
      [%case-when-then [%gte [when-q-col-1 ~ ~] [when-q-col-1 ~ ~]] then-q-col-1]
      (some then-q-col-2)
      literal-1
    ==
    :-  %searched-gte-qualified-col-dime-gt
    :*  ~
      [%case-when-then [%gte [when-q-col-2 ~ ~] [literal-1 ~ ~]] then-q-col-1]
      (some then-q-col-2)
      literal-1
    ==
    :-  %searched-gte-qualified-col-dime-eq
    :*  ~
      [%case-when-then [%gte [when-q-col-1 ~ ~] [literal-1 ~ ~]] then-q-col-1]
      (some then-q-col-2)
      literal-1
    ==
    :-  %searched-gte-dime-qualified-col-gt
    :*  ~
      [%case-when-then [%gte [literal-2 ~ ~] [when-q-col-1 ~ ~]] then-q-col-1]
      (some then-q-col-2)
      literal-1
    ==
    :-  %searched-gte-dime-qualified-col-eq
    :*  ~
      [%case-when-then [%gte [literal-1 ~ ~] [when-q-col-1 ~ ~]] then-q-col-1]
      (some then-q-col-2)
      literal-1
    ==
    :-  %searched-gte-unqualified-columns-gt
    :*  ~
      [%case-when-then [%gte [when-u-col-5 ~ ~] [when-u-col-4 ~ ~]] then-u-col-4]
      (some then-u-col-5)
      [~.ud 4]
    ==
    :-  %searched-gte-unqualified-columns-eq
    :*  ~
      [%case-when-then [%gte [when-u-col-4 ~ ~] [when-u-col-4 ~ ~]] then-u-col-4]
      (some then-u-col-5)
      [~.ud 4]
    ==
    :-  %searched-gte-unqualified-col-dime-gt
    :*  ~
      [%case-when-then [%gte [when-u-col-5 ~ ~] [[~.ud 4] ~ ~]] then-u-col-4]
      (some then-u-col-5)
      [~.ud 4]
    ==
    :-  %searched-gte-unqualified-col-dime-eq
    :*  ~
      [%case-when-then [%gte [when-u-col-4 ~ ~] [[~.ud 4] ~ ~]] then-u-col-4]
      (some then-u-col-5)
      [~.ud 4]
    ==
    :-  %searched-gte-dime-unqualified-col-gt
    :*  ~
      [%case-when-then [%gte [[~.ud 5] ~ ~] [when-u-col-4 ~ ~]] then-u-col-4]
      (some then-u-col-5)
      [~.ud 4]
    ==
    :-  %searched-gte-dime-unqualified-col-eq
    :*  ~
      [%case-when-then [%gte [[~.ud 4] ~ ~] [when-u-col-4 ~ ~]] then-u-col-4]
      (some then-u-col-5)
      [~.ud 4]
    ==
  ==
::
::  %gt tests
::
++  test-case-searched-when-gt
  %-  when-row-test
  :~
    :-  %searched-gt-dimes-gt
    :*  ~
      [%case-when-then [%gt [literal-2 ~ ~] [literal-1 ~ ~]] then-q-col-1]
      (some then-q-col-2)
      literal-1
    ==
    :-  %searched-gt-qualified-columns-gt
    :*  ~
      [%case-when-then [%gt [when-q-col-2 ~ ~] [when-q-col-1 ~ ~]] then-q-col-1]
      (some then-q-col-2)
      literal-1
    ==
    :-  %searched-gt-qualified-col-dime-gt
    :*  ~
      [%case-when-then [%gt [when-q-col-2 ~ ~] [literal-1 ~ ~]] then-q-col-1]
      (some then-q-col-2)
      literal-1
    ==
    :-  %searched-gt-dime-qualified-col-gt
    :*  ~
      [%case-when-then [%gt [literal-2 ~ ~] [when-q-col-1 ~ ~]] then-q-col-1]
      (some then-q-col-2)
      literal-1
    ==
    :-  %searched-gt-unqualified-columns-gt
    :*  ~
      [%case-when-then [%gt [when-u-col-5 ~ ~] [when-u-col-4 ~ ~]] then-u-col-4]
      (some then-u-col-5)
      [~.ud 4]
    ==
    :-  %searched-gt-unqualified-col-dime-gt
    :*  ~
      [%case-when-then [%gt [when-u-col-5 ~ ~] [[~.ud 4] ~ ~]] then-u-col-4]
      (some then-u-col-5)
      [~.ud 4]
    ==
    :-  %searched-gt-dime-unqualified-col-gt
    :*  ~
      [%case-when-then [%gt [[~.ud 5] ~ ~] [when-u-col-4 ~ ~]] then-u-col-4]
      (some then-u-col-5)
      [~.ud 4]
    ==
  ==
::
::  %lte tests
::
++  test-case-searched-when-lte
  %-  when-row-test
  :~
    :-  %searched-lte-dimes-lt
    :*  ~
      [%case-when-then [%lte [literal-1 ~ ~] [literal-2 ~ ~]] then-q-col-1]
      (some then-q-col-2)
      literal-1
    ==
    :-  %searched-lte-dimes-eq
    :*  ~
      [%case-when-then [%lte [literal-1 ~ ~] [literal-1 ~ ~]] then-q-col-1]
      (some then-q-col-2)
      literal-1
    ==
    :-  %searched-lte-qualified-columns-lt
    :*  ~
      [%case-when-then [%lte [when-q-col-1 ~ ~] [when-q-col-2 ~ ~]] then-q-col-1]
      (some then-q-col-2)
      literal-1
    ==
    :-  %searched-lte-qualified-columns-eq
    :*  ~
      [%case-when-then [%lte [when-q-col-1 ~ ~] [when-q-col-1 ~ ~]] then-q-col-1]
      (some then-q-col-2)
      literal-1
    ==
    :-  %searched-lte-qualified-col-dime-lt
    :*  ~
      [%case-when-then [%lte [when-q-col-1 ~ ~] [literal-2 ~ ~]] then-q-col-1]
      (some then-q-col-2)
      literal-1
    ==
    :-  %searched-lte-qualified-col-dime-eq
    :*  ~
      [%case-when-then [%lte [when-q-col-1 ~ ~] [literal-1 ~ ~]] then-q-col-1]
      (some then-q-col-2)
      literal-1
    ==
    :-  %searched-lte-dime-qualified-col-lt
    :*  ~
      [%case-when-then [%lte [literal-1 ~ ~] [when-q-col-2 ~ ~]] then-q-col-1]
      (some then-q-col-2)
      literal-1
    ==
    :-  %searched-lte-dime-qualified-col-eq
    :*  ~
      [%case-when-then [%lte [literal-1 ~ ~] [when-q-col-1 ~ ~]] then-q-col-1]
      (some then-q-col-2)
      literal-1
    ==
    :-  %searched-lte-unqualified-columns-lt
    :*  ~
      [%case-when-then [%lte [when-u-col-4 ~ ~] [when-u-col-5 ~ ~]] then-u-col-4]
      (some then-u-col-5)
      [~.ud 4]
    ==
    :-  %searched-lte-unqualified-columns-eq
    :*  ~
      [%case-when-then [%lte [when-u-col-4 ~ ~] [when-u-col-4 ~ ~]] then-u-col-4]
      (some then-u-col-5)
      [~.ud 4]
    ==
    :-  %searched-lte-unqualified-col-dime-lt
    :*  ~
      [%case-when-then [%lte [when-u-col-4 ~ ~] [[~.ud 5] ~ ~]] then-u-col-4]
      (some then-u-col-5)
      [~.ud 4]
    ==
    :-  %searched-lte-unqualified-col-dime-eq
    :*  ~
      [%case-when-then [%lte [when-u-col-4 ~ ~] [[~.ud 4] ~ ~]] then-u-col-4]
      (some then-u-col-5)
      [~.ud 4]
    ==
    :-  %searched-lte-dime-unqualified-col-lt
    :*  ~
      [%case-when-then [%lte [[~.ud 4] ~ ~] [when-u-col-5 ~ ~]] then-u-col-4]
      (some then-u-col-5)
      [~.ud 4]
    ==
    :-  %searched-lte-dime-unqualified-col-eq
    :*  ~
      [%case-when-then [%lte [[~.ud 4] ~ ~] [when-u-col-4 ~ ~]] then-u-col-4]
      (some then-u-col-5)
      [~.ud 4]
    ==
  ==
::
::  %lt tests
::
++  test-case-searched-when-lt
  %-  when-row-test
  :~
    :-  %searched-lt-dimes-lt
    :*  ~
      [%case-when-then [%lt [literal-1 ~ ~] [literal-2 ~ ~]] then-q-col-1]
      (some then-q-col-2)
      literal-1
    ==
    :-  %searched-lt-qualified-columns-lt
    :*  ~
      [%case-when-then [%lt [when-q-col-1 ~ ~] [when-q-col-2 ~ ~]] then-q-col-1]
      (some then-q-col-2)
      literal-1
    ==
    :-  %searched-lt-qualified-col-dime-lt
    :*  ~
      [%case-when-then [%lt [when-q-col-1 ~ ~] [literal-2 ~ ~]] then-q-col-1]
      (some then-q-col-2)
      literal-1
    ==
    :-  %searched-lt-dime-qualified-col-lt
    :*  ~
      [%case-when-then [%lt [literal-1 ~ ~] [when-q-col-2 ~ ~]] then-q-col-1]
      (some then-q-col-2)
      literal-1
    ==
    :-  %searched-lt-unqualified-columns-lt
    :*  ~
      [%case-when-then [%lt [when-u-col-4 ~ ~] [when-u-col-5 ~ ~]] then-u-col-4]
      (some then-u-col-5)
      [~.ud 4]
    ==
    :-  %searched-lt-unqualified-col-dime-lt
    :*  ~
      [%case-when-then [%lt [when-u-col-4 ~ ~] [[~.ud 5] ~ ~]] then-u-col-4]
      (some then-u-col-5)
      [~.ud 4]
    ==
    :-  %searched-lt-dime-unqualified-col-lt
    :*  ~
      [%case-when-then [%lt [[~.ud 4] ~ ~] [when-u-col-5 ~ ~]] then-u-col-4]
      (some then-u-col-5)
      [~.ud 4]
    ==
  ==
::
::  %in tests
::
++  test-case-searched-when-in
  %-  when-row-test
  :~
    :-  %searched-in-dime
    :*  ~
      [%case-when-then [%in [literal-1 ~ ~] [[%value-literals [~.ud '1;2;4;5']] ~ ~]] then-q-col-1]
      (some then-q-col-2)
      literal-1
    ==
    :-  %searched-in-qualified-col
    :*  ~
      [%case-when-then [%in [when-q-col-1 ~ ~] [[%value-literals [~.ud '1;2;4;5']] ~ ~]] then-q-col-1]
      (some then-q-col-2)
      literal-1
    ==
    :-  %searched-in-unqualified-col
    :*  ~
      [%case-when-then [%in [when-u-col-4 ~ ~] [[%value-literals [~.ud '1;2;4;5']] ~ ~]] then-u-col-4]
      (some then-u-col-5)
      [~.ud 4]
    ==
  ==
::
::  %not-in tests
::
++  test-case-searched-when-not-in
  %-  when-row-test
  :~
    :-  %searched-not-in-dime
    :*  ~
      [%case-when-then [%not-in [[~.ud 3] ~ ~] [[%value-literals [~.ud '1;2;4;5']] ~ ~]] then-q-col-1]
      (some then-q-col-2)
      literal-1
    ==
    :-  %searched-not-in-qualified-col
    :*  ~
      [%case-when-then [%not-in [when-q-col-3 ~ ~] [[%value-literals [~.ud '1;2;4;5']] ~ ~]] then-q-col-1]
      (some then-q-col-2)
      literal-1
    ==
    :-  %searched-not-in-unqualified-col
    :*  ~
      [%case-when-then [%not-in [when-u-col-6 ~ ~] [[%value-literals [~.ud '1;2;4;5']] ~ ~]] then-u-col-4]
      (some then-u-col-5)
      [~.ud 4]
    ==
  ==
::
::  %between tests
::
++  test-case-searched-when-between
  =/  mk-between-pred
    |*  [val-to-test=* lower-bound=* upper-bound=*]
    :+  %between
      [%gte [val-to-test ~ ~] [lower-bound ~ ~]]
    [%lte [val-to-test ~ ~] [upper-bound ~ ~]]
  %-  when-row-test
  :~
    :-  %searched-between-dime-dimes
    :*  ~
      [%case-when-then (mk-between-pred literal-2 literal-1 [~.ud 3]) then-q-col-1]
      (some then-q-col-2)
      literal-1
    ==
    :-  %searched-between-qualified-col-qualified-cols
    :*  ~
      [%case-when-then (mk-between-pred when-q-col-2 when-q-col-1 when-q-col-3) then-q-col-1]
      (some then-q-col-2)
      literal-1
    ==
    :-  %searched-between-qualified-col-dime-and-qualified-col
    :*  ~
      [%case-when-then (mk-between-pred when-q-col-2 literal-1 when-q-col-3) then-q-col-1]
      (some then-q-col-2)
      literal-1
    ==
    :-  %searched-between-qualified-col-qualified-col-and-dime
    :*  ~
      [%case-when-then (mk-between-pred when-q-col-2 when-q-col-1 [~.ud 3]) then-q-col-1]
      (some then-q-col-2)
      literal-1
    ==
    :-  %searched-between-qualified-col-dimes
    :*  ~
      [%case-when-then (mk-between-pred when-q-col-2 literal-1 [~.ud 3]) then-q-col-1]
      (some then-q-col-2)
      literal-1
    ==
    :-  %searched-between-unqualified-col-unqualified-cols
    :*  ~
      [%case-when-then (mk-between-pred when-u-col-5 when-u-col-4 when-u-col-6) then-u-col-4]
      (some then-u-col-5)
      [~.ud 4]
    ==
    :-  %searched-between-unqualified-col-dime-and-unqualified-col
    :*  ~
      [%case-when-then (mk-between-pred when-u-col-5 [~.ud 4] when-u-col-6) then-u-col-4]
      (some then-u-col-5)
      [~.ud 4]
    ==
    :-  %searched-between-unqualified-col-unqualified-col-and-dime
    :*  ~
      [%case-when-then (mk-between-pred when-u-col-5 when-u-col-4 [~.ud 6]) then-u-col-4]
      (some then-u-col-5)
      [~.ud 4]
    ==
    :-  %searched-between-unqualified-col-dimes
    :*  ~
      [%case-when-then (mk-between-pred when-u-col-5 [~.ud 4] [~.ud 6]) then-u-col-4]
      (some then-u-col-5)
      [~.ud 4]
    ==
  ==
::
::  %not-between tests
::
++  test-case-searched-when-not-between
  =/  mk-not-between-pred
    |*  [val-to-test=* lower-bound=* upper-bound=*]
    :+  %not-between
      [%gte [val-to-test ~ ~] [lower-bound ~ ~]]
    [%lte [val-to-test ~ ~] [upper-bound ~ ~]]
  %-  when-row-test
  :~
    :-  %searched-not-between-dime-dimes
    :*  ~
      [%case-when-then (mk-not-between-pred [~.ud 5] literal-1 [~.ud 3]) then-q-col-1]
      (some then-q-col-2)
      literal-1
    ==
    :-  %searched-not-between-qualified-col-qualified-cols
    :*  ~
      [%case-when-then (mk-not-between-pred when-q-col-1 when-q-col-2 when-q-col-3) then-q-col-1]
      (some then-q-col-2)
      literal-1
    ==
    :-  %searched-not-between-qualified-col-dime-and-qualified-col
    :*  ~
      [%case-when-then (mk-not-between-pred when-q-col-1 literal-2 when-q-col-3) then-q-col-1]
      (some then-q-col-2)
      literal-1
    ==
    :-  %searched-not-between-qualified-col-qualified-col-and-dime
    :*  ~
      [%case-when-then (mk-not-between-pred when-q-col-1 when-q-col-2 [~.ud 3]) then-q-col-1]
      (some then-q-col-2)
      literal-1
    ==
    :-  %searched-not-between-qualified-col-dimes
    :*  ~
      [%case-when-then (mk-not-between-pred when-q-col-1 literal-2 [~.ud 4]) then-q-col-1]
      (some then-q-col-2)
      literal-1
    ==
    :-  %searched-not-between-unqualified-col-unqualified-cols
    :*  ~
      [%case-when-then (mk-not-between-pred when-u-col-4 when-u-col-5 when-u-col-6) then-u-col-4]
      (some then-u-col-5)
      [~.ud 4]
    ==
    :-  %searched-not-between-unqualified-col-dime-and-unqualified-col
    :*  ~
      [%case-when-then (mk-not-between-pred when-u-col-4 [~.ud 5] when-u-col-6) then-u-col-4]
      (some then-u-col-5)
      [~.ud 4]
    ==
    :-  %searched-not-between-unqualified-col-unqualified-col-and-dime
    :*  ~
      [%case-when-then (mk-not-between-pred when-u-col-4 when-u-col-5 [~.ud 6]) then-u-col-4]
      (some then-u-col-5)
      [~.ud 4]
    ==
    :-  %searched-not-between-unqualified-col-dimes
    :*  ~
      [%case-when-then (mk-not-between-pred when-u-col-4 [~.ud 5] [~.ud 7]) then-u-col-4]
      (some then-u-col-5)
      [~.ud 4]
    ==
  ==
::
::  %and tests
::
++  test-case-searched-when-and
  %-  when-row-test
  :~
    :-  %searched-and-true
    :*  ~
      [%case-when-then [%and [%eq [literal-1 ~ ~] [literal-1 ~ ~]] [%eq [literal-1 ~ ~] [literal-1 ~ ~]]] then-q-col-1]
      (some then-q-col-2)
      literal-1
    ==
  ==
::
::  %or tests
::
++  test-case-searched-when-or
  %-  when-row-test
  :~
    :-  %searched-or-true-true
    :*  ~
      [%case-when-then [%or [%eq [literal-1 ~ ~] [literal-1 ~ ~]] [%eq [literal-1 ~ ~] [literal-1 ~ ~]]] then-q-col-1]
      (some then-q-col-2)
      literal-1
    ==
    :-  %searched-or-true-false
    :*  ~
      [%case-when-then [%or [%eq [[~.ud 0] ~ ~] [literal-1 ~ ~]] [%eq [literal-1 ~ ~] [literal-1 ~ ~]]] then-q-col-1]
      (some then-q-col-2)
      literal-1
    ==
    :-  %searched-or-false-false
    :*  ~
      [%case-when-then [%or [%eq [[~.ud 0] ~ ~] [literal-1 ~ ~]] [%eq [[~.ud 0] ~ ~] [literal-1 ~ ~]]] then-q-col-1]
      (some then-q-col-2)
      literal-2
    ==
  ==
::
::  %not tests
::
++  test-case-searched-when-not
  %-  when-row-test
  :~
    :-  %searched-not-false-predicate
    :*  ~
      [%case-when-then [%not [%eq [[~.ud 0] ~ ~] [literal-1 ~ ~]] ~] then-q-col-1]
      (some then-q-col-2)
      literal-1
    ==
    :-  %searched-not-true-preciate
    :*  ~
      [%case-when-then [%not [%eq [literal-1 ~ ~] [literal-1 ~ ~]] ~] then-q-col-1]
      (some then-q-col-2)
      literal-2
    ==
  ==
::
::  simple case expression tests
::
++  test-case-when-simple
  %-  when-row-test
  :~
    ::  target = literal value
    :-  %simple-case-target-dime-when-dime
    :*  (some literal-value-1)
      [%case-when-then literal-value-1 then-q-col-1]
      ~
      literal-1
    ==
    :-  %simple-case-target-dime-when-qualified-column
    :*  (some literal-value-1)
      [%case-when-then when-q-col-1 then-q-col-1]
      ~
      literal-1
    ==
    :-  %simple-case-target-dime-when-unqualified-column
    :*  (some [%literal-value [~.ud 4]])
      [%case-when-then when-u-col-4 then-q-col-1]
      ~
      literal-1
    ==
    :-  %simple-case-target-dime-when-scalar-alias
    :*  (some [%literal-value [~.ud 3]])
      [%case-when-then [%scalar-alias %scalar1] then-q-col-1]
      ~
      literal-1
    ==
    :-  %simple-case-target-dime-when-embedded-scalar
    :*  (some [%literal-value [~.ud 3]])
      [%case-when-then (~(got by when-scalars) %scalar1) then-q-col-1]
      ~
      literal-1
    ==
    ::  target = qualified column
    :-  %simple-case-target-qualified-when-dime
    :*  (some when-q-col-1)
      [%case-when-then literal-value-1 then-q-col-1]
      ~
      literal-1
    ==
    :-  %simple-case-target-qualified-when-qualified-column
    :*  (some when-q-col-1)
      [%case-when-then when-q-col-1 then-q-col-1]
      ~
      literal-1
    ==
    :-  %simple-case-target-qualified-when-unqualified-column
    :*  (some when-q-col-1)
      [%case-when-then [%literal-value [~.ud 1]] then-q-col-1]
      ~
      literal-1
    ==
    :-  %simple-case-target-qualified-when-scalar-alias
    :*  (some when-q-col-3)
      [%case-when-then [%scalar-alias %scalar1] then-q-col-1]
      ~
      literal-1
    ==
    :-  %simple-case-target-qualified-when-embedded-scalar
    :*  (some when-q-col-3)
      [%case-when-then (~(got by when-scalars) %scalar1) then-q-col-1]
      ~
      literal-1
    ==
    ::  target = unqualified column
    :-  %simple-case-target-unqualified-when-dime
    :*  (some when-u-col-4)
      [%case-when-then [%literal-value [~.ud 4]] then-q-col-1]
      ~
      literal-1
    ==
    :-  %simple-case-target-unqualified-when-qualified-column
    :*  (some when-u-col-4)
      [%case-when-then when-q-col-4 then-q-col-1]
      ~
      literal-1
    ==
    :-  %simple-case-target-unqualified-when-unqualified-column
    :*  (some when-u-col-4)
      [%case-when-then when-u-col-4 then-q-col-1]
      ~
      literal-1
    ==
    :-  %simple-case-target-unqualified-when-scalar-alias
    :*  (some when-u-col-4)
      [%case-when-then [%scalar-alias %scalar2] then-u-col-4]
      ~
      [~.ud 4]
    ==
    :-  %simple-case-target-unqualified-when-embedded-scalar
    :*  (some when-u-col-4)
      [%case-when-then (~(got by when-scalars) %scalar2) then-u-col-4]
      ~
      [~.ud 4]
    ==
    ::  target = scalar alias
    :-  %simple-case-target-scalar-alias-when-dime
    :*  (some [%scalar-alias %scalar1])
      [%case-when-then [%literal-value [~.ud 3]] then-q-col-1]
      ~
      literal-1
    ==
    :-  %simple-case-target-scalar-alias-when-qualified-column
    :*  (some [%scalar-alias %scalar1])
      [%case-when-then when-q-col-3 then-q-col-1]
      ~
      literal-1
    ==
    :-  %simple-case-target-scalar-alias-when-unqualified-column
    :*  (some [%scalar-alias %scalar2])
      [%case-when-then when-u-col-4 then-q-col-1]
      ~
      literal-1
    ==
    :-  %simple-case-target-scalar-alias-when-scalar-alias
    :*  (some [%scalar-alias %scalar1])
      [%case-when-then [%scalar-alias %scalar1] then-q-col-1]
      ~
      literal-1
    ==
    :-  %simple-case-target-scalar-alias-when-embedded-scalar
    :*  (some [%scalar-alias %scalar1])
      [%case-when-then (~(got by when-scalars) %scalar1) then-q-col-1]
      ~
      literal-1
    ==
    ::  target = embedded scalar
    :-  %simple-case-target-embedded-scalar-when-dime
    :*  (some (~(got by when-scalars) %scalar1))
      [%case-when-then [%literal-value [~.ud 3]] then-q-col-1]
      ~
      literal-1
    ==
    :-  %simple-case-target-embedded-scalar-when-qualified-column
    :*  (some (~(got by when-scalars) %scalar1))
      [%case-when-then when-q-col-3 then-q-col-1]
      ~
      literal-1
    ==
    :-  %simple-case-target-embedded-scalar-when-unqualified-column
    :*  (some (~(got by when-scalars) %scalar2))
      [%case-when-then when-u-col-4 then-q-col-1]
      ~
      literal-1
    ==
    :-  %simple-case-target-embedded-scalar-when-scalar-alias
    :*  (some (~(got by when-scalars) %scalar1))
      [%case-when-then [%scalar-alias %scalar1] then-q-col-1]
      ~
      literal-1
    ==
    :-  %simple-case-target-embedded-scalar-when-embedded-scalar
    :*  (some (~(got by when-scalars) %scalar1))
      [%case-when-then (~(got by when-scalars) %scalar1) then-q-col-1]
      ~
      literal-1
    ==
  ==

::  ::::::::::::::::::::::
::  :::: TARGET TESTS ::::
::  ::::::::::::::::::::::
::  TODO: target is not null-checked -- add test
::
::  set up some costant context for tests
::
++  target-q-col-1             [%qualified-column qualified-table-1 %col1 ~]
++  target-q-col-2             [%qualified-column qualified-table-1 %col2 ~]
++  target-q-col-3             [%qualified-column qualified-table-1 %col3 ~]
::
++  target-u-col-4             [%unqualified-column %col4 ~]
++  target-u-col-5             [%unqualified-column %col5 ~]
++  target-u-col-6             [%unqualified-column %col6 ~]
::
++  target-qual-type-lookup       %-  mk-qualified-type-lookup
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
++  target-unqual-type-lookup       %-  mk-unqualified-type-lookup
                                    :~
                                      [%col4 ~.ud]
                                      [%col5 ~.ud]
                                      [%col6 ~.ud]
                                    ==
::
++  target-qualifier-lookup  %-  malt
                             %-  limo
                             :~
                               [%col4 ~[qualified-table-1]]
                               [%col5 ~[qualified-table-1]]
                               [%col6 ~[qualified-table-1]]
                             ==
::
++  target-named-ctes        *named-ctes
::
++  target-row               %-  mk-indexed-row
                             :~
                               [%col1 1]
                               [%col2 2]
                               [%col3 3]
                               [%col4 4]
                               [%col5 5]
                               [%col6 6]
                             ==
::
++  target-scalars           %-  malt
                             %-  limo
                             :~
                               :-  %scalar1
                               :*  %if-then-else
                                 if=true-predicate
                                 then=[target-q-col-1]
                                 else=[target-q-col-2]
                               ==
                             ==
::
::  test target as literal value
++  test-case-target-literal-value
  =/  cases
    :~
      [%case-when-then [%literal-value [~.ud 1]] target-q-col-1]
      [%case-when-then [%literal-value [~.ud 2]] target-q-col-2]
    ==
  =/  case-expr=case:ast
    :*  %case
      target=(some [%literal-value [~.ud 1]])
      cases=cases
      else=(some target-q-col-3)
    ==
  =/  scalar-to-apply
    (prepare-scalar case-expr target-named-ctes [target-qualifier-lookup target-qual-type-lookup] target-scalars)
  %+  expect-eq
    !>  [~.ud 1]
    !>  (apply-scalar target-row scalar-to-apply)
::
::  test target as qualified column
++  test-case-target-qualified-col
  =/  cases
    :~
      [%case-when-then [%literal-value [~.ud 1]] target-q-col-1]
      [%case-when-then [%literal-value [~.ud 2]] target-q-col-2]
    ==
  =/  case-expr=case:ast
    :*  %case
      target=(some target-q-col-1)
      cases=cases
      else=(some target-q-col-3)
    ==
  =/  scalar-to-apply
    (prepare-scalar case-expr target-named-ctes [target-qualifier-lookup target-qual-type-lookup] target-scalars)
  %+  expect-eq
    !>  [~.ud 1]
    !>  (apply-scalar target-row scalar-to-apply)
::
::  test target as unqualified column
++  test-case-target-unqualified-col
  =/  cases
    :~
      [%case-when-then [%literal-value [~.ud 4]] target-u-col-4]
      [%case-when-then [%literal-value [~.ud 5]] target-u-col-5]
    ==
  =/  case-expr=case:ast
    :*  %case
      target=(some target-u-col-4)
      cases=cases
      else=(some target-u-col-6)
    ==
  =/  scalar-to-apply
    (prepare-scalar case-expr target-named-ctes [target-qualifier-lookup target-qual-type-lookup] target-scalars)
  %+  expect-eq
    !>  [~.ud 4]
    !>  (apply-scalar target-row scalar-to-apply)
::
::  test target as scalar alias
++  test-case-target-scalar-alias
  =/  cases
    :~
      [%case-when-then [%literal-value [~.ud 1]] target-q-col-1]
      [%case-when-then [%literal-value [~.ud 2]] target-q-col-2]
    ==
  =/  case-expr=case:ast
    :*  %case
      target=(some [%scalar-alias %scalar1])
      cases=cases
      else=(some target-q-col-3)
    ==
  =/  scalar-to-apply
    (prepare-scalar case-expr target-named-ctes [target-qualifier-lookup target-qual-type-lookup] target-scalars)
  %+  expect-eq
    !>  [~.ud 1]
    !>  (apply-scalar target-row scalar-to-apply)
::
::  test target as embedded scalar
++  test-case-target-embedded-scalar
  =/  cases
    :~
      [%case-when-then [%literal-value [~.ud 1]] target-q-col-1]
      [%case-when-then [%literal-value [~.ud 2]] target-q-col-2]
    ==
  =/  case-expr=case:ast
    :*  %case
      target=(some (~(got by target-scalars) %scalar1))
      cases=cases
      else=(some target-q-col-3)
    ==
  =/  scalar-to-apply
    (prepare-scalar case-expr target-named-ctes [target-qualifier-lookup target-qual-type-lookup] target-scalars)
  %+  expect-eq
    !>  [~.ud 1]
    !>  (apply-scalar target-row scalar-to-apply)

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
    !>  literal-1
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
      [%case-when-then literal-value-1 then-q-col-1]
      [%case-when-then literal-value-2 then-q-col-2]
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
    !>  literal-1
    !>  (apply-scalar then-row scalar-to-apply)
::
++  test-case-simple-then-unqualified-col-01
  =/  cases
    :~
      [%case-when-then literal-value-1 then-u-col-4]
      [%case-when-then literal-value-2 then-u-col-5]
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
      [%case-when-then literal-value-1 [%literal-value [~.t 'foo']]]
      [%case-when-then literal-value-2 [%literal-value [~.t 'baz']]]
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
      [%case-when-then literal-value-1 [%scalar-alias %scalar1]]
      [%case-when-then literal-value-2 then-q-col-2]
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
      [%case-when-then literal-value-1 (~(got by then-scalars) %scalar1)]
      [%case-when-then literal-value-2 then-q-col-2]
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
    !>  literal-2
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
      [%case-when-then literal-value-2 else-q-col-2]
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
    !>  literal-2
    !>  (apply-scalar else-row scalar-to-apply)
::
++  test-case-simple-else-unqualified-col-01
  =/  cases
    :~
      [%case-when-then literal-value-2 else-u-col-4]
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
      [%case-when-then literal-value-2 [%literal-value [~.t 'foo']]]
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
      [%case-when-then literal-value-2 else-q-col-2]
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
      [%case-when-then literal-value-2 else-q-col-2]
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
