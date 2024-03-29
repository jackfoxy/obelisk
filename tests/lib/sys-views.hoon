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
  =/  row1  :-  %row 
                :~  [%database [~.tas %db1]] 
                    [%sys-agent [~.tas '/test-agent']] 
                    [%sys-tmsp [~.da ~2000.1.1]] 
                    [%data-ship [~.p 0]] 
                    [%data-agent [~.tas '/test-agent']] 
                    [%data-tmsp [~.da ~2000.1.1]]
                    ==
  =/  row2  :-  %row
                :~  [%database [~.tas %db1]] 
                    [%sys-agent [~.tas '/test-agent']]
                    [%sys-tmsp [~.da ~2000.1.2]]
                    [%data-ship [~.p 0]]
                    [%data-agent [~.tas '/test-agent']]
                    [%data-tmsp [~.da ~2000.1.2]]
                    ==
  =/  row3  :-  %row 
                :~  [%database [~.tas %db1]] 
                    [%sys-agent [~.tas '/test-agent']]
                    [%sys-tmsp [~.da ~2000.1.2]]
                    [%data-ship [~.p 0]]
                    [%data-agent [~.tas '/test-agent']]
                    [%data-tmsp [~.da ~2000.1.3]]
                    ==
  =/  row4  :-  %row 
                :~  [%database [~.tas %db2]] 
                    [%sys-agent [~.tas '/test-agent']]
                    [%sys-tmsp [~.da ~2000.1.4]]
                    [%data-ship [~.p 0]]
                    [%data-agent [~.tas '/test-agent']]
                    [%data-tmsp [~.da ~2000.1.4]]
                    ==
  =/  row5  :-  %row 
                :~  [%database [~.tas %db2]] 
                    [%sys-agent [~.tas '/test-agent']]
                    [%sys-tmsp [~.da ~2000.1.5]]
                    [%data-ship [~.p 0]]
                    [%data-agent [~.tas '/test-agent']]
                    [%data-tmsp [~.da ~2000.1.5]]
                    ==
  =/  row6  :-  %row 
                :~  [%database [~.tas %sys]] 
                    [%sys-agent [~.tas '/test-agent']]
                    [%sys-tmsp [~.da ~2000.1.1]]
                    [%data-ship [~.p 0]]
                    [%data-agent [~.tas '/test-agent']]
                    [%data-tmsp [~.da ~2000.1.1]]
                    ==
  ::
  =/  expected  :~  %results
                    :-  %result-set
                        ~[row1 row2 row3 row4 row5 row6]
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
  =/  row1  :-  %row
                :~  [%namespace [~.tas %dbo]]
                [%name [~.tas %my-table]]
                [%ship [~.p 0]]
                [%agent [~.tas '/test-agent']]
                [%tmsp [~.da ~2000.1.3]]
                [%row-count [~.ud 1]]
                [%clustered [~.f 0]]
                [%key-ordinal [~.ud 1]]
                [%key [~.tas %col1]]
                [%key-ascending [~.f 0]]
                [%col-ordinal [~.ud 1]]
                [%col-name [~.tas %col1]]
                [%col-type [~.tas %t]]
              ==
  =/  row2  :-  %row
                :~  [%namespace [~.tas %dbo]]
                [%name [~.tas %my-table]]
                [%ship [~.p 0]]
                [%agent [~.tas '/test-agent']]
                [%tmsp [~.da ~2000.1.3]]
                [%row-count [~.ud 1]]
                [%clustered [~.f 0]]
                [%key-ordinal [~.ud 1]]
                [%key [~.tas %col1]]
                [%key-ascending [~.f 0]]
                [%col-ordinal [~.ud 2]]
                [%col-name [~.tas %col2]]
                [%col-type [~.tas %t]]
              ==
  =/  row3  :-  %row
                :~  [%namespace [~.tas %dbo]]
                [%name [~.tas %my-table]]
                [%ship [~.p 0]]
                [%agent [~.tas '/test-agent']]
                [%tmsp [~.da ~2000.1.3]]
                [%row-count [~.ud 1]]
                [%clustered [~.f 0]]
                [%key-ordinal [~.ud 2]]
                [%key [~.tas %col2]]
                [%key-ascending [~.f 1]]
                [%col-ordinal [~.ud 1]]
                [%col-name [~.tas %col1]]
                [%col-type [~.tas %t]]
              ==
  =/  row4  :-  %row
                :~  [%namespace [~.tas %dbo]]
                [%name [~.tas %my-table]]
                [%ship [~.p 0]]
                [%agent [~.tas '/test-agent']]
                [%tmsp [~.da ~2000.1.3]]
                [%row-count [~.ud 1]]
                [%clustered [~.f 0]]
                [%key-ordinal [~.ud 2]]
                [%key [~.tas %col2]]
                [%key-ascending [~.f 1]]
                [%col-ordinal [~.ud 2]]
                [%col-name [~.tas %col2]]
                [%col-type [~.tas %t]]
              ==
  =/  row5  :-  %row
                :~  [%namespace [~.tas %dbo]]
                [%name [~.tas %my-table-2]]
                [%ship [~.p 0]]
                [%agent [~.tas '/test-agent']]
                [%tmsp [~.da ~2000.1.4]]
                [%row-count [~.ud 0]]
                [%clustered [~.f 0]]
                [%key-ordinal [~.ud 1]]
                [%key [~.tas %col1]]
                [%key-ascending [~.f 1]]
                [%col-ordinal [~.ud 1]]
                [%col-name [~.tas %col1]]
                [%col-type [~.tas %p]]
              ==
  =/  row6  :-  %row
                :~  [%namespace [~.tas %dbo]]
                [%name [~.tas %my-table-2]]
                [%ship [~.p 0]]
                [%agent [~.tas '/test-agent']]
                [%tmsp [~.da ~2000.1.4]]
                [%row-count [~.ud 0]]
                [%clustered [~.f 0]]
                [%key-ordinal [~.ud 1]]
                [%key [~.tas %col1]]
                [%key-ascending [~.f 1]]
                [%col-ordinal [~.ud 2]]
                [%col-name [~.tas %col2]]
                [%col-type [~.tas %t]]
              ==
  =/  row7  :-  %row
                :~  [%namespace [~.tas %dbo]]
                [%name [~.tas %my-table-2]]
                [%ship [~.p 0]]
                [%agent [~.tas '/test-agent']]
                [%tmsp [~.da ~2000.1.4]]
                [%row-count [~.ud 0]]
                [%clustered [~.f 0]]
                [%key-ordinal [~.ud 2]]
                [%key [~.tas %col2]]
                [%key-ascending [~.f 0]]
                [%col-ordinal [~.ud 1]]
                [%col-name [~.tas %col1]]
                [%col-type [~.tas %p]]
              ==
  =/  row8  :-  %row
                :~  [%namespace [~.tas %dbo]]
                [%name [~.tas %my-table-2]]
                [%ship [~.p 0]]
                [%agent [~.tas '/test-agent']]
                [%tmsp [~.da ~2000.1.4]]
                [%row-count [~.ud 0]]
                [%clustered [~.f 0]]
                [%key-ordinal [~.ud 2]]
                [%key [~.tas %col2]]
                [%key-ascending [~.f 0]]
                [%col-ordinal [~.ud 2]]
                [%col-name [~.tas %col2]]
                [%col-type [~.tas %t]]
              ==
  =/  row9  :-  %row
                :~  [%namespace [~.tas %dbo]]
                [%name [~.tas %my-table-3]]
                [%ship [~.p 0]]
                [%agent [~.tas '/test-agent']]
                [%tmsp [~.da ~2000.1.4]]
                [%row-count [~.ud 0]]
                [%clustered [~.f 0]]
                [%key-ordinal [~.ud 1]]
                [%key [~.tas %col1]]
                [%key-ascending [~.f 0]]
                [%col-ordinal [~.ud 1]]
                [%col-name [~.tas %col1]]
                [%col-type [~.tas %p]]
              ==
  =/  row10  :-  %row
                :~  [%namespace [~.tas %dbo]]
                [%name [~.tas %my-table-3]]
                [%ship [~.p 0]]
                [%agent [~.tas '/test-agent']]
                [%tmsp [~.da ~2000.1.4]]
                [%row-count [~.ud 0]]
                [%clustered [~.f 0]]
                [%key-ordinal [~.ud 1]]
                [%key [~.tas %col1]]
                [%key-ascending [~.f 0]]
                [%col-ordinal [~.ud 2]]
                [%col-name [~.tas %col2]]
                [%col-type [~.tas %t]]
              ==
  =/  row11  :-  %row
                :~  [%namespace [~.tas %dbo]]
                [%name [~.tas %my-table-3]]
                [%ship [~.p 0]]
                [%agent [~.tas '/test-agent']]
                [%tmsp [~.da ~2000.1.4]]
                [%row-count [~.ud 0]]
                [%clustered [~.f 0]]
                [%key-ordinal [~.ud 1]]
                [%key [~.tas %col1]]
                [%key-ascending [~.f 0]]
                [%col-ordinal [~.ud 3]]
                [%col-name [~.tas %col3]]
                [%col-type [~.tas %ud]]
              ==
  =/  row12  :-  %row
                :~  [%namespace [~.tas %dbo]]
                [%name [~.tas %my-table-4]]
                [%ship [~.p 0]]
                [%agent [~.tas '/test-agent']]
                [%tmsp [~.da ~2000.1.6]]
                [%row-count [~.ud 0]]
                [%clustered [~.f 0]]
                [%key-ordinal [~.ud 1]]
                [%key [~.tas %col1]]
                [%key-ascending [~.f 0]]
                [%col-ordinal [~.ud 1]]
                [%col-name [~.tas %col1]]
                [%col-type [~.tas %p]]
              ==
  =/  row13  :-  %row
                :~  [%namespace [~.tas %dbo]]
                [%name [~.tas %my-table-4]]
                [%ship [~.p 0]]
                [%agent [~.tas '/test-agent']]
                [%tmsp [~.da ~2000.1.6]]
                [%row-count [~.ud 0]]
                [%clustered [~.f 0]]
                [%key-ordinal [~.ud 1]]
                [%key [~.tas %col1]]
                [%key-ascending [~.f 0]]
                [%col-ordinal [~.ud 2]]
                [%col-name [~.tas %col2]]
                [%col-type [~.tas %t]]
              ==
  =/  row14  :-  %row
                :~  [%namespace [~.tas %dbo]]
                [%name [~.tas %my-table-4]]
                [%ship [~.p 0]]
                [%agent [~.tas '/test-agent']]
                [%tmsp [~.da ~2000.1.6]]
                [%row-count [~.ud 0]]
                [%clustered [~.f 0]]
                [%key-ordinal [~.ud 1]]
                [%key [~.tas %col1]]
                [%key-ascending [~.f 0]]
                [%col-ordinal [~.ud 3]]
                [%col-name [~.tas %col3]]
                [%col-type [~.tas %ud]]
              ==
  =/  row15  :-  %row
                :~  [%namespace [~.tas %dbo]]
                [%name [~.tas %my-table-4]]
                [%ship [~.p 0]]
                [%agent [~.tas '/test-agent']]
                [%tmsp [~.da ~2000.1.6]]
                [%row-count [~.ud 0]]
                [%clustered [~.f 0]]
                [%key-ordinal [~.ud 2]]
                [%key [~.tas %col3]]
                [%key-ascending [~.f 0]]
                [%col-ordinal [~.ud 1]]
                [%col-name [~.tas %col1]]
                [%col-type [~.tas %p]]
              ==
  =/  row16  :-  %row
                :~  [%namespace [~.tas %dbo]]
                [%name [~.tas %my-table-4]]
                [%ship [~.p 0]]
                [%agent [~.tas '/test-agent']]
                [%tmsp [~.da ~2000.1.6]]
                [%row-count [~.ud 0]]
                [%clustered [~.f 0]]
                [%key-ordinal [~.ud 2]]
                [%key [~.tas %col3]]
                [%key-ascending [~.f 0]]
                [%col-ordinal [~.ud 2]]
                [%col-name [~.tas %col2]]
                [%col-type [~.tas %t]]
              ==
  =/  row17  :-  %row
                :~  [%namespace [~.tas %dbo]]
                [%name [~.tas %my-table-4]]
                [%ship [~.p 0]]
                [%agent [~.tas '/test-agent']]
                [%tmsp [~.da ~2000.1.6]]
                [%row-count [~.ud 0]]
                [%clustered [~.f 0]]
                [%key-ordinal [~.ud 2]]
                [%key [~.tas %col3]]
                [%key-ascending [~.f 0]]
                [%col-ordinal [~.ud 3]]
                [%col-name [~.tas %col3]]
                [%col-type [~.tas %ud]]
              ==
  =/  row18  :-  %row
                :~  [%namespace [~.tas %ref]]
                [%name [~.tas %my-table-4]]
                [%ship [~.p 0]]
                [%agent [~.tas '/test-agent']]
                [%tmsp [~.da ~2000.1.7]]
                [%row-count [~.ud 0]]
                [%clustered [~.f 0]]
                [%key-ordinal [~.ud 1]]
                [%key [~.tas %col1]]
                [%key-ascending [~.f 0]]
                [%col-ordinal [~.ud 1]]
                [%col-name [~.tas %col1]]
                [%col-type [~.tas %p]]
              ==
  =/  row19  :-  %row
                :~  [%namespace [~.tas %ref]]
                [%name [~.tas %my-table-4]]
                [%ship [~.p 0]]
                [%agent [~.tas '/test-agent']]
                [%tmsp [~.da ~2000.1.7]]
                [%row-count [~.ud 0]]
                [%clustered [~.f 0]]
                [%key-ordinal [~.ud 1]]
                [%key [~.tas %col1]]
                [%key-ascending [~.f 0]]
                [%col-ordinal [~.ud 2]]
                [%col-name [~.tas %col2]]
                [%col-type [~.tas %t]]
              ==
  =/  row20  :-  %row
                :~  [%namespace [~.tas %ref]]
                [%name [~.tas %my-table-4]]
                [%ship [~.p 0]]
                [%agent [~.tas '/test-agent']]
                [%tmsp [~.da ~2000.1.7]]
                [%row-count [~.ud 0]]
                [%clustered [~.f 0]]
                [%key-ordinal [~.ud 1]]
                [%key [~.tas %col1]]
                [%key-ascending [~.f 0]]
                [%col-ordinal [~.ud 3]]
                [%col-name [~.tas %col3]]
                [%col-type [~.tas %ud]]
              ==
  =/  row21  :-  %row
                :~  [%namespace [~.tas %ref]]
                [%name [~.tas %my-table-4]]
                [%ship [~.p 0]]
                [%agent [~.tas '/test-agent']]
                [%tmsp [~.da ~2000.1.7]]
                [%row-count [~.ud 0]]
                [%clustered [~.f 0]]
                [%key-ordinal [~.ud 2]]
                [%key [~.tas %col3]]
                [%key-ascending [~.f 0]]
                [%col-ordinal [~.ud 1]]
                [%col-name [~.tas %col1]]
                [%col-type [~.tas %p]]
              ==
  =/  row22  :-  %row
                :~  [%namespace [~.tas %ref]]
                [%name [~.tas %my-table-4]]
                [%ship [~.p 0]]
                [%agent [~.tas '/test-agent']]
                [%tmsp [~.da ~2000.1.7]]
                [%row-count [~.ud 0]]
                [%clustered [~.f 0]]
                [%key-ordinal [~.ud 2]]
                [%key [~.tas %col3]]
                [%key-ascending [~.f 0]]
                [%col-ordinal [~.ud 2]]
                [%col-name [~.tas %col2]]
                [%col-type [~.tas %t]]
              ==
  =/  row23  :-  %row
                :~  [%namespace [~.tas %ref]]
                [%name [~.tas %my-table-4]]
                [%ship [~.p 0]]
                [%agent [~.tas '/test-agent']]
                [%tmsp [~.da ~2000.1.7]]
                [%row-count [~.ud 0]]
                [%clustered [~.f 0]]
                [%key-ordinal [~.ud 2]]
                [%key [~.tas %col3]]
                [%key-ascending [~.f 0]]
                [%col-ordinal [~.ud 3]]
                [%col-name [~.tas %col3]]
                [%col-type [~.tas %ud]]
              ==
  =/  expected  :~  %results
                    :-  %result-set
                        :~  row1
                            row2
                            row3
                            row4
                            row5
                            row6
                            row7
                            row8
                            row9
                            row10
                            row11
                            row12
                            row13
                            row14
                            row15
                            row16
                            row17
                            row18
                            row19
                            row20
                            row21
                            row22
                            row23
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
  =/  row1   :-  %row 
                :~  [%namespace [~.tas %dbo]]
                    [%name [~.tas %my-table-2]]
                    [%col-ordinal [~.ud 1]]
                    [%col-name [~.tas %col1]]
                    [%col-type [~.tas %p]]
                  ==
  =/  row2   :-  %row 
                :~  [%namespace [~.tas %dbo]]
                    [%name [~.tas %my-table-2]]
                    [%col-ordinal [~.ud 2]]
                    [%col-name [~.tas %col2]]
                    [%col-type [~.tas %t]]
                  ==
  =/  row3   :-  %row 
                :~  [%namespace [~.tas %dbo]]
                    [%name [~.tas %my-table-3]]
                    [%col-ordinal [~.ud 1]]
                    [%col-name [~.tas %col1]]
                    [%col-type [~.tas %p]]
                  ==
  =/  row4   :-  %row 
                :~  [%namespace [~.tas %dbo]]
                    [%name [~.tas %my-table-3]]
                    [%col-ordinal [~.ud 2]]
                    [%col-name [~.tas %col2]]
                    [%col-type [~.tas %t]]
                  ==
  =/  row5   :-  %row 
                :~  [%namespace [~.tas %dbo]]
                    [%name [~.tas %my-table-3]]
                    [%col-ordinal [~.ud 3]]
                    [%col-name [~.tas %col3]]
                    [%col-type [~.tas %ud]]
                  ==
  =/  row6   :-  %row 
                :~  [%namespace [~.tas %dbo]]
                    [%name [~.tas %my-table-4]]
                    [%col-ordinal [~.ud 1]]
                    [%col-name [~.tas %col1]]
                    [%col-type [~.tas %p]]
                  ==
  =/  row7   :-  %row 
                :~  [%namespace [~.tas %dbo]]
                    [%name [~.tas %my-table-4]]
                    [%col-ordinal [~.ud 2]]
                    [%col-name [~.tas %col2]]
                    [%col-type [~.tas %t]]
                  ==
  =/  row8   :-  %row 
                :~  [%namespace [~.tas %dbo]]
                    [%name [~.tas %my-table-4]]
                    [%col-ordinal [~.ud 3]]
                    [%col-name [~.tas %col3]]
                    [%col-type [~.tas %ud]]
                  ==
  =/  row9   :-  %row 
                :~  [%namespace [~.tas %ref]]
                    [%name [~.tas %my-table]]
                    [%col-ordinal [~.ud 1]]
                    [%col-name [~.tas %col1]]
                    [%col-type [~.tas %t]]
                  ==
  =/  row10  :-  %row 
                :~  [%namespace [~.tas %ref]]
                    [%name [~.tas %my-table]]
                    [%col-ordinal [~.ud 2]]
                    [%col-name [~.tas %col2]]
                    [%col-type [~.tas %t]]
                ==
  =/  expected  :~  %results
                    :-  %result-set
                        ~[row1 row2 row3 row4 row5 row6 row7 row8 row9 row10]
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
  =/  row1   :-  %row 
                :~  [%tmsp [~.da ~2000.1.7]]
                    [%agent [~.tas '/test-agent']]
                    [%component [~.tas %ref]]
                    [%name [~.tas %my-table-4]]
                    ==
  =/  row2   :-  %row 
                :~  [%tmsp [~.da ~2000.1.6]]
                    [%agent [~.tas '/test-agent']]
                    [%component [~.tas %dbo]]
                    [%name [~.tas %my-table-4]]
                    ==
  =/  row3   :-  %row 
                :~  [%tmsp [~.da ~2000.1.5]]
                    [%agent [~.tas '/test-agent']]
                    [%component [~.tas %namespace]]
                    [%name [~.tas %ref]]
                    ==
  =/  row4    :-  %row 
                :~  [%tmsp [~.da ~2000.1.4]]
                    [%agent [~.tas '/test-agent']]
                    [%component [~.tas %dbo]]
                    [%name [~.tas %my-table-2]]
                    ==
  =/  row5   :-  %row 
                :~  [%tmsp [~.da ~2000.1.4]]
                    [%agent [~.tas '/test-agent']]
                    [%component [~.tas %dbo]]
                    [%name [~.tas %my-table-3]]
                    ==
  =/  row6   :-  %row 
                :~  [%tmsp [~.da ~2000.1.2]]
                    [%agent [~.tas '/test-agent']]
                    [%component [~.tas %dbo]]
                    [%name [~.tas %my-table]]
                    ==
  =/  row7   :-  %row 
                :~  [%tmsp [~.da ~2000.1.1]]
                    [%agent [~.tas '/test-agent']]
                    [%component [~.tas %namespace]]
                    [%name [~.tas %dbo]]
                    ==
  =/  row8   :-  %row 
                :~  [%tmsp [~.da ~2000.1.1]]
                    [%agent [~.tas '/test-agent']]
                    [%component [~.tas %namespace]]
                    [%name [~.tas %sys]]
                    ==
  =/  expected  :~  %results
                    :-  %result-set
                        ~[row1 row2 row3 row4 row5 row6 row7 row8]
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
  =/  row1  :-  %row 
                :~  [%tmsp [~.da ~2000.1.10]]
                    [%ship [~.p 0]]
                    [%agent [~.tas '/test-agent']]
                    [%namespace [~.tas %ref]]
                    [%table [~.tas %my-table-4]]
                    ==
  =/  row2  :-  %row 
                    :~  [%tmsp [~.da ~2000.1.9]]
                    [%ship [~.p 0]]
                    [%agent [~.tas '/test-agent']]
                    [%namespace [~.tas %ref]]
                    [%table [~.tas %my-table-4]]
                    ==
  =/  row3  :-  %row 
                :~  [%tmsp [~.da ~2000.1.8]]
                    [%ship [~.p 0]]
                    [%agent [~.tas '/test-agent']]
                    [%namespace [~.tas %dbo]]
                    [%table [~.tas %my-table-4]]
                    ==
  =/  row4  :-  %row 
                :~  [%tmsp [~.da ~2000.1.7]]
                    [%ship [~.p 0]]
                    [%agent [~.tas '/test-agent']]
                    [%namespace [~.tas %dbo]]
                    [%table [~.tas %my-table-4]]
                    ==
  =/  row5  :-  %row 
                :~  [%tmsp [~.da ~2000.1.5]]
                    [%ship [~.p 0]]
                    [%agent [~.tas '/test-agent']]
                    [%namespace [~.tas %dbo]]
                    [%table [~.tas %my-table-2]]
                    ==
  =/  row6  :-  %row 
                :~  [%tmsp [~.da ~2000.1.4]]
                    [%ship [~.p 0]]
                    [%agent [~.tas '/test-agent']]
                    [%namespace [~.tas %dbo]]
                    [%table [~.tas %my-table-2]]
                    ==
  =/  row7  :-  %row 
                :~  [%tmsp [~.da ~2000.1.4]]
                    [%ship [~.p 0]]
                    [%agent [~.tas '/test-agent']]
                    [%namespace [~.tas %dbo]]
                    [%table [~.tas %my-table-3]]
                    ==
  =/  row8  :-  %row 
                :~  [%tmsp [~.da ~2000.1.3]]
                    [%ship [~.p 0]]
                    [%agent [~.tas '/test-agent']]
                    [%namespace [~.tas %dbo]]
                    [%table [~.tas %my-table]]
                    ==
  =/  row9  :-  %row 
                :~  [%tmsp [~.da ~2000.1.2]]
                    [%ship [~.p 0]]
                    [%agent [~.tas '/test-agent']]
                    [%namespace [~.tas %dbo]]
                    [%table [~.tas %my-table]]
                    ==
  =/  expected  :~  %results
                    :-  %result-set
                        ~[row1 row2 row3 row4 row5 row6 row7 row8 row9]
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