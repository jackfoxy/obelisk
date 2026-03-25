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
++  u-col-4           [%unqualified-column %col4 ~]
++  u-col-5           [%unqualified-column %col5 ~]
++  u-col-6           [%unqualified-column %col6 ~]
++  u-col-7           [%unqualified-column %col7 ~]
++  u-col-8           [%unqualified-column %col8 ~]
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
::  abs test helpers
::  @sd: col1=-3 (negative 3), col2=--2 (positive 2)
::  @rd: col3=.~-1, col4=.~2
::
::  qualified: col1=@sd neg, col2=@sd pos, col3=@rd neg, col4=@rd pos, col5=@ud
::
++  abs-qual-map-meta
  %-  mk-qualified-map-meta
      :~  :-  qualified-table-1
              %-  addr-columns
                  :~  [%column %col1 ~.sd 0]
                      [%column %col2 ~.sd 0]
                      [%column %col3 ~.rd 0]
                      [%column %col4 ~.rd 0]
                      [%column %col5 ~.ud 0]
                      ==
          ==
::
++  abs-q-col-4  [%qualified-column qualified-table-1 %col4 ~]
++  abs-q-col-5  [%qualified-column qualified-table-1 %col5 ~]
::
++  abs-qual-table-row  %-  mk-indexed-row
                        :~  [%col1 -3]                       ::  @sd -3
                            [%col2 --2]                      ::  @sd --2
                            [%col3 .~-1]                     ::  @rd -1.0
                            [%col4 .~2]                      ::  @rd 2.0
                            [%col5 5]                        ::  @ud 5
                        ==
::
::  unqualified: col4=@sd neg, col5=@sd pos, col6=@rd neg, col7=@rd pos, 
::  col8=@ud
::
++  abs-unqual-map-meta
  :-  %unqualified-map-meta
      %-  mk-unqualified-typ-addr-lookup
          %-  addr-columns
              :~  [%column %col4 ~.sd 0]
                  [%column %col5 ~.sd 0]
                  [%column %col6 ~.rd 0]
                  [%column %col7 ~.rd 0]
                  [%column %col8 ~.ud 0]
                  ==
::
++  abs-unqual-lookup  %-  malt  %-  limo
                       :~  [%col4 ~[qualified-table-1]]
                           [%col5 ~[qualified-table-1]]
                           [%col6 ~[qualified-table-1]]
                           [%col7 ~[qualified-table-1]]
                           [%col8 ~[qualified-table-1]]
                       ==
::
++  abs-unqual-table-row  %-  mk-indexed-row
                          :~  [%col4 -3]                     ::  @sd -3
                              [%col5 --2]                    ::  @sd --2
                              [%col6 .~-1]                   ::  @rd -1.0
                              [%col7 .~2]                    ::  @rd 2.0
                              [%col8 8]                      ::  @ud 8
                          ==
::
::  %sign test helpers
::  @sd: col1=--0 (zero), col2=-1, col3=--1
::  @rd: col4=.~0, col5=.~-1, col6=.~1
::
::  qualified: col1=@sd zero, col2=@sd neg, col3=@sd pos
::             col4=@rd zero, col5=@rd neg, col6=@rd pos
::             col7=@ud zero, col8=@ud pos
::
++  sign-qual-map-meta
  %-  mk-qualified-map-meta
      :~  :-  qualified-table-1
              %-  addr-columns
                  :~  [%column %col1 ~.sd 0]
                      [%column %col2 ~.sd 0]
                      [%column %col3 ~.sd 0]
                      [%column %col4 ~.rd 0]
                      [%column %col5 ~.rd 0]
                      [%column %col6 ~.rd 0]
                      [%column %col7 ~.ud 0]
                      [%column %col8 ~.ud 0]
                      ==
          ==
::
++  sign-q-col-4  [%qualified-column qualified-table-1 %col4 ~]
++  sign-q-col-5  [%qualified-column qualified-table-1 %col5 ~]
++  sign-q-col-6  [%qualified-column qualified-table-1 %col6 ~]
++  sign-q-col-7  [%qualified-column qualified-table-1 %col7 ~]
++  sign-q-col-8  [%qualified-column qualified-table-1 %col8 ~]
::
++  sign-qual-table-row  %-  mk-indexed-row
                         :~  [%col1 --0]                      ::  @sd --0 (zero)
                             [%col2 -1]                       ::  @sd -1
                             [%col3 --1]                      ::  @sd --1
                             [%col4 0]                        ::  @rd .~0
                             [%col5 .~-1]                     ::  @rd .~-1
                             [%col6 .~1]                      ::  @rd .~1
                             [%col7 0]                        ::  @ud 0
                             [%col8 1]                        ::  @ud 1
                         ==
::
::  unqualified: col1=@sd zero, col2=@sd neg, col3=@sd pos
::               col4=@rd zero, col5=@rd neg, col6=@rd pos
::               col7=@ud zero, col8=@ud pos
::
++  sign-unqual-map-meta
  :-  %unqualified-map-meta
      %-  mk-unqualified-typ-addr-lookup
          %-  addr-columns
              :~  [%column %col1 ~.sd 0]
                  [%column %col2 ~.sd 0]
                  [%column %col3 ~.sd 0]
                  [%column %col4 ~.rd 0]
                  [%column %col5 ~.rd 0]
                  [%column %col6 ~.rd 0]
                  [%column %col7 ~.ud 0]
                  [%column %col8 ~.ud 0]
                  ==
::
++  sign-unqual-lookup  %-  malt  %-  limo
                        :~  [%col1 ~[qualified-table-1]]
                            [%col2 ~[qualified-table-1]]
                            [%col3 ~[qualified-table-1]]
                            [%col4 ~[qualified-table-1]]
                            [%col5 ~[qualified-table-1]]
                            [%col6 ~[qualified-table-1]]
                            [%col7 ~[qualified-table-1]]
                            [%col8 ~[qualified-table-1]]
                        ==
::
++  sign-u-col-1  [%unqualified-column %col1 ~]
++  sign-u-col-2  [%unqualified-column %col2 ~]
++  sign-u-col-3  [%unqualified-column %col3 ~]
::
++  sign-unqual-table-row  %-  mk-indexed-row
                           :~  [%col1 --0]                    ::  @sd --0 (zero)
                               [%col2 -1]                     ::  @sd -1
                               [%col3 --1]                    ::  @sd --1
                               [%col4 0]                      ::  @rd .~0
                               [%col5 .~-1]                   ::  @rd .~-1
                               [%col6 .~1]                    ::  @rd .~1
                               [%col7 0]                      ::  @ud 0
                               [%col8 1]                      ::  @ud 1
                           ==
::
::  %sqrt test helpers
::  @rd: col2=.~1, col3=.~4
::  @sd: col4=--0, col5=--1, col6=--4
::
::  qualified: col1=@rd 0, col2=@rd 1.0, col3=@rd 4.0
::             col4=@sd --0, col5=@sd --1, col6=@sd --4
::             col7=@ud 0, col8=@ud 1, col9=@ud 4
::
++  sqrt-qual-map-meta
  %-  mk-qualified-map-meta
      :~  :-  qualified-table-1
              %-  addr-columns
                  :~  [%column %col1 ~.rd 0]
                      [%column %col2 ~.rd 0]
                      [%column %col3 ~.rd 0]
                      [%column %col4 ~.sd 0]
                      [%column %col5 ~.sd 0]
                      [%column %col6 ~.sd 0]
                      [%column %col7 ~.ud 0]
                      [%column %col8 ~.ud 0]
                      [%column %col9 ~.ud 0]
                      ==
          ==
::
++  sqrt-q-col-1  [%qualified-column qualified-table-1 %col1 ~]
++  sqrt-q-col-2  [%qualified-column qualified-table-1 %col2 ~]
++  sqrt-q-col-3  [%qualified-column qualified-table-1 %col3 ~]
++  sqrt-q-col-4  [%qualified-column qualified-table-1 %col4 ~]
++  sqrt-q-col-5  [%qualified-column qualified-table-1 %col5 ~]
++  sqrt-q-col-6  [%qualified-column qualified-table-1 %col6 ~]
++  sqrt-q-col-7  [%qualified-column qualified-table-1 %col7 ~]
++  sqrt-q-col-8  [%qualified-column qualified-table-1 %col8 ~]
++  sqrt-q-col-9  [%qualified-column qualified-table-1 %col9 ~]
::
++  sqrt-qual-table-row  %-  mk-indexed-row
                         :~  [%col1 0]                        ::  @rd 0
                             [%col2 .~1]                      ::  @rd 1.0
                             [%col3 .~4]                      ::  @rd 4.0
                             [%col4 --0]                      ::  @sd --0
                             [%col5 --1]                      ::  @sd --1
                             [%col6 --4]                      ::  @sd --4
                             [%col7 0]                        ::  @ud 0
                             [%col8 1]                        ::  @ud 1
                             [%col9 4]                        ::  @ud 4
                         ==
::
::  unqualified: col1=@rd 0, col2=@rd 1.0, col3=@rd 4.0
::               col4=@sd --0, col5=@sd --1, col6=@sd --4
::               col7=@ud 0, col8=@ud 1, col9=@ud 4
::
++  sqrt-unqual-map-meta
  :-  %unqualified-map-meta
      %-  mk-unqualified-typ-addr-lookup
          %-  addr-columns
              :~  [%column %col1 ~.rd 0]
                  [%column %col2 ~.rd 0]
                  [%column %col3 ~.rd 0]
                  [%column %col4 ~.sd 0]
                  [%column %col5 ~.sd 0]
                  [%column %col6 ~.sd 0]
                  [%column %col7 ~.ud 0]
                  [%column %col8 ~.ud 0]
                  [%column %col9 ~.ud 0]
                  ==
::
++  sqrt-unqual-lookup  %-  malt  %-  limo
                        :~  [%col1 ~[qualified-table-1]]
                            [%col2 ~[qualified-table-1]]
                            [%col3 ~[qualified-table-1]]
                            [%col4 ~[qualified-table-1]]
                            [%col5 ~[qualified-table-1]]
                            [%col6 ~[qualified-table-1]]
                            [%col7 ~[qualified-table-1]]
                            [%col8 ~[qualified-table-1]]
                            [%col9 ~[qualified-table-1]]
                        ==
::
++  sqrt-u-col-1  [%unqualified-column %col1 ~]
++  sqrt-u-col-2  [%unqualified-column %col2 ~]
++  sqrt-u-col-3  [%unqualified-column %col3 ~]
++  sqrt-u-col-4  [%unqualified-column %col4 ~]
++  sqrt-u-col-5  [%unqualified-column %col5 ~]
++  sqrt-u-col-6  [%unqualified-column %col6 ~]
++  sqrt-u-col-7  [%unqualified-column %col7 ~]
++  sqrt-u-col-8  [%unqualified-column %col8 ~]
++  sqrt-u-col-9  [%unqualified-column %col9 ~]
::
++  sqrt-unqual-table-row  %-  mk-indexed-row
                           :~  [%col1 0]                      ::  @rd 0
                               [%col2 .~1]                    ::  @rd 1.0
                               [%col3 .~4]                    ::  @rd 4.0
                               [%col4 --0]                    ::  @sd --0
                               [%col5 --1]                    ::  @sd --1
                               [%col6 --4]                    ::  @sd --4
                               [%col7 0]                      ::  @ud 0
                               [%col8 1]                      ::  @ud 1
                               [%col9 4]                      ::  @ud 4
                           ==
::
::  %round test helpers
::  @rd: col2=.~1, col3=.~2
::  @sd: col4=--0, col5=--1, col6=--2
::  length=[~.ud 0] for all cases (round to integer)
::
::  qualified: col1=@rd 0, col2=@rd 1.0, col3=@rd 2.0
::             col4=@sd --0, col5=@sd --1, col6=@sd --2
::             col7=@ud 0, col8=@ud 1, col9=@ud 2
::
++  round-qual-map-meta
  %-  mk-qualified-map-meta
      :~  :-  qualified-table-1
              %-  addr-columns
                  :~  [%column %col1 ~.rd 0]
                      [%column %col2 ~.rd 0]
                      [%column %col3 ~.rd 0]
                      [%column %col4 ~.sd 0]
                      [%column %col5 ~.sd 0]
                      [%column %col6 ~.sd 0]
                      [%column %col7 ~.ud 0]
                      [%column %col8 ~.ud 0]
                      [%column %col9 ~.ud 0]
                      ==
          ==
::
++  round-q-col-1  [%qualified-column qualified-table-1 %col1 ~]
++  round-q-col-2  [%qualified-column qualified-table-1 %col2 ~]
++  round-q-col-3  [%qualified-column qualified-table-1 %col3 ~]
++  round-q-col-4  [%qualified-column qualified-table-1 %col4 ~]
++  round-q-col-5  [%qualified-column qualified-table-1 %col5 ~]
++  round-q-col-6  [%qualified-column qualified-table-1 %col6 ~]
++  round-q-col-7  [%qualified-column qualified-table-1 %col7 ~]
++  round-q-col-8  [%qualified-column qualified-table-1 %col8 ~]
++  round-q-col-9  [%qualified-column qualified-table-1 %col9 ~]
::
++  round-qual-table-row  %-  mk-indexed-row
                          :~  [%col1 0]                        ::  @rd 0
                              [%col2 .~1]                      ::  @rd 1.0
                              [%col3 .~2]                      ::  @rd 2.0
                              [%col4 --0]                      ::  @sd --0
                              [%col5 --1]                      ::  @sd --1
                              [%col6 --2]                      ::  @sd --2
                              [%col7 0]                        ::  @ud 0
                              [%col8 1]                        ::  @ud 1
                              [%col9 2]                        ::  @ud 2
                          ==
::
::  unqualified: col1=@rd 0, col2=@rd 1.0, col3=@rd 2.0
::               col4=@sd --0, col5=@sd --1, col6=@sd --2
::               col7=@ud 0, col8=@ud 1, col9=@ud 2
::
++  round-unqual-map-meta
  :-  %unqualified-map-meta
      %-  mk-unqualified-typ-addr-lookup
          %-  addr-columns
              :~  [%column %col1 ~.rd 0]
                  [%column %col2 ~.rd 0]
                  [%column %col3 ~.rd 0]
                  [%column %col4 ~.sd 0]
                  [%column %col5 ~.sd 0]
                  [%column %col6 ~.sd 0]
                  [%column %col7 ~.ud 0]
                  [%column %col8 ~.ud 0]
                  [%column %col9 ~.ud 0]
                  ==
::
++  round-unqual-lookup  %-  malt  %-  limo
                         :~  [%col1 ~[qualified-table-1]]
                             [%col2 ~[qualified-table-1]]
                             [%col3 ~[qualified-table-1]]
                             [%col4 ~[qualified-table-1]]
                             [%col5 ~[qualified-table-1]]
                             [%col6 ~[qualified-table-1]]
                             [%col7 ~[qualified-table-1]]
                             [%col8 ~[qualified-table-1]]
                             [%col9 ~[qualified-table-1]]
                         ==
::
++  round-u-col-1  [%unqualified-column %col1 ~]
++  round-u-col-2  [%unqualified-column %col2 ~]
++  round-u-col-3  [%unqualified-column %col3 ~]
++  round-u-col-4  [%unqualified-column %col4 ~]
++  round-u-col-5  [%unqualified-column %col5 ~]
++  round-u-col-6  [%unqualified-column %col6 ~]
++  round-u-col-7  [%unqualified-column %col7 ~]
++  round-u-col-8  [%unqualified-column %col8 ~]
++  round-u-col-9  [%unqualified-column %col9 ~]
::
++  round-unqual-table-row  %-  mk-indexed-row
                            :~  [%col1 0]                      ::  @rd 0
                                [%col2 .~1]                    ::  @rd 1.0
                                [%col3 .~2]                    ::  @rd 2.0
                                [%col4 --0]                    ::  @sd --0
                                [%col5 --1]                    ::  @sd --1
                                [%col6 --2]                    ::  @sd --2
                                [%col7 0]                      ::  @ud 0
                                [%col8 1]                      ::  @ud 1
                                [%col9 2]                      ::  @ud 2
                            ==
::
::  %floor test helpers
::  @rd: col2=.~1.5, col3=.~-1.5
::  floor(.~1.5) = .~1, floor(.~-1.5) = .~-2
::  @sd and @ud: pass-through
::
::  qualified: col1=@rd 0, col2=@rd 1.5, col3=@rd -1.5
::             col4=@sd --0, col5=@sd --1, col6=@sd -1
::             col7=@ud 0, col8=@ud 1, col9=@ud 2
::
++  floor-qual-map-meta
  %-  mk-qualified-map-meta
      :~  :-  qualified-table-1
              %-  addr-columns
                  :~  [%column %col1 ~.rd 0]
                      [%column %col2 ~.rd 0]
                      [%column %col3 ~.rd 0]
                      [%column %col4 ~.sd 0]
                      [%column %col5 ~.sd 0]
                      [%column %col6 ~.sd 0]
                      [%column %col7 ~.ud 0]
                      [%column %col8 ~.ud 0]
                      [%column %col9 ~.ud 0]
                      ==
          ==
::
++  floor-q-col-1  [%qualified-column qualified-table-1 %col1 ~]
++  floor-q-col-2  [%qualified-column qualified-table-1 %col2 ~]
++  floor-q-col-3  [%qualified-column qualified-table-1 %col3 ~]
++  floor-q-col-4  [%qualified-column qualified-table-1 %col4 ~]
++  floor-q-col-5  [%qualified-column qualified-table-1 %col5 ~]
++  floor-q-col-6  [%qualified-column qualified-table-1 %col6 ~]
++  floor-q-col-7  [%qualified-column qualified-table-1 %col7 ~]
++  floor-q-col-8  [%qualified-column qualified-table-1 %col8 ~]
++  floor-q-col-9  [%qualified-column qualified-table-1 %col9 ~]
::
++  floor-qual-table-row  %-  mk-indexed-row
                          :~  [%col1 0]                        ::  @rd 0
                              [%col2 .~1.5]                    ::  @rd 1.5
                              [%col3 .~-1.5]                   ::  @rd -1.5
                              [%col4 --0]                      ::  @sd --0
                              [%col5 --1]                      ::  @sd --1
                              [%col6 -1]                       ::  @sd -1
                              [%col7 0]                        ::  @ud 0
                              [%col8 1]                        ::  @ud 1
                              [%col9 2]                        ::  @ud 2
                          ==
::
::  unqualified: col1=@rd 0, col2=@rd 1.5, col3=@rd -1.5
::               col4=@sd --0, col5=@sd --1, col6=@sd -1
::               col7=@ud 0, col8=@ud 1, col9=@ud 2
::
++  floor-unqual-map-meta
  :-  %unqualified-map-meta
      %-  mk-unqualified-typ-addr-lookup
          %-  addr-columns
              :~  [%column %col1 ~.rd 0]
                  [%column %col2 ~.rd 0]
                  [%column %col3 ~.rd 0]
                  [%column %col4 ~.sd 0]
                  [%column %col5 ~.sd 0]
                  [%column %col6 ~.sd 0]
                  [%column %col7 ~.ud 0]
                  [%column %col8 ~.ud 0]
                  [%column %col9 ~.ud 0]
                  ==
::
++  floor-unqual-lookup  %-  malt  %-  limo
                         :~  [%col1 ~[qualified-table-1]]
                             [%col2 ~[qualified-table-1]]
                             [%col3 ~[qualified-table-1]]
                             [%col4 ~[qualified-table-1]]
                             [%col5 ~[qualified-table-1]]
                             [%col6 ~[qualified-table-1]]
                             [%col7 ~[qualified-table-1]]
                             [%col8 ~[qualified-table-1]]
                             [%col9 ~[qualified-table-1]]
                         ==
::
++  floor-u-col-1  [%unqualified-column %col1 ~]
++  floor-u-col-2  [%unqualified-column %col2 ~]
++  floor-u-col-3  [%unqualified-column %col3 ~]
++  floor-u-col-4  [%unqualified-column %col4 ~]
++  floor-u-col-5  [%unqualified-column %col5 ~]
++  floor-u-col-6  [%unqualified-column %col6 ~]
++  floor-u-col-7  [%unqualified-column %col7 ~]
++  floor-u-col-8  [%unqualified-column %col8 ~]
++  floor-u-col-9  [%unqualified-column %col9 ~]
::
++  floor-unqual-table-row  %-  mk-indexed-row
                            :~  [%col1 0]                      ::  @rd 0
                                [%col2 .~1.5]                  ::  @rd 1.5
                                [%col3 .~-1.5]                 ::  @rd -1.5
                                [%col4 --0]                    ::  @sd --0
                                [%col5 --1]                    ::  @sd --1
                                [%col6 -1]                     ::  @sd -1
                                [%col7 0]                      ::  @ud 0
                                [%col8 1]                      ::  @ud 1
                                [%col9 2]                      ::  @ud 2
                            ==
::
::  %ceiling test helpers
::  @rd: col2=.~1.5, col3=.~-1.5
::  ceiling(.~1.5) = .~2, ceiling(.~-1.5) = .~-1
::  @sd and @ud: pass-through
::
::  qualified: col1=@rd 0, col2=@rd 1.5, col3=@rd -1.5
::             col4=@sd --0, col5=@sd --1, col6=@sd -1
::             col7=@ud 0, col8=@ud 1, col9=@ud 2
::
++  ceiling-qual-map-meta
  %-  mk-qualified-map-meta
      :~  :-  qualified-table-1
              %-  addr-columns
                  :~  [%column %col1 ~.rd 0]
                      [%column %col2 ~.rd 0]
                      [%column %col3 ~.rd 0]
                      [%column %col4 ~.sd 0]
                      [%column %col5 ~.sd 0]
                      [%column %col6 ~.sd 0]
                      [%column %col7 ~.ud 0]
                      [%column %col8 ~.ud 0]
                      [%column %col9 ~.ud 0]
                      ==
          ==
::
++  ceiling-q-col-1  [%qualified-column qualified-table-1 %col1 ~]
++  ceiling-q-col-2  [%qualified-column qualified-table-1 %col2 ~]
++  ceiling-q-col-3  [%qualified-column qualified-table-1 %col3 ~]
++  ceiling-q-col-4  [%qualified-column qualified-table-1 %col4 ~]
++  ceiling-q-col-5  [%qualified-column qualified-table-1 %col5 ~]
++  ceiling-q-col-6  [%qualified-column qualified-table-1 %col6 ~]
++  ceiling-q-col-7  [%qualified-column qualified-table-1 %col7 ~]
++  ceiling-q-col-8  [%qualified-column qualified-table-1 %col8 ~]
++  ceiling-q-col-9  [%qualified-column qualified-table-1 %col9 ~]
::
++  ceiling-qual-table-row  %-  mk-indexed-row
                             :~  [%col1 0]                        ::  @rd 0
                                 [%col2 .~1.5]                  ::  @rd 1.5
                                 [%col3 .~-1.5]                 ::  @rd -1.5
                                 [%col4 --0]                      ::  @sd --0
                                 [%col5 --1]                      ::  @sd --1
                                 [%col6 -1]                       ::  @sd -1
                                 [%col7 0]                        ::  @ud 0
                                 [%col8 1]                        ::  @ud 1
                                 [%col9 2]                        ::  @ud 2
                             ==
::
::  unqualified: col1=@rd 0, col2=@rd 1.5, col3=@rd -1.5
::               col4=@sd --0, col5=@sd --1, col6=@sd -1
::               col7=@ud 0, col8=@ud 1, col9=@ud 2
::
++  ceiling-unqual-map-meta
  :-  %unqualified-map-meta
      %-  mk-unqualified-typ-addr-lookup
          %-  addr-columns
              :~  [%column %col1 ~.rd 0]
                  [%column %col2 ~.rd 0]
                  [%column %col3 ~.rd 0]
                  [%column %col4 ~.sd 0]
                  [%column %col5 ~.sd 0]
                  [%column %col6 ~.sd 0]
                  [%column %col7 ~.ud 0]
                  [%column %col8 ~.ud 0]
                  [%column %col9 ~.ud 0]
                  ==
::
++  ceiling-unqual-lookup  %-  malt  %-  limo
                            :~  [%col1 ~[qualified-table-1]]
                                [%col2 ~[qualified-table-1]]
                                [%col3 ~[qualified-table-1]]
                                [%col4 ~[qualified-table-1]]
                                [%col5 ~[qualified-table-1]]
                                [%col6 ~[qualified-table-1]]
                                [%col7 ~[qualified-table-1]]
                                [%col8 ~[qualified-table-1]]
                                [%col9 ~[qualified-table-1]]
                            ==
::
++  ceiling-u-col-1  [%unqualified-column %col1 ~]
++  ceiling-u-col-2  [%unqualified-column %col2 ~]
++  ceiling-u-col-3  [%unqualified-column %col3 ~]
++  ceiling-u-col-4  [%unqualified-column %col4 ~]
++  ceiling-u-col-5  [%unqualified-column %col5 ~]
++  ceiling-u-col-6  [%unqualified-column %col6 ~]
++  ceiling-u-col-7  [%unqualified-column %col7 ~]
++  ceiling-u-col-8  [%unqualified-column %col8 ~]
++  ceiling-u-col-9  [%unqualified-column %col9 ~]
::
++  ceiling-unqual-table-row  %-  mk-indexed-row
                               :~  [%col1 0]                      ::  @rd 0
                                   [%col2 .~1.5]                ::  @rd 1.5
                                   [%col3 .~-1.5]               ::  @rd -1.5
                                   [%col4 --0]                    ::  @sd --0
                                   [%col5 --1]                    ::  @sd --1
                                   [%col6 -1]                     ::  @sd -1
                                   [%col7 0]                      ::  @ud 0
                                   [%col8 1]                      ::  @ud 1
                                   [%col9 2]                      ::  @ud 2
                               ==
::
::  %round test helpers (fractional/signed data; positive and negative length)
::  @rd: col2=.~1.5, col3=.~-1.5, col4=.~15, col5=.~-15
::  @sd: col6=--1.234, col7=-1.234
::  round(.~1.5, @ud 0) = .~2   (half rounds up toward +inf)
::  round(.~-1.5, @ud 0) = .~-1 (toward +inf)
::  round(.~15, @sd -1) = .~20, round(.~-15, @sd -1) = .~-10
::  round(--1.234, @sd -1) = --1.230, round(-1.234, @sd -1) = -1.230
::  @ud 1.235: round(1.235, @sd -1) = 1.240  (half-up boundary)
::
++  round-frac-qual-map-meta
  %-  mk-qualified-map-meta
      :~  :-  qualified-table-1
              %-  addr-columns
                  :~  [%column %col1 ~.rd 0]
                      [%column %col2 ~.rd 0]
                      [%column %col3 ~.rd 0]
                      [%column %col4 ~.rd 0]
                      [%column %col5 ~.rd 0]
                      [%column %col6 ~.sd 0]
                      [%column %col7 ~.sd 0]
                      [%column %col8 ~.ud 0]
                      [%column %col9 ~.ud 0]
                      ==
          ==
::
++  round-frac-q-col-1  [%qualified-column qualified-table-1 %col1 ~]
++  round-frac-q-col-2  [%qualified-column qualified-table-1 %col2 ~]
++  round-frac-q-col-3  [%qualified-column qualified-table-1 %col3 ~]
++  round-frac-q-col-4  [%qualified-column qualified-table-1 %col4 ~]
++  round-frac-q-col-5  [%qualified-column qualified-table-1 %col5 ~]
++  round-frac-q-col-6  [%qualified-column qualified-table-1 %col6 ~]
++  round-frac-q-col-7  [%qualified-column qualified-table-1 %col7 ~]
++  round-frac-q-col-8  [%qualified-column qualified-table-1 %col8 ~]
++  round-frac-q-col-9  [%qualified-column qualified-table-1 %col9 ~]
::
++  round-frac-qual-table-row  %-  mk-indexed-row
                               :~  [%col1 0]                        ::  @rd 0
                                   [%col2 .~1.5]                    ::  @rd 1.5
                                   [%col3 .~-1.5]                   ::  @rd -1.5
                                   [%col4 .~15]                     ::  @rd 15.0
                                   [%col5 .~-15]                    ::  @rd -15.0
                                   [%col6 --1.234]                  ::  @sd --1.234
                                   [%col7 -1.234]                   ::  @sd -1.234
                                   [%col8 1.234]                    ::  @ud 1.234
                                   [%col9 1.235]                    ::  @ud 1.235
                               ==
::
++  round-frac-unqual-map-meta
  :-  %unqualified-map-meta
      %-  mk-unqualified-typ-addr-lookup
          %-  addr-columns
              :~  [%column %col1 ~.rd 0]
                  [%column %col2 ~.rd 0]
                  [%column %col3 ~.rd 0]
                  [%column %col4 ~.rd 0]
                  [%column %col5 ~.rd 0]
                  [%column %col6 ~.sd 0]
                  [%column %col7 ~.sd 0]
                  [%column %col8 ~.ud 0]
                  [%column %col9 ~.ud 0]
                  ==
::
++  round-frac-unqual-lookup  %-  malt  %-  limo
                              :~  [%col1 ~[qualified-table-1]]
                                  [%col2 ~[qualified-table-1]]
                                  [%col3 ~[qualified-table-1]]
                                  [%col4 ~[qualified-table-1]]
                                  [%col5 ~[qualified-table-1]]
                                  [%col6 ~[qualified-table-1]]
                                  [%col7 ~[qualified-table-1]]
                                  [%col8 ~[qualified-table-1]]
                                  [%col9 ~[qualified-table-1]]
                              ==
::
++  round-frac-u-col-1  [%unqualified-column %col1 ~]
++  round-frac-u-col-2  [%unqualified-column %col2 ~]
++  round-frac-u-col-3  [%unqualified-column %col3 ~]
++  round-frac-u-col-4  [%unqualified-column %col4 ~]
++  round-frac-u-col-5  [%unqualified-column %col5 ~]
++  round-frac-u-col-6  [%unqualified-column %col6 ~]
++  round-frac-u-col-7  [%unqualified-column %col7 ~]
++  round-frac-u-col-8  [%unqualified-column %col8 ~]
++  round-frac-u-col-9  [%unqualified-column %col9 ~]
::
++  round-frac-unqual-table-row  %-  mk-indexed-row
                                 :~  [%col1 0]                        ::  @rd 0
                                     [%col2 .~1.5]                    ::  @rd 1.5
                                     [%col3 .~-1.5]                   ::  @rd -1.5
                                     [%col4 .~15]                     ::  @rd 15.0
                                     [%col5 .~-15]                    ::  @rd -15.0
                                     [%col6 --1.234]                  ::  @sd --1.234
                                     [%col7 -1.234]                   ::  @sd -1.234
                                     [%col8 1.234]                    ::  @ud 1.234
                                     [%col9 1.235]                    ::  @ud 1.235
                                 ==
