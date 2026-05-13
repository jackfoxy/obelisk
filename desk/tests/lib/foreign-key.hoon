/-  ast
/+  *test-helpers
|%
::
++  create-parent
  "CREATE TABLE parent ".
  "(id @ud, label @t) ".
  "PRIMARY KEY (id); "
++  create-child
  "CREATE TABLE child ".
  "(id @ud, parent-id @ud, note @t) ".
  "PRIMARY KEY (id) ".
  "FOREIGN KEY (parent-id) REFERENCES parent (id); "
++  create-child-cascade
  "CREATE TABLE child ".
  "(id @ud, parent-id @ud, note @t) ".
  "PRIMARY KEY (id) ".
  "FOREIGN KEY (parent-id) REFERENCES parent (id) ".
  "ON DELETE CASCADE ON UPDATE CASCADE; "
++  create-child-set-default
  "CREATE TABLE child ".
  "(id @ud, parent-id @ud, note @t) ".
  "PRIMARY KEY (id) ".
  "FOREIGN KEY (parent-id) REFERENCES parent (id) ".
  "ON DELETE SET DEFAULT ON UPDATE SET DEFAULT; "
++  insert-parents
  "INSERT INTO parent (id, label) ".
  "VALUES (0, 'bunt') (1, 'one') (2, 'two'); "
++  insert-children
  "INSERT INTO child (id, parent-id, note) ".
  "VALUES (10, 1, 'alpha') (11, 2, 'bravo'); "
++  child-10-11
  :~  :-  %vector
          :~  [%id [~.ud 10]]
              [%parent-id [~.ud 1]]
              [%note [~.t 'alpha']]
              ==
      :-  %vector
          :~  [%id [~.ud 11]]
              [%parent-id [~.ud 2]]
              [%note [~.t 'bravo']]
              ==
      ==
++  child-10-parent-0
  :~  :-  %vector
          :~  [%id [~.ud 10]]
              [%parent-id [~.ud 0]]
              [%note [~.t 'alpha']]
              ==
      ==
++  composite-child-10-updated
  :~  :-  %vector
          :~  [%id [~.ud 10]]
              [%parent-tenant [~.ud 3]]
              [%parent-code [~.ud 9]]
              [%note [~.t 'alpha']]
              ==
      ==
::
::  CREATE TABLE with FOREIGN KEY and valid INSERTs
++  test-foreign-key-00
  =|  run=@ud
  %-  exec-2-1
  :*  run
      :+  ~2030.1.1
          %db1
          %-  zing  :~  "CREATE DATABASE db1; "
                        create-parent
                        create-child
                        ==
      ::
      [~2030.1.2 %db1 insert-parents]
      ::
      [~2030.1.3 %db1 insert-children]
      ::
      :+  ~2030.1.4
          %db1
          "FROM child SELECT id, parent-id, note"
      ::
      :-  %results
          :~  [%action 'SELECT']
              [%result-set child-10-11]
              [%server-time ~2030.1.4]
              [%relation 'db1.dbo.child']
              [%schema-time ~2030.1.1]
              [%data-time ~2030.1.3]
              [%vector-count 2]
              ==
      ==
::
::  ALTER TABLE ADD FOREIGN KEY over existing valid rows
++  test-foreign-key-01
  =|  run=@ud
  %-  exec-3-1
  :*  run
      :+  ~2030.2.1
          %db1
          %-  zing  :~  "CREATE DATABASE db1; "
                        create-parent
                        "CREATE TABLE child ".
                        "(id @ud, parent-id @ud, note @t) ".
                        "PRIMARY KEY (id); "
                        ==
      ::
      [~2030.2.2 %db1 insert-parents]
      ::
      [~2030.2.3 %db1 insert-children]
      ::
      :+  ~2030.2.4
          %db1
          "ALTER TABLE child ADD FOREIGN KEY ".
          "(parent-id) REFERENCES parent (id); "
      ::
      [~2030.2.5 %db1 "FROM child SELECT id, parent-id, note"]
      ::
      :-  %results
          :~  [%action 'SELECT']
              [%result-set child-10-11]
              [%server-time ~2030.2.5]
              [%relation 'db1.dbo.child']
              [%schema-time ~2030.2.4]
              [%data-time ~2030.2.3]
              [%vector-count 2]
              ==
      ==
::
::  ALTER TABLE DROP FOREIGN KEY removes enforcement
++  test-foreign-key-02
  =|  run=@ud
  %-  exec-4-1
  :*  run
      :+  ~2030.3.1
          %db1
          %-  zing  :~  "CREATE DATABASE db1; "
                        create-parent
                        create-child
                        ==
      ::
      [~2030.3.2 %db1 insert-parents]
      ::
      [~2030.3.3 %db1 insert-children]
      ::
      :+  ~2030.3.4
          %db1
          "ALTER TABLE child DROP FOREIGN KEY ".
          "(parent-id) parent; "
      ::
      :+  ~2030.3.5
          %db1
          "INSERT INTO child (id, parent-id, note) ".
          "VALUES (12, 99, 'orphan'); "
      ::
      :+  ~2030.3.6
          %db1
          "FROM child WHERE id = 12 SELECT id, parent-id, note"
      ::
      :-  %results
          :~  [%action 'SELECT']
              :-  %result-set
                  :~  :-  %vector
                          :~  [%id [~.ud 12]]
                              [%parent-id [~.ud 99]]
                              [%note [~.t 'orphan']]
                              ==
                      ==
              [%server-time ~2030.3.6]
              [%relation 'db1.dbo.child']
              [%schema-time ~2030.3.4]
              [%data-time ~2030.3.5]
              [%vector-count 1]
              ==
      ==
::
::  ON DELETE CASCADE removes child rows
++  test-foreign-key-03
  =|  run=@ud
  %-  exec-3-1
  :*  run
      :+  ~2030.4.1
          %db1
          %-  zing  :~  "CREATE DATABASE db1; "
                        create-parent
                        create-child-cascade
                        ==
      ::
      [~2030.4.2 %db1 insert-parents]
      ::
      [~2030.4.3 %db1 insert-children]
      ::
      [~2030.4.4 %db1 "DELETE FROM parent WHERE id = 1; "]
      ::
      :+  ~2030.4.5
          %db1
          "FROM child SELECT id, parent-id, note"
      ::
      :-  %results
          :~  [%action 'SELECT']
              :-  %result-set
                  :~  :-  %vector
                          :~  [%id [~.ud 11]]
                              [%parent-id [~.ud 2]]
                              [%note [~.t 'bravo']]
                              ==
                      ==
              [%server-time ~2030.4.5]
              [%relation 'db1.dbo.child']
              [%schema-time ~2030.4.1]
              [%data-time ~2030.4.4]
              [%vector-count 1]
              ==
      ==
::
::  ON DELETE SET DEFAULT sets child key columns to bunt values
++  test-foreign-key-04
  =|  run=@ud
  %-  exec-3-1
  :*  run
      :+  ~2030.5.1
          %db1
          %-  zing  :~  "CREATE DATABASE db1; "
                        create-parent
                        create-child-set-default
                        ==
      ::
      [~2030.5.2 %db1 insert-parents]
      ::
      [~2030.5.3 %db1 insert-children]
      ::
      [~2030.5.4 %db1 "DELETE FROM parent WHERE id = 1; "]
      ::
      :+  ~2030.5.5
          %db1
          "FROM child WHERE id = 10 SELECT id, parent-id, note"
      ::
      :-  %results
          :~  [%action 'SELECT']
              [%result-set child-10-parent-0]
              [%server-time ~2030.5.5]
              [%relation 'db1.dbo.child']
              [%schema-time ~2030.5.1]
              [%data-time ~2030.5.4]
              [%vector-count 1]
              ==
      ==
