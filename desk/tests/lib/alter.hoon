/-  ast
/+  parse, *test, *test-helpers
|%
::
::  ALTER DATABASE
::
::  parses ALTER DATABASE with mixed-case keywords and extra whitespace
++  test-alter-database-parse-00
  %+  expect-eq
    !>  ~[[%alter-database name='old-db' new-name='new-db']]
    !>  %-  parse:parse(default-database 'dummy')
        " aLtEr \0d dataBase  old-db  rename \09 TO  new-db "
::
::  renames a database and reflects the change in sys.sys.databases
++  test-alter-database-run-00
  =|  run=@ud
  %-  exec-1-1
  :*  run
      [~2000.1.1 %sys "CREATE DATABASE db1"]
      ::
      [~2000.1.2 %sys "ALTER DATABASE db1 RENAME TO db2"]
      ::
      [~2000.1.3 %sys "FROM sys.sys.databases SELECT *"]
      ::
      :-  %results
          :~  [%action 'SELECT']
              :-  %result-set
                  :~  :-  %vector
                          :~  [%database [~.tas %db2]]
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
              [%server-time ~2000.1.3]
              [%relation 'sys.sys.databases']
              [%schema-time ~2000.1.1]
              [%data-time ~2000.1.2]
              [%vector-count 3]
              ==
      ==
::
::  allows schema changes through the renamed database name
++  test-alter-database-run-01
  =|  run=@ud
  %-  exec-1-1
  :*  run
      [~2000.1.1 %sys "CREATE DATABASE db1"]
      ::
      [~2000.1.2 %sys "ALTER DATABASE db1 RENAME TO db2"]
      ::
      [~2000.1.3 %sys "CREATE TABLE db2..my-table (col1 @t) PRIMARY KEY (col1)"]
      ::
      :-  %results
          :~  [%action 'CREATE TABLE %my-table']
              [%server-time ~2000.1.3]
              [%schema-time ~2000.1.3]
              ==
      ==
::
::  rejects attempts to rename the sys database
++  test-fail-alter-database-00
  =|  run=@ud
  %-  failon-0
  :*  run
      [~2000.1.1 %sys "ALTER DATABASE sys RENAME TO db1"]
      ::
      'database %sys cannot be renamed'
      ==
::
::  rejects renaming a database to an existing database name
++  test-fail-alter-database-01
  =|  run=@ud
  %-  failon-1
  :*  run
      [~2000.1.1 %sys "CREATE DATABASE db1; CREATE DATABASE db2"]
      ::
      [~2000.1.2 %sys "ALTER DATABASE db1 RENAME TO db2"]
      ::
      'database %db2 already exists'
      ==
::
::  rejects renaming a database that does not exist
++  test-fail-alter-database-02
  =|  run=@ud
  %-  failon-0
  :*  run
      [~2000.1.1 %sys "ALTER DATABASE missing-db RENAME TO db2"]
      ::
      'database %missing-db does not exist'
      ==
::
::  copies a table into a new namespace and preserves old as-of reads
++  test-alter-namespace-table-00
  =|  run=@ud
  %-  exec-4-2-ordered
  :*  run
      [~2000.1.1 %sys "CREATE DATABASE db1"]
      ::
      [~2000.1.2 %db1 "CREATE NAMESPACE ns1"]
      ::
      [~2000.1.3 %db1 "CREATE TABLE my-table (col1 @t) PRIMARY KEY (col1)"]
      ::
      [~2000.1.4 %db1 "INSERT INTO my-table (col1) VALUES ('cord')"]
      ::
      [~2000.1.5 %db1 "ALTER NAMESPACE ns1 TRANSFER TABLE my-table"]
      ::
      [~2000.1.6 %db1 "FROM sys.tables SELECT *"]
      ::
      :+  ~2000.1.7
          %db1
          "FROM dbo.my-table AS OF ~2000.1.4 SELECT *"
      ::
      :-  %results
          :~  [%action 'SELECT']
              :-  %result-set
                  :~  :-  %vector
                          :~  [%namespace [~.tas %dbo]]
                              [%name [~.tas %my-table]]
                              [%agent [~.ta '/test-agent']]
                              [%tmsp [~.da ~2000.1.3]]
                              [%row-count [~.ud 1]]
                              ==
                      :-  %vector
                          :~  [%namespace [~.tas %ns1]]
                              [%name [~.tas %my-table]]
                              [%agent [~.ta '/test-agent']]
                              [%tmsp [~.da ~2000.1.5]]
                              [%row-count [~.ud 1]]
                              ==
                      ==
              [%server-time ~2000.1.6]
              [%relation 'db1.sys.tables']
              [%schema-time ~2000.1.5]
              [%data-time ~2000.1.5]
              [%vector-count 2]
              ==
      ::
      :-  %results
          :~  [%action 'SELECT']
              :-  %result-set
                  :~  :-  %vector
                          :~  [%col1 [~.t 'cord']]
                              ==
                      ==
              [%server-time ~2000.1.7]
              [%relation 'db1.dbo.my-table']
              [%schema-time ~2000.1.3]
              [%data-time ~2000.1.4]
              [%vector-count 1]
              ==
      ==
