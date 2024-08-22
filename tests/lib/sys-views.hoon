::  Demonstrate unit testing on a Gall agent with %obelisk.
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
      =databases
      ==
--
|%
::
::  sys.sys.databases
::
::  Test Cases: series ending in each of effective commands
::
++  test-sys-sys-databases-01  ::  CREATE TABLE
  =|  run=@ud
  =/  expected-rows
        :~
          :-  %vector
              :~  [%database [~.tas %db1]]
                  [%sys-agent [~.tas '/test-agent']]
                  [%sys-tmsp [~.da ~2000.1.1]]
                  [%data-ship [~.p 0]]
                  [%data-agent [~.tas '/test-agent']]
                  [%data-tmsp [~.da ~2000.1.1]]
                  ==
          :-  %vector
              :~  [%database [~.tas %db1]]
                  [%sys-agent [~.tas '/test-agent']]
                  [%sys-tmsp [~.da ~2000.1.2]]
                  [%data-ship [~.p 0]]
                  [%data-agent [~.tas '/test-agent']]
                  [%data-tmsp [~.da ~2000.1.2]]
                  ==
          :-  %vector
              :~  [%database [~.tas %db1]]
                  [%sys-agent [~.tas '/test-agent']]
                  [%sys-tmsp [~.da ~2000.1.2]]
                  [%data-ship [~.p 0]]
                  [%data-agent [~.tas '/test-agent']]
                  [%data-tmsp [~.da ~2000.1.3]]
                  ==
          :-  %vector
              :~  [%database [~.tas %db2]]
                  [%sys-agent [~.tas '/test-agent']]
                  [%sys-tmsp [~.da ~2000.1.4]]
                  [%data-ship [~.p 0]]
                  [%data-agent [~.tas '/test-agent']]
                  [%data-tmsp [~.da ~2000.1.4]]
                  ==
          :-  %vector
              :~  [%database [~.tas %db2]]
                  [%sys-agent [~.tas '/test-agent']]
                  [%sys-tmsp [~.da ~2000.1.5]]
                  [%data-ship [~.p 0]]
                  [%data-agent [~.tas '/test-agent']]
                  [%data-tmsp [~.da ~2000.1.5]]
                  ==
          :-  %vector
              :~  [%database [~.tas %sys]]
                  [%sys-agent [~.tas '/test-agent']]
                  [%sys-tmsp [~.da ~2000.1.1]]
                  [%data-ship [~.p 0]]
                  [%data-agent [~.tas '/test-agent']]
                  [%data-tmsp [~.da ~2000.1.1]]
                  ==
          ==
  ::
  =/  expected  :-  %results
                      :~  [%message 'SELECT']
                          [%result-set expected-rows]
                          [%server-time ~2000.1.5]
                          [%schema-time ~2000.1.1]
                          [%data-time ~2000.1.5]
                          [%vector-count 6]
                      ==
  =^  mov1  agent
    %:  ~(on-poke agent (bowl [run ~2000.1.1]))
        %obelisk-action
        !>([%tape-create-db "CREATE DATABASE db1"])
    ==
  =.  run  +(run)
  =^  mov2  agent
    %:  ~(on-poke agent (bowl [run ~2000.1.2]))
        %obelisk-action
        !>  :+  %tape
                %db1
                "CREATE TABLE db1..my-table (col1 @t) PRIMARY KEY (col1)"
    ==
  =.  run  +(run)
  =^  mov3  agent
    %:  ~(on-poke agent (bowl [run ~2000.1.3]))
        %obelisk-action
        !>([%tape %db1 "INSERT INTO db1..my-table (col1) VALUES ('cord')"])
    ==
  =.  run  +(run)
  =^  mov4  agent
    %:  ~(on-poke agent (bowl [run ~2000.1.4]))
        %obelisk-action
        !>([%tape-create-db "CREATE DATABASE db2"])
    ==
  =.  run  +(run)
  =^  mov5  agent
    %:  ~(on-poke agent (bowl [run ~2000.1.5]))
        %obelisk-action
        !>  :+  %tape
                %db1
                "CREATE TABLE db2..my-table (col1 @t) PRIMARY KEY (col1)"
    ==
  =.  run  +(run)
  =^  mov6  agent
    %:  ~(on-poke agent (bowl [run ~2000.1.5]))
        %obelisk-action
        !>([%tape %db1 "FROM sys.sys.databases SELECT *"])
    ==
  %+  expect-eq
    !>  expected
    !>  ->+>+>-.mov6
::
++  test-sys-sys-databases-02  ::  DROP TABLE
  =|  run=@ud
  =/  expected-rows
        :~
          :-  %vector
              :~  [%database [~.tas %db1]]
                  [%sys-agent [~.tas '/test-agent']]
                  [%sys-tmsp [~.da ~2000.1.1]]
                  [%data-ship [~.p 0]]
                  [%data-agent [~.tas '/test-agent']]
                  [%data-tmsp [~.da ~2000.1.1]]
                  ==
          :-  %vector
              :~  [%database [~.tas %db1]]
                  [%sys-agent [~.tas '/test-agent']]
                  [%sys-tmsp [~.da ~2000.1.2]]
                  [%data-ship [~.p 0]]
                  [%data-agent [~.tas '/test-agent']]
                  [%data-tmsp [~.da ~2000.1.2]]
                  ==
          :-  %vector
              :~  [%database [~.tas %db1]]
                  [%sys-agent [~.tas '/test-agent']]
                  [%sys-tmsp [~.da ~2000.1.2]]
                  [%data-ship [~.p 0]]
                  [%data-agent [~.tas '/test-agent']]
                  [%data-tmsp [~.da ~2000.1.3]]
                  ==
          :-  %vector
              :~  [%database [~.tas %db1]]
                  [%sys-agent [~.tas '/test-agent']]
                  [%sys-tmsp [~.da ~2000.1.6]]
                  [%data-ship [~.p 0]]
                  [%data-agent [~.tas '/test-agent']]
                  [%data-tmsp [~.da ~2000.1.6]]
                  ==
          :-  %vector
              :~  [%database [~.tas %db2]]
                  [%sys-agent [~.tas '/test-agent']]
                  [%sys-tmsp [~.da ~2000.1.4]]
                  [%data-ship [~.p 0]]
                  [%data-agent [~.tas '/test-agent']]
                  [%data-tmsp [~.da ~2000.1.4]]
                  ==
          :-  %vector
              :~  [%database [~.tas %db2]]
                  [%sys-agent [~.tas '/test-agent']]
                  [%sys-tmsp [~.da ~2000.1.5]]
                  [%data-ship [~.p 0]]
                  [%data-agent [~.tas '/test-agent']]
                  [%data-tmsp [~.da ~2000.1.5]]
                  ==
          :-  %vector
              :~  [%database [~.tas %sys]]
                  [%sys-agent [~.tas '/test-agent']]
                  [%sys-tmsp [~.da ~2000.1.1]]
                  [%data-ship [~.p 0]]
                  [%data-agent [~.tas '/test-agent']]
                  [%data-tmsp [~.da ~2000.1.1]]
                  ==
          ==
  ::
  =/  expected  :-  %results
                      :~  [%message 'SELECT']
                          [%result-set expected-rows]
                          [%server-time ~2000.1.7]
                          [%schema-time ~2000.1.1]
                          [%data-time ~2000.1.6]
                          [%vector-count 7]
                      ==
  =^  mov1  agent
    %:  ~(on-poke agent (bowl [run ~2000.1.1]))
        %obelisk-action
        !>([%tape-create-db "CREATE DATABASE db1"])
    ==
  =.  run  +(run)
  =^  mov2  agent
    %:  ~(on-poke agent (bowl [run ~2000.1.2]))
        %obelisk-action
        !>  :+  %tape
                %db1
                "CREATE TABLE db1..my-table (col1 @t) PRIMARY KEY (col1)"
    ==
  =.  run  +(run)
  =^  mov3  agent
    %:  ~(on-poke agent (bowl [run ~2000.1.3]))
        %obelisk-action
        !>([%tape %db1 "INSERT INTO db1..my-table (col1) VALUES ('cord')"])
    ==
  =.  run  +(run)
  =^  mov4  agent
    %:  ~(on-poke agent (bowl [run ~2000.1.4]))
        %obelisk-action
        !>([%tape-create-db "CREATE DATABASE db2"])
    ==
  =.  run  +(run)
  =^  mov5  agent
    %:  ~(on-poke agent (bowl [run ~2000.1.5]))
        %obelisk-action
        !>  :+  %tape
                %db1
                "CREATE TABLE db2..my-table (col1 @t) PRIMARY KEY (col1)"
    ==
  =.  run  +(run)
  =^  mov6  agent
    %:  ~(on-poke agent (bowl [run ~2000.1.6]))
        %obelisk-action
        !>([%tape %db1 "DROP TABLE FORCE db1..my-table"])
    ==
  =.  run  +(run)
  =^  mov7  agent
    %:  ~(on-poke agent (bowl [run ~2000.1.7]))
        %obelisk-action
        !>([%tape %db1 "FROM sys.sys.databases SELECT *"])
    ==
  %+  expect-eq
    !>  expected
    !>  ->+>+>-.mov7
::
++  test-sys-sys-databases-03  ::  TRUNCATE TABLE (data present)
  =|  run=@ud
  =/  expected-rows
        :~
          :-  %vector
              :~  [%database [~.tas %db1]]
                  [%sys-agent [~.tas '/test-agent']]
                  [%sys-tmsp [~.da ~2000.1.1]]
                  [%data-ship [~.p 0]]
                  [%data-agent [~.tas '/test-agent']]
                  [%data-tmsp [~.da ~2000.1.1]]
                  ==
          :-  %vector
              :~  [%database [~.tas %db1]]
                  [%sys-agent [~.tas '/test-agent']]
                  [%sys-tmsp [~.da ~2000.1.2]]
                  [%data-ship [~.p 0]]
                  [%data-agent [~.tas '/test-agent']]
                  [%data-tmsp [~.da ~2000.1.2]]
                  ==
          :-  %vector
              :~  [%database [~.tas %db1]]
                  [%sys-agent [~.tas '/test-agent']]
                  [%sys-tmsp [~.da ~2000.1.2]]
                  [%data-ship [~.p 0]]
                  [%data-agent [~.tas '/test-agent']]
                  [%data-tmsp [~.da ~2000.1.3]]
                  ==
          :-  %vector
              :~  [%database [~.tas %db1]]
                  [%sys-agent [~.tas '/test-agent']]
                  [%sys-tmsp [~.da ~2000.1.2]]
                  [%data-ship [~.p 0]]
                  [%data-agent [~.tas '/test-agent']]
                  [%data-tmsp [~.da ~2000.1.6]]
                  ==
          :-  %vector
              :~  [%database [~.tas %db2]]
                  [%sys-agent [~.tas '/test-agent']]
                  [%sys-tmsp [~.da ~2000.1.4]]
                  [%data-ship [~.p 0]]
                  [%data-agent [~.tas '/test-agent']]
                  [%data-tmsp [~.da ~2000.1.4]]
                  ==
          :-  %vector
              :~  [%database [~.tas %db2]]
                  [%sys-agent [~.tas '/test-agent']]
                  [%sys-tmsp [~.da ~2000.1.5]]
                  [%data-ship [~.p 0]]
                  [%data-agent [~.tas '/test-agent']]
                  [%data-tmsp [~.da ~2000.1.5]]
                  ==
          :-  %vector
              :~  [%database [~.tas %sys]]
                  [%sys-agent [~.tas '/test-agent']]
                  [%sys-tmsp [~.da ~2000.1.1]]
                  [%data-ship [~.p 0]]
                  [%data-agent [~.tas '/test-agent']]
                  [%data-tmsp [~.da ~2000.1.1]]
                  ==
          ==
  ::
  =/  expected  :-  %results
                      :~  [%message 'SELECT']
                          [%result-set expected-rows]
                          [%server-time ~2000.1.7]
                          [%schema-time ~2000.1.1]
                          [%data-time ~2000.1.6]
                          [%vector-count 7]
                      ==
  =^  mov1  agent
    %:  ~(on-poke agent (bowl [run ~2000.1.1]))
        %obelisk-action
        !>([%tape-create-db "CREATE DATABASE db1"])
    ==
  =.  run  +(run)
  =^  mov2  agent
    %:  ~(on-poke agent (bowl [run ~2000.1.2]))
        %obelisk-action
        !>  :+  %tape
                %db1
                "CREATE TABLE db1..my-table (col1 @t) PRIMARY KEY (col1)"
    ==
  =.  run  +(run)
  =^  mov3  agent
    %:  ~(on-poke agent (bowl [run ~2000.1.3]))
        %obelisk-action
        !>([%tape %db1 "INSERT INTO db1..my-table (col1) VALUES ('cord')"])
    ==
  =.  run  +(run)
  =^  mov4  agent
    %:  ~(on-poke agent (bowl [run ~2000.1.4]))
        %obelisk-action
        !>([%tape-create-db "CREATE DATABASE db2"])
    ==
  =.  run  +(run)
  =^  mov5  agent
    %:  ~(on-poke agent (bowl [run ~2000.1.5]))
        %obelisk-action
        !>  :+  %tape
                %db1
                "CREATE TABLE db2..my-table (col1 @t) PRIMARY KEY (col1)"
    ==
  =.  run  +(run)
  =^  mov6  agent
    %:  ~(on-poke agent (bowl [run ~2000.1.6]))
        %obelisk-action
        !>([%tape %db1 "TRUNCATE TABLE db1..my-table"])
    ==
  =.  run  +(run)
  =^  mov7  agent
    %:  ~(on-poke agent (bowl [run ~2000.1.7]))
        %obelisk-action
        !>([%tape %db1 "FROM sys.sys.databases SELECT *"])
    ==
  %+  expect-eq
    !>  expected
    !>  ->+>+>-.mov7