::
::  ON UPDATE CASCADE updates child key columns
++  test-foreign-key-05
  =|  run=@ud
  %-  exec-3-1
  :*  run
      :+  ~2030.6.1
          %db1
          %-  zing  :~  "CREATE DATABASE db1; "
                        create-parent
                        create-child-cascade
                        ==
      ::
      [~2030.6.2 %db1 insert-parents]
      ::
      [~2030.6.3 %db1 insert-children]
      ::
      [~2030.6.4 %db1 "UPDATE parent SET id = 3 WHERE id = 1; "]
      ::
      :+  ~2030.6.5
          %db1
          "FROM child WHERE id = 10 SELECT id, parent-id, note"
      ::
      :-  %results
          :~  [%action 'SELECT']
              :-  %result-set
                  :~  :-  %vector
                          :~  [%id [~.ud 10]]
                              [%parent-id [~.ud 3]]
                              [%note [~.t 'alpha']]
                              ==
                      ==
              [%server-time ~2030.6.5]
              [%relation 'db1.dbo.child']
              [%schema-time ~2030.6.1]
              [%data-time ~2030.6.4]
              [%vector-count 1]
              ==
      ==
::
::  ON UPDATE SET DEFAULT sets child key columns to bunt values
++  test-foreign-key-06
  =|  run=@ud
  %-  exec-3-1
  :*  run
      :+  ~2030.7.1
          %db1
          %-  zing  :~  "CREATE DATABASE db1; "
                        create-parent
                        create-child-set-default
                        ==
      ::
      [~2030.7.2 %db1 insert-parents]
      ::
      [~2030.7.3 %db1 insert-children]
      ::
      [~2030.7.4 %db1 "UPDATE parent SET id = 3 WHERE id = 1; "]
      ::
      :+  ~2030.7.5
          %db1
          "FROM child WHERE id = 10 SELECT id, parent-id, note"
      ::
      :-  %results
          :~  [%action 'SELECT']
              [%result-set child-10-parent-0]
              [%server-time ~2030.7.5]
              [%relation 'db1.dbo.child']
              [%schema-time ~2030.7.1]
              [%data-time ~2030.7.4]
              [%vector-count 1]
              ==
      ==
::
::  INSERT AS OF checks referenced data at the mutation's AS OF content time
++  test-foreign-key-07
  =|  run=@ud
  %-  exec-3-1
  :*  run
      :+  ~2030.8.1
          %db1
          %-  zing  :~  "CREATE DATABASE db1; "
                        create-parent
                        create-child
                        ==
      ::
      [~2030.8.2 %db1 "INSERT INTO parent (id, label) VALUES (1, 'one')"]
      ::
      [~2030.8.3 %db1 "DELETE FROM parent WHERE id = 1"]
      ::
      :+  ~2030.8.4
          %db1
          "INSERT INTO child AS OF ~2030.8.2 ".
          "(id, parent-id, note) VALUES (10, 1, 'alpha')"
      ::
      [~2030.8.5 %db1 "FROM child SELECT id, parent-id, note"]
      ::
      :-  %results
          :~  [%action 'SELECT']
              :-  %result-set
                  :~  :-  %vector
                          :~  [%id [~.ud 10]]
                              [%parent-id [~.ud 1]]
                              [%note [~.t 'alpha']]
                              ==
                      ==
              [%server-time ~2030.8.5]
              [%relation 'db1.dbo.child']
              [%schema-time ~2030.8.1]
              [%data-time ~2030.8.4]
              [%vector-count 1]
              ==
      ==
::
::  DROP TABLE FORCE removes dependent foreign keys
++  test-foreign-key-08
  =|  run=@ud
  %-  exec-4-1
  :*  run
      :+  ~2030.9.1
          %db1
          %-  zing  :~  "CREATE DATABASE db1; "
                        create-parent
                        create-child
                        ==
      ::
      [~2030.9.2 %db1 insert-parents]
      ::
      [~2030.9.3 %db1 insert-children]
      ::
      [~2030.9.4 %db1 "DROP TABLE FORCE parent; "]
      ::
      :+  ~2030.9.5
          %db1
          "INSERT INTO child (id, parent-id, note) ".
          "VALUES (12, 99, 'after-force'); "
      ::
      :+  ~2030.9.6
          %db1
          "FROM child WHERE id = 12 SELECT id, parent-id, note"
      ::
      :-  %results
          :~  [%action 'SELECT']
              :-  %result-set
                  :~  :-  %vector
                          :~  [%id [~.ud 12]]
                              [%parent-id [~.ud 99]]
                              [%note [~.t 'after-force']]
                              ==
                      ==
              [%server-time ~2030.9.6]
              [%relation 'db1.dbo.child']
              [%schema-time ~2030.9.1]
              [%data-time ~2030.9.5]
              [%vector-count 1]
              ==
      ==
::
::  DROP TABLE FORCE handles a self-referential FK
++  test-foreign-key-drop-self-force
  =|  run=@ud
  %-  exec-1-1
  :*  run
      :+  ~2030.9.3
          %db1
          %-  zing  :~  "CREATE DATABASE db1; "
                        "CREATE TABLE node ".
                        "(id @ud, parent-id @ud) PRIMARY KEY (id) ".
                        "FOREIGN KEY (parent-id) REFERENCES node (id); "
                        "DROP TABLE FORCE node; "
                        "CREATE TABLE node ".
                        "(id @ud, parent-id @ud) PRIMARY KEY (id); "
                        ==
      ::
      [~2030.9.4 %db1 "INSERT INTO node (id, parent-id) VALUES (1, 99); "]
      ::
      [~2030.9.5 %db1 "FROM node SELECT id, parent-id"]
      ::
      :-  %results
          :~  [%action 'SELECT']
              :-  %result-set
                  :~  :-  %vector
                          :~  [%id [~.ud 1]]
                              [%parent-id [~.ud 99]]
                              ==
                      ==
              [%server-time ~2030.9.5]
              [%relation 'db1.dbo.node']
              [%schema-time ~2030.9.3]
              [%data-time ~2030.9.4]
              [%vector-count 1]
              ==
      ==
::
::  composite FK to a namespace-qualified table cascades in declared order
++  test-foreign-key-09
  =|  run=@ud
  %-  exec-3-1
  :*  run
      :+  ~2030.10.1
          %db1
          %-  zing  :~  "CREATE DATABASE db1; "
                        "CREATE NAMESPACE ns1; "
                        "CREATE TABLE ns1.parent ".
                        "(tenant-id @ud, code @ud, label @t) ".
                        "PRIMARY KEY (tenant-id, code); "
                        "CREATE TABLE child ".
                        "(id @ud, parent-tenant @ud, parent-code @ud, note @t) ".
                        "PRIMARY KEY (id) ".
                        "FOREIGN KEY (parent-tenant, parent-code) ".
                        "REFERENCES ns1.parent (tenant-id, code) ".
                        "ON UPDATE CASCADE; "
                        ==
      ::
      :+  ~2030.10.2
          %db1
          "INSERT INTO ns1.parent (tenant-id, code, label) ".
          "VALUES (1, 7, 'old'); "
      ::
      :+  ~2030.10.3
          %db1
          "INSERT INTO child ".
          "(id, parent-tenant, parent-code, note) ".
          "VALUES (10, 1, 7, 'alpha'); "
      ::
      :+  ~2030.10.4
          %db1
          "UPDATE ns1.parent ".
          "SET tenant-id = 3, code = 9 ".
          "WHERE tenant-id = 1 AND code = 7; "
      ::
      :+  ~2030.10.5
          %db1
          "FROM child SELECT id, parent-tenant, parent-code, note"
      ::
      :-  %results
          :~  [%action 'SELECT']
              [%result-set composite-child-10-updated]
              [%server-time ~2030.10.5]
              [%relation 'db1.dbo.child']
              [%schema-time ~2030.10.1]
              [%data-time ~2030.10.4]
              [%vector-count 1]
              ==
      ==
