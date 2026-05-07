/-  ast
/+  parse,  *test, *test-helpers
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
:: -test /=urql=/tests/lib/parse-alter/hoon ~
|%
:: ALTER DATABASE
::
::  parses ALTER DATABASE with mixed-case keywords and extra whitespace
++  test-alter-database-parse-00
  %+  expect-eq
    !>  ~[[%alter-database name='old-db' new-name='new-db']]
    !>  %-  parse:parse(default-database 'dummy')
        " aLtEr \0d dataBase  old-db  rename \09 TO  new-db "
::
::
:: alter namespace
::
:: tests 1, 2, 3, 5, and extra whitespace characters, alter namespace db.ns db.ns2.table ; ns db..table
++  test-alter-namespace-00
  =/  expected1
    :*  %alter-namespace
        database-name='db'
        target-namespace='ns'
        table-or-view=%table
        [%qualified-table ship=~ database='db' namespace='ns2' name='table' ~]
        as-of=~
        ==
  =/  expected2
    :*  %alter-namespace
        database-name='db1'
        target-namespace='ns'
        table-or-view=%table
        [%qualified-table ship=~ database='db' namespace='dbo' name='table' ~]
        as-of=~
        ==
  %+  expect-eq
    !>  ~[expected1 expected2]
    !>  %-  parse:parse(default-database 'db1')
        " ALtER NAmESPACE   db.ns   TRANsFER ".
        "  TaBLE  db.ns2.table \0a;\0a ALTER ".
        "NAMESPACE ns TRANSFER TABLE db..table "
::
:: alter namespace  ns table
++  test-alter-namespace-01
  =/  expected
    :*  %alter-namespace
        database-name='db1'
        target-namespace='ns'
        table-or-view=%table
        [%qualified-table ship=~ database='db1' namespace='dbo' name='table' ~]
        as-of=~
        ==
  %+  expect-eq
    !>  ~[expected]
    !>  %-  parse:parse(default-database 'db1')
        "ALTER NAMESPACE ns TRANSFER TABLE table "
::
:: alter namespace db.ns db.ns2.table as of now
++  test-alter-namespace-02
  =/  expected
    :*  %alter-namespace
        database-name='db'
        target-namespace='ns'
        table-or-view=%table
        [%qualified-table ship=~ database='db' namespace='ns2' name='table' ~]
        as-of=~
        ==
  %+  expect-eq
    !>  ~[expected]
    !>  %-  parse:parse(default-database 'db1')
        "alter namespace db.ns transfer table db.ns2.table as of now"
::
:: alter namespace db.ns db.ns2.table as of ~2023.12.25..7.15.0..1ef5
++  test-alter-namespace-03
  =/  expected
    :*  %alter-namespace
        database-name='db'
        target-namespace='ns'
        table-or-view=%table
        [%qualified-table ship=~ database='db' namespace='ns2' name='table' ~]
        as-of=[~ [%da ~2023.12.25..7.15.0..1ef5]]
        ==
  %+  expect-eq
    !>  ~[expected]
    !>  %-  parse:parse(default-database 'db1')
        "alter namespace db.ns transfer table ".
        "db.ns2.table as of ~2023.12.25..7.15.0..1ef5"
::
:: alter namespace db.ns db.ns2.table as of 5 days ago
++  test-alter-namespace-04
  =/  expected
    :*  %alter-namespace
        database-name='db'
        target-namespace='ns'
        table-or-view=%table
        [%qualified-table ship=~ database='db' namespace='ns2' name='table' ~]
        as-of=[~ %as-of-offset 5 %days]
        ==
  %+  expect-eq
    !>  ~[expected]
    !>  %-  parse:parse(default-database 'db1')
        "alter namespace db.ns transfer table ".
        "db.ns2.table as of 5 days ago"
::
:: alter namespace ns table as of now
++  test-alter-namespace-05
  =/  expected
    :*  %alter-namespace
        database-name='db1'
        target-namespace='ns'
        table-or-view=%table
        [%qualified-table ship=~ database='db1' namespace='dbo' name='table' ~]
        as-of=~
        ==
  %+  expect-eq
    !>  ~[expected]
    !>  %-  parse:parse(default-database 'db1')
        "alter namespace ns transfer table table as of now"
