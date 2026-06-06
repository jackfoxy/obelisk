/-  ast=obelisk-ast
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
:: -test /=urql=/tests/lib/parse/hoon ~
|%
:: current database must be proper face
++  test-fail-default-database
    %-  expect-fail
    |.  %-  parse:parse(default-database 'oTher-db')
        "cReate\0d\09  namespace my-namespace"
::
::
:: create database
::
:: tests 1, 3, and extra whitespace characters
++  test-create-database-00
  %+  expect-eq
    !>  ~[[%create-database name='my-database' as-of=~]]
    !>  %-  parse:parse(default-database 'dummy')
        "cReate datAbase \0a  my-database "
::
:: as of now
++  test-create-database-01
  %+  expect-eq
    !>  ~[[%create-database name='my-db' as-of=~]]
    !>  %-  parse:parse(default-database 'dummy')
        "create database my-db As   Of now"
::
:: as of date-time
++  test-create-database-02
  =/  expected
    [%create-database name='my-db' as-of=[~ [%da ~2023.12.25..7.15.0..1ef5]]]
  %+  expect-eq
    !>  ~[expected]
    !>  %-  parse:parse(default-database 'dummy')
        "create database my-db AS OF ".
        "~2023.12.25..7.15.0..1ef5"
::
:: as of seconds ago
++  test-create-database-03
  %+  expect-eq
    !>  ~[[%create-database name='my-db' as-of=[~ [%as-of-offset 5 %seconds]]]]
    !>  %-  parse:parse(default-database 'dummy')
        "create database my-db as   of 5 seconds ago"
::
:: as of minutes ago
++  test-create-database-04
  =/  expected
    [%create-database name='my-db' as-of=[~ [%as-of-offset 15 %minutes]]]
  %+  expect-eq
    !>  ~[expected]
    !>  %-  parse:parse(default-database 'dummy')
        "create database my-db as of 15 minutes ago"
::
:: as of hours ago
++  test-create-database-05
  %+  expect-eq
    !>  ~[[%create-database name='my-db' as-of=[~ [%as-of-offset 9 %hours]]]]
    !>  %-  parse:parse(default-database 'dummy')
        "create database my-db as of 9 hours ago"
::
:: as of days ago
++  test-create-database-06
  %+  expect-eq
    !>  ~[[%create-database name='my-db' as-of=[~ [%as-of-offset 3 %days]]]]
    !>  %-  parse:parse(default-database 'dummy')
        "create database my-db as of 3 days ago"
::
:: as of weeks ago
++  test-create-database-07
  %+  expect-eq
    !>  ~[[%create-database name='my-db' as-of=[~ [%as-of-offset 2 %weeks]]]]
    !>  %-  parse:parse(default-database 'dummy')
        "create database my-db as of 2 weeks ago"
::
:: as of months ago
++  test-create-database-08
  %+  expect-eq
    !>  ~[[%create-database name='my-db' as-of=[~ [%as-of-offset 7 %months]]]]
    !>  %-  parse:parse(default-database 'dummy')
        "create database my-db as of 7 months ago"
::
:: as of years ago
++  test-create-database-09
  %+  expect-eq
    !>  ~[[%create-database name='my-db' as-of=[~ [%as-of-offset 4 %years]]]]
    !>  %-  parse:parse(default-database 'dummy')
        "create database my-db as of 4 years ago"
::
:: fail when database name is not a term
++  test-fail-create-database-01
  %-  expect-fail
  |.  (parse:parse(default-database 'dummy') "cReate datAbase  My-database")
::
:: create index
::
:: tests 1, 2, 3, 5, and extra whitespace characters, create index... db.ns.table, create unique index... db..table
++  test-create-index-1
  =/  expected1
    :*  %create-index  name='my-index'
        [%qualified-table ship=~ database='db' namespace='ns' name='table' ~]
        %.n
        :~  [%ordered-column name='col1' ascending=%.y]
            [%ordered-column name='col2' ascending=%.n]
            [%ordered-column name='col3' ascending=%.y]
            ==
        ~
        ==
  =/  expected2
    :*  %create-index  name='my-index'
        [%qualified-table ship=~ database='db' namespace='dbo' name='table' ~]
        %.y
        :~  [%ordered-column name='col1' ascending=%.y]
            [%ordered-column name='col2' ascending=%.n]
            [%ordered-column name='col3' ascending=%.y]
            ==
        ~
        ==
  %+  expect-eq
    !>  ~[expected1 expected2]
    !>  %-  parse:parse(default-database 'db1')
        "CREATe \0d INdEX\09my-index ".
        "On db.ns.table  ( col1 , col2\0a ".
        "desc  , col3) \0a;\0a CREATE ".
        "unIque INDEX my-index ON db..table ".
        "(col1 , col2 desc, col3 )  "
::
:: leading whitespace characters, end delimiter, create index... ns.table
++  test-create-index-2
  =/  expected
    :*  %create-index  name='my-index'
        [%qualified-table ship=~ database='db1' namespace='ns' name='table' ~]
        %.n
        :~  [%ordered-column name='col1' ascending=%.y]
            [%ordered-column name='col2' ascending=%.n]
            [%ordered-column name='col3' ascending=%.y]
            ==
        ~
        ==
  %+  expect-eq
    !>  ~[expected]
    !>  %-  parse:parse(default-database 'db1')
        "  \0d CREATE INDEX my-index ".
        "ON ns.table (col1, col2 desc, col3);"
::
:: create index... table (col1 desc, col2 asc, col3)
++  test-create-index-3
  =/  expected
    :*  %create-index  name='my-index'
        [%qualified-table ship=~ database='db1' namespace='dbo' name='table' ~]
        %.n
        :~  [%ordered-column name='col1' ascending=%.n]
            [%ordered-column name='col2' ascending=%.y]
            [%ordered-column name='col3' ascending=%.y]
            ==
        ~
        ==
  %+  expect-eq
    !>  ~[expected]
    !>  %-  parse:parse(default-database 'db1')
        "CREATE INDEX my-index ON table ".
        "(col1 desc, col2 asc, col3)"
::
:: create unique index... table (col1 desc)
++  test-create-index-4
  =/  expected
    :*  %create-index  name='my-index'
        [%qualified-table ship=~ database='db1' namespace='dbo' name='table' ~]
        %.y
        ~[[%ordered-column name='col1' ascending=%.n]]
        ~
        ==
  %+  expect-eq
    !>  ~[expected]
    !>  %-  parse:parse(default-database 'db1')
        "CREATE uniQue INDEX my-index ON table (col1 desc)"
::
:: create unique index... table (col1)
++  test-create-index-5
  =/  expected
    :*  %create-index  name='my-index'
        [%qualified-table ship=~ database='db1' namespace='dbo' name='table' ~]
        %.y
        ~[[%ordered-column name='col1' ascending=%.y]]
        ~
        ==
  %+  expect-eq
    !>  ~[expected]
    !>  %-  parse:parse(default-database 'db1')
        "CREATE uniQue INDEX my-index ON table (col1)"
::
:: fail when database qualifier is not a term
++  test-fail-create-index-6
  %-  expect-fail
  |.  %-  parse:parse(default-database 'db2')
      "create index my-index ON Db.ns.table (col1)"
::
:: fail when namespace qualifier is not a term
++  test-fail-create-index-7
  %-  expect-fail
  |.  %-  parse:parse(default-database 'db2')
      "create index my-index ON db.Ns.table (col1)"
::
:: fail when table name is not a term
++  test-fail-create-index-8
  %-  expect-fail
  |.  %-  parse:parse(default-database 'other-db')
      "create index my-index ON db.ns.Table (col1)"
::
:: create namespace
::
:: tests 1, 2, 3, 5, and extra whitespace characters
++  test-create-namespace-00
  =/  expected1
    [%create-namespace database-name='db1' name='ns1' as-of=~]
  =/  expected2
    :*  %create-namespace  database-name='my-db'
        name='another-namespace'  as-of=~
        ==
  %+  expect-eq
    !>  ~[expected1 expected2]
    !>  %-  parse:parse(default-database 'db1')
        "cReate\0d\09  namespace ns1 ; ".
        "cReate namesPace my-db.another-namespace"
::
:: leading and trailing whitespace characters, end delimiter not required on single
++  test-create-namespace-01
  %+  expect-eq
    !>  ~[[%create-namespace database-name='db1' name='ns1' as-of=~]]
    !>  %-  parse:parse(default-database 'db1')
        "   \09cReate\0d\09  namespace ns1 "
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
    !>  %-  parse:parse(default-database 'db1')
        "create namespace db2.ns1 as   of now"
::
:: as of date-time simple name
++  test-create-namespace-04
  =/  expected
    :*  %create-namespace  database-name='db1'
        name='ns1'
        [~ [%da ~2023.12.25..7.15.0..1ef5]]
        ==
  %+  expect-eq
    !>  ~[expected]
    !>  %-  parse:parse(default-database 'db1')
        "create namespace ns1 AS of ".
        "~2023.12.25..7.15.0..1ef5"
::
:: as of date-time qualified name
++  test-create-namespace-05
  =/  expected
    :*  %create-namespace  database-name='db2'
        name='ns1'
        [~ [%da ~2023.12.25..7.15.0..1ef5]]
        ==
  %+  expect-eq
    !>  ~[expected]
    !>  %-  parse:parse(default-database 'db1')
        "create namespace db2.ns1 as   OF ".
        "~2023.12.25..7.15.0..1ef5"
::
:: as of seconds ago simple name
++  test-create-namespace-06
  =/  expected
    :*  %create-namespace  database-name='db1'
        name='ns1'  [~ [%as-of-offset 5 %seconds]]
        ==
  %+  expect-eq
    !>  ~[expected]
    !>  %-  parse:parse(default-database 'db1')
        "create namespace ns1 as of 5 seconds ago"
::
:: as of seconds ago qualified name
++  test-create-namespace-07
  =/  expected
    :*  %create-namespace  database-name='db2'
        name='ns1'  [~ [%as-of-offset 5 %seconds]]
        ==
  %+  expect-eq
    !>  ~[expected]
    !>  %-  parse:parse(default-database 'db1')
        "create namespace db2.ns1 as of 5 seconds ago"
::
:: as of minutes ago simple name
++  test-create-namespace-08
  =/  expected
    :*  %create-namespace  database-name='db1'
        name='ns1'  [~ [%as-of-offset 15 %minutes]]
        ==
  %+  expect-eq
    !>  ~[expected]
    !>  %-  parse:parse(default-database 'db1')
        "create namespace ns1 as of 15 minutes ago"
::
:: as of minutes ago qualified name
++  test-create-namespace-09
  =/  expected
    :*  %create-namespace  database-name='db2'
        name='ns1'  [~ [%as-of-offset 15 %minutes]]
        ==
  %+  expect-eq
    !>  ~[expected]
    !>  %-  parse:parse(default-database 'db1')
        "create namespace db2.ns1 as of 15 minutes ago"
::
:: as of hours ago simple name
++  test-create-namespace-10
  =/  expected
    :*  %create-namespace  database-name='db1'
        name='ns1'  [~ [%as-of-offset 9 %hours]]
        ==
  %+  expect-eq
    !>  ~[expected]
    !>  %-  parse:parse(default-database 'db1')
        "create namespace ns1 as of 9 hours ago"
::
:: as of hours ago qualified name
++  test-create-namespace-11
  =/  expected
    :*  %create-namespace  database-name='db2'
        name='ns1'  [~ [%as-of-offset 9 %hours]]
        ==
  %+  expect-eq
    !>  ~[expected]
    !>  %-  parse:parse(default-database 'db1')
        "create namespace db2.ns1 as of 9 hours ago"
::
:: as of days ago simple name
++  test-create-namespace-12
  =/  expected
    :*  %create-namespace  database-name='db1'
        name='ns1'  [~ [%as-of-offset 3 %days]]
        ==
  %+  expect-eq
    !>  ~[expected]
    !>  %-  parse:parse(default-database 'db1')
        "create namespace ns1  as of3 days ago"
::
:: as of days ago qualified name
++  test-create-namespace-13
  =/  expected
    :*  %create-namespace  database-name='db2'
        name='ns1'  [~ [%as-of-offset 3 %days]]
        ==
  %+  expect-eq
    !>  ~[expected]
    !>  %-  parse:parse(default-database 'db1')
        "create namespace db2.ns1  as of3 days ago"
::
:: as of weeks ago simple name
++  test-create-namespace-14
  =/  expected
    :*  %create-namespace  database-name='db1'
        name='ns1'  [~ [%as-of-offset 2 %weeks]]
        ==
  %+  expect-eq
    !>  ~[expected]
    !>  %-  parse:parse(default-database 'db1')
        "create namespace ns1 as of 2 weeks ago"
::
:: as of weeks ago qualified name
++  test-create-namespace-15
  =/  expected
    :*  %create-namespace  database-name='db2'
        name='ns1'  [~ [%as-of-offset 2 %weeks]]
        ==
  %+  expect-eq
    !>  ~[expected]
    !>  %-  parse:parse(default-database 'db1')
        "create namespace db2.ns1 as of 2 weeks ago"
::
:: as of months ago simple name
++  test-create-namespace-16
  =/  expected
    :*  %create-namespace  database-name='db1'
        name='ns1'  [~ [%as-of-offset 7 %months]]
        ==
  %+  expect-eq
    !>  ~[expected]
    !>  %-  parse:parse(default-database 'db1')
        "create namespace ns1 as of 7 months ago"
::
:: as of months ago qualified name
++  test-create-namespace-17
  =/  expected
    :*  %create-namespace  database-name='db2'
        name='ns1'  [~ [%as-of-offset 7 %months]]
        ==
  %+  expect-eq
    !>  ~[expected]
    !>  %-  parse:parse(default-database 'db1')
        "create namespace db2.ns1 as of 7 months ago"
::
:: as of years ago simple name
++  test-create-namespace-18
  =/  expected
    :*  %create-namespace  database-name='db1'
        name='ns1'  [~ [%as-of-offset 4 %years]]
        ==
  %+  expect-eq
    !>  ~[expected]
    !>  %-  parse:parse(default-database 'db1')
        "create namespace ns1 as of 4 years ago"
::
:: as of years ago qualified name
++  test-create-namespace-19
  =/  expected
    :*  %create-namespace  database-name='db2'
        name='ns1'  [~ [%as-of-offset 4 %years]]
        ==
  %+  expect-eq
    !>  ~[expected]
    !>  %-  parse:parse(default-database 'db1')
        "create namespace db2.ns1 as of 4 years ago"
::
:: fail when database qualifier is not a term
++  test-fail-create-namespace-20
  %-  expect-fail
  |.  %-  parse:parse(default-database 'db1')
      "cReate namesPace Bad-face.another-namespace"
::
:: fail when namespace is not a term
++  test-fail-create-namespace-21
  %-  expect-fail
  |.  %-  parse:parse(default-database 'db1')
      "cReate namesPace my-db.Bad-face"