::
::  TRUNCATE TABLE enforces ON DELETE CASCADE
++  test-foreign-key-10
  =|  run=@ud
  %-  exec-3-1
  :*  run
      :+  ~2030.11.1
          %db1
          %-  zing  :~  "CREATE DATABASE db1; "
                        create-parent
                        create-child-cascade
                        ==
      ::
      [~2030.11.2 %db1 insert-parents]
      ::
      [~2030.11.3 %db1 insert-children]
      ::
      [~2030.11.4 %db1 "TRUNCATE TABLE parent; "]
      ::
      [~2030.11.5 %db1 "FROM child SELECT id, parent-id, note"]
      ::
      :-  %results
          :~  [%action 'SELECT']
              [%result-set ~]
              [%server-time ~2030.11.5]
              [%relation 'db1.dbo.child']
              [%schema-time ~2030.11.1]
              [%data-time ~2030.11.4]
              [%vector-count 0]
              ==
      ==
::
::  TRUNCATE TABLE succeeds when declared FKs have no referencing rows
++  test-foreign-key-11
  =|  run=@ud
  %-  exec-2-1
  :*  run
      :+  ~2030.12.1
          %db1
          %-  zing  :~  "CREATE DATABASE db1; "
                        create-parent
                        create-child
                        ==
      ::
      [~2030.12.2 %db1 insert-parents]
      ::
      [~2030.12.3 %db1 "TRUNCATE TABLE parent; "]
      ::
      [~2030.12.4 %db1 "FROM parent SELECT id, label"]
      ::
      :-  %results
          :~  [%action 'SELECT']
              [%result-set ~]
              [%server-time ~2030.12.4]
              [%relation 'db1.dbo.parent']
              [%schema-time ~2030.12.1]
              [%data-time ~2030.12.3]
              [%vector-count 0]
              ==
      ==
::
::  same-database namespace transfer preserves incoming FK metadata
++  test-foreign-key-12
  =|  run=@ud
  %-  exec-4-1
  :*  run
      :+  ~2031.1.1
          %db1
          %-  zing  :~  "CREATE DATABASE db1; "
                        "CREATE NAMESPACE ns1; "
                        create-parent
                        create-child-cascade
                        ==
      ::
      [~2031.1.2 %db1 insert-parents]
      ::
      [~2031.1.3 %db1 insert-children]
      ::
      [~2031.1.4 %db1 "ALTER NAMESPACE ns1 TRANSFER TABLE parent; "]
      ::
      [~2031.1.5 %db1 "DELETE FROM ns1.parent WHERE id = 1; "]
      ::
      [~2031.1.6 %db1 "FROM child SELECT id, parent-id, note"]
      ::
      :-  %results
          :~  [%action 'SELECT']
              :-  %result-set
                  :~  :-  %vector
                          :~  [%id [~.ud 11]]
                              [%parent-id [~.ud 2]]
                              [%note [~.t 'bravo']]
                              ==
                      ==
              [%server-time ~2031.1.6]
              [%relation 'db1.dbo.child']
              [%schema-time ~2031.1.1]
              [%data-time ~2031.1.5]
              [%vector-count 1]
              ==
      ==
::
::  same-database namespace transfer preserves outgoing FK metadata
++  test-foreign-key-transfer-child
  =|  run=@ud
  %-  failon-2
  :*  run
      :+  ~2031.1.11
          %db1
          %-  zing  :~  "CREATE DATABASE db1; "
                        "CREATE NAMESPACE ns1; "
                        create-parent
                        create-child
                        ==
      ::
      [~2031.1.12 %db1 "ALTER NAMESPACE ns1 TRANSFER TABLE child; "]
      ::
      [~2031.1.13 %db1 "INSERT INTO ns1.child (id, parent-id, note) VALUES (12, 99, 'orphan')"]
      ::
      'INSERT: FOREIGN KEY parent key not found'
      ==
::
::  ALTER TABLE RENAME TO preserves incoming FK metadata
++  test-foreign-key-rename-parent
  =|  run=@ud
  %-  exec-4-1
  :*  run
      :+  ~2031.1.3
          %db1
          %-  zing  :~  "CREATE DATABASE db1; "
                        create-parent
                        create-child-cascade
                        ==
      ::
      [~2031.1.4 %db1 insert-parents]
      ::
      [~2031.1.5 %db1 insert-children]
      ::
      [~2031.1.6 %db1 "ALTER TABLE parent RENAME TO parent-2; "]
      ::
      [~2031.1.7 %db1 "DELETE FROM parent-2 WHERE id = 1; "]
      ::
      [~2031.1.8 %db1 "FROM child SELECT id, parent-id, note"]
      ::
      :-  %results
          :~  [%action 'SELECT']
              :-  %result-set
                  :~  :-  %vector
                          :~  [%id [~.ud 11]]
                              [%parent-id [~.ud 2]]
                              [%note [~.t 'bravo']]
                              ==
                      ==
              [%server-time ~2031.1.8]
              [%relation 'db1.dbo.child']
              [%schema-time ~2031.1.3]
              [%data-time ~2031.1.7]
              [%vector-count 1]
              ==
      ==
::
::  ALTER TABLE RENAME TO preserves outgoing FK metadata
++  test-foreign-key-rename-child
  =|  run=@ud
  %-  failon-2
  :*  run
      :+  ~2031.1.5
          %db1
          %-  zing  :~  "CREATE DATABASE db1; "
                        create-parent
                        create-child
                        ==
      ::
      [~2031.1.6 %db1 "ALTER TABLE child RENAME TO child-2; "]
      ::
      [~2031.1.7 %db1 "INSERT INTO child-2 (id, parent-id, note) VALUES (12, 99, 'orphan')"]
      ::
      'INSERT: FOREIGN KEY parent key not found'
      ==
::
::  RENAME COLUMN preserves a child-side FK source column
++  test-foreign-key-rename-source-column
  =|  run=@ud
  %-  failon-4
  :*  run
      :+  ~2031.1.7
          %db1
          %-  zing  :~  "CREATE DATABASE db1; "
                        create-parent
                        create-child
                        ==
      ::
      [~2031.1.8 %db1 insert-parents]
      ::
      [~2031.1.9 %db1 insert-children]
      ::
      [~2031.1.10 %db1 "ALTER TABLE child RENAME COLUMN (parent-id TO parent-key); "]
      ::
      [~2031.1.11 %db1 "DELETE FROM parent WHERE id = 1"]
      ::
      'DELETE: FOREIGN KEY restrict violation'
      ==
::
::  RENAME COLUMN preserves a referenced parent primary-key column
++  test-foreign-key-rename-parent-column
  =|  run=@ud
  %-  exec-4-1
  :*  run
      :+  ~2031.1.9
          %db1
          %-  zing  :~  "CREATE DATABASE db1; "
                        create-parent
                        create-child-cascade
                        ==
      ::
      [~2031.1.10 %db1 insert-parents]
      ::
      [~2031.1.11 %db1 insert-children]
      ::
      [~2031.1.12 %db1 "ALTER TABLE parent RENAME COLUMN (id TO pk-id); "]
      ::
      [~2031.1.13 %db1 "DELETE FROM parent WHERE pk-id = 1; "]
      ::
      [~2031.1.14 %db1 "FROM child SELECT id, parent-id, note"]
      ::
      :-  %results
          :~  [%action 'SELECT']
              :-  %result-set
                  :~  :-  %vector
                          :~  [%id [~.ud 11]]
                              [%parent-id [~.ud 2]]
                              [%note [~.t 'bravo']]
                              ==
                      ==
              [%server-time ~2031.1.14]
              [%relation 'db1.dbo.child']
              [%schema-time ~2031.1.9]
              [%data-time ~2031.1.13]
              [%vector-count 1]
              ==
      ==
::
::  rejects cross-database foreign keys
++  test-fail-foreign-key-00
  =|  run=@ud
  =/  cmd
    :*  %create-table
        [%qualified-table ship=~ database='db1' namespace='dbo' name='child' ~]
        :~  [%column name='id' type=%ud addr=0]
            [%column name='parent-id' type=%ud addr=0]
            ==
        ~[[%ordered-column name='id' ascending=%.y]]
        :~  :*  %foreign-key
                [%qualified-table ship=~ database='db1' namespace='dbo' name='child' ~]
                ~[%parent-id]
                [%qualified-table ship=~ database='db2' namespace='dbo' name='parent' ~]
                ~[%id]
                ~
                ==
            ==
        ~
        ==
  %-  failon-c
  :*  run
      :+  ~2031.1.1
          %sys
          "CREATE DATABASE db1; CREATE DATABASE db2; ".
          "CREATE TABLE db2..parent (id @ud) PRIMARY KEY (id); "
      ::
      [~2031.1.2 [%commands ~[cmd]]]
      ::
      'CREATE TABLE: foreign key references another database'
      ==
