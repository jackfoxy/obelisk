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
:: INSERT
::
::  insert rows to table
++  test-insert-01
  =|  run=@ud
  =/  my-insert  "INSERT INTO db1..my-table (col1, col2, col3)  ".
                 "VALUES ('cord',~nomryg-nilref,20) ('Default',Default, 0)"
  =/  expected-1  :~  %results
                      [%server-time ~2012.5.3]
                      [%schema-time ~2012.5.1]
                      [%data-time ~2012.5.3]
                      [%message 'inserted:']
                      [%vector-count 2]
                      [%message 'table data:']
                      [%vector-count 2]
                ==
  =/  expected-rows  :: to do: make "real" alpha ordering
        :~
          :-  %vector
              :~  [%col1 [~.t 'Default']]
                  [%col2 [~.p ~zod]]
                  [%col3 [~.ud 0]]
                  ==
          :-  %vector
              :~  [%col1 [~.t 'cord']]
                  [%col2 [~.p ~nomryg-nilref]]
                  [%col3 [~.ud 20]]
                  ==
            ==
  =/  expected-2  :~  %results
                      [%result-set expected-rows]
                      [%server-time ~2012.5.4]
                      [%schema-time ~2012.5.1]
                      [%data-time ~2012.5.3]
                      [%vector-count 2]
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
                "(col1 @t, col2 @p, col3 @ud) ".
                "PRIMARY KEY CLUSTERED (col1)"
    ==
  =.  run  +(run)
  =^  mov3  agent
    %:  ~(on-poke agent (bowl [run ~2012.5.3]))
        %obelisk-action
        !>([%tape %db1 my-insert])
    ==
  =.  run  +(run)
  =^  mov4  agent
    %:  ~(on-poke agent (bowl [run ~2012.5.4]))
        %obelisk-action
        !>([%tape %db1 "FROM my-table SELECT *"])
    ==
  ::
  %+  weld
      %+  expect-eq
        !>  expected-1
        ::!>  ;;(* expected-1)
        ::!>  ->+>+>-.mov3
        !>  ;;(cmd-result ->+>+>-.mov3)
      %+  expect-eq
        !>  expected-2
        ::!>  ;;(* expected-2)
        ::!>  ->+>+>-.mov4
        !>  ;;(cmd-result ->+>+>-.mov4)
::
::  insert rows to table, cols not in cannonical order
++  test-insert-02
  =|  run=@ud
  =/  my-insert  "INSERT INTO db1..my-table (col1, col3, col2)  ".
                 "VALUES ('cord',20,~nomryg-nilref) ('Default', 0,Default)"
  =/  expected-1  :~  %results
                      [%server-time ~2012.5.3]
                      [%schema-time ~2012.5.1]
                      [%data-time ~2012.5.3]
                      [%message 'inserted:']
                      [%vector-count 2]
                      [%message 'table data:']
                      [%vector-count 2]
                  ==
  =/  expected-rows  :: to do: make "real" alpha ordering
        :~
          :-  %vector
              :~  [%col1 [~.t 'Default']]
                  [%col2 [~.p ~zod]]
                  [%col3 [~.ud 0]]
                  ==
          :-  %vector
              :~  [%col1 [~.t 'cord']]
                  [%col2 [~.p ~nomryg-nilref]]
                  [%col3 [~.ud 20]]
                  ==
            ==
  =/  expected-2  :~  %results
                      :-  %result-set  expected-rows
                      :-  %server-time  ~2012.5.4
                      :-  %schema-time  ~2012.5.1
                      :-  %data-time  ~2012.5.3
                      :-  %vector-count  2
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
                "(col1 @t, col2 @p, col3 @ud) ".
                "PRIMARY KEY CLUSTERED (col1)"
    ==
  =.  run  +(run)
  =^  mov3  agent
    %:  ~(on-poke agent (bowl [run ~2012.5.3]))
        %obelisk-action
        !>([%tape %db1 my-insert])
    ==
  =.  run  +(run)
  =^  mov4  agent
    %:  ~(on-poke agent (bowl [run ~2012.5.4]))
        %obelisk-action
        !>([%tape %db1 "FROM my-table SELECT *"])
    ==
  ::
  %+  weld
      %+  expect-eq
        !>  expected-1
        ::!>  ;;(* expected-1)
        ::!>  ->+>+>-.mov3
        !>  ;;(cmd-result ->+>+>-.mov3)
      %+  expect-eq
        !>  expected-2
        ::!>  ;;(* expected-2)
        ::!>  ->+>+>-.mov4
        !>  ;;(cmd-result ->+>+>-.mov4)
