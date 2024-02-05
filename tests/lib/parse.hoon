/-  ast
/+  parse,  *test
::
:: we frequently break the rules of unit and regression tests here
:: by testing more than one thing per result, otherwise there would
:: just be too many tests
::
:: each arm tests one urql command
::
:: common things to test
:: 1) basic command works producing AST object
:: 2) multiple ASTs
:: 3) all keywords are case ambivalent
:: 4) all names follow rules for faces
:: 5) all qualifier combinations work
::
:: -test /=urql=/tests/lib/parse/hoon ~
|%
:: current database must be proper face
++  test-fail-default-database
    %-  expect-fail
    |.  (parse:parse(default-database 'oTher-db') "cReate\0d\09  namespace my-namespace")
::
:: alter index
::
:: tests 1, 2, 3, 5, and extra whitespace characters, alter index... db.ns.index db.ns.table columns action; alter index db..index db..table one column
++  test-alter-index-1
  =/  expected1  [%alter-index name=[%qualified-object ship=~ database='db' namespace='ns' name='my-index'] object=[%qualified-object ship=~ database='db' namespace='ns' name='table'] columns=~[[%ordered-column name='col1' is-ascending=%.y] [%ordered-column name='col2' is-ascending=%.n] [%ordered-column name='col3' is-ascending=%.y]] action=%disable]
  =/  expected2  [%alter-index name=[%qualified-object ship=~ database='db' namespace='dbo' name='my-index'] object=[%qualified-object ship=~ database='db' namespace='dbo' name='table'] columns=~[[%ordered-column name='col1' is-ascending=%.y]] action=%rebuild]
  %+  expect-eq
    !>  ~[expected1 expected2]
    !>  (parse:parse(default-database 'db1') "aLter \0d INdEX\09db.ns.my-index On db.ns.table  ( col1  asc , col2\0a desc  , col3) \0a dIsable \0a;\0a aLter \0d INdEX\09db..my-index On db..table  ( col1  asc ) \0a \0a rEBuild ")
::
:: alter index 1 column without action
++  test-alter-index-2
  =/  expected  [%alter-index name=[%qualified-object ship=~ database='db' namespace='ns' name='my-index'] object=[%qualified-object ship=~ database='db' namespace='ns' name='table'] columns=~[[%ordered-column name='col1' is-ascending=%.y]] action=%rebuild]
  %+  expect-eq
    !>  ~[expected]
    !>  (parse:parse(default-database 'db1') "ALTER INDEX db.ns.my-index ON db.ns.table (col1)")
::
:: leading whitespace characters, end delimiter, alter ns.index ns.table columns no action
++  test-alter-index-3
  =/  expected  [%alter-index name=[%qualified-object ship=~ database='db1' namespace='ns' name='my-index'] object=[%qualified-object ship=~ database='db1' namespace='ns' name='table'] columns=~[[%ordered-column name='col1' is-ascending=%.y] [%ordered-column name='col2' is-ascending=%.n] [%ordered-column name='col3' is-ascending=%.y]] action=%rebuild]
  %+  expect-eq
    !>  ~[expected]
    !>  (parse:parse(default-database 'db1') "  \0d alter INDEX ns.my-index ON ns.table (col1, col2 desc, col3 asc);")
::
:: alter index table no columns, action only
++  test-alter-index-4
  =/  expected  [%alter-index name=[%qualified-object ship=~ database='db1' namespace='dbo' name='my-index'] object=[%qualified-object ship=~ database='db1' namespace='dbo' name='table'] columns=~ action=%resume]
  %+  expect-eq
    !>  ~[expected]
    !>  (parse:parse(default-database 'db1') "ALTER INDEX my-index ON table RESUME")
::
:: fail when namespace qualifier is not a term
++  test-fail-alter-index-5
  %-  expect-fail
  |.  (parse:parse(default-database 'db2') "alter index my-index ON db.Ns.table (col1, col2) resume")
::
:: fail when table name is not a term
++  test-fail-alter-index-6
  %-  expect-fail
  |.  (parse:parse(default-database 'other-db') "alter index my-index ON db.ns.Table (col1, col2) resume")
::
::
:: alter namespace
::
:: tests 1, 2, 3, 5, and extra whitespace characters, alter namespace db.ns db.ns2.table ; ns db..table
++  test-alter-namespace-00
  =/  expected1  [%alter-namespace database-name='db' source-namespace='ns' object-type=%table target-namespace='ns2' target-name='table' as-of=~]
  =/  expected2  [%alter-namespace database-name='db1' source-namespace='ns' object-type=%table target-namespace='dbo' target-name='table' as-of=~]
  %+  expect-eq
    !>  ~[expected1 expected2]
    !>  (parse:parse(default-database 'db1') " ALtER NAmESPACE   db.ns   TRANsFER   TaBLE  db.ns2.table \0a;\0a ALTER NAMESPACE ns TRANSFER TABLE db..table ")
::
:: alter namespace  ns table
++  test-alter-namespace-01
  =/  expected  [%alter-namespace database-name='db1' source-namespace='ns' object-type=%table target-namespace='dbo' target-name='table' as-of=~]  %+  expect-eq
    !>  ~[expected]
    !>  (parse:parse(default-database 'db1') "ALTER NAMESPACE ns TRANSFER TABLE table ")
::
:: alter namespace db.ns db.ns2.table as of now
++  test-alter-namespace-02
  %+  expect-eq
    !>  ~[[%alter-namespace database-name='db' source-namespace='ns' object-type=%table target-namespace='ns2' target-name='table' as-of=~]]
    !>  (parse:parse(default-database 'db1') "alter namespace db.ns transfer table db.ns2.table as of now")
::
:: alter namespace db.ns db.ns2.table as of ~2023.12.25..7.15.0..1ef5
++  test-alter-namespace-03
  %+  expect-eq
    !>  ~[[%alter-namespace database-name='db' source-namespace='ns' object-type=%table target-namespace='ns2' target-name='table' as-of=[~ [%da ~2023.12.25..7.15.0..1ef5]]]]
    !>  (parse:parse(default-database 'db1') "alter namespace db.ns transfer table db.ns2.table as of ~2023.12.25..7.15.0..1ef5")
::
:: alter namespace db.ns db.ns2.table as of 5 days ago
++  test-alter-namespace-04
  %+  expect-eq
    !>  ~[[%alter-namespace database-name='db' source-namespace='ns' object-type=%table target-namespace='ns2' target-name='table' as-of=[~ %as-of-offset 5 %days]]]
    !>  (parse:parse(default-database 'db1') "alter namespace db.ns transfer table db.ns2.table as of 5 days ago")
::
:: alter namespace ns table as of now
++  test-alter-namespace-05
  %+  expect-eq
    !>  ~[[%alter-namespace database-name='db1' source-namespace='ns' object-type=%table target-namespace='dbo' target-name='table' as-of=~]]
    !>  (parse:parse(default-database 'db1') "alter namespace ns transfer table table as of now")
::
:: alter namespace ns table as of ~2023.12.25..7.15.0..1ef5
++  test-alter-namespace-06
  %+  expect-eq
    !>  ~[[%alter-namespace database-name='db1' source-namespace='ns' object-type=%table target-namespace='dbo' target-name='table' as-of=[~ [%da ~2023.12.25..7.15.0..1ef5]]]]
    !>  (parse:parse(default-database 'db1') "alter namespace ns transfer table table as of ~2023.12.25..7.15.0..1ef5")
::
:: alter namespace ns table as of 5 days ago
++  test-alter-namespace-07
  %+  expect-eq
    !>  ~[[%alter-namespace database-name='db1' source-namespace='ns' object-type=%table target-namespace='dbo' target-name='table' as-of=[~ %as-of-offset 5 %days]]]
    !>  (parse:parse(default-database 'db1') "alter namespace ns transfer table table as of 5 days ago")
::
:: alter namespace ns table as of ~d3.h5.m30.s12
++  test-alter-namespace-08
  %+  expect-eq
    !>  ~[[%alter-namespace database-name='db1' source-namespace='ns' object-type=%table target-namespace='dbo' target-name='table' as-of=[~ [%dr ~d3.h5.m30.s12]]]]
    !>  (parse:parse(default-database 'db1') "alter namespace ns transfer table table as of ~d3.h5.m30.s12")
::
:: alter namespace ns table as of ~h5.m30.s12
++  test-alter-namespace-09
  %+  expect-eq
    !>  ~[[%alter-namespace database-name='db1' source-namespace='ns' object-type=%table target-namespace='dbo' target-name='table' as-of=[~ [%dr ~h5.m30.s12]]]]
    !>  (parse:parse(default-database 'db1') "alter namespace ns transfer table table as of ~h5.m30.s12")
::
:: alter namespace ns table as of ~m30.s12
++  test-alter-namespace-10
  %+  expect-eq
    !>  ~[[%alter-namespace database-name='db1' source-namespace='ns' object-type=%table target-namespace='dbo' target-name='table' as-of=[~ [%dr ~m30.s12]]]]
    !>  (parse:parse(default-database 'db1') "alter namespace ns transfer table table as of ~m30.s12")
::
:: alter namespace ns table as of ~s12
++  test-alter-namespace-11
  %+  expect-eq
    !>  ~[[%alter-namespace database-name='db1' source-namespace='ns' object-type=%table target-namespace='dbo' target-name='table' as-of=[~ [%dr ~s12]]]]
    !>  (parse:parse(default-database 'db1') "alter namespace ns transfer table table as of ~s12")
::
:: fail when namespace qualifier is not a term
++  test-fail-alter-namespace-12
  %-  expect-fail
  |.  (parse:parse(default-database 'db2') "ALTER NAMESPACE db.nS TRANSFER TABLE db.ns2.table")
::
:: fail when table name is not a term
++  test-fail-alter-namespace-13
  %-  expect-fail
  |.  (parse:parse(default-database 'other-db') "ALTER NAMESPACE db.ns TRANSFER TABLE db.ns2.tAble")
::
::
:: alter table
::
:: tests 1, 2, 3, 5, and extra whitespace characters
:: alter column db.ns.table 3 columns ; alter column db..table 1 column
++  test-alter-table-00
  =/  expected1  [%alter-table table=[%qualified-object ship=~ database='db' namespace='ns' name='table'] alter-columns=~ add-columns=~[[%column name='col1' column-type=%t] [%column name='col2' column-type=%p] [%column name='col3' column-type=%ud]] drop-columns=~ add-foreign-keys=~ drop-foreign-keys=~ as-of=~]
  =/  expected2  [%alter-table table=[%qualified-object ship=~ database='db' namespace='dbo' name='table'] alter-columns=~ add-columns=~[[%column name='col1' column-type=%t]] drop-columns=~ add-foreign-keys=~ drop-foreign-keys=~ as-of=~]
  %+  expect-eq
    !>  ~[expected1 expected2]
    !>  (parse:parse(default-database 'db1') " ALtER  TaBLE  db.ns.table  AdD  COlUMN  ( col1  @t ,  col2  @p ,  col3  @ud ) \0a;\0a ALTER TABLE db..table ADD COLUMN (col1 @t) ")
::
:: alter column table 3 columns
++  test-alter-table-01
  =/  expected  [%alter-table table=[%qualified-object ship=~ database='db1' namespace='dbo' name='table'] alter-columns=~[[%column name='col1' column-type=%t] [%column name='col2' column-type=%p] [%column name='col3' column-type=%ud]] add-columns=~ drop-columns=~ add-foreign-keys=~ drop-foreign-keys=~ as-of=~]
  %+  expect-eq
    !>  ~[expected]
    !>  (parse:parse(default-database 'db1') "ALTER TABLE table ALTER COLUMN (col1 @t, col2 @p, col3 @ud)")
::
:: alter column table 1 column
++  test-alter-table-02
  =/  expected  [%alter-table table=[%qualified-object ship=~ database='db1' namespace='dbo' name='table'] alter-columns=~[[%column name='col1' column-type=%t]] add-columns=~ drop-columns=~ add-foreign-keys=~ drop-foreign-keys=~ as-of=~]
  %+  expect-eq
    !>  ~[expected]
    !>  (parse:parse(default-database 'db1') "ALTER TABLE table ALTER COLUMN (col1 @t)")
::
:: drop column table 3 columns
++  test-alter-table-03
  =/  expected  [%alter-table table=[%qualified-object ship=~ database='db1' namespace='dbo' name='table'] alter-columns=~ add-columns=~ drop-columns=['col1' 'col2' 'col3' ~] add-foreign-keys=~ drop-foreign-keys=~ as-of=~]
  %+  expect-eq
    !>  ~[expected]
    !>  (parse:parse(default-database 'db1') "ALTER TABLE table DROP COLUMN (col1, col2, col3)")
::
:: drop column table 1 column
++  test-alter-table-04
  =/  expected  [%alter-table table=[%qualified-object ship=~ database='db1' namespace='dbo' name='table'] alter-columns=~ add-columns=~ drop-columns=['col1' ~] add-foreign-keys=~ drop-foreign-keys=~ as-of=~]
  %+  expect-eq
    !>  ~[expected]
    !>  (parse:parse(default-database 'db1') "ALTER TABLE table DROP COLUMN (col1)")
::
:: add 2 foreign keys, extra spaces and mixed case key words
++  test-alter-table-05
  =/  expected  [%alter-table table=[%qualified-object ship=~ database='db1' namespace='dbo' name='table'] alter-columns=~ add-columns=~ drop-columns=~ add-foreign-keys=~[[%foreign-key name='fk' table=[%qualified-object ship=~ database='db1' namespace='dbo' name='table'] columns=~[[%ordered-column name='col1' is-ascending=%.y] [%ordered-column name='col2' is-ascending=%.n]] reference-table=[%qualified-object ship=~ database='db1' namespace='dbo' name='fk-table'] reference-columns=['col19' 'col20' ~] referential-integrity=~[%delete-cascade %update-cascade]] [%foreign-key name='fk2' table=[%qualified-object ship=~ database='db1' namespace='dbo' name='table'] columns=~[[%ordered-column name='col1' is-ascending=%.y] [%ordered-column name='col2' is-ascending=%.n]] reference-table=[%qualified-object ship=~ database='db1' namespace='dbo' name='fk-table2'] reference-columns=['col19' 'col20' ~] referential-integrity=~[%delete-cascade %update-cascade]]] drop-foreign-keys=~ as-of=~]
  =/  urql  "ALTER TABLE table ADD FOREIGN KEY fk  ( col1 , col2  desc )  reFerences  fk-table  ( col19 ,  col20 )  On  dELETE  CAsCADE  oN  UPdATE  CAScADE, fk2  ( col1 ,  col2  desc )  reFerences  fk-table2  ( col19 ,  col20 )  On  dELETE  CAsCADE  oN  UPdATE  CAScADE "
  %+  expect-eq
    !>  ~[expected]
    !>  (parse:parse(default-database 'db1') urql)
::
:: drop 2 foreign keys, extra spaces
++  test-alter-table-06
  =/  expected  [%alter-table table=[%qualified-object ship=~ database='db1' namespace='dbo' name='mytable'] alter-columns=~ add-columns=~ drop-columns=~ add-foreign-keys=~ drop-foreign-keys=['fk1' 'fk2' ~] as-of=~]
  %+  expect-eq
    !>  ~[expected]
    !>  (parse:parse(default-database 'db1') " ALTER  TABLE  mytable  DROP  FOREIGN  KEY  ( fk1,  fk2 )")
::
:: drop 2 foreign keys, no extra spaces
++  test-alter-table-07
  =/  expected  [%alter-table table=[%qualified-object ship=~ database='db' namespace='dbo' name='mytable'] alter-columns=~ add-columns=~ drop-columns=~ add-foreign-keys=~ drop-foreign-keys=['fk1' 'fk2' ~] as-of=~]
  %+  expect-eq
    !>  ~[expected]
    !>  (parse:parse(default-database 'db1') "ALTER TABLE db..mytable DROP FOREIGN KEY (fk1,fk2)")
::
:: drop 1 foreign key
++  test-alter-table-08
  =/  expected  [%alter-table table=[%qualified-object ship=~ database='db1' namespace='ns' name='mytable'] alter-columns=~ add-columns=~ drop-columns=~ add-foreign-keys=~ drop-foreign-keys=['fk1' ~] as-of=~]
  %+  expect-eq
    !>  ~[expected]
    !>  (parse:parse(default-database 'db1') "ALTER TABLE ns.mytable DROP FOREIGN KEY (fk1)")
::
::  add column as of now
++  test-alter-table-09
  =/  expected  [%alter-table table=[%qualified-object ship=~ database='db' namespace='ns' name='table'] alter-columns=~ add-columns=~[[%column name='col1' column-type=%t] [%column name='col2' column-type=%p] [%column name='col3' column-type=%ud]] drop-columns=~ add-foreign-keys=~ drop-foreign-keys=~ as-of=~]
    %+  expect-eq
    !>  ~[expected]
    !>  (parse:parse(default-database 'db1') "alter table  db.ns.table  add  column  ( col1  @t ,  col2  @p ,  col3  @ud ) as of now")
::
::  add column as of now
++  test-alter-table-10
  =/  expected  [%alter-table table=[%qualified-object ship=~ database='db' namespace='ns' name='table'] alter-columns=~ add-columns=~[[%column name='col1' column-type=%t] [%column name='col2' column-type=%p] [%column name='col3' column-type=%ud]] drop-columns=~ add-foreign-keys=~ drop-foreign-keys=~ as-of=[~ [%da ~2023.12.25..7.15.0..1ef5]]]
    %+  expect-eq
    !>  ~[expected]
    !>  (parse:parse(default-database 'db1') "alter table  db.ns.table  add  column  ( col1  @t ,  col2  @p ,  col3  @ud ) as of ~2023.12.25..7.15.0..1ef5")
::
::  add column as of 1 weeks ago
++  test-alter-table-11
  =/  expected  [%alter-table table=[%qualified-object ship=~ database='db' namespace='ns' name='table'] alter-columns=~ add-columns=~[[%column name='col1' column-type=%t] [%column name='col2' column-type=%p] [%column name='col3' column-type=%ud]] drop-columns=~ add-foreign-keys=~ drop-foreign-keys=~ as-of=[~ [%as-of-offset 1 %weeks]]]
    %+  expect-eq
    !>  ~[expected]
    !>  (parse:parse(default-database 'db1') "alter table  db.ns.table  add  column  ( col1  @t ,  col2  @p ,  col3  @ud ) as of 1 weeks ago")
::
:: alter column as of now
++  test-alter-table-12
  =/  expected  [%alter-table table=[%qualified-object ship=~ database='db1' namespace='dbo' name='table'] alter-columns=~[[%column name='col1' column-type=%t] [%column name='col2' column-type=%p]] add-columns=~ drop-columns=~ add-foreign-keys=~ drop-foreign-keys=~ as-of=~]
  %+  expect-eq
    !>  ~[expected]
    !>  (parse:parse(default-database 'db1') "alter table table alter column (col1 @t, col2 @p) as of now")
::
:: alter column as of ~2023.12.25..7.15.0..1ef5
++  test-alter-table-13
  =/  expected  [%alter-table table=[%qualified-object ship=~ database='db1' namespace='dbo' name='table'] alter-columns=~[[%column name='col1' column-type=%t] [%column name='col2' column-type=%p] [%column name='col3' column-type=%ud]] add-columns=~ drop-columns=~ add-foreign-keys=~ drop-foreign-keys=~ as-of=[~ [%da ~2023.12.25..7.15.0..1ef5]]]
  %+  expect-eq
    !>  ~[expected]
    !>  (parse:parse(default-database 'db1') "alter table table alter column (col1 @t, col2 @p, col3 @ud) as of ~2023.12.25..7.15.0..1ef5")
::
:: alter column as of 5 days ago
++  test-alter-table-14
  =/  expected  [%alter-table table=[%qualified-object ship=~ database='db1' namespace='dbo' name='table'] alter-columns=~[[%column name='col1' column-type=%t]] add-columns=~ drop-columns=~ add-foreign-keys=~ drop-foreign-keys=~ as-of=[~ %as-of-offset 5 %days]]
  %+  expect-eq
    !>  ~[expected]
    !>  (parse:parse(default-database 'db1') "alter table table alter column (col1 @t) as of 5 days ago")
::
:: drop column as of now
++  test-alter-table-15
  =/  expected  [%alter-table table=[%qualified-object ship=~ database='db1' namespace='dbo' name='table'] alter-columns=~ add-columns=~ drop-columns=['col1' 'col2' ~] add-foreign-keys=~ drop-foreign-keys=~ as-of=~]
  %+  expect-eq
    !>  ~[expected]
    !>  (parse:parse(default-database 'db1') "alter table table drop column (col1, col2) as of now")
::
:: drop column as of ~2023.12.25..7.15.0..1ef5
++  test-alter-table-16
  =/  expected  [%alter-table table=[%qualified-object ship=~ database='db1' namespace='dbo' name='table'] alter-columns=~ add-columns=~ drop-columns=['col1' ~] add-foreign-keys=~ drop-foreign-keys=~ as-of=[~ [%da ~2023.12.25..7.15.0..1ef5]]]
  %+  expect-eq
    !>  ~[expected]
    !>  (parse:parse(default-database 'db1') "alter table table drop column (col1) as of ~2023.12.25..7.15.0..1ef5")
::
:: drop column as of 5 days ago
++  test-alter-table-17
  =/  expected  [%alter-table table=[%qualified-object ship=~ database='db1' namespace='dbo' name='table'] alter-columns=~ add-columns=~ drop-columns=['col1' 'col2' 'col3' ~] add-foreign-keys=~ drop-foreign-keys=~ as-of=[~ %as-of-offset 5 %days]]
  %+  expect-eq
    !>  ~[expected]
    !>  (parse:parse(default-database 'db1') "alter table table drop column (col1, col2, col3) as of 5 days ago")
::
:: add 2 foreign keys as of now
++  test-alter-table-18
  =/  expected  [%alter-table table=[%qualified-object ship=~ database='db1' namespace='dbo' name='table'] alter-columns=~ add-columns=~ drop-columns=~ add-foreign-keys=~[[%foreign-key name='fk' table=[%qualified-object ship=~ database='db1' namespace='dbo' name='table'] columns=~[[%ordered-column name='col1' is-ascending=%.y] [%ordered-column name='col2' is-ascending=%.n]] reference-table=[%qualified-object ship=~ database='db1' namespace='dbo' name='fk-table'] reference-columns=['col19' 'col20' ~] referential-integrity=~[%delete-cascade %update-cascade]] [%foreign-key name='fk2' table=[%qualified-object ship=~ database='db1' namespace='dbo' name='table'] columns=~[[%ordered-column name='col1' is-ascending=%.y] [%ordered-column name='col2' is-ascending=%.n]] reference-table=[%qualified-object ship=~ database='db1' namespace='dbo' name='fk-table2'] reference-columns=['col19' 'col20' ~] referential-integrity=~[%delete-cascade %update-cascade]]] drop-foreign-keys=~ as-of=~]
  =/  urql  "alter table table add foreign key fk  ( col1 , col2  desc )  references  fk-table  ( col19 ,  col20 )  on  delete  cascade  on  update  cascade, fk2  ( col1 ,  col2  desc )  references  fk-table2  ( col19 ,  col20 )  on  delete  cascade  on  update  cascade as of now"
  %+  expect-eq
    !>  ~[expected]
    !>  (parse:parse(default-database 'db1') urql)
::
:: add 2 foreign keys as of ~2023.12.25..7.15.0..1ef5
++  test-alter-table-19
  =/  expected  [%alter-table table=[%qualified-object ship=~ database='db1' namespace='dbo' name='table'] alter-columns=~ add-columns=~ drop-columns=~ add-foreign-keys=~[[%foreign-key name='fk' table=[%qualified-object ship=~ database='db1' namespace='dbo' name='table'] columns=~[[%ordered-column name='col1' is-ascending=%.y] [%ordered-column name='col2' is-ascending=%.n]] reference-table=[%qualified-object ship=~ database='db1' namespace='dbo' name='fk-table'] reference-columns=['col19' 'col20' ~] referential-integrity=~[%delete-cascade %update-cascade]] [%foreign-key name='fk2' table=[%qualified-object ship=~ database='db1' namespace='dbo' name='table'] columns=~[[%ordered-column name='col1' is-ascending=%.y] [%ordered-column name='col2' is-ascending=%.n]] reference-table=[%qualified-object ship=~ database='db1' namespace='dbo' name='fk-table2'] reference-columns=['col19' 'col20' ~] referential-integrity=~[%delete-cascade %update-cascade]]] drop-foreign-keys=~ as-of=[~ [%da ~2023.12.25..7.15.0..1ef5]]]
  =/  urql  "alter table table add foreign key fk  ( col1 , col2  desc )  references  fk-table  ( col19 ,  col20 )  on  delete  cascade  on  update  cascade, fk2  ( col1 ,  col2  desc )  references  fk-table2  ( col19 ,  col20 )  on  delete  cascade  on  update  cascade as of ~2023.12.25..7.15.0..1ef5"
  %+  expect-eq
    !>  ~[expected]
    !>  (parse:parse(default-database 'db1') urql)
::
:: add 2 foreign keys as of 5 days ago
++  test-alter-table-20
  =/  expected  [%alter-table table=[%qualified-object ship=~ database='db1' namespace='dbo' name='table'] alter-columns=~ add-columns=~ drop-columns=~ add-foreign-keys=~[[%foreign-key name='fk' table=[%qualified-object ship=~ database='db1' namespace='dbo' name='table'] columns=~[[%ordered-column name='col1' is-ascending=%.y] [%ordered-column name='col2' is-ascending=%.n]] reference-table=[%qualified-object ship=~ database='db1' namespace='dbo' name='fk-table'] reference-columns=['col19' 'col20' ~] referential-integrity=~[%delete-cascade %update-cascade]] [%foreign-key name='fk2' table=[%qualified-object ship=~ database='db1' namespace='dbo' name='table'] columns=~[[%ordered-column name='col1' is-ascending=%.y] [%ordered-column name='col2' is-ascending=%.n]] reference-table=[%qualified-object ship=~ database='db1' namespace='dbo' name='fk-table2'] reference-columns=['col19' 'col20' ~] referential-integrity=~[%delete-cascade %update-cascade]]] drop-foreign-keys=~ as-of=[~ %as-of-offset 5 %days]]
  =/  urql  "alter table table add foreign key fk  ( col1 , col2  desc )  references  fk-table  ( col19 ,  col20 )  on  delete  cascade  on  update  cascade, fk2  ( col1 ,  col2  desc )  references  fk-table2  ( col19 ,  col20 )  on  delete  cascade  on  update  cascade as of 5 days ago"
  %+  expect-eq
    !>  ~[expected]
    !>  (parse:parse(default-database 'db1') urql)
::
:: drop 2 foreign keys as of now
++  test-alter-table-21
  =/  expected  [%alter-table table=[%qualified-object ship=~ database='db1' namespace='dbo' name='mytable'] alter-columns=~ add-columns=~ drop-columns=~ add-foreign-keys=~ drop-foreign-keys=['fk1' 'fk2' ~] as-of=~]
  %+  expect-eq
    !>  ~[expected]
    !>  (parse:parse(default-database 'db1') "alter  table  mytable  drop  foreign  key  ( fk1,  fk2 ) as of now")
::
:: drop 2 foreign keys as of ~2023.12.25..7.15.0..1ef5
++  test-alter-table-22
  =/  expected  [%alter-table table=[%qualified-object ship=~ database='db1' namespace='dbo' name='mytable'] alter-columns=~ add-columns=~ drop-columns=~ add-foreign-keys=~ drop-foreign-keys=['fk1' 'fk2' ~] as-of=[~ [%da ~2023.12.25..7.15.0..1ef5]]]
  %+  expect-eq
    !>  ~[expected]
    !>  (parse:parse(default-database 'db1') "alter  table  mytable  drop  foreign  key  ( fk1,  fk2 ) as of ~2023.12.25..7.15.0..1ef5")
::
:: drop 2 foreign keys as of 5 days ago
++  test-alter-table-23
  =/  expected  [%alter-table table=[%qualified-object ship=~ database='db1' namespace='dbo' name='mytable'] alter-columns=~ add-columns=~ drop-columns=~ add-foreign-keys=~ drop-foreign-keys=['fk1' 'fk2' ~] as-of=[~ %as-of-offset 5 %days]]
  %+  expect-eq
    !>  ~[expected]
    !>  (parse:parse(default-database 'db1') "alter  table  mytable  drop  foreign  key  ( fk1,  fk2 ) as of 5 days ago")
::
:: fail when table name not a term
++  test-fail-alter-table-24
%-  expect-fail
  |.  (parse:parse(default-database 'db1') "ALTER TABLE ns.myTable DROP FOREIGN KEY (fk1)")
::
:: create database
::
:: tests 1, 3, and extra whitespace characters
++  test-create-database-00
  %+  expect-eq
    !>  ~[[%create-database name='my-database' as-of=~]]
    !>  (parse:parse(default-database 'dummy') "cReate datAbase \0a  my-database ")
::
:: as of now
++  test-create-database-01
  %+  expect-eq
    !>  ~[[%create-database name='my-db' as-of=~]]
    !>  (parse:parse(default-database 'dummy') "create database my-db As   Of now")
::
:: as of date-time
++  test-create-database-02
  %+  expect-eq
    !>  ~[[%create-database name='my-db' as-of=[~ [%da ~2023.12.25..7.15.0..1ef5]]]]
    !>  (parse:parse(default-database 'dummy') "create database my-db AS OF ~2023.12.25..7.15.0..1ef5")
::
:: as of seconds ago
++  test-create-database-03
  %+  expect-eq
    !>  ~[[%create-database name='my-db' as-of=[~ [%as-of-offset 5 %seconds]]]]
    !>  (parse:parse(default-database 'dummy') "create database my-db as   of 5 seconds ago")