::
:: alter namespace ns table as of ~2023.12.25..7.15.0..1ef5
++  test-alter-namespace-06
  =/  expected
    :*  %alter-namespace
        database-name='db1'
        target-namespace='ns'
        table-or-view=%table
        [%qualified-table ship=~ database='db1' namespace='dbo' name='table' ~]
        as-of=[~ [%da ~2023.12.25..7.15.0..1ef5]]
        ==
  %+  expect-eq
    !>  ~[expected]
    !>  %-  parse:parse(default-database 'db1')
        "alter namespace ns transfer table table ".
        "as of ~2023.12.25..7.15.0..1ef5"
::
:: alter namespace ns table as of 5 days ago
++  test-alter-namespace-07
  =/  expected
    :*  %alter-namespace
        database-name='db1'
        target-namespace='ns'
        table-or-view=%table
        [%qualified-table ship=~ database='db1' namespace='dbo' name='table' ~]
        as-of=[~ %as-of-offset 5 %days]
        ==
  %+  expect-eq
    !>  ~[expected]
    !>  %-  parse:parse(default-database 'db1')
        "alter namespace ns transfer table table ".
        "as of 5 days ago"
::
:: alter namespace ns table as of ~d3.h5.m30.s12
++  test-alter-namespace-08
  =/  expected
    :*  %alter-namespace
        database-name='db1'
        target-namespace='ns'
        table-or-view=%table
        [%qualified-table ship=~ database='db1' namespace='dbo' name='table' ~]
        as-of=[~ [%dr ~d3.h5.m30.s12]]
        ==
  %+  expect-eq
    !>  ~[expected]
    !>  %-  parse:parse(default-database 'db1')
        "alter namespace ns transfer table table ".
        "as of ~d3.h5.m30.s12"
::
:: alter namespace ns table as of ~h5.m30.s12
++  test-alter-namespace-09
  =/  expected
    :*  %alter-namespace
        database-name='db1'
        target-namespace='ns'
        table-or-view=%table
        [%qualified-table ship=~ database='db1' namespace='dbo' name='table' ~]
        as-of=[~ [%dr ~h5.m30.s12]]
        ==
  %+  expect-eq
    !>  ~[expected]
    !>  %-  parse:parse(default-database 'db1')
        "alter namespace ns transfer table table ".
        "as of ~h5.m30.s12"
::
:: alter namespace ns table as of ~m30.s12
++  test-alter-namespace-10
  =/  expected
    :*  %alter-namespace
        database-name='db1'
        target-namespace='ns'
        table-or-view=%table
        [%qualified-table ship=~ database='db1' namespace='dbo' name='table' ~]
        as-of=[~ [%dr ~m30.s12]]
        ==
  %+  expect-eq
    !>  ~[expected]
    !>  %-  parse:parse(default-database 'db1')
        "alter namespace ns transfer table table ".
        "as of ~m30.s12"
::
:: alter namespace ns table as of ~s12
++  test-alter-namespace-11
  =/  expected
    :*  %alter-namespace
        database-name='db1'
        target-namespace='ns'
        table-or-view=%table
        [%qualified-table ship=~ database='db1' namespace='dbo' name='table' ~]
        as-of=[~ [%dr ~s12]]
        ==
  %+  expect-eq
    !>  ~[expected]
    !>  %-  parse:parse(default-database 'db1')
        "alter namespace ns transfer table table ".
        "as of ~s12"
::
:: fail when namespace qualifier is not a term
++  test-fail-alter-namespace-12
  %-  expect-fail
  |.  %-  parse:parse(default-database 'db2')
      "ALTER NAMESPACE db.nS TRANSFER TABLE db.ns2.table"
::
:: fail when table name is not a term
++  test-fail-alter-namespace-13
  %-  expect-fail
  |.  %-  parse:parse(default-database 'other-db')
      "ALTER NAMESPACE db.ns TRANSFER TABLE db.ns2.tAble"