::
:: create table
::
:: tests 1, 2, 3, 5, and extra whitespace characters, db.ns.table on delete cascade on update cascade; db..table on update cascade on delete cascade
++  test-create-table-00
  =/  cols
    :~  [%column name='col1' type=%t addr=0]
        [%column name='col2' type=%p addr=0]
        [%column name='col3' type=%ud addr=0]
        ==
  =/  pidx
    :~  [%ordered-column name='col1' ascending=%.y]
        [%ordered-column name='col2' ascending=%.y]
        ==
  =/  fk-cols
    ~[%col1 %col2]
  =/  fk1
    :*  %foreign-key
        :*  %qualified-table  ship=~
            database='db'  namespace='ns'
            name='my-table'  ~
            ==
        fk-cols
        :*  %qualified-table  ship=~
            database='db'  namespace='dbo'
            name='fk-table'  ~
            ==
        ~[%col19 %col20]
        ~[%delete-cascade %update-cascade]
        ==
  =/  fk2
    :*  %foreign-key
        :*  %qualified-table  ship=~
            database='db'  namespace='dbo'
            name='my-table'  ~
            ==
        fk-cols
        :*  %qualified-table  ship=~
            database='db'  namespace='dbo'
            name='fk-table'  ~
            ==
        ~[%col19 %col20]
        ~[%update-cascade %delete-cascade]
        ==
  =/  expected1
    :*  %create-table
        :*  %qualified-table  ship=~
            database='db'  namespace='ns'
            name='my-table'  ~
            ==
        cols  pidx  ~[fk1]  ~
        ==
  =/  expected2
    :*  %create-table
        :*  %qualified-table  ship=~
            database='db'  namespace='dbo'
            name='my-table'  ~
            ==
        cols  pidx  ~[fk2]  ~
        ==
  =/  urql1
    "crEate  taBle  db.ns.my-table  ( col1  @t ,  col2  @p ,  ".
    "col3  @ud )  pRimary  kEy  ( col1 ,  col2 )  foReign  KeY  ".
    "( col1 ,  col2 )  reFerences  fk-table  ".
    "( col19 ,  col20 )  On  dELETE  CAsCADE  oN  UPdATE  CAScADE "
  =/  urql2
    "crEate  taBle  db..my-table  ( col1  @t ,  col2  @p ,  ".
    "col3  @ud )  pRimary  kEy  ( col1 ,  col2 )  foReign  KeY  ".
    "( col1 ,  col2 )  reFerences  fk-table  ".
    "( col19 ,  col20 )  On  UPdATE  CAsCADE  oN  dELETE  CAScADE "
  %+  expect-eq
    !>  ~[expected1 expected2]
    !>  %-  parse:parse(default-database 'db1')
        (weld urql1 (weld "\0a;\0a" urql2))
::
:: leading whitespace characters, whitespace after end delimiter, create table... table ... references  ns.fk-table  on update no action on delete no action
++  test-create-table-01
  =/  my-table
    :*  %qualified-table  ship=~
        database='db1'  namespace='dbo'
        name='my-table'  ~
        ==
  =/  fk
    :*  %foreign-key
        my-table
        ~[%col1 %col2]
        :*  %qualified-table  ship=~
            database='db1'  namespace='ns'
            name='fk-table'  ~
            ==
        ~[%col19 %col20]
        ~
        ==
  =/  expected
    :*  %create-table
        my-table
        :~  [%column name='col1' type=%t addr=0]
            [%column name='col2' type=%p addr=0]
            [%column name='col3' type=%ud addr=0]
            ==
        :~  [%ordered-column name='col1' ascending=%.y]
            [%ordered-column name='col2' ascending=%.y]
            ==
        ~[fk]
        ~
        ==
  =/  urql
    "  \0acreate table my-table ".
    "(col1 @t,col2 @p,col3 @ud) ".
    "primary key (col1, col2) ".
    "foreign key (col1,col2) ".
    "reFerences ns.fk-table ".
    "(col19, col20) on update restrict ".
    "on delete restrict; "
  %+  expect-eq
    !>  ~[expected]
    !>  (parse:parse(default-database 'db1') urql)
::
:: create table with @ta and @tas columns
++  test-create-table-ta-tas-00
  =/  expected
    :*  %create-table
        :*  %qualified-table  ship=~
            database='db1'  namespace='dbo'
            name='my-table'  ~
            ==
        :~  [%column name='id' type=%ud addr=0]
            [%column name='path' type=%ta addr=0]
            [%column name='term' type=%tas addr=0]
            ==
        ~[[%ordered-column name='id' ascending=%.y]]
        ~
        ~
        ==
  %+  expect-eq
    !>  ~[expected]
    !>  %-  parse:parse(default-database 'db1')
        "create table my-table (id @ud, path @ta, term @tas) primary key (id)"
::
:: create table... table ... references  ns.fk-table  on update no action on delete cascade
++  test-create-table-02
  =/  my-table
    :*  %qualified-table  ship=~
        database='db1'  namespace='dbo'
        name='my-table'  ~
        ==
  =/  fk
    :*  %foreign-key
        my-table
        ~[%col1 %col2]
        :*  %qualified-table  ship=~
            database='db1'  namespace='ns'
            name='fk-table'  ~
            ==
        ~[%col19 %col20]
        ~[%delete-cascade]
        ==
  =/  expected
    :*  %create-table
        my-table
        :~  [%column name='col1' type=%t addr=0]
            [%column name='col2' type=%p addr=0]
            [%column name='col3' type=%ud addr=0]
            ==
        :~  [%ordered-column name='col1' ascending=%.y]
            [%ordered-column name='col2' ascending=%.y]
            ==
        ~[fk]
        ~
        ==
  =/  urql
    "create table my-table ".
    "(col1 @t,col2 @p,col3 @ud) ".
    "primary key (col1, col2) ".
    "foreign key (col1,col2) ".
    "reFerences ns.fk-table ".
    "(col19, col20) on update restrict ".
    "on delete cascade"
  %+  expect-eq
    !>  ~[expected]
    !>  (parse:parse(default-database 'db1') urql)
::
:: create table... table ... references fk-table on update cascade on delete no action
++  test-create-table-03
  =/  my-table
    :*  %qualified-table  ship=~
        database='db1'  namespace='dbo'
        name='my-table'  ~
        ==
  =/  fk
    :*  %foreign-key
        my-table
        ~[%col1 %col2]
        :*  %qualified-table  ship=~
            database='db1'  namespace='dbo'
            name='fk-table'  ~
            ==
        ~[%col19 %col20]
        ~[%update-cascade]
        ==
  =/  expected
    :*  %create-table
        my-table
        :~  [%column name='col1' type=%t addr=0]
            [%column name='col2' type=%p addr=0]
            [%column name='col3' type=%ud addr=0]
            ==
        :~  [%ordered-column name='col1' ascending=%.y]
            [%ordered-column name='col2' ascending=%.y]
            ==
        ~[fk]
        ~
        ==
  =/  urql
    "create table my-table (col1 @t,col2 @p,col3 @ud) ".
    "primary key (col1, col2) foreign key (col1,col2) ".
    "reFerences fk-table (col19, col20) on update cascade on delete restrict"
  %+  expect-eq
    !>  ~[expected]
    !>  (parse:parse(default-database 'db1') urql)
::
:: create table... table ... single column indices... references fk-table on update cascade
++  test-create-table-04
  =/  my-table
    :*  %qualified-table  ship=~
        database='db1'  namespace='dbo'
        name='my-table'  ~
        ==
  =/  fk
    :*  %foreign-key
        my-table
        ~[%col2]
        :*  %qualified-table  ship=~
            database='db1'  namespace='dbo'
            name='fk-table'  ~
            ==
        ~[%col20]
        ~[%update-cascade]
        ==
  =/  expected
    :*  %create-table
        my-table
        :~  [%column name='col1' type=%t addr=0]
            [%column name='col2' type=%p addr=0]
            [%column name='col3' type=%ud addr=0]
            ==
        ~[[%ordered-column name='col1' ascending=%.y]]
        ~[fk]
        ~
        ==
  =/  urql
    "create table my-table ".
    "(col1 @t,col2 @p,col3 @ud) ".
    "primary key (col1) ".
    "foreign key (col2) ".
    "reFerences fk-table (col20) ".
    "on update cascade"
  %+  expect-eq
    !>  ~[expected]
    !>  (parse:parse(default-database 'db1') urql)
::
:: create table... table ... single column indices... references fk-table
++  test-create-table-05
  =/  my-table
    :*  %qualified-table  ship=~
        database='db1'  namespace='dbo'
        name='my-table'  ~
        ==
  =/  fk
    :*  %foreign-key
        my-table
        ~[%col2]
        :*  %qualified-table  ship=~
            database='db1'  namespace='dbo'
            name='fk-table'  ~
            ==
        ~[%col20]
        ~
        ==
  =/  expected
    :*  %create-table
        my-table
        :~  [%column name='col1' type=%t addr=0]
            [%column name='col2' type=%p addr=0]
            [%column name='col3' type=%ud addr=0]
            ==
        ~[[%ordered-column name='col1' ascending=%.y]]
        ~[fk]
        ~
        ==
  =/  urql
    "create table my-table ".
    "(col1 @t,col2 @p,col3 @ud) ".
    "primary key (col1) ".
    "foreign key (col2) ".
    "reFerences fk-table (col20) "
  %+  expect-eq
    !>  ~[expected]
    !>  (parse:parse(default-database 'db1') urql)
::
:: create table...  no foreign key
++  test-create-table-06
  =/  expected
    :*  %create-table
        :*  %qualified-table  ship=~
            database='db1'  namespace='dbo'
            name='my-table'  ~
            ==
        :~  [%column name='col1' type=%t addr=0]
            [%column name='col2' type=%p addr=0]
            [%column name='col3' type=%ud addr=0]
            ==
        :~  [%ordered-column name='col1' ascending=%.y]
            [%ordered-column name='col2' ascending=%.y]
            ==
        ~
        ~
        ==
  =/  urql
    "create table my-table (col1 @t,col2 @p,col3 @ud) primary key (col1,col2)"
  %+  expect-eq
    !>  ~[expected]
    !>  (parse:parse(default-database 'db1') urql)
::
:: create table...  2 foreign keys
++  test-create-table-07
  =/  my-table
    :*  %qualified-table  ship=~
        database='db1'  namespace='dbo'
        name='my-table'  ~
        ==
  =/  fk1
    :*  %foreign-key
        my-table
        ~[%col2]
        :*  %qualified-table  ship=~
            database='db1'  namespace='dbo'
            name='fk-table'  ~
            ==
        ~[%col20]
        ~
        ==
  =/  fk2
    :*  %foreign-key
        my-table
        ~[%col1 %col2]
        :*  %qualified-table  ship=~
            database='db1'  namespace='dbo'
            name='fk-table2'  ~
            ==
        ~[%col19 %col20]
        ~
        ==
  =/  expected
    :*  %create-table
        my-table
        :~  [%column name='col1' type=%t addr=0]
            [%column name='col2' type=%p addr=0]
            [%column name='col3' type=%ud addr=0]
            ==
        ~[[%ordered-column name='col1' ascending=%.y]]
        ~[fk1 fk2]
        ~
        ==
  =/  urql
    "create table my-table ".
    "(col1 @t,col2 @p,col3 @ud) ".
    "primary key (col1) ".
    "foreign key (col2) ".
    "reFerences fk-table (col20), ".
    "(col1, col2) ".
    "reFerences fk-table2 (col19, col20)"
  %+  expect-eq
    !>  ~[expected]
    !>  (parse:parse(default-database 'db1') urql)
::
:: fail when database qualifier on foreign key table db.ns.fk-table
::
:: create table as of simple name as of now
++  test-create-table-08
  =/  expected
    :*  %create-table
        :*  %qualified-table  ship=~
            database='db1'  namespace='dbo'
            name='my-table'  ~
            ==
        :~  [%column name='col1' type=%t addr=0]
            [%column name='col2' type=%p addr=0]
            [%column name='col3' type=%ud addr=0]
            ==
        :~  [%ordered-column name='col1' ascending=%.y]
            [%ordered-column name='col2' ascending=%.y]
            ==
        ~
        ~
        ==
  =/  urql
    "create table my-table ".
    "(col1 @t,col2 @p,col3 @ud) ".
    "primary key (col1,col2) AS of now"
  %+  expect-eq
    !>  ~[expected]
    !>  (parse:parse(default-database 'db1') urql)
::
:: create table as of ns-qualified name as of datetime
++  test-create-table-09
  =/  expected
    :*  %create-table
        :*  %qualified-table  ship=~
            database='db1'  namespace='ns1'
            name='my-table'  ~
            ==
        :~  [%column name='col1' type=%t addr=0]
            [%column name='col2' type=%p addr=0]
            [%column name='col3' type=%ud addr=0]
            ==
        :~  [%ordered-column name='col1' ascending=%.y]
            [%ordered-column name='col2' ascending=%.y]
            ==
        ~
        [~ [%da ~2023.12.25..7.15.0..1ef5]]
        ==
  =/  urql
    "create table ns1.my-table ".
    "(col1 @t,col2 @p,col3 @ud) ".
    "primary key (col1,col2) ".
    "as     OF ~2023.12.25..7.15.0..1ef5"
  %+  expect-eq
    !>  ~[expected]
    !>  (parse:parse(default-database 'db1') urql)
::
:: create table as of db-qualified name
++  test-create-table-10
  =/  expected
    :*  %create-table
        :*  %qualified-table  ship=~
            database='db2'  namespace='dbo'
            name='my-table'  ~
            ==
        :~  [%column name='col1' type=%t addr=0]
            [%column name='col2' type=%p addr=0]
            [%column name='col3' type=%ud addr=0]
            ==
        :~  [%ordered-column name='col1' ascending=%.y]
            [%ordered-column name='col2' ascending=%.y]
            ==
        ~
        [~ [%as-of-offset 5 %seconds]]
        ==
  =/  urql
    "create table db2..my-table ".
    "(col1 @t,col2 @p,col3 @ud) ".
    "primary key (col1,col2) ".
    "aS Of 5 seconds ago"
  %+  expect-eq
    !>  ~[expected]
    !>  (parse:parse(default-database 'db1') urql)
::
:: create table as of db-ns-qualified name
++  test-create-table-11
  =/  expected
    :*  %create-table
        :*  %qualified-table  ship=~
            database='db2'  namespace='ns1'
            name='my-table'  ~
            ==
        :~  [%column name='col1' type=%t addr=0]
            [%column name='col2' type=%p addr=0]
            [%column name='col3' type=%ud addr=0]
            ==
        :~  [%ordered-column name='col1' ascending=%.y]
            [%ordered-column name='col2' ascending=%.y]
            ==
        ~
        [~ [%as-of-offset 15 %minutes]]
        ==
  =/  urql
    "create table db2.ns1.my-table ".
    "(col1 @t,col2 @p,col3 @ud) ".
    "primary key (col1,col2) ".
    "as of 15 minutes ago"
  %+  expect-eq
    !>  ~[expected]
    !>  (parse:parse(default-database 'db1') urql)
++  test-fail-create-table-12
  =/  urql
    "create table my-table ".
    "(col1 @t,col2 @p,col3 @ud) ".
    "primary key (col1) ".
    "foreign key (col2) ".
    "reFerences db.ns.fk-table (col20) "
  %-  expect-fail
  |.  (parse:parse(default-database 'other-db') urql)
::
:: fail when database qualifier on foreign key table db..fk-table
++  test-fail-create-table-13
  =/  urql
    "create table my-table ".
    "(col1 @t,col2 @p,col3 @ud) ".
    "primary key (col1) ".
    "foreign key (col2) ".
    "reFerences db..fk-table (col20) "
  %-  expect-fail
  |.  (parse:parse(default-database 'other-db') urql)
::
:: foreign key on delete set default
++  test-create-table-14
  =/  fk
    :*  %foreign-key
        [%qualified-table ship=~ database='db1' namespace='dbo' name='my-table' ~]
        ~[%col2]
        :*  %qualified-table  ship=~  database='db1'
            namespace='dbo'  name='fk-table'  ~
            ==
        ~[%col20]
        ~[%delete-set-default]
        ==
  =/  expected
    :*  %create-table
        [%qualified-table ship=~ database='db1' namespace='dbo' name='my-table' ~]
        :~  [%column name='col1' type=%t addr=0]
            [%column name='col2' type=%p addr=0]
            ==
        ~[[%ordered-column name='col1' ascending=%.y]]
        ~[fk]
        ~
        ==
  %+  expect-eq
    !>  ~[expected]
    !>  %-  parse:parse(default-database 'db1')
        "create table my-table (col1 @t, col2 @p) ".
        "primary key (col1) foreign key (col2) ".
        "references fk-table (col20) on delete set default"
::
:: foreign key on update set default
++  test-create-table-15
  =/  fk
    :*  %foreign-key
        [%qualified-table ship=~ database='db1' namespace='dbo' name='my-table' ~]
        ~[%col2]
        :*  %qualified-table  ship=~  database='db1'
            namespace='dbo'  name='fk-table'  ~
            ==
        ~[%col20]
        ~[%update-set-default]
        ==
  =/  expected
    :*  %create-table
        [%qualified-table ship=~ database='db1' namespace='dbo' name='my-table' ~]
        :~  [%column name='col1' type=%t addr=0]
            [%column name='col2' type=%p addr=0]
            ==
        ~[[%ordered-column name='col1' ascending=%.y]]
        ~[fk]
        ~
        ==
  %+  expect-eq
    !>  ~[expected]
    !>  %-  parse:parse(default-database 'db1')
        "create table my-table (col1 @t, col2 @p) ".
        "primary key (col1) foreign key (col2) ".
        "references fk-table (col20) on update set default"
