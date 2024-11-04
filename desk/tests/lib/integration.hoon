:::  unit tests on %obelisk library simulating pokes
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
::  integration tests
::
::  insert followed by insert in same script, same time
++  test-integrate-00
  =|  run=@ud
  =/  expected  :~
                  :-  %results
                      :~  [%message 'INSERT INTO %my-table']
                          [%server-time ~2000.1.3]
                          [%schema-time ~2000.1.2]
                          [%data-time ~2000.1.3]
                          [%message 'inserted:']
                          [%vector-count 1]
                          [%message 'table data:']
                          [%vector-count 1]
                      ==
                  :-  %results
                      :~  [%message 'INSERT INTO %my-table']
                          [%server-time ~2000.1.3]
                          [%schema-time ~2000.1.2]
                          [%data-time ~2000.1.3]
                          [%message 'inserted:']
                          [%vector-count 1]
                          [%message 'table data:']
                          [%vector-count 2]
                      ==
                  ==
  ::
  =^  move  agent
    %:  ~(on-poke agent (bowl [run ~ ~2000.1.1]))
        %obelisk-action
        !>([%tape %sys "CREATE DATABASE db1 AS OF ~2000.1.1"])
    ==
  =.  run  +(run)
  =^  mov3  agent
    %:  ~(on-poke agent (bowl [run ~ ~2000.1.2]))
        %obelisk-action
        !>  :+  %tape
                %db1
                "CREATE TABLE db1..my-table (col1 @t) PRIMARY KEY (col1)"
    ==
  =.  run  +(run)
  =^  mov4  agent
    %:  ~(on-poke agent (bowl [run ~ ~2000.1.3]))
        %obelisk-action
        !>  :+  %tape
                %db1
                "INSERT INTO db1..my-table (col1) VALUES ('cord'); ".
                "INSERT INTO db1..my-table VALUES ('cord2') "
    ==
  ::
  %+  expect-eq
    !>  expected
    !>  ;;((list cmd-result) ->+>+>+.mov4)
::
::  insert followed by insert in same script, next time
++  test-integrate-01
  =|  run=@ud
  =/  expected-1  :~
                    :-  %results
                        :~  [%message 'INSERT INTO %my-table']
                            [%server-time ~2000.1.3]
                            [%schema-time ~2000.1.2]
                            [%data-time ~2000.1.3]
                            [%message 'inserted:']
                            [%vector-count 1]
                            [%message 'table data:']
                            [%vector-count 1]
                        ==
                    :-  %results
                        :~  [%message 'INSERT INTO %my-table']
                            [%server-time ~2000.1.3]
                            [%schema-time ~2000.1.2]
                            [%data-time ~2000.1.4]
                            [%message 'inserted:']
                            [%vector-count 1]
                            [%message 'table data:']
                            [%vector-count 2]
                        ==
                    ==
  =/  expected-2a-rows  :~
                          :-  %vector
                              :~  [%col1 [~.t 'cord']]
                                  ==
                          ==
  =/  expected-2b-rows  :~
                          :-  %vector
                              :~  [%col1 [~.t 'cord']]
                                  ==
                          :-  %vector
                              :~  [%col1 [~.t 'cord2']]
                                  ==
                          ==
  =/  expected-2  :~
                    :-  %results
                      :~  [%message 'SELECT']
                          [%result-set expected-2a-rows]
                          [%server-time ~2000.1.4]
                          [%message 'db1.dbo.my-table']
                          [%schema-time ~2000.1.2]
                          [%data-time ~2000.1.3]
                          [%vector-count 1]
                      ==
                    :-  %results
                      :~  [%message 'SELECT']
                          [%result-set expected-2b-rows]
                          [%server-time ~2000.1.4]
                          [%message 'db1.dbo.my-table']
                          [%schema-time ~2000.1.2]
                          [%data-time ~2000.1.4]
                          [%vector-count 2]
                      ==
                    ==
  ::
  =^  move  agent
    %:  ~(on-poke agent (bowl [run ~ ~2000.1.1]))
        %obelisk-action
        !>([%tape %sys "CREATE DATABASE db1 AS OF ~2000.1.1"])
    ==
  =.  run  +(run)
  =^  mov3  agent
    %:  ~(on-poke agent (bowl [run ~ ~2000.1.2]))
        %obelisk-action
        !>  :+  %tape
                %db1
                "CREATE TABLE db1..my-table (col1 @t) PRIMARY KEY (col1)"
    ==
  =.  run  +(run)
  =^  mov4  agent
    %:  ~(on-poke agent (bowl [run ~ ~2000.1.3]))
        %obelisk-action
        !>  :+  %tape
                %db1
                "INSERT INTO db1..my-table (col1) VALUES ('cord'); ".
                "INSERT INTO db1..my-table VALUES ('cord2') ".
                "AS OF ~2000.1.4"
    ==
  =.  run  +(run)
  =^  mov5  agent
    %:  ~(on-poke agent (bowl [run ~ ~2000.1.4]))
        %obelisk-action
        !>  :+  %tape
                %db1
                "FROM my-table AS OF ~2000.1.3 SELECT *; ".
                "FROM my-table SELECT *"
    ==
  ::
  %+  weld
    %+  expect-eq
      !>  expected-1
      !>  ;;((list cmd-result) ->+>+>+.mov4)
    %+  expect-eq
      !>  expected-2
      !>  ;;((list cmd-result) ->+>+>+.mov5)