::
:: fail because alter namespace only accepts table transfers
++  test-fail-alter-namespace-14
  %-  expect-fail
  |.  %-  parse:parse(default-database 'other-db')
      "ALTER NAMESPACE db.ns TRANSFER VIEW db.ns2.my-view"
::
::
:: alter table
::
:: tests 1, 2, 3, 5, and extra whitespace characters
:: alter column db.ns.table 3 columns ; alter column db..table 1 column
++  test-alter-table-00
  =/  expected1
    :*  %alter-table
        [%qualified-table ship=~ database='db' namespace='ns' name='table' ~]
        ~
        :~  [%column name='col1' column-type=%t addr=0]
            [%column name='col2' column-type=%p addr=0]
            [%column name='col3' column-type=%ud addr=0]
            ==
        ~
        ~
        ~
        ~
        ==
  =/  expected2
    :*  %alter-table
        [%qualified-table ship=~ database='db' namespace='dbo' name='table' ~]
        ~
        ~[[%column name='col1' column-type=%t addr=0]]
        ~
        ~
        ~
        ~
        ==
  %+  expect-eq
    !>  ~[expected1 expected2]
    !>  %-  parse:parse(default-database 'db1')
        " ALtER  TaBLE  db.ns.table  AdD  COlUMN  ".
        "( col1  @t ,  col2  @p ,  col3  @ud ) ".
        "\0a;\0a ALTER TABLE db..table ADD COLUMN ".
        "(col1 @t) "
::
:: alter column table 3 columns
++  test-alter-table-01
  =/  expected
    :*  %alter-table
        [%qualified-table ship=~ database='db1' namespace='dbo' name='table' ~]
        :~  [%column name='col1' column-type=%t addr=0]
            [%column name='col2' column-type=%p addr=0]
            [%column name='col3' column-type=%ud addr=0]
            ==
        ~
        ~
        ~
        ~
        ~
        ==
  %+  expect-eq
    !>  ~[expected]
    !>  %-  parse:parse(default-database 'db1')
        "ALTER TABLE table ALTER COLUMN ".
        "(col1 @t, col2 @p, col3 @ud)"
::
:: alter column table 1 column
++  test-alter-table-02
  =/  expected
    :*  %alter-table
        [%qualified-table ship=~ database='db1' namespace='dbo' name='table' ~]
        ~[[%column name='col1' column-type=%t addr=0]]
        ~
        ~
        ~
        ~
        ~
        ==
  %+  expect-eq
    !>  ~[expected]
    !>  %-  parse:parse(default-database 'db1')
        "ALTER TABLE table ALTER COLUMN (col1 @t)"
::
:: drop column table 3 columns
++  test-alter-table-03
  =/  expected
    :*  %alter-table
        [%qualified-table ship=~ database='db1' namespace='dbo' name='table' ~]
        ~
        ~
        ['col1' 'col2' 'col3' ~]
        ~
        ~
        ~
        ==
  %+  expect-eq
    !>  ~[expected]
    !>  %-  parse:parse(default-database 'db1')
        "ALTER TABLE table DROP COLUMN (col1, col2, col3)"
::
:: drop column table 1 column
++  test-alter-table-04
  =/  expected
    :*  %alter-table
        [%qualified-table ship=~ database='db1' namespace='dbo' name='table' ~]
        ~
        ~
        ['col1' ~]
        ~
        ~
        ~
        ==
  %+  expect-eq
    !>  ~[expected]
    !>  %-  parse:parse(default-database 'db1')
        "ALTER TABLE table DROP COLUMN (col1)"
