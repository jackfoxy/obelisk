::  @uc bitcoin addresses: 0c<address> or a bare address, verified by its
::  base58check checksum and a mainnet or testnet version byte
::
/-  ast=obelisk-ast, *obelisk
/+  parse, *format, *test, *test-helpers
|%
::
::  every literal form: 0c, bare mainnet P2PKH and P2SH, bare testnet
::  P2PKH (m and n) and P2SH (2), two leading zero bytes, the all-zero
::  address, and DEFAULT
++  init-wallet
  "CREATE DATABASE db1; ".
  "CREATE TABLE wallet (addr @uc, owner @t, backup @uc) ".
  "PRIMARY KEY (addr); ".
  "INSERT INTO wallet VALUES ".
  "(0c1A1zP1eP5QGefi2DMPTfTL5SLmv7DivfNa, 'genesis', DEFAULT) ".
  "(3J98t1WpEZ73CNmQviecrnyiWrnqRhWNLy, 'p2sh', ".
  "1111111111111111111114oLvT2) ".
  "(mipcBbFg9gMiCh81Kj8tqqdgoZub1ZJRfn, 'testnet', ".
  "0c2MzQwSSnBHWHqSAqtTVQ6v47XtaisrJa1Vc) ".
  "(2MzQwSSnBHWHqSAqtTVQ6v47XtaisrJa1Vc, 'testnet-p2sh', ".
  "n3PzssfEpfnsMjG6si2ykmRnAvYrSVQfR4) ".
  "(n3PzssfEpfnsMjG6si2ykmRnAvYrSVQfR4, 'testnet-n', DEFAULT) ".
  "(113QnJ3yHfvBu6HCS8EyUu2f5mmDQqM9v, 'lead-zero', DEFAULT); ".
  "CREATE TABLE payment (id @ud, addr @uc) PRIMARY KEY (id) ".
  "FOREIGN KEY (addr) REFERENCES wallet (addr); ".
  "INSERT INTO payment VALUES (1, 1A1zP1eP5QGefi2DMPTfTL5SLmv7DivfNa) ".
  "(2, 0cmipcBbFg9gMiCh81Kj8tqqdgoZub1ZJRfn);"
::
::  SELECT results of rows from the relations named
++  uc-results
  |=  [names=(list @t) rows=(list vector:ast)]
  ^-  cmd-result:ast
  =/  head=(list result:ast)
    :~  [%action 'SELECT']
        [%result-set rows]
        [%server-time ~2012.5.3]
    ==
  =/  relations=(list (list result:ast))
    %+  turn  names
    |=  name=@t
    ^-  (list result:ast)
    :~  [%relation-name name]
        [%schema-time ~2012.4.30]
        [%data-time ~2012.4.30]
    ==
  =/  relation-results=(list result:ast)  (zing relations)
  =/  count=(list result:ast)  ~[[%vector-count (lent rows)]]
  =/  tail=(list result:ast)  (weld relation-results count)
  =/  results=(list result:ast)  (weld head tail)
  [%results results]
::
++  wallet-results  (cury uc-results ~['db1.dbo.wallet'])
::
++  uc-test
  |=  [run=@ud urql=tape expect=cmd-result:ast]
  %-  exec-0-1
  [run [~2012.4.30 %db1 init-wallet] [~2012.5.3 %db1 urql] expect]
::
++  uc-fail
  |=  [run=@ud urql=tape message=@t]
  %-  failon-1
  [run [~2012.4.30 %db1 init-wallet] [~2012.5.3 %db1 urql] message]
::
++  parse-db1
  |=  urql=tape
  (parse:parse(default-database 'db1') urql)
::
::  the rows of VALUES of a parsed INSERT
++  values-of
  |=  urql=tape
  ^-  *
  =/  raw=*  (parse-db1 urql)
  ?>  ?=([[%crud-txn * %insert %insert * * * %data *] ~] raw)
  =/  txn  -.raw
  +>+>+>+>.txn
