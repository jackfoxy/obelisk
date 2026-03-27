::  Demonstrate unit testing on a Gall agent with %obelisk.
::
/+  *test-helpers
|%
::
::  To Do: when alter implemented, for sys-tmsp ahead and behind data
::
::  sys.sys.databases
::
::  Test Cases: series ending in each of effective commands
::
++  test-sys-databases-01  ::  CREATE TABLE
  =|  run=@ud
  %-  exec-4-2
  :*  run
      [~2000.1.1 %sys "CREATE DATABASE db1"]
      ::
      :+  ~2000.1.2
          %db1
          "CREATE TABLE db1..my-table (col1 @t) PRIMARY KEY (col1)"
      ::
      [~2000.1.3 %db1 "INSERT INTO db1..my-table (col1) VALUES ('cord')"]
      ::
      [~2000.1.4 %sys "CREATE DATABASE db2"]
      ::
      :+  ~2000.1.5
          %db1
          "CREATE TABLE db2..my-table (col1 @t) PRIMARY KEY (col1)"
      ::
      [~2000.1.6 %db1 "FROM sys.sys.databases SELECT *"]
      ::
      :+  ~2000.1.7
          %db1
          "FROM sys.sys.databases AS OF ~2000.1.4..1.1.1 SELECT *"
      ::
      :-  %results
          :~  [%message 'SELECT']
              :-  %result-set
                  :~  :-  %vector
                          :~  [%database [~.tas %db2]]
                              [%sys-agent [~.ta '/test-agent']]
                              [%sys-tmsp [~.da ~2000.1.5]]
                              [%data-ship [~.p 0]]
                              [%data-agent [~.ta '/test-agent']]
                              [%data-tmsp [~.da ~2000.1.5]]
                              ==
                      :-  %vector
                          :~  [%database [~.tas %db1]]
                              [%sys-agent [~.ta '/test-agent']]
                              [%sys-tmsp [~.da ~2000.1.2]]
                              [%data-ship [~.p 0]]
                              [%data-agent [~.ta '/test-agent']]
                              [%data-tmsp [~.da ~2000.1.2]]
                              ==
                      :-  %vector
                          :~  [%database [~.tas %db1]]
                              [%sys-agent [~.ta '/test-agent']]
                              [%sys-tmsp [~.da ~2000.1.2]]
                              [%data-ship [~.p 0]]
                              [%data-agent [~.ta '/test-agent']]
                              [%data-tmsp [~.da ~2000.1.3]]
                              ==
                      :-  %vector
                          :~  [%database [~.tas %sys]]
                              [%sys-agent [~.ta '/test-agent']]
                              [%sys-tmsp [~.da ~2000.1.1]]
                              [%data-ship [~.p 0]]
                              [%data-agent [~.ta '/test-agent']]
                              [%data-tmsp [~.da ~2000.1.1]]
                              ==
                      :-  %vector
                          :~  [%database [~.tas %db1]]
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
              [%data-time ~2000.1.5]
              [%vector-count 6]
              ==
      ::
      :-  %results
          :~  [%message 'SELECT']
              :-  %result-set
                  :~  :-  %vector
                          :~  [%database [~.tas %db1]]
                              [%sys-agent [~.ta '/test-agent']]
                              [%sys-tmsp [~.da ~2000.1.2]]
                              [%data-ship [~.p 0]]
                              [%data-agent [~.ta '/test-agent']]
                              [%data-tmsp [~.da ~2000.1.2]]
                              ==
                      :-  %vector
                          :~  [%database [~.tas %db1]]
                              [%sys-agent [~.ta '/test-agent']]
                              [%sys-tmsp [~.da ~2000.1.2]]
                              [%data-ship [~.p 0]]
                              [%data-agent [~.ta '/test-agent']]
                              [%data-tmsp [~.da ~2000.1.3]]
                              ==
                      :-  %vector
                          :~  [%database [~.tas %sys]]
                              [%sys-agent [~.ta '/test-agent']]
                              [%sys-tmsp [~.da ~2000.1.1]]
                              [%data-ship [~.p 0]]
                              [%data-agent [~.ta '/test-agent']]
                              [%data-tmsp [~.da ~2000.1.1]]
                              ==
                      :-  %vector
                          :~  [%database [~.tas %db1]]
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
              [%server-time ~2000.1.7]
              [%message 'sys.sys.databases']
              [%schema-time ~2000.1.1]
              [%data-time ~2000.1.4]
              [%vector-count 5]
              ==
      ==
::
++  test-sys-databases-02  ::  DROP TABLE
  =|  run=@ud
  %-  exec-5-1
  :*  run
      [~2000.1.1 %sys "CREATE DATABASE db1"]
      ::
      :+  ~2000.1.2
          %db1
          "CREATE TABLE db1..my-table (col1 @t) PRIMARY KEY (col1)"
      ::
      [~2000.1.3 %db1 "INSERT INTO db1..my-table (col1) VALUES ('cord')"]
      ::
      [~2000.1.4 %sys "CREATE DATABASE db2"]
      ::
      :+  ~2000.1.5
          %db1
          "CREATE TABLE db2..my-table (col1 @t) PRIMARY KEY (col1)"
      ::
      [~2000.1.6 %db1 "DROP TABLE FORCE db1..my-table"]
      ::
      [~2000.1.7 %db1 "FROM sys.sys.databases SELECT *"]
      ::
      :-  %results
          :~  [%message 'SELECT']
              :-  %result-set
                  :~  :-  %vector
                          :~  [%database [~.tas %db2]]
                              [%sys-agent [~.ta '/test-agent']]
                              [%sys-tmsp [~.da ~2000.1.5]]
                              [%data-ship [~.p 0]]
                              [%data-agent [~.ta '/test-agent']]
                              [%data-tmsp [~.da ~2000.1.5]]
                              ==
                      :-  %vector
                          :~  [%database [~.tas %db1]]
                              [%sys-agent [~.ta '/test-agent']]
                              [%sys-tmsp [~.da ~2000.1.2]]
                              [%data-ship [~.p 0]]
                              [%data-agent [~.ta '/test-agent']]
                              [%data-tmsp [~.da ~2000.1.2]]
                              ==
                      :-  %vector
                          :~  [%database [~.tas %db1]]
                              [%sys-agent [~.ta '/test-agent']]
                              [%sys-tmsp [~.da ~2000.1.6]]
                              [%data-ship [~.p 0]]
                              [%data-agent [~.ta '/test-agent']]
                              [%data-tmsp [~.da ~2000.1.6]]
                              ==
                      :-  %vector
                          :~  [%database [~.tas %db1]]
                              [%sys-agent [~.ta '/test-agent']]
                              [%sys-tmsp [~.da ~2000.1.2]]
                              [%data-ship [~.p 0]]
                              [%data-agent [~.ta '/test-agent']]
                              [%data-tmsp [~.da ~2000.1.3]]
                              ==
                      :-  %vector
                          :~  [%database [~.tas %sys]]
                              [%sys-agent [~.ta '/test-agent']]
                              [%sys-tmsp [~.da ~2000.1.1]]
                              [%data-ship [~.p 0]]
                              [%data-agent [~.ta '/test-agent']]
                              [%data-tmsp [~.da ~2000.1.1]]
                              ==
                      :-  %vector
                          :~  [%database [~.tas %db1]]
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
              [%server-time ~2000.1.7]
              [%message 'sys.sys.databases']
              [%schema-time ~2000.1.1]
              [%data-time ~2000.1.6]
              [%vector-count 7]
              ==
      ==
::
++  test-sys-databases-03  ::  DROP DATABASE not idempotent
  =|  run=@ud
  %-  exec-5-2-68
  :*  run
      [~2000.1.1 %sys "CREATE DATABASE db1"]
      ::
      :+  ~2000.1.2
          %db1
          "CREATE TABLE db1..my-table (col1 @t) PRIMARY KEY (col1)"
      ::
      [~2000.1.3 %db1 "INSERT INTO db1..my-table (col1) VALUES ('cord')"]
      ::
      [~2000.1.4 %sys "CREATE DATABASE db2"]
      ::
      :+  ~2000.1.5
          %db1
          "CREATE TABLE db2..my-table (col1 @t) PRIMARY KEY (col1)"
      ::
      [~2000.1.6 %db1 "FROM sys.sys.databases SELECT *"]
      ::
      [~2000.1.7 %db1 "DROP DATABASE FORCE db1"]
      ::
      :+  ~2000.1.8
          %db1
          "FROM sys.sys.databases AS OF ~2000.1.6 SELECT *"
      ::
      :-  %results
          :~  [%message 'SELECT']
              :-  %result-set
                  :~  :-  %vector
                          :~  [%database [~.tas %db2]]
                              [%sys-agent [~.ta '/test-agent']]
                              [%sys-tmsp [~.da ~2000.1.5]]
                              [%data-ship [~.p 0]]
                              [%data-agent [~.ta '/test-agent']]
                              [%data-tmsp [~.da ~2000.1.5]]
                              ==
                      :-  %vector
                          :~  [%database [~.tas %db1]]
                              [%sys-agent [~.ta '/test-agent']]
                              [%sys-tmsp [~.da ~2000.1.2]]
                              [%data-ship [~.p 0]]
                              [%data-agent [~.ta '/test-agent']]
                              [%data-tmsp [~.da ~2000.1.2]]
                              ==
                      :-  %vector
                          :~  [%database [~.tas %db1]]
                              [%sys-agent [~.ta '/test-agent']]
                              [%sys-tmsp [~.da ~2000.1.2]]
                              [%data-ship [~.p 0]]
                              [%data-agent [~.ta '/test-agent']]
                              [%data-tmsp [~.da ~2000.1.3]]
                              ==
                      :-  %vector
                          :~  [%database [~.tas %sys]]
                              [%sys-agent [~.ta '/test-agent']]
                              [%sys-tmsp [~.da ~2000.1.1]]
                              [%data-ship [~.p 0]]
                              [%data-agent [~.ta '/test-agent']]
                              [%data-tmsp [~.da ~2000.1.1]]
                              ==
                      :-  %vector
                          :~  [%database [~.tas %db1]]
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
              [%data-time ~2000.1.5]
              [%vector-count 6]
              ==
      ::
      :-  %results
          :~  [%message 'SELECT']
              :-  %result-set
                  :~  :-  %vector
                          :~  [%database [~.tas %db2]]
                              [%sys-agent [~.ta '/test-agent']]
                              [%sys-tmsp [~.da ~2000.1.5]]
                              [%data-ship [~.p 0]]
                              [%data-agent [~.ta '/test-agent']]
                              [%data-tmsp [~.da ~2000.1.5]]
                              ==
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
              [%server-time ~2000.1.8]
              [%message 'sys.sys.databases']
              [%schema-time ~2000.1.1]
              [%data-time ~2000.1.5]
              [%vector-count 3]
              ==
      ==
::
++  test-sys-databases-04  ::  TRUNCATE TABLE (data present)
  =|  run=@ud
  %-  exec-5-1
  :*  run
      [~2000.1.1 %sys "CREATE DATABASE db1"]
      ::
      :+  ~2000.1.2
          %db1
          "CREATE TABLE db1..my-table (col1 @t) PRIMARY KEY (col1)"
      ::
      [~2000.1.3 %db1 "INSERT INTO db1..my-table (col1) VALUES ('cord')"]
      ::
      [~2000.1.4 %sys "CREATE DATABASE db2"]
      ::
      :+  ~2000.1.5
          %db1
          "CREATE TABLE db2..my-table (col1 @t) PRIMARY KEY (col1)"
      ::
      [~2000.1.6 %db1 "TRUNCATE TABLE db1..my-table"]
      ::
      [~2000.1.7 %db1 "FROM sys.sys.databases SELECT *"]
      ::
      :-  %results
          :~  [%message 'SELECT']
              :-  %result-set
                  :~  :-  %vector
                          :~  [%database [~.tas %db2]]
                              [%sys-agent [~.ta '/test-agent']]
                              [%sys-tmsp [~.da ~2000.1.5]]
                              [%data-ship [~.p 0]]
                              [%data-agent [~.ta '/test-agent']]
                              [%data-tmsp [~.da ~2000.1.5]]
                              ==
                      :-  %vector
                          :~  [%database [~.tas %db1]]
                              [%sys-agent [~.ta '/test-agent']]
                              [%sys-tmsp [~.da ~2000.1.2]]
                              [%data-ship [~.p 0]]
                              [%data-agent [~.ta '/test-agent']]
                              [%data-tmsp [~.da ~2000.1.2]]
                              ==
                      :-  %vector
                          :~  [%database [~.tas %db1]]
                              [%sys-agent [~.ta '/test-agent']]
                              [%sys-tmsp [~.da ~2000.1.2]]
                              [%data-ship [~.p 0]]
                              [%data-agent [~.ta '/test-agent']]
                              [%data-tmsp [~.da ~2000.1.6]]
                              ==
                      :-  %vector
                          :~  [%database [~.tas %db1]]
                              [%sys-agent [~.ta '/test-agent']]
                              [%sys-tmsp [~.da ~2000.1.2]]
                              [%data-ship [~.p 0]]
                              [%data-agent [~.ta '/test-agent']]
                              [%data-tmsp [~.da ~2000.1.3]]
                              ==
                      :-  %vector
                          :~  [%database [~.tas %sys]]
                              [%sys-agent [~.ta '/test-agent']]
                              [%sys-tmsp [~.da ~2000.1.1]]
                              [%data-ship [~.p 0]]
                              [%data-agent [~.ta '/test-agent']]
                              [%data-tmsp [~.da ~2000.1.1]]
                              ==
                      :-  %vector
                          :~  [%database [~.tas %db1]]
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
              [%server-time ~2000.1.7]
              [%message 'sys.sys.databases']
              [%schema-time ~2000.1.1]
              [%data-time ~2000.1.6]
              [%vector-count 7]
              ==
      ==