::
:: foreign key on delete set default on update cascade
++  test-create-table-16
  =/  fk
    :*  %foreign-key
        [%qualified-table ship=~ database='db1' namespace='dbo' name='my-table' ~]
        ~[%col2]
        :*  %qualified-table  ship=~  database='db1'
            namespace='dbo'  name='fk-table'  ~
            ==
        ~[%col20]
        ~[%delete-set-default %update-cascade]
        ==
  =/  expected
    :*  %create-table
        [%qualified-table ship=~ database='db1' namespace='dbo' name='my-table' ~]
        :~  [%column name='col1' type=%t addr=0]
            [%column name='col2' type=%p addr=0]
            ==
        ~[[%ordered-column name='col1' ascending=%.y]]
        ~[fk]
        ~
        ==
  %+  expect-eq
    !>  ~[expected]
    !>  %-  parse:parse(default-database 'db1')
        "create table my-table (col1 @t, col2 @p) ".
        "primary key (col1) foreign key (col2) ".
        "references fk-table (col20) ".
        "on delete set default on update cascade"
::
:: foreign key on delete restrict on update restrict produces empty integrity list
++  test-create-table-17
  =/  fk
    :*  %foreign-key
        [%qualified-table ship=~ database='db1' namespace='dbo' name='my-table' ~]
        ~[%col2]
        :*  %qualified-table  ship=~  database='db1'
            namespace='dbo'  name='fk-table'  ~
            ==
        ~[%col20]
        ~
        ==
  =/  expected
    :*  %create-table
        [%qualified-table ship=~ database='db1' namespace='dbo' name='my-table' ~]
        :~  [%column name='col1' type=%t addr=0]
            [%column name='col2' type=%p addr=0]
            ==
        ~[[%ordered-column name='col1' ascending=%.y]]
        ~[fk]
        ~
        ==
  %+  expect-eq
    !>  ~[expected]
    !>  %-  parse:parse(default-database 'db1')
        "create table my-table (col1 @t, col2 @p) ".
        "primary key (col1) foreign key (col2) ".
        "references fk-table (col20) ".
        "on delete restrict on update restrict"
::
:: fail when no action keyword used (retired)
++  test-fail-create-table-18
  =/  urql
    "create table my-table (col1 @t, col2 @p) ".
    "primary key (col1) foreign key (col2) ".
    "references fk-table (col20) on delete no action"
  %-  expect-fail
  |.  (parse:parse(default-database 'db1') urql)
::
:: delete
::
++  col1
  [%unqualified-column column='col1' alias=~]
++  col2
  [%unqualified-column column='col2' alias=~]
++  col3
  [%unqualified-column column='col3' alias=~]
++  col4
  [%unqualified-column column='col4' alias=~]
++  column-foo4      :^  %qualified-column
                         :*  %qualified-table
                             ship=~
                             database=%db1
                             namespace=%dbo
                             name=%foobar
                             alias=~
                             ==
                         name=%foo
                         alias=~
++  column-bar2      :^  %qualified-column
                         :*  %qualified-table
                             ship=~
                             database=%db1
                             namespace=%dbo
                             name=%foobar
                             alias=~
                             ==
                         name=%bar
                         alias=~
++  delete-pred
  [%eq [column-foo ~ ~] [column-bar ~ ~]]
++  delete-pred2
  [%eq [column-bar2 ~ ~] [column-foo4 ~ ~]]
++  cte-t1
  =/  q
    :*  %query  ~  scalars=~  predicate=~
        group-by=~  having=~
        select=select-all-columns  ~
        ==
  :*  %cte  name='t1'
      body=[%query q]
      ==
++  cte-foobar
  =/  qt
    :*  %qualified-table  ship=~
        database='db1'  namespace='dbo'
        name='foobar'  alias=~
        ==
  =/  from-clause
    [%from relation=qt as-of=~ joins=~]
  =/  q
    :*  %query  [~ from-clause]  scalars=~
        :*  %eq
            [col1 ~ ~]
            [[value-type=%ud value=2] ~ ~]
            ==
        group-by=~  having=~
        [%select top=~ columns=~[col3 col4]]
        ~
        ==
  :*  %cte  name='foobar'
      body=[%query q]
      ==
++  cte-bar
  =/  qt
    :*  %qualified-table  ship=~
        database='db1'  namespace='dbo'
        name='bar'  alias=~
        ==
  =/  from-clause
    [%from relation=qt as-of=~ joins=~]
  =/  q
    :*  %query  [~ from-clause]  scalars=~
        [%eq [col1 ~ ~] [col2 ~ ~]]
        group-by=~  having=~
        [%select top=~ columns=~[col2]]
        ~
        ==
  :*  %cte  name='bar'
      body=[%query q]
      ==
++  foo-table
  [%qualified-table ship=~ database='db1' namespace='dbo' name='foo' alias=~]
++  foobar-table
  [%qualified-table ~ 'db1' 'dbo' 'foobar' ~]
++  foo-table-t1
  :*  %qualified-table  ship=~
      database='db1'  namespace='dbo'
      name='foo'  alias=[~ 'T1']
      ==
::
:: delete with predicate 2X
++  test-delete-00
  =/  expected1  [%crud-txn ctes=~ body=[%delete [%delete scalars=~ table=foo-table ~ delete-pred]]]
  =/  expected2  [%crud-txn ctes=~ body=[%delete [%delete scalars=~ table=foobar-table ~ delete-pred2]]]
  =/  urql  "delete from foo  where foo=bar; DELETE foobar where bar=foo"
  %+  expect-eq
    !>  ~[expected1 expected2]
    !>  (parse:parse(default-database 'db1') urql)
::
:: delete with predicate as of now
++  test-delete-01
  =/  expected  [%crud-txn ctes=~ body=[%delete [%delete scalars=~ table=foo-table ~ delete-pred]]]
  %+  expect-eq
    !>  ~[expected]
    !>  %-  parse:parse(default-database 'db1')
            "delete from foo as of now where foo=bar"
::
:: delete with predicate as of ~2023.12.25..7.15.0..1ef5
++  test-delete-02
  =/  expected  :*  %crud-txn
                    ctes=~
                    :-  %delete
                    :*  %delete
                        scalars=~
                        table=foo-table
                        [~ [%da ~2023.12.25..7.15.0..1ef5]]
                        delete-pred
                        ==
                    ==
  %+  expect-eq
    !>  ~[expected]
    !>  %-  parse:parse(default-database 'db1')
            "delete from foo as of ~2023.12.25..7.15.0..1ef5 where foo=bar"
::
:: delete with predicate as of 5 seconds ago
++  test-delete-03
  =/  expected  :*  %crud-txn
                    ctes=~
                    :-  %delete
                    :*  %delete
                        scalars=~
                        table=foo-table
                        [~ [%as-of-offset 5 %seconds]]
                        delete-pred
                        ==
                    ==
  %+  expect-eq
    !>  ~[expected]
    !>  %-  parse:parse(default-database 'db1')
            "delete from foo as of 5 seconds ago where foo=bar"
::
:: delete with one cte and predicate
++  test-delete-04
  =/  expected  [%crud-txn ctes=~[cte-t1] body=[%delete [%delete scalars=~ table=foo-table ~ delete-pred]]]
  %+  expect-eq
    !>  ~[expected]
    !>  %-  parse:parse(default-database 'db1')
            "with (select *) as t1 delete from foo where foo=bar"
::
:: delete with one cte and predicate as of now
++  test-delete-05
  =/  expected  [%crud-txn ctes=~[cte-t1] body=[%delete [%delete scalars=~ table=foo-table ~ delete-pred]]]
  %+  expect-eq
    !>  ~[expected]
    !>  %-  parse:parse(default-database 'db1')
            "with (select *) as t1 delete from foo as of now where foo=bar"
::
:: delete with one cte and predicate as of ~2023.12.25..7.15.0..1ef5
++  test-delete-06
  =/  expected  :*  %crud-txn
                    ctes=~[cte-t1]
                    :-  %delete
                    :*  %delete
                        scalars=~
                        table=foo-table
                        [~ [%da ~2023.12.25..7.15.0..1ef5]]
                        delete-pred
                        ==
                    ==
  %+  expect-eq
    !>  ~[expected]
    !>  %-  parse:parse(default-database 'db1')
            "with (select *) as t1 delete from ".
            "foo as of ~2023.12.25..7.15.0..1ef5 where foo=bar"
::
:: delete with one cte and predicate as of 5 seconds ago
++  test-delete-07
  =/  expected  :*  %crud-txn
                    ctes=~[cte-t1]
                    :-  %delete
                    :*  %delete
                        scalars=~
                        table=foo-table
                        [~ [%as-of-offset 5 %seconds]]
                        delete-pred
                        ==
                    ==
  %+  expect-eq
    !>  ~[expected]
    !>  %-  parse:parse(default-database 'db1')
            "with (select *) as t1 delete from foo as of 5 seconds ago ".
            "where foo=bar"
::
:: delete with two ctes and predicate
++  test-delete-08
  =/  expected  [%crud-txn ctes=~[cte-t1 cte-foobar] body=[%delete [%delete scalars=~ table=foo-table ~ delete-pred]]]
  %+  expect-eq
    !>  ~[expected]
    !>  %-  parse:parse(default-database 'db1')
            "with (select *) as t1, ".
            "(from foobar where col1=2 select col3, col4) as foobar ".
            "delete from foo where foo=bar"
::
:: delete with two ctes and predicate as of now
++  test-delete-09
  =/  expected  [%crud-txn ctes=~[cte-t1 cte-foobar] body=[%delete [%delete scalars=~ table=foo-table ~ delete-pred]]]
  %+  expect-eq
    !>  ~[expected]
    !>  %-  parse:parse(default-database 'db1')
            "with (select *) as t1, ".
            "(from foobar where col1=2 select col3, col4) as foobar ".
            "delete from foo as of now where foo=bar"
::
:: delete with two ctes and predicate as of ~2023.12.25..7.15.0..1ef5
++  test-delete-10
  =/  expected  :*  %crud-txn
                    ctes=~[cte-t1 cte-foobar]
                    :-  %delete
                    :*  %delete
                        scalars=~
                        table=foo-table
                        [~ [%da ~2023.12.25..7.15.0..1ef5]]
                        delete-pred
                        ==
                    ==
  %+  expect-eq
    !>  ~[expected]
    !>  %-  parse:parse(default-database 'db1')
            "with (select *) as t1, ".
            "(from foobar where col1=2 select col3, col4) as foobar ".
            "delete from foo as of ~2023.12.25..7.15.0..1ef5 where foo=bar"
::
:: delete with two ctes and predicate as of 5 seconds ago
++  test-delete-11
  =/  expected  :*  %crud-txn
                    ctes=~[cte-t1 cte-foobar]
                    :-  %delete
                    :*  %delete
                        scalars=~
                        table=foo-table
                        [~ [%as-of-offset 5 %seconds]]
                        delete-pred
                        ==
                    ==
  %+  expect-eq
    !>  ~[expected]
    !>  %-  parse:parse(default-database 'db1')
            "with (select *) as t1, ".
            "(from foobar where col1=2 select col3, col4) as foobar delete ".
            "from foo as of 5 seconds ago where foo=bar"
::
:: delete with three ctes and predicate
++  test-delete-12
  =/  expected  [%crud-txn ctes=~[cte-t1 cte-foobar cte-bar] body=[%delete [%delete scalars=~ foo-table ~ delete-pred]]]
  %+  expect-eq
    !>  ~[expected]
    !>  %-  parse:parse(default-database 'db1')
            "with (select *) as t1, ".
            "(from foobar where col1=2 select col3, col4) as foobar, ".
            "(from bar where col1=col2 select col2) as bar ".
            "delete from foo where foo=bar"
::
:: delete with three ctes and predicate as of now
++  test-delete-13
  =/  expected  [%crud-txn ctes=~[cte-t1 cte-foobar cte-bar] body=[%delete [%delete scalars=~ foo-table ~ delete-pred]]]
  %+  expect-eq
    !>  ~[expected]
    !>  %-  parse:parse(default-database 'db1')
            "with (select *) as t1, ".
            "(from foobar where col1=2 select col3, col4) as foobar, ".
            "(from bar where col1=col2 select col2) as bar ".
            "delete from foo aS  Of    NOw where foo=bar"
::
:: delete with three ctes and predicate as of ~2023.12.25..7.15.0..1ef5
++  test-delete-14
  =/  expected  :*  %crud-txn
                    ctes=~[cte-t1 cte-foobar cte-bar]
                    :-  %delete
                    :*  %delete
                        scalars=~
                        table=foo-table
                        [~ [%da ~2023.12.25..7.15.0..1ef5]]
                        delete-pred
                        ==
                    ==
  %+  expect-eq
    !>  ~[expected]
    !>  %-  parse:parse(default-database 'db1')
            "with (select *) as t1, ".
            "(from foobar where col1=2 select col3, col4) as foobar, ".
            "(from bar where col1=col2 select col2) as bar ".
            "delete from foo as of ~2023.12.25..7.15.0..1ef5 where foo=bar"
::
:: delete with three ctes and predicate as of 5 seconds ago
++  test-delete-15
  =/  expected  :*  %crud-txn
                    ctes=~[cte-t1 cte-foobar cte-bar]
                    :-  %delete
                    :*  %delete
                        scalars=~
                        table=foo-table
                        [~ [%as-of-offset 5 %seconds]]
                        delete-pred
                        ==
                    ==
  %+  expect-eq
    !>  ~[expected]
    !>  %-  parse:parse(default-database 'db1')
            "with (select *) as t1, ".
            "(from foobar where col1=2 select col3, col4) as foobar, ".
            "(from bar where col1=col2 select col2) as bar ".
            "delete from foo as of 5 seconds ago where foo=bar"
::
:: delete with 2 scalars, no cte
++  test-delete-16
  =/  sc1  :*  %scalar
               name='add-10'
               :*  %arithmetic
                   operator=%lus
                   left=[%unqualified-column 'col3' ~]
                   right=[p=%ud q=10]
                   ==
               ==
  =/  sc2  :*  %scalar
               name='add-20'
               :*  %arithmetic
                   operator=%lus
                   left=[%unqualified-column 'col3' ~]
                   right=[p=%ud q=20]
                     ==
               ==
  =/  expected  :*  %crud-txn
                    ctes=~
                    :-  %delete
                    :*  %delete
                        scalars=~[sc1 sc2]
                        table=foo-table
                        as-of=~
                        delete-pred
                        ==
                    ==
  %+  expect-eq
    !>  ~[expected]
    !>  %-  parse:parse(default-database 'db1')
            "scalars add-10 col3 + 10 end add-20 col3 + 20 end ".
            "delete from foo where foo=bar"
::
:: delete with 2 scalars and 1 cte
++  test-delete-17
  =/  sc1  :*  %scalar
               name='add-10'
               :*  %arithmetic
                   operator=%lus
                   left=[%unqualified-column 'col3' ~]
                   right=[p=%ud q=10]
                   ==
               ==
  =/  sc2  :*  %scalar
               name='add-20'
               :*  %arithmetic
                   operator=%lus
                   left=[%unqualified-column 'col3' ~]
                   right=[p=%ud q=20]
                   ==
               ==
  =/  expected  :*  %crud-txn
                    ctes=~[cte-t1]
                    :-  %delete
                    :*  %delete
                        scalars=~[sc1 sc2]
                        table=foo-table
                        as-of=~
                        delete-pred
                        ==
                    ==
  %+  expect-eq
    !>  ~[expected]
    !>  %-  parse:parse(default-database 'db1')
            "with (select *) as t1 ".
            "scalars add-10 col3 + 10 end add-20 col3 + 20 end ".
            "delete from foo where foo=bar"
