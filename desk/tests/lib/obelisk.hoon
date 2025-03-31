::  unit tests on %obelisk library simulating pokes
::
/-  ast, *obelisk
/+  *test, *obelisk, parse, utils
/=  agent  /app/obelisk
|%
::
::  Build an example bowl manually.
++  bowl
  |=  [run=@ud src=(unit @p) now=@da]
  ^-  bowl:gall
  ?~  src
    :*  [~zod ~zod %obelisk `path`(limo `path`/test-agent)] :: (our src dap sap)
        [~ ~ ~]                                          :: (wex sup sky)
        [run `@uvJ`(shax run) now [~zod %base ud+run]]   :: (act eny now byk)
    ==
  :*  [~zod (need src) %obelisk `path`(limo `path`/test-agent)]
      [~ ~ ~]
      [run `@uvJ`(shax run) now [~zod %base ud+run]]
  ==
::
::  Build a reference state mold.
+$  state
  $:  %0
      =server
      ==
--
|%
::
::  Set TMSP
::
::  set-tmsp back 0 seconds
++  test-set-tmsp-00
  %+  expect-eq
    !>  ~2023.12.25..7.15.0..1ef5
    !>  %-  set-tmsp
            :-  `(as-of-offset:ast %as-of-offset 0 %seconds)
                ~2023.12.25..7.15.0..1ef5
::
::  set-tmsp back 65 seconds
++  test-set-tmsp-01
  %+  expect-eq
    !>  ~2023.12.25..7.13.55..1ef5
    !>  %-  set-tmsp
          :-  `(as-of-offset:ast %as-of-offset 65 %seconds)
              ~2023.12.25..7.15.0..1ef5
::
::  set-tmsp back 0 minutes
++  test-set-tmsp-02
  %+  expect-eq
    !>  ~2023.12.25..7.15.0..1ef5
    !>  %-  set-tmsp
            :-  `(as-of-offset:ast %as-of-offset 0 %minutes)
                ~2023.12.25..7.15.0..1ef5
::
::  set-tmsp back 65 minutes
++  test-set-tmsp-03
  %+  expect-eq
    !>  ~2023.12.25..6.10.0..1ef5
    !>  %-  set-tmsp
            :-  `(as-of-offset:ast %as-of-offset 65 %minutes)
                ~2023.12.25..7.15.0..1ef5
::
::  set-tmsp back 0 hours
++  test-set-tmsp-04
  %+  expect-eq
    !>  ~2023.12.25..7.15.0..1ef5
    !>  %-  set-tmsp
            :-  `(as-of-offset:ast %as-of-offset 0 %hours)
                ~2023.12.25..7.15.0..1ef5
::
::  set-tmsp back 65 hours
++  test-set-tmsp-05
  %+  expect-eq
    !>  ~2023.12.22..14.15.0..1ef5
    !>  %-  set-tmsp
            :-  `(as-of-offset:ast %as-of-offset 65 %hours)
                ~2023.12.25..7.15.0..1ef5
::
::  set-tmsp back 0 days
++  test-set-tmsp-06
  %+  expect-eq
    !>  ~2023.12.25..7.15.0..1ef5
    !>  %-  set-tmsp
            :-  `(as-of-offset:ast %as-of-offset 0 %days)
                ~2023.12.25..7.15.0..1ef5
::
::  set-tmsp back 65 days
++  test-set-tmsp-07
  %+  expect-eq
    !>  ~2023.10.21..7.15.0..1ef5
    !>  %-  set-tmsp
            :-  `(as-of-offset:ast %as-of-offset 65 %days)
                ~2023.12.25..7.15.0..1ef5
::
::  set-tmsp back 0 weeks
++  test-set-tmsp-08
  %+  expect-eq
    !>  ~2023.12.25..7.15.0..1ef5
    !>  %-  set-tmsp
            :-  `(as-of-offset:ast %as-of-offset 0 %weeks)
                ~2023.12.25..7.15.0..1ef5
::
::  set-tmsp back 65 weeks
++  test-set-tmsp-09
  %+  expect-eq
    !>  ~2022.9.26..7.15.0..1ef5
    !>  %-  set-tmsp
            :-  `(as-of-offset:ast %as-of-offset 65 %weeks)
                ~2023.12.25..7.15.0..1ef5
::
::  set-tmsp leap year
++  test-set-tmsp-10
  %+  expect-eq
    !>  ~2020.2.27..7.15.0..1ef5
    !>  %-  set-tmsp
            :-  `(as-of-offset:ast %as-of-offset 7 %days)
                ~2020.3.5..7.15.0..1ef5
::
::  set-tmsp back 0 months
++  test-set-tmsp-11
  %+  expect-eq
    !>  ~2023.12.25..7.15.0..1ef5
    !>  %-  set-tmsp
            :-  `(as-of-offset:ast %as-of-offset 0 %months)
                ~2023.12.25..7.15.0..1ef5
::
::  set-tmsp back 65 months
++  test-set-tmsp-12
  %+  expect-eq
    !>  ~2018.7.25..7.15.0..1ef5
    !>  %-  set-tmsp
            :-  `(as-of-offset:ast %as-of-offset 65 %months)
                ~2023.12.25..7.15.0..1ef5
::
::  set-tmsp back 3 months
++  test-set-tmsp-13
  %+  expect-eq
    !>  ~2019.12.5..7.15.0..1ef5
    !>  %-  set-tmsp
            :-  `(as-of-offset:ast %as-of-offset 3 %months)
                ~2020.3.5..7.15.0..1ef5
::
::  set-tmsp back 2 months
++  test-set-tmsp-14
  %+  expect-eq
    !>  ~2020.1.5..7.15.0..1ef5
    !>  %-  set-tmsp
            :-  `(as-of-offset:ast %as-of-offset 2 %months)
                ~2020.3.5..7.15.0..1ef5
::
::  set-tmsp back 0 years
++  test-set-tmsp-15
  %+  expect-eq
    !>  ~2023.12.25..7.15.0..1ef5
    !>  %-  set-tmsp
            :-  `(as-of-offset:ast %as-of-offset 0 %years)
                ~2023.12.25..7.15.0..1ef5
::
::  set-tmsp back 65 years
++  test-set-tmsp-16
  %+  expect-eq
    !>  ~1958.12.25..7.15.0..1ef5
    !>  %-  set-tmsp
            :-  `(as-of-offset:ast %as-of-offset 65 %years)
                ~2023.12.25..7.15.0..1ef5
::
::  set-tmsp to ~1962.2.2..7.15.0..1ef5
++  test-set-tmsp-17
  %+  expect-eq
    !>  ~1962.2.2..7.15.0..1ef5
    !>  (set-tmsp [`[%da ~1962.2.2..7.15.0..1ef5] ~2023.12.25..7.15.0..1ef5])
::
::  set-tmsp back ~s65
++  test-set-tmsp-18
  %+  expect-eq
    !>  ~2023.12.25..7.13.55..1ef5
    !>  (set-tmsp [`[%dr ~s65] ~2023.12.25..7.15.0..1ef5])
::
::  set-tmsp back ~m65
++  test-set-tmsp-19
  %+  expect-eq
    !>  ~2023.12.25..6.10.0..1ef5
    !>  (set-tmsp [`[%dr ~m65] ~2023.12.25..7.15.0..1ef5])
::
::  set-tmsp back ~m65.s65
++  test-set-tmsp-20
  %+  expect-eq
    !>  ~2023.12.25..6.8.55..1ef5
    !>  (set-tmsp [`[%dr ~m65.s65] ~2023.12.25..7.15.0..1ef5])
::
::  set-tmsp back ~h2.m12.s5
++  test-set-tmsp-21
  %+  expect-eq
    !>  ~2023.12.25..5.2.55..1ef5
    !>  (set-tmsp [`[%dr ~h2.m12.s5] ~2023.12.25..7.15.0..1ef5])
::
::  set-tmsp back ~d5.h2.m12.s5
++  test-set-tmsp-22
  %+  expect-eq
    !>  ~2023.12.20..5.2.55..1ef5
    !>  (set-tmsp [`[%dr ~d5.h2.m12.s5] ~2023.12.25..7.15.0..1ef5])
::
::  set-tmsp back ~s0
++  test-set-tmsp-23
  %+  expect-eq
    !>  ~2023.12.25..7.15.0..1ef5
    !>  (set-tmsp [`[%dr ~s0] ~2023.12.25..7.15.0..1ef5])
