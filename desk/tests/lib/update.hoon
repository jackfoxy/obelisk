::  Demonstrate unit testing queries on a Gall agent with %obelisk.
::
/-  ast, *obelisk
/+  *test
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
::
--
|%
::
++  create-table  "CREATE TABLE db1..my-table ".
                  "(col0 @da, col1 @t, col2 @p, col3 @ud, col4 @da) ".
                  "PRIMARY KEY (col0, col2);"

++  insert-table  "INSERT INTO db1..my-table (col0, col1, col2, col3, col4) ".
                  "VALUES (~2010.5.3, 'cord',~nomryg-nilref,20,Default) ".
                  "       (~2010.5.31, 'Default',Default, 0,Default) ".
                  "       (~2010.5.31, 'Default',~nec, 0,Default) ".
                  "       (~2010.5.31, 'Default',~bus, 0,Default); "
::
::  [@ud tape tape tape cmd-result cmd-result] -> 
++  execut-112
  |=  $:  run=@ud
          init=tape
          action=tape
          resolve=tape
          expect1=cmd-result
          expect2=cmd-result
          ==
  =^  mov1  agent
  %+  ~(on-poke agent (bowl [run ~2012.4.30]))
      %obelisk-action
      !>  [%tape2 %db1 init]                        :: <==
  =^  mov2  agent
  %+  ~(on-poke agent (bowl [run ~2012.5.1]))
      %obelisk-action
      !>  [%tape2 %db1 action]                      :: <==
  =^  mov3  agent
  %+  ~(on-poke agent (bowl [run ~2012.5.3]))
      %obelisk-action
      !>  [%tape2 %db1 resolve]                     :: <==
  ::
  %+  weld  (eval-results expect1 ;;(cmd-result ->+>+>+<.mov2))
            (eval-results expect2 ;;(cmd-result ->+>+>+<.mov3))
::
::
++  execut-222
  |=  $:  run=@ud
          init=tape
          action-1=tape
          action-2=tape
          resolve-1=tape
          resolve-2=tape
          expect1=cmd-result
          expect2=cmd-result
          ==
  =^  mov1  agent
  %+  ~(on-poke agent (bowl [run ~2012.4.30]))
      %obelisk-action
      !>  [%tape2 %db1 init]                        :: <==
  =^  mov2  agent
  %+  ~(on-poke agent (bowl [run ~2012.5.1]))
      %obelisk-action
      !>  [%tape2 %db1 action-1]                    :: <==
  =^  mov3  agent
  %+  ~(on-poke agent (bowl [run ~2012.5.2]))
      %obelisk-action
      !>  [%tape2 %db1 action-2]                    :: <==
  =^  mov4  agent
  %+  ~(on-poke agent (bowl [run ~2012.5.3]))
      %obelisk-action
      !>  [%tape2 %db1 resolve-1]                   :: <==
  =^  mov5  agent
  %+  ~(on-poke agent (bowl [run ~2012.5.4]))
      %obelisk-action
      !>  [%tape2 %db1 resolve-2]                   :: <==
  ::
  
        ::~&  "mov2:  {<->+>+>+<.mov2>}"
        ::~&  " "
        ::~&  "mov3:  {<->+>+>+<.mov3>}"

  %+  weld  (eval-results expect1 ;;(cmd-result ->+>+>+<.mov4))
            (eval-results expect2 ;;(cmd-result ->+>+>+<.mov5))

        ::(eval-results expect1 ->+>+>+<.mov4)
        ::  (eval-results expect2 ->+>+>+<.mov5)

        ::%+  expect-eq
        ::      !>  expect1 
        ::      !>  ->+>+>+<.mov2

  ::%+  expect-fail-message
  ::  'dummy'
  ::|.  %+  ~(on-poke agent (bowl [run ~2012.5.1]))
  ::        %obelisk-action
  ::        !>  [%test %db1 action-1]
::
::
++  failon
  |=  [run=@ud init=tape action=tape resolve=tape expect1=tape expect2=tape]
  =^  mov1  agent
  %+  ~(on-poke agent (bowl [run ~2012.4.30]))
      %obelisk-action
      !>  [%tape2 %db1 init]                        :: <==
  =^  mov2  agent
  %+  ~(on-poke agent (bowl [run ~2012.4.30]))
      %obelisk-action
      !>  [%tape2 %db1 action]                      :: <==
  %+  expect-fail-message
    (crip expect1)
    |.  %+  ~(on-poke agent (bowl [run ~2012.5.5]))
            %obelisk-action
            !>  [%test %db1 resolve]
::
::  no predicate, one column
++  test-update-00
  =|  run=@ud
  %-  execut-112
        :*  run
            %-  zing  :~  "CREATE DATABASE db1;"
                          create-table
                          insert-table
                          ==
            ::
            "update my-table set col1='hello'"
            ::
            "FROM my-table ".
            "SELECT *"
            ::
            :-  %results  :~  [%message msg='UPDATE db1.dbo.my-table']
                              [%server-time date=~2012.5.1]
                              [%schema-time date=~2012.4.30]
                              [%data-time date=~2012.4.30]
                              [%message msg='updated:']
                              [%vector-count count=4]
                              [%message msg='table data:']
                              [%vector-count count=4]
                              ==
            ::
            :-  %results  :~  [%message 'SELECT']
                              :-  %result-set
                                  :~
                                    :-  %vector
                                        :~  [%col0 [~.da ~2010.5.3]]
                                            [%col1 [~.t 'hello']]
                                            [%col2 [~.p ~nomryg-nilref]]
                                            [%col3 [~.ud 20]]
                                            [%col4 [~.da ~2000.1.1]]
                                            ==
                                    :-  %vector
                                        :~  [%col0 [~.da ~2010.5.31]]
                                            [%col1 [~.t 'hello']]
                                            [%col2 [~.p ~zod]]
                                            [%col3 [~.ud 0]]
                                            [%col4 [~.da ~2000.1.1]]
                                            ==
                                    :-  %vector
                                        :~  [%col0 [~.da ~2010.5.31]]
                                            [%col1 [~.t 'hello']]
                                            [%col2 [~.p ~nec]]
                                            [%col3 [~.ud 0]]
                                            [%col4 [~.da ~2000.1.1]]
                                            ==
                                    :-  %vector
                                        :~  [%col0 [~.da ~2010.5.31]]
                                            [%col1 [~.t 'hello']]
                                            [%col2 [~.p ~bus]]
                                            [%col3 [~.ud 0]]
                                            [%col4 [~.da ~2000.1.1]]
                                            ==
                                    ==
                              [%server-time ~2012.5.3]
                              [%message 'db1.dbo.my-table']
                              [%schema-time ~2012.4.30]
                              [%data-time ~2012.5.1]
                              [%vector-count 4]
                              ==
            ==
