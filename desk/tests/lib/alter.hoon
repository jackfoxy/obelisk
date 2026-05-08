/-  ast
/+  parse, *test, *test-helpers
|%
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
::
::  ALTER TABLE runtime coverage
::
++  create-base-table
  "CREATE TABLE db1..my-table ".
  "(id @ud, name @t, born @da, score @ud) ".
  "PRIMARY KEY (id)"
::
++  insert-base-rows
  "INSERT INTO db1..my-table ".
  "(id, name, born, score) VALUES ".
  "(1, 'alpha', ~2001.1.1, 10) ".
  "(2, 'beta', ~2002.2.2, 20)"
::
++  base-result-set
  :~  :-  %vector
          :~  [%id [~.ud 1]]
              [%name [~.t 'alpha']]
              [%born [~.da ~2001.1.1]]
              [%score [~.ud 10]]
              ==
      :-  %vector
          :~  [%id [~.ud 2]]
              [%name [~.t 'beta']]
              [%born [~.da ~2002.2.2]]
              [%score [~.ud 20]]
              ==
      ==
::
::  renames a table and preserves prior-schema AS OF reads
++  test-alter-table-rename-run-00
  =|  run=@ud
  %-  exec-3-2
  :*  run
      [~2000.1.1 %sys "CREATE DATABASE db1"]
      ::
      [~2000.1.2 %db1 create-base-table]
      ::
      [~2000.1.3 %db1 insert-base-rows]
      ::
      [~2000.1.4 %db1 "ALTER TABLE my-table RENAME TO renamed-table"]
      ::
      [~2000.1.5 %db1 "FROM renamed-table SELECT *"]
      ::
      [~2000.1.6 %db1 "FROM my-table AS OF ~2000.1.3 SELECT *"]
      ::
      :-  %results
          :~  [%action 'SELECT']
              [%result-set base-result-set]
              [%server-time ~2000.1.5]
              [%relation 'db1.dbo.renamed-table']
              [%schema-time ~2000.1.4]
              [%data-time ~2000.1.3]
              [%vector-count 2]
              ==
      ::
      :-  %results
          :~  [%action 'SELECT']
              [%result-set base-result-set]
              [%server-time ~2000.1.6]
              [%relation 'db1.dbo.my-table']
              [%schema-time ~2000.1.2]
              [%data-time ~2000.1.3]
              [%vector-count 2]
              ==
      ==
::
::  accepts a one-item COLUMNS clause
++  test-alter-table-columns-single-run-00
  =|  run=@ud
  %-  exec-3-1
  :*  run
      [~2010.1.1 %sys "CREATE DATABASE db1"]
      ::
      :+  ~2010.1.2
          %db1
          "CREATE TABLE my-table (id @ud) PRIMARY KEY (id)"
      ::
      [~2010.1.3 %db1 "INSERT INTO my-table VALUES (1) (2)"]
      ::
      [~2010.1.4 %db1 "ALTER TABLE my-table COLUMNS (id)"]
      ::
      [~2010.1.5 %db1 "FROM my-table SELECT *"]
      ::
      :-  %results
          :~  [%action 'SELECT']
              :-  %result-set
                  :~  :-  %vector  :~  [%id [~.ud 1]]  ==
                      :-  %vector  :~  [%id [~.ud 2]]  ==
                      ==
              [%server-time ~2010.1.5]
              [%relation 'db1.dbo.my-table']
              [%schema-time ~2010.1.4]
              [%data-time ~2010.1.3]
              [%vector-count 2]
              ==
      ==
