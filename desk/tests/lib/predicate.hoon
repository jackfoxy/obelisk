::  Demonstrate unit testing filtered queries on a Gall agent with %obelisk.
::
/+  *test-helpers
|%
::
++  create-mytable
  "CREATE TABLE db1..my-table ".
  "(col1 @t, col2 @da, col3 @t, col4 @t) ".
  "PRIMARY KEY (col1)"
++  create-joined-tables
  "CREATE TABLE db1..my-table ".
  "(col1 @t, col2 @da) ".
  "PRIMARY KEY (col1); ".
  "CREATE TABLE db1..my-table-2 ".
  "(col1 @t, col3 @t, col4 @t) ".
  "PRIMARY KEY (col1)"
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
          :~  [%message 'SELECT']
              :-  %result-set
                  :~  :-  %vector
                          :~  [%col1 [~.t 'Angel']]
                              [%col2 [~.da ~2001.9.19]]
                              [%col3 [~.t 'tuxedo']]
                              [%col4 [~.t 'row3']]
                              ==
                      ==
              [%server-time ~2012.5.3]
              [%message 'db1.dbo.my-table']
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
          :~  [%message 'SELECT']
              :-  %result-set
                  :~  :-  %vector
                          :~  [%col1 [~.t 'Angel']]
                              [%col2 [~.da ~2001.9.19]]
                              [%col3 [~.t 'tuxedo']]
                              [%col4 [~.t 'row3']]
                              ==
                      ==
              [%server-time ~2012.5.3]
              [%message 'db1.dbo.my-table']
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
          :~  [%message 'SELECT']
              :-  %result-set
                  :~  :-  %vector
                          :~  [%col1 [~.t 'Angel']]
                              [%col2 [~.da ~2001.9.19]]
                              [%col3 [~.t 'Angel']]
                              [%col4 [~.t 'row3']]
                              ==
                      ==
              [%server-time ~2012.5.3]
              [%message 'db1.dbo.my-table']
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
          :~  [%message 'SELECT']
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
              [%message 'db1.sys.columns']
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
          :~  [%message 'SELECT']
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
              [%message 'db1.sys.columns']
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
          :~  [%message 'SELECT']
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
              [%message 'db1.sys.columns']
              [%schema-time ~2012.5.1]
              [%data-time ~2012.5.1]
              [%vector-count 4]
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
            :~  [%message 'SELECT']
                :-  %result-set
                    :~  :-  %vector
                            :~  [%col1 [~.t 'Angel']]
                                [%col2 [~.da ~2001.9.19]]
                                [%col3 [~.t 'tuxedo']]
                                [%col4 [~.t 'row3']]
                                ==
                        ==
                [%server-time ~2012.5.3]
                [%message 'db1.dbo.my-table']
                [%schema-time ~2012.5.1]
                [%data-time ~2012.5.2]
                [%message 'db1.dbo.my-table-2']
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
            :~  [%message 'SELECT']
                :-  %result-set
                    :~  :-  %vector
                            :~  [%col1 [~.t 'Angel']]
                                [%col2 [~.da ~2001.9.19]]
                                [%col3 [~.t 'tuxedo']]
                                [%col4 [~.t 'row3']]
                                ==
                        ==
                [%server-time ~2012.5.3]
                [%message 'db1.dbo.my-table']
                [%schema-time ~2012.5.1]
                [%data-time ~2012.5.2]
                [%message 'db1.dbo.my-table-2']
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
          :~  [%message 'SELECT']
              :-  %result-set
                  :~  :-  %vector
                          :~  [%col1 [~.t 'Angel']]
                              [%col2 [~.da ~2001.9.19]]
                              [%col3 [~.t 'Angel']]
                              [%col4 [~.t 'row3']]
                              ==
                      ==
              [%server-time ~2012.5.3]
              [%message 'db1.dbo.my-table']
              [%schema-time ~2012.5.1]
              [%data-time ~2012.5.2]
              [%message 'db1.dbo.my-table-2']
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
  ::                  [%message 'SELECT']
  ::                  [%result-set expected-rows]
  ::                  [%server-time ~2012.5.3]
  ::                  [%message 'db1.sys.columns']
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
          :~  [%message 'SELECT']
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
              [%message 'db1.dbo.my-table']
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
          :~  [%message 'SELECT']
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
              [%message 'db1.dbo.my-table']
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
          :~  [%message 'SELECT']
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
              [%message 'db1.dbo.my-table']
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
          :~  [%message 'SELECT']
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
              [%message 'db1.sys.columns']
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
          :~  [%message 'SELECT']
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
              [%message 'db1.sys.columns']
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
          :~  [%message 'SELECT']
              [%result-set ~]
              [%server-time ~2012.5.3]
              [%message 'db1.sys.columns']
              [%schema-time ~2012.5.1]
              [%data-time ~2012.5.1]
              [%vector-count 0]
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
          :~  [%message 'SELECT']
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
              [%message 'db1.dbo.my-table']
              [%schema-time ~2012.5.1]
              [%data-time ~2012.5.2]
              [%message 'db1.dbo.my-table-2']
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
          :~  [%message 'SELECT']
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
              [%message 'db1.dbo.my-table']
              [%schema-time ~2012.5.1]
              [%data-time ~2012.5.2]
              [%message 'db1.dbo.my-table-2']
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
          :~  [%message 'SELECT']
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
              [%message 'db1.dbo.my-table']
              [%schema-time ~2012.5.1]
              [%data-time ~2012.5.2]
              [%message 'db1.dbo.my-table-2']
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
          :~  [%message 'SELECT']
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
              [%message 'db1.dbo.my-table']
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
          :~  [%message 'SELECT']
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
              [%message 'db1.dbo.my-table']
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
          :~  [%message 'SELECT']
              :-  %result-set
                  :~  :-  %vector
                          :~  [%col1 [~.t 'Ace']]
                              [%col2 [~.da ~2005.12.19]]
                              [%col3 [~.t 'ticolor']]
                              [%col4 [~.t 'row2']]
                              ==
                      ==
              [%server-time ~2012.5.3]
              [%message 'db1.dbo.my-table']
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
          :~  [%message 'SELECT']
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
              [%message 'db1.dbo.my-table']
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
          :~  [%message 'SELECT']
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
              [%message 'db1.dbo.my-table']
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
          :~  [%message 'SELECT']
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
              [%message 'db1.sys.columns']
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
          :~  [%message 'SELECT']
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
              [%message 'db1.sys.columns']
              [%schema-time ~2012.5.1]
              [%data-time ~2012.5.1]
              [%vector-count 4]
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
          :~  [%message 'SELECT']
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
              [%message 'db1.dbo.my-table']
              [%schema-time ~2012.5.1]
              [%data-time ~2012.5.2]
              [%message 'db1.dbo.my-table-2']
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
          :~  [%message 'SELECT']
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
              [%message 'db1.dbo.my-table']
              [%schema-time ~2012.5.1]
              [%data-time ~2012.5.2]
              [%message 'db1.dbo.my-table-2']
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
          :~  [%message 'SELECT']
              :-  %result-set
                  :~  :-  %vector
                          :~  [%col1 [~.t 'Ace']]
                              [%col2 [~.da ~2005.12.19]]
                              [%col3 [~.t 'ticolor']]
                              [%col4 [~.t 'row2']]
                              ==
                      ==
              [%server-time ~2012.5.3]
              [%message 'db1.dbo.my-table']
              [%schema-time ~2012.5.1]
              [%data-time ~2012.5.2]
              [%message 'db1.dbo.my-table-2']
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
          :~  [%message 'SELECT']
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
              [%message 'db1.dbo.my-table']
              [%schema-time ~2012.5.1]
              [%data-time ~2012.5.2]
              [%message 'db1.dbo.my-table-2']
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
          :~  [%message 'SELECT']
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
              [%message 'db1.dbo.my-table']
              [%schema-time ~2012.5.1]
              [%data-time ~2012.5.2]
              [%message 'db1.dbo.my-table-2']
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
          :~  [%message 'SELECT']
              :-  %result-set
                  :~  :-  %vector
                          :~  [%col1 [~.t 'Ace']]
                              [%col2 [~.da ~2005.12.19]]
                              [%col3 [~.t 'ticolor']]
                              [%col4 [~.t 'row2']]
                              ==
                      ==
              [%server-time ~2012.5.3]
              [%message 'db1.dbo.my-table']
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
          :~  [%message 'SELECT']
              :-  %result-set
                  :~  :-  %vector
                          :~  [%col1 [~.t 'Abby']]
                              [%col2 [~.da ~1999.2.19]]
                              [%col3 [~.t 'tricolor']]
                              [%col4 [~.t 'row1']]
                              ==
                      ==
              [%server-time ~2012.5.3]
              [%message 'db1.dbo.my-table']
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
          :~  [%message 'SELECT']
              :-  %result-set
                  :~  :-  %vector
                          :~  [%col1 [~.t 'Angel']]
                              [%col2 [~.da ~2001.9.19]]
                              [%col3 [~.t 'tuxedo']]
                              [%col4 [~.t 'row3']]
                              ==
                      ==
              [%server-time ~2012.5.3]
              [%message 'db1.dbo.my-table']
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
          :~  [%message 'SELECT']
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
              [%message 'db1.dbo.my-table']
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
          :~  [%message 'SELECT']
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
              [%message 'db1.dbo.my-table']
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
          :~  [%message 'SELECT']
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
              [%message 'db1.sys.columns']
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
          :~  [%message 'SELECT']
              [%result-set ~]
              [%server-time ~2012.5.3]
              [%message 'db1.sys.columns']
              [%schema-time ~2012.5.1]
              [%data-time ~2012.5.1]
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
          :~  [%message 'SELECT']
              :-  %result-set
                  :~  :-  %vector
                          :~  [%col1 [~.t 'Ace']]
                              [%col2 [~.da ~2005.12.19]]
                              [%col3 [~.t 'ticolor']]
                              [%col4 [~.t 'row2']]
                              ==
                      ==
              [%server-time ~2012.5.3]
              [%message 'db1.dbo.my-table']
              [%schema-time ~2012.5.1]
              [%data-time ~2012.5.2]
              [%message 'db1.dbo.my-table-2']
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
          :~  [%message 'SELECT']
              :-  %result-set
                  :~  :-  %vector
                          :~  [%col1 [~.t 'Abby']]
                              [%col2 [~.da ~1999.2.19]]
                              [%col3 [~.t 'tricolor']]
                              [%col4 [~.t 'row1']]
                              ==
                      ==
              [%server-time ~2012.5.3]
              [%message 'db1.dbo.my-table']
              [%schema-time ~2012.5.1]
              [%data-time ~2012.5.2]
              [%message 'db1.dbo.my-table-2']
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
          :~  [%message 'SELECT']
              :-  %result-set
                  :~  :-  %vector
                          :~  [%col1 [~.t 'Angel']]
                              [%col2 [~.da ~2001.9.19]]
                              [%col3 [~.t 'tuxedo']]
                              [%col4 [~.t 'row3']]
                              ==
                      ==
              [%server-time ~2012.5.3]
              [%message 'db1.dbo.my-table']
              [%schema-time ~2012.5.1]
              [%data-time ~2012.5.2]
              [%message 'db1.dbo.my-table-2']
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
          :~  [%message 'SELECT']
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
              [%message 'db1.dbo.my-table']
              [%schema-time ~2012.5.1]
              [%data-time ~2012.5.2]
              [%message 'db1.dbo.my-table-2']
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
          :~  [%message 'SELECT']
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
              [%message 'db1.dbo.my-table']
              [%schema-time ~2012.5.1]
              [%data-time ~2012.5.2]
              [%message 'db1.dbo.my-table-2']
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
          :~  [%message 'SELECT']
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
              [%message 'db1.dbo.my-table']
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
          :~  [%message 'SELECT']
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
              [%message 'db1.dbo.my-table']
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
          :~  [%message 'SELECT']
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
              [%message 'db1.dbo.my-table']
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
          :~  [%message 'SELECT']
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
              [%message 'db1.dbo.my-table']
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
          :~  [%message 'SELECT']
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
              [%message 'db1.dbo.my-table']
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
          :~  [%message 'SELECT']
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
              [%message 'db1.sys.columns']
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
          :~  [%message 'SELECT']
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
              [%message 'db1.sys.columns']
              [%schema-time ~2012.5.1]
              [%data-time ~2012.5.1]
              [%vector-count 4]
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
          :~  [%message 'SELECT']
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
              [%message 'db1.dbo.my-table']
              [%schema-time ~2012.5.1]
              [%data-time ~2012.5.2]
              [%message 'db1.dbo.my-table-2']
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
          :~  [%message 'SELECT']
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
              [%message 'db1.dbo.my-table']
              [%schema-time ~2012.5.1]
              [%data-time ~2012.5.2]
              [%message 'db1.dbo.my-table-2']
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
          :~  [%message 'SELECT']
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
              [%message 'db1.dbo.my-table']
              [%schema-time ~2012.5.1]
              [%data-time ~2012.5.2]
              [%message 'db1.dbo.my-table-2']
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
          :~  [%message 'SELECT']
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
              [%message 'db1.dbo.my-table']
              [%schema-time ~2012.5.1]
              [%data-time ~2012.5.2]
              [%message 'db1.dbo.my-table-2']
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
          :~  [%message 'SELECT']
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
              [%message 'db1.dbo.my-table']
              [%schema-time ~2012.5.1]
              [%data-time ~2012.5.2]
              [%message 'db1.dbo.my-table-2']
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
          :~  [%message 'SELECT']
              :-  %result-set
                  :~  :-  %vector
                          :~  [%col1 [~.t 'Ace']]
                              [%col2 [~.da ~2005.12.19]]
                              [%col3 [~.t 'ticolor']]
                              [%col4 [~.t 'row2']]
                              ==
                      ==
              [%server-time ~2012.5.3]
              [%message 'db1.dbo.my-table']
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
          :~  [%message 'SELECT']
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
              [%message 'db1.dbo.my-table']
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
          :~  [%message 'SELECT']
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
              [%message 'db1.dbo.my-table']
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
          :~  [%message 'SELECT']
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
              [%message 'db1.dbo.my-table']
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
          :~  [%message 'SELECT']
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
              [%message 'db1.dbo.my-table']
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
          :~  [%message 'SELECT']
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
              [%message 'db1.sys.columns']
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
          :~  [%message 'SELECT']
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
              [%message 'db1.sys.columns']
              [%schema-time ~2012.5.1]
              [%data-time ~2012.5.1]
              [%vector-count 4]
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
          :~  [%message 'SELECT']
              :-  %result-set
                  :~  :-  %vector
                          :~  [%col1 [~.t 'Ace']]
                              [%col2 [~.da ~2005.12.19]]
                              [%col3 [~.t 'ticolor']]
                              [%col4 [~.t 'row2']]
                              ==
                      ==
              [%server-time ~2012.5.3]
              [%message 'db1.dbo.my-table']
              [%schema-time ~2012.5.1]
              [%data-time ~2012.5.2]
              [%message 'db1.dbo.my-table-2']
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
          :~  [%message 'SELECT']
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
              [%message 'db1.dbo.my-table']
              [%schema-time ~2012.5.1]
              [%data-time ~2012.5.2]
              [%message 'db1.dbo.my-table-2']
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
          :~  [%message 'SELECT']
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
              [%message 'db1.dbo.my-table']
              [%schema-time ~2012.5.1]
              [%data-time ~2012.5.2]
              [%message 'db1.dbo.my-table-2']
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
          :~  [%message 'SELECT']
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
              [%message 'db1.dbo.my-table']
              [%schema-time ~2012.5.1]
              [%data-time ~2012.5.2]
              [%message 'db1.dbo.my-table-2']
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
          :~  [%message 'SELECT']
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
              [%message 'db1.dbo.my-table']
              [%schema-time ~2012.5.1]
              [%data-time ~2012.5.2]
              [%message 'db1.dbo.my-table-2']
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
          :~  [%message 'SELECT']
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
              [%message 'db1.dbo.my-table']
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
          :~  [%message 'SELECT']
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
              [%message 'db1.dbo.my-table']
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
          :~  [%message 'SELECT']
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
              [%message 'db1.dbo.my-table']
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
          :~  [%message 'SELECT']
              [%result-set ~]
              [%server-time ~2012.5.3]
              [%message 'db1.dbo.my-table']
              [%schema-time ~2012.5.1]
              [%data-time ~2012.5.2]
              [%vector-count 0]
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
          "type of IN list incorrect, should be p=~.t"
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
          "type of IN list incorrect, should be p=~.t"
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
          :~  [%message 'SELECT']
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
              [%message 'db1.dbo.my-table']
              [%schema-time ~2012.5.1]
              [%data-time ~2012.5.2]
              [%message 'db1.dbo.my-table-2']
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
          :~  [%message 'SELECT']
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
              [%message 'db1.dbo.my-table']
              [%schema-time ~2012.5.1]
              [%data-time ~2012.5.2]
              [%message 'db1.dbo.my-table-2']
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
          :~  [%message 'SELECT']
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
              [%message 'db1.dbo.my-table']
              [%schema-time ~2012.5.1]
              [%data-time ~2012.5.2]
              [%message 'db1.dbo.my-table-2']
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
            :~  [%message 'SELECT']
                [%result-set ~]
                [%server-time ~2012.5.3]
                [%message 'db1.dbo.my-table']
                [%schema-time ~2012.5.1]
                [%data-time ~2012.5.2]
                [%message 'db1.dbo.my-table-2']
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
          "type of IN list incorrect, should be p=~.t"
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
          "type of IN list incorrect, should be p=~.t"
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
          :~  [%message 'SELECT']
              :-  %result-set
                  :~  :-  %vector
                          :~  [%col1 [~.t 'Angel']]
                              [%col2 [~.da ~2001.9.19]]
                              [%col3 [~.t 'tuxedo']]
                              [%col4 [~.t 'row3']]
                              ==
                      ==
              [%server-time ~2012.5.3]
              [%message 'db1.dbo.my-table']
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
          :~  [%message 'SELECT']
              :-  %result-set
                  :~  :-  %vector
                          :~  [%col1 [~.t 'Ace']]
                              [%col2 [~.da ~2005.12.19]]
                              [%col3 [~.t 'ticolor']]
                              [%col4 [~.t 'row2']]
                              ==
                      ==
              [%server-time ~2012.5.3]
              [%message 'db1.dbo.my-table']
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
          :~  [%message 'SELECT']
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
              [%message 'db1.dbo.my-table']
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
          :~  [%message 'SELECT']
              [%result-set ~]
              [%server-time ~2012.5.3]
              [%message 'db1.dbo.my-table']
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
          "type of IN list incorrect, should be p=~.t"
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
          "type of IN list incorrect, should be p=~.t"
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
          :~  [%message 'SELECT']
              :-  %result-set
                  :~  :-  %vector
                          :~  [%col1 [~.t 'Angel']]
                              [%col2 [~.da ~2001.9.19]]
                              [%col3 [~.t 'tuxedo']]
                              [%col4 [~.t 'row3']]
                              ==
                      ==
              [%server-time ~2012.5.3]
              [%message 'db1.dbo.my-table']
              [%schema-time ~2012.5.1]
              [%data-time ~2012.5.2]
              [%message 'db1.dbo.my-table-2']
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
          :~  [%message 'SELECT']
              :-  %result-set
                  :~  :-  %vector
                          :~  [%col1 [~.t 'Ace']]
                              [%col2 [~.da ~2005.12.19]]
                              [%col3 [~.t 'ticolor']]
                              [%col4 [~.t 'row2']]
                              ==
                      ==
              [%server-time ~2012.5.3]
              [%message 'db1.dbo.my-table']
              [%schema-time ~2012.5.1]
              [%data-time ~2012.5.2]
              [%message 'db1.dbo.my-table-2']
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
          :~  [%message 'SELECT']
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
              [%message 'db1.dbo.my-table']
              [%schema-time ~2012.5.1]
              [%data-time ~2012.5.2]
              [%message 'db1.dbo.my-table-2']
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
          :~  [%message 'SELECT']
              [%result-set ~]
              [%server-time ~2012.5.3]
              [%message 'db1.dbo.my-table']
              [%schema-time ~2012.5.1]
              [%data-time ~2012.5.2]
              [%message 'db1.dbo.my-table-2']
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
          "type of IN list incorrect, should be p=~.t"
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
          "type of IN list incorrect, should be p=~.t"
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
          :~  [%message 'SELECT']
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
              [%message 'db1.dbo.my-table']
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
          :~  [%message 'SELECT']
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
              [%message 'db1.dbo.my-table']
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
          :~  [%message 'SELECT']
              :-  %result-set
                  :~  :-  %vector
                          :~  [%col1 [~.t 'Angel']]
                              [%col2 [~.da ~2001.9.19]]
                              [%col3 [~.t 'Angel']]
                              [%col4 [~.t 'row3']]
                              ==
                      ==
              [%server-time ~2012.5.3]
              [%message 'db1.dbo.my-table']
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
          :~  [%message 'SELECT']
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
              [%message 'db1.sys.columns']
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
          :~  [%message 'SELECT']
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
              [%message 'db1.dbo.my-table']
              [%schema-time ~2012.5.1]
              [%data-time ~2012.5.2]
              [%message 'db1.dbo.my-table-2']
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
          :~  [%message 'SELECT']
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
              [%message 'db1.dbo.my-table']
              [%schema-time ~2012.5.1]
              [%data-time ~2012.5.2]
              [%message 'db1.dbo.my-table-2']
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
          :~  [%message 'SELECT']
              :-  %result-set
                  :~  :-  %vector
                          :~  [%col1 [~.t 'Angel']]
                              [%col2 [~.da ~2001.9.19]]
                              [%col3 [~.t 'Angel']]
                              [%col4 [~.t 'row3']]
                              ==
                      ==
              [%server-time ~2012.5.3]
              [%message 'db1.dbo.my-table']
              [%schema-time ~2012.5.1]
              [%data-time ~2012.5.2]
              [%message 'db1.dbo.my-table-2']
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
          :~  [%message 'SELECT']
              :-  %result-set
                  :~  :-  %vector
                          :~  [%col1 [~.t 'Angel']]
                              [%col2 [~.da ~2001.9.19]]
                              [%col3 [~.t 'tuxedo']]
                              [%col4 [~.t 'row3']]
                              ==
                      ==
              [%server-time ~2012.5.3]
              [%message 'db1.dbo.my-table']
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
          :~  [%message 'SELECT']
              [%result-set ~]
              [%server-time ~2012.5.3]
              [%message 'db1.dbo.my-table']
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
          :~  [%message 'SELECT']
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
              [%message 'db1.dbo.my-table']
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
          :~  [%message 'SELECT']
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
              [%message 'db1.sys.columns']
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
          :~  [%message 'SELECT']
              :-  %result-set
                  :~  :-  %vector
                          :~  [%col1 [~.t 'Angel']]
                              [%col2 [~.da ~2001.9.19]]
                              [%col3 [~.t 'tuxedo']]
                              [%col4 [~.t 'row3']]
                              ==
                      ==
              [%server-time ~2012.5.3]
              [%message 'db1.dbo.my-table']
              [%schema-time ~2012.5.1]
              [%data-time ~2012.5.2]
              [%message 'db1.dbo.my-table-2']
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
          :~  [%message 'SELECT']
              [%result-set ~]
              [%server-time ~2012.5.3]
              [%message 'db1.dbo.my-table']
              [%schema-time ~2012.5.1]
              [%data-time ~2012.5.2]
              [%message 'db1.dbo.my-table-2']
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
          :~  [%message 'SELECT']
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
              [%message 'db1.dbo.my-table']
              [%schema-time ~2012.5.1]
              [%data-time ~2012.5.2]
              [%message 'db1.dbo.my-table-2']
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
          :~  [%message 'SELECT']
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
              [%message 'db1.dbo.my-table']
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
          :~  [%message 'SELECT']
              :-  %result-set
                  :~  :-  %vector
                          :~  [%col1 [~.t 'Angel']]
                              [%col2 [~.da ~2001.9.19]]
                              [%col3 [~.t 'Angel']]
                              [%col4 [~.t 'row3']]
                              ==
                      ==
              [%server-time ~2012.5.3]
              [%message 'db1.dbo.my-table']
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
          :~  [%message 'SELECT']
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
              [%message 'db1.dbo.my-table']
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
          :~  [%message 'SELECT']
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
              [%message 'db1.dbo.my-table']
              [%schema-time ~2012.5.1]
              [%data-time ~2012.5.2]
              [%message 'db1.dbo.my-table-2']
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
          :~  [%message 'SELECT']
              :-  %result-set
                  :~  :-  %vector
                          :~  [%col1 [~.t 'Angel']]
                              [%col2 [~.da ~2001.9.19]]
                              [%col3 [~.t 'Angel']]
                              [%col4 [~.t 'row3']]
                              ==
                      ==
              [%server-time ~2012.5.3]
              [%message 'db1.dbo.my-table']
              [%schema-time ~2012.5.1]
              [%data-time ~2012.5.2]
              [%message 'db1.dbo.my-table-2']
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
          :~  [%message 'SELECT']
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
              [%message 'db1.dbo.my-table']
              [%schema-time ~2012.5.1]
              [%data-time ~2012.5.2]
              [%message 'db1.dbo.my-table-2']
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
          :~  [%message 'SELECT']
              :-  %result-set
                  :~  :-  %vector
                          :~  [%col1 [~.t 'Ace']]
                              [%col2 [~.da ~2005.12.19]]
                              [%col3 [~.t 'ticolor']]
                              [%col4 [~.t 'row2']]
                              ==
                      ==
              [%server-time ~2012.5.3]
              [%message 'db1.dbo.my-table']
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
          :~  [%message 'SELECT']
              :-  %result-set
                  :~  :-  %vector
                          :~  [%col1 [~.t 'Angel']]
                              [%col2 [~.da ~2001.9.19]]
                              [%col3 [~.t 'Angel']]
                              [%col4 [~.t 'row3']]
                              ==
                      ==
              [%server-time ~2012.5.3]
              [%message 'db1.dbo.my-table']
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
          :~  [%message 'SELECT']
              :-  %result-set
                  :~  :-  %vector
                          :~  [%col1 [~.t 'Ace']]
                              [%col2 [~.da ~2005.12.19]]
                              [%col3 [~.t 'ticolor']]
                              [%col4 [~.t 'row2']]
                              ==
                      ==
              [%server-time ~2012.5.3]
              [%message 'db1.dbo.my-table']
              [%schema-time ~2012.5.1]
              [%data-time ~2012.5.2]
              [%message 'db1.dbo.my-table-2']
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
            :~  [%message 'SELECT']
                :-  %result-set
                    :~  :-  %vector
                            :~  [%col1 [~.t 'Angel']]
                                [%col2 [~.da ~2001.9.19]]
                                [%col3 [~.t 'Angel']]
                                [%col4 [~.t 'row3']]
                                ==
                        ==
                [%server-time ~2012.5.3]
                [%message 'db1.dbo.my-table']
                [%schema-time ~2012.5.1]
                [%data-time ~2012.5.2]
                [%message 'db1.dbo.my-table-2']
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
          :~  [%message 'SELECT']
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
              [%message 'db1.dbo.my-table']
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
          :~  [%message 'SELECT']
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
              [%message 'db1.dbo.my-table']
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
          :~  [%message 'SELECT']
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
              [%message 'db1.dbo.my-table']
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
          :~  [%message 'SELECT']
              :-  %result-set
                  :~  :-  %vector
                          :~  [%col1 [~.t 'Abby']]
                              [%col2 [~.da ~1999.2.19]]
                              [%col3 [~.t 'tricolor']]
                              [%col4 [~.t 'row1']]
                              ==
                      ==
              [%server-time ~2012.5.3]
              [%message 'db1.dbo.my-table']
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
          :~  [%message 'SELECT']
              [%result-set ~]
              [%server-time ~2012.5.3]
              [%message 'db1.sys.columns']
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
          :~  [%message 'SELECT']
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
              [%message 'db1.dbo.my-table']
              [%schema-time ~2012.5.1]
              [%data-time ~2012.5.2]
              [%message 'db1.dbo.my-table-2']
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
          :~  [%message 'SELECT']
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
              [%message 'db1.dbo.my-table']
              [%schema-time ~2012.5.1]
              [%data-time ~2012.5.2]
              [%message 'db1.dbo.my-table-2']
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
          :~  [%message 'SELECT']
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
              [%message 'db1.dbo.my-table']
              [%schema-time ~2012.5.1]
              [%data-time ~2012.5.2]
              [%message 'db1.dbo.my-table-2']
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
          :~  [%message 'SELECT']
              :-  %result-set
                  :~  :-  %vector
                          :~  [%col1 [~.t 'Abby']]
                              [%col2 [~.da ~1999.2.19]]
                              [%col3 [~.t 'tricolor']]
                              [%col4 [~.t 'row1']]
                              ==
                      ==
              [%server-time ~2012.5.3]
              [%message 'db1.dbo.my-table']
              [%schema-time ~2012.5.1]
              [%data-time ~2012.5.2]
              [%message 'db1.dbo.my-table-2']
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
::++  test-qualified-01
::  =|  run=@ud
::  =/  expected-rows
::        :~
::          :-  %vector
::              :~  [%col1 [~.t 'Ace']]
::                  [%col2 [~.da ~2005.12.19]]
::                  [%col3 [~.t 'ticolor']]
::                  [%col4 [~.t 'row2']]
::                  ==
::          :-  %vector
::              :~  [%col1 [~.t 'Abby']]
::                  [%col2 [~.da ~1999.2.19]]
::                  [%col3 [~.t 'tricolor']]
::                  [%col4 [~.t 'row1']]
::                  ==
::          ==
::  =/  expected  :~  %results
::                    [%message 'SELECT']
::                    [%result-set expected-rows]
::                    [%server-time ~2012.5.3]
::                    [%message 'db1.dbo.my-table']
::                    [%schema-time ~2012.5.1]
::                    [%data-time ~2012.5.2]
::                    [%vector-count 2]
::                ==
::  =^  mov1  agent
::    %+  ~(on-poke agent (bowl [run ~2012.4.30]))
::        %obelisk-action
::        !>([%tape2 %sys "CREATE DATABASE db1"])
::  =.  run  +(run)
::  =^  mov2  agent
::    %+  ~(on-poke agent (bowl [run ~2012.5.1]))
::        %obelisk-action
::        !>  :+  %tape2
::                %db1
::                create-mytable
::  =.  run  +(run)
::  =^  mov3  agent
::    %+  ~(on-poke agent (bowl [run ~2012.5.2]))
::        %obelisk-action
::        !>  :+  %tape2
::                %db1
::                "INSERT INTO my-table".
::                " VALUES".
::                " ('Abby', ~1999.2.19, 'tricolor', 'row1')".
::                " ('Ace', ~2005.12.19, 'ticolor', 'row2')".
::                " ('Angel', ~2001.9.19, 'tuxedo', 'row3')"
::  =.  run  +(run)
::  =^  mov4  agent
::    %+  ~(on-poke agent (bowl [run ~2012.5.3]))
::        %obelisk-action
::        !>  :+  %tape2
::                %db1
::                "FROM my-table T1".
::                "WHERE (t1.col3 = 'ticolor' AND col4='row2') ".
::                "OR (col3='tricolor' AND T1.col4='row1') SELECT *"
::  ::
::  (eval-results expected ;;(cmd-result ->+>+>+<.mov4))
--
