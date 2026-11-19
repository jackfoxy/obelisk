::  Unit testing user-defined views on a Gall agent with %obelisk.
::
/-  ast=obelisk-ast
/+  *test-helpers
|%
::
++  setup
  "CREATE DATABASE db1; ".
  "CREATE TABLE db1..orders (id @ud, customer @t, amount @ud) ".
  "PRIMARY KEY (id); ".
  "CREATE TABLE db1..customers (customer @t, city @t) ".
  "PRIMARY KEY (customer); ".
  "INSERT INTO db1..orders VALUES (1, 'ann', 10) (2, 'bob', 250) ".
  "(3, 'ann', 400); ".
  "INSERT INTO db1..customers VALUES ('ann', 'paris') ('bob', 'rome');"
::
++  create-big-orders
  "CREATE VIEW big-orders AS ".
  "FROM orders WHERE amount > 100 SELECT id, customer, amount"
::
++  create-ann-big
  "CREATE VIEW ann-big AS ".
  "FROM big-orders WHERE customer = 'ann' SELECT id, amount"
::
++  order-row
  |=  [id=@ud who=@t amount=@ud]
  ^-  vector:ast
  [%vector ~[[%id [~.ud id]] [%customer [~.t who]] [%amount [~.ud amount]]]]
::
++  id-amount-row
  |=  [id=@ud amount=@ud]
  ^-  vector:ast
  [%vector ~[[%id [~.ud id]] [%amount [~.ud amount]]]]
::
++  select-result
  |=  $:  rows=(list vector:ast)
          server=@da
          relation=@t
          schema=@da
          data=@da
          ==
  ^-  cmd-result:ast
  :-  %results
      :~  [%action 'SELECT']
          [%result-set rows]
          [%server-time server]
          [%relation-name relation]
          [%schema-time schema]
          [%data-time data]
          [%vector-count (lent rows)]
          ==
::
::  CREATE VIEW
::
::  the CREATE VIEW result
++  test-create-view-00
  =|  run=@ud
  %-  exec-0-1
  :*  run
      [~2012.4.30 %db1 setup]
      [~2012.5.1 %db1 create-big-orders]
      :-  %results
          :~  [%action 'CREATE VIEW %big-orders']
              [%server-time ~2012.5.1]
              [%schema-time ~2012.5.1]
              ==
      ==
::
::  a view filters and projects its table
++  test-create-view-01
  =|  run=@ud
  %-  exec-1-1
  :*  run
      [~2012.4.30 %db1 setup]
      [~2012.5.1 %db1 create-big-orders]
      [~2012.5.2 %db1 "FROM big-orders SELECT *"]
      %:  select-result
            ~[(order-row 2 'bob' 250) (order-row 3 'ann' 400)]
            ~2012.5.2
            'db1.dbo.big-orders'
            ~2012.5.1
            ~2012.5.1
            ==
      ==
::
::  a query filters and projects a view
++  test-create-view-02
  =|  run=@ud
  %-  exec-1-1
  :*  run
      [~2012.4.30 %db1 setup]
      [~2012.5.1 %db1 create-big-orders]
      :+  ~2012.5.2
          %db1
          "FROM big-orders WHERE customer = 'ann' SELECT id, amount"
      %:  select-result
            ~[(id-amount-row 3 400)]
            ~2012.5.2
            'db1.dbo.big-orders'
            ~2012.5.1
            ~2012.5.1
            ==
      ==
::
::  a view of a join, with a column alias
++  test-create-view-03
  =|  run=@ud
  =/  row
    |=  [id=@ud who=@t city=@t]
    ^-  vector:ast
    [%vector ~[[%id [~.ud id]] [%who [~.t who]] [%city [~.t city]]]]
  %-  exec-1-1
  :*  run
      [~2012.4.30 %db1 setup]
      :+  ~2012.5.1
          %db1
          "CREATE VIEW order-cities AS FROM orders JOIN customers ".
          "SELECT orders.id, orders.customer AS who, customers.city"
      [~2012.5.2 %db1 "FROM order-cities WHERE city = 'paris' SELECT *"]
      %:  select-result
            ~[(row 1 'ann' 'paris') (row 3 'ann' 'paris')]
            ~2012.5.2
            'db1.dbo.order-cities'
            ~2012.5.1
            ~2012.5.1
            ==
      ==