::
::  COLUMNS changes canonical order for later implicit INSERT and SELECT *
++  test-alter-table-columns-multi-run-00
  =|  run=@ud
  %-  exec-3-1
  :*  run
      [~2010.2.1 %sys "CREATE DATABASE db1"]
      ::
      :+  ~2010.2.2
          %db1
          %-  zing
          :~  create-base-table
              insert-base-rows
              ==
      ::
      [~2010.2.3 %db1 "ALTER TABLE my-table COLUMNS (score, name, id, born)"]
      ::
      :+  ~2010.2.4
          %db1
          "INSERT INTO my-table VALUES (30, 'gamma', 3, ~2003.3.3)"
      ::
      [~2010.2.5 %db1 "FROM my-table SELECT *"]
      ::
      :-  %results
          :~  [%action 'SELECT']
              :-  %result-set
                  :~  :-  %vector
                          :~  [%score [~.ud 10]]
                              [%name [~.t 'alpha']]
                              [%id [~.ud 1]]
                              [%born [~.da ~2001.1.1]]
                              ==
                      :-  %vector
                          :~  [%score [~.ud 20]]
                              [%name [~.t 'beta']]
                              [%id [~.ud 2]]
                              [%born [~.da ~2002.2.2]]
                              ==
                      :-  %vector
                          :~  [%score [~.ud 30]]
                              [%name [~.t 'gamma']]
                              [%id [~.ud 3]]
                              [%born [~.da ~2003.3.3]]
                              ==
                      ==
              [%server-time ~2010.2.5]
              [%relation 'db1.dbo.my-table']
              [%schema-time ~2010.2.3]
              [%data-time ~2010.2.4]
              [%vector-count 3]
              ==
      ==
::
::  changes to a one-column PRIMARY KEY apply to later inserts
++  test-alter-table-primary-key-single-run-00
  =|  run=@ud
  %-  exec-3-1
  :*  run
      [~2020.1.1 %sys "CREATE DATABASE db1"]
      ::
      :+  ~2020.1.2
          %db1
          "CREATE TABLE my-table ".
          "(id @ud, code @t, label @t) ".
          "PRIMARY KEY (id); ".
          "INSERT INTO my-table VALUES ".
          "(1, 'a', 'alpha') ".
          "(2, 'b', 'beta')"
      ::
      [~2020.1.3 %db1 "ALTER TABLE my-table PRIMARY KEY (code)"]
      ::
      :+  ~2020.1.4
          %db1
          "INSERT INTO my-table VALUES (1, 'c', 'duplicate-old-id')"
      ::
      [~2020.1.5 %db1 "FROM my-table SELECT *"]
      ::
      :-  %results
          :~  [%action 'SELECT']
              :-  %result-set
                  :~  :-  %vector
                          :~  [%id [~.ud 1]]
                              [%code [~.t 'a']]
                              [%label [~.t 'alpha']]
                              ==
                      :-  %vector
                          :~  [%id [~.ud 2]]
                              [%code [~.t 'b']]
                              [%label [~.t 'beta']]
                              ==
                      :-  %vector
                          :~  [%id [~.ud 1]]
                              [%code [~.t 'c']]
                              [%label [~.t 'duplicate-old-id']]
                              ==
                      ==
              [%server-time ~2020.1.5]
              [%relation 'db1.dbo.my-table']
              [%schema-time ~2020.1.3]
              [%data-time ~2020.1.4]
              [%vector-count 3]
              ==
      ==
::
::  changes to a multi-column PRIMARY KEY apply to later inserts
++  test-alter-table-primary-key-multi-run-00
  =|  run=@ud
  %-  exec-3-1
  :*  run
      [~2020.2.1 %sys "CREATE DATABASE db1"]
      ::
      :+  ~2020.2.2
          %db1
          "CREATE TABLE my-table ".
          "(seq @ud, tenant @t, code @t) ".
          "PRIMARY KEY (seq); ".
          "INSERT INTO my-table VALUES ".
          "(1, 'a', 'x') ".
          "(2, 'b', 'x')"
      ::
      [~2020.2.3 %db1 "ALTER TABLE my-table PRIMARY KEY (tenant, code)"]
      ::
      [~2020.2.4 %db1 "INSERT INTO my-table VALUES (1, 'c', 'x')"]
      ::
      [~2020.2.5 %db1 "FROM my-table SELECT *"]
      ::
      :-  %results
          :~  [%action 'SELECT']
              :-  %result-set
                  :~  :-  %vector
                          :~  [%seq [~.ud 1]]
                              [%tenant [~.t 'a']]
                              [%code [~.t 'x']]
                              ==
                      :-  %vector
                          :~  [%seq [~.ud 2]]
                              [%tenant [~.t 'b']]
                              [%code [~.t 'x']]
                              ==
                      :-  %vector
                          :~  [%seq [~.ud 1]]
                              [%tenant [~.t 'c']]
                              [%code [~.t 'x']]
                              ==
                      ==
              [%server-time ~2020.2.5]
              [%relation 'db1.dbo.my-table']
              [%schema-time ~2020.2.3]
              [%data-time ~2020.2.4]
              [%vector-count 3]
              ==
      ==