::
::  no predicate, 3 columns
++  test-update-01
  =|  run=@ud
  %-  execut-112
        :*  run
            %-  zing  :~  "CREATE DATABASE db1;"
                          create-table
                          insert-table
                          ==
            ::
            "update my-table set col1='hello', ".
            "                    col3=44, ".
            "                    col4=~2001.1.1; "
            ::
            "FROM my-table ".
            "SELECT *"
            ::
            :-  %results  :~  [%message msg='UPDATE db1.dbo.my-table']
                              [%server-time date=~2012.5.1]
                              [%schema-time date=~2012.4.30]
                              [%data-time date=~2012.4.30]
                              [%message msg='updated:']
                              [%vector-count count=4]
                              [%message msg='table data:']
                              [%vector-count count=4]
                              ==
            ::
            :-  %results  :~  [%message 'SELECT']
                              :-  %result-set
                                  :~
                                    :-  %vector
                                        :~  [%col0 [~.da ~2010.5.3]]
                                            [%col1 [~.t 'hello']]
                                            [%col2 [~.p ~nomryg-nilref]]
                                            [%col3 [~.ud 44]]
                                            [%col4 [~.da ~2001.1.1]]
                                            ==
                                    :-  %vector
                                        :~  [%col0 [~.da ~2010.5.31]]
                                            [%col1 [~.t 'hello']]
                                            [%col2 [~.p ~zod]]
                                            [%col3 [~.ud 44]]
                                            [%col4 [~.da ~2001.1.1]]
                                            ==
                                    :-  %vector
                                        :~  [%col0 [~.da ~2010.5.31]]
                                            [%col1 [~.t 'hello']]
                                            [%col2 [~.p ~nec]]
                                            [%col3 [~.ud 44]]
                                            [%col4 [~.da ~2001.1.1]]
                                            ==
                                    :-  %vector
                                        :~  [%col0 [~.da ~2010.5.31]]
                                            [%col1 [~.t 'hello']]
                                            [%col2 [~.p ~bus]]
                                            [%col3 [~.ud 44]]
                                            [%col4 [~.da ~2001.1.1]]
                                            ==
                                    ==
                              [%server-time ~2012.5.3]
                              [%message 'db1.dbo.my-table']
                              [%schema-time ~2012.4.30]
                              [%data-time ~2012.5.1]
                              [%vector-count 4]
                              ==
            ==
::
::  no predicate, one key column, changes canonical order
++  test-update-02
  =|  run=@ud
  %-  execut-112
        :*  run
            %-  zing  :~  "CREATE DATABASE db1;"
                          create-table
                          insert-table
                          ==
            ::
            "update my-table set col0=DEFAULT"
            ::
            "FROM my-table ".
            "SELECT *"
            ::
            :-  %results  :~  [%message msg='UPDATE db1.dbo.my-table']
                              [%server-time date=~2012.5.1]
                              [%schema-time date=~2012.4.30]
                              [%data-time date=~2012.4.30]
                              [%message msg='updated:']
                              [%vector-count count=4]
                              [%message msg='table data:']
                              [%vector-count count=4]
                              ==
            ::
            :-  %results  :~  [%message 'SELECT']
                              :-  %result-set
                                  :~
                                    :-  %vector
                                        :~  [%col0 [~.da ~2000.1.1]]
                                            [%col1 [~.t 'cord']]
                                            [%col2 [~.p ~nomryg-nilref]]
                                            [%col3 [~.ud 20]]
                                            [%col4 [~.da ~2000.1.1]]
                                            ==
                                    :-  %vector
                                        :~  [%col0 [~.da ~2000.1.1]]
                                            [%col1 [~.t 'Default']]
                                            [%col2 [~.p ~zod]]
                                            [%col3 [~.ud 0]]
                                            [%col4 [~.da ~2000.1.1]]
                                            ==
                                    :-  %vector
                                        :~  [%col0 [~.da ~2000.1.1]]
                                            [%col1 [~.t 'Default']]
                                            [%col2 [~.p ~nec]]
                                            [%col3 [~.ud 0]]
                                            [%col4 [~.da ~2000.1.1]]
                                            ==
                                    :-  %vector
                                        :~  [%col0 [~.da ~2000.1.1]]
                                            [%col1 [~.t 'Default']]
                                            [%col2 [~.p ~bus]]
                                            [%col3 [~.ud 0]]
                                            [%col4 [~.da ~2000.1.1]]
                                            ==
                                    ==
                              [%server-time ~2012.5.3]
                              [%message 'db1.dbo.my-table']
                              [%schema-time ~2012.4.30]
                              [%data-time ~2012.5.1]
                              [%vector-count 4]
                              ==
            ==