::
::  %max / %min test helpers
::  @rd: col1=.~-3 (negative), col2=.~2 (positive)
::  @sd: col3=-3 (negative), col4=--2 (positive)
::  @ud: col5=2 (small), col6=5 (large)
::
::  qualified: col1=@rd .~-3, col2=@rd .~2
::             col3=@sd -3, col4=@sd --2
::             col5=@ud 2, col6=@ud 5
::
++  minmax-qual-map-meta
  %-  mk-qualified-map-meta
      :~  :-  qualified-table-1
              %-  addr-columns
                  :~  [%column %col1 ~.rd 0]
                      [%column %col2 ~.rd 0]
                      [%column %col3 ~.sd 0]
                      [%column %col4 ~.sd 0]
                      [%column %col5 ~.ud 0]
                      [%column %col6 ~.ud 0]
                      ==
          ==
::
++  minmax-q-col-1  [%qualified-column qualified-table-1 %col1 ~]
++  minmax-q-col-2  [%qualified-column qualified-table-1 %col2 ~]
++  minmax-q-col-3  [%qualified-column qualified-table-1 %col3 ~]
++  minmax-q-col-4  [%qualified-column qualified-table-1 %col4 ~]
++  minmax-q-col-5  [%qualified-column qualified-table-1 %col5 ~]
++  minmax-q-col-6  [%qualified-column qualified-table-1 %col6 ~]
::
++  minmax-qual-table-row  %-  mk-indexed-row
                           :~  [%col1 .~-3]                    ::  @rd -3.0
                               [%col2 .~2]                     ::  @rd 2.0
                               [%col3 -3]                      ::  @sd -3
                               [%col4 --2]                     ::  @sd --2
                               [%col5 2]                       ::  @ud 2
                               [%col6 5]                       ::  @ud 5
                           ==
::
::  unqualified: col1=@rd .~-3, col2=@rd .~2
::               col3=@sd -3, col4=@sd --2
::               col5=@ud 2, col6=@ud 5
::
++  minmax-unqual-map-meta
  :-  %unqualified-map-meta
      %-  mk-unqualified-typ-addr-lookup
          %-  addr-columns
              :~  [%column %col1 ~.rd 0]
                  [%column %col2 ~.rd 0]
                  [%column %col3 ~.sd 0]
                  [%column %col4 ~.sd 0]
                  [%column %col5 ~.ud 0]
                  [%column %col6 ~.ud 0]
                  ==
::
++  minmax-unqual-lookup  %-  malt  %-  limo
                          :~  [%col1 ~[qualified-table-1]]
                              [%col2 ~[qualified-table-1]]
                              [%col3 ~[qualified-table-1]]
                              [%col4 ~[qualified-table-1]]
                              [%col5 ~[qualified-table-1]]
                              [%col6 ~[qualified-table-1]]
                          ==
::
++  minmax-u-col-1  [%unqualified-column %col1 ~]
++  minmax-u-col-2  [%unqualified-column %col2 ~]
++  minmax-u-col-3  [%unqualified-column %col3 ~]
++  minmax-u-col-4  [%unqualified-column %col4 ~]
++  minmax-u-col-5  [%unqualified-column %col5 ~]
++  minmax-u-col-6  [%unqualified-column %col6 ~]
::
++  minmax-unqual-table-row  %-  mk-indexed-row
                             :~  [%col1 .~-3]                  ::  @rd -3.0
                                 [%col2 .~2]                   ::  @rd 2.0
                                 [%col3 -3]                    ::  @sd -3
                                 [%col4 --2]                   ::  @sd --2
                                 [%col5 2]                     ::  @ud 2
                                 [%col6 5]                     ::  @ud 5
                             ==
::
::  %log test helpers
::  @rd: col1=.~1, col2=.~2, col3=.~0.1
::  @sd: col4=--1, col5=--2, col6=--100
::  @ud: col7=1,   col8=2,   col9=100
::
::  qualified: col1=@rd .~1, col2=@rd .~2, col3=@rd .~0.1
::             col4=@sd --1, col5=@sd --2, col6=@sd --100
::             col7=@ud 1,   col8=@ud 2,   col9=@ud 100
::
++  log-qual-map-meta
  %-  mk-qualified-map-meta
      :~  :-  qualified-table-1
              %-  addr-columns
                  :~  [%column %col1 ~.rd 0]
                      [%column %col2 ~.rd 0]
                      [%column %col3 ~.rd 0]
                      [%column %col4 ~.sd 0]
                      [%column %col5 ~.sd 0]
                      [%column %col6 ~.sd 0]
                      [%column %col7 ~.ud 0]
                      [%column %col8 ~.ud 0]
                      [%column %col9 ~.ud 0]
                      ==
          ==
::
++  log-q-col-1  [%qualified-column qualified-table-1 %col1 ~]
++  log-q-col-2  [%qualified-column qualified-table-1 %col2 ~]
++  log-q-col-3  [%qualified-column qualified-table-1 %col3 ~]
++  log-q-col-4  [%qualified-column qualified-table-1 %col4 ~]
++  log-q-col-5  [%qualified-column qualified-table-1 %col5 ~]
++  log-q-col-6  [%qualified-column qualified-table-1 %col6 ~]
++  log-q-col-7  [%qualified-column qualified-table-1 %col7 ~]
++  log-q-col-8  [%qualified-column qualified-table-1 %col8 ~]
++  log-q-col-9  [%qualified-column qualified-table-1 %col9 ~]
::
++  log-qual-table-row  %-  mk-indexed-row
                        :~  [%col1 .~1]                      ::  @rd 1.0
                            [%col2 .~2]                      ::  @rd 2.0
                            [%col3 .~0.1]                    ::  @rd 0.1
                            [%col4 --1]                      ::  @sd --1
                            [%col5 --2]                      ::  @sd --2
                            [%col6 --100]                    ::  @sd --100
                            [%col7 1]                        ::  @ud 1
                            [%col8 2]                        ::  @ud 2
                            [%col9 100]                      ::  @ud 100
                        ==
::
::  unqualified: col1=@rd .~1, col2=@rd .~2, col3=@rd .~0.1
::               col4=@sd --1, col5=@sd --2, col6=@sd --100
::               col7=@ud 1,   col8=@ud 2,   col9=@ud 100
::
++  log-unqual-map-meta
  :-  %unqualified-map-meta
      %-  mk-unqualified-typ-addr-lookup
          %-  addr-columns
              :~  [%column %col1 ~.rd 0]
                  [%column %col2 ~.rd 0]
                  [%column %col3 ~.rd 0]
                  [%column %col4 ~.sd 0]
                  [%column %col5 ~.sd 0]
                  [%column %col6 ~.sd 0]
                  [%column %col7 ~.ud 0]
                  [%column %col8 ~.ud 0]
                  [%column %col9 ~.ud 0]
                  ==
::
++  log-unqual-lookup  %-  malt  %-  limo
                       :~  [%col1 ~[qualified-table-1]]
                           [%col2 ~[qualified-table-1]]
                           [%col3 ~[qualified-table-1]]
                           [%col4 ~[qualified-table-1]]
                           [%col5 ~[qualified-table-1]]
                           [%col6 ~[qualified-table-1]]
                           [%col7 ~[qualified-table-1]]
                           [%col8 ~[qualified-table-1]]
                           [%col9 ~[qualified-table-1]]
                       ==
::
++  log-u-col-1  [%unqualified-column %col1 ~]
++  log-u-col-2  [%unqualified-column %col2 ~]
++  log-u-col-3  [%unqualified-column %col3 ~]
++  log-u-col-4  [%unqualified-column %col4 ~]
++  log-u-col-5  [%unqualified-column %col5 ~]
++  log-u-col-6  [%unqualified-column %col6 ~]
++  log-u-col-7  [%unqualified-column %col7 ~]
++  log-u-col-8  [%unqualified-column %col8 ~]
++  log-u-col-9  [%unqualified-column %col9 ~]
::
++  log-unqual-table-row  %-  mk-indexed-row
                          :~  [%col1 .~1]                    ::  @rd 1.0
                              [%col2 .~2]                    ::  @rd 2.0
                              [%col3 .~0.1]                  ::  @rd 0.1
                              [%col4 --1]                    ::  @sd --1
                              [%col5 --2]                    ::  @sd --2
                              [%col6 --100]                  ::  @sd --100
                              [%col7 1]                      ::  @ud 1
                              [%col8 2]                      ::  @ud 2
                              [%col9 100]                    ::  @ud 100
                          ==
::  %sin test helpers
::  @rd: col1=.~0.2, col2=.~1, col3=.~-0.2
::  @sd: col4=--0,   col5=--1, col6=-1
::  @ud: col7=0,     col8=1,   col9=2
::
::  qualified: col1=@rd .~0.2, col2=@rd .~1, col3=@rd .~-0.2
::             col4=@sd --0,   col5=@sd --1, col6=@sd -1
::             col7=@ud 0,     col8=@ud 1,   col9=@ud 2
::
++  sin-qual-map-meta
  %-  mk-qualified-map-meta
      :~  :-  qualified-table-1
              %-  addr-columns
                  :~  [%column %col1 ~.rd 0]
                      [%column %col2 ~.rd 0]
                      [%column %col3 ~.rd 0]
                      [%column %col4 ~.sd 0]
                      [%column %col5 ~.sd 0]
                      [%column %col6 ~.sd 0]
                      [%column %col7 ~.ud 0]
                      [%column %col8 ~.ud 0]
                      [%column %col9 ~.ud 0]
                      ==
          ==
::
++  sin-q-col-1  [%qualified-column qualified-table-1 %col1 ~]
++  sin-q-col-2  [%qualified-column qualified-table-1 %col2 ~]
++  sin-q-col-3  [%qualified-column qualified-table-1 %col3 ~]
++  sin-q-col-4  [%qualified-column qualified-table-1 %col4 ~]
++  sin-q-col-5  [%qualified-column qualified-table-1 %col5 ~]
++  sin-q-col-6  [%qualified-column qualified-table-1 %col6 ~]
++  sin-q-col-7  [%qualified-column qualified-table-1 %col7 ~]
++  sin-q-col-8  [%qualified-column qualified-table-1 %col8 ~]
++  sin-q-col-9  [%qualified-column qualified-table-1 %col9 ~]
::
++  sin-qual-table-row  %-  mk-indexed-row
                        :~  [%col1 .~0.2]                    ::  @rd 0.2
                            [%col2 .~1]                      ::  @rd 1.0
                            [%col3 .~-0.2]                   ::  @rd -0.2
                            [%col4 --0]                      ::  @sd --0
                            [%col5 --1]                      ::  @sd --1
                            [%col6 -1]                       ::  @sd -1
                            [%col7 0]                        ::  @ud 0
                            [%col8 1]                        ::  @ud 1
                            [%col9 2]                        ::  @ud 2
                        ==
::
::  unqualified: col1=@rd .~0.2, col2=@rd .~1, col3=@rd .~-0.2
::               col4=@sd --0,   col5=@sd --1, col6=@sd -1
::               col7=@ud 0,     col8=@ud 1,   col9=@ud 2
::
++  sin-unqual-map-meta
  :-  %unqualified-map-meta
      %-  mk-unqualified-typ-addr-lookup
          %-  addr-columns
              :~  [%column %col1 ~.rd 0]
                  [%column %col2 ~.rd 0]
                  [%column %col3 ~.rd 0]
                  [%column %col4 ~.sd 0]
                  [%column %col5 ~.sd 0]
                  [%column %col6 ~.sd 0]
                  [%column %col7 ~.ud 0]
                  [%column %col8 ~.ud 0]
                  [%column %col9 ~.ud 0]
                  ==
::
++  sin-unqual-lookup  %-  malt  %-  limo
                       :~  [%col1 ~[qualified-table-1]]
                           [%col2 ~[qualified-table-1]]
                           [%col3 ~[qualified-table-1]]
                           [%col4 ~[qualified-table-1]]
                           [%col5 ~[qualified-table-1]]
                           [%col6 ~[qualified-table-1]]
                           [%col7 ~[qualified-table-1]]
                           [%col8 ~[qualified-table-1]]
                           [%col9 ~[qualified-table-1]]
                       ==
::
++  sin-u-col-1  [%unqualified-column %col1 ~]
++  sin-u-col-2  [%unqualified-column %col2 ~]
++  sin-u-col-3  [%unqualified-column %col3 ~]
++  sin-u-col-4  [%unqualified-column %col4 ~]
++  sin-u-col-5  [%unqualified-column %col5 ~]
++  sin-u-col-6  [%unqualified-column %col6 ~]
++  sin-u-col-7  [%unqualified-column %col7 ~]
++  sin-u-col-8  [%unqualified-column %col8 ~]
++  sin-u-col-9  [%unqualified-column %col9 ~]
::
++  sin-unqual-table-row  %-  mk-indexed-row
                          :~  [%col1 .~0.2]                  ::  @rd 0.2
                              [%col2 .~1]                    ::  @rd 1.0
                              [%col3 .~-0.2]                 ::  @rd -0.2
                              [%col4 --0]                    ::  @sd --0
                              [%col5 --1]                    ::  @sd --1
                              [%col6 -1]                     ::  @sd -1
                              [%col7 0]                      ::  @ud 0
                              [%col8 1]                      ::  @ud 1
                              [%col9 2]                      ::  @ud 2
                          ==
::  %cos test helpers
::  @rd: col1=.~1, col2=.~1.56, col3=.~-1
::  @sd: col4=--0, col5=--1,    col6=-1
::  @ud: col7=0,   col8=1,      col9=2
::
::  qualified: col1=@rd .~1, col2=@rd .~1.56, col3=@rd .~-1
::             col4=@sd --0, col5=@sd --1,    col6=@sd -1
::             col7=@ud 0,   col8=@ud 1,      col9=@ud 2
::
++  cos-qual-map-meta
  %-  mk-qualified-map-meta
      :~  :-  qualified-table-1
              %-  addr-columns
                  :~  [%column %col1 ~.rd 0]
                      [%column %col2 ~.rd 0]
                      [%column %col3 ~.rd 0]
                      [%column %col4 ~.sd 0]
                      [%column %col5 ~.sd 0]
                      [%column %col6 ~.sd 0]
                      [%column %col7 ~.ud 0]
                      [%column %col8 ~.ud 0]
                      [%column %col9 ~.ud 0]
                      ==
          ==
::
++  cos-q-col-1  [%qualified-column qualified-table-1 %col1 ~]
++  cos-q-col-2  [%qualified-column qualified-table-1 %col2 ~]
++  cos-q-col-3  [%qualified-column qualified-table-1 %col3 ~]
++  cos-q-col-4  [%qualified-column qualified-table-1 %col4 ~]
++  cos-q-col-5  [%qualified-column qualified-table-1 %col5 ~]
++  cos-q-col-6  [%qualified-column qualified-table-1 %col6 ~]
++  cos-q-col-7  [%qualified-column qualified-table-1 %col7 ~]
++  cos-q-col-8  [%qualified-column qualified-table-1 %col8 ~]
++  cos-q-col-9  [%qualified-column qualified-table-1 %col9 ~]
::
++  cos-qual-table-row  %-  mk-indexed-row
                        :~  [%col1 .~1]                      ::  @rd 1.0
                            [%col2 .~1.56]                   ::  @rd 1.56
                            [%col3 .~-1]                     ::  @rd -1.0
                            [%col4 --0]                      ::  @sd --0
                            [%col5 --1]                      ::  @sd --1
                            [%col6 -1]                       ::  @sd -1
                            [%col7 0]                        ::  @ud 0
                            [%col8 1]                        ::  @ud 1
                            [%col9 2]                        ::  @ud 2
                        ==
::
::  unqualified: col1=@rd .~1, col2=@rd .~1.56, col3=@rd .~-1
::               col4=@sd --0, col5=@sd --1,    col6=@sd -1
::               col7=@ud 0,   col8=@ud 1,      col9=@ud 2
::
++  cos-unqual-map-meta
  :-  %unqualified-map-meta
      %-  mk-unqualified-typ-addr-lookup
          %-  addr-columns
              :~  [%column %col1 ~.rd 0]
                  [%column %col2 ~.rd 0]
                  [%column %col3 ~.rd 0]
                  [%column %col4 ~.sd 0]
                  [%column %col5 ~.sd 0]
                  [%column %col6 ~.sd 0]
                  [%column %col7 ~.ud 0]
                  [%column %col8 ~.ud 0]
                  [%column %col9 ~.ud 0]
                  ==
::
++  cos-unqual-lookup  %-  malt  %-  limo
                       :~  [%col1 ~[qualified-table-1]]
                           [%col2 ~[qualified-table-1]]
                           [%col3 ~[qualified-table-1]]
                           [%col4 ~[qualified-table-1]]
                           [%col5 ~[qualified-table-1]]
                           [%col6 ~[qualified-table-1]]
                           [%col7 ~[qualified-table-1]]
                           [%col8 ~[qualified-table-1]]
                           [%col9 ~[qualified-table-1]]
                       ==
::
++  cos-u-col-1  [%unqualified-column %col1 ~]
++  cos-u-col-2  [%unqualified-column %col2 ~]
++  cos-u-col-3  [%unqualified-column %col3 ~]
++  cos-u-col-4  [%unqualified-column %col4 ~]
++  cos-u-col-5  [%unqualified-column %col5 ~]
++  cos-u-col-6  [%unqualified-column %col6 ~]
++  cos-u-col-7  [%unqualified-column %col7 ~]
++  cos-u-col-8  [%unqualified-column %col8 ~]
++  cos-u-col-9  [%unqualified-column %col9 ~]
::
++  cos-unqual-table-row  %-  mk-indexed-row
                          :~  [%col1 .~1]                    ::  @rd 1.0
                              [%col2 .~1.56]                 ::  @rd 1.56
                              [%col3 .~-1]                   ::  @rd -1.0
                              [%col4 --0]                    ::  @sd --0
                              [%col5 --1]                    ::  @sd --1
                              [%col6 -1]                     ::  @sd -1
                              [%col7 0]                      ::  @ud 0
                              [%col8 1]                      ::  @ud 1
                              [%col9 2]                      ::  @ud 2
                          ==
::
::  tan helpers
::  qualified: col1=@rd .~1, col2=@rd .~0, col3=@rd .~-1
::              col4=@sd --0, col5=@sd --1, col6=@sd -1
::              col7=@ud 0,   col8=@ud 1,   col9=@ud 2
::
++  tan-qual-map-meta
  %-  mk-qualified-map-meta
      :~  :-  qualified-table-1
              %-  addr-columns
                  :~  [%column %col1 ~.rd 0]
                      [%column %col2 ~.rd 0]
                      [%column %col3 ~.rd 0]
                      [%column %col4 ~.sd 0]
                      [%column %col5 ~.sd 0]
                      [%column %col6 ~.sd 0]
                      [%column %col7 ~.ud 0]
                      [%column %col8 ~.ud 0]
                      [%column %col9 ~.ud 0]
                      ==
          ==
::
++  tan-q-col-1  [%qualified-column qualified-table-1 %col1 ~]
++  tan-q-col-2  [%qualified-column qualified-table-1 %col2 ~]
++  tan-q-col-3  [%qualified-column qualified-table-1 %col3 ~]
++  tan-q-col-4  [%qualified-column qualified-table-1 %col4 ~]
++  tan-q-col-5  [%qualified-column qualified-table-1 %col5 ~]
++  tan-q-col-6  [%qualified-column qualified-table-1 %col6 ~]
++  tan-q-col-7  [%qualified-column qualified-table-1 %col7 ~]
++  tan-q-col-8  [%qualified-column qualified-table-1 %col8 ~]
++  tan-q-col-9  [%qualified-column qualified-table-1 %col9 ~]
::
++  tan-qual-table-row  %-  mk-indexed-row
                        :~  [%col1 .~1]                      ::  @rd 1.0
                            [%col2 .~0]                      ::  @rd 0.0
                            [%col3 .~-1]                     ::  @rd -1.0
                            [%col4 --0]                      ::  @sd --0
                            [%col5 --1]                      ::  @sd --1
                            [%col6 -1]                       ::  @sd -1
                            [%col7 0]                        ::  @ud 0
                            [%col8 1]                        ::  @ud 1
                            [%col9 2]                        ::  @ud 2
                        ==
::
::  unqualified: col1=@rd .~1, col2=@rd .~0, col3=@rd .~-1
::               col4=@sd --0, col5=@sd --1, col6=@sd -1
::               col7=@ud 0,   col8=@ud 1,   col9=@ud 2
::
++  tan-unqual-map-meta
  :-  %unqualified-map-meta
      %-  mk-unqualified-typ-addr-lookup
          %-  addr-columns
              :~  [%column %col1 ~.rd 0]
                  [%column %col2 ~.rd 0]
                  [%column %col3 ~.rd 0]
                  [%column %col4 ~.sd 0]
                  [%column %col5 ~.sd 0]
                  [%column %col6 ~.sd 0]
                  [%column %col7 ~.ud 0]
                  [%column %col8 ~.ud 0]
                  [%column %col9 ~.ud 0]
                  ==
::
++  tan-unqual-lookup  %-  malt  %-  limo
                       :~  [%col1 ~[qualified-table-1]]
                           [%col2 ~[qualified-table-1]]
                           [%col3 ~[qualified-table-1]]
                           [%col4 ~[qualified-table-1]]
                           [%col5 ~[qualified-table-1]]
                           [%col6 ~[qualified-table-1]]
                           [%col7 ~[qualified-table-1]]
                           [%col8 ~[qualified-table-1]]
                           [%col9 ~[qualified-table-1]]
                       ==
::
++  tan-u-col-1  [%unqualified-column %col1 ~]
++  tan-u-col-2  [%unqualified-column %col2 ~]
++  tan-u-col-3  [%unqualified-column %col3 ~]
++  tan-u-col-4  [%unqualified-column %col4 ~]
++  tan-u-col-5  [%unqualified-column %col5 ~]
++  tan-u-col-6  [%unqualified-column %col6 ~]
++  tan-u-col-7  [%unqualified-column %col7 ~]
++  tan-u-col-8  [%unqualified-column %col8 ~]
++  tan-u-col-9  [%unqualified-column %col9 ~]
::
++  tan-unqual-table-row  %-  mk-indexed-row
                          :~  [%col1 .~1]                    ::  @rd 1.0
                              [%col2 .~0]                    ::  @rd 0.0
                              [%col3 .~-1]                   ::  @rd -1.0
                              [%col4 --0]                    ::  @sd --0
                              [%col5 --1]                    ::  @sd --1
                              [%col6 -1]                     ::  @sd -1
                              [%col7 0]                      ::  @ud 0
                              [%col8 1]                      ::  @ud 1
                              [%col9 2]                      ::  @ud 2
                          ==
::
::  asin helpers
::  asin domain is [-1, 1]; @ud only supports 0 and 1 (8 columns total)
::  qualified: col1=@rd .~1, col2=@rd .~0, col3=@rd .~-1
::              col4=@sd --0, col5=@sd --1, col6=@sd -1
::              col7=@ud 0,   col8=@ud 1
::
++  asin-qual-map-meta
  %-  mk-qualified-map-meta
      :~  :-  qualified-table-1
              %-  addr-columns
                  :~  [%column %col1 ~.rd 0]
                      [%column %col2 ~.rd 0]
                      [%column %col3 ~.rd 0]
                      [%column %col4 ~.sd 0]
                      [%column %col5 ~.sd 0]
                      [%column %col6 ~.sd 0]
                      [%column %col7 ~.ud 0]
                      [%column %col8 ~.ud 0]
                      ==
          ==
::
++  asin-q-col-1  [%qualified-column qualified-table-1 %col1 ~]
++  asin-q-col-2  [%qualified-column qualified-table-1 %col2 ~]
++  asin-q-col-3  [%qualified-column qualified-table-1 %col3 ~]
++  asin-q-col-4  [%qualified-column qualified-table-1 %col4 ~]
++  asin-q-col-5  [%qualified-column qualified-table-1 %col5 ~]
++  asin-q-col-6  [%qualified-column qualified-table-1 %col6 ~]
++  asin-q-col-7  [%qualified-column qualified-table-1 %col7 ~]
++  asin-q-col-8  [%qualified-column qualified-table-1 %col8 ~]
::
++  asin-qual-table-row  %-  mk-indexed-row
                         :~  [%col1 .~1]                     ::  @rd 1.0
                             [%col2 .~0]                     ::  @rd 0.0
                             [%col3 .~-1]                    ::  @rd -1.0
                             [%col4 --0]                     ::  @sd --0
                             [%col5 --1]                     ::  @sd --1
                             [%col6 -1]                      ::  @sd -1
                             [%col7 0]                       ::  @ud 0
                             [%col8 1]                       ::  @ud 1
                         ==
::
::  unqualified: col1=@rd .~1, col2=@rd .~0, col3=@rd .~-1
::               col4=@sd --0, col5=@sd --1, col6=@sd -1
::               col7=@ud 0,   col8=@ud 1
::
++  asin-unqual-map-meta
  :-  %unqualified-map-meta
      %-  mk-unqualified-typ-addr-lookup
          %-  addr-columns
              :~  [%column %col1 ~.rd 0]
                  [%column %col2 ~.rd 0]
                  [%column %col3 ~.rd 0]
                  [%column %col4 ~.sd 0]
                  [%column %col5 ~.sd 0]
                  [%column %col6 ~.sd 0]
                  [%column %col7 ~.ud 0]
                  [%column %col8 ~.ud 0]
                  ==
::
++  asin-unqual-lookup  %-  malt  %-  limo
                        :~  [%col1 ~[qualified-table-1]]
                            [%col2 ~[qualified-table-1]]
                            [%col3 ~[qualified-table-1]]
                            [%col4 ~[qualified-table-1]]
                            [%col5 ~[qualified-table-1]]
                            [%col6 ~[qualified-table-1]]
                            [%col7 ~[qualified-table-1]]
                            [%col8 ~[qualified-table-1]]
                        ==
::
++  asin-u-col-1  [%unqualified-column %col1 ~]
++  asin-u-col-2  [%unqualified-column %col2 ~]
++  asin-u-col-3  [%unqualified-column %col3 ~]
++  asin-u-col-4  [%unqualified-column %col4 ~]
++  asin-u-col-5  [%unqualified-column %col5 ~]
++  asin-u-col-6  [%unqualified-column %col6 ~]
++  asin-u-col-7  [%unqualified-column %col7 ~]
++  asin-u-col-8  [%unqualified-column %col8 ~]
::
++  asin-unqual-table-row  %-  mk-indexed-row
                           :~  [%col1 .~1]                   ::  @rd 1.0
                               [%col2 .~0]                   ::  @rd 0.0
                               [%col3 .~-1]                  ::  @rd -1.0
                               [%col4 --0]                   ::  @sd --0
                               [%col5 --1]                   ::  @sd --1
                               [%col6 -1]                    ::  @sd -1
                               [%col7 0]                     ::  @ud 0
                               [%col8 1]                     ::  @ud 1
                           ==
::
::  acos helpers
::  acos domain is [-1, 1]; @ud only supports 0 and 1 (8 columns total)
::  qualified: col1=@rd .~1, col2=@rd .~0, col3=@rd .~-1
::              col4=@sd --0, col5=@sd --1, col6=@sd -1
::              col7=@ud 0,   col8=@ud 1
::
++  acos-qual-map-meta
  %-  mk-qualified-map-meta
      :~  :-  qualified-table-1
              %-  addr-columns
                  :~  [%column %col1 ~.rd 0]
                      [%column %col2 ~.rd 0]
                      [%column %col3 ~.rd 0]
                      [%column %col4 ~.sd 0]
                      [%column %col5 ~.sd 0]
                      [%column %col6 ~.sd 0]
                      [%column %col7 ~.ud 0]
                      [%column %col8 ~.ud 0]
                      ==
          ==
::
++  acos-q-col-1  [%qualified-column qualified-table-1 %col1 ~]
++  acos-q-col-2  [%qualified-column qualified-table-1 %col2 ~]
++  acos-q-col-3  [%qualified-column qualified-table-1 %col3 ~]
++  acos-q-col-4  [%qualified-column qualified-table-1 %col4 ~]
++  acos-q-col-5  [%qualified-column qualified-table-1 %col5 ~]
++  acos-q-col-6  [%qualified-column qualified-table-1 %col6 ~]
++  acos-q-col-7  [%qualified-column qualified-table-1 %col7 ~]
++  acos-q-col-8  [%qualified-column qualified-table-1 %col8 ~]
::
++  acos-qual-table-row  %-  mk-indexed-row
                         :~  [%col1 .~1]                     ::  @rd 1.0
                             [%col2 .~0]                     ::  @rd 0.0
                             [%col3 .~-1]                    ::  @rd -1.0
                             [%col4 --0]                     ::  @sd --0
                             [%col5 --1]                     ::  @sd --1
                             [%col6 -1]                      ::  @sd -1
                             [%col7 0]                       ::  @ud 0
                             [%col8 1]                       ::  @ud 1
                         ==
::
::  unqualified: col1=@rd .~1, col2=@rd .~0, col3=@rd .~-1
::               col4=@sd --0, col5=@sd --1, col6=@sd -1
::               col7=@ud 0,   col8=@ud 1
::
++  acos-unqual-map-meta
  :-  %unqualified-map-meta
      %-  mk-unqualified-typ-addr-lookup
          %-  addr-columns
              :~  [%column %col1 ~.rd 0]
                  [%column %col2 ~.rd 0]
                  [%column %col3 ~.rd 0]
                  [%column %col4 ~.sd 0]
                  [%column %col5 ~.sd 0]
                  [%column %col6 ~.sd 0]
                  [%column %col7 ~.ud 0]
                  [%column %col8 ~.ud 0]
                  ==
::
++  acos-unqual-lookup  %-  malt  %-  limo
                        :~  [%col1 ~[qualified-table-1]]
                            [%col2 ~[qualified-table-1]]
                            [%col3 ~[qualified-table-1]]
                            [%col4 ~[qualified-table-1]]
                            [%col5 ~[qualified-table-1]]
                            [%col6 ~[qualified-table-1]]
                            [%col7 ~[qualified-table-1]]
                            [%col8 ~[qualified-table-1]]
                        ==
::
++  acos-u-col-1  [%unqualified-column %col1 ~]
++  acos-u-col-2  [%unqualified-column %col2 ~]
++  acos-u-col-3  [%unqualified-column %col3 ~]
++  acos-u-col-4  [%unqualified-column %col4 ~]
++  acos-u-col-5  [%unqualified-column %col5 ~]
++  acos-u-col-6  [%unqualified-column %col6 ~]
++  acos-u-col-7  [%unqualified-column %col7 ~]
++  acos-u-col-8  [%unqualified-column %col8 ~]
::
++  acos-unqual-table-row  %-  mk-indexed-row
                           :~  [%col1 .~1]                   ::  @rd 1.0
                               [%col2 .~0]                   ::  @rd 0.0
                               [%col3 .~-1]                  ::  @rd -1.0
                               [%col4 --0]                   ::  @sd --0
                               [%col5 --1]                   ::  @sd --1
                               [%col6 -1]                    ::  @sd -1
                               [%col7 0]                     ::  @ud 0
                               [%col8 1]                     ::  @ud 1
                           ==
