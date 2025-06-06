::  Demonstrate unit testing queries on a Gall agent with %obelisk.
::
/-  ast, *obelisk
/+  *test, *sys-views
/=  agent  /app/obelisk
|%
::
::  Build an example bowl manually
++  bowl
  |=  [run=@ud now=@da]
  ^-  bowl:gall
  :*  [~zod ~zod %obelisk `path`(limo `path`/test-agent)]  :: (our src dap sap)
      [~ ~ ~]                                              :: (wex sup sky)
      [run `@uvJ`(shax run) now [~zod %base ud+run]]       :: (act eny now byk)
  ==
::
::  Build a reference state mold
+$  state
  $:  %0
      =server
      ==
--
|%
::
++  expected-2-rows
        :~
          :-  %vector
              :~  [%col1 [~.t 'cord']]
                  [%col2 [~.p ~nomryg-nilref]]
                  [%col3 [~.ud 20]]
                  ==
          :-  %vector
              :~  [%col1 [~.t 'Default']]
                  [%col2 [~.p ~zod]]
                  [%col3 [~.ud 0]]
                  ==
          ==
::
:: INSERT
::
::  insert rows to table
++  test-insert-01
  =|  run=@ud
  =/  my-insert  "INSERT INTO db1..my-table (col1, col2, col3)  ".
                 "VALUES ('cord',~nomryg-nilref,20) ('Default',Default, 0)"
  =/  expected-1  :-  %results
                      :~  [%message 'INSERT INTO db1.dbo.my-table']
                          [%server-time ~2012.5.3]
                          [%schema-time ~2012.5.1]
                          [%data-time ~2012.5.1]
                          [%message 'inserted:']
                          [%vector-count 2]
                          [%message 'table data:']
                          [%vector-count 2]
                      ==
  =/  expected-2  :-  %results
                      :~  [%message 'SELECT']
                          [%result-set expected-2-rows]
                          [%server-time ~2012.5.4]
                          [%message 'db1.dbo.my-table']
                          [%schema-time ~2012.5.1]
                          [%data-time ~2012.5.3]
                          [%vector-count 2]
                      ==
  ::
  =^  mov1  agent
    %+  ~(on-poke agent (bowl [run ~2012.4.30]))
        %obelisk-action
        !>([%tape2 %sys "CREATE DATABASE db1"])
  =.  run  +(run)
  =^  mov2  agent
    %+  ~(on-poke agent (bowl [run ~2012.5.1]))
        %obelisk-action
        !>  :+  %tape2
                %db1
                "CREATE TABLE db1..my-table ".
                "(col1 @t, col2 @p, col3 @ud) ".
                "PRIMARY KEY (col1)"
  =.  run  +(run)
  =^  mov3  agent
    %+  ~(on-poke agent (bowl [run ~2012.5.3]))
        %obelisk-action
        !>([%tape2 %db1 my-insert])
  =.  run  +(run)
  =^  mov4  agent
    %+  ~(on-poke agent (bowl [run ~2012.5.4]))
        %obelisk-action
        !>([%tape2 %db1 "FROM my-table SELECT *"])
  ::
  %+  weld
      %+  expect-eq
        !>  expected-1
        !>  ;;(cmd-result ->+>+>+<.mov3)
      %+  expect-eq
        !>  expected-2
        !>  ;;(cmd-result ->+>+>+<.mov4)
::
::  insert rows to table, cols not in cannonical order
++  test-insert-02
  =|  run=@ud
  =/  my-insert  "INSERT INTO db1..my-table (col1, col3, col2)  ".
                 "VALUES ('cord',20,~nomryg-nilref) ('Default', 0,Default)"
  =/  expected-1  :-  %results
                      :~  [%message 'INSERT INTO db1.dbo.my-table']
                          [%server-time ~2012.5.3]
                          [%schema-time ~2012.5.1]
                          [%data-time ~2012.5.1]
                          [%message 'inserted:']
                          [%vector-count 2]
                          [%message 'table data:']
                          [%vector-count 2]
                      ==
  =/  expected-2  :-  %results
                      :~  [%message 'SELECT']
                          [%result-set expected-2-rows]
                          [%server-time ~2012.5.4]
                          [%message 'db1.dbo.my-table']
                          [%schema-time ~2012.5.1]
                          [%data-time ~2012.5.3]
                          [%vector-count 2]
                      ==
  ::
  =^  mov1  agent
    %+  ~(on-poke agent (bowl [run ~2012.4.30]))
        %obelisk-action
        !>([%tape2 %sys "CREATE DATABASE db1"])
  =.  run  +(run)
  =^  mov2  agent
    %+  ~(on-poke agent (bowl [run ~2012.5.1]))
        %obelisk-action
        !>  :+  %tape2
                %db1
                "CREATE TABLE db1..my-table ".
                "(col1 @t, col2 @p, col3 @ud) ".
                "PRIMARY KEY (col1)"
  =.  run  +(run)
  =^  mov3  agent
    %+  ~(on-poke agent (bowl [run ~2012.5.3]))
        %obelisk-action
        !>([%tape2 %db1 my-insert])
  =.  run  +(run)
  =^  mov4  agent
    %+  ~(on-poke agent (bowl [run ~2012.5.4]))
        %obelisk-action
        !>([%tape2 %db1 "FROM my-table SELECT *"])
  ::
  %+  weld
      %+  expect-eq
        !>  expected-1
        !>  ;;(cmd-result ->+>+>+<.mov3)
      %+  expect-eq
        !>  expected-2
        !>  ;;(cmd-result ->+>+>+<.mov4)
::
::  insert rows to table, cols in inverse cannonical order
++  test-insert-03
  =|  run=@ud
  =/  my-insert  "INSERT INTO db1..my-table (col3, col2, col1)  ".
                 "VALUES (20,~nomryg-nilref,'cord') (0,Default,'Default')"
  =/  expected-1  :-  %results
                      :~  [%message 'INSERT INTO db1.dbo.my-table']
                          [%server-time ~2012.5.3]
                          [%schema-time ~2012.5.1]
                          [%data-time ~2012.5.1]
                          [%message 'inserted:']
                          [%vector-count 2]
                          [%message 'table data:']
                          [%vector-count 2]
                      ==
  =/  expected-2  :-  %results
                      :~  [%message 'SELECT']
                          [%result-set expected-2-rows]
                          [%server-time ~2012.5.4]
                          [%message 'db1.dbo.my-table']
                          [%schema-time ~2012.5.1]
                          [%data-time ~2012.5.3]
                          [%vector-count 2]
                      ==
  ::
  =^  mov1  agent
    %+  ~(on-poke agent (bowl [run ~2012.4.30]))
        %obelisk-action
        !>([%tape2 %sys "CREATE DATABASE db1"])
  =.  run  +(run)
  =^  mov2  agent
    %+  ~(on-poke agent (bowl [run ~2012.5.1]))
        %obelisk-action
        !>  :+  %tape2
                %db1
                "CREATE TABLE db1..my-table ".
                "(col1 @t, col2 @p, col3 @ud) ".
                "PRIMARY KEY (col1)"
  =.  run  +(run)
  =^  mov3  agent
    %+  ~(on-poke agent (bowl [run ~2012.5.3]))
        %obelisk-action
        !>([%tape2 %db1 my-insert])
  =.  run  +(run)
  =^  mov4  agent
    %+  ~(on-poke agent (bowl [run ~2012.5.4]))
        %obelisk-action
        !>([%tape2 %db1 "FROM my-table SELECT *"])
  ::
  %+  weld
      %+  expect-eq
        !>  expected-1
        !>  ;;(cmd-result ->+>+>+<.mov3)
      %+  expect-eq
        !>  expected-2
        !>  ;;(cmd-result ->+>+>+<.mov4)