::
::  every form, ordered by address atom: version byte, then hash
++  test-uc-select-00
  =|  run=@ud
  %^  uc-test  run
    "FROM wallet SELECT addr, owner, backup ORDER BY addr"
  %-  wallet-results
  :~  :-  %vector
          :~  [%addr [~.uc 0c113QnJ3yHfvBu6HCS8EyUu2f5mmDQqM9v]]
              [%owner [~.t 'lead-zero']]
              [%backup [~.uc 0]]
          ==
      :-  %vector
          :~  [%addr [~.uc 0c1A1zP1eP5QGefi2DMPTfTL5SLmv7DivfNa]]
              [%owner [~.t 'genesis']]
              [%backup [~.uc 0]]
          ==
      :-  %vector
          :~  [%addr [~.uc 0c3J98t1WpEZ73CNmQviecrnyiWrnqRhWNLy]]
              [%owner [~.t 'p2sh']]
              [%backup [~.uc 0]]
          ==
      :-  %vector
          :~  [%addr [~.uc 0cmipcBbFg9gMiCh81Kj8tqqdgoZub1ZJRfn]]
              [%owner [~.t 'testnet']]
              [%backup [~.uc 0c2MzQwSSnBHWHqSAqtTVQ6v47XtaisrJa1Vc]]
          ==
      :-  %vector
          :~  [%addr [~.uc 0cn3PzssfEpfnsMjG6si2ykmRnAvYrSVQfR4]]
              [%owner [~.t 'testnet-n']]
              [%backup [~.uc 0]]
          ==
      :-  %vector
          :~  [%addr [~.uc 0c2MzQwSSnBHWHqSAqtTVQ6v47XtaisrJa1Vc]]
              [%owner [~.t 'testnet-p2sh']]
              [%backup [~.uc 0cn3PzssfEpfnsMjG6si2ykmRnAvYrSVQfR4]]
          ==
  ==
::
::  a bare testnet address beginning with a lower case letter is a literal,
::  not a column; IN mixes the bare and 0c forms
++  test-uc-where-00
  =|  run=@ud
  %^  uc-test  run
    "FROM wallet WHERE addr = mipcBbFg9gMiCh81Kj8tqqdgoZub1ZJRfn ".
    "OR addr IN (1A1zP1eP5QGefi2DMPTfTL5SLmv7DivfNa, ".
    "0cn3PzssfEpfnsMjG6si2ykmRnAvYrSVQfR4) ".
    "SELECT owner ORDER BY owner"
  %-  wallet-results
  :~  [%vector ~[[%owner [~.t 'genesis']]]]
      [%vector ~[[%owner [~.t 'testnet']]]]
      [%vector ~[[%owner [~.t 'testnet-n']]]]
  ==
::
::  the all-zero address equals the default
++  test-uc-where-01
  =|  run=@ud
  %^  uc-test  run
    "FROM wallet WHERE backup <> 1111111111111111111114oLvT2 ".
    "SELECT owner ORDER BY owner"
  %-  wallet-results
  :~  [%vector ~[[%owner [~.t 'testnet']]]]
      [%vector ~[[%owner [~.t 'testnet-p2sh']]]]
  ==
::
::  literals in SELECT, and as an IF predicate operand
++  test-uc-literals-00
  =|  run=@ud
  %^  uc-test  run
    "FROM wallet WHERE owner = 'genesis' ".
    "SELECT mipcBbFg9gMiCh81Kj8tqqdgoZub1ZJRfn, ".
    "0c3J98t1WpEZ73CNmQviecrnyiWrnqRhWNLy AS p2sh, ".
    "IF addr = 1A1zP1eP5QGefi2DMPTfTL5SLmv7DivfNa THEN 'yes' ELSE 'no' ".
    "ENDIF AS genesis"
  %-  wallet-results
  :~  :-  %vector
          :~  [%literal-0 [~.uc 0cmipcBbFg9gMiCh81Kj8tqqdgoZub1ZJRfn]]
              [%p2sh [~.uc 0c3J98t1WpEZ73CNmQviecrnyiWrnqRhWNLy]]
              [%genesis [~.t 'yes']]
          ==
  ==
::
::  MIN and MAX order addresses by atom
++  test-uc-aggregate-00
  =|  run=@ud
  %^  uc-test  run
    "FROM wallet SELECT MIN(addr), MAX(addr), COUNT(DISTINCT backup)"
  %-  wallet-results
  :~  :-  %vector
          :~  [%min-0 [~.uc 0c113QnJ3yHfvBu6HCS8EyUu2f5mmDQqM9v]]
              [%max-1 [~.uc 0c2MzQwSSnBHWHqSAqtTVQ6v47XtaisrJa1Vc]]
              [%count-2 [~.ud 3]]
          ==
  ==
::
::  JOIN on an address foreign key
++  test-uc-join-00
  =|  run=@ud
  %^  uc-test  run
    "FROM payment P JOIN wallet W ON P.addr = W.addr ".
    "SELECT P.id, W.owner ORDER BY P.id"
  %+  uc-results  ~['db1.dbo.payment' 'db1.dbo.wallet']
  :~  [%vector ~[[%id [~.ud 1]] [%owner [~.t 'genesis']]]]
      [%vector ~[[%id [~.ud 2]] [%owner [~.t 'testnet']]]]
  ==