::
::  truncate followed by insert in same script, same time
++  test-integrate-02
  =|  run=@ud
  =/  expected-1  :~
                    :-  %results
                        :~  [%message 'INSERT INTO %my-table']
                            [%server-time ~2000.1.3]
                            [%schema-time ~2000.1.2]
                            [%data-time ~2000.1.3]
                            [%message 'inserted:']
                            [%vector-count 1]
                            [%message 'table data:']
                            [%vector-count 1]
                        ==
                    == 
  =/  expected-2-rows  :~
                          :-  %vector
                              :~  [%col1 [~.t 'cord']]
                                  ==
                          :-  %vector
                              :~  [%col1 [~.t 'cord2']]
                                  ==
                          ==
  =/  expected-2  :~
                    :-  %results
                      :~  [%message msg='TRUNCATE TABLE %my-table']
                          [%server-time date=~2000.1.4]
                          [%data-time date=~2000.1.4]
                          [%vector-count count=1]
                      ==
                    :-  %results
                        :~  [%message 'INSERT INTO %my-table']
                            [%server-time ~2000.1.4]
                            [%schema-time ~2000.1.2]
                            [%data-time ~2000.1.4]
                            [%message 'inserted:']
                            [%vector-count 2]
                            [%message 'table data:']
                            [%vector-count 2]
                        ==
                    ==
  ::
  =^  move  agent
    %:  ~(on-poke agent (bowl [run ~ ~2000.1.1]))
        %obelisk-action
        !>([%tape %sys "CREATE DATABASE db1 AS OF ~2000.1.1"])
    ==
  =.  run  +(run)
  =^  mov3  agent
    %:  ~(on-poke agent (bowl [run ~ ~2000.1.2]))
        %obelisk-action
        !>  :+  %tape
                %db1
                "CREATE TABLE db1..my-table (col1 @t) PRIMARY KEY (col1)"
    ==
  =.  run  +(run)
  =^  mov4  agent
    %:  ~(on-poke agent (bowl [run ~ ~2000.1.3]))
        %obelisk-action
        !>  :+  %tape
                %db1
                "INSERT INTO db1..my-table (col1) VALUES ('cord'); "
    ==
  =.  run  +(run)
  =^  mov5  agent
    %:  ~(on-poke agent (bowl [run ~ ~2000.1.4]))
        %obelisk-action
        !>  :+  %tape
                %db1
                "TRUNCATE TABLE my-table;  ".
                "INSERT INTO db1..my-table VALUES ('cord2') ('cord3') "
    ==
  ::
  %+  weld
    %+  expect-eq
      !>  expected-1
      !>  ;;((list cmd-result) ->+>+>+.mov4)
    %+  expect-eq
      !>  expected-2
      !>  ;;((list cmd-result) ->+>+>+.mov5)
