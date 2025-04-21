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
                  "(col1 @t, col2 @p, col3 @ud, col4 @da) ".
                  "PRIMARY KEY (col1);"

 ++  insert-table  "INSERT INTO db1..my-table (col1, col2, col3, col4) ".
                    "VALUES ('cord',~nomryg-nilref,20,Default) ".
                    "       ('Default',Default, 0,Default); "
::
::
++  execut
  |=  [run=@ud init=tape action=tape resolve=tape expect1=cmd-result expect2=cmd-result]
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

  

    ::~&  "print:  {<->+>+>+.mov2>}"
    :: ~&  " "
    ::  ~&  "print:  {<->+>+>+<.mov3>}"

    ::(eval-results expect1 ->+>+>+<.mov2)
    ::  (eval-results expect2 ->+>+>+<.mov3)

    ::%+  expect-eq
    ::      !>  expect1 
    ::      !>  ->+>+>+<.mov2

  ::%+  expect-fail-message
  ::  'dummy'
  ::|.  %+  ~(on-poke agent (bowl [run ~2012.5.1]))
  ::        %obelisk-action
  ::        !>  [%test %db1 action]


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
  ::=/  bar=[@ud tape tape tape cmd-result cmd-result]
  %-  execut  :*  run
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
                  [%results ~]
                  ::
                  :-  %results  :~  [%message 'SELECT']
                                    :-  %result-set
                                        :~
                                          :-  %vector
                                              :~  [%col1 [~.t 'cord2']]
                                                  [%col2 [~.p ~nomryg-nilref]]
                                                  [%col3 [~.ud 20]]
                                                  ==
                                          :-  %vector
                                              :~  [%col1 [~.t 'Default2']]
                                                  [%col2 [~.p ~zod]]
                                                  [%col3 [~.ud 0]]
                                                  ==
                                          ==
                                    [%server-time ~2012.5.3]
                                    [%message 'db1.dbo.my-table']
                                    [%schema-time ~2012.5.1]
                                    [%data-time ~2012.5.2]
                                    [%vector-count 2]
                                    ==
                  ==
  ::(execut bar)