::
++  test-sys-sys-databases-04  ::  TRUNCATE TABLE (no data present)
  =|  run=@ud
  =/  expected-rows
        :~
          :-  %vector
              :~  [%database [~.tas %db1]]
                  [%sys-agent [~.tas '/test-agent']]
                  [%sys-tmsp [~.da ~2000.1.1]]
                  [%data-ship [~.p 0]]
                  [%data-agent [~.tas '/test-agent']]
                  [%data-tmsp [~.da ~2000.1.1]]
                  ==
          :-  %vector
              :~  [%database [~.tas %db1]]
                  [%sys-agent [~.tas '/test-agent']]
                  [%sys-tmsp [~.da ~2000.1.2]]
                  [%data-ship [~.p 0]]
                  [%data-agent [~.tas '/test-agent']]
                  [%data-tmsp [~.da ~2000.1.2]]
                  ==
          :-  %vector
              :~  [%database [~.tas %db1]]
                  [%sys-agent [~.tas '/test-agent']]
                  [%sys-tmsp [~.da ~2000.1.2]]
                  [%data-ship [~.p 0]]
                  [%data-agent [~.tas '/test-agent']]
                  [%data-tmsp [~.da ~2000.1.3]]
                  ==
          :-  %vector
              :~  [%database [~.tas %db2]]
                  [%sys-agent [~.tas '/test-agent']]
                  [%sys-tmsp [~.da ~2000.1.4]]
                  [%data-ship [~.p 0]]
                  [%data-agent [~.tas '/test-agent']]
                  [%data-tmsp [~.da ~2000.1.4]]
                  ==
          :-  %vector
              :~  [%database [~.tas %db2]]
                  [%sys-agent [~.tas '/test-agent']]
                  [%sys-tmsp [~.da ~2000.1.5]]
                  [%data-ship [~.p 0]]
                  [%data-agent [~.tas '/test-agent']]
                  [%data-tmsp [~.da ~2000.1.5]]
                  ==
          :-  %vector
              :~  [%database [~.tas %sys]]
                  [%sys-agent [~.tas '/test-agent']]
                  [%sys-tmsp [~.da ~2000.1.1]]
                  [%data-ship [~.p 0]]
                  [%data-agent [~.tas '/test-agent']]
                  [%data-tmsp [~.da ~2000.1.1]]
                  ==
          ==
  ::
  =/  expected  :-  %results
                      :~  [%message 'SELECT']
                          [%result-set expected-rows]
                          [%server-time ~2000.1.7]
                          [%schema-time ~2000.1.1]
                          [%data-time ~2000.1.5]
                          [%vector-count 6]
                      ==
  =^  mov1  agent
    %:  ~(on-poke agent (bowl [run ~2000.1.1]))
        %obelisk-action
        !>([%tape-create-db "CREATE DATABASE db1"])
    ==
  =.  run  +(run)
  =^  mov2  agent
    %:  ~(on-poke agent (bowl [run ~2000.1.2]))
        %obelisk-action
        !>  :+  %tape
                %db1
                "CREATE TABLE db1..my-table (col1 @t) PRIMARY KEY (col1)"
    ==
  =.  run  +(run)
  =^  mov3  agent
    %:  ~(on-poke agent (bowl [run ~2000.1.3]))
        %obelisk-action
        !>([%tape %db1 "INSERT INTO db1..my-table (col1) VALUES ('cord')"])
    ==
  =.  run  +(run)
  =^  mov4  agent
    %:  ~(on-poke agent (bowl [run ~2000.1.4]))
        %obelisk-action
        !>([%tape-create-db "CREATE DATABASE db2"])
    ==
  =.  run  +(run)
  =^  mov5  agent
    %:  ~(on-poke agent (bowl [run ~2000.1.5]))
        %obelisk-action
        !>  :+  %tape
                %db1
                "CREATE TABLE db2..my-table (col1 @t) PRIMARY KEY (col1)"
    ==
  =.  run  +(run)
  =^  mov6  agent
    %:  ~(on-poke agent (bowl [run ~2000.1.6]))
        %obelisk-action
        !>([%tape %db1 "TRUNCATE TABLE db2..my-table"])
    ==
  =.  run  +(run)
  =^  mov7  agent
    %:  ~(on-poke agent (bowl [run ~2000.1.7]))
        %obelisk-action
        !>([%tape %db1 "FROM sys.sys.databases SELECT *"])
    ==
  %+  expect-eq
    !>  expected
    !>  ->+>+>-.mov7
::
++  test-sys-sys-databases-05  ::  INSERT
  =|  run=@ud
  =/  expected-rows
        :~
          :-  %vector
              :~  [%database [~.tas %db1]]
                  [%sys-agent [~.tas '/test-agent']]
                  [%sys-tmsp [~.da ~2000.1.1]]
                  [%data-ship [~.p 0]]
                  [%data-agent [~.tas '/test-agent']]
                  [%data-tmsp [~.da ~2000.1.1]]
                  ==
          :-  %vector
              :~  [%database [~.tas %db1]]
                  [%sys-agent [~.tas '/test-agent']]
                  [%sys-tmsp [~.da ~2000.1.2]]
                  [%data-ship [~.p 0]]
                  [%data-agent [~.tas '/test-agent']]
                  [%data-tmsp [~.da ~2000.1.2]]
                  ==
          :-  %vector
              :~  [%database [~.tas %db1]]
                  [%sys-agent [~.tas '/test-agent']]
                  [%sys-tmsp [~.da ~2000.1.2]]
                  [%data-ship [~.p 0]]
                  [%data-agent [~.tas '/test-agent']]
                  [%data-tmsp [~.da ~2000.1.3]]
                  ==
          :-  %vector
              :~  [%database [~.tas %sys]]
                  [%sys-agent [~.tas '/test-agent']]
                  [%sys-tmsp [~.da ~2000.1.1]]
                  [%data-ship [~.p 0]]
                  [%data-agent [~.tas '/test-agent']]
                  [%data-tmsp [~.da ~2000.1.1]]
                  ==
          ==
  ::
  =/  expected  :-  %results
                      :~  [%message 'SELECT']
                          [%result-set expected-rows]
                          [%server-time ~2000.1.7]
                          [%schema-time ~2000.1.1]
                          [%data-time ~2000.1.3]
                          [%vector-count 4]
                      ==
  =^  mov1  agent
    %:  ~(on-poke agent (bowl [run ~2000.1.1]))
        %obelisk-action
        !>([%tape-create-db "CREATE DATABASE db1"])
    ==
  =.  run  +(run)
  =^  mov2  agent
    %:  ~(on-poke agent (bowl [run ~2000.1.2]))
        %obelisk-action
        !>  :+  %tape
                %db1
                "CREATE TABLE db1..my-table (col1 @t) PRIMARY KEY (col1)"
    ==
  =.  run  +(run)
  =^  mov3  agent
    %:  ~(on-poke agent (bowl [run ~2000.1.3]))
        %obelisk-action
        !>([%tape %db1 "INSERT INTO db1..my-table (col1) VALUES ('cord')"])
    ==
  =.  run  +(run)
  =^  mov4  agent
    %:  ~(on-poke agent (bowl [run ~2000.1.7]))
        %obelisk-action
        !>([%tape %db1 "FROM sys.sys.databases SELECT *"])
    ==
  %+  expect-eq
    !>  expected
    !>  ->+>+>-.mov4
::
::  sys.namespaces
::
::  Test Cases: CREATE or DROP NAMESPACE
::
++  test-sys-namspaces-01
  =|  run=@ud
  =/  row1  :-  %vector
                :~  [%namespace [~.tas %dbo]]
                    [%tmsp [~.da ~2000.1.1]]
                    ==
  =/  row2  :-  %vector
                :~  [%namespace [~.tas %sys]]
                    [%tmsp [~.da ~2000.1.1]]
                    ==
  =/  row3  :-  %vector
                :~  [%namespace [~.tas %ns1]]
                    [%tmsp [~.da ~2000.1.2]]
                    ==
  ::
  =/  expected  :-  %results
                      :~  [%message 'SELECT']
                          [%result-set ~[row1 row2 row3]]
                          [%server-time ~2000.1.2]
                          [%schema-time ~2000.1.2]
                          [%data-time ~2000.1.2]
                          [%vector-count 3]
                      ==
  ::
  =^  mov1  agent
    %:  ~(on-poke agent (bowl [run ~2000.1.1]))
        %obelisk-action
        !>([%tape-create-db "CREATE DATABASE db1 AS OF ~2000.1.1"])
    ==
  =.  run  +(run)
  =^  mov2  agent
    %:  ~(on-poke agent (bowl [run ~2000.1.2]))
        %obelisk-action
        !>  :+  %tape
                %db1
                "CREATE NAMESPACE ns1 AS OF ~2000.1.2"
    ==
  =.  run  +(run)
  =^  mov3  agent
    %:  ~(on-poke agent (bowl [run ~2000.1.2]))
        %obelisk-action
        !>([%tape %db1 "FROM sys.namespaces SELECT *"])
    ==
  %+  expect-eq
    !>  expected
    !>  ->+>+>-.mov3
::
::  sys-namespaces not default DB
++  test-sys-namspaces-02
  =|  run=@ud
  =/  row1  :-  %vector
                :~  [%namespace [~.tas %dbo]]
                    [%tmsp [~.da ~2000.1.1]]
                    ==
  =/  row2  :-  %vector
                :~  [%namespace [~.tas %sys]]
                    [%tmsp [~.da ~2000.1.1]]
                    ==
  =/  row3  :-  %vector
                :~  [%namespace [~.tas %ns1]]
                    [%tmsp [~.da ~2000.1.2]]
                    ==
  ::
  =/  expected  :-  %results
                      :~  [%message 'SELECT']
                          [%result-set ~[row1 row2 row3]]
                          [%server-time ~2000.1.2]
                          [%schema-time ~2000.1.2]
                          [%data-time ~2000.1.2]
                          [%vector-count 3]
                      ==
  ::
  =^  mov1  agent
    %:  ~(on-poke agent (bowl [run ~1999.12.31]))
        %obelisk-action
        !>([%tape-create-db "CREATE DATABASE db1"])
    ==
  =.  run  +(run)
  =^  mov2  agent
    %:  ~(on-poke agent (bowl [run ~2000.1.1]))
        %obelisk-action
        !>([%tape-create-db "CREATE DATABASE db2"])
    ==
  =.  run  +(run)
  =^  mov3  agent
    %:  ~(on-poke agent (bowl [run ~2000.1.2]))
        %obelisk-action
        !>  :+  %tape
                %db2
                "CREATE NAMESPACE ns1"
    ==
  =.  run  +(run)
  =^  mov4  agent
    %:  ~(on-poke agent (bowl [run ~2000.1.2]))
        %obelisk-action
        !>([%tape %db1 "FROM db2.sys.namespaces SELECT *"])
    ==
  %+  expect-eq
    !>  expected
    ::!>  ;;(* expected)
    ::!>  ->+>+>-.mov4
    !>  ;;(cmd-result ->+>+>-.mov4)