::
::  atan helpers
::  atan domain is all reals; 9 columns total
::  qualified: col1=@rd .~1, col2=@rd .~0, col3=@rd .~-1
::              col4=@sd --0, col5=@sd --1, col6=@sd -1
::              col7=@ud 0,   col8=@ud 1,   col9=@ud 2
::
++  atan-qual-map-meta
  %-  mk-qualified-map-meta
      :~  :-  qualified-table-1
              %-  addr-columns
                  :~  [%column %col1 ~.rd 0]
                      [%column %col2 ~.rd 0]
                      [%column %col3 ~.rd 0]
                      [%column %col4 ~.sd 0]
                      [%column %col5 ~.sd 0]
                      [%column %col6 ~.sd 0]
                      [%column %col7 ~.ud 0]
                      [%column %col8 ~.ud 0]
                      [%column %col9 ~.ud 0]
                      ==
          ==
::
++  atan-q-col-1  [%qualified-column qualified-table-1 %col1 ~]
++  atan-q-col-2  [%qualified-column qualified-table-1 %col2 ~]
++  atan-q-col-3  [%qualified-column qualified-table-1 %col3 ~]
++  atan-q-col-4  [%qualified-column qualified-table-1 %col4 ~]
++  atan-q-col-5  [%qualified-column qualified-table-1 %col5 ~]
++  atan-q-col-6  [%qualified-column qualified-table-1 %col6 ~]
++  atan-q-col-7  [%qualified-column qualified-table-1 %col7 ~]
++  atan-q-col-8  [%qualified-column qualified-table-1 %col8 ~]
++  atan-q-col-9  [%qualified-column qualified-table-1 %col9 ~]
::
++  atan-qual-table-row  %-  mk-indexed-row
                         :~  [%col1 .~1]                     ::  @rd 1.0
                             [%col2 .~0]                     ::  @rd 0.0
                             [%col3 .~-1]                    ::  @rd -1.0
                             [%col4 --0]                     ::  @sd --0
                             [%col5 --1]                     ::  @sd --1
                             [%col6 -1]                      ::  @sd -1
                             [%col7 0]                       ::  @ud 0
                             [%col8 1]                       ::  @ud 1
                             [%col9 2]                       ::  @ud 2
                         ==
::
::  unqualified: col1=@rd .~1, col2=@rd .~0, col3=@rd .~-1
::               col4=@sd --0, col5=@sd --1, col6=@sd -1
::               col7=@ud 0,   col8=@ud 1,   col9=@ud 2
::
++  atan-unqual-map-meta
  :-  %unqualified-map-meta
      %-  mk-unqualified-typ-addr-lookup
          %-  addr-columns
              :~  [%column %col1 ~.rd 0]
                  [%column %col2 ~.rd 0]
                  [%column %col3 ~.rd 0]
                  [%column %col4 ~.sd 0]
                  [%column %col5 ~.sd 0]
                  [%column %col6 ~.sd 0]
                  [%column %col7 ~.ud 0]
                  [%column %col8 ~.ud 0]
                  [%column %col9 ~.ud 0]
                  ==
::
++  atan-unqual-lookup  %-  malt  %-  limo
                        :~  [%col1 ~[qualified-table-1]]
                            [%col2 ~[qualified-table-1]]
                            [%col3 ~[qualified-table-1]]
                            [%col4 ~[qualified-table-1]]
                            [%col5 ~[qualified-table-1]]
                            [%col6 ~[qualified-table-1]]
                            [%col7 ~[qualified-table-1]]
                            [%col8 ~[qualified-table-1]]
                            [%col9 ~[qualified-table-1]]
                        ==
::
++  atan-u-col-1  [%unqualified-column %col1 ~]
++  atan-u-col-2  [%unqualified-column %col2 ~]
++  atan-u-col-3  [%unqualified-column %col3 ~]
++  atan-u-col-4  [%unqualified-column %col4 ~]
++  atan-u-col-5  [%unqualified-column %col5 ~]
++  atan-u-col-6  [%unqualified-column %col6 ~]
++  atan-u-col-7  [%unqualified-column %col7 ~]
++  atan-u-col-8  [%unqualified-column %col8 ~]
++  atan-u-col-9  [%unqualified-column %col9 ~]
::
++  atan-unqual-table-row  %-  mk-indexed-row
                           :~  [%col1 .~1]                   ::  @rd 1.0
                               [%col2 .~0]                   ::  @rd 0.0
                               [%col3 .~-1]                  ::  @rd -1.0
                               [%col4 --0]                   ::  @sd --0
                               [%col5 --1]                   ::  @sd --1
                               [%col6 -1]                    ::  @sd -1
                               [%col7 0]                     ::  @ud 0
                               [%col8 1]                     ::  @ud 1
                               [%col9 2]                     ::  @ud 2
                           ==
::
::  %atan2 test helpers
::  col1=@rd y=.~1, col2=@rd x=.~2
::  col3=@sd y=--1, col4=@sd x=--2
::  col5=@ud y=1,   col6=@ud x=2
::
::  qualified: col1=@rd .~1, col2=@rd .~2
::             col3=@sd --1, col4=@sd --2
::             col5=@ud 1,   col6=@ud 2
::
++  atan2-qual-map-meta
  %-  mk-qualified-map-meta
      :~  :-  qualified-table-1
              %-  addr-columns
                  :~  [%column %col1 ~.rd 0]
                      [%column %col2 ~.rd 0]
                      [%column %col3 ~.sd 0]
                      [%column %col4 ~.sd 0]
                      [%column %col5 ~.ud 0]
                      [%column %col6 ~.ud 0]
                      ==
          ==
::
++  atan2-q-col-1  [%qualified-column qualified-table-1 %col1 ~]
++  atan2-q-col-2  [%qualified-column qualified-table-1 %col2 ~]
++  atan2-q-col-3  [%qualified-column qualified-table-1 %col3 ~]
++  atan2-q-col-4  [%qualified-column qualified-table-1 %col4 ~]
++  atan2-q-col-5  [%qualified-column qualified-table-1 %col5 ~]
++  atan2-q-col-6  [%qualified-column qualified-table-1 %col6 ~]
::
++  atan2-qual-table-row  %-  mk-indexed-row
                           :~  [%col1 .~1]                   ::  @rd y=1.0
                               [%col2 .~2]                   ::  @rd x=2.0
                               [%col3 --1]                   ::  @sd y=--1
                               [%col4 --2]                   ::  @sd x=--2
                               [%col5 1]                     ::  @ud y=1
                               [%col6 2]                     ::  @ud x=2
                           ==
::
::  unqualified: col1=@rd .~1, col2=@rd .~2
::               col3=@sd --1, col4=@sd --2
::               col5=@ud 1,   col6=@ud 2
::
++  atan2-unqual-map-meta
  :-  %unqualified-map-meta
      %-  mk-unqualified-typ-addr-lookup
          %-  addr-columns
              :~  [%column %col1 ~.rd 0]
                  [%column %col2 ~.rd 0]
                  [%column %col3 ~.sd 0]
                  [%column %col4 ~.sd 0]
                  [%column %col5 ~.ud 0]
                  [%column %col6 ~.ud 0]
                  ==
::
++  atan2-unqual-lookup  %-  malt  %-  limo
                          :~  [%col1 ~[qualified-table-1]]
                              [%col2 ~[qualified-table-1]]
                              [%col3 ~[qualified-table-1]]
                              [%col4 ~[qualified-table-1]]
                              [%col5 ~[qualified-table-1]]
                              [%col6 ~[qualified-table-1]]
                          ==
::
++  atan2-u-col-1  [%unqualified-column %col1 ~]
++  atan2-u-col-2  [%unqualified-column %col2 ~]
++  atan2-u-col-3  [%unqualified-column %col3 ~]
++  atan2-u-col-4  [%unqualified-column %col4 ~]
++  atan2-u-col-5  [%unqualified-column %col5 ~]
++  atan2-u-col-6  [%unqualified-column %col6 ~]
::
++  atan2-unqual-table-row  %-  mk-indexed-row
                             :~  [%col1 .~1]                 ::  @rd y=1.0
                                 [%col2 .~2]                 ::  @rd x=2.0
                                 [%col3 --1]                 ::  @sd y=--1
                                 [%col4 --2]                 ::  @sd x=--2
                                 [%col5 1]                   ::  @ud y=1
                                 [%col6 2]                   ::  @ud x=2
                             ==
::
::  %degrees test helpers
::  @rd: col1=.~0, col2=.~1, col3=.~3.14, col4=.~-3.14, col5=.~24, col6=.~-24
::  @sd: col7=--0, col8=--1, col9=--3, col10=-3, col11=--24, col12=-24
::  @ud: col13=0, col14=1, col15=3, col16=24
::
::  qualified: col1..col6=@rd, col7..col12=@sd, col13..col16=@ud
::
++  degrees-qual-map-meta
  %-  mk-qualified-map-meta
      :~  :-  qualified-table-1
              %-  addr-columns
                  :~  [%column %col1 ~.rd 0]
                      [%column %col2 ~.rd 0]
                      [%column %col3 ~.rd 0]
                      [%column %col4 ~.rd 0]
                      [%column %col5 ~.rd 0]
                      [%column %col6 ~.rd 0]
                      [%column %col7 ~.sd 0]
                      [%column %col8 ~.sd 0]
                      [%column %col9 ~.sd 0]
                      [%column %col10 ~.sd 0]
                      [%column %col11 ~.sd 0]
                      [%column %col12 ~.sd 0]
                      [%column %col13 ~.ud 0]
                      [%column %col14 ~.ud 0]
                      [%column %col15 ~.ud 0]
                      [%column %col16 ~.ud 0]
                      ==
          ==
::
++  degrees-q-col-1   [%qualified-column qualified-table-1 %col1 ~]
++  degrees-q-col-2   [%qualified-column qualified-table-1 %col2 ~]
++  degrees-q-col-3   [%qualified-column qualified-table-1 %col3 ~]
++  degrees-q-col-4   [%qualified-column qualified-table-1 %col4 ~]
++  degrees-q-col-5   [%qualified-column qualified-table-1 %col5 ~]
++  degrees-q-col-6   [%qualified-column qualified-table-1 %col6 ~]
++  degrees-q-col-7   [%qualified-column qualified-table-1 %col7 ~]
++  degrees-q-col-8   [%qualified-column qualified-table-1 %col8 ~]
++  degrees-q-col-9   [%qualified-column qualified-table-1 %col9 ~]
++  degrees-q-col-10  [%qualified-column qualified-table-1 %col10 ~]
++  degrees-q-col-11  [%qualified-column qualified-table-1 %col11 ~]
++  degrees-q-col-12  [%qualified-column qualified-table-1 %col12 ~]
++  degrees-q-col-13  [%qualified-column qualified-table-1 %col13 ~]
++  degrees-q-col-14  [%qualified-column qualified-table-1 %col14 ~]
++  degrees-q-col-15  [%qualified-column qualified-table-1 %col15 ~]
++  degrees-q-col-16  [%qualified-column qualified-table-1 %col16 ~]
::
++  degrees-qual-table-row  %-  mk-indexed-row
                             :~  [%col1 .~0]       ::  @rd 0.0
                                 [%col2 .~1]       ::  @rd 1.0
                                 [%col3 .~3.14]    ::  @rd 3.14
                                 [%col4 .~-3.14]   ::  @rd -3.14
                                 [%col5 .~24]      ::  @rd 24.0
                                 [%col6 .~-24]     ::  @rd -24.0
                                 [%col7 --0]       ::  @sd --0
                                 [%col8 --1]       ::  @sd --1
                                 [%col9 --3]       ::  @sd --3
                                 [%col10 -3]       ::  @sd -3
                                 [%col11 --24]     ::  @sd --24
                                 [%col12 -24]      ::  @sd -24
                                 [%col13 0]        ::  @ud 0
                                 [%col14 1]        ::  @ud 1
                                 [%col15 3]        ::  @ud 3
                                 [%col16 24]       ::  @ud 24
                             ==
::
::  unqualified: col1..col6=@rd, col7..col12=@sd, col13..col16=@ud
::
++  degrees-unqual-map-meta
  :-  %unqualified-map-meta
      %-  mk-unqualified-typ-addr-lookup
          %-  addr-columns
              :~  [%column %col1 ~.rd 0]
                  [%column %col2 ~.rd 0]
                  [%column %col3 ~.rd 0]
                  [%column %col4 ~.rd 0]
                  [%column %col5 ~.rd 0]
                  [%column %col6 ~.rd 0]
                  [%column %col7 ~.sd 0]
                  [%column %col8 ~.sd 0]
                  [%column %col9 ~.sd 0]
                  [%column %col10 ~.sd 0]
                  [%column %col11 ~.sd 0]
                  [%column %col12 ~.sd 0]
                  [%column %col13 ~.ud 0]
                  [%column %col14 ~.ud 0]
                  [%column %col15 ~.ud 0]
                  [%column %col16 ~.ud 0]
                  ==
::
++  degrees-unqual-lookup  %-  malt  %-  limo
                           :~  [%col1 ~[qualified-table-1]]
                               [%col2 ~[qualified-table-1]]
                               [%col3 ~[qualified-table-1]]
                               [%col4 ~[qualified-table-1]]
                               [%col5 ~[qualified-table-1]]
                               [%col6 ~[qualified-table-1]]
                               [%col7 ~[qualified-table-1]]
                               [%col8 ~[qualified-table-1]]
                               [%col9 ~[qualified-table-1]]
                               [%col10 ~[qualified-table-1]]
                               [%col11 ~[qualified-table-1]]
                               [%col12 ~[qualified-table-1]]
                               [%col13 ~[qualified-table-1]]
                               [%col14 ~[qualified-table-1]]
                               [%col15 ~[qualified-table-1]]
                               [%col16 ~[qualified-table-1]]
                           ==
::
++  degrees-u-col-1   [%unqualified-column %col1 ~]
++  degrees-u-col-2   [%unqualified-column %col2 ~]
++  degrees-u-col-3   [%unqualified-column %col3 ~]
++  degrees-u-col-4   [%unqualified-column %col4 ~]
++  degrees-u-col-5   [%unqualified-column %col5 ~]
++  degrees-u-col-6   [%unqualified-column %col6 ~]
++  degrees-u-col-7   [%unqualified-column %col7 ~]
++  degrees-u-col-8   [%unqualified-column %col8 ~]
++  degrees-u-col-9   [%unqualified-column %col9 ~]
++  degrees-u-col-10  [%unqualified-column %col10 ~]
++  degrees-u-col-11  [%unqualified-column %col11 ~]
++  degrees-u-col-12  [%unqualified-column %col12 ~]
++  degrees-u-col-13  [%unqualified-column %col13 ~]
++  degrees-u-col-14  [%unqualified-column %col14 ~]
++  degrees-u-col-15  [%unqualified-column %col15 ~]
++  degrees-u-col-16  [%unqualified-column %col16 ~]
::
++  degrees-unqual-table-row  %-  mk-indexed-row
                               :~  [%col1 .~0]       ::  @rd 0.0
                                   [%col2 .~1]       ::  @rd 1.0
                                   [%col3 .~3.14]    ::  @rd 3.14
                                   [%col4 .~-3.14]   ::  @rd -3.14
                                   [%col5 .~24]      ::  @rd 24.0
                                   [%col6 .~-24]     ::  @rd -24.0
                                   [%col7 --0]       ::  @sd --0
                                   [%col8 --1]       ::  @sd --1
                                   [%col9 --3]       ::  @sd --3
                                   [%col10 -3]       ::  @sd -3
                                   [%col11 --24]     ::  @sd --24
                                   [%col12 -24]      ::  @sd -24
                                   [%col13 0]        ::  @ud 0
                                   [%col14 1]        ::  @ud 1
                                   [%col15 3]        ::  @ud 3
                                   [%col16 24]       ::  @ud 24
                               ==
::
::  string test helpers
::  col1=@t 'hello', col2=@t 'world', col3=@t '  hello  ', col4=@t 'HELLO', col5=@ud 3
::
++  str-qual-map-meta
  %-  mk-qualified-map-meta
      :~  :-  qualified-table-1
              %-  addr-columns
                  :~  [%column %col1 ~.t 0]
                      [%column %col2 ~.t 0]
                      [%column %col3 ~.t 0]
                      [%column %col4 ~.t 0]
                      [%column %col5 ~.ud 0]
                      ==
          ==
::
++  str-q-col-1  [%qualified-column qualified-table-1 %col1 ~]
++  str-q-col-2  [%qualified-column qualified-table-1 %col2 ~]
++  str-q-col-3  [%qualified-column qualified-table-1 %col3 ~]
++  str-q-col-4  [%qualified-column qualified-table-1 %col4 ~]
++  str-q-col-5  [%qualified-column qualified-table-1 %col5 ~]
::
++  str-qual-table-row  %-  mk-indexed-row
                        :~  [%col1 'hello']          ::  @t
                            [%col2 'world']          ::  @t
                            [%col3 '  hello  ']      ::  @t with leading/trailing spaces
                            [%col4 'HELLO']          ::  @t uppercase
                            [%col5 3]                ::  @ud
                        ==
::
++  str-unqual-map-meta
  :-  %unqualified-map-meta
      %-  mk-unqualified-typ-addr-lookup
          %-  addr-columns
              :~  [%column %col6 ~.t 0]
                  [%column %col7 ~.t 0]
                  [%column %col8 ~.t 0]
                  [%column %col9 ~.t 0]
                  [%column %col10 ~.ud 0]
                  ==
::
++  str-unqual-lookup  %-  malt  %-  limo
                       :~  [%col6 ~[qualified-table-1]]
                           [%col7 ~[qualified-table-1]]
                           [%col8 ~[qualified-table-1]]
                           [%col9 ~[qualified-table-1]]
                           [%col10 ~[qualified-table-1]]
                       ==
::
++  str-u-col-6   [%unqualified-column %col6 ~]
++  str-u-col-7   [%unqualified-column %col7 ~]
++  str-u-col-8   [%unqualified-column %col8 ~]
++  str-u-col-9   [%unqualified-column %col9 ~]
++  str-u-col-10  [%unqualified-column %col10 ~]
::
++  str-unqual-table-row  %-  mk-indexed-row
                          :~  [%col6 'hello']         ::  @t
                              [%col7 'world']         ::  @t
                              [%col8 '  hello  ']     ::  @t with leading/trailing spaces
                              [%col9 'HELLO']         ::  @t uppercase
                              [%col10 3]              ::  @ud
                          ==
::
::  string trim test helpers
::  for testing pattern=(unit datum) as a column reference
::  qualified: col1=@t 'xxhelloxx', col2=@t 'x'
::  unqualified: col3=@t 'xxhelloxx', col4=@t 'x'
::
++  str-trim-qual-map-meta
  %-  mk-qualified-map-meta
      :~  :-  qualified-table-1
              %-  addr-columns
                  :~  [%column %col1 ~.t 0]
                      [%column %col2 ~.t 0]
                      ==
          ==
::
++  str-trim-q-col-1  [%qualified-column qualified-table-1 %col1 ~]
++  str-trim-q-col-2  [%qualified-column qualified-table-1 %col2 ~]
::
++  str-trim-qual-table-row  %-  mk-indexed-row
                             :~  [%col1 'xxhelloxx']  ::  @t string to trim
                                 [%col2 'x']          ::  @t trim character
                             ==
::
++  str-trim-unqual-map-meta
  :-  %unqualified-map-meta
      %-  mk-unqualified-typ-addr-lookup
          %-  addr-columns
              :~  [%column %col3 ~.t 0]
                  [%column %col4 ~.t 0]
                  ==
::
++  str-trim-unqual-lookup  %-  malt  %-  limo
                            :~  [%col3 ~[qualified-table-1]]
                                [%col4 ~[qualified-table-1]]
                            ==
::
++  str-trim-u-col-3  [%unqualified-column %col3 ~]
++  str-trim-u-col-4  [%unqualified-column %col4 ~]
::
++  str-trim-unqual-table-row  %-  mk-indexed-row
                               :~  [%col3 'xxhelloxx']  ::  @t string to trim
                                   [%col4 'x']          ::  @t trim character
                               ==
::
::  string numeric test helpers (for %string function)
::  col1=@ud 42, col2=@sd --42, col3=@sd -42, col4=@rd .~42.42, col5=@rd .~-24.24
::
++  str-num-qual-map-meta
  %-  mk-qualified-map-meta
      :~  :-  qualified-table-1
              %-  addr-columns
                  :~  [%column %col1 ~.ud 0]
                      [%column %col2 ~.sd 0]
                      [%column %col3 ~.sd 0]
                      [%column %col4 ~.rd 0]
                      [%column %col5 ~.rd 0]
                      ==
          ==
::
++  str-num-q-col-1  [%qualified-column qualified-table-1 %col1 ~]
++  str-num-q-col-2  [%qualified-column qualified-table-1 %col2 ~]
++  str-num-q-col-3  [%qualified-column qualified-table-1 %col3 ~]
++  str-num-q-col-4  [%qualified-column qualified-table-1 %col4 ~]
++  str-num-q-col-5  [%qualified-column qualified-table-1 %col5 ~]
::
++  str-num-qual-table-row  %-  mk-indexed-row
                            :~  [%col1 42]        ::  @ud 42
                                [%col2 --42]      ::  @sd --42 positive
                                [%col3 -42]       ::  @sd -42 negative
                                [%col4 .~42.42]   ::  @rd 42.42
                                [%col5 .~-24.24]  ::  @rd -24.24
                            ==
::
++  str-num-unqual-map-meta
  :-  %unqualified-map-meta
      %-  mk-unqualified-typ-addr-lookup
          %-  addr-columns
              :~  [%column %col6 ~.ud 0]
                  [%column %col7 ~.sd 0]
                  [%column %col8 ~.sd 0]
                  [%column %col9 ~.rd 0]
                  [%column %col10 ~.rd 0]
                  ==
::
++  str-num-unqual-lookup  %-  malt  %-  limo
                           :~  [%col6 ~[qualified-table-1]]
                               [%col7 ~[qualified-table-1]]
                               [%col8 ~[qualified-table-1]]
                               [%col9 ~[qualified-table-1]]
                               [%col10 ~[qualified-table-1]]
                           ==
::
++  str-num-u-col-6   [%unqualified-column %col6 ~]
++  str-num-u-col-7   [%unqualified-column %col7 ~]
++  str-num-u-col-8   [%unqualified-column %col8 ~]
++  str-num-u-col-9   [%unqualified-column %col9 ~]
++  str-num-u-col-10  [%unqualified-column %col10 ~]
::
++  str-num-unqual-table-row  %-  mk-indexed-row
                              :~  [%col6 42]        ::  @ud 42
                                  [%col7 --42]      ::  @sd --42 positive
                                  [%col8 -42]       ::  @sd -42 negative
                                  [%col9 .~42.42]   ::  @rd 42.42
                                  [%col10 .~-24.24] ::  @rd -24.24
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
                                      then=[~.ud 4]
                                      else=[~.ud 5]
                                    ==
                                    table-named-ctes
                                    qual-lookup
                                    qual-map-meta
                                    *(map @tas resolved-scalar)
                                    (bowl [0 ~2026.4.21])
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
++  test-abs-qual
  %:  run-scalar-tests
    table-named-ctes
    qual-lookup
    abs-qual-map-meta
    *(map @tas resolved-scalar)
    abs-qual-table-row
    :~
    ::  abs(@sd -1) = @sd --1 = atom 2
    :-  %abs-literal-sd-neg
        :-  [%abs [~.sd -1]]
            [~.sd --1]
    ::  abs(@sd --1) = @sd --1 = atom 2
    :-  %abs-literal-sd-pos
        :-  [%abs [~.sd --1]]
            [~.sd --1]
    :-  %abs-literal-ud
        :-  [%abs [~.ud 5]]
            [~.ud 5]
    ::  abs(@rd -1.0) = @rd 1.0
    :-  %abs-literal-rd-neg
        :-  [%abs [~.rd .~-1]]
            [~.rd .~1]
    ::  abs(@rd 1.0) = @rd 1.0
    :-  %abs-literal-rd-pos
        :-  [%abs [~.rd .~1]]
            [~.rd .~1]
    ::  abs(@sd -3) = @sd --3 = atom 6
    :-  %abs-qual-sd-neg
        :-  [%abs q-col-1]
            [~.sd --3]
    ::  abs(@sd --2) = @sd --2 = atom 4
    :-  %abs-qual-sd-pos
        :-  [%abs q-col-2]
            [~.sd --2]
    ::  abs(@rd -1.0) = @rd 1.0
    :-  %abs-qual-rd-neg
        :-  [%abs q-col-3]
            [~.rd .~1]
    ::  abs(@rd 2.0) = @rd 2.0
    :-  %abs-qual-rd-pos
        :-  [%abs abs-q-col-4]
            [~.rd .~2]
    ::  abs(@ud 5) = @ud 5
    :-  %abs-qual-ud
        :-  [%abs abs-q-col-5]
            [~.ud 5]
  ==
  ==
::
++  test-abs-unqual
  %:  run-scalar-tests
    table-named-ctes
    abs-unqual-lookup
    abs-unqual-map-meta
    *(map @tas resolved-scalar)
    abs-unqual-table-row
    :~
    ::  abs(@sd -3) = @sd --3 = atom 6
    :-  %abs-unqual-sd-neg
        :-  [%abs u-col-4]
            [~.sd --3]
    ::  abs(@sd --2) = @sd --2 = atom 4
    :-  %abs-unqual-sd-pos
        :-  [%abs u-col-5]
            [~.sd --2]
    ::  abs(@rd -1.0) = @rd 1.0
    :-  %abs-unqual-rd-neg
        :-  [%abs u-col-6]
            [~.rd .~1]
    ::  abs(@rd 2.0) = @rd 2.0
    :-  %abs-unqual-rd-pos
        :-  [%abs u-col-7]
            [~.rd .~2]
    ::  abs(@ud 8) = @ud 8
    :-  %abs-unqual-ud
        :-  [%abs u-col-8]
            [~.ud 8]
  ==
  ==
::
::  %sign tests
::
++  test-sign-qual
  %:  run-scalar-tests
    table-named-ctes
    qual-lookup
    sign-qual-map-meta
    *(map @tas resolved-scalar)
    sign-qual-table-row
    :~
    :-  %sign-literal-sd-zero
        :-  [%sign [~.sd --0]]
            [~.sd --0]
    ::  sign(@sd -1) = @sd -1
    :-  %sign-literal-sd-neg
        :-  [%sign [~.sd -1]]
            [~.sd -1]
    ::  sign(@sd --1) = @sd --1
    :-  %sign-literal-sd-pos
        :-  [%sign [~.sd --1]]
            [~.sd --1]
    :-  %sign-literal-rd-zero
        :-  [%sign [~.rd .~0]]
            [~.rd .~0]
    :-  %sign-literal-rd-neg
        :-  [%sign [~.rd .~-1]]
            [~.rd .~-1]
    :-  %sign-literal-rd-pos
        :-  [%sign [~.rd .~1]]
            [~.rd .~1]
    :-  %sign-literal-ud-zero
        :-  [%sign [~.ud 0]]
            [~.ud 0]
    :-  %sign-literal-ud-pos
        :-  [%sign [~.ud 1]]
            [~.ud 1]
    :-  %sign-qual-sd-zero
        :-  [%sign q-col-1]
            [~.sd --0]
    ::  sign(@sd -1) = @sd -1
    :-  %sign-qual-sd-neg
        :-  [%sign q-col-2]
            [~.sd -1]
    ::  sign(@sd --1) = @sd --1
    :-  %sign-qual-sd-pos
        :-  [%sign q-col-3]
            [~.sd --1]
    :-  %sign-qual-rd-zero
        :-  [%sign sign-q-col-4]
            [~.rd .~0]
    :-  %sign-qual-rd-neg
        :-  [%sign sign-q-col-5]
            [~.rd .~-1]
    :-  %sign-qual-rd-pos
        :-  [%sign sign-q-col-6]
            [~.rd .~1]
    :-  %sign-qual-ud-zero
        :-  [%sign sign-q-col-7]
            [~.ud 0]
    :-  %sign-qual-ud-pos
        :-  [%sign sign-q-col-8]
            [~.ud 1]
    ==
  ==
::
++  test-sign-unqual
  %:  run-scalar-tests
    table-named-ctes
    sign-unqual-lookup
    sign-unqual-map-meta
    *(map @tas resolved-scalar)
    sign-unqual-table-row
    :~
    :-  %sign-unqual-sd-zero
        :-  [%sign sign-u-col-1]
            [~.sd --0]
    ::  sign(@sd -1) = @sd -1
    :-  %sign-unqual-sd-neg
        :-  [%sign sign-u-col-2]
            [~.sd -1]
    ::  sign(@sd --1) = @sd --1
    :-  %sign-unqual-sd-pos
        :-  [%sign sign-u-col-3]
            [~.sd --1]
    :-  %sign-unqual-rd-zero
        :-  [%sign u-col-4]
            [~.rd .~0]
    :-  %sign-unqual-rd-neg
        :-  [%sign u-col-5]
            [~.rd .~-1]
    :-  %sign-unqual-rd-pos
        :-  [%sign u-col-6]
            [~.rd .~1]
    :-  %sign-unqual-ud-zero
        :-  [%sign u-col-7]
            [~.ud 0]
    :-  %sign-unqual-ud-pos
        :-  [%sign u-col-8]
            [~.ud 1]
    ==
  ==
::
::  %sqrt tests
::
++  test-sqrt-qual
  %:  run-scalar-tests
    table-named-ctes
    qual-lookup
    sqrt-qual-map-meta
    *(map @tas resolved-scalar)
    sqrt-qual-table-row
    :~
    :-  %sqrt-literal-rd-zero
        :-  [%sqrt [~.rd .~0]]
            [~.rd .~0]
    ::  sqrt(@rd 1.0) = 1.0
    :-  %sqrt-literal-rd-one
        :-  [%sqrt [~.rd .~1]]
            [~.rd .~1]
    ::  sqrt(@rd 4.0) = 2.0
    :-  %sqrt-literal-rd-four
        :-  [%sqrt [~.rd .~4]]
            [~.rd .~2]
    :-  %sqrt-literal-sd-zero
        :-  [%sqrt [~.sd --0]]
            [~.sd --0]
    ::  sqrt(@sd --1) = --1
    :-  %sqrt-literal-sd-one
        :-  [%sqrt [~.sd --1]]
            [~.sd --1]
    ::  sqrt(@sd --4) = --2
    :-  %sqrt-literal-sd-four
        :-  [%sqrt [~.sd --4]]
            [~.sd --2]
    :-  %sqrt-literal-ud-zero
        :-  [%sqrt [~.ud 0]]
            [~.ud 0]
    :-  %sqrt-literal-ud-one
        :-  [%sqrt [~.ud 1]]
            [~.ud 1]
    ::  sqrt(@ud 4) = 2
    :-  %sqrt-literal-ud-four
        :-  [%sqrt [~.ud 4]]
            [~.ud 2]
    :-  %sqrt-qual-rd-zero
        :-  [%sqrt sqrt-q-col-1]
            [~.rd .~0]
    :-  %sqrt-qual-rd-one
        :-  [%sqrt sqrt-q-col-2]
            [~.rd .~1]
    ::  sqrt(@rd 4.0) = 2.0
    :-  %sqrt-qual-rd-four
        :-  [%sqrt sqrt-q-col-3]
            [~.rd .~2]
    :-  %sqrt-qual-sd-zero
        :-  [%sqrt sqrt-q-col-4]
            [~.sd --0]
    :-  %sqrt-qual-sd-one
        :-  [%sqrt sqrt-q-col-5]
            [~.sd --1]
    ::  sqrt(@sd --4) = --2
    :-  %sqrt-qual-sd-four
        :-  [%sqrt sqrt-q-col-6]
            [~.sd --2]
    :-  %sqrt-qual-ud-zero
        :-  [%sqrt sqrt-q-col-7]
            [~.ud 0]
    :-  %sqrt-qual-ud-one
        :-  [%sqrt sqrt-q-col-8]
            [~.ud 1]
    ::  sqrt(@ud 4) = 2
    :-  %sqrt-qual-ud-four
        :-  [%sqrt sqrt-q-col-9]
            [~.ud 2]
    ==
  ==