::
::  set-tmsp back ~d0.h0.m0.s0
++  test-set-tmsp-24
  %+  expect-eq
    !>  ~2023.12.25..7.15.0..1ef5
    !>  (set-tmsp [`[%dr ~d0.h0.m0.s0] ~2023.12.25..7.15.0..1ef5])
::
::  alphanumeric ordering
::
++  printable-ascii  "0123456789:;<=>?@ABCDEFGHIJK !#$%&'()*+,-./".
                     "LMNOPQRSTUVWXYZ[]^_`abcdefghijklmnopqrstuvwxyz|}~\{\"\\"
++  alpha-ordering  " !\"#$%&'()*+,-./0123456789:;<=>?@`AaBbCcDdEeFfGgHhIiJjKk".
                    "LlMmNnOoPpQqRrSsTtUuVvWwXxYyZz[\{\\|]}^~_"
++  aor-ordering    " !\"#$%&'()*+,-./0123456789:;<=>?@ABCDEFGHIJKLMNOPQRSTUVW".
                    "XYZ[\\]^_`abcdefghijklmnopqrstuvwxyz\{|}~"
::
++  test-alpha-01
  %+  expect-eq
    !>  alpha-ordering
    !>  (sort printable-ascii alpha)
::
++  test-alpha-02
  %+  expect-eq
    !>  aor-ordering
    !>  (sort printable-ascii aor)
::
++  test-alpha-03
  =/  foo  "ijklmnopqrs0123YZ[]^_`abcde456EFGHIJK !#$%&'()*+,-./".
           "LMNOPQR789:;<=>?@ABCDSTUVWXfghtuvwxyz|}~\{\"\\"
  %+  expect-eq
    !>  alpha-ordering
    !>  (sort foo alpha)
::
++  test-alpha-04
  %+  expect-eq
    !>  alpha-ordering
    !>  (sort aor-ordering alpha)
::
++  test-alpha-05
  %+  expect-eq
    !>  alpha-ordering
    !>  (sort alpha-ordering alpha)
++  test-alpha-06
  =/  the-list  :~  'abc'
                    'aBc'
                    'ab'
                    'Abc'
                    'A'
                    'b'
                    'bb'
                    'abC'
                    'aB'
                    'ABC'
                    'AbC'
                    'a'
                    'bac'
                    'aBC'
                    'Ab'
                    'ABc'
                    'AB'
                    ==
  =/  expected  :~  'A'
                    'a'
                    'AB'
                    'aB'
                    'Ab'
                    'ab'
                    'ABC'
                    'aBC'
                    'ABc'
                    'aBc'
                    'AbC'
                    'Abc'
                    'abC'
                    'abc'
                    'b'
                    'bac'
                    'bb'
                    ==
  %+  expect-eq
    !>  expected
    !>  (sort the-list alpha:utils)
::
::  CREATE DATABASE
::
++  expected-db-rows
    :~
      :-  %vector
          :~  [%database [~.tas %db1]]
              [%sys-agent [~.ta '/test-agent']]
              [%sys-tmsp [~.da ~2000.1.1]]
              [%data-ship [~.p 0]]
              [%data-agent [~.ta '/test-agent']]
              [%data-tmsp [~.da ~2000.1.1]]
              ==
      :-  %vector
          :~  [%database [~.tas %sys]]
              [%sys-agent [~.ta '/test-agent']]
              [%sys-tmsp [~.da ~2000.1.1]]
              [%data-ship [~.p 0]]
              [%data-agent [~.ta '/test-agent']]
              [%data-tmsp [~.da ~2000.1.1]]
              ==
      ==
  ::
++  expected-db
      :~  %results
          [%message 'SELECT'] 
          [%result-set expected-db-rows]
          [%server-time ~2000.1.2]
          [%message 'sys.sys.databases']
          [%schema-time ~2000.1.1]
          [%data-time ~2000.1.1]
          [%vector-count 2]
      ==
::
::  create database tape, AS OF
++  test-create-db-01
  =|  run=@ud
  =^  move  agent
    %+  ~(on-poke agent (bowl [run ~ ~1999.1.1]))
        %obelisk-action
        !>([%test %sys "CREATE DATABASE db1 AS OF ~2000.1.1"])
  =+  !<(=state on-save:agent)
  ::
  =.  run  +(run)
  =^  move2  agent
    %+  ~(on-poke agent (bowl [run ~ ~2000.1.2]))
        %obelisk-action
        !>([%test %db1 "FROM sys.sys.databases SELECT *"])
  ::
  %+  weld  %+  expect-eq
              !>  :-  %results
                      :~  [%message 'created database %db1']
                          [%server-time ~1999.1.1]
                          [%schema-time ~2000.1.1]
                          ==
              !>  ;;(cmd-result ->+>+>-.move)
            %+  expect-eq
              !>  expected-db
              !>  ;;(cmd-result ->+>+>-.move2)
::
::  create database command
++  test-create-db-02
  =|  run=@ud
  =^  move  agent
    %+  ~(on-poke agent (bowl [run ~ ~2000.1.1]))
        %obelisk-action
        !>([%commands ~[[%create-database %db1 ~]]])
  =+  !<(=state on-save:agent)
  ::
  =.  run  +(run)
  =^  move2  agent
    %+  ~(on-poke agent (bowl [run ~ ~2000.1.2]))
        %obelisk-action
        !>([%test %db1 "FROM sys.sys.databases SELECT *"])
  ::
  %+  weld  %+  expect-eq
              !>  :-  %results
                      :~  [%message 'created database %db1']
                          [%server-time ~2000.1.1]
                          [%schema-time ~2000.1.1]
                          ==
              !>  ->+>+>-.move
            %+  expect-eq
              !>  expected-db
              !>  ;;(cmd-result ->+>+>-.move2)
::
::  fail duplicate database
++  test-fail-create-database-01
  =|  run=@ud
  =^  move  agent
    %+  ~(on-poke agent (bowl [run ~ ~2000.1.1]))
        %obelisk-action
        !>([%tape2 %sys "CREATE DATABASE db1"])
  ::
  %+  expect-fail-message
        'database %db1 already exists'
  |.  %+  ~(on-poke agent (bowl [run ~ ~2000.1.2]))
          %obelisk-action
          !>([%test %sys "CREATE DATABASE db1"])
::
::  fail on create %sys database
++  test-fail-create-database-02
  =|  run=@ud
  ::
  %+  expect-fail-message
        'database name cannot be \'sys\''
  |.  %+  ~(on-poke agent (bowl [run ~ ~2000.1.2]))
          %obelisk-action
          !>([%test %sys "CREATE DATABASE sys"])
::  fail on foreign source agent

::  to do:  re-enable this test after persmissions implemented
::          currently fails on wrong message
::++  test-fail-create-database-03
::  =|  run=@ud
::  ::
::  %+  expect-fail-message
::        'database must be created by local agent'
::  |.  %+  ~(on-poke agent (bowl [run `~nec ~2000.1.2]))
::          %obelisk-action
::          !>([%test %sys "CREATE DATABASE db1"])
::    ==
::
::  DROP DATABASE
::
::  drop one database, no data
++  test-drop-db-01
  =|  run=@ud
  =/  expected-rows  :~
                      :-  %vector
                          :~  [%database [~.tas %sys]]
                              [%sys-agent [~.ta '/test-agent']]
                              [%sys-tmsp [~.da ~2000.1.1]]
                              [%data-ship [~.p 0]]
                              [%data-agent [~.ta '/test-agent']]
                              [%data-tmsp [~.da ~2000.1.1]]
                              ==
                      ==
  ::
  =/  expected  :~  %results
                    [%message 'SELECT']
                    [%result-set expected-rows]
                    [%server-time ~2000.1.3]
                    [%message 'sys.sys.databases']
                    [%schema-time ~2000.1.1]
                    [%data-time ~2000.1.1]
                    [%vector-count 1]
                ==
  ::
  =^  move  agent
    %+  ~(on-poke agent (bowl [run ~ ~2000.1.1]))
        %obelisk-action
        !>([%tape2 %sys "CREATE DATABASE db1 AS OF ~2000.1.1"])
  ::
  =.  run  +(run)
  =^  move2  agent
    %+  ~(on-poke agent (bowl [run ~ ~2000.1.2]))
        %obelisk-action
        !>([%test %db1 "DROP DATABASE db1"])
  ::
  =.  run  +(run)
  =^  move3  agent
    %+  ~(on-poke agent (bowl [run ~ ~2000.1.3]))
        %obelisk-action
        !>([%test %sys "FROM sys.sys.databases SELECT *"])
  ::
  %+  weld  %+  expect-eq
              !>  :-  %results
                      :~  [%message 'DROP DATABASE %db1']
                          [%server-time ~2000.1.2]
                          [%message 'database %db1 dropped']
                          ==
              !>  ;;(cmd-result ->+>+>-.move2)
            %+  expect-eq
              !>  expected
              !>  ;;(cmd-result ->+>+>-.move3)
::
::  drop database from 2 user dbs, no data
++  test-drop-db-02
  =|  run=@ud
  =/  expected-rows  :~
                      :-  %vector
                          :~  [%database [~.tas %sys]]
                              [%sys-agent [~.ta '/test-agent']]
                              [%sys-tmsp [~.da ~2000.1.1]]
                              [%data-ship [~.p 0]]
                              [%data-agent [~.ta '/test-agent']]
                              [%data-tmsp [~.da ~2000.1.1]]
                              ==
                      :-  %vector
                          :~  [%database [~.tas %db2]]
                              [%sys-agent [~.ta '/test-agent']]
                              [%sys-tmsp [~.da ~2000.1.2]]
                              [%data-ship [~.p 0]]
                              [%data-agent [~.ta '/test-agent']]
                              [%data-tmsp [~.da ~2000.1.2]]
                              ==
                      ==
  ::
  =/  expected  :~  %results
                    [%message 'SELECT']
                    [%result-set expected-rows]
                    [%server-time ~2000.1.4]
                    [%message 'sys.sys.databases']
                    [%schema-time ~2000.1.1]
                    [%data-time ~2000.1.2]
                    [%vector-count 2]
                ==
  ::
  =^  move  agent
    %+  ~(on-poke agent (bowl [run ~ ~2000.1.1]))
        %obelisk-action
        !>([%tape2 %sys "CREATE DATABASE db1 AS OF ~2000.1.1"])
  ::
  =.  run  +(run)
  =^  move2  agent
    %+  ~(on-poke agent (bowl [run ~ ~2000.1.2]))
        %obelisk-action
        !>([%tape2 %sys "CREATE DATABASE db2"])
  ::
  =.  run  +(run)
  =^  move3  agent
    %+  ~(on-poke agent (bowl [run ~ ~2000.1.3]))
        %obelisk-action
        !>([%test %db1 "DROP DATABASE db1"])
  ::
  =.  run  +(run)
  =^  move4  agent
    %+  ~(on-poke agent (bowl [run ~ ~2000.1.4]))
        %obelisk-action
        !>([%test %sys "FROM sys.sys.databases SELECT *"])
  ::
  %+  weld  %+  expect-eq
              !>  :-  %results
                      :~  [%message 'DROP DATABASE %db1']
                          [%server-time ~2000.1.3]
                          [%message 'database %db1 dropped']
                          ==
              !>  ;;(cmd-result ->+>+>-.move3)
            %+  expect-eq
              !>  expected
              !>  ;;(cmd-result ->+>+>-.move4)
::
::  drop database from 2 user dbs, FORCE, not default DB
++  test-drop-db-03
  =|  run=@ud
  =/  expected-rows  :~
                      :-  %vector
                          :~  [%database [~.tas %sys]]
                              [%sys-agent [~.ta '/test-agent']]
                              [%sys-tmsp [~.da ~2000.1.1]]
                              [%data-ship [~.p 0]]
                              [%data-agent [~.ta '/test-agent']]
                              [%data-tmsp [~.da ~2000.1.1]]
                              ==
                      :-  %vector
                          :~  [%database [~.tas %db2]]
                              [%sys-agent [~.ta '/test-agent']]
                              [%sys-tmsp [~.da ~2000.1.4]]
                              [%data-ship [~.p 0]]
                              [%data-agent [~.ta '/test-agent']]
                              [%data-tmsp [~.da ~2000.1.4]]
                              ==
                      ==
  ::
  =/  expected  :~  %results
                    [%message 'SELECT']
                    [%result-set expected-rows]
                    [%server-time ~2000.1.6]
                    [%message 'sys.sys.databases']
                    [%schema-time ~2000.1.1]
                    [%data-time ~2000.1.4]
                    [%vector-count 2]
                ==
  ::
  =^  move  agent
    %+  ~(on-poke agent (bowl [run ~ ~2000.1.1]))
        %obelisk-action
        !>([%tape2 %sys "CREATE DATABASE db1 AS OF ~2000.1.1"])
  =.  run  +(run)
  =^  mov3  agent
    %+  ~(on-poke agent (bowl [run ~ ~2000.1.2]))
        %obelisk-action
        !>  :+  %tape2
                %db1
                "CREATE TABLE db1..my-table (col1 @t) PRIMARY KEY (col1)"
  =.  run  +(run)
  =^  mov4  agent
    %+  ~(on-poke agent (bowl [run ~ ~2000.1.3]))
        %obelisk-action
        !>  :+  %tape2
                %db1
                "INSERT INTO db1..my-table (col1) VALUES ('cord') "
  =.  run  +(run)
  =^  move5  agent
    %+  ~(on-poke agent (bowl [run ~ ~2000.1.4]))
        %obelisk-action
        !>([%tape2 %sys "CREATE DATABASE db2"])
  ::
  =.  run  +(run)
  =^  move6  agent
    %+  ~(on-poke agent (bowl [run ~ ~2000.1.5]))
        %obelisk-action
        !>([%test %db2 "DROP DATABASE FORCE db1"])
  ::
  =.  run  +(run)
  =^  move7  agent
    %+  ~(on-poke agent (bowl [run ~ ~2000.1.6]))
        %obelisk-action
        !>([%test %db2 "FROM sys.sys.databases SELECT *"])
  ::
  %+  weld  %+  expect-eq
              !>  :-  %results
                      :~  [%message 'DROP DATABASE %db1']
                          [%server-time ~2000.1.5]
                          [%message 'database %db1 dropped']
                          ==
              !>  ;;(cmd-result ->+>+>-.move6)
            %+  expect-eq
              !>  expected
              !>  ;;(cmd-result ->+>+>-.move7)
::
::  drop database from 2 user dbs, table no data
++  test-drop-db-04
  =|  run=@ud
  =/  expected-rows  :~
                      :-  %vector
                          :~  [%database [~.tas %sys]]
                              [%sys-agent [~.ta '/test-agent']]
                              [%sys-tmsp [~.da ~2000.1.1]]
                              [%data-ship [~.p 0]]
                              [%data-agent [~.ta '/test-agent']]
                              [%data-tmsp [~.da ~2000.1.1]]
                              ==
                      :-  %vector
                          :~  [%database [~.tas %db2]]
                              [%sys-agent [~.ta '/test-agent']]
                              [%sys-tmsp [~.da ~2000.1.4]]
                              [%data-ship [~.p 0]]
                              [%data-agent [~.ta '/test-agent']]
                              [%data-tmsp [~.da ~2000.1.4]]
                              ==
                      ==
  ::
  =/  expected  :~  %results
                    [%message 'SELECT']
                    [%result-set expected-rows]
                    [%server-time ~2000.1.6]
                    [%message 'sys.sys.databases']
                    [%schema-time ~2000.1.1]
                    [%data-time ~2000.1.4]
                    [%vector-count 2]
                ==
  ::
  =^  move  agent
    %+  ~(on-poke agent (bowl [run ~ ~2000.1.1]))
        %obelisk-action
        !>([%tape2 %sys "CREATE DATABASE db1 AS OF ~2000.1.1"])
  =.  run  +(run)
  =^  mov3  agent
    %+  ~(on-poke agent (bowl [run ~ ~2000.1.2]))
        %obelisk-action
        !>  :+  %tape2
                %db1
                "CREATE TABLE db1..my-table (col1 @t) PRIMARY KEY (col1)"
  =.  run  +(run)
  =^  move4  agent
    %+  ~(on-poke agent (bowl [run ~ ~2000.1.4]))
        %obelisk-action
        !>([%tape2 %sys "CREATE DATABASE db2"])
  ::
  =.  run  +(run)
  =^  move5  agent
    %+  ~(on-poke agent (bowl [run ~ ~2000.1.5]))
        %obelisk-action
        !>([%test %db1 "DROP DATABASE db1"])
  ::
  =.  run  +(run)
  =^  move6  agent
    %+  ~(on-poke agent (bowl [run ~ ~2000.1.6]))
        %obelisk-action
        !>([%test %db2 "FROM sys.sys.databases SELECT *"])
  ::
  %+  weld  %+  expect-eq
              !>  :-  %results
                      :~  [%message 'DROP DATABASE %db1']
                          [%server-time ~2000.1.5]
                          [%message 'database %db1 dropped']
                          ==
              !>  ;;(cmd-result ->+>+>-.move5)
            %+  expect-eq
              !>  expected
              !>  ;;(cmd-result ->+>+>-.move6)
::
::  drop database from 2 user dbs, table with data no FORCE
++  test-fail-drop-db-01
  =|  run=@ud
  ::
  =^  move  agent
    %+  ~(on-poke agent (bowl [run ~ ~2000.1.1]))
        %obelisk-action
        !>([%tape2 %sys "CREATE DATABASE db1 AS OF ~2000.1.1"])
  =.  run  +(run)
  =^  mov3  agent
    %+  ~(on-poke agent (bowl [run ~ ~2000.1.2]))
        %obelisk-action
        !>  :+  %tape2
                %db1
                "CREATE TABLE db1..my-table (col1 @t) PRIMARY KEY (col1)"
  =.  run  +(run)
  =^  mov4  agent
    %+  ~(on-poke agent (bowl [run ~ ~2000.1.3]))
        %obelisk-action
        !>  :+  %tape2
                %db1
                "INSERT INTO db1..my-table (col1) VALUES ('cord') "
  =.  run  +(run)
  =^  move5  agent
    %+  ~(on-poke agent (bowl [run ~ ~2000.1.4]))
        %obelisk-action
        !>([%tape2 %sys "CREATE DATABASE db2"])
  ::
  %+  expect-fail-message
        '%db1 has populated tables and `FORCE` was not specified'
  |.  %+  ~(on-poke agent (bowl [run ~ ~2000.1.6]))
          %obelisk-action
          !>  :+  %test
                  %db1
                  "DROP DATABASE db1"
::
::  drop database db does not exist
++  test-fail-drop-db-02
  =|  run=@ud
  ::
  =^  move  agent
    %+  ~(on-poke agent (bowl [run ~ ~2000.1.1]))
        %obelisk-action
        !>([%tape2 %sys "CREATE DATABASE db1 AS OF ~2000.1.1"])
  =.  run  +(run)
  =^  mov3  agent
    %+  ~(on-poke agent (bowl [run ~ ~2000.1.2]))
        %obelisk-action
        !>  :+  %tape2
                %db1
                "CREATE TABLE db1..my-table (col1 @t) PRIMARY KEY (col1)"
  =.  run  +(run)
  =^  mov4  agent
    %+  ~(on-poke agent (bowl [run ~ ~2000.1.3]))
        %obelisk-action
        !>  :+  %tape2
                %db1
                "INSERT INTO db1..my-table (col1) VALUES ('cord') "
  =.  run  +(run)
  =^  move5  agent
    %+  ~(on-poke agent (bowl [run ~ ~2000.1.4]))
        %obelisk-action
        !>([%tape2 %sys "CREATE DATABASE db2"])
  ::
  %+  expect-fail-message
        'database %db3 does not exist'
  |.  %+  ~(on-poke agent (bowl [run ~ ~2000.1.6]))
          %obelisk-action
          !>  :+  %test
                  %db1
                  "DROP DATABASE db3"
::
::  fail schema change after query
++  test-fail-drop-db-03
  =|  run=@ud
  ::
  =^  move  agent
    %+  ~(on-poke agent (bowl [run ~ ~2000.1.1]))
        %obelisk-action
        !>([%tape2 %sys "CREATE DATABASE db1 AS OF ~2000.1.1"])
  =.  run  +(run)
  =^  mov2  agent
    %+  ~(on-poke agent (bowl [run ~ ~2000.1.2]))
        %obelisk-action
        !>  :+  %tape2
                %db1
                "CREATE TABLE db1..my-table (col1 @t) PRIMARY KEY (col1)"
  =.  run  +(run)
  =^  mov3  agent
    %+  ~(on-poke agent (bowl [run ~ ~2000.1.3]))
        %obelisk-action
        !>  :+  %tape2
                %db1
                "INSERT INTO db1..my-table (col1) VALUES ('cord') "
  =.  run  +(run)
  =^  move4  agent
    %+  ~(on-poke agent (bowl [run ~ ~2000.1.4]))
        %obelisk-action
        !>([%tape2 %sys "CREATE DATABASE db2"])
  ::
  %+  expect-fail-message
        'DROP DATABASE: state change after query in script'
  |.  %+  ~(on-poke agent (bowl [run ~ ~2012.5.3]))
          %obelisk-action
          !>  :+  %test
                  %db1
                  "FROM db1..my-table SELECT *; ".
                  "DROP DATABASE db2 "
::
::  fail on not dropped by local agent

::  to do:  re-enable this test after persmissions implemented
::          currently fails on wrong message
::++  test-fail-drop-db-04
::  =|  run=@ud
::  ::
::  =^  move  agent
::    %+  ~(on-poke agent (bowl [run ~ ~2000.1.1]))
::        %obelisk-action
::        !>([%tape2 %sys "CREATE DATABASE db1 AS OF ~2000.1.1"])
::  =.  run  +(run)
::  =^  mov2  agent
::    %+  ~(on-poke agent (bowl [run ~ ~2000.1.2]))
::        %obelisk-action
::        !>  :+  %tape2
::                %db1
::                "CREATE TABLE db1..my-table (col1 @t) PRIMARY KEY (col1)"
::  =.  run  +(run)
::  =^  mov3  agent
::    %+  ~(on-poke agent (bowl [run ~ ~2000.1.3]))
::        %obelisk-action
::        !>  :+  %tape2
::                %db1
::                "INSERT INTO db1..my-table (col1) VALUES ('cord') "
::  =.  run  +(run)
::  =^  move4  agent
::    %+  ~(on-poke agent (bowl [run ~ ~2000.1.4]))
::        %obelisk-action
::        !>([%tape2 %sys "CREATE DATABASE db2"])
::  ::
::  %+  expect-fail-message
::        'DROP DATABASE: database must be dropped by local agent'
::  |.  %+  ~(on-poke agent (bowl [run `~nec ~2012.5.3]))
::      %obelisk-action
::      !>  :+  %test
::              %db1
::              "DROP DATABASE db2 "
::
::  fail on attempt to drop %sys database
++  test-fail-drop-db-05
  =|  run=@ud
  ::
  =^  move  agent
    %+  ~(on-poke agent (bowl [run ~ ~2000.1.1]))
        %obelisk-action
        !>([%tape2 %sys "CREATE DATABASE db1"])
  %+  expect-fail-message
        'database %sys cannot be dropped'
  |.  %+  ~(on-poke agent (bowl [run ~ ~2012.5.3]))
          %obelisk-action
          !>  :+  %test
                  %db1
                  "DROP DATABASE sys "
::
::  CREATE NAMESPACE
::
::  Create namespace, not default DB
++  test-create-namepsace-01
  =|  run=@ud
  =^  mov1  agent
    %+  ~(on-poke agent (bowl [run ~ ~2000.1.1]))
        %obelisk-action
        !>([%tape2 %sys "CREATE DATABASE db1"])
  =.  run  +(run)
  =^  mov2  agent
    %+  ~(on-poke agent (bowl [run ~ ~2000.1.2]))
        %obelisk-action
        !>([%tape2 %sys "CREATE DATABASE db2"])
  =.  run  +(run)
  =^  mov3  agent
    %+  ~(on-poke agent (bowl [run ~ ~2000.1.3]))
        %obelisk-action
        !>([%test %db1 "CREATE NAMESPACE db2.ns1"])
  =.  run  +(run)
  =^  mov4  agent
    %+  ~(on-poke agent (bowl [run ~ ~2000.1.4]))
        %obelisk-action
        !>  :+  %test
                %db1
                "CREATE TABLE db2.ns1.my-table (col1 @t) PRIMARY KEY (col1)"
  ::
  %+  weld  %+  expect-eq
              !>  :-  %results
                      :~  [%message 'CREATE NAMESPACE %ns1']
                          [%server-time ~2000.1.3]
                          [%schema-time ~2000.1.3]
                          ==
              !>  ;;(cmd-result ->+>+>-.mov3)
            %+  expect-eq
              !>  :-  %results
                      :~  [%message 'CREATE TABLE %my-table']
                          [%server-time ~2000.1.4]
                          [%schema-time ~2000.1.4]
                          ==
              !>  ;;(cmd-result ->+>+>-.mov4)
::
::  fail on duplicate namepsace
++  test-fail-create-namespace-01
  =|  run=@ud
  =^  mov1  agent
    %+  ~(on-poke agent (bowl [run ~ ~2000.1.1]))
        %obelisk-action
        !>([%commands ~[[%create-database 'db1' ~]]])
  =.  run  +(run)
  =^  mov2  agent
    %+  ~(on-poke agent (bowl [run ~ ~2000.1.2]))
        %obelisk-action
        !>([%commands ~[[%create-namespace %db1 %ns1 ~]]])
  =.  run  +(run)
  ::
  %+  expect-fail-message
        'CREATE NAMESPACE: namespace %ns1 already exists'
  |.  %+  ~(on-poke agent (bowl [run ~ ~2000.1.3]))
          %obelisk-action
          !>([%commands ~[[%create-namespace %db1 %ns1 ~]]])
::
::  fail on database does not exist
++  test-fail-create-namespace-02
  =|  run=@ud
  =^  mov1  agent
    %+  ~(on-poke agent (bowl [run ~ ~2000.1.1]))
        %obelisk-action
        !>([%commands ~[[%create-database 'db1' ~]]])
  =.  run  +(run)
  ::
  %+  expect-fail-message
        'CREATE NAMESPACE: database %db does not exist'
  |.  %+  ~(on-poke agent (bowl [run ~ ~2000.1.3]))
          %obelisk-action
          !>([%commands ~[[%create-namespace %db %ns1 ~]]])
::
:: fail on time, create ns = schema
++  test-fail-create-namespace-03
  =|  run=@ud
  =^  mov1  agent
    %+  ~(on-poke agent (bowl [run ~ ~2000.1.1]))
        %obelisk-action
        !>  :+  %tape2
                %sys
                "CREATE DATABASE db1 as of ~2023.7.9..22.35.35..7e90"
  =.  run  +(run)
  ::
  %+  expect-fail-message
        'CREATE NAMESPACE: namespace %ns1 as-of schema time out of order'
  |.  %+  ~(on-poke agent (bowl [run ~ ~2000.1.2]))
          %obelisk-action
          !>  :+  %test
                  %db1
                  "CREATE NAMESPACE ns1 as of ~2023.7.9..22.35.35..7e90"
::
:: fail on time, create ns lt schema
++  test-fail-create-namespace-04
  =|  run=@ud
  =^  mov1  agent
    %+  ~(on-poke agent (bowl [run ~ ~2000.1.1]))
        %obelisk-action
        !>  :+  %tape2
                %sys
                "CREATE DATABASE db1 as of ~2023.7.9..22.35.35..7e90"
  =.  run  +(run)
  ::
  %+  expect-fail-message
        'CREATE NAMESPACE: namespace %ns1 as-of schema time out of order'
  |.  %+  ~(on-poke agent (bowl [run ~ ~2000.1.2]))
          %obelisk-action
          !>  :+  %test
                  %db1
                  "CREATE NAMESPACE ns1 as of ~2023.7.9..22.35.34..7e90"
::
::  fail on time, create ns = content
++  test-fail-create-namespace-05
  =|  run=@ud
  =^  mov1  agent
    %+  ~(on-poke agent (bowl [run ~ ~2000.1.1]))
        %obelisk-action
        !>([%tape2 %sys "CREATE DATABASE db1"])
  =.  run  +(run)
  =^  mov2  agent
    %+  ~(on-poke agent (bowl [run ~ ~2000.1.2]))
        %obelisk-action
        !>  :+  %tape2
                %db1
                "CREATE TABLE db1..my-table (col1 @t) PRIMARY KEY (col1)"
  =.  run  +(run)
  =^  mov3  agent
    %+  ~(on-poke agent (bowl [run ~ ~2023.7.9..22.35.35..7e90]))
        %obelisk-action
        !>  :+  %tape2
                %db1
                "INSERT INTO db1..my-table ".
                "(col1) VALUES ('cord') "
  =.  run  +(run)
  ::
  %+  expect-fail-message
        'CREATE NAMESPACE: namespace %ns1 as-of content time out of order'
  |.  %+  ~(on-poke agent (bowl [run ~ ~2000.1.2]))
          %obelisk-action
          !>  :+  %test
                  %db1
                  "CREATE NAMESPACE ns1 as of ~2023.7.9..22.35.35..7e90"
::
::  fail on time, create ns lt content
++  test-fail-create-namespace-06
  =|  run=@ud
  =^  mov1  agent
    %+  ~(on-poke agent (bowl [run ~ ~2000.1.1]))
        %obelisk-action
        !>([%tape2 %sys "CREATE DATABASE db1"])
  =.  run  +(run)
  =^  mov2  agent
    %+  ~(on-poke agent (bowl [run ~ ~2000.1.2]))
        %obelisk-action
        !>  :+  %tape2
                %db1
                "CREATE TABLE db1..my-table (col1 @t) PRIMARY KEY (col1)"
  =.  run  +(run)
  =^  mov3  agent
    %+  ~(on-poke agent (bowl [run ~ ~2023.7.9..22.35.35..7e90]))
        %obelisk-action
        !>  :+  %tape2
                %db1
                "INSERT INTO db1..my-table ".
                "(col1) VALUES ('cord') "
  =.  run  +(run)
  ::
  %+  expect-fail-message
        'CREATE NAMESPACE: namespace %ns1 as-of content time out of order'
  |.  %+  ~(on-poke agent (bowl [run ~ ~2000.1.2]))
          %obelisk-action
          !>  :+  %test
                  %db1
                  "CREATE NAMESPACE ns1 as of ~2023.7.9..22.35.34..7e90"
::
::  fail on foreign source agent

::  to do:  re-enable this test after persmissions implemented
::          currently fails on wrong message
::++  test-fail-create-namespace-07
::  =|  run=@ud
::  =^  mov1  agent
::    %+  ~(on-poke agent (bowl [run ~ ~2000.1.1]))
::        %obelisk-action
::        !>([%tape2 %sys "CREATE DATABASE db1"])
::  =.  run  +(run)
::  ::
::  %+  expect-fail-message
::        'CREATE NAMESPACE: schema changes must be by local agent'
::  |.  %+  ~(on-poke agent (bowl [run `~nec ~2000.1.2]))
::      %obelisk-action
::      !>  :+  %test
::              %db1
::              "CREATE NAMESPACE ns1"
::
::  CREATE TABLE
::
::  Create table, not default DB
++  test-create-table-01
  =|  run=@ud
  =^  mov1  agent
    %+  ~(on-poke agent (bowl [run ~ ~2000.1.1]))
        %obelisk-action
        !>([%tape2 %sys "CREATE DATABASE db1"])
  =.  run  +(run)
  =^  mov2  agent
    %+  ~(on-poke agent (bowl [run ~ ~2000.1.2]))
        %obelisk-action
        !>([%tape2 %sys "CREATE DATABASE db2"])
  =.  run  +(run)
  =^  mov3  agent
    %+  ~(on-poke agent (bowl [run ~ ~2000.1.3]))
        %obelisk-action
        !>  :+  %test
                %db1
                "CREATE TABLE db2..my-table (col1 @t) PRIMARY KEY (col1)"
  ::
  %+  expect-eq
    !>  :-  %results
            :~  [%message 'CREATE TABLE %my-table']
                [%server-time ~2000.1.3]
                [%schema-time ~2000.1.3]
                ==
    !>  ;;(cmd-result ->+>+>-.mov3)
::
::  fail on database does not exist
++  test-fail-create-table-01
  =|  run=@ud
  =/  cmd
    :*  %create-table
        [%qualified-object ship=~ database='db' namespace='dbo' name='my-table' alias=~]
        :~  [%column name='col1' column-type=%t]
            [%column name='col2' column-type=%p]
            [%column name='col3' column-type=%ud]
        ==
        pri-indx=~[[%ordered-column column-name='col1' ascending=%.y]]
        foreign-keys=~
        as-of=~
    ==
  =^  mov1  agent
    %+  ~(on-poke agent (bowl [run ~ ~2000.1.1]))
        %obelisk-action
        !>([%commands ~[[%create-database 'db1' ~]]])
  =.  run  +(run)
  ::
  %+  expect-fail-message
        'CREATE TABLE: database %db does not exist'
  |.  %+  ~(on-poke agent (bowl [run ~ ~2000.1.4]))
          %obelisk-action
          !>([%commands ~[cmd]])
::
::  fail on namespace does not exist
++  test-fail-create-table-02
  =|  run=@ud
  =/  cmd
    :*  %create-table
        :*  %qualified-object
            ship=~
            database='db1'
            namespace='ns1'
            name='my-table'
            alias=~
        ==
        :~  [%column name='col1' column-type=%t]
            [%column name='col2' column-type=%p]
            [%column name='col3' column-type=%ud]
        ==
        pri-indx=~[[%ordered-column column-name='col1' ascending=%.y]]
        foreign-keys=~
        as-of=~
    ==
  =^  mov1  agent
    %+  ~(on-poke agent (bowl [run ~ ~2000.1.1]))
        %obelisk-action
        !>([%commands ~[[%create-database 'db1' ~]]])
  =.  run  +(run)
  ::
  %+  expect-fail-message
        'CREATE TABLE: namespace %ns1 does not exist'
  |.  %+  ~(on-poke agent (bowl [run ~ ~2000.1.4]))
          %obelisk-action
          !>([%commands ~[cmd]])
::
::  fail on duplicate table name
++  test-fail-create-table-03
  =|  run=@ud
  =/  cmd
    :*  %create-table
        :*  %qualified-object
            ship=~
            database='db1'
            namespace='dbo'
            name='my-table'
            alias=~
        ==
        :~  [%column name='col1' column-type=%t]
            [%column name='col2' column-type=%p]
            [%column name='col3' column-type=%ud]
        ==
        pri-indx=~[[%ordered-column column-name='col1' ascending=%.y]]
        foreign-keys=~
        as-of=~
    ==
  =^  mov1  agent
    %+  ~(on-poke agent (bowl [run ~ ~2000.1.1]))
        %obelisk-action
        !>([%commands ~[[%create-database 'db1' ~]]])
  =.  run  +(run)
  =^  mov2  agent
    %+  ~(on-poke agent (bowl [run ~ ~2000.1.2]))
        %obelisk-action
        !>([%commands ~[cmd]])
  =.  run  +(run)
  ::
  %+  expect-fail-message
        'CREATE TABLE: %my-table exists in %dbo'
  |.  %+  ~(on-poke agent (bowl [run ~ ~2000.1.4]))
          %obelisk-action
          !>([%commands ~[cmd]])
::
::  fail on duplicate column names
++  test-fail-create-table-04
  =|  run=@ud
  =/  cmd
    :*  %create-table
        :*  %qualified-object
            ship=~
            database='db1'
            namespace='dbo'
            name='my-table'
            alias=~
        ==
        :~  [%column name='col1' column-type=%t]
            [%column name='col2' column-type=%p]
            [%column name='col1' column-type=%t]
        ==
        pri-indx=~[[%ordered-column column-name='col1' ascending=%.y]]
        foreign-keys=~
        as-of=~
    ==
  =^  mov1  agent
    %+  ~(on-poke agent (bowl [run ~ ~2000.1.1]))
        %obelisk-action
        !>([%commands ~[[%create-database 'db1' ~]]])
  =.  run  +(run)
  ::
  %+  expect-fail-message
    %-  crip  
        "CREATE TABLE: duplicate column names ~[[%column name=%col1 type=~.t] ".
        "[%column name=%col2 type=~.p] [%column name=%col1 type=~.t]]"
  |.  %+  ~(on-poke agent (bowl [run ~ ~2000.1.4]))
          %obelisk-action
          !>([%commands ~[cmd]])
::
::  fail on time, create table = content
++  test-fail-create-table-05
  =|  run=@ud
  =^  mov1  agent
    %+  ~(on-poke agent (bowl [run ~ ~2000.1.1]))
        %obelisk-action
        !>([%tape2 %sys "CREATE DATABASE db1"])
  =.  run  +(run)
  =^  mov2  agent
    %+  ~(on-poke agent (bowl [run ~ ~2000.1.2]))
        %obelisk-action
        !>  :+  %tape2
                %db1
                "CREATE TABLE db1..my-table (col1 @t) PRIMARY KEY (col1)"
  =.  run  +(run)
  =^  mov3  agent
    %+  ~(on-poke agent (bowl [run ~ ~2023.7.9..22.35.35..7e90]))
        %obelisk-action
        !>  :+  %tape2
                %db1
                "INSERT INTO db1..my-table ".
                "(col1) VALUES ('cord') "
  =.  run  +(run)
  ::
  %+  expect-fail-message
        'CREATE TABLE: table %my-table-2 as-of data time out of order'
  |.  %+  ~(on-poke agent (bowl [run ~ ~2000.1.2]))
          %obelisk-action
          !>  :+  %test
                  %db1
                  "CREATE TABLE db1..my-table-2 (col1 @t) PRIMARY KEY (col1) ".
                  "AS OF ~2023.7.9..22.35.35..7e90"
::
::  fail on time, create table < content
++  test-fail-create-table-06
  =|  run=@ud
  =^  mov1  agent
    %+  ~(on-poke agent (bowl [run ~ ~2000.1.1]))
        %obelisk-action
        !>([%tape2 %sys "CREATE DATABASE db1"])
  =.  run  +(run)
  =^  mov2  agent
    %+  ~(on-poke agent (bowl [run ~ ~2000.1.2]))
        %obelisk-action
        !>  :+  %tape2
                %db1
                "CREATE TABLE db1..my-table (col1 @t) PRIMARY KEY (col1)"
  =.  run  +(run)
  =^  mov3  agent
    %+  ~(on-poke agent (bowl [run ~ ~2023.7.9..22.35.35..7e90]))
        %obelisk-action
        !>  :+  %tape2
                %db1
                "INSERT INTO db1..my-table ".
                "(col1) VALUES ('cord') "
  =.  run  +(run)
  ::
  %+  expect-fail-message
        'CREATE TABLE: table %my-table-2 as-of data time out of order'
  |.  %+  ~(on-poke agent (bowl [run ~ ~2000.1.2]))
          %obelisk-action
          !>  :+  %test
                  %db1
                  "CREATE TABLE db1..my-table-2 (col1 @t) PRIMARY KEY (col1) ".
                  "AS OF ~2023.7.9..22.35.35..7e90"
::
::  fail on time, create table = schema
++  test-fail-create-table-07
  =|  run=@ud
  =^  mov1  agent
    %+  ~(on-poke agent (bowl [run ~ ~2000.1.1]))
        %obelisk-action
        !>  :+  %tape2
                %sys
                "CREATE DATABASE db1 as of ~2023.7.9..22.35.35..7e90"
  =.  run  +(run)
  ::
  %+  expect-fail-message
        'CREATE TABLE: table %my-table-2 as-of schema time out of order'
  |.  %+  ~(on-poke agent (bowl [run ~ ~2000.1.2]))
          %obelisk-action
          !>  :+  %test
                  %db1
                  "CREATE TABLE db1..my-table-2 (col1 @t, col2 @p) ".
                  "PRIMARY KEY (col1, col2) ".
                  "as of ~2023.7.9..22.35.35..7e90"
::
::  fail on time, create table lt schema
++  test-fail-create-table-08
  =|  run=@ud
  =^  mov1  agent
    %+  ~(on-poke agent (bowl [run ~ ~2000.1.1]))
        %obelisk-action
        !>  :+  %tape2
                %sys
                "CREATE DATABASE db1 as of ~2023.7.9..22.35.35..7e90"
  =.  run  +(run)
  ::
  %+  expect-fail-message
        'CREATE TABLE: table %my-table-2 as-of schema time out of order'
  |.  %+  ~(on-poke agent (bowl [run ~ ~2000.1.2]))
          %obelisk-action
          !>  :+  %test
                  %db1
                  "CREATE TABLE db1..my-table-2 (col1 @t, col2 @p) ".
                    "PRIMARY KEY (col1, col2) ".
                    "as of ~2023.7.9..22.35.34..7e90"
::
::  fail on key column not in column definitions
++  test-fail-create-table-09
  =|  run=@ud
  =/  cmd
    :*  %create-table
        :*  %qualified-object
            ship=~
            database='db1'
            namespace='dbo'
            name='my-table'
            alias=~
        ==
        :~  [%column name='col1' column-type=%t]
            [%column name='col2' column-type=%p]
            [%column name='col3' column-type=%ud]
        ==
        :~  [%ordered-column column-name='col1' ascending=%.y]
            [%ordered-column column-name='col4' ascending=%.y]
        ==
        foreign-keys=~
        as-of=~
    ==
  =^  mov1  agent
    %+  ~(on-poke agent (bowl [run ~ ~2000.1.1]))
        %obelisk-action
        !>([%commands ~[[%create-database 'db1' ~]]])
  =.  run  +(run)
  ::
  %+  expect-fail-message
  %-  crip  
        "CREATE TABLE: key column not in column definitions ".
        "~[[%ordered-column name=%col1 ascending=%.y] ".
        "[%ordered-column name=%col4 ascending=%.y]]"
  |.  %+  ~(on-poke agent (bowl [run ~ ~2000.1.2]))
          %obelisk-action
          !>([%commands ~[cmd]])
::
::  fail on duplicate column names in key
++  test-fail-create-table-10
  =|  run=@ud
  =/  cmd
    :*  %create-table
        :*  %qualified-object
            ship=~
            database='db1'
            namespace='dbo'
            name='my-table'
            alias=~
        ==
        :~  [%column name='col1' column-type=%t]
            [%column name='col2' column-type=%p]
            [%column name='col3' column-type=%t]
        ==
        :~  [%ordered-column column-name='col1' ascending=%.y]
            [%ordered-column column-name='col1' ascending=%.n]
            ==
        foreign-keys=~
        as-of=~
    ==
  =^  mov1  agent
    %+  ~(on-poke agent (bowl [run ~ ~2000.1.1]))
        %obelisk-action
        !>([%commands ~[[%create-database 'db1' ~]]])
  =.  run  +(run)
  ::
  %+  expect-fail-message
    %-  crip  
        "CREATE TABLE: duplicate column names in key ".
        "~[[%ordered-column name=%col1 ascending=%.y] ".
        "[%ordered-column name=%col1 ascending=%.n]]"
  |.  %+  ~(on-poke agent (bowl [run ~ ~2000.1.4]))
          %obelisk-action
          !>([%commands ~[cmd]])
::
::  fail table must be created by local agent

::  to do:  re-enable this test after persmissions implemented
::          currently fails on wrong message
::++  test-fail-create-table-11
::  =|  run=@ud
::  =/  cmd
::    :*  %create-table
::        :*  %qualified-object
::            ship=~
::            database='db1'
::            namespace='dbo'
::            name='my-table'
::            alias=~
::        ==
::        :~  [%column name='col1' column-type=%t]
::            [%column name='col2' column-type=%p]
::            [%column name='col3' column-type=%t]
::        ==
::        pri-indx=~[[%ordered-column column-name='col1' ascending=%.y] [%ordered-column column-name='col1' ascending=%.n]]
::        foreign-keys=~
::        as-of=~
::    ==
::  =^  mov1  agent
::    %+  ~(on-poke agent (bowl [run ~ ~2000.1.1]))
::        %obelisk-action
::        !>([%commands ~[[%create-database 'db1' ~]]])
::  =.  run  +(run)
::  ::
::  %+  expect-fail-message
::        'CREATE TABLE: table must be created by local agent'
::  |.  %+  ~(on-poke agent (bowl [run `~nec ~2000.1.4]))
::      %obelisk-action
::      !>([%commands ~[cmd]])
::
::  fail on state change after query in script
++  test-fail-create-table-12
  =|  run=@ud
  =^  mov1  agent
    %+  ~(on-poke agent (bowl [run ~ ~2000.1.1]))
        %obelisk-action
        !>([%tape2 %sys "CREATE DATABASE db1"])
  =.  run  +(run)
  =^  mov2  agent
    %+  ~(on-poke agent (bowl [run ~ ~2000.1.2]))
        %obelisk-action
        !>  :+  %tape2
                %db1
                "CREATE TABLE db1..my-table (col1 @t) PRIMARY KEY (col1)"
  =.  run  +(run)
  =^  mov3  agent
    %+  ~(on-poke agent (bowl [run ~ ~2000.1.3]))
        %obelisk-action
        !>  :+  %tape2
                %db1
                "INSERT INTO db1..my-table (col1) VALUES ('cord') "
  =.  run  +(run)
  ::
  %+  expect-fail-message
        'CREATE TABLE: state change after query in script'
  |.  %+  ~(on-poke agent (bowl [run ~ ~2000.1.4]))
          %obelisk-action
          !>  :+  %test
                  %db1
                  "FROM my-table SELECT * ".
                  "CREATE TABLE db1..my-table-2 (col1 @t) PRIMARY KEY (col1) "
::
::  Drop table
::
::  drop table with data force, not default DB
++  test-drop-tbl-force
  =|  run=@ud
  =^  mov1  agent
    %+  ~(on-poke agent (bowl [run ~ ~2000.1.1]))
        %obelisk-action
        !>([%tape2 %sys "CREATE DATABASE db1"])
  =.  run  +(run)
  =^  mov2  agent
    %+  ~(on-poke agent (bowl [run ~ ~2000.1.2]))
        %obelisk-action
        !>([%tape2 %sys "CREATE DATABASE db2"])
  =.  run  +(run)
  =^  mov3  agent
    %+  ~(on-poke agent (bowl [run ~ ~2000.1.3]))
        %obelisk-action
        !>  :+  %tape2
                %db2
                "CREATE TABLE my-table (col1 @t) PRIMARY KEY (col1)"
  =.  run  +(run)
  =^  mov4  agent
    %+  ~(on-poke agent (bowl [run ~ ~2000.1.4]))
        %obelisk-action
        !>([%tape2 %db2 "INSERT INTO my-table (col1) VALUES ('cord')"])
  =.  run  +(run)
  =^  mov5  agent
    %+  ~(on-poke agent (bowl [run ~ ~2000.1.5]))
        %obelisk-action
        !>  :+  %test
                %db1
                "DROP TABLE FORCE db2..my-table"
  ::
  %+  expect-eq
    !>  :-  %results
            :~  [%message 'DROP TABLE %my-table']
                [%server-time ~2000.1.5]
                [%schema-time ~2000.1.5]
                [%data-time ~2000.1.5]
                [%vector-count 1]
                ==
    !>  ;;(cmd-result ->+>+>-.mov5)
::
::  fail on time, drop table = schema
++  test-fail-drop-table-01
  =|  run=@ud
  =^  mov1  agent
    %+  ~(on-poke agent (bowl [run ~ ~2000.1.1]))
        %obelisk-action
        !>  :+  %tape2
                %sys
                "CREATE DATABASE db1 as of ~2023.7.9..22.35.35..7e90"
  =.  run  +(run)
  =^  mov2  agent
    %+  ~(on-poke agent (bowl [run ~ ~2000.1.2]))
        %obelisk-action
        !>  :+  %tape2
                %db1
                "CREATE TABLE db1..my-table-2 (col1 @t, col2 @p) ".
                "PRIMARY KEY (col1, col2) ".
                "AS OF ~2023.7.9..22.35.36..7e90"
  =.  run  +(run)
  =^  mov2  agent
    %+  ~(on-poke agent (bowl [run ~ ~2000.1.3]))
        %obelisk-action
        !>([%tape2 %db1 "CREATE NAMESPACE ns1 as of ~2023.7.9..22.35.37..7e90"])
  =.  run  +(run)
  ::
  %+  expect-fail-message
        'DROP TABLE: %my-table-2 as-of schema time out of order'
  |.  %+  ~(on-poke agent (bowl [run ~ ~2000.1.2]))
          %obelisk-action
          !>  :+  %test
                  %db1
                  "DROP TABLE db1..my-table-2 ".
                  "AS OF ~2023.7.9..22.35.37..7e90"
::
::  fail on time, drop table lt schema
++  test-fail-drop-table-02
  =|  run=@ud
  =^  mov1  agent
    %+  ~(on-poke agent (bowl [run ~ ~2000.1.1]))
        %obelisk-action
        !>  :+  %tape2
                %sys
                "CREATE DATABASE db1 as of ~2023.7.9..22.35.35..7e90"
  =.  run  +(run)
  =^  mov2  agent
    %+  ~(on-poke agent (bowl [run ~ ~2000.1.2]))
        %obelisk-action
        !>  :+  %tape2
                %db1
                "CREATE TABLE db1..my-table-2 (col1 @t, col2 @p) ".
                "PRIMARY KEY (col1, col2) ".
                "AS OF ~2023.7.9..22.35.36..7e90"
  =.  run  +(run)
  =^  mov2  agent
    %+  ~(on-poke agent (bowl [run ~ ~2000.1.3]))
        %obelisk-action
        !>([%tape2 %db1 "CREATE NAMESPACE ns1 as of ~2023.7.9..22.35.37..7e90"])
  =.  run  +(run)
  ::
  %+  expect-fail-message
        'DROP TABLE: %my-table-2 as-of schema time out of order'
  |.  %+  ~(on-poke agent (bowl [run ~ ~2000.1.2]))
          %obelisk-action
          !>  :+  %test
                  %db1
                  "DROP TABLE db1..my-table-2 ".
                  "AS OF ~2023.7.9..22.35.36..7e90"
::
::  fail on time, drop table = content
  ++  test-fail-drop-table-03
  =|  run=@ud
  =^  mov1  agent
    %+  ~(on-poke agent (bowl [run ~ ~2000.1.1]))
        %obelisk-action
        !>([%tape2 %sys "CREATE DATABASE db1"])
  =.  run  +(run)
  =^  mov2  agent
    %+  ~(on-poke agent (bowl [run ~ ~2000.1.2]))
        %obelisk-action
        !>  :+  %tape2
                %db1
                "CREATE TABLE db1..my-table (col1 @t) PRIMARY KEY (col1)"
  =.  run  +(run)
  =^  mov3  agent
    %+  ~(on-poke agent (bowl [run ~ ~2023.7.9..22.35.35..7e90]))
        %obelisk-action
        !>  :+  %tape2
                %db1
                "INSERT INTO db1..my-table ".
                "(col1) VALUES ('cord') "
  =.  run  +(run)
  ::
  %+  expect-fail-message
        'DROP TABLE: %my-table as-of data time out of order'
  |.  %+  ~(on-poke agent (bowl [run ~ ~2000.1.2]))
          %obelisk-action
          !>  :+  %test
                  %db1
                  "DROP TABLE FORCE db1..my-table ".
                  "as of ~2023.7.9..22.35.35..7e90"
::
::  fail on time, drop table < content
++  test-fail-drop-table-04
  =|  run=@ud
  =^  mov1  agent
    %+  ~(on-poke agent (bowl [run ~ ~2000.1.1]))
        %obelisk-action
        !>([%tape2 %sys "CREATE DATABASE db1"])
  =.  run  +(run)
  =^  mov2  agent
    %+  ~(on-poke agent (bowl [run ~ ~2000.1.2]))
        %obelisk-action
        !>  :+  %tape2
                %db1
                "CREATE TABLE db1..my-table (col1 @t) PRIMARY KEY (col1)"
  =.  run  +(run)
  =^  mov3  agent
    %+  ~(on-poke agent (bowl [run ~ ~2023.7.9..22.35.35..7e90]))
        %obelisk-action
        !>  :+  %tape2
                %db1
                "INSERT INTO db1..my-table ".
                "(col1) VALUES ('cord') "
  =.  run  +(run)
  ::
  %+  expect-fail-message
        'DROP TABLE: %my-table as-of data time out of order'
  |.  %+  ~(on-poke agent (bowl [run ~ ~2000.1.2]))
          %obelisk-action
          !>  :+  %test
                  %db1
                  "DROP TABLE FORCE db1..my-table ".
                  "as of ~2023.7.9..22.35.34..7e90"
::
::  fail drop table with data no force
++  test-fail-drop-table-05
  =|  run=@ud
  =/  cmd
    :^  %drop-table
        :*  %qualified-object
            ship=~
            database='db1'
            namespace='dbo'
            name='my-table'
            alias=~
        ==
        %.n
        ~
  =^  mov1  agent
    %+  ~(on-poke agent (bowl [run ~ ~2000.1.1]))
        %obelisk-action
        !>([%tape2 %sys "CREATE DATABASE db1"])
  =.  run  +(run)
  =^  mov2  agent
    %+  ~(on-poke agent (bowl [run ~ ~2000.1.2]))
        %obelisk-action
        !>  :+  %tape2
                %db1
                "CREATE TABLE db1..my-table (col1 @t) PRIMARY KEY (col1)"
  =.  run  +(run)
  =^  mov3  agent
    %+  ~(on-poke agent (bowl [run ~ ~2000.1.3]))
        %obelisk-action
        !>([%tape2 %db1 "INSERT INTO db1..my-table (col1) VALUES ('cord')"])
  =.  run  +(run)
  ::
  %+  expect-fail-message
        'DROP TABLE: %my-table has data, use FORCE to DROP'
  |.  %+  ~(on-poke agent (bowl [run ~ ~2000.1.4]))
          %obelisk-action
          !>([%commands ~[cmd]])
::
::  fail on database does not exist
++  test-fail-drop-table-06
  =|  run=@ud
  =/  cmd
    :^  %drop-table
        :*  %qualified-object
            ship=~
            database='db'
            namespace='dbo'
            name='my-table'
            alias=~
        ==
        %.n
        ~
  =^  mov1  agent
    %+  ~(on-poke agent (bowl [run ~ ~2000.1.1]))
        %obelisk-action
        !>([%tape2 %sys "CREATE DATABASE db1"])
  =.  run  +(run)
  ::
  %+  expect-fail-message
        'DROP TABLE: database %db does not exist'
  |.  %+  ~(on-poke agent (bowl [run ~ ~2000.1.4]))
          %obelisk-action
          !>([%commands ~[cmd]])
::
::  fail on namespace does not exist
++  test-fail-drop-table-07
  =|  run=@ud
  =/  cmd
    :^  %drop-table
        :*  %qualified-object
            ship=~
            database='db1'
            namespace='ns1'
            name='my-table'
            alias=~
        ==
        %.n
        ~
  =^  mov1  agent
    %+  ~(on-poke agent (bowl [run ~ ~2000.1.1]))
        %obelisk-action
        !>([%commands ~[[%create-database 'db1' ~]]])
  =.  run  +(run)
  ::
  %+  expect-fail-message
        'DROP TABLE: namespace %ns1 does not exist'
  |.  %+  ~(on-poke agent (bowl [run ~ ~2000.1.4]))
          %obelisk-action
          !>([%commands ~[cmd]])
::
::  fail on table name does not exist
++  test-fail-drop-table-08
  =|  run=@ud
  =/  cmd
    :^  %drop-table
        :*  %qualified-object
            ship=~
            database='db1'
            namespace='dbo'
            name='my-table'
            alias=~
        ==
        %.n
        ~
  =^  mov1  agent
    %+  ~(on-poke agent (bowl [run ~ ~2000.1.1]))
        %obelisk-action
        !>([%commands ~[[%create-database 'db1' ~]]])
  =.  run  +(run)
  ::
  %+  expect-fail-message
        'DROP TABLE: %my-table does not exist in %dbo'
  |.  %+  ~(on-poke agent (bowl [run ~ ~2000.1.4]))
          %obelisk-action
          !>([%commands ~[cmd]])
::
::  fail on state change after query in script
++  test-fail-drop-table-09
  =|  run=@ud
  =^  mov1  agent
    %+  ~(on-poke agent (bowl [run ~ ~2000.1.1]))
        %obelisk-action
        !>([%tape2 %sys "CREATE DATABASE db1"])
  =.  run  +(run)
  =^  mov2  agent
    %+  ~(on-poke agent (bowl [run ~ ~2000.1.2]))
        %obelisk-action
        !>  :+  %tape2
                %db1
                "CREATE TABLE db1..my-table (col1 @t) PRIMARY KEY (col1)"
  =.  run  +(run)
  =^  mov3  agent
    %+  ~(on-poke agent (bowl [run ~ ~2000.1.3]))
        %obelisk-action
        !>([%tape2 %db1 "INSERT INTO db1..my-table (col1) VALUES ('cord')"])
  =.  run  +(run)
  ::
  %+  expect-fail-message
        'DROP TABLE: state change after query in script'
  |.  %+  ~(on-poke agent (bowl [run ~ ~2000.1.4]))
          %obelisk-action
          !>  :+  %test
                  %db1
                  "FROM my-table SELECT * ".
                  "DROP TABLE db1..my-table-2 "
::
::  fail on table must be dropped by local agent

::  to do:  re-enable this test after persmissions implemented
::          currently fails on wrong message
::++  test-fail-drop-table-10
::  =|  run=@ud
::  =^  mov1  agent
::    %+  ~(on-poke agent (bowl [run ~ ~2000.1.1]))
::        %obelisk-action
::        !>([%tape2 %sys "CREATE DATABASE db1"])
::  =.  run  +(run)
::  =^  mov2  agent
::    %+  ~(on-poke agent (bowl [run ~ ~2000.1.2]))
::        %obelisk-action
::        !>  :+  %tape2
::                %db1
::                "CREATE TABLE db1..my-table (col1 @t) PRIMARY KEY (col1)"
::  =.  run  +(run)
::  =^  mov3  agent
::    %+  ~(on-poke agent (bowl [run ~ ~2000.1.3]))
::        %obelisk-action
::        !>([%tape2 %db1 "INSERT INTO db1..my-table (col1) VALUES ('cord')"])
::  =.  run  +(run)
::  ::
::  %+  expect-fail-message
::        'DROP TABLE: table must be dropped by local agent'
::  |.  %+  ~(on-poke agent (bowl [run `~nec ~2000.1.2]))
::      %obelisk-action
::      !>  :+  %test
::              %db1
::              "DROP TABLE db1..my-table-2 "
::
::  Truncate table
::
::  truncate table with data, not default DB
++  test-truncate-table-01
  =|  run=@ud
  =^  mov1  agent
    %+  ~(on-poke agent (bowl [run ~ ~2000.1.1]))
        %obelisk-action
        !>([%tape2 %sys "CREATE DATABASE db1"])
  =.  run  +(run)
  =^  mov2  agent
    %+  ~(on-poke agent (bowl [run ~ ~2000.1.2]))
        %obelisk-action
        !>([%tape2 %sys "CREATE DATABASE db2"])
  =.  run  +(run)
  =^  mov3  agent
    %+  ~(on-poke agent (bowl [run ~ ~2000.1.3]))
        %obelisk-action
        !>  :+  %tape2
                %db2
                "CREATE TABLE my-table (col1 @t) PRIMARY KEY (col1)"
  =.  run  +(run)
  =^  mov4  agent
    %+  ~(on-poke agent (bowl [run ~ ~2000.1.4]))
        %obelisk-action
        !>([%tape2 %db2 "INSERT INTO my-table (col1) VALUES ('cord')"])
  =.  run  +(run)
  =^  mov5  agent
    %+  ~(on-poke agent (bowl [run ~ ~2000.1.5]))
        %obelisk-action
        !>  :+  %test
                %db1
                "TRUNCATE TABLE db2..my-table"
  ::
  %+  expect-eq
    !>  :-  %results
            :~  [%message 'TRUNCATE TABLE db2.dbo.my-table']
                [%server-time ~2000.1.5]
                [%data-time ~2000.1.5]
                [%vector-count 1]
                ==
    !>  ;;(cmd-result ->+>+>-.mov5)
::
::  fail on database does not exist
++  test-fail-truncate-tbl-01
  =|  run=@ud
  =/  cmd
    :+  %truncate-table
        [%qualified-object ship=~ database='db' namespace='dbo' name='my-table' alias=~]
        ~
  =^  mov1  agent
    %+  ~(on-poke agent (bowl [run ~ ~2000.1.1]))
        %obelisk-action
        !>([%commands ~[[%create-database 'db1' ~]]])
  =.  run  +(run)
  ::
  %+  expect-fail-message
        'TRUNCATE TABLE: database %db does not exist'
  |.  %+  ~(on-poke agent (bowl [run ~ ~2000.1.3]))
          %obelisk-action
          !>([%commands ~[cmd]])
::
::  fail on namespace does not exist
++  test-fail-truncate-tbl-02
  =|  run=@ud
  =/  cmd
    :+  %truncate-table
       [%qualified-object ship=~ database='db1' namespace='ns1' name='my-table' alias=~]
        ~
  =^  mov1  agent
    %+  ~(on-poke agent (bowl [run ~ ~2000.1.1]))
        %obelisk-action
        !>([%commands ~[[%create-database 'db1' ~]]])
  =.  run  +(run)
  ::
  %+  expect-fail-message
        'TRUNCATE TABLE: namespace %ns1 does not exist'
  |.  %+  ~(on-poke agent (bowl [run ~ ~2000.1.3]))
          %obelisk-action
          !>([%commands ~[cmd]])
::
::  fail on table name does not exist
++  test-fail-truncate-tbl-03
  =|  run=@ud
  =/  cmd
    :+  %truncate-table
        :*  %qualified-object
            ship=~
            database='db1'
            namespace='dbo'
            name='my-table'
            alias=~
        ==
        ~
  =^  mov1  agent
    %+  ~(on-poke agent (bowl [run ~ ~2000.1.1]))
        %obelisk-action
        !>([%commands ~[[%create-database 'db1' ~]]])
  =.  run  +(run)
  ::
  %+  expect-fail-message
        'TRUNCATE TABLE: %my-table does not exists in %dbo'
  |.  %+  ~(on-poke agent (bowl [run ~ ~2000.1.3]))
          %obelisk-action
          !>([%commands ~[cmd]])
::
::  fail on state change after query in script
++  test-fail-truncate-table-04
  =|  run=@ud
  =^  mov1  agent
    %+  ~(on-poke agent (bowl [run ~ ~2000.1.1]))
        %obelisk-action
        !>([%tape2 %sys "CREATE DATABASE db1"])
  =.  run  +(run)
  =^  mov2  agent
    %+  ~(on-poke agent (bowl [run ~ ~2000.1.2]))
        %obelisk-action
        !>  :+  %tape2
                %db1
                "CREATE TABLE db1..my-table (col1 @t) PRIMARY KEY (col1)"
  =.  run  +(run)
  =^  mov3  agent
    %+  ~(on-poke agent (bowl [run ~ ~2000.1.3]))
        %obelisk-action
        !>([%tape2 %db1 "INSERT INTO db1..my-table (col1) VALUES ('cord')"])
  =.  run  +(run)
  ::
  %+  expect-fail-message
        'TRUNCATE TABLE: state change after query in script'
  |.  %+  ~(on-poke agent (bowl [run ~ ~2000.1.4]))
          %obelisk-action
          !>  :+  %test
                  %db1
                  "FROM my-table SELECT * ".
                  "TRUNCATE TABLE db1..my-table-2 "
::
::  fail on time, truncate table lt schema
++  test-fail-truncate-tbl-05
  =|  run=@ud
  =^  mov1  agent
    %+  ~(on-poke agent (bowl [run ~ ~2000.1.1]))
        %obelisk-action
        !>  :+  %tape2
                %sys
                "CREATE DATABASE db1 as of ~2023.7.9..22.35.35..7e90"
  =.  run  +(run)
  =^  mov2  agent
    %+  ~(on-poke agent (bowl [run ~ ~2000.1.2]))
        %obelisk-action
        !>  :+  %tape2
                %db1
                "CREATE TABLE db1..my-table-2 (col1 @t, col2 @p) ".
                "PRIMARY KEY (col1, col2) ".
                "AS OF ~2023.7.9..22.35.36..7e90"
  =.  run  +(run)
  =^  mov2  agent
    %+  ~(on-poke agent (bowl [run ~ ~2000.1.3]))
        %obelisk-action
        !>([%tape2 %db1 "CREATE NAMESPACE ns1 as of ~2023.7.9..22.35.37..7e90"])
  =.  run  +(run)
  ::
  %+  expect-fail-message
        'TRUNCATE TABLE: %my-table-2 as-of schema time out of order'
  |.  %+  ~(on-poke agent (bowl [run ~ ~2000.1.2]))
          %obelisk-action
          !>  :+  %test
                  %db1
                  "TRUNCATE TABLE db1..my-table-2 ".
                  "AS OF ~2023.7.9..22.35.36..7e90"
::
::  fail on time, truncate table = content
++  test-fail-truncate-tbl-06
  =|  run=@ud
  =^  mov1  agent
    %+  ~(on-poke agent (bowl [run ~ ~2000.1.1]))
        %obelisk-action
        !>([%tape2 %sys "CREATE DATABASE db1"])
  =.  run  +(run)
  =^  mov2  agent
    %+  ~(on-poke agent (bowl [run ~ ~2000.1.2]))
        %obelisk-action
        !>  :+  %tape2
                %db1
                "CREATE TABLE db1..my-table (col1 @t) PRIMARY KEY (col1)"
  =.  run  +(run)
  =^  mov3  agent
    %+  ~(on-poke agent (bowl [run ~ ~2023.7.9..22.35.35..7e90]))
        %obelisk-action
        !>  :+  %tape2
                %db1
                "INSERT INTO db1..my-table ".
                "(col1) VALUES ('cord') "
  =.  run  +(run)
  ::
  %+  expect-fail-message
        'TRUNCATE TABLE: %my-table as-of data time out of order'
  |.  %+  ~(on-poke agent (bowl [run ~ ~2000.1.2]))
          %obelisk-action
          !>  :+  %test
                  %db1
                  "TRUNCATE TABLE db1..my-table as of ~2023.7.9..22.35.35..7e90"
::
::  fail on time, truncate table = content with AS OF ... AGO
++  test-fail-truncate-tbl-07
  =|  run=@ud
  =^  mov1  agent
    %+  ~(on-poke agent (bowl [run ~ ~2000.1.1]))
        %obelisk-action
        !>([%tape2 %sys "CREATE DATABASE db1"])
  =.  run  +(run)
  =^  mov2  agent
    %+  ~(on-poke agent (bowl [run ~ ~2000.1.2]))
        %obelisk-action
        !>  :+  %tape2
                %db1
                "CREATE TABLE db1..my-table (col1 @t) PRIMARY KEY (col1)"
  =.  run  +(run)
  =^  mov3  agent
    %+  ~(on-poke agent (bowl [run ~ ~2000.1.3]))
        %obelisk-action
        !>  :+  %tape2
                %db1
                "INSERT INTO db1..my-table (col1) VALUES ('cord') "
  =.  run  +(run)
  ::
  %+  expect-fail-message
        'TRUNCATE TABLE: %my-table as-of data time out of order'
  |.  %+  ~(on-poke agent (bowl [run ~ ~2000.1.4]))
          %obelisk-action
          !>  :+  %test
                  %db1
                  "TRUNCATE TABLE my-table as of 1 day ago"
--