::
:: add 2 foreign keys, extra spaces and mixed case key words
++  test-alter-table-05
  =/  fk1
    :*  %foreign-key  name='fk'
        [%qualified-table ship=~ database='db1' namespace='dbo' name='table' ~]
        :~  [%ordered-column name='col1' is-ascending=%.y]
            [%ordered-column name='col2' is-ascending=%.n]
            ==
        :*  %qualified-table  ship=~  database='db1'
            namespace='dbo'  name='fk-table'  ~
            ==
        ['col19' 'col20' ~]
        ~[%delete-cascade %update-cascade]
        ==
  =/  fk2
    :*  %foreign-key  name='fk2'
        [%qualified-table ship=~ database='db1' namespace='dbo' name='table' ~]
        :~  [%ordered-column name='col1' is-ascending=%.y]
            [%ordered-column name='col2' is-ascending=%.n]
            ==
        :*  %qualified-table  ship=~  database='db1'
            namespace='dbo'  name='fk-table2'  ~
            ==
        ['col19' 'col20' ~]
        ~[%delete-cascade %update-cascade]
        ==
  =/  expected
    :*  %alter-table
        [%qualified-table ship=~ database='db1' namespace='dbo' name='table' ~]
        ~
        ~
        ~
        ~[fk1 fk2]
        ~
        ~
        ==
  =/  urql
    "ALTER TABLE table ADD FOREIGN KEY ".
    "fk  ( col1 , col2  desc )  reFerences ".
    " fk-table  ( col19 ,  col20 )  On ".
    " dELETE  CAsCADE  oN  UPdATE ".
    " CAScADE, fk2  ( col1 ,  col2 ".
    " desc )  reFerences  fk-table2 ".
    " ( col19 ,  col20 )  On  dELETE ".
    " CAsCADE  oN  UPdATE  CAScADE "
  %+  expect-eq
    !>  ~[expected]
    !>  (parse:parse(default-database 'db1') urql)
::
:: drop 2 foreign keys, extra spaces
++  test-alter-table-06
  =/  expected
    :*  %alter-table
        :*  %qualified-table  ship=~  database='db1'
            namespace='dbo'  name='mytable'  ~
            ==
        ~
        ~
        ~
        ~
        ['fk1' 'fk2' ~]
        ~
        ==
  %+  expect-eq
    !>  ~[expected]
    !>  %-  parse:parse(default-database 'db1')
        " ALTER  TABLE  mytable  DROP  FOREIGN  KEY  ( fk1,  fk2 )"
::
:: drop 2 foreign keys, no extra spaces
++  test-alter-table-07
  =/  expected
    :*  %alter-table
        [%qualified-table ship=~ database='db' namespace='dbo' name='mytable' ~]
        ~
        ~
        ~
        ~
        ['fk1' 'fk2' ~]
        ~
        ==
  %+  expect-eq
    !>  ~[expected]
    !>  %-  parse:parse(default-database 'db1')
        "ALTER TABLE db..mytable DROP FOREIGN KEY (fk1,fk2)"
::
:: drop 1 foreign key
++  test-alter-table-08
  =/  expected
    :*  %alter-table
        [%qualified-table ship=~ database='db1' namespace='ns' name='mytable' ~]
        ~
        ~
        ~
        ~
        ['fk1' ~]
        ~
        ==
  %+  expect-eq
    !>  ~[expected]
    !>  %-  parse:parse(default-database 'db1')
        "ALTER TABLE ns.mytable DROP FOREIGN KEY (fk1)"
::
::  add column as of now
++  test-alter-table-09
  =/  expected
    :*  %alter-table
        [%qualified-table ship=~ database='db' namespace='ns' name='table' ~]
        ~
        :~  [%column name='col1' column-type=%t addr=0]
            [%column name='col2' column-type=%p addr=0]
            [%column name='col3' column-type=%ud addr=0]
            ==
        ~
        ~
        ~
        ~
        ==
  %+  expect-eq
    !>  ~[expected]
    !>  %-  parse:parse(default-database 'db1')
        "alter table  db.ns.table  add  column ".
        " ( col1  @t ,  col2  @p ,  col3  @ud )".
        " as of now"
::
::  add column as of now
++  test-alter-table-10
  =/  expected
    :*  %alter-table
        [%qualified-table ship=~ database='db' namespace='ns' name='table' ~]
        ~
        :~  [%column name='col1' column-type=%t addr=0]
            [%column name='col2' column-type=%p addr=0]
            [%column name='col3' column-type=%ud addr=0]
            ==
        ~
        ~
        ~
        [~ [%da ~2023.12.25..7.15.0..1ef5]]
        ==
  %+  expect-eq
    !>  ~[expected]
    !>  %-  parse:parse(default-database 'db1')
        "alter table  db.ns.table  add  column ".
        " ( col1  @t ,  col2  @p ,  col3  @ud )".
        " as of ~2023.12.25..7.15.0..1ef5"
