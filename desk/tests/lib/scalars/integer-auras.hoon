::  @sb, @sx, @sv, @sw (signed) and @ub, @ux, @uv, @uw (unsigned)
::  arithmetic and numeric functions; @sd and @ud are tested in
::  arithmetic.hoon and builtin-functions.hoon
::
::  signed auras share @sd semantics, unsigned auras @ud semantics, so
::  each aura runs the same parameterized tests
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
::  signed column values 0 1 2 3 5 -7 4 0
++  s-row  %-  mk-indexed-row
           :~  [%col0 --0]  [%col1 --1]  [%col2 --2]  [%col3 --3]
               [%col4 --5]  [%col5 -7]   [%col6 --4]  [%col7 --0]
               ==
::
::  unsigned column values 0 1 2 3 5 7 4 0
++  u-row  %-  mk-indexed-row
           :~  [%col0 0]  [%col1 1]  [%col2 2]  [%col3 3]
               [%col4 5]  [%col5 7]  [%col6 4]  [%col7 0]
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
::  prepare scalar fn of aura's columns; crashes at prepare time
++  prep
  |=  [aura=@ta fn=scalar-function:ast]
  ^-  [@uvJ resolved-scalar]
  %:  prepare-scalar
        fn
        ~
        qual-lookup
        (qual-map-meta aura)
        *(map @tas resolved-scalar)
        (bowl [0 ~2026.4.21])
        eny:(bowl [0 ~2026.4.21])
        ==
::
::  signed
::
++  signed-arithmetic
  |=  aura=@ta
  ^-  tang
  %+  weld
    %:  run-scalar-tests
      ~
      qual-lookup
      (qual-map-meta aura)
      (mk-resolved-scalars aura)
      s-row
      :~
      :-  %lus-literal-literal
          :-  [%arithmetic %lus [aura --3] [aura -5]]
              [aura -2]
      :-  %lus-col-col
          :-  [%arithmetic %lus q-col-2 q-col-3]
              [aura --5]
      :-  %hep-literal-literal
          :-  [%arithmetic %hep [aura --3] [aura --5]]
              [aura -2]
      :-  %hep-col-literal
          :-  [%arithmetic %hep q-col-1 [aura -2]]
              [aura --3]
      :-  %tar-literal-literal
          :-  [%arithmetic %tar [aura -2] [aura --3]]
              [aura -6]
      :-  %tar-col-col
          :-  [%arithmetic %tar q-col-2 q-col-3]
              [aura --6]
      ::  truncates toward zero
      :-  %fas-literal-literal
          :-  [%arithmetic %fas [aura -7] [aura --2]]
              [aura -3]
      :-  %fas-col-col
          :-  [%arithmetic %fas q-col-3 q-col-2]
              [aura --1]
      :-  %cen-literal-literal
          :-  [%arithmetic %cen [aura -7] [aura --2]]
              [aura -1]
      :-  %cen-col-col
          :-  [%arithmetic %cen q-col-3 q-col-2]
              [aura --1]
      :-  %ket-ud-exponent
          :-  [%arithmetic %ket [aura --2] [~.ud 3]]
              [aura --8]
      :-  %ket-negative-base
          :-  [%arithmetic %ket [aura -2] [~.ud 3]]
              [aura -8]
      :-  %ket-col-col
          :-  [%arithmetic %ket q-col-2 q-col-3]
              [aura --8]
      :-  %ket-ux-exponent
          :-  [%arithmetic %ket [aura --2] [~.ux 0x3]]
              [aura --8]
      ::  2^0.5 truncates
      :-  %ket-rd-exponent
          :-  [%arithmetic %ket [aura --2] [~.rd .~0.5]]
              [aura --1]
      ::  (1 + 1) * 2
      :-  %nested
          :-  :^  %arithmetic
                  %tar
                  [%arithmetic %lus q-col-1 [aura --1]]
                  q-col-2
              [aura --4]
      ::  scalar1 is col3
      :-  %scalar-name
          :-  [%arithmetic %lus [%scalar-name %scalar1] [aura --1]]
              [aura --4]
      ==
    ==
  %:  run-scalar-tests
    ~
    qual-lookup
    (unqual-map-meta aura)
    ~
    s-row
    :~
    :-  %lus-unqual
        :-  [%arithmetic %lus u-col-4 u-col-5]
            [aura -2]
    :-  %hep-unqual
        :-  [%arithmetic %hep u-col-6 u-col-4]
            [aura -1]
    :-  %tar-unqual
        :-  [%arithmetic %tar u-col-5 u-col-6]
            [aura -28]
    :-  %fas-unqual
        :-  [%arithmetic %fas u-col-5 u-col-6]
            [aura -1]
    :-  %cen-unqual
        :-  [%arithmetic %cen u-col-5 u-col-6]
            [aura -3]
    ::  x^0 = 1
    :-  %ket-unqual
        :-  [%arithmetic %ket u-col-6 u-col-7]
            [aura --1]
    ==
  ==