::
++  test-sqrt-unqual
  %:  run-scalar-tests
    table-named-ctes
    sqrt-unqual-lookup
    sqrt-unqual-map-meta
    *(map @tas resolved-scalar)
    sqrt-unqual-table-row
    :~
    :-  %sqrt-unqual-rd-zero
        :-  [%sqrt sqrt-u-col-1]
            [~.rd .~0]
    :-  %sqrt-unqual-rd-one
        :-  [%sqrt sqrt-u-col-2]
            [~.rd .~1]
    ::  sqrt(@rd 4.0) = 2.0
    :-  %sqrt-unqual-rd-four
        :-  [%sqrt sqrt-u-col-3]
            [~.rd .~2]
    :-  %sqrt-unqual-sd-zero
        :-  [%sqrt sqrt-u-col-4]
            [~.sd --0]
    :-  %sqrt-unqual-sd-one
        :-  [%sqrt sqrt-u-col-5]
            [~.sd --1]
    ::  sqrt(@sd --4) = --2
    :-  %sqrt-unqual-sd-four
        :-  [%sqrt sqrt-u-col-6]
            [~.sd --2]
    :-  %sqrt-unqual-ud-zero
        :-  [%sqrt sqrt-u-col-7]
            [~.ud 0]
    :-  %sqrt-unqual-ud-one
        :-  [%sqrt sqrt-u-col-8]
            [~.ud 1]
    ::  sqrt(@ud 4) = 2
    :-  %sqrt-unqual-ud-four
        :-  [%sqrt sqrt-u-col-9]
            [~.ud 2]
    ==
  ==
::
::  %floor tests
::
++  test-floor-qual
  %:  run-scalar-tests
    table-named-ctes
    qual-lookup
    floor-qual-map-meta
    *(map @tas resolved-scalar)
    floor-qual-table-row
    :~
    :-  %floor-literal-rd-zero
        :-  [%floor [~.rd .~0]]
            [~.rd .~0]
    ::  floor(@rd 1.5) = 1.0
    :-  %floor-literal-rd-one-five
        :-  [%floor [~.rd .~1.5]]
            [~.rd .~1]
    ::  floor(@rd -1.5) = -2.0
    :-  %floor-literal-rd-neg-one-five
        :-  [%floor [~.rd .~-1.5]]
            [~.rd .~-2]
    :-  %floor-literal-sd-zero
        :-  [%floor [~.sd --0]]
            [~.sd --0]
    :-  %floor-literal-sd-one
        :-  [%floor [~.sd --1]]
            [~.sd --1]
    :-  %floor-literal-sd-neg
        :-  [%floor [~.sd -1]]
            [~.sd -1]
    :-  %floor-literal-ud-zero
        :-  [%floor [~.ud 0]]
            [~.ud 0]
    :-  %floor-literal-ud-one
        :-  [%floor [~.ud 1]]
            [~.ud 1]
    :-  %floor-literal-ud-two
        :-  [%floor [~.ud 2]]
            [~.ud 2]
    :-  %floor-qual-rd-zero
        :-  [%floor floor-q-col-1]
            [~.rd .~0]
    ::  floor(@rd 1.5) = 1.0
    :-  %floor-qual-rd-one-five
        :-  [%floor floor-q-col-2]
            [~.rd .~1]
    ::  floor(@rd -1.5) = -2.0
    :-  %floor-qual-rd-neg-one-five
        :-  [%floor floor-q-col-3]
            [~.rd .~-2]
    :-  %floor-qual-sd-zero
        :-  [%floor floor-q-col-4]
            [~.sd --0]
    :-  %floor-qual-sd-one
        :-  [%floor floor-q-col-5]
            [~.sd --1]
    :-  %floor-qual-sd-neg
        :-  [%floor floor-q-col-6]
            [~.sd -1]
    :-  %floor-qual-ud-zero
        :-  [%floor floor-q-col-7]
            [~.ud 0]
    :-  %floor-qual-ud-one
        :-  [%floor floor-q-col-8]
            [~.ud 1]
    :-  %floor-qual-ud-two
        :-  [%floor floor-q-col-9]
            [~.ud 2]
    ==
  ==
::
++  test-floor-unqual
  %:  run-scalar-tests
    table-named-ctes
    floor-unqual-lookup
    floor-unqual-map-meta
    *(map @tas resolved-scalar)
    floor-unqual-table-row
    :~
    :-  %floor-unqual-rd-zero
        :-  [%floor floor-u-col-1]
            [~.rd .~0]
    ::  floor(@rd 1.5) = 1.0
    :-  %floor-unqual-rd-one-five
        :-  [%floor floor-u-col-2]
            [~.rd .~1]
    ::  floor(@rd -1.5) = -2.0
    :-  %floor-unqual-rd-neg-one-five
        :-  [%floor floor-u-col-3]
            [~.rd .~-2]
    :-  %floor-unqual-sd-zero
        :-  [%floor floor-u-col-4]
            [~.sd --0]
    :-  %floor-unqual-sd-one
        :-  [%floor floor-u-col-5]
            [~.sd --1]
    :-  %floor-unqual-sd-neg
        :-  [%floor floor-u-col-6]
            [~.sd -1]
    :-  %floor-unqual-ud-zero
        :-  [%floor floor-u-col-7]
            [~.ud 0]
    :-  %floor-unqual-ud-one
        :-  [%floor floor-u-col-8]
            [~.ud 1]
    :-  %floor-unqual-ud-two
        :-  [%floor floor-u-col-9]
            [~.ud 2]
    ==
  ==
::
::  %ceiling tests
::
++  test-ceiling-qual
  %:  run-scalar-tests
    table-named-ctes
    qual-lookup
    ceiling-qual-map-meta
    *(map @tas resolved-scalar)
    ceiling-qual-table-row
    :~
    :-  %ceiling-literal-rd-zero
        :-  [%ceiling [~.rd .~0]]
            [~.rd .~0]
    ::  ceiling(@rd 1.5) = 2.0
    :-  %ceiling-literal-rd-one-five
        :-  [%ceiling [~.rd .~1.5]]
            [~.rd .~2]
    ::  ceiling(@rd -1.5) = -1.0
    :-  %ceiling-literal-rd-neg-one-five
        :-  [%ceiling [~.rd .~-1.5]]
            [~.rd .~-1]
    :-  %ceiling-literal-sd-zero
        :-  [%ceiling [~.sd --0]]
            [~.sd --0]
    :-  %ceiling-literal-sd-one
        :-  [%ceiling [~.sd --1]]
            [~.sd --1]
    :-  %ceiling-literal-sd-neg
        :-  [%ceiling [~.sd -1]]
            [~.sd -1]
    :-  %ceiling-literal-ud-zero
        :-  [%ceiling [~.ud 0]]
            [~.ud 0]
    :-  %ceiling-literal-ud-one
        :-  [%ceiling [~.ud 1]]
            [~.ud 1]
    :-  %ceiling-literal-ud-two
        :-  [%ceiling [~.ud 2]]
            [~.ud 2]
    :-  %ceiling-qual-rd-zero
        :-  [%ceiling ceiling-q-col-1]
            [~.rd .~0]
    ::  ceiling(@rd 1.5) = 2.0
    :-  %ceiling-qual-rd-one-five
        :-  [%ceiling ceiling-q-col-2]
            [~.rd .~2]
    ::  ceiling(@rd -1.5) = -1.0
    :-  %ceiling-qual-rd-neg-one-five
        :-  [%ceiling ceiling-q-col-3]
            [~.rd .~-1]
    :-  %ceiling-qual-sd-zero
        :-  [%ceiling ceiling-q-col-4]
            [~.sd --0]
    :-  %ceiling-qual-sd-one
        :-  [%ceiling ceiling-q-col-5]
            [~.sd --1]
    :-  %ceiling-qual-sd-neg
        :-  [%ceiling ceiling-q-col-6]
            [~.sd -1]
    :-  %ceiling-qual-ud-zero
        :-  [%ceiling ceiling-q-col-7]
            [~.ud 0]
    :-  %ceiling-qual-ud-one
        :-  [%ceiling ceiling-q-col-8]
            [~.ud 1]
    :-  %ceiling-qual-ud-two
        :-  [%ceiling ceiling-q-col-9]
            [~.ud 2]
    ==
  ==
::
++  test-ceiling-unqual
  %:  run-scalar-tests
    table-named-ctes
    ceiling-unqual-lookup
    ceiling-unqual-map-meta
    *(map @tas resolved-scalar)
    ceiling-unqual-table-row
    :~
    :-  %ceiling-unqual-rd-zero
        :-  [%ceiling ceiling-u-col-1]
            [~.rd .~0]
    ::  ceiling(@rd 1.5) = 2.0
    :-  %ceiling-unqual-rd-one-five
        :-  [%ceiling ceiling-u-col-2]
            [~.rd .~2]
    ::  ceiling(@rd -1.5) = -1.0
    :-  %ceiling-unqual-rd-neg-one-five
        :-  [%ceiling ceiling-u-col-3]
            [~.rd .~-1]
    :-  %ceiling-unqual-sd-zero
        :-  [%ceiling ceiling-u-col-4]
            [~.sd --0]
    :-  %ceiling-unqual-sd-one
        :-  [%ceiling ceiling-u-col-5]
            [~.sd --1]
    :-  %ceiling-unqual-sd-neg
        :-  [%ceiling ceiling-u-col-6]
            [~.sd -1]
    :-  %ceiling-unqual-ud-zero
        :-  [%ceiling ceiling-u-col-7]
            [~.ud 0]
    :-  %ceiling-unqual-ud-one
        :-  [%ceiling ceiling-u-col-8]
            [~.ud 1]
    :-  %ceiling-unqual-ud-two
        :-  [%ceiling ceiling-u-col-9]
            [~.ud 2]
    ==
  ==
::
::  %round tests
::
++  test-round-qual
  %:  run-scalar-tests
    table-named-ctes
    qual-lookup
    round-frac-qual-map-meta
    *(map @tas resolved-scalar)
    round-frac-qual-table-row
    :~
    :-  %round-literal-rd-zero
        :-  [%round [~.rd .~0] [~.ud 0]]
            [~.rd .~0]
    ::  round(.~1.5, 0) = .~2  (half rounds up)
    :-  %round-literal-rd-one-five-pos-len
        :-  [%round [~.rd .~1.5] [~.ud 0]]
            [~.rd .~2]
    ::  round(.~-1.5, 0) = .~-1  (toward +inf)
    :-  %round-literal-rd-neg-one-five-pos-len
        :-  [%round [~.rd .~-1.5] [~.ud 0]]
            [~.rd .~-1]
    ::  round(.~15, @sd -1) = .~20
    :-  %round-literal-rd-fifteen-neg-len
        :-  [%round [~.rd .~15] [~.sd -1]]
            [~.rd .~20]
    ::  round(.~-15, @sd -1) = .~-10
    :-  %round-literal-rd-neg-fifteen-neg-len
        :-  [%round [~.rd .~-15] [~.sd -1]]
            [~.rd .~-10]
    :-  %round-literal-sd-zero
        :-  [%round [~.sd --0] [~.ud 0]]
            [~.sd --0]
    ::  round(--1.234, @sd -1) = --1.230
    :-  %round-literal-sd-pos-neg-len
        :-  [%round [~.sd --1.234] [~.sd -1]]
            [~.sd --1.230]
    ::  round(-1.234, @sd -1) = -1.230
    :-  %round-literal-sd-neg-neg-len
        :-  [%round [~.sd -1.234] [~.sd -1]]
            [~.sd -1.230]
    :-  %round-literal-ud-zero
        :-  [%round [~.ud 0] [~.ud 0]]
            [~.ud 0]
    ::  round(1.234, @sd -1) = 1.230
    :-  %round-literal-ud-pos-neg-len
        :-  [%round [~.ud 1.234] [~.sd -1]]
            [~.ud 1.230]
    ::  round(1.235, @sd -1) = 1.240  (half rounds up)
    :-  %round-literal-ud-half-neg-len
        :-  [%round [~.ud 1.235] [~.sd -1]]
            [~.ud 1.240]
    :-  %round-qual-rd-zero
        :-  [%round round-frac-q-col-1 [~.ud 0]]
            [~.rd .~0]
    ::  round(col2=1.5, 0) = .~2
    :-  %round-qual-rd-one-five-pos-len
        :-  [%round round-frac-q-col-2 [~.ud 0]]
            [~.rd .~2]
    ::  round(col3=-1.5, 0) = .~-1
    :-  %round-qual-rd-neg-one-five-pos-len
        :-  [%round round-frac-q-col-3 [~.ud 0]]
            [~.rd .~-1]
    ::  round(col4=15.0, @sd -1) = .~20
    :-  %round-qual-rd-fifteen-neg-len
        :-  [%round round-frac-q-col-4 [~.sd -1]]
            [~.rd .~20]
    ::  round(col5=-15.0, @sd -1) = .~-10
    :-  %round-qual-rd-neg-fifteen-neg-len
        :-  [%round round-frac-q-col-5 [~.sd -1]]
            [~.rd .~-10]
    ::  round(col6=--1.234, @sd -1) = --1.230
    :-  %round-qual-sd-pos-neg-len
        :-  [%round round-frac-q-col-6 [~.sd -1]]
            [~.sd --1.230]
    ::  round(col7=-1.234, @sd -1) = -1.230
    :-  %round-qual-sd-neg-neg-len
        :-  [%round round-frac-q-col-7 [~.sd -1]]
            [~.sd -1.230]
    ::  round(col8=1.234, @sd -1) = 1.230
    :-  %round-qual-ud-neg-len
        :-  [%round round-frac-q-col-8 [~.sd -1]]
            [~.ud 1.230]
    ::  round(col9=1.235, @sd -1) = 1.240
    :-  %round-qual-ud-half-neg-len
        :-  [%round round-frac-q-col-9 [~.sd -1]]
            [~.ud 1.240]
    ::
    ::  length 2: @sd and @ud pass through; @rd rounds to 2 decimal places
    ::
    ::  round(.~1.5, 2) = .~1.5  (already ≤2dp)
    :-  %round-literal-rd-one-five-len-2
        :-  [%round [~.rd .~1.5] [~.ud 2]]
            [~.rd .~1.5]
    ::  round(.~-1.5, 2) = .~-1.5
    :-  %round-literal-rd-neg-one-five-len-2
        :-  [%round [~.rd .~-1.5] [~.ud 2]]
            [~.rd .~-1.5]
    ::  round(--1.234, 2) = --1.234  (pass-through)
    :-  %round-literal-sd-pos-len-2
        :-  [%round [~.sd --1.234] [~.ud 2]]
            [~.sd --1.234]
    ::  round(-1.234, 2) = -1.234
    :-  %round-literal-sd-neg-len-2
        :-  [%round [~.sd -1.234] [~.ud 2]]
            [~.sd -1.234]
    ::  round(1.234, 2) = 1.234  (pass-through)
    :-  %round-literal-ud-len-2
        :-  [%round [~.ud 1.234] [~.ud 2]]
            [~.ud 1.234]
    ::  round(col2=1.5, 2) = .~1.5
    :-  %round-qual-rd-one-five-len-2
        :-  [%round round-frac-q-col-2 [~.ud 2]]
            [~.rd .~1.5]
    ::  round(col3=-1.5, 2) = .~-1.5
    :-  %round-qual-rd-neg-one-five-len-2
        :-  [%round round-frac-q-col-3 [~.ud 2]]
            [~.rd .~-1.5]
    ::  round(col6=--1.234, 2) = --1.234  (pass-through)
    :-  %round-qual-sd-pos-len-2
        :-  [%round round-frac-q-col-6 [~.ud 2]]
            [~.sd --1.234]
    ::  round(col7=-1.234, 2) = -1.234
    :-  %round-qual-sd-neg-len-2
        :-  [%round round-frac-q-col-7 [~.ud 2]]
            [~.sd -1.234]
    ::  round(col8=1.234, 2) = 1.234  (pass-through)
    :-  %round-qual-ud-len-2
        :-  [%round round-frac-q-col-8 [~.ud 2]]
            [~.ud 1.234]
    ::
    ::  length -2: round to nearest 100
    ::
    ::  round(.~150, @sd -2) = .~200  (half rounds up)
    :-  %round-literal-rd-one-fifty-neg-len-2
        :-  [%round [~.rd .~150] [~.sd -2]]
            [~.rd .~200]
    ::  round(.~-150, @sd -2) = .~-100  (toward +inf)
    :-  %round-literal-rd-neg-one-fifty-neg-len-2
        :-  [%round [~.rd .~-150] [~.sd -2]]
            [~.rd .~-100]
    ::  round(.~123, @sd -2) = .~100
    :-  %round-literal-rd-one-two-three-neg-len-2
        :-  [%round [~.rd .~123] [~.sd -2]]
            [~.rd .~100]
    ::  round(--12.345, @sd -2) = --12.300
    :-  %round-literal-sd-pos-neg-len-2
        :-  [%round [~.sd --12.345] [~.sd -2]]
            [~.sd --12.300]
    ::  round(-12.345, @sd -2) = -12.300
    :-  %round-literal-sd-neg-neg-len-2
        :-  [%round [~.sd -12.345] [~.sd -2]]
            [~.sd -12.300]
    ::  round(12.345, @sd -2) = 12.300
    :-  %round-literal-ud-neg-len-2
        :-  [%round [~.ud 12.345] [~.sd -2]]
            [~.ud 12.300]
    ::  round(12.350, @sd -2) = 12.400  (half rounds up)
    :-  %round-literal-ud-half-neg-len-2
        :-  [%round [~.ud 12.350] [~.sd -2]]
            [~.ud 12.400]
    ::  round(col4=15.0, @sd -2) = .~0
    :-  %round-qual-rd-fifteen-neg-len-2
        :-  [%round round-frac-q-col-4 [~.sd -2]]
            [~.rd .~0]
    ::  round(col5=-15.0, @sd -2) = .~0
    :-  %round-qual-rd-neg-fifteen-neg-len-2
        :-  [%round round-frac-q-col-5 [~.sd -2]]
            [~.rd .~0]
    ::  round(col6=--1.234, @sd -2) = --1.200
    :-  %round-qual-sd-pos-neg-len-2
        :-  [%round round-frac-q-col-6 [~.sd -2]]
            [~.sd --1.200]
    ::  round(col7=-1.234, @sd -2) = -1.200
    :-  %round-qual-sd-neg-neg-len-2
        :-  [%round round-frac-q-col-7 [~.sd -2]]
            [~.sd -1.200]
    ::  round(col8=1.234, @sd -2) = 1.200
    :-  %round-qual-ud-neg-len-2
        :-  [%round round-frac-q-col-8 [~.sd -2]]
            [~.ud 1.200]
    ::  round(col9=1.235, @sd -2) = 1.200
    :-  %round-qual-ud-neg-len-2-col9
        :-  [%round round-frac-q-col-9 [~.sd -2]]
            [~.ud 1.200]
    ==
  ==
::
++  test-round-unqual
  %:  run-scalar-tests
    table-named-ctes
    round-frac-unqual-lookup
    round-frac-unqual-map-meta
    *(map @tas resolved-scalar)
    round-frac-unqual-table-row
    :~
    :-  %round-unqual-rd-zero
        :-  [%round round-frac-u-col-1 [~.ud 0]]
            [~.rd .~0]
    ::  round(col2=1.5, 0) = .~2
    :-  %round-unqual-rd-one-five-pos-len
        :-  [%round round-frac-u-col-2 [~.ud 0]]
            [~.rd .~2]
    ::  round(col3=-1.5, 0) = .~-1
    :-  %round-unqual-rd-neg-one-five-pos-len
        :-  [%round round-frac-u-col-3 [~.ud 0]]
            [~.rd .~-1]
    ::  round(col4=15.0, @sd -1) = .~20
    :-  %round-unqual-rd-fifteen-neg-len
        :-  [%round round-frac-u-col-4 [~.sd -1]]
            [~.rd .~20]
    ::  round(col5=-15.0, @sd -1) = .~-10
    :-  %round-unqual-rd-neg-fifteen-neg-len
        :-  [%round round-frac-u-col-5 [~.sd -1]]
            [~.rd .~-10]
    ::  round(col6=--1.234, @sd -1) = --1.230
    :-  %round-unqual-sd-pos-neg-len
        :-  [%round round-frac-u-col-6 [~.sd -1]]
            [~.sd --1.230]
    ::  round(col7=-1.234, @sd -1) = -1.230
    :-  %round-unqual-sd-neg-neg-len
        :-  [%round round-frac-u-col-7 [~.sd -1]]
            [~.sd -1.230]
    ::  round(col8=1.234, @sd -1) = 1.230
    :-  %round-unqual-ud-neg-len
        :-  [%round round-frac-u-col-8 [~.sd -1]]
            [~.ud 1.230]
    ::  round(col9=1.235, @sd -1) = 1.240
    :-  %round-unqual-ud-half-neg-len
        :-  [%round round-frac-u-col-9 [~.sd -1]]
            [~.ud 1.240]
    ::
    ::  length 2
    ::
    ::  round(col2=1.5, 2) = .~1.5
    :-  %round-unqual-rd-one-five-len-2
        :-  [%round round-frac-u-col-2 [~.ud 2]]
            [~.rd .~1.5]
    ::  round(col3=-1.5, 2) = .~-1.5
    :-  %round-unqual-rd-neg-one-five-len-2
        :-  [%round round-frac-u-col-3 [~.ud 2]]
            [~.rd .~-1.5]
    ::  round(col6=--1.234, 2) = --1.234  (pass-through)
    :-  %round-unqual-sd-pos-len-2
        :-  [%round round-frac-u-col-6 [~.ud 2]]
            [~.sd --1.234]
    ::  round(col7=-1.234, 2) = -1.234
    :-  %round-unqual-sd-neg-len-2
        :-  [%round round-frac-u-col-7 [~.ud 2]]
            [~.sd -1.234]
    ::  round(col8=1.234, 2) = 1.234  (pass-through)
    :-  %round-unqual-ud-len-2
        :-  [%round round-frac-u-col-8 [~.ud 2]]
            [~.ud 1.234]
    ::
    ::  length -2
    ::
    ::  round(col4=15.0, @sd -2) = .~0
    :-  %round-unqual-rd-fifteen-neg-len-2
        :-  [%round round-frac-u-col-4 [~.sd -2]]
            [~.rd .~0]
    ::  round(col5=-15.0, @sd -2) = .~0
    :-  %round-unqual-rd-neg-fifteen-neg-len-2
        :-  [%round round-frac-u-col-5 [~.sd -2]]
            [~.rd .~0]
    ::  round(col6=--1.234, @sd -2) = --1.200
    :-  %round-unqual-sd-pos-neg-len-2
        :-  [%round round-frac-u-col-6 [~.sd -2]]
            [~.sd --1.200]
    ::  round(col7=-1.234, @sd -2) = -1.200
    :-  %round-unqual-sd-neg-neg-len-2
        :-  [%round round-frac-u-col-7 [~.sd -2]]
            [~.sd -1.200]
    ::  round(col8=1.234, @sd -2) = 1.200
    :-  %round-unqual-ud-neg-len-2
        :-  [%round round-frac-u-col-8 [~.sd -2]]
            [~.ud 1.200]
    ::  round(col9=1.235, @sd -2) = 1.200
    :-  %round-unqual-ud-neg-len-2-col9
        :-  [%round round-frac-u-col-9 [~.sd -2]]
            [~.ud 1.200]
    ==
  ==
::
::  constant tests
::
++  test-constants
  %:  run-scalar-tests
    table-named-ctes
    qual-lookup
    qual-map-meta
    *(map @tas resolved-scalar)
    table-row
    :~
    :-  %e
        :-  [%e ~]
            [~.rd .~2.718281828459045]
    :-  %phi
        :-  [%phi ~]
            [~.rd .~1.618033988749895]
    :-  %pi
        :-  [%pi ~]
            [~.rd .~3.141592653589793]
    :-  %tau
        :-  [%tau ~]
            [~.rd .~6.283185307179586]
  ==
  ==
::
::  %max tests
::
++  test-max-qual
  %:  run-scalar-tests
    table-named-ctes
    qual-lookup
    minmax-qual-map-meta
    *(map @tas resolved-scalar)
    minmax-qual-table-row
    :~
    ::  literal / literal
    ::  max(.~-3, .~2) = .~2
    :-  %max-lit-rd-neg-pos
        :-  [%max [~.rd .~-3] [~.rd .~2]]
            [~.rd .~2]
    ::  max(.~2, .~-3) = .~2
    :-  %max-lit-rd-pos-neg
        :-  [%max [~.rd .~2] [~.rd .~-3]]
            [~.rd .~2]
    ::  max(.~-3, .~-1) = .~-1  (both negative)
    :-  %max-lit-rd-neg-neg
        :-  [%max [~.rd .~-3] [~.rd .~-1]]
            [~.rd .~-1]
    ::  max(.~1, .~2) = .~2  (both positive)
    :-  %max-lit-rd-pos-pos
        :-  [%max [~.rd .~1] [~.rd .~2]]
            [~.rd .~2]
    ::  max(.~1, .~1) = .~1  (equal)
    :-  %max-lit-rd-equal
        :-  [%max [~.rd .~1] [~.rd .~1]]
            [~.rd .~1]
    ::  max(-3, --2) = --2
    :-  %max-lit-sd-neg-pos
        :-  [%max [~.sd -3] [~.sd --2]]
            [~.sd --2]
    ::  max(--2, -3) = --2
    :-  %max-lit-sd-pos-neg
        :-  [%max [~.sd --2] [~.sd -3]]
            [~.sd --2]
    ::  max(-3, -1) = -1  (both negative)
    :-  %max-lit-sd-neg-neg
        :-  [%max [~.sd -3] [~.sd -1]]
            [~.sd -1]
    ::  max(--1, --2) = --2  (both positive)
    :-  %max-lit-sd-pos-pos
        :-  [%max [~.sd --1] [~.sd --2]]
            [~.sd --2]
    ::  max(--1, --1) = --1  (equal)
    :-  %max-lit-sd-equal
        :-  [%max [~.sd --1] [~.sd --1]]
            [~.sd --1]
    ::  max(2, 5) = 5
    :-  %max-lit-ud-small-large
        :-  [%max [~.ud 2] [~.ud 5]]
            [~.ud 5]
    ::  max(5, 2) = 5
    :-  %max-lit-ud-large-small
        :-  [%max [~.ud 5] [~.ud 2]]
            [~.ud 5]
    ::  max(3, 3) = 3  (equal)
    :-  %max-lit-ud-equal
        :-  [%max [~.ud 3] [~.ud 3]]
            [~.ud 3]
    ::  column / literal and column / column
    ::  max(col1=.~-3, .~2) = .~2
    :-  %max-qual-rd-col-lit
        :-  [%max minmax-q-col-1 [~.rd .~2]]
            [~.rd .~2]
    ::  max(.~2, col1=.~-3) = .~2
    :-  %max-qual-rd-lit-col
        :-  [%max [~.rd .~2] minmax-q-col-1]
            [~.rd .~2]
    ::  max(col1=.~-3, col2=.~2) = .~2
    :-  %max-qual-rd-col-col
        :-  [%max minmax-q-col-1 minmax-q-col-2]
            [~.rd .~2]
    ::  max(col1=.~-3, col1=.~-3) = .~-3  (equal)
    :-  %max-qual-rd-equal
        :-  [%max minmax-q-col-1 minmax-q-col-1]
            [~.rd .~-3]
    ::  max(col3=-3, --2) = --2
    :-  %max-qual-sd-col-lit
        :-  [%max minmax-q-col-3 [~.sd --2]]
            [~.sd --2]
    ::  max(--2, col3=-3) = --2
    :-  %max-qual-sd-lit-col
        :-  [%max [~.sd --2] minmax-q-col-3]
            [~.sd --2]
    ::  max(col3=-3, col4=--2) = --2
    :-  %max-qual-sd-col-col
        :-  [%max minmax-q-col-3 minmax-q-col-4]
            [~.sd --2]
    ::  max(col3=-3, col3=-3) = -3  (equal)
    :-  %max-qual-sd-equal
        :-  [%max minmax-q-col-3 minmax-q-col-3]
            [~.sd -3]
    ::  max(col5=2, 5) = 5
    :-  %max-qual-ud-col-lit
        :-  [%max minmax-q-col-5 [~.ud 5]]
            [~.ud 5]
    ::  max(5, col5=2) = 5
    :-  %max-qual-ud-lit-col
        :-  [%max [~.ud 5] minmax-q-col-5]
            [~.ud 5]
    ::  max(col5=2, col6=5) = 5
    :-  %max-qual-ud-col-col
        :-  [%max minmax-q-col-5 minmax-q-col-6]
            [~.ud 5]
    ::  max(col5=2, col5=2) = 2  (equal)
    :-  %max-qual-ud-equal
        :-  [%max minmax-q-col-5 minmax-q-col-5]
            [~.ud 2]
  ==
  ==
::
++  test-max-unqual
  %:  run-scalar-tests
    table-named-ctes
    minmax-unqual-lookup
    minmax-unqual-map-meta
    *(map @tas resolved-scalar)
    minmax-unqual-table-row
    :~
    ::  max(col1=.~-3, .~2) = .~2
    :-  %max-unqual-rd-col-lit
        :-  [%max minmax-u-col-1 [~.rd .~2]]
            [~.rd .~2]
    ::  max(.~2, col1=.~-3) = .~2
    :-  %max-unqual-rd-lit-col
        :-  [%max [~.rd .~2] minmax-u-col-1]
            [~.rd .~2]
    ::  max(col1=.~-3, col2=.~2) = .~2
    :-  %max-unqual-rd-col-col
        :-  [%max minmax-u-col-1 minmax-u-col-2]
            [~.rd .~2]
    ::  max(col1=.~-3, col1=.~-3) = .~-3  (equal)
    :-  %max-unqual-rd-equal
        :-  [%max minmax-u-col-1 minmax-u-col-1]
            [~.rd .~-3]
    ::  max(col3=-3, --2) = --2
    :-  %max-unqual-sd-col-lit
        :-  [%max minmax-u-col-3 [~.sd --2]]
            [~.sd --2]
    ::  max(--2, col3=-3) = --2
    :-  %max-unqual-sd-lit-col
        :-  [%max [~.sd --2] minmax-u-col-3]
            [~.sd --2]
    ::  max(col3=-3, col4=--2) = --2
    :-  %max-unqual-sd-col-col
        :-  [%max minmax-u-col-3 minmax-u-col-4]
            [~.sd --2]
    ::  max(col3=-3, col3=-3) = -3  (equal)
    :-  %max-unqual-sd-equal
        :-  [%max minmax-u-col-3 minmax-u-col-3]
            [~.sd -3]
    ::  max(col5=2, 5) = 5
    :-  %max-unqual-ud-col-lit
        :-  [%max minmax-u-col-5 [~.ud 5]]
            [~.ud 5]
    ::  max(5, col5=2) = 5
    :-  %max-unqual-ud-lit-col
        :-  [%max [~.ud 5] minmax-u-col-5]
            [~.ud 5]
    ::  max(col5=2, col6=5) = 5
    :-  %max-unqual-ud-col-col
        :-  [%max minmax-u-col-5 minmax-u-col-6]
            [~.ud 5]
    ::  max(col5=2, col5=2) = 2  (equal)
    :-  %max-unqual-ud-equal
        :-  [%max minmax-u-col-5 minmax-u-col-5]
            [~.ud 2]
  ==
  ==