::
::  insert rows to table, cols in inverse cannonical order
++  test-insert-03
  =|  run=@ud
  =/  my-insert  "INSERT INTO db1..my-table (col3, col2, col1)  ".
                 "VALUES (20,~nomryg-nilref,'cord') (0,Default,'Default')"
  =/  expected-1  :~  %results
                      [%server-time ~2012.5.3]
                      [%schema-time ~2012.5.1]
                      [%data-time ~2012.5.3]
                      [%message 'inserted:']
                      [%vector-count 2]
                      [%message 'table data:']
                      [%vector-count 2]
                  ==
  =/  expected-rows  :: to do: make "real" alpha ordering
        :~
          :-  %vector
              :~  [%col1 [~.t 'Default']]
                  [%col2 [~.p ~zod]]
                  [%col3 [~.ud 0]]
                  ==
          :-  %vector
              :~  [%col1 [~.t 'cord']]
                  [%col2 [~.p ~nomryg-nilref]]
                  [%col3 [~.ud 20]]
                  ==
            ==
  =/  expected-2  :~  %results
                      :-  %result-set  expected-rows
                      :-  %server-time  ~2012.5.4
                      :-  %schema-time  ~2012.5.1
                      :-  %data-time  ~2012.5.3
                      :-  %vector-count  2
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
                "(col1 @t, col2 @p, col3 @ud) ".
                "PRIMARY KEY CLUSTERED (col1)"
    ==
  =.  run  +(run)
  =^  mov3  agent
    %:  ~(on-poke agent (bowl [run ~2012.5.3]))
        %obelisk-action
        !>([%tape %db1 my-insert])
    ==
  =.  run  +(run)
  =^  mov4  agent
    %:  ~(on-poke agent (bowl [run ~2012.5.4]))
        %obelisk-action
        !>([%tape %db1 "FROM my-table SELECT *"])
    ==
  ::
  %+  weld
      %+  expect-eq
        !>  expected-1
        ::!>  ;;(* expected-1)
        ::!>  ->+>+>-.mov3
        !>  ;;(cmd-result ->+>+>-.mov3)
      %+  expect-eq
        !>  expected-2
        ::!>  ;;(* expected-2)
        ::!>  ->+>+>-.mov4
        !>  ;;(cmd-result ->+>+>-.mov4)
::
::  insert rows to table, canonical order, columns not specified
++  test-insert-04
  =|  run=@ud
  =/  my-insert  "INSERT INTO db1..my-table ".
                 "VALUES ('cord',~nomryg-nilref,20) ('Default',Default, 0)"
  =/  expected-1  :~  %results
                      [%server-time ~2012.5.3]
                      [%schema-time ~2012.5.1]
                      [%data-time ~2012.5.3]
                      [%message 'inserted:']
                      [%vector-count 2]
                      [%message 'table data:']
                      [%vector-count 2]
                ==
  =/  expected-rows  :: to do: make "real" alpha ordering
        :~
          :-  %vector
              :~  [%col1 [~.t 'Default']]
                  [%col2 [~.p ~zod]]
                  [%col3 [~.ud 0]]
                  ==
          :-  %vector
              :~  [%col1 [~.t 'cord']]
                  [%col2 [~.p ~nomryg-nilref]]
                  [%col3 [~.ud 20]]
                  ==
            ==
  =/  expected-2  :~  %results
                      [%result-set expected-rows]
                      [%server-time ~2012.5.4]
                      [%schema-time ~2012.5.1]
                      [%data-time ~2012.5.3]
                      [%vector-count 2]
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
                "(col1 @t, col2 @p, col3 @ud) ".
                "PRIMARY KEY CLUSTERED (col1)"
    ==
  =.  run  +(run)
  =^  mov3  agent
    %:  ~(on-poke agent (bowl [run ~2012.5.3]))
        %obelisk-action
        !>([%tape %db1 my-insert])
    ==
  =.  run  +(run)
  =^  mov4  agent
    %:  ~(on-poke agent (bowl [run ~2012.5.4]))
        %obelisk-action
        !>([%tape %db1 "FROM my-table SELECT *"])
    ==
  ::
  %+  weld
      %+  expect-eq
        !>  expected-1
        ::!>  ;;(* expected-1)
        ::!>  ->+>+>-.mov3
        !>  ;;(cmd-result ->+>+>-.mov3)
      %+  expect-eq
        !>  expected-2
        ::!>  ;;(* expected-2)
        ::!>  ->+>+>-.mov4
        !>  ;;(cmd-result ->+>+>-.mov4)