::
::  no predicate, all columns except 1 key column
++  test-update-03
  =|  run=@ud
  %-  execut-112
        :*  run
            %-  zing  :~  "CREATE DATABASE db1;"
                          create-table
                          insert-table
                          ==
            ::
            "update my-table set col0=DEFAULT, ".
            "                    col1='upd1', ".
            "                    col3=7, ".
            "                    col4=~2025.4.25; "
            ::
            "FROM my-table ".
            "SELECT *"
            ::
            :-  %results  :~  [%message msg='UPDATE db1.dbo.my-table']
                              [%server-time date=~2012.5.1]
                              [%schema-time date=~2012.4.30]
                              [%data-time date=~2012.4.30]
                              [%message msg='updated:']
                              [%vector-count count=4]
                              [%message msg='table data:']
                              [%vector-count count=4]
                              ==
            ::
            :-  %results  :~  [%message 'SELECT']
                              :-  %result-set
                                  :~
                                    :-  %vector
                                        :~  [%col0 [~.da ~2000.1.1]]
                                            [%col1 [~.t 'upd1']]
                                            [%col2 [~.p ~nomryg-nilref]]
                                            [%col3 [~.ud 7]]
                                            [%col4 [~.da ~2025.4.25]]
                                            ==
                                    :-  %vector
                                        :~  [%col0 [~.da ~2000.1.1]]
                                            [%col1 [~.t 'upd1']]
                                            [%col2 [~.p ~zod]]
                                            [%col3 [~.ud 7]]
                                            [%col4 [~.da ~2025.4.25]]
                                            ==
                                    :-  %vector
                                        :~  [%col0 [~.da ~2000.1.1]]
                                            [%col1 [~.t 'upd1']]
                                            [%col2 [~.p ~nec]]
                                            [%col3 [~.ud 7]]
                                            [%col4 [~.da ~2025.4.25]]
                                            ==
                                    :-  %vector
                                        :~  [%col0 [~.da ~2000.1.1]]
                                            [%col1 [~.t 'upd1']]
                                            [%col2 [~.p ~bus]]
                                            [%col3 [~.ud 7]]
                                            [%col4 [~.da ~2025.4.25]]
                                            ==
                                    ==
                              [%server-time ~2012.5.3]
                              [%message 'db1.dbo.my-table']
                              [%schema-time ~2012.4.30]
                              [%data-time ~2012.5.1]
                              [%vector-count 4]
                              ==
            ==
::
::  predicate, no updates
++  test-update-04
  =|  run=@ud
  %-  execut-112
        :*  run
            %-  zing  :~  "CREATE DATABASE db1;"
                          create-table
                          insert-table
                          ==
            ::
            "UPDATE my-table SET col1='hello' ".
            "WHERE 'foo'='hello' "
            ::
            "FROM my-table ".
            "SELECT *"
            ::
            :-  %results  :~  [%message msg='UPDATE db1.dbo.my-table']
                              [%server-time date=~2012.5.1]
                              [%schema-time date=~2012.4.30]
                              [%data-time date=~2012.4.30]
                              [%message msg='no rows updated']
                              ==
            ::
            :-  %results  :~  [%message 'SELECT']
                              :-  %result-set
                                  :~
                                    :-  %vector
                                        :~  [%col0 [~.da ~2010.5.3]]
                                            [%col1 [~.t 'cord']]
                                            [%col2 [~.p ~nomryg-nilref]]
                                            [%col3 [~.ud 20]]
                                            [%col4 [~.da ~2000.1.1]]
                                            ==
                                    :-  %vector
                                        :~  [%col0 [~.da ~2010.5.31]]
                                            [%col1 [~.t 'Default']]
                                            [%col2 [~.p ~zod]]
                                            [%col3 [~.ud 0]]
                                            [%col4 [~.da ~2000.1.1]]
                                            ==
                                    :-  %vector
                                        :~  [%col0 [~.da ~2010.5.31]]
                                            [%col1 [~.t 'Default']]
                                            [%col2 [~.p ~nec]]
                                            [%col3 [~.ud 0]]
                                            [%col4 [~.da ~2000.1.1]]
                                            ==
                                    :-  %vector
                                        :~  [%col0 [~.da ~2010.5.31]]
                                            [%col1 [~.t 'Default']]
                                            [%col2 [~.p ~bus]]
                                            [%col3 [~.ud 0]]
                                            [%col4 [~.da ~2000.1.1]]
                                            ==
                                    ==
                              [%server-time ~2012.5.3]
                              [%message 'db1.dbo.my-table']
                              [%schema-time ~2012.4.30]
                              [%data-time ~2012.4.30]
                              [%vector-count 4]
                              ==
            ==
::
::  predicate, one column, one update
++  test-update-05
  =|  run=@ud
  %-  execut-112
        :*  run
            %-  zing  :~  "CREATE DATABASE db1;"
                          create-table
                          insert-table
                          ==
            ::
            "UPDATE my-table SET col1='hello' ".
            "WHERE col3=20 "
            ::
            "FROM my-table ".
            "SELECT *"
            ::
            :-  %results  :~  [%message msg='UPDATE db1.dbo.my-table']
                              [%server-time date=~2012.5.1]
                              [%schema-time date=~2012.4.30]
                              [%data-time date=~2012.4.30]
                              [%message msg='updated:']
                              [%vector-count count=1]
                              [%message msg='table data:']
                              [%vector-count count=4]
                              ==
            ::
            :-  %results  :~  [%message 'SELECT']
                              :-  %result-set
                                  :~
                                    :-  %vector
                                        :~  [%col0 [~.da ~2010.5.3]]
                                            [%col1 [~.t 'hello']]
                                            [%col2 [~.p ~nomryg-nilref]]
                                            [%col3 [~.ud 20]]
                                            [%col4 [~.da ~2000.1.1]]
                                            ==
                                    :-  %vector
                                        :~  [%col0 [~.da ~2010.5.31]]
                                            [%col1 [~.t 'Default']]
                                            [%col2 [~.p ~zod]]
                                            [%col3 [~.ud 0]]
                                            [%col4 [~.da ~2000.1.1]]
                                            ==
                                    :-  %vector
                                        :~  [%col0 [~.da ~2010.5.31]]
                                            [%col1 [~.t 'Default']]
                                            [%col2 [~.p ~nec]]
                                            [%col3 [~.ud 0]]
                                            [%col4 [~.da ~2000.1.1]]
                                            ==
                                    :-  %vector
                                        :~  [%col0 [~.da ~2010.5.31]]
                                            [%col1 [~.t 'Default']]
                                            [%col2 [~.p ~bus]]
                                            [%col3 [~.ud 0]]
                                            [%col4 [~.da ~2000.1.1]]
                                            ==
                                    ==
                              [%server-time ~2012.5.3]
                              [%message 'db1.dbo.my-table']
                              [%schema-time ~2012.4.30]
                              [%data-time ~2012.5.1]
                              [%vector-count 4]
                              ==
            ==
