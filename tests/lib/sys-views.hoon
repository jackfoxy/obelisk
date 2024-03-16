::  Demonstrate unit testing on a Gall agent with %obelisk.
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
:: system views
++  test-sys-sys-databases
  =|  run=@ud
  =/  col-row  :~  [%database %tas]
                  [%sys-agent %tas]
                  [%sys-tmsp %da]
                  [%data-ship %p]
                  [%data-agent %tas]
                  [%data-tmsp %da]
                ==
  =/  row1  `(list @)`~[%db1 '/test-agent' ~2000.1.1 0 '/test-agent' ~2000.1.1]
  =/  row2  `(list @)`~[%db1 '/test-agent' ~2000.1.2 0 '/test-agent' ~2000.1.2]
  =/  row3  `(list @)`~[%db1 '/test-agent' ~2000.1.2 0 '/test-agent' ~2000.1.3]
  =/  row4  `(list @)`~[%db2 '/test-agent' ~2000.1.4 0 '/test-agent' ~2000.1.4]
  =/  row5  `(list @)`~[%db2 '/test-agent' ~2000.1.5 0 '/test-agent' ~2000.1.5]
  =/  expected  :~  %results
                    :^  %result-set
                        'sys.sys.databases'
                        (limo col-row)
                        (limo ~[row1 row2 row3 row4 row5])
                ==
  =/  cmd
    :^  %drop-table
        :*  %qualified-object
            ship=~
            database='db1'
            namespace='dbo'
            name='my-table'
        ==
        %.y
        ~
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
                "CREATE TABLE db1..my-table (col1 @t) PRIMARY KEY (col1)"
    ==
  =.  run  +(run)
  =^  mov3  agent  
    %:  ~(on-poke agent (bowl [run ~2000.1.3]))
        %obelisk-action
        !>([%tape %db1 "INSERT INTO db1..my-table (col1) VALUES ('cord')"])
    ==
  =.  run  +(run)
  =^  mov4  agent  
    %:  ~(on-poke agent (bowl [run ~2000.1.4]))
        %obelisk-action
        !>([%tape-create-db "CREATE DATABASE db2"])
    ==
  =.  run  +(run)
  =^  mov5  agent  
    %:  ~(on-poke agent (bowl [run ~2000.1.5]))
        %obelisk-action
        !>  :+  %tape
                %db1
                "CREATE TABLE db2..my-table (col1 @t) PRIMARY KEY (col1)"
    ==
  =.  run  +(run)
  =^  mov6  agent  
    %:  ~(on-poke agent (bowl [run ~2000.1.5]))
        %obelisk-action
        !>([%tape %db1 "FROM sys.sys.databases SELECT *"])
    ==
  %+  expect-eq
    !>  expected
    !>  ->+>+>-.mov6