::
::  insert rows to table, table already populated
++  test-insert-05
  =|  run=@ud
  =/  my-insert-1  "INSERT INTO db1..my-table ".
                 "VALUES ('cord',~nomryg-nilref,20) ('Default',Default, 0)"
  =/  my-insert-2  "INSERT INTO db1..my-table ".
                 "VALUES ('cord-2',~sampel-palnet,40) ('Default-2',Default, 0)"
  =/  expected-1  :~  %results
                      [%server-time ~2012.5.4]
                      [%schema-time ~2012.5.1]
                      [%data-time ~2012.5.4]
                      [%message 'inserted:']
                      [%vector-count 2]
                      [%message 'table data:']
                      [%vector-count 4]
                ==
  =/  expected-rows  :: to do: make "real" alpha ordering
        :~
          :-  %vector
              :~  [%col1 [~.t 'Default']]
                  [%col2 [~.p ~zod]]
                  [%col3 [~.ud 0]]
                  ==
          :-  %vector
              :~  [%col1 [~.t 'Default-2']]
                  [%col2 [~.p ~zod]]
                  [%col3 [~.ud 0]]
                  ==
          :-  %vector
              :~  [%col1 [~.t 'cord']]
                  [%col2 [~.p ~nomryg-nilref]]
                  [%col3 [~.ud 20]]
                  ==
          :-  %vector
              :~  [%col1 [~.t 'cord-2']]
                  [%col2 [~.p ~sampel-palnet]]
                  [%col3 [~.ud 40]]
                  ==
            ==
  =/  expected-2  :~  %results
                      [%result-set expected-rows]
                      [%server-time ~2012.5.5]
                      [%schema-time ~2012.5.1]
                      [%data-time ~2012.5.4]
                      [%vector-count 4]
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
                "(col1 @t, col2 @p, col3 @ud) ".
                "PRIMARY KEY CLUSTERED (col1)"
    ==
  =.  run  +(run)
  =^  mov3  agent
    %:  ~(on-poke agent (bowl [run ~2012.5.3]))
        %obelisk-action
        !>([%tape %db1 my-insert-1])
    ==
  =.  run  +(run)
  =^  mov4  agent
    %:  ~(on-poke agent (bowl [run ~2012.5.4]))
        %obelisk-action
        !>([%tape %db1 my-insert-2])
    ==
  =.  run  +(run)
  =^  mov5  agent
    %:  ~(on-poke agent (bowl [run ~2012.5.5]))
        %obelisk-action
        !>([%tape %db1 "FROM my-table SELECT *"])
    ==
  ::
  %+  weld
      %+  expect-eq
        !>  expected-1
        ::!>  ;;(* expected-1)
        ::!>  ->+>+>-.mov4
        !>  ;;(cmd-result ->+>+>-.mov4)
      %+  expect-eq
        !>  expected-2
        ::!>  ;;(* expected-2)
        ::!>  ->+>+>-.mov5
        !>  ;;(cmd-result ->+>+>-.mov5)