::
::  add column as of 1 weeks ago
++  test-alter-table-11
  =/  expected
    :*  %alter-table
        [%qualified-table ship=~ database='db' namespace='ns' name='table' ~]
        ~
        :~  [%column name='col1' column-type=%t addr=0]
            [%column name='col2' column-type=%p addr=0]
            [%column name='col3' column-type=%ud addr=0]
            ==
        ~
        ~
        ~
        [~ [%as-of-offset 1 %weeks]]
        ==
  %+  expect-eq
    !>  ~[expected]
    !>  %-  parse:parse(default-database 'db1')
        "alter table  db.ns.table  add  column ".
        " ( col1  @t ,  col2  @p ,  col3  @ud )".
        " as of 1 weeks ago"
::
:: alter column as of now
++  test-alter-table-12
  =/  expected
    :*  %alter-table
        [%qualified-table ship=~ database='db1' namespace='dbo' name='table' ~]
        :~  [%column name='col1' column-type=%t addr=0]
            [%column name='col2' column-type=%p addr=0]
            ==
        ~
        ~
        ~
        ~
        ~
        ==
  %+  expect-eq
    !>  ~[expected]
    !>  %-  parse:parse(default-database 'db1')
        "alter table table alter column (col1 @t, col2 @p) as of now"
::
:: alter column as of ~2023.12.25..7.15.0..1ef5
++  test-alter-table-13
  =/  expected
    :*  %alter-table
        [%qualified-table ship=~ database='db1' namespace='dbo' name='table' ~]
        :~  [%column name='col1' column-type=%t addr=0]
            [%column name='col2' column-type=%p addr=0]
            [%column name='col3' column-type=%ud addr=0]
            ==
        ~
        ~
        ~
        ~
        [~ [%da ~2023.12.25..7.15.0..1ef5]]
        ==
  %+  expect-eq
    !>  ~[expected]
    !>  %-  parse:parse(default-database 'db1')
        "alter table table alter column ".
        "(col1 @t, col2 @p, col3 @ud) ".
        "as of ~2023.12.25..7.15.0..1ef5"
::
:: alter column as of 5 days ago
++  test-alter-table-14
  =/  expected
    :*  %alter-table
        [%qualified-table ship=~ database='db1' namespace='dbo' name='table' ~]
        ~[[%column name='col1' column-type=%t addr=0]]
        ~
        ~
        ~
        ~
        [~ %as-of-offset 5 %days]
        ==
  %+  expect-eq
    !>  ~[expected]
    !>  %-  parse:parse(default-database 'db1')
        "alter table table alter column ".
        "(col1 @t) as of 5 days ago"
::
:: drop column as of now
++  test-alter-table-15
  =/  expected
    :*  %alter-table
        [%qualified-table ship=~ database='db1' namespace='dbo' name='table' ~]
        ~
        ~
        ['col1' 'col2' ~]
        ~
        ~
        ~
        ==
  %+  expect-eq
    !>  ~[expected]
    !>  %-  parse:parse(default-database 'db1')
        "alter table table drop column (col1, col2) as of now"
::
:: drop column as of ~2023.12.25..7.15.0..1ef5
++  test-alter-table-16
  =/  expected
    :*  %alter-table
        [%qualified-table ship=~ database='db1' namespace='dbo' name='table' ~]
        ~
        ~
        ['col1' ~]
        ~
        ~
        [~ [%da ~2023.12.25..7.15.0..1ef5]]
        ==
  %+  expect-eq
    !>  ~[expected]
    !>  %-  parse:parse(default-database 'db1')
        "alter table table drop column (col1) ".
        "as of ~2023.12.25..7.15.0..1ef5"
