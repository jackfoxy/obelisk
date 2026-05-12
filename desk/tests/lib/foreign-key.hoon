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
::
::  CREATE TABLE with FOREIGN KEY and valid INSERTs
++  test-foreign-key-00
  =|  run=@ud
  %-  exec-0-1
  :*  run
      :+  ~2030.1.1
          %db1
          %-  zing  :~  "CREATE DATABASE db1; "
                        create-parent
                        create-child
                        insert-parents
                        insert-children
                        ==
      ::
      :+  ~2030.1.2
          %db1
          "FROM child SELECT id, parent-id, note"
      ::
      :-  %results
          :~  [%action 'SELECT']
              [%result-set child-10-11]
              [%server-time ~2030.1.2]
              [%relation 'db1.dbo.child']
              [%schema-time ~2030.1.1]
              [%data-time ~2030.1.1]
              [%vector-count 2]
              ==
      ==
::
::  ALTER TABLE ADD FOREIGN KEY over existing valid rows
++  test-foreign-key-01
  =|  run=@ud
  %-  exec-0-1
  :*  run
      :+  ~2030.2.1
          %db1
          %-  zing  :~  "CREATE DATABASE db1; "
                        create-parent
                        "CREATE TABLE child ".
                        "(id @ud, parent-id @ud, note @t) ".
                        "PRIMARY KEY (id); "
                        insert-parents
                        insert-children
                        "ALTER TABLE child ADD FOREIGN KEY ".
                        "(parent-id) REFERENCES parent (id); "
                        ==
      ::
      [~2030.2.2 %db1 "FROM child SELECT id, parent-id, note"]
      ::
      :-  %results
          :~  [%action 'SELECT']
              [%result-set child-10-11]
              [%server-time ~2030.2.2]
              [%relation 'db1.dbo.child']
              [%schema-time ~2030.2.1]
              [%data-time ~2030.2.1]
              [%vector-count 2]
              ==
      ==
::
::  ALTER TABLE DROP FOREIGN KEY removes enforcement
++  test-foreign-key-02
  =|  run=@ud
  %-  exec-0-1
  :*  run
      :+  ~2030.3.1
          %db1
          %-  zing  :~  "CREATE DATABASE db1; "
                        create-parent
                        create-child
                        insert-parents
                        insert-children
                        "ALTER TABLE child DROP FOREIGN KEY ".
                        "(parent-id) parent; "
                        "INSERT INTO child (id, parent-id, note) ".
                        "VALUES (12, 99, 'orphan'); "
                        ==
      ::
      :+  ~2030.3.2
          %db1
          "FROM child SELECT id, parent-id, note WHERE id = 12"
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
              [%server-time ~2030.3.2]
              [%relation 'db1.dbo.child']
              [%schema-time ~2030.3.1]
              [%data-time ~2030.3.1]
              [%vector-count 1]
              ==
      ==
::
::  ON DELETE CASCADE removes child rows
++  test-foreign-key-03
  =|  run=@ud
  %-  exec-0-1
  :*  run
      :+  ~2030.4.1
          %db1
          %-  zing  :~  "CREATE DATABASE db1; "
                        create-parent
                        create-child-cascade
                        insert-parents
                        insert-children
                        "DELETE FROM parent WHERE id = 1; "
                        ==
      ::
      [~2030.4.2 %db1 "FROM child SELECT id, parent-id, note"]
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
              [%server-time ~2030.4.2]
              [%relation 'db1.dbo.child']
              [%schema-time ~2030.4.1]
              [%data-time ~2030.4.1]
              [%vector-count 1]
              ==
      ==
::
::  ON DELETE SET DEFAULT sets child key columns to bunt values
++  test-foreign-key-04
  =|  run=@ud
  %-  exec-0-1
  :*  run
      :+  ~2030.5.1
          %db1
          %-  zing  :~  "CREATE DATABASE db1; "
                        create-parent
                        create-child-set-default
                        insert-parents
                        insert-children
                        "DELETE FROM parent WHERE id = 1; "
                        ==
      ::
      :+  ~2030.5.2
          %db1
          "FROM child SELECT id, parent-id, note WHERE id = 10"
      ::
      :-  %results
          :~  [%action 'SELECT']
              [%result-set child-10-parent-0]
              [%server-time ~2030.5.2]
              [%relation 'db1.dbo.child']
              [%schema-time ~2030.5.1]
              [%data-time ~2030.5.1]
              [%vector-count 1]
              ==
      ==