::
::  a view of a view
++  test-create-view-04
  =|  run=@ud
  %-  exec-2-1
  :*  run
      [~2012.4.30 %db1 setup]
      [~2012.5.1 %db1 create-big-orders]
      [~2012.5.2 %db1 create-ann-big]
      [~2012.5.3 %db1 "FROM ann-big SELECT *"]
      %:  select-result
            ~[(id-amount-row 3 400)]
            ~2012.5.3
            'db1.dbo.ann-big'
            ~2012.5.2
            ~2012.5.2
            ==
      ==
::
::  a view shadows the table it reads
++  test-create-view-05
  =|  run=@ud
  %-  exec-1-1
  :*  run
      [~2012.4.30 %db1 setup]
      :+  ~2012.5.1
          %db1
          "CREATE VIEW orders AS FROM orders WHERE amount > 100 SELECT *"
      [~2012.5.2 %db1 "FROM orders SELECT *"]
      %:  select-result
            ~[(order-row 2 'bob' 250) (order-row 3 'ann' 400)]
            ~2012.5.2
            'db1.dbo.orders'
            ~2012.5.1
            ~2012.5.1
            ==
      ==
::
::  INSERT into a shadowed name changes the table, and the view shows it
++  test-create-view-06
  =|  run=@ud
  %-  exec-2-1
  :*  run
      [~2012.4.30 %db1 setup]
      :+  ~2012.5.1
          %db1
          "CREATE VIEW orders AS FROM orders WHERE amount > 100 SELECT *"
      [~2012.5.2 %db1 "INSERT INTO orders VALUES (4, 'cy', 500) (5, 'cy', 5)"]
      [~2012.5.3 %db1 "FROM orders SELECT *"]
      %:  select-result
            :~  (order-row 2 'bob' 250)
                (order-row 3 'ann' 400)
                (order-row 4 'cy' 500)
                ==
            ~2012.5.3
            'db1.dbo.orders'
            ~2012.5.1
            ~2012.5.2
            ==
      ==
::
::  time travel: a view as of before and after a change to its table
++  test-create-view-07
  =|  run=@ud
  %-  exec-2-2
  :*  run
      [~2012.4.30 %db1 setup]
      [~2012.5.1 %db1 create-big-orders]
      [~2012.5.2 %db1 "INSERT INTO orders VALUES (4, 'cy', 500)"]
      [~2012.5.3 %db1 "FROM big-orders AS OF ~2012.5.1..12.0.0 SELECT *"]
      [~2012.5.4 %db1 "FROM big-orders SELECT *"]
      %:  select-result
            ~[(order-row 2 'bob' 250) (order-row 3 'ann' 400)]
            ~2012.5.3
            'db1.dbo.big-orders'
            ~2012.5.1
            ~2012.5.1
            ==
      %:  select-result
            :~  (order-row 2 'bob' 250)
                (order-row 3 'ann' 400)
                (order-row 4 'cy' 500)
                ==
            ~2012.5.4
            'db1.dbo.big-orders'
            ~2012.5.1
            ~2012.5.2
            ==
      ==
::
::  a change to a table the view does not read leaves its cache alone
++  test-create-view-08
  =|  run=@ud
  %-  exec-2-1
  :*  run
      [~2012.4.30 %db1 setup]
      [~2012.5.1 %db1 create-big-orders]
      [~2012.5.2 %db1 "INSERT INTO customers VALUES ('cy', 'oslo')"]
      [~2012.5.3 %db1 "FROM big-orders SELECT *"]
      %:  select-result
            ~[(order-row 2 'bob' 250) (order-row 3 'ann' 400)]
            ~2012.5.3
            'db1.dbo.big-orders'
            ~2012.5.1
            ~2012.5.1
            ==
      ==
