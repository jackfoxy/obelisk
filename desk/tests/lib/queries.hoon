::  Demonstrate unit testing queries on a Gall agent with %obelisk.
::
/-  ast, *obelisk
/+  *test, *sys-views
/=  agent  /app/obelisk
|%
::
::  Build an example bowl manually
++  bowl
  |=  [run=@ud now=@da]
  ^-  bowl:gall
  :*  [~zod ~zod %obelisk `path`(limo `path`/test-agent)]  :: (our src dap sap)
      [~ ~ ~]                                              :: (wex sup sky)
      [run `@uvJ`(shax run) now [~zod %base ud+run]]       :: (act eny now byk)
  ==
::
::  Build a reference state mold
+$  state
  $:  %0
      =server
      ==
--
|%
::
::  * (select all)
++  test-simple-query-01
  =|  run=@ud
  =/  expected-rows
        :~
          :-  %vector
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
  =/  expected  :~  %results
                    [%message 'SELECT']
                    [%result-set expected-rows]
                    [%server-time ~2012.5.3]
                    [%message 'db1.dbo.my-table']
                    [%schema-time ~2012.5.1]
                    [%data-time ~2012.5.2]
                    [%vector-count 3]
                ==
  =^  mov1  agent
    %:  ~(on-poke agent (bowl [run ~2012.4.30]))
        %obelisk-action
        !>([%tape %sys "CREATE DATABASE db1"])
    ==
  =.  run  +(run)
  =^  mov2  agent
    %:  ~(on-poke agent (bowl [run ~2012.5.1]))
        %obelisk-action
        !>  :+  %tape
                %db1
                "CREATE TABLE db1..my-table ".
                "(col1 @t, col2 @da, col3 @t, col4 @t) ".
                "PRIMARY KEY (col1)"
    ==
  =.  run  +(run)
  =^  mov3  agent
    %:  ~(on-poke agent (bowl [run ~2012.5.2]))
        %obelisk-action
        !>  :+  %tape
                %db1
                "INSERT INTO my-table".
                " VALUES".
                " ('Abby', ~1999.2.19, 'tricolor', 'row1')".
                " ('Ace', ~2005.12.19, 'ticolor', 'row2')".
                " ('Angel', ~2001.9.19, 'tuxedo', 'row3')"
    ==
  =.  run  +(run)
  =^  mov4  agent
    %:  ~(on-poke agent (bowl [run ~2012.5.3]))
        %obelisk-action
        !>([%tape %db1 "FROM my-table SELECT *"])
    ==
  %+  expect-eq
    !>  expected
    !>  ;;(cmd-result ->+>+>+<.mov4)
::
::  *, *
++  test-simple-query-02
  =|  run=@ud
  =/  expected-rows
        :~
          :-  %vector
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
  =/  expected  :~  %results
                    [%message 'SELECT']
                    [%result-set expected-rows]
                    [%server-time ~2012.5.3]
                    [%message 'db1.dbo.my-table']
                    [%schema-time ~2012.5.1]
                    [%data-time ~2012.5.2]
                    [%vector-count 3]
                ==
  =^  mov1  agent
    %:  ~(on-poke agent (bowl [run ~2012.4.30]))
        %obelisk-action
        !>([%tape %sys "CREATE DATABASE db1"])
    ==
  =.  run  +(run)
  =^  mov2  agent
    %:  ~(on-poke agent (bowl [run ~2012.5.1]))
        %obelisk-action
        !>  :+  %tape
                %db1
                "CREATE TABLE db1..my-table ".
                "(col1 @t, col2 @da, col3 @t, col4 @t) ".
                "PRIMARY KEY (col1)"
    ==
    =.  run  +(run)
  =^  mov3  agent
    %:  ~(on-poke agent (bowl [run ~2012.5.2]))
        %obelisk-action
        !>  :+  %tape
                %db1
                "INSERT INTO my-table".
                " VALUES".
                " ('Abby', ~1999.2.19, 'tricolor', 'row1')".
                " ('Ace', ~2005.12.19, 'ticolor', 'row2')".
                " ('Angel', ~2001.9.19, 'tuxedo', 'row3')"
    ==
  =.  run  +(run)
  =^  mov4  agent
    %:  ~(on-poke agent (bowl [run ~2012.5.3]))
        %obelisk-action
        !>([%tape %db1 "FROM my-table SELECT *, *"])
    ==
  %+  expect-eq
    !>  expected
    !>  ;;(cmd-result ->+>+>+<.mov4)
::
::  table-name.*
++  test-simple-query-03
  =|  run=@ud
  =/  expected-rows
        :~
          :-  %vector
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
  =/  expected  :~  %results
                    [%message 'SELECT']
                    [%result-set expected-rows]
                    [%server-time ~2012.5.3]
                    [%message 'db1.dbo.my-table']
                    [%schema-time ~2012.5.1]
                    [%data-time ~2012.5.2]
                    [%vector-count 3]
                ==
  =^  mov1  agent
    %:  ~(on-poke agent (bowl [run ~2012.4.30]))
        %obelisk-action
        !>([%tape %sys "CREATE DATABASE db1"])
    ==
  =.  run  +(run)
  =^  mov2  agent
    %:  ~(on-poke agent (bowl [run ~2012.5.1]))
        %obelisk-action
        !>  :+  %tape
                %db1
                "CREATE TABLE db1..my-table ".
                "(col1 @t, col2 @da, col3 @t, col4 @t) ".
                "PRIMARY KEY (col1)"
    ==
    =.  run  +(run)
  =^  mov3  agent
    %:  ~(on-poke agent (bowl [run ~2012.5.2]))
        %obelisk-action
        !>  :+  %tape
                %db1
                "INSERT INTO my-table".
                " VALUES".
                " ('Abby', ~1999.2.19, 'tricolor', 'row1')".
                " ('Ace', ~2005.12.19, 'ticolor', 'row2')".
                " ('Angel', ~2001.9.19, 'tuxedo', 'row3')"
    ==
  =.  run  +(run)
  =^  mov4  agent
    %:  ~(on-poke agent (bowl [run ~2012.5.3]))
        %obelisk-action
        !>([%tape %db1 "FROM my-table SELECT my-table.*"])
    ==
  %+  expect-eq
    !>  expected
    !>  ;;(cmd-result ->+>+>+<.mov4)
::
::  table-alias.*
++  test-simple-query-04
  =|  run=@ud
  =/  expected-rows
        :~
          :-  %vector
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
  =/  expected  :~  %results
                    [%message 'SELECT']
                    [%result-set expected-rows]
                    [%server-time ~2012.5.3]
                    [%message 'db1.dbo.my-table']
                    [%schema-time ~2012.5.1]
                    [%data-time ~2012.5.2]
                    [%vector-count 3]
                ==
  =^  mov1  agent
    %:  ~(on-poke agent (bowl [run ~2012.4.30]))
        %obelisk-action
        !>([%tape %sys "CREATE DATABASE db1"])
    ==
  =.  run  +(run)
  =^  mov2  agent
    %:  ~(on-poke agent (bowl [run ~2012.5.1]))
        %obelisk-action
        !>  :+  %tape
                %db1
                "CREATE TABLE db1..my-table ".
                "(col1 @t, col2 @da, col3 @t, col4 @t) ".
                "PRIMARY KEY (col1)"
    ==
    =.  run  +(run)
  =^  mov3  agent
    %:  ~(on-poke agent (bowl [run ~2012.5.2]))
        %obelisk-action
        !>  :+  %tape
                %db1
                "INSERT INTO my-table".
                " VALUES".
                " ('Abby', ~1999.2.19, 'tricolor', 'row1')".
                " ('Ace', ~2005.12.19, 'ticolor', 'row2')".
                " ('Angel', ~2001.9.19, 'tuxedo', 'row3')"
    ==
  =.  run  +(run)
  =^  mov4  agent
    %:  ~(on-poke agent (bowl [run ~2012.5.3]))
        %obelisk-action
        !>([%tape %db1 "FROM my-table T1 SELECT T1.*"])
    ==
  %+  expect-eq
    !>  expected
    !>  ;;(cmd-result ->+>+>+<.mov4)
::
::  *, *
++  test-simple-query-05
  =|  run=@ud
  =/  expected-rows
        :~
          :-  %vector
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
  =/  expected  :~  %results
                    [%message 'SELECT']
                    [%result-set expected-rows]
                    [%server-time ~2012.5.3]
                    [%message 'db1.dbo.my-table']
                    [%schema-time ~2012.5.1]
                    [%data-time ~2012.5.2]
                    [%vector-count 3]
                ==
  =^  mov1  agent
    %:  ~(on-poke agent (bowl [run ~2012.4.30]))
        %obelisk-action
        !>([%tape %sys "CREATE DATABASE db1"])
    ==
  =.  run  +(run)
  =^  mov2  agent
    %:  ~(on-poke agent (bowl [run ~2012.5.1]))
        %obelisk-action
        !>  :+  %tape
                %db1
                "CREATE TABLE db1..my-table ".
                "(col1 @t, col2 @da, col3 @t, col4 @t) ".
                "PRIMARY KEY (col1)"
    ==
    =.  run  +(run)
  =^  mov3  agent
    %:  ~(on-poke agent (bowl [run ~2012.5.2]))
        %obelisk-action
        !>  :+  %tape
                %db1
                "INSERT INTO my-table".
                " VALUES".
                " ('Abby', ~1999.2.19, 'tricolor', 'row1')".
                " ('Ace', ~2005.12.19, 'ticolor', 'row2')".
                " ('Angel', ~2001.9.19, 'tuxedo', 'row3')"
    ==
  =.  run  +(run)
  ::=^  mov4  agent
  ::  %:  ~(on-poke agent (bowl [run ~2012.5.3]))
  ::      %obelisk-action
  ::      !>([%tape %db1 "FROM my-table SELECT col1,col2,col3,col4"])
  ::  ==
  ::%+  expect-eq
  ::  !>  expected
  ::  !>  ;;(cmd-result ->+>+>+<.mov4)


  ::
  %+  expect-fail-message
        'table %db1.%dbo.%my-table does not exist at schema time ~2012.4.30'
  |.  %:  ~(on-poke agent (bowl [run ~2012.5.3]))
          %obelisk-action
          !>([%test %db1 "FROM my-table SELECT col1,col2,col3,col4"])
      ==