::
::  ADD COLUMN one item populates prior rows with the @ud bunt value
++  test-alter-table-add-column-single-run-00
  =|  run=@ud
  %-  exec-4-2
  :*  run
      [~2030.1.1 %sys "CREATE DATABASE db1"]
      ::
      [~2030.1.2 %db1 create-base-table]
      ::
      [~2030.1.3 %db1 insert-base-rows]
      ::
      [~2030.1.4 %db1 "ALTER TABLE my-table ADD COLUMN (age @ud)"]
      ::
      :+  ~2030.1.5
          %db1
          "INSERT INTO my-table ".
          "(id, name, born, score, age) ".
          "VALUES (3, 'gamma', ~2003.3.3, 30, 9)"
      ::
      [~2030.1.6 %db1 "FROM my-table SELECT *"]
      ::
      [~2030.1.7 %db1 "FROM my-table AS OF ~2030.1.3 SELECT *"]
      ::
      :-  %results
          :~  [%action 'SELECT']
              :-  %result-set
                  :~  :-  %vector
                          :~  [%id [~.ud 1]]
                              [%name [~.t 'alpha']]
                              [%born [~.da ~2001.1.1]]
                              [%score [~.ud 10]]
                              [%age [~.ud 0]]
                              ==
                      :-  %vector
                          :~  [%id [~.ud 2]]
                              [%name [~.t 'beta']]
                              [%born [~.da ~2002.2.2]]
                              [%score [~.ud 20]]
                              [%age [~.ud 0]]
                              ==
                      :-  %vector
                          :~  [%id [~.ud 3]]
                              [%name [~.t 'gamma']]
                              [%born [~.da ~2003.3.3]]
                              [%score [~.ud 30]]
                              [%age [~.ud 9]]
                              ==
                      ==
              [%server-time ~2030.1.6]
              [%relation 'db1.dbo.my-table']
              [%schema-time ~2030.1.4]
              [%data-time ~2030.1.5]
              [%vector-count 3]
              ==
      ::
      :-  %results
          :~  [%action 'SELECT']
              [%result-set base-result-set]
              [%server-time ~2030.1.7]
              [%relation 'db1.dbo.my-table']
              [%schema-time ~2030.1.2]
              [%data-time ~2030.1.3]
              [%vector-count 2]
              ==
      ==
::
::  ADD COLUMN multi item populates prior rows with @da, @sd, and @rd bunts
++  test-alter-table-add-column-multi-bunts-run-00
  =|  run=@ud
  %-  exec-4-2
  :*  run
      [~2030.2.1 %sys "CREATE DATABASE db1"]
      ::
      [~2030.2.2 %db1 create-base-table]
      ::
      [~2030.2.3 %db1 insert-base-rows]
      ::
      :+  ~2030.2.4
          %db1
          "ALTER TABLE my-table ".
          "ADD COLUMN (created @da, balance @sd, ratio @rd)"
      ::
      :+  ~2030.2.5
          %db1
          "INSERT INTO my-table ".
          "(id, name, born, score, created, balance, ratio) ".
          "VALUES (3, 'gamma', ~2003.3.3, 30, ~2030.2.5, --7, .~1.5)"
      ::
      [~2030.2.6 %db1 "FROM my-table SELECT *"]
      ::
      [~2030.2.7 %db1 "FROM my-table AS OF ~2030.2.3 SELECT *"]
      ::
      :-  %results
          :~  [%action 'SELECT']
              :-  %result-set
                  :~  :-  %vector
                          :~  [%id [~.ud 1]]
                              [%name [~.t 'alpha']]
                              [%born [~.da ~2001.1.1]]
                              [%score [~.ud 10]]
                              [%created [~.da ~2000.1.1]]
                              [%balance [~.sd --0]]
                              [%ratio [~.rd .~0]]
                              ==
                      :-  %vector
                          :~  [%id [~.ud 2]]
                              [%name [~.t 'beta']]
                              [%born [~.da ~2002.2.2]]
                              [%score [~.ud 20]]
                              [%created [~.da ~2000.1.1]]
                              [%balance [~.sd --0]]
                              [%ratio [~.rd .~0]]
                              ==
                      :-  %vector
                          :~  [%id [~.ud 3]]
                              [%name [~.t 'gamma']]
                              [%born [~.da ~2003.3.3]]
                              [%score [~.ud 30]]
                              [%created [~.da ~2030.2.5]]
                              [%balance [~.sd --7]]
                              [%ratio [~.rd .~1.5]]
                              ==
                      ==
              [%server-time ~2030.2.6]
              [%relation 'db1.dbo.my-table']
              [%schema-time ~2030.2.4]
              [%data-time ~2030.2.5]
              [%vector-count 3]
              ==
      ::
      :-  %results
          :~  [%action 'SELECT']
              [%result-set base-result-set]
              [%server-time ~2030.2.7]
              [%relation 'db1.dbo.my-table']
              [%schema-time ~2030.2.2]
              [%data-time ~2030.2.3]
              [%vector-count 2]
              ==
      ==