::
::  a view of a view refreshes when the table under both changes
++  test-create-view-09
  =|  run=@ud
  %-  exec-3-1
  :*  run
      [~2012.4.30 %db1 setup]
      [~2012.5.1 %db1 create-big-orders]
      [~2012.5.2 %db1 create-ann-big]
      [~2012.5.3 %db1 "UPDATE orders SET amount = 900 WHERE id = 1"]
      [~2012.5.4 %db1 "FROM ann-big SELECT *"]
      %:  select-result
            ~[(id-amount-row 1 900) (id-amount-row 3 400)]
            ~2012.5.4
            'db1.dbo.ann-big'
            ~2012.5.2
            ~2012.5.3
            ==
      ==
::
::  TOP and ORDER BY in a view
++  test-create-view-10
  =|  run=@ud
  %-  exec-1-1
  :*  run
      [~2012.4.30 %db1 setup]
      :+  ~2012.5.1
          %db1
          "CREATE VIEW top-orders AS ".
          "FROM orders SELECT TOP 2 id, amount ORDER BY amount DESC"
      [~2012.5.2 %db1 "FROM top-orders SELECT *"]
      %:  select-result
            ~[(id-amount-row 3 400) (id-amount-row 2 250)]
            ~2012.5.2
            'db1.dbo.top-orders'
            ~2012.5.1
            ~2012.5.1
            ==
      ==
::
::  a view with a common table expression
++  test-create-view-11
  =|  run=@ud
  %-  exec-1-1
  :*  run
      [~2012.4.30 %db1 setup]
      :+  ~2012.5.1
          %db1
          "CREATE VIEW ann-orders AS ".
          "WITH (FROM orders WHERE customer = 'ann' SELECT id, amount) AS ann ".
          "FROM ann SELECT *"
      [~2012.5.2 %db1 "FROM ann-orders SELECT *"]
      %:  select-result
            ~[(id-amount-row 1 10) (id-amount-row 3 400)]
            ~2012.5.2
            'db1.dbo.ann-orders'
            ~2012.5.1
            ~2012.5.1
            ==
      ==
::
::  a view of a set operation
++  test-create-view-12
  =|  run=@ud
  =/  row
    |=(who=@t ^-(vector:ast [%vector ~[[%customer [~.t who]]]]))
  %-  exec-1-1
  :*  run
      [~2012.4.30 %db1 setup]
      :+  ~2012.5.1
          %db1
          "CREATE VIEW names AS FROM orders SELECT customer ".
          "UNION FROM customers SELECT customer"
      [~2012.5.2 %db1 "FROM names SELECT *"]
      %:  select-result
            ~[(row 'ann') (row 'bob')]
            ~2012.5.2
            'db1.dbo.names'
            ~2012.5.1
            ~2012.5.1
            ==
      ==
::
::  a view not cacheable: its query reads a relative AS OF, here one day
::  before the time of the query reading the view
++  test-create-view-13
  =|  run=@ud
  %-  exec-2-1
  :*  run
      [~2012.4.30 %db1 setup]
      [~2012.5.1 %db1 "CREATE VIEW day-ago AS FROM orders AS OF ~d1 SELECT *"]
      [~2012.5.2..12.0.0 %db1 "INSERT INTO orders VALUES (4, 'cy', 500)"]
      [~2012.5.3 %db1 "FROM day-ago SELECT *"]
      %:  select-result
            :~  (order-row 1 'ann' 10)
                (order-row 2 'bob' 250)
                (order-row 3 'ann' 400)
                ==
            ~2012.5.3
            'db1.dbo.day-ago'
            ~2012.5.1
            ~2012.5.3
            ==
      ==
