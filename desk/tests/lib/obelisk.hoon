::  unit tests on %obelisk library simulating pokes
::
/+  *test-helpers, utils
|%
::
::  Set TMSP
::
::  set-tmsp back 0 seconds
++  test-set-tmsp-00
  %+  expect-eq
    !>  ~2023.12.25..7.15.0..1ef5
    !>  %-  set-tmsp:utils
            :-  `(as-of-offset:ast %as-of-offset 0 %seconds)
                ~2023.12.25..7.15.0..1ef5
::
::  set-tmsp back 65 seconds
++  test-set-tmsp-01
  %+  expect-eq
    !>  ~2023.12.25..7.13.55..1ef5
    !>  %-  set-tmsp:utils
          :-  `(as-of-offset:ast %as-of-offset 65 %seconds)
              ~2023.12.25..7.15.0..1ef5
::
::  set-tmsp back 0 minutes
++  test-set-tmsp-02
  %+  expect-eq
    !>  ~2023.12.25..7.15.0..1ef5
    !>  %-  set-tmsp:utils
            :-  `(as-of-offset:ast %as-of-offset 0 %minutes)
                ~2023.12.25..7.15.0..1ef5
::
::  set-tmsp back 65 minutes
++  test-set-tmsp-03
  %+  expect-eq
    !>  ~2023.12.25..6.10.0..1ef5
    !>  %-  set-tmsp:utils
            :-  `(as-of-offset:ast %as-of-offset 65 %minutes)
                ~2023.12.25..7.15.0..1ef5
::
::  set-tmsp back 0 hours
++  test-set-tmsp-04
  %+  expect-eq
    !>  ~2023.12.25..7.15.0..1ef5
    !>  %-  set-tmsp:utils
            :-  `(as-of-offset:ast %as-of-offset 0 %hours)
                ~2023.12.25..7.15.0..1ef5
::
::  set-tmsp back 65 hours
++  test-set-tmsp-05
  %+  expect-eq
    !>  ~2023.12.22..14.15.0..1ef5
    !>  %-  set-tmsp:utils
            :-  `(as-of-offset:ast %as-of-offset 65 %hours)
                ~2023.12.25..7.15.0..1ef5
::
::  set-tmsp back 0 days
++  test-set-tmsp-06
  %+  expect-eq
    !>  ~2023.12.25..7.15.0..1ef5
    !>  %-  set-tmsp:utils
            :-  `(as-of-offset:ast %as-of-offset 0 %days)
                ~2023.12.25..7.15.0..1ef5
::
::  set-tmsp back 65 days
++  test-set-tmsp-07
  %+  expect-eq
    !>  ~2023.10.21..7.15.0..1ef5
    !>  %-  set-tmsp:utils
            :-  `(as-of-offset:ast %as-of-offset 65 %days)
                ~2023.12.25..7.15.0..1ef5
::
::  set-tmsp back 0 weeks
++  test-set-tmsp-08
  %+  expect-eq
    !>  ~2023.12.25..7.15.0..1ef5
    !>  %-  set-tmsp:utils
            :-  `(as-of-offset:ast %as-of-offset 0 %weeks)
                ~2023.12.25..7.15.0..1ef5
::
::  set-tmsp back 65 weeks
++  test-set-tmsp-09
  %+  expect-eq
    !>  ~2022.9.26..7.15.0..1ef5
    !>  %-  set-tmsp:utils
            :-  `(as-of-offset:ast %as-of-offset 65 %weeks)
                ~2023.12.25..7.15.0..1ef5
::
::  set-tmsp leap year
++  test-set-tmsp-10
  %+  expect-eq
    !>  ~2020.2.27..7.15.0..1ef5
    !>  %-  set-tmsp:utils
            :-  `(as-of-offset:ast %as-of-offset 7 %days)
                ~2020.3.5..7.15.0..1ef5
::
::  set-tmsp back 0 months
++  test-set-tmsp-11
  %+  expect-eq
    !>  ~2023.12.25..7.15.0..1ef5
    !>  %-  set-tmsp:utils
            :-  `(as-of-offset:ast %as-of-offset 0 %months)
                ~2023.12.25..7.15.0..1ef5
::
::  set-tmsp back 65 months
++  test-set-tmsp-12
  %+  expect-eq
    !>  ~2018.7.25..7.15.0..1ef5
    !>  %-  set-tmsp:utils
            :-  `(as-of-offset:ast %as-of-offset 65 %months)
                ~2023.12.25..7.15.0..1ef5
::
::  set-tmsp back 3 months
++  test-set-tmsp-13
  %+  expect-eq
    !>  ~2019.12.5..7.15.0..1ef5
    !>  %-  set-tmsp:utils
            :-  `(as-of-offset:ast %as-of-offset 3 %months)
                ~2020.3.5..7.15.0..1ef5
::
::  set-tmsp back 2 months
++  test-set-tmsp-14
  %+  expect-eq
    !>  ~2020.1.5..7.15.0..1ef5
    !>  %-  set-tmsp:utils
            :-  `(as-of-offset:ast %as-of-offset 2 %months)
                ~2020.3.5..7.15.0..1ef5
::
::  set-tmsp back 0 years
++  test-set-tmsp-15
  %+  expect-eq
    !>  ~2023.12.25..7.15.0..1ef5
    !>  %-  set-tmsp:utils
            :-  `(as-of-offset:ast %as-of-offset 0 %years)
                ~2023.12.25..7.15.0..1ef5
::
::  set-tmsp back 65 years
++  test-set-tmsp-16
  %+  expect-eq
    !>  ~1958.12.25..7.15.0..1ef5
    !>  %-  set-tmsp:utils
            :-  `(as-of-offset:ast %as-of-offset 65 %years)
                ~2023.12.25..7.15.0..1ef5
::
::  set-tmsp to ~1962.2.2..7.15.0..1ef5
++  test-set-tmsp-17
  %+  expect-eq
    !>  ~1962.2.2..7.15.0..1ef5
    !>  %-  set-tmsp:utils
            [`[%da ~1962.2.2..7.15.0..1ef5] ~2023.12.25..7.15.0..1ef5]
::
::  set-tmsp back ~s65
++  test-set-tmsp-18
  %+  expect-eq
    !>  ~2023.12.25..7.13.55..1ef5
    !>  (set-tmsp:utils [`[%dr ~s65] ~2023.12.25..7.15.0..1ef5])
::
::  set-tmsp back ~m65
++  test-set-tmsp-19
  %+  expect-eq
    !>  ~2023.12.25..6.10.0..1ef5
    !>  (set-tmsp:utils [`[%dr ~m65] ~2023.12.25..7.15.0..1ef5])