::
::  rejects source columns that do not exist
++  test-fail-foreign-key-01
  =|  run=@ud
  %-  failon-0
  :*  run
      :+  ~2031.2.1
          %db1
          %-  zing  :~  "CREATE DATABASE db1; "
                        create-parent
                        "CREATE TABLE child ".
                        "(id @ud, parent-id @ud) PRIMARY KEY (id) ".
                        "FOREIGN KEY (missing-id) REFERENCES parent (id); "
                        ==
      ::
      'CREATE TABLE: foreign key source column %missing-id does not exist'
      ==
::
::  rejects missing reference tables
++  test-fail-foreign-key-02
  =|  run=@ud
  %-  failon-0
  :*  run
      :+  ~2031.3.1
          %db1
          %-  zing  :~  "CREATE DATABASE db1; "
                        "CREATE TABLE child ".
                        "(id @ud, parent-id @ud) PRIMARY KEY (id) ".
                        "FOREIGN KEY (parent-id) REFERENCES missing-parent (id); "
                        ==
      ::
      'CREATE TABLE: table %missing-parent referenced by FOREIGN KEY does not exist'
      ==
::
::  rejects missing reference columns
++  test-fail-foreign-key-03
  =|  run=@ud
  %-  failon-0
  :*  run
      :+  ~2031.4.1
          %db1
          %-  zing  :~  "CREATE DATABASE db1; "
                        create-parent
                        "CREATE TABLE child ".
                        "(id @ud, parent-id @ud) PRIMARY KEY (id) ".
                        "FOREIGN KEY (parent-id) REFERENCES parent (missing-id); "
                        ==
      ::
      'CREATE TABLE: column %missing-id referenced by FOREIGN KEY does not exist'
      ==
::
::  rejects source/reference aura mismatches
++  test-fail-foreign-key-04
  =|  run=@ud
  %-  failon-0
  :*  run
      :+  ~2031.5.1
          %db1
          %-  zing  :~  "CREATE DATABASE db1; "
                        "CREATE TABLE parent ".
                        "(id @t) PRIMARY KEY (id); "
                        "CREATE TABLE child ".
                        "(id @ud, parent-id @ud) PRIMARY KEY (id) ".
                        "FOREIGN KEY (parent-id) REFERENCES parent (id); "
                        ==
      ::
      'CREATE TABLE: aura mis-match in FOREIGN KEY %parent-id %id'
      ==
::
::  rejects reference columns that are not the exact primary key order
++  test-fail-foreign-key-05
  =|  run=@ud
  %-  failon-0
  :*  run
      :+  ~2031.6.1
          %db1
          %-  zing  :~  "CREATE DATABASE db1; "
                        "CREATE TABLE parent ".
                        "(id-a @ud, id-b @ud) PRIMARY KEY (id-a, id-b); "
                        "CREATE TABLE child ".
                        "(id @ud, parent-a @ud, parent-b @ud) PRIMARY KEY (id) ".
                        "FOREIGN KEY (parent-a, parent-b) ".
                        "REFERENCES parent (id-b, id-a); "
                        ==
      ::
      'CREATE TABLE: foreign key reference columns do not match referenced PRIMARY KEY'
      ==
::
::  rejects duplicate foreign key definitions
++  test-fail-foreign-key-06
  =|  run=@ud
  %-  failon-0
  :*  run
      :+  ~2031.7.1
          %db1
          %-  zing  :~  "CREATE DATABASE db1; "
                        create-parent
                        "CREATE TABLE child ".
                        "(id @ud, parent-id @ud) PRIMARY KEY (id) ".
                        "FOREIGN KEY (parent-id) REFERENCES parent (id), ".
                        "(parent-id) REFERENCES parent (id); "
                        ==
      ::
      'CREATE TABLE: foreign key already exists'
      ==
::
::  rejects ADD FOREIGN KEY over existing invalid child rows
++  test-fail-foreign-key-07
  =|  run=@ud
  %-  failon-3
  :*  run
      :+  ~2031.8.1
          %db1
          %-  zing  :~  "CREATE DATABASE db1; "
                        create-parent
                        "CREATE TABLE child ".
                        "(id @ud, parent-id @ud, note @t) PRIMARY KEY (id); "
                        ==
      ::
      [~2031.8.2 %db1 insert-parents]
      ::
      :+  ~2031.8.3
          %db1
          "INSERT INTO child (id, parent-id, note) ".
          "VALUES (10, 99, 'orphan'); "
      ::
      :+  ~2031.8.4
          %db1
          "ALTER TABLE child ADD FOREIGN KEY ".
          "(parent-id) REFERENCES parent (id); "
      ::
      'ALTER TABLE: FOREIGN KEY parent key not found'
      ==
::
::  rejects DROP FOREIGN KEY that does not match any constraint
++  test-fail-foreign-key-08
  =|  run=@ud
  %-  failon-1
  :*  run
      :+  ~2031.9.1
          %db1
          %-  zing  :~  "CREATE DATABASE db1; "
                        create-parent
                        create-child
                        ==
      ::
      :+  ~2031.9.2
          %db1
          "ALTER TABLE child DROP FOREIGN KEY ".
          "(parent-id) missing-parent; "
      ::
      'ALTER TABLE: foreign key to drop does not exist'
      ==
::
::  rejects INSERT when parent key is missing
++  test-fail-foreign-key-09
  =|  run=@ud
  %-  failon-2
  :*  run
      :+  ~2031.10.1
          %db1
          %-  zing  :~  "CREATE DATABASE db1; "
                        create-parent
                        create-child
                        ==
      ::
      [~2031.10.2 %db1 insert-parents]
      ::
      :+  ~2031.10.3
          %db1
          "INSERT INTO child (id, parent-id, note) ".
          "VALUES (10, 99, 'orphan'); "
      ::
      'INSERT: FOREIGN KEY parent key not found'
      ==
::
::  rejects UPDATE of a child key to a missing parent key
++  test-fail-foreign-key-10
  =|  run=@ud
  %-  failon-3
  :*  run
      :+  ~2031.11.1
          %db1
          %-  zing  :~  "CREATE DATABASE db1; "
                        create-parent
                        create-child
                        ==
      ::
      [~2031.11.2 %db1 insert-parents]
      ::
      [~2031.11.3 %db1 insert-children]
      ::
      [~2031.11.4 %db1 "UPDATE child SET parent-id = 99 WHERE id = 10; "]
      ::
      'UPDATE: FOREIGN KEY parent key not found'
      ==
::
::  rejects DELETE of referenced parent rows under RESTRICT
++  test-fail-foreign-key-11
  =|  run=@ud
  %-  failon-3
  :*  run
      :+  ~2031.12.1
          %db1
          %-  zing  :~  "CREATE DATABASE db1; "
                        create-parent
                        create-child
                        ==
      ::
      [~2031.12.2 %db1 insert-parents]
      ::
      [~2031.12.3 %db1 insert-children]
      ::
      [~2031.12.4 %db1 "DELETE FROM parent WHERE id = 1; "]
      ::
      'DELETE: FOREIGN KEY restrict violation'
      ==
::
::  rejects UPDATE of referenced parent keys under RESTRICT
++  test-fail-foreign-key-12
  =|  run=@ud
  %-  failon-3
  :*  run
      :+  ~2032.1.1
          %db1
          %-  zing  :~  "CREATE DATABASE db1; "
                        create-parent
                        create-child
                        ==
      ::
      [~2032.1.2 %db1 insert-parents]
      ::
      [~2032.1.3 %db1 insert-children]
      ::
      [~2032.1.4 %db1 "UPDATE parent SET id = 3 WHERE id = 1; "]
      ::
      'UPDATE: FOREIGN KEY restrict violation'
      ==