::
++  test-sys-databases-05  ::  TRUNCATE TABLE (no data present)
  =|  run=@ud
  %-  exec-5-1
  :*  run
      [~2000.1.1 %sys "CREATE DATABASE db1"]
      ::
      :+  ~2000.1.2
          %db1
          "CREATE TABLE db1..my-table (col1 @t) PRIMARY KEY (col1)"
      ::
      [~2000.1.3 %db1 "INSERT INTO db1..my-table (col1) VALUES ('cord')"]
      ::
      [~2000.1.4 %sys "CREATE DATABASE db2"]
      ::
      :+  ~2000.1.5
          %db1
          "CREATE TABLE db2..my-table (col1 @t) PRIMARY KEY (col1)"
      ::
      [~2000.1.6 %db1 "TRUNCATE TABLE db2..my-table"]
      ::
      [~2000.1.7 %db1 "FROM sys.sys.databases SELECT *"]
      ::
      :-  %results
          :~  [%message 'SELECT']
              :-  %result-set
                  :~  :-  %vector
                          :~  [%database [~.tas %db2]]
                              [%sys-agent [~.ta '/test-agent']]
                              [%sys-tmsp [~.da ~2000.1.5]]
                              [%data-ship [~.p 0]]
                              [%data-agent [~.ta '/test-agent']]
                              [%data-tmsp [~.da ~2000.1.5]]
                              ==
                      :-  %vector
                          :~  [%database [~.tas %db1]]
                              [%sys-agent [~.ta '/test-agent']]
                              [%sys-tmsp [~.da ~2000.1.2]]
                              [%data-ship [~.p 0]]
                              [%data-agent [~.ta '/test-agent']]
                              [%data-tmsp [~.da ~2000.1.2]]
                              ==
                      :-  %vector
                          :~  [%database [~.tas %db1]]
                              [%sys-agent [~.ta '/test-agent']]
                              [%sys-tmsp [~.da ~2000.1.2]]
                              [%data-ship [~.p 0]]
                              [%data-agent [~.ta '/test-agent']]
                              [%data-tmsp [~.da ~2000.1.3]]
                              ==
                      :-  %vector
                          :~  [%database [~.tas %sys]]
                              [%sys-agent [~.ta '/test-agent']]
                              [%sys-tmsp [~.da ~2000.1.1]]
                              [%data-ship [~.p 0]]
                              [%data-agent [~.ta '/test-agent']]
                              [%data-tmsp [~.da ~2000.1.1]]
                              ==
                      :-  %vector
                          :~  [%database [~.tas %db1]]
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
              [%server-time ~2000.1.7]
              [%message 'sys.sys.databases']
              [%schema-time ~2000.1.1]
              [%data-time ~2000.1.5]
              [%vector-count 6]
              ==
      ==
::
++  test-sys-databases-06  ::  INSERT
  =|  run=@ud
  %-  exec-2-1
  :*  run
      [~2000.1.1 %sys "CREATE DATABASE db1"]
      ::
      :+  ~2000.1.2
          %db1
          "CREATE TABLE db1..my-table (col1 @t) PRIMARY KEY (col1)"
      ::
      [~2000.1.3 %db1 "INSERT INTO db1..my-table (col1) VALUES ('cord')"]
      ::
      [~2000.1.7 %db1 "FROM sys.sys.databases SELECT *"]
      ::
      :-  %results
          :~  [%message 'SELECT']
              :-  %result-set
                  :~  :-  %vector
                          :~  [%database [~.tas %db1]]
                              [%sys-agent [~.ta '/test-agent']]
                              [%sys-tmsp [~.da ~2000.1.2]]
                              [%data-ship [~.p 0]]
                              [%data-agent [~.ta '/test-agent']]
                              [%data-tmsp [~.da ~2000.1.2]]
                              ==
                      :-  %vector
                          :~  [%database [~.tas %db1]]
                              [%sys-agent [~.ta '/test-agent']]
                              [%sys-tmsp [~.da ~2000.1.2]]
                              [%data-ship [~.p 0]]
                              [%data-agent [~.ta '/test-agent']]
                              [%data-tmsp [~.da ~2000.1.3]]
                              ==
                      :-  %vector
                          :~  [%database [~.tas %sys]]
                              [%sys-agent [~.ta '/test-agent']]
                              [%sys-tmsp [~.da ~2000.1.1]]
                              [%data-ship [~.p 0]]
                              [%data-agent [~.ta '/test-agent']]
                              [%data-tmsp [~.da ~2000.1.1]]
                              ==
                      :-  %vector
                          :~  [%database [~.tas %db1]]
                              [%sys-agent [~.ta '/test-agent']]
                              [%sys-tmsp [~.da ~2000.1.1]]
                              [%data-ship [~.p 0]]
                              [%data-agent [~.ta '/test-agent']]
                              [%data-tmsp [~.da ~2000.1.1]]
                              ==
                      ==
              [%server-time ~2000.1.7]
              [%message 'sys.sys.databases']
              [%schema-time ~2000.1.1]
              [%data-time ~2000.1.3]
              [%vector-count 4]
              ==
      ==
::
::  sys.namespaces
::
::  Test Cases: CREATE or DROP NAMESPACE
::
++  test-sys-namspaces-01
  =|  run=@ud
  %-  exec-1-2
  :*  run
      [~2000.1.1 %sys "CREATE DATABASE db1 AS OF ~2000.1.1"]
      ::
      :+  ~2000.1.2
          %db1
          "CREATE NAMESPACE ns1 AS OF ~2000.1.2"
      ::
      [~2000.1.2 %db1 "FROM sys.namespaces SELECT *"]
      ::
      :+  ~2000.1.3
          %db1
          "FROM sys.namespaces AS OF ~2000.1.1..1.1.1 SELECT *"
      ::
      :-  %results
          :~  [%message 'SELECT']
              :-  %result-set
                  :~  :-  %vector
                          :~  [%namespace [~.tas %dbo]]
                              [%tmsp [~.da ~2000.1.1]]
                              ==
                      :-  %vector
                          :~  [%namespace [~.tas %ns1]]
                              [%tmsp [~.da ~2000.1.2]]
                              ==
                      :-  %vector
                          :~  [%namespace [~.tas %sys]]
                              [%tmsp [~.da ~2000.1.1]]
                              ==
                      ==
              [%server-time ~2000.1.2]
              [%message 'db1.sys.namespaces']
              [%schema-time ~2000.1.2]
              [%data-time ~2000.1.2]
              [%vector-count 3]
              ==
      ::
      :-  %results
          :~  [%message 'SELECT']
              :-  %result-set
                  :~  :-  %vector
                          :~  [%namespace [~.tas %dbo]]
                              [%tmsp [~.da ~2000.1.1]]
                              ==
                      :-  %vector
                          :~  [%namespace [~.tas %sys]]
                              [%tmsp [~.da ~2000.1.1]]
                              ==
                      ==
              [%server-time ~2000.1.3]
              [%message 'db1.sys.namespaces']
              [%schema-time ~2000.1.1]
              [%data-time ~2000.1.1]
              [%vector-count 2]
              ==
      ==
::
::  sys-namespaces not default DB
++  test-sys-namspaces-02
  =|  run=@ud
  %-  exec-2-1
  :*  run
      [~1999.12.31 %sys "CREATE DATABASE db1"]
      ::
      [~2000.1.1 %sys "CREATE DATABASE db2"]
      ::
      :+  ~2000.1.2
          %db2
          "CREATE NAMESPACE ns1"
      ::
      [~2000.1.2 %db1 "FROM db2.sys.namespaces SELECT *"]
      ::
      :-  %results
          :~  [%message 'SELECT']
              :-  %result-set
                  :~  :-  %vector
                          :~  [%namespace [~.tas %dbo]]
                              [%tmsp [~.da ~2000.1.1]]
                              ==
                      :-  %vector
                          :~  [%namespace [~.tas %ns1]]
                              [%tmsp [~.da ~2000.1.2]]
                              ==
                      :-  %vector
                          :~  [%namespace [~.tas %sys]]
                              [%tmsp [~.da ~2000.1.1]]
                              ==
                      ==
              [%server-time ~2000.1.2]
              [%message 'db2.sys.namespaces']
              [%schema-time ~2000.1.2]
              [%data-time ~2000.1.2]
              [%vector-count 3]
              ==
      ==
