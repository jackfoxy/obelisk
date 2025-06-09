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
::
::  delete all
++  test-delete-00
  =|  run=@ud
  =/  expected  :~  %results
                    [%message 'DELETE FROM db1.dbo.calendar']
                    [%server-time ~2012.5.3]
                    [%schema-time ~2012.4.30]
                    [%data-time ~2012.4.30]
                    [%message 'deleted:']
                    [%vector-count 13]
                    [%message 'table data:']
                    [%vector-count 0]
                    ==
  =^  mov1  agent
    %+  ~(on-poke agent (bowl [run ~2012.4.30]))
        %obelisk-action
        !>  :+  %tape2
                %db1
                %-  zing  :~  "CREATE DATABASE db1;"
                              create-calendar
                              insert-calendar
                              ==
  =.  run  +(run)
   =^  mov2  agent
    %+  ~(on-poke agent (bowl [run ~2012.5.3]))
        %obelisk-action
        !>  :+  %tape2
                %db1
                "DELETE FROM calendar ".
                "WHERE day-name = 'Sunday' ".
                "   OR day-name = 'Monday' ".
                "   OR day-name = 'Tuesday' ".
                "   OR day-name = 'Wednesday' ".
                "   OR day-name = 'Thursday' ".
                "   OR day-name = 'Friday' ".
                "   OR day-name = 'Saturday' "
  ::
  (eval-results expected ;;(cmd-result ->+>+>+<.mov2))
::
::  delete none
++  test-delete-01
  =|  run=@ud
  =/  expected  :~  %results
                    [%message 'DELETE FROM db1.dbo.calendar']
                    [%server-time ~2012.5.3]
                    [%schema-time ~2012.4.30]
                    [%data-time ~2012.4.30]
                    [%message 'no rows deleted']
                    ==
  =^  mov1  agent
    %+  ~(on-poke agent (bowl [run ~2012.4.30]))
        %obelisk-action
        !>  :+  %tape2
                %db1
                %-  zing  :~  "CREATE DATABASE db1;"
                              create-calendar
                              insert-calendar
                              ==
  =.  run  +(run)
   =^  mov2  agent
    %+  ~(on-poke agent (bowl [run ~2012.5.3]))
        %obelisk-action
        !>  :+  %tape2
                %db1
                "DELETE calendar ".
                "WHERE day-name = 'asdf'"
  ::
  (eval-results expected ;;(cmd-result ->+>+>+<.mov2))
::
::  delete delete 2 rows
++  test-delete-02
  =|  run=@ud
  =/  expected  :~  %results
                    [%message 'DELETE FROM db1.dbo.calendar']
                    [%server-time ~2012.5.3]
                    [%schema-time ~2012.4.30]
                    [%data-time ~2012.4.30]
                    [%message 'deleted:']
                    [%vector-count 2]
                    [%message 'table data:']
                    [%vector-count 11]
                    ==
  =^  mov1  agent
    %+  ~(on-poke agent (bowl [run ~2012.4.30]))
        %obelisk-action
        !>  :+  %tape2
                %db1
                %-  zing  :~  "CREATE DATABASE db1;"
                              create-calendar
                              insert-calendar
                              ==
  =.  run  +(run)
   =^  mov2  agent
    %+  ~(on-poke agent (bowl [run ~2012.5.3]))
        %obelisk-action
        !>  :+  %tape2
                %db1
                "DELETE calendar ".
                "WHERE day-name = 'Monday'"
  ::
  (eval-results expected ;;(cmd-result ->+>+>+<.mov2))