::
::  sys.tables
::
::  Test Cases: CREATE, ALTER, DROP TABLE
::              INSERT, DELETE
::              TRUNCATE TABLE (data present/not present)
::
++  test-sys-tables-01  ::  CREATE TABLE
  =|  run=@ud
  =/  expected-rows
        :~
          :-  %vector
              :~  [%namespace [~.tas %dbo]]
                  [%name [~.tas %my-table]]
                  [%ship [~.p 0]]
                  [%agent [~.tas '/test-agent']]
                  [%tmsp [~.da ~2000.1.3]]
                  [%row-count [~.ud 1]]
                  [%key-ordinal [~.ud 1]]
                  [%key [~.tas %col1]]
                  [%key-ascending [~.f 0]]
                  ==
          :-  %vector
              :~  [%namespace [~.tas %dbo]]
                  [%name [~.tas %my-table]]
                  [%ship [~.p 0]]
                  [%agent [~.tas '/test-agent']]
                  [%tmsp [~.da ~2000.1.3]]
                  [%row-count [~.ud 1]]
                  [%key-ordinal [~.ud 2]]
                  [%key [~.tas %col2]]
                  [%key-ascending [~.f 1]]
                  ==
          :-  %vector
              :~  [%namespace [~.tas %dbo]]
                  [%name [~.tas %my-table-2]]
                  [%ship [~.p 0]]
                  [%agent [~.tas '/test-agent']]
                  [%tmsp [~.da ~2000.1.4]]
                  [%row-count [~.ud 0]]
                  [%key-ordinal [~.ud 1]]
                  [%key [~.tas %col1]]
                  [%key-ascending [~.f 1]]
                  ==
          :-  %vector
              :~  [%namespace [~.tas %dbo]]
                  [%name [~.tas %my-table-2]]
                  [%ship [~.p 0]]
                  [%agent [~.tas '/test-agent']]
                  [%tmsp [~.da ~2000.1.4]]
                  [%row-count [~.ud 0]]
                  [%key-ordinal [~.ud 2]]
                  [%key [~.tas %col2]]
                  [%key-ascending [~.f 0]]
                  ==
          :-  %vector
              :~  [%namespace [~.tas %dbo]]
                  [%name [~.tas %my-table-3]]
                  [%ship [~.p 0]]
                  [%agent [~.tas '/test-agent']]
                  [%tmsp [~.da ~2000.1.4]]
                  [%row-count [~.ud 0]]
                  [%key-ordinal [~.ud 1]]
                  [%key [~.tas %col1]]
                  [%key-ascending [~.f 0]]
                  ==
          :-  %vector
              :~  [%namespace [~.tas %dbo]]
                  [%name [~.tas %my-table-4]]
                  [%ship [~.p 0]]
                  [%agent [~.tas '/test-agent']]
                  [%tmsp [~.da ~2000.1.6]]
                  [%row-count [~.ud 0]]
                  [%key-ordinal [~.ud 1]]
                  [%key [~.tas %col1]]
                  [%key-ascending [~.f 0]]
                  ==
          :-  %vector
              :~  [%namespace [~.tas %dbo]]
                  [%name [~.tas %my-table-4]]
                  [%ship [~.p 0]]
                  [%agent [~.tas '/test-agent']]
                  [%tmsp [~.da ~2000.1.6]]
                  [%row-count [~.ud 0]]
                  [%key-ordinal [~.ud 2]]
                  [%key [~.tas %col3]]
                  [%key-ascending [~.f 0]]
                  ==
          :-  %vector
              :~  [%namespace [~.tas %ref]]
                  [%name [~.tas %my-table-4]]
                  [%ship [~.p 0]]
                  [%agent [~.tas '/test-agent']]
                  [%tmsp [~.da ~2000.1.7]]
                  [%row-count [~.ud 0]]
                  [%key-ordinal [~.ud 1]]
                  [%key [~.tas %col1]]
                  [%key-ascending [~.f 0]]
                  ==
          :-  %vector
              :~  [%namespace [~.tas %ref]]
                  [%name [~.tas %my-table-4]]
                  [%ship [~.p 0]]
                  [%agent [~.tas '/test-agent']]
                  [%tmsp [~.da ~2000.1.7]]
                  [%row-count [~.ud 0]]
                  [%key-ordinal [~.ud 2]]
                  [%key [~.tas %col3]]
                  [%key-ascending [~.f 0]]
                  ==
          ==
  =/  expected  :-  %results
                      :~  [%message 'SELECT']
                          [%result-set expected-rows]
                          [%server-time ~2000.1.8]
                          [%schema-time ~2000.1.7]
                          [%data-time ~2000.1.7]
                          [%vector-count 9]
                      ==
  =^  mov1  agent
    %:  ~(on-poke agent (bowl [run ~2000.1.1]))
        %obelisk-action
        !>([%tape-create-db "CREATE DATABASE db1"])
    ==
  =.  run  +(run)
  =^  mov2  agent
    %:  ~(on-poke agent (bowl [run ~2000.1.2]))
        %obelisk-action
        !>  :+  %tape
                %db1
                "CREATE TABLE db1..my-table (col1 @t, col2 @t) ".
                "PRIMARY KEY (col1, col2 DESC)"
    ==
  =.  run  +(run)
  =^  mov3  agent
    %:  ~(on-poke agent (bowl [run ~2000.1.3]))
        %obelisk-action
        !>  :+  %tape
                %db1
                "INSERT INTO db1..my-table (col1, col2) ".
                "VALUES ('cord', 'cord2')"
    ==
  =.  run  +(run)
  =^  mov4  agent
    %:  ~(on-poke agent (bowl [run ~2000.1.4]))
        %obelisk-action
        !>  :+  %tape
                %db1
                "CREATE TABLE db1..my-table-2 (col1 @p, col2 @t) ".
                "PRIMARY KEY (col1 desc, col2); ".
                "CREATE TABLE db1..my-table-3 (col1 @p, col2 @t, col3 @ud) ".
                "PRIMARY KEY (col1)"
    ==
  =.  run  +(run)
  =^  mov5  agent
    %:  ~(on-poke agent (bowl [run ~2000.1.5]))
        %obelisk-action
        !>([%tape %db1 "CREATE NAMESPACE ref"])
    ==
  =.  run  +(run)
  =^  mov6  agent
    %:  ~(on-poke agent (bowl [run ~2000.1.6]))
        %obelisk-action
        !>  :+  %tape
                %db1
                "CREATE TABLE db1..my-table-4 (col1 @p, col2 @t, col3 @ud) ".
                "PRIMARY KEY (col1, col3)"
    ==
  =.  run  +(run)
  =^  mov7  agent
    %:  ~(on-poke agent (bowl [run ~2000.1.7]))
        %obelisk-action
        !>  :+  %tape
                %db1
                "CREATE TABLE db1.ref.my-table-4 (col1 @p, col2 @t, col3 @ud) ".
                "PRIMARY KEY (col1, col3)"
    ==
  =.  run  +(run)
  =^  mov8  agent
    %:  ~(on-poke agent (bowl [run ~2000.1.8]))
        %obelisk-action
        !>([%tape %db1 "FROM sys.tables SELECT *"])
    ==
  %+  expect-eq
    !>  expected
    !>  ->+>+>-.mov8
::
++  test-sys-tables-02  ::  INSERT and DROP TABLE
  =|  run=@ud
  =/  expected-rows
        :~
          :-  %vector
              :~  [%namespace [~.tas %dbo]]
                  [%name [~.tas %my-table]]
                  [%ship [~.p 0]]
                  [%agent [~.tas '/test-agent']]
                  [%tmsp [~.da ~2000.1.3]]
                  [%row-count [~.ud 1]]
                  [%key-ordinal [~.ud 1]]
                  [%key [~.tas %col1]]
                  [%key-ascending [~.f 0]]
                  ==
          :-  %vector
              :~  [%namespace [~.tas %dbo]]
                  [%name [~.tas %my-table]]
                  [%ship [~.p 0]]
                  [%agent [~.tas '/test-agent']]
                  [%tmsp [~.da ~2000.1.3]]
                  [%row-count [~.ud 1]]
                  [%key-ordinal [~.ud 2]]
                  [%key [~.tas %col2]]
                  [%key-ascending [~.f 1]]
                  ==
          :-  %vector
              :~  [%namespace [~.tas %dbo]]
                  [%name [~.tas %my-table-2]]
                  [%ship [~.p 0]]
                  [%agent [~.tas '/test-agent']]
                  [%tmsp [~.da ~2000.1.4]]
                  [%row-count [~.ud 0]]
                  [%key-ordinal [~.ud 1]]
                  [%key [~.tas %col1]]
                  [%key-ascending [~.f 1]]
                  ==
          :-  %vector
              :~  [%namespace [~.tas %dbo]]
                  [%name [~.tas %my-table-2]]
                  [%ship [~.p 0]]
                  [%agent [~.tas '/test-agent']]
                  [%tmsp [~.da ~2000.1.4]]
                  [%row-count [~.ud 0]]
                  [%key-ordinal [~.ud 2]]
                  [%key [~.tas %col2]]
                  [%key-ascending [~.f 0]]
                  ==
          :-  %vector
              :~  [%namespace [~.tas %dbo]]
                  [%name [~.tas %my-table-3]]
                  [%ship [~.p 0]]
                  [%agent [~.tas '/test-agent']]
                  [%tmsp [~.da ~2000.1.4]]
                  [%row-count [~.ud 0]]
                  [%key-ordinal [~.ud 1]]
                  [%key [~.tas %col1]]
                  [%key-ascending [~.f 0]]
                  ==
          :-  %vector
              :~  [%namespace [~.tas %dbo]]
                  [%name [~.tas %my-table-4]]
                  [%ship [~.p 0]]
                  [%agent [~.tas '/test-agent']]
                  [%tmsp [~.da ~2000.1.6]]
                  [%row-count [~.ud 0]]
                  [%key-ordinal [~.ud 1]]
                  [%key [~.tas %col1]]
                  [%key-ascending [~.f 0]]
                  ==
          :-  %vector
              :~  [%namespace [~.tas %dbo]]
                  [%name [~.tas %my-table-4]]
                  [%ship [~.p 0]]
                  [%agent [~.tas '/test-agent']]
                  [%tmsp [~.da ~2000.1.6]]
                  [%row-count [~.ud 0]]
                  [%key-ordinal [~.ud 2]]
                  [%key [~.tas %col3]]
                  [%key-ascending [~.f 0]]
                  ==
          ==
  =/  expected  :-  %results
                      :~  [%message 'SELECT']
                          [%result-set expected-rows]
                          [%server-time ~2000.1.9]
                          [%schema-time ~2000.1.8]
                          [%data-time ~2000.1.8]
                          [%vector-count 7]
                      ==
  =^  mov1  agent
    %:  ~(on-poke agent (bowl [run ~2000.1.1]))
        %obelisk-action
        !>([%tape-create-db "CREATE DATABASE db1"])
    ==
  =.  run  +(run)
  =^  mov2  agent
    %:  ~(on-poke agent (bowl [run ~2000.1.2]))
        %obelisk-action
        !>  :+  %tape
                %db1
                "CREATE TABLE db1..my-table (col1 @t, col2 @t) ".
                "PRIMARY KEY (col1, col2 DESC)"
    ==
  =.  run  +(run)
  =^  mov3  agent
    %:  ~(on-poke agent (bowl [run ~2000.1.3]))
        %obelisk-action
        !>  :+  %tape
                %db1
                "INSERT INTO db1..my-table (col1, col2) ".
                "VALUES ('cord', 'cord2')"
    ==
  =.  run  +(run)
  =^  mov4  agent
    %:  ~(on-poke agent (bowl [run ~2000.1.4]))
        %obelisk-action
        !>  :+  %tape
                %db1
                "CREATE TABLE db1..my-table-2 (col1 @p, col2 @t) ".
                "PRIMARY KEY (col1 desc, col2); ".
                "CREATE TABLE db1..my-table-3 (col1 @p, col2 @t, col3 @ud) ".
                "PRIMARY KEY (col1)"
    ==
  =.  run  +(run)
  =^  mov5  agent
    %:  ~(on-poke agent (bowl [run ~2000.1.5]))
        %obelisk-action
        !>([%tape %db1 "CREATE NAMESPACE ref"])
    ==
  =.  run  +(run)
  =^  mov6  agent
    %:  ~(on-poke agent (bowl [run ~2000.1.6]))
        %obelisk-action
        !>  :+  %tape
                %db1
                "CREATE TABLE db1..my-table-4 (col1 @p, col2 @t, col3 @ud) ".
                "PRIMARY KEY (col1, col3)"
    ==
  =.  run  +(run)
  =^  mov7  agent
    %:  ~(on-poke agent (bowl [run ~2000.1.7]))
        %obelisk-action
        !>  :+  %tape
                %db1
                "CREATE TABLE db1.ref.my-table-4 (col1 @p, col2 @t, col3 @ud) ".
                "PRIMARY KEY (col1, col3)"
    ==

  =.  run  +(run)
  =^  mov8  agent
    %:  ~(on-poke agent (bowl [run ~2000.1.8]))
        %obelisk-action
        !>([%tape %db1 "DROP TABLE db1.ref.my-table-4"])
    ==

  =.  run  +(run)
  =^  mov9  agent
    %:  ~(on-poke agent (bowl [run ~2000.1.9]))
        %obelisk-action
        !>([%tape %db1 "FROM sys.tables SELECT *"])
    ==
  %+  expect-eq
    !>  expected
    !>  ->+>+>-.mov9

