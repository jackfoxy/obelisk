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
::  @sd encoding: positive n → atom 2n, negative n → atom 2|n|-1
::    atom 5 = @sd -3,  atom 4 = @sd --2,  atom 6 = @sd --3 (abs of -3)
::  0xbff0.0000.0000.0000 = @rd -1.0,  0x4000.0000.0000.0000 = @rd 2.0
::  0x3ff0.0000.0000.0000 = @rd 1.0
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
                        :~  [%col1 5]                        ::  @sd -3
                            [%col2 4]                        ::  @sd --2
                            [%col3 0xbff0.0000.0000.0000]    ::  @rd -1.0
                            [%col4 0x4000.0000.0000.0000]    ::  @rd 2.0
                            [%col5 5]                        ::  @ud 5
                        ==
::
::  unqualified: col4=@sd neg, col5=@sd pos, col6=@rd neg, col7=@rd pos, col8=@ud
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
                          :~  [%col4 5]                      ::  @sd -3
                              [%col5 4]                      ::  @sd --2
                              [%col6 0xbff0.0000.0000.0000]  ::  @rd -1.0
                              [%col7 0x4000.0000.0000.0000]  ::  @rd 2.0
                              [%col8 8]                      ::  @ud 8
                          ==
::
::  %sign test helpers
::  @sd: atom 0 = --0 (zero), atom 1 = -1, atom 2 = --1
::  @rd: atom 0 = .~0,  0xbff0.0000.0000.0000 = .~-1,  0x3ff0.0000.0000.0000 = .~1
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
                         :~  [%col1 0]                        ::  @sd --0 (zero)
                             [%col2 1]                        ::  @sd -1
                             [%col3 2]                        ::  @sd --1
                             [%col4 0]                        ::  @rd .~0
                             [%col5 0xbff0.0000.0000.0000]    ::  @rd .~-1
                             [%col6 0x3ff0.0000.0000.0000]    ::  @rd .~1
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
                           :~  [%col1 0]                      ::  @sd --0 (zero)
                               [%col2 1]                      ::  @sd -1
                               [%col3 2]                      ::  @sd --1
                               [%col4 0]                      ::  @rd .~0
                               [%col5 0xbff0.0000.0000.0000]  ::  @rd .~-1
                               [%col6 0x3ff0.0000.0000.0000]  ::  @rd .~1
                               [%col7 0]                      ::  @ud 0
                               [%col8 1]                      ::  @ud 1
                           ==
::
::  %sqrt test helpers
::  @rd: 0x3ff0.0000.0000.0000 = .~1, 0x4000.0000.0000.0000 = .~2, 0x4010.0000.0000.0000 = .~4
::  @sd: atom 0 = --0, atom 2 = --1, atom 4 = --2, atom 8 = --4
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
                             [%col2 0x3ff0.0000.0000.0000]    ::  @rd 1.0
                             [%col3 0x4010.0000.0000.0000]    ::  @rd 4.0
                             [%col4 0]                        ::  @sd --0
                             [%col5 2]                        ::  @sd --1
                             [%col6 8]                        ::  @sd --4
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
                               [%col2 0x3ff0.0000.0000.0000]  ::  @rd 1.0
                               [%col3 0x4010.0000.0000.0000]  ::  @rd 4.0
                               [%col4 0]                      ::  @sd --0
                               [%col5 2]                      ::  @sd --1
                               [%col6 8]                      ::  @sd --4
                               [%col7 0]                      ::  @ud 0
                               [%col8 1]                      ::  @ud 1
                               [%col9 4]                      ::  @ud 4
                           ==