::
::  all column aliases
++  test-simple-query-06
  =|  run=@ud
  =/  expected-rows
        :~
          :-  %vector
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
  =/  expected  :~  %results
                    [%message 'SELECT']
                    [%result-set expected-rows]
                    [%server-time ~2012.5.3]
                    [%message 'db1.dbo.my-table']
                    [%schema-time ~2012.5.1]
                    [%data-time ~2012.5.2]
                    [%vector-count 3]
                ==
  =^  mov1  agent
    %:  ~(on-poke agent (bowl [run ~2012.4.30]))
        %obelisk-action
        !>([%tape %sys "CREATE DATABASE db1"])
    ==
  =.  run  +(run)
  =^  mov2  agent
    %:  ~(on-poke agent (bowl [run ~2012.5.1]))
        %obelisk-action
        !>  :+  %tape
                %db1
                "CREATE TABLE db1..my-table ".
                "(col1 @t, col2 @da, col3 @t, col4 @t) ".
                "PRIMARY KEY (col1)"
    ==
    =.  run  +(run)
  =^  mov3  agent
    %:  ~(on-poke agent (bowl [run ~2012.5.2]))
        %obelisk-action
        !>  :+  %tape
                %db1
                "INSERT INTO my-table".
                " VALUES".
                " ('Abby', ~1999.2.19, 'tricolor', 'row1')".
                " ('Ace', ~2005.12.19, 'ticolor', 'row2')".
                " ('Angel', ~2001.9.19, 'tuxedo', 'row3')"
    ==
  =.  run  +(run)
  =^  mov4  agent
    %:  ~(on-poke agent (bowl [run ~2012.5.3]))
        %obelisk-action
        !>  :+  %tape
              %db1
              "FROM my-table SELECT col1 as c1,col2 as c2,col3 as c3,col4 as c4"
    ==
  %+  expect-eq
    !>  expected
    !>  ;;(cmd-result ->+>+>+<.mov4)
::
::  all literals
++  test-simple-query-07
  =|  run=@ud
  =/  expected-rows
        :~
          :-  %vector
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
  =/  expected  :~  %results
                    [%message 'SELECT']
                    [%result-set expected-rows]
                    [%server-time ~2012.5.3]
                    [%schema-time ~2012.4.30]
                    [%data-time ~2012.4.30]
                    [%vector-count 1]
                ==

  =/  select  "SELECT 'cor,d', ~nomryg-nilref, ~2020.12.25..7.15.0..1ef5, ".
              "2020.12.25..7.15.0..1ef5, ~d71.h19.m26.s24..9d55, ".
              ".195.198.143.90, .0.0.0.0.0.1c.c3c6.8f5a, Y, N, 2.222, 2222, ".
              "195.198.143.900, .3.14, .-3.14, ~3.14, ~-3.14, 0x12.6401, ".
              "10.1011, -20, --20, 'cor\\'d'"
  =^  mov1  agent
    %:  ~(on-poke agent (bowl [run ~2012.4.30]))
        %obelisk-action
        !>([%tape %sys "CREATE DATABASE db1"])
    ==
  =.  run  +(run)
  =^  mov4  agent
    %:  ~(on-poke agent (bowl [run ~2012.5.3]))
        %obelisk-action
        !>([%tape %sys select])
    ==
  %+  expect-eq
    !>  expected
    !>  ;;(cmd-result ->+>+>+<.mov4)
::
::  all literals, aliased
++  test-simple-query-08
  =|  run=@ud
  =/  expected-rows
        :~
          :-  %vector
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
  =/  expected  :~  %results
                    [%message 'SELECT']
                    [%result-set expected-rows]
                    [%server-time ~2012.5.3]
                    [%schema-time ~2012.4.30]
                    [%data-time ~2012.4.30]
                    [%vector-count 1]
                ==
  =/  select  "SELECT 'cor,d' as cord1, ~nomryg-nilref AS Ship, ".
              "~2020.12.25..7.15.0..1ef5 as date1, ".
              "2020.12.25..7.15.0..1ef5 as date2, ".
              "~d71.h19.m26.s24..9d55 as timespan, .195.198.143.90 as ip, ".
              ".0.0.0.0.0.1c.c3c6.8f5a as ipfv6, Y as true, N as false, ".
              "2.222 as undec1, 2222 as undec2, 195.198.143.900 as undec3, ".
              ".3.14 as float32-1, .-3.14 as float32-2, ~3.14 as float64-1, ".
              "~-3.14 as float64-2, 0x12.6401 AS UNHEX, 10.1011 as unbinary, ".
              "-20 as signdec1, --20 as signdec2, 'cor\\'d' AS CORD2"
  =^  mov1  agent
    %:  ~(on-poke agent (bowl [run ~2012.4.30]))
        %obelisk-action
        !>([%tape %sys "CREATE DATABASE db1"])
    ==
  =.  run  +(run)
  =^  mov4  agent
    %:  ~(on-poke agent (bowl [run ~2012.5.3]))
        %obelisk-action
        !>([%tape %sys select])
    ==
  %+  expect-eq
    !>  expected
    !>  ;;(cmd-result ->+>+>+<.mov4)
::
::  interspersed literals, aliased and unaliased
++  test-simple-query-09
  =|  run=@ud
  =/  expected-rows
        :~
          :-  %vector
              :~  [%cord [~.t 430.158.540.643]]
                  [%col1 [~.t 'Ace']]
                  [%literal-2 [~.p ~nomryg-nilref]]
                  [%col2 [~.da ~2005.12.19]]
                  [%pi [~.rs 3.226.006.979]]
                  [%col3 [~.t 'ticolor']]
                  [%col4 [~.t 'row2']]
                  [%literal-7 [~.da ~2023.12.25]]
                  ==
          :-  %vector
              :~  [%cord [~.t 430.158.540.643]]
                  [%col1 [~.t 'Angel']]
                  [%literal-2 [~.p ~nomryg-nilref]]
                  [%col2 [~.da ~2001.9.19]]
                  [%pi [~.rs 3.226.006.979]]
                  [%col3 [~.t 'tuxedo']]
                  [%col4 [~.t 'row3']]
                  [%literal-7 [~.da ~2023.12.25]]
                  ==
          :-  %vector
              :~  [%cord [~.t 430.158.540.643]]

                  [%col1 [~.t 'Abby']]

                  [%literal-2 [~.p ~nomryg-nilref]]

                  [%col2 [~.da ~1999.2.19]]

                  [%pi [~.rs 3.226.006.979]]

                  [%col3 [~.t 'tricolor']]
                  [%col4 [~.t 'row1']]

                  [%literal-7 [~.da ~2023.12.25]]
                  ==
              ==
  =/  expected  :~  %results
                    [%message 'SELECT']
                    [%result-set expected-rows]
                    [%server-time ~2012.5.3]
                    [%message 'db1.dbo.my-table']
                    [%schema-time ~2012.5.1]
                    [%data-time ~2012.5.2]
                    [%vector-count 3]
                ==
  =^  mov1  agent
    %:  ~(on-poke agent (bowl [run ~2012.4.30]))
        %obelisk-action
        !>([%tape %sys "CREATE DATABASE db1"])
    ==
  =.  run  +(run)
  =^  mov2  agent
    %:  ~(on-poke agent (bowl [run ~2012.5.1]))
        %obelisk-action
        !>  :+  %tape
                %db1
                "CREATE TABLE db1..my-table ".
                "(col1 @t, col2 @da, col3 @t, col4 @t) ".
                "PRIMARY KEY (col1)"
    ==
    =.  run  +(run)
  =^  mov3  agent
    %:  ~(on-poke agent (bowl [run ~2012.5.2]))
        %obelisk-action
        !>  :+  %tape
                %db1
                "INSERT INTO my-table".
                " VALUES".
                " ('Abby', ~1999.2.19, 'tricolor', 'row1')".
                " ('Ace', ~2005.12.19, 'ticolor', 'row2')".
                " ('Angel', ~2001.9.19, 'tuxedo', 'row3')"
    ==
  =.  run  +(run)
  =^  mov4  agent
    %:  ~(on-poke agent (bowl [run ~2012.5.3]))
        %obelisk-action
        !>  :+  %tape
              %db1
              "FROM my-table T1 ".
              "SELECT 'cor\\'d' AS cord, col1 as C1, ~nomryg-nilref, col2, ".
                     ".-3.14 as pi, col3, col4, ~2023.12.25"
    ==
  %+  expect-eq
    !>  expected
    !>  ;;(cmd-result ->+>+>+<.mov4)
::
::  all column names, reversed
++  test-simple-query-10
  =|  run=@ud
  =/  expected-rows
        :~
          :-  %vector
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
  =/  expected  :~  %results
                    [%message 'SELECT']
                    [%result-set expected-rows]
                    [%server-time ~2012.5.3]
                    [%message 'db1.dbo.my-table']
                    [%schema-time ~2012.5.1]
                    [%data-time ~2012.5.2]
                    [%vector-count 3]
                ==
  =^  mov1  agent
    %:  ~(on-poke agent (bowl [run ~2012.4.30]))
        %obelisk-action
        !>([%tape %sys "CREATE DATABASE db1"])
    ==
  =.  run  +(run)
  =^  mov2  agent
    %:  ~(on-poke agent (bowl [run ~2012.5.1]))
        %obelisk-action
        !>  :+  %tape
                %db1
                "CREATE TABLE db1..my-table ".
                "(col1 @t, col2 @da, col3 @t, col4 @t) ".
                "PRIMARY KEY (col1)"
    ==
    =.  run  +(run)
  =^  mov3  agent
    %:  ~(on-poke agent (bowl [run ~2012.5.2]))
        %obelisk-action
        !>  :+  %tape
                %db1
                "INSERT INTO my-table".
                " VALUES".
                " ('Abby', ~1999.2.19, 'tricolor', 'row1')".
                " ('Ace', ~2005.12.19, 'ticolor', 'row2')".
                " ('Angel', ~2001.9.19, 'tuxedo', 'row3')"
    ==
  =.  run  +(run)
  =^  mov4  agent
    %:  ~(on-poke agent (bowl [run ~2012.5.3]))
        %obelisk-action
        !>([%tape %db1 "FROM my-table SELECT col4,col3,col2,col1"])
    ==
  %+  expect-eq
    !>  expected
    !>  ;;(cmd-result ->+>+>+<.mov4)
::
::  all column aliases (mixed case), reversed
++  test-simple-query-11
  =|  run=@ud
  =/  expected-rows
        :~
          :-  %vector
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
  =/  expected  :~  %results
                    [%message 'SELECT']
                    [%result-set expected-rows]
                    [%server-time ~2012.5.3]
                    [%message 'db1.dbo.my-table']
                    [%schema-time ~2012.5.1]
                    [%data-time ~2012.5.2]
                    [%vector-count 3]
                ==
  =^  mov1  agent
    %:  ~(on-poke agent (bowl [run ~2012.4.30]))
        %obelisk-action
        !>([%tape %sys "CREATE DATABASE db1"])
    ==
  =.  run  +(run)
  =^  mov2  agent
    %:  ~(on-poke agent (bowl [run ~2012.5.1]))
        %obelisk-action
        !>  :+  %tape
                %db1
                "CREATE TABLE db1..my-table ".
                "(col1 @t, col2 @da, col3 @t, col4 @t) ".
                "PRIMARY KEY (col1)"
    ==
    =.  run  +(run)
  =^  mov3  agent
    %:  ~(on-poke agent (bowl [run ~2012.5.2]))
        %obelisk-action
        !>  :+  %tape
                %db1
                "INSERT INTO my-table".
                " VALUES".
                " ('Abby', ~1999.2.19, 'tricolor', 'row1')".
                " ('Ace', ~2005.12.19, 'ticolor', 'row2')".
                " ('Angel', ~2001.9.19, 'tuxedo', 'row3')"
    ==
  =.  run  +(run)
  =^  mov4  agent
    %:  ~(on-poke agent (bowl [run ~2012.5.3]))
        %obelisk-action
        !>  :+  %tape
              %db1
              "FROM my-table SELECT col4 as c4,col3 as C3,col2 as c2,col1 as c1"
    ==
  %+  expect-eq
    !>  expected
    !>  ;;(cmd-result ->+>+>+<.mov4)