::
::  insert rows to table, canonical order, columns not specified
++  test-insert-04
  =|  run=@ud
  =/  my-insert  "INSERT INTO db1..my-table ".
                 "VALUES ('cord',~nomryg-nilref,20) ('Default',Default, 0)"
  =/  expected-1  :-  %results
                      :~  [%message 'INSERT INTO db1.dbo.my-table']
                          [%server-time ~2012.5.3]
                          [%schema-time ~2012.5.1]
                          [%data-time ~2012.5.1]
                          [%message 'inserted:']
                          [%vector-count 2]
                          [%message 'table data:']
                          [%vector-count 2]
                    ==
  =/  expected-2  :-  %results
                      :~  [%message 'SELECT']
                          [%result-set expected-2-rows]
                          [%server-time ~2012.5.4]
                          [%message 'db1.dbo.my-table']
                          [%schema-time ~2012.5.1]
                          [%data-time ~2012.5.3]
                          [%vector-count 2]
                      ==
  ::
  =^  mov1  agent
    %+  ~(on-poke agent (bowl [run ~2012.4.30]))
        %obelisk-action
        !>([%tape2 %sys "CREATE DATABASE db1"])
  =.  run  +(run)
  =^  mov2  agent
    %+  ~(on-poke agent (bowl [run ~2012.5.1]))
        %obelisk-action
        !>  :+  %tape2
                %db1
                "CREATE TABLE db1..my-table ".
                "(col1 @t, col2 @p, col3 @ud) ".
                "PRIMARY KEY (col1)"
  =.  run  +(run)
  =^  mov3  agent
    %+  ~(on-poke agent (bowl [run ~2012.5.3]))
        %obelisk-action
        !>([%tape2 %db1 my-insert])
  =.  run  +(run)
  =^  mov4  agent
    %+  ~(on-poke agent (bowl [run ~2012.5.4]))
        %obelisk-action
        !>([%tape2 %db1 "FROM my-table SELECT *"])
  ::
  %+  weld
      %+  expect-eq
        !>  expected-1
        !>  ;;(cmd-result ->+>+>+<.mov3)
      %+  expect-eq
        !>  expected-2
        !>  ;;(cmd-result ->+>+>+<.mov4)
::
::  insert rows to table, table already populated
++  test-insert-05
  =|  run=@ud
  =/  my-insert-1  "INSERT INTO db1..my-table ".
                 "VALUES ('cord',~nomryg-nilref,20) ('Default',Default, 0)"
  =/  my-insert-2  "INSERT INTO db1..my-table ".
                 "VALUES ('cord-2',~sampel-palnet,40) ('Default-2',Default, 0)"
  =/  expected-1  :-  %results
                      :~  [%message 'INSERT INTO db1.dbo.my-table']
                          [%server-time ~2012.5.4]
                          [%schema-time ~2012.5.1]
                          [%data-time ~2012.5.3]
                          [%message 'inserted:']
                          [%vector-count 2]
                          [%message 'table data:']
                          [%vector-count 4]
                    ==
  =/  expected-rows  :: to do: make "real" alpha ordering
        :~
          :-  %vector
              :~  [%col1 [~.t 'cord']]
                  [%col2 [~.p ~nomryg-nilref]]
                  [%col3 [~.ud 20]]
                  ==
          :-  %vector
              :~  [%col1 [~.t 'cord-2']]
                  [%col2 [~.p ~sampel-palnet]]
                  [%col3 [~.ud 40]]
                  ==
          :-  %vector
              :~  [%col1 [~.t 'Default']]
                  [%col2 [~.p ~zod]]
                  [%col3 [~.ud 0]]
                  ==
          :-  %vector
              :~  [%col1 [~.t 'Default-2']]
                  [%col2 [~.p ~zod]]
                  [%col3 [~.ud 0]]
                  ==
            ==
  =/  expected-2  :-  %results
                      :~  [%message 'SELECT']
                          [%result-set expected-rows]
                          [%server-time ~2012.5.5]
                          [%message 'db1.dbo.my-table']
                          [%schema-time ~2012.5.1]
                          [%data-time ~2012.5.4]
                          [%vector-count 4]
                      ==
  ::
  =^  mov1  agent
    %+  ~(on-poke agent (bowl [run ~2012.4.30]))
        %obelisk-action
        !>([%tape2 %sys "CREATE DATABASE db1"])
  =.  run  +(run)
  =^  mov2  agent
    %+  ~(on-poke agent (bowl [run ~2012.5.1]))
        %obelisk-action
        !>  :+  %tape2
                %db1
                "CREATE TABLE db1..my-table ".
                "(col1 @t, col2 @p, col3 @ud) ".
                "PRIMARY KEY (col1)"
  =.  run  +(run)
  =^  mov3  agent
    %+  ~(on-poke agent (bowl [run ~2012.5.3]))
        %obelisk-action
        !>([%tape2 %db1 my-insert-1])
  =.  run  +(run)
  =^  mov4  agent
    %+  ~(on-poke agent (bowl [run ~2012.5.4]))
        %obelisk-action
        !>([%tape2 %db1 my-insert-2])
  =.  run  +(run)
  =^  mov5  agent
    %+  ~(on-poke agent (bowl [run ~2012.5.5]))
        %obelisk-action
        !>([%tape2 %db1 "FROM my-table SELECT *"])
  ::
  %+  weld
      %+  expect-eq
        !>  expected-1
        !>  ;;(cmd-result ->+>+>+<.mov4)
      %+  expect-eq
        !>  expected-2
        !>  ;;(cmd-result ->+>+>+<.mov5)