::
::  %round test helpers
::  @rd: 0x3ff0.0000.0000.0000 = .~1, 0x4000.0000.0000.0000 = .~2
::  @sd: atom 0 = --0, atom 2 = --1, atom 4 = --2
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
                              [%col2 0x3ff0.0000.0000.0000]    ::  @rd 1.0
                              [%col3 0x4000.0000.0000.0000]    ::  @rd 2.0
                              [%col4 0]                        ::  @sd --0
                              [%col5 2]                        ::  @sd --1
                              [%col6 4]                        ::  @sd --2
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
                                [%col2 0x3ff0.0000.0000.0000]  ::  @rd 1.0
                                [%col3 0x4000.0000.0000.0000]  ::  @rd 2.0
                                [%col4 0]                      ::  @sd --0
                                [%col5 2]                      ::  @sd --1
                                [%col6 4]                      ::  @sd --2
                                [%col7 0]                      ::  @ud 0
                                [%col8 1]                      ::  @ud 1
                                [%col9 2]                      ::  @ud 2
                            ==
::
::  %floor test helpers
::  @rd: 0x3ff8.0000.0000.0000 = .~1.5, 0xbff8.0000.0000.0000 = .~-1.5
::  floor(1.5) = 1.0 = 0x3ff0..., floor(-1.5) = -2.0 = 0xc000...
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
                              [%col2 0x3ff8.0000.0000.0000]    ::  @rd 1.5
                              [%col3 0xbff8.0000.0000.0000]    ::  @rd -1.5
                              [%col4 0]                        ::  @sd --0
                              [%col5 2]                        ::  @sd --1
                              [%col6 1]                        ::  @sd -1
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
                                [%col2 0x3ff8.0000.0000.0000]  ::  @rd 1.5
                                [%col3 0xbff8.0000.0000.0000]  ::  @rd -1.5
                                [%col4 0]                      ::  @sd --0
                                [%col5 2]                      ::  @sd --1
                                [%col6 1]                      ::  @sd -1
                                [%col7 0]                      ::  @ud 0
                                [%col8 1]                      ::  @ud 1
                                [%col9 2]                      ::  @ud 2
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
                                      then=[~.ud 4]
                                      else=[~.ud 5]
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
++  test-abs-qual
  %:  run-scalar-tests
    table-named-ctes
    qual-lookup
    abs-qual-map-meta
    *(map @tas resolved-scalar)
    abs-qual-table-row
    :~
    :-  %abs-literal-sd-neg
    :*  [%abs [~.sd -1]]        ::  abs(@sd -1) = @sd --1 = atom 2
      [~.sd --1]
    ==
    :-  %abs-literal-sd-pos
    :*  [%abs [~.sd --1]]         ::  abs(@sd --1) = @sd --1 = atom 2
      [~.sd --1]
    ==
    :-  %abs-literal-ud
    :*  [%abs [~.ud 5]]
      [~.ud 5]
    ==
    :-  %abs-literal-rd-neg
    :*  [%abs [~.rd .~-1]]  ::  abs(@rd -1.0) = @rd 1.0
      [~.rd .~1]
    ==
    :-  %abs-literal-rd-pos
    :*  [%abs [~.rd .~1]]  ::  abs(@rd 1.0) = @rd 1.0
      [~.rd .~1]
    ==
    :-  %abs-qual-sd-neg
    :*  [%abs q-col-1]          ::  abs(@sd -3) = @sd --3 = atom 6
      [~.sd --3]
    ==
    :-  %abs-qual-sd-pos
    :*  [%abs q-col-2]          ::  abs(@sd --2) = @sd --2 = atom 4
      [~.sd --2]
    ==
    :-  %abs-qual-rd-neg
    :*  [%abs q-col-3]          ::  abs(@rd -1.0) = @rd 1.0
      [~.rd .~1]
    ==
    :-  %abs-qual-rd-pos
    :*  [%abs abs-q-col-4]      ::  abs(@rd 2.0) = @rd 2.0
      [~.rd .~2]
    ==
    :-  %abs-qual-ud
    :*  [%abs abs-q-col-5]      ::  abs(@ud 5) = @ud 5
      [~.ud 5]
    ==
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
    :-  %abs-unqual-sd-neg
    :*  [%abs u-col-4]          ::  abs(@sd -3) = @sd --3 = atom 6
      [~.sd --3]
    ==
    :-  %abs-unqual-sd-pos
    :*  [%abs u-col-5]          ::  abs(@sd --2) = @sd --2 = atom 4
      [~.sd --2]
    ==
    :-  %abs-unqual-rd-neg
    :*  [%abs u-col-6]          ::  abs(@rd -1.0) = @rd 1.0
      [~.rd .~1]
    ==
    :-  %abs-unqual-rd-pos
    :*  [%abs u-col-7]          ::  abs(@rd 2.0) = @rd 2.0
      [~.rd .~2]
    ==
    :-  %abs-unqual-ud
    :*  [%abs u-col-8]          ::  abs(@ud 8) = @ud 8
      [~.ud 8]
    ==
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
    :*  [%sign [~.sd --0]]    [~.sd --0]    ==
    :-  %sign-literal-sd-neg
    :*  [%sign [~.sd -1]]    [~.sd -1]    ==  ::  sign(@sd -1) = @sd -1
    :-  %sign-literal-sd-pos
    :*  [%sign [~.sd --1]]    [~.sd --1]    ==  ::  sign(@sd --1) = @sd --1
    :-  %sign-literal-rd-zero
    :*  [%sign [~.rd .~0]]    [~.rd .~0]    ==
    :-  %sign-literal-rd-neg
    :*  [%sign [~.rd .~-1]]  [~.rd .~-1]  ==
    :-  %sign-literal-rd-pos
    :*  [%sign [~.rd .~1]]  [~.rd .~1]  ==
    :-  %sign-literal-ud-zero
    :*  [%sign [~.ud 0]]    [~.ud 0]    ==
    :-  %sign-literal-ud-pos
    :*  [%sign [~.ud 1]]    [~.ud 1]    ==
    :-  %sign-qual-sd-zero
    :*  [%sign q-col-1]       [~.sd --0]  ==
    :-  %sign-qual-sd-neg
    :*  [%sign q-col-2]       [~.sd -1]  ==  ::  sign(@sd -1) = @sd -1
    :-  %sign-qual-sd-pos
    :*  [%sign q-col-3]       [~.sd --1]  ==  ::  sign(@sd --1) = @sd --1
    :-  %sign-qual-rd-zero
    :*  [%sign sign-q-col-4]  [~.rd .~0]  ==
    :-  %sign-qual-rd-neg
    :*  [%sign sign-q-col-5]  [~.rd .~-1]  ==
    :-  %sign-qual-rd-pos
    :*  [%sign sign-q-col-6]  [~.rd .~1]  ==
    :-  %sign-qual-ud-zero
    :*  [%sign sign-q-col-7]  [~.ud 0]  ==
    :-  %sign-qual-ud-pos
    :*  [%sign sign-q-col-8]  [~.ud 1]  ==
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
    :*  [%sign sign-u-col-1]  [~.sd --0]  ==
    :-  %sign-unqual-sd-neg
    :*  [%sign sign-u-col-2]  [~.sd -1]  ==  ::  sign(@sd -1) = @sd -1
    :-  %sign-unqual-sd-pos
    :*  [%sign sign-u-col-3]  [~.sd --1]  ==  ::  sign(@sd --1) = @sd --1
    :-  %sign-unqual-rd-zero
    :*  [%sign u-col-4]       [~.rd .~0]  ==
    :-  %sign-unqual-rd-neg
    :*  [%sign u-col-5]       [~.rd .~-1]  ==
    :-  %sign-unqual-rd-pos
    :*  [%sign u-col-6]       [~.rd .~1]  ==
    :-  %sign-unqual-ud-zero
    :*  [%sign u-col-7]       [~.ud 0]  ==
    :-  %sign-unqual-ud-pos
    :*  [%sign u-col-8]       [~.ud 1]  ==
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
    :*  [%sqrt [~.rd .~0]]  [~.rd .~0]  ==
    :-  %sqrt-literal-rd-one  ::  sqrt(@rd 1.0) = 1.0
    :*  [%sqrt [~.rd .~1]]  [~.rd .~1]  ==
    :-  %sqrt-literal-rd-four  ::  sqrt(@rd 4.0) = 2.0
    :*  [%sqrt [~.rd .~4]]  [~.rd .~2]  ==
    :-  %sqrt-literal-sd-zero
    :*  [%sqrt [~.sd --0]]  [~.sd --0]  ==
    :-  %sqrt-literal-sd-one  ::  sqrt(@sd --1) = --1
    :*  [%sqrt [~.sd --1]]  [~.sd --1]  ==
    :-  %sqrt-literal-sd-four  ::  sqrt(@sd --4) = --2
    :*  [%sqrt [~.sd --4]]  [~.sd --2]  ==
    :-  %sqrt-literal-ud-zero
    :*  [%sqrt [~.ud 0]]  [~.ud 0]  ==
    :-  %sqrt-literal-ud-one
    :*  [%sqrt [~.ud 1]]  [~.ud 1]  ==
    :-  %sqrt-literal-ud-four  ::  sqrt(@ud 4) = 2
    :*  [%sqrt [~.ud 4]]  [~.ud 2]  ==
    :-  %sqrt-qual-rd-zero
    :*  [%sqrt sqrt-q-col-1]  [~.rd .~0]  ==
    :-  %sqrt-qual-rd-one
    :*  [%sqrt sqrt-q-col-2]  [~.rd .~1]  ==
    :-  %sqrt-qual-rd-four  ::  sqrt(@rd 4.0) = 2.0
    :*  [%sqrt sqrt-q-col-3]  [~.rd .~2]  ==
    :-  %sqrt-qual-sd-zero
    :*  [%sqrt sqrt-q-col-4]  [~.sd --0]  ==
    :-  %sqrt-qual-sd-one
    :*  [%sqrt sqrt-q-col-5]  [~.sd --1]  ==
    :-  %sqrt-qual-sd-four  ::  sqrt(@sd --4) = --2
    :*  [%sqrt sqrt-q-col-6]  [~.sd --2]  ==
    :-  %sqrt-qual-ud-zero
    :*  [%sqrt sqrt-q-col-7]  [~.ud 0]  ==
    :-  %sqrt-qual-ud-one
    :*  [%sqrt sqrt-q-col-8]  [~.ud 1]  ==
    :-  %sqrt-qual-ud-four  ::  sqrt(@ud 4) = 2
    :*  [%sqrt sqrt-q-col-9]  [~.ud 2]  ==
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
    :*  [%sqrt sqrt-u-col-1]  [~.rd .~0]  ==
    :-  %sqrt-unqual-rd-one
    :*  [%sqrt sqrt-u-col-2]  [~.rd .~1]  ==
    :-  %sqrt-unqual-rd-four  ::  sqrt(@rd 4.0) = 2.0
    :*  [%sqrt sqrt-u-col-3]  [~.rd .~2]  ==
    :-  %sqrt-unqual-sd-zero
    :*  [%sqrt sqrt-u-col-4]  [~.sd --0]  ==
    :-  %sqrt-unqual-sd-one
    :*  [%sqrt sqrt-u-col-5]  [~.sd --1]  ==
    :-  %sqrt-unqual-sd-four  ::  sqrt(@sd --4) = --2
    :*  [%sqrt sqrt-u-col-6]  [~.sd --2]  ==
    :-  %sqrt-unqual-ud-zero
    :*  [%sqrt sqrt-u-col-7]  [~.ud 0]  ==
    :-  %sqrt-unqual-ud-one
    :*  [%sqrt sqrt-u-col-8]  [~.ud 1]  ==
    :-  %sqrt-unqual-ud-four  ::  sqrt(@ud 4) = 2
    :*  [%sqrt sqrt-u-col-9]  [~.ud 2]  ==
    ==
  ==