::
::  sys.views
++  test-sys-views-00
  =|  run=@ud
  =/  row
    |=  [name=@tas cacheable=? definition=@t]
    ^-  vector:ast
    :-  %vector
    :~  [%namespace [~.tas %dbo]]
        [%name [~.tas name]]
        [%cacheable [~.f cacheable]]
        [%definition [~.t definition]]
        ==
  %-  exec-3-1
  :*  run
      [~2012.4.30 %db1 setup]
      [~2012.5.1 %db1 create-big-orders]
      [~2012.5.2 %db1 create-ann-big]
      [~2012.5.3 %db1 "CREATE VIEW day-ago AS FROM orders AS OF ~d1 SELECT *"]
      :+  ~2012.5.4
          %db1
          "FROM sys.views SELECT namespace, name, cacheable, definition"
      %:  select-result
            :~  %^  row  %big-orders  %.y
                'FROM orders WHERE amount > 100 SELECT id, customer, amount'
                %^  row  %ann-big  %.y
                'FROM big-orders WHERE customer = \'ann\' SELECT id, amount'
                (row %day-ago %.n 'FROM orders AS OF ~d1 SELECT *')
                ==
            ~2012.5.4
            'db1.sys.views'
            ~2012.5.3
            ~2012.5.3
            ==
      ==
::
::  sys.view-references
++  test-sys-views-01
  =|  run=@ud
  =/  row
    |=  [name=@tas ref=@tas kind=@tas]
    ^-  vector:ast
    :-  %vector
    :~  [%namespace [~.tas %dbo]]
        [%name [~.tas name]]
        [%ref-namespace [~.tas %dbo]]
        [%ref-name [~.tas ref]]
        [%ref-type [~.tas kind]]
        ==
  %-  exec-2-1
  :*  run
      [~2012.4.30 %db1 setup]
      [~2012.5.1 %db1 create-big-orders]
      [~2012.5.2 %db1 create-ann-big]
      [~2012.5.3 %db1 "FROM sys.view-references SELECT *"]
      %:  select-result
            :~  (row %ann-big %big-orders %view)
                (row %big-orders %orders %table)
                ==
            ~2012.5.3
            'db1.sys.view-references'
            ~2012.5.2
            ~2012.5.2
            ==
      ==
::
::  sys.columns lists view columns
++  test-sys-views-02
  =|  run=@ud
  =/  row
    |=  [ordinal=@ud name=@tas type=@ta]
    ^-  vector:ast
    :-  %vector
    :~  [%name [~.tas %big-orders]]
        [%col-ordinal [~.ud ordinal]]
        [%col-name [~.tas name]]
        [%col-type [~.ta type]]
        ==
  %-  exec-1-1
  :*  run
      [~2012.4.30 %db1 setup]
      [~2012.5.1 %db1 create-big-orders]
      :+  ~2012.5.2
          %db1
          "FROM sys.columns WHERE relation-type = 'view' ".
          "SELECT name, col-ordinal, col-name, col-type"
      %:  select-result
            :~  (row 1 %id ~.ud)
                (row 2 %customer ~.t)
                (row 3 %amount ~.ud)
                ==
            ~2012.5.2
            'db1.sys.columns'
            ~2012.5.1
            ~2012.5.1
            ==
      ==
::
::  ALTER VIEW
::
++  test-alter-view-00
  =|  run=@ud
  %-  exec-2-1
  :*  run
      [~2012.4.30 %db1 setup]
      [~2012.5.1 %db1 create-big-orders]
      :+  ~2012.5.2
          %db1
          "ALTER VIEW big-orders AS FROM orders WHERE amount > 300 ".
          "SELECT id, amount"
      [~2012.5.3 %db1 "FROM big-orders SELECT *"]
      %:  select-result
            ~[(id-amount-row 3 400)]
            ~2012.5.3
            'db1.dbo.big-orders'
            ~2012.5.2
            ~2012.5.2
            ==
      ==
::
::  the prior definition of an altered view, by time travel
++  test-alter-view-01
  =|  run=@ud
  %-  exec-2-1
  :*  run
      [~2012.4.30 %db1 setup]
      [~2012.5.1 %db1 create-big-orders]
      :+  ~2012.5.2
          %db1
          "ALTER VIEW big-orders AS FROM orders WHERE amount > 300 ".
          "SELECT id, amount"
      [~2012.5.3 %db1 "FROM big-orders AS OF ~2012.5.1 SELECT *"]
      %:  select-result
            ~[(order-row 2 'bob' 250) (order-row 3 'ann' 400)]
            ~2012.5.3
            'db1.dbo.big-orders'
            ~2012.5.1
            ~2012.5.1
            ==
      ==