::
::  all column names, with table prefix
++  test-simple-query-12
  =|  run=@ud
  =/  expected-rows
        :~
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
          :-  %vector
              :~  [%col1 [~.t 'Ace']]
                  [%col2 [~.da ~2005.12.19]]
                  [%col3 [~.t 'ticolor']]
                  [%col4 [~.t 'row2']]
                  ==
              ==
  =/  expected  :~  %results
                    [%message 'SELECT']
                    [%result-set expected-rows]
                    [%server-time ~2012.5.3]
                    [%message 'db1.dbo.my-table']
                    [%schema-time ~2012.5.1]
                    [%data-time ~2012.5.2]
                    [%vector-count 3]
                ==
  =^  mov1  agent
    %:  ~(on-poke agent (bowl [run ~2012.4.30]))
        %obelisk-action
        !>([%tape %sys "CREATE DATABASE db1"])
    ==
  =.  run  +(run)
  =^  mov2  agent
    %:  ~(on-poke agent (bowl [run ~2012.5.1]))
        %obelisk-action
        !>  :+  %tape
                %db1
                "CREATE TABLE db1..my-table ".
                "(col1 @t, col2 @da, col3 @t, col4 @t) ".
                "PRIMARY KEY (col1)"
    ==
    =.  run  +(run)
  =^  mov3  agent
    %:  ~(on-poke agent (bowl [run ~2012.5.2]))
        %obelisk-action
        !>  :+  %tape
                %db1
                "INSERT INTO my-table".
                " VALUES".
                " ('Abby', ~1999.2.19, 'tricolor', 'row1')".
                " ('Ace', ~2005.12.19, 'ticolor', 'row2')".
                " ('Angel', ~2001.9.19, 'tuxedo', 'row3')"
    ==
  =.  run  +(run)
  =^  mov4  agent
    %:  ~(on-poke agent (bowl [run ~2012.5.3]))
        %obelisk-action
        !>  :+  %tape
              %db1
              "FROM my-table ".
              "SELECT my-table.col1,my-table.col2,my-table.col3,my-table.col4"
    ==
  %+  expect-eq
    !>  expected
    !>  ;;(cmd-result ->+>+>+<.mov4)
::
::  all column names, with table alias
++  test-simple-query-13
  =|  run=@ud
  =/  expected-rows
        :~
          :-  %vector
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
  =/  expected  :~  %results
                    [%message 'SELECT']
                    [%result-set expected-rows]
                    [%server-time ~2012.5.3]
                    [%message 'db1.dbo.my-table']
                    [%schema-time ~2012.5.1]
                    [%data-time ~2012.5.2]
                    [%vector-count 3]
                ==
  =^  mov1  agent
    %:  ~(on-poke agent (bowl [run ~2012.4.30]))
        %obelisk-action
        !>([%tape %sys "CREATE DATABASE db1"])
    ==
  =.  run  +(run)
  =^  mov2  agent
    %:  ~(on-poke agent (bowl [run ~2012.5.1]))
        %obelisk-action
        !>  :+  %tape
                %db1
                "CREATE TABLE db1..my-table ".
                "(col1 @t, col2 @da, col3 @t, col4 @t) ".
                "PRIMARY KEY (col1)"
    ==
    =.  run  +(run)
  =^  mov3  agent
    %:  ~(on-poke agent (bowl [run ~2012.5.2]))
        %obelisk-action
        !>  :+  %tape
                %db1
                "INSERT INTO my-table".
                " VALUES".
                " ('Abby', ~1999.2.19, 'tricolor', 'row1')".
                " ('Ace', ~2005.12.19, 'ticolor', 'row2')".
                " ('Angel', ~2001.9.19, 'tuxedo', 'row3')"
    ==
  =.  run  +(run)
  =^  mov4  agent
    %:  ~(on-poke agent (bowl [run ~2012.5.3]))
        %obelisk-action
        !>  :+  %tape
              %db1
              "FROM my-table T1 SELECT T1.col1,T1.col2,T1.col3,T1.col4"
    ==
  %+  expect-eq
    !>  expected
    !>  ;;(cmd-result ->+>+>+<.mov4)
::
::  all column names, with table prefix, reversed
++  test-simple-query-14
  =|  run=@ud
  =/  expected-rows
        :~
          :-  %vector
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
  =/  expected  :~  %results
                    [%message 'SELECT']
                    [%result-set expected-rows]
                    [%server-time ~2012.5.3]
                    [%message 'db1.dbo.my-table']
                    [%schema-time ~2012.5.1]
                    [%data-time ~2012.5.2]
                    [%vector-count 3]
                ==
  =^  mov1  agent
    %:  ~(on-poke agent (bowl [run ~2012.4.30]))
        %obelisk-action
        !>([%tape %sys "CREATE DATABASE db1"])
    ==
  =.  run  +(run)
  =^  mov2  agent
    %:  ~(on-poke agent (bowl [run ~2012.5.1]))
        %obelisk-action
        !>  :+  %tape
                %db1
                "CREATE TABLE db1..my-table ".
                "(col1 @t, col2 @da, col3 @t, col4 @t) ".
                "PRIMARY KEY (col1)"
    ==
    =.  run  +(run)
  =^  mov3  agent
    %:  ~(on-poke agent (bowl [run ~2012.5.2]))
        %obelisk-action
        !>  :+  %tape
                %db1
                "INSERT INTO my-table".
                " VALUES".
                " ('Abby', ~1999.2.19, 'tricolor', 'row1')".
                " ('Ace', ~2005.12.19, 'ticolor', 'row2')".
                " ('Angel', ~2001.9.19, 'tuxedo', 'row3')"
    ==
  =.  run  +(run)
  =^  mov4  agent
    %:  ~(on-poke agent (bowl [run ~2012.5.3]))
        %obelisk-action
        !>  :+  %tape
              %db1
              "FROM my-table ".
              "SELECT my-table.col4,my-table.col3,my-table.col2,my-table.col1"
    ==
  %+  expect-eq
    !>  expected
    !>  ;;(cmd-result ->+>+>+<.mov4)
::
::  all column names, with table alias, reversed
++  test-simple-query-15
  =|  run=@ud
  =/  expected-rows
        :~
          :-  %vector
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
  =/  expected  :~  %results
                    [%message 'SELECT']
                    [%result-set expected-rows]
                    [%server-time ~2012.5.3]
                    [%message 'db1.dbo.my-table']
                    [%schema-time ~2012.5.1]
                    [%data-time ~2012.5.2]
                    [%vector-count 3]
                ==
  =^  mov1  agent
    %:  ~(on-poke agent (bowl [run ~2012.4.30]))
        %obelisk-action
        !>([%tape %sys "CREATE DATABASE db1"])
    ==
  =.  run  +(run)
  =^  mov2  agent
    %:  ~(on-poke agent (bowl [run ~2012.5.1]))
        %obelisk-action
        !>  :+  %tape
                %db1
                "CREATE TABLE db1..my-table ".
                "(col1 @t, col2 @da, col3 @t, col4 @t) ".
                "PRIMARY KEY (col1)"
    ==
    =.  run  +(run)
  =^  mov3  agent
    %:  ~(on-poke agent (bowl [run ~2012.5.2]))
        %obelisk-action
        !>  :+  %tape
                %db1
                "INSERT INTO my-table".
                " VALUES".
                " ('Abby', ~1999.2.19, 'tricolor', 'row1')".
                " ('Ace', ~2005.12.19, 'ticolor', 'row2')".
                " ('Angel', ~2001.9.19, 'tuxedo', 'row3')"
    ==
  =.  run  +(run)
  =^  mov4  agent
    %:  ~(on-poke agent (bowl [run ~2012.5.3]))
        %obelisk-action
        !>  :+  %tape
              %db1
              "FROM my-table T1 SELECT T1.col4,T1.col3,T1.col2,T1.col1"
    ==
  %+  expect-eq
    !>  expected
    !>  ;;(cmd-result ->+>+>+<.mov4)
::
::  one column name, *
++  test-simple-query-16
  =|  run=@ud
  =/  expected-rows
        :~
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
          :-  %vector
              :~  [%col3 [~.t 'tuxedo']]
                  [%col1 [~.t 'Angel']]
                  [%col2 [~.da ~2001.9.19]]
                  [%col3 [~.t 'tuxedo']]
                  [%col4 [~.t 'row3']]
                  ==
              ==
  =/  expected  :~  %results
                    [%message 'SELECT']
                    [%result-set expected-rows]
                    [%server-time ~2012.5.3]
                    [%message 'db1.dbo.my-table']
                    [%schema-time ~2012.5.1]
                    [%data-time ~2012.5.2]
                    [%vector-count 3]
                ==
  =^  mov1  agent
    %:  ~(on-poke agent (bowl [run ~2012.4.30]))
        %obelisk-action
        !>([%tape %sys "CREATE DATABASE db1"])
    ==
  =.  run  +(run)
  =^  mov2  agent
    %:  ~(on-poke agent (bowl [run ~2012.5.1]))
        %obelisk-action
        !>  :+  %tape
                %db1
                "CREATE TABLE db1..my-table ".
                "(col1 @t, col2 @da, col3 @t, col4 @t) ".
                "PRIMARY KEY (col1)"
    ==
    =.  run  +(run)
  =^  mov3  agent
    %:  ~(on-poke agent (bowl [run ~2012.5.2]))
        %obelisk-action
        !>  :+  %tape
                %db1
                "INSERT INTO my-table".
                " VALUES".
                " ('Abby', ~1999.2.19, 'tricolor', 'row1')".
                " ('Ace', ~2005.12.19, 'ticolor', 'row2')".
                " ('Angel', ~2001.9.19, 'tuxedo', 'row3')"
    ==
  =.  run  +(run)
  =^  mov4  agent
    %:  ~(on-poke agent (bowl [run ~2012.5.3]))
        %obelisk-action
        !>([%tape %db1 "FROM my-table SELECT col3,*"])
    ==
  %+  expect-eq
    !>  expected
    !>  ;;(cmd-result ->+>+>+<.mov4)
::
::  one column name, table-name.*
++  test-simple-query-17
  =|  run=@ud
  =/  expected-rows
        :~
          :-  %vector
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
  =/  expected  :~  %results
                    [%message 'SELECT']
                    [%result-set expected-rows]
                    [%server-time ~2012.5.3]
                    [%message 'db1.dbo.my-table']
                    [%schema-time ~2012.5.1]
                    [%data-time ~2012.5.2]
                    [%vector-count 3]
                ==
  =^  mov1  agent
    %:  ~(on-poke agent (bowl [run ~2012.4.30]))
        %obelisk-action
        !>([%tape %sys "CREATE DATABASE db1"])
    ==
  =.  run  +(run)
  =^  mov2  agent
    %:  ~(on-poke agent (bowl [run ~2012.5.1]))
        %obelisk-action
        !>  :+  %tape
                %db1
                "CREATE TABLE db1..my-table ".
                "(col1 @t, col2 @da, col3 @t, col4 @t) ".
                "PRIMARY KEY (col1)"
    ==
    =.  run  +(run)
  =^  mov3  agent
    %:  ~(on-poke agent (bowl [run ~2012.5.2]))
        %obelisk-action
        !>  :+  %tape
                %db1
                "INSERT INTO my-table".
                " VALUES".
                " ('Abby', ~1999.2.19, 'tricolor', 'row1')".
                " ('Ace', ~2005.12.19, 'ticolor', 'row2')".
                " ('Angel', ~2001.9.19, 'tuxedo', 'row3')"
    ==
  =.  run  +(run)
  =^  mov4  agent
    %:  ~(on-poke agent (bowl [run ~2012.5.3]))
        %obelisk-action
        !>([%tape %db1 "FROM my-table SELECT col3,my-table.*"])
    ==
  %+  expect-eq
    !>  expected
    !>  ;;(cmd-result ->+>+>+<.mov4)