::
::  insert rows to table, not default DB
++  test-insert-06
  =|  run=@ud
  =/  expected-1  :-  %results
                      :~  [%message 'INSERT INTO db2.dbo.my-table']
                          [%server-time ~2012.5.3]
                          [%schema-time ~2012.5.1]
                          [%data-time ~2012.5.1]
                          [%message 'inserted:']
                          [%vector-count 2]
                          [%message 'table data:']
                          [%vector-count 2]
                      ==
  =/  expected-2  :-  %results
                      :~  [%message 'SELECT']
                          [%result-set expected-2-rows]
                          [%server-time ~2012.5.4]
                          [%message 'db2.dbo.my-table']
                          [%schema-time ~2012.5.1]
                          [%data-time ~2012.5.3]
                          [%vector-count 2]
                      ==
  ::
  =^  mov1  agent
    %+  ~(on-poke agent (bowl [run ~2012.4.29]))
        %obelisk-action
        !>([%tape2 %sys "CREATE DATABASE db1"])
  =.  run  +(run)
  =^  mov2  agent
    %+  ~(on-poke agent (bowl [run ~2012.4.30]))
        %obelisk-action
        !>([%tape2 %sys "CREATE DATABASE db2"])
  =.  run  +(run)
  =^  mov3  agent
    %+  ~(on-poke agent (bowl [run ~2012.5.1]))
        %obelisk-action
        !>  :+  %tape2
                %db2
                "CREATE TABLE db2..my-table ".
                "(col1 @t, col2 @p, col3 @ud) ".
                "PRIMARY KEY (col1)"
  =.  run  +(run)
  =^  mov4  agent
    %+  ~(on-poke agent (bowl [run ~2012.5.3]))
        %obelisk-action
        !>  :+  %tape2
                %db1
                "INSERT INTO db2..my-table (col1, col2, col3)  ".
                "VALUES ('cord',~nomryg-nilref,20) ('Default',Default, 0)"
  =.  run  +(run)
  =^  mov5  agent
    %+  ~(on-poke agent (bowl [run ~2012.5.4]))
        %obelisk-action
        !>([%tape2 %db2 "FROM my-table SELECT *"])
  ::
  %+  weld
      %+  expect-eq
        !>  expected-1
        !>  ;;(cmd-result ->+>+>+<.mov4)
      %+  expect-eq
        !>  expected-2
        !>  ;;(cmd-result ->+>+>+<.mov5)


::
::  insert followed by insert in same script, same time
++  test-insert-07
  =|  run=@ud
  =/  expected  :~
                  :-  %results
                      :~  [%message 'INSERT INTO db1.dbo.my-table']
                          [%server-time ~2000.1.3]
                          [%schema-time ~2000.1.2]
                          [%data-time ~2000.1.2]
                          [%message 'inserted:']
                          [%vector-count 1]
                          [%message 'table data:']
                          [%vector-count 1]
                      ==
                  :-  %results
                      :~  [%message 'INSERT INTO db1.dbo.my-table']
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
    %+  ~(on-poke agent (bowl [run ~2000.1.1]))
        %obelisk-action
        !>([%tape2 %sys "CREATE DATABASE db1 AS OF ~2000.1.1"])
  =.  run  +(run)
  =^  mov3  agent
    %+  ~(on-poke agent (bowl [run ~2000.1.2]))
        %obelisk-action
        !>  :+  %tape2
                %db1
                "CREATE TABLE db1..my-table (col1 @t) PRIMARY KEY (col1)"
  =.  run  +(run)
  =^  mov4  agent
    %+  ~(on-poke agent (bowl [run ~2000.1.3]))
        %obelisk-action
        !>  :+  %tape2
                %db1
                "INSERT INTO db1..my-table (col1) VALUES ('cord'); ".
                "INSERT INTO db1..my-table VALUES ('cord2') "
  ::
  %+  expect-eq
    !>  expected
    !>  ;;((list cmd-result) ->+>+>+.mov4)
::
::  insert followed by insert in same script, next time
++  test-insert-08
  =|  run=@ud
  =/  expected-1  :~
                    :-  %results
                        :~  [%message 'INSERT INTO db1.dbo.my-table']
                            [%server-time ~2000.1.3]
                            [%schema-time ~2000.1.2]
                            [%data-time ~2000.1.2]
                            [%message 'inserted:']
                            [%vector-count 1]
                            [%message 'table data:']
                            [%vector-count 1]
                        ==
                    :-  %results
                        :~  [%message 'INSERT INTO db1.dbo.my-table']
                            [%server-time ~2000.1.3]
                            [%schema-time ~2000.1.2]
                            [%data-time ~2000.1.2]
                            [%message 'inserted:']
                            [%vector-count 1]
                            [%message 'table data:']
                            [%vector-count 1]
                        ==
                    ==
  =/  expected-2a-rows  :~
                          :-  %vector
                              :~  [%col1 [~.t 'cord']]
                                  ==
                          ==
  =/  expected-2b-rows  :~
                          :-  %vector
                              :~  [%col1 [~.t 'cord2']]
                                  ==
                          ==
  =/  expected-2  :~
                    :-  %results
                      :~  [%message 'SELECT']
                          [%result-set expected-2b-rows]
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
                          [%data-time ~2000.1.3]
                          [%vector-count 1]
                      ==
                    ==
  ::
  =^  move  agent
    %+  ~(on-poke agent (bowl [run ~2000.1.1]))
        %obelisk-action
        !>([%tape2 %sys "CREATE DATABASE db1 AS OF ~2000.1.1"])
  =.  run  +(run)
  =^  mov3  agent
    %+  ~(on-poke agent (bowl [run ~2000.1.2]))
        %obelisk-action
        !>  :+  %tape2
                %db1
                "CREATE TABLE db1..my-table (col1 @t) PRIMARY KEY (col1)"
  =.  run  +(run)
  =^  mov4  agent
    %+  ~(on-poke agent (bowl [run ~2000.1.3]))
        %obelisk-action
        !>  :+  %tape2
                %db1
                "INSERT INTO db1..my-table (col1) VALUES ('cord'); ".
                "INSERT INTO db1..my-table AS OF ~2000.1.2..12.12.12 ".
                "VALUES ('cord2') "
  =.  run  +(run)
  =^  mov5  agent
    %+  ~(on-poke agent (bowl [run ~2000.1.4]))
        %obelisk-action
        !>  :+  %tape2
                %db1
                "FROM my-table AS OF ~2000.1.3 SELECT *; ".
                "FROM my-table SELECT *"
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
++  test-insert-09
  =|  run=@ud
  =/  expected-1  :~
                    :-  %results
                        :~  [%message 'INSERT INTO db1.dbo.my-table']
                            [%server-time ~2000.1.3]
                            [%schema-time ~2000.1.2]
                            [%data-time ~2000.1.2]
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
                      :~  [%message 'TRUNCATE TABLE db1.dbo.my-table']
                          [%server-time date=~2000.1.4]
                          [%data-time date=~2000.1.4]
                          [%vector-count count=1]
                      ==
                    :-  %results
                        :~  [%message 'INSERT INTO db1.dbo.my-table']
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
    %+  ~(on-poke agent (bowl [run ~2000.1.1]))
        %obelisk-action
        !>([%tape2 %sys "CREATE DATABASE db1 AS OF ~2000.1.1"])
  =.  run  +(run)
  =^  mov3  agent
    %+  ~(on-poke agent (bowl [run ~2000.1.2]))
        %obelisk-action
        !>  :+  %tape2
                %db1
                "CREATE TABLE db1..my-table (col1 @t) PRIMARY KEY (col1)"
  =.  run  +(run)
  =^  mov4  agent
    %+  ~(on-poke agent (bowl [run ~2000.1.3]))
        %obelisk-action
        !>  :+  %tape2
                %db1
                "INSERT INTO db1..my-table (col1) VALUES ('cord'); "
  =.  run  +(run)
  =^  mov5  agent
    %+  ~(on-poke agent (bowl [run ~2000.1.4]))
        %obelisk-action
        !>  :+  %tape2
                %db1
                "TRUNCATE TABLE my-table;  ".
                "INSERT INTO db1..my-table VALUES ('cord2') ('cord3') "
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
++  test-insert-10
  =|  run=@ud
  =/  expected  :-  %results
                    :~  [%message 'INSERT INTO db1.dbo.my-table']
                        [%server-time ~2000.1.4..15.01.02]
                        [%schema-time ~2000.1.2]
                        [%data-time ~2000.1.4..15.01.01]
                        [%message 'inserted:']
                        [%vector-count 2]
                        [%message 'table data:']
                        [%vector-count 2]
                    ==
  ::
  =^  move  agent
    %+  ~(on-poke agent (bowl [run ~2000.1.1]))
        %obelisk-action
        !>([%tape2 %sys "CREATE DATABASE db1 AS OF ~2000.1.1"])
  =.  run  +(run)
  =^  mov3  agent
    %+  ~(on-poke agent (bowl [run ~2000.1.2]))
        %obelisk-action
        !>  :+  %tape2
                %db1
                "CREATE TABLE db1..my-table ".
                "(col1 @t, col2 @da) PRIMARY KEY (col1) ;"
  =.  run  +(run)
  =^  mov4  agent
    %+  ~(on-poke agent (bowl [run ~2000.1.3]))
        %obelisk-action
        !>  :+  %tape2
                %db1
                "INSERT INTO db1..my-table (col1, col2) ".
                "VALUES".
                "  ('today', ~2024.9.26)".
                "  ('tomorrow', ~2024.9.27)".
                "  ('next day', ~2024.9.28); "
  =.  run  +(run)
  =^  mov5  agent
    %+  ~(on-poke agent (bowl [run ~2000.1.4..15.01.01]))
        %obelisk-action
        !>  :+  %tape2
                %db1
                "TRUNCATE TABLE my-table;  "

  =.  run  +(run)
  =^  mov6  agent
    %+  ~(on-poke agent (bowl [run ~2000.1.4..15.01.02]))
        %obelisk-action
        !>  :+  %tape2
                %db1
                "INSERT INTO db1..my-table ".
                "VALUES".
                "  ('today', ~2024.9.26)".
                "  ('tomorrow', ~2024.9.27)"
  ::
  %+  expect-eq
    !>  expected
    !>  ;;(cmd-result ->+>+>+<.mov6)