::
::  predicate, one column, three updates
++  test-update-06
  =|  run=@ud
  %-  execut-112
        :*  run
            %-  zing  :~  "CREATE DATABASE db1;"
                          create-table
                          insert-table
                          ==
            ::
            "UPDATE my-table SET col1='hello' ".
            "WHERE col1='Default' "
            ::
            "FROM my-table ".
            "SELECT *"
            ::
            :-  %results  :~  [%message msg='UPDATE db1.dbo.my-table']
                              [%server-time date=~2012.5.1]
                              [%schema-time date=~2012.4.30]
                              [%data-time date=~2012.4.30]
                              [%message msg='updated:']
                              [%vector-count count=3]
                              [%message msg='table data:']
                              [%vector-count count=4]
                              ==
            ::
            :-  %results  :~  [%message 'SELECT']
                              :-  %result-set
                                  :~
                                    :-  %vector
                                        :~  [%col0 [~.da ~2010.5.3]]
                                            [%col1 [~.t 'cord']]
                                            [%col2 [~.p ~nomryg-nilref]]
                                            [%col3 [~.ud 20]]
                                            [%col4 [~.da ~2000.1.1]]
                                            ==
                                    :-  %vector
                                        :~  [%col0 [~.da ~2010.5.31]]
                                            [%col1 [~.t 'hello']]
                                            [%col2 [~.p ~zod]]
                                            [%col3 [~.ud 0]]
                                            [%col4 [~.da ~2000.1.1]]
                                            ==
                                    :-  %vector
                                        :~  [%col0 [~.da ~2010.5.31]]
                                            [%col1 [~.t 'hello']]
                                            [%col2 [~.p ~nec]]
                                            [%col3 [~.ud 0]]
                                            [%col4 [~.da ~2000.1.1]]
                                            ==
                                    :-  %vector
                                        :~  [%col0 [~.da ~2010.5.31]]
                                            [%col1 [~.t 'hello']]
                                            [%col2 [~.p ~bus]]
                                            [%col3 [~.ud 0]]
                                            [%col4 [~.da ~2000.1.1]]
                                            ==
                                    ==
                              [%server-time ~2012.5.3]
                              [%message 'db1.dbo.my-table']
                              [%schema-time ~2012.4.30]
                              [%data-time ~2012.5.1]
                              [%vector-count 4]
                              ==
            ==
::
::  predicate, 3 columns, three updates
++  test-update-07
  =|  run=@ud
  %-  execut-112
        :*  run
            %-  zing  :~  "CREATE DATABASE db1;"
                          create-table
                          insert-table
                          ==
            ::
            "UPDATE my-table SET col1='hello', ".
            "                    col3=152, ".
            "                    col4=~1978.12.31 ".
            "WHERE col1='Default' "
            ::
            "FROM my-table ".
            "SELECT *"
            ::
            :-  %results  :~  [%message msg='UPDATE db1.dbo.my-table']
                              [%server-time date=~2012.5.1]
                              [%schema-time date=~2012.4.30]
                              [%data-time date=~2012.4.30]
                              [%message msg='updated:']
                              [%vector-count count=3]
                              [%message msg='table data:']
                              [%vector-count count=4]
                              ==
            ::
            :-  %results  :~  [%message 'SELECT']
                              :-  %result-set
                                  :~
                                    :-  %vector
                                        :~  [%col0 [~.da ~2010.5.3]]
                                            [%col1 [~.t 'cord']]
                                            [%col2 [~.p ~nomryg-nilref]]
                                            [%col3 [~.ud 20]]
                                            [%col4 [~.da ~2000.1.1]]
                                            ==
                                    :-  %vector
                                        :~  [%col0 [~.da ~2010.5.31]]
                                            [%col1 [~.t 'hello']]
                                            [%col2 [~.p ~zod]]
                                            [%col3 [~.ud 152]]
                                            [%col4 [~.da ~1978.12.31]]
                                            ==
                                    :-  %vector
                                        :~  [%col0 [~.da ~2010.5.31]]
                                            [%col1 [~.t 'hello']]
                                            [%col2 [~.p ~nec]]
                                            [%col3 [~.ud 152]]
                                            [%col4 [~.da ~1978.12.31]]
                                            ==
                                    :-  %vector
                                        :~  [%col0 [~.da ~2010.5.31]]
                                            [%col1 [~.t 'hello']]
                                            [%col2 [~.p ~bus]]
                                            [%col3 [~.ud 152]]
                                            [%col4 [~.da ~1978.12.31]]
                                            ==
                                    ==
                              [%server-time ~2012.5.3]
                              [%message 'db1.dbo.my-table']
                              [%schema-time ~2012.4.30]
                              [%data-time ~2012.5.1]
                              [%vector-count 4]
                              ==
            ==
::
::  predicate, 3 columns, one update
++  test-update-08
  =|  run=@ud
  %-  execut-112
        :*  run
            %-  zing  :~  "CREATE DATABASE db1;"
                          create-table
                          insert-table
                          ==
            ::
            "UPDATE my-table SET col1='hello', ".
            "                    col3=152, ".
            "                    col4=~1978.12.31 ".
            "WHERE col1='Default' ".
            "  AND col2=~nec    ;"
            ::
            "FROM my-table ".
            "SELECT *"
            ::
            :-  %results  :~  [%message msg='UPDATE db1.dbo.my-table']
                              [%server-time date=~2012.5.1]
                              [%schema-time date=~2012.4.30]
                              [%data-time date=~2012.4.30]
                              [%message msg='updated:']
                              [%vector-count count=1]
                              [%message msg='table data:']
                              [%vector-count count=4]
                              ==
            ::
            :-  %results  :~  [%message 'SELECT']
                              :-  %result-set
                                  :~
                                    :-  %vector
                                        :~  [%col0 [~.da ~2010.5.3]]
                                            [%col1 [~.t 'cord']]
                                            [%col2 [~.p ~nomryg-nilref]]
                                            [%col3 [~.ud 20]]
                                            [%col4 [~.da ~2000.1.1]]
                                            ==
                                    :-  %vector
                                        :~  [%col0 [~.da ~2010.5.31]]
                                            [%col1 [~.t 'Default']]
                                            [%col2 [~.p ~zod]]
                                            [%col3 [~.ud 0]]
                                            [%col4 [~.da ~2000.1.1]]
                                            ==
                                    :-  %vector
                                        :~  [%col0 [~.da ~2010.5.31]]
                                            [%col1 [~.t 'hello']]
                                            [%col2 [~.p ~nec]]
                                            [%col3 [~.ud 152]]
                                            [%col4 [~.da ~1978.12.31]]
                                            ==
                                    :-  %vector
                                        :~  [%col0 [~.da ~2010.5.31]]
                                            [%col1 [~.t 'Default']]
                                            [%col2 [~.p ~bus]]
                                            [%col3 [~.ud 0]]
                                            [%col4 [~.da ~2000.1.1]]
                                            ==
                                    ==
                              [%server-time ~2012.5.3]
                              [%message 'db1.dbo.my-table']
                              [%schema-time ~2012.4.30]
                              [%data-time ~2012.5.1]
                              [%vector-count 4]
                              ==
            ==