::
::  ON UPDATE CASCADE updates child key columns
++  test-foreign-key-05
  =|  run=@ud
  %-  exec-0-1
  :*  run
      :+  ~2030.6.1
          %db1
          %-  zing  :~  "CREATE DATABASE db1; "
                        create-parent
                        create-child-cascade
                        insert-parents
                        insert-children
                        "UPDATE parent SET id = 3 WHERE id = 1; "
                        ==
      ::
      :+  ~2030.6.2
          %db1
          "FROM child SELECT id, parent-id, note WHERE id = 10"
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
              [%server-time ~2030.6.2]
              [%relation 'db1.dbo.child']
              [%schema-time ~2030.6.1]
              [%data-time ~2030.6.1]
              [%vector-count 1]
              ==
      ==
::
::  ON UPDATE SET DEFAULT sets child key columns to bunt values
++  test-foreign-key-06
  =|  run=@ud
  %-  exec-0-1
  :*  run
      :+  ~2030.7.1
          %db1
          %-  zing  :~  "CREATE DATABASE db1; "
                        create-parent
                        create-child-set-default
                        insert-parents
                        insert-children
                        "UPDATE parent SET id = 3 WHERE id = 1; "
                        ==
      ::
      :+  ~2030.7.2
          %db1
          "FROM child SELECT id, parent-id, note WHERE id = 10"
      ::
      :-  %results
          :~  [%action 'SELECT']
              [%result-set child-10-parent-0]
              [%server-time ~2030.7.2]
              [%relation 'db1.dbo.child']
              [%schema-time ~2030.7.1]
              [%data-time ~2030.7.1]
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
  %-  exec-0-1
  :*  run
      :+  ~2030.9.1
          %db1
          %-  zing  :~  "CREATE DATABASE db1; "
                        create-parent
                        create-child
                        insert-parents
                        insert-children
                        "DROP TABLE FORCE parent; "
                        "INSERT INTO child (id, parent-id, note) ".
                        "VALUES (12, 99, 'after-force'); "
                        ==
      ::
      :+  ~2030.9.2
          %db1
          "FROM child SELECT id, parent-id, note WHERE id = 12"
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
              [%server-time ~2030.9.2]
              [%relation 'db1.dbo.child']
              [%schema-time ~2030.9.1]
              [%data-time ~2030.9.1]
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
  %-  failon-0
  :*  run
      :+  ~2031.8.1
          %db1
          %-  zing  :~  "CREATE DATABASE db1; "
                        create-parent
                        "CREATE TABLE child ".
                        "(id @ud, parent-id @ud, note @t) PRIMARY KEY (id); "
                        insert-parents
                        "INSERT INTO child (id, parent-id, note) ".
                        "VALUES (10, 99, 'orphan'); "
                        "ALTER TABLE child ADD FOREIGN KEY ".
                        "(parent-id) REFERENCES parent (id); "
                        ==
      ::
      'ALTER TABLE: FOREIGN KEY parent key not found'
      ==
::
::  rejects DROP FOREIGN KEY that does not match any constraint
++  test-fail-foreign-key-08
  =|  run=@ud
  %-  failon-0
  :*  run
      :+  ~2031.9.1
          %db1
          %-  zing  :~  "CREATE DATABASE db1; "
                        create-parent
                        create-child
                        "ALTER TABLE child DROP FOREIGN KEY ".
                        "(parent-id) missing-parent; "
                        ==
      ::
      'ALTER TABLE: foreign key to drop does not exist'
      ==
::
::  rejects INSERT when parent key is missing
++  test-fail-foreign-key-09
  =|  run=@ud
  %-  failon-0
  :*  run
      :+  ~2031.10.1
          %db1
          %-  zing  :~  "CREATE DATABASE db1; "
                        create-parent
                        create-child
                        insert-parents
                        "INSERT INTO child (id, parent-id, note) ".
                        "VALUES (10, 99, 'orphan'); "
                        ==
      ::
      'INSERT: FOREIGN KEY parent key not found'
      ==