::
::  truncate followed by insert in same script, different time
++  test-insert-11
  =|  run=@ud
  =/  expected-rows  :~
                          :-  %vector
                              :~  [%col1 [~.t 'cord']]
                                  ==
                          :-  %vector
                              :~  [%col1 [~.t 'cord2']]
                                  ==
                          :-  %vector
                              :~  [%col1 [~.t 'cord3']]
                                  ==
                          ==
  =/  expected-1  :~
                    :-  %results
                      :~  [%message 'TRUNCATE TABLE db1.dbo.my-table']
                          [%server-time date=~2000.1.4]
                          [%data-time date=~2000.1.4]
                          [%vector-count count=1]
                      ==
                    :-  %results
                      :~  [%message 'INSERT INTO db1.dbo.my-table']
                          [%server-time ~2000.1.4]
                          [%schema-time ~2000.1.2]
                          [%data-time ~2000.1.3]
                          [%message 'inserted:']
                          [%vector-count 2]
                          [%message 'table data:']
                          [%vector-count 3]
                      ==
                    ==
  =/  expected-2  :~  %results
                      [%message 'SELECT']
                      [%result-set expected-rows]
                      [%server-time ~2000.1.5]
                      [%message 'db1.dbo.my-table']
                      [%schema-time ~2000.1.2]
                      [%data-time ~2000.1.4]
                      [%vector-count 3]
                      ==
  ::
  =^  move  agent
    %+  ~(on-poke agent (bowl [run ~2000.1.1]))
        %obelisk-action
        !>([%tape2 %sys "CREATE DATABASE db1 AS OF ~2000.1.1"])
  =.  run  +(run)
  =^  mov3  agent
    %+  ~(on-poke agent (bowl [run ~2000.1.2]))
        %obelisk-action
        !>  :+  %tape2
                %db1
                "CREATE TABLE db1..my-table (col1 @t) PRIMARY KEY (col1)"
  =.  run  +(run)
  =^  mov4  agent
    %+  ~(on-poke agent (bowl [run ~2000.1.3]))
        %obelisk-action
        !>  :+  %tape2
                %db1
                "INSERT INTO db1..my-table (col1) VALUES ('cord'); "
  =.  run  +(run)
  =^  mov5  agent
    %+  ~(on-poke agent (bowl [run ~2000.1.4]))
        %obelisk-action
        !>  :+  %tape2
                %db1
                "TRUNCATE TABLE my-table;  ".
                "INSERT INTO db1..my-table AS OF ~2000.1.3 ".
                "VALUES ('cord2') ('cord3') "
  =.  run  +(run)
  =^  mov6  agent
    %+  ~(on-poke agent (bowl [run ~2000.1.5]))
        %obelisk-action
        !>([%tape2 %db1 "FROM my-table SELECT *"])
  ::
  %+  weld
    %+  expect-eq
      !>  expected-1
      !>  ;;((list cmd-result) ->+>+>+.mov5)
    (eval-results expected-2 ;;(cmd-result ->+>+>+<.mov6))
::
::  create db, create tbl, 2X insert with AS OF
++  test-insert-12
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
                    :~  [%message 'INSERT INTO db2.dbo.my-table-1']
                        [%server-time ~2005.2.2]
                        [%schema-time ~2000.1.1]
                        [%data-time ~2000.1.1]
                        [%message 'inserted:']
                        [%vector-count 3]
                        [%message 'table data:']
                        [%vector-count 3]
                    ==
                  :-  %results
                    :~  [%message 'INSERT INTO db2.dbo.my-table-1']
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
    %+  ~(on-poke agent (bowl [run ~2005.2.2]))
        %obelisk-action
        !>  :+  %tape2
                %db1
                "CREATE DATABASE db2 AS OF ~2000.1.1;".
                "CREATE TABLE db2..my-table-1 (col1 @t, col2 @da) ".
                "       PRIMARY KEY (col1) AS OF ~2000.1.1; ".
                "INSERT INTO db2..my-table-1  AS OF ~2000.1.1".
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
  ::
  %+  expect-eq
    !>  expected
    !>  ;;((list cmd-result) ->+>+>+.move)
