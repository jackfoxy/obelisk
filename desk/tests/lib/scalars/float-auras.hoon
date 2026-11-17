::  @rh, @rs and @rq arithmetic and numeric functions; @rd is tested in
::  arithmetic.hoon and builtin-functions.hoon
::
::  expected results of the iterative functions (+log, +sin, +pow, ...)
::  are bit exact for lib/math.hoon: float operations round toward zero,
::  literals parse to nearest
::
/-  ast=obelisk-ast, *obelisk
/+  *scalars,  *test,  *main,  *test-helpers
::
|%
::
++  qualified-table-1  :*  %qualified-table
                           ship=(some ~sampel-palnet)
                           database=%db2
                           namespace=%dba
                           name=%table1
                           alias=~
                           ==
::
++  q-col-0  [%qualified-column qualified-table-1 %col0 ~]
++  q-col-1  [%qualified-column qualified-table-1 %col1 ~]
++  q-col-2  [%qualified-column qualified-table-1 %col2 ~]
++  q-col-3  [%qualified-column qualified-table-1 %col3 ~]
++  u-col-4  [%unqualified-column %col4 ~]
++  u-col-5  [%unqualified-column %col5 ~]
++  u-col-6  [%unqualified-column %col6 ~]
++  u-col-7  [%unqualified-column %col7 ~]
::
++  qual-lookup
  %-  malt
  %-  limo
  :~  [%col4 ~[qualified-table-1]]
      [%col5 ~[qualified-table-1]]
      [%col6 ~[qualified-table-1]]
      [%col7 ~[qualified-table-1]]
      ==
::
++  qual-map-meta
  |=  aura=@ta
  %-  mk-qualified-map-meta
  :~  :-  qualified-table-1
          %-  addr-columns  :~  [%column %col0 aura 0]
                                [%column %col1 aura 0]
                                [%column %col2 aura 0]
                                [%column %col3 aura 0]
                                ==
      ==
::
++  unqual-map-meta
  |=  aura=@ta
  :-  %unqualified-map-meta
      %-  mk-unqualified-typ-addr-lookup
          %-  addr-columns  :~  [%column %col4 aura 0]
                                [%column %col5 aura 0]
                                [%column %col6 aura 0]
                                [%column %col7 aura 0]
                                ==
::
++  mk-indexed-row
  |=  [kvp=(lest [@tas @])]
  :*  %indexed-row
      key=(turn kvp |=(e=[@tas @] +.e))
      data=(malt (limo kvp))
      ==
::
::  column values 0 1 2 3 0.5 -1.5 4 0
++  rh-row  %-  mk-indexed-row
            :~  [%col0 .~~0]  [%col1 .~~1]    [%col2 .~~2]  [%col3 .~~3]
                [%col4 .~~0.5]  [%col5 .~~-1.5]  [%col6 .~~4]  [%col7 .~~0]
                ==
++  rs-row  %-  mk-indexed-row
            :~  [%col0 .0]  [%col1 .1]    [%col2 .2]  [%col3 .3]
                [%col4 .0.5]  [%col5 .-1.5]  [%col6 .4]  [%col7 .0]
                ==
++  rq-row  %-  mk-indexed-row
            :~  [%col0 .~~~0]  [%col1 .~~~1]    [%col2 .~~~2]  [%col3 .~~~3]
                [%col4 .~~~0.5]  [%col5 .~~~-1.5]  [%col6 .~~~4]  [%col7 .~~~0]
                ==
::
::  %scalar1 evaluates to col3
++  mk-resolved-scalars
  |=  aura=@ta
  ^-  (map @tas resolved-scalar)
  %-  malt
  %-  limo
  :~  :-  %scalar1
          =<  +
          %:  prepare-scalar
                ^-  scalar-function:ast
                :*  %if-then-else
                    if=[n=%eq [n=[~.ud 1] ~ ~] [n=[~.ud 1] ~ ~]]
                    then=q-col-3
                    else=q-col-2
                    ==
                ~
                qual-lookup
                (qual-map-meta aura)
                *(map @tas resolved-scalar)
                (bowl [0 ~2026.4.21])
                eny:(bowl [0 ~2026.4.21])
                ==
      ==
::
::  table flt with float columns a and b of aura, literal prefix pfx
++  init-flt
  |=  [aura=tape pfx=tape]
  ^-  tape
  "CREATE DATABASE db1; CREATE TABLE flt (id @ud, a {aura}, b {aura}) ".
  "PRIMARY KEY (id); INSERT INTO flt VALUES (1, {pfx}1.5, {pfx}2.25) ".
  "(2, {pfx}-3, {pfx}4);"
::
::  @rh
::
++  test-arithmetic-qual-rh
  %:  run-scalar-tests
    ~
    qual-lookup
    (qual-map-meta ~.rh)
    ~
    rh-row
    :~
    :-  %lus-literal-literal
        :-  [%arithmetic %lus [~.rh .~~1.5] [~.rh .~~2.25]]
            [~.rh .~~3.75]
    :-  %lus-col-literal
        :-  [%arithmetic %lus q-col-2 [~.rh .~~0.5]]
            [~.rh .~~2.5]
    :-  %lus-literal-col
        :-  [%arithmetic %lus [~.rh .~~0.5] q-col-3]
            [~.rh .~~3.5]
    :-  %hep-literal-literal
        :-  [%arithmetic %hep [~.rh .~~1.5] [~.rh .~~2.25]]
            [~.rh .~~-0.75]
    :-  %hep-col-col
        :-  [%arithmetic %hep q-col-1 q-col-3]
            [~.rh .~~-2]
    :-  %tar-literal-literal
        :-  [%arithmetic %tar [~.rh .~~1.5] [~.rh .~~-2.5]]
            [~.rh .~~-3.75]
    :-  %tar-col-col
        :-  [%arithmetic %tar q-col-2 q-col-3]
            [~.rh .~~6]
    ::  1/3 rounds toward zero
    :-  %fas-literal-literal
        :-  [%arithmetic %fas [~.rh .~~1] [~.rh .~~3]]
            [~.rh .~~0.3333]
    :-  %fas-col-col
        :-  [%arithmetic %fas q-col-3 q-col-2]
            [~.rh .~~1.5]
    ::  2/3 rounds toward zero
    :-  %fas-literal-col
        :-  [%arithmetic %fas [~.rh .~~2] q-col-3]
            [~.rh .~~0.6665]
    :-  %ket-ud-exponent
        :-  [%arithmetic %ket [~.rh .~~1.5] [~.ud 2]]
            [~.rh .~~2.25]
    :-  %ket-sd-exponent
        :-  [%arithmetic %ket [~.rh .~~1.5] [~.sd --3]]
            [~.rh .~~3.375]
    :-  %ket-col-col
        :-  [%arithmetic %ket q-col-2 q-col-3]
            [~.rh .~~8]
    ::  2^0.5 by +exp and +log
    :-  %ket-fractional-exponent
        :-  [%arithmetic %ket [~.rh .~~2] [~.rh .~~0.5]]
            [~.rh .~~1.412]
    :-  %ket-rq-exponent
        :-  [%arithmetic %ket [~.rh .~~2] [~.rq .~~~3]]
            [~.rh .~~8]
    :-  %ket-negative-base
        :-  [%arithmetic %ket [~.rh .~~-1.5] [~.ud 3]]
            [~.rh .~~-3.375]
    :-  %ket-ud-base
        :-  [%arithmetic %ket [~.ud 2] [~.rh .~~3]]
            [~.ud 8]
    :-  %ket-sd-base
        :-  [%arithmetic %ket [~.sd -2] [~.rh .~~3]]
            [~.sd -8]
    ::  2^0.5 truncates
    :-  %ket-ud-base-fractional
        :-  [%arithmetic %ket [~.ud 2] [~.rh .~~0.5]]
            [~.ud 1]
    ==
  ==
