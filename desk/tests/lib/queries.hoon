::  Demonstrate unit testing queries on a Gall agent with %obelisk.
::
/+  *test-helpers
|%
::
::  * (select all)
++  test-simple-query-01
  =|  run=@ud
  %-  exec-2-1
  :*  run
      [~2012.4.30 %sys "CREATE DATABASE db1"]
      ::
      :+  ~2012.5.1
          %db1
          "CREATE TABLE db1..my-table ".
          "(col1 @t, col2 @da, col3 @t, col4 @t) ".
          "PRIMARY KEY (col1)"
      ::
      :+  ~2012.5.2
          %db1
          "INSERT INTO my-table".
          " VALUES".
          " ('Abby', ~1999.2.19, 'tricolor', 'row1')".
          " ('Ace', ~2005.12.19, 'ticolor', 'row2')".
          " ('Angel', ~2001.9.19, 'tuxedo', 'row3')"
      ::
      [~2012.5.3 %db1 "FROM my-table SELECT *"]
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
::  *, *
++  test-simple-query-02
  =|  run=@ud
  %-  exec-2-1
  :*  run
      [~2012.4.30 %sys "CREATE DATABASE db1"]
      ::
      :+  ~2012.5.1
          %db1
          "CREATE TABLE db1..my-table ".
          "(col1 @t, col2 @da, col3 @t, col4 @t) ".
          "PRIMARY KEY (col1)"
      ::
      :+  ~2012.5.2
          %db1
          "INSERT INTO my-table".
          " VALUES".
          " ('Abby', ~1999.2.19, 'tricolor', 'row1')".
          " ('Ace', ~2005.12.19, 'ticolor', 'row2')".
          " ('Angel', ~2001.9.19, 'tuxedo', 'row3')"
      ::
      [~2012.5.3 %db1 "FROM my-table SELECT *, *"]
      ::
      :-  %results
          :~  [%action 'SELECT']
              :-  %result-set
                  :~  :-  %vector
                          :~  [%col1 [~.t 'Angel']]
                              [%col2 [~.da ~2001.9.19]]
                              [%col3 [~.t 'tuxedo']]
                              [%col4 [~.t 'row3']]
                              [%col1 [~.t 'Angel']]
                              [%col2 [~.da ~2001.9.19]]
                              [%col3 [~.t 'tuxedo']]
                              [%col4 [~.t 'row3']]
                              ==
                      :-  %vector
                          :~  [%col1 [~.t 'Ace']]
                              [%col2 [~.da ~2005.12.19]]
                              [%col3 [~.t 'ticolor']]
                              [%col4 [~.t 'row2']]
                              [%col1 [~.t 'Ace']]
                              [%col2 [~.da ~2005.12.19]]
                              [%col3 [~.t 'ticolor']]
                              [%col4 [~.t 'row2']]
                              ==
                      :-  %vector
                          :~  [%col1 [~.t 'Abby']]
                              [%col2 [~.da ~1999.2.19]]
                              [%col3 [~.t 'tricolor']]
                              [%col4 [~.t 'row1']]
                              [%col1 [~.t 'Abby']]
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
::  table-name.*
++  test-simple-query-03
  =|  run=@ud
  %-  exec-2-1
  :*  run
      [~2012.4.30 %sys "CREATE DATABASE db1"]
      ::
      :+  ~2012.5.1
          %db1
          "CREATE TABLE db1..my-table ".
          "(col1 @t, col2 @da, col3 @t, col4 @t) ".
          "PRIMARY KEY (col1)"
      ::
      :+  ~2012.5.2
          %db1
          "INSERT INTO my-table".
          " VALUES".
          " ('Abby', ~1999.2.19, 'tricolor', 'row1')".
          " ('Ace', ~2005.12.19, 'ticolor', 'row2')".
          " ('Angel', ~2001.9.19, 'tuxedo', 'row3')"
      ::
      [~2012.5.3 %db1 "FROM my-table SELECT my-table.*"]
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
::  table-alias.*
++  test-simple-query-04
  =|  run=@ud
  %-  exec-2-1
  ::%-  debug-2-1
    :*  run
        [~2012.4.30 %sys "CREATE DATABASE db1"]
        ::
        :+  ~2012.5.1
            %db1
            "CREATE TABLE db1..my-table ".
            "(col1 @t, col2 @da, col3 @t, col4 @t) ".
            "PRIMARY KEY (col1)"
        ::
        :+  ~2012.5.2
            %db1
            "INSERT INTO my-table".
            " VALUES".
            " ('Abby', ~1999.2.19, 'tricolor', 'row1')".
            " ('Ace', ~2005.12.19, 'ticolor', 'row2')".
            " ('Angel', ~2001.9.19, 'tuxedo', 'row3')"
        ::
        [~2012.5.3 %db1 "FROM my-table T1 SELECT T1.*"]
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
::  *, *
++  test-simple-query-05
  =|  run=@ud
  %-  exec-2-1
  :*  run
      [~2012.4.30 %sys "CREATE DATABASE db1"]
      ::
      :+  ~2012.5.1
          %db1
          "CREATE TABLE db1..my-table ".
          "(col1 @t, col2 @da, col3 @t, col4 @t) ".
          "PRIMARY KEY (col1)"
      ::
      :+  ~2012.5.2
          %db1
          "INSERT INTO my-table".
          " VALUES".
          " ('Abby', ~1999.2.19, 'tricolor', 'row1')".
          " ('Ace', ~2005.12.19, 'ticolor', 'row2')".
          " ('Angel', ~2001.9.19, 'tuxedo', 'row3')"
      ::
      [~2012.5.3 %db1 "FROM my-table SELECT col1,col2,col3,col4"]
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
::  all column aliases
++  test-simple-query-06
  =|  run=@ud
  %-  exec-2-1
  :*  run
      [~2012.4.30 %sys "CREATE DATABASE db1"]
      ::
      :+  ~2012.5.1
          %db1
          "CREATE TABLE db1..my-table ".
          "(col1 @t, col2 @da, col3 @t, col4 @t) ".
          "PRIMARY KEY (col1)"
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
          "FROM my-table SELECT col1 as c1,col2 as c2,col3 as c3,col4 as c4"
      ::
      :-  %results
          :~  [%action 'SELECT']
              :-  %result-set
                  :~  :-  %vector
                          :~  [%c1 [~.t 'Ace']]
                              [%c2 [~.da ~2005.12.19]]
                              [%c3 [~.t 'ticolor']]
                              [%c4 [~.t 'row2']]
                              ==
                      :-  %vector
                          :~  [%c1 [~.t 'Angel']]
                              [%c2 [~.da ~2001.9.19]]
                              [%c3 [~.t 'tuxedo']]
                              [%c4 [~.t 'row3']]
                              ==
                      :-  %vector
                          :~  [%c1 [~.t 'Abby']]
                              [%c2 [~.da ~1999.2.19]]
                              [%c3 [~.t 'tricolor']]
                              [%c4 [~.t 'row1']]
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
::  all literals
++  test-simple-query-07
  =|  run=@ud
  =/  select  "SELECT 'cor,d', ~nomryg-nilref, ~2020.12.25..7.15.0..1ef5, ".
              "2020.12.25..7.15.0..1ef5, ~d71.h19.m26.s24..9d55, ".
              ".195.198.143.90, .0.0.0.0.0.1c.c3c6.8f5a, Y, N, 2.222, 2222, ".
              "195.198.143.900, .3.14, .-3.14, .~3.14, .~-3.14, 0x12.6401, ".
              "10.1011, -20, --20, 'cor\\'d'"
  %-  exec-0-1
  :*  run
      [~2012.4.30 %sys "CREATE DATABASE db1"]
      ::
      [~2012.5.3 %sys select]
      ::
      :-  %results
          :~  [%action 'SELECT']
              :-  %result-set
                  :~  :-  %vector
                          :~  [%literal-0 [~.t 430.242.426.723]]
                              [%literal-1 [~.p 28.242.037]]
                              :-  %literal-2
                                  [~.da 170.141.184.504.830.774.788.415.618.594.688.204.800]
                              :-  %literal-3
                                  [~.da 170.141.184.504.830.774.788.415.618.594.688.204.800]
                              [%literal-4 [~.dr 114.450.695.119.985.999.668.576.256]]
                              [%literal-5 [~.if 3.284.569.946]]
                              [%literal-6 [~.is 123.543.654.234]]
                              [%literal-7 [~.f 0]]
                              [%literal-8 [~.f 1]]
                              [%literal-9 [~.ud 2.222]]
                              [%literal-10 [~.ud 2.222]]
                              [%literal-11 [~.ud 195.198.143.900]]
                              [%literal-12 [~.rs 1.078.523.331]]
                              [%literal-13 [~.rs 3.226.006.979]]
                              [%literal-14 [~.rd 4.614.253.070.214.989.087]]
                              [%literal-15 [~.rd 13.837.625.107.069.764.895]]
                              [%literal-16 [~.ux 1.205.249]]
                              [%literal-17 [~.ub 43]]
                              [%literal-18 [~.sd 39]]
                              [%literal-19 [~.sd 40]]
                              [%literal-20 [~.t 430.158.540.643]]
                              ==
                      ==
              [%server-time ~2012.5.3]
              [%schema-time ~2012.4.30]
              [%data-time ~2012.4.30]
              [%vector-count 1]
              ==
      ==
::
::  all literals, aliased
++  test-simple-query-08
  =|  run=@ud
  =/  select  "SELECT 'cor,d' as cord1, ~nomryg-nilref AS Ship, ".
              "~2020.12.25..7.15.0..1ef5 as date1, ".
              "2020.12.25..7.15.0..1ef5 as date2, ".
              "~d71.h19.m26.s24..9d55 as timespan, .195.198.143.90 as ip, ".
              ".0.0.0.0.0.1c.c3c6.8f5a as ipfv6, Y as true, N as false, ".
              "2.222 as undec1, 2222 as undec2, 195.198.143.900 as undec3, ".
              ".3.14 as float32-1, .-3.14 as float32-2, .~3.14 as float64-1, ".
              ".~-3.14 as float64-2, 0x12.6401 AS UNHEX, 10.1011 as unbinary, ".
              "-20 as signdec1, --20 as signdec2, 'cor\\'d' AS CORD2"
  %-  exec-0-1
  :*  run
      [~2012.4.30 %sys "CREATE DATABASE db1"]
      ::
      [~2012.5.3 %sys select]
      ::
      :-  %results
          :~  [%action 'SELECT']
              :-  %result-set
                  :~  :-  %vector
                          :~  [%cord1 [~.t 430.242.426.723]]
                              [%ship [~.p 28.242.037]]
                              :-  %date1
                                  [~.da 170.141.184.504.830.774.788.415.618.594.688.204.800]
                              :-  %date2
                                  [~.da 170.141.184.504.830.774.788.415.618.594.688.204.800]
                              [%timespan [~.dr 114.450.695.119.985.999.668.576.256]]
                              [%ip [~.if 3.284.569.946]]
                              [%ipfv6 [~.is 123.543.654.234]]
                              [%true [~.f 0]]
                              [%false [~.f 1]]
                              [%undec1 [~.ud 2.222]]
                              [%undec2 [~.ud 2.222]]
                              [%undec3 [~.ud 195.198.143.900]]
                              [%float32-1 [~.rs 1.078.523.331]]
                              [%float32-2 [~.rs 3.226.006.979]]
                              [%float64-1 [~.rd 4.614.253.070.214.989.087]]
                              [%float64-2 [~.rd 13.837.625.107.069.764.895]]
                              [%unhex [~.ux 1.205.249]]
                              [%unbinary [~.ub 43]]
                              [%signdec1 [~.sd 39]]
                              [%signdec2 [~.sd 40]]
                              [%cord2 [~.t 430.158.540.643]]
                              ==
                      ==
              [%server-time ~2012.5.3]
              [%schema-time ~2012.4.30]
              [%data-time ~2012.4.30]
              [%vector-count 1]
              ==
      ==
::
::  interspersed literals, aliased and unaliased
++  test-simple-query-09
  =|  run=@ud
  %-  exec-2-1
  :*  run
      [~2012.4.30 %sys "CREATE DATABASE db1"]
      ::
      :+  ~2012.5.1
          %db1
          "CREATE TABLE db1..my-table ".
          "(col1 @t, col2 @da, col3 @t, col4 @t) ".
          "PRIMARY KEY (col1)"
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
          "SELECT 'cor\\'d' AS cord, col1 as C1, ~nomryg-nilref, col2, ".
                 ".-3.14 as pi, col3, col4, ~2023.12.25"
      ::
      :-  %results
          :~  [%action 'SELECT']
              :-  %result-set
                  :~  :-  %vector
                          :~  [%cord [~.t 430.158.540.643]]
                              [%c1 [~.t 'Ace']]
                              [%literal-2 [~.p ~nomryg-nilref]]
                              [%col2 [~.da ~2005.12.19]]
                              [%pi [~.rs 3.226.006.979]]
                              [%col3 [~.t 'ticolor']]
                              [%col4 [~.t 'row2']]
                              [%literal-7 [~.da ~2023.12.25]]
                              ==
                      :-  %vector
                          :~  [%cord [~.t 430.158.540.643]]
                              [%c1 [~.t 'Angel']]
                              [%literal-2 [~.p ~nomryg-nilref]]
                              [%col2 [~.da ~2001.9.19]]
                              [%pi [~.rs 3.226.006.979]]
                              [%col3 [~.t 'tuxedo']]
                              [%col4 [~.t 'row3']]
                              [%literal-7 [~.da ~2023.12.25]]
                              ==
                      :-  %vector
                          :~  [%cord [~.t 430.158.540.643]]
                              [%c1 [~.t 'Abby']]
                              [%literal-2 [~.p ~nomryg-nilref]]
                              [%col2 [~.da ~1999.2.19]]
                              [%pi [~.rs 3.226.006.979]]
                              [%col3 [~.t 'tricolor']]
                              [%col4 [~.t 'row1']]
                              [%literal-7 [~.da ~2023.12.25]]
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
::  all column names, reversed
++  test-simple-query-10
  =|  run=@ud
  %-  exec-2-1
  :*  run
      [~2012.4.30 %sys "CREATE DATABASE db1"]
      ::
      :+  ~2012.5.1
          %db1
          "CREATE TABLE db1..my-table ".
          "(col1 @t, col2 @da, col3 @t, col4 @t) ".
          "PRIMARY KEY (col1)"
      ::
      :+  ~2012.5.2
          %db1
          "INSERT INTO my-table".
          " VALUES".
          " ('Abby', ~1999.2.19, 'tricolor', 'row1')".
          " ('Ace', ~2005.12.19, 'ticolor', 'row2')".
          " ('Angel', ~2001.9.19, 'tuxedo', 'row3')"
      ::
      [~2012.5.3 %db1 "FROM my-table SELECT col4,col3,col2,col1"]
      ::
      :-  %results
          :~  [%action 'SELECT']
              :-  %result-set
                  :~  :-  %vector
                          :~  [%col4 [~.t 'row3']]
                              [%col3 [~.t 'tuxedo']]
                              [%col2 [~.da ~2001.9.19]]
                              [%col1 [~.t 'Angel']]
                              ==
                      :-  %vector
                          :~  [%col4 [~.t 'row1']]
                              [%col3 [~.t 'tricolor']]
                              [%col2 [~.da ~1999.2.19]]
                              [%col1 [~.t 'Abby']]
                              ==
                      :-  %vector
                          :~  [%col4 [~.t 'row2']]
                              [%col3 [~.t 'ticolor']]
                              [%col2 [~.da ~2005.12.19]]
                              [%col1 [~.t 'Ace']]
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
::  all column aliases (mixed case), reversed
++  test-simple-query-11
  =|  run=@ud
  %-  exec-2-1
  :*  run
      [~2012.4.30 %sys "CREATE DATABASE db1"]
      ::
      :+  ~2012.5.1
          %db1
          "CREATE TABLE db1..my-table ".
          "(col1 @t, col2 @da, col3 @t, col4 @t) ".
          "PRIMARY KEY (col1)"
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
          "FROM my-table SELECT col4 as c4,col3 as C3,col2 as c2,col1 as c1"
      ::
      :-  %results
          :~  [%action 'SELECT']
              :-  %result-set
                  :~  :-  %vector
                          :~  [%c4 [~.t 'row3']]
                              [%c3 [~.t 'tuxedo']]
                              [%c2 [~.da ~2001.9.19]]
                              [%c1 [~.t 'Angel']]
                              ==
                      :-  %vector
                          :~  [%c4 [~.t 'row1']]
                              [%c3 [~.t 'tricolor']]
                              [%c2 [~.da ~1999.2.19]]
                              [%c1 [~.t 'Abby']]
                              ==
                      :-  %vector
                          :~  [%c4 [~.t 'row2']]
                              [%c3 [~.t 'ticolor']]
                              [%c2 [~.da ~2005.12.19]]
                              [%c1 [~.t 'Ace']]
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
::  all column names, with table prefix
++  test-simple-query-12
  =|  run=@ud
  %-  exec-2-1
  :*  run
      [~2012.4.30 %sys "CREATE DATABASE db1"]
      ::
      :+  ~2012.5.1
          %db1
          "CREATE TABLE db1..my-table ".
          "(col1 @t, col2 @da, col3 @t, col4 @t) ".
          "PRIMARY KEY (col1)"
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
          "FROM my-table ".
          "SELECT my-table.col1,my-table.col2,my-table.col3,my-table.col4"
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
                      :-  %vector
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
              [%vector-count 3]
              ==
      ==
::
::  all column names, with table alias
++  test-simple-query-13
  =|  run=@ud
  %-  exec-2-1
  :*  run
      [~2012.4.30 %sys "CREATE DATABASE db1"]
      ::
      :+  ~2012.5.1
          %db1
          "CREATE TABLE db1..my-table ".
          "(col1 @t, col2 @da, col3 @t, col4 @t) ".
          "PRIMARY KEY (col1)"
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
          "FROM my-table T1 SELECT T1.col1,T1.col2,T1.col3,T1.col4"
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
::  all column names, with table prefix, reversed
++  test-simple-query-14
  =|  run=@ud
  %-  exec-2-1
  :*  run
      [~2012.4.30 %sys "CREATE DATABASE db1"]
      ::
      :+  ~2012.5.1
          %db1
          "CREATE TABLE db1..my-table ".
          "(col1 @t, col2 @da, col3 @t, col4 @t) ".
          "PRIMARY KEY (col1)"
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
          "FROM my-table ".
          "SELECT my-table.col4,my-table.col3,my-table.col2,my-table.col1"
      ::
      :-  %results
          :~  [%action 'SELECT']
              :-  %result-set
                  :~  :-  %vector
                          :~  [%col4 [~.t 'row3']]
                              [%col3 [~.t 'tuxedo']]
                              [%col2 [~.da ~2001.9.19]]
                              [%col1 [~.t 'Angel']]
                              ==
                      :-  %vector
                          :~  [%col4 [~.t 'row1']]
                              [%col3 [~.t 'tricolor']]
                              [%col2 [~.da ~1999.2.19]]
                              [%col1 [~.t 'Abby']]
                              ==
                      :-  %vector
                          :~  [%col4 [~.t 'row2']]
                              [%col3 [~.t 'ticolor']]
                              [%col2 [~.da ~2005.12.19]]
                              [%col1 [~.t 'Ace']]
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
::  all column names, with table alias, reversed
++  test-simple-query-15
  =|  run=@ud
  %-  exec-2-1
  :*  run
      [~2012.4.30 %sys "CREATE DATABASE db1"]
      ::
      :+  ~2012.5.1
          %db1
          "CREATE TABLE db1..my-table ".
          "(col1 @t, col2 @da, col3 @t, col4 @t) ".
          "PRIMARY KEY (col1)"
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
          "FROM my-table T1 SELECT T1.col4,T1.col3,T1.col2,T1.col1"
      ::
      :-  %results
          :~  [%action 'SELECT']
              :-  %result-set
                  :~  :-  %vector
                          :~  [%col4 [~.t 'row3']]
                              [%col3 [~.t 'tuxedo']]
                              [%col2 [~.da ~2001.9.19]]
                              [%col1 [~.t 'Angel']]
                              ==
                      :-  %vector
                          :~  [%col4 [~.t 'row1']]
                              [%col3 [~.t 'tricolor']]
                              [%col2 [~.da ~1999.2.19]]
                              [%col1 [~.t 'Abby']]
                              ==
                      :-  %vector
                          :~  [%col4 [~.t 'row2']]
                              [%col3 [~.t 'ticolor']]
                              [%col2 [~.da ~2005.12.19]]
                              [%col1 [~.t 'Ace']]
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
::  one column name, *
++  test-simple-query-16
  =|  run=@ud
  %-  exec-2-1
  :*  run
      [~2012.4.30 %sys "CREATE DATABASE db1"]
      ::
      :+  ~2012.5.1
          %db1
          "CREATE TABLE db1..my-table ".
          "(col1 @t, col2 @da, col3 @t, col4 @t) ".
          "PRIMARY KEY (col1)"
      ::
      :+  ~2012.5.2
          %db1
          "INSERT INTO my-table".
          " VALUES".
          " ('Abby', ~1999.2.19, 'tricolor', 'row1')".
          " ('Ace', ~2005.12.19, 'ticolor', 'row2')".
          " ('Angel', ~2001.9.19, 'tuxedo', 'row3')"
      ::
      [~2012.5.3 %db1 "FROM my-table SELECT col3,*"]
      ::
      :-  %results
          :~  [%action 'SELECT']
              :-  %result-set
                  :~  :-  %vector
                          :~  [%col3 [~.t 'tricolor']]
                              [%col1 [~.t 'Abby']]
                              [%col2 [~.da ~1999.2.19]]
                              [%col3 [~.t 'tricolor']]
                              [%col4 [~.t 'row1']]
                              ==
                      :-  %vector
                          :~  [%col3 [~.t 'ticolor']]
                              [%col1 [~.t 'Ace']]
                              [%col2 [~.da ~2005.12.19]]
                              [%col3 [~.t 'ticolor']]
                              [%col4 [~.t 'row2']]
                              ==
                      :-  %vector
                          :~  [%col3 [~.t 'tuxedo']]
                              [%col1 [~.t 'Angel']]
                              [%col2 [~.da ~2001.9.19]]
                              [%col3 [~.t 'tuxedo']]
                              [%col4 [~.t 'row3']]
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
::  one column name, table-name.*
++  test-simple-query-17
  =|  run=@ud
  %-  exec-2-1
  :*  run
      [~2012.4.30 %sys "CREATE DATABASE db1"]
      ::
      :+  ~2012.5.1
          %db1
          "CREATE TABLE db1..my-table ".
          "(col1 @t, col2 @da, col3 @t, col4 @t) ".
          "PRIMARY KEY (col1)"
      ::
      :+  ~2012.5.2
          %db1
          "INSERT INTO my-table".
          " VALUES".
          " ('Abby', ~1999.2.19, 'tricolor', 'row1')".
          " ('Ace', ~2005.12.19, 'ticolor', 'row2')".
          " ('Angel', ~2001.9.19, 'tuxedo', 'row3')"
      ::
      [~2012.5.3 %db1 "FROM my-table SELECT col3,my-table.*"]
      ::
      :-  %results
          :~  [%action 'SELECT']
              :-  %result-set
                  :~  :-  %vector
                          :~  [%col3 [~.t 'tuxedo']]
                              [%col1 [~.t 'Angel']]
                              [%col2 [~.da ~2001.9.19]]
                              [%col3 [~.t 'tuxedo']]
                              [%col4 [~.t 'row3']]
                              ==
                      :-  %vector
                          :~  [%col3 [~.t 'tricolor']]
                              [%col1 [~.t 'Abby']]
                              [%col2 [~.da ~1999.2.19]]
                              [%col3 [~.t 'tricolor']]
                              [%col4 [~.t 'row1']]
                              ==
                      :-  %vector
                          :~  [%col3 [~.t 'ticolor']]
                              [%col1 [~.t 'Ace']]
                              [%col2 [~.da ~2005.12.19]]
                              [%col3 [~.t 'ticolor']]
                              [%col4 [~.t 'row2']]
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
::  one column name, table-alias.*
++  test-simple-query-18
  =|  run=@ud
  %-  exec-2-1
  :*  run
      [~2012.4.30 %sys "CREATE DATABASE db1"]
      ::
      :+  ~2012.5.1
          %db1
          "CREATE TABLE db1..my-table ".
          "(col1 @t, col2 @da, col3 @t, col4 @t) ".
          "PRIMARY KEY (col1)"
      ::
      :+  ~2012.5.2
          %db1
          "INSERT INTO my-table".
          " VALUES".
          " ('Abby', ~1999.2.19, 'tricolor', 'row1')".
          " ('Ace', ~2005.12.19, 'ticolor', 'row2')".
          " ('Angel', ~2001.9.19, 'tuxedo', 'row3')"
      ::
      [~2012.5.3 %db1 "FROM my-table T1 SELECT col2, T1.*"]
      ::
      :-  %results
          :~  [%action 'SELECT']
              :-  %result-set
                  :~  :-  %vector
                          :~  [%col2 [~.da ~2001.9.19]]
                              [%col1 [~.t 'Angel']]
                              [%col2 [~.da ~2001.9.19]]
                              [%col3 [~.t 'tuxedo']]
                              [%col4 [~.t 'row3']]
                              ==
                      :-  %vector
                          :~  [%col2 [~.da ~1999.2.19]]
                              [%col1 [~.t 'Abby']]
                              [%col2 [~.da ~1999.2.19]]
                              [%col3 [~.t 'tricolor']]
                              [%col4 [~.t 'row1']]
                              ==
                      :-  %vector
                          :~  [%col2 [~.da ~2005.12.19]]
                              [%col1 [~.t 'Ace']]
                              [%col2 [~.da ~2005.12.19]]
                              [%col3 [~.t 'ticolor']]
                              [%col4 [~.t 'row2']]
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
::  *, two column names, table-name.*, one column alias
++  test-simple-query-19
  =|  run=@ud
  %-  exec-2-1
  :*  run
      [~2012.4.30 %sys "CREATE DATABASE db1"]
      ::
      :+  ~2012.5.1
          %db1
          "CREATE TABLE db1..my-table ".
          "(col1 @t, col2 @da, col3 @t, col4 @t) ".
          "PRIMARY KEY (col1)"
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
          "FROM my-table T1 SELECT *, col2,col4, my-table.*, col1 as C1"
      ::
      :-  %results
          :~  [%action 'SELECT']
              :-  %result-set
                  :~  :-  %vector
                          :~  [%col1 [~.t 'Ace']]
                              [%col2 [~.da ~2005.12.19]]
                              [%col3 [~.t 'ticolor']]
                              [%col4 [~.t 'row2']]

                              [%col2 [~.da ~2005.12.19]]
                              [%col4 [~.t 'row2']]

                              [%col1 [~.t 'Ace']]
                              [%col2 [~.da ~2005.12.19]]
                              [%col3 [~.t 'ticolor']]
                              [%col4 [~.t 'row2']]

                              [%c1 [~.t 'Ace']]
                              ==
                      :-  %vector
                          :~  [%col1 [~.t 'Angel']]
                              [%col2 [~.da ~2001.9.19]]
                              [%col3 [~.t 'tuxedo']]
                              [%col4 [~.t 'row3']]

                              [%col2 [~.da ~2001.9.19]]
                              [%col4 [~.t 'row3']]

                              [%col1 [~.t 'Angel']]
                              [%col2 [~.da ~2001.9.19]]
                              [%col3 [~.t 'tuxedo']]
                              [%col4 [~.t 'row3']]

                              [%c1 [~.t 'Angel']]
                              ==
                      :-  %vector
                          :~  [%col1 [~.t 'Abby']]
                              [%col2 [~.da ~1999.2.19]]
                              [%col3 [~.t 'tricolor']]
                              [%col4 [~.t 'row1']]

                              [%col2 [~.da ~1999.2.19]]
                              [%col4 [~.t 'row1']]

                              [%col1 [~.t 'Abby']]
                              [%col2 [~.da ~1999.2.19]]
                              [%col3 [~.t 'tricolor']]
                              [%col4 [~.t 'row1']]

                              [%c1 [~.t 'Abby']]
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
::  one column alias, table-alias.*, two column names, *
++  test-simple-query-20
  =|  run=@ud
  %-  exec-2-1
  :*  run
      [~2012.4.30 %sys "CREATE DATABASE db1"]
      ::
      :+  ~2012.5.1
          %db1
          "CREATE TABLE db1..my-table ".
          "(col1 @t, col2 @da, col3 @t, col4 @t) ".
          "PRIMARY KEY (col1)"
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
          "FROM my-table T1 SELECT col1 as C1, T1.*, col2,col4, *"
      ::
      :-  %results
          :~  [%action 'SELECT']
              :-  %result-set
                  :~  :-  %vector
                          :~  [%c1 [~.t 'Ace']]

                              [%col1 [~.t 'Ace']]
                              [%col2 [~.da ~2005.12.19]]
                              [%col3 [~.t 'ticolor']]
                              [%col4 [~.t 'row2']]

                              [%col2 [~.da ~2005.12.19]]
                              [%col4 [~.t 'row2']]

                              [%col1 [~.t 'Ace']]
                              [%col2 [~.da ~2005.12.19]]
                              [%col3 [~.t 'ticolor']]
                              [%col4 [~.t 'row2']]
                              ==
                      :-  %vector
                          :~  [%c1 [~.t 'Abby']]

                              [%col1 [~.t 'Abby']]
                              [%col2 [~.da ~1999.2.19]]
                              [%col3 [~.t 'tricolor']]
                              [%col4 [~.t 'row1']]

                              [%col2 [~.da ~1999.2.19]]
                              [%col4 [~.t 'row1']]

                              [%col1 [~.t 'Abby']]
                              [%col2 [~.da ~1999.2.19]]
                              [%col3 [~.t 'tricolor']]
                              [%col4 [~.t 'row1']]
                              ==
                      :-  %vector
                          :~  [%c1 [~.t 'Angel']]

                              [%col1 [~.t 'Angel']]
                              [%col2 [~.da ~2001.9.19]]
                              [%col3 [~.t 'tuxedo']]
                              [%col4 [~.t 'row3']]

                              [%col2 [~.da ~2001.9.19]]
                              [%col4 [~.t 'row3']]

                              [%col1 [~.t 'Angel']]
                              [%col2 [~.da ~2001.9.19]]
                              [%col3 [~.t 'tuxedo']]
                              [%col4 [~.t 'row3']]
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
::  select all literals mixed with aliases
++  test-simple-query-21
  =|  run=@ud
  =/  my-select  "SELECT ~2020.12.25 AS Date, ~2020.12.25..7.15.0, ".
  "~2020.12.25..7.15.0..1ef5, 2020.12.25, 2020.12.25..7.15.0, ".
  "2020.12.25..7.15.0..1ef5, ~d71.h19.m26.s24..9d55 AS Timespan, ".
  "~d71.h19.m26.s24, ~d71.h19.m26, ~d71.h19, ~d71, Y AS Loobean, N,  ".
  ".195.198.143.90 AS IPv4-address, .0.0.0.0.0.1c.c3c6.8f5a as IPv6-address, ".
  "~sampel-palnet AS Ship, .3.14 AS Single-float, .-3.14,  ".
  ".~3.14 AS Double-float, .~-3.14, --0b10.0000 AS Signed-binary, -0b10.0000, ".
  "--20 AS Signed-decimal, -20, --0v201.4gvml.245kc AS Signed-base32, ".
  "-0v201.4gvml.245kc, --0w2.04AfS.G8xqc AS Signed-base64, -0w2.04AfS.G8xqc, ".
  "--0x2004.90fd AS Signed-hexadecimal, -0x2004.90fd,  ".
  "10.1011 AS Unsigned-binary, 2.222 AS Unsigned-decimal, 2222,  ".
  "0x12.6401 AS Unsigned-hexadecimal"
  %-  exec-1-1
  :*  run
      [~2012.4.30 %sys "CREATE DATABASE db1"]
      ::
      :+  ~2012.5.1
          %db1
          "CREATE TABLE db1..my-table ".
          "(col1 @t, col2 @da, col3 @t, col4 @t) ".
          "PRIMARY KEY (col1)"
      ::
      [~2012.5.3 %db1 my-select]
      ::
      :-  %results
          :~  [%action 'SELECT']
              :-  %result-set
                  :~  :-  %vector
                          :~  [%date ~.da ~2020.12.25]
                              [%literal-1 ~.da ~2020.12.25..7.15.0]
                              [%literal-2 ~.da ~2020.12.25..7.15.0..1ef5]
                              [%literal-3 ~.da ~2020.12.25]
                              [%literal-4 ~.da ~2020.12.25..7.15.0]
                              [%literal-5 ~.da ~2020.12.25..7.15.0..1ef5]
                              [%timespan ~.dr ~d71.h19.m26.s24..9d55]
                              [%literal-7 ~.dr ~d71.h19.m26.s24]
                              [%literal-8 ~.dr ~d71.h19.m26]
                              [%literal-9 ~.dr ~d71.h19]
                              [%literal-10 ~.dr ~d71]
                              [%loobean ~.f %.y]
                              [%literal-12 ~.f %.n]
                              [%ipv4-address ~.if .195.198.143.90]
                              [%ipv6-address ~.is .0.0.0.0.0.1c.c3c6.8f5a]
                              [%ship ~.p ~sampel-palnet]
                              [%single-float ~.rs .3.14]
                              [%literal-17 ~.rs .-3.14]
                              [%double-float ~.rd .~3.14]
                              [%literal-19 ~.rd .~-3.14]
                              [%signed-binary ~.sb --0b10.0000]
                              [%literal-21 ~.sb -0b10.0000]
                              [%signed-decimal ~.sd --20]
                              [%literal-23 ~.sd -20]
                              [%signed-base32 ~.sv --0v201.4gvml.245kc]
                              [%literal-25 ~.sv -0v201.4gvml.245kc]
                              [%signed-base64 ~.sw --0w2.04AfS.G8xqc]
                              [%literal-27 ~.sw -0w2.04AfS.G8xqc]
                              [%signed-hexadecimal ~.sx --0x2004.90fd]
                              [%literal-29 ~.sx -0x2004.90fd]
                              [%unsigned-binary ~.ub 0b10.1011]
                              [%unsigned-decimal ~.ud 2.222]
                              [%literal-32 ~.ud 2.222]
                              [%unsigned-hexadecimal ~.ux 0x12.6401]
                              ==
                      ==
              [%server-time ~2012.5.3]
              [%schema-time ~2012.4.30]
              [%data-time ~2012.4.30]
              [%vector-count 1]
              ==
      ==
::
::  select one literal
++  test-simple-query-22
  =|  run=@ud
  %-  exec-1-1
  :*  run
      [~2012.4.30 %sys "CREATE DATABASE db1"]
      ::
      :+  ~2012.5.1
          %db1
          "CREATE TABLE db1..my-table ".
          "(col1 @t, col2 @da, col3 @t, col4 @t) ".
          "PRIMARY KEY (col1)"
      ::
      [~2012.5.3 %db1 "SELECT 0"]
      ::
      :-  %results
          :~  [%action 'SELECT']
              [%result-set ~[[%vector ~[[%literal-0 ~.ud 0]]]]]
              [%server-time ~2012.5.3]
              [%schema-time ~2012.4.30]
              [%data-time ~2012.4.30]
              [%vector-count 1]
              ==
      ==
::
::  * (select all) not default DB
++  test-simple-query-23
  =|  run=@ud
  %-  exec-3-1
  :*  run
      [~2012.4.29 %sys "CREATE DATABASE db1"]
      ::
      [~2012.4.30 %sys "CREATE DATABASE db2"]
      ::
      :+  ~2012.5.1
          %db2
          "CREATE TABLE my-table ".
          "(col1 @t, col2 @da, col3 @t, col4 @t) ".
          "PRIMARY KEY (col1)"
      ::
      :+  ~2012.5.2
          %db2
          "INSERT INTO my-table".
          " VALUES".
          " ('Abby', ~1999.2.19, 'tricolor', 'row1')".
          " ('Ace', ~2005.12.19, 'ticolor', 'row2')".
          " ('Angel', ~2001.9.19, 'tuxedo', 'row3')"
      ::
      [~2012.5.3 %db1 "FROM db2..my-table SELECT *"]
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
              [%relation 'db2.dbo.my-table']
              [%schema-time ~2012.5.1]
              [%data-time ~2012.5.2]
              [%vector-count 3]
              ==
      ==
::
::  * (select all) not default DB, one script
++  test-simple-query-24
  =|  run=@ud
  %-  exec-0-r
  :*  run
      :+  ~2012.4.29
          %db2 
          "CREATE DATABASE db1; ".
          "CREATE DATABASE db2; ".
          "CREATE TABLE my-table".
          "  (col1 @t, col2 @da, col3 @t, col4 @t) ".
          "  PRIMARY KEY (col1); ".
          "INSERT INTO my-table".
          " VALUES".
          " ('Abby', ~1999.2.19, 'tricolor', 'row1')".
          " ('Ace', ~2005.12.19, 'ticolor', 'row2')".
          " ('Angel', ~2001.9.19, 'tuxedo', 'row3'); ".
          "FROM db2..my-table SELECT *"
      ::
      :~  %results
          [%action 'SELECT']
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
          [%server-time ~2012.4.29]
          [%relation 'db2.dbo.my-table']
          [%schema-time ~2012.4.29]
          [%data-time ~2012.4.29]
          [%vector-count 3]
          ==
      ==
::
::  lit-da, one column alias, lit-p aliased, table-alias.*, two column names, *
++  test-simple-query-25
  =|  run=@ud
  %-  exec-2-1
  :*  run
      [~2012.4.30 %sys "CREATE DATABASE db1"]
      ::
      :+  ~2012.5.1
          %db1
          "CREATE TABLE db1..my-table ".
          "(col1 @t, col2 @da, col3 @t, col4 @t) ".
          "PRIMARY KEY (col1)"
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
          "FROM my-table T1 SELECT ~2024.10.20, col1 as C1, ".
          "~sampel-palnet as home, T1.*, col2,col4, *"
      ::
      :-  %results
          :~  [%action 'SELECT']
              :-  %result-set
                  :~  :-  %vector
                          :~  [p=%literal-0 q=[p=~.da ~2024.10.20]]
                          
                              [%c1 [~.t 'Abby']]

                              [p=%home q=[p=~.p ~sampel-palnet]]

                              [%col1 [~.t 'Abby']]
                              [%col2 [~.da ~1999.2.19]]
                              [%col3 [~.t 'tricolor']]
                              [%col4 [~.t 'row1']]

                              [%col2 [~.da ~1999.2.19]]
                              [%col4 [~.t 'row1']]

                              [%col1 [~.t 'Abby']]
                              [%col2 [~.da ~1999.2.19]]
                              [%col3 [~.t 'tricolor']]
                              [%col4 [~.t 'row1']]
                              ==
                      :-  %vector
                          :~  [p=%literal-0 q=[p=~.da ~2024.10.20]]
                          
                              [%c1 [~.t 'Angel']]

                              [p=%home q=[p=~.p ~sampel-palnet]]

                              [%col1 [~.t 'Angel']]
                              [%col2 [~.da ~2001.9.19]]
                              [%col3 [~.t 'tuxedo']]
                              [%col4 [~.t 'row3']]

                              [%col2 [~.da ~2001.9.19]]
                              [%col4 [~.t 'row3']]

                              [%col1 [~.t 'Angel']]
                              [%col2 [~.da ~2001.9.19]]
                              [%col3 [~.t 'tuxedo']]
                              [%col4 [~.t 'row3']]
                              ==
                      :-  %vector
                          :~  [p=%literal-0 q=[p=~.da ~2024.10.20]]
                          
                              [%c1 [~.t 'Ace']]

                              [p=%home q=[p=~.p ~sampel-palnet]]

                              [%col1 [~.t 'Ace']]
                              [%col2 [~.da ~2005.12.19]]
                              [%col3 [~.t 'ticolor']]
                              [%col4 [~.t 'row2']]

                              [%col2 [~.da ~2005.12.19]]
                              [%col4 [~.t 'row2']]

                              [%col1 [~.t 'Ace']]
                              [%col2 [~.da ~2005.12.19]]
                              [%col3 [~.t 'ticolor']]
                              [%col4 [~.t 'row2']]
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
::  view-alias.*
++  test-simple-query-26
  =|  run=@ud
  %-  exec-0-1
  :*  run
      [~2012.4.30 %sys "CREATE DATABASE db1"]
      ::
      [~2012.5.3 %db1 "FROM sys.sys.databases V1 select v1.*"]
      ::
      :-  %results
          :~  [%action 'SELECT']
              :-  %result-set
                  :~  :-  %vector
                          :~  [%database [~.tas %db1]]
                              [%sys-agent [~.ta '/test-agent']]
                              [%sys-tmsp [~.da ~2012.4.30]]
                              [%data-ship [~.p ~zod]]
                              [%data-agent [~.ta '/test-agent']]
                              [%data-tmsp [~.da ~2012.4.30]]
                              ==
                      :-  %vector
                          :~  [%database [~.tas %sys]]
                              [%sys-agent [~.ta '/test-agent']]
                              [%sys-tmsp [~.da ~2012.4.30]]
                              [%data-ship [~.p ~zod]]
                              [%data-agent [~.ta '/test-agent']]
                              [%data-tmsp [~.da ~2012.4.30]]
                              ==
                      ==
              [%server-time ~2012.5.3]
              [%relation 'sys.sys.databases']
              [%schema-time ~2012.4.30]
              [%data-time ~2012.4.30]
              [%vector-count 2]
              ==
      ==
::
::  one column name 2X
++  test-simple-query-27
  =|  run=@ud
  %-  exec-2-1
  :*  run
      [~2012.4.30 %sys "CREATE DATABASE db1"]
      ::
      :+  ~2012.5.1
          %db1
          "CREATE TABLE db1..my-table ".
          "(col1 @t, col2 @da, col3 @t, col4 @t) ".
          "PRIMARY KEY (col1)"
      ::
      :+  ~2012.5.2
          %db1
          "INSERT INTO my-table".
          " VALUES".
          " ('Abby', ~1999.2.19, 'tricolor', 'row1')".
          " ('Ace', ~2005.12.19, 'ticolor', 'row2')".
          " ('Angel', ~2001.9.19, 'tuxedo', 'row3')"
      ::
      [~2012.5.3 %db1 "FROM my-table SELECT col3,col3"]
      ::
      :-  %results
          :~  [%action 'SELECT']
              :-  %result-set
                  :~  :-  %vector
                          :~  [%col3 [~.t 'tricolor']]
                              [%col3 [~.t 'tricolor']]
                              ==
                      :-  %vector
                          :~  [%col3 [~.t 'ticolor']]
                              [%col3 [~.t 'ticolor']]
                              ==
                      :-  %vector
                          :~  [%col3 [~.t 'tuxedo']]
                              [%col3 [~.t 'tuxedo']]
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
::  time travel
::
++  time-expected-rows
      :~
        :-  %vector
            :~  [%col1 [~.t 'Ace']]
                [%col2 [~.da ~2005.12.19]]
                [%col3 [~.t 'ticolor']]
                [%col4 [~.t 'row2']]

                [%col2 [~.da ~2005.12.19]]
                [%col4 [~.t 'row2']]

                [%col1 [~.t 'Ace']]
                [%col2 [~.da ~2005.12.19]]
                [%col3 [~.t 'ticolor']]
                [%col4 [~.t 'row2']]

                [%c1 [~.t 'Ace']]
                ==
        :-  %vector
            :~  [%col1 [~.t 'Angel']]
                [%col2 [~.da ~2001.9.19]]
                [%col3 [~.t 'tuxedo']]
                [%col4 [~.t 'row3']]

                [%col2 [~.da ~2001.9.19]]
                [%col4 [~.t 'row3']]

                [%col1 [~.t 'Angel']]
                [%col2 [~.da ~2001.9.19]]
                [%col3 [~.t 'tuxedo']]
                [%col4 [~.t 'row3']]

                [%c1 [~.t 'Angel']]
                ==
        :-  %vector
            :~  [%col1 [~.t 'Abby']]
                [%col2 [~.da ~1999.2.19]]
                [%col3 [~.t 'tricolor']]
                [%col4 [~.t 'row1']]

                [%col2 [~.da ~1999.2.19]]
                [%col4 [~.t 'row1']]

                [%col1 [~.t 'Abby']]
                [%col2 [~.da ~1999.2.19]]
                [%col3 [~.t 'tricolor']]
                [%col4 [~.t 'row1']]

                [%c1 [~.t 'Abby']]
                ==
          ==
  ::
++  time-new-rows
        :~
          :-  %vector
              :~  [%col1 [~.t 'Bandit']]
                  [%col2 [~.da ~2006.12.23]]
                  [%col3 [~.t 'tricolor']]
                  [%col4 [~.t 'row5']]

                  [%col2 [~.da ~2006.12.23]]
                  [%col4 [~.t 'row5']]

                  [%col1 [~.t 'Bandit']]
                  [%col2 [~.da ~2006.12.23]]
                  [%col3 [~.t 'tricolor']]
                  [%col4 [~.t 'row5']]

                  [%c1 [~.t 'Bandit']]
                  ==
          :-  %vector
              :~  [%col1 [~.t 'Baker']]
                  [%col2 [~.da ~1998.3.8]]
                  [%col3 [~.t 'caleco']]
                  [%col4 [~.t 'row4']]

                  [%col2 [~.da ~1998.3.8]]
                  [%col4 [~.t 'row4']]

                  [%col1 [~.t 'Baker']]
                  [%col2 [~.da ~1998.3.8]]
                  [%col3 [~.t 'caleco']]
                  [%col4 [~.t 'row4']]

                  [%c1 [~.t 'Baker']]
                  ==
          ==
++  time-expected1  :~  %results
                        [%action 'SELECT']
                        [%result-set (weld time-new-rows time-expected-rows)]
                        [%server-time ~2012.5.5]
                        [%relation 'db1.dbo.my-table']
                        [%schema-time ~2012.5.1]
                        [%data-time ~2012.5.3]
                        [%vector-count 5]
                        ==
++  time-expected2  :~  %results
                        [%action 'SELECT']
                        [%result-set time-expected-rows]
                        [%server-time ~2012.5.5]
                        [%relation 'db1.dbo.my-table']
                        [%schema-time ~2012.5.1]
                        [%data-time ~2012.5.2]
                        [%vector-count 3]
                        ==
::
::  as-of ~time >
::  *, two column names, table-name.*, one column alias
++  test-time-query-01
  =|  run=@ud
  %-  exec-3-2
  :*  run
      [~2012.4.30 %sys "CREATE DATABASE db1"]
      ::
      :+  ~2012.5.1
          %db1
          "CREATE TABLE db1..my-table ".
          "(col1 @t, col2 @da, col3 @t, col4 @t) ".
          "PRIMARY KEY (col1)"
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
          "INSERT INTO my-table".
          " VALUES".
          " ('Baker', ~1998.3.8, 'caleco', 'row4')".
          " ('Bandit', ~2006.12.23, 'tricolor', 'row5')"
      ::
      :+  ~2012.5.5
          %db1
          "FROM my-table T1 SELECT *, col2,col4, my-table.*, col1 as C1"
      ::
      :+  ~2012.5.5
          %db1
          "FROM my-table AS OF ~2012.5.2 T1 ".
          "SELECT *, col2,col4, my-table.*, col1 as C1"
      ::
      time-expected1
      ::
      time-expected2
      ==
::
::  as-of ~time =
::  *, two column names, table-name.*, one column alias
++  test-time-query-02
  =|  run=@ud
  %-  exec-3-2
  :*  run
      [~2012.4.30 %sys "CREATE DATABASE db1"]
      ::
      :+  ~2012.5.1
          %db1
          "CREATE TABLE db1..my-table ".
          "(col1 @t, col2 @da, col3 @t, col4 @t) ".
          "PRIMARY KEY (col1)"
      ::
      :+  ~2012.5.2
          %db1
          "INSERT INTO my-table".
          " VALUES".
          " ('Abby', ~1999.2.19, 'tricolor', 'row1')".
          " ('Ace', ~2005.12.19, 'ticolor', 'row2')".
          " ('Angel', ~2001.9.19, 'tuxedo', 'row3')"
      ::
      :+  ~2012.5.4
          %db1
          "INSERT INTO my-table".
          " VALUES".
          " ('Baker', ~1998.3.8, 'caleco', 'row4')".
          " ('Bandit', ~2006.12.23, 'tricolor', 'row5')"
      ::
      :+  ~2012.5.5
          %db1
          "FROM my-table T1 SELECT *, col2,col4, my-table.*, col1 as C1"
      ::
      :+  ~2012.5.5
          %db1
          "FROM my-table AS OF ~2012.5.3 T1 ".
          "SELECT *, col2,col4, my-table.*, col1 as C1"
      ::
      :-  %results
          :~  [%action 'SELECT']
              [%result-set (weld time-new-rows time-expected-rows)]
              [%server-time ~2012.5.5]
              [%relation 'db1.dbo.my-table']
              [%schema-time ~2012.5.1]
              [%data-time ~2012.5.4]
              [%vector-count 5]
              ==
      ::
      time-expected2
      ==
::
::  as-of 3 days ago (data-time = days ago)
::  *, two column names, table-name.*, one column alias
++  test-time-query-03
  =|  run=@ud
  %-  exec-3-2
  :*  run
      [~2012.4.30 %sys "CREATE DATABASE db1"]
      ::
      :+  ~2012.5.1
          %db1
          "CREATE TABLE db1..my-table ".
          "(col1 @t, col2 @da, col3 @t, col4 @t) ".
          "PRIMARY KEY (col1)"
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
          "INSERT INTO my-table".
          " VALUES".
          " ('Baker', ~1998.3.8, 'caleco', 'row4')".
          " ('Bandit', ~2006.12.23, 'tricolor', 'row5')"
      ::
      :+  ~2012.5.5
          %db1
          "FROM my-table T1 SELECT *, col2,col4, my-table.*, col1 as C1"
      ::
      :+  ~2012.5.5
          %db1
          "FROM my-table AS OF 3 DAYS AGO T1 ".
          "SELECT *, col2,col4, my-table.*, col1 as C1"
      ::
      time-expected1
      ::
      time-expected2
      ==
::
::  as-of 2 days ago (data-time < days ago)
::  *, two column names, table-name.*, one column alias
++  test-time-query-04
  =|  run=@ud
  %-  exec-3-2
  :*  run
      [~2012.4.30 %sys "CREATE DATABASE db1"]
      ::
      :+  ~2012.5.1
          %db1
          "CREATE TABLE db1..my-table ".
          "(col1 @t, col2 @da, col3 @t, col4 @t) ".
          "PRIMARY KEY (col1)"
      ::
      :+  ~2012.5.2
          %db1
          "INSERT INTO my-table".
          " VALUES".
          " ('Abby', ~1999.2.19, 'tricolor', 'row1')".
          " ('Ace', ~2005.12.19, 'ticolor', 'row2')".
          " ('Angel', ~2001.9.19, 'tuxedo', 'row3')"
      ::
      :+  ~2012.5.4
          %db1
          "INSERT INTO my-table".
          " VALUES".
          " ('Baker', ~1998.3.8, 'caleco', 'row4')".
          " ('Bandit', ~2006.12.23, 'tricolor', 'row5')"
      ::
      :+  ~2012.5.5
          %db1
          "FROM my-table T1 SELECT *, col2,col4, my-table.*, col1 as C1"
      ::
      :+  ~2012.5.5
          %db1
          "FROM my-table AS OF 2 DAYS AGO T1 ".
          "SELECT *, col2,col4, my-table.*, col1 as C1"
      ::
      :-  %results
          :~  [%action 'SELECT']
              [%result-set (weld time-new-rows time-expected-rows)]
              [%server-time ~2012.5.5]
              [%relation 'db1.dbo.my-table']
              [%schema-time ~2012.5.1]
              [%data-time ~2012.5.4]
              [%vector-count 5]
              ==
      ::
      time-expected2
      ==
::
::  as-of ~d3 (data-time = ~d3 ago)
::  *, two column names, table-name.*, one column alias
++  test-time-query-05
  =|  run=@ud
  %-  exec-3-2
  :*  run
      [~2012.4.30 %sys "CREATE DATABASE db1"]
      ::
      :+  ~2012.5.1
          %db1
          "CREATE TABLE db1..my-table ".
          "(col1 @t, col2 @da, col3 @t, col4 @t) ".
          "PRIMARY KEY (col1)"
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
          "INSERT INTO my-table".
          " VALUES".
          " ('Baker', ~1998.3.8, 'caleco', 'row4')".
          " ('Bandit', ~2006.12.23, 'tricolor', 'row5')"
      ::
      :+  ~2012.5.5
          %db1
          "FROM my-table T1 SELECT *, col2,col4, my-table.*, col1 as C1"
      ::
      :+  ~2012.5.5
          %db1
          "FROM my-table AS OF ~d3 T1 ".
          "SELECT *, col2,col4, my-table.*, col1 as C1"
      ::
      time-expected1
      ::
      time-expected2
      ==
::
::  as-of ~d2 (data-time < ~d2 ago)
::  *, two column names, table-name.*, one column alias
++  test-time-query-06
  =|  run=@ud
  %-  exec-3-2
  :*  run
      [~2012.4.30 %sys "CREATE DATABASE db1"]
      ::
      :+  ~2012.5.1
          %db1
          "CREATE TABLE db1..my-table ".
          "(col1 @t, col2 @da, col3 @t, col4 @t) ".
          "PRIMARY KEY (col1)"
      ::
      :+  ~2012.5.2
          %db1
          "INSERT INTO my-table".
          " VALUES".
          " ('Abby', ~1999.2.19, 'tricolor', 'row1')".
          " ('Ace', ~2005.12.19, 'ticolor', 'row2')".
          " ('Angel', ~2001.9.19, 'tuxedo', 'row3')"
      ::
      :+  ~2012.5.4
          %db1
          "INSERT INTO my-table".
          " VALUES".
          " ('Baker', ~1998.3.8, 'caleco', 'row4')".
          " ('Bandit', ~2006.12.23, 'tricolor', 'row5')"
      ::
      :+  ~2012.5.5
          %db1
          "FROM my-table T1 SELECT *, col2,col4, my-table.*, col1 as C1"
      ::
      :+  ~2012.5.5
          %db1
          "FROM my-table AS OF ~d2 T1 ".
          "SELECT *, col2,col4, my-table.*, col1 as C1"
      ::
      :-  %results
          :~  [%action 'SELECT']
              [%result-set (weld time-new-rows time-expected-rows)]
              [%server-time ~2012.5.5]
              [%relation 'db1.dbo.my-table']
              [%schema-time ~2012.5.1]
              [%data-time ~2012.5.4]
              [%vector-count 5]
              ==
      ::
      time-expected2
      ==
::
::  shrinking
::
::  shrinking one column to one vector
++  test-shrinking-01
  =|  run=@ud
  %-  exec-2-1
  :*  run
      [~2012.4.30 %sys "CREATE DATABASE db1"]
      ::
      :+  ~2012.5.1
          %db1
          "CREATE TABLE db1..my-table ".
          "(col1 @t, col2 @da, col3 @t, col4 @t) ".
          "PRIMARY KEY (col1)"
      ::
      :+  ~2012.5.2
          %db1
          "INSERT INTO my-table".
          " VALUES".
          " ('Abby', ~2005.12.19, 'tricolor', 'row1')".
          " ('Angel', ~2005.12.19, 'tuxedo', 'row3')".
          " ('Ace', ~2005.12.19, 'tricolor', 'row2')"
      ::
      [~2012.5.3 %db1 "FROM my-table SELECT col2"]
      ::
      :-  %results
          :~  [%action 'SELECT']
              [%result-set ~[[%vector ~[[%col2 [~.da ~2005.12.19]]]]]]
              [%server-time ~2012.5.3]
              [%relation 'db1.dbo.my-table']
              [%schema-time ~2012.5.1]
              [%data-time ~2012.5.2]
              [%vector-count 1]
              ==
      ==
::
::  shrinking one column (out of order) to one vector
++  test-shrinking-02
  =|  run=@ud
  %-  exec-2-1
  :*  run
      [~2012.4.30 %sys "CREATE DATABASE db1"]
      ::
      :+  ~2012.5.1
          %db1
          "CREATE TABLE db1..my-table ".
          "(col1 @t, col2 @da, col3 @t, col4 @t) ".
          "PRIMARY KEY (col1)"
      ::
      :+  ~2012.5.2
          %db1
          "INSERT INTO my-table".
          " VALUES".
          " ('Abby', ~2005.12.19, 'tricolor', 'row1')".
          " ('Ace', ~2005.12.19, 'tuxedo', 'row2')".
          " ('Angel', ~2005.12.19, 'tricolor', 'row3')"
      ::
      [~2012.5.3 %db1 "FROM my-table SELECT col3"]
      ::
      :-  %results
          :~  [%action 'SELECT']
              :-  %result-set
                  :~  [%vector ~[[%col3 [~.t 'tricolor']]]]
                      [%vector ~[[%col3 [~.t 'tuxedo']]]]
                      ==
              [%server-time ~2012.5.3]
              [%relation 'db1.dbo.my-table']
              [%schema-time ~2012.5.1]
              [%data-time ~2012.5.2]
              [%vector-count 2]
              ==
      ==
::
::  shrinking one column to two vectors
++  test-shrinking-03
  =|  run=@ud
  %-  exec-2-1
  :*  run
      [~2012.4.30 %sys "CREATE DATABASE db1"]
      ::
      :+  ~2012.5.1
          %db1
          "CREATE TABLE db1..my-table ".
          "(col1 @t, col2 @da, col3 @t, col4 @t) ".
          "PRIMARY KEY (col1)"
      ::
      :+  ~2012.5.2
          %db1
          "INSERT INTO my-table".
          " VALUES".
          " ('Abby', ~2005.12.19, 'tricolor', 'row1')".
          " ('Angel', ~2005.12.19, 'tuxedo', 'row3')".
          " ('Ace', ~2005.12.19, 'tricolor', 'row2')"
      ::
      [~2012.5.3 %db1 "FROM my-table SELECT col3"]
      ::
      :-  %results
          :~  [%action 'SELECT']
              :-  %result-set
                  :~  [%vector ~[[%col3 [~.t 'tricolor']]]]
                      [%vector ~[[%col3 [~.t 'tuxedo']]]]
                      ==
              [%server-time ~2012.5.3]
              [%relation 'db1.dbo.my-table']
              [%schema-time ~2012.5.1]
              [%data-time ~2012.5.2]
              [%vector-count 2]
              ==
      ==
::
::  shrinking two columns to two vectors
++  test-shrinking-04
  =|  run=@ud
  %-  exec-2-1
  :*  run
      [~2012.4.30 %sys "CREATE DATABASE db1"]
      ::
      :+  ~2012.5.1
          %db1
          "CREATE TABLE db1..my-table ".
          "(col1 @t, col2 @da, col3 @t, col4 @t) ".
          "PRIMARY KEY (col1)"
      ::
      :+  ~2012.5.2
          %db1
          "INSERT INTO my-table".
          " VALUES".
          " ('Abby', ~2005.12.19, 'tricolor', 'row1')".
          " ('Angel', ~2005.12.19, 'tuxedo', 'row3')".
          " ('Ace', ~2005.12.19, 'tricolor', 'row2')"
      ::
      [~2012.5.3 %db1 "FROM my-table SELECT col2 as c2, col3"]
      ::
      :-  %results
          :~  [%action 'SELECT']
              :-  %result-set
                  :~  [%vector ~[[%c2 [~.da ~2005.12.19]] [%col3 [~.t 'tricolor']]]]
                      [%vector ~[[%c2 [~.da ~2005.12.19]] [%col3 [~.t 'tuxedo']]]]
                      ==
              [%server-time ~2012.5.3]
              [%relation 'db1.dbo.my-table']
              [%schema-time ~2012.5.1]
              [%data-time ~2012.5.2]
              [%vector-count 2]
              ==
      ==
::
::  shrinking two columns and literals to two vectors
++  test-shrinking-05
  =|  run=@ud
  %-  exec-2-1
  :*  run
      [~2012.4.30 %sys "CREATE DATABASE db1"]
      ::
      :+  ~2012.5.1
          %db1
          "CREATE TABLE db1..my-table ".
          "(col1 @t, col2 @da, col3 @t, col4 @t) ".
          "PRIMARY KEY (col1)"
      ::
      :+  ~2012.5.2
          %db1
          "INSERT INTO my-table".
          " VALUES".
          " ('Abby', ~2005.12.19, 'tricolor', 'row1')".
          " ('Angel', ~2005.12.19, 'tuxedo', 'row3')".
          " ('Ace', ~2005.12.19, 'tricolor', 'row2')"
      ::
      :+  ~2012.5.3
          %db1
          "FROM my-table SELECT  ~2024.10.20, col2 as c2, ".
          "~sampel-palnet as home, col3"
      ::
      :-  %results
          :~  [%action 'SELECT']
              :-  %result-set
                  :~  :-  %vector
                          :~  [p=%literal-0 q=[p=~.da ~2024.10.20]]
                              [%c2 [~.da ~2005.12.19]]
                              [p=%home q=[p=~.p ~sampel-palnet]]
                              [%col3 [~.t 'tuxedo']]
                              ==
                      :-  %vector
                          :~  [p=%literal-0 q=[p=~.da ~2024.10.20]]
                              [%c2 [~.da ~2005.12.19]]
                              [p=%home q=[p=~.p ~sampel-palnet]]
                              [%col3 [~.t 'tricolor']]
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
::  shrinking two columns and literals from view
++  test-shrinking-06
  =|  run=@ud
  %-  exec-2-1
  ::%-  debug-2-1
  :*  run
      [~2012.4.30 %sys "CREATE DATABASE db1"]
      ::
      :+  ~2012.5.1
          %db1
          "CREATE TABLE db1..my-table ".
          "(col1 @t, col2 @da, col3 @t, col4 @t) ".
          "PRIMARY KEY (col1)"
      ::
      :+  ~2012.5.2
          %db1
          "CREATE TABLE db1..my-table-2 ".
          "(c2-col1 @t, c2-col2 @da, c2-col3 @t, c2-col4 @t) ".
          "PRIMARY KEY (c2-col1, c2-col2)"
      ::
      :+  ~2012.5.3
          %db1
          "FROM sys.tables SELECT  ~2024.10.20, tmsp as time, ".
          "~sampel-palnet as home"
      ::
      :-  %results
          :~  [%action 'SELECT']
              :-  %result-set
                  :~  :-  %vector
                          :~  [p=%literal-0 q=[p=~.da ~2024.10.20]]
                              [%time [~.da ~2012.5.2]]
                              [p=%home q=[p=~.p ~sampel-palnet]]
                              ==
                      :-  %vector
                          :~  [p=%literal-0 q=[p=~.da ~2024.10.20]]
                              [%time [~.da ~2012.5.1]]
                              [p=%home q=[p=~.p ~sampel-palnet]]
                              ==
                      ==
              [%server-time ~2012.5.3]
              [%relation 'db1.sys.tables']
              [%schema-time ~2012.5.2]
              [%data-time ~2012.5.2]
              [%vector-count 2]
              ==
      ==
::
::  joins
++  create-calendar
  "CREATE TABLE calendar ".
  "(date        @da,".
  " year        @ud,".
  " month       @ud,".
  " month-name  @t,".
  " day         @ud,".
  " day-name    @t,".
  " day-of-year @ud,".
  " weekday     @ud,".
  " year-week   @ud)".
  "  PRIMARY KEY (date);"
++  insert-calendar
  "INSERT INTO calendar ".
  "VALUES ".
  "(~2023.12.21, 2023, 12, 'December', 21, 'Thursday', 355, 5, 51) ".
  "(~2023.12.22, 2023, 12, 'December', 22, 'Friday', 356, 6, 51) ".
  "(~2023.12.23, 2023, 12, 'December', 23, 'Saturday', 357, 7, 51) ".
  "(~2023.12.24, 2023, 12, 'December', 24, 'Sunday', 358, 1, 52) ".
  "(~2023.12.25, 2023, 12, 'December', 25, 'Monday', 359, 2, 52) ".
  "(~2023.12.26, 2023, 12, 'December', 26, 'Tuesday', 360, 3, 52) ".
  "(~2023.12.27, 2023, 12, 'December', 27, 'Wednesday', 361, 4, 52) ".
  "(~2023.12.28, 2023, 12, 'December', 28, 'Thursday', 362, 5, 52) ".
  "(~2023.12.29, 2023, 12, 'December', 29, 'Friday', 363, 6, 52) ".
  "(~2023.12.30, 2023, 12, 'December', 30, 'Saturday', 364, 7, 52) ".
  "(~2023.12.31, 2023, 12, 'December', 31, 'Sunday', 365, 1, 53) ".
  "(~2024.1.1, 2024, 1, 'January', 1, 'Monday', 1, 2, 1) ".
  "(~2024.1.2, 2024, 1, 'January', 2, 'Tuesday', 2, 3, 1);"
++  create-holiday-calendar
  "CREATE TABLE holiday-calendar ".
  "(date @da, us-federal-holiday @t) ".
  "PRIMARY KEY (date);"
++  insert-holiday-calendar
  "INSERT INTO holiday-calendar ".
  "(date, us-federal-holiday) ".
  "VALUES ".
  "(~2023.11.23, 'Thanksgiving Day') ".
  "(~2023.12.25, 'Christmas Day') ".
  "(~2024.1.1, 'New Years Day') ".
  "(~2024.1.15, 'Birthday of Martin Luther King Jr.');"
++  create-tbl1
  "CREATE TABLE tbl1 ".
  "(year        @ud,".
  " month       @ud,".
  " day         @ud,".
  " month-name  @t)".
  "  PRIMARY KEY (year, month, day);"
++  create-tbl3
  "CREATE TABLE tbl3 ".
  "(date      @da,".
  " year      @ud,".
  " month     @ud,".
  " day       @ud,".
  " row-name  @t)".
  "  PRIMARY KEY (date);"
++  create-cross-tbl
  "CREATE TABLE cross ".
  "(cross-key  @ud,".
  " cross-2    @p,".
  " cross-3    @t)".
  "  PRIMARY KEY (cross-key);"
++  insert-cross
  "INSERT INTO cross ".
  "VALUES ".
  "(1, ~sampel-palnet, 'cross-a') ".
  "(2, ~nec, 'cross-b') ".
  "(3, ~bus, 'cross-c');"
++  insert-tbl1
  "INSERT INTO tbl1 ".
  "VALUES ".
  "(2023, 12, 21, 'December') ".
  "(2023, 12, 22, 'December') ".
  "(2023, 12, 23, 'December') ".
  "(2023, 12, 24, 'December') ".
  "(2023, 12, 25, 'December') ".
  "(2023, 12, 26, 'December') ".
  "(2023, 12, 27, 'December') ".
  "(2023, 12, 28, 'December') ".
  "(2023, 12, 29, 'December') ".
  "(2023, 12, 30, 'December') ".
  "(2023, 12, 31, 'December') ".
  "(2024, 1, 1, 'January') ".
  "(2024, 1, 2, 'January') ".
  "(2024, 2, 3, 'February') ".
  "(2024, 2, 4, 'February') ".
  "(2024, 2, 5, 'February') ".
  "(2024, 2, 6, 'February') ".
  "(2024, 2, 7, 'February') ".
  "(2024, 3, 3, 'March') ".
  "(2024, 3, 4, 'March') ".
  "(2024, 3, 5, 'March') ".
  "(2024, 3, 6, 'March') ".
  "(2024, 3, 7, 'March') ".
  "(2024, 3, 8, 'March') ".
  "(2024, 4, 1, 'April') ".
  "(2024, 4, 2, 'April') ".
  "(2024, 4, 3, 'April') ".
  "(2024, 4, 4, 'April') ".
  "(2024, 4, 5, 'April') ".
  "(2024, 4, 6, 'April') ".
  "(2024, 4, 7, 'April') ".
  "(2024, 4, 8, 'April');"
++  insert-tbl1-a
  "INSERT INTO tbl1 ".
  "VALUES ".
  "(2023, 12, 21, 'December') ".
  "(2023, 12, 22, 'December') ".
  "(2023, 12, 23, 'December') ".
  "(2023, 12, 24, 'December') ".
  "(2023, 12, 25, 'December') ".
  "(2023, 12, 26, 'December') ".
  "(2023, 12, 27, 'December') ".
  "(2023, 12, 28, 'December') ".
  "(2023, 12, 29, 'December') ".
  "(2023, 12, 30, 'December') ".
  "(2023, 12, 31, 'December');"
++  insert-tbl1-b
  "INSERT INTO tbl1 ".
  "VALUES ".
  "(2023, 8, 21, 'August') ".
  "(2023, 9, 22, 'September') ".
  "(2023, 10, 23, 'October') ".
  "(2023, 11, 24, 'November') ".
  "(2023, 12, 25, 'December');"
++  insert-tbl2
  "INSERT INTO tbl2 ".
  "VALUES ".
  "(2023, 12, 21, 'Thursday') ".
  "(2023, 12, 22, 'Friday') ".
  "(2023, 12, 23, 'Saturday') ".
  "(2023, 12, 24, 'Sunday') ".
  "(2023, 12, 25, 'Monday') ".
  "(2023, 12, 26, 'Tuesday') ".
  "(2023, 12, 27, 'Wednesday') ".
  "(2023, 12, 28, 'Thursday') ".
  "(2023, 12, 29, 'Friday') ".
  "(2023, 12, 30, 'Saturday') ".
  "(2023, 12, 31, 'Sunday') ".
  "(2024, 1, 1, 'Monday') ".
  "(2024, 1, 2, 'Tuesday') ".
  "(2024, 2, 3, 'Saturday') ".
  "(2024, 2, 4, 'Sunday') ".
  "(2024, 2, 5, 'Monday') ".
  "(2024, 2, 6, 'Tuesday') ".
  "(2024, 2, 7, 'Wednesday') ".
  "(2024, 3, 3, 'Sunday') ".
  "(2024, 3, 4, 'Monday') ".
  "(2024, 3, 5, 'Tuesday') ".
  "(2024, 3, 6, 'Wednesday') ".
  "(2024, 3, 7, 'Thursday') ".
  "(2024, 3, 8, 'Friday') ".
  "(2024, 4, 1, 'Monday') ".
  "(2024, 4, 2, 'Tuesday') ".
  "(2024, 4, 3, 'Wednesday') ".
  "(2024, 4, 4, 'Thursday') ".
  "(2024, 4, 5, 'Friday') ".
  "(2024, 4, 6, 'Saturday') ".
  "(2024, 4, 7, 'Sunday') ".
  "(2024, 4, 8, 'Monday');"
++  insert-tbl2-a
  "INSERT INTO tbl2 ".
  "VALUES ".
  "(2023, 12, 23, 'Saturday') ".
  "(2023, 12, 24, 'Sunday') ".
  "(2023, 12, 25, 'Monday') ".
  "(2023, 12, 26, 'Tuesday') ".
  "(2023, 12, 27, 'Wednesday') ".
  "(2023, 12, 29, 'Friday') ".
  "(2023, 12, 30, 'Saturday') ".
  "(2023, 12, 31, 'Sunday') ".
  "(2024, 1, 1, 'Monday') ".
  "(2024, 1, 2, 'Tuesday') ".
  "(2024, 2, 3, 'Saturday') ".
  "(2024, 2, 5, 'Monday') ".
  "(2024, 2, 6, 'Tuesday') ".
  "(2024, 2, 7, 'Wednesday') ".
  "(2024, 3, 3, 'Sunday') ".
  "(2024, 3, 4, 'Monday') ".
  "(2024, 3, 6, 'Wednesday') ".
  "(2024, 3, 7, 'Thursday') ".
  "(2024, 3, 8, 'Friday') ".
  "(2024, 4, 1, 'Monday') ".
  "(2024, 4, 3, 'Wednesday') ".
  "(2024, 4, 4, 'Thursday') ".
  "(2024, 4, 5, 'Friday') ".
  "(2024, 4, 7, 'Sunday') ".
  "(2024, 4, 8, 'Monday') ".
  "(2024, 4, 9, 'Tuesday');"
++  insert-tbl3
  "INSERT INTO tbl3 ".
  "VALUES ".
  "(~2023.12.21, 2023, 12, 21, 'row-1') ".
  "(~2023.12.24, 2023, 12, 24, 'row-2') ".
  "(~2023.12.25, 2023, 12, 25, 'row-3') ".
  "(~2023.12.26, 2023, 12, 26, 'row-4') ".
  "(~2023.12.30, 2023, 12, 30, 'row-5') ".
  "(~2023.12.31, 2023, 12, 31, 'row-6') ".
  "(~2024.1.1, 2024, 1, 1, 'row-7') ".
  "(~2024.1.2, 2024, 1, 2, 'row-8') ".
  "(~2024.2.7, 2024, 2, 7, 'row-9') ".
  "(~2024.3.3, 2024, 3, 3, 'row-10') ".
  "(~2024.3.4, 2024, 3, 4, 'row-11') ".
  "(~2024.3.8, 2024, 3, 8, 'row-12') ".
  "(~2024.4.1, 2024, 4, 1, 'row-13') ".
  "(~2024.4.2, 2024, 4, 2, 'row-14') ".
  "(~2024.4.7, 2024, 4, 7, 'row-15') ".
  "(~2024.4.8, 2024, 4, 8, 'row-16');"
++  expect-rows-1
      :~
        :-  %vector
            :~  [%year [~.ud 2.023]]
                [%month [~.ud 12]]
                [%day [~.ud 21]]
                [%month-name [~.t 'December']]
                [%day-name [~.t 'Thursday']]
                ==
        :-  %vector
            :~  [%year [~.ud 2.023]]
                [%month [~.ud 12]]
                [%day [~.ud 22]]
                [%month-name [~.t 'December']]
                [%day-name [~.t 'Friday']]
                ==
        :-  %vector
            :~  [%year [~.ud 2.023]]
                [%month [~.ud 12]]
                [%day [~.ud 23]]
                [%month-name [~.t 'December']]
                [%day-name [~.t 'Saturday']]
                ==
        :-  %vector
            :~  [%year [~.ud 2.023]]
                [%month [~.ud 12]]
                [%day [~.ud 24]]
                [%month-name [~.t 'December']]
                [%day-name [~.t 'Sunday']]
                ==
        :-  %vector
            :~  [%year [~.ud 2.023]]
                [%month [~.ud 12]]
                [%day [~.ud 25]]
                [%month-name [~.t 'December']]
                [%day-name [~.t 'Monday']]
                ==
        :-  %vector
            :~  [%year [~.ud 2.023]]
                [%month [~.ud 12]]
                [%day [~.ud 26]]
                [%month-name [~.t 'December']]
                [%day-name [~.t 'Tuesday']]
                ==
        :-  %vector
            :~  [%year [~.ud 2.023]]
                [%month [~.ud 12]]
                [%day [~.ud 27]]
                [%month-name [~.t 'December']]
                [%day-name [~.t 'Wednesday']]
                ==
        :-  %vector
            :~  [%year [~.ud 2.023]]
                [%month [~.ud 12]]
                [%day [~.ud 28]]
                [%month-name [~.t 'December']]
                [%day-name [~.t 'Thursday']]
                ==
        :-  %vector
            :~  [%year [~.ud 2.023]]
                [%month [~.ud 12]]
                [%day [~.ud 29]]
                [%month-name [~.t 'December']]
                [%day-name [~.t 'Friday']]
                ==
        :-  %vector
            :~  [%year [~.ud 2.023]]
                [%month [~.ud 12]]
                [%day [~.ud 30]]
                [%month-name [~.t 'December']]
                [%day-name [~.t 'Saturday']]
                ==
        :-  %vector
            :~  [%year [~.ud 2.023]]
                [%month [~.ud 12]]
                [%day [~.ud 31]]
                [%month-name [~.t 'December']]
                [%day-name [~.t 'Sunday']]
                ==
        :-  %vector
            :~  [%year [~.ud 2.024]]
                [%month [~.ud 1]]
                [%day [~.ud 1]]
                [%month-name [~.t 'January']]
                [%day-name [~.t 'Monday']]
                ==
        :-  %vector
            :~  [%year [~.ud 2.024]]
                [%month [~.ud 1]]
                [%day [~.ud 2]]
                [%month-name [~.t 'January']]
                [%day-name [~.t 'Tuesday']]
                ==
        :-  %vector
            :~  [%year [~.ud 2.024]]
                [%month [~.ud 2]]
                [%day [~.ud 3]]
                [%month-name [~.t 'February']]
                [%day-name [~.t 'Saturday']]
                ==
        :-  %vector
            :~  [%year [~.ud 2.024]]
                [%month [~.ud 2]]
                [%day [~.ud 4]]
                [%month-name [~.t 'February']]
                [%day-name [~.t 'Sunday']]
                ==
        :-  %vector
            :~  [%year [~.ud 2.024]]
                [%month [~.ud 2]]
                [%day [~.ud 5]]
                [%month-name [~.t 'February']]
                [%day-name [~.t 'Monday']]
                ==
        :-  %vector
            :~  [%year [~.ud 2.024]]
                [%month [~.ud 2]]
                [%day [~.ud 6]]
                [%month-name [~.t 'February']]
                [%day-name [~.t 'Tuesday']]
                ==
        :-  %vector
            :~  [%year [~.ud 2.024]]
                [%month [~.ud 2]]
                [%day [~.ud 7]]
                [%month-name [~.t 'February']]
                [%day-name [~.t 'Wednesday']]
                ==
        :-  %vector
            :~  [%year [~.ud 2.024]]
                [%month [~.ud 3]]
                [%day [~.ud 3]]
                [%month-name [~.t 'March']]
                [%day-name [~.t 'Sunday']]
                ==
        :-  %vector
            :~  [%year [~.ud 2.024]]
                [%month [~.ud 3]]
                [%day [~.ud 4]]
                [%month-name [~.t 'March']]
                [%day-name [~.t 'Monday']]
                ==
        :-  %vector
            :~  [%year [~.ud 2.024]]
                [%month [~.ud 3]]
                [%day [~.ud 5]]
                [%month-name [~.t 'March']]
                [%day-name [~.t 'Tuesday']]
                ==
        :-  %vector
            :~  [%year [~.ud 2.024]]
                [%month [~.ud 3]]
                [%day [~.ud 6]]
                [%month-name [~.t 'March']]
                [%day-name [~.t 'Wednesday']]
                ==
        :-  %vector
            :~  [%year [~.ud 2.024]]
                [%month [~.ud 3]]
                [%day [~.ud 7]]
                [%month-name [~.t 'March']]
                [%day-name [~.t 'Thursday']]
                ==
        :-  %vector
            :~  [%year [~.ud 2.024]]
                [%month [~.ud 3]]
                [%day [~.ud 8]]
                [%month-name [~.t 'March']]
                [%day-name [~.t 'Friday']]
                ==
        :-  %vector
            :~  [%year [~.ud 2.024]]
                [%month [~.ud 4]]
                [%day [~.ud 1]]
                [%month-name [~.t 'April']]
                [%day-name [~.t 'Monday']]
                ==
        :-  %vector
            :~  [%year [~.ud 2.024]]
                [%month [~.ud 4]]
                [%day [~.ud 2]]
                [%month-name [~.t 'April']]
                [%day-name [~.t 'Tuesday']]
                ==
        :-  %vector
            :~  [%year [~.ud 2.024]]
                [%month [~.ud 4]]
                [%day [~.ud 3]]
                [%month-name [~.t 'April']]
                [%day-name [~.t 'Wednesday']]
                ==
        :-  %vector
            :~  [%year [~.ud 2.024]]
                [%month [~.ud 4]]
                [%day [~.ud 4]]
                [%month-name [~.t 'April']]
                [%day-name [~.t 'Thursday']]
                ==
        :-  %vector
            :~  [%year [~.ud 2.024]]
                [%month [~.ud 4]]
                [%day [~.ud 5]]
                [%month-name [~.t 'April']]
                [%day-name [~.t 'Friday']]
                ==
        :-  %vector
            :~  [%year [~.ud 2.024]]
                [%month [~.ud 4]]
                [%day [~.ud 6]]
                [%month-name [~.t 'April']]
                [%day-name [~.t 'Saturday']]
                ==
        :-  %vector
            :~  [%year [~.ud 2.024]]
                [%month [~.ud 4]]
                [%day [~.ud 7]]
                [%month-name [~.t 'April']]
                [%day-name [~.t 'Sunday']]
                ==
        :-  %vector
            :~  [%year [~.ud 2.024]]
                [%month [~.ud 4]]
                [%day [~.ud 8]]
                [%month-name [~.t 'April']]
                [%day-name [~.t 'Monday']]
                ==
        ==
++  expect-rows-1-a
      :~
        :-  %vector
            :~  [%year [~.ud 2.023]]
                [%month [~.ud 12]]
                [%day [~.ud 23]]
                [%month-name [~.t 'December']]
                [%day-name [~.t 'Saturday']]
                ==
        :-  %vector
            :~  [%year [~.ud 2.023]]
                [%month [~.ud 12]]
                [%day [~.ud 24]]
                [%month-name [~.t 'December']]
                [%day-name [~.t 'Sunday']]
                ==
        :-  %vector
            :~  [%year [~.ud 2.023]]
                [%month [~.ud 12]]
                [%day [~.ud 25]]
                [%month-name [~.t 'December']]
                [%day-name [~.t 'Monday']]
                ==
        :-  %vector
            :~  [%year [~.ud 2.023]]
                [%month [~.ud 12]]
                [%day [~.ud 26]]
                [%month-name [~.t 'December']]
                [%day-name [~.t 'Tuesday']]
                ==
        :-  %vector
            :~  [%year [~.ud 2.023]]
                [%month [~.ud 12]]
                [%day [~.ud 27]]
                [%month-name [~.t 'December']]
                [%day-name [~.t 'Wednesday']]
                ==
        :-  %vector
            :~  [%year [~.ud 2.023]]
                [%month [~.ud 12]]
                [%day [~.ud 29]]
                [%month-name [~.t 'December']]
                [%day-name [~.t 'Friday']]
                ==
        :-  %vector
            :~  [%year [~.ud 2.023]]
                [%month [~.ud 12]]
                [%day [~.ud 30]]
                [%month-name [~.t 'December']]
                [%day-name [~.t 'Saturday']]
                ==
        :-  %vector
            :~  [%year [~.ud 2.023]]
                [%month [~.ud 12]]
                [%day [~.ud 31]]
                [%month-name [~.t 'December']]
                [%day-name [~.t 'Sunday']]
                ==
        :-  %vector
            :~  [%year [~.ud 2.024]]
                [%month [~.ud 1]]
                [%day [~.ud 1]]
                [%month-name [~.t 'January']]
                [%day-name [~.t 'Monday']]
                ==
        :-  %vector
            :~  [%year [~.ud 2.024]]
                [%month [~.ud 1]]
                [%day [~.ud 2]]
                [%month-name [~.t 'January']]
                [%day-name [~.t 'Tuesday']]
                ==
        :-  %vector
            :~  [%year [~.ud 2.024]]
                [%month [~.ud 2]]
                [%day [~.ud 3]]
                [%month-name [~.t 'February']]
                [%day-name [~.t 'Saturday']]
                ==
        :-  %vector
            :~  [%year [~.ud 2.024]]
                [%month [~.ud 2]]
                [%day [~.ud 5]]
                [%month-name [~.t 'February']]
                [%day-name [~.t 'Monday']]
                ==
        :-  %vector
            :~  [%year [~.ud 2.024]]
                [%month [~.ud 2]]
                [%day [~.ud 6]]
                [%month-name [~.t 'February']]
                [%day-name [~.t 'Tuesday']]
                ==
        :-  %vector
            :~  [%year [~.ud 2.024]]
                [%month [~.ud 2]]
                [%day [~.ud 7]]
                [%month-name [~.t 'February']]
                [%day-name [~.t 'Wednesday']]
                ==
        :-  %vector
            :~  [%year [~.ud 2.024]]
                [%month [~.ud 3]]
                [%day [~.ud 3]]
                [%month-name [~.t 'March']]
                [%day-name [~.t 'Sunday']]
                ==
        :-  %vector
            :~  [%year [~.ud 2.024]]
                [%month [~.ud 3]]
                [%day [~.ud 4]]
                [%month-name [~.t 'March']]
                [%day-name [~.t 'Monday']]
                ==
        :-  %vector
            :~  [%year [~.ud 2.024]]
                [%month [~.ud 3]]
                [%day [~.ud 6]]
                [%month-name [~.t 'March']]
                [%day-name [~.t 'Wednesday']]
                ==
        :-  %vector
            :~  [%year [~.ud 2.024]]
                [%month [~.ud 3]]
                [%day [~.ud 7]]
                [%month-name [~.t 'March']]
                [%day-name [~.t 'Thursday']]
                ==
        :-  %vector
            :~  [%year [~.ud 2.024]]
                [%month [~.ud 3]]
                [%day [~.ud 8]]
                [%month-name [~.t 'March']]
                [%day-name [~.t 'Friday']]
                ==
        :-  %vector
            :~  [%year [~.ud 2.024]]
                [%month [~.ud 4]]
                [%day [~.ud 1]]
                [%month-name [~.t 'April']]
                [%day-name [~.t 'Monday']]
                ==
        :-  %vector
            :~  [%year [~.ud 2.024]]
                [%month [~.ud 4]]
                [%day [~.ud 3]]
                [%month-name [~.t 'April']]
                [%day-name [~.t 'Wednesday']]
                ==
        :-  %vector
            :~  [%year [~.ud 2.024]]
                [%month [~.ud 4]]
                [%day [~.ud 4]]
                [%month-name [~.t 'April']]
                [%day-name [~.t 'Thursday']]
                ==
        :-  %vector
            :~  [%year [~.ud 2.024]]
                [%month [~.ud 4]]
                [%day [~.ud 5]]
                [%month-name [~.t 'April']]
                [%day-name [~.t 'Friday']]
                ==
        :-  %vector
            :~  [%year [~.ud 2.024]]
                [%month [~.ud 4]]
                [%day [~.ud 7]]
                [%month-name [~.t 'April']]
                [%day-name [~.t 'Sunday']]
                ==
        :-  %vector
            :~  [%year [~.ud 2.024]]
                [%month [~.ud 4]]
                [%day [~.ud 8]]
                [%month-name [~.t 'April']]
                [%day-name [~.t 'Monday']]
                ==
        ==
++  expect-rows-2
      :~
        :-  %vector
            :~  [%year [~.ud 2.023]]
                [%month [~.ud 12]]
                [%day [~.ud 25]]
                [%month-name [~.t 'December']]
                [%day-name [~.t 'Monday']]
                ==
        :-  %vector
            :~  [%year [~.ud 2.024]]
                [%month [~.ud 1]]
                [%day [~.ud 1]]
                [%month-name [~.t 'January']]
                [%day-name [~.t 'Monday']]
                ==
        :-  %vector
            :~  [%year [~.ud 2.024]]
                [%month [~.ud 2]]
                [%day [~.ud 5]]
                [%month-name [~.t 'February']]
                [%day-name [~.t 'Monday']]
                ==
        :-  %vector
            :~  [%year [~.ud 2.024]]
                [%month [~.ud 3]]
                [%day [~.ud 4]]
                [%month-name [~.t 'March']]
                [%day-name [~.t 'Monday']]
                ==
        :-  %vector
            :~  [%year [~.ud 2.024]]
                [%month [~.ud 4]]
                [%day [~.ud 1]]
                [%month-name [~.t 'April']]
                [%day-name [~.t 'Monday']]
                ==
        :-  %vector
            :~  [%year [~.ud 2.024]]
                [%month [~.ud 4]]
                [%day [~.ud 8]]
                [%month-name [~.t 'April']]
                [%day-name [~.t 'Monday']]
                ==
        ==
++  expected-cross-rows
      :~  :-  %vector
              :~  [%year [~.ud q=2.023]]
                  [%month [~.ud q=12]]
                  [%day [~.ud q=31]]
                  [%month-name [~.t q=8.243.102.914.963.531.076]]
                  [%cross-key [~.ud q=1]]
                  [%cross-2 [~.p q=1.624.961.343]]
                  [%cross-3 [~.t q=27.353.046.622.106.211]]
                  ==
          :-  %vector
              :~  [%year [~.ud q=2.023]]
                  [%month [~.ud q=12]]
                  [%day [~.ud q=23]]
                  [%month-name [~.t q=8.243.102.914.963.531.076]]
                  [%cross-key [~.ud q=2]]
                  [%cross-2 [~.p q=1]]
                  [%cross-3 [~.t q=27.634.521.598.816.867]]
                  ==
          :-  %vector
              :~  [%year [~.ud q=2.023]]
                  [%month [~.ud q=12]]
                  [%day [~.ud q=29]]
                  [%month-name [~.t q=8.243.102.914.963.531.076]]
                  [%cross-key [~.ud q=2]]
                  [%cross-2 [~.p q=1]]
                  [%cross-3 [~.t q=27.634.521.598.816.867]]
                  ==
          :-  %vector
              :~  [%year [~.ud q=2.023]]
                  [%month [~.ud q=12]]
                  [%day [~.ud q=31]]
                  [%month-name [~.t q=8.243.102.914.963.531.076]]
                  [%cross-key [~.ud q=2]]
                  [%cross-2 [~.p q=1]]
                  [%cross-3 [~.t q=27.634.521.598.816.867]]
                  ==
          :-  %vector
              :~  [%year [~.ud q=2.023]]
                  [%month [~.ud q=12]]
                  [%day [~.ud q=25]]
                  [%month-name [~.t q=8.243.102.914.963.531.076]]
                  [%cross-key [~.ud q=2]]
                  [%cross-2 [~.p q=1]]
                  [%cross-3 [~.t q=27.634.521.598.816.867]]
                  ==
          :-  %vector
              :~  [%year [~.ud q=2.023]]
                  [%month [~.ud q=12]]
                  [%day [~.ud q=23]]
                  [%month-name [~.t q=8.243.102.914.963.531.076]]
                  [%cross-key [~.ud q=3]]
                  [%cross-2 [~.p q=182]]
                  [%cross-3 [~.t q=27.915.996.575.527.523]]
                  ==
          :-  %vector
              :~  [%year [~.ud q=2.023]]
                  [%month [~.ud q=12]]
                  [%day [~.ud q=30]]
                  [%month-name [~.t q=8.243.102.914.963.531.076]]
                  [%cross-key [~.ud q=3]]
                  [%cross-2 [~.p q=182]]
                  [%cross-3 [~.t q=27.915.996.575.527.523]]
                  ==
          :-  %vector
              :~  [%year [~.ud q=2.023]]
                  [%month [~.ud q=12]]
                  [%day [~.ud q=31]]
                  [%month-name [~.t q=8.243.102.914.963.531.076]]
                  [%cross-key [~.ud q=3]]
                  [%cross-2 [~.p q=182]]
                  [%cross-3 [~.t q=27.915.996.575.527.523]]
                  ==
          :-  %vector
              :~  [%year [~.ud q=2.023]]
                  [%month [~.ud q=12]]
                  [%day [~.ud q=27]]
                  [%month-name [~.t q=8.243.102.914.963.531.076]]
                  [%cross-key [~.ud q=1]]
                  [%cross-2 [~.p q=1.624.961.343]]
                  [%cross-3 [~.t q=27.353.046.622.106.211]]
                  ==
          :-  %vector
              :~  [%year [~.ud q=2.023]]
                  [%month [~.ud q=12]]
                  [%day [~.ud q=26]]
                  [%month-name [~.t q=8.243.102.914.963.531.076]]
                  [%cross-key [~.ud q=3]]
                  [%cross-2 [~.p q=182]]
                  [%cross-3 [~.t q=27.915.996.575.527.523]]
                  ==
          :-  %vector
              :~  [%year [~.ud q=2.023]]
                  [%month [~.ud q=12]]
                  [%day [~.ud q=21]]
                  [%month-name [~.t q=8.243.102.914.963.531.076]]
                  [%cross-key [~.ud q=2]]
                  [%cross-2 [~.p q=1]]
                  [%cross-3 [~.t q=27.634.521.598.816.867]]
                  ==
          :-  %vector
              :~  [%year [~.ud q=2.023]]
                  [%month [~.ud q=12]]
                  [%day [~.ud q=22]]
                  [%month-name [~.t q=8.243.102.914.963.531.076]]
                  [%cross-key [~.ud q=1]]
                  [%cross-2 [~.p q=1.624.961.343]]
                  [%cross-3 [~.t q=27.353.046.622.106.211]]
                  ==
          :-  %vector
              :~  [%year [~.ud q=2.023]]
                  [%month [~.ud q=12]]
                  [%day [~.ud q=28]]
                  [%month-name [~.t q=8.243.102.914.963.531.076]]
                  [%cross-key [~.ud q=2]]
                  [%cross-2 [~.p q=1]]
                  [%cross-3 [~.t q=27.634.521.598.816.867]]
                  ==
          :-  %vector
              :~  [%year [~.ud q=2.023]]
                  [%month [~.ud q=12]]
                  [%day [~.ud q=30]]
                  [%month-name [~.t q=8.243.102.914.963.531.076]]
                  [%cross-key [~.ud q=2]]
                  [%cross-2 [~.p q=1]]
                  [%cross-3 [~.t q=27.634.521.598.816.867]]
                  ==
          :-  %vector
              :~  [%year [~.ud q=2.023]]
                  [%month [~.ud q=12]]
                  [%day [~.ud q=26]]
                  [%month-name [~.t q=8.243.102.914.963.531.076]]
                  [%cross-key [~.ud q=2]]
                  [%cross-2 [~.p q=1]]
                  [%cross-3 [~.t q=27.634.521.598.816.867]]
                  ==
          :-  %vector
              :~  [%year [~.ud q=2.023]]
                  [%month [~.ud q=12]]
                  [%day [~.ud q=29]]
                  [%month-name [~.t q=8.243.102.914.963.531.076]]
                  [%cross-key [~.ud q=1]]
                  [%cross-2 [~.p q=1.624.961.343]]
                  [%cross-3 [~.t q=27.353.046.622.106.211]]
                  ==
          :-  %vector
              :~  [%year [~.ud q=2.023]]
                  [%month [~.ud q=12]]
                  [%day [~.ud q=28]]
                  [%month-name [~.t q=8.243.102.914.963.531.076]]
                  [%cross-key [~.ud q=3]]
                  [%cross-2 [~.p q=182]]
                  [%cross-3 [~.t q=27.915.996.575.527.523]]
                  ==
          :-  %vector
              :~  [%year [~.ud q=2.023]]
                  [%month [~.ud q=12]]
                  [%day [~.ud q=24]]
                  [%month-name [~.t q=8.243.102.914.963.531.076]]
                  [%cross-key [~.ud q=2]]
                  [%cross-2 [~.p q=1]]
                  [%cross-3 [~.t q=27.634.521.598.816.867]]
                  ==
          :-  %vector
              :~  [%year [~.ud q=2.023]]
                  [%month [~.ud q=12]]
                  [%day [~.ud q=24]]
                  [%month-name [~.t q=8.243.102.914.963.531.076]]
                  [%cross-key [~.ud q=3]]
                  [%cross-2 [~.p q=182]]
                  [%cross-3 [~.t q=27.915.996.575.527.523]]
                  ==
          :-  %vector
              :~  [%year [~.ud q=2.023]]
                  [%month [~.ud q=12]]
                  [%day [~.ud q=22]]
                  [%month-name [~.t q=8.243.102.914.963.531.076]]
                  [%cross-key [~.ud q=3]]
                  [%cross-2 [~.p q=182]]
                  [%cross-3 [~.t q=27.915.996.575.527.523]]
                  ==
          :-  %vector
              :~  [%year [~.ud q=2.023]]
                  [%month [~.ud q=12]]
                  [%day [~.ud q=29]]
                  [%month-name [~.t q=8.243.102.914.963.531.076]]
                  [%cross-key [~.ud q=3]]
                  [%cross-2 [~.p q=182]]
                  [%cross-3 [~.t q=27.915.996.575.527.523]]
                  ==
          :-  %vector
              :~  [%year [~.ud q=2.023]]
                  [%month [~.ud q=12]]
                  [%day [~.ud q=23]]
                  [%month-name [~.t q=8.243.102.914.963.531.076]]
                  [%cross-key [~.ud q=1]]
                  [%cross-2 [~.p q=1.624.961.343]]
                  [%cross-3 [~.t q=27.353.046.622.106.211]]
                  ==
          :-  %vector
              :~  [%year [~.ud q=2.023]]
                  [%month [~.ud q=12]]
                  [%day [~.ud q=21]]
                  [%month-name [~.t q=8.243.102.914.963.531.076]]
                  [%cross-key [~.ud q=1]]
                  [%cross-2 [~.p q=1.624.961.343]]
                  [%cross-3 [~.t q=27.353.046.622.106.211]]
                  ==
          :-  %vector
              :~  [%year [~.ud q=2.023]]
                  [%month [~.ud q=12]]
                  [%day [~.ud q=21]]
                  [%month-name [~.t q=8.243.102.914.963.531.076]]
                  [%cross-key [~.ud q=3]]
                  [%cross-2 [~.p q=182]]
                  [%cross-3 [~.t q=27.915.996.575.527.523]]
                  ==
          :-  %vector
              :~  [%year [~.ud q=2.023]]
                  [%month [~.ud q=12]]
                  [%day [~.ud q=27]]
                  [%month-name [~.t q=8.243.102.914.963.531.076]]
                  [%cross-key [~.ud q=2]]
                  [%cross-2 [~.p q=1]]
                  [%cross-3 [~.t q=27.634.521.598.816.867]]
                  ==
          :-  %vector
              :~  [%year [~.ud q=2.023]]
                  [%month [~.ud q=12]]
                  [%day [~.ud q=26]]
                  [%month-name [~.t q=8.243.102.914.963.531.076]]
                  [%cross-key [~.ud q=1]]
                  [%cross-2 [~.p q=1.624.961.343]]
                  [%cross-3 [~.t q=27.353.046.622.106.211]]
                  ==
          :-  %vector
              :~  [%year [~.ud q=2.023]]
                  [%month [~.ud q=12]]
                  [%day [~.ud q=22]]
                  [%month-name [~.t q=8.243.102.914.963.531.076]]
                  [%cross-key [~.ud q=2]]
                  [%cross-2 [~.p q=1]]
                  [%cross-3 [~.t q=27.634.521.598.816.867]]
                  ==
          :-  %vector
              :~  [%year [~.ud q=2.023]]
                  [%month [~.ud q=12]]
                  [%day [~.ud q=27]]
                  [%month-name [~.t q=8.243.102.914.963.531.076]]
                  [%cross-key [~.ud q=3]]
                  [%cross-2 [~.p q=182]]
                  [%cross-3 [~.t q=27.915.996.575.527.523]]
                  ==
          :-  %vector
              :~  [%year [~.ud q=2.023]]
                  [%month [~.ud q=12]]
                  [%day [~.ud q=25]]
                  [%month-name [~.t q=8.243.102.914.963.531.076]]
                  [%cross-key [~.ud q=1]]
                  [%cross-2 [~.p q=1.624.961.343]]
                  [%cross-3 [~.t q=27.353.046.622.106.211]]
                  ==
          :-  %vector
              :~  [%year [~.ud q=2.023]]
                  [%month [~.ud q=12]]
                  [%day [~.ud q=24]]
                  [%month-name [~.t q=8.243.102.914.963.531.076]]
                  [%cross-key [~.ud q=1]]
                  [%cross-2 [~.p q=1.624.961.343]]
                  [%cross-3 [~.t q=27.353.046.622.106.211]]
                  ==
          :-  %vector
              :~  [%year [~.ud q=2.023]]
                  [%month [~.ud q=12]]
                  [%day [~.ud q=30]]
                  [%month-name [~.t q=8.243.102.914.963.531.076]]
                  [%cross-key [~.ud q=1]]
                  [%cross-2 [~.p q=1.624.961.343]]
                  [%cross-3 [~.t q=27.353.046.622.106.211]]
                  ==
          :-  %vector
             :~  [%year [~.ud q=2.023]]
                  [%month [~.ud q=12]]
                  [%day [~.ud q=25]]
                  [%month-name [~.t q=8.243.102.914.963.531.076]]
                  [%cross-key [~.ud q=3]]
                  [%cross-2 [~.p q=182]]
                  [%cross-3 [~.t q=27.915.996.575.527.523]]
                  ==
          :-  %vector
              :~  [%year [~.ud q=2.023]]
                  [%month [~.ud q=12]]
                  [%day [~.ud q=28]]
                  [%month-name [~.t q=8.243.102.914.963.531.076]]
                  [%cross-key [~.ud q=1]]
                  [%cross-2 [~.p q=1.624.961.343]]
                  [%cross-3 [~.t q=27.353.046.622.106.211]]
                  ==
          ==
++  expected-natural-cross-rows
        :~  :-  %vector
                :~  [%row-name [~.t 'row-3']]
                    [%day-name [~.t 'Monday']]
                    [%date [~.da ~2023.12.25]]
                    [%us-federal-holiday [~.t 'Christmas Day']]
                    [%date [~.da ~2023.12.25]]
                    [%year [~.ud 2.023]]
                    [%month [~.ud 12]]
                    [%day [~.ud 25]]
                    [%row-name [~.t 'row-3']]
                    [%cross-key [~.ud 1]]
                    [%cross-2 [~.p ~sampel-palnet]]
                    [%cross-3 [~.t 'cross-a']]
                    ==
            :-  %vector
                :~  [%row-name [~.t 'row-7']]
                    [%day-name [~.t 'Monday']]
                    [%date [~.da ~2024.1.1]]
                    [%us-federal-holiday [~.t 'New Years Day']]
                    [%date [~.da ~2024.1.1]]
                    [%year [~.ud 2.024]]
                    [%month [~.ud 1]]
                    [%day [~.ud 1]]
                    [%row-name [~.t 'row-7']]
                    [%cross-key [~.ud 1]]
                    [%cross-2 [~.p ~sampel-palnet]]
                    [%cross-3 [~.t 'cross-a']]
                    ==
            :-  %vector
                :~  [%row-name [~.t 'row-3']]
                    [%day-name [~.t 'Monday']]
                    [%date [~.da ~2023.12.25]]
                    [%us-federal-holiday [~.t 'Christmas Day']]
                    [%date [~.da ~2023.12.25]]
                    [%year [~.ud 2.023]]
                    [%month [~.ud 12]]
                    [%day [~.ud 25]]
                    [%row-name [~.t 'row-3']]
                    [%cross-key [~.ud 2]]
                    [%cross-2 [~.p ~nec]]
                    [%cross-3 [~.t 'cross-b']]
                    ==
            :-  %vector
                :~  [%row-name [~.t 'row-7']]
                    [%day-name [~.t 'Monday']]
                    [%date [~.da ~2024.1.1]]
                    [%us-federal-holiday [~.t 'New Years Day']]
                    [%date [~.da ~2024.1.1]]
                    [%year [~.ud 2.024]]
                    [%month [~.ud 1]]
                    [%day [~.ud 1]]
                    [%row-name [~.t 'row-7']]
                    [%cross-key [~.ud 2]]
                    [%cross-2 [~.p ~nec]]
                    [%cross-3 [~.t 'cross-b']]
                    ==
            :-  %vector
                :~  [%row-name [~.t 'row-3']]
                    [%day-name [~.t 'Monday']]
                    [%date [~.da ~2023.12.25]]
                    [%us-federal-holiday [~.t 'Christmas Day']]
                    [%date [~.da ~2023.12.25]]
                    [%year [~.ud 2.023]]
                    [%month [~.ud 12]]
                    [%day [~.ud 25]]
                    [%row-name [~.t 'row-3']]
                    [%cross-key [~.ud 3]]
                    [%cross-2 [~.p ~bus]]
                    [%cross-3 [~.t 'cross-c']]
                    ==
            :-  %vector
                :~  [%row-name [~.t 'row-7']]
                    [%day-name [~.t 'Monday']]
                    [%date [~.da ~2024.1.1]]
                    [%us-federal-holiday [~.t 'New Years Day']]
                    [%date [~.da ~2024.1.1]]
                    [%year [~.ud 2.024]]
                    [%month [~.ud 1]]
                    [%day [~.ud 1]]
                    [%row-name [~.t 'row-7']]
                    [%cross-key [~.ud 3]]
                    [%cross-2 [~.p ~bus]]
                    [%cross-3 [~.t 'cross-c']]
                    ==
            ==
++  expected-cross-aliased-rows
      :~  :-  %vector
              :~  [%year [~.ud q=2.023]]
                  [%month-name [~.t q='August']]
                  [%literal-2 [~.t q='cross joining']]
                  [%cross-key [~.ud q=1]]
                  [%cross-2 [~.p q=~sampel-palnet]]
                  ==
          :-  %vector
              :~  [%year [~.ud q=2.023]]
                  [%month-name [~.t q='August']]
                  [%literal-2 [~.t q='cross joining']]
                  [%cross-key [~.ud q=2]]
                  [%cross-2 [~.p q=~nec]]
                  ==
          :-  %vector
              :~  [%year [~.ud q=2.023]]
                  [%month-name [~.t q='August']]
                  [%literal-2 [~.t q='cross joining']]
                  [%cross-key [~.ud q=3]]
                  [%cross-2 [~.p q=~bus]]
                  ==
          :-  %vector
              :~  [%year [~.ud q=2.023]]
                  [%month-name [~.t q='August']]
                  [%literal-2 [~.t q='cross joining']]
                  [%cross-key [~.ud q=4]]
                  [%cross-2 [~.p q=~sev]]
                  ==
          :-  %vector
              :~  [%year [~.ud q=2.023]]
                  [%month-name [~.t q='September']]
                  [%literal-2 [~.t q='cross joining']]
                  [%cross-key [~.ud q=1]]
                  [%cross-2 [~.p q=~sampel-palnet]]
                  ==
          :-  %vector
              :~  [%year [~.ud q=2.023]]
                  [%month-name [~.t q='September']]
                  [%literal-2 [~.t q='cross joining']]
                  [%cross-key [~.ud q=2]]
                  [%cross-2 [~.p q=~nec]]
                  ==
          :-  %vector
              :~  [%year [~.ud q=2.023]]
                  [%month-name [~.t q='September']]
                  [%literal-2 [~.t q='cross joining']]
                  [%cross-key [~.ud q=3]]
                  [%cross-2 [~.p q=~bus]]
                  ==
          :-  %vector
              :~  [%year [~.ud q=2.023]]
                  [%month-name [~.t q='September']]
                  [%literal-2 [~.t q='cross joining']]
                  [%cross-key [~.ud q=4]]
                  [%cross-2 [~.p q=~sev]]
                  ==
          :-  %vector
              :~  [%year [~.ud q=2.023]]
                  [%month-name [~.t q='October']]
                  [%literal-2 [~.t q='cross joining']]
                  [%cross-key [~.ud q=1]]
                  [%cross-2 [~.p q=~sampel-palnet]]
                  ==
          :-  %vector
              :~  [%year [~.ud q=2.023]]
                  [%month-name [~.t q='October']]
                  [%literal-2 [~.t q='cross joining']]
                  [%cross-key [~.ud q=2]]
                  [%cross-2 [~.p q=~nec]]
                  ==
          :-  %vector
              :~  [%year [~.ud q=2.023]]
                  [%month-name [~.t q='October']]
                  [%literal-2 [~.t q='cross joining']]
                  [%cross-key [~.ud q=3]]
                  [%cross-2 [~.p q=~bus]]
                  ==
          :-  %vector
              :~  [%year [~.ud q=2.023]]
                  [%month-name [~.t q='October']]
                  [%literal-2 [~.t q='cross joining']]
                  [%cross-key [~.ud q=4]]
                  [%cross-2 [~.p q=~sev]]
                  ==
          :-  %vector
              :~  [%year [~.ud q=2.023]]
                  [%month-name [~.t q='November']]
                  [%literal-2 [~.t q='cross joining']]
                  [%cross-key [~.ud q=1]]
                  [%cross-2 [~.p q=~sampel-palnet]]
                  ==
          :-  %vector
              :~  [%year [~.ud q=2.023]]
                  [%month-name [~.t q='November']]
                  [%literal-2 [~.t q='cross joining']]
                  [%cross-key [~.ud q=2]]
                  [%cross-2 [~.p q=~nec]]
                  ==
          :-  %vector
              :~  [%year [~.ud q=2.023]]
                  [%month-name [~.t q='November']]
                  [%literal-2 [~.t q='cross joining']]
                  [%cross-key [~.ud q=3]]
                  [%cross-2 [~.p q=~bus]]
                  ==
          :-  %vector
              :~  [%year [~.ud q=2.023]]
                  [%month-name [~.t q='November']]
                  [%literal-2 [~.t q='cross joining']]
                  [%cross-key [~.ud q=4]]
                  [%cross-2 [~.p q=~sev]]
                  ==
          :-  %vector
              :~  [%year [~.ud q=2.023]]
                  [%month-name [~.t q='December']]
                  [%literal-2 [~.t q='cross joining']]
                  [%cross-key [~.ud q=1]]
                  [%cross-2 [~.p q=~sampel-palnet]]
                  ==
          :-  %vector
              :~  [%year [~.ud q=2.023]]
                  [%month-name [~.t q='December']]
                  [%literal-2 [~.t q='cross joining']]
                  [%cross-key [~.ud q=2]]
                  [%cross-2 [~.p q=~nec]]
                  ==
          :-  %vector
              :~  [%year [~.ud q=2.023]]
                  [%month-name [~.t q='December']]
                  [%literal-2 [~.t q='cross joining']]
                  [%cross-key [~.ud q=3]]
                  [%cross-2 [~.p q=~bus]]
                  ==
          :-  %vector
              :~  [%year [~.ud q=2.023]]
                  [%month-name [~.t q='December']]
                  [%literal-2 [~.t q='cross joining']]
                  [%cross-key [~.ud q=4]]
                  [%cross-2 [~.p q=~sev]]
                  ==
          ==
++  expected-cross-as-of-rows
      :~  :-  %vector
              :~  [%year [~.ud q=2.023]]
                  [%month-name [~.t q='August']]
                  [%literal-2 [~.t q='cross joining']]
                  [%cross-key [~.ud q=1]]
                  [%cross-2 [~.p q=~sampel-palnet]]
                  ==
          :-  %vector
              :~  [%year [~.ud q=2.023]]
                  [%month-name [~.t q='August']]
                  [%literal-2 [~.t q='cross joining']]
                  [%cross-key [~.ud q=2]]
                  [%cross-2 [~.p q=~nec]]
                  ==
          :-  %vector
              :~  [%year [~.ud q=2.023]]
                  [%month-name [~.t q='August']]
                  [%literal-2 [~.t q='cross joining']]
                  [%cross-key [~.ud q=3]]
                  [%cross-2 [~.p q=~bus]]
                  ==
          :-  %vector
              :~  [%year [~.ud q=2.023]]
                  [%month-name [~.t q='September']]
                  [%literal-2 [~.t q='cross joining']]
                  [%cross-key [~.ud q=1]]
                  [%cross-2 [~.p q=~sampel-palnet]]
                  ==
          :-  %vector
              :~  [%year [~.ud q=2.023]]
                  [%month-name [~.t q='September']]
                  [%literal-2 [~.t q='cross joining']]
                  [%cross-key [~.ud q=2]]
                  [%cross-2 [~.p q=~nec]]
                  ==
          :-  %vector
              :~  [%year [~.ud q=2.023]]
                  [%month-name [~.t q='September']]
                  [%literal-2 [~.t q='cross joining']]
                  [%cross-key [~.ud q=3]]
                  [%cross-2 [~.p q=~bus]]
                  ==
          :-  %vector
              :~  [%year [~.ud q=2.023]]
                  [%month-name [~.t q='October']]
                  [%literal-2 [~.t q='cross joining']]
                  [%cross-key [~.ud q=1]]
                  [%cross-2 [~.p q=~sampel-palnet]]
                  ==
          :-  %vector
              :~  [%year [~.ud q=2.023]]
                  [%month-name [~.t q='October']]
                  [%literal-2 [~.t q='cross joining']]
                  [%cross-key [~.ud q=2]]
                  [%cross-2 [~.p q=~nec]]
                  ==
          :-  %vector
              :~  [%year [~.ud q=2.023]]
                  [%month-name [~.t q='October']]
                  [%literal-2 [~.t q='cross joining']]
                  [%cross-key [~.ud q=3]]
                  [%cross-2 [~.p q=~bus]]
                  ==
          :-  %vector
              :~  [%year [~.ud q=2.023]]
                  [%month-name [~.t q='November']]
                  [%literal-2 [~.t q='cross joining']]
                  [%cross-key [~.ud q=1]]
                  [%cross-2 [~.p q=~sampel-palnet]]
                  ==
          :-  %vector
              :~  [%year [~.ud q=2.023]]
                  [%month-name [~.t q='November']]
                  [%literal-2 [~.t q='cross joining']]
                  [%cross-key [~.ud q=2]]
                  [%cross-2 [~.p q=~nec]]
                  ==
          :-  %vector
              :~  [%year [~.ud q=2.023]]
                  [%month-name [~.t q='November']]
                  [%literal-2 [~.t q='cross joining']]
                  [%cross-key [~.ud q=3]]
                  [%cross-2 [~.p q=~bus]]
                  ==
          :-  %vector
              :~  [%year [~.ud q=2.023]]
                  [%month-name [~.t q='December']]
                  [%literal-2 [~.t q='cross joining']]
                  [%cross-key [~.ud q=1]]
                  [%cross-2 [~.p q=~sampel-palnet]]
                  ==
          :-  %vector
              :~  [%year [~.ud q=2.023]]
                  [%month-name [~.t q='December']]
                  [%literal-2 [~.t q='cross joining']]
                  [%cross-key [~.ud q=2]]
                  [%cross-2 [~.p q=~nec]]
                  ==
          :-  %vector
              :~  [%year [~.ud q=2.023]]
                  [%month-name [~.t q='December']]
                  [%literal-2 [~.t q='cross joining']]
                  [%cross-key [~.ud q=3]]
                  [%cross-2 [~.p q=~bus]]
                  ==
          ==
++  expected-cross
      :~  %results
          [%action 'SELECT']
          [%result-set expected-cross-rows]
          [%server-time ~2012.5.3]
          [%relation 'db1.dbo.cross']
          [%schema-time ~2012.4.30]
          [%data-time ~2012.4.30]
          [%relation 'db1.dbo.tbl1']
          [%schema-time ~2012.4.30]
          [%data-time ~2012.4.30]
          [%vector-count 33]
          ==
++  expected-cross-aliased
      :~  %results
          [%action 'SELECT']
          [%result-set expected-cross-aliased-rows]
          [%server-time ~2012.5.3]
          [%relation 'db1.dbo.cross']
          [%schema-time ~2012.4.30]
          [%data-time ~2012.5.2]
          [%relation 'db1.dbo.tbl1']
          [%schema-time ~2012.4.30]
          [%data-time ~2012.4.30]
          [%vector-count 20]
          ==
++  expected-cross-as-of
      :~  %results
          [%action 'SELECT']
          [%result-set expected-cross-as-of-rows]
          [%server-time ~2012.5.4]
          [%relation 'db1.dbo.cross']
          [%schema-time ~2012.4.30]
          [%data-time ~2012.4.30]
          [%relation 'db1.dbo.tbl1']
          [%schema-time ~2012.4.30]
          [%data-time ~2012.4.30]
          [%vector-count 15]
          ==
::
::  test T1.* in select, all rows join
++  test-join-00
  =|  run=@ud
  %-  exec-0-1
  :*  run
      :+  ~2012.4.30
          %db1
          %-  zing  :~  "CREATE DATABASE db1;"
                        create-calendar
                        insert-calendar
                        create-holiday-calendar
                        insert-holiday-calendar
                        ==
      ::
      :+  ~2012.5.3
          %db1
          "FROM calendar T1 ".
          "JOIN holiday-calendar T2 ".
          "SELECT T1.day-name, T2.*"
      ::
      :-  %results
          :~  [%action 'SELECT']
              :-  %result-set
                  :~  :-  %vector
                          :~  [%day-name [~.t 'Monday']]
                              [%date [~.da ~2023.12.25]]
                              [%us-federal-holiday [~.t 'Christmas Day']]
                              ==
                      :-  %vector
                          :~  [%day-name [~.t 'Monday']]
                              [%date [~.da ~2024.1.1]]
                              [%us-federal-holiday [~.t 'New Years Day']]
                              ==
                      ==
              [%server-time ~2012.5.3]
              [%relation 'db1.dbo.calendar']
              [%schema-time ~2012.4.30]
              [%data-time ~2012.4.30]
              [%relation 'db1.dbo.holiday-calendar']
              [%schema-time ~2012.4.30]
              [%data-time ~2012.4.30]
              [%vector-count 2]
              ==
      ==
::
::  test T1.* in select
++  test-join-01
  =|  run=@ud
  %-  exec-0-1
  :*  run
      :+  ~2012.4.30
          %db1
          %-  zing  :~  "CREATE DATABASE db1;"
                        create-calendar
                        insert-calendar
                        create-holiday-calendar
                        insert-holiday-calendar
                        ==
      ::
      :+  ~2012.5.3
          %db1
          "FROM calendar T1 ".
          "JOIN holiday-calendar T2 ".
          "SELECT T1.day-name, T2.*"
      ::
      :-  %results
          :~  [%action 'SELECT']
              :-  %result-set
                  :~  :-  %vector
                          :~  [%day-name [~.t 'Monday']]
                              [%date [~.da ~2023.12.25]]
                              [%us-federal-holiday [~.t 'Christmas Day']]
                              ==
                      :-  %vector
                          :~  [%day-name [~.t 'Monday']]
                              [%date [~.da ~2024.1.1]]
                              [%us-federal-holiday [~.t 'New Years Day']]
                              ==
                      ==
              [%server-time ~2012.5.3]
              [%relation 'db1.dbo.calendar']
              [%schema-time ~2012.4.30]
              [%data-time ~2012.4.30]
              [%relation 'db1.dbo.holiday-calendar']
              [%schema-time ~2012.4.30]
              [%data-time ~2012.4.30]
              [%vector-count 2]
              ==
      ==
::
::  test T1.* in select, tables inverted
++  test-join-02
  =|  run=@ud
  %-  exec-0-1
  :*  run
      :+  ~2012.4.30
          %db1
          %-  zing  :~  "CREATE DATABASE db1;"
                        create-calendar
                        insert-calendar
                        create-holiday-calendar
                        insert-holiday-calendar
                        ==
      ::
      :+  ~2012.5.3
          %db1
          "FROM holiday-calendar T1 ".
          "JOIN calendar T2 ".
          "SELECT T2.day-name, T1.*"
      ::
      :-  %results
          :~  [%action 'SELECT']
              :-  %result-set
                  :~  :-  %vector
                          :~  [%day-name [~.t 'Monday']]
                              [%date [~.da ~2023.12.25]]
                              [%us-federal-holiday [~.t 'Christmas Day']]
                              ==
                      :-  %vector
                          :~  [%day-name [~.t 'Monday']]
                              [%date [~.da ~2024.1.1]]
                              [%us-federal-holiday [~.t 'New Years Day']]
                              ==
                      ==
              [%server-time ~2012.5.3]
              [%relation 'db1.dbo.calendar']
              [%schema-time ~2012.4.30]
              [%data-time ~2012.4.30]
              [%relation 'db1.dbo.holiday-calendar']
              [%schema-time ~2012.4.30]
              [%data-time ~2012.4.30]
              [%vector-count 2]
              ==
      ==
::
::  test alternating file alias case
++  test-join-03
  =|  run=@ud
  %-  exec-0-1
  :*  run
      :+  ~2012.4.30
          %db1
          %-  zing  :~  "CREATE DATABASE db1;"
                        create-calendar
                        insert-calendar
                        create-holiday-calendar
                        insert-holiday-calendar
                        ==
      ::
      :+  ~2012.5.3
          %db1
          "FROM calendar t1 ".
          "JOIN holiday-calendar T2 ".
          "SELECT T1.day-name, t2.*, t2.us-federal-holiday"
      ::
      :-  %results
          :~  [%action 'SELECT']
              :-  %result-set
                  :~  :-  %vector
                          :~  [%day-name [~.t 'Monday']]
                              [%date [~.da ~2023.12.25]]
                              [%us-federal-holiday [~.t 'Christmas Day']]
                              [%us-federal-holiday [~.t 'Christmas Day']]
                              ==
                      :-  %vector
                          :~  [%day-name [~.t 'Monday']]
                              [%date [~.da ~2024.1.1]]
                              [%us-federal-holiday [~.t 'New Years Day']]
                              [%us-federal-holiday [~.t 'New Years Day']]
                              ==
                      ==
              [%server-time ~2012.5.3]
              [%relation 'db1.dbo.calendar']
              [%schema-time ~2012.4.30]
              [%data-time ~2012.4.30]
              [%relation 'db1.dbo.holiday-calendar']
              [%schema-time ~2012.4.30]
              [%data-time ~2012.4.30]
              [%vector-count 2]
              ==
      ==
::  test alternating file alias case, tables inverted
++  test-join-04
  =|  run=@ud
  %-  exec-0-1
  :*  run
      :+  ~2012.4.30
          %db1
          %-  zing  :~  "CREATE DATABASE db1;"
                        create-calendar
                        insert-calendar
                        create-holiday-calendar
                        insert-holiday-calendar
                        ==
      ::
      :+  ~2012.5.3
          %db1
          "FROM holiday-calendar t1 ".
          "JOIN calendar T2 ".
          "SELECT T2.day-name, t1.*, t1.us-federal-holiday"
      ::
      :-  %results
          :~  [%action 'SELECT']
              :-  %result-set
                  :~  :-  %vector
                          :~  [%day-name [~.t 'Monday']]
                              [%date [~.da ~2023.12.25]]
                              [%us-federal-holiday [~.t 'Christmas Day']]
                              [%us-federal-holiday [~.t 'Christmas Day']]
                              ==
                      :-  %vector
                          :~  [%day-name [~.t 'Monday']]
                              [%date [~.da ~2024.1.1]]
                              [%us-federal-holiday [~.t 'New Years Day']]
                              [%us-federal-holiday [~.t 'New Years Day']]
                              ==
                      ==
              [%server-time ~2012.5.3]
              [%relation 'db1.dbo.calendar']
              [%schema-time ~2012.4.30]
              [%data-time ~2012.4.30]
              [%relation 'db1.dbo.holiday-calendar']
              [%schema-time ~2012.4.30]
              [%data-time ~2012.4.30]
              [%vector-count 2]
              ==
      ==
::
::  test alternating file alias case in predicate
++  test-join-05
  =|  run=@ud
  %-  exec-0-1
  :*  run
      :+  ~2012.4.30
          %db1
          %-  zing  :~  "CREATE DATABASE db1;"
                        create-calendar
                        insert-calendar
                        create-holiday-calendar
                        insert-holiday-calendar
                        ==
      ::
      :+  ~2012.5.3
          %db1
          "FROM calendar t1 ".
          "JOIN holiday-calendar T2 ".
          "WHERE T1.day-name = 'Monday' ".
          "  AND t2.us-federal-holiday = 'Christmas Day' ".
          "SELECT T1.day-name, t2.*, t2.us-federal-holiday"
      ::
      :-  %results
          :~  [%action 'SELECT']
              :-  %result-set
                  :~  :-  %vector
                          :~  [%day-name [~.t 'Monday']]
                              [%date [~.da ~2023.12.25]]
                              [%us-federal-holiday [~.t 'Christmas Day']]
                              [%us-federal-holiday [~.t 'Christmas Day']]
                              ==
                      ==
              [%server-time ~2012.5.3]
              [%relation 'db1.dbo.calendar']
              [%schema-time ~2012.4.30]
              [%data-time ~2012.4.30]
              [%relation 'db1.dbo.holiday-calendar']
              [%schema-time ~2012.4.30]
              [%data-time ~2012.4.30]
              [%vector-count 1]
              ==
      ==
::
::  test alternating file alias case in predicate, tables inverted
++  test-join-06
  =|  run=@ud
  %-  exec-0-1
  :*  run
      :+  ~2012.4.30
          %db1
          %-  zing  :~  "CREATE DATABASE db1;"
                        create-calendar
                        insert-calendar
                        create-holiday-calendar
                        insert-holiday-calendar
                        ==
      ::
      :+  ~2012.5.3
          %db1
          "FROM holiday-calendar t1 ".
          "JOIN calendar T2 ".
          "WHERE T2.day-name = 'Monday' ".
          "  AND t1.us-federal-holiday = 'Christmas Day' ".
          "SELECT T2.day-name, t1.*, t1.us-federal-holiday"
      ::
      :-  %results
          :~  [%action 'SELECT']
              :-  %result-set
                  :~  :-  %vector
                          :~  [%day-name [~.t 'Monday']]
                              [%date [~.da ~2023.12.25]]
                              [%us-federal-holiday [~.t 'Christmas Day']]
                              [%us-federal-holiday [~.t 'Christmas Day']]
                              ==
                      ==
              [%server-time ~2012.5.3]
              [%relation 'db1.dbo.calendar']
              [%schema-time ~2012.4.30]
              [%data-time ~2012.4.30]
              [%relation 'db1.dbo.holiday-calendar']
              [%schema-time ~2012.4.30]
              [%data-time ~2012.4.30]
              [%vector-count 1]
              ==
      ==
::
::  test mixed column alias case in predicate
++  test-join-07
  =|  run=@ud
  %-  exec-0-1
  :*  run
      :+  ~2012.4.30
          %db1
          %-  zing  :~  "CREATE DATABASE db1;"
                        create-calendar
                        insert-calendar
                        create-holiday-calendar
                        insert-holiday-calendar
                        ==
      ::
      :+  ~2012.5.3
          %db1
          "FROM calendar t1 ".
          "JOIN holiday-calendar T2 ".
          "WHERE T1.day-name = 'Monday' ".
          "  AND t2.us-federal-holiday = 'Christmas Day' ".
          "SELECT T1.day-name AS Day, t2.us-federal-holiday"
      ::
      :-  %results
          :~  [%action 'SELECT']
              :-  %result-set
                  :~  :-  %vector
                          :~  [%day [~.t 'Monday']]
                              [%us-federal-holiday [~.t 'Christmas Day']]
                              ==
                      ==
              [%server-time ~2012.5.3]
              [%relation 'db1.dbo.calendar']
              [%schema-time ~2012.4.30]
              [%data-time ~2012.4.30]
              [%relation 'db1.dbo.holiday-calendar']
              [%schema-time ~2012.4.30]
              [%data-time ~2012.4.30]
              [%vector-count 1]
              ==
      ==
::
::  test mixed column alias case in predicate, tables inverted
++  test-join-08
  =|  run=@ud
  %-  exec-0-1
  :*  run
      :+  ~2012.4.30
          %db1
          %-  zing  :~  "CREATE DATABASE db1;"
                        create-calendar
                        insert-calendar
                        create-holiday-calendar
                        insert-holiday-calendar
                        ==
      ::
      :+  ~2012.5.3
          %db1
          "FROM holiday-calendar t1 ".
          "JOIN calendar T2 ".
          "WHERE T2.day-name = 'Monday' ".
          "  AND t1.us-federal-holiday = 'Christmas Day' ".
          "SELECT T2.day-name AS Day, t1.us-federal-holiday"
      ::
      :-  %results
          :~  [%action 'SELECT']
              :-  %result-set
                  :~  :-  %vector
                          :~  [%day [~.t 'Monday']]
                              [%us-federal-holiday [~.t 'Christmas Day']]
                              ==
                      ==
              [%server-time ~2012.5.3]
              [%relation 'db1.dbo.calendar']
              [%schema-time ~2012.4.30]
              [%data-time ~2012.4.30]
              [%relation 'db1.dbo.holiday-calendar']
              [%schema-time ~2012.4.30]
              [%data-time ~2012.4.30]
              [%vector-count 1]
              ==
      ==
::
::  join multi-column keys, all rows join
++  test-join-09
  =|  run=@ud
  %-  exec-0-2
  :*  run
      :+  ~2012.4.30
          %db1
          %-  zing  :~  "CREATE DATABASE db1;"
                        create-tbl1
                        insert-tbl1
                        "CREATE TABLE tbl2 ".
                        "(year        @ud,".
                        " month       @ud,".
                        " day         @ud,".
                        " day-name  @t)".
                        "  PRIMARY KEY (year, month, day);"
                        insert-tbl2
                        ==
      ::
      :+  ~2012.5.3
          %db1
          "FROM tbl1 t1 ".
          "JOIN tbl2 T2 ".
          "SELECT T1.year, T2.month, T1.day, month-name, day-name"
      ::
      :+  ~2012.5.3
          %db1
          "FROM tbl1 t1 ".
          "JOIN tbl2 T2 ".
          "WHERE day-name = 'Monday' ".
          "SELECT T1.year, T2.month, T1.day, month-name, day-name"
      ::
      :-  %results
          :~  [%action 'SELECT']
              [%result-set expect-rows-1]
              [%server-time ~2012.5.3]
              [%relation 'db1.dbo.tbl1']
              [%schema-time ~2012.4.30]
              [%data-time ~2012.4.30]
              [%relation 'db1.dbo.tbl2']
              [%schema-time ~2012.4.30]
              [%data-time ~2012.4.30]
              [%vector-count 32]
              ==
      ::
      :-  %results
          :~  [%action 'SELECT']
              [%result-set expect-rows-2]
              [%server-time ~2012.5.3]
              [%relation 'db1.dbo.tbl1']
              [%schema-time ~2012.4.30]
              [%data-time ~2012.4.30]
              [%relation 'db1.dbo.tbl2']
              [%schema-time ~2012.4.30]
              [%data-time ~2012.4.30]
              [%vector-count 6]
              ==
      ==
::
::  join multi-column keys
++  test-join-10
  =|  run=@ud
  %-  exec-0-2
  :*  run
      :+  ~2012.4.30
          %db1
          %-  zing  :~  "CREATE DATABASE db1;"
                        create-tbl1
                        insert-tbl1
                        "CREATE TABLE tbl2 ".
                        "(year        @ud,".
                        " month       @ud,".
                        " day         @ud,".
                        " day-name  @t)".
                        "  PRIMARY KEY (year, month, day);"
                        insert-tbl2-a
                        ==
      ::
      :+  ~2012.5.3
          %db1
          "FROM tbl1 t1 ".
          "JOIN tbl2 T2 ".
          "SELECT T1.year, T2.month, T1.day, month-name, day-name"
      ::
      :+  ~2012.5.3
          %db1
          "FROM tbl1 t1 ".
          "JOIN tbl2 T2 ".
          "WHERE day-name = 'Monday' ".
          "SELECT T1.year, T2.month, T1.day, month-name, day-name"
      ::
      :-  %results
          :~  [%action 'SELECT']
              [%result-set expect-rows-1-a]
              [%server-time ~2012.5.3]
              [%relation 'db1.dbo.tbl1']
              [%schema-time ~2012.4.30]
              [%data-time ~2012.4.30]
              [%relation 'db1.dbo.tbl2']
              [%schema-time ~2012.4.30]
              [%data-time ~2012.4.30]
              [%vector-count 25]
              ==
      ::
      :-  %results
          :~  [%action 'SELECT']
              [%result-set expect-rows-2]
              [%server-time ~2012.5.3]
              [%relation 'db1.dbo.tbl1']
              [%schema-time ~2012.4.30]
              [%data-time ~2012.4.30]
              [%relation 'db1.dbo.tbl2']
              [%schema-time ~2012.4.30]
              [%data-time ~2012.4.30]
              [%vector-count 6]
              ==
      ==
::
::  join multi-column keys, tables inverted
++  test-join-11
  =|  run=@ud
  %-  exec-0-2
  :*  run
      :+  ~2012.4.30
          %db1
          %-  zing  :~  "CREATE DATABASE db1;"
                        create-tbl1
                        insert-tbl1
                        "CREATE TABLE tbl2 ".
                        "(year        @ud,".
                        " month       @ud,".
                        " day         @ud,".
                        " day-name  @t)".
                        "  PRIMARY KEY (year, month, day);"
                        insert-tbl2-a
                        ==
      ::
      :+  ~2012.5.3
          %db1
          "FROM tbl2 t1 ".
          "JOIN tbl1 T2 ".
          "SELECT T2.year, T1.month, T2.day, month-name, day-name"
      ::
      :+  ~2012.5.3
          %db1
          "FROM tbl2 t1 ".
          "JOIN tbl1 T2 ".
          "WHERE day-name = 'Monday' ".
          "SELECT T2.year, T1.month, T2.day, month-name, day-name"
      ::
      :-  %results
          :~  [%action 'SELECT']
              [%result-set expect-rows-1-a]
              [%server-time ~2012.5.3]
              [%relation 'db1.dbo.tbl1']
              [%schema-time ~2012.4.30]
              [%data-time ~2012.4.30]
              [%relation 'db1.dbo.tbl2']
              [%schema-time ~2012.4.30]
              [%data-time ~2012.4.30]
              [%vector-count 25]
              ==
      ::
      :-  %results
          :~  [%action 'SELECT']
              [%result-set expect-rows-2]
              [%server-time ~2012.5.3]
              [%relation 'db1.dbo.tbl1']
              [%schema-time ~2012.4.30]
              [%data-time ~2012.4.30]
              [%relation 'db1.dbo.tbl2']
              [%schema-time ~2012.4.30]
              [%data-time ~2012.4.30]
              [%vector-count 6]
              ==
      ==
::
::  join ascending and descending multi-column keys, all rows join
++  test-join-12
  =|  run=@ud
  %-  exec-0-2
  :*  run
      :+  ~2012.4.30
          %db1
          %-  zing  :~  "CREATE DATABASE db1;"
                        create-tbl1
                        insert-tbl1
                        "CREATE TABLE tbl2 ".
                        "(year        @ud,".
                        " month       @ud,".
                        " day         @ud,".
                        " day-name  @t)".
                        "  PRIMARY KEY (year DESC, month DESC, day DESC);"
                        insert-tbl2
                        ==
      ::
      :+  ~2012.5.3
          %db1
          "FROM tbl1 t1 ".
          "JOIN tbl2 T2 ".
          "SELECT T1.year, T2.month, T1.day, month-name, day-name"
      ::
      :+  ~2012.5.3
          %db1
          "FROM tbl1 t1 ".
          "JOIN tbl2 T2 ".
          "WHERE T2.day-name = 'Monday' ".
          "SELECT T1.year, T2.month, T1.day, month-name, day-name"
      ::
      :-  %results
          :~  [%action 'SELECT']
              [%result-set expect-rows-1]
              [%server-time ~2012.5.3]
              [%relation 'db1.dbo.tbl1']
              [%schema-time ~2012.4.30]
              [%data-time ~2012.4.30]
              [%relation 'db1.dbo.tbl2']
              [%schema-time ~2012.4.30]
              [%data-time ~2012.4.30]
              [%vector-count 32]
              ==
      ::
      :-  %results
          :~  [%action 'SELECT']
              [%result-set expect-rows-2]
              [%server-time ~2012.5.3]
              [%relation 'db1.dbo.tbl1']
              [%schema-time ~2012.4.30]
              [%data-time ~2012.4.30]
              [%relation 'db1.dbo.tbl2']
              [%schema-time ~2012.4.30]
              [%data-time ~2012.4.30]
              [%vector-count 6]
              ==
      ==
::
::  join ascending and descending multi-column keys
++  test-join-13
  =|  run=@ud
  %-  exec-0-2
  :*  run
      :+  ~2012.4.30
          %db1
          %-  zing  :~  "CREATE DATABASE db1;"
                        create-tbl1
                        insert-tbl1
                        "CREATE TABLE tbl2 ".
                        "(year        @ud,".
                        " month       @ud,".
                        " day         @ud,".
                        " day-name  @t)".
                        "  PRIMARY KEY (year DESC, month DESC, day DESC);"
                        insert-tbl2-a
                        ==
      ::
      :+  ~2012.5.3
          %db1
          "FROM tbl1 t1 ".
          "JOIN tbl2 T2 ".
          "SELECT T1.year, T2.month, T1.day, month-name, day-name"
      ::
      :+  ~2012.5.3
          %db1
          "FROM tbl1 t1 ".
          "JOIN tbl2 T2 ".
          "WHERE T2.day-name = 'Monday' ".
          "SELECT T1.year, T2.month, T1.day, month-name, day-name"
      ::
      :-  %results
          :~  [%action 'SELECT']
              [%result-set expect-rows-1-a]
              [%server-time ~2012.5.3]
              [%relation 'db1.dbo.tbl1']
              [%schema-time ~2012.4.30]
              [%data-time ~2012.4.30]
              [%relation 'db1.dbo.tbl2']
              [%schema-time ~2012.4.30]
              [%data-time ~2012.4.30]
              [%vector-count 25]
              ==
      ::
      :-  %results
          :~  [%action 'SELECT']
              [%result-set expect-rows-2]
              [%server-time ~2012.5.3]
              [%relation 'db1.dbo.tbl1']
              [%schema-time ~2012.4.30]
              [%data-time ~2012.4.30]
              [%relation 'db1.dbo.tbl2']
              [%schema-time ~2012.4.30]
              [%data-time ~2012.4.30]
              [%vector-count 6]
              ==
      ==
::
::  join ascending and descending multi-column keys, tables inverted 
++  test-join-14
  =|  run=@ud
  %-  exec-0-2
  :*  run
      :+  ~2012.4.30
          %db1
          %-  zing  :~  "CREATE DATABASE db1;"
                        create-tbl1
                        insert-tbl1
                        "CREATE TABLE tbl2 ".
                        "(year        @ud,".
                        " month       @ud,".
                        " day         @ud,".
                        " day-name  @t)".
                        "  PRIMARY KEY (year DESC, month DESC, day DESC);"
                        insert-tbl2-a
                        ==
      ::
      :+  ~2012.5.3
          %db1
          "FROM tbl1 t2 ".
          "JOIN tbl2 T1 ".
          "SELECT T2.year, T1.month, T2.day, month-name, day-name"
      ::
      :+  ~2012.5.3
          %db1
          "FROM tbl1 t2 ".
          "JOIN tbl2 T1 ".
          "WHERE T1.day-name = 'Monday' ".
          "SELECT T2.year, T1.month, T2.day, month-name, day-name"
      ::
      :-  %results
          :~  [%action 'SELECT']
              [%result-set expect-rows-1-a]
              [%server-time ~2012.5.3]
              [%relation 'db1.dbo.tbl1']
              [%schema-time ~2012.4.30]
              [%data-time ~2012.4.30]
              [%relation 'db1.dbo.tbl2']
              [%schema-time ~2012.4.30]
              [%data-time ~2012.4.30]
              [%vector-count 25]
              ==
      ::
      :-  %results
          :~  [%action 'SELECT']
              [%result-set expect-rows-2]
              [%server-time ~2012.5.3]
              [%relation 'db1.dbo.tbl1']
              [%schema-time ~2012.4.30]
              [%data-time ~2012.4.30]
              [%relation 'db1.dbo.tbl2']
              [%schema-time ~2012.4.30]
              [%data-time ~2012.4.30]
              [%vector-count 6]
              ==
      ==
::
::  join ascending and partial descending multi-column keys, all rows join
++  test-join-15
  =|  run=@ud
  %-  exec-0-2
  :*  run
      :+  ~2012.4.30
          %db1
          %-  zing  :~  "CREATE DATABASE db1;"
                        create-tbl1
                        insert-tbl1
                        "CREATE TABLE tbl2 ".
                        "(year        @ud,".
                        " month       @ud,".
                        " day         @ud,".
                        " day-name  @t)".
                        "  PRIMARY KEY (year, month DESC, day DESC);"
                        insert-tbl2
                        ==
      ::
      :+  ~2012.5.3
          %db1
          "FROM tbl1 t1 ".
          "JOIN tbl2 T2 ".
          "SELECT T1.year, T2.month, T1.day, month-name, day-name"
      ::
      :+  ~2012.5.3
          %db1
          "FROM tbl1 t1 ".
          "JOIN tbl2 T2 ".
          "WHERE day-name = 'Monday' ".
          "SELECT T1.year, T2.month, T1.day, month-name, day-name"
      ::
      :-  %results
          :~  [%action 'SELECT']
              [%result-set expect-rows-1]
              [%server-time ~2012.5.3]
              [%relation 'db1.dbo.tbl1']
              [%schema-time ~2012.4.30]
              [%data-time ~2012.4.30]
              [%relation 'db1.dbo.tbl2']
              [%schema-time ~2012.4.30]
              [%data-time ~2012.4.30]
              [%vector-count 32]
              ==
      ::
      :-  %results
          :~  [%action 'SELECT']
              [%result-set expect-rows-2]
              [%server-time ~2012.5.3]
              [%relation 'db1.dbo.tbl1']
              [%schema-time ~2012.4.30]
              [%data-time ~2012.4.30]
              [%relation 'db1.dbo.tbl2']
              [%schema-time ~2012.4.30]
              [%data-time ~2012.4.30]
              [%vector-count 6]
              ==
      ==
::
::  join ascending and partial descending multi-column keys
++  test-join-16
  =|  run=@ud
  %-  exec-0-2
  :*  run
      :+  ~2012.4.30
          %db1
          %-  zing  :~  "CREATE DATABASE db1;"
                        create-tbl1
                        insert-tbl1
                        "CREATE TABLE tbl2 ".
                        "(year        @ud,".
                        " month       @ud,".
                        " day         @ud,".
                        " day-name  @t)".
                        "  PRIMARY KEY (year, month DESC, day DESC);"
                        insert-tbl2-a
                        ==
      ::
      :+  ~2012.5.3
          %db1
          "FROM tbl1 t1 ".
          "JOIN tbl2 T2 ".
          "SELECT T1.year, T2.month, T1.day, month-name, day-name"
      ::
      :+  ~2012.5.3
          %db1
          "FROM tbl1 t1 ".
          "JOIN tbl2 T2 ".
          "WHERE day-name = 'Monday' ".
          "SELECT T1.year, T2.month, T1.day, month-name, day-name"
      ::
      :-  %results
          :~  [%action 'SELECT']
              [%result-set expect-rows-1-a]
              [%server-time ~2012.5.3]
              [%relation 'db1.dbo.tbl1']
              [%schema-time ~2012.4.30]
              [%data-time ~2012.4.30]
              [%relation 'db1.dbo.tbl2']
              [%schema-time ~2012.4.30]
              [%data-time ~2012.4.30]
              [%vector-count 25]
              ==
      ::
      :-  %results
          :~  [%action 'SELECT']
              [%result-set expect-rows-2]
              [%server-time ~2012.5.3]
              [%relation 'db1.dbo.tbl1']
              [%schema-time ~2012.4.30]
              [%data-time ~2012.4.30]
              [%relation 'db1.dbo.tbl2']
              [%schema-time ~2012.4.30]
              [%data-time ~2012.4.30]
              [%vector-count 6]
              ==
      ==
::
::  join ascending and partial descending multi-column keys, tables inverted 
++  test-join-17
  =|  run=@ud
  %-  exec-0-2
  :*  run
      :+  ~2012.4.30
          %db1
          %-  zing  :~  "CREATE DATABASE db1;"
                        create-tbl1
                        insert-tbl1
                        "CREATE TABLE tbl2 ".
                        "(year        @ud,".
                        " month       @ud,".
                        " day         @ud,".
                        " day-name  @t)".
                        "  PRIMARY KEY (year, month DESC, day DESC);"
                        insert-tbl2-a
                        ==
      ::
      :+  ~2012.5.3
          %db1
          "FROM tbl2 t1 ".
          "JOIN tbl1 T2 ".
          "SELECT T2.year, T1.month, T2.day, month-name, day-name"
      ::
      :+  ~2012.5.3
          %db1
          "FROM tbl2 t2 ".
          "JOIN tbl1 T1 ".
          "WHERE day-name = 'Monday' ".
          "SELECT T2.year, T1.month, T2.day, month-name, day-name"
      ::
      :-  %results
          :~  [%action 'SELECT']
              [%result-set expect-rows-1-a]
              [%server-time ~2012.5.3]
              [%relation 'db1.dbo.tbl1']
              [%schema-time ~2012.4.30]
              [%data-time ~2012.4.30]
              [%relation 'db1.dbo.tbl2']
              [%schema-time ~2012.4.30]
              [%data-time ~2012.4.30]
              [%vector-count 25]
              ==
      ::
      :-  %results
          :~  [%action 'SELECT']
              [%result-set expect-rows-2]
              [%server-time ~2012.5.3]
              [%relation 'db1.dbo.tbl1']
              [%schema-time ~2012.4.30]
              [%data-time ~2012.4.30]
              [%relation 'db1.dbo.tbl2']
              [%schema-time ~2012.4.30]
              [%data-time ~2012.4.30]
              [%vector-count 6]
              ==
      ==
::
::  join ascending and partial descending multi-column keys
::  with column aliases and literals
++  test-join-18
  =|  run=@ud
  %-  exec-0-1
  :*  run
      :+  ~2012.4.30
          %db1
          %-  zing  :~  "CREATE DATABASE db1;"
                        create-tbl1
                        insert-tbl1
                        "CREATE TABLE tbl2 ".
                        "(year        @ud,".
                        " month       @ud,".
                        " day         @ud,".
                        " day-name  @t)".
                        "  PRIMARY KEY (year, month DESC, day DESC);"
                        insert-tbl2-a
                        ==
      ::
      :+  ~2012.5.3
          %db1
          "FROM tbl2 t2 ".
          "JOIN tbl1 T1 ".
          "WHERE day-name = 'Monday' ".
          "SELECT 1, T2.year as my-year, T1.month AS the-month, ".
          "T2.day As the-day, ~zod, month-name, day-name"
      ::
      :-  %results
          :~  [%action 'SELECT']
              :-  %result-set
                  :~  :-  %vector
                          :~  [%literal-0 [~.ud 1]]
                              [%my-year [~.ud 2.023]]
                              [%the-month [~.ud 12]]
                              [%the-day [~.ud 25]]
                              [%literal-4 [~.p 0]]
                              [%month-name [~.t 'December']]
                              [%day-name [~.t 'Monday']]
                              ==
                      :-  %vector
                          :~  [%literal-0 [~.ud 1]]
                              [%my-year [~.ud 2.024]]
                              [%the-month [~.ud 1]]
                              [%the-day [~.ud 1]]
                              [%literal-4 [~.p 0]]
                              [%month-name [~.t 'January']]
                              [%day-name [~.t 'Monday']]
                              ==
                      :-  %vector
                          :~  [%literal-0 [~.ud 1]]
                              [%my-year [~.ud 2.024]]
                              [%the-month [~.ud 2]]
                              [%the-day [~.ud 5]]
                              [%literal-4 [~.p 0]]
                              [%month-name [~.t 'February']]
                              [%day-name [~.t 'Monday']]
                              ==
                      :-  %vector
                          :~  [%literal-0 [~.ud 1]]
                              [%my-year [~.ud 2.024]]
                              [%the-month [~.ud 3]]
                              [%the-day [~.ud 4]]
                              [%literal-4 [~.p 0]]
                              [%month-name [~.t 'March']]
                              [%day-name [~.t 'Monday']]
                              ==
                      :-  %vector
                          :~  [%literal-0 [~.ud 1]]
                              [%my-year [~.ud 2.024]]
                              [%the-month [~.ud 4]]
                              [%the-day [~.ud 1]]
                              [%literal-4 [~.p 0]]
                              [%month-name [~.t 'April']]
                              [%day-name [~.t 'Monday']]
                              ==
                      :-  %vector
                          :~  [%literal-0 [~.ud 1]]
                              [%my-year [~.ud 2.024]]
                              [%the-month [~.ud 4]]
                              [%the-day [~.ud 8]]
                              [%literal-4 [~.p 0]]
                              [%month-name [~.t 'April']]
                              [%day-name [~.t 'Monday']]
                              ==
                      ==
              [%server-time ~2012.5.3]
              [%relation 'db1.dbo.tbl1']
              [%schema-time ~2012.4.30]
              [%data-time ~2012.4.30]
              [%relation 'db1.dbo.tbl2']
              [%schema-time ~2012.4.30]
              [%data-time ~2012.4.30]
              [%vector-count 6]
              ==
      ==
::
::  join same table prior date
++  test-join-19
  =|  run=@ud
  %-  exec-1-1
  :*  run
      :+  ~2012.4.30
          %db1
          %-  zing  :~  "CREATE DATABASE db1;"
                        create-calendar
                        insert-calendar
                        ==
      ::
      :+  ~2012.5.30
          %db1
          "INSERT INTO calendar ".
          "VALUES ".
          "(~2024.1.3, 2024, 1, 'January', 3, 'Wednesday', 3, 4, 1) ".
          "(~2024.1.4, 2024, 1, 'January', 4, 'Thursday', 4, 5, 1);"
      ::
      :+  ~2012.6.3
          %db1
          "FROM calendar T1 ".
          "JOIN calendar AS OF ~2012.5.29 T2 ".
          "SELECT T1.day-name, T2.*"
      ::
      :-  %results
          :~  [%action 'SELECT']
              :-  %result-set
                  :~  :-  %vector
                          :~  [%day-name [~.t 'Thursday']]
                              [%date [~.da ~2023.12.21]]
                              [%year [~.ud 2.023]]
                              [%month [~.ud 12]]
                              [%month-name [~.t 'December']]
                              [%day [~.ud 21]]
                              [%day-name [~.t 'Thursday']]
                              [%day-of-year [~.ud 355]]
                              [%weekday [~.ud 5]]
                              [%year-week [~.ud 51]]
                              ==
                      :-  %vector
                          :~  [%day-name [~.t 'Friday']]
                              [%date [~.da ~2023.12.22]]
                              [%year [~.ud 2.023]]
                              [%month [~.ud 12]]
                              [%month-name [~.t 'December']]
                              [%day [~.ud 22]]
                              [%day-name [~.t 'Friday']]
                              [%day-of-year [~.ud 356]]
                              [%weekday [~.ud 6]]
                              [%year-week [~.ud 51]]
                              ==
                      :-  %vector
                          :~  [%day-name [~.t 'Saturday']]
                              [%date [~.da ~2023.12.23]]
                              [%year [~.ud 2.023]]
                              [%month [~.ud 12]]
                              [%month-name [~.t 'December']]
                              [%day [~.ud 23]]
                              [%day-name [~.t 'Saturday']]
                              [%day-of-year [~.ud 357]]
                              [%weekday [~.ud 7]]
                              [%year-week [~.ud 51]]
                              ==
                      :-  %vector
                          :~  [%day-name [~.t 'Sunday']]
                              [%date [~.da ~2023.12.24]]
                              [%year [~.ud 2.023]]
                              [%month [~.ud 12]]
                              [%month-name [~.t 'December']]
                              [%day [~.ud 24]]
                              [%day-name [~.t 'Sunday']]
                              [%day-of-year [~.ud 358]]
                              [%weekday [~.ud 1]]
                              [%year-week [~.ud 52]]
                              ==
                      :-  %vector
                          :~  [%day-name [~.t 'Monday']]
                              [%date [~.da ~2023.12.25]]
                              [%year [~.ud 2.023]]
                              [%month [~.ud 12]]
                              [%month-name [~.t 'December']]
                              [%day [~.ud 25]]
                              [%day-name [~.t 'Monday']]
                              [%day-of-year [~.ud 359]]
                              [%weekday [~.ud 2]]
                              [%year-week [~.ud 52]]
                              ==
                      :-  %vector
                          :~  [%day-name [~.t 'Tuesday']]
                              [%date [~.da ~2023.12.26]]
                              [%year [~.ud 2.023]]
                              [%month [~.ud 12]]
                              [%month-name [~.t 'December']]
                              [%day [~.ud 26]]
                              [%day-name [~.t 'Tuesday']]
                              [%day-of-year [~.ud 360]]
                              [%weekday [~.ud 3]]
                              [%year-week [~.ud 52]]
                              ==
                      :-  %vector
                          :~  [%day-name [~.t 'Wednesday']]
                              [%date [~.da ~2023.12.27]]
                              [%year [~.ud 2.023]]
                              [%month [~.ud 12]]
                              [%month-name [~.t 'December']]
                              [%day [~.ud 27]]
                              [%day-name [~.t 'Wednesday']]
                              [%day-of-year [~.ud 361]]
                              [%weekday [~.ud 4]]
                              [%year-week [~.ud 52]]
                              ==
                      :-  %vector
                          :~  [%day-name [~.t 'Thursday']]
                              [%date [~.da ~2023.12.28]]
                              [%year [~.ud 2.023]]
                              [%month [~.ud 12]]
                              [%month-name [~.t 'December']]
                              [%day [~.ud 28]]
                              [%day-name [~.t 'Thursday']]
                              [%day-of-year [~.ud 362]]
                              [%weekday [~.ud 5]]
                              [%year-week [~.ud 52]]
                              ==
                      :-  %vector
                          :~  [%day-name [~.t 'Friday']]
                              [%date [~.da ~2023.12.29]]
                              [%year [~.ud 2.023]]
                              [%month [~.ud 12]]
                              [%month-name [~.t 'December']]
                              [%day [~.ud 29]]
                              [%day-name [~.t 'Friday']]
                              [%day-of-year [~.ud 363]]
                              [%weekday [~.ud 6]]
                              [%year-week [~.ud 52]]
                              ==
                      :-  %vector
                          :~  [%day-name [~.t 'Saturday']]
                              [%date [~.da ~2023.12.30]]
                              [%year [~.ud 2.023]]
                              [%month [~.ud 12]]
                              [%month-name [~.t 'December']]
                              [%day [~.ud 30]]
                              [%day-name [~.t 'Saturday']]
                              [%day-of-year [~.ud 364]]
                              [%weekday [~.ud 7]]
                              [%year-week [~.ud 52]]
                              ==
                      :-  %vector
                          :~  [%day-name [~.t 'Sunday']]
                              [%date [~.da ~2023.12.31]]
                              [%year [~.ud 2.023]]
                              [%month [~.ud 12]]
                              [%month-name [~.t 'December']]
                              [%day [~.ud 31]]
                              [%day-name [~.t 'Sunday']]
                              [%day-of-year [~.ud 365]]
                              [%weekday [~.ud 1]]
                              [%year-week [~.ud 53]]
                              ==
                      :-  %vector
                          :~  [%day-name [~.t 'Monday']]
                              [%date [~.da ~2024.1.1]]
                              [%year [~.ud 2.024]]
                              [%month [~.ud 1]]
                              [%month-name [~.t 'January']]
                              [%day [~.ud 1]]
                              [%day-name [~.t 'Monday']]
                              [%day-of-year [~.ud 1]]
                              [%weekday [~.ud 2]]
                              [%year-week [~.ud 1]]
                              ==
                      :-  %vector
                          :~  [%day-name [~.t 'Tuesday']]
                              [%date [~.da ~2024.1.2]]
                              [%year [~.ud 2.024]]
                              [%month [~.ud 1]]
                              [%month-name [~.t 'January']]
                              [%day [~.ud 2]]
                              [%day-name [~.t 'Tuesday']]
                              [%day-of-year [~.ud 2]]
                              [%weekday [~.ud 3]]
                              [%year-week [~.ud 1]]
                              ==
                      ==
              [%server-time ~2012.6.3]
              [%relation 'db1.dbo.calendar']
              [%schema-time ~2012.4.30]
              [%data-time ~2012.4.30]
              [%relation 'db1.dbo.calendar']
              [%schema-time ~2012.4.30]
              [%data-time ~2012.5.30]
              [%vector-count 13]
              ==
      ==
::
::  cross join
++  test-join-20
  =|  run=@ud
  %-  exec-0-1
  :*  run
      :+  ~2012.4.30
          %db1
          %-  zing  :~  "CREATE DATABASE db1;"
                        create-tbl1
                        create-cross-tbl
                        insert-tbl1-a
                        insert-cross
                        ==
      ::
      :+  ~2012.5.3
          %db1
          "FROM tbl1 ".
          "CROSS JOIN cross ".
          "SELECT year, month, day, month-name, cross-key, cross-2, ".
          "cross-3"
      ::
      expected-cross
      ==
::
::  cross join (inverted)
++  test-join-21
  =|  run=@ud
  %-  exec-0-1
  :*  run
      :+  ~2012.4.30
          %db1
          %-  zing  :~  "CREATE DATABASE db1;"
                        create-tbl1
                        create-cross-tbl
                        insert-tbl1-a
                        insert-cross
                        ==
      ::
      :+  ~2012.5.3
          %db1
          "FROM cross ".
          "CROSS JOIN tbl1 ".
          "SELECT year, month, day, month-name, cross-key, cross-2, ".
          "cross-3"
      ::
      expected-cross
      ==
::
::  cross join, as of, aliased, literals
++  test-join-22
  =|  run=@ud
  %-  exec-1-2
  :*  run
      :+  ~2012.4.30
          %db1
          %-  zing  :~  "CREATE DATABASE db1;"
                        create-tbl1
                        create-cross-tbl
                        insert-tbl1-b
                        insert-cross
                        ==
      ::
      :+  ~2012.5.2
          %db1
          "INSERT INTO cross ".
          "VALUES ".
          "(4, ~sev, 'cross-d');"
      ::
      :+  ~2012.5.3
          %db1
          "FROM tbl1 T1 ".
          "CROSS JOIN cross T2 ".
          "SELECT T1.year, T1.month-name, 'cross joining', ".
          "T2.cross-key, T2.cross-2"
      ::
      :+  ~2012.5.4
          %db1
          "FROM tbl1 T1 ".
          "CROSS JOIN cross as of ~2012.5.1 T2 ".
          "SELECT T1.year, T1.month-name, 'cross joining', ".
          "T2.cross-key, T2.cross-2"
      ::
      expected-cross-aliased
      ::
      expected-cross-as-of
      ==
::
::  test 3 natural joins
++  test-join-23
  =|  run=@ud
  %-  exec-0-1
  :*  run
      :+  ~2012.4.30
          %db1
          %-  zing  :~  "CREATE DATABASE db1;"
                        create-calendar
                        insert-calendar
                        create-holiday-calendar
                        insert-holiday-calendar
                        create-tbl3
                        insert-tbl3
                        ==
      ::
      :+  ~2012.5.3
          %db1
          "FROM calendar T1 ".
          "JOIN holiday-calendar T2 ".
          "JOIN tbl3 T3 ".
          "SELECT row-name, T1.day-name, T2.*, T3.*"
      ::
      :-  %results
          :~  [%action 'SELECT']
              :-  %result-set
                  :~  :-  %vector
                          :~  [%row-name [~.t 'row-3']]
                              [%day-name [~.t 'Monday']]
                              [%date [~.da ~2023.12.25]]
                              [%us-federal-holiday [~.t 'Christmas Day']]
                              [%date [~.da ~2023.12.25]]
                              [%year [~.ud 2.023]]
                              [%month [~.ud 12]]
                              [%day [~.ud 25]]
                              [%row-name [~.t 'row-3']]
                              ==
                      :-  %vector
                          :~  [%row-name [~.t 'row-7']]
                              [%day-name [~.t 'Monday']]
                              [%date [~.da ~2024.1.1]]
                              [%us-federal-holiday [~.t 'New Years Day']]
                              [%date [~.da ~2024.1.1]]
                              [%year [~.ud 2.024]]
                              [%month [~.ud 1]]
                              [%day [~.ud 1]]
                              [%row-name [~.t 'row-7']]
                              ==
                      ==
              [%server-time ~2012.5.3]
              [%relation 'db1.dbo.calendar']
              [%schema-time ~2012.4.30]
              [%data-time ~2012.4.30]
              [%relation 'db1.dbo.holiday-calendar']
              [%schema-time ~2012.4.30]
              [%data-time ~2012.4.30]
              [%relation 'db1.dbo.tbl3']
              [%schema-time ~2012.4.30]
              [%data-time ~2012.4.30]
              [%vector-count 2]
              ==
      ==
::
::  test 3 natural joins and cross join
++  test-join-24
  =|  run=@ud
  %-  exec-0-1
  :*  run
      :+  ~2012.4.30
          %db1
          %-  zing  :~  "CREATE DATABASE db1;"
                        create-calendar
                        create-holiday-calendar
                        create-tbl3
                        create-cross-tbl
                        insert-calendar
                        insert-holiday-calendar
                        insert-tbl3
                        insert-cross
                        ==
      ::
      :+  ~2012.5.3
          %db1
          "FROM calendar T1 ".
          "JOIN holiday-calendar T2 ".
          "JOIN tbl3 T3 ".
          "CROSS JOIN cross T4 ".
          "SELECT row-name, T1.day-name, T2.*, T3.*, T4.*"
      ::
      :-  %results
          :~  [%action 'SELECT']
              [%result-set expected-natural-cross-rows]
              [%server-time ~2012.5.3]
              [%relation 'db1.dbo.calendar']
              [%schema-time ~2012.4.30]
              [%data-time ~2012.4.30]
              [%relation 'db1.dbo.cross']
              [%schema-time ~2012.4.30]
              [%data-time ~2012.4.30]
              [%relation 'db1.dbo.holiday-calendar']
              [%schema-time ~2012.4.30]
              [%data-time ~2012.4.30]
              [%relation 'db1.dbo.tbl3']
              [%schema-time ~2012.4.30]
              [%data-time ~2012.4.30]
              [%vector-count 6]
              ==
      ==
::
::  test 3 natural joins and cross join, join order 2
++  test-join-25
  =|  run=@ud
  %-  exec-0-1
  :*  run
      :+  ~2012.4.30
          %db1
          %-  zing  :~  "CREATE DATABASE db1;"
                        create-calendar
                        create-holiday-calendar
                        create-tbl3
                        create-cross-tbl
                        insert-calendar
                        insert-holiday-calendar
                        insert-tbl3
                        insert-cross
                        ==
      ::
      :+  ~2012.5.3
          %db1
          "FROM calendar T1 ".
          "CROSS JOIN cross T4 ".
          "JOIN holiday-calendar T2 ".
          "JOIN tbl3 T3 ".
          "SELECT row-name, T1.day-name, T2.*, T3.*, T4.*"
      ::
      :-  %results
          :~  [%action 'SELECT']
              [%result-set expected-natural-cross-rows]
              [%server-time ~2012.5.3]
              [%relation 'db1.dbo.calendar']
              [%schema-time ~2012.4.30]
              [%data-time ~2012.4.30]
              [%relation 'db1.dbo.cross']
              [%schema-time ~2012.4.30]
              [%data-time ~2012.4.30]
              [%relation 'db1.dbo.holiday-calendar']
              [%schema-time ~2012.4.30]
              [%data-time ~2012.4.30]
              [%relation 'db1.dbo.tbl3']
              [%schema-time ~2012.4.30]
              [%data-time ~2012.4.30]
              [%vector-count 6]
              ==
      ==
::
::  test 3 natural joins and cross join, join order 3
++  test-join-26
  =|  run=@ud
  %-  exec-0-1
  :*  run
      :+  ~2012.4.30
          %db1
          %-  zing  :~  "CREATE DATABASE db1;"
                        create-calendar
                        create-holiday-calendar
                        create-tbl3
                        create-cross-tbl
                        insert-calendar
                        insert-holiday-calendar
                        insert-tbl3
                        insert-cross
                        ==
      ::
      :+  ~2012.5.3
          %db1
          "FROM tbl3 T3 ".
          "CROSS JOIN cross T4 ".
          "JOIN holiday-calendar T2 ".
          "JOIN calendar T1 ".
          "SELECT row-name, T1.day-name, T2.*, T3.*, T4.*"
      ::
      :-  %results
          :~  [%action 'SELECT']
              [%result-set expected-natural-cross-rows]
              [%server-time ~2012.5.3]
              [%relation 'db1.dbo.calendar']
              [%schema-time ~2012.4.30]
              [%data-time ~2012.4.30]
              [%relation 'db1.dbo.cross']
              [%schema-time ~2012.4.30]
              [%data-time ~2012.4.30]
              [%relation 'db1.dbo.holiday-calendar']
              [%schema-time ~2012.4.30]
              [%data-time ~2012.4.30]
              [%relation 'db1.dbo.tbl3']
              [%schema-time ~2012.4.30]
              [%data-time ~2012.4.30]
              [%vector-count 6]
              ==
      ==
::
::  test 3 natural joins and 2 cross joins
++  test-join-27
  =|  run=@ud
  %-  exec-0-1
  :*  run
      :+  ~2012.4.30
          %db1
          %-  zing  :~  "CREATE DATABASE db1;"
                        create-calendar
                        create-holiday-calendar
                        create-tbl3
                        create-cross-tbl
                        "CREATE TABLE cross2 ".
                        "(cross-key2  @ud,".
                        " cross-42    @t)".
                        "  PRIMARY KEY (cross-key2);"
                        insert-calendar
                        insert-holiday-calendar
                        insert-tbl3
                        insert-cross
                        "INSERT INTO cross2 ".
                        "VALUES ".
                        "(1, 'cross-1a') ".
                        "(3, 'cross-3b');"
                        ==
      ::
      :+  ~2012.5.3
          %db1
          "FROM tbl3 T3 ".
          "CROSS JOIN cross T4 ".
          "JOIN holiday-calendar T2 ".
          "CROSS JOIN cross2 T5 ".
          "JOIN calendar T1 ".
          "SELECT row-name, T1.day-name, T2.*, T3.*, T4.*, cross-42"
      ::
      :-  %results
          :~  [%action 'SELECT']
              :-  %result-set
                  :~  :-  %vector
                          :~  [%row-name [~.t 'row-3']]
                              [%day-name [~.t 'Monday']]
                              [%date [~.da ~2023.12.25]]
                              [%us-federal-holiday [~.t 'Christmas Day']]
                              [%date [~.da ~2023.12.25]]
                              [%year [~.ud 2.023]]
                              [%month [~.ud 12]]
                              [%day [~.ud 25]]
                              [%row-name [~.t 'row-3']]
                              [%cross-key [~.ud 1]]
                              [%cross-2 [~.p ~sampel-palnet]]
                              [%cross-3 [~.t 'cross-a']]
                              [%cross-42 [~.t 'cross-1a']]
                              ==
                      :-  %vector
                          :~  [%row-name [~.t 'row-7']]
                              [%day-name [~.t 'Monday']]
                              [%date [~.da ~2024.1.1]]
                              [%us-federal-holiday [~.t 'New Years Day']]
                              [%date [~.da ~2024.1.1]]
                              [%year [~.ud 2.024]]
                              [%month [~.ud 1]]
                              [%day [~.ud 1]]
                              [%row-name [~.t 'row-7']]
                              [%cross-key [~.ud 1]]
                              [%cross-2 [~.p ~sampel-palnet]]
                              [%cross-3 [~.t 'cross-a']]
                              [%cross-42 [~.t 'cross-1a']]
                              ==
                      :-  %vector
                          :~  [%row-name [~.t 'row-3']]
                              [%day-name [~.t 'Monday']]
                              [%date [~.da ~2023.12.25]]
                              [%us-federal-holiday [~.t 'Christmas Day']]
                              [%date [~.da ~2023.12.25]]
                              [%year [~.ud 2.023]]
                              [%month [~.ud 12]]
                              [%day [~.ud 25]]
                              [%row-name [~.t 'row-3']]
                              [%cross-key [~.ud 2]]
                              [%cross-2 [~.p ~nec]]
                              [%cross-3 [~.t 'cross-b']]
                              [%cross-42 [~.t 'cross-1a']]
                              ==
                      :-  %vector
                          :~  [%row-name [~.t 'row-7']]
                              [%day-name [~.t 'Monday']]
                              [%date [~.da ~2024.1.1]]
                              [%us-federal-holiday [~.t 'New Years Day']]
                              [%date [~.da ~2024.1.1]]
                              [%year [~.ud 2.024]]
                              [%month [~.ud 1]]
                              [%day [~.ud 1]]
                              [%row-name [~.t 'row-7']]
                              [%cross-key [~.ud 2]]
                              [%cross-2 [~.p ~nec]]
                              [%cross-3 [~.t 'cross-b']]
                              [%cross-42 [~.t 'cross-1a']]
                              ==
                      :-  %vector
                          :~  [%row-name [~.t 'row-3']]
                              [%day-name [~.t 'Monday']]
                              [%date [~.da ~2023.12.25]]
                              [%us-federal-holiday [~.t 'Christmas Day']]
                              [%date [~.da ~2023.12.25]]
                              [%year [~.ud 2.023]]
                              [%month [~.ud 12]]
                              [%day [~.ud 25]]
                              [%row-name [~.t 'row-3']]
                              [%cross-key [~.ud 3]]
                              [%cross-2 [~.p ~bus]]
                              [%cross-3 [~.t 'cross-c']]
                              [%cross-42 [~.t 'cross-1a']]
                              ==
                      :-  %vector
                          :~  [%row-name [~.t 'row-7']]
                              [%day-name [~.t 'Monday']]
                              [%date [~.da ~2024.1.1]]
                              [%us-federal-holiday [~.t 'New Years Day']]
                              [%date [~.da ~2024.1.1]]
                              [%year [~.ud 2.024]]
                              [%month [~.ud 1]]
                              [%day [~.ud 1]]
                              [%row-name [~.t 'row-7']]
                              [%cross-key [~.ud 3]]
                              [%cross-2 [~.p ~bus]]
                              [%cross-3 [~.t 'cross-c']]
                              [%cross-42 [~.t 'cross-1a']]
                              ==
                      :-  %vector
                          :~  [%row-name [~.t 'row-3']]
                              [%day-name [~.t 'Monday']]
                              [%date [~.da ~2023.12.25]]
                              [%us-federal-holiday [~.t 'Christmas Day']]
                              [%date [~.da ~2023.12.25]]
                              [%year [~.ud 2.023]]
                              [%month [~.ud 12]]
                              [%day [~.ud 25]]
                              [%row-name [~.t 'row-3']]
                              [%cross-key [~.ud 1]]
                              [%cross-2 [~.p ~sampel-palnet]]
                              [%cross-3 [~.t 'cross-a']]
                              [%cross-42 [~.t 'cross-3b']]
                              ==
                      :-  %vector
                          :~  [%row-name [~.t 'row-7']]
                              [%day-name [~.t 'Monday']]
                              [%date [~.da ~2024.1.1]]
                              [%us-federal-holiday [~.t 'New Years Day']]
                              [%date [~.da ~2024.1.1]]
                              [%year [~.ud 2.024]]
                              [%month [~.ud 1]]
                              [%day [~.ud 1]]
                              [%row-name [~.t 'row-7']]
                              [%cross-key [~.ud 1]]
                              [%cross-2 [~.p ~sampel-palnet]]
                              [%cross-3 [~.t 'cross-a']]
                              [%cross-42 [~.t 'cross-3b']]
                              ==
                      :-  %vector
                          :~  [%row-name [~.t 'row-3']]
                              [%day-name [~.t 'Monday']]
                              [%date [~.da ~2023.12.25]]
                              [%us-federal-holiday [~.t 'Christmas Day']]
                              [%date [~.da ~2023.12.25]]
                              [%year [~.ud 2.023]]
                              [%month [~.ud 12]]
                              [%day [~.ud 25]]
                              [%row-name [~.t 'row-3']]
                              [%cross-key [~.ud 2]]
                              [%cross-2 [~.p ~nec]]
                              [%cross-3 [~.t 'cross-b']]
                              [%cross-42 [~.t 'cross-3b']]
                              ==
                      :-  %vector
                          :~  [%row-name [~.t 'row-7']]
                              [%day-name [~.t 'Monday']]
                              [%date [~.da ~2024.1.1]]
                              [%us-federal-holiday [~.t 'New Years Day']]
                              [%date [~.da ~2024.1.1]]
                              [%year [~.ud 2.024]]
                              [%month [~.ud 1]]
                              [%day [~.ud 1]]
                              [%row-name [~.t 'row-7']]
                              [%cross-key [~.ud 2]]
                              [%cross-2 [~.p ~nec]]
                              [%cross-3 [~.t 'cross-b']]
                              [%cross-42 [~.t 'cross-3b']]
                              ==
                      :-  %vector
                          :~  [%row-name [~.t 'row-3']]
                              [%day-name [~.t 'Monday']]
                              [%date [~.da ~2023.12.25]]
                              [%us-federal-holiday [~.t 'Christmas Day']]
                              [%date [~.da ~2023.12.25]]
                              [%year [~.ud 2.023]]
                              [%month [~.ud 12]]
                              [%day [~.ud 25]]
                              [%row-name [~.t 'row-3']]
                              [%cross-key [~.ud 3]]
                              [%cross-2 [~.p ~bus]]
                              [%cross-3 [~.t 'cross-c']]
                              [%cross-42 [~.t 'cross-3b']]
                              ==
                      :-  %vector
                          :~  [%row-name [~.t 'row-7']]
                              [%day-name [~.t 'Monday']]
                              [%date [~.da ~2024.1.1]]
                              [%us-federal-holiday [~.t 'New Years Day']]
                              [%date [~.da ~2024.1.1]]
                              [%year [~.ud 2.024]]
                              [%month [~.ud 1]]
                              [%day [~.ud 1]]
                              [%row-name [~.t 'row-7']]
                              [%cross-key [~.ud 3]]
                              [%cross-2 [~.p ~bus]]
                              [%cross-3 [~.t 'cross-c']]
                              [%cross-42 [~.t 'cross-3b']]
                              ==
                      ==
              [%server-time ~2012.5.3]
              [%relation 'db1.dbo.calendar']
              [%schema-time ~2012.4.30]
              [%data-time ~2012.4.30]
              [%relation 'db1.dbo.cross']
              [%schema-time ~2012.4.30]
              [%data-time ~2012.4.30]
              [%relation 'db1.dbo.cross2']
              [%schema-time ~2012.4.30]
              [%data-time ~2012.4.30]
              [%relation 'db1.dbo.holiday-calendar']
              [%schema-time ~2012.4.30]
              [%data-time ~2012.4.30]
              [%relation 'db1.dbo.tbl3']
              [%schema-time ~2012.4.30]
              [%data-time ~2012.4.30]
              [%vector-count 12]
              ==
      ==
::
::  cross database join
++  test-join-28
  =|  run=@ud
  %-  exec-0-1
  :*  run
      :+  ~2012.4.30
          %db1
          %-  zing  :~  "CREATE DATABASE db1;"
                        "CREATE DATABASE db2;"
                        create-calendar
                        insert-calendar
                        "CREATE TABLE db2..holiday-calendar ".
                        "(date @da, us-federal-holiday @t) ".
                        "PRIMARY KEY (date);"
                        "INSERT INTO db2..holiday-calendar ".
                        "(date, us-federal-holiday) ".
                        "VALUES ".
                        "(~2023.11.23, 'Thanksgiving Day') ".
                        "(~2023.12.25, 'Christmas Day') ".
                        "(~2024.1.1, 'New Years Day') ".
                        "(~2024.1.15, 'Birth of Martin Luther King Jr.');"
                        ==
      ::
      :+  ~2012.5.3
          %db1
          "FROM calendar T1 ".
          "JOIN db2..holiday-calendar T2 ".
          "SELECT T1.day-name, T2.*"
      ::
      :-  %results
          :~  [%action 'SELECT']
              :-  %result-set
                  :~  :-  %vector
                          :~  [%day-name [~.t 'Monday']]
                              [%date [~.da ~2023.12.25]]
                              [%us-federal-holiday [~.t 'Christmas Day']]
                              ==
                      :-  %vector
                          :~  [%day-name [~.t 'Monday']]
                              [%date [~.da ~2024.1.1]]
                              [%us-federal-holiday [~.t 'New Years Day']]
                              ==
                      ==
              [%server-time ~2012.5.3]
              [%relation 'db1.dbo.calendar']
              [%schema-time ~2012.4.30]
              [%data-time ~2012.4.30]
              [%relation 'db2.dbo.holiday-calendar']
              [%schema-time ~2012.4.30]
              [%data-time ~2012.4.30]
              [%vector-count 2]
              ==
      ==
::
::  natural join, composite @rd @sd @rd primary key, asc/desc inverted between tables
++  test-join-29
  =|  run=@ud
  %-  exec-0-1
  :*  run
      :+  ~2012.4.30
          %db1
          %-  zing  :~
            "CREATE DATABASE db1;"
            "CREATE TABLE db1..nj-tbl-a "
            "(pk-rd1 @rd, pk-sd @sd, pk-rd2 @rd, tbl-a-label @t) "
            "PRIMARY KEY (pk-rd1 ASC, pk-sd DESC, pk-rd2 ASC);"
            "CREATE TABLE db1..nj-tbl-b "
            "(pk-rd1 @rd, pk-sd @sd, pk-rd2 @rd, tbl-b-label @t) "
            "PRIMARY KEY (pk-rd1 DESC, pk-sd ASC, pk-rd2 DESC);"
            "INSERT INTO nj-tbl-a (pk-rd1, pk-sd, pk-rd2, tbl-a-label) VALUES "
            "(.~1.0, --3, .~2.0, 'row1') "
            "(.~1.0, --1, .~4.0, 'row2') "
            "(.~2.0, --4, .~1.0, 'row3') "
            "(.~2.0, --2, .~3.0, 'row4') "
            "(.~3.0, --5, .~2.0, 'row5') "
            "(.~3.0, --1, .~1.0, 'row6') "
            "(.~4.0, --3, .~4.0, 'row7') "
            "(.~4.0, --2, .~2.0, 'row8') "
            "(.~5.0, --4, .~3.0, 'row9') "
            "(.~5.0, --1, .~2.0, 'row10');"
            "INSERT INTO nj-tbl-b (pk-rd1, pk-sd, pk-rd2, tbl-b-label) VALUES "
            "(.~6.0, --2, .~3.0, 'row1') "
            "(.~5.0, --1, .~2.0, 'row2') "
            "(.~4.5, --5, .~1.5, 'row3') "
            "(.~4.0, --3, .~4.0, 'row4') "
            "(.~3.5, --3, .~2.5, 'row5') "
            "(.~3.0, --1, .~1.0, 'row6') "
            "(.~2.5, --4, .~4.0, 'row7') "
            "(.~2.0, --2, .~3.0, 'row8') "
            "(.~1.5, --1, .~3.5, 'row9') "
            "(.~1.0, --3, .~2.0, 'row10');"
            ==
      ::
      :+  ~2012.5.3
          %db1
          "FROM nj-tbl-a T1 ".
          "JOIN nj-tbl-b T2 ".
          "SELECT T1.*, T2.*"
      ::
      :-  %results
          :~  [%action 'SELECT']
              :-  %result-set
                  :~  :-  %vector
                          :~  [%pk-rd1 [~.rd .~1.0]]
                              [%pk-sd [~.sd --3]]
                              [%pk-rd2 [~.rd .~2.0]]
                              [%tbl-a-label [~.t 'row1']]
                              [%pk-rd1 [~.rd .~1.0]]
                              [%pk-sd [~.sd --3]]
                              [%pk-rd2 [~.rd .~2.0]]
                              [%tbl-b-label [~.t 'row10']]
                              ==
                      :-  %vector
                          :~  [%pk-rd1 [~.rd .~2.0]]
                              [%pk-sd [~.sd --2]]
                              [%pk-rd2 [~.rd .~3.0]]
                              [%tbl-a-label [~.t 'row4']]
                              [%pk-rd1 [~.rd .~2.0]]
                              [%pk-sd [~.sd --2]]
                              [%pk-rd2 [~.rd .~3.0]]
                              [%tbl-b-label [~.t 'row8']]
                              ==
                      :-  %vector
                          :~  [%pk-rd1 [~.rd .~3.0]]
                              [%pk-sd [~.sd --1]]
                              [%pk-rd2 [~.rd .~1.0]]
                              [%tbl-a-label [~.t 'row6']]
                              [%pk-rd1 [~.rd .~3.0]]
                              [%pk-sd [~.sd --1]]
                              [%pk-rd2 [~.rd .~1.0]]
                              [%tbl-b-label [~.t 'row6']]
                              ==
                      :-  %vector
                          :~  [%pk-rd1 [~.rd .~4.0]]
                              [%pk-sd [~.sd --3]]
                              [%pk-rd2 [~.rd .~4.0]]
                              [%tbl-a-label [~.t 'row7']]
                              [%pk-rd1 [~.rd .~4.0]]
                              [%pk-sd [~.sd --3]]
                              [%pk-rd2 [~.rd .~4.0]]
                              [%tbl-b-label [~.t 'row4']]
                              ==
                      :-  %vector
                          :~  [%pk-rd1 [~.rd .~5.0]]
                              [%pk-sd [~.sd --1]]
                              [%pk-rd2 [~.rd .~2.0]]
                              [%tbl-a-label [~.t 'row10']]
                              [%pk-rd1 [~.rd .~5.0]]
                              [%pk-sd [~.sd --1]]
                              [%pk-rd2 [~.rd .~2.0]]
                              [%tbl-b-label [~.t 'row2']]
                              ==
                      ==
              [%server-time ~2012.5.3]
              [%relation 'db1.dbo.nj-tbl-a']
              [%schema-time ~2012.4.30]
              [%data-time ~2012.4.30]
              [%relation 'db1.dbo.nj-tbl-b']
              [%schema-time ~2012.4.30]
              [%data-time ~2012.4.30]
              [%vector-count 5]
              ==
      ==
::
::  natural join, composite @sd @rd @sd primary key, asc/desc inverted between tables
++  test-join-30
  =|  run=@ud
  %-  exec-0-1
  :*  run
      :+  ~2012.4.30
          %db1
          %-  zing  :~
            "CREATE DATABASE db1;"
            "CREATE TABLE db1..nj-tbl-c "
            "(pk-sd1 @sd, pk-rd @rd, pk-sd2 @sd, tbl-c-label @t) "
            "PRIMARY KEY (pk-sd1 DESC, pk-rd ASC, pk-sd2 DESC);"
            "CREATE TABLE db1..nj-tbl-d "
            "(pk-sd1 @sd, pk-rd @rd, pk-sd2 @sd, tbl-d-label @t) "
            "PRIMARY KEY (pk-sd1 ASC, pk-rd DESC, pk-sd2 ASC);"
            "INSERT INTO nj-tbl-c (pk-sd1, pk-rd, pk-sd2, tbl-c-label) VALUES "
            "(--9, .~1.0, --9, 'row1') "
            "(--9, .~2.0, --7, 'row2') "
            "(--8, .~1.5, --8, 'row3') "
            "(--8, .~3.0, --6, 'row4') "
            "(--7, .~2.5, --9, 'row5') "
            "(--7, .~4.0, --5, 'row6') "
            "(--6, .~3.5, --8, 'row7') "
            "(--6, .~5.0, --4, 'row8') "
            "(--5, .~4.5, --7, 'row9') "
            "(--5, .~6.0, --3, 'row10');"
            "INSERT INTO nj-tbl-d (pk-sd1, pk-rd, pk-sd2, tbl-d-label) VALUES "
            "(--6, .~5.0, --4, 'row1') "
            "(--10, .~9.0, --1, 'row2') "
            "(--9, .~1.0, --9, 'row3') "
            "(--8, .~4.5, --2, 'row4') "
            "(--7, .~3.0, --1, 'row5') "
            "(--8, .~3.0, --6, 'row6') "
            "(--6, .~2.0, --3, 'row7') "
            "(--7, .~4.0, --5, 'row8') "
            "(--5, .~7.0, --2, 'row9') "
            "(--5, .~6.0, --3, 'row10');"
            ==
      ::
      :+  ~2012.5.3
          %db1
          "FROM nj-tbl-c T1 ".
          "JOIN nj-tbl-d T2 ".
          "SELECT T1.*, T2.*"
      ::
      :-  %results
          :~  [%action 'SELECT']
              :-  %result-set
                  :~  :-  %vector
                          :~  [%pk-sd1 [~.sd --9]]
                              [%pk-rd [~.rd .~1.0]]
                              [%pk-sd2 [~.sd --9]]
                              [%tbl-c-label [~.t 'row1']]
                              [%pk-sd1 [~.sd --9]]
                              [%pk-rd [~.rd .~1.0]]
                              [%pk-sd2 [~.sd --9]]
                              [%tbl-d-label [~.t 'row3']]
                              ==
                      :-  %vector
                          :~  [%pk-sd1 [~.sd --8]]
                              [%pk-rd [~.rd .~3.0]]
                              [%pk-sd2 [~.sd --6]]
                              [%tbl-c-label [~.t 'row4']]
                              [%pk-sd1 [~.sd --8]]
                              [%pk-rd [~.rd .~3.0]]
                              [%pk-sd2 [~.sd --6]]
                              [%tbl-d-label [~.t 'row6']]
                              ==
                      :-  %vector
                          :~  [%pk-sd1 [~.sd --7]]
                              [%pk-rd [~.rd .~4.0]]
                              [%pk-sd2 [~.sd --5]]
                              [%tbl-c-label [~.t 'row6']]
                              [%pk-sd1 [~.sd --7]]
                              [%pk-rd [~.rd .~4.0]]
                              [%pk-sd2 [~.sd --5]]
                              [%tbl-d-label [~.t 'row8']]
                              ==
                      :-  %vector
                          :~  [%pk-sd1 [~.sd --6]]
                              [%pk-rd [~.rd .~5.0]]
                              [%pk-sd2 [~.sd --4]]
                              [%tbl-c-label [~.t 'row8']]
                              [%pk-sd1 [~.sd --6]]
                              [%pk-rd [~.rd .~5.0]]
                              [%pk-sd2 [~.sd --4]]
                              [%tbl-d-label [~.t 'row1']]
                              ==
                      :-  %vector
                          :~  [%pk-sd1 [~.sd --5]]
                              [%pk-rd [~.rd .~6.0]]
                              [%pk-sd2 [~.sd --3]]
                              [%tbl-c-label [~.t 'row10']]
                              [%pk-sd1 [~.sd --5]]
                              [%pk-rd [~.rd .~6.0]]
                              [%pk-sd2 [~.sd --3]]
                              [%tbl-d-label [~.t 'row10']]
                              ==
                      ==
              [%server-time ~2012.5.3]
              [%relation 'db1.dbo.nj-tbl-c']
              [%schema-time ~2012.4.30]
              [%data-time ~2012.4.30]
              [%relation 'db1.dbo.nj-tbl-d']
              [%schema-time ~2012.4.30]
              [%data-time ~2012.4.30]
              [%vector-count 5]
              ==
      ==
::
::  partial key, 2-col PK matches 1-col PK leading prefix, same order, 1:many
++  test-join-31
  =|  run=@ud
  %-  exec-0-1
  :*  run
      :+  ~2012.4.30
          %db1
          %-  zing  :~
            "CREATE DATABASE db1;"
            "CREATE TABLE db1..tbl-a "
            "(pk1 @ud, pk2 @ud, label-a @t) "
            "PRIMARY KEY (pk1 ASC, pk2 ASC);"
            "CREATE TABLE db1..tbl-b "
            "(pk1 @ud, label-b @t) "
            "PRIMARY KEY (pk1 ASC);"
            "INSERT INTO tbl-a (pk1, pk2, label-a) VALUES "
            "(1, 10, 'a1') "
            "(1, 20, 'a2') "
            "(2, 30, 'a3') "
            "(3, 40, 'a4') "
            "(3, 50, 'a5') "
            "(4, 60, 'a6');"
            "INSERT INTO tbl-b (pk1, label-b) VALUES "
            "(1, 'b1') "
            "(3, 'b2') "
            "(5, 'b3');"
            ==
      ::
      :+  ~2012.5.3
          %db1
          "FROM tbl-a T1 ".
          "JOIN tbl-b T2 ".
          "SELECT T1.*, T2.*"
      ::
      :-  %results
          :~  [%action 'SELECT']
              :-  %result-set
                  :~  :-  %vector
                          :~  [%pk1 [~.ud 1]]
                              [%pk2 [~.ud 10]]
                              [%label-a [~.t 'a1']]
                              [%pk1 [~.ud 1]]
                              [%label-b [~.t 'b1']]
                              ==
                      :-  %vector
                          :~  [%pk1 [~.ud 1]]
                              [%pk2 [~.ud 20]]
                              [%label-a [~.t 'a2']]
                              [%pk1 [~.ud 1]]
                              [%label-b [~.t 'b1']]
                              ==
                      :-  %vector
                          :~  [%pk1 [~.ud 3]]
                              [%pk2 [~.ud 40]]
                              [%label-a [~.t 'a4']]
                              [%pk1 [~.ud 3]]
                              [%label-b [~.t 'b2']]
                              ==
                      :-  %vector
                          :~  [%pk1 [~.ud 3]]
                              [%pk2 [~.ud 50]]
                              [%label-a [~.t 'a5']]
                              [%pk1 [~.ud 3]]
                              [%label-b [~.t 'b2']]
                              ==
                      ==
              [%server-time ~2012.5.3]
              [%relation 'db1.dbo.tbl-a']
              [%schema-time ~2012.4.30]
              [%data-time ~2012.4.30]
              [%relation 'db1.dbo.tbl-b']
              [%schema-time ~2012.4.30]
              [%data-time ~2012.4.30]
              [%vector-count 4]
              ==
      ==
::
::  partial key, 2-col PK matches 1-col PK leading prefix, inverted order, 1:many
++  test-join-32
  =|  run=@ud
  %-  exec-0-1
  :*  run
      :+  ~2012.4.30
          %db1
          %-  zing  :~
            "CREATE DATABASE db1;"
            "CREATE TABLE db1..tbl-a "
            "(pk1 @ud, pk2 @ud, label-a @t) "
            "PRIMARY KEY (pk1 ASC, pk2 ASC);"
            "CREATE TABLE db1..tbl-b "
            "(pk1 @ud, label-b @t) "
            "PRIMARY KEY (pk1 DESC);"
            "INSERT INTO tbl-a (pk1, pk2, label-a) VALUES "
            "(1, 10, 'a1') "
            "(1, 20, 'a2') "
            "(2, 30, 'a3') "
            "(3, 40, 'a4') "
            "(3, 50, 'a5') "
            "(4, 60, 'a6');"
            "INSERT INTO tbl-b (pk1, label-b) VALUES "
            "(1, 'b1') "
            "(3, 'b2') "
            "(5, 'b3');"
            ==
      ::
      :+  ~2012.5.3
          %db1
          "FROM tbl-a T1 ".
          "JOIN tbl-b T2 ".
          "SELECT T1.*, T2.*"
      ::
      :-  %results
          :~  [%action 'SELECT']
              :-  %result-set
                  :~  :-  %vector
                          :~  [%pk1 [~.ud 1]]
                              [%pk2 [~.ud 10]]
                              [%label-a [~.t 'a1']]
                              [%pk1 [~.ud 1]]
                              [%label-b [~.t 'b1']]
                              ==
                      :-  %vector
                          :~  [%pk1 [~.ud 1]]
                              [%pk2 [~.ud 20]]
                              [%label-a [~.t 'a2']]
                              [%pk1 [~.ud 1]]
                              [%label-b [~.t 'b1']]
                              ==
                      :-  %vector
                          :~  [%pk1 [~.ud 3]]
                              [%pk2 [~.ud 40]]
                              [%label-a [~.t 'a4']]
                              [%pk1 [~.ud 3]]
                              [%label-b [~.t 'b2']]
                              ==
                      :-  %vector
                          :~  [%pk1 [~.ud 3]]
                              [%pk2 [~.ud 50]]
                              [%label-a [~.t 'a5']]
                              [%pk1 [~.ud 3]]
                              [%label-b [~.t 'b2']]
                              ==
                      ==
              [%server-time ~2012.5.3]
              [%relation 'db1.dbo.tbl-a']
              [%schema-time ~2012.4.30]
              [%data-time ~2012.4.30]
              [%relation 'db1.dbo.tbl-b']
              [%schema-time ~2012.4.30]
              [%data-time ~2012.4.30]
              [%vector-count 4]
              ==
      ==
::
::  partial key, 3-col PK matches 2-col PK leading prefix, same order, 1:many
++  test-join-33
  =|  run=@ud
  %-  exec-0-1
  :*  run
      :+  ~2012.4.30
          %db1
          %-  zing  :~
            "CREATE DATABASE db1;"
            "CREATE TABLE db1..tbl-a "
            "(pk1 @ud, pk2 @ud, pk3 @ud, label-a @t) "
            "PRIMARY KEY (pk1 ASC, pk2 ASC, pk3 ASC);"
            "CREATE TABLE db1..tbl-b "
            "(pk1 @ud, pk2 @ud, label-b @t) "
            "PRIMARY KEY (pk1 ASC, pk2 ASC);"
            "INSERT INTO tbl-a (pk1, pk2, pk3, label-a) VALUES "
            "(1, 10, 100, 'a1') "
            "(1, 10, 200, 'a2') "
            "(1, 20, 300, 'a3') "
            "(2, 10, 400, 'a4') "
            "(2, 20, 500, 'a5') "
            "(3, 30, 600, 'a6');"
            "INSERT INTO tbl-b (pk1, pk2, label-b) VALUES "
            "(1, 10, 'b1') "
            "(1, 20, 'b2') "
            "(2, 20, 'b3') "
            "(4, 10, 'b4');"
            ==
      ::
      :+  ~2012.5.3
          %db1
          "FROM tbl-a T1 ".
          "JOIN tbl-b T2 ".
          "SELECT T1.*, T2.*"
      ::
      :-  %results
          :~  [%action 'SELECT']
              :-  %result-set
                  :~  :-  %vector
                          :~  [%pk1 [~.ud 1]]
                              [%pk2 [~.ud 10]]
                              [%pk3 [~.ud 100]]
                              [%label-a [~.t 'a1']]
                              [%pk1 [~.ud 1]]
                              [%pk2 [~.ud 10]]
                              [%label-b [~.t 'b1']]
                              ==
                      :-  %vector
                          :~  [%pk1 [~.ud 1]]
                              [%pk2 [~.ud 10]]
                              [%pk3 [~.ud 200]]
                              [%label-a [~.t 'a2']]
                              [%pk1 [~.ud 1]]
                              [%pk2 [~.ud 10]]
                              [%label-b [~.t 'b1']]
                              ==
                      :-  %vector
                          :~  [%pk1 [~.ud 1]]
                              [%pk2 [~.ud 20]]
                              [%pk3 [~.ud 300]]
                              [%label-a [~.t 'a3']]
                              [%pk1 [~.ud 1]]
                              [%pk2 [~.ud 20]]
                              [%label-b [~.t 'b2']]
                              ==
                      :-  %vector
                          :~  [%pk1 [~.ud 2]]
                              [%pk2 [~.ud 20]]
                              [%pk3 [~.ud 500]]
                              [%label-a [~.t 'a5']]
                              [%pk1 [~.ud 2]]
                              [%pk2 [~.ud 20]]
                              [%label-b [~.t 'b3']]
                              ==
                      ==
              [%server-time ~2012.5.3]
              [%relation 'db1.dbo.tbl-a']
              [%schema-time ~2012.4.30]
              [%data-time ~2012.4.30]
              [%relation 'db1.dbo.tbl-b']
              [%schema-time ~2012.4.30]
              [%data-time ~2012.4.30]
              [%vector-count 4]
              ==
      ==
::
::  partial key, 3-col PK matches 2-col PK leading prefix, inverted order, 1:many
++  test-join-34
  =|  run=@ud
  %-  exec-0-1
  :*  run
      :+  ~2012.4.30
          %db1
          %-  zing  :~
            "CREATE DATABASE db1;"
            "CREATE TABLE db1..tbl-a "
            "(pk1 @ud, pk2 @ud, pk3 @ud, label-a @t) "
            "PRIMARY KEY (pk1 ASC, pk2 ASC, pk3 ASC);"
            "CREATE TABLE db1..tbl-b "
            "(pk1 @ud, pk2 @ud, label-b @t) "
            "PRIMARY KEY (pk1 DESC, pk2 DESC);"
            "INSERT INTO tbl-a (pk1, pk2, pk3, label-a) VALUES "
            "(1, 10, 100, 'a1') "
            "(1, 10, 200, 'a2') "
            "(1, 20, 300, 'a3') "
            "(2, 10, 400, 'a4') "
            "(2, 20, 500, 'a5') "
            "(3, 30, 600, 'a6');"
            "INSERT INTO tbl-b (pk1, pk2, label-b) VALUES "
            "(1, 10, 'b1') "
            "(1, 20, 'b2') "
            "(2, 20, 'b3') "
            "(4, 10, 'b4');"
            ==
      ::
      :+  ~2012.5.3
          %db1
          "FROM tbl-a T1 ".
          "JOIN tbl-b T2 ".
          "SELECT T1.*, T2.*"
      ::
      :-  %results
          :~  [%action 'SELECT']
              :-  %result-set
                  :~  :-  %vector
                          :~  [%pk1 [~.ud 1]]
                              [%pk2 [~.ud 10]]
                              [%pk3 [~.ud 100]]
                              [%label-a [~.t 'a1']]
                              [%pk1 [~.ud 1]]
                              [%pk2 [~.ud 10]]
                              [%label-b [~.t 'b1']]
                              ==
                      :-  %vector
                          :~  [%pk1 [~.ud 1]]
                              [%pk2 [~.ud 10]]
                              [%pk3 [~.ud 200]]
                              [%label-a [~.t 'a2']]
                              [%pk1 [~.ud 1]]
                              [%pk2 [~.ud 10]]
                              [%label-b [~.t 'b1']]
                              ==
                      :-  %vector
                          :~  [%pk1 [~.ud 1]]
                              [%pk2 [~.ud 20]]
                              [%pk3 [~.ud 300]]
                              [%label-a [~.t 'a3']]
                              [%pk1 [~.ud 1]]
                              [%pk2 [~.ud 20]]
                              [%label-b [~.t 'b2']]
                              ==
                      :-  %vector
                          :~  [%pk1 [~.ud 2]]
                              [%pk2 [~.ud 20]]
                              [%pk3 [~.ud 500]]
                              [%label-a [~.t 'a5']]
                              [%pk1 [~.ud 2]]
                              [%pk2 [~.ud 20]]
                              [%label-b [~.t 'b3']]
                              ==
                      ==
              [%server-time ~2012.5.3]
              [%relation 'db1.dbo.tbl-a']
              [%schema-time ~2012.4.30]
              [%data-time ~2012.4.30]
              [%relation 'db1.dbo.tbl-b']
              [%schema-time ~2012.4.30]
              [%data-time ~2012.4.30]
              [%vector-count 4]
              ==
      ==
::
::  partial key, 2-col PK matches 1-col PK leading prefix + non-key column match, same order
++  test-join-35
  =|  run=@ud
  %-  exec-0-1
  :*  run
      :+  ~2012.4.30
          %db1
          %-  zing  :~
            "CREATE DATABASE db1;"
            "CREATE TABLE db1..tbl-a "
            "(pk1 @ud, pk2 @ud, val @t, label-a @t) "
            "PRIMARY KEY (pk1 ASC, pk2 ASC);"
            "CREATE TABLE db1..tbl-b "
            "(pk1 @ud, val @t, label-b @t) "
            "PRIMARY KEY (pk1 ASC);"
            "INSERT INTO tbl-a (pk1, pk2, val, label-a) VALUES "
            "(1, 10, 'x', 'a1') "
            "(1, 20, 'y', 'a2') "
            "(2, 30, 'x', 'a3') "
            "(3, 40, 'x', 'a4') "
            "(3, 50, 'y', 'a5');"
            "INSERT INTO tbl-b (pk1, val, label-b) VALUES "
            "(1, 'x', 'b1') "
            "(3, 'y', 'b2') "
            "(5, 'x', 'b3');"
            ==
      ::
      :+  ~2012.5.3
          %db1
          "FROM tbl-a T1 ".
          "JOIN tbl-b T2 ".
          "SELECT T1.*, T2.*"
      ::
      :-  %results
          :~  [%action 'SELECT']
              :-  %result-set
                  :~  :-  %vector
                          :~  [%pk1 [~.ud 1]]
                              [%pk2 [~.ud 10]]
                              [%val [~.t 'x']]
                              [%label-a [~.t 'a1']]
                              [%pk1 [~.ud 1]]
                              [%val [~.t 'x']]
                              [%label-b [~.t 'b1']]
                              ==
                      :-  %vector
                          :~  [%pk1 [~.ud 3]]
                              [%pk2 [~.ud 50]]
                              [%val [~.t 'y']]
                              [%label-a [~.t 'a5']]
                              [%pk1 [~.ud 3]]
                              [%val [~.t 'y']]
                              [%label-b [~.t 'b2']]
                              ==
                      ==
              [%server-time ~2012.5.3]
              [%relation 'db1.dbo.tbl-a']
              [%schema-time ~2012.4.30]
              [%data-time ~2012.4.30]
              [%relation 'db1.dbo.tbl-b']
              [%schema-time ~2012.4.30]
              [%data-time ~2012.4.30]
              [%vector-count 2]
              ==
      ==
::
::  partial key, 2-col PK matches 1-col PK leading prefix + non-key column match, inverted order
++  test-join-36
  =|  run=@ud
  %-  exec-0-1
  :*  run
      :+  ~2012.4.30
          %db1
          %-  zing  :~
            "CREATE DATABASE db1;"
            "CREATE TABLE db1..tbl-a "
            "(pk1 @ud, pk2 @ud, val @t, label-a @t) "
            "PRIMARY KEY (pk1 ASC, pk2 ASC);"
            "CREATE TABLE db1..tbl-b "
            "(pk1 @ud, val @t, label-b @t) "
            "PRIMARY KEY (pk1 DESC);"
            "INSERT INTO tbl-a (pk1, pk2, val, label-a) VALUES "
            "(1, 10, 'x', 'a1') "
            "(1, 20, 'y', 'a2') "
            "(2, 30, 'x', 'a3') "
            "(3, 40, 'x', 'a4') "
            "(3, 50, 'y', 'a5');"
            "INSERT INTO tbl-b (pk1, val, label-b) VALUES "
            "(1, 'x', 'b1') "
            "(3, 'y', 'b2') "
            "(5, 'x', 'b3');"
            ==
      ::
      :+  ~2012.5.3
          %db1
          "FROM tbl-a T1 ".
          "JOIN tbl-b T2 ".
          "SELECT T1.*, T2.*"
      ::
      :-  %results
          :~  [%action 'SELECT']
              :-  %result-set
                  :~  :-  %vector
                          :~  [%pk1 [~.ud 1]]
                              [%pk2 [~.ud 10]]
                              [%val [~.t 'x']]
                              [%label-a [~.t 'a1']]
                              [%pk1 [~.ud 1]]
                              [%val [~.t 'x']]
                              [%label-b [~.t 'b1']]
                              ==
                      :-  %vector
                          :~  [%pk1 [~.ud 3]]
                              [%pk2 [~.ud 50]]
                              [%val [~.t 'y']]
                              [%label-a [~.t 'a5']]
                              [%pk1 [~.ud 3]]
                              [%val [~.t 'y']]
                              [%label-b [~.t 'b2']]
                              ==
                      ==
              [%server-time ~2012.5.3]
              [%relation 'db1.dbo.tbl-a']
              [%schema-time ~2012.4.30]
              [%data-time ~2012.4.30]
              [%relation 'db1.dbo.tbl-b']
              [%schema-time ~2012.4.30]
              [%data-time ~2012.4.30]
              [%vector-count 2]
              ==
      ==
::
::  partial key, 3-col PK matches 2-col PK leading prefix + non-key column match, same order
++  test-join-37
  =|  run=@ud
  %-  exec-0-1
  :*  run
      :+  ~2012.4.30
          %db1
          %-  zing  :~
            "CREATE DATABASE db1;"
            "CREATE TABLE db1..tbl-a "
            "(pk1 @ud, pk2 @ud, pk3 @ud, val @t, label-a @t) "
            "PRIMARY KEY (pk1 ASC, pk2 ASC, pk3 ASC);"
            "CREATE TABLE db1..tbl-b "
            "(pk1 @ud, pk2 @ud, val @t, label-b @t) "
            "PRIMARY KEY (pk1 ASC, pk2 ASC);"
            "INSERT INTO tbl-a (pk1, pk2, pk3, val, label-a) VALUES "
            "(1, 10, 100, 'x', 'a1') "
            "(1, 10, 200, 'y', 'a2') "
            "(1, 20, 300, 'x', 'a3') "
            "(2, 10, 400, 'x', 'a4') "
            "(2, 20, 500, 'y', 'a5');"
            "INSERT INTO tbl-b (pk1, pk2, val, label-b) VALUES "
            "(1, 10, 'y', 'b1') "
            "(1, 20, 'x', 'b2') "
            "(2, 20, 'y', 'b3');"
            ==
      ::
      :+  ~2012.5.3
          %db1
          "FROM tbl-a T1 ".
          "JOIN tbl-b T2 ".
          "SELECT T1.*, T2.*"
      ::
      :-  %results
          :~  [%action 'SELECT']
              :-  %result-set
                  :~  :-  %vector
                          :~  [%pk1 [~.ud 1]]
                              [%pk2 [~.ud 10]]
                              [%pk3 [~.ud 200]]
                              [%val [~.t 'y']]
                              [%label-a [~.t 'a2']]
                              [%pk1 [~.ud 1]]
                              [%pk2 [~.ud 10]]
                              [%val [~.t 'y']]
                              [%label-b [~.t 'b1']]
                              ==
                      :-  %vector
                          :~  [%pk1 [~.ud 1]]
                              [%pk2 [~.ud 20]]
                              [%pk3 [~.ud 300]]
                              [%val [~.t 'x']]
                              [%label-a [~.t 'a3']]
                              [%pk1 [~.ud 1]]
                              [%pk2 [~.ud 20]]
                              [%val [~.t 'x']]
                              [%label-b [~.t 'b2']]
                              ==
                      :-  %vector
                          :~  [%pk1 [~.ud 2]]
                              [%pk2 [~.ud 20]]
                              [%pk3 [~.ud 500]]
                              [%val [~.t 'y']]
                              [%label-a [~.t 'a5']]
                              [%pk1 [~.ud 2]]
                              [%pk2 [~.ud 20]]
                              [%val [~.t 'y']]
                              [%label-b [~.t 'b3']]
                              ==
                      ==
              [%server-time ~2012.5.3]
              [%relation 'db1.dbo.tbl-a']
              [%schema-time ~2012.4.30]
              [%data-time ~2012.4.30]
              [%relation 'db1.dbo.tbl-b']
              [%schema-time ~2012.4.30]
              [%data-time ~2012.4.30]
              [%vector-count 3]
              ==
      ==
::
::  partial key, 3-col PK matches 2-col PK leading prefix + non-key column match, inverted order
++  test-join-38
  =|  run=@ud
  %-  exec-0-1
  :*  run
      :+  ~2012.4.30
          %db1
          %-  zing  :~
            "CREATE DATABASE db1;"
            "CREATE TABLE db1..tbl-a "
            "(pk1 @ud, pk2 @ud, pk3 @ud, val @t, label-a @t) "
            "PRIMARY KEY (pk1 ASC, pk2 ASC, pk3 ASC);"
            "CREATE TABLE db1..tbl-b "
            "(pk1 @ud, pk2 @ud, val @t, label-b @t) "
            "PRIMARY KEY (pk1 DESC, pk2 DESC);"
            "INSERT INTO tbl-a (pk1, pk2, pk3, val, label-a) VALUES "
            "(1, 10, 100, 'x', 'a1') "
            "(1, 10, 200, 'y', 'a2') "
            "(1, 20, 300, 'x', 'a3') "
            "(2, 10, 400, 'x', 'a4') "
            "(2, 20, 500, 'y', 'a5');"
            "INSERT INTO tbl-b (pk1, pk2, val, label-b) VALUES "
            "(1, 10, 'y', 'b1') "
            "(1, 20, 'x', 'b2') "
            "(2, 20, 'y', 'b3');"
            ==
      ::
      :+  ~2012.5.3
          %db1
          "FROM tbl-a T1 ".
          "JOIN tbl-b T2 ".
          "SELECT T1.*, T2.*"
      ::
      :-  %results
          :~  [%action 'SELECT']
              :-  %result-set
                  :~  :-  %vector
                          :~  [%pk1 [~.ud 1]]
                              [%pk2 [~.ud 10]]
                              [%pk3 [~.ud 200]]
                              [%val [~.t 'y']]
                              [%label-a [~.t 'a2']]
                              [%pk1 [~.ud 1]]
                              [%pk2 [~.ud 10]]
                              [%val [~.t 'y']]
                              [%label-b [~.t 'b1']]
                              ==
                      :-  %vector
                          :~  [%pk1 [~.ud 1]]
                              [%pk2 [~.ud 20]]
                              [%pk3 [~.ud 300]]
                              [%val [~.t 'x']]
                              [%label-a [~.t 'a3']]
                              [%pk1 [~.ud 1]]
                              [%pk2 [~.ud 20]]
                              [%val [~.t 'x']]
                              [%label-b [~.t 'b2']]
                              ==
                      :-  %vector
                          :~  [%pk1 [~.ud 2]]
                              [%pk2 [~.ud 20]]
                              [%pk3 [~.ud 500]]
                              [%val [~.t 'y']]
                              [%label-a [~.t 'a5']]
                              [%pk1 [~.ud 2]]
                              [%pk2 [~.ud 20]]
                              [%val [~.t 'y']]
                              [%label-b [~.t 'b3']]
                              ==
                      ==
              [%server-time ~2012.5.3]
              [%relation 'db1.dbo.tbl-a']
              [%schema-time ~2012.4.30]
              [%data-time ~2012.4.30]
              [%relation 'db1.dbo.tbl-b']
              [%schema-time ~2012.4.30]
              [%data-time ~2012.4.30]
              [%vector-count 3]
              ==
      ==
::
::  non-contiguous key match, 3-col PK cols 1&3 match 2-col PK,
::  slow path: merge on leading col 1, filter on col 3 within groups
++  test-join-39
  =|  run=@ud
  %-  exec-0-1
  :*  run
      :+  ~2012.4.30
          %db1
          %-  zing  :~
            "CREATE DATABASE db1;"
            "CREATE TABLE db1..tbl-a "
            "(pk1 @ud, pk2 @ud, pk3 @ud, label-a @t) "
            "PRIMARY KEY (pk1 ASC, pk2 ASC, pk3 ASC);"
            "CREATE TABLE db1..tbl-b "
            "(pk1 @ud, pk3 @ud, label-b @t) "
            "PRIMARY KEY (pk1 ASC, pk3 ASC);"
            "INSERT INTO tbl-a (pk1, pk2, pk3, label-a) VALUES "
            "(1, 10, 100, 'a1') "
            "(1, 10, 200, 'a2') "
            "(1, 20, 100, 'a3') "
            "(2, 10, 300, 'a4') "
            "(2, 20, 100, 'a5') "
            "(3, 10, 200, 'a6');"
            "INSERT INTO tbl-b (pk1, pk3, label-b) VALUES "
            "(1, 100, 'b1') "
            "(1, 200, 'b2') "
            "(2, 100, 'b3') "
            "(3, 300, 'b4');"
            ==
      ::
      :+  ~2012.5.3
          %db1
          "FROM tbl-a T1 ".
          "JOIN tbl-b T2 ".
          "SELECT T1.*, T2.*"
      ::
      :-  %results
          :~  [%action 'SELECT']
              :-  %result-set
                  :~  :-  %vector
                          :~  [%pk1 [~.ud 1]]
                              [%pk2 [~.ud 10]]
                              [%pk3 [~.ud 100]]
                              [%label-a [~.t 'a1']]
                              [%pk1 [~.ud 1]]
                              [%pk3 [~.ud 100]]
                              [%label-b [~.t 'b1']]
                              ==
                      :-  %vector
                          :~  [%pk1 [~.ud 1]]
                              [%pk2 [~.ud 10]]
                              [%pk3 [~.ud 200]]
                              [%label-a [~.t 'a2']]
                              [%pk1 [~.ud 1]]
                              [%pk3 [~.ud 200]]
                              [%label-b [~.t 'b2']]
                              ==
                      :-  %vector
                          :~  [%pk1 [~.ud 1]]
                              [%pk2 [~.ud 20]]
                              [%pk3 [~.ud 100]]
                              [%label-a [~.t 'a3']]
                              [%pk1 [~.ud 1]]
                              [%pk3 [~.ud 100]]
                              [%label-b [~.t 'b1']]
                              ==
                      :-  %vector
                          :~  [%pk1 [~.ud 2]]
                              [%pk2 [~.ud 20]]
                              [%pk3 [~.ud 100]]
                              [%label-a [~.t 'a5']]
                              [%pk1 [~.ud 2]]
                              [%pk3 [~.ud 100]]
                              [%label-b [~.t 'b3']]
                              ==
                      ==
              [%server-time ~2012.5.3]
              [%relation 'db1.dbo.tbl-a']
              [%schema-time ~2012.4.30]
              [%data-time ~2012.4.30]
              [%relation 'db1.dbo.tbl-b']
              [%schema-time ~2012.4.30]
              [%data-time ~2012.4.30]
              [%vector-count 4]
              ==
      ==
::
::  many:many partial key, 2-col PK matches 2-col PK on 1-col leading prefix,
::  multiple rows on both sides produce cross product within each key group
++  test-join-40
  =|  run=@ud
  %-  exec-0-1
  :*  run
      :+  ~2012.4.30
          %db1
          %-  zing  :~
            "CREATE DATABASE db1;"
            "CREATE TABLE db1..tbl-a "
            "(pk1 @ud, pk2 @ud, label-a @t) "
            "PRIMARY KEY (pk1 ASC, pk2 ASC);"
            "CREATE TABLE db1..tbl-b "
            "(pk1 @ud, pk2b @ud, label-b @t) "
            "PRIMARY KEY (pk1 ASC, pk2b ASC);"
            "INSERT INTO tbl-a (pk1, pk2, label-a) VALUES "
            "(1, 10, 'a1') "
            "(1, 20, 'a2') "
            "(2, 30, 'a3') "
            "(4, 40, 'a4');"
            "INSERT INTO tbl-b (pk1, pk2b, label-b) VALUES "
            "(1, 100, 'b1') "
            "(1, 200, 'b2') "
            "(1, 300, 'b3') "
            "(2, 400, 'b4') "
            "(5, 500, 'b5');"
            ==
      ::
      :+  ~2012.5.3
          %db1
          "FROM tbl-a T1 ".
          "JOIN tbl-b T2 ".
          "SELECT T1.*, T2.*"
      ::
      :-  %results
          :~  [%action 'SELECT']
              :-  %result-set
                  :~  :-  %vector
                          :~  [%pk1 [~.ud 1]]
                              [%pk2 [~.ud 10]]
                              [%label-a [~.t 'a1']]
                              [%pk1 [~.ud 1]]
                              [%pk2b [~.ud 100]]
                              [%label-b [~.t 'b1']]
                              ==
                      :-  %vector
                          :~  [%pk1 [~.ud 1]]
                              [%pk2 [~.ud 10]]
                              [%label-a [~.t 'a1']]
                              [%pk1 [~.ud 1]]
                              [%pk2b [~.ud 200]]
                              [%label-b [~.t 'b2']]
                              ==
                      :-  %vector
                          :~  [%pk1 [~.ud 1]]
                              [%pk2 [~.ud 10]]
                              [%label-a [~.t 'a1']]
                              [%pk1 [~.ud 1]]
                              [%pk2b [~.ud 300]]
                              [%label-b [~.t 'b3']]
                              ==
                      :-  %vector
                          :~  [%pk1 [~.ud 1]]
                              [%pk2 [~.ud 20]]
                              [%label-a [~.t 'a2']]
                              [%pk1 [~.ud 1]]
                              [%pk2b [~.ud 100]]
                              [%label-b [~.t 'b1']]
                              ==
                      :-  %vector
                          :~  [%pk1 [~.ud 1]]
                              [%pk2 [~.ud 20]]
                              [%label-a [~.t 'a2']]
                              [%pk1 [~.ud 1]]
                              [%pk2b [~.ud 200]]
                              [%label-b [~.t 'b2']]
                              ==
                      :-  %vector
                          :~  [%pk1 [~.ud 1]]
                              [%pk2 [~.ud 20]]
                              [%label-a [~.t 'a2']]
                              [%pk1 [~.ud 1]]
                              [%pk2b [~.ud 300]]
                              [%label-b [~.t 'b3']]
                              ==
                      :-  %vector
                          :~  [%pk1 [~.ud 2]]
                              [%pk2 [~.ud 30]]
                              [%label-a [~.t 'a3']]
                              [%pk1 [~.ud 2]]
                              [%pk2b [~.ud 400]]
                              [%label-b [~.t 'b4']]
                              ==
                      ==
              [%server-time ~2012.5.3]
              [%relation 'db1.dbo.tbl-a']
              [%schema-time ~2012.4.30]
              [%data-time ~2012.4.30]
              [%relation 'db1.dbo.tbl-b']
              [%schema-time ~2012.4.30]
              [%data-time ~2012.4.30]
              [%vector-count 7]
              ==
      ==
::
::  3-table partial key join, A(2-col PK) JOIN B(1-col PK) JOIN C(1-col PK),
::  leading prefix match on pk1 at each step
++  test-join-41
  =|  run=@ud
  %-  exec-0-1
  :*  run
      :+  ~2012.4.30
          %db1
          %-  zing  :~
            "CREATE DATABASE db1;"
            "CREATE TABLE db1..tbl-a "
            "(pk1 @ud, pk2 @ud, label-a @t) "
            "PRIMARY KEY (pk1 ASC, pk2 ASC);"
            "CREATE TABLE db1..tbl-b "
            "(pk1 @ud, label-b @t) "
            "PRIMARY KEY (pk1 ASC);"
            "CREATE TABLE db1..tbl-c "
            "(pk1 @ud, label-c @t) "
            "PRIMARY KEY (pk1 ASC);"
            "INSERT INTO tbl-a (pk1, pk2, label-a) VALUES "
            "(1, 10, 'a1') "
            "(1, 20, 'a2') "
            "(2, 30, 'a3') "
            "(2, 40, 'a4') "
            "(3, 50, 'a5') "
            "(4, 60, 'a6');"
            "INSERT INTO tbl-b (pk1, label-b) VALUES "
            "(1, 'b1') "
            "(2, 'b2') "
            "(3, 'b3') "
            "(5, 'b4');"
            "INSERT INTO tbl-c (pk1, label-c) VALUES "
            "(1, 'c1') "
            "(2, 'c2') "
            "(6, 'c3');"
            ==
      ::
      :+  ~2012.5.3
          %db1
          "FROM tbl-a T1 ".
          "JOIN tbl-b T2 ".
          "JOIN tbl-c T3 ".
          "SELECT T1.*, T2.*, T3.*"
      ::
      :-  %results
          :~  [%action 'SELECT']
              :-  %result-set
                  :~  :-  %vector
                          :~  [%pk1 [~.ud 1]]
                              [%pk2 [~.ud 10]]
                              [%label-a [~.t 'a1']]
                              [%pk1 [~.ud 1]]
                              [%label-b [~.t 'b1']]
                              [%pk1 [~.ud 1]]
                              [%label-c [~.t 'c1']]
                              ==
                      :-  %vector
                          :~  [%pk1 [~.ud 1]]
                              [%pk2 [~.ud 20]]
                              [%label-a [~.t 'a2']]
                              [%pk1 [~.ud 1]]
                              [%label-b [~.t 'b1']]
                              [%pk1 [~.ud 1]]
                              [%label-c [~.t 'c1']]
                              ==
                      :-  %vector
                          :~  [%pk1 [~.ud 2]]
                              [%pk2 [~.ud 30]]
                              [%label-a [~.t 'a3']]
                              [%pk1 [~.ud 2]]
                              [%label-b [~.t 'b2']]
                              [%pk1 [~.ud 2]]
                              [%label-c [~.t 'c2']]
                              ==
                      :-  %vector
                          :~  [%pk1 [~.ud 2]]
                              [%pk2 [~.ud 40]]
                              [%label-a [~.t 'a4']]
                              [%pk1 [~.ud 2]]
                              [%label-b [~.t 'b2']]
                              [%pk1 [~.ud 2]]
                              [%label-c [~.t 'c2']]
                              ==
                      ==
              [%server-time ~2012.5.3]
              [%relation 'db1.dbo.tbl-a']
              [%schema-time ~2012.4.30]
              [%data-time ~2012.4.30]
              [%relation 'db1.dbo.tbl-b']
              [%schema-time ~2012.4.30]
              [%data-time ~2012.4.30]
              [%relation 'db1.dbo.tbl-c']
              [%schema-time ~2012.4.30]
              [%data-time ~2012.4.30]
              [%vector-count 4]
              ==
      ==
::
::  no primary key overlap, single non-key column match (color), hash join path
::  both tables have PKs with different column names, join on shared non-key column
++  test-join-42
  =|  run=@ud
  %-  exec-0-1
  :*  run
      :+  ~2012.4.30
          %db1
          %-  zing  :~
            "CREATE DATABASE db1;"
            "CREATE TABLE db1..tbl-a "
            "(key-a @ud, color @t, label-a @t) "
            "PRIMARY KEY (key-a ASC);"
            "CREATE TABLE db1..tbl-b "
            "(key-b @ud, color @t, label-b @t) "
            "PRIMARY KEY (key-b ASC);"
            "INSERT INTO tbl-a (key-a, color, label-a) VALUES "
            "(1, 'red', 'a1') "
            "(2, 'blue', 'a2') "
            "(3, 'red', 'a3') "
            "(4, 'green', 'a4');"
            "INSERT INTO tbl-b (key-b, color, label-b) VALUES "
            "(10, 'red', 'b1') "
            "(20, 'blue', 'b2') "
            "(30, 'yellow', 'b3');"
            ==
      ::
      :+  ~2012.5.3
          %db1
          "FROM tbl-a T1 ".
          "JOIN tbl-b T2 ".
          "SELECT T1.*, T2.*"
      ::
      :-  %results
          :~  [%action 'SELECT']
              :-  %result-set
                  :~  :-  %vector
                          :~  [%key-a [~.ud 1]]
                              [%color [~.t 'red']]
                              [%label-a [~.t 'a1']]
                              [%key-b [~.ud 10]]
                              [%color [~.t 'red']]
                              [%label-b [~.t 'b1']]
                              ==
                      :-  %vector
                          :~  [%key-a [~.ud 2]]
                              [%color [~.t 'blue']]
                              [%label-a [~.t 'a2']]
                              [%key-b [~.ud 20]]
                              [%color [~.t 'blue']]
                              [%label-b [~.t 'b2']]
                              ==
                      :-  %vector
                          :~  [%key-a [~.ud 3]]
                              [%color [~.t 'red']]
                              [%label-a [~.t 'a3']]
                              [%key-b [~.ud 10]]
                              [%color [~.t 'red']]
                              [%label-b [~.t 'b1']]
                              ==
                      ==
              [%server-time ~2012.5.3]
              [%relation 'db1.dbo.tbl-a']
              [%schema-time ~2012.4.30]
              [%data-time ~2012.4.30]
              [%relation 'db1.dbo.tbl-b']
              [%schema-time ~2012.4.30]
              [%data-time ~2012.4.30]
              [%vector-count 3]
              ==
      ==
::
::  no primary key overlap, multiple non-key matching columns (color + size), hash join
::  both tables have PKs with different column names, join on two shared non-key columns
++  test-join-43
  =|  run=@ud
  %-  exec-0-1
  :*  run
      :+  ~2012.4.30
          %db1
          %-  zing  :~
            "CREATE DATABASE db1;"
            "CREATE TABLE db1..tbl-a "
            "(key-a @ud, color @t, size @ud, label-a @t) "
            "PRIMARY KEY (key-a ASC);"
            "CREATE TABLE db1..tbl-b "
            "(key-b @ud, color @t, size @ud, label-b @t) "
            "PRIMARY KEY (key-b ASC);"
            "INSERT INTO tbl-a (key-a, color, size, label-a) VALUES "
            "(1, 'red', 10, 'a1') "
            "(2, 'blue', 20, 'a2') "
            "(3, 'red', 10, 'a3') "
            "(4, 'green', 30, 'a4') "
            "(5, 'blue', 20, 'a5');"
            "INSERT INTO tbl-b (key-b, color, size, label-b) VALUES "
            "(10, 'red', 10, 'b1') "
            "(20, 'blue', 20, 'b2') "
            "(30, 'red', 30, 'b3') "
            "(40, 'yellow', 10, 'b4');"
            ==
      ::
      :+  ~2012.5.3
          %db1
          "FROM tbl-a T1 ".
          "JOIN tbl-b T2 ".
          "SELECT T1.*, T2.*"
      ::
      :-  %results
          :~  [%action 'SELECT']
              :-  %result-set
                  :~  :-  %vector
                          :~  [%key-a [~.ud 1]]
                              [%color [~.t 'red']]
                              [%size [~.ud 10]]
                              [%label-a [~.t 'a1']]
                              [%key-b [~.ud 10]]
                              [%color [~.t 'red']]
                              [%size [~.ud 10]]
                              [%label-b [~.t 'b1']]
                              ==
                      :-  %vector
                          :~  [%key-a [~.ud 2]]
                              [%color [~.t 'blue']]
                              [%size [~.ud 20]]
                              [%label-a [~.t 'a2']]
                              [%key-b [~.ud 20]]
                              [%color [~.t 'blue']]
                              [%size [~.ud 20]]
                              [%label-b [~.t 'b2']]
                              ==
                      :-  %vector
                          :~  [%key-a [~.ud 3]]
                              [%color [~.t 'red']]
                              [%size [~.ud 10]]
                              [%label-a [~.t 'a3']]
                              [%key-b [~.ud 10]]
                              [%color [~.t 'red']]
                              [%size [~.ud 10]]
                              [%label-b [~.t 'b1']]
                              ==
                      :-  %vector
                          :~  [%key-a [~.ud 5]]
                              [%color [~.t 'blue']]
                              [%size [~.ud 20]]
                              [%label-a [~.t 'a5']]
                              [%key-b [~.ud 20]]
                              [%color [~.t 'blue']]
                              [%size [~.ud 20]]
                              [%label-b [~.t 'b2']]
                              ==
                      ==
              [%server-time ~2012.5.3]
              [%relation 'db1.dbo.tbl-a']
              [%schema-time ~2012.4.30]
              [%data-time ~2012.4.30]
              [%relation 'db1.dbo.tbl-b']
              [%schema-time ~2012.4.30]
              [%data-time ~2012.4.30]
              [%vector-count 4]
              ==
      ==
::
::  no primary key overlap, many:many cross product on non-key column, hash join
::  3 A-rows and 2 B-rows share color 'x', producing 3x2=6 joined rows
++  test-join-44
  =|  run=@ud
  %-  exec-0-1
  :*  run
      :+  ~2012.4.30
          %db1
          %-  zing  :~
            "CREATE DATABASE db1;"
            "CREATE TABLE db1..tbl-a "
            "(key-a @ud, color @t, label-a @t) "
            "PRIMARY KEY (key-a ASC);"
            "CREATE TABLE db1..tbl-b "
            "(key-b @ud, color @t, label-b @t) "
            "PRIMARY KEY (key-b ASC);"
            "INSERT INTO tbl-a (key-a, color, label-a) VALUES "
            "(1, 'x', 'a1') "
            "(2, 'x', 'a2') "
            "(3, 'x', 'a3') "
            "(4, 'y', 'a4') "
            "(5, 'z', 'a5');"
            "INSERT INTO tbl-b (key-b, color, label-b) VALUES "
            "(10, 'x', 'b1') "
            "(20, 'x', 'b2') "
            "(30, 'y', 'b3') "
            "(40, 'w', 'b4');"
            ==
      ::
      :+  ~2012.5.3
          %db1
          "FROM tbl-a T1 ".
          "JOIN tbl-b T2 ".
          "SELECT T1.*, T2.*"
      ::
      :-  %results
          :~  [%action 'SELECT']
              :-  %result-set
                  :~  :-  %vector
                          :~  [%key-a [~.ud 1]]
                              [%color [~.t 'x']]
                              [%label-a [~.t 'a1']]
                              [%key-b [~.ud 10]]
                              [%color [~.t 'x']]
                              [%label-b [~.t 'b1']]
                              ==
                      :-  %vector
                          :~  [%key-a [~.ud 1]]
                              [%color [~.t 'x']]
                              [%label-a [~.t 'a1']]
                              [%key-b [~.ud 20]]
                              [%color [~.t 'x']]
                              [%label-b [~.t 'b2']]
                              ==
                      :-  %vector
                          :~  [%key-a [~.ud 2]]
                              [%color [~.t 'x']]
                              [%label-a [~.t 'a2']]
                              [%key-b [~.ud 10]]
                              [%color [~.t 'x']]
                              [%label-b [~.t 'b1']]
                              ==
                      :-  %vector
                          :~  [%key-a [~.ud 2]]
                              [%color [~.t 'x']]
                              [%label-a [~.t 'a2']]
                              [%key-b [~.ud 20]]
                              [%color [~.t 'x']]
                              [%label-b [~.t 'b2']]
                              ==
                      :-  %vector
                          :~  [%key-a [~.ud 3]]
                              [%color [~.t 'x']]
                              [%label-a [~.t 'a3']]
                              [%key-b [~.ud 10]]
                              [%color [~.t 'x']]
                              [%label-b [~.t 'b1']]
                              ==
                      :-  %vector
                          :~  [%key-a [~.ud 3]]
                              [%color [~.t 'x']]
                              [%label-a [~.t 'a3']]
                              [%key-b [~.ud 20]]
                              [%color [~.t 'x']]
                              [%label-b [~.t 'b2']]
                              ==
                      :-  %vector
                          :~  [%key-a [~.ud 4]]
                              [%color [~.t 'y']]
                              [%label-a [~.t 'a4']]
                              [%key-b [~.ud 30]]
                              [%color [~.t 'y']]
                              [%label-b [~.t 'b3']]
                              ==
                      ==
              [%server-time ~2012.5.3]
              [%relation 'db1.dbo.tbl-a']
              [%schema-time ~2012.4.30]
              [%data-time ~2012.4.30]
              [%relation 'db1.dbo.tbl-b']
              [%schema-time ~2012.4.30]
              [%data-time ~2012.4.30]
              [%vector-count 7]
              ==
      ==
::
::  asymmetric: matching column (pk1) is in A's primary key but not B's,
::  no PK column overlap between tables, hash join on pk1
++  test-join-45
  =|  run=@ud
  %-  exec-0-1
  :*  run
      :+  ~2012.4.30
          %db1
          %-  zing  :~
            "CREATE DATABASE db1;"
            "CREATE TABLE db1..tbl-a "
            "(pk1 @ud, pk2 @ud, label-a @t) "
            "PRIMARY KEY (pk1 ASC, pk2 ASC);"
            "CREATE TABLE db1..tbl-b "
            "(key-b @ud, pk1 @ud, label-b @t) "
            "PRIMARY KEY (key-b ASC);"
            "INSERT INTO tbl-a (pk1, pk2, label-a) VALUES "
            "(1, 10, 'a1') "
            "(1, 20, 'a2') "
            "(2, 30, 'a3') "
            "(3, 40, 'a4') "
            "(4, 50, 'a5');"
            "INSERT INTO tbl-b (key-b, pk1, label-b) VALUES "
            "(100, 1, 'b1') "
            "(200, 3, 'b2') "
            "(300, 5, 'b3');"
            ==
      ::
      :+  ~2012.5.3
          %db1
          "FROM tbl-a T1 ".
          "JOIN tbl-b T2 ".
          "SELECT T1.*, T2.*"
      ::
      :-  %results
          :~  [%action 'SELECT']
              :-  %result-set
                  :~  :-  %vector
                          :~  [%pk1 [~.ud 1]]
                              [%pk2 [~.ud 10]]
                              [%label-a [~.t 'a1']]
                              [%key-b [~.ud 100]]
                              [%pk1 [~.ud 1]]
                              [%label-b [~.t 'b1']]
                              ==
                      :-  %vector
                          :~  [%pk1 [~.ud 1]]
                              [%pk2 [~.ud 20]]
                              [%label-a [~.t 'a2']]
                              [%key-b [~.ud 100]]
                              [%pk1 [~.ud 1]]
                              [%label-b [~.t 'b1']]
                              ==
                      :-  %vector
                          :~  [%pk1 [~.ud 3]]
                              [%pk2 [~.ud 40]]
                              [%label-a [~.t 'a4']]
                              [%key-b [~.ud 200]]
                              [%pk1 [~.ud 3]]
                              [%label-b [~.t 'b2']]
                              ==
                      ==
              [%server-time ~2012.5.3]
              [%relation 'db1.dbo.tbl-a']
              [%schema-time ~2012.4.30]
              [%data-time ~2012.4.30]
              [%relation 'db1.dbo.tbl-b']
              [%schema-time ~2012.4.30]
              [%data-time ~2012.4.30]
              [%vector-count 3]
              ==
      ==
::
::  3-table join, no key overlap at either step,
::  A JOIN B on grp (non-key), result JOIN C on cat (non-key),
::  different matching columns at each join step
++  test-join-46
  =|  run=@ud
  %-  exec-0-1
  :*  run
      :+  ~2012.4.30
          %db1
          %-  zing  :~
            "CREATE DATABASE db1;"
            "CREATE TABLE db1..tbl-a "
            "(key-a @ud, grp @t, label-a @t) "
            "PRIMARY KEY (key-a ASC);"
            "CREATE TABLE db1..tbl-b "
            "(key-b @ud, grp @t, cat @t, label-b @t) "
            "PRIMARY KEY (key-b ASC);"
            "CREATE TABLE db1..tbl-c "
            "(key-c @ud, cat @t, label-c @t) "
            "PRIMARY KEY (key-c ASC);"
            "INSERT INTO tbl-a (key-a, grp, label-a) VALUES "
            "(1, 'x', 'a1') "
            "(2, 'y', 'a2') "
            "(3, 'x', 'a3') "
            "(4, 'z', 'a4');"
            "INSERT INTO tbl-b (key-b, grp, cat, label-b) VALUES "
            "(10, 'x', 'p', 'b1') "
            "(20, 'y', 'q', 'b2') "
            "(30, 'w', 'p', 'b3');"
            "INSERT INTO tbl-c (key-c, cat, label-c) VALUES "
            "(100, 'p', 'c1') "
            "(200, 'r', 'c2') "
            "(300, 'q', 'c3');"
            ==
      ::
      :+  ~2012.5.3
          %db1
          "FROM tbl-a T1 ".
          "JOIN tbl-b T2 ".
          "JOIN tbl-c T3 ".
          "SELECT T1.*, T2.*, T3.*"
      ::
      :-  %results
          :~  [%action 'SELECT']
              :-  %result-set
                  :~  :-  %vector
                          :~  [%key-a [~.ud 1]]
                              [%grp [~.t 'x']]
                              [%label-a [~.t 'a1']]
                              [%key-b [~.ud 10]]
                              [%grp [~.t 'x']]
                              [%cat [~.t 'p']]
                              [%label-b [~.t 'b1']]
                              [%key-c [~.ud 100]]
                              [%cat [~.t 'p']]
                              [%label-c [~.t 'c1']]
                              ==
                      :-  %vector
                          :~  [%key-a [~.ud 2]]
                              [%grp [~.t 'y']]
                              [%label-a [~.t 'a2']]
                              [%key-b [~.ud 20]]
                              [%grp [~.t 'y']]
                              [%cat [~.t 'q']]
                              [%label-b [~.t 'b2']]
                              [%key-c [~.ud 300]]
                              [%cat [~.t 'q']]
                              [%label-c [~.t 'c3']]
                              ==
                      :-  %vector
                          :~  [%key-a [~.ud 3]]
                              [%grp [~.t 'x']]
                              [%label-a [~.t 'a3']]
                              [%key-b [~.ud 10]]
                              [%grp [~.t 'x']]
                              [%cat [~.t 'p']]
                              [%label-b [~.t 'b1']]
                              [%key-c [~.ud 100]]
                              [%cat [~.t 'p']]
                              [%label-c [~.t 'c1']]
                              ==
                      ==
              [%server-time ~2012.5.3]
              [%relation 'db1.dbo.tbl-a']
              [%schema-time ~2012.4.30]
              [%data-time ~2012.4.30]
              [%relation 'db1.dbo.tbl-b']
              [%schema-time ~2012.4.30]
              [%data-time ~2012.4.30]
              [%relation 'db1.dbo.tbl-c']
              [%schema-time ~2012.4.30]
              [%data-time ~2012.4.30]
              [%vector-count 3]
              ==
      ==
::
::  3-table, full key match with inverted order at 2nd join, joined-row prior
::  A JOIN B (perfect match) produces joined-rows, AB JOIN C (inverted id DESC)
++  test-join-47
  =|  run=@ud
  %-  exec-0-1
  :*  run
      :+  ~2012.4.30
          %db1
          %-  zing  :~
            "CREATE DATABASE db1;"
            "CREATE TABLE db1..tbl-a "
            "(id @ud, label-a @t) "
            "PRIMARY KEY (id ASC);"
            "CREATE TABLE db1..tbl-b "
            "(id @ud, label-b @t) "
            "PRIMARY KEY (id ASC);"
            "CREATE TABLE db1..tbl-c "
            "(id @ud, label-c @t) "
            "PRIMARY KEY (id DESC);"
            "INSERT INTO tbl-a (id, label-a) VALUES "
            "(1, 'a1') "
            "(2, 'a2') "
            "(3, 'a3') "
            "(4, 'a4');"
            "INSERT INTO tbl-b (id, label-b) VALUES "
            "(1, 'b1') "
            "(2, 'b2') "
            "(3, 'b3') "
            "(5, 'b5');"
            "INSERT INTO tbl-c (id, label-c) VALUES "
            "(1, 'c1') "
            "(3, 'c3') "
            "(6, 'c6');"
            ==
      ::
      :+  ~2012.5.3
          %db1
          "FROM tbl-a T1 ".
          "JOIN tbl-b T2 ".
          "JOIN tbl-c T3 ".
          "SELECT T1.*, T2.*, T3.*"
      ::
      :-  %results
          :~  [%action 'SELECT']
              :-  %result-set
                  :~  :-  %vector
                          :~  [%id [~.ud 1]]
                              [%label-a [~.t 'a1']]
                              [%id [~.ud 1]]
                              [%label-b [~.t 'b1']]
                              [%id [~.ud 1]]
                              [%label-c [~.t 'c1']]
                              ==
                      :-  %vector
                          :~  [%id [~.ud 3]]
                              [%label-a [~.t 'a3']]
                              [%id [~.ud 3]]
                              [%label-b [~.t 'b3']]
                              [%id [~.ud 3]]
                              [%label-c [~.t 'c3']]
                              ==
                      ==
              [%server-time ~2012.5.3]
              [%relation 'db1.dbo.tbl-a']
              [%schema-time ~2012.4.30]
              [%data-time ~2012.4.30]
              [%relation 'db1.dbo.tbl-b']
              [%schema-time ~2012.4.30]
              [%data-time ~2012.4.30]
              [%relation 'db1.dbo.tbl-c']
              [%schema-time ~2012.4.30]
              [%data-time ~2012.4.30]
              [%vector-count 2]
              ==
      ==
::
::  3-table, partial key with inverted order at 2nd join, joined-row prior
::  A JOIN B (perfect match on pk1), AB JOIN C (pk1 DESC partial of pk1 DESC, pk2c ASC)
++  test-join-48
  =|  run=@ud
  %-  exec-0-1
  :*  run
      :+  ~2012.4.30
          %db1
          %-  zing  :~
            "CREATE DATABASE db1;"
            "CREATE TABLE db1..tbl-a "
            "(pk1 @ud, label-a @t) "
            "PRIMARY KEY (pk1 ASC);"
            "CREATE TABLE db1..tbl-b "
            "(pk1 @ud, label-b @t) "
            "PRIMARY KEY (pk1 ASC);"
            "CREATE TABLE db1..tbl-c "
            "(pk1 @ud, pk2c @ud, label-c @t) "
            "PRIMARY KEY (pk1 DESC, pk2c ASC);"
            "INSERT INTO tbl-a (pk1, label-a) VALUES "
            "(1, 'a1') "
            "(2, 'a2') "
            "(3, 'a3') "
            "(4, 'a4');"
            "INSERT INTO tbl-b (pk1, label-b) VALUES "
            "(1, 'b1') "
            "(2, 'b2') "
            "(3, 'b3') "
            "(5, 'b5');"
            "INSERT INTO tbl-c (pk1, pk2c, label-c) VALUES "
            "(1, 10, 'c1') "
            "(1, 20, 'c2') "
            "(2, 30, 'c3') "
            "(3, 40, 'c4') "
            "(6, 50, 'c5');"
            ==
      ::
      :+  ~2012.5.3
          %db1
          "FROM tbl-a T1 ".
          "JOIN tbl-b T2 ".
          "JOIN tbl-c T3 ".
          "SELECT T1.*, T2.*, T3.*"
      ::
      :-  %results
          :~  [%action 'SELECT']
              :-  %result-set
                  :~  :-  %vector
                          :~  [%pk1 [~.ud 1]]
                              [%label-a [~.t 'a1']]
                              [%pk1 [~.ud 1]]
                              [%label-b [~.t 'b1']]
                              [%pk1 [~.ud 1]]
                              [%pk2c [~.ud 10]]
                              [%label-c [~.t 'c1']]
                              ==
                      :-  %vector
                          :~  [%pk1 [~.ud 1]]
                              [%label-a [~.t 'a1']]
                              [%pk1 [~.ud 1]]
                              [%label-b [~.t 'b1']]
                              [%pk1 [~.ud 1]]
                              [%pk2c [~.ud 20]]
                              [%label-c [~.t 'c2']]
                              ==
                      :-  %vector
                          :~  [%pk1 [~.ud 2]]
                              [%label-a [~.t 'a2']]
                              [%pk1 [~.ud 2]]
                              [%label-b [~.t 'b2']]
                              [%pk1 [~.ud 2]]
                              [%pk2c [~.ud 30]]
                              [%label-c [~.t 'c3']]
                              ==
                      :-  %vector
                          :~  [%pk1 [~.ud 3]]
                              [%label-a [~.t 'a3']]
                              [%pk1 [~.ud 3]]
                              [%label-b [~.t 'b3']]
                              [%pk1 [~.ud 3]]
                              [%pk2c [~.ud 40]]
                              [%label-c [~.t 'c4']]
                              ==
                      ==
              [%server-time ~2012.5.3]
              [%relation 'db1.dbo.tbl-a']
              [%schema-time ~2012.4.30]
              [%data-time ~2012.4.30]
              [%relation 'db1.dbo.tbl-b']
              [%schema-time ~2012.4.30]
              [%data-time ~2012.4.30]
              [%relation 'db1.dbo.tbl-c']
              [%schema-time ~2012.4.30]
              [%data-time ~2012.4.30]
              [%vector-count 4]
              ==
      ==
::
::  3-table, partial key + non-key column match at 2nd join, joined-row prior
::  A JOIN B (perfect match on pk1), AB JOIN C (partial pk1 + non-key val filter)
::  val column is in B's columns, carried through joined-row
++  test-join-49
  =|  run=@ud
  %-  exec-0-1
  :*  run
      :+  ~2012.4.30
          %db1
          %-  zing  :~
            "CREATE DATABASE db1;"
            "CREATE TABLE db1..tbl-a "
            "(pk1 @ud, label-a @t) "
            "PRIMARY KEY (pk1 ASC);"
            "CREATE TABLE db1..tbl-b "
            "(pk1 @ud, val @t, label-b @t) "
            "PRIMARY KEY (pk1 ASC);"
            "CREATE TABLE db1..tbl-c "
            "(pk1 @ud, pk2c @ud, val @t, label-c @t) "
            "PRIMARY KEY (pk1 ASC, pk2c ASC);"
            "INSERT INTO tbl-a (pk1, label-a) VALUES "
            "(1, 'a1') "
            "(2, 'a2') "
            "(3, 'a3') "
            "(4, 'a4');"
            "INSERT INTO tbl-b (pk1, val, label-b) VALUES "
            "(1, 'x', 'b1') "
            "(2, 'y', 'b2') "
            "(3, 'x', 'b3') "
            "(5, 'z', 'b5');"
            "INSERT INTO tbl-c (pk1, pk2c, val, label-c) VALUES "
            "(1, 10, 'x', 'c1') "
            "(1, 20, 'y', 'c2') "
            "(2, 30, 'y', 'c3') "
            "(3, 40, 'x', 'c4') "
            "(6, 50, 'w', 'c5');"
            ==
      ::
      :+  ~2012.5.3
          %db1
          "FROM tbl-a T1 ".
          "JOIN tbl-b T2 ".
          "JOIN tbl-c T3 ".
          "SELECT T1.*, T2.*, T3.*"
      ::
      :-  %results
          :~  [%action 'SELECT']
              :-  %result-set
                  :~  :-  %vector
                          :~  [%pk1 [~.ud 1]]
                              [%label-a [~.t 'a1']]
                              [%pk1 [~.ud 1]]
                              [%val [~.t 'x']]
                              [%label-b [~.t 'b1']]
                              [%pk1 [~.ud 1]]
                              [%pk2c [~.ud 10]]
                              [%val [~.t 'x']]
                              [%label-c [~.t 'c1']]
                              ==
                      :-  %vector
                          :~  [%pk1 [~.ud 2]]
                              [%label-a [~.t 'a2']]
                              [%pk1 [~.ud 2]]
                              [%val [~.t 'y']]
                              [%label-b [~.t 'b2']]
                              [%pk1 [~.ud 2]]
                              [%pk2c [~.ud 30]]
                              [%val [~.t 'y']]
                              [%label-c [~.t 'c3']]
                              ==
                      :-  %vector
                          :~  [%pk1 [~.ud 3]]
                              [%label-a [~.t 'a3']]
                              [%pk1 [~.ud 3]]
                              [%val [~.t 'x']]
                              [%label-b [~.t 'b3']]
                              [%pk1 [~.ud 3]]
                              [%pk2c [~.ud 40]]
                              [%val [~.t 'x']]
                              [%label-c [~.t 'c4']]
                              ==
                      ==
              [%server-time ~2012.5.3]
              [%relation 'db1.dbo.tbl-a']
              [%schema-time ~2012.4.30]
              [%data-time ~2012.4.30]
              [%relation 'db1.dbo.tbl-b']
              [%schema-time ~2012.4.30]
              [%data-time ~2012.4.30]
              [%relation 'db1.dbo.tbl-c']
              [%schema-time ~2012.4.30]
              [%data-time ~2012.4.30]
              [%vector-count 3]
              ==
      ==
::
::  3-table, non-contiguous key match at 2nd join, joined-row prior
::  A JOIN B (perfect match on pk1+pk3), AB JOIN C (leading pk1, non-contiguous pk3)
++  test-join-50
  =|  run=@ud
  %-  exec-0-1
  :*  run
      :+  ~2012.4.30
          %db1
          %-  zing  :~
            "CREATE DATABASE db1;"
            "CREATE TABLE db1..tbl-a "
            "(pk1 @ud, pk3 @ud, label-a @t) "
            "PRIMARY KEY (pk1 ASC, pk3 ASC);"
            "CREATE TABLE db1..tbl-b "
            "(pk1 @ud, pk3 @ud, label-b @t) "
            "PRIMARY KEY (pk1 ASC, pk3 ASC);"
            "CREATE TABLE db1..tbl-c "
            "(pk1 @ud, pk2c @ud, pk3 @ud, label-c @t) "
            "PRIMARY KEY (pk1 ASC, pk2c ASC, pk3 ASC);"
            "INSERT INTO tbl-a (pk1, pk3, label-a) VALUES "
            "(1, 100, 'a1') "
            "(1, 200, 'a2') "
            "(2, 100, 'a3') "
            "(3, 300, 'a4') "
            "(4, 100, 'a5');"
            "INSERT INTO tbl-b (pk1, pk3, label-b) VALUES "
            "(1, 100, 'b1') "
            "(1, 200, 'b2') "
            "(2, 100, 'b3') "
            "(3, 300, 'b4') "
            "(5, 500, 'b5');"
            "INSERT INTO tbl-c (pk1, pk2c, pk3, label-c) VALUES "
            "(1, 10, 100, 'c1') "
            "(1, 20, 200, 'c2') "
            "(2, 30, 300, 'c3') "
            "(2, 40, 100, 'c4') "
            "(3, 50, 400, 'c5') "
            "(6, 60, 100, 'c6');"
            ==
      ::
      :+  ~2012.5.3
          %db1
          "FROM tbl-a T1 ".
          "JOIN tbl-b T2 ".
          "JOIN tbl-c T3 ".
          "SELECT T1.*, T2.*, T3.*"
      ::
      :-  %results
          :~  [%action 'SELECT']
              :-  %result-set
                  :~  :-  %vector
                          :~  [%pk1 [~.ud 1]]
                              [%pk3 [~.ud 100]]
                              [%label-a [~.t 'a1']]
                              [%pk1 [~.ud 1]]
                              [%pk3 [~.ud 100]]
                              [%label-b [~.t 'b1']]
                              [%pk1 [~.ud 1]]
                              [%pk2c [~.ud 10]]
                              [%pk3 [~.ud 100]]
                              [%label-c [~.t 'c1']]
                              ==
                      :-  %vector
                          :~  [%pk1 [~.ud 1]]
                              [%pk3 [~.ud 200]]
                              [%label-a [~.t 'a2']]
                              [%pk1 [~.ud 1]]
                              [%pk3 [~.ud 200]]
                              [%label-b [~.t 'b2']]
                              [%pk1 [~.ud 1]]
                              [%pk2c [~.ud 20]]
                              [%pk3 [~.ud 200]]
                              [%label-c [~.t 'c2']]
                              ==
                      :-  %vector
                          :~  [%pk1 [~.ud 2]]
                              [%pk3 [~.ud 100]]
                              [%label-a [~.t 'a3']]
                              [%pk1 [~.ud 2]]
                              [%pk3 [~.ud 100]]
                              [%label-b [~.t 'b3']]
                              [%pk1 [~.ud 2]]
                              [%pk2c [~.ud 40]]
                              [%pk3 [~.ud 100]]
                              [%label-c [~.t 'c4']]
                              ==
                      ==
              [%server-time ~2012.5.3]
              [%relation 'db1.dbo.tbl-a']
              [%schema-time ~2012.4.30]
              [%data-time ~2012.4.30]
              [%relation 'db1.dbo.tbl-b']
              [%schema-time ~2012.4.30]
              [%data-time ~2012.4.30]
              [%relation 'db1.dbo.tbl-c']
              [%schema-time ~2012.4.30]
              [%data-time ~2012.4.30]
              [%vector-count 3]
              ==
      ==
::
::  4-table chain, full key match at every step, 3rd join has double-nested joined-rows
::  A JOIN B JOIN C JOIN D, all on id, testing deep joined-row propagation
++  test-join-51
  =|  run=@ud
  %-  exec-0-1
  :*  run
      :+  ~2012.4.30
          %db1
          %-  zing  :~
            "CREATE DATABASE db1;"
            "CREATE TABLE db1..tbl-a "
            "(id @ud, label-a @t) "
            "PRIMARY KEY (id ASC);"
            "CREATE TABLE db1..tbl-b "
            "(id @ud, label-b @t) "
            "PRIMARY KEY (id ASC);"
            "CREATE TABLE db1..tbl-c "
            "(id @ud, label-c @t) "
            "PRIMARY KEY (id ASC);"
            "CREATE TABLE db1..tbl-d "
            "(id @ud, label-d @t) "
            "PRIMARY KEY (id ASC);"
            "INSERT INTO tbl-a (id, label-a) VALUES "
            "(1, 'a1') "
            "(2, 'a2') "
            "(3, 'a3') "
            "(5, 'a5');"
            "INSERT INTO tbl-b (id, label-b) VALUES "
            "(1, 'b1') "
            "(2, 'b2') "
            "(3, 'b3') "
            "(6, 'b6');"
            "INSERT INTO tbl-c (id, label-c) VALUES "
            "(1, 'c1') "
            "(2, 'c2') "
            "(3, 'c3') "
            "(7, 'c7');"
            "INSERT INTO tbl-d (id, label-d) VALUES "
            "(1, 'd1') "
            "(2, 'd2') "
            "(8, 'd8');"
            ==
      ::
      :+  ~2012.5.3
          %db1
          "FROM tbl-a T1 ".
          "JOIN tbl-b T2 ".
          "JOIN tbl-c T3 ".
          "JOIN tbl-d T4 ".
          "SELECT T1.*, T2.*, T3.*, T4.*"
      ::
      :-  %results
          :~  [%action 'SELECT']
              :-  %result-set
                  :~  :-  %vector
                          :~  [%id [~.ud 1]]
                              [%label-a [~.t 'a1']]
                              [%id [~.ud 1]]
                              [%label-b [~.t 'b1']]
                              [%id [~.ud 1]]
                              [%label-c [~.t 'c1']]
                              [%id [~.ud 1]]
                              [%label-d [~.t 'd1']]
                              ==
                      :-  %vector
                          :~  [%id [~.ud 2]]
                              [%label-a [~.t 'a2']]
                              [%id [~.ud 2]]
                              [%label-b [~.t 'b2']]
                              [%id [~.ud 2]]
                              [%label-c [~.t 'c2']]
                              [%id [~.ud 2]]
                              [%label-d [~.t 'd2']]
                              ==
                      ==
              [%server-time ~2012.5.3]
              [%relation 'db1.dbo.tbl-a']
              [%schema-time ~2012.4.30]
              [%data-time ~2012.4.30]
              [%relation 'db1.dbo.tbl-b']
              [%schema-time ~2012.4.30]
              [%data-time ~2012.4.30]
              [%relation 'db1.dbo.tbl-c']
              [%schema-time ~2012.4.30]
              [%data-time ~2012.4.30]
              [%relation 'db1.dbo.tbl-d']
              [%schema-time ~2012.4.30]
              [%data-time ~2012.4.30]
              [%vector-count 2]
              ==
      ==
::
::  3-table, 2nd join matches on column from first table (not most recent join table)
::  A has grp+tag, B has grp (A JOIN B on grp), C has tag (AB JOIN C on tag)
::  tag is only in A's data within the joined-row, not in B's columns
::  REQUIRES: accumulated columns across joins (enhancement)
++  test-join-52
  =|  run=@ud
  %-  exec-0-1
  :*  run
      :+  ~2012.4.30
          %db1
          %-  zing  :~
            "CREATE DATABASE db1;"
            "CREATE TABLE db1..tbl-a "
            "(key-a @ud, grp @t, tag @t, label-a @t) "
            "PRIMARY KEY (key-a ASC);"
            "CREATE TABLE db1..tbl-b "
            "(key-b @ud, grp @t, label-b @t) "
            "PRIMARY KEY (key-b ASC);"
            "CREATE TABLE db1..tbl-c "
            "(key-c @ud, tag @t, label-c @t) "
            "PRIMARY KEY (key-c ASC);"
            "INSERT INTO tbl-a (key-a, grp, tag, label-a) VALUES "
            "(1, 'x', 'p', 'a1') "
            "(2, 'y', 'q', 'a2') "
            "(3, 'x', 'r', 'a3') "
            "(4, 'z', 'p', 'a4');"
            "INSERT INTO tbl-b (key-b, grp, label-b) VALUES "
            "(10, 'x', 'b1') "
            "(20, 'y', 'b2') "
            "(30, 'w', 'b3');"
            "INSERT INTO tbl-c (key-c, tag, label-c) VALUES "
            "(100, 'p', 'c1') "
            "(200, 'q', 'c2') "
            "(300, 's', 'c3');"
            ==
      ::
      :+  ~2012.5.3
          %db1
          "FROM tbl-a T1 ".
          "JOIN tbl-b T2 ".
          "JOIN tbl-c T3 ".
          "SELECT T1.*, T2.*, T3.*"
      ::
      :-  %results
          :~  [%action 'SELECT']
              :-  %result-set
                  :~  :-  %vector
                          :~  [%key-a [~.ud 1]]
                              [%grp [~.t 'x']]
                              [%tag [~.t 'p']]
                              [%label-a [~.t 'a1']]
                              [%key-b [~.ud 10]]
                              [%grp [~.t 'x']]
                              [%label-b [~.t 'b1']]
                              [%key-c [~.ud 100]]
                              [%tag [~.t 'p']]
                              [%label-c [~.t 'c1']]
                              ==
                      :-  %vector
                          :~  [%key-a [~.ud 2]]
                              [%grp [~.t 'y']]
                              [%tag [~.t 'q']]
                              [%label-a [~.t 'a2']]
                              [%key-b [~.ud 20]]
                              [%grp [~.t 'y']]
                              [%label-b [~.t 'b2']]
                              [%key-c [~.ud 200]]
                              [%tag [~.t 'q']]
                              [%label-c [~.t 'c2']]
                              ==
                      ==
              [%server-time ~2012.5.3]
              [%relation 'db1.dbo.tbl-a']
              [%schema-time ~2012.4.30]
              [%data-time ~2012.4.30]
              [%relation 'db1.dbo.tbl-b']
              [%schema-time ~2012.4.30]
              [%data-time ~2012.4.30]
              [%relation 'db1.dbo.tbl-c']
              [%schema-time ~2012.4.30]
              [%data-time ~2012.4.30]
              [%vector-count 2]
              ==
      ==
::
::  3-table, 2nd join matches on columns split across prior tables A and B
::  A has tag (not in B), B has cat (not in A), C has both tag+cat
::  A JOIN B on grp, then AB JOIN C on tag (from A) + cat (from B)
::  REQUIRES: accumulated columns across joins (enhancement)
++  test-join-53
  =|  run=@ud
  %-  exec-0-1
  :*  run
      :+  ~2012.4.30
          %db1
          %-  zing  :~
            "CREATE DATABASE db1;"
            "CREATE TABLE db1..tbl-a "
            "(key-a @ud, grp @t, tag @t, label-a @t) "
            "PRIMARY KEY (key-a ASC);"
            "CREATE TABLE db1..tbl-b "
            "(key-b @ud, grp @t, cat @t, label-b @t) "
            "PRIMARY KEY (key-b ASC);"
            "CREATE TABLE db1..tbl-c "
            "(key-c @ud, tag @t, cat @t, label-c @t) "
            "PRIMARY KEY (key-c ASC);"
            "INSERT INTO tbl-a (key-a, grp, tag, label-a) VALUES "
            "(1, 'x', 'p', 'a1') "
            "(2, 'y', 'q', 'a2') "
            "(3, 'x', 'r', 'a3') "
            "(4, 'z', 'p', 'a4');"
            "INSERT INTO tbl-b (key-b, grp, cat, label-b) VALUES "
            "(10, 'x', 'm', 'b1') "
            "(20, 'y', 'n', 'b2') "
            "(30, 'w', 'm', 'b3');"
            "INSERT INTO tbl-c (key-c, tag, cat, label-c) VALUES "
            "(100, 'p', 'm', 'c1') "
            "(200, 'q', 'n', 'c2') "
            "(300, 'r', 'm', 'c3') "
            "(400, 'p', 'n', 'c4') "
            "(500, 's', 's', 'c5');"
            ==
      ::
      :+  ~2012.5.3
          %db1
          "FROM tbl-a T1 ".
          "JOIN tbl-b T2 ".
          "JOIN tbl-c T3 ".
          "SELECT T1.*, T2.*, T3.*"
      ::
      :-  %results
          :~  [%action 'SELECT']
              :-  %result-set
                  :~  :-  %vector
                          :~  [%key-a [~.ud 1]]
                              [%grp [~.t 'x']]
                              [%tag [~.t 'p']]
                              [%label-a [~.t 'a1']]
                              [%key-b [~.ud 10]]
                              [%grp [~.t 'x']]
                              [%cat [~.t 'm']]
                              [%label-b [~.t 'b1']]
                              [%key-c [~.ud 100]]
                              [%tag [~.t 'p']]
                              [%cat [~.t 'm']]
                              [%label-c [~.t 'c1']]
                              ==
                      :-  %vector
                          :~  [%key-a [~.ud 2]]
                              [%grp [~.t 'y']]
                              [%tag [~.t 'q']]
                              [%label-a [~.t 'a2']]
                              [%key-b [~.ud 20]]
                              [%grp [~.t 'y']]
                              [%cat [~.t 'n']]
                              [%label-b [~.t 'b2']]
                              [%key-c [~.ud 200]]
                              [%tag [~.t 'q']]
                              [%cat [~.t 'n']]
                              [%label-c [~.t 'c2']]
                              ==
                      :-  %vector
                          :~  [%key-a [~.ud 3]]
                              [%grp [~.t 'x']]
                              [%tag [~.t 'r']]
                              [%label-a [~.t 'a3']]
                              [%key-b [~.ud 10]]
                              [%grp [~.t 'x']]
                              [%cat [~.t 'm']]
                              [%label-b [~.t 'b1']]
                              [%key-c [~.ud 300]]
                              [%tag [~.t 'r']]
                              [%cat [~.t 'm']]
                              [%label-c [~.t 'c3']]
                              ==
                      ==
              [%server-time ~2012.5.3]
              [%relation 'db1.dbo.tbl-a']
              [%schema-time ~2012.4.30]
              [%data-time ~2012.4.30]
              [%relation 'db1.dbo.tbl-b']
              [%schema-time ~2012.4.30]
              [%data-time ~2012.4.30]
              [%relation 'db1.dbo.tbl-c']
              [%schema-time ~2012.4.30]
              [%data-time ~2012.4.30]
              [%vector-count 3]
              ==
      ==
::
::  same object 2X with unqualified column
++  test-fail-join-00
  =|  run=@ud
  %-  failon-1
  :*  run
      :+  ~2012.4.30
          %db1
          %-  zing  :~  "CREATE DATABASE db1;"
                        create-tbl1
                        ==
      ::
      :+  ~2012.5.5
          %db1
          "FROM db1..tbl1 ".
          "JOIN db1..tbl1 ".
          "SELECT year"
      ::
      'SELECT: column %year must be qualified'
      ==
::
::  same object 2X with unknown column
++  test-fail-join-01
  =|  run=@ud
  %-  failon-1
  :*  run
      :+  ~2012.4.30
          %db1
          %-  zing  :~  "CREATE DATABASE db1;"
                        create-tbl1
                        ==
      ::
      :+  ~2012.5.5
          %db1
          "FROM db1..tbl1 ".
          "JOIN db1..tbl1 ".
          "SELECT year-month"
      ::
      'SELECT: column %year-month not found'
      ==
::
::  fail on ambiguous non-key column in multi-table natural join
++  test-fail-join-02
  =|  run=@ud
  %-  failon-1
  :*  run
      :+  ~2012.4.30
          %db1
          %-  zing  :~
            "CREATE DATABASE db1;"
            "CREATE TABLE db1..tbl-a "
            "(pk1 @ud, pk2 @ud, val @ud, label-a @t) "
            "PRIMARY KEY (pk1 ASC, pk2 ASC);"
            "CREATE TABLE db1..tbl-b "
            "(pk1 @ud, val @ud, label-b @t) "
            "PRIMARY KEY (pk1 ASC);"
            "CREATE TABLE db1..tbl-c "
            "(pk1 @ud, pk3 @ud, val @ud, label-c @t) "
            "PRIMARY KEY (pk1 ASC, pk3 ASC);"
            "INSERT INTO tbl-a (pk1, pk2, val, label-a) VALUES "
            "(1, 10, 100, 'a1');"
            "INSERT INTO tbl-b (pk1, val, label-b) VALUES "
            "(1, 100, 'b1');"
            "INSERT INTO tbl-c (pk1, pk3, val, label-c) VALUES "
            "(1, 200, 100, 'c1');"
            ==
      ::
      :+  ~2012.5.3
          %db1
          "FROM tbl-a T1 ".
          "JOIN tbl-b T2 ".
          "JOIN tbl-c T3 ".
          "SELECT T1.*, T2.*, T3.*"
      ::
      'natural join: column %val occurs in multiple tables'
      ==
::
::  bugs
::
::  bug selecting calendar because of screw-up in views schema API
++  test-bugz-01
  =|  run=@ud
  %-  exec-1-1
  :*  run
      [~2024.8.22..15.31.16 %sys "CREATE DATABASE animal-shelter"]
      ::
      :+  ~2024.8.22..15.31.46
          %animal-shelter
          "CREATE NAMESPACE reference; ".
          "CREATE TABLE reference.calendar ".
          "( date        @da, ".
          "  year        @ud, ".
          "  month       @ud, ".
          "  month-name  @t, ".
          "  day         @ud, ".
          "  day-name    @t, ".
          "  day-of-year @ud, ".
          "  weekday     @ud, ".
          "  year-week   @ud ) ".
          "  PRIMARY KEY (date); ".
          "INSERT INTO reference.calendar ".
          "(date, year, month, month-name, day, day-name, day-of-year, ".
                                                   "weekday, year-week) ".
          "VALUES ".
          "  (~1990.1.1, 1990, 1, 'January', 1, 'Monday', 1, 2, 1) ".
          "  (~1990.1.2, 1990, 1, 'January', 2, 'Tuesday', 2, 3, 1) ".
          "  (~1990.1.3, 1990, 1, 'January', 3, 'Wednesday', 3, 4, 1) ".
          "  (~1990.1.4, 1990, 1, 'January', 4, 'Thursday', 4, 5, 1);"
      ::
      :+  ~2024.8.22..16.11.26
          %animal-shelter
          "FROM reference.calendar SELECT *"
      ::
      :-  %results
          :~  [%action 'SELECT']
              :-  %result-set
                  :~  :-  %vector
                         :~  [%date [~.da ~1990.1.2]]
                             [%year [~.ud 1.990]]
                             [%month [~.ud 1]]
                             [%month-name [~.t 'January']]
                             [%day [~.ud 2]]
                             [%day-name [~.t 'Tuesday']]
                             [%day-of-year [~.ud 2]]
                             [%weekday [~.ud 3]]
                             [%year-week [~.ud 1]]
                             ==
                      :-  %vector
                         :~  [%date [~.da ~1990.1.3]]
                             [%year [~.ud 1.990]]
                             [%month [~.ud 1]]
                             [%month-name [~.t 'January']]
                             [%day [~.ud 3]]
                             [%day-name [~.t 'Wednesday']]
                             [%day-of-year [~.ud 3]]
                             [%weekday [~.ud 4]]
                             [%year-week [~.ud 1]]
                             ==
                      :-  %vector
                          :~  [%date [~.da ~1990.1.1]]
                              [%year [~.ud 1.990]]
                              [%month [~.ud 1]]
                              [%month-name [~.t 'January']]
                              [%day [~.ud 1]]
                              [%day-name [~.t 'Monday']]
                              [%day-of-year [~.ud 1]]
                              [%weekday [~.ud 2]]
                              [%year-week [~.ud 1]]
                              ==
                     :-  %vector
                         :~  [%date [~.da ~1990.1.4]]
                             [%year [~.ud 1.990]]
                             [%month [~.ud 1]]
                             [%month-name [~.t 'January']]
                             [%day [~.ud 4]]
                             [%day-name [~.t 'Thursday']]
                             [%day-of-year [~.ud 4]]
                             [%weekday [~.ud 5]]
                             [%year-week [~.ud 1]]
                             ==
                      ==
              [%server-time ~2024.8.22..16.11.26]
              [%relation 'animal-shelter.reference.calendar']
              [%schema-time ~2024.8.22..15.31.46]
              [%data-time ~2024.8.22..15.31.46]
              [%vector-count 4]
              ==
      ==
::
:: SELECT error messages
::
::  fail on prior to table existence
++  test-fail-select-01
  =|  run=@ud
  %-  failon-3
  :*  run
      [~2012.4.30 %sys "CREATE DATABASE db1"]
      ::
      :+  ~2012.5.1
          %db1
          "CREATE TABLE db1..my-table ".
          "(col1 @t, col2 @da, col3 @t, col4 @t) ".
          "PRIMARY KEY (col1) ".
          "AS OF ~2012.5.3"
      ::
      :+  ~2012.5.2
          %db1
          "INSERT INTO my-table AS OF ~2012.5.4".
          " VALUES".
          " ('Abby', ~1999.2.19, 'tricolor', 'row1')".
          " ('Ace', ~2005.12.19, 'ticolor', 'row2')".
          " ('Angel', ~2001.9.19, 'tuxedo', 'row3')"
      ::
      :+  ~2012.5.2
          %db1
          "FROM my-table SELECT ".
          "my-table.col4,my-table.col3,my-table.col2,my-table.col1"
      ::
      'table %db1.%dbo.%my-table does not exist at schema time ~2012.4.30'
      ==
::
::  fail on bad column name
++  test-fail-select-02
  =|  run=@ud
  %-  failon-3
  :*  run
      [~2012.4.30 %sys "CREATE DATABASE db1"]
      ::
      :+  ~2012.5.1
          %db1
          "CREATE TABLE db1..my-table ".
          "(col1 @t, col2 @da, col3 @t, col4 @t) ".
          "PRIMARY KEY (col1) ".
          "AS OF ~2012.5.3"
      ::
      :+  ~2012.5.4
          %db1
          "INSERT INTO my-table AS OF ~2012.5.5".
          " VALUES".
          " ('Abby', ~1999.2.19, 'tricolor', 'row1')".
          " ('Ace', ~2005.12.19, 'ticolor', 'row2')".
          " ('Angel', ~2001.9.19, 'tuxedo', 'row3')"
      ::
      :+  ~2012.5.6
          %db1
          "FROM my-table SELECT col4, foo"
      ::
      'SELECT: column %foo not found'
      ==
::
:: unresolved alias select all object
++  test-fail-select-03
  =|  run=@ud
  %+  expect-fail-message
        'cannot resolve 13.140'
  |.  %+  ~(on-poke agent (bowl [run ~2012.5.5]))
          %obelisk-action
          !>  :+  %test
                  %db1
                  "FROM animal-shelter.reference.calendar T1 ".
                  "JOIN reference.calendar-us-fed-holiday calendar ".
                  "WHERE T1.date BETWEEN ~2025.1.1 AND ~2025.12.31 ".
                  "SELECT T1.date, day-name, us-federal-holiday, T3.*;"
::
::  fail on as-of ~d4 (schema-time < ~d4 ago)
++  test-fail-time-query-01
  =|  run=@ud
  %-  failon-3
  :*  run
      [~2012.4.30 %sys "CREATE DATABASE db1"]
      ::
      :+  ~2012.5.2
          %db1
          "CREATE TABLE db1..my-table ".
          "(col1 @t, col2 @da, col3 @t, col4 @t) ".
          "PRIMARY KEY (col1)"
      ::
      :+  ~2012.5.3
          %db1
          "INSERT INTO my-table".
          " VALUES".
          " ('Abby', ~1999.2.19, 'tricolor', 'row1')".
          " ('Ace', ~2005.12.19, 'ticolor', 'row2')".
          " ('Angel', ~2001.9.19, 'tuxedo', 'row3')"
      ::
      :+  ~2012.5.5
          %db1
          "FROM my-table AS OF ~d4 T1 ".
          "SELECT *, col2,col4, my-table.*, col1 as C1"
      ::
      'SELECT: table %db1.%dbo.%my-table does not exist at schema time ~2012.4.30'
      ==
::
::  fail on bad column name in WHERE bad column = literal
++  test-fail-select-04
  =|  run=@ud
  %-  failon-1
  :*  run
      :+  ~2012.4.30
          %db1
          %-  zing  :~  "CREATE DATABASE db1;"
                        "CREATE TABLE db1..my-table "
                        "(col1 @t, col2 @da, col3 @t, col4 @t) "
                        "PRIMARY KEY (col1);"
                        ==
      ::
      :+  ~2012.5.3
          %db1
          "FROM my-table WHERE bad-col = 'row1' SELECT col1"
      ::
      'column %bad-col does not exist'
      ==
::
::  fail on bad column name in WHERE literal = bad column
++  test-fail-select-05
  =|  run=@ud
  %-  failon-1
  :*  run
      :+  ~2012.4.30
          %db1
          %-  zing  :~  "CREATE DATABASE db1;"
                        "CREATE TABLE db1..my-table "
                        "(col1 @t, col2 @da, col3 @t, col4 @t) "
                        "PRIMARY KEY (col1);"
                        ==
      ::
      :+  ~2012.5.3
          %db1
          "FROM my-table WHERE 'row1' = bad-col SELECT col1"
      ::
      'column %bad-col does not exist'
      ==
::
::  fail on bad column name in WHERE bad column = good column
++  test-fail-select-06
  =|  run=@ud
  %-  failon-1
  :*  run
      :+  ~2012.4.30
          %db1
          %-  zing  :~  "CREATE DATABASE db1;"
                        "CREATE TABLE db1..my-table "
                        "(col1 @t, col2 @da, col3 @t, col4 @t) "
                        "PRIMARY KEY (col1);"
                        ==
      ::
      :+  ~2012.5.3
          %db1
          "FROM my-table WHERE bad-col = col1 SELECT col1"
      ::
      'column %bad-col does not exist'
      ==
::
::  fail on bad column name in WHERE good column = bad column
++  test-fail-select-07
  =|  run=@ud
  %-  failon-1
  :*  run
      :+  ~2012.4.30
          %db1
          %-  zing  :~  "CREATE DATABASE db1;"
                        "CREATE TABLE db1..my-table "
                        "(col1 @t, col2 @da, col3 @t, col4 @t) "
                        "PRIMARY KEY (col1);"
                        ==
      ::
      :+  ~2012.5.3
          %db1
          "FROM my-table WHERE col1 = bad-col SELECT col1"
      ::
      'column %bad-col does not exist'
      ==
::
::  fail on bad column name in join WHERE bad column = literal
++  test-fail-join-04
  =|  run=@ud
  %-  failon-1
  :*  run
      :+  ~2012.4.30
          %db1
          %-  zing  :~  "CREATE DATABASE db1;"
                        create-tbl1
                        ==
      ::
      :+  ~2012.5.5
          %db1
          "FROM db1..tbl1 T1 ".
          "JOIN db1..tbl1 T2 ".
          "WHERE bad-col = 'January' ".
          "SELECT T1.year"
      ::
      'column %bad-col does not exist'
      ==
::
::  fail on bad column name in join WHERE literal = bad column
++  test-fail-join-05
  =|  run=@ud
  %-  failon-1
  :*  run
      :+  ~2012.4.30
          %db1
          %-  zing  :~  "CREATE DATABASE db1;"
                        create-tbl1
                        ==
      ::
      :+  ~2012.5.5
          %db1
          "FROM db1..tbl1 T1 ".
          "JOIN db1..tbl1 T2 ".
          "WHERE 'January' = bad-col ".
          "SELECT T1.year"
      ::
      'column %bad-col does not exist'
      ==
::
::  fail on bad column name in join WHERE bad column = good column
++  test-fail-join-06
  =|  run=@ud
  %-  failon-1
  :*  run
      :+  ~2012.4.30
          %db1
          %-  zing  :~  "CREATE DATABASE db1;"
                        create-tbl1
                        ==
      ::
      :+  ~2012.5.5
          %db1
          "FROM db1..tbl1 T1 ".
          "JOIN db1..tbl1 T2 ".
          "WHERE bad-col = T1.month-name ".
          "SELECT T1.year"
      ::
      'column %bad-col does not exist'
      ==
::
::  fail on bad column name in join WHERE good column = bad column
++  test-fail-join-07
  =|  run=@ud
  %-  failon-1
  :*  run
      :+  ~2012.4.30
          %db1
          %-  zing  :~  "CREATE DATABASE db1;"
                        create-tbl1
                        ==
      ::
      :+  ~2012.5.5
          %db1
          "FROM db1..tbl1 T1 ".
          "JOIN db1..tbl1 T2 ".
          "WHERE T1.month-name = bad-col ".
          "SELECT T1.year"
      ::
      'column %bad-col does not exist'
      ==
::
::  predicate joins (JOIN ... ON)
::
::  dept: departments with dept-id PK
++  create-dept
  "CREATE TABLE dept ".
  "(dept-id @ud, dept-name @t) ".
  "PRIMARY KEY (dept-id);"
::  dept-ids 1-5; ids 4,5 have no matching employees
++  insert-dept
  "INSERT INTO dept VALUES ".
  "(1, 'Engineering') ".
  "(2, 'Sales') ".
  "(3, 'Marketing') ".
  "(4, 'Legal') ".
  "(5, 'Finance');"
::  emp: employees with emp-id PK, dept-ref foreign key to dept (different name)
++  create-emp
  "CREATE TABLE emp ".
  "(emp-id @ud, emp-name @t, dept-ref @ud) ".
  "PRIMARY KEY (emp-id);"
::  dept-refs 1,2,3 match dept; dept-ref 99 has no matching dept
++  insert-emp
  "INSERT INTO emp VALUES ".
  "(10, 'Alice', 1) ".
  "(20, 'Bob', 1) ".
  "(30, 'Carol', 2) ".
  "(40, 'Dave', 3) ".
  "(50, 'Eve', 99);"
::  proj: projects with proj-id PK, lead-emp foreign key to emp
++  create-proj
  "CREATE TABLE proj ".
  "(proj-id @ud, proj-name @t, lead-emp @ud) ".
  "PRIMARY KEY (proj-id);"
::  lead-emp 10,30 match emp; lead-emp 777 has no match
++  insert-proj
  "INSERT INTO proj VALUES ".
  "(100, 'Alpha', 10) ".
  "(200, 'Beta', 30) ".
  "(300, 'Gamma', 777);"
::  tiny-a and tiny-b: single-row tables for edge cases
++  create-tiny-a
  "CREATE TABLE tiny-a ".
  "(ta-id @ud, ta-val @t) ".
  "PRIMARY KEY (ta-id);"
++  insert-tiny-a
  "INSERT INTO tiny-a VALUES (1, 'only-a');"
++  create-tiny-b
  "CREATE TABLE tiny-b ".
  "(tb-id @ud, tb-val @t) ".
  "PRIMARY KEY (tb-id);"
++  insert-tiny-b
  "INSERT INTO tiny-b VALUES (1, 'only-b');"
::
::  emp2: employees with compound PK (dept-ref, emp-id) for multi-column tests
++  create-emp2
  "CREATE TABLE emp2 ".
  "(dept-ref @ud, emp-id @ud, emp-name @t) ".
  "PRIMARY KEY (dept-ref, emp-id);"
++  insert-emp2
  "INSERT INTO emp2 VALUES ".
  "(1, 10, 'Alice') ".
  "(1, 20, 'Bob') ".
  "(2, 30, 'Carol') ".
  "(3, 40, 'Dave') ".
  "(99, 50, 'Eve');"
::  dept2: departments with compound PK (region-id, dept-key) for multi-column tests
++  create-dept2
  "CREATE TABLE dept2 ".
  "(region-id @ud, dept-key @ud, dept-label @t) ".
  "PRIMARY KEY (region-id, dept-key);"
++  insert-dept2
  "INSERT INTO dept2 VALUES ".
  "(1, 10, 'Eng-East') ".
  "(1, 20, 'Sales-East') ".
  "(2, 30, 'Mktg-West') ".
  "(3, 40, 'Legal-South') ".
  "(5, 50, 'HR-North');"
::  sys-view predicate-join fixtures
::  date-catalog: ref-date @da joins sys.tables.tmsp @da (different column names)
++  create-date-catalog
  "CREATE TABLE date-catalog ".
  "(dc-id @ud, ref-date @da, dc-note @t) ".
  "PRIMARY KEY (dc-id);"
++  insert-date-catalog
  "INSERT INTO date-catalog VALUES ".
  "(1, ~2012.4.30, 'matches emp table') ".
  "(2, ~2099.1.1, 'no match');"
::  compound-cat: joins sys.tables on tmsp @da AND row-count @ud (both different names)
++  create-compound-cat
  "CREATE TABLE compound-cat ".
  "(cc-id @ud, ref-date @da, row-count-ref @ud, cc-note @t) ".
  "PRIMARY KEY (cc-id);"
++  insert-compound-cat
  "INSERT INTO compound-cat VALUES ".
  "(1, ~2012.4.30, 5, 'emp: 5 rows at init') ".
  "(2, ~2012.4.30, 999, 'wrong count no match');"
::  ns-date-cat: ns-date @da joins sys.namespaces.tmsp @da (different column names)
++  create-ns-date-cat
  "CREATE TABLE ns-date-cat ".
  "(ndc-id @ud, ns-date @da, ndc-note @t) ".
  "PRIMARY KEY (ndc-id);"
++  insert-ns-date-cat
  "INSERT INTO ns-date-cat VALUES ".
  "(1, ~2012.4.30, 'matches dbo namespace') ".
  "(2, ~2099.1.1, 'no match');"
::  ship-cat: ship-ref @p joins sys.sys.databases.data-ship @p (different column names)
++  create-ship-cat
  "CREATE TABLE ship-cat ".
  "(sc-id @ud, ship-ref @p, sc-note @t) ".
  "PRIMARY KEY (sc-id);"
++  insert-ship-cat
  "INSERT INTO ship-cat VALUES ".
  "(1, ~zod, 'local ship') ".
  "(2, ~nec, 'foreign ship no match');"
::  date-ref-tbl: ref-date @da joins sys.tables.tmsp; owner-id @ud joins emp.emp-id
++  create-date-ref-tbl
  "CREATE TABLE date-ref-tbl ".
  "(drt-id @ud, ref-date @da, owner-id @ud, drt-note @t) ".
  "PRIMARY KEY (drt-id);"
++  insert-date-ref-tbl
  "INSERT INTO date-ref-tbl VALUES ".
  "(1, ~2012.4.30, 10, 'alice emp table') ".
  "(2, ~2099.1.1, 99, 'future no match');"
::  mini-tbl: 2-column table for sys.columns compound join test
++  create-mini-tbl
  "CREATE TABLE mini-tbl ".
  "(mk-id @ud, mk-tag @t) ".
  "PRIMARY KEY (mk-id);"
::
::  test-predicate-join-00
::  single equality ON, same-named key columns match (equivalent to natural join)
::  verifies basic predicate join works; non-matching rows filtered on both sides
++  test-predicate-join-00
  =|  run=@ud
  %-  exec-0-1
  :*  run
      :+  ~2012.4.30
          %db1
          %-  zing  :~  "CREATE DATABASE db1;"
                        create-dept
                        insert-dept
                        create-emp
                        insert-emp
                        ==
      ::
      :+  ~2012.5.3
          %db1
          "FROM emp T1 ".
          "JOIN dept T2 ON T1.dept-ref = T2.dept-id ".
          "SELECT T1.emp-name, T1.dept-ref, T2.dept-name"
      ::
      :-  %results
          :~  [%action 'SELECT']
              :-  %result-set
                  :~  :-  %vector
                          :~  [%emp-name [~.t 'Alice']]
                              [%dept-ref [~.ud 1]]
                              [%dept-name [~.t 'Engineering']]
                              ==
                      :-  %vector
                          :~  [%emp-name [~.t 'Bob']]
                              [%dept-ref [~.ud 1]]
                              [%dept-name [~.t 'Engineering']]
                              ==
                      :-  %vector
                          :~  [%emp-name [~.t 'Carol']]
                              [%dept-ref [~.ud 2]]
                              [%dept-name [~.t 'Sales']]
                              ==
                      :-  %vector
                          :~  [%emp-name [~.t 'Dave']]
                              [%dept-ref [~.ud 3]]
                              [%dept-name [~.t 'Marketing']]
                              ==
                      ==
              [%server-time ~2012.5.3]
              [%relation 'db1.dbo.dept']
              [%schema-time ~2012.4.30]
              [%data-time ~2012.4.30]
              [%relation 'db1.dbo.emp']
              [%schema-time ~2012.4.30]
              [%data-time ~2012.4.30]
              [%vector-count 4]
              ==
      ==
::
::  test-predicate-join-01
::  single equality ON, one-to-many: multiple emps in same dept
::  dept-id=1 has two employees (Alice, Bob); non-matching rows on both sides
++  test-predicate-join-01
  =|  run=@ud
  %-  exec-0-1
  :*  run
      :+  ~2012.4.30
          %db1
          %-  zing  :~  "CREATE DATABASE db1;"
                        create-dept
                        insert-dept
                        create-emp
                        insert-emp
                        ==
      ::
      :+  ~2012.5.3
          %db1
          "FROM dept T1 ".
          "JOIN emp T2 ON T1.dept-id = T2.dept-ref ".
          "SELECT T1.dept-name, T2.emp-name"
      ::
      :-  %results
          :~  [%action 'SELECT']
              :-  %result-set
                  :~  :-  %vector
                          :~  [%dept-name [~.t 'Engineering']]
                              [%emp-name [~.t 'Alice']]
                              ==
                      :-  %vector
                          :~  [%dept-name [~.t 'Engineering']]
                              [%emp-name [~.t 'Bob']]
                              ==
                      :-  %vector
                          :~  [%dept-name [~.t 'Sales']]
                              [%emp-name [~.t 'Carol']]
                              ==
                      :-  %vector
                          :~  [%dept-name [~.t 'Marketing']]
                              [%emp-name [~.t 'Dave']]
                              ==
                      ==
              [%server-time ~2012.5.3]
              [%relation 'db1.dbo.dept']
              [%schema-time ~2012.4.30]
              [%data-time ~2012.4.30]
              [%relation 'db1.dbo.emp']
              [%schema-time ~2012.4.30]
              [%data-time ~2012.4.30]
              [%vector-count 4]
              ==
      ==
::
::  test-predicate-join-02
::  single equality ON, no matches: join on impossible value
::  all dept rows and all emp rows are non-matching
++  test-predicate-join-02
  =|  run=@ud
  %-  exec-0-1
  :*  run
      :+  ~2012.4.30
          %db1
          %-  zing  :~  "CREATE DATABASE db1;"
                        create-tiny-a
                        insert-tiny-a
                        create-tiny-b
                        "INSERT INTO tiny-b VALUES (2, 'no-match');"
                        ==
      ::
      :+  ~2012.5.3
          %db1
          "FROM tiny-a T1 ".
          "JOIN tiny-b T2 ON T1.ta-id = T2.tb-id ".
          "SELECT T1.ta-val, T2.tb-val"
      ::
      :-  %results
          :~  [%action 'SELECT']
              [%result-set ~]
              [%server-time ~2012.5.3]
              [%relation 'db1.dbo.tiny-a']
              [%schema-time ~2012.4.30]
              [%data-time ~2012.4.30]
              [%relation 'db1.dbo.tiny-b']
              [%schema-time ~2012.4.30]
              [%data-time ~2012.4.30]
              [%vector-count 0]
              ==
      ==
::
::  test-predicate-join-03
::  single equality ON, all rows match on both sides
::  both tables single row with matching key; no non-matching rows
::  (we still verify the mechanism works with full match)
++  test-predicate-join-03
  =|  run=@ud
  %-  exec-0-1
  :*  run
      :+  ~2012.4.30
          %db1
          %-  zing  :~  "CREATE DATABASE db1;"
                        create-tiny-a
                        insert-tiny-a
                        create-tiny-b
                        insert-tiny-b
                        ==
      ::
      :+  ~2012.5.3
          %db1
          "FROM tiny-a T1 ".
          "JOIN tiny-b T2 ON T1.ta-id = T2.tb-id ".
          "SELECT T1.ta-val, T2.tb-val"
      ::
      :-  %results
          :~  [%action 'SELECT']
              :-  %result-set
                  :~  :-  %vector
                          :~  [%ta-val [~.t 'only-a']]
                              [%tb-val [~.t 'only-b']]
                              ==
                      ==
              [%server-time ~2012.5.3]
              [%relation 'db1.dbo.tiny-a']
              [%schema-time ~2012.4.30]
              [%data-time ~2012.4.30]
              [%relation 'db1.dbo.tiny-b']
              [%schema-time ~2012.4.30]
              [%data-time ~2012.4.30]
              [%vector-count 1]
              ==
      ==
::
::  test-predicate-join-04
::  single equality ON non-key columns (join on emp-name = dept-name would be
::  nonsensical, so use same-type non-key columns)
::  dept has dept-name @t, emp has emp-name @t; join on non-key @ud columns
::  uses emp.dept-ref = dept.dept-id which are non-PK from emp's perspective
::  but PK from dept's perspective; rows with dept-ref 99 and dept-id 4,5 unmatched
++  test-predicate-join-04
  =|  run=@ud
  %-  exec-0-1
  :*  run
      :+  ~2012.4.30
          %db1
          %-  zing  :~  "CREATE DATABASE db1;"
                        create-dept
                        insert-dept
                        create-emp
                        insert-emp
                        ==
      ::
      :+  ~2012.5.3
          %db1
          "FROM emp T1 ".
          "JOIN dept T2 ON T1.dept-ref = T2.dept-id ".
          "SELECT T1.emp-id, T1.emp-name, T2.dept-id, T2.dept-name"
      ::
      :-  %results
          :~  [%action 'SELECT']
              :-  %result-set
                  :~  :-  %vector
                          :~  [%emp-id [~.ud 10]]
                              [%emp-name [~.t 'Alice']]
                              [%dept-id [~.ud 1]]
                              [%dept-name [~.t 'Engineering']]
                              ==
                      :-  %vector
                          :~  [%emp-id [~.ud 20]]
                              [%emp-name [~.t 'Bob']]
                              [%dept-id [~.ud 1]]
                              [%dept-name [~.t 'Engineering']]
                              ==
                      :-  %vector
                          :~  [%emp-id [~.ud 30]]
                              [%emp-name [~.t 'Carol']]
                              [%dept-id [~.ud 2]]
                              [%dept-name [~.t 'Sales']]
                              ==
                      :-  %vector
                          :~  [%emp-id [~.ud 40]]
                              [%emp-name [~.t 'Dave']]
                              [%dept-id [~.ud 3]]
                              [%dept-name [~.t 'Marketing']]
                              ==
                      ==
              [%server-time ~2012.5.3]
              [%relation 'db1.dbo.dept']
              [%schema-time ~2012.4.30]
              [%data-time ~2012.4.30]
              [%relation 'db1.dbo.emp']
              [%schema-time ~2012.4.30]
              [%data-time ~2012.4.30]
              [%vector-count 4]
              ==
      ==
::
::  test-predicate-join-05
::  multi-column equality ON: two AND-ed equality conditions
::  joins emp2(dept-ref, emp-id) with dept2(region-id, dept-key) on both columns
::  non-matching rows: emp2 (99,50) and dept2 (5,50) have no counterpart
++  test-predicate-join-05
  =|  run=@ud
  %-  exec-0-1
  :*  run
      :+  ~2012.4.30
          %db1
          %-  zing  :~  "CREATE DATABASE db1;"
                        create-emp2
                        insert-emp2
                        create-dept2
                        insert-dept2
                        ==
      ::
      :+  ~2012.5.3
          %db1
          "FROM emp2 T1 ".
          "JOIN dept2 T2 ".
          "ON T1.dept-ref = T2.region-id AND T1.emp-id = T2.dept-key ".
          "SELECT T1.emp-name, T2.dept-label"
      ::
      :-  %results
          :~  [%action 'SELECT']
              :-  %result-set
                  :~  :-  %vector
                          :~  [%emp-name [~.t 'Alice']]
                              [%dept-label [~.t 'Eng-East']]
                              ==
                      :-  %vector
                          :~  [%emp-name [~.t 'Bob']]
                              [%dept-label [~.t 'Sales-East']]
                              ==
                      :-  %vector
                          :~  [%emp-name [~.t 'Carol']]
                              [%dept-label [~.t 'Mktg-West']]
                              ==
                      :-  %vector
                          :~  [%emp-name [~.t 'Dave']]
                              [%dept-label [~.t 'Legal-South']]
                              ==
                      ==
              [%server-time ~2012.5.3]
              [%relation 'db1.dbo.dept2']
              [%schema-time ~2012.4.30]
              [%data-time ~2012.4.30]
              [%relation 'db1.dbo.emp2']
              [%schema-time ~2012.4.30]
              [%data-time ~2012.4.30]
              [%vector-count 4]
              ==
      ==
::
::  test-predicate-join-06
::  different column names: ON T1.dept-ref = T2.dept-id
::  (key differentiator from natural join which requires same column names)
::  Eve(dept-ref=99) unmatched on left; Legal(4), Finance(5) unmatched on right
++  test-predicate-join-06
  =|  run=@ud
  %-  exec-0-1
  :*  run
      :+  ~2012.4.30
          %db1
          %-  zing  :~  "CREATE DATABASE db1;"
                        create-dept
                        insert-dept
                        create-emp
                        insert-emp
                        ==
      ::
      :+  ~2012.5.3
          %db1
          "FROM emp T1 ".
          "JOIN dept T2 ON T1.dept-ref = T2.dept-id ".
          "SELECT T1.*, T2.*"
      ::
      :-  %results
          :~  [%action 'SELECT']
              :-  %result-set
                  :~  :-  %vector
                          :~  [%emp-id [~.ud 10]]
                              [%emp-name [~.t 'Alice']]
                              [%dept-ref [~.ud 1]]
                              [%dept-id [~.ud 1]]
                              [%dept-name [~.t 'Engineering']]
                              ==
                      :-  %vector
                          :~  [%emp-id [~.ud 20]]
                              [%emp-name [~.t 'Bob']]
                              [%dept-ref [~.ud 1]]
                              [%dept-id [~.ud 1]]
                              [%dept-name [~.t 'Engineering']]
                              ==
                      :-  %vector
                          :~  [%emp-id [~.ud 30]]
                              [%emp-name [~.t 'Carol']]
                              [%dept-ref [~.ud 2]]
                              [%dept-id [~.ud 2]]
                              [%dept-name [~.t 'Sales']]
                              ==
                      :-  %vector
                          :~  [%emp-id [~.ud 40]]
                              [%emp-name [~.t 'Dave']]
                              [%dept-ref [~.ud 3]]
                              [%dept-id [~.ud 3]]
                              [%dept-name [~.t 'Marketing']]
                              ==
                      ==
              [%server-time ~2012.5.3]
              [%relation 'db1.dbo.dept']
              [%schema-time ~2012.4.30]
              [%data-time ~2012.4.30]
              [%relation 'db1.dbo.emp']
              [%schema-time ~2012.4.30]
              [%data-time ~2012.4.30]
              [%vector-count 4]
              ==
      ==
::
::  test-predicate-join-07
::  different column names, multi-column ON
::  joins emp2(dept-ref, emp-id) with dept2(region-id, dept-key)
::  both column pairs have different names; non-matching on both sides
++  test-predicate-join-07
  =|  run=@ud
  %-  exec-0-1
  :*  run
      :+  ~2012.4.30
          %db1
          %-  zing  :~  "CREATE DATABASE db1;"
                        create-emp2
                        insert-emp2
                        create-dept2
                        insert-dept2
                        ==
      ::
      :+  ~2012.5.3
          %db1
          "FROM emp2 T1 ".
          "JOIN dept2 T2 ".
          "ON T1.dept-ref = T2.region-id AND T1.emp-id = T2.dept-key ".
          "SELECT T1.*, T2.*"
      ::
      :-  %results
          :~  [%action 'SELECT']
              :-  %result-set
                  :~  :-  %vector
                          :~  [%dept-ref [~.ud 1]]
                              [%emp-id [~.ud 10]]
                              [%emp-name [~.t 'Alice']]
                              [%region-id [~.ud 1]]
                              [%dept-key [~.ud 10]]
                              [%dept-label [~.t 'Eng-East']]
                              ==
                      :-  %vector
                          :~  [%dept-ref [~.ud 1]]
                              [%emp-id [~.ud 20]]
                              [%emp-name [~.t 'Bob']]
                              [%region-id [~.ud 1]]
                              [%dept-key [~.ud 20]]
                              [%dept-label [~.t 'Sales-East']]
                              ==
                      :-  %vector
                          :~  [%dept-ref [~.ud 2]]
                              [%emp-id [~.ud 30]]
                              [%emp-name [~.t 'Carol']]
                              [%region-id [~.ud 2]]
                              [%dept-key [~.ud 30]]
                              [%dept-label [~.t 'Mktg-West']]
                              ==
                      :-  %vector
                          :~  [%dept-ref [~.ud 3]]
                              [%emp-id [~.ud 40]]
                              [%emp-name [~.t 'Dave']]
                              [%region-id [~.ud 3]]
                              [%dept-key [~.ud 40]]
                              [%dept-label [~.t 'Legal-South']]
                              ==
                      ==
              [%server-time ~2012.5.3]
              [%relation 'db1.dbo.dept2']
              [%schema-time ~2012.4.30]
              [%data-time ~2012.4.30]
              [%relation 'db1.dbo.emp2']
              [%schema-time ~2012.4.30]
              [%data-time ~2012.4.30]
              [%vector-count 4]
              ==
      ==
::
::  test-predicate-join-08
::  both sides have non-matching rows
::  emp has Eve(dept-ref=99) unmatched; dept has Legal(4), Finance(5) unmatched
::  verifies filtering works correctly in both directions
++  test-predicate-join-08
  =|  run=@ud
  %-  exec-0-1
  :*  run
      :+  ~2012.4.30
          %db1
          %-  zing  :~  "CREATE DATABASE db1;"
                        create-dept
                        insert-dept
                        create-emp
                        insert-emp
                        ==
      ::
      :+  ~2012.5.3
          %db1
          "FROM emp T1 ".
          "JOIN dept T2 ON T1.dept-ref = T2.dept-id ".
          "SELECT T1.emp-id, T1.emp-name, T2.dept-id, T2.dept-name"
      ::
      :-  %results
          :~  [%action 'SELECT']
              :-  %result-set
                  :~  :-  %vector
                          :~  [%emp-id [~.ud 10]]
                              [%emp-name [~.t 'Alice']]
                              [%dept-id [~.ud 1]]
                              [%dept-name [~.t 'Engineering']]
                              ==
                      :-  %vector
                          :~  [%emp-id [~.ud 20]]
                              [%emp-name [~.t 'Bob']]
                              [%dept-id [~.ud 1]]
                              [%dept-name [~.t 'Engineering']]
                              ==
                      :-  %vector
                          :~  [%emp-id [~.ud 30]]
                              [%emp-name [~.t 'Carol']]
                              [%dept-id [~.ud 2]]
                              [%dept-name [~.t 'Sales']]
                              ==
                      :-  %vector
                          :~  [%emp-id [~.ud 40]]
                              [%emp-name [~.t 'Dave']]
                              [%dept-id [~.ud 3]]
                              [%dept-name [~.t 'Marketing']]
                              ==
                      ==
              [%server-time ~2012.5.3]
              [%relation 'db1.dbo.dept']
              [%schema-time ~2012.4.30]
              [%data-time ~2012.4.30]
              [%relation 'db1.dbo.emp']
              [%schema-time ~2012.4.30]
              [%data-time ~2012.4.30]
              [%vector-count 4]
              ==
      ==
::
::  test-predicate-join-09
::  left side only has unmatched rows
::  all dept rows match; emp has Eve(dept-ref=99) that doesn't match any dept
++  test-predicate-join-09
  =|  run=@ud
  %-  exec-0-1
  :*  run
      :+  ~2012.4.30
          %db1
          %-  zing  :~  "CREATE DATABASE db1;"
                        "CREATE TABLE dept-small ".
                        "(dept-id @ud, dept-name @t) ".
                        "PRIMARY KEY (dept-id);"
                        "INSERT INTO dept-small VALUES ".
                        "(1, 'Engineering') ".
                        "(2, 'Sales') ".
                        "(3, 'Marketing');"
                        create-emp
                        insert-emp
                        ==
      ::
      :+  ~2012.5.3
          %db1
          "FROM emp T1 ".
          "JOIN dept-small T2 ON T1.dept-ref = T2.dept-id ".
          "SELECT T1.emp-name, T2.dept-name"
      ::
      :-  %results
          :~  [%action 'SELECT']
              :-  %result-set
                  :~  :-  %vector
                          :~  [%emp-name [~.t 'Alice']]
                              [%dept-name [~.t 'Engineering']]
                              ==
                      :-  %vector
                          :~  [%emp-name [~.t 'Bob']]
                              [%dept-name [~.t 'Engineering']]
                              ==
                      :-  %vector
                          :~  [%emp-name [~.t 'Carol']]
                              [%dept-name [~.t 'Sales']]
                              ==
                      :-  %vector
                          :~  [%emp-name [~.t 'Dave']]
                              [%dept-name [~.t 'Marketing']]
                              ==
                      ==
              [%server-time ~2012.5.3]
              [%relation 'db1.dbo.dept-small']
              [%schema-time ~2012.4.30]
              [%data-time ~2012.4.30]
              [%relation 'db1.dbo.emp']
              [%schema-time ~2012.4.30]
              [%data-time ~2012.4.30]
              [%vector-count 4]
              ==
      ==
::
::  test-predicate-join-10
::  right side only has unmatched rows
::  all emp rows match a dept; dept has Legal(4), Finance(5) with no matching emp
++  test-predicate-join-10
  =|  run=@ud
  %-  exec-0-1
  :*  run
      :+  ~2012.4.30
          %db1
          %-  zing  :~  "CREATE DATABASE db1;"
                        create-dept
                        insert-dept
                        "CREATE TABLE emp-small ".
                        "(emp-id @ud, emp-name @t, dept-ref @ud) ".
                        "PRIMARY KEY (emp-id);"
                        "INSERT INTO emp-small VALUES ".
                        "(10, 'Alice', 1) ".
                        "(20, 'Bob', 2) ".
                        "(30, 'Carol', 3);"
                        ==
      ::
      :+  ~2012.5.3
          %db1
          "FROM emp-small T1 ".
          "JOIN dept T2 ON T1.dept-ref = T2.dept-id ".
          "SELECT T1.emp-name, T2.dept-name"
      ::
      :-  %results
          :~  [%action 'SELECT']
              :-  %result-set
                  :~  :-  %vector
                          :~  [%emp-name [~.t 'Alice']]
                              [%dept-name [~.t 'Engineering']]
                              ==
                      :-  %vector
                          :~  [%emp-name [~.t 'Bob']]
                              [%dept-name [~.t 'Sales']]
                              ==
                      :-  %vector
                          :~  [%emp-name [~.t 'Carol']]
                              [%dept-name [~.t 'Marketing']]
                              ==
                      ==
              [%server-time ~2012.5.3]
              [%relation 'db1.dbo.dept']
              [%schema-time ~2012.4.30]
              [%data-time ~2012.4.30]
              [%relation 'db1.dbo.emp-small']
              [%schema-time ~2012.4.30]
              [%data-time ~2012.4.30]
              [%vector-count 3]
              ==
      ==
::
::  test-predicate-join-11
::  inverted FROM/JOIN order: dept first, emp second (vs test-00 emp first)
::  same data, same result set; verifies join direction doesn't affect results
::  non-matching rows: Eve(99) on emp side, Legal(4)/Finance(5) on dept side
++  test-predicate-join-11
  =|  run=@ud
  %-  exec-0-1
  :*  run
      :+  ~2012.4.30
          %db1
          %-  zing  :~  "CREATE DATABASE db1;"
                        create-dept
                        insert-dept
                        create-emp
                        insert-emp
                        ==
      ::
      :+  ~2012.5.3
          %db1
          "FROM dept T1 ".
          "JOIN emp T2 ON T1.dept-id = T2.dept-ref ".
          "SELECT T2.emp-name, T2.dept-ref, T1.dept-name"
      ::
      :-  %results
          :~  [%action 'SELECT']
              :-  %result-set
                  :~  :-  %vector
                          :~  [%emp-name [~.t 'Alice']]
                              [%dept-ref [~.ud 1]]
                              [%dept-name [~.t 'Engineering']]
                              ==
                      :-  %vector
                          :~  [%emp-name [~.t 'Bob']]
                              [%dept-ref [~.ud 1]]
                              [%dept-name [~.t 'Engineering']]
                              ==
                      :-  %vector
                          :~  [%emp-name [~.t 'Carol']]
                              [%dept-ref [~.ud 2]]
                              [%dept-name [~.t 'Sales']]
                              ==
                      :-  %vector
                          :~  [%emp-name [~.t 'Dave']]
                              [%dept-ref [~.ud 3]]
                              [%dept-name [~.t 'Marketing']]
                              ==
                      ==
              [%server-time ~2012.5.3]
              [%relation 'db1.dbo.dept']
              [%schema-time ~2012.4.30]
              [%data-time ~2012.4.30]
              [%relation 'db1.dbo.emp']
              [%schema-time ~2012.4.30]
              [%data-time ~2012.4.30]
              [%vector-count 4]
              ==
      ==
::
::  test-predicate-join-12
::  larger table in FROM, smaller table in JOIN
::  emp (5 rows) FROM, dept-small (3 rows) JOIN
::  Eve(dept-ref=99) unmatched on left
++  test-predicate-join-12
  =|  run=@ud
  %-  exec-0-1
  :*  run
      :+  ~2012.4.30
          %db1
          %-  zing  :~  "CREATE DATABASE db1;"
                        "CREATE TABLE dept-sm ".
                        "(dept-id @ud, dept-name @t) ".
                        "PRIMARY KEY (dept-id);"
                        "INSERT INTO dept-sm VALUES ".
                        "(1, 'Engineering') ".
                        "(2, 'Sales') ".
                        "(3, 'Marketing');"
                        create-emp
                        insert-emp
                        ==
      ::
      :+  ~2012.5.3
          %db1
          "FROM emp T1 ".
          "JOIN dept-sm T2 ON T1.dept-ref = T2.dept-id ".
          "SELECT T1.emp-name, T2.dept-name"
      ::
      :-  %results
          :~  [%action 'SELECT']
              :-  %result-set
                  :~  :-  %vector
                          :~  [%emp-name [~.t 'Alice']]
                              [%dept-name [~.t 'Engineering']]
                              ==
                      :-  %vector
                          :~  [%emp-name [~.t 'Bob']]
                              [%dept-name [~.t 'Engineering']]
                              ==
                      :-  %vector
                          :~  [%emp-name [~.t 'Carol']]
                              [%dept-name [~.t 'Sales']]
                              ==
                      :-  %vector
                          :~  [%emp-name [~.t 'Dave']]
                              [%dept-name [~.t 'Marketing']]
                              ==
                      ==
              [%server-time ~2012.5.3]
              [%relation 'db1.dbo.dept-sm']
              [%schema-time ~2012.4.30]
              [%data-time ~2012.4.30]
              [%relation 'db1.dbo.emp']
              [%schema-time ~2012.4.30]
              [%data-time ~2012.4.30]
              [%vector-count 4]
              ==
      ==
::
::  test-predicate-join-13
::  smaller table in FROM, larger table in JOIN
::  dept-small (3 rows) FROM, emp (5 rows) JOIN
::  Eve(dept-ref=99) unmatched on right (JOIN side)
++  test-predicate-join-13
  =|  run=@ud
  %-  exec-0-1
  :*  run
      :+  ~2012.4.30
          %db1
          %-  zing  :~  "CREATE DATABASE db1;"
                        "CREATE TABLE dept-sm2 ".
                        "(dept-id @ud, dept-name @t) ".
                        "PRIMARY KEY (dept-id);"
                        "INSERT INTO dept-sm2 VALUES ".
                        "(1, 'Engineering') ".
                        "(2, 'Sales') ".
                        "(3, 'Marketing');"
                        create-emp
                        insert-emp
                        ==
      ::
      :+  ~2012.5.3
          %db1
          "FROM dept-sm2 T1 ".
          "JOIN emp T2 ON T1.dept-id = T2.dept-ref ".
          "SELECT T1.dept-name, T2.emp-name"
      ::
      :-  %results
          :~  [%action 'SELECT']
              :-  %result-set
                  :~  :-  %vector
                          :~  [%dept-name [~.t 'Engineering']]
                              [%emp-name [~.t 'Alice']]
                              ==
                      :-  %vector
                          :~  [%dept-name [~.t 'Engineering']]
                              [%emp-name [~.t 'Bob']]
                              ==
                      :-  %vector
                          :~  [%dept-name [~.t 'Sales']]
                              [%emp-name [~.t 'Carol']]
                              ==
                      :-  %vector
                          :~  [%dept-name [~.t 'Marketing']]
                              [%emp-name [~.t 'Dave']]
                              ==
                      ==
              [%server-time ~2012.5.3]
              [%relation 'db1.dbo.dept-sm2']
              [%schema-time ~2012.4.30]
              [%data-time ~2012.4.30]
              [%relation 'db1.dbo.emp']
              [%schema-time ~2012.4.30]
              [%data-time ~2012.4.30]
              [%vector-count 4]
              ==
      ==
::
::  test-predicate-join-14
::  3-table predicate join: emp -> dept -> proj
::  FROM emp JOIN dept ON emp.dept-ref=dept.dept-id JOIN proj ON proj.lead-emp=emp.emp-id
::  non-matching: Eve(99), dept Legal(4)/Finance(5), proj Gamma(lead-emp=777)
++  test-predicate-join-14
  =|  run=@ud
  %-  exec-0-1
  :*  run
      :+  ~2012.4.30
          %db1
          %-  zing  :~  "CREATE DATABASE db1;"
                        create-emp
                        insert-emp
                        create-dept
                        insert-dept
                        create-proj
                        insert-proj
                        ==
      ::
      :+  ~2012.5.3
          %db1
          "FROM emp T1 ".
          "JOIN dept T2 ON T1.dept-ref = T2.dept-id ".
          "JOIN proj T3 ON T3.lead-emp = T1.emp-id ".
          "SELECT T1.emp-name, T2.dept-name, T3.proj-name"
      ::
      :-  %results
          :~  [%action 'SELECT']
              :-  %result-set
                  :~  :-  %vector
                          :~  [%emp-name [~.t 'Alice']]
                              [%dept-name [~.t 'Engineering']]
                              [%proj-name [~.t 'Alpha']]
                              ==
                      :-  %vector
                          :~  [%emp-name [~.t 'Carol']]
                              [%dept-name [~.t 'Sales']]
                              [%proj-name [~.t 'Beta']]
                              ==
                      ==
              [%server-time ~2012.5.3]
              [%relation 'db1.dbo.dept']
              [%schema-time ~2012.4.30]
              [%data-time ~2012.4.30]
              [%relation 'db1.dbo.emp']
              [%schema-time ~2012.4.30]
              [%data-time ~2012.4.30]
              [%relation 'db1.dbo.proj']
              [%schema-time ~2012.4.30]
              [%data-time ~2012.4.30]
              [%vector-count 2]
              ==
      ==
::
::  test-predicate-join-15
::  mixed: natural join first, then predicate join
::  FROM calendar JOIN holiday-calendar (natural on date PK)
::  JOIN emp ON ... (predicate join)
::  uses a bridge table to connect calendar date to emp
++  test-predicate-join-15
  =|  run=@ud
  %-  exec-0-1
  :*  run
      :+  ~2012.4.30
          %db1
          %-  zing  :~  "CREATE DATABASE db1;"
                        create-dept
                        insert-dept
                        create-emp
                        insert-emp
                        create-proj
                        insert-proj
                        ==
      ::
      :+  ~2012.5.3
          %db1
          "FROM dept T1 ".
          "JOIN emp T2 ON T1.dept-id = T2.dept-ref ".
          "JOIN proj T3 ON T3.lead-emp = T2.emp-id ".
          "SELECT T1.dept-name, T2.emp-name, T3.proj-name"
      ::
      :-  %results
          :~  [%action 'SELECT']
              :-  %result-set
                  :~  :-  %vector
                          :~  [%dept-name [~.t 'Engineering']]
                              [%emp-name [~.t 'Alice']]
                              [%proj-name [~.t 'Alpha']]
                              ==
                      :-  %vector
                          :~  [%dept-name [~.t 'Sales']]
                              [%emp-name [~.t 'Carol']]
                              [%proj-name [~.t 'Beta']]
                              ==
                      ==
              [%server-time ~2012.5.3]
              [%relation 'db1.dbo.dept']
              [%schema-time ~2012.4.30]
              [%data-time ~2012.4.30]
              [%relation 'db1.dbo.emp']
              [%schema-time ~2012.4.30]
              [%data-time ~2012.4.30]
              [%relation 'db1.dbo.proj']
              [%schema-time ~2012.4.30]
              [%data-time ~2012.4.30]
              [%vector-count 2]
              ==
      ==
::
::  test-predicate-join-16
::  ON predicate references earlier (non-adjacent) relation in the join stack
::  FROM dept T1 JOIN emp T2 ON ... JOIN proj T3 ON T3.lead-emp = T1.dept-id
::  T3's ON references T1 (two positions back), not T2
::  proj.lead-emp matches dept.dept-id: Alpha(10) no match, Beta(30) no match,
::  Gamma(777) no match; only matches where lead-emp equals a dept-id value
++  test-predicate-join-16
  =|  run=@ud
  %-  exec-0-1
  :*  run
      :+  ~2012.4.30
          %db1
          %-  zing  :~  "CREATE DATABASE db1;"
                        create-dept
                        insert-dept
                        create-emp
                        insert-emp
                        "CREATE TABLE proj2 ".
                        "(proj-id @ud, proj-name @t, lead-dept @ud) ".
                        "PRIMARY KEY (proj-id);"
                        "INSERT INTO proj2 VALUES ".
                        "(100, 'Alpha', 1) ".
                        "(200, 'Beta', 2) ".
                        "(300, 'Gamma', 777);"
                        ==
      ::
      :+  ~2012.5.3
          %db1
          "FROM dept T1 ".
          "JOIN emp T2 ON T1.dept-id = T2.dept-ref ".
          "JOIN proj2 T3 ON T3.lead-dept = T1.dept-id ".
          "SELECT T1.dept-name, T2.emp-name, T3.proj-name"
      ::
      :-  %results
          :~  [%action 'SELECT']
              :-  %result-set
                  :~  :-  %vector
                          :~  [%dept-name [~.t 'Engineering']]
                              [%emp-name [~.t 'Alice']]
                              [%proj-name [~.t 'Alpha']]
                              ==
                      :-  %vector
                          :~  [%dept-name [~.t 'Engineering']]
                              [%emp-name [~.t 'Bob']]
                              [%proj-name [~.t 'Alpha']]
                              ==
                      :-  %vector
                          :~  [%dept-name [~.t 'Sales']]
                              [%emp-name [~.t 'Carol']]
                              [%proj-name [~.t 'Beta']]
                              ==
                      ==
              [%server-time ~2012.5.3]
              [%relation 'db1.dbo.dept']
              [%schema-time ~2012.4.30]
              [%data-time ~2012.4.30]
              [%relation 'db1.dbo.emp']
              [%schema-time ~2012.4.30]
              [%data-time ~2012.4.30]
              [%relation 'db1.dbo.proj2']
              [%schema-time ~2012.4.30]
              [%data-time ~2012.4.30]
              [%vector-count 3]
              ==
      ==
::
::  test-predicate-join-17
::  predicate join with post-join WHERE filter
::  join emp to dept on dept-ref=dept-id, then WHERE dept-name = 'Engineering'
::  non-matching: Eve(99), Legal(4), Finance(5) filtered by join;
::  Carol(Sales), Dave(Marketing) filtered by WHERE
++  test-predicate-join-17
  =|  run=@ud
  %-  exec-0-1
  :*  run
      :+  ~2012.4.30
          %db1
          %-  zing  :~  "CREATE DATABASE db1;"
                        create-dept
                        insert-dept
                        create-emp
                        insert-emp
                        ==
      ::
      :+  ~2012.5.3
          %db1
          "FROM emp T1 ".
          "JOIN dept T2 ON T1.dept-ref = T2.dept-id ".
          "WHERE T2.dept-name = 'Engineering' ".
          "SELECT T1.emp-name, T2.dept-name"
      ::
      :-  %results
          :~  [%action 'SELECT']
              :-  %result-set
                  :~  :-  %vector
                          :~  [%emp-name [~.t 'Alice']]
                              [%dept-name [~.t 'Engineering']]
                              ==
                      :-  %vector
                          :~  [%emp-name [~.t 'Bob']]
                              [%dept-name [~.t 'Engineering']]
                              ==
                      ==
              [%server-time ~2012.5.3]
              [%relation 'db1.dbo.dept']
              [%schema-time ~2012.4.30]
              [%data-time ~2012.4.30]
              [%relation 'db1.dbo.emp']
              [%schema-time ~2012.4.30]
              [%data-time ~2012.4.30]
              [%vector-count 2]
              ==
      ==
::
::  test-predicate-join-18
::  predicate join with specific column SELECT (not *)
::  select only emp-name from left, only dept-name from right
::  non-matching rows on both sides
++  test-predicate-join-18
  =|  run=@ud
  %-  exec-0-1
  :*  run
      :+  ~2012.4.30
          %db1
          %-  zing  :~  "CREATE DATABASE db1;"
                        create-dept
                        insert-dept
                        create-emp
                        insert-emp
                        ==
      ::
      :+  ~2012.5.3
          %db1
          "FROM emp T1 ".
          "JOIN dept T2 ON T1.dept-ref = T2.dept-id ".
          "SELECT T1.emp-name"
      ::
      :-  %results
          :~  [%action 'SELECT']
              :-  %result-set
                  :~  :-  %vector
                          :~  [%emp-name [~.t 'Alice']]
                              ==
                      :-  %vector
                          :~  [%emp-name [~.t 'Bob']]
                              ==
                      :-  %vector
                          :~  [%emp-name [~.t 'Carol']]
                              ==
                      :-  %vector
                          :~  [%emp-name [~.t 'Dave']]
                              ==
                      ==
              [%server-time ~2012.5.3]
              [%relation 'db1.dbo.dept']
              [%schema-time ~2012.4.30]
              [%data-time ~2012.4.30]
              [%relation 'db1.dbo.emp']
              [%schema-time ~2012.4.30]
              [%data-time ~2012.4.30]
              [%vector-count 4]
              ==
      ==
::
::  test-predicate-join-19
::  self-join with aliases: same table joined to itself on different columns
::  emp joined to emp: find employees in the same department
::  ON T1.dept-ref = T2.dept-ref AND T1.emp-id <> T2.emp-id would need inequality,
::  so instead: self-join on dept-ref, with WHERE to exclude self-pairs
::  for equality-only path: join on dept-ref = dept-ref (same column, both sides)
::  non-matching: Eve(dept-ref=99) has no pair
++  test-predicate-join-19
  =|  run=@ud
  %-  exec-0-1
  :*  run
      :+  ~2012.4.30
          %db1
          %-  zing  :~  "CREATE DATABASE db1;"
                        create-emp
                        insert-emp
                        ==
      ::
      :+  ~2012.5.3
          %db1
          "FROM emp T1 ".
          "JOIN emp T2 ON T1.dept-ref = T2.dept-ref ".
          "WHERE T1.emp-id < T2.emp-id ".
          "SELECT T1.emp-name, T2.emp-name"
      ::
      :-  %results
          :~  [%action 'SELECT']
              :-  %result-set
                  :~  :-  %vector
                          :~  [%emp-name [~.t 'Alice']]
                              [%emp-name [~.t 'Bob']]
                              ==
                      ==
              [%server-time ~2012.5.3]
              [%relation 'db1.dbo.emp']
              [%schema-time ~2012.4.30]
              [%data-time ~2012.4.30]
              [%vector-count 1]
              ==
      ==
::
::  test-predicate-join-20
::  single-row tables on both sides, matching
::  verifies minimum-size join works correctly
++  test-predicate-join-20
  =|  run=@ud
  %-  exec-0-1
  :*  run
      :+  ~2012.4.30
          %db1
          %-  zing  :~  "CREATE DATABASE db1;"
                        create-tiny-a
                        insert-tiny-a
                        create-tiny-b
                        insert-tiny-b
                        ==
      ::
      :+  ~2012.5.3
          %db1
          "FROM tiny-a T1 ".
          "JOIN tiny-b T2 ON T1.ta-id = T2.tb-id ".
          "SELECT T1.*, T2.*"
      ::
      :-  %results
          :~  [%action 'SELECT']
              :-  %result-set
                  :~  :-  %vector
                          :~  [%ta-id [~.ud 1]]
                              [%ta-val [~.t 'only-a']]
                              [%tb-id [~.ud 1]]
                              [%tb-val [~.t 'only-b']]
                              ==
                      ==
              [%server-time ~2012.5.3]
              [%relation 'db1.dbo.tiny-a']
              [%schema-time ~2012.4.30]
              [%data-time ~2012.4.30]
              [%relation 'db1.dbo.tiny-b']
              [%schema-time ~2012.4.30]
              [%data-time ~2012.4.30]
              [%vector-count 1]
              ==
      ==
::
::  test-predicate-join-21
::  unqualified columns in ON that resolve unambiguously
::  dept-ref only exists in emp, dept-id only exists in dept
::  non-matching rows on both sides
++  test-predicate-join-21
  =|  run=@ud
  %-  exec-0-1
  :*  run
      :+  ~2012.4.30
          %db1
          %-  zing  :~  "CREATE DATABASE db1;"
                        create-dept
                        insert-dept
                        create-emp
                        insert-emp
                        ==
      ::
      :+  ~2012.5.3
          %db1
          "FROM emp T1 ".
          "JOIN dept T2 ON dept-ref = dept-id ".
          "SELECT T1.emp-name, T2.dept-name"
      ::
      :-  %results
          :~  [%action 'SELECT']
              :-  %result-set
                  :~  :-  %vector
                          :~  [%emp-name [~.t 'Alice']]
                              [%dept-name [~.t 'Engineering']]
                              ==
                      :-  %vector
                          :~  [%emp-name [~.t 'Bob']]
                              [%dept-name [~.t 'Engineering']]
                              ==
                      :-  %vector
                          :~  [%emp-name [~.t 'Carol']]
                              [%dept-name [~.t 'Sales']]
                              ==
                      :-  %vector
                          :~  [%emp-name [~.t 'Dave']]
                              [%dept-name [~.t 'Marketing']]
                              ==
                      ==
              [%server-time ~2012.5.3]
              [%relation 'db1.dbo.dept']
              [%schema-time ~2012.4.30]
              [%data-time ~2012.4.30]
              [%relation 'db1.dbo.emp']
              [%schema-time ~2012.4.30]
              [%data-time ~2012.4.30]
              [%vector-count 4]
              ==
      ==
::
::  sys-view predicate join tests
::  ─────────────────────────────────────────────────────────────────────────
::  Group A: user table JOIN sys view (and inverted) via ON predicate
::  ─────────────────────────────────────────────────────────────────────────
::
::  test-predicate-join-22 (A-0)
::  user date-catalog JOIN sys.tables ON sys.tables.tmsp = date-catalog.ref-date
::  date-catalog created in action poke (~2012.5.1) so its own sys.tables entry
::  has tmsp ~2012.5.1, isolating the match to emp (tmsp ~2012.4.30)
++  test-predicate-join-22
  =|  run=@ud
  %-  exec-1-1
  :*  run
      :+  ~2012.4.30
          %db1
          %-  zing  :~  "CREATE DATABASE db1;"
                        create-emp
                        insert-emp
                        ==
      ::
      :+  ~2012.5.1
          %db1
          %-  zing  :~  create-date-catalog
                        insert-date-catalog
                        ==
      ::
      :+  ~2012.5.3
          %db1
          "FROM date-catalog T1 ".
          "JOIN sys.tables T2 ON T2.tmsp = T1.ref-date ".
          "SELECT T1.ref-date, T1.dc-note, T2.name"
      ::
      :-  %results
          :~  [%action 'SELECT']
              :-  %result-set
                  :~  :-  %vector
                          :~  [%ref-date [~.da ~2012.4.30]]
                              [%dc-note [~.t 'matches emp table']]
                              [%name [~.tas %emp]]
                              ==
                      ==
              [%server-time ~2012.5.3]
              [%relation 'db1.dbo.date-catalog']
              [%schema-time ~2012.5.1]
              [%data-time ~2012.5.1]
              [%relation 'db1.sys.tables']
              [%schema-time ~2012.5.1]
              [%data-time ~2012.5.1]
              [%vector-count 1]
              ==
      ==
::
::  test-predicate-join-23 (A-1)
::  same as A-0 with tables inverted: sys.tables on left, date-catalog on right
++  test-predicate-join-23
  =|  run=@ud
  %-  exec-1-1
  :*  run
      :+  ~2012.4.30
          %db1
          %-  zing  :~  "CREATE DATABASE db1;"
                        create-emp
                        insert-emp
                        ==
      ::
      :+  ~2012.5.1
          %db1
          %-  zing  :~  create-date-catalog
                        insert-date-catalog
                        ==
      ::
      :+  ~2012.5.3
          %db1
          "FROM sys.tables T1 ".
          "JOIN date-catalog T2 ON T1.tmsp = T2.ref-date ".
          "SELECT T2.ref-date, T2.dc-note, T1.name"
      ::
      :-  %results
          :~  [%action 'SELECT']
              :-  %result-set
                  :~  :-  %vector
                          :~  [%ref-date [~.da ~2012.4.30]]
                              [%dc-note [~.t 'matches emp table']]
                              [%name [~.tas %emp]]
                              ==
                      ==
              [%server-time ~2012.5.3]
              [%relation 'db1.dbo.date-catalog']
              [%schema-time ~2012.5.1]
              [%data-time ~2012.5.1]
              [%relation 'db1.sys.tables']
              [%schema-time ~2012.5.1]
              [%data-time ~2012.5.1]
              [%vector-count 1]
              ==
      ==
::
::  test-predicate-join-24 (A-2)
::  user date-catalog JOIN sys.tables ON tmsp = ref-date: no rows match
::  date-catalog has only far-future dates; no sys.tables entry has those tmsp values
++  test-predicate-join-24
  =|  run=@ud
  %-  exec-0-1
  :*  run
      :+  ~2012.4.30
          %db1
          %-  zing  :~  "CREATE DATABASE db1;"
                        create-emp
                        insert-emp
                        create-date-catalog
                        "INSERT INTO date-catalog VALUES ".
                        "(1, ~2099.1.1, 'future A') ".
                        "(2, ~2099.12.31, 'future B');"
                        ==
      ::
      :+  ~2012.5.3
          %db1
          "FROM date-catalog T1 ".
          "JOIN sys.tables T2 ON T2.tmsp = T1.ref-date ".
          "SELECT T1.ref-date, T1.dc-note"
      ::
      :-  %results
          :~  [%action 'SELECT']
              [%result-set ~]
              [%server-time ~2012.5.3]
              [%relation 'db1.dbo.date-catalog']
              [%schema-time ~2012.4.30]
              [%data-time ~2012.4.30]
              [%relation 'db1.sys.tables']
              [%schema-time ~2012.4.30]
              [%data-time ~2012.4.30]
              [%vector-count 0]
              ==
      ==
::
::  test-predicate-join-25 (A-3)
::  ns-date-cat JOIN sys.namespaces ON sys.namespaces.tmsp = ns-date-cat.ns-date
::  sys.namespaces has one row (dbo, ~2012.4.30); row 1 matches, row 2 does not
++  test-predicate-join-25
  =|  run=@ud
  %-  exec-0-1
  :*  run
      :+  ~2012.4.30
          %db1
          %-  zing  :~  "CREATE DATABASE db1;"
                        create-ns-date-cat
                        insert-ns-date-cat
                        ==
      ::
      :+  ~2012.5.3
          %db1
          "FROM ns-date-cat T1 ".
          "JOIN sys.namespaces T2 ON T2.tmsp = T1.ns-date ".
          "SELECT T1.ns-date, T1.ndc-note, T2.namespace"
      ::
      :-  %results
          :~  [%action 'SELECT']
              :-  %result-set
                  :~  :-  %vector
                          :~  [%ns-date [~.da ~2012.4.30]]
                              [%ndc-note [~.t 'matches dbo namespace']]
                              [%namespace [~.tas %dbo]]
                              ==
                      :-  %vector
                          :~  [%ns-date [~.da ~2012.4.30]]
                              [%ndc-note [~.t 'matches dbo namespace']]
                              [%namespace [~.tas %sys]]
                              ==
                      ==
              [%server-time ~2012.5.3]
              [%relation 'db1.dbo.ns-date-cat']
              [%schema-time ~2012.4.30]
              [%data-time ~2012.4.30]
              [%relation 'db1.sys.namespaces']
              [%schema-time ~2012.4.30]
              [%data-time ~2012.4.30]
              [%vector-count 2]
              ==
      ==
::
::  test-predicate-join-26 (A-4)
::  compound ON: compound-cat JOIN sys.tables ON tmsp = ref-date AND row-count = row-count-ref
::  two equality conditions required simultaneously; row 2 in compound-cat has wrong count
::  compound-cat created in action poke to isolate emp as the only tmsp match
++  test-predicate-join-26
  =|  run=@ud
  %-  exec-1-1
  :*  run
      :+  ~2012.4.30
          %db1
          %-  zing  :~  "CREATE DATABASE db1;"
                        create-emp
                        insert-emp
                        ==
      ::
      :+  ~2012.5.1
          %db1
          %-  zing  :~  create-compound-cat
                        insert-compound-cat
                        ==
      ::
      :+  ~2012.5.3
          %db1
          "FROM compound-cat T1 ".
          "JOIN sys.tables T2 ".
          "ON T2.tmsp = T1.ref-date AND T2.row-count = T1.row-count-ref ".
          "SELECT T1.ref-date, T1.row-count-ref, T1.cc-note, T2.name"
      ::
      :-  %results
          :~  [%action 'SELECT']
              :-  %result-set
                  :~  :-  %vector
                          :~  [%ref-date [~.da ~2012.4.30]]
                              [%row-count-ref [~.ud 5]]
                              [%cc-note [~.t 'emp: 5 rows at init']]
                              [%name [~.tas %emp]]
                              ==
                      ==
              [%server-time ~2012.5.3]
              [%relation 'db1.dbo.compound-cat']
              [%schema-time ~2012.5.1]
              [%data-time ~2012.5.1]
              [%relation 'db1.sys.tables']
              [%schema-time ~2012.5.1]
              [%data-time ~2012.5.1]
              [%vector-count 1]
              ==
      ==
::
::  test-predicate-join-27 (A-5a)
::  ship-cat JOIN sys.sys.databases ON data-ship = ship-ref; query issued from %db1
::  both db1 and sys share data-ship=~zod; ship-cat row 1 joins to both
++  test-predicate-join-27
  =|  run=@ud
  %-  exec-1-1
  :*  run
      [~2012.4.30 %sys "CREATE DATABASE db1"]
      ::
      :+  ~2012.5.1
          %db1
          %-  zing  :~  create-ship-cat
                        insert-ship-cat
                        ==
      ::
      :+  ~2012.5.3
          %db1
          "FROM ship-cat T1 ".
          "JOIN sys.sys.databases T2 ON T2.data-ship = T1.ship-ref ".
          "SELECT T1.ship-ref, T1.sc-note, T2.database"
      ::
      :-  %results
          :~  [%action 'SELECT']
              :-  %result-set
                  :~  :-  %vector
                          :~  [%ship-ref [~.p ~zod]]
                              [%sc-note [~.t 'local ship']]
                              [%database [~.tas %db1]]
                              ==
                      :-  %vector
                          :~  [%ship-ref [~.p ~zod]]
                              [%sc-note [~.t 'local ship']]
                              [%database [~.tas %sys]]
                              ==
                      ==
              [%server-time ~2012.5.3]
              [%relation 'db1.dbo.ship-cat']
              [%schema-time ~2012.5.1]
              [%data-time ~2012.5.1]
              [%relation 'sys.sys.databases']
              [%schema-time ~2012.4.30]
              [%data-time ~2012.5.1]
              [%vector-count 2]
              ==
      ==
::
::  test-predicate-join-28 (A-5b)
::  same join as A-5a but query issued from %sys context; db1..ship-cat fully qualified
++  test-predicate-join-28
  =|  run=@ud
  %-  exec-1-1
  :*  run
      [~2012.4.30 %sys "CREATE DATABASE db1"]
      ::
      :+  ~2012.5.1
          %db1
          %-  zing  :~  create-ship-cat
                        insert-ship-cat
                        ==
      ::
      :+  ~2012.5.3
          %sys
          "FROM db1..ship-cat T1 ".
          "JOIN sys.sys.databases T2 ON T2.data-ship = T1.ship-ref ".
          "SELECT T1.ship-ref, T1.sc-note, T2.database"
      ::
      :-  %results
          :~  [%action 'SELECT']
              :-  %result-set
                  :~  :-  %vector
                          :~  [%ship-ref [~.p ~zod]]
                              [%sc-note [~.t 'local ship']]
                              [%database [~.tas %db1]]
                              ==
                      :-  %vector
                          :~  [%ship-ref [~.p ~zod]]
                              [%sc-note [~.t 'local ship']]
                              [%database [~.tas %sys]]
                              ==
                      ==
              [%server-time ~2012.5.3]
              [%relation 'db1.dbo.ship-cat']
              [%schema-time ~2012.5.1]
              [%data-time ~2012.5.1]
              [%relation 'sys.sys.databases']
              [%schema-time ~2012.4.30]
              [%data-time ~2012.5.1]
              [%vector-count 2]
              ==
      ==
::
::  ─────────────────────────────────────────────────────────────────────────
::  Group B: sys view JOIN sys view via ON predicate
::  ─────────────────────────────────────────────────────────────────────────
::
::  test-predicate-join-29 (B-0)
::  sys.tables JOIN sys.namespaces ON namespace = namespace
::  emp and dept (both in dbo) each join to the single dbo namespace row
++  test-predicate-join-29
  =|  run=@ud
  %-  exec-0-1
  :*  run
      :+  ~2012.4.30
          %db1
          %-  zing  :~  "CREATE DATABASE db1;"
                        create-emp
                        insert-emp
                        create-dept
                        insert-dept
                        ==
      ::
      :+  ~2012.5.3
          %db1
          "FROM sys.tables T1 ".
          "JOIN sys.namespaces T2 ON T1.namespace = T2.namespace ".
          "SELECT T1.name, T2.tmsp"
      ::
      :-  %results
          :~  [%action 'SELECT']
              :-  %result-set
                  :~  :-  %vector
                          :~  [%name [~.tas %dept]]
                              [%tmsp [~.da ~2012.4.30]]
                              ==
                      :-  %vector
                          :~  [%name [~.tas %emp]]
                              [%tmsp [~.da ~2012.4.30]]
                              ==
                      ==
              [%server-time ~2012.5.3]
              [%relation 'db1.sys.namespaces']
              [%schema-time ~2012.4.30]
              [%data-time ~2012.4.30]
              [%relation 'db1.sys.tables']
              [%schema-time ~2012.4.30]
              [%data-time ~2012.4.30]
              [%vector-count 2]
              ==
      ==
::
::  test-predicate-join-30 (B-1)
::  sys.columns JOIN sys.tables ON namespace = namespace AND name = name
::  mini-tbl has 2 columns; each column row joins to the single mini-tbl table row
++  test-predicate-join-30
  =|  run=@ud
  %-  exec-0-1
  :*  run
      :+  ~2012.4.30
          %db1
          %-  zing  :~  "CREATE DATABASE db1;"
                        create-mini-tbl
                        ==
      ::
      :+  ~2012.5.3
          %db1
          "FROM sys.columns T1 ".
          "JOIN sys.tables T2 ON T1.namespace = T2.namespace AND T1.name = T2.name ".
          "SELECT T1.col-name, T1.col-type, T2.namespace"
      ::
      :-  %results
          :~  [%action 'SELECT']
              :-  %result-set
                  :~  :-  %vector
                          :~  [%col-name [~.tas %mk-id]]
                              [%col-type [~.ta 'ud']]
                              [%namespace [~.tas %dbo]]
                              ==
                      :-  %vector
                          :~  [%col-name [~.tas %mk-tag]]
                              [%col-type [~.ta 't']]
                              [%namespace [~.tas %dbo]]
                              ==
                      ==
              [%server-time ~2012.5.3]
              [%relation 'db1.sys.columns']
              [%schema-time ~2012.4.30]
              [%data-time ~2012.4.30]
              [%relation 'db1.sys.tables']
              [%schema-time ~2012.4.30]
              [%data-time ~2012.4.30]
              [%vector-count 2]
              ==
      ==
::
::  ─────────────────────────────────────────────────────────────────────────
::  Group C: 3-table joins with sys view in the sequence
::  ─────────────────────────────────────────────────────────────────────────
::
::  test-predicate-join-31 (C-0)
::  3-table: date-ref-tbl JOIN sys.tables ON tmsp = ref-date JOIN emp ON emp-id = owner-id
::  sys view at middle of the join chain; date-ref-tbl created in action poke to isolate match
++  test-predicate-join-31
  =|  run=@ud
  %-  exec-1-1
  :*  run
      :+  ~2012.4.30
          %db1
          %-  zing  :~  "CREATE DATABASE db1;"
                        create-emp
                        insert-emp
                        ==
      ::
      :+  ~2012.5.1
          %db1
          %-  zing  :~  create-date-ref-tbl
                        insert-date-ref-tbl
                        ==
      ::
      :+  ~2012.5.3
          %db1
          "FROM date-ref-tbl T1 ".
          "JOIN sys.tables T2 ON T2.tmsp = T1.ref-date ".
          "JOIN emp T3 ON T3.emp-id = T1.owner-id ".
          "SELECT T1.ref-date, T2.name, T3.emp-name"
      ::
      :-  %results
          :~  [%action 'SELECT']
              :-  %result-set
                  :~  :-  %vector
                          :~  [%ref-date [~.da ~2012.4.30]]
                              [%name [~.tas %emp]]
                              [%emp-name [~.t 'Alice']]
                              ==
                      ==
              [%server-time ~2012.5.3]
              [%relation 'db1.dbo.date-ref-tbl']
              [%schema-time ~2012.5.1]
              [%data-time ~2012.5.1]
              [%relation 'db1.dbo.emp']
              [%schema-time ~2012.4.30]
              [%data-time ~2012.4.30]
              [%relation 'db1.sys.tables']
              [%schema-time ~2012.5.1]
              [%data-time ~2012.5.1]
              [%vector-count 1]
              ==
      ==
::
::  test-predicate-join-32 (C-1)
::  3-table: sys.tables JOIN date-ref-tbl ON tmsp = ref-date JOIN emp ON emp-id = owner-id
::  sys view at head of the join chain; same data, same result as C-0
++  test-predicate-join-32
  =|  run=@ud
  %-  exec-1-1
  :*  run
      :+  ~2012.4.30
          %db1
          %-  zing  :~  "CREATE DATABASE db1;"
                        create-emp
                        insert-emp
                        ==
      ::
      :+  ~2012.5.1
          %db1
          %-  zing  :~  create-date-ref-tbl
                        insert-date-ref-tbl
                        ==
      ::
      :+  ~2012.5.3
          %db1
          "FROM sys.tables T1 ".
          "JOIN date-ref-tbl T2 ON T1.tmsp = T2.ref-date ".
          "JOIN emp T3 ON T3.emp-id = T2.owner-id ".
          "SELECT T2.ref-date, T1.name, T3.emp-name"
      ::
      :-  %results
          :~  [%action 'SELECT']
              :-  %result-set
                  :~  :-  %vector
                          :~  [%ref-date [~.da ~2012.4.30]]
                              [%name [~.tas %emp]]
                              [%emp-name [~.t 'Alice']]
                              ==
                      ==
              [%server-time ~2012.5.3]
              [%relation 'db1.dbo.date-ref-tbl']
              [%schema-time ~2012.5.1]
              [%data-time ~2012.5.1]
              [%relation 'db1.dbo.emp']
              [%schema-time ~2012.4.30]
              [%data-time ~2012.4.30]
              [%relation 'db1.sys.tables']
              [%schema-time ~2012.5.1]
              [%data-time ~2012.5.1]
              [%vector-count 1]
              ==
      ==
::
::  ─────────────────────────────────────────────────────────────────────────
::  Group D: ON predicate joins in CTEs; joining main sequence to CTEs
::  ─────────────────────────────────────────────────────────────────────────
::
::  test-predicate-join-33 (D-0)
::  CTE definition contains ON predicate join (compound-cat JOIN sys.tables)
::  CTE result is cross-joined to main FROM tiny-a
::  verifies CTE inner query is not limited to single-table FROM
++  test-predicate-join-33
  =|  run=@ud
  %-  exec-1-1
  :*  run
      :+  ~2012.4.30
          %db1
          %-  zing  :~  "CREATE DATABASE db1;"
                        create-emp
                        insert-emp
                        ==
      ::
      :+  ~2012.5.1
          %db1
          %-  zing  :~  create-compound-cat
                        insert-compound-cat
                        create-tiny-a
                        insert-tiny-a
                        ==
      ::
      :+  ~2012.5.3
          %db1
          "WITH (FROM compound-cat T1 ".
          "      JOIN sys.tables T2 ".
          "      ON T2.tmsp = T1.ref-date AND T2.row-count = T1.row-count-ref ".
          "      SELECT T1.row-count-ref, T2.name) AS meta ".
          "FROM tiny-a ".
          "SELECT ta-val, meta.row-count-ref, meta.name"
      ::
      :-  %results
          :~  [%action 'SELECT']
              :-  %result-set
                  :~  :-  %vector
                          :~  [%ta-val [~.t 'only-a']]
                              [%row-count-ref [~.ud 5]]
                              [%name [~.tas %emp]]
                              ==
                      ==
              [%server-time ~2012.5.3]
              [%relation 'db1.dbo.compound-cat']
              [%schema-time ~2012.5.1]
              [%data-time ~2012.5.1]
              [%relation 'db1.dbo.tiny-a']
              [%schema-time ~2012.5.1]
              [%data-time ~2012.5.1]
              [%relation 'db1.sys.tables']
              [%schema-time ~2012.5.1]
              [%data-time ~2012.5.1]
              [%vector-count 1]
              ==
      ==
::
::  test-predicate-join-34 (D-1)
::  CTE wraps a user table (tiny-a); main FROM has ON join to sys.tables
::  tests joining in the main sequence to a sys view while a CTE is also present
++  test-predicate-join-34
  =|  run=@ud
  %-  exec-1-1
  :*  run
      :+  ~2012.4.30
          %db1
          %-  zing  :~  "CREATE DATABASE db1;"
                        create-emp
                        insert-emp
                        ==
      ::
      :+  ~2012.5.1
          %db1
          %-  zing  :~  create-date-catalog
                        insert-date-catalog
                        create-tiny-a
                        insert-tiny-a
                        ==
      ::
      :+  ~2012.5.3
          %db1
          "WITH (FROM tiny-a SELECT ta-val) AS tiny-cte ".
          "FROM date-catalog T1 ".
          "JOIN sys.tables T2 ON T2.tmsp = T1.ref-date ".
          "SELECT T1.ref-date, T2.name, tiny-cte.ta-val"
      ::
      :-  %results
          :~  [%action 'SELECT']
              :-  %result-set
                  :~  :-  %vector
                          :~  [%ref-date [~.da ~2012.4.30]]
                              [%name [~.tas %emp]]
                              [%ta-val [~.t 'only-a']]
                              ==
                      ==
              [%server-time ~2012.5.3]
              [%relation 'db1.dbo.date-catalog']
              [%schema-time ~2012.5.1]
              [%data-time ~2012.5.1]
              [%relation 'db1.dbo.tiny-a']
              [%schema-time ~2012.5.1]
              [%data-time ~2012.5.1]
              [%relation 'db1.sys.tables']
              [%schema-time ~2012.5.1]
              [%data-time ~2012.5.1]
              [%vector-count 1]
              ==
      ==
::
::  test-predicate-join-35 (D-2)
::  CTE1 has ON join inside (compound-cat JOIN sys.tables)
::  CTE2 wraps sys.namespaces directly
::  main FROM joins the two CTEs with ON predicate
++  test-predicate-join-35
  =|  run=@ud
  %-  exec-1-1
  :*  run
      :+  ~2012.4.30
          %db1
          %-  zing  :~  "CREATE DATABASE db1;"
                        create-emp
                        insert-emp
                        ==
      ::
      :+  ~2012.5.1
          %db1
          %-  zing  :~  create-compound-cat
                        insert-compound-cat
                        ==
      ::
      :+  ~2012.5.3
          %db1
          "WITH (FROM compound-cat T1 ".
          "      JOIN sys.tables T2 ".
          "      ON T2.tmsp = T1.ref-date AND T2.row-count = T1.row-count-ref ".
          "      SELECT T1.row-count-ref, T2.namespace AS tbl-ns) AS meta, ".
          "     (FROM sys.namespaces SELECT namespace, tmsp) AS nss ".
          "FROM meta T1 JOIN nss T2 ON T1.tbl-ns = T2.namespace ".
          "SELECT T1.row-count-ref, T2.tmsp"
      ::
      :-  %results
          :~  [%action 'SELECT']
              :-  %result-set
                  :~  :-  %vector
                          :~  [%row-count-ref [~.ud 5]]
                              [%tmsp [~.da ~2012.4.30]]
                              ==
                      ==
              [%server-time ~2012.5.3]
              [%relation 'db1.dbo.compound-cat']
              [%schema-time ~2012.5.1]
              [%data-time ~2012.5.1]
              [%relation 'db1.sys.namespaces']
              [%schema-time ~2012.5.1]
              [%data-time ~2012.4.30]
              [%relation 'db1.sys.tables']
              [%schema-time ~2012.5.1]
              [%data-time ~2012.5.1]
              [%vector-count 1]
              ==
      ==
::
::  ─────────────────────────────────────────────────────────────────────────
::  Group E: AS OF with sys view in ON predicate join
::  ─────────────────────────────────────────────────────────────────────────
::
::  test-predicate-join-36 (E-0)
::  tbl-cat-aof JOIN sys.tables AS OF ~2012.4.30 ON tmsp = ref-date
::  mini-aof has 1 row at ~2012.4.30 and 2 rows at query time
::  AS OF snapshot isolates mini-aof as the only sys.tables match (tbl-cat-aof
::  didn't exist at ~2012.4.30) and reports row-count=1 not 2
++  test-predicate-join-36
  =|  run=@ud
  %-  exec-2-1
  :*  run
      :+  ~2012.4.30
          %db1
          %-  zing  :~  "CREATE DATABASE db1;"
                        "CREATE TABLE mini-aof "
                        "(mk-id @ud, mk-tag @t) "
                        "PRIMARY KEY (mk-id);"
                        "INSERT INTO mini-aof VALUES (1, 'first-row');"
                        ==
      ::
      :+  ~2012.5.1
          %db1
          %-  zing  :~  "CREATE TABLE tbl-cat-aof "
                        "(cat-id @ud, ref-date @da, cat-note @t) "
                        "PRIMARY KEY (cat-id);"
                        "INSERT INTO tbl-cat-aof VALUES "
                        "(1, ~2012.4.30, 'matches mini-aof at init');"
                        ==
      ::
      :+  ~2012.5.2
          %db1
          "INSERT INTO mini-aof VALUES (2, 'second-row');"
      ::
      :+  ~2012.5.3
          %db1
          "FROM tbl-cat-aof T1 ".
          "JOIN sys.tables AS OF ~2012.4.30 T2 ON T2.tmsp = T1.ref-date ".
          "SELECT T1.ref-date, T1.cat-note, T2.name, T2.row-count"
      ::
      :-  %results
          :~  [%action 'SELECT']
              :-  %result-set
                  :~  :-  %vector
                          :~  [%ref-date [~.da ~2012.4.30]]
                              [%cat-note [~.t 'matches mini-aof at init']]
                              [%name [~.tas %mini-aof]]
                              [%row-count [~.ud 1]]
                              ==
                      ==
              [%server-time ~2012.5.3]
              [%relation 'db1.dbo.tbl-cat-aof']
              [%schema-time ~2012.5.1]
              [%data-time ~2012.5.1]
              [%relation 'db1.sys.tables']
              [%schema-time ~2012.4.30]
              [%data-time ~2012.4.30]
              [%vector-count 1]
              ==
      ==
::
::  test-predicate-join-37 (D-3)
::  CTE2 itself joins CTE1 (which is a join CTE) with sys.namespaces
::  tests that a join-CTE can be used as the left side of a join inside
::  a second CTE — exercises double-materialization path
++  test-predicate-join-37
  =|  run=@ud
  %-  exec-1-1
  :*  run
      :+  ~2012.4.30
          %db1
          %-  zing  :~  "CREATE DATABASE db1;"
                        create-emp
                        insert-emp
                        ==
      ::
      :+  ~2012.5.1
          %db1
          %-  zing  :~  create-compound-cat
                        insert-compound-cat
                        ==
      ::
      :+  ~2012.5.3
          %db1
          "WITH (FROM compound-cat T1 ".
          "      JOIN sys.tables T2 ".
          "      ON T2.tmsp = T1.ref-date AND T2.row-count = T1.row-count-ref ".
          "      SELECT T1.row-count-ref, T2.namespace AS tbl-ns) AS meta, ".
          "     (FROM meta T1 ".
          "      JOIN sys.namespaces T2 ON T1.tbl-ns = T2.namespace ".
          "      SELECT T1.row-count-ref, T2.tmsp AS ns-tmsp) AS enriched ".
          "FROM enriched SELECT *"
      ::
      :-  %results
          :~  [%action 'SELECT']
              :-  %result-set
                  :~  :-  %vector
                          :~  [%row-count-ref [~.ud 5]]
                              [%ns-tmsp [~.da ~2012.4.30]]
                              ==
                      ==
              [%server-time ~2012.5.3]
              [%relation 'db1.dbo.compound-cat']
              [%schema-time ~2012.5.1]
              [%data-time ~2012.5.1]
              [%relation 'db1.sys.namespaces']
              [%schema-time ~2012.5.1]
              [%data-time ~2012.4.30]
              [%relation 'db1.sys.tables']
              [%schema-time ~2012.5.1]
              [%data-time ~2012.5.1]
              [%vector-count 1]
              ==
      ==
::
::  test-predicate-join-38 (D-4)
::  same structure as test-35 but outer SELECT uses column aliases
::  stresses alias plumbing through the two-CTE join result
++  test-predicate-join-38
  =|  run=@ud
  %-  exec-1-1
  :*  run
      :+  ~2012.4.30
          %db1
          %-  zing  :~  "CREATE DATABASE db1;"
                        create-emp
                        insert-emp
                        ==
      ::
      :+  ~2012.5.1
          %db1
          %-  zing  :~  create-compound-cat
                        insert-compound-cat
                        ==
      ::
      :+  ~2012.5.3
          %db1
          "WITH (FROM compound-cat T1 ".
          "      JOIN sys.tables T2 ".
          "      ON T2.tmsp = T1.ref-date AND T2.row-count = T1.row-count-ref ".
          "      SELECT T1.row-count-ref, T2.namespace AS tbl-ns) AS meta, ".
          "     (FROM sys.namespaces SELECT namespace, tmsp) AS nss ".
          "FROM meta T1 JOIN nss T2 ON T1.tbl-ns = T2.namespace ".
          "SELECT T1.row-count-ref AS ref-count, T2.tmsp AS ns-date"
      ::
      :-  %results
          :~  [%action 'SELECT']
              :-  %result-set
                  :~  :-  %vector
                          :~  [%ref-count [~.ud 5]]
                              [%ns-date [~.da ~2012.4.30]]
                              ==
                      ==
              [%server-time ~2012.5.3]
              [%relation 'db1.dbo.compound-cat']
              [%schema-time ~2012.5.1]
              [%data-time ~2012.5.1]
              [%relation 'db1.sys.namespaces']
              [%schema-time ~2012.5.1]
              [%data-time ~2012.4.30]
              [%relation 'db1.sys.tables']
              [%schema-time ~2012.5.1]
              [%data-time ~2012.5.1]
              [%vector-count 1]
              ==
      ==
::
::  test-predicate-join-39 (D-5)
::  same structure as test-35 but outer query adds a WHERE predicate
::  verifies WHERE evaluation works on the materialized result of a two-CTE join
++  test-predicate-join-39
  =|  run=@ud
  %-  exec-1-1
  :*  run
      :+  ~2012.4.30
          %db1
          %-  zing  :~  "CREATE DATABASE db1;"
                        create-emp
                        insert-emp
                        ==
      ::
      :+  ~2012.5.1
          %db1
          %-  zing  :~  create-compound-cat
                        insert-compound-cat
                        ==
      ::
      :+  ~2012.5.3
          %db1
          "WITH (FROM compound-cat T1 ".
          "      JOIN sys.tables T2 ".
          "      ON T2.tmsp = T1.ref-date AND T2.row-count = T1.row-count-ref ".
          "      SELECT T1.row-count-ref, T2.namespace AS tbl-ns) AS meta, ".
          "     (FROM sys.namespaces SELECT namespace, tmsp) AS nss ".
          "FROM meta T1 JOIN nss T2 ON T1.tbl-ns = T2.namespace ".
          "WHERE tmsp = ~2012.4.30 ".
          "SELECT T1.row-count-ref, T2.tmsp"
      ::
      :-  %results
          :~  [%action 'SELECT']
              :-  %result-set
                  :~  :-  %vector
                          :~  [%row-count-ref [~.ud 5]]
                              [%tmsp [~.da ~2012.4.30]]
                              ==
                      ==
              [%server-time ~2012.5.3]
              [%relation 'db1.dbo.compound-cat']
              [%schema-time ~2012.5.1]
              [%data-time ~2012.5.1]
              [%relation 'db1.sys.namespaces']
              [%schema-time ~2012.5.1]
              [%data-time ~2012.4.30]
              [%relation 'db1.sys.tables']
              [%schema-time ~2012.5.1]
              [%data-time ~2012.5.1]
              [%vector-count 1]
              ==
      ==
::
::  test-fail-predicate-join-00
::  ON predicate references non-existent column
++  test-fail-predicate-join-00
  =|  run=@ud
  %-  failon-1
  :*  run
      :+  ~2012.4.30
          %db1
          %-  zing  :~  "CREATE DATABASE db1;"
                        create-dept
                        insert-dept
                        create-emp
                        insert-emp
                        ==
      ::
      :+  ~2012.5.5
          %db1
          "FROM emp T1 ".
          "JOIN dept T2 ON T1.bad-col = T2.dept-id ".
          "SELECT T1.emp-name"
      ::
      'column %bad-col does not exist'
      ==
::
::  test-fail-predicate-join-01
::  ON predicate has type mismatch (@t = @ud)
++  test-fail-predicate-join-01
  =|  run=@ud
  %-  failon-1
  :*  run
      :+  ~2012.4.30
          %db1
          %-  zing  :~  "CREATE DATABASE db1;"
                        create-dept
                        insert-dept
                        create-emp
                        insert-emp
                        ==
      ::
      :+  ~2012.5.5
          %db1
          "FROM emp T1 ".
          "JOIN dept T2 ON T1.emp-name = T2.dept-id ".
          "SELECT T1.emp-name"
      ::
      'type mismatch in ON predicate'
      ==
::
::  test-fail-predicate-join-02
::  ON predicate references alias not in the join (T3 doesn't exist)
++  test-fail-predicate-join-02
  =|  run=@ud
  %-  failon-1
  :*  run
      :+  ~2012.4.30
          %db1
          %-  zing  :~  "CREATE DATABASE db1;"
                        create-dept
                        insert-dept
                        create-emp
                        insert-emp
                        ==
      ::
      :+  ~2012.5.5
          %db1
          "FROM emp T1 ".
          "JOIN dept T2 ON T1.dept-ref = T3.dept-id ".
          "SELECT T1.emp-name"
      ::
      'is not defined'
      ==
::
::  test-fail-predicate-join-03
::  ambiguous unqualified column in ON (column exists in both tables)
::  emp has emp-id, if dept also had emp-id it would be ambiguous
::  use two tables that share a column name
++  test-fail-predicate-join-03
  =|  run=@ud
  %-  failon-1
  :*  run
      :+  ~2012.4.30
          %db1
          %-  zing  :~  "CREATE DATABASE db1;"
                        "CREATE TABLE tbl-x ".
                        "(shared-col @ud, x-val @t) ".
                        "PRIMARY KEY (shared-col);"
                        "INSERT INTO tbl-x VALUES (1, 'x1');"
                        "CREATE TABLE tbl-y ".
                        "(shared-col @ud, y-val @t) ".
                        "PRIMARY KEY (shared-col);"
                        "INSERT INTO tbl-y VALUES (1, 'y1');"
                        ==
      ::
      :+  ~2012.5.5
          %db1
          "FROM tbl-x T1 ".
          "JOIN tbl-y T2 ON shared-col = T2.shared-col ".
          "SELECT T1.x-val"
      ::
      'column %shared-col is ambiguous in ON predicate'
      ==
::
::  test-fail-predicate-join-04
::  ON predicate contains inequality operator (not supported in equality+AND path)
++  test-fail-predicate-join-04
  =|  run=@ud
  %-  failon-1
  :*  run
      :+  ~2012.4.30
          %db1
          %-  zing  :~  "CREATE DATABASE db1;"
                        create-dept
                        insert-dept
                        create-emp
                        insert-emp
                        ==
      ::
      :+  ~2012.5.5
          %db1
          "FROM emp T1 ".
          "JOIN dept T2 ON T1.dept-ref > T2.dept-id ".
          "SELECT T1.emp-name"
      ::
      'JOIN ON predicate only supports equality and AND conjunctions'
      ==
::
::  test-fail-predicate-join-05
::  ON predicate contains OR conjunction (not supported in equality+AND path)
++  test-fail-predicate-join-05
  =|  run=@ud
  %-  failon-1
  :*  run
      :+  ~2012.4.30
          %db1
          %-  zing  :~  "CREATE DATABASE db1;"
                        create-dept
                        insert-dept
                        create-emp
                        insert-emp
                        ==
      ::
      :+  ~2012.5.5
          %db1
          "FROM emp T1 ".
          "JOIN dept T2 ".
          "ON T1.dept-ref = T2.dept-id OR T1.emp-id = T2.dept-id ".
          "SELECT T1.emp-name"
      ::
      'JOIN ON predicate only supports equality and AND conjunctions'
      ==
::
::  test-fail-predicate-join-06
::  ON predicate contains BETWEEN (not supported in equality+AND path)
++  test-fail-predicate-join-06
  =|  run=@ud
  %-  failon-1
  :*  run
      :+  ~2012.4.30
          %db1
          %-  zing  :~  "CREATE DATABASE db1;"
                        create-dept
                        insert-dept
                        create-emp
                        insert-emp
                        ==
      ::
      :+  ~2012.5.5
          %db1
          "FROM emp T1 ".
          "JOIN dept T2 ON T1.dept-ref BETWEEN 1 AND T2.dept-id ".
          "SELECT T1.emp-name"
      ::
      'JOIN ON predicate only supports equality and AND conjunctions'
      ==
::
::  cte column selection - single cte, literal replicated across main table rows
++  test-cte-col-00
  =|  run=@ud
  %-  exec-0-1
  :*  run
      :+  ~2012.4.30
          %db1
          %-  zing  :~  "CREATE DATABASE db1;"
                        "CREATE TABLE foo (col1 @t, col2 @t) PRIMARY KEY (col1);"
                        "INSERT INTO foo VALUES ('a', 'b');"
                        "CREATE TABLE foo2 (col3 @t, col4 @t) PRIMARY KEY (col3);"
                        "INSERT INTO foo2 VALUES ('c', 'd') ('e', 'f')"
                        ==
      ::
      :+  ~2012.5.1
          %db1
          "WITH (FROM foo select col1, col2) as first ".
          "FROM foo2 ".
          "SELECT col3, col4, first.col1, first.col2 AS my-col2"
      ::
      :-  %results
          :~  [%action 'SELECT']
              :-  %result-set
                  :~  :-  %vector
                          :~  [%col3 [~.t 'c']]
                              [%col4 [~.t 'd']]
                              [%col1 [~.t 'a']]
                              [%my-col2 [~.t 'b']]
                              ==
                      :-  %vector
                          :~  [%col3 [~.t 'e']]
                              [%col4 [~.t 'f']]
                              [%col1 [~.t 'a']]
                              [%my-col2 [~.t 'b']]
                              ==
                      ==
              [%server-time ~2012.5.1]
              [%relation 'db1.dbo.foo']
              [%schema-time ~2012.4.30]
              [%data-time ~2012.4.30]
              [%relation 'db1.dbo.foo2']
              [%schema-time ~2012.4.30]
              [%data-time ~2012.4.30]
              [%vector-count 2]
              ==
      ==
::
::  cte column selection - two ctes, cte-on-cte reference, literal replicated
++  test-cte-col-01
  =|  run=@ud
  %-  exec-0-1
  :*  run
      :+  ~2012.4.30
          %db1
          "CREATE DATABASE db1; ".
          "CREATE TABLE foo (col1 @t, col2 @t) PRIMARY KEY (col1); ".
          "INSERT INTO foo VALUES ('a', 'b'); ".
          "CREATE TABLE foo2 (col3 @t, col4 @t) PRIMARY KEY (col3); ".
          "INSERT INTO foo2 VALUES ('c', 'd'); ".
          "CREATE TABLE foo3 (col5 @t) PRIMARY KEY (col5); ".
          "INSERT INTO foo3 VALUES ('e') ('f')"
      ::
      :+  ~2012.5.1
          %db1
          "with (FROM foo select col1, col2) as first, ".
          "(FROM foo2 ".
          "SELECT col3, col4, first.col1, first.col2 AS my-col2) as second ".
          "FROM foo3 ".
          "SELECT col5, first.col1, first.col2, second.col1, ".
          "       second.my-col2 AS my-col-2"
      ::
      :-  %results
          :~  [%action 'SELECT']
              :-  %result-set
                  :~  :-  %vector
                          :~  [%col5 [~.t 'e']]
                              [%col1 [~.t 'a']]
                              [%col2 [~.t 'b']]
                              [%col1 [~.t 'a']]
                              [%my-col-2 [~.t 'b']]
                              ==
                      :-  %vector
                          :~  [%col5 [~.t 'f']]
                              [%col1 [~.t 'a']]
                              [%col2 [~.t 'b']]
                              [%col1 [~.t 'a']]
                              [%my-col-2 [~.t 'b']]
                              ==
                      ==
              [%server-time ~2012.5.1]
              [%relation 'db1.dbo.foo']
              [%schema-time ~2012.4.30]
              [%data-time ~2012.4.30]
              [%relation 'db1.dbo.foo2']
              [%schema-time ~2012.4.30]
              [%data-time ~2012.4.30]
              [%relation 'db1.dbo.foo3']
              [%schema-time ~2012.4.30]
              [%data-time ~2012.4.30]
              [%vector-count 2]
              ==
      ==
::
::  scalar-only select, no FROM clause
++  test-select-scalar-00
  =|  run=@ud
  %-  exec-0-1
  :*  run
      [~2012.4.30 %sys "CREATE DATABASE db1"]
      ::
      :+  ~2012.5.1
          %db1
          "SCALARS greeting CONCAT('hello',' world') ".
          "        verdict IF 1 = 1 THEN 'yes' ELSE 'no' ENDIF ".
          "        holiday IF 1 = 1 THEN ~2024.12.25 ELSE ~2024.12.26 ENDIF ".
          "        total 20 + 22 END ".
          "SELECT greeting, verdict, holiday, total"
      ::
      :-  %results
          :~  [%action 'SELECT']
              :-  %result-set
                  :~  :-  %vector
                          :~  [%greeting [~.t 'hello world']]
                              [%verdict [~.t 'yes']]
                              [%holiday [~.da ~2024.12.25]]
                              [%total [~.ud 42]]
                              ==
                      ==
              [%server-time ~2012.5.1]
              [%schema-time ~2012.4.30]
              [%data-time ~2012.4.30]
              [%vector-count 1]
              ==
      ==
::
::  single-table scalar select with single-row cte column
++  test-select-scalar-01
  =|  run=@ud
  %-  exec-0-1
  :*  run
      :+  ~2012.4.30
          %db1
          %-  zing  :~
            "CREATE DATABASE db1;"
            "CREATE TABLE pet "
            "(pet-id @ud, pet-name @t, pet-type @t, born @da, points @ud) "
            "PRIMARY KEY (pet-id);"
            "INSERT INTO pet VALUES "
            "(1, 'Mochi', 'cat', ~2020.3.1, 5) "
            "(2, 'Bramble', 'dog', ~2018.7.4, 8);"
            "CREATE TABLE cte-source (cte-note @t) PRIMARY KEY (cte-note);"
            "INSERT INTO cte-source VALUES ('solo');"
            ==
      ::
      :+  ~2012.5.1
          %db1
          "WITH (FROM cte-source SELECT cte-note) AS one-cte ".
          "FROM pet ".
          "SCALARS pet-label CONCAT(pet-name,' friend') ".
          "        picked-text IF pet-id = 1 THEN pet-type ELSE pet-name ENDIF ".
          "        picked-date IF pet-id = 1 THEN born ELSE ~2025.1.1 ENDIF ".
          "        total-points pet-id + points + 10 END ".
          "SELECT pet-id, pet-name, 'single-table' AS scope, one-cte.cte-note, ".
          "       pet-label, picked-text, picked-date, total-points"
      ::
      :-  %results
          :~  [%action 'SELECT']
              :-  %result-set
                  :~  :-  %vector
                          :~  [%pet-id [~.ud 1]]
                              [%pet-name [~.t 'Mochi']]
                              [%scope [~.t 'single-table']]
                              [%cte-note [~.t 'solo']]
                              [%pet-label [~.t 'Mochi friend']]
                              [%picked-text [~.t 'cat']]
                              [%picked-date [~.da ~2020.3.1]]
                              [%total-points [~.ud 16]]
                              ==
                      :-  %vector
                          :~  [%pet-id [~.ud 2]]
                              [%pet-name [~.t 'Bramble']]
                              [%scope [~.t 'single-table']]
                              [%cte-note [~.t 'solo']]
                              [%pet-label [~.t 'Bramble friend']]
                              [%picked-text [~.t 'Bramble']]
                              [%picked-date [~.da ~2025.1.1]]
                              [%total-points [~.ud 20]]
                              ==
                      ==
              [%server-time ~2012.5.1]
              [%relation 'db1.dbo.cte-source']
              [%schema-time ~2012.4.30]
              [%data-time ~2012.4.30]
              [%relation 'db1.dbo.pet']
              [%schema-time ~2012.4.30]
              [%data-time ~2012.4.30]
              [%vector-count 2]
              ==
      ==
::
::  natural join scalar select with single-row cte column
++  test-select-scalar-02
  =|  run=@ud
  %-  exec-0-1
  :*  run
      :+  ~2012.4.30
          %db1
          %-  zing  :~
            "CREATE DATABASE db1;"
            "CREATE TABLE join-left "
            "(id @ud, left-name @t, left-date @da, left-points @ud) "
            "PRIMARY KEY (id);"
            "CREATE TABLE join-right "
            "(id @ud, right-name @t, right-date @da, right-points @ud) "
            "PRIMARY KEY (id);"
            "INSERT INTO join-left VALUES "
            "(1, 'sun', ~2023.12.25, 1) "
            "(2, 'moon', ~2024.1.1, 2);"
            "INSERT INTO join-right VALUES "
            "(1, 'rise', ~2024.1.5, 4) "
            "(2, 'beam', ~2024.1.10, 1);"
            "CREATE TABLE join-cte-src (cte-tag @t) PRIMARY KEY (cte-tag);"
            "INSERT INTO join-cte-src VALUES ('join-cte');"
            ==
      ::
      :+  ~2012.5.1
          %db1
          "WITH (FROM join-cte-src SELECT cte-tag) AS one-cte ".
          "FROM join-left T1 ".
          "JOIN join-right T2 ".
          "SCALARS joined-label CONCAT(T1.left-name,T2.right-name) ".
          "        picked-text IF T1.left-points = 1 OR T2.right-points = 4 ".
          "                    THEN T2.right-name ".
          "                    ELSE T1.left-name ENDIF ".
          "        picked-date IF T1.left-points = 1 OR T2.right-points = 4 ".
          "                    THEN T2.right-date ".
          "                    ELSE T1.left-date ENDIF ".
          "        combined-points T1.left-points + T2.right-points + 10 END ".
          "SELECT T1.id AS join-id, T1.left-name, T2.right-name, ".
          "       'natural-join' AS scope, one-cte.cte-tag, joined-label, ".
          "       picked-text, picked-date, combined-points"
      ::
      :-  %results
          :~  [%action 'SELECT']
              :-  %result-set
                  :~  :-  %vector
                          :~  [%join-id [~.ud 1]]
                              [%left-name [~.t 'sun']]
                              [%right-name [~.t 'rise']]
                              [%scope [~.t 'natural-join']]
                              [%cte-tag [~.t 'join-cte']]
                              [%joined-label [~.t 'sunrise']]
                              [%picked-text [~.t 'rise']]
                              [%picked-date [~.da ~2024.1.5]]
                              [%combined-points [~.ud 15]]
                              ==
                      :-  %vector
                          :~  [%join-id [~.ud 2]]
                              [%left-name [~.t 'moon']]
                              [%right-name [~.t 'beam']]
                              [%scope [~.t 'natural-join']]
                              [%cte-tag [~.t 'join-cte']]
                              [%joined-label [~.t 'moonbeam']]
                              [%picked-text [~.t 'moon']]
                              [%picked-date [~.da ~2024.1.1]]
                              [%combined-points [~.ud 13]]
                              ==
                      ==
              [%server-time ~2012.5.1]
              [%relation 'db1.dbo.join-cte-src']
              [%schema-time ~2012.4.30]
              [%data-time ~2012.4.30]
              [%relation 'db1.dbo.join-left']
              [%schema-time ~2012.4.30]
              [%data-time ~2012.4.30]
              [%relation 'db1.dbo.join-right']
              [%schema-time ~2012.4.30]
              [%data-time ~2012.4.30]
              [%vector-count 2]
              ==
      ==
--