::
:: INSERT error messages
::
:: insert rows without columns, fail on col wrong type
++  test-fail-insert-01
  =|  run=@ud
  =/  my-insert
        "INSERT INTO db1..my-table VALUES ('cord2',~nec,21) ('cord2',1, ~bus)"
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
                "(col1 @t, col2 @p, col3 @ud) ".
                "PRIMARY KEY CLUSTERED (col1)"
    ==
  =.  run  +(run)
  ::
  %+  expect-fail-message
        'type of column %column name=%col2 does not match input value type ~.ud'
  |.  %:  ~(on-poke agent (bowl [run ~2012.5.5]))
          %obelisk-action
          !>([%tape %db1 my-insert])
      ==
::
:: fail on dup rows
++  test-fail-insert-02
  =|  run=@ud
  =/  my-insert  "INSERT INTO db1..my-table (col1, col2, col3)  ".
                 "VALUES ('cord',~nomryg-nilref,20) ('Default',Default, 0)"
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
                "(col1 @t, col2 @p, col3 @ud) ".
                "PRIMARY KEY CLUSTERED (col1)"
    ==
  =.  run  +(run)
  =^  mov3  agent
    %:  ~(on-poke agent (bowl [run ~2012.5.2]))
        %obelisk-action
        !>([%tape %db1 my-insert])
    ==
  =.  run  +(run)
  ::
  %+  expect-fail-message
        'cannot add duplicate key: ~[1.685.221.219]'
  |.  %:  ~(on-poke agent (bowl [run ~2012.5.5]))
          %obelisk-action
          !>([%tape %db1 my-insert])
      ==
::
:: fail on dup col names
++  test-fail-insert-03
  =|  run=@ud
  =/  my-insert  "INSERT INTO db1..my-table (col1, col2, col2)  ".
                 "VALUES ('cord',20,20) ('Default',Default, 0)"
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
                "(col1 @t, col2 @ud, col3 @ud) ".
                "PRIMARY KEY CLUSTERED (col1)"
    ==
  =.  run  +(run)
  ::
  %+  expect-fail-message
        'incorrect columns specified: [~ u=<|col1 col2 col2|>]'
  |.  %:  ~(on-poke agent (bowl [run ~2012.5.5]))
          %obelisk-action
          !>([%tape %db1 my-insert])
      ==
::
:: fail on too few cols
++  test-fail-insert-04
  =|  run=@ud
  =/  my-insert  "INSERT INTO db1..my-table (col1, col2)  ".
                 "VALUES ('cord',~nomryg-nilref,20) ('Default',Default, 0)"
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
                "(col1 @t, col2 @p, col3 @ud) ".
                "PRIMARY KEY CLUSTERED (col1)"
    ==
  =.  run  +(run)
  ::
  %+  expect-fail-message
        'incorrect columns specified: [~ u=<|col1 col2|>]'
  |.  %:  ~(on-poke agent (bowl [run ~2012.5.5]))
          %obelisk-action
          !>([%tape %db1 my-insert])
      ==
::
:: fail on too many cols
++  test-fail-insert-05
  =|  run=@ud
  =/  my-insert  "INSERT INTO db1..my-table (col1, col2, col3, col4) ".
                 "VALUES ('cord',~nomryg-nilref,20) ('Default',Default, 0)"
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
                "(col1 @t, col2 @p, col3 @ud) ".
                "PRIMARY KEY CLUSTERED (col1)"
    ==
  =.  run  +(run)
  ::
  %+  expect-fail-message
        'incorrect columns specified: [~ u=<|col1 col2 col3 col4|>]'
  |.  %:  ~(on-poke agent (bowl [run ~2012.5.5]))
          %obelisk-action
          !>([%tape %db1 my-insert])
      ==