::
++  test-arithmetic-unqual-rh
  %:  run-scalar-tests
    ~
    qual-lookup
    (unqual-map-meta ~.rh)
    ~
    rh-row
    :~
    :-  %lus-col-col
        :-  [%arithmetic %lus u-col-4 u-col-5]
            [~.rh .~~-1]
    :-  %hep-col-col
        :-  [%arithmetic %hep u-col-6 u-col-4]
            [~.rh .~~3.5]
    :-  %tar-col-col
        :-  [%arithmetic %tar u-col-5 u-col-6]
            [~.rh .~~-6]
    :-  %fas-col-col
        :-  [%arithmetic %fas u-col-6 u-col-4]
            [~.rh .~~8]
    ::  x^0 = 1
    :-  %ket-col-col
        :-  [%arithmetic %ket u-col-6 u-col-7]
            [~.rh .~~1]
    ==
  ==
::
++  test-arithmetic-nested-rh
  %:  run-scalar-tests
    ~
    qual-lookup
    (qual-map-meta ~.rh)
    (mk-resolved-scalars ~.rh)
    rh-row
    :~
    ::  (1 + 0.5) * 2
    :-  %nested
        :-  [%arithmetic %tar [%arithmetic %lus q-col-1 [~.rh .~~0.5]] q-col-2]
            [~.rh .~~3]
    ::  scalar1 is col3
    :-  %scalar-name
        :-  [%arithmetic %lus [%scalar-name %scalar1] [~.rh .~~1]]
            [~.rh .~~4]
    ==
  ==
::
++  test-numeric-functions-rh
  %:  run-scalar-tests
    ~
    qual-lookup
    (qual-map-meta ~.rh)
    ~
    rh-row
    :~
    :-  %abs-literal
        :-  [%abs [~.rh .~~-1.5]]
            [~.rh .~~1.5]
    :-  %abs-col
        :-  [%abs q-col-2]
            [~.rh .~~2]
    :-  %sign-negative
        :-  [%sign [~.rh .~~-1.5]]
            [~.rh .~~-1]
    :-  %sign-zero
        :-  [%sign [~.rh .~~0]]
            [~.rh .~~0]
    :-  %sign-col
        :-  [%sign q-col-3]
            [~.rh .~~1]
    :-  %floor-positive
        :-  [%floor [~.rh .~~1.5]]
            [~.rh .~~1]
    :-  %floor-negative
        :-  [%floor [~.rh .~~-1.5]]
            [~.rh .~~-2]
    :-  %floor-col
        :-  [%floor q-col-3]
            [~.rh .~~3]
    :-  %ceiling-positive
        :-  [%ceiling [~.rh .~~1.5]]
            [~.rh .~~2]
    :-  %ceiling-negative
        :-  [%ceiling [~.rh .~~-1.5]]
            [~.rh .~~-1]
    :-  %round-places
        :-  [%round [~.rh .~~1.25] [~.ud 1]]
            [~.rh .~~1.3]
    :-  %round-tens
        :-  [%round [~.rh .~~123.5] [~.sd -1]]
            [~.rh .~~120]
    :-  %round-col
        :-  [%round q-col-2 [~.ud 0]]
            [~.rh .~~2]
    :-  %max-literal
        :-  [%max [~.rh .~~1.5] [~.rh .~~-1.5]]
            [~.rh .~~1.5]
    :-  %max-col
        :-  [%max q-col-2 q-col-3]
            [~.rh .~~3]
    :-  %min-literal
        :-  [%min [~.rh .~~1.5] [~.rh .~~-1.5]]
            [~.rh .~~-1.5]
    :-  %min-col
        :-  [%min q-col-2 q-col-3]
            [~.rh .~~2]
    :-  %sqrt-literal
        :-  [%sqrt [~.rh .~~2.25]]
            [~.rh .~~1.5]
    ::  sqrt(2) rounds toward zero
    :-  %sqrt-col
        :-  [%sqrt q-col-2]
            [~.rh .~~1.414]
    ==
  ==