::
::  sys.tables and sys.table-keys
::
::  Test Cases: CREATE, ALTER, DROP TABLE
::              INSERT, DELETE
::              TRUNCATE TABLE (data present/not present)
::
++  test-sys-tables-and-keys-01  ::  CREATE TABLE
  =|  run=@ud
  %-  exec-6-4
  :*  run
      [~2000.1.1 %sys "CREATE DATABASE db1"]
      ::
      :+  ~2000.1.2
          %db1
          "CREATE TABLE db1..my-table (col1 @t, col2 @t) ".
          "PRIMARY KEY (col1, col2 DESC)"
      ::
      :+  ~2000.1.3
          %db1
          "INSERT INTO db1..my-table (col1, col2) ".
          "VALUES ('cord', 'cord2')"
      ::
      :+  ~2000.1.4
          %db1
          "CREATE TABLE db1..my-table-2 (col1 @p, col2 @t) ".
          "PRIMARY KEY (col1 desc, col2); ".
          "CREATE TABLE db1..my-table-3 (col1 @p, col2 @t, col3 @ud) ".
          "PRIMARY KEY (col1)"
      ::
      [~2000.1.5 %db1 "CREATE NAMESPACE ref"]
      ::
      :+  ~2000.1.6
          %db1
          "CREATE TABLE db1..my-table-4 (col1 @p, col2 @t, col3 @ud) ".
          "PRIMARY KEY (col1, col3)"
      ::
      :+  ~2000.1.7
          %db1
          "CREATE TABLE db1.ref.my-table-4 (col1 @p, col2 @t, col3 @ud) ".
          "PRIMARY KEY (col1, col3)"
      ::
      [~2000.1.8 %db1 "FROM sys.tables SELECT *"]
      ::
      [~2000.1.9 %db1 "FROM sys.tables AS OF ~2000.1.6 SELECT *"]
      ::
      [~2000.1.8 %db1 "FROM sys.table-keys SELECT *"]
      ::
      [~2000.1.9 %db1 "FROM sys.table-keys AS OF ~2000.1.6 SELECT *"]
      ::
      :-  %results
          :~  [%message 'SELECT']
              :-  %result-set
                  :~  :-  %vector
                          :~  [%namespace [~.tas %dbo]]
                              [%name [~.tas %my-table]]
                              [%agent [~.ta '/test-agent']]
                              [%tmsp [~.da ~2000.1.2]]
                              [%row-count [~.ud 1]]
                              ==
                      :-  %vector
                          :~  [%namespace [~.tas %ref]]
                              [%name [~.tas %my-table-4]]
                              [%agent [~.ta '/test-agent']]
                              [%tmsp [~.da ~2000.1.7]]
                              [%row-count [~.ud 0]]
                              ==
                      :-  %vector
                          :~  [%namespace [~.tas %dbo]]
                              [%name [~.tas %my-table-4]]
                              [%agent [~.ta '/test-agent']]
                              [%tmsp [~.da ~2000.1.6]]
                              [%row-count [~.ud 0]]
                              ==
                      :-  %vector
                          :~  [%namespace [~.tas %dbo]]
                              [%name [~.tas %my-table-3]]
                              [%agent [~.ta '/test-agent']]
                              [%tmsp [~.da ~2000.1.4]]
                              [%row-count [~.ud 0]]
                              ==
                      :-  %vector
                          :~  [%namespace [~.tas %dbo]]
                              [%name [~.tas %my-table-2]]
                              [%agent [~.ta '/test-agent']]
                              [%tmsp [~.da ~2000.1.4]]
                              [%row-count [~.ud 0]]
                              ==
                      ==
              [%server-time ~2000.1.8]
              [%message 'db1.sys.tables']
              [%schema-time ~2000.1.7]
              [%data-time ~2000.1.7]
              [%vector-count 5]
              ==
      ::
      :-  %results
          :~  [%message 'SELECT']
              :-  %result-set
                  :~  :-  %vector
                          :~  [%namespace [~.tas %dbo]]
                              [%name [~.tas %my-table]]
                              [%agent [~.ta '/test-agent']]
                              [%tmsp [~.da ~2000.1.2]]
                              [%row-count [~.ud 1]]
                              ==
                      :-  %vector
                          :~  [%namespace [~.tas %dbo]]
                              [%name [~.tas %my-table-4]]
                              [%agent [~.ta '/test-agent']]
                              [%tmsp [~.da ~2000.1.6]]
                              [%row-count [~.ud 0]]
                              ==
                      :-  %vector
                          :~  [%namespace [~.tas %dbo]]
                              [%name [~.tas %my-table-3]]
                              [%agent [~.ta '/test-agent']]
                              [%tmsp [~.da ~2000.1.4]]
                              [%row-count [~.ud 0]]
                              ==
                      :-  %vector
                          :~  [%namespace [~.tas %dbo]]
                              [%name [~.tas %my-table-2]]
                              [%agent [~.ta '/test-agent']]
                              [%tmsp [~.da ~2000.1.4]]
                              [%row-count [~.ud 0]]
                              ==
                      ==
              [%server-time ~2000.1.9]
              [%message 'db1.sys.tables']
              [%schema-time ~2000.1.6]
              [%data-time ~2000.1.6]
              [%vector-count 4]
              ==
      ::
      :-  %results
          :~  [%message 'SELECT']
              :-  %result-set
                  :~  :-  %vector
                          :~  [%namespace [~.tas %dbo]]
                              [%name [~.tas %my-table]]
                              [%key-ordinal [~.ud 1]]
                              [%key [~.tas %col1]]
                              [%key-ascending [~.f 0]]
                              ==
                      :-  %vector
                          :~  [%namespace [~.tas %ref]]
                              [%name [~.tas %my-table-4]]
                              [%key-ordinal [~.ud 2]]
                              [%key [~.tas %col3]]
                              [%key-ascending [~.f 0]]
                              ==
                      :-  %vector
                          :~  [%namespace [~.tas %dbo]]
                              [%name [~.tas %my-table-4]]
                              [%key-ordinal [~.ud 2]]
                              [%key [~.tas %col3]]
                              [%key-ascending [~.f 0]]
                              ==
                      :-  %vector
                          :~  [%namespace [~.tas %dbo]]
                              [%name [~.tas %my-table]]
                              [%key-ordinal [~.ud 2]]
                              [%key [~.tas %col2]]
                              [%key-ascending [~.f 1]]
                              ==
                      :-  %vector
                          :~  [%namespace [~.tas %dbo]]
                              [%name [~.tas %my-table-3]]
                              [%key-ordinal [~.ud 1]]
                              [%key [~.tas %col1]]
                              [%key-ascending [~.f 0]]
                              ==
                      :-  %vector
                          :~  [%namespace [~.tas %dbo]]
                              [%name [~.tas %my-table-2]]
                              [%key-ordinal [~.ud 2]]
                              [%key [~.tas %col2]]
                              [%key-ascending [~.f 0]]
                              ==
                      :-  %vector
                          :~  [%namespace [~.tas %ref]]
                              [%name [~.tas %my-table-4]]
                              [%key-ordinal [~.ud 1]]
                              [%key [~.tas %col1]]
                              [%key-ascending [~.f 0]]
                              ==
                      :-  %vector
                          :~  [%namespace [~.tas %dbo]]
                              [%name [~.tas %my-table-4]]
                              [%key-ordinal [~.ud 1]]
                              [%key [~.tas %col1]]
                              [%key-ascending [~.f 0]]
                              ==
                      :-  %vector
                          :~  [%namespace [~.tas %dbo]]
                              [%name [~.tas %my-table-2]]
                              [%key-ordinal [~.ud 1]]
                              [%key [~.tas %col1]]
                              [%key-ascending [~.f 1]]
                              ==
                      ==
              [%server-time ~2000.1.8]
              [%message 'db1.sys.table-keys']
              [%schema-time ~2000.1.7]
              [%data-time ~2000.1.7]
              [%vector-count 9]
              ==
      ::
      :-  %results
          :~  [%message 'SELECT']
              :-  %result-set
                  :~  :-  %vector
                          :~  [%namespace [~.tas %dbo]]
                              [%name [~.tas %my-table]]
                              [%key-ordinal [~.ud 1]]
                              [%key [~.tas %col1]]
                              [%key-ascending [~.f 0]]
                              ==
                      :-  %vector
                          :~  [%namespace [~.tas %dbo]]
                              [%name [~.tas %my-table-4]]
                              [%key-ordinal [~.ud 2]]
                              [%key [~.tas %col3]]
                              [%key-ascending [~.f 0]]
                              ==
                      :-  %vector
                          :~  [%namespace [~.tas %dbo]]
                              [%name [~.tas %my-table]]
                              [%key-ordinal [~.ud 2]]
                              [%key [~.tas %col2]]
                              [%key-ascending [~.f 1]]
                              ==
                      :-  %vector
                          :~  [%namespace [~.tas %dbo]]
                              [%name [~.tas %my-table-3]]
                              [%key-ordinal [~.ud 1]]
                              [%key [~.tas %col1]]
                              [%key-ascending [~.f 0]]
                              ==
                      :-  %vector
                          :~  [%namespace [~.tas %dbo]]
                              [%name [~.tas %my-table-2]]
                              [%key-ordinal [~.ud 2]]
                              [%key [~.tas %col2]]
                              [%key-ascending [~.f 0]]
                              ==
                      :-  %vector
                          :~  [%namespace [~.tas %dbo]]
                              [%name [~.tas %my-table-4]]
                              [%key-ordinal [~.ud 1]]
                              [%key [~.tas %col1]]
                              [%key-ascending [~.f 0]]
                              ==
                      :-  %vector
                          :~  [%namespace [~.tas %dbo]]
                              [%name [~.tas %my-table-2]]
                              [%key-ordinal [~.ud 1]]
                              [%key [~.tas %col1]]
                              [%key-ascending [~.f 1]]
                              ==
                      ==
              [%server-time ~2000.1.9]
              [%message 'db1.sys.table-keys']
              [%schema-time ~2000.1.6]
              [%data-time ~2000.1.6]
              [%vector-count 7]
              ==
      ==
::
++  test-sys-tables-and-keys-02  ::  INSERT and DROP TABLE
  =|  run=@ud
  %-  exec-7-6
  :*  run
      [~2000.1.1 %sys "CREATE DATABASE db1"]
      ::
      :+  ~2000.1.2
          %db1
          "CREATE TABLE db1..my-table (col1 @t, col2 @t) ".
          "PRIMARY KEY (col1, col2 DESC)"
      ::
      :+  ~2000.1.3
          %db1
          "INSERT INTO db1..my-table (col1, col2) ".
          "VALUES ('cord', 'cord2')"
      ::
      :+  ~2000.1.4
          %db1
          "CREATE TABLE db1..my-table-2 (col1 @p, col2 @t) ".
          "PRIMARY KEY (col1 desc, col2); ".
          "CREATE TABLE db1..my-table-3 (col1 @p, col2 @t, col3 @ud) ".
          "PRIMARY KEY (col1)"
      ::
      [~2000.1.5 %db1 "CREATE NAMESPACE ref"]
      ::
      :+  ~2000.1.6
          %db1
          "CREATE TABLE db1..my-table-4 (col1 @p, col2 @t, col3 @ud) ".
          "PRIMARY KEY (col1, col3)"
      ::
      :+  ~2000.1.7
          %db1
          "CREATE TABLE db1.ref.my-table-4 (col1 @p, col2 @t, col3 @ud) ".
          "PRIMARY KEY (col1, col3)"
      ::
      [~2000.1.8 %db1 "DROP TABLE db1.ref.my-table-4"]
      ::
      [~2000.1.9 %db1 "FROM sys.tables SELECT *"]
      ::
      [~2000.1.10 %db1 "FROM sys.tables AS OF ~2000.1.7 SELECT *"]
      ::
      [~2000.1.11 %db1 "FROM sys.tables AS OF ~2000.1.2 SELECT *"]
      ::
      [~2000.1.9 %db1 "FROM sys.table-keys SELECT *"]
      ::
      [~2000.1.10 %db1 "FROM sys.table-keys AS OF ~2000.1.7 SELECT *"]
      ::
      [~2000.1.11 %db1 "FROM sys.table-keys AS OF ~2000.1.2 SELECT *"]
      ::
      :-  %results
          :~  [%message 'SELECT']
              :-  %result-set
                  :~  :-  %vector
                          :~  [%namespace [~.tas %dbo]]
                              [%name [~.tas %my-table]]
                              [%agent [~.ta '/test-agent']]
                              [%tmsp [~.da ~2000.1.2]]
                              [%row-count [~.ud 1]]
                              ==
                      :-  %vector
                          :~  [%namespace [~.tas %dbo]]
                              [%name [~.tas %my-table-4]]
                              [%agent [~.ta '/test-agent']]
                              [%tmsp [~.da ~2000.1.6]]
                              [%row-count [~.ud 0]]
                              ==
                      :-  %vector
                          :~  [%namespace [~.tas %dbo]]
                              [%name [~.tas %my-table-3]]
                              [%agent [~.ta '/test-agent']]
                              [%tmsp [~.da ~2000.1.4]]
                              [%row-count [~.ud 0]]
                              ==
                      :-  %vector
                          :~  [%namespace [~.tas %dbo]]
                              [%name [~.tas %my-table-2]]
                              [%agent [~.ta '/test-agent']]
                              [%tmsp [~.da ~2000.1.4]]
                              [%row-count [~.ud 0]]
                              ==
                      ==
              [%server-time ~2000.1.9]
              [%message 'db1.sys.tables']
              [%schema-time ~2000.1.8]
              [%data-time ~2000.1.8]
              [%vector-count 4]
              ==
      ::
      :-  %results
          :~  [%message 'SELECT']
              :-  %result-set
                  :~  :-  %vector
                          :~  [%namespace [~.tas %dbo]]
                              [%name [~.tas %my-table]]
                              [%agent [~.ta '/test-agent']]
                              [%tmsp [~.da ~2000.1.2]]
                              [%row-count [~.ud 1]]
                              ==
                      :-  %vector
                          :~  [%namespace [~.tas %ref]]
                              [%name [~.tas %my-table-4]]
                              [%agent [~.ta '/test-agent']]
                              [%tmsp [~.da ~2000.1.7]]
                              [%row-count [~.ud 0]]
                              ==
                      :-  %vector
                          :~  [%namespace [~.tas %dbo]]
                              [%name [~.tas %my-table-4]]
                              [%agent [~.ta '/test-agent']]
                              [%tmsp [~.da ~2000.1.6]]
                              [%row-count [~.ud 0]]
                              ==
                      :-  %vector
                          :~  [%namespace [~.tas %dbo]]
                              [%name [~.tas %my-table-3]]
                              [%agent [~.ta '/test-agent']]
                              [%tmsp [~.da ~2000.1.4]]
                              [%row-count [~.ud 0]]
                              ==
                      :-  %vector
                          :~  [%namespace [~.tas %dbo]]
                              [%name [~.tas %my-table-2]]
                              [%agent [~.ta '/test-agent']]
                              [%tmsp [~.da ~2000.1.4]]
                              [%row-count [~.ud 0]]
                              ==
                      ==
              [%server-time ~2000.1.10]
              [%message 'db1.sys.tables']
              [%schema-time ~2000.1.7]
              [%data-time ~2000.1.7]
              [%vector-count 5]
              ==
      ::
      :-  %results
          :~  [%message 'SELECT']
              :-  %result-set
                  :~  :-  %vector
                          :~  [%namespace [~.tas %dbo]]
                              [%name [~.tas %my-table]]
                              [%agent [~.ta '/test-agent']]
                              [%tmsp [~.da ~2000.1.2]]
                              [%row-count [~.ud 0]]
                              ==
                      ==
              [%server-time ~2000.1.11]
              [%message 'db1.sys.tables']
              [%schema-time ~2000.1.2]
              [%data-time ~2000.1.2]
              [%vector-count 1]
              ==
      ::
      :-  %results
          :~  [%message 'SELECT']
              :-  %result-set
                  :~  :-  %vector
                          :~  [%namespace [~.tas %dbo]]
                              [%name [~.tas %my-table]]
                              [%key-ordinal [~.ud 1]]
                              [%key [~.tas %col1]]
                              [%key-ascending [~.f 0]]
                              ==
                      :-  %vector
                          :~  [%namespace [~.tas %dbo]]
                              [%name [~.tas %my-table-4]]
                              [%key-ordinal [~.ud 2]]
                              [%key [~.tas %col3]]
                              [%key-ascending [~.f 0]]
                              ==
                      :-  %vector
                          :~  [%namespace [~.tas %dbo]]
                              [%name [~.tas %my-table]]
                              [%key-ordinal [~.ud 2]]
                              [%key [~.tas %col2]]
                              [%key-ascending [~.f 1]]
                              ==
                      :-  %vector
                          :~  [%namespace [~.tas %dbo]]
                              [%name [~.tas %my-table-3]]
                              [%key-ordinal [~.ud 1]]
                              [%key [~.tas %col1]]
                              [%key-ascending [~.f 0]]
                              ==
                      :-  %vector
                          :~  [%namespace [~.tas %dbo]]
                              [%name [~.tas %my-table-2]]
                              [%key-ordinal [~.ud 2]]
                              [%key [~.tas %col2]]
                              [%key-ascending [~.f 0]]
                              ==
                      :-  %vector
                          :~  [%namespace [~.tas %dbo]]
                              [%name [~.tas %my-table-4]]
                              [%key-ordinal [~.ud 1]]
                              [%key [~.tas %col1]]
                              [%key-ascending [~.f 0]]
                              ==
                      :-  %vector
                          :~  [%namespace [~.tas %dbo]]
                              [%name [~.tas %my-table-2]]
                              [%key-ordinal [~.ud 1]]
                              [%key [~.tas %col1]]
                              [%key-ascending [~.f 1]]
                              ==
                      ==
              [%server-time ~2000.1.9]
              [%message 'db1.sys.table-keys']
              [%schema-time ~2000.1.8]
              [%data-time ~2000.1.8]
              [%vector-count 7]
              ==
      ::
      :-  %results
          :~  [%message 'SELECT']
              :-  %result-set
                  :~  :-  %vector
                          :~  [%namespace [~.tas %dbo]]
                              [%name [~.tas %my-table]]
                              [%key-ordinal [~.ud 1]]
                              [%key [~.tas %col1]]
                              [%key-ascending [~.f 0]]
                              ==
                      :-  %vector
                          :~  [%namespace [~.tas %ref]]
                              [%name [~.tas %my-table-4]]
                              [%key-ordinal [~.ud 2]]
                              [%key [~.tas %col3]]
                              [%key-ascending [~.f 0]]
                              ==
                      :-  %vector
                          :~  [%namespace [~.tas %dbo]]
                              [%name [~.tas %my-table-4]]
                              [%key-ordinal [~.ud 2]]
                              [%key [~.tas %col3]]
                              [%key-ascending [~.f 0]]
                              ==
                      :-  %vector
                          :~  [%namespace [~.tas %dbo]]
                              [%name [~.tas %my-table]]
                              [%key-ordinal [~.ud 2]]
                              [%key [~.tas %col2]]
                              [%key-ascending [~.f 1]]
                              ==
                      :-  %vector
                          :~  [%namespace [~.tas %dbo]]
                              [%name [~.tas %my-table-3]]
                              [%key-ordinal [~.ud 1]]
                              [%key [~.tas %col1]]
                              [%key-ascending [~.f 0]]
                              ==
                      :-  %vector
                          :~  [%namespace [~.tas %dbo]]
                              [%name [~.tas %my-table-2]]
                              [%key-ordinal [~.ud 2]]
                              [%key [~.tas %col2]]
                              [%key-ascending [~.f 0]]
                              ==
                      :-  %vector
                          :~  [%namespace [~.tas %ref]]
                              [%name [~.tas %my-table-4]]
                              [%key-ordinal [~.ud 1]]
                              [%key [~.tas %col1]]
                              [%key-ascending [~.f 0]]
                              ==
                      :-  %vector
                          :~  [%namespace [~.tas %dbo]]
                              [%name [~.tas %my-table-4]]
                              [%key-ordinal [~.ud 1]]
                              [%key [~.tas %col1]]
                              [%key-ascending [~.f 0]]
                              ==
                      :-  %vector
                          :~  [%namespace [~.tas %dbo]]
                              [%name [~.tas %my-table-2]]
                              [%key-ordinal [~.ud 1]]
                              [%key [~.tas %col1]]
                              [%key-ascending [~.f 1]]
                              ==
                      ==
              [%server-time ~2000.1.10]
              [%message 'db1.sys.table-keys']
              [%schema-time ~2000.1.7]
              [%data-time ~2000.1.7]
              [%vector-count 9]
              ==
      ::
      :-  %results
          :~  [%message 'SELECT']
              :-  %result-set
                  :~  :-  %vector
                          :~  [%namespace [~.tas %dbo]]
                              [%name [~.tas %my-table]]
                              [%key-ordinal [~.ud 1]]
                              [%key [~.tas %col1]]
                              [%key-ascending [~.f 0]]
                          ==
                  :-  %vector
                      :~  [%namespace [~.tas %dbo]]
                          [%name [~.tas %my-table]]
                          [%key-ordinal [~.ud 2]]
                          [%key [~.tas %col2]]
                          [%key-ascending [~.f 1]]
                          ==
                  ==
          [%server-time ~2000.1.11]
          [%message 'db1.sys.table-keys']
          [%schema-time ~2000.1.2]
          [%data-time ~2000.1.2]
          [%vector-count 2]
          ==
  ==