::
:: insert rows with columns specified, fail on col wrong type
++  test-fail-insert-06
  =|  run=@ud
  =/  my-insert  "INSERT INTO db1..my-table (col1, col2, col3) ".
                 "VALUES ('cord',40,20) ('Default',Default, 0)"
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
                "(col1 @t, col2 @p, col3 @ud) ".
                "PRIMARY KEY CLUSTERED (col1)"
    ==
  =.  run  +(run)
  ::
  %+  expect-fail-message
        'type of column %column name=%col2 does not match input value type ~.ud'
  |.  %:  ~(on-poke agent (bowl [run ~2012.5.5]))
          %obelisk-action
          !>([%tape %db1 my-insert])
      ==
::
:: fail on bad column name
++  test-fail-insert-07
  =|  run=@ud
  =/  my-insert  "INSERT INTO db1..my-table (col1a, col2, col3) ".
                 "VALUES ('cord',~nomryg-nilref,20) ('Default',Default, 0)"
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
                "(col1 @t, col2 @p, col3 @ud) ".
                "PRIMARY KEY CLUSTERED (col1)"
    ==
  =.  run  +(run)
  ::
  %+  expect-fail-message
        'insert invalid column: \'col1a\''
  |.  %:  ~(on-poke agent (bowl [run ~2012.5.5]))
          %obelisk-action
          !>([%tape %db1 my-insert])
      ==
::
:: fail on bad table name
++  test-fail-insert-08
  =|  run=@ud
  =/  my-insert  "INSERT INTO db1..my-table-2 (col1, col2, col3) ".
                 "VALUES ('cord',~nomryg-nilref,20) ('Default',Default, 0)"
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
                "(col1 @t, col2 @p, col3 @ud) ".
                "PRIMARY KEY CLUSTERED (col1)"
    ==
  =.  run  +(run)
  ::
  %+  expect-fail-message
        'table [%dbo %my-table-2] does not exist'
  |.  %:  ~(on-poke agent (bowl [run ~2012.5.5]))
          %obelisk-action
          !>([%tape %db1 my-insert])
      ==
::
:: fail on bad namespace name
++  test-fail-insert-09
  =|  run=@ud
  =/  my-insert  "INSERT INTO db1.ns1.my-table (col1, col2, col3) ".
                 "VALUES ('cord',~nomryg-nilref,20) ('Default',Default, 0)"
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
                "(col1 @t, col2 @p, col3 @ud) ".
                "PRIMARY KEY CLUSTERED (col1)"
    ==
  =.  run  +(run)
  ::
  %+  expect-fail-message
        'table [%ns1 %my-table] does not exist'
  |.  %:  ~(on-poke agent (bowl [run ~2012.5.5]))
          %obelisk-action
          !>([%tape %db1 my-insert])
      ==
::
:: fail on bad AS OF data time
++  test-fail-insert-10
  =|  run=@ud
  =/  my-insert-1  "INSERT INTO db1..my-table (col1, col2, col3) ".
                   "VALUES ('cord',~nomryg-nilref,20) ('Default',Default, 0) "
  =/  my-insert-2  "INSERT INTO db1..my-table (col1, col2, col3) ".
                   "VALUES ('cord2',~nomryg-nilref,20) ('Default2',Default, 0) ".
                   "AS OF ~2012.5.1"
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
                "(col1 @t, col2 @p, col3 @ud) ".
                "PRIMARY KEY CLUSTERED (col1)"
    ==
  =.  run  +(run)
  =^  mov3  agent
    %:  ~(on-poke agent (bowl [run ~2012.5.2]))
        %obelisk-action
        !>([%tape %db1 my-insert-1])
    ==
  =.  run  +(run)
  ::
  %+  expect-fail-message
        'insert into table %my-table as-of schema time out of order'
  |.  %:  ~(on-poke agent (bowl [run ~2012.5.5]))
          %obelisk-action
          !>([%tape %db1 my-insert-2])
      ==