::
++  test-trig-log-rh
  %:  run-scalar-tests
    ~
    qual-lookup
    (qual-map-meta ~.rh)
    ~
    rh-row
    :~
    :-  %log-one
        :-  [%log [~.rh .~~1] ~]
            [~.rh .~~0]
    :-  %log-col
        :-  [%log q-col-2 ~]
            [~.rh .~~0.6914]
    :-  %sin-zero
        :-  [%sin [~.rh .~~0]]
            [~.rh .~~0]
    :-  %sin-half
        :-  [%sin [~.rh .~~0.5]]
            [~.rh .~~0.4792]
    :-  %cos-zero
        :-  [%cos [~.rh .~~0]]
            [~.rh .~~1]
    :-  %cos-half
        :-  [%cos [~.rh .~~0.5]]
            [~.rh .~~0.8774]
    :-  %tan-half
        :-  [%tan [~.rh .~~0.5]]
            [~.rh .~~0.546]
    ::  pi/2
    :-  %asin-one
        :-  [%asin [~.rh .~~1]]
            [~.rh .~~1.57]
    :-  %asin-half
        :-  [%asin [~.rh .~~0.5]]
            [~.rh .~~0.525]
    :-  %acos-one
        :-  [%acos [~.rh .~~1]]
            [~.rh .~~0]
    :-  %acos-half
        :-  [%acos [~.rh .~~0.5]]
            [~.rh .~~1.051]
    :-  %atan-zero
        :-  [%atan [~.rh .~~0]]
            [~.rh .~~0]
    ::  pi/4
    :-  %atan-col
        :-  [%atan q-col-1]
            [~.rh .~~0.786]
    :-  %atan2-literal
        :-  [%atan2 [~.rh .~~1] [~.rh .~~2]]
            [~.rh .~~0.4646]
    :-  %atan2-ud-x
        :-  [%atan2 [~.rh .~~1] [~.ud 2]]
            [~.rh .~~0.4646]
    :-  %atan2-ud-y
        :-  [%atan2 [~.ud 1] [~.rh .~~2]]
            [~.rh .~~0.4646]
    :-  %degrees-zero
        :-  [%degrees [~.rh .~~0]]
            [~.rh .~~0]
    :-  %degrees-one
        :-  [%degrees [~.rh .~~1]]
            [~.rh .~~57.28]
    ==
  ==
::
++  test-fail-remainder-literal-rh
  %+  expect-fail-message
    'remainder not implemented for @rh'
    |.  %:  prepare-scalar
              ^-  scalar-function:ast
              [%arithmetic %cen [~.rh .~~1] [~.rh .~~2]]
              ~  qual-lookup  (qual-map-meta ~.rh)
              *(map @tas resolved-scalar)
              (bowl [0 ~2026.4.21])
              eny:(bowl [0 ~2026.4.21])
              ==
::
++  test-fail-remainder-col-rh
  =/  fn
    %:  prepare-scalar
          ^-  scalar-function:ast
          [%arithmetic %cen q-col-3 q-col-2]
          ~  qual-lookup  (qual-map-meta ~.rh)
          *(map @tas resolved-scalar)
          (bowl [0 ~2026.4.21])
          eny:(bowl [0 ~2026.4.21])
          ==
  %+  expect-fail-message
    'remainder not implemented for @rh'
    |.  (apply-scalar rh-row +.fn)
::
++  test-fail-div-zero-literal-rh
  %+  expect-fail-message
    'division by zero'
    |.  %:  prepare-scalar
              ^-  scalar-function:ast
              [%arithmetic %fas [~.rh .~~1] [~.rh .~~0]]
              ~  qual-lookup  (qual-map-meta ~.rh)
              *(map @tas resolved-scalar)
              (bowl [0 ~2026.4.21])
              eny:(bowl [0 ~2026.4.21])
              ==
::
++  test-fail-div-negative-zero-literal-rh
  %+  expect-fail-message
    'division by zero'
    |.  %:  prepare-scalar
              ^-  scalar-function:ast
              [%arithmetic %fas [~.rh .~~1] [~.rh .~~0]]
              ~  qual-lookup  (qual-map-meta ~.rh)
              *(map @tas resolved-scalar)
              (bowl [0 ~2026.4.21])
              eny:(bowl [0 ~2026.4.21])
              ==
::
++  test-fail-div-zero-col-rh
  =/  fn
    %:  prepare-scalar
          ^-  scalar-function:ast
          [%arithmetic %fas q-col-1 q-col-0]
          ~  qual-lookup  (qual-map-meta ~.rh)
          *(map @tas resolved-scalar)
          (bowl [0 ~2026.4.21])
          eny:(bowl [0 ~2026.4.21])
          ==
  %+  expect-fail-message
    'division by zero'
    |.  (apply-scalar rh-row +.fn)
::
++  test-fail-ns-conflict-rh
  %+  expect-fail-message
    'number system conflict: ~.rh %lus ~.rd'
    |.  %:  prepare-scalar
              ^-  scalar-function:ast
              [%arithmetic %lus [~.rh .~~1] [~.rd .~1]]
              ~  qual-lookup  (qual-map-meta ~.rh)
              *(map @tas resolved-scalar)
              (bowl [0 ~2026.4.21])
              eny:(bowl [0 ~2026.4.21])
              ==
::
++  test-fail-negative-exponent-rh
  %+  expect-fail-message
    %-  crip  "negative exponent [p=~.rh ".
              "q=48.128] ".
              "not supported"
    |.  %:  prepare-scalar
              ^-  scalar-function:ast
              [%arithmetic %ket [~.rh .~~2] [~.rh .~~-1]]
              ~  qual-lookup  (qual-map-meta ~.rh)
              *(map @tas resolved-scalar)
              (bowl [0 ~2026.4.21])
              eny:(bowl [0 ~2026.4.21])
              ==
::
++  test-fail-log-negative-rh
  %+  expect-fail-message
    'log(.~~-1) is not a number'
    |.  %:  prepare-scalar
              ^-  scalar-function:ast
              [%log [~.rh .~~-1] ~]
              ~  qual-lookup  (qual-map-meta ~.rh)
              *(map @tas resolved-scalar)
              (bowl [0 ~2026.4.21])
              eny:(bowl [0 ~2026.4.21])
              ==
::
++  test-fail-sqrt-negative-rh
  %+  expect-fail-message
    'sqrt(.~~-1) is not a number'
    |.  %:  prepare-scalar
              ^-  scalar-function:ast
              [%sqrt [~.rh .~~-1]]
              ~  qual-lookup  (qual-map-meta ~.rh)
              *(map @tas resolved-scalar)
              (bowl [0 ~2026.4.21])
              eny:(bowl [0 ~2026.4.21])
              ==
::
++  test-fail-atan2-conflict-rh
  %+  expect-fail-message
    'atan2: type conflict: ~.rh vs ~.rd'
    |.  %:  prepare-scalar
              ^-  scalar-function:ast
              [%atan2 [~.rh .~~1] [~.rd .~1]]
              ~  qual-lookup  (qual-map-meta ~.rh)
              *(map @tas resolved-scalar)
              (bowl [0 ~2026.4.21])
              eny:(bowl [0 ~2026.4.21])
              ==