::
++  test-sys-tables-and-keys-03  ::  TRUNCATE TABLE  (data present)
  =|  run=@ud
  %-  exec-7-2
  :*  run
      [~2000.1.1 %sys "CREATE DATABASE db1"]
      ::
      :+  ~2000.1.2
          %db1
          "CREATE TABLE db1..my-table (col1 @t, col2 @t) ".
          "PRIMARY KEY (col1, col2 DESC)"
      ::
      :+  ~2000.1.3
          %db1
          "INSERT INTO db1..my-table (col1, col2) ".
          "VALUES ('cord', 'cord2')"
      ::
      :+  ~2000.1.4
          %db1
          "CREATE TABLE db1..my-table-2 (col1 @p, col2 @t) ".
          "PRIMARY KEY (col1 desc, col2); ".
          "CREATE TABLE db1..my-table-3 (col1 @p, col2 @t, col3 @ud) ".
          "PRIMARY KEY (col1)"
      ::
      [~2000.1.5 %db1 "CREATE NAMESPACE ref"]
      ::
      :+  ~2000.1.6
          %db1
          "CREATE TABLE db1..my-table-4 (col1 @p, col2 @t, col3 @ud) ".
          "PRIMARY KEY (col1, col3)"
      ::
      :+  ~2000.1.7
          %db1
          "CREATE TABLE db1.ref.my-table-4 (col1 @p, col2 @t, col3 @ud) ".
          "PRIMARY KEY (col1, col3)"
      ::
      [~2000.1.8 %db1 "TRUNCATE TABLE db1..my-table"]
      ::
      [~2000.1.9 %db1 "FROM sys.tables SELECT *"]
      ::
      [~2000.1.9 %db1 "FROM sys.table-keys SELECT *"]
      ::
      :-  %results
          :~  [%message 'SELECT']
              :-  %result-set
                  :~  :-  %vector
                          :~  [%namespace [~.tas %dbo]]
                              [%name [~.tas %my-table]]
                              [%agent [~.ta '/test-agent']]
                              [%tmsp [~.da ~2000.1.2]]
                              [%row-count [~.ud 0]]
                              ==
                      :-  %vector
                          :~  [%namespace [~.tas %ref]]
                              [%name [~.tas %my-table-4]]
                              [%agent [~.ta '/test-agent']]
                              [%tmsp [~.da ~2000.1.7]]
                              [%row-count [~.ud 0]]
                              ==
                      :-  %vector
                          :~  [%namespace [~.tas %dbo]]
                              [%name [~.tas %my-table-4]]
                              [%agent [~.ta '/test-agent']]
                              [%tmsp [~.da ~2000.1.6]]
                              [%row-count [~.ud 0]]
                              ==
                      :-  %vector
                          :~  [%namespace [~.tas %dbo]]
                              [%name [~.tas %my-table-3]]
                              [%agent [~.ta '/test-agent']]
                              [%tmsp [~.da ~2000.1.4]]
                              [%row-count [~.ud 0]]
                              ==
                      :-  %vector
                          :~  [%namespace [~.tas %dbo]]
                              [%name [~.tas %my-table-2]]
                              [%agent [~.ta '/test-agent']]
                              [%tmsp [~.da ~2000.1.4]]
                              [%row-count [~.ud 0]]
                              ==
                      ==
              [%server-time ~2000.1.9]
              [%message 'db1.sys.tables']
              [%schema-time ~2000.1.7]
              [%data-time ~2000.1.8]
              [%vector-count 5]
              ==
      ::
      :-  %results
          :~  [%message 'SELECT']
              :-  %result-set
                  :~  :-  %vector
                          :~  [%namespace [~.tas %dbo]]
                              [%name [~.tas %my-table]]
                              [%key-ordinal [~.ud 2]]
                              [%key [~.tas %col2]]
                              [%key-ascending [~.f 1]]
                              ==
                      :-  %vector
                          :~  [%namespace [~.tas %ref]]
                              [%name [~.tas %my-table-4]]
                              [%key-ordinal [~.ud 2]]
                              [%key [~.tas %col3]]
                              [%key-ascending [~.f 0]]
                              ==
                      :-  %vector
                          :~  [%namespace [~.tas %dbo]]
                              [%name [~.tas %my-table-4]]
                              [%key-ordinal [~.ud 2]]
                              [%key [~.tas %col3]]
                              [%key-ascending [~.f 0]]
                              ==
                      :-  %vector
                          :~  [%namespace [~.tas %dbo]]
                              [%name [~.tas %my-table-3]]
                              [%key-ordinal [~.ud 1]]
                              [%key [~.tas %col1]]
                              [%key-ascending [~.f 0]]
                              ==
                      :-  %vector
                          :~  [%namespace [~.tas %dbo]]
                              [%name [~.tas %my-table]]
                              [%key-ordinal [~.ud 1]]
                              [%key [~.tas %col1]]
                              [%key-ascending [~.f 0]]
                              ==
                      :-  %vector
                          :~  [%namespace [~.tas %dbo]]
                              [%name [~.tas %my-table-2]]
                              [%key-ordinal [~.ud 2]]
                              [%key [~.tas %col2]]
                              [%key-ascending [~.f 0]]
                              ==
                      :-  %vector
                          :~  [%namespace [~.tas %ref]]
                              [%name [~.tas %my-table-4]]
                              [%key-ordinal [~.ud 1]]
                              [%key [~.tas %col1]]
                              [%key-ascending [~.f 0]]
                              ==
                      :-  %vector
                          :~  [%namespace [~.tas %dbo]]
                              [%name [~.tas %my-table-4]]
                              [%key-ordinal [~.ud 1]]
                              [%key [~.tas %col1]]
                              [%key-ascending [~.f 0]]
                              ==
                      :-  %vector
                          :~  [%namespace [~.tas %dbo]]
                              [%name [~.tas %my-table-2]]
                              [%key-ordinal [~.ud 1]]
                              [%key [~.tas %col1]]
                              [%key-ascending [~.f 1]]
                              ==
                      ==
              [%server-time ~2000.1.9]
              [%message 'db1.sys.table-keys']
              [%schema-time ~2000.1.7]
              [%data-time ~2000.1.7]
              [%vector-count 9]
              ==
      ==
::
++  test-sys-tables-and-keys-04  ::  TRUNCATE TABLE  (data not present)
  =|  run=@ud
  %-  exec-6-2
  :*  run
      [~2000.1.1 %sys "CREATE DATABASE db1"]
      ::
      :+  ~2000.1.2
          %db1
          "CREATE TABLE db1..my-table (col1 @t, col2 @t) ".
          "PRIMARY KEY (col1, col2 DESC)"
      ::
      :+  ~2000.1.4
          %db1
          "CREATE TABLE db1..my-table-2 (col1 @p, col2 @t) ".
          "PRIMARY KEY (col1 desc, col2); ".
          "CREATE TABLE db1..my-table-3 (col1 @p, col2 @t, col3 @ud) ".
          "PRIMARY KEY (col1)"
      ::
      [~2000.1.5 %db1 "CREATE NAMESPACE ref"]
      ::
      :+  ~2000.1.6
          %db1
          "CREATE TABLE db1..my-table-4 (col1 @p, col2 @t, col3 @ud) ".
          "PRIMARY KEY (col1, col3)"
      ::
      :+  ~2000.1.7
          %db1
          "CREATE TABLE db1.ref.my-table-4 (col1 @p, col2 @t, col3 @ud) ".
          "PRIMARY KEY (col1, col3)"
      ::
      [~2000.1.8 %db1 "TRUNCATE TABLE db1..my-table"]
      ::
      [~2000.1.9 %db1 "FROM sys.tables SELECT *"]
      ::
      [~2000.1.9 %db1 "FROM sys.table-keys SELECT *"]
      ::
      :-  %results
          :~  [%message 'SELECT']
              :-  %result-set
                  :~  :-  %vector
                          :~  [%namespace [~.tas %dbo]]
                              [%name [~.tas %my-table]]
                              [%agent [~.ta '/test-agent']]
                              [%tmsp [~.da ~2000.1.2]]
                              [%row-count [~.ud 0]]
                              ==
                      :-  %vector
                          :~  [%namespace [~.tas %ref]]
                              [%name [~.tas %my-table-4]]
                              [%agent [~.ta '/test-agent']]
                              [%tmsp [~.da ~2000.1.7]]
                              [%row-count [~.ud 0]]
                              ==
                      :-  %vector
                          :~  [%namespace [~.tas %dbo]]
                              [%name [~.tas %my-table-4]]
                              [%agent [~.ta '/test-agent']]
                              [%tmsp [~.da ~2000.1.6]]
                              [%row-count [~.ud 0]]
                              ==
                      :-  %vector
                          :~  [%namespace [~.tas %dbo]]
                              [%name [~.tas %my-table-3]]
                              [%agent [~.ta '/test-agent']]
                              [%tmsp [~.da ~2000.1.4]]
                              [%row-count [~.ud 0]]
                              ==
                      :-  %vector
                          :~  [%namespace [~.tas %dbo]]
                              [%name [~.tas %my-table-2]]
                              [%agent [~.ta '/test-agent']]
                              [%tmsp [~.da ~2000.1.4]]
                              [%row-count [~.ud 0]]
                              ==
                      ==
              [%server-time ~2000.1.9]
              [%message 'db1.sys.tables']
              [%schema-time ~2000.1.7]
              [%data-time ~2000.1.7]
              [%vector-count 5]
              ==
      ::
      :-  %results
          :~  [%message 'SELECT']
              :-  %result-set
                  :~  :-  %vector
                          :~  [%namespace [~.tas %dbo]]
                              [%name [~.tas %my-table]]
                              [%key-ordinal [~.ud 1]]
                              [%key [~.tas %col1]]
                              [%key-ascending [~.f 0]]
                              ==
                      :-  %vector
                          :~  [%namespace [~.tas %ref]]
                              [%name [~.tas %my-table-4]]
                              [%key-ordinal [~.ud 2]]
                              [%key [~.tas %col3]]
                              [%key-ascending [~.f 0]]
                              ==
                      :-  %vector
                          :~  [%namespace [~.tas %dbo]]
                              [%name [~.tas %my-table-4]]
                              [%key-ordinal [~.ud 2]]
                              [%key [~.tas %col3]]
                              [%key-ascending [~.f 0]]
                              ==
                      :-  %vector
                          :~  [%namespace [~.tas %dbo]]
                              [%name [~.tas %my-table-3]]
                              [%key-ordinal [~.ud 1]]
                              [%key [~.tas %col1]]
                              [%key-ascending [~.f 0]]
                              ==
                      :-  %vector
                          :~  [%namespace [~.tas %dbo]]
                              [%name [~.tas %my-table-2]]
                              [%key-ordinal [~.ud 2]]
                              [%key [~.tas %col2]]
                              [%key-ascending [~.f 0]]
                              ==
                      :-  %vector
                          :~  [%namespace [~.tas %ref]]
                              [%name [~.tas %my-table-4]]
                              [%key-ordinal [~.ud 1]]
                              [%key [~.tas %col1]]
                              [%key-ascending [~.f 0]]
                              ==
                      :-  %vector
                          :~  [%namespace [~.tas %dbo]]
                              [%name [~.tas %my-table]]
                              [%key-ordinal [~.ud 2]]
                              [%key [~.tas %col2]]
                              [%key-ascending [~.f 1]]
                              ==
                      :-  %vector
                          :~  [%namespace [~.tas %dbo]]
                              [%name [~.tas %my-table-4]]
                              [%key-ordinal [~.ud 1]]
                              [%key [~.tas %col1]]
                              [%key-ascending [~.f 0]]
                              ==
                      :-  %vector
                          :~  [%namespace [~.tas %dbo]]
                              [%name [~.tas %my-table-2]]
                              [%key-ordinal [~.ud 1]]
                              [%key [~.tas %col1]]
                              [%key-ascending [~.f 1]]
                              ==
                      ==
              [%server-time ~2000.1.9]
              [%message 'db1.sys.table-keys']
              [%schema-time ~2000.1.7]
              [%data-time ~2000.1.7]
              [%vector-count 9]
              ==
      ==