::
:: fail on bad AS OF schema time
++  test-fail-insert-11
  =|  run=@ud
  =/  my-insert  "INSERT INTO db1..my-table (col1, col2, col3) ".
                 "VALUES ('cord',~nomryg-nilref,20) ('Default',Default, 0) ".
                 "AS OF ~2012.5.1"
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
                "(col1 @t, col2 @p, col3 @ud) ".
                "PRIMARY KEY CLUSTERED (col1)"
    ==
  =.  run  +(run)
  ::
  %+  expect-fail-message
        'insert into table %my-table as-of schema time out of order'
  |.  %:  ~(on-poke agent (bowl [run ~2012.5.5]))
          %obelisk-action
          !>([%tape %db1 my-insert])
      ==
::
:: successful AS OF insert followed by fail on data time
++  test-fail-insert-12
  =|  run=@ud
  =/  my-insert-1  "INSERT INTO db1..my-table (col1, col2, col3) ".
                   "VALUES ('cord',~nomryg-nilref,20) ('Default',Default, 0) ".
                   "AS OF ~2012.5.5"
  =/  my-insert-2  "INSERT INTO db1..my-table (col1, col2, col3) ".
                   "VALUES ('cord2',~nomryg-nilref,20) ('Default2',Default, 0) "
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
                "(col1 @t, col2 @p, col3 @ud) ".
                "PRIMARY KEY CLUSTERED (col1)"
    ==
  =.  run  +(run)
  =^  mov3  agent
    %:  ~(on-poke agent (bowl [run ~2012.5.2]))
        %obelisk-action
        !>([%tape %db1 my-insert-1])
    ==
  =.  run  +(run)
  ::
  %+  expect-fail-message
        'insert into table %my-table as-of data time out of order'
  |.  %:  ~(on-poke agent (bowl [run ~2012.5.5]))
          %obelisk-action
          !>([%tape %db1 my-insert-2])
      ==
::
::  fail on time,  insert = schema
++  test-fail-insert-13
  =|  run=@ud
  =^  mov1  agent
    %:  ~(on-poke agent (bowl [run ~2000.1.1]))
        %obelisk-action
        !>([%tape-create-db "CREATE DATABASE db1"])
    ==
  =.  run  +(run)
  =^  mov2  agent
    %:  ~(on-poke agent (bowl [run ~2000.1.2]))
        %obelisk-action
        !>  :+  %tape
                %db1
                "CREATE TABLE db1..my-table (col1 @t) PRIMARY KEY (col1) ".
                "AS OF ~2023.7.9..22.35.35..7e90"
    ==
  =.  run  +(run)
  =^  mov3  agent
    %:  ~(on-poke agent (bowl [run ~2000.1.3]))
        %obelisk-action
        !>([%tape %db1 "CREATE NAMESPACE ns1 as of ~2023.7.9..22.35.36..7e90"])
    ==
  =.  run  +(run)
  ::
  %+  expect-fail-message
        'insert into table %my-table as-of schema time out of order'
  |.  %:  ~(on-poke agent (bowl [run ~2000.1.2]))
      %obelisk-action
      !>  :+  %tape
              %db1
              "INSERT INTO db1..my-table (col1) VALUES ('cord') ".
              "AS OF ~2023.7.9..22.35.36..7e90"
    ==
::
::  fail on time,  insert < schema
++  test-fail-insert-14
  =|  run=@ud
  =^  mov1  agent
    %:  ~(on-poke agent (bowl [run ~2000.1.1]))
        %obelisk-action
        !>([%tape-create-db "CREATE DATABASE db1"])
    ==
  =.  run  +(run)
  =^  mov2  agent
    %:  ~(on-poke agent (bowl [run ~2000.1.2]))
        %obelisk-action
        !>  :+  %tape
                %db1
                "CREATE TABLE db1..my-table (col1 @t) PRIMARY KEY (col1) ".
                "AS OF ~2023.7.9..22.35.34..7e90"
    ==
  =.  run  +(run)
  =^  mov3  agent
    %:  ~(on-poke agent (bowl [run ~2000.1.3]))
        %obelisk-action
        !>([%tape %db1 "CREATE NAMESPACE ns1 as of ~2023.7.9..22.35.36..7e90"])
    ==
  =.  run  +(run)
  ::
  %+  expect-fail-message
        'insert into table %my-table as-of schema time out of order'
  |.  %:  ~(on-poke agent (bowl [run ~2000.1.2]))
      %obelisk-action
      !>  :+  %tape
              %db1
              "INSERT INTO db1..my-table (col1) VALUES ('cord') ".
              "AS OF ~2023.7.9..22.35.35..7e90"
    ==