::
++  test-sys-tables-03  ::  TRUNCATE TABLE  (data present)
  =|  run=@ud
  =/  expected-rows
        :~
          :-  %vector
              :~  [%namespace [~.tas %dbo]]
                  [%name [~.tas %my-table]]
                  [%ship [~.p 0]]
                  [%agent [~.tas '/test-agent']]
                  [%tmsp [~.da ~2000.1.8]]
                  [%row-count [~.ud 0]]
                  [%key-ordinal [~.ud 1]]
                  [%key [~.tas %col1]]
                  [%key-ascending [~.f 0]]
                  ==
          :-  %vector
              :~  [%namespace [~.tas %dbo]]
                  [%name [~.tas %my-table]]
                  [%ship [~.p 0]]
                  [%agent [~.tas '/test-agent']]
                  [%tmsp [~.da ~2000.1.8]]
                  [%row-count [~.ud 0]]
                  [%key-ordinal [~.ud 2]]
                  [%key [~.tas %col2]]
                  [%key-ascending [~.f 1]]
                  ==
          :-  %vector
              :~  [%namespace [~.tas %dbo]]
                  [%name [~.tas %my-table-2]]
                  [%ship [~.p 0]]
                  [%agent [~.tas '/test-agent']]
                  [%tmsp [~.da ~2000.1.4]]
                  [%row-count [~.ud 0]]
                  [%key-ordinal [~.ud 1]]
                  [%key [~.tas %col1]]
                  [%key-ascending [~.f 1]]
                  ==
          :-  %vector
              :~  [%namespace [~.tas %dbo]]
                  [%name [~.tas %my-table-2]]
                  [%ship [~.p 0]]
                  [%agent [~.tas '/test-agent']]
                  [%tmsp [~.da ~2000.1.4]]
                  [%row-count [~.ud 0]]
                  [%key-ordinal [~.ud 2]]
                  [%key [~.tas %col2]]
                  [%key-ascending [~.f 0]]
                  ==
          :-  %vector
              :~  [%namespace [~.tas %dbo]]
                  [%name [~.tas %my-table-3]]
                  [%ship [~.p 0]]
                  [%agent [~.tas '/test-agent']]
                  [%tmsp [~.da ~2000.1.4]]
                  [%row-count [~.ud 0]]
                  [%key-ordinal [~.ud 1]]
                  [%key [~.tas %col1]]
                  [%key-ascending [~.f 0]]
                  ==
          :-  %vector
              :~  [%namespace [~.tas %dbo]]
                  [%name [~.tas %my-table-4]]
                  [%ship [~.p 0]]
                  [%agent [~.tas '/test-agent']]
                  [%tmsp [~.da ~2000.1.6]]
                  [%row-count [~.ud 0]]
                  [%key-ordinal [~.ud 1]]
                  [%key [~.tas %col1]]
                  [%key-ascending [~.f 0]]
                  ==
          :-  %vector
              :~  [%namespace [~.tas %dbo]]
                  [%name [~.tas %my-table-4]]
                  [%ship [~.p 0]]
                  [%agent [~.tas '/test-agent']]
                  [%tmsp [~.da ~2000.1.6]]
                  [%row-count [~.ud 0]]
                  [%key-ordinal [~.ud 2]]
                  [%key [~.tas %col3]]
                  [%key-ascending [~.f 0]]
                  ==
          :-  %vector
              :~  [%namespace [~.tas %ref]]
                  [%name [~.tas %my-table-4]]
                  [%ship [~.p 0]]
                  [%agent [~.tas '/test-agent']]
                  [%tmsp [~.da ~2000.1.7]]
                  [%row-count [~.ud 0]]
                  [%key-ordinal [~.ud 1]]
                  [%key [~.tas %col1]]
                  [%key-ascending [~.f 0]]
                  ==
          :-  %vector
              :~  [%namespace [~.tas %ref]]
                  [%name [~.tas %my-table-4]]
                  [%ship [~.p 0]]
                  [%agent [~.tas '/test-agent']]
                  [%tmsp [~.da ~2000.1.7]]
                  [%row-count [~.ud 0]]
                  [%key-ordinal [~.ud 2]]
                  [%key [~.tas %col3]]
                  [%key-ascending [~.f 0]]
                  ==
          ==
  =/  expected  :-  %results
                      :~  [%message 'SELECT']
                          [%result-set expected-rows]
                          [%server-time ~2000.1.9]
                          [%schema-time ~2000.1.7]
                          [%data-time ~2000.1.8]
                          [%vector-count 9]
                      ==
  =^  mov1  agent
    %:  ~(on-poke agent (bowl [run ~2000.1.1]))
        %obelisk-action
        !>([%tape-create-db "CREATE DATABASE db1"])
    ==
  =.  run  +(run)
  =^  mov2  agent
    %:  ~(on-poke agent (bowl [run ~2000.1.2]))
        %obelisk-action
        !>  :+  %tape
                %db1
                "CREATE TABLE db1..my-table (col1 @t, col2 @t) ".
                "PRIMARY KEY (col1, col2 DESC)"
    ==
  =.  run  +(run)
  =^  mov3  agent
    %:  ~(on-poke agent (bowl [run ~2000.1.3]))
        %obelisk-action
        !>  :+  %tape
                %db1
                "INSERT INTO db1..my-table (col1, col2) ".
                "VALUES ('cord', 'cord2')"
    ==
  =.  run  +(run)
  =^  mov4  agent
    %:  ~(on-poke agent (bowl [run ~2000.1.4]))
        %obelisk-action
        !>  :+  %tape
                %db1
                "CREATE TABLE db1..my-table-2 (col1 @p, col2 @t) ".
                "PRIMARY KEY (col1 desc, col2); ".
                "CREATE TABLE db1..my-table-3 (col1 @p, col2 @t, col3 @ud) ".
                "PRIMARY KEY (col1)"
    ==
  =.  run  +(run)
  =^  mov5  agent
    %:  ~(on-poke agent (bowl [run ~2000.1.5]))
        %obelisk-action
        !>([%tape %db1 "CREATE NAMESPACE ref"])
    ==
  =.  run  +(run)
  =^  mov6  agent
    %:  ~(on-poke agent (bowl [run ~2000.1.6]))
        %obelisk-action
        !>  :+  %tape
                %db1
                "CREATE TABLE db1..my-table-4 (col1 @p, col2 @t, col3 @ud) ".
                "PRIMARY KEY (col1, col3)"
    ==
  =.  run  +(run)
  =^  mov7  agent
    %:  ~(on-poke agent (bowl [run ~2000.1.7]))
        %obelisk-action
        !>  :+  %tape
                %db1
                "CREATE TABLE db1.ref.my-table-4 (col1 @p, col2 @t, col3 @ud) ".
                "PRIMARY KEY (col1, col3)"
    ==

  =.  run  +(run)
  =^  mov8  agent
    %:  ~(on-poke agent (bowl [run ~2000.1.8]))
        %obelisk-action
        !>([%tape %db1 "TRUNCATE TABLE db1..my-table"])
    ==

  =.  run  +(run)
  =^  mov9  agent
    %:  ~(on-poke agent (bowl [run ~2000.1.9]))
        %obelisk-action
        !>([%tape %db1 "FROM sys.tables SELECT *"])
    ==
  %+  expect-eq
    !>  expected
    !>  ->+>+>-.mov9