::
:: drop database
::
:: tests 1, 2, 3, 5, and extra whitespace characters, force db.name, name
++  test-drop-database-1
  =/  expected1  [%drop-database name='name' force=%.n]
  =/  expected2  [%drop-database name='name' force=%.y]
  %+  expect-eq
    !>  ~[expected1 expected2]
    !>  %-  parse:parse(default-database 'other-db')
        "droP  Database  name;".
        "droP \0d\09 DataBase FORce  \0a name"
::
:: leading and trailing whitespace characters, end delimiter not required on single, force name
++  test-drop-database-2
  %+  expect-eq
    !>  ~[[%drop-database name='name' force=%.y]]
    !>  %-  parse:parse(default-database 'other-db')
        "   \09drOp\0d\09  dAtabaSe\0a force name "
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
  =/  expected1
    :*  %drop-index  name='my-index'
        :*  %qualified-table  ship=~
            database='db'  namespace='ns'
            name='name'  ~
            ==
        ~
        ==
  =/  expected2
    :*  %drop-index  name='my-index'
        :*  %qualified-table  ship=~
            database='db'  namespace='dbo'
            name='name'  ~
            ==
        ~
        ==
  %+  expect-eq
    !>  ~[expected1 expected2]
    !>  %-  parse:parse(default-database 'other-db')
        "droP  inDex my-index On db.ns.name;".
        "droP  index my-index oN \0a db..name"
::
:: leading and trailing whitespace characters, end delimiter not required on single, ns.name
++  test-drop-index-2
  %+  expect-eq
    !>  :~  :*  %drop-index  name='my-index'
                :*  %qualified-table  ship=~
                    database='other-db'
                    namespace='ns'
                    name='name'  ~
                    ==
                ~
                ==
            ==
    !>  %-  parse:parse(default-database 'other-db')
        "   \09drop\0d\09  index\0d ".
        "my-index \0a On ns.name   "
::
:: :: fail when database qualifier is not a term
++  test-fail-drop-index-3
  %-  expect-fail
  |.  %-  parse:parse(default-database 'other-db')
      "DROP index my-index on Db.ns.name"
::
:: fail when database qualifier is not a term
++  test-fail-drop-index-4
  %-  expect-fail
  |.  %-  parse:parse(default-database 'other-db')
      "DROP index my-index on Db.ns.name"
::
:: fail when namespace qualifier is not a term
++  test-fail-drop-index-5
  %-  expect-fail
  |.  %-  parse:parse(default-database 'other-db')
      "DROP index my-index on db.nS.name"
::
:: fail when index name is not a term
++  test-fail-drop-index-6
  %-  expect-fail
  |.  %-  parse:parse(default-database 'other-db')
      "DROP index my-index on db.ns.nAme"
::
:: fail when index name is qualified with ship
++  test-fail-drop-index-7
  %-  expect-fail
  |.  %-  parse:parse(default-database 'other-db')
      "DROP index my-index on ~zod.db.ns.nAme"
::
:: drop namespace
::
:: tests 1, 2, 3, 5, and extra whitespace characters, force db.name, name
++  test-drop-namespace-00
  =/  expected1
    :*  %drop-namespace  database-name='db'
        name='name'  force=%.n  as-of=~
        ==
  =/  expected2
    :*  %drop-namespace  database-name='other-db'
        name='name'  force=%.y  as-of=~
        ==
  %+  expect-eq
    !>  ~[expected1 expected2]
    !>  %-  parse:parse(default-database 'other-db')
        "droP  Namespace  db.name;".
        "droP \0d\09 Namespace FORce  \0a name"
::
:: leading and trailing whitespace characters, end delimiter not required on single, force name
++  test-drop-namespace-01
  =/  expected
    :*  %drop-namespace  database-name='other-db'
        name='name'  force=%.y  as-of=~
        ==
  %+  expect-eq
    !>  ~[expected]
    !>  %-  parse:parse(default-database 'other-db')
        "   \09drOp\0d\09  naMespace\0a force name "
::
:: db.name
++  test-drop-namespace-02
  %+  expect-eq
    !>  ~[[%drop-namespace database-name='db' name='name' force=%.n as-of=~]]
    !>  (parse:parse(default-database 'other-db') "drop namespace db.name")
::
::  name, as of now
++  test-drop-namespace-03
  =/  expected
    :*  %drop-namespace  database-name='other-db'
        name='ns1'  force=%.n  as-of=~
        ==
  %+  expect-eq
    !>  ~[expected]
    !>  %-  parse:parse(default-database 'other-db')
        "drop namespace ns1 AS OF NOW"
::
::  name, as of date
++  test-drop-namespace-04
  =/  expected
    :*  %drop-namespace  database-name='other-db'
        name='ns1'  force=%.n
        as-of=[~ [%da ~2023.12.25..7.15.0..1ef5]]
        ==
  %+  expect-eq
    !>  ~[expected]
    !>  %-  parse:parse(default-database 'other-db')
        "drop namespace ns1 ".
        "as of ~2023.12.25..7.15.0..1ef5"
::
::  name, as of 5 seconds ago
++  test-drop-namespace-05
  =/  expected
    :*  %drop-namespace  database-name='other-db'
        name='ns1'  force=%.n
        as-of=[~ [%as-of-offset 5 %seconds]]
        ==
  %+  expect-eq
    !>  ~[expected]
    !>  %-  parse:parse(default-database 'other-db')
        "drop namespace ns1 as of 5 seconds ago"
::
::  force name as of now
++  test-drop-namespace-06
  =/  expected
    :*  %drop-namespace  database-name='other-db'
        name='ns1'  force=%.y  as-of=~
        ==
  %+  expect-eq
    !>  ~[expected]
    !>  %-  parse:parse(default-database 'other-db')
        "drop namespace force ns1 as of now"
::
::  force name as of date
++  test-drop-namespace-07
  =/  expected
    :*  %drop-namespace  database-name='other-db'
        name='ns1'  force=%.y
        as-of=[~ [%da ~2023.12.25..7.15.0..1ef5]]
        ==
  %+  expect-eq
    !>  ~[expected]
    !>  %-  parse:parse(default-database 'other-db')
        "drop namespace force ns1 ".
        "as of ~2023.12.25..7.15.0..1ef5"
::
::  force name as of 5 seconds ago
++  test-drop-namespace-08
  =/  expected
    :*  %drop-namespace  database-name='other-db'
        name='ns1'  force=%.y
        as-of=[~ [%as-of-offset 5 %seconds]]
        ==
  %+  expect-eq
    !>  ~[expected]
    !>  %-  parse:parse(default-database 'other-db')
        "drop namespace force ns1 ".
        "as of 5 seconds ago"
::
:: db name as of now
++  test-drop-namespace-09
  %+  expect-eq
    !>  ~[[%drop-namespace database-name='db1' name='ns1' force=%.n as-of=~]]
    !>  %-  parse:parse(default-database 'other-db')
        "drop namespace db1.ns1 as of now"
::
:: db name as of date
++  test-drop-namespace-10
  =/  expected
    :*  %drop-namespace  database-name='db1'
        name='ns1'  force=%.n
        as-of=[~ [%da ~2023.12.25..7.15.0..1ef5]]
        ==
  %+  expect-eq
    !>  ~[expected]
    !>  %-  parse:parse(default-database 'other-db')
        "drop namespace db1.ns1 ".
        "as of ~2023.12.25..7.15.0..1ef5"
::
:: db name as of 5 seconds ago
++  test-drop-namespace-11
  =/  expected
    :*  %drop-namespace  database-name='db1'
        name='ns1'  force=%.n
        as-of=[~ [%as-of-offset 5 %seconds]]
        ==
  %+  expect-eq
    !>  ~[expected]
    !>  %-  parse:parse(default-database 'other-db')
        "drop namespace db1.ns1 ".
        "as of 5 seconds ago"
::
:: force db name as of now
++  test-drop-namespace-12
  %+  expect-eq
    !>  ~[[%drop-namespace database-name='db1' name='ns1' force=%.y as-of=~]]
    !>  %-  parse:parse(default-database 'other-db')
        "drop namespace force db1.ns1 as of now"
::
:: force db name as of ~2023.12.25..7.15.0..1ef5
++  test-drop-namespace-13
  =/  expected
    :*  %drop-namespace  database-name='db1'
        name='ns1'  force=%.y
        as-of=[~ [%da ~2023.12.25..7.15.0..1ef5]]
        ==
  %+  expect-eq
    !>  ~[expected]
    !>  %-  parse:parse(default-database 'other-db')
        "drop namespace force db1.ns1 ".
        "as of ~2023.12.25..7.15.0..1ef5"
::
:: force db name as of 15 minutes ago
++  test-drop-namespace-14
  =/  expected
    :*  %drop-namespace  database-name='db1'
        name='ns1'  force=%.y
        as-of=[~ [%as-of-offset 15 %minutes]]
        ==
  %+  expect-eq
    !>  ~[expected]
    !>  %-  parse:parse(default-database 'other-db')
        "drop namespace force db1.ns1 ".
        "as of 15 minutes ago"
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
  =/  qt
    :*  %qualified-table  ship=~
        database='db'  namespace='ns'
        name='name'  ~
        ==
  =/  expected1
    [%drop-table table=qt force=%.y as-of=~]
  =/  expected2
    [%drop-table table=qt force=%.n as-of=~]
  %+  expect-eq
    !>  ~[expected1 expected2]
    !>  %-  parse:parse(default-database 'other-db')
        "droP  table FORce db.ns.name;".
        "droP  table  \0a db.ns.name"
::
:: leading and trailing whitespace characters, end delimiter not required on single, force db..name
++  test-drop-table-01
  =/  expected
    :*  %drop-table
        :*  %qualified-table  ship=~
            database='db'  namespace='dbo'
            name='name'  ~
            ==
        force=%.y  as-of=~
        ==
  %+  expect-eq
    !>  ~[expected]
    !>  %-  parse:parse(default-database 'other-db')
        "   \09drop\0d\09  table\0aforce db..name "
::
:: db..name
++  test-drop-table-02
  =/  expected
    :*  %drop-table
        :*  %qualified-table  ship=~
            database='db'  namespace='dbo'
            name='name'  ~
            ==
        force=%.n  as-of=~
        ==
  %+  expect-eq
    !>  ~[expected]
    !>  %-  parse:parse(default-database 'other-db')
        "drop table db..name"
::
:: force ns.name
++  test-drop-table-03
  =/  expected
    :*  %drop-table
        :*  %qualified-table  ship=~
            database='other-db'  namespace='ns'
            name='name'  ~
            ==
        force=%.y  as-of=~
        ==
  %+  expect-eq
    !>  ~[expected]
    !>  %-  parse:parse(default-database 'other-db')
        "drop table force ns.name"
::
:: ns.name
++  test-drop-table-04
  =/  expected
    :*  %drop-table
        :*  %qualified-table  ship=~
            database='other-db'  namespace='ns'
            name='name'  ~
            ==
        force=%.n  as-of=~
        ==
  %+  expect-eq
    !>  ~[expected]
    !>  %-  parse:parse(default-database 'other-db')
        "drop table ns.name"
::
:: force name
++  test-drop-table-05
  =/  expected
    :*  %drop-table
        :*  %qualified-table  ship=~
            database='other-db'  namespace='dbo'
            name='name'  ~
            ==
        force=%.y  as-of=~
        ==
  %+  expect-eq
    !>  ~[expected]
    !>  %-  parse:parse(default-database 'other-db')
        "DROP table FORCE name"
::
:: name
++  test-drop-table-06
  =/  expected
    :*  %drop-table
        :*  %qualified-table  ship=~
            database='other-db'  namespace='dbo'
            name='name'  ~
            ==
        force=%.n  as-of=~
        ==
  %+  expect-eq
    !>  ~[expected]
    !>  %-  parse:parse(default-database 'other-db')
        "DROP table name"
::
:: force db.ns.name as of now
++  test-drop-table-07
  =/  expected
    :*  %drop-table
        :*  %qualified-table  ship=~
            database='db'  namespace='ns'
            name='name'  ~
            ==
        force=%.y  as-of=~
        ==
  %+  expect-eq
    !>  ~[expected]
    !>  %-  parse:parse(default-database 'other-db')
        "drop table force db.ns.name as of now"
::
:: force db..name as of date
++  test-drop-table-08
  =/  expected
    :*  %drop-table
        :*  %qualified-table  ship=~
            database='db'  namespace='dbo'
            name='name'  ~
            ==
        force=%.y
        as-of=[~ [%da ~2023.12.25..7.15.0..1ef5]]
        ==
  %+  expect-eq
    !>  ~[expected]
    !>  %-  parse:parse(default-database 'other-db')
        "drop table force db..name ".
        "as of ~2023.12.25..7.15.0..1ef5"
::
:: force ns.name as of weeks ago
++  test-drop-table-09
  =/  expected
    :*  %drop-table
        :*  %qualified-table  ship=~
            database='other-db'  namespace='ns'
            name='name'  ~
            ==
        force=%.y
        as-of=[~ [%as-of-offset 10 %weeks]]
        ==
  %+  expect-eq
    !>  ~[expected]
    !>  %-  parse:parse(default-database 'other-db')
        "drop table force ns.name ".
        "as of 10 weeks ago"
::
:: name as of now
++  test-drop-table-10
  =/  expected
    :*  %drop-table
        :*  %qualified-table  ship=~
            database='db'  namespace='ns'
            name='name'  ~
            ==
        force=%.n  as-of=~
        ==
  %+  expect-eq
    !>  ~[expected]
    !>  %-  parse:parse(default-database 'other-db')
        "drop table db.ns.name as of now"
::
:: db..name as of date
++  test-drop-table-11
  =/  expected
    :*  %drop-table
        :*  %qualified-table  ship=~
            database='db'  namespace='dbo'
            name='name'  ~
            ==
        force=%.n
        as-of=[~ [%da ~2023.12.25..7.15.0..1ef5]]
        ==
  %+  expect-eq
    !>  ~[expected]
    !>  %-  parse:parse(default-database 'other-db')
        "drop table db..name ".
        "as of ~2023.12.25..7.15.0..1ef5"
::
:: name as of weeks ago
++  test-drop-table-12
  =/  expected
    :*  %drop-table
        :*  %qualified-table  ship=~
            database='other-db'  namespace='dbo'
            name='name'  ~
            ==
        force=%.n
        as-of=[~ [%as-of-offset 10 %weeks]]
        ==
  %+  expect-eq
    !>  ~[expected]
    !>  %-  parse:parse(default-database 'other-db')
        "drop table name as of 10 weeks ago"
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
  =/  qt
    :*  %qualified-table  ship=~
        database='db'  namespace='ns'
        name='name'  ~
        ==
  =/  expected1  [%drop-view view=qt force=%.y]
  =/  expected2  [%drop-view view=qt force=%.n]
  %+  expect-eq
    !>  ~[expected1 expected2]
    !>  %-  parse:parse(default-database 'other-db')
        "droP  View FORce db.ns.name;".
        "droP  View  \0a db.ns.name"
::
:: leading and trailing whitespace characters, end delimiter not required on single, force db..name
++  test-drop-view-2
  =/  expected
    :*  %drop-view
        :*  %qualified-table  ship=~
            database='db'  namespace='dbo'
            name='name'  ~
            ==
        force=%.y
        ==
  %+  expect-eq
    !>  ~[expected]
    !>  %-  parse:parse(default-database 'other-db')
        "   \09drop\0d\09  vIew\0aforce db..name "
::
:: db..name
++  test-drop-view-3
  =/  expected
    :*  %drop-view
        :*  %qualified-table  ship=~
            database='db'  namespace='dbo'
            name='name'  ~
            ==
        force=%.n
        ==
  %+  expect-eq
    !>  ~[expected]
    !>  %-  parse:parse(default-database 'other-db')
        "drop view db..name"
::
:: force ns.name
++  test-drop-view-4
  =/  expected
    :*  %drop-view
        :*  %qualified-table  ship=~
            database='other-db'  namespace='ns'
            name='name'  ~
            ==
        force=%.y
        ==
  %+  expect-eq
    !>  ~[expected]
    !>  %-  parse:parse(default-database 'other-db')
        "drop view force ns.name"