::
::  create db, create tbl, 2X insert
++  test-insert-13
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
                    :~  [%message 'INSERT INTO db2.dbo.my-table-1']
                        [%server-time ~2000.1.1]
                        [%schema-time ~2000.1.1]
                        [%data-time ~2000.1.1]
                        [%message 'inserted:']
                        [%vector-count 3]
                        [%message 'table data:']
                        [%vector-count 3]
                    ==
                  :-  %results
                    :~  [%message 'INSERT INTO db2.dbo.my-table-1']
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
    %+  ~(on-poke agent (bowl [run ~2000.1.1]))
        %obelisk-action
        !>  :+  %tape2
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
  ::
  %+  expect-eq
    !>  expected
    !>  ;;((list cmd-result) ->+>+>+.move)
::
::  create db, create tbl, insert with AS OF; DROP Table, select
++  test-insert-14
  =|  run=@ud
  =/  expected  :-  %results
                    :~  [%message 'SELECT']
                        [%result-set ~]
                        [%server-time ~2012.5.1]
                        [%message 'db2.dbo.my-table-1']
                        [%schema-time ~2000.1.1]
                        [%data-time ~2000.1.1]
                        [%vector-count 0]
                        ==
  ::
  =^  move  agent
    %+  ~(on-poke agent (bowl [run ~2005.2.2]))
        %obelisk-action
        !>  :+  %tape2
                %db1
                "CREATE DATABASE db2 AS OF ~2000.1.1;".
                "CREATE TABLE db2..my-table-1 (col1 @t, col2 @da) ".
                "       PRIMARY KEY (col1) AS OF ~2000.1.1; ".
                "INSERT INTO db2..my-table-1  AS OF ~2000.1.1".
                "  (col1, col2) ".
                "VALUES".
                "  ('today', ~2000.1.1)".
                "  ('tomorrow', ~2000.1.2)".
                "  ('next day', ~2000.1.3);".
                "DROP TABLE FORCE db2..my-table-1;"
  =.  run  +(run)
  =^  mov2  agent
    %+  ~(on-poke agent (bowl [run ~2012.5.1]))
        %obelisk-action
        !>  :+  %tape2
                %db1
                "FROM db2..my-table-1 AS OF ~2000.1.1 ".
                "SELECT *"
  ::
  %+  expect-eq
    !>  expected
    !>  ;;(cmd-result ->+>+>+<.mov2)
::
::  create db, create tbl, 2X insert with AS OF on second
++  test-insert-15
  =|  run=@ud
  =/  expected  :~  %results
                    [%message 'SELECT']
                    :-  %result-set
                        :~
                          :-  %vector
                              :~  [%col1 [~.t 'next-today']]
                                  [%col2 [~.da ~2000.1.1]]
                                  ==
                          :-  %vector
                              :~  [%col1 [~.t 'next-tomorrow']]
                                  [%col2 [~.da ~2000.1.2]]
                                  ==
                          :-  %vector
                              :~  [%col1 [~.t 'next-next day']]
                                  [%col2 [~.da ~2000.1.3]]
                                  ==
                          ==
                    [%server-time ~2012.5.1]
                    [%message 'db2.dbo.my-table-1']
                    [%schema-time ~2000.1.1]
                    [%data-time ~2005.2.2]
                    [%vector-count 3]
                    ==
  ::
  =^  mov1  agent
    %+  ~(on-poke agent (bowl [run ~2005.2.2]))
        %obelisk-action
        !>  :+  %tape2
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
                  "INSERT INTO db2..my-table-1  AS OF ~2000.1.1".
                  "  (col1, col2) ".
                  "VALUES".
                  "  ('next-today', ~2000.1.1)".
                  "  ('next-tomorrow', ~2000.1.2)".
                  "  ('next-next day', ~2000.1.3);"
  =^  mov2  agent
    %+  ~(on-poke agent (bowl [run ~2012.5.1]))
        %obelisk-action
        !>  :+  %tape2
                %db1
                "FROM db2..my-table-1 ".
                "SELECT *"
  ::
  (eval-results expected ;;(cmd-result ->+>+>+<.mov2))
::
::  2X insert with AS OF > second
++  test-insert-16
  =|  run=@ud
  =/  expected  :~  %results
                    [%message 'SELECT']
                    :-  %result-set
                        :~
                          :-  %vector
                              :~  [%col1 [~.t 'next-today']]
                                  [%col2 [~.da ~2000.1.1]]
                                  ==
                          :-  %vector
                              :~  [%col1 [~.t 'next-tomorrow']]
                                  [%col2 [~.da ~2000.1.2]]
                                  ==
                          :-  %vector
                              :~  [%col1 [~.t 'next-next day']]
                                  [%col2 [~.da ~2000.1.3]]
                                  ==
                          ==
                    [%server-time ~2012.5.2]
                    [%message 'db2.dbo.my-table-1']
                    [%schema-time ~2000.1.1]
                    [%data-time ~2012.5.1]
                    [%vector-count 3]
                    ==
  ::
  =^  mov1  agent
    %+  ~(on-poke agent (bowl [run ~2005.2.2]))
        %obelisk-action
        !>  :+  %tape2
                %db1
                  "CREATE DATABASE db2 AS OF ~2000.1.1;".
                  "CREATE TABLE db2..my-table-1 (col1 @t, col2 @da) ".
                  "       PRIMARY KEY (col1) AS OF ~2000.1.1; ".
                  "INSERT INTO db2..my-table-1 ".
                  "  (col1, col2) ".
                  "VALUES".
                  "  ('today', ~2000.1.1)".
                  "  ('tomorrow', ~2000.1.2)".
                  "  ('next day', ~2000.1.3);"
  =^  mov2  agent
    %+  ~(on-poke agent (bowl [run ~2012.5.1]))
        %obelisk-action
        !>  :+  %tape2
                %db1
                "INSERT INTO db2..my-table-1  AS OF ~2001.1.1".
                  "  (col1, col2) ".
                  "VALUES".
                  "  ('next-today', ~2000.1.1)".
                  "  ('next-tomorrow', ~2000.1.2)".
                  "  ('next-next day', ~2000.1.3);"
  =^  mov3  agent
    %+  ~(on-poke agent (bowl [run ~2012.5.2]))
        %obelisk-action
        !>  :+  %tape2
                %db1
                "FROM db2..my-table-1 ".
                "SELECT *"
  ::
  (eval-results expected ;;(cmd-result ->+>+>+<.mov3))