::
++  test-sys-tables-04  ::  TRUNCATE TABLE  (data not present)
  =|  run=@ud
  =/  expected-rows
        :~
          :-  %vector
              :~  [%namespace [~.tas %dbo]]
                  [%name [~.tas %my-table]]
                  [%ship [~.p 0]]
                  [%agent [~.tas '/test-agent']]
                  [%tmsp [~.da ~2000.1.2]]
                  [%row-count [~.ud 0]]
                  [%key-ordinal [~.ud 1]]
                  [%key [~.tas %col1]]
                  [%key-ascending [~.f 0]]
                  ==
          :-  %vector
              :~  [%namespace [~.tas %dbo]]
                  [%name [~.tas %my-table]]
                  [%ship [~.p 0]]
                  [%agent [~.tas '/test-agent']]
                  [%tmsp [~.da ~2000.1.2]]
                  [%row-count [~.ud 0]]
                  [%key-ordinal [~.ud 2]]
                  [%key [~.tas %col2]]
                  [%key-ascending [~.f 1]]
                  ==
          :-  %vector
              :~  [%namespace [~.tas %dbo]]
                  [%name [~.tas %my-table-2]]
                  [%ship [~.p 0]]
                  [%agent [~.tas '/test-agent']]
                  [%tmsp [~.da ~2000.1.4]]
                  [%row-count [~.ud 0]]
                  [%key-ordinal [~.ud 1]]
                  [%key [~.tas %col1]]
                  [%key-ascending [~.f 1]]
                  ==
          :-  %vector
              :~  [%namespace [~.tas %dbo]]
                  [%name [~.tas %my-table-2]]
                  [%ship [~.p 0]]
                  [%agent [~.tas '/test-agent']]
                  [%tmsp [~.da ~2000.1.4]]
                  [%row-count [~.ud 0]]
                  [%key-ordinal [~.ud 2]]
                  [%key [~.tas %col2]]
                  [%key-ascending [~.f 0]]
                  ==
          :-  %vector
              :~  [%namespace [~.tas %dbo]]
                  [%name [~.tas %my-table-3]]
                  [%ship [~.p 0]]
                  [%agent [~.tas '/test-agent']]
                  [%tmsp [~.da ~2000.1.4]]
                  [%row-count [~.ud 0]]
                  [%key-ordinal [~.ud 1]]
                  [%key [~.tas %col1]]
                  [%key-ascending [~.f 0]]
                  ==
          :-  %vector
              :~  [%namespace [~.tas %dbo]]
                  [%name [~.tas %my-table-4]]
                  [%ship [~.p 0]]
                  [%agent [~.tas '/test-agent']]
                  [%tmsp [~.da ~2000.1.6]]
                  [%row-count [~.ud 0]]
                  [%key-ordinal [~.ud 1]]
                  [%key [~.tas %col1]]
                  [%key-ascending [~.f 0]]
                  ==
          :-  %vector
              :~  [%namespace [~.tas %dbo]]
                  [%name [~.tas %my-table-4]]
                  [%ship [~.p 0]]
                  [%agent [~.tas '/test-agent']]
                  [%tmsp [~.da ~2000.1.6]]
                  [%row-count [~.ud 0]]
                  [%key-ordinal [~.ud 2]]
                  [%key [~.tas %col3]]
                  [%key-ascending [~.f 0]]
                  ==
          :-  %vector
              :~  [%namespace [~.tas %ref]]
                  [%name [~.tas %my-table-4]]
                  [%ship [~.p 0]]
                  [%agent [~.tas '/test-agent']]
                  [%tmsp [~.da ~2000.1.7]]
                  [%row-count [~.ud 0]]
                  [%key-ordinal [~.ud 1]]
                  [%key [~.tas %col1]]
                  [%key-ascending [~.f 0]]
                  ==
          :-  %vector
              :~  [%namespace [~.tas %ref]]
                  [%name [~.tas %my-table-4]]
                  [%ship [~.p 0]]
                  [%agent [~.tas '/test-agent']]
                  [%tmsp [~.da ~2000.1.7]]
                  [%row-count [~.ud 0]]
                  [%key-ordinal [~.ud 2]]
                  [%key [~.tas %col3]]
                  [%key-ascending [~.f 0]]
                  ==
          ==
  =/  expected  :-  %results
                      :~  [%message 'SELECT']
                          [%result-set expected-rows]
                          [%server-time ~2000.1.9]
                          [%schema-time ~2000.1.7]
                          [%data-time ~2000.1.7]
                          [%vector-count 9]
                      ==
  =^  mov1  agent
    %:  ~(on-poke agent (bowl [run ~2000.1.1]))
        %obelisk-action
        !>([%tape-create-db "CREATE DATABASE db1"])
    ==
  =.  run  +(run)
  =^  mov2  agent
    %:  ~(on-poke agent (bowl [run ~2000.1.2]))
        %obelisk-action
        !>  :+  %tape
                %db1
                "CREATE TABLE db1..my-table (col1 @t, col2 @t) ".
                "PRIMARY KEY (col1, col2 DESC)"
    ==
  =.  run  +(run)
  =^  mov3  agent
    %:  ~(on-poke agent (bowl [run ~2000.1.4]))
        %obelisk-action
        !>  :+  %tape
                %db1
                "CREATE TABLE db1..my-table-2 (col1 @p, col2 @t) ".
                "PRIMARY KEY (col1 desc, col2); ".
                "CREATE TABLE db1..my-table-3 (col1 @p, col2 @t, col3 @ud) ".
                "PRIMARY KEY (col1)"
    ==
  =.  run  +(run)
  =^  mov4  agent
    %:  ~(on-poke agent (bowl [run ~2000.1.5]))
        %obelisk-action
        !>([%tape %db1 "CREATE NAMESPACE ref"])
    ==
  =.  run  +(run)
  =^  mov5  agent
    %:  ~(on-poke agent (bowl [run ~2000.1.6]))
        %obelisk-action
        !>  :+  %tape
                %db1
                "CREATE TABLE db1..my-table-4 (col1 @p, col2 @t, col3 @ud) ".
                "PRIMARY KEY (col1, col3)"
    ==
  =.  run  +(run)
  =^  mov6  agent
    %:  ~(on-poke agent (bowl [run ~2000.1.7]))
        %obelisk-action
        !>  :+  %tape
                %db1
                "CREATE TABLE db1.ref.my-table-4 (col1 @p, col2 @t, col3 @ud) ".
                "PRIMARY KEY (col1, col3)"
    ==

  =.  run  +(run)
  =^  mov7  agent
    %:  ~(on-poke agent (bowl [run ~2000.1.8]))
        %obelisk-action
        !>([%tape %db1 "TRUNCATE TABLE db1..my-table"])
    ==

  =.  run  +(run)
  =^  mov8  agent
    %:  ~(on-poke agent (bowl [run ~2000.1.9]))
        %obelisk-action
        !>([%tape %db1 "FROM sys.tables SELECT *"])
    ==
  %+  expect-eq
    !>  expected
    !>  ->+>+>-.mov8
::
++  test-sys-columns-01 ::  CREATE TABLE
  =|  run=@ud
  =/  expected-rows
        :~
          :-  %vector
            :~  [%namespace [~.tas %dbo]]
                [%name [~.tas %my-table-2]]
                [%col-ordinal [~.ud 1]]
                [%col-name [~.tas %col1]]
                [%col-type [~.ta ~.p]]
              ==
          :-  %vector
              :~  [%namespace [~.tas %dbo]]
                  [%name [~.tas %my-table-2]]
                  [%col-ordinal [~.ud 2]]
                  [%col-name [~.tas %col2]]
                  [%col-type [~.ta ~.t]]
                ==
          :-  %vector
              :~  [%namespace [~.tas %dbo]]
                  [%name [~.tas %my-table-3]]
                  [%col-ordinal [~.ud 1]]
                  [%col-name [~.tas %col1]]
                  [%col-type [~.ta ~.p]]
                ==
          :-  %vector
              :~  [%namespace [~.tas %dbo]]
                  [%name [~.tas %my-table-3]]
                  [%col-ordinal [~.ud 2]]
                  [%col-name [~.tas %col2]]
                  [%col-type [~.ta ~.t]]
                ==
          :-  %vector
              :~  [%namespace [~.tas %dbo]]
                  [%name [~.tas %my-table-3]]
                  [%col-ordinal [~.ud 3]]
                  [%col-name [~.tas %col3]]
                  [%col-type [~.ta ~.ud]]
                ==
          :-  %vector
              :~  [%namespace [~.tas %dbo]]
                  [%name [~.tas %my-table-4]]
                  [%col-ordinal [~.ud 1]]
                  [%col-name [~.tas %col1]]
                  [%col-type [~.ta ~.p]]
                ==
          :-  %vector
              :~  [%namespace [~.tas %dbo]]
                  [%name [~.tas %my-table-4]]
                  [%col-ordinal [~.ud 2]]
                  [%col-name [~.tas %col2]]
                  [%col-type [~.ta ~.t]]
                ==
          :-  %vector
              :~  [%namespace [~.tas %dbo]]
                  [%name [~.tas %my-table-4]]
                  [%col-ordinal [~.ud 3]]
                  [%col-name [~.tas %col3]]
                  [%col-type [~.ta ~.ud]]
                ==
          :-  %vector
              :~  [%namespace [~.tas %ref]]
                  [%name [~.tas %my-table]]
                  [%col-ordinal [~.ud 1]]
                  [%col-name [~.tas %col1]]
                  [%col-type [~.ta ~.t]]
                ==
          :-  %vector
              :~  [%namespace [~.tas %ref]]
                  [%name [~.tas %my-table]]
                  [%col-ordinal [~.ud 2]]
                  [%col-name [~.tas %col2]]
                  [%col-type [~.ta ~.t]]
              ==
        ==
  =/  expected  :-  %results
                      :~  [%message 'SELECT']
                          [%result-set expected-rows]
                          [%server-time ~2000.1.6]
                          [%schema-time ~2000.1.5]
                          [%data-time ~2000.1.5]
                          [%vector-count 10]
                      ==
  =^  mov1  agent
    %:  ~(on-poke agent (bowl [run ~2000.1.1]))
        %obelisk-action
        !>([%tape-create-db "CREATE DATABASE db1"])
    ==
  =.  run  +(run)
  =^  mov2  agent
    %:  ~(on-poke agent (bowl [run ~2000.1.2]))
        %obelisk-action
        !>([%tape %db1 "CREATE NAMESPACE db1.ref"])
    ==
  =.  run  +(run)
  =^  mov3  agent
    %:  ~(on-poke agent (bowl [run ~2000.1.3]))
        %obelisk-action
        !>  :+  %tape
                %db1
                "CREATE TABLE db1.ref.my-table (col1 @t, col2 @t) ".
                "PRIMARY KEY (col1, col2 DESC)"
    ==
  =.  run  +(run)
  =^  mov4  agent
    %:  ~(on-poke agent (bowl [run ~2000.1.4]))
        %obelisk-action
        !>  :+  %tape
                %db1
                "CREATE TABLE db1..my-table-2 (col1 @p, col2 @t) ".
                "PRIMARY KEY (col1 desc, col2); ".
                "CREATE TABLE db1..my-table-3 (col1 @p, col2 @t, col3 @ud) ".
                "PRIMARY KEY (col1)"
    ==
  =.  run  +(run)
  =^  mov5  agent
    %:  ~(on-poke agent (bowl [run ~2000.1.5]))
        %obelisk-action
        !>  :+  %tape
                %db1
                "CREATE TABLE db1..my-table-4 (col1 @p, col2 @t, col3 @ud) ".
                "PRIMARY KEY (col1, col3)"
    ==
  =.  run  +(run)
  =^  mov6  agent
    %:  ~(on-poke agent (bowl [run ~2000.1.6]))
        %obelisk-action
        !>([%tape %db1 "FROM sys.columns SELECT *"])
    ==
  %+  expect-eq
    !>  expected
    !>  ->+>+>-.mov6
::
++  test-sys-columns-02 ::  DROP TABLE
  =|  run=@ud
  =/  expected-rows
        :~
          :-  %vector
            :~  [%namespace [~.tas %dbo]]
                [%name [~.tas %my-table-2]]
                [%col-ordinal [~.ud 1]]
                [%col-name [~.tas %col1]]
                [%col-type [~.ta ~.p]]
              ==
          :-  %vector
              :~  [%namespace [~.tas %dbo]]
                  [%name [~.tas %my-table-2]]
                  [%col-ordinal [~.ud 2]]
                  [%col-name [~.tas %col2]]
                  [%col-type [~.ta ~.t]]
                ==
          :-  %vector
              :~  [%namespace [~.tas %dbo]]
                  [%name [~.tas %my-table-3]]
                  [%col-ordinal [~.ud 1]]
                  [%col-name [~.tas %col1]]
                  [%col-type [~.ta ~.p]]
                ==
          :-  %vector
              :~  [%namespace [~.tas %dbo]]
                  [%name [~.tas %my-table-3]]
                  [%col-ordinal [~.ud 2]]
                  [%col-name [~.tas %col2]]
                  [%col-type [~.ta ~.t]]
                ==
          :-  %vector
              :~  [%namespace [~.tas %dbo]]
                  [%name [~.tas %my-table-3]]
                  [%col-ordinal [~.ud 3]]
                  [%col-name [~.tas %col3]]
                  [%col-type [~.ta ~.ud]]
                ==
          :-  %vector
              :~  [%namespace [~.tas %dbo]]
                  [%name [~.tas %my-table-4]]
                  [%col-ordinal [~.ud 1]]
                  [%col-name [~.tas %col1]]
                  [%col-type [~.ta ~.p]]
                ==
          :-  %vector
              :~  [%namespace [~.tas %dbo]]
                  [%name [~.tas %my-table-4]]
                  [%col-ordinal [~.ud 2]]
                  [%col-name [~.tas %col2]]
                  [%col-type [~.ta ~.t]]
                ==
          :-  %vector
              :~  [%namespace [~.tas %dbo]]
                  [%name [~.tas %my-table-4]]
                  [%col-ordinal [~.ud 3]]
                  [%col-name [~.tas %col3]]
                  [%col-type [~.ta ~.ud]]
                ==
        ==
  =/  expected  :-  %results
                      :~  [%message 'SELECT']
                          [%result-set expected-rows]
                          [%server-time ~2000.1.7]
                          [%schema-time ~2000.1.6]
                          [%data-time ~2000.1.6]
                          [%vector-count 8]
                      ==
  =/  cmd  :^  %drop-table
              :*  %qualified-object
                  ship=~
                  database='db1'
                  namespace='ref'
                  name='my-table'
              ==
              %.y
              ~
  =^  mov1  agent
    %:  ~(on-poke agent (bowl [run ~2000.1.1]))
        %obelisk-action
        !>([%tape-create-db "CREATE DATABASE db1"])
    ==
  =.  run  +(run)
  =^  mov2  agent
    %:  ~(on-poke agent (bowl [run ~2000.1.2]))
        %obelisk-action
        !>([%tape %db1 "CREATE NAMESPACE db1.ref"])
    ==
  =.  run  +(run)
  =^  mov3  agent
    %:  ~(on-poke agent (bowl [run ~2000.1.3]))
        %obelisk-action
        !>  :+  %tape
                %db1
                "CREATE TABLE db1.ref.my-table (col1 @t, col2 @t) ".
                "PRIMARY KEY (col1, col2 DESC)"
    ==
  =.  run  +(run)
  =^  mov4  agent
    %:  ~(on-poke agent (bowl [run ~2000.1.4]))
        %obelisk-action
        !>  :+  %tape
                %db1
                "CREATE TABLE db1..my-table-2 (col1 @p, col2 @t) ".
                "PRIMARY KEY (col1 desc, col2); ".
                "CREATE TABLE db1..my-table-3 (col1 @p, col2 @t, col3 @ud) ".
                "PRIMARY KEY (col1)"
    ==
  =.  run  +(run)
  =^  mov5  agent
    %:  ~(on-poke agent (bowl [run ~2000.1.5]))
        %obelisk-action
        !>  :+  %tape
                %db1
                "CREATE TABLE db1..my-table-4 (col1 @p, col2 @t, col3 @ud) ".
                "PRIMARY KEY (col1, col3)"
    ==
  =.  run  +(run)
  =^  mov6  agent
    %:  ~(on-poke agent (bowl [run ~2000.1.6]))
        %obelisk-action
        !>([%commands ~[cmd]])
    ==
  =.  run  +(run)
  =^  mov7  agent
    %:  ~(on-poke agent (bowl [run ~2000.1.7]))
        %obelisk-action
        !>([%tape %db1 "FROM sys.columns SELECT *"])
    ==
  %+  expect-eq
    !>  expected
    !>  ->+>+>-.mov7