::
++  signed-functions
  |=  aura=@ta
  ^-  tang
  %:  run-scalar-tests
    ~
    qual-lookup
    (qual-map-meta aura)
    ~
    s-row
    :~
    :-  %abs-literal
        :-  [%abs [aura -5]]
            [aura --5]
    :-  %abs-col
        :-  [%abs q-col-2]
            [aura --2]
    :-  %sign-negative
        :-  [%sign [aura -5]]
            [aura -1]
    :-  %sign-zero
        :-  [%sign [aura --0]]
            [aura --0]
    :-  %sign-col
        :-  [%sign q-col-3]
            [aura --1]
    :-  %floor-literal
        :-  [%floor [aura -5]]
            [aura -5]
    :-  %ceiling-col
        :-  [%ceiling q-col-3]
            [aura --3]
    :-  %round-places
        :-  [%round [aura --1.235] [~.ud 2]]
            [aura --1.235]
    :-  %round-tens
        :-  [%round [aura --1.235] [~.sd -1]]
            [aura --1.240]
    ::  round half up toward +infinity
    :-  %round-tens-negative
        :-  [%round [aura -1.235] [~.sd -1]]
            [aura -1.230]
    :-  %round-aura-length
        :-  [%round [aura --1.235] [aura -2]]
            [aura --1.200]
    :-  %max-literal
        :-  [%max [aura --3] [aura -5]]
            [aura --3]
    :-  %max-col
        :-  [%max q-col-2 q-col-3]
            [aura --3]
    :-  %min-literal
        :-  [%min [aura --3] [aura -5]]
            [aura -5]
    :-  %min-col
        :-  [%min q-col-2 q-col-3]
            [aura --2]
    :-  %sqrt-literal
        :-  [%sqrt [aura --16]]
            [aura --4]
    ::  sqrt(3) truncates
    :-  %sqrt-col
        :-  [%sqrt q-col-3]
            [aura --1]
    :-  %degrees-positive
        :-  [%degrees [aura --1]]
            [aura --57]
    ::  round half away from zero
    :-  %degrees-negative
        :-  [%degrees [aura -1]]
            [aura -57]
    ==
  ==
::
::  neg-one is (scot aura -1)
++  signed-failures
  |=  [aura=@ta neg-one=tape]
  ^-  tang
  =/  a  (trip aura)
  ;:  weld
    %+  expect-fail-message
      'division by zero'
      |.((prep aura [%arithmetic %fas [aura --1] [aura --0]]))
  ::
    =/  fn  (prep aura [%arithmetic %fas q-col-1 q-col-0])
    %+  expect-fail-message
      'division by zero'
      |.((apply-scalar s-row +.fn))
  ::
    %+  expect-fail-message
      (crip "number system conflict: ~.{a} %lus ~.sd")
      |.((prep aura [%arithmetic %lus [aura --1] [~.sd --1]]))
  ::
    %+  expect-fail-message
      (crip "negative exponent [p=~.{a} q=1] not supported")
      |.((prep aura [%arithmetic %ket [aura --2] [aura -1]]))
  ::
    %+  expect-fail-message
      (crip "log({neg-one}) is not a number")
      |.((prep aura [%log [aura -1] ~]))
  ::
    %+  expect-fail-message
      (crip "sqrt({neg-one}) is not a number")
      |.((prep aura [%sqrt [aura -1]]))
  ::
    %+  expect-fail-message
      (crip "max: type conflict: ~.{a} vs ~.sd")
      |.((prep aura [%max [aura --1] [~.sd --1]]))
  ==