::
::  fail on time,  insert = data
++  test-fail-insert-15
  =|  run=@ud
  =^  mov1  agent
    %:  ~(on-poke agent (bowl [run ~2000.1.1]))
        %obelisk-action
        !>([%tape-create-db "CREATE DATABASE db1"])
    ==
  =.  run  +(run)
  =^  mov2  agent
    %:  ~(on-poke agent (bowl [run ~2000.1.2]))
        %obelisk-action
        !>  :+  %tape
                %db1
                "CREATE TABLE db1..my-table (col1 @t) PRIMARY KEY (col1) ".
                "AS OF ~2023.7.9..22.35.34..7e90"
    ==
  =.  run  +(run)
  =^  mov3  agent
    %:  ~(on-poke agent (bowl [run ~2000.1.3]))
        %obelisk-action
        !>  :+  %tape
                %db1
                "INSERT INTO db1..my-table (col1) VALUES ('cord') ".
                "AS OF ~2023.7.9..22.35.35..7e90"
    ==
  =.  run  +(run)
  ::
  %+  expect-fail-message
        'insert into table %my-table as-of data time out of order'
  |.  %:  ~(on-poke agent (bowl [run ~2000.1.2]))
      %obelisk-action
      !>  :+  %tape
              %db1
              "INSERT INTO db1..my-table (col1) VALUES ('foo') ".
              "AS OF ~2023.7.9..22.35.35..7e90"
    ==
::
::  fail on time,  insert < data
++  test-fail-insert-16
  =|  run=@ud
  =^  mov1  agent
    %:  ~(on-poke agent (bowl [run ~2000.1.1]))
        %obelisk-action
        !>([%tape-create-db "CREATE DATABASE db1"])
    ==
  =.  run  +(run)
  =^  mov2  agent
    %:  ~(on-poke agent (bowl [run ~2000.1.2]))
        %obelisk-action
        !>  :+  %tape
                %db1
                "CREATE TABLE db1..my-table (col1 @t) PRIMARY KEY (col1) ".
                "AS OF ~2023.7.9..22.35.33..7e90"
    ==
  =.  run  +(run)
  =^  mov3  agent
    %:  ~(on-poke agent (bowl [run ~2000.1.3]))
        %obelisk-action
        !>  :+  %tape
                %db1
                "INSERT INTO db1..my-table (col1) VALUES ('cord') ".
                "AS OF ~2023.7.9..22.35.35..7e90"
    ==
  =.  run  +(run)
  ::
  %+  expect-fail-message
        'insert into table %my-table as-of data time out of order'
  |.  %:  ~(on-poke agent (bowl [run ~2000.1.2]))
      %obelisk-action
      !>  :+  %tape
              %db1
              "INSERT INTO db1..my-table (col1) VALUES ('foo') ".
              "AS OF ~2023.7.9..22.35.34..7e90"
    ==
::
::  fail on changing state after select in script
++  test-fail-insert-17
  =|  run=@ud
  =^  mov1  agent
    %:  ~(on-poke agent (bowl [run ~2000.1.1]))
        %obelisk-action
        !>([%tape-create-db "CREATE DATABASE db1"])
    ==
  =.  run  +(run)
  ::
  %+  expect-fail-message
        'insert state change after query in script'
  |.  %:  ~(on-poke agent (bowl [run ~2000.1.2]))
      %obelisk-action
      !>  :+  %tape
              %db1
              "CREATE TABLE db1..my-table (col1 @t) PRIMARY KEY (col1); ".
              "SELECT 0;".
              "INSERT INTO db1..my-table (col1) VALUES ('cord') "
    ==

--