::
++  test-sys-tables
  =|  run=@ud
  =/  col-row  :~  [%namespace %tas]
                   [%name %tas]
                   [%ship %p]
                   [%agent %tas]
                   [%tmsp %da]
                   [%row-count %ud]
                   [%clustered %f]
                   [%key-ordinal %ud]
                   [%key %tas]
                   [%key-ascending %f]
                   [%col-ordinal %ud]
                   [%col-name %tas]
                   [%col-type %tas]
                   ==
  =/  row1  ~[%dbo %my-table 0 '/test-agent' ~2000.1.3 1 0 1 %col1 0 1 %col1 %t]
  =/  row2  ~[%dbo %my-table 0 '/test-agent' ~2000.1.3 1 0 1 %col1 0 2 %col2 %t]
  =/  row3  ~[%dbo %my-table 0 '/test-agent' ~2000.1.3 1 0 2 %col2 1 1 %col1 %t]
  =/  row4  ~[%dbo %my-table 0 '/test-agent' ~2000.1.3 1 0 2 %col2 1 2 %col2 %t]
  =/  row5  :~  %dbo
                %my-table-2
                0
                '/test-agent'
                ~2000.1.4
                0
                0
                1
                %col1
                1
                1
                %col1
                %p
              ==
  =/  row6  :~  %dbo
                %my-table-2
                0
                '/test-agent'
                ~2000.1.4
                0
                0
                1
                %col1
                1
                2
                %col2
                %t
              ==
  =/  row7  :~  %dbo
                %my-table-2
                0
                '/test-agent'
                ~2000.1.4
                0
                0
                2
                %col2
                0
                1
                %col1
                %p
              ==
  =/  row8  :~  %dbo
                %my-table-2
                0
                '/test-agent'
                ~2000.1.4
                0
                0
                2
                %col2
                0
                2
                %col2
                %t
              ==
  =/  row9  :~  %dbo
                %my-table-3
                0
                '/test-agent'
                ~2000.1.4
                0
                0
                1
                %col1
                0
                1
                %col1
                %p
              ==
  =/  row10  :~  %dbo
                %my-table-3
                0
                '/test-agent'
                ~2000.1.4
                0
                0
                1
                %col1
                0
                2
                %col2
                %t
              ==
  =/  row11  :~  %dbo
                %my-table-3
                0
                '/test-agent'
                ~2000.1.4
                0
                0
                1
                %col1
                0
                3
                %col3
                %ud
              ==
  =/  row12  :~  %dbo
                %my-table-4
                0
                '/test-agent'
                ~2000.1.6
                0
                0
                1
                %col1
                0
                1
                %col1
                %p
              ==
  =/  row13  :~  %dbo
                %my-table-4
                0
                '/test-agent'
                ~2000.1.6
                0
                0
                1
                %col1
                0
                2
                %col2
                %t
              ==
  =/  row14  :~  %dbo
                %my-table-4
                0
                '/test-agent'
                ~2000.1.6
                0
                0
                1
                %col1
                0
                3
                %col3
                %ud
              ==
  =/  row15  :~  %dbo
                %my-table-4
                0
                '/test-agent'
                ~2000.1.6
                0
                0
                2
                %col3
                0
                1
                %col1
                %p
              ==
  =/  row16  :~  %dbo
                %my-table-4
                0
                '/test-agent'
                ~2000.1.6
                0
                0
                2
                %col3
                0
                2
                %col2
                %t
              ==
  =/  row17  :~  %dbo
                %my-table-4
                0
                '/test-agent'
                ~2000.1.6
                0
                0
                2
                %col3
                0
                3
                %col3
                %ud
              ==
  =/  row18  :~  %ref
                %my-table-4
                0
                '/test-agent'
                ~2000.1.7
                0
                0
                1
                %col1
                0
                1
                %col1
                %p
              ==
  =/  row19  :~  %ref
                %my-table-4
                0
                '/test-agent'
                ~2000.1.7
                0
                0
                1
                %col1
                0
                2
                %col2
                %t
              ==
  =/  row20  :~  %ref
                %my-table-4
                0
                '/test-agent'
                ~2000.1.7
                0
                0
                1
                %col1
                0
                3
                %col3
                %ud
              ==
  =/  row21  :~  %ref
                %my-table-4
                0
                '/test-agent'
                ~2000.1.7
                0
                0
                2
                %col3
                0
                1
                %col1
                %p
              ==
  =/  row22  :~  %ref
                %my-table-4
                0
                '/test-agent'
                ~2000.1.7
                0
                0
                2
                %col3
                0
                2
                %col2
                %t
              ==
  =/  row23  :~  %ref
                %my-table-4
                0
                '/test-agent'
                ~2000.1.7
                0
                0
                2
                %col3
                0
                3
                %col3
                %ud
              ==
  =/  expected  :~  %results
                    :^  %result-set
                        ~.db1.sys.tables
                        (limo col-row)
                        %-  limo  :~  `(list @)`row1
                                      `(list @)`row2
                                      `(list @)`row3
                                      `(list @)`row4
                                      `(list @)`row5
                                      `(list @)`row6
                                      `(list @)`row7
                                      `(list @)`row8
                                      `(list @)`row9
                                      `(list @)`row10
                                      `(list @)`row11
                                      `(list @)`row12
                                      `(list @)`row13
                                      `(list @)`row14
                                      `(list @)`row15
                                      `(list @)`row16
                                      `(list @)`row17
                                      `(list @)`row18
                                      `(list @)`row19
                                      `(list @)`row20
                                      `(list @)`row21
                                      `(list @)`row22
                                      `(list @)`row23
                                      ==
                ==
  =/  cmd
    :^  %drop-table
        :*  %qualified-object
            ship=~
            database='db1'
            namespace='dbo'
            name='my-table'
        ==
        %.y
        ~
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
                "CREATE TABLE db1..my-table (col1 @t, col2 @t) ".
                "PRIMARY KEY (col1, col2 DESC)"
    ==
  =.  run  +(run)
  =^  mov3  agent  
    %:  ~(on-poke agent (bowl [run ~2000.1.3]))
        %obelisk-action
        !>  :+  %tape
                %db1
                "INSERT INTO db1..my-table (col1, col2) ".
                "VALUES ('cord', 'cord2')"
    ==
  =.  run  +(run)
  =^  mov4  agent  
    %:  ~(on-poke agent (bowl [run ~2000.1.4]))
        %obelisk-action
        !>  :+  %tape
                %db1
                "CREATE TABLE db1..my-table-2 (col1 @p, col2 @t) ".
                "PRIMARY KEY (col1 desc, col2); ".
                "CREATE TABLE db1..my-table-3 (col1 @p, col2 @t, col3 @ud) ".
                "PRIMARY KEY (col1)"
    ==
  =.  run  +(run)
  =^  mov5  agent  
    %:  ~(on-poke agent (bowl [run ~2000.1.5]))
        %obelisk-action
        !>([%tape %db1 "CREATE NAMESPACE ref"])
    ==
  =.  run  +(run)
  =^  mov6  agent  
    %:  ~(on-poke agent (bowl [run ~2000.1.6]))
        %obelisk-action
        !>  :+  %tape
                %db1
                "CREATE TABLE db1..my-table-4 (col1 @p, col2 @t, col3 @ud) ".
                "PRIMARY KEY (col1, col3)"
    ==
  =.  run  +(run)
  =^  mov7  agent  
    %:  ~(on-poke agent (bowl [run ~2000.1.7]))
        %obelisk-action
        !>  :+  %tape
                %db1
                "CREATE TABLE db1.ref.my-table-4 (col1 @p, col2 @t, col3 @ud) ".
                "PRIMARY KEY (col1, col3)"
    ==
  =.  run  +(run)
  =^  mov8  agent  
    %:  ~(on-poke agent (bowl [run ~2000.1.8]))
        %obelisk-action
        !>([%tape %db1 "FROM sys.tables SELECT *"])
    ==
  %+  expect-eq
    !>  expected
    !>  ->+>+>-.mov8