::
::  one-item DROP COLUMN, RENAME COLUMN, and ALTER COLUMN affect later writes
++  test-alter-table-drop-rename-alter-single-run-00
  =|  run=@ud
  %-  exec-4-2
  :*  run
      [~2040.1.1 %sys "CREATE DATABASE db1"]
      ::
      :+  ~2040.1.2
          %db1
          "CREATE TABLE my-table ".
          "(id @ud, old-name @t, note @t, metric @ud) ".
          "PRIMARY KEY (id); ".
          "INSERT INTO my-table VALUES ".
          "(1, 'alpha', 'drop', 0) ".
          "(2, 'beta', 'drop', 0)"
      ::
      :+  ~2040.1.3
          %db1
          "ALTER TABLE my-table ".
          "DROP COLUMN (note), ".
          "RENAME COLUMN (old-name TO name), ".
          "ALTER COLUMN (metric @sd)"
      ::
      [~2040.1.4 %db1 "UPDATE my-table SET metric=--7 WHERE id = 1"]
      ::
      [~2040.1.5 %db1 "INSERT INTO my-table VALUES (3, 'gamma', --9)"]
      ::
      [~2040.1.6 %db1 "FROM my-table SELECT *"]
      ::
      [~2040.1.7 %db1 "FROM my-table AS OF ~2040.1.2 SELECT *"]
      ::
      :-  %results
          :~  [%action 'SELECT']
              :-  %result-set
                  :~  :-  %vector
                          :~  [%id [~.ud 1]]
                              [%name [~.t 'alpha']]
                              [%metric [~.sd --7]]
                              ==
                      :-  %vector
                          :~  [%id [~.ud 2]]
                              [%name [~.t 'beta']]
                              [%metric [~.sd --0]]
                              ==
                      :-  %vector
                          :~  [%id [~.ud 3]]
                              [%name [~.t 'gamma']]
                              [%metric [~.sd --9]]
                              ==
                      ==
              [%server-time ~2040.1.6]
              [%relation 'db1.dbo.my-table']
              [%schema-time ~2040.1.3]
              [%data-time ~2040.1.5]
              [%vector-count 3]
              ==
      ::
      :-  %results
          :~  [%action 'SELECT']
              :-  %result-set
                  :~  :-  %vector
                          :~  [%id [~.ud 1]]
                              [%old-name [~.t 'alpha']]
                              [%note [~.t 'drop']]
                              [%metric [~.ud 0]]
                              ==
                      :-  %vector
                          :~  [%id [~.ud 2]]
                              [%old-name [~.t 'beta']]
                              [%note [~.t 'drop']]
                              [%metric [~.ud 0]]
                              ==
                      ==
              [%server-time ~2040.1.7]
              [%relation 'db1.dbo.my-table']
              [%schema-time ~2040.1.2]
              [%data-time ~2040.1.2]
              [%vector-count 2]
              ==
      ==