::
++  test-select-rh
  =|  run=@ud
  %-  exec-0-1
  :*  run
      [~2012.4.30 %db1 (init-flt "@rh" ".~~")]
      ::
      :+  ~2012.5.3
          %db1
          "FROM flt WHERE a > .~~0 SELECT id, a + b, a * b, SQRT(b), a ^ 2"
      ::
      :-  %results
          :~  [%action 'SELECT']
              :-  %result-set
                  :~  :-  %vector
                          :~  [%id [~.ud 1]]
                              [%scalar-1 [~.rh .~~3.75]]
                              [%scalar-2 [~.rh .~~3.375]]
                              [%scalar-3 [~.rh .~~1.5]]
                              [%scalar-4 [~.rh .~~2.25]]
                              ==
                      ==
              [%server-time ~2012.5.3]
              [%relation-name 'db1.dbo.flt']
              [%schema-time ~2012.4.30]
              [%data-time ~2012.4.30]
              [%vector-count 1]
              ==
      ==
::
::  @rs
::
++  test-arithmetic-qual-rs
  %:  run-scalar-tests
    ~
    qual-lookup
    (qual-map-meta ~.rs)
    ~
    rs-row
    :~
    :-  %lus-literal-literal
        :-  [%arithmetic %lus [~.rs .1.5] [~.rs .2.25]]
            [~.rs .3.75]
    :-  %lus-col-literal
        :-  [%arithmetic %lus q-col-2 [~.rs .0.5]]
            [~.rs .2.5]
    :-  %lus-literal-col
        :-  [%arithmetic %lus [~.rs .0.5] q-col-3]
            [~.rs .3.5]
    :-  %hep-literal-literal
        :-  [%arithmetic %hep [~.rs .1.5] [~.rs .2.25]]
            [~.rs .-0.75]
    :-  %hep-col-col
        :-  [%arithmetic %hep q-col-1 q-col-3]
            [~.rs .-2]
    :-  %tar-literal-literal
        :-  [%arithmetic %tar [~.rs .1.5] [~.rs .-2.5]]
            [~.rs .-3.75]
    :-  %tar-col-col
        :-  [%arithmetic %tar q-col-2 q-col-3]
            [~.rs .6]
    ::  1/3 rounds toward zero
    :-  %fas-literal-literal
        :-  [%arithmetic %fas [~.rs .1] [~.rs .3]]
            [~.rs .0.3333333]
    :-  %fas-col-col
        :-  [%arithmetic %fas q-col-3 q-col-2]
            [~.rs .1.5]
    ::  2/3 rounds toward zero
    :-  %fas-literal-col
        :-  [%arithmetic %fas [~.rs .2] q-col-3]
            [~.rs .0.6666666]
    :-  %ket-ud-exponent
        :-  [%arithmetic %ket [~.rs .1.5] [~.ud 2]]
            [~.rs .2.25]
    :-  %ket-sd-exponent
        :-  [%arithmetic %ket [~.rs .1.5] [~.sd --3]]
            [~.rs .3.375]
    :-  %ket-col-col
        :-  [%arithmetic %ket q-col-2 q-col-3]
            [~.rs .8]
    ::  2^0.5 by +exp and +log
    :-  %ket-fractional-exponent
        :-  [%arithmetic %ket [~.rs .2] [~.rs .0.5]]
            [~.rs .1.414213]
    :-  %ket-rh-exponent
        :-  [%arithmetic %ket [~.rs .2] [~.rh .~~3]]
            [~.rs .8]
    :-  %ket-negative-base
        :-  [%arithmetic %ket [~.rs .-1.5] [~.ud 3]]
            [~.rs .-3.375]
    :-  %ket-ud-base
        :-  [%arithmetic %ket [~.ud 2] [~.rs .3]]
            [~.ud 8]
    :-  %ket-sd-base
        :-  [%arithmetic %ket [~.sd -2] [~.rs .3]]
            [~.sd -8]
    ::  2^0.5 truncates
    :-  %ket-ud-base-fractional
        :-  [%arithmetic %ket [~.ud 2] [~.rs .0.5]]
            [~.ud 1]
    ==
  ==
::
++  test-arithmetic-unqual-rs
  %:  run-scalar-tests
    ~
    qual-lookup
    (unqual-map-meta ~.rs)
    ~
    rs-row
    :~
    :-  %lus-col-col
        :-  [%arithmetic %lus u-col-4 u-col-5]
            [~.rs .-1]
    :-  %hep-col-col
        :-  [%arithmetic %hep u-col-6 u-col-4]
            [~.rs .3.5]
    :-  %tar-col-col
        :-  [%arithmetic %tar u-col-5 u-col-6]
            [~.rs .-6]
    :-  %fas-col-col
        :-  [%arithmetic %fas u-col-6 u-col-4]
            [~.rs .8]
    ::  x^0 = 1
    :-  %ket-col-col
        :-  [%arithmetic %ket u-col-6 u-col-7]
            [~.rs .1]
    ==
  ==
::
++  test-arithmetic-nested-rs
  %:  run-scalar-tests
    ~
    qual-lookup
    (qual-map-meta ~.rs)
    (mk-resolved-scalars ~.rs)
    rs-row
    :~
    ::  (1 + 0.5) * 2
    :-  %nested
        :-  [%arithmetic %tar [%arithmetic %lus q-col-1 [~.rs .0.5]] q-col-2]
            [~.rs .3]
    ::  scalar1 is col3
    :-  %scalar-name
        :-  [%arithmetic %lus [%scalar-name %scalar1] [~.rs .1]]
            [~.rs .4]
    ==
  ==