::
::  predicate, one key column, changes canonical order
++  test-update-09
  =|  run=@ud
  %-  execut-112
      :*  run
          %-  zing  :~  "CREATE DATABASE db1;"
                        create-table
                        insert-table
                        ==
          ::
          "UPDATE my-table SET col0=~1978.12.31 ".
          "WHERE col2=~nec    ;"
          ::
          "FROM my-table ".
          "SELECT *"
          ::
          :-  %results  :~  [%message msg='UPDATE db1.dbo.my-table']
                            [%server-time date=~2012.5.1]
                            [%schema-time date=~2012.4.30]
                            [%data-time date=~2012.4.30]
                            [%message msg='updated:']
                            [%vector-count count=1]
                            [%message msg='table data:']
                            [%vector-count count=4]
                            ==
          ::
          :-  %results  :~  [%message 'SELECT']
                            :-  %result-set
                                :~
                                  :-  %vector
                                      :~  [%col0 [~.da ~2010.5.3]]
                                          [%col1 [~.t 'cord']]
                                          [%col2 [~.p ~nomryg-nilref]]
                                          [%col3 [~.ud 20]]
                                          [%col4 [~.da ~2000.1.1]]
                                          ==
                                  :-  %vector
                                      :~  [%col0 [~.da ~2010.5.31]]
                                          [%col1 [~.t 'Default']]
                                          [%col2 [~.p ~zod]]
                                          [%col3 [~.ud 0]]
                                          [%col4 [~.da ~2000.1.1]]
                                          ==
                                  :-  %vector
                                      :~  [%col0 [~.da ~1978.12.31]]
                                          [%col1 [~.t 'Default']]
                                          [%col2 [~.p ~nec]]
                                          [%col3 [~.ud 0]]
                                          [%col4 [~.da ~2000.1.1]]
                                          ==
                                  :-  %vector
                                      :~  [%col0 [~.da ~2010.5.31]]
                                          [%col1 [~.t 'Default']]
                                          [%col2 [~.p ~bus]]
                                          [%col3 [~.ud 0]]
                                          [%col4 [~.da ~2000.1.1]]
                                          ==
                                  ==
                            [%server-time ~2012.5.3]
                            [%message 'db1.dbo.my-table']
                            [%schema-time ~2012.4.30]
                            [%data-time ~2012.5.1]
                            [%vector-count 4]
                            ==
          ==
::
::  predicate, all columns, one update
++  test-update-10
  =|  run=@ud
  %-  execut-112
        :*  run
            %-  zing  :~  "CREATE DATABASE db1;"
                          create-table
                          insert-table
                          ==
            ::
            "UPDATE my-table SET col0=~1980.1.1, ".
            "                    col1='hello', ".
            "                    col3=152, ".
            "                    col4=~1978.12.31 ".
            "WHERE col1='Default' ".
            "  AND col2=~nec    ;"
            ::
            "FROM my-table ".
            "SELECT *"
            ::
            :-  %results  :~  [%message msg='UPDATE db1.dbo.my-table']
                              [%server-time date=~2012.5.1]
                              [%schema-time date=~2012.4.30]
                              [%data-time date=~2012.4.30]
                              [%message msg='updated:']
                              [%vector-count count=1]
                              [%message msg='table data:']
                              [%vector-count count=4]
                              ==
            ::
            :-  %results  :~  [%message 'SELECT']
                              :-  %result-set
                                  :~
                                    :-  %vector
                                        :~  [%col0 [~.da ~2010.5.3]]
                                            [%col1 [~.t 'cord']]
                                            [%col2 [~.p ~nomryg-nilref]]
                                            [%col3 [~.ud 20]]
                                            [%col4 [~.da ~2000.1.1]]
                                            ==
                                    :-  %vector
                                        :~  [%col0 [~.da ~2010.5.31]]
                                            [%col1 [~.t 'Default']]
                                            [%col2 [~.p ~zod]]
                                            [%col3 [~.ud 0]]
                                            [%col4 [~.da ~2000.1.1]]
                                            ==
                                    :-  %vector
                                        :~  [%col0 [~.da ~1980.1.1]]
                                            [%col1 [~.t 'hello']]
                                            [%col2 [~.p ~nec]]
                                            [%col3 [~.ud 152]]
                                            [%col4 [~.da ~1978.12.31]]
                                            ==
                                    :-  %vector
                                        :~  [%col0 [~.da ~2010.5.31]]
                                            [%col1 [~.t 'Default']]
                                            [%col2 [~.p ~bus]]
                                            [%col3 [~.ud 0]]
                                            [%col4 [~.da ~2000.1.1]]
                                            ==
                                    ==
                              [%server-time ~2012.5.3]
                              [%message 'db1.dbo.my-table']
                              [%schema-time ~2012.4.30]
                              [%data-time ~2012.5.1]
                              [%vector-count 4]
                              ==
            ==