::
::  delete all but 1
++  test-delete-03
  =|  run=@ud
  =/  expected  :~  %results
                    [%message 'DELETE FROM db1.dbo.calendar']
                    [%server-time ~2012.5.3]
                    [%schema-time ~2012.4.30]
                    [%data-time ~2012.4.30]
                    [%message 'deleted:']
                    [%vector-count 12]
                    [%message 'table data:']
                    [%vector-count 1]
                    ==
  =^  mov1  agent
    %+  ~(on-poke agent (bowl [run ~2012.4.30]))
        %obelisk-action
        !>  :+  %tape2
                %db1
                %-  zing  :~  "CREATE DATABASE db1;"
                              create-calendar
                              insert-calendar
                              ==
  =.  run  +(run)
  =^  mov2  agent
    %+  ~(on-poke agent (bowl [run ~2012.5.3]))
        %obelisk-action
        !>  :+  %tape2
                %db1
                "DELETE FROM calendar ".
                "WHERE day-name = 'Sunday' ".
                "   OR day-name = 'Monday' ".
                "   OR day-name = 'Tuesday' ".
                "   OR day-name = 'Wednesday' ".
                "   OR day-name = 'Thursday' ".
                "   OR day-name = 'Friday' ".
                "   OR (day-name = 'Saturday' ".
                "       AND day-of-year = 357) "
  ::
  (eval-results expected ;;(cmd-result ->+>+>+<.mov2))
::
::  delete all but 1 FROM AS OF > data time
++  test-delete-04
  =|  run=@ud
  =/  expected-delete  :~  %results
                           [%message 'DELETE FROM db1.dbo.calendar']
                           [%server-time ~2012.5.3]
                           [%schema-time ~2012.4.30]
                           [%data-time ~2012.4.30]
                           [%message 'deleted:']
                           [%vector-count 12]
                           [%message 'table data:']
                           [%vector-count 1]
                           ==
  =/  expected-rows  :~  :-  %vector
                             :~  [%date [~.da ~2023.12.30]]
                                 [%year [~.ud 2.023]]
                                 [%month [~.ud 12]]
                                 [%month-name [~.t 'December']]
                                 [%day [~.ud 30]]
                                 [%day-name [~.t 'Saturday']]
                                 [%day-of-year [~.ud 364]]
                                 [%weekday [~.ud 7]]
                                 [%year-week [~.ud 52]]
                                 ==
                         ==
  =/  expected-after-delete  :-  %results
                                 :~  [%message 'SELECT']
                                     [%result-set expected-rows]
                                     [%server-time ~2012.5.4]
                                     [%message 'db1.dbo.calendar']
                                     [%schema-time ~2012.4.30]
                                     [%data-time ~2012.5.3]
                                     [%vector-count 1]
                                 ==
  =^  mov1  agent
    %+  ~(on-poke agent (bowl [run ~2012.4.30]))
        %obelisk-action
        !>  :+  %tape2
                %db1
                %-  zing  :~  "CREATE DATABASE db1;"
                              create-calendar
                              insert-calendar
                              ==
  =.  run  +(run)
  =^  mov2  agent
    %+  ~(on-poke agent (bowl [run ~2012.5.2]))
        %obelisk-action
        !>  :+  %tape2
                %db1
                "INSERT INTO calendar ".
                "VALUES ".
                "(~2024.1.6, 2024, 1, 'January', 6, 'Saturday', 6, 7, 1) ".
                "(~2024.1.13, 2024, 1, 'January', 13, 'Saturday', 13, 7, 2) ".
                "(~2024.1.20, 2024, 1, 'January', 20, 'Saturday', 20, 7, 3) "
  =.  run  +(run)
   =^  mov3  agent
    %+  ~(on-poke agent (bowl [run ~2012.5.3]))
        %obelisk-action
        !>  :+  %tape2
                %db1
                "DELETE FROM calendar AS OF ~2012.5.1 ".
                "WHERE day-name = 'Sunday' ".
                "   OR day-name = 'Monday' ".
                "   OR day-name = 'Tuesday' ".
                "   OR day-name = 'Wednesday' ".
                "   OR day-name = 'Thursday' ".
                "   OR day-name = 'Friday' ".
                "   OR (day-name = 'Saturday' ".
                "       AND day-of-year = 357) "
  =.  run  +(run)
  =^  mov4  agent
    %+  ~(on-poke agent (bowl [run ~2012.5.4]))
        %obelisk-action
        !>([%tape2 %db1 "FROM calendar SELECT *"])
  ::
  %+  weld  (eval-results expected-delete ;;(cmd-result ->+>+>+<.mov3))
            (eval-results expected-after-delete ;;(cmd-result ->+>+>+<.mov4))