::
++  test-numeric-functions-rs
  %:  run-scalar-tests
    ~
    qual-lookup
    (qual-map-meta ~.rs)
    ~
    rs-row
    :~
    :-  %abs-literal
        :-  [%abs [~.rs .-1.5]]
            [~.rs .1.5]
    :-  %abs-col
        :-  [%abs q-col-2]
            [~.rs .2]
    :-  %sign-negative
        :-  [%sign [~.rs .-1.5]]
            [~.rs .-1]
    :-  %sign-zero
        :-  [%sign [~.rs .0]]
            [~.rs .0]
    :-  %sign-col
        :-  [%sign q-col-3]
            [~.rs .1]
    :-  %floor-positive
        :-  [%floor [~.rs .1.5]]
            [~.rs .1]
    :-  %floor-negative
        :-  [%floor [~.rs .-1.5]]
            [~.rs .-2]
    :-  %floor-col
        :-  [%floor q-col-3]
            [~.rs .3]
    :-  %ceiling-positive
        :-  [%ceiling [~.rs .1.5]]
            [~.rs .2]
    :-  %ceiling-negative
        :-  [%ceiling [~.rs .-1.5]]
            [~.rs .-1]
    :-  %round-places
        :-  [%round [~.rs .1.25] [~.ud 1]]
            [~.rs .1.3]
    :-  %round-tens
        :-  [%round [~.rs .123.5] [~.sd -1]]
            [~.rs .120]
    :-  %round-col
        :-  [%round q-col-2 [~.ud 0]]
            [~.rs .2]
    :-  %max-literal
        :-  [%max [~.rs .1.5] [~.rs .-1.5]]
            [~.rs .1.5]
    :-  %max-col
        :-  [%max q-col-2 q-col-3]
            [~.rs .3]
    :-  %min-literal
        :-  [%min [~.rs .1.5] [~.rs .-1.5]]
            [~.rs .-1.5]
    :-  %min-col
        :-  [%min q-col-2 q-col-3]
            [~.rs .2]
    :-  %sqrt-literal
        :-  [%sqrt [~.rs .2.25]]
            [~.rs .1.5]
    ::  sqrt(2) rounds toward zero
    :-  %sqrt-col
        :-  [%sqrt q-col-2]
            [~.rs .1.4142135]
    ==
  ==
::
++  test-trig-log-rs
  %:  run-scalar-tests
    ~
    qual-lookup
    (qual-map-meta ~.rs)
    ~
    rs-row
    :~
    :-  %log-one
        :-  [%log [~.rs .1] ~]
            [~.rs .0]
    :-  %log-col
        :-  [%log q-col-2 ~]
            [~.rs .0.6931469]
    :-  %sin-zero
        :-  [%sin [~.rs .0]]
            [~.rs .0]
    :-  %sin-half
        :-  [%sin [~.rs .0.5]]
            [~.rs .0.4794255]
    :-  %cos-zero
        :-  [%cos [~.rs .0]]
            [~.rs .1]
    :-  %cos-half
        :-  [%cos [~.rs .0.5]]
            [~.rs .0.87758243]
    :-  %tan-half
        :-  [%tan [~.rs .0.5]]
            [~.rs .0.5463025]
    ::  pi/2
    :-  %asin-one
        :-  [%asin [~.rs .1]]
            [~.rs .1.5707964]
    :-  %asin-half
        :-  [%asin [~.rs .0.5]]
            [~.rs .0.52359915]
    :-  %acos-one
        :-  [%acos [~.rs .1]]
            [~.rs .0]
    :-  %acos-half
        :-  [%acos [~.rs .0.5]]
            [~.rs .1.0471988]
    :-  %atan-zero
        :-  [%atan [~.rs .0]]
            [~.rs .0]
    ::  pi/4
    :-  %atan-col
        :-  [%atan q-col-1]
            [~.rs .0.7853988]
    :-  %atan2-literal
        :-  [%atan2 [~.rs .1] [~.rs .2]]
            [~.rs .0.46364787]
    :-  %atan2-ud-x
        :-  [%atan2 [~.rs .1] [~.ud 2]]
            [~.rs .0.46364787]
    :-  %atan2-ud-y
        :-  [%atan2 [~.ud 1] [~.rs .2]]
            [~.rs .0.46364787]
    :-  %degrees-zero
        :-  [%degrees [~.rs .0]]
            [~.rs .0]
    :-  %degrees-one
        :-  [%degrees [~.rs .1]]
            [~.rs .57.295776]
    ==
  ==
::
++  test-fail-remainder-literal-rs
  %+  expect-fail-message
    'remainder not implemented for @rs'
    |.  %:  prepare-scalar
              ^-  scalar-function:ast
              [%arithmetic %cen [~.rs .1] [~.rs .2]]
              ~  qual-lookup  (qual-map-meta ~.rs)
              *(map @tas resolved-scalar)
              (bowl [0 ~2026.4.21])
              eny:(bowl [0 ~2026.4.21])
              ==
::
++  test-fail-remainder-col-rs
  =/  fn
    %:  prepare-scalar
          ^-  scalar-function:ast
          [%arithmetic %cen q-col-3 q-col-2]
          ~  qual-lookup  (qual-map-meta ~.rs)
          *(map @tas resolved-scalar)
          (bowl [0 ~2026.4.21])
          eny:(bowl [0 ~2026.4.21])
          ==
  %+  expect-fail-message
    'remainder not implemented for @rs'
    |.  (apply-scalar rs-row +.fn)
::
++  test-fail-div-zero-literal-rs
  %+  expect-fail-message
    'division by zero'
    |.  %:  prepare-scalar
              ^-  scalar-function:ast
              [%arithmetic %fas [~.rs .1] [~.rs .0]]
              ~  qual-lookup  (qual-map-meta ~.rs)
              *(map @tas resolved-scalar)
              (bowl [0 ~2026.4.21])
              eny:(bowl [0 ~2026.4.21])
              ==
::
++  test-fail-div-negative-zero-literal-rs
  %+  expect-fail-message
    'division by zero'
    |.  %:  prepare-scalar
              ^-  scalar-function:ast
              [%arithmetic %fas [~.rs .1] [~.rs .0]]
              ~  qual-lookup  (qual-map-meta ~.rs)
              *(map @tas resolved-scalar)
              (bowl [0 ~2026.4.21])
              eny:(bowl [0 ~2026.4.21])
              ==
::
++  test-fail-div-zero-col-rs
  =/  fn
    %:  prepare-scalar
          ^-  scalar-function:ast
          [%arithmetic %fas q-col-1 q-col-0]
          ~  qual-lookup  (qual-map-meta ~.rs)
          *(map @tas resolved-scalar)
          (bowl [0 ~2026.4.21])
          eny:(bowl [0 ~2026.4.21])
          ==
  %+  expect-fail-message
    'division by zero'
    |.  (apply-scalar rs-row +.fn)
::
++  test-fail-ns-conflict-rs
  %+  expect-fail-message
    'number system conflict: ~.rs %lus ~.rd'
    |.  %:  prepare-scalar
              ^-  scalar-function:ast
              [%arithmetic %lus [~.rs .1] [~.rd .~1]]
              ~  qual-lookup  (qual-map-meta ~.rs)
              *(map @tas resolved-scalar)
              (bowl [0 ~2026.4.21])
              eny:(bowl [0 ~2026.4.21])
              ==