::
::  truncate followed by insert in different script
++  test-integrate-03
  =|  run=@ud
  =/  expected  :-  %results
                    :~  [%message 'INSERT INTO %my-table']
                        [%server-time ~2000.1.4..15.01.02]
                        [%schema-time ~2000.1.2]
                        [%data-time ~2000.1.4..15.01.02]
                        [%message 'inserted:']
                        [%vector-count 2]
                        [%message 'table data:']
                        [%vector-count 2]
                    ==
  ::
  =^  move  agent
    %:  ~(on-poke agent (bowl [run ~ ~2000.1.1]))
        %obelisk-action
        !>([%tape %sys "CREATE DATABASE db1 AS OF ~2000.1.1"])
    ==
  =.  run  +(run)
  =^  mov3  agent
    %:  ~(on-poke agent (bowl [run ~ ~2000.1.2]))
        %obelisk-action
        !>  :+  %tape
                %db1
                "CREATE TABLE db1..my-table ".
                "(col1 @t, col2 @da) PRIMARY KEY (col1) ;"
    ==
  =.  run  +(run)
  =^  mov4  agent
    %:  ~(on-poke agent (bowl [run ~ ~2000.1.3]))
        %obelisk-action
        !>  :+  %tape
                %db1
                "INSERT INTO db1..my-table (col1, col2) ".
                "VALUES".
                "  ('today', ~2024.9.26)".
                "  ('tomorrow', ~2024.9.27)".
                "  ('next day', ~2024.9.28); "
    ==
  =.  run  +(run)
  =^  mov5  agent
    %:  ~(on-poke agent (bowl [run ~ ~2000.1.4..15.01.01]))
        %obelisk-action
        !>  :+  %tape
                %db1
                "TRUNCATE TABLE my-table;  "
    ==

  =.  run  +(run)
  =^  mov6  agent
    %:  ~(on-poke agent (bowl [run ~ ~2000.1.4..15.01.02]))
        %obelisk-action
        !>  :+  %tape
                %db1
                "INSERT INTO db1..my-table ".
                "VALUES".
                "  ('today', ~2024.9.26)".
                "  ('tomorrow', ~2024.9.27)"
    ==
  ::
  %+  expect-eq
    !>  expected
    !>  ;;(cmd-result ->+>+>+<.mov6)
::
::  truncate followed by insert in same script, different time
++  test-integrate-04
  =|  run=@ud
  =/  expected  :~
                    :-  %results
                      :~  [%message msg='TRUNCATE TABLE %my-table']
                          [%server-time date=~2000.1.4]
                          [%data-time date=~2000.1.4]
                          [%vector-count count=1]
                      ==
                    :-  %results
                      :~  [%message 'INSERT INTO %my-table']
                          [%server-time ~2000.1.4]
                          [%schema-time ~2000.1.2]
                          [%data-time ~2000.1.5]
                          [%message 'inserted:']
                          [%vector-count 2]
                          [%message 'table data:']
                          [%vector-count 2]
                      ==
                    ==
  ::
  =^  move  agent
    %:  ~(on-poke agent (bowl [run ~ ~2000.1.1]))
        %obelisk-action
        !>([%tape %sys "CREATE DATABASE db1 AS OF ~2000.1.1"])
    ==
  =.  run  +(run)
  =^  mov3  agent
    %:  ~(on-poke agent (bowl [run ~ ~2000.1.2]))
        %obelisk-action
        !>  :+  %tape
                %db1
                "CREATE TABLE db1..my-table (col1 @t) PRIMARY KEY (col1)"
    ==
  =.  run  +(run)
  =^  mov4  agent
    %:  ~(on-poke agent (bowl [run ~ ~2000.1.3]))
        %obelisk-action
        !>  :+  %tape
                %db1
                "INSERT INTO db1..my-table (col1) VALUES ('cord'); "
    ==
  =.  run  +(run)
  =^  mov5  agent
    %:  ~(on-poke agent (bowl [run ~ ~2000.1.4]))
        %obelisk-action
        !>  :+  %tape
                %db1
                "TRUNCATE TABLE my-table;  ".
                "INSERT INTO db1..my-table VALUES ('cord2') ('cord3') ".
                "AS OF ~2000.1.5"
    ==
  ::
  %+  expect-eq
    !>  expected
    !>  ;;((list cmd-result) ->+>+>+.mov5)