::
++  test-sys-columns-01 ::  CREATE TABLE
  =|  run=@ud
  %-  exec-4-2
  :*  run
      [~2000.1.1 %sys "CREATE DATABASE db1"]
      ::
      [~2000.1.2 %db1 "CREATE NAMESPACE db1.ref"]
      ::
      :+  ~2000.1.3
          %db1
          "CREATE TABLE db1.ref.my-table (col1 @t, col2 @t) ".
          "PRIMARY KEY (col1, col2 DESC)"
      ::
      :+  ~2000.1.4
          %db1
          "CREATE TABLE db1..my-table-2 (col1 @p, col2 @t) ".
          "PRIMARY KEY (col1 desc, col2); ".
          "CREATE TABLE db1..my-table-3 (col1 @p, col2 @t, col3 @ud) ".
          "PRIMARY KEY (col1)"
      ::
      :+  ~2000.1.5
          %db1
          "CREATE TABLE db1..my-table-4 (col1 @p, col2 @t, col3 @ud) ".
          "PRIMARY KEY (col1, col3)"
      ::
      [~2000.1.6 %db1 "FROM sys.columns SELECT *"]
      ::
      [~2000.1.7 %db1 "FROM sys.columns AS OF 2000.1.4..1.1.1 SELECT *"]
      ::
      :-  %results
          :~  [%message 'SELECT']
              :-  %result-set
                  :~  :-  %vector
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
                      :-  %vector
                          :~  [%namespace [~.tas %dbo]]
                              [%name [~.tas %my-table-3]]
                              [%col-ordinal [~.ud 1]]
                              [%col-name [~.tas %col1]]
                              [%col-type [~.ta ~.p]]
                              ==
                      :-  %vector
                          :~  [%namespace [~.tas %dbo]]
                              [%name [~.tas %my-table-2]]
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
                              [%name [~.tas %my-table-2]]
                              [%col-ordinal [~.ud 2]]
                              [%col-name [~.tas %col2]]
                              [%col-type [~.ta ~.t]]
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
                              [%name [~.tas %my-table-3]]
                              [%col-ordinal [~.ud 3]]
                              [%col-name [~.tas %col3]]
                              [%col-type [~.ta ~.ud]]
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
                              [%name [~.tas %my-table-4]]
                              [%col-ordinal [~.ud 3]]
                              [%col-name [~.tas %col3]]
                              [%col-type [~.ta ~.ud]]
                              ==
                      ==
              [%server-time ~2000.1.6]
              [%message 'db1.sys.columns']
              [%schema-time ~2000.1.5]
              [%data-time ~2000.1.5]
              [%vector-count 10]
              ==
      ::
      :-  %results
          :~  [%message 'SELECT']
              :-  %result-set
                  :~  :-  %vector
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
                      :-  %vector
                          :~  [%namespace [~.tas %dbo]]
                              [%name [~.tas %my-table-3]]
                              [%col-ordinal [~.ud 1]]
                              [%col-name [~.tas %col1]]
                              [%col-type [~.ta ~.p]]
                              ==
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
                              [%col-ordinal [~.ud 3]]
                              [%col-name [~.tas %col3]]
                              [%col-type [~.ta ~.ud]]
                              ==
                      :-  %vector
                          :~  [%namespace [~.tas %dbo]]
                              [%name [~.tas %my-table-3]]
                              [%col-ordinal [~.ud 2]]
                              [%col-name [~.tas %col2]]
                              [%col-type [~.ta ~.t]]
                              ==
                      ==
              [%server-time ~2000.1.7]
              [%message 'db1.sys.columns']
              [%schema-time ~2000.1.4]
              [%data-time ~2000.1.4]
              [%vector-count 7]
              ==
      ==
::
++  test-sys-columns-02 ::  DROP TABLE
  =|  run=@ud
  =/  cmd  :^  %drop-table
              :*  %qualified-table
                  ship=~
                  database='db1'
                  namespace='ref'
                  name='my-table'
                  alias=~
              ==
              %.y
              ~
  %-  exec-5-2xx
  :*  run
      [~2000.1.1 %sys "CREATE DATABASE db1"]
      ::
      [~2000.1.2 %db1 "CREATE NAMESPACE db1.ref"]
      ::
      :+  ~2000.1.3
          %db1
          "CREATE TABLE db1.ref.my-table (col1 @t, col2 @t) ".
          "PRIMARY KEY (col1, col2 DESC)"
      ::
      :+  ~2000.1.4
          %db1
          "CREATE TABLE db1..my-table-2 (col1 @p, col2 @t) ".
          "PRIMARY KEY (col1 desc, col2); ".
          "CREATE TABLE db1..my-table-3 (col1 @p, col2 @t, col3 @ud) ".
          "PRIMARY KEY (col1)"
      ::
      :+  ~2000.1.5
          %db1
          "CREATE TABLE db1..my-table-4 (col1 @p, col2 @t, col3 @ud) ".
          "PRIMARY KEY (col1, col3)"
      ::
      [~2000.1.6 %commands ~[cmd]]
      ::
      [~2000.1.7 %db1 "FROM sys.columns SELECT *"]
      ::
      [~2000.1.8 %db1 "FROM sys.columns AS OF ~2000.1.5 SELECT *"]
      ::
      :-  %results
          :~  [%message 'SELECT']
              :-  %result-set
                  :~  :-  %vector
                          :~  [%namespace [~.tas %dbo]]
                              [%name [~.tas %my-table-3]]
                              [%col-ordinal [~.ud 1]]
                              [%col-name [~.tas %col1]]
                              [%col-type [~.ta ~.p]]
                              ==
                      :-  %vector
                          :~  [%namespace [~.tas %dbo]]
                              [%name [~.tas %my-table-2]]
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
                              [%name [~.tas %my-table-2]]
                              [%col-ordinal [~.ud 2]]
                              [%col-name [~.tas %col2]]
                              [%col-type [~.ta ~.t]]
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
                              [%name [~.tas %my-table-3]]
                              [%col-ordinal [~.ud 3]]
                              [%col-name [~.tas %col3]]
                              [%col-type [~.ta ~.ud]]
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
                              [%name [~.tas %my-table-4]]
                              [%col-ordinal [~.ud 3]]
                              [%col-name [~.tas %col3]]
                              [%col-type [~.ta ~.ud]]
                              ==
                      ==
              [%server-time ~2000.1.7]
              [%message 'db1.sys.columns']
              [%schema-time ~2000.1.6]
              [%data-time ~2000.1.6]
              [%vector-count 8]
              ==
      ::
      :-  %results
          :~  [%message 'SELECT']
              :-  %result-set
                  :~  :-  %vector
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
                      :-  %vector
                          :~  [%namespace [~.tas %dbo]]
                              [%name [~.tas %my-table-3]]
                              [%col-ordinal [~.ud 1]]
                              [%col-name [~.tas %col1]]
                              [%col-type [~.ta ~.p]]
                              ==
                      :-  %vector
                          :~  [%namespace [~.tas %dbo]]
                              [%name [~.tas %my-table-2]]
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
                              [%name [~.tas %my-table-2]]
                              [%col-ordinal [~.ud 2]]
                              [%col-name [~.tas %col2]]
                              [%col-type [~.ta ~.t]]
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
                              [%name [~.tas %my-table-3]]
                              [%col-ordinal [~.ud 3]]
                              [%col-name [~.tas %col3]]
                              [%col-type [~.ta ~.ud]]
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
                              [%name [~.tas %my-table-4]]
                              [%col-ordinal [~.ud 3]]
                              [%col-name [~.tas %col3]]
                              [%col-type [~.ta ~.ud]]
                              ==
                      ==
              [%server-time ~2000.1.8]
              [%message 'db1.sys.columns']
              [%schema-time ~2000.1.5]
              [%data-time ~2000.1.5]
              [%vector-count 10]
              ==
      ==