::
:: ns.name
++  test-drop-view-5
  =/  expected
    :*  %drop-view
        :*  %qualified-table  ship=~
            database='other-db'  namespace='ns'
            name='name'  ~
            ==
        force=%.n
        ==
  %+  expect-eq
    !>  ~[expected]
    !>  %-  parse:parse(default-database 'other-db')
        "drop view ns.name"
::
:: force name
++  test-drop-view-6
  =/  expected
    :*  %drop-view
        :*  %qualified-table  ship=~
            database='other-db'  namespace='dbo'
            name='name'  ~
            ==
        force=%.y
        ==
  %+  expect-eq
    !>  ~[expected]
    !>  %-  parse:parse(default-database 'other-db')
        "DROP VIEW FORCE name"
::
:: name
++  test-drop-view-7
  =/  expected
    :*  %drop-view
        :*  %qualified-table  ship=~
            database='other-db'  namespace='dbo'
            name='name'  ~
            ==
        force=%.n
        ==
  %+  expect-eq
    !>  ~[expected]
    !>  %-  parse:parse(default-database 'other-db')
        "DROP VIEW name"
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
:: truncate table
::
:: tests 1, 2, 3, 5, and extra whitespace characters
++  test-truncate-table-01
  =/  expected1
    :*  %truncate-table
        :*  %qualified-table  ship=[~ ~zod]
            database='db'  namespace='ns'
            name='name'  ~
            ==
        as-of=~
        ==
  =/  expected2
    :*  %truncate-table
        :*  %qualified-table
            ship=[~ ~sampel-palnet]
            database='db'  namespace='dbo'
            name='name'  ~
            ==
        as-of=~
        ==
  %+  expect-eq
    !>  ~[expected1 expected2]
    !>  %-  parse:parse(default-database 'dummy')
        " \0atrUncate TAble\0d ".
        "~zod.db.ns.name\0a; ".
        "truncate table ~sampel-palnet.db..name"
::
:: leading and trailing whitespace characters, end delimiter not required on single, db.ns.name
++  test-truncate-table-02
  =/  expected
    :*  %truncate-table
        :*  %qualified-table  ship=~
            database='db'  namespace='ns'
            name='name'  ~
            ==
        as-of=~
        ==
  %+  expect-eq
    !>  ~[expected]
    !>  %-  parse:parse(default-database 'dummy')
        "   \09truncate\0d\09  TaBle\0a db.ns.name "
::
:: db..name
++  test-truncate-table-03
  =/  expected
    :*  %truncate-table
        :*  %qualified-table  ship=~
            database='db'  namespace='dbo'
            name='name'  ~
            ==
        as-of=~
        ==
  %+  expect-eq
    !>  ~[expected]
    !>  %-  parse:parse(default-database 'dummy')
        "truncate table db..name"
::
:: ns.name
++  test-truncate-table-04
  =/  expected
    :*  %truncate-table
        :*  %qualified-table  ship=~
            database='dummy'  namespace='ns'
            name='name'  ~
            ==
        as-of=~
        ==
  %+  expect-eq
    !>  ~[expected]
    !>  %-  parse:parse(default-database 'dummy')
        "truncate table ns.name"
::
:: name
++  test-truncate-table-05
  =/  expected
    :*  %truncate-table
        :*  %qualified-table  ship=~
            database='dummy'  namespace='dbo'
            name='name'  ~
            ==
        as-of=~
        ==
  %+  expect-eq
    !>  ~[expected]
    !>  %-  parse:parse(default-database 'dummy')
        "truncate table name"
::
:: truncate as of now
++  test-truncate-table-06
  =/  expected
    :*  %truncate-table
        :*  %qualified-table  ship=~
            database=%db1  namespace='dbo'
            name='tbl1'  ~
            ==
        as-of=~
        ==
  %+  expect-eq
    !>  ~[expected]
    !>  %-  parse:parse(default-database 'db1')
        "truncate table tbl1 as of now"
::
:: utruncate as of ~2023.12.25..7.15.0..1ef5
++  test-truncate-table-07
  =/  expected
    :*  %truncate-table
        :*  %qualified-table  ship=~
            database=%db1  namespace='dbo'
            name='tbl1'  ~
            ==
        as-of=[~ [%da ~2023.12.25..7.15.0..1ef5]]
        ==
  %+  expect-eq
    !>  ~[expected]
    !>  %-  parse:parse(default-database 'db1')
        "truncate table tbl1 ".
        "as of ~2023.12.25..7.15.0..1ef5"
::
:: truncate as of 4 seconds ago
++  test-truncate-table-08
  =/  expected
    :*  %truncate-table
        :*  %qualified-table  ship=~
            database=%db1  namespace='dbo'
            name='tbl1'  ~
            ==
        as-of=[~ [%as-of-offset 4 %seconds]]
        ==
  %+  expect-eq
    !>  ~[expected]
    !>  %-  parse:parse(default-database 'db1')
        "truncate table tbl1 as of 4 seconds ago"
::
:: fail when database qualifier is not a term
++  test-fail-truncate-table-01
  %-  expect-fail
  |.  (parse:parse(default-database 'dummy') "truncate table Db.ns.name")
::
:: fail when namespace qualifier is not a term
++  test-fail-truncate-table-02
  %-  expect-fail
  |.  (parse:parse(default-database 'dummy') "truncate table db.nS.name")
::
:: fail when table name is not a term
++  test-fail-truncate-table-03
  %-  expect-fail
  |.  (parse:parse(default-database 'dummy') "truncate table db.ns.nAme")
::
:: fail when table name is not a term
++  test-fail-truncate-table-04
  %-  expect-fail
  |.  (parse:parse(default-database 'dummy') "truncate table db.ns.nAme")
::
:: fail when ship is invalid
++  test-fail-truncate-table-05
  %-  expect-fail
  |.  %-  parse:parse(default-database 'dummy')
      "truncate table ~shitty-shippp db.ns.nAme"
::
::  select
::
::  NOTE: SELECT all literal types is in test/lib/queries/hoon
::
++  column-foo             :^  %qualified-column
                               :*  %qualified-table
                                   ship=~
                                   database=%db1
                                   namespace=%dbo
                                   name=%foo
                                   alias=~
                                 ==
                               name=%foo
                               alias=~
++  column-bar             :^  %qualified-column
                               :*  %qualified-table
                                   ship=~
                                   database=%db1
                                   namespace=%dbo
                                   name=%foo
                                   alias=~
                                   ==
                               name=%bar
                               alias=~
++  literal-1              [p=%ud q=1]
++  select-all-columns  [%select top=~ columns=~[[%all %all]]]
++  from-foo
  [~ [%from relation=foo-table as-of=~ joins=~]]
++  aliased-columns-1
  =/  qt1
    :*  %qualified-table  ship=~
        database='db'  namespace='ns'
        name='table'  ~
        ==
  =/  qt2
    :*  %qualified-table  ship=~
        database='db1'  namespace='dbo'
        name='table-alias'  ~
        ==
  =/  qt3
    :*  %qualified-table  ship=~
        database='db'  namespace='dbo'
        name='table'  ~
        ==
  :~  [%unqualified-column column='x1' alias=[~ 'foo']]
      :*  %qualified-column  qt1
          column='col1'  alias=[~ 'foo2']
          ==
      :*  %qualified-column  qt2
          column='name'  alias=[~ 'bar']
          ==
      :*  %qualified-column  qt3
          column='col2'  alias=[~ 'bar2']
          ==
      [%selected-value value=literal-1 alias=[~ %foobar]]
      :*  %selected-value
          value=[value-type=%p value=0]
          alias=[~ 'f1']
          ==
      :*  %selected-value
          value=[value-type=%t value='cord']
          alias=[~ 'bar3']
          ==
      ==
++  mixed-all
  =/  qt1
    :*  %qualified-table  ship=~
        database='db'  namespace='dbo'
        name='t1'  ~
        ==
  =/  qt2
    :*  %qualified-table  ship=~
        database='db1'  namespace='dbo'
        name='t1'  alias=[~ 'T1']
        ==
  :~  [%all-object qualifier=qt1]
      [%unqualified-column column='foo' alias=[~ 'foobar']]
      [%unqualified-column column='bar' alias=~]
      [%all %all]
      [%all-object qualifier=qt2]
      ==
++  aggregates
  =/  agg-col
    :*  %qualified-column
        :*  %qualified-table  ship=~
            database='UNKNOWN'
            namespace='COLUMN-OR-CTE'
            name='foobar'  ~
            ==
        column='foobar'  alias=~
        ==
  :~  column-foo
      :*  %selected-aggregate
          [%aggregate function='count' source=column-foo]
          alias=[~ 'CountFoo']
          ==
      :*  %selected-aggregate
          [%aggregate function='count' source=column-bar]
          alias=~
          ==
      :*  %selected-aggregate
          [%aggregate function='sum' source=column-bar]
          alias=~
          ==
      :*  %selected-aggregate
          [%aggregate function='sum' source=agg-col]
          alias=[~ 'foobar']
          ==
      ==
++  from-t1
  =/  qt
    :*  %qualified-table  ship=~
        database='db1'  namespace='dbo'
        name='t1'  alias=[~ 'T1']
        ==
  [~ [%from relation=qt as-of=~ joins=~]]
++  from-aggregate
    =/  qt
      :*  %qualified-table  ship=~
          database='db1'  namespace='dbo'
          name='tbl1'  alias=~
          ==
    :-  ~
        :^  %from
            relation=qt
            as-of=~
            :~  :*  %joined-relation
                    join=%join
                    :*  %qualified-table
                        ship=~
                        database=%db1
                        namespace=%dbo
                        name=%tbl2
                        alias=~
                        ==
                    as-of=~
                    predicate=~
                    ==
                ==
::
::  simplest possible select (bunt)
++  test-select-01
  =/  select  "select 0"
  =/  query
    :*  %query  ~  scalars=~  ~
        group-by=~  having=~
        [%select top=~ columns=~[[%selected-value [value-type=%ud value=0] ~]]]
        ~
        ==
  %+  expect-eq
    !>  ~[[%crud-txn ctes=~ body=[%query query]]]
    !>  (parse:parse(default-database 'db1') select)
::
::  select cord-like literal forms
++  test-select-cord-literal-forms-00
  =/  query
    :*  %query  ~  scalars=~  ~
        group-by=~  having=~
        :+  %select  top=~
            :~  [%selected-value [value-type=%t value='foo'] ~]
                [%selected-value [value-type=%tas value=%foo] ~]
                [%selected-value [value-type=%ta value=~.foo_bar] ~]
                ==
        ~
        ==
  %+  expect-eq
    !>  ~[[%crud-txn ctes=~ body=[%query query]]]
    !>  %-  parse:parse(default-database 'db1')
        "select 'foo', %foo, ~.foo_bar"
::
::  fail on malformed term literal
++  test-fail-cord-literal-forms-00
  %-  expect-fail
  |.  %-  parse:parse(default-database 'db1')
      "select %bad!"
::
::  fail on malformed knot literal
++  test-fail-cord-literal-forms-01
  %-  expect-fail
  |.  %-  parse:parse(default-database 'db1')
      "select ~.bad!"
::
::  star select top, trailing whitespace
++  test-select-02
  =/  select  "select top 10   * "
  =/  query
    :*  %query  ~  scalars=~  ~
        group-by=~  having=~
        [%select top=[~ 10] columns=~[[%all %all]]]
        ~
        ==
  %+  expect-eq
    !>  ~[[%crud-txn ctes=~ body=[%query query]]]
    !>  (parse:parse(default-database 'db1') select)
::
::  star select top
++  test-select-03
  =/  select  "select top 10 *"
  =/  query
    :*  %query  ~  scalars=~  ~
        group-by=~  having=~
        [%select top=[~ 10] columns=~[[%all %all]]]
        ~
        ==
  %+  expect-eq
    !>  ~[[%crud-txn ctes=~ body=[%query query]]]
    !>  (parse:parse(default-database 'db1') select)
::
::  star select top, trailing whitespace
++  test-select-04
  =/  select  "select top 10   * "
  =/  query
    :*  %query  ~  scalars=~  ~
        group-by=~  having=~
        [%select top=[~ 10] columns=~[[%all %all]]]
        ~
        ==
  %+  expect-eq
    !>  ~[[%crud-txn ctes=~ body=[%query query]]]
    !>  (parse:parse(default-database 'db1') select)
::
::  star select top
++  test-select-05
  =/  select  "select top 10   *"
  =/  query
    :*  %query  ~  scalars=~  ~
        group-by=~  having=~
        [%select top=[~ 10] columns=~[[%all %all]]]
        ~
        ==
  %+  expect-eq
    !>  ~[[%crud-txn ctes=~ body=[%query query]]]
    !>  (parse:parse(default-database 'db1') select)
::
::  star select, trailing whitespace
++  test-select-06
  =/  select  "select  *       "
  =/  query
    :*  %query  ~  scalars=~  ~
        group-by=~  having=~
        select-all-columns  order-by=~
        ==
  %+  expect-eq
    !>  ~[[%crud-txn ctes=~ body=[%query query]]]
    !>  (parse:parse(default-database 'db1') select)
::
::  star select
++  test-select-07
  =/  select  "select  *"
  =/  query
    :*  %query  ~  scalars=~  ~
        group-by=~  having=~
        select-all-columns  order-by=~
        ==
  %+  expect-eq
    !>  ~[[%crud-txn ctes=~ body=[%query query]]]
    !>  (parse:parse(default-database 'db1') select)
::
::  select top, simple columns
++  test-select-08
  =/  select  "FROM ns.table JOIN table-alias ".
              "JOIN db.dbo.table T1 select top 10 ".
              " x1, db1.ns.table.col1, table-alias.name, db..table.col2, ".
              "T1.foo, 1, ~zod, 'cord'"
  =/  qt-ns-table
    :*  %qualified-table  ship=~
        database='db1'  namespace='ns'
        name='table'  alias=~
        ==
  =/  qt-table-alias
    :*  %qualified-table  ship=~
        database='db1'  namespace='dbo'
        name='table-alias'  alias=~
        ==
  =/  qt-db-table
    :*  %qualified-table  ship=~
        database='db'  namespace='dbo'
        name='table'  alias=~
        ==
  =/  qt-db-table-t1
    :*  %qualified-table  ship=~
        database='db'  namespace='dbo'
        name='table'  alias=[~ 'T1']
        ==
  =/  from  :-  ~
                :^  %from
                    relation=qt-ns-table
                    as-of=~
                    :~  :*  %joined-relation
                            join=%join
                            qt-table-alias
                            as-of=~
                            predicate=~
                            ==
                        :*  %joined-relation
                            join=%join
                            qt-db-table-t1
                            as-of=~
                            predicate=~
                            ==
                        ==
  =/  my-columns
    :~  [%unqualified-column column='x1' alias=~]
        [%qualified-column qualifier=qt-ns-table column='col1' alias=~]
        [%qualified-column qualifier=qt-table-alias column='name' alias=~]
        [%qualified-column qualifier=qt-db-table column='col2' alias=~]
        [%qualified-column qualifier=qt-db-table-t1 column='foo' alias=~]
        [%selected-value literal-1 ~]
        [%selected-value [value-type=%p value=0] ~]
        [%selected-value [value-type=%t value='cord'] ~]
        ==
  =/  query
    :*  %query  from  scalars=~  ~
        group-by=~  having=~
        [%select top=[~ 10] columns=my-columns]
        ~
        ==
  %+  expect-eq
    !>  ~[[%crud-txn ctes=~ body=[%query query]]]
    !>  (parse:parse(default-database 'db1') select)