::
::  create db, create tbl, 2X insert with AS OF
++  test-integrate-05
  =|  run=@ud
  =/  expected  :~
                  :-  %results
                    :~  [%message 'created database %db2']
                        [%server-time ~2005.2.2]
                        [%schema-time ~2000.1.1]
                    ==
                  :-  %results
                    :~  [%message 'CREATE TABLE %my-table-1']
                        [%server-time ~2005.2.2]
                        [%schema-time ~2000.1.1]
                    ==
                  :-  %results
                    :~  [%message 'INSERT INTO %my-table-1']
                        [%server-time ~2005.2.2]
                        [%schema-time ~2000.1.1]
                        [%data-time ~2000.1.1]
                        [%message 'inserted:']
                        [%vector-count 3]
                        [%message 'table data:']
                        [%vector-count 3]
                    ==
                  :-  %results
                    :~  [%message 'INSERT INTO %my-table-1']
                        [%server-time ~2005.2.2]
                        [%schema-time ~2000.1.1]
                        [%data-time ~2005.2.2]
                        [%message 'inserted:']
                        [%vector-count 3]
                        [%message 'table data:']
                        [%vector-count 6]
                    ==
                  ==
  ::
  =^  move  agent
    %:  ~(on-poke agent (bowl [run ~ ~2005.2.2]))
        %obelisk-action
        !>  :+  %tape
                %db1
                "CREATE DATABASE db2 AS OF ~2000.1.1;".
                "CREATE TABLE db2..my-table-1 (col1 @t, col2 @da) ".
                "       PRIMARY KEY (col1) AS OF ~2000.1.1; ".
                "INSERT INTO db2..my-table-1 ".
                "  (col1, col2) ".
                "VALUES".
                "  ('today', ~2000.1.1)".
                "  ('tomorrow', ~2000.1.2)".
                "  ('next day', ~2000.1.3) AS OF ~2000.1.1;".
                "INSERT INTO db2..my-table-1 ".
                "  (col1, col2) ".
                "VALUES".
                "  ('next-today', ~2000.1.1)".
                "  ('next-tomorrow', ~2000.1.2)".
                "  ('next-next day', ~2000.1.3);"
    ==
  ::
  %+  expect-eq
    !>  expected
    !>  ;;((list cmd-result) ->+>+>+.move)
::
::  create db, create tbl, 2X insert
++  test-integrate-06
  =|  run=@ud
  =/  expected  :~
                  :-  %results
                    :~  [%message 'created database %db2']
                        [%server-time ~2000.1.1]
                        [%schema-time ~2000.1.1]
                    ==
                  :-  %results
                    :~  [%message 'CREATE TABLE %my-table-1']
                        [%server-time ~2000.1.1]
                        [%schema-time ~2000.1.1]
                    ==
                  :-  %results
                    :~  [%message 'INSERT INTO %my-table-1']
                        [%server-time ~2000.1.1]
                        [%schema-time ~2000.1.1]
                        [%data-time ~2000.1.1]
                        [%message 'inserted:']
                        [%vector-count 3]
                        [%message 'table data:']
                        [%vector-count 3]
                    ==
                  :-  %results
                    :~  [%message 'INSERT INTO %my-table-1']
                        [%server-time ~2000.1.1]
                        [%schema-time ~2000.1.1]
                        [%data-time ~2000.1.1]
                        [%message 'inserted:']
                        [%vector-count 3]
                        [%message 'table data:']
                        [%vector-count 6]
                    ==
                  ==
  ::
  =^  move  agent
    %:  ~(on-poke agent (bowl [run ~ ~2000.1.1]))
        %obelisk-action
        !>  :+  %tape
                %db1
                "CREATE DATABASE db2;".
                "CREATE TABLE db2..my-table-1 (col1 @t, col2 @da) ".
                "       PRIMARY KEY (col1); ".
                "INSERT INTO db2..my-table-1 ".
                "  (col1, col2) ".
                "VALUES".
                "  ('today', ~2000.1.1)".
                "  ('tomorrow', ~2000.1.2)".
                "  ('next day', ~2000.1.3);".
                "INSERT INTO db2..my-table-1 ".
                "  (col1, col2) ".
                "VALUES".
                "  ('next-today', ~2000.1.1)".
                "  ('next-tomorrow', ~2000.1.2)".
                "  ('next-next day', ~2000.1.3);"
    ==
  ::
  %+  expect-eq
    !>  expected
    !>  ;;((list cmd-result) ->+>+>+.move)