::
:: as of minutes ago
++  test-create-database-04
  %+  expect-eq
    !>  ~[[%create-database name='my-db' as-of=[~ [%as-of-offset 15 %minutes]]]]
    !>  (parse:parse(default-database 'dummy') "create database my-db as of 15 minutes ago")
::
:: as of hours ago
++  test-create-database-05
  %+  expect-eq
    !>  ~[[%create-database name='my-db' as-of=[~ [%as-of-offset 9 %hours]]]]
    !>  (parse:parse(default-database 'dummy') "create database my-db as of 9 hours ago")
::
:: as of days ago
++  test-create-database-06
  %+  expect-eq
    !>  ~[[%create-database name='my-db' as-of=[~ [%as-of-offset 3 %days]]]]
    !>  (parse:parse(default-database 'dummy') "create database my-db as of 3 days ago")
::
:: as of weeks ago
++  test-create-database-07
  %+  expect-eq
    !>  ~[[%create-database name='my-db' as-of=[~ [%as-of-offset 2 %weeks]]]]
    !>  (parse:parse(default-database 'dummy') "create database my-db as of 2 weeks ago")
::
:: as of months ago
++  test-create-database-08
  %+  expect-eq
    !>  ~[[%create-database name='my-db' as-of=[~ [%as-of-offset 7 %months]]]]
    !>  (parse:parse(default-database 'dummy') "create database my-db as of 7 months ago")
::
:: as of years ago
++  test-create-database-09
  %+  expect-eq
    !>  ~[[%create-database name='my-db' as-of=[~ [%as-of-offset 4 %years]]]]
    !>  (parse:parse(default-database 'dummy') "create database my-db as of 4 years ago")
::
:: subsequent commands ignored
++  test-create-database-10
  %+  expect-eq
    !>  ~[[%create-database name='my-database' as-of=~]]
    !>  (parse:parse(default-database 'dummy') "cReate datAbase \0a  my-database; cReate namesPace my-db.another-namespace")
::
:: fail when database name is not a term
++  test-fail-create-database-11
  %-  expect-fail
  |.  (parse:parse(default-database 'dummy') "cReate datAbase  My-database")
::
:: fail when commands are prior to create database
++  test-fail-create-database-12
  %-  expect-fail
  |.  (parse:parse(default-database 'dummy') "create namespace my-namespace ; cReate datAbase my-database")
::
:: create index
::
:: tests 1, 2, 3, 5, and extra whitespace characters, create index... db.ns.table, create unique index... db..table
++  test-create-index-1
  =/  expected1  [%create-index name='my-index' object-name=[%qualified-object ship=~ database='db' namespace='ns' name='table'] is-unique=%.n is-clustered=%.n columns=~[[%ordered-column name='col1' is-ascending=%.y] [%ordered-column name='col2' is-ascending=%.n] [%ordered-column name='col3' is-ascending=%.y]]]
  =/  expected2  [%create-index name='my-index' object-name=[%qualified-object ship=~ database='db' namespace='dbo' name='table'] is-unique=%.y is-clustered=%.n columns=~[[%ordered-column name='col1' is-ascending=%.y] [%ordered-column name='col2' is-ascending=%.n] [%ordered-column name='col3' is-ascending=%.y]]]
  %+  expect-eq
    !>  ~[expected1 expected2]
    !>  (parse:parse(default-database 'db1') "CREATe \0d INdEX\09my-index On db.ns.table  ( col1 , col2\0a desc  , col3) \0a;\0a CREATE unIque INDEX my-index ON db..table (col1 , col2 desc, col3 )  ")
::
:: leading whitespace characters, end delimiter, create clustered index... ns.table
++  test-create-index-2
  =/  expected  [%create-index name='my-index' object-name=[%qualified-object ship=~ database='db1' namespace='ns' name='table'] is-unique=%.n is-clustered=%.y columns=~[[%ordered-column name='col1' is-ascending=%.y] [%ordered-column name='col2' is-ascending=%.n] [%ordered-column name='col3' is-ascending=%.y]]]
  %+  expect-eq
    !>  ~[expected]
    !>  (parse:parse(default-database 'db1') "  \0d CREATE clusTered INDEX my-index ON ns.table (col1, col2 desc, col3);")
::
:: create look-up index... table (col1 desc, col2 asc, col3)
++  test-create-index-3
  =/  expected  [%create-index name='my-index' object-name=[%qualified-object ship=~ database='db1' namespace='dbo' name='table'] is-unique=%.n is-clustered=%.n columns=~[[%ordered-column name='col1' is-ascending=%.n] [%ordered-column name='col2' is-ascending=%.y] [%ordered-column name='col3' is-ascending=%.y]]]
  %+  expect-eq
    !>  ~[expected]
    !>  (parse:parse(default-database 'db1') "CREATE look-up INDEX my-index ON table (col1 desc, col2 asc, col3)")
::
:: create unique clustered index... table (col1 desc)
++  test-create-index-4
  =/  expected  [%create-index name='my-index' object-name=[%qualified-object ship=~ database='db1' namespace='dbo' name='table'] is-unique=%.y is-clustered=%.y columns=~[[%ordered-column name='col1' is-ascending=%.n]]]
  %+  expect-eq
    !>  ~[expected]
    !>  (parse:parse(default-database 'db1') "CREATE uniQue clusTered INDEX my-index ON table (col1 desc)")
::
:: create unique look-up index... table (col1)
++  test-create-index-5
  =/  expected  [%create-index name='my-index' object-name=[%qualified-object ship=~ database='db1' namespace='dbo' name='table'] is-unique=%.y is-clustered=%.n columns=~[[%ordered-column name='col1' is-ascending=%.y]]]
  %+  expect-eq
    !>  ~[expected]
    !>  (parse:parse(default-database 'db1') "CREATE uniQue look-up INDEX my-index ON table (col1)")
::
:: fail when database qualifier is not a term
++  test-fail-create-index-6
  %-  expect-fail
  |.  (parse:parse(default-database 'db2') "create index my-index ON Db.ns.table (col1)")
::
:: fail when namespace qualifier is not a term
++  test-fail-create-index-7
  %-  expect-fail
  |.  (parse:parse(default-database 'db2') "create index my-index ON db.Ns.table (col1)")
::
:: fail when table name is not a term
++  test-fail-create-index-8
  %-  expect-fail
  |.  (parse:parse(default-database 'other-db') "create index my-index ON db.ns.Table (col1)")
::
:: create namespace
::
:: tests 1, 2, 3, 5, and extra whitespace characters
++  test-create-namespace-00
  =/  expected1  [%create-namespace database-name='db1' name='ns1' as-of=~]
  =/  expected2  [%create-namespace database-name='my-db' name='another-namespace' as-of=~]
  %+  expect-eq
    !>  ~[expected1 expected2]
    !>  (parse:parse(default-database 'db1') "cReate\0d\09  namespace ns1 ; cReate namesPace my-db.another-namespace")
::
:: leading and trailing whitespace characters, end delimiter not required on single
++  test-create-namespace-01
  %+  expect-eq
    !>  ~[[%create-namespace database-name='db1' name='ns1' as-of=~]]
    !>  (parse:parse(default-database 'db1') "   \09cReate\0d\09  namespace ns1 ")
::
:: as of now simple name
++  test-create-namespace-02
  %+  expect-eq
    !>  ~[[%create-namespace database-name='db1' name='ns1' as-of=~]]
    !>  (parse:parse(default-database 'db1') "create namespace ns1 aS oF now")
::
:: as of now qualified name
++  test-create-namespace-03
  %+  expect-eq
    !>  ~[[%create-namespace database-name='db2' name='ns1' as-of=~]]
    !>  (parse:parse(default-database 'db1') "create namespace db2.ns1 as   of now")
::
:: as of date-time simple name
++  test-create-namespace-04
  %+  expect-eq
    !>  ~[[%create-namespace database-name='db1' name='ns1' as-of=[~ [%da ~2023.12.25..7.15.0..1ef5]]]]
    !>  (parse:parse(default-database 'db1') "create namespace ns1 AS of ~2023.12.25..7.15.0..1ef5")
::
:: as of date-time qualified name
++  test-create-namespace-05
  %+  expect-eq
    !>  ~[[%create-namespace database-name='db2' name='ns1' as-of=[~ [%da ~2023.12.25..7.15.0..1ef5]]]]
    !>  (parse:parse(default-database 'db1') "create namespace db2.ns1 as   OF ~2023.12.25..7.15.0..1ef5")
::
:: as of seconds ago simple name
++  test-create-namespace-06
  %+  expect-eq
    !>  ~[[%create-namespace database-name='db1' name='ns1' as-of=[~ [%as-of-offset 5 %seconds]]]]
    !>  (parse:parse(default-database 'db1') "create namespace ns1 as of 5 seconds ago")
::
:: as of seconds ago qualified name
++  test-create-namespace-07
  %+  expect-eq
    !>  ~[[%create-namespace database-name='db2' name='ns1' as-of=[~ [%as-of-offset 5 %seconds]]]]
    !>  (parse:parse(default-database 'db1') "create namespace db2.ns1 as of 5 seconds ago")
::
:: as of minutes ago simple name
++  test-create-namespace-08
  %+  expect-eq
    !>  ~[[%create-namespace database-name='db1' name='ns1' as-of=[~ [%as-of-offset 15 %minutes]]]]
    !>  (parse:parse(default-database 'db1') "create namespace ns1 as of 15 minutes ago")
::
:: as of minutes ago qualified name
++  test-create-namespace-09
  %+  expect-eq
    !>  ~[[%create-namespace database-name='db2' name='ns1' as-of=[~ [%as-of-offset 15 %minutes]]]]
    !>  (parse:parse(default-database 'db1') "create namespace db2.ns1 as of 15 minutes ago")
::
:: as of hours ago simple name
++  test-create-namespace-10
  %+  expect-eq
    !>  ~[[%create-namespace database-name='db1' name='ns1' as-of=[~ [%as-of-offset 9 %hours]]]]
    !>  (parse:parse(default-database 'db1') "create namespace ns1 as of 9 hours ago")
::
:: as of hours ago qualified name
++  test-create-namespace-11
  %+  expect-eq
    !>  ~[[%create-namespace database-name='db2' name='ns1' as-of=[~ [%as-of-offset 9 %hours]]]]
    !>  (parse:parse(default-database 'db1') "create namespace db2.ns1 as of 9 hours ago")
::
:: as of days ago simple name
++  test-create-namespace-12
  %+  expect-eq
    !>  ~[[%create-namespace database-name='db1' name='ns1' as-of=[~ [%as-of-offset 3 %days]]]]
    !>  (parse:parse(default-database 'db1') "create namespace ns1  as of3 days ago")
::
:: as of days ago qualified name
++  test-create-namespace-13
  %+  expect-eq
    !>  ~[[%create-namespace database-name='db2' name='ns1' as-of=[~ [%as-of-offset 3 %days]]]]
    !>  (parse:parse(default-database 'db1') "create namespace db2.ns1  as of3 days ago")
::
:: as of weeks ago simple name
++  test-create-namespace-14
  %+  expect-eq
    !>  ~[[%create-namespace database-name='db1' name='ns1' as-of=[~ [%as-of-offset 2 %weeks]]]]
    !>  (parse:parse(default-database 'db1') "create namespace ns1 as of 2 weeks ago")
::
:: as of weeks ago qualified name
++  test-create-namespace-15
  %+  expect-eq
    !>  ~[[%create-namespace database-name='db2' name='ns1' as-of=[~ [%as-of-offset 2 %weeks]]]]
    !>  (parse:parse(default-database 'db1') "create namespace db2.ns1 as of 2 weeks ago")
::
:: as of months ago simple name
++  test-create-namespace-16
  %+  expect-eq
    !>  ~[[%create-namespace database-name='db1' name='ns1' as-of=[~ [%as-of-offset 7 %months]]]]
    !>  (parse:parse(default-database 'db1') "create namespace ns1 as of 7 months ago")
::
:: as of months ago qualified name
++  test-create-namespace-17
  %+  expect-eq
    !>  ~[[%create-namespace database-name='db2' name='ns1' as-of=[~ [%as-of-offset 7 %months]]]]
    !>  (parse:parse(default-database 'db1') "create namespace db2.ns1 as of 7 months ago")
::
:: as of years ago simple name
++  test-create-namespace-18
  %+  expect-eq
    !>  ~[[%create-namespace database-name='db1' name='ns1' as-of=[~ [%as-of-offset 4 %years]]]]
    !>  (parse:parse(default-database 'db1') "create namespace ns1 as of 4 years ago")
::
:: as of years ago qualified name
++  test-create-namespace-19
  %+  expect-eq
    !>  ~[[%create-namespace database-name='db2' name='ns1' as-of=[~ [%as-of-offset 4 %years]]]]
    !>  (parse:parse(default-database 'db1') "create namespace db2.ns1 as of 4 years ago")
::
:: fail when database qualifier is not a term
++  test-fail-create-namespace-20
  %-  expect-fail
  |.  (parse:parse(default-database 'db1') "cReate namesPace Bad-face.another-namespace")
::
:: fail when namespace is not a term
++  test-fail-create-namespace-21
  %-  expect-fail
  |.  (parse:parse(default-database 'db1') "cReate namesPace my-db.Bad-face")
::
:: create table
::
:: tests 1, 2, 3, 5, and extra whitespace characters, db.ns.table clustered on delete cascade on update cascade; db..table look-up on update cascade on delete cascade
++  test-create-table-00
  =/  expected1  [%create-table table=[%qualified-object ship=~ database='db' namespace='ns' name='my-table'] columns=~[[%column name='col1' column-type=%t] [%column name='col2' column-type=%p] [%column name='col3' column-type=%ud]] clustered=%.y pri-indx=~[[%ordered-column name='col1' is-ascending=%.y] [%ordered-column name='col2' is-ascending=%.y]] foreign-keys=~[[%foreign-key name='fk' table=[%qualified-object ship=~ database='db' namespace='ns' name='my-table'] columns=~[[%ordered-column name='col1' is-ascending=%.y] [%ordered-column name='col2' is-ascending=%.n]] reference-table=[%qualified-object ship=~ database='db' namespace='dbo' name='fk-table'] reference-columns=~['col19' 'col20'] referential-integrity=~[%delete-cascade %update-cascade]]] as-of=~]
  =/  expected2  [%create-table table=[%qualified-object ship=~ database='db' namespace='dbo' name='my-table'] columns=~[[%column name='col1' column-type=%t] [%column name='col2' column-type=%p] [%column name='col3' column-type=%ud]] clustered=%.n pri-indx=~[[%ordered-column name='col1' is-ascending=%.y] [%ordered-column name='col2' is-ascending=%.y]] foreign-keys=~[[%foreign-key name='fk' table=[%qualified-object ship=~ database='db' namespace='dbo' name='my-table'] columns=~[[%ordered-column name='col1' is-ascending=%.y] [%ordered-column name='col2' is-ascending=%.n]] reference-table=[%qualified-object ship=~ database='db' namespace='dbo' name='fk-table'] reference-columns=~['col19' 'col20'] referential-integrity=~[%delete-cascade %update-cascade]]] as-of=~]
  =/  urql1  "crEate  taBle  db.ns.my-table  ( col1  @t ,  col2  @p ,  col3  @ud )  pRimary  kEy  clusTered  ( col1 ,  col2 )  foReign  KeY  fk  ( col1 ,  col2  desc )  reFerences  fk-table  ( col19 ,  col20 )  On  dELETE  CAsCADE  oN  UPdATE  CAScADE "
  =/  urql2  "crEate  taBle  db..my-table  ( col1  @t ,  col2  @p ,  col3  @ud )  pRimary  kEy  look-up  ( col1 ,  col2 )  foReign  KeY  fk  ( col1 ,  col2  desc )  reFerences  fk-table  ( col19 ,  col20 )  On  UPdATE  CAsCADE  oN  dELETE  CAScADE "
  %+  expect-eq
    !>  ~[expected1 expected2]
    !>  (parse:parse(default-database 'db1') (weld urql1 (weld "\0a;\0a" urql2)))
::
:: leading whitespace characters, whitespace after end delimiter, create look-up table... table ... references  ns.fk-table  on update no action on delete no action
++  test-create-table-01
  =/  expected  [%create-table table=[%qualified-object ship=~ database='db1' namespace='dbo' name='my-table'] columns=~[[%column name='col1' column-type=%t] [%column name='col2' column-type=%p] [%column name='col3' column-type=%ud]] clustered=%.n pri-indx=~[[%ordered-column name='col1' is-ascending=%.y] [%ordered-column name='col2' is-ascending=%.y]] foreign-keys=~[[%foreign-key name='fk' table=[%qualified-object ship=~ database='db1' namespace='dbo' name='my-table'] columns=~[[%ordered-column name='col1' is-ascending=%.y] [%ordered-column name='col2' is-ascending=%.n]] reference-table=[%qualified-object ship=~ database='db1' namespace='ns' name='fk-table'] reference-columns=~['col19' 'col20'] referential-integrity=~]] as-of=~]
  =/  urql  "  \0acreate table my-table (col1 @t,col2 @p,col3 @ud) primary key look-up (col1, col2) foreign key fk (col1,col2 desc) reFerences ns.fk-table (col19, col20) on update no action on delete no action; "
  %+  expect-eq
    !>  ~[expected]
    !>  (parse:parse(default-database 'db1') urql)
::
:: create table... table ... references  ns.fk-table  on update no action on delete cascade
++  test-create-table-02
  =/  expected  [%create-table table=[%qualified-object ship=~ database='db1' namespace='dbo' name='my-table'] columns=~[[%column name='col1' column-type=%t] [%column name='col2' column-type=%p] [%column name='col3' column-type=%ud]] clustered=%.y pri-indx=~[[%ordered-column name='col1' is-ascending=%.y] [%ordered-column name='col2' is-ascending=%.y]] foreign-keys=~[[%foreign-key name='fk' table=[%qualified-object ship=~ database='db1' namespace='dbo' name='my-table'] columns=~[[%ordered-column name='col1' is-ascending=%.y] [%ordered-column name='col2' is-ascending=%.n]] reference-table=[%qualified-object ship=~ database='db1' namespace='ns' name='fk-table'] reference-columns=~['col19' 'col20'] referential-integrity=~[%delete-cascade]]] as-of=~]
  =/  urql  "create table my-table (col1 @t,col2 @p,col3 @ud) primary key (col1, col2) foreign key fk (col1,col2 desc) reFerences ns.fk-table (col19, col20) on update no action on delete cascade"
  %+  expect-eq
    !>  ~[expected]
    !>  (parse:parse(default-database 'db1') urql)
::
:: create table... table ... references fk-table on update cascade on delete no action
++  test-create-table-03
  =/  expected  [%create-table table=[%qualified-object ship=~ database='db1' namespace='dbo' name='my-table'] columns=~[[%column name='col1' column-type=%t] [%column name='col2' column-type=%p] [%column name='col3' column-type=%ud]] clustered=%.y pri-indx=~[[%ordered-column name='col1' is-ascending=%.y] [%ordered-column name='col2' is-ascending=%.y]] foreign-keys=~[[%foreign-key name='fk' table=[%qualified-object ship=~ database='db1' namespace='dbo' name='my-table'] columns=~[[%ordered-column name='col1' is-ascending=%.y] [%ordered-column name='col2' is-ascending=%.n]] reference-table=[%qualified-object ship=~ database='db1' namespace='dbo' name='fk-table'] reference-columns=~['col19' 'col20'] referential-integrity=~[%update-cascade]]] as-of=~]
  =/  urql  "create table my-table (col1 @t,col2 @p,col3 @ud) primary key (col1, col2) foreign key fk (col1,col2 desc) reFerences fk-table (col19, col20) on update cascade on delete no action"
  %+  expect-eq
    !>  ~[expected]
    !>  (parse:parse(default-database 'db1') urql)
::
:: create table... table ... single column indices... references fk-table on update cascade
++  test-create-table-04
  =/  expected  [%create-table table=[%qualified-object ship=~ database='db1' namespace='dbo' name='my-table'] columns=~[[%column name='col1' column-type=%t] [%column name='col2' column-type=%p] [%column name='col3' column-type=%ud]] clustered=%.y pri-indx=~[[%ordered-column name='col1' is-ascending=%.y]] foreign-keys=~[[%foreign-key name='fk' table=[%qualified-object ship=~ database='db1' namespace='dbo' name='my-table'] columns=~[[%ordered-column name='col2' is-ascending=%.n]] reference-table=[%qualified-object ship=~ database='db1' namespace='dbo' name='fk-table'] reference-columns=~['col20'] referential-integrity=~[%update-cascade]]] as-of=~]
  =/  urql  "create table my-table (col1 @t,col2 @p,col3 @ud) primary key (col1) foreign key fk (col2 desc) reFerences fk-table (col20) on update cascade"
  %+  expect-eq
    !>  ~[expected]
    !>  (parse:parse(default-database 'db1') urql)
::
:: create table... table ... single column indices... references fk-table
++  test-create-table-05
  =/  expected  [%create-table table=[%qualified-object ship=~ database='db1' namespace='dbo' name='my-table'] columns=~[[%column name='col1' column-type=%t] [%column name='col2' column-type=%p] [%column name='col3' column-type=%ud]] clustered=%.y pri-indx=~[[%ordered-column name='col1' is-ascending=%.y]] foreign-keys=~[[%foreign-key name='fk' table=[%qualified-object ship=~ database='db1' namespace='dbo' name='my-table'] columns=~[[%ordered-column name='col2' is-ascending=%.n]] reference-table=[%qualified-object ship=~ database='db1' namespace='dbo' name='fk-table'] reference-columns=~['col20'] referential-integrity=~]] as-of=~]
  =/  urql  "create table my-table (col1 @t,col2 @p,col3 @ud) primary key (col1) foreign key fk (col2 desc) reFerences fk-table (col20) "
  %+  expect-eq
    !>  ~[expected]
    !>  (parse:parse(default-database 'db1') urql)
::
:: create table...  no foreign key
++  test-create-table-06
  =/  expected  [%create-table table=[%qualified-object ship=~ database='db1' namespace='dbo' name='my-table'] columns=~[[%column name='col1' column-type=%t] [%column name='col2' column-type=%p] [%column name='col3' column-type=%ud]] clustered=%.y pri-indx=~[[%ordered-column name='col1' is-ascending=%.y] [%ordered-column name='col2' is-ascending=%.y]] foreign-keys=~ as-of=~]
  =/  urql  "create table my-table (col1 @t,col2 @p,col3 @ud) primary key (col1,col2)"
  %+  expect-eq
    !>  ~[expected]
    !>  (parse:parse(default-database 'db1') urql)
::
:: create table...  2 foreign keys
++  test-create-table-07
  =/  expected  [%create-table table=[%qualified-object ship=~ database='db1' namespace='dbo' name='my-table'] columns=~[[%column name='col1' column-type=%t] [%column name='col2' column-type=%p] [%column name='col3' column-type=%ud]] clustered=%.y pri-indx=~[[%ordered-column name='col1' is-ascending=%.y]] foreign-keys=~[[%foreign-key name='fk' table=[%qualified-object ship=~ database='db1' namespace='dbo' name='my-table'] columns=~[[%ordered-column name='col2' is-ascending=%.n]] reference-table=[%qualified-object ship=~ database='db1' namespace='dbo' name='fk-table'] reference-columns=['col20' ~] referential-integrity=~] [%foreign-key name='fk2' table=[%qualified-object ship=~ database='db1' namespace='dbo' name='my-table'] columns=~[[%ordered-column name='col1' is-ascending=%.y] [%ordered-column name='col2' is-ascending=%.n]] reference-table=[%qualified-object ship=~ database='db1' namespace='dbo' name='fk-table2'] reference-columns=['col19' 'col20' ~] referential-integrity=~]] as-of=~]
  =/  urql  "create table my-table (col1 @t,col2 @p,col3 @ud) primary key (col1) foreign key fk (col2 desc) reFerences fk-table (col20), fk2 (col1, col2 desc) reFerences fk-table2 (col19, col20)"
  %+  expect-eq
    !>  ~[expected]
    !>  (parse:parse(default-database 'db1') urql)
::
:: fail when database qualifier on foreign key table db.ns.fk-table
::
:: create table as of simple name as of now
++  test-create-table-08
  =/  expected  [%create-table table=[%qualified-object ship=~ database='db1' namespace='dbo' name='my-table'] columns=~[[%column name='col1' column-type=%t] [%column name='col2' column-type=%p] [%column name='col3' column-type=%ud]] clustered=%.y pri-indx=~[[%ordered-column name='col1' is-ascending=%.y] [%ordered-column name='col2' is-ascending=%.y]] foreign-keys=~ as-of=~]
  =/  urql  "create table my-table (col1 @t,col2 @p,col3 @ud) primary key (col1,col2) AS of now"
  %+  expect-eq
    !>  ~[expected]
    !>  (parse:parse(default-database 'db1') urql)
::
:: create table as of ns-qualified name as of datetime
++  test-create-table-09
  =/  expected  [%create-table table=[%qualified-object ship=~ database='db1' namespace='ns1' name='my-table'] columns=~[[%column name='col1' column-type=%t] [%column name='col2' column-type=%p] [%column name='col3' column-type=%ud]] clustered=%.y pri-indx=~[[%ordered-column name='col1' is-ascending=%.y] [%ordered-column name='col2' is-ascending=%.y]] foreign-keys=~ as-of=[~ [%da ~2023.12.25..7.15.0..1ef5]]]
  =/  urql  "create table ns1.my-table (col1 @t,col2 @p,col3 @ud) primary key (col1,col2) as     OF ~2023.12.25..7.15.0..1ef5"
  %+  expect-eq
    !>  ~[expected]
    !>  (parse:parse(default-database 'db1') urql)
::
:: create table as of db-qualified name
++  test-create-table-10
  =/  expected  [%create-table table=[%qualified-object ship=~ database='db2' namespace='dbo' name='my-table'] columns=~[[%column name='col1' column-type=%t] [%column name='col2' column-type=%p] [%column name='col3' column-type=%ud]] clustered=%.y pri-indx=~[[%ordered-column name='col1' is-ascending=%.y] [%ordered-column name='col2' is-ascending=%.y]] foreign-keys=~ as-of=[~ [%as-of-offset 5 %seconds]]]
  =/  urql  "create table db2..my-table (col1 @t,col2 @p,col3 @ud) primary key (col1,col2) aS Of 5 seconds ago"
  %+  expect-eq
    !>  ~[expected]
    !>  (parse:parse(default-database 'db1') urql)
::
:: create table as of db-ns-qualified name
++  test-create-table-11
  =/  expected  [%create-table table=[%qualified-object ship=~ database='db2' namespace='ns1' name='my-table'] columns=~[[%column name='col1' column-type=%t] [%column name='col2' column-type=%p] [%column name='col3' column-type=%ud]] clustered=%.y pri-indx=~[[%ordered-column name='col1' is-ascending=%.y] [%ordered-column name='col2' is-ascending=%.y]] foreign-keys=~ as-of=[~ [%as-of-offset 15 %minutes]]]
  =/  urql  "create table db2.ns1.my-table (col1 @t,col2 @p,col3 @ud) primary key (col1,col2) as of 15 minutes ago"
  %+  expect-eq
    !>  ~[expected]
    !>  (parse:parse(default-database 'db1') urql)
++  test-fail-create-table-12
  =/  urql  "create table my-table (col1 @t,col2 @p,col3 @ud) primary key (col1) foreign key fk (col2 desc) reFerences db.ns.fk-table (col20) "
  %-  expect-fail
  |.  (parse:parse(default-database 'other-db') urql)
::
:: fail when database qualifier on foreign key table db..fk-table
++  test-fail-create-table-13
  =/  urql  "create table my-table (col1 @t,col2 @p,col3 @ud) primary key (col1) foreign key fk (col2 desc) reFerences db..fk-table (col20) "
  %-  expect-fail
  |.  (parse:parse(default-database 'other-db') urql)
::
:: delete
::
++  col1
  [%qualified-column qualifier=[%qualified-object ship=~ database='UNKNOWN' namespace='COLUMN-OR-CTE' name='col1'] column='col1' alias=~]
++  col2
  [%qualified-column qualifier=[%qualified-object ship=~ database='UNKNOWN' namespace='COLUMN-OR-CTE' name='col2'] column='col2' alias=~]
++  col3
  [%qualified-column qualifier=[%qualified-object ship=~ database='UNKNOWN' namespace='COLUMN-OR-CTE' name='col3'] column='col3' alias=~]
++  col4
  [%qualified-column qualifier=[%qualified-object ship=~ database='UNKNOWN' namespace='COLUMN-OR-CTE' name='col4'] column='col4' alias=~]
++  delete-pred
  `[%eq [column-foo ~ ~] [column-bar ~ ~]]
++  cte-t1
  [%cte name='t1' [%query ~ scalars=~ predicate=~ group-by=~ having=~ selection=select-all-columns ~]]
++  cte-foobar
  [%cte name='foobar' [%query [~ [%from object=[%table-set object=[%qualified-object ship=~ database='db1' namespace='dbo' name='foobar'] alias=~] joins=~]] scalars=~ `[%eq [col1 ~ ~] [[value-type=%ud value=2] ~ ~]] group-by=~ having=~ [%select top=~ bottom=~ columns=~[col3 col4]] ~]]