::
::  delete all but 1 FROM AS OF = data time
++  test-delete-05
  =|  run=@ud
  =/  expected-delete  :~  %results
                           [%message 'DELETE FROM db1.dbo.calendar']
                           [%server-time ~2012.5.3]
                           [%schema-time ~2012.4.30]
                           [%data-time ~2012.4.30]
                           [%message 'deleted:']
                           [%vector-count 12]
                           [%message 'table data:']
                           [%vector-count 1]
                           ==
  =/  expected-rows  :~  :-  %vector
                             :~  [%date [~.da ~2023.12.30]]
                                 [%year [~.ud 2.023]]
                                 [%month [~.ud 12]]
                                 [%month-name [~.t 'December']]
                                 [%day [~.ud 30]]
                                 [%day-name [~.t 'Saturday']]
                                 [%day-of-year [~.ud 364]]
                                 [%weekday [~.ud 7]]
                                 [%year-week [~.ud 52]]
                                 ==
                         ==
  =/  expected-after-delete  :-  %results
                                 :~  [%message 'SELECT']
                                     [%result-set expected-rows]
                                     [%server-time ~2012.5.4]
                                     [%message 'db1.dbo.calendar']
                                     [%schema-time ~2012.4.30]
                                     [%data-time ~2012.5.3]
                                     [%vector-count 1]
                                 ==
  =^  mov1  agent
    %+  ~(on-poke agent (bowl [run ~2012.4.30]))
        %obelisk-action
        !>  :+  %tape2
                %db1
                %-  zing  :~  "CREATE DATABASE db1;"
                              create-calendar
                              insert-calendar
                              ==
  =.  run  +(run)
  =^  mov2  agent
    %+  ~(on-poke agent (bowl [run ~2012.5.2]))
        %obelisk-action
        !>  :+  %tape2
                %db1
                "INSERT INTO calendar ".
                "VALUES ".
                "(~2024.1.6, 2024, 1, 'January', 6, 'Saturday', 6, 7, 1) ".
                "(~2024.1.13, 2024, 1, 'January', 13, 'Saturday', 13, 7, 2) ".
                "(~2024.1.20, 2024, 1, 'January', 20, 'Saturday', 20, 7, 3) "
  =.  run  +(run)
   =^  mov3  agent
    %+  ~(on-poke agent (bowl [run ~2012.5.3]))
        %obelisk-action
        !>  :+  %tape2
                %db1
                "DELETE FROM calendar AS OF ~2012.4.30 ".
                "WHERE day-name = 'Sunday' ".
                "   OR day-name = 'Monday' ".
                "   OR day-name = 'Tuesday' ".
                "   OR day-name = 'Wednesday' ".
                "   OR day-name = 'Thursday' ".
                "   OR day-name = 'Friday' ".
                "   OR (day-name = 'Saturday' ".
                "       AND day-of-year = 357) "
  =.  run  +(run)
  =^  mov4  agent
    %+  ~(on-poke agent (bowl [run ~2012.5.4]))
        %obelisk-action
        !>([%tape2 %db1 "FROM calendar SELECT *"])
  ::
  %+  weld  (eval-results expected-delete ;;(cmd-result ->+>+>+<.mov3))
            (eval-results expected-after-delete ;;(cmd-result ->+>+>+<.mov4))