::
::  create db, create tbl, insert with AS OF; DROP Table, select
++  test-integrate-07
  =|  run=@ud
  =/  expected  :-  %results
                    :~  [%message 'SELECT']
                        :-  %result-set
                            :~
                              :-  %vector
                                  :~  [%col1 [~.t 'next day']]
                                      [%col2 [~.da ~2000.1.3]]
                                      ==
                              :-  %vector
                                  :~  [%col1 [~.t 'today']]
                                      [%col2 [~.da ~2000.1.1]]
                                      ==
                              :-  %vector
                                  :~  [%col1 [~.t 'tomorrow']]
                                      [%col2 [~.da ~2000.1.2]]
                                      ==
                            ==
                        [%server-time ~2012.5.1]
                        [%message 'db2.dbo.my-table-1']
                        [%schema-time ~2000.1.1]
                        [%data-time ~2000.1.1]
                        [%vector-count 3]
                    ==
  ::
  =^  move  agent
    %:  ~(on-poke agent (bowl [run ~ ~2005.2.2]))
        %obelisk-action
        !>  :+  %tape
                %db1
                "CREATE DATABASE db2 AS OF ~2000.1.1;".
                "CREATE TABLE db2..my-table-1 (col1 @t, col2 @da) ".
                "       PRIMARY KEY (col1) AS OF ~2000.1.1; ".
                "INSERT INTO db2..my-table-1 ".
                "  (col1, col2) ".
                "VALUES".
                "  ('today', ~2000.1.1)".
                "  ('tomorrow', ~2000.1.2)".
                "  ('next day', ~2000.1.3) AS OF ~2000.1.1;".
                "DROP TABLE FORCE db2..my-table-1;"
    ==
  =.  run  +(run)
  =^  mov2  agent
    %:  ~(on-poke agent (bowl [run ~ ~2012.5.1]))
        %obelisk-action
        !>  :+  %tape
                %db1
                "FROM db2..my-table-1 AS OF ~2005.2.1 ".
                "SELECT *"
    ==
  ::
  %+  expect-eq
    !>  expected
    !>  ;;(cmd-result ->+>+>+<.mov2)
::
::  create db, create tbl, 2X insert with AS OF, out of order
++  test-fail-integrate-00
  =|  run=@ud
  ::
  %+  expect-fail-message
        'INSERT: table %my-table-1 as-of data time out of order'
  |.  %:  ~(on-poke agent (bowl [run ~ ~2012.5.5]))
          %obelisk-action
          !>  :+  %tape
                  %db1
                  "CREATE DATABASE db2 AS OF ~2000.1.1;".
                  "CREATE TABLE db2..my-table-1 (col1 @t, col2 @da) ".
                  "       PRIMARY KEY (col1) AS OF ~2000.1.1; ".
                  "INSERT INTO db2..my-table-1 ".
                  "  (col1, col2) ".
                  "VALUES".
                  "  ('today', ~2000.1.1)".
                  "  ('tomorrow', ~2000.1.2)".
                  "  ('next day', ~2000.1.3);".
                  "INSERT INTO db2..my-table-1 ".
                  "  (col1, col2) ".
                  "VALUES".
                  "  ('next-today', ~2000.1.1)".
                  "  ('next-tomorrow', ~2000.1.2)".
                  "  ('next-next day', ~2000.1.3) AS OF ~2000.1.1;"
      ==
::
::  create db, create tbl, insert with AS OF; DROP Table, fail select
++  test-fail-integrate-01
  =|  run=@ud
  ::
  =^  move  agent
    %:  ~(on-poke agent (bowl [run ~ ~2005.2.2]))
        %obelisk-action
        !>  :+  %tape
                %db1
                "CREATE DATABASE db2 AS OF ~2000.1.1;".
                "CREATE TABLE db2..my-table-1 (col1 @t, col2 @da) ".
                "       PRIMARY KEY (col1) AS OF ~2000.1.1; ".
                "INSERT INTO db2..my-table-1 ".
                "  (col1, col2) ".
                "VALUES".
                "  ('today', ~2000.1.1)".
                "  ('tomorrow', ~2000.1.2)".
                "  ('next day', ~2000.1.3) AS OF ~2000.1.1;".
                "DROP TABLE FORCE db2..my-table-1;"
    ==

  %+  expect-fail-message
    'SELECT: table %db2.%dbo.%my-table-1 does not exist at schema time ~2005.2.2'
  |.  %:  ~(on-poke agent (bowl [run ~ ~2012.5.5]))
      %obelisk-action
      !>  :+  %tape
              %db1
              "FROM db2..my-table-1 ".
                "SELECT *"
    ==
--