::
++  test-fail-negative-exponent-rs
  %+  expect-fail-message
    %-  crip  "negative exponent [p=~.rs ".
              "q=3.212.836.864] ".
              "not supported"
    |.  %:  prepare-scalar
              ^-  scalar-function:ast
              [%arithmetic %ket [~.rs .2] [~.rs .-1]]
              ~  qual-lookup  (qual-map-meta ~.rs)
              *(map @tas resolved-scalar)
              (bowl [0 ~2026.4.21])
              eny:(bowl [0 ~2026.4.21])
              ==
::
++  test-fail-log-negative-rs
  %+  expect-fail-message
    'log(.-1) is not a number'
    |.  %:  prepare-scalar
              ^-  scalar-function:ast
              [%log [~.rs .-1] ~]
              ~  qual-lookup  (qual-map-meta ~.rs)
              *(map @tas resolved-scalar)
              (bowl [0 ~2026.4.21])
              eny:(bowl [0 ~2026.4.21])
              ==
::
++  test-fail-sqrt-negative-rs
  %+  expect-fail-message
    'sqrt(.-1) is not a number'
    |.  %:  prepare-scalar
              ^-  scalar-function:ast
              [%sqrt [~.rs .-1]]
              ~  qual-lookup  (qual-map-meta ~.rs)
              *(map @tas resolved-scalar)
              (bowl [0 ~2026.4.21])
              eny:(bowl [0 ~2026.4.21])
              ==
::
++  test-fail-atan2-conflict-rs
  %+  expect-fail-message
    'atan2: type conflict: ~.rs vs ~.rd'
    |.  %:  prepare-scalar
              ^-  scalar-function:ast
              [%atan2 [~.rs .1] [~.rd .~1]]
              ~  qual-lookup  (qual-map-meta ~.rs)
              *(map @tas resolved-scalar)
              (bowl [0 ~2026.4.21])
              eny:(bowl [0 ~2026.4.21])
              ==
::
++  test-select-rs
  =|  run=@ud
  %-  exec-0-1
  :*  run
      [~2012.4.30 %db1 (init-flt "@rs" ".")]
      ::
      :+  ~2012.5.3
          %db1
          "FROM flt WHERE a > .0 SELECT id, a + b, a * b, SQRT(b), a ^ 2"
      ::
      :-  %results
          :~  [%action 'SELECT']
              :-  %result-set
                  :~  :-  %vector
                          :~  [%id [~.ud 1]]
                              [%scalar-1 [~.rs .3.75]]
                              [%scalar-2 [~.rs .3.375]]
                              [%scalar-3 [~.rs .1.5]]
                              [%scalar-4 [~.rs .2.25]]
                              ==
                      ==
              [%server-time ~2012.5.3]
              [%relation-name 'db1.dbo.flt']
              [%schema-time ~2012.4.30]
              [%data-time ~2012.4.30]
              [%vector-count 1]
              ==
      ==
::
::  @rq
::
++  test-arithmetic-qual-rq
  %:  run-scalar-tests
    ~
    qual-lookup
    (qual-map-meta ~.rq)
    ~
    rq-row
    :~
    :-  %lus-literal-literal
        :-  [%arithmetic %lus [~.rq .~~~1.5] [~.rq .~~~2.25]]
            [~.rq .~~~3.75]
    :-  %lus-col-literal
        :-  [%arithmetic %lus q-col-2 [~.rq .~~~0.5]]
            [~.rq .~~~2.5]
    :-  %lus-literal-col
        :-  [%arithmetic %lus [~.rq .~~~0.5] q-col-3]
            [~.rq .~~~3.5]
    :-  %hep-literal-literal
        :-  [%arithmetic %hep [~.rq .~~~1.5] [~.rq .~~~2.25]]
            [~.rq .~~~-0.75]
    :-  %hep-col-col
        :-  [%arithmetic %hep q-col-1 q-col-3]
            [~.rq .~~~-2]
    :-  %tar-literal-literal
        :-  [%arithmetic %tar [~.rq .~~~1.5] [~.rq .~~~-2.5]]
            [~.rq .~~~-3.75]
    :-  %tar-col-col
        :-  [%arithmetic %tar q-col-2 q-col-3]
            [~.rq .~~~6]
    ::  1/3 rounds toward zero
    :-  %fas-literal-literal
        :-  [%arithmetic %fas [~.rq .~~~1] [~.rq .~~~3]]
            [~.rq .~~~0.3333333333333333333333333333333333]
    :-  %fas-col-col
        :-  [%arithmetic %fas q-col-3 q-col-2]
            [~.rq .~~~1.5]
    ::  2/3 rounds toward zero
    :-  %fas-literal-col
        :-  [%arithmetic %fas [~.rq .~~~2] q-col-3]
            [~.rq .~~~0.6666666666666666666666666666666666]
    :-  %ket-ud-exponent
        :-  [%arithmetic %ket [~.rq .~~~1.5] [~.ud 2]]
            [~.rq .~~~2.25]
    :-  %ket-sd-exponent
        :-  [%arithmetic %ket [~.rq .~~~1.5] [~.sd --3]]
            [~.rq .~~~3.375]
    :-  %ket-col-col
        :-  [%arithmetic %ket q-col-2 q-col-3]
            [~.rq .~~~8]
    ::  2^0.5 by +exp and +log
    :-  %ket-fractional-exponent
        :-  [%arithmetic %ket [~.rq .~~~2] [~.rq .~~~0.5]]
            [~.rq .~~~1.4142135623730950488016887242096943]
    :-  %ket-rs-exponent
        :-  [%arithmetic %ket [~.rq .~~~2] [~.rs .3]]
            [~.rq .~~~8]
    :-  %ket-negative-base
        :-  [%arithmetic %ket [~.rq .~~~-1.5] [~.ud 3]]
            [~.rq .~~~-3.375]
    :-  %ket-ud-base
        :-  [%arithmetic %ket [~.ud 2] [~.rq .~~~3]]
            [~.ud 8]
    :-  %ket-sd-base
        :-  [%arithmetic %ket [~.sd -2] [~.rq .~~~3]]
            [~.sd -8]
    ::  2^0.5 truncates
    :-  %ket-ud-base-fractional
        :-  [%arithmetic %ket [~.ud 2] [~.rq .~~~0.5]]
            [~.ud 1]
    ==
  ==
