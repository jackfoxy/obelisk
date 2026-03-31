::  Demonstrate unit testing filtered queries on a Gall agent with %obelisk.
::
/-  ast, *obelisk
/+  *predicate, *scalars, *test, *test-helpers, *utils
|%
::
++  create-mytable
  "CREATE TABLE db1..my-table ".
  "(col1 @t, col2 @da, col3 @t, col4 @t) ".
  "PRIMARY KEY (col1)"
++  create-rs-table
  "CREATE TABLE db1..my-table ".
  "(col1 @t, col2 @rs) ".
  "PRIMARY KEY (col1)"
++  create-rd-table
  "CREATE TABLE db1..my-table ".
  "(col1 @t, col2 @rd) ".
  "PRIMARY KEY (col1)"
++  create-rd-2col-table
  "CREATE TABLE db1..my-table ".
  "(col1 @t, col2 @rd, col3 @rd) ".
  "PRIMARY KEY (col1)"
++  create-sd-table
  "CREATE TABLE db1..my-table ".
  "(col1 @t, col2 @sd) ".
  "PRIMARY KEY (col1)"
++  create-sd-2col-table
  "CREATE TABLE db1..my-table ".
  "(col1 @t, col2 @sd, col3 @sd) ".
  "PRIMARY KEY (col1)"
++  create-ud-3col-table
  "CREATE TABLE db1..my-table ".
  "(col1 @t, col2 @ud, col3 @ud, col4 @ud) ".
  "PRIMARY KEY (col1)"
++  create-joined-tables
  "CREATE TABLE db1..my-table ".
  "(col1 @t, col2 @da) ".
  "PRIMARY KEY (col1); ".
  "CREATE TABLE db1..my-table-2 ".
  "(col1 @t, col3 @t, col4 @t) ".
  "PRIMARY KEY (col1)"
::
++  create-scalar-joined-tables
  "CREATE TABLE db1..my-table ".
  "(col1 @t, col2 @ud, col3 @t, col4 @da, col5 @ud) ".
  "PRIMARY KEY (col1); ".
  "CREATE TABLE db1..my-table-2 ".
  "(col1 @t, col2 @ud, col3 @t, col4 @da, col5 @ud) ".
  "PRIMARY KEY (col1)"
::
++  insert-scalar-joined-tables
  "INSERT INTO my-table".
  " VALUES".
  " ('A', 2, 'ant', ~2024.1.2, 1)".
  " ('B', 4, 'bear', ~2024.1.4, 2)".
  " ('C', 6, 'cobra', ~2024.1.6, 3)".
  " ('D', 8, 'dove', ~2024.1.8, 4); ".
  "INSERT INTO my-table-2".
  " VALUES".
  " ('U', 1, 'u', ~2024.1.1, 1)".
  " ('V', 3, 'v', ~2024.1.3, 2)".
  " ('W', 5, 'w', ~2024.1.5, 3)".
  " ('X', 7, 'x', ~2024.1.7, 4)"
::
++  scalar-row-a-u  :-  %vector  :~  [%col1 [~.t 'A']]  [%col3 [~.t 'u']]  ==
++  scalar-row-a-v  :-  %vector  :~  [%col1 [~.t 'A']]  [%col3 [~.t 'v']]  ==
++  scalar-row-a-w  :-  %vector  :~  [%col1 [~.t 'A']]  [%col3 [~.t 'w']]  ==
++  scalar-row-a-x  :-  %vector  :~  [%col1 [~.t 'A']]  [%col3 [~.t 'x']]  ==
++  scalar-row-b-v  :-  %vector  :~  [%col1 [~.t 'B']]  [%col3 [~.t 'v']]  ==
++  scalar-row-b-w  :-  %vector  :~  [%col1 [~.t 'B']]  [%col3 [~.t 'w']]  ==
++  scalar-row-b-x  :-  %vector  :~  [%col1 [~.t 'B']]  [%col3 [~.t 'x']]  ==
++  scalar-row-c-w  :-  %vector  :~  [%col1 [~.t 'C']]  [%col3 [~.t 'w']]  ==
++  scalar-row-c-x  :-  %vector  :~  [%col1 [~.t 'C']]  [%col3 [~.t 'x']]  ==
++  scalar-row-d-x  :-  %vector  :~  [%col1 [~.t 'D']]  [%col3 [~.t 'x']]  ==
::
++  run-scalar-joined-test
  |=  [query=tape count=@ud expected-rows=(list vector:ast)]
  =|  run=@ud
  %-  exec-2-1
  :*  run
      [~2012.4.30 %sys "CREATE DATABASE db1"]
      ::
      [~2012.5.1 %db1 create-scalar-joined-tables]
      ::
      [~2012.5.2 %db1 insert-scalar-joined-tables]
      ::
      [~2012.5.3 %db1 query]
      ::
      :-  %results
          :~  [%action 'SELECT']
              :-  %result-set
                  expected-rows
              [%server-time ~2012.5.3]
              [%relation 'db1.dbo.my-table']
              [%schema-time ~2012.5.1]
              [%data-time ~2012.5.2]
              [%relation 'db1.dbo.my-table-2']
              [%schema-time ~2012.5.1]
              [%data-time ~2012.5.2]
              [%vector-count count]
              ==
      ==
::
::  EQ
::
::  WHERE <column> = <literal>
++  test-eq-00
  =|  run=@ud
  %-  exec-2-1
  :*  run
      [~2012.4.30 %sys "CREATE DATABASE db1"]
      ::
      [~2012.5.1 %db1 create-mytable]
      ::
      :+  ~2012.5.2
          %db1
          "INSERT INTO my-table".
          " VALUES".
          " ('Abby', ~1999.2.19, 'tricolor', 'row1')".
          " ('Ace', ~2005.12.19, 'ticolor', 'row2')".
          " ('Angel', ~2001.9.19, 'tuxedo', 'row3')"
      ::
      :+  ~2012.5.3
          %db1
          "FROM my-table WHERE col3 = 'tuxedo' SELECT *"
      ::
      :-  %results
          :~  [%action 'SELECT']
              :-  %result-set
                  :~  :-  %vector
                          :~  [%col1 [~.t 'Angel']]
                              [%col2 [~.da ~2001.9.19]]
                              [%col3 [~.t 'tuxedo']]
                              [%col4 [~.t 'row3']]
                              ==
                      ==
              [%server-time ~2012.5.3]
              [%relation 'db1.dbo.my-table']
              [%schema-time ~2012.5.1]
              [%data-time ~2012.5.2]
              [%vector-count 1]
              ==
      ==
::
::  WHERE <literal> = <column>
++  test-eq-01
  =|  run=@ud
  %-  exec-2-1
  :*  run
      [~2012.4.30 %sys "CREATE DATABASE db1"]
      ::
      [~2012.5.1 %db1 create-mytable]
      ::
      :+  ~2012.5.2
          %db1
          "INSERT INTO my-table".
          " VALUES".
          " ('Abby', ~1999.2.19, 'tricolor', 'row1')".
          " ('Ace', ~2005.12.19, 'ticolor', 'row2')".
          " ('Angel', ~2001.9.19, 'tuxedo', 'row3')"
      ::
      :+  ~2012.5.3
          %db1
          "FROM my-table WHERE 'tuxedo' = col3 SELECT *"
      ::
      :-  %results
          :~  [%action 'SELECT']
              :-  %result-set
                  :~  :-  %vector
                          :~  [%col1 [~.t 'Angel']]
                              [%col2 [~.da ~2001.9.19]]
                              [%col3 [~.t 'tuxedo']]
                              [%col4 [~.t 'row3']]
                              ==
                      ==
              [%server-time ~2012.5.3]
              [%relation 'db1.dbo.my-table']
              [%schema-time ~2012.5.1]
              [%data-time ~2012.5.2]
              [%vector-count 1]
              ==
      ==
::
::  WHERE <column> = <column>
++  test-eq-02
  =|  run=@ud
  %-  exec-2-1
  :*  run
      [~2012.4.30 %sys "CREATE DATABASE db1"]
      ::
      [~2012.5.1 %db1 create-mytable]
      ::
      :+  ~2012.5.2
          %db1
          "INSERT INTO my-table".
          " VALUES".
          " ('Abby', ~1999.2.19, 'tricolor', 'row1')".
          " ('Ace', ~2005.12.19, 'ticolor', 'row2')".
          " ('Angel', ~2001.9.19, 'Angel', 'row3')"
      ::
      :+  ~2012.5.3
          %db1
          "FROM my-table WHERE col1 = col3 SELECT *"
      ::
      :-  %results
          :~  [%action 'SELECT']
              :-  %result-set
                  :~  :-  %vector
                          :~  [%col1 [~.t 'Angel']]
                              [%col2 [~.da ~2001.9.19]]
                              [%col3 [~.t 'Angel']]
                              [%col4 [~.t 'row3']]
                              ==
                      ==
              [%server-time ~2012.5.3]
              [%relation 'db1.dbo.my-table']
              [%schema-time ~2012.5.1]
              [%data-time ~2012.5.2]
              [%vector-count 1]
              ==
      ==
::
::  view WHERE <column> = <literal>
++  test-eq-03
  =|  run=@ud
  %-  exec-1-1
  :*  run
      [~2012.4.30 %sys "CREATE DATABASE db1"]
      ::
      [~2012.5.1 %db1 create-mytable]
      ::
      :+  ~2012.5.3
          %db1
          "FROM sys.columns WHERE col-name = 'col3' SELECT *"
      ::
      :-  %results
          :~  [%action 'SELECT']
              :-  %result-set
                  :~  :-  %vector
                          :~  [p=%namespace q=[p=~.tas q=%dbo]]
                              [p=%name q=[p=~.tas q=%my-table]]
                              [p=%col-ordinal q=[p=~.ud q=3]]
                              [p=%col-name q=[p=~.tas q=%col3]]
                              [p=%col-type q=[p=~.ta q=116]]
                              ==
                      ==
              [%server-time ~2012.5.3]
              [%relation 'db1.sys.columns']
              [%schema-time ~2012.5.1]
              [%data-time ~2012.5.1]
              [%vector-count 1]
              ==
      ==
::
::  view WHERE <column> = <literal>
++  test-eq-04
  =|  run=@ud
  %-  exec-1-1
  :*  run
      [~2012.4.30 %sys "CREATE DATABASE db1"]
      ::
      [~2012.5.1 %db1 create-mytable]
      ::
      :+  ~2012.5.3
          %db1
          "FROM sys.columns WHERE 'col3' = col-name SELECT *"
      ::
      :-  %results
          :~  [%action 'SELECT']
              :-  %result-set
                  :~  :-  %vector
                          :~  [p=%namespace q=[p=~.tas q=%dbo]]
                              [p=%name q=[p=~.tas q=%my-table]]
                              [p=%col-ordinal q=[p=~.ud q=3]]
                              [p=%col-name q=[p=~.tas q=%col3]]
                              [p=%col-type q=[p=~.ta q=116]]
                              ==
                      ==
              [%server-time ~2012.5.3]
              [%relation 'db1.sys.columns']
              [%schema-time ~2012.5.1]
              [%data-time ~2012.5.1]
              [%vector-count 1]
              ==
      ==
::
::  view WHERE <literal> = <literal>
++  test-eq-05
  =|  run=@ud
  %-  exec-1-1
  :*  run
      [~2012.4.30 %sys "CREATE DATABASE db1"]
      ::
      [~2012.5.1 %db1 create-mytable]
      ::
      :+  ~2012.5.3
          %db1
          "FROM sys.columns WHERE 1 = 1 SELECT *"
      ::
      :-  %results
          :~  [%action 'SELECT']
              :-  %result-set
                  :~  :-  %vector
                          :~  [p=%namespace q=[p=~.tas q=%dbo]]
                              [p=%name q=[p=~.tas q=%my-table]]
                              [p=%col-ordinal q=[p=~.ud q=2]]
                              [p=%col-name q=[p=~.tas q=%col2]]
                              [p=%col-type q=[p=~.ta q=~.da]]
                              ==
                      :-  %vector
                          :~  [p=%namespace q=[p=~.tas q=%dbo]]
                              [p=%name q=[p=~.tas q=%my-table]]
                              [p=%col-ordinal q=[p=~.ud q=1]]
                              [p=%col-name q=[p=~.tas q=%col1]]
                              [p=%col-type q=[p=~.ta q=~.t]]
                              ==
                      :-  %vector
                          :~  [p=%namespace q=[p=~.tas q=%dbo]]
                              [p=%name q=[p=~.tas q=%my-table]]
                              [p=%col-ordinal q=[p=~.ud q=4]]
                              [p=%col-name q=[p=~.tas q=%col4]]
                              [p=%col-type q=[p=~.ta q=~.t]]
                              ==
                      :-  %vector
                          :~  [p=%namespace q=[p=~.tas q=%dbo]]
                              [p=%name q=[p=~.tas q=%my-table]]
                              [p=%col-ordinal q=[p=~.ud q=3]]
                              [p=%col-name q=[p=~.tas q=%col3]]
                              [p=%col-type q=[p=~.ta q=~.t]]
                              ==
                      ==
              [%server-time ~2012.5.3]
              [%relation 'db1.sys.columns']
              [%schema-time ~2012.5.1]
              [%data-time ~2012.5.1]
              [%vector-count 4]
              ==
      ==
::
::  WHERE <column> = <literal> @rs
++  test-eq-06
  =|  run=@ud
  %-  exec-2-1
  :*  run
      [~2012.4.30 %sys "CREATE DATABASE db1"]
      ::
      [~2012.5.1 %db1 create-rs-table]
      ::
      :+  ~2012.5.2
          %db1
          "INSERT INTO my-table".
          " VALUES".
          " ('row1', .6.02)".
          " ('row2', .3.14)"
      ::
      :+  ~2012.5.3
          %db1
          "FROM my-table WHERE col2 = .6.02 SELECT *"
      ::
      :-  %results
          :~  [%action 'SELECT']
              :-  %result-set
                  :~  :-  %vector
                          :~  [%col1 [~.t 'row1']]
                              [%col2 [~.rs .6.02]]
                              ==
                      ==
              [%server-time ~2012.5.3]
              [%relation 'db1.dbo.my-table']
              [%schema-time ~2012.5.1]
              [%data-time ~2012.5.2]
              [%vector-count 1]
              ==
      ==
::
::  WHERE <column> = <literal> @rs +0 = -0
++  test-eq-07
  =|  run=@ud
  %-  exec-2-1
  :*  run
      [~2012.4.30 %sys "CREATE DATABASE db1"]
      ::
      [~2012.5.1 %db1 create-rs-table]
      ::
      :+  ~2012.5.2
          %db1
          "INSERT INTO my-table".
          " VALUES".
          " ('row1', .-0)".
          " ('row2', .3.14)"
      ::
      :+  ~2012.5.3
          %db1
          "FROM my-table WHERE col2 = .0 SELECT *"
      ::
      :-  %results
          :~  [%action 'SELECT']
              :-  %result-set
                  :~  :-  %vector
                          :~  [%col1 [~.t 'row1']]
                              [%col2 [~.rs .-0]]
                              ==
                      ==
              [%server-time ~2012.5.3]
              [%relation 'db1.dbo.my-table']
              [%schema-time ~2012.5.1]
              [%data-time ~2012.5.2]
              [%vector-count 1]
              ==
      ==
::
::  WHERE <column> = <literal> @rd
++  test-eq-08
  =|  run=@ud
  %-  exec-2-1
  :*  run
      [~2012.4.30 %sys "CREATE DATABASE db1"]
      ::
      [~2012.5.1 %db1 create-rd-table]
      ::
      :+  ~2012.5.2
          %db1
          "INSERT INTO my-table".
          " VALUES".
          " ('row1', .~6.02)".
          " ('row2', .~3.14)"
      ::
      :+  ~2012.5.3
          %db1
          "FROM my-table WHERE col2 = .~6.02 SELECT *"
      ::
      :-  %results
          :~  [%action 'SELECT']
              :-  %result-set
                  :~  :-  %vector
                          :~  [%col1 [~.t 'row1']]
                              [%col2 [~.rd .~6.02]]
                              ==
                      ==
              [%server-time ~2012.5.3]
              [%relation 'db1.dbo.my-table']
              [%schema-time ~2012.5.1]
              [%data-time ~2012.5.2]
              [%vector-count 1]
              ==
      ==
::
::  WHERE <column> = <literal> @rd +0 = -0
++  test-eq-09
  =|  run=@ud
  %-  exec-2-1
  :*  run
      [~2012.4.30 %sys "CREATE DATABASE db1"]
      ::
      [~2012.5.1 %db1 create-rd-table]
      ::
      :+  ~2012.5.2
          %db1
          "INSERT INTO my-table".
          " VALUES".
          " ('row1', .~-0)".
          " ('row2', .~3.14)"
      ::
      :+  ~2012.5.3
          %db1
          "FROM my-table WHERE col2 = .~0 SELECT *"
      ::
      :-  %results
          :~  [%action 'SELECT']
              :-  %result-set
                  :~  :-  %vector
                          :~  [%col1 [~.t 'row1']]
                              [%col2 [~.rd .~-0]]
                              ==
                      ==
              [%server-time ~2012.5.3]
              [%relation 'db1.dbo.my-table']
              [%schema-time ~2012.5.1]
              [%data-time ~2012.5.2]
              [%vector-count 1]
              ==
      ==
::
::  fail WHERE <column> = <literal> types differ
++  test-fail-eq-00
  =|  run=@ud
  %-  failon-3
  :*  run
      [~2012.4.30 %sys "CREATE DATABASE db1"]
      ::
      [~2012.5.1 %db1 create-mytable]
      ::
      :+  ~2012.5.2
          %db1
          "INSERT INTO my-table".
          " VALUES".
          " ('Abby', ~1999.2.19, 'tricolor', 'row1')".
          " ('Ace', ~2005.12.19, 'ticolor', 'row2')".
          " ('Angel', ~2001.9.19, 'Angel', 'row3')"
      ::
      :+  ~2012.5.2
          %db1
          "FROM my-table WHERE col1 = ~1999.2.19 SELECT *"
      ::
      %-  crip
          "comparing column to literal of different aura: %col1 type=~.t ".
          "[p=~.da q=170.141.184.492.111.779.796.175.933.613.172.326.400]"
      ==
::
::  fail WHERE <literal> = <column> types differ
++  test-fail-eq-01
  =|  run=@ud
  %-  failon-3
  :*  run
      [~2012.4.30 %sys "CREATE DATABASE db1"]
      ::
      [~2012.5.1 %db1 create-mytable]
      ::
      :+  ~2012.5.2
          %db1
          "INSERT INTO my-table".
          " VALUES".
          " ('Abby', ~1999.2.19, 'tricolor', 'row1')".
          " ('Ace', ~2005.12.19, 'ticolor', 'row2')".
          " ('Angel', ~2001.9.19, 'Angel', 'row3')"
      ::
      :+  ~2012.5.2
          %db1
          "FROM my-table WHERE ~1999.2.19 = col1 SELECT *"
      ::
      %-  crip
          "comparing literal to column of different aura: ".
          "[p=~.da q=170.141.184.492.111.779.796.175.933.613.172.326.400] ".
          "%col1 type=~.t"
      ==
::
::  fail WHERE <column> = <column> types differ
++  test-fail-eq-02
  =|  run=@ud
  %-  failon-3
  :*  run
      [~2012.4.30 %sys "CREATE DATABASE db1"]
      ::
      [~2012.5.1 %db1 create-mytable]
      ::
      :+  ~2012.5.2
          %db1
          "INSERT INTO my-table".
          " VALUES".
          " ('Abby', ~1999.2.19, 'tricolor', 'row1')".
          " ('Ace', ~2005.12.19, 'ticolor', 'row2')".
          " ('Angel', ~2001.9.19, 'Angel', 'row3')"
      ::
      :+  ~2012.5.2
          %db1
          "FROM my-table WHERE col1 = col2 SELECT *"
      ::
      %-  crip
          "comparing columns of different auras: %col1 type=~.t %col2 type=~.da"
      ==
::
::  WHERE <column> = <literal> joined
++  test-eq-joined-00
  =|  run=@ud
  %-  exec-2-1
  ::%-  debug-2-1
    :*  run
        [~2012.4.30 %sys "CREATE DATABASE db1"]
        ::
        [~2012.5.1 %db1 create-joined-tables]
        ::
        :+  ~2012.5.2
            %db1
            "INSERT INTO my-table".
            " VALUES".
            " ('Abby', ~1999.2.19)".
            " ('Ace', ~2005.12.19)".
            " ('Angel', ~2001.9.19); ".
            "INSERT INTO my-table-2".
            " VALUES".
            " ('Abby', 'tricolor', 'row1')".
            " ('Ace', 'ticolor', 'row2')".
            " ('Angel', 'tuxedo', 'row3')"
        ::
        :+  ~2012.5.3
            %db1
            "FROM my-table T1 JOIN my-table-2 T2 ".
            "WHERE col3 = 'tuxedo' SELECT T1.*, T2.col3, T2.col4"
        ::
        :-  %results
            :~  [%action 'SELECT']
                :-  %result-set
                    :~  :-  %vector
                            :~  [%col1 [~.t 'Angel']]
                                [%col2 [~.da ~2001.9.19]]
                                [%col3 [~.t 'tuxedo']]
                                [%col4 [~.t 'row3']]
                                ==
                        ==
                [%server-time ~2012.5.3]
                [%relation 'db1.dbo.my-table']
                [%schema-time ~2012.5.1]
                [%data-time ~2012.5.2]
                [%relation 'db1.dbo.my-table-2']
                [%schema-time ~2012.5.1]
                [%data-time ~2012.5.2]
                [%vector-count 1]
                ==
        ==
::
::  WHERE <literal> = <column> joined
++  test-eq-joined-01
  =|  run=@ud
  %-  exec-2-1
    :*  run
        [~2012.4.30 %sys "CREATE DATABASE db1"]
        ::
        [~2012.5.1 %db1 create-joined-tables]
        ::
        :+  ~2012.5.2
            %db1
            "INSERT INTO my-table".
            " VALUES".
            " ('Abby', ~1999.2.19)".
            " ('Ace', ~2005.12.19)".
            " ('Angel', ~2001.9.19); ".
            "INSERT INTO my-table-2".
            " VALUES".
            " ('Abby', 'tricolor', 'row1')".
            " ('Ace', 'ticolor', 'row2')".
            " ('Angel', 'tuxedo', 'row3')"
        ::
        :+  ~2012.5.3
            %db1
            "FROM my-table T1 JOIN my-table-2 T2 ".
            "WHERE 'tuxedo' = col3 SELECT T1.*, T2.col3, T2.col4"
        ::
        :-  %results
            :~  [%action 'SELECT']
                :-  %result-set
                    :~  :-  %vector
                            :~  [%col1 [~.t 'Angel']]
                                [%col2 [~.da ~2001.9.19]]
                                [%col3 [~.t 'tuxedo']]
                                [%col4 [~.t 'row3']]
                                ==
                        ==
                [%server-time ~2012.5.3]
                [%relation 'db1.dbo.my-table']
                [%schema-time ~2012.5.1]
                [%data-time ~2012.5.2]
                [%relation 'db1.dbo.my-table-2']
                [%schema-time ~2012.5.1]
                [%data-time ~2012.5.2]
                [%vector-count 1]
                ==
        ==
::
::  WHERE <column> = <column> joined
++  test-eq-joined-02
  =|  run=@ud
  %-  exec-2-1
  :*  run
      [~2012.4.30 %sys "CREATE DATABASE db1"]
      ::
      [~2012.5.1 %db1 create-joined-tables]
      ::
      :+  ~2012.5.2
          %db1
          "INSERT INTO my-table".
          " VALUES".
          " ('Abby', ~1999.2.19)".
          " ('Ace', ~2005.12.19)".
          " ('Angel', ~2001.9.19); ".
          "INSERT INTO my-table-2".
          " VALUES".
          " ('Abby', 'tricolor', 'row1')".
          " ('Ace', 'ticolor', 'row2')".
          " ('Angel', 'Angel', 'row3')"
      ::
      :+  ~2012.5.3
          %db1
          "FROM my-table T1 JOIN my-table-2 T2 ".
          "WHERE T1.col1 = col3 SELECT T1.*, T2.col3, T2.col4"
      ::
      :-  %results
          :~  [%action 'SELECT']
              :-  %result-set
                  :~  :-  %vector
                          :~  [%col1 [~.t 'Angel']]
                              [%col2 [~.da ~2001.9.19]]
                              [%col3 [~.t 'Angel']]
                              [%col4 [~.t 'row3']]
                              ==
                      ==
              [%server-time ~2012.5.3]
              [%relation 'db1.dbo.my-table']
              [%schema-time ~2012.5.1]
              [%data-time ~2012.5.2]
              [%relation 'db1.dbo.my-table-2']
              [%schema-time ~2012.5.1]
              [%data-time ~2012.5.2]
              [%vector-count 1]
              ==
      ==
::
::  view WHERE <column> = <literal> joined
::++  test-eq-joined-03
:: to do: beta2, no natural join, missing index on sys views,
::        this is a partial natural join
  ::=|  run=@ud
  ::=/  expected-rows
  ::      :~
  ::        :-  %vector
  ::            :~  [p=%namespace q=[p=~.tas q=%dbo]]
  ::                [p=%name q=[p=~.tas q=%my-table]]
  ::                [p=%col-ordinal q=[p=~.ud q=3]]
  ::                [p=%col-name q=[p=~.tas q=%col3]]
  ::                [p=%col-type q=[p=~.ta q=116]]
  ::                [p=%key q=[p=~.tas q=%col1]]
  ::                ==
  ::          ==
  ::=/  expected  :~  %results
  ::                  [%action 'SELECT']
  ::                  [%result-set expected-rows]
  ::                  [%server-time ~2012.5.3]
  ::                  [%relation 'db1.sys.columns']
  ::                  [%schema-time ~2012.5.1]
  ::                  [%data-time ~2012.5.1]
  ::                  [%vector-count 1]
  ::              ==
  ::=^  mov1  agent
  ::  %+  ~(on-poke agent (bowl [run ~2012.4.30]))
  ::      %obelisk-action
  ::      !>([%tape2 %sys "CREATE DATABASE db1"])
  ::=.  run  +(run)
  ::=^  mov2  agent
  ::  %+  ~(on-poke agent (bowl [run ~2012.5.1]))
  ::      %obelisk-action
  ::      !>  :+  %tape2
  ::              %db1
  ::              "CREATE TABLE db1..my-table ".
  ::              "(col1 @t, col2 @da, col3 @t, col4 @t) ".
  ::              "PRIMARY KEY (col1)"
  ::=.  run  +(run)
  ::=^  mov3  agent
  ::  %+  ~(on-poke agent (bowl [run ~2012.5.3]))
  ::      %obelisk-action
  ::      !>  :+  %tape2
  ::              %db1
  ::              "FROM sys.columns JOIN sys.table-keys ".
  ::              "WHERE col-name = 'col3' ".
  ::              "SELECT sys.columns.*, sys.table-keys.key"
  ::::
  ::(eval-results expected ;;(cmd-result ->+>+>+<.mov3))
::
::  fail WHERE <column> = <literal> types differ joined
++  test-fail-eq-joined-00
  =|  run=@ud
  %-  failon-3
  :*  run
      [~2012.4.30 %sys "CREATE DATABASE db1"]
      ::
      [~2012.5.1 %db1 create-joined-tables]
      ::
      :+  ~2012.5.2
          %db1
          "INSERT INTO my-table".
          " VALUES".
          " ('Abby', ~1999.2.19)".
          " ('Ace', ~2005.12.19)".
          " ('Angel', ~2001.9.19); ".
          "INSERT INTO my-table-2".
          " VALUES".
          " ('Abby', 'tricolor', 'row1')".
          " ('Ace', 'ticolor', 'row2')".
          " ('Angel', 'Angel', 'row3')"
      ::
      :+  ~2012.5.2
          %db1
          "FROM my-table T1 JOIN my-table-2 T2 ".
          "WHERE t1.col1 = ~1999.2.19 SELECT T1.*, T2.col3, T2.col4"
      ::
      %-  crip
          "comparing column to literal of different aura: %col1 type=~.t ".
          "[p=~.da q=170.141.184.492.111.779.796.175.933.613.172.326.400]"
      ==
::
::  fail WHERE <literal> = <column> types differ joined
++  test-fail-eq-joined-01
  =|  run=@ud
  %-  failon-3
  :*  run
      [~2012.4.30 %sys "CREATE DATABASE db1"]
      ::
      [~2012.5.1 %db1 create-joined-tables]
      ::
      :+  ~2012.5.2
          %db1
          "INSERT INTO my-table".
          " VALUES".
          " ('Abby', ~1999.2.19)".
          " ('Ace', ~2005.12.19)".
          " ('Angel', ~2001.9.19); ".
          "INSERT INTO my-table-2".
          " VALUES".
          " ('Abby', 'tricolor', 'row1')".
          " ('Ace', 'ticolor', 'row2')".
          " ('Angel', 'Angel', 'row3')"
      ::
      :+  ~2012.5.2
          %db1
          "FROM my-table T1 JOIN my-table-2 T2 ".
          "WHERE ~1999.2.19 = t1.col1 SELECT T1.*, T2.col3, T2.col4"
      ::
      %-  crip
          "comparing literal to column of different aura: ".
          "[p=~.da q=170.141.184.492.111.779.796.175.933.613.172.326.400] ".
          "%col1 type=~.t"
      ==
::
::  fail WHERE <column> = <column> types differ joined
++  test-fail-eq-joined-02
  =|  run=@ud
  %-  failon-3
  :*  run
      [~2012.4.30 %sys "CREATE DATABASE db1"]
      ::
      [~2012.5.1 %db1 create-joined-tables]
      ::
      :+  ~2012.5.2
          %db1
          "INSERT INTO my-table".
          " VALUES".
          " ('Abby', ~1999.2.19)".
          " ('Ace', ~2005.12.19)".
          " ('Angel', ~2001.9.19); ".
          "INSERT INTO my-table-2".
          " VALUES".
          " ('Abby', 'tricolor', 'row1')".
          " ('Ace', 'ticolor', 'row2')".
          " ('Angel', 'Angel', 'row3')"
      ::
      :+  ~2012.5.2
          %db1
          "FROM my-table T1 JOIN my-table-2 T2 ".
          "WHERE t1.col1 = col2 SELECT T1.*, T2.col3, T2.col4"
      ::
      %-  crip
          "comparing columns of different auras: ".
          "%col1 type=~.t %col2 type=~.da"
      ==
::
::  NEQ
::
::  WHERE <column> <> <literal>
++  test-neq-00
  =|  run=@ud
  %-  exec-2-1
  :*  run
      [~2012.4.30 %sys "CREATE DATABASE db1"]
      ::
      [~2012.5.1 %db1 create-mytable]
      ::
      :+  ~2012.5.2
          %db1
          "INSERT INTO my-table".
          " VALUES".
          " ('Abby', ~1999.2.19, 'tricolor', 'row1')".
          " ('Ace', ~2005.12.19, 'ticolor', 'row2')".
          " ('Angel', ~2001.9.19, 'tuxedo', 'row3')"
      ::
      :+  ~2012.5.3
          %db1
          "FROM my-table WHERE col3 <> 'tuxedo' SELECT *"
      ::
      :-  %results
          :~  [%action 'SELECT']
              :-  %result-set
                  :~  :-  %vector
                          :~  [%col1 [~.t 'Ace']]
                              [%col2 [~.da ~2005.12.19]]
                              [%col3 [~.t 'ticolor']]
                              [%col4 [~.t 'row2']]
                              ==
                      :-  %vector
                          :~  [%col1 [~.t 'Abby']]
                              [%col2 [~.da ~1999.2.19]]
                              [%col3 [~.t 'tricolor']]
                              [%col4 [~.t 'row1']]
                              ==
                      ==
              [%server-time ~2012.5.3]
              [%relation 'db1.dbo.my-table']
              [%schema-time ~2012.5.1]
              [%data-time ~2012.5.2]
              [%vector-count 2]
              ==
      ==
::
::  WHERE <literal> <> <column>
++  test-neq-01
  =|  run=@ud
  %-  exec-2-1
  :*  run
      [~2012.4.30 %sys "CREATE DATABASE db1"]
      ::
      [~2012.5.1 %db1 create-mytable]
      ::
      :+  ~2012.5.2
          %db1
          "INSERT INTO my-table".
          " VALUES".
          " ('Abby', ~1999.2.19, 'tricolor', 'row1')".
          " ('Ace', ~2005.12.19, 'ticolor', 'row2')".
          " ('Angel', ~2001.9.19, 'tuxedo', 'row3')"
      ::
      :+  ~2012.5.3
          %db1
          "FROM my-table WHERE 'tuxedo' <> col3 SELECT *"
      ::
      :-  %results
          :~  [%action 'SELECT']
              :-  %result-set
                  :~  :-  %vector
                          :~  [%col1 [~.t 'Ace']]
                              [%col2 [~.da ~2005.12.19]]
                              [%col3 [~.t 'ticolor']]
                              [%col4 [~.t 'row2']]
                              ==
                      :-  %vector
                          :~  [%col1 [~.t 'Abby']]
                              [%col2 [~.da ~1999.2.19]]
                              [%col3 [~.t 'tricolor']]
                              [%col4 [~.t 'row1']]
                              ==
                      ==
              [%server-time ~2012.5.3]
              [%relation 'db1.dbo.my-table']
              [%schema-time ~2012.5.1]
              [%data-time ~2012.5.2]
              [%vector-count 2]
              ==
      ==
::
::  WHERE <column> != <column>
++  test-neq-02
  =|  run=@ud
  %-  exec-2-1
  :*  run
      [~2012.4.30 %sys "CREATE DATABASE db1"]
      ::
      [~2012.5.1 %db1 create-mytable]
      ::
      :+  ~2012.5.2
          %db1
          "INSERT INTO my-table".
          " VALUES".
          " ('Abby', ~1999.2.19, 'tricolor', 'row1')".
          " ('Ace', ~2005.12.19, 'ticolor', 'row2')".
          " ('Angel', ~2001.9.19, 'Angel', 'row3')"
      ::
      :+  ~2012.5.3
          %db1
          "FROM my-table WHERE col1 != col3 SELECT *"
      ::
      :-  %results
          :~  [%action 'SELECT']
              :-  %result-set
                  :~  :-  %vector
                          :~  [%col1 [~.t 'Ace']]
                              [%col2 [~.da ~2005.12.19]]
                              [%col3 [~.t 'ticolor']]
                              [%col4 [~.t 'row2']]
                              ==
                      :-  %vector
                          :~  [%col1 [~.t 'Abby']]
                              [%col2 [~.da ~1999.2.19]]
                              [%col3 [~.t 'tricolor']]
                              [%col4 [~.t 'row1']]
                              ==
                      ==
              [%server-time ~2012.5.3]
              [%relation 'db1.dbo.my-table']
              [%schema-time ~2012.5.1]
              [%data-time ~2012.5.2]
              [%vector-count 2]
              ==
      ==
::
::  view WHERE <column> <> <literal>
++  test-neq-03
  =|  run=@ud
  %-  exec-1-1
  :*  run
      [~2012.4.30 %sys "CREATE DATABASE db1"]
      ::
      :+  ~2012.5.1
          %db1
          "CREATE TABLE db1..my-table ".
          "(col1 @t, col2 @da, col3 @t, col4 @t) ".
          "PRIMARY KEY (col3)"
      ::
      :+  ~2012.5.3
          %db1
          "FROM sys.columns WHERE col-name <> 'col3' SELECT *"
      ::
      :-  %results
          :~  [%action 'SELECT']
              :-  %result-set
                  :~  :-  %vector
                          :~  [p=%namespace q=[p=~.tas q=%dbo]]
                              [p=%name q=[p=~.tas q=%my-table]]
                              [p=%col-ordinal q=[p=~.ud q=2]]
                              [p=%col-name q=[p=~.tas q=%col2]]
                              [p=%col-type q=[p=~.ta q=~.da]]
                              ==
                      :-  %vector
                          :~  [p=%namespace q=[p=~.tas q=%dbo]]
                              [p=%name q=[p=~.tas q=%my-table]]
                              [p=%col-ordinal q=[p=~.ud q=1]]
                              [p=%col-name q=[p=~.tas q=%col1]]
                              [p=%col-type q=[p=~.ta q=~.t]]
                              ==
                      :-  %vector
                          :~  [p=%namespace q=[p=~.tas q=%dbo]]
                              [p=%name q=[p=~.tas q=%my-table]]
                              [p=%col-ordinal q=[p=~.ud q=4]]
                              [p=%col-name q=[p=~.tas q=%col4]]
                              [p=%col-type q=[p=~.ta q=~.t]]
                              ==
                      ==
              [%server-time ~2012.5.3]
              [%relation 'db1.sys.columns']
              [%schema-time ~2012.5.1]
              [%data-time ~2012.5.1]
              [%vector-count 3]
              ==
      ==
::
::  view WHERE <literal> <> <column>
++  test-neq-04
  =|  run=@ud
  %-  exec-1-1
  :*  run
      [~2012.4.30 %sys "CREATE DATABASE db1"]
      ::
      [~2012.5.1 %db1 create-mytable]
      ::
      :+  ~2012.5.3
          %db1
          "FROM sys.columns WHERE 'col3' <> col-name SELECT *"
      ::
      :-  %results
          :~  [%action 'SELECT']
              :-  %result-set
                  :~  :-  %vector
                          :~  [p=%namespace q=[p=~.tas q=%dbo]]
                              [p=%name q=[p=~.tas q=%my-table]]
                              [p=%col-ordinal q=[p=~.ud q=2]]
                              [p=%col-name q=[p=~.tas q=%col2]]
                              [p=%col-type q=[p=~.ta q=~.da]]
                              ==
                      :-  %vector
                          :~  [p=%namespace q=[p=~.tas q=%dbo]]
                              [p=%name q=[p=~.tas q=%my-table]]
                              [p=%col-ordinal q=[p=~.ud q=1]]
                              [p=%col-name q=[p=~.tas q=%col1]]
                              [p=%col-type q=[p=~.ta q=~.t]]
                              ==
                      :-  %vector
                          :~  [p=%namespace q=[p=~.tas q=%dbo]]
                              [p=%name q=[p=~.tas q=%my-table]]
                              [p=%col-ordinal q=[p=~.ud q=4]]
                              [p=%col-name q=[p=~.tas q=%col4]]
                              [p=%col-type q=[p=~.ta q=~.t]]
                              ==
                      ==
              [%server-time ~2012.5.3]
              [%relation 'db1.sys.columns']
              [%schema-time ~2012.5.1]
              [%data-time ~2012.5.1]
              [%vector-count 3]
              ==
      ==
::
::  view WHERE <literal> != <literal>
++  test-neq-05
  =|  run=@ud
  %-  exec-1-1
  :*  run
      [~2012.4.30 %sys "CREATE DATABASE db1"]
      ::
      [~2012.5.1 %db1 create-mytable]
      ::
      :+  ~2012.5.3
          %db1
          "FROM sys.columns WHERE 1 != 1 SELECT *"
      ::
      :-  %results
          :~  [%action 'SELECT']
              [%result-set ~]
              [%server-time ~2012.5.3]
              [%relation 'db1.sys.columns']
              [%schema-time ~2012.5.1]
              [%data-time ~2012.5.1]
              [%vector-count 0]
              ==
      ==
::
::  WHERE <column> <> <literal> @rs
++  test-neq-06
  =|  run=@ud
  %-  exec-2-1
  :*  run
      [~2012.4.30 %sys "CREATE DATABASE db1"]
      ::
      [~2012.5.1 %db1 create-rs-table]
      ::
      :+  ~2012.5.2
          %db1
          "INSERT INTO my-table".
          " VALUES".
          " ('row1', .6.02)".
          " ('row2', .3.14)"
      ::
      :+  ~2012.5.3
          %db1
          "FROM my-table WHERE col2 <> .6.02 SELECT *"
      ::
      :-  %results
          :~  [%action 'SELECT']
              :-  %result-set
                  :~  :-  %vector
                          :~  [%col1 [~.t 'row2']]
                              [%col2 [~.rs .3.14]]
                              ==
                      ==
              [%server-time ~2012.5.3]
              [%relation 'db1.dbo.my-table']
              [%schema-time ~2012.5.1]
              [%data-time ~2012.5.2]
              [%vector-count 1]
              ==
      ==
::
::  WHERE <column> <> <literal> @rd
++  test-neq-07
  =|  run=@ud
  %-  exec-2-1
  :*  run
      [~2012.4.30 %sys "CREATE DATABASE db1"]
      ::
      [~2012.5.1 %db1 create-rd-table]
      ::
      :+  ~2012.5.2
          %db1
          "INSERT INTO my-table".
          " VALUES".
          " ('row1', .~6.02)".
          " ('row2', .~3.14)"
      ::
      :+  ~2012.5.3
          %db1
          "FROM my-table WHERE col2 <> .~6.02 SELECT *"
      ::
      :-  %results
          :~  [%action 'SELECT']
              :-  %result-set
                  :~  :-  %vector
                          :~  [%col1 [~.t 'row2']]
                              [%col2 [~.rd .~3.14]]
                              ==
                      ==
              [%server-time ~2012.5.3]
              [%relation 'db1.dbo.my-table']
              [%schema-time ~2012.5.1]
              [%data-time ~2012.5.2]
              [%vector-count 1]
              ==
      ==
::
::  fail WHERE <column> <> <literal> types differ
++  test-fail-neq-00
  =|  run=@ud
  %-  failon-3
  :*  run
      [~2012.4.30 %sys "CREATE DATABASE db1"]
      ::
      [~2012.5.1 %db1 create-mytable]
      ::
      :+  ~2012.5.2
          %db1
          "INSERT INTO my-table".
          " VALUES".
          " ('Abby', ~1999.2.19, 'tricolor', 'row1')".
          " ('Ace', ~2005.12.19, 'ticolor', 'row2')".
          " ('Angel', ~2001.9.19, 'Angel', 'row3')"
      ::
      :+  ~2012.5.2
          %db1
          "FROM my-table WHERE col1 <> ~1999.2.19 SELECT *"
      ::
      %-  crip
          "comparing column to literal of different aura: %col1 type=~.t ".
          "[p=~.da q=170.141.184.492.111.779.796.175.933.613.172.326.400]"
      ==
::
::  fail WHERE <literal> <><column> types differ
++  test-fail-neq-01
  =|  run=@ud
  %-  failon-3
  :*  run
      [~2012.4.30 %sys "CREATE DATABASE db1"]
      ::
      [~2012.5.1 %db1 create-mytable]
      ::
      :+  ~2012.5.2
          %db1
          "INSERT INTO my-table".
          " VALUES".
          " ('Abby', ~1999.2.19, 'tricolor', 'row1')".
          " ('Ace', ~2005.12.19, 'ticolor', 'row2')".
          " ('Angel', ~2001.9.19, 'Angel', 'row3')"
      ::
      :+  ~2012.5.2
          %db1
          "FROM my-table WHERE ~1999.2.19 <> col1 SELECT *"
      ::
      %-  crip
          "comparing literal to column of different aura: ".
          "[p=~.da q=170.141.184.492.111.779.796.175.933.613.172.326.400] ".
          "%col1 type=~.t"
      ==
::
::  fail WHERE <column> <> <column> types differ
++  test-fail-neq-02
  =|  run=@ud
  %-  failon-3
  :*  run
      [~2012.4.30 %sys "CREATE DATABASE db1"]
      ::
      [~2012.5.1 %db1 create-mytable]
      ::
      :+  ~2012.5.2
          %db1
          "INSERT INTO my-table".
          " VALUES".
          " ('Abby', ~1999.2.19, 'tricolor', 'row1')".
          " ('Ace', ~2005.12.19, 'ticolor', 'row2')".
          " ('Angel', ~2001.9.19, 'Angel', 'row3')"
      ::
      :+  ~2012.5.2
          %db1
          "FROM my-table WHERE col1 <> col2 SELECT *"
      ::
      %-  crip
          "comparing columns of different auras: %col1 type=~.t %col2 type=~.da"
      ==
::
::  WHERE <column> <> <literal> joined
++  test-neq-joined-00
  =|  run=@ud
  %-  exec-2-1
  :*  run
      [~2012.4.30 %sys "CREATE DATABASE db1"]
      ::
      [~2012.5.1 %db1 create-joined-tables]
      ::
      :+  ~2012.5.2
          %db1
          "INSERT INTO my-table".
          " VALUES".
          " ('Abby', ~1999.2.19)".
          " ('Ace', ~2005.12.19)".
          " ('Angel', ~2001.9.19); ".
          "INSERT INTO my-table-2".
          " VALUES".
          " ('Abby', 'tricolor', 'row1')".
          " ('Ace', 'ticolor', 'row2')".
          " ('Angel', 'tuxedo', 'row3')"
      ::
      :+  ~2012.5.3
          %db1
          "FROM my-table T1 JOIN my-table-2 T2 ".
          "WHERE col3 <> 'tuxedo' SELECT T1.*, T2.col3, T2.col4"
      ::
      :-  %results
          :~  [%action 'SELECT']
              :-  %result-set
                  :~  :-  %vector
                          :~  [%col1 [~.t 'Ace']]
                              [%col2 [~.da ~2005.12.19]]
                              [%col3 [~.t 'ticolor']]
                              [%col4 [~.t 'row2']]
                              ==
                      :-  %vector
                          :~  [%col1 [~.t 'Abby']]
                              [%col2 [~.da ~1999.2.19]]
                              [%col3 [~.t 'tricolor']]
                              [%col4 [~.t 'row1']]
                              ==
                      ==
              [%server-time ~2012.5.3]
              [%relation 'db1.dbo.my-table']
              [%schema-time ~2012.5.1]
              [%data-time ~2012.5.2]
              [%relation 'db1.dbo.my-table-2']
              [%schema-time ~2012.5.1]
              [%data-time ~2012.5.2]
              [%vector-count 2]
              ==
      ==
::
::  WHERE <literal> <> <column> joined
++  test-neq-joined-01
  =|  run=@ud
  %-  exec-2-1
  :*  run
      [~2012.4.30 %sys "CREATE DATABASE db1"]
      ::
      [~2012.5.1 %db1 create-joined-tables]
      ::
      :+  ~2012.5.2
          %db1
          "INSERT INTO my-table".
          " VALUES".
          " ('Abby', ~1999.2.19)".
          " ('Ace', ~2005.12.19)".
          " ('Angel', ~2001.9.19); ".
          "INSERT INTO my-table-2".
          " VALUES".
          " ('Abby', 'tricolor', 'row1')".
          " ('Ace', 'ticolor', 'row2')".
          " ('Angel', 'tuxedo', 'row3')"
      ::
      :+  ~2012.5.3
          %db1
          "FROM my-table T1 JOIN my-table-2 T2 ".
          "WHERE 'tuxedo' <> col3 SELECT T1.*, T2.col3, T2.col4"
      ::
      :-  %results
          :~  [%action 'SELECT']
              :-  %result-set
                  :~  :-  %vector
                          :~  [%col1 [~.t 'Ace']]
                              [%col2 [~.da ~2005.12.19]]
                              [%col3 [~.t 'ticolor']]
                              [%col4 [~.t 'row2']]
                              ==
                      :-  %vector
                          :~  [%col1 [~.t 'Abby']]
                              [%col2 [~.da ~1999.2.19]]
                              [%col3 [~.t 'tricolor']]
                              [%col4 [~.t 'row1']]
                              ==
                      ==
              [%server-time ~2012.5.3]
              [%relation 'db1.dbo.my-table']
              [%schema-time ~2012.5.1]
              [%data-time ~2012.5.2]
              [%relation 'db1.dbo.my-table-2']
              [%schema-time ~2012.5.1]
              [%data-time ~2012.5.2]
              [%vector-count 2]
              ==
      ==
::
::  WHERE <column> != <column> joined
++  test-neq-joined-02
  =|  run=@ud
  %-  exec-2-1
  :*  run
      [~2012.4.30 %sys "CREATE DATABASE db1"]
      ::
      [~2012.5.1 %db1 create-joined-tables]
      ::
      :+  ~2012.5.2
          %db1
          "INSERT INTO my-table".
          " VALUES".
          " ('Abby', ~1999.2.19)".
          " ('Ace', ~2005.12.19)".
          " ('Angel', ~2001.9.19); ".
          "INSERT INTO my-table-2".
          " VALUES".
          " ('Abby', 'tricolor', 'row1')".
          " ('Ace', 'ticolor', 'row2')".
          " ('Angel', 'Angel', 'row3')"
      ::
      :+  ~2012.5.3
          %db1
          "FROM my-table T1 JOIN my-table-2 T2 ".
          "WHERE t1.col1 != col3 SELECT T1.*, T2.col3, T2.col4"
      ::
      :-  %results
          :~  [%action 'SELECT']
              :-  %result-set
                  :~  :-  %vector
                          :~  [%col1 [~.t 'Ace']]
                              [%col2 [~.da ~2005.12.19]]
                              [%col3 [~.t 'ticolor']]
                              [%col4 [~.t 'row2']]
                              ==
                      :-  %vector
                          :~  [%col1 [~.t 'Abby']]
                              [%col2 [~.da ~1999.2.19]]
                              [%col3 [~.t 'tricolor']]
                              [%col4 [~.t 'row1']]
                              ==
                      ==
              [%server-time ~2012.5.3]
              [%relation 'db1.dbo.my-table']
              [%schema-time ~2012.5.1]
              [%data-time ~2012.5.2]
              [%relation 'db1.dbo.my-table-2']
              [%schema-time ~2012.5.1]
              [%data-time ~2012.5.2]
              [%vector-count 2]
              ==
      ==
::
++  test-fail-neq-joined-00
  =|  run=@ud
  %-  failon-3
  :*  run
      [~2012.4.30 %sys "CREATE DATABASE db1"]
      ::
      [~2012.5.1 %db1 create-joined-tables]
      ::
      :+  ~2012.5.2
          %db1
          "INSERT INTO my-table".
          " VALUES".
          " ('Abby', ~1999.2.19)".
          " ('Ace', ~2005.12.19)".
          " ('Angel', ~2001.9.19); ".
          "INSERT INTO my-table-2".
          " VALUES".
          " ('Abby', 'tricolor', 'row1')".
          " ('Ace', 'ticolor', 'row2')".
          " ('Angel', 'Angel', 'row3')"
      ::
      :+  ~2012.5.2
          %db1
          "FROM my-table T1 JOIN my-table-2 T2 ".
          "WHERE t1.col1 <> ~1999.2.19 SELECT T1.*, T2.col3, T2.col4"
      ::
      %-  crip
          "comparing column to literal of different aura: %col1 type=~.t ".
          "[p=~.da q=170.141.184.492.111.779.796.175.933.613.172.326.400]"
      ==
::
::  fail WHERE <literal> <><column> types differ joined
++  test-fail-neq-joined-01
  =|  run=@ud
  %-  failon-3
  :*  run
      [~2012.4.30 %sys "CREATE DATABASE db1"]
      ::
      [~2012.5.1 %db1 create-joined-tables]
      ::
      :+  ~2012.5.2
          %db1
          "INSERT INTO my-table".
          " VALUES".
          " ('Abby', ~1999.2.19)".
          " ('Ace', ~2005.12.19)".
          " ('Angel', ~2001.9.19); ".
          "INSERT INTO my-table-2".
          " VALUES".
          " ('Abby', 'tricolor', 'row1')".
          " ('Ace', 'ticolor', 'row2')".
          " ('Angel', 'Angel', 'row3')"
      ::
      :+  ~2012.5.2
          %db1
          "FROM my-table T1 JOIN my-table-2 T2 ".
          "WHERE ~1999.2.19 <> t1.col1 SELECT T1.*, T2.col3, T2.col4"
      ::
      %-  crip
          "comparing literal to column of different aura: ".
          "[p=~.da q=170.141.184.492.111.779.796.175.933.613.172.326.400] ".
          "%col1 type=~.t"
      ==
::
::  fail WHERE <column> <> <column> types differ joined
++  test-fail-neq-joined-02
  =|  run=@ud
  %-  failon-3
  :*  run
      [~2012.4.30 %sys "CREATE DATABASE db1"]
      ::
      [~2012.5.1 %db1 create-joined-tables]
      ::
      :+  ~2012.5.2
          %db1
          "INSERT INTO my-table".
          " VALUES".
          " ('Abby', ~1999.2.19)".
          " ('Ace', ~2005.12.19)".
          " ('Angel', ~2001.9.19); ".
          "INSERT INTO my-table-2".
          " VALUES".
          " ('Abby', 'tricolor', 'row1')".
          " ('Ace', 'ticolor', 'row2')".
          " ('Angel', 'Angel', 'row3')"
      ::
      :+  ~2012.5.2
          %db1
          "FROM my-table T1 JOIN my-table-2 T2 ".
          "WHERE t1.col1 <> col2 SELECT T1.*, T2.col3, T2.col4"
      ::
      %-  crip
          "comparing columns of different auras: %col1 type=~.t %col2 type=~.da"
      ==
::
::  GT
::
::  WHERE <column> > <literal> (cord)
++  test-gt-00
  =|  run=@ud
  %-  exec-2-1
  :*  run
      [~2012.4.30 %sys "CREATE DATABASE db1"]
      ::
      [~2012.5.1 %db1 create-mytable]
      ::
      :+  ~2012.5.2
          %db1
          "INSERT INTO my-table".
          " VALUES".
          " ('Abby', ~1999.2.19, 'tricolor', 'row1')".
          " ('Ace', ~2005.12.19, 'ticolor', 'row2')".
          " ('Angel', ~2001.9.19, 'tuxedo', 'row3')"
      ::
      :+  ~2012.5.3
          %db1
          "FROM my-table WHERE col3 > 'toledo' SELECT *"
      ::
      :-  %results
          :~  [%action 'SELECT']
              :-  %result-set
                  :~  :-  %vector
                          :~  [%col1 [~.t 'Angel']]
                              [%col2 [~.da ~2001.9.19]]
                              [%col3 [~.t 'tuxedo']]
                              [%col4 [~.t 'row3']]
                              ==
                      :-  %vector
                          :~  [%col1 [~.t 'Abby']]
                              [%col2 [~.da ~1999.2.19]]
                              [%col3 [~.t 'tricolor']]
                              [%col4 [~.t 'row1']]
                              ==
                      ==
              [%server-time ~2012.5.3]
              [%relation 'db1.dbo.my-table']
              [%schema-time ~2012.5.1]
              [%data-time ~2012.5.2]
              [%vector-count 2]
              ==
      ==
::
::  WHERE <column> > <literal> (@da)
++  test-gt-01
  =|  run=@ud
  %-  exec-2-1
  :*  run
      [~2012.4.30 %sys "CREATE DATABASE db1"]
      ::
      [~2012.5.1 %db1 create-mytable]
      ::
      :+  ~2012.5.2
          %db1
          "INSERT INTO my-table".
          " VALUES".
          " ('Abby', ~1999.2.19, 'tricolor', 'row1')".
          " ('Ace', ~2005.12.19, 'ticolor', 'row2')".
          " ('Angel', ~2001.9.19, 'tuxedo', 'row3')"
      ::
      :+  ~2012.5.3
          %db1
          "FROM my-table WHERE col2 > ~1999.2.19 SELECT *"
      ::
      :-  %results
          :~  [%action 'SELECT']
              :-  %result-set
                  :~  :-  %vector
                          :~  [%col1 [~.t 'Ace']]
                              [%col2 [~.da ~2005.12.19]]
                              [%col3 [~.t 'ticolor']]
                              [%col4 [~.t 'row2']]
                              ==
                      :-  %vector
                          :~  [%col1 [~.t 'Angel']]
                              [%col2 [~.da ~2001.9.19]]
                              [%col3 [~.t 'tuxedo']]
                              [%col4 [~.t 'row3']]
                              ==
                      ==
              [%server-time ~2012.5.3]
              [%relation 'db1.dbo.my-table']
              [%schema-time ~2012.5.1]
              [%data-time ~2012.5.2]
              [%vector-count 2]
              ==
      ==
::
::  WHERE <literal> > <column>  (cord)
++  test-gt-02
  =|  run=@ud
  %-  exec-2-1
  :*  run
      [~2012.4.30 %sys "CREATE DATABASE db1"]
      ::
      [~2012.5.1 %db1 create-mytable]
      ::
      :+  ~2012.5.2
          %db1
          "INSERT INTO my-table".
          " VALUES".
          " ('Abby', ~1999.2.19, 'tricolor', 'row1')".
          " ('Ace', ~2005.12.19, 'ticolor', 'row2')".
          " ('Angel', ~2001.9.19, 'tuxedo', 'row3')"
      ::
      :+  ~2012.5.3
          %db1
          "FROM my-table WHERE 'tricolor' > col3 SELECT *"
      ::
      :-  %results
          :~  [%action 'SELECT']
              :-  %result-set
                  :~  :-  %vector
                          :~  [%col1 [~.t 'Ace']]
                              [%col2 [~.da ~2005.12.19]]
                              [%col3 [~.t 'ticolor']]
                              [%col4 [~.t 'row2']]
                              ==
                      ==
              [%server-time ~2012.5.3]
              [%relation 'db1.dbo.my-table']
              [%schema-time ~2012.5.1]
              [%data-time ~2012.5.2]
              [%vector-count 1]
              ==
      ==
::
::  WHERE <column> > <column>  (cord)
++  test-gt-03
  =|  run=@ud
  %-  exec-2-1
  :*  run
      [~2012.4.30 %sys "CREATE DATABASE db1"]
      ::
      [~2012.5.1 %db1 create-mytable]
      ::
      :+  ~2012.5.2
          %db1
          "INSERT INTO my-table".
          " VALUES".
          " ('Abby', ~1999.2.19, 'tricolor', 'row1')".
          " ('Ace', ~2005.12.19, 'ticolor', 'row2')".
          " ('Angel', ~2001.9.19, 'Angel', 'row3')"
      ::
      :+  ~2012.5.3
          %db1
          "FROM my-table WHERE col3 > col1 SELECT *"
      ::
      :-  %results
          :~  [%action 'SELECT']
              :-  %result-set
                  :~  :-  %vector
                          :~  [%col1 [~.t 'Ace']]
                              [%col2 [~.da ~2005.12.19]]
                              [%col3 [~.t 'ticolor']]
                              [%col4 [~.t 'row2']]
                              ==
                      :-  %vector
                          :~  [%col1 [~.t 'Abby']]
                              [%col2 [~.da ~1999.2.19]]
                              [%col3 [~.t 'tricolor']]
                              [%col4 [~.t 'row1']]
                              ==
                      ==
              [%server-time ~2012.5.3]
              [%relation 'db1.dbo.my-table']
              [%schema-time ~2012.5.1]
              [%data-time ~2012.5.2]
              [%vector-count 2]
              ==
      ==
::
::  WHERE <column> > <literal> (cord)
++  test-gt-04
  =|  run=@ud
  %-  exec-2-1
  :*  run
      [~2012.4.30 %sys "CREATE DATABASE db1"]
      ::
      :+  ~2012.5.1
          %db1
          "CREATE TABLE db1..my-table ".
          "(col1 @t, col2 @da, col3 @t, col4 @t) ".
          "PRIMARY KEY (col3)"
      ::
      :+  ~2012.5.2
          %db1
          "INSERT INTO my-table".
          " VALUES".
          " ('Abby', ~1999.2.19, 'tricolor', 'row1')".
          " ('Ace', ~2005.12.19, 'ticolor', 'row2')".
          " ('Angel', ~2001.9.19, 'tuxedo', 'row3')"
      ::
      :+  ~2012.5.3
          %db1
          "FROM my-table WHERE col1 > 'Abbz' SELECT *"
      ::
      :-  %results
          :~  [%action 'SELECT']
              :-  %result-set
                  :~  :-  %vector
                          :~  [%col1 [~.t 'Ace']]
                              [%col2 [~.da ~2005.12.19]]
                              [%col3 [~.t 'ticolor']]
                              [%col4 [~.t 'row2']]
                              ==
                      :-  %vector
                          :~  [%col1 [~.t 'Angel']]
                              [%col2 [~.da ~2001.9.19]]
                              [%col3 [~.t 'tuxedo']]
                              [%col4 [~.t 'row3']]
                              ==
                      ==
              [%server-time ~2012.5.3]
              [%relation 'db1.dbo.my-table']
              [%schema-time ~2012.5.1]
              [%data-time ~2012.5.2]
              [%vector-count 2]
              ==
      ==
::
::  view WHERE <column> > <literal>
++  test-gt-05
  =|  run=@ud
  %-  exec-1-1
  :*  run
      [~2012.4.30 %sys "CREATE DATABASE db1"]
      ::
      [~2012.5.1 %db1 create-mytable]
      ::
      :+  ~2012.5.3
          %db1
          "FROM sys.columns WHERE 'col3' > col-name SELECT *"
      ::
      :-  %results
          :~  [%action 'SELECT']
              :-  %result-set
                  :~  :-  %vector
                          :~  [p=%namespace q=[p=~.tas q=%dbo]]
                              [p=%name q=[p=~.tas q=%my-table]]
                              [p=%col-ordinal q=[p=~.ud q=2]]
                              [p=%col-name q=[p=~.tas q=%col2]]
                              [p=%col-type q=[p=~.ta q=~.da]]
                              ==
                      :-  %vector
                          :~  [p=%namespace q=[p=~.tas q=%dbo]]
                              [p=%name q=[p=~.tas q=%my-table]]
                              [p=%col-ordinal q=[p=~.ud q=1]]
                              [p=%col-name q=[p=~.tas q=%col1]]
                              [p=%col-type q=[p=~.ta q=~.t]]
                              ==
                      ==
              [%server-time ~2012.5.3]
              [%relation 'db1.sys.columns']
              [%schema-time ~2012.5.1]
              [%data-time ~2012.5.1]
              [%vector-count 2]
              ==
      ==
::
::  view WHERE <literal> > <literal>
++  test-gt-06
  =|  run=@ud
  %-  exec-1-1
  :*  run
      [~2012.4.30 %sys "CREATE DATABASE db1"]
      ::
      [~2012.5.1 %db1 create-mytable]
      ::
      :+  ~2012.5.3
          %db1
          "FROM sys.columns WHERE 2 > 1 SELECT *"
      ::
      :-  %results
          :~  [%action 'SELECT']
              :-  %result-set
                  :~  :-  %vector
                          :~  [p=%namespace q=[p=~.tas q=%dbo]]
                              [p=%name q=[p=~.tas q=%my-table]]
                              [p=%col-ordinal q=[p=~.ud q=2]]
                              [p=%col-name q=[p=~.tas q=%col2]]
                              [p=%col-type q=[p=~.ta q=~.da]]
                              ==
                      :-  %vector
                          :~  [p=%namespace q=[p=~.tas q=%dbo]]
                              [p=%name q=[p=~.tas q=%my-table]]
                              [p=%col-ordinal q=[p=~.ud q=1]]
                              [p=%col-name q=[p=~.tas q=%col1]]
                              [p=%col-type q=[p=~.ta q=~.t]]
                              ==
                      :-  %vector
                          :~  [p=%namespace q=[p=~.tas q=%dbo]]
                              [p=%name q=[p=~.tas q=%my-table]]
                              [p=%col-ordinal q=[p=~.ud q=4]]
                              [p=%col-name q=[p=~.tas q=%col4]]
                              [p=%col-type q=[p=~.ta q=~.t]]
                              ==
                      :-  %vector
                          :~  [p=%namespace q=[p=~.tas q=%dbo]]
                              [p=%name q=[p=~.tas q=%my-table]]
                              [p=%col-ordinal q=[p=~.ud q=3]]
                              [p=%col-name q=[p=~.tas q=%col3]]
                              [p=%col-type q=[p=~.ta q=~.t]]
                              ==
                      ==
              [%server-time ~2012.5.3]
              [%relation 'db1.sys.columns']
              [%schema-time ~2012.5.1]
              [%data-time ~2012.5.1]
              [%vector-count 4]
              ==
      ==
::
::  WHERE <literal> > <literal> @rd neg-pos (false)
++  test-gt-07
  =|  run=@ud
  %-  exec-2-1
  :*  run
      [~2012.4.30 %sys "CREATE DATABASE db1"]
      ::
      [~2012.5.1 %db1 create-rd-table]
      ::
      :+  ~2012.5.2
          %db1
          "INSERT INTO my-table".
          " VALUES".
          " ('row1', .~3.14)"
      ::
      :+  ~2012.5.3
          %db1
          "FROM my-table WHERE .~-3.14 > .~3.14 SELECT *"
      ::
      :-  %results
          :~  [%action 'SELECT']
              [%result-set ~]
              [%server-time ~2012.5.3]
              [%relation 'db1.dbo.my-table']
              [%schema-time ~2012.5.1]
              [%data-time ~2012.5.2]
              [%vector-count 0]
              ==
      ==
::
::  WHERE <literal> > <literal> @rd pos-neg (true)
++  test-gt-08
  =|  run=@ud
  %-  exec-2-1
  :*  run
      [~2012.4.30 %sys "CREATE DATABASE db1"]
      ::
      [~2012.5.1 %db1 create-rd-table]
      ::
      :+  ~2012.5.2
          %db1
          "INSERT INTO my-table".
          " VALUES".
          " ('row1', .~3.14)"
      ::
      :+  ~2012.5.3
          %db1
          "FROM my-table WHERE .~3.14 > .~-3.14 SELECT *"
      ::
      :-  %results
          :~  [%action 'SELECT']
              :-  %result-set
                  :~  :-  %vector
                          :~  [%col1 [~.t 'row1']]
                              [%col2 [~.rd .~3.14]]
                              ==
                      ==
              [%server-time ~2012.5.3]
              [%relation 'db1.dbo.my-table']
              [%schema-time ~2012.5.1]
              [%data-time ~2012.5.2]
              [%vector-count 1]
              ==
      ==
::
::  WHERE <literal> > <literal> @rd pos-pos (true)
++  test-gt-09
  =|  run=@ud
  %-  exec-2-1
  :*  run
      [~2012.4.30 %sys "CREATE DATABASE db1"]
      ::
      [~2012.5.1 %db1 create-rd-table]
      ::
      :+  ~2012.5.2
          %db1
          "INSERT INTO my-table".
          " VALUES".
          " ('row1', .~3.14)"
      ::
      :+  ~2012.5.3
          %db1
          "FROM my-table WHERE .~6.02 > .~3.14 SELECT *"
      ::
      :-  %results
          :~  [%action 'SELECT']
              :-  %result-set
                  :~  :-  %vector
                          :~  [%col1 [~.t 'row1']]
                              [%col2 [~.rd .~3.14]]
                              ==
                      ==
              [%server-time ~2012.5.3]
              [%relation 'db1.dbo.my-table']
              [%schema-time ~2012.5.1]
              [%data-time ~2012.5.2]
              [%vector-count 1]
              ==
      ==
::
::  WHERE <literal> > <literal> @rd neg-neg (false)
++  test-gt-10
  =|  run=@ud
  %-  exec-2-1
  :*  run
      [~2012.4.30 %sys "CREATE DATABASE db1"]
      ::
      [~2012.5.1 %db1 create-rd-table]
      ::
      :+  ~2012.5.2
          %db1
          "INSERT INTO my-table".
          " VALUES".
          " ('row1', .~3.14)"
      ::
      :+  ~2012.5.3
          %db1
          "FROM my-table WHERE .~-6.02 > .~-3.14 SELECT *"
      ::
      :-  %results
          :~  [%action 'SELECT']
              [%result-set ~]
              [%server-time ~2012.5.3]
              [%relation 'db1.dbo.my-table']
              [%schema-time ~2012.5.1]
              [%data-time ~2012.5.2]
              [%vector-count 0]
              ==
      ==
::
::  WHERE <column> > <literal> @rd neg-pos (false)
++  test-gt-11
  =|  run=@ud
  %-  exec-2-1
  :*  run
      [~2012.4.30 %sys "CREATE DATABASE db1"]
      ::
      [~2012.5.1 %db1 create-rd-table]
      ::
      :+  ~2012.5.2
          %db1
          "INSERT INTO my-table".
          " VALUES".
          " ('row1', .~-3.14)".
          " ('row2', .~-6.02)"
      ::
      :+  ~2012.5.3
          %db1
          "FROM my-table WHERE col2 > .~3.14 SELECT *"
      ::
      :-  %results
          :~  [%action 'SELECT']
              [%result-set ~]
              [%server-time ~2012.5.3]
              [%relation 'db1.dbo.my-table']
              [%schema-time ~2012.5.1]
              [%data-time ~2012.5.2]
              [%vector-count 0]
              ==
      ==
::
::  WHERE <column> > <literal> @rd pos-neg (true)
++  test-gt-12
  =|  run=@ud
  %-  exec-2-1
  :*  run
      [~2012.4.30 %sys "CREATE DATABASE db1"]
      ::
      [~2012.5.1 %db1 create-rd-table]
      ::
      :+  ~2012.5.2
          %db1
          "INSERT INTO my-table".
          " VALUES".
          " ('row1', .~3.14)".
          " ('row2', .~6.02)"
      ::
      :+  ~2012.5.3
          %db1
          "FROM my-table WHERE col2 > .~-3.14 SELECT *"
      ::
      :-  %results
          :~  [%action 'SELECT']
              :-  %result-set
                  :~  :-  %vector
                          :~  [%col1 [~.t 'row1']]
                              [%col2 [~.rd .~3.14]]
                              ==
                      :-  %vector
                          :~  [%col1 [~.t 'row2']]
                              [%col2 [~.rd .~6.02]]
                              ==
                      ==
              [%server-time ~2012.5.3]
              [%relation 'db1.dbo.my-table']
              [%schema-time ~2012.5.1]
              [%data-time ~2012.5.2]
              [%vector-count 2]
              ==
      ==
::
::  WHERE <column> > <literal> @rd pos-pos (true and false)
++  test-gt-13
  =|  run=@ud
  %-  exec-2-1
  :*  run
      [~2012.4.30 %sys "CREATE DATABASE db1"]
      ::
      [~2012.5.1 %db1 create-rd-table]
      ::
      :+  ~2012.5.2
          %db1
          "INSERT INTO my-table".
          " VALUES".
          " ('row1', .~6.02)".
          " ('row2', .~3.14)"
      ::
      :+  ~2012.5.3
          %db1
          "FROM my-table WHERE col2 > .~5.0 SELECT *"
      ::
      :-  %results
          :~  [%action 'SELECT']
              :-  %result-set
                  :~  :-  %vector
                          :~  [%col1 [~.t 'row1']]
                              [%col2 [~.rd .~6.02]]
                              ==
                      ==
              [%server-time ~2012.5.3]
              [%relation 'db1.dbo.my-table']
              [%schema-time ~2012.5.1]
              [%data-time ~2012.5.2]
              [%vector-count 1]
              ==
      ==
::
::  WHERE <column> > <literal> @rd neg-neg (true and false)
++  test-gt-14
  =|  run=@ud
  %-  exec-2-1
  :*  run
      [~2012.4.30 %sys "CREATE DATABASE db1"]
      ::
      [~2012.5.1 %db1 create-rd-table]
      ::
      :+  ~2012.5.2
          %db1
          "INSERT INTO my-table".
          " VALUES".
          " ('row1', .~-3.14)".
          " ('row2', .~-6.02)"
      ::
      :+  ~2012.5.3
          %db1
          "FROM my-table WHERE col2 > .~-5.0 SELECT *"
      ::
      :-  %results
          :~  [%action 'SELECT']
              :-  %result-set
                  :~  :-  %vector
                          :~  [%col1 [~.t 'row1']]
                              [%col2 [~.rd .~-3.14]]
                              ==
                      ==
              [%server-time ~2012.5.3]
              [%relation 'db1.dbo.my-table']
              [%schema-time ~2012.5.1]
              [%data-time ~2012.5.2]
              [%vector-count 1]
              ==
      ==
::
::  WHERE <literal> > <column> @rd neg-pos (false)
++  test-gt-15
  =|  run=@ud
  %-  exec-2-1
  :*  run
      [~2012.4.30 %sys "CREATE DATABASE db1"]
      ::
      [~2012.5.1 %db1 create-rd-table]
      ::
      :+  ~2012.5.2
          %db1
          "INSERT INTO my-table".
          " VALUES".
          " ('row1', .~3.14)".
          " ('row2', .~6.02)"
      ::
      :+  ~2012.5.3
          %db1
          "FROM my-table WHERE .~-3.14 > col2 SELECT *"
      ::
      :-  %results
          :~  [%action 'SELECT']
              [%result-set ~]
              [%server-time ~2012.5.3]
              [%relation 'db1.dbo.my-table']
              [%schema-time ~2012.5.1]
              [%data-time ~2012.5.2]
              [%vector-count 0]
              ==
      ==
::
::  WHERE <literal> > <column> @rd pos-neg (true)
++  test-gt-16
  =|  run=@ud
  %-  exec-2-1
  :*  run
      [~2012.4.30 %sys "CREATE DATABASE db1"]
      ::
      [~2012.5.1 %db1 create-rd-table]
      ::
      :+  ~2012.5.2
          %db1
          "INSERT INTO my-table".
          " VALUES".
          " ('row1', .~-3.14)".
          " ('row2', .~-6.02)"
      ::
      :+  ~2012.5.3
          %db1
          "FROM my-table WHERE .~3.14 > col2 SELECT *"
      ::
      :-  %results
          :~  [%action 'SELECT']
              :-  %result-set
                  :~  :-  %vector
                          :~  [%col1 [~.t 'row1']]
                              [%col2 [~.rd .~-3.14]]
                              ==
                      :-  %vector
                          :~  [%col1 [~.t 'row2']]
                              [%col2 [~.rd .~-6.02]]
                              ==
                      ==
              [%server-time ~2012.5.3]
              [%relation 'db1.dbo.my-table']
              [%schema-time ~2012.5.1]
              [%data-time ~2012.5.2]
              [%vector-count 2]
              ==
      ==
::
::  WHERE <literal> > <column> @rd pos-pos (true and false)
++  test-gt-17
  =|  run=@ud
  %-  exec-2-1
  :*  run
      [~2012.4.30 %sys "CREATE DATABASE db1"]
      ::
      [~2012.5.1 %db1 create-rd-table]
      ::
      :+  ~2012.5.2
          %db1
          "INSERT INTO my-table".
          " VALUES".
          " ('row1', .~6.02)".
          " ('row2', .~3.14)"
      ::
      :+  ~2012.5.3
          %db1
          "FROM my-table WHERE .~5.0 > col2 SELECT *"
      ::
      :-  %results
          :~  [%action 'SELECT']
              :-  %result-set
                  :~  :-  %vector
                          :~  [%col1 [~.t 'row2']]
                              [%col2 [~.rd .~3.14]]
                              ==
                      ==
              [%server-time ~2012.5.3]
              [%relation 'db1.dbo.my-table']
              [%schema-time ~2012.5.1]
              [%data-time ~2012.5.2]
              [%vector-count 1]
              ==
      ==
::
::  WHERE <literal> > <column> @rd neg-neg (true and false)
++  test-gt-18
  =|  run=@ud
  %-  exec-2-1
  :*  run
      [~2012.4.30 %sys "CREATE DATABASE db1"]
      ::
      [~2012.5.1 %db1 create-rd-table]
      ::
      :+  ~2012.5.2
          %db1
          "INSERT INTO my-table".
          " VALUES".
          " ('row1', .~-3.14)".
          " ('row2', .~-6.02)"
      ::
      :+  ~2012.5.3
          %db1
          "FROM my-table WHERE .~-5.0 > col2 SELECT *"
      ::
      :-  %results
          :~  [%action 'SELECT']
              :-  %result-set
                  :~  :-  %vector
                          :~  [%col1 [~.t 'row2']]
                              [%col2 [~.rd .~-6.02]]
                              ==
                      ==
              [%server-time ~2012.5.3]
              [%relation 'db1.dbo.my-table']
              [%schema-time ~2012.5.1]
              [%data-time ~2012.5.2]
              [%vector-count 1]
              ==
      ==
::
::  WHERE <column> > <column> @rd neg-pos (false)
++  test-gt-19
  =|  run=@ud
  %-  exec-2-1
  :*  run
      [~2012.4.30 %sys "CREATE DATABASE db1"]
      ::
      [~2012.5.1 %db1 create-rd-2col-table]
      ::
      :+  ~2012.5.2
          %db1
          "INSERT INTO my-table".
          " VALUES".
          " ('row1', .~-3.14, .~3.14)"
      ::
      :+  ~2012.5.3
          %db1
          "FROM my-table WHERE col2 > col3 SELECT *"
      ::
      :-  %results
          :~  [%action 'SELECT']
              [%result-set ~]
              [%server-time ~2012.5.3]
              [%relation 'db1.dbo.my-table']
              [%schema-time ~2012.5.1]
              [%data-time ~2012.5.2]
              [%vector-count 0]
              ==
      ==
::
::  WHERE <column> > <column> @rd pos-neg (true)
++  test-gt-20
  =|  run=@ud
  %-  exec-2-1
  :*  run
      [~2012.4.30 %sys "CREATE DATABASE db1"]
      ::
      [~2012.5.1 %db1 create-rd-2col-table]
      ::
      :+  ~2012.5.2
          %db1
          "INSERT INTO my-table".
          " VALUES".
          " ('row1', .~3.14, .~-3.14)"
      ::
      :+  ~2012.5.3
          %db1
          "FROM my-table WHERE col2 > col3 SELECT *"
      ::
      :-  %results
          :~  [%action 'SELECT']
              :-  %result-set
                  :~  :-  %vector
                          :~  [%col1 [~.t 'row1']]
                              [%col2 [~.rd .~3.14]]
                              [%col3 [~.rd .~-3.14]]
                              ==
                      ==
              [%server-time ~2012.5.3]
              [%relation 'db1.dbo.my-table']
              [%schema-time ~2012.5.1]
              [%data-time ~2012.5.2]
              [%vector-count 1]
              ==
      ==
::
::  WHERE <column> > <column> @rd pos-pos (true and false)
++  test-gt-21
  =|  run=@ud
  %-  exec-2-1
  :*  run
      [~2012.4.30 %sys "CREATE DATABASE db1"]
      ::
      [~2012.5.1 %db1 create-rd-2col-table]
      ::
      :+  ~2012.5.2
          %db1
          "INSERT INTO my-table".
          " VALUES".
          " ('row1', .~6.02, .~3.14)".
          " ('row2', .~3.14, .~6.02)"
      ::
      :+  ~2012.5.3
          %db1
          "FROM my-table WHERE col2 > col3 SELECT *"
      ::
      :-  %results
          :~  [%action 'SELECT']
              :-  %result-set
                  :~  :-  %vector
                          :~  [%col1 [~.t 'row1']]
                              [%col2 [~.rd .~6.02]]
                              [%col3 [~.rd .~3.14]]
                              ==
                      ==
              [%server-time ~2012.5.3]
              [%relation 'db1.dbo.my-table']
              [%schema-time ~2012.5.1]
              [%data-time ~2012.5.2]
              [%vector-count 1]
              ==
      ==
::
::  WHERE <column> > <column> @rd neg-neg (true and false)
++  test-gt-22
  =|  run=@ud
  %-  exec-2-1
  :*  run
      [~2012.4.30 %sys "CREATE DATABASE db1"]
      ::
      [~2012.5.1 %db1 create-rd-2col-table]
      ::
      :+  ~2012.5.2
          %db1
          "INSERT INTO my-table".
          " VALUES".
          " ('row1', .~-3.14, .~-6.02)".
          " ('row2', .~-6.02, .~-3.14)"
      ::
      :+  ~2012.5.3
          %db1
          "FROM my-table WHERE col2 > col3 SELECT *"
      ::
      :-  %results
          :~  [%action 'SELECT']
              :-  %result-set
                  :~  :-  %vector
                          :~  [%col1 [~.t 'row1']]
                              [%col2 [~.rd .~-3.14]]
                              [%col3 [~.rd .~-6.02]]
                              ==
                      ==
              [%server-time ~2012.5.3]
              [%relation 'db1.dbo.my-table']
              [%schema-time ~2012.5.1]
              [%data-time ~2012.5.2]
              [%vector-count 1]
              ==
      ==
::
::  WHERE <literal> > <literal> @sd neg-pos (false)
++  test-gt-23
  =|  run=@ud
  %-  exec-2-1
  :*  run
      [~2012.4.30 %sys "CREATE DATABASE db1"]
      ::
      [~2012.5.1 %db1 create-sd-table]
      ::
      :+  ~2012.5.2
          %db1
          "INSERT INTO my-table".
          " VALUES".
          " ('row1', --6)"
      ::
      :+  ~2012.5.3
          %db1
          "FROM my-table WHERE -3 > --3 SELECT *"
      ::
      :-  %results
          :~  [%action 'SELECT']
              [%result-set ~]
              [%server-time ~2012.5.3]
              [%relation 'db1.dbo.my-table']
              [%schema-time ~2012.5.1]
              [%data-time ~2012.5.2]
              [%vector-count 0]
              ==
      ==
::
::  WHERE <literal> > <literal> @sd pos-neg (true)
++  test-gt-24
  =|  run=@ud
  %-  exec-2-1
  :*  run
      [~2012.4.30 %sys "CREATE DATABASE db1"]
      ::
      [~2012.5.1 %db1 create-sd-table]
      ::
      :+  ~2012.5.2
          %db1
          "INSERT INTO my-table".
          " VALUES".
          " ('row1', --6)"
      ::
      :+  ~2012.5.3
          %db1
          "FROM my-table WHERE --3 > -3 SELECT *"
      ::
      :-  %results
          :~  [%action 'SELECT']
              :-  %result-set
                  :~  :-  %vector
                          :~  [%col1 [~.t 'row1']]
                              [%col2 [~.sd --6]]
                              ==
                      ==
              [%server-time ~2012.5.3]
              [%relation 'db1.dbo.my-table']
              [%schema-time ~2012.5.1]
              [%data-time ~2012.5.2]
              [%vector-count 1]
              ==
      ==
::
::  WHERE <literal> > <literal> @sd pos-pos (true)
++  test-gt-25
  =|  run=@ud
  %-  exec-2-1
  :*  run
      [~2012.4.30 %sys "CREATE DATABASE db1"]
      ::
      [~2012.5.1 %db1 create-sd-table]
      ::
      :+  ~2012.5.2
          %db1
          "INSERT INTO my-table".
          " VALUES".
          " ('row1', --6)"
      ::
      :+  ~2012.5.3
          %db1
          "FROM my-table WHERE --6 > --3 SELECT *"
      ::
      :-  %results
          :~  [%action 'SELECT']
              :-  %result-set
                  :~  :-  %vector
                          :~  [%col1 [~.t 'row1']]
                              [%col2 [~.sd --6]]
                              ==
                      ==
              [%server-time ~2012.5.3]
              [%relation 'db1.dbo.my-table']
              [%schema-time ~2012.5.1]
              [%data-time ~2012.5.2]
              [%vector-count 1]
              ==
      ==
::
::  WHERE <literal> > <literal> @sd neg-neg (false)
++  test-gt-26
  =|  run=@ud
  %-  exec-2-1
  :*  run
      [~2012.4.30 %sys "CREATE DATABASE db1"]
      ::
      [~2012.5.1 %db1 create-sd-table]
      ::
      :+  ~2012.5.2
          %db1
          "INSERT INTO my-table".
          " VALUES".
          " ('row1', --6)"
      ::
      :+  ~2012.5.3
          %db1
          "FROM my-table WHERE -6 > -3 SELECT *"
      ::
      :-  %results
          :~  [%action 'SELECT']
              [%result-set ~]
              [%server-time ~2012.5.3]
              [%relation 'db1.dbo.my-table']
              [%schema-time ~2012.5.1]
              [%data-time ~2012.5.2]
              [%vector-count 0]
              ==
      ==
::
::  WHERE <column> > <literal> @sd neg-pos (false)
++  test-gt-27
  =|  run=@ud
  %-  exec-2-1
  :*  run
      [~2012.4.30 %sys "CREATE DATABASE db1"]
      ::
      [~2012.5.1 %db1 create-sd-table]
      ::
      :+  ~2012.5.2
          %db1
          "INSERT INTO my-table".
          " VALUES".
          " ('row1', -3)".
          " ('row2', -6)"
      ::
      :+  ~2012.5.3
          %db1
          "FROM my-table WHERE col2 > --3 SELECT *"
      ::
      :-  %results
          :~  [%action 'SELECT']
              [%result-set ~]
              [%server-time ~2012.5.3]
              [%relation 'db1.dbo.my-table']
              [%schema-time ~2012.5.1]
              [%data-time ~2012.5.2]
              [%vector-count 0]
              ==
      ==
::
::  WHERE <column> > <literal> @sd pos-neg (true)
++  test-gt-28
  =|  run=@ud
  %-  exec-2-1
  :*  run
      [~2012.4.30 %sys "CREATE DATABASE db1"]
      ::
      [~2012.5.1 %db1 create-sd-table]
      ::
      :+  ~2012.5.2
          %db1
          "INSERT INTO my-table".
          " VALUES".
          " ('row1', --3)".
          " ('row2', --6)"
      ::
      :+  ~2012.5.3
          %db1
          "FROM my-table WHERE col2 > -3 SELECT *"
      ::
      :-  %results
          :~  [%action 'SELECT']
              :-  %result-set
                  :~  :-  %vector
                          :~  [%col1 [~.t 'row1']]
                              [%col2 [~.sd --3]]
                              ==
                      :-  %vector
                          :~  [%col1 [~.t 'row2']]
                              [%col2 [~.sd --6]]
                              ==
                      ==
              [%server-time ~2012.5.3]
              [%relation 'db1.dbo.my-table']
              [%schema-time ~2012.5.1]
              [%data-time ~2012.5.2]
              [%vector-count 2]
              ==
      ==
::
::  WHERE <column> > <literal> @sd pos-pos (true and false)
++  test-gt-29
  =|  run=@ud
  %-  exec-2-1
  :*  run
      [~2012.4.30 %sys "CREATE DATABASE db1"]
      ::
      [~2012.5.1 %db1 create-sd-table]
      ::
      :+  ~2012.5.2
          %db1
          "INSERT INTO my-table".
          " VALUES".
          " ('row1', --6)".
          " ('row2', --3)"
      ::
      :+  ~2012.5.3
          %db1
          "FROM my-table WHERE col2 > --5 SELECT *"
      ::
      :-  %results
          :~  [%action 'SELECT']
              :-  %result-set
                  :~  :-  %vector
                          :~  [%col1 [~.t 'row1']]
                              [%col2 [~.sd --6]]
                              ==
                      ==
              [%server-time ~2012.5.3]
              [%relation 'db1.dbo.my-table']
              [%schema-time ~2012.5.1]
              [%data-time ~2012.5.2]
              [%vector-count 1]
              ==
      ==
::
::  WHERE <column> > <literal> @sd neg-neg (true and false)
++  test-gt-30
  =|  run=@ud
  %-  exec-2-1
  :*  run
      [~2012.4.30 %sys "CREATE DATABASE db1"]
      ::
      [~2012.5.1 %db1 create-sd-table]
      ::
      :+  ~2012.5.2
          %db1
          "INSERT INTO my-table".
          " VALUES".
          " ('row1', -3)".
          " ('row2', -6)"
      ::
      :+  ~2012.5.3
          %db1
          "FROM my-table WHERE col2 > -5 SELECT *"
      ::
      :-  %results
          :~  [%action 'SELECT']
              :-  %result-set
                  :~  :-  %vector
                          :~  [%col1 [~.t 'row1']]
                              [%col2 [~.sd -3]]
                              ==
                      ==
              [%server-time ~2012.5.3]
              [%relation 'db1.dbo.my-table']
              [%schema-time ~2012.5.1]
              [%data-time ~2012.5.2]
              [%vector-count 1]
              ==
      ==
::
::  WHERE <literal> > <column> @sd neg-pos (false)
++  test-gt-31
  =|  run=@ud
  %-  exec-2-1
  :*  run
      [~2012.4.30 %sys "CREATE DATABASE db1"]
      ::
      [~2012.5.1 %db1 create-sd-table]
      ::
      :+  ~2012.5.2
          %db1
          "INSERT INTO my-table".
          " VALUES".
          " ('row1', --3)".
          " ('row2', --6)"
      ::
      :+  ~2012.5.3
          %db1
          "FROM my-table WHERE -3 > col2 SELECT *"
      ::
      :-  %results
          :~  [%action 'SELECT']
              [%result-set ~]
              [%server-time ~2012.5.3]
              [%relation 'db1.dbo.my-table']
              [%schema-time ~2012.5.1]
              [%data-time ~2012.5.2]
              [%vector-count 0]
              ==
      ==
::
::  WHERE <literal> > <column> @sd pos-neg (true)
++  test-gt-32
  =|  run=@ud
  %-  exec-2-1
  :*  run
      [~2012.4.30 %sys "CREATE DATABASE db1"]
      ::
      [~2012.5.1 %db1 create-sd-table]
      ::
      :+  ~2012.5.2
          %db1
          "INSERT INTO my-table".
          " VALUES".
          " ('row1', -3)".
          " ('row2', -6)"
      ::
      :+  ~2012.5.3
          %db1
          "FROM my-table WHERE --3 > col2 SELECT *"
      ::
      :-  %results
          :~  [%action 'SELECT']
              :-  %result-set
                  :~  :-  %vector
                          :~  [%col1 [~.t 'row1']]
                              [%col2 [~.sd -3]]
                              ==
                      :-  %vector
                          :~  [%col1 [~.t 'row2']]
                              [%col2 [~.sd -6]]
                              ==
                      ==
              [%server-time ~2012.5.3]
              [%relation 'db1.dbo.my-table']
              [%schema-time ~2012.5.1]
              [%data-time ~2012.5.2]
              [%vector-count 2]
              ==
      ==
::
::  WHERE <literal> > <column> @sd pos-pos (true and false)
++  test-gt-33
  =|  run=@ud
  %-  exec-2-1
  :*  run
      [~2012.4.30 %sys "CREATE DATABASE db1"]
      ::
      [~2012.5.1 %db1 create-sd-table]
      ::
      :+  ~2012.5.2
          %db1
          "INSERT INTO my-table".
          " VALUES".
          " ('row1', --6)".
          " ('row2', --3)"
      ::
      :+  ~2012.5.3
          %db1
          "FROM my-table WHERE --5 > col2 SELECT *"
      ::
      :-  %results
          :~  [%action 'SELECT']
              :-  %result-set
                  :~  :-  %vector
                          :~  [%col1 [~.t 'row2']]
                              [%col2 [~.sd --3]]
                              ==
                      ==
              [%server-time ~2012.5.3]
              [%relation 'db1.dbo.my-table']
              [%schema-time ~2012.5.1]
              [%data-time ~2012.5.2]
              [%vector-count 1]
              ==
      ==
::
::  WHERE <literal> > <column> @sd neg-neg (true and false)
++  test-gt-34
  =|  run=@ud
  %-  exec-2-1
  :*  run
      [~2012.4.30 %sys "CREATE DATABASE db1"]
      ::
      [~2012.5.1 %db1 create-sd-table]
      ::
      :+  ~2012.5.2
          %db1
          "INSERT INTO my-table".
          " VALUES".
          " ('row1', -3)".
          " ('row2', -6)"
      ::
      :+  ~2012.5.3
          %db1
          "FROM my-table WHERE -5 > col2 SELECT *"
      ::
      :-  %results
          :~  [%action 'SELECT']
              :-  %result-set
                  :~  :-  %vector
                          :~  [%col1 [~.t 'row2']]
                              [%col2 [~.sd -6]]
                              ==
                      ==
              [%server-time ~2012.5.3]
              [%relation 'db1.dbo.my-table']
              [%schema-time ~2012.5.1]
              [%data-time ~2012.5.2]
              [%vector-count 1]
              ==
      ==
::
::  WHERE <column> > <column> @sd neg-pos (false)
++  test-gt-35
  =|  run=@ud
  %-  exec-2-1
  :*  run
      [~2012.4.30 %sys "CREATE DATABASE db1"]
      ::
      [~2012.5.1 %db1 create-sd-2col-table]
      ::
      :+  ~2012.5.2
          %db1
          "INSERT INTO my-table".
          " VALUES".
          " ('row1', -3, --3)"
      ::
      :+  ~2012.5.3
          %db1
          "FROM my-table WHERE col2 > col3 SELECT *"
      ::
      :-  %results
          :~  [%action 'SELECT']
              [%result-set ~]
              [%server-time ~2012.5.3]
              [%relation 'db1.dbo.my-table']
              [%schema-time ~2012.5.1]
              [%data-time ~2012.5.2]
              [%vector-count 0]
              ==
      ==
::
::  WHERE <column> > <column> @sd pos-neg (true)
++  test-gt-36
  =|  run=@ud
  %-  exec-2-1
  :*  run
      [~2012.4.30 %sys "CREATE DATABASE db1"]
      ::
      [~2012.5.1 %db1 create-sd-2col-table]
      ::
      :+  ~2012.5.2
          %db1
          "INSERT INTO my-table".
          " VALUES".
          " ('row1', --3, -3)"
      ::
      :+  ~2012.5.3
          %db1
          "FROM my-table WHERE col2 > col3 SELECT *"
      ::
      :-  %results
          :~  [%action 'SELECT']
              :-  %result-set
                  :~  :-  %vector
                          :~  [%col1 [~.t 'row1']]
                              [%col2 [~.sd --3]]
                              [%col3 [~.sd -3]]
                              ==
                      ==
              [%server-time ~2012.5.3]
              [%relation 'db1.dbo.my-table']
              [%schema-time ~2012.5.1]
              [%data-time ~2012.5.2]
              [%vector-count 1]
              ==
      ==
::
::  WHERE <column> > <column> @sd pos-pos (true and false)
++  test-gt-37
  =|  run=@ud
  %-  exec-2-1
  :*  run
      [~2012.4.30 %sys "CREATE DATABASE db1"]
      ::
      [~2012.5.1 %db1 create-sd-2col-table]
      ::
      :+  ~2012.5.2
          %db1
          "INSERT INTO my-table".
          " VALUES".
          " ('row1', --6, --3)".
          " ('row2', --3, --6)"
      ::
      :+  ~2012.5.3
          %db1
          "FROM my-table WHERE col2 > col3 SELECT *"
      ::
      :-  %results
          :~  [%action 'SELECT']
              :-  %result-set
                  :~  :-  %vector
                          :~  [%col1 [~.t 'row1']]
                              [%col2 [~.sd --6]]
                              [%col3 [~.sd --3]]
                              ==
                      ==
              [%server-time ~2012.5.3]
              [%relation 'db1.dbo.my-table']
              [%schema-time ~2012.5.1]
              [%data-time ~2012.5.2]
              [%vector-count 1]
              ==
      ==
::
::  WHERE <column> > <column> @sd neg-neg (true and false)
++  test-gt-38
  =|  run=@ud
  %-  exec-2-1
  :*  run
      [~2012.4.30 %sys "CREATE DATABASE db1"]
      ::
      [~2012.5.1 %db1 create-sd-2col-table]
      ::
      :+  ~2012.5.2
          %db1
          "INSERT INTO my-table".
          " VALUES".
          " ('row1', -3, -6)".
          " ('row2', -6, -3)"
      ::
      :+  ~2012.5.3
          %db1
          "FROM my-table WHERE col2 > col3 SELECT *"
      ::
      :-  %results
          :~  [%action 'SELECT']
              :-  %result-set
                  :~  :-  %vector
                          :~  [%col1 [~.t 'row1']]
                              [%col2 [~.sd -3]]
                              [%col3 [~.sd -6]]
                              ==
                      ==
              [%server-time ~2012.5.3]
              [%relation 'db1.dbo.my-table']
              [%schema-time ~2012.5.1]
              [%data-time ~2012.5.2]
              [%vector-count 1]
              ==
      ==
::
::  fail WHERE <column> > <literal> types differ
++  test-fail-gt-00
  =|  run=@ud
  %-  failon-3
  :*  run
      [~2012.4.30 %sys "CREATE DATABASE db1"]
      ::
      [~2012.5.1 %db1 create-mytable]
      ::
      :+  ~2012.5.2
          %db1
          "INSERT INTO my-table".
          " VALUES".
          " ('Abby', ~1999.2.19, 'tricolor', 'row1')".
          " ('Ace', ~2005.12.19, 'ticolor', 'row2')".
          " ('Angel', ~2001.9.19, 'Angel', 'row3')"
      ::
      :+  ~2012.5.2
          %db1
          "FROM my-table WHERE col1 > ~1999.2.19 SELECT *"
      ::
      %-  crip
          "comparing column to literal of different aura: %col1 type=~.t ".
          "[p=~.da q=170.141.184.492.111.779.796.175.933.613.172.326.400]"
      ==
::
::  fail WHERE <literal> > <column> types differ
++  test-fail-gt-01
  =|  run=@ud
  %-  failon-3
  :*  run
      [~2012.4.30 %sys "CREATE DATABASE db1"]
      ::
      [~2012.5.1 %db1 create-mytable]
      ::
      :+  ~2012.5.2
          %db1
          "INSERT INTO my-table".
          " VALUES".
          " ('Abby', ~1999.2.19, 'tricolor', 'row1')".
          " ('Ace', ~2005.12.19, 'ticolor', 'row2')".
          " ('Angel', ~2001.9.19, 'Angel', 'row3')"
      ::
      :+  ~2012.5.2
          %db1
          "FROM my-table WHERE ~1999.2.19 > col1 SELECT *"
      ::
      %-  crip
          "comparing literal to column of different aura: ".
          "[p=~.da q=170.141.184.492.111.779.796.175.933.613.172.326.400] ".
          "%col1 type=~.t"
      ==
::
::  fail WHERE <column> > <column> types differ
++  test-fail-gt-02
  =|  run=@ud
  %-  failon-3
  :*  run
      [~2012.4.30 %sys "CREATE DATABASE db1"]
      ::
      [~2012.5.1 %db1 create-mytable]
      ::
      :+  ~2012.5.2
          %db1
          "INSERT INTO my-table".
          " VALUES".
          " ('Abby', ~1999.2.19, 'tricolor', 'row1')".
          " ('Ace', ~2005.12.19, 'ticolor', 'row2')".
          " ('Angel', ~2001.9.19, 'Angel', 'row3')"
      ::
      :+  ~2012.5.2
          %db1
          "FROM my-table WHERE col1 > col2 SELECT *"
      ::
      %-  crip
          "comparing columns of different auras: %col1 type=~.t %col2 type=~.da"
      ==
::
::  WHERE <column> > <literal> (cord) joined
++  test-gt-joined-00
  =|  run=@ud
  %-  exec-2-1
  :*  run
      [~2012.4.30 %sys "CREATE DATABASE db1"]
      ::
      [~2012.5.1 %db1 create-joined-tables]
      ::
      :+  ~2012.5.2
          %db1
          "INSERT INTO my-table".
          " VALUES".
          " ('Abby', ~1999.2.19)".
          " ('Ace', ~2005.12.19)".
          " ('Angel', ~2001.9.19); ".
          "INSERT INTO my-table-2".
          " VALUES".
          " ('Abby', 'tricolor', 'row1')".
          " ('Ace', 'ticolor', 'row2')".
          " ('Angel', 'tuxedo', 'row3')"
      ::
      :+  ~2012.5.3
          %db1
          "FROM my-table T1 JOIN my-table-2 T2 ".
          "WHERE col3 > 'toledo' SELECT T1.*, T2.col3, T2.col4"
      ::
      :-  %results
          :~  [%action 'SELECT']
              :-  %result-set
                  :~  :-  %vector
                          :~  [%col1 [~.t 'Angel']]
                              [%col2 [~.da ~2001.9.19]]
                              [%col3 [~.t 'tuxedo']]
                              [%col4 [~.t 'row3']]
                              ==
                      :-  %vector
                          :~  [%col1 [~.t 'Abby']]
                              [%col2 [~.da ~1999.2.19]]
                              [%col3 [~.t 'tricolor']]
                              [%col4 [~.t 'row1']]
                              ==
                      ==
              [%server-time ~2012.5.3]
              [%relation 'db1.dbo.my-table']
              [%schema-time ~2012.5.1]
              [%data-time ~2012.5.2]
              [%relation 'db1.dbo.my-table-2']
              [%schema-time ~2012.5.1]
              [%data-time ~2012.5.2]
              [%vector-count 2]
              ==
      ==
::
::  WHERE <column> > <literal> (@da) joined
++  test-gt-joined-01
  =|  run=@ud
  %-  exec-2-1
  :*  run
      [~2012.4.30 %sys "CREATE DATABASE db1"]
      ::
      [~2012.5.1 %db1 create-joined-tables]
      ::
      :+  ~2012.5.2
          %db1
          "INSERT INTO my-table".
          " VALUES".
          " ('Abby', ~1999.2.19)".
          " ('Ace', ~2005.12.19)".
          " ('Angel', ~2001.9.19); ".
          "INSERT INTO my-table-2".
          " VALUES".
          " ('Abby', 'tricolor', 'row1')".
          " ('Ace', 'ticolor', 'row2')".
          " ('Angel', 'tuxedo', 'row3')"
      ::
      :+  ~2012.5.3
          %db1
          "FROM my-table T1 JOIN my-table-2 T2 ".
          "WHERE col2 > ~1999.2.19 SELECT T1.*, T2.col3, T2.col4"
      ::
      :-  %results
          :~  [%action 'SELECT']
              :-  %result-set
                  :~  :-  %vector
                          :~  [%col1 [~.t 'Ace']]
                              [%col2 [~.da ~2005.12.19]]
                              [%col3 [~.t 'ticolor']]
                              [%col4 [~.t 'row2']]
                              ==
                      :-  %vector
                          :~  [%col1 [~.t 'Angel']]
                              [%col2 [~.da ~2001.9.19]]
                              [%col3 [~.t 'tuxedo']]
                              [%col4 [~.t 'row3']]
                              ==
                      ==
              [%server-time ~2012.5.3]
              [%relation 'db1.dbo.my-table']
              [%schema-time ~2012.5.1]
              [%data-time ~2012.5.2]
              [%relation 'db1.dbo.my-table-2']
              [%schema-time ~2012.5.1]
              [%data-time ~2012.5.2]
              [%vector-count 2]
              ==
      ==
::
::  WHERE <literal> > <column>  (cord) joined
++  test-gt-joined-02
  =|  run=@ud
  %-  exec-2-1
  :*  run
      [~2012.4.30 %sys "CREATE DATABASE db1"]
      ::
      [~2012.5.1 %db1 create-joined-tables]
      ::
      :+  ~2012.5.2
          %db1
          "INSERT INTO my-table".
          " VALUES".
          " ('Abby', ~1999.2.19)".
          " ('Ace', ~2005.12.19)".
          " ('Angel', ~2001.9.19); ".
          "INSERT INTO my-table-2".
          " VALUES".
          " ('Abby', 'tricolor', 'row1')".
          " ('Ace', 'ticolor', 'row2')".
          " ('Angel', 'tuxedo', 'row3')"
      ::
      :+  ~2012.5.3
          %db1
          "FROM my-table T1 JOIN my-table-2 T2 ".
          "WHERE 'tricolor' > col3 SELECT T1.*, T2.col3, T2.col4"
      ::
      :-  %results
          :~  [%action 'SELECT']
              :-  %result-set
                  :~  :-  %vector
                          :~  [%col1 [~.t 'Ace']]
                              [%col2 [~.da ~2005.12.19]]
                              [%col3 [~.t 'ticolor']]
                              [%col4 [~.t 'row2']]
                              ==
                      ==
              [%server-time ~2012.5.3]
              [%relation 'db1.dbo.my-table']
              [%schema-time ~2012.5.1]
              [%data-time ~2012.5.2]
              [%relation 'db1.dbo.my-table-2']
              [%schema-time ~2012.5.1]
              [%data-time ~2012.5.2]
              [%vector-count 1]
              ==
      ==
::
::  WHERE <column> > <column>  (cord) joined
++  test-gt-joined-03
  =|  run=@ud
  %-  exec-2-1
  :*  run
      [~2012.4.30 %sys "CREATE DATABASE db1"]
      ::
      [~2012.5.1 %db1 create-joined-tables]
      ::
      :+  ~2012.5.2
          %db1
          "INSERT INTO my-table".
          " VALUES".
          " ('Abby', ~1999.2.19)".
          " ('Ace', ~2005.12.19)".
          " ('Angel', ~2001.9.19); ".
          "INSERT INTO my-table-2".
          " VALUES".
          " ('Abby', 'tricolor', 'row1')".
          " ('Ace', 'ticolor', 'row2')".
          " ('Angel', 'Angel', 'row3')"
      ::
      :+  ~2012.5.3
          %db1
          "FROM my-table T1 JOIN my-table-2 T2 ".
          "WHERE col3 > t1.col1 SELECT T1.*, T2.col3, T2.col4"
      ::
      :-  %results
          :~  [%action 'SELECT']
              :-  %result-set
                  :~  :-  %vector
                          :~  [%col1 [~.t 'Ace']]
                              [%col2 [~.da ~2005.12.19]]
                              [%col3 [~.t 'ticolor']]
                              [%col4 [~.t 'row2']]
                              ==
                      :-  %vector
                          :~  [%col1 [~.t 'Abby']]
                              [%col2 [~.da ~1999.2.19]]
                              [%col3 [~.t 'tricolor']]
                              [%col4 [~.t 'row1']]
                              ==
                      ==
              [%server-time ~2012.5.3]
              [%relation 'db1.dbo.my-table']
              [%schema-time ~2012.5.1]
              [%data-time ~2012.5.2]
              [%relation 'db1.dbo.my-table-2']
              [%schema-time ~2012.5.1]
              [%data-time ~2012.5.2]
              [%vector-count 2]
              ==
      ==
::
::  WHERE <column> > <literal> (cord) joined
++  test-gt-joined-04
  =|  run=@ud
  %-  exec-2-1
  :*  run
      [~2012.4.30 %sys "CREATE DATABASE db1"]
      ::
      [~2012.5.1 %db1 create-joined-tables]
      ::
      :+  ~2012.5.2
          %db1
          "INSERT INTO my-table".
          " VALUES".
          " ('Abby', ~1999.2.19)".
          " ('Ace', ~2005.12.19)".
          " ('Angel', ~2001.9.19); ".
          "INSERT INTO my-table-2".
          " VALUES".
          " ('Abby', 'tricolor', 'row1')".
          " ('Ace', 'ticolor', 'row2')".
          " ('Angel', 'tuxedo', 'row3')"
      ::
      :+  ~2012.5.3
          %db1
          "FROM my-table t1 JOIN my-table-2 T2 ".
          "WHERE T1.col1 > 'Abbz' SELECT T1.*, T2.col3, T2.col4"
      ::
      :-  %results
          :~  [%action 'SELECT']
              :-  %result-set
                  :~  :-  %vector
                          :~  [%col1 [~.t 'Ace']]
                              [%col2 [~.da ~2005.12.19]]
                              [%col3 [~.t 'ticolor']]
                              [%col4 [~.t 'row2']]
                              ==
                      :-  %vector
                          :~  [%col1 [~.t 'Angel']]
                              [%col2 [~.da ~2001.9.19]]
                              [%col3 [~.t 'tuxedo']]
                              [%col4 [~.t 'row3']]
                              ==
                      ==
              [%server-time ~2012.5.3]
              [%relation 'db1.dbo.my-table']
              [%schema-time ~2012.5.1]
              [%data-time ~2012.5.2]
              [%relation 'db1.dbo.my-table-2']
              [%schema-time ~2012.5.1]
              [%data-time ~2012.5.2]
              [%vector-count 2]
              ==
      ==
::
::  fail WHERE <column> > <literal> types differ joined
++  test-fail-gt-joined-00
  =|  run=@ud
  %-  failon-3
  :*  run
      [~2012.4.30 %sys "CREATE DATABASE db1"]
      ::
      [~2012.5.1 %db1 create-joined-tables]
      ::
      :+  ~2012.5.2
          %db1
          "INSERT INTO my-table".
          " VALUES".
          " ('Abby', ~1999.2.19)".
          " ('Ace', ~2005.12.19)".
          " ('Angel', ~2001.9.19); ".
          "INSERT INTO my-table-2".
          " VALUES".
          " ('Abby', 'tricolor', 'row1')".
          " ('Ace', 'ticolor', 'row2')".
          " ('Angel', 'Angel', 'row3')"
      ::
      :+  ~2012.5.2
          %db1
          "FROM my-table T1 JOIN my-table-2 T2 ".
          "WHERE t1.col1 > ~1999.2.19 SELECT T1.*, T2.col3, T2.col4"
      ::
      %-  crip
          "comparing column to literal of different aura: %col1 type=~.t ".
          "[p=~.da q=170.141.184.492.111.779.796.175.933.613.172.326.400]"
      ==
::
::  fail WHERE <literal> > <column> types differ joined
++  test-fail-gt-joined-01
  =|  run=@ud
  %-  failon-3
  :*  run
      [~2012.4.30 %sys "CREATE DATABASE db1"]
      ::
      [~2012.5.1 %db1 create-joined-tables]
      ::
      :+  ~2012.5.2
          %db1
          "INSERT INTO my-table".
          " VALUES".
          " ('Abby', ~1999.2.19)".
          " ('Ace', ~2005.12.19)".
          " ('Angel', ~2001.9.19); ".
          "INSERT INTO my-table-2".
          " VALUES".
          " ('Abby', 'tricolor', 'row1')".
          " ('Ace', 'ticolor', 'row2')".
          " ('Angel', 'Angel', 'row3')"
      ::
      :+  ~2012.5.2
          %db1
          "FROM my-table T1 JOIN my-table-2 T2 ".
          "WHERE ~1999.2.19 > t1.col1 SELECT T1.*, T2.col3, T2.col4"
      ::
      %-  crip
          "comparing literal to column of different aura: ".
          "[p=~.da q=170.141.184.492.111.779.796.175.933.613.172.326.400] ".
          "%col1 type=~.t"
      ==
::
::  fail WHERE <column> > <column> types differ joined
++  test-fail-gt-joined-02
  =|  run=@ud
  %-  failon-3
  :*  run
      [~2012.4.30 %sys "CREATE DATABASE db1"]
      ::
      [~2012.5.1 %db1 create-joined-tables]
      ::
      :+  ~2012.5.2
          %db1
          "INSERT INTO my-table".
          " VALUES".
          " ('Abby', ~1999.2.19)".
          " ('Ace', ~2005.12.19)".
          " ('Angel', ~2001.9.19); ".
          "INSERT INTO my-table-2".
          " VALUES".
          " ('Abby', 'tricolor', 'row1')".
          " ('Ace', 'ticolor', 'row2')".
          " ('Angel', 'Angel', 'row3')"
      ::
      :+  ~2012.5.2
          %db1
          "FROM my-table T1 JOIN my-table-2 T2 ".
          "WHERE t1.col1 > col2 SELECT T1.*, T2.col3, T2.col4"
      ::
      %-  crip
          "comparing columns of different auras: %col1 type=~.t %col2 type=~.da"
      ==
::
::  LT
::
::  WHERE <column> < <literal> (cord)
++  test-lt-00
  =|  run=@ud
  %-  exec-2-1
  :*  run
      [~2012.4.30 %sys "CREATE DATABASE db1"]
      ::
      [~2012.5.1 %db1 create-mytable]
      ::
      :+  ~2012.5.2
          %db1
          "INSERT INTO my-table".
          " VALUES".
          " ('Abby', ~1999.2.19, 'tricolor', 'row1')".
          " ('Ace', ~2005.12.19, 'ticolor', 'row2')".
          " ('Angel', ~2001.9.19, 'tuxedo', 'row3')"
      ::
      :+  ~2012.5.3
          %db1
          "FROM my-table WHERE col3 < 'toledo' SELECT *"
      ::
      :-  %results
          :~  [%action 'SELECT']
              :-  %result-set
                  :~  :-  %vector
                          :~  [%col1 [~.t 'Ace']]
                              [%col2 [~.da ~2005.12.19]]
                              [%col3 [~.t 'ticolor']]
                              [%col4 [~.t 'row2']]
                              ==
                      ==
              [%server-time ~2012.5.3]
              [%relation 'db1.dbo.my-table']
              [%schema-time ~2012.5.1]
              [%data-time ~2012.5.2]
              [%vector-count 1]
              ==
      ==
::
::  WHERE <column> < <literal> (@da)
++  test-lt-01
  =|  run=@ud
  %-  exec-2-1
  :*  run
      [~2012.4.30 %sys "CREATE DATABASE db1"]
      ::
      [~2012.5.1 %db1 create-mytable]
      ::
      :+  ~2012.5.2
          %db1
          "INSERT INTO my-table".
          " VALUES".
          " ('Abby', ~1999.2.19, 'tricolor', 'row1')".
          " ('Ace', ~2005.12.19, 'ticolor', 'row2')".
          " ('Angel', ~2001.9.19, 'tuxedo', 'row3')"
      ::
      :+  ~2012.5.3
          %db1
          "FROM my-table WHERE col2 < ~2001.9.19 SELECT *"
      ::
      :-  %results
          :~  [%action 'SELECT']
              :-  %result-set
                  :~  :-  %vector
                          :~  [%col1 [~.t 'Abby']]
                              [%col2 [~.da ~1999.2.19]]
                              [%col3 [~.t 'tricolor']]
                              [%col4 [~.t 'row1']]
                              ==
                      ==
              [%server-time ~2012.5.3]
              [%relation 'db1.dbo.my-table']
              [%schema-time ~2012.5.1]
              [%data-time ~2012.5.2]
              [%vector-count 1]
              ==
      ==
::
::  WHERE <literal> < <column>  (cord)
++  test-lt-02
  =|  run=@ud
  %-  exec-2-1
  :*  run
      [~2012.4.30 %sys "CREATE DATABASE db1"]
      ::
      [~2012.5.1 %db1 create-mytable]
      ::
      :+  ~2012.5.2
          %db1
          "INSERT INTO my-table".
          " VALUES".
          " ('Abby', ~1999.2.19, 'tricolor', 'row1')".
          " ('Ace', ~2005.12.19, 'ticolor', 'row2')".
          " ('Angel', ~2001.9.19, 'tuxedo', 'row3')"
      ::
      :+  ~2012.5.3
          %db1
          "FROM my-table WHERE 'tricolor' < col3 SELECT *"
      ::
      :-  %results
          :~  [%action 'SELECT']
              :-  %result-set
                  :~  :-  %vector
                          :~  [%col1 [~.t 'Angel']]
                              [%col2 [~.da ~2001.9.19]]
                              [%col3 [~.t 'tuxedo']]
                              [%col4 [~.t 'row3']]
                              ==
                      ==
              [%server-time ~2012.5.3]
              [%relation 'db1.dbo.my-table']
              [%schema-time ~2012.5.1]
              [%data-time ~2012.5.2]
              [%vector-count 1]
              ==
      ==
::
::  WHERE <column> < <column>  (cord)
++  test-lt-03
  =|  run=@ud
  %-  exec-2-1
  :*  run
      [~2012.4.30 %sys "CREATE DATABASE db1"]
      ::
      [~2012.5.1 %db1 create-mytable]
      ::
      :+  ~2012.5.2
          %db1
          "INSERT INTO my-table".
          " VALUES".
          " ('Abby', ~1999.2.19, 'tricolor', 'row1')".
          " ('Ace', ~2005.12.19, 'ticolor', 'row2')".
          " ('Angel', ~2001.9.19, 'Angel', 'row3')"
      ::
      :+  ~2012.5.3
          %db1
          "FROM my-table WHERE col1 < col3 SELECT *"
      ::
      :-  %results
          :~  [%action 'SELECT']
              :-  %result-set
                  :~  :-  %vector
                          :~  [%col1 [~.t 'Ace']]
                              [%col2 [~.da ~2005.12.19]]
                              [%col3 [~.t 'ticolor']]
                              [%col4 [~.t 'row2']]
                              ==
                      :-  %vector
                          :~  [%col1 [~.t 'Abby']]
                              [%col2 [~.da ~1999.2.19]]
                              [%col3 [~.t 'tricolor']]
                              [%col4 [~.t 'row1']]
                              ==
                      ==
              [%server-time ~2012.5.3]
              [%relation 'db1.dbo.my-table']
              [%schema-time ~2012.5.1]
              [%data-time ~2012.5.2]
              [%vector-count 2]
              ==
      ==
::
::  WHERE <column> < <literal> (cord)
++  test-lt-04
  =|  run=@ud
  %-  exec-2-1
  :*  run
      [~2012.4.30 %sys "CREATE DATABASE db1"]
      ::
      :+  ~2012.5.1
          %db1
          "CREATE TABLE db1..my-table ".
          "(col1 @t, col2 @da, col3 @t, col4 @t) ".
          "PRIMARY KEY (col3)"
      ::
      :+  ~2012.5.2
          %db1
          "INSERT INTO my-table".
          " VALUES".
          " ('Abby', ~1999.2.19, 'tricolor', 'row1')".
          " ('Ace', ~2005.12.19, 'ticolor', 'row2')".
          " ('Angel', ~2001.9.19, 'tuxedo', 'row3')"
      ::
      :+  ~2012.5.3
          %db1
          "FROM my-table WHERE col1 < 'Angel' SELECT *"
      ::
      :-  %results
          :~  [%action 'SELECT']
              :-  %result-set
                  :~  :-  %vector
                          :~  [%col1 [~.t 'Ace']]
                              [%col2 [~.da ~2005.12.19]]
                              [%col3 [~.t 'ticolor']]
                              [%col4 [~.t 'row2']]
                              ==
                      :-  %vector
                          :~  [%col1 [~.t 'Abby']]
                              [%col2 [~.da ~1999.2.19]]
                              [%col3 [~.t 'tricolor']]
                              [%col4 [~.t 'row1']]
                              ==
                      ==
              [%server-time ~2012.5.3]
              [%relation 'db1.dbo.my-table']
              [%schema-time ~2012.5.1]
              [%data-time ~2012.5.2]
              [%vector-count 2]
              ==
      ==
::
::  view WHERE <column> < <literal>
++  test-lt-05
  =|  run=@ud
  %-  exec-1-1
  :*  run
      [~2012.4.30 %sys "CREATE DATABASE db1"]
      ::
      [~2012.5.1 %db1 create-mytable]
      ::
      :+  ~2012.5.3
          %db1
          "FROM sys.columns WHERE 'col2' < col-name SELECT *"
      ::
      :-  %results
          :~  [%action 'SELECT']
              :-  %result-set
                  :~  :-  %vector
                          :~  [p=%namespace q=[p=~.tas q=%dbo]]
                              [p=%name q=[p=~.tas q=%my-table]]
                              [p=%col-ordinal q=[p=~.ud q=4]]
                              [p=%col-name q=[p=~.tas q=%col4]]
                              [p=%col-type q=[p=~.ta q=~.t]]
                              ==
                      :-  %vector
                          :~  [p=%namespace q=[p=~.tas q=%dbo]]
                              [p=%name q=[p=~.tas q=%my-table]]
                              [p=%col-ordinal q=[p=~.ud q=3]]
                              [p=%col-name q=[p=~.tas q=%col3]]
                              [p=%col-type q=[p=~.ta q=~.t]]
                              ==
                      ==
              [%server-time ~2012.5.3]
              [%relation 'db1.sys.columns']
              [%schema-time ~2012.5.1]
              [%data-time ~2012.5.1]
              [%vector-count 2]
              ==
      ==
::
::  view WHERE <literal> < <literal>
++  test-lt-06
  =|  run=@ud
  %-  exec-1-1
  :*  run
      [~2012.4.30 %sys "CREATE DATABASE db1"]
      ::
      [~2012.5.1 %db1 create-mytable]
      ::
      :+  ~2012.5.3
          %db1
          "FROM sys.columns WHERE 2 < 1 SELECT *"
      ::
      :-  %results
          :~  [%action 'SELECT']
              [%result-set ~]
              [%server-time ~2012.5.3]
              [%relation 'db1.sys.columns']
              [%schema-time ~2012.5.1]
              [%data-time ~2012.5.1]
              [%vector-count 0]
              ==
      ==
::
::  WHERE <literal> < <literal> @rd less (true)
++  test-lt-07
  =|  run=@ud
  %-  exec-2-1
  :*  run
      [~2012.4.30 %sys "CREATE DATABASE db1"]
      ::
      [~2012.5.1 %db1 create-rd-table]
      ::
      :+  ~2012.5.2
          %db1
          "INSERT INTO my-table".
          " VALUES".
          " ('row1', .~3.14)"
      ::
      :+  ~2012.5.3
          %db1
          "FROM my-table WHERE .~3.14 < .~6.02 SELECT *"
      ::
      :-  %results
          :~  [%action 'SELECT']
              :-  %result-set
                  :~  :-  %vector
                          :~  [%col1 [~.t 'row1']]
                              [%col2 [~.rd .~3.14]]
                              ==
                      ==
              [%server-time ~2012.5.3]
              [%relation 'db1.dbo.my-table']
              [%schema-time ~2012.5.1]
              [%data-time ~2012.5.2]
              [%vector-count 1]
              ==
      ==
::
::  WHERE <literal> < <literal> @rd equality (false)
++  test-lt-08
  =|  run=@ud
  %-  exec-2-1
  :*  run
      [~2012.4.30 %sys "CREATE DATABASE db1"]
      ::
      [~2012.5.1 %db1 create-rd-table]
      ::
      :+  ~2012.5.2
          %db1
          "INSERT INTO my-table".
          " VALUES".
          " ('row1', .~3.14)"
      ::
      :+  ~2012.5.3
          %db1
          "FROM my-table WHERE .~3.14 < .~3.14 SELECT *"
      ::
      :-  %results
          :~  [%action 'SELECT']
              [%result-set ~]
              [%server-time ~2012.5.3]
              [%relation 'db1.dbo.my-table']
              [%schema-time ~2012.5.1]
              [%data-time ~2012.5.2]
              [%vector-count 0]
              ==
      ==
::
::  WHERE <literal> < <literal> @rd greater (false)
++  test-lt-09
  =|  run=@ud
  %-  exec-2-1
  :*  run
      [~2012.4.30 %sys "CREATE DATABASE db1"]
      ::
      [~2012.5.1 %db1 create-rd-table]
      ::
      :+  ~2012.5.2
          %db1
          "INSERT INTO my-table".
          " VALUES".
          " ('row1', .~3.14)"
      ::
      :+  ~2012.5.3
          %db1
          "FROM my-table WHERE .~6.02 < .~3.14 SELECT *"
      ::
      :-  %results
          :~  [%action 'SELECT']
              [%result-set ~]
              [%server-time ~2012.5.3]
              [%relation 'db1.dbo.my-table']
              [%schema-time ~2012.5.1]
              [%data-time ~2012.5.2]
              [%vector-count 0]
              ==
      ==
::
::  WHERE <column> < <literal> @rd less (true)
++  test-lt-10
  =|  run=@ud
  %-  exec-2-1
  :*  run
      [~2012.4.30 %sys "CREATE DATABASE db1"]
      ::
      [~2012.5.1 %db1 create-rd-table]
      ::
      :+  ~2012.5.2
          %db1
          "INSERT INTO my-table".
          " VALUES".
          " ('row1', .~3.14)"
      ::
      :+  ~2012.5.3
          %db1
          "FROM my-table WHERE col2 < .~6.02 SELECT *"
      ::
      :-  %results
          :~  [%action 'SELECT']
              :-  %result-set
                  :~  :-  %vector
                          :~  [%col1 [~.t 'row1']]
                              [%col2 [~.rd .~3.14]]
                              ==
                      ==
              [%server-time ~2012.5.3]
              [%relation 'db1.dbo.my-table']
              [%schema-time ~2012.5.1]
              [%data-time ~2012.5.2]
              [%vector-count 1]
              ==
      ==
::
::  WHERE <column> < <literal> @rd equality (false)
++  test-lt-11
  =|  run=@ud
  %-  exec-2-1
  :*  run
      [~2012.4.30 %sys "CREATE DATABASE db1"]
      ::
      [~2012.5.1 %db1 create-rd-table]
      ::
      :+  ~2012.5.2
          %db1
          "INSERT INTO my-table".
          " VALUES".
          " ('row1', .~3.14)"
      ::
      :+  ~2012.5.3
          %db1
          "FROM my-table WHERE col2 < .~3.14 SELECT *"
      ::
      :-  %results
          :~  [%action 'SELECT']
              [%result-set ~]
              [%server-time ~2012.5.3]
              [%relation 'db1.dbo.my-table']
              [%schema-time ~2012.5.1]
              [%data-time ~2012.5.2]
              [%vector-count 0]
              ==
      ==
::
::  WHERE <column> < <literal> @rd greater (false)
++  test-lt-12
  =|  run=@ud
  %-  exec-2-1
  :*  run
      [~2012.4.30 %sys "CREATE DATABASE db1"]
      ::
      [~2012.5.1 %db1 create-rd-table]
      ::
      :+  ~2012.5.2
          %db1
          "INSERT INTO my-table".
          " VALUES".
          " ('row1', .~6.02)"
      ::
      :+  ~2012.5.3
          %db1
          "FROM my-table WHERE col2 < .~3.14 SELECT *"
      ::
      :-  %results
          :~  [%action 'SELECT']
              [%result-set ~]
              [%server-time ~2012.5.3]
              [%relation 'db1.dbo.my-table']
              [%schema-time ~2012.5.1]
              [%data-time ~2012.5.2]
              [%vector-count 0]
              ==
      ==
::
::  WHERE <literal> < <column> @rd less (true)
++  test-lt-13
  =|  run=@ud
  %-  exec-2-1
  :*  run
      [~2012.4.30 %sys "CREATE DATABASE db1"]
      ::
      [~2012.5.1 %db1 create-rd-table]
      ::
      :+  ~2012.5.2
          %db1
          "INSERT INTO my-table".
          " VALUES".
          " ('row1', .~6.02)"
      ::
      :+  ~2012.5.3
          %db1
          "FROM my-table WHERE .~3.14 < col2 SELECT *"
      ::
      :-  %results
          :~  [%action 'SELECT']
              :-  %result-set
                  :~  :-  %vector
                          :~  [%col1 [~.t 'row1']]
                              [%col2 [~.rd .~6.02]]
                              ==
                      ==
              [%server-time ~2012.5.3]
              [%relation 'db1.dbo.my-table']
              [%schema-time ~2012.5.1]
              [%data-time ~2012.5.2]
              [%vector-count 1]
              ==
      ==
::
::  WHERE <literal> < <column> @rd equality (false)
++  test-lt-14
  =|  run=@ud
  %-  exec-2-1
  :*  run
      [~2012.4.30 %sys "CREATE DATABASE db1"]
      ::
      [~2012.5.1 %db1 create-rd-table]
      ::
      :+  ~2012.5.2
          %db1
          "INSERT INTO my-table".
          " VALUES".
          " ('row1', .~3.14)"
      ::
      :+  ~2012.5.3
          %db1
          "FROM my-table WHERE .~3.14 < col2 SELECT *"
      ::
      :-  %results
          :~  [%action 'SELECT']
              [%result-set ~]
              [%server-time ~2012.5.3]
              [%relation 'db1.dbo.my-table']
              [%schema-time ~2012.5.1]
              [%data-time ~2012.5.2]
              [%vector-count 0]
              ==
      ==
::
::  WHERE <literal> < <column> @rd greater (false)
++  test-lt-15
  =|  run=@ud
  %-  exec-2-1
  :*  run
      [~2012.4.30 %sys "CREATE DATABASE db1"]
      ::
      [~2012.5.1 %db1 create-rd-table]
      ::
      :+  ~2012.5.2
          %db1
          "INSERT INTO my-table".
          " VALUES".
          " ('row1', .~3.14)"
      ::
      :+  ~2012.5.3
          %db1
          "FROM my-table WHERE .~6.02 < col2 SELECT *"
      ::
      :-  %results
          :~  [%action 'SELECT']
              [%result-set ~]
              [%server-time ~2012.5.3]
              [%relation 'db1.dbo.my-table']
              [%schema-time ~2012.5.1]
              [%data-time ~2012.5.2]
              [%vector-count 0]
              ==
      ==
::
::  WHERE <column> < <column> @rd less (true)
++  test-lt-16
  =|  run=@ud
  %-  exec-2-1
  :*  run
      [~2012.4.30 %sys "CREATE DATABASE db1"]
      ::
      [~2012.5.1 %db1 create-rd-2col-table]
      ::
      :+  ~2012.5.2
          %db1
          "INSERT INTO my-table".
          " VALUES".
          " ('row1', .~3.14, .~6.02)"
      ::
      :+  ~2012.5.3
          %db1
          "FROM my-table WHERE col2 < col3 SELECT *"
      ::
      :-  %results
          :~  [%action 'SELECT']
              :-  %result-set
                  :~  :-  %vector
                          :~  [%col1 [~.t 'row1']]
                              [%col2 [~.rd .~3.14]]
                              [%col3 [~.rd .~6.02]]
                              ==
                      ==
              [%server-time ~2012.5.3]
              [%relation 'db1.dbo.my-table']
              [%schema-time ~2012.5.1]
              [%data-time ~2012.5.2]
              [%vector-count 1]
              ==
      ==
::
::  WHERE <column> < <column> @rd equality (false)
++  test-lt-17
  =|  run=@ud
  %-  exec-2-1
  :*  run
      [~2012.4.30 %sys "CREATE DATABASE db1"]
      ::
      [~2012.5.1 %db1 create-rd-2col-table]
      ::
      :+  ~2012.5.2
          %db1
          "INSERT INTO my-table".
          " VALUES".
          " ('row1', .~3.14, .~3.14)"
      ::
      :+  ~2012.5.3
          %db1
          "FROM my-table WHERE col2 < col3 SELECT *"
      ::
      :-  %results
          :~  [%action 'SELECT']
              [%result-set ~]
              [%server-time ~2012.5.3]
              [%relation 'db1.dbo.my-table']
              [%schema-time ~2012.5.1]
              [%data-time ~2012.5.2]
              [%vector-count 0]
              ==
      ==
::
::  WHERE <column> < <column> @rd greater (false)
++  test-lt-18
  =|  run=@ud
  %-  exec-2-1
  :*  run
      [~2012.4.30 %sys "CREATE DATABASE db1"]
      ::
      [~2012.5.1 %db1 create-rd-2col-table]
      ::
      :+  ~2012.5.2
          %db1
          "INSERT INTO my-table".
          " VALUES".
          " ('row1', .~6.02, .~3.14)"
      ::
      :+  ~2012.5.3
          %db1
          "FROM my-table WHERE col2 < col3 SELECT *"
      ::
      :-  %results
          :~  [%action 'SELECT']
              [%result-set ~]
              [%server-time ~2012.5.3]
              [%relation 'db1.dbo.my-table']
              [%schema-time ~2012.5.1]
              [%data-time ~2012.5.2]
              [%vector-count 0]
              ==
      ==
::
::  WHERE <literal> < <literal> @sd less (true)
++  test-lt-19
  =|  run=@ud
  %-  exec-2-1
  :*  run
      [~2012.4.30 %sys "CREATE DATABASE db1"]
      ::
      [~2012.5.1 %db1 create-sd-table]
      ::
      :+  ~2012.5.2
          %db1
          "INSERT INTO my-table".
          " VALUES".
          " ('row1', --3)"
      ::
      :+  ~2012.5.3
          %db1
          "FROM my-table WHERE --3 < --6 SELECT *"
      ::
      :-  %results
          :~  [%action 'SELECT']
              :-  %result-set
                  :~  :-  %vector
                          :~  [%col1 [~.t 'row1']]
                              [%col2 [~.sd --3]]
                              ==
                      ==
              [%server-time ~2012.5.3]
              [%relation 'db1.dbo.my-table']
              [%schema-time ~2012.5.1]
              [%data-time ~2012.5.2]
              [%vector-count 1]
              ==
      ==
::
::  WHERE <literal> < <literal> @sd equality (false)
++  test-lt-20
  =|  run=@ud
  %-  exec-2-1
  :*  run
      [~2012.4.30 %sys "CREATE DATABASE db1"]
      ::
      [~2012.5.1 %db1 create-sd-table]
      ::
      :+  ~2012.5.2
          %db1
          "INSERT INTO my-table".
          " VALUES".
          " ('row1', --3)"
      ::
      :+  ~2012.5.3
          %db1
          "FROM my-table WHERE --3 < --3 SELECT *"
      ::
      :-  %results
          :~  [%action 'SELECT']
              [%result-set ~]
              [%server-time ~2012.5.3]
              [%relation 'db1.dbo.my-table']
              [%schema-time ~2012.5.1]
              [%data-time ~2012.5.2]
              [%vector-count 0]
              ==
      ==
::
::  WHERE <literal> < <literal> @sd greater (false)
++  test-lt-21
  =|  run=@ud
  %-  exec-2-1
  :*  run
      [~2012.4.30 %sys "CREATE DATABASE db1"]
      ::
      [~2012.5.1 %db1 create-sd-table]
      ::
      :+  ~2012.5.2
          %db1
          "INSERT INTO my-table".
          " VALUES".
          " ('row1', --3)"
      ::
      :+  ~2012.5.3
          %db1
          "FROM my-table WHERE --6 < --3 SELECT *"
      ::
      :-  %results
          :~  [%action 'SELECT']
              [%result-set ~]
              [%server-time ~2012.5.3]
              [%relation 'db1.dbo.my-table']
              [%schema-time ~2012.5.1]
              [%data-time ~2012.5.2]
              [%vector-count 0]
              ==
      ==
::
::  WHERE <column> < <literal> @sd less (true)
++  test-lt-22
  =|  run=@ud
  %-  exec-2-1
  :*  run
      [~2012.4.30 %sys "CREATE DATABASE db1"]
      ::
      [~2012.5.1 %db1 create-sd-table]
      ::
      :+  ~2012.5.2
          %db1
          "INSERT INTO my-table".
          " VALUES".
          " ('row1', --3)"
      ::
      :+  ~2012.5.3
          %db1
          "FROM my-table WHERE col2 < --6 SELECT *"
      ::
      :-  %results
          :~  [%action 'SELECT']
              :-  %result-set
                  :~  :-  %vector
                          :~  [%col1 [~.t 'row1']]
                              [%col2 [~.sd --3]]
                              ==
                      ==
              [%server-time ~2012.5.3]
              [%relation 'db1.dbo.my-table']
              [%schema-time ~2012.5.1]
              [%data-time ~2012.5.2]
              [%vector-count 1]
              ==
      ==
::
::  WHERE <column> < <literal> @sd equality (false)
++  test-lt-23
  =|  run=@ud
  %-  exec-2-1
  :*  run
      [~2012.4.30 %sys "CREATE DATABASE db1"]
      ::
      [~2012.5.1 %db1 create-sd-table]
      ::
      :+  ~2012.5.2
          %db1
          "INSERT INTO my-table".
          " VALUES".
          " ('row1', --3)"
      ::
      :+  ~2012.5.3
          %db1
          "FROM my-table WHERE col2 < --3 SELECT *"
      ::
      :-  %results
          :~  [%action 'SELECT']
              [%result-set ~]
              [%server-time ~2012.5.3]
              [%relation 'db1.dbo.my-table']
              [%schema-time ~2012.5.1]
              [%data-time ~2012.5.2]
              [%vector-count 0]
              ==
      ==
::
::  WHERE <column> < <literal> @sd greater (false)
++  test-lt-24
  =|  run=@ud
  %-  exec-2-1
  :*  run
      [~2012.4.30 %sys "CREATE DATABASE db1"]
      ::
      [~2012.5.1 %db1 create-sd-table]
      ::
      :+  ~2012.5.2
          %db1
          "INSERT INTO my-table".
          " VALUES".
          " ('row1', --6)"
      ::
      :+  ~2012.5.3
          %db1
          "FROM my-table WHERE col2 < --3 SELECT *"
      ::
      :-  %results
          :~  [%action 'SELECT']
              [%result-set ~]
              [%server-time ~2012.5.3]
              [%relation 'db1.dbo.my-table']
              [%schema-time ~2012.5.1]
              [%data-time ~2012.5.2]
              [%vector-count 0]
              ==
      ==
::
::  WHERE <literal> < <column> @sd less (true)
++  test-lt-25
  =|  run=@ud
  %-  exec-2-1
  :*  run
      [~2012.4.30 %sys "CREATE DATABASE db1"]
      ::
      [~2012.5.1 %db1 create-sd-table]
      ::
      :+  ~2012.5.2
          %db1
          "INSERT INTO my-table".
          " VALUES".
          " ('row1', --6)"
      ::
      :+  ~2012.5.3
          %db1
          "FROM my-table WHERE --3 < col2 SELECT *"
      ::
      :-  %results
          :~  [%action 'SELECT']
              :-  %result-set
                  :~  :-  %vector
                          :~  [%col1 [~.t 'row1']]
                              [%col2 [~.sd --6]]
                              ==
                      ==
              [%server-time ~2012.5.3]
              [%relation 'db1.dbo.my-table']
              [%schema-time ~2012.5.1]
              [%data-time ~2012.5.2]
              [%vector-count 1]
              ==
      ==
::
::  WHERE <literal> < <column> @sd equality (false)
++  test-lt-26
  =|  run=@ud
  %-  exec-2-1
  :*  run
      [~2012.4.30 %sys "CREATE DATABASE db1"]
      ::
      [~2012.5.1 %db1 create-sd-table]
      ::
      :+  ~2012.5.2
          %db1
          "INSERT INTO my-table".
          " VALUES".
          " ('row1', --3)"
      ::
      :+  ~2012.5.3
          %db1
          "FROM my-table WHERE --3 < col2 SELECT *"
      ::
      :-  %results
          :~  [%action 'SELECT']
              [%result-set ~]
              [%server-time ~2012.5.3]
              [%relation 'db1.dbo.my-table']
              [%schema-time ~2012.5.1]
              [%data-time ~2012.5.2]
              [%vector-count 0]
              ==
      ==
::
::  WHERE <literal> < <column> @sd greater (false)
++  test-lt-27
  =|  run=@ud
  %-  exec-2-1
  :*  run
      [~2012.4.30 %sys "CREATE DATABASE db1"]
      ::
      [~2012.5.1 %db1 create-sd-table]
      ::
      :+  ~2012.5.2
          %db1
          "INSERT INTO my-table".
          " VALUES".
          " ('row1', --3)"
      ::
      :+  ~2012.5.3
          %db1
          "FROM my-table WHERE --6 < col2 SELECT *"
      ::
      :-  %results
          :~  [%action 'SELECT']
              [%result-set ~]
              [%server-time ~2012.5.3]
              [%relation 'db1.dbo.my-table']
              [%schema-time ~2012.5.1]
              [%data-time ~2012.5.2]
              [%vector-count 0]
              ==
      ==
::
::  WHERE <column> < <column> @sd less (true)
++  test-lt-28
  =|  run=@ud
  %-  exec-2-1
  :*  run
      [~2012.4.30 %sys "CREATE DATABASE db1"]
      ::
      [~2012.5.1 %db1 create-sd-2col-table]
      ::
      :+  ~2012.5.2
          %db1
          "INSERT INTO my-table".
          " VALUES".
          " ('row1', --3, --6)"
      ::
      :+  ~2012.5.3
          %db1
          "FROM my-table WHERE col2 < col3 SELECT *"
      ::
      :-  %results
          :~  [%action 'SELECT']
              :-  %result-set
                  :~  :-  %vector
                          :~  [%col1 [~.t 'row1']]
                              [%col2 [~.sd --3]]
                              [%col3 [~.sd --6]]
                              ==
                      ==
              [%server-time ~2012.5.3]
              [%relation 'db1.dbo.my-table']
              [%schema-time ~2012.5.1]
              [%data-time ~2012.5.2]
              [%vector-count 1]
              ==
      ==
::
::  WHERE <column> < <column> @sd equality (false)
++  test-lt-29
  =|  run=@ud
  %-  exec-2-1
  :*  run
      [~2012.4.30 %sys "CREATE DATABASE db1"]
      ::
      [~2012.5.1 %db1 create-sd-2col-table]
      ::
      :+  ~2012.5.2
          %db1
          "INSERT INTO my-table".
          " VALUES".
          " ('row1', --3, --3)"
      ::
      :+  ~2012.5.3
          %db1
          "FROM my-table WHERE col2 < col3 SELECT *"
      ::
      :-  %results
          :~  [%action 'SELECT']
              [%result-set ~]
              [%server-time ~2012.5.3]
              [%relation 'db1.dbo.my-table']
              [%schema-time ~2012.5.1]
              [%data-time ~2012.5.2]
              [%vector-count 0]
              ==
      ==
::
::  WHERE <column> < <column> @sd greater (false)
++  test-lt-30
  =|  run=@ud
  %-  exec-2-1
  :*  run
      [~2012.4.30 %sys "CREATE DATABASE db1"]
      ::
      [~2012.5.1 %db1 create-sd-2col-table]
      ::
      :+  ~2012.5.2
          %db1
          "INSERT INTO my-table".
          " VALUES".
          " ('row1', --6, --3)"
      ::
      :+  ~2012.5.3
          %db1
          "FROM my-table WHERE col2 < col3 SELECT *"
      ::
      :-  %results
          :~  [%action 'SELECT']
              [%result-set ~]
              [%server-time ~2012.5.3]
              [%relation 'db1.dbo.my-table']
              [%schema-time ~2012.5.1]
              [%data-time ~2012.5.2]
              [%vector-count 0]
              ==
      ==
::
::  fail WHERE <column> < <literal> types differ
++  test-fail-lt-00
  =|  run=@ud
  %-  failon-3
  :*  run
      [~2012.4.30 %sys "CREATE DATABASE db1"]
      ::
      [~2012.5.1 %db1 create-mytable]
      ::
      :+  ~2012.5.2
          %db1
          "INSERT INTO my-table".
          " VALUES".
          " ('Abby', ~1999.2.19, 'tricolor', 'row1')".
          " ('Ace', ~2005.12.19, 'ticolor', 'row2')".
          " ('Angel', ~2001.9.19, 'Angel', 'row3')"
      ::
      :+  ~2012.5.2
          %db1
          "FROM my-table WHERE col1 < ~1999.2.19 SELECT *"
      ::
      %-  crip
          "comparing column to literal of different aura: %col1 type=~.t ".
          "[p=~.da q=170.141.184.492.111.779.796.175.933.613.172.326.400]"
      ==
::
::  fail WHERE <literal> < <column> types differ
++  test-fail-lt-01
  =|  run=@ud
  %-  failon-3
  :*  run
      [~2012.4.30 %sys "CREATE DATABASE db1"]
      ::
      [~2012.5.1 %db1 create-mytable]
      ::
      :+  ~2012.5.2
          %db1
          "INSERT INTO my-table".
          " VALUES".
          " ('Abby', ~1999.2.19, 'tricolor', 'row1')".
          " ('Ace', ~2005.12.19, 'ticolor', 'row2')".
          " ('Angel', ~2001.9.19, 'Angel', 'row3')"
      ::
      :+  ~2012.5.2
          %db1
          "FROM my-table WHERE ~1999.2.19 < col1 SELECT *"
      ::
      %-  crip
          "comparing literal to column of different aura: ".
          "[p=~.da q=170.141.184.492.111.779.796.175.933.613.172.326.400] ".
          "%col1 type=~.t"
      ==
::
::  fail WHERE <column> < <column> types differ
++  test-fail-lt-02
  =|  run=@ud
  %-  failon-3
  :*  run
      [~2012.4.30 %sys "CREATE DATABASE db1"]
      ::
      [~2012.5.1 %db1 create-mytable]
      ::
      :+  ~2012.5.2
          %db1
          "INSERT INTO my-table".
          " VALUES".
          " ('Abby', ~1999.2.19, 'tricolor', 'row1')".
          " ('Ace', ~2005.12.19, 'ticolor', 'row2')".
          " ('Angel', ~2001.9.19, 'Angel', 'row3')"
      ::
      :+  ~2012.5.2
          %db1
          "FROM my-table WHERE col1 < col2 SELECT *"
      ::
      %-  crip
          "comparing columns of different auras: %col1 type=~.t %col2 type=~.da"
      ==
::
::  WHERE <column> < <literal> (cord) joined
++  test-lt-joined-00
  =|  run=@ud
  %-  exec-2-1
  :*  run
      [~2012.4.30 %sys "CREATE DATABASE db1"]
      ::
      [~2012.5.1 %db1 create-joined-tables]
      ::
      :+  ~2012.5.2
          %db1
          "INSERT INTO my-table".
          " VALUES".
          " ('Abby', ~1999.2.19)".
          " ('Ace', ~2005.12.19)".
          " ('Angel', ~2001.9.19); ".
          "INSERT INTO my-table-2".
          " VALUES".
          " ('Abby', 'tricolor', 'row1')".
          " ('Ace', 'ticolor', 'row2')".
          " ('Angel', 'tuxedo', 'row3')"
      ::
      :+  ~2012.5.3
          %db1
          "FROM my-table T1 JOIN my-table-2 T2 ".
          "WHERE col3 < 'toledo' SELECT T1.*, T2.col3, T2.col4"
      ::
      :-  %results
          :~  [%action 'SELECT']
              :-  %result-set
                  :~  :-  %vector
                          :~  [%col1 [~.t 'Ace']]
                              [%col2 [~.da ~2005.12.19]]
                              [%col3 [~.t 'ticolor']]
                              [%col4 [~.t 'row2']]
                              ==
                      ==
              [%server-time ~2012.5.3]
              [%relation 'db1.dbo.my-table']
              [%schema-time ~2012.5.1]
              [%data-time ~2012.5.2]
              [%relation 'db1.dbo.my-table-2']
              [%schema-time ~2012.5.1]
              [%data-time ~2012.5.2]
              [%vector-count 1]
              ==
      ==
::
::  WHERE <column> < <literal> (@da) joined
++  test-lt-joined-01
  =|  run=@ud
  %-  exec-2-1
  :*  run
      [~2012.4.30 %sys "CREATE DATABASE db1"]
      ::
      [~2012.5.1 %db1 create-joined-tables]
      ::
      :+  ~2012.5.2
          %db1
          "INSERT INTO my-table".
          " VALUES".
          " ('Abby', ~1999.2.19)".
          " ('Ace', ~2005.12.19)".
          " ('Angel', ~2001.9.19); ".
          "INSERT INTO my-table-2".
          " VALUES".
          " ('Abby', 'tricolor', 'row1')".
          " ('Ace', 'ticolor', 'row2')".
          " ('Angel', 'tuxedo', 'row3')"
      ::
      :+  ~2012.5.3
          %db1
          "FROM my-table T1 JOIN my-table-2 T2 ".
          "WHERE col2 < ~2001.9.19 SELECT T1.*, T2.col3, T2.col4"
      ::
      :-  %results
          :~  [%action 'SELECT']
              :-  %result-set
                  :~  :-  %vector
                          :~  [%col1 [~.t 'Abby']]
                              [%col2 [~.da ~1999.2.19]]
                              [%col3 [~.t 'tricolor']]
                              [%col4 [~.t 'row1']]
                              ==
                      ==
              [%server-time ~2012.5.3]
              [%relation 'db1.dbo.my-table']
              [%schema-time ~2012.5.1]
              [%data-time ~2012.5.2]
              [%relation 'db1.dbo.my-table-2']
              [%schema-time ~2012.5.1]
              [%data-time ~2012.5.2]
              [%vector-count 1]
              ==
      ==
::
::  WHERE <literal> < <column>  (cord) joined
++  test-lt-joined-02
  =|  run=@ud
  %-  exec-2-1
  :*  run
      [~2012.4.30 %sys "CREATE DATABASE db1"]
      ::
      [~2012.5.1 %db1 create-joined-tables]
      ::
      :+  ~2012.5.2
          %db1
          "INSERT INTO my-table".
          " VALUES".
          " ('Abby', ~1999.2.19)".
          " ('Ace', ~2005.12.19)".
          " ('Angel', ~2001.9.19); ".
          "INSERT INTO my-table-2".
          " VALUES".
          " ('Abby', 'tricolor', 'row1')".
          " ('Ace', 'ticolor', 'row2')".
          " ('Angel', 'tuxedo', 'row3')"
      ::
      :+  ~2012.5.3
          %db1
          "FROM my-table T1 JOIN my-table-2 T2 ".
          "WHERE 'tricolor' < col3 SELECT T1.*, T2.col3, T2.col4"
      ::
      :-  %results
          :~  [%action 'SELECT']
              :-  %result-set
                  :~  :-  %vector
                          :~  [%col1 [~.t 'Angel']]
                              [%col2 [~.da ~2001.9.19]]
                              [%col3 [~.t 'tuxedo']]
                              [%col4 [~.t 'row3']]
                              ==
                      ==
              [%server-time ~2012.5.3]
              [%relation 'db1.dbo.my-table']
              [%schema-time ~2012.5.1]
              [%data-time ~2012.5.2]
              [%relation 'db1.dbo.my-table-2']
              [%schema-time ~2012.5.1]
              [%data-time ~2012.5.2]
              [%vector-count 1]
              ==
      ==
::
::  WHERE <column> < <column>  (cord) joined
++  test-lt-joined-03
  =|  run=@ud
  %-  exec-2-1
  :*  run
      [~2012.4.30 %sys "CREATE DATABASE db1"]
      ::
      [~2012.5.1 %db1 create-joined-tables]
      ::
      :+  ~2012.5.2
          %db1
          "INSERT INTO my-table".
          " VALUES".
          " ('Abby', ~1999.2.19)".
          " ('Ace', ~2005.12.19)".
          " ('Angel', ~2001.9.19); ".
          "INSERT INTO my-table-2".
          " VALUES".
          " ('Abby', 'tricolor', 'row1')".
          " ('Ace', 'ticolor', 'row2')".
          " ('Angel', 'Angel', 'row3')"
      ::
      :+  ~2012.5.3
          %db1
          "FROM my-table T1 JOIN my-table-2 T2 ".
          "WHERE T1.col1 < col3 SELECT T1.*, T2.col3, T2.col4"
      ::
      :-  %results
          :~  [%action 'SELECT']
              :-  %result-set
                  :~  :-  %vector
                          :~  [%col1 [~.t 'Ace']]
                              [%col2 [~.da ~2005.12.19]]
                              [%col3 [~.t 'ticolor']]
                              [%col4 [~.t 'row2']]
                              ==
                      :-  %vector
                          :~  [%col1 [~.t 'Abby']]
                              [%col2 [~.da ~1999.2.19]]
                              [%col3 [~.t 'tricolor']]
                              [%col4 [~.t 'row1']]
                              ==
                      ==
              [%server-time ~2012.5.3]
              [%relation 'db1.dbo.my-table']
              [%schema-time ~2012.5.1]
              [%data-time ~2012.5.2]
              [%relation 'db1.dbo.my-table-2']
              [%schema-time ~2012.5.1]
              [%data-time ~2012.5.2]
              [%vector-count 2]
              ==
      ==
::
::  WHERE <column> < <literal> (cord) joined
++  test-lt-joined-04
  =|  run=@ud
  %-  exec-2-1
  :*  run
      [~2012.4.30 %sys "CREATE DATABASE db1"]
      ::
      [~2012.5.1 %db1 create-joined-tables]
      ::
      :+  ~2012.5.2
          %db1
          "INSERT INTO my-table".
          " VALUES".
          " ('Abby', ~1999.2.19)".
          " ('Ace', ~2005.12.19)".
          " ('Angel', ~2001.9.19); ".
          "INSERT INTO my-table-2".
          " VALUES".
          " ('Abby', 'tricolor', 'row1')".
          " ('Ace', 'ticolor', 'row2')".
          " ('Angel', 'tuxedo', 'row3')"
      ::
      :+  ~2012.5.3
          %db1
          "FROM my-table t1 JOIN my-table-2 T2 ".
          "WHERE t1.col1 < 'Angel' SELECT T1.*, T2.col3, T2.col4"
      ::
      :-  %results
          :~  [%action 'SELECT']
              :-  %result-set
                  :~  :-  %vector
                          :~  [%col1 [~.t 'Ace']]
                              [%col2 [~.da ~2005.12.19]]
                              [%col3 [~.t 'ticolor']]
                              [%col4 [~.t 'row2']]
                              ==
                      :-  %vector
                          :~  [%col1 [~.t 'Abby']]
                              [%col2 [~.da ~1999.2.19]]
                              [%col3 [~.t 'tricolor']]
                              [%col4 [~.t 'row1']]
                              ==
                      ==
              [%server-time ~2012.5.3]
              [%relation 'db1.dbo.my-table']
              [%schema-time ~2012.5.1]
              [%data-time ~2012.5.2]
              [%relation 'db1.dbo.my-table-2']
              [%schema-time ~2012.5.1]
              [%data-time ~2012.5.2]
              [%vector-count 2]
              ==
      ==
::
::  fail WHERE <column> < <literal> types differ joined
++  test-fail-lt-joined-00
  =|  run=@ud
  %-  failon-3
  :*  run
      [~2012.4.30 %sys "CREATE DATABASE db1"]
      ::
      [~2012.5.1 %db1 create-joined-tables]
      ::
      :+  ~2012.5.2
          %db1
          "INSERT INTO my-table".
          " VALUES".
          " ('Abby', ~1999.2.19)".
          " ('Ace', ~2005.12.19)".
          " ('Angel', ~2001.9.19); ".
          "INSERT INTO my-table-2".
          " VALUES".
          " ('Abby', 'tricolor', 'row1')".
          " ('Ace', 'ticolor', 'row2')".
          " ('Angel', 'Angel', 'row3')"
      ::
      :+  ~2012.5.2
          %db1
          "FROM my-table T1 JOIN my-table-2 T2 ".
          "WHERE t1.col1 < ~1999.2.19 SELECT T1.*, T2.col3, T2.col4"
      ::
      %-  crip
          "comparing column to literal of different aura: %col1 type=~.t ".
          "[p=~.da q=170.141.184.492.111.779.796.175.933.613.172.326.400]"
      ==
::
::  fail WHERE <literal> < <column> types differ joined
++  test-fail-lt-joined-01
  =|  run=@ud
  %-  failon-3
  :*  run
      [~2012.4.30 %sys "CREATE DATABASE db1"]
      ::
      [~2012.5.1 %db1 create-joined-tables]
      ::
      :+  ~2012.5.2
          %db1
          "INSERT INTO my-table".
          " VALUES".
          " ('Abby', ~1999.2.19)".
          " ('Ace', ~2005.12.19)".
          " ('Angel', ~2001.9.19); ".
          "INSERT INTO my-table-2".
          " VALUES".
          " ('Abby', 'tricolor', 'row1')".
          " ('Ace', 'ticolor', 'row2')".
          " ('Angel', 'Angel', 'row3')"
      ::
      :+  ~2012.5.2
          %db1
          "FROM my-table T1 JOIN my-table-2 T2 ".
          "WHERE ~1999.2.19 < t1.col1 SELECT T1.*, T2.col3, T2.col4"
      ::
      %-  crip
          "comparing literal to column of different aura: ".
          "[p=~.da q=170.141.184.492.111.779.796.175.933.613.172.326.400] ".
          "%col1 type=~.t"
      ==
::
::  fail WHERE <column> < <column> types differ joined
++  test-fail-lt-joined-02
  =|  run=@ud
  %-  failon-3
  :*  run
      [~2012.4.30 %sys "CREATE DATABASE db1"]
      ::
      [~2012.5.1 %db1 create-joined-tables]
      ::
      :+  ~2012.5.2
          %db1
          "INSERT INTO my-table".
          " VALUES".
          " ('Abby', ~1999.2.19)".
          " ('Ace', ~2005.12.19)".
          " ('Angel', ~2001.9.19); ".
          "INSERT INTO my-table-2".
          " VALUES".
          " ('Abby', 'tricolor', 'row1')".
          " ('Ace', 'ticolor', 'row2')".
          " ('Angel', 'Angel', 'row3')"
      ::
      :+  ~2012.5.2
          %db1
          "FROM my-table T1 JOIN my-table-2 T2 ".
          "WHERE t1.col1 < col2 SELECT T1.*, T2.col3, T2.col4"
      ::
      %-  crip
          "comparing columns of different auras: %col1 type=~.t %col2 type=~.da"
      ==
::
::  GTE
::
::  WHERE <column> >= <literal> (cord)
++  test-gte-00
  =|  run=@ud
  %-  exec-2-1
  :*  run
      [~2012.4.30 %sys "CREATE DATABASE db1"]
      ::
      [~2012.5.1 %db1 create-mytable]
      ::
      :+  ~2012.5.2
          %db1
          "INSERT INTO my-table".
          " VALUES".
          " ('Abby', ~1999.2.19, 'tricolor', 'row1')".
          " ('Ace', ~2005.12.19, 'ticolor', 'row2')".
          " ('Angel', ~2001.9.19, 'tuxedo', 'row3')"
      ::
      :+  ~2012.5.3
          %db1
          "FROM my-table WHERE col3 >= 'tricolor' SELECT *"
      ::
      :-  %results
          :~  [%action 'SELECT']
              :-  %result-set
                  :~  :-  %vector
                          :~  [%col1 [~.t 'Angel']]
                              [%col2 [~.da ~2001.9.19]]
                              [%col3 [~.t 'tuxedo']]
                              [%col4 [~.t 'row3']]
                              ==
                      :-  %vector
                          :~  [%col1 [~.t 'Abby']]
                              [%col2 [~.da ~1999.2.19]]
                              [%col3 [~.t 'tricolor']]
                              [%col4 [~.t 'row1']]
                              ==
                      ==
              [%server-time ~2012.5.3]
              [%relation 'db1.dbo.my-table']
              [%schema-time ~2012.5.1]
              [%data-time ~2012.5.2]
              [%vector-count 2]
              ==
      ==
::
::  WHERE <column> >= <literal> (@da)
++  test-gte-01
  =|  run=@ud
  %-  exec-2-1
  :*  run
      [~2012.4.30 %sys "CREATE DATABASE db1"]
      ::
      [~2012.5.1 %db1 create-mytable]
      ::
      :+  ~2012.5.2
          %db1
          "INSERT INTO my-table".
          " VALUES".
          " ('Abby', ~1999.2.19, 'tricolor', 'row1')".
          " ('Ace', ~2005.12.19, 'ticolor', 'row2')".
          " ('Angel', ~2001.9.19, 'tuxedo', 'row3')"
      ::
      :+  ~2012.5.3
          %db1
          "FROM my-table WHERE col2 >= ~1999.2.19 SELECT *"
      ::
      :-  %results
          :~  [%action 'SELECT']
              :-  %result-set
                  :~  :-  %vector
                          :~  [%col1 [~.t 'Ace']]
                              [%col2 [~.da ~2005.12.19]]
                              [%col3 [~.t 'ticolor']]
                              [%col4 [~.t 'row2']]
                              ==
                      :-  %vector
                          :~  [%col1 [~.t 'Angel']]
                              [%col2 [~.da ~2001.9.19]]
                              [%col3 [~.t 'tuxedo']]
                              [%col4 [~.t 'row3']]
                              ==
                      :-  %vector
                          :~  [%col1 [~.t 'Abby']]
                              [%col2 [~.da ~1999.2.19]]
                              [%col3 [~.t 'tricolor']]
                              [%col4 [~.t 'row1']]
                              ==
                      ==
              [%server-time ~2012.5.3]
              [%relation 'db1.dbo.my-table']
              [%schema-time ~2012.5.1]
              [%data-time ~2012.5.2]
              [%vector-count 3]
              ==
      ==
::
::  WHERE <literal> >= <column>  (cord)
++  test-gte-02
  =|  run=@ud
  %-  exec-2-1
  :*  run
      [~2012.4.30 %sys "CREATE DATABASE db1"]
      ::
      [~2012.5.1 %db1 create-mytable]
      ::
      :+  ~2012.5.2
          %db1
          "INSERT INTO my-table".
          " VALUES".
          " ('Abby', ~1999.2.19, 'tricolor', 'row1')".
          " ('Ace', ~2005.12.19, 'ticolor', 'row2')".
          " ('Angel', ~2001.9.19, 'tuxedo', 'row3')"
      ::
      :+  ~2012.5.3
          %db1
          "FROM my-table WHERE 'tricolor' >= col3 SELECT *"
      ::
      :-  %results
          :~  [%action 'SELECT']
              :-  %result-set
                  :~  :-  %vector
                          :~  [%col1 [~.t 'Ace']]
                              [%col2 [~.da ~2005.12.19]]
                              [%col3 [~.t 'ticolor']]
                              [%col4 [~.t 'row2']]
                              ==
                      :-  %vector
                          :~  [%col1 [~.t 'Abby']]
                              [%col2 [~.da ~1999.2.19]]
                              [%col3 [~.t 'tricolor']]
                              [%col4 [~.t 'row1']]
                              ==
                      ==
              [%server-time ~2012.5.3]
              [%relation 'db1.dbo.my-table']
              [%schema-time ~2012.5.1]
              [%data-time ~2012.5.2]
              [%vector-count 2]
              ==
      ==
::
::  WHERE <column> >= <column>  (cord)
++  test-gte-03
  =|  run=@ud
  %-  exec-2-1
  :*  run
      [~2012.4.30 %sys "CREATE DATABASE db1"]
      ::
      [~2012.5.1 %db1 create-mytable]
      ::
      :+  ~2012.5.2
          %db1
          "INSERT INTO my-table".
          " VALUES".
          " ('Abby', ~1999.2.19, 'tricolor', 'row1')".
          " ('Ace', ~2005.12.19, 'ticolor', 'row2')".
          " ('Angel', ~2001.9.19, 'Angel', 'row3')"
      ::
      :+  ~2012.5.3
          %db1
          "FROM my-table WHERE col3 >= col1 SELECT *"
      ::
      :-  %results
          :~  [%action 'SELECT']
              :-  %result-set
                  :~  :-  %vector
                          :~  [%col1 [~.t 'Angel']]
                              [%col2 [~.da ~2001.9.19]]
                              [%col3 [~.t 'Angel']]
                              [%col4 [~.t 'row3']]
                              ==
                      :-  %vector
                          :~  [%col1 [~.t 'Ace']]
                              [%col2 [~.da ~2005.12.19]]
                              [%col3 [~.t 'ticolor']]
                              [%col4 [~.t 'row2']]
                              ==
                      :-  %vector
                          :~  [%col1 [~.t 'Abby']]
                              [%col2 [~.da ~1999.2.19]]
                              [%col3 [~.t 'tricolor']]
                              [%col4 [~.t 'row1']]
                              ==
                      ==
              [%server-time ~2012.5.3]
              [%relation 'db1.dbo.my-table']
              [%schema-time ~2012.5.1]
              [%data-time ~2012.5.2]
              [%vector-count 3]
              ==
      ==
::
::  WHERE <column> >= <literal> (cord)
++  test-gte-04
  =|  run=@ud
  %-  exec-2-1
  :*  run
      [~2012.4.30 %sys "CREATE DATABASE db1"]
      ::
      :+  ~2012.5.1
          %db1
          "CREATE TABLE db1..my-table ".
          "(col1 @t, col2 @da, col3 @t, col4 @t) ".
          "PRIMARY KEY (col3)"
      ::
      :+  ~2012.5.2
          %db1
          "INSERT INTO my-table".
          " VALUES".
          " ('Abby', ~1999.2.19, 'tricolor', 'row1')".
          " ('Ace', ~2005.12.19, 'ticolor', 'row2')".
          " ('Angel', ~2001.9.19, 'tuxedo', 'row3')"
      ::
      :+  ~2012.5.3
          %db1
          "FROM my-table WHERE col1 >= 'Ace' SELECT *"
      ::
      :-  %results
          :~  [%action 'SELECT']
              :-  %result-set
                  :~  :-  %vector
                          :~  [%col1 [~.t 'Ace']]
                              [%col2 [~.da ~2005.12.19]]
                              [%col3 [~.t 'ticolor']]
                              [%col4 [~.t 'row2']]
                              ==
                      :-  %vector
                          :~  [%col1 [~.t 'Angel']]
                              [%col2 [~.da ~2001.9.19]]
                              [%col3 [~.t 'tuxedo']]
                              [%col4 [~.t 'row3']]
                              ==
                      ==
              [%server-time ~2012.5.3]
              [%relation 'db1.dbo.my-table']
              [%schema-time ~2012.5.1]
              [%data-time ~2012.5.2]
              [%vector-count 2]
              ==
      ==
::
::  view WHERE <column> >= <literal>
++  test-gte-05
  =|  run=@ud
  %-  exec-1-1
  :*  run
      [~2012.4.30 %sys "CREATE DATABASE db1"]
      ::
      [~2012.5.1 %db1 create-mytable]
      ::
      :+  ~2012.5.3
          %db1
          "FROM sys.columns WHERE 'col3' >= col-name SELECT *"
      ::
      :-  %results
          :~  [%action 'SELECT']
              :-  %result-set
                  :~  :-  %vector
                          :~  [p=%namespace q=[p=~.tas q=%dbo]]
                              [p=%name q=[p=~.tas q=%my-table]]
                              [p=%col-ordinal q=[p=~.ud q=2]]
                              [p=%col-name q=[p=~.tas q=%col2]]
                              [p=%col-type q=[p=~.ta q=~.da]]
                              ==
                      :-  %vector
                          :~  [p=%namespace q=[p=~.tas q=%dbo]]
                              [p=%name q=[p=~.tas q=%my-table]]
                              [p=%col-ordinal q=[p=~.ud q=1]]
                              [p=%col-name q=[p=~.tas q=%col1]]
                              [p=%col-type q=[p=~.ta q=~.t]]
                              ==
                      :-  %vector
                          :~  [p=%namespace q=[p=~.tas q=%dbo]]
                              [p=%name q=[p=~.tas q=%my-table]]
                              [p=%col-ordinal q=[p=~.ud q=3]]
                              [p=%col-name q=[p=~.tas q=%col3]]
                              [p=%col-type q=[p=~.ta q=~.t]]
                              ==
                      ==
              [%server-time ~2012.5.3]
              [%relation 'db1.sys.columns']
              [%schema-time ~2012.5.1]
              [%data-time ~2012.5.1]
              [%vector-count 3]
              ==
      ==
::
::  view WHERE <literal> >= <literal>
++  test-gte-06
  =|  run=@ud
  %-  exec-1-1
  :*  run
      [~2012.4.30 %sys "CREATE DATABASE db1"]
      ::
      [~2012.5.1 %db1 create-mytable]
      ::
      :+  ~2012.5.3
          %db1
          "FROM sys.columns WHERE 2 >= 1 SELECT *"
      ::
      :-  %results
          :~  [%action 'SELECT']
              :-  %result-set
                  :~  :-  %vector
                          :~  [p=%namespace q=[p=~.tas q=%dbo]]
                              [p=%name q=[p=~.tas q=%my-table]]
                              [p=%col-ordinal q=[p=~.ud q=2]]
                              [p=%col-name q=[p=~.tas q=%col2]]
                              [p=%col-type q=[p=~.ta q=~.da]]
                              ==
                      :-  %vector
                          :~  [p=%namespace q=[p=~.tas q=%dbo]]
                              [p=%name q=[p=~.tas q=%my-table]]
                              [p=%col-ordinal q=[p=~.ud q=1]]
                              [p=%col-name q=[p=~.tas q=%col1]]
                              [p=%col-type q=[p=~.ta q=~.t]]
                              ==
                      :-  %vector
                          :~  [p=%namespace q=[p=~.tas q=%dbo]]
                              [p=%name q=[p=~.tas q=%my-table]]
                              [p=%col-ordinal q=[p=~.ud q=4]]
                              [p=%col-name q=[p=~.tas q=%col4]]
                              [p=%col-type q=[p=~.ta q=~.t]]
                              ==
                      :-  %vector
                          :~  [p=%namespace q=[p=~.tas q=%dbo]]
                              [p=%name q=[p=~.tas q=%my-table]]
                              [p=%col-ordinal q=[p=~.ud q=3]]
                              [p=%col-name q=[p=~.tas q=%col3]]
                              [p=%col-type q=[p=~.ta q=~.t]]
                              ==
                      ==
              [%server-time ~2012.5.3]
              [%relation 'db1.sys.columns']
              [%schema-time ~2012.5.1]
              [%data-time ~2012.5.1]
              [%vector-count 4]
              ==
      ==
::
::  WHERE <literal> >= <literal> @rd equality (true)
++  test-gte-07
  =|  run=@ud
  %-  exec-2-1
  :*  run
      [~2012.4.30 %sys "CREATE DATABASE db1"]
      ::
      [~2012.5.1 %db1 create-rd-table]
      ::
      :+  ~2012.5.2
          %db1
          "INSERT INTO my-table".
          " VALUES".
          " ('row1', .~3.14)"
      ::
      :+  ~2012.5.3
          %db1
          "FROM my-table WHERE .~3.14 >= .~3.14 SELECT *"
      ::
      :-  %results
          :~  [%action 'SELECT']
              :-  %result-set
                  :~  :-  %vector
                          :~  [%col1 [~.t 'row1']]
                              [%col2 [~.rd .~3.14]]
                              ==
                      ==
              [%server-time ~2012.5.3]
              [%relation 'db1.dbo.my-table']
              [%schema-time ~2012.5.1]
              [%data-time ~2012.5.2]
              [%vector-count 1]
              ==
      ==
::
::  WHERE <literal> >= <literal> @rd greater (true)
++  test-gte-08
  =|  run=@ud
  %-  exec-2-1
  :*  run
      [~2012.4.30 %sys "CREATE DATABASE db1"]
      ::
      [~2012.5.1 %db1 create-rd-table]
      ::
      :+  ~2012.5.2
          %db1
          "INSERT INTO my-table".
          " VALUES".
          " ('row1', .~3.14)"
      ::
      :+  ~2012.5.3
          %db1
          "FROM my-table WHERE .~6.02 >= .~3.14 SELECT *"
      ::
      :-  %results
          :~  [%action 'SELECT']
              :-  %result-set
                  :~  :-  %vector
                          :~  [%col1 [~.t 'row1']]
                              [%col2 [~.rd .~3.14]]
                              ==
                      ==
              [%server-time ~2012.5.3]
              [%relation 'db1.dbo.my-table']
              [%schema-time ~2012.5.1]
              [%data-time ~2012.5.2]
              [%vector-count 1]
              ==
      ==
::
::  WHERE <literal> >= <literal> @rd less (false)
++  test-gte-09
  =|  run=@ud
  %-  exec-2-1
  :*  run
      [~2012.4.30 %sys "CREATE DATABASE db1"]
      ::
      [~2012.5.1 %db1 create-rd-table]
      ::
      :+  ~2012.5.2
          %db1
          "INSERT INTO my-table".
          " VALUES".
          " ('row1', .~3.14)"
      ::
      :+  ~2012.5.3
          %db1
          "FROM my-table WHERE .~3.14 >= .~6.02 SELECT *"
      ::
      :-  %results
          :~  [%action 'SELECT']
              [%result-set ~]
              [%server-time ~2012.5.3]
              [%relation 'db1.dbo.my-table']
              [%schema-time ~2012.5.1]
              [%data-time ~2012.5.2]
              [%vector-count 0]
              ==
      ==
::
::  WHERE <column> >= <literal> @rd equality (true)
++  test-gte-10
  =|  run=@ud
  %-  exec-2-1
  :*  run
      [~2012.4.30 %sys "CREATE DATABASE db1"]
      ::
      [~2012.5.1 %db1 create-rd-table]
      ::
      :+  ~2012.5.2
          %db1
          "INSERT INTO my-table".
          " VALUES".
          " ('row1', .~3.14)"
      ::
      :+  ~2012.5.3
          %db1
          "FROM my-table WHERE col2 >= .~3.14 SELECT *"
      ::
      :-  %results
          :~  [%action 'SELECT']
              :-  %result-set
                  :~  :-  %vector
                          :~  [%col1 [~.t 'row1']]
                              [%col2 [~.rd .~3.14]]
                              ==
                      ==
              [%server-time ~2012.5.3]
              [%relation 'db1.dbo.my-table']
              [%schema-time ~2012.5.1]
              [%data-time ~2012.5.2]
              [%vector-count 1]
              ==
      ==
::
::  WHERE <column> >= <literal> @rd greater (true)
++  test-gte-11
  =|  run=@ud
  %-  exec-2-1
  :*  run
      [~2012.4.30 %sys "CREATE DATABASE db1"]
      ::
      [~2012.5.1 %db1 create-rd-table]
      ::
      :+  ~2012.5.2
          %db1
          "INSERT INTO my-table".
          " VALUES".
          " ('row1', .~6.02)"
      ::
      :+  ~2012.5.3
          %db1
          "FROM my-table WHERE col2 >= .~3.14 SELECT *"
      ::
      :-  %results
          :~  [%action 'SELECT']
              :-  %result-set
                  :~  :-  %vector
                          :~  [%col1 [~.t 'row1']]
                              [%col2 [~.rd .~6.02]]
                              ==
                      ==
              [%server-time ~2012.5.3]
              [%relation 'db1.dbo.my-table']
              [%schema-time ~2012.5.1]
              [%data-time ~2012.5.2]
              [%vector-count 1]
              ==
      ==
::
::  WHERE <column> >= <literal> @rd less (false)
++  test-gte-12
  =|  run=@ud
  %-  exec-2-1
  :*  run
      [~2012.4.30 %sys "CREATE DATABASE db1"]
      ::
      [~2012.5.1 %db1 create-rd-table]
      ::
      :+  ~2012.5.2
          %db1
          "INSERT INTO my-table".
          " VALUES".
          " ('row1', .~3.14)"
      ::
      :+  ~2012.5.3
          %db1
          "FROM my-table WHERE col2 >= .~6.02 SELECT *"
      ::
      :-  %results
          :~  [%action 'SELECT']
              [%result-set ~]
              [%server-time ~2012.5.3]
              [%relation 'db1.dbo.my-table']
              [%schema-time ~2012.5.1]
              [%data-time ~2012.5.2]
              [%vector-count 0]
              ==
      ==
::
::  WHERE <literal> >= <column> @rd equality (true)
++  test-gte-13
  =|  run=@ud
  %-  exec-2-1
  :*  run
      [~2012.4.30 %sys "CREATE DATABASE db1"]
      ::
      [~2012.5.1 %db1 create-rd-table]
      ::
      :+  ~2012.5.2
          %db1
          "INSERT INTO my-table".
          " VALUES".
          " ('row1', .~3.14)"
      ::
      :+  ~2012.5.3
          %db1
          "FROM my-table WHERE .~3.14 >= col2 SELECT *"
      ::
      :-  %results
          :~  [%action 'SELECT']
              :-  %result-set
                  :~  :-  %vector
                          :~  [%col1 [~.t 'row1']]
                              [%col2 [~.rd .~3.14]]
                              ==
                      ==
              [%server-time ~2012.5.3]
              [%relation 'db1.dbo.my-table']
              [%schema-time ~2012.5.1]
              [%data-time ~2012.5.2]
              [%vector-count 1]
              ==
      ==
::
::  WHERE <literal> >= <column> @rd greater (true)
++  test-gte-14
  =|  run=@ud
  %-  exec-2-1
  :*  run
      [~2012.4.30 %sys "CREATE DATABASE db1"]
      ::
      [~2012.5.1 %db1 create-rd-table]
      ::
      :+  ~2012.5.2
          %db1
          "INSERT INTO my-table".
          " VALUES".
          " ('row1', .~3.14)"
      ::
      :+  ~2012.5.3
          %db1
          "FROM my-table WHERE .~6.02 >= col2 SELECT *"
      ::
      :-  %results
          :~  [%action 'SELECT']
              :-  %result-set
                  :~  :-  %vector
                          :~  [%col1 [~.t 'row1']]
                              [%col2 [~.rd .~3.14]]
                              ==
                      ==
              [%server-time ~2012.5.3]
              [%relation 'db1.dbo.my-table']
              [%schema-time ~2012.5.1]
              [%data-time ~2012.5.2]
              [%vector-count 1]
              ==
      ==
::
::  WHERE <literal> >= <column> @rd less (false)
++  test-gte-15
  =|  run=@ud
  %-  exec-2-1
  :*  run
      [~2012.4.30 %sys "CREATE DATABASE db1"]
      ::
      [~2012.5.1 %db1 create-rd-table]
      ::
      :+  ~2012.5.2
          %db1
          "INSERT INTO my-table".
          " VALUES".
          " ('row1', .~6.02)"
      ::
      :+  ~2012.5.3
          %db1
          "FROM my-table WHERE .~3.14 >= col2 SELECT *"
      ::
      :-  %results
          :~  [%action 'SELECT']
              [%result-set ~]
              [%server-time ~2012.5.3]
              [%relation 'db1.dbo.my-table']
              [%schema-time ~2012.5.1]
              [%data-time ~2012.5.2]
              [%vector-count 0]
              ==
      ==
::
::  WHERE <column> >= <column> @rd equality (true)
++  test-gte-16
  =|  run=@ud
  %-  exec-2-1
  :*  run
      [~2012.4.30 %sys "CREATE DATABASE db1"]
      ::
      [~2012.5.1 %db1 create-rd-2col-table]
      ::
      :+  ~2012.5.2
          %db1
          "INSERT INTO my-table".
          " VALUES".
          " ('row1', .~3.14, .~3.14)"
      ::
      :+  ~2012.5.3
          %db1
          "FROM my-table WHERE col2 >= col3 SELECT *"
      ::
      :-  %results
          :~  [%action 'SELECT']
              :-  %result-set
                  :~  :-  %vector
                          :~  [%col1 [~.t 'row1']]
                              [%col2 [~.rd .~3.14]]
                              [%col3 [~.rd .~3.14]]
                              ==
                      ==
              [%server-time ~2012.5.3]
              [%relation 'db1.dbo.my-table']
              [%schema-time ~2012.5.1]
              [%data-time ~2012.5.2]
              [%vector-count 1]
              ==
      ==
::
::  WHERE <column> >= <column> @rd greater (true)
++  test-gte-17
  =|  run=@ud
  %-  exec-2-1
  :*  run
      [~2012.4.30 %sys "CREATE DATABASE db1"]
      ::
      [~2012.5.1 %db1 create-rd-2col-table]
      ::
      :+  ~2012.5.2
          %db1
          "INSERT INTO my-table".
          " VALUES".
          " ('row1', .~6.02, .~3.14)"
      ::
      :+  ~2012.5.3
          %db1
          "FROM my-table WHERE col2 >= col3 SELECT *"
      ::
      :-  %results
          :~  [%action 'SELECT']
              :-  %result-set
                  :~  :-  %vector
                          :~  [%col1 [~.t 'row1']]
                              [%col2 [~.rd .~6.02]]
                              [%col3 [~.rd .~3.14]]
                              ==
                      ==
              [%server-time ~2012.5.3]
              [%relation 'db1.dbo.my-table']
              [%schema-time ~2012.5.1]
              [%data-time ~2012.5.2]
              [%vector-count 1]
              ==
      ==
::
::  WHERE <column> >= <column> @rd less (false)
++  test-gte-18
  =|  run=@ud
  %-  exec-2-1
  :*  run
      [~2012.4.30 %sys "CREATE DATABASE db1"]
      ::
      [~2012.5.1 %db1 create-rd-2col-table]
      ::
      :+  ~2012.5.2
          %db1
          "INSERT INTO my-table".
          " VALUES".
          " ('row1', .~3.14, .~6.02)"
      ::
      :+  ~2012.5.3
          %db1
          "FROM my-table WHERE col2 >= col3 SELECT *"
      ::
      :-  %results
          :~  [%action 'SELECT']
              [%result-set ~]
              [%server-time ~2012.5.3]
              [%relation 'db1.dbo.my-table']
              [%schema-time ~2012.5.1]
              [%data-time ~2012.5.2]
              [%vector-count 0]
              ==
      ==
::
::  WHERE <literal> >= <literal> @sd equality (true)
++  test-gte-19
  =|  run=@ud
  %-  exec-2-1
  :*  run
      [~2012.4.30 %sys "CREATE DATABASE db1"]
      ::
      [~2012.5.1 %db1 create-sd-table]
      ::
      :+  ~2012.5.2
          %db1
          "INSERT INTO my-table".
          " VALUES".
          " ('row1', --3)"
      ::
      :+  ~2012.5.3
          %db1
          "FROM my-table WHERE --3 >= --3 SELECT *"
      ::
      :-  %results
          :~  [%action 'SELECT']
              :-  %result-set
                  :~  :-  %vector
                          :~  [%col1 [~.t 'row1']]
                              [%col2 [~.sd --3]]
                              ==
                      ==
              [%server-time ~2012.5.3]
              [%relation 'db1.dbo.my-table']
              [%schema-time ~2012.5.1]
              [%data-time ~2012.5.2]
              [%vector-count 1]
              ==
      ==
::
::  WHERE <literal> >= <literal> @sd greater (true)
++  test-gte-20
  =|  run=@ud
  %-  exec-2-1
  :*  run
      [~2012.4.30 %sys "CREATE DATABASE db1"]
      ::
      [~2012.5.1 %db1 create-sd-table]
      ::
      :+  ~2012.5.2
          %db1
          "INSERT INTO my-table".
          " VALUES".
          " ('row1', --3)"
      ::
      :+  ~2012.5.3
          %db1
          "FROM my-table WHERE --6 >= --3 SELECT *"
      ::
      :-  %results
          :~  [%action 'SELECT']
              :-  %result-set
                  :~  :-  %vector
                          :~  [%col1 [~.t 'row1']]
                              [%col2 [~.sd --3]]
                              ==
                      ==
              [%server-time ~2012.5.3]
              [%relation 'db1.dbo.my-table']
              [%schema-time ~2012.5.1]
              [%data-time ~2012.5.2]
              [%vector-count 1]
              ==
      ==
::
::  WHERE <literal> >= <literal> @sd less (false)
++  test-gte-21
  =|  run=@ud
  %-  exec-2-1
  :*  run
      [~2012.4.30 %sys "CREATE DATABASE db1"]
      ::
      [~2012.5.1 %db1 create-sd-table]
      ::
      :+  ~2012.5.2
          %db1
          "INSERT INTO my-table".
          " VALUES".
          " ('row1', --3)"
      ::
      :+  ~2012.5.3
          %db1
          "FROM my-table WHERE --3 >= --6 SELECT *"
      ::
      :-  %results
          :~  [%action 'SELECT']
              [%result-set ~]
              [%server-time ~2012.5.3]
              [%relation 'db1.dbo.my-table']
              [%schema-time ~2012.5.1]
              [%data-time ~2012.5.2]
              [%vector-count 0]
              ==
      ==
::
::  WHERE <column> >= <literal> @sd equality (true)
++  test-gte-22
  =|  run=@ud
  %-  exec-2-1
  :*  run
      [~2012.4.30 %sys "CREATE DATABASE db1"]
      ::
      [~2012.5.1 %db1 create-sd-table]
      ::
      :+  ~2012.5.2
          %db1
          "INSERT INTO my-table".
          " VALUES".
          " ('row1', --3)"
      ::
      :+  ~2012.5.3
          %db1
          "FROM my-table WHERE col2 >= --3 SELECT *"
      ::
      :-  %results
          :~  [%action 'SELECT']
              :-  %result-set
                  :~  :-  %vector
                          :~  [%col1 [~.t 'row1']]
                              [%col2 [~.sd --3]]
                              ==
                      ==
              [%server-time ~2012.5.3]
              [%relation 'db1.dbo.my-table']
              [%schema-time ~2012.5.1]
              [%data-time ~2012.5.2]
              [%vector-count 1]
              ==
      ==
::
::  WHERE <column> >= <literal> @sd greater (true)
++  test-gte-23
  =|  run=@ud
  %-  exec-2-1
  :*  run
      [~2012.4.30 %sys "CREATE DATABASE db1"]
      ::
      [~2012.5.1 %db1 create-sd-table]
      ::
      :+  ~2012.5.2
          %db1
          "INSERT INTO my-table".
          " VALUES".
          " ('row1', --6)"
      ::
      :+  ~2012.5.3
          %db1
          "FROM my-table WHERE col2 >= --3 SELECT *"
      ::
      :-  %results
          :~  [%action 'SELECT']
              :-  %result-set
                  :~  :-  %vector
                          :~  [%col1 [~.t 'row1']]
                              [%col2 [~.sd --6]]
                              ==
                      ==
              [%server-time ~2012.5.3]
              [%relation 'db1.dbo.my-table']
              [%schema-time ~2012.5.1]
              [%data-time ~2012.5.2]
              [%vector-count 1]
              ==
      ==
::
::  WHERE <column> >= <literal> @sd less (false)
++  test-gte-24
  =|  run=@ud
  %-  exec-2-1
  :*  run
      [~2012.4.30 %sys "CREATE DATABASE db1"]
      ::
      [~2012.5.1 %db1 create-sd-table]
      ::
      :+  ~2012.5.2
          %db1
          "INSERT INTO my-table".
          " VALUES".
          " ('row1', --3)"
      ::
      :+  ~2012.5.3
          %db1
          "FROM my-table WHERE col2 >= --6 SELECT *"
      ::
      :-  %results
          :~  [%action 'SELECT']
              [%result-set ~]
              [%server-time ~2012.5.3]
              [%relation 'db1.dbo.my-table']
              [%schema-time ~2012.5.1]
              [%data-time ~2012.5.2]
              [%vector-count 0]
              ==
      ==
::
::  WHERE <literal> >= <column> @sd equality (true)
++  test-gte-25
  =|  run=@ud
  %-  exec-2-1
  :*  run
      [~2012.4.30 %sys "CREATE DATABASE db1"]
      ::
      [~2012.5.1 %db1 create-sd-table]
      ::
      :+  ~2012.5.2
          %db1
          "INSERT INTO my-table".
          " VALUES".
          " ('row1', --3)"
      ::
      :+  ~2012.5.3
          %db1
          "FROM my-table WHERE --3 >= col2 SELECT *"
      ::
      :-  %results
          :~  [%action 'SELECT']
              :-  %result-set
                  :~  :-  %vector
                          :~  [%col1 [~.t 'row1']]
                              [%col2 [~.sd --3]]
                              ==
                      ==
              [%server-time ~2012.5.3]
              [%relation 'db1.dbo.my-table']
              [%schema-time ~2012.5.1]
              [%data-time ~2012.5.2]
              [%vector-count 1]
              ==
      ==
::
::  WHERE <literal> >= <column> @sd greater (true)
++  test-gte-26
  =|  run=@ud
  %-  exec-2-1
  :*  run
      [~2012.4.30 %sys "CREATE DATABASE db1"]
      ::
      [~2012.5.1 %db1 create-sd-table]
      ::
      :+  ~2012.5.2
          %db1
          "INSERT INTO my-table".
          " VALUES".
          " ('row1', --3)"
      ::
      :+  ~2012.5.3
          %db1
          "FROM my-table WHERE --6 >= col2 SELECT *"
      ::
      :-  %results
          :~  [%action 'SELECT']
              :-  %result-set
                  :~  :-  %vector
                          :~  [%col1 [~.t 'row1']]
                              [%col2 [~.sd --3]]
                              ==
                      ==
              [%server-time ~2012.5.3]
              [%relation 'db1.dbo.my-table']
              [%schema-time ~2012.5.1]
              [%data-time ~2012.5.2]
              [%vector-count 1]
              ==
      ==
::
::  WHERE <literal> >= <column> @sd less (false)
++  test-gte-27
  =|  run=@ud
  %-  exec-2-1
  :*  run
      [~2012.4.30 %sys "CREATE DATABASE db1"]
      ::
      [~2012.5.1 %db1 create-sd-table]
      ::
      :+  ~2012.5.2
          %db1
          "INSERT INTO my-table".
          " VALUES".
          " ('row1', --6)"
      ::
      :+  ~2012.5.3
          %db1
          "FROM my-table WHERE --3 >= col2 SELECT *"
      ::
      :-  %results
          :~  [%action 'SELECT']
              [%result-set ~]
              [%server-time ~2012.5.3]
              [%relation 'db1.dbo.my-table']
              [%schema-time ~2012.5.1]
              [%data-time ~2012.5.2]
              [%vector-count 0]
              ==
      ==
::
::  WHERE <column> >= <column> @sd equality (true)
++  test-gte-28
  =|  run=@ud
  %-  exec-2-1
  :*  run
      [~2012.4.30 %sys "CREATE DATABASE db1"]
      ::
      [~2012.5.1 %db1 create-sd-2col-table]
      ::
      :+  ~2012.5.2
          %db1
          "INSERT INTO my-table".
          " VALUES".
          " ('row1', --3, --3)"
      ::
      :+  ~2012.5.3
          %db1
          "FROM my-table WHERE col2 >= col3 SELECT *"
      ::
      :-  %results
          :~  [%action 'SELECT']
              :-  %result-set
                  :~  :-  %vector
                          :~  [%col1 [~.t 'row1']]
                              [%col2 [~.sd --3]]
                              [%col3 [~.sd --3]]
                              ==
                      ==
              [%server-time ~2012.5.3]
              [%relation 'db1.dbo.my-table']
              [%schema-time ~2012.5.1]
              [%data-time ~2012.5.2]
              [%vector-count 1]
              ==
      ==
::
::  WHERE <column> >= <column> @sd greater (true)
++  test-gte-29
  =|  run=@ud
  %-  exec-2-1
  :*  run
      [~2012.4.30 %sys "CREATE DATABASE db1"]
      ::
      [~2012.5.1 %db1 create-sd-2col-table]
      ::
      :+  ~2012.5.2
          %db1
          "INSERT INTO my-table".
          " VALUES".
          " ('row1', --6, --3)"
      ::
      :+  ~2012.5.3
          %db1
          "FROM my-table WHERE col2 >= col3 SELECT *"
      ::
      :-  %results
          :~  [%action 'SELECT']
              :-  %result-set
                  :~  :-  %vector
                          :~  [%col1 [~.t 'row1']]
                              [%col2 [~.sd --6]]
                              [%col3 [~.sd --3]]
                              ==
                      ==
              [%server-time ~2012.5.3]
              [%relation 'db1.dbo.my-table']
              [%schema-time ~2012.5.1]
              [%data-time ~2012.5.2]
              [%vector-count 1]
              ==
      ==
::
::  WHERE <column> >= <column> @sd less (false)
++  test-gte-30
  =|  run=@ud
  %-  exec-2-1
  :*  run
      [~2012.4.30 %sys "CREATE DATABASE db1"]
      ::
      [~2012.5.1 %db1 create-sd-2col-table]
      ::
      :+  ~2012.5.2
          %db1
          "INSERT INTO my-table".
          " VALUES".
          " ('row1', --3, --6)"
      ::
      :+  ~2012.5.3
          %db1
          "FROM my-table WHERE col2 >= col3 SELECT *"
      ::
      :-  %results
          :~  [%action 'SELECT']
              [%result-set ~]
              [%server-time ~2012.5.3]
              [%relation 'db1.dbo.my-table']
              [%schema-time ~2012.5.1]
              [%data-time ~2012.5.2]
              [%vector-count 0]
              ==
      ==
::
::  fail WHERE <column> >= <literal> types differ
++  test-fail-gte-00
  =|  run=@ud
  %-  failon-3
  :*  run
      [~2012.4.30 %sys "CREATE DATABASE db1"]
      ::
      [~2012.5.1 %db1 create-mytable]
      ::
      :+  ~2012.5.2
          %db1
          "INSERT INTO my-table".
          " VALUES".
          " ('Abby', ~1999.2.19, 'tricolor', 'row1')".
          " ('Ace', ~2005.12.19, 'ticolor', 'row2')".
          " ('Angel', ~2001.9.19, 'Angel', 'row3')"
      ::
      :+  ~2012.5.2
          %db1
          "FROM my-table WHERE col1 >= ~1999.2.19 SELECT *"
      ::
      %-  crip
          "comparing column to literal of different aura: %col1 type=~.t ".
          "[p=~.da q=170.141.184.492.111.779.796.175.933.613.172.326.400]"
      ==
::
::  fail WHERE <literal> >= <column> types differ
++  test-fail-gte-01
  =|  run=@ud
  %-  failon-3
  :*  run
      [~2012.4.30 %sys "CREATE DATABASE db1"]
      ::
      [~2012.5.1 %db1 create-mytable]
      ::
      :+  ~2012.5.2
          %db1
          "INSERT INTO my-table".
          " VALUES".
          " ('Abby', ~1999.2.19, 'tricolor', 'row1')".
          " ('Ace', ~2005.12.19, 'ticolor', 'row2')".
          " ('Angel', ~2001.9.19, 'Angel', 'row3')"
      ::
      :+  ~2012.5.2
          %db1
          "FROM my-table WHERE ~1999.2.19 >= col1 SELECT *"
      ::
      %-  crip
          "comparing literal to column of different aura: ".
          "[p=~.da q=170.141.184.492.111.779.796.175.933.613.172.326.400] ".
          "%col1 type=~.t"
      ==
::
::  fail WHERE <column> >= <column> types differ
++  test-fail-gte-02
  =|  run=@ud
  %-  failon-3
  :*  run
      [~2012.4.30 %sys "CREATE DATABASE db1"]
      ::
      [~2012.5.1 %db1 create-mytable]
      ::
      :+  ~2012.5.2
          %db1
          "INSERT INTO my-table".
          " VALUES".
          " ('Abby', ~1999.2.19, 'tricolor', 'row1')".
          " ('Ace', ~2005.12.19, 'ticolor', 'row2')".
          " ('Angel', ~2001.9.19, 'Angel', 'row3')"
      ::
      :+  ~2012.5.2
          %db1
          "FROM my-table WHERE col1 >= col2 SELECT *"
      ::
      %-  crip
          "comparing columns of different auras: %col1 type=~.t %col2 type=~.da"
      ==
::
::  WHERE <column> >= <literal> (cord) joined
++  test-gte-joined-00
  =|  run=@ud
  %-  exec-2-1
  :*  run
      [~2012.4.30 %sys "CREATE DATABASE db1"]
      ::
      [~2012.5.1 %db1 create-joined-tables]
      ::
      :+  ~2012.5.2
          %db1
          "INSERT INTO my-table".
          " VALUES".
          " ('Abby', ~1999.2.19)".
          " ('Ace', ~2005.12.19)".
          " ('Angel', ~2001.9.19); ".
          "INSERT INTO my-table-2".
          " VALUES".
          " ('Abby', 'tricolor', 'row1')".
          " ('Ace', 'ticolor', 'row2')".
          " ('Angel', 'tuxedo', 'row3')"
      ::
      :+  ~2012.5.3
          %db1
          "FROM my-table T1 JOIN my-table-2 T2 ".
          "WHERE col3 >= 'tricolor' SELECT T1.*, T2.col3, T2.col4"
      ::
      :-  %results
          :~  [%action 'SELECT']
              :-  %result-set
                  :~  :-  %vector
                          :~  [%col1 [~.t 'Angel']]
                              [%col2 [~.da ~2001.9.19]]
                              [%col3 [~.t 'tuxedo']]
                              [%col4 [~.t 'row3']]
                              ==
                      :-  %vector
                          :~  [%col1 [~.t 'Abby']]
                              [%col2 [~.da ~1999.2.19]]
                              [%col3 [~.t 'tricolor']]
                              [%col4 [~.t 'row1']]
                              ==
                      ==
              [%server-time ~2012.5.3]
              [%relation 'db1.dbo.my-table']
              [%schema-time ~2012.5.1]
              [%data-time ~2012.5.2]
              [%relation 'db1.dbo.my-table-2']
              [%schema-time ~2012.5.1]
              [%data-time ~2012.5.2]
              [%vector-count 2]
              ==
      ==
::
::  WHERE <column> >= <literal> (@da) joined
++  test-gte-joined-01
  =|  run=@ud
  %-  exec-2-1
  :*  run
      [~2012.4.30 %sys "CREATE DATABASE db1"]
      ::
      [~2012.5.1 %db1 create-joined-tables]
      ::
      :+  ~2012.5.2
          %db1
          "INSERT INTO my-table".
          " VALUES".
          " ('Abby', ~1999.2.19)".
          " ('Ace', ~2005.12.19)".
          " ('Angel', ~2001.9.19); ".
          "INSERT INTO my-table-2".
          " VALUES".
          " ('Abby', 'tricolor', 'row1')".
          " ('Ace', 'ticolor', 'row2')".
          " ('Angel', 'tuxedo', 'row3')"
      ::
      :+  ~2012.5.3
          %db1
          "FROM my-table T1 JOIN my-table-2 T2 ".
          "WHERE col2 >= ~1999.2.19 SELECT T1.*, T2.col3, T2.col4"
      ::
      :-  %results
          :~  [%action 'SELECT']
              :-  %result-set
                  :~  :-  %vector
                          :~  [%col1 [~.t 'Ace']]
                              [%col2 [~.da ~2005.12.19]]
                              [%col3 [~.t 'ticolor']]
                              [%col4 [~.t 'row2']]
                              ==
                      :-  %vector
                          :~  [%col1 [~.t 'Angel']]
                              [%col2 [~.da ~2001.9.19]]
                              [%col3 [~.t 'tuxedo']]
                              [%col4 [~.t 'row3']]
                              ==
                      :-  %vector
                          :~  [%col1 [~.t 'Abby']]
                              [%col2 [~.da ~1999.2.19]]
                              [%col3 [~.t 'tricolor']]
                              [%col4 [~.t 'row1']]
                              ==
                      ==
              [%server-time ~2012.5.3]
              [%relation 'db1.dbo.my-table']
              [%schema-time ~2012.5.1]
              [%data-time ~2012.5.2]
              [%relation 'db1.dbo.my-table-2']
              [%schema-time ~2012.5.1]
              [%data-time ~2012.5.2]
              [%vector-count 3]
              ==
      ==
::
::  WHERE <literal> >= <column>  (cord) joined
++  test-gte-joined-02
  =|  run=@ud
  %-  exec-2-1
  :*  run
      [~2012.4.30 %sys "CREATE DATABASE db1"]
      ::
      [~2012.5.1 %db1 create-joined-tables]
      ::
      :+  ~2012.5.2
          %db1
          "INSERT INTO my-table".
          " VALUES".
          " ('Abby', ~1999.2.19)".
          " ('Ace', ~2005.12.19)".
          " ('Angel', ~2001.9.19); ".
          "INSERT INTO my-table-2".
          " VALUES".
          " ('Abby', 'tricolor', 'row1')".
          " ('Ace', 'ticolor', 'row2')".
          " ('Angel', 'tuxedo', 'row3')"
      ::
      :+  ~2012.5.3
          %db1
          "FROM my-table T1 JOIN my-table-2 T2 ".
          "WHERE 'tricolor' >= col3 SELECT T1.*, T2.col3, T2.col4"
      ::
      :-  %results
          :~  [%action 'SELECT']
              :-  %result-set
                  :~  :-  %vector
                          :~  [%col1 [~.t 'Ace']]
                              [%col2 [~.da ~2005.12.19]]
                              [%col3 [~.t 'ticolor']]
                              [%col4 [~.t 'row2']]
                              ==
                      :-  %vector
                          :~  [%col1 [~.t 'Abby']]
                              [%col2 [~.da ~1999.2.19]]
                              [%col3 [~.t 'tricolor']]
                              [%col4 [~.t 'row1']]
                              ==
                      ==
              [%server-time ~2012.5.3]
              [%relation 'db1.dbo.my-table']
              [%schema-time ~2012.5.1]
              [%data-time ~2012.5.2]
              [%relation 'db1.dbo.my-table-2']
              [%schema-time ~2012.5.1]
              [%data-time ~2012.5.2]
              [%vector-count 2]
              ==
      ==
::
::  WHERE <column> >= <column>  (cord) joined
++  test-gte-joined-03
  =|  run=@ud
  %-  exec-2-1
  :*  run
      [~2012.4.30 %sys "CREATE DATABASE db1"]
      ::
      [~2012.5.1 %db1 create-joined-tables]
      ::
      :+  ~2012.5.2
          %db1
          "INSERT INTO my-table".
          " VALUES".
          " ('Abby', ~1999.2.19)".
          " ('Ace', ~2005.12.19)".
          " ('Angel', ~2001.9.19); ".
          "INSERT INTO my-table-2".
          " VALUES".
          " ('Abby', 'tricolor', 'row1')".
          " ('Ace', 'ticolor', 'row2')".
          " ('Angel', 'Angel', 'row3')"
      ::
      :+  ~2012.5.3
          %db1
          "FROM my-table T1 JOIN my-table-2 T2 ".
          "WHERE col3 >= t1.col1 SELECT T1.*, T2.col3, T2.col4"
      ::
      :-  %results
          :~  [%action 'SELECT']
              :-  %result-set
                  :~  :-  %vector
                          :~  [%col1 [~.t 'Angel']]
                              [%col2 [~.da ~2001.9.19]]
                              [%col3 [~.t 'Angel']]
                              [%col4 [~.t 'row3']]
                              ==
                      :-  %vector
                          :~  [%col1 [~.t 'Ace']]
                              [%col2 [~.da ~2005.12.19]]
                              [%col3 [~.t 'ticolor']]
                              [%col4 [~.t 'row2']]
                              ==
                      :-  %vector
                          :~  [%col1 [~.t 'Abby']]
                              [%col2 [~.da ~1999.2.19]]
                              [%col3 [~.t 'tricolor']]
                              [%col4 [~.t 'row1']]
                              ==
                      ==
              [%server-time ~2012.5.3]
              [%relation 'db1.dbo.my-table']
              [%schema-time ~2012.5.1]
              [%data-time ~2012.5.2]
              [%relation 'db1.dbo.my-table-2']
              [%schema-time ~2012.5.1]
              [%data-time ~2012.5.2]
              [%vector-count 3]
              ==
      ==
::
::  WHERE <column> >= <literal> (cord) joined
++  test-gte-joined-04
  =|  run=@ud
  %-  exec-2-1
  :*  run
      [~2012.4.30 %sys "CREATE DATABASE db1"]
      ::
      [~2012.5.1 %db1 create-joined-tables]
      ::
      :+  ~2012.5.2
          %db1
          "INSERT INTO my-table".
          " VALUES".
          " ('Abby', ~1999.2.19)".
          " ('Ace', ~2005.12.19)".
          " ('Angel', ~2001.9.19); ".
          "INSERT INTO my-table-2".
          " VALUES".
          " ('Abby', 'tricolor', 'row1')".
          " ('Ace', 'ticolor', 'row2')".
          " ('Angel', 'tuxedo', 'row3')"
      ::
      :+  ~2012.5.3
          %db1
          "FROM my-table t1 JOIN my-table-2 T2 ".
          "WHERE t1.col1 >= 'Ace' SELECT T1.*, T2.col3, T2.col4"
      ::
      :-  %results
          :~  [%action 'SELECT']
              :-  %result-set
                  :~  :-  %vector
                          :~  [%col1 [~.t 'Ace']]
                              [%col2 [~.da ~2005.12.19]]
                              [%col3 [~.t 'ticolor']]
                              [%col4 [~.t 'row2']]
                              ==
                      :-  %vector
                          :~  [%col1 [~.t 'Angel']]
                              [%col2 [~.da ~2001.9.19]]
                              [%col3 [~.t 'tuxedo']]
                              [%col4 [~.t 'row3']]
                              ==
                      ==
              [%server-time ~2012.5.3]
              [%relation 'db1.dbo.my-table']
              [%schema-time ~2012.5.1]
              [%data-time ~2012.5.2]
              [%relation 'db1.dbo.my-table-2']
              [%schema-time ~2012.5.1]
              [%data-time ~2012.5.2]
              [%vector-count 2]
              ==
      ==
::
::  fail WHERE <column> >= <literal> types differ joined
++  test-fail-gte-joined-00
  =|  run=@ud
  %-  failon-3
  :*  run
      [~2012.4.30 %sys "CREATE DATABASE db1"]
      ::
      [~2012.5.1 %db1 create-joined-tables]
      ::
      :+  ~2012.5.2
          %db1
          "INSERT INTO my-table".
          " VALUES".
          " ('Abby', ~1999.2.19)".
          " ('Ace', ~2005.12.19)".
          " ('Angel', ~2001.9.19); ".
          "INSERT INTO my-table-2".
          " VALUES".
          " ('Abby', 'tricolor', 'row1')".
          " ('Ace', 'ticolor', 'row2')".
          " ('Angel', 'Angel', 'row3')"
      ::
      :+  ~2012.5.2
          %db1
          "FROM my-table T1 JOIN my-table-2 T2 ".
          "WHERE t1.col1 >= ~1999.2.19 SELECT T1.*, T2.col3, T2.col4"
      ::
      %-  crip
          "comparing column to literal of different aura: %col1 type=~.t ".
          "[p=~.da q=170.141.184.492.111.779.796.175.933.613.172.326.400]"
      ==
::
::  fail WHERE <literal> >= <column> types differ joined
++  test-fail-gte-joined-01
  =|  run=@ud
  %-  failon-3
  :*  run
      [~2012.4.30 %sys "CREATE DATABASE db1"]
      ::
      [~2012.5.1 %db1 create-joined-tables]
      ::
      :+  ~2012.5.2
          %db1
          "INSERT INTO my-table".
          " VALUES".
          " ('Abby', ~1999.2.19)".
          " ('Ace', ~2005.12.19)".
          " ('Angel', ~2001.9.19); ".
          "INSERT INTO my-table-2".
          " VALUES".
          " ('Abby', 'tricolor', 'row1')".
          " ('Ace', 'ticolor', 'row2')".
          " ('Angel', 'Angel', 'row3')"
      ::
      :+  ~2012.5.2
          %db1
          "FROM my-table T1 JOIN my-table-2 T2 ".
          "WHERE ~1999.2.19 >= t1.col1 SELECT T1.*, T2.col3, T2.col4"
      ::
      %-  crip
          "comparing literal to column of different aura: ".
          "[p=~.da q=170.141.184.492.111.779.796.175.933.613.172.326.400] ".
          "%col1 type=~.t"
      ==
::
::  fail WHERE <column> >= <column> types differ joined
++  test-fail-gte-joined-02
  =|  run=@ud
  %-  failon-3
  :*  run
      [~2012.4.30 %sys "CREATE DATABASE db1"]
      ::
      [~2012.5.1 %db1 create-joined-tables]
      ::
      :+  ~2012.5.2
          %db1
          "INSERT INTO my-table".
          " VALUES".
          " ('Abby', ~1999.2.19)".
          " ('Ace', ~2005.12.19)".
          " ('Angel', ~2001.9.19); ".
          "INSERT INTO my-table-2".
          " VALUES".
          " ('Abby', 'tricolor', 'row1')".
          " ('Ace', 'ticolor', 'row2')".
          " ('Angel', 'Angel', 'row3')"
      ::
      :+  ~2012.5.2
          %db1
          "FROM my-table T1 JOIN my-table-2 T2 ".
          "WHERE t1.col1 >= col2 SELECT T1.*, T2.col3, T2.col4"
      ::
      %-  crip
          "comparing columns of different auras: %col1 type=~.t %col2 type=~.da"
      ==
::
::  LTE
::
::  WHERE <column> <= <literal> (cord)
++  test-lte-00
  =|  run=@ud
  %-  exec-2-1
  :*  run
      [~2012.4.30 %sys "CREATE DATABASE db1"]
      ::
      [~2012.5.1 %db1 create-mytable]
      ::
      :+  ~2012.5.2
          %db1
          "INSERT INTO my-table".
          " VALUES".
          " ('Abby', ~1999.2.19, 'tricolor', 'row1')".
          " ('Ace', ~2005.12.19, 'ticolor', 'row2')".
          " ('Angel', ~2001.9.19, 'tuxedo', 'row3')"
      ::
      :+  ~2012.5.3
          %db1
          "FROM my-table WHERE col3 <= 'ticolor' SELECT *"
      ::
      :-  %results
          :~  [%action 'SELECT']
              :-  %result-set
                  :~  :-  %vector
                          :~  [%col1 [~.t 'Ace']]
                              [%col2 [~.da ~2005.12.19]]
                              [%col3 [~.t 'ticolor']]
                              [%col4 [~.t 'row2']]
                              ==
                      ==
              [%server-time ~2012.5.3]
              [%relation 'db1.dbo.my-table']
              [%schema-time ~2012.5.1]
              [%data-time ~2012.5.2]
              [%vector-count 1]
              ==
      ==
::
::  WHERE <column> <= <literal> (@da)
++  test-lte-01
  =|  run=@ud
  %-  exec-2-1
  :*  run
      [~2012.4.30 %sys "CREATE DATABASE db1"]
      ::
      [~2012.5.1 %db1 create-mytable]
      ::
      :+  ~2012.5.2
          %db1
          "INSERT INTO my-table".
          " VALUES".
          " ('Abby', ~1999.2.19, 'tricolor', 'row1')".
          " ('Ace', ~2005.12.19, 'ticolor', 'row2')".
          " ('Angel', ~2001.9.19, 'tuxedo', 'row3')"
      ::
      :+  ~2012.5.3
          %db1
          "FROM my-table WHERE col2 <= ~2001.9.19 SELECT *"
      ::
      :-  %results
          :~  [%action 'SELECT']
              :-  %result-set
                  :~  :-  %vector
                          :~  [%col1 [~.t 'Angel']]
                              [%col2 [~.da ~2001.9.19]]
                              [%col3 [~.t 'tuxedo']]
                              [%col4 [~.t 'row3']]
                              ==
                      :-  %vector
                          :~  [%col1 [~.t 'Abby']]
                              [%col2 [~.da ~1999.2.19]]
                              [%col3 [~.t 'tricolor']]
                              [%col4 [~.t 'row1']]
                              ==
                      ==
              [%server-time ~2012.5.3]
              [%relation 'db1.dbo.my-table']
              [%schema-time ~2012.5.1]
              [%data-time ~2012.5.2]
              [%vector-count 2]
              ==
      ==
::
::  WHERE <literal> <= <column>  (cord)
++  test-lte-02
  =|  run=@ud
  %-  exec-2-1
  :*  run
      [~2012.4.30 %sys "CREATE DATABASE db1"]
      ::
      [~2012.5.1 %db1 create-mytable]
      ::
      :+  ~2012.5.2
          %db1
          "INSERT INTO my-table".
          " VALUES".
          " ('Abby', ~1999.2.19, 'tricolor', 'row1')".
          " ('Ace', ~2005.12.19, 'ticolor', 'row2')".
          " ('Angel', ~2001.9.19, 'tuxedo', 'row3')"
      ::
      :+  ~2012.5.3
          %db1
          "FROM my-table WHERE 'tricolor' <= col3 SELECT *"
      ::
      :-  %results
          :~  [%action 'SELECT']
              :-  %result-set
                  :~  :-  %vector
                          :~  [%col1 [~.t 'Angel']]
                              [%col2 [~.da ~2001.9.19]]
                              [%col3 [~.t 'tuxedo']]
                              [%col4 [~.t 'row3']]
                              ==
                      :-  %vector
                          :~  [%col1 [~.t 'Abby']]
                              [%col2 [~.da ~1999.2.19]]
                              [%col3 [~.t 'tricolor']]
                              [%col4 [~.t 'row1']]
                              ==
                      ==
              [%server-time ~2012.5.3]
              [%relation 'db1.dbo.my-table']
              [%schema-time ~2012.5.1]
              [%data-time ~2012.5.2]
              [%vector-count 2]
              ==
      ==
::
::  WHERE <column> <= <column>  (cord)
++  test-lte-03
  =|  run=@ud
  %-  exec-2-1
  :*  run
      [~2012.4.30 %sys "CREATE DATABASE db1"]
      ::
      [~2012.5.1 %db1 create-mytable]
      ::
      :+  ~2012.5.2
          %db1
          "INSERT INTO my-table".
          " VALUES".
          " ('Abby', ~1999.2.19, 'tricolor', 'row1')".
          " ('Ace', ~2005.12.19, 'ticolor', 'row2')".
          " ('Angel', ~2001.9.19, 'Angel', 'row3')"
      ::
      :+  ~2012.5.3
          %db1
          "FROM my-table WHERE col1 <= col3 SELECT *"
      ::
      :-  %results
          :~  [%action 'SELECT']
              :-  %result-set
                  :~  :-  %vector
                          :~  [%col1 [~.t 'Angel']]
                              [%col2 [~.da ~2001.9.19]]
                              [%col3 [~.t 'Angel']]
                              [%col4 [~.t 'row3']]
                              ==
                      :-  %vector
                          :~  [%col1 [~.t 'Ace']]
                              [%col2 [~.da ~2005.12.19]]
                              [%col3 [~.t 'ticolor']]
                              [%col4 [~.t 'row2']]
                              ==
                      :-  %vector
                          :~  [%col1 [~.t 'Abby']]
                              [%col2 [~.da ~1999.2.19]]
                              [%col3 [~.t 'tricolor']]
                              [%col4 [~.t 'row1']]
                              ==
                      ==
              [%server-time ~2012.5.3]
              [%relation 'db1.dbo.my-table']
              [%schema-time ~2012.5.1]
              [%data-time ~2012.5.2]
              [%vector-count 3]
              ==
      ==
::
::  WHERE <column> <= <literal> (cord)
++  test-lte-04
  =|  run=@ud
  %-  exec-2-1
  :*  run
      [~2012.4.30 %sys "CREATE DATABASE db1"]
      ::
      :+  ~2012.5.1
          %db1
          "CREATE TABLE db1..my-table ".
          "(col1 @t, col2 @da, col3 @t, col4 @t) ".
          "PRIMARY KEY (col3)"
      ::
      :+  ~2012.5.2
          %db1
          "INSERT INTO my-table".
          " VALUES".
          " ('Abby', ~1999.2.19, 'tricolor', 'row1')".
          " ('Ace', ~2005.12.19, 'ticolor', 'row2')".
          " ('Angel', ~2001.9.19, 'tuxedo', 'row3')"
      ::
      :+  ~2012.5.3
          %db1
          "FROM my-table WHERE col1 <= 'Ace' SELECT *"
      ::
      :-  %results
          :~  [%action 'SELECT']
              :-  %result-set
                  :~  :-  %vector
                          :~  [%col1 [~.t 'Ace']]
                              [%col2 [~.da ~2005.12.19]]
                              [%col3 [~.t 'ticolor']]
                              [%col4 [~.t 'row2']]
                              ==
                      :-  %vector
                          :~  [%col1 [~.t 'Abby']]
                              [%col2 [~.da ~1999.2.19]]
                              [%col3 [~.t 'tricolor']]
                              [%col4 [~.t 'row1']]
                              ==
                      ==
              [%server-time ~2012.5.3]
              [%relation 'db1.dbo.my-table']
              [%schema-time ~2012.5.1]
              [%data-time ~2012.5.2]
              [%vector-count 2]
              ==
      ==
::
::  view WHERE <column> <= <literal>
++  test-lte-05
  =|  run=@ud
  %-  exec-1-1
  :*  run
      [~2012.4.30 %sys "CREATE DATABASE db1"]
      ::
      [~2012.5.1 %db1 create-mytable]
      ::
      :+  ~2012.5.3
          %db1
          "FROM sys.columns WHERE 'col2' <= col-name SELECT *"
      ::
      :-  %results
          :~  [%action 'SELECT']
              :-  %result-set
                  :~  :-  %vector
                          :~  [p=%namespace q=[p=~.tas q=%dbo]]
                              [p=%name q=[p=~.tas q=%my-table]]
                              [p=%col-ordinal q=[p=~.ud q=2]]
                              [p=%col-name q=[p=~.tas q=%col2]]
                              [p=%col-type q=[p=~.ta q=~.da]]
                              ==
                      :-  %vector
                          :~  [p=%namespace q=[p=~.tas q=%dbo]]
                              [p=%name q=[p=~.tas q=%my-table]]
                              [p=%col-ordinal q=[p=~.ud q=4]]
                              [p=%col-name q=[p=~.tas q=%col4]]
                              [p=%col-type q=[p=~.ta q=~.t]]
                              ==
                      :-  %vector
                          :~  [p=%namespace q=[p=~.tas q=%dbo]]
                              [p=%name q=[p=~.tas q=%my-table]]
                              [p=%col-ordinal q=[p=~.ud q=3]]
                              [p=%col-name q=[p=~.tas q=%col3]]
                              [p=%col-type q=[p=~.ta q=~.t]]
                              ==
                      ==
              [%server-time ~2012.5.3]
              [%relation 'db1.sys.columns']
              [%schema-time ~2012.5.1]
              [%data-time ~2012.5.1]
              [%vector-count 3]
              ==
      ==
::
::  view WHERE <literal> <= <literal>
++  test-lte-06
  =|  run=@ud
  %-  exec-1-1
  :*  run
      [~2012.4.30 %sys "CREATE DATABASE db1"]
      ::
      [~2012.5.1 %db1 create-mytable]
      ::
      :+  ~2012.5.3
          %db1
          "FROM sys.columns WHERE 1 <= 1 SELECT *"
      ::
      :-  %results
          :~  [%action 'SELECT']
              :-  %result-set
                  :~  :-  %vector
                          :~  [p=%namespace q=[p=~.tas q=%dbo]]
                              [p=%name q=[p=~.tas q=%my-table]]
                              [p=%col-ordinal q=[p=~.ud q=2]]
                              [p=%col-name q=[p=~.tas q=%col2]]
                              [p=%col-type q=[p=~.ta q=~.da]]
                              ==
                      :-  %vector
                          :~  [p=%namespace q=[p=~.tas q=%dbo]]
                              [p=%name q=[p=~.tas q=%my-table]]
                              [p=%col-ordinal q=[p=~.ud q=1]]
                              [p=%col-name q=[p=~.tas q=%col1]]
                              [p=%col-type q=[p=~.ta q=~.t]]
                              ==
                      :-  %vector
                          :~  [p=%namespace q=[p=~.tas q=%dbo]]
                              [p=%name q=[p=~.tas q=%my-table]]
                              [p=%col-ordinal q=[p=~.ud q=4]]
                              [p=%col-name q=[p=~.tas q=%col4]]
                              [p=%col-type q=[p=~.ta q=~.t]]
                              ==
                      :-  %vector
                          :~  [p=%namespace q=[p=~.tas q=%dbo]]
                              [p=%name q=[p=~.tas q=%my-table]]
                              [p=%col-ordinal q=[p=~.ud q=3]]
                              [p=%col-name q=[p=~.tas q=%col3]]
                              [p=%col-type q=[p=~.ta q=~.t]]
                              ==
                      ==
              [%server-time ~2012.5.3]
              [%relation 'db1.sys.columns']
              [%schema-time ~2012.5.1]
              [%data-time ~2012.5.1]
              [%vector-count 4]
              ==
      ==
::
::  WHERE <literal> <= <literal> @rd less (true)
++  test-lte-07
  =|  run=@ud
  %-  exec-2-1
  :*  run
      [~2012.4.30 %sys "CREATE DATABASE db1"]
      ::
      [~2012.5.1 %db1 create-rd-table]
      ::
      :+  ~2012.5.2
          %db1
          "INSERT INTO my-table".
          " VALUES".
          " ('row1', .~3.14)"
      ::
      :+  ~2012.5.3
          %db1
          "FROM my-table WHERE .~3.14 <= .~6.02 SELECT *"
      ::
      :-  %results
          :~  [%action 'SELECT']
              :-  %result-set
                  :~  :-  %vector
                          :~  [%col1 [~.t 'row1']]
                              [%col2 [~.rd .~3.14]]
                              ==
                      ==
              [%server-time ~2012.5.3]
              [%relation 'db1.dbo.my-table']
              [%schema-time ~2012.5.1]
              [%data-time ~2012.5.2]
              [%vector-count 1]
              ==
      ==
::
::  WHERE <literal> <= <literal> @rd equality (true)
++  test-lte-08
  =|  run=@ud
  %-  exec-2-1
  :*  run
      [~2012.4.30 %sys "CREATE DATABASE db1"]
      ::
      [~2012.5.1 %db1 create-rd-table]
      ::
      :+  ~2012.5.2
          %db1
          "INSERT INTO my-table".
          " VALUES".
          " ('row1', .~3.14)"
      ::
      :+  ~2012.5.3
          %db1
          "FROM my-table WHERE .~3.14 <= .~3.14 SELECT *"
      ::
      :-  %results
          :~  [%action 'SELECT']
              :-  %result-set
                  :~  :-  %vector
                          :~  [%col1 [~.t 'row1']]
                              [%col2 [~.rd .~3.14]]
                              ==
                      ==
              [%server-time ~2012.5.3]
              [%relation 'db1.dbo.my-table']
              [%schema-time ~2012.5.1]
              [%data-time ~2012.5.2]
              [%vector-count 1]
              ==
      ==
::
::  WHERE <literal> <= <literal> @rd greater (false)
++  test-lte-09
  =|  run=@ud
  %-  exec-2-1
  :*  run
      [~2012.4.30 %sys "CREATE DATABASE db1"]
      ::
      [~2012.5.1 %db1 create-rd-table]
      ::
      :+  ~2012.5.2
          %db1
          "INSERT INTO my-table".
          " VALUES".
          " ('row1', .~3.14)"
      ::
      :+  ~2012.5.3
          %db1
          "FROM my-table WHERE .~6.02 <= .~3.14 SELECT *"
      ::
      :-  %results
          :~  [%action 'SELECT']
              [%result-set ~]
              [%server-time ~2012.5.3]
              [%relation 'db1.dbo.my-table']
              [%schema-time ~2012.5.1]
              [%data-time ~2012.5.2]
              [%vector-count 0]
              ==
      ==
::
::  WHERE <column> <= <literal> @rd less (true)
++  test-lte-10
  =|  run=@ud
  %-  exec-2-1
  :*  run
      [~2012.4.30 %sys "CREATE DATABASE db1"]
      ::
      [~2012.5.1 %db1 create-rd-table]
      ::
      :+  ~2012.5.2
          %db1
          "INSERT INTO my-table".
          " VALUES".
          " ('row1', .~3.14)"
      ::
      :+  ~2012.5.3
          %db1
          "FROM my-table WHERE col2 <= .~6.02 SELECT *"
      ::
      :-  %results
          :~  [%action 'SELECT']
              :-  %result-set
                  :~  :-  %vector
                          :~  [%col1 [~.t 'row1']]
                              [%col2 [~.rd .~3.14]]
                              ==
                      ==
              [%server-time ~2012.5.3]
              [%relation 'db1.dbo.my-table']
              [%schema-time ~2012.5.1]
              [%data-time ~2012.5.2]
              [%vector-count 1]
              ==
      ==
::
::  WHERE <column> <= <literal> @rd equality (true)
++  test-lte-11
  =|  run=@ud
  %-  exec-2-1
  :*  run
      [~2012.4.30 %sys "CREATE DATABASE db1"]
      ::
      [~2012.5.1 %db1 create-rd-table]
      ::
      :+  ~2012.5.2
          %db1
          "INSERT INTO my-table".
          " VALUES".
          " ('row1', .~3.14)"
      ::
      :+  ~2012.5.3
          %db1
          "FROM my-table WHERE col2 <= .~3.14 SELECT *"
      ::
      :-  %results
          :~  [%action 'SELECT']
              :-  %result-set
                  :~  :-  %vector
                          :~  [%col1 [~.t 'row1']]
                              [%col2 [~.rd .~3.14]]
                              ==
                      ==
              [%server-time ~2012.5.3]
              [%relation 'db1.dbo.my-table']
              [%schema-time ~2012.5.1]
              [%data-time ~2012.5.2]
              [%vector-count 1]
              ==
      ==
::
::  WHERE <column> <= <literal> @rd greater (false)
++  test-lte-12
  =|  run=@ud
  %-  exec-2-1
  :*  run
      [~2012.4.30 %sys "CREATE DATABASE db1"]
      ::
      [~2012.5.1 %db1 create-rd-table]
      ::
      :+  ~2012.5.2
          %db1
          "INSERT INTO my-table".
          " VALUES".
          " ('row1', .~6.02)"
      ::
      :+  ~2012.5.3
          %db1
          "FROM my-table WHERE col2 <= .~3.14 SELECT *"
      ::
      :-  %results
          :~  [%action 'SELECT']
              [%result-set ~]
              [%server-time ~2012.5.3]
              [%relation 'db1.dbo.my-table']
              [%schema-time ~2012.5.1]
              [%data-time ~2012.5.2]
              [%vector-count 0]
              ==
      ==
::
::  WHERE <literal> <= <column> @rd less (true)
++  test-lte-13
  =|  run=@ud
  %-  exec-2-1
  :*  run
      [~2012.4.30 %sys "CREATE DATABASE db1"]
      ::
      [~2012.5.1 %db1 create-rd-table]
      ::
      :+  ~2012.5.2
          %db1
          "INSERT INTO my-table".
          " VALUES".
          " ('row1', .~6.02)"
      ::
      :+  ~2012.5.3
          %db1
          "FROM my-table WHERE .~3.14 <= col2 SELECT *"
      ::
      :-  %results
          :~  [%action 'SELECT']
              :-  %result-set
                  :~  :-  %vector
                          :~  [%col1 [~.t 'row1']]
                              [%col2 [~.rd .~6.02]]
                              ==
                      ==
              [%server-time ~2012.5.3]
              [%relation 'db1.dbo.my-table']
              [%schema-time ~2012.5.1]
              [%data-time ~2012.5.2]
              [%vector-count 1]
              ==
      ==
::
::  WHERE <literal> <= <column> @rd equality (true)
++  test-lte-14
  =|  run=@ud
  %-  exec-2-1
  :*  run
      [~2012.4.30 %sys "CREATE DATABASE db1"]
      ::
      [~2012.5.1 %db1 create-rd-table]
      ::
      :+  ~2012.5.2
          %db1
          "INSERT INTO my-table".
          " VALUES".
          " ('row1', .~3.14)"
      ::
      :+  ~2012.5.3
          %db1
          "FROM my-table WHERE .~3.14 <= col2 SELECT *"
      ::
      :-  %results
          :~  [%action 'SELECT']
              :-  %result-set
                  :~  :-  %vector
                          :~  [%col1 [~.t 'row1']]
                              [%col2 [~.rd .~3.14]]
                              ==
                      ==
              [%server-time ~2012.5.3]
              [%relation 'db1.dbo.my-table']
              [%schema-time ~2012.5.1]
              [%data-time ~2012.5.2]
              [%vector-count 1]
              ==
      ==
::
::  WHERE <literal> <= <column> @rd greater (false)
++  test-lte-15
  =|  run=@ud
  %-  exec-2-1
  :*  run
      [~2012.4.30 %sys "CREATE DATABASE db1"]
      ::
      [~2012.5.1 %db1 create-rd-table]
      ::
      :+  ~2012.5.2
          %db1
          "INSERT INTO my-table".
          " VALUES".
          " ('row1', .~3.14)"
      ::
      :+  ~2012.5.3
          %db1
          "FROM my-table WHERE .~6.02 <= col2 SELECT *"
      ::
      :-  %results
          :~  [%action 'SELECT']
              [%result-set ~]
              [%server-time ~2012.5.3]
              [%relation 'db1.dbo.my-table']
              [%schema-time ~2012.5.1]
              [%data-time ~2012.5.2]
              [%vector-count 0]
              ==
      ==
::
::  WHERE <column> <= <column> @rd less (true)
++  test-lte-16
  =|  run=@ud
  %-  exec-2-1
  :*  run
      [~2012.4.30 %sys "CREATE DATABASE db1"]
      ::
      [~2012.5.1 %db1 create-rd-2col-table]
      ::
      :+  ~2012.5.2
          %db1
          "INSERT INTO my-table".
          " VALUES".
          " ('row1', .~3.14, .~6.02)"
      ::
      :+  ~2012.5.3
          %db1
          "FROM my-table WHERE col2 <= col3 SELECT *"
      ::
      :-  %results
          :~  [%action 'SELECT']
              :-  %result-set
                  :~  :-  %vector
                          :~  [%col1 [~.t 'row1']]
                              [%col2 [~.rd .~3.14]]
                              [%col3 [~.rd .~6.02]]
                              ==
                      ==
              [%server-time ~2012.5.3]
              [%relation 'db1.dbo.my-table']
              [%schema-time ~2012.5.1]
              [%data-time ~2012.5.2]
              [%vector-count 1]
              ==
      ==
::
::  WHERE <column> <= <column> @rd equality (true)
++  test-lte-17
  =|  run=@ud
  %-  exec-2-1
  :*  run
      [~2012.4.30 %sys "CREATE DATABASE db1"]
      ::
      [~2012.5.1 %db1 create-rd-2col-table]
      ::
      :+  ~2012.5.2
          %db1
          "INSERT INTO my-table".
          " VALUES".
          " ('row1', .~3.14, .~3.14)"
      ::
      :+  ~2012.5.3
          %db1
          "FROM my-table WHERE col2 <= col3 SELECT *"
      ::
      :-  %results
          :~  [%action 'SELECT']
              :-  %result-set
                  :~  :-  %vector
                          :~  [%col1 [~.t 'row1']]
                              [%col2 [~.rd .~3.14]]
                              [%col3 [~.rd .~3.14]]
                              ==
                      ==
              [%server-time ~2012.5.3]
              [%relation 'db1.dbo.my-table']
              [%schema-time ~2012.5.1]
              [%data-time ~2012.5.2]
              [%vector-count 1]
              ==
      ==
::
::  WHERE <column> <= <column> @rd greater (false)
++  test-lte-18
  =|  run=@ud
  %-  exec-2-1
  :*  run
      [~2012.4.30 %sys "CREATE DATABASE db1"]
      ::
      [~2012.5.1 %db1 create-rd-2col-table]
      ::
      :+  ~2012.5.2
          %db1
          "INSERT INTO my-table".
          " VALUES".
          " ('row1', .~6.02, .~3.14)"
      ::
      :+  ~2012.5.3
          %db1
          "FROM my-table WHERE col2 <= col3 SELECT *"
      ::
      :-  %results
          :~  [%action 'SELECT']
              [%result-set ~]
              [%server-time ~2012.5.3]
              [%relation 'db1.dbo.my-table']
              [%schema-time ~2012.5.1]
              [%data-time ~2012.5.2]
              [%vector-count 0]
              ==
      ==
::
::  WHERE <literal> <= <literal> @sd less (true)
++  test-lte-19
  =|  run=@ud
  %-  exec-2-1
  :*  run
      [~2012.4.30 %sys "CREATE DATABASE db1"]
      ::
      [~2012.5.1 %db1 create-sd-table]
      ::
      :+  ~2012.5.2
          %db1
          "INSERT INTO my-table".
          " VALUES".
          " ('row1', --3)"
      ::
      :+  ~2012.5.3
          %db1
          "FROM my-table WHERE --3 <= --6 SELECT *"
      ::
      :-  %results
          :~  [%action 'SELECT']
              :-  %result-set
                  :~  :-  %vector
                          :~  [%col1 [~.t 'row1']]
                              [%col2 [~.sd --3]]
                              ==
                      ==
              [%server-time ~2012.5.3]
              [%relation 'db1.dbo.my-table']
              [%schema-time ~2012.5.1]
              [%data-time ~2012.5.2]
              [%vector-count 1]
              ==
      ==
::
::  WHERE <literal> <= <literal> @sd equality (true)
++  test-lte-20
  =|  run=@ud
  %-  exec-2-1
  :*  run
      [~2012.4.30 %sys "CREATE DATABASE db1"]
      ::
      [~2012.5.1 %db1 create-sd-table]
      ::
      :+  ~2012.5.2
          %db1
          "INSERT INTO my-table".
          " VALUES".
          " ('row1', --3)"
      ::
      :+  ~2012.5.3
          %db1
          "FROM my-table WHERE --3 <= --3 SELECT *"
      ::
      :-  %results
          :~  [%action 'SELECT']
              :-  %result-set
                  :~  :-  %vector
                          :~  [%col1 [~.t 'row1']]
                              [%col2 [~.sd --3]]
                              ==
                      ==
              [%server-time ~2012.5.3]
              [%relation 'db1.dbo.my-table']
              [%schema-time ~2012.5.1]
              [%data-time ~2012.5.2]
              [%vector-count 1]
              ==
      ==
::
::  WHERE <literal> <= <literal> @sd greater (false)
++  test-lte-21
  =|  run=@ud
  %-  exec-2-1
  :*  run
      [~2012.4.30 %sys "CREATE DATABASE db1"]
      ::
      [~2012.5.1 %db1 create-sd-table]
      ::
      :+  ~2012.5.2
          %db1
          "INSERT INTO my-table".
          " VALUES".
          " ('row1', --3)"
      ::
      :+  ~2012.5.3
          %db1
          "FROM my-table WHERE --6 <= --3 SELECT *"
      ::
      :-  %results
          :~  [%action 'SELECT']
              [%result-set ~]
              [%server-time ~2012.5.3]
              [%relation 'db1.dbo.my-table']
              [%schema-time ~2012.5.1]
              [%data-time ~2012.5.2]
              [%vector-count 0]
              ==
      ==
::
::  WHERE <column> <= <literal> @sd less (true)
++  test-lte-22
  =|  run=@ud
  %-  exec-2-1
  :*  run
      [~2012.4.30 %sys "CREATE DATABASE db1"]
      ::
      [~2012.5.1 %db1 create-sd-table]
      ::
      :+  ~2012.5.2
          %db1
          "INSERT INTO my-table".
          " VALUES".
          " ('row1', --3)"
      ::
      :+  ~2012.5.3
          %db1
          "FROM my-table WHERE col2 <= --6 SELECT *"
      ::
      :-  %results
          :~  [%action 'SELECT']
              :-  %result-set
                  :~  :-  %vector
                          :~  [%col1 [~.t 'row1']]
                              [%col2 [~.sd --3]]
                              ==
                      ==
              [%server-time ~2012.5.3]
              [%relation 'db1.dbo.my-table']
              [%schema-time ~2012.5.1]
              [%data-time ~2012.5.2]
              [%vector-count 1]
              ==
      ==
::
::  WHERE <column> <= <literal> @sd equality (true)
++  test-lte-23
  =|  run=@ud
  %-  exec-2-1
  :*  run
      [~2012.4.30 %sys "CREATE DATABASE db1"]
      ::
      [~2012.5.1 %db1 create-sd-table]
      ::
      :+  ~2012.5.2
          %db1
          "INSERT INTO my-table".
          " VALUES".
          " ('row1', --3)"
      ::
      :+  ~2012.5.3
          %db1
          "FROM my-table WHERE col2 <= --3 SELECT *"
      ::
      :-  %results
          :~  [%action 'SELECT']
              :-  %result-set
                  :~  :-  %vector
                          :~  [%col1 [~.t 'row1']]
                              [%col2 [~.sd --3]]
                              ==
                      ==
              [%server-time ~2012.5.3]
              [%relation 'db1.dbo.my-table']
              [%schema-time ~2012.5.1]
              [%data-time ~2012.5.2]
              [%vector-count 1]
              ==
      ==
::
::  WHERE <column> <= <literal> @sd greater (false)
++  test-lte-24
  =|  run=@ud
  %-  exec-2-1
  :*  run
      [~2012.4.30 %sys "CREATE DATABASE db1"]
      ::
      [~2012.5.1 %db1 create-sd-table]
      ::
      :+  ~2012.5.2
          %db1
          "INSERT INTO my-table".
          " VALUES".
          " ('row1', --6)"
      ::
      :+  ~2012.5.3
          %db1
          "FROM my-table WHERE col2 <= --3 SELECT *"
      ::
      :-  %results
          :~  [%action 'SELECT']
              [%result-set ~]
              [%server-time ~2012.5.3]
              [%relation 'db1.dbo.my-table']
              [%schema-time ~2012.5.1]
              [%data-time ~2012.5.2]
              [%vector-count 0]
              ==
      ==
::
::  WHERE <literal> <= <column> @sd less (true)
++  test-lte-25
  =|  run=@ud
  %-  exec-2-1
  :*  run
      [~2012.4.30 %sys "CREATE DATABASE db1"]
      ::
      [~2012.5.1 %db1 create-sd-table]
      ::
      :+  ~2012.5.2
          %db1
          "INSERT INTO my-table".
          " VALUES".
          " ('row1', --6)"
      ::
      :+  ~2012.5.3
          %db1
          "FROM my-table WHERE --3 <= col2 SELECT *"
      ::
      :-  %results
          :~  [%action 'SELECT']
              :-  %result-set
                  :~  :-  %vector
                          :~  [%col1 [~.t 'row1']]
                              [%col2 [~.sd --6]]
                              ==
                      ==
              [%server-time ~2012.5.3]
              [%relation 'db1.dbo.my-table']
              [%schema-time ~2012.5.1]
              [%data-time ~2012.5.2]
              [%vector-count 1]
              ==
      ==
::
::  WHERE <literal> <= <column> @sd equality (true)
++  test-lte-26
  =|  run=@ud
  %-  exec-2-1
  :*  run
      [~2012.4.30 %sys "CREATE DATABASE db1"]
      ::
      [~2012.5.1 %db1 create-sd-table]
      ::
      :+  ~2012.5.2
          %db1
          "INSERT INTO my-table".
          " VALUES".
          " ('row1', --3)"
      ::
      :+  ~2012.5.3
          %db1
          "FROM my-table WHERE --3 <= col2 SELECT *"
      ::
      :-  %results
          :~  [%action 'SELECT']
              :-  %result-set
                  :~  :-  %vector
                          :~  [%col1 [~.t 'row1']]
                              [%col2 [~.sd --3]]
                              ==
                      ==
              [%server-time ~2012.5.3]
              [%relation 'db1.dbo.my-table']
              [%schema-time ~2012.5.1]
              [%data-time ~2012.5.2]
              [%vector-count 1]
              ==
      ==
::
::  WHERE <literal> <= <column> @sd greater (false)
++  test-lte-27
  =|  run=@ud
  %-  exec-2-1
  :*  run
      [~2012.4.30 %sys "CREATE DATABASE db1"]
      ::
      [~2012.5.1 %db1 create-sd-table]
      ::
      :+  ~2012.5.2
          %db1
          "INSERT INTO my-table".
          " VALUES".
          " ('row1', --3)"
      ::
      :+  ~2012.5.3
          %db1
          "FROM my-table WHERE --6 <= col2 SELECT *"
      ::
      :-  %results
          :~  [%action 'SELECT']
              [%result-set ~]
              [%server-time ~2012.5.3]
              [%relation 'db1.dbo.my-table']
              [%schema-time ~2012.5.1]
              [%data-time ~2012.5.2]
              [%vector-count 0]
              ==
      ==
::
::  WHERE <column> <= <column> @sd less (true)
++  test-lte-28
  =|  run=@ud
  %-  exec-2-1
  :*  run
      [~2012.4.30 %sys "CREATE DATABASE db1"]
      ::
      [~2012.5.1 %db1 create-sd-2col-table]
      ::
      :+  ~2012.5.2
          %db1
          "INSERT INTO my-table".
          " VALUES".
          " ('row1', --3, --6)"
      ::
      :+  ~2012.5.3
          %db1
          "FROM my-table WHERE col2 <= col3 SELECT *"
      ::
      :-  %results
          :~  [%action 'SELECT']
              :-  %result-set
                  :~  :-  %vector
                          :~  [%col1 [~.t 'row1']]
                              [%col2 [~.sd --3]]
                              [%col3 [~.sd --6]]
                              ==
                      ==
              [%server-time ~2012.5.3]
              [%relation 'db1.dbo.my-table']
              [%schema-time ~2012.5.1]
              [%data-time ~2012.5.2]
              [%vector-count 1]
              ==
      ==
::
::  WHERE <column> <= <column> @sd equality (true)
++  test-lte-29
  =|  run=@ud
  %-  exec-2-1
  :*  run
      [~2012.4.30 %sys "CREATE DATABASE db1"]
      ::
      [~2012.5.1 %db1 create-sd-2col-table]
      ::
      :+  ~2012.5.2
          %db1
          "INSERT INTO my-table".
          " VALUES".
          " ('row1', --3, --3)"
      ::
      :+  ~2012.5.3
          %db1
          "FROM my-table WHERE col2 <= col3 SELECT *"
      ::
      :-  %results
          :~  [%action 'SELECT']
              :-  %result-set
                  :~  :-  %vector
                          :~  [%col1 [~.t 'row1']]
                              [%col2 [~.sd --3]]
                              [%col3 [~.sd --3]]
                              ==
                      ==
              [%server-time ~2012.5.3]
              [%relation 'db1.dbo.my-table']
              [%schema-time ~2012.5.1]
              [%data-time ~2012.5.2]
              [%vector-count 1]
              ==
      ==
::
::  WHERE <column> <= <column> @sd greater (false)
++  test-lte-30
  =|  run=@ud
  %-  exec-2-1
  :*  run
      [~2012.4.30 %sys "CREATE DATABASE db1"]
      ::
      [~2012.5.1 %db1 create-sd-2col-table]
      ::
      :+  ~2012.5.2
          %db1
          "INSERT INTO my-table".
          " VALUES".
          " ('row1', --6, --3)"
      ::
      :+  ~2012.5.3
          %db1
          "FROM my-table WHERE col2 <= col3 SELECT *"
      ::
      :-  %results
          :~  [%action 'SELECT']
              [%result-set ~]
              [%server-time ~2012.5.3]
              [%relation 'db1.dbo.my-table']
              [%schema-time ~2012.5.1]
              [%data-time ~2012.5.2]
              [%vector-count 0]
              ==
      ==
::
::  fail WHERE <column> <= <literal> types differ
++  test-fail-lte-00
  =|  run=@ud
  %-  failon-3
  :*  run
      [~2012.4.30 %sys "CREATE DATABASE db1"]
      ::
      [~2012.5.1 %db1 create-mytable]
      ::
      :+  ~2012.5.2
          %db1
          "INSERT INTO my-table".
          " VALUES".
          " ('Abby', ~1999.2.19, 'tricolor', 'row1')".
          " ('Ace', ~2005.12.19, 'ticolor', 'row2')".
          " ('Angel', ~2001.9.19, 'Angel', 'row3')"
      ::
      :+  ~2012.5.2
          %db1
          "FROM my-table WHERE col1 <= ~1999.2.19 SELECT *"
      ::
      %-  crip
          "comparing column to literal of different aura: %col1 type=~.t ".
          "[p=~.da q=170.141.184.492.111.779.796.175.933.613.172.326.400]"
      ==
::
::  fail WHERE <literal> <= <column> types differ
++  test-fail-lte-01
  =|  run=@ud
  %-  failon-3
  :*  run
      [~2012.4.30 %sys "CREATE DATABASE db1"]
      ::
      [~2012.5.1 %db1 create-mytable]
      ::
      :+  ~2012.5.2
          %db1
          "INSERT INTO my-table".
          " VALUES".
          " ('Abby', ~1999.2.19, 'tricolor', 'row1')".
          " ('Ace', ~2005.12.19, 'ticolor', 'row2')".
          " ('Angel', ~2001.9.19, 'Angel', 'row3')"
      ::
      :+  ~2012.5.2
          %db1
          "FROM my-table WHERE ~1999.2.19 <= col1 SELECT *"
      ::
      %-  crip
          "comparing literal to column of different aura: ".
          "[p=~.da q=170.141.184.492.111.779.796.175.933.613.172.326.400] ".
          "%col1 type=~.t"
      ==
::
::  fail WHERE <column> <= <column> types differ
++  test-fail-lte-02
  =|  run=@ud
  %-  failon-3
  :*  run
      [~2012.4.30 %sys "CREATE DATABASE db1"]
      ::
      [~2012.5.1 %db1 create-mytable]
      ::
      :+  ~2012.5.2
          %db1
          "INSERT INTO my-table".
          " VALUES".
          " ('Abby', ~1999.2.19, 'tricolor', 'row1')".
          " ('Ace', ~2005.12.19, 'ticolor', 'row2')".
          " ('Angel', ~2001.9.19, 'Angel', 'row3')"
      ::
      :+  ~2012.5.2
          %db1
          "FROM my-table WHERE col1 <= col2 SELECT *"
      ::
      %-  crip
          "comparing columns of different auras: %col1 type=~.t %col2 type=~.da"
      ==
::
::  WHERE <column> <= <literal> (cord) joined
++  test-lte-joined-00
  =|  run=@ud
  %-  exec-2-1
  :*  run
      [~2012.4.30 %sys "CREATE DATABASE db1"]
      ::
      [~2012.5.1 %db1 create-joined-tables]
      ::
      :+  ~2012.5.2
          %db1
          "INSERT INTO my-table".
          " VALUES".
          " ('Abby', ~1999.2.19)".
          " ('Ace', ~2005.12.19)".
          " ('Angel', ~2001.9.19); ".
          "INSERT INTO my-table-2".
          " VALUES".
          " ('Abby', 'tricolor', 'row1')".
          " ('Ace', 'ticolor', 'row2')".
          " ('Angel', 'tuxedo', 'row3')"
      ::
      :+  ~2012.5.3
          %db1
          "FROM my-table T1 JOIN my-table-2 T2 ".
          "WHERE col3 <= 'ticolor' SELECT T1.*, T2.col3, T2.col4"
      ::
      :-  %results
          :~  [%action 'SELECT']
              :-  %result-set
                  :~  :-  %vector
                          :~  [%col1 [~.t 'Ace']]
                              [%col2 [~.da ~2005.12.19]]
                              [%col3 [~.t 'ticolor']]
                              [%col4 [~.t 'row2']]
                              ==
                      ==
              [%server-time ~2012.5.3]
              [%relation 'db1.dbo.my-table']
              [%schema-time ~2012.5.1]
              [%data-time ~2012.5.2]
              [%relation 'db1.dbo.my-table-2']
              [%schema-time ~2012.5.1]
              [%data-time ~2012.5.2]
              [%vector-count 1]
              ==
      ==
::
::  WHERE <column> <= <literal> (@da) joined
++  test-lte-joined-01
  =|  run=@ud
  %-  exec-2-1
  :*  run
      [~2012.4.30 %sys "CREATE DATABASE db1"]
      ::
      [~2012.5.1 %db1 create-joined-tables]
      ::
      :+  ~2012.5.2
          %db1
          "INSERT INTO my-table".
          " VALUES".
          " ('Abby', ~1999.2.19)".
          " ('Ace', ~2005.12.19)".
          " ('Angel', ~2001.9.19); ".
          "INSERT INTO my-table-2".
          " VALUES".
          " ('Abby', 'tricolor', 'row1')".
          " ('Ace', 'ticolor', 'row2')".
          " ('Angel', 'tuxedo', 'row3')"
      ::
      :+  ~2012.5.3
          %db1
          "FROM my-table T1 JOIN my-table-2 T2 ".
          "WHERE col2 <= ~2001.9.19 SELECT T1.*, T2.col3, T2.col4"
      ::
      :-  %results
          :~  [%action 'SELECT']
              :-  %result-set
                  :~  :-  %vector
                          :~  [%col1 [~.t 'Angel']]
                              [%col2 [~.da ~2001.9.19]]
                              [%col3 [~.t 'tuxedo']]
                              [%col4 [~.t 'row3']]
                              ==
                      :-  %vector
                          :~  [%col1 [~.t 'Abby']]
                              [%col2 [~.da ~1999.2.19]]
                              [%col3 [~.t 'tricolor']]
                              [%col4 [~.t 'row1']]
                              ==
                      ==
              [%server-time ~2012.5.3]
              [%relation 'db1.dbo.my-table']
              [%schema-time ~2012.5.1]
              [%data-time ~2012.5.2]
              [%relation 'db1.dbo.my-table-2']
              [%schema-time ~2012.5.1]
              [%data-time ~2012.5.2]
              [%vector-count 2]
              ==
      ==
::
::  WHERE <literal> <= <column>  (cord) joined
++  test-lte-joined-02
  =|  run=@ud
  %-  exec-2-1
  :*  run
      [~2012.4.30 %sys "CREATE DATABASE db1"]
      ::
      [~2012.5.1 %db1 create-joined-tables]
      ::
      :+  ~2012.5.2
          %db1
          "INSERT INTO my-table".
          " VALUES".
          " ('Abby', ~1999.2.19)".
          " ('Ace', ~2005.12.19)".
          " ('Angel', ~2001.9.19); ".
          "INSERT INTO my-table-2".
          " VALUES".
          " ('Abby', 'tricolor', 'row1')".
          " ('Ace', 'ticolor', 'row2')".
          " ('Angel', 'tuxedo', 'row3')"
      ::
      :+  ~2012.5.3
          %db1
          "FROM my-table T1 JOIN my-table-2 T2 ".
          "WHERE 'tricolor' <= col3 SELECT T1.*, T2.col3, T2.col4"
      ::
      :-  %results
          :~  [%action 'SELECT']
              :-  %result-set
                  :~  :-  %vector
                          :~  [%col1 [~.t 'Angel']]
                              [%col2 [~.da ~2001.9.19]]
                              [%col3 [~.t 'tuxedo']]
                              [%col4 [~.t 'row3']]
                              ==
                      :-  %vector
                          :~  [%col1 [~.t 'Abby']]
                              [%col2 [~.da ~1999.2.19]]
                              [%col3 [~.t 'tricolor']]
                              [%col4 [~.t 'row1']]
                              ==
                      ==
              [%server-time ~2012.5.3]
              [%relation 'db1.dbo.my-table']
              [%schema-time ~2012.5.1]
              [%data-time ~2012.5.2]
              [%relation 'db1.dbo.my-table-2']
              [%schema-time ~2012.5.1]
              [%data-time ~2012.5.2]
              [%vector-count 2]
              ==
      ==
::
::  WHERE <column> <= <column>  (cord) joined
++  test-lte-joined-03
  =|  run=@ud
  %-  exec-2-1
  :*  run
      [~2012.4.30 %sys "CREATE DATABASE db1"]
      ::
      [~2012.5.1 %db1 create-joined-tables]
      ::
      :+  ~2012.5.2
          %db1
          "INSERT INTO my-table".
          " VALUES".
          " ('Abby', ~1999.2.19)".
          " ('Ace', ~2005.12.19)".
          " ('Angel', ~2001.9.19); ".
          "INSERT INTO my-table-2".
          " VALUES".
          " ('Abby', 'tricolor', 'row1')".
          " ('Ace', 'ticolor', 'row2')".
          " ('Angel', 'Angel', 'row3')"
      ::
      :+  ~2012.5.3
          %db1
          "FROM my-table T1 JOIN my-table-2 T2 ".
          "WHERE T1.col1 <= col3 SELECT T1.*, T2.col3, T2.col4"
      ::
      :-  %results
          :~  [%action 'SELECT']
              :-  %result-set
                  :~  :-  %vector
                          :~  [%col1 [~.t 'Angel']]
                              [%col2 [~.da ~2001.9.19]]
                              [%col3 [~.t 'Angel']]
                              [%col4 [~.t 'row3']]
                              ==
                      :-  %vector
                          :~  [%col1 [~.t 'Ace']]
                              [%col2 [~.da ~2005.12.19]]
                              [%col3 [~.t 'ticolor']]
                              [%col4 [~.t 'row2']]
                              ==
                      :-  %vector
                          :~  [%col1 [~.t 'Abby']]
                              [%col2 [~.da ~1999.2.19]]
                              [%col3 [~.t 'tricolor']]
                              [%col4 [~.t 'row1']]
                              ==
                      ==
              [%server-time ~2012.5.3]
              [%relation 'db1.dbo.my-table']
              [%schema-time ~2012.5.1]
              [%data-time ~2012.5.2]
              [%relation 'db1.dbo.my-table-2']
              [%schema-time ~2012.5.1]
              [%data-time ~2012.5.2]
              [%vector-count 3]
              ==
      ==
::
::  WHERE <column> <= <literal> (cord) joined
++  test-lte-joined-04
  =|  run=@ud
  %-  exec-2-1
  :*  run
      [~2012.4.30 %sys "CREATE DATABASE db1"]
      ::
      [~2012.5.1 %db1 create-joined-tables]
      ::
      :+  ~2012.5.2
          %db1
          "INSERT INTO my-table".
          " VALUES".
          " ('Abby', ~1999.2.19)".
          " ('Ace', ~2005.12.19)".
          " ('Angel', ~2001.9.19); ".
          "INSERT INTO my-table-2".
          " VALUES".
          " ('Abby', 'tricolor', 'row1')".
          " ('Ace', 'ticolor', 'row2')".
          " ('Angel', 'tuxedo', 'row3')"
      ::
      :+  ~2012.5.3
          %db1
          "FROM my-table T1 JOIN my-table-2 T2 ".
          "WHERE t1.col1 <= 'Ace' SELECT T1.*, T2.col3, T2.col4"
      ::
      :-  %results
          :~  [%action 'SELECT']
              :-  %result-set
                  :~  :-  %vector
                          :~  [%col1 [~.t 'Ace']]
                              [%col2 [~.da ~2005.12.19]]
                              [%col3 [~.t 'ticolor']]
                              [%col4 [~.t 'row2']]
                              ==
                      :-  %vector
                          :~  [%col1 [~.t 'Abby']]
                              [%col2 [~.da ~1999.2.19]]
                              [%col3 [~.t 'tricolor']]
                              [%col4 [~.t 'row1']]
                              ==
                      ==
              [%server-time ~2012.5.3]
              [%relation 'db1.dbo.my-table']
              [%schema-time ~2012.5.1]
              [%data-time ~2012.5.2]
              [%relation 'db1.dbo.my-table-2']
              [%schema-time ~2012.5.1]
              [%data-time ~2012.5.2]
              [%vector-count 2]
              ==
      ==
::
::  fail WHERE <column> <= <literal> types differ joined
++  test-fail-lte-joined-00
  =|  run=@ud
  %-  failon-3
  :*  run
      [~2012.4.30 %sys "CREATE DATABASE db1"]
      ::
      [~2012.5.1 %db1 create-joined-tables]
      ::
      :+  ~2012.5.2
          %db1
          "INSERT INTO my-table".
          " VALUES".
          " ('Abby', ~1999.2.19)".
          " ('Ace', ~2005.12.19)".
          " ('Angel', ~2001.9.19); ".
          "INSERT INTO my-table-2".
          " VALUES".
          " ('Abby', 'tricolor', 'row1')".
          " ('Ace', 'ticolor', 'row2')".
          " ('Angel', 'Angel', 'row3')"
      ::
      :+  ~2012.5.2
          %db1
          "FROM my-table T1 JOIN my-table-2 T2 ".
          "WHERE t1.col1 <= ~1999.2.19 SELECT T1.*, T2.col3, T2.col4"
      ::
      %-  crip
          "comparing column to literal of different aura: %col1 type=~.t ".
          "[p=~.da q=170.141.184.492.111.779.796.175.933.613.172.326.400]"
      ==
::
::  fail WHERE <literal> <= <column> types differ joined
++  test-fail-lte-joined-01
  =|  run=@ud
  %-  failon-3
  :*  run
      [~2012.4.30 %sys "CREATE DATABASE db1"]
      ::
      [~2012.5.1 %db1 create-joined-tables]
      ::
      :+  ~2012.5.2
          %db1
          "INSERT INTO my-table".
          " VALUES".
          " ('Abby', ~1999.2.19)".
          " ('Ace', ~2005.12.19)".
          " ('Angel', ~2001.9.19); ".
          "INSERT INTO my-table-2".
          " VALUES".
          " ('Abby', 'tricolor', 'row1')".
          " ('Ace', 'ticolor', 'row2')".
          " ('Angel', 'Angel', 'row3')"
      ::
      :+  ~2012.5.2
          %db1
          "FROM my-table T1 JOIN my-table-2 T2 ".
          "WHERE ~1999.2.19 <= t1.col1 SELECT T1.*, T2.col3, T2.col4"
      ::
      %-  crip
          "comparing literal to column of different aura: ".
          "[p=~.da q=170.141.184.492.111.779.796.175.933.613.172.326.400] ".
          "%col1 type=~.t"
      ==
::
::  fail WHERE <column> <= <column> types differ joined
++  test-fail-lte-joined-02
  =|  run=@ud
  %-  failon-3
  :*  run
      [~2012.4.30 %sys "CREATE DATABASE db1"]
      ::
      [~2012.5.1 %db1 create-joined-tables]
      ::
      :+  ~2012.5.2
          %db1
          "INSERT INTO my-table".
          " VALUES".
          " ('Abby', ~1999.2.19)".
          " ('Ace', ~2005.12.19)".
          " ('Angel', ~2001.9.19); ".
          "INSERT INTO my-table-2".
          " VALUES".
          " ('Abby', 'tricolor', 'row1')".
          " ('Ace', 'ticolor', 'row2')".
          " ('Angel', 'Angel', 'row3')"
      ::
      :+  ~2012.5.2
          %db1
          "FROM my-table T1 JOIN my-table-2 T2 ".
          "WHERE t1.col1 <= col2 SELECT T1.*, T2.col3, T2.col4"
      ::
      %-  crip
          "comparing columns of different auras: %col1 type=~.t %col2 type=~.da"
      ==
::
::  IN
::
::  WHERE <column> IN (list @t)
++  test-in-00
  =|  run=@ud
  %-  exec-2-1
  :*  run
      [~2012.4.30 %sys "CREATE DATABASE db1"]
      ::
      [~2012.5.1 %db1 create-mytable]
      ::
      :+  ~2012.5.2
          %db1
          "INSERT INTO my-table".
          " VALUES".
          " ('Abby', ~1999.2.19, 'tricolor', 'row1')".
          " ('Ace', ~2005.12.19, 'ticolor', 'row2')".
          " ('Angel', ~2001.9.19, 'tuxedo', 'row3')"
      ::
      :+  ~2012.5.3
          %db1
          "FROM my-table WHERE col3 IN ('ticolor', 'tricolor') SELECT *"
      ::
      :-  %results
          :~  [%action 'SELECT']
              :-  %result-set
                  :~  :-  %vector
                          :~  [%col1 [~.t 'Ace']]
                              [%col2 [~.da ~2005.12.19]]
                              [%col3 [~.t 'ticolor']]
                              [%col4 [~.t 'row2']]
                              ==
                      :-  %vector
                          :~  [%col1 [~.t 'Abby']]
                              [%col2 [~.da ~1999.2.19]]
                              [%col3 [~.t 'tricolor']]
                              [%col4 [~.t 'row1']]
                              ==
                      ==
              [%server-time ~2012.5.3]
              [%relation 'db1.dbo.my-table']
              [%schema-time ~2012.5.1]
              [%data-time ~2012.5.2]
              [%vector-count 2]
              ==
      ==
::
::  WHERE <column> IN (list @da) (@da)
++  test-in-01
  =|  run=@ud
  %-  exec-2-1
  :*  run
      [~2012.4.30 %sys "CREATE DATABASE db1"]
      ::
      [~2012.5.1 %db1 create-mytable]
      ::
      :+  ~2012.5.2
          %db1
          "INSERT INTO my-table".
          " VALUES".
          " ('Abby', ~1999.2.19, 'tricolor', 'row1')".
          " ('Ace', ~2005.12.19, 'ticolor', 'row2')".
          " ('Angel', ~2001.9.19, 'tuxedo', 'row3')"
      ::
      :+  ~2012.5.3
          %db1
          "FROM my-table WHERE col2 in(~2001.9.19, ~1999.2.19) SELECT *"
      ::
      :-  %results
          :~  [%action 'SELECT']
              :-  %result-set
                  :~  :-  %vector
                          :~  [%col1 [~.t 'Angel']]
                              [%col2 [~.da ~2001.9.19]]
                              [%col3 [~.t 'tuxedo']]
                              [%col4 [~.t 'row3']]
                              ==
                      :-  %vector
                          :~  [%col1 [~.t 'Abby']]
                              [%col2 [~.da ~1999.2.19]]
                              [%col3 [~.t 'tricolor']]
                              [%col4 [~.t 'row1']]
                              ==
                      ==
              [%server-time ~2012.5.3]
              [%relation 'db1.dbo.my-table']
              [%schema-time ~2012.5.1]
              [%data-time ~2012.5.2]
              [%vector-count 2]
              ==
      ==
::
::  WHERE <literal> IN (list @t)
++  test-in-02
  =|  run=@ud
  %-  exec-2-1
  :*  run
      [~2012.4.30 %sys "CREATE DATABASE db1"]
      ::
      [~2012.5.1 %db1 create-mytable]
      ::
      :+  ~2012.5.2
          %db1
          "INSERT INTO my-table".
          " VALUES".
          " ('Abby', ~1999.2.19, 'tricolor', 'row1')".
          " ('Ace', ~2005.12.19, 'ticolor', 'row2')".
          " ('Angel', ~2001.9.19, 'tuxedo', 'row3')"
      ::
      :+  ~2012.5.3
          %db1
          "FROM my-table WHERE 'tricolor' ".
          "IN ('tricolor', 'ticolor', 'tuxedo') SELECT *"
      ::
      :-  %results
          :~  [%action 'SELECT']
              :-  %result-set
                  :~  :-  %vector
                          :~  [%col1 [~.t 'Ace']]
                              [%col2 [~.da ~2005.12.19]]
                              [%col3 [~.t 'ticolor']]
                              [%col4 [~.t 'row2']]
                              ==
                      :-  %vector
                          :~  [%col1 [~.t 'Angel']]
                              [%col2 [~.da ~2001.9.19]]
                              [%col3 [~.t 'tuxedo']]
                              [%col4 [~.t 'row3']]
                              ==
                      :-  %vector
                          :~  [%col1 [~.t 'Abby']]
                              [%col2 [~.da ~1999.2.19]]
                              [%col3 [~.t 'tricolor']]
                              [%col4 [~.t 'row1']]
                              ==
                      ==
              [%server-time ~2012.5.3]
              [%relation 'db1.dbo.my-table']
              [%schema-time ~2012.5.1]
              [%data-time ~2012.5.2]
              [%vector-count 3]
              ==
      ==
::
::  WHERE <column> IN (list @)  (no matches)
++  test-in-03
  =|  run=@ud
  %-  exec-2-1
  :*  run
      [~2012.4.30 %sys "CREATE DATABASE db1"]
      ::
      [~2012.5.1 %db1 create-mytable]
      ::
      :+  ~2012.5.2
          %db1
          "INSERT INTO my-table".
          " VALUES".
          " ('Abby', ~1999.2.19, 'tricolor', 'row1')".
          " ('Ace', ~2005.12.19, 'ticolor', 'row2')".
          " ('Angel', ~2001.9.19, 'Angel', 'row3')"
      ::
      :+  ~2012.5.3
          %db1
          "FROM my-table WHERE col1 IN ('widget', 'bam') SELECT *"
      ::
      :-  %results
          :~  [%action 'SELECT']
              [%result-set ~]
              [%server-time ~2012.5.3]
              [%relation 'db1.dbo.my-table']
              [%schema-time ~2012.5.1]
              [%data-time ~2012.5.2]
              [%vector-count 0]
              ==
      ==
::
::  WHERE <column> IN (list @rs) +0 = -0
++  test-in-04
  =|  run=@ud
  %-  exec-2-1
  :*  run
      [~2012.4.30 %sys "CREATE DATABASE db1"]
      ::
      [~2012.5.1 %db1 create-rs-table]
      ::
      :+  ~2012.5.2
          %db1
          "INSERT INTO my-table".
          " VALUES".
          " ('row1', .-0)".
          " ('row2', .3.14)"
      ::
      :+  ~2012.5.3
          %db1
          "FROM my-table WHERE col2 IN (.0, .1.0) SELECT *"
      ::
      :-  %results
          :~  [%action 'SELECT']
              :-  %result-set
                  :~  :-  %vector
                          :~  [%col1 [~.t 'row1']]
                              [%col2 [~.rs .-0]]
                              ==
                      ==
              [%server-time ~2012.5.3]
              [%relation 'db1.dbo.my-table']
              [%schema-time ~2012.5.1]
              [%data-time ~2012.5.2]
              [%vector-count 1]
              ==
      ==
::
::  WHERE <column> IN (list @rd) +0 = -0
++  test-in-05
  =|  run=@ud
  %-  exec-2-1
  :*  run
      [~2012.4.30 %sys "CREATE DATABASE db1"]
      ::
      [~2012.5.1 %db1 create-rd-table]
      ::
      :+  ~2012.5.2
          %db1
          "INSERT INTO my-table".
          " VALUES".
          " ('row1', .~-0)".
          " ('row2', .~3.14)"
      ::
      :+  ~2012.5.3
          %db1
          "FROM my-table WHERE col2 IN (.~0, .~1.0) SELECT *"
      ::
      :-  %results
          :~  [%action 'SELECT']
              :-  %result-set
                  :~  :-  %vector
                          :~  [%col1 [~.t 'row1']]
                              [%col2 [~.rd .~-0]]
                              ==
                      ==
              [%server-time ~2012.5.3]
              [%relation 'db1.dbo.my-table']
              [%schema-time ~2012.5.1]
              [%data-time ~2012.5.2]
              [%vector-count 1]
              ==
      ==

::
::  fail WHERE <column> IN (list @t) types differ
++  test-fail-in-00
  =|  run=@ud
  %-  failon-3
  :*  run
      [~2012.4.30 %sys "CREATE DATABASE db1"]
      ::
      [~2012.5.1 %db1 create-mytable]
      ::
      :+  ~2012.5.2
          %db1
          "INSERT INTO my-table".
          " VALUES".
          " ('Abby', ~1999.2.19, 'tricolor', 'row1')".
          " ('Ace', ~2005.12.19, 'ticolor', 'row2')".
          " ('Angel', ~2001.9.19, 'Angel', 'row3')"
      ::
      :+  ~2012.5.2
          %db1
          "FROM my-table WHERE col3 ".
          "IN (~1999.2.19, ~2005.12.19, ~2001.9.19) SELECT *"
      ::
      %-  crip
          "type of IN list incorrect, should be ~.t"
      ==
::
::  fail WHERE <literal> IN (list @) types differ
++  test-fail-in-01
  =|  run=@ud
  %-  failon-3
  :*  run
      [~2012.4.30 %sys "CREATE DATABASE db1"]
      ::
      [~2012.5.1 %db1 create-mytable]
      ::
      :+  ~2012.5.2
          %db1
          "INSERT INTO my-table".
          " VALUES".
          " ('Abby', ~1999.2.19, 'tricolor', 'row1')".
          " ('Ace', ~2005.12.19, 'ticolor', 'row2')".
          " ('Angel', ~2001.9.19, 'Angel', 'row3')"
      ::
      :+  ~2012.5.2
          %db1
          "FROM my-table WHERE 'ticolor' ".
          "IN (~1999.2.19, ~2005.12.19, ~2001.9.19) SELECT *"
      ::
      %-  crip
          "type of IN list incorrect, should be ~.t"
      ==
::
::  WHERE <column> IN (list @t) joined
++  test-in-joined-00
  =|  run=@ud
  %-  exec-2-1
  :*  run
      [~2012.4.30 %sys "CREATE DATABASE db1"]
      ::
      [~2012.5.1 %db1 create-joined-tables]
      ::
      :+  ~2012.5.2
          %db1
          "INSERT INTO my-table".
          " VALUES".
          " ('Abby', ~1999.2.19)".
          " ('Ace', ~2005.12.19)".
          " ('Angel', ~2001.9.19); ".
          "INSERT INTO my-table-2".
          " VALUES".
          " ('Abby', 'tricolor', 'row1')".
          " ('Ace', 'ticolor', 'row2')".
          " ('Angel', 'tuxedo', 'row3')"
      ::
      :+  ~2012.5.3
          %db1
          "FROM my-table T1 JOIN my-table-2 T2 ".
          "WHERE col3 IN ('ticolor', 'tricolor') SELECT T1.*, T2.col3, T2.col4"
      ::
      :-  %results
          :~  [%action 'SELECT']
              :-  %result-set
                  :~  :-  %vector
                          :~  [%col1 [~.t 'Ace']]
                              [%col2 [~.da ~2005.12.19]]
                              [%col3 [~.t 'ticolor']]
                              [%col4 [~.t 'row2']]
                              ==
                      :-  %vector
                          :~  [%col1 [~.t 'Abby']]
                              [%col2 [~.da ~1999.2.19]]
                              [%col3 [~.t 'tricolor']]
                              [%col4 [~.t 'row1']]
                              ==
                      ==
              [%server-time ~2012.5.3]
              [%relation 'db1.dbo.my-table']
              [%schema-time ~2012.5.1]
              [%data-time ~2012.5.2]
              [%relation 'db1.dbo.my-table-2']
              [%schema-time ~2012.5.1]
              [%data-time ~2012.5.2]
              [%vector-count 2]
              ==
      ==
::
::  WHERE <column> IN (list @da) (@da) joined
++  test-in-joined-01
  =|  run=@ud
  %-  exec-2-1
  :*  run
      [~2012.4.30 %sys "CREATE DATABASE db1"]
      ::
      [~2012.5.1 %db1 create-joined-tables]
      ::
      :+  ~2012.5.2
          %db1
          "INSERT INTO my-table".
          " VALUES".
          " ('Abby', ~1999.2.19)".
          " ('Ace', ~2005.12.19)".
          " ('Angel', ~2001.9.19); ".
          "INSERT INTO my-table-2".
          " VALUES".
          " ('Abby', 'tricolor', 'row1')".
          " ('Ace', 'ticolor', 'row2')".
          " ('Angel', 'tuxedo', 'row3')"
      ::
      :+  ~2012.5.3
          %db1
          "FROM my-table T1 JOIN my-table-2 T2 ".
          "WHERE col2 in(~2001.9.19, ~1999.2.19) SELECT T1.*, T2.col3, T2.col4"
      ::
      :-  %results
          :~  [%action 'SELECT']
              :-  %result-set
                  :~  :-  %vector
                          :~  [%col1 [~.t 'Angel']]
                              [%col2 [~.da ~2001.9.19]]
                              [%col3 [~.t 'tuxedo']]
                              [%col4 [~.t 'row3']]
                              ==
                      :-  %vector
                          :~  [%col1 [~.t 'Abby']]
                              [%col2 [~.da ~1999.2.19]]
                              [%col3 [~.t 'tricolor']]
                              [%col4 [~.t 'row1']]
                              ==
                      ==
              [%server-time ~2012.5.3]
              [%relation 'db1.dbo.my-table']
              [%schema-time ~2012.5.1]
              [%data-time ~2012.5.2]
              [%relation 'db1.dbo.my-table-2']
              [%schema-time ~2012.5.1]
              [%data-time ~2012.5.2]
              [%vector-count 2]
              ==
      ==
::
::  WHERE <literal> IN (list @t) joined
++  test-in-joined-02
  =|  run=@ud
  %-  exec-2-1
  :*  run
      [~2012.4.30 %sys "CREATE DATABASE db1"]
      ::
      [~2012.5.1 %db1 create-joined-tables]
      ::
      :+  ~2012.5.2
          %db1
          "INSERT INTO my-table".
          " VALUES".
          " ('Abby', ~1999.2.19)".
          " ('Ace', ~2005.12.19)".
          " ('Angel', ~2001.9.19); ".
          "INSERT INTO my-table-2".
          " VALUES".
          " ('Abby', 'tricolor', 'row1')".
          " ('Ace', 'ticolor', 'row2')".
          " ('Angel', 'tuxedo', 'row3')"
      ::
      :+  ~2012.5.3
          %db1
          "FROM my-table T1 JOIN my-table-2 T2 ".
          "WHERE 'tricolor' IN ('tricolor', 'ticolor', 'tuxedo') ".
          "SELECT T1.*, T2.col3, T2.col4"
      ::
      :-  %results
          :~  [%action 'SELECT']
              :-  %result-set
                  :~  :-  %vector
                          :~  [%col1 [~.t 'Ace']]
                              [%col2 [~.da ~2005.12.19]]
                              [%col3 [~.t 'ticolor']]
                              [%col4 [~.t 'row2']]
                              ==
                      :-  %vector
                          :~  [%col1 [~.t 'Angel']]
                              [%col2 [~.da ~2001.9.19]]
                              [%col3 [~.t 'tuxedo']]
                              [%col4 [~.t 'row3']]
                              ==
                      :-  %vector
                          :~  [%col1 [~.t 'Abby']]
                              [%col2 [~.da ~1999.2.19]]
                              [%col3 [~.t 'tricolor']]
                              [%col4 [~.t 'row1']]
                              ==
                      ==
              [%server-time ~2012.5.3]
              [%relation 'db1.dbo.my-table']
              [%schema-time ~2012.5.1]
              [%data-time ~2012.5.2]
              [%relation 'db1.dbo.my-table-2']
              [%schema-time ~2012.5.1]
              [%data-time ~2012.5.2]
              [%vector-count 3]
              ==
      ==
::
::  WHERE <column> IN (list @)  (no matches) joined
++  test-in-joined-03
  =|  run=@ud
  %-  exec-2-1
  ::%-  debug-2-1
    :*  run
        [~2012.4.30 %sys "CREATE DATABASE db1"]
        ::
        [~2012.5.1 %db1 create-joined-tables]
        ::
        :+  ~2012.5.2
            %db1
            "INSERT INTO my-table".
            " VALUES".
            " ('Abby', ~1999.2.19)".
            " ('Ace', ~2005.12.19)".
            " ('Angel', ~2001.9.19); ".
            "INSERT INTO my-table-2".
            " VALUES".
            " ('Abby', 'tricolor', 'row1')".
            " ('Ace', 'ticolor', 'row2')".
            " ('Angel', 'Angel', 'row3')"
        ::
        :+  ~2012.5.3
            %db1
            "FROM my-table T1 JOIN my-table-2 T2 ".
            "WHERE t1.col1 IN ('widget', 'bam') SELECT T1.*, T2.col3, T2.col4"
        ::
        :-  %results
            :~  [%action 'SELECT']
                [%result-set ~]
                [%server-time ~2012.5.3]
                [%relation 'db1.dbo.my-table']
                [%schema-time ~2012.5.1]
                [%data-time ~2012.5.2]
                [%relation 'db1.dbo.my-table-2']
                [%schema-time ~2012.5.1]
                [%data-time ~2012.5.2]
                [%vector-count 0]
                ==
        ==
::
::  fail WHERE <column> IN (list @t) types differ joined
++  test-fail-in-joined-00
  =|  run=@ud
  %-  failon-3
  :*  run
      [~2012.4.30 %sys "CREATE DATABASE db1"]
      ::
      [~2012.5.1 %db1 create-joined-tables]
      ::
      :+  ~2012.5.2
          %db1
          "INSERT INTO my-table".
          " VALUES".
          " ('Abby', ~1999.2.19)".
          " ('Ace', ~2005.12.19)".
          " ('Angel', ~2001.9.19); ".
          "INSERT INTO my-table-2".
          " VALUES".
          " ('Abby', 'tricolor', 'row1')".
          " ('Ace', 'ticolor', 'row2')".
          " ('Angel', 'Angel', 'row3')"
      ::
      :+  ~2012.5.2
          %db1
          "FROM my-table T1 JOIN my-table-2 T2 ".
          "WHERE col3 IN (~1999.2.19, ~2005.12.19, ~2001.9.19) ".
          "SELECT T1.*, T2.col3, T2.col4"
      ::
      %-  crip
          "type of IN list incorrect, should be ~.t"
      ==
::
::  fail WHERE <literal> IN (list @) types differ joined
++  test-fail-in-joined-01
  =|  run=@ud
  %-  failon-3
  :*  run
      [~2012.4.30 %sys "CREATE DATABASE db1"]
      ::
      [~2012.5.1 %db1 create-joined-tables]
      ::
      :+  ~2012.5.2
          %db1
          "INSERT INTO my-table".
          " VALUES".
          " ('Abby', ~1999.2.19)".
          " ('Ace', ~2005.12.19)".
          " ('Angel', ~2001.9.19); ".
          "INSERT INTO my-table-2".
          " VALUES".
          " ('Abby', 'tricolor', 'row1')".
          " ('Ace', 'ticolor', 'row2')".
          " ('Angel', 'Angel', 'row3')"
      ::
      :+  ~2012.5.2
          %db1
          "FROM my-table T1 JOIN my-table-2 T2 ".
          "WHERE 'ticolor' IN (~1999.2.19, ~2005.12.19, ~2001.9.19) ".
          "SELECT T1.*, T2.col3, T2.col4"
      ::
      %-  crip
          "type of IN list incorrect, should be ~.t"
      ==
::
::  NOT IN
::
::  WHERE <column> NOT IN (list @t)
++  test-not-in-00
  =|  run=@ud
  %-  exec-2-1
  :*  run
      [~2012.4.30 %sys "CREATE DATABASE db1"]
      ::
      [~2012.5.1 %db1 create-mytable]
      ::
      :+  ~2012.5.2
          %db1
          "INSERT INTO my-table".
          " VALUES".
          " ('Abby', ~1999.2.19, 'tricolor', 'row1')".
          " ('Ace', ~2005.12.19, 'ticolor', 'row2')".
          " ('Angel', ~2001.9.19, 'tuxedo', 'row3')"
      ::
      :+  ~2012.5.3
          %db1
          "FROM my-table WHERE col3 NOT IN ('ticolor', 'tricolor') ".
          "SELECT *"
      ::
      :-  %results
          :~  [%action 'SELECT']
              :-  %result-set
                  :~  :-  %vector
                          :~  [%col1 [~.t 'Angel']]
                              [%col2 [~.da ~2001.9.19]]
                              [%col3 [~.t 'tuxedo']]
                              [%col4 [~.t 'row3']]
                              ==
                      ==
              [%server-time ~2012.5.3]
              [%relation 'db1.dbo.my-table']
              [%schema-time ~2012.5.1]
              [%data-time ~2012.5.2]
              [%vector-count 1]
              ==
      ==
::
::  WHERE <column> NOT IN (list @da) (@da)
++  test-not-in-01
  =|  run=@ud
  %-  exec-2-1
  :*  run
      [~2012.4.30 %sys "CREATE DATABASE db1"]
      ::
      [~2012.5.1 %db1 create-mytable]
      ::
      :+  ~2012.5.2
          %db1
          "INSERT INTO my-table".
          " VALUES".
          " ('Abby', ~1999.2.19, 'tricolor', 'row1')".
          " ('Ace', ~2005.12.19, 'ticolor', 'row2')".
          " ('Angel', ~2001.9.19, 'tuxedo', 'row3')"
      ::
      :+  ~2012.5.3
          %db1
          "FROM my-table WHERE col2 NOT IN (~2001.9.19, ~1999.2.19) ".
          "SELECT *"
      ::
      :-  %results
          :~  [%action 'SELECT']
              :-  %result-set
                  :~  :-  %vector
                          :~  [%col1 [~.t 'Ace']]
                              [%col2 [~.da ~2005.12.19]]
                              [%col3 [~.t 'ticolor']]
                              [%col4 [~.t 'row2']]
                              ==
                      ==
              [%server-time ~2012.5.3]
              [%relation 'db1.dbo.my-table']
              [%schema-time ~2012.5.1]
              [%data-time ~2012.5.2]
              [%vector-count 1]
              ==
      ==
::
::  WHERE <literal> NOT IN (list @t)  (no matches)
++  test-not-in-02
  =|  run=@ud
  %-  exec-2-1
  :*  run
      [~2012.4.30 %sys "CREATE DATABASE db1"]
      ::
      [~2012.5.1 %db1 create-mytable]
      ::
      :+  ~2012.5.2
          %db1
          "INSERT INTO my-table".
          " VALUES".
          " ('Abby', ~1999.2.19, 'tricolor', 'row1')".
          " ('Ace', ~2005.12.19, 'ticolor', 'row2')".
          " ('Angel', ~2001.9.19, 'tuxedo', 'row3')"
      ::
      :+  ~2012.5.3
          %db1
          "FROM my-table WHERE 'boo' ".
          "NOT IN ('tricolor', 'ticolor', 'tuxedo') SELECT *"
      ::
      :-  %results
          :~  [%action 'SELECT']
              :-  %result-set
                  :~  :-  %vector
                          :~  [%col1 [~.t 'Ace']]
                              [%col2 [~.da ~2005.12.19]]
                              [%col3 [~.t 'ticolor']]
                              [%col4 [~.t 'row2']]
                              ==
                      :-  %vector
                          :~  [%col1 [~.t 'Angel']]
                              [%col2 [~.da ~2001.9.19]]
                              [%col3 [~.t 'tuxedo']]
                              [%col4 [~.t 'row3']]
                              ==
                      :-  %vector
                          :~  [%col1 [~.t 'Abby']]
                              [%col2 [~.da ~1999.2.19]]
                              [%col3 [~.t 'tricolor']]
                              [%col4 [~.t 'row1']]
                              ==
                      ==
              [%server-time ~2012.5.3]
              [%relation 'db1.dbo.my-table']
              [%schema-time ~2012.5.1]
              [%data-time ~2012.5.2]
              [%vector-count 3]
              ==
      ==
::
::  WHERE <column> NOT IN (list @)
++  test-not-in-03
  =|  run=@ud
  %-  exec-2-1
  :*  run
      [~2012.4.30 %sys "CREATE DATABASE db1"]
      ::
      [~2012.5.1 %db1 create-mytable]
      ::
      :+  ~2012.5.2
          %db1
          "INSERT INTO my-table".
          " VALUES".
          " ('Abby', ~1999.2.19, 'tricolor', 'row1')".
          " ('Ace', ~2005.12.19, 'ticolor', 'row2')".
          " ('Angel', ~2001.9.19, 'Angel', 'row3')"
      ::
      :+  ~2012.5.3
          %db1
          "FROM my-table WHERE col1 NOT IN ('Abby', 'Ace', 'Angel') ".
          "SELECT *"
      ::
      :-  %results
          :~  [%action 'SELECT']
              [%result-set ~]
              [%server-time ~2012.5.3]
              [%relation 'db1.dbo.my-table']
              [%schema-time ~2012.5.1]
              [%data-time ~2012.5.2]
              [%vector-count 0]
              ==
      ==
::
::  fail WHERE <column> NOT IN (list @t) types differ
++  test-fail-not-in-00
  =|  run=@ud
  %-  failon-3
  :*  run
      [~2012.4.30 %sys "CREATE DATABASE db1"]
      ::
      [~2012.5.1 %db1 create-mytable]
      ::
      :+  ~2012.5.2
          %db1
          "INSERT INTO my-table".
          " VALUES".
          " ('Abby', ~1999.2.19, 'tricolor', 'row1')".
          " ('Ace', ~2005.12.19, 'ticolor', 'row2')".
          " ('Angel', ~2001.9.19, 'Angel', 'row3')"
      ::
      :+  ~2012.5.2
          %db1
          "FROM my-table WHERE col3 ".
          "IN (~1999.2.19, ~2005.12.19, ~2001.9.19) SELECT *"
      ::
      %-  crip
          "type of IN list incorrect, should be ~.t"
      ==
::
::  fail WHERE <literal> NOT IN (list @) types differ
++  test-fail-not-in-01
  =|  run=@ud
  %-  failon-3
  :*  run
      [~2012.4.30 %sys "CREATE DATABASE db1"]
      ::
      [~2012.5.1 %db1 create-mytable]
      ::
      :+  ~2012.5.2
          %db1
          "INSERT INTO my-table".
          " VALUES".
          " ('Abby', ~1999.2.19, 'tricolor', 'row1')".
          " ('Ace', ~2005.12.19, 'ticolor', 'row2')".
          " ('Angel', ~2001.9.19, 'Angel', 'row3')"
      ::
      :+  ~2012.5.2
          %db1
          "FROM my-table WHERE 'ticolor' ".
          "IN (~1999.2.19, ~2005.12.19, ~2001.9.19) SELECT *"
      ::
      %-  crip
          "type of IN list incorrect, should be ~.t"
      ==
::
::  WHERE <column> NOT IN (list @t) joined
++  test-not-in-joined-00
  =|  run=@ud
  %-  exec-2-1
  :*  run
      [~2012.4.30 %sys "CREATE DATABASE db1"]
      ::
      [~2012.5.1 %db1 create-joined-tables]
      ::
      :+  ~2012.5.2
          %db1
          "INSERT INTO my-table".
          " VALUES".
          " ('Abby', ~1999.2.19)".
          " ('Ace', ~2005.12.19)".
          " ('Angel', ~2001.9.19); ".
          "INSERT INTO my-table-2".
          " VALUES".
          " ('Abby', 'tricolor', 'row1')".
          " ('Ace', 'ticolor', 'row2')".
          " ('Angel', 'tuxedo', 'row3')"
      ::
      :+  ~2012.5.3
          %db1
          "FROM my-table T1 JOIN my-table-2 T2 ".
          "WHERE col3 NOT IN ('ticolor', 'tricolor') ".
          "SELECT T1.*, T2.col3, T2.col4"
      ::
      :-  %results
          :~  [%action 'SELECT']
              :-  %result-set
                  :~  :-  %vector
                          :~  [%col1 [~.t 'Angel']]
                              [%col2 [~.da ~2001.9.19]]
                              [%col3 [~.t 'tuxedo']]
                              [%col4 [~.t 'row3']]
                              ==
                      ==
              [%server-time ~2012.5.3]
              [%relation 'db1.dbo.my-table']
              [%schema-time ~2012.5.1]
              [%data-time ~2012.5.2]
              [%relation 'db1.dbo.my-table-2']
              [%schema-time ~2012.5.1]
              [%data-time ~2012.5.2]
              [%vector-count 1]
              ==
      ==
::
::  WHERE <column> NOT IN (list @da) (@da) joined
++  test-not-in-joined-01
  =|  run=@ud
  %-  exec-2-1
  :*  run
      [~2012.4.30 %sys "CREATE DATABASE db1"]
      ::
      [~2012.5.1 %db1 create-joined-tables]
      ::
      :+  ~2012.5.2
          %db1
          "INSERT INTO my-table".
          " VALUES".
          " ('Abby', ~1999.2.19)".
          " ('Ace', ~2005.12.19)".
          " ('Angel', ~2001.9.19); ".
          "INSERT INTO my-table-2".
          " VALUES".
          " ('Abby', 'tricolor', 'row1')".
          " ('Ace', 'ticolor', 'row2')".
          " ('Angel', 'tuxedo', 'row3')"
      ::
      :+  ~2012.5.3
          %db1
          "FROM my-table T1 JOIN my-table-2 T2 ".
          "WHERE col2 NOT IN (~2001.9.19, ~1999.2.19) ".
          "SELECT T1.*, T2.col3, T2.col4"
      ::
      :-  %results
          :~  [%action 'SELECT']
              :-  %result-set
                  :~  :-  %vector
                          :~  [%col1 [~.t 'Ace']]
                              [%col2 [~.da ~2005.12.19]]
                              [%col3 [~.t 'ticolor']]
                              [%col4 [~.t 'row2']]
                              ==
                      ==
              [%server-time ~2012.5.3]
              [%relation 'db1.dbo.my-table']
              [%schema-time ~2012.5.1]
              [%data-time ~2012.5.2]
              [%relation 'db1.dbo.my-table-2']
              [%schema-time ~2012.5.1]
              [%data-time ~2012.5.2]
              [%vector-count 1]
              ==
      ==
::
::  WHERE <literal> NOT IN (list @t)  (no matches) joined
++  test-not-in-joined-02
  =|  run=@ud
  %-  exec-2-1
  :*  run
      [~2012.4.30 %sys "CREATE DATABASE db1"]
      ::
      [~2012.5.1 %db1 create-joined-tables]
      ::
      :+  ~2012.5.2
          %db1
          "INSERT INTO my-table".
          " VALUES".
          " ('Abby', ~1999.2.19)".
          " ('Ace', ~2005.12.19)".
          " ('Angel', ~2001.9.19); ".
          "INSERT INTO my-table-2".
          " VALUES".
          " ('Abby', 'tricolor', 'row1')".
          " ('Ace', 'ticolor', 'row2')".
          " ('Angel', 'tuxedo', 'row3')"
      ::
      :+  ~2012.5.3
          %db1
          "FROM my-table T1 JOIN my-table-2 T2 ".
          "WHERE 'boo' NOT IN ('tricolor', 'ticolor', 'tuxedo') ".
          "SELECT T1.*, T2.col3, T2.col4"
      ::
      :-  %results
          :~  [%action 'SELECT']
              :-  %result-set
                  :~  :-  %vector
                          :~  [%col1 [~.t 'Ace']]
                              [%col2 [~.da ~2005.12.19]]
                              [%col3 [~.t 'ticolor']]
                              [%col4 [~.t 'row2']]
                              ==
                      :-  %vector
                          :~  [%col1 [~.t 'Angel']]
                              [%col2 [~.da ~2001.9.19]]
                              [%col3 [~.t 'tuxedo']]
                              [%col4 [~.t 'row3']]
                              ==
                      :-  %vector
                          :~  [%col1 [~.t 'Abby']]
                              [%col2 [~.da ~1999.2.19]]
                              [%col3 [~.t 'tricolor']]
                              [%col4 [~.t 'row1']]
                              ==
                      ==
              [%server-time ~2012.5.3]
              [%relation 'db1.dbo.my-table']
              [%schema-time ~2012.5.1]
              [%data-time ~2012.5.2]
              [%relation 'db1.dbo.my-table-2']
              [%schema-time ~2012.5.1]
              [%data-time ~2012.5.2]
              [%vector-count 3]
              ==
      ==
::
::  WHERE <column> NOT IN (list @) joined
++  test-not-in-joined-03
  =|  run=@ud
  %-  exec-2-1
  :*  run
      [~2012.4.30 %sys "CREATE DATABASE db1"]
      ::
      [~2012.5.1 %db1 create-joined-tables]
      ::
      :+  ~2012.5.2
          %db1
          "INSERT INTO my-table".
          " VALUES".
          " ('Abby', ~1999.2.19)".
          " ('Ace', ~2005.12.19)".
          " ('Angel', ~2001.9.19); ".
          "INSERT INTO my-table-2".
          " VALUES".
          " ('Abby', 'tricolor', 'row1')".
          " ('Ace', 'ticolor', 'row2')".
          " ('Angel', 'Angel', 'row3')"
      ::
      :+  ~2012.5.3
          %db1
          "FROM my-table T1 JOIN my-table-2 T2 ".
          "WHERE t1.col1 NOT IN ('Abby', 'Ace', 'Angel') ".
          "SELECT T1.*, T2.col3, T2.col4"
      ::
      :-  %results
          :~  [%action 'SELECT']
              [%result-set ~]
              [%server-time ~2012.5.3]
              [%relation 'db1.dbo.my-table']
              [%schema-time ~2012.5.1]
              [%data-time ~2012.5.2]
              [%relation 'db1.dbo.my-table-2']
              [%schema-time ~2012.5.1]
              [%data-time ~2012.5.2]
              [%vector-count 0]
              ==
      ==
::
::  fail WHERE <column> NOT IN (list @t) types differ joined
++  test-fail-not-in-joined-00
  =|  run=@ud
  %-  failon-3
  :*  run
      [~2012.4.30 %sys "CREATE DATABASE db1"]
      ::
      [~2012.5.1 %db1 create-joined-tables]
      ::
      :+  ~2012.5.2
          %db1
          "INSERT INTO my-table".
          " VALUES".
          " ('Abby', ~1999.2.19)".
          " ('Ace', ~2005.12.19)".
          " ('Angel', ~2001.9.19); ".
          "INSERT INTO my-table-2".
          " VALUES".
          " ('Abby', 'tricolor', 'row1')".
          " ('Ace', 'ticolor', 'row2')".
          " ('Angel', 'Angel', 'row3')"
      ::
      :+  ~2012.5.2
          %db1
          "FROM my-table T1 JOIN my-table-2 T2 ".
          "WHERE col3 IN (~1999.2.19, ~2005.12.19, ~2001.9.19) ".
          "SELECT T1.*, T2.col3, T2.col4"
      ::
      %-  crip
          "type of IN list incorrect, should be ~.t"
      ==
::
::  fail WHERE <literal> NOT IN (list @) types differ joined
++  test-fail-not-in-joined-01
  =|  run=@ud
  %-  failon-3
  :*  run
      [~2012.4.30 %sys "CREATE DATABASE db1"]
      ::
      [~2012.5.1 %db1 create-joined-tables]
      ::
      :+  ~2012.5.2
          %db1
          "INSERT INTO my-table".
          " VALUES".
          " ('Abby', ~1999.2.19)".
          " ('Ace', ~2005.12.19)".
          " ('Angel', ~2001.9.19); ".
          "INSERT INTO my-table-2".
          " VALUES".
          " ('Abby', 'tricolor', 'row1')".
          " ('Ace', 'ticolor', 'row2')".
          " ('Angel', 'Angel', 'row3')"
      ::
      :+  ~2012.5.2
          %db1
          "FROM my-table T1 JOIN my-table-2 T2 ".
          "WHERE 'ticolor' IN (~1999.2.19, ~2005.12.19, ~2001.9.19) ".
          "SELECT T1.*, T2.col3, T2.col4"
      ::
      %-  crip
          "type of IN list incorrect, should be ~.t"
      ==
::
::  BETWEEN
::
::  WHERE <column> BETWEEN <literal> AND <literal>
++  test-between-00
  =|  run=@ud
  %-  exec-2-1
  :*  run
      [~2012.4.30 %sys "CREATE DATABASE db1"]
      ::
      [~2012.5.1 %db1 create-mytable]
      ::
      :+  ~2012.5.2
          %db1
          "INSERT INTO my-table".
          " VALUES".
          " ('Abby', ~1999.2.19, 'tricolor', 'row1')".
          " ('Ace', ~2005.12.19, 'ticolor', 'row2')".
          " ('Angel', ~2001.9.19, 'tuxedo', 'row3')"
      ::
      :+  ~2012.5.3
          %db1
          "FROM my-table WHERE col3 BETWEEN 'ticolor' AND 'tummy' ".
          "SELECT *"
      ::
      :-  %results
          :~  [%action 'SELECT']
              :-  %result-set
                  :~  :-  %vector
                          :~  [%col1 [~.t 'Ace']]
                              [%col2 [~.da ~2005.12.19]]
                              [%col3 [~.t 'ticolor']]
                              [%col4 [~.t 'row2']]
                              ==
                      :-  %vector
                          :~  [%col1 [~.t 'Abby']]
                              [%col2 [~.da ~1999.2.19]]
                              [%col3 [~.t 'tricolor']]
                              [%col4 [~.t 'row1']]
                              ==
                      ==
              [%server-time ~2012.5.3]
              [%relation 'db1.dbo.my-table']
              [%schema-time ~2012.5.1]
              [%data-time ~2012.5.2]
              [%vector-count 2]
              ==
      ==
::
::  WHERE <literal> BETWEEN <column> AND <literal>
++  test-between-01
  =|  run=@ud
  %-  exec-2-1
  :*  run
      [~2012.4.30 %sys "CREATE DATABASE db1"]
      ::
      [~2012.5.1 %db1 create-mytable]
      ::
      :+  ~2012.5.2
          %db1
          "INSERT INTO my-table".
          " VALUES".
          " ('Abby', ~1999.2.19, 'tricolor', 'row1')".
          " ('Ace', ~2005.12.19, 'ticolor', 'row2')".
          " ('Angel', ~2001.9.19, 'tuxedo', 'row3')"
      ::
      :+  ~2012.5.3
          %db1
          "FROM my-table WHERE 'tuxedo' BETWEEN col3 AND 'tuxedos' ".
          "SELECT *"
      ::
      :-  %results
          :~  [%action 'SELECT']
              :-  %result-set
                  :~  :-  %vector
                          :~  [%col1 [~.t 'Ace']]
                              [%col2 [~.da ~2005.12.19]]
                              [%col3 [~.t 'ticolor']]
                              [%col4 [~.t 'row2']]
                              ==
                      :-  %vector
                          :~  [%col1 [~.t 'Angel']]
                              [%col2 [~.da ~2001.9.19]]
                              [%col3 [~.t 'tuxedo']]
                              [%col4 [~.t 'row3']]
                              ==
                      :-  %vector
                          :~  [%col1 [~.t 'Abby']]
                              [%col2 [~.da ~1999.2.19]]
                              [%col3 [~.t 'tricolor']]
                              [%col4 [~.t 'row1']]
                              ==
                      ==
              [%server-time ~2012.5.3]
              [%relation 'db1.dbo.my-table']
              [%schema-time ~2012.5.1]
              [%data-time ~2012.5.2]
              [%vector-count 3]
              ==
      ==
::
::  WHERE <column> BETWEEN <column> <column> (no optional AND)
++  test-between-02
  =|  run=@ud
  %-  exec-2-1
  :*  run
      [~2012.4.30 %sys "CREATE DATABASE db1"]
      ::
      [~2012.5.1 %db1 create-mytable]
      ::
      :+  ~2012.5.2
          %db1
          "INSERT INTO my-table".
          " VALUES".
          " ('Abby', ~1999.2.19, 'tricolor', 'row1')".
          " ('Ace', ~2005.12.19, 'ticolor', 'row2')".
          " ('Angel', ~2001.9.19, 'Angel', 'row3')"
      ::
      :+  ~2012.5.3
          %db1
          "FROM my-table WHERE col1 BETWEEN col3 col4 SELECT *"
      ::
      :-  %results
          :~  [%action 'SELECT']
              :-  %result-set
                  :~  :-  %vector
                          :~  [%col1 [~.t 'Angel']]
                              [%col2 [~.da ~2001.9.19]]
                              [%col3 [~.t 'Angel']]
                              [%col4 [~.t 'row3']]
                              ==
                      ==
              [%server-time ~2012.5.3]
              [%relation 'db1.dbo.my-table']
              [%schema-time ~2012.5.1]
              [%data-time ~2012.5.2]
              [%vector-count 1]
              ==
      ==
::
::  view WHERE <column> BETWEEN <literal> AND <literal>
++  test-between-03
  =|  run=@ud
  %-  exec-1-1
  :*  run
      [~2012.4.30 %sys "CREATE DATABASE db1"]
      ::
      [~2012.5.1 %db1 create-mytable]
      ::
      :+  ~2012.5.3
          %db1
          "FROM sys.columns WHERE col-name BETWEEN 'col2' AND 'col3' ".
          "SELECT *"
      ::
      :-  %results
          :~  [%action 'SELECT']
              :-  %result-set
                  :~  :-  %vector
                          :~  [p=%namespace q=[p=~.tas q=%dbo]]
                              [p=%name q=[p=~.tas q=%my-table]]
                              [p=%col-ordinal q=[p=~.ud q=2]]
                              [p=%col-name q=[p=~.tas q=%col2]]
                              [p=%col-type q=[p=~.ta q=~.da]]
                              ==
                      :-  %vector
                          :~  [p=%namespace q=[p=~.tas q=%dbo]]
                              [p=%name q=[p=~.tas q=%my-table]]
                              [p=%col-ordinal q=[p=~.ud q=3]]
                              [p=%col-name q=[p=~.tas q=%col3]]
                              [p=%col-type q=[p=~.ta q=~.t]]
                              ==
                      ==
              [%server-time ~2012.5.3]
              [%relation 'db1.sys.columns']
              [%schema-time ~2012.5.1]
              [%data-time ~2012.5.1]
              [%vector-count 2]
              ==
      ==
::
::  fail WHERE <column> BETWEEN <literal> AND <literal> types differ
++  test-fail-between-00
  =|  run=@ud
  %-  failon-3
  :*  run
      [~2012.4.30 %sys "CREATE DATABASE db1"]
      ::
      [~2012.5.1 %db1 create-mytable]
      ::
      :+  ~2012.5.2
          %db1
          "INSERT INTO my-table".
          " VALUES".
          " ('Abby', ~1999.2.19, 'tricolor', 'row1')".
          " ('Ace', ~2005.12.19, 'ticolor', 'row2')".
          " ('Angel', ~2001.9.19, 'Angel', 'row3')"
      ::
      :+  ~2012.5.2
          %db1
          "FROM my-table WHERE col1 BETWEEN ~1999.2.19 AND 'row1' ".
          "SELECT *"
      ::
      %-  crip
          "comparing column to literal of different aura: %col1 type=~.t ".
          "[p=~.da q=170.141.184.492.111.779.796.175.933.613.172.326.400]"
      ==
::
::  fail WHERE <literal> BETWEEN <column> AND <column> types differ
++  test-fail-between-01
  =|  run=@ud
  %-  failon-3
  :*  run
      [~2012.4.30 %sys "CREATE DATABASE db1"]
      ::
      [~2012.5.1 %db1 create-mytable]
      ::
      :+  ~2012.5.2
          %db1
          "INSERT INTO my-table".
          " VALUES".
          " ('Abby', ~1999.2.19, 'tricolor', 'row1')".
          " ('Ace', ~2005.12.19, 'ticolor', 'row2')".
          " ('Angel', ~2001.9.19, 'Angel', 'row3')"
      ::
      :+  ~2012.5.2
          %db1
          "FROM my-table WHERE ~1999.2.19 BETWEEN col1 ".
          "AND col2 SELECT *"
      ::
      %-  crip
          "comparing literal to column of different aura: ".
          "[p=~.da q=170.141.184.492.111.779.796.175.933.613.172.326.400] ".
          "%col1 type=~.t"
      ==
::
::  fail WHERE <column> BETWEEN <column> AND <column> types differ
++  test-fail-between-02
  =|  run=@ud
  %-  failon-3
  :*  run
      [~2012.4.30 %sys "CREATE DATABASE db1"]
      ::
      [~2012.5.1 %db1 create-mytable]
      ::
      :+  ~2012.5.2
          %db1
          "INSERT INTO my-table".
          " VALUES".
          " ('Abby', ~1999.2.19, 'tricolor', 'row1')".
          " ('Ace', ~2005.12.19, 'ticolor', 'row2')".
          " ('Angel', ~2001.9.19, 'Angel', 'row3')"
      ::
      :+  ~2012.5.2
          %db1
          "FROM my-table WHERE col1 BETWEEN col2 AND col3 SELECT *"
      ::
      %-  crip
          "comparing columns of different auras: %col1 type=~.t %col2 type=~.da"
      ==
::
::  fail WHERE <column> BETWEEN <column> AND <column> range not ascending
++  test-fail-between-03
  =|  run=@ud
  %-  failon-3
  :*  run
      [~2012.4.30 %sys "CREATE DATABASE db1"]
      ::
      [~2012.5.1 %db1 create-mytable]
      ::
      :+  ~2012.5.2
          %db1
          "INSERT INTO my-table".
          " VALUES".
          " ('Abby', ~1999.2.19, 'tricolor', 'row1')".
          " ('Ace', ~2005.12.19, 'ticolor', 'row2')".
          " ('Angel', ~2001.9.19, 'Angel', 'row3')"
      ::
      :+  ~2012.5.2
          %db1
          "FROM my-table WHERE col1 BETWEEN ~2005.12.19 ".
          "AND ~1999.2.19 SELECT *"
      ::
      %-  crip
          "comparing column to literal of different aura: %col1 type=~.t ".
          "[p=~.da q=170.141.184.496.088.307.522.657.354.235.930.214.400]"
      ==
::
::  WHERE <column> BETWEEN <literal> AND <literal> joined
++  test-between-joined-00
  =|  run=@ud
  %-  exec-2-1
  :*  run
      [~2012.4.30 %sys "CREATE DATABASE db1"]
      ::
      [~2012.5.1 %db1 create-joined-tables]
      ::
      :+  ~2012.5.2
          %db1
          "INSERT INTO my-table".
          " VALUES".
          " ('Abby', ~1999.2.19)".
          " ('Ace', ~2005.12.19)".
          " ('Angel', ~2001.9.19); ".
          "INSERT INTO my-table-2".
          " VALUES".
          " ('Abby', 'tricolor', 'row1')".
          " ('Ace', 'ticolor', 'row2')".
          " ('Angel', 'tuxedo', 'row3')"
      ::
      :+  ~2012.5.3
          %db1
          "FROM my-table T1 JOIN my-table-2 T2 ".
          "WHERE col3 BETWEEN 'ticolor' AND 'tummy' ".
          "SELECT T1.*, T2.col3, T2.col4"
      ::
      :-  %results
          :~  [%action 'SELECT']
              :-  %result-set
                  :~  :-  %vector
                          :~  [%col1 [~.t 'Ace']]
                              [%col2 [~.da ~2005.12.19]]
                              [%col3 [~.t 'ticolor']]
                              [%col4 [~.t 'row2']]
                              ==
                      :-  %vector
                          :~  [%col1 [~.t 'Abby']]
                              [%col2 [~.da ~1999.2.19]]
                              [%col3 [~.t 'tricolor']]
                              [%col4 [~.t 'row1']]
                              ==
                      ==
              [%server-time ~2012.5.3]
              [%relation 'db1.dbo.my-table']
              [%schema-time ~2012.5.1]
              [%data-time ~2012.5.2]
              [%relation 'db1.dbo.my-table-2']
              [%schema-time ~2012.5.1]
              [%data-time ~2012.5.2]
              [%vector-count 2]
              ==
      ==
::
::  WHERE <literal> BETWEEN <column> AND <literal> joined
++  test-between-joined-01
  =|  run=@ud
  %-  exec-2-1
  :*  run
      [~2012.4.30 %sys "CREATE DATABASE db1"]
      ::
      [~2012.5.1 %db1 create-joined-tables]
      ::
      :+  ~2012.5.2
          %db1
          "INSERT INTO my-table".
          " VALUES".
          " ('Abby', ~1999.2.19)".
          " ('Ace', ~2005.12.19)".
          " ('Angel', ~2001.9.19); ".
          "INSERT INTO my-table-2".
          " VALUES".
          " ('Abby', 'tricolor', 'row1')".
          " ('Ace', 'ticolor', 'row2')".
          " ('Angel', 'tuxedo', 'row3')"
      ::
      :+  ~2012.5.3
          %db1
          "FROM my-table T1 JOIN my-table-2 T2 ".
          "WHERE 'tuxedo' BETWEEN col3 AND 'tuxedos' ".
          "SELECT T1.*, T2.col3, T2.col4"
      ::
      :-  %results
          :~  [%action 'SELECT']
              :-  %result-set
                  :~  :-  %vector
                          :~  [%col1 [~.t 'Ace']]
                              [%col2 [~.da ~2005.12.19]]
                              [%col3 [~.t 'ticolor']]
                              [%col4 [~.t 'row2']]
                              ==
                      :-  %vector
                          :~  [%col1 [~.t 'Angel']]
                              [%col2 [~.da ~2001.9.19]]
                              [%col3 [~.t 'tuxedo']]
                              [%col4 [~.t 'row3']]
                              ==
                      :-  %vector
                          :~  [%col1 [~.t 'Abby']]
                              [%col2 [~.da ~1999.2.19]]
                              [%col3 [~.t 'tricolor']]
                              [%col4 [~.t 'row1']]
                              ==
                      ==
              [%server-time ~2012.5.3]
              [%relation 'db1.dbo.my-table']
              [%schema-time ~2012.5.1]
              [%data-time ~2012.5.2]
              [%relation 'db1.dbo.my-table-2']
              [%schema-time ~2012.5.1]
              [%data-time ~2012.5.2]
              [%vector-count 3]
              ==
      ==
::
::  WHERE <column> BETWEEN <column> <column> (no optional AND) joined
++  test-between-joined-02
  =|  run=@ud
  %-  exec-2-1
  :*  run
      [~2012.4.30 %sys "CREATE DATABASE db1"]
      ::
      [~2012.5.1 %db1 create-joined-tables]
      ::
      :+  ~2012.5.2
          %db1
          "INSERT INTO my-table".
          " VALUES".
          " ('Abby', ~1999.2.19)".
          " ('Ace', ~2005.12.19)".
          " ('Angel', ~2001.9.19); ".
          "INSERT INTO my-table-2".
          " VALUES".
          " ('Abby', 'tricolor', 'row1')".
          " ('Ace', 'ticolor', 'row2')".
          " ('Angel', 'Angel', 'row3')"
      ::
      :+  ~2012.5.3
          %db1
          "FROM my-table T1 JOIN my-table-2 T2 ".
          "WHERE t1.col1 BETWEEN col3 col4 SELECT T1.*, T2.col3, T2.col4"
      ::
      :-  %results
          :~  [%action 'SELECT']
              :-  %result-set
                  :~  :-  %vector
                          :~  [%col1 [~.t 'Angel']]
                              [%col2 [~.da ~2001.9.19]]
                              [%col3 [~.t 'Angel']]
                              [%col4 [~.t 'row3']]
                              ==
                      ==
              [%server-time ~2012.5.3]
              [%relation 'db1.dbo.my-table']
              [%schema-time ~2012.5.1]
              [%data-time ~2012.5.2]
              [%relation 'db1.dbo.my-table-2']
              [%schema-time ~2012.5.1]
              [%data-time ~2012.5.2]
              [%vector-count 1]
              ==
      ==
::
::  fail WHERE <column> BETWEEN <literal> AND <literal> types differ joined
++  test-fail-between-joined-00
  =|  run=@ud
  %-  failon-3
  :*  run
      [~2012.4.30 %sys "CREATE DATABASE db1"]
      ::
      [~2012.5.1 %db1 create-joined-tables]
      ::
      :+  ~2012.5.2
          %db1
          "INSERT INTO my-table".
          " VALUES".
          " ('Abby', ~1999.2.19)".
          " ('Ace', ~2005.12.19)".
          " ('Angel', ~2001.9.19); ".
          "INSERT INTO my-table-2".
          " VALUES".
          " ('Abby', 'tricolor', 'row1')".
          " ('Ace', 'ticolor', 'row2')".
          " ('Angel', 'Angel', 'row3')"
      ::
      :+  ~2012.5.2
          %db1
          "FROM my-table T1 JOIN my-table-2 T2 ".
          "WHERE t1.col1 BETWEEN ~1999.2.19 AND 'row1' ".
          "SELECT T1.*, T2.col3, T2.col4"
      ::
      %-  crip
          "comparing column to literal of different aura: %col1 type=~.t ".
          "[p=~.da q=170.141.184.492.111.779.796.175.933.613.172.326.400]"
      ==
::
::  fail WHERE <literal> BETWEEN <column> AND <column> types differ joined
++  test-fail-between-joined-01
  =|  run=@ud
  %-  failon-3
  :*  run
      [~2012.4.30 %sys "CREATE DATABASE db1"]
      ::
      [~2012.5.1 %db1 create-joined-tables]
      ::
      :+  ~2012.5.2
          %db1
          "INSERT INTO my-table".
          " VALUES".
          " ('Abby', ~1999.2.19)".
          " ('Ace', ~2005.12.19)".
          " ('Angel', ~2001.9.19); ".
          "INSERT INTO my-table-2".
          " VALUES".
          " ('Abby', 'tricolor', 'row1')".
          " ('Ace', 'ticolor', 'row2')".
          " ('Angel', 'Angel', 'row3')"
      ::
      :+  ~2012.5.2
          %db1
          "FROM my-table T1 JOIN my-table-2 T2 ".
          "WHERE ~1999.2.19 BETWEEN t1.col1 ".
          "AND col2 SELECT T1.*, T2.col3, T2.col4"
      ::
      %-  crip
          "comparing literal to column of different aura: ".
          "[p=~.da q=170.141.184.492.111.779.796.175.933.613.172.326.400] ".
          "%col1 type=~.t"
      ==
::
::  fail WHERE <column> BETWEEN <column> AND <column> types differ joined
++  test-fail-between-joined-02
  =|  run=@ud
  %-  failon-3
  :*  run
      [~2012.4.30 %sys "CREATE DATABASE db1"]
      ::
      [~2012.5.1 %db1 create-joined-tables]
      ::
      :+  ~2012.5.2
          %db1
          "INSERT INTO my-table".
          " VALUES".
          " ('Abby', ~1999.2.19)".
          " ('Ace', ~2005.12.19)".
          " ('Angel', ~2001.9.19); ".
          "INSERT INTO my-table-2".
          " VALUES".
          " ('Abby', 'tricolor', 'row1')".
          " ('Ace', 'ticolor', 'row2')".
          " ('Angel', 'Angel', 'row3')"
      ::
      :+  ~2012.5.2
          %db1
          "FROM my-table T1 JOIN my-table-2 T2 ".
          "WHERE t1.col1 BETWEEN col2 AND col3 ".
          "SELECT T1.*, T2.col3, T2.col4"
      ::
      %-  crip
          "comparing columns of different auras: %col1 type=~.t %col2 type=~.da"
      ==
::
::  fail WHERE <column> BETWEEN <column> & <column> range not ascending joined
++  test-fail-between-joined-03
  =|  run=@ud
  %-  failon-3
  :*  run
      [~2012.4.30 %sys "CREATE DATABASE db1"]
      ::
      [~2012.5.1 %db1 create-joined-tables]
      ::
      :+  ~2012.5.2
          %db1
          "INSERT INTO my-table".
          " VALUES".
          " ('Abby', ~1999.2.19)".
          " ('Ace', ~2005.12.19)".
          " ('Angel', ~2001.9.19); ".
          "INSERT INTO my-table-2".
          " VALUES".
          " ('Abby', 'tricolor', 'row1')".
          " ('Ace', 'ticolor', 'row2')".
          " ('Angel', 'Angel', 'row3')"
      ::
      :+  ~2012.5.2
          %db1
          "FROM my-table T1 JOIN my-table-2 T2 ".
          "WHERE t1.col1 BETWEEN ~2005.12.19 ".
          "AND ~1999.2.19 SELECT T1.*, T2.col3, T2.col4"
      ::
      %-  crip
          "comparing column to literal of different aura: %col1 type=~.t ".
          "[p=~.da q=170.141.184.496.088.307.522.657.354.235.930.214.400]"
      ==
::
::  NOT BETWEEN
::
::  WHERE <column> NOT BETWEEN <literal> AND <literal>
++  test-not-between-00
  =|  run=@ud
  %-  exec-2-1
  :*  run
      [~2012.4.30 %sys "CREATE DATABASE db1"]
      ::
      [~2012.5.1 %db1 create-mytable]
      ::
      :+  ~2012.5.2
          %db1
          "INSERT INTO my-table".
          " VALUES".
          " ('Abby', ~1999.2.19, 'tricolor', 'row1')".
          " ('Ace', ~2005.12.19, 'ticolor', 'row2')".
          " ('Angel', ~2001.9.19, 'tuxedo', 'row3')"
      ::
      :+  ~2012.5.3
          %db1
          "FROM my-table WHERE col3 NOT BETWEEN 'ticolor' ".
          "AND 'tummy' SELECT *"
      ::
      :-  %results
          :~  [%action 'SELECT']
              :-  %result-set
                  :~  :-  %vector
                          :~  [%col1 [~.t 'Angel']]
                              [%col2 [~.da ~2001.9.19]]
                              [%col3 [~.t 'tuxedo']]
                              [%col4 [~.t 'row3']]
                              ==
                      ==
              [%server-time ~2012.5.3]
              [%relation 'db1.dbo.my-table']
              [%schema-time ~2012.5.1]
              [%data-time ~2012.5.2]
              [%vector-count 1]
              ==
      ==
::
::  WHERE <literal> NOT BETWEEN <column> AND <literal>
++  test-not-between-01
  =|  run=@ud
  %-  exec-2-1
  :*  run
      [~2012.4.30 %sys "CREATE DATABASE db1"]
      ::
      [~2012.5.1 %db1 create-mytable]
      ::
      :+  ~2012.5.2
          %db1
          "INSERT INTO my-table".
          " VALUES".
          " ('Abby', ~1999.2.19, 'tricolor', 'row1')".
          " ('Ace', ~2005.12.19, 'ticolor', 'row2')".
          " ('Angel', ~2001.9.19, 'tuxedo', 'row3')"
      ::
      :+  ~2012.5.3
          %db1
          "FROM my-table WHERE 'tuxedo' NOT BETWEEN col3 ".
          "AND 'tuxedos' SELECT *"
      ::
      :-  %results
          :~  [%action 'SELECT']
              [%result-set ~]
              [%server-time ~2012.5.3]
              [%relation 'db1.dbo.my-table']
              [%schema-time ~2012.5.1]
              [%data-time ~2012.5.2]
              [%vector-count 0]
              ==
      ==
::
::  WHERE <column> NOT BETWEEN <column> <column> (no optional AND)
++  test-not-between-02
  =|  run=@ud
  %-  exec-2-1
  :*  run
      [~2012.4.30 %sys "CREATE DATABASE db1"]
      ::
      [~2012.5.1 %db1 create-mytable]
      ::
      :+  ~2012.5.2
          %db1
          "INSERT INTO my-table".
          " VALUES".
          " ('Abby', ~1999.2.19, 'tricolor', 'row1')".
          " ('Ace', ~2005.12.19, 'ticolor', 'row2')".
          " ('Angel', ~2001.9.19, 'Angel', 'row3')"
      ::
      :+  ~2012.5.3
          %db1
          "FROM my-table WHERE col1 NOT BETWEEN col3 col4 SELECT *"
      ::
      :-  %results
          :~  [%action 'SELECT']
              :-  %result-set
                  :~  :-  %vector
                          :~  [%col1 [~.t 'Ace']]
                              [%col2 [~.da ~2005.12.19]]
                              [%col3 [~.t 'ticolor']]
                              [%col4 [~.t 'row2']]
                              ==
                      :-  %vector
                          :~  [%col1 [~.t 'Abby']]
                              [%col2 [~.da ~1999.2.19]]
                              [%col3 [~.t 'tricolor']]
                              [%col4 [~.t 'row1']]
                              ==
                      ==
              [%server-time ~2012.5.3]
              [%relation 'db1.dbo.my-table']
              [%schema-time ~2012.5.1]
              [%data-time ~2012.5.2]
              [%vector-count 2]
              ==
      ==
::
::  view WHERE <column> NOT BETWEEN <literal> AND <literal>
++  test-not-between-03
  =|  run=@ud
  %-  exec-1-1
  :*  run
      [~2012.4.30 %sys "CREATE DATABASE db1"]
      ::
      [~2012.5.1 %db1 create-mytable]
      ::
      :+  ~2012.5.3
          %db1
          "FROM sys.columns WHERE col-name NOT BETWEEN 'col2' ".
          "AND 'col3' SELECT *"
      ::
      :-  %results
          :~  [%action 'SELECT']
              :-  %result-set
                  :~  :-  %vector
                          :~  [p=%namespace q=[p=~.tas q=%dbo]]
                              [p=%name q=[p=~.tas q=%my-table]]
                              [p=%col-ordinal q=[p=~.ud q=1]]
                              [p=%col-name q=[p=~.tas q=%col1]]
                              [p=%col-type q=[p=~.ta q=~.t]]
                              ==
                      :-  %vector
                          :~  [p=%namespace q=[p=~.tas q=%dbo]]
                              [p=%name q=[p=~.tas q=%my-table]]
                              [p=%col-ordinal q=[p=~.ud q=4]]
                              [p=%col-name q=[p=~.tas q=%col4]]
                              [p=%col-type q=[p=~.ta q=~.t]]
                              ==
                      ==
              [%server-time ~2012.5.3]
              [%relation 'db1.sys.columns']
              [%schema-time ~2012.5.1]
              [%data-time ~2012.5.1]
              [%vector-count 2]
              ==
      ==
::
::  fail WHERE <column> NOT BETWEEN <literal> AND <literal> types differ
++  test-fail-not-between-00
  =|  run=@ud
  %-  failon-3
  :*  run
      [~2012.4.30 %sys "CREATE DATABASE db1"]
      ::
      [~2012.5.1 %db1 create-mytable]
      ::
      :+  ~2012.5.2
          %db1
          "INSERT INTO my-table".
          " VALUES".
          " ('Abby', ~1999.2.19, 'tricolor', 'row1')".
          " ('Ace', ~2005.12.19, 'ticolor', 'row2')".
          " ('Angel', ~2001.9.19, 'Angel', 'row3')"
      ::
      :+  ~2012.5.2
          %db1
          "FROM my-table WHERE col1 NOT BETWEEN ~1999.2.19 ".
          "AND 'row1' SELECT *"
      ::
      %-  crip
          "comparing column to literal of different aura: %col1 type=~.t ".
          "[p=~.da q=170.141.184.492.111.779.796.175.933.613.172.326.400]"
      ==
::
::  fail WHERE <literal> NOT BETWEEN <column> AND <column> types differ
++  test-fail-not-between-01
  =|  run=@ud
  %-  failon-3
  :*  run
      [~2012.4.30 %sys "CREATE DATABASE db1"]
      ::
      [~2012.5.1 %db1 create-mytable]
      ::
      :+  ~2012.5.2
          %db1
          "INSERT INTO my-table".
          " VALUES".
          " ('Abby', ~1999.2.19, 'tricolor', 'row1')".
          " ('Ace', ~2005.12.19, 'ticolor', 'row2')".
          " ('Angel', ~2001.9.19, 'Angel', 'row3')"
      ::
      :+  ~2012.5.2
          %db1
          "FROM my-table WHERE ~1999.2.19 NOT BETWEEN col1 ".
          "AND col2 SELECT *"
      ::
      %-  crip
          "comparing literal to column of different aura: ".
          "[p=~.da q=170.141.184.492.111.779.796.175.933.613.172.326.400] ".
          "%col1 type=~.t"
      ==
::
::  fail WHERE <column> NOT BETWEEN <column> AND <column> types differ
++  test-fail-not-between-02
  =|  run=@ud
  %-  failon-3
  :*  run
      [~2012.4.30 %sys "CREATE DATABASE db1"]
      ::
      [~2012.5.1 %db1 create-mytable]
      ::
      :+  ~2012.5.2
          %db1
          "INSERT INTO my-table".
          " VALUES".
          " ('Abby', ~1999.2.19, 'tricolor', 'row1')".
          " ('Ace', ~2005.12.19, 'ticolor', 'row2')".
          " ('Angel', ~2001.9.19, 'Angel', 'row3')"
      ::
      :+  ~2012.5.2
          %db1
          "FROM my-table WHERE col1 NOT BETWEEN col2 AND col3 SELECT *"
      ::
      %-  crip
          "comparing columns of different auras: %col1 type=~.t %col2 type=~.da"
      ==
::
::  fail WHERE <column> NOT BETWEEN <column> AND <column> range not ascending
++  test-fail-not-between-03
  =|  run=@ud
  %-  failon-3
  :*  run
      [~2012.4.30 %sys "CREATE DATABASE db1"]
      ::
      [~2012.5.1 %db1 create-mytable]
      ::
      :+  ~2012.5.2
          %db1
          "INSERT INTO my-table".
          " VALUES".
          " ('Abby', ~1999.2.19, 'tricolor', 'row1')".
          " ('Ace', ~2005.12.19, 'ticolor', 'row2')".
          " ('Angel', ~2001.9.19, 'Angel', 'row3')"
      ::
      :+  ~2012.5.2
          %db1
          "FROM my-table WHERE col1 NOT BETWEEN ~2005.12.19 ".
          "AND ~1999.2.19 SELECT *"
      ::
      %-  crip
          "comparing column to literal of different aura: %col1 type=~.t ".
          "[p=~.da q=170.141.184.496.088.307.522.657.354.235.930.214.400]"
      ==
::
::  WHERE <column> NOT BETWEEN <literal> AND <literal> joined
++  test-not-between-joined-00
  =|  run=@ud
  %-  exec-2-1
  :*  run
      [~2012.4.30 %sys "CREATE DATABASE db1"]
      ::
      [~2012.5.1 %db1 create-joined-tables]
      ::
      :+  ~2012.5.2
          %db1
          "INSERT INTO my-table".
          " VALUES".
          " ('Abby', ~1999.2.19)".
          " ('Ace', ~2005.12.19)".
          " ('Angel', ~2001.9.19); ".
          "INSERT INTO my-table-2".
          " VALUES".
          " ('Abby', 'tricolor', 'row1')".
          " ('Ace', 'ticolor', 'row2')".
          " ('Angel', 'tuxedo', 'row3')"
      ::
      :+  ~2012.5.3
          %db1
          "FROM my-table T1 JOIN my-table-2 T2 ".
          "WHERE col3 NOT BETWEEN 'ticolor' AND 'tummy' ".
          "SELECT T1.*, T2.col3, T2.col4"
      ::
      :-  %results
          :~  [%action 'SELECT']
              :-  %result-set
                  :~  :-  %vector
                          :~  [%col1 [~.t 'Angel']]
                              [%col2 [~.da ~2001.9.19]]
                              [%col3 [~.t 'tuxedo']]
                              [%col4 [~.t 'row3']]
                              ==
                      ==
              [%server-time ~2012.5.3]
              [%relation 'db1.dbo.my-table']
              [%schema-time ~2012.5.1]
              [%data-time ~2012.5.2]
              [%relation 'db1.dbo.my-table-2']
              [%schema-time ~2012.5.1]
              [%data-time ~2012.5.2]
              [%vector-count 1]
              ==
      ==
::
::  WHERE <literal> NOT BETWEEN <column> AND <literal> joined
++  test-not-between-joined-01
  =|  run=@ud
  %-  exec-2-1
  :*  run
      [~2012.4.30 %sys "CREATE DATABASE db1"]
      ::
      [~2012.5.1 %db1 create-joined-tables]
      ::
      :+  ~2012.5.2
          %db1
          "INSERT INTO my-table".
          " VALUES".
          " ('Abby', ~1999.2.19)".
          " ('Ace', ~2005.12.19)".
          " ('Angel', ~2001.9.19); ".
          "INSERT INTO my-table-2".
          " VALUES".
          " ('Abby', 'tricolor', 'row1')".
          " ('Ace', 'ticolor', 'row2')".
          " ('Angel', 'tuxedo', 'row3')"
      ::
      :+  ~2012.5.3
          %db1
          "FROM my-table T1 JOIN my-table-2 T2 ".
          "WHERE 'tuxedo' NOT BETWEEN col3 AND 'tuxedos' ".
          "SELECT T1.*, T2.col3, T2.col4"
      ::
      :-  %results
          :~  [%action 'SELECT']
              [%result-set ~]
              [%server-time ~2012.5.3]
              [%relation 'db1.dbo.my-table']
              [%schema-time ~2012.5.1]
              [%data-time ~2012.5.2]
              [%relation 'db1.dbo.my-table-2']
              [%schema-time ~2012.5.1]
              [%data-time ~2012.5.2]
              [%vector-count 0]
              ==
      ==
::
::  WHERE <column> NOT BETWEEN <column> <column> (no optional AND) joined
++  test-not-between-joined-02
  =|  run=@ud
  %-  exec-2-1
  :*  run
      [~2012.4.30 %sys "CREATE DATABASE db1"]
      ::
      [~2012.5.1 %db1 create-joined-tables]
      ::
      :+  ~2012.5.2
          %db1
          "INSERT INTO my-table".
          " VALUES".
          " ('Abby', ~1999.2.19)".
          " ('Ace', ~2005.12.19)".
          " ('Angel', ~2001.9.19); ".
          "INSERT INTO my-table-2".
          " VALUES".
          " ('Abby', 'tricolor', 'row1')".
          " ('Ace', 'ticolor', 'row2')".
          " ('Angel', 'Angel', 'row3')"
      ::
      :+  ~2012.5.3
          %db1
          "FROM my-table T1 JOIN my-table-2 T2 ".
          "WHERE t1.col1 NOT BETWEEN col3 col4 ".
          "SELECT T1.*, T2.col3, T2.col4"
      ::
      :-  %results
          :~  [%action 'SELECT']
              :-  %result-set
                  :~  :-  %vector
                          :~  [%col1 [~.t 'Ace']]
                              [%col2 [~.da ~2005.12.19]]
                              [%col3 [~.t 'ticolor']]
                              [%col4 [~.t 'row2']]
                              ==
                      :-  %vector
                          :~  [%col1 [~.t 'Abby']]
                              [%col2 [~.da ~1999.2.19]]
                              [%col3 [~.t 'tricolor']]
                              [%col4 [~.t 'row1']]
                              ==
                      ==
              [%server-time ~2012.5.3]
              [%relation 'db1.dbo.my-table']
              [%schema-time ~2012.5.1]
              [%data-time ~2012.5.2]
              [%relation 'db1.dbo.my-table-2']
              [%schema-time ~2012.5.1]
              [%data-time ~2012.5.2]
              [%vector-count 2]
              ==
      ==
::
::  fail WHERE <column> NOT BETWEEN <literal> AND <literal> types differ joined
++  test-fail-not-between-joined-00
  =|  run=@ud
  %-  failon-3
  :*  run
      [~2012.4.30 %sys "CREATE DATABASE db1"]
      ::
      [~2012.5.1 %db1 create-joined-tables]
      ::
      :+  ~2012.5.2
          %db1
          "INSERT INTO my-table".
          " VALUES".
          " ('Abby', ~1999.2.19)".
          " ('Ace', ~2005.12.19)".
          " ('Angel', ~2001.9.19); ".
          "INSERT INTO my-table-2".
          " VALUES".
          " ('Abby', 'tricolor', 'row1')".
          " ('Ace', 'ticolor', 'row2')".
          " ('Angel', 'Angel', 'row3')"
      ::
      :+  ~2012.5.2
          %db1
          "FROM my-table T1 JOIN my-table-2 T2 ".
          "WHERE t1.col1 NOT BETWEEN ~1999.2.19 ".
          "AND 'row1' SELECT T1.*, T2.col3, T2.col4"
      ::
      %-  crip
          "comparing column to literal of different aura: %col1 type=~.t ".
          "[p=~.da q=170.141.184.492.111.779.796.175.933.613.172.326.400]"
      ==
::
::  fail WHERE <literal> NOT BETWEEN <column> AND <column> types differ joined
++  test-fail-not-between-joined-01
  =|  run=@ud
  %-  failon-3
  :*  run
      [~2012.4.30 %sys "CREATE DATABASE db1"]
      ::
      [~2012.5.1 %db1 create-joined-tables]
      ::
      :+  ~2012.5.2
          %db1
          "INSERT INTO my-table".
          " VALUES".
          " ('Abby', ~1999.2.19)".
          " ('Ace', ~2005.12.19)".
          " ('Angel', ~2001.9.19); ".
          "INSERT INTO my-table-2".
          " VALUES".
          " ('Abby', 'tricolor', 'row1')".
          " ('Ace', 'ticolor', 'row2')".
          " ('Angel', 'Angel', 'row3')"
      ::
      :+  ~2012.5.2
          %db1
          "FROM my-table T1 JOIN my-table-2 T2 ".
          "WHERE ~1999.2.19 NOT BETWEEN t1.col1 ".
          "AND col2 SELECT T1.*, T2.col3, T2.col4"
      ::
      %-  crip
          "comparing literal to column of different aura: ".
          "[p=~.da q=170.141.184.492.111.779.796.175.933.613.172.326.400] ".
          "%col1 type=~.t"
      ==
::
::  fail WHERE <column> NOT BETWEEN <column> AND <column> types differ joined
++  test-fail-not-between-joined-02
  =|  run=@ud
  %-  failon-3
  :*  run
      [~2012.4.30 %sys "CREATE DATABASE db1"]
      ::
      [~2012.5.1 %db1 create-joined-tables]
      ::
      :+  ~2012.5.2
          %db1
          "INSERT INTO my-table".
          " VALUES".
          " ('Abby', ~1999.2.19)".
          " ('Ace', ~2005.12.19)".
          " ('Angel', ~2001.9.19); ".
          "INSERT INTO my-table-2".
          " VALUES".
          " ('Abby', 'tricolor', 'row1')".
          " ('Ace', 'ticolor', 'row2')".
          " ('Angel', 'Angel', 'row3')"
      ::
      :+  ~2012.5.2
          %db1
          "FROM my-table T1 JOIN my-table-2 T2 ".
          "WHERE t1.col1 NOT BETWEEN col2 AND col3 ".
          "SELECT T1.*, T2.col3, T2.col4"
      ::
      %-  crip
          "comparing columns of different auras: %col1 type=~.t %col2 type=~.da"
      ==
::
::  fail WHERE <column> NOT BETWEEN <column> AND <column> range not ascending joined
++  test-fail-not-between-joined-03
  =|  run=@ud
  %-  failon-3
  :*  run
      [~2012.4.30 %sys "CREATE DATABASE db1"]
      ::
      [~2012.5.1 %db1 create-joined-tables]
      ::
      :+  ~2012.5.2
          %db1
          "INSERT INTO my-table".
          " VALUES".
          " ('Abby', ~1999.2.19)".
          " ('Ace', ~2005.12.19)".
          " ('Angel', ~2001.9.19); ".
          "INSERT INTO my-table-2".
          " VALUES".
          " ('Abby', 'tricolor', 'row1')".
          " ('Ace', 'ticolor', 'row2')".
          " ('Angel', 'Angel', 'row3')"
      ::
      :+  ~2012.5.2
          %db1
          "FROM my-table T1 JOIN my-table-2 T2 ".
          "WHERE t1.col1 NOT BETWEEN ~2005.12.19 ".
          "AND ~1999.2.19 SELECT T1.*, T2.col3, T2.col4"
      ::
      %-  crip
          "comparing column to literal of different aura: %col1 type=~.t ".
          "[p=~.da q=170.141.184.496.088.307.522.657.354.235.930.214.400]"
      ==
::
::  OR
::
::  WHERE <column> = <literal> OR <column> = <literal>
++  test-or-00
  =|  run=@ud
  %-  exec-2-1
  :*  run
      [~2012.4.30 %sys "CREATE DATABASE db1"]
      ::
      [~2012.5.1 %db1 create-mytable]
      ::
      :+  ~2012.5.2
          %db1
          "INSERT INTO my-table".
          " VALUES".
          " ('Abby', ~1999.2.19, 'tricolor', 'row1')".
          " ('Ace', ~2005.12.19, 'ticolor', 'row2')".
          " ('Angel', ~2001.9.19, 'tuxedo', 'row3')"
      ::
      :+  ~2012.5.3
          %db1
          "FROM my-table WHERE col3 = 'ticolor' OR col3='tricolor' ".
          "SELECT *"
      ::
      :-  %results
          :~  [%action 'SELECT']
              :-  %result-set
                  :~  :-  %vector
                          :~  [%col1 [~.t 'Ace']]
                              [%col2 [~.da ~2005.12.19]]
                              [%col3 [~.t 'ticolor']]
                              [%col4 [~.t 'row2']]
                              ==
                      :-  %vector
                          :~  [%col1 [~.t 'Abby']]
                              [%col2 [~.da ~1999.2.19]]
                              [%col3 [~.t 'tricolor']]
                              [%col4 [~.t 'row1']]
                              ==
                      ==
              [%server-time ~2012.5.3]
              [%relation 'db1.dbo.my-table']
              [%schema-time ~2012.5.1]
              [%data-time ~2012.5.2]
              [%vector-count 2]
              ==
      ==
::
::  WHERE <column> = <column> OR <column> = <column>
++  test-or-01
  =|  run=@ud
  %-  exec-2-1
  :*  run
      [~2012.4.30 %sys "CREATE DATABASE db1"]
      ::
      [~2012.5.1 %db1 create-mytable]
      ::
      :+  ~2012.5.2
          %db1
          "INSERT INTO my-table".
          " VALUES".
          " ('Abby', ~1999.2.19, 'tricolor', 'row1')".
          " ('Ace', ~2005.12.19, 'ticolor', 'row2')".
          " ('Angel', ~2001.9.19, 'Angel', 'row3')"
      ::
      :+  ~2012.5.3
          %db1
          "FROM my-table WHERE col1 = col3 OR col3=col4 SELECT *"
      ::
      :-  %results
          :~  [%action 'SELECT']
              :-  %result-set
                  :~  :-  %vector
                          :~  [%col1 [~.t 'Angel']]
                              [%col2 [~.da ~2001.9.19]]
                              [%col3 [~.t 'Angel']]
                              [%col4 [~.t 'row3']]
                              ==
                      ==
              [%server-time ~2012.5.3]
              [%relation 'db1.dbo.my-table']
              [%schema-time ~2012.5.1]
              [%data-time ~2012.5.2]
              [%vector-count 1]
              ==
      ==
::
::  WHERE <column> = ... AND ... OR ... AND ...
++  test-or-02
  =|  run=@ud
  %-  exec-2-1
  :*  run
      [~2012.4.30 %sys "CREATE DATABASE db1"]
      ::
      [~2012.5.1 %db1 create-mytable]
      ::
      :+  ~2012.5.2
          %db1
          "INSERT INTO my-table".
          " VALUES".
          " ('Abby', ~1999.2.19, 'tricolor', 'row1')".
          " ('Ace', ~2005.12.19, 'ticolor', 'row2')".
          " ('Angel', ~2001.9.19, 'tuxedo', 'row3')"
      ::
      :+  ~2012.5.3
          %db1
          "FROM my-table WHERE (col3 = 'ticolor' AND col4='row2') ".
          "OR (col3='tricolor' AND col4='row1') SELECT *"
      ::
      :-  %results
          :~  [%action 'SELECT']
              :-  %result-set
                  :~  :-  %vector
                          :~  [%col1 [~.t 'Ace']]
                              [%col2 [~.da ~2005.12.19]]
                              [%col3 [~.t 'ticolor']]
                              [%col4 [~.t 'row2']]
                              ==
                      :-  %vector
                          :~  [%col1 [~.t 'Abby']]
                              [%col2 [~.da ~1999.2.19]]
                              [%col3 [~.t 'tricolor']]
                              [%col4 [~.t 'row1']]
                              ==
                      ==
              [%server-time ~2012.5.3]
              [%relation 'db1.dbo.my-table']
              [%schema-time ~2012.5.1]
              [%data-time ~2012.5.2]
              [%vector-count 2]
              ==
      ==
::
::  WHERE <column> = <literal> OR <column> = <literal> joined
++  test-or-joined-00
  =|  run=@ud
  %-  exec-2-1
  :*  run
      [~2012.4.30 %sys "CREATE DATABASE db1"]
      ::
      [~2012.5.1 %db1 create-joined-tables]
      ::
      :+  ~2012.5.2
          %db1
          "INSERT INTO my-table".
          " VALUES".
          " ('Abby', ~1999.2.19)".
          " ('Ace', ~2005.12.19)".
          " ('Angel', ~2001.9.19); ".
          "INSERT INTO my-table-2".
          " VALUES".
          " ('Abby', 'tricolor', 'row1')".
          " ('Ace', 'ticolor', 'row2')".
          " ('Angel', 'tuxedo', 'row3')"
      ::
      :+  ~2012.5.3
          %db1
          "FROM my-table T1 JOIN my-table-2 T2 ".
          "WHERE col3 = 'ticolor' OR t1.col1='Abby' ".
          "SELECT T1.*, T2.col3, T2.col4"
      ::
      :-  %results
          :~  [%action 'SELECT']
              :-  %result-set
                  :~  :-  %vector
                          :~  [%col1 [~.t 'Ace']]
                              [%col2 [~.da ~2005.12.19]]
                              [%col3 [~.t 'ticolor']]
                              [%col4 [~.t 'row2']]
                              ==
                      :-  %vector
                          :~  [%col1 [~.t 'Abby']]
                              [%col2 [~.da ~1999.2.19]]
                              [%col3 [~.t 'tricolor']]
                              [%col4 [~.t 'row1']]
                              ==
                      ==
              [%server-time ~2012.5.3]
              [%relation 'db1.dbo.my-table']
              [%schema-time ~2012.5.1]
              [%data-time ~2012.5.2]
              [%relation 'db1.dbo.my-table-2']
              [%schema-time ~2012.5.1]
              [%data-time ~2012.5.2]
              [%vector-count 2]
              ==
      ==
::
::  WHERE <column> = <column> OR <column> = <column> joined
++  test-or-joined-01
  =|  run=@ud
  %-  exec-2-1
  :*  run
      [~2012.4.30 %sys "CREATE DATABASE db1"]
      ::
      [~2012.5.1 %db1 create-joined-tables]
      ::
      :+  ~2012.5.2
          %db1
          "INSERT INTO my-table".
          " VALUES".
          " ('Abby', ~1999.2.19)".
          " ('Ace', ~2005.12.19)".
          " ('Angel', ~2001.9.19); ".
          "INSERT INTO my-table-2".
          " VALUES".
          " ('Abby', 'tricolor', 'row1')".
          " ('Ace', 'ticolor', 'row2')".
          " ('Angel', 'Angel', 'row3')"
      ::
      :+  ~2012.5.3
          %db1
          "FROM my-table T1 JOIN my-table-2 T2 ".
          "WHERE t1.col1 = col3 OR col3=col4 ".
          "SELECT T1.*, T2.col3, T2.col4"
      ::
      :-  %results
          :~  [%action 'SELECT']
              :-  %result-set
                  :~  :-  %vector
                          :~  [%col1 [~.t 'Angel']]
                              [%col2 [~.da ~2001.9.19]]
                              [%col3 [~.t 'Angel']]
                              [%col4 [~.t 'row3']]
                              ==
                      ==
              [%server-time ~2012.5.3]
              [%relation 'db1.dbo.my-table']
              [%schema-time ~2012.5.1]
              [%data-time ~2012.5.2]
              [%relation 'db1.dbo.my-table-2']
              [%schema-time ~2012.5.1]
              [%data-time ~2012.5.2]
              [%vector-count 1]
              ==
      ==
::
::  WHERE <column> = ... AND ... OR ... AND ... joined
++  test-or-joined-02
  =|  run=@ud
  %-  exec-2-1
  :*  run
      [~2012.4.30 %sys "CREATE DATABASE db1"]
      ::
      [~2012.5.1 %db1 create-joined-tables]
      ::
      :+  ~2012.5.2
          %db1
          "INSERT INTO my-table".
          " VALUES".
          " ('Abby', ~1999.2.19)".
          " ('Ace', ~2005.12.19)".
          " ('Angel', ~2001.9.19); ".
          "INSERT INTO my-table-2".
          " VALUES".
          " ('Abby', 'tricolor', 'row1')".
          " ('Ace', 'ticolor', 'row2')".
          " ('Angel', 'tuxedo', 'row3')"
      ::
      :+  ~2012.5.3
          %db1
          "FROM my-table  T1 JOIN my-table-2 T2 ".
          "WHERE (col3 = 'ticolor' AND col4='row2') ".
          "OR (col3='tricolor' AND col4='row1') ".
          "SELECT T1.*, T2.col3, T2.col4"
      ::
      :-  %results
          :~  [%action 'SELECT']
              :-  %result-set
                  :~  :-  %vector
                          :~  [%col1 [~.t 'Ace']]
                              [%col2 [~.da ~2005.12.19]]
                              [%col3 [~.t 'ticolor']]
                              [%col4 [~.t 'row2']]
                              ==
                      :-  %vector
                          :~  [%col1 [~.t 'Abby']]
                              [%col2 [~.da ~1999.2.19]]
                              [%col3 [~.t 'tricolor']]
                              [%col4 [~.t 'row1']]
                              ==
                      ==
              [%server-time ~2012.5.3]
              [%relation 'db1.dbo.my-table']
              [%schema-time ~2012.5.1]
              [%data-time ~2012.5.2]
              [%relation 'db1.dbo.my-table-2']
              [%schema-time ~2012.5.1]
              [%data-time ~2012.5.2]
              [%vector-count 2]
              ==
      ==
::
::  AND
::
::  WHERE <column> = <literal> AND <column> = <literal>
++  test-and-00
  =|  run=@ud
  %-  exec-2-1
  :*  run
      [~2012.4.30 %sys "CREATE DATABASE db1"]
      ::
      [~2012.5.1 %db1 create-mytable]
      ::
      :+  ~2012.5.2
          %db1
          "INSERT INTO my-table".
          " VALUES".
          " ('Abby', ~1999.2.19, 'tricolor', 'row1')".
          " ('Ace', ~2005.12.19, 'ticolor', 'row2')".
          " ('Angel', ~2001.9.19, 'tuxedo', 'row3')"
      ::
      :+  ~2012.5.3
          %db1
          "FROM my-table WHERE col3 = 'ticolor' AND col4='row2' SELECT *"
      ::
      :-  %results
          :~  [%action 'SELECT']
              :-  %result-set
                  :~  :-  %vector
                          :~  [%col1 [~.t 'Ace']]
                              [%col2 [~.da ~2005.12.19]]
                              [%col3 [~.t 'ticolor']]
                              [%col4 [~.t 'row2']]
                              ==
                      ==
              [%server-time ~2012.5.3]
              [%relation 'db1.dbo.my-table']
              [%schema-time ~2012.5.1]
              [%data-time ~2012.5.2]
              [%vector-count 1]
              ==
      ==
::
::  WHERE <column> = <column> AND <column> = <literal>
++  test-and-01
  =|  run=@ud
  %-  exec-2-1
  :*  run
      [~2012.4.30 %sys "CREATE DATABASE db1"]
      ::
      [~2012.5.1 %db1 create-mytable]
      ::
      :+  ~2012.5.2
          %db1
          "INSERT INTO my-table".
          " VALUES".
          " ('Abby', ~1999.2.19, 'tricolor', 'row1')".
          " ('Ace', ~2005.12.19, 'ticolor', 'row2')".
          " ('Angel', ~2001.9.19, 'Angel', 'row3')"
      ::
      :+  ~2012.5.3
          %db1
          "FROM my-table WHERE col1 = col3 AND col4='row3' SELECT *"
      ::
      :-  %results
          :~  [%action 'SELECT']
              :-  %result-set
                  :~  :-  %vector
                          :~  [%col1 [~.t 'Angel']]
                              [%col2 [~.da ~2001.9.19]]
                              [%col3 [~.t 'Angel']]
                              [%col4 [~.t 'row3']]
                              ==
                      ==
              [%server-time ~2012.5.3]
              [%relation 'db1.dbo.my-table']
              [%schema-time ~2012.5.1]
              [%data-time ~2012.5.2]
              [%vector-count 1]
              ==
      ==
::
::  WHERE <column> = <literal> AND <column> = <literal> joined
++  test-and-joined-00
  =|  run=@ud
  %-  exec-2-1
  :*  run
      [~2012.4.30 %sys "CREATE DATABASE db1"]
      ::
      [~2012.5.1 %db1 create-joined-tables]
      ::
      :+  ~2012.5.2
          %db1
          "INSERT INTO my-table".
          " VALUES".
          " ('Abby', ~1999.2.19)".
          " ('Ace', ~2005.12.19)".
          " ('Angel', ~2001.9.19); ".
          "INSERT INTO my-table-2".
          " VALUES".
          " ('Abby', 'tricolor', 'row1')".
          " ('Ace', 'ticolor', 'row2')".
          " ('Angel', 'tuxedo', 'row3')"
      ::
      :+  ~2012.5.3
          %db1
          "FROM my-table T1 JOIN my-table-2 T2 ".
          "WHERE col3 = 'ticolor' AND col4='row2' ".
          "SELECT T1.*, T2.col3, T2.col4"
      ::
      :-  %results
          :~  [%action 'SELECT']
              :-  %result-set
                  :~  :-  %vector
                          :~  [%col1 [~.t 'Ace']]
                              [%col2 [~.da ~2005.12.19]]
                              [%col3 [~.t 'ticolor']]
                              [%col4 [~.t 'row2']]
                              ==
                      ==
              [%server-time ~2012.5.3]
              [%relation 'db1.dbo.my-table']
              [%schema-time ~2012.5.1]
              [%data-time ~2012.5.2]
              [%relation 'db1.dbo.my-table-2']
              [%schema-time ~2012.5.1]
              [%data-time ~2012.5.2]
              [%vector-count 1]
              ==
      ==
::
::  WHERE <column> = <column> AND <column> = <literal> joined
++  test-and-joined-01
  =|  run=@ud
  %-  exec-2-1
  ::%-  debug-2-1
    :*  run
        [~2012.4.30 %sys "CREATE DATABASE db1"]
        ::
        [~2012.5.1 %db1 create-joined-tables]
        ::
        :+  ~2012.5.2
            %db1
            "INSERT INTO my-table".
            " VALUES".
            " ('Abby', ~1999.2.19)".
            " ('Ace', ~2005.12.19)".
            " ('Angel', ~2001.9.19); ".
            "INSERT INTO my-table-2".
            " VALUES".
            " ('Abby', 'tricolor', 'row1')".
            " ('Ace', 'ticolor', 'row2')".
            " ('Angel', 'Angel', 'row3')"
        ::
        :+  ~2012.5.3
            %db1
            "FROM my-table T1 JOIN my-table-2 T2 ".
            "WHERE t1.col1 = col3 AND col4='row3' ".
            "SELECT T1.*, T2.col3, T2.col4"
        ::
        :-  %results
            :~  [%action 'SELECT']
                :-  %result-set
                    :~  :-  %vector
                            :~  [%col1 [~.t 'Angel']]
                                [%col2 [~.da ~2001.9.19]]
                                [%col3 [~.t 'Angel']]
                                [%col4 [~.t 'row3']]
                                ==
                        ==
                [%server-time ~2012.5.3]
                [%relation 'db1.dbo.my-table']
                [%schema-time ~2012.5.1]
                [%data-time ~2012.5.2]
                [%relation 'db1.dbo.my-table-2']
                [%schema-time ~2012.5.1]
                [%data-time ~2012.5.2]
                [%vector-count 1]
                ==
        ==
::
::  NOT
::
::  WHERE NOT <column> = <literal>
++  test-not-00
  =|  run=@ud
  %-  exec-2-1
  :*  run
      [~2012.4.30 %sys "CREATE DATABASE db1"]
      ::
      [~2012.5.1 %db1 create-mytable]
      ::
      :+  ~2012.5.2
          %db1
          "INSERT INTO my-table".
          " VALUES".
          " ('Abby', ~1999.2.19, 'tricolor', 'row1')".
          " ('Ace', ~2005.12.19, 'ticolor', 'row2')".
          " ('Angel', ~2001.9.19, 'tuxedo', 'row3')"
      ::
      :+  ~2012.5.3
          %db1
          "FROM my-table WHERE NOT col3 = 'tuxedo' SELECT *"
      ::
      :-  %results
          :~  [%action 'SELECT']
              :-  %result-set
                  :~  :-  %vector
                          :~  [%col1 [~.t 'Ace']]
                              [%col2 [~.da ~2005.12.19]]
                              [%col3 [~.t 'ticolor']]
                              [%col4 [~.t 'row2']]
                              ==
                      :-  %vector
                          :~  [%col1 [~.t 'Abby']]
                              [%col2 [~.da ~1999.2.19]]
                              [%col3 [~.t 'tricolor']]
                              [%col4 [~.t 'row1']]
                              ==
                      ==
              [%server-time ~2012.5.3]
              [%relation 'db1.dbo.my-table']
              [%schema-time ~2012.5.1]
              [%data-time ~2012.5.2]
              [%vector-count 2]
              ==
      ==
::
::  WHERE NOT <literal> = <column>
++  test-not-01
  =|  run=@ud
  %-  exec-2-1
  :*  run
      [~2012.4.30 %sys "CREATE DATABASE db1"]
      ::
      [~2012.5.1 %db1 create-mytable]
      ::
      :+  ~2012.5.2
          %db1
          "INSERT INTO my-table".
          " VALUES".
          " ('Abby', ~1999.2.19, 'tricolor', 'row1')".
          " ('Ace', ~2005.12.19, 'ticolor', 'row2')".
          " ('Angel', ~2001.9.19, 'tuxedo', 'row3')"
      ::
      :+  ~2012.5.3
          %db1
          "FROM my-table WHERE NOT 'tuxedo' = col3 SELECT *"
      ::
      :-  %results
          :~  [%action 'SELECT']
              :-  %result-set
                  :~  :-  %vector
                          :~  [%col1 [~.t 'Ace']]
                              [%col2 [~.da ~2005.12.19]]
                              [%col3 [~.t 'ticolor']]
                              [%col4 [~.t 'row2']]
                              ==
                      :-  %vector
                          :~  [%col1 [~.t 'Abby']]
                              [%col2 [~.da ~1999.2.19]]
                              [%col3 [~.t 'tricolor']]
                              [%col4 [~.t 'row1']]
                              ==
                      ==
              [%server-time ~2012.5.3]
              [%relation 'db1.dbo.my-table']
              [%schema-time ~2012.5.1]
              [%data-time ~2012.5.2]
              [%vector-count 2]
              ==
      ==
::
::  WHERE NOT <column> = <column>
++  test-not-02
  =|  run=@ud
  %-  exec-2-1
  :*  run
      [~2012.4.30 %sys "CREATE DATABASE db1"]
      ::
      [~2012.5.1 %db1 create-mytable]
      ::
      :+  ~2012.5.2
          %db1
          "INSERT INTO my-table".
          " VALUES".
          " ('Abby', ~1999.2.19, 'tricolor', 'row1')".
          " ('Ace', ~2005.12.19, 'ticolor', 'row2')".
          " ('Angel', ~2001.9.19, 'Angel', 'row3')"
      ::
      :+  ~2012.5.3
          %db1
          "FROM my-table WHERE NOT col1 = col3 SELECT *"
      ::
      :-  %results
          :~  [%action 'SELECT']
              :-  %result-set
                  :~  :-  %vector
                          :~  [%col1 [~.t 'Ace']]
                              [%col2 [~.da ~2005.12.19]]
                              [%col3 [~.t 'ticolor']]
                              [%col4 [~.t 'row2']]
                              ==
                      :-  %vector
                          :~  [%col1 [~.t 'Abby']]
                              [%col2 [~.da ~1999.2.19]]
                              [%col3 [~.t 'tricolor']]
                              [%col4 [~.t 'row1']]
                              ==
                      ==
              [%server-time ~2012.5.3]
              [%relation 'db1.dbo.my-table']
              [%schema-time ~2012.5.1]
              [%data-time ~2012.5.2]
              [%vector-count 2]
              ==
      ==
::
::  WHERE NOT <column> = <column> AND NOT <column> = <literal>
++  test-not-03
  =|  run=@ud
  %-  exec-2-1
  :*  run
      [~2012.4.30 %sys "CREATE DATABASE db1"]
      ::
      [~2012.5.1 %db1 create-mytable]
      ::
      :+  ~2012.5.2
          %db1
          "INSERT INTO my-table".
          " VALUES".
          " ('Abby', ~1999.2.19, 'tricolor', 'row1')".
          " ('Ace', ~2005.12.19, 'ticolor', 'row2')".
          " ('Angel', ~2001.9.19, 'Angel', 'row3')"
      ::
      :+  ~2012.5.3
          %db1
          "FROM my-table WHERE NOT col1 = col3 AND NOT col4='row2' ".
          "SELECT *"
      ::
      :-  %results
          :~  [%action 'SELECT']
              :-  %result-set
                  :~  :-  %vector
                          :~  [%col1 [~.t 'Abby']]
                              [%col2 [~.da ~1999.2.19]]
                              [%col3 [~.t 'tricolor']]
                              [%col4 [~.t 'row1']]
                              ==
                      ==
              [%server-time ~2012.5.3]
              [%relation 'db1.dbo.my-table']
              [%schema-time ~2012.5.1]
              [%data-time ~2012.5.2]
              [%vector-count 1]
              ==
      ==
::
::  view WHERE NOT <literal> = <literal>
++  test-not-04
  =|  run=@ud
  %-  exec-1-1
  :*  run
      [~2012.4.30 %sys "CREATE DATABASE db1"]
      ::
      [~2012.5.1 %db1 create-mytable]
      ::
      :+  ~2012.5.3
          %db1
          "FROM sys.columns WHERE NOT 1 = 1 SELECT *"
      ::
      :-  %results
          :~  [%action 'SELECT']
              [%result-set ~]
              [%server-time ~2012.5.3]
              [%relation 'db1.sys.columns']
              [%schema-time ~2012.5.1]
              [%data-time ~2012.5.1]
              [%vector-count 0]
              ==
      ==
::
::  fail WHERE NOT <literal> = <column> types differ
++  test-fail-not-00
  =|  run=@ud
  %-  failon-3
  :*  run
      [~2012.4.30 %sys "CREATE DATABASE db1"]
      ::
      [~2012.5.1 %db1 create-mytable]
      ::
      :+  ~2012.5.2
          %db1
          "INSERT INTO my-table".
          " VALUES".
          " ('Abby', ~1999.2.19, 'tricolor', 'row1')".
          " ('Ace', ~2005.12.19, 'ticolor', 'row2')".
          " ('Angel', ~2001.9.19, 'Angel', 'row3')"
      ::
      [~2012.5.2 %db1 "FROM my-table WHERE NOT ~1999.2.19 = col1 SELECT *"]
      ::
      %-  crip
          "comparing literal to column of different aura: ".
          "[p=~.da q=170.141.184.492.111.779.796.175.933.613.172.326.400] ".
          "%col1 type=~.t"
      ==
::
::  fail WHERE NOT <column> = <column> types differ
++  test-fail-not-01
  =|  run=@ud
  %-  failon-3
  :*  run
      [~2012.4.30 %sys "CREATE DATABASE db1"]
      ::
      [~2012.5.1 %db1 create-mytable]
      ::
      :+  ~2012.5.2
          %db1
          "INSERT INTO my-table".
          " VALUES".
          " ('Abby', ~1999.2.19, 'tricolor', 'row1')".
          " ('Ace', ~2005.12.19, 'ticolor', 'row2')".
          " ('Angel', ~2001.9.19, 'Angel', 'row3')"
      ::
      :+  ~2012.5.2
          %db1
          "FROM my-table WHERE NOT col1 = col2 SELECT *"
      ::
      %-  crip
          "comparing columns of different auras: %col1 type=~.t %col2 type=~.da"
      ==
::
::  WHERE NOT <column> = <literal> joined
++  test-not-joined-00
  =|  run=@ud
  %-  exec-2-1
  :*  run
      [~2012.4.30 %sys "CREATE DATABASE db1"]
      ::
      [~2012.5.1 %db1 create-joined-tables]
      ::
      :+  ~2012.5.2
          %db1
          "INSERT INTO my-table".
          " VALUES".
          " ('Abby', ~1999.2.19)".
          " ('Ace', ~2005.12.19)".
          " ('Angel', ~2001.9.19); ".
          "INSERT INTO my-table-2".
          " VALUES".
          " ('Abby', 'tricolor', 'row1')".
          " ('Ace', 'ticolor', 'row2')".
          " ('Angel', 'tuxedo', 'row3')"
      ::
      :+  ~2012.5.3
          %db1
          "FROM my-table T1 JOIN my-table-2 T2 ".
          "WHERE NOT col3 = 'tuxedo' ".
          "SELECT T1.*, T2.col3, T2.col4"
      ::
      :-  %results
          :~  [%action 'SELECT']
              :-  %result-set
                  :~  :-  %vector
                          :~  [%col1 [~.t 'Ace']]
                              [%col2 [~.da ~2005.12.19]]
                              [%col3 [~.t 'ticolor']]
                              [%col4 [~.t 'row2']]
                              ==
                      :-  %vector
                          :~  [%col1 [~.t 'Abby']]
                              [%col2 [~.da ~1999.2.19]]
                              [%col3 [~.t 'tricolor']]
                              [%col4 [~.t 'row1']]
                              ==
                      ==
              [%server-time ~2012.5.3]
              [%relation 'db1.dbo.my-table']
              [%schema-time ~2012.5.1]
              [%data-time ~2012.5.2]
              [%relation 'db1.dbo.my-table-2']
              [%schema-time ~2012.5.1]
              [%data-time ~2012.5.2]
              [%vector-count 2]
              ==
      ==
::
::  WHERE NOT <literal> = <column> joined
++  test-not-joined-01
  =|  run=@ud
  %-  exec-2-1
  :*  run
      [~2012.4.30 %sys "CREATE DATABASE db1"]
      ::
      [~2012.5.1 %db1 create-joined-tables]
      ::
      :+  ~2012.5.2
          %db1
          "INSERT INTO my-table".
          " VALUES".
          " ('Abby', ~1999.2.19)".
          " ('Ace', ~2005.12.19)".
          " ('Angel', ~2001.9.19); ".
          "INSERT INTO my-table-2".
          " VALUES".
          " ('Abby', 'tricolor', 'row1')".
          " ('Ace', 'ticolor', 'row2')".
          " ('Angel', 'tuxedo', 'row3')"
      ::
      :+  ~2012.5.3
          %db1
          "FROM my-table T1 JOIN my-table-2 T2 ".
          "WHERE NOT 'tuxedo' = col3 ".
          "SELECT T1.*, T2.col3, T2.col4"
      ::
      :-  %results
          :~  [%action 'SELECT']
              :-  %result-set
                  :~  :-  %vector
                          :~  [%col1 [~.t 'Ace']]
                              [%col2 [~.da ~2005.12.19]]
                              [%col3 [~.t 'ticolor']]
                              [%col4 [~.t 'row2']]
                              ==
                      :-  %vector
                          :~  [%col1 [~.t 'Abby']]
                              [%col2 [~.da ~1999.2.19]]
                              [%col3 [~.t 'tricolor']]
                              [%col4 [~.t 'row1']]
                              ==
                      ==
              [%server-time ~2012.5.3]
              [%relation 'db1.dbo.my-table']
              [%schema-time ~2012.5.1]
              [%data-time ~2012.5.2]
              [%relation 'db1.dbo.my-table-2']
              [%schema-time ~2012.5.1]
              [%data-time ~2012.5.2]
              [%vector-count 2]
              ==
      ==
::
::  WHERE NOT <column> = <column> joined
++  test-not-joined-02
  =|  run=@ud
  %-  exec-2-1
  :*  run
      [~2012.4.30 %sys "CREATE DATABASE db1"]
      ::
      [~2012.5.1 %db1 create-joined-tables]
      ::
      :+  ~2012.5.2
          %db1
          "INSERT INTO my-table".
          " VALUES".
          " ('Abby', ~1999.2.19)".
          " ('Ace', ~2005.12.19)".
          " ('Angel', ~2001.9.19); ".
          "INSERT INTO my-table-2".
          " VALUES".
          " ('Abby', 'tricolor', 'row1')".
          " ('Ace', 'ticolor', 'row2')".
          " ('Angel', 'Angel', 'row3')"
      ::
      :+  ~2012.5.3
          %db1
          "FROM my-table T1 JOIN my-table-2 T2 ".
          "WHERE NOT t1.col1 = col3 ".
          "SELECT T1.*, T2.col3, T2.col4"
      ::
      :-  %results
          :~  [%action 'SELECT']
              :-  %result-set
                  :~  :-  %vector
                          :~  [%col1 [~.t 'Ace']]
                              [%col2 [~.da ~2005.12.19]]
                              [%col3 [~.t 'ticolor']]
                              [%col4 [~.t 'row2']]
                              ==
                      :-  %vector
                          :~  [%col1 [~.t 'Abby']]
                              [%col2 [~.da ~1999.2.19]]
                              [%col3 [~.t 'tricolor']]
                              [%col4 [~.t 'row1']]
                              ==
                      ==
              [%server-time ~2012.5.3]
              [%relation 'db1.dbo.my-table']
              [%schema-time ~2012.5.1]
              [%data-time ~2012.5.2]
              [%relation 'db1.dbo.my-table-2']
              [%schema-time ~2012.5.1]
              [%data-time ~2012.5.2]
              [%vector-count 2]
              ==
      ==
::
::  WHERE NOT <column> = <column> AND NOT <column> = <literal> joined
++  test-not-joined-03
  =|  run=@ud
  %-  exec-2-1
  :*  run
      [~2012.4.30 %sys "CREATE DATABASE db1"]
      ::
      [~2012.5.1 %db1 create-joined-tables]
      ::
      :+  ~2012.5.2
          %db1
          "INSERT INTO my-table".
          " VALUES".
          " ('Abby', ~1999.2.19)".
          " ('Ace', ~2005.12.19)".
          " ('Angel', ~2001.9.19); ".
          "INSERT INTO my-table-2".
          " VALUES".
          " ('Abby', 'tricolor', 'row1')".
          " ('Ace', 'ticolor', 'row2')".
          " ('Angel', 'Angel', 'row3')"
      ::
      :+  ~2012.5.3
          %db1
          "FROM my-table T1 JOIN my-table-2 T2 ".
          "WHERE NOT t1.col1 = col3 AND NOT col4='row2' ".
          "SELECT T1.*, T2.col3, T2.col4"
      ::
      :-  %results
          :~  [%action 'SELECT']
              :-  %result-set
                  :~  :-  %vector
                          :~  [%col1 [~.t 'Abby']]
                              [%col2 [~.da ~1999.2.19]]
                              [%col3 [~.t 'tricolor']]
                              [%col4 [~.t 'row1']]
                              ==
                      ==
              [%server-time ~2012.5.3]
              [%relation 'db1.dbo.my-table']
              [%schema-time ~2012.5.1]
              [%data-time ~2012.5.2]
              [%relation 'db1.dbo.my-table-2']
              [%schema-time ~2012.5.1]
              [%data-time ~2012.5.2]
              [%vector-count 1]
              ==
      ==
::
::  fail WHERE NOT <literal> = <column> types differ joined
++  test-fail-not-joined-00
  =|  run=@ud
  %-  failon-3
  :*  run
      [~2012.4.30 %sys "CREATE DATABASE db1"]
      ::
      [~2012.5.1 %db1 create-joined-tables]
      ::
      :+  ~2012.5.2
          %db1
          "INSERT INTO my-table".
          " VALUES".
          " ('Abby', ~1999.2.19)".
          " ('Ace', ~2005.12.19)".
          " ('Angel', ~2001.9.19); ".
          "INSERT INTO my-table-2".
          " VALUES".
          " ('Abby', 'tricolor', 'row1')".
          " ('Ace', 'ticolor', 'row2')".
          " ('Angel', 'Angel', 'row3')"
      ::
      :+  ~2012.5.2
          %db1
          "FROM my-table T1 JOIN my-table-2 T2 ".
          "WHERE NOT ~1999.2.19 = t1.col1 SELECT T1.*, T2.col3, T2.col4"
      ::
      %-  crip
          "comparing literal to column of different aura: ".
          "[p=~.da q=170.141.184.492.111.779.796.175.933.613.172.326.400] ".
          "%col1 type=~.t"
      ==
::
::  fail WHERE NOT <column> = <column> types differ joined
++  test-fail-not-joined-01
  =|  run=@ud
  %-  failon-3
  :*  run
      [~2012.4.30 %sys "CREATE DATABASE db1"]
      ::
      [~2012.5.1 %db1 create-joined-tables]
      ::
      :+  ~2012.5.2
          %db1
          "INSERT INTO my-table".
          " VALUES".
          " ('Abby', ~1999.2.19)".
          " ('Ace', ~2005.12.19)".
          " ('Angel', ~2001.9.19); ".
          "INSERT INTO my-table-2".
          " VALUES".
          " ('Abby', 'tricolor', 'row1')".
          " ('Ace', 'ticolor', 'row2')".
          " ('Angel', 'Angel', 'row3')"
      ::
      :+  ~2012.5.2
          %db1
          "FROM my-table T1 JOIN my-table-2 T2 ".
          "WHERE NOT t1.col1 = col2 SELECT T1.*, T2.col3, T2.col4"
      ::
      %-  crip
          "comparing columns of different auras: %col1 type=~.t %col2 type=~.da"
      ==
::
::  qualified predicates
::  to do: implement name qualified in parse
::
::  alias qualified single table
++  test-qualified-01
  =|  run=@ud
  %-  exec-2-1
  :*  run
      [~2012.4.30 %sys "CREATE DATABASE db1"]
      ::
      [~2012.5.1 %db1 create-mytable]
      ::
      :+  ~2012.5.2
          %db1
          "INSERT INTO my-table".
          " VALUES".
          " ('Abby', ~1999.2.19, 'tricolor', 'row1')".
          " ('Ace', ~2005.12.19, 'ticolor', 'row2')".
          " ('Angel', ~2001.9.19, 'tuxedo', 'row3')"
      ::
      :+  ~2012.5.3
          %db1
          "FROM my-table T1 ".
          "WHERE (t1.col3 = 'ticolor' AND col4='row2') ".
             "OR (col3='tricolor' AND T1.col4='row1') ".
          "SELECT *"
      ::
      :-  %results
          :~  [%action 'SELECT']
              :-  %result-set
                  :~  :-  %vector
                          :~  [%col1 [~.t 'Ace']]
                              [%col2 [~.da ~2005.12.19]]
                              [%col3 [~.t 'ticolor']]
                              [%col4 [~.t 'row2']]
                              ==
                      :-  %vector
                          :~  [%col1 [~.t 'Abby']]
                              [%col2 [~.da ~1999.2.19]]
                              [%col3 [~.t 'tricolor']]
                              [%col4 [~.t 'row1']]
                              ==
                      ==
              [%server-time ~2012.5.3]
              [%relation 'db1.dbo.my-table']
              [%schema-time ~2012.5.1]
              [%data-time ~2012.5.2]
              [%vector-count 2]
              ==
      ==
::
::::  EQ cte-column
::::
::  WHERE <cte-column> = <cte-column> (matching)
++  test-eq-cte-00
  =|  run=@ud
  %-  exec-2-1
  :*  run
      [~2012.4.30 %sys "CREATE DATABASE db1"]
      ::
      [~2012.5.1 %db1 create-joined-tables]
      ::
      :+  ~2012.5.2
          %db1
          "INSERT INTO my-table".
          " VALUES".
          " ('Abby', ~1999.2.19)".
          " ('Ace', ~2005.12.19)".
          " ('Angel', ~2001.9.19); ".
          "INSERT INTO my-table-2".
          " VALUES".
          " ('Abby', 'tricolor', 'row1')".
          " ('Ace', 'ticolor', 'row2')".
          " ('Angel', 'Angel', 'row3')"
      ::
      :+  ~2012.5.3
          %db1
          "WITH (FROM my-table-2 WHERE col4 = 'row3' ".
          "SELECT col1, col3) AS my-cte ".
          "FROM my-table WHERE my-cte.col1 = my-cte.col3 SELECT *"
      ::
      :-  %results
          :~  [%action 'SELECT']
              :-  %result-set
                  :~  :-  %vector
                          :~  [%col1 [~.t 'Ace']]
                              [%col2 [~.da ~2005.12.19]]
                              ==
                      :-  %vector
                          :~  [%col1 [~.t 'Angel']]
                              [%col2 [~.da ~2001.9.19]]
                              ==
                      :-  %vector
                          :~  [%col1 [~.t 'Abby']]
                              [%col2 [~.da ~1999.2.19]]
                              ==
                      ==
              [%server-time ~2012.5.3]
              [%relation 'db1.dbo.my-table']
              [%schema-time ~2012.5.1]
              [%data-time ~2012.5.2]
              [%relation 'db1.dbo.my-table-2']
              [%schema-time ~2012.5.1]
              [%data-time ~2012.5.2]
              [%vector-count 3]
              ==
      ==
::
::  WHERE <cte-column> = <cte-column> (not matching)
++  test-eq-cte-01
  =|  run=@ud
  %-  exec-2-1
  :*  run
      [~2012.4.30 %sys "CREATE DATABASE db1"]
      ::
      [~2012.5.1 %db1 create-joined-tables]
      ::
      :+  ~2012.5.2
          %db1
          "INSERT INTO my-table".
          " VALUES".
          " ('Abby', ~1999.2.19)".
          " ('Ace', ~2005.12.19)".
          " ('Angel', ~2001.9.19); ".
          "INSERT INTO my-table-2".
          " VALUES".
          " ('Abby', 'tricolor', 'row1')".
          " ('Ace', 'ticolor', 'row2')".
          " ('Angel', 'tuxedo', 'row3')"
      ::
      :+  ~2012.5.3
          %db1
          "WITH (FROM my-table-2 WHERE col4 = 'row3' SELECT col1, col3) AS my-cte ".
          "FROM my-table WHERE my-cte.col1 = my-cte.col3 SELECT *"
      ::
      :-  %results
          :~  [%action 'SELECT']
              [%result-set ~]
              [%server-time ~2012.5.3]
              [%relation 'db1.dbo.my-table']
              [%schema-time ~2012.5.1]
              [%data-time ~2012.5.2]
              [%relation 'db1.dbo.my-table-2']
              [%schema-time ~2012.5.1]
              [%data-time ~2012.5.2]
              [%vector-count 0]
              ==
      ==
::
::  WHERE <cte-column> = <literal> (matching)
++  test-eq-cte-02
  =|  run=@ud
  %-  exec-2-1
  :*  run
      [~2012.4.30 %sys "CREATE DATABASE db1"]
      ::
      [~2012.5.1 %db1 create-joined-tables]
      ::
      :+  ~2012.5.2
          %db1
          "INSERT INTO my-table".
          " VALUES".
          " ('Abby', ~1999.2.19)".
          " ('Ace', ~2005.12.19)".
          " ('Angel', ~2001.9.19); ".
          "INSERT INTO my-table-2".
          " VALUES".
          " ('Abby', 'tricolor', 'row1')".
          " ('Ace', 'ticolor', 'row2')".
          " ('Angel', 'tuxedo', 'row3')"
      ::
      :+  ~2012.5.3
          %db1
          "WITH (FROM my-table-2 WHERE col4 = 'row3' SELECT col1) AS my-cte ".
          "FROM my-table WHERE my-cte.col1 = 'Angel' SELECT *"
      ::
      :-  %results
          :~  [%action 'SELECT']
              :-  %result-set
                  :~  :-  %vector
                          :~  [%col1 [~.t 'Ace']]
                              [%col2 [~.da ~2005.12.19]]
                              ==
                      :-  %vector
                          :~  [%col1 [~.t 'Angel']]
                              [%col2 [~.da ~2001.9.19]]
                              ==
                      :-  %vector
                          :~  [%col1 [~.t 'Abby']]
                              [%col2 [~.da ~1999.2.19]]
                              ==
                      ==
              [%server-time ~2012.5.3]
              [%relation 'db1.dbo.my-table']
              [%schema-time ~2012.5.1]
              [%data-time ~2012.5.2]
              [%relation 'db1.dbo.my-table-2']
              [%schema-time ~2012.5.1]
              [%data-time ~2012.5.2]
              [%vector-count 3]
              ==
      ==
::
::  WHERE <cte-column> = <literal> (not matching)
++  test-eq-cte-03
  =|  run=@ud
  %-  exec-2-1
  :*  run
      [~2012.4.30 %sys "CREATE DATABASE db1"]
      ::
      [~2012.5.1 %db1 create-joined-tables]
      ::
      :+  ~2012.5.2
          %db1
          "INSERT INTO my-table".
          " VALUES".
          " ('Abby', ~1999.2.19)".
          " ('Ace', ~2005.12.19)".
          " ('Angel', ~2001.9.19); ".
          "INSERT INTO my-table-2".
          " VALUES".
          " ('Abby', 'tricolor', 'row1')".
          " ('Ace', 'ticolor', 'row2')".
          " ('Angel', 'tuxedo', 'row3')"
      ::
      :+  ~2012.5.3
          %db1
          "WITH (FROM my-table-2 WHERE col4 = 'row3' SELECT col1) AS my-cte ".
          "FROM my-table WHERE my-cte.col1 = 'Ace' SELECT *"
      ::
      :-  %results
          :~  [%action 'SELECT']
              [%result-set ~]
              [%server-time ~2012.5.3]
              [%relation 'db1.dbo.my-table']
              [%schema-time ~2012.5.1]
              [%data-time ~2012.5.2]
              [%relation 'db1.dbo.my-table-2']
              [%schema-time ~2012.5.1]
              [%data-time ~2012.5.2]
              [%vector-count 0]
              ==
      ==
::
::  WHERE <literal> = <cte-column> (matching)
++  test-eq-cte-04
  =|  run=@ud
  %-  exec-2-1
  :*  run
      [~2012.4.30 %sys "CREATE DATABASE db1"]
      ::
      [~2012.5.1 %db1 create-joined-tables]
      ::
      :+  ~2012.5.2
          %db1
          "INSERT INTO my-table".
          " VALUES".
          " ('Abby', ~1999.2.19)".
          " ('Ace', ~2005.12.19)".
          " ('Angel', ~2001.9.19); ".
          "INSERT INTO my-table-2".
          " VALUES".
          " ('Abby', 'tricolor', 'row1')".
          " ('Ace', 'ticolor', 'row2')".
          " ('Angel', 'tuxedo', 'row3')"
      ::
      :+  ~2012.5.3
          %db1
          "WITH (FROM my-table-2 WHERE col4 = 'row3' SELECT col1) AS my-cte ".
          "FROM my-table WHERE 'Angel' = my-cte.col1 SELECT *"
      ::
      :-  %results
          :~  [%action 'SELECT']
              :-  %result-set
                  :~  :-  %vector
                          :~  [%col1 [~.t 'Ace']]
                              [%col2 [~.da ~2005.12.19]]
                              ==
                      :-  %vector
                          :~  [%col1 [~.t 'Angel']]
                              [%col2 [~.da ~2001.9.19]]
                              ==
                      :-  %vector
                          :~  [%col1 [~.t 'Abby']]
                              [%col2 [~.da ~1999.2.19]]
                              ==
                      ==
              [%server-time ~2012.5.3]
              [%relation 'db1.dbo.my-table']
              [%schema-time ~2012.5.1]
              [%data-time ~2012.5.2]
              [%relation 'db1.dbo.my-table-2']
              [%schema-time ~2012.5.1]
              [%data-time ~2012.5.2]
              [%vector-count 3]
              ==
      ==
::
::  WHERE <literal> = <cte-column> (not matching)
++  test-eq-cte-05
  =|  run=@ud
  %-  exec-2-1
  :*  run
      [~2012.4.30 %sys "CREATE DATABASE db1"]
      ::
      [~2012.5.1 %db1 create-joined-tables]
      ::
      :+  ~2012.5.2
          %db1
          "INSERT INTO my-table".
          " VALUES".
          " ('Abby', ~1999.2.19)".
          " ('Ace', ~2005.12.19)".
          " ('Angel', ~2001.9.19); ".
          "INSERT INTO my-table-2".
          " VALUES".
          " ('Abby', 'tricolor', 'row1')".
          " ('Ace', 'ticolor', 'row2')".
          " ('Angel', 'tuxedo', 'row3')"
      ::
      :+  ~2012.5.3
          %db1
          "WITH (FROM my-table-2 WHERE col4 = 'row3' SELECT col1) AS my-cte ".
          "FROM my-table WHERE 'Ace' = my-cte.col1 SELECT *"
      ::
      :-  %results
          :~  [%action 'SELECT']
              [%result-set ~]
              [%server-time ~2012.5.3]
              [%relation 'db1.dbo.my-table']
              [%schema-time ~2012.5.1]
              [%data-time ~2012.5.2]
              [%relation 'db1.dbo.my-table-2']
              [%schema-time ~2012.5.1]
              [%data-time ~2012.5.2]
              [%vector-count 0]
              ==
      ==
::
::  WHERE <cte-column> = <column>
++  test-eq-cte-06
  =|  run=@ud
  %-  exec-2-1
  :*  run
      [~2012.4.30 %sys "CREATE DATABASE db1"]
      ::
      [~2012.5.1 %db1 create-joined-tables]
      ::
      :+  ~2012.5.2
          %db1
          "INSERT INTO my-table".
          " VALUES".
          " ('Abby', ~1999.2.19)".
          " ('Ace', ~2005.12.19)".
          " ('Angel', ~2001.9.19); ".
          "INSERT INTO my-table-2".
          " VALUES".
          " ('Abby', 'tricolor', 'row1')".
          " ('Ace', 'ticolor', 'row2')".
          " ('Angel', 'tuxedo', 'row3')"
      ::
      :+  ~2012.5.3
          %db1
          "WITH (FROM my-table-2 WHERE col4 = 'row3' SELECT col1) AS my-cte ".
          "FROM my-table WHERE my-cte.col1 = col1 SELECT *"
      ::
      :-  %results
          :~  [%action 'SELECT']
              :-  %result-set
                  :~  :-  %vector
                          :~  [%col1 [~.t 'Angel']]
                              [%col2 [~.da ~2001.9.19]]
                              ==
                      ==
              [%server-time ~2012.5.3]
              [%relation 'db1.dbo.my-table']
              [%schema-time ~2012.5.1]
              [%data-time ~2012.5.2]
              [%relation 'db1.dbo.my-table-2']
              [%schema-time ~2012.5.1]
              [%data-time ~2012.5.2]
              [%vector-count 1]
              ==
      ==
::
::  WHERE <column> = <cte-column>
++  test-eq-cte-07
  =|  run=@ud
  %-  exec-2-1
  :*  run
      [~2012.4.30 %sys "CREATE DATABASE db1"]
      ::
      [~2012.5.1 %db1 create-joined-tables]
      ::
      :+  ~2012.5.2
          %db1
          "INSERT INTO my-table".
          " VALUES".
          " ('Abby', ~1999.2.19)".
          " ('Ace', ~2005.12.19)".
          " ('Angel', ~2001.9.19); ".
          "INSERT INTO my-table-2".
          " VALUES".
          " ('Abby', 'tricolor', 'row1')".
          " ('Ace', 'ticolor', 'row2')".
          " ('Angel', 'tuxedo', 'row3')"
      ::
      :+  ~2012.5.3
          %db1
          "WITH (FROM my-table-2 WHERE col4 = 'row3' SELECT col1) AS my-cte ".
          "FROM my-table WHERE col1 = my-cte.col1 SELECT *"
      ::
      :-  %results
          :~  [%action 'SELECT']
              :-  %result-set
                  :~  :-  %vector
                          :~  [%col1 [~.t 'Angel']]
                              [%col2 [~.da ~2001.9.19]]
                              ==
                      ==
              [%server-time ~2012.5.3]
              [%relation 'db1.dbo.my-table']
              [%schema-time ~2012.5.1]
              [%data-time ~2012.5.2]
              [%relation 'db1.dbo.my-table-2']
              [%schema-time ~2012.5.1]
              [%data-time ~2012.5.2]
              [%vector-count 1]
              ==
      ==
::
::  fail WHERE <cte-column> = <cte-column> types differ
++  test-fail-eq-cte-00
  =|  run=@ud
  %-  failon-3
  :*  run
      [~2012.4.30 %sys "CREATE DATABASE db1"]
      ::
      [~2012.5.1 %db1 create-mytable]
      ::
      :+  ~2012.5.2
          %db1
          "INSERT INTO my-table".
          " VALUES".
          " ('Abby', ~1999.2.19, 'tricolor', 'row1')".
          " ('Ace', ~2005.12.19, 'ticolor', 'row2')".
          " ('Angel', ~2001.9.19, 'tuxedo', 'row3')"
      ::
      :+  ~2012.5.2
          %db1
          "WITH (FROM my-table WHERE col4 = 'row3' SELECT col1, col2) AS my-cte ".
          "FROM my-table WHERE my-cte.col1 = my-cte.col2 SELECT *"
      ::
      %-  crip
          "comparing cte-columns of different auras: %col1 %col2"
      ==
::
::  fail WHERE <cte-column> = <literal> types differ
++  test-fail-eq-cte-01
  =|  run=@ud
  %-  failon-3
  :*  run
      [~2012.4.30 %sys "CREATE DATABASE db1"]
      ::
      [~2012.5.1 %db1 create-mytable]
      ::
      :+  ~2012.5.2
          %db1
          "INSERT INTO my-table".
          " VALUES".
          " ('Abby', ~1999.2.19, 'tricolor', 'row1')".
          " ('Ace', ~2005.12.19, 'ticolor', 'row2')".
          " ('Angel', ~2001.9.19, 'tuxedo', 'row3')"
      ::
      :+  ~2012.5.2
          %db1
          "WITH (FROM my-table WHERE col4 = 'row3' SELECT col3) AS my-cte ".
          "FROM my-table WHERE my-cte.col3 = ~1999.2.19 SELECT *"
      ::
      %-  crip
          "comparing cte-column to literal of different aura: %col3 ".
          "[p=~.da q=170.141.184.492.111.779.796.175.933.613.172.326.400]"
      ==
::
::  fail WHERE <literal> = <cte-column> types differ
++  test-fail-eq-cte-02
  =|  run=@ud
  %-  failon-3
  :*  run
      [~2012.4.30 %sys "CREATE DATABASE db1"]
      ::
      [~2012.5.1 %db1 create-mytable]
      ::
      :+  ~2012.5.2
          %db1
          "INSERT INTO my-table".
          " VALUES".
          " ('Abby', ~1999.2.19, 'tricolor', 'row1')".
          " ('Ace', ~2005.12.19, 'ticolor', 'row2')".
          " ('Angel', ~2001.9.19, 'tuxedo', 'row3')"
      ::
      :+  ~2012.5.2
          %db1
          "WITH (FROM my-table WHERE col4 = 'row3' SELECT col3) AS my-cte ".
          "FROM my-table WHERE ~1999.2.19 = my-cte.col3 SELECT *"
      ::
      %-  crip
          "comparing literal to cte-column of different aura: ".
          "[p=~.da q=170.141.184.492.111.779.796.175.933.613.172.326.400] ".
          "%col3"
      ==
::
::  fail WHERE <cte-column> = <column> types differ
++  test-fail-eq-cte-03
  =|  run=@ud
  %-  failon-3
  :*  run
      [~2012.4.30 %sys "CREATE DATABASE db1"]
      ::
      [~2012.5.1 %db1 create-mytable]
      ::
      :+  ~2012.5.2
          %db1
          "INSERT INTO my-table".
          " VALUES".
          " ('Abby', ~1999.2.19, 'tricolor', 'row1')".
          " ('Ace', ~2005.12.19, 'ticolor', 'row2')".
          " ('Angel', ~2001.9.19, 'tuxedo', 'row3')"
      ::
      :+  ~2012.5.2
          %db1
          "WITH (FROM my-table WHERE col4 = 'row3' SELECT col3) AS my-cte ".
          "FROM my-table WHERE my-cte.col3 = col2 SELECT *"
      ::
      %-  crip
          "comparing cte-column to column of different aura: %col3 %col2"
      ==
::
::  fail WHERE <column> = <cte-column> types differ
++  test-fail-eq-cte-04
  =|  run=@ud
  %-  failon-3
  :*  run
      [~2012.4.30 %sys "CREATE DATABASE db1"]
      ::
      [~2012.5.1 %db1 create-mytable]
      ::
      :+  ~2012.5.2
          %db1
          "INSERT INTO my-table".
          " VALUES".
          " ('Abby', ~1999.2.19, 'tricolor', 'row1')".
          " ('Ace', ~2005.12.19, 'ticolor', 'row2')".
          " ('Angel', ~2001.9.19, 'tuxedo', 'row3')"
      ::
      :+  ~2012.5.2
          %db1
          "WITH (FROM my-table WHERE col4 = 'row3' SELECT col3) AS my-cte ".
          "FROM my-table WHERE col2 = my-cte.col3 SELECT *"
      ::
      %-  crip
          "comparing column to cte-column of different aura: %col2 %col3"
      ==
::
::::  BETWEEN cte-column
::::
::  WHERE <cte-column> BETWEEN <literal> AND <literal> (true)
++  test-between-cte-00
  =|  run=@ud
  %-  exec-2-1
  :*  run
      [~2012.4.30 %sys "CREATE DATABASE db1"]
      ::
      [~2012.5.1 %db1 create-joined-tables]
      ::
      :+  ~2012.5.2
          %db1
          "INSERT INTO my-table".
          " VALUES".
          " ('Abby', ~1999.2.19)".
          " ('Ace', ~2005.12.19)".
          " ('Angel', ~2001.9.19); ".
          "INSERT INTO my-table-2".
          " VALUES".
          " ('Abby', 'tricolor', 'row1')".
          " ('Ace', 'ticolor', 'row2')".
          " ('Angel', 'tuxedo', 'row3')"
      ::
      :+  ~2012.5.3
          %db1
          "WITH (FROM my-table-2 WHERE col4 = 'row2' SELECT col3) AS my-cte ".
          "FROM my-table WHERE my-cte.col3 BETWEEN 'tango' AND 'tuxedos' SELECT *"
      ::
      :-  %results
          :~  [%action 'SELECT']
              :-  %result-set
                  :~  :-  %vector
                          :~  [%col1 [~.t 'Ace']]
                              [%col2 [~.da ~2005.12.19]]
                              ==
                      :-  %vector
                          :~  [%col1 [~.t 'Angel']]
                              [%col2 [~.da ~2001.9.19]]
                              ==
                      :-  %vector
                          :~  [%col1 [~.t 'Abby']]
                              [%col2 [~.da ~1999.2.19]]
                              ==
                      ==
              [%server-time ~2012.5.3]
              [%relation 'db1.dbo.my-table']
              [%schema-time ~2012.5.1]
              [%data-time ~2012.5.2]
              [%relation 'db1.dbo.my-table-2']
              [%schema-time ~2012.5.1]
              [%data-time ~2012.5.2]
              [%vector-count 3]
              ==
      ==
::
::  WHERE <cte-column> BETWEEN <literal> AND <literal> (false)
++  test-between-cte-01
  =|  run=@ud
  %-  exec-2-1
  :*  run
      [~2012.4.30 %sys "CREATE DATABASE db1"]
      ::
      [~2012.5.1 %db1 create-joined-tables]
      ::
      :+  ~2012.5.2
          %db1
          "INSERT INTO my-table".
          " VALUES".
          " ('Abby', ~1999.2.19)".
          " ('Ace', ~2005.12.19)".
          " ('Angel', ~2001.9.19); ".
          "INSERT INTO my-table-2".
          " VALUES".
          " ('Abby', 'tricolor', 'row1')".
          " ('Ace', 'ticolor', 'row2')".
          " ('Angel', 'tuxedo', 'row3')"
      ::
      :+  ~2012.5.3
          %db1
          "WITH (FROM my-table-2 WHERE col4 = 'row2' SELECT col3) AS my-cte ".
          "FROM my-table WHERE my-cte.col3 BETWEEN 'tuxedo' AND 'tuxedos' SELECT *"
      ::
      :-  %results
          :~  [%action 'SELECT']
              [%result-set ~]
              [%server-time ~2012.5.3]
              [%relation 'db1.dbo.my-table']
              [%schema-time ~2012.5.1]
              [%data-time ~2012.5.2]
              [%relation 'db1.dbo.my-table-2']
              [%schema-time ~2012.5.1]
              [%data-time ~2012.5.2]
              [%vector-count 0]
              ==
      ==
::
::  WHERE <cte-column> BETWEEN <cte-column> AND <literal>
++  test-between-cte-02
  =|  run=@ud
  %-  exec-2-1
  :*  run
      [~2012.4.30 %sys "CREATE DATABASE db1"]
      ::
      [~2012.5.1 %db1 create-joined-tables]
      ::
      :+  ~2012.5.2
          %db1
          "INSERT INTO my-table".
          " VALUES".
          " ('Abby', ~1999.2.19)".
          " ('Ace', ~2005.12.19)".
          " ('Angel', ~2001.9.19); ".
          "INSERT INTO my-table-2".
          " VALUES".
          " ('Abby', 'tricolor', 'row1')".
          " ('Ace', 'ticolor', 'row2')".
          " ('Angel', 'tuxedo', 'row3')"
      ::
      :+  ~2012.5.3
          %db1
          "WITH (FROM my-table-2 WHERE col4 = 'row2' SELECT col3, col4) AS my-cte ".
          "FROM my-table WHERE my-cte.col3 BETWEEN my-cte.col4 AND 'tummy' SELECT *"
      ::
      :-  %results
          :~  [%action 'SELECT']
              :-  %result-set
                  :~  :-  %vector
                          :~  [%col1 [~.t 'Ace']]
                              [%col2 [~.da ~2005.12.19]]
                              ==
                      :-  %vector
                          :~  [%col1 [~.t 'Angel']]
                              [%col2 [~.da ~2001.9.19]]
                              ==
                      :-  %vector
                          :~  [%col1 [~.t 'Abby']]
                              [%col2 [~.da ~1999.2.19]]
                              ==
                      ==
              [%server-time ~2012.5.3]
              [%relation 'db1.dbo.my-table']
              [%schema-time ~2012.5.1]
              [%data-time ~2012.5.2]
              [%relation 'db1.dbo.my-table-2']
              [%schema-time ~2012.5.1]
              [%data-time ~2012.5.2]
              [%vector-count 3]
              ==
      ==
::
::  WHERE <column> BETWEEN <cte-column> AND <literal>
++  test-between-cte-03
  =|  run=@ud
  %-  exec-2-1
  :*  run
      [~2012.4.30 %sys "CREATE DATABASE db1"]
      ::
      [~2012.5.1 %db1 create-joined-tables]
      ::
      :+  ~2012.5.2
          %db1
          "INSERT INTO my-table".
          " VALUES".
          " ('Abby', ~1999.2.19)".
          " ('Ace', ~2005.12.19)".
          " ('Angel', ~2001.9.19); ".
          "INSERT INTO my-table-2".
          " VALUES".
          " ('Abby', 'Abby', 'row1')".
          " ('Ace', 'Ace', 'row2')".
          " ('Angel', 'Angel', 'row3')"
      ::
      :+  ~2012.5.3
          %db1
          "WITH (FROM my-table-2 WHERE col4 = 'row2' SELECT col3) AS my-cte ".
          "FROM my-table WHERE col1 BETWEEN my-cte.col3 AND 'Angel' SELECT *"
      ::
      :-  %results
          :~  [%action 'SELECT']
              :-  %result-set
                  :~  :-  %vector
                          :~  [%col1 [~.t 'Ace']]
                              [%col2 [~.da ~2005.12.19]]
                              ==
                      :-  %vector
                          :~  [%col1 [~.t 'Angel']]
                              [%col2 [~.da ~2001.9.19]]
                              ==
                      ==
              [%server-time ~2012.5.3]
              [%relation 'db1.dbo.my-table']
              [%schema-time ~2012.5.1]
              [%data-time ~2012.5.2]
              [%relation 'db1.dbo.my-table-2']
              [%schema-time ~2012.5.1]
              [%data-time ~2012.5.2]
              [%vector-count 2]
              ==
      ==
::
::  WHERE <column> BETWEEN <cte-column> AND <cte-column>
++  test-between-cte-04
  =|  run=@ud
  %-  exec-2-1
  :*  run
      [~2012.4.30 %sys "CREATE DATABASE db1"]
      ::
      [~2012.5.1 %db1 create-joined-tables]
      ::
      :+  ~2012.5.2
          %db1
          "INSERT INTO my-table".
          " VALUES".
          " ('Abby', ~1999.2.19)".
          " ('Ace', ~2005.12.19)".
          " ('Angel', ~2001.9.19); ".
          "INSERT INTO my-table-2".
          " VALUES".
          " ('Abby', 'Abby', 'row1')".
          " ('Ace', 'Ace', 'Angel')".
          " ('Angel', 'Angel', 'row3')"
      ::
      :+  ~2012.5.3
          %db1
          "WITH (FROM my-table-2 WHERE col4 = 'Angel' SELECT col3, col4) AS my-cte ".
          "FROM my-table WHERE col1 BETWEEN my-cte.col3 AND my-cte.col4 SELECT *"
      ::
      :-  %results
          :~  [%action 'SELECT']
              :-  %result-set
                  :~  :-  %vector
                          :~  [%col1 [~.t 'Ace']]
                              [%col2 [~.da ~2005.12.19]]
                              ==
                      :-  %vector
                          :~  [%col1 [~.t 'Angel']]
                              [%col2 [~.da ~2001.9.19]]
                              ==
                      ==
              [%server-time ~2012.5.3]
              [%relation 'db1.dbo.my-table']
              [%schema-time ~2012.5.1]
              [%data-time ~2012.5.2]
              [%relation 'db1.dbo.my-table-2']
              [%schema-time ~2012.5.1]
              [%data-time ~2012.5.2]
              [%vector-count 2]
              ==
      ==
::
::  fail WHERE <cte-column> BETWEEN <column> AND <literal> types differ
++  test-fail-between-cte-00
  =|  run=@ud
  %-  failon-3
  :*  run
      [~2012.4.30 %sys "CREATE DATABASE db1"]
      ::
      [~2012.5.1 %db1 create-mytable]
      ::
      :+  ~2012.5.2
          %db1
          "INSERT INTO my-table".
          " VALUES".
          " ('Abby', ~1999.2.19, 'tricolor', 'row1')".
          " ('Ace', ~2005.12.19, 'ticolor', 'row2')".
          " ('Angel', ~2001.9.19, 'tuxedo', 'row3')"
      ::
      :+  ~2012.5.2
          %db1
          "WITH (FROM my-table WHERE col4 = 'row3' SELECT col3) AS my-cte ".
          "FROM my-table WHERE my-cte.col3 BETWEEN col2 AND 'zzz' SELECT *"
      ::
      %-  crip
          "comparing cte-column to column of different aura: %col3 %col2"
      ==
::
::  fail WHERE <cte-column> BETWEEN <column> AND <cte-column> types differ
++  test-fail-between-cte-01
  =|  run=@ud
  %-  failon-3
  :*  run
      [~2012.4.30 %sys "CREATE DATABASE db1"]
      ::
      [~2012.5.1 %db1 create-mytable]
      ::
      :+  ~2012.5.2
          %db1
          "INSERT INTO my-table".
          " VALUES".
          " ('Abby', ~1999.2.19, 'tricolor', 'row1')".
          " ('Ace', ~2005.12.19, 'ticolor', 'row2')".
          " ('Angel', ~2001.9.19, 'tuxedo', 'row3')"
      ::
      :+  ~2012.5.2
          %db1
          "WITH (FROM my-table WHERE col4 = 'row3' SELECT col3, col2) AS my-cte ".
          "FROM my-table WHERE my-cte.col3 BETWEEN col1 AND my-cte.col2 SELECT *"
      ::
      %-  crip
          "comparing cte-columns of different auras: %col3 %col2"
      ==
::
::  fail WHERE <column> BETWEEN <cte-column> AND <cte-column> types differ
++  test-fail-between-cte-02
  =|  run=@ud
  %-  failon-3
  :*  run
      [~2012.4.30 %sys "CREATE DATABASE db1"]
      ::
      [~2012.5.1 %db1 create-mytable]
      ::
      :+  ~2012.5.2
          %db1
          "INSERT INTO my-table".
          " VALUES".
          " ('Abby', ~1999.2.19, 'tricolor', 'row1')".
          " ('Ace', ~2005.12.19, 'ticolor', 'row2')".
          " ('Angel', ~2001.9.19, 'tuxedo', 'row3')"
      ::
      :+  ~2012.5.2
          %db1
          "WITH (FROM my-table WHERE col4 = 'row3' SELECT col3, col2) AS my-cte ".
          "FROM my-table WHERE col1 BETWEEN my-cte.col3 AND my-cte.col2 SELECT *"
      ::
      %-  crip
          "comparing column to cte-column of different aura: %col1 %col2"
      ==
::
::::  IN cte-column
::::
::  WHERE <cte-column> IN (list @t) (true)
++  test-in-cte-00
  =|  run=@ud
  %-  exec-2-1
  :*  run
      [~2012.4.30 %sys "CREATE DATABASE db1"]
      ::
      [~2012.5.1 %db1 create-mytable]
      ::
      :+  ~2012.5.2
          %db1
          "INSERT INTO my-table".
          " VALUES".
          " ('Abby', ~1999.2.19, 'tricolor', 'row1')".
          " ('Ace', ~2005.12.19, 'ticolor', 'row2')".
          " ('Angel', ~2001.9.19, 'tuxedo', 'row3')"
      ::
      :+  ~2012.5.3
          %db1
          "WITH (FROM my-table WHERE col4 = 'row2' SELECT col3) AS my-cte ".
          "FROM my-table WHERE my-cte.col3 IN ('ticolor', 'tuxedo') SELECT *"
      ::
      :-  %results
          :~  [%action 'SELECT']
              :-  %result-set
                  :~  :-  %vector
                          :~  [%col1 [~.t 'Ace']]
                              [%col2 [~.da ~2005.12.19]]
                              [%col3 [~.t 'ticolor']]
                              [%col4 [~.t 'row2']]
                              ==
                      :-  %vector
                          :~  [%col1 [~.t 'Angel']]
                              [%col2 [~.da ~2001.9.19]]
                              [%col3 [~.t 'tuxedo']]
                              [%col4 [~.t 'row3']]
                              ==
                      :-  %vector
                          :~  [%col1 [~.t 'Abby']]
                              [%col2 [~.da ~1999.2.19]]
                              [%col3 [~.t 'tricolor']]
                              [%col4 [~.t 'row1']]
                              ==
                      ==
              [%server-time ~2012.5.3]
              [%relation 'db1.dbo.my-table']
              [%schema-time ~2012.5.1]
              [%data-time ~2012.5.2]
              [%vector-count 3]
              ==
      ==
::
::  WHERE <cte-column> IN (list @t) (false)
++  test-in-cte-01
  =|  run=@ud
  %-  exec-2-1
  :*  run
      [~2012.4.30 %sys "CREATE DATABASE db1"]
      ::
      [~2012.5.1 %db1 create-mytable]
      ::
      :+  ~2012.5.2
          %db1
          "INSERT INTO my-table".
          " VALUES".
          " ('Abby', ~1999.2.19, 'tricolor', 'row1')".
          " ('Ace', ~2005.12.19, 'ticolor', 'row2')".
          " ('Angel', ~2001.9.19, 'tuxedo', 'row3')"
      ::
      :+  ~2012.5.3
          %db1
          "WITH (FROM my-table WHERE col4 = 'row2' SELECT col3) AS my-cte ".
          "FROM my-table WHERE my-cte.col3 IN ('tricolor', 'tuxedo') SELECT *"
      ::
      :-  %results
          :~  [%action 'SELECT']
              [%result-set ~]
              [%server-time ~2012.5.3]
              [%relation 'db1.dbo.my-table']
              [%schema-time ~2012.5.1]
              [%data-time ~2012.5.2]
              [%vector-count 0]
              ==
      ==
::
::  WHERE <cte-column> IN cte-column (true)
++  test-in-cte-02
  =|  run=@ud
  %-  exec-2-1
  :*  run
      [~2012.4.30 %sys "CREATE DATABASE db1"]
      ::
      [~2012.5.1 %db1 create-joined-tables]
      ::
      :+  ~2012.5.2
          %db1
          "INSERT INTO my-table".
          " VALUES".
          " ('Abby', ~1999.2.19)".
          " ('Ace', ~2005.12.19)".
          " ('Angel', ~2001.9.19); ".
          "INSERT INTO my-table-2".
          " VALUES".
          " ('Abby', 'Abby', 'row1')".
          " ('Ace', 'Ace', 'row2')".
          " ('Angel', 'Angel', 'row3')"
      ::
      :+  ~2012.5.3
          %db1
          "WITH (FROM my-table-2 WHERE col4 = 'row2' SELECT col3) AS cte-a, ".
          "(FROM my-table-2 SELECT col1) AS cte-b ".
          "FROM my-table WHERE cte-a.col3 IN cte-b.col1 SELECT *"
      ::
      :-  %results
          :~  [%action 'SELECT']
              :-  %result-set
                  :~  :-  %vector
                          :~  [%col1 [~.t 'Ace']]
                              [%col2 [~.da ~2005.12.19]]
                              ==
                      :-  %vector
                          :~  [%col1 [~.t 'Angel']]
                              [%col2 [~.da ~2001.9.19]]
                              ==
                      :-  %vector
                          :~  [%col1 [~.t 'Abby']]
                              [%col2 [~.da ~1999.2.19]]
                              ==
                      ==
              [%server-time ~2012.5.3]
              [%relation 'db1.dbo.my-table']
              [%schema-time ~2012.5.1]
              [%data-time ~2012.5.2]
              [%relation 'db1.dbo.my-table-2']
              [%schema-time ~2012.5.1]
              [%data-time ~2012.5.2]
              [%vector-count 3]
              ==
      ==
::
::  WHERE <cte-column> IN cte-column (false)
++  test-in-cte-03
  =|  run=@ud
  %-  exec-2-1
  :*  run
      [~2012.4.30 %sys "CREATE DATABASE db1"]
      ::
      [~2012.5.1 %db1 create-joined-tables]
      ::
      :+  ~2012.5.2
          %db1
          "INSERT INTO my-table".
          " VALUES".
          " ('Abby', ~1999.2.19)".
          " ('Ace', ~2005.12.19)".
          " ('Angel', ~2001.9.19); ".
          "INSERT INTO my-table-2".
          " VALUES".
          " ('Abby', 'Abby', 'row1')".
          " ('Ace', 'Ace', 'row2')".
          " ('Angel', 'Angel', 'row3')"
      ::
      :+  ~2012.5.3
          %db1
          "WITH (FROM my-table-2 WHERE col4 = 'row2' SELECT col3) AS cte-a, ".
          "(FROM my-table-2 WHERE col1 != 'Ace' SELECT col1) AS cte-b ".
          "FROM my-table WHERE cte-a.col3 IN cte-b.col1 SELECT *"
      ::
      :-  %results
          :~  [%action 'SELECT']
              [%result-set ~]
              [%server-time ~2012.5.3]
              [%relation 'db1.dbo.my-table']
              [%schema-time ~2012.5.1]
              [%data-time ~2012.5.2]
              [%relation 'db1.dbo.my-table-2']
              [%schema-time ~2012.5.1]
              [%data-time ~2012.5.2]
              [%vector-count 0]
              ==
      ==
::
::  WHERE <column> IN cte-column
++  test-in-cte-04
  =|  run=@ud
  %-  exec-2-1
  :*  run
      [~2012.4.30 %sys "CREATE DATABASE db1"]
      ::
      [~2012.5.1 %db1 create-joined-tables]
      ::
      :+  ~2012.5.2
          %db1
          "INSERT INTO my-table".
          " VALUES".
          " ('Abby', ~1999.2.19)".
          " ('Ace', ~2005.12.19)".
          " ('Angel', ~2001.9.19); ".
          "INSERT INTO my-table-2".
          " VALUES".
          " ('Ace', 'ticolor', 'row2')".
          " ('Angel', 'tuxedo', 'row3')"
      ::
      :+  ~2012.5.3
          %db1
          "WITH (FROM my-table-2 SELECT col1) AS my-cte ".
          "FROM my-table WHERE col1 IN my-cte.col1 SELECT *"
      ::
      :-  %results
          :~  [%action 'SELECT']
              :-  %result-set
                  :~  :-  %vector
                          :~  [%col1 [~.t 'Ace']]
                              [%col2 [~.da ~2005.12.19]]
                              ==
                      :-  %vector
                          :~  [%col1 [~.t 'Angel']]
                              [%col2 [~.da ~2001.9.19]]
                              ==
                      ==
              [%server-time ~2012.5.3]
              [%relation 'db1.dbo.my-table']
              [%schema-time ~2012.5.1]
              [%data-time ~2012.5.2]
              [%relation 'db1.dbo.my-table-2']
              [%schema-time ~2012.5.1]
              [%data-time ~2012.5.2]
              [%vector-count 2]
              ==
      ==
::
::  fail WHERE <cte-column> IN (list @t) types differ
++  test-fail-in-cte-00
  =|  run=@ud
  %-  failon-3
  :*  run
      [~2012.4.30 %sys "CREATE DATABASE db1"]
      ::
      [~2012.5.1 %db1 create-mytable]
      ::
      :+  ~2012.5.2
          %db1
          "INSERT INTO my-table".
          " VALUES".
          " ('Abby', ~1999.2.19, 'tricolor', 'row1')".
          " ('Ace', ~2005.12.19, 'ticolor', 'row2')".
          " ('Angel', ~2001.9.19, 'tuxedo', 'row3')"
      ::
      :+  ~2012.5.2
          %db1
          "WITH (FROM my-table WHERE col4 = 'row2' SELECT col2) AS my-cte ".
          "FROM my-table WHERE my-cte.col2 IN ('ticolor', 'tuxedo') SELECT *"
      ::
      %-  crip
          "type of IN list incorrect, should be ~.da"
      ==
::
::  fail WHERE <cte-column> IN cte-column types differ
++  test-fail-in-cte-01
  =|  run=@ud
  %-  failon-3
  :*  run
      [~2012.4.30 %sys "CREATE DATABASE db1"]
      ::
      [~2012.5.1 %db1 create-mytable]
      ::
      :+  ~2012.5.2
          %db1
          "INSERT INTO my-table".
          " VALUES".
          " ('Abby', ~1999.2.19, 'tricolor', 'row1')".
          " ('Ace', ~2005.12.19, 'ticolor', 'row2')".
          " ('Angel', ~2001.9.19, 'tuxedo', 'row3')"
      ::
      :+  ~2012.5.2
          %db1
          "WITH (FROM my-table WHERE col4 = 'row3' SELECT col3) AS cte-a, ".
          "(FROM my-table WHERE col4 = 'row3' SELECT col2) AS cte-b ".
          "FROM my-table WHERE cte-a.col3 IN cte-b.col2 SELECT *"
      ::
      %-  crip
          "IN cte-column type ~.da doesn't match left side type ~.t"
      ==
::
::  fail WHERE <column> IN cte-column types differ
++  test-fail-in-cte-02
  =|  run=@ud
  %-  failon-3
  :*  run
      [~2012.4.30 %sys "CREATE DATABASE db1"]
      ::
      [~2012.5.1 %db1 create-mytable]
      ::
      :+  ~2012.5.2
          %db1
          "INSERT INTO my-table".
          " VALUES".
          " ('Abby', ~1999.2.19, 'tricolor', 'row1')".
          " ('Ace', ~2005.12.19, 'ticolor', 'row2')".
          " ('Angel', ~2001.9.19, 'tuxedo', 'row3')"
      ::
      :+  ~2012.5.2
          %db1
          "WITH (FROM my-table WHERE col4 = 'row3' SELECT col2) AS my-cte ".
          "FROM my-table WHERE col1 IN my-cte.col2 SELECT *"
      ::
      %-  crip
          "IN cte-column type ~.da doesn't match left side type ~.t"
      ==
::
::  direct predicate scalar-name resolution
::
++  mk-predicate-indexed-row
  |=  kvp=(lest [@tas @])
  ^-  data-row
  :*  %indexed-row
      key=(turn kvp |=(e=[@tas @] +.e))
      data=(malt (limo kvp))
  ==
::
++  pred-leaf
  |=  a=predicate-component:ast
  [a ~ ~]
::
++  pred-scalar-row
  %-  mk-predicate-indexed-row
  :~
    [%col1 'Angel']
    [%col2 ~2001.9.19]
    [%col3 'tuxedo']
    [%col4 7]
    ==
::
++  pred-scalar-map-meta
  ^-  map-meta
  :-  %unqualified-map-meta
  %-  mk-unqualified-typ-addr-lookup
  %-  addr-columns
  :~  [%column %col1 ~.t 0]
      [%column %col2 ~.da 0]
      [%column %col3 ~.t 0]
      [%column %col4 ~.ud 0]
      ==
::
++  pred-scalar-qualified-table
  :*  %qualified-table
      ship=~
      database=%db1
      namespace=%dbo
      name=%my-table
      alias=~
      ==
::
++  pred-scalar-qualifier-lookup
  ^-  qualifier-lookup
  %-  malt
  %-  limo
  :~  [%col1 ~[pred-scalar-qualified-table]]
      [%col2 ~[pred-scalar-qualified-table]]
      [%col3 ~[pred-scalar-qualified-table]]
      [%col4 ~[pred-scalar-qualified-table]]
      ==
::
++  pred-scalar-resolved-scalars
  ^-  resolved-scalars
  %-  malt
  %-  limo
      :~  :-  %scalar-lit
          [~.t 'tuxedo']
      :-  %scalar-fn
          :*  %fn
            type=~.t
            |=  row=data-row
            ^-  dime
            =/  idx=indexed-row  ?>(?=(%indexed-row -.row) row)
            [~.t (~(got by data.idx) %col3)]
          ==
      :-  %scalar-num
          :*  %fn
            type=~.ud
            |=  row=data-row
            ^-  dime
            =/  idx=indexed-row  ?>(?=(%indexed-row -.row) row)
            [~.ud (~(got by data.idx) %col4)]
          ==
      :-  %scalar-date
          :*  %fn
            type=~.da
            |=  row=data-row
            ^-  dime
            =/  idx=indexed-row  ?>(?=(%indexed-row -.row) row)
            [~.da (~(got by data.idx) %col2)]
          ==
      ==
::
::  scalar test harness rows
::
++  scalar-true  [~.t 'true']
++  scalar-false  [~.t 'false']
::
::  WHEN scalar-fn equals text literal
++  scalar-row-00
  :-  :*  %if-then-else
        if=[%eq (pred-leaf [%scalar-name %scalar-fn]) (pred-leaf [~.t 'tuxedo'])]
        then=scalar-true
        else=scalar-false
        ==
      scalar-true
::
::  WHEN text column equals scalar-literal
++  scalar-row-01
  :-  :*  %if-then-else
        if=[%eq (pred-leaf [%unqualified-column %col3 ~]) (pred-leaf [%scalar-name %scalar-lit])]
        then=scalar-true
        else=scalar-false
        ==
      scalar-true
::
::  WHEN scalar-fn is contained in numeric list
++  scalar-row-02
  :-  :*  %if-then-else
        if=[%in (pred-leaf [%scalar-name %scalar-num]) (pred-leaf [%value-literals %ud '5;7'])]
        then=scalar-true
        else=scalar-false
        ==
      scalar-true
::
::  WHERE <scalar-fn> = <literal>
++  test-scalar-00
  %:  run-scalar-tests
    *named-ctes
    pred-scalar-qualifier-lookup
    pred-scalar-map-meta
    pred-scalar-resolved-scalars
    pred-scalar-row
    :~  [%scalar-00 scalar-row-00]
        ==
  ==
::
::  WHERE <column> = <scalar-literal>
++  test-scalar-01
  %:  run-scalar-tests
    *named-ctes
    pred-scalar-qualifier-lookup
    pred-scalar-map-meta
    pred-scalar-resolved-scalars
    pred-scalar-row
    :~  [%scalar-01 scalar-row-01]
        ==
  ==
::
::  WHERE <scalar-fn> IN (list @ud)
++  test-scalar-02
  %:  run-scalar-tests
    *named-ctes
    pred-scalar-qualifier-lookup
    pred-scalar-map-meta
    pred-scalar-resolved-scalars
    pred-scalar-row
    :~  [%scalar-02 scalar-row-02]
        ==
  ==
::
::  WHERE <scalar-fn> = <literal>
++  test-scalar-03
  =|  run=@ud
  %-  exec-2-1
  :*  run
      [~2012.4.30 %sys "CREATE DATABASE db1"]
      ::
      [~2012.5.1 %db1 create-ud-3col-table]
      ::
      :+  ~2012.5.2
          %db1
          "INSERT INTO my-table".
          " VALUES".
          " ('Abby', 6, 4, 6)".
          " ('Ace', 9, 5, 9)".
          " ('Angel', 12, 8, 12)"
      ::
      :+  ~2012.5.3
          %db1
          "FROM my-table ".
          "SCALARS my-scalar (2 + col3 + col4) / 2 END ".
          "WHERE my-scalar = 6 ".
          "SELECT *"
      ::
      :-  %results
          :~  [%action 'SELECT']
              :-  %result-set
                  :~  :-  %vector
                          :~  [%col1 [~.t 'Abby']]
                              [%col2 [~.ud 6]]
                              [%col3 [~.ud 4]]
                              [%col4 [~.ud 6]]
                              ==
                      ==
              [%server-time ~2012.5.3]
              [%relation 'db1.dbo.my-table']
              [%schema-time ~2012.5.1]
              [%data-time ~2012.5.2]
              [%vector-count 1]
              ==
      ==
::
::  WHERE <literal> = <scalar-fn>
++  test-scalar-04
  =|  run=@ud
  %-  exec-2-1
  :*  run
      [~2012.4.30 %sys "CREATE DATABASE db1"]
      ::
      [~2012.5.1 %db1 create-ud-3col-table]
      ::
      :+  ~2012.5.2
          %db1
          "INSERT INTO my-table".
          " VALUES".
          " ('Abby', 6, 4, 6)".
          " ('Ace', 9, 5, 9)".
          " ('Angel', 12, 8, 12)"
      ::
      :+  ~2012.5.3
          %db1
          "FROM my-table ".
          "SCALARS my-scalar (2 + col3 + col4) / 2 END ".
          "WHERE 6 = my-scalar ".
          "SELECT *"
      ::
      :-  %results
          :~  [%action 'SELECT']
              :-  %result-set
                  :~  :-  %vector
                          :~  [%col1 [~.t 'Abby']]
                              [%col2 [~.ud 6]]
                              [%col3 [~.ud 4]]
                              [%col4 [~.ud 6]]
                              ==
                      ==
              [%server-time ~2012.5.3]
              [%relation 'db1.dbo.my-table']
              [%schema-time ~2012.5.1]
              [%data-time ~2012.5.2]
              [%vector-count 1]
              ==
      ==
::
::  WHERE <scalar-fn> = <column>
++  test-scalar-05
  =|  run=@ud
  %-  exec-2-1
  :*  run
      [~2012.4.30 %sys "CREATE DATABASE db1"]
      ::
      [~2012.5.1 %db1 create-ud-3col-table]
      ::
      :+  ~2012.5.2
          %db1
          "INSERT INTO my-table".
          " VALUES".
          " ('Abby', 6, 4, 6)".
          " ('Ace', 9, 5, 9)".
          " ('Angel', 12, 8, 12)"
      ::
      :+  ~2012.5.3
          %db1
          "FROM my-table ".
          "SCALARS my-scalar (2 + col3 + col4) / 2 END ".
          "WHERE my-scalar = col2 ".
          "SELECT *"
      ::
      :-  %results
          :~  [%action 'SELECT']
              :-  %result-set
                  :~  :-  %vector
                          :~  [%col1 [~.t 'Abby']]
                              [%col2 [~.ud 6]]
                              [%col3 [~.ud 4]]
                              [%col4 [~.ud 6]]
                              ==
                      ==
              [%server-time ~2012.5.3]
              [%relation 'db1.dbo.my-table']
              [%schema-time ~2012.5.1]
              [%data-time ~2012.5.2]
              [%vector-count 1]
              ==
      ==
::
::  WHERE <column> = <scalar-fn>
++  test-scalar-06
  =|  run=@ud
  %-  exec-2-1
  :*  run
      [~2012.4.30 %sys "CREATE DATABASE db1"]
      ::
      [~2012.5.1 %db1 create-ud-3col-table]
      ::
      :+  ~2012.5.2
          %db1
          "INSERT INTO my-table".
          " VALUES".
          " ('Abby', 6, 4, 6)".
          " ('Ace', 9, 5, 9)".
          " ('Angel', 12, 8, 12)"
      ::
      :+  ~2012.5.3
          %db1
          "FROM my-table ".
          "SCALARS my-scalar (2 + col3 + col4) / 2 END ".
          "WHERE col2 = my-scalar ".
          "SELECT *"
      ::
      :-  %results
          :~  [%action 'SELECT']
              :-  %result-set
                  :~  :-  %vector
                          :~  [%col1 [~.t 'Abby']]
                              [%col2 [~.ud 6]]
                              [%col3 [~.ud 4]]
                              [%col4 [~.ud 6]]
                              ==
                      ==
              [%server-time ~2012.5.3]
              [%relation 'db1.dbo.my-table']
              [%schema-time ~2012.5.1]
              [%data-time ~2012.5.2]
              [%vector-count 1]
              ==
      ==
::
::  WHERE <scalar-fn> = <scalar-fn>
++  test-scalar-07
  =|  run=@ud
  %-  exec-2-1
  :*  run
      [~2012.4.30 %sys "CREATE DATABASE db1"]
      ::
      [~2012.5.1 %db1 create-ud-3col-table]
      ::
      :+  ~2012.5.2
          %db1
          "INSERT INTO my-table".
          " VALUES".
          " ('Abby', 6, 4, 6)".
          " ('Ace', 9, 5, 9)".
          " ('Angel', 12, 8, 12)"
      ::
      :+  ~2012.5.3
          %db1
          "FROM my-table ".
          "SCALARS left-scalar (col2 + col3 + 2) - 6 END ".
          "right-scalar (col4 * 2 + 0) / 2 END ".
          "WHERE left-scalar = right-scalar ".
          "SELECT *"
      ::
      :-  %results
          :~  [%action 'SELECT']
              :-  %result-set
                  :~  :-  %vector
                          :~  [%col1 [~.t 'Abby']]
                              [%col2 [~.ud 6]]
                              [%col3 [~.ud 4]]
                              [%col4 [~.ud 6]]
                              ==
                      ==
              [%server-time ~2012.5.3]
              [%relation 'db1.dbo.my-table']
              [%schema-time ~2012.5.1]
              [%data-time ~2012.5.2]
              [%vector-count 1]
              ==
      ==
::
::  searched CASE scalar predicates on 10 joined rows with singleton and list CTEs
::  @ud
++  test-scalar-case-search-ud-00
  =/  query
    "WITH (FROM my-table ".
          "WHERE col1 = 'B' ".
          "SELECT col2, col3, col4, col5) AS one-cte, ".
          "(FROM my-table ".
          "WHERE col1 IN ('A', 'B', 'C') ".
          "SELECT col2, col3, col4, col5) AS list-cte ".
    "FROM my-table T1 CROSS JOIN my-table-2 T2 ".
    "SCALARS left-scalar CASE ".
                         "WHEN T1.col5 = 1 THEN T2.col2 ".
                         "WHEN T2.col5 = 4 THEN one-cte.col2 ".
                         "ELSE T1.col2 END ".
            "right-scalar CASE ".
                          "WHEN T2.col5 = 1 THEN one-cte.col2 ".
                          "WHEN T1.col5 = 3 THEN T2.col2 ".
                          "ELSE T1.col2 END ".
    "WHERE T1.col5 <= T2.col5 AND left-scalar = right-scalar ".
    "SELECT T1.col1, T2.col3"
  %:  run-scalar-joined-test
    query
    3
    :~  scalar-row-b-v
        scalar-row-b-w
        scalar-row-b-x
        ==
  ==
::
++  test-scalar-case-search-ud-01
  =/  query
    "WITH (FROM my-table ".
          "WHERE col1 = 'B' ".
          "SELECT col2, col3, col4, col5) AS one-cte, ".
          "(FROM my-table ".
          "WHERE col1 IN ('A', 'B', 'C') ".
          "SELECT col2, col3, col4, col5) AS list-cte ".
    "FROM my-table T1 CROSS JOIN my-table-2 T2 ".
    "SCALARS left-scalar CASE ".
                         "WHEN T1.col5 = 1 THEN T2.col2 ".
                         "WHEN T2.col5 = 4 THEN one-cte.col2 ".
                         "ELSE T1.col2 END ".
    "WHERE T1.col5 <= T2.col5 AND 1 = left-scalar ".
    "SELECT T1.col1, T2.col3"
  %:  run-scalar-joined-test
    query
    1
    :~  scalar-row-a-u
        ==
  ==
::
++  test-scalar-case-search-ud-02
  =/  query
    "WITH (FROM my-table ".
          "WHERE col1 = 'B' ".
          "SELECT col2, col3, col4, col5) AS one-cte, ".
          "(FROM my-table ".
          "WHERE col1 IN ('A', 'B', 'C') ".
          "SELECT col2, col3, col4, col5) AS list-cte ".
    "FROM my-table T1 CROSS JOIN my-table-2 T2 ".
    "SCALARS left-scalar CASE ".
                         "WHEN T1.col5 = 1 THEN T2.col2 ".
                         "WHEN T2.col5 = 4 THEN one-cte.col2 ".
                         "ELSE T1.col2 END ".
    "WHERE T1.col5 <= T2.col5 AND left-scalar = 6 ".
    "SELECT T1.col1, T2.col3"
  %:  run-scalar-joined-test
    query
    1
    :~  scalar-row-c-w
        ==
  ==
::
++  test-scalar-case-search-ud-03
  =/  query
    "WITH (FROM my-table ".
          "WHERE col1 = 'B' ".
          "SELECT col2, col3, col4, col5) AS one-cte, ".
          "(FROM my-table ".
          "WHERE col1 IN ('A', 'B', 'C') ".
          "SELECT col2, col3, col4, col5) AS list-cte ".
    "FROM my-table T1 CROSS JOIN my-table-2 T2 ".
    "SCALARS left-scalar CASE ".
                         "WHEN T1.col5 = 1 THEN T2.col2 ".
                         "WHEN T2.col5 = 4 THEN one-cte.col2 ".
                         "ELSE T1.col2 END ".
    "WHERE T1.col5 <= T2.col5 AND left-scalar = T2.col2 ".
    "SELECT T1.col1, T2.col3"
  %:  run-scalar-joined-test
    query
    4
    :~  scalar-row-a-u
        scalar-row-a-v
        scalar-row-a-w
        scalar-row-a-x
        ==
  ==
::
++  test-scalar-case-search-ud-04
  =/  query
    "WITH (FROM my-table ".
          "WHERE col1 = 'B' ".
          "SELECT col2, col3, col4, col5) AS one-cte, ".
          "(FROM my-table ".
          "WHERE col1 IN ('A', 'B', 'C') ".
          "SELECT col2, col3, col4, col5) AS list-cte ".
    "FROM my-table T1 CROSS JOIN my-table-2 T2 ".
    "SCALARS left-scalar CASE ".
                         "WHEN T1.col5 = 1 THEN T2.col2 ".
                         "WHEN T2.col5 = 4 THEN one-cte.col2 ".
                         "ELSE T1.col2 END ".
    "WHERE T1.col5 <= T2.col5 AND T1.col2 = left-scalar ".
    "SELECT T1.col1, T2.col3"
  %:  run-scalar-joined-test
    query
    4
    :~  scalar-row-b-v
        scalar-row-b-w
        scalar-row-b-x
        scalar-row-c-w
        ==
  ==
::
++  test-scalar-case-search-ud-05
  =/  query
    "WITH (FROM my-table ".
          "WHERE col1 = 'B' ".
          "SELECT col2, col3, col4, col5) AS one-cte, ".
          "(FROM my-table ".
          "WHERE col1 IN ('A', 'B', 'C') ".
          "SELECT col2, col3, col4, col5) AS list-cte ".
    "FROM my-table T1 CROSS JOIN my-table-2 T2 ".
    "SCALARS left-scalar CASE ".
                         "WHEN T1.col5 = 1 THEN T2.col2 ".
                         "WHEN T2.col5 = 4 THEN one-cte.col2 ".
                         "ELSE T1.col2 END ".
    "WHERE T1.col5 <= T2.col5 AND left-scalar IN list-cte.col2 ".
    "SELECT T1.col1, T2.col3"
  %:  run-scalar-joined-test
    query
    6
    :~  scalar-row-b-v
        scalar-row-b-w
        scalar-row-b-x
        scalar-row-c-w
        scalar-row-c-x
        scalar-row-d-x
        ==
  ==
::
::  @t
++  test-scalar-case-search-t-00
  =/  query
    "WITH (FROM my-table ".
          "WHERE col1 = 'B' ".
          "SELECT col2, col3, col4, col5) AS one-cte, ".
          "(FROM my-table ".
          "WHERE col1 IN ('A', 'B', 'C') ".
          "SELECT col2, col3, col4, col5) AS list-cte ".
    "FROM my-table T1 CROSS JOIN my-table-2 T2 ".
    "SCALARS left-scalar CASE ".
                         "WHEN T1.col5 = 1 THEN T2.col3 ".
                         "WHEN T2.col5 = 4 THEN one-cte.col3 ".
                         "ELSE T1.col3 END ".
            "right-scalar CASE ".
                          "WHEN T2.col5 = 1 THEN one-cte.col3 ".
                          "WHEN T1.col5 = 3 THEN T2.col3 ".
                          "ELSE T1.col3 END ".
    "WHERE T1.col5 <= T2.col5 AND left-scalar = right-scalar ".
    "SELECT T1.col1, T2.col3"
  %:  run-scalar-joined-test
    query
    3
    :~  scalar-row-b-v
        scalar-row-b-w
        scalar-row-b-x
        ==
  ==
::
++  test-scalar-case-search-t-01
  =/  query
    "WITH (FROM my-table ".
          "WHERE col1 = 'B' ".
          "SELECT col2, col3, col4, col5) AS one-cte, ".
          "(FROM my-table ".
          "WHERE col1 IN ('A', 'B', 'C') ".
          "SELECT col2, col3, col4, col5) AS list-cte ".
    "FROM my-table T1 CROSS JOIN my-table-2 T2 ".
    "SCALARS left-scalar CASE ".
                         "WHEN T1.col5 = 1 THEN T2.col3 ".
                         "WHEN T2.col5 = 4 THEN one-cte.col3 ".
                         "ELSE T1.col3 END ".
    "WHERE T1.col5 <= T2.col5 AND 'u' = left-scalar ".
    "SELECT T1.col1, T2.col3"
  %:  run-scalar-joined-test
    query
    1
    :~  scalar-row-a-u
        ==
  ==
::
++  test-scalar-case-search-t-02
  =/  query
    "WITH (FROM my-table ".
          "WHERE col1 = 'B' ".
          "SELECT col2, col3, col4, col5) AS one-cte, ".
          "(FROM my-table ".
          "WHERE col1 IN ('A', 'B', 'C') ".
          "SELECT col2, col3, col4, col5) AS list-cte ".
    "FROM my-table T1 CROSS JOIN my-table-2 T2 ".
    "SCALARS left-scalar CASE ".
                         "WHEN T1.col5 = 1 THEN T2.col3 ".
                         "WHEN T2.col5 = 4 THEN one-cte.col3 ".
                         "ELSE T1.col3 END ".
    "WHERE T1.col5 <= T2.col5 AND left-scalar = 'cobra' ".
    "SELECT T1.col1, T2.col3"
  %:  run-scalar-joined-test
    query
    1
    :~  scalar-row-c-w
        ==
  ==
::
++  test-scalar-case-search-t-03
  =/  query
    "WITH (FROM my-table ".
          "WHERE col1 = 'B' ".
          "SELECT col2, col3, col4, col5) AS one-cte, ".
          "(FROM my-table ".
          "WHERE col1 IN ('A', 'B', 'C') ".
          "SELECT col2, col3, col4, col5) AS list-cte ".
    "FROM my-table T1 CROSS JOIN my-table-2 T2 ".
    "SCALARS left-scalar CASE ".
                         "WHEN T1.col5 = 1 THEN T2.col3 ".
                         "WHEN T2.col5 = 4 THEN one-cte.col3 ".
                         "ELSE T1.col3 END ".
    "WHERE T1.col5 <= T2.col5 AND left-scalar = T2.col3 ".
    "SELECT T1.col1, T2.col3"
  %:  run-scalar-joined-test
    query
    4
    :~  scalar-row-a-u
        scalar-row-a-v
        scalar-row-a-w
        scalar-row-a-x
        ==
  ==
::
++  test-scalar-case-search-t-04
  =/  query
    "WITH (FROM my-table ".
          "WHERE col1 = 'B' ".
          "SELECT col2, col3, col4, col5) AS one-cte, ".
          "(FROM my-table ".
          "WHERE col1 IN ('A', 'B', 'C') ".
          "SELECT col2, col3, col4, col5) AS list-cte ".
    "FROM my-table T1 CROSS JOIN my-table-2 T2 ".
    "SCALARS left-scalar CASE ".
                         "WHEN T1.col5 = 1 THEN T2.col3 ".
                         "WHEN T2.col5 = 4 THEN one-cte.col3 ".
                         "ELSE T1.col3 END ".
    "WHERE T1.col5 <= T2.col5 AND T1.col3 = left-scalar ".
    "SELECT T1.col1, T2.col3"
  %:  run-scalar-joined-test
    query
    4
    :~  scalar-row-b-v
        scalar-row-b-w
        scalar-row-b-x
        scalar-row-c-w
        ==
  ==
::
++  test-scalar-case-search-t-05
  =/  query
    "WITH (FROM my-table ".
          "WHERE col1 = 'B' ".
          "SELECT col2, col3, col4, col5) AS one-cte, ".
          "(FROM my-table ".
          "WHERE col1 IN ('A', 'B', 'C') ".
          "SELECT col2, col3, col4, col5) AS list-cte ".
    "FROM my-table T1 CROSS JOIN my-table-2 T2 ".
    "SCALARS left-scalar CASE ".
                         "WHEN T1.col5 = 1 THEN T2.col3 ".
                         "WHEN T2.col5 = 4 THEN one-cte.col3 ".
                         "ELSE T1.col3 END ".
    "WHERE T1.col5 <= T2.col5 AND left-scalar IN list-cte.col3 ".
    "SELECT T1.col1, T2.col3"
  %:  run-scalar-joined-test
    query
    6
    :~  scalar-row-b-v
        scalar-row-b-w
        scalar-row-b-x
        scalar-row-c-w
        scalar-row-c-x
        scalar-row-d-x
        ==
  ==
::
::  @da
++  test-scalar-case-search-da-00
  =/  query
    "WITH (FROM my-table ".
          "WHERE col1 = 'B' ".
          "SELECT col2, col3, col4, col5) AS one-cte, ".
          "(FROM my-table ".
          "WHERE col1 IN ('A', 'B', 'C') ".
          "SELECT col2, col3, col4, col5) AS list-cte ".
    "FROM my-table T1 CROSS JOIN my-table-2 T2 ".
    "SCALARS left-scalar CASE ".
                         "WHEN T1.col5 = 1 THEN T2.col4 ".
                         "WHEN T2.col5 = 4 THEN one-cte.col4 ".
                         "ELSE T1.col4 END ".
            "right-scalar CASE ".
                          "WHEN T2.col5 = 1 THEN one-cte.col4 ".
                          "WHEN T1.col5 = 3 THEN T2.col4 ".
                          "ELSE T1.col4 END ".
    "WHERE T1.col5 <= T2.col5 AND left-scalar = right-scalar ".
    "SELECT T1.col1, T2.col3"
  %:  run-scalar-joined-test
    query
    3
    :~  scalar-row-b-v
        scalar-row-b-w
        scalar-row-b-x
        ==
  ==
::
++  test-scalar-case-search-da-01
  =/  query
    "WITH (FROM my-table ".
          "WHERE col1 = 'B' ".
          "SELECT col2, col3, col4, col5) AS one-cte, ".
          "(FROM my-table ".
          "WHERE col1 IN ('A', 'B', 'C') ".
          "SELECT col2, col3, col4, col5) AS list-cte ".
    "FROM my-table T1 CROSS JOIN my-table-2 T2 ".
    "SCALARS left-scalar CASE ".
                         "WHEN T1.col5 = 1 THEN T2.col4 ".
                         "WHEN T2.col5 = 4 THEN one-cte.col4 ".
                         "ELSE T1.col4 END ".
    "WHERE T1.col5 <= T2.col5 AND ~2024.1.1 = left-scalar ".
    "SELECT T1.col1, T2.col3"
  %:  run-scalar-joined-test
    query
    1
    :~  scalar-row-a-u
        ==
  ==
::
++  test-scalar-case-search-da-02
  =/  query
    "WITH (FROM my-table ".
          "WHERE col1 = 'B' ".
          "SELECT col2, col3, col4, col5) AS one-cte, ".
          "(FROM my-table ".
          "WHERE col1 IN ('A', 'B', 'C') ".
          "SELECT col2, col3, col4, col5) AS list-cte ".
    "FROM my-table T1 CROSS JOIN my-table-2 T2 ".
    "SCALARS left-scalar CASE ".
                         "WHEN T1.col5 = 1 THEN T2.col4 ".
                         "WHEN T2.col5 = 4 THEN one-cte.col4 ".
                         "ELSE T1.col4 END ".
    "WHERE T1.col5 <= T2.col5 AND left-scalar = ~2024.1.6 ".
    "SELECT T1.col1, T2.col3"
  %:  run-scalar-joined-test
    query
    1
    :~  scalar-row-c-w
        ==
  ==
::
++  test-scalar-case-search-da-03
  =/  query
    "WITH (FROM my-table ".
          "WHERE col1 = 'B' ".
          "SELECT col2, col3, col4, col5) AS one-cte, ".
          "(FROM my-table ".
          "WHERE col1 IN ('A', 'B', 'C') ".
          "SELECT col2, col3, col4, col5) AS list-cte ".
    "FROM my-table T1 CROSS JOIN my-table-2 T2 ".
    "SCALARS left-scalar CASE ".
                         "WHEN T1.col5 = 1 THEN T2.col4 ".
                         "WHEN T2.col5 = 4 THEN one-cte.col4 ".
                         "ELSE T1.col4 END ".
    "WHERE T1.col5 <= T2.col5 AND left-scalar = T2.col4 ".
    "SELECT T1.col1, T2.col3"
  %:  run-scalar-joined-test
    query
    4
    :~  scalar-row-a-u
        scalar-row-a-v
        scalar-row-a-w
        scalar-row-a-x
        ==
  ==
::
++  test-scalar-case-search-da-04
  =/  query
    "WITH (FROM my-table ".
          "WHERE col1 = 'B' ".
          "SELECT col2, col3, col4, col5) AS one-cte, ".
          "(FROM my-table ".
          "WHERE col1 IN ('A', 'B', 'C') ".
          "SELECT col2, col3, col4, col5) AS list-cte ".
    "FROM my-table T1 CROSS JOIN my-table-2 T2 ".
    "SCALARS left-scalar CASE ".
                         "WHEN T1.col5 = 1 THEN T2.col4 ".
                         "WHEN T2.col5 = 4 THEN one-cte.col4 ".
                         "ELSE T1.col4 END ".
    "WHERE T1.col5 <= T2.col5 AND T1.col4 = left-scalar ".
    "SELECT T1.col1, T2.col3"
  %:  run-scalar-joined-test
    query
    4
    :~  scalar-row-b-v
        scalar-row-b-w
        scalar-row-b-x
        scalar-row-c-w
        ==
  ==
::
++  test-scalar-case-search-da-05
  =/  query
    "WITH (FROM my-table ".
          "WHERE col1 = 'B' ".
          "SELECT col2, col3, col4, col5) AS one-cte, ".
          "(FROM my-table ".
          "WHERE col1 IN ('A', 'B', 'C') ".
          "SELECT col2, col3, col4, col5) AS list-cte ".
    "FROM my-table T1 CROSS JOIN my-table-2 T2 ".
    "SCALARS left-scalar CASE ".
                         "WHEN T1.col5 = 1 THEN T2.col4 ".
                         "WHEN T2.col5 = 4 THEN one-cte.col4 ".
                         "ELSE T1.col4 END ".
    "WHERE T1.col5 <= T2.col5 AND left-scalar IN list-cte.col4 ".
    "SELECT T1.col1, T2.col3"
  %:  run-scalar-joined-test
    query
    6
    :~  scalar-row-b-v
        scalar-row-b-w
        scalar-row-b-x
        scalar-row-c-w
        scalar-row-c-x
        scalar-row-d-x
        ==
  ==
::
::  simple CASE scalar predicates on 10 joined rows with singleton and list CTEs
::  @ud
++  test-scalar-case-simple-ud-00
  =/  query
    "WITH (FROM my-table ".
          "WHERE col1 = 'B' ".
          "SELECT col2, col3, col4, col5) AS one-cte, ".
          "(FROM my-table ".
          "WHERE col1 IN ('A', 'B', 'C') ".
          "SELECT col2, col3, col4, col5) AS list-cte ".
    "FROM my-table T1 CROSS JOIN my-table-2 T2 ".
    "SCALARS target-scalar CASE ".
                          "WHEN T1.col5 = 1 THEN 1 ".
                          "WHEN T2.col5 = 4 THEN one-cte.col5 ".
                          "ELSE 3 END ".
            "left-scalar CASE target-scalar ".
                        "WHEN 1 THEN T2.col2 ".
                        "WHEN 2 THEN one-cte.col2 ".
                        "ELSE T1.col2 END ".
            "right-scalar CASE target-scalar ".
                         "WHEN 1 THEN T1.col2 ".
                         "WHEN 2 THEN one-cte.col2 ".
                         "ELSE T2.col2 END ".
    "WHERE T1.col5 <= T2.col5 AND left-scalar = right-scalar ".
    "SELECT T1.col1, T2.col3"
  %:  run-scalar-joined-test
    query
    3
    :~  scalar-row-b-x
        scalar-row-c-x
        scalar-row-d-x
        ==
  ==
::
++  test-scalar-case-simple-ud-01
  =/  query
    "WITH (FROM my-table ".
          "WHERE col1 = 'B' ".
          "SELECT col2, col3, col4, col5) AS one-cte, ".
          "(FROM my-table ".
          "WHERE col1 IN ('A', 'B', 'C') ".
          "SELECT col2, col3, col4, col5) AS list-cte ".
    "FROM my-table T1 CROSS JOIN my-table-2 T2 ".
    "SCALARS left-scalar CASE one-cte.col5 ".
                         "WHEN 2 THEN T2.col2 ".
                         "WHEN 1 THEN one-cte.col2 ".
                         "ELSE T1.col2 END ".
    "WHERE T1.col5 <= T2.col5 AND 7 = left-scalar ".
    "SELECT T1.col1, T2.col3"
  %:  run-scalar-joined-test
    query
    4
    :~  scalar-row-a-x
        scalar-row-b-x
        scalar-row-c-x
        scalar-row-d-x
        ==
  ==
::
++  test-scalar-case-simple-ud-02
  =/  query
    "WITH (FROM my-table ".
          "WHERE col1 = 'B' ".
          "SELECT col2, col3, col4, col5) AS one-cte, ".
          "(FROM my-table ".
          "WHERE col1 IN ('A', 'B', 'C') ".
          "SELECT col2, col3, col4, col5) AS list-cte ".
    "FROM my-table T1 CROSS JOIN my-table-2 T2 ".
    "SCALARS left-scalar CASE (T1.col5 + T2.col5 - T2.col5 + one-cte.col5 - one-cte.col5) ".
                         "WHEN 1 THEN T2.col2 ".
                         "WHEN 2 THEN one-cte.col2 ".
                         "ELSE T1.col2 END ".
    "WHERE T1.col5 <= T2.col5 AND left-scalar = 6 ".
    "SELECT T1.col1, T2.col3"
  %:  run-scalar-joined-test
    query
    2
    :~  scalar-row-c-w
        scalar-row-c-x
        ==
  ==
::
++  test-scalar-case-simple-ud-03
  =/  query
    "WITH (FROM my-table ".
          "WHERE col1 = 'B' ".
          "SELECT col2, col3, col4, col5) AS one-cte, ".
          "(FROM my-table ".
          "WHERE col1 IN ('A', 'B', 'C') ".
          "SELECT col2, col3, col4, col5) AS list-cte ".
    "FROM my-table T1 CROSS JOIN my-table-2 T2 ".
    "SCALARS left-scalar CASE T1.col5 ".
                         "WHEN 1 THEN T2.col2 ".
                         "WHEN 2 THEN one-cte.col2 ".
                         "ELSE T1.col2 END ".
    "WHERE T1.col5 <= T2.col5 AND left-scalar = T2.col2 ".
    "SELECT T1.col1, T2.col3"
  %:  run-scalar-joined-test
    query
    4
    :~  scalar-row-a-u
        scalar-row-a-v
        scalar-row-a-w
        scalar-row-a-x
        ==
  ==
::
++  test-scalar-case-simple-ud-04
  =/  query
    "WITH (FROM my-table ".
          "WHERE col1 = 'B' ".
          "SELECT col2, col3, col4, col5) AS one-cte, ".
          "(FROM my-table ".
          "WHERE col1 IN ('A', 'B', 'C') ".
          "SELECT col2, col3, col4, col5) AS list-cte ".
    "FROM my-table T1 CROSS JOIN my-table-2 T2 ".
    "SCALARS left-scalar CASE (T1.col5 + T2.col5 - T2.col5 + one-cte.col5 - one-cte.col5) ".
                         "WHEN 1 THEN T2.col2 ".
                         "WHEN 2 THEN one-cte.col2 ".
                         "ELSE T1.col2 END ".
    "WHERE T1.col5 <= T2.col5 AND T1.col2 = left-scalar ".
    "SELECT T1.col1, T2.col3"
  %:  run-scalar-joined-test
    query
    6
    :~  scalar-row-b-v
        scalar-row-b-w
        scalar-row-b-x
        scalar-row-c-w
        scalar-row-c-x
        scalar-row-d-x
        ==
  ==
::
++  test-scalar-case-simple-ud-05
  =/  query
    "WITH (FROM my-table ".
          "WHERE col1 = 'B' ".
          "SELECT col2, col3, col4, col5) AS one-cte, ".
          "(FROM my-table ".
          "WHERE col1 IN ('A', 'B', 'C') ".
          "SELECT col2, col3, col4, col5) AS list-cte ".
    "FROM my-table T1 CROSS JOIN my-table-2 T2 ".
    "SCALARS target-scalar CASE ".
                          "WHEN T1.col5 = 1 THEN 1 ".
                          "WHEN T2.col5 = 4 THEN one-cte.col5 ".
                          "ELSE 3 END ".
            "left-scalar CASE target-scalar ".
                        "WHEN 1 THEN T2.col2 ".
                        "WHEN 2 THEN one-cte.col2 ".
                        "ELSE T1.col2 END ".
    "WHERE T1.col5 <= T2.col5 AND left-scalar IN list-cte.col2 ".
    "SELECT T1.col1, T2.col3"
  %:  run-scalar-joined-test
    query
    6
    :~  scalar-row-b-v
        scalar-row-b-w
        scalar-row-b-x
        scalar-row-c-w
        scalar-row-c-x
        scalar-row-d-x
        ==
  ==
::
::  @t
++  test-scalar-case-simple-t-00
  =/  query
    "WITH (FROM my-table ".
          "WHERE col1 = 'B' ".
          "SELECT col2, col3, col4, col5) AS one-cte, ".
          "(FROM my-table ".
          "WHERE col1 IN ('A', 'B', 'C') ".
          "SELECT col2, col3, col4, col5) AS list-cte ".
    "FROM my-table T1 CROSS JOIN my-table-2 T2 ".
    "SCALARS target-scalar CASE ".
                          "WHEN T1.col5 = 1 THEN 1 ".
                          "WHEN T2.col5 = 4 THEN one-cte.col5 ".
                          "ELSE 3 END ".
            "left-scalar CASE target-scalar ".
                        "WHEN 1 THEN T2.col3 ".
                        "WHEN 2 THEN one-cte.col3 ".
                        "ELSE T1.col3 END ".
            "right-scalar CASE target-scalar ".
                         "WHEN 1 THEN T1.col3 ".
                         "WHEN 2 THEN one-cte.col3 ".
                         "ELSE T2.col3 END ".
    "WHERE T1.col5 <= T2.col5 AND left-scalar = right-scalar ".
    "SELECT T1.col1, T2.col3"
  %:  run-scalar-joined-test
    query
    3
    :~  scalar-row-b-x
        scalar-row-c-x
        scalar-row-d-x
        ==
  ==
::
++  test-scalar-case-simple-t-01
  =/  query
    "WITH (FROM my-table ".
          "WHERE col1 = 'B' ".
          "SELECT col2, col3, col4, col5) AS one-cte, ".
          "(FROM my-table ".
          "WHERE col1 IN ('A', 'B', 'C') ".
          "SELECT col2, col3, col4, col5) AS list-cte ".
    "FROM my-table T1 CROSS JOIN my-table-2 T2 ".
    "SCALARS left-scalar CASE one-cte.col5 ".
                         "WHEN 2 THEN T2.col3 ".
                         "WHEN 1 THEN one-cte.col3 ".
                         "ELSE T1.col3 END ".
    "WHERE T1.col5 <= T2.col5 AND 'x' = left-scalar ".
    "SELECT T1.col1, T2.col3"
  %:  run-scalar-joined-test
    query
    4
    :~  scalar-row-a-x
        scalar-row-b-x
        scalar-row-c-x
        scalar-row-d-x
        ==
  ==
::
++  test-scalar-case-simple-t-02
  =/  query
    "WITH (FROM my-table ".
          "WHERE col1 = 'B' ".
          "SELECT col2, col3, col4, col5) AS one-cte, ".
          "(FROM my-table ".
          "WHERE col1 IN ('A', 'B', 'C') ".
          "SELECT col2, col3, col4, col5) AS list-cte ".
    "FROM my-table T1 CROSS JOIN my-table-2 T2 ".
    "SCALARS left-scalar CASE (T1.col5 + T2.col5 - T2.col5 + one-cte.col5 - one-cte.col5) ".
                         "WHEN 1 THEN T2.col3 ".
                         "WHEN 2 THEN one-cte.col3 ".
                         "ELSE T1.col3 END ".
    "WHERE T1.col5 <= T2.col5 AND left-scalar = 'cobra' ".
    "SELECT T1.col1, T2.col3"
  %:  run-scalar-joined-test
    query
    2
    :~  scalar-row-c-w
        scalar-row-c-x
        ==
  ==
::
++  test-scalar-case-simple-t-03
  =/  query
    "WITH (FROM my-table ".
          "WHERE col1 = 'B' ".
          "SELECT col2, col3, col4, col5) AS one-cte, ".
          "(FROM my-table ".
          "WHERE col1 IN ('A', 'B', 'C') ".
          "SELECT col2, col3, col4, col5) AS list-cte ".
    "FROM my-table T1 CROSS JOIN my-table-2 T2 ".
    "SCALARS left-scalar CASE T1.col5 ".
                         "WHEN 1 THEN T2.col3 ".
                         "WHEN 2 THEN one-cte.col3 ".
                         "ELSE T1.col3 END ".
    "WHERE T1.col5 <= T2.col5 AND left-scalar = T2.col3 ".
    "SELECT T1.col1, T2.col3"
  %:  run-scalar-joined-test
    query
    4
    :~  scalar-row-a-u
        scalar-row-a-v
        scalar-row-a-w
        scalar-row-a-x
        ==
  ==
::
++  test-scalar-case-simple-t-04
  =/  query
    "WITH (FROM my-table ".
          "WHERE col1 = 'B' ".
          "SELECT col2, col3, col4, col5) AS one-cte, ".
          "(FROM my-table ".
          "WHERE col1 IN ('A', 'B', 'C') ".
          "SELECT col2, col3, col4, col5) AS list-cte ".
    "FROM my-table T1 CROSS JOIN my-table-2 T2 ".
    "SCALARS left-scalar CASE (T1.col5 + T2.col5 - T2.col5 + one-cte.col5 - one-cte.col5) ".
                         "WHEN 1 THEN T2.col3 ".
                         "WHEN 2 THEN one-cte.col3 ".
                         "ELSE T1.col3 END ".
    "WHERE T1.col5 <= T2.col5 AND T1.col3 = left-scalar ".
    "SELECT T1.col1, T2.col3"
  %:  run-scalar-joined-test
    query
    6
    :~  scalar-row-b-v
        scalar-row-b-w
        scalar-row-b-x
        scalar-row-c-w
        scalar-row-c-x
        scalar-row-d-x
        ==
  ==
::
++  test-scalar-case-simple-t-05
  =/  query
    "WITH (FROM my-table ".
          "WHERE col1 = 'B' ".
          "SELECT col2, col3, col4, col5) AS one-cte, ".
          "(FROM my-table ".
          "WHERE col1 IN ('A', 'B', 'C') ".
          "SELECT col2, col3, col4, col5) AS list-cte ".
    "FROM my-table T1 CROSS JOIN my-table-2 T2 ".
    "SCALARS target-scalar CASE ".
                          "WHEN T1.col5 = 1 THEN 1 ".
                          "WHEN T2.col5 = 4 THEN one-cte.col5 ".
                          "ELSE 3 END ".
            "left-scalar CASE target-scalar ".
                        "WHEN 1 THEN T2.col3 ".
                        "WHEN 2 THEN one-cte.col3 ".
                        "ELSE T1.col3 END ".
    "WHERE T1.col5 <= T2.col5 AND left-scalar IN list-cte.col3 ".
    "SELECT T1.col1, T2.col3"
  %:  run-scalar-joined-test
    query
    6
    :~  scalar-row-b-v
        scalar-row-b-w
        scalar-row-b-x
        scalar-row-c-w
        scalar-row-c-x
        scalar-row-d-x
        ==
  ==
::
::  @da
++  test-scalar-case-simple-da-00
  =/  query
    "WITH (FROM my-table ".
          "WHERE col1 = 'B' ".
          "SELECT col2, col3, col4, col5) AS one-cte, ".
          "(FROM my-table ".
          "WHERE col1 IN ('A', 'B', 'C') ".
          "SELECT col2, col3, col4, col5) AS list-cte ".
    "FROM my-table T1 CROSS JOIN my-table-2 T2 ".
    "SCALARS target-scalar CASE ".
                          "WHEN T1.col5 = 1 THEN 1 ".
                          "WHEN T2.col5 = 4 THEN one-cte.col5 ".
                          "ELSE 3 END ".
            "left-scalar CASE target-scalar ".
                        "WHEN 1 THEN T2.col4 ".
                        "WHEN 2 THEN one-cte.col4 ".
                        "ELSE T1.col4 END ".
            "right-scalar CASE target-scalar ".
                         "WHEN 1 THEN T1.col4 ".
                         "WHEN 2 THEN one-cte.col4 ".
                         "ELSE T2.col4 END ".
    "WHERE T1.col5 <= T2.col5 AND left-scalar = right-scalar ".
    "SELECT T1.col1, T2.col3"
  %:  run-scalar-joined-test
    query
    3
    :~  scalar-row-b-x
        scalar-row-c-x
        scalar-row-d-x
        ==
  ==
::
++  test-scalar-case-simple-da-01
  =/  query
    "WITH (FROM my-table ".
          "WHERE col1 = 'B' ".
          "SELECT col2, col3, col4, col5) AS one-cte, ".
          "(FROM my-table ".
          "WHERE col1 IN ('A', 'B', 'C') ".
          "SELECT col2, col3, col4, col5) AS list-cte ".
    "FROM my-table T1 CROSS JOIN my-table-2 T2 ".
    "SCALARS left-scalar CASE one-cte.col5 ".
                         "WHEN 2 THEN T2.col4 ".
                         "WHEN 1 THEN one-cte.col4 ".
                         "ELSE T1.col4 END ".
    "WHERE T1.col5 <= T2.col5 AND ~2024.1.7 = left-scalar ".
    "SELECT T1.col1, T2.col3"
  %:  run-scalar-joined-test
    query
    4
    :~  scalar-row-a-x
        scalar-row-b-x
        scalar-row-c-x
        scalar-row-d-x
        ==
  ==
::
++  test-scalar-case-simple-da-02
  =/  query
    "WITH (FROM my-table ".
          "WHERE col1 = 'B' ".
          "SELECT col2, col3, col4, col5) AS one-cte, ".
          "(FROM my-table ".
          "WHERE col1 IN ('A', 'B', 'C') ".
          "SELECT col2, col3, col4, col5) AS list-cte ".
    "FROM my-table T1 CROSS JOIN my-table-2 T2 ".
    "SCALARS left-scalar CASE (T1.col5 + T2.col5 - T2.col5 + one-cte.col5 - one-cte.col5) ".
                         "WHEN 1 THEN T2.col4 ".
                         "WHEN 2 THEN one-cte.col4 ".
                         "ELSE T1.col4 END ".
    "WHERE T1.col5 <= T2.col5 AND left-scalar = ~2024.1.6 ".
    "SELECT T1.col1, T2.col3"
  %:  run-scalar-joined-test
    query
    2
    :~  scalar-row-c-w
        scalar-row-c-x
        ==
  ==
::
++  test-scalar-case-simple-da-03
  =/  query
    "WITH (FROM my-table ".
          "WHERE col1 = 'B' ".
          "SELECT col2, col3, col4, col5) AS one-cte, ".
          "(FROM my-table ".
          "WHERE col1 IN ('A', 'B', 'C') ".
          "SELECT col2, col3, col4, col5) AS list-cte ".
    "FROM my-table T1 CROSS JOIN my-table-2 T2 ".
    "SCALARS left-scalar CASE T1.col5 ".
                         "WHEN 1 THEN T2.col4 ".
                         "WHEN 2 THEN one-cte.col4 ".
                         "ELSE T1.col4 END ".
    "WHERE T1.col5 <= T2.col5 AND left-scalar = T2.col4 ".
    "SELECT T1.col1, T2.col3"
  %:  run-scalar-joined-test
    query
    4
    :~  scalar-row-a-u
        scalar-row-a-v
        scalar-row-a-w
        scalar-row-a-x
        ==
  ==
::
++  test-scalar-case-simple-da-04
  =/  query
    "WITH (FROM my-table ".
          "WHERE col1 = 'B' ".
          "SELECT col2, col3, col4, col5) AS one-cte, ".
          "(FROM my-table ".
          "WHERE col1 IN ('A', 'B', 'C') ".
          "SELECT col2, col3, col4, col5) AS list-cte ".
    "FROM my-table T1 CROSS JOIN my-table-2 T2 ".
    "SCALARS left-scalar CASE (T1.col5 + T2.col5 - T2.col5 + one-cte.col5 - one-cte.col5) ".
                         "WHEN 1 THEN T2.col4 ".
                         "WHEN 2 THEN one-cte.col4 ".
                         "ELSE T1.col4 END ".
    "WHERE T1.col5 <= T2.col5 AND T1.col4 = left-scalar ".
    "SELECT T1.col1, T2.col3"
  %:  run-scalar-joined-test
    query
    6
    :~  scalar-row-b-v
        scalar-row-b-w
        scalar-row-b-x
        scalar-row-c-w
        scalar-row-c-x
        scalar-row-d-x
        ==
  ==
::
++  test-scalar-case-simple-da-05
  =/  query
    "WITH (FROM my-table ".
          "WHERE col1 = 'B' ".
          "SELECT col2, col3, col4, col5) AS one-cte, ".
          "(FROM my-table ".
          "WHERE col1 IN ('A', 'B', 'C') ".
          "SELECT col2, col3, col4, col5) AS list-cte ".
    "FROM my-table T1 CROSS JOIN my-table-2 T2 ".
    "SCALARS target-scalar CASE ".
                          "WHEN T1.col5 = 1 THEN 1 ".
                          "WHEN T2.col5 = 4 THEN one-cte.col5 ".
                          "ELSE 3 END ".
            "left-scalar CASE target-scalar ".
                        "WHEN 1 THEN T2.col4 ".
                        "WHEN 2 THEN one-cte.col4 ".
                        "ELSE T1.col4 END ".
    "WHERE T1.col5 <= T2.col5 AND left-scalar IN list-cte.col4 ".
    "SELECT T1.col1, T2.col3"
  %:  run-scalar-joined-test
    query
    6
    :~  scalar-row-b-v
        scalar-row-b-w
        scalar-row-b-x
        scalar-row-c-w
        scalar-row-c-x
        scalar-row-d-x
        ==
  ==
::
::  if-then-else scalar predicates on 10 joined rows with singleton and list CTEs
::  @ud
++  test-scalar-if-then-else-ud-00
  =/  query
    "WITH (FROM my-table ".
          "WHERE col1 = 'B' ".
          "SELECT col2, col3, col4, col5) AS one-cte, ".
          "(FROM my-table ".
          "WHERE col1 IN ('A', 'B', 'C') ".
          "SELECT col2, col3, col4, col5) AS list-cte ".
    "FROM my-table T1 CROSS JOIN my-table-2 T2 ".
    "SCALARS plus-two-scalar one-cte.col5 + 2 END ".
            "left-scalar IF T1.col5 = 1 OR T2.col5 = plus-two-scalar ".
                        "THEN T2.col2 ".
                        "ELSE T1.col2 ENDIF ".
            "right-scalar IF T1.col5 = one-cte.col5 OR T2.col5 = 3 ".
                         "THEN T1.col2 ".
                         "ELSE one-cte.col2 ENDIF ".
    "WHERE T1.col5 <= T2.col5 AND left-scalar = right-scalar ".
    "SELECT T1.col1, T2.col3"
  %:  run-scalar-joined-test
    query
    3
    :~  scalar-row-b-v
        scalar-row-b-w
        scalar-row-c-w
        ==
  ==
::
++  test-scalar-if-then-else-ud-01
  =/  query
    "WITH (FROM my-table ".
          "WHERE col1 = 'B' ".
          "SELECT col2, col3, col4, col5) AS one-cte, ".
          "(FROM my-table ".
          "WHERE col1 IN ('A', 'B', 'C') ".
          "SELECT col2, col3, col4, col5) AS list-cte ".
    "FROM my-table T1 CROSS JOIN my-table-2 T2 ".
    "SCALARS plus-two-scalar one-cte.col5 + 2 END ".
            "left-scalar IF T1.col5 = 1 OR T2.col5 = plus-two-scalar ".
                        "THEN T2.col2 ".
                        "ELSE T1.col2 ENDIF ".
    "WHERE T1.col5 <= T2.col5 AND 7 = left-scalar ".
    "SELECT T1.col1, T2.col3"
  %:  run-scalar-joined-test
    query
    4
    :~  scalar-row-a-x
        scalar-row-b-x
        scalar-row-c-x
        scalar-row-d-x
        ==
  ==
::
++  test-scalar-if-then-else-ud-02
  =/  query
    "WITH (FROM my-table ".
          "WHERE col1 = 'B' ".
          "SELECT col2, col3, col4, col5) AS one-cte, ".
          "(FROM my-table ".
          "WHERE col1 IN ('A', 'B', 'C') ".
          "SELECT col2, col3, col4, col5) AS list-cte ".
    "FROM my-table T1 CROSS JOIN my-table-2 T2 ".
    "SCALARS plus-two-scalar one-cte.col5 + 2 END ".
            "left-scalar IF T1.col5 = 1 OR T2.col5 = plus-two-scalar ".
                        "THEN T2.col2 ".
                        "ELSE T1.col2 ENDIF ".
    "WHERE T1.col5 <= T2.col5 AND left-scalar = 1 ".
    "SELECT T1.col1, T2.col3"
  %:  run-scalar-joined-test
    query
    1
    :~  scalar-row-a-u
        ==
  ==
::
++  test-scalar-if-then-else-ud-03
  =/  query
    "WITH (FROM my-table ".
          "WHERE col1 = 'B' ".
          "SELECT col2, col3, col4, col5) AS one-cte, ".
          "(FROM my-table ".
          "WHERE col1 IN ('A', 'B', 'C') ".
          "SELECT col2, col3, col4, col5) AS list-cte ".
    "FROM my-table T1 CROSS JOIN my-table-2 T2 ".
    "SCALARS plus-two-scalar one-cte.col5 + 2 END ".
            "left-scalar IF T1.col5 = 1 OR T2.col5 = plus-two-scalar ".
                        "THEN T2.col2 ".
                        "ELSE T1.col2 ENDIF ".
    "WHERE T1.col5 <= T2.col5 AND left-scalar = T2.col2 ".
    "SELECT T1.col1, T2.col3"
  %:  run-scalar-joined-test
    query
    7
    :~  scalar-row-a-u
        scalar-row-a-v
        scalar-row-a-w
        scalar-row-a-x
        scalar-row-b-x
        scalar-row-c-x
        scalar-row-d-x
        ==
  ==
::
++  test-scalar-if-then-else-ud-04
  =/  query
    "WITH (FROM my-table ".
          "WHERE col1 = 'B' ".
          "SELECT col2, col3, col4, col5) AS one-cte, ".
          "(FROM my-table ".
          "WHERE col1 IN ('A', 'B', 'C') ".
          "SELECT col2, col3, col4, col5) AS list-cte ".
    "FROM my-table T1 CROSS JOIN my-table-2 T2 ".
    "SCALARS plus-two-scalar one-cte.col5 + 2 END ".
            "left-scalar IF T1.col5 = 1 OR T2.col5 = plus-two-scalar ".
                        "THEN T2.col2 ".
                        "ELSE T1.col2 ENDIF ".
    "WHERE T1.col5 <= T2.col5 AND T1.col2 = left-scalar ".
    "SELECT T1.col1, T2.col3"
  %:  run-scalar-joined-test
    query
    3
    :~  scalar-row-b-v
        scalar-row-b-w
        scalar-row-c-w
        ==
  ==
::
++  test-scalar-if-then-else-ud-05
  =/  query
    "WITH (FROM my-table ".
          "WHERE col1 = 'B' ".
          "SELECT col2, col3, col4, col5) AS one-cte, ".
          "(FROM my-table ".
          "WHERE col1 IN ('A', 'B', 'C') ".
          "SELECT col2, col3, col4, col5) AS list-cte ".
    "FROM my-table T1 CROSS JOIN my-table-2 T2 ".
    "SCALARS plus-two-scalar one-cte.col5 + 2 END ".
            "left-scalar IF T1.col5 = 1 OR T2.col5 = plus-two-scalar ".
                        "THEN T2.col2 ".
                        "ELSE T1.col2 ENDIF ".
    "WHERE T1.col5 <= T2.col5 AND left-scalar IN list-cte.col2 ".
    "SELECT T1.col1, T2.col3"
  %:  run-scalar-joined-test
    query
    3
    :~  scalar-row-b-v
        scalar-row-b-w
        scalar-row-c-w
        ==
  ==
::
::  @t
++  test-scalar-if-then-else-t-00
  =/  query
    "WITH (FROM my-table ".
          "WHERE col1 = 'B' ".
          "SELECT col2, col3, col4, col5) AS one-cte, ".
          "(FROM my-table ".
          "WHERE col1 IN ('A', 'B', 'C') ".
          "SELECT col2, col3, col4, col5) AS list-cte ".
    "FROM my-table T1 CROSS JOIN my-table-2 T2 ".
    "SCALARS plus-two-scalar one-cte.col5 + 2 END ".
            "left-scalar IF T1.col5 = 1 OR T2.col5 = plus-two-scalar ".
                        "THEN T2.col3 ".
                        "ELSE T1.col3 ENDIF ".
            "right-scalar IF T1.col5 = one-cte.col5 OR T2.col5 = 3 ".
                         "THEN T1.col3 ".
                         "ELSE one-cte.col3 ENDIF ".
    "WHERE T1.col5 <= T2.col5 AND left-scalar = right-scalar ".
    "SELECT T1.col1, T2.col3"
  %:  run-scalar-joined-test
    query
    3
    :~  scalar-row-b-v
        scalar-row-b-w
        scalar-row-c-w
        ==
  ==
::
++  test-scalar-if-then-else-t-01
  =/  query
    "WITH (FROM my-table ".
          "WHERE col1 = 'B' ".
          "SELECT col2, col3, col4, col5) AS one-cte, ".
          "(FROM my-table ".
          "WHERE col1 IN ('A', 'B', 'C') ".
          "SELECT col2, col3, col4, col5) AS list-cte ".
    "FROM my-table T1 CROSS JOIN my-table-2 T2 ".
    "SCALARS plus-two-scalar one-cte.col5 + 2 END ".
            "left-scalar IF T1.col5 = 1 OR T2.col5 = plus-two-scalar ".
                        "THEN T2.col3 ".
                        "ELSE T1.col3 ENDIF ".
    "WHERE T1.col5 <= T2.col5 AND 'x' = left-scalar ".
    "SELECT T1.col1, T2.col3"
  %:  run-scalar-joined-test
    query
    4
    :~  scalar-row-a-x
        scalar-row-b-x
        scalar-row-c-x
        scalar-row-d-x
        ==
  ==
::
++  test-scalar-if-then-else-t-02
  =/  query
    "WITH (FROM my-table ".
          "WHERE col1 = 'B' ".
          "SELECT col2, col3, col4, col5) AS one-cte, ".
          "(FROM my-table ".
          "WHERE col1 IN ('A', 'B', 'C') ".
          "SELECT col2, col3, col4, col5) AS list-cte ".
    "FROM my-table T1 CROSS JOIN my-table-2 T2 ".
    "SCALARS plus-two-scalar one-cte.col5 + 2 END ".
            "left-scalar IF T1.col5 = 1 OR T2.col5 = plus-two-scalar ".
                        "THEN T2.col3 ".
                        "ELSE T1.col3 ENDIF ".
    "WHERE T1.col5 <= T2.col5 AND left-scalar = 'u' ".
    "SELECT T1.col1, T2.col3"
  %:  run-scalar-joined-test
    query
    1
    :~  scalar-row-a-u
        ==
  ==
::
++  test-scalar-if-then-else-t-03
  =/  query
    "WITH (FROM my-table ".
          "WHERE col1 = 'B' ".
          "SELECT col2, col3, col4, col5) AS one-cte, ".
          "(FROM my-table ".
          "WHERE col1 IN ('A', 'B', 'C') ".
          "SELECT col2, col3, col4, col5) AS list-cte ".
    "FROM my-table T1 CROSS JOIN my-table-2 T2 ".
    "SCALARS plus-two-scalar one-cte.col5 + 2 END ".
            "left-scalar IF T1.col5 = 1 OR T2.col5 = plus-two-scalar ".
                        "THEN T2.col3 ".
                        "ELSE T1.col3 ENDIF ".
    "WHERE T1.col5 <= T2.col5 AND left-scalar = T2.col3 ".
    "SELECT T1.col1, T2.col3"
  %:  run-scalar-joined-test
    query
    7
    :~  scalar-row-a-u
        scalar-row-a-v
        scalar-row-a-w
        scalar-row-a-x
        scalar-row-b-x
        scalar-row-c-x
        scalar-row-d-x
        ==
  ==
::
++  test-scalar-if-then-else-t-04
  =/  query
    "WITH (FROM my-table ".
          "WHERE col1 = 'B' ".
          "SELECT col2, col3, col4, col5) AS one-cte, ".
          "(FROM my-table ".
          "WHERE col1 IN ('A', 'B', 'C') ".
          "SELECT col2, col3, col4, col5) AS list-cte ".
    "FROM my-table T1 CROSS JOIN my-table-2 T2 ".
    "SCALARS plus-two-scalar one-cte.col5 + 2 END ".
            "left-scalar IF T1.col5 = 1 OR T2.col5 = plus-two-scalar ".
                        "THEN T2.col3 ".
                        "ELSE T1.col3 ENDIF ".
    "WHERE T1.col5 <= T2.col5 AND T1.col3 = left-scalar ".
    "SELECT T1.col1, T2.col3"
  %:  run-scalar-joined-test
    query
    3
    :~  scalar-row-b-v
        scalar-row-b-w
        scalar-row-c-w
        ==
  ==
::
++  test-scalar-if-then-else-t-05
  =/  query
    "WITH (FROM my-table ".
          "WHERE col1 = 'B' ".
          "SELECT col2, col3, col4, col5) AS one-cte, ".
          "(FROM my-table ".
          "WHERE col1 IN ('A', 'B', 'C') ".
          "SELECT col2, col3, col4, col5) AS list-cte ".
    "FROM my-table T1 CROSS JOIN my-table-2 T2 ".
    "SCALARS plus-two-scalar one-cte.col5 + 2 END ".
            "left-scalar IF T1.col5 = 1 OR T2.col5 = plus-two-scalar ".
                        "THEN T2.col3 ".
                        "ELSE T1.col3 ENDIF ".
    "WHERE T1.col5 <= T2.col5 AND left-scalar IN list-cte.col3 ".
    "SELECT T1.col1, T2.col3"
  %:  run-scalar-joined-test
    query
    3
    :~  scalar-row-b-v
        scalar-row-b-w
        scalar-row-c-w
        ==
  ==
::
::  @da
++  test-scalar-if-then-else-da-00
  =/  query
    "WITH (FROM my-table ".
          "WHERE col1 = 'B' ".
          "SELECT col2, col3, col4, col5) AS one-cte, ".
          "(FROM my-table ".
          "WHERE col1 IN ('A', 'B', 'C') ".
          "SELECT col2, col3, col4, col5) AS list-cte ".
    "FROM my-table T1 CROSS JOIN my-table-2 T2 ".
    "SCALARS plus-two-scalar one-cte.col5 + 2 END ".
            "left-scalar IF T1.col5 = 1 OR T2.col5 = plus-two-scalar ".
                        "THEN T2.col4 ".
                        "ELSE T1.col4 ENDIF ".
            "right-scalar IF T1.col5 = one-cte.col5 OR T2.col5 = 3 ".
                         "THEN T1.col4 ".
                         "ELSE one-cte.col4 ENDIF ".
    "WHERE T1.col5 <= T2.col5 AND left-scalar = right-scalar ".
    "SELECT T1.col1, T2.col3"
  %:  run-scalar-joined-test
    query
    3
    :~  scalar-row-b-v
        scalar-row-b-w
        scalar-row-c-w
        ==
  ==
::
++  test-scalar-if-then-else-da-01
  =/  query
    "WITH (FROM my-table ".
          "WHERE col1 = 'B' ".
          "SELECT col2, col3, col4, col5) AS one-cte, ".
          "(FROM my-table ".
          "WHERE col1 IN ('A', 'B', 'C') ".
          "SELECT col2, col3, col4, col5) AS list-cte ".
    "FROM my-table T1 CROSS JOIN my-table-2 T2 ".
    "SCALARS plus-two-scalar one-cte.col5 + 2 END ".
            "left-scalar IF T1.col5 = 1 OR T2.col5 = plus-two-scalar ".
                        "THEN T2.col4 ".
                        "ELSE T1.col4 ENDIF ".
    "WHERE T1.col5 <= T2.col5 AND ~2024.1.7 = left-scalar ".
    "SELECT T1.col1, T2.col3"
  %:  run-scalar-joined-test
    query
    4
    :~  scalar-row-a-x
        scalar-row-b-x
        scalar-row-c-x
        scalar-row-d-x
        ==
  ==
::
++  test-scalar-if-then-else-da-02
  =/  query
    "WITH (FROM my-table ".
          "WHERE col1 = 'B' ".
          "SELECT col2, col3, col4, col5) AS one-cte, ".
          "(FROM my-table ".
          "WHERE col1 IN ('A', 'B', 'C') ".
          "SELECT col2, col3, col4, col5) AS list-cte ".
    "FROM my-table T1 CROSS JOIN my-table-2 T2 ".
    "SCALARS plus-two-scalar one-cte.col5 + 2 END ".
            "left-scalar IF T1.col5 = 1 OR T2.col5 = plus-two-scalar ".
                        "THEN T2.col4 ".
                        "ELSE T1.col4 ENDIF ".
    "WHERE T1.col5 <= T2.col5 AND left-scalar = ~2024.1.1 ".
    "SELECT T1.col1, T2.col3"
  %:  run-scalar-joined-test
    query
    1
    :~  scalar-row-a-u
        ==
  ==
::
++  test-scalar-if-then-else-da-03
  =/  query
    "WITH (FROM my-table ".
          "WHERE col1 = 'B' ".
          "SELECT col2, col3, col4, col5) AS one-cte, ".
          "(FROM my-table ".
          "WHERE col1 IN ('A', 'B', 'C') ".
          "SELECT col2, col3, col4, col5) AS list-cte ".
    "FROM my-table T1 CROSS JOIN my-table-2 T2 ".
    "SCALARS plus-two-scalar one-cte.col5 + 2 END ".
            "left-scalar IF T1.col5 = 1 OR T2.col5 = plus-two-scalar ".
                        "THEN T2.col4 ".
                        "ELSE T1.col4 ENDIF ".
    "WHERE T1.col5 <= T2.col5 AND left-scalar = T2.col4 ".
    "SELECT T1.col1, T2.col3"
  %:  run-scalar-joined-test
    query
    7
    :~  scalar-row-a-u
        scalar-row-a-v
        scalar-row-a-w
        scalar-row-a-x
        scalar-row-b-x
        scalar-row-c-x
        scalar-row-d-x
        ==
  ==
::
++  test-scalar-if-then-else-da-04
  =/  query
    "WITH (FROM my-table ".
          "WHERE col1 = 'B' ".
          "SELECT col2, col3, col4, col5) AS one-cte, ".
          "(FROM my-table ".
          "WHERE col1 IN ('A', 'B', 'C') ".
          "SELECT col2, col3, col4, col5) AS list-cte ".
    "FROM my-table T1 CROSS JOIN my-table-2 T2 ".
    "SCALARS plus-two-scalar one-cte.col5 + 2 END ".
            "left-scalar IF T1.col5 = 1 OR T2.col5 = plus-two-scalar ".
                        "THEN T2.col4 ".
                        "ELSE T1.col4 ENDIF ".
    "WHERE T1.col5 <= T2.col5 AND T1.col4 = left-scalar ".
    "SELECT T1.col1, T2.col3"
  %:  run-scalar-joined-test
    query
    3
    :~  scalar-row-b-v
        scalar-row-b-w
        scalar-row-c-w
        ==
  ==
::
++  test-scalar-if-then-else-da-05
  =/  query
    "WITH (FROM my-table ".
          "WHERE col1 = 'B' ".
          "SELECT col2, col3, col4, col5) AS one-cte, ".
          "(FROM my-table ".
          "WHERE col1 IN ('A', 'B', 'C') ".
          "SELECT col2, col3, col4, col5) AS list-cte ".
    "FROM my-table T1 CROSS JOIN my-table-2 T2 ".
    "SCALARS plus-two-scalar one-cte.col5 + 2 END ".
            "left-scalar IF T1.col5 = 1 OR T2.col5 = plus-two-scalar ".
                        "THEN T2.col4 ".
                        "ELSE T1.col4 ENDIF ".
    "WHERE T1.col5 <= T2.col5 AND left-scalar IN list-cte.col4 ".
    "SELECT T1.col1, T2.col3"
  %:  run-scalar-joined-test
    query
    3
    :~  scalar-row-b-v
        scalar-row-b-w
        scalar-row-c-w
        ==
  ==
::
::  fail WHERE <scalar-fn> = <column> types differ
++  test-fail-scalar-00
  %+  expect-fail-message
      'comparing scalar to column of different aura: %scalar-date type=~.da %col3 type=~.t'
      |.
      =/  pred
        [%eq (pred-leaf [%scalar-name %scalar-date]) (pred-leaf [%unqualified-column %col3 ~])]
      =/  gate
        %:  prepare-predicate  pred
                               pred-scalar-map-meta
                               pred-scalar-qualifier-lookup
                               *named-ctes
                               pred-scalar-resolved-scalars
                               ==
      !>((gate pred-scalar-row))
::
::  fail WHERE <scalar-fn> IN (list @ud) types differ
++  test-fail-scalar-01
  %+  expect-fail-message
      'type of IN list incorrect, should be ~.da'
      |.
      =/  pred
        [%in (pred-leaf [%scalar-name %scalar-date]) (pred-leaf [%value-literals %ud '5;7'])]
      =/  gate
        %:  prepare-predicate  pred
                               pred-scalar-map-meta
                               pred-scalar-qualifier-lookup
                               *named-ctes
                               pred-scalar-resolved-scalars
                               ==
      !>((gate pred-scalar-row))
--