::
::  %min tests
::
++  test-min-qual
  %:  run-scalar-tests
    table-named-ctes
    qual-lookup
    minmax-qual-map-meta
    *(map @tas resolved-scalar)
    minmax-qual-table-row
    :~
    ::  literal / literal
    ::  min(.~-3, .~2) = .~-3
    :-  %min-lit-rd-neg-pos
        :-  [%min [~.rd .~-3] [~.rd .~2]]
            [~.rd .~-3]
    ::  min(.~2, .~-3) = .~-3
    :-  %min-lit-rd-pos-neg
        :-  [%min [~.rd .~2] [~.rd .~-3]]
            [~.rd .~-3]
    ::  min(.~-3, .~-1) = .~-3  (both negative)
    :-  %min-lit-rd-neg-neg
        :-  [%min [~.rd .~-3] [~.rd .~-1]]
            [~.rd .~-3]
    ::  min(.~1, .~2) = .~1  (both positive)
    :-  %min-lit-rd-pos-pos
        :-  [%min [~.rd .~1] [~.rd .~2]]
            [~.rd .~1]
    ::  min(.~1, .~1) = .~1  (equal)
    :-  %min-lit-rd-equal
        :-  [%min [~.rd .~1] [~.rd .~1]]
            [~.rd .~1]
    ::  min(-3, --2) = -3
    :-  %min-lit-sd-neg-pos
        :-  [%min [~.sd -3] [~.sd --2]]
            [~.sd -3]
    ::  min(--2, -3) = -3
    :-  %min-lit-sd-pos-neg
        :-  [%min [~.sd --2] [~.sd -3]]
            [~.sd -3]
    ::  min(-3, -1) = -3  (both negative)
    :-  %min-lit-sd-neg-neg
        :-  [%min [~.sd -3] [~.sd -1]]
            [~.sd -3]
    ::  min(--1, --2) = --1  (both positive)
    :-  %min-lit-sd-pos-pos
        :-  [%min [~.sd --1] [~.sd --2]]
            [~.sd --1]
    ::  min(--1, --1) = --1  (equal)
    :-  %min-lit-sd-equal
        :-  [%min [~.sd --1] [~.sd --1]]
            [~.sd --1]
    ::  min(2, 5) = 2
    :-  %min-lit-ud-small-large
        :-  [%min [~.ud 2] [~.ud 5]]
            [~.ud 2]
    ::  min(5, 2) = 2
    :-  %min-lit-ud-large-small
        :-  [%min [~.ud 5] [~.ud 2]]
            [~.ud 2]
    ::  min(3, 3) = 3  (equal)
    :-  %min-lit-ud-equal
        :-  [%min [~.ud 3] [~.ud 3]]
            [~.ud 3]
    ::  column / literal and column / column
    ::  min(col1=.~-3, .~2) = .~-3
    :-  %min-qual-rd-col-lit
        :-  [%min minmax-q-col-1 [~.rd .~2]]
            [~.rd .~-3]
    ::  min(.~2, col1=.~-3) = .~-3
    :-  %min-qual-rd-lit-col
        :-  [%min [~.rd .~2] minmax-q-col-1]
            [~.rd .~-3]
    ::  min(col1=.~-3, col2=.~2) = .~-3
    :-  %min-qual-rd-col-col
        :-  [%min minmax-q-col-1 minmax-q-col-2]
            [~.rd .~-3]
    ::  min(col1=.~-3, col1=.~-3) = .~-3  (equal)
    :-  %min-qual-rd-equal
        :-  [%min minmax-q-col-1 minmax-q-col-1]
            [~.rd .~-3]
    ::  min(col3=-3, --2) = -3
    :-  %min-qual-sd-col-lit
        :-  [%min minmax-q-col-3 [~.sd --2]]
            [~.sd -3]
    ::  min(--2, col3=-3) = -3
    :-  %min-qual-sd-lit-col
        :-  [%min [~.sd --2] minmax-q-col-3]
            [~.sd -3]
    ::  min(col3=-3, col4=--2) = -3
    :-  %min-qual-sd-col-col
        :-  [%min minmax-q-col-3 minmax-q-col-4]
            [~.sd -3]
    ::  min(col3=-3, col3=-3) = -3  (equal)
    :-  %min-qual-sd-equal
        :-  [%min minmax-q-col-3 minmax-q-col-3]
            [~.sd -3]
    ::  min(col5=2, 5) = 2
    :-  %min-qual-ud-col-lit
        :-  [%min minmax-q-col-5 [~.ud 5]]
            [~.ud 2]
    ::  min(5, col5=2) = 2
    :-  %min-qual-ud-lit-col
        :-  [%min [~.ud 5] minmax-q-col-5]
            [~.ud 2]
    ::  min(col5=2, col6=5) = 2
    :-  %min-qual-ud-col-col
        :-  [%min minmax-q-col-5 minmax-q-col-6]
            [~.ud 2]
    ::  min(col5=2, col5=2) = 2  (equal)
    :-  %min-qual-ud-equal
        :-  [%min minmax-q-col-5 minmax-q-col-5]
            [~.ud 2]
  ==
  ==
::
++  test-min-unqual
  %:  run-scalar-tests
    table-named-ctes
    minmax-unqual-lookup
    minmax-unqual-map-meta
    *(map @tas resolved-scalar)
    minmax-unqual-table-row
    :~
    ::  min(col1=.~-3, .~2) = .~-3
    :-  %min-unqual-rd-col-lit
        :-  [%min minmax-u-col-1 [~.rd .~2]]
            [~.rd .~-3]
    ::  min(.~2, col1=.~-3) = .~-3
    :-  %min-unqual-rd-lit-col
        :-  [%min [~.rd .~2] minmax-u-col-1]
            [~.rd .~-3]
    ::  min(col1=.~-3, col2=.~2) = .~-3
    :-  %min-unqual-rd-col-col
        :-  [%min minmax-u-col-1 minmax-u-col-2]
            [~.rd .~-3]
    ::  min(col1=.~-3, col1=.~-3) = .~-3  (equal)
    :-  %min-unqual-rd-equal
        :-  [%min minmax-u-col-1 minmax-u-col-1]
            [~.rd .~-3]
    ::  min(col3=-3, --2) = -3
    :-  %min-unqual-sd-col-lit
        :-  [%min minmax-u-col-3 [~.sd --2]]
            [~.sd -3]
    ::  min(--2, col3=-3) = -3
    :-  %min-unqual-sd-lit-col
        :-  [%min [~.sd --2] minmax-u-col-3]
            [~.sd -3]
    ::  min(col3=-3, col4=--2) = -3
    :-  %min-unqual-sd-col-col
        :-  [%min minmax-u-col-3 minmax-u-col-4]
            [~.sd -3]
    ::  min(col3=-3, col3=-3) = -3  (equal)
    :-  %min-unqual-sd-equal
        :-  [%min minmax-u-col-3 minmax-u-col-3]
            [~.sd -3]
    ::  min(col5=2, 5) = 2
    :-  %min-unqual-ud-col-lit
        :-  [%min minmax-u-col-5 [~.ud 5]]
            [~.ud 2]
    ::  min(5, col5=2) = 2
    :-  %min-unqual-ud-lit-col
        :-  [%min [~.ud 5] minmax-u-col-5]
            [~.ud 2]
    ::  min(col5=2, col6=5) = 2
    :-  %min-unqual-ud-col-col
        :-  [%min minmax-u-col-5 minmax-u-col-6]
            [~.ud 2]
    ::  min(col5=2, col5=2) = 2  (equal)
    :-  %min-unqual-ud-equal
        :-  [%min minmax-u-col-5 minmax-u-col-5]
            [~.ud 2]
  ==
  ==
::
::  %log tests
::
++  test-log-qual
  %:  run-scalar-tests
    table-named-ctes
    qual-lookup
    log-qual-map-meta
    *(map @tas resolved-scalar)
    log-qual-table-row
    :~
    ::  literals: @rd
    ::  log(1.0) = 0.0
    :-  %log-lit-rd-1
        :-  [%log [~.rd .~1] ~]
            [~.rd .~0]
    ::  log(2.0) = 0.6931471805589156
    :-  %log-lit-rd-2
        :-  [%log [~.rd .~2] ~]
            [~.rd 4.604.418.534.313.441.763]
    ::  log(0.12) = -2.1202635359958357
    :-  %log-lit-rd-0-12
        :-  [%log [~.rd .~0.12] ~]
            [~.rd 13.835.328.864.690.572.176]
    ::  log(0.1) = -2.302585092782879
    :-  %log-lit-rd-0-1
        :-  [%log [~.rd .~0.1] ~]
            [~.rd 13.835.739.416.338.191.600]
    ::  log(0.2) = -1.6094379123624005
    :-  %log-lit-rd-0-2
        :-  [%log [~.rd .~0.2] ~]
            [~.rd 13.833.299.120.010.136.851]
    ::  log(2.2) = 0.7884573603622065
    :-  %log-lit-rd-2-2
        :-  [%log [~.rd .~2.2] ~]
            [~.rd 4.605.277.012.093.944.509]
    ::  log(100.0) = 4.605170181454591
    :-  %log-lit-rd-100
        :-  [%log [~.rd .~100] ~]
            [~.rd 4.616.870.979.110.785.924]
    ::  literals: @sd (positive integers only)
    ::  log(--1) = 0.0
    :-  %log-lit-sd-1
        :-  [%log [~.sd --1] ~]
            [~.rd .~0]
    ::  log(--2) = 0.6931471805589156
    :-  %log-lit-sd-2
        :-  [%log [~.sd --2] ~]
            [~.rd 4.604.418.534.313.441.763]
    ::  log(--100) = 4.605170181454591
    :-  %log-lit-sd-100
        :-  [%log [~.sd --100] ~]
            [~.rd 4.616.870.979.110.785.924]
    ::  literals: @ud
    ::  log(1) = 0.0
    :-  %log-lit-ud-1
        :-  [%log [~.ud 1] ~]
            [~.rd .~0]
    ::  log(2) = 0.6931471805589156
    :-  %log-lit-ud-2
        :-  [%log [~.ud 2] ~]
            [~.rd 4.604.418.534.313.441.763]
    ::  log(100) = 4.605170181454591
    :-  %log-lit-ud-100
        :-  [%log [~.ud 100] ~]
            [~.rd 4.616.870.979.110.785.924]
    ::  qualified columns: @rd
    ::  log(col1=.~1) = 0.0
    :-  %log-qual-rd-1
        :-  [%log log-q-col-1 ~]
            [~.rd .~0]
    ::  log(col2=.~2) = 0.6931471805589156
    :-  %log-qual-rd-2
        :-  [%log log-q-col-2 ~]
            [~.rd 4.604.418.534.313.441.763]
    ::  log(col3=.~0.1) = -2.302585092782879
    :-  %log-qual-rd-0-1
        :-  [%log log-q-col-3 ~]
            [~.rd 13.835.739.416.338.191.600]
    ::  qualified columns: @sd
    ::  log(col4=--1) = 0.0
    :-  %log-qual-sd-1
        :-  [%log log-q-col-4 ~]
            [~.rd .~0]
    ::  log(col5=--2) = 0.6931471805589156
    :-  %log-qual-sd-2
        :-  [%log log-q-col-5 ~]
            [~.rd 4.604.418.534.313.441.763]
    ::  log(col6=--100) = 4.605170181454591
    :-  %log-qual-sd-100
        :-  [%log log-q-col-6 ~]
            [~.rd 4.616.870.979.110.785.924]
    ::  qualified columns: @ud
    ::  log(col7=1) = 0.0
    :-  %log-qual-ud-1
        :-  [%log log-q-col-7 ~]
            [~.rd .~0]
    ::  log(col8=2) = 0.6931471805589156
    :-  %log-qual-ud-2
        :-  [%log log-q-col-8 ~]
            [~.rd 4.604.418.534.313.441.763]
    ::  log(col9=100) = 4.605170181454591
    :-  %log-qual-ud-100
        :-  [%log log-q-col-9 ~]
            [~.rd 4.616.870.979.110.785.924]
  ==
  ==
::
++  test-log-unqual
  %:  run-scalar-tests
    table-named-ctes
    log-unqual-lookup
    log-unqual-map-meta
    *(map @tas resolved-scalar)
    log-unqual-table-row
    :~
    ::  unqualified columns: @rd
    ::  log(col1=.~1) = 0.0
    :-  %log-unqual-rd-1
        :-  [%log log-u-col-1 ~]
            [~.rd .~0]
    ::  log(col2=.~2) = 0.6931471805589156
    :-  %log-unqual-rd-2
        :-  [%log log-u-col-2 ~]
            [~.rd 4.604.418.534.313.441.763]
    ::  log(col3=.~0.1) = -2.302585092782879
    :-  %log-unqual-rd-0-1
        :-  [%log log-u-col-3 ~]
            [~.rd 13.835.739.416.338.191.600]
    ::  unqualified columns: @sd
    ::  log(col4=--1) = 0.0
    :-  %log-unqual-sd-1
        :-  [%log log-u-col-4 ~]
            [~.rd .~0]
    ::  log(col5=--2) = 0.6931471805589156
    :-  %log-unqual-sd-2
        :-  [%log log-u-col-5 ~]
            [~.rd 4.604.418.534.313.441.763]
    ::  log(col6=--100) = 4.605170181454591
    :-  %log-unqual-sd-100
        :-  [%log log-u-col-6 ~]
            [~.rd 4.616.870.979.110.785.924]
    ::  unqualified columns: @ud
    ::  log(col7=1) = 0.0
    :-  %log-unqual-ud-1
        :-  [%log log-u-col-7 ~]
            [~.rd .~0]
    ::  log(col8=2) = 0.6931471805589156
    :-  %log-unqual-ud-2
        :-  [%log log-u-col-8 ~]
            [~.rd 4.604.418.534.313.441.763]
    ::  log(col9=100) = 4.605170181454591
    :-  %log-unqual-ud-100
        :-  [%log log-u-col-9 ~]
            [~.rd 4.616.870.979.110.785.924]
  ==
  ==
::
++  test-sin-qual
  %:  run-scalar-tests
    table-named-ctes
    qual-lookup
    sin-qual-map-meta
    *(map @tas resolved-scalar)
    sin-qual-table-row
    :~
    ::  literals: @rd
    ::  sin(0.0) = 0.0
    :-  %sin-lit-rd-0
        :-  [%sin [~.rd .~0]]
            [~.rd .~0]
    ::  sin(0.2) = 0.1986693307950617
    :-  %sin-lit-rd-0-2
        :-  [%sin [~.rd .~0.2]]
            [~.rd .~0.19866933079506116]
    ::  sin(1.0) = 0.8414709848078934
    :-  %sin-lit-rd-1
        :-  [%sin [~.rd .~1]]
            [~.rd .~0.84147098480789606]
    ::  sin(-0.2) = 0.02278564266428059
    :-  %sin-lit-rd-neg-0-2
        :-  [%sin [~.rd .~-0.2]]
            [~.rd .~0.022785642664279956]
    ::  sin(-1.0) = 0.11588947232451653
    :-  %sin-lit-rd-neg-1
        :-  [%sin [~.rd .~-1]]
            [~.rd .~0.11588947232452712]
    ::  literals: @sd
    ::  sin(--0) = 0.0
    :-  %sin-lit-sd-0
        :-  [%sin [~.sd --0]]
            [~.rd .~0]
    ::  sin(--1) = 0.8414709848078934
    :-  %sin-lit-sd-1
        :-  [%sin [~.sd --1]]
            [~.rd .~0.84147098480789606]
    ::  sin(-1) = 0.11588947232451653
    :-  %sin-lit-sd-neg-1
        :-  [%sin [~.sd -1]]
            [~.rd .~0.11588947232452712]
    ::  literals: @ud
    ::  sin(0) = 0.0
    :-  %sin-lit-ud-0
        :-  [%sin [~.ud 0]]
            [~.rd .~0]
    ::  sin(1) = 0.8414709848078934
    :-  %sin-lit-ud-1
        :-  [%sin [~.ud 1]]
            [~.rd .~0.84147098480789606]
    ::  sin(2) = 0.9092974268256406
    :-  %sin-lit-ud-2
        :-  [%sin [~.ud 2]]
            [~.rd .~0.90929742682568127]
    ::  qualified columns: @rd
    ::  sin(col1=.~0.2) = 0.1986693307950617
    :-  %sin-qual-rd-0-2
        :-  [%sin sin-q-col-1]
            [~.rd .~0.19866933079506116]
    ::  sin(col2=.~1) = 0.8414709848078934
    :-  %sin-qual-rd-1
        :-  [%sin sin-q-col-2]
            [~.rd .~0.84147098480789606]
    ::  sin(col3=.~-0.2) = 0.02278564266428059
    :-  %sin-qual-rd-neg-0-2
        :-  [%sin sin-q-col-3]
            [~.rd .~0.022785642664279956]
    ::  qualified columns: @sd
    ::  sin(col4=--0) = 0.0
    :-  %sin-qual-sd-0
        :-  [%sin sin-q-col-4]
            [~.rd .~0]
    ::  sin(col5=--1) = 0.8414709848078934
    :-  %sin-qual-sd-1
        :-  [%sin sin-q-col-5]
            [~.rd .~0.84147098480789606]
    ::  sin(col6=-1) = 0.11588947232451653
    :-  %sin-qual-sd-neg-1
        :-  [%sin sin-q-col-6]
            [~.rd .~0.11588947232452712]
    ::  qualified columns: @ud
    ::  sin(col7=0) = 0.0
    :-  %sin-qual-ud-0
        :-  [%sin sin-q-col-7]
            [~.rd .~0]
    ::  sin(col8=1) = 0.8414709848078934
    :-  %sin-qual-ud-1
        :-  [%sin sin-q-col-8]
            [~.rd .~0.84147098480789606]
    ::  sin(col9=2) = 0.9092974268256406
    :-  %sin-qual-ud-2
        :-  [%sin sin-q-col-9]
            [~.rd .~0.90929742682568127]
  ==
  ==
::
++  test-sin-unqual
  %:  run-scalar-tests
    table-named-ctes
    sin-unqual-lookup
    sin-unqual-map-meta
    *(map @tas resolved-scalar)
    sin-unqual-table-row
    :~
    ::  unqualified columns: @rd
    ::  sin(col1=.~0.2) = 0.1986693307950617
    :-  %sin-unqual-rd-0-2
        :-  [%sin sin-u-col-1]
            [~.rd .~0.19866933079506116]
    ::  sin(col2=.~1) = 0.8414709848078934
    :-  %sin-unqual-rd-1
        :-  [%sin sin-u-col-2]
            [~.rd .~0.84147098480789606]
    ::  sin(col3=.~-0.2) = 0.02278564266428059
    :-  %sin-unqual-rd-neg-0-2
        :-  [%sin sin-u-col-3]
            [~.rd .~0.022785642664279956]
    ::  unqualified columns: @sd
    ::  sin(col4=--0) = 0.0
    :-  %sin-unqual-sd-0
        :-  [%sin sin-u-col-4]
            [~.rd .~0]
    ::  sin(col5=--1) = 0.8414709848078934
    :-  %sin-unqual-sd-1
        :-  [%sin sin-u-col-5]
            [~.rd .~0.84147098480789606]
    ::  sin(col6=-1) = 0.11588947232451653
    :-  %sin-unqual-sd-neg-1
        :-  [%sin sin-u-col-6]
            [~.rd .~0.11588947232452712]
    ::  unqualified columns: @ud
    ::  sin(col7=0) = 0.0
    :-  %sin-unqual-ud-0
        :-  [%sin sin-u-col-7]
            [~.rd .~0]
    ::  sin(col8=1) = 0.8414709848078934
    :-  %sin-unqual-ud-1
        :-  [%sin sin-u-col-8]
            [~.rd .~0.84147098480789606]
    ::  sin(col9=2) = 0.9092974268256406
    :-  %sin-unqual-ud-2
        :-  [%sin sin-u-col-9]
            [~.rd .~0.90929742682568127]
  ==
  ==
::
++  test-cos-qual
  %:  run-scalar-tests
    table-named-ctes
    qual-lookup
    cos-qual-map-meta
    *(map @tas resolved-scalar)
    cos-qual-table-row
    :~
    ::  literals: @rd
    ::  cos(0.0) = 1.0
    :-  %cos-lit-rd-0
        :-  [%cos [~.rd .~0]]
            [~.rd .~1]
    ::  cos(1.0) = 0.5403023058680917
    :-  %cos-lit-rd-1
        :-  [%cos [~.rd .~1]]
            [~.rd .~0.54030230586813921]
    ::  cos(1.56) = 0.010796117058732157
    :-  %cos-lit-rd-1-56
        :-  [%cos [~.rd .~1.56]]
            [~.rd .~0.010796117058267505]
    ::  cos(-1.0) = 0.9932621155587997
    :-  %cos-lit-rd-neg-1
        :-  [%cos [~.rd .~-1]]
            [~.rd .~0.99326211555879951]
    ::  cos(-1.56) = 0.9843233239774423
    :-  %cos-lit-rd-neg-1-56
        :-  [%cos [~.rd .~-1.56]]
            [~.rd .~0.98432332397743372]
    ::  literals: @sd
    ::  cos(--0) = 1.0
    :-  %cos-lit-sd-0
        :-  [%cos [~.sd --0]]
            [~.rd .~1]
    ::  cos(--1) = 0.5403023058680917
    :-  %cos-lit-sd-1
        :-  [%cos [~.sd --1]]
            [~.rd .~0.54030230586813921]
    ::  cos(-1) = 0.9932621155587997
    :-  %cos-lit-sd-neg-1
        :-  [%cos [~.sd -1]]
            [~.rd .~0.99326211555879951]
    ::  literals: @ud
    ::  cos(0) = 1.0
    :-  %cos-lit-ud-0
        :-  [%cos [~.ud 0]]
            [~.rd .~1]
    ::  cos(1) = 0.5403023058680917
    :-  %cos-lit-ud-1
        :-  [%cos [~.ud 1]]
            [~.rd .~0.54030230586813921]
    ::  cos(2) = -0.41614683654756957
    :-  %cos-lit-ud-2
        :-  [%cos [~.ud 2]]
            [~.rd .~-0.41614683654714218]
    ::  qualified columns: @rd
    ::  cos(col1=.~1) = 0.5403023058680917
    :-  %cos-qual-rd-1
        :-  [%cos cos-q-col-1]
            [~.rd .~0.54030230586813921]
    ::  cos(col2=.~1.56) = 0.010796117058732157
    :-  %cos-qual-rd-1-56
        :-  [%cos cos-q-col-2]
            [~.rd .~0.010796117058267505]
    ::  cos(col3=.~-1) = 0.9932621155587997
    :-  %cos-qual-rd-neg-1
        :-  [%cos cos-q-col-3]
            [~.rd .~0.99326211555879951]
    ::  qualified columns: @sd
    ::  cos(col4=--0) = 1.0
    :-  %cos-qual-sd-0
        :-  [%cos cos-q-col-4]
            [~.rd .~1]
    ::  cos(col5=--1) = 0.5403023058680917
    :-  %cos-qual-sd-1
        :-  [%cos cos-q-col-5]
            [~.rd .~0.54030230586813921]
    ::  cos(col6=-1) = 0.9932621155587997
    :-  %cos-qual-sd-neg-1
        :-  [%cos cos-q-col-6]
            [~.rd .~0.99326211555879951]
    ::  qualified columns: @ud
    ::  cos(col7=0) = 1.0
    :-  %cos-qual-ud-0
        :-  [%cos cos-q-col-7]
            [~.rd .~1]
    ::  cos(col8=1) = 0.5403023058680917
    :-  %cos-qual-ud-1
        :-  [%cos cos-q-col-8]
            [~.rd .~0.54030230586813921]
    ::  cos(col9=2) = -0.41614683654756957
    :-  %cos-qual-ud-2
        :-  [%cos cos-q-col-9]
            [~.rd .~-0.41614683654714218]
  ==
  ==
::
++  test-cos-unqual
  %:  run-scalar-tests
    table-named-ctes
    cos-unqual-lookup
    cos-unqual-map-meta
    *(map @tas resolved-scalar)
    cos-unqual-table-row
    :~
    ::  unqualified columns: @rd
    ::  cos(col1=.~1) = 0.5403023058680917
    :-  %cos-unqual-rd-1
        :-  [%cos cos-u-col-1]
            [~.rd .~0.54030230586813921]
    ::  cos(col2=.~1.56) = 0.010796117058732157
    :-  %cos-unqual-rd-1-56
        :-  [%cos cos-u-col-2]
            [~.rd .~0.010796117058267505]
    ::  cos(col3=.~-1) = 0.9932621155587997
    :-  %cos-unqual-rd-neg-1
        :-  [%cos cos-u-col-3]
            [~.rd .~0.99326211555879951]
    ::  unqualified columns: @sd
    ::  cos(col4=--0) = 1.0
    :-  %cos-unqual-sd-0
        :-  [%cos cos-u-col-4]
            [~.rd .~1]
    ::  cos(col5=--1) = 0.5403023058680917
    :-  %cos-unqual-sd-1
        :-  [%cos cos-u-col-5]
            [~.rd .~0.54030230586813921]
    ::  cos(col6=-1) = 0.9932621155587997
    :-  %cos-unqual-sd-neg-1
        :-  [%cos cos-u-col-6]
            [~.rd .~0.99326211555879951]
    ::  unqualified columns: @ud
    ::  cos(col7=0) = 1.0
    :-  %cos-unqual-ud-0
        :-  [%cos cos-u-col-7]
            [~.rd .~1]
    ::  cos(col8=1) = 0.5403023058680917
    :-  %cos-unqual-ud-1
        :-  [%cos cos-u-col-8]
            [~.rd .~0.54030230586813921]
    ::  cos(col9=2) = -0.41614683654756957
    :-  %cos-unqual-ud-2
        :-  [%cos cos-u-col-9]
            [~.rd .~-0.41614683654714218]
  ==
  ==
::
++  test-tan-qual
  %:  run-scalar-tests
    table-named-ctes
    qual-lookup
    tan-qual-map-meta
    *(map @tas resolved-scalar)
    tan-qual-table-row
    :~
    ::  literals: @rd
    ::  tan(0.0) = 0.0
    :-  %tan-lit-rd-0
        :-  [%tan [~.rd .~0]]
            [~.rd .~0]
    ::  tan(1.0) = 1.5574077246550349
    :-  %tan-lit-rd-1
        :-  [%tan [~.rd .~1]]
            [~.rd .~1.5574077246549027]
    ::  tan(-1.0) = 0.11667561916354599
    :-  %tan-lit-rd-neg-1
        :-  [%tan [~.rd .~-1]]
            [~.rd .~0.11667561916355668]
    ::  literals: @sd
    ::  tan(--0) = 0.0
    :-  %tan-lit-sd-0
        :-  [%tan [~.sd --0]]
            [~.rd .~0]
    ::  tan(--1) = 1.5574077246550349
    :-  %tan-lit-sd-1
        :-  [%tan [~.sd --1]]
            [~.rd .~1.5574077246549027]
    ::  tan(-1) = 0.11667561916354599
    :-  %tan-lit-sd-neg-1
        :-  [%tan [~.sd -1]]
            [~.rd .~0.11667561916355668]
    ::  literals: @ud
    ::  tan(0) = 0.0
    :-  %tan-lit-ud-0
        :-  [%tan [~.ud 0]]
            [~.rd .~0]
    ::  tan(1) = 1.5574077246550349
    :-  %tan-lit-ud-1
        :-  [%tan [~.ud 1]]
            [~.rd .~1.5574077246549027]
    ::  tan(2) = -2.1850398632615189
    :-  %tan-lit-ud-2
        :-  [%tan [~.ud 2]]
            [~.rd .~-2.1850398632615189]
    ::  qualified columns: @rd
    ::  tan(col1=.~1) = 1.5574077246550349
    :-  %tan-qual-rd-1
        :-  [%tan tan-q-col-1]
            [~.rd .~1.5574077246549027]
    ::  tan(col2=.~0) = 0.0
    :-  %tan-qual-rd-0
        :-  [%tan tan-q-col-2]
            [~.rd .~0]
    ::  tan(col3=.~-1) = 0.11667561916354599
    :-  %tan-qual-rd-neg-1
        :-  [%tan tan-q-col-3]
            [~.rd .~0.11667561916355668]
    ::  qualified columns: @sd
    ::  tan(col4=--0) = 0.0
    :-  %tan-qual-sd-0
        :-  [%tan tan-q-col-4]
            [~.rd .~0]
    ::  tan(col5=--1) = 1.5574077246550349
    :-  %tan-qual-sd-1
        :-  [%tan tan-q-col-5]
            [~.rd .~1.5574077246549027]
    ::  tan(col6=-1) = 0.11667561916354599
    :-  %tan-qual-sd-neg-1
        :-  [%tan tan-q-col-6]
            [~.rd .~0.11667561916355668]
    ::  qualified columns: @ud
    ::  tan(col7=0) = 0.0
    :-  %tan-qual-ud-0
        :-  [%tan tan-q-col-7]
            [~.rd .~0]
    ::  tan(col8=1) = 1.5574077246550349
    :-  %tan-qual-ud-1
        :-  [%tan tan-q-col-8]
            [~.rd .~1.5574077246549027]
    ::  tan(col9=2) = -2.1850398632615189
    :-  %tan-qual-ud-2
        :-  [%tan tan-q-col-9]
            [~.rd .~-2.1850398632615189]
  ==
  ==