::
++  test-sys-log-01    ::  CREATE TABLE
  =|  run=@ud
  %-  exec-5-2
  :*  run
      [~2000.1.1 %sys "CREATE DATABASE db1"]
      ::
      :+  ~2000.1.2
          %db1
          "CREATE TABLE db1..my-table (col1 @t, col2 @t) ".
          "PRIMARY KEY (col1, col2 DESC)"
      ::
      :+  ~2000.1.4
          %db1
          "CREATE TABLE db1..my-table-2 (col1 @p, col2 @t) ".
          "PRIMARY KEY (col1 desc, col2); ".
          "CREATE TABLE db1..my-table-3 (col1 @p, col2 @t, col3 @ud) ".
          "PRIMARY KEY (col1)"
      ::
      [~2000.1.5 %db1 "CREATE NAMESPACE ref"]
      ::
      :+  ~2000.1.6
          %db1
          "CREATE TABLE db1..my-table-4 (col1 @p, col2 @t, col3 @ud) ".
          "PRIMARY KEY (col1, col3)"
      ::
      :+  ~2000.1.7
          %db1
          "CREATE TABLE db1.ref.my-table-4 (col1 @p, col2 @t, col3 @ud) ".
          "PRIMARY KEY (col1, col3)"
      ::
      [~2000.1.8 %db1 "FROM sys.sys-log SELECT *"]
      ::
      [~2000.1.9 %db1 "FROM sys.sys-log AS OF ~2000.1.6 SELECT *"]
      ::
      :-  %results
          :~  [%message 'SELECT']
              :-  %result-set
                  :~  :-  %vector
                          :~  [%tmsp [~.da ~2000.1.7]]
                              [%agent [~.ta '/test-agent']]
                              [%component [~.tas %ref]]
                              [%name [~.tas %my-table-4]]
                              ==
                      :-  %vector
                          :~  [%tmsp [~.da ~2000.1.4]]
                              [%agent [~.ta '/test-agent']]
                              [%component [~.tas %dbo]]
                              [%name [~.tas %my-table-3]]
                              ==
                      :-  %vector
                          :~  [%tmsp [~.da ~2000.1.6]]
                              [%agent [~.ta '/test-agent']]
                              [%component [~.tas %dbo]]
                              [%name [~.tas %my-table-4]]
                              ==
                      :-  %vector
                          :~  [%tmsp [~.da ~2000.1.5]]
                              [%agent [~.ta '/test-agent']]
                              [%component [~.tas %namespace]]
                              [%name [~.tas %ref]]
                              ==
                      :-  %vector
                          :~  [%tmsp [~.da ~2000.1.4]]
                              [%agent [~.ta '/test-agent']]
                              [%component [~.tas %dbo]]
                              [%name [~.tas %my-table-2]]
                              ==
                      :-  %vector
                          :~  [%tmsp [~.da ~2000.1.1]]
                              [%agent [~.ta '/test-agent']]
                              [%component [~.tas %namespace]]
                              [%name [~.tas %sys]]
                              ==
                      :-  %vector
                          :~  [%tmsp [~.da ~2000.1.2]]
                              [%agent [~.ta '/test-agent']]
                              [%component [~.tas %dbo]]
                              [%name [~.tas %my-table]]
                              ==
                      :-  %vector
                          :~  [%tmsp [~.da ~2000.1.1]]
                              [%agent [~.ta '/test-agent']]
                              [%component [~.tas %namespace]]
                              [%name [~.tas %dbo]]
                              ==
                      ==
              [%server-time ~2000.1.8]
              [%message 'db1.sys.sys-log']
              [%schema-time ~2000.1.7]
              [%data-time ~2000.1.7]
              [%vector-count 8]
              ==
      ::
      :-  %results
          :~  [%message 'SELECT']
              :-  %result-set
                  :~  :-  %vector
                          :~  [%tmsp [~.da ~2000.1.4]]
                              [%agent [~.ta '/test-agent']]
                              [%component [~.tas %dbo]]
                              [%name [~.tas %my-table-3]]
                              ==
                      :-  %vector
                          :~  [%tmsp [~.da ~2000.1.6]]
                              [%agent [~.ta '/test-agent']]
                              [%component [~.tas %dbo]]
                              [%name [~.tas %my-table-4]]
                              ==
                      :-  %vector
                          :~  [%tmsp [~.da ~2000.1.5]]
                              [%agent [~.ta '/test-agent']]
                              [%component [~.tas %namespace]]
                              [%name [~.tas %ref]]
                              ==
                      :-  %vector
                          :~  [%tmsp [~.da ~2000.1.4]]
                              [%agent [~.ta '/test-agent']]
                              [%component [~.tas %dbo]]
                              [%name [~.tas %my-table-2]]
                              ==
                      :-  %vector
                          :~  [%tmsp [~.da ~2000.1.1]]
                              [%agent [~.ta '/test-agent']]
                              [%component [~.tas %namespace]]
                              [%name [~.tas %sys]]
                              ==
                      :-  %vector
                          :~  [%tmsp [~.da ~2000.1.2]]
                              [%agent [~.ta '/test-agent']]
                              [%component [~.tas %dbo]]
                              [%name [~.tas %my-table]]
                              ==
                      :-  %vector
                          :~  [%tmsp [~.da ~2000.1.1]]
                              [%agent [~.ta '/test-agent']]
                              [%component [~.tas %namespace]]
                              [%name [~.tas %dbo]]
                              ==
                      ==
              [%server-time ~2000.1.9]
              [%message 'db1.sys.sys-log']
              [%schema-time ~2000.1.6]
              [%data-time ~2000.1.6]
              [%vector-count 7]
              ==
      ==
::
++  test-sys-log-02    ::  DROP TABLE, note that DROP does not change results
  =|  run=@ud
  %-  exec-6-2
  :*  run
      [~2000.1.1 %sys "CREATE DATABASE db1"]
      ::
      :+  ~2000.1.2
          %db1
          "CREATE TABLE db1..my-table (col1 @t, col2 @t) ".
          "PRIMARY KEY (col1, col2 DESC)"
      ::
      :+  ~2000.1.4
          %db1
          "CREATE TABLE db1..my-table-2 (col1 @p, col2 @t) ".
          "PRIMARY KEY (col1 desc, col2); ".
          "CREATE TABLE db1..my-table-3 (col1 @p, col2 @t, col3 @ud) ".
          "PRIMARY KEY (col1)"
      ::
      [~2000.1.5 %db1 "CREATE NAMESPACE ref"]
      ::
      :+  ~2000.1.6
          %db1
          "CREATE TABLE db1..my-table-4 (col1 @p, col2 @t, col3 @ud) ".
          "PRIMARY KEY (col1, col3)"
      ::
      :+  ~2000.1.7
          %db1
          "CREATE TABLE db1.ref.my-table-4 (col1 @p, col2 @t, col3 @ud) ".
          "PRIMARY KEY (col1, col3)"
      ::
      :+  ~2000.1.8
          %db1
          "DROP TABLE db1..my-table"
      ::
      [~2000.1.9 %db1 "FROM sys.sys-log SELECT *"]
      ::
      [~2000.1.10 %db1 "FROM sys.sys-log AS OF ~2000.1.7 SELECT *"]
      ::
      :-  %results
          :~  [%message 'SELECT']
              :-  %result-set
                  :~  :-  %vector
                          :~  [%tmsp [~.da ~2000.1.7]]
                              [%agent [~.ta '/test-agent']]
                              [%component [~.tas %ref]]
                              [%name [~.tas %my-table-4]]
                              ==
                      :-  %vector
                          :~  [%tmsp [~.da ~2000.1.4]]
                              [%agent [~.ta '/test-agent']]
                              [%component [~.tas %dbo]]
                              [%name [~.tas %my-table-3]]
                              ==
                      :-  %vector
                          :~  [%tmsp [~.da ~2000.1.6]]
                              [%agent [~.ta '/test-agent']]
                              [%component [~.tas %dbo]]
                              [%name [~.tas %my-table-4]]
                              ==
                      :-  %vector
                          :~  [%tmsp [~.da ~2000.1.5]]
                              [%agent [~.ta '/test-agent']]
                              [%component [~.tas %namespace]]
                              [%name [~.tas %ref]]
                              ==
                      :-  %vector
                          :~  [%tmsp [~.da ~2000.1.4]]
                              [%agent [~.ta '/test-agent']]
                              [%component [~.tas %dbo]]
                              [%name [~.tas %my-table-2]]
                              ==
                      :-  %vector
                          :~  [%tmsp [~.da ~2000.1.1]]
                              [%agent [~.ta '/test-agent']]
                              [%component [~.tas %namespace]]
                              [%name [~.tas %sys]]
                              ==
                      :-  %vector
                          :~  [%tmsp [~.da ~2000.1.2]]
                              [%agent [~.ta '/test-agent']]
                              [%component [~.tas %dbo]]
                              [%name [~.tas %my-table]]
                              ==
                      :-  %vector
                          :~  [%tmsp [~.da ~2000.1.1]]
                              [%agent [~.ta '/test-agent']]
                              [%component [~.tas %namespace]]
                              [%name [~.tas %dbo]]
                              ==
                      ==
              [%server-time ~2000.1.9]
              [%message 'db1.sys.sys-log']
              [%schema-time ~2000.1.8]
              [%data-time ~2000.1.8]
              [%vector-count 8]
              ==
      ::
      :-  %results
          :~  [%message 'SELECT']
              :-  %result-set
                  :~  :-  %vector
                          :~  [%tmsp [~.da ~2000.1.7]]
                              [%agent [~.ta '/test-agent']]
                              [%component [~.tas %ref]]
                              [%name [~.tas %my-table-4]]
                              ==
                      :-  %vector
                          :~  [%tmsp [~.da ~2000.1.4]]
                              [%agent [~.ta '/test-agent']]
                              [%component [~.tas %dbo]]
                              [%name [~.tas %my-table-3]]
                              ==
                      :-  %vector
                          :~  [%tmsp [~.da ~2000.1.6]]
                              [%agent [~.ta '/test-agent']]
                              [%component [~.tas %dbo]]
                              [%name [~.tas %my-table-4]]
                              ==
                      :-  %vector
                          :~  [%tmsp [~.da ~2000.1.5]]
                              [%agent [~.ta '/test-agent']]
                              [%component [~.tas %namespace]]
                              [%name [~.tas %ref]]
                              ==
                      :-  %vector
                          :~  [%tmsp [~.da ~2000.1.4]]
                              [%agent [~.ta '/test-agent']]
                              [%component [~.tas %dbo]]
                              [%name [~.tas %my-table-2]]
                              ==
                      :-  %vector
                          :~  [%tmsp [~.da ~2000.1.1]]
                              [%agent [~.ta '/test-agent']]
                              [%component [~.tas %namespace]]
                              [%name [~.tas %sys]]
                              ==
                      :-  %vector
                          :~  [%tmsp [~.da ~2000.1.2]]
                              [%agent [~.ta '/test-agent']]
                              [%component [~.tas %dbo]]
                              [%name [~.tas %my-table]]
                              ==
                      :-  %vector
                          :~  [%tmsp [~.da ~2000.1.1]]
                              [%agent [~.ta '/test-agent']]
                              [%component [~.tas %namespace]]
                              [%name [~.tas %dbo]]
                              ==
                      ==
              [%server-time ~2000.1.10]
              [%message 'db1.sys.sys-log']
              [%schema-time ~2000.1.7]
              [%data-time ~2000.1.7]
              [%vector-count 8]
              ==
      ==
::
++  test-sys-data-log-01   ::  INSERT
  =|  run=@ud
  %-  exec-9-2
  :*  run
      [~2000.1.1 %sys "CREATE DATABASE db1"]
      ::
      :+  ~2000.1.2
          %db1
          "CREATE TABLE db1..my-table (col1 @t, col2 @t) ".
          "PRIMARY KEY (col1, col2 DESC)"
      ::
      :+  ~2000.1.3
          %db1
          "INSERT INTO db1..my-table (col1, col2) ".
          "VALUES ('cord', 'cord2')"
      ::
      :+  ~2000.1.4
          %db1
          "CREATE TABLE db1..my-table-2 (col1 @p, col2 @t) ".
          "PRIMARY KEY (col1 desc, col2); ".
          "CREATE TABLE db1..my-table-3 (col1 @p, col2 @t, col3 @ud) ".
          "PRIMARY KEY (col1)"
      ::
      :+  ~2000.1.5
          %db1
          "INSERT INTO db1..my-table-2 (col1, col2) ".
          "VALUES (~zod, 'cord2')"
      ::
      [~2000.1.6 %db1 "CREATE NAMESPACE ref"]
      ::
      :+  ~2000.1.7
          %db1
          "CREATE TABLE db1..my-table-4 (col1 @p, col2 @t, col3 @ud) ".
          "PRIMARY KEY (col1, col3)"
      ::
      :+  ~2000.1.8
          %db1
          "INSERT INTO db1..my-table-4 (col1, col2, col3) ".
          "VALUES (~zod, 'cord2', 42)"
      ::
      :+  ~2000.1.9
          %db1
          "CREATE TABLE db1.ref.my-table-4 (col1 @p, col2 @t, col3 @ud) ".
          "PRIMARY KEY (col1, col3)"
      ::
      :+  ~2000.1.10
          %db1
          "INSERT INTO db1.ref.my-table-4 (col1, col2, col3) ".
          "VALUES (~zod, 'cord2', 16)"
      ::
      [~2000.1.11 %db1 "FROM sys.data-log SELECT *"]
      ::
      [~2000.1.12 %db1 "FROM sys.data-log AS OF ~2000.1.9 SELECT *"]
      ::
      :-  %results
          :~  [%message 'SELECT']
              :-  %result-set
                  :~  :-  %vector
                          :~  [%tmsp [~.da ~2000.1.3]]
                              [%ship [~.p 0]]
                              [%agent [~.ta '/test-agent']]
                              [%namespace [~.tas %dbo]]
                              [%table [~.tas %my-table]]
                              [%row-count [~.ud 1]]
                              ==
                      :-  %vector
                          :~  [%tmsp [~.da ~2000.1.2]]
                              [%ship [~.p 0]]
                              [%agent [~.ta '/test-agent']]
                              [%namespace [~.tas %dbo]]
                              [%table [~.tas %my-table]]
                              [%row-count [~.ud 0]]
                              ==
                      :-  %vector
                          :~  [%tmsp [~.da ~2000.1.8]]
                              [%ship [~.p 0]]
                              [%agent [~.ta '/test-agent']]
                              [%namespace [~.tas %dbo]]
                              [%table [~.tas %my-table-4]]
                              [%row-count [~.ud 1]]
                              ==
                      :-  %vector
                          :~  [%tmsp [~.da ~2000.1.4]]
                              [%ship [~.p 0]]
                              [%agent [~.ta '/test-agent']]
                              [%namespace [~.tas %dbo]]
                              [%table [~.tas %my-table-3]]
                              [%row-count [~.ud 0]]
                              ==
                      :-  %vector
                          :~  [%tmsp [~.da ~2000.1.10]]
                              [%ship [~.p 0]]
                              [%agent [~.ta '/test-agent']]
                              [%namespace [~.tas %ref]]
                              [%table [~.tas %my-table-4]]
                              [%row-count [~.ud 1]]
                              ==
                      :-  %vector
                          :~  [%tmsp [~.da ~2000.1.5]]
                              [%ship [~.p 0]]
                              [%agent [~.ta '/test-agent']]
                              [%namespace [~.tas %dbo]]
                              [%table [~.tas %my-table-2]]
                              [%row-count [~.ud 1]]
                              ==
                      :-  %vector
                          :~  [%tmsp [~.da ~2000.1.9]]
                              [%ship [~.p 0]]
                              [%agent [~.ta '/test-agent']]
                              [%namespace [~.tas %ref]]
                              [%table [~.tas %my-table-4]]
                              [%row-count [~.ud 0]]
                              ==
                      :-  %vector
                          :~  [%tmsp [~.da ~2000.1.7]]
                              [%ship [~.p 0]]
                              [%agent [~.ta '/test-agent']]
                              [%namespace [~.tas %dbo]]
                              [%table [~.tas %my-table-4]]
                              [%row-count [~.ud 0]]
                              ==
                      :-  %vector
                          :~  [%tmsp [~.da ~2000.1.4]]
                              [%ship [~.p 0]]
                              [%agent [~.ta '/test-agent']]
                              [%namespace [~.tas %dbo]]
                              [%table [~.tas %my-table-2]]
                              [%row-count [~.ud 0]]
                              ==
                      ==
              [%server-time ~2000.1.11]
              [%message 'db1.sys.data-log']
              [%schema-time ~2000.1.9]
              [%data-time ~2000.1.10]
              [%vector-count 9]
              ==
      ::
      :-  %results
          :~  [%message 'SELECT']
              :-  %result-set
                  :~  :-  %vector
                          :~  [%tmsp [~.da ~2000.1.3]]
                              [%ship [~.p 0]]
                              [%agent [~.ta '/test-agent']]
                              [%namespace [~.tas %dbo]]
                              [%table [~.tas %my-table]]
                              [%row-count [~.ud 1]]
                              ==
                      :-  %vector
                          :~  [%tmsp [~.da ~2000.1.2]]
                              [%ship [~.p 0]]
                              [%agent [~.ta '/test-agent']]
                              [%namespace [~.tas %dbo]]
                              [%table [~.tas %my-table]]
                              [%row-count [~.ud 0]]
                              ==
                      :-  %vector
                          :~  [%tmsp [~.da ~2000.1.8]]
                              [%ship [~.p 0]]
                              [%agent [~.ta '/test-agent']]
                              [%namespace [~.tas %dbo]]
                              [%table [~.tas %my-table-4]]
                              [%row-count [~.ud 1]]
                              ==
                      :-  %vector
                          :~  [%tmsp [~.da ~2000.1.4]]
                              [%ship [~.p 0]]
                              [%agent [~.ta '/test-agent']]
                              [%namespace [~.tas %dbo]]
                              [%table [~.tas %my-table-3]]
                              [%row-count [~.ud 0]]
                              ==
                      :-  %vector
                          :~  [%tmsp [~.da ~2000.1.5]]
                              [%ship [~.p 0]]
                              [%agent [~.ta '/test-agent']]
                              [%namespace [~.tas %dbo]]
                              [%table [~.tas %my-table-2]]
                              [%row-count [~.ud 1]]
                              ==
                      :-  %vector
                          :~  [%tmsp [~.da ~2000.1.9]]
                              [%ship [~.p 0]]
                              [%agent [~.ta '/test-agent']]
                              [%namespace [~.tas %ref]]
                              [%table [~.tas %my-table-4]]
                              [%row-count [~.ud 0]]
                              ==
                      :-  %vector
                          :~  [%tmsp [~.da ~2000.1.7]]
                              [%ship [~.p 0]]
                              [%agent [~.ta '/test-agent']]
                              [%namespace [~.tas %dbo]]
                              [%table [~.tas %my-table-4]]
                              [%row-count [~.ud 0]]
                              ==
                      :-  %vector
                          :~  [%tmsp [~.da ~2000.1.4]]
                              [%ship [~.p 0]]
                              [%agent [~.ta '/test-agent']]
                              [%namespace [~.tas %dbo]]
                              [%table [~.tas %my-table-2]]
                              [%row-count [~.ud 0]]
                              ==
                      ==
              [%server-time ~2000.1.12]
              [%message 'db1.sys.data-log']
              [%schema-time ~2000.1.9]
              [%data-time ~2000.1.9]
              [%vector-count 8]
              ==
      ==