::
++  test-uc-update-00
  =|  run=@ud
  %-  exec-1-1
  :*  run
      [~2012.4.30 %db1 init-wallet]
      :+  ~2012.5.1
          %db1
          "UPDATE wallet SET backup = n3PzssfEpfnsMjG6si2ykmRnAvYrSVQfR4 ".
          "WHERE owner = 'genesis'"
      [~2012.5.3 %db1 "FROM wallet WHERE owner = 'genesis' SELECT backup"]
      :-  %results
          :~  [%action 'SELECT']
              :-  %result-set
                  :~  :-  %vector
                          :~  :-  %backup
                                  [~.uc 0cn3PzssfEpfnsMjG6si2ykmRnAvYrSVQfR4]
                          ==
                  ==
              [%server-time ~2012.5.3]
              [%relation-name 'db1.dbo.wallet']
              [%schema-time ~2012.4.30]
              [%data-time ~2012.5.1]
              [%vector-count 1]
          ==
      ==
::
++  test-fail-uc-foreign-key-00
  =|  run=@ud
  %^  uc-fail  run
    "INSERT INTO payment VALUES (3, 1BvBMSEYstWetqTFn5Au4m4GFg7xJaNVN2)"
  'INSERT: FOREIGN KEY parent key not found'
::
++  test-fail-uc-primary-key-00
  =|  run=@ud
  %^  uc-fail  run
    "INSERT INTO wallet VALUES (0c1A1zP1eP5QGefi2DMPTfTL5SLmv7DivfNa, 'x', ".
    "DEFAULT)"
  'cannot add duplicate key'
::
++  test-fail-uc-sized-00
  =|  run=@ud
  %-  failon-1
  :*  run
      [~2012.4.30 %sys "CREATE DATABASE db1"]
      [~2012.5.1 %db1 "CREATE TABLE bad (id @ud, a @ucD) PRIMARY KEY (id)"]
      'bit width applies only to integer auras, not @uc'
      ==
::
::  an address is not a number
++  test-fail-uc-arithmetic-00
  =|  run=@ud
  %^  uc-fail  run
    "FROM wallet SELECT addr + 1"
  'number system conflict: ~.uc %lus ~.ud'
::
++  test-fail-uc-abs-00
  =|  run=@ud
  %^  uc-fail  run
    "FROM wallet SELECT ABS(addr)"
  'not a supported number system for %abs'
::
::  parsing
::
++  test-uc-parse-00
  %+  expect-eq
    !>  :~  :~  [~.uc 0c1A1zP1eP5QGefi2DMPTfTL5SLmv7DivfNa]
                [~.uc 0c1A1zP1eP5QGefi2DMPTfTL5SLmv7DivfNa]
                [~.uc 0c3J98t1WpEZ73CNmQviecrnyiWrnqRhWNLy]
                [~.uc 0cmipcBbFg9gMiCh81Kj8tqqdgoZub1ZJRfn]
                [~.uc 0c2MzQwSSnBHWHqSAqtTVQ6v47XtaisrJa1Vc]
                [~.uc 0cn3PzssfEpfnsMjG6si2ykmRnAvYrSVQfR4]
                [~.uc 0c113QnJ3yHfvBu6HCS8EyUu2f5mmDQqM9v]
                [~.uc 0]
            ==  ==
    !>  %-  values-of
        "INSERT INTO t VALUES (0c1A1zP1eP5QGefi2DMPTfTL5SLmv7DivfNa, ".
        "1A1zP1eP5QGefi2DMPTfTL5SLmv7DivfNa, ".
        "3J98t1WpEZ73CNmQviecrnyiWrnqRhWNLy, ".
        "mipcBbFg9gMiCh81Kj8tqqdgoZub1ZJRfn, ".
        "2MzQwSSnBHWHqSAqtTVQ6v47XtaisrJa1Vc, ".
        "n3PzssfEpfnsMjG6si2ykmRnAvYrSVQfR4, ".
        "113QnJ3yHfvBu6HCS8EyUu2f5mmDQqM9v, 0c1111111111111111111114oLvT2)"
::
::  the payload is the version byte and 20-byte hash, as Hoon's @uc
++  test-uc-parse-01
  %+  expect-eq
    !>  ~[~[[~.uc 0x62e9.07b1.5cbf.27d5.4253.99eb.f6f0.fb50.ebb8.8f18]]]
    !>  (values-of "INSERT INTO t VALUES (1A1zP1eP5QGefi2DMPTfTL5SLmv7DivfNa)")
