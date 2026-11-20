::  bit-width (sized) integer auras, e.g. @udD (8 bits): an aura and its
::  sized form are compatible, values and results must fit the width
::
/-  ast=obelisk-ast, *obelisk
/+  *test, *test-helpers
|%
::
::  a @udD, b @sdD (-128..127), c @uxF (32 bits), w @udE
++  init-sz
  "CREATE DATABASE db1; ".
  "CREATE TABLE sz (id @ud, a @udD, b @sdD, c @uxF, w @udE) ".
  "PRIMARY KEY (id); ".
  "INSERT INTO sz VALUES (1, 100, -5, 0xffff.ffff, 1000) ".
  "(2, 255, -128, 0x0, 0);"
::
++  sz-results
  |=  [tmsp=@da rows=(list vector:ast)]
  ^-  cmd-result:ast
  :-  %results
      :~  [%action 'SELECT']
          [%result-set rows]
          [%server-time tmsp]
          [%relation-name 'db1.dbo.sz']
          [%schema-time ~2012.4.30]
          [%data-time ~2012.4.30]
          [%vector-count (lent rows)]
          ==
::
::  sized values keep their aura; arithmetic with an unsized literal takes
::  the sized aura; predicates compare a sized signed aura as signed
++  test-sized-select
  =|  run=@ud
  %-  exec-0-1
  :*  run
      [~2012.4.30 %db1 init-sz]
      ::
      :+  ~2012.5.3
          %db1
          "FROM sz WHERE a > 50 AND b < --0 AND b > -10 ".
          "SELECT id, a, b, c, a + 1, b * --2, c - 0x1"
      ::
      %+  sz-results  ~2012.5.3
      :~  :-  %vector
              :~  [%id [~.ud 1]]
                  [%a ['udD' 100]]
                  [%b ['sdD' -5]]
                  [%c ['uxF' 0xffff.ffff]]
                  [%scalar-4 ['udD' 101]]
                  [%scalar-5 ['sdD' -10]]
                  [%scalar-6 ['uxF' 0xffff.fffe]]
                  ==
          ==
      ==
::
::  IF takes the sized aura of its branches, an unsized branch is retagged
++  test-sized-if
  =|  run=@ud
  %-  exec-0-1
  :*  run
      [~2012.4.30 %db1 init-sz]
      ::
      :+  ~2012.5.3
          %db1
          "FROM sz WHERE id = 1 ".
          "SELECT IF a > 50 THEN a ELSE 0 ENDIF, ".
          "IF a > 200 THEN a ELSE 7 ENDIF, MAX(a, 3), ABS(b)"
      ::
      %+  sz-results  ~2012.5.3
      :~  :-  %vector
              :~  [%scalar-0 ['udD' 100]]
                  [%scalar-1 ['udD' 7]]
                  [%scalar-2 ['udD' 100]]
                  [%scalar-3 ['sdD' --5]]
                  ==
          ==
      ==
::
++  test-fail-sized-insert-ud
  =|  run=@ud
  %-  failon-1
  :*  run
      [~2012.4.30 %db1 init-sz]
      [~2012.5.1 %db1 "INSERT INTO sz VALUES (3, 256, --0, 0x0, 0)"]
      '256 exceeds @udD'
      ==
::
++  test-fail-sized-insert-sd
  =|  run=@ud
  %-  failon-1
  :*  run
      [~2012.4.30 %db1 init-sz]
      [~2012.5.1 %db1 "INSERT INTO sz VALUES (3, 1, --128, 0x0, 0)"]
      '--128 exceeds @sdD'
      ==
::
++  test-fail-sized-insert-ux
  =|  run=@ud
  %-  failon-1
  :*  run
      [~2012.4.30 %db1 init-sz]
      [~2012.5.1 %db1 "INSERT INTO sz VALUES (3, 1, --0, 0x1.0000.0000, 0)"]
      '0x1.0000.0000 exceeds @uxF'
      ==
::
++  test-fail-sized-update
  =|  run=@ud
  %-  failon-1
  :*  run
      [~2012.4.30 %db1 init-sz]
      [~2012.5.1 %db1 "UPDATE sz SET a = 300 WHERE id = 1"]
      '300 exceeds @udD'
      ==
::
++  test-fail-sized-arithmetic-overflow
  =|  run=@ud
  %-  failon-1
  :*  run
      [~2012.4.30 %db1 init-sz]
      [~2012.5.1 %db1 "FROM sz WHERE id = 1 SELECT a + 200"]
      '300 exceeds @udD'
      ==
::
::  -128 has no positive counterpart in @sdD
++  test-fail-sized-abs-overflow
  =|  run=@ud
  %-  failon-1
  :*  run
      [~2012.4.30 %db1 init-sz]
      [~2012.5.1 %db1 "FROM sz WHERE id = 2 SELECT ABS(b)"]
      '--128 exceeds @sdD'
      ==
::
++  test-fail-sized-if-overflow
  =|  run=@ud
  %-  failon-1
  :*  run
      [~2012.4.30 %db1 init-sz]
      :+  ~2012.5.1
          %db1
          "FROM sz WHERE id = 1 SELECT IF a > 200 THEN a ELSE 300 ENDIF"
      '300 exceeds @udD'
      ==
::
::  mixed widths take the largest width
++  test-sized-mixed-width
  =|  run=@ud
  %-  exec-0-1
  :*  run
      [~2012.4.30 %db1 init-sz]
      ::
      :+  ~2012.5.3
          %db1
          "FROM sz WHERE id = 1 SELECT a + w, MAX(a, w)"
      ::
      %+  sz-results  ~2012.5.3
      :~  :-  %vector
              :~  [%scalar-0 ['udE' 1.100]]
                  [%scalar-1 ['udE' 1.000]]
                  ==
          ==
      ==
::
++  test-fail-sized-alter-column
  =|  run=@ud
  %-  failon-1
  :*  run
      [~2012.4.30 %db1 init-sz]
      [~2012.5.1 %db1 "ALTER TABLE sz ALTER COLUMN (c @uxD)"]
      'ALTER TABLE: %sz column %c has values outside @uxD'
      ==
::
++  test-fail-sized-text-aura
  =|  run=@ud
  %-  failon-1
  :*  run
      [~2012.4.30 %sys "CREATE DATABASE db1"]
      [~2012.5.1 %db1 "CREATE TABLE bad (id @ud, t @tD) PRIMARY KEY (id)"]
      'bit width applies only to integer auras, not @t'
      ==
--