::
::  one column name, table-alias.*
++  test-simple-query-18
  =|  run=@ud
  =/  expected-rows
        :~
          :-  %vector
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
  =/  expected  :~  %results
                    [%message 'SELECT']
                    [%result-set expected-rows]
                    [%server-time ~2012.5.3]
                    [%message 'db1.dbo.my-table']
                    [%schema-time ~2012.5.1]
                    [%data-time ~2012.5.2]
                    [%vector-count 3]
                ==
  =^  mov1  agent
    %:  ~(on-poke agent (bowl [run ~2012.4.30]))
        %obelisk-action
        !>([%tape %sys "CREATE DATABASE db1"])
    ==
  =.  run  +(run)
  =^  mov2  agent
    %:  ~(on-poke agent (bowl [run ~2012.5.1]))
        %obelisk-action
        !>  :+  %tape
                %db1
                "CREATE TABLE db1..my-table ".
                "(col1 @t, col2 @da, col3 @t, col4 @t) ".
                "PRIMARY KEY (col1)"
    ==
    =.  run  +(run)
  =^  mov3  agent
    %:  ~(on-poke agent (bowl [run ~2012.5.2]))
        %obelisk-action
        !>  :+  %tape
                %db1
                "INSERT INTO my-table".
                " VALUES".
                " ('Abby', ~1999.2.19, 'tricolor', 'row1')".
                " ('Ace', ~2005.12.19, 'ticolor', 'row2')".
                " ('Angel', ~2001.9.19, 'tuxedo', 'row3')"
    ==
  =.  run  +(run)
  =^  mov4  agent
    %:  ~(on-poke agent (bowl [run ~2012.5.3]))
        %obelisk-action
        !>([%tape %db1 "FROM my-table T1 SELECT col2, T1.*"])
    ==
  %+  expect-eq
    !>  expected
    !>  ;;(cmd-result ->+>+>+<.mov4)
::
::  *, two column names, table-name.*, one column alias
++  test-simple-query-19
  =|  run=@ud
  =/  expected-rows
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

                  [%col1 [~.t 'Ace']]
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

                  [%col1 [~.t 'Angel']]
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

                  [%col1 [~.t 'Abby']]
                  ==
              ==
  =/  expected  :~  %results
                    [%message 'SELECT']
                    [%result-set expected-rows]
                    [%server-time ~2012.5.3]
                    [%message 'db1.dbo.my-table']
                    [%schema-time ~2012.5.1]
                    [%data-time ~2012.5.2]
                    [%vector-count 3]
                ==
  =^  mov1  agent
    %:  ~(on-poke agent (bowl [run ~2012.4.30]))
        %obelisk-action
        !>([%tape %sys "CREATE DATABASE db1"])
    ==
  =.  run  +(run)
  =^  mov2  agent
    %:  ~(on-poke agent (bowl [run ~2012.5.1]))
        %obelisk-action
        !>  :+  %tape
                %db1
                "CREATE TABLE db1..my-table ".
                "(col1 @t, col2 @da, col3 @t, col4 @t) ".
                "PRIMARY KEY (col1)"
    ==
    =.  run  +(run)
  =^  mov3  agent
    %:  ~(on-poke agent (bowl [run ~2012.5.2]))
        %obelisk-action
        !>  :+  %tape
                %db1
                "INSERT INTO my-table".
                " VALUES".
                " ('Abby', ~1999.2.19, 'tricolor', 'row1')".
                " ('Ace', ~2005.12.19, 'ticolor', 'row2')".
                " ('Angel', ~2001.9.19, 'tuxedo', 'row3')"
    ==
  =.  run  +(run)
  =^  mov4  agent
    %:  ~(on-poke agent (bowl [run ~2012.5.3]))
        %obelisk-action
        !>  :+  %tape
              %db1
              "FROM my-table T1 SELECT *, col2,col4, my-table.*, col1 as C1"
    ==
  %+  expect-eq
    !>  expected
    !>  ;;(cmd-result ->+>+>+<.mov4)
::
::  one column alias, table-alias.*, two column names, *
++  test-simple-query-20
  =|  run=@ud
  =/  expected-rows
        :~
          :-  %vector
              :~  [%col1 [~.t 'Ace']]

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
              :~  [%col1 [~.t 'Abby']]

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
              :~  [%col1 [~.t 'Angel']]

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
  =/  expected  :~  %results
                    [%message 'SELECT']
                    [%result-set expected-rows]
                    [%server-time ~2012.5.3]
                    [%message 'db1.dbo.my-table']
                    [%schema-time ~2012.5.1]
                    [%data-time ~2012.5.2]
                    [%vector-count 3]
                ==
  =^  mov1  agent
    %:  ~(on-poke agent (bowl [run ~2012.4.30]))
        %obelisk-action
        !>([%tape %sys "CREATE DATABASE db1"])
    ==
  =.  run  +(run)
  =^  mov2  agent
    %:  ~(on-poke agent (bowl [run ~2012.5.1]))
        %obelisk-action
        !>  :+  %tape
                %db1
                "CREATE TABLE db1..my-table ".
                "(col1 @t, col2 @da, col3 @t, col4 @t) ".
                "PRIMARY KEY (col1)"
    ==
  =.  run  +(run)
  =^  mov3  agent
    %:  ~(on-poke agent (bowl [run ~2012.5.2]))
        %obelisk-action
        !>  :+  %tape
                %db1
                "INSERT INTO my-table".
                " VALUES".
                " ('Abby', ~1999.2.19, 'tricolor', 'row1')".
                " ('Ace', ~2005.12.19, 'ticolor', 'row2')".
                " ('Angel', ~2001.9.19, 'tuxedo', 'row3')"
    ==
  =.  run  +(run)
  =^  mov4  agent
    %:  ~(on-poke agent (bowl [run ~2012.5.3]))
        %obelisk-action
        !>  :+  %tape
              %db1
              "FROM my-table T1 SELECT col1 as C1, T1.*, col2,col4, *"
    ==
  %+  expect-eq
    !>  expected
    !>  ;;(cmd-result ->+>+>+<.mov4)
::
::  select all literals mixed with aliases
++  test-simple-query-21
  =|  run=@ud
  =/  expected-rows  :~  :-  %vector
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
  =/  expected  :~  %results
                    [%message 'SELECT']
                    [%result-set expected-rows]
                    [%server-time ~2012.5.3]
                    [%schema-time ~2012.4.30]
                    [%data-time ~2012.4.30]
                    [%vector-count 1]
                ==
  =/  my-select  "SELECT ~2020.12.25 AS Date, ~2020.12.25..7.15.0, ".
  "~2020.12.25..7.15.0..1ef5, 2020.12.25, 2020.12.25..7.15.0, ".
  "2020.12.25..7.15.0..1ef5, ~d71.h19.m26.s24..9d55 AS Timespan, ".
  "~d71.h19.m26.s24, ~d71.h19.m26, ~d71.h19, ~d71, Y AS Loobean, N,  ".
  ".195.198.143.90 AS IPv4-address, .0.0.0.0.0.1c.c3c6.8f5a as IPv6-address, ".
  "~sampel-palnet AS Ship, .3.14 AS Single-float, .-3.14,  ".
  "~3.14 AS Double-float, ~-3.14, --0b10.0000 AS Signed-binary, -0b10.0000, ".
  "--20 AS Signed-decimal, -20, --0v201.4gvml.245kc AS Signed-base32, ".
  "-0v201.4gvml.245kc, --0w2.04AfS.G8xqc AS Signed-base64, -0w2.04AfS.G8xqc, ".
  "--0x2004.90fd AS Signed-hexadecimal, -0x2004.90fd,  ".
  "10.1011 AS Unsigned-binary, 2.222 AS Unsigned-decimal, 2222,  ".
  "0x12.6401 AS Unsigned-hexadecimal"
  ::
  =^  mov1  agent
    %:  ~(on-poke agent (bowl [run ~2012.4.30]))
        %obelisk-action
        !>([%tape %sys "CREATE DATABASE db1"])
    ==
  =.  run  +(run)
  =^  mov2  agent
    %:  ~(on-poke agent (bowl [run ~2012.5.1]))
        %obelisk-action
        !>  :+  %tape
                %db1
                "CREATE TABLE db1..my-table ".
                "(col1 @t, col2 @da, col3 @t, col4 @t) ".
                "PRIMARY KEY (col1)"
    ==
  =.  run  +(run)
  =^  mov4  agent
    %:  ~(on-poke agent (bowl [run ~2012.5.3]))
        %obelisk-action
        !>([%tape %db1 my-select])
    ==
  %+  expect-eq
    !>  expected
    !>  ;;(cmd-result ->+>+>+<.mov4)
::
::  select one literal
++  test-simple-query-22
  =|  run=@ud
  =/  expected  :~  %results
                    [%message 'SELECT']
                    [%result-set ~[[%vector ~[[%literal-0 ~.ud 0]]]]]
                    [%server-time ~2012.5.3]
                    [%schema-time ~2012.4.30]
                    [%data-time ~2012.4.30]
                    [%vector-count 1]
                ==
  ::
  =^  mov1  agent
    %:  ~(on-poke agent (bowl [run ~2012.4.30]))
        %obelisk-action
        !>([%tape %sys "CREATE DATABASE db1"])
    ==
  =.  run  +(run)
  =^  mov2  agent
    %:  ~(on-poke agent (bowl [run ~2012.5.1]))
        %obelisk-action
        !>  :+  %tape
                %db1
                "CREATE TABLE db1..my-table ".
                "(col1 @t, col2 @da, col3 @t, col4 @t) ".
                "PRIMARY KEY (col1)"
    ==
  =.  run  +(run)
  =^  mov4  agent
    %:  ~(on-poke agent (bowl [run ~2012.5.3]))
        %obelisk-action
        !>([%tape %db1 "SELECT 0"])
    ==
  ::
  %+  expect-eq
    !>  expected
    !>  ;;(cmd-result ->+>+>+<.mov4)