++  cte-bar
  [%cte name='bar' [%query [~ [%from object=[%table-set object=[%qualified-object ship=~ database='db1' namespace='dbo' name='bar'] alias=~] joins=~]] scalars=~ `[%eq [col1 ~ ~] [col2 ~ ~]] group-by=~ having=~ [%select top=~ bottom=~ columns=~[col2]] ~]]
++  foo-table
  [%qualified-object ship=~ database='db1' namespace='dbo' name='foo']
::
:: delete from foo;delete  foo
++  test-delete-00
  =/  expected1  [%transform ctes=~ [[%delete table=foo-table ~ ~] ~ ~]]
  =/  expected2  [%transform ctes=~ [[%delete table=foo-table ~ ~] ~ ~]]
  %+  expect-eq
    !>  ~[expected1 expected2]
    !>  (parse:parse(default-database 'db1') "delete from foo;delete  foo")
::
:: delete from foo as of now;delete foo as of now
++  test-delete-01
  =/  expected1  [%transform ctes=~ [[%delete table=foo-table ~ ~] ~ ~]]
  =/  expected2  [%transform ctes=~ [[%delete table=foo-table ~ ~] ~ ~]]
  %+  expect-eq
    !>  ~[expected1 expected2]
    !>  (parse:parse(default-database 'db1') "delete from foo as of now;delete  foo AS OF now")
::
:: delete from foo as of ~2023.12.25..7.15.0..1ef5;delete foo as of ~2023.12.25..7.15.0..1ef5
++  test-delete-02
  =/  expected1  [%transform ctes=~ [[%delete table=foo-table ~ [~ [%da ~2023.12.25..7.15.0..1ef5]]] ~ ~]]
  =/  expected2  [%transform ctes=~ [[%delete table=foo-table ~ [~ [%da ~2023.12.25..7.15.0..1ef5]]] ~ ~]]
  %+  expect-eq
    !>  ~[expected1 expected2]
    !>  (parse:parse(default-database 'db1') "delete from foo as of 2023.12.25..7.15.0..1ef5;delete  foo as of ~2023.12.25..7.15.0..1ef5")
::
:: delete from foo as of 5 seconds ago;delete foo as of 5 seconds ago
++  test-delete-03
  =/  expected1  [%transform ctes=~ [[%delete table=foo-table ~ [~ [%as-of-offset 5 %seconds]]] ~ ~]]
  =/  expected2  [%transform ctes=~ [[%delete table=foo-table ~ [~ [%as-of-offset 4 %seconds]]] ~ ~]]
  %+  expect-eq
    !>  ~[expected1 expected2]
    !>  (parse:parse(default-database 'db1') "delete from foo as of 5 seconds ago;delete  foo as of 4 seconds ago")
::
:: delete with predicate as
++  test-delete-04
  =/  expected  [%transform ctes=~ [[%delete table=foo-table delete-pred ~] ~ ~]]
  %+  expect-eq
    !>  ~[expected]
    !>  (parse:parse(default-database 'db1') "delete from foo  where foo=bar")
::
:: delete with predicate of now
++  test-delete-05
  =/  expected  [%transform ctes=~ [[%delete table=foo-table delete-pred ~] ~ ~]]
  %+  expect-eq
    !>  ~[expected]
    !>  (parse:parse(default-database 'db1') "delete from foo where foo=bar as of now")
::
:: delete with predicate of ~2023.12.25..7.15.0..1ef5
++  test-delete-06
  =/  expected  [%transform ctes=~ [[%delete table=foo-table delete-pred [~ [%da ~2023.12.25..7.15.0..1ef5]]] ~ ~]]
  %+  expect-eq
    !>  ~[expected]
    !>  (parse:parse(default-database 'db1') "delete from foo where foo=bar as of ~2023.12.25..7.15.0..1ef5")
::
:: delete with predicate of 5 seconds ago
++  test-delete-07
  =/  expected  [%transform ctes=~ [[%delete table=foo-table delete-pred [~ [%as-of-offset 5 %seconds]]] ~ ~]]
  %+  expect-eq
    !>  ~[expected]
    !>  (parse:parse(default-database 'db1') "delete from foo where foo=bar as of 5 seconds ago")
::
:: delete with one cte and predicate
++  test-delete-08
  =/  expected  [%transform ctes=~[cte-t1] [[%delete table=foo-table delete-pred ~] ~ ~]]
  %+  expect-eq
    !>  ~[expected]
    !>  (parse:parse(default-database 'db1') "with (select *) as t1 delete from foo where foo=bar")
::
:: delete with one cte and predicate as of now
++  test-delete-09
  =/  expected  [%transform ctes=~[cte-t1] [[%delete table=foo-table delete-pred ~] ~ ~]]
  %+  expect-eq
    !>  ~[expected]
    !>  (parse:parse(default-database 'db1') "with (select *) as t1 delete from foo where foo=bar as of now")
::
:: delete with one cte and predicate as of ~2023.12.25..7.15.0..1ef5
++  test-delete-10
  =/  expected  [%transform ctes=~[cte-t1] [[%delete table=foo-table delete-pred [~ [%da ~2023.12.25..7.15.0..1ef5]]] ~ ~]]
  %+  expect-eq
    !>  ~[expected]
    !>  (parse:parse(default-database 'db1') "with (select *) as t1 delete from foo where foo=bar as of ~2023.12.25..7.15.0..1ef5")
::
:: delete with one cte and predicate as of 5 seconds ago
++  test-delete-11
  =/  expected  [%transform ctes=~[cte-t1] [[%delete table=foo-table delete-pred [~ [%as-of-offset 5 %seconds]]] ~ ~]]
  %+  expect-eq
    !>  ~[expected]
    !>  (parse:parse(default-database 'db1') "with (select *) as t1 delete from foo where foo=bar as of 5 seconds ago")
::
:: delete with two ctes and predicate
++  test-delete-12
  =/  expected  [%transform ctes=~[cte-t1 cte-foobar] [[%delete table=foo-table delete-pred ~] ~ ~]]
  %+  expect-eq
    !>  ~[expected]
    !>  (parse:parse(default-database 'db1') "with (select *) as t1, (from foobar where col1=2 select col3, col4) as foobar delete from foo where foo=bar")
::
:: delete with two ctes and predicate as of now
++  test-delete-13
  =/  expected  [%transform ctes=~[cte-t1 cte-foobar] [[%delete table=foo-table delete-pred ~] ~ ~]]
  %+  expect-eq
    !>  ~[expected]
    !>  (parse:parse(default-database 'db1') "with (select *) as t1, (from foobar where col1=2 select col3, col4) as foobar delete from foo where foo=bar as of now")
::
:: delete with two ctes and predicate as of ~2023.12.25..7.15.0..1ef5
++  test-delete-14
  =/  expected  [%transform ctes=~[cte-t1 cte-foobar] [[%delete table=foo-table delete-pred [~ [%da ~2023.12.25..7.15.0..1ef5]]] ~ ~]]
  %+  expect-eq
    !>  ~[expected]
    !>  (parse:parse(default-database 'db1') "with (select *) as t1, (from foobar where col1=2 select col3, col4) as foobar delete from foo where foo=bar as of ~2023.12.25..7.15.0..1ef5")
::
:: delete with two ctes and predicate as of 5 seconds ago
++  test-delete-15
  =/  expected  [%transform ctes=~[cte-t1 cte-foobar] [[%delete table=foo-table delete-pred [~ [%as-of-offset 5 %seconds]]] ~ ~]]
  %+  expect-eq
    !>  ~[expected]
    !>  (parse:parse(default-database 'db1') "with (select *) as t1, (from foobar where col1=2 select col3, col4) as foobar delete from foo where foo=bar as of 5 seconds ago")
::
:: delete with three ctes and predicate
++  test-delete-16
  =/  expected  [%transform ctes=~[cte-t1 cte-foobar cte-bar] [%delete table=foo-table delete-pred ~] ~ ~]
  %+  expect-eq
    !>  ~[expected]
    !>  (parse:parse(default-database 'db1') "with (select *) as t1, (from foobar where col1=2 select col3, col4) as foobar, (from bar where col1=col2 select col2) as bar delete from foo where foo=bar")
::
:: delete with three ctes and predicate as of now
++  test-delete-17
  =/  expected  [%transform ctes=~[cte-t1 cte-foobar cte-bar] [%delete table=foo-table delete-pred ~] ~ ~]
  %+  expect-eq
    !>  ~[expected]
    !>  (parse:parse(default-database 'db1') "with (select *) as t1, (from foobar where col1=2 select col3, col4) as foobar, (from bar where col1=col2 select col2) as bar delete from foo where foo=bar aS  Of    NOw")
::
:: delete with three ctes and predicate as of ~2023.12.25..7.15.0..1ef5
++  test-delete-18
  =/  expected  [%transform ctes=~[cte-t1 cte-foobar cte-bar] [%delete table=foo-table delete-pred [~ [%da ~2023.12.25..7.15.0..1ef5]]] ~ ~]
  %+  expect-eq
    !>  ~[expected]
    !>  (parse:parse(default-database 'db1') "with (select *) as t1, (from foobar where col1=2 select col3, col4) as foobar, (from bar where col1=col2 select col2) as bar delete from foo where foo=bar as of ~2023.12.25..7.15.0..1ef5")
::
:: delete with three ctes and predicate as of 5 seconds ago
++  test-delete-19
  =/  expected  [%transform ctes=~[cte-t1 cte-foobar cte-bar] [%delete table=foo-table delete-pred [~ [%as-of-offset 5 %seconds]]] ~ ~]
  %+  expect-eq
    !>  ~[expected]
    !>  (parse:parse(default-database 'db1') "with (select *) as t1, (from foobar where col1=2 select col3, col4) as foobar, (from bar where col1=col2 select col2) as bar delete from foo where foo=bar as of 5 seconds ago")
::
:: delete cte with no predicate
++  test-delete-20
  =/  expected  [%transform ctes=~[cte-t1] [[%delete table=foo-table ~ ~] ~ ~]]
  %+  expect-eq
  !>  ~[expected]
  !>  (parse:parse(default-database 'db1') "with (select *) as t1 delete from foo")
::
:: delete cte with no predicate as of now
++  test-delete-21
  =/  expected  [%transform ctes=~[cte-t1] [[%delete table=foo-table ~ ~] ~ ~]]
  %+  expect-eq
  !>  ~[expected]
  !>  (parse:parse(default-database 'db1') "with (select *) as t1 delete from foo as of now")
::
:: delete cte with no predicate as of ~2023.12.25..7.15.0..1ef5
++  test-delete-22
  =/  expected  [%transform ctes=~[cte-t1] [[%delete table=foo-table ~ [~ [%da ~2023.12.25..7.15.0..1ef5]]] ~ ~]]
  %+  expect-eq
  !>  ~[expected]
  !>  (parse:parse(default-database 'db1') "with (select *) as t1 delete from foo as of ~2023.12.25..7.15.0..1ef5")
::
:: delete cte with no predicate as of 5 seconds ago
++  test-delete-23
  =/  expected  [%transform ctes=~[cte-t1] [[%delete table=foo-table ~ [~ [%as-of-offset 5 %seconds]]] ~ ~]]
  %+  expect-eq
  !>  ~[expected]
  !>  (parse:parse(default-database 'db1') "with (select *) as t1 delete from foo as of 5 seconds ago")
::
:: drop database
::
:: tests 1, 2, 3, 5, and extra whitespace characters, force db.name, name
++  test-drop-database-1
  =/  expected1  [%drop-database name='name' force=%.n]
  =/  expected2  [%drop-database name='name' force=%.y]
  %+  expect-eq
    !>  ~[expected1 expected2]
    !>  (parse:parse(default-database 'other-db') "droP  Database  name;droP \0d\09 DataBase FORce  \0a name")
::
:: leading and trailing whitespace characters, end delimiter not required on single, force name
++  test-drop-database-2
  %+  expect-eq
    !>  ~[[%drop-database name='name' force=%.y]]
    !>  (parse:parse(default-database 'other-db') "   \09drOp\0d\09  dAtabaSe\0a force name ")
::
:: fail when database is not a term
++  test-fail-drop-database-3
  %-  expect-fail
  |.  (parse:parse(default-database 'other-db') "DROP DATABASE nAme")
::
:: drop index
::
:: tests 1, 2, 3, 5, and extra whitespace characters, db.ns.name, db..name
++  test-drop-index-1
  =/  expected1  [%drop-index name='my-index' object=[%qualified-object ship=~ database='db' namespace='ns' name='name']]
  =/  expected2  [%drop-index name='my-index' object=[%qualified-object ship=~ database='db' namespace='dbo' name='name']]
  %+  expect-eq
    !>  ~[expected1 expected2]
    !>  (parse:parse(default-database 'other-db') "droP  inDex my-index On db.ns.name;droP  index my-index oN \0a db..name")
::
:: leading and trailing whitespace characters, end delimiter not required on single, ns.name
++  test-drop-index-2
  %+  expect-eq
    !>  ~[[%drop-index name='my-index' object=[%qualified-object ship=~ database='other-db' namespace='ns' name='name']]]
    !>  (parse:parse(default-database 'other-db') "   \09drop\0d\09  index\0d my-index \0a On ns.name   ")
::
:: :: fail when database qualifier is not a term
++  test-fail-drop-index-3
  %-  expect-fail
  |.  (parse:parse(default-database 'other-db') "DROP index my-index on Db.ns.name")
::
:: fail when database qualifier is not a term
++  test-fail-drop-index-4
  %-  expect-fail
  |.  (parse:parse(default-database 'other-db') "DROP index my-index on Db.ns.name")
::
:: fail when namespace qualifier is not a term
++  test-fail-drop-index-5
  %-  expect-fail
  |.  (parse:parse(default-database 'other-db') "DROP index my-index on db.nS.name")
::
:: fail when index name is not a term
++  test-fail-drop-index-6
  %-  expect-fail
  |.  (parse:parse(default-database 'other-db') "DROP index my-index on db.ns.nAme")
::
:: fail when index name is qualified with ship
++  test-fail-drop-index-7
  %-  expect-fail
  |.  (parse:parse(default-database 'other-db') "DROP index my-index on ~zod.db.ns.nAme")
::
:: drop namespace
::
:: tests 1, 2, 3, 5, and extra whitespace characters, force db.name, name
++  test-drop-namespace-00
  =/  expected1  [%drop-namespace database-name='db' name='name' force=%.n as-of=~]
  =/  expected2  [%drop-namespace database-name='other-db' name='name' force=%.y as-of=~]
  %+  expect-eq
    !>  ~[expected1 expected2]
    !>  (parse:parse(default-database 'other-db') "droP  Namespace  db.name;droP \0d\09 Namespace FORce  \0a name")
::
:: leading and trailing whitespace characters, end delimiter not required on single, force name
++  test-drop-namespace-01
  %+  expect-eq
    !>  ~[[%drop-namespace database-name='other-db' name='name' force=%.y as-of=~]]
    !>  (parse:parse(default-database 'other-db') "   \09drOp\0d\09  naMespace\0a force name ")
::
:: db.name
++  test-drop-namespace-02
  %+  expect-eq
    !>  ~[[%drop-namespace database-name='db' name='name' force=%.n as-of=~]]
    !>  (parse:parse(default-database 'other-db') "drop namespace db.name")
::
::  name, as of now
++  test-drop-namespace-03
  %+  expect-eq
    !>  ~[[%drop-namespace database-name='other-db' name='ns1' force=%.n as-of=~]]
    !>  (parse:parse(default-database 'other-db') "drop namespace ns1 AS OF NOW")
::
::  name, as of date
++  test-drop-namespace-04
  %+  expect-eq
    !>  ~[[%drop-namespace database-name='other-db' name='ns1' force=%.n as-of=[~ [%da ~2023.12.25..7.15.0..1ef5]]]]
    !>  (parse:parse(default-database 'other-db') "drop namespace ns1 as of ~2023.12.25..7.15.0..1ef5")
::
::  name, as of 5 seconds ago
++  test-drop-namespace-05
  %+  expect-eq
    !>  ~[[%drop-namespace database-name='other-db' name='ns1' force=%.n as-of=[~ [%as-of-offset 5 %seconds]]]]
    !>  (parse:parse(default-database 'other-db') "drop namespace ns1 as of 5 seconds ago")
::
::  force name as of now
++  test-drop-namespace-06
  %+  expect-eq
    !>  ~[[%drop-namespace database-name='other-db' name='ns1' force=%.y as-of=~]]
    !>  (parse:parse(default-database 'other-db') "drop namespace force ns1 as of now")
::
::  force name as of date
++  test-drop-namespace-07
  %+  expect-eq
    !>  ~[[%drop-namespace database-name='other-db' name='ns1' force=%.y as-of=[~ [%da ~2023.12.25..7.15.0..1ef5]]]]
    !>  (parse:parse(default-database 'other-db') "drop namespace force ns1 as of ~2023.12.25..7.15.0..1ef5")
::
::  force name as of 5 seconds ago
++  test-drop-namespace-08
  %+  expect-eq
    !>  ~[[%drop-namespace database-name='other-db' name='ns1' force=%.y as-of=[~ [%as-of-offset 5 %seconds]]]]
    !>  (parse:parse(default-database 'other-db') "drop namespace force ns1 as of 5 seconds ago")
::
:: db name as of now
++  test-drop-namespace-09
  %+  expect-eq
    !>  ~[[%drop-namespace database-name='db1' name='ns1' force=%.n as-of=~]]
    !>  (parse:parse(default-database 'other-db') "drop namespace db1.ns1 as of now")
::
:: db name as of date
++  test-drop-namespace-10
  %+  expect-eq
    !>  ~[[%drop-namespace database-name='db1' name='ns1' force=%.n as-of=[~ [%da ~2023.12.25..7.15.0..1ef5]]]]
    !>  (parse:parse(default-database 'other-db') "drop namespace db1.ns1 as of ~2023.12.25..7.15.0..1ef5")
::
:: db name as of 5 seconds ago
++  test-drop-namespace-11
  %+  expect-eq
    !>  ~[[%drop-namespace database-name='db1' name='ns1' force=%.n as-of=[~ [%as-of-offset 5 %seconds]]]]
    !>  (parse:parse(default-database 'other-db') "drop namespace db1.ns1 as of 5 seconds ago")
::
:: force db name as of now
++  test-drop-namespace-12
  %+  expect-eq
    !>  ~[[%drop-namespace database-name='db1' name='ns1' force=%.y as-of=~]]
    !>  (parse:parse(default-database 'other-db') "drop namespace force db1.ns1 as of now")
::
:: force db name as of ~2023.12.25..7.15.0..1ef5
++  test-drop-namespace-13
  %+  expect-eq
    !>  ~[[%drop-namespace database-name='db1' name='ns1' force=%.y as-of=[~ [%da ~2023.12.25..7.15.0..1ef5]]]]
    !>  (parse:parse(default-database 'other-db') "drop namespace force db1.ns1 as of ~2023.12.25..7.15.0..1ef5")
::
:: force db name as of 15 minutes ago
++  test-drop-namespace-14
  %+  expect-eq
    !>  ~[[%drop-namespace database-name='db1' name='ns1' force=%.y as-of=[~ [%as-of-offset 15 %minutes]]]]
    !>  (parse:parse(default-database 'other-db') "drop namespace force db1.ns1 as of 15 minutes ago")
::
:: fail when database qualifier is not a term
++  test-fail-drop-namespace-15
  %-  expect-fail
  |.  (parse:parse(default-database 'other-db') "DROP NAMESPACE Db.name")
::
:: fail when namespace is not a term
++  test-fail-drop-namespace-16
  %-  expect-fail
  |.  (parse:parse(default-database 'other-db') "DROP NAMESPACE nAme")
::
:: drop table
::
:: tests 1, 2, 3, 5, and extra whitespace characters
++  test-drop-table-00
  =/  expected1  [%drop-table table=[%qualified-object ship=~ database='db' namespace='ns' name='name'] force=%.y as-of=~]
  =/  expected2  [%drop-table table=[%qualified-object ship=~ database='db' namespace='ns' name='name'] force=%.n as-of=~]
  %+  expect-eq
    !>  ~[expected1 expected2]
    !>  (parse:parse(default-database 'other-db') "droP  table FORce db.ns.name;droP  table  \0a db.ns.name")
::
:: leading and trailing whitespace characters, end delimiter not required on single, force db..name
++  test-drop-table-01
  %+  expect-eq
    !>  ~[[%drop-table table=[%qualified-object ship=~ database='db' namespace='dbo' name='name'] force=%.y as-of=~]]
    !>  (parse:parse(default-database 'other-db') "   \09drop\0d\09  table\0aforce db..name ")
::
:: db..name
++  test-drop-table-02
  %+  expect-eq
    !>  ~[[%drop-table table=[%qualified-object ship=~ database='db' namespace='dbo' name='name'] force=%.n as-of=~]]
    !>  (parse:parse(default-database 'other-db') "drop table db..name")
::
:: force ns.name
++  test-drop-table-03
  %+  expect-eq
    !>  ~[[%drop-table table=[%qualified-object ship=~ database='other-db' namespace='ns' name='name'] force=%.y as-of=~]]
    !>  (parse:parse(default-database 'other-db') "drop table force ns.name")
::
:: ns.name
++  test-drop-table-04
  %+  expect-eq
    !>  ~[[%drop-table table=[%qualified-object ship=~ database='other-db' namespace='ns' name='name'] force=%.n as-of=~]]
    !>  (parse:parse(default-database 'other-db') "drop table ns.name")
::
:: force name
++  test-drop-table-05
  %+  expect-eq
    !>  ~[[%drop-table table=[%qualified-object ship=~ database='other-db' namespace='dbo' name='name'] force=%.y as-of=~]]
    !>  (parse:parse(default-database 'other-db') "DROP table FORCE name")
::
:: name
++  test-drop-table-06
  %+  expect-eq
   !>  ~[[%drop-table table=[%qualified-object ship=~ database='other-db' namespace='dbo' name='name'] force=%.n as-of=~]]
    !>  (parse:parse(default-database 'other-db') "DROP table name")
::
:: force db.ns.name as of now
++  test-drop-table-07
  %+  expect-eq
    !>  ~[[%drop-table table=[%qualified-object ship=~ database='db' namespace='ns' name='name'] force=%.y as-of=~]]
    !>  (parse:parse(default-database 'other-db') "drop table force db.ns.name as of now")
::
:: force db..name as of date
++  test-drop-table-08
  %+  expect-eq
    !>  ~[[%drop-table table=[%qualified-object ship=~ database='db' namespace='dbo' name='name'] force=%.y as-of=[~ [%da ~2023.12.25..7.15.0..1ef5]]]]
    !>  (parse:parse(default-database 'other-db') "drop table force db..name as of ~2023.12.25..7.15.0..1ef5")
::
:: force ns.name as of weeks ago
++  test-drop-table-09
  %+  expect-eq
    !>  ~[[%drop-table table=[%qualified-object ship=~ database='other-db' namespace='ns' name='name'] force=%.y as-of=[~ [%as-of-offset 10 %weeks]]]]
    !>  (parse:parse(default-database 'other-db') "drop table force ns.name as of 10 weeks ago")
::
:: name as of now
++  test-drop-table-10
  %+  expect-eq
    !>  ~[[%drop-table table=[%qualified-object ship=~ database='db' namespace='ns' name='name'] force=%.n as-of=~]]
    !>  (parse:parse(default-database 'other-db') "drop table db.ns.name as of now")
::
:: db..name as of date
++  test-drop-table-11
  %+  expect-eq
    !>  ~[[%drop-table table=[%qualified-object ship=~ database='db' namespace='dbo' name='name'] force=%.n as-of=[~ [%da ~2023.12.25..7.15.0..1ef5]]]]
    !>  (parse:parse(default-database 'other-db') "drop table db..name as of ~2023.12.25..7.15.0..1ef5")
::
:: name as of weeks ago
++  test-drop-table-12
  %+  expect-eq
    !>  ~[[%drop-table table=[%qualified-object ship=~ database='other-db' namespace='dbo' name='name'] force=%.n as-of=[~ [%as-of-offset 10 %weeks]]]]
    !>  (parse:parse(default-database 'other-db') "drop table name as of 10 weeks ago")
::
:: fail when database qualifier is not a term
++  test-fail-drop-table-13
  %-  expect-fail
  |.  (parse:parse(default-database 'other-db') "DROP table Db.ns.name")
::
:: fail when namespace qualifier is not a term
++  test-fail-drop-table-14
  %-  expect-fail
  |.  (parse:parse(default-database 'other-db') "DROP table db.nS.name")
::
:: fail when table name is not a term
++  test-fail-drop-table-15
  %-  expect-fail
  |.  (parse:parse(default-database 'other-db') "DROP table db.ns.nAme")
::
:: fail when table name is qualified with ship
++  test-fail-drop-table-16
  %-  expect-fail
  |.  (parse:parse(default-database 'other-db') "DROP table ~zod.db.ns.name")
::
:: drop view
::
:: tests 1, 2, 3, 5, and extra whitespace characters
++  test-drop-view-1
  =/  expected1  [%drop-view view=[%qualified-object ship=~ database='db' namespace='ns' name='name'] force=%.y]
  =/  expected2  [%drop-view view=[%qualified-object ship=~ database='db' namespace='ns' name='name'] force=%.n]
  %+  expect-eq
    !>  ~[expected1 expected2]
    !>  (parse:parse(default-database 'other-db') "droP  View FORce db.ns.name;droP  View  \0a db.ns.name")
::
:: leading and trailing whitespace characters, end delimiter not required on single, force db..name
++  test-drop-view-2
  %+  expect-eq
    !>  ~[[%drop-view view=[%qualified-object ship=~ database='db' namespace='dbo' name='name'] force=%.y]]
    !>  (parse:parse(default-database 'other-db') "   \09drop\0d\09  vIew\0aforce db..name ")
::
:: db..name
++  test-drop-view-3
  %+  expect-eq
    !>  ~[[%drop-view view=[%qualified-object ship=~ database='db' namespace='dbo' name='name'] force=%.n]]
    !>  (parse:parse(default-database 'other-db') "drop view db..name")
::
:: force ns.name
++  test-drop-view-4
  %+  expect-eq
    !>  ~[[%drop-view view=[%qualified-object ship=~ database='other-db' namespace='ns' name='name'] force=%.y]]
    !>  (parse:parse(default-database 'other-db') "drop view force ns.name")
::
:: ns.name
++  test-drop-view-5
  %+  expect-eq
    !>  ~[[%drop-view view=[%qualified-object ship=~ database='other-db' namespace='ns' name='name'] force=%.n]]
    !>  (parse:parse(default-database 'other-db') "drop view ns.name")
::
:: force name
++  test-drop-view-6
  %+  expect-eq
    !>  ~[[%drop-view view=[%qualified-object ship=~ database='other-db' namespace='dbo' name='name'] force=%.y]]
    !>  (parse:parse(default-database 'other-db') "DROP VIEW FORCE name")
::
:: name
++  test-drop-view-7
  %+  expect-eq
    !>  ~[[%drop-view view=[%qualified-object ship=~ database='other-db' namespace='dbo' name='name'] force=%.n]]
    !>  (parse:parse(default-database 'other-db') "DROP VIEW name")
::
:: fail when database qualifier is not a term
++  test-fail-drop-view-8
  %-  expect-fail
  |.  (parse:parse(default-database 'other-db') "DROP VIEW Db.ns.name")
::
:: fail when namespace qualifier is not a term
++  test-fail-drop-view-9
  %-  expect-fail
  |.  (parse:parse(default-database 'other-db') "DROP VIEW db.nS.name")
::
:: fail when view name is not a term
++  test-fail-drop-view-10
  %-  expect-fail
  |.  (parse:parse(default-database 'other-db') "DROP VIEW db.ns.nAme")
::
:: fail when view name is qualified with ship
++  test-fail-drop-view-11
  %-  expect-fail
  |.  (parse:parse(default-database 'other-db') "DROP view ~zod.db.ns.name")
::
:: grant permission
::
:: tests 1, 2, 3, 5, and extra whitespace characters, ship-database, parent-database
++  test-grant-1
  =/  expected1  [%grant permission=%adminread to=~[~sampel-palnet] grant-target=[%database 'db']]
  =/  expected2  [%grant permission=%adminread to=%parent grant-target=[%database 'db']]
  %+  expect-eq
    !>  ~[expected1 expected2]
    !>  (parse:parse(default-database 'other-db') "grant  adminread\0a tO \0d ~sampel-palnet on\0a database  db;Grant adminRead to paRent on dataBase db")
::
:: leading and trailing whitespace characters, end delimiter not required on single, ship-qualified-ns
++  test-grant-2
  %+  expect-eq
    !>  ~[[%grant permission=%readwrite to=~[~sampel-palnet] grant-target=[%namespace 'db' 'ns']]]
    !>  (parse:parse(default-database 'db2') "   \09Grant Readwrite   to ~sampel-palnet on namespace db.ns ")
::
:: ship unqualified ns
++  test-grant-3
  %+  expect-eq
    !>  ~[[%grant permission=%readwrite to=~[~sampel-palnet] grant-target=[%namespace 'db2' 'ns']]]
    !>  (parse:parse(default-database 'db2') "Grant Readwrite to ~sampel-palnet on namespace ns")
::
:: siblings qualified ns
++  test-grant-4
  %+  expect-eq
    !>  ~[[%grant permission=%readonly to=%siblings grant-target=[%namespace 'db' 'ns']]]
    !>  (parse:parse(default-database 'db2') "grant readonly to SIBLINGS on namespace db.ns")
::
:: moons unqualified ns
++  test-grant-5
  %+  expect-eq
    !>  ~[[%grant permission=%readwrite to=%moons grant-target=[%namespace 'db2' 'ns']]]
    !>  (parse:parse(default-database 'db2') "Grant Readwrite to moonS on namespace ns")
::
:: ship db.ns.table
++  test-grant-6
  %+  expect-eq
    !>  ~[[%grant permission=%readwrite to=~[~sampel-palnet] grant-target=[%qualified-object ship=~ database='db' namespace='ns' name='table']]]
    !>  (parse:parse(default-database 'db2') "Grant Readwrite to ~sampel-palnet on db.ns.table")
::
:: parent db.ns.table
++  test-grant-7
  %+  expect-eq
    !>  ~[[%grant permission=%adminread to=%parent grant-target=[%qualified-object ship=~ database='db' namespace='ns' name='table']]]
    !>  (parse:parse(default-database 'db2') "grant adminread to parent on db.ns.table")
::
:: ship db..table
++  test-grant-8
  %+  expect-eq
    !>  ~[[%grant permission=%readwrite to=~[~sampel-palnet] grant-target=[%qualified-object ship=~ database='db' namespace='dbo' name='table']]]
    !>  (parse:parse(default-database 'db2') "Grant Readwrite to ~sampel-palnet on db..table")
::
:: parent on db..table
++  test-grant-9
  %+  expect-eq
    !>  ~[[%grant permission=%adminread to=%parent grant-target=[%qualified-object ship=~ database='db' namespace='dbo' name='table']]]
    !>  (parse:parse(default-database 'db2') "grant adminread to parent on db..table")
::
:: ship table
++  test-grant-10
  %+  expect-eq
    !>  ~[[%grant permission=%readwrite to=~[~sampel-palnet] grant-target=[%qualified-object ship=~ database='db2' namespace='dbo' name='table']]]
    !>  (parse:parse(default-database 'db2') "Grant Readwrite to ~sampel-palnet on table")
::
:: ship list table
++  test-grant-11
  %+  expect-eq
    !>  ~[[%grant permission=%readwrite to=~[~zod ~bus ~nec ~sampel-palnet] grant-target=[%qualified-object ship=~ database='db2' namespace='dbo' name='table']]]
    !>  (parse:parse(default-database 'db2') "grant Readwrite to ~zod,~bus,~nec,~sampel-palnet on table")
::
:: ship list on db..table
++  test-grant-12
  %+  expect-eq
    !>  ~[[%grant permission=%adminread to=~[~zod ~bus ~nec ~sampel-palnet] grant-target=[%qualified-object ship=~ database='db' namespace='dbo' name='table']]]
    !>  (parse:parse(default-database 'db2') "grant adminread to ~zod,~bus,~nec,~sampel-palnet on db..table")
::
:: ship list spaced, table
++  test-grant-13
  %+  expect-eq
    !>  ~[[%grant permission=%readwrite to=~[~zod ~bus ~nec ~sampel-palnet] grant-target=[%qualified-object ship=~ database='db2' namespace='dbo' name='table']]]
    !>  (parse:parse(default-database 'db2') "grant Readwrite to  ~zod,\0a~bus ,~nec , ~sampel-palnet on table")
::
:: ship list spaced, on db..table
++  test-grant-14
  %+  expect-eq
    !>  ~[[%grant permission=%adminread to=~[~zod ~bus ~nec ~sampel-palnet] grant-target=[%qualified-object ship=~ database='db' namespace='dbo' name='table']]]
    !>  (parse:parse(default-database 'db2') "grant adminread to ~zod , ~bus, ~nec ,~sampel-palnet on db..table")
::
:: parent table
++  test-grant-15
  %+  expect-eq
    !>  ~[[%grant permission=%adminread to=%parent grant-target=[%qualified-object ship=~ database='db2' namespace='dbo' name='table']]]
    !>  (parse:parse(default-database 'db2') "grant adminread to parent on table")
::
:: fail when database qualifier is not a term
++  test-fail-grant-16
  %-  expect-fail
  |.  (parse:parse(default-database 'db2') "grant adminread to parent on Db.ns.table")
::
:: fail when namespace qualifier is not a term
++  test-fail-grant-17
  %-  expect-fail
  |.  (parse:parse(default-database 'db2') "grant adminread to parent on db.Ns.table")
::
:: fail when table name is not a term
++  test-fail-grant-18
  %-  expect-fail
  |.  (parse:parse(default-database 'other-db') "grant adminread to parent on Table")
::
:: fail when table name is qualified with ship
++  test-fail-grant-19
  %-  expect-fail
  |.  (parse:parse(default-database 'other-db') "grant adminread to parent ~zod.db.ns.name")
::
:: insert
::
:: tests 1, 2, 3, 5, and extra whitespace characters, db.ns.table, db..table, colum list, two value rows, one value row, no space around ; delimeter
:: NOTE: the parser does not check:
::       1) validity of columns re parent table
::       2) match column count to values count
::       3) enforce consistent value counts across rows
++  test-insert-00
  =/  expected1  
    :+  %transform
        ctes=~
        :+  :*  %insert
                table=[%qualified-object ship=~ database='db' namespace='ns' name='my-table']
                columns=`['col1' 'col2' 'col3' 'col4' 'col5' 'col6' 'col7' 'col8' 'col9' ~]
                values=[%data ~[~[[~.t 1.685.221.219] [~.rs 1.078.523.331] [~.sd 39] [~.ud 20] [~.rs 1.078.523.331] [~.p 28.242.037] [~.rs 3.226.006.979] [~.t 430.158.540.643] [~.sd 6]] ~[[~.default 32.770.348.699.510.116] [~.if 3.284.569.946] [~.ud 195.198.143.900]]]]
                as-of=~
            ==
        ~
        ~
  =/  expected2  
    :+  %transform
        ctes=~
        :+  :*  %insert
                table=[%qualified-object ship=~ database='db' namespace='dbo' name='my-table']
                columns=`['col1' 'col2' 'col3' 'col4' 'col5' 'col6' 'col7' 'col8' 'col9' ~]
                values=[%data ~[~[[~.t 1.685.221.219] [~.rs 1.078.523.331] [~.sd 39] [~.ud 20] [~.rs 1.078.523.331] [~.p 28.242.037] [~.rs 3.226.006.979] [~.t 430.158.540.643] [~.sd 6]]]]
                as-of=~
            ==
        ~
        ~
  =/  urql1  " iNsert  iNto  db.ns.my-table  ".
"( col1 ,  col2 ,  col3 ,  col4 ,  col5 ,  col6 ,  col7 ,  col8 ,  col9 )".
" Values  ('cord',.3.14,-20,20,.3.14,~nomryg-nilref,.-3.14, 'cor\\'d', --3)".
"  (Default,.195.198.143.90, 195.198.143.900)"
  =/  urql2  "insert into db..my-table ".
"(col1, col2, col3, col4, col5, col6, col7, col8, col9)".
"valueS ('cord',.3.14,-20,20,.3.14,~nomryg-nilref,.-3.14, 'cor\\'d', --3)"
  %+  expect-eq
    !>  ~[expected1 expected2]
    !>  (parse:parse(default-database 'other-db') (weld urql1 (weld ";" urql2)))
::
:: no columns, 3 rows
++  test-insert-01
  =/  expected  
    :+  %transform
        ctes=~
        :+  :*  %insert
                table=[%qualified-object ship=~ database='db1' namespace='dbo' name='my-table']
                columns=~
                values=[%data ~[~[[~.t 1.685.221.219] [~.rs 1.078.523.331] [~.sd 39] [~.ud 20] [~.rs 1.078.523.331] [~.p 28.242.037] [~.rs 3.226.006.979] [~.t 430.158.540.643] [~.sd 6]] ~[[~.default 32.770.348.699.510.116] [~.if 3.284.569.946] [~.ud 195.198.143.900]] ~[[~.ud 2.222] [~.ud 2.222] [~.ud 195.198.143.900] [~.rs 1.078.523.331] [~.rs 3.226.006.979] [~.rd 4.614.253.070.214.989.087] [~.rd 13.837.625.107.069.764.895] [~.ux 1.205.249] [~.ub 43] [~.sd 39] [~.sd 40] [~.uw 61.764.130.813.526] [~.uw 1.870.418.170.505.042.572.886]]]]
                as-of=~
            ==
        ~
        ~
  =/  urql  "insert into my-table ".
"values ('cord',.3.14,-20,20,.3.14,~nomryg-nilref,.-3.14, 'cor\\'d', --3)".
" (default,.195.198.143.90, 195.198.143.900)".
" (2.222,2222,195.198.143.900,.3.14,.-3.14,~3.14,~-3.14,0x12.6401,10.1011,-20,--20,e2O.l4Xpm,pm.l4e2O.l4Xpm)"
  %+  expect-eq
    !>  ~[expected]
    !>  (parse:parse(default-database 'db1') urql)
::
:: no columns, 3 rows, as of now
++  test-insert-02
  =/  expected  
    :+  %transform
        ctes=~
        :+  :*  %insert
                table=[%qualified-object ship=~ database='db1' namespace='dbo' name='my-table']
                columns=~
                values=[%data ~[~[[~.t 1.685.221.219] [~.rs 1.078.523.331] [~.sd 39] [~.ud 20] [~.rs 1.078.523.331] [~.p 28.242.037] [~.rs 3.226.006.979] [~.t 430.158.540.643] [~.sd 6]] ~[[~.default 32.770.348.699.510.116] [~.if 3.284.569.946] [~.ud 195.198.143.900]] ~[[~.ud 2.222] [~.ud 2.222] [~.ud 195.198.143.900] [~.rs 1.078.523.331] [~.rs 3.226.006.979] [~.rd 4.614.253.070.214.989.087] [~.rd 13.837.625.107.069.764.895] [~.ux 1.205.249] [~.ub 43] [~.sd 39] [~.sd 40] [~.uw 61.764.130.813.526] [~.uw 1.870.418.170.505.042.572.886]]]]
                as-of=~
            ==
        ~
        ~
  =/  urql  "insert into my-table ".
"values ('cord',.3.14,-20,20,.3.14,~nomryg-nilref,.-3.14, 'cor\\'d', --3)".
" (default,.195.198.143.90, 195.198.143.900)".
" (2.222,2222,195.198.143.900,.3.14,.-3.14,~3.14,~-3.14,0x12.6401,10.1011,-20,--20,e2O.l4Xpm,pm.l4e2O.l4Xpm)".
" as of now"
  %+  expect-eq
    !>  ~[expected]
    !>  (parse:parse(default-database 'db1') urql)
::
:: no columns, 3 rows, as of ~2023.12.25..7.15.0..1ef5
++  test-insert-03
  =/  expected  
    :+  %transform
        ctes=~
        :+  :*  %insert
                table=[%qualified-object ship=~ database='db1' namespace='dbo' name='my-table']
                columns=~
                values=[%data ~[~[[~.t 1.685.221.219] [~.rs 1.078.523.331] [~.sd 39] [~.ud 20] [~.rs 1.078.523.331] [~.p 28.242.037] [~.rs 3.226.006.979] [~.t 430.158.540.643] [~.sd 6]] ~[[~.default 32.770.348.699.510.116] [~.if 3.284.569.946] [~.ud 195.198.143.900]] ~[[~.ud 2.222] [~.ud 2.222] [~.ud 195.198.143.900] [~.rs 1.078.523.331] [~.rs 3.226.006.979] [~.rd 4.614.253.070.214.989.087] [~.rd 13.837.625.107.069.764.895] [~.ux 1.205.249] [~.ub 43] [~.sd 39] [~.sd 40] [~.uw 61.764.130.813.526] [~.uw 1.870.418.170.505.042.572.886]]]]
                as-of=[~ [%da ~2023.12.25..7.15.0..1ef5]]
            ==
        ~
        ~
  =/  urql  "insert into my-table ".
"values ('cord',.3.14,-20,20,.3.14,~nomryg-nilref,.-3.14, 'cor\\'d', --3)".
" (default,.195.198.143.90, 195.198.143.900)".
" (2.222,2222,195.198.143.900,.3.14,.-3.14,~3.14,~-3.14,0x12.6401,10.1011,-20,--20,e2O.l4Xpm,pm.l4e2O.l4Xpm)".
" as of ~2023.12.25..7.15.0..1ef5"
  %+  expect-eq
    !>  ~[expected]
    !>  (parse:parse(default-database 'db1') urql)
::
:: no columns, 3 rows, as of 5 days ago
++  test-insert-04
  =/  expected  
    :+  %transform
        ctes=~
        :+  :*  %insert
                table=[%qualified-object ship=~ database='db1' namespace='dbo' name='my-table']
                columns=~
                values=[%data ~[~[[~.t 1.685.221.219] [~.rs 1.078.523.331] [~.sd 39] [~.ud 20] [~.rs 1.078.523.331] [~.p 28.242.037] [~.rs 3.226.006.979] [~.t 430.158.540.643] [~.sd 6]] ~[[~.default 32.770.348.699.510.116] [~.if 3.284.569.946] [~.ud 195.198.143.900]] ~[[~.ud 2.222] [~.ud 2.222] [~.ud 195.198.143.900] [~.rs 1.078.523.331] [~.rs 3.226.006.979] [~.rd 4.614.253.070.214.989.087] [~.rd 13.837.625.107.069.764.895] [~.ux 1.205.249] [~.ub 43] [~.sd 39] [~.sd 40] [~.uw 61.764.130.813.526] [~.uw 1.870.418.170.505.042.572.886]]]]
                as-of=[~ %as-of-offset 5 %days]
            ==
        ~
        ~
  =/  urql  "insert into my-table ".
"values ('cord',.3.14,-20,20,.3.14,~nomryg-nilref,.-3.14, 'cor\\'d', --3)".
" (default,.195.198.143.90, 195.198.143.900)".
" (2.222,2222,195.198.143.900,.3.14,.-3.14,~3.14,~-3.14,0x12.6401,10.1011,-20,--20,e2O.l4Xpm,pm.l4e2O.l4Xpm)".
" as of 5 days ago"
  %+  expect-eq
    !>  ~[expected]
    !>  (parse:parse(default-database 'db1') urql)
::
:: no columns, 3 rows, as of now
++  test-insert-05
  =/  expected
    :+  %transform
        ctes=~
        :+  :*  %insert
                table=[%qualified-object ship=~ database='db' namespace='ns' name='my-table']
                columns=`['col1' 'col2' 'col3' 'col4' 'col5' 'col6' 'col7' 'col8' 'col9' ~]
                values=[%data ~[~[[~.t 1.685.221.219] [~.rs 1.078.523.331] [~.sd 39] [~.ud 20] [~.rs 1.078.523.331] [~.p 28.242.037] [~.rs 3.226.006.979] [~.t 430.158.540.643] [~.sd 6]] ~[[~.default 32.770.348.699.510.116] [~.if 3.284.569.946] [~.ud 195.198.143.900]]]]
                as-of=~
            ==
        ~
        ~
  =/  urql  "insert  into  db.ns.my-table ".
"(col1, col2, col3, col4, col5, col6, col7, col8, col9 )".
" values  ('cord',.3.14,-20,20,.3.14,~nomryg-nilref,.-3.14, 'cor\\'d', --3)".
"  (default,.195.198.143.90, 195.198.143.900) as of now"
  %+  expect-eq
    !>  ~[expected]
    !>  (parse:parse(default-database 'other-db') urql)
::
:: no columns, 3 rows, as of now
++  test-insert-06
  =/  expected
    :+  %transform
        ctes=~
        :+  :*  %insert
                table=[%qualified-object ship=~ database='db' namespace='ns' name='my-table']
                columns=`['col1' 'col2' 'col3' 'col4' 'col5' 'col6' 'col7' 'col8' 'col9' ~]
                values=[%data ~[~[[~.t 1.685.221.219] [~.rs 1.078.523.331] [~.sd 39] [~.ud 20] [~.rs 1.078.523.331] [~.p 28.242.037] [~.rs 3.226.006.979] [~.t 430.158.540.643] [~.sd 6]] ~[[~.default 32.770.348.699.510.116] [~.if 3.284.569.946] [~.ud 195.198.143.900]]]]
                as-of=[~ [%da ~2023.12.25..7.15.0..1ef5]]
            ==
        ~
        ~
  =/  urql  "insert  into  db.ns.my-table ".
"(col1, col2, col3, col4, col5, col6, col7, col8, col9 )".
" values  ('cord',.3.14,-20,20,.3.14,~nomryg-nilref,.-3.14, 'cor\\'d', --3)".
"  (default,.195.198.143.90, 195.198.143.900) as of ~2023.12.25..7.15.0..1ef5"
  %+  expect-eq
    !>  ~[expected]
    !>  (parse:parse(default-database 'other-db') urql)
::
:: no columns, 3 rows, as of offset
++  test-insert-07
  =/  expected
    :+  %transform
        ctes=~
        :+  :*  %insert
                table=[%qualified-object ship=~ database='db' namespace='ns' name='my-table']
                columns=`['col1' 'col2' 'col3' 'col4' 'col5' 'col6' 'col7' 'col8' 'col9' ~]
                values=[%data ~[~[[~.t 1.685.221.219] [~.rs 1.078.523.331] [~.sd 39] [~.ud 20] [~.rs 1.078.523.331] [~.p 28.242.037] [~.rs 3.226.006.979] [~.t 430.158.540.643] [~.sd 6]] ~[[~.default 32.770.348.699.510.116] [~.if 3.284.569.946] [~.ud 195.198.143.900]]]]
                as-of=[~ %as-of-offset 5 %days]
            ==
        ~
        ~
  =/  urql  "insert  into  db.ns.my-table ".
"(col1, col2, col3, col4, col5, col6, col7, col8, col9 )".
" values  ('cord',.3.14,-20,20,.3.14,~nomryg-nilref,.-3.14, 'cor\\'d', --3)".
"  (default,.195.198.143.90, 195.198.143.900) as of 5 days ago"
  %+  expect-eq
    !>  ~[expected]
    !>  (parse:parse(default-database 'other-db') urql)
::
:: every column type, no spaces around values
++  test-insert-08
  =/  expected  
    :+  %transform
        ctes=~
        :+  :*  %insert
                table=[%qualified-object ship=~ database='db' namespace='ns' name='my-table']
                columns=~
                values=[%data ~[~[[~.t 1.685.221.219] [~.p 28.242.037] [~.p 28.242.037] [~.da 170.141.184.504.830.774.788.415.618.594.688.204.800] [~.da 170.141.184.504.830.774.788.415.618.594.688.204.800] [~.dr 114.450.695.119.985.999.668.576.256] [~.dr 114.450.695.119.985.999.668.576.256] [~.if 3.284.569.946] [~.is 123.543.654.234] [~.f 0] [~.f 1] [~.f 0] [~.f 1] [~.ud 2.222] [~.ud 2.222] [~.ud 195.198.143.900] [~.rs 1.078.523.331] [~.rs 3.226.006.979] [~.rd 4.614.253.070.214.989.087] [~.rd 13.837.625.107.069.764.895] [~.ux 1.205.249] [~.ub 43] [~.sd 39] [~.sd 40] [~.uw 61.764.130.813.526] [~.uw 1.870.418.170.505.042.572.886]]]]
                as-of=~
            ==
        ~
        ~
  =/  urql  "insert into db.ns.my-table ".
"values ('cord',~nomryg-nilref,nomryg-nilref,~2020.12.25..7.15.0..1ef5,2020.12.25..7.15.0..1ef5,".
"~d71.h19.m26.s24..9d55, d71.h19.m26.s24..9d55,.195.198.143.90,.0.0.0.0.0.1c.c3c6.8f5a,y,n,Y,N,".
"2.222,2222,195.198.143.900,.3.14,.-3.14,~3.14,~-3.14,0x12.6401,10.1011,-20,--20,e2O.l4Xpm,pm.l4e2O.l4Xpm)"
  %+  expect-eq
    !>  ~[expected]
    !>  (parse:parse(default-database 'db1') urql)
::
:: every column type, spaces on all sides of values, comma inside cord
++  test-insert-09
  =/  expected  
    :+  %transform
        ctes=~
        :+  :*  %insert
                table=[%qualified-object ship=~ database='db' namespace='ns' name='my-table']
                columns=~
                values=[%data ~[~[[~.t 430.242.426.723] [~.p 28.242.037] [~.p 28.242.037] [~.da 170.141.184.504.830.774.788.415.618.594.688.204.800] [~.da 170.141.184.504.830.774.788.415.618.594.688.204.800] [~.dr 114.450.695.119.985.999.668.576.256] [~.dr 114.450.695.119.985.999.668.576.256] [~.if 3.284.569.946] [~.is 123.543.654.234] [~.f 0] [~.f 1] [~.f 0] [~.f 1] [~.ud 2.222] [~.ud 2.222] [~.ud 195.198.143.900] [~.rs 1.078.523.331] [~.rs 3.226.006.979] [~.rd 4.614.253.070.214.989.087] [~.rd 13.837.625.107.069.764.895] [~.ux 1.205.249] [~.ub 43] [~.sd 39] [~.sd 40] [~.uw 61.764.130.813.526] [~.uw 1.870.418.170.505.042.572.886]]]]
                as-of=~
            ==
        ~
        ~
  =/  urql  "insert into db.ns.my-table ".
"values ( 'cor,d' , ~nomryg-nilref , nomryg-nilref , ~2020.12.25..7.15.0..1ef5 , 2020.12.25..7.15.0..1ef5 , ".
"~d71.h19.m26.s24..9d55 ,  d71.h19.m26.s24..9d55 , .195.198.143.90 , .0.0.0.0.0.1c.c3c6.8f5a , y , n , Y , N , ".
"2.222 , 2222 , 195.198.143.900 , .3.14 , .-3.14 , ~3.14 , ~-3.14 , 0x12.6401 , 10.1011 , -20 , --20 , e2O.l4Xpm , pm.l4e2O.l4Xpm )"
  %+  expect-eq
    !>  ~[expected]
    !>  (parse:parse(default-database 'db1') urql)
::
:: revoke permission
::
:: tests 1, 2, 3, 5, and extra whitespace characters, ship-database, parent-database
++  test-revoke-1
  =/  expected1  [%revoke permission=%adminread to=~[~sampel-palnet] revoke-target=[%database 'db']]
  =/  expected2  [%revoke permission=%adminread to=%parent revoke-target=[%database 'db']]
  %+  expect-eq
    !>  ~[expected1 expected2]
    !>  (parse:parse(default-database 'other-db') "revoke  adminread\0a From \0d ~sampel-palnet on\0a database  db;Revoke adminRead fRom paRent on dataBase db")
::
:: leading and trailing whitespace characters, end delimiter not required on single, ship-qualified-ns
++  test-revoke-2
  %+  expect-eq
    !>  ~[[%revoke permission=%readwrite to=~[~sampel-palnet] revoke-target=[%namespace 'db' 'ns']]]
    !>  (parse:parse(default-database 'db2') "   \09ReVoke Readwrite   From ~sampel-palnet on namespace db.ns ")
::
:: ship unqualified ns
++  test-revoke-3
  %+  expect-eq
    !>  ~[[%revoke permission=%readwrite to=~[~sampel-palnet] revoke-target=[%namespace 'db2' 'ns']]]
    !>  (parse:parse(default-database 'db2') "Revoke Readwrite from ~sampel-palnet on namespace ns")
::
:: siblings qualified ns
++  test-revoke-4
  %+  expect-eq
    !>  ~[[%revoke permission=%readonly to=%siblings revoke-target=[%namespace 'db' 'ns']]]
    !>  (parse:parse(default-database 'db2') "revoke readonly from SIBLINGS on namespace db.ns")
::
:: moons unqualified ns
++  test-revoke-5
  %+  expect-eq
    !>  ~[[%revoke permission=%readwrite to=%moons revoke-target=[%namespace 'db2' 'ns']]]
    !>  (parse:parse(default-database 'db2') "Revoke Readwrite from moonS on namespace ns")
::
:: ship db.ns.table
++  test-revoke-6
  %+  expect-eq
    !>  ~[[%revoke permission=%readwrite to=~[~sampel-palnet] revoke-target=[%qualified-object ship=~ database='db' namespace='ns' name='table']]]
    !>  (parse:parse(default-database 'db2') "Revoke Readwrite from ~sampel-palnet on db.ns.table")
::
:: all from all db.ns.table
++  test-revoke-7
  %+  expect-eq
    !>  ~[[%revoke permission=%all from=%all revoke-target=[%qualified-object ship=~ database='db' namespace='ns' name='table']]]
    !>  (parse:parse(default-database 'db2') "revoke all from all on db.ns.table")
::
:: ship db..table
++  test-revoke-8
  %+  expect-eq
    !>  ~[[%revoke permission=%readwrite from=~[~sampel-palnet] revoke-target=[%qualified-object ship=~ database='db' namespace='dbo' name='table']]]
    !>  (parse:parse(default-database 'db2') "Revoke Readwrite from ~sampel-palnet on db..table")
::
:: parent on db..table
++  test-revoke-9
  %+  expect-eq
    !>  ~[[%revoke permission=%adminread from=%parent revoke-target=[%qualified-object ship=~ database='db' namespace='dbo' name='table']]]
    !>  (parse:parse(default-database 'db2') "revoke adminread from parent on db..table")
::
:: single ship table
++  test-revoke-10
  %+  expect-eq
    !>  ~[[%revoke permission=%readwrite from=~[~sampel-palnet] revoke-target=[%qualified-object ship=~ database='db2' namespace='dbo' name='table']]]
    !>  (parse:parse(default-database 'db2') "Revoke Readwrite from ~sampel-palnet on table")
::
:: ship list table
++  test-revoke-11
  %+  expect-eq
    !>  ~[[%revoke permission=%readwrite from=~[~zod ~sampel-palnet-sampel-palnet ~nec ~sampel-palnet] revoke-target=[%qualified-object ship=~ database='db2' namespace='dbo' name='table']]]
    !>  (parse:parse(default-database 'db2') "Revoke Readwrite from ~zod,~sampel-palnet-sampel-palnet,~nec,~sampel-palnet on table")
::
:: ship list on db..table
++  test-revoke-12
  %+  expect-eq
    !>  ~[[%revoke permission=%adminread from=~[~zod ~bus ~nec ~sampel-palnet] revoke-target=[%qualified-object ship=~ database='db' namespace='dbo' name='table']]]
    !>  (parse:parse(default-database 'db2') "revoke adminread from ~zod,~bus,~nec,~sampel-palnet on db..table")
::
:: ship list spaced, table
++  test-revoke-13
  %+  expect-eq
    !>  ~[[%revoke permission=%readwrite from=~[~zod ~bus ~nec ~sampel-palnet] revoke-target=[%qualified-object ship=~ database='db2' namespace='dbo' name='table']]]
    !>  (parse:parse(default-database 'db2') "Revoke Readwrite from  ~zod,\0a~bus ,~nec , ~sampel-palnet on table")
::
:: ship list spaced, on db..table
++  test-revoke-14
  %+  expect-eq
    !>  ~[[%revoke permission=%adminread from=~[~zod ~bus ~nec ~sampel-palnet] revoke-target=[%qualified-object ship=~ database='db' namespace='dbo' name='table']]]
    !>  (parse:parse(default-database 'db2') "revoke adminread from ~zod , ~bus, ~nec ,~sampel-palnet on db..table")
::
:: parent table
++  test-revoke-15
  %+  expect-eq
    !>  ~[[%revoke permission=%adminread from=%parent revoke-target=[%qualified-object ship=~ database='db2' namespace='dbo' name='table']]]
    !>  (parse:parse(default-database 'db2') "revoke adminread from parent on table")
::
:: fail when database qualifier is not a term
++  test-fail-revoke-16
  %-  expect-fail
  |.  (parse:parse(default-database 'db2') "revoke adminread from parent on Db.ns.table")
::
:: fail when namespace qualifier is not a term
++  test-fail-revoke-17
  %-  expect-fail
  |.  (parse:parse(default-database 'db2') "revoke adminread from parent on db.Ns.table")
::
:: fail when table name is not a term
++  test-fail-revoke-18
  %-  expect-fail
  |.  (parse:parse(default-database 'other-db') "revoke adminread from parent on Table")
::
:: fail when table name is qualified with ship
++  test-fail-revoke-19
  %-  expect-fail
  |.  (parse:parse(default-database 'other-db') "revoke adminread from parent on ~zod.db.ns.name")
::
::
:: truncate table
::
:: tests 1, 2, 3, 5, and extra whitespace characters
++  test-truncate-table-1
  =/  expected1  [%truncate-table table=[%qualified-object ship=[~ ~zod] database='db' namespace='ns' name='name'] as-of=~]
  =/  expected2  [%truncate-table table=[%qualified-object ship=[~ ~sampel-palnet] database='db' namespace='dbo' name='name'] as-of=~]
  %+  expect-eq
    !>  ~[expected1 expected2]
    !>  (parse:parse(default-database 'dummy') " \0atrUncate TAble\0d ~zod.db.ns.name\0a; truncate table ~sampel-palnet.db..name")
::
:: leading and trailing whitespace characters, end delimiter not required on single, db.ns.name
++  test-truncate-table-2
  %+  expect-eq
    !>  ~[[%truncate-table table=[%qualified-object ship=~ database='db' namespace='ns' name='name'] as-of=~]]
    !>  (parse:parse(default-database 'dummy') "   \09truncate\0d\09  TaBle\0a db.ns.name ")
::
:: db..name
++  test-truncate-table-3
  %+  expect-eq
    !>  ~[[%truncate-table table=[%qualified-object ship=~ database='db' namespace='dbo' name='name'] as-of=~]]
    !>  (parse:parse(default-database 'dummy') "truncate table db..name")
::
:: ns.name
++  test-truncate-table-4
  %+  expect-eq
    !>  ~[[%truncate-table table=[%qualified-object ship=~ database='dummy' namespace='ns' name='name'] as-of=~]]
    !>  (parse:parse(default-database 'dummy') "truncate table ns.name")
::
:: name
++  test-truncate-table-5
  %+  expect-eq
   !>  ~[[%truncate-table table=[%qualified-object ship=~ database='dummy' namespace='dbo' name='name'] as-of=~]]
   !>  (parse:parse(default-database 'dummy') "truncate table name")
::
:: fail when database qualifier is not a term
++  test-fail-truncate-table-6
  %-  expect-fail
  |.  (parse:parse(default-database 'dummy') "truncate table Db.ns.name")
::
:: fail when namespace qualifier is not a term
++  test-fail-truncate-table-7
  %-  expect-fail
  |.  (parse:parse(default-database 'dummy') "truncate table db.nS.name")
::
:: fail when table name is not a term
++  test-fail-truncate-table-8
  %-  expect-fail
  |.  (parse:parse(default-database 'dummy') "truncate table db.ns.nAme")
::
:: fail when table name is not a term
++  test-fail-truncate-table-9
  %-  expect-fail
  |.  (parse:parse(default-database 'dummy') "truncate table db.ns.nAme")
::
:: fail when ship is invalid
++  test-fail-truncate-table-10
  %-  expect-fail
  |.  (parse:parse(default-database 'dummy') "truncate table ~shitty-shippp db.ns.nAme")
::
:: from object and joins
::
++  select-top-10-all  [%select top=[~ 10] bottom=~ columns=~[[%qualified-object ship=~ database='ALL' namespace='ALL' name='ALL']]]
++  from-foo
  [~ [%from object=[%table-set object=foo-table alias=~] joins=~]]
++  from-foo-aliased
  [~ [%from object=[%table-set object=foo-table alias=[~ 'F1']] joins=~]]
++  simple-from-foo
  [%query from-foo scalars=~ ~ group-by=~ having=~ select-top-10-all ~]
++  aliased-from-foo
  [%query from-foo-aliased scalars=~ ~ group-by=~ having=~ select-top-10-all ~]
++  joins-bar
  ~[[%joined-object join=%join object=[%table-set object=[%qualified-object ship=~ database='db1' namespace='dbo' name='bar'] alias=~] predicate=`one-eq-1]]
++  from-foo-join-bar
  [~ [%from object=[%table-set object=foo-table alias=~] joins=joins-bar]]
++  simple-from-foo-join-bar
  [%query from-foo-join-bar scalars=~ ~ group-by=~ having=~ select-top-10-all ~]
++  joins-bar-aliased
  ~[[%joined-object join=%join object=[%table-set object=[%qualified-object ship=~ database='db1' namespace='dbo' name='bar'] alias=[~ 'b1']] predicate=`one-eq-1]]
++  from-foo-join-bar-aliased
  [~ [%from object=[%table-set object=foo-table alias=~] joins=joins-bar-aliased]]
++  simple-from-foo-join-bar-aliased
  [%query from-foo-join-bar-aliased scalars=~ ~ group-by=~ having=~ select-top-10-all ~]
++  from-foo-aliased-join-bar-aliased
  [~ [%from object=[%table-set object=foo-table alias=[~ 'f1']] joins=joins-bar-aliased]]
++  aliased-from-foo-join-bar-aliased
  [%query from-foo-aliased-join-bar-aliased scalars=~ ~ group-by=~ having=~ select-top-10-all ~]
++  joins-bar-baz
  ~[[%joined-object join=%join object=[%table-set object=[%qualified-object ship=~ database='db1' namespace='dbo' name='bar'] alias=~] predicate=`one-eq-1] [%joined-object join=%left-join object=[%table-set object=[%qualified-object ship=~ database='db1' namespace='dbo' name='baz'] alias=~] predicate=`one-eq-1]]
++  from-foo-join-bar-baz
  [~ [%from object=[%table-set object=foo-table alias=~] joins=joins-bar-baz]]
++  simple-from-foo-join-bar-baz
  [%query from-foo-join-bar-baz scalars=~ ~ group-by=~ having=~ select-top-10-all ~]
++  aliased-joins-bar-baz
  ~[[%joined-object join=%join object=[%table-set object=[%qualified-object ship=~ database='db1' namespace='dbo' name='bar'] alias=[~ 'B1']] predicate=`one-eq-1] [%joined-object join=%left-join object=[%table-set object=[%qualified-object ship=~ database='db1' namespace='dbo' name='baz'] alias=[~ 'b2']] predicate=`one-eq-1]]
++  aliased-foo-join-bar-baz
  [~ [%from object=[%table-set object=foo-table alias=[~ 'f1']] joins=aliased-joins-bar-baz]]
++  aliased-from-foo-join-bar-baz
  [%query aliased-foo-join-bar-baz scalars=~ ~ group-by=~ having=~ select-top-10-all ~]
++  foo-table-row  [%query-row ~['col1' 'col2' 'col3']]
++  from-foo-row
  [~ [%from object=[%table-set object=foo-table-row alias=~] joins=~]]
++  from-foo-row-aliased
  [~ [%from object=[%table-set object=foo-table-row alias=[~ 'F1']] joins=~]]
++  simple-from-foo-row
  [%query from-foo-row scalars=~ ~ group-by=~ having=~ select-top-10-all ~]
++  aliased-from-foo-row
  [%query from-foo-row-aliased scalars=~ ~ group-by=~ having=~ select-top-10-all ~]
++  joins-col
  ~[[%joined-object join=%join object=[%table-set object=[%query-row ~['col1' 'col2' 'col3']] alias=~] predicate=`one-eq-1]]
++  from-foo-join-bar-row
  [~ [%from object=[%table-set object=foo-table alias=~] joins=joins-col]]
++  simple-from-foo-join-bar-row
  [%query from-foo-join-bar-row scalars=~ ~ group-by=~ having=~ select-top-10-all ~]
++  joins-col-aliased
  ~[[%joined-object join=%join object=[%table-set object=[%query-row ~['col1' 'col2' 'col3']] alias=[~ 'b1']] predicate=`one-eq-1]]
++  from-foo-join-bar-row-aliased
  [~ [%from object=[%table-set object=foo-table alias=~] joins=joins-col-aliased]]
++  simple-from-foo-join-bar-row-aliased
  [%query from-foo-join-bar-row-aliased scalars=~ ~ group-by=~ having=~ select-top-10-all ~]
++  from-foo-row-aliased-join-bar-aliased
  [~ [%from object=[%table-set object=foo-table alias=[~ 'f1']] joins=joins-col-aliased]]
++  aliased-from-foo-join-bar-row-aliased
  [%query from-foo-row-aliased-join-bar-aliased scalars=~ ~ group-by=~ having=~ select-top-10-all ~]
++  joins-bar-col
  ~[[%joined-object join=%join object=[%table-set object=[%qualified-object ship=~ database='db1' namespace='dbo' name='bar'] alias=~] predicate=`one-eq-1] [%joined-object join=%left-join object=[%table-set object=[%query-row ~['col1' 'col2' 'col3']] alias=~] predicate=`one-eq-1]]
++  from-foo-join-bar-row-baz
  [~ [%from object=[%table-set object=foo-table-row alias=~] joins=joins-bar-col]]
++  simple-from-foo-join-bar-row-baz
  [%query from-foo-join-bar-row-baz scalars=~ ~ group-by=~ having=~ select-top-10-all ~]
++  aliased-joins-bar-col
  ~[[%joined-object join=%join object=[%table-set object=[%qualified-object ship=~ database='db1' namespace='dbo' name='bar'] alias=[~ 'B1']] predicate=`one-eq-1] [%joined-object join=%left-join object=[%table-set object=[%query-row ~['col1' 'col2' 'col3']] alias=[~ 'b2']] predicate=`one-eq-1]]
++  aliased-foo-join-bar-col
  [~ [%from object=[%table-set object=[%query-row ~['col1']] alias=[~ 'f1']] joins=aliased-joins-bar-col]]
++  aliased-from-foo-join-bar-row-baz
  [%query aliased-foo-join-bar-col scalars=~ ~ group-by=~ having=~ select-top-10-all ~]
++  foo-alias-y
  [%table-set object=[%qualified-object ship=~ database='db1' namespace='dbo' name='foo'] alias=[~ 'y']]
++  bar-alias-x
  [%table-set object=[%qualified-object ship=~ database='db1' namespace='dbo' name='bar'] alias=[~ 'x']]
++  foo-unaliased
  [%table-set object=[%qualified-object ship=~ database='db1' namespace='dbo' name='foo'] alias=~]
++  bar-unaliased
  [%table-set object=[%qualified-object ship=~ database='db1' namespace='dbo' name='bar'] alias=~]
++  passthru-row-y
  [%table-set object=[%query-row ~['col1' 'col2' 'col3']] alias=[~ 'y']]
++  passthru-row-x
  [%table-set object=[%query-row ~['col1' 'col2' 'col3']] alias=[~ 'x']]
++  passthru-unaliased
  [%table-set object=[%query-row ~['col1' 'col2' 'col3']] alias=~]
::
::  from foo (un-aliased)
++  test-from-join-01
%+  expect-eq
    !>  ~[[%transform ctes=~ [[simple-from-foo] ~ ~]]]
    !>  (parse:parse(default-database 'db1') "FROM foo SELECT TOP 10 *")
::
::  from foo (aliased)
++  test-from-join-02
%+  expect-eq
    !>  ~[[%transform ctes=~ [[aliased-from-foo] ~ ~]]]
    !>  (parse:parse(default-database 'db1') "FROM foo F1 SELECT TOP 10 *")
::
::  from foo (aliased as)
++  test-from-join-03
%+  expect-eq
    !>  ~[[%transform ctes=~ [[aliased-from-foo] ~ ~]]]
    !>  (parse:parse(default-database 'db1') "FROM foo as F1 SELECT TOP 10 *")
::
::  from foo (un-aliased) join bar (un-aliased)
++  test-from-join-04
%+  expect-eq
    !>  ~[[%transform ctes=~ [[simple-from-foo-join-bar] ~ ~]]]
    !>  (parse:parse(default-database 'db1') "FROM foo join bar on 1 = 1 SELECT TOP 10 *")
::
::  from foo (un-aliased) join bar (aliased)
++  test-from-join-05
%+  expect-eq
    !>  ~[[%transform ctes=~ [[simple-from-foo-join-bar-aliased] ~ ~]]]
    !>  (parse:parse(default-database 'db1') "FROM foo join bar b1 on 1 = 1 SELECT TOP 10 *")
::
::  from foo (un-aliased) join bar (aliased as)
++  test-from-join-06
%+  expect-eq
    !>  ~[[%transform ctes=~ [[simple-from-foo-join-bar-aliased] ~ ~]]]
    !>  (parse:parse(default-database 'db1') "FROM foo join bar  as  b1 on 1 = 1 SELECT TOP 10 *")
::
::  from foo (aliased lower case) join bar (aliased as)
++  test-from-join-07
%+  expect-eq
    !>  ~[[%transform ctes=~ [[aliased-from-foo-join-bar-aliased] ~ ~]]]
    !>  (parse:parse(default-database 'db1') "FROM foo f1 join bar b1 on 1 = 1 SELECT TOP 10 *")
::
::  from foo (un-aliased) join bar (un-aliased) left join baz (un-aliased)
++  test-from-join-08
%+  expect-eq
    !>  ~[[%transform ctes=~ [[simple-from-foo-join-bar-baz] ~ ~]]]
    !>  (parse:parse(default-database 'db1') "FROM foo join bar on 1 = 1 left join baz on 1 = 1 SELECT TOP 10 *")
::
::  from foo (aliased) join bar (aliased) left join baz (aliased)
++  test-from-join-09
%+  expect-eq
    !>  ~[[%transform ctes=~ [[aliased-from-foo-join-bar-baz] ~ ~]]]
    !>  (parse:parse(default-database 'db1') "FROM foo f1 join bar as B1 on 1 = 1 left join baz b2 on 1 = 1 SELECT TOP 10 *")
::
::  from pass-thru row (un-aliased)
++  test-from-join-10
%+  expect-eq
    !>  ~[[%transform ctes=~ [[simple-from-foo-row] ~ ~]]]
    !>  (parse:parse(default-database 'db1') "FROM (col1, col2, col3) SELECT TOP 10 *")
::
::  from pass-thru row (aliased)
++  test-from-join-11
%+  expect-eq
    !>  ~[[%transform ctes=~ [[aliased-from-foo-row] ~ ~]]]
    !>  (parse:parse(default-database 'db1') "FROM (col1, col2, col3) F1 SELECT TOP 10 *")
::
::  from pass-thru row (aliased as)
++  test-from-join-12
%+  expect-eq
    !>  ~[[%transform ctes=~ [[aliased-from-foo-row] ~ ~]]]
    !>  (parse:parse(default-database 'db1') "FROM (col1, col2, col3) as F1 SELECT TOP 10 *")

::  from foo (un-aliased) join pass-thru (un-aliased)
++  test-from-join-13
%+  expect-eq
    !>  ~[[%transform ctes=~ [[simple-from-foo-join-bar-row] ~ ~]]]
    !>  (parse:parse(default-database 'db1') "FROM foo join (col1, col2, col3) on 1 = 1 SELECT TOP 10 *")
::
::  from foo (un-aliased) join pass-thru (aliased)
++  test-from-join-14
%+  expect-eq
    !>  ~[[%transform ctes=~ [[simple-from-foo-join-bar-row-aliased] ~ ~]]]
    !>  (parse:parse(default-database 'db1') "FROM foo join (col1, col2, col3) b1 on 1 = 1 SELECT TOP 10 *")
::
::  from foo (un-aliased) join pass-thru (aliased as)
++  test-from-join-15
%+  expect-eq
    !>  ~[[%transform ctes=~ [[simple-from-foo-join-bar-row-aliased] ~ ~]]]
    !>  (parse:parse(default-database 'db1') "FROM foo join (col1,col2,col3)  as  b1 on 1 = 1 SELECT TOP 10 *")
::
::  from foo (aliased lower case) join pass-thru (aliased as)
++  test-from-join-16
%+  expect-eq
    !>  ~[[%transform ctes=~ [[aliased-from-foo-join-bar-row-aliased] ~ ~]]]
    !>  (parse:parse(default-database 'db1') "FROM foo f1 join (col1,col2,col3) b1 on 1 = 1 SELECT TOP 10 *")
::
::  from pass-thru (un-aliased) join bar (un-aliased) left join pass-thru (un-aliased)
++  test-from-join-17
%+  expect-eq
    !>  ~[[%transform ctes=~ [[simple-from-foo-join-bar-row-baz] ~ ~]]]
    !>  (parse:parse(default-database 'db1') "FROM (col1,col2,col3) join bar on 1 = 1 left join (col1,col2,col3) on 1 = 1 SELECT TOP 10 *")
::
::  from pass-thru single column (aliased) join bar (aliased) left join pass-thru (aliased)
++  test-from-join-18
%+  expect-eq
    !>  ~[[%transform ctes=~ [[aliased-from-foo-join-bar-row-baz] ~ ~]]]
    !>  (parse:parse(default-database 'db1') "FROM (col1) f1 join bar as B1 on 1 = 1 left join ( col1,col2,col3 ) b2 on 1 = 1 SELECT TOP 10 *")
::
::  from foo as (aliased) cross join bar (aliased)
++  test-from-join-19
%+  expect-eq
 =/  expected  
   [%transform ctes=~ [[%query from=[~ [%from object=foo-alias-y joins=~[[%joined-object join=%cross-join object=bar-alias-x predicate=~]]]] scalars=~ predicate=~ group-by=~ having=~ selection=select-all-columns order-by=~] ~ ~]]
    !>  ~[expected]
    !>  (parse:parse(default-database 'db1') "FROM foo as y cross join bar x SELECT *")
::
::  from foo (aliased) cross join bar as (aliased)
++  test-from-join-20
%+  expect-eq
 =/  expected  
   [%transform ctes=~ [[%query from=[~ [%from object=foo-alias-y joins=~[[%joined-object join=%cross-join object=bar-alias-x predicate=~]]]] scalars=~ predicate=~ group-by=~ having=~ selection=select-all-columns order-by=~] ~ ~]]
    !>  ~[expected]
    !>  (parse:parse(default-database 'db1') "FROM foo y cross join bar as x SELECT *")
::
::  from foo cross join bar
++  test-from-join-21
%+  expect-eq
 =/  expected  
   [%transform ctes=~ [[%query from=[~ [%from object=foo-unaliased joins=~[[%joined-object join=%cross-join object=bar-unaliased predicate=~]]]] scalars=~ predicate=~ group-by=~ having=~ selection=select-all-columns order-by=~] ~ ~]]
    !>  ~[expected]
    !>  (parse:parse(default-database 'db1') "FROM foo cross join bar SELECT *")
::
::  from pass-thru as (aliased) cross join bar (aliased)
++  test-from-join-22
%+  expect-eq
 =/  expected  
   [%transform ctes=~ [[%query from=[~ [%from object=passthru-row-y joins=~[[%joined-object join=%cross-join object=bar-alias-x predicate=~]]]] scalars=~ predicate=~ group-by=~ having=~ selection=select-all-columns order-by=~] ~ ~]]
    !>  ~[expected]
    !>  (parse:parse(default-database 'db1') "FROM (col1, col2, col3) as y cross join bar x SELECT *")
::
::  from pass-thru (aliased) cross join bar as (aliased)
++  test-from-join-23
%+  expect-eq
 =/  expected  
   [%transform ctes=~ [[%query from=[~ [%from object=passthru-row-y joins=~[[%joined-object join=%cross-join object=bar-alias-x predicate=~]]]] scalars=~ predicate=~ group-by=~ having=~ selection=select-all-columns order-by=~] ~ ~]]
    !>  ~[expected]
    !>  (parse:parse(default-database 'db1') "FROM (col1,col2,col3) y cross join bar as x SELECT *")

::
::  from foo as (aliased) cross join pass-thru  (aliased)
++  test-from-join-24
%+  expect-eq
=/  expected  
  [%transform ctes=~ [[%query from=[~ [%from object=foo-alias-y joins=~[[%joined-object join=%cross-join object=passthru-row-x predicate=~]]]] scalars=~ predicate=~ group-by=~ having=~ selection=select-all-columns order-by=~] ~ ~]]
    !>  ~[expected]
    !>  (parse:parse(default-database 'db1') "FROM foo as y cross join (col1,col2,col3) x SELECT *")
::
::  from foo (aliased) cross join pass-thru  as (aliased)
++  test-from-join-25
%+  expect-eq
=/  expected  
  [%transform ctes=~ [[%query from=[~ [%from object=foo-alias-y joins=~[[%joined-object join=%cross-join object=passthru-row-x predicate=~]]]] scalars=~ predicate=~ group-by=~ having=~ selection=select-all-columns order-by=~] ~ ~]]
    !>  ~[expected]
    !>  (parse:parse(default-database 'db1') "FROM foo y cross join (col1,col2,col3) as x SELECT *")
::
::  from pass-thru cross join pass-thru
++  test-from-join-26
%+  expect-eq
=/  expected  
  [%transform ctes=~ [[%query from=[~ [%from object=passthru-unaliased joins=~[[%joined-object join=%cross-join object=passthru-unaliased predicate=~]]]] scalars=~ predicate=~ group-by=~ having=~ selection=select-all-columns order-by=~] ~ ~]]
    !>  ~[expected]
    !>  (parse:parse(default-database 'db1') "FROM (col1,col2,col3) cross join (col1,col2,col3) SELECT *")
::
::  from foo (aliased) cross join pass-thru
++  test-from-join-27
%+  expect-eq
=/  expected  
  [%transform ctes=~ [[%query from=[~ [%from object=foo-alias-y joins=~[[%joined-object join=%cross-join object=passthru-unaliased predicate=~]]]] scalars=~ predicate=~ group-by=~ having=~ selection=select-all-columns order-by=~] ~ ~]]
    !>  ~[expected]
    !>  (parse:parse(default-database 'db1') "FROM foo y cross join (col1,col2,col3) SELECT *")
::
:: fail joins with cross join
++  test-fail-from-join-28
    =/  select  "FROM foo y join foo cross join (col1,col2,col3) SELECT *"
    %-  expect-fail
    |.  (parse:parse(default-database 'db1') select)
    ::
:: fail joins with cross join
++  test-fail-from-join-29
    =/  select  "FROM foo y cross join bar join bar  SELECT *"
    %-  expect-fail
    |.  (parse:parse(default-database 'db1') select)
:: fail multiple cross join
++  test-fail-from-join-30
    =/  select  "FROM foo y cross join (col1,col2,col3) cross join foobar  SELECT *"
    %-  expect-fail
    |.  (parse:parse(default-database 'db1') select)
::
::  predicate
::
::  re-used components
++  all-columns  [%qualified-object ship=~ database='ALL' namespace='ALL' name='ALL']
++  select-all-columns  [%select top=~ bottom=~ columns=~[all-columns]]
++  foo
  [[%qualified-column [%qualified-object ~ 'UNKNOWN' 'COLUMN-OR-CTE' 'foo'] 'foo' ~] ~ ~]
++  t1-foo
  [[%qualified-column [%qualified-object ~ 'UNKNOWN' 'COLUMN' 'T1'] 'foo' ~] ~ ~]

++  foo2
  [[%qualified-column [%qualified-object ~ 'UNKNOWN' 'COLUMN-OR-CTE' 'foo2'] 'foo2' ~] ~ ~]
++  t1-foo2
  [[%qualified-column [%qualified-object ~ 'UNKNOWN' 'COLUMN' 'T1'] 'foo2' ~] ~ ~]
++  foo3
  [[%qualified-column [%qualified-object ~ 'UNKNOWN' 'COLUMN-OR-CTE' 'foo3'] 'foo3' ~] ~ ~]
++  t1-foo3
  [[%qualified-column [%qualified-object ~ 'UNKNOWN' 'COLUMN' 'T1'] 'foo3' ~] ~ ~]
++  foo4
  [[%qualified-column [%qualified-object ~ 'UNKNOWN' 'COLUMN-OR-CTE' 'foo4'] 'foo4' ~] ~ ~]
++  foo5
  [[%qualified-column [%qualified-object ~ 'UNKNOWN' 'COLUMN-OR-CTE' 'foo5'] 'foo5' ~] ~ ~]
++  foo6
  [[%qualified-column [%qualified-object ~ 'UNKNOWN' 'COLUMN-OR-CTE' 'foo6'] 'foo6' ~] ~ ~]
++  foo7
  [[%qualified-column [%qualified-object ~ 'UNKNOWN' 'COLUMN-OR-CTE' 'foo7'] 'foo7' ~] ~ ~]
++  bar
  [[%qualified-column [%qualified-object ~ 'UNKNOWN' 'COLUMN-OR-CTE' 'bar'] 'bar' ~] ~ ~]
++  t2-bar
  [[%qualified-column [%qualified-object ~ 'UNKNOWN' 'COLUMN' 'T2'] 'bar' ~] ~ ~]
++  foobar
  [[%qualified-column [%qualified-object ~ 'UNKNOWN' 'COLUMN-OR-CTE' 'foobar'] 'foobar' ~] ~ ~]
++  a1-adoption-email
  [[%qualified-column [%qualified-object ~ 'UNKNOWN' 'COLUMN' 'A1'] 'adoption-email' ~] ~ ~]
++  a2-adoption-email
  [[%qualified-column [%qualified-object ~ 'UNKNOWN' 'COLUMN' 'A2'] 'adoption-email' ~] ~ ~]
++  a1-adoption-date
  [[%qualified-column [%qualified-object ~ 'UNKNOWN' 'COLUMN' 'A1'] 'adoption-date' ~] ~ ~]
++  a2-adoption-date
  [[%qualified-column [%qualified-object ~ 'UNKNOWN' 'COLUMN' 'A2'] 'adoption-date' ~] ~ ~]
++  a1-name
  [[%qualified-column [%qualified-object ~ 'UNKNOWN' 'COLUMN' 'A1'] 'name' ~] ~ ~]
++  a2-name
  [[%qualified-column [%qualified-object ~ 'UNKNOWN' 'COLUMN' 'A2'] 'name' ~] ~ ~]
++  a1-species
  [[%qualified-column [%qualified-object ~ 'UNKNOWN' 'COLUMN' 'A1'] 'species' ~] ~ ~]
++  a2-species
  [[%qualified-column [%qualified-object ~ 'UNKNOWN' 'COLUMN' 'A2'] 'species' ~] ~ ~]
++  value-literals   [[%value-literals %ud '3;2;1'] ~ ~]
++  aggregate-count-foobar
  [%aggregate function='count' source=[%qualified-column qualifier=[%qualified-object ship=~ database='UNKNOWN' namespace='COLUMN-OR-CTE' name='foobar'] column='foobar' alias=~]]
++  literal-10           [[%ud 10] ~ ~]
::
::  re-used simple predicates
++  foobar-gte-foo       [%gte foobar foo]
++  foobar-lte-bar       [%lte foobar bar]
++  foo-eq-1             [%eq foo [[%ud 1] ~ ~]]
++  t1-foo-gt-foo2       [%gt t1-foo foo2]
++  t2-bar-in-list       [%in t2-bar value-literals]
++  t1-foo2-eq-zod       [%eq t1-foo2 [[%p 0] ~ ~]]
++  t1-foo3-lt-any-list  [%lt t1-foo3 [%any value-literals ~]]
::
::  re-used predicates with conjunctions
++  and-fb-gte-f--fb-lte-b   [%and foobar-gte-foo foobar-lte-bar]
++  and-fb-gte-f--t1f2-eq-z  [%and foobar-gte-foo t1-foo2-eq-zod]
++  and-f-eq-1--t1f3-lt-any  [%and foo-eq-1 t1-foo3-lt-any-list]
++  and-and                  [%and and-fb-gte-f--fb-lte-b t1-foo2-eq-zod]
++  and-and-or               [%or and-and t2-bar-in-list]
++  and-and-or-and           [%or and-and and-fb-gte-f--t1f2-eq-z]
++  and-and-or-and-or-and    [%or and-and-or-and and-f-eq-1--t1f3-lt-any]
::
::  predicates with conjunctions and nesting
++  and-fb-gt-f--fb-lt-b     [%and [%gt foobar foo] [%lt foobar bar]]
++  and-t1f-gt-f2--t2b-in-l  [%and t1-foo-gt-foo2 t2-bar-in-list]
++  or2                      [%and [%and t1-foo3-lt-any-list t1-foo2-eq-zod] foo-eq-1]
++  or3                      [%and [%eq foo3 foo4] [%eq foo5 foo6]]
++  big-or                   [%or [%or [%or and-t1f-gt-f2--t2b-in-l or2] or3] [%eq foo4 foo5]]
++  big-and                  [%and and-fb-gt-f--fb-lt-b big-or]
++  a-a-l-a-o-l-a-a-r-o-r-a-l-o-r-a
                             [%and big-and [%eq foo6 foo7]]
++  first-or                 [%or [%gt foobar foo] [%lt foobar bar]]
++  last-or                  [%or t1-foo3-lt-any-list [%and t1-foo2-eq-zod foo-eq-1]]
++  first-and                [%and first-or t1-foo-gt-foo2]
++  second-and               [%and first-and t2-bar-in-list]
++  king-and                 [%and [second-and] last-or]
::
::  test binary operators, varying spacing
++  test-predicate-01
  =/  query  "FROM adoptions AS T1 JOIN adoptions AS T2 ON T1.foo = T2.bar SELECT *"
  =/  pred=(tree predicate-component:ast)  [%eq t1-foo t2-bar]
  =/  expected  
    [%transform ctes=~ [[%query [~ [%from object=[%table-set object=[%qualified-object ship=~ database='db1' namespace='dbo' name='adoptions'] alias=[~ 'T1']] joins=~[[%joined-object join=%join object=[%table-set object=[%qualified-object ship=~ database='db1' namespace='dbo' name='adoptions'] alias=[~ 'T2']] predicate=`pred]]]] scalars=~ ~ group-by=~ having=~ select-all-columns ~] ~ ~]]
  %+  expect-eq
    !>  ~[expected]
    !>  (parse:parse(default-database 'db1') query)
++  test-predicate-02
  =/  query  "FROM adoptions AS T1 JOIN adoptions AS T2 ON foo<>bar SELECT *"
  =/  pred=(tree predicate-component:ast)  [%neq foo bar]
  =/  expected  
    [%transform ctes=~ [[%query [~ [%from object=[%table-set object=[%qualified-object ship=~ database='db1' namespace='dbo' name='adoptions'] alias=[~ 'T1']] joins=~[[%joined-object join=%join object=[%table-set object=[%qualified-object ship=~ database='db1' namespace='dbo' name='adoptions'] alias=[~ 'T2']] predicate=`pred]]]] scalars=~ ~ group-by=~ having=~ select-all-columns ~] ~ ~]]
  %+  expect-eq
    !>  ~[expected]
    !>  (parse:parse(default-database 'db1') query)
++  test-predicate-03
  =/  query  "FROM adoptions AS T1 JOIN adoptions AS T2 ON foo!= bar SELECT *"
  =/  pred=(tree predicate-component:ast)  [%neq foo bar]
  =/  expected  
    [%transform ctes=~ [[%query [~ [%from object=[%table-set object=[%qualified-object ship=~ database='db1' namespace='dbo' name='adoptions'] alias=[~ 'T1']] joins=~[[%joined-object join=%join object=[%table-set object=[%qualified-object ship=~ database='db1' namespace='dbo' name='adoptions'] alias=[~ 'T2']] predicate=`pred]]]] scalars=~ ~ group-by=~ having=~ select-all-columns ~] ~ ~]]
  %+  expect-eq
    !>  ~[expected]
    !>  (parse:parse(default-database 'db1') query)
++  test-predicate-04
  =/  query  "FROM adoptions AS T1 JOIN adoptions AS T2 ON foo >bar SELECT *"
  =/  pred=(tree predicate-component:ast)  [%gt foo bar]
  =/  expected  
    [%transform ctes=~ [[%query [~ [%from object=[%table-set object=[%qualified-object ship=~ database='db1' namespace='dbo' name='adoptions'] alias=[~ 'T1']] joins=~[[%joined-object join=%join object=[%table-set object=[%qualified-object ship=~ database='db1' namespace='dbo' name='adoptions'] alias=[~ 'T2']] predicate=`pred]]]] scalars=~ ~ group-by=~ having=~ select-all-columns ~] ~ ~]]
  %+  expect-eq
    !>  ~[expected]
    !>  (parse:parse(default-database 'db1') query)
++  test-predicate-05
  =/  query  "FROM adoptions AS T1 JOIN adoptions AS T2 ON foo <bar SELECT *"
  =/  pred=(tree predicate-component:ast)  [%lt foo bar]
  =/  expected  
    [%transform ctes=~ [[%query [~ [%from object=[%table-set object=[%qualified-object ship=~ database='db1' namespace='dbo' name='adoptions'] alias=[~ 'T1']] joins=~[[%joined-object join=%join object=[%table-set object=[%qualified-object ship=~ database='db1' namespace='dbo' name='adoptions'] alias=[~ 'T2']] predicate=`pred]]]] scalars=~ ~ group-by=~ having=~ select-all-columns ~] ~ ~]]
  %+  expect-eq
    !>  ~[expected]
    !>  (parse:parse(default-database 'db1') query)
++  test-predicate-06
  =/  query  "FROM adoptions AS T1 JOIN adoptions AS T2 ON foo>= bar SELECT *"
  =/  pred=(tree predicate-component:ast)  [%gte foo bar]
  =/  expected  
    [%transform ctes=~ [[%query [~ [%from object=[%table-set object=[%qualified-object ship=~ database='db1' namespace='dbo' name='adoptions'] alias=[~ 'T1']] joins=~[[%joined-object join=%join object=[%table-set object=[%qualified-object ship=~ database='db1' namespace='dbo' name='adoptions'] alias=[~ 'T2']] predicate=`pred]]]] scalars=~ ~ group-by=~ having=~ select-all-columns ~] ~ ~]]
  %+  expect-eq
    !>  ~[expected]
    !>  (parse:parse(default-database 'db1') query)
++  test-predicate-07
  =/  query  "FROM adoptions AS T1 JOIN adoptions AS T2 ON foo!< bar SELECT *"
  =/  pred=(tree predicate-component:ast)  [%gte foo bar]
  =/  expected  
    [%transform ctes=~ [[%query [~ [%from object=[%table-set object=[%qualified-object ship=~ database='db1' namespace='dbo' name='adoptions'] alias=[~ 'T1']] joins=~[[%joined-object join=%join object=[%table-set object=[%qualified-object ship=~ database='db1' namespace='dbo' name='adoptions'] alias=[~ 'T2']] predicate=`pred]]]] scalars=~ ~ group-by=~ having=~ select-all-columns ~] ~ ~]]
  %+  expect-eq
    !>  ~[expected]
    !>  (parse:parse(default-database 'db1') query)
++  test-predicate-08
  =/  query  "FROM adoptions AS T1 JOIN adoptions AS T2 ON foo <= bar SELECT *"
  =/  pred=(tree predicate-component:ast)  [%lte foo bar]
  =/  expected  
    [%transform ctes=~ [[%query [~ [%from object=[%table-set object=[%qualified-object ship=~ database='db1' namespace='dbo' name='adoptions'] alias=[~ 'T1']] joins=~[[%joined-object join=%join object=[%table-set object=[%qualified-object ship=~ database='db1' namespace='dbo' name='adoptions'] alias=[~ 'T2']] predicate=`pred]]]] scalars=~ ~ group-by=~ having=~ select-all-columns ~] ~ ~]]
  %+  expect-eq
    !>  ~[expected]
    !>  (parse:parse(default-database 'db1') query)
++  test-predicate-09
  =/  query  "FROM adoptions AS T1 JOIN adoptions AS T2 ON foo !> bar SELECT *"
  =/  pred=(tree predicate-component:ast)  [%lte foo bar]
  =/  expected  
    [%transform ctes=~ [[%query [~ [%from object=[%table-set object=[%qualified-object ship=~ database='db1' namespace='dbo' name='adoptions'] alias=[~ 'T1']] joins=~[[%joined-object join=%join object=[%table-set object=[%qualified-object ship=~ database='db1' namespace='dbo' name='adoptions'] alias=[~ 'T2']] predicate=`pred]]]] scalars=~ ~ group-by=~ having=~ select-all-columns ~] ~ ~]]
  %+  expect-eq
    !>  ~[expected]
    !>  (parse:parse(default-database 'db1') query)
++  test-predicate-10
  =/  query  "FROM foo WHERE foobar EQUIV bar SELECT *"
  =/  pred=(tree predicate-component:ast)  [%equiv foobar bar]
  %+  expect-eq
    !>  ~[[%transform ctes=~ [[%query from-foo scalars=~ `pred group-by=~ having=~ [%select top=~ bottom=~ columns=~[all-columns]] ~]] ~ ~]]
    !>  (parse:parse(default-database 'db1') query)
++  test-predicate-11
  =/  query  "FROM foo WHERE foobar NOT EQUIV bar SELECT *"
  =/  pred=(tree predicate-component:ast)  [%not-equiv foobar bar]
  %+  expect-eq
    !>  ~[[%transform ctes=~ [[%query from-foo scalars=~ `pred group-by=~ having=~ select-all-columns ~]] ~ ~]]
    !>  (parse:parse(default-database 'db1') query)
::
::  remaining simple predicates, varying spacing and keywork casing
++  test-predicate-12
  =/  query  "FROM adoptions AS T1 JOIN adoptions AS T2 ON T1.foo = T2.bar ".
    " WHERE foobar  Not  Between foo  And bar ".
    " SELECT *"
  =/  joinpred=(tree predicate-component:ast)  [%eq t1-foo t2-bar]
  =/  pred=(tree predicate-component:ast)      [%not-between foobar-gte-foo foobar-lte-bar]
  =/  expected
    [%transform ctes=~ [[%query [~ [%from object=[%table-set object=[%qualified-object ship=~ database='db1' namespace='dbo' name='adoptions'] alias=[~ 'T1']] joins=~[[%joined-object join=%join object=[%table-set object=[%qualified-object ship=~ database='db1' namespace='dbo' name='adoptions'] alias=[~ 'T2']] predicate=`joinpred]]]] scalars=~ `pred group-by=~ having=~ select-all-columns ~] ~ ~]]
  %+  expect-eq
    !>  ~[expected]
    !>  (parse:parse(default-database 'db1') query)
++  test-predicate-13
  =/  query  "FROM adoptions AS T1 JOIN adoptions AS T2 ON T1.foo = T2.bar ".
    " WHERE foobar  Not  Between foo   bar ".
    " SELECT *"
  =/  joinpred=(tree predicate-component:ast)  [%eq t1-foo t2-bar]
  =/  pred=(tree predicate-component:ast)      [%not-between foobar-gte-foo foobar-lte-bar]
  =/  expected
    [%transform ctes=~ [[%query [~ [%from object=[%table-set object=[%qualified-object ship=~ database='db1' namespace='dbo' name='adoptions'] alias=[~ 'T1']] joins=~[[%joined-object join=%join object=[%table-set object=[%qualified-object ship=~ database='db1' namespace='dbo' name='adoptions'] alias=[~ 'T2']] predicate=`joinpred]]]] scalars=~ `pred group-by=~ having=~ select-all-columns ~] ~ ~]]
  %+  expect-eq
    !>  ~[expected]
    !>  (parse:parse(default-database 'db1') query)
++  test-predicate-14
  =/  query  "FROM adoptions AS T1 JOIN adoptions AS T2 ON T1.foo = T2.bar ".
    " WHERE foobar  Between foo  And bar ".
    " SELECT *"
  =/  joinpred=(tree predicate-component:ast)  [%eq t1-foo t2-bar]
  =/  pred=(tree predicate-component:ast)      [%between foobar-gte-foo foobar-lte-bar]
  =/  expected
    [%transform ctes=~ [[%query [~ [%from object=[%table-set object=[%qualified-object ship=~ database='db1' namespace='dbo' name='adoptions'] alias=[~ 'T1']] joins=~[[%joined-object join=%join object=[%table-set object=[%qualified-object ship=~ database='db1' namespace='dbo' name='adoptions'] alias=[~ 'T2']] predicate=`joinpred]]]] scalars=~ `pred group-by=~ having=~ select-all-columns ~] ~ ~]]
  %+  expect-eq
    !>  ~[expected]
    !>  (parse:parse(default-database 'db1') query)
++  test-predicate-15
  =/  query  "FROM adoptions AS T1 JOIN adoptions AS T2 ON T1.foo = T2.bar ".
    " WHERE foobar between foo  And bar ".
    " SELECT *"
  =/  joinpred=(tree predicate-component:ast)  [%eq t1-foo t2-bar]
  =/  pred=(tree predicate-component:ast)      [%between foobar-gte-foo foobar-lte-bar]
  =/  expected
    [%transform ctes=~ [[%query [~ [%from object=[%table-set object=[%qualified-object ship=~ database='db1' namespace='dbo' name='adoptions'] alias=[~ 'T1']] joins=~[[%joined-object join=%join object=[%table-set object=[%qualified-object ship=~ database='db1' namespace='dbo' name='adoptions'] alias=[~ 'T2']] predicate=`joinpred]]]] scalars=~ `pred group-by=~ having=~ select-all-columns ~] ~ ~]]
  %+  expect-eq
    !>  ~[expected]
    !>  (parse:parse(default-database 'db1') query)
++  test-predicate-16
  =/  query  "FROM adoptions AS T1 JOIN adoptions AS T2 ON T1.foo = T2.bar ".
    " WHERE T1.foo>=aLl bar ".
    " SELECT *"
  =/  joinpred=(tree predicate-component:ast)  [%eq t1-foo t2-bar]
  =/  pred=(tree predicate-component:ast)      [%gte t1-foo [%all bar ~]]
  =/  expected
    [%transform ctes=~ [[%query [~ [%from object=[%table-set object=[%qualified-object ship=~ database='db1' namespace='dbo' name='adoptions'] alias=[~ 'T1']] joins=~[[%joined-object join=%join object=[%table-set object=[%qualified-object ship=~ database='db1' namespace='dbo' name='adoptions'] alias=[~ 'T2']] predicate=`joinpred]]]] scalars=~ `pred group-by=~ having=~ select-all-columns ~] ~ ~]]
  %+  expect-eq
    !>  ~[expected]
    !>  (parse:parse(default-database 'db1') query)
++  test-predicate-17
  =/  query  "FROM adoptions AS T1 JOIN adoptions AS T2 ON T1.foo = T2.bar ".
    " WHERE T1.foo nOt In bar ".
    " SELECT *"
  =/  joinpred=(tree predicate-component:ast)  [%eq t1-foo t2-bar]
  =/  pred=(tree predicate-component:ast)      [%not-in t1-foo bar]
  =/  expected
    [%transform ctes=~ [[%query [~ [%from object=[%table-set object=[%qualified-object ship=~ database='db1' namespace='dbo' name='adoptions'] alias=[~ 'T1']] joins=~[[%joined-object join=%join object=[%table-set object=[%qualified-object ship=~ database='db1' namespace='dbo' name='adoptions'] alias=[~ 'T2']] predicate=`joinpred]]]] scalars=~ `pred group-by=~ having=~ select-all-columns ~] ~ ~]]
  %+  expect-eq
    !>  ~[expected]
    !>  (parse:parse(default-database 'db1') query)
++  test-predicate-18
  =/  query  "FROM adoptions AS T1 JOIN adoptions AS T2 ON T1.foo = T2.bar ".
    " WHERE T1.foo not in (1,2,3) ".
    " SELECT *"
  =/  joinpred=(tree predicate-component:ast)  [%eq t1-foo t2-bar]
  =/  pred=(tree predicate-component:ast)      [%not-in t1-foo value-literals]
  =/  expected
    [%transform ctes=~ [[%query [~ [%from object=[%table-set object=[%qualified-object ship=~ database='db1' namespace='dbo' name='adoptions'] alias=[~ 'T1']] joins=~[[%joined-object join=%join object=[%table-set object=[%qualified-object ship=~ database='db1' namespace='dbo' name='adoptions'] alias=[~ 'T2']] predicate=`joinpred]]]] scalars=~ `pred group-by=~ having=~ select-all-columns ~] ~ ~]]
  %+  expect-eq
    !>  ~[expected]
    !>  (parse:parse(default-database 'db1') query)
++  test-predicate-19
  =/  query  "FROM adoptions AS T1 JOIN adoptions AS T2 ON T1.foo = T2.bar ".
    " WHERE T1.foo in bar ".
    " SELECT *"
  =/  joinpred=(tree predicate-component:ast)  [%eq t1-foo t2-bar]
  =/  pred=(tree predicate-component:ast)      [%in t1-foo bar]
  =/  expected
    [%transform ctes=~ [[%query [~ [%from object=[%table-set object=[%qualified-object ship=~ database='db1' namespace='dbo' name='adoptions'] alias=[~ 'T1']] joins=~[[%joined-object join=%join object=[%table-set object=[%qualified-object ship=~ database='db1' namespace='dbo' name='adoptions'] alias=[~ 'T2']] predicate=`joinpred]]]] scalars=~ `pred group-by=~ having=~ select-all-columns ~] ~ ~]]
  %+  expect-eq
    !>  ~[expected]
    !>  (parse:parse(default-database 'db1') query)
++  test-predicate-20
  =/  query  "FROM adoptions AS T1 JOIN adoptions AS T2 ON T1.foo = T2.bar ".
    " WHERE T1.foo in (1,2,3) ".
    " SELECT *"
  =/  joinpred=(tree predicate-component:ast)  [%eq t1-foo t2-bar]
  =/  pred=(tree predicate-component:ast)      [%in t1-foo value-literals]
  =/  expected
    [%transform ctes=~ [[%query [~ [%from object=[%table-set object=[%qualified-object ship=~ database='db1' namespace='dbo' name='adoptions'] alias=[~ 'T1']] joins=~[[%joined-object join=%join object=[%table-set object=[%qualified-object ship=~ database='db1' namespace='dbo' name='adoptions'] alias=[~ 'T2']] predicate=`joinpred]]]] scalars=~ `pred group-by=~ having=~ select-all-columns ~] ~ ~]]
  %+  expect-eq
    !>  ~[expected]
    !>  (parse:parse(default-database 'db1') query)
++  test-predicate-21
  =/  query  "FROM adoptions AS T1 JOIN adoptions AS T2 ON T1.foo = T2.bar ".
    " WHERE NOT  EXISTS  T1.foo ".
    " SELECT *"
  =/  joinpred=(tree predicate-component:ast)  [%eq t1-foo t2-bar]
  =/  pred=(tree predicate-component:ast)      [%not-exists t1-foo ~]
  =/  expected
    [%transform ctes=~ [[%query [~ [%from object=[%table-set object=[%qualified-object ship=~ database='db1' namespace='dbo' name='adoptions'] alias=[~ 'T1']] joins=~[[%joined-object join=%join object=[%table-set object=[%qualified-object ship=~ database='db1' namespace='dbo' name='adoptions'] alias=[~ 'T2']] predicate=`joinpred]]]] scalars=~ `pred group-by=~ having=~ select-all-columns ~] ~ ~]]
  %+  expect-eq
    !>  ~[expected]
    !>  (parse:parse(default-database 'db1') query)
++  test-predicate-22
  =/  query  "FROM adoptions AS T1 JOIN adoptions AS T2 ON T1.foo = T2.bar ".
    " WHERE NOT  exists  foo ".
    " SELECT *"
  =/  joinpred=(tree predicate-component:ast)  [%eq t1-foo t2-bar]
  =/  pred=(tree predicate-component:ast)      [%not-exists foo ~]
  =/  expected
    [%transform ctes=~ [[%query [~ [%from object=[%table-set object=[%qualified-object ship=~ database='db1' namespace='dbo' name='adoptions'] alias=[~ 'T1']] joins=~[[%joined-object join=%join object=[%table-set object=[%qualified-object ship=~ database='db1' namespace='dbo' name='adoptions'] alias=[~ 'T2']] predicate=`joinpred]]]] scalars=~ `pred group-by=~ having=~ select-all-columns ~] ~ ~]]
  %+  expect-eq
    !>  ~[expected]
    !>  (parse:parse(default-database 'db1') query)
++  test-predicate-23
  =/  query  "FROM adoptions AS T1 JOIN adoptions AS T2 ON T1.foo = T2.bar ".
    " WHERE EXISTS T1.foo ".
    " SELECT *"
  =/  joinpred=(tree predicate-component:ast)  [%eq t1-foo t2-bar]
  =/  pred=(tree predicate-component:ast)      [%exists t1-foo ~]
  =/  expected
    [%transform ctes=~ [[%query [~ [%from object=[%table-set object=[%qualified-object ship=~ database='db1' namespace='dbo' name='adoptions'] alias=[~ 'T1']] joins=~[[%joined-object join=%join object=[%table-set object=[%qualified-object ship=~ database='db1' namespace='dbo' name='adoptions'] alias=[~ 'T2']] predicate=`joinpred]]]] scalars=~ `pred group-by=~ having=~ select-all-columns ~] ~ ~]]
  %+  expect-eq
    !>  ~[expected]
    !>  (parse:parse(default-database 'db1') query)
++  test-predicate-24
  =/  query  "FROM adoptions AS T1 JOIN adoptions AS T2 ON T1.foo = T2.bar ".
    " WHERE EXISTS  foo ".
    " SELECT *"
  =/  joinpred=(tree predicate-component:ast)  [%eq t1-foo t2-bar]
  =/  pred=(tree predicate-component:ast)      [%exists foo ~]
  =/  expected
    [%transform ctes=~ [[%query [~ [%from object=[%table-set object=[%qualified-object ship=~ database='db1' namespace='dbo' name='adoptions'] alias=[~ 'T1']] joins=~[[%joined-object join=%join object=[%table-set object=[%qualified-object ship=~ database='db1' namespace='dbo' name='adoptions'] alias=[~ 'T2']] predicate=`joinpred]]]] scalars=~ `pred group-by=~ having=~ select-all-columns ~] ~ ~]]
  %+  expect-eq
    !>  ~[expected]
    !>  (parse:parse(default-database 'db1') query)
::
::  test conjunctions, varying spacing and keyword casing
++  test-predicate-25
  =/  query  "FROM adoptions AS T1 JOIN adoptions AS T2 ON T1.foo = T2.bar ".
    " WHERE foobar >=foo And foobar<=bar ".
    " SELECT *"
  =/  joinpred=(tree predicate-component:ast)  [%eq t1-foo t2-bar]
  =/  pred=(tree predicate-component:ast)      and-fb-gte-f--fb-lte-b
  =/  expected
    [%transform ctes=~ [[%query [~ [%from object=[%table-set object=[%qualified-object ship=~ database='db1' namespace='dbo' name='adoptions'] alias=[~ 'T1']] joins=~[[%joined-object join=%join object=[%table-set object=[%qualified-object ship=~ database='db1' namespace='dbo' name='adoptions'] alias=[~ 'T2']] predicate=`joinpred]]]] scalars=~ `pred group-by=~ having=~ select-all-columns ~] ~ ~]]
  %+  expect-eq
    !>  ~[expected]
    !>  (parse:parse(default-database 'db1') query)
::
:: expected/actual match
++  test-predicate-26
  =/  query  "FROM adoptions AS T1 JOIN adoptions AS T2 ON T1.foo = T2.bar ".
    " WHERE foobar >=foo And foobar<=bar ".
    " and T1.foo2 = ~zod ".
    " SELECT *"
  =/  joinpred=(tree predicate-component:ast)  [%eq t1-foo t2-bar]
  =/  pred=(tree predicate-component:ast)
        :+  %and
            :+  %and
                [%gte foobar foo]
                [%lte foobar bar]
            :+  %eq
                t1-foo2
                [[%p 0] ~ ~]
  =/  expected
    [%transform ctes=~ [[%query [~ [%from object=[%table-set object=[%qualified-object ship=~ database='db1' namespace='dbo' name='adoptions'] alias=[~ 'T1']] joins=~[[%joined-object join=%join object=[%table-set object=[%qualified-object ship=~ database='db1' namespace='dbo' name='adoptions'] alias=[~ 'T2']] predicate=`joinpred]]]] scalars=~ `pred group-by=~ having=~ select-all-columns ~] ~ ~]]
  %+  expect-eq
    !>  ~[expected]
    !>  (parse:parse(default-database 'db1') query)
::
:: expected/actual match
++  test-predicate-27
  =/  query  "FROM adoptions AS T1 JOIN adoptions AS T2 ON T1.foo = T2.bar ".
    " WHERE foobar >=foo And foobar<=bar ".
    " and T1.foo2 = ~zod ".
    " or T2.bar in (1,2,3)".
    " SELECT *"
  =/  joinpred=(tree predicate-component:ast)  [%eq t1-foo t2-bar]
  =/  pred=(tree predicate-component:ast)      and-and-or
  =/  expected
    [%transform ctes=~ [[%query [~ [%from object=[%table-set object=[%qualified-object ship=~ database='db1' namespace='dbo' name='adoptions'] alias=[~ 'T1']] joins=~[[%joined-object join=%join object=[%table-set object=[%qualified-object ship=~ database='db1' namespace='dbo' name='adoptions'] alias=[~ 'T2']] predicate=`joinpred]]]] scalars=~ `pred group-by=~ having=~ select-all-columns ~] ~ ~]]
  %+  expect-eq
    !>  ~[expected]
    !>  (parse:parse(default-database 'db1') query)
::
:: expected/actual match
++  test-predicate-28
  =/  query  "FROM adoptions AS T1 JOIN adoptions AS T2 ON T1.foo = T2.bar ".
    " WHERE foobar >=foo And foobar<=bar ".
    " and T1.foo2 = ~zod ".
    " or  ".
    " foobar>=foo ".
    " AND   T1.foo2=~zod ".
    " SELECT *"
  =/  joinpred=(tree predicate-component:ast)  [%eq t1-foo t2-bar]
  =/  pred=(tree predicate-component:ast)      and-and-or-and
  =/  expected
    [%transform ctes=~ [[%query [~ [%from object=[%table-set object=[%qualified-object ship=~ database='db1' namespace='dbo' name='adoptions'] alias=[~ 'T1']] joins=~[[%joined-object join=%join object=[%table-set object=[%qualified-object ship=~ database='db1' namespace='dbo' name='adoptions'] alias=[~ 'T2']] predicate=`joinpred]]]] scalars=~ `pred group-by=~ having=~ select-all-columns ~] ~ ~]]
  %+  expect-eq
    !>  ~[expected]
    !>  (parse:parse(default-database 'db1') query)
::
:: expected/actual match
++  test-predicate-29
  =/  query  "FROM adoptions AS T1 JOIN adoptions AS T2 ON T1.foo = T2.bar ".
    " WHERE foobar >=foo And foobar<=bar ".
    " and T1.foo2 = ~zod ".
    " or  ".
    " foobar>=foo ".
    " AND   T1.foo2=~zod ".
    "  OR ".
    " foo = 1 ".
    " AND T1.foo3 < any (1,2,3) ".
    " SELECT *"
  =/  joinpred=(tree predicate-component:ast)  [%eq t1-foo t2-bar]
  =/  pred=(tree predicate-component:ast)      and-and-or-and-or-and
  =/  expected
    [%transform ctes=~ [[%query [~ [%from object=[%table-set object=[%qualified-object ship=~ database='db1' namespace='dbo' name='adoptions'] alias=[~ 'T1']] joins=~[[%joined-object join=%join object=[%table-set object=[%qualified-object ship=~ database='db1' namespace='dbo' name='adoptions'] alias=[~ 'T2']] predicate=`joinpred]]]] scalars=~ `pred group-by=~ having=~ select-all-columns ~] ~ ~]]
  %+  expect-eq
    !>  ~[expected]
    !>  (parse:parse(default-database 'db1') query)
::  
:: simple nesting
++  test-predicate-30
  =/  query  "FROM adoptions AS T1 JOIN adoptions AS T2 ON T1.foo = T2.bar ".
    " WHERE (foobar > foo OR foobar < bar) ".
    " AND T1.foo>foo2 ".
    " AND T2.bar IN (1,2,3) ".
    " AND (T1.foo3< any (1,2,3) OR T1.foo2=~zod AND foo=1 ) ".
    " SELECT *"
  =/  joinpred=(tree predicate-component:ast)  [%eq t1-foo t2-bar]
  =/  pred=(tree predicate-component:ast)
        :+  %and 
            :+  %and 
                :+  %and
                    first-or
                    t1-foo-gt-foo2
                :+  %in
                    t2-bar
                    value-literals
            :+  %or 
                t1-foo3-lt-any-list
                :+  %and
                    t1-foo2-eq-zod
                    foo-eq-1
  =/  expected
    [%transform ctes=~ [[%query [~ [%from object=[%table-set object=[%qualified-object ship=~ database='db1' namespace='dbo' name='adoptions'] alias=[~ 'T1']] joins=~[[%joined-object join=%join object=[%table-set object=[%qualified-object ship=~ database='db1' namespace='dbo' name='adoptions'] alias=[~ 'T2']] predicate=`joinpred]]]] scalars=~ `pred group-by=~ having=~ select-all-columns ~] ~ ~]]
  %+  expect-eq
    !>  ~[expected]
    !>  (parse:parse(default-database 'db1') query)
::
::  nesting
++  test-predicate-31
  =/  query  "FROM adoptions AS T1 JOIN adoptions AS T2 ON T1.foo = T2.bar ".
    " WHERE foobar > foo AND foobar < bar ".
    " AND ( T1.foo>foo2 AND T2.bar IN (1,2,3) ".
    "       OR (T1.foo3< any (1,2,3) AND T1.foo2=~zod AND foo=1 ) ".
    "       OR (foo3=foo4 AND foo5=foo6) ".
    "       OR foo4=foo5 ".
    "      ) ".
    " AND foo6=foo7".
    " SELECT *"
  =/  joinpred=(tree predicate-component:ast)  [%eq t1-foo t2-bar]
  =/  pred=(tree predicate-component:ast)      a-a-l-a-o-l-a-a-r-o-r-a-l-o-r-a
  =/  expected
    [%transform ctes=~ [[%query [~ [%from object=[%table-set object=[%qualified-object ship=~ database='db1' namespace='dbo' name='adoptions'] alias=[~ 'T1']] joins=~[[%joined-object join=%join object=[%table-set object=[%qualified-object ship=~ database='db1' namespace='dbo' name='adoptions'] alias=[~ 'T2']] predicate=`joinpred]]]] scalars=~ `pred group-by=~ having=~ select-all-columns ~] ~ ~]]
  %+  expect-eq
    !>  ~[expected]
    !>  (parse:parse(default-database 'db1') query)
::
::  simple nesting, superfluous () around entire predicate
++  test-predicate-32
  =/  query  "FROM adoptions AS T1 JOIN adoptions AS T2 ON T1.foo = T2.bar ".
    " WHERE ((foobar > foo OR foobar < bar) ".
    " AND T1.foo>foo2 ".
    " AND T2.bar IN (1,2,3) ".
    " AND (T1.foo3< any (1,2,3) OR T1.foo2=~zod AND foo=1 )) ".
    " SELECT *"
  =/  joinpred=(tree predicate-component:ast)  [%eq t1-foo t2-bar]
  =/  pred=(tree predicate-component:ast)      king-and
  =/  expected
    [%transform ctes=~ [[%query [~ [%from object=[%table-set object=[%qualified-object ship=~ database='db1' namespace='dbo' name='adoptions'] alias=[~ 'T1']] joins=~[[%joined-object join=%join object=[%table-set object=[%qualified-object ship=~ database='db1' namespace='dbo' name='adoptions'] alias=[~ 'T2']] predicate=`joinpred]]]] scalars=~ `pred group-by=~ having=~ select-all-columns ~] ~ ~]]
  %+  expect-eq
    !>  ~[expected]
    !>  (parse:parse(default-database 'db1') query)
::
::  aggregate inequality
++  test-predicate-33
  =/  select  "from foo where  count( foobar )  > 10 select * "
  =/  pred=(tree predicate-component:ast)  [%gt [aggregate-count-foobar ~ ~] literal-10]
  %+  expect-eq
    !>  ~[[%transform ctes=~ [[%query from-foo scalars=~ `pred group-by=~ having=~ select-all-columns ~]] ~ ~]]
    !>  (parse:parse(default-database 'db1') select)