::
::  unsigned
::
++  unsigned-arithmetic
  |=  aura=@ta
  ^-  tang
  %+  weld
    %:  run-scalar-tests
      ~
      qual-lookup
      (qual-map-meta aura)
      (mk-resolved-scalars aura)
      u-row
      :~
      :-  %lus-literal-literal
          :-  [%arithmetic %lus [aura 3] [aura 5]]
              [aura 8]
      :-  %lus-col-col
          :-  [%arithmetic %lus q-col-2 q-col-3]
              [aura 5]
      :-  %hep-literal-literal
          :-  [%arithmetic %hep [aura 5] [aura 3]]
              [aura 2]
      :-  %hep-col-col
          :-  [%arithmetic %hep q-col-3 q-col-1]
              [aura 2]
      :-  %tar-literal-literal
          :-  [%arithmetic %tar [aura 3] [aura 5]]
              [aura 15]
      :-  %tar-col-col
          :-  [%arithmetic %tar q-col-2 q-col-3]
              [aura 6]
      :-  %fas-literal-literal
          :-  [%arithmetic %fas [aura 7] [aura 2]]
              [aura 3]
      :-  %fas-col-col
          :-  [%arithmetic %fas q-col-3 q-col-2]
              [aura 1]
      :-  %cen-literal-literal
          :-  [%arithmetic %cen [aura 7] [aura 2]]
              [aura 1]
      :-  %cen-col-col
          :-  [%arithmetic %cen q-col-3 q-col-2]
              [aura 1]
      :-  %ket-ud-exponent
          :-  [%arithmetic %ket [aura 2] [~.ud 3]]
              [aura 8]
      :-  %ket-sd-exponent
          :-  [%arithmetic %ket [aura 2] [~.sd --3]]
              [aura 8]
      :-  %ket-col-col
          :-  [%arithmetic %ket q-col-2 q-col-3]
              [aura 8]
      ::  2^0.5 truncates
      :-  %ket-rd-exponent
          :-  [%arithmetic %ket [aura 2] [~.rd .~0.5]]
              [aura 1]
      ::  (1 + 1) * 2
      :-  %nested
          :-  :^  %arithmetic
                  %tar
                  [%arithmetic %lus q-col-1 [aura 1]]
                  q-col-2
              [aura 4]
      ::  scalar1 is col3
      :-  %scalar-name
          :-  [%arithmetic %lus [%scalar-name %scalar1] [aura 1]]
              [aura 4]
      ==
    ==
  %:  run-scalar-tests
    ~
    qual-lookup
    (unqual-map-meta aura)
    ~
    u-row
    :~
    :-  %lus-unqual
        :-  [%arithmetic %lus u-col-4 u-col-5]
            [aura 12]
    :-  %hep-unqual
        :-  [%arithmetic %hep u-col-5 u-col-4]
            [aura 2]
    :-  %tar-unqual
        :-  [%arithmetic %tar u-col-4 u-col-5]
            [aura 35]
    :-  %fas-unqual
        :-  [%arithmetic %fas u-col-5 u-col-6]
            [aura 1]
    :-  %cen-unqual
        :-  [%arithmetic %cen u-col-5 u-col-6]
            [aura 3]
    ::  x^0 = 1
    :-  %ket-unqual
        :-  [%arithmetic %ket u-col-6 u-col-7]
            [aura 1]
    ==
  ==