::
::  * (select all) not default DB
++  test-simple-query-23
  =|  run=@ud
  =/  expected-rows
        :~
          :-  %vector
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
  =/  expected  :~  %results
                    [%message 'SELECT']
                    [%result-set expected-rows]
                    [%server-time ~2012.5.3]
                    [%message 'db2.dbo.my-table']
                    [%schema-time ~2012.5.1]
                    [%data-time ~2012.5.2]
                    [%vector-count 3]
                ==
  =^  mov1  agent
    %:  ~(on-poke agent (bowl [run ~2012.4.29]))
        %obelisk-action
        !>([%tape %sys "CREATE DATABASE db1"])
    ==
  =.  run  +(run)
  =^  mov2  agent
    %:  ~(on-poke agent (bowl [run ~2012.4.30]))
        %obelisk-action
        !>([%tape %sys "CREATE DATABASE db2"])
    ==
  =.  run  +(run)
  =^  mov3  agent
    %:  ~(on-poke agent (bowl [run ~2012.5.1]))
        %obelisk-action
        !>  :+  %tape
                %db2
                "CREATE TABLE my-table ".
                "(col1 @t, col2 @da, col3 @t, col4 @t) ".
                "PRIMARY KEY (col1)"
    ==
    =.  run  +(run)
  =^  mov4  agent
    %:  ~(on-poke agent (bowl [run ~2012.5.2]))
        %obelisk-action
        !>  :+  %tape
                %db2
                "INSERT INTO my-table".
                " VALUES".
                " ('Abby', ~1999.2.19, 'tricolor', 'row1')".
                " ('Ace', ~2005.12.19, 'ticolor', 'row2')".
                " ('Angel', ~2001.9.19, 'tuxedo', 'row3')"
    ==
  =.  run  +(run)
  =^  mov5  agent
    %:  ~(on-poke agent (bowl [run ~2012.5.3]))
        %obelisk-action
        !>([%tape %db1 "FROM db2..my-table SELECT *"])
    ==
  %+  expect-eq
    !>  expected
    !>  ;;(cmd-result ->+>+>+<.mov5)
::
::  * (select all) not default DB, one script
++  test-simple-query-24
  =|  run=@ud
  =/  expected-rows
        :~
          :-  %vector
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
  =/  expected  :~  %results
                    [%message 'SELECT']
                    [%result-set expected-rows]
                    [%server-time ~2012.4.29]
                    [%message 'db2.dbo.my-table']
                    [%schema-time ~2012.4.29]
                    [%data-time ~2012.4.29]
                    [%vector-count 3]
                ==
  =^  mov1  agent
    %:  ~(on-poke agent (bowl [run ~2012.4.29]))
        %obelisk-action
        !>  :+  %tape
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
    ==
  %+  expect-eq
    !>  expected
  ::  !>  ;;(cmd-result ->+>+>+>+>-.mov1)
    !>  ;;(cmd-result ->+>+>+>+>+<.mov1)
::
::  lit-da, one column alias, lit-p aliased, table-alias.*, two column names, *
++  test-simple-query-25
  =|  run=@ud
  =/  expected-rows
        :~
          :-  %vector
              :~  [p=%literal-0 q=[p=~.da ~2024.10.20]]
              
                  [%col1 [~.t 'Abby']]

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
              
                  [%col1 [~.t 'Angel']]

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
              
                  [%col1 [~.t 'Ace']]

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
  =/  expected  :~  %results
                    [%message 'SELECT']
                    [%result-set expected-rows]
                    [%server-time ~2012.5.3]
                    [%message 'db1.dbo.my-table']
                    [%schema-time ~2012.5.1]
                    [%data-time ~2012.5.2]
                    [%vector-count 3]
                ==
  =^  mov1  agent
    %:  ~(on-poke agent (bowl [run ~2012.4.30]))
        %obelisk-action
        !>([%tape %sys "CREATE DATABASE db1"])
    ==
  =.  run  +(run)
  =^  mov2  agent
    %:  ~(on-poke agent (bowl [run ~2012.5.1]))
        %obelisk-action
        !>  :+  %tape
                %db1
                "CREATE TABLE db1..my-table ".
                "(col1 @t, col2 @da, col3 @t, col4 @t) ".
                "PRIMARY KEY (col1)"
    ==
  =.  run  +(run)
  =^  mov3  agent
    %:  ~(on-poke agent (bowl [run ~2012.5.2]))
        %obelisk-action
        !>  :+  %tape
                %db1
                "INSERT INTO my-table".
                " VALUES".
                " ('Abby', ~1999.2.19, 'tricolor', 'row1')".
                " ('Ace', ~2005.12.19, 'ticolor', 'row2')".
                " ('Angel', ~2001.9.19, 'tuxedo', 'row3')"
    ==
  =.  run  +(run)
  =^  mov4  agent
    %:  ~(on-poke agent (bowl [run ~2012.5.3]))
        %obelisk-action
        !>  :+  %tape
              %db1
              "FROM my-table T1 SELECT ~2024.10.20, col1 as C1, ".
              "~sampel-palnet as home, T1.*, col2,col4, *"
    ==
  %+  expect-eq
    !>  expected
    !>  ;;(cmd-result ->+>+>+<.mov4)
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

                [%col1 [~.t 'Ace']]
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

                [%col1 [~.t 'Angel']]
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

                [%col1 [~.t 'Abby']]
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

                  [%col1 [~.t 'Bandit']]
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

                  [%col1 [~.t 'Baker']]
                  ==
          ==
++  time-expected1  :~  %results
                        [%message 'SELECT']
                        [%result-set (weld time-new-rows time-expected-rows)]
                        [%server-time ~2012.5.5]
                        [%message 'db1.dbo.my-table']
                        [%schema-time ~2012.5.1]
                        [%data-time ~2012.5.3]
                        [%vector-count 5]
                        ==
++  time-expected2  :~  %results
                        [%message 'SELECT']
                        [%result-set time-expected-rows]
                        [%server-time ~2012.5.5]
                        [%message 'db1.dbo.my-table']
                        [%schema-time ~2012.5.1]
                        [%data-time ~2012.5.2]
                        [%vector-count 3]
                        ==
::
::  as-of ~time
::  *, two column names, table-name.*, one column alias
++  test-time-query-01
  =|  run=@ud
  =^  mov1  agent
    %:  ~(on-poke agent (bowl [run ~2012.4.30]))
        %obelisk-action
        !>([%tape %sys "CREATE DATABASE db1"])
    ==
  =.  run  +(run)
  =^  mov2  agent
    %:  ~(on-poke agent (bowl [run ~2012.5.1]))
        %obelisk-action
        !>  :+  %tape
                %db1
                "CREATE TABLE db1..my-table ".
                "(col1 @t, col2 @da, col3 @t, col4 @t) ".
                "PRIMARY KEY (col1)"
    ==
    =.  run  +(run)
  =^  mov3  agent
    %:  ~(on-poke agent (bowl [run ~2012.5.2]))
        %obelisk-action
        !>  :+  %tape
                %db1
                "INSERT INTO my-table".
                " VALUES".
                " ('Abby', ~1999.2.19, 'tricolor', 'row1')".
                " ('Ace', ~2005.12.19, 'ticolor', 'row2')".
                " ('Angel', ~2001.9.19, 'tuxedo', 'row3')"
    ==
  =.  run  +(run)
  =^  mov4  agent
    %:  ~(on-poke agent (bowl [run ~2012.5.3]))
        %obelisk-action
        !>  :+  %tape
                %db1
                "INSERT INTO my-table".
                " VALUES".
                " ('Baker', ~1998.3.8, 'caleco', 'row4')".
                " ('Bandit', ~2006.12.23, 'tricolor', 'row5')"
    ==
  =.  run  +(run)
  =^  mov5  agent
    %:  ~(on-poke agent (bowl [run ~2012.5.5]))
        %obelisk-action
        !>  :+  %tape
              %db1
              "FROM my-table T1 SELECT *, col2,col4, my-table.*, col1 as C1"
    ==
  ::
  =.  run  +(run)
  =^  mov6  agent
    %:  ~(on-poke agent (bowl [run ~2012.5.5]))
        %obelisk-action
        !>  :+  %tape
              %db1
              "FROM my-table AS OF ~2012.5.2 T1 ".
              "SELECT *, col2,col4, my-table.*, col1 as C1"
    ==
  ::
  ;:  weld
  %+  expect-eq
    !>  time-expected1
    !>  ;;(cmd-result ->+>+>+<.mov5)
  %+  expect-eq
    !>  time-expected2
    !>  ;;(cmd-result ->+>+>+<.mov6)
  ==
::
::  as-of 3 days ago (data-time = days ago)
::  *, two column names, table-name.*, one column alias
++  test-time-query-02
  =|  run=@ud
  =^  mov1  agent
    %:  ~(on-poke agent (bowl [run ~2012.4.30]))
        %obelisk-action
        !>([%tape %sys "CREATE DATABASE db1"])
    ==
  =.  run  +(run)
  =^  mov2  agent
    %:  ~(on-poke agent (bowl [run ~2012.5.1]))
        %obelisk-action
        !>  :+  %tape
                %db1
                "CREATE TABLE db1..my-table ".
                "(col1 @t, col2 @da, col3 @t, col4 @t) ".
                "PRIMARY KEY (col1)"
    ==
    =.  run  +(run)
  =^  mov3  agent
    %:  ~(on-poke agent (bowl [run ~2012.5.2]))
        %obelisk-action
        !>  :+  %tape
                %db1
                "INSERT INTO my-table".
                " VALUES".
                " ('Abby', ~1999.2.19, 'tricolor', 'row1')".
                " ('Ace', ~2005.12.19, 'ticolor', 'row2')".
                " ('Angel', ~2001.9.19, 'tuxedo', 'row3')"
    ==
  =.  run  +(run)
  =^  mov4  agent
    %:  ~(on-poke agent (bowl [run ~2012.5.3]))
        %obelisk-action
        !>  :+  %tape
                %db1
                "INSERT INTO my-table".
                " VALUES".
                " ('Baker', ~1998.3.8, 'caleco', 'row4')".
                " ('Bandit', ~2006.12.23, 'tricolor', 'row5')"
    ==
  =.  run  +(run)
  =^  mov5  agent
    %:  ~(on-poke agent (bowl [run ~2012.5.5]))
        %obelisk-action
        !>  :+  %tape
              %db1
              "FROM my-table T1 SELECT *, col2,col4, my-table.*, col1 as C1"
    ==
  ::
  =.  run  +(run)
  =^  mov6  agent
    %:  ~(on-poke agent (bowl [run ~2012.5.5]))
        %obelisk-action
        !>  :+  %tape
              %db1
              "FROM my-table AS OF 3 DAYS AGO T1 ".
              "SELECT *, col2,col4, my-table.*, col1 as C1"
    ==
  ::
  ;:  weld
  %+  expect-eq
    !>  time-expected1
    !>  ;;(cmd-result ->+>+>+<.mov5)
  %+  expect-eq
    !>  time-expected2
    !>  ;;(cmd-result ->+>+>+<.mov6)
  ==
