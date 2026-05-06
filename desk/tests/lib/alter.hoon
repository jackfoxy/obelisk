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
--