::
::  rejects SET DEFAULT when the referenced table lacks the bunt key
++  test-fail-foreign-key-13
  =|  run=@ud
  %-  failon-3
  :*  run
      :+  ~2032.2.1
          %db1
          %-  zing  :~  "CREATE DATABASE db1; "
                        "CREATE TABLE parent ".
                        "(id @ud, label @t) PRIMARY KEY (id); "
                        create-child-set-default
                        ==
      ::
      [~2032.2.2 %db1 "INSERT INTO parent (id, label) VALUES (1, 'one'); "]
      ::
      [~2032.2.3 %db1 "INSERT INTO child (id, parent-id, note) VALUES (10, 1, 'alpha'); "]
      ::
      [~2032.2.4 %db1 "DELETE FROM parent WHERE id = 1; "]
      ::
      'DELETE: FOREIGN KEY SET DEFAULT parent bunt key not found'
      ==
::
::  rejects TRUNCATE of referenced parent rows under RESTRICT
++  test-fail-foreign-key-14
  =|  run=@ud
  %-  failon-3
  :*  run
      :+  ~2032.3.1
          %db1
          %-  zing  :~  "CREATE DATABASE db1; "
                        create-parent
                        create-child
                        ==
      ::
      [~2032.3.2 %db1 insert-parents]
      ::
      [~2032.3.3 %db1 insert-children]
      ::
      [~2032.3.4 %db1 "TRUNCATE TABLE parent; "]
      ::
      'TRUNCATE TABLE: FOREIGN KEY restrict violation'
      ==
::
::  rejects DROP TABLE of a referenced table without FORCE
++  test-fail-foreign-key-15
  =|  run=@ud
  %-  failon-1
  :*  run
      :+  ~2032.4.1
          %db1
          %-  zing  :~  "CREATE DATABASE db1; "
                        create-parent
                        create-child
                        ==
      ::
      [~2032.4.2 %db1 "DROP TABLE parent; "]
      ::
      'DROP TABLE: %parent used in FOREIGN KEY, use FORCE to DROP'
      ==
::
::  rejects DROP TABLE of a self-referential FK without FORCE
++  test-fail-foreign-key-drop-self
  =|  run=@ud
  %-  failon-1
  :*  run
      :+  ~2032.4.2
          %db1
          %-  zing  :~  "CREATE DATABASE db1; "
                        "CREATE TABLE node ".
                        "(id @ud, parent-id @ud) PRIMARY KEY (id) ".
                        "FOREIGN KEY (parent-id) REFERENCES node (id); "
                        ==
      ::
      [~2032.4.3 %db1 "DROP TABLE node; "]
      ::
      'DROP TABLE: %node used in FOREIGN KEY, use FORCE to DROP'
      ==
::
::  rejects AS OF INSERT when parent key did not exist at the AS OF content time
++  test-fail-foreign-key-16
  =|  run=@ud
  %-  failon-2
  :*  run
      :+  ~2032.5.1
          %db1
          %-  zing  :~  "CREATE DATABASE db1; "
                        create-parent
                        create-child
                        ==
      ::
      [~2032.5.3 %db1 "INSERT INTO parent (id, label) VALUES (1, 'one')"]
      ::
      :+  ~2032.5.4
          %db1
          "INSERT INTO child AS OF ~2032.5.2 ".
          "(id, parent-id, note) VALUES (10, 1, 'alpha')"
      ::
      'INSERT: FOREIGN KEY parent key not found'
      ==
::
::  rejects cross-database namespace transfers that would split a foreign key
++  test-fail-foreign-key-17
  =|  run=@ud
  %-  failon-1
  :*  run
      :+  ~2032.6.1
          %db1
          %-  zing  :~  "CREATE DATABASE db1; ".
                        "CREATE DATABASE db2; ".
                        "CREATE NAMESPACE db2.ns2; "
                        create-parent
                        create-child
                        ==
      ::
      [~2032.6.2 %db1 "ALTER NAMESPACE db2.ns2 TRANSFER TABLE child; "]
      ::
      'ALTER NAMESPACE: FOREIGN KEY cross-database transfer not allowed'
      ==
::
::  rejects dropping a referenced primary-key column
++  test-fail-foreign-key-18
  =|  run=@ud
  %-  failon-1
  :*  run
      :+  ~2032.7.1
          %db1
          %-  zing  :~  "CREATE DATABASE db1; "
                        create-parent
                        create-child
                        ==
      ::
      [~2032.7.2 %db1 "ALTER TABLE parent DROP COLUMN (id); "]
      ::
      'ALTER TABLE: column %id is referenced by FOREIGN KEY'
      ==
::
::  rejects dropping a child-side FK source column
++  test-fail-foreign-key-drop-source-column
  =|  run=@ud
  %-  failon-1
  :*  run
      :+  ~2032.7.2
          %db1
          %-  zing  :~  "CREATE DATABASE db1; "
                        create-parent
                        create-child
                        ==
      ::
      [~2032.7.3 %db1 "ALTER TABLE child DROP COLUMN (parent-id); "]
      ::
      'ALTER TABLE: column %parent-id is referenced by FOREIGN KEY'
      ==
::
::  rejects altering a referenced primary-key column
++  test-fail-foreign-key-alter-parent-column
  =|  run=@ud
  %-  failon-1
  :*  run
      :+  ~2032.7.3
          %db1
          %-  zing  :~  "CREATE DATABASE db1; "
                        create-parent
                        create-child
                        ==
      ::
      [~2032.7.4 %db1 "ALTER TABLE parent ALTER COLUMN (id @t); "]
      ::
      'ALTER TABLE: column %id is referenced by FOREIGN KEY'
      ==
::
::  rejects altering a child-side FK source column
++  test-fail-foreign-key-alter-source-column
  =|  run=@ud
  %-  failon-1
  :*  run
      :+  ~2032.7.4
          %db1
          %-  zing  :~  "CREATE DATABASE db1; "
                        create-parent
                        create-child
                        ==
      ::
      [~2032.7.5 %db1 "ALTER TABLE child ALTER COLUMN (parent-id @t); "]
      ::
      'ALTER TABLE: column %parent-id is referenced by FOREIGN KEY'
      ==
::
::  rejects changing the primary key of a referenced table
++  test-fail-foreign-key-alter-parent-primary-key
  =|  run=@ud
  %-  failon-1
  :*  run
      :+  ~2032.7.5
          %db1
          %-  zing  :~  "CREATE DATABASE db1; "
                        create-parent
                        create-child
                        ==
      ::
      [~2032.7.6 %db1 "ALTER TABLE parent PRIMARY KEY (label); "]
      ::
      'ALTER TABLE: PRIMARY KEY is referenced by FOREIGN KEY'
      ==
::
::  rejects duplicate ADD FOREIGN KEY definitions
++  test-fail-foreign-key-19
  =|  run=@ud
  %-  failon-2
  :*  run
      :+  ~2032.8.1
          %db1
          %-  zing  :~  "CREATE DATABASE db1; "
                        create-parent
                        "CREATE TABLE child ".
                        "(id @ud, parent-id @ud) PRIMARY KEY (id); "
                        ==
      ::
      :+  ~2032.8.2
          %db1
          "ALTER TABLE child ADD FOREIGN KEY ".
          "(parent-id) REFERENCES parent (id); "
      ::
      :+  ~2032.8.3
          %db1
          "ALTER TABLE child ADD FOREIGN KEY ".
          "(parent-id) REFERENCES parent (id); "
      ::
      'ALTER TABLE: foreign key already exists'
      ==