::
::  predicate, AS OF = @da prior data state, one update
++  test-update-11
  =|  run=@ud
  %-  execut-222
        :*  run
            %-  zing  :~  "CREATE DATABASE db1;"
                          create-table
                          insert-table
                          ==
            ::
            "UPDATE my-table ".
            "   SET col0=~1980.1.1, ".
            "       col1='hello', ".
            "       col3=152, ".
            "       col4=~1978.12.31 ".
            "WHERE col1='Default' ".
            "  AND col2=~nec    ;".
            "INSERT INTO db1..my-table ".
            "VALUES (~2011.7.30, 'name',~deg,44,~2012.7.30); "

            ::
            "UPDATE my-table AS OF ~2012.4.30 ".
            "   SET col0=~1981.2.2, ".
            "       col1='hello you', ".
            "       col3=153, ".
            "       col4=~1999.12.31 ".
            "WHERE col1='Default' ".
            "  AND col2=~bus    ;"
            ::
            "FROM my-table AS OF ~2012.5.1".
            "SELECT *;"
            ::
            "FROM my-table ".
            "SELECT *;"
            ::
            :-  %results  :~  [%message 'SELECT']
                              :-  %result-set
                                  :~
                                    :-  %vector
                                        :~  [%col0 [~.da ~2010.5.3]]
                                            [%col1 [~.t 'cord']]
                                            [%col2 [~.p ~nomryg-nilref]]
                                            [%col3 [~.ud 20]]
                                            [%col4 [~.da ~2000.1.1]]
                                            ==
                                    :-  %vector
                                        :~  [%col0 [~.da ~2010.5.31]]
                                            [%col1 [~.t 'Default']]
                                            [%col2 [~.p ~zod]]
                                            [%col3 [~.ud 0]]
                                            [%col4 [~.da ~2000.1.1]]
                                            ==
                                    :-  %vector
                                        :~  [%col0 [~.da ~1980.1.1]]
                                            [%col1 [~.t 'hello']]
                                            [%col2 [~.p ~nec]]
                                            [%col3 [~.ud 152]]
                                            [%col4 [~.da ~1978.12.31]]
                                            ==
                                    :-  %vector
                                        :~  [%col0 [~.da ~2010.5.31]]
                                            [%col1 [~.t 'Default']]
                                            [%col2 [~.p ~bus]]
                                            [%col3 [~.ud 0]]
                                            [%col4 [~.da ~2000.1.1]]
                                            ==
                                    :-  %vector
                                        :~  [%col0 [~.da ~2011.7.30]]
                                            [%col1 [~.t 'name']]
                                            [%col2 [~.p ~deg]]
                                            [%col3 [~.ud 44]]
                                            [%col4 [~.da ~2012.7.30]]
                                            ==
                                    ==
                              [%server-time ~2012.5.3]
                              [%message 'db1.dbo.my-table']
                              [%schema-time ~2012.4.30]
                              [%data-time ~2012.5.1]
                              [%vector-count 5]
                              ==
            ::
            :-  %results  :~  [%message 'SELECT']
                              :-  %result-set
                                  :~
                                    :-  %vector
                                        :~  [%col0 [~.da ~2010.5.3]]
                                            [%col1 [~.t 'cord']]
                                            [%col2 [~.p ~nomryg-nilref]]
                                            [%col3 [~.ud 20]]
                                            [%col4 [~.da ~2000.1.1]]
                                            ==
                                    :-  %vector
                                        :~  [%col0 [~.da ~2010.5.31]]
                                            [%col1 [~.t 'Default']]
                                            [%col2 [~.p ~zod]]
                                            [%col3 [~.ud 0]]
                                            [%col4 [~.da ~2000.1.1]]
                                            ==
                                    :-  %vector
                                        :~  [%col0 [~.da ~2010.5.31]]
                                            [%col1 [~.t 'Default']]
                                            [%col2 [~.p ~nec]]
                                            [%col3 [~.ud 0]]
                                            [%col4 [~.da ~2000.1.1]]
                                            ==
                                    :-  %vector
                                        :~  [%col0 [~.da ~1981.2.2]]
                                            [%col1 [~.t 'hello you']]
                                            [%col2 [~.p ~bus]]
                                            [%col3 [~.ud 153]]
                                            [%col4 [~.da ~1999.12.31]]
                                            ==
                                    ==
                              [%server-time ~2012.5.4]
                              [%message 'db1.dbo.my-table']
                              [%schema-time ~2012.4.30]
                              [%data-time ~2012.5.2]
                              [%vector-count 4]
                              ==
            ==