::
++  test-arithmetic-unqual-rq
  %:  run-scalar-tests
    ~
    qual-lookup
    (unqual-map-meta ~.rq)
    ~
    rq-row
    :~
    :-  %lus-col-col
        :-  [%arithmetic %lus u-col-4 u-col-5]
            [~.rq .~~~-1]
    :-  %hep-col-col
        :-  [%arithmetic %hep u-col-6 u-col-4]
            [~.rq .~~~3.5]
    :-  %tar-col-col
        :-  [%arithmetic %tar u-col-5 u-col-6]
            [~.rq .~~~-6]
    :-  %fas-col-col
        :-  [%arithmetic %fas u-col-6 u-col-4]
            [~.rq .~~~8]
    ::  x^0 = 1
    :-  %ket-col-col
        :-  [%arithmetic %ket u-col-6 u-col-7]
            [~.rq .~~~1]
    ==
  ==
::
++  test-arithmetic-nested-rq
  %:  run-scalar-tests
    ~
    qual-lookup
    (qual-map-meta ~.rq)
    (mk-resolved-scalars ~.rq)
    rq-row
    :~
    ::  (1 + 0.5) * 2
    :-  %nested
        :-  [%arithmetic %tar [%arithmetic %lus q-col-1 [~.rq .~~~0.5]] q-col-2]
            [~.rq .~~~3]
    ::  scalar1 is col3
    :-  %scalar-name
        :-  [%arithmetic %lus [%scalar-name %scalar1] [~.rq .~~~1]]
            [~.rq .~~~4]
    ==
  ==
::
++  test-numeric-functions-rq
  %:  run-scalar-tests
    ~
    qual-lookup
    (qual-map-meta ~.rq)
    ~
    rq-row
    :~
    :-  %abs-literal
        :-  [%abs [~.rq .~~~-1.5]]
            [~.rq .~~~1.5]
    :-  %abs-col
        :-  [%abs q-col-2]
            [~.rq .~~~2]
    :-  %sign-negative
        :-  [%sign [~.rq .~~~-1.5]]
            [~.rq .~~~-1]
    :-  %sign-zero
        :-  [%sign [~.rq .~~~0]]
            [~.rq .~~~0]
    :-  %sign-col
        :-  [%sign q-col-3]
            [~.rq .~~~1]
    :-  %floor-positive
        :-  [%floor [~.rq .~~~1.5]]
            [~.rq .~~~1]
    :-  %floor-negative
        :-  [%floor [~.rq .~~~-1.5]]
            [~.rq .~~~-2]
    :-  %floor-col
        :-  [%floor q-col-3]
            [~.rq .~~~3]
    :-  %ceiling-positive
        :-  [%ceiling [~.rq .~~~1.5]]
            [~.rq .~~~2]
    :-  %ceiling-negative
        :-  [%ceiling [~.rq .~~~-1.5]]
            [~.rq .~~~-1]
    :-  %round-places
        :-  [%round [~.rq .~~~1.25] [~.ud 1]]
            [~.rq .~~~1.2999999999999999999999999999999998]
    :-  %round-tens
        :-  [%round [~.rq .~~~123.5] [~.sd -1]]
            [~.rq .~~~120]
    :-  %round-col
        :-  [%round q-col-2 [~.ud 0]]
            [~.rq .~~~2]
    :-  %max-literal
        :-  [%max [~.rq .~~~1.5] [~.rq .~~~-1.5]]
            [~.rq .~~~1.5]
    :-  %max-col
        :-  [%max q-col-2 q-col-3]
            [~.rq .~~~3]
    :-  %min-literal
        :-  [%min [~.rq .~~~1.5] [~.rq .~~~-1.5]]
            [~.rq .~~~-1.5]
    :-  %min-col
        :-  [%min q-col-2 q-col-3]
            [~.rq .~~~2]
    :-  %sqrt-literal
        :-  [%sqrt [~.rq .~~~2.25]]
            [~.rq .~~~1.5]
    ::  sqrt(2) rounds toward zero
    :-  %sqrt-col
        :-  [%sqrt q-col-2]
            [~.rq .~~~1.414213562373095048801688724209698]
    ==
  ==
::
++  test-trig-log-rq
  %:  run-scalar-tests
    ~
    qual-lookup
    (qual-map-meta ~.rq)
    ~
    rq-row
    :~
    :-  %log-one
        :-  [%log [~.rq .~~~1] ~]
            [~.rq .~~~0]
    :-  %log-col
        :-  [%log q-col-2 ~]
            [~.rq .~~~0.6931471805599453094172321214581744]
    :-  %sin-zero
        :-  [%sin [~.rq .~~~0]]
            [~.rq .~~~0]
    :-  %sin-half
        :-  [%sin [~.rq .~~~0.5]]
            [~.rq .~~~0.479425538604203000273287935215571]
    :-  %cos-zero
        :-  [%cos [~.rq .~~~0]]
            [~.rq .~~~1]
    :-  %cos-half
        :-  [%cos [~.rq .~~~0.5]]
            [~.rq .~~~0.8775825618903727161162815826038293]
    :-  %tan-half
        :-  [%tan [~.rq .~~~0.5]]
            [~.rq .~~~0.5463024898437905132551794657802852]
    ::  pi/2
    :-  %asin-one
        :-  [%asin [~.rq .~~~1]]
            [~.rq .~~~1.5707963267948966192313216916397514]
    :-  %asin-half
        :-  [%asin [~.rq .~~~0.5]]
            [~.rq .~~~0.5235987755982988730771072305465868]
    :-  %acos-one
        :-  [%acos [~.rq .~~~1]]
            [~.rq .~~~0]
    :-  %acos-half
        :-  [%acos [~.rq .~~~0.5]]
            [~.rq .~~~1.0471975511965977461542144610931777]
    :-  %atan-zero
        :-  [%atan [~.rq .~~~0]]
            [~.rq .~~~0]
    ::  pi/4
    :-  %atan-col
        :-  [%atan q-col-1]
            [~.rq .~~~0.7853981633974483096156608458198807]
    :-  %atan2-literal
        :-  [%atan2 [~.rq .~~~1] [~.rq .~~~2]]
            [~.rq .~~~0.46364760900080611621425623146121685]
    :-  %atan2-ud-x
        :-  [%atan2 [~.rq .~~~1] [~.ud 2]]
            [~.rq .~~~0.46364760900080611621425623146121685]
    :-  %atan2-ud-y
        :-  [%atan2 [~.ud 1] [~.rq .~~~2]]
            [~.rq .~~~0.46364760900080611621425623146121685]
    :-  %degrees-zero
        :-  [%degrees [~.rq .~~~0]]
            [~.rq .~~~0]
    :-  %degrees-one
        :-  [%degrees [~.rq .~~~1]]
            [~.rq .~~~57.295779513082320876798154814105166]
    ==
  ==