::
::  multi-item DROP COLUMN, RENAME COLUMN, and ALTER COLUMN affect later writes
++  test-alter-table-drop-rename-alter-multi-run-00
  =|  run=@ud
  %-  exec-3-1
  :*  run
      [~2040.2.1 %sys "CREATE DATABASE db1"]
      ::
      :+  ~2040.2.2
          %db1
          "CREATE TABLE my-table ".
          "(id @ud, old-a @t, old-b @t, ".
          "note-a @t, note-b @t, metric @ud, measure @ud) ".
          "PRIMARY KEY (id); ".
          "INSERT INTO my-table VALUES ".
          "(1, 'a1', 'b1', 'drop-a', 'drop-b', 0, 0)"
      ::
      :+  ~2040.2.3
          %db1
          "ALTER TABLE my-table ".
          "DROP COLUMN (note-a, note-b), ".
          "RENAME COLUMN (old-a TO a, old-b TO b), ".
          "ALTER COLUMN (metric @sd, measure @rd)"
      ::
      :+  ~2040.2.4
          %db1
          "UPDATE my-table SET metric=--5, measure=.~2.5 WHERE id = 1"
      ::
      [~2040.2.5 %db1 "FROM my-table SELECT *"]
      ::
      :-  %results
          :~  [%action 'SELECT']
              :-  %result-set
                  :~  :-  %vector
                          :~  [%id [~.ud 1]]
                              [%a [~.t 'a1']]
                              [%b [~.t 'b1']]
                              [%metric [~.sd --5]]
                              [%measure [~.rd .~2.5]]
                              ==
                      ==
              [%server-time ~2040.2.5]
              [%relation 'db1.dbo.my-table']
              [%schema-time ~2040.2.3]
              [%data-time ~2040.2.4]
              [%vector-count 1]
              ==
      ==
::
::  UPDATE, DELETE, and INSERT operate on the altered schema while AS OF sees old data
++  test-alter-table-dml-after-schema-change-run-00
  =|  run=@ud
  %-  exec-6-2
  :*  run
      [~2050.1.1 %sys "CREATE DATABASE db1"]
      ::
      :+  ~2050.1.2
          %db1
          "CREATE TABLE my-table ".
          "(id @ud, name @t, score @ud) ".
          "PRIMARY KEY (id)"
      ::
      :+  ~2050.1.3
          %db1
          "INSERT INTO my-table VALUES ".
          "(1, 'alpha', 10) ".
          "(2, 'beta', 20) ".
          "(3, 'gamma', 30)"
      ::
      :+  ~2050.1.4
          %db1
          "ALTER TABLE my-table ".
          "ADD COLUMN (status @t), ".
          "RENAME COLUMN (name TO title), ".
          "COLUMNS (id, title, status, score)"
      ::
      :+  ~2050.1.5
          %db1
          "UPDATE my-table SET status='kept', score=11 WHERE id = 1"
      ::
      [~2050.1.6 %db1 "DELETE FROM my-table WHERE id = 2"]
      ::
      :+  ~2050.1.7
          %db1
          "INSERT INTO my-table VALUES (4, 'delta', 'new', 40)"
      ::
      [~2050.1.8 %db1 "FROM my-table SELECT *"]
      ::
      [~2050.1.9 %db1 "FROM my-table AS OF ~2050.1.3 SELECT *"]
      ::
      :-  %results
          :~  [%action 'SELECT']
              :-  %result-set
                  :~  :-  %vector
                          :~  [%id [~.ud 1]]
                              [%title [~.t 'alpha']]
                              [%status [~.t 'kept']]
                              [%score [~.ud 11]]
                              ==
                      :-  %vector
                          :~  [%id [~.ud 3]]
                              [%title [~.t 'gamma']]
                              [%status [~.t 'Default']]
                              [%score [~.ud 30]]
                              ==
                      :-  %vector
                          :~  [%id [~.ud 4]]
                              [%title [~.t 'delta']]
                              [%status [~.t 'new']]
                              [%score [~.ud 40]]
                              ==
                      ==
              [%server-time ~2050.1.8]
              [%relation 'db1.dbo.my-table']
              [%schema-time ~2050.1.4]
              [%data-time ~2050.1.7]
              [%vector-count 3]
              ==
      ::
      :-  %results
          :~  [%action 'SELECT']
              :-  %result-set
                  :~  :-  %vector
                          :~  [%id [~.ud 1]]
                              [%name [~.t 'alpha']]
                              [%score [~.ud 10]]
                              ==
                      :-  %vector
                          :~  [%id [~.ud 2]]
                              [%name [~.t 'beta']]
                              [%score [~.ud 20]]
                              ==
                      :-  %vector
                          :~  [%id [~.ud 3]]
                              [%name [~.t 'gamma']]
                              [%score [~.ud 30]]
                              ==
                      ==
              [%server-time ~2050.1.9]
              [%relation 'db1.dbo.my-table']
              [%schema-time ~2050.1.2]
              [%data-time ~2050.1.3]
              [%vector-count 3]
              ==
      ==