::
:: drop column as of 5 days ago
++  test-alter-table-17
  =/  expected
    :*  %alter-table
        [%qualified-table ship=~ database='db1' namespace='dbo' name='table' ~]
        ~
        ~
        ['col1' 'col2' 'col3' ~]
        ~
        ~
        [~ %as-of-offset 5 %days]
        ==
  %+  expect-eq
    !>  ~[expected]
    !>  %-  parse:parse(default-database 'db1')
        "alter table table drop column (col1, col2, col3) as of 5 days ago"
::
:: add 2 foreign keys as of now
++  test-alter-table-18
  =/  fk1
    :*  %foreign-key  name='fk'
        [%qualified-table ship=~ database='db1' namespace='dbo' name='table' ~]
        :~  [%ordered-column name='col1' is-ascending=%.y]
            [%ordered-column name='col2' is-ascending=%.n]
            ==
        :*  %qualified-table  ship=~  database='db1'
            namespace='dbo'  name='fk-table'  ~
            ==
        ['col19' 'col20' ~]
        ~[%delete-cascade %update-cascade]
        ==
  =/  fk2
    :*  %foreign-key  name='fk2'
        [%qualified-table ship=~ database='db1' namespace='dbo' name='table' ~]
        :~  [%ordered-column name='col1' is-ascending=%.y]
            [%ordered-column name='col2' is-ascending=%.n]
            ==
        :*  %qualified-table  ship=~  database='db1'
            namespace='dbo'  name='fk-table2'  ~
            ==
        ['col19' 'col20' ~]
        ~[%delete-cascade %update-cascade]
        ==
  =/  expected
    :*  %alter-table
        [%qualified-table ship=~ database='db1' namespace='dbo' name='table' ~]
        ~
        ~
        ~
        ~[fk1 fk2]
        ~
        ~
        ==
  =/  urql
    "alter table table add foreign key ".
    "fk  ( col1 , col2  desc )  references".
    "  fk-table  ( col19 ,  col20 )  on".
    "  delete  cascade  on  update ".
    " cascade, fk2  ( col1 ,  col2 ".
    " desc )  references  fk-table2 ".
    " ( col19 ,  col20 )  on  delete ".
    " cascade  on  update  cascade ".
    "as of now"
  %+  expect-eq
    !>  ~[expected]
    !>  (parse:parse(default-database 'db1') urql)
::
:: add 2 foreign keys as of ~2023.12.25..7.15.0..1ef5
++  test-alter-table-19
  =/  fk1
    :*  %foreign-key  name='fk'
        [%qualified-table ship=~ database='db1' namespace='dbo' name='table' ~]
        :~  [%ordered-column name='col1' is-ascending=%.y]
            [%ordered-column name='col2' is-ascending=%.n]
            ==
        :*  %qualified-table  ship=~  database='db1'
            namespace='dbo'  name='fk-table'  ~
            ==
        ['col19' 'col20' ~]
        ~[%delete-cascade %update-cascade]
        ==
  =/  fk2
    :*  %foreign-key  name='fk2'
        [%qualified-table ship=~ database='db1' namespace='dbo' name='table' ~]
        :~  [%ordered-column name='col1' is-ascending=%.y]
            [%ordered-column name='col2' is-ascending=%.n]
            ==
        :*  %qualified-table  ship=~  database='db1'
            namespace='dbo'  name='fk-table2'  ~
            ==
        ['col19' 'col20' ~]
        ~[%delete-cascade %update-cascade]
        ==
  =/  expected
    :*  %alter-table
        [%qualified-table ship=~ database='db1' namespace='dbo' name='table' ~]
        ~
        ~
        ~
        ~[fk1 fk2]
        ~
        [~ [%da ~2023.12.25..7.15.0..1ef5]]
        ==
  =/  urql
    "alter table table add foreign key ".
    "fk  ( col1 , col2  desc )  references".
    "  fk-table  ( col19 ,  col20 )  on".
    "  delete  cascade  on  update ".
    " cascade, fk2  ( col1 ,  col2 ".
    " desc )  references  fk-table2 ".
    " ( col19 ,  col20 )  on  delete ".
    " cascade  on  update  cascade ".
    "as of ~2023.12.25..7.15.0..1ef5"
  %+  expect-eq
    !>  ~[expected]
    !>  (parse:parse(default-database 'db1') urql)