::
::  as-of 2 days ago (data-time < days ago)
::  *, two column names, table-name.*, one column alias
++  test-time-query-03
  =|  run=@ud
  =/  expected1  :~  %results
                     [%message 'SELECT']
                     [%result-set (weld time-new-rows time-expected-rows)]
                     [%server-time ~2012.5.5]
                     [%message 'db1.dbo.my-table']
                     [%schema-time ~2012.5.1]
                     [%data-time ~2012.5.4]
                     [%vector-count 5]
                     ==
  ::
  =^  mov1  agent
    %:  ~(on-poke agent (bowl [run ~2012.4.30]))
        %obelisk-action
        !>([%tape %sys "CREATE DATABASE db1"])
    ==
  =.  run  +(run)
  =^  mov2  agent
    %:  ~(on-poke agent (bowl [run ~2012.5.1]))
        %obelisk-action
        !>  :+  %tape
                %db1
                "CREATE TABLE db1..my-table ".
                "(col1 @t, col2 @da, col3 @t, col4 @t) ".
                "PRIMARY KEY (col1)"
    ==
    =.  run  +(run)
  =^  mov3  agent
    %:  ~(on-poke agent (bowl [run ~2012.5.2]))
        %obelisk-action
        !>  :+  %tape
                %db1
                "INSERT INTO my-table".
                " VALUES".
                " ('Abby', ~1999.2.19, 'tricolor', 'row1')".
                " ('Ace', ~2005.12.19, 'ticolor', 'row2')".
                " ('Angel', ~2001.9.19, 'tuxedo', 'row3')"
    ==
  =.  run  +(run)
  =^  mov4  agent
    %:  ~(on-poke agent (bowl [run ~2012.5.4]))
        %obelisk-action
        !>  :+  %tape
                %db1
                "INSERT INTO my-table".
                " VALUES".
                " ('Baker', ~1998.3.8, 'caleco', 'row4')".
                " ('Bandit', ~2006.12.23, 'tricolor', 'row5')"
    ==
  =.  run  +(run)
  =^  mov5  agent
    %:  ~(on-poke agent (bowl [run ~2012.5.5]))
        %obelisk-action
        !>  :+  %tape
              %db1
              "FROM my-table T1 SELECT *, col2,col4, my-table.*, col1 as C1"
    ==
  ::
  =.  run  +(run)
  =^  mov6  agent
    %:  ~(on-poke agent (bowl [run ~2012.5.5]))
        %obelisk-action
        !>  :+  %tape
              %db1
              "FROM my-table AS OF 2 DAYS AGO T1 ".
              "SELECT *, col2,col4, my-table.*, col1 as C1"
    ==
  ::
  ;:  weld
  %+  expect-eq
    !>  expected1
    !>  ;;(cmd-result ->+>+>+<.mov5)
  %+  expect-eq
    !>  time-expected2
    !>  ;;(cmd-result ->+>+>+<.mov6)
  ==
::
::  as-of ~d3 (data-time = ~d3 ago)
::  *, two column names, table-name.*, one column alias
++  test-time-query-04
  =|  run=@ud
  =^  mov1  agent
    %:  ~(on-poke agent (bowl [run ~2012.4.30]))
        %obelisk-action
        !>([%tape %sys "CREATE DATABASE db1"])
    ==
  =.  run  +(run)
  =^  mov2  agent
    %:  ~(on-poke agent (bowl [run ~2012.5.1]))
        %obelisk-action
        !>  :+  %tape
                %db1
                "CREATE TABLE db1..my-table ".
                "(col1 @t, col2 @da, col3 @t, col4 @t) ".
                "PRIMARY KEY (col1)"
    ==
    =.  run  +(run)
  =^  mov3  agent
    %:  ~(on-poke agent (bowl [run ~2012.5.2]))
        %obelisk-action
        !>  :+  %tape
                %db1
                "INSERT INTO my-table".
                " VALUES".
                " ('Abby', ~1999.2.19, 'tricolor', 'row1')".
                " ('Ace', ~2005.12.19, 'ticolor', 'row2')".
                " ('Angel', ~2001.9.19, 'tuxedo', 'row3')"
    ==
  =.  run  +(run)
  =^  mov4  agent
    %:  ~(on-poke agent (bowl [run ~2012.5.3]))
        %obelisk-action
        !>  :+  %tape
                %db1
                "INSERT INTO my-table".
                " VALUES".
                " ('Baker', ~1998.3.8, 'caleco', 'row4')".
                " ('Bandit', ~2006.12.23, 'tricolor', 'row5')"
    ==
  =.  run  +(run)
  =^  mov5  agent
    %:  ~(on-poke agent (bowl [run ~2012.5.5]))
        %obelisk-action
        !>  :+  %tape
              %db1
              "FROM my-table T1 SELECT *, col2,col4, my-table.*, col1 as C1"
    ==
  ::
  =.  run  +(run)
  =^  mov6  agent
    %:  ~(on-poke agent (bowl [run ~2012.5.5]))
        %obelisk-action
        !>  :+  %tape
              %db1
              "FROM my-table AS OF ~d3 T1 ".
              "SELECT *, col2,col4, my-table.*, col1 as C1"
    ==
  ::
  ;:  weld
  %+  expect-eq
    !>  time-expected1
    !>  ;;(cmd-result ->+>+>+<.mov5)
  %+  expect-eq
    !>  time-expected2
    !>  ;;(cmd-result ->+>+>+<.mov6)
  ==
::
::  as-of ~d2 (data-time < ~d2 ago)
::  *, two column names, table-name.*, one column alias
++  test-time-query-05
  =|  run=@ud
  =/  expected1  :~  %results
                     [%message 'SELECT']
                     [%result-set (weld time-new-rows time-expected-rows)]
                     [%server-time ~2012.5.5]
                     [%message 'db1.dbo.my-table']
                     [%schema-time ~2012.5.1]
                     [%data-time ~2012.5.4]
                     [%vector-count 5]
                     ==
  ::
  =^  mov1  agent
    %:  ~(on-poke agent (bowl [run ~2012.4.30]))
        %obelisk-action
        !>([%tape %sys "CREATE DATABASE db1"])
    ==
  =.  run  +(run)
  =^  mov2  agent
    %:  ~(on-poke agent (bowl [run ~2012.5.1]))
        %obelisk-action
        !>  :+  %tape
                %db1
                "CREATE TABLE db1..my-table ".
                "(col1 @t, col2 @da, col3 @t, col4 @t) ".
                "PRIMARY KEY (col1)"
    ==
    =.  run  +(run)
  =^  mov3  agent
    %:  ~(on-poke agent (bowl [run ~2012.5.2]))
        %obelisk-action
        !>  :+  %tape
                %db1
                "INSERT INTO my-table".
                " VALUES".
                " ('Abby', ~1999.2.19, 'tricolor', 'row1')".
                " ('Ace', ~2005.12.19, 'ticolor', 'row2')".
                " ('Angel', ~2001.9.19, 'tuxedo', 'row3')"
    ==
  =.  run  +(run)
  =^  mov4  agent
    %:  ~(on-poke agent (bowl [run ~2012.5.4]))
        %obelisk-action
        !>  :+  %tape
                %db1
                "INSERT INTO my-table".
                " VALUES".
                " ('Baker', ~1998.3.8, 'caleco', 'row4')".
                " ('Bandit', ~2006.12.23, 'tricolor', 'row5')"
    ==
  =.  run  +(run)
  =^  mov5  agent
    %:  ~(on-poke agent (bowl [run ~2012.5.5]))
        %obelisk-action
        !>  :+  %tape
              %db1
              "FROM my-table T1 SELECT *, col2,col4, my-table.*, col1 as C1"
    ==
  ::
  =.  run  +(run)
  =^  mov6  agent
    %:  ~(on-poke agent (bowl [run ~2012.5.5]))
        %obelisk-action
        !>  :+  %tape
              %db1
              "FROM my-table AS OF ~d2 T1 ".
              "SELECT *, col2,col4, my-table.*, col1 as C1"
    ==
  ::
  ;:  weld
  %+  expect-eq
    !>  expected1
    !>  ;;(cmd-result ->+>+>+<.mov5)
  %+  expect-eq
    !>  time-expected2
    !>  ;;(cmd-result ->+>+>+<.mov6)
  ==
::
::  shrinking
::
::  shrinking one column to one vector
++  test-shrinking-01
  =|  run=@ud
  =/  expected  :~  %results
                    [%message 'SELECT']
                    [%result-set ~[[%vector ~[[%col2 [~.da ~2005.12.19]]]]]]
                    [%server-time ~2012.5.3]
                    [%message 'db1.dbo.my-table']
                    [%schema-time ~2012.5.1]
                    [%data-time ~2012.5.2]
                    [%vector-count 1]
                ==
  =^  mov1  agent
    %:  ~(on-poke agent (bowl [run ~2012.4.30]))
        %obelisk-action
        !>([%tape %sys "CREATE DATABASE db1"])
    ==
  =.  run  +(run)
  =^  mov2  agent
    %:  ~(on-poke agent (bowl [run ~2012.5.1]))
        %obelisk-action
        !>  :+  %tape
                %db1
                "CREATE TABLE db1..my-table ".
                "(col1 @t, col2 @da, col3 @t, col4 @t) ".
                "PRIMARY KEY (col1)"
    ==
    =.  run  +(run)
  =^  mov3  agent
    %:  ~(on-poke agent (bowl [run ~2012.5.2]))
        %obelisk-action
        !>  :+  %tape
                %db1
                "INSERT INTO my-table".
                " VALUES".
                " ('Abby', ~2005.12.19, 'tricolor', 'row1')".
                " ('Angel', ~2005.12.19, 'tuxedo', 'row3')".
                " ('Ace', ~2005.12.19, 'tricolor', 'row2')"
    ==
  =.  run  +(run)
  =^  mov4  agent
    %:  ~(on-poke agent (bowl [run ~2012.5.3]))
        %obelisk-action
        !>([%tape %db1 "FROM my-table SELECT col2"])
    ==
  %+  expect-eq
    !>  expected
    !>  ;;(cmd-result ->+>+>+<.mov4)
::
::  shrinking one column (out of order) to one vector
++  test-shrinking-02
  =|  run=@ud
  =/  expected-rows
        :~  [%vector ~[[%col3 [~.t 'tricolor']]]]
            [%vector ~[[%col3 [~.t 'tuxedo']]]]
            ==
  =/  expected  :~  %results
                    [%message 'SELECT']
                    [%result-set expected-rows]
                    [%server-time ~2012.5.3]
                    [%message 'db1.dbo.my-table']
                    [%schema-time ~2012.5.1]
                    [%data-time ~2012.5.2]
                    [%vector-count 2]
                ==
  =^  mov1  agent
    %:  ~(on-poke agent (bowl [run ~2012.4.30]))
        %obelisk-action
        !>([%tape %sys "CREATE DATABASE db1"])
    ==
  =.  run  +(run)
  =^  mov2  agent
    %:  ~(on-poke agent (bowl [run ~2012.5.1]))
        %obelisk-action
        !>  :+  %tape
                %db1
                "CREATE TABLE db1..my-table ".
                "(col1 @t, col2 @da, col3 @t, col4 @t) ".
                "PRIMARY KEY (col1)"
    ==
    =.  run  +(run)
  =^  mov3  agent
    %:  ~(on-poke agent (bowl [run ~2012.5.2]))
        %obelisk-action
        !>  :+  %tape
                %db1
                "INSERT INTO my-table".
                " VALUES".
                " ('Abby', ~2005.12.19, 'tricolor', 'row1')".
                " ('Ace', ~2005.12.19, 'tuxedo', 'row2')".
                " ('Angel', ~2005.12.19, 'tricolor', 'row3')"
                
    ==
  =.  run  +(run)
  =^  mov4  agent
    %:  ~(on-poke agent (bowl [run ~2012.5.3]))
        %obelisk-action
        !>([%tape %db1 "FROM my-table SELECT col3"])
    ==
  %+  expect-eq
    !>  expected
    !>  ;;(cmd-result ->+>+>+<.mov4)