::
::  DELETE followed by DELETE AS OF in same script
++  test-delete-06
  =|  run=@ud
  =/  expected-deletes  :~  :-  %results
                                :~  [%message 'DELETE FROM db1.dbo.calendar']
                                    [%server-time ~2012.5.3]
                                    [%schema-time ~2012.4.30]
                                    [%data-time ~2012.5.2]
                                    [%message 'deleted:']
                                    [%vector-count 5]
                                    [%message 'table data:']
                                    [%vector-count 11]
                                    ==
                            :-  %results
                                :~  [%message 'DELETE FROM db1.dbo.calendar']
                                    [%server-time ~2012.5.3]
                                    [%schema-time ~2012.4.30]
                                    [%data-time ~2012.4.30]
                                    [%message 'deleted:']
                                    [%vector-count 12]
                                    [%message 'table data:']
                                    [%vector-count 1]
                                    ==
                            ==
  =/  expected-rows  :~  :-  %vector
                             :~  [%date [~.da ~2023.12.30]]
                                 [%year [~.ud 2.023]]
                                 [%month [~.ud 12]]
                                 [%month-name [~.t 'December']]
                                 [%day [~.ud 30]]
                                 [%day-name [~.t 'Saturday']]
                                 [%day-of-year [~.ud 364]]
                                 [%weekday [~.ud 7]]
                                 [%year-week [~.ud 52]]
                                 ==
                         ==
  =/  expected-select  :-  %results
                                 :~  [%message 'SELECT']
                                     [%result-set expected-rows]
                                     [%server-time ~2012.5.4]
                                     [%message 'db1.dbo.calendar']
                                     [%schema-time ~2012.4.30]
                                     [%data-time ~2012.5.3]
                                     [%vector-count 1]
                                     ==
  =^  mov1  agent
    %+  ~(on-poke agent (bowl [run ~2012.4.30]))
        %obelisk-action
        !>  :+  %tape2
                %db1
                %-  zing  :~  "CREATE DATABASE db1;"
                              create-calendar
                              insert-calendar
                              ==
  =.  run  +(run)
  =^  mov2  agent
    %+  ~(on-poke agent (bowl [run ~2012.5.2]))
        %obelisk-action
        !>  :+  %tape2
                %db1
                "INSERT INTO calendar ".
                "VALUES ".
                "(~2024.1.6, 2024, 1, 'January', 6, 'Saturday', 6, 7, 1) ".
                "(~2024.1.13, 2024, 1, 'January', 13, 'Saturday', 13, 7, 2) ".
                "(~2024.1.20, 2024, 1, 'January', 20, 'Saturday', 20, 7, 3) "
  =.  run  +(run)
   =^  mov3  agent
    %+  ~(on-poke agent (bowl [run ~2012.5.3]))
        %obelisk-action
        !>  :+  %tape2
                %db1
                "DELETE FROM calendar ".
                "WHERE day-name = 'Saturday'; ".
                "DELETE FROM calendar AS OF ~2012.5.1 ".
                "WHERE day-name = 'Sunday' ".
                "   OR day-name = 'Monday' ".
                "   OR day-name = 'Tuesday' ".
                "   OR day-name = 'Wednesday' ".
                "   OR day-name = 'Thursday' ".
                "   OR day-name = 'Friday' ".
                "   OR (day-name = 'Saturday' ".
                "       AND day-of-year = 357) "
  =.  run  +(run)
  =^  mov4  agent
    %+  ~(on-poke agent (bowl [run ~2012.5.4]))
        %obelisk-action
        !>([%tape2 %db1 "FROM calendar SELECT *"])
  ::
  %+  weld  %+  expect-eq
                !>  expected-deletes
                !>  ;;((list cmd-result) ->+>+>+.mov3)
            (eval-results expected-select ;;(cmd-result ->+>+>+<.mov4))