::
::  all in-scope ALTER TABLE clauses in one statement
++  test-alter-table-full-clause-run-00
  =|  run=@ud
  %-  exec-5-2
  :*  run
      [~2060.1.1 %sys "CREATE DATABASE db1"]
      ::
      :+  ~2060.1.2
          %db1
          "CREATE TABLE my-table ".
          "(id @ud, code @t, old-name @t, amt @ud, keep @ud, drop-me @t) ".
          "PRIMARY KEY (id)"
      ::
      :+  ~2060.1.3
          %db1
          "INSERT INTO my-table VALUES (1, 'a', 'before', 0, 7, 'drop')"
      ::
      :+  ~2060.1.5
          %db1
          "ALTER TABLE my-table ".
          "RENAME TO full-table, ".
          "COLUMNS (code, id, title, amt, created, keep), ".
          "PRIMARY KEY (code, id), ".
          "ADD COLUMN (created @da), ".
          "DROP COLUMN (drop-me), ".
          "RENAME COLUMN (old-name TO title), ".
          "ALTER COLUMN (amt @sd) ".
          "AS OF ~2060.1.4"
      ::
      :+  ~2060.1.6
          %db1
          "UPDATE full-table SET title='changed', amt=--9 WHERE code = 'a'"
      ::
      :+  ~2060.1.7
          %db1
          "INSERT INTO full-table VALUES ('b', 2, 'after', --3, ~2060.1.7, 8)"
      ::
      [~2060.1.8 %db1 "FROM full-table SELECT *"]
      ::
      [~2060.1.9 %db1 "FROM my-table AS OF ~2060.1.3 SELECT *"]
      ::
      :-  %results
          :~  [%action 'SELECT']
              :-  %result-set
                  :~  :-  %vector
                          :~  [%code [~.t 'a']]
                              [%id [~.ud 1]]
                              [%title [~.t 'changed']]
                              [%amt [~.sd --9]]
                              [%created [~.da ~2000.1.1]]
                              [%keep [~.ud 7]]
                              ==
                      :-  %vector
                          :~  [%code [~.t 'b']]
                              [%id [~.ud 2]]
                              [%title [~.t 'after']]
                              [%amt [~.sd --3]]
                              [%created [~.da ~2060.1.7]]
                              [%keep [~.ud 8]]
                              ==
                      ==
              [%server-time ~2060.1.8]
              [%relation 'db1.dbo.full-table']
              [%schema-time ~2060.1.4]
              [%data-time ~2060.1.7]
              [%vector-count 2]
              ==
      ::
      :-  %results
          :~  [%action 'SELECT']
              :-  %result-set
                  :~  :-  %vector
                          :~  [%id [~.ud 1]]
                              [%code [~.t 'a']]
                              [%old-name [~.t 'before']]
                              [%amt [~.ud 0]]
                              [%keep [~.ud 7]]
                              [%drop-me [~.t 'drop']]
                              ==
                      ==
              [%server-time ~2060.1.9]
              [%relation 'db1.dbo.my-table']
              [%schema-time ~2060.1.2]
              [%data-time ~2060.1.3]
              [%vector-count 1]
              ==
      ==
