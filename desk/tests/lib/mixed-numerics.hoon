::  mixed numeric arithmetic, comparison and functions: operands of
::  different number systems convert to a common aura, compare exactly
::
/-  ast=obelisk-ast, *obelisk
/+  *test, *test-helpers, *utils
|%
::
::  u @ud, s @sd, r @rd, h @rh, x @ux, q @rq, d @udD
::  row 2: u is 2^53 + 1, r is 2^53
++  init-mx
  "CREATE DATABASE db1; ".
  "CREATE TABLE mx (id @ud, u @ud, s @sd, r @rd, h @rh, x @ux, q @rq, ".
  "d @udD) PRIMARY KEY (id); ".
  "INSERT INTO mx VALUES ".
  "(1, 5, -3, .~2.5, .~~1.5, 0x10, .~~~0.25, 200) ".
  "(2, 9.007.199.254.740.993, --2, .~9007199254740992, .~~2, 0xff, ".
  ".~~~1, 7); ".
  "CREATE TABLE lk (k @sd, label @t) PRIMARY KEY (k); ".
  "INSERT INTO lk VALUES (--5, 'five') (--2, 'two');"
::
++  mx-results
  |=  rows=(list vector:ast)
  ^-  cmd-result:ast
  :-  %results
      :~  [%action 'SELECT']
          [%result-set rows]
          [%server-time ~2012.5.3]
          [%relation-name 'db1.dbo.mx']
          [%schema-time ~2012.4.30]
          [%data-time ~2012.4.30]
          [%vector-count (lent rows)]
          ==