::
::  predicate, AS OF 30 hours ago > prior data state, one update
++  test-update-12
  =|  run=@ud
  %-  execut-222
        :*  run
            %-  zing  :~  "CREATE DATABASE db1;"
                          create-table
                          insert-table
                          ==
            ::
            "UPDATE my-table ".
            "   SET col0=~1980.1.1, ".
            "       col1='hello', ".
            "       col3=152, ".
            "       col4=~1978.12.31 ".
            "WHERE col1='Default' ".
            "  AND col2=~nec    ;".
            "INSERT INTO db1..my-table ".
            "VALUES (~2011.7.30, 'name',~deg,44,~2012.7.30); "

            ::
            "UPDATE my-table AS OF 30 HOURS AGO ".
            "   SET col0=~1981.2.2, ".
            "       col1='hello you', ".
            "       col3=153, ".
            "       col4=~1999.12.31 ".
            "WHERE col1='Default' ".
            "  AND col2=~bus    ;"
            ::
            "FROM my-table AS OF ~2012.5.1".
            "SELECT *;"
            ::
            "FROM my-table ".
            "SELECT *;"
            ::
            :-  %results  :~  [%message 'SELECT']
                              :-  %result-set
                                  :~
                                    :-  %vector
                                        :~  [%col0 [~.da ~2010.5.3]]
                                            [%col1 [~.t 'cord']]
                                            [%col2 [~.p ~nomryg-nilref]]
                                            [%col3 [~.ud 20]]
                                            [%col4 [~.da ~2000.1.1]]
                                            ==
                                    :-  %vector
                                        :~  [%col0 [~.da ~2010.5.31]]
                                            [%col1 [~.t 'Default']]
                                            [%col2 [~.p ~zod]]
                                            [%col3 [~.ud 0]]
                                            [%col4 [~.da ~2000.1.1]]
                                            ==
                                    :-  %vector
                                        :~  [%col0 [~.da ~1980.1.1]]
                                            [%col1 [~.t 'hello']]
                                            [%col2 [~.p ~nec]]
                                            [%col3 [~.ud 152]]
                                            [%col4 [~.da ~1978.12.31]]
                                            ==
                                    :-  %vector
                                        :~  [%col0 [~.da ~2010.5.31]]
                                            [%col1 [~.t 'Default']]
                                            [%col2 [~.p ~bus]]
                                            [%col3 [~.ud 0]]
                                            [%col4 [~.da ~2000.1.1]]
                                            ==
                                    :-  %vector
                                        :~  [%col0 [~.da ~2011.7.30]]
                                            [%col1 [~.t 'name']]
                                            [%col2 [~.p ~deg]]
                                            [%col3 [~.ud 44]]
                                            [%col4 [~.da ~2012.7.30]]
                                            ==
                                    ==
                              [%server-time ~2012.5.3]
                              [%message 'db1.dbo.my-table']
                              [%schema-time ~2012.4.30]
                              [%data-time ~2012.5.1]
                              [%vector-count 5]
                              ==
            ::
            :-  %results  :~  [%message 'SELECT']
                              :-  %result-set
                                  :~
                                    :-  %vector
                                        :~  [%col0 [~.da ~2010.5.3]]
                                            [%col1 [~.t 'cord']]
                                            [%col2 [~.p ~nomryg-nilref]]
                                            [%col3 [~.ud 20]]
                                            [%col4 [~.da ~2000.1.1]]
                                            ==
                                    :-  %vector
                                        :~  [%col0 [~.da ~2010.5.31]]
                                            [%col1 [~.t 'Default']]
                                            [%col2 [~.p ~zod]]
                                            [%col3 [~.ud 0]]
                                            [%col4 [~.da ~2000.1.1]]
                                            ==
                                    :-  %vector
                                        :~  [%col0 [~.da ~2010.5.31]]
                                            [%col1 [~.t 'Default']]
                                            [%col2 [~.p ~nec]]
                                            [%col3 [~.ud 0]]
                                            [%col4 [~.da ~2000.1.1]]
                                            ==
                                    :-  %vector
                                        :~  [%col0 [~.da ~1981.2.2]]
                                            [%col1 [~.t 'hello you']]
                                            [%col2 [~.p ~bus]]
                                            [%col3 [~.ud 153]]
                                            [%col4 [~.da ~1999.12.31]]
                                            ==
                                    ==
                              [%server-time ~2012.5.4]
                              [%message 'db1.dbo.my-table']
                              [%schema-time ~2012.4.30]
                              [%data-time ~2012.5.2]
                              [%vector-count 4]
                              ==
            ==
::
::  predicate, AS OF ~h36.m30 > prior data state, one update
++  test-update-13
  =|  run=@ud
  %-  execut-222
        :*  run
            %-  zing  :~  "CREATE DATABASE db1;"
                          create-table
                          insert-table
                          ==
            ::
            "UPDATE my-table ".
            "   SET col0=~1980.1.1, ".
            "       col1='hello', ".
            "       col3=152, ".
            "       col4=~1978.12.31 ".
            "WHERE col1='Default' ".
            "  AND col2=~nec    ;".
            "INSERT INTO db1..my-table ".
            "VALUES (~2011.7.30, 'name',~deg,44,~2012.7.30); "

            ::
            "UPDATE my-table AS OF ~h36.m30 ".
            "   SET col0=~1981.2.2, ".
            "       col1='hello you', ".
            "       col3=153, ".
            "       col4=~1999.12.31 ".
            "WHERE col1='Default' ".
            "  AND col2=~bus    ;"
            ::
            "FROM my-table AS OF ~2012.5.1".
            "SELECT *;"
            ::
            "FROM my-table ".
            "SELECT *;"
            ::
            :-  %results  :~  [%message 'SELECT']
                              :-  %result-set
                                  :~
                                    :-  %vector
                                        :~  [%col0 [~.da ~2010.5.3]]
                                            [%col1 [~.t 'cord']]
                                            [%col2 [~.p ~nomryg-nilref]]
                                            [%col3 [~.ud 20]]
                                            [%col4 [~.da ~2000.1.1]]
                                            ==
                                    :-  %vector
                                        :~  [%col0 [~.da ~2010.5.31]]
                                            [%col1 [~.t 'Default']]
                                            [%col2 [~.p ~zod]]
                                            [%col3 [~.ud 0]]
                                            [%col4 [~.da ~2000.1.1]]
                                            ==
                                    :-  %vector
                                        :~  [%col0 [~.da ~1980.1.1]]
                                            [%col1 [~.t 'hello']]
                                            [%col2 [~.p ~nec]]
                                            [%col3 [~.ud 152]]
                                            [%col4 [~.da ~1978.12.31]]
                                            ==
                                    :-  %vector
                                        :~  [%col0 [~.da ~2010.5.31]]
                                            [%col1 [~.t 'Default']]
                                            [%col2 [~.p ~bus]]
                                            [%col3 [~.ud 0]]
                                            [%col4 [~.da ~2000.1.1]]
                                            ==
                                    :-  %vector
                                        :~  [%col0 [~.da ~2011.7.30]]
                                            [%col1 [~.t 'name']]
                                            [%col2 [~.p ~deg]]
                                            [%col3 [~.ud 44]]
                                            [%col4 [~.da ~2012.7.30]]
                                            ==
                                    ==
                              [%server-time ~2012.5.3]
                              [%message 'db1.dbo.my-table']
                              [%schema-time ~2012.4.30]
                              [%data-time ~2012.5.1]
                              [%vector-count 5]
                              ==
            ::
            :-  %results  :~  [%message 'SELECT']
                              :-  %result-set
                                  :~
                                    :-  %vector
                                        :~  [%col0 [~.da ~2010.5.3]]
                                            [%col1 [~.t 'cord']]
                                            [%col2 [~.p ~nomryg-nilref]]
                                            [%col3 [~.ud 20]]
                                            [%col4 [~.da ~2000.1.1]]
                                            ==
                                    :-  %vector
                                        :~  [%col0 [~.da ~2010.5.31]]
                                            [%col1 [~.t 'Default']]
                                            [%col2 [~.p ~zod]]
                                            [%col3 [~.ud 0]]
                                            [%col4 [~.da ~2000.1.1]]
                                            ==
                                    :-  %vector
                                        :~  [%col0 [~.da ~2010.5.31]]
                                            [%col1 [~.t 'Default']]
                                            [%col2 [~.p ~nec]]
                                            [%col3 [~.ud 0]]
                                            [%col4 [~.da ~2000.1.1]]
                                            ==
                                    :-  %vector
                                        :~  [%col0 [~.da ~1981.2.2]]
                                            [%col1 [~.t 'hello you']]
                                            [%col2 [~.p ~bus]]
                                            [%col3 [~.ud 153]]
                                            [%col4 [~.da ~1999.12.31]]
                                            ==
                                    ==
                              [%server-time ~2012.5.4]
                              [%message 'db1.dbo.my-table']
                              [%schema-time ~2012.4.30]
                              [%data-time ~2012.5.2]
                              [%vector-count 4]
                              ==
            ==