::
::  records cross-database table transfers in both database logs
++  test-alter-namespace-table-01
  =|  run=@ud
  %-  exec-4-2-ordered
  :*  run
      [~2000.1.1 %sys "CREATE DATABASE db1"]
      ::
      [~2000.1.2 %sys "CREATE DATABASE db2"]
      ::
      [~2000.1.3 %db1 "CREATE NAMESPACE db2.ns2"]
      ::
      [~2000.1.4 %db1 "CREATE TABLE my-table (col1 @t) PRIMARY KEY (col1)"]
      ::
      [~2000.1.5 %db1 "ALTER NAMESPACE db2.ns2 TRANSFER TABLE my-table"]
      ::
      :+  ~2000.1.6
          %db1
          "FROM sys.sys-log SELECT action, component, database, namespace, ".
          "relation, target-database, target-namespace, target-relation"
      ::
      :+  ~2000.1.7
          %db2
          "FROM sys.sys-log SELECT action, component, database, namespace, ".
          "relation, target-database, target-namespace, target-relation"
      ::
      :-  %results
          :~  [%action 'SELECT']
              :-  %result-set
                  :~  :-  %vector
                          :~  [%action [~.tas %create]]
                              [%component [~.tas %namespace]]
                              [%database [~.tas %db1]]
                              [%namespace [~.tas %dbo]]
                              [%relation [~.tas '']]
                              [%target-database [~.tas '']]
                              [%target-namespace [~.tas '']]
                              [%target-relation [~.tas '']]
                              ==
                      :-  %vector
                          :~  [%action [~.tas %create]]
                              [%component [~.tas %namespace]]
                              [%database [~.tas %db1]]
                              [%namespace [~.tas %sys]]
                              [%relation [~.tas '']]
                              [%target-database [~.tas '']]
                              [%target-namespace [~.tas '']]
                              [%target-relation [~.tas '']]
                              ==
                      :-  %vector
                          :~  [%action [~.tas %create]]
                              [%component [~.tas %table]]
                              [%database [~.tas %db1]]
                              [%namespace [~.tas %dbo]]
                              [%relation [~.tas %my-table]]
                              [%target-database [~.tas '']]
                              [%target-namespace [~.tas '']]
                              [%target-relation [~.tas '']]
                              ==
                      :-  %vector
                          :~  [%action [~.tas %alter]]
                              [%component [~.tas %table]]
                              [%database [~.tas %db1]]
                              [%namespace [~.tas %dbo]]
                              [%relation [~.tas %my-table]]
                              [%target-database [~.tas %db2]]
                              [%target-namespace [~.tas %ns2]]
                              [%target-relation [~.tas %my-table]]
                              ==
                      ==
              [%server-time ~2000.1.6]
              [%relation 'db1.sys.sys-log']
              [%schema-time ~2000.1.5]
              [%data-time ~2000.1.5]
              [%vector-count 4]
              ==
      ::
      :-  %results
          :~  [%action 'SELECT']
              :-  %result-set
                  :~  :-  %vector
                          :~  [%action [~.tas %create]]
                              [%component [~.tas %namespace]]
                              [%database [~.tas %db2]]
                              [%namespace [~.tas %dbo]]
                              [%relation [~.tas '']]
                              [%target-database [~.tas '']]
                              [%target-namespace [~.tas '']]
                              [%target-relation [~.tas '']]
                              ==
                      :-  %vector
                          :~  [%action [~.tas %create]]
                              [%component [~.tas %namespace]]
                              [%database [~.tas %db2]]
                              [%namespace [~.tas %ns2]]
                              [%relation [~.tas '']]
                              [%target-database [~.tas '']]
                              [%target-namespace [~.tas '']]
                              [%target-relation [~.tas '']]
                              ==
                      :-  %vector
                          :~  [%action [~.tas %create]]
                              [%component [~.tas %namespace]]
                              [%database [~.tas %db2]]
                              [%namespace [~.tas %sys]]
                              [%relation [~.tas '']]
                              [%target-database [~.tas '']]
                              [%target-namespace [~.tas '']]
                              [%target-relation [~.tas '']]
                              ==
                      :-  %vector
                          :~  [%action [~.tas %alter]]
                              [%component [~.tas %table]]
                              [%database [~.tas %db1]]
                              [%namespace [~.tas %dbo]]
                              [%relation [~.tas %my-table]]
                              [%target-database [~.tas %db2]]
                              [%target-namespace [~.tas %ns2]]
                              [%target-relation [~.tas %my-table]]
                              ==
                      ==
              [%server-time ~2000.1.7]
              [%relation 'db2.sys.sys-log']
              [%schema-time ~2000.1.5]
              [%data-time ~2000.1.5]
              [%vector-count 4]
              ==
      ==
::
::  rejects alter namespace when as-of equals latest schema time
++  test-fail-alter-namespace-table-00
  =|  run=@ud
  %-  failon-3
  :*  run
      [~2000.1.1 %sys "CREATE DATABASE db1"]
      ::
      [~2000.1.2 %db1 "CREATE NAMESPACE ns1"]
      ::
      [~2000.1.3 %db1 "CREATE TABLE my-table (col1 @t) PRIMARY KEY (col1)"]
      ::
      :+  ~2000.1.4
          %db1
          "ALTER NAMESPACE ns1 TRANSFER TABLE my-table AS OF ~2000.1.3"
      ::
      'ALTER NAMESPACE: %my-table as-of schema time out of order'
      ==
::
::  rejects alter namespace when as-of precedes latest schema time
++  test-fail-alter-namespace-table-01
  =|  run=@ud
  %-  failon-3
  :*  run
      [~2000.1.1 %sys "CREATE DATABASE db1"]
      ::
      [~2000.1.2 %db1 "CREATE NAMESPACE ns1"]
      ::
      [~2000.1.3 %db1 "CREATE TABLE my-table (col1 @t) PRIMARY KEY (col1)"]
      ::
      :+  ~2000.1.4
          %db1
          "ALTER NAMESPACE ns1 TRANSFER TABLE my-table AS OF ~2000.1.2"
      ::
      'ALTER NAMESPACE: %my-table as-of schema time out of order'
      ==
--