::
::  %round tests
::
++  test-round-qual
  %:  run-scalar-tests
    table-named-ctes
    qual-lookup
    round-qual-map-meta
    *(map @tas resolved-scalar)
    round-qual-table-row
    :~
    :-  %round-literal-rd-zero
    :*  [%round [~.rd .~0] [~.ud 0] ~]  [~.rd .~0]  ==
    :-  %round-literal-rd-one  ::  round(@rd 1.0, 0) = 1.0
    :*  [%round [~.rd .~1] [~.ud 0] ~]
      [~.rd .~1]
    ==
    :-  %round-literal-rd-two  ::  round(@rd 2.0, 0) = 2.0
    :*  [%round [~.rd .~2] [~.ud 0] ~]
      [~.rd .~2]
    ==
    :-  %round-literal-sd-zero
    :*  [%round [~.sd --0] [~.ud 0] ~]  [~.sd --0]  ==
    :-  %round-literal-sd-one
    :*  [%round [~.sd --1] [~.ud 0] ~]  [~.sd --1]  ==
    :-  %round-literal-sd-two
    :*  [%round [~.sd --2] [~.ud 0] ~]  [~.sd --2]  ==
    :-  %round-literal-ud-zero
    :*  [%round [~.ud 0] [~.ud 0] ~]  [~.ud 0]  ==
    :-  %round-literal-ud-one
    :*  [%round [~.ud 1] [~.ud 0] ~]  [~.ud 1]  ==
    :-  %round-literal-ud-two
    :*  [%round [~.ud 2] [~.ud 0] ~]  [~.ud 2]  ==
    :-  %round-qual-rd-zero
    :*  [%round round-q-col-1 [~.ud 0] ~]  [~.rd .~0]  ==
    :-  %round-qual-rd-one
    :*  [%round round-q-col-2 [~.ud 0] ~]  [~.rd .~1]  ==
    :-  %round-qual-rd-two  ::  round(@rd 2.0, 0) = 2.0
    :*  [%round round-q-col-3 [~.ud 0] ~]  [~.rd .~2]  ==
    :-  %round-qual-sd-zero
    :*  [%round round-q-col-4 [~.ud 0] ~]  [~.sd --0]  ==
    :-  %round-qual-sd-one
    :*  [%round round-q-col-5 [~.ud 0] ~]  [~.sd --1]  ==
    :-  %round-qual-sd-two
    :*  [%round round-q-col-6 [~.ud 0] ~]  [~.sd --2]  ==
    :-  %round-qual-ud-zero
    :*  [%round round-q-col-7 [~.ud 0] ~]  [~.ud 0]  ==
    :-  %round-qual-ud-one
    :*  [%round round-q-col-8 [~.ud 0] ~]  [~.ud 1]  ==
    :-  %round-qual-ud-two
    :*  [%round round-q-col-9 [~.ud 0] ~]  [~.ud 2]  ==
    ==
  ==
