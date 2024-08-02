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
      =databases
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
              ::  :~  [%col1 [~.t 2.036.490.817]]
              ::      [%col2 [~.da 170.141.184.492.111.779.796.175.933.613.172.326.400]]
              ::      [%col3 [~.t 8.245.928.668.403.692.148]]
              ::      [%col4 [~.t 829.910.898]]
              :~  [%col1 [~.t 'Abby']]
                  [%col2 [~.da ~1999.2.19]]
                  [%col3 [~.t 'tricolor']]
                  [%col4 [~.t 'row1']]
                  ==
          :-  %vector
              ::  :~  [%col1 [~.t 6.644.545]]
              ::      [%col2 [~.da 170.141.184.496.088.307.522.657.354.235.930.214.400]]
              ::      [%col3 [~.t 32.210.658.860.951.924]]
              ::      [%col4 [~.t 846.688.114]
              :~  [%col1 [~.t 'Ace']]
                  [%col2 [~.da ~2005.12.19]]
                  [%col3 [~.t 'ticolor']]
                  [%col4 [~.t 'row2']]
                  ==
          :-  %vector
              ::  :~  [%col1 [~.t 465.557.745.217]]
              ::      [%col2 [~.da 170.141.184.493.614.731.958.930.234.072.996.249.600]]
              ::      [%col3 [~.t 122.476.989.805.940]]
              ::      [%col4 [~.t 863.465.330]]
              :~  [%col1 [~.t 'Angel']]
                  [%col2 [~.da ~2001.9.19]]
                  [%col3 [~.t 'tuxedo']]
                  [%col4 [~.t 'row3']]
                  ==
            ==
  =/  expected  :~  %results
                    :-  %result-set  expected-rows
                    :-  %server-time  ~2012.5.3
                    :-  %schema-time  ~2012.5.1
                    :-  %data-time  ~2012.5.2
                    :-  %vector-count  3
                ==
  =^  mov1  agent
    %:  ~(on-poke agent (bowl [run ~2012.4.30]))
        %obelisk-action
        !>([%tape-create-db "CREATE DATABASE db1"])
    ==
  =.  run  +(run)
  =^  mov2  agent
    %:  ~(on-poke agent (bowl [run ~2012.5.1]))
        %obelisk-action
        !>  :+  %tape
                %db1
                "CREATE TABLE db1..my-table ".
                "(col1 @t, col2 @da, col3 @t, col4 @t) ".
                "PRIMARY KEY CLUSTERED (col1)"
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
    ::!>  ;;(* expected)
    ::!>  ->+>+>-.mov4
    !>  ;;(cmd-result ->+>+>-.mov4)
::
::  *, *
++  test-simple-query-02
  =|  run=@ud
  =/  expected-rows
        :~
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
              :~  [%col1 [~.t 'Angel']]
                  [%col2 [~.da ~2001.9.19]]
                  [%col3 [~.t 'tuxedo']]
                  [%col4 [~.t 'row3']]
                  [%col1 [~.t 'Angel']]
                  [%col2 [~.da ~2001.9.19]]
                  [%col3 [~.t 'tuxedo']]
                  [%col4 [~.t 'row3']]
                  ==
            ==
  =/  expected  :~  %results
                    :-  %result-set  expected-rows
                    :-  %server-time  ~2012.5.3
                    :-  %schema-time  ~2012.5.1
                    :-  %data-time  ~2012.5.2
                    :-  %vector-count  3
                ==
  =^  mov1  agent
    %:  ~(on-poke agent (bowl [run ~2012.4.30]))
        %obelisk-action
        !>([%tape-create-db "CREATE DATABASE db1"])
    ==
  =.  run  +(run)
  =^  mov2  agent
    %:  ~(on-poke agent (bowl [run ~2012.5.1]))
        %obelisk-action
        !>  :+  %tape
                %db1
                "CREATE TABLE db1..my-table ".
                "(col1 @t, col2 @da, col3 @t, col4 @t) ".
                "PRIMARY KEY CLUSTERED (col1)"
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
    ::!>  ;;(* expected)
    ::!>  ->+>+>-.mov4
    !>  ;;(cmd-result ->+>+>-.mov4)
::
::  table-name.*
++  test-simple-query-03
  =|  run=@ud
  =/  expected-rows
        :~
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
          :-  %vector
              :~  [%col1 [~.t 'Angel']]
                  [%col2 [~.da ~2001.9.19]]
                  [%col3 [~.t 'tuxedo']]
                  [%col4 [~.t 'row3']]
                  ==
            ==
  =/  expected  :~  %results
                    :-  %result-set  expected-rows
                    :-  %server-time  ~2012.5.3
                    :-  %schema-time  ~2012.5.1
                    :-  %data-time  ~2012.5.2
                    :-  %vector-count  3
                ==
  =^  mov1  agent
    %:  ~(on-poke agent (bowl [run ~2012.4.30]))
        %obelisk-action
        !>([%tape-create-db "CREATE DATABASE db1"])
    ==
  =.  run  +(run)
  =^  mov2  agent
    %:  ~(on-poke agent (bowl [run ~2012.5.1]))
        %obelisk-action
        !>  :+  %tape
                %db1
                "CREATE TABLE db1..my-table ".
                "(col1 @t, col2 @da, col3 @t, col4 @t) ".
                "PRIMARY KEY CLUSTERED (col1)"
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
    ::!>  ;;(* expected)
    ::!>  ->+>+>-.mov4
    !>  ;;(cmd-result ->+>+>-.mov4)
::
::  table-alias.*
++  test-simple-query-04
  =|  run=@ud
  =/  expected-rows
        :~
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
          :-  %vector
              :~  [%col1 [~.t 'Angel']]
                  [%col2 [~.da ~2001.9.19]]
                  [%col3 [~.t 'tuxedo']]
                  [%col4 [~.t 'row3']]
                  ==
            ==
  =/  expected  :~  %results
                    :-  %result-set  expected-rows
                    :-  %server-time  ~2012.5.3
                    :-  %schema-time  ~2012.5.1
                    :-  %data-time  ~2012.5.2
                    :-  %vector-count  3
                ==
  =^  mov1  agent
    %:  ~(on-poke agent (bowl [run ~2012.4.30]))
        %obelisk-action
        !>([%tape-create-db "CREATE DATABASE db1"])
    ==
  =.  run  +(run)
  =^  mov2  agent
    %:  ~(on-poke agent (bowl [run ~2012.5.1]))
        %obelisk-action
        !>  :+  %tape
                %db1
                "CREATE TABLE db1..my-table ".
                "(col1 @t, col2 @da, col3 @t, col4 @t) ".
                "PRIMARY KEY CLUSTERED (col1)"
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
    ::!>  ;;(* expected)
    ::!>  ->+>+>-.mov4
    !>  ;;(cmd-result ->+>+>-.mov4)
::
::  *, *
++  test-simple-query-05
  =|  run=@ud
  =/  expected-rows
        :~
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
          :-  %vector
              :~  [%col1 [~.t 'Angel']]
                  [%col2 [~.da ~2001.9.19]]
                  [%col3 [~.t 'tuxedo']]
                  [%col4 [~.t 'row3']]
                  ==
            ==
  =/  expected  :~  %results
                    :-  %result-set  expected-rows
                    :-  %server-time  ~2012.5.3
                    :-  %schema-time  ~2012.5.1
                    :-  %data-time  ~2012.5.2
                    :-  %vector-count  3
                ==
  =^  mov1  agent
    %:  ~(on-poke agent (bowl [run ~2012.4.30]))
        %obelisk-action
        !>([%tape-create-db "CREATE DATABASE db1"])
    ==
  =.  run  +(run)
  =^  mov2  agent
    %:  ~(on-poke agent (bowl [run ~2012.5.1]))
        %obelisk-action
        !>  :+  %tape
                %db1
                "CREATE TABLE db1..my-table ".
                "(col1 @t, col2 @da, col3 @t, col4 @t) ".
                "PRIMARY KEY CLUSTERED (col1)"
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
        !>([%tape %db1 "FROM my-table SELECT col1,col2,col3,col4"])
    ==
  %+  expect-eq
    !>  expected
    ::!>  ;;(* expected)
    ::!>  ->+>+>-.mov4
    !>  ;;(cmd-result ->+>+>-.mov4)
::
::  all column aliases
++  test-simple-query-06
  =|  run=@ud
  =/  expected-rows
        :~
          :-  %vector
              :~  [%c1 [~.t 'Abby']]
                  [%c2 [~.da ~1999.2.19]]
                  [%c3 [~.t 'tricolor']]
                  [%c4 [~.t 'row1']]
                  ==
          :-  %vector
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
            ==
  =/  expected  :~  %results
                    :-  %result-set  expected-rows
                    :-  %server-time  ~2012.5.3
                    :-  %schema-time  ~2012.5.1
                    :-  %data-time  ~2012.5.2
                    :-  %vector-count  3
                ==
  =^  mov1  agent
    %:  ~(on-poke agent (bowl [run ~2012.4.30]))
        %obelisk-action
        !>([%tape-create-db "CREATE DATABASE db1"])
    ==
  =.  run  +(run)
  =^  mov2  agent
    %:  ~(on-poke agent (bowl [run ~2012.5.1]))
        %obelisk-action
        !>  :+  %tape
                %db1
                "CREATE TABLE db1..my-table ".
                "(col1 @t, col2 @da, col3 @t, col4 @t) ".
                "PRIMARY KEY CLUSTERED (col1)"
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
        !>([%tape %db1 "FROM my-table SELECT col1 as c1,col2 as c2,col3 as c3,col4 as c4"])
    ==
  %+  expect-eq
    !>  expected
    ::!>  ;;(* expected)
    ::!>  ->+>+>-.mov4
    !>  ;;(cmd-result ->+>+>-.mov4)
::
::  all literals
++  test-simple-query-07
  =|  run=@ud
  =/  expected-rows
        :~
          :-  %vector
              :~  [%literal-0 [~.t 430.242.426.723]]
                  [%literal-1 [~.p 28.242.037]]
                  [%literal-2 [~.da 170.141.184.504.830.774.788.415.618.594.688.204.800]]
                  [%literal-3 [~.da 170.141.184.504.830.774.788.415.618.594.688.204.800]]
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
                    :-  %result-set  expected-rows
                    :-  %server-time  ~2012.5.3
                    :-  %schema-time  ~2012.4.30
                    :-  %data-time  ~2012.4.30
                    :-  %vector-count  1
                ==

  =/  select  "SELECT 'cor,d', ~nomryg-nilref, ~2020.12.25..7.15.0..1ef5, ".
              "2020.12.25..7.15.0..1ef5, ~d71.h19.m26.s24..9d55, ".
              ".195.198.143.90, .0.0.0.0.0.1c.c3c6.8f5a, Y, N, 2.222, 2222, ".
              "195.198.143.900, .3.14, .-3.14, ~3.14, ~-3.14, 0x12.6401, ".
              "10.1011, -20, --20, 'cor\\'d'"
  =^  mov1  agent
    %:  ~(on-poke agent (bowl [run ~2012.4.30]))
        %obelisk-action
        !>([%tape-create-db "CREATE DATABASE db1"])
    ==
  =.  run  +(run)
  =^  mov4  agent
    %:  ~(on-poke agent (bowl [run ~2012.5.3]))
        %obelisk-action
        !>([%tape %sys select])
    ==
  %+  expect-eq
    ::!>  expected
    !>  ;;(* expected)
    !>  ->+>+>-.mov4
    ::!>  ;;(cmd-result ->+>+>-.mov4)
::
::  all literals, aliased
++  test-simple-query-08
  =|  run=@ud
  =/  expected-rows
        :~
          :-  %vector
              :~  [%cord1 [~.t 430.242.426.723]]
                  [%ship [~.p 28.242.037]]
                  [%date1 [~.da 170.141.184.504.830.774.788.415.618.594.688.204.800]]
                  [%date2 [~.da 170.141.184.504.830.774.788.415.618.594.688.204.800]]
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
                    :-  %result-set  expected-rows
                    :-  %server-time  ~2012.5.3
                    :-  %schema-time  ~2012.4.30
                    :-  %data-time  ~2012.4.30
                    :-  %vector-count  1
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
        !>([%tape-create-db "CREATE DATABASE db1"])
    ==
  =.  run  +(run)
  =^  mov4  agent
    %:  ~(on-poke agent (bowl [run ~2012.5.3]))
        %obelisk-action
        !>([%tape %sys select])
    ==
  %+  expect-eq
    ::!>  expected
    !>  ;;(* expected)
    !>  ->+>+>-.mov4
    ::!>  ;;(cmd-result ->+>+>-.mov4)
::
::  interspersed literals, aliased and unaliased
++  test-simple-query-09
  =|  run=@ud
  =/  expected-rows
        :~
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
          :-  %vector
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
            ==
  =/  expected  :~  %results
                    :-  %result-set  expected-rows
                    :-  %server-time  ~2012.5.3
                    :-  %schema-time  ~2012.5.1
                    :-  %data-time  ~2012.5.2
                    :-  %vector-count  3
                ==
  =^  mov1  agent
    %:  ~(on-poke agent (bowl [run ~2012.4.30]))
        %obelisk-action
        !>([%tape-create-db "CREATE DATABASE db1"])
    ==
  =.  run  +(run)
  =^  mov2  agent
    %:  ~(on-poke agent (bowl [run ~2012.5.1]))
        %obelisk-action
        !>  :+  %tape
                %db1
                "CREATE TABLE db1..my-table ".
                "(col1 @t, col2 @da, col3 @t, col4 @t) ".
                "PRIMARY KEY CLUSTERED (col1)"
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
        !>([%tape %db1 "FROM my-table T1 SELECT 'cor\\'d' AS cord, col1 as C1, ~nomryg-nilref, col2, .-3.14 as pi, col3, col4, ~2023.12.25"])
    ==
  %+  expect-eq
    ::!>  expected
    !>  ;;(* expected)
    !>  ->+>+>-.mov4
    ::!>  ;;(cmd-result ->+>+>-.mov4)
::
::  all column names, reversed
++  test-simple-query-10
  =|  run=@ud
  =/  expected-rows
        :~
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
          :-  %vector
              :~  [%col4 [~.t 'row3']]
                  [%col3 [~.t 'tuxedo']]
                  [%col2 [~.da ~2001.9.19]]
                  [%col1 [~.t 'Angel']]
                  ==
            ==
  =/  expected  :~  %results
                    :-  %result-set  expected-rows
                    :-  %server-time  ~2012.5.3
                    :-  %schema-time  ~2012.5.1
                    :-  %data-time  ~2012.5.2
                    :-  %vector-count  3
                ==
  =^  mov1  agent
    %:  ~(on-poke agent (bowl [run ~2012.4.30]))
        %obelisk-action
        !>([%tape-create-db "CREATE DATABASE db1"])
    ==
  =.  run  +(run)
  =^  mov2  agent
    %:  ~(on-poke agent (bowl [run ~2012.5.1]))
        %obelisk-action
        !>  :+  %tape
                %db1
                "CREATE TABLE db1..my-table ".
                "(col1 @t, col2 @da, col3 @t, col4 @t) ".
                "PRIMARY KEY CLUSTERED (col1)"
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
    ::!>  ;;(* expected)
    ::!>  ->+>+>-.mov4
    !>  ;;(cmd-result ->+>+>-.mov4)
::
::  all column aliases (mixed case), reversed
++  test-simple-query-11
  =|  run=@ud
  =/  expected-rows
        :~
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
          :-  %vector
              :~  [%c4 [~.t 'row3']]
                  [%c3 [~.t 'tuxedo']]
                  [%c2 [~.da ~2001.9.19]]
                  [%c1 [~.t 'Angel']]
                  ==
            ==
  =/  expected  :~  %results
                    :-  %result-set  expected-rows
                    :-  %server-time  ~2012.5.3
                    :-  %schema-time  ~2012.5.1
                    :-  %data-time  ~2012.5.2
                    :-  %vector-count  3
                ==
  =^  mov1  agent
    %:  ~(on-poke agent (bowl [run ~2012.4.30]))
        %obelisk-action
        !>([%tape-create-db "CREATE DATABASE db1"])
    ==
  =.  run  +(run)
  =^  mov2  agent
    %:  ~(on-poke agent (bowl [run ~2012.5.1]))
        %obelisk-action
        !>  :+  %tape
                %db1
                "CREATE TABLE db1..my-table ".
                "(col1 @t, col2 @da, col3 @t, col4 @t) ".
                "PRIMARY KEY CLUSTERED (col1)"
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
        !>([%tape %db1 "FROM my-table SELECT col4 as c4,col3 as C3,col2 as c2,col1 as c1"])
    ==
  %+  expect-eq
    !>  expected
    ::!>  ;;(* expected)
    ::!>  ->+>+>-.mov4
    !>  ;;(cmd-result ->+>+>-.mov4)
::
::  all column names, with table prefix
++  test-simple-query-12
  =|  run=@ud
  =/  expected-rows
        :~
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
          :-  %vector
              :~  [%col1 [~.t 'Angel']]
                  [%col2 [~.da ~2001.9.19]]
                  [%col3 [~.t 'tuxedo']]
                  [%col4 [~.t 'row3']]
                  ==
            ==
  =/  expected  :~  %results
                    :-  %result-set  expected-rows
                    :-  %server-time  ~2012.5.3
                    :-  %schema-time  ~2012.5.1
                    :-  %data-time  ~2012.5.2
                    :-  %vector-count  3
                ==
  =^  mov1  agent
    %:  ~(on-poke agent (bowl [run ~2012.4.30]))
        %obelisk-action
        !>([%tape-create-db "CREATE DATABASE db1"])
    ==
  =.  run  +(run)
  =^  mov2  agent
    %:  ~(on-poke agent (bowl [run ~2012.5.1]))
        %obelisk-action
        !>  :+  %tape
                %db1
                "CREATE TABLE db1..my-table ".
                "(col1 @t, col2 @da, col3 @t, col4 @t) ".
                "PRIMARY KEY CLUSTERED (col1)"
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
        !>([%tape %db1 "FROM my-table SELECT my-table.col1,my-table.col2,my-table.col3,my-table.col4"])
    ==
  %+  expect-eq
    !>  expected
    ::!>  ;;(* expected)
    ::!>  ->+>+>-.mov4
    !>  ;;(cmd-result ->+>+>-.mov4)
::
::  all column names, with table alias
++  test-simple-query-13
  =|  run=@ud
  =/  expected-rows
        :~
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
          :-  %vector
              :~  [%col1 [~.t 'Angel']]
                  [%col2 [~.da ~2001.9.19]]
                  [%col3 [~.t 'tuxedo']]
                  [%col4 [~.t 'row3']]
                  ==
            ==
  =/  expected  :~  %results
                    :-  %result-set  expected-rows
                    :-  %server-time  ~2012.5.3
                    :-  %schema-time  ~2012.5.1
                    :-  %data-time  ~2012.5.2
                    :-  %vector-count  3
                ==
  =^  mov1  agent
    %:  ~(on-poke agent (bowl [run ~2012.4.30]))
        %obelisk-action
        !>([%tape-create-db "CREATE DATABASE db1"])
    ==
  =.  run  +(run)
  =^  mov2  agent
    %:  ~(on-poke agent (bowl [run ~2012.5.1]))
        %obelisk-action
        !>  :+  %tape
                %db1
                "CREATE TABLE db1..my-table ".
                "(col1 @t, col2 @da, col3 @t, col4 @t) ".
                "PRIMARY KEY CLUSTERED (col1)"
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
        !>([%tape %db1 "FROM my-table T1 SELECT T1.col1,T1.col2,T1.col3,T1.col4"])
    ==
  %+  expect-eq
    !>  expected
    ::!>  ;;(* expected)
    ::!>  ->+>+>-.mov4
    !>  ;;(cmd-result ->+>+>-.mov4)
::
::  all column names, with table prefix, reversed
++  test-simple-query-14
  =|  run=@ud
  =/  expected-rows
        :~
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
          :-  %vector
              :~  [%col4 [~.t 'row3']]
                  [%col3 [~.t 'tuxedo']]
                  [%col2 [~.da ~2001.9.19]]
                  [%col1 [~.t 'Angel']]
                  ==
            ==
  =/  expected  :~  %results
                    :-  %result-set  expected-rows
                    :-  %server-time  ~2012.5.3
                    :-  %schema-time  ~2012.5.1
                    :-  %data-time  ~2012.5.2
                    :-  %vector-count  3
                ==
  =^  mov1  agent
    %:  ~(on-poke agent (bowl [run ~2012.4.30]))
        %obelisk-action
        !>([%tape-create-db "CREATE DATABASE db1"])
    ==
  =.  run  +(run)
  =^  mov2  agent
    %:  ~(on-poke agent (bowl [run ~2012.5.1]))
        %obelisk-action
        !>  :+  %tape
                %db1
                "CREATE TABLE db1..my-table ".
                "(col1 @t, col2 @da, col3 @t, col4 @t) ".
                "PRIMARY KEY CLUSTERED (col1)"
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
        !>([%tape %db1 "FROM my-table SELECT my-table.col4,my-table.col3,my-table.col2,my-table.col1"])
    ==
  %+  expect-eq
    !>  expected
    ::!>  ;;(* expected)
    ::!>  ->+>+>-.mov4
    !>  ;;(cmd-result ->+>+>-.mov4)
::
::  all column names, with table alias, reversed
++  test-simple-query-15
  =|  run=@ud
  =/  expected-rows
        :~
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
          :-  %vector
              :~  [%col4 [~.t 'row3']]
                  [%col3 [~.t 'tuxedo']]
                  [%col2 [~.da ~2001.9.19]]
                  [%col1 [~.t 'Angel']]
                  ==
            ==
  =/  expected  :~  %results
                    :-  %result-set  expected-rows
                    :-  %server-time  ~2012.5.3
                    :-  %schema-time  ~2012.5.1
                    :-  %data-time  ~2012.5.2
                    :-  %vector-count  3
                ==
  =^  mov1  agent
    %:  ~(on-poke agent (bowl [run ~2012.4.30]))
        %obelisk-action
        !>([%tape-create-db "CREATE DATABASE db1"])
    ==
  =.  run  +(run)
  =^  mov2  agent
    %:  ~(on-poke agent (bowl [run ~2012.5.1]))
        %obelisk-action
        !>  :+  %tape
                %db1
                "CREATE TABLE db1..my-table ".
                "(col1 @t, col2 @da, col3 @t, col4 @t) ".
                "PRIMARY KEY CLUSTERED (col1)"
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
        !>([%tape %db1 "FROM my-table T1 SELECT T1.col4,T1.col3,T1.col2,T1.col1"])
    ==
  %+  expect-eq
    !>  expected
    ::!>  ;;(* expected)
    ::!>  ->+>+>-.mov4
    !>  ;;(cmd-result ->+>+>-.mov4)
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
                    :-  %result-set  expected-rows
                    :-  %server-time  ~2012.5.3
                    :-  %schema-time  ~2012.5.1
                    :-  %data-time  ~2012.5.2
                    :-  %vector-count  3
                ==
  =^  mov1  agent
    %:  ~(on-poke agent (bowl [run ~2012.4.30]))
        %obelisk-action
        !>([%tape-create-db "CREATE DATABASE db1"])
    ==
  =.  run  +(run)
  =^  mov2  agent
    %:  ~(on-poke agent (bowl [run ~2012.5.1]))
        %obelisk-action
        !>  :+  %tape
                %db1
                "CREATE TABLE db1..my-table ".
                "(col1 @t, col2 @da, col3 @t, col4 @t) ".
                "PRIMARY KEY CLUSTERED (col1)"
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
    ::!>  ;;(* expected)
    ::!>  ->+>+>-.mov4
    !>  ;;(cmd-result ->+>+>-.mov4)
::
::  one column name, table-name.*
++  test-simple-query-17
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
                    :-  %result-set  expected-rows
                    :-  %server-time  ~2012.5.3
                    :-  %schema-time  ~2012.5.1
                    :-  %data-time  ~2012.5.2
                    :-  %vector-count  3
                ==
  =^  mov1  agent
    %:  ~(on-poke agent (bowl [run ~2012.4.30]))
        %obelisk-action
        !>([%tape-create-db "CREATE DATABASE db1"])
    ==
  =.  run  +(run)
  =^  mov2  agent
    %:  ~(on-poke agent (bowl [run ~2012.5.1]))
        %obelisk-action
        !>  :+  %tape
                %db1
                "CREATE TABLE db1..my-table ".
                "(col1 @t, col2 @da, col3 @t, col4 @t) ".
                "PRIMARY KEY CLUSTERED (col1)"
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
    ::!>  ;;(* expected)
    ::!>  ->+>+>-.mov4
    !>  ;;(cmd-result ->+>+>-.mov4)
    ::
::
::  one column name, table-alias.*
++  test-simple-query-18
  =|  run=@ud
  =/  expected-rows
        :~
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
          :-  %vector
              :~  [%col2 [~.da ~2001.9.19]]
                  [%col1 [~.t 'Angel']]
                  [%col2 [~.da ~2001.9.19]]
                  [%col3 [~.t 'tuxedo']]
                  [%col4 [~.t 'row3']]
                  ==
            ==
  =/  expected  :~  %results
                    :-  %result-set  expected-rows
                    :-  %server-time  ~2012.5.3
                    :-  %schema-time  ~2012.5.1
                    :-  %data-time  ~2012.5.2
                    :-  %vector-count  3
                ==
  =^  mov1  agent
    %:  ~(on-poke agent (bowl [run ~2012.4.30]))
        %obelisk-action
        !>([%tape-create-db "CREATE DATABASE db1"])
    ==
  =.  run  +(run)
  =^  mov2  agent
    %:  ~(on-poke agent (bowl [run ~2012.5.1]))
        %obelisk-action
        !>  :+  %tape
                %db1
                "CREATE TABLE db1..my-table ".
                "(col1 @t, col2 @da, col3 @t, col4 @t) ".
                "PRIMARY KEY CLUSTERED (col1)"
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
    ::!>  expected
    !>  ;;(* expected)
    !>  ->+>+>-.mov4
    ::!>  ;;(cmd-result ->+>+>-.mov4)
::
::  *, two column names, table-name.*, one column alias
++  test-simple-query-19
  =|  run=@ud
  =/  expected-rows
        :~
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
            ==
  =/  expected  :~  %results
                    :-  %result-set  expected-rows
                    :-  %server-time  ~2012.5.3
                    :-  %schema-time  ~2012.5.1
                    :-  %data-time  ~2012.5.2
                    :-  %vector-count  3
                ==
  =^  mov1  agent
    %:  ~(on-poke agent (bowl [run ~2012.4.30]))
        %obelisk-action
        !>([%tape-create-db "CREATE DATABASE db1"])
    ==
  =.  run  +(run)
  =^  mov2  agent
    %:  ~(on-poke agent (bowl [run ~2012.5.1]))
        %obelisk-action
        !>  :+  %tape
                %db1
                "CREATE TABLE db1..my-table ".
                "(col1 @t, col2 @da, col3 @t, col4 @t) ".
                "PRIMARY KEY CLUSTERED (col1)"
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
        !>([%tape %db1 "FROM my-table T1 SELECT *, col2,col4, my-table.*, col1 as C1"])
    ==
  %+  expect-eq
    ::!>  expected
    !>  ;;(* expected)
    !>  ->+>+>-.mov4
    ::!>  ;;(cmd-result ->+>+>-.mov4)
::
::  one column alias, table-alias.*, two column names, *
++  test-simple-query-20
  =|  run=@ud
  =/  expected-rows
        :~
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
  =/  expected  :~  %results
                    :-  %result-set  expected-rows
                    :-  %server-time  ~2012.5.3
                    :-  %schema-time  ~2012.5.1
                    :-  %data-time  ~2012.5.2
                    :-  %vector-count  3
                ==
  =^  mov1  agent
    %:  ~(on-poke agent (bowl [run ~2012.4.30]))
        %obelisk-action
        !>([%tape-create-db "CREATE DATABASE db1"])
    ==
  =.  run  +(run)
  =^  mov2  agent
    %:  ~(on-poke agent (bowl [run ~2012.5.1]))
        %obelisk-action
        !>  :+  %tape
                %db1
                "CREATE TABLE db1..my-table ".
                "(col1 @t, col2 @da, col3 @t, col4 @t) ".
                "PRIMARY KEY CLUSTERED (col1)"
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
        !>([%tape %db1 "FROM my-table T1 SELECT col1 as C1, T1.*, col2,col4, *"])
    ==
  %+  expect-eq
    ::!>  expected
    !>  ;;(* expected)
    !>  ->+>+>-.mov4
    ::!>  ;;(cmd-result ->+>+>-.mov4)
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
                    :-  %result-set  expected-rows
                    :-  %server-time  ~2012.5.3
                    :-  %schema-time  ~2012.4.30
                    :-  %data-time  ~2012.4.30
                    :-  %vector-count  1
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
        !>([%tape-create-db "CREATE DATABASE db1"])
    ==
  =.  run  +(run)
  =^  mov2  agent
    %:  ~(on-poke agent (bowl [run ~2012.5.1]))
        %obelisk-action
        !>  :+  %tape
                %db1
                "CREATE TABLE db1..my-table ".
                "(col1 @t, col2 @da, col3 @t, col4 @t) ".
                "PRIMARY KEY CLUSTERED (col1)"
    ==
  =.  run  +(run)
  =^  mov4  agent
    %:  ~(on-poke agent (bowl [run ~2012.5.3]))
        %obelisk-action
        !>([%tape %db1 my-select])
    ==
  %+  expect-eq
    !>  expected
    ::!>  ;;(* expected)
    ::!>  ->+>+>-.mov4
    !>  ;;(cmd-result ->+>+>-.mov4)
::
::  select one literal
++  test-simple-query-22
  =|  run=@ud
  =/  expected  :~  %results
                    :-  %result-set  ~[[%vector ~[[%literal-0 ~.ud 0]]]]
                    :-  %server-time  ~2012.5.3
                    :-  %schema-time  ~2012.4.30
                    :-  %data-time  ~2012.4.30
                    :-  %vector-count  1
                ==
  ::
  =^  mov1  agent
    %:  ~(on-poke agent (bowl [run ~2012.4.30]))
        %obelisk-action
        !>([%tape-create-db "CREATE DATABASE db1"])
    ==
  =.  run  +(run)
  =^  mov2  agent
    %:  ~(on-poke agent (bowl [run ~2012.5.1]))
        %obelisk-action
        !>  :+  %tape
                %db1
                "CREATE TABLE db1..my-table ".
                "(col1 @t, col2 @da, col3 @t, col4 @t) ".
                "PRIMARY KEY CLUSTERED (col1)"
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
    ::!>  ;;(* expected)
    ::!>  ->+>+>-.mov4
    !>  ;;(cmd-result ->+>+>-.mov4)
::
::  shrinking
::
::  shrinking one column to one vector
++  test-shrinking-01
  =|  run=@ud
  =/  expected  :~  %results
                    :-  %result-set  ~[[%vector ~[[%col2 [~.da ~2005.12.19]]]]]
                    :-  %server-time  ~2012.5.3
                    :-  %schema-time  ~2012.5.1
                    :-  %data-time  ~2012.5.2
                    :-  %vector-count  1
                ==
  =^  mov1  agent
    %:  ~(on-poke agent (bowl [run ~2012.4.30]))
        %obelisk-action
        !>([%tape-create-db "CREATE DATABASE db1"])
    ==
  =.  run  +(run)
  =^  mov2  agent
    %:  ~(on-poke agent (bowl [run ~2012.5.1]))
        %obelisk-action
        !>  :+  %tape
                %db1
                "CREATE TABLE db1..my-table ".
                "(col1 @t, col2 @da, col3 @t, col4 @t) ".
                "PRIMARY KEY CLUSTERED (col1)"
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
                " ('Ace', ~2005.12.19, 'tricolor', 'row2')".
                " ('Angel', ~2005.12.19, 'tuxedo', 'row3')"
    ==
  =.  run  +(run)
  =^  mov4  agent
    %:  ~(on-poke agent (bowl [run ~2012.5.3]))
        %obelisk-action
        !>([%tape %db1 "FROM my-table SELECT col2"])
    ==
  %+  expect-eq
    !>  expected
    ::!>  ;;(* expected)
    ::!>  ->+>+>-.mov4
    !>  ;;(cmd-result ->+>+>-.mov4)
::
::  shrinking one column to two vectors
++  test-shrinking-02
  =|  run=@ud
  =/  expected-rows
        :~  [%vector ~[[%col3 [~.t 'tricolor']]]]
            [%vector ~[[%col3 [~.t 'tuxedo']]]]
            ==
  =/  expected  :~  %results
                    :-  %result-set  expected-rows
                    :-  %server-time  ~2012.5.3
                    :-  %schema-time  ~2012.5.1
                    :-  %data-time  ~2012.5.2
                    :-  %vector-count  2
                ==
  =^  mov1  agent
    %:  ~(on-poke agent (bowl [run ~2012.4.30]))
        %obelisk-action
        !>([%tape-create-db "CREATE DATABASE db1"])
    ==
  =.  run  +(run)
  =^  mov2  agent
    %:  ~(on-poke agent (bowl [run ~2012.5.1]))
        %obelisk-action
        !>  :+  %tape
                %db1
                "CREATE TABLE db1..my-table ".
                "(col1 @t, col2 @da, col3 @t, col4 @t) ".
                "PRIMARY KEY CLUSTERED (col1)"
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
    ::!>  ;;(* expected)
    ::!>  ->+>+>-.mov4
    !>  ;;(cmd-result ->+>+>-.mov4)
::
::  shrinking two columns to two vectors
++  test-shrinking-03
  =|  run=@ud
  =/  expected-rows
        :~  [%vector ~[[%c2 [~.da ~2005.12.19]] [%col3 [~.t 'tricolor']]]]
            [%vector ~[[%c2 [~.da ~2005.12.19]] [%col3 [~.t 'tuxedo']]]]
            ==
  =/  expected  :~  %results
                    :-  %result-set  expected-rows
                    :-  %server-time  ~2012.5.3
                    :-  %schema-time  ~2012.5.1
                    :-  %data-time  ~2012.5.2
                    :-  %vector-count  2
                ==
  =^  mov1  agent
    %:  ~(on-poke agent (bowl [run ~2012.4.30]))
        %obelisk-action
        !>([%tape-create-db "CREATE DATABASE db1"])
    ==
  =.  run  +(run)
  =^  mov2  agent
    %:  ~(on-poke agent (bowl [run ~2012.5.1]))
        %obelisk-action
        !>  :+  %tape
                %db1
                "CREATE TABLE db1..my-table ".
                "(col1 @t, col2 @da, col3 @t, col4 @t) ".
                "PRIMARY KEY CLUSTERED (col1)"
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
    ::!>  ;;(* expected)
    ::!>  ->+>+>-.mov4
    !>  ;;(cmd-result ->+>+>-.mov4)
::
:: SELECT error messages
::
::  SELECT prior to table existence
++  test-fail-select-01
  =|  run=@ud
  =/  my-select  "FROM my-table SELECT ".
                 "my-table.col4,my-table.col3,my-table.col2,my-table.col1"
  ::
  =^  mov1  agent
    %:  ~(on-poke agent (bowl [run ~2012.4.30]))
        %obelisk-action
        !>([%tape-create-db "CREATE DATABASE db1"])
    ==
  =.  run  +(run)
  =^  mov2  agent
    %:  ~(on-poke agent (bowl [run ~2012.5.1]))
        %obelisk-action
        !>  :+  %tape
                %db1
                "CREATE TABLE db1..my-table ".
                "(col1 @t, col2 @da, col3 @t, col4 @t) ".
                "PRIMARY KEY CLUSTERED (col1) ".
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
        'table %dbo.%my-table does not exist at schema time ~2012.4.30'
  |.  %:  ~(on-poke agent (bowl [run ~2012.5.2]))
          %obelisk-action
          !>([%tape %db1 my-select])
      ==
--