::
::  accepts ALTER TABLE AS OF greater than latest schema and data timestamps
++  test-alter-table-as-of-run-00
  =|  run=@ud
  %-  exec-3-1
  :*  run
      [~2070.1.1 %sys "CREATE DATABASE db1"]
      ::
      [~2070.1.2 %db1 create-base-table]
      ::
      [~2070.1.3 %db1 insert-base-rows]
      ::
      :+  ~2070.1.5
          %db1
          "ALTER TABLE my-table ADD COLUMN (asof-col @t) AS OF ~2070.1.4"
      ::
      [~2070.1.6 %db1 "FROM my-table SELECT *"]
      ::
      :-  %results
          :~  [%action 'SELECT']
              :-  %result-set
                  :~  :-  %vector
                          :~  [%id [~.ud 1]]
                              [%name [~.t 'alpha']]
                              [%born [~.da ~2001.1.1]]
                              [%score [~.ud 10]]
                              [%asof-col [~.t 'Default']]
                              ==
                      :-  %vector
                          :~  [%id [~.ud 2]]
                              [%name [~.t 'beta']]
                              [%born [~.da ~2002.2.2]]
                              [%score [~.ud 20]]
                              [%asof-col [~.t 'Default']]
                              ==
                      ==
              [%server-time ~2070.1.6]
              [%relation 'db1.dbo.my-table']
              [%schema-time ~2070.1.4]
              [%data-time ~2070.1.3]
              [%vector-count 2]
              ==
      ==
::
::  rejects ALTER TABLE AS OF equal to latest schema timestamp
++  test-fail-alter-table-as-of-schema-00
  =|  run=@ud
  %-  failon-2
  :*  run
      [~2070.2.1 %sys "CREATE DATABASE db1"]
      ::
      [~2070.2.2 %db1 create-base-table]
      ::
      :+  ~2070.2.3
          %db1
          "ALTER TABLE my-table ADD COLUMN (extra @t) AS OF ~2070.2.2"
      ::
      'ALTER TABLE: %my-table as-of schema time out of order'
      ==
::
::  rejects ALTER TABLE AS OF equal to latest data timestamp
++  test-fail-alter-table-as-of-data-00
  =|  run=@ud
  %-  failon-3
  :*  run
      [~2070.3.1 %sys "CREATE DATABASE db1"]
      ::
      [~2070.3.2 %db1 create-base-table]
      ::
      [~2070.3.3 %db1 insert-base-rows]
      ::
      :+  ~2070.3.4
          %db1
          "ALTER TABLE my-table ADD COLUMN (extra @t) AS OF ~2070.3.3"
      ::
      'ALTER TABLE: %my-table as-of data time out of order'
      ==
::
::  rejects ALTER TABLE after a query in the same script
++  test-fail-alter-table-state-change-after-query-00
  =|  run=@ud
  %-  failon-2
  :*  run
      [~2070.4.1 %sys "CREATE DATABASE db1"]
      ::
      [~2070.4.2 %db1 create-base-table]
      ::
      :+  ~2070.4.3
          %db1
          "FROM my-table SELECT *; ".
          "ALTER TABLE my-table ADD COLUMN (extra @t)"
      ::
      'ALTER TABLE: state change after query in script'
      ==
::
::  rejects altering a table that does not exist
++  test-fail-alter-table-missing-table-00
  =|  run=@ud
  %-  failon-1
  :*  run
      [~2080.1.1 %sys "CREATE DATABASE db1"]
      ::
      [~2080.1.2 %db1 "ALTER TABLE missing-table ADD COLUMN (extra @t)"]
      ::
      'ALTER TABLE: %missing-table does not exist in %dbo'
      ==
::
::  rejects renaming a table over an existing table
++  test-fail-alter-table-rename-target-exists-00
  =|  run=@ud
  %-  failon-2
  :*  run
      [~2080.2.1 %sys "CREATE DATABASE db1"]
      ::
      :+  ~2080.2.2
          %db1
          "CREATE TABLE my-table (id @ud) PRIMARY KEY (id); ".
          "CREATE TABLE other-table (id @ud) PRIMARY KEY (id)"
      ::
      [~2080.2.3 %db1 "ALTER TABLE my-table RENAME TO other-table"]
      ::
      'ALTER TABLE: %other-table exists in %dbo'
      ==