::
++  test-sys-log-01    ::  CREATE TABLE
  =|  run=@ud
  =/  expected-rows
        :~
          :-  %vector
              :~  [%tmsp [~.da ~2000.1.7]]
                  [%agent [~.tas '/test-agent']]
                  [%component [~.tas %ref]]
                  [%name [~.tas %my-table-4]]
                  ==
          :-  %vector
              :~  [%tmsp [~.da ~2000.1.6]]
                  [%agent [~.tas '/test-agent']]
                  [%component [~.tas %dbo]]
                  [%name [~.tas %my-table-4]]
                  ==
          :-  %vector
              :~  [%tmsp [~.da ~2000.1.5]]
                  [%agent [~.tas '/test-agent']]
                  [%component [~.tas %namespace]]
                  [%name [~.tas %ref]]
                  ==
          :-  %vector
              :~  [%tmsp [~.da ~2000.1.4]]
                  [%agent [~.tas '/test-agent']]
                  [%component [~.tas %dbo]]
                  [%name [~.tas %my-table-2]]
                  ==
          :-  %vector
              :~  [%tmsp [~.da ~2000.1.4]]
                  [%agent [~.tas '/test-agent']]
                  [%component [~.tas %dbo]]
                  [%name [~.tas %my-table-3]]
                  ==
          :-  %vector
              :~  [%tmsp [~.da ~2000.1.2]]
                  [%agent [~.tas '/test-agent']]
                  [%component [~.tas %dbo]]
                  [%name [~.tas %my-table]]
                  ==
          :-  %vector
              :~  [%tmsp [~.da ~2000.1.1]]
                  [%agent [~.tas '/test-agent']]
                  [%component [~.tas %namespace]]
                  [%name [~.tas %dbo]]
                  ==
          :-  %vector
              :~  [%tmsp [~.da ~2000.1.1]]
                  [%agent [~.tas '/test-agent']]
                  [%component [~.tas %namespace]]
                  [%name [~.tas %sys]]
                  ==
        ==
  =/  expected  :-  %results
                      :~  [%message 'SELECT']
                          [%result-set expected-rows]
                          [%server-time ~2000.1.8]
                          [%schema-time ~2000.1.7]
                          [%data-time ~2000.1.7]
                          [%vector-count 8]
                      ==
  =^  mov1  agent
    %:  ~(on-poke agent (bowl [run ~2000.1.1]))
        %obelisk-action
        !>([%tape-create-db "CREATE DATABASE db1"])
    ==
  =.  run  +(run)
  =^  mov2  agent
    %:  ~(on-poke agent (bowl [run ~2000.1.2]))
        %obelisk-action
        !>  :+  %tape
                %db1
                "CREATE TABLE db1..my-table (col1 @t, col2 @t) ".
                "PRIMARY KEY (col1, col2 DESC)"
    ==
  =.  run  +(run)
  =^  mov3  agent
    %:  ~(on-poke agent (bowl [run ~2000.1.4]))
        %obelisk-action
        !>  :+  %tape
                %db1
                "CREATE TABLE db1..my-table-2 (col1 @p, col2 @t) ".
                "PRIMARY KEY (col1 desc, col2); ".
                "CREATE TABLE db1..my-table-3 (col1 @p, col2 @t, col3 @ud) ".
                "PRIMARY KEY (col1)"
    ==
  =.  run  +(run)
  =^  mov4  agent
    %:  ~(on-poke agent (bowl [run ~2000.1.5]))
        %obelisk-action
        !>([%tape %db1 "CREATE NAMESPACE ref"])
    ==
  =.  run  +(run)
  =^  mov5  agent
    %:  ~(on-poke agent (bowl [run ~2000.1.6]))
        %obelisk-action
        !>  :+  %tape
                %db1
                "CREATE TABLE db1..my-table-4 (col1 @p, col2 @t, col3 @ud) ".
                "PRIMARY KEY (col1, col3)"
    ==
  =.  run  +(run)
  =^  mov6  agent
    %:  ~(on-poke agent (bowl [run ~2000.1.7]))
        %obelisk-action
        !>  :+  %tape
                %db1
                "CREATE TABLE db1.ref.my-table-4 (col1 @p, col2 @t, col3 @ud) ".
                "PRIMARY KEY (col1, col3)"
    ==
  =.  run  +(run)
  =^  mov7  agent
    %:  ~(on-poke agent (bowl [run ~2000.1.8]))
        %obelisk-action
        !>([%tape %db1 "FROM sys.sys-log SELECT *"])
    ==
  %+  expect-eq
    !>  expected
    !>  ->+>+>-.mov7
::
++  test-sys-log-02    ::  DROP TABLE
  =|  run=@ud
  =/  expected-rows
        :~
          :-  %vector
              :~  [%tmsp [~.da ~2000.1.7]]
                  [%agent [~.tas '/test-agent']]
                  [%component [~.tas %ref]]
                  [%name [~.tas %my-table-4]]
                  ==
          :-  %vector
              :~  [%tmsp [~.da ~2000.1.6]]
                  [%agent [~.tas '/test-agent']]
                  [%component [~.tas %dbo]]
                  [%name [~.tas %my-table-4]]
                  ==
          :-  %vector
              :~  [%tmsp [~.da ~2000.1.5]]
                  [%agent [~.tas '/test-agent']]
                  [%component [~.tas %namespace]]
                  [%name [~.tas %ref]]
                  ==
          :-  %vector
              :~  [%tmsp [~.da ~2000.1.4]]
                  [%agent [~.tas '/test-agent']]
                  [%component [~.tas %dbo]]
                  [%name [~.tas %my-table-2]]
                  ==
          :-  %vector
              :~  [%tmsp [~.da ~2000.1.4]]
                  [%agent [~.tas '/test-agent']]
                  [%component [~.tas %dbo]]
                  [%name [~.tas %my-table-3]]
                  ==
          :-  %vector
              :~  [%tmsp [~.da ~2000.1.2]]
                  [%agent [~.tas '/test-agent']]
                  [%component [~.tas %dbo]]
                  [%name [~.tas %my-table]]
                  ==
          :-  %vector
              :~  [%tmsp [~.da ~2000.1.1]]
                  [%agent [~.tas '/test-agent']]
                  [%component [~.tas %namespace]]
                  [%name [~.tas %dbo]]
                  ==
          :-  %vector
              :~  [%tmsp [~.da ~2000.1.1]]
                  [%agent [~.tas '/test-agent']]
                  [%component [~.tas %namespace]]
                  [%name [~.tas %sys]]
                  ==
        ==
  =/  expected  :-  %results
                      :~  [%message 'SELECT']
                          [%result-set expected-rows]
                          [%server-time ~2000.1.9]
                          [%schema-time ~2000.1.8]
                          [%data-time ~2000.1.8]
                          [%vector-count 8]
                      ==
  =^  mov1  agent
    %:  ~(on-poke agent (bowl [run ~2000.1.1]))
        %obelisk-action
        !>([%tape-create-db "CREATE DATABASE db1"])
    ==
  =.  run  +(run)
  =^  mov2  agent
    %:  ~(on-poke agent (bowl [run ~2000.1.2]))
        %obelisk-action
        !>  :+  %tape
                %db1
                "CREATE TABLE db1..my-table (col1 @t, col2 @t) ".
                "PRIMARY KEY (col1, col2 DESC)"
    ==
  =.  run  +(run)
  =^  mov3  agent
    %:  ~(on-poke agent (bowl [run ~2000.1.4]))
        %obelisk-action
        !>  :+  %tape
                %db1
                "CREATE TABLE db1..my-table-2 (col1 @p, col2 @t) ".
                "PRIMARY KEY (col1 desc, col2); ".
                "CREATE TABLE db1..my-table-3 (col1 @p, col2 @t, col3 @ud) ".
                "PRIMARY KEY (col1)"
    ==
  =.  run  +(run)
  =^  mov4  agent
    %:  ~(on-poke agent (bowl [run ~2000.1.5]))
        %obelisk-action
        !>([%tape %db1 "CREATE NAMESPACE ref"])
    ==
  =.  run  +(run)
  =^  mov5  agent
    %:  ~(on-poke agent (bowl [run ~2000.1.6]))
        %obelisk-action
        !>  :+  %tape
                %db1
                "CREATE TABLE db1..my-table-4 (col1 @p, col2 @t, col3 @ud) ".
                "PRIMARY KEY (col1, col3)"
    ==
  =.  run  +(run)
  =^  mov6  agent
    %:  ~(on-poke agent (bowl [run ~2000.1.7]))
        %obelisk-action
        !>  :+  %tape
                %db1
                "CREATE TABLE db1.ref.my-table-4 (col1 @p, col2 @t, col3 @ud) ".
                "PRIMARY KEY (col1, col3)"
    ==
  =.  run  +(run)
  =^  mov7  agent
    %:  ~(on-poke agent (bowl [run ~2000.1.8]))
        %obelisk-action
        !>  :+  %tape
                %db1
                "DROP TABLE db1..my-table"
    ==
  =.  run  +(run)
  =^  mov8  agent
    %:  ~(on-poke agent (bowl [run ~2000.1.9]))
        %obelisk-action
        !>([%tape %db1 "FROM sys.sys-log SELECT *"])
    ==
  %+  expect-eq
    !>  expected
    !>  ->+>+>-.mov8