::
::  DROP VIEW
::
::  dropping a shadowing view shows the table
++  test-drop-view-00
  =|  run=@ud
  %-  exec-2-1
  :*  run
      [~2012.4.30 %db1 setup]
      :+  ~2012.5.1
          %db1
          "CREATE VIEW orders AS FROM orders WHERE amount > 100 SELECT *"
      [~2012.5.2 %db1 "DROP VIEW orders"]
      [~2012.5.3 %db1 "FROM orders SELECT *"]
      %:  select-result
            :~  (order-row 1 'ann' 10)
                (order-row 2 'bob' 250)
                (order-row 3 'ann' 400)
                ==
            ~2012.5.3
            'db1.dbo.orders'
            ~2012.4.30
            ~2012.4.30
            ==
      ==
::
::  a dropped view, by time travel
++  test-drop-view-01
  =|  run=@ud
  %-  exec-2-1
  :*  run
      [~2012.4.30 %db1 setup]
      [~2012.5.1 %db1 create-big-orders]
      [~2012.5.2 %db1 "DROP VIEW big-orders"]
      [~2012.5.3 %db1 "FROM big-orders AS OF ~2012.5.1..12.0.0 SELECT *"]
      %:  select-result
            ~[(order-row 2 'bob' 250) (order-row 3 'ann' 400)]
            ~2012.5.3
            'db1.dbo.big-orders'
            ~2012.5.1
            ~2012.5.1
            ==
      ==
::
::  DROP VIEW FORCE drops the views reading the view
++  test-drop-view-02
  =|  run=@ud
  %-  exec-2-1
  :*  run
      [~2012.4.30 %db1 setup]
      [~2012.5.1 %db1 create-big-orders]
      [~2012.5.2 %db1 create-ann-big]
      [~2012.5.3 %db1 "DROP VIEW FORCE big-orders"]
      :-  %results
          :~  [%action 'DROP VIEW %big-orders']
              [%server-time ~2012.5.3]
              [%schema-time ~2012.5.3]
              [%message 'dropped view %dbo.%ann-big']
              ==
      ==
::
::  a view dropped by FORCE does not exist
++  test-fail-drop-view-00
  =|  run=@ud
  %-  failon-4
  :*  run
      [~2012.4.30 %db1 setup]
      [~2012.5.1 %db1 create-big-orders]
      [~2012.5.2 %db1 create-ann-big]
      [~2012.5.3 %db1 "DROP VIEW FORCE big-orders"]
      [~2012.5.4 %db1 "FROM ann-big SELECT *"]
      'SELECT: table %db1.%dbo.%ann-big does not exist'
      ==
::
::  a view read by a view cannot be dropped without FORCE
++  test-fail-drop-view-01
  =|  run=@ud
  %-  failon-3
  :*  run
      [~2012.4.30 %db1 setup]
      [~2012.5.1 %db1 create-big-orders]
      [~2012.5.2 %db1 create-ann-big]
      [~2012.5.3 %db1 "DROP VIEW big-orders"]
      'DROP VIEW: %big-orders used in view %dbo.%ann-big, use FORCE to DROP'
      ==
::
++  test-fail-drop-view-02
  =|  run=@ud
  %-  failon-1
  :*  run
      [~2012.4.30 %db1 setup]
      [~2012.5.1 %db1 "DROP VIEW nope"]
      'DROP VIEW: %nope does not exist in %dbo'
      ==
::
++  test-fail-drop-view-03
  =|  run=@ud
  %-  failon-1
  :*  run
      [~2012.4.30 %db1 setup]
      [~2012.5.1 %db1 "DROP VIEW sys.tables"]
      'DROP VIEW: %tables is a system view'
      ==
::
::  failures
::
++  test-fail-create-view-00
  =|  run=@ud
  %-  failon-2
  :*  run
      [~2012.4.30 %db1 setup]
      [~2012.5.1 %db1 create-big-orders]
      [~2012.5.2 %db1 create-big-orders]
      'CREATE VIEW: %big-orders exists in %dbo'
      ==