::
++  test-tan-unqual
  %:  run-scalar-tests
    table-named-ctes
    tan-unqual-lookup
    tan-unqual-map-meta
    *(map @tas resolved-scalar)
    tan-unqual-table-row
    :~
    ::  unqualified columns: @rd
    ::  tan(col1=.~1) = 1.5574077246550349
    :-  %tan-unqual-rd-1
        :-  [%tan tan-u-col-1]
            [~.rd .~1.5574077246549027]
    ::  tan(col2=.~0) = 0.0
    :-  %tan-unqual-rd-0
        :-  [%tan tan-u-col-2]
            [~.rd .~0]
    ::  tan(col3=.~-1) = 0.11667561916354599
    :-  %tan-unqual-rd-neg-1
        :-  [%tan tan-u-col-3]
            [~.rd .~0.11667561916355668]
    ::  unqualified columns: @sd
    ::  tan(col4=--0) = 0.0
    :-  %tan-unqual-sd-0
        :-  [%tan tan-u-col-4]
            [~.rd .~0]
    ::  tan(col5=--1) = 1.5574077246550349
    :-  %tan-unqual-sd-1
        :-  [%tan tan-u-col-5]
            [~.rd .~1.5574077246549027]
    ::  tan(col6=-1) = 0.11667561916354599
    :-  %tan-unqual-sd-neg-1
        :-  [%tan tan-u-col-6]
            [~.rd .~0.11667561916355668]
    ::  unqualified columns: @ud
    ::  tan(col7=0) = 0.0
    :-  %tan-unqual-ud-0
        :-  [%tan tan-u-col-7]
            [~.rd .~0]
    ::  tan(col8=1) = 1.5574077246550349
    :-  %tan-unqual-ud-1
        :-  [%tan tan-u-col-8]
            [~.rd .~1.5574077246549027]
    ::  tan(col9=2) = -2.1850398632615189
    :-  %tan-unqual-ud-2
        :-  [%tan tan-u-col-9]
            [~.rd .~-2.1850398632615189]
  ==
  ==
::
++  test-asin-qual
  %:  run-scalar-tests
    table-named-ctes
    qual-lookup
    asin-qual-map-meta
    *(map @tas resolved-scalar)
    asin-qual-table-row
    :~
    ::  literals: @rd
    ::  asin(1.0) = 1.5707963267948966
    :-  %asin-lit-rd-1
        :-  [%asin [~.rd .~1]]
            [~.rd .~1.5707963267948966]
    ::  asin(0.0) = 0.0
    :-  %asin-lit-rd-0
        :-  [%asin [~.rd .~0]]
            [~.rd .~0]
    ::  asin(-1.0) = -1.5707963267948966
    :-  %asin-lit-rd-neg-1
        :-  [%asin [~.rd .~-1]]
            [~.rd .~-1.5707963267948966]
    ::  literals: @sd
    ::  asin(--0) = 0.0
    :-  %asin-lit-sd-0
        :-  [%asin [~.sd --0]]
            [~.rd .~0]
    ::  asin(--1) = 1.5707963267948966
    :-  %asin-lit-sd-1
        :-  [%asin [~.sd --1]]
            [~.rd .~1.5707963267948966]
    ::  asin(-1) = -1.5707963267948966
    :-  %asin-lit-sd-neg-1
        :-  [%asin [~.sd -1]]
            [~.rd .~-1.5707963267948966]
    ::  literals: @ud
    ::  asin(0) = 0.0
    :-  %asin-lit-ud-0
        :-  [%asin [~.ud 0]]
            [~.rd .~0]
    ::  asin(1) = 1.5707963267948966
    :-  %asin-lit-ud-1
        :-  [%asin [~.ud 1]]
            [~.rd .~1.5707963267948966]
    ::  qualified columns: @rd
    ::  asin(col1=.~1) = 1.5707963267948966
    :-  %asin-qual-rd-1
        :-  [%asin asin-q-col-1]
            [~.rd .~1.5707963267948966]
    ::  asin(col2=.~0) = 0.0
    :-  %asin-qual-rd-0
        :-  [%asin asin-q-col-2]
            [~.rd .~0]
    ::  asin(col3=.~-1) = -1.5707963267948966
    :-  %asin-qual-rd-neg-1
        :-  [%asin asin-q-col-3]
            [~.rd .~-1.5707963267948966]
    ::  qualified columns: @sd
    ::  asin(col4=--0) = 0.0
    :-  %asin-qual-sd-0
        :-  [%asin asin-q-col-4]
            [~.rd .~0]
    ::  asin(col5=--1) = 1.5707963267948966
    :-  %asin-qual-sd-1
        :-  [%asin asin-q-col-5]
            [~.rd .~1.5707963267948966]
    ::  asin(col6=-1) = -1.5707963267948966
    :-  %asin-qual-sd-neg-1
        :-  [%asin asin-q-col-6]
            [~.rd .~-1.5707963267948966]
    ::  qualified columns: @ud
    ::  asin(col7=0) = 0.0
    :-  %asin-qual-ud-0
        :-  [%asin asin-q-col-7]
            [~.rd .~0]
    ::  asin(col8=1) = 1.5707963267948966
    :-  %asin-qual-ud-1
        :-  [%asin asin-q-col-8]
            [~.rd .~1.5707963267948966]
  ==
  ==
::
++  test-asin-unqual
  %:  run-scalar-tests
    table-named-ctes
    asin-unqual-lookup
    asin-unqual-map-meta
    *(map @tas resolved-scalar)
    asin-unqual-table-row
    :~
    ::  unqualified columns: @rd
    ::  asin(col1=.~1) = 1.5707963267948966
    :-  %asin-unqual-rd-1
        :-  [%asin asin-u-col-1]
            [~.rd .~1.5707963267948966]
    ::  asin(col2=.~0) = 0.0
    :-  %asin-unqual-rd-0
        :-  [%asin asin-u-col-2]
            [~.rd .~0]
    ::  asin(col3=.~-1) = -1.5707963267948966
    :-  %asin-unqual-rd-neg-1
        :-  [%asin asin-u-col-3]
            [~.rd .~-1.5707963267948966]
    ::  unqualified columns: @sd
    ::  asin(col4=--0) = 0.0
    :-  %asin-unqual-sd-0
        :-  [%asin asin-u-col-4]
            [~.rd .~0]
    ::  asin(col5=--1) = 1.5707963267948966
    :-  %asin-unqual-sd-1
        :-  [%asin asin-u-col-5]
            [~.rd .~1.5707963267948966]
    ::  asin(col6=-1) = -1.5707963267948966
    :-  %asin-unqual-sd-neg-1
        :-  [%asin asin-u-col-6]
            [~.rd .~-1.5707963267948966]
    ::  unqualified columns: @ud
    ::  asin(col7=0) = 0.0
    :-  %asin-unqual-ud-0
        :-  [%asin asin-u-col-7]
            [~.rd .~0]
    ::  asin(col8=1) = 1.5707963267948966
    :-  %asin-unqual-ud-1
        :-  [%asin asin-u-col-8]
            [~.rd .~1.5707963267948966]
  ==
  ==
::
++  test-acos-qual
  %:  run-scalar-tests
    table-named-ctes
    qual-lookup
    acos-qual-map-meta
    *(map @tas resolved-scalar)
    acos-qual-table-row
    :~
    ::  literals: @rd
    ::  acos(1.0) = 0.0
    :-  %acos-lit-rd-1
        :-  [%acos [~.rd .~1]]
            [~.rd .~0]
    ::  acos(0.0) = 1.5707963267948966
    :-  %acos-lit-rd-0
        :-  [%acos [~.rd .~0]]
            [~.rd .~1.5707963267948966]
    ::  acos(-1.0) = 3.141592653589793
    :-  %acos-lit-rd-neg-1
        :-  [%acos [~.rd .~-1]]
            [~.rd .~3.141592653589793]
    ::  literals: @sd
    ::  acos(--0) = 1.5707963267948966
    :-  %acos-lit-sd-0
        :-  [%acos [~.sd --0]]
            [~.rd .~1.5707963267948966]
    ::  acos(--1) = 0.0
    :-  %acos-lit-sd-1
        :-  [%acos [~.sd --1]]
            [~.rd .~0]
    ::  acos(-1) = 3.141592653589793
    :-  %acos-lit-sd-neg-1
        :-  [%acos [~.sd -1]]
            [~.rd .~3.141592653589793]
    ::  literals: @ud
    ::  acos(0) = 1.5707963267948966
    :-  %acos-lit-ud-0
        :-  [%acos [~.ud 0]]
            [~.rd .~1.5707963267948966]
    ::  acos(1) = 0.0
    :-  %acos-lit-ud-1
        :-  [%acos [~.ud 1]]
            [~.rd .~0]
    ::  qualified columns: @rd
    ::  acos(col1=.~1) = 0.0
    :-  %acos-qual-rd-1
        :-  [%acos acos-q-col-1]
            [~.rd .~0]
    ::  acos(col2=.~0) = 1.5707963267948966
    :-  %acos-qual-rd-0
        :-  [%acos acos-q-col-2]
            [~.rd .~1.5707963267948966]
    ::  acos(col3=.~-1) = 3.141592653589793
    :-  %acos-qual-rd-neg-1
        :-  [%acos acos-q-col-3]
            [~.rd .~3.141592653589793]
    ::  qualified columns: @sd
    ::  acos(col4=--0) = 1.5707963267948966
    :-  %acos-qual-sd-0
        :-  [%acos acos-q-col-4]
            [~.rd .~1.5707963267948966]
    ::  acos(col5=--1) = 0.0
    :-  %acos-qual-sd-1
        :-  [%acos acos-q-col-5]
            [~.rd .~0]
    ::  acos(col6=-1) = 3.141592653589793
    :-  %acos-qual-sd-neg-1
        :-  [%acos acos-q-col-6]
            [~.rd .~3.141592653589793]
    ::  qualified columns: @ud
    ::  acos(col7=0) = 1.5707963267948966
    :-  %acos-qual-ud-0
        :-  [%acos acos-q-col-7]
            [~.rd .~1.5707963267948966]
    ::  acos(col8=1) = 0.0
    :-  %acos-qual-ud-1
        :-  [%acos acos-q-col-8]
            [~.rd .~0]
  ==
  ==
::
++  test-acos-unqual
  %:  run-scalar-tests
    table-named-ctes
    acos-unqual-lookup
    acos-unqual-map-meta
    *(map @tas resolved-scalar)
    acos-unqual-table-row
    :~
    ::  unqualified columns: @rd
    ::  acos(col1=.~1) = 0.0
    :-  %acos-unqual-rd-1
        :-  [%acos acos-u-col-1]
            [~.rd .~0]
    ::  acos(col2=.~0) = 1.5707963267948966
    :-  %acos-unqual-rd-0
        :-  [%acos acos-u-col-2]
            [~.rd .~1.5707963267948966]
    ::  acos(col3=.~-1) = 3.141592653589793
    :-  %acos-unqual-rd-neg-1
        :-  [%acos acos-u-col-3]
            [~.rd .~3.141592653589793]
    ::  unqualified columns: @sd
    ::  acos(col4=--0) = 1.5707963267948966
    :-  %acos-unqual-sd-0
        :-  [%acos acos-u-col-4]
            [~.rd .~1.5707963267948966]
    ::  acos(col5=--1) = 0.0
    :-  %acos-unqual-sd-1
        :-  [%acos acos-u-col-5]
            [~.rd .~0]
    ::  acos(col6=-1) = 3.141592653589793
    :-  %acos-unqual-sd-neg-1
        :-  [%acos acos-u-col-6]
            [~.rd .~3.141592653589793]
    ::  unqualified columns: @ud
    ::  acos(col7=0) = 1.5707963267948966
    :-  %acos-unqual-ud-0
        :-  [%acos acos-u-col-7]
            [~.rd .~1.5707963267948966]
    ::  acos(col8=1) = 0.0
    :-  %acos-unqual-ud-1
        :-  [%acos acos-u-col-8]
            [~.rd .~0]
  ==
  ==
::
++  test-atan-qual
  %:  run-scalar-tests
    table-named-ctes
    qual-lookup
    atan-qual-map-meta
    *(map @tas resolved-scalar)
    atan-qual-table-row
    :~
    ::  literals: @rd
    ::  atan(1.0) = 0.7853981633790044
    :-  %atan-lit-rd-1
        :-  [%atan [~.rd .~1]]
            [~.rd .~0.78539816339745139]
    ::  atan(0.0) = 0.0
    :-  %atan-lit-rd-0
        :-  [%atan [~.rd .~0]]
            [~.rd .~0]
    ::  atan(-1.0) = -0.7853981633790044
    :-  %atan-lit-rd-neg-1
        :-  [%atan [~.rd .~-1]]
            [~.rd .~-0.78539816339745139]
    ::  literals: @sd
    ::  atan(--0) = 0.0
    :-  %atan-lit-sd-0
        :-  [%atan [~.sd --0]]
            [~.rd .~0]
    ::  atan(--1) = 0.7853981633790044
    :-  %atan-lit-sd-1
        :-  [%atan [~.sd --1]]
            [~.rd .~0.78539816339745139]
    ::  atan(-1) = -0.7853981633790044
    :-  %atan-lit-sd-neg-1
        :-  [%atan [~.sd -1]]
            [~.rd .~-0.78539816339745139]
    ::  literals: @ud
    ::  atan(0) = 0.0
    :-  %atan-lit-ud-0
        :-  [%atan [~.ud 0]]
            [~.rd .~0]
    ::  atan(1) = 0.7853981633790044
    :-  %atan-lit-ud-1
        :-  [%atan [~.ud 1]]
            [~.rd .~0.78539816339745139]
    ::  atan(2) = 1.1071487177940904
    :-  %atan-lit-ud-2
        :-  [%atan [~.ud 2]]
            [~.rd .~1.1071487177940984]
    ::  qualified columns: @rd
    ::  atan(col1=.~1) = 0.7853981633790044
    :-  %atan-qual-rd-1
        :-  [%atan atan-q-col-1]
            [~.rd .~0.78539816339745139]
    ::  atan(col2=.~0) = 0.0
    :-  %atan-qual-rd-0
        :-  [%atan atan-q-col-2]
            [~.rd .~0]
    ::  atan(col3=.~-1) = -0.7853981633790044
    :-  %atan-qual-rd-neg-1
        :-  [%atan atan-q-col-3]
            [~.rd .~-0.78539816339745139]
    ::  qualified columns: @sd
    ::  atan(col4=--0) = 0.0
    :-  %atan-qual-sd-0
        :-  [%atan atan-q-col-4]
            [~.rd .~0]
    ::  atan(col5=--1) = 0.7853981633790044
    :-  %atan-qual-sd-1
        :-  [%atan atan-q-col-5]
            [~.rd .~0.78539816339745139]
    ::  atan(col6=-1) = -0.7853981633790044
    :-  %atan-qual-sd-neg-1
        :-  [%atan atan-q-col-6]
            [~.rd .~-0.78539816339745139]
    ::  qualified columns: @ud
    ::  atan(col7=0) = 0.0
    :-  %atan-qual-ud-0
        :-  [%atan atan-q-col-7]
            [~.rd .~0]
    ::  atan(col8=1) = 0.7853981633790044
    :-  %atan-qual-ud-1
        :-  [%atan atan-q-col-8]
            [~.rd .~0.78539816339745139]
    ::  atan(col9=2) = 1.1071487177940904
    :-  %atan-qual-ud-2
        :-  [%atan atan-q-col-9]
            [~.rd .~1.1071487177940984]
  ==
  ==
::
++  test-atan-unqual
  %:  run-scalar-tests
    table-named-ctes
    atan-unqual-lookup
    atan-unqual-map-meta
    *(map @tas resolved-scalar)
    atan-unqual-table-row
    :~
    ::  unqualified columns: @rd
    ::  atan(col1=.~1) = 0.7853981633790044
    :-  %atan-unqual-rd-1
        :-  [%atan atan-u-col-1]
            [~.rd .~0.78539816339745139]
    ::  atan(col2=.~0) = 0.0
    :-  %atan-unqual-rd-0
        :-  [%atan atan-u-col-2]
            [~.rd .~0]
    ::  atan(col3=.~-1) = -0.7853981633790044
    :-  %atan-unqual-rd-neg-1
        :-  [%atan atan-u-col-3]
            [~.rd .~-0.78539816339745139]
    ::  unqualified columns: @sd
    ::  atan(col4=--0) = 0.0
    :-  %atan-unqual-sd-0
        :-  [%atan atan-u-col-4]
            [~.rd .~0]
    ::  atan(col5=--1) = 0.7853981633790044
    :-  %atan-unqual-sd-1
        :-  [%atan atan-u-col-5]
            [~.rd .~0.78539816339745139]
    ::  atan(col6=-1) = -0.7853981633790044
    :-  %atan-unqual-sd-neg-1
        :-  [%atan atan-u-col-6]
            [~.rd .~-0.78539816339745139]
    ::  unqualified columns: @ud
    ::  atan(col7=0) = 0.0
    :-  %atan-unqual-ud-0
        :-  [%atan atan-u-col-7]
            [~.rd .~0]
    ::  atan(col8=1) = 0.7853981633790044
    :-  %atan-unqual-ud-1
        :-  [%atan atan-u-col-8]
            [~.rd .~0.78539816339745139]
    ::  atan(col9=2) = 1.1071487177940904
    :-  %atan-unqual-ud-2
        :-  [%atan atan-u-col-9]
            [~.rd .~1.1071487177940984]
  ==
  ==
::
::  %atan2 tests
::
++  test-atan2-qual
  %:  run-scalar-tests
    table-named-ctes
    qual-lookup
    atan2-qual-map-meta
    *(map @tas resolved-scalar)
    atan2-qual-table-row
    :~
    ::  literals: @rd y / @rd x
    ::  atan2(.~0, .~0) = 0.0
    :-  %atan2-lit-rd-0-0
        :-  [%atan2 [~.rd .~0] [~.rd .~0]]
            [~.rd .~0]
    ::  atan2(.~1, .~2) = 0.46364760900081726
    :-  %atan2-lit-rd-1-2
        :-  [%atan2 [~.rd .~1] [~.rd .~2]]
            [~.rd .~0.46364760900080748]
    ::  atan2(.~-1, .~1) = -0.78539816339744828
    :-  %atan2-lit-rd-neg1-1
        :-  [%atan2 [~.rd .~-1] [~.rd .~1]]
            [~.rd .~-0.78539816339745139]
    ::  atan2(.~3, .~-2) = 2.1587989303424643
    :-  %atan2-lit-rd-3-neg2
        :-  [%atan2 [~.rd .~3] [~.rd .~-2]]
            [~.rd .~2.1587989303424591]
    ::  atan2(.~-4, .~-5) = -2.4668517113662596
    :-  %atan2-lit-rd-neg4-neg5
        :-  [%atan2 [~.rd .~-4] [~.rd .~-5]]
            [~.rd .~-2.466851711366238]
    ::  literals: @sd y / @sd x
    ::  atan2(--0, --0) = 0.0
    :-  %atan2-lit-sd-0-0
        :-  [%atan2 [~.sd --0] [~.sd --0]]
            [~.rd .~0]
    ::  atan2(--1, --2) = 0.46364760900081726
    :-  %atan2-lit-sd-1-2
        :-  [%atan2 [~.sd --1] [~.sd --2]]
            [~.rd .~0.46364760900080748]
    ::  atan2(-1, --1) = -0.78539816339744828
    :-  %atan2-lit-sd-neg1-1
        :-  [%atan2 [~.sd -1] [~.sd --1]]
            [~.rd .~-0.78539816339745139]
    ::  atan2(--3, -2) = 2.1587989303424643
    :-  %atan2-lit-sd-3-neg2
        :-  [%atan2 [~.sd --3] [~.sd -2]]
            [~.rd .~2.1587989303424591]
    ::  atan2(-4, -5) = -2.4668517113662596
    :-  %atan2-lit-sd-neg4-neg5
        :-  [%atan2 [~.sd -4] [~.sd -5]]
            [~.rd .~-2.466851711366238]
    ::  literals: @ud y / @ud x (non-negative only)
    ::  atan2(0, 0) = 0.0
    :-  %atan2-lit-ud-0-0
        :-  [%atan2 [~.ud 0] [~.ud 0]]
            [~.rd .~0]
    ::  atan2(1, 2) = 0.46364760900081726
    :-  %atan2-lit-ud-1-2
        :-  [%atan2 [~.ud 1] [~.ud 2]]
            [~.rd .~0.46364760900080748]
    ::  cross-type literals: atan2(1, 2) with all 6 cross-type combos
    ::  @rd y / @sd x: atan2(.~1, --2)
    :-  %atan2-lit-rd-y-sd-x
        :-  [%atan2 [~.rd .~1] [~.sd --2]]
            [~.rd .~0.46364760900080748]
    ::  @rd y / @ud x: atan2(.~1, 2)
    :-  %atan2-lit-rd-y-ud-x
        :-  [%atan2 [~.rd .~1] [~.ud 2]]
            [~.rd .~0.46364760900080748]
    ::  @sd y / @rd x: atan2(--1, .~2)
    :-  %atan2-lit-sd-y-rd-x
        :-  [%atan2 [~.sd --1] [~.rd .~2]]
            [~.rd .~0.46364760900080748]
    ::  @sd y / @ud x: atan2(--1, 2)
    :-  %atan2-lit-sd-y-ud-x
        :-  [%atan2 [~.sd --1] [~.ud 2]]
            [~.rd .~0.46364760900080748]
    ::  @ud y / @rd x: atan2(1, .~2)
    :-  %atan2-lit-ud-y-rd-x
        :-  [%atan2 [~.ud 1] [~.rd .~2]]
            [~.rd .~0.46364760900080748]
    ::  @ud y / @sd x: atan2(1, --2)
    :-  %atan2-lit-ud-y-sd-x
        :-  [%atan2 [~.ud 1] [~.sd --2]]
            [~.rd .~0.46364760900080748]
    ::  qualified columns: 9 type combinations (y=1, x=2)
    ::  @rd col1(y=.~1) / @rd col2(x=.~2)
    :-  %atan2-qual-rd-y-rd-x
        :-  [%atan2 atan2-q-col-1 atan2-q-col-2]
            [~.rd .~0.46364760900080748]
    ::  @rd col1(y=.~1) / @sd col4(x=--2)
    :-  %atan2-qual-rd-y-sd-x
        :-  [%atan2 atan2-q-col-1 atan2-q-col-4]
            [~.rd .~0.46364760900080748]
    ::  @rd col1(y=.~1) / @ud col6(x=2)
    :-  %atan2-qual-rd-y-ud-x
        :-  [%atan2 atan2-q-col-1 atan2-q-col-6]
            [~.rd .~0.46364760900080748]
    ::  @sd col3(y=--1) / @rd col2(x=.~2)
    :-  %atan2-qual-sd-y-rd-x
        :-  [%atan2 atan2-q-col-3 atan2-q-col-2]
            [~.rd .~0.46364760900080748]
    ::  @sd col3(y=--1) / @sd col4(x=--2)
    :-  %atan2-qual-sd-y-sd-x
        :-  [%atan2 atan2-q-col-3 atan2-q-col-4]
            [~.rd .~0.46364760900080748]
    ::  @sd col3(y=--1) / @ud col6(x=2)
    :-  %atan2-qual-sd-y-ud-x
        :-  [%atan2 atan2-q-col-3 atan2-q-col-6]
            [~.rd .~0.46364760900080748]
    ::  @ud col5(y=1) / @rd col2(x=.~2)
    :-  %atan2-qual-ud-y-rd-x
        :-  [%atan2 atan2-q-col-5 atan2-q-col-2]
            [~.rd .~0.46364760900080748]
    ::  @ud col5(y=1) / @sd col4(x=--2)
    :-  %atan2-qual-ud-y-sd-x
        :-  [%atan2 atan2-q-col-5 atan2-q-col-4]
            [~.rd .~0.46364760900080748]
    ::  @ud col5(y=1) / @ud col6(x=2)
    :-  %atan2-qual-ud-y-ud-x
        :-  [%atan2 atan2-q-col-5 atan2-q-col-6]
            [~.rd .~0.46364760900080748]
  ==
  ==
::
++  test-atan2-unqual
  %:  run-scalar-tests
    table-named-ctes
    atan2-unqual-lookup
    atan2-unqual-map-meta
    *(map @tas resolved-scalar)
    atan2-unqual-table-row
    :~
    ::  unqualified columns: 9 type combinations (y=1, x=2)
    ::  @rd col1(y=.~1) / @rd col2(x=.~2)
    :-  %atan2-unqual-rd-y-rd-x
        :-  [%atan2 atan2-u-col-1 atan2-u-col-2]
            [~.rd .~0.46364760900080748]
    ::  @rd col1(y=.~1) / @sd col4(x=--2)
    :-  %atan2-unqual-rd-y-sd-x
        :-  [%atan2 atan2-u-col-1 atan2-u-col-4]
            [~.rd .~0.46364760900080748]
    ::  @rd col1(y=.~1) / @ud col6(x=2)
    :-  %atan2-unqual-rd-y-ud-x
        :-  [%atan2 atan2-u-col-1 atan2-u-col-6]
            [~.rd .~0.46364760900080748]
    ::  @sd col3(y=--1) / @rd col2(x=.~2)
    :-  %atan2-unqual-sd-y-rd-x
        :-  [%atan2 atan2-u-col-3 atan2-u-col-2]
            [~.rd .~0.46364760900080748]
    ::  @sd col3(y=--1) / @sd col4(x=--2)
    :-  %atan2-unqual-sd-y-sd-x
        :-  [%atan2 atan2-u-col-3 atan2-u-col-4]
            [~.rd .~0.46364760900080748]
    ::  @sd col3(y=--1) / @ud col6(x=2)
    :-  %atan2-unqual-sd-y-ud-x
        :-  [%atan2 atan2-u-col-3 atan2-u-col-6]
            [~.rd .~0.46364760900080748]
    ::  @ud col5(y=1) / @rd col2(x=.~2)
    :-  %atan2-unqual-ud-y-rd-x
        :-  [%atan2 atan2-u-col-5 atan2-u-col-2]
            [~.rd .~0.46364760900080748]
    ::  @ud col5(y=1) / @sd col4(x=--2)
    :-  %atan2-unqual-ud-y-sd-x
        :-  [%atan2 atan2-u-col-5 atan2-u-col-4]
            [~.rd .~0.46364760900080748]
    ::  @ud col5(y=1) / @ud col6(x=2)
    :-  %atan2-unqual-ud-y-ud-x
        :-  [%atan2 atan2-u-col-5 atan2-u-col-6]
            [~.rd .~0.46364760900080748]
  ==
  ==
::
++  test-degrees-qual
  %:  run-scalar-tests
    table-named-ctes
    qual-lookup
    degrees-qual-map-meta
    *(map @tas resolved-scalar)
    degrees-qual-table-row
    :~
    ::  literals: @rd
    ::  degrees(0.0) = 0.0
    :-  %degrees-lit-rd-0
        :-  [%degrees [~.rd .~0]]
            [~.rd .~0]
    ::  degrees(1.0) = 57.29577951308232
    :-  %degrees-lit-rd-1
        :-  [%degrees [~.rd .~1]]
            [~.rd .~57.29577951308232]
    ::  degrees(3.14) ~= 179.9087
    :-  %degrees-lit-rd-3-14
        :-  [%degrees [~.rd .~3.14]]
            [~.rd .~179.90874767107848]
    ::  degrees(-3.14) ~= -179.9087
    :-  %degrees-lit-rd-neg-3-14
        :-  [%degrees [~.rd .~-3.14]]
            [~.rd .~-179.90874767107848]
    ::  degrees(24.0) ~= 1375.0987
    :-  %degrees-lit-rd-24
        :-  [%degrees [~.rd .~24]]
            [~.rd .~1375.0987083139757]
    ::  degrees(-24.0) ~= -1375.0987
    :-  %degrees-lit-rd-neg-24
        :-  [%degrees [~.rd .~-24]]
            [~.rd .~-1375.0987083139757]
    ::  literals: @sd
    ::  degrees(--0) = --0
    :-  %degrees-lit-sd-0
        :-  [%degrees [~.sd --0]]
            [~.sd --0]
    ::  degrees(--1) = --57
    :-  %degrees-lit-sd-1
        :-  [%degrees [~.sd --1]]
            [~.sd --57]
    ::  degrees(--3) = --172
    :-  %degrees-lit-sd-3
        :-  [%degrees [~.sd --3]]
            [~.sd --172]
    ::  degrees(-3) = -172
    :-  %degrees-lit-sd-neg-3
        :-  [%degrees [~.sd -3]]
            [~.sd -172]
    ::  degrees(--24) = --1.375
    :-  %degrees-lit-sd-24
        :-  [%degrees [~.sd --24]]
            [~.sd --1.375]
    ::  degrees(-24) = -1.375
    :-  %degrees-lit-sd-neg-24
        :-  [%degrees [~.sd -24]]
            [~.sd -1.375]
    ::  literals: @ud
    ::  degrees(0) = 0
    :-  %degrees-lit-ud-0
        :-  [%degrees [~.ud 0]]
            [~.ud 0]
    ::  degrees(1) = 57
    :-  %degrees-lit-ud-1
        :-  [%degrees [~.ud 1]]
            [~.ud 57]
    ::  degrees(3) = 172
    :-  %degrees-lit-ud-3
        :-  [%degrees [~.ud 3]]
            [~.ud 172]
    ::  degrees(24) = 1.375
    :-  %degrees-lit-ud-24
        :-  [%degrees [~.ud 24]]
            [~.ud 1.375]
    ::  qualified columns: @rd
    ::  degrees(col1=.~0) = .~0
    :-  %degrees-qual-rd-0
        :-  [%degrees degrees-q-col-1]
            [~.rd .~0]
    ::  degrees(col2=.~1) = .~57.29577951308232
    :-  %degrees-qual-rd-1
        :-  [%degrees degrees-q-col-2]
            [~.rd .~57.29577951308232]
    ::  degrees(col3=.~3.14) ~= .~179.9087
    :-  %degrees-qual-rd-3-14
        :-  [%degrees degrees-q-col-3]
            [~.rd .~179.90874767107848]
    ::  degrees(col4=.~-3.14) ~= .~-179.9087
    :-  %degrees-qual-rd-neg-3-14
        :-  [%degrees degrees-q-col-4]
            [~.rd .~-179.90874767107848]
    ::  degrees(col5=.~24) ~= .~1375.0987
    :-  %degrees-qual-rd-24
        :-  [%degrees degrees-q-col-5]
            [~.rd .~1375.0987083139757]
    ::  degrees(col6=.~-24) ~= .~-1375.0987
    :-  %degrees-qual-rd-neg-24
        :-  [%degrees degrees-q-col-6]
            [~.rd .~-1375.0987083139757]
    ::  qualified columns: @sd
    ::  degrees(col7=--0) = --0
    :-  %degrees-qual-sd-0
        :-  [%degrees degrees-q-col-7]
            [~.sd --0]
    ::  degrees(col8=--1) = --180
    :-  %degrees-qual-sd-1
        :-  [%degrees degrees-q-col-8]
            [~.sd --57]
    ::  degrees(col9=--3) = --540
    :-  %degrees-qual-sd-3
        :-  [%degrees degrees-q-col-9]
            [~.sd --172]
    ::  degrees(col10=-3) = -540
    :-  %degrees-qual-sd-neg-3
        :-  [%degrees degrees-q-col-10]
            [~.sd -172]
    ::  degrees(col11=--24)
    :-  %degrees-qual-sd-24
        :-  [%degrees degrees-q-col-11]
            [~.sd --1.375]
    ::  degrees(col12=-24) = -4320
    :-  %degrees-qual-sd-neg-24
        :-  [%degrees degrees-q-col-12]
            [~.sd -1.375]
    ::  qualified columns: @ud
    ::  degrees(col13=0) = 0
    :-  %degrees-qual-ud-0
        :-  [%degrees degrees-q-col-13]
            [~.ud 0]
    ::  degrees(col14=1) = 180
    :-  %degrees-qual-ud-1
        :-  [%degrees degrees-q-col-14]
            [~.ud 57]
    ::  degrees(col15=3) = 540
    :-  %degrees-qual-ud-3
        :-  [%degrees degrees-q-col-15]
            [~.ud 172]
    ::  degrees(col16=24)
    :-  %degrees-qual-ud-24
        :-  [%degrees degrees-q-col-16]
            [~.ud 1.375]
  ==
  ==