::
::  from foo select top, simple columns, trailing space, no internal space
++  test-select-09
  =/  select  "from foo T1 join db.ns.foo select top 10  ".
              "x1,db.ns.foo.col1,t1.name,db1..foo.col2,T1.foo,1,~zod,'cord' "
  =/  from  :-  ~
                :^  %from
                    relation=foo-table-t1
                    as-of=~
                    :~  :*  %joined-relation
                            join=%join
                            :*  %qualified-table
                                ship=~
                                database=%db
                                namespace=%ns
                                name=%foo
                                alias=~
                                ==
                            as-of=~
                            predicate=~
                            ==
                        ==
  =/  qt-ns-foo
    :*  %qualified-table  ship=~
        database='db'  namespace='ns'
        name='foo'  alias=~
        ==
  =/  qt-foo-t1
    :*  %qualified-table  ship=~
        database='db1'  namespace='dbo'
        name='foo'  alias=[~ 'T1']
        ==
  =/  qt-foo
    :*  %qualified-table  ship=~
        database='db1'  namespace='dbo'
        name='foo'  alias=~
        ==
  =/  my-columns
    :~  [%unqualified-column column='x1' alias=~]
        [%qualified-column qualifier=qt-ns-foo column='col1' alias=~]
        [%qualified-column qualifier=qt-foo-t1 column='name' alias=~]
        [%qualified-column qualifier=qt-foo column='col2' alias=~]
        [%qualified-column qualifier=qt-foo-t1 column='foo' alias=~]
        [%selected-value literal-1 ~]
        [%selected-value [value-type=%p value=0] ~]
        [%selected-value [value-type=%t value='cord'] ~]
        ==
  =/  query
    :*  %query  from  scalars=~  ~
        group-by=~  having=~
        [%select top=[~ 10] columns=my-columns]
        ~
        ==
  %+  expect-eq
    !>  ~[[%crud-txn ctes=~ body=[%query query]]]
    !>  (parse:parse(default-database 'db1') select)
::
::  aliased format 1 columns
++  test-select-10
  =/  select  "FROM ns.table JOIN table-alias ".
              "JOIN db.dbo.table select x1 as foo , ".
              "db.ns.table.col1 as foo2 , table-alias.name as bar , ".
              "db..table.col2 as bar2 , 1 as foobar , ~zod as F1 , ".
              "'cord' as BAR3 "
  =/  qt-from
    :*  %qualified-table  ship=~
        database='db1'  namespace='ns'
        name='table'  alias=~
        ==
  =/  from  :-  ~
                :^  %from
                    relation=qt-from
                    as-of=~
                    :~  :*  %joined-relation
                            join=%join
                            :*  %qualified-table
                                ship=~
                                database=%db1
                                namespace=%dbo
                                name=%table-alias
                                alias=~
                                ==
                            as-of=~
                            predicate=~
                            ==
                          :*  %joined-relation
                            join=%join
                            :*  %qualified-table
                                ship=~
                                database=%db
                                namespace=%dbo
                                name=%table
                                alias=~
                                ==
                            as-of=~
                            predicate=~
                            ==
                        ==
  =/  query
    :*  %query  from  scalars=~  ~
        group-by=~  having=~
        [%select top=~ columns=aliased-columns-1]
        ~
        ==
  %+  expect-eq
    !>  ~[[%crud-txn ctes=~ body=[%query query]]]
    !>  (parse:parse(default-database 'db1') select)
::
::  aliased format 1, top, columns, no whitespace
++  test-select-11
  =/  select  "FROM ns.table JOIN table-alias ".
              "JOIN db.dbo.table select  top 10  ".
              "x1 as foo,db.ns.table.col1 as foo2,table-alias.name as bar,".
              "db..table.col2 as bar2,1 as foobar,~zod as F1,'cord' as BAR3"
  =/  qt-from
    :*  %qualified-table  ship=~
        database='db1'  namespace='ns'
        name='table'  alias=~
        ==
  =/  from  :-  ~
                :^  %from
                    relation=qt-from
                    as-of=~
                    :~  :*  %joined-relation
                            join=%join
                            :*  %qualified-table
                                ship=~
                                database=%db1
                                namespace=%dbo
                                name=%table-alias
                                alias=~
                                ==
                            as-of=~
                            predicate=~
                            ==
                          :*  %joined-relation
                            join=%join
                            :*  %qualified-table
                                ship=~
                                database=%db
                                namespace=%dbo
                                name=%table
                                alias=~
                                ==
                            as-of=~
                            predicate=~
                            ==
                        ==
  =/  query
    :*  %query  from  scalars=~  ~
        group-by=~  having=~
        [%select top=[~ 10] columns=aliased-columns-1]
        ~
        ==
  %+  expect-eq
    !>  ~[[%crud-txn ctes=~ body=[%query query]]]
    !>  (parse:parse(default-database 'db1') select)
::
::  mixed all, object all, object alias all, column, aliased column
++  test-select-12
  =/  select  "from t1 T1 select db..t1.* , foo as foobar , bar , * , T1.* "
  =/  query
    :*  %query  from-t1  scalars=~  ~
        group-by=~  having=~
        [%select top=~ columns=mixed-all]
        ~
        ==
  %+  expect-eq
    !>  ~[[%crud-txn ctes=~ body=[%query query]]]
    !>  (parse:parse(default-database 'db1') select)
::::
::::  , top, mixed all, object all, object alias all, column, aliased column, no whitespace
++  test-select-13
  =/  select  "from t1 T1 select top 10  db..t1.*,foo as foobar,bar,*,T1.*"
  =/  query
    :*  %query  from-t1  scalars=~  ~
        group-by=~  having=~
        [%select top=[~ 10] columns=mixed-all]
        ~
        ==
  %+  expect-eq
    !>  ~[[%crud-txn ctes=~ body=[%query query]]]
    !>  (parse:parse(default-database 'db1') select)

::::  to do: revive tests when group by implemented 
::::
::::  mixed aggregates
::++  test-select-14
::  =/  select  "FROM tbl1 ".
::              "JOIN tbl2 ".
::              "select  foo , COUNT(foo) as CountFoo, cOUNT( bar) ,sum(bar ) , sum( foobar ) as foobar "
::  %+  expect-eq
::    !>  ~[[%crud-txn ctes=~ body=[%query [%query from-aggregate scalars=~ ~ group-by=~ having=~ [%select top=~ columns=aggregates] ~]]]]
::    !>  (parse:parse(default-database 'db1') select)
::::
::::  , top, mixed aggregates, no whitespace
::++  test-select-15
::  =/  select  "FROM tbl1 ".
::              "JOIN tbl2 ".
::              "select top 10 foo,COUNT(foo) as CountFoo,cOUNT( bar),sum(bar ),sum( foobar ) as foobar"
::  %+  expect-eq
::    !>  ~[[%crud-txn ctes=~ body=[%query [%query from-aggregate scalars=~ ~ group-by=~ having=~ [%select top=[~ 10] columns=aggregates] ~]]]]
::    !>  (parse:parse(default-database 'db1') select)
::
:: fail top, no top parameter, trailing whitespace
++  test-fail-select-16
    =/  select  "select top   * "
    %-  expect-fail
    |.  (parse:parse(default-database 'db1') select)
::
:: fail top, no column crud-txn, trailing whitespace
++  test-fail-select-01
    =/  select  "select top 10   "
    %-  expect-fail
    |.  (parse:parse(default-database 'db1') select)
::
:: fail top, no column crud-txn, trailing whitespace
++  test-fail-select-02
    =/  select  "select top 10    "
    %-  expect-fail
    |.  (parse:parse(default-database 'db1') select)
::
:: fail top, no top parameter, trailing whitespace
++  test-fail-select-03
    =/  select  "select top   * "
    %-  expect-fail
    |.  (parse:parse(default-database 'db1') select)
::
:: fail top, no top parameter
++  test-fail-select-04
    =/  select  "select top   *"
    %-  expect-fail
    |.  (parse:parse(default-database 'db1') select)
::
:: fail no column crud-txn, trailing whitespace
++  test-fail-select-05
    =/  select  "select         "
    %-  expect-fail
    |.  (parse:parse(default-database 'db1') select)
::
:: fail top, no column crud-txn
++  test-fail-select-06
    =/  select  "select top 10"
    %-  expect-fail
    |.  (parse:parse(default-database 'db1') select)
::
:: fail no column crud-txn
++  test-fail-select-07
    =/  select  "select"
    %-  expect-fail
    |.  (parse:parse(default-database 'db1') select)
::
::  group and order by
::
++  group-by
  =/  qt
    :*  %qualified-table  ship=~
        database='db'  namespace='ns'
        name='table'  alias=~
        ==
  :~  [%qualified-column qualifier=qt column='col' alias=~]
      [%unqualified-column name='foo' alias=[~ 'T1']]
      3
      4
      ==
++  order-by
  =/  qt
    :*  %qualified-table  ship=~
        database='db'  namespace='ns'
        name='table'  alias=~
        ==
  =/  qc  [%qualified-column qualifier=qt column='col' alias=~]
  =/  uc  [%unqualified-column name='foo' alias=[~ 'T1']]
  :~  [%ordering-column qc ascending=%.y]
      [%ordering-column uc ascending=%.n]
      [%ordering-column 3 ascending=%.y]
      [%ordering-column 4 ascending=%.n]
      ==
::
::  group by
++  test-group-by-01
  =/  select  "from foo group by  db.ns.table.col , T1.foo , 3 , 4 select *"
  =/  query
    :*  %query  from-foo  scalars=~
        predicate=~  group-by=group-by
        having=~
        select=select-all-columns  order-by=~
        ==
  %+  expect-eq
    !>  ~[[%crud-txn ctes=~ body=[%query query]]]
    !>  (parse:parse(default-database 'db1') select)
::
::  group by, no whitespace, with predicate
::  to do: fix when GROUP BY enabled
::++  test-group-by-02
::  =/  pred=(tree predicate-component:ast)  [%eq t1-foo t2-bar]
::  =/  select  "from foo where T1.foo = T2.bar group by db.ns.table.col,T1.foo,3,4 select *"
::  %+  expect-eq
::    !>  ~[[%crud-txn ctes=~ body=[%query [%query from-foo scalars=~ predicate=pred group-by=group-by having=~ select=select-all-columns order-by=~]]]]
::    !>  (parse:parse(default-database 'db1') select)
::
::  order by
++  test-order-by-01
  =/  select  "from foo select * order by  db.ns.table.col  asc ".
              ", T1.foo desc , 3 , 4  desc "
  =/  query
    :*  %query  from-foo  scalars=~
        predicate=~  group-by=~
        having=~
        select=select-all-columns  order-by
        ==
  %+  expect-eq
    !>  ~[[%crud-txn ctes=~ body=[%query query]]]
    !>  (parse:parse(default-database 'db1') select)
::
::  order by, no whitespace
++  test-order-by-02
  =/  select  "from foo select * order by db.ns.table.col aSc,".
              "T1.foo desc,3,4 Desc"
  =/  query
    :*  %query  from-foo  scalars=~
        predicate=~  group-by=~
        having=~
        select=select-all-columns  order-by
        ==
  %+  expect-eq
    !>  ~[[%crud-txn ctes=~ body=[%query query]]]
    !>  (parse:parse(default-database 'db1') select)
::
:: update
::
++  one-eq-1  [%eq [literal-1 ~ ~] [literal-1 ~ ~]]
++  update-pred
      [%and one-eq-1 [%eq [upd-col2 ~ ~] [[value-type=%ud value=4] ~ ~]]]
++  upd-col1  [%qualified-column foo-table name='col1' alias=~]
++  upd-col2  [%qualified-column foo-table name='col2' alias=~]
++  upd-col3  [%qualified-column foo-table name='col3' alias=~]
++  upd-col4  [%qualified-column foo-table name='col4' alias=~]
++  unqlf-2   [%unqualified-column name=%col2 alias=~]
::
:: update with cord-like literal forms
++  test-update-cord-literal-forms-00
  =/  expected  :*  %crud-txn
                    ctes=~
                    :-  %update
                    :*  %update
                        scalars=~
                        table=foo-table
                        as-of=~
                        :-  columns=~[upd-col3 upd-col2 upd-col1]
                            :~  [value-type=%ta value=~.foo-bar]
                                [value-type=%tas value=%foo]
                                [value-type=%t value='foo']
                                ==
                        predicate=~
                        ==
                    ==
  %+  expect-eq
    !>  ~[expected]
    !>  %-  parse:parse(default-database 'db1')
            "update foo set col1='foo', col2=%foo, col3=~.foo-bar"
::
:: update one column, no predicate
++  test-update-00
  =/  expected  :*  %crud-txn
                    ctes=~
                    :-  %update
                    :*  %update
                        scalars=~
                        table=foo-table
                        as-of=~
                        :-  columns=~[upd-col1]
                            values=~[[value-type=%t value='hello']]
                        predicate=~
                        ==
                    ==
  %+  expect-eq
    !>  ~[expected]
    !>  %-  parse:parse(default-database 'db1')
            "update foo set col1='hello'"
::
:: update one column, no predicate as of now
++  test-update-01
  =/  expected  :*  %crud-txn
                    ctes=~
                    :-  %update
                    :*  %update
                        scalars=~
                        table=foo-table
                        as-of=~
                        :-  columns=~[upd-col1]
                            values=~[[value-type=%t value='hello']]
                        predicate=~
                        ==
                    ==
  %+  expect-eq
    !>  ~[expected]
    !>  %-  parse:parse(default-database 'db1')
            "update foo as of now set col1='hello'"
::
:: update one column, no predicate as of ~2023.12.25..7.15.0..1ef5
++  test-update-02
  =/  expected  :*  %crud-txn
                    ctes=~
                    :-  %update
                    :*  %update
                        scalars=~
                        table=foo-table
                        as-of=[~ [%da ~2023.12.25..7.15.0..1ef5]]
                        :-  columns=~[upd-col1]
                            values=~[[value-type=%t value='hello']]
                        predicate=~
                        ==
                    ==
  %+  expect-eq
    !>  ~[expected]
    !>  %-  parse:parse(default-database 'db1')
            "update foo as of ~2023.12.25..7.15.0..1ef5 set col1='hello'"
::
:: update one column, no predicate as of 4 seconds ago
++  test-update-03
  =/  expected  :*  %crud-txn
                    ctes=~
                    :-  %update
                    :*  %update
                        scalars=~
                        table=foo-table
                        as-of=[~ [%as-of-offset 4 %seconds]]
                        :-  columns=~[upd-col1]
                            values=~[[value-type=%t value='hello']]
                        predicate=~
                        ==
                    ==
  %+  expect-eq
    !>  ~[expected]
    !>  %-  parse:parse(default-database 'db1')
            "update foo as of 4 seconds ago set col1='hello'"
::
:: update two columns, no predicate
++  test-update-04
  =/  expected  :*  %crud-txn
                    ctes=~
                    :-  %update
                    :*  %update
                        scalars=~
                        table=foo-table
                        as-of=~
                        :-  columns=~[upd-col3 upd-col1]
                            values=~[[value-type=%t value='hello'] unqlf-2]
                        predicate=~
                        ==
                    ==
  %+  expect-eq
    !>  ~[expected]
    !>  %-  parse:parse(default-database 'db1')
            "update foo set col1=col2, col3 = 'hello'"
::
:: update three columns, no predicate, end of command marker
++  test-update-04a
  =/  expected  :*  %crud-txn
                    ctes=~
                    :-  %update
                    :*  %update
                        scalars=~
                        table=foo-table
                        as-of=~
                        :-  columns=~[upd-col4 upd-col3 upd-col1]
                            :~  %default
                                [value-type=%ud value=44]
                                [value-type=%t value='hello']
                                ==
                        predicate=~
                        ==
                    ==
  %+  expect-eq
    !>  ~[expected]
    !>  %-  parse:parse(default-database 'db1')
            "update foo set col1='hello', ".
                  "                    col3=44, ".
                  "                    col4=DEFAULT; "
::
:: update two columns, no predicate as of now
++  test-update-05
  =/  expected  :*  %crud-txn
                    ctes=~
                    :-  %update
                    :*  %update
                        scalars=~
                        table=foo-table
                        as-of=~
                        :-  columns=~[upd-col3 upd-col1]
                            values=~[[value-type=%t value='hello'] unqlf-2]
                        predicate=~
                        ==
                    ==
  %+  expect-eq
    !>  ~[expected]
    !>  %-  parse:parse(default-database 'db1')
            "update foo as of now set col1=col2, col3 = 'hello'"