::
:: insert then insert to previous AS OF time
++  test-insert-17
  =|  run=@ud
  =/  expected  :~  %results
                    [%message 'SELECT']
                    :-  %result-set
                        :~
                          :-  %vector
                              :~  [%col1 [~.t 'cord2']]
                                  [%col2 [~.p ~nomryg-nilref]]
                                  [%col3 [~.ud 20]]
                                  ==
                          :-  %vector
                              :~  [%col1 [~.t 'Default2']]
                                  [%col2 [~.p ~zod]]
                                  [%col3 [~.ud 0]]
                                  ==
                          ==
                    [%server-time ~2012.5.3]
                    [%message 'db1.dbo.my-table']
                    [%schema-time ~2012.5.1]
                    [%data-time ~2012.5.2]
                    [%vector-count 2]
                    ==  
  ::
  =^  mov1  agent
    %+  ~(on-poke agent (bowl [run ~2012.4.30]))
        %obelisk-action
        !>([%tape2 %sys "CREATE DATABASE db1"])
  =.  run  +(run)
  =^  mov2  agent
    %+  ~(on-poke agent (bowl [run ~2012.5.1]))
        %obelisk-action
        !>  :+  %tape2
                %db1
                "CREATE TABLE db1..my-table ".
                "(col1 @t, col2 @p, col3 @ud) ".
                "PRIMARY KEY (col1)"
  =.  run  +(run)
  =^  mov3  agent
    %+  ~(on-poke agent (bowl [run ~2012.5.2]))
        %obelisk-action
        !>  :+  %tape2
                %db1
                "INSERT INTO db1..my-table (col1, col2, col3) ".
                "VALUES ('cord',~nomryg-nilref,20) ('Default',Default, 0) "
  =.  run  +(run)
  =^  mov4  agent
    %+  ~(on-poke agent (bowl [run ~2012.5.2]))
        %obelisk-action
        !>  :+  %tape2
                %db1
                "INSERT INTO db1..my-table AS OF ~2012.5.1 (col1, col2, col3) ".
                "VALUES ('cord2',~nomryg-nilref,20) ('Default2',Default, 0) "
  =^  mov5  agent
    %+  ~(on-poke agent (bowl [run ~2012.5.3]))
        %obelisk-action
        !>  :+  %tape2
                %db1
                "FROM my-table ".
                "SELECT *"
  ::
  (eval-results expected ;;(cmd-result ->+>+>+<.mov5))
::
:: create table, then insert AS OF
++  test-insert-18
  =|  run=@ud
  =/  expected  :-  %results
                    :~  [%message 'INSERT INTO db1.dbo.my-table']
                        [%server-time ~2012.5.2]
                        [%schema-time ~2012.5.1]
                        [%data-time ~2012.5.1]
                        [%message 'inserted:']
                        [%vector-count 2]
                        [%message 'table data:']
                        [%vector-count 2]
                    ==
  ::
  =^  mov1  agent
    %+  ~(on-poke agent (bowl [run ~2012.4.30]))
        %obelisk-action
        !>([%tape2 %sys "CREATE DATABASE db1"])
  =.  run  +(run)
  =^  mov2  agent
    %+  ~(on-poke agent (bowl [run ~2012.5.1]))
        %obelisk-action
        !>  :+  %tape2
                %db1
                "CREATE TABLE db1..my-table ".
                "(col1 @t, col2 @p, col3 @ud) ".
                "PRIMARY KEY (col1)"
  =.  run  +(run)
  =^  mov3  agent
    %+  ~(on-poke agent (bowl [run ~2012.5.2]))
        %obelisk-action
        !>  :+  %tape2
                %db1
                "INSERT INTO db1..my-table AS OF ~2012.5.1 ".
                 "(col1, col2, col3) ".
                 "VALUES ('cord',~nomryg-nilref,20) ('Default',Default, 0) "
  ::
  %+  expect-eq
    !>  expected
    !>  ;;(cmd-result ->+>+>+<.mov3)
::
:: INSERT error messages
::
:: insert rows without columns, fail on col wrong type
++  test-fail-insert-01
  =|  run=@ud
  =/  my-insert
        "INSERT INTO db1..my-table VALUES ('cord2',~nec,21) ('cord2',1, ~bus)"
  ::
  =^  mov1  agent
    %+  ~(on-poke agent (bowl [run ~2012.4.30]))
        %obelisk-action
        !>([%tape2 %sys "CREATE DATABASE db1"])
  =.  run  +(run)
  =^  mov2  agent
    %+  ~(on-poke agent (bowl [run ~2012.5.1]))
        %obelisk-action
        !>  :+  %tape2
                %db1
                "CREATE TABLE db1..my-table ".
                "(col1 @t, col2 @p, col3 @ud) ".
                "PRIMARY KEY (col1)"
  =.  run  +(run)
  ::
  %+  expect-fail-message
    %-  crip  
        "INSERT: type of column %column name=%col2 ".
        "does not match input value type ~.ud"
  |.  %+  ~(on-poke agent (bowl [run ~2012.5.5]))
          %obelisk-action
          !>([%test %db1 my-insert])
::
:: fail on dup rows
++  test-fail-insert-02
  =|  run=@ud
  =/  my-insert  "INSERT INTO db1..my-table (col1, col2, col3)  ".
                 "VALUES ('cord',~nomryg-nilref,20) ('Default',Default, 0)"
  ::
  =^  mov1  agent
    %+  ~(on-poke agent (bowl [run ~2012.4.30]))
        %obelisk-action
        !>([%tape2 %sys "CREATE DATABASE db1"])
  =.  run  +(run)
  =^  mov2  agent
    %+  ~(on-poke agent (bowl [run ~2012.5.1]))
        %obelisk-action
        !>  :+  %tape2
                %db1
                "CREATE TABLE db1..my-table ".
                "(col1 @t, col2 @p, col3 @ud) ".
                "PRIMARY KEY (col1)"
  =.  run  +(run)
  =^  mov3  agent
    %+  ~(on-poke agent (bowl [run ~2012.5.2]))
        %obelisk-action
        !>([%tape2 %db1 my-insert])
  =.  run  +(run)
  ::
  %+  expect-fail-message
        'INSERT: cannot add duplicate key: ~[1.685.221.219]'
  |.  %+  ~(on-poke agent (bowl [run ~2012.5.5]))
          %obelisk-action
          !>([%test %db1 my-insert])