::
++  test-data-log-01   ::  INSERT
  =|  run=@ud
  =/  expected-rows
        :~
          :-  %vector
              :~  [%tmsp [~.da ~2000.1.10]]
                  [%ship [~.p 0]]
                  [%agent [~.tas '/test-agent']]
                  [%namespace [~.tas %ref]]
                  [%table [~.tas %my-table-4]]
                  ==
          :-  %vector
                  :~  [%tmsp [~.da ~2000.1.9]]
                  [%ship [~.p 0]]
                  [%agent [~.tas '/test-agent']]
                  [%namespace [~.tas %ref]]
                  [%table [~.tas %my-table-4]]
                  ==
          :-  %vector
              :~  [%tmsp [~.da ~2000.1.8]]
                  [%ship [~.p 0]]
                  [%agent [~.tas '/test-agent']]
                  [%namespace [~.tas %dbo]]
                  [%table [~.tas %my-table-4]]
                  ==
          :-  %vector
              :~  [%tmsp [~.da ~2000.1.7]]
                  [%ship [~.p 0]]
                  [%agent [~.tas '/test-agent']]
                  [%namespace [~.tas %dbo]]
                  [%table [~.tas %my-table-4]]
                  ==
          :-  %vector
              :~  [%tmsp [~.da ~2000.1.5]]
                  [%ship [~.p 0]]
                  [%agent [~.tas '/test-agent']]
                  [%namespace [~.tas %dbo]]
                  [%table [~.tas %my-table-2]]
                  ==
          :-  %vector
              :~  [%tmsp [~.da ~2000.1.4]]
                  [%ship [~.p 0]]
                  [%agent [~.tas '/test-agent']]
                  [%namespace [~.tas %dbo]]
                  [%table [~.tas %my-table-2]]
                  ==
          :-  %vector
              :~  [%tmsp [~.da ~2000.1.4]]
                  [%ship [~.p 0]]
                  [%agent [~.tas '/test-agent']]
                  [%namespace [~.tas %dbo]]
                  [%table [~.tas %my-table-3]]
                  ==
          :-  %vector
              :~  [%tmsp [~.da ~2000.1.3]]
                  [%ship [~.p 0]]
                  [%agent [~.tas '/test-agent']]
                  [%namespace [~.tas %dbo]]
                  [%table [~.tas %my-table]]
                  ==
          :-  %vector
              :~  [%tmsp [~.da ~2000.1.2]]
                  [%ship [~.p 0]]
                  [%agent [~.tas '/test-agent']]
                  [%namespace [~.tas %dbo]]
                  [%table [~.tas %my-table]]
                  ==
        ==
  =/  expected  :-  %results
                      :~  [%message 'SELECT']
                          [%result-set expected-rows]
                          [%server-time ~2000.1.11]
                          [%schema-time ~2000.1.9]
                          [%data-time ~2000.1.10]
                          [%vector-count 9]
                      ==
  =^  mov1  agent
    %:  ~(on-poke agent (bowl [run ~2000.1.1]))
        %obelisk-action
        !>([%tape-create-db "CREATE DATABASE db1"])
    ==
  =.  run  +(run)
  =^  mov2  agent
    %:  ~(on-poke agent (bowl [run ~2000.1.2]))
        %obelisk-action
        !>  :+  %tape
                %db1
                "CREATE TABLE db1..my-table (col1 @t, col2 @t) ".
                "PRIMARY KEY (col1, col2 DESC)"
    ==
    =.  run  +(run)
  =^  mov3  agent
    %:  ~(on-poke agent (bowl [run ~2000.1.3]))
        %obelisk-action
        !>  :+  %tape
                %db1
                "INSERT INTO db1..my-table (col1, col2) ".
                "VALUES ('cord', 'cord2')"
    ==
  =.  run  +(run)
  =^  mov4  agent
    %:  ~(on-poke agent (bowl [run ~2000.1.4]))
        %obelisk-action
        !>  :+  %tape
                %db1
                "CREATE TABLE db1..my-table-2 (col1 @p, col2 @t) ".
                "PRIMARY KEY (col1 desc, col2); ".
                "CREATE TABLE db1..my-table-3 (col1 @p, col2 @t, col3 @ud) ".
                "PRIMARY KEY (col1)"
    ==
    =.  run  +(run)
  =^  mov5  agent
    %:  ~(on-poke agent (bowl [run ~2000.1.5]))
        %obelisk-action
        !>  :+  %tape
                %db1
                "INSERT INTO db1..my-table-2 (col1, col2) ".
                "VALUES (~zod, 'cord2')"
    ==
  =.  run  +(run)
  =^  mov6  agent
    %:  ~(on-poke agent (bowl [run ~2000.1.6]))
        %obelisk-action
        !>([%tape %db1 "CREATE NAMESPACE ref"])
    ==
  =.  run  +(run)
  =^  mov7  agent
    %:  ~(on-poke agent (bowl [run ~2000.1.7]))
        %obelisk-action
        !>  :+  %tape
                %db1
                "CREATE TABLE db1..my-table-4 (col1 @p, col2 @t, col3 @ud) ".
                "PRIMARY KEY (col1, col3)"
    ==
    =.  run  +(run)
  =^  mov8  agent
    %:  ~(on-poke agent (bowl [run ~2000.1.8]))
        %obelisk-action
        !>  :+  %tape
                %db1
                "INSERT INTO db1..my-table-4 (col1, col2, col3) ".
                "VALUES (~zod, 'cord2', 42)"
    ==
  =.  run  +(run)
  =^  mov9  agent
    %:  ~(on-poke agent (bowl [run ~2000.1.9]))
        %obelisk-action
        !>  :+  %tape
                %db1
                "CREATE TABLE db1.ref.my-table-4 (col1 @p, col2 @t, col3 @ud) ".
                "PRIMARY KEY (col1, col3)"
    ==
    =.  run  +(run)
  =^  mov10  agent
    %:  ~(on-poke agent (bowl [run ~2000.1.10]))
        %obelisk-action
        !>  :+  %tape
                %db1
                "INSERT INTO db1.ref.my-table-4 (col1, col2, col3) ".
                "VALUES (~zod, 'cord2', 16)"
    ==
  =.  run  +(run)
  =^  mov11  agent
    %:  ~(on-poke agent (bowl [run ~2000.1.11]))
        %obelisk-action
        !>([%tape %db1 "FROM sys.data-log SELECT *"])
    ==
  %+  expect-eq
    !>  expected
    !>  ->+>+>-.mov11
::
++  test-data-log-02   ::  CREATE TABLE
  =|  run=@ud
  =/  expected-rows
        :~
          :-  %vector
                  :~  [%tmsp [~.da ~2000.1.9]]
                  [%ship [~.p 0]]
                  [%agent [~.tas '/test-agent']]
                  [%namespace [~.tas %ref]]
                  [%table [~.tas %my-table-4]]
                  ==
          :-  %vector
              :~  [%tmsp [~.da ~2000.1.8]]
                  [%ship [~.p 0]]
                  [%agent [~.tas '/test-agent']]
                  [%namespace [~.tas %dbo]]
                  [%table [~.tas %my-table-4]]
                  ==
          :-  %vector
              :~  [%tmsp [~.da ~2000.1.7]]
                  [%ship [~.p 0]]
                  [%agent [~.tas '/test-agent']]
                  [%namespace [~.tas %dbo]]
                  [%table [~.tas %my-table-4]]
                  ==
          :-  %vector
              :~  [%tmsp [~.da ~2000.1.5]]
                  [%ship [~.p 0]]
                  [%agent [~.tas '/test-agent']]
                  [%namespace [~.tas %dbo]]
                  [%table [~.tas %my-table-2]]
                  ==
          :-  %vector
              :~  [%tmsp [~.da ~2000.1.4]]
                  [%ship [~.p 0]]
                  [%agent [~.tas '/test-agent']]
                  [%namespace [~.tas %dbo]]
                  [%table [~.tas %my-table-2]]
                  ==
          :-  %vector
              :~  [%tmsp [~.da ~2000.1.4]]
                  [%ship [~.p 0]]
                  [%agent [~.tas '/test-agent']]
                  [%namespace [~.tas %dbo]]
                  [%table [~.tas %my-table-3]]
                  ==
          :-  %vector
              :~  [%tmsp [~.da ~2000.1.3]]
                  [%ship [~.p 0]]
                  [%agent [~.tas '/test-agent']]
                  [%namespace [~.tas %dbo]]
                  [%table [~.tas %my-table]]
                  ==
          :-  %vector
              :~  [%tmsp [~.da ~2000.1.2]]
                  [%ship [~.p 0]]
                  [%agent [~.tas '/test-agent']]
                  [%namespace [~.tas %dbo]]
                  [%table [~.tas %my-table]]
                  ==
        ==
  =/  expected  :-  %results
                      :~  [%message 'SELECT']
                          [%result-set expected-rows]
                          [%server-time ~2000.1.10]
                          [%schema-time ~2000.1.9]
                          [%data-time ~2000.1.9]
                          [%vector-count 8]
                      ==
  =^  mov1  agent
    %:  ~(on-poke agent (bowl [run ~2000.1.1]))
        %obelisk-action
        !>([%tape-create-db "CREATE DATABASE db1"])
    ==
  =.  run  +(run)
  =^  mov2  agent
    %:  ~(on-poke agent (bowl [run ~2000.1.2]))
        %obelisk-action
        !>  :+  %tape
                %db1
                "CREATE TABLE db1..my-table (col1 @t, col2 @t) ".
                "PRIMARY KEY (col1, col2 DESC)"
    ==
    =.  run  +(run)
  =^  mov3  agent
    %:  ~(on-poke agent (bowl [run ~2000.1.3]))
        %obelisk-action
        !>  :+  %tape
                %db1
                "INSERT INTO db1..my-table (col1, col2) ".
                "VALUES ('cord', 'cord2')"
    ==
  =.  run  +(run)
  =^  mov4  agent
    %:  ~(on-poke agent (bowl [run ~2000.1.4]))
        %obelisk-action
        !>  :+  %tape
                %db1
                "CREATE TABLE db1..my-table-2 (col1 @p, col2 @t) ".
                "PRIMARY KEY (col1 desc, col2); ".
                "CREATE TABLE db1..my-table-3 (col1 @p, col2 @t, col3 @ud) ".
                "PRIMARY KEY (col1)"
    ==
    =.  run  +(run)
  =^  mov5  agent
    %:  ~(on-poke agent (bowl [run ~2000.1.5]))
        %obelisk-action
        !>  :+  %tape
                %db1
                "INSERT INTO db1..my-table-2 (col1, col2) ".
                "VALUES (~zod, 'cord2')"
    ==
  =.  run  +(run)
  =^  mov6  agent
    %:  ~(on-poke agent (bowl [run ~2000.1.6]))
        %obelisk-action
        !>([%tape %db1 "CREATE NAMESPACE ref"])
    ==
  =.  run  +(run)
  =^  mov7  agent
    %:  ~(on-poke agent (bowl [run ~2000.1.7]))
        %obelisk-action
        !>  :+  %tape
                %db1
                "CREATE TABLE db1..my-table-4 (col1 @p, col2 @t, col3 @ud) ".
                "PRIMARY KEY (col1, col3)"
    ==
    =.  run  +(run)
  =^  mov8  agent
    %:  ~(on-poke agent (bowl [run ~2000.1.8]))
        %obelisk-action
        !>  :+  %tape
                %db1
                "INSERT INTO db1..my-table-4 (col1, col2, col3) ".
                "VALUES (~zod, 'cord2', 42)"
    ==
  =.  run  +(run)
  =^  mov9  agent
    %:  ~(on-poke agent (bowl [run ~2000.1.9]))
        %obelisk-action
        !>  :+  %tape
                %db1
                "CREATE TABLE db1.ref.my-table-4 (col1 @p, col2 @t, col3 @ud) ".
                "PRIMARY KEY (col1, col3)"
    ==
  =.  run  +(run)
  =^  mov11  agent
    %:  ~(on-poke agent (bowl [run ~2000.1.10]))
        %obelisk-action
        !>([%tape %db1 "FROM sys.data-log SELECT *"])
    ==
  %+  expect-eq
    !>  expected
    !>  ->+>+>-.mov11