::
:: update two columns, no predicate as of ~2023.12.25..7.15.0..1ef5
++  test-update-06
  =/  expected  :*  %crud-txn
                    ctes=~
                    :-  %update
                    :*  %update
                        scalars=~
                        table=foo-table
                        as-of=[~ [%da ~2023.12.25..7.15.0..1ef5]]
                        :-  columns=~[upd-col3 upd-col1]
                            values=~[[value-type=%t value='hello'] unqlf-2]
                        predicate=~
                        ==
                    ==
  %+  expect-eq
    !>  ~[expected]
    !>  %-  parse:parse(default-database 'db1')
            "update foo as of ~2023.12.25..7.15.0..1ef5 ".
            "set col1=col2, col3 = 'hello'"
::
:: update two columns, no predicate as of 4 seconds ago
++  test-update-07
  =/  expected  :*  %crud-txn
                    ctes=~
                    :-  %update
                    :*  %update
                        scalars=~
                        table=foo-table
                        as-of=[~ [%as-of-offset 4 %seconds]]
                        :-  columns=~[upd-col3 upd-col1]
                            values=~[[value-type=%t value='hello'] unqlf-2]
                        predicate=~
                        ==
                    ==
  %+  expect-eq
    !>  ~[expected]
    !>  %-  parse:parse(default-database 'db1')
            "update foo as of 4 seconds ago set col1=col2, col3 = 'hello'"
::
:: update two columns, with predicate
++  test-update-08
  =/  expected  :*  %crud-txn
                    ctes=~
                    :-  %update
                    :*  %update
                        scalars=~
                        table=foo-table
                        as-of=~
                        :-  columns=~[upd-col3 upd-col1]
                            values=~[[value-type=%t value='hello'] unqlf-2]
                        predicate=update-pred
                        ==
                    ==
  %+  expect-eq
    !>  ~[expected]
    !>  %-  parse:parse(default-database 'db1')
            "update foo set col1=col2, col3 = 'hello' where 1 = 1 and col2 = 4"
::
:: update two columns, with predicate as of now
++  test-update-09
  =/  expected  :*  %crud-txn
                    ctes=~
                    :-  %update
                    :*  %update
                        scalars=~
                        table=foo-table
                        as-of=~
                        :-  columns=~[upd-col3 upd-col1]
                            values=~[[value-type=%t value='hello'] unqlf-2]
                        predicate=update-pred
                        ==
                    ==
  %+  expect-eq
    !>  ~[expected]
    !>  %-  parse:parse(default-database 'db1')
            "update foo as of now set col1=col2, col3 = 'hello' ".
            "where 1 = 1 and col2 = 4"
::
:: update two columns, with predicate as of ~2023.12.25..7.15.0..1ef5
++  test-update-10
  =/  expected  :*  %crud-txn
                    ctes=~
                    :-  %update
                    :*  %update
                        scalars=~
                        table=foo-table
                        as-of=[~ [%da ~2023.12.25..7.15.0..1ef5]]
                        :-  columns=~[upd-col3 upd-col1]
                            values=~[[value-type=%t value='hello'] unqlf-2]
                        predicate=update-pred
                        ==
                    ==
  %+  expect-eq
    !>  ~[expected]
    !>  %-  parse:parse(default-database 'db1')
            "update foo as of ~2023.12.25..7.15.0..1ef5 ".
            "set col1=col2, col3 = 'hello' where 1 = 1 and col2 = 4"
::
:: update two columns, with predicate as of 4 seconds ago
++  test-update-11
  =/  expected  :*  %crud-txn
                    ctes=~
                    :-  %update
                    :*  %update
                        scalars=~
                        table=foo-table
                        as-of=[~ [%as-of-offset 4 %seconds]]
                        :-  columns=~[upd-col3 upd-col1]
                            values=~[[value-type=%t value='hello'] unqlf-2]
                        predicate=update-pred
                        ==
                    ==
  %+  expect-eq
    !>  ~[expected]
    !>  %-  parse:parse(default-database 'db1')
            "update foo as of 4 seconds ago set col1=col2, col3 = 'hello' ".
            "where 1 = 1 and col2 = 4"
::
:: update with one cte and predicate
++  test-update-12
  =/  expected  :*  %crud-txn
                    ctes=~[cte-t1]
                    :-  %update
                    :*  %update
                        scalars=~
                        table=foo-table
                        as-of=~
                        :-  columns=~[upd-col3 upd-col1]
                            values=~[[value-type=%t value='hello'] unqlf-2]
                        predicate=update-pred
                        ==
                    ==
  %+  expect-eq
    !>  ~[expected]
    !>  %-  parse:parse(default-database 'db1')
            "with (select *) as t1 update foo set col1=col2, col3 = 'hello' ".
            "where 1 = 1 and col2 = 4"
::
:: update with one cte and predicate as of now
++  test-update-13
  =/  expected  :*  %crud-txn
                    ctes=~[cte-t1]
                    :-  %update
                    :*  %update
                        scalars=~
                        table=foo-table
                        as-of=~
                        :-  columns=~[upd-col3 upd-col1]
                            values=~[[value-type=%t value='hello'] unqlf-2]
                        predicate=update-pred
                        ==
                    ==
  %+  expect-eq
    !>  ~[expected]
    !>  %-  parse:parse(default-database 'db1')
            "with (select *) as t1 update foo as of now ".
            "set col1=col2, col3 = 'hello' where 1 = 1 and col2 = 4"
::
:: update with one cte and predicate as of ~2023.12.25..7.15.0..1ef5
++  test-update-14
  =/  expected  :*  %crud-txn
                    ctes=~[cte-t1]
                    :-  %update
                    :*  %update
                        scalars=~
                        table=foo-table
                        as-of=[~ [%da ~2023.12.25..7.15.0..1ef5]]
                        :-  columns=~[upd-col3 upd-col1]
                            values=~[[value-type=%t value='hello'] unqlf-2]
                        predicate=update-pred
                        ==
                    ==
  %+  expect-eq
    !>  ~[expected]
    !>  %-  parse:parse(default-database 'db1')
            "with (select *) as t1 update foo as of ~2023.12.25..7.15.0..1ef5 ".
            "set col1=col2, col3 = 'hello' ".
            "where 1 = 1 and col2 = 4"
::
:: update with one cte and predicate as of 4 seconds ago
++  test-update-15
  =/  expected  :*  %crud-txn
                    ctes=~[cte-t1]
                    :-  %update
                    :*  %update
                        scalars=~
                        table=foo-table
                        as-of=[~ [%as-of-offset 4 %seconds]]
                        :-  columns=~[upd-col3 upd-col1]
                            values=~[[value-type=%t value='hello'] unqlf-2]
                        predicate=update-pred
                        ==
                    ==
  %+  expect-eq
    !>  ~[expected]
    !>  %-  parse:parse(default-database 'db1')
            "with (select *) as t1 update foo as of 4 seconds ago ".
            "set col1=col2, col3 = 'hello' ".
            "where 1 = 1 and col2 = 4"
::
:: update with three ctes and predicate
:: if we remove the from statements after the with the test passes
:: with the parse-scalar rule present
++  test-update-16
  =/  expected  :*  %crud-txn
                    ctes=~[cte-t1 cte-foobar cte-bar]
                    :-  %update
                    :*  %update
                        scalars=~
                        table=foo-table
                        as-of=~
                        :-  columns=~[upd-col3 upd-col1]
                            values=~[[value-type=%t value='hello'] unqlf-2]
                        predicate=update-pred
                        ==
                    ==
  %+  expect-eq
    !>  ~[expected]
    !>  %-  parse:parse(default-database 'db1')
            "with (select *) as t1, ".
            "(from foobar where col1=2 select col3, col4) as foobar, ".
            "(from bar where col1=col2 select col2) as bar ".
            "update foo set col1=col2, col3 = 'hello' where 1 = 1 and col2 = 4"
::
:: update with three ctes and predicate as of now
++  test-update-17
  =/  expected  :*  %crud-txn
                    ctes=~[cte-t1 cte-foobar cte-bar]
                    :-  %update
                    :*  %update
                        scalars=~
                        table=foo-table
                        as-of=~
                        :-  columns=~[upd-col3 upd-col1]
                            values=~[[value-type=%t value='hello'] unqlf-2]
                        predicate=update-pred
                        ==
                    ==
  %+  expect-eq
    !>  ~[expected]
    !>  %-  parse:parse(default-database 'db1')
            "with (select *) as t1, ".
            "(from foobar where col1=2 select col3, col4) as foobar, ".
            "(from bar where col1=col2 select col2) as bar ".
            "update foo as of now set col1=col2, col3 = 'hello' ".
            "where 1 = 1 and col2 = 4"
::
:: update with three ctes and predicate as of ~2023.12.25..7.15.0..1ef5
++  test-update-18
  =/  expected  :*  %crud-txn
                    ctes=~[cte-t1 cte-foobar cte-bar]
                    :-  %update
                    :*  %update
                        scalars=~
                        table=foo-table
                        as-of=[~ [%da ~2023.12.25..7.15.0..1ef5]]
                        :-  columns=~[upd-col3 upd-col1]
                            values=~[[value-type=%t value='hello'] unqlf-2]
                        predicate=update-pred
                        ==
                    ==
  %+  expect-eq
    !>  ~[expected]
    !>  %-  parse:parse(default-database 'db1')
            "with (select *) as t1, ".
            "(from foobar where col1=2 select col3, col4) as foobar, ".
            "(from bar where col1=col2 select col2) as bar ".
            "update foo as of ~2023.12.25..7.15.0..1ef5 ".
            "set col1=col2, col3 = 'hello' where 1 = 1 and col2 = 4"
::
:: update with three ctes and predicate as of 4 seconds ago
++  test-update-19
  =/  expected  :*  %crud-txn
                    ctes=~[cte-t1 cte-foobar cte-bar]
                    :-  %update
                    :*  %update
                        scalars=~
                        table=foo-table
                        as-of=[~ [%as-of-offset 4 %seconds]]
                        :-  columns=~[upd-col3 upd-col1]
                            values=~[[value-type=%t value='hello'] unqlf-2]
                        predicate=update-pred
                        ==
                    ==
  %+  expect-eq
    !>  ~[expected]
    !>  %-  parse:parse(default-database 'db1')
            "with (select *) as t1, ".
            "(from foobar where col1=2 select col3, col4) as foobar, ".
            "(from bar where col1=col2 select col2) as bar ".
            "update foo as of 4 seconds ago set col1=col2, col3 = 'hello' ".
            "where 1 = 1 and col2 = 4"
::
:: update with 2 scalars, no cte
++  test-update-20
  =/  sc1  :*  %scalar
               name='add-10'
               :*  %arithmetic
                   operator=%lus
                   left=[%unqualified-column 'col3' ~]
                   right=[p=%ud q=10]
                   ==
               ==
  =/  sc2  :*  %scalar
               name='add-20'
               :*  %arithmetic
                   operator=%lus
                   left=[%unqualified-column 'col3' ~]
                   right=[p=%ud q=20]
                   ==
               ==
  =/  expected  :*  %crud-txn
                    ctes=~
                    :-  %update
                    :*  %update
                        scalars=~[sc1 sc2]
                        table=foo-table
                        as-of=~
                        :-  columns=~[upd-col1]
                            values=~[[value-type=%t value='hello']]
                        predicate=update-pred
                        ==
                    ==
  %+  expect-eq
    !>  ~[expected]
    !>  %-  parse:parse(default-database 'db1')
            "scalars add-10 col3 + 10 end add-20 col3 + 20 end ".
            "update foo set col1='hello' where 1 = 1 and col2 = 4"
::
:: update with 2 scalars and 1 cte
++  test-update-21
  =/  sc1  :*  %scalar
               name='add-10'
               :*  %arithmetic
                   operator=%lus
                   left=[%unqualified-column 'col3' ~]
                   right=[p=%ud q=10]
                   ==
               ==
  =/  sc2  :*  %scalar
               name='add-20'
               :*  %arithmetic
                   operator=%lus
                   left=[%unqualified-column 'col3' ~]
                   right=[p=%ud q=20]
                   ==
               ==
  =/  expected  :*  %crud-txn
                    ctes=~[cte-t1]
                    :-  %update
                    :*  %update
                        scalars=~[sc1 sc2]
                        table=foo-table
                        as-of=~
                        :-  columns=~[upd-col1]
                            values=~[[value-type=%t value='hello']]
                        predicate=update-pred
                        ==
                    ==
  %+  expect-eq
    !>  ~[expected]
    !>  %-  parse:parse(default-database 'db1')
            "with (select *) as t1 ".
            "scalars add-10 col3 + 10 end add-20 col3 + 20 end ".
            "update foo set col1='hello' where 1 = 1 and col2 = 4"
::
:: merge
::
++  predicate-bar-eq-bar
  =/  qt-tgt
    :*  %qualified-table  ship=~
        database='UNKNOWN'  namespace='COLUMN'
        name='tgt'  alias=~
        ==
  =/  qt-src
    :*  %qualified-table  ship=~
        database='UNKNOWN'  namespace='COLUMN'
        name='src'  alias=~
        ==
  =/  col-tgt
    [%qualified-column qualifier=qt-tgt column='bar' alias=~]
  =/  col-src
    [%qualified-column qualifier=qt-src column='bar' alias=~]
  [%eq [col-tgt ~ ~] [col-src ~ ~]]
++  cte-bar-foobar
  =/  qt-bar
    :*  %qualified-table  ship=~
        database='UNKNOWN'
        namespace='COLUMN-OR-CTE'
        name='bar'  alias=~
        ==
  =/  qt-foobar
    :*  %qualified-table  ship=~
        database='UNKNOWN'
        namespace='COLUMN-OR-CTE'
        name='foobar'  alias=~
        ==
  =/  cols
    :~  :*  %qualified-column
            qualifier=qt-bar
            column='bar'  alias=~
            ==
        :*  %qualified-column
            qualifier=qt-foobar
            column='foobar'  alias=~
            ==
        ==
  =/  query
    :*  %query  from=~  scalars=~
        predicate=~  group-by=~  having=~
        [%select top=~ columns=cols]
        order-by=~
        ==
  [%cte name='T1' body=[%query query]]
++  cte-bar-foobar-src
  =/  qt-bar
    :*  %qualified-table  ship=~
        database='UNKNOWN'
        namespace='COLUMN-OR-CTE'
        name='bar'  alias=~
        ==
  =/  qt-foobar
    :*  %qualified-table  ship=~
        database='UNKNOWN'
        namespace='COLUMN-OR-CTE'
        name='foobar'  alias=~
        ==
  =/  cols
    :~  :*  %qualified-column
            qualifier=qt-bar
            column='bar'  alias=~
            ==
        :*  %qualified-column
            qualifier=qt-foobar
            column='foobar'  alias=~
            ==
        ==
  =/  query
    :*  %query  from=~  scalars=~
        predicate=~  group-by=~  having=~
        [%select top=~ columns=cols]
        order-by=~
        ==
  [%cte name='src' body=[%query query]]
++  qt-src
  :*  %qualified-table  ship=~
      database='UNKNOWN'  namespace='COLUMN'
      name='src'  alias=~
      ==
++  column-src-foo
  [%qualified-column qualifier=qt-src column='foo' alias=~]
++  column-src-bar
  [%qualified-column qualifier=qt-src column='bar' alias=~]
++  column-src-foobar
  [%qualified-column qualifier=qt-src column='foobar' alias=~]