::
::  rejects ADD FOREIGN KEY when existing composite child rows are orphaned
++  test-fail-foreign-key-20
  =|  run=@ud
  %-  failon-3
  :*  run
      :+  ~2032.9.1
          %db1
          %-  zing  :~  "CREATE DATABASE db1; "
                        "CREATE TABLE parent ".
                        "(tenant-id @ud, code @ud) ".
                        "PRIMARY KEY (tenant-id, code); "
                        "CREATE TABLE child ".
                        "(id @ud, parent-tenant @ud, parent-code @ud) ".
                        "PRIMARY KEY (id); "
                        ==
      ::
      [~2032.9.2 %db1 "INSERT INTO parent (tenant-id, code) VALUES (1, 7); "]
      ::
      :+  ~2032.9.3
          %db1
          "INSERT INTO child ".
          "(id, parent-tenant, parent-code) ".
          "VALUES (10, 1, 8); "
      ::
      :+  ~2032.9.4
          %db1
          "ALTER TABLE child ADD FOREIGN KEY ".
          "(parent-tenant, parent-code) ".
          "REFERENCES parent (tenant-id, code); "
      ::
      'ALTER TABLE: FOREIGN KEY parent key not found'
      ==
::
::  DROP FOREIGN KEY identifies constraints by source columns and table
++  test-fail-foreign-key-21
  =|  run=@ud
  %-  failon-5
  :*  run
      :+  ~2032.10.1
          %db1
          %-  zing  :~  "CREATE DATABASE db1; "
                        "CREATE TABLE parent-a ".
                        "(id @ud) PRIMARY KEY (id); "
                        "CREATE TABLE parent-b ".
                        "(id @ud) PRIMARY KEY (id); "
                        "CREATE TABLE child ".
                        "(id @ud, parent-id @ud) PRIMARY KEY (id) ".
                        "FOREIGN KEY (parent-id) REFERENCES parent-a (id), ".
                        "(parent-id) REFERENCES parent-b (id); "
                        ==
      ::
      [~2032.10.2 %db1 "INSERT INTO parent-a (id) VALUES (1); "]
      ::
      [~2032.10.3 %db1 "INSERT INTO parent-b (id) VALUES (1); "]
      ::
      [~2032.10.4 %db1 "INSERT INTO child (id, parent-id) VALUES (10, 1); "]
      ::
      :+  ~2032.10.5
          %db1
          "ALTER TABLE child DROP FOREIGN KEY ".
          "(parent-id) parent-a; "
      ::
      [~2032.10.6 %db1 "DELETE FROM parent-b WHERE id = 1; "]
      ::
      'DELETE: FOREIGN KEY restrict violation'
      ==
::
::  rejects DROP TABLE of a child table containing an outgoing FK
++  test-fail-foreign-key-22
  =|  run=@ud
  %-  failon-1
  :*  run
      :+  ~2032.11.1
          %db1
          %-  zing  :~  "CREATE DATABASE db1; "
                        create-parent
                        create-child
                        ==
      ::
      [~2032.11.2 %db1 "DROP TABLE child; "]
      ::
      'DROP TABLE: %child used in FOREIGN KEY, use FORCE to DROP'
      ==
::
::  rejects CREATE TABLE when the referenced namespace does not exist
++  test-fail-foreign-key-23
  =|  run=@ud
  %-  failon-0
  :*  run
      :+  ~2032.12.1
          %db1
          %-  zing  :~  "CREATE DATABASE db1; "
                        "CREATE TABLE child ".
                        "(id @ud, parent-id @ud) PRIMARY KEY (id) ".
                        "FOREIGN KEY (parent-id) ".
                        "REFERENCES missing-ns.parent (id); "
                        ==
      ::
      'CREATE TABLE: namespace %missing-ns referenced by FOREIGN KEY does not exist'
      ==
::
::  rejects TRUNCATE SET DEFAULT when the bunt parent row would be removed
++  test-fail-foreign-key-24
  =|  run=@ud
  %-  failon-3
  :*  run
      :+  ~2033.1.1
          %db1
          %-  zing  :~  "CREATE DATABASE db1; "
                        create-parent
                        create-child-set-default
                        ==
      ::
      [~2033.1.2 %db1 insert-parents]
      ::
      [~2033.1.3 %db1 insert-children]
      ::
      [~2033.1.4 %db1 "TRUNCATE TABLE parent; "]
      ::
      'TRUNCATE TABLE: FOREIGN KEY SET DEFAULT parent bunt key not found'
      ==
::
::  RESTRICT-only two-table cycle is accepted
++  test-foreign-key-13
  =|  run=@ud
  %-  exec-1-1
  :*  run
      :+  ~2033.2.1
          %db1
          %-  zing  :~  "CREATE DATABASE db1; "
                        "CREATE TABLE a (id @ud, b-ref @ud) PRIMARY KEY (id); "
                        "CREATE TABLE b (id @ud, a-ref @ud) ".
                        "PRIMARY KEY (id) ".
                        "FOREIGN KEY (a-ref) REFERENCES a (id); "
                        ==
      ::
      [~2033.2.2 %db1 "ALTER TABLE a ADD FOREIGN KEY (b-ref) REFERENCES b (id); "]
      ::
      [~2033.2.3 %db1 "FROM a SELECT id, b-ref"]
      ::
      :-  %results
          :~  [%action 'SELECT']
              [%result-set ~]
              [%server-time ~2033.2.3]
              [%relation 'db1.dbo.a']
              [%schema-time ~2033.2.2]
              [%data-time ~2033.2.1]
              [%vector-count 0]
              ==
      ==
::
::  RESTRICT-only three-table cycle is accepted
++  test-foreign-key-14
  =|  run=@ud
  %-  exec-1-1
  :*  run
      :+  ~2033.3.1
          %db1
          %-  zing  :~  "CREATE DATABASE db1; "
                        "CREATE TABLE a (id @ud, c-ref @ud) PRIMARY KEY (id); "
                        "CREATE TABLE b (id @ud, a-ref @ud) ".
                        "PRIMARY KEY (id) ".
                        "FOREIGN KEY (a-ref) REFERENCES a (id); "
                        "CREATE TABLE c (id @ud, b-ref @ud) ".
                        "PRIMARY KEY (id) ".
                        "FOREIGN KEY (b-ref) REFERENCES b (id); "
                        ==
      ::
      [~2033.3.2 %db1 "ALTER TABLE a ADD FOREIGN KEY (c-ref) REFERENCES c (id); "]
      ::
      [~2033.3.3 %db1 "FROM a SELECT id, c-ref"]
      ::
      :-  %results
          :~  [%action 'SELECT']
              [%result-set ~]
              [%server-time ~2033.3.3]
              [%relation 'db1.dbo.a']
              [%schema-time ~2033.3.2]
              [%data-time ~2033.3.1]
              [%vector-count 0]
              ==
      ==
::
::  self-referential RESTRICT FK accepted; multi-row insert references same batch
++  test-foreign-key-15
  =|  run=@ud
  %-  exec-1-1
  :*  run
      :+  ~2033.4.1
          %db1
          %-  zing  :~  "CREATE DATABASE db1; "
                        "CREATE TABLE node ".
                        "(id @ud, parent-id @ud) ".
                        "PRIMARY KEY (id) ".
                        "FOREIGN KEY (parent-id) REFERENCES node (id); "
                        ==
      ::
      :+  ~2033.4.2
          %db1
          "INSERT INTO node (id, parent-id) ".
          "VALUES (0, 0) (1, 0) (2, 1); "
      ::
      [~2033.4.3 %db1 "FROM node WHERE id = 2 SELECT id, parent-id"]
      ::
      :-  %results
          :~  [%action 'SELECT']
              :-  %result-set
                  :~  :-  %vector
                          :~  [%id [~.ud 2]]
                              [%parent-id [~.ud 1]]
                              ==
                      ==
              [%server-time ~2033.4.3]
              [%relation 'db1.dbo.node']
              [%schema-time ~2033.4.1]
              [%data-time ~2033.4.2]
              [%vector-count 1]
              ==
      ==
::
::  rejects self-referential CASCADE FK at CREATE TABLE
++  test-fail-foreign-key-25
  =|  run=@ud
  %-  failon-0
  :*  run
      :+  ~2033.5.1
          %db1
          %-  zing  :~  "CREATE DATABASE db1; "
                        "CREATE TABLE node ".
                        "(id @ud, parent-id @ud) ".
                        "PRIMARY KEY (id) ".
                        "FOREIGN KEY (parent-id) REFERENCES node (id) ".
                        "ON DELETE CASCADE; "
                        ==
      ::
      'CREATE TABLE: cascading foreign-key cycle not allowed'
      ==