::
::  DELETE AS OF followed by DELETE in same script
++  test-delete-07
  =|  run=@ud
  =/  expected-deletes  :~  :-  %results
                                :~  [%message 'DELETE FROM db1.dbo.calendar']
                                    [%server-time ~2012.5.3]
                                    [%schema-time ~2012.4.30]
                                    [%data-time ~2012.4.30]
                                    [%message 'deleted:']
                                    [%vector-count 1]
                                    [%message 'table data:']
                                    [%vector-count 12]
                                    ==
                            :-  %results
                                :~  [%message 'DELETE FROM db1.dbo.calendar']
                                    [%server-time ~2012.5.3]
                                    [%schema-time ~2012.4.30]
                                    [%data-time ~2012.5.3]
                                    [%message 'deleted:']
                                    [%vector-count 5]
                                    [%message 'table data:']
                                    [%vector-count 7]
                                    ==
                            ==
  =/  expected-rows  :~   :-  %vector
                              :~  [%date [~.da ~2023.12.21]]
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
                              :~  [%date [~.da ~2023.12.25]]
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
                              :~  [%date [~.da ~2023.12.26]]
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
                              :~  [%date [~.da ~2023.12.28]]
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
                              :~  [%date [~.da ~2023.12.30]]
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
                              :~  [%date [~.da ~2024.1.1]]
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
                              :~  [%date [~.da ~2024.1.2]]
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
  =/  expected-select  :-  %results
                           :~  [%message 'SELECT']
                               [%result-set expected-rows]
                               [%server-time ~2012.5.4]
                               [%message 'db1.dbo.calendar']
                               [%schema-time ~2012.4.30]
                               [%data-time ~2012.5.3]
                               [%vector-count 7]
                               ==
  =^  mov1  agent
    %+  ~(on-poke agent (bowl [run ~2012.4.30]))
        %obelisk-action
        !>  :+  %tape2
                %db1
                %-  zing  :~  "CREATE DATABASE db1;"
                              create-calendar
                              insert-calendar
                              ==
  =.  run  +(run)
  =^  mov2  agent
    %+  ~(on-poke agent (bowl [run ~2012.5.2]))
        %obelisk-action
        !>  :+  %tape2
                %db1
                "INSERT INTO calendar ".
                "VALUES ".
                "(~2024.1.6, 2024, 1, 'January', 6, 'Saturday', 6, 7, 1) ".
                "(~2024.1.13, 2024, 1, 'January', 13, 'Saturday', 13, 7, 2) ".
                "(~2024.1.20, 2024, 1, 'January', 20, 'Saturday', 20, 7, 3) "
  =.  run  +(run)
   =^  mov3  agent
    %+  ~(on-poke agent (bowl [run ~2012.5.3]))
        %obelisk-action
        !>  :+  %tape2
                %db1
                "DELETE FROM calendar AS OF ~2012.5.1 ".
                "WHERE day-name = 'Wednesday'; ".
                "DELETE FROM calendar ".
                "WHERE day-name = 'Sunday' ".
                "   OR day-name = 'Friday' ".
                "   OR (day-name = 'Saturday' ".
                "       AND day-of-year = 357) "
  =.  run  +(run)
  =^  mov4  agent
    %+  ~(on-poke agent (bowl [run ~2012.5.4]))
        %obelisk-action
        !>([%tape2 %db1 "FROM calendar SELECT *"])
  ::
  %+  weld  %+  expect-eq
                !>  expected-deletes
                !>  ;;((list cmd-result) ->+>+>+.mov3)
            (eval-results expected-select ;;(cmd-result ->+>+>+<.mov4))