::
++  unsigned-functions
  |=  aura=@ta
  ^-  tang
  %:  run-scalar-tests
    ~
    qual-lookup
    (qual-map-meta aura)
    ~
    u-row
    :~
    :-  %abs-literal
        :-  [%abs [aura 5]]
            [aura 5]
    :-  %abs-col
        :-  [%abs q-col-2]
            [aura 2]
    :-  %sign-zero
        :-  [%sign [aura 0]]
            [aura 0]
    :-  %sign-literal
        :-  [%sign [aura 5]]
            [aura 1]
    :-  %sign-col
        :-  [%sign q-col-3]
            [aura 1]
    :-  %floor-literal
        :-  [%floor [aura 5]]
            [aura 5]
    :-  %ceiling-col
        :-  [%ceiling q-col-3]
            [aura 3]
    :-  %round-tens
        :-  [%round [aura 1.235] [~.sd -1]]
            [aura 1.240]
    ::  an unsigned length is a number of decimal places
    :-  %round-aura-length
        :-  [%round [aura 1.235] [aura 2]]
            [aura 1.235]
    :-  %round-sb-length
        :-  [%round [aura 1.235] [~.sb -2]]
            [aura 1.200]
    :-  %max-literal
        :-  [%max [aura 3] [aura 5]]
            [aura 5]
    :-  %max-col
        :-  [%max q-col-2 q-col-3]
            [aura 3]
    :-  %min-literal
        :-  [%min [aura 3] [aura 5]]
            [aura 3]
    :-  %min-col
        :-  [%min q-col-2 q-col-3]
            [aura 2]
    :-  %sqrt-literal
        :-  [%sqrt [aura 16]]
            [aura 4]
    ::  sqrt(3) truncates
    :-  %sqrt-col
        :-  [%sqrt q-col-3]
            [aura 1]
    :-  %degrees-one
        :-  [%degrees [aura 1]]
            [aura 57]
    :-  %degrees-three
        :-  [%degrees [aura 3]]
            [aura 172]
    ==
  ==
::
++  unsigned-failures
  |=  aura=@ta
  ^-  tang
  =/  a  (trip aura)
  ;:  weld
    %+  expect-fail-message
      'subtraction underflow'
      |.((prep aura [%arithmetic %hep [aura 2] [aura 3]]))
  ::
    %+  expect-fail-message
      'division by zero'
      |.((prep aura [%arithmetic %fas [aura 1] [aura 0]]))
  ::
    =/  fn  (prep aura [%arithmetic %fas q-col-1 q-col-0])
    %+  expect-fail-message
      'division by zero'
      |.((apply-scalar u-row +.fn))
  ::
    %+  expect-fail-message
      (crip "number system conflict: ~.{a} %lus ~.ud")
      |.((prep aura [%arithmetic %lus [aura 1] [~.ud 1]]))
  ::
    %+  expect-fail-message
      'log(0) is not a number'
      |.((prep aura [%log [aura 0] ~]))
  ::
    %+  expect-fail-message
      (crip "min: type conflict: ~.{a} vs ~.ud")
      |.((prep aura [%min [aura 1] [~.ud 1]]))
  ==
::
::  signed and unsigned
::
::  one and two are the atoms of 1 and 2 in aura, row has col2 = 2
++  integer-trig-log
  |=  [aura=@ta one=@ two=@ row=data-row]
  ^-  tang
  %:  run-scalar-tests
    ~
    qual-lookup
    (qual-map-meta aura)
    ~
    row
    :~
    :-  %log-one
        :-  [%log [aura one] ~]
            [~.rd .~0]
    :-  %log-col
        :-  [%log q-col-2 ~]
            [~.rd 4.604.418.534.313.441.763]
    :-  %sin-one
        :-  [%sin [aura one]]
            [~.rd .~0.84147098480789606]
    :-  %cos-one
        :-  [%cos [aura one]]
            [~.rd .~0.54030230586813921]
    :-  %tan-one
        :-  [%tan [aura one]]
            [~.rd .~1.5574077246549027]
    :-  %asin-one
        :-  [%asin [aura one]]
            [~.rd .~1.5707963267948966]
    :-  %acos-one
        :-  [%acos [aura one]]
            [~.rd .~0]
    :-  %atan-one
        :-  [%atan [aura one]]
            [~.rd .~0.78539816339745139]
    :-  %atan2-literal
        :-  [%atan2 [aura one] [aura two]]
            [~.rd .~0.46364760900080748]
    ::  integer auras mix in atan2
    :-  %atan2-ud-x
        :-  [%atan2 [aura one] [~.ud 2]]
            [~.rd .~0.46364760900080748]
    ==
  ==