::
::  shrinking one column to two vectors
++  test-shrinking-03
  =|  run=@ud
  =/  expected-rows
        :~  [%vector ~[[%col3 [~.t 'tricolor']]]]
            [%vector ~[[%col3 [~.t 'tuxedo']]]]
            ==
  =/  expected  :~  %results
                    [%message 'SELECT']
                    [%result-set expected-rows]
                    [%server-time ~2012.5.3]
                    [%message 'db1.dbo.my-table']
                    [%schema-time ~2012.5.1]
                    [%data-time ~2012.5.2]
                    [%vector-count 2]
                ==
  =^  mov1  agent
    %:  ~(on-poke agent (bowl [run ~2012.4.30]))
        %obelisk-action
        !>([%tape %sys "CREATE DATABASE db1"])
    ==
  =.  run  +(run)
  =^  mov2  agent
    %:  ~(on-poke agent (bowl [run ~2012.5.1]))
        %obelisk-action
        !>  :+  %tape
                %db1
                "CREATE TABLE db1..my-table ".
                "(col1 @t, col2 @da, col3 @t, col4 @t) ".
                "PRIMARY KEY (col1)"
    ==
    =.  run  +(run)
  =^  mov3  agent
    %:  ~(on-poke agent (bowl [run ~2012.5.2]))
        %obelisk-action
        !>  :+  %tape
                %db1
                "INSERT INTO my-table".
                " VALUES".
                " ('Abby', ~2005.12.19, 'tricolor', 'row1')".
                " ('Angel', ~2005.12.19, 'tuxedo', 'row3')".
                " ('Ace', ~2005.12.19, 'tricolor', 'row2')"
    ==
  =.  run  +(run)
  =^  mov4  agent
    %:  ~(on-poke agent (bowl [run ~2012.5.3]))
        %obelisk-action
        !>([%tape %db1 "FROM my-table SELECT col3"])
    ==
  %+  expect-eq
    !>  expected
    !>  ;;(cmd-result ->+>+>+<.mov4)
::
::  shrinking two columns to two vectors
++  test-shrinking-04
  =|  run=@ud
  =/  expected-rows
        :~  [%vector ~[[%col2 [~.da ~2005.12.19]] [%col3 [~.t 'tricolor']]]]
            [%vector ~[[%col2 [~.da ~2005.12.19]] [%col3 [~.t 'tuxedo']]]]
            ==
  =/  expected  :~  %results
                    [%message 'SELECT']
                    [%result-set expected-rows]
                    [%server-time ~2012.5.3]
                    [%message 'db1.dbo.my-table']
                    [%schema-time ~2012.5.1]
                    [%data-time ~2012.5.2]
                    [%vector-count 2]
                ==
  =^  mov1  agent
    %:  ~(on-poke agent (bowl [run ~2012.4.30]))
        %obelisk-action
        !>([%tape %sys "CREATE DATABASE db1"])
    ==
  =.  run  +(run)
  =^  mov2  agent
    %:  ~(on-poke agent (bowl [run ~2012.5.1]))
        %obelisk-action
        !>  :+  %tape
                %db1
                "CREATE TABLE db1..my-table ".
                "(col1 @t, col2 @da, col3 @t, col4 @t) ".
                "PRIMARY KEY (col1)"
    ==
    =.  run  +(run)
  =^  mov3  agent
    %:  ~(on-poke agent (bowl [run ~2012.5.2]))
        %obelisk-action
        !>  :+  %tape
                %db1
                "INSERT INTO my-table".
                " VALUES".
                " ('Abby', ~2005.12.19, 'tricolor', 'row1')".
                " ('Angel', ~2005.12.19, 'tuxedo', 'row3')".
                " ('Ace', ~2005.12.19, 'tricolor', 'row2')"
    ==
  =.  run  +(run)
  =^  mov4  agent
    %:  ~(on-poke agent (bowl [run ~2012.5.3]))
        %obelisk-action
        !>([%tape %db1 "FROM my-table SELECT col2 as c2, col3"])
    ==
  %+  expect-eq
    !>  expected
    !>  ;;(cmd-result ->+>+>+<.mov4)
::
::  shrinking two columns and literals to two vectors
++  test-shrinking-05
  =|  run=@ud
  =/  expected-rows
        :~  :-  %vector
                :~  [p=%literal-0 q=[p=~.da ~2024.10.20]]
                    [%col2 [~.da ~2005.12.19]]
                    [p=%home q=[p=~.p ~sampel-palnet]]
                    [%col3 [~.t 'tuxedo']]
                    ==
            :-  %vector
                :~  [p=%literal-0 q=[p=~.da ~2024.10.20]]
                    [%col2 [~.da ~2005.12.19]]
                    [p=%home q=[p=~.p ~sampel-palnet]]
                    [%col3 [~.t 'tricolor']]
                    ==
            ==
  =/  expected  :~  %results
                    [%message 'SELECT']
                    [%result-set expected-rows]
                    [%server-time ~2012.5.3]
                    [%message 'db1.dbo.my-table']
                    [%schema-time ~2012.5.1]
                    [%data-time ~2012.5.2]
                    [%vector-count 2]
                ==
  =^  mov1  agent
    %:  ~(on-poke agent (bowl [run ~2012.4.30]))
        %obelisk-action
        !>([%tape %sys "CREATE DATABASE db1"])
    ==
  =.  run  +(run)
  =^  mov2  agent
    %:  ~(on-poke agent (bowl [run ~2012.5.1]))
        %obelisk-action
        !>  :+  %tape
                %db1
                "CREATE TABLE db1..my-table ".
                "(col1 @t, col2 @da, col3 @t, col4 @t) ".
                "PRIMARY KEY (col1)"
    ==
    =.  run  +(run)
  =^  mov3  agent
    %:  ~(on-poke agent (bowl [run ~2012.5.2]))
        %obelisk-action
        !>  :+  %tape
                %db1
                "INSERT INTO my-table".
                " VALUES".
                " ('Abby', ~2005.12.19, 'tricolor', 'row1')".
                " ('Angel', ~2005.12.19, 'tuxedo', 'row3')".
                " ('Ace', ~2005.12.19, 'tricolor', 'row2')"
    ==
  =.  run  +(run)
  =^  mov4  agent
    %:  ~(on-poke agent (bowl [run ~2012.5.3]))
        %obelisk-action
        !>  :+  %tape
                %db1
                "FROM my-table SELECT  ~2024.10.20, col2 as c2, ".
                "~sampel-palnet as home, col3"
    ==
  %+  expect-eq
    !>  expected
    !>  ;;(cmd-result ->+>+>+<.mov4)
::
::  shrinking two columns and literals from view
++  test-shrinking-06
  =|  run=@ud
  =/  expected-rows
        :~  :-  %vector
                :~  [p=%literal-0 q=[p=~.da ~2024.10.20]]
                    [%tmsp [~.da ~2012.5.2]]
                    [p=%home q=[p=~.p ~sampel-palnet]]
                    [%key [~.tas 'c2-col2']]
                    ==
            :-  %vector
                :~  [p=%literal-0 q=[p=~.da ~2024.10.20]]
                    [%tmsp [~.da ~2012.5.2]]
                    [p=%home q=[p=~.p ~sampel-palnet]]
                    [%key [~.tas 'c2-col1']]
                    ==
            :-  %vector
                :~  [p=%literal-0 q=[p=~.da ~2024.10.20]]
                    [%tmsp [~.da ~2012.5.1]]
                    [p=%home q=[p=~.p ~sampel-palnet]]
                    [%key [~.tas 'col1']]
                    ==
            ==
  =/  expected  :~  %results
                    [%message 'SELECT']
                    [%result-set expected-rows]
                    [%server-time ~2012.5.3]
                    [%message 'db1.sys.tables']
                    [%schema-time ~2012.5.2]
                    [%data-time ~2012.5.2]
                    [%vector-count 3]
                ==
  =^  mov1  agent
    %:  ~(on-poke agent (bowl [run ~2012.4.30]))
        %obelisk-action
        !>([%tape %sys "CREATE DATABASE db1"])
    ==
  =.  run  +(run)
  =^  mov2  agent
    %:  ~(on-poke agent (bowl [run ~2012.5.1]))
        %obelisk-action
        !>  :+  %tape
                %db1
                "CREATE TABLE db1..my-table ".
                "(col1 @t, col2 @da, col3 @t, col4 @t) ".
                "PRIMARY KEY (col1)"
    ==
  =.  run  +(run)
  =^  mov3  agent
    %:  ~(on-poke agent (bowl [run ~2012.5.2]))
        %obelisk-action
        !>  :+  %tape
                %db1
                "CREATE TABLE db1..my-table-2 ".
                "(c2-col1 @t, c2-col2 @da, c2-col3 @t, c2-col4 @t) ".
                "PRIMARY KEY (c2-col1, c2-col2)"
    ==
  ::
  =.  run  +(run)
  =^  mov4  agent
    %:  ~(on-poke agent (bowl [run ~2012.5.3]))
        %obelisk-action
        !>  :+  %tape
                %db1
                "FROM sys.tables SELECT  ~2024.10.20, tmsp as time, ".
                "~sampel-palnet as home, key"
    ==
  %+  expect-eq
    !>  expected
    !>  ;;(cmd-result ->+>+>+<.mov4)
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
::
::  test T1.* in select
++  test-joins-00
  =|  run=@ud
  =/  expected-rows
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
  =/  expected  :~  %results
                    [%message 'SELECT']
                    [%result-set expected-rows]
                    [%server-time ~2012.5.3]
                    [%message 'db1.dbo.calendar']
                    [%schema-time ~2012.4.30]
                    [%data-time ~2012.4.30]
                    [%message 'db1.dbo.holiday-calendar']
                    [%schema-time ~2012.4.30]
                    [%data-time ~2012.4.30]
                    [%vector-count 2]
                ==
  =^  mov1  agent
    %+  ~(on-poke agent (bowl [run ~2012.4.30]))
        %obelisk-action
        !>  :+  %tape
                %db1
                %-  zing  :~  "CREATE DATABASE db1;"
                              create-calendar
                              insert-calendar
                              create-holiday-calendar
                              insert-holiday-calendar
                              ==
  =.  run  +(run)
   =^  mov2  agent
    %+  ~(on-poke agent (bowl [run ~2012.5.3]))
        %obelisk-action
        !>  :+  %tape
                %db1
                "FROM calendar T1 ".
                "JOIN holiday-calendar T2 ".
                "SELECT T1.day-name, T2.*"
  %+  expect-eq
    !>  expected
    !>  ;;(cmd-result ->+>+>+<.mov2)