::
::  predicate, AS OF > prior data state, one update, same script
++  test-update-14
  =|  run=@ud
  %-  execut-112
        :*  run
            %-  zing  :~  "CREATE DATABASE db1;"
                          create-table
                          insert-table
                          ==
            ::
            "UPDATE my-table ".
            "   SET col0=~1980.1.1, ".
            "       col1='hello', ".
            "       col3=152, ".
            "       col4=~1978.12.31 ".
            "WHERE col1='Default' ".
            "  AND col2=~nec    ;".
            "INSERT INTO db1..my-table ".
            "VALUES (~2011.7.30, 'name',~deg,44,~2012.7.30); ".
            "UPDATE my-table AS OF ~m30 ".
            "   SET col0=~1981.2.2, ".
            "       col1='hello you', ".
            "       col3=153, ".
            "       col4=~1999.12.31 ".
            "WHERE col1='Default' ".
            "  AND col2=~bus    ;"
            ::
            "FROM my-table ".
            "SELECT *;"
            ::
            :-  %results  :~  [%message msg='UPDATE db1.dbo.my-table']
                              [%server-time date=~2012.5.1]
                              [%schema-time date=~2012.4.30]
                              [%data-time date=~2012.4.30]
                              [%message msg='updated:']
                              [%vector-count count=1]
                              [%message msg='table data:']
                              [%vector-count count=4]
                              ==
            ::
            :-  %results  :~  [%message 'SELECT']
                              :-  %result-set
                                  :~
                                    :-  %vector
                                        :~  [%col0 [~.da ~2010.5.3]]
                                            [%col1 [~.t 'cord']]
                                            [%col2 [~.p ~nomryg-nilref]]
                                            [%col3 [~.ud 20]]
                                            [%col4 [~.da ~2000.1.1]]
                                            ==
                                    :-  %vector
                                        :~  [%col0 [~.da ~2010.5.31]]
                                            [%col1 [~.t 'Default']]
                                            [%col2 [~.p ~zod]]
                                            [%col3 [~.ud 0]]
                                            [%col4 [~.da ~2000.1.1]]
                                            ==
                                    :-  %vector
                                        :~  [%col0 [~.da ~2010.5.31]]
                                            [%col1 [~.t 'Default']]
                                            [%col2 [~.p ~nec]]
                                            [%col3 [~.ud 0]]
                                            [%col4 [~.da ~2000.1.1]]
                                            ==
                                    :-  %vector
                                        :~  [%col0 [~.da ~1981.2.2]]
                                            [%col1 [~.t 'hello you']]
                                            [%col2 [~.p ~bus]]
                                            [%col3 [~.ud 153]]
                                            [%col4 [~.da ~1999.12.31]]
                                            ==
                                    ==
                              [%server-time ~2012.5.3]
                              [%message 'db1.dbo.my-table']
                              [%schema-time ~2012.4.30]
                              [%data-time ~2012.5.1]
                              [%vector-count 4]
                              ==
            ==
::
::  fail on no predicate, create dup key
++  test-fail-update-00
  =|  run=@ud
  %-  failon  :*  run
                  %-  zing  :~  "CREATE DATABASE db1;"
                                create-table
                                insert-table
                                ==
                  ::
                  ""
                  ::
                  ""
                  ::
                  ""
                  ::
                  ""
                  ==
::
::  fail on predicate, create dup key
++  test-fail-update-01
  =|  run=@ud
  %-  failon  :*  run
                  %-  zing  :~  "CREATE DATABASE db1;"
                                create-table
                                insert-table
                                ==
                  ::
                  ""
                  ::
                  ""
                  ::
                  ""
                  ::
                  ""
                  ==
::
::  fail on column does not exist
++  test-fail-update-02
  =|  run=@ud
  %-  failon  :*  run
                  %-  zing  :~  "CREATE DATABASE db1;"
                                create-table
                                insert-table
                                ==
                  ::
                  ""
                  ::
                  ""
                  ::
                  ""
                  ::
                  ""
                  ==
::
::  fail on column is wrong type
++  test-fail-update-03
  =|  run=@ud
  %-  failon  :*  run
                  %-  zing  :~  "CREATE DATABASE db1;"
                                create-table
                                insert-table
                                ==
                  ::
                  ""
                  ::
                  ""
                  ::
                  ""
                  ::
                  ""
                  ==
::
::  fail on table not matching by column qualifier
++  test-fail-update-04
  =|  run=@ud
  %-  failon  :*  run
                  %-  zing  :~  "CREATE DATABASE db1;"
                                create-table
                                insert-table
                                ==
                  ::
                  ""
                  ::
                  ""
                  ::
                  ""
                  ::
                  ""
                  ==
::
::  fail on columns and values mismatch
++  test-fail-update-05
  =|  run=@ud
  %-  failon  :*  run
                  %-  zing  :~  "CREATE DATABASE db1;"
                                create-table
                                insert-table
                                ==
                  ::
                  ""
                  ::
                  ""
                  ::
                  ""
                  ::
                  ""
                  ==
--