::
::  RAND keeps the aura and stays within [lo, hi]
++  rand-in-range
  |=  [aura=@ta lo=@ hi=@ signed=?]
  ^-  tang
  =/  fn  (prep aura [%rand [aura lo] [aura hi]])
  =/  res=dime  (apply-scalar ?:(signed s-row u-row) +.fn)
  %+  weld
    (expect-eq !>(aura) !>(p.res))
  %-  expect
  !>  ?.  signed
        &((gte q.res lo) (lte q.res hi))
      ?&  !=(-1 (cmp:si `@s`q.res `@s`lo))
          !=(--1 (cmp:si `@s`q.res `@s`hi))
          ==
::
::  @sb
::
++  test-arithmetic-sb  (signed-arithmetic ~.sb)
++  test-functions-sb   (signed-functions ~.sb)
++  test-trig-log-sb    (integer-trig-log ~.sb --1 --2 s-row)
++  test-rand-sb        (rand-in-range ~.sb -2 --2 %.y)
++  test-fail-sb        (signed-failures ~.sb "-0b1")
::
::  @sv
::
++  test-arithmetic-sv  (signed-arithmetic ~.sv)
++  test-functions-sv   (signed-functions ~.sv)
++  test-trig-log-sv    (integer-trig-log ~.sv --1 --2 s-row)
++  test-rand-sv        (rand-in-range ~.sv -2 --2 %.y)
++  test-fail-sv        (signed-failures ~.sv "-0v1")
::
::  @sw
::
++  test-arithmetic-sw  (signed-arithmetic ~.sw)
++  test-functions-sw   (signed-functions ~.sw)
++  test-trig-log-sw    (integer-trig-log ~.sw --1 --2 s-row)
++  test-rand-sw        (rand-in-range ~.sw -2 --2 %.y)
++  test-fail-sw        (signed-failures ~.sw "-0w1")
::
::  @sx
::
++  test-arithmetic-sx  (signed-arithmetic ~.sx)
++  test-functions-sx   (signed-functions ~.sx)
++  test-trig-log-sx    (integer-trig-log ~.sx --1 --2 s-row)
++  test-rand-sx        (rand-in-range ~.sx -2 --2 %.y)
++  test-fail-sx        (signed-failures ~.sx "-0x1")
::
::  @ub
::
++  test-arithmetic-ub  (unsigned-arithmetic ~.ub)
++  test-functions-ub   (unsigned-functions ~.ub)
++  test-trig-log-ub    (integer-trig-log ~.ub 1 2 u-row)
++  test-rand-ub        (rand-in-range ~.ub 3 9 %.n)
++  test-fail-ub        (unsigned-failures ~.ub)
::
::  @uv
::
++  test-arithmetic-uv  (unsigned-arithmetic ~.uv)
++  test-functions-uv   (unsigned-functions ~.uv)
++  test-trig-log-uv    (integer-trig-log ~.uv 1 2 u-row)
++  test-rand-uv        (rand-in-range ~.uv 3 9 %.n)
++  test-fail-uv        (unsigned-failures ~.uv)
::
::  @uw
::
++  test-arithmetic-uw  (unsigned-arithmetic ~.uw)
++  test-functions-uw   (unsigned-functions ~.uw)
++  test-trig-log-uw    (integer-trig-log ~.uw 1 2 u-row)
++  test-rand-uw        (rand-in-range ~.uw 3 9 %.n)
++  test-fail-uw        (unsigned-failures ~.uw)
::
::  @ux
::
++  test-arithmetic-ux  (unsigned-arithmetic ~.ux)
++  test-functions-ux   (unsigned-functions ~.ux)
++  test-trig-log-ux    (integer-trig-log ~.ux 1 2 u-row)
++  test-rand-ux        (rand-in-range ~.ux 3 9 %.n)
++  test-fail-ux        (unsigned-failures ~.ux)
::
::  all
::
++  test-fail-unsupported-number-system
  %+  expect-fail-message
    %-  crip  "~.t not a supported number system for %abs, ".
              "need ?(~.rh ~.rs ~.rd ~.rq ~.sb ~.sd ~.sv ~.sw ~.sx ".
              "~.ub ~.ud ~.uv ~.uw ~.ux)"
    |.((prep ~.t [%abs [~.t 'a']]))
