::  Unit testing cte queries and data mutation on a Gall agent with %obelisk.
::
/-  ast, *obelisk, *server-state
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
                  "       (~2010.5.31, 'Default',~nec, 1,Default) ".
                  "       (~2010.5.31, 'Default',~bus, 2,Default) ".
                  "       (~2010.6.30, 'zod man',~zod, 3,~2010.6.1) ".
                  "       (~2010.3.23, '~num galaxy',~num, 4,~2010.3.3) ".
                  "       (~2012.2.29, 'rygged',~rus, 5,~2012.2.1); "
::
::  [@ud tape tape cmd-result cmd-result] -> 
++  execute-111
  |=  $:  run=@ud
          init=tape
          resolve=tape
          expect1=cmd-result
          ==
  =^  mov1  agent
  %+  ~(on-poke agent (bowl [run ~2012.4.30]))
      %obelisk-action
      !>  [%tape2 %db1 init]                  :: <== initialize the DB
  
  =^  mov2  agent
  %+  ~(on-poke agent (bowl [run ~2012.5.3]))
      %obelisk-action
      !>  [%tape2 %db1 resolve]               :: <== SELECT
  ::
  (eval-results expect1 ;;(cmd-result ->+>+>+<.mov2))

  ::
  ::%+  expect-fail-message
  ::      'table %db1.%dbo.%my-table does not exist at schema time ~2012.4.30'
  ::|.  %+  ~(on-poke agent (bowl [run ~2012.5.2]))
  ::        %obelisk-action
  ::        !>([%test %db1 resolve])

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
  %+  weld  (eval-results expect1 ;;(cmd-result ->+>+>+<.mov4))
            (eval-results expect2 ;;(cmd-result ->+>+>+<.mov5))
::
::
++  failon
  |=  [run=@ud init=tape action=tape expect1=@t]
  =^  mov1  agent
  %+  ~(on-poke agent (bowl [run ~2012.4.30]))
      %obelisk-action
      !>  [%tape2 %db1 init]                        :: <==
  ::
  %+  expect-fail-message
      expect1
      |.  %+  ~(on-poke agent (bowl [run ~2012.5.5]))
              %obelisk-action
              !>  [%test %db1 action]
::
::
::  simple query of cte, SELECT *
++  test-cte-00
  =|  run=@ud
  %-  execute-111
        :*  run
            %-  zing  :~  "CREATE DATABASE db1;"
                          create-table
                          insert-table
                          ==
            ::
            "WITH (FROM my-table ".
            "      SELECT *) AS my-cte ".
            "FROM my-cte SELECT * "
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
                                            [%col3 [~.ud 1]]
                                            [%col4 [~.da ~2000.1.1]]
                                            ==
                                    :-  %vector
                                        :~  [%col0 [~.da ~2010.5.31]]
                                            [%col1 [~.t 'Default']]
                                            [%col2 [~.p ~bus]]
                                            [%col3 [~.ud 2]]
                                            [%col4 [~.da ~2000.1.1]]
                                            ==
                                    :-  %vector
                                        :~  [%col0 [~.da ~2010.6.30]]
                                            [%col1 [~.t 'zod man']]
                                            [%col2 [~.p ~zod]]
                                            [%col3 [~.ud 3]]
                                            [%col4 [~.da ~2010.6.1]]
                                            ==
                                    :-  %vector
                                        :~  [%col0 [~.da ~2010.3.23]]
                                            [%col1 [~.t '~num galaxy']]
                                            [%col2 [~.p ~num]]
                                            [%col3 [~.ud 4]]
                                            [%col4 [~.da ~2010.3.3]]
                                            ==
                                    :-  %vector
                                        :~  [%col0 [~.da ~2012.2.29]]
                                            [%col1 [~.t 'rygged']]
                                            [%col2 [~.p ~rus]]
                                            [%col3 [~.ud 5]]
                                            [%col4 [~.da ~2012.2.1]]
                                            ==

                                    ==
                              [%server-time ~2012.5.3]
                              [%message 'db1.dbo.my-table']
                              [%schema-time ~2012.4.30]
                              [%data-time ~2012.4.30]
                              [%vector-count 7]
                              ==
            ==
--