::
::  no predicate, 3 columns
++  test-update-01
  =|  run=@ud
  %-  execut  :*  run
                  %-  zing  :~  "CREATE DATABASE db1;"
                                create-table
                                insert-table
                                ==
                  ::
                  "update foo set col1='hello'"
                  ::
                  "FROM my-table ".
                  "SELECT *"
                  ::
                  [%results ~]
                  ::
                  :-  %results  :~  [%message 'SELECT']
                                    :-  %result-set
                                        :~
                                          :-  %vector
                                              :~  [%col1 [~.t 'cord2']]
                                                  [%col2 [~.p ~nomryg-nilref]]
                                                  [%col3 [~.ud 20]]
                                                  ==
                                          :-  %vector
                                              :~  [%col1 [~.t 'Default2']]
                                                  [%col2 [~.p ~zod]]
                                                  [%col3 [~.ud 0]]
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
::  no predicate, one key column, changes canonical order
++  test-update-02
  =|  run=@ud
  %-  execut  :*  run
                  %-  zing  :~  "CREATE DATABASE db1;"
                                create-table
                                insert-table
                                ==
                  ::
                  "update foo set col1='hello'"
                  ::
                  "FROM my-table ".
                  "SELECT *"
                  ::
                  [%results ~]
                  ::
                  :-  %results  :~  [%message 'SELECT']
                                    :-  %result-set
                                        :~
                                          :-  %vector
                                              :~  [%col1 [~.t 'cord2']]
                                                  [%col2 [~.p ~nomryg-nilref]]
                                                  [%col3 [~.ud 20]]
                                                  ==
                                          :-  %vector
                                              :~  [%col1 [~.t 'Default2']]
                                                  [%col2 [~.p ~zod]]
                                                  [%col3 [~.ud 0]]
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
::  no predicate, all columns
++  test-update-03
  =|  run=@ud
  %-  execut  :*  run
                  %-  zing  :~  "CREATE DATABASE db1;"
                                create-table
                                insert-table
                                ==
                  ::
                  "update foo set col1='hello'"
                  ::
                  "FROM my-table ".
                  "SELECT *"
                  ::
                  [%results ~]
                  ::
                  :-  %results  :~  [%message 'SELECT']
                                    :-  %result-set
                                        :~
                                          :-  %vector
                                              :~  [%col1 [~.t 'cord2']]
                                                  [%col2 [~.p ~nomryg-nilref]]
                                                  [%col3 [~.ud 20]]
                                                  ==
                                          :-  %vector
                                              :~  [%col1 [~.t 'Default2']]
                                                  [%col2 [~.p ~zod]]
                                                  [%col3 [~.ud 0]]
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
::  predicate, no updates
++  test-update-04
  =|  run=@ud
  %-  execut  :*  run
                  %-  zing  :~  "CREATE DATABASE db1;"
                                create-table
                                insert-table
                                ==
                  ::
                  "update foo set col1='hello'"
                  ::
                  "FROM my-table ".
                  "SELECT *"
                  ::
                  [%results ~]
                  ::
                  :-  %results  :~  [%message 'SELECT']
                                    :-  %result-set
                                        :~
                                          :-  %vector
                                              :~  [%col1 [~.t 'cord2']]
                                                  [%col2 [~.p ~nomryg-nilref]]
                                                  [%col3 [~.ud 20]]
                                                  ==
                                          :-  %vector
                                              :~  [%col1 [~.t 'Default2']]
                                                  [%col2 [~.p ~zod]]
                                                  [%col3 [~.ud 0]]
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
::  predicate, one column, one update
++  test-update-05
  =|  run=@ud
  %-  execut  :*  run
                  %-  zing  :~  "CREATE DATABASE db1;"
                                create-table
                                insert-table
                                ==
                  ::
                  "update foo set col1='hello'"
                  ::
                  "FROM my-table ".
                  "SELECT *"
                  ::
                  [%results ~]
                  ::
                  :-  %results  :~  [%message 'SELECT']
                                    :-  %result-set
                                        :~
                                          :-  %vector
                                              :~  [%col1 [~.t 'cord2']]
                                                  [%col2 [~.p ~nomryg-nilref]]
                                                  [%col3 [~.ud 20]]
                                                  ==
                                          :-  %vector
                                              :~  [%col1 [~.t 'Default2']]
                                                  [%col2 [~.p ~zod]]
                                                  [%col3 [~.ud 0]]
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
::  predicate, one column, three updates
++  test-update-06
  =|  run=@ud
  %-  execut  :*  run
                  %-  zing  :~  "CREATE DATABASE db1;"
                                create-table
                                insert-table
                                ==
                  ::
                  "update foo set col1='hello'"
                  ::
                  "FROM my-table ".
                  "SELECT *"
                  ::
                  [%results ~]
                  ::
                  :-  %results  :~  [%message 'SELECT']
                                    :-  %result-set
                                        :~
                                          :-  %vector
                                              :~  [%col1 [~.t 'cord2']]
                                                  [%col2 [~.p ~nomryg-nilref]]
                                                  [%col3 [~.ud 20]]
                                                  ==
                                          :-  %vector
                                              :~  [%col1 [~.t 'Default2']]
                                                  [%col2 [~.p ~zod]]
                                                  [%col3 [~.ud 0]]
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
::  predicate, 3 columns, one update
++  test-update-07
  =|  run=@ud
  %-  execut  :*  run
                  %-  zing  :~  "CREATE DATABASE db1;"
                                create-table
                                insert-table
                                ==
                  ::
                  "update foo set col1='hello'"
                  ::
                  "FROM my-table ".
                  "SELECT *"
                  ::
                  [%results ~]
                  ::
                  :-  %results  :~  [%message 'SELECT']
                                    :-  %result-set
                                        :~
                                          :-  %vector
                                              :~  [%col1 [~.t 'cord2']]
                                                  [%col2 [~.p ~nomryg-nilref]]
                                                  [%col3 [~.ud 20]]
                                                  ==
                                          :-  %vector
                                              :~  [%col1 [~.t 'Default2']]
                                                  [%col2 [~.p ~zod]]
                                                  [%col3 [~.ud 0]]
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
::  predicate, 3 columns, three updates
::++  test-update-08
::  =|  run=@ud
::  %:  execut  :-  run
::                  :*  %-  zing
::                          "CREATE DATABASE db1;"
::                          create-table
::                          insert-table
::                          ==
::                      ::
::                      ""
::                      ::
::                      ""
::                      ::
::                      ""
::                      ::
::                      :~  %results
::                          [%message 'SELECT']
::                          :-  %result-set
::                              :~
::                                :-  %vector
::                                    :~  [%col1 [~.t 'cord2']]
::                                        [%col2 [~.p ~nomryg-nilref]]
::                                        [%col3 [~.ud 20]]
::                                        ==
::                                :-  %vector
::                                    :~  [%col1 [~.t 'Default2']]
::                                        [%col2 [~.p ~zod]]
::                                        [%col3 [~.ud 0]]
::                                        ==
::                                ==
::                          [%server-time ~2012.5.3]
::                          [%message 'db1.dbo.my-table']
::                          [%schema-time ~2012.5.1]
::                          [%data-time ~2012.5.2]
::                          [%vector-count 2]
::                          ==
::                      ==
::
::  predicate, one key column, changes canonical order
++  test-update-09
  =|  run=@ud
  %-  execut  :*  run
                  %-  zing  :~  "CREATE DATABASE db1;"
                                create-table
                                insert-table
                                ==
                  ::
                  "update foo set col1='hello'"
                  ::
                  "FROM my-table ".
                  "SELECT *"
                  ::
                  [%results ~]
                  ::
                  :-  %results  :~  [%message 'SELECT']
                                    :-  %result-set
                                        :~
                                          :-  %vector
                                              :~  [%col1 [~.t 'cord2']]
                                                  [%col2 [~.p ~nomryg-nilref]]
                                                  [%col3 [~.ud 20]]
                                                  ==
                                          :-  %vector
                                              :~  [%col1 [~.t 'Default2']]
                                                  [%col2 [~.p ~zod]]
                                                  [%col3 [~.ud 0]]
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
::  predicate, all columns, one update
++  test-update-10
  =|  run=@ud
  %-  execut  :*  run
                  %-  zing  :~  "CREATE DATABASE db1;"
                                create-table
                                insert-table
                                ==
                  ::
                  "update foo set col1='hello'"
                  ::
                  "FROM my-table ".
                  "SELECT *"
                  ::
                  [%results ~]
                  ::
                  :-  %results  :~  [%message 'SELECT']
                                    :-  %result-set
                                        :~
                                          :-  %vector
                                              :~  [%col1 [~.t 'cord2']]
                                                  [%col2 [~.p ~nomryg-nilref]]
                                                  [%col3 [~.ud 20]]
                                                  ==
                                          :-  %vector
                                              :~  [%col1 [~.t 'Default2']]
                                                  [%col2 [~.p ~zod]]
                                                  [%col3 [~.ud 0]]
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
::  predicate, no updates
++  test-update-11
  =|  run=@ud
  %-  execut  :*  run
                  %-  zing  :~  "CREATE DATABASE db1;"
                                create-table
                                insert-table
                                ==
                  ::
                  "update foo set col1='hello'"
                  ::
                  "FROM my-table ".
                  "SELECT *"
                  ::
                  [%results ~]
                  ::
                  :-  %results  :~  [%message 'SELECT']
                                    :-  %result-set
                                        :~
                                          :-  %vector
                                              :~  [%col1 [~.t 'cord2']]
                                                  [%col2 [~.p ~nomryg-nilref]]
                                                  [%col3 [~.ud 20]]
                                                  ==
                                          :-  %vector
                                              :~  [%col1 [~.t 'Default2']]
                                                  [%col2 [~.p ~zod]]
                                                  [%col3 [~.ud 0]]
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
::  predicate, AS OF = prior data state, one update
::++  test-update-12
::  =|  run=@ud
::  %:  execut  :-  run
::                  :*  %-  zing
::                          "CREATE DATABASE db1;"
::                          create-table
::                          insert-table
::                          ==
::                      ::
::                      ""
::                      ::
::                      ""
::                      ::
::                      ~[%results ~]
::                      ::
::                      :~  %results
::                          [%message 'SELECT']
::                          :-  %result-set
::                              :~
::                                :-  %vector
::                                    :~  [%col1 [~.t 'cord2']]
::                                        [%col2 [~.p ~nomryg-nilref]]
::                                        [%col3 [~.ud 20]]
::                                        ==
::                                :-  %vector
::                                    :~  [%col1 [~.t 'Default2']]
::                                        [%col2 [~.p ~zod]]
::                                        [%col3 [~.ud 0]]
::                                        ==
::                                ==
::                          [%server-time ~2012.5.3]
::                          [%message 'db1.dbo.my-table']
::                          [%schema-time ~2012.5.1]
::                          [%data-time ~2012.5.2]
::                          [%vector-count 2]
::                          ==
::                      ==
::
::  predicate, AS OF > prior data state, one update
::++  test-update-13
::  =|  run=@ud
::  =/  bar=[@ud tape tape tape cmd-result md-result]
::        :*  run
::            %-  zing    "CREATE DATABASE db1;"
::                      create-table
::                      insert-table
::                      ==
::            ::
::            " "
::            ::
::            " "
::            ::
::            [%results ~]
::            ::
::            :-  %results
::                :~  [%message 'SELECT']
::                    :-  %result-set
::                        :~  :-  %vector
::                                :~  [%col1 [~.t 'cord2']]
::                                    [%col2 [~.p ~nomryg-nilref]]
::                                    [%col3 [~.ud 20]]
::                                    ==
::                            :-  %vector
::                                :~  [%col1 [~.t 'Default2']]
::                                    [%col2 [~.p ~zod]]
::                                    [%col3 [~.ud 0]]
::                                    ==
::                            ==
::                    [%server-time ~2012.5.3]
::                    [%message 'db1.dbo.my-table']
::                    [%schema-time ~2012.5.1]
::                    [%data-time ~2012.5.2]
::                    [%vector-count 2]
::                    ==
::            ==
::  (execut bar)
::
::  predicate, AS OF > prior data state, one update, same script
++  test-update-14
  =|  run=@ud
  %-  execut  :*  run
                  %-  zing  :~  "CREATE DATABASE db1;"
                                create-table
                                insert-table
                                ==
                  ::
                  "update foo set col1='hello'"
                  ::
                  "FROM my-table ".
                  "SELECT *"
                  ::
                  [%results ~]
                  ::
                  :-  %results  :~  [%message 'SELECT']
                                    :-  %result-set
                                        :~
                                          :-  %vector
                                              :~  [%col1 [~.t 'cord2']]
                                                  [%col2 [~.p ~nomryg-nilref]]
                                                  [%col3 [~.ud 20]]
                                                  ==
                                          :-  %vector
                                              :~  [%col1 [~.t 'Default2']]
                                                  [%col2 [~.p ~zod]]
                                                  [%col3 [~.ud 0]]
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
::  fail on no predicate, create dup key
::++  test-fail-update-00
::  =|  run=@ud
::  %:  failon  :*    run
::                  %-  zing
::                          "CREATE DATABASE db1;"
::                          create-table
::                          insert-table
::                          ==
::                      ::
::                      ""
::                      ::
::                      ""
::                      ::
::                      ""
::                      ::
::                      ""
::                      ==
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
::++  test-fail-update-02
::  =|  run=@ud
::  %:  failon  :*  run
::                  %-  zing
::                          "CREATE DATABASE db1;"
::                          create-table
::                          insert-table
::                          ==
::                  ::
::                  ""
::                  ::
::                  ""
::                  ::
::                  ""
::                  ::
::                  ""
::                  ==
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