::
++  test-round-unqual
  %:  run-scalar-tests
    table-named-ctes
    round-unqual-lookup
    round-unqual-map-meta
    *(map @tas resolved-scalar)
    round-unqual-table-row
    :~
    :-  %round-unqual-rd-zero
    :*  [%round round-u-col-1 [~.ud 0] ~]  [~.rd .~0]  ==
    :-  %round-unqual-rd-one
    :*  [%round round-u-col-2 [~.ud 0] ~]  [~.rd .~1]  ==
    :-  %round-unqual-rd-two  ::  round(@rd 2.0, 0) = 2.0
    :*  [%round round-u-col-3 [~.ud 0] ~]  [~.rd .~2]  ==
    :-  %round-unqual-sd-zero
    :*  [%round round-u-col-4 [~.ud 0] ~]  [~.sd --0]  ==
    :-  %round-unqual-sd-one
    :*  [%round round-u-col-5 [~.ud 0] ~]  [~.sd --1]  ==
    :-  %round-unqual-sd-two
    :*  [%round round-u-col-6 [~.ud 0] ~]  [~.sd --2]  ==
    :-  %round-unqual-ud-zero
    :*  [%round round-u-col-7 [~.ud 0] ~]  [~.ud 0]  ==
    :-  %round-unqual-ud-one
    :*  [%round round-u-col-8 [~.ud 0] ~]  [~.ud 1]  ==
    :-  %round-unqual-ud-two
    :*  [%round round-u-col-9 [~.ud 0] ~]  [~.ud 2]  ==
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
    :*  [%floor [~.rd .~0]]  [~.rd .~0]  ==
    :-  %floor-literal-rd-one-five  ::  floor(@rd 1.5) = 1.0
    :*  [%floor [~.rd .~1.5]]  [~.rd .~1]  ==
    :-  %floor-literal-rd-neg-one-five  ::  floor(@rd -1.5) = -2.0
    :*  [%floor [~.rd .~-1.5]]  [~.rd .~-2]  ==
    :-  %floor-literal-sd-zero
    :*  [%floor [~.sd --0]]  [~.sd --0]  ==
    :-  %floor-literal-sd-one
    :*  [%floor [~.sd --1]]  [~.sd --1]  ==
    :-  %floor-literal-sd-neg
    :*  [%floor [~.sd -1]]  [~.sd -1]  ==
    :-  %floor-literal-ud-zero
    :*  [%floor [~.ud 0]]  [~.ud 0]  ==
    :-  %floor-literal-ud-one
    :*  [%floor [~.ud 1]]  [~.ud 1]  ==
    :-  %floor-literal-ud-two
    :*  [%floor [~.ud 2]]  [~.ud 2]  ==
    :-  %floor-qual-rd-zero
    :*  [%floor floor-q-col-1]  [~.rd .~0]  ==
    :-  %floor-qual-rd-one-five  ::  floor(@rd 1.5) = 1.0
    :*  [%floor floor-q-col-2]  [~.rd .~1]  ==
    :-  %floor-qual-rd-neg-one-five  ::  floor(@rd -1.5) = -2.0
    :*  [%floor floor-q-col-3]  [~.rd .~-2]  ==
    :-  %floor-qual-sd-zero
    :*  [%floor floor-q-col-4]  [~.sd --0]  ==
    :-  %floor-qual-sd-one
    :*  [%floor floor-q-col-5]  [~.sd --1]  ==
    :-  %floor-qual-sd-neg
    :*  [%floor floor-q-col-6]  [~.sd -1]  ==
    :-  %floor-qual-ud-zero
    :*  [%floor floor-q-col-7]  [~.ud 0]  ==
    :-  %floor-qual-ud-one
    :*  [%floor floor-q-col-8]  [~.ud 1]  ==
    :-  %floor-qual-ud-two
    :*  [%floor floor-q-col-9]  [~.ud 2]  ==
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
    :*  [%floor floor-u-col-1]  [~.rd .~0]  ==
    :-  %floor-unqual-rd-one-five  ::  floor(@rd 1.5) = 1.0
    :*  [%floor floor-u-col-2]  [~.rd .~1]  ==
    :-  %floor-unqual-rd-neg-one-five  ::  floor(@rd -1.5) = -2.0
    :*  [%floor floor-u-col-3]  [~.rd .~-2]  ==
    :-  %floor-unqual-sd-zero
    :*  [%floor floor-u-col-4]  [~.sd --0]  ==
    :-  %floor-unqual-sd-one
    :*  [%floor floor-u-col-5]  [~.sd --1]  ==
    :-  %floor-unqual-sd-neg
    :*  [%floor floor-u-col-6]  [~.sd -1]  ==
    :-  %floor-unqual-ud-zero
    :*  [%floor floor-u-col-7]  [~.ud 0]  ==
    :-  %floor-unqual-ud-one
    :*  [%floor floor-u-col-8]  [~.ud 1]  ==
    :-  %floor-unqual-ud-two
    :*  [%floor floor-u-col-9]  [~.ud 2]  ==
    ==
  ==
::
--