::
:: fail on dup col names
++  test-fail-insert-03
  =|  run=@ud
  =/  my-insert  "INSERT INTO db1..my-table (col1, col2, col2)  ".
                 "VALUES ('cord',20,20) ('Default',Default, 0)"
  ::
  =^  mov1  agent
    %+  ~(on-poke agent (bowl [run ~2012.4.30]))
        %obelisk-action
        !>([%tape2 %sys "CREATE DATABASE db1"])
  =.  run  +(run)
  =^  mov2  agent
    %+  ~(on-poke agent (bowl [run ~2012.5.1]))
        %obelisk-action
        !>  :+  %tape2
                %db1
                "CREATE TABLE db1..my-table ".
                "(col1 @t, col2 @ud, col3 @ud) ".
                "PRIMARY KEY (col1)"
  =.  run  +(run)
  ::
  %+  expect-fail-message
        'INSERT: incorrect columns specified: [~ u=~[%col1 %col2 %col2]]'
  |.  %+  ~(on-poke agent (bowl [run ~2012.5.5]))
          %obelisk-action
          !>([%test %db1 my-insert])
::
:: fail on too few cols
++  test-fail-insert-04
  =|  run=@ud
  =/  my-insert  "INSERT INTO db1..my-table (col1, col2)  ".
                 "VALUES ('cord',~nomryg-nilref,20) ('Default',Default, 0)"
  ::
  =^  mov1  agent
    %+  ~(on-poke agent (bowl [run ~2012.4.30]))
        %obelisk-action
        !>([%tape2 %sys "CREATE DATABASE db1"])
  =.  run  +(run)
  =^  mov2  agent
    %+  ~(on-poke agent (bowl [run ~2012.5.1]))
        %obelisk-action
        !>  :+  %tape2
                %db1
                "CREATE TABLE db1..my-table ".
                "(col1 @t, col2 @p, col3 @ud) ".
                "PRIMARY KEY (col1)"
  =.  run  +(run)
  ::
  %+  expect-fail-message
        'INSERT: incorrect columns specified: [~ u=~[%col1 %col2]]'
  |.  %+  ~(on-poke agent (bowl [run ~2012.5.5]))
          %obelisk-action
          !>([%test %db1 my-insert])
::
:: fail on too many cols
++  test-fail-insert-05
  =|  run=@ud
  =/  my-insert  "INSERT INTO db1..my-table (col1, col2, col3, col4) ".
                 "VALUES ('cord',~nomryg-nilref,20) ('Default',Default, 0)"
  ::
  =^  mov1  agent
    %+  ~(on-poke agent (bowl [run ~2012.4.30]))
        %obelisk-action
        !>([%tape2 %sys "CREATE DATABASE db1"])
  =.  run  +(run)
  =^  mov2  agent
    %+  ~(on-poke agent (bowl [run ~2012.5.1]))
        %obelisk-action
        !>  :+  %tape2
                %db1
                "CREATE TABLE db1..my-table ".
                "(col1 @t, col2 @p, col3 @ud) ".
                "PRIMARY KEY (col1)"
  =.  run  +(run)
  ::
  %+  expect-fail-message
        'INSERT: incorrect columns specified: [~ u=~[%col1 %col2 %col3 %col4]]'
  |.  %+  ~(on-poke agent (bowl [run ~2012.5.5]))
          %obelisk-action
          !>([%test %db1 my-insert])
::
:: insert rows with columns specified, fail on col wrong type
++  test-fail-insert-06
  =|  run=@ud
  =/  my-insert  "INSERT INTO db1..my-table (col1, col2, col3) ".
                 "VALUES ('cord',40,20) ('Default',Default, 0)"
  ::
  =^  mov1  agent
    %+  ~(on-poke agent (bowl [run ~2012.4.30]))
        %obelisk-action
        !>([%tape2 %sys "CREATE DATABASE db1"])
  =.  run  +(run)
  =^  mov2  agent
    %+  ~(on-poke agent (bowl [run ~2012.5.1]))
        %obelisk-action
        !>  :+  %tape2
                %db1
                "CREATE TABLE db1..my-table ".
                "(col1 @t, col2 @p, col3 @ud) ".
                "PRIMARY KEY (col1)"
  =.  run  +(run)
  ::
  %+  expect-fail-message
    %-  crip  
        "INSERT: type of column %column name=%col2 ".
        "does not match input value type ~.ud"
  |.  %+  ~(on-poke agent (bowl [run ~2012.5.5]))
          %obelisk-action
          !>([%test %db1 my-insert])
::
:: fail on bad column name
++  test-fail-insert-07
  =|  run=@ud
  =/  my-insert  "INSERT INTO db1..my-table (col1a, col2, col3) ".
                 "VALUES ('cord',~nomryg-nilref,20) ('Default',Default, 0)"
  ::
  =^  mov1  agent
    %+  ~(on-poke agent (bowl [run ~2012.4.30]))
        %obelisk-action
        !>([%tape2 %sys "CREATE DATABASE db1"])
  =.  run  +(run)
  =^  mov2  agent
    %+  ~(on-poke agent (bowl [run ~2012.5.1]))
        %obelisk-action
        !>  :+  %tape2
                %db1
                "CREATE TABLE db1..my-table ".
                "(col1 @t, col2 @p, col3 @ud) ".
                "PRIMARY KEY (col1)"
  =.  run  +(run)
  ::
  %+  expect-fail-message
        'INSERT: invalid column: \'col1a\''
  |.  %+  ~(on-poke agent (bowl [run ~2012.5.5]))
          %obelisk-action
          !>([%test %db1 my-insert])
::
:: fail on bad table name
++  test-fail-insert-08
  =|  run=@ud
  =/  my-insert  "INSERT INTO db1..my-table-2 (col1, col2, col3) ".
                 "VALUES ('cord',~nomryg-nilref,20) ('Default',Default, 0)"
  ::
  =^  mov1  agent
    %+  ~(on-poke agent (bowl [run ~2012.4.30]))
        %obelisk-action
        !>([%tape2 %sys "CREATE DATABASE db1"])
  =.  run  +(run)
  =^  mov2  agent
    %+  ~(on-poke agent (bowl [run ~2012.5.1]))
        %obelisk-action
        !>  :+  %tape2
                %db1
                "CREATE TABLE db1..my-table ".
                "(col1 @t, col2 @p, col3 @ud) ".
                "PRIMARY KEY (col1)"
  =.  run  +(run)
  ::
  %+  expect-fail-message
        'INSERT: table [%dbo %my-table-2] does not exist'
  |.  %+  ~(on-poke agent (bowl [run ~2012.5.5]))
          %obelisk-action
          !>([%test %db1 my-insert])
::
:: fail on bad namespace name
++  test-fail-insert-09
  =|  run=@ud
  =/  my-insert  "INSERT INTO db1.ns1.my-table (col1, col2, col3) ".
                 "VALUES ('cord',~nomryg-nilref,20) ('Default',Default, 0)"
  ::
  =^  mov1  agent
    %+  ~(on-poke agent (bowl [run ~2012.4.30]))
        %obelisk-action
        !>([%tape2 %sys "CREATE DATABASE db1"])
  =.  run  +(run)
  =^  mov2  agent
    %+  ~(on-poke agent (bowl [run ~2012.5.1]))
        %obelisk-action
        !>  :+  %tape2
                %db1
                "CREATE TABLE db1..my-table ".
                "(col1 @t, col2 @p, col3 @ud) ".
                "PRIMARY KEY (col1)"
  =.  run  +(run)
  ::
  %+  expect-fail-message
        'INSERT: table [%ns1 %my-table] does not exist'
  |.  %+  ~(on-poke agent (bowl [run ~2012.5.5]))
          %obelisk-action
          !>([%test %db1 my-insert])