::
++  test-sys-columns
  =|  run=@ud
  =/  col-row  :~  [%namespace %tas]
                   [%name %tas]
                   [%col-ordinal %ud]
                   [%col-name %tas]
                   [%col-type %tas]
                ==
  =/  row1   `(list @)`~[%dbo %my-table-2 1 %col1 %p]
  =/  row2   `(list @)`~[%dbo %my-table-2 2 %col2 %t]
  =/  row3   `(list @)`~[%dbo %my-table-3 1 %col1 %p]
  =/  row4   `(list @)`~[%dbo %my-table-3 2 %col2 %t]
  =/  row5   `(list @)`~[%dbo %my-table-3 3 %col3 %ud]
  =/  row6   `(list @)`~[%dbo %my-table-4 1 %col1 %p]
  =/  row7   `(list @)`~[%dbo %my-table-4 2 %col2 %t]
  =/  row8   `(list @)`~[%dbo %my-table-4 3 %col3 %ud]
  =/  row9   `(list @)`~[%ref %my-table 1 %col1 %t]
  =/  row10  `(list @)`~[%ref %my-table 2 %col2 %t]
  =/  expected  :~  %results
                    :^  %result-set
                        ~.db1.sys.columns
                        (limo col-row)
                        %-  limo  :~  row1
                                      row2
                                      row3
                                      row4
                                      row5
                                      row6
                                      row7
                                      row8
                                      row9
                                      row10
                                      ==
                ==
  =/  cmd  :^  %drop-table
              :*  %qualified-object
                  ship=~
                  database='db1'
                  namespace='dbo'
                  name='my-table'
              ==
              %.y
              ~
  =^  mov1  agent  
    %:  ~(on-poke agent (bowl [run ~2000.1.1]))
        %obelisk-action
        !>([%tape-create-db "CREATE DATABASE db1"])
    ==
  =.  run  +(run)
  =^  mov2  agent  
    %:  ~(on-poke agent (bowl [run ~2000.1.2]))
        %obelisk-action
        !>([%tape %db1 "CREATE NAMESPACE db1.ref"])
    ==
  =.  run  +(run)
  =^  mov3  agent  
    %:  ~(on-poke agent (bowl [run ~2000.1.3]))
        %obelisk-action
        !>  :+  %tape
                %db1
                "CREATE TABLE db1.ref.my-table (col1 @t, col2 @t) ".
                "PRIMARY KEY (col1, col2 DESC)"
    ==
  =.  run  +(run)
  =^  mov4  agent  
    %:  ~(on-poke agent (bowl [run ~2000.1.4]))
        %obelisk-action
        !>  :+  %tape
                %db1
                "CREATE TABLE db1..my-table-2 (col1 @p, col2 @t) ".
                "PRIMARY KEY (col1 desc, col2); ".
                "CREATE TABLE db1..my-table-3 (col1 @p, col2 @t, col3 @ud) ".
                "PRIMARY KEY (col1)"
    ==
  =.  run  +(run)
  =^  mov5  agent  
    %:  ~(on-poke agent (bowl [run ~2000.1.5]))
        %obelisk-action
        !>  :+  %tape
                %db1
                "CREATE TABLE db1..my-table-4 (col1 @p, col2 @t, col3 @ud) ".
                "PRIMARY KEY (col1, col3)"
    ==
  =.  run  +(run)
  =^  mov6  agent  
    %:  ~(on-poke agent (bowl [run ~2000.1.6]))
        %obelisk-action
        !>([%tape %db1 "FROM sys.columns SELECT *"])
    ==
  %+  expect-eq
    !>  expected
    !>  ->+>+>-.mov6