::
++  test-degrees-unqual
  %:  run-scalar-tests
    table-named-ctes
    degrees-unqual-lookup
    degrees-unqual-map-meta
    *(map @tas resolved-scalar)
    degrees-unqual-table-row
    :~
    ::  unqualified columns: @rd
    ::  degrees(col1=.~0) = .~0
    :-  %degrees-unqual-rd-0
        :-  [%degrees degrees-u-col-1]
            [~.rd .~0]
    ::  degrees(col2=.~1) = .~57.29577951308232
    :-  %degrees-unqual-rd-1
        :-  [%degrees degrees-u-col-2]
            [~.rd .~57.29577951308232]
    ::  degrees(col3=.~3.14) ~= .~179.9087
    :-  %degrees-unqual-rd-3-14
        :-  [%degrees degrees-u-col-3]
            [~.rd .~179.90874767107848]
    ::  degrees(col4=.~-3.14) ~= .~-179.9087
    :-  %degrees-unqual-rd-neg-3-14
        :-  [%degrees degrees-u-col-4]
            [~.rd .~-179.90874767107848]
    ::  degrees(col5=.~24) ~= .~1375.0987
    :-  %degrees-unqual-rd-24
        :-  [%degrees degrees-u-col-5]
            [~.rd .~1375.0987083139757]
    ::  degrees(col6=.~-24) ~= .~-1375.0987
    :-  %degrees-unqual-rd-neg-24
        :-  [%degrees degrees-u-col-6]
            [~.rd .~-1375.0987083139757]
    ::  unqualified columns: @sd
    ::  degrees(col7=--0) = --0
    :-  %degrees-unqual-sd-0
        :-  [%degrees degrees-u-col-7]
            [~.sd --0]
    ::  degrees(col8=--1) = --180
    :-  %degrees-unqual-sd-1
        :-  [%degrees degrees-u-col-8]
            [~.sd --57]
    ::  degrees(col9=--3) = --540
    :-  %degrees-unqual-sd-3
        :-  [%degrees degrees-u-col-9]
            [~.sd --172]
    ::  degrees(col10=-3) = -540
    :-  %degrees-unqual-sd-neg-3
        :-  [%degrees degrees-u-col-10]
            [~.sd -172]
    ::  degrees(col11=--24)
    :-  %degrees-unqual-sd-24
        :-  [%degrees degrees-u-col-11]
            [~.sd --1.375]
    ::  degrees(col12=-24) = -4320
    :-  %degrees-unqual-sd-neg-24
        :-  [%degrees degrees-u-col-12]
            [~.sd -1.375]
    ::  unqualified columns: @ud
    ::  degrees(col13=0) = 0
    :-  %degrees-unqual-ud-0
        :-  [%degrees degrees-u-col-13]
            [~.ud 0]
    ::  degrees(col14=1) = 180
    :-  %degrees-unqual-ud-1
        :-  [%degrees degrees-u-col-14]
            [~.ud 57]
    ::  degrees(col15=3) = 540
    :-  %degrees-unqual-ud-3
        :-  [%degrees degrees-u-col-15]
            [~.ud 172]
    ::  degrees(col16=24)
    :-  %degrees-unqual-ud-24
        :-  [%degrees degrees-u-col-16]
            [~.ud 1.375]
  ==
  ==
::
::  date scalar test helpers
::  col1=@da ~2026.3.15..10.30.45 (year=2026, month=3, day=15, hour=10, min=30, sec=45)
::  col2=@dr ~d1 (1 day)
::
::  qualified: col1=@da, col2=@dr
::
++  dt-qual-map-meta
  %-  mk-qualified-map-meta
      :~  :-  qualified-table-1
              %-  addr-columns
                  :~  [%column %col1 ~.da 0]
                      [%column %col2 ~.dr 0]
                      ==
          ==
::
++  dt-q-col-1  [%qualified-column qualified-table-1 %col1 ~]
++  dt-q-col-2  [%qualified-column qualified-table-1 %col2 ~]
::
++  dt-qual-table-row  %-  mk-indexed-row
                       :~  [%col1 ~2026.3.15..10.30.45]  ::  @da
                           [%col2 ~d1]                    ::  @dr 1 day
                       ==
::
::  unqualified: col1=@da, col2=@dr
::
++  dt-unqual-map-meta
  :-  %unqualified-map-meta
      %-  mk-unqualified-typ-addr-lookup
          %-  addr-columns  :~  [%column %col1 ~.da 0]
                                [%column %col2 ~.dr 0]
                                ==
::
++  dt-unqual-lookup  %-  malt  %-  limo
                      :~  [%col1 ~[qualified-table-1]]
                          [%col2 ~[qualified-table-1]]
                          ==
::
++  dt-u-col-1  [%unqualified-column %col1 ~]
++  dt-u-col-2  [%unqualified-column %col2 ~]
::
++  dt-unqual-table-row  %-  mk-indexed-row
                         :~  [%col1 ~2026.3.15..10.30.45]  ::  @da
                             [%col2 ~d1]                    ::  @dr 1 day
                         ==
::
::  %getutcdate
::
++  test-getutcdate
  %:  run-scalar-tests
    table-named-ctes
    *qualifier-lookup
    qual-map-meta
    *(map @tas resolved-scalar)
    table-row
    :~
    ::  getutcdate() = now.bowl = ~2026.4.21
    :-  %getutcdate
        :-  [%getutcdate ~]
            [~.da ~2026.4.21]
    ==
  ==
::
::  %year: only @da supported
::
++  test-year-qual
  %:  run-scalar-tests
    table-named-ctes
    *qualifier-lookup
    dt-qual-map-meta
    *(map @tas resolved-scalar)
    dt-qual-table-row
    :~
    ::  literal @da: year(~2026.3.15..10.30.45) = 2026
    :-  %year-lit-da
        :-  [%year [~.da ~2026.3.15..10.30.45]]
            [~.ud 2.026]
    ::  qualified column @da (col1=~2026.3.15..10.30.45)
    :-  %year-qual-da
        :-  [%year dt-q-col-1]
            [~.ud 2.026]
    ==
  ==
::
++  test-year-unqual
  %:  run-scalar-tests
    table-named-ctes
    dt-unqual-lookup
    dt-unqual-map-meta
    *(map @tas resolved-scalar)
    dt-unqual-table-row
    :~
    ::  unqualified column @da (col1=~2026.3.15..10.30.45)
    :-  %year-unqual-da
        :-  [%year dt-u-col-1]
            [~.ud 2.026]
    ==
  ==
::
::  %month: only @da supported
::
++  test-month-qual
  %:  run-scalar-tests
    table-named-ctes
    *qualifier-lookup
    dt-qual-map-meta
    *(map @tas resolved-scalar)
    dt-qual-table-row
    :~
    ::  literal @da: month(~2026.3.15..10.30.45) = 3
    :-  %month-lit-da
        :-  [%month [~.da ~2026.3.15..10.30.45]]
            [~.ud 3]
    ::  qualified column @da (col1=~2026.3.15..10.30.45)
    :-  %month-qual-da
        :-  [%month dt-q-col-1]
            [~.ud 3]
    ==
  ==
::
++  test-month-unqual
  %:  run-scalar-tests
    table-named-ctes
    dt-unqual-lookup
    dt-unqual-map-meta
    *(map @tas resolved-scalar)
    dt-unqual-table-row
    :~
    ::  unqualified column @da (col1=~2026.3.15..10.30.45)
    :-  %month-unqual-da
        :-  [%month dt-u-col-1]
            [~.ud 3]
    ==
  ==
::
::  %day: @da yields day-of-month; @dr yields whole days in duration
::
++  test-day-qual
  %:  run-scalar-tests
    table-named-ctes
    *qualifier-lookup
    dt-qual-map-meta
    *(map @tas resolved-scalar)
    dt-qual-table-row
    :~
    ::  literal @da: day(~2026.3.15..10.30.45) = 15
    :-  %day-lit-da
        :-  [%day [~.da ~2026.3.15..10.30.45]]
            [~.ud 15]
    ::  literal @dr: day(~d1) = 1
    :-  %day-lit-dr
        :-  [%day [~.dr ~d1]]
            [~.ud 1]
    ::  qualified column @da (col1=~2026.3.15..10.30.45)
    :-  %day-qual-da
        :-  [%day dt-q-col-1]
            [~.ud 15]
    ::  qualified column @dr (col2=~d1)
    :-  %day-qual-dr
        :-  [%day dt-q-col-2]
            [~.ud 1]
    ==
  ==
::
++  test-day-unqual
  %:  run-scalar-tests
    table-named-ctes
    dt-unqual-lookup
    dt-unqual-map-meta
    *(map @tas resolved-scalar)
    dt-unqual-table-row
    :~
    ::  unqualified column @da (col1=~2026.3.15..10.30.45)
    :-  %day-unqual-da
        :-  [%day dt-u-col-1]
            [~.ud 15]
    ::  unqualified column @dr (col2=~d1)
    :-  %day-unqual-dr
        :-  [%day dt-u-col-2]
            [~.ud 1]
    ==
  ==
::
::  %hour: @da yields hour-of-day; @dr yields whole hours in duration
::
++  test-hour-qual
  %:  run-scalar-tests
    table-named-ctes
    *qualifier-lookup
    dt-qual-map-meta
    *(map @tas resolved-scalar)
    dt-qual-table-row
    :~
    ::  literal @da: hour(~2026.3.15..10.30.45) = 10
    :-  %hour-lit-da
        :-  [%hour [~.da ~2026.3.15..10.30.45]]
            [~.ud 10]
    ::  literal @dr: hour(~d1) = 24
    :-  %hour-lit-dr
        :-  [%hour [~.dr ~d1]]
            [~.ud 24]
    ::  qualified column @da (col1=~2026.3.15..10.30.45)
    :-  %hour-qual-da
        :-  [%hour dt-q-col-1]
            [~.ud 10]
    ::  qualified column @dr (col2=~d1)
    :-  %hour-qual-dr
        :-  [%hour dt-q-col-2]
            [~.ud 24]
    ==
  ==
::
++  test-hour-unqual
  %:  run-scalar-tests
    table-named-ctes
    dt-unqual-lookup
    dt-unqual-map-meta
    *(map @tas resolved-scalar)
    dt-unqual-table-row
    :~
    ::  unqualified column @da (col1=~2026.3.15..10.30.45)
    :-  %hour-unqual-da
        :-  [%hour dt-u-col-1]
            [~.ud 10]
    ::  unqualified column @dr (col2=~d1)
    :-  %hour-unqual-dr
        :-  [%hour dt-u-col-2]
            [~.ud 24]
    ==
  ==
::
::  %minute: @da yields minute-of-hour; @dr yields whole minutes in duration
::
++  test-minute-qual
  %:  run-scalar-tests
    table-named-ctes
    *qualifier-lookup
    dt-qual-map-meta
    *(map @tas resolved-scalar)
    dt-qual-table-row
    :~
    ::  literal @da: minute(~2026.3.15..10.30.45) = 30
    :-  %minute-lit-da
        :-  [%minute [~.da ~2026.3.15..10.30.45]]
            [~.ud 30]
    ::  literal @dr: minute(~d1) = 1440
    :-  %minute-lit-dr
        :-  [%minute [~.dr ~d1]]
            [~.ud 1.440]
    ::  qualified column @da (col1=~2026.3.15..10.30.45)
    :-  %minute-qual-da
        :-  [%minute dt-q-col-1]
            [~.ud 30]
    ::  qualified column @dr (col2=~d1)
    :-  %minute-qual-dr
        :-  [%minute dt-q-col-2]
            [~.ud 1.440]
    ==
  ==
::
++  test-minute-unqual
  %:  run-scalar-tests
    table-named-ctes
    dt-unqual-lookup
    dt-unqual-map-meta
    *(map @tas resolved-scalar)
    dt-unqual-table-row
    :~
    ::  unqualified column @da (col1=~2026.3.15..10.30.45)
    :-  %minute-unqual-da
        :-  [%minute dt-u-col-1]
            [~.ud 30]
    ::  unqualified column @dr (col2=~d1)
    :-  %minute-unqual-dr
        :-  [%minute dt-u-col-2]
            [~.ud 1.440]
    ==
  ==
::
::  %second: @da yields second-of-minute; @dr yields whole seconds in duration
::
++  test-second-qual
  %:  run-scalar-tests
    table-named-ctes
    *qualifier-lookup
    dt-qual-map-meta
    *(map @tas resolved-scalar)
    dt-qual-table-row
    :~
    ::  literal @da: second(~2026.3.15..10.30.45) = 45
    :-  %second-lit-da
        :-  [%second [~.da ~2026.3.15..10.30.45]]
            [~.ud 45]
    ::  literal @dr: second(~d1) = 86400
    :-  %second-lit-dr
        :-  [%second [~.dr ~d1]]
            [~.ud 86.400]
    ::  qualified column @da (col1=~2026.3.15..10.30.45)
    :-  %second-qual-da
        :-  [%second dt-q-col-1]
            [~.ud 45]
    ::  qualified column @dr (col2=~d1)
    :-  %second-qual-dr
        :-  [%second dt-q-col-2]
            [~.ud 86.400]
    ==
  ==
::
++  test-second-unqual
  %:  run-scalar-tests
    table-named-ctes
    dt-unqual-lookup
    dt-unqual-map-meta
    *(map @tas resolved-scalar)
    dt-unqual-table-row
    :~
    ::  unqualified column @da (col1=~2026.3.15..10.30.45)
    :-  %second-unqual-da
        :-  [%second dt-u-col-1]
            [~.ud 45]
    ::  unqualified column @dr (col2=~d1)
    :-  %second-unqual-dr
        :-  [%second dt-u-col-2]
            [~.ud 86.400]
    ==
  ==
::
::  %add-time: expr=@da|@dr, duration=@dr
::  covers all 4 (lit/col × lit/col) combos for both @da+@dr and @dr+@dr
::
++  test-add-time-qual
  %:  run-scalar-tests
    table-named-ctes
    *qualifier-lookup
    dt-qual-map-meta
    *(map @tas resolved-scalar)
    dt-qual-table-row
    :~
    ::  @da + @dr literals: ~2026.3.15..10.30.45 + ~d1 = ~2026.3.16..10.30.45
    :-  %add-time-lit-da-dr
        :-  [%add-time [~.da ~2026.3.15..10.30.45] [~.dr ~d1]]
            [~.da ~2026.3.16..10.30.45]
    ::  @dr + @dr literals: ~d1 + ~d1 = ~d2
    :-  %add-time-lit-dr-dr
        :-  [%add-time [~.dr ~d1] [~.dr ~d1]]
            [~.dr ~d2]
    ::  qualified col @da + lit @dr
    :-  %add-time-qual-col-da-lit-dr
        :-  [%add-time dt-q-col-1 [~.dr ~d1]]
            [~.da ~2026.3.16..10.30.45]
    ::  lit @da + qualified col @dr
    :-  %add-time-qual-lit-da-col-dr
        :-  [%add-time [~.da ~2026.3.15..10.30.45] dt-q-col-2]
            [~.da ~2026.3.16..10.30.45]
    ::  qualified col @da + qualified col @dr
    :-  %add-time-qual-col-da-col-dr
        :-  [%add-time dt-q-col-1 dt-q-col-2]
            [~.da ~2026.3.16..10.30.45]
    ::  qualified col @dr + lit @dr: ~d1 + ~d1 = ~d2
    :-  %add-time-qual-col-dr-lit-dr
        :-  [%add-time dt-q-col-2 [~.dr ~d1]]
            [~.dr ~d2]
    ::  lit @dr + qualified col @dr: ~d1 + ~d1 = ~d2
    :-  %add-time-qual-lit-dr-col-dr
        :-  [%add-time [~.dr ~d1] dt-q-col-2]
            [~.dr ~d2]
    ::  qualified col @dr + qualified col @dr: ~d1 + ~d1 = ~d2
    :-  %add-time-qual-col-dr-col-dr
        :-  [%add-time dt-q-col-2 dt-q-col-2]
            [~.dr ~d2]
    ==
  ==
::
++  test-add-time-unqual
  %:  run-scalar-tests
    table-named-ctes
    dt-unqual-lookup
    dt-unqual-map-meta
    *(map @tas resolved-scalar)
    dt-unqual-table-row
    :~
    ::  unqualified col @da + lit @dr
    :-  %add-time-unqual-col-da-lit-dr
        :-  [%add-time dt-u-col-1 [~.dr ~d1]]
            [~.da ~2026.3.16..10.30.45]
    ::  lit @da + unqualified col @dr
    :-  %add-time-unqual-lit-da-col-dr
        :-  [%add-time [~.da ~2026.3.15..10.30.45] dt-u-col-2]
            [~.da ~2026.3.16..10.30.45]
    ::  unqualified col @da + unqualified col @dr
    :-  %add-time-unqual-col-da-col-dr
        :-  [%add-time dt-u-col-1 dt-u-col-2]
            [~.da ~2026.3.16..10.30.45]
    ::  unqualified col @dr + lit @dr: ~d1 + ~d1 = ~d2
    :-  %add-time-unqual-col-dr-lit-dr
        :-  [%add-time dt-u-col-2 [~.dr ~d1]]
            [~.dr ~d2]
    ::  lit @dr + unqualified col @dr: ~d1 + ~d1 = ~d2
    :-  %add-time-unqual-lit-dr-col-dr
        :-  [%add-time [~.dr ~d1] dt-u-col-2]
            [~.dr ~d2]
    ::  unqualified col @dr + unqualified col @dr: ~d1 + ~d1 = ~d2
    :-  %add-time-unqual-col-dr-col-dr
        :-  [%add-time dt-u-col-2 dt-u-col-2]
            [~.dr ~d2]
    ==
  ==
::
::  %subtract-time: expr=@da|@dr, duration=@dr
::  covers all 4 (lit/col × lit/col) combos for both @da-@dr and @dr-@dr
::  note: col@dr-col@dr uses col2=~d1 for both sides, yielding zero duration
::
++  test-subtract-time-qual
  %:  run-scalar-tests
    table-named-ctes
    *qualifier-lookup
    dt-qual-map-meta
    *(map @tas resolved-scalar)
    dt-qual-table-row
    :~
    ::  @da - @dr literals: ~2026.3.15..10.30.45 - ~d1 = ~2026.3.14..10.30.45
    :-  %subtract-time-lit-da-dr
        :-  [%subtract-time [~.da ~2026.3.15..10.30.45] [~.dr ~d1]]
            [~.da ~2026.3.14..10.30.45]
    ::  @dr - @dr literals: ~d2 - ~d1 = ~d1
    :-  %subtract-time-lit-dr-dr
        :-  [%subtract-time [~.dr ~d2] [~.dr ~d1]]
            [~.dr ~d1]
    ::  qualified col @da - lit @dr
    :-  %subtract-time-qual-col-da-lit-dr
        :-  [%subtract-time dt-q-col-1 [~.dr ~d1]]
            [~.da ~2026.3.14..10.30.45]
    ::  lit @da - qualified col @dr
    :-  %subtract-time-qual-lit-da-col-dr
        :-  [%subtract-time [~.da ~2026.3.15..10.30.45] dt-q-col-2]
            [~.da ~2026.3.14..10.30.45]
    ::  qualified col @da - qualified col @dr
    :-  %subtract-time-qual-col-da-col-dr
        :-  [%subtract-time dt-q-col-1 dt-q-col-2]
            [~.da ~2026.3.14..10.30.45]
    ::  qualified col @dr - lit @dr: ~d1 - ~d1 = 0
    :-  %subtract-time-qual-col-dr-lit-dr
        :-  [%subtract-time dt-q-col-2 [~.dr ~d1]]
            [~.dr 0]
    ::  lit @dr - qualified col @dr: ~d2 - ~d1 = ~d1
    :-  %subtract-time-qual-lit-dr-col-dr
        :-  [%subtract-time [~.dr ~d2] dt-q-col-2]
            [~.dr ~d1]
    ::  qualified col @dr - qualified col @dr: ~d1 - ~d1 = 0
    :-  %subtract-time-qual-col-dr-col-dr
        :-  [%subtract-time dt-q-col-2 dt-q-col-2]
            [~.dr 0]
    ==
  ==
::
::  ::::::::::::::::::::::::::::
::  :::: STRING SCALAR TESTS ::::
::  ::::::::::::::::::::::::::::
::
::  %concat tests
::  col1='hello', col2='world', col5=@ud 3 (unused here)
::
++  test-concat-qual
  %:  run-scalar-tests
    table-named-ctes
    qual-lookup
    str-qual-map-meta
    *(map @tas resolved-scalar)
    str-qual-table-row
    :~
    ::  lit + lit
    :-  %concat-lit-lit
        :-  [%concat ~[[~.t 'hello'] [~.t 'world']]]
            [~.t 'helloworld']
    ::  3-item lit
    :-  %concat-lit-lit-lit
        :-  [%concat ~[[~.t 'a'] [~.t 'b'] [~.t 'c']]]
            [~.t 'abc']
    ::  col + lit
    :-  %concat-col-lit
        :-  [%concat ~[str-q-col-1 [~.t 'world']]]
            [~.t 'helloworld']
    ::  lit + col
    :-  %concat-lit-col
        :-  [%concat ~[[~.t 'hello'] str-q-col-2]]
            [~.t 'helloworld']
    ::  col + col
    :-  %concat-col-col
        :-  [%concat ~[str-q-col-1 str-q-col-2]]
            [~.t 'helloworld']
  ==
  ==
::
++  test-concat-unqual
  %:  run-scalar-tests
    table-named-ctes
    str-unqual-lookup
    str-unqual-map-meta
    *(map @tas resolved-scalar)
    str-unqual-table-row
    :~
    ::  unqual col + lit
    :-  %concat-unqual-col-lit
        :-  [%concat ~[str-u-col-6 [~.t 'world']]]
            [~.t 'helloworld']
    ::  lit + unqual col
    :-  %concat-unqual-lit-col
        :-  [%concat ~[[~.t 'hello'] str-u-col-7]]
            [~.t 'helloworld']
    ::  unqual col + unqual col
    :-  %concat-unqual-col-col
        :-  [%concat ~[str-u-col-6 str-u-col-7]]
            [~.t 'helloworld']
  ==
  ==
::
::  %left tests
::  LEFT(str, n) returns the left n characters
::  col1='hello' col5=@ud 3
::
++  test-left-qual
  %:  run-scalar-tests
    table-named-ctes
    qual-lookup
    str-qual-map-meta
    *(map @tas resolved-scalar)
    str-qual-table-row
    :~
    ::  lit-str + lit-int
    :-  %left-lit-lit
        :-  [%left [~.t 'hello'] [~.ud 3]]
            [~.t 'hel']
    ::  col-str + lit-int
    :-  %left-col-lit
        :-  [%left str-q-col-1 [~.ud 3]]
            [~.t 'hel']
    ::  lit-str + col-int
    :-  %left-lit-col
        :-  [%left [~.t 'hello'] str-q-col-5]
            [~.t 'hel']
    ::  col-str + col-int
    :-  %left-col-col
        :-  [%left str-q-col-1 str-q-col-5]
            [~.t 'hel']
  ==
  ==
::
++  test-left-unqual
  %:  run-scalar-tests
    table-named-ctes
    str-unqual-lookup
    str-unqual-map-meta
    *(map @tas resolved-scalar)
    str-unqual-table-row
    :~
    ::  unqual col-str + lit-int
    :-  %left-unqual-col-lit
        :-  [%left str-u-col-6 [~.ud 3]]
            [~.t 'hel']
    ::  lit-str + unqual col-int
    :-  %left-unqual-lit-col
        :-  [%left [~.t 'hello'] str-u-col-10]
            [~.t 'hel']
    ::  unqual col-str + unqual col-int
    :-  %left-unqual-col-col
        :-  [%left str-u-col-6 str-u-col-10]
            [~.t 'hel']
  ==
  ==
::
::  %len tests
::  LEN(str) returns number of characters as @ud
::  col1='hello' (len 5)
::
++  test-len-qual
  %:  run-scalar-tests
    table-named-ctes
    qual-lookup
    str-qual-map-meta
    *(map @tas resolved-scalar)
    str-qual-table-row
    :~
    ::  lit empty string
    :-  %len-lit-empty
        :-  [%len [~.t '']]
            [~.ud 0]
    ::  lit 'hello' = 5 chars
    :-  %len-lit
        :-  [%len [~.t 'hello']]
            [~.ud 5]
    ::  qualified col1='hello' = 5
    :-  %len-qual-col
        :-  [%len str-q-col-1]
            [~.ud 5]
  ==
  ==
::
++  test-len-unqual
  %:  run-scalar-tests
    table-named-ctes
    str-unqual-lookup
    str-unqual-map-meta
    *(map @tas resolved-scalar)
    str-unqual-table-row
    :~
    ::  unqual col6='hello' = 5
    :-  %len-unqual-col
        :-  [%len str-u-col-6]
            [~.ud 5]
  ==
  ==
::
::  %lower tests
::  LOWER(str) converts uppercase to lowercase
::  col4='HELLO'
::
++  test-lower-qual
  %:  run-scalar-tests
    table-named-ctes
    qual-lookup
    str-qual-map-meta
    *(map @tas resolved-scalar)
    str-qual-table-row
    :~
    ::  lit all-caps
    :-  %lower-lit-caps
        :-  [%lower [~.t 'HELLO']]
            [~.t 'hello']
    ::  lit mixed case
    :-  %lower-lit-mixed
        :-  [%lower [~.t 'Hello World']]
            [~.t 'hello world']
    ::  qualified col4='HELLO'
    :-  %lower-qual-col
        :-  [%lower str-q-col-4]
            [~.t 'hello']
  ==
  ==
::
++  test-lower-unqual
  %:  run-scalar-tests
    table-named-ctes
    str-unqual-lookup
    str-unqual-map-meta
    *(map @tas resolved-scalar)
    str-unqual-table-row
    :~
    ::  unqual col9='HELLO'
    :-  %lower-unqual-col
        :-  [%lower str-u-col-9]
            [~.t 'hello']
  ==
  ==
::
::  %ltrim tests
::  default 1-param: trims leading whitespace
::  2-param: trims leading occurrences of pattern cord
::  str-qual: col1='hello', col3='  hello  '
::  str-trim: col1='xxhelloxx', col2='x'
::
++  test-ltrim-qual
  %:  run-scalar-tests
    table-named-ctes
    qual-lookup
    str-qual-map-meta
    *(map @tas resolved-scalar)
    str-qual-table-row
    :~
    ::  default: lit with leading spaces
    :-  %ltrim-default-lit
        :-  [%ltrim [~.t '  hello  '] ~]
            [~.t 'hello  ']
    ::  default: qualified col3='  hello  '
    :-  %ltrim-default-qual-col
        :-  [%ltrim str-q-col-3 ~]
            [~.t 'hello  ']
    ::  pattern: lit-str + lit-pattern
    :-  %ltrim-pattern-lit-lit
        :-  [%ltrim [~.t 'xxhello'] (some [~.t 'x'])]
            [~.t 'hello']
    ::  pattern: col-str (no leading 'x') + lit-pattern — no change
    :-  %ltrim-pattern-col-lit
        :-  [%ltrim str-q-col-1 (some [~.t 'x'])]
            [~.t 'hello']
  ==
  ==
::
++  test-ltrim-qual-pattern-col
  %:  run-scalar-tests
    table-named-ctes
    *qualifier-lookup
    str-trim-qual-map-meta
    *(map @tas resolved-scalar)
    str-trim-qual-table-row
    :~
    ::  col-str + lit-pattern: col1='xxhelloxx', trim 'x' from left
    :-  %ltrim-trim-col-lit
        :-  [%ltrim str-trim-q-col-1 (some [~.t 'x'])]
            [~.t 'helloxx']
    ::  lit-str + col-pattern: col2='x'
    :-  %ltrim-trim-lit-col
        :-  [%ltrim [~.t 'xxhello'] (some str-trim-q-col-2)]
            [~.t 'hello']
    ::  col-str + col-pattern
    :-  %ltrim-trim-col-col
        :-  [%ltrim str-trim-q-col-1 (some str-trim-q-col-2)]
            [~.t 'helloxx']
  ==
  ==
::
++  test-ltrim-unqual
  %:  run-scalar-tests
    table-named-ctes
    str-unqual-lookup
    str-unqual-map-meta
    *(map @tas resolved-scalar)
    str-unqual-table-row
    :~
    ::  default: unqual col8='  hello  '
    :-  %ltrim-default-unqual-col
        :-  [%ltrim str-u-col-8 ~]
            [~.t 'hello  ']
    ::  pattern: lit-str + lit-pattern
    :-  %ltrim-unqual-pattern-lit-lit
        :-  [%ltrim [~.t 'xxhello'] (some [~.t 'x'])]
            [~.t 'hello']
  ==
  ==
::
++  test-ltrim-unqual-pattern-col
  %:  run-scalar-tests
    table-named-ctes
    str-trim-unqual-lookup
    str-trim-unqual-map-meta
    *(map @tas resolved-scalar)
    str-trim-unqual-table-row
    :~
    ::  unqual col-str + lit-pattern
    :-  %ltrim-unqual-trim-col-lit
        :-  [%ltrim str-trim-u-col-3 (some [~.t 'x'])]
            [~.t 'helloxx']
    ::  lit-str + unqual col-pattern
    :-  %ltrim-unqual-trim-lit-col
        :-  [%ltrim [~.t 'xxhello'] (some str-trim-u-col-4)]
            [~.t 'hello']
    ::  unqual col-str + unqual col-pattern
    :-  %ltrim-unqual-trim-col-col
        :-  [%ltrim str-trim-u-col-3 (some str-trim-u-col-4)]
            [~.t 'helloxx']
  ==
  ==
