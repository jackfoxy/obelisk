/-  ast=obelisk-ast
/+  parse,  *test
::
::  CREATE VIEW, ALTER VIEW, DROP VIEW, and ALTER NAMESPACE TRANSFER VIEW
::  parsing.  An expected view query is the parse of the same query as a
::  command, with the view's database as the default database.
::
|%
++  query-of
  |=  [db=@tas query=tape]
  ^-  crud-txn:ast
  ;;(crud-txn:ast (snag 0 (parse:parse(default-database db) query)))
::
++  qt
  |=  [db=@tas ns=@tas name=@tas]
  ^-  qualified-table:ast
  [%qualified-table ~ db ns name ~]
::
::  CREATE VIEW
::
::  unqualified view in the default database, text without end of command
++  test-create-view-00
  =/  query  "FROM my-table WHERE col1 > 1 SELECT col1, col2"
  %+  expect-eq
    !>  ^-  (list command:ast)
        :~  :*  %create-view
                (qt 'db1' 'dbo' 'v1')
                (crip query)
                (query-of 'db1' query)
                ~
                ==
            ==
    !>  %-  parse:parse(default-database 'db1')
        "CREATE VIEW v1 AS FROM my-table WHERE col1 > 1 SELECT col1, col2;"
::
::  mixed case keywords and extra whitespace, namespace qualified view
++  test-create-view-01
  =/  query  "FROM my-table SELECT *"
  %+  expect-eq
    !>  ^-  (list command:ast)
        :~  :*  %create-view
                (qt 'db1' 'ns1' 'v1')
                (crip query)
                (query-of 'db1' query)
                ~
                ==
            ==
    !>  %-  parse:parse(default-database 'db1')
        " cReAte  \0a VIEW  ns1.v1 \09 aS  \0a FROM my-table SELECT * \0a; "
::
::  the query defaults to the view's database, not the script's
++  test-create-view-02
  =/  query  "FROM my-table SELECT col1"
  %+  expect-eq
    !>  ^-  (list command:ast)
        :~  :*  %create-view
                (qt 'db2' 'dbo' 'v1')
                (crip query)
                (query-of 'db2' query)
                ~
                ==
            ==
    !>  %-  parse:parse(default-database 'db1')
        "CREATE VIEW db2..v1 AS FROM my-table SELECT col1"
::
::  AS OF before AS
++  test-create-view-03
  =/  query  "FROM my-table SELECT col1"
  %+  expect-eq
    !>  ^-  (list command:ast)
        :~  :*  %create-view
                (qt 'db1' 'dbo' 'v1')
                (crip query)
                (query-of 'db1' query)
                [~ [%da ~2023.1.5]]
                ==
            ==
    !>  %-  parse:parse(default-database 'db1')
        "CREATE VIEW v1 AS OF ~2023.1.5 AS FROM my-table SELECT col1"
::
::  AS OF offset
++  test-create-view-04
  =/  query  "FROM my-table SELECT col1"
  %+  expect-eq
    !>  ^-  (list command:ast)
        :~  :*  %create-view
                (qt 'db1' 'dbo' 'v1')
                (crip query)
                (query-of 'db1' query)
                [~ [%as-of-offset 3 %days]]
                ==
            ==
    !>  %-  parse:parse(default-database 'db1')
        "CREATE VIEW v1 as of 3 days ago as FROM my-table SELECT col1"
::
::  common table expressions
++  test-create-view-05
  =/  query  "WITH (FROM my-table SELECT col1) AS my-cte FROM my-cte SELECT *"
  %+  expect-eq
    !>  ^-  (list command:ast)
        :~  :*  %create-view
                (qt 'db1' 'dbo' 'v1')
                (crip query)
                (query-of 'db1' query)
                ~
                ==
            ==
    !>  %-  parse:parse(default-database 'db1')
        "CREATE VIEW v1 AS WITH (FROM my-table SELECT col1) AS my-cte ".
        "FROM my-cte SELECT *"
::
::  set operation
++  test-create-view-06
  =/  query  "FROM a SELECT id UNION FROM b SELECT id"
  %+  expect-eq
    !>  ^-  (list command:ast)
        :~  :*  %create-view
                (qt 'db1' 'dbo' 'v1')
                (crip query)
                (query-of 'db1' query)
                ~
                ==
            ==
    !>  %-  parse:parse(default-database 'db1')
        "CREATE VIEW v1 AS FROM a SELECT id UNION FROM b SELECT id"
::
::  query without FROM
++  test-create-view-07
  =/  query  "SELECT 1 AS one"
  %+  expect-eq
    !>  ^-  (list command:ast)
        :~  :*  %create-view
                (qt 'db1' 'dbo' 'v1')
                (crip query)
                (query-of 'db1' query)
                ~
                ==
            ==
    !>  %-  parse:parse(default-database 'db1')
        "CREATE VIEW v1 AS SELECT 1 AS one"