::
::  fail on changing state after select in script
++  test-fail-insert-10
  =|  run=@ud
  =^  mov1  agent
    %+  ~(on-poke agent (bowl [run ~2000.1.1]))
        %obelisk-action
        !>([%tape2 %sys "CREATE DATABASE db1"])
  =.  run  +(run)
  ::
  %+  expect-fail-message
        'INSERT: state change after query in script'
  |.  %+  ~(on-poke agent (bowl [run ~2000.1.2]))
          %obelisk-action
          !>  :+  %test
                  %db1
                  "CREATE TABLE db1..my-table (col1 @t) PRIMARY KEY (col1); ".
                  "SELECT 0;".
                  "INSERT INTO db1..my-table (col1) VALUES ('cord') "
::
::  fail on database does not exist
++  test-fail-insert-11
  =|  run=@ud
  =^  mov1  agent
    %+  ~(on-poke agent (bowl [run ~2000.1.1]))
        %obelisk-action
        !>([%tape2 %sys "CREATE DATABASE db1"])
  =.  run  +(run)
  ::
  %+  expect-fail-message
        'INSERT: database %db does not exist'
  |.  %+  ~(on-poke agent (bowl [run ~2000.1.2]))
          %obelisk-action
          !>  :+  %test
                  %db1
                  "CREATE TABLE db1..my-table (col1 @t) PRIMARY KEY (col1); ".
                  "INSERT INTO db..my-table (col1) VALUES ('cord') "
::
::  fail on incorrect columns when columns not specified
++  test-fail-insert-12
  =|  run=@ud
  =/  expected  :-  %results
                    :~  [%message 'INSERT INTO db1.dbo.my-table']
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
    %+  ~(on-poke agent (bowl [run ~2000.1.1]))
        %obelisk-action
        !>([%tape2 %sys "CREATE DATABASE db1 AS OF ~2000.1.1"])
  =.  run  +(run)
  =^  mov3  agent
    %+  ~(on-poke agent (bowl [run ~2000.1.2]))
        %obelisk-action
        !>  :+  %tape2
                %db1
                "CREATE TABLE db1..my-table ".
                "(col1 @t, col2 @da) PRIMARY KEY (col1) ;"
  =.  run  +(run)
  =^  mov4  agent
    %+  ~(on-poke agent (bowl [run ~2000.1.3]))
        %obelisk-action
        !>  :+  %tape2
                %db1
                "INSERT INTO db1..my-table (col1, col2) ".
                "VALUES".
                "  ('today', ~2024.9.26)".
                "  ('tomorrow', ~2024.9.27)".
                "  ('next day', ~2024.9.28); "
  =.  run  +(run)
  =^  mov5  agent
    %+  ~(on-poke agent (bowl [run ~2000.1.4..15.01.01]))
        %obelisk-action
        !>  :+  %tape2
                %db1
                "TRUNCATE TABLE my-table;  "
  ::
  ::
  %+  expect-fail-message
        'INSERT: incorrect columns specified: '
  |.  %+  ~(on-poke agent (bowl [run ~2012.5.5]))
          %obelisk-action
          !>  :+  %test
                %db1
                "INSERT INTO db1..my-table VALUES ('cord2') ('cord3') "
::
::  cannot insert data in the future, insert time = schema time
++  test-fail-insert-13
  =|  run=@ud
  =/  expected  :-  %results
                    :~  [%message 'INSERT INTO db1.dbo.my-table']
                        [%server-time ~2012.5.2]
                        [%schema-time ~2023.7.9..22.35.35..7e90]
                        [%data-time ~2023.7.9..22.35.35..7e90]
                        [%message 'inserted:']
                        [%vector-count 1]
                        [%message 'table data:']
                        [%vector-count 1]
                    ==
  =^  mov1  agent
    %+  ~(on-poke agent (bowl [run ~2000.1.1]))
        %obelisk-action
        !>([%tape2 %sys "CREATE DATABASE db1"])
  =.  run  +(run)
  =^  mov2  agent
    %+  ~(on-poke agent (bowl [run ~2000.1.2]))
        %obelisk-action
        !>  :+  %tape2
                %db1
                "CREATE TABLE db1..my-table ".
                "(col1 @t) PRIMARY KEY (col1) AS OF ~2023.7.9..22.35.35..7e90 "
  =.  run  +(run)
  =^  mov3  agent
    %+  ~(on-poke agent (bowl [run ~2000.1.3]))
        %obelisk-action
        !>([%tape2 %db1 "CREATE NAMESPACE ns1 as of ~2023.7.9..22.35.36..7e90"])
  =.  run  +(run)
  ::
  %+  expect-fail-message
        'INSERT: table %my-table as-of schema time out of order'
  |.  %+  ~(on-poke agent (bowl [run ~2012.5.2]))
          %obelisk-action
          !>  :+  %test
                  %db1
                  "INSERT INTO db1..my-table AS OF ~2023.7.9..22.35.36..7e90".
                " (col1) VALUES ('cord') "
::
::  cannot insert data in the future,  insert < schema
++  test-fail-insert-14
  =|  run=@ud
  =^  mov1  agent
    %+  ~(on-poke agent (bowl [run ~2000.1.1]))
        %obelisk-action
        !>([%tape2 %sys "CREATE DATABASE db1"])
  =.  run  +(run)
  =^  mov2  agent
    %+  ~(on-poke agent (bowl [run ~2000.1.2]))
        %obelisk-action
        !>  :+  %tape2
                %db1
                "CREATE TABLE db1..my-table ".
                "(col1 @t) PRIMARY KEY (col1) AS OF ~2023.7.9..22.35.34..7e90 "
  =.  run  +(run)
  =^  mov3  agent
    %+  ~(on-poke agent (bowl [run ~2000.1.3]))
        %obelisk-action
        !>([%tape2 %db1 "CREATE NAMESPACE ns1 as of ~2023.7.9..22.35.36..7e90"])
  =.  run  +(run)
  ::
  %+  expect-fail-message
        'INSERT: table %my-table as-of schema time out of order'
  |.  %+  ~(on-poke agent (bowl [run ~2000.1.4]))
          %obelisk-action
          !>  :+  %test
                  %db1
                  "INSERT INTO db1..my-table AS OF ~2023.7.9..22.35.35..7e90 ".
                  "(col1) VALUES ('cord') "
--