::
::  end to end: @uv literals in INSERT, WHERE and SELECT
++  test-select-uv
  =|  run=@ud
  %-  exec-0-1
  :*  run
      :+  ~2012.4.30
          %db1
          "CREATE DATABASE db1; CREATE TABLE nums (id @ud, a @uv, b @uv) ".
          "PRIMARY KEY (id); INSERT INTO nums VALUES (1, 0v3v, 0v10) ".
          "(2, 0v1.00001, 0v1.00000);"
      ::
      :+  ~2012.5.3
          %db1
          "FROM nums WHERE a > 0v10 AND b < 0v1.00000 ".
          "SELECT id, a + b, a - b, a * b, a / b, a % b, SQRT(a), a ^ 2"
      ::
      :-  %results
          :~  [%action 'SELECT']
              :-  %result-set
                  :~  :-  %vector
                          :~  [%id [~.ud 1]]
                              [%scalar-1 [~.uv 0v4v]]
                              [%scalar-2 [~.uv 0v2v]]
                              [%scalar-3 [~.uv 0v3v0]]
                              [%scalar-4 [~.uv 0v3]]
                              [%scalar-5 [~.uv 0vv]]
                              [%scalar-6 [~.uv 0vb]]
                              [%scalar-7 [~.uv 0vfo1]]
                              ==
                      ==
              [%server-time ~2012.5.3]
              [%relation-name 'db1.dbo.nums']
              [%schema-time ~2012.4.30]
              [%data-time ~2012.4.30]
              [%vector-count 1]
              ==
      ==
::
::  end to end: @sx literals in INSERT, WHERE and SELECT; b < --0x0
::  only holds comparing as signed
++  test-select-sx
  =|  run=@ud
  %-  exec-0-1
  :*  run
      :+  ~2012.4.30
          %db1
          "CREATE DATABASE db1; CREATE TABLE nums (id @ud, a @sx, b @sx) ".
          "PRIMARY KEY (id); INSERT INTO nums VALUES (1, --0x7f, -0x20) ".
          "(2, -0x1, --0x1);"
      ::
      :+  ~2012.5.3
          %db1
          "FROM nums WHERE a > b AND b < --0x0 ".
          "SELECT id, a + b, a - b, a * b, a / b, a % b, ABS(b), b ^ 2"
      ::
      :-  %results
          :~  [%action 'SELECT']
              :-  %result-set
                  :~  :-  %vector
                          :~  [%id [~.ud 1]]
                              [%scalar-1 [~.sx --0x5f]]
                              [%scalar-2 [~.sx --0x9f]]
                              [%scalar-3 [~.sx -0xfe0]]
                              [%scalar-4 [~.sx -0x3]]
                              [%scalar-5 [~.sx --0x1f]]
                              [%scalar-6 [~.sx --0x20]]
                              [%scalar-7 [~.sx --0x400]]
                              ==
                      ==
              [%server-time ~2012.5.3]
              [%relation-name 'db1.dbo.nums']
              [%schema-time ~2012.4.30]
              [%data-time ~2012.4.30]
              [%vector-count 1]
              ==
      ==
--