::
::  rejects self-referential CASCADE FK at ALTER TABLE ADD FOREIGN KEY
++  test-fail-foreign-key-26
  =|  run=@ud
  %-  failon-1
  :*  run
      :+  ~2033.6.1
          %db1
          %-  zing  :~  "CREATE DATABASE db1; "
                        "CREATE TABLE node ".
                        "(id @ud, parent-id @ud) ".
                        "PRIMARY KEY (id); "
                        ==
      ::
      :+  ~2033.6.2
          %db1
          %-  zing  :~  "ALTER TABLE node ADD FOREIGN KEY ".
                        "(parent-id) REFERENCES node (id) ".
                        "ON DELETE CASCADE; "
                        ==
      ::
      'ALTER TABLE: cascading foreign-key cycle not allowed'
      ==
::
::  rejects two-table CASCADE cycle at ALTER TABLE ADD FOREIGN KEY
++  test-fail-foreign-key-27
  =|  run=@ud
  %-  failon-1
  :*  run
      :+  ~2033.7.1
          %db1
          %-  zing  :~  "CREATE DATABASE db1; "
                        "CREATE TABLE a (id @ud, b-ref @ud) PRIMARY KEY (id); "
                        "CREATE TABLE b (id @ud, a-ref @ud) ".
                        "PRIMARY KEY (id) ".
                        "FOREIGN KEY (a-ref) REFERENCES a (id) ".
                        "ON DELETE CASCADE; "
                        ==
      ::
      :+  ~2033.7.2
          %db1
          %-  zing  :~  "ALTER TABLE a ADD FOREIGN KEY ".
                        "(b-ref) REFERENCES b (id) ".
                        "ON DELETE CASCADE; "
                        ==
      ::
      'ALTER TABLE: cascading foreign-key cycle not allowed'
      ==
::
::  rejects three-table CASCADE cycle at ALTER TABLE ADD FOREIGN KEY
++  test-fail-foreign-key-28
  =|  run=@ud
  %-  failon-1
  :*  run
      :+  ~2033.8.1
          %db1
          %-  zing  :~  "CREATE DATABASE db1; "
                        "CREATE TABLE a (id @ud, c-ref @ud) PRIMARY KEY (id); "
                        "CREATE TABLE b (id @ud, a-ref @ud) ".
                        "PRIMARY KEY (id) ".
                        "FOREIGN KEY (a-ref) REFERENCES a (id) ".
                        "ON DELETE CASCADE; "
                        "CREATE TABLE c (id @ud, b-ref @ud) ".
                        "PRIMARY KEY (id) ".
                        "FOREIGN KEY (b-ref) REFERENCES b (id) ".
                        "ON DELETE CASCADE; "
                        ==
      ::
      :+  ~2033.8.2
          %db1
          %-  zing  :~  "ALTER TABLE a ADD FOREIGN KEY ".
                        "(c-ref) REFERENCES c (id) ".
                        "ON DELETE CASCADE; "
                        ==
      ::
      'ALTER TABLE: cascading foreign-key cycle not allowed'
      ==
::
::  rejects two-table SET DEFAULT cycle at ALTER TABLE ADD FOREIGN KEY
++  test-fail-foreign-key-29
  =|  run=@ud
  %-  failon-1
  :*  run
      :+  ~2033.9.1
          %db1
          %-  zing  :~  "CREATE DATABASE db1; "
                        "CREATE TABLE a (id @ud, b-ref @ud) PRIMARY KEY (id); "
                        "CREATE TABLE b (id @ud, a-ref @ud) ".
                        "PRIMARY KEY (id) ".
                        "FOREIGN KEY (a-ref) REFERENCES a (id) ".
                        "ON DELETE SET DEFAULT; "
                        ==
      ::
      :+  ~2033.9.2
          %db1
          %-  zing  :~  "ALTER TABLE a ADD FOREIGN KEY ".
                        "(b-ref) REFERENCES b (id) ".
                        "ON DELETE SET DEFAULT; "
                        ==
      ::
      'ALTER TABLE: cascading foreign-key cycle not allowed'
      ==
::
::  parent non-primary-key UPDATE does not trigger RI action
++  test-foreign-key-16
  =|  run=@ud
  %-  exec-3-1
  :*  run
      :+  ~2034.1.1
          %db1
          %-  zing  :~  "CREATE DATABASE db1; "
                        create-parent
                        create-child
                        ==
      ::
      [~2034.1.2 %db1 "INSERT INTO parent (id, label) VALUES (1, 'one'); "]
      ::
      [~2034.1.3 %db1 "INSERT INTO child (id, parent-id, note) VALUES (10, 1, 'alpha'); "]
      ::
      [~2034.1.4 %db1 "UPDATE parent SET label = 'changed' WHERE id = 1; "]
      ::
      [~2034.1.5 %db1 "FROM child WHERE id = 10 SELECT id, parent-id, note"]
      ::
      :-  %results
          :~  [%action 'SELECT']
              :-  %result-set
                  :~  :-  %vector
                          :~  [%id [~.ud 10]]
                              [%parent-id [~.ud 1]]
                              [%note [~.t 'alpha']]
                              ==
                      ==
              [%server-time ~2034.1.5]
              [%relation 'db1.dbo.child']
              [%schema-time ~2034.1.1]
              [%data-time ~2034.1.3]
              [%vector-count 1]
              ==
      ==
::
::  self-referential RESTRICT: valid delete of leaf node
++  test-foreign-key-17
  =|  run=@ud
  %-  exec-2-1
  :*  run
      :+  ~2034.2.1
          %db1
          %-  zing  :~  "CREATE DATABASE db1; "
                        "CREATE TABLE node ".
                        "(id @ud, parent-id @ud) ".
                        "PRIMARY KEY (id) ".
                        "FOREIGN KEY (parent-id) REFERENCES node (id); "
                        ==
      ::
      :+  ~2034.2.2
          %db1
          "INSERT INTO node (id, parent-id) ".
          "VALUES (0, 0) (1, 0) (2, 1); "
      ::
      [~2034.2.3 %db1 "DELETE FROM node WHERE id = 2; "]
      ::
      [~2034.2.4 %db1 "FROM node WHERE id = 2 SELECT id, parent-id"]
      ::
      :-  %results
          :~  [%action 'SELECT']
              [%result-set ~]
              [%server-time ~2034.2.4]
              [%relation 'db1.dbo.node']
              [%schema-time ~2034.2.1]
              [%data-time ~2034.2.3]
              [%vector-count 0]
              ==
      ==
::
::  constrained-values cleared after child DELETE allows parent DELETE
++  test-foreign-key-18
  =|  run=@ud
  %-  exec-4-1
  :*  run
      :+  ~2034.3.1
          %db1
          %-  zing  :~  "CREATE DATABASE db1; "
                        create-parent
                        create-child
                        ==
      ::
      [~2034.3.2 %db1 "INSERT INTO parent (id, label) VALUES (0, 'bunt') (1, 'one'); "]
      ::
      [~2034.3.3 %db1 "INSERT INTO child (id, parent-id, note) VALUES (10, 1, 'alpha'); "]
      ::
      [~2034.3.4 %db1 "DELETE FROM child WHERE id = 10; "]
      ::
      [~2034.3.5 %db1 "DELETE FROM parent WHERE id = 1; "]
      ::
      [~2034.3.6 %db1 "FROM parent SELECT id, label"]
      ::
      :-  %results
          :~  [%action 'SELECT']
              :-  %result-set
                  :~  :-  %vector
                          :~  [%id [~.ud 0]]
                              [%label [~.t 'bunt']]
                              ==
                      ==
              [%server-time ~2034.3.6]
              [%relation 'db1.dbo.parent']
              [%schema-time ~2034.3.1]
              [%data-time ~2034.3.5]
              [%vector-count 1]
              ==
      ==