::
::
::  %patindex tests
::  PATINDEX(str, pattern) returns 1-based position, 0 if not found
::  col1='hello', col2='world'
::
++  test-patindex-qual
  %:  run-scalar-tests
    table-named-ctes
    qual-lookup
    str-qual-map-meta
    *(map @tas resolved-scalar)
    str-qual-table-row
    :~
    ::  lit found: 'ell' starts at position 2
    :-  %patindex-lit-found
        :-  [%patindex [~.t 'hello'] [~.t 'ell']]
            [~.ud 2]
    ::  lit not found: returns 0
    :-  %patindex-lit-not-found
        :-  [%patindex [~.t 'hello'] [~.t 'xyz']]
            [~.ud 0]
    ::  col-str + lit-pattern
    :-  %patindex-col-lit
        :-  [%patindex str-q-col-1 [~.t 'ell']]
            [~.ud 2]
    ::  lit-str + col-pattern: 'world' in 'hello world' at pos 7
    :-  %patindex-lit-col
        :-  [%patindex [~.t 'hello world'] str-q-col-2]
            [~.ud 7]
    ::  col-str + col-pattern: col1 finds col1 at pos 1
    :-  %patindex-col-col
        :-  [%patindex str-q-col-1 str-q-col-1]
            [~.ud 1]
  ==
  ==
::
++  test-patindex-unqual
  %:  run-scalar-tests
    table-named-ctes
    str-unqual-lookup
    str-unqual-map-meta
    *(map @tas resolved-scalar)
    str-unqual-table-row
    :~
    ::  unqual col-str + lit-pattern
    :-  %patindex-unqual-col-lit
        :-  [%patindex str-u-col-6 [~.t 'ell']]
            [~.ud 2]
    ::  lit-str + unqual col-pattern
    :-  %patindex-unqual-lit-col
        :-  [%patindex [~.t 'hello world'] str-u-col-7]
            [~.ud 7]
    ::  unqual col + unqual col
    :-  %patindex-unqual-col-col
        :-  [%patindex str-u-col-6 str-u-col-6]
            [~.ud 1]
  ==
  ==
::
::  %quotestring tests
::  default wraps in '[' ']'; optional pair (unit [datum datum]) = open + close
::  col1='hello'
::
++  test-quotestring-qual
  %:  run-scalar-tests
    table-named-ctes
    qual-lookup
    str-qual-map-meta
    *(map @tas resolved-scalar)
    str-qual-table-row
    :~
    ::  default: no quote pair → wraps in [ ]
    :-  %quotestring-default-lit
        :-  [%quotestring [~.t 'hello'] ~]
            [~.t '[hello]']
    ::  default: qualified col
    :-  %quotestring-default-col
        :-  [%quotestring str-q-col-1 ~]
            [~.t '[hello]']
    ::  quote pair ['"' '"']: same open and close
    :-  %quotestring-dquote-lit
        :-  [%quotestring [~.t 'hello'] (some [[~.t '"'] [~.t '"']])]
            [~.t '"hello"']
    ::  quote pair ['"' '"']: qualified col
    :-  %quotestring-dquote-col
        :-  [%quotestring str-q-col-1 (some [[~.t '"'] [~.t '"']])]
            [~.t '"hello"']
    ::  quote pair ['{' '}']: different open and close
    :-  %quotestring-braces-lit
        :-  [%quotestring [~.t 'hello'] (some [[~.t '{'] [~.t '}']])]
            [~.t '{hello}']
    ::  quote pair ['{' '}']: qualified col
    :-  %quotestring-braces-col
        :-  [%quotestring str-q-col-1 (some [[~.t '{'] [~.t '}']])]
            [~.t '{hello}']
  ==
  ==
::
++  test-quotestring-unqual
  %:  run-scalar-tests
    table-named-ctes
    str-unqual-lookup
    str-unqual-map-meta
    *(map @tas resolved-scalar)
    str-unqual-table-row
    :~
    ::  default: unqual col
    :-  %quotestring-unqual-default-col
        :-  [%quotestring str-u-col-6 ~]
            [~.t '[hello]']
    ::  quote pair ['"' '"']: unqual col
    :-  %quotestring-unqual-dquote-col
        :-  [%quotestring str-u-col-6 (some [[~.t '"'] [~.t '"']])]
            [~.t '"hello"']
    ::  quote pair ['{' '}']: unqual col
    :-  %quotestring-unqual-braces-col
        :-  [%quotestring str-u-col-6 (some [[~.t '{'] [~.t '}']])]
            [~.t '{hello}']
  ==
  ==
::
::  %replace tests
::  REPLACE(str, pattern, replacement) replaces all occurrences
::  col1='hello', col2='world'
::
++  test-replace-qual
  %:  run-scalar-tests
    table-named-ctes
    qual-lookup
    str-qual-map-meta
    *(map @tas resolved-scalar)
    str-qual-table-row
    :~
    ::  lit+lit+lit
    :-  %replace-lit-lit-lit
        :-  [%replace [~.t 'hello world'] [~.t 'world'] [~.t 'there']]
            [~.t 'hello there']
    ::  col-str + lit-pattern + lit-replacement
    :-  %replace-col-lit-lit
        :-  [%replace str-q-col-1 [~.t 'ell'] [~.t 'ELL']]
            [~.t 'hELLo']
    ::  col-str + col-pattern + lit-replacement: replaces 'hello' with 'bye'
    :-  %replace-col-col-lit
        :-  [%replace str-q-col-1 str-q-col-1 [~.t 'bye']]
            [~.t 'bye']
    ::  col-str + lit-pattern + col-replacement: REPLACE('hello','ell','world') = 'hworldo'
    :-  %replace-col-lit-col
        :-  [%replace str-q-col-1 [~.t 'ell'] str-q-col-2]
            [~.t 'hworldo']
  ==
  ==
::
++  test-replace-unqual
  %:  run-scalar-tests
    table-named-ctes
    str-unqual-lookup
    str-unqual-map-meta
    *(map @tas resolved-scalar)
    str-unqual-table-row
    :~
    ::  unqual col-str + lit-pattern + lit-replacement
    :-  %replace-unqual-col-lit-lit
        :-  [%replace str-u-col-6 [~.t 'ell'] [~.t 'ELL']]
            [~.t 'hELLo']
    ::  unqual col-str + col-pattern + lit-replacement
    :-  %replace-unqual-col-col-lit
        :-  [%replace str-u-col-6 str-u-col-6 [~.t 'bye']]
            [~.t 'bye']
    ::  unqual col-str + lit-pattern + col-replacement
    :-  %replace-unqual-col-lit-col
        :-  [%replace str-u-col-6 [~.t 'ell'] str-u-col-7]
            [~.t 'hworldo']
  ==
  ==
::
::  %replicate tests
::  REPLICATE(str, n) repeats str n times
::  col1='hello', col5=@ud 3
::
++  test-replicate-qual
  %:  run-scalar-tests
    table-named-ctes
    qual-lookup
    str-qual-map-meta
    *(map @tas resolved-scalar)
    str-qual-table-row
    :~
    ::  lit integer-expression=1
    :-  %replicate-lit-1
        :-  [%replicate [~.t 'ha'] [~.ud 1]]
            [~.t 'ha']
    ::  lit integer-expression=2
    :-  %replicate-lit-2
        :-  [%replicate [~.t 'ha'] [~.ud 2]]
            [~.t 'haha']
    ::  lit integer-expression=3
    :-  %replicate-lit-3
        :-  [%replicate [~.t 'ha'] [~.ud 3]]
            [~.t 'hahaha']
    ::  col-str + lit-int
    :-  %replicate-col-lit
        :-  [%replicate str-q-col-1 [~.ud 2]]
            [~.t 'hellohello']
    ::  lit-str + col-int (col5=3)
    :-  %replicate-lit-col
        :-  [%replicate [~.t 'ha'] str-q-col-5]
            [~.t 'hahaha']
    ::  col-str + col-int
    :-  %replicate-col-col
        :-  [%replicate str-q-col-1 str-q-col-5]
            [~.t 'hellohellohello']
  ==
  ==
::
++  test-replicate-unqual
  %:  run-scalar-tests
    table-named-ctes
    str-unqual-lookup
    str-unqual-map-meta
    *(map @tas resolved-scalar)
    str-unqual-table-row
    :~
    ::  unqual col-str + lit-int
    :-  %replicate-unqual-col-lit
        :-  [%replicate str-u-col-6 [~.ud 2]]
            [~.t 'hellohello']
    ::  lit-str + unqual col-int
    :-  %replicate-unqual-lit-col
        :-  [%replicate [~.t 'ha'] str-u-col-10]
            [~.t 'hahaha']
    ::  unqual col-str + unqual col-int
    :-  %replicate-unqual-col-col
        :-  [%replicate str-u-col-6 str-u-col-10]
            [~.t 'hellohellohello']
  ==
  ==
::
::  %reverse tests
::  REVERSE(str) returns string in reverse order
::  col1='hello'
::
++  test-reverse-qual
  %:  run-scalar-tests
    table-named-ctes
    qual-lookup
    str-qual-map-meta
    *(map @tas resolved-scalar)
    str-qual-table-row
    :~
    ::  lit
    :-  %reverse-lit
        :-  [%reverse [~.t 'hello']]
            [~.t 'olleh']
    ::  lit palindrome: unchanged
    :-  %reverse-lit-palindrome
        :-  [%reverse [~.t 'racecar']]
            [~.t 'racecar']
    ::  qualified col1='hello'
    :-  %reverse-qual-col
        :-  [%reverse str-q-col-1]
            [~.t 'olleh']
  ==
  ==
::
++  test-reverse-unqual
  %:  run-scalar-tests
    table-named-ctes
    str-unqual-lookup
    str-unqual-map-meta
    *(map @tas resolved-scalar)
    str-unqual-table-row
    :~
    ::  unqual col6='hello'
    :-  %reverse-unqual-col
        :-  [%reverse str-u-col-6]
            [~.t 'olleh']
  ==
  ==
::
::  %right tests
::  RIGHT(str, n) returns the right n characters
::  col1='hello', col5=@ud 3
::
++  test-right-qual
  %:  run-scalar-tests
    table-named-ctes
    qual-lookup
    str-qual-map-meta
    *(map @tas resolved-scalar)
    str-qual-table-row
    :~
    ::  lit-str + lit-int
    :-  %right-lit-lit
        :-  [%right [~.t 'hello'] [~.ud 3]]
            [~.t 'llo']
    ::  col-str + lit-int
    :-  %right-col-lit
        :-  [%right str-q-col-1 [~.ud 3]]
            [~.t 'llo']
    ::  lit-str + col-int (col5=3)
    :-  %right-lit-col
        :-  [%right [~.t 'hello'] str-q-col-5]
            [~.t 'llo']
    ::  col-str + col-int
    :-  %right-col-col
        :-  [%right str-q-col-1 str-q-col-5]
            [~.t 'llo']
  ==
  ==
::
++  test-right-unqual
  %:  run-scalar-tests
    table-named-ctes
    str-unqual-lookup
    str-unqual-map-meta
    *(map @tas resolved-scalar)
    str-unqual-table-row
    :~
    ::  unqual col-str + lit-int
    :-  %right-unqual-col-lit
        :-  [%right str-u-col-6 [~.ud 3]]
            [~.t 'llo']
    ::  lit-str + unqual col-int
    :-  %right-unqual-lit-col
        :-  [%right [~.t 'hello'] str-u-col-10]
            [~.t 'llo']
    ::  unqual col-str + unqual col-int
    :-  %right-unqual-col-col
        :-  [%right str-u-col-6 str-u-col-10]
            [~.t 'llo']
  ==
  ==
::
::
::  %rtrim tests
::  mirror of ltrim: removes trailing occurrences
::
++  test-rtrim-qual
  %:  run-scalar-tests
    table-named-ctes
    qual-lookup
    str-qual-map-meta
    *(map @tas resolved-scalar)
    str-qual-table-row
    :~
    ::  default: lit with trailing spaces
    :-  %rtrim-default-lit
        :-  [%rtrim [~.t '  hello  '] ~]
            [~.t '  hello']
    ::  default: qualified col3='  hello  '
    :-  %rtrim-default-qual-col
        :-  [%rtrim str-q-col-3 ~]
            [~.t '  hello']
    ::  pattern: lit-str + lit-pattern
    :-  %rtrim-pattern-lit-lit
        :-  [%rtrim [~.t 'helloxx'] (some [~.t 'x'])]
            [~.t 'hello']
    ::  pattern: col-str (no trailing 'x') + lit-pattern — no change
    :-  %rtrim-pattern-col-lit
        :-  [%rtrim str-q-col-1 (some [~.t 'x'])]
            [~.t 'hello']
  ==
  ==
::
++  test-rtrim-qual-pattern-col
  %:  run-scalar-tests
    table-named-ctes
    *qualifier-lookup
    str-trim-qual-map-meta
    *(map @tas resolved-scalar)
    str-trim-qual-table-row
    :~
    ::  col-str + lit-pattern: col1='xxhelloxx', trim 'x' from right
    :-  %rtrim-trim-col-lit
        :-  [%rtrim str-trim-q-col-1 (some [~.t 'x'])]
            [~.t 'xxhello']
    ::  lit-str + col-pattern
    :-  %rtrim-trim-lit-col
        :-  [%rtrim [~.t 'helloxx'] (some str-trim-q-col-2)]
            [~.t 'hello']
    ::  col-str + col-pattern
    :-  %rtrim-trim-col-col
        :-  [%rtrim str-trim-q-col-1 (some str-trim-q-col-2)]
            [~.t 'xxhello']
  ==
  ==
::
++  test-rtrim-unqual
  %:  run-scalar-tests
    table-named-ctes
    str-unqual-lookup
    str-unqual-map-meta
    *(map @tas resolved-scalar)
    str-unqual-table-row
    :~
    ::  default: unqual col8='  hello  '
    :-  %rtrim-default-unqual-col
        :-  [%rtrim str-u-col-8 ~]
            [~.t '  hello']
    ::  pattern: lit-str + lit-pattern
    :-  %rtrim-unqual-pattern-lit-lit
        :-  [%rtrim [~.t 'helloxx'] (some [~.t 'x'])]
            [~.t 'hello']
  ==
  ==
::
++  test-rtrim-unqual-pattern-col
  %:  run-scalar-tests
    table-named-ctes
    str-trim-unqual-lookup
    str-trim-unqual-map-meta
    *(map @tas resolved-scalar)
    str-trim-unqual-table-row
    :~
    ::  unqual col-str + lit-pattern
    :-  %rtrim-unqual-trim-col-lit
        :-  [%rtrim str-trim-u-col-3 (some [~.t 'x'])]
            [~.t 'xxhello']
    ::  lit-str + unqual col-pattern
    :-  %rtrim-unqual-trim-lit-col
        :-  [%rtrim [~.t 'helloxx'] (some str-trim-u-col-4)]
            [~.t 'hello']
    ::  unqual col-str + unqual col-pattern
    :-  %rtrim-unqual-trim-col-col
        :-  [%rtrim str-trim-u-col-3 (some str-trim-u-col-4)]
            [~.t 'xxhello']
  ==
  ==
::
::  %string tests
::  STRING(numeric) converts to cord using scow
::  @ud 42 → '42', @sd --42 → '--42', @sd -42 → '-42'
::  @rd .~42.42 → '.~42.42', @rd .~-24.24 → '.~-24.24'
::
++  test-string-qual
  %:  run-scalar-tests
    table-named-ctes
    *qualifier-lookup
    str-num-qual-map-meta
    *(map @tas resolved-scalar)
    str-num-qual-table-row
    :~
    ::  literal @ud 42
    :-  %string-lit-ud
        :-  [%string [~.ud 42]]
            [~.t '42']
    ::  literal @sd --42 (positive)
    :-  %string-lit-sd-pos
        :-  [%string [~.sd --42]]
            [~.t '--42']
    ::  literal @sd -42 (negative)
    :-  %string-lit-sd-neg
        :-  [%string [~.sd -42]]
            [~.t '-42']
    ::  literal @rd .~42.42
    :-  %string-lit-rd-pos
        :-  [%string [~.rd .~42.42]]
            [~.t '.~42.42']
    ::  literal @rd .~-24.24
    :-  %string-lit-rd-neg
        :-  [%string [~.rd .~-24.24]]
            [~.t '.~-24.24']
    ::  qualified col1=@ud 42
    :-  %string-qual-col-ud
        :-  [%string str-num-q-col-1]
            [~.t '42']
    ::  qualified col2=@sd --42 (positive)
    :-  %string-qual-col-sd-pos
        :-  [%string str-num-q-col-2]
            [~.t '--42']
    ::  qualified col3=@sd -42 (negative)
    :-  %string-qual-col-sd-neg
        :-  [%string str-num-q-col-3]
            [~.t '-42']
    ::  qualified col4=@rd .~42.42
    :-  %string-qual-col-rd-pos
        :-  [%string str-num-q-col-4]
            [~.t '.~42.42']
    ::  qualified col5=@rd .~-24.24
    :-  %string-qual-col-rd-neg
        :-  [%string str-num-q-col-5]
            [~.t '.~-24.24']
  ==
  ==
::
++  test-string-unqual
  %:  run-scalar-tests
    table-named-ctes
    str-num-unqual-lookup
    str-num-unqual-map-meta
    *(map @tas resolved-scalar)
    str-num-unqual-table-row
    :~
    ::  unqual col6=@ud 42
    :-  %string-unqual-col-ud
        :-  [%string str-num-u-col-6]
            [~.t '42']
    ::  unqual col7=@sd --42
    :-  %string-unqual-col-sd-pos
        :-  [%string str-num-u-col-7]
            [~.t '--42']
    ::  unqual col8=@sd -42
    :-  %string-unqual-col-sd-neg
        :-  [%string str-num-u-col-8]
            [~.t '-42']
    ::  unqual col9=@rd .~42.42
    :-  %string-unqual-col-rd-pos
        :-  [%string str-num-u-col-9]
            [~.t '.~42.42']
    ::  unqual col10=@rd .~-24.24
    :-  %string-unqual-col-rd-neg
        :-  [%string str-num-u-col-10]
            [~.t '.~-24.24']
  ==
  ==
::
::  %string-concat tests
::  STRING-CONCAT(args..., delimiter): joins args with delimiter between each
::  col1='hello', col2='world', col5=@ud 3 (unused)
::
++  test-string-concat-qual
  %:  run-scalar-tests
    table-named-ctes
    qual-lookup
    str-qual-map-meta
    *(map @tas resolved-scalar)
    str-qual-table-row
    :~
    ::  2-item lit + lit-delimiter
    :-  %string-concat-lit-lit-delim
        :-  [%string-concat ~[[~.t 'hello'] [~.t 'world']] [~.t ', ']]
            [~.t 'hello, world']
    ::  3-item lit + lit-delimiter
    :-  %string-concat-lit-lit-lit-delim
        :-  [%string-concat ~[[~.t 'a'] [~.t 'b'] [~.t 'c']] [~.t ',']]
            [~.t 'a,b,c']
    ::  col + lit + lit-delimiter
    :-  %string-concat-col-lit-delim
        :-  [%string-concat ~[str-q-col-1 [~.t 'world']] [~.t ', ']]
            [~.t 'hello, world']
    ::  col + col + lit-delimiter
    :-  %string-concat-col-col-delim
        :-  [%string-concat ~[str-q-col-1 str-q-col-2] [~.t ', ']]
            [~.t 'hello, world']
    ::  col + col + col-delimiter (col1='hello' as delimiter)
    :-  %string-concat-col-col-col-delim
        :-  [%string-concat ~[[~.t 'a'] [~.t 'b']] str-q-col-1]
            [~.t 'ahellob']
  ==
  ==
::
++  test-string-concat-unqual
  %:  run-scalar-tests
    table-named-ctes
    str-unqual-lookup
    str-unqual-map-meta
    *(map @tas resolved-scalar)
    str-unqual-table-row
    :~
    ::  unqual col + lit + lit-delimiter
    :-  %string-concat-unqual-col-lit-delim
        :-  [%string-concat ~[str-u-col-6 [~.t 'world']] [~.t ', ']]
            [~.t 'hello, world']
    ::  unqual col + unqual col + lit-delimiter
    :-  %string-concat-unqual-col-col-delim
        :-  [%string-concat ~[str-u-col-6 str-u-col-7] [~.t ', ']]
            [~.t 'hello, world']
    ::  unqual col + unqual col + unqual col-delimiter
    :-  %string-concat-unqual-col-col-col-delim
        :-  [%string-concat ~[[~.t 'a'] [~.t 'b']] str-u-col-6]
            [~.t 'ahellob']
  ==
  ==
::
::  %stuff tests
::  STUFF(str, start, length, replace): deletes length chars at start, inserts replace
::  col1='hello', col2='world', col5=@ud 3
::
++  test-stuff-qual
  %:  run-scalar-tests
    table-named-ctes
    qual-lookup
    str-qual-map-meta
    *(map @tas resolved-scalar)
    str-qual-table-row
    :~
    ::  all literals: STUFF('hello world', 7, 5, 'there') = 'hello there'
    :-  %stuff-lit-lit-lit-lit
        :-  [%stuff [~.t 'hello world'] [~.ud 7] [~.ud 5] [~.t 'there']]
            [~.t 'hello there']
    ::  STUFF('hello', 2, 3, 'ELL') = 'hELLo'
    :-  %stuff-lit-234-lit
        :-  [%stuff [~.t 'hello'] [~.ud 2] [~.ud 3] [~.t 'ELL']]
            [~.t 'hELLo']
    ::  col-str + lit + lit + lit
    :-  %stuff-col-lit-lit-lit
        :-  [%stuff str-q-col-1 [~.ud 2] [~.ud 3] [~.t 'ELL']]
            [~.t 'hELLo']
    ::  col-str + lit + col-len + lit-replace
    :-  %stuff-col-lit-col-lit
        :-  [%stuff str-q-col-1 [~.ud 2] str-q-col-5 [~.t 'ELL']]
            [~.t 'hELLo']
    ::  col-str + lit + lit + col-replace: STUFF('hello',2,3,'world') = 'hworldo'
    :-  %stuff-col-lit-lit-col
        :-  [%stuff str-q-col-1 [~.ud 2] [~.ud 3] str-q-col-2]
            [~.t 'hworldo']
  ==
  ==
::
++  test-stuff-unqual
  %:  run-scalar-tests
    table-named-ctes
    str-unqual-lookup
    str-unqual-map-meta
    *(map @tas resolved-scalar)
    str-unqual-table-row
    :~
    ::  unqual col-str + lit + lit + lit
    :-  %stuff-unqual-col-lit-lit-lit
        :-  [%stuff str-u-col-6 [~.ud 2] [~.ud 3] [~.t 'ELL']]
            [~.t 'hELLo']
    ::  unqual col-str + lit + col-len + col-replace
    :-  %stuff-unqual-col-lit-col-col
        :-  [%stuff str-u-col-6 [~.ud 2] str-u-col-10 str-u-col-7]
            [~.t 'hworldo']
  ==
  ==
::
::  %substring tests
::  SUBSTRING(str, start, [length]): 1-based index
::  col1='hello', col5=@ud 3
::
++  test-substring-qual
  %:  run-scalar-tests
    table-named-ctes
    qual-lookup
    str-qual-map-meta
    *(map @tas resolved-scalar)
    str-qual-table-row
    :~
    ::  3-param lit: SUBSTRING('hello', 2, 3) = 'ell'
    :-  %substring-3p-lit
        :-  [%substring [~.t 'hello'] [~.ud 2] (some [~.ud 3])]
            [~.t 'ell']
    ::  2-param lit: SUBSTRING('hello', 2) = 'ello'
    :-  %substring-2p-lit
        :-  [%substring [~.t 'hello'] [~.ud 2] ~]
            [~.t 'ello']
    ::  3-param col-str + lit-start + lit-len
    :-  %substring-3p-col-lit-lit
        :-  [%substring str-q-col-1 [~.ud 2] (some [~.ud 3])]
            [~.t 'ell']
    ::  3-param col-str + lit-start + col-len (col5=3)
    :-  %substring-3p-col-lit-col
        :-  [%substring str-q-col-1 [~.ud 2] (some str-q-col-5)]
            [~.t 'ell']
    ::  2-param col-str + lit-start
    :-  %substring-2p-col-lit
        :-  [%substring str-q-col-1 [~.ud 2] ~]
            [~.t 'ello']
  ==
  ==
::
++  test-substring-unqual
  %:  run-scalar-tests
    table-named-ctes
    str-unqual-lookup
    str-unqual-map-meta
    *(map @tas resolved-scalar)
    str-unqual-table-row
    :~
    ::  3-param unqual col-str + lit-start + lit-len
    :-  %substring-unqual-3p-col-lit-lit
        :-  [%substring str-u-col-6 [~.ud 2] (some [~.ud 3])]
            [~.t 'ell']
    ::  3-param unqual col-str + lit-start + col-len
    :-  %substring-unqual-3p-col-lit-col
        :-  [%substring str-u-col-6 [~.ud 2] (some str-u-col-10)]
            [~.t 'ell']
    ::  2-param unqual col-str + lit-start
    :-  %substring-unqual-2p-col-lit
        :-  [%substring str-u-col-6 [~.ud 2] ~]
            [~.t 'ello']
  ==
  ==
::
::  %trim tests
::  TRIM removes leading and trailing whitespace (default) or pattern chars (2-param)
::
++  test-trim-qual
  %:  run-scalar-tests
    table-named-ctes
    qual-lookup
    str-qual-map-meta
    *(map @tas resolved-scalar)
    str-qual-table-row
    :~
    ::  default: lit with leading and trailing spaces
    :-  %trim-default-lit
        :-  [%trim [~.t '  hello  '] ~]
            [~.t 'hello']
    ::  default: qualified col3='  hello  '
    :-  %trim-default-qual-col
        :-  [%trim str-q-col-3 ~]
            [~.t 'hello']
    ::  pattern: lit-str + lit-pattern
    :-  %trim-pattern-lit-lit
        :-  [%trim [~.t 'xxhelloxx'] (some [~.t 'x'])]
            [~.t 'hello']
    ::  pattern: col-str (no surrounding 'x') + lit-pattern — no change
    :-  %trim-pattern-col-lit
        :-  [%trim str-q-col-1 (some [~.t 'x'])]
            [~.t 'hello']
  ==
  ==
::
++  test-trim-qual-pattern-col
  %:  run-scalar-tests
    table-named-ctes
    *qualifier-lookup
    str-trim-qual-map-meta
    *(map @tas resolved-scalar)
    str-trim-qual-table-row
    :~
    ::  col-str + lit-pattern: col1='xxhelloxx', trim 'x' from both sides
    :-  %trim-trim-col-lit
        :-  [%trim str-trim-q-col-1 (some [~.t 'x'])]
            [~.t 'hello']
    ::  lit-str + col-pattern
    :-  %trim-trim-lit-col
        :-  [%trim [~.t 'xxhelloxx'] (some str-trim-q-col-2)]
            [~.t 'hello']
    ::  col-str + col-pattern
    :-  %trim-trim-col-col
        :-  [%trim str-trim-q-col-1 (some str-trim-q-col-2)]
            [~.t 'hello']
  ==
  ==
::
++  test-trim-unqual
  %:  run-scalar-tests
    table-named-ctes
    str-unqual-lookup
    str-unqual-map-meta
    *(map @tas resolved-scalar)
    str-unqual-table-row
    :~
    ::  default: unqual col8='  hello  '
    :-  %trim-default-unqual-col
        :-  [%trim str-u-col-8 ~]
            [~.t 'hello']
    ::  pattern: lit-str + lit-pattern
    :-  %trim-unqual-pattern-lit-lit
        :-  [%trim [~.t 'xxhelloxx'] (some [~.t 'x'])]
            [~.t 'hello']
  ==
  ==
::
++  test-trim-unqual-pattern-col
  %:  run-scalar-tests
    table-named-ctes
    str-trim-unqual-lookup
    str-trim-unqual-map-meta
    *(map @tas resolved-scalar)
    str-trim-unqual-table-row
    :~
    ::  unqual col-str + lit-pattern
    :-  %trim-unqual-trim-col-lit
        :-  [%trim str-trim-u-col-3 (some [~.t 'x'])]
            [~.t 'hello']
    ::  lit-str + unqual col-pattern
    :-  %trim-unqual-trim-lit-col
        :-  [%trim [~.t 'xxhelloxx'] (some str-trim-u-col-4)]
            [~.t 'hello']
    ::  unqual col-str + unqual col-pattern
    :-  %trim-unqual-trim-col-col
        :-  [%trim str-trim-u-col-3 (some str-trim-u-col-4)]
            [~.t 'hello']
  ==
  ==
::
::  %upper tests
::  UPPER(str) converts lowercase to uppercase
::  col1='hello', col4='HELLO'
::
++  test-upper-qual
  %:  run-scalar-tests
    table-named-ctes
    qual-lookup
    str-qual-map-meta
    *(map @tas resolved-scalar)
    str-qual-table-row
    :~
    ::  lit all-lowercase
    :-  %upper-lit
        :-  [%upper [~.t 'hello']]
            [~.t 'HELLO']
    ::  lit mixed case
    :-  %upper-lit-mixed
        :-  [%upper [~.t 'Hello World']]
            [~.t 'HELLO WORLD']
    ::  qualified col1='hello'
    :-  %upper-qual-col
        :-  [%upper str-q-col-1]
            [~.t 'HELLO']
  ==
  ==
::
++  test-upper-unqual
  %:  run-scalar-tests
    table-named-ctes
    str-unqual-lookup
    str-unqual-map-meta
    *(map @tas resolved-scalar)
    str-unqual-table-row
    :~
    ::  unqual col6='hello'
    :-  %upper-unqual-col
        :-  [%upper str-u-col-6]
            [~.t 'HELLO']
  ==
  ==
::
++  test-subtract-time-unqual
  %:  run-scalar-tests
    table-named-ctes
    dt-unqual-lookup
    dt-unqual-map-meta
    *(map @tas resolved-scalar)
    dt-unqual-table-row
    :~
    ::  unqualified col @da - lit @dr
    :-  %subtract-time-unqual-col-da-lit-dr
        :-  [%subtract-time dt-u-col-1 [~.dr ~d1]]
            [~.da ~2026.3.14..10.30.45]
    ::  lit @da - unqualified col @dr
    :-  %subtract-time-unqual-lit-da-col-dr
        :-  [%subtract-time [~.da ~2026.3.15..10.30.45] dt-u-col-2]
            [~.da ~2026.3.14..10.30.45]
    ::  unqualified col @da - unqualified col @dr
    :-  %subtract-time-unqual-col-da-col-dr
        :-  [%subtract-time dt-u-col-1 dt-u-col-2]
            [~.da ~2026.3.14..10.30.45]
    ::  unqualified col @dr - lit @dr: ~d1 - ~d1 = 0
    :-  %subtract-time-unqual-col-dr-lit-dr
        :-  [%subtract-time dt-u-col-2 [~.dr ~d1]]
            [~.dr 0]
    ::  lit @dr - unqualified col @dr: ~d2 - ~d1 = ~d1
    :-  %subtract-time-unqual-lit-dr-col-dr
        :-  [%subtract-time [~.dr ~d2] dt-u-col-2]
            [~.dr ~d1]
    ::  unqualified col @dr - unqualified col @dr: ~d1 - ~d1 = 0
    :-  %subtract-time-unqual-col-dr-col-dr
        :-  [%subtract-time dt-u-col-2 dt-u-col-2]
            [~.dr 0]
    ==
  ==
::
--