::
::  rejects adding a column that already exists
++  test-fail-alter-table-add-existing-column-00
  =|  run=@ud
  %-  failon-2
  :*  run
      [~2080.3.1 %sys "CREATE DATABASE db1"]
      ::
      [~2080.3.2 %db1 create-base-table]
      ::
      [~2080.3.3 %db1 "ALTER TABLE my-table ADD COLUMN (name @t)"]
      ::
      'ALTER TABLE: %my-table column %name already exists'
      ==
::
::  rejects dropping a column that does not exist
++  test-fail-alter-table-drop-missing-column-00
  =|  run=@ud
  %-  failon-2
  :*  run
      [~2080.4.1 %sys "CREATE DATABASE db1"]
      ::
      [~2080.4.2 %db1 create-base-table]
      ::
      [~2080.4.3 %db1 "ALTER TABLE my-table DROP COLUMN (missing)"]
      ::
      'ALTER TABLE: %my-table column %missing does not exist'
      ==
::
::  rejects renaming a column that does not exist
++  test-fail-alter-table-rename-missing-column-00
  =|  run=@ud
  %-  failon-2
  :*  run
      [~2080.5.1 %sys "CREATE DATABASE db1"]
      ::
      [~2080.5.2 %db1 create-base-table]
      ::
      [~2080.5.3 %db1 "ALTER TABLE my-table RENAME COLUMN (missing TO found)"]
      ::
      'ALTER TABLE: %my-table column %missing does not exist'
      ==
::
::  rejects renaming a column over an existing column
++  test-fail-alter-table-rename-column-target-exists-00
  =|  run=@ud
  %-  failon-2
  :*  run
      [~2080.6.1 %sys "CREATE DATABASE db1"]
      ::
      [~2080.6.2 %db1 create-base-table]
      ::
      [~2080.6.3 %db1 "ALTER TABLE my-table RENAME COLUMN (name TO score)"]
      ::
      'ALTER TABLE: %my-table column %score already exists'
      ==
::
::  rejects altering a column that does not exist
++  test-fail-alter-table-alter-missing-column-00
  =|  run=@ud
  %-  failon-2
  :*  run
      [~2080.7.1 %sys "CREATE DATABASE db1"]
      ::
      [~2080.7.2 %db1 create-base-table]
      ::
      [~2080.7.3 %db1 "ALTER TABLE my-table ALTER COLUMN (missing @t)"]
      ::
      'ALTER TABLE: %my-table column %missing does not exist'
      ==
::
::  rejects PRIMARY KEY columns that are not in the post-alter schema
++  test-fail-alter-table-primary-key-missing-column-00
  =|  run=@ud
  %-  failon-2
  :*  run
      [~2080.8.1 %sys "CREATE DATABASE db1"]
      ::
      [~2080.8.2 %db1 create-base-table]
      ::
      [~2080.8.3 %db1 "ALTER TABLE my-table PRIMARY KEY (missing)"]
      ::
      'ALTER TABLE: key column not in column definitions %missing'
      ==
::
::  rejects duplicate column names in COLUMNS
++  test-fail-alter-table-columns-duplicate-00
  =|  run=@ud
  %-  failon-2
  :*  run
      [~2080.9.1 %sys "CREATE DATABASE db1"]
      ::
      [~2080.9.2 %db1 create-base-table]
      ::
      [~2080.9.3 %db1 "ALTER TABLE my-table COLUMNS (id, name, id, born, score)"]
      ::
      'ALTER TABLE: duplicate column names in COLUMNS %id'
      ==
::
::  rejects duplicate column names in PRIMARY KEY
++  test-fail-alter-table-primary-key-duplicate-00
  =|  run=@ud
  %-  failon-2
  :*  run
      [~2080.10.1 %sys "CREATE DATABASE db1"]
      ::
      [~2080.10.2 %db1 create-base-table]
      ::
      [~2080.10.3 %db1 "ALTER TABLE my-table PRIMARY KEY (id, id)"]
      ::
      'ALTER TABLE: duplicate column names in key %id'
      ==
--