::
::  constrained-values updated after child FK-column UPDATE frees old parent
++  test-foreign-key-19
  =|  run=@ud
  %-  exec-4-1
  :*  run
      :+  ~2034.4.1
          %db1
          %-  zing  :~  "CREATE DATABASE db1; "
                        create-parent
                        create-child
                        ==
      ::
      :+  ~2034.4.2
          %db1
          "INSERT INTO parent (id, label) ".
          "VALUES (0, 'bunt') (1, 'one') (2, 'two'); "
      ::
      [~2034.4.3 %db1 "INSERT INTO child (id, parent-id, note) VALUES (10, 1, 'alpha'); "]
      ::
      [~2034.4.4 %db1 "UPDATE child SET parent-id = 2 WHERE id = 10; "]
      ::
      [~2034.4.5 %db1 "DELETE FROM parent WHERE id = 1; "]
      ::
      [~2034.4.6 %db1 "FROM parent SELECT id, label"]
      ::
      :-  %results
          :~  [%action 'SELECT']
              :-  %result-set
                  :~  :-  %vector
                          :~  [%id [~.ud 0]]
                              [%label [~.t 'bunt']]
                              ==
                      :-  %vector
                          :~  [%id [~.ud 2]]
                              [%label [~.t 'two']]
                              ==
                      ==
              [%server-time ~2034.4.6]
              [%relation 'db1.dbo.parent']
              [%schema-time ~2034.4.1]
              [%data-time ~2034.4.5]
              [%vector-count 2]
              ==
      ==
::
::  constrained-values follows child PK UPDATE; parent freed when updated child deleted
++  test-foreign-key-20
  =|  run=@ud
  %-  exec-5-1
  :*  run
      :+  ~2034.5.1
          %db1
          %-  zing  :~  "CREATE DATABASE db1; "
                        create-parent
                        create-child
                        ==
      ::
      [~2034.5.2 %db1 "INSERT INTO parent (id, label) VALUES (0, 'bunt') (1, 'one'); "]
      ::
      [~2034.5.3 %db1 "INSERT INTO child (id, parent-id, note) VALUES (10, 1, 'alpha'); "]
      ::
      [~2034.5.4 %db1 "UPDATE child SET id = 20 WHERE id = 10; "]
      ::
      [~2034.5.5 %db1 "DELETE FROM child WHERE id = 20; "]
      ::
      [~2034.5.6 %db1 "DELETE FROM parent WHERE id = 1; "]
      ::
      [~2034.5.7 %db1 "FROM parent SELECT id, label"]
      ::
      :-  %results
          :~  [%action 'SELECT']
              :-  %result-set
                  :~  :-  %vector
                          :~  [%id [~.ud 0]]
                              [%label [~.t 'bunt']]
                              ==
                      ==
              [%server-time ~2034.5.7]
              [%relation 'db1.dbo.parent']
              [%schema-time ~2034.5.1]
              [%data-time ~2034.5.6]
              [%vector-count 1]
              ==
      ==
::
::  rejects self-referential INSERT with missing parent reference
++  test-fail-foreign-key-30
  =|  run=@ud
  %-  failon-1
  :*  run
      :+  ~2034.6.1
          %db1
          %-  zing  :~  "CREATE DATABASE db1; "
                        "CREATE TABLE node ".
                        "(id @ud, parent-id @ud) ".
                        "PRIMARY KEY (id) ".
                        "FOREIGN KEY (parent-id) REFERENCES node (id); "
                        ==
      ::
      [~2034.6.2 %db1 "INSERT INTO node (id, parent-id) VALUES (1, 99); "]
      ::
      'INSERT: FOREIGN KEY parent key not found'
      ==
::
::  rejects DELETE of referenced self-FK row under RESTRICT
++  test-fail-foreign-key-31
  =|  run=@ud
  %-  failon-2
  :*  run
      :+  ~2034.7.1
          %db1
          %-  zing  :~  "CREATE DATABASE db1; "
                        "CREATE TABLE node ".
                        "(id @ud, parent-id @ud) ".
                        "PRIMARY KEY (id) ".
                        "FOREIGN KEY (parent-id) REFERENCES node (id); "
                        ==
      ::
      [~2034.7.2 %db1 "INSERT INTO node (id, parent-id) VALUES (0, 0) (1, 0); "]
      ::
      [~2034.7.3 %db1 "DELETE FROM node WHERE id = 0; "]
      ::
      'DELETE: FOREIGN KEY restrict violation'
      ==
::
::  rejects UPDATE of referenced self-FK primary key under RESTRICT
++  test-fail-foreign-key-32
  =|  run=@ud
  %-  failon-2
  :*  run
      :+  ~2034.8.1
          %db1
          %-  zing  :~  "CREATE DATABASE db1; "
                        "CREATE TABLE node ".
                        "(id @ud, parent-id @ud) ".
                        "PRIMARY KEY (id) ".
                        "FOREIGN KEY (parent-id) REFERENCES node (id); "
                        ==
      ::
      [~2034.8.2 %db1 "INSERT INTO node (id, parent-id) VALUES (0, 0) (1, 0); "]
      ::
      [~2034.8.3 %db1 "UPDATE node SET id = 99 WHERE id = 0; "]
      ::
      'UPDATE: FOREIGN KEY restrict violation'
      ==
::
::  constrained-values follows child PK UPDATE; parent remains protected
++  test-fail-foreign-key-33
  =|  run=@ud
  %-  failon-4
  :*  run
      :+  ~2034.9.1
          %db1
          %-  zing  :~  "CREATE DATABASE db1; "
                        create-parent
                        create-child
                        ==
      ::
      [~2034.9.2 %db1 "INSERT INTO parent (id, label) VALUES (0, 'bunt') (1, 'one'); "]
      ::
      [~2034.9.3 %db1 "INSERT INTO child (id, parent-id, note) VALUES (10, 1, 'alpha'); "]
      ::
      [~2034.9.4 %db1 "UPDATE child SET id = 20 WHERE id = 10; "]
      ::
      [~2034.9.5 %db1 "DELETE FROM parent WHERE id = 1; "]
      ::
      'DELETE: FOREIGN KEY restrict violation'
      ==
::
::  constrained-values set not empty until last child reference removed
++  test-fail-foreign-key-34
  =|  run=@ud
  %-  failon-4
  :*  run
      :+  ~2034.10.1
          %db1
          %-  zing  :~  "CREATE DATABASE db1; "
                        create-parent
                        create-child
                        ==
      ::
      [~2034.10.2 %db1 "INSERT INTO parent (id, label) VALUES (0, 'bunt') (1, 'one'); "]
      ::
      :+  ~2034.10.3
          %db1
          "INSERT INTO child (id, parent-id, note) ".
          "VALUES (10, 1, 'alpha') (11, 1, 'bravo'); "
      ::
      [~2034.10.4 %db1 "DELETE FROM child WHERE id = 10; "]
      ::
      [~2034.10.5 %db1 "DELETE FROM parent WHERE id = 1; "]
      ::
      'DELETE: FOREIGN KEY restrict violation'
      ==
::
::  RESTRICT enforced after ALTER TABLE ADD FOREIGN KEY over existing child rows
++  test-fail-foreign-key-35
  =|  run=@ud
  %-  failon-4
  :*  run
      :+  ~2034.11.1
          %db1
          %-  zing  :~  "CREATE DATABASE db1; "
                        create-parent
                        "CREATE TABLE child ".
                        "(id @ud, parent-id @ud, note @t) ".
                        "PRIMARY KEY (id); "
                        ==
      ::
      [~2034.11.2 %db1 "INSERT INTO parent (id, label) VALUES (0, 'bunt') (1, 'one'); "]
      ::
      [~2034.11.3 %db1 "INSERT INTO child (id, parent-id, note) VALUES (10, 1, 'alpha'); "]
      ::
      :+  ~2034.11.4
          %db1
          "ALTER TABLE child ADD FOREIGN KEY ".
          "(parent-id) REFERENCES parent (id); "
      ::
      [~2034.11.5 %db1 "DELETE FROM parent WHERE id = 1; "]
      ::
      'DELETE: FOREIGN KEY restrict violation'
      ==
--