::
::  set-tmsp back ~m65.s65
++  test-set-tmsp-20
  %+  expect-eq
    !>  ~2023.12.25..6.8.55..1ef5
    !>  (set-tmsp:utils [`[%dr ~m65.s65] ~2023.12.25..7.15.0..1ef5])
::
::  set-tmsp back ~h2.m12.s5
++  test-set-tmsp-21
  %+  expect-eq
    !>  ~2023.12.25..5.2.55..1ef5
    !>  (set-tmsp:utils [`[%dr ~h2.m12.s5] ~2023.12.25..7.15.0..1ef5])
::
::  set-tmsp back ~d5.h2.m12.s5
++  test-set-tmsp-22
  %+  expect-eq
    !>  ~2023.12.20..5.2.55..1ef5
    !>  (set-tmsp:utils [`[%dr ~d5.h2.m12.s5] ~2023.12.25..7.15.0..1ef5])
::
::  set-tmsp back ~s0
++  test-set-tmsp-23
  %+  expect-eq
    !>  ~2023.12.25..7.15.0..1ef5
    !>  (set-tmsp:utils [`[%dr ~s0] ~2023.12.25..7.15.0..1ef5])
::
::  set-tmsp back ~d0.h0.m0.s0
++  test-set-tmsp-24
  %+  expect-eq
    !>  ~2023.12.25..7.15.0..1ef5
    !>  (set-tmsp:utils [`[%dr ~d0.h0.m0.s0] ~2023.12.25..7.15.0..1ef5])
::
::  alphanumeric ordering
::
++  printable-ascii  "0123456789:;<=>?@ABCDEFGHIJK !#$%&'()*+,-./".
                     "LMNOPQRSTUVWXYZ[]^_`abcdefghijklmnopqrstuvwxyz|}~\{\"\\"
++  alpha-ordering  " !\"#$%&'()*+,-./0123456789:;<=>?@[\\]^_`AaBbCcDdEeFfGgHhIiJjKk".
                    "LlMmNnOoPpQqRrSsTtUuVvWwXxYyZz\{|}~"
++  aor-ordering    " !\"#$%&'()*+,-./0123456789:;<=>?@ABCDEFGHIJKLMNOPQRSTUVW".
                    "XYZ[\\]^_`abcdefghijklmnopqrstuvwxyz\{|}~"
::
++  test-alpha-01
  %+  expect-eq
    !>  alpha-ordering
    !>  (sort printable-ascii alpha:utils)
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
    !>  (sort foo alpha:utils)
::
++  test-alpha-04
  %+  expect-eq
    !>  alpha-ordering
    !>  (sort aor-ordering alpha:utils)
::
++  test-alpha-05
  %+  expect-eq
    !>  alpha-ordering
    !>  (sort alpha-ordering alpha:utils)
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
                    'Ab'
                    'aB'
                    'ab'
                    'ABC'
                    'ABc'
                    'AbC'
                    'Abc'
                    'aBC'
                    'aBc'
                    'abC'
                    'abc'
                    'b'
                    'bac'
                    'bb'
                    ==
  ::
  %+  weld  %+  expect-eq
                !>  expected
                !>  (sort the-list alpha:utils)
            %+  expect-eq
                !>  expected
                !>  (sort (flop the-list) alpha:utils)
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
  ::  Note: State inspection =+  !<(=state on-save:agent) is lost
  %-  exec-0-02
  :*  run
      [~1999.1.1 %sys "CREATE DATABASE db1 AS OF ~2000.1.1"]
      ::
      [~2000.1.2 %db1 "FROM sys.sys.databases SELECT *"]
      ::
      :-  %results
          :~  [%message 'created database %db1']
              [%server-time ~1999.1.1]
              [%schema-time ~2000.1.1]
              ==
      ::
      expected-db
      ==
::
::  create database command
++  test-create-db-02
  =|  run=@ud
  %-  exec-0-0c2
  :*  run
      ::
      [~2000.1.1 [%commands ~[[%create-database %db1 ~]]]]
      ::
      [~2000.1.2 %db1 "FROM sys.sys.databases SELECT *"]
      ::
      :-  %results
          :~  [%message 'created database %db1']
              [%server-time ~2000.1.1]
              [%schema-time ~2000.1.1]
              ==
      ::
      expected-db
      ==
::
::  fail duplicate database
++  test-fail-create-database-01
  =|  run=@ud
  %-  failon-1
  :*  run
      [~2000.1.1 %sys "CREATE DATABASE db1"]
      ::
      [~2000.1.2 %sys "CREATE DATABASE db1"]
      ::
      'database %db1 already exists'
      ==
::
::  fail on create %sys database
++  test-fail-create-database-02
  =|  run=@ud
  %-  failon-0
  :*  run
      [~2000.1.2 %sys "CREATE DATABASE sys"]
      ::
      'database name cannot be \'sys\''
      ==
::
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
  %-  exec-0-2
  :*  run
      [~2000.1.1 %sys "CREATE DATABASE db1 AS OF ~2000.1.1"]
      ::
      [~2000.1.2 %db1 "DROP DATABASE db1"]
      ::
      [~2000.1.3 %sys "FROM sys.sys.databases SELECT *"]
      ::
      :-  %results
          :~  [%message 'DROP DATABASE %db1']
              [%server-time ~2000.1.2]
              [%message 'database %db1 dropped']
              ==
      ::
      :-  %results
          :~  [%message 'SELECT']
              :-  %result-set
                  :~  :-  %vector
                          :~  [%database [~.tas %sys]]
                              [%sys-agent [~.ta '/test-agent']]
                              [%sys-tmsp [~.da ~2000.1.1]]
                              [%data-ship [~.p 0]]
                              [%data-agent [~.ta '/test-agent']]
                              [%data-tmsp [~.da ~2000.1.1]]
                              ==
                      ==
              [%server-time ~2000.1.3]
              [%message 'sys.sys.databases']
              [%schema-time ~2000.1.1]
              [%data-time ~2000.1.1]
              [%vector-count 1]
              ==
      ==
::
::  drop database from 2 user dbs, no data
++  test-drop-db-02
  =|  run=@ud
  %-  exec-1-2
  :*  run
      [~2000.1.1 %sys "CREATE DATABASE db1 AS OF ~2000.1.1"]
      ::
      [~2000.1.2 %sys "CREATE DATABASE db2"]
      ::
      [~2000.1.3 %db1 "DROP DATABASE db1"]
      ::
      [~2000.1.4 %sys "FROM sys.sys.databases SELECT *"]
      ::
      :-  %results
          :~  [%message 'DROP DATABASE %db1']
              [%server-time ~2000.1.3]
              [%message 'database %db1 dropped']
              ==
      ::
      :-  %results
          :~  [%message 'SELECT']
              :-  %result-set
                  :~  :-  %vector
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
              [%server-time ~2000.1.4]
              [%message 'sys.sys.databases']
              [%schema-time ~2000.1.1]
              [%data-time ~2000.1.2]
              [%vector-count 2]
              ==
      ==
::
::  drop database from 2 user dbs, FORCE, not default DB
++  test-drop-db-03
  =|  run=@ud
  %-  exec-3-2
  :*  run
      [~2000.1.1 %sys "CREATE DATABASE db1 AS OF ~2000.1.1"]
      ::
      :+  ~2000.1.2
          %db1
          "CREATE TABLE db1..my-table (col1 @t) PRIMARY KEY (col1)"
      ::
      :+  ~2000.1.3
          %db1
          "INSERT INTO db1..my-table (col1) VALUES ('cord') "
      ::
      [~2000.1.4 %sys "CREATE DATABASE db2"]
      ::
      [~2000.1.5 %db2 "DROP DATABASE FORCE db1"]
      ::
      [~2000.1.6 %db2 "FROM sys.sys.databases SELECT *"]
      ::
      :-  %results
          :~  [%message 'DROP DATABASE %db1']
              [%server-time ~2000.1.5]
              [%message 'database %db1 dropped']
              ==
      ::
      :-  %results
          :~  [%message 'SELECT']
              :-  %result-set
                  :~  :-  %vector
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
              [%server-time ~2000.1.6]
              [%message 'sys.sys.databases']
              [%schema-time ~2000.1.1]
              [%data-time ~2000.1.4]
              [%vector-count 2]
              ==
      ==
::
::  drop database from 2 user dbs, table no data
++  test-drop-db-04
  =|  run=@ud
  %-  exec-2-2
  :*  run
      [~2000.1.1 %sys "CREATE DATABASE db1 AS OF ~2000.1.1"]
      ::
      :+  ~2000.1.2
          %db1
          "CREATE TABLE db1..my-table (col1 @t) PRIMARY KEY (col1)"
      ::
      [~2000.1.4 %sys "CREATE DATABASE db2"]
      ::
      [~2000.1.5 %db1 "DROP DATABASE db1"]
      ::
      [~2000.1.6 %db2 "FROM sys.sys.databases SELECT *"]
      ::
      :-  %results
          :~  [%message 'DROP DATABASE %db1']
              [%server-time ~2000.1.5]
              [%message 'database %db1 dropped']
              ==
      ::
      :-  %results
          :~  [%message 'SELECT']
              :-  %result-set
                  :~  :-  %vector
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
              [%server-time ~2000.1.6]
              [%message 'sys.sys.databases']
              [%schema-time ~2000.1.1]
              [%data-time ~2000.1.4]
              [%vector-count 2]
              ==
      ==
::
::  drop database from 2 user dbs, table with data no FORCE
++  test-fail-drop-db-01
  =|  run=@ud
  %-  failon-4
  :*  run
      [~2000.1.1 %sys "CREATE DATABASE db1 AS OF ~2000.1.1"]
      ::
      :+  ~2000.1.2
          %db1
          "CREATE TABLE db1..my-table (col1 @t) PRIMARY KEY (col1)"
      ::
      :+  ~2000.1.3
          %db1
          "INSERT INTO db1..my-table (col1) VALUES ('cord') "
      ::
      [~2000.1.4 %sys "CREATE DATABASE db2"]
      ::
      [~2000.1.6 %db1 "DROP DATABASE db1"]
      ::
      '%db1 has populated tables and `FORCE` was not specified'
      ==
::
::  drop database db does not exist
++  test-fail-drop-db-02
  =|  run=@ud
  %-  failon-4
  :*  run
      [~2000.1.1 %sys "CREATE DATABASE db1 AS OF ~2000.1.1"]
      ::
      :+  ~2000.1.2
          %db1
          "CREATE TABLE db1..my-table (col1 @t) PRIMARY KEY (col1)"
      ::
      :+  ~2000.1.3
          %db1
          "INSERT INTO db1..my-table (col1) VALUES ('cord') "
      ::
      [~2000.1.4 %sys "CREATE DATABASE db2"]
      ::
      [~2000.1.6 %db1 "DROP DATABASE db3"]
      ::
      'database %db3 does not exist'
      ==
::
::  fail schema change after query
++  test-fail-drop-db-03
  =|  run=@ud
  %-  failon-4
  :*  run
      [~2000.1.1 %sys "CREATE DATABASE db1 AS OF ~2000.1.1"]
      ::
      :+  ~2000.1.2
          %db1
          "CREATE TABLE db1..my-table (col1 @t) PRIMARY KEY (col1)"
      ::
      :+  ~2000.1.3
          %db1
          "INSERT INTO db1..my-table (col1) VALUES ('cord') "
      ::
      [~2000.1.4 %sys "CREATE DATABASE db2"]
      ::
      :+  ~2012.5.3
          %db1
          "FROM db1..my-table SELECT *; ".
          "DROP DATABASE db2 "
      ::
      'DROP DATABASE: state change after query in script'
      ==
::
::  fail on not dropped by local agent

::  to do:  re-enable this test after persmissions implemented
::          currently fails on wrong message
::++  test-fail-drop-db-04
::  =|  run=@ud
::  ::
::  =^  mov1  agent
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
::  =^  mov4  agent
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
  %-  failon-1
  :*  run
      [~2000.1.1 %sys "CREATE DATABASE db1"]
      ::
      [~2012.5.3 %db1 "DROP DATABASE sys "]
      ::
      'database %sys cannot be dropped'
      ==
::
::  CREATE NAMESPACE
::
::  Create namespace, not default DB
++  test-create-namepsace-01
  =|  run=@ud
  %-  exec-1-2
  :*  run
      [~2000.1.1 %sys "CREATE DATABASE db1"]
      ::
      [~2000.1.2 %sys "CREATE DATABASE db2"]
      ::
      [~2000.1.3 %db1 "CREATE NAMESPACE db2.ns1"]
      ::
      :+  ~2000.1.4
          %db1
          "CREATE TABLE db2.ns1.my-table (col1 @t) PRIMARY KEY (col1)"
      ::
      :-  %results
          :~  [%message 'CREATE NAMESPACE %ns1']
              [%server-time ~2000.1.3]
              [%schema-time ~2000.1.3]
              ==
      ::
      :-  %results
          :~  [%message 'CREATE TABLE %my-table']
              [%server-time ~2000.1.4]
              [%schema-time ~2000.1.4]
              ==
      ==
::
::  fail on duplicate namepsace
++  test-fail-create-namespace-01
  =|  run=@ud
  %-  failon-2c
  :*  run
      [~2000.1.1 [%commands ~[[%create-database 'db1' ~]]]]
      ::
      [~2000.1.2 [%commands ~[[%create-namespace %db1 %ns1 ~]]]]
      ::
      [~2000.1.3 [%commands ~[[%create-namespace %db1 %ns1 ~]]]]
      ::
      'CREATE NAMESPACE: namespace %ns1 already exists'
      ==
::
::  fail on database does not exist
++  test-fail-create-namespace-02
  =|  run=@ud
  %-  failon-1cc
  :*  run
      [~2000.1.1 [%commands ~[[%create-database 'db1' ~]]]]
      ::
      [~2000.1.3 [%commands ~[[%create-namespace %db %ns1 ~]]]]
      ::
      'CREATE NAMESPACE: database %db does not exist'
      ==
::
:: fail on time, create ns = schema
++  test-fail-create-namespace-03
  =|  run=@ud
  %-  failon-1
  :*  run
      :+  ~2000.1.1
          %sys
          "CREATE DATABASE db1 as of ~2023.7.9..22.35.35..7e90"
      ::
      :+  ~2000.1.2
          %db1
          "CREATE NAMESPACE ns1 as of ~2023.7.9..22.35.35..7e90"
      ::
      'CREATE NAMESPACE: namespace %ns1 as-of schema time out of order'
      ==
::
:: fail on time, create ns lt schema
++  test-fail-create-namespace-04
  =|  run=@ud
  %-  failon-1
  :*  run
      :+  ~2000.1.1
          %sys
          "CREATE DATABASE db1 as of ~2023.7.9..22.35.35..7e90"
      ::
      :+  ~2000.1.2
          %db1
          "CREATE NAMESPACE ns1 as of ~2023.7.9..22.35.34..7e90"
      ::
      'CREATE NAMESPACE: namespace %ns1 as-of schema time out of order'
      ==
::
::  fail on time, create ns = content
++  test-fail-create-namespace-05
  =|  run=@ud
  %-  failon-3
  :*  run
      [~2000.1.1 %sys "CREATE DATABASE db1"]
      ::
      :+  ~2000.1.2
          %db1
          "CREATE TABLE db1..my-table (col1 @t) PRIMARY KEY (col1)"
      ::
      :+  ~2023.7.9..22.35.35..7e90
          %db1
          "INSERT INTO db1..my-table ".
          "(col1) VALUES ('cord') "
      ::
      :+  ~2000.1.2
          %db1
          "CREATE NAMESPACE ns1 as of ~2023.7.9..22.35.35..7e90"
      ::
      'CREATE NAMESPACE: namespace %ns1 as-of content time out of order'
      ==
::
::  fail on time, create ns lt content
++  test-fail-create-namespace-06
  =|  run=@ud
  %-  failon-3
  :*  run
      [~2000.1.1 %sys "CREATE DATABASE db1"]
      ::
      :+  ~2000.1.2
          %db1
          "CREATE TABLE db1..my-table (col1 @t) PRIMARY KEY (col1)"
      ::
      :+  ~2023.7.9..22.35.35..7e90
          %db1
          "INSERT INTO db1..my-table ".
          "(col1) VALUES ('cord') "
      ::
      :+  ~2000.1.2
          %db1
          "CREATE NAMESPACE ns1 as of ~2023.7.9..22.35.34..7e90"
      ::
      'CREATE NAMESPACE: namespace %ns1 as-of content time out of order'
      ==
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
::  fail on attempt to create namespace in sys database
++  test-fail-create-namespace-08
  =|  run=@ud
  %-  failon-0
  :*  run
      [~2000.1.1 %sys "CREATE NAMESPACE sys.ns1"]
      ::
      'cannot create namespace in sys database'
      ==
::
::  CREATE TABLE
::
::  Create table, not default DB
++  test-create-table-01
  =|  run=@ud
  %-  exec-1-1
  :*  run
      [~2000.1.1 %sys "CREATE DATABASE db1"]
      ::
      [~2000.1.2 %sys "CREATE DATABASE db2"]
      ::
      :+  ~2000.1.3
          %db1
          "CREATE TABLE db2..my-table (col1 @t) PRIMARY KEY (col1)"
      ::
      :-  %results
          :~  [%message 'CREATE TABLE %my-table']
              [%server-time ~2000.1.3]
              [%schema-time ~2000.1.3]
              ==
      ==
::
::  create table in future, create table in further future
++  test-create-table-02
  =|  run=@ud
  %-  exec-1-1
  :*  run
      :+  ~2000.1.1
          %db1
          "CREATE DATABASE db1;"
      ::
      :+  ~2000.1.2
          %db1
          "CREATE TABLE db1..my-table (col1 @t) ".
          "PRIMARY KEY (col1) as of ~2023.7.9"
      ::
      :+  ~2000.1.3
          %db1
          "CREATE TABLE db1..my-table-2 (col1 @t) ".
          "PRIMARY KEY (col1) ".
          "AS OF ~2023.7.10;"
      ::
      :-  %results
          :~  [%message 'CREATE TABLE %my-table-2']
              [%server-time ~2000.1.3]
              [%schema-time date=~2023.7.10]
              ==
      ==
::
::  fail on database does not exist
++  test-fail-create-table-01
  =|  run=@ud
  =/  cmd
    :*  %create-table
        [%qualified-table ship=~ database='db' namespace='dbo' name='my-table' alias=~]
        :~  [%column name='col1' column-type=%t addr=0]
            [%column name='col2' column-type=%p addr=0]
            [%column name='col3' column-type=%ud addr=0]
        ==
        pri-indx=~[[%ordered-column column-name='col1' ascending=%.y]]
        foreign-keys=~
        as-of=~
    ==
  %-  failon-1cc
  :*  run
      [~2000.1.1 [%commands ~[[%create-database 'db1' ~]]]]
      ::
      [~2000.1.4 [%commands ~[cmd]]]
      ::
      'CREATE TABLE: database %db does not exist'
      ==
::
::  fail on namespace does not exist
++  test-fail-create-table-02
  =|  run=@ud
  =/  cmd
    :*  %create-table
        :*  %qualified-table
            ship=~
            database='db1'
            namespace='ns1'
            name='my-table'
            alias=~
        ==
        :~  [%column name='col1' column-type=%t addr=0]
            [%column name='col2' column-type=%p addr=0]
            [%column name='col3' column-type=%ud addr=0]
        ==
        pri-indx=~[[%ordered-column column-name='col1' ascending=%.y]]
        foreign-keys=~
        as-of=~
    ==
  %-  failon-1cc
  :*  run
      [~2000.1.1 [%commands ~[[%create-database 'db1' ~]]]]
      ::
      [~2000.1.4 [%commands ~[cmd]]]
      ::
      'CREATE TABLE: namespace %ns1 does not exist'
      ==
::
::  fail on duplicate table name
++  test-fail-create-table-03
  =|  run=@ud
  =/  cmd
    :*  %create-table
        :*  %qualified-table
            ship=~
            database='db1'
            namespace='dbo'
            name='my-table'
            alias=~
        ==
        :~  [%column name='col1' column-type=%t addr=0]
            [%column name='col2' column-type=%p addr=0]
            [%column name='col3' column-type=%ud addr=0]
        ==
        pri-indx=~[[%ordered-column column-name='col1' ascending=%.y]]
        foreign-keys=~
        as-of=~
    ==
  %-  failon-2c
  :*  run
      [~2000.1.1 [%commands ~[[%create-database 'db1' ~]]]]
      ::
      [~2000.1.2 [%commands ~[cmd]]]
      ::
      [~2000.1.4 [%commands ~[cmd]]]
      ::
      'CREATE TABLE: %my-table exists in %dbo'
      ==
::
::  fail on duplicate column names
++  test-fail-create-table-04
  =|  run=@ud
  =/  cmd
    :*  %create-table
        :*  %qualified-table
            ship=~
            database='db1'
            namespace='dbo'
            name='my-table'
            alias=~
        ==
        :~  [%column name='col1' column-type=%t addr=0]
            [%column name='col2' column-type=%p addr=0]
            [%column name='col1' column-type=%t addr=0]
        ==
        pri-indx=~[[%ordered-column column-name='col1' ascending=%.y]]
        foreign-keys=~
        as-of=~
    ==
  %-  failon-1cc
  :*  run
      [~2000.1.1 [%commands ~[[%create-database 'db1' ~]]]]
      ::
      [~2000.1.4 [%commands ~[cmd]]]
      ::
      %-  crip  
          "CREATE TABLE: duplicate column names ".
          "~[[%column name=%col1 type=~.t addr=0] ".
          "[%column name=%col2 type=~.p addr=0] ".
          "[%column name=%col1 type=~.t addr=0]]"
      ==
::
::  fail on time, create table = content
++  test-fail-create-table-05
  =|  run=@ud
  %-  failon-3
  :*  run
      [~2000.1.1 %sys "CREATE DATABASE db1"]
      ::
      :+  ~2000.1.2
          %db1
          "CREATE TABLE db1..my-table (col1 @t) PRIMARY KEY (col1)"
      ::
      :+  ~2023.7.9..22.35.35..7e90
          %db1
          "INSERT INTO db1..my-table ".
          "(col1) VALUES ('cord') "
      ::
      :+  ~2000.1.2
          %db1
          "CREATE TABLE db1..my-table-2 (col1 @t) PRIMARY KEY (col1) ".
          "AS OF ~2023.7.9..22.35.35..7e90"
      ::
      'CREATE TABLE: %my-table-2 as-of data time out of order'
      ==
::
::  fail on time, create table < content
++  test-fail-create-table-06
  =|  run=@ud
  %-  failon-3
  :*  run
      [~2000.1.1 %sys "CREATE DATABASE db1"]
      ::
      :+  ~2000.1.2
          %db1
          "CREATE TABLE db1..my-table (col1 @t) PRIMARY KEY (col1)"
      ::
      :+  ~2023.7.9..22.35.35..7e90
          %db1
          "INSERT INTO db1..my-table ".
          "(col1) VALUES ('cord') "
      ::
      :+  ~2000.1.2
          %db1
          "CREATE TABLE db1..my-table-2 (col1 @t) PRIMARY KEY (col1) ".
          "AS OF ~2023.7.9..22.35.35..7e90"
      ::
      'CREATE TABLE: %my-table-2 as-of data time out of order'
      ==
::
::  fail on time, create table = schema
++  test-fail-create-table-07
  =|  run=@ud
  %-  failon-1
  :*  run
      :+  ~2000.1.1
          %sys
          "CREATE DATABASE db1 as of ~2023.7.9..22.35.35..7e90"
      ::
      :+  ~2000.1.2
          %db1
          "CREATE TABLE db1..my-table-2 (col1 @t, col2 @p) ".
          "PRIMARY KEY (col1, col2) ".
          "as of ~2023.7.9..22.35.35..7e90"
      ::
      'CREATE TABLE: %my-table-2 as-of schema time out of order'
      ==
::
::  fail on time, create table lt schema
++  test-fail-create-table-08
  =|  run=@ud
  %-  failon-1
  :*  run
      :+  ~2000.1.1
          %sys
          "CREATE DATABASE db1 as of ~2023.7.9..22.35.35..7e90"
      ::
      :+  ~2000.1.2
          %db1
          "CREATE TABLE db1..my-table-2 (col1 @t, col2 @p) ".
            "PRIMARY KEY (col1, col2) ".
            "as of ~2023.7.9..22.35.34..7e90"
      ::
      'CREATE TABLE: %my-table-2 as-of schema time out of order'
      ==
::
::  fail on key column not in column definitions
++  test-fail-create-table-09
  =|  run=@ud
  =/  cmd
    :*  %create-table
        :*  %qualified-table
            ship=~
            database='db1'
            namespace='dbo'
            name='my-table'
            alias=~
        ==
        :~  [%column name='col1' column-type=%t addr=0]
            [%column name='col2' column-type=%p addr=0]
            [%column name='col3' column-type=%ud addr=0]
        ==
        :~  [%ordered-column column-name='col1' ascending=%.y]
            [%ordered-column column-name='col4' ascending=%.y]
        ==
        foreign-keys=~
        as-of=~
    ==
  %-  failon-1cc
  :*  run
      [~2000.1.1 [%commands ~[[%create-database 'db1' ~]]]]
      ::
      [~2000.1.2 [%commands ~[cmd]]]
      ::
      %-  crip  
          "CREATE TABLE: key column not in column definitions ".
          "~[[%ordered-column name=%col1 ascending=%.y] ".
          "[%ordered-column name=%col4 ascending=%.y]]"
      ==
::
::  fail on duplicate column names in key
++  test-fail-create-table-10
  =|  run=@ud
  =/  cmd
    :*  %create-table
        :*  %qualified-table
            ship=~
            database='db1'
            namespace='dbo'
            name='my-table'
            alias=~
        ==
        :~  [%column name='col1' column-type=%t addr=0]
            [%column name='col2' column-type=%p addr=0]
            [%column name='col3' column-type=%t addr=0]
        ==
        :~  [%ordered-column column-name='col1' ascending=%.y]
            [%ordered-column column-name='col1' ascending=%.n]
            ==
        foreign-keys=~
        as-of=~
    ==
  %-  failon-1cc
  :*  run
      [~2000.1.1 [%commands ~[[%create-database 'db1' ~]]]]
      ::
      [~2000.1.4 [%commands ~[cmd]]]
      ::
      %-  crip  
          "CREATE TABLE: duplicate column names in key ".
          "~[[%ordered-column name=%col1 ascending=%.y] ".
          "[%ordered-column name=%col1 ascending=%.n]]"
      ==
::
::  create table in future, fail on insert of other table in present
++  test-fail-create-table-11
  =|  run=@ud
  %-  failon-2
  :*  run
      :+  ~2000.1.1
          %db1
          "CREATE DATABASE db1; ".
          "CREATE TABLE db1..my-table-2 (col1 @t) PRIMARY KEY (col1); "
      ::
      :+  ~2000.1.2
          %db1
          "CREATE TABLE db1..my-table (col1 @t) ".
          "PRIMARY KEY (col1) as of ~2023.7.9"
      ::
      :+  ~2000.1.3
          %db1
          "INSERT INTO db1..my-table-2 ".
          "(col1) VALUES ('cord') "
      ::
      'INSERT: table %my-table-2 as-of schema time out of order'
      ==
::
::  create table in future, fail on create other table in present
++  test-fail-create-table-12
  =|  run=@ud
  %-  failon-2
  :*  run
      :+  ~2000.1.1
          %db1
          "CREATE DATABASE db1;"
      ::
      :+  ~2000.1.2
          %db1
          "CREATE TABLE db1..my-table (col1 @t) ".
          "PRIMARY KEY (col1) as of ~2023.7.9"
      ::
      :+  ~2000.1.3
          %db1
          "CREATE TABLE db1..my-table-2 (col1 @t) PRIMARY KEY (col1); "
      ::
      'CREATE TABLE: %my-table-2 as-of schema time out of order'
      ==
::
::  fail table must be created by local agent

::  to do:  re-enable this test after persmissions implemented
::          currently fails on wrong message
::++  test-fail-create-table-13
::  =|  run=@ud
::  =/  cmd
::    :*  %create-table
::        :*  %qualified-table
::            ship=~
::            database='db1'
::            namespace='dbo'
::            name='my-table'
::            alias=~
::        ==
::        :~  [%column name='col1' column-type=%t addr=0]
::            [%column name='col2' column-type=%p addr=0]
::            [%column name='col3' column-type=%t addr=0]
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
++  test-fail-create-table-14
  =|  run=@ud
  %-  failon-3
  :*  run
      [~2000.1.1 %sys "CREATE DATABASE db1"]
      ::
      :+  ~2000.1.2
          %db1
          "CREATE TABLE db1..my-table (col1 @t) PRIMARY KEY (col1)"
      ::
      :+  ~2000.1.3
          %db1
          "INSERT INTO db1..my-table (col1) VALUES ('cord') "
      ::
      :+  ~2000.1.4
          %db1
          "FROM my-table SELECT * ".
          "CREATE TABLE db1..my-table-2 (col1 @t) PRIMARY KEY (col1) "
      ::
      'CREATE TABLE: state change after query in script'
      ==
::
::  fail on attempt to create table in sys database
++  test-fail-create-table-15
  =|  run=@ud
  %-  failon-0
  :*  run
      :+  ~2000.1.1
          %sys
          "CREATE TABLE sys.sys.my-table (col1 @t) PRIMARY KEY (col1)"
      ::
      'cannot create table in %sys database'
      ==
::
::  Drop table
::
::  drop table with data force, not default DB
::  Would need exec-4-1 (init + 4 actions + 1 resolve) which doesn't exist
::  drop table with data force, not default DB
++  test-drop-tbl-force
  =|  run=@ud
  %-  exec-3-1
  :*  run
      [~2000.1.1 %sys "CREATE DATABASE db1"]
      ::
      [~2000.1.2 %sys "CREATE DATABASE db2"]
      ::
      :+  ~2000.1.3
          %db2
          "CREATE TABLE my-table (col1 @t) PRIMARY KEY (col1)"
      ::
      [~2000.1.4 %db2 "INSERT INTO my-table (col1) VALUES ('cord')"]
      ::
      :+  ~2000.1.5
          %db1
          "DROP TABLE FORCE db2..my-table"
      ::
      :-  %results
          :~  [%message 'DROP TABLE %my-table']
              [%server-time ~2000.1.5]
              [%schema-time ~2000.1.5]
              [%data-time ~2000.1.5]
              [%vector-count 1]
              ==
      ==
::
::  fail on time, drop table = schema
++  test-fail-drop-table-01
  =|  run=@ud
  %-  failon-3
  :*  run
      :+  ~2000.1.1
          %sys
          "CREATE DATABASE db1 as of ~2023.7.9..22.35.35..7e90"
      ::
      :+  ~2000.1.2
          %db1
          "CREATE TABLE db1..my-table-2 (col1 @t, col2 @p) ".
          "PRIMARY KEY (col1, col2) ".
          "AS OF ~2023.7.9..22.35.36..7e90"
      ::
      [~2000.1.3 %db1 "CREATE NAMESPACE ns1 as of ~2023.7.9..22.35.37..7e90"]
      ::
      :+  ~2000.1.2
          %db1
          "DROP TABLE db1..my-table-2 ".
          "AS OF ~2023.7.9..22.35.37..7e90"
      ::
      'DROP TABLE: %my-table-2 as-of schema time out of order'
      ==
::
::  fail on time, drop table lt schema
++  test-fail-drop-table-02
  =|  run=@ud
  %-  failon-3
  :*  run
      :+  ~2000.1.1
          %sys
          "CREATE DATABASE db1 as of ~2023.7.9..22.35.35..7e90"
      ::
      :+  ~2000.1.2
          %db1
          "CREATE TABLE db1..my-table-2 (col1 @t, col2 @p) ".
          "PRIMARY KEY (col1, col2) ".
          "AS OF ~2023.7.9..22.35.36..7e90"
      ::
      [~2000.1.3 %db1 "CREATE NAMESPACE ns1 as of ~2023.7.9..22.35.37..7e90"]
      ::
      :+  ~2000.1.2
          %db1
          "DROP TABLE db1..my-table-2 ".
          "AS OF ~2023.7.9..22.35.36..7e90"
      ::
      'DROP TABLE: %my-table-2 as-of schema time out of order'
      ==
::
::  fail on time, drop table = content
++  test-fail-drop-table-03
  =|  run=@ud
  %-  failon-3
  :*  run
      [~2000.1.1 %sys "CREATE DATABASE db1"]
      ::
      :+  ~2000.1.2
          %db1
          "CREATE TABLE db1..my-table (col1 @t) PRIMARY KEY (col1)"
      ::
      :+  ~2023.7.9..22.35.35..7e90
          %db1
          "INSERT INTO db1..my-table ".
          "(col1) VALUES ('cord') "
      ::
      :+  ~2000.1.2
          %db1
          "DROP TABLE FORCE db1..my-table ".
          "as of ~2023.7.9..22.35.35..7e90"
      ::
      'DROP TABLE: %my-table as-of data time out of order'
      ==
::
::  fail on time, drop table < content
++  test-fail-drop-table-04
  =|  run=@ud
  %-  failon-3
  :*  run
      [~2000.1.1 %sys "CREATE DATABASE db1"]
      ::
      :+  ~2000.1.2
          %db1
          "CREATE TABLE db1..my-table (col1 @t) PRIMARY KEY (col1)"
      ::
      :+  ~2023.7.9..22.35.35..7e90
          %db1
          "INSERT INTO db1..my-table ".
          "(col1) VALUES ('cord') "
      ::
      :+  ~2000.1.2
          %db1
          "DROP TABLE FORCE db1..my-table ".
          "as of ~2023.7.9..22.35.34..7e90"
      ::
      'DROP TABLE: %my-table as-of data time out of order'
      ==
::
::  fail drop table with data no force
::  Mixes tape-based actions (init, action-1, action-2) with command-based failing action
++  test-fail-drop-table-05
  =|  run=@ud
  =/  cmd
    :^  %drop-table
        :*  %qualified-table
            ship=~
            database='db1'
            namespace='dbo'
            name='my-table'
            alias=~
        ==
        %.n
        ~
  %-  failon-3c
  :*  run
      [~2000.1.1 %sys "CREATE DATABASE db1"]
      ::
      :+  ~2000.1.2
          %db1
          "CREATE TABLE db1..my-table (col1 @t) PRIMARY KEY (col1)"
      ::
      [~2000.1.3 %db1 "INSERT INTO db1..my-table (col1) VALUES ('cord')"]
      ::
      [~2000.1.4 [%commands ~[cmd]]]
      ::
      'DROP TABLE: %my-table has data, use FORCE to DROP'
      ==
::
::  fail on database does not exist
++  test-fail-drop-table-06
  =|  run=@ud
  =/  cmd
    :^  %drop-table
        :*  %qualified-table
            ship=~
            database='db'
            namespace='dbo'
            name='my-table'
            alias=~
        ==
        %.n
        ~
  %-  failon-1c
  :*  run
      [~2000.1.1 %sys "CREATE DATABASE db1"]
      ::
      [~2000.1.4 [%commands ~[cmd]]]
      ::
      'DROP TABLE: database %db does not exist'
      ==
::
::  fail on namespace does not exist
++  test-fail-drop-table-07
  =|  run=@ud
  =/  cmd
    :^  %drop-table
        :*  %qualified-table
            ship=~
            database='db1'
            namespace='ns1'
            name='my-table'
            alias=~
        ==
        %.n
        ~
  %-  failon-1cc
  :*  run
      [~2000.1.1 [%commands ~[[%create-database 'db1' ~]]]]
      ::
      [~2000.1.4 [%commands ~[cmd]]]
      ::
      'DROP TABLE: namespace %ns1 does not exist'
      ==
::
::  fail on table name does not exist
++  test-fail-drop-table-08
  =|  run=@ud
  =/  cmd
    :^  %drop-table
        :*  %qualified-table
            ship=~
            database='db1'
            namespace='dbo'
            name='my-table'
            alias=~
        ==
        %.n
        ~
  %-  failon-1cc
  :*  run
      [~2000.1.1 [%commands ~[[%create-database 'db1' ~]]]]
      ::
      [~2000.1.4 [%commands ~[cmd]]]
      ::
      'DROP TABLE: %my-table does not exist in %dbo'
      ==
::
::  fail on state change after query in script
++  test-fail-drop-table-09
  =|  run=@ud
  %-  failon-3
  :*  run
      [~2000.1.1 %sys "CREATE DATABASE db1"]
      ::
      :+  ~2000.1.2
          %db1
          "CREATE TABLE db1..my-table (col1 @t) PRIMARY KEY (col1)"
      ::
      [~2000.1.3 %db1 "INSERT INTO db1..my-table (col1) VALUES ('cord')"]
      ::
      :+  ~2000.1.4
          %db1
          "FROM my-table SELECT * ".
          "DROP TABLE db1..my-table-2 "
      ::
      'DROP TABLE: state change after query in script'
      ==
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
  %-  exec-3-1
  :*  run
      [~2000.1.1 %sys "CREATE DATABASE db1"]
      ::
      [~2000.1.2 %sys "CREATE DATABASE db2"]
      ::
      :+  ~2000.1.3
          %db2
          "CREATE TABLE my-table (col1 @t) PRIMARY KEY (col1)"
      ::
      [~2000.1.4 %db2 "INSERT INTO my-table (col1) VALUES ('cord')"]
      ::
      :+  ~2000.1.5
          %db1
          "TRUNCATE TABLE db2..my-table"
      ::
      :-  %results
          :~  [%message 'TRUNCATE TABLE db2.dbo.my-table']
              [%server-time ~2000.1.5]
              [%data-time ~2000.1.5]
              [%vector-count 1]
              ==
      ==
::
::  truncate table in future, define table in further future
++  test-truncate-table-02
  =|  run=@ud
  %-  exec-1-1
  :*  run
      :+  ~2000.1.1
          %db1
          "CREATE DATABASE db1; ".
          "CREATE TABLE db1..my-table (col1 @t) PRIMARY KEY (col1); ".
          "INSERT INTO db1..my-table ".
          "(col1) VALUES ('cord') "
      ::
      :+  ~2000.1.2
          %db1
          "TRUNCATE TABLE db1..my-table as of ~2023.7.9"
      ::
      :+  ~2000.1.3
          %db1
          "CREATE TABLE db1..my-table-2 (col1 @t) ".
          "PRIMARY KEY (col1) ".
          "AS OF ~2023.7.10;"
      ::
      :-  %results
          :~  [%message 'CREATE TABLE %my-table-2']
              [%server-time ~2000.1.3]
              [%schema-time date=~2023.7.10]
              ==
      ==
::
::  fail on database does not exist
++  test-fail-truncate-tbl-01
  =|  run=@ud
  =/  cmd
    :+  %truncate-table
        [%qualified-table ship=~ database='db' namespace='dbo' name='my-table' alias=~]
        ~
  %-  failon-1cc
  :*  run
      [~2000.1.1 [%commands ~[[%create-database 'db1' ~]]]]
      ::
      [~2000.1.3 [%commands ~[cmd]]]
      ::
      'TRUNCATE TABLE: database %db does not exist'
      ==
::
::  fail on namespace does not exist
++  test-fail-truncate-tbl-02
  =|  run=@ud
  =/  cmd
    :+  %truncate-table
       [%qualified-table ship=~ database='db1' namespace='ns1' name='my-table' alias=~]
        ~
  %-  failon-1cc
  :*  run
      [~2000.1.1 [%commands ~[[%create-database 'db1' ~]]]]
      ::
      [~2000.1.3 [%commands ~[cmd]]]
      ::
      'TRUNCATE TABLE: namespace %ns1 does not exist'
      ==
::
::  fail on table name does not exist
++  test-fail-truncate-tbl-03
  =|  run=@ud
  =/  cmd
    :+  %truncate-table
        :*  %qualified-table
            ship=~
            database='db1'
            namespace='dbo'
            name='my-table'
            alias=~
        ==
        ~
  %-  failon-1cc
  :*  run
      [~2000.1.1 [%commands ~[[%create-database 'db1' ~]]]]
      ::
      [~2000.1.3 [%commands ~[cmd]]]
      ::
      'TRUNCATE TABLE: %my-table does not exists in %dbo'
      ==
::
::  fail on state change after query in script
++  test-fail-truncate-table-04
  =|  run=@ud
  %-  failon-3
  :*  run
      [~2000.1.1 %sys "CREATE DATABASE db1"]
      ::
      :+  ~2000.1.2
          %db1
          "CREATE TABLE db1..my-table (col1 @t) PRIMARY KEY (col1)"
      ::
      [~2000.1.3 %db1 "INSERT INTO db1..my-table (col1) VALUES ('cord')"]
      ::
      :+  ~2000.1.4
          %db1
          "FROM my-table SELECT * ".
          "TRUNCATE TABLE db1..my-table-2 "
      ::
      'TRUNCATE TABLE: state change after query in script'
      ==
::
::  fail on time, truncate table lt schema
++  test-fail-truncate-tbl-05
  =|  run=@ud
  %-  failon-3
  :*  run
      :+  ~2000.1.1
          %sys
          "CREATE DATABASE db1 as of ~2023.7.9..22.35.35..7e90"
      ::
      :+  ~2000.1.2
          %db1
          "CREATE TABLE db1..my-table-2 (col1 @t, col2 @p) ".
          "PRIMARY KEY (col1, col2) ".
          "AS OF ~2023.7.9..22.35.36..7e90"
      ::
      [~2000.1.3 %db1 "CREATE NAMESPACE ns1 as of ~2023.7.9..22.35.37..7e90"]
      ::
      :+  ~2000.1.2
          %db1
          "TRUNCATE TABLE db1..my-table-2 ".
          "AS OF ~2023.7.9..22.35.36..7e90"
      ::
      'TRUNCATE TABLE: %my-table-2 as-of schema time out of order'
      ==
::
::  fail on time, truncate table = content
++  test-fail-truncate-tbl-06
  =|  run=@ud
  %-  failon-3
  :*  run
      [~2000.1.1 %sys "CREATE DATABASE db1"]
      ::
      :+  ~2000.1.2
          %db1
          "CREATE TABLE db1..my-table (col1 @t) PRIMARY KEY (col1)"
      ::
      :+  ~2023.7.9..22.35.35..7e90
          %db1
          "INSERT INTO db1..my-table ".
          "(col1) VALUES ('cord') "
      ::
      :+  ~2000.1.2
          %db1
          "TRUNCATE TABLE db1..my-table as of ~2023.7.9..22.35.35..7e90"
      ::
      'TRUNCATE TABLE: %my-table as-of data time out of order'
      ==
::
::  fail on time, truncate table = content with AS OF ... AGO
++  test-fail-truncate-tbl-07
  =|  run=@ud
  %-  failon-3
  :*  run
      [~2000.1.1 %sys "CREATE DATABASE db1"]
      ::
      :+  ~2000.1.2
          %db1
          "CREATE TABLE db1..my-table (col1 @t) PRIMARY KEY (col1)"
      ::
      :+  ~2000.1.3
          %db1
          "INSERT INTO db1..my-table (col1) VALUES ('cord') "
      ::
      :+  ~2000.1.4
          %db1
          "TRUNCATE TABLE my-table as of 1 day ago"
      ::
      'TRUNCATE TABLE: %my-table as-of data time out of order'
      ==
::
::  truncate table in future, fail on insert of other table in present
++  test-fail-truncate-tbl-08
  =|  run=@ud
  %-  failon-2
  :*  run
      :+  ~2000.1.1
          %db1
          "CREATE DATABASE db1; ".
          "CREATE TABLE db1..my-table (col1 @t) PRIMARY KEY (col1); ".
          "CREATE TABLE db1..my-table-2 (col1 @t) PRIMARY KEY (col1); ".
          "INSERT INTO db1..my-table ".
          "(col1) VALUES ('cord') "
      ::
      :+  ~2000.1.2
          %db1
          "TRUNCATE TABLE db1..my-table as of ~2023.7.9"
      ::
      :+  ~2000.1.3
          %db1
          "INSERT INTO db1..my-table-2 ".
          "(col1) VALUES ('cord') "
      ::
      'INSERT: table %my-table-2 as-of data time out of order'
      ==
::
::  truncate table in future, fail on truncate other table in present
++  test-fail-truncate-tbl-09
  =|  run=@ud
  %-  failon-2
  :*  run
      :+  ~2000.1.1
          %db1
          "CREATE DATABASE db1; ".
          "CREATE TABLE db1..my-table (col1 @t) PRIMARY KEY (col1); ".
          "CREATE TABLE db1..my-table-2 (col1 @t) PRIMARY KEY (col1); ".
          "INSERT INTO db1..my-table ".
          "(col1) VALUES ('cord') ".
          "INSERT INTO db1..my-table-2 ".
          "(col1) VALUES ('cord') "
      ::
      :+  ~2000.1.2
          %db1
          "TRUNCATE TABLE db1..my-table as of ~2023.7.9"
      ::
      :+  ~2000.1.3
          %db1
          "TRUNCATE TABLE db1..my-table-2 "
      ::
      'TRUNCATE TABLE: %my-table-2 as-of data time out of order'
      ==
::
::  truncate table in future, fail on define table in present
++  test-fail-truncate-tbl-10
  =|  run=@ud
  %-  failon-2
  :*  run
      :+  ~2000.1.1
          %db1
          "CREATE DATABASE db1; ".
          "CREATE TABLE db1..my-table (col1 @t) PRIMARY KEY (col1); ".
          "INSERT INTO db1..my-table ".
          "(col1) VALUES ('cord') "
      ::
      :+  ~2000.1.2
          %db1
          "TRUNCATE TABLE db1..my-table as of ~2023.7.9"
      ::
      :+  ~2000.1.3
          %db1
          "CREATE TABLE db1..my-table-2 (col1 @t) ".
          "PRIMARY KEY (col1); "
      ::
      'CREATE TABLE: %my-table-2 as-of data time out of order'
      ==
--