::
::  rejects UPDATE of a child key to a missing parent key
++  test-fail-foreign-key-10
  =|  run=@ud
  %-  failon-0
  :*  run
      :+  ~2031.11.1
          %db1
          %-  zing  :~  "CREATE DATABASE db1; "
                        create-parent
                        create-child
                        insert-parents
                        insert-children
                        "UPDATE child SET parent-id = 99 WHERE id = 10; "
                        ==
      ::
      'UPDATE: FOREIGN KEY parent key not found'
      ==
::
::  rejects DELETE of referenced parent rows under RESTRICT
++  test-fail-foreign-key-11
  =|  run=@ud
  %-  failon-0
  :*  run
      :+  ~2031.12.1
          %db1
          %-  zing  :~  "CREATE DATABASE db1; "
                        create-parent
                        create-child
                        insert-parents
                        insert-children
                        "DELETE FROM parent WHERE id = 1; "
                        ==
      ::
      'DELETE: FOREIGN KEY restrict violation'
      ==
::
::  rejects UPDATE of referenced parent keys under RESTRICT
++  test-fail-foreign-key-12
  =|  run=@ud
  %-  failon-0
  :*  run
      :+  ~2032.1.1
          %db1
          %-  zing  :~  "CREATE DATABASE db1; "
                        create-parent
                        create-child
                        insert-parents
                        insert-children
                        "UPDATE parent SET id = 3 WHERE id = 1; "
                        ==
      ::
      'UPDATE: FOREIGN KEY restrict violation'
      ==
::
::  rejects SET DEFAULT when the referenced table lacks the bunt key
++  test-fail-foreign-key-13
  =|  run=@ud
  %-  failon-0
  :*  run
      :+  ~2032.2.1
          %db1
          %-  zing  :~  "CREATE DATABASE db1; "
                        "CREATE TABLE parent ".
                        "(id @ud, label @t) PRIMARY KEY (id); "
                        create-child-set-default
                        "INSERT INTO parent (id, label) ".
                        "VALUES (1, 'one'); "
                        "INSERT INTO child (id, parent-id, note) ".
                        "VALUES (10, 1, 'alpha'); "
                        "DELETE FROM parent WHERE id = 1; "
                        ==
      ::
      'DELETE: FOREIGN KEY SET DEFAULT parent bunt key not found'
      ==
::
::  rejects TRUNCATE of referenced parent rows under RESTRICT
++  test-fail-foreign-key-14
  =|  run=@ud
  %-  failon-0
  :*  run
      :+  ~2032.3.1
          %db1
          %-  zing  :~  "CREATE DATABASE db1; "
                        create-parent
                        create-child
                        insert-parents
                        insert-children
                        "TRUNCATE TABLE parent; "
                        ==
      ::
      'TRUNCATE TABLE: FOREIGN KEY restrict violation'
      ==
::
::  rejects DROP TABLE of a referenced table without FORCE
++  test-fail-foreign-key-15
  =|  run=@ud
  %-  failon-0
  :*  run
      :+  ~2032.4.1
          %db1
          %-  zing  :~  "CREATE DATABASE db1; "
                        create-parent
                        create-child
                        "DROP TABLE parent; "
                        ==
      ::
      'DROP TABLE: %parent used in FOREIGN KEY, use FORCE to DROP'
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
  %-  failon-0
  :*  run
      :+  ~2032.6.1
          %db1
          %-  zing  :~  "CREATE DATABASE db1; ".
                        "CREATE DATABASE db2; ".
                        "CREATE NAMESPACE db2.ns2; "
                        create-parent
                        create-child
                        "ALTER NAMESPACE db2.ns2 TRANSFER TABLE child; "
                        ==
      ::
      'ALTER NAMESPACE: FOREIGN KEY cross-database transfer not allowed'
      ==
::
::  rejects dropping a referenced primary-key column
++  test-fail-foreign-key-18
  =|  run=@ud
  %-  failon-0
  :*  run
      :+  ~2032.7.1
          %db1
          %-  zing  :~  "CREATE DATABASE db1; "
                        create-parent
                        create-child
                        "ALTER TABLE parent DROP COLUMN (id); "
                        ==
      ::
      'ALTER TABLE: column %id is referenced by FOREIGN KEY'
      ==
--