::
++  test-fail-remainder-literal-rq
  %+  expect-fail-message
    'remainder not implemented for @rq'
    |.  %:  prepare-scalar
              ^-  scalar-function:ast
              [%arithmetic %cen [~.rq .~~~1] [~.rq .~~~2]]
              ~  qual-lookup  (qual-map-meta ~.rq)
              *(map @tas resolved-scalar)
              (bowl [0 ~2026.4.21])
              eny:(bowl [0 ~2026.4.21])
              ==
::
++  test-fail-remainder-col-rq
  =/  fn
    %:  prepare-scalar
          ^-  scalar-function:ast
          [%arithmetic %cen q-col-3 q-col-2]
          ~  qual-lookup  (qual-map-meta ~.rq)
          *(map @tas resolved-scalar)
          (bowl [0 ~2026.4.21])
          eny:(bowl [0 ~2026.4.21])
          ==
  %+  expect-fail-message
    'remainder not implemented for @rq'
    |.  (apply-scalar rq-row +.fn)
::
++  test-fail-div-zero-literal-rq
  %+  expect-fail-message
    'division by zero'
    |.  %:  prepare-scalar
              ^-  scalar-function:ast
              [%arithmetic %fas [~.rq .~~~1] [~.rq .~~~0]]
              ~  qual-lookup  (qual-map-meta ~.rq)
              *(map @tas resolved-scalar)
              (bowl [0 ~2026.4.21])
              eny:(bowl [0 ~2026.4.21])
              ==
::
++  test-fail-div-negative-zero-literal-rq
  %+  expect-fail-message
    'division by zero'
    |.  %:  prepare-scalar
              ^-  scalar-function:ast
              [%arithmetic %fas [~.rq .~~~1] [~.rq .~~~0]]
              ~  qual-lookup  (qual-map-meta ~.rq)
              *(map @tas resolved-scalar)
              (bowl [0 ~2026.4.21])
              eny:(bowl [0 ~2026.4.21])
              ==
::
++  test-fail-div-zero-col-rq
  =/  fn
    %:  prepare-scalar
          ^-  scalar-function:ast
          [%arithmetic %fas q-col-1 q-col-0]
          ~  qual-lookup  (qual-map-meta ~.rq)
          *(map @tas resolved-scalar)
          (bowl [0 ~2026.4.21])
          eny:(bowl [0 ~2026.4.21])
          ==
  %+  expect-fail-message
    'division by zero'
    |.  (apply-scalar rq-row +.fn)
::
++  test-fail-ns-conflict-rq
  %+  expect-fail-message
    'number system conflict: ~.rq %lus ~.rd'
    |.  %:  prepare-scalar
              ^-  scalar-function:ast
              [%arithmetic %lus [~.rq .~~~1] [~.rd .~1]]
              ~  qual-lookup  (qual-map-meta ~.rq)
              *(map @tas resolved-scalar)
              (bowl [0 ~2026.4.21])
              eny:(bowl [0 ~2026.4.21])
              ==
::
++  test-fail-negative-exponent-rq
  %+  expect-fail-message
    %-  crip  "negative exponent [p=~.rq ".
              "q=255.206.582.893.845.312.769.902.425.077.496.938.496] ".
              "not supported"
    |.  %:  prepare-scalar
              ^-  scalar-function:ast
              [%arithmetic %ket [~.rq .~~~2] [~.rq .~~~-1]]
              ~  qual-lookup  (qual-map-meta ~.rq)
              *(map @tas resolved-scalar)
              (bowl [0 ~2026.4.21])
              eny:(bowl [0 ~2026.4.21])
              ==
::
++  test-fail-log-negative-rq
  %+  expect-fail-message
    'log(.~~~-1) is not a number'
    |.  %:  prepare-scalar
              ^-  scalar-function:ast
              [%log [~.rq .~~~-1] ~]
              ~  qual-lookup  (qual-map-meta ~.rq)
              *(map @tas resolved-scalar)
              (bowl [0 ~2026.4.21])
              eny:(bowl [0 ~2026.4.21])
              ==
::
++  test-fail-sqrt-negative-rq
  %+  expect-fail-message
    'sqrt(.~~~-1) is not a number'
    |.  %:  prepare-scalar
              ^-  scalar-function:ast
              [%sqrt [~.rq .~~~-1]]
              ~  qual-lookup  (qual-map-meta ~.rq)
              *(map @tas resolved-scalar)
              (bowl [0 ~2026.4.21])
              eny:(bowl [0 ~2026.4.21])
              ==
::
++  test-fail-atan2-conflict-rq
  %+  expect-fail-message
    'atan2: type conflict: ~.rq vs ~.rd'
    |.  %:  prepare-scalar
              ^-  scalar-function:ast
              [%atan2 [~.rq .~~~1] [~.rd .~1]]
              ~  qual-lookup  (qual-map-meta ~.rq)
              *(map @tas resolved-scalar)
              (bowl [0 ~2026.4.21])
              eny:(bowl [0 ~2026.4.21])
              ==
::
++  test-select-rq
  =|  run=@ud
  %-  exec-0-1
  :*  run
      [~2012.4.30 %db1 (init-flt "@rq" ".~~~")]
      ::
      :+  ~2012.5.3
          %db1
          "FROM flt WHERE a > .~~~0 SELECT id, a + b, a * b, SQRT(b), a ^ 2"
      ::
      :-  %results
          :~  [%action 'SELECT']
              :-  %result-set
                  :~  :-  %vector
                          :~  [%id [~.ud 1]]
                              [%scalar-1 [~.rq .~~~3.75]]
                              [%scalar-2 [~.rq .~~~3.375]]
                              [%scalar-3 [~.rq .~~~1.5]]
                              [%scalar-4 [~.rq .~~~2.25]]
                              ==
                      ==
              [%server-time ~2012.5.3]
              [%relation-name 'db1.dbo.flt']
              [%schema-time ~2012.4.30]
              [%data-time ~2012.4.30]
              [%vector-count 1]
              ==
      ==
::
--