::::
::::
::++  test-merge-01
::  =/  query  " WITH (SELECT bar, foobar) as T1 ".
::" MERGE INTO dbo.foo AS tgt ".
::" USING T1 AS src ".
::" ON (tgt.bar = src.bar) ".
::" WHEN MATCHED THEN ".
::"    UPDATE SET foobar = src.foo "
::  =/  expected
::    [%crud-txn ctes=~[cte-bar-foobar] body=[%merge [%merge target-table=[%qualified-table ship=~ database='db1' namespace='dbo' name='foo' alias=[~ 'tgt']] new-table=~ source-table=[%qualified-table ship=~ database='UNKNOWN' namespace='COLUMN-OR-CTE' name='T1' alias=[~ 'src']] predicate=predicate-bar-eq-bar matched=~[[%matching predicate=~ matching-profile=[%update ~[['foobar' column-src-foo]]]]] unmatched-by-target=~ unmatched-by-source=~ as-of=~]]]
::  %+  expect-eq
::    !>  ~[expected]
::    !>  (parse:parse(default-database 'db1') query)
::::
::::
::++  test-merge-02
::  =/  query  " WITH (SELECT bar, foobar) as T1 ".
::" MERGE INTO dbo.foo AS tgt ".
::" USING T1 AS src ".
::" ON (tgt.bar = src.bar) ".
::" WHEN MATCHED THEN ".
::"    UPDATE SET foobar = src.foo, ".
::"    bar = bar "
::  =/  expected
::    [%crud-txn ctes=~[cte-bar-foobar] body=[%merge [%merge target-table=[%qualified-table ship=~ database='db1' namespace='dbo' name='foo' alias=[~ 'tgt']] new-table=~ source-table=[%qualified-table ship=~ database='UNKNOWN' namespace='COLUMN-OR-CTE' name='T1' alias=[~ 'src']] predicate=predicate-bar-eq-bar matched=~[[%matching predicate=~ matching-profile=[%update ~[['foobar' column-src-foo] ['bar' column-bar]]]]] unmatched-by-target=~ unmatched-by-source=~ as-of=~]]]
::  %+  expect-eq
::    !>  ~[expected]
::    !>  (parse:parse(default-database 'db1') query)
::::
::::
::++  test-merge-03
::  =/  query  "WITH (SELECT bar, foobar) as src ".
::" MERGE dbo.foo ".
::" USING src ".
::" ON (tgt.bar = src.bar) ".
::" WHEN MATCHED AND 1 = 1 THEN ".
::"    UPDATE SET foobar = src.foobar ".
::" WHEN NOT MATCHED THEN ".
::"    INSERT (bar, foobar) ".
::"    VALUES (src.bar, 99)"
::  =/  expected
::    [%crud-txn ctes=~[cte-bar-foobar-src] body=[%merge [%merge target-table=[%qualified-table ship=~ database='db1' namespace='dbo' name='foo' alias=~] new-table=~ source-table=[%qualified-table ship=~ database='db1' namespace='dbo' name='src' alias=~] predicate=predicate-bar-eq-bar matched=~[[%matching predicate=one-eq-1 matching-profile=[%update ~[['foobar' column-src-foobar]]]]] unmatched-by-target=~[[%matching predicate=~ matching-profile=[%insert ~[['bar' column-src-bar] ['foobar' [value-type=%ud value=99]]]]]] unmatched-by-source=~ as-of=~]]]
::  %+  expect-eq
::    !>  ~[expected]
::    !>  (parse:parse(default-database 'db1') query)
::
:: block comment
::
++  test-block-cmnt-00
  %+  expect-eq
    !>  ~
    !>  %-  parse:parse(default-database 'other-db')  ~
::
++  m-cmnt-1  "/* line1\0aline2\0aline3\0a*/"
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
                              "namespace ns1\0a"
                              "; \0a"
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
                              "namespace ns1\0a"
                              m-cmnt-2
                              m-cmnt-3
                              "; \0a"
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
                              "namespace ns1\0a"
                              m-cmnt-1
                              "; \0a"
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
                              "namespace ns1\0a"
                              m-cmnt-1
                              "; "
                              m-cmnt-2
                              "cReate namesPace db1.db1-ns1"
                              m-cmnt-3
                              ==
++  test-block-cmnt-07
  %+  expect-eq
    !>  ~[[%create-database database-name='db3' as-of=~]]
    !>  %-  parse:parse(default-database 'other-db')
            %-  zing
                %-  limo  :~  "CREATE DATABASE db3; :: this is a line comment".
                              ":: they can start anywhere on a line ".
                              ":: and comment out the remainder of the line".
                              "/* this is a block comment".
                              "everyting within /* and */".
                              "(which must be in columns 1 and 2) is a comment".
                              "CREATE TABLE db3..my-table-1".
                              "  (col1 @t, col2 @da) PRIMARY KEY (col1)".
                              "*/"
                              ==
::
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
++  q1
  :*  %query  from=~  scalars=~
      predicate=~  group-by=~  having=~
      [%select top=~ columns=s1]  order-by=~
      ==
++  q2
  :*  %query  from=~  scalars=~
      predicate=~  group-by=~  having=~
      [%select top=~ columns=s2]  order-by=~
      ==
++  q3
  :*  %query  from=~  scalars=~
      predicate=~  group-by=~  having=~
      [%select top=~ columns=s3]  order-by=~
      ==
::
++  t1  [%crud-txn ctes=~ body=[%query q1]]
++  t2  [%crud-txn ctes=~ body=[%query q2]]
++  t3  [%crud-txn ctes=~ body=[%query q3]]
::
++  test-block-cmnt-08
  %+  expect-eq
    !>  ~[t1 t2 t3]
    !>  %-  parse:parse(default-database 'other-db')
            %-  zing
                %-  limo
                :~  "select '\2f\2a', '*\2f', '::', ".
                    "' \2f\2a ', ' *\2f ', ' :: '\0a"
                    m-cmnt-1
                    "select ' :: ', '\2f\2a', '*\2f', ".
                    "'::', ' \2f\2a ', ' *\2f '\0a"
                    m-cmnt-2
                    "select ' *\2f ', ' :: ', ".
                    "'\2f\2a', '*\2f', '::', ' \2f\2a '"
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
++  q1a
  :*  %query  from=~  scalars=~
      predicate=~  group-by=~  having=~
      [%select top=~ columns=s1a]  order-by=~
      ==
++  q2a
  :*  %query  from=~  scalars=~
      predicate=~  group-by=~  having=~
      [%select top=~ columns=s2a]  order-by=~
      ==
++  q3a
  :*  %query  from=~  scalars=~
      predicate=~  group-by=~  having=~
      [%select top=~ columns=s3a]  order-by=~
      ==
++  q3b
  :*  %query  from=~  scalars=~
      predicate=~  group-by=~  having=~
      [%select top=~ columns=s3b]  order-by=~
      ==
::
++  t1a  [%crud-txn ctes=~ body=[%query q1a]]
++  t2a  [%crud-txn ctes=~ body=[%query q2a]]
++  t3a  [%crud-txn ctes=~ body=[%query q3a]]
++  t3b  [%crud-txn ctes=~ body=[%query q3b]]
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
    !>  %-  parse:parse(default-database 'db1')
        "create namespace ns1 \0a::line cmnt"
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
::
:: cte validation
::
:: cte columns may appear in a select list outside the from clause
++  test-cte-column-select-00
  =/  first-cte-query
    :*  %query
        from-foo
        scalars=~
        predicate=~
        group-by=~
        having=~
        [%select top=~ columns=~[col1 col2]]
        order-by=~
        ==
  =/  foo2-table
    :*  %qualified-table
        ship=~
        database='db1'
        namespace='dbo'
        name='foo2'
        alias=~
        ==
  =/  query
    :*  %query
        [~ [%from relation=foo2-table as-of=~ joins=~]]
        scalars=~
        predicate=~
        group-by=~
        having=~
        :+  %select
            top=~
            :~  col3
                col4
                [%selected-cte-column 'first' 'col1' ~]
                [%selected-cte-column 'first' 'col2' [~ 'my-col2']]
                ==
        order-by=~
        ==
  =/  expected
    :~  :+  %crud-txn
            ctes=~[[%cte name='first' body=[%query first-cte-query]]]
            body=[%query query]
        ==
  %+  expect-eq
    !>  expected
    !>  %-  parse:parse(default-database 'db1')
        "WITH (FROM foo select col1, col2) as first ".
        "FROM foo2 ".
        "SELECT col3, col4, first.col1, first.col2 AS my-col2"
::
:: cte columns may be re-selected by later ctes and re-referenced with aliases
++  test-cte-column-select-01
  =/  first-cte-query
    :*  %query
        from-foo
        scalars=~
        predicate=~
        group-by=~
        having=~
        [%select top=~ columns=~[col1 col2]]
        order-by=~
        ==
  =/  foo2-table
    :*  %qualified-table
        ship=~
        database='db1'
        namespace='dbo'
        name='foo2'
        alias=~
        ==
  =/  second-cte-query
    :*  %query
        [~ [%from relation=foo2-table as-of=~ joins=~]]
        scalars=~
        predicate=~
        group-by=~
        having=~
        :+  %select
            top=~
            :~  col3
                col4
                [%selected-cte-column 'first' 'col1' ~]
                [%selected-cte-column 'first' 'col2' [~ 'my-col2']]
                ==
        order-by=~
        ==
  =/  foo3-table
    :*  %qualified-table
        ship=~
        database='db1'
        namespace='dbo'
        name='foo3'
        alias=~
        ==
  =/  col5
    [%unqualified-column column='col5' alias=~]
  =/  query
    :*  %query
        [~ [%from relation=foo3-table as-of=~ joins=~]]
        scalars=~
        predicate=~
        group-by=~
        having=~
        :+  %select
            top=~
            :~  col5
                [%selected-cte-column 'first' 'col1' ~]
                [%selected-cte-column 'first' 'col2' ~]
                [%selected-cte-column 'second' 'col1' ~]
                [%selected-cte-column 'second' 'my-col2' [~ 'my-col-2']]
                ==
        order-by=~
        ==
  =/  expected
    :~  :*  %crud-txn
            :~  :*  %cte  name='first'  body=[%query first-cte-query]  ==
                :*  %cte  name='second'  body=[%query second-cte-query]  ==
                ==
            body=[%query query]
        ==
    ==
  %+  expect-eq
    !>  expected
    !>  %-  parse:parse(default-database 'db1')
        "with (FROM foo select col1, col2) as first, ".
        "(FROM foo2 ".
        "SELECT col3, col4, first.col1, first.col2 AS my-col2) as second ".
        "FROM foo3 ".
        "SELECT col5, first.col1, first.col2, second.col1, second.my-col2 AS my-col-2"
::
::  set operations
::
::  helpers for set-op tests
++  foo-set-query
  :*  %query
      from-foo
      scalars=~
      predicate=~
      group-by=~
      having=~
      select-all-columns
      ~
      ==
++  bar-table
  [%qualified-table ship=~ database='db1' namespace='dbo' name='bar' alias=~]
++  from-bar
  [~ [%from relation=bar-table as-of=~ joins=~]]
++  bar-set-query
  :*  %query
      from-bar
      scalars=~
      predicate=~
      group-by=~
      having=~
      select-all-columns
      ~
      ==
++  baz-table
  [%qualified-table ship=~ database='db1' namespace='dbo' name='baz' alias=~]
++  from-baz
  [~ [%from relation=baz-table as-of=~ joins=~]]
++  baz-set-query
  :*  %query
      from-baz
      scalars=~
      predicate=~
      group-by=~
      having=~
      select-all-columns
      ~
      ==
::  UNION: basic two-query union
++  test-set-op-union-00
  =/  expected
    :+  %crud-txn
        ctes=~
        :-  %set-query
        :*  %set-query
            head=foo-set-query
            tail=~[[op=%union query=bar-set-query]]
            ==
  %+  expect-eq
    !>  ~[expected]
    !>  (parse:parse(default-database 'db1') "FROM foo SELECT * UNION FROM bar SELECT *")
::  UNION: mixed case keyword
++  test-set-op-union-01
  =/  expected
    :+  %crud-txn
        ctes=~
        :-  %set-query
        :*  %set-query
            head=foo-set-query
            tail=~[[op=%union query=bar-set-query]]
            ==
  %+  expect-eq
    !>  ~[expected]
    !>  (parse:parse(default-database 'db1') "FROM foo SELECT * uNiOn FROM bar SELECT *")
::  EXCEPT
++  test-set-op-except-00
  =/  expected
    :+  %crud-txn
        ctes=~
        :-  %set-query
        :*  %set-query
            head=foo-set-query
            tail=~[[op=%except query=bar-set-query]]
            ==
  %+  expect-eq
    !>  ~[expected]
    !>  (parse:parse(default-database 'db1') "FROM foo SELECT * EXCEPT FROM bar SELECT *")
::  INTERSECT
++  test-set-op-intersect-00
  =/  expected
    :+  %crud-txn
        ctes=~
        :-  %set-query
        :*  %set-query
            head=foo-set-query
            tail=~[[op=%intersect query=bar-set-query]]
            ==
  %+  expect-eq
    !>  ~[expected]
    !>  (parse:parse(default-database 'db1') "FROM foo SELECT * INTERSECT FROM bar SELECT *")
::  DIVIDED BY (mixed case)
++  test-set-op-divided-by-00
  =/  expected
    :+  %crud-txn
        ctes=~
        :-  %set-query
        :*  %set-query
            head=foo-set-query
            tail=~[[op=%divided-by query=bar-set-query]]
            ==
  %+  expect-eq
    !>  ~[expected]
    !>  (parse:parse(default-database 'db1') "FROM foo SELECT * DiViDeD bY FROM bar SELECT *")
::  DIVIDED BY WITH REMAINDER
++  test-set-op-divide-with-remainder-00
  =/  expected
    :+  %crud-txn
        ctes=~
        :-  %set-query
        :*  %set-query
            head=foo-set-query
            tail=~[[op=%divide-with-remainder query=bar-set-query]]
            ==
  %+  expect-eq
    !>  ~[expected]
    !>  (parse:parse(default-database 'db1') "FROM foo SELECT * DIVIDED BY WITH REMAINDER FROM bar SELECT *")
::  Three-query chain: q1 UNION q2 EXCEPT q3
++  test-set-op-chain-00
  =/  expected
    :+  %crud-txn
        ctes=~
        :-  %set-query
        :*  %set-query
            head=foo-set-query
            :~  [op=%union query=bar-set-query]
                [op=%except query=baz-set-query]
                ==
            ==
  %+  expect-eq
    !>  ~[expected]
    !>  %-  parse:parse(default-database 'db1')
            "FROM foo SELECT * UNION FROM bar SELECT * EXCEPT FROM baz SELECT *"
::  CTE with set-op body: WITH (q1 UNION q2) AS cte FROM cte SELECT *
++  test-set-op-cte-union-00
  =/  cte-body=cte-body:ast
    :-  %set-query
    :*  %set-query
        head=foo-set-query
        tail=~[[op=%union query=bar-set-query]]
        ==
  =/  cte-name  'u1'
  =/  cte-table
    :*  %qualified-table  ship=~
        database='UNKNOWN'  namespace='COLUMN-OR-CTE'
        name='u1'  alias=~
        ==
  =/  outer-from
    [~ [%from relation=[%cte-name 'u1' ~] as-of=~ joins=~]]
  =/  outer-q
    :*  %query
        outer-from
        scalars=~
        predicate=~
        group-by=~
        having=~
        select-all-columns
        ~
        ==
  =/  expected
    :+  %crud-txn
        ctes=~[[%cte name=cte-name body=cte-body]]
        body=[%query outer-q]
  %+  expect-eq
    !>  ~[expected]
    !>  %-  parse:parse(default-database 'db1')
            "WITH (FROM foo SELECT * UNION FROM bar SELECT *) AS u1 FROM u1 SELECT *"
::
:: fail: cte name conflicts with from alias (case-insensitive)
++  test-fail-cte-alias-conflict-00
  %^  failon-parse  'db1'
                    "with (select *) as t1 from foo T1 select *"
                    'FROM alias conflicts with CTE name'
::
:: fail: predicate column qualifier is not a known from alias or cte name
++  test-fail-cte-unknown-qualifier-01
  %^  failon-parse  'db1'
                    "with (select *) as t1 from foo where ".
                    "unknown.col = col1 select *"
                    (crip "table alias or CTE name 'unknown' is not defined")
::
:: fail: predicate column qualifier matches cte name
:: column not in cte select list
++  test-fail-cte-column-not-in-cte-02
  %^  failon-parse  'db1'
                    "with (from foobar where col1 = col2 ".
                    "select col3, col4) as foobar ".
                    "from foo where foobar.nonexistent = col1 select *"
                    'nonexistent is not produced by CTE %foobar'
--