::
++  test-sys-log
  =|  run=@ud
  =/  col-row  ~[[%tmsp %da] [%agent %tas] [%component %tas] [%name %tas]]
  =/  row1  ~[~2000.1.7 '/test-agent' %ref %my-table-4]
  =/  row2  ~[~2000.1.6 '/test-agent' %dbo %my-table-4]
  =/  row3  ~[~2000.1.5 '/test-agent' %namespace %ref]
  =/  row4  ~[~2000.1.4 '/test-agent' %dbo %my-table-2]
  =/  row5  ~[~2000.1.4 '/test-agent' %dbo %my-table-3]
  =/  row6  ~[~2000.1.2 '/test-agent' %dbo %my-table]
  =/  row7  ~[~2000.1.1 '/test-agent' %namespace %dbo]
  =/  row8  ~[~2000.1.1 '/test-agent' %namespace %sys]
  =/  expected  :~  %results
                    :^  %result-set
                        ~.db1.sys.sys-log
                        (limo col-row)
                        %-  limo  :~  `(list @)`row1
                                      `(list @)`row2
                                      `(list @)`row3
                                      `(list @)`row4
                                      `(list @)`row5
                                      `(list @)`row6
                                      `(list @)`row7
                                      `(list @)`row8
                                      ==
                ==
  =/  cmd
    :^  %drop-table
        :*  %qualified-object
            ship=~
            database='db1'
            namespace='dbo'
            name='my-table'
        ==
        %.y
        ~
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
                "CREATE TABLE db1..my-table (col1 @t, col2 @t) ".
                "PRIMARY KEY (col1, col2 DESC)"
    ==
  =.  run  +(run)
  =^  mov3  agent  
    %:  ~(on-poke agent (bowl [run ~2000.1.4]))
        %obelisk-action
        !>  :+  %tape
                %db1
                "CREATE TABLE db1..my-table-2 (col1 @p, col2 @t) ".
                "PRIMARY KEY (col1 desc, col2); ".
                "CREATE TABLE db1..my-table-3 (col1 @p, col2 @t, col3 @ud) ".
                "PRIMARY KEY (col1)"
    ==
  =.  run  +(run)
  =^  mov4  agent  
    %:  ~(on-poke agent (bowl [run ~2000.1.5]))
        %obelisk-action
        !>([%tape %db1 "CREATE NAMESPACE ref"])
    ==
  =.  run  +(run)
  =^  mov5  agent  
    %:  ~(on-poke agent (bowl [run ~2000.1.6]))
        %obelisk-action
        !>  :+  %tape
                %db1
                "CREATE TABLE db1..my-table-4 (col1 @p, col2 @t, col3 @ud) ".
                "PRIMARY KEY (col1, col3)"
    ==
  =.  run  +(run)
  =^  mov6  agent  
    %:  ~(on-poke agent (bowl [run ~2000.1.7]))
        %obelisk-action
        !>  :+  %tape
                %db1
                "CREATE TABLE db1.ref.my-table-4 (col1 @p, col2 @t, col3 @ud) ".
                "PRIMARY KEY (col1, col3)"
    ==
  =.  run  +(run)
  =^  mov7  agent  
    %:  ~(on-poke agent (bowl [run ~2000.1.8]))
        %obelisk-action
        !>([%tape %db1 "FROM sys.sys-log SELECT *"])
    ==
  %+  expect-eq
    !>  expected
    !>  ->+>+>-.mov7