::
::  aggregate inequality, no whitespace
++  test-predicate-34
  =/  select  "from foo where count(foobar) > 10 select *"
  =/  pred=(tree predicate-component:ast)  [%gt [aggregate-count-foobar ~ ~] literal-10]
  %+  expect-eq
    !>  ~[[%transform ctes=~ [[%query from-foo scalars=~ `pred group-by=~ having=~ select-all-columns ~]] ~ ~]]
    !>  (parse:parse(default-database 'db1') select)
::
::  aggregate equality
++  test-predicate-35
  =/  select  "from foo where bar = count(foobar) select *"
  =/  pred=(tree predicate-component:ast)  [%eq bar [aggregate-count-foobar ~ ~]]
  %+  expect-eq
    !>  ~[[%transform ctes=~ [[%query from-foo scalars=~ `pred group-by=~ having=~ select-all-columns ~]] ~ ~]]
    !>  (parse:parse(default-database 'db1') select)
::
::  complext predicate, bug test
++  test-predicate-36
  =/  query  "FROM adoptions AS T1 JOIN adoptions AS T2 ON T1.foo = T2.bar ".
    " WHERE  A1.adoption-email = A2.adoption-email  ".
    "  AND     A1.adoption-date = A2.adoption-date  ".
    "  AND    foo = bar  ".
    "  AND ((A1.name = A2.name AND A1.species > A2.species) ".
    "       OR ".
    "       (A1.name > A2.name AND A1.species = A2.species) ".
    "       OR ".
    "      (A1.name > A2.name AND A1.species > A2.species) ".
    "     ) ".
    " SELECT *"
  =/  joinpred=(tree predicate-component:ast)  [%eq t1-foo t2-bar]
  =/  pred=(tree predicate-component:ast)
    [%and [%and [%and [%eq a1-adoption-email a2-adoption-email] [%eq a1-adoption-date a2-adoption-date]] [%eq foo bar]] [%or [%or [%and [%eq a1-name a2-name] [%gt a1-species a2-species]] [%and [%gt a1-name a2-name] [%eq a1-species a2-species]]] [%and [%gt a1-name a2-name] [%gt a1-species a2-species]]]]
  =/  expected
    [%transform ctes=~ [[%query [~ [%from object=[%table-set object=[%qualified-object ship=~ database='db1' namespace='dbo' name='adoptions'] alias=[~ 'T1']] joins=~[[%joined-object join=%join object=[%table-set object=[%qualified-object ship=~ database='db1' namespace='dbo' name='adoptions'] alias=[~ 'T2']] predicate=`joinpred]]]] scalars=~ `pred group-by=~ having=~ select-all-columns ~] ~ ~]]
  %+  expect-eq
    !>  ~[expected]
    !>  (parse:parse(default-database 'db1') query)
::
::  outer parens
++  test-predicate-37
  =/  query  "FROM adoptions AS T1 JOIN adoptions AS T2 ON (T1.foo = T2.bar) SELECT *"
  =/  pred=(tree predicate-component:ast)  [%eq t1-foo t2-bar]
  =/  expected
    [%transform ctes=~ [[%query [~ [%from object=[%table-set object=[%qualified-object ship=~ database='db1' namespace='dbo' name='adoptions'] alias=[~ 'T1']] joins=~[[%joined-object join=%join object=[%table-set object=[%qualified-object ship=~ database='db1' namespace='dbo' name='adoptions'] alias=[~ 'T2']] predicate=`pred]]]] scalars=~ ~ group-by=~ having=~ select-all-columns ~] ~ ~]]
  %+  expect-eq
    !>  ~[expected]
    !>  (parse:parse(default-database 'db1') query)
::
::  scalar
::
++  column-foo       [%qualified-column qualifier=[%qualified-object ship=~ database='UNKNOWN' namespace='COLUMN-OR-CTE' name='foo'] column='foo' alias=~]
++  column-foo2      [%qualified-column qualifier=[%qualified-object ship=~ database='UNKNOWN' namespace='COLUMN-OR-CTE' name='foo2'] column='foo2' alias=~]
++  column-foo3      [%qualified-column qualifier=[%qualified-object ship=~ database='UNKNOWN' namespace='COLUMN-OR-CTE' name='foo3'] column='foo3' alias=~]
++  column-bar       [%qualified-column qualifier=[%qualified-object ship=~ database='UNKNOWN' namespace='COLUMN-OR-CTE' name='bar'] column='bar' alias=~]
++  literal-zod      [value-type=%p value=0]
++  literal-1        [value-type=%ud value=1]
++  naked-coalesce   ~[%coalesce column-bar literal-zod literal-1 column-foo]
++  simple-coalesce  [[%scalar %foobar] naked-coalesce]
++  simple-if-naked  [%if [%eq [literal-1 0 0] literal-1 0 0] %then column-foo %else column-bar %endif]
++  simple-if        [[%scalar %foobar] simple-if-naked]
++  case-predicate   [%when [%eq [literal-1 0 0] literal-1 0 0] %then column-foo]
++  case-datum       [%when column-foo2 %then column-foo]
++  case-coalesce    [%when column-foo3 %then naked-coalesce]
++  case-1           [[%scalar %foobar] [%case column-foo3 ~[case-predicate] %else column-bar %end]]
++  case-2           [[%scalar %foobar] [%case column-foo3 ~[case-datum] %else column-bar %end]]
++  case-3           [[%scalar %foobar] [%case column-foo3 ~[case-datum case-predicate] %else column-bar %end]]
++  case-4           [[%scalar %foobar] [%case column-foo3 ~[case-datum case-predicate] %else simple-if-naked %end]]
++  case-5           [[%scalar %foobar] [%case column-foo3 ~[case-datum case-predicate case-coalesce] %else simple-if-naked %end]]
++  case-aggregate   [[%scalar %foobar] [%case [%qualified-column [%qualified-object 0 'UNKNOWN' 'COLUMN-OR-CTE' %foo3] %foo3 0] [[%when [%qualified-column [%qualified-object 0 'UNKNOWN' 'COLUMN-OR-CTE' %foo2] %foo2 0] %then %aggregate %count %qualified-column [%qualified-object 0 'UNKNOWN' 'COLUMN-OR-CTE' %foo] %foo 0] 0] %else [%aggregate %count %qualified-column [%qualified-object 0 'UNKNOWN' 'COLUMN-OR-CTE' %foo] %foo 0] %end]]
::  coalesce
::++  test-scalar-01
::  =/  scalar  "SCALAR foobar COALESCE bar,~zod,1,foo"
::  %+  expect-eq
::    !>  simple-coalesce
::    !>  (wonk (parse-scalar:parse [[1 1] scalar]))
::
::  coalesce as
::++  test-scalar-02
::  =/  scalar  "SCALAR foobar AS COALESCE bar,~zod,1,foo"
::  %+  expect-eq
::    !>  simple-coalesce
::    !>  (wonk (parse-scalar:parse [[1 1] scalar]))
::
::  simple if
::++  test-scalar-03
::  =/  scalar  "SCALAR foobar IF 1 = 1 THEN foo ELSE bar ENDIF"
::  %+  expect-eq
::    !>  simple-if
::    !>  (wonk (parse-scalar:parse [[1 1] scalar]))
::
::  simple if as
::++  test-scalar-04
::  =/  scalar  "SCALAR foobar AS IF 1 = 1 THEN foo ELSE bar ENDIF"
::  %+  expect-eq
::    !>  simple-if
::    !>  (wonk (parse-scalar:parse [[1 1] scalar]))
::
::  simple case with predicate
::++  test-scalar-05
::  =/  scalar  "SCALAR foobar CASE foo3 WHEN 1 = 1 THEN foo ELSE bar END"
::  %+  expect-eq
::    !>  case-1
::    !>  (wonk (parse-scalar:parse [[1 1] scalar]))
::
::  simple case AS with datum
::++  test-scalar-06
::  =/  scalar  "SCALAR foobar AS CASE foo3 WHEN foo2 THEN foo ELSE bar END"
::  %+  expect-eq
::    !>  case-2
::    !>  (wonk (parse-scalar:parse [[1 1] scalar]))
::
::  simple case, 2 whens
::++  test-scalar-07
::  =/  scalar  "SCALAR foobar AS CASE foo3 WHEN foo2 THEN foo WHEN 1 = 1 THEN foo ELSE bar END"
::  %+  expect-eq
::    !>  case-3
::    !>  (wonk (parse-scalar:parse [[1 1] scalar]))
::
::  2 whens, embedded if for else
::++  test-scalar-08
::  =/  scalar  "SCALAR foobar AS CASE foo3 ".
::" WHEN foo2 THEN foo WHEN 1 = 1 THEN foo ".
::" ELSE IF 1 = 1 THEN foo ELSE bar ENDIF END"
::  %+  expect-eq
::    !>  case-4
::    !>  (wonk (parse-scalar:parse [[1 1] scalar]))
::
::  3 whens, coalesce, embedded if for else
::++  test-scalar-09
::  =/  scalar  "SCALAR foobar AS CASE foo3 ".
::" WHEN foo2 THEN foo ".
::" WHEN 1 = 1 THEN foo ".
::" WHEN foo3 THEN COALESCE bar,~zod,1,foo ".
::" ELSE IF 1 = 1 THEN foo ELSE bar ENDIF END"
::  %+  expect-eq
::    !>  case-5
::    !>  (wonk (parse-scalar:parse [[1 1] scalar]))
::
::  if aggragate
::++  test-scalar-10
::  =/  scalar  "SCALAR foobar IF count(foo)=1 THEN foo3 else bar ENDIF"
::  %+  expect-eq
::    !>  [[%scalar %foobar] [%if [%eq [aggregate-count-foobar 0 0] literal-1 0 0] %then column-foo3 %else column-bar %endif]]
::    !>  (wonk (parse-scalar:parse [[1 1] scalar]))
::
::  coalesce aggragate
::++  test-scalar-11
::  =/  scalar  "SCALAR foobar AS COALESCE count(foo),~zod,1,foo"
::  %+  expect-eq
::    !>  [[%scalar %foobar] ~[%coalesce aggregate-count-foobar literal-zod literal-1 column-foo]]
::    !>  (wonk (parse-scalar:parse [[1 1] scalar]))
::
::  case aggregate
::++  test-scalar-12
::  =/  scalar  "SCALAR foobar AS CASE foo3 WHEN foo2 THEN count(foo) ELSE count(foo) END"
::  %+  expect-eq
::    !>  case-aggregate
::    !>  (wonk (parse-scalar:parse [[1 1] scalar]))
::
::  select
::
++  simple-columns
  ~[[%qualified-column qualifier=[%qualified-object ship=~ database='UNKNOWN' namespace='COLUMN-OR-CTE' name='x1'] column='x1' alias=~] [%qualified-column qualifier=[%qualified-object ship=~ database='db' namespace='ns' name='table'] column='col1' alias=~] [%qualified-column qualifier=[%qualified-object ship=~ database='UNKNOWN' namespace='COLUMN' name='table-alias'] column='name' alias=~] [%qualified-column qualifier=[%qualified-object ship=~ database='db' namespace='dbo' name='table'] column='col2' alias=~] [%qualified-column qualifier=[%qualified-object ship=~ database='UNKNOWN' namespace='COLUMN' name='T1'] column='foo' alias=~] [%ud 1] [%p 0] [%t 'cord']]
++  aliased-columns-1
  ~[[%qualified-column qualifier=[%qualified-object ship=~ database='UNKNOWN' namespace='COLUMN-OR-CTE' name='x1'] column='x1' alias=[~ 'foo']] [%qualified-column qualifier=[%qualified-object ship=~ database='db' namespace='ns' name='table'] column='col1' alias=[~ 'foo2']] [%qualified-column qualifier=[%qualified-object ship=~ database='UNKNOWN' namespace='COLUMN' name='table-alias'] column='name' alias=[~ 'bar']] [%qualified-column qualifier=[%qualified-object ship=~ database='db' namespace='dbo' name='table'] column='col2' alias=[~ 'bar2']] [%selected-value value=literal-1 alias=[~ %foobar]] [%selected-value value=[value-type=%p value=0] alias=[~ 'f1']] [%selected-value value=[value-type=%t value='cord'] alias=[~ 'bar3']]]
++  mixed-all
  ~[[%qualified-column qualifier=[%qualified-object ship=~ database='db' namespace='dbo' name='t1'] column='ALL' alias=~] [%qualified-column qualifier=[%qualified-object ship=~ database='UNKNOWN' namespace='COLUMN-OR-CTE' name='foo'] column='foo' alias=[~ 'foobar']] column-bar [%qualified-object ship=~ database='ALL' namespace='ALL' name='ALL'] [%qualified-column qualifier=[%qualified-object ship=~ database='UNKNOWN' namespace='COLUMN-OR-CTE' name='T2'] column='ALL' alias=~]]
++  aggregates
  ~[column-foo [%selected-aggregate [%aggregate function='count' source=column-foo] alias=[~ 'CountFoo']] [%selected-aggregate [%aggregate function='count' source=column-bar] alias=~] [%selected-aggregate [%aggregate function='sum' source=column-bar] alias=~] [%selected-aggregate [%aggregate function='sum' source=[%qualified-column qualifier=[%qualified-object ship=~ database='UNKNOWN' namespace='COLUMN-OR-CTE' name='foobar'] column='foobar' alias=~]] alias=[~ 'foobar']]]
::
::  simplest possible select (bunt)
++  test-select-01
  =/  select  "select 0"
  %+  expect-eq
    !>  ~[[%transform ctes=~ [[%query ~ scalars=~ ~ group-by=~ having=~ [%select top=~ bottom=~ columns=~[[%selected-value [value-type=%ud value=0] ~]]] ~] ~ ~]]]
    !>  (parse:parse(default-database 'db1') select)
::
::  star select top, bottom, trailing whitespace
++  test-select-02
  =/  select  "select top 10  bottom 10 * "
  %+  expect-eq
    !>  ~[[%transform ctes=~ [[%query ~ scalars=~ ~ group-by=~ having=~ [%select top=[~ 10] bottom=[~ 10] columns=~[all-columns]] ~] ~ ~]]]
    !>  (parse:parse(default-database 'db1') select)
::
::  star select top, bottom
++  test-select-03
  =/  select  "select top 10  bottom 10 *"
  %+  expect-eq
    !>  ~[[%transform ctes=~ [[%query ~ scalars=~ ~ group-by=~ having=~ [%select top=[~ 10] bottom=[~ 10] columns=~[all-columns]] ~] ~ ~]]]
    !>  (parse:parse(default-database 'db1') select)
::
::  star select top, trailing whitespace
++  test-select-04
  =/  select  "select top 10   * "
  %+  expect-eq
    !>  ~[[%transform ctes=~ [[%query ~ scalars=~ ~ group-by=~ having=~ [%select top=[~ 10] bottom=~ columns=~[all-columns]] ~] ~ ~]]]
    !>  (parse:parse(default-database 'db1') select)
::
::  star select top
++  test-select-05
  =/  select  "select top 10   *"
  %+  expect-eq
    !>  ~[[%transform ctes=~ [[%query ~ scalars=~ ~ group-by=~ having=~ [%select top=[~ 10] bottom=~ columns=~[all-columns]] ~] ~ ~]]]
    !>  (parse:parse(default-database 'db1') select)
::
::  star select, trailing whitespace
++  test-select-06
  =/  select  "select  *       "
  %+  expect-eq
    !>  ~[[%transform ctes=~ [[%query ~ scalars=~ ~ group-by=~ having=~ select-all-columns ~] ~ ~]]]
    !>  (parse:parse(default-database 'db1') select)
::
::  star select
++  test-select-07
  =/  select  "select  *"
  %+  expect-eq
    !>  ~[[%transform ctes=~ [[%query ~ scalars=~ ~ group-by=~ having=~ select-all-columns ~] ~ ~]]]
    !>  (parse:parse(default-database 'db1') select)
::
::  star select bottom, trailing whitespace
++  test-select-08
  =/  select  "select bottom 10 * "
  %+  expect-eq
    !>  ~[[%transform ctes=~ [[%query ~ scalars=~ ~ group-by=~ having=~ [%select top=~ bottom=[~ 10] columns=~[all-columns]] ~] ~ ~]]]
    !>  (parse:parse(default-database 'db1') select)
::
::  star select bottom
++  test-select-09
  =/  select  "select bottom 10 *"
  %+  expect-eq
    !>  ~[[%transform ctes=~ [[%query ~ scalars=~ ~ group-by=~ having=~ [%select top=~ bottom=[~ 10] columns=~[all-columns]] ~] ~ ~]]]
    !>  (parse:parse(default-database 'db1') select)
::
::  select top, bottom, simple columns
++  test-select-10
  =/  select  "select top 10  bottom 10 ".
" x1, db.ns.table.col1, table-alias.name, db..table.col2, T1.foo, 1, ~zod, 'cord'"
  =/  my-columns  ~[[%qualified-column qualifier=[%qualified-object ship=~ database='UNKNOWN' namespace='COLUMN-OR-CTE' name='x1'] column='x1' alias=~] [%qualified-column qualifier=[%qualified-object ship=~ database='db' namespace='ns' name='table'] column='col1' alias=~] [%qualified-column qualifier=[%qualified-object ship=~ database='UNKNOWN' namespace='COLUMN' name='table-alias'] column='name' alias=~] [%qualified-column qualifier=[%qualified-object ship=~ database='db' namespace='dbo' name='table'] column='col2' alias=~] [%qualified-column qualifier=[%qualified-object ship=~ database='UNKNOWN' namespace='COLUMN' name='T1'] column='foo' alias=~] [%selected-value literal-1 ~] [%selected-value [value-type=%p value=0] ~] [%selected-value [value-type=%t value='cord'] ~]]
  %+  expect-eq
    !>  ~[[%transform ctes=~ [[%query ~ scalars=~ ~ group-by=~ having=~ [%select top=[~ 10] bottom=[~ 10] columns=my-columns] ~] ~ ~]]]
    !>  (parse:parse(default-database 'db1') select)
::
::  from foo select top, bottom, simple columns, trailing space, no internal space
++  test-select-11
  =/  select  "from foo select top 10  bottom 10  x1,db.ns.table.col1,table-alias.name,db..table.col2,T1.foo,1,~zod,'cord' "
  =/  from  [~ [%from object=[%table-set object=foo-table alias=~] joins=~]]
  =/  my-columns  ~[[%qualified-column qualifier=[%qualified-object ship=~ database='UNKNOWN' namespace='COLUMN-OR-CTE' name='x1'] column='x1' alias=~] [%qualified-column qualifier=[%qualified-object ship=~ database='db' namespace='ns' name='table'] column='col1' alias=~] [%qualified-column qualifier=[%qualified-object ship=~ database='UNKNOWN' namespace='COLUMN' name='table-alias'] column='name' alias=~] [%qualified-column qualifier=[%qualified-object ship=~ database='db' namespace='dbo' name='table'] column='col2' alias=~] [%qualified-column qualifier=[%qualified-object ship=~ database='UNKNOWN' namespace='COLUMN' name='T1'] column='foo' alias=~] [%selected-value literal-1 ~] [%selected-value [value-type=%p value=0] ~] [%selected-value [value-type=%t value='cord'] ~]]
  %+  expect-eq
    !>  ~[[%transform ctes=~ [[%query from scalars=~ ~ group-by=~ having=~ [%select top=[~ 10] bottom=[~ 10] columns=my-columns] ~] ~ ~]]]
    !>  (parse:parse(default-database 'db1') select)
::
::  aliased format 1 columns
++  test-select-12
  =/  select  "select x1 as foo , db.ns.table.col1 as foo2 , table-alias.name as bar , db..table.col2 as bar2 , 1 as foobar , ~zod as F1 , 'cord' as BAR3 "
  %+  expect-eq
    !>  ~[[%transform ctes=~ [[%query ~ scalars=~ ~ group-by=~ having=~ [%select top=~ bottom=~ columns=aliased-columns-1] ~] ~ ~]]]
    !>  (parse:parse(default-database 'db1') select)
::
::  aliased format 1, top, bottom columns, no whitespace
++  test-select-13
  =/  select  "select  top 10  bottom 10  x1 as foo,db.ns.table.col1 as foo2,table-alias.name as bar,db..table.col2 as bar2,1 as foobar,~zod as F1,'cord' as BAR3"
  %+  expect-eq
    !>  ~[[%transform ctes=~ [[%query ~ scalars=~ ~ group-by=~ having=~ [%select top=[~ 10] bottom=[~ 10] columns=aliased-columns-1] ~] ~ ~]]]
    !>  (parse:parse(default-database 'db1') select)
::
::  mixed all, object all, object alias all, column, aliased column
++  test-select-14
  =/  select  "select db..t1.* , foo as foobar , bar , * , T2.* "
  %+  expect-eq
    !>  ~[[%transform ctes=~ [[%query ~ scalars=~ ~ group-by=~ having=~ [%select top=~ bottom=~ columns=mixed-all] ~] ~ ~]]]
    !>  (parse:parse(default-database 'db1') select)
::
::  , top, bottom, mixed all, object all, object alias all, column, aliased column, no whitespace
++  test-select-15
  =/  select  "select top 10  bottom 10  db..t1.*,foo as foobar,bar,*,T2.*"
  %+  expect-eq
    !>  ~[[%transform ctes=~ [[%query ~ scalars=~ ~ group-by=~ having=~ [%select top=[~ 10] bottom=[~ 10] columns=mixed-all] ~] ~ ~]]]
    !>  (parse:parse(default-database 'db1') select)
::
::  mixed aggregates
++  test-select-16
  =/  select  "select  foo , COUNT(foo) as CountFoo, cOUNT( bar) ,sum(bar ) , sum( foobar ) as foobar "
  %+  expect-eq
    !>  ~[[%transform ctes=~ [[%query ~ scalars=~ ~ group-by=~ having=~ [%select top=~ bottom=~ columns=aggregates] ~] ~ ~]]]
    !>  (parse:parse(default-database 'db1') select)
::
::  , top, bottom, mixed aggregates, no whitespace
++  test-select-17
  =/  select  "select top 10 bottom 10 foo,COUNT(foo) as CountFoo,cOUNT( bar),sum(bar ),sum( foobar ) as foobar"
  %+  expect-eq
    !>  ~[[%transform ctes=~ [[%query ~ scalars=~ ~ group-by=~ having=~ [%select top=[~ 10] bottom=[~ 10] columns=aggregates] ~] ~ ~]]]
    !>  (parse:parse(default-database 'db1') select)
::
:: fail top, bottom, no bottom parameter, trailing whitespace
++  test-fail-select-18
    =/  select  "select top 10  bottom * "
    %-  expect-fail
    |.  (parse:parse(default-database 'db1') select)
::
:: fail top, bottom, no bottom parameter
++  test-fail-select-19
    =/  select  "select top 10  bottom *"
    %-  expect-fail
    |.  (parse:parse(default-database 'db1') select)
::
:: fail top, bottom, no top parameter, trailing whitespace
++  test-fail-select-20
    =/  select  "select top   bottom 10 * "
    %-  expect-fail
    |.  (parse:parse(default-database 'db1') select)
::
:: fail top, bottom, no top parameter
++  test-fail-select-21
    =/  select  "select top   bottom 10 *"
    %-  expect-fail
    |.  (parse:parse(default-database 'db1') select)
::
:: fail top, bottom, no column selection, trailing whitespace
++  test-fail-select-2
    =/  select  "select top 10  bottom 10  "
    %-  expect-fail
    |.  (parse:parse(default-database 'db1') select)
::
:: fail top, bottom, no bottom parameter, trailing whitespace
++  test-fail-select-23
    =/  select  "select top 10  bottom   * "
    %-  expect-fail
    |.  (parse:parse(default-database 'db1') select)
::
:: fail top, bottom, no bottom parameter
++  test-fail-select-24
    =/  select  "select top 10  bottom   *"
    %-  expect-fail
    |.  (parse:parse(default-database 'db1') select)
::
:: fail top, no column selection, trailing whitespace
++  test-fail-select-25
    =/  select  "select top 10    "
    %-  expect-fail
    |.  (parse:parse(default-database 'db1') select)
::
:: fail top, no top parameter, trailing whitespace
++  test-fail-select-26
    =/  select  "select top   * "
    %-  expect-fail
    |.  (parse:parse(default-database 'db1') select)
::
:: fail top, no top parameter
++  test-fail-select-27
    =/  select  "select top   *"
    %-  expect-fail
    |.  (parse:parse(default-database 'db1') select)
::
:: fail no column selection, trailing whitespace
++  test-fail-select-28
    =/  select  "select         "
    %-  expect-fail
    |.  (parse:parse(default-database 'db1') select)
::
:: fail bottom, no bottom parameter, trailing whitespace
++  test-fail-select-29
    =/  select  "select bottom * "
    %-  expect-fail
    |.  (parse:parse(default-database 'db1') select)
::
:: fail bottom, no bottom parameter
++  test-fail-select-30
    =/  select  "select bottom *"
    %-  expect-fail
    |.  (parse:parse(default-database 'db1') select)
::
:: fail bottom, no column selection, trailing whitespace
++  test-fail-select-31
    =/  select  "select bottom 10 "
    %-  expect-fail
    |.  (parse:parse(default-database 'db1') select)
::
:: fail top, bottom, no column selection
++  test-fail-select-32
    =/  select  "select top 10  bottom 10"
    %-  expect-fail
    |.  (parse:parse(default-database 'db1') select)
::
:: fail top, no column selection
++  test-fail-select-33
    =/  select  "select top 10"
    %-  expect-fail
    |.  (parse:parse(default-database 'db1') select)
::
:: fail no column selection
++  test-fail-select-34
    =/  select  "select"
    %-  expect-fail
    |.  (parse:parse(default-database 'db1') select)
::
:: fail bottom, no column selection
++  test-fail-select-35
    =/  select  "select bottom 10"
    %-  expect-fail
    |.  (parse:parse(default-database 'db1') select)
::
::  group and order by
::
++  group-by  ~[[%qualified-column qualifier=[%qualified-object ship=~ database='db' namespace='ns' name='table'] column='col' alias=~] [%qualified-column qualifier=[%qualified-object ship=~ database='UNKNOWN' namespace='COLUMN' name='T1'] column='foo' alias=~] 3 4]
++  order-by  ~[[%ordering-column [%qualified-column qualifier=[%qualified-object ship=~ database='db' namespace='ns' name='table'] column='col' alias=~] is-ascending=%.y] [%ordering-column [%qualified-column qualifier=[%qualified-object ship=~ database='UNKNOWN' namespace='COLUMN' name='T1'] column='foo' alias=~] is-ascending=%.n] [%ordering-column 3 is-ascending=%.y] [%ordering-column 4 is-ascending=%.n]]
::
::  group by
++  test-group-by-01
  =/  select  "from foo group by  db.ns.table.col , T1.foo , 3 , 4 select *"
  %+  expect-eq
    !>  ~[[%transform ctes=~ [[%query from-foo scalars=~ predicate=~ group-by=group-by having=~ selection=select-all-columns ~] ~ ~]]]
    !>  (parse:parse(default-database 'db1') select)
::
::  group by, no whitespace, with predicate
++  test-group-by-02
  =/  pred=(tree predicate-component:ast)  [%eq t1-foo t2-bar]
  =/  select  "from foo where T1.foo = T2.bar group by db.ns.table.col,T1.foo,3,4 select *"
  %+  expect-eq
    !>  ~[[%transform ctes=~ [[%query from-foo scalars=~ predicate=`pred group-by=group-by having=~ selection=select-all-columns ~] ~ ~]]]
    !>  (parse:parse(default-database 'db1') select)
::
::  order by
++  test-order-by-01
  =/  select  "from foo select * order by  db.ns.table.col  asc , T1.foo desc , 3 , 4  desc "
  %+  expect-eq
    !>  ~[[%transform ctes=~ [[%query from-foo scalars=~ predicate=~ group-by=~ having=~ selection=select-all-columns order-by] ~ ~]]]
    !>  (parse:parse(default-database 'db1') select)
::
::  order by, no whitespace
++  test-order-by-02
  =/  select  "from foo select * order by db.ns.table.col aSc,T1.foo desc,3,4 Desc"
  %+  expect-eq
    !>  ~[[%transform ctes=~ [[%query from-foo scalars=~ predicate=~ group-by=~ having=~ selection=select-all-columns order-by] ~ ~]]]
    !>  (parse:parse(default-database 'db1') select)
::
:: update
::
++  one-eq-1
  [%eq [literal-1 ~ ~] [literal-1 ~ ~]]
++  update-pred
  [%and one-eq-1 [%eq [col2 ~ ~] [[value-type=%ud value=4] ~ ~]]]
::
:: update one column, no predicate
++  test-update-00
  %+  expect-eq
    !>  ~[[%transform ctes=~ [[%update table=foo-table columns=~['col1'] values=~[[value-type=%t value='hello']] predicate=~ as-of=~] ~ ~]]]
    !>  (parse:parse(default-database 'db1') "update foo set col1='hello'")
::
:: update one column, no predicate as of now
++  test-update-01
  %+  expect-eq
    !>  ~[[%transform ctes=~ [[%update table=foo-table columns=~['col1'] values=~[[value-type=%t value='hello']] predicate=~ as-of=~] ~ ~]]]
    !>  (parse:parse(default-database 'db1') "update foo set col1='hello' as of now")
::
:: update one column, no predicate as of ~2023.12.25..7.15.0..1ef5
++  test-update-02
  %+  expect-eq
    !>  ~[[%transform ctes=~ [[%update table=foo-table columns=~['col1'] values=~[[value-type=%t value='hello']] predicate=~ as-of=[~ [%da ~2023.12.25..7.15.0..1ef5]]] ~ ~]]]
    !>  (parse:parse(default-database 'db1') "update foo set col1='hello' as of ~2023.12.25..7.15.0..1ef5")
::
:: update one column, no predicate as of 4 seconds ago
++  test-update-03
  %+  expect-eq
    !>  ~[[%transform ctes=~ [[%update table=foo-table columns=~['col1'] values=~[[value-type=%t value='hello']] predicate=~ as-of=[~ [%as-of-offset 4 %seconds]]] ~ ~]]]
    !>  (parse:parse(default-database 'db1') "update foo set col1='hello' as of 4 seconds ago")
::
:: update two columns, no predicate
++  test-update-04
  %+  expect-eq
    !>  ~[[%transform ctes=~ [[%update table=foo-table columns=~['col3' 'col1'] values=~[[value-type=%t value='hello'] col2] predicate=~ as-of=~] ~ ~]]]
    !>  (parse:parse(default-database 'db1') "update foo set col1=col2, col3 = 'hello'")
::
:: update two columns, no predicate as of now
++  test-update-05
  %+  expect-eq
    !>  ~[[%transform ctes=~ [[%update table=foo-table columns=~['col3' 'col1'] values=~[[value-type=%t value='hello'] col2] predicate=~ as-of=~] ~ ~]]]
    !>  (parse:parse(default-database 'db1') "update foo set col1=col2, col3 = 'hello' as of now")
::
:: update two columns, no predicate as of ~2023.12.25..7.15.0..1ef5
++  test-update-06
  %+  expect-eq
    !>  ~[[%transform ctes=~ [[%update table=foo-table columns=~['col3' 'col1'] values=~[[value-type=%t value='hello'] col2] predicate=~ as-of=[~ [%da ~2023.12.25..7.15.0..1ef5]]] ~ ~]]]
    !>  (parse:parse(default-database 'db1') "update foo set col1=col2, col3 = 'hello' as of ~2023.12.25..7.15.0..1ef5")
::
:: update two columns, no predicate as of 4 seconds ago
++  test-update-07
  %+  expect-eq
    !>  ~[[%transform ctes=~ [[%update table=foo-table columns=~['col3' 'col1'] values=~[[value-type=%t value='hello'] col2] predicate=~ as-of=[~ [%as-of-offset 4 %seconds]]] ~ ~]]]
    !>  (parse:parse(default-database 'db1') "update foo set col1=col2, col3 = 'hello' as of 4 seconds ago")
::
:: update two columns, with predicate
++  test-update-08
  %+  expect-eq
    !>  ~[[%transform ctes=~ [[%update table=foo-table columns=~['col3' 'col1'] values=~[[value-type=%t value='hello'] col2] predicate=`update-pred as-of=~] ~ ~]]]
    !>  (parse:parse(default-database 'db1') "update foo set col1=col2, col3 = 'hello' where 1 = 1 and col2 = 4")
::
:: update two columns, with predicate as of now
++  test-update-09
  %+  expect-eq
    !>  ~[[%transform ctes=~ [[%update table=foo-table columns=~['col3' 'col1'] values=~[[value-type=%t value='hello'] col2] predicate=`update-pred as-of=~] ~ ~]]]
    !>  (parse:parse(default-database 'db1') "update foo set col1=col2, col3 = 'hello' where 1 = 1 and col2 = 4 as of now")
::
:: update two columns, with predicate as of ~2023.12.25..7.15.0..1ef5
++  test-update-10
  %+  expect-eq
    !>  ~[[%transform ctes=~ [[%update table=foo-table columns=~['col3' 'col1'] values=~[[value-type=%t value='hello'] col2] predicate=`update-pred as-of=[~ [%da ~2023.12.25..7.15.0..1ef5]]] ~ ~]]]
    !>  (parse:parse(default-database 'db1') "update foo set col1=col2, col3 = 'hello' where 1 = 1 and col2 = 4 as of ~2023.12.25..7.15.0..1ef5")
::
:: update two columns, with predicate as of 4 seconds ago
++  test-update-11
  %+  expect-eq
    !>  ~[[%transform ctes=~ [[%update table=foo-table columns=~['col3' 'col1'] values=~[[value-type=%t value='hello'] col2] predicate=`update-pred as-of=[~ [%as-of-offset 4 %seconds]]] ~ ~]]]
    !>  (parse:parse(default-database 'db1') "update foo set col1=col2, col3 = 'hello' where 1 = 1 and col2 = 4 as of 4 seconds ago")
::
:: update with one cte and predicate
++  test-update-12
  %+  expect-eq
    !>  ~[[%transform ctes=~[cte-t1] [[%update table=foo-table columns=~['col3' 'col1'] values=~[[value-type=%t value='hello'] col2] predicate=`update-pred as-of=~] ~ ~]]]
    !>  (parse:parse(default-database 'db1') "with (select *) as t1 update foo set col1=col2, col3 = 'hello' where 1 = 1 and col2 = 4")
::
:: update with one cte and predicate as of now
++  test-update-13
  %+  expect-eq
    !>  ~[[%transform ctes=~[cte-t1] [[%update table=foo-table columns=~['col3' 'col1'] values=~[[value-type=%t value='hello'] col2] predicate=`update-pred as-of=~] ~ ~]]]
    !>  (parse:parse(default-database 'db1') "with (select *) as t1 update foo set col1=col2, col3 = 'hello' where 1 = 1 and col2 = 4 as of now")
::
:: update with one cte and predicate as of ~2023.12.25..7.15.0..1ef5
++  test-update-14
  %+  expect-eq
    !>  ~[[%transform ctes=~[cte-t1] [[%update table=foo-table columns=~['col3' 'col1'] values=~[[value-type=%t value='hello'] col2] predicate=`update-pred as-of=[~ [%da ~2023.12.25..7.15.0..1ef5]]] ~ ~]]]
    !>  (parse:parse(default-database 'db1') "with (select *) as t1 update foo set col1=col2, col3 = 'hello' where 1 = 1 and col2 = 4 as of ~2023.12.25..7.15.0..1ef5")
::
:: update with one cte and predicate as of 4 seconds ago
++  test-update-15
  %+  expect-eq
    !>  ~[[%transform ctes=~[cte-t1] [[%update table=foo-table columns=~['col3' 'col1'] values=~[[value-type=%t value='hello'] col2] predicate=`update-pred as-of=[~ [%as-of-offset 4 %seconds]]] ~ ~]]]
    !>  (parse:parse(default-database 'db1') "with (select *) as t1 update foo set col1=col2, col3 = 'hello' where 1 = 1 and col2 = 4 as of 4 seconds ago")
::
:: update with three ctes and predicate
++  test-update-16
  %+  expect-eq
    !>  ~[[%transform ctes=~[cte-t1 cte-foobar cte-bar] [[%update table=foo-table columns=~['col3' 'col1'] values=~[[value-type=%t value='hello'] col2] predicate=`update-pred as-of=~] ~ ~]]]
    !>  (parse:parse(default-database 'db1') "with (select *) as t1, (from foobar where col1=2 select col3, col4) as foobar, (from bar where col1=col2 select col2) as bar update foo set col1=col2, col3 = 'hello' where 1 = 1 and col2 = 4")
::
:: update with three ctes and predicate as of now
++  test-update-17
  %+  expect-eq
    !>  ~[[%transform ctes=~[cte-t1 cte-foobar cte-bar] [[%update table=foo-table columns=~['col3' 'col1'] values=~[[value-type=%t value='hello'] col2] predicate=`update-pred as-of=~] ~ ~]]]
    !>  (parse:parse(default-database 'db1') "with (select *) as t1, (from foobar where col1=2 select col3, col4) as foobar, (from bar where col1=col2 select col2) as bar update foo set col1=col2, col3 = 'hello' where 1 = 1 and col2 = 4 as of now")
::
:: update with three ctes and predicate as of ~2023.12.25..7.15.0..1ef5
++  test-update-18
  %+  expect-eq
    !>  ~[[%transform ctes=~[cte-t1 cte-foobar cte-bar] [[%update table=foo-table columns=~['col3' 'col1'] values=~[[value-type=%t value='hello'] col2] predicate=`update-pred as-of=[~ [%da ~2023.12.25..7.15.0..1ef5]]] ~ ~]]]
    !>  (parse:parse(default-database 'db1') "with (select *) as t1, (from foobar where col1=2 select col3, col4) as foobar, (from bar where col1=col2 select col2) as bar update foo set col1=col2, col3 = 'hello' where 1 = 1 and col2 = 4 as of ~2023.12.25..7.15.0..1ef5")
::
:: update with three ctes and predicate as of 4 seconds ago
++  test-update-19
  %+  expect-eq
    !>  ~[[%transform ctes=~[cte-t1 cte-foobar cte-bar] [[%update table=foo-table columns=~['col3' 'col1'] values=~[[value-type=%t value='hello'] col2] predicate=`update-pred as-of=[~ [%as-of-offset 4 %seconds]]] ~ ~]]]
    !>  (parse:parse(default-database 'db1') "with (select *) as t1, (from foobar where col1=2 select col3, col4) as foobar, (from bar where col1=col2 select col2) as bar update foo set col1=col2, col3 = 'hello' where 1 = 1 and col2 = 4 as of 4 seconds ago")
::
:: fail update cte with no predicate
::++  test-fail-update-06
::  %-  expect-fail
::  |.  (parse:parse(default-database 'other-db') "with (select *) as t1 update foo set col1=col2, col3 = 'hello' ")
::
:: merge
::
++  predicate-bar-eq-bar
  [%eq [[%qualified-column qualifier=[%qualified-object ship=~ database='UNKNOWN' namespace='COLUMN' name='tgt'] column='bar' alias=~] ~ ~] [[%qualified-column qualifier=[%qualified-object ship=~ database='UNKNOWN' namespace='COLUMN' name='src'] column='bar' alias=~] ~ ~]]
++  cte-bar-foobar
  [%cte name='T1' %query from=~ scalars=~ predicate=~ group-by=~ having=~ selection=[%select top=~ bottom=~ columns=~[[%qualified-column qualifier=[%qualified-object ship=~ database='UNKNOWN' namespace='COLUMN-OR-CTE' name='bar'] column='bar' alias=~] [%qualified-column qualifier=[%qualified-object ship=~ database='UNKNOWN' namespace='COLUMN-OR-CTE' name='foobar'] column='foobar' alias=~]]] order-by=~]
++  cte-bar-foobar-src
  [%cte name='src' %query from=~ scalars=~ predicate=~ group-by=~ having=~ selection=[%select top=~ bottom=~ columns=~[[%qualified-column qualifier=[%qualified-object ship=~ database='UNKNOWN' namespace='COLUMN-OR-CTE' name='bar'] column='bar' alias=~] [%qualified-column qualifier=[%qualified-object ship=~ database='UNKNOWN' namespace='COLUMN-OR-CTE' name='foobar'] column='foobar' alias=~]]] order-by=~]
++  column-src-foo
  [%qualified-column qualifier=[%qualified-object ship=~ database='UNKNOWN' namespace='COLUMN' name='src'] column='foo' alias=~]
++  column-src-bar
  [%qualified-column qualifier=[%qualified-object ship=~ database='UNKNOWN' namespace='COLUMN' name='src'] column='bar' alias=~]
++  column-src-foobar
  [%qualified-column qualifier=[%qualified-object ship=~ database='UNKNOWN' namespace='COLUMN' name='src'] column='foobar' alias=~]
++  passthru-tgt
  [%table-set object=[%query-row ~['col1' 'col2' 'col3']] alias=[~ 'tgt']]
++  passthru-src
  [%table-set object=[%query-row ~['col1' 'col2' 'col3']] alias=[~ 'src']]
::
::
++  test-merge-01
  =/  query  " WITH (SELECT bar, foobar) as T1 ".
" MERGE INTO dbo.foo AS tgt ".
" USING T1 AS src ".
" ON (tgt.bar = src.bar) ".
" WHEN MATCHED THEN ".
"    UPDATE SET foobar = src.foo "
  =/  expected  
    [%transform ctes=~[cte-bar-foobar] [[%merge target-table=[%table-set object=[%qualified-object ship=~ database='db1' namespace='dbo' name='foo'] alias=[~ 'tgt']] new-table=~ source-table=[%table-set object=[%qualified-object ship=~ database='UNKNOWN' namespace='COLUMN-OR-CTE' name='T1'] alias=[~ 'src']] predicate=predicate-bar-eq-bar matched=~[[%matching predicate=~ matching-profile=[%update ~[['foobar' column-src-foo]]]]] unmatched-by-target=~ unmatched-by-source=~ as-of=~] ~ ~]]
  %+  expect-eq
    !>  ~[expected]
    !>  (parse:parse(default-database 'db1') query)
::
::
++  test-merge-02
  =/  query  " WITH (SELECT bar, foobar) as T1 ".
" MERGE INTO dbo.foo AS tgt ".
" USING T1 AS src ".
" ON (tgt.bar = src.bar) ".
" WHEN MATCHED THEN ".
"    UPDATE SET foobar = src.foo, ".
"    bar = bar "
  =/  expected  
    [%transform ctes=~[cte-bar-foobar] [[%merge target-table=[%table-set object=[%qualified-object ship=~ database='db1' namespace='dbo' name='foo'] alias=[~ 'tgt']] new-table=~ source-table=[%table-set object=[%qualified-object ship=~ database='UNKNOWN' namespace='COLUMN-OR-CTE' name='T1'] alias=[~ 'src']] predicate=predicate-bar-eq-bar matched=~[[%matching predicate=~ matching-profile=[%update ~[['foobar' column-src-foo] ['bar' column-bar]]]]] unmatched-by-target=~ unmatched-by-source=~ as-of=~] ~ ~]]
  %+  expect-eq
    !>  ~[expected]
    !>  (parse:parse(default-database 'db1') query)
::
::
++  test-merge-03
  =/  query  "WITH (SELECT bar, foobar) as src ".
" MERGE dbo.foo ".
" USING src ".
" ON (tgt.bar = src.bar) ".
" WHEN MATCHED AND 1 = 1 THEN ".
"    UPDATE SET foobar = src.foobar ".
" WHEN NOT MATCHED THEN ".
"    INSERT (bar, foobar) ".
"    VALUES (src.bar, 99)"
  =/  expected  
    [%transform ctes=~[cte-bar-foobar-src] [[%merge target-table=[%table-set object=[%qualified-object ship=~ database='db1' namespace='dbo' name='foo'] alias=~] new-table=~ source-table=[%table-set object=[%qualified-object ship=~ database='db1' namespace='dbo' name='src'] alias=~] predicate=predicate-bar-eq-bar matched=~[[%matching predicate=`one-eq-1 matching-profile=[%update ~[['foobar' column-src-foobar]]]]] unmatched-by-target=~[[%matching predicate=~ matching-profile=[%insert ~[['bar' column-src-bar] ['foobar' [value-type=%ud value=99]]]]]] unmatched-by-source=~ as-of=~] ~ ~]]
  %+  expect-eq
    !>  ~[expected]
    !>  (parse:parse(default-database 'db1') query)
::
:: merge target passthru alias AS
++  test-merge-04
  =/  query  "WITH (SELECT bar, foobar) as T1 ".
" MERGE INTO (col1,col2,col3) AS tgt ".
" USING T1 AS src ".
" ON (tgt.bar = src.bar) ".
" WHEN MATCHED THEN ".
"    UPDATE SET foobar = src.foo "
  =/  expected  
    [%transform ctes=~[cte-bar-foobar] [[%merge target-table=passthru-tgt new-table=~ source-table=[%table-set object=[%qualified-object ship=~ database='UNKNOWN' namespace='COLUMN-OR-CTE' name='T1'] alias=[~ 'src']] predicate=predicate-bar-eq-bar matched=~[[%matching predicate=~ matching-profile=[%update ~[['foobar' column-src-foo]]]]] unmatched-by-target=~ unmatched-by-source=~ as-of=~] ~ ~]]
  %+  expect-eq
    !>  ~[expected]
    !>  (parse:parse(default-database 'db1') query)
::
:: merge target passthru alias
++  test-merge-05
  =/  query  "WITH (SELECT bar, foobar) as T1 ".
" MERGE INTO ( col1, col2 , col3) tgt ".
" USING T1 AS src ".
" ON (tgt.bar = src.bar) ".
" WHEN MATCHED THEN ".
"    UPDATE SET foobar = src.foo "
  =/  expected  
    [%transform ctes=~[cte-bar-foobar] [[%merge target-table=passthru-tgt new-table=~ source-table=[%table-set object=[%qualified-object ship=~ database='UNKNOWN' namespace='COLUMN-OR-CTE' name='T1'] alias=[~ 'src']] predicate=predicate-bar-eq-bar matched=~[[%matching predicate=~ matching-profile=[%update ~[['foobar' column-src-foo]]]]] unmatched-by-target=~ unmatched-by-source=~ as-of=~] ~ ~]]
  %+  expect-eq
    !>  ~[expected]
    !>  (parse:parse(default-database 'db1') query)
::
:: merge target passthru unaliased
++  test-merge-06
  =/  query  "WITH (SELECT bar, foobar) as T1 ".
" MERGE INTO (col1, col2 , col3)  ".
" USING T1 AS src ".
" ON (tgt.bar = src.bar) ".
" WHEN MATCHED THEN ".
"    UPDATE SET foobar = src.foo "
  =/  expected
    [%transform ctes=~[cte-bar-foobar] [[%merge target-table=passthru-unaliased new-table=~ source-table=[%table-set object=[%qualified-object ship=~ database='UNKNOWN' namespace='COLUMN-OR-CTE' name='T1'] alias=[~ 'src']] predicate=predicate-bar-eq-bar matched=~[[%matching predicate=~ matching-profile=[%update ~[['foobar' column-src-foo]]]]] unmatched-by-target=~ unmatched-by-source=~ as-of=~] ~ ~]]
  %+  expect-eq
    !>  ~[expected]
    !>  (parse:parse(default-database 'db1') query)
::
::merge source passthru alias AS
++  test-merge-07
  =/  query  "MERGE dbo.foo ".
" USING (col1, col2 , col3) as src ".
" ON (tgt.bar = src.bar) ".
" WHEN MATCHED AND 1 = 1 THEN ".
"    UPDATE SET foobar = src.foobar ".
" WHEN NOT MATCHED THEN ".
"    INSERT (bar, foobar) ".
"    VALUES (src.bar, 99)"
  =/  expected 
    [%transform ctes=~ [[%merge target-table=[%table-set object=[%qualified-object ship=~ database='db1' namespace='dbo' name='foo'] alias=~] new-table=~ source-table=passthru-src predicate=predicate-bar-eq-bar matched=~[[%matching predicate=`one-eq-1 matching-profile=[%update ~[['foobar' column-src-foobar]]]]] unmatched-by-target=~[[%matching predicate=~ matching-profile=[%insert ~[['bar' column-src-bar] ['foobar' [value-type=%ud value=99]]]]]] unmatched-by-source=~ as-of=~] ~ ~]]
  %+  expect-eq
    !>  ~[expected]
    !>  (parse:parse(default-database 'db1') query)
::
::merge source passthru alias AS
++  test-merge-08
  =/  query  "MERGE dbo.foo ".
" USING (col1, col2 , col3) src ".
" ON (tgt.bar = src.bar) ".
" WHEN MATCHED AND 1 = 1 THEN ".
"    UPDATE SET foobar = src.foobar ".
" WHEN NOT MATCHED THEN ".
"    INSERT (bar, foobar) ".
"    VALUES (src.bar, 99)"
  =/  expected
    [%transform ctes=~ [[%merge target-table=[%table-set object=[%qualified-object ship=~ database='db1' namespace='dbo' name='foo'] alias=~] new-table=~ source-table=passthru-src predicate=predicate-bar-eq-bar matched=~[[%matching predicate=`one-eq-1 matching-profile=[%update ~[['foobar' column-src-foobar]]]]] unmatched-by-target=~[[%matching predicate=~ matching-profile=[%insert ~[['bar' column-src-bar] ['foobar' [value-type=%ud value=99]]]]]] unmatched-by-source=~ as-of=~] ~ ~]]
  %+  expect-eq
    !>  ~[expected]
    !>  (parse:parse(default-database 'db1') query)
::
::merge source passthru alias AS
++  test-merge-09
  =/  query  "MERGE dbo.foo ".
" USING (col1, col2 , col3) ".
" ON (tgt.bar = src.bar) ".
" WHEN MATCHED AND 1 = 1 THEN ".
"    UPDATE SET foobar = src.foobar ".
" WHEN NOT MATCHED THEN ".
"    INSERT (bar, foobar) ".
"    VALUES (src.bar, 99)"
  =/  expected
    [%transform ctes=~ [[%merge target-table=[%table-set object=[%qualified-object ship=~ database='db1' namespace='dbo' name='foo'] alias=~] new-table=~ source-table=passthru-unaliased predicate=predicate-bar-eq-bar matched=~[[%matching predicate=`one-eq-1 matching-profile=[%update ~[['foobar' column-src-foobar]]]]] unmatched-by-target=~[[%matching predicate=~ matching-profile=[%insert ~[['bar' column-src-bar] ['foobar' [value-type=%ud value=99]]]]]] unmatched-by-source=~ as-of=~] ~ ~]]
  %+  expect-eq
    !>  ~[expected]
    !>  (parse:parse(default-database 'db1') query)
:: to do: tests for merge to new file
::
:: block comment
::
++  test-block-cmnt-00
  %+  expect-eq
    !>  ~
    !>  %-  parse:parse(default-database 'other-db')  ~
::
++  m-cmnt-1  "/* line1\0a  line2 \0a line3\0a*/"
++  m-cmnt-2  "\0a/* linea\0a  lineb \0a linec \0a*/"
++  m-cmnt-3  "\0a/* linea1 \0a lineb2 \0a linec3 \0a*/"
::
++  test-block-cmnt-01
  %+  expect-eq
    !>  ~
    !>  %-  parse:parse(default-database 'other-db')  %-  zing  ~[m-cmnt-1]
++  test-block-cmnt-02
  =/  expected1  [%create-namespace database-name='other-db' name='ns1' as-of=~]
  =/  expected2  [%create-namespace database-name='db1' name='db1-ns1' as-of=~]
  %+  expect-eq
    !>  ~[expected1 expected2]
    !>  %-  parse:parse(default-database 'other-db') 
            %-  zing 
                %-  limo  :~  m-cmnt-1 
                              "cReate" 
                              m-cmnt-2 
                              "  namespace ns1\0a" 
                              " ; \0a" 
                              "cReate namesPace db1.db1-ns1\0a" 
                              m-cmnt-3
                              ==
++  test-block-cmnt-03
  =/  expected1  [%create-namespace database-name='other-db' name='ns1' as-of=~]
  =/  expected2  [%create-namespace database-name='db1' name='db1-ns1' as-of=~]
  %+  expect-eq
    !>  ~[expected1 expected2]
    !>  %-  parse:parse(default-database 'other-db') 
            %-  zing 
                %-  limo  :~  "cReate\0a" 
                              m-cmnt-1 
                              "  namespace ns1\0a" 
                              m-cmnt-2 
                              " ; \0a" 
                              m-cmnt-3 
                              "cReate namesPace db1.db1-ns1\0a"
                              ==

++  test-block-cmnt-04
  =/  expected1  [%create-namespace database-name='other-db' name='ns1' as-of=~]
  =/  expected2  [%create-namespace database-name='db1' name='db1-ns1' as-of=~]
  %+  expect-eq
    !>  ~[expected1 expected2]
    !>  %-  parse:parse(default-database 'other-db') 
            %-  zing 
                %-  limo  :~  m-cmnt-1 
                              "\0acReate\0a" 
                              "  namespace ns1\0a" 
                              m-cmnt-2 
                              m-cmnt-3 
                              " ; \0a" 
                              "cReate namesPace db1.db1-ns1\0a"
                              ==

++  test-block-cmnt-05
  =/  expected1  [%create-namespace database-name='other-db' name='ns1' as-of=~]
  =/  expected2  [%create-namespace database-name='db1' name='db1-ns1' as-of=~]
  %+  expect-eq
    !>  ~[expected1 expected2]
    !>  %-  parse:parse(default-database 'other-db') 
            %-  zing 
                %-  limo  :~  "cReate\0a" 
                              "  namespace ns1\0a" 
                              m-cmnt-1 
                              " ; \0a" 
                              m-cmnt-2 
                              "cReate namesPace db1.db1-ns1\0a" 
                              m-cmnt-3
                              ==

++  test-block-cmnt-06
  =/  expected1  [%create-namespace database-name='other-db' name='ns1' as-of=~]
  =/  expected2  [%create-namespace database-name='db1' name='db1-ns1' as-of=~]
  %+  expect-eq
    !>  ~[expected1 expected2]
    !>  %-  parse:parse(default-database 'other-db') 
            %-  zing 
                %-  limo  :~  "cReate\0a" 
                              "  namespace ns1\0a" 
                              m-cmnt-1 
                              " ; " 
                              m-cmnt-2 
                              "cReate namesPace db1.db1-ns1" 
                              m-cmnt-3
                              ==
::
++  vfas-tar  [%selected-value value=[p=~.t q=10.799] alias=~]
++  vcol-col  [%selected-value value=[p=~.t q=14.906] alias=~]
++  vtar-fas  [%selected-value value=[p=~.t q=12.074] alias=~]
++  va-fas-tar-a  [%selected-value value=[p=~.t q=539.635.488] alias=~]
++  va-col-col-a  [%selected-value value=[p=~.t q=540.686.880] alias=~]
++  va-tar-fas-a  [%selected-value value=[p=~.t q=539.961.888] alias=~]
::
++  s1  ~[vfas-tar vtar-fas vcol-col va-fas-tar-a va-tar-fas-a va-col-col-a]
++  s2  ~[va-col-col-a vfas-tar vtar-fas vcol-col va-fas-tar-a va-tar-fas-a]
++  s3  ~[va-tar-fas-a va-col-col-a vfas-tar vtar-fas vcol-col va-fas-tar-a]
::
++  q1  [%query from=~ scalars=~ predicate=~ group-by=~ having=~ selection=[%select top=~ bottom=~ columns=s1] order-by=~]
++  q2  [%query from=~ scalars=~ predicate=~ group-by=~ having=~ selection=[%select top=~ bottom=~ columns=s2] order-by=~]
++  q3  [%query from=~ scalars=~ predicate=~ group-by=~ having=~ selection=[%select top=~ bottom=~ columns=s3] order-by=~]
::
++  t1  [%transform ctes=~ set-functions=[q1 ~ ~]]
++  t2  [%transform ctes=~ set-functions=[q2 ~ ~]]
++  t3  [%transform ctes=~ set-functions=[q3 ~ ~]]
::
++  test-block-cmnt-07
  %+  expect-eq
    !>  ~[t1 t2 t3]
    !>  %-  parse:parse(default-database 'other-db') 
            %-  zing 
                %-  limo  :~  "select '\2f\2a', '*\2f', '::', ' \2f\2a ', ' *\2f ', ' :: '\0a" 
                              m-cmnt-1 
                              "select ' :: ', '\2f\2a', '*\2f', '::', ' \2f\2a ', ' *\2f '\0a" 
                              m-cmnt-2 
                              "select ' *\2f ', ' :: ', '\2f\2a', '*\2f', '::', ' \2f\2a '"  
                              m-cmnt-3
                              ==
::
:: line comment
::
++  s1a  ~[vfas-tar vtar-fas]
++  s2a  ~[va-col-col-a vfas-tar vtar-fas]
++  s3a  ~[va-tar-fas-a va-col-col-a vfas-tar vtar-fas]
++  s3b  ~[va-tar-fas-a]
::
++  q1a  [%query from=~ scalars=~ predicate=~ group-by=~ having=~ selection=[%select top=~ bottom=~ columns=s1a] order-by=~]
++  q2a  [%query from=~ scalars=~ predicate=~ group-by=~ having=~ selection=[%select top=~ bottom=~ columns=s2a] order-by=~]
++  q3a  [%query from=~ scalars=~ predicate=~ group-by=~ having=~ selection=[%select top=~ bottom=~ columns=s3a] order-by=~]
++  q3b  [%query from=~ scalars=~ predicate=~ group-by=~ having=~ selection=[%select top=~ bottom=~ columns=s3b] order-by=~]
::
++  t1a  [%transform ctes=~ set-functions=[q1a ~ ~]]
++  t2a  [%transform ctes=~ set-functions=[q2a ~ ~]]
++  t3a  [%transform ctes=~ set-functions=[q3a ~ ~]]
++  t3b  [%transform ctes=~ set-functions=[q3b ~ ~]]
::
++  test-line-cmnt-00
  %+  expect-eq
    !>  ~
    !>  %-  parse:parse(default-database 'other-db')  ~
++  test-line-cmnt-01
  %+  expect-eq
    !>  ~
    !>  %-  parse:parse(default-database 'other-db')  %-  zing  ~["::line cmnt"]
++  test-line-cmnt-02
  %+  expect-eq
    !>  ~[[%create-namespace database-name='db1' name='ns1' as-of=~]]
    !>  (parse:parse(default-database 'db1') "create namespace ns1 \0a::line cmnt")
++  test-line-cmnt-03
  %+  expect-eq
    !>  ~[[%create-namespace database-name='db1' name='ns1' as-of=~]]
    !>  (parse:parse(default-database 'db1') "create namespace ns1 ::line cmnt")
++  test-line-cmnt-04
  %+  expect-eq
    !>  ~[t1a t2 t3]
    !>  %-  parse:parse(default-database 'other-db') 
            %-  zing 
            %-  limo  
            :~  "select '\2f\2a', '*\2f' ::, ' \2f\2a ', ' *\2f ', ' :: '\0a" 
                m-cmnt-1 
                "select ' :: ', '\2f\2a', '*\2f', '::', ' \2f\2a ', ' *\2f '" 
                m-cmnt-2 
                "select ' *\2f ', ' :: ', '\2f\2a', '*\2f', '::', ' \2f\2a '"  
                m-cmnt-3
                ==
++  test-line-cmnt-05
  %+  expect-eq
    !>  ~[t1 t2a t3]
    !>  %-  parse:parse(default-database 'other-db') 
            %-  zing 
            %-  limo  
            :~  "select '\2f\2a', '*\2f', '::', ' \2f\2a ', ' *\2f ', ' :: '\0a" 
                m-cmnt-1 
                "select ' :: ', '\2f\2a', '*\2f'::, ' \2f\2a ', ' *\2f '" 
                m-cmnt-2 
                "select ' *\2f ', ' :: ', '\2f\2a', '*\2f', '::', ' \2f\2a '"  
                m-cmnt-3
                ==
++  test-line-cmnt-06
  %+  expect-eq
    !>  ~[t1 t2 t3a]
    !>  %-  parse:parse(default-database 'other-db') 
            %-  zing 
            %-  limo  
            :~  "select '\2f\2a', '*\2f', '::', ' \2f\2a ', ' *\2f ', ' :: '\0a" 
                m-cmnt-1 
                "select ' :: ', '\2f\2a', '*\2f', '::', ' \2f\2a ', ' *\2f '" 
                m-cmnt-2 
                "select ' *\2f ', ' :: ', '\2f\2a', '*\2f' ::, ' \2f\2a '"  
                m-cmnt-3
                ==
++  test-line-cmnt-07
  %+  expect-eq
    !>  ~[t1 t2a t3b]
    !>  %-  parse:parse(default-database 'other-db') 
            %-  zing 
            %-  limo  
            :~  "select '\2f\2a', '*\2f', '::', ' \2f\2a ', ' *\2f ', ' :: '\0a" 
                "select ' :: ', '\2f\2a', '*\2f'::, ' \2f\2a ', ' *\2f '\0a" 
                "select ' *\2f '  :: ', '\2f\2a', '*\2f', '::', ' \2f\2a '"
                ==
--