::
:: add 2 foreign keys as of 5 days ago
++  test-alter-table-20
  =/  fk1
    :*  %foreign-key  name='fk'
        [%qualified-table ship=~ database='db1' namespace='dbo' name='table' ~]
        :~  [%ordered-column name='col1' is-ascending=%.y]
            [%ordered-column name='col2' is-ascending=%.n]
            ==
        :*  %qualified-table  ship=~  database='db1'
            namespace='dbo'  name='fk-table'  ~
            ==
        ['col19' 'col20' ~]
        ~[%delete-cascade %update-cascade]
        ==
  =/  fk2
    :*  %foreign-key  name='fk2'
        [%qualified-table ship=~ database='db1' namespace='dbo' name='table' ~]
        :~  [%ordered-column name='col1' is-ascending=%.y]
            [%ordered-column name='col2' is-ascending=%.n]
            ==
        :*  %qualified-table  ship=~  database='db1'
            namespace='dbo'  name='fk-table2'  ~
            ==
        ['col19' 'col20' ~]
        ~[%delete-cascade %update-cascade]
        ==
  =/  expected
    :*  %alter-table
        [%qualified-table ship=~ database='db1' namespace='dbo' name='table' ~]
        ~
        ~
        ~
        ~[fk1 fk2]
        ~
        [~ %as-of-offset 5 %days]
        ==
  =/  urql
    "alter table table add foreign key ".
    "fk  ( col1 , col2  desc )  references".
    "  fk-table  ( col19 ,  col20 )  on".
    "  delete  cascade  on  update ".
    " cascade, fk2  ( col1 ,  col2 ".
    " desc )  references  fk-table2 ".
    " ( col19 ,  col20 )  on  delete ".
    " cascade  on  update  cascade ".
    "as of 5 days ago"
  %+  expect-eq
    !>  ~[expected]
    !>  (parse:parse(default-database 'db1') urql)
::
:: drop 2 foreign keys as of now
++  test-alter-table-21
  =/  expected
    :*  %alter-table
        :*  %qualified-table  ship=~  database='db1'
            namespace='dbo'  name='mytable'  ~
            ==
        ~
        ~
        ~
        ~
        ['fk1' 'fk2' ~]
        ~
        ==
  %+  expect-eq
    !>  ~[expected]
    !>  %-  parse:parse(default-database 'db1')
        "alter  table  mytable  drop  foreign  key  ( fk1,  fk2 ) as of now"
::
:: drop 2 foreign keys as of ~2023.12.25..7.15.0..1ef5
++  test-alter-table-22
  =/  expected
    :*  %alter-table
        :*  %qualified-table  ship=~  database='db1'
            namespace='dbo'  name='mytable'  ~
            ==
        ~
        ~
        ~
        ~
        ['fk1' 'fk2' ~]
        [~ [%da ~2023.12.25..7.15.0..1ef5]]
        ==
  %+  expect-eq
    !>  ~[expected]
    !>  %-  parse:parse(default-database 'db1')
        "alter  table  mytable  drop  foreign ".
        " key  ( fk1,  fk2 ) ".
        "as of ~2023.12.25..7.15.0..1ef5"
::
:: drop 2 foreign keys as of 5 days ago
++  test-alter-table-23
  =/  expected
    :*  %alter-table
        :*  %qualified-table  ship=~  database='db1'
            namespace='dbo'  name='mytable'  ~
            ==
        ~
        ~
        ~
        ~
        ['fk1' 'fk2' ~]
        [~ %as-of-offset 5 %days]
        ==
  %+  expect-eq
    !>  ~[expected]
    !>  %-  parse:parse(default-database 'db1')
        "alter  table  mytable  drop  foreign ".
        " key  ( fk1,  fk2 ) as of 5 days ago"
::
:: fail when table name not a term
++  test-fail-alter-table-24
  %-  expect-fail
  |.  %-  parse:parse(default-database 'db1')
      "ALTER TABLE ns.myTable DROP FOREIGN KEY (fk1)"
--