::
::  DELETE then INSERT same key
++  test-delete-08
  =|  run=@ud
  =/  expected-rows  :~   :-  %vector
                              :~  [%date [~.da ~2024.1.6]]
                                  [%year [~.ud 2.024]]
                                  [%month [~.ud 1]]
                                  [%month-name [~.t 'January']]
                                  [%day [~.ud 6]]
                                  [%day-name [~.t 'Saturday']]
                                  [%day-of-year [~.ud 6]]
                                  [%weekday [~.ud 7]]
                                  [%year-week [~.ud 1]]
                                  ==
                          :-  %vector
                              :~  [%date [~.da ~2024.1.13]]
                                  [%year [~.ud 2.024]]
                                  [%month [~.ud 1]]
                                  [%month-name [~.t 'January']]
                                  [%day [~.ud 13]]
                                  [%day-name [~.t 'Weekendday']]
                                  [%day-of-year [~.ud 13]]
                                  [%weekday [~.ud 7]]
                                  [%year-week [~.ud 2]]
                                  ==
                          :-  %vector
                              :~  [%date [~.da ~2024.1.20]]
                                  [%year [~.ud 2.024]]
                                  [%month [~.ud 1]]
                                  [%month-name [~.t 'January']]
                                  [%day [~.ud 20]]
                                  [%day-name [~.t 'Saturday']]
                                  [%day-of-year [~.ud 20]]
                                  [%weekday [~.ud 7]]
                                  [%year-week [~.ud 3]]
                                  ==
                          ==
  =/  expected-select  :-  %results
                           :~  [%message 'SELECT']
                               [%result-set expected-rows]
                               [%server-time ~2012.5.4]
                               [%message 'db1.dbo.calendar']
                               [%schema-time ~2012.4.30]
                               [%data-time ~2012.5.3]
                               [%vector-count 3]
                               ==
  =^  mov1  agent
    %+  ~(on-poke agent (bowl [run ~2012.4.30]))
        %obelisk-action
        !>  :+  %tape2
                %db1
                %-  zing  :~  "CREATE DATABASE db1;"
                              create-calendar
                              ==
  =.  run  +(run)
  =^  mov2  agent
    %+  ~(on-poke agent (bowl [run ~2012.5.2]))
        %obelisk-action
        !>  :+  %tape2
                %db1
                "INSERT INTO calendar ".
                "VALUES ".
                "(~2024.1.6, 2024, 1, 'January', 6, 'Saturday', 6, 7, 1) ".
                "(~2024.1.13, 2024, 1, 'January', 13, 'Saturday', 13, 7, 2) ".
                "(~2024.1.20, 2024, 1, 'January', 20, 'Saturday', 20, 7, 3) "
  =.  run  +(run)
   =^  mov3  agent
    %+  ~(on-poke agent (bowl [run ~2012.5.3]))
        %obelisk-action
        !>  :+  %tape2
                %db1
                "DELETE FROM calendar ".
                "WHERE day-name = 'Saturday' ".
                "  AND day-of-year = 13; ".
                "INSERT INTO calendar ".
                "VALUES ".
                "(~2024.1.13, 2024, 1, 'January', 13, 'Weekendday', 13, 7, 2) "
  =.  run  +(run)
  =^  mov4  agent
    %+  ~(on-poke agent (bowl [run ~2012.5.4]))
        %obelisk-action
        !>([%tape2 %db1 "FROM calendar SELECT *"])
  ::
  (eval-results expected-select ;;(cmd-result ->+>+>+<.mov4))
::
::  fail on no predicate
++  test-fail-delete-00
  =|  run=@ud
  =^  mov1  agent
    %+  ~(on-poke agent (bowl [run ~2012.4.30]))
        %obelisk-action
        !>  :+  %tape2
                %db1
                %-  zing  :~  "CREATE DATABASE db1;"
                              create-calendar
                              insert-calendar
                              ==
  ::
  %+  expect-fail-message
        'PARSER:'
  |.  %+  ~(on-poke agent (bowl [run ~2012.5.3]))
          %obelisk-action
          !>  :+  %test
                  %db1
                  "DELETE FROM calendar "
::
::  fail on changing state after select in script
++  test-fail-delete-01
  =|  run=@ud
  =^  mov1  agent
    %+  ~(on-poke agent (bowl [run ~2000.1.1]))
        %obelisk-action
        !>([%tape2 %sys "CREATE DATABASE db1"])
  =.  run  +(run)
  ::
  %+  expect-fail-message
        'DELETE: state change after query in script'
  |.  %+  ~(on-poke agent (bowl [run ~2000.1.2]))
          %obelisk-action
          !>  :+  %test
                  %db1
                  "CREATE TABLE db1..my-table (col1 @t) PRIMARY KEY (col1); ".
                  "SELECT 0;".
                  "DELETE FROM calendar ".
                  "WHERE 1 = 1 "
--