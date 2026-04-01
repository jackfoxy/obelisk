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
::  fail natural join on incompatible keys
++  test-fail-join-02
  =|  run=@ud
  %-  failon-1
  :*  run
      :+  ~2012.4.30
          %db1
          %-  zing  :~  "CREATE DATABASE db1;"
                        create-tbl1
                        "CREATE TABLE calendar ".
                        "( date        @da, ".
                        "  year        @ud, ".
                        "  month       @ud, ".
                        "  month-name  @t, ".
                        "  day         @ud, ".
                        "  day-name    @t, ".
                        "  day-of-year @ud, ".
                        "  weekday     @ud, ".
                        "  year-week   @ud ) ".
                        "  PRIMARY KEY (date, year, month); "
                        ==
      ::
      :+  ~2012.5.5
          %db1
          "FROM db1..tbl1 ".
          "JOIN calendar ".
          "SELECT year"
      ::
      %-  crip
          "no natural join or foreign key join, columns do not match: ".
          "[%qualified-table ship=~ database=%db1 namespace=%dbo ".
          "name=%calendar alias=~]"
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
++  test-fail-join-03
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
          "WHERE 'January' = bad-col ".
          "SELECT T1.year"
      ::
      'column %bad-col does not exist'
      ==
::
::  fail on bad column name in join WHERE bad column = good column
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
          "WHERE bad-col = T1.month-name ".
          "SELECT T1.year"
      ::
      'column %bad-col does not exist'
      ==
::
::  fail on bad column name in join WHERE good column = bad column
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
          "WHERE T1.month-name = bad-col ".
          "SELECT T1.year"
      ::
      'column %bad-col does not exist'
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
--