::
::  +common-aura
::
++  test-common-aura
  =/  cases=(list [@ta @ta (unit @ta)])
    :~  [~.ud ~.ud `~.ud]
        [~.ud ~.sd `~.sd]
        [~.ux ~.ud `~.ud]
        [~.ux ~.sx `~.sx]
        [~.ux ~.sd `~.sd]
        [~.ub ~.uv `~.ud]
        ['udD' ~.ud `'udD']
        ['udD' 'udE' `'udE']
        ['udD' ~.sd `'sdD']
        ['uxF' ~.sx `'sxF']
        [~.ud ~.rh `~.rd]
        [~.sd ~.rs `~.rd]
        ['udD' ~.rh `~.rd]
        [~.rh ~.rs `~.rs]
        [~.rh ~.rd `~.rd]
        [~.rq ~.ud `~.rq]
        [~.rd ~.rq `~.rq]
        [~.rh ~.rh `~.rh]
        [~.t ~.t `~.t]
        [~.t ~.ta ~]
        [~.ud ~.t ~]
        [~.da ~.dr ~]
        ==
  %+  expect-eq
    !>  (turn cases |=([a=@ta b=@ta c=(unit @ta)] c))
    !>  (turn cases |=([a=@ta b=@ta c=(unit @ta)] (common-aura a b)))
::
::  the common aura does not depend on operand order
++  test-common-aura-commutes
  =/  auras=(list @ta)
    ~[~.ud ~.sd ~.ux ~.sx ~.ub 'udD' 'udE' 'sdF' ~.rh ~.rs ~.rd ~.rq]
  %+  expect-eq
    !>  %.y
    !>  %+  levy  auras
        |=  a=@ta
        %+  levy  auras
        |=(b=@ta =((common-aura a b) (common-aura b a)))
::
::  +num-cmp is exact across number systems
::
++  test-num-cmp
  %+  expect-eq
    !>  ~[%gt %eq %gt %eq %eq %lt %nan %lt %lt %gt %eq]
    !>  :~  (num-cmp ~.ud 5 ~.sd -3)
            (num-cmp ~.sd -3 ~.rd .~-3)
            (num-cmp ~.ud 9.007.199.254.740.993 ~.rd .~9007199254740992)
            (num-cmp ~.rd .~-0 ~.ud 0)
            (num-cmp ~.rh .~~1.5 ~.rq .~~~1.5)
            (num-cmp ~.rd .~-inf ~.sd -100)
            (num-cmp ~.rd .~nan ~.ud 1)
            (num-cmp ~.sd -5 ~.sd -3)
            (num-cmp ~.rd .~-2.5 ~.sd -2)
            (num-cmp ~.rh .~~inf ~.ud 1.000.000)
            (num-cmp 'udD' 7 ~.rs .7)
            ==
::
::  equal values of different number systems key alike
++  test-number-key
  %+  expect-eq
    !>  [%.y %.y %.n %.y]
    !>  :*  =((number-key ~.ud 4) (number-key ~.rd .~4))
            =((number-key ~.sd --4) (number-key ~.rh .~~4))
            =((number-key ~.sd -4) (number-key ~.ud 4))
            =((number-key ~.rd .~0) (number-key ~.rd .~-0))
            ==
::
++  test-convert-number
  %+  expect-eq
    !>  ~[--5 .~-3 .~~~1.5 0x10 .~16]
    !>  :~  (convert-number ~.ud ~.sd 5)
            (convert-number ~.sd ~.rd -3)
            (convert-number ~.rh ~.rq .~~1.5)
            (convert-number 'uxF' ~.ux 0x10)
            (convert-number ~.ux ~.rd 0x10)
            ==
::
++  test-fail-convert-number-width
  %+  expect-fail-message
    '--200 exceeds @sdD'
    |.((convert-number 'udD' 'sdD' 200))
::
::  end to end
::
::  each result takes the common aura of its operands; ^ keeps the base's
::  aura, @rd for a negative or non-literal signed exponent
++  test-mixed-arithmetic
  =|  run=@ud
  %-  exec-0-1
  :*  run
      [~2012.4.30 %db1 init-mx]
      ::
      :+  ~2012.5.3
          %db1
          "FROM mx WHERE id = 1 ".
          "SELECT u + s, u - s, s * r, u + h, h + r, h * q, x + u, ".
          "x + 0x1, x + s, d + u, u / r, 2 ^ -3, u ^ --2, x ^ -1, r ^ 2"
      ::
      %-  mx-results
      :~  :-  %vector
              :~  [%scalar-0 [~.sd --2]]
                  [%scalar-1 [~.sd --8]]
                  [%scalar-2 [~.rd .~-7.5]]
                  [%scalar-3 [~.rd .~6.5]]
                  [%scalar-4 [~.rd .~4]]
                  [%scalar-5 [~.rq .~~~0.375]]
                  [%scalar-6 [~.ud 21]]
                  [%scalar-7 [~.ux 0x11]]
                  [%scalar-8 [~.sd --13]]
                  [%scalar-9 ['udD' 205]]
                  [%scalar-10 [~.rd .~2]]
                  [%scalar-11 [~.rd .~0.125]]
                  [%scalar-12 [~.sd --25]]
                  [%scalar-13 [~.rd .~0.0625]]
                  [%scalar-14 [~.rd .~6.25]]
                  ==
          ==
      ==
::
::  comparisons are exact: u is 2^53 + 1, r is 2^53, so u > r and u <> r
::  hold although u converted to @rd equals r
++  test-mixed-comparison
  =|  run=@ud
  %-  exec-0-1
  :*  run
      [~2012.4.30 %db1 init-mx]
      ::
      :+  ~2012.5.3
          %db1
          "FROM mx WHERE h = s AND x = 255 AND u > r AND u <> r ".
          "AND r < u AND q < h AND s >= 2 AND s IN (5, 2) SELECT id"
      ::
      %-  mx-results
      :~  [%vector ~[[%id [~.ud 2]]]]
          ==
      ==
::
++  test-mixed-not-in
  =|  run=@ud
  %-  exec-0-1
  :*  run
      [~2012.4.30 %db1 init-mx]
      ::
      [~2012.5.3 %db1 "FROM mx WHERE s NOT IN (5, 2) SELECT id"]
      ::
      %-  mx-results
      :~  [%vector ~[[%id [~.ud 1]]]]
          ==
      ==
::
::  branches and arguments of several types convert to their common aura
::
++  test-mixed-if
  =|  run=@ud
  %-  exec-0-1
  :*  run
      [~2012.4.30 %db1 init-mx]
      :+  ~2012.5.3
          %db1
          "FROM mx WHERE id = 1 SELECT IF u > 3 THEN u ELSE s ENDIF"
      (mx-results ~[[%vector ~[[%scalar-0 [~.sd --5]]]]])
      ==
::
++  test-mixed-max
  =|  run=@ud
  %-  exec-0-1
  :*  run
      [~2012.4.30 %db1 init-mx]
      [~2012.5.3 %db1 "FROM mx WHERE id = 1 SELECT MAX(u, r)"]
      (mx-results ~[[%vector ~[[%scalar-0 [~.rd .~5]]]]])
      ==
::
++  test-mixed-min
  =|  run=@ud
  %-  exec-0-1
  :*  run
      [~2012.4.30 %db1 init-mx]
      [~2012.5.3 %db1 "FROM mx WHERE id = 1 SELECT MIN(s, h)"]
      (mx-results ~[[%vector ~[[%scalar-0 [~.rd .~-3]]]]])
      ==
::
++  test-mixed-case-searched
  =|  run=@ud
  %-  exec-0-1
  :*  run
      [~2012.4.30 %db1 init-mx]
      :+  ~2012.5.3
          %db1
          "FROM mx WHERE id = 1 SELECT CASE WHEN u > 3 THEN h ELSE q END"
      (mx-results ~[[%vector ~[[%scalar-0 [~.rq .~~~1.5]]]]])
      ==
::
++  test-mixed-case-simple
  =|  run=@ud
  %-  exec-0-1
  :*  run
      [~2012.4.30 %db1 init-mx]
      :+  ~2012.5.3
          %db1
          "FROM mx WHERE id = 1 ".
          "SELECT CASE x WHEN 16 THEN 'sixteen' ELSE 'other' END"
      (mx-results ~[[%vector ~[[%scalar-0 [~.t 'sixteen']]]]])
      ==
::
++  test-mixed-coalesce
  =|  run=@ud
  %-  exec-0-1
  :*  run
      [~2012.4.30 %db1 init-mx]
      [~2012.5.3 %db1 "FROM mx WHERE id = 1 SELECT COALESCE(u, s)"]
      (mx-results ~[[%vector ~[[%scalar-0 [~.sd --5]]]]])
      ==
::
::  a signed WHEN literal matches an unsigned target by value
++  test-mixed-case-simple-signed
  =|  run=@ud
  %-  exec-0-1
  :*  run
      [~2012.4.30 %db1 init-mx]
      :+  ~2012.5.3
          %db1
          "FROM mx WHERE id = 1 ".
          "SELECT CASE u WHEN --5 THEN 'five' ELSE 'other' END"
      (mx-results ~[[%vector ~[[%scalar-0 [~.t 'five']]]]])
      ==
::
::  JOIN ON columns of different number systems matches by value
++  test-mixed-join
  =|  run=@ud
  %-  exec-0-1
  :*  run
      [~2012.4.30 %db1 init-mx]
      ::
      :+  ~2012.5.3
          %db1
          "FROM mx T1 JOIN lk T2 ON T1.u = T2.k SELECT T1.id, T2.label"
      ::
      :-  %results
          :~  [%action 'SELECT']
              :-  %result-set
                  :~  :-  %vector
                          :~  [%id [~.ud 1]]
                              [%label [~.t 'five']]
                              ==
                      ==
              [%server-time ~2012.5.3]
              [%relation-name 'db1.dbo.lk']
              [%schema-time ~2012.4.30]
              [%data-time ~2012.4.30]
              [%relation-name 'db1.dbo.mx']
              [%schema-time ~2012.4.30]
              [%data-time ~2012.4.30]
              [%vector-count 1]
              ==
      ==
::
::  @udD 200 converts to the common @sdD, which tops out at 127
++  test-fail-mixed-width-overflow
  =|  run=@ud
  %-  failon-1
  :*  run
      [~2012.4.30 %db1 init-mx]
      [~2012.5.3 %db1 "FROM mx WHERE id = 1 SELECT d + s"]
      '--200 exceeds @sdD'
      ==
::
++  test-fail-mixed-remainder
  =|  run=@ud
  %-  failon-1
  :*  run
      [~2012.4.30 %db1 init-mx]
      [~2012.5.3 %db1 "FROM mx WHERE id = 1 SELECT u % r"]
      'remainder not implemented for @rd'
      ==
::
::  a signed exponent that is not a literal gives @rd
++  test-mixed-column-signed-exponent
  =|  run=@ud
  %-  exec-0-1
  :*  run
      [~2012.4.30 %db1 init-mx]
      [~2012.5.3 %db1 "FROM mx WHERE id = 1 SELECT 2 ^ s, x ^ s"]
      %-  mx-results
      :~  :-  %vector
              :~  [%scalar-0 [~.rd .~0.125]]
                  [%scalar-1 [~.rd .~0.000244140625]]
                  ==
          ==
      ==
::
::  0 ^ -1 is 1 / 0
++  test-fail-mixed-zero-negative-exponent
  =|  run=@ud
  %-  failon-1
  :*  run
      [~2012.4.30 %db1 init-mx]
      [~2012.5.3 %db1 "FROM mx WHERE id = 1 SELECT 0 ^ -1"]
      'division by zero'
      ==
--