::
::  test alternating file alias case
++  test-joins-01
  =|  run=@ud
  =/  expected-rows
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
  =/  expected  :~  %results
                    [%message 'SELECT']
                    [%result-set expected-rows]
                    [%server-time ~2012.5.3]
                    [%message 'db1.dbo.calendar']
                    [%schema-time ~2012.4.30]
                    [%data-time ~2012.4.30]
                    [%message 'db1.dbo.holiday-calendar']
                    [%schema-time ~2012.4.30]
                    [%data-time ~2012.4.30]
                    [%vector-count 2]
                ==
  =^  mov1  agent
    %+  ~(on-poke agent (bowl [run ~2012.4.30]))
        %obelisk-action
        !>  :+  %tape
                %db1
                %-  zing  :~  "CREATE DATABASE db1;"
                              create-calendar
                              insert-calendar
                              create-holiday-calendar
                              insert-holiday-calendar
                              ==
  =.  run  +(run)
   =^  mov2  agent
    %+  ~(on-poke agent (bowl [run ~2012.5.3]))
        %obelisk-action
        !>  :+  %tape
                %db1
                "FROM calendar t1 ".
                "JOIN holiday-calendar T2 ".
                "SELECT T1.day-name, t2.*, t2.us-federal-holiday"
  %+  expect-eq
    !>  expected
    !>  ;;(cmd-result ->+>+>+<.mov2)
::
::  test alternating file alias case in predicate
++  test-joins-02
  =|  run=@ud
  =/  expected-rows
        :~  :-  %vector
                :~  [%day-name [~.t 'Monday']]
                    [%date [~.da ~2023.12.25]]
                    [%us-federal-holiday [~.t 'Christmas Day']]
                    [%us-federal-holiday [~.t 'Christmas Day']]
                    ==
            ==
  =/  expected  :~  %results
                    [%message 'SELECT']
                    [%result-set expected-rows]
                    [%server-time ~2012.5.3]
                    [%message 'db1.dbo.calendar']
                    [%schema-time ~2012.4.30]
                    [%data-time ~2012.4.30]
                    [%message 'db1.dbo.holiday-calendar']
                    [%schema-time ~2012.4.30]
                    [%data-time ~2012.4.30]
                    [%vector-count 1]
                ==
  =^  mov1  agent
    %+  ~(on-poke agent (bowl [run ~2012.4.30]))
        %obelisk-action
        !>  :+  %tape
                %db1
                %-  zing  :~  "CREATE DATABASE db1;"
                              create-calendar
                              insert-calendar
                              create-holiday-calendar
                              insert-holiday-calendar
                              ==
  =.  run  +(run)
   =^  mov2  agent
    %+  ~(on-poke agent (bowl [run ~2012.5.3]))
        %obelisk-action
        !>  :+  %tape
                %db1
                "FROM calendar t1 ".
                "JOIN holiday-calendar T2 ".
                "WHERE T1.day-name = 'Monday' ".
                "  AND t2.us-federal-holiday = 'Christmas Day' ".
                "SELECT T1.day-name, t2.*, t2.us-federal-holiday"
  %+  expect-eq
    !>  expected
    !>  ;;(cmd-result ->+>+>+<.mov2)
::
::  test mixed column alias case in predicate
++  test-joins-03
  =|  run=@ud
  =/  expected-rows
        :~  :-  %vector
                :~  [%day [~.t 'Monday']]
                    [%us-federal-holiday [~.t 'Christmas Day']]
                    ==
            ==
  =/  expected  :~  %results
                    [%message 'SELECT']
                    [%result-set expected-rows]
                    [%server-time ~2012.5.3]
                    [%message 'db1.dbo.calendar']
                    [%schema-time ~2012.4.30]
                    [%data-time ~2012.4.30]
                    [%message 'db1.dbo.holiday-calendar']
                    [%schema-time ~2012.4.30]
                    [%data-time ~2012.4.30]
                    [%vector-count 1]
                ==
  =^  mov1  agent
    %+  ~(on-poke agent (bowl [run ~2012.4.30]))
        %obelisk-action
        !>  :+  %tape
                %db1
                %-  zing  :~  "CREATE DATABASE db1;"
                              create-calendar
                              insert-calendar
                              create-holiday-calendar
                              insert-holiday-calendar
                              ==
  =.  run  +(run)
  =^  mov2  agent
    %+  ~(on-poke agent (bowl [run ~2012.5.3]))
        %obelisk-action
        !>  :+  %tape
                %db1
                "FROM calendar t1 ".
                "JOIN holiday-calendar T2 ".
                "WHERE T1.day-name = 'Monday' ".
                "  AND t2.us-federal-holiday = 'Christmas Day' ".
                "SELECT T1.day-name AS Day, t2.us-federal-holiday"
  %+  expect-eq
    !>  expected
    !>  ;;(cmd-result ->+>+>+<.mov2)
::
::  bugs
::
::  bug selecting calendar because of screw-up in views schema API
++  test-bugz-01
  =|  run=@ud
  =/  expected-rows
        :~
          :-  %vector
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
  ::
  =/  expected  :~  %results
                    [%message 'SELECT']
                    [%result-set expected-rows]
                    [%server-time ~2024.8.22..16.11.26]
                    [%message 'animal-shelter.reference.calendar']
                    [%schema-time ~2024.8.22..15.31.46]
                    [%data-time ~2024.8.22..15.31.46]
                    [%vector-count 4]
                ==
  =^  mov1  agent
   %:  ~(on-poke agent (bowl [run ~2024.8.22..15.31.16]))
       %obelisk-action
       !>([%tape %sys "CREATE DATABASE animal-shelter"])
   ==
  =.  run  +(run)
  =^  mov2  agent
    %:  ~(on-poke agent (bowl [run ~2024.8.22..15.31.46]))
        %obelisk-action
        !>  :+  %tape
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
    ==
  =.  run  +(run)
  =^  mov3  agent
    %:  ~(on-poke agent (bowl [run ~2024.8.22..16.11.26]))
        %obelisk-action
        !>  :+  %tape
              %animal-shelter
              "FROM reference.calendar SELECT *"
    ==
  %+  expect-eq
    !>  expected
    !>  ;;(cmd-result ->+>+>+<.mov3)
::
:: SELECT error messages
::
::  fail on prior to table existence
++  test-fail-select-01
  =|  run=@ud
  =/  my-select  "FROM my-table SELECT ".
                 "my-table.col4,my-table.col3,my-table.col2,my-table.col1"
  ::
  =^  mov1  agent
    %:  ~(on-poke agent (bowl [run ~2012.4.30]))
        %obelisk-action
        !>([%tape %sys "CREATE DATABASE db1"])
    ==
  =.  run  +(run)
  =^  mov2  agent
    %:  ~(on-poke agent (bowl [run ~2012.5.1]))
        %obelisk-action
        !>  :+  %tape
                %db1
                "CREATE TABLE db1..my-table ".
                "(col1 @t, col2 @da, col3 @t, col4 @t) ".
                "PRIMARY KEY (col1) ".
                "AS OF ~2012.5.3"
    ==
    =.  run  +(run)
  =^  mov3  agent
    %:  ~(on-poke agent (bowl [run ~2012.5.2]))
        %obelisk-action
        !>  :+  %tape
                %db1
                "INSERT INTO my-table".
                " VALUES".
                " ('Abby', ~1999.2.19, 'tricolor', 'row1')".
                " ('Ace', ~2005.12.19, 'ticolor', 'row2')".
                " ('Angel', ~2001.9.19, 'tuxedo', 'row3') ".
                "AS OF ~2012.5.4"
    ==
  =.  run  +(run)
  ::
  %+  expect-fail-message
        'table %db1.%dbo.%my-table does not exist at schema time ~2012.4.30'
  |.  %:  ~(on-poke agent (bowl [run ~2012.5.2]))
          %obelisk-action
          !>([%test %db1 my-select])
      ==
::
::  fail on bad column name   to do: fix and uncomment
::++  test-fail-select-02
::  =|  run=@ud
::  =/  my-select  "FROM my-table SELECT ".
::                 "col4, foo"
  ::
::  =^  mov1  agent
::    %:  ~(on-poke agent (bowl [run ~2012.4.30]))
::        %obelisk-action
::        !>([%tape %sys "CREATE DATABASE db1"])
::    ==
::  =.  run  +(run)
::  =^  mov2  agent
::    %:  ~(on-poke agent (bowl [run ~2012.5.1]))
::        %obelisk-action
::        !>  :+  %tape
::                %db1
::                "CREATE TABLE db1..my-table ".
::                "(col1 @t, col2 @da, col3 @t, col4 @t) ".
::                "PRIMARY KEY (col1) ".
::                "AS OF ~2012.5.3"
::    ==
::  =.  run  +(run)
::  =^  mov3  agent
::    %:  ~(on-poke agent (bowl [run ~2012.5.2]))
::        %obelisk-action
::        !>  :+  %tape
::                %db1
::                "INSERT INTO my-table".
::                " VALUES".
::                " ('Abby', ~1999.2.19, 'tricolor', 'row1')".
::                " ('Ace', ~2005.12.19, 'ticolor', 'row2')".
::                " ('Angel', ~2001.9.19, 'tuxedo', 'row3') ".
::                "AS OF ~2012.5.4"
::    ==
::  =.  run  +(run)
  ::
::  %+  expect-fail-message
::        'SELECT: column %foo not found'
::  |.  %:  ~(on-poke agent (bowl [run ~2012.5.3]))
::          %obelisk-action
::          !>([%test %db1 my-select])
::      ==
::
::  fail on as-of ~d4 (schema-time < ~d4 ago)
++  test-fail-time-query-01
  =|  run=@ud
  =/  expected1  :~  %results
                     [%message 'SELECT']
                     [%result-set (weld time-expected-rows time-new-rows)]
                     [%server-time ~2012.5.5]
                     [%message 'db1.dbo.my-table']
                     [%schema-time ~2012.5.1]
                     [%data-time ~2012.5.4]
                     [%vector-count 5]
                     ==
  ::
  =^  mov1  agent
    %:  ~(on-poke agent (bowl [run ~2012.4.30]))
        %obelisk-action
        !>([%tape %sys "CREATE DATABASE db1"])
    ==
  =.  run  +(run)
  =^  mov2  agent
    %:  ~(on-poke agent (bowl [run ~2012.5.2]))
        %obelisk-action
        !>  :+  %tape
                %db1
                "CREATE TABLE db1..my-table ".
                "(col1 @t, col2 @da, col3 @t, col4 @t) ".
                "PRIMARY KEY (col1)"
    ==
    =.  run  +(run)
  =^  mov3  agent
    %:  ~(on-poke agent (bowl [run ~2012.5.3]))
        %obelisk-action
        !>  :+  %tape
                %db1
                "INSERT INTO my-table".
                " VALUES".
                " ('Abby', ~1999.2.19, 'tricolor', 'row1')".
                " ('Ace', ~2005.12.19, 'ticolor', 'row2')".
                " ('Angel', ~2001.9.19, 'tuxedo', 'row3')"
    ==
  %+  expect-fail-message
    'SELECT: table %db1.%dbo.%my-table does not exist at schema time ~2012.4.30'
  |.  %:  ~(on-poke agent (bowl [run ~2012.5.5]))
      %obelisk-action
      !>  :+  %test
              %db1
              "FROM my-table AS OF ~d4 T1 ".
              "SELECT *, col2,col4, my-table.*, col1 as C1"
    ==

--