::
::  a view, then a query of it: the script continues after the view
++  test-create-view-08
  =/  query  "FROM my-table SELECT col1 ORDER BY col1"
  %+  expect-eq
    !>  ^-  (list command:ast)
        :~  :*  %create-view
                (qt 'db1' 'dbo' 'v1')
                (crip query)
                (query-of 'db1' query)
                ~
                ==
            (query-of 'db1' "FROM v1 SELECT *")
            ==
    !>  %-  parse:parse(default-database 'db1')
        "CREATE VIEW v1 AS FROM my-table SELECT col1 ORDER BY col1; ".
        "FROM v1 SELECT *"
::
::  a view named as the table it reads
++  test-create-view-09
  =/  query  "FROM my-table WHERE col1 > 1 SELECT *"
  %+  expect-eq
    !>  ^-  (list command:ast)
        :~  :*  %create-view
                (qt 'db1' 'dbo' 'my-table')
                (crip query)
                (query-of 'db1' query)
                ~
                ==
            ==
    !>  %-  parse:parse(default-database 'db1')
        "CREATE VIEW my-table AS FROM my-table WHERE col1 > 1 SELECT *"
::
::  fail when AS is missing
++  test-fail-create-view-00
  %-  expect-fail
  |.  (parse:parse(default-database 'db1') "CREATE VIEW v1 FROM t SELECT *")
::
::  fail when the view query is a data change
++  test-fail-create-view-01
  %-  expect-fail
  |.  %-  parse:parse(default-database 'db1')
      "CREATE VIEW v1 AS INSERT INTO t VALUES (1)"
::
::  fail when the view query following WITH is a data change
++  test-fail-create-view-02
  %-  expect-fail
  |.  %-  parse:parse(default-database 'db1')
      "CREATE VIEW v1 AS WITH (FROM t SELECT a) AS c DELETE FROM t"
::
::  fail when the view name is not a term
++  test-fail-create-view-03
  %-  expect-fail
  |.  (parse:parse(default-database 'db1') "CREATE VIEW vIew AS FROM t SELECT *")
::
::  fail when AS has no query
++  test-fail-create-view-04
  %-  expect-fail
  |.  (parse:parse(default-database 'db1') "CREATE VIEW v1 AS ")
::
::  ALTER VIEW
::
++  test-alter-view-00
  =/  query  "FROM my-table SELECT col2"
  %+  expect-eq
    !>  ^-  (list command:ast)
        :~  :*  %alter-view
                (qt 'db1' 'ns1' 'v1')
                (crip query)
                (query-of 'db1' query)
                ~
                ==
            ==
    !>  %-  parse:parse(default-database 'db1')
        "alter  view ns1.v1 as FROM my-table SELECT col2"
::
++  test-alter-view-01
  =/  query  "FROM my-table SELECT col2"
  %+  expect-eq
    !>  ^-  (list command:ast)
        :~  :*  %alter-view
                (qt 'db2' 'dbo' 'v1')
                (crip query)
                (query-of 'db2' query)
                [~ [%da ~2023.1.5]]
                ==
            ==
    !>  %-  parse:parse(default-database 'db1')
        "ALTER VIEW db2..v1 AS OF ~2023.1.5 AS FROM my-table SELECT col2"
::
::  DROP VIEW AS OF
::
++  test-drop-view-as-of-00
  %+  expect-eq
    !>  ^-  (list command:ast)
        :~  [%drop-view (qt 'db1' 'dbo' 'v1') %.n [~ [%da ~2023.1.5]]]
            [%drop-view (qt 'db1' 'ns1' 'v2') %.y [~ [%da ~2023.1.6]]]
            [%drop-view (qt 'db1' 'dbo' 'v3') %.n ~]
            ==
    !>  %-  parse:parse(default-database 'db1')
        "DROP VIEW v1 AS OF ~2023.1.5; ".
        "DROP VIEW FORCE ns1.v2 AS OF ~2023.1.6; ".
        "DROP VIEW v3 AS OF NOW"
::
::  ALTER NAMESPACE TRANSFER VIEW
::
++  test-alter-namespace-view-00
  %+  expect-eq
    !>  ^-  (list command:ast)
        :~  :*  %alter-namespace
                'db1'
                'ns2'
                %view
                (qt 'db1' 'ns1' 'v1')
                ~
                ==
            :*  %alter-namespace
                'db1'
                'ns2'
                %view
                (qt 'db1' 'dbo' 'v1')
                [~ [%da ~2023.1.5]]
                ==
            ==
    !>  %-  parse:parse(default-database 'db1')
        "ALTER NAMESPACE ns2 TRANSFER VIEW ns1.v1; ".
        "alter namespace db1.ns2 transfer view v1 as of ~2023.1.5"
--