::
++  test-fail-uc-parse-checksum-00
  %+  expect-fail-message
    'invalid @uc address: 0c1A1zP1eP5QGefi2DMPTfTL5SLmv7DivfNb'
  |.  %-  parse-db1
      "INSERT INTO t VALUES (0c1A1zP1eP5QGefi2DMPTfTL5SLmv7DivfNb)"
::
::  a bare address failing its checksum is not an address
++  test-fail-uc-parse-checksum-01
  %-  expect-fail
  |.  (parse-db1 "INSERT INTO t VALUES (1A1zP1eP5QGefi2DMPTfTL5SLmv7DivfNb)")
::
++  test-fail-uc-parse-checksum-02
  %-  expect-fail
  |.  %-  parse-db1
      "FROM t WHERE a = 1A1zP1eP5QGefi2DMPTfTL5SLmv7DivfNb SELECT a"
::
::  0 is not a base58 digit
++  test-fail-uc-parse-character-00
  %+  expect-fail-message
    'invalid @uc address: 0c1A1zP1eP5QGefi2DMPTfTL5SLmv7DivfN0'
  |.  %-  parse-db1
      "INSERT INTO t VALUES (0c1A1zP1eP5QGefi2DMPTfTL5SLmv7DivfN0)"
::
++  test-fail-uc-parse-empty-00
  %+  expect-fail-message
    'invalid @uc address: 0c'
  |.  (parse-db1 "INSERT INTO t VALUES (0c)")
::
::  a valid checksum of a Litecoin version byte, 0x30
++  test-fail-uc-parse-version-00
  %+  expect-fail-message
    'invalid @uc address: 0cLKKHMBjCU89fyFNgSRprDoD8Jb25N8uWvd'
  |.  %-  parse-db1
      "INSERT INTO t VALUES (0cLKKHMBjCU89fyFNgSRprDoD8Jb25N8uWvd)"
::
++  test-fail-uc-parse-version-01
  %-  expect-fail
  |.  (parse-db1 "INSERT INTO t VALUES (LKKHMBjCU89fyFNgSRprDoD8Jb25N8uWvd)")
::
::  a valid checksum of 26 bytes
++  test-fail-uc-parse-length-00
  %+  expect-fail-message
    'invalid @uc address: 0c1QXEx2ZQ9mEdvMSaVKHznFv6iZpz5jcRkb'
  |.  %-  parse-db1
      "INSERT INTO t VALUES (0c1QXEx2ZQ9mEdvMSaVKHznFv6iZpz5jcRkb)"
::
++  test-fail-uc-parse-bech32-00
  %+  expect-fail-message
    'bech32 address is not @uc: bc1qar0srrr7xfkvy5l643lydnw9re59gtzzwf5mdq'
  |.  %-  parse-db1
      "INSERT INTO t VALUES (0cbc1qar0srrr7xfkvy5l643lydnw9re59gtzzwf5mdq)"
::
++  test-fail-uc-parse-bech32-01
  %+  expect-fail-message
    'bech32 address is not @uc: bc1qar0srrr7xfkvy5l643lydnw9re59gtzzwf5mdq'
  |.  %-  parse-db1
      "INSERT INTO t VALUES (bc1qar0srrr7xfkvy5l643lydnw9re59gtzzwf5mdq)"
::
++  test-fail-uc-parse-bech32-02
  %+  expect-fail-message
    'bech32 address is not @uc: tb1qw508d6qejxtdg4y5r3zarvary0c5xw7kxpjzsx'
  |.  %-  parse-db1
      "FROM t WHERE a = tb1qw508d6qejxtdg4y5r3zarvary0c5xw7kxpjzsx SELECT a"
::
::  display
::
++  test-uc-render-00
  %+  expect-eq
    !>  "1A1zP1eP5QGefi2DMPTfTL5SLmv7DivfNa"
    !>  (render-dime [~.uc 0c1A1zP1eP5QGefi2DMPTfTL5SLmv7DivfNa])
::
++  test-uc-render-01
  %+  expect-eq
    !>  "113QnJ3yHfvBu6HCS8EyUu2f5mmDQqM9v"
    !>  (render-dime [~.uc 0c113QnJ3yHfvBu6HCS8EyUu2f5mmDQqM9v])
::
++  test-uc-render-02
  %+  expect-eq
    !>  "2MzQwSSnBHWHqSAqtTVQ6v47XtaisrJa1Vc"
    !>  (render-dime [~.uc 0c2MzQwSSnBHWHqSAqtTVQ6v47XtaisrJa1Vc])
::
::  the default, all zero, address
++  test-uc-render-03
  %+  expect-eq
    !>  "1111111111111111111114oLvT2"
    !>  (render-dime [~.uc 0])
--