::
++  test-sys-data-log-02   ::  CREATE TABLE
  =|  run=@ud
  %-  exec-8-2
  :*  run
      [~2000.1.1 %sys "CREATE DATABASE db1"]
      ::
      :+  ~2000.1.2
          %db1
          "CREATE TABLE db1..my-table (col1 @t, col2 @t) ".
          "PRIMARY KEY (col1, col2 DESC)"
      ::
      :+  ~2000.1.3
          %db1
          "INSERT INTO db1..my-table (col1, col2) ".
          "VALUES ('cord', 'cord2')"
      ::
      :+  ~2000.1.4
          %db1
          "CREATE TABLE db1..my-table-2 (col1 @p, col2 @t) ".
          "PRIMARY KEY (col1 desc, col2); ".
          "CREATE TABLE db1..my-table-3 (col1 @p, col2 @t, col3 @ud) ".
          "PRIMARY KEY (col1)"
      ::
      :+  ~2000.1.5
          %db1
          "INSERT INTO db1..my-table-2 (col1, col2) ".
          "VALUES (~zod, 'cord2')"
      ::
      [~2000.1.6 %db1 "CREATE NAMESPACE ref"]
      ::
      :+  ~2000.1.7
          %db1
          "CREATE TABLE db1..my-table-4 (col1 @p, col2 @t, col3 @ud) ".
          "PRIMARY KEY (col1, col3)"
      ::
      :+  ~2000.1.8
          %db1
          "INSERT INTO db1..my-table-4 (col1, col2, col3) ".
          "VALUES (~zod, 'cord2', 42)"
      ::
      :+  ~2000.1.9
          %db1
          "CREATE TABLE db1.ref.my-table-4 (col1 @p, col2 @t, col3 @ud) ".
          "PRIMARY KEY (col1, col3)"
      ::
      [~2000.1.10 %db1 "FROM sys.data-log SELECT *"]
      ::
      [~2000.1.11 %db1 "FROM sys.data-log AS OF ~2000.1.8 SELECT *"]
      ::
      :-  %results
          :~  [%message 'SELECT']
              :-  %result-set
                  :~  :-  %vector
                          :~  [%tmsp [~.da ~2000.1.3]]
                              [%ship [~.p 0]]
                              [%agent [~.ta '/test-agent']]
                              [%namespace [~.tas %dbo]]
                              [%table [~.tas %my-table]]
                              [%row-count [~.ud 1]]
                              ==
                      :-  %vector
                          :~  [%tmsp [~.da ~2000.1.2]]
                              [%ship [~.p 0]]
                              [%agent [~.ta '/test-agent']]
                              [%namespace [~.tas %dbo]]
                              [%table [~.tas %my-table]]
                              [%row-count [~.ud 0]]
                              ==
                      :-  %vector
                          :~  [%tmsp [~.da ~2000.1.8]]
                              [%ship [~.p 0]]
                              [%agent [~.ta '/test-agent']]
                              [%namespace [~.tas %dbo]]
                              [%table [~.tas %my-table-4]]
                              [%row-count [~.ud 1]]
                              ==
                      :-  %vector
                          :~  [%tmsp [~.da ~2000.1.4]]
                              [%ship [~.p 0]]
                              [%agent [~.ta '/test-agent']]
                              [%namespace [~.tas %dbo]]
                              [%table [~.tas %my-table-3]]
                              [%row-count [~.ud 0]]
                              ==
                      :-  %vector
                          :~  [%tmsp [~.da ~2000.1.5]]
                              [%ship [~.p 0]]
                              [%agent [~.ta '/test-agent']]
                              [%namespace [~.tas %dbo]]
                              [%table [~.tas %my-table-2]]
                              [%row-count [~.ud 1]]
                              ==
                      :-  %vector
                          :~  [%tmsp [~.da ~2000.1.9]]
                              [%ship [~.p 0]]
                              [%agent [~.ta '/test-agent']]
                              [%namespace [~.tas %ref]]
                              [%table [~.tas %my-table-4]]
                              [%row-count [~.ud 0]]
                              ==
                      :-  %vector
                          :~  [%tmsp [~.da ~2000.1.7]]
                              [%ship [~.p 0]]
                              [%agent [~.ta '/test-agent']]
                              [%namespace [~.tas %dbo]]
                              [%table [~.tas %my-table-4]]
                              [%row-count [~.ud 0]]
                              ==
                      :-  %vector
                          :~  [%tmsp [~.da ~2000.1.4]]
                              [%ship [~.p 0]]
                              [%agent [~.ta '/test-agent']]
                              [%namespace [~.tas %dbo]]
                              [%table [~.tas %my-table-2]]
                              [%row-count [~.ud 0]]
                              ==
                      ==
              [%server-time ~2000.1.10]
              [%message 'db1.sys.data-log']
              [%schema-time ~2000.1.9]
              [%data-time ~2000.1.9]
              [%vector-count 8]
              ==
      ::
      :-  %results
          :~  [%message 'SELECT']
              :-  %result-set
                  :~  :-  %vector
                          :~  [%tmsp [~.da ~2000.1.3]]
                              [%ship [~.p 0]]
                              [%agent [~.ta '/test-agent']]
                              [%namespace [~.tas %dbo]]
                              [%table [~.tas %my-table]]
                              [%row-count [~.ud 1]]
                              ==
                      :-  %vector
                          :~  [%tmsp [~.da ~2000.1.2]]
                              [%ship [~.p 0]]
                              [%agent [~.ta '/test-agent']]
                              [%namespace [~.tas %dbo]]
                              [%table [~.tas %my-table]]
                              [%row-count [~.ud 0]]
                              ==
                      :-  %vector
                          :~  [%tmsp [~.da ~2000.1.8]]
                              [%ship [~.p 0]]
                              [%agent [~.ta '/test-agent']]
                              [%namespace [~.tas %dbo]]
                              [%table [~.tas %my-table-4]]
                              [%row-count [~.ud 1]]
                              ==
                      :-  %vector
                          :~  [%tmsp [~.da ~2000.1.4]]
                              [%ship [~.p 0]]
                              [%agent [~.ta '/test-agent']]
                              [%namespace [~.tas %dbo]]
                              [%table [~.tas %my-table-3]]
                              [%row-count [~.ud 0]]
                              ==
                      :-  %vector
                          :~  [%tmsp [~.da ~2000.1.5]]
                              [%ship [~.p 0]]
                              [%agent [~.ta '/test-agent']]
                              [%namespace [~.tas %dbo]]
                              [%table [~.tas %my-table-2]]
                              [%row-count [~.ud 1]]
                              ==
                      :-  %vector
                          :~  [%tmsp [~.da ~2000.1.7]]
                              [%ship [~.p 0]]
                              [%agent [~.ta '/test-agent']]
                              [%namespace [~.tas %dbo]]
                              [%table [~.tas %my-table-4]]
                              [%row-count [~.ud 0]]
                              ==
                      :-  %vector
                          :~  [%tmsp [~.da ~2000.1.4]]
                              [%ship [~.p 0]]
                              [%agent [~.ta '/test-agent']]
                              [%namespace [~.tas %dbo]]
                              [%table [~.tas %my-table-2]]
                              [%row-count [~.ud 0]]
                              ==
                      ==
              [%server-time ~2000.1.11]
              [%message 'db1.sys.data-log']
              [%schema-time ~2000.1.7]
              [%data-time ~2000.1.8]
              [%vector-count 7]
              ==
      ==