::
++  test-fail-create-view-01
  =|  run=@ud
  %-  failon-1
  :*  run
      [~2012.4.30 %db1 setup]
      [~2012.5.1 %db1 "CREATE VIEW sys.v AS FROM orders SELECT *"]
      'CREATE VIEW: views cannot be created in namespace %sys'
      ==
::
++  test-fail-create-view-02
  =|  run=@ud
  %-  failon-1
  :*  run
      [~2012.4.30 %db1 setup]
      [~2012.5.1 %db1 "CREATE VIEW v AS FROM nothing SELECT *"]
      'CREATE VIEW: %dbo.%nothing does not exist'
      ==
::
++  test-fail-create-view-03
  =|  run=@ud
  %-  failon-1
  :*  run
      [~2012.4.30 %db1 setup]
      [~2012.5.1 %db1 "CREATE VIEW v AS FROM db2..orders SELECT *"]
      'CREATE VIEW: view references another database %db2'
      ==
::
++  test-fail-create-view-04
  =|  run=@ud
  %-  failon-1
  :*  run
      [~2012.4.30 %db1 setup]
      :+  ~2012.5.1
          %db1
          "CREATE VIEW v AS FROM orders JOIN customers ".
          "SELECT orders.customer, customers.customer"
      'duplicate column names'
      ==
::
++  test-fail-create-view-05
  =|  run=@ud
  %-  failon-1
  :*  run
      [~2012.4.30 %db1 setup]
      [~2012.5.1 %db1 "CREATE VIEW ns9.v AS FROM orders SELECT *"]
      'CREATE VIEW: namespace %ns9 does not exist'
      ==
::
++  test-fail-create-view-06
  =|  run=@ud
  %-  failon-1
  :*  run
      [~2012.4.30 %db1 setup]
      [~2012.5.1 %db1 "CREATE VIEW db9..v AS FROM orders SELECT *"]
      'CREATE VIEW: database %db9 does not exist'
      ==
::
::  a table read by a view cannot be shadowed
++  test-fail-create-view-07
  =|  run=@ud
  %-  failon-2
  :*  run
      [~2012.4.30 %db1 setup]
      [~2012.5.1 %db1 create-big-orders]
      [~2012.5.2 %db1 "CREATE VIEW orders AS FROM orders SELECT *"]
      %-  crip
      "CREATE VIEW: %orders would shadow table %dbo.%orders used in view ".
      "%dbo.%big-orders"
      ==
::
++  test-fail-create-view-08
  =|  run=@ud
  %-  failon-2
  :*  run
      [~2012.4.30 %db1 setup]
      [~2012.5.1 %db1 create-big-orders]
      :+  ~2012.5.2
          %db1
          "CREATE VIEW v2 AS OF ~2012.5.1 AS FROM orders SELECT *"
      'CREATE VIEW: %v2 as-of schema time out of order'
      ==
::
++  test-fail-create-view-09
  =|  run=@ud
  %-  failon-1
  :*  run
      [~2012.4.30 %db1 setup]
      :+  ~2012.5.1
          %db1
          "FROM orders SELECT *; CREATE VIEW v AS FROM orders SELECT *"
      'CREATE VIEW: state change after query in script'
      ==
::
++  test-fail-alter-view-00
  =|  run=@ud
  %-  failon-1
  :*  run
      [~2012.4.30 %db1 setup]
      [~2012.5.1 %db1 "ALTER VIEW nope AS FROM orders SELECT *"]
      'ALTER VIEW: %nope does not exist in %dbo'
      ==
::
::  a view read by a view cannot be altered
++  test-fail-alter-view-01
  =|  run=@ud
  %-  failon-3
  :*  run
      [~2012.4.30 %db1 setup]
      [~2012.5.1 %db1 create-big-orders]
      [~2012.5.2 %db1 create-ann-big]
      [~2012.5.3 %db1 "ALTER VIEW big-orders AS FROM orders SELECT *"]
      'ALTER VIEW: %big-orders used in view %dbo.%ann-big'
      ==
--
