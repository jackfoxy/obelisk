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
                               %-  addr-columns
                                   :~  [%column %col1 ~.ud 0]
                                       [%column %col2 ~.ud 0]
                                       [%column %col3 ~.ud 0]
                                       [%column %col4 ~.ud 0]
                                       [%column %other-col4 ~.ud 0]
                                       [%column %col5 ~.ud 0]
                                       [%column %col6 ~.ud 0]
                                       [%column %col7 ~.ud 0]
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
                                    ==
                          :-  %scalar2
                              %:  prepare-scalar
                                    ^-  scalar-function:ast
                                    :*  %if-then-else
                                      if=true-predicate
                                      then=[%literal-value [~.ud 4]]
                                      else=[%literal-value [~.ud 5]]
                                    ==
                                    table-named-ctes
                                    qual-lookup
                                    qual-map-meta
                                    *(map @tas resolved-scalar)
                                    ==
                          ==
::
::
::  :::::::::::::::::::::::::::
::  :::: BUILTIN FNS TESTS ::::
::  :::::::::::::::::::::::::::
::
::  %abs tests
::
++  test-case-when-searched-eq
  %:  run-scalar-tests
    table-named-ctes
    qual-lookup
    qual-map-meta
    resolved-scalars
    table-row
    :~
    :-  %abs
    :*  [%abs [%literal-value [~.sd -1]]]
      [~.sd 1]
    ==
  ==
  ==
::
--