::
++  test-data-log
  =|  run=@ud
  =/  col-row  :~  [%tmsp %da]
                   [%ship %p]
                   [%agent %tas]
                   [%namespace %tas]
                   [%table %tas]
                ==
  =/  row1  ~[~2000.1.10 0 '/test-agent' %ref %my-table-4]
  =/  row2  ~[~2000.1.9 0 '/test-agent' %ref %my-table-4]
  =/  row3  ~[~2000.1.8 0 '/test-agent' %dbo %my-table-4]
  =/  row4  ~[~2000.1.7 0 '/test-agent' %dbo %my-table-4]
  =/  row5  ~[~2000.1.5 0 '/test-agent' %dbo %my-table-2]
  =/  row6  ~[~2000.1.4 0 '/test-agent' %dbo %my-table-2]
  =/  row7  ~[~2000.1.4 0 '/test-agent' %dbo %my-table-3]
  =/  row8  ~[~2000.1.3 0 '/test-agent' %dbo %my-table]
  =/  row9  ~[~2000.1.2 0 '/test-agent' %dbo %my-table]
  =/  expected  :~  %results
                    :^  %result-set
                        ~.db1.sys.data-log
                        (limo col-row)
                        %-  limo  :~  `(list @)`row1
                                      `(list @)`row2
                                      `(list @)`row3
                                      `(list @)`row4
                                      `(list @)`row5
                                      `(list @)`row6
                                      `(list @)`row7
                                      `(list @)`row8
                                      `(list @)`row9
                                      ==
                ==
  =/  cmd
    :^  %drop-table
        :*  %qualified-object
            ship=~
            database='db1'
            namespace='dbo'
            name='my-table'
        ==
        %.y
        ~
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
                "CREATE TABLE db1..my-table (col1 @t, col2 @t) ".
                "PRIMARY KEY (col1, col2 DESC)"
    ==
    =.  run  +(run)
  =^  mov3  agent  
    %:  ~(on-poke agent (bowl [run ~2000.1.3]))
        %obelisk-action
        !>  :+  %tape
                %db1
                "INSERT INTO db1..my-table (col1, col2) ".
                "VALUES ('cord', 'cord2')"
    ==
  =.  run  +(run)
  =^  mov4  agent  
    %:  ~(on-poke agent (bowl [run ~2000.1.4]))
        %obelisk-action
        !>  :+  %tape
                %db1
                "CREATE TABLE db1..my-table-2 (col1 @p, col2 @t) ".
                "PRIMARY KEY (col1 desc, col2); ".
                "CREATE TABLE db1..my-table-3 (col1 @p, col2 @t, col3 @ud) ".
                "PRIMARY KEY (col1)"
    ==
    =.  run  +(run)
  =^  mov5  agent  
    %:  ~(on-poke agent (bowl [run ~2000.1.5]))
        %obelisk-action
        !>  :+  %tape
                %db1
                "INSERT INTO db1..my-table-2 (col1, col2) ".
                "VALUES (~zod, 'cord2')"
    ==
  =.  run  +(run)
  =^  mov6  agent  
    %:  ~(on-poke agent (bowl [run ~2000.1.6]))
        %obelisk-action
        !>([%tape %db1 "CREATE NAMESPACE ref"])
    ==
  =.  run  +(run)
  =^  mov7  agent  
    %:  ~(on-poke agent (bowl [run ~2000.1.7]))
        %obelisk-action
        !>  :+  %tape
                %db1
                "CREATE TABLE db1..my-table-4 (col1 @p, col2 @t, col3 @ud) ".
                "PRIMARY KEY (col1, col3)"
    ==
    =.  run  +(run)
  =^  mov8  agent  
    %:  ~(on-poke agent (bowl [run ~2000.1.8]))
        %obelisk-action
        !>  :+  %tape
                %db1
                "INSERT INTO db1..my-table-4 (col1, col2, col3) ".
                "VALUES (~zod, 'cord2', 42)"
    ==
  =.  run  +(run)
  =^  mov9  agent  
    %:  ~(on-poke agent (bowl [run ~2000.1.9]))
        %obelisk-action
        !>  :+  %tape
                %db1
                "CREATE TABLE db1.ref.my-table-4 (col1 @p, col2 @t, col3 @ud) ".
                "PRIMARY KEY (col1, col3)"
    ==
    =.  run  +(run)
  =^  mov10  agent  
    %:  ~(on-poke agent (bowl [run ~2000.1.10]))
        %obelisk-action
        !>  :+  %tape
                %db1
                "INSERT INTO db1.ref.my-table-4 (col1, col2, col3) ".
                "VALUES (~zod, 'cord2', 16)"
    ==
  =.  run  +(run)
  =^  mov11  agent  
    %:  ~(on-poke agent (bowl [run ~2000.1.1]))
        %obelisk-action
        !>([%tape %db1 "FROM sys.data-log SELECT *"])
    ==
  %+  expect-eq
    !>  expected
    !>  ->+>+>-.mov11
--