::
++  test-sys-data-log-03   ::  DROP TABLE FORCE
  =|  run=@ud
  %-  exec-9-2
  :*  run
      [~2000.1.1 %sys "CREATE DATABASE db1"]
      ::
      :+  ~2000.1.2
          %db1
          "CREATE TABLE db1..my-table (col1 @t, col2 @t) ".
          "PRIMARY KEY (col1, col2 DESC)"
      ::
      :+  ~2000.1.3
          %db1
          "INSERT INTO db1..my-table (col1, col2) ".
          "VALUES ('cord', 'cord2')"
      ::
      :+  ~2000.1.4
          %db1
          "CREATE TABLE db1..my-table-2 (col1 @p, col2 @t) ".
          "PRIMARY KEY (col1 desc, col2); ".
          "CREATE TABLE db1..my-table-3 (col1 @p, col2 @t, col3 @ud) ".
          "PRIMARY KEY (col1)"
      ::
      :+  ~2000.1.5
          %db1
          "INSERT INTO db1..my-table-2 (col1, col2) ".
          "VALUES (~zod, 'cord2')"
      ::
      [~2000.1.6 %db1 "CREATE NAMESPACE ref"]
      ::
      :+  ~2000.1.7
          %db1
          "CREATE TABLE db1..my-table-4 (col1 @p, col2 @t, col3 @ud) ".
          "PRIMARY KEY (col1, col3)"
      ::
      :+  ~2000.1.8
          %db1
          "INSERT INTO db1..my-table-4 (col1, col2, col3) ".
          "VALUES (~zod, 'cord2', 42)"
      ::
      :+  ~2000.1.9
          %db1
          "CREATE TABLE db1.ref.my-table-4 (col1 @p, col2 @t, col3 @ud) ".
          "PRIMARY KEY (col1, col3)"
      ::
      :+  ~2000.1.10
          %db1
          "DROP TABLE FORCE db1..my-table-4"
      ::
      [~2000.1.11 %db1 "FROM sys.data-log SELECT *"]
      ::
      [~2000.1.12 %db1 "FROM sys.data-log AS OF ~2000.1.9 SELECT *"]
      ::
      :-  %results
          :~  [%message 'SELECT']
              :-  %result-set
                  :~  :-  %vector
                          :~  [%tmsp [~.da ~2000.1.3]]
                              [%ship [~.p 0]]
                              [%agent [~.ta '/test-agent']]
                              [%namespace [~.tas %dbo]]
                              [%table [~.tas %my-table]]
                              [%row-count [~.ud 1]]
                              ==
                      :-  %vector
                          :~  [%tmsp [~.da ~2000.1.2]]
                              [%ship [~.p 0]]
                              [%agent [~.ta '/test-agent']]
                              [%namespace [~.tas %dbo]]
                              [%table [~.tas %my-table]]
                              [%row-count [~.ud 0]]
                              ==
                      :-  %vector
                          :~  [%tmsp [~.da ~2000.1.8]]
                              [%ship [~.p 0]]
                              [%agent [~.ta '/test-agent']]
                              [%namespace [~.tas %dbo]]
                              [%table [~.tas %my-table-4]]
                              [%row-count [~.ud 1]]
                              ==
                      :-  %vector
                          :~  [%tmsp [~.da ~2000.1.4]]
                              [%ship [~.p 0]]
                              [%agent [~.ta '/test-agent']]
                              [%namespace [~.tas %dbo]]
                              [%table [~.tas %my-table-3]]
                              [%row-count [~.ud 0]]
                              ==
                      :-  %vector
                          :~  [%tmsp [~.da ~2000.1.5]]
                              [%ship [~.p 0]]
                              [%agent [~.ta '/test-agent']]
                              [%namespace [~.tas %dbo]]
                              [%table [~.tas %my-table-2]]
                              [%row-count [~.ud 1]]
                              ==
                      :-  %vector
                          :~  [%tmsp [~.da ~2000.1.9]]
                              [%ship [~.p 0]]
                              [%agent [~.ta '/test-agent']]
                              [%namespace [~.tas %ref]]
                              [%table [~.tas %my-table-4]]
                              [%row-count [~.ud 0]]
                              ==
                      :-  %vector
                          :~  [%tmsp [~.da ~2000.1.7]]
                              [%ship [~.p 0]]
                              [%agent [~.ta '/test-agent']]
                              [%namespace [~.tas %dbo]]
                              [%table [~.tas %my-table-4]]
                              [%row-count [~.ud 0]]
                              ==
                      :-  %vector
                          :~  [%tmsp [~.da ~2000.1.4]]
                              [%ship [~.p 0]]
                              [%agent [~.ta '/test-agent']]
                              [%namespace [~.tas %dbo]]
                              [%table [~.tas %my-table-2]]
                              [%row-count [~.ud 0]]
                              ==
                      ==
              [%server-time ~2000.1.11]
              [%message 'db1.sys.data-log']
              [%schema-time ~2000.1.10]
              [%data-time ~2000.1.10]
              [%vector-count 8]
              ==
      ::
      :-  %results
          :~  [%message 'SELECT']
              :-  %result-set
                  :~  :-  %vector
                          :~  [%tmsp [~.da ~2000.1.3]]
                              [%ship [~.p 0]]
                              [%agent [~.ta '/test-agent']]
                              [%namespace [~.tas %dbo]]
                              [%table [~.tas %my-table]]
                              [%row-count [~.ud 1]]
                              ==
                      :-  %vector
                          :~  [%tmsp [~.da ~2000.1.2]]
                              [%ship [~.p 0]]
                              [%agent [~.ta '/test-agent']]
                              [%namespace [~.tas %dbo]]
                              [%table [~.tas %my-table]]
                              [%row-count [~.ud 0]]
                              ==
                      :-  %vector
                          :~  [%tmsp [~.da ~2000.1.8]]
                              [%ship [~.p 0]]
                              [%agent [~.ta '/test-agent']]
                              [%namespace [~.tas %dbo]]
                              [%table [~.tas %my-table-4]]
                              [%row-count [~.ud 1]]
                              ==
                      :-  %vector
                          :~  [%tmsp [~.da ~2000.1.4]]
                              [%ship [~.p 0]]
                              [%agent [~.ta '/test-agent']]
                              [%namespace [~.tas %dbo]]
                              [%table [~.tas %my-table-3]]
                              [%row-count [~.ud 0]]
                              ==
                      :-  %vector
                          :~  [%tmsp [~.da ~2000.1.5]]
                              [%ship [~.p 0]]
                              [%agent [~.ta '/test-agent']]
                              [%namespace [~.tas %dbo]]
                              [%table [~.tas %my-table-2]]
                              [%row-count [~.ud 1]]
                              ==
                      :-  %vector
                          :~  [%tmsp [~.da ~2000.1.9]]
                              [%ship [~.p 0]]
                              [%agent [~.ta '/test-agent']]
                          [%namespace [~.tas %ref]]
                          [%table [~.tas %my-table-4]]
                          [%row-count [~.ud 0]]
                          ==
                  :-  %vector
                      :~  [%tmsp [~.da ~2000.1.7]]
                          [%ship [~.p 0]]
                          [%agent [~.ta '/test-agent']]
                          [%namespace [~.tas %dbo]]
                          [%table [~.tas %my-table-4]]
                          [%row-count [~.ud 0]]
                          ==
                  :-  %vector
                      :~  [%tmsp [~.da ~2000.1.4]]
                          [%ship [~.p 0]]
                          [%agent [~.ta '/test-agent']]
                          [%namespace [~.tas %dbo]]
                          [%table [~.tas %my-table-2]]
                          [%row-count [~.ud 0]]
                          ==
                  ==
          [%server-time ~2000.1.12]
          [%message 'db1.sys.data-log']
          [%schema-time ~2000.1.9]
          [%data-time ~2000.1.9]
          [%vector-count 8]
          ==
  ==
++  test-sys-data-log-04   ::  TRUNCATE TABLE
  =|  run=@ud
  %-  exec-9-2
  :*  run
      [~2000.1.1 %sys "CREATE DATABASE db1"]
      ::
      :+  ~2000.1.2
          %db1
          "CREATE TABLE db1..my-table (col1 @t, col2 @t) ".
          "PRIMARY KEY (col1, col2 DESC)"
      ::
      :+  ~2000.1.3
          %db1
          "INSERT INTO db1..my-table (col1, col2) ".
          "VALUES ('cord', 'cord2')"
      ::
      :+  ~2000.1.4
          %db1
          "CREATE TABLE db1..my-table-2 (col1 @p, col2 @t) ".
          "PRIMARY KEY (col1 desc, col2); ".
          "CREATE TABLE db1..my-table-3 (col1 @p, col2 @t, col3 @ud) ".
          "PRIMARY KEY (col1)"
      ::
      :+  ~2000.1.5
          %db1
          "INSERT INTO db1..my-table-2 (col1, col2) ".
          "VALUES (~zod, 'cord2')"
      ::
      [~2000.1.6 %db1 "CREATE NAMESPACE ref"]
      ::
      :+  ~2000.1.7
          %db1
          "CREATE TABLE db1..my-table-4 (col1 @p, col2 @t, col3 @ud) ".
          "PRIMARY KEY (col1, col3)"
      ::
      :+  ~2000.1.8
          %db1
          "INSERT INTO db1..my-table-4 (col1, col2, col3) ".
          "VALUES (~zod, 'cord2', 42)"
      ::
      :+  ~2000.1.9
          %db1
          "CREATE TABLE db1.ref.my-table-4 (col1 @p, col2 @t, col3 @ud) ".
          "PRIMARY KEY (col1, col3)"
      ::
      :+  ~2000.1.10
          %db1
          "TRUNCATE TABLE db1..my-table-4"
      ::
      [~2000.1.11 %db1 "FROM sys.data-log SELECT *"]
      ::
      [~2000.1.12 %db1 "FROM sys.data-log AS OF ~2000.1.8 SELECT *"]
      ::
      :-  %results
          :~  [%message 'SELECT']
              :-  %result-set
                  :~  :-  %vector
                          :~  [%tmsp [~.da ~2000.1.3]]
                              [%ship [~.p 0]]
                              [%agent [~.ta '/test-agent']]
                              [%namespace [~.tas %dbo]]
                              [%table [~.tas %my-table]]
                              [%row-count [~.ud 1]]
                              ==
                      :-  %vector
                          :~  [%tmsp [~.da ~2000.1.2]]
                              [%ship [~.p 0]]
                              [%agent [~.ta '/test-agent']]
                              [%namespace [~.tas %dbo]]
                              [%table [~.tas %my-table]]
                              [%row-count [~.ud 0]]
                              ==
                      :-  %vector
                          :~  [%tmsp [~.da ~2000.1.8]]
                              [%ship [~.p 0]]
                              [%agent [~.ta '/test-agent']]
                              [%namespace [~.tas %dbo]]
                              [%table [~.tas %my-table-4]]
                              [%row-count [~.ud 1]]
                              ==
                      :-  %vector
                          :~  [%tmsp [~.da ~2000.1.4]]
                              [%ship [~.p 0]]
                              [%agent [~.ta '/test-agent']]
                              [%namespace [~.tas %dbo]]
                              [%table [~.tas %my-table-3]]
                              [%row-count [~.ud 0]]
                              ==
                      :-  %vector
                          :~  [%tmsp [~.da ~2000.1.5]]
                              [%ship [~.p 0]]
                              [%agent [~.ta '/test-agent']]
                              [%namespace [~.tas %dbo]]
                              [%table [~.tas %my-table-2]]
                              [%row-count [~.ud 1]]
                              ==
                      :-  %vector
                          :~  [%tmsp [~.da ~2000.1.10]]
                              [%ship [~.p 0]]
                              [%agent [~.ta '/test-agent']]
                              [%namespace [~.tas %dbo]]
                              [%table [~.tas %my-table-4]]
                              [%row-count [~.ud 0]]
                              ==
                      :-  %vector
                          :~  [%tmsp [~.da ~2000.1.9]]
                              [%ship [~.p 0]]
                              [%agent [~.ta '/test-agent']]
                              [%namespace [~.tas %ref]]
                              [%table [~.tas %my-table-4]]
                              [%row-count [~.ud 0]]
                              ==
                      :-  %vector
                          :~  [%tmsp [~.da ~2000.1.7]]
                              [%ship [~.p 0]]
                              [%agent [~.ta '/test-agent']]
                              [%namespace [~.tas %dbo]]
                              [%table [~.tas %my-table-4]]
                              [%row-count [~.ud 0]]
                              ==
                      :-  %vector
                          :~  [%tmsp [~.da ~2000.1.4]]
                              [%ship [~.p 0]]
                              [%agent [~.ta '/test-agent']]
                              [%namespace [~.tas %dbo]]
                              [%table [~.tas %my-table-2]]
                              [%row-count [~.ud 0]]
                              ==
                      ==
              [%server-time ~2000.1.11]
              [%message 'db1.sys.data-log']
              [%schema-time ~2000.1.9]
              [%data-time ~2000.1.10]
              [%vector-count 9]
              ==
      ::
      :-  %results
          :~  [%message 'SELECT']
              :-  %result-set
                  :~  :-  %vector
                          :~  [%tmsp [~.da ~2000.1.3]]
                              [%ship [~.p 0]]
                              [%agent [~.ta '/test-agent']]
                              [%namespace [~.tas %dbo]]
                              [%table [~.tas %my-table]]
                              [%row-count [~.ud 1]]
                              ==
                      :-  %vector
                          :~  [%tmsp [~.da ~2000.1.2]]
                              [%ship [~.p 0]]
                              [%agent [~.ta '/test-agent']]
                              [%namespace [~.tas %dbo]]
                              [%table [~.tas %my-table]]
                              [%row-count [~.ud 0]]
                              ==
                      :-  %vector
                          :~  [%tmsp [~.da ~2000.1.8]]
                              [%ship [~.p 0]]
                              [%agent [~.ta '/test-agent']]
                              [%namespace [~.tas %dbo]]
                              [%table [~.tas %my-table-4]]
                              [%row-count [~.ud 1]]
                              ==
                      :-  %vector
                          :~  [%tmsp [~.da ~2000.1.4]]
                              [%ship [~.p 0]]
                              [%agent [~.ta '/test-agent']]
                              [%namespace [~.tas %dbo]]
                              [%table [~.tas %my-table-3]]
                              [%row-count [~.ud 0]]
                              ==
                      :-  %vector
                          :~  [%tmsp [~.da ~2000.1.5]]
                              [%ship [~.p 0]]
                              [%agent [~.ta '/test-agent']]
                              [%namespace [~.tas %dbo]]
                              [%table [~.tas %my-table-2]]
                              [%row-count [~.ud 1]]
                              ==
                      :-  %vector
                          :~  [%tmsp [~.da ~2000.1.7]]
                              [%ship [~.p 0]]
                              [%agent [~.ta '/test-agent']]
                              [%namespace [~.tas %dbo]]
                              [%table [~.tas %my-table-4]]
                              [%row-count [~.ud 0]]
                              ==
                      :-  %vector
                          :~  [%tmsp [~.da ~2000.1.4]]
                              [%ship [~.p 0]]
                              [%agent [~.ta '/test-agent']]
                              [%namespace [~.tas %dbo]]
                              [%table [~.tas %my-table-2]]
                              [%row-count [~.ud 0]]
                              ==
                      ==
              [%server-time ~2000.1.12]
              [%message 'db1.sys.data-log']
              [%schema-time ~2000.1.7]
              [%data-time ~2000.1.8]
              [%vector-count 7]
              ==
      ==
--