::
++  test-data-log-03   ::  DROP TABLE FORCE
  =|  run=@ud
  =/  expected-rows
        :~
          :-  %vector
                  :~  [%tmsp [~.da ~2000.1.9]]
                  [%ship [~.p 0]]
                  [%agent [~.tas '/test-agent']]
                  [%namespace [~.tas %ref]]
                  [%table [~.tas %my-table-4]]
                  ==
          :-  %vector
              :~  [%tmsp [~.da ~2000.1.8]]
                  [%ship [~.p 0]]
                  [%agent [~.tas '/test-agent']]
                  [%namespace [~.tas %dbo]]
                  [%table [~.tas %my-table-4]]
                  ==
          :-  %vector
              :~  [%tmsp [~.da ~2000.1.7]]
                  [%ship [~.p 0]]
                  [%agent [~.tas '/test-agent']]
                  [%namespace [~.tas %dbo]]
                  [%table [~.tas %my-table-4]]
                  ==
          :-  %vector
              :~  [%tmsp [~.da ~2000.1.5]]
                  [%ship [~.p 0]]
                  [%agent [~.tas '/test-agent']]
                  [%namespace [~.tas %dbo]]
                  [%table [~.tas %my-table-2]]
                  ==
          :-  %vector
              :~  [%tmsp [~.da ~2000.1.4]]
                  [%ship [~.p 0]]
                  [%agent [~.tas '/test-agent']]
                  [%namespace [~.tas %dbo]]
                  [%table [~.tas %my-table-2]]
                  ==
          :-  %vector
              :~  [%tmsp [~.da ~2000.1.4]]
                  [%ship [~.p 0]]
                  [%agent [~.tas '/test-agent']]
                  [%namespace [~.tas %dbo]]
                  [%table [~.tas %my-table-3]]
                  ==
          :-  %vector
              :~  [%tmsp [~.da ~2000.1.3]]
                  [%ship [~.p 0]]
                  [%agent [~.tas '/test-agent']]
                  [%namespace [~.tas %dbo]]
                  [%table [~.tas %my-table]]
                  ==
          :-  %vector
              :~  [%tmsp [~.da ~2000.1.2]]
                  [%ship [~.p 0]]
                  [%agent [~.tas '/test-agent']]
                  [%namespace [~.tas %dbo]]
                  [%table [~.tas %my-table]]
                  ==
        ==
  =/  expected  :-  %results
                      :~  [%message 'SELECT']
                          [%result-set expected-rows]
                          [%server-time ~2000.1.11]
                          [%schema-time ~2000.1.10]
                          [%data-time ~2000.1.10]
                          [%vector-count 8]
                      ==
  =^  mov1  agent
    %:  ~(on-poke agent (bowl [run ~2000.1.1]))
        %obelisk-action
        !>([%tape-create-db "CREATE DATABASE db1"])
    ==
  =.  run  +(run)
  =^  mov2  agent
    %:  ~(on-poke agent (bowl [run ~2000.1.2]))
        %obelisk-action
        !>  :+  %tape
                %db1
                "CREATE TABLE db1..my-table (col1 @t, col2 @t) ".
                "PRIMARY KEY (col1, col2 DESC)"
    ==
    =.  run  +(run)
  =^  mov3  agent
    %:  ~(on-poke agent (bowl [run ~2000.1.3]))
        %obelisk-action
        !>  :+  %tape
                %db1
                "INSERT INTO db1..my-table (col1, col2) ".
                "VALUES ('cord', 'cord2')"
    ==
  =.  run  +(run)
  =^  mov4  agent
    %:  ~(on-poke agent (bowl [run ~2000.1.4]))
        %obelisk-action
        !>  :+  %tape
                %db1
                "CREATE TABLE db1..my-table-2 (col1 @p, col2 @t) ".
                "PRIMARY KEY (col1 desc, col2); ".
                "CREATE TABLE db1..my-table-3 (col1 @p, col2 @t, col3 @ud) ".
                "PRIMARY KEY (col1)"
    ==
    =.  run  +(run)
  =^  mov5  agent
    %:  ~(on-poke agent (bowl [run ~2000.1.5]))
        %obelisk-action
        !>  :+  %tape
                %db1
                "INSERT INTO db1..my-table-2 (col1, col2) ".
                "VALUES (~zod, 'cord2')"
    ==
  =.  run  +(run)
  =^  mov6  agent
    %:  ~(on-poke agent (bowl [run ~2000.1.6]))
        %obelisk-action
        !>([%tape %db1 "CREATE NAMESPACE ref"])
    ==
  =.  run  +(run)
  =^  mov7  agent
    %:  ~(on-poke agent (bowl [run ~2000.1.7]))
        %obelisk-action
        !>  :+  %tape
                %db1
                "CREATE TABLE db1..my-table-4 (col1 @p, col2 @t, col3 @ud) ".
                "PRIMARY KEY (col1, col3)"
    ==
    =.  run  +(run)
  =^  mov8  agent
    %:  ~(on-poke agent (bowl [run ~2000.1.8]))
        %obelisk-action
        !>  :+  %tape
                %db1
                "INSERT INTO db1..my-table-4 (col1, col2, col3) ".
                "VALUES (~zod, 'cord2', 42)"
    ==
  =.  run  +(run)
  =^  mov9  agent
    %:  ~(on-poke agent (bowl [run ~2000.1.9]))
        %obelisk-action
        !>  :+  %tape
                %db1
                "CREATE TABLE db1.ref.my-table-4 (col1 @p, col2 @t, col3 @ud) ".
                "PRIMARY KEY (col1, col3)"
    ==
  =.  run  +(run)

   =^  mov10  agent
    %:  ~(on-poke agent (bowl [run ~2000.1.10]))
        %obelisk-action
        !>  :+  %tape
                %db1
                "DROP TABLE FORCE db1..my-table-4"
    ==
  =.  run  +(run)

  =^  mov11  agent
    %:  ~(on-poke agent (bowl [run ~2000.1.11]))
        %obelisk-action
        !>([%tape %db1 "FROM sys.data-log SELECT *"])
    ==
  %+  expect-eq
    !>  expected
    ::!>  ;;(* expected)
    !>  ->+>+>-.mov11
::
++  test-data-log-04   ::  TRUNCATE TABLE
  =|  run=@ud
  =/  expected-rows
        :~
          :-  %vector
              :~  [%tmsp [~.da ~2000.1.10]]
                  [%ship [~.p 0]]
                  [%agent [~.tas '/test-agent']]
                  [%namespace [~.tas %dbo]]
                  [%table [~.tas %my-table-4]]
                  ==
          :-  %vector
                  :~  [%tmsp [~.da ~2000.1.9]]
                  [%ship [~.p 0]]
                  [%agent [~.tas '/test-agent']]
                  [%namespace [~.tas %ref]]
                  [%table [~.tas %my-table-4]]
                  ==
          :-  %vector
              :~  [%tmsp [~.da ~2000.1.8]]
                  [%ship [~.p 0]]
                  [%agent [~.tas '/test-agent']]
                  [%namespace [~.tas %dbo]]
                  [%table [~.tas %my-table-4]]
                  ==
          :-  %vector
              :~  [%tmsp [~.da ~2000.1.7]]
                  [%ship [~.p 0]]
                  [%agent [~.tas '/test-agent']]
                  [%namespace [~.tas %dbo]]
                  [%table [~.tas %my-table-4]]
                  ==
          :-  %vector
              :~  [%tmsp [~.da ~2000.1.5]]
                  [%ship [~.p 0]]
                  [%agent [~.tas '/test-agent']]
                  [%namespace [~.tas %dbo]]
                  [%table [~.tas %my-table-2]]
                  ==
          :-  %vector
              :~  [%tmsp [~.da ~2000.1.4]]
                  [%ship [~.p 0]]
                  [%agent [~.tas '/test-agent']]
                  [%namespace [~.tas %dbo]]
                  [%table [~.tas %my-table-2]]
                  ==
          :-  %vector
              :~  [%tmsp [~.da ~2000.1.4]]
                  [%ship [~.p 0]]
                  [%agent [~.tas '/test-agent']]
                  [%namespace [~.tas %dbo]]
                  [%table [~.tas %my-table-3]]
                  ==
          :-  %vector
              :~  [%tmsp [~.da ~2000.1.3]]
                  [%ship [~.p 0]]
                  [%agent [~.tas '/test-agent']]
                  [%namespace [~.tas %dbo]]
                  [%table [~.tas %my-table]]
                  ==
          :-  %vector
              :~  [%tmsp [~.da ~2000.1.2]]
                  [%ship [~.p 0]]
                  [%agent [~.tas '/test-agent']]
                  [%namespace [~.tas %dbo]]
                  [%table [~.tas %my-table]]
                  ==
        ==
  =/  expected  :-  %results
                      :~  [%message 'SELECT']
                          [%result-set expected-rows]
                          [%server-time ~2000.1.11]
                          [%schema-time ~2000.1.9]
                          [%data-time ~2000.1.10]
                          [%vector-count 9]
                      ==
  =^  mov1  agent
    %:  ~(on-poke agent (bowl [run ~2000.1.1]))
        %obelisk-action
        !>([%tape-create-db "CREATE DATABASE db1"])
    ==
  =.  run  +(run)
  =^  mov2  agent
    %:  ~(on-poke agent (bowl [run ~2000.1.2]))
        %obelisk-action
        !>  :+  %tape
                %db1
                "CREATE TABLE db1..my-table (col1 @t, col2 @t) ".
                "PRIMARY KEY (col1, col2 DESC)"
    ==
    =.  run  +(run)
  =^  mov3  agent
    %:  ~(on-poke agent (bowl [run ~2000.1.3]))
        %obelisk-action
        !>  :+  %tape
                %db1
                "INSERT INTO db1..my-table (col1, col2) ".
                "VALUES ('cord', 'cord2')"
    ==
  =.  run  +(run)
  =^  mov4  agent
    %:  ~(on-poke agent (bowl [run ~2000.1.4]))
        %obelisk-action
        !>  :+  %tape
                %db1
                "CREATE TABLE db1..my-table-2 (col1 @p, col2 @t) ".
                "PRIMARY KEY (col1 desc, col2); ".
                "CREATE TABLE db1..my-table-3 (col1 @p, col2 @t, col3 @ud) ".
                "PRIMARY KEY (col1)"
    ==
    =.  run  +(run)
  =^  mov5  agent
    %:  ~(on-poke agent (bowl [run ~2000.1.5]))
        %obelisk-action
        !>  :+  %tape
                %db1
                "INSERT INTO db1..my-table-2 (col1, col2) ".
                "VALUES (~zod, 'cord2')"
    ==
  =.  run  +(run)
  =^  mov6  agent
    %:  ~(on-poke agent (bowl [run ~2000.1.6]))
        %obelisk-action
        !>([%tape %db1 "CREATE NAMESPACE ref"])
    ==
  =.  run  +(run)
  =^  mov7  agent
    %:  ~(on-poke agent (bowl [run ~2000.1.7]))
        %obelisk-action
        !>  :+  %tape
                %db1
                "CREATE TABLE db1..my-table-4 (col1 @p, col2 @t, col3 @ud) ".
                "PRIMARY KEY (col1, col3)"
    ==
    =.  run  +(run)
  =^  mov8  agent
    %:  ~(on-poke agent (bowl [run ~2000.1.8]))
        %obelisk-action
        !>  :+  %tape
                %db1
                "INSERT INTO db1..my-table-4 (col1, col2, col3) ".
                "VALUES (~zod, 'cord2', 42)"
    ==
  =.  run  +(run)
  =^  mov9  agent
    %:  ~(on-poke agent (bowl [run ~2000.1.9]))
        %obelisk-action
        !>  :+  %tape
                %db1
                "CREATE TABLE db1.ref.my-table-4 (col1 @p, col2 @t, col3 @ud) ".
                "PRIMARY KEY (col1, col3)"
    ==
  =.  run  +(run)

   =^  mov10  agent
    %:  ~(on-poke agent (bowl [run ~2000.1.10]))
        %obelisk-action
        !>  :+  %tape
                %db1
                "TRUNCATE TABLE db1..my-table-4"
    ==
  =.  run  +(run)

  =^  mov11  agent
    %:  ~(on-poke agent (bowl [run ~2000.1.11]))
        %obelisk-action
        !>([%tape %db1 "FROM sys.data-log SELECT *"])
    ==
  %+  expect-eq
    !>  ;;(* expected)
    !>  ->+>+>-.mov11
--