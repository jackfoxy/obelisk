::  Unit testing cte queries and data mutation on a Gall agent with %obelisk.
::
/+  *test-helpers
|%
::
++  create-table              "CREATE TABLE db1..my-table ".
                              "(col0 @da, col1 @t, col2 @p, col3 @ud, col4 @da) ".
                              "PRIMARY KEY (col0, col2);"
::
++  create-calendar           "CREATE TABLE calendar ".
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
::
++  create-holiday-calendar   "CREATE TABLE holiday-calendar ".
                              "(date @da, us-federal-holiday @t) ".
                              "PRIMARY KEY (date);"
::
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
++  insert-holiday-calendar
  "INSERT INTO holiday-calendar ".
  "(date, us-federal-holiday) ".
  "VALUES ".
  "(~2023.11.23, 'Thanksgiving Day') ".
  "(~2023.12.25, 'Christmas Day') ".
  "(~2024.1.1, 'New Years Day') ".
  "(~2024.1.15, 'Birthday of Martin Luther King Jr.');"
::
++  insert-table
  "INSERT INTO db1..my-table (col0, col1, col2, col3, col4) ".
  "VALUES (~2010.5.3, 'cord',~nomryg-nilref,20,Default) ".
  "       (~2010.5.31, 'Default',Default, 0,Default) ".
  "       (~2010.5.31, 'Default',~nec, 1,Default) ".
  "       (~2010.5.31, 'Default',~bus, 2,Default) ".
  "       (~2010.6.30, 'zod man',~zod, 3,~2010.6.1) ".
  "       (~2010.3.23, '~num galaxy',~num, 4,~2010.3.3) ".
  "       (~2012.2.29, 'rygged',~rus, 5,~2012.2.1); "
::
::  simple query of cte, SELECT *
++  test-cte-00
  =|  run=@ud
  %-  exec-0-1
  ::%-    debug-0-1
        :*  run
            :+  ~2012.4.30
                %db1
                %-  zing  :~  "CREATE DATABASE db1;"
                              create-table
                              insert-table
                              ==
            ::
            :+  ~2012.5.3
                %db1
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
::
::  simple query of joined, filtered cte, SELECT *
++  test-cte-01
  =|  run=@ud
  =/  expected-rows
        :~   :-  %vector
                :~  [%day-name [~.t 'Monday']]
                    [%date [~.da ~2023.12.25]]
                    [%us-federal-holiday [~.t 'Christmas Day']]
                    [%fed [~.t 'Christmas Day']]
                    ==
            ==
  %-  exec-0-1
  ::%-  debug-0-1
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
                "WITH (FROM calendar t1 ".
                      "JOIN holiday-calendar T2 ".
                      "WHERE T1.day-name = 'Monday' ".
                      "  AND t2.us-federal-holiday = 'Christmas Day' ".
                      "SELECT T1.day-name, t2.*, ".
                            "t2.us-federal-holiday as fed) ".
                      "AS my-cte ".
                "FROM my-cte SELECT * "
            ::
            :-  %results  :~  [%message 'SELECT']
                              [%result-set expected-rows]
                              [%server-time ~2012.5.3]
                              [%message 'db1.dbo.calendar']
                              [%schema-time ~2012.4.30]
                              [%data-time ~2012.4.30]
                              [%message msg='db1.dbo.holiday-calendar']
                              [%schema-time date=~2012.4.30]
                              [%data-time date=~2012.4.30]
                              [%vector-count 1]
                              ==
            ==
::
::  CTE with JOIN, specific columns only (no wildcards), outer SELECT *
++  test-cte-02
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
                "WITH (FROM calendar T1 ".
                      "JOIN holiday-calendar T2 ".
                      "SELECT T1.day-name, T2.date, T2.us-federal-holiday) ".
                      "AS my-cte ".
                "FROM my-cte SELECT * "
            ::
            :-  %results  :~  [%message 'SELECT']
                              [%result-set expected-rows]
                              [%server-time ~2012.5.3]
                              [%message 'db1.dbo.calendar']
                              [%schema-time ~2012.4.30]
                              [%data-time ~2012.4.30]
                              [%message msg='db1.dbo.holiday-calendar']
                              [%schema-time date=~2012.4.30]
                              [%data-time date=~2012.4.30]
                              [%vector-count 2]
                              ==
            ==
::
::  CTE with JOIN + WHERE predicate, outer SELECT *
++  test-cte-03
  =|  run=@ud
  =/  expected-rows
        :~  :-  %vector
                :~  [%day-name [~.t 'Monday']]
                    [%date [~.da ~2023.12.25]]
                    [%us-federal-holiday [~.t 'Christmas Day']]
                    ==
            ==
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
                "WITH (FROM calendar T1 ".
                      "JOIN holiday-calendar T2 ".
                      "WHERE T2.us-federal-holiday = 'Christmas Day' ".
                      "SELECT T1.day-name, T2.date, ".
                            "T2.us-federal-holiday) ".
                      "AS my-cte ".
                "FROM my-cte SELECT * "
            ::
            :-  %results  :~  [%message 'SELECT']
                              [%result-set expected-rows]
                              [%server-time ~2012.5.3]
                              [%message 'db1.dbo.calendar']
                              [%schema-time ~2012.4.30]
                              [%data-time ~2012.4.30]
                              [%message msg='db1.dbo.holiday-calendar']
                              [%schema-time date=~2012.4.30]
                              [%data-time date=~2012.4.30]
                              [%vector-count 1]
                              ==
            ==
::
::  CTE with JOIN + column aliases to avoid duplicates, outer SELECT *
++  test-cte-04
  =|  run=@ud
  =/  expected-rows
        :~  :-  %vector
                :~  [%cal-date [~.da ~2023.12.25]]
                    [%day-name [~.t 'Monday']]
                    [%hol-date [~.da ~2023.12.25]]
                    [%us-federal-holiday [~.t 'Christmas Day']]
                    ==
            :-  %vector
                :~  [%cal-date [~.da ~2024.1.1]]
                    [%day-name [~.t 'Monday']]
                    [%hol-date [~.da ~2024.1.1]]
                    [%us-federal-holiday [~.t 'New Years Day']]
                    ==
            ==
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
                "WITH (FROM calendar T1 ".
                      "JOIN holiday-calendar T2 ".
                      "SELECT T1.date AS cal-date, T1.day-name, ".
                            "T2.date AS hol-date, ".
                            "T2.us-federal-holiday) ".
                      "AS my-cte ".
                "FROM my-cte SELECT * "
            ::
            :-  %results  :~  [%message 'SELECT']
                              [%result-set expected-rows]
                              [%server-time ~2012.5.3]
                              [%message 'db1.dbo.calendar']
                              [%schema-time ~2012.4.30]
                              [%data-time ~2012.4.30]
                              [%message msg='db1.dbo.holiday-calendar']
                              [%schema-time date=~2012.4.30]
                              [%data-time date=~2012.4.30]
                              [%vector-count 2]
                              ==
            ==
::
::  CTE with JOIN, outer SELECT specific columns from CTE
++  test-cte-05
  =|  run=@ud
  =/  expected-rows
        :~  :-  %vector
                :~  [%us-federal-holiday [~.t 'Christmas Day']]
                    ==
            :-  %vector
                :~  [%us-federal-holiday [~.t 'New Years Day']]
                    ==
            ==
  %-  exec-0-1
  ::%-  debug-0-1
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
                "WITH (FROM calendar T1 ".
                      "JOIN holiday-calendar T2 ".
                      "SELECT T1.day-name, T2.date, T2.us-federal-holiday) ".
                      "AS my-cte ".
                "FROM my-cte SELECT us-federal-holiday "
            ::
            :-  %results  :~  [%message 'SELECT']
                              [%result-set expected-rows]
                              [%server-time ~2012.5.3]
                              [%message 'db1.dbo.calendar']
                              [%schema-time ~2012.4.30]
                              [%data-time ~2012.4.30]
                              [%message msg='db1.dbo.holiday-calendar']
                              [%schema-time date=~2012.4.30]
                              [%data-time date=~2012.4.30]
                              [%vector-count 2]
                              ==
            ==
::
::  CTE with JOIN, outer SELECT with WHERE predicate on CTE columns
++  test-cte-06
  =|  run=@ud
  =/  expected-rows
        :~  :-  %vector
                :~  [%day-name [~.t 'Monday']]
                    [%date [~.da ~2024.1.1]]
                    [%us-federal-holiday [~.t 'New Years Day']]
                    ==
            ==
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
                "WITH (FROM calendar T1 ".
                      "JOIN holiday-calendar T2 ".
                      "SELECT T1.day-name, T2.date, T2.us-federal-holiday) ".
                      "AS my-cte ".
                "FROM my-cte ".
                "WHERE us-federal-holiday = 'New Years Day' ".
                "SELECT * "
            ::
            :-  %results  :~  [%message 'SELECT']
                              [%result-set expected-rows]
                              [%server-time ~2012.5.3]
                              [%message 'db1.dbo.calendar']
                              [%schema-time ~2012.4.30]
                              [%data-time ~2012.4.30]
                              [%message msg='db1.dbo.holiday-calendar']
                              [%schema-time date=~2012.4.30]
                              [%data-time date=~2012.4.30]
                              [%vector-count 1]
                              ==
            ==
::
::  CTE with JOIN + aliases, outer SELECT specific columns + predicate
++  test-cte-07
  =|  run=@ud
  =/  expected-rows
        :~  :-  %vector
                :~  [%holiday [~.t 'Christmas Day']]
                    ==
            ==
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
                "WITH (FROM calendar T1 ".
                      "JOIN holiday-calendar T2 ".
                      "SELECT T1.day-name, T2.date, ".
                            "T2.us-federal-holiday AS holiday) ".
                      "AS my-cte ".
                "FROM my-cte ".
                "WHERE date = ~2023.12.25 ".
                "SELECT holiday "
            ::
            :-  %results  :~  [%message 'SELECT']
                              [%result-set expected-rows]
                              [%server-time ~2012.5.3]
                              [%message 'db1.dbo.calendar']
                              [%schema-time ~2012.4.30]
                              [%data-time ~2012.4.30]
                              [%message msg='db1.dbo.holiday-calendar']
                              [%schema-time date=~2012.4.30]
                              [%data-time date=~2012.4.30]
                              [%vector-count 1]
                              ==
            ==
::
::  single-table CTE with specific columns, outer SELECT *
++  test-cte-08
  =|  run=@ud
  =/  expected-rows
        :~  :-  %vector
                :~  [%date [~.da ~2023.12.25]]
                    [%us-federal-holiday [~.t 'Christmas Day']]
                    ==
            :-  %vector
                :~  [%date [~.da ~2024.1.1]]
                    [%us-federal-holiday [~.t 'New Years Day']]
                    ==
            :-  %vector
                :~  [%date [~.da ~2024.1.15]]
                    [%us-federal-holiday [~.t 'Birthday of Martin Luther King Jr.']]
                    ==
            :-  %vector
                :~  [%date [~.da ~2023.11.23]]
                    [%us-federal-holiday [~.t 'Thanksgiving Day']]
                    ==
            ==
  %-  exec-0-1
        :*  run
            :+  ~2012.4.30
                %db1
                %-  zing  :~  "CREATE DATABASE db1;"
                              create-holiday-calendar
                              insert-holiday-calendar
                              ==
            ::
            :+  ~2012.5.3
                %db1
                "WITH (FROM holiday-calendar ".
                      "SELECT date, us-federal-holiday) ".
                      "AS hol-cte ".
                "FROM hol-cte SELECT * "
            ::
            :-  %results  :~  [%message 'SELECT']
                              [%result-set expected-rows]
                              [%server-time ~2012.5.3]
                              [%message 'db1.dbo.holiday-calendar']
                              [%schema-time ~2012.4.30]
                              [%data-time ~2012.4.30]
                              [%vector-count 4]
                              ==
            ==
::
::  single-table CTE with WHERE, outer SELECT *
++  test-cte-09
  =|  run=@ud
  =/  expected-rows
        :~  :-  %vector
                :~  [%date [~.da ~2023.12.25]]
                    [%day-name [~.t 'Monday']]
                    [%month-name [~.t 'December']]
                    ==
            :-  %vector
                :~  [%date [~.da ~2024.1.1]]
                    [%day-name [~.t 'Monday']]
                    [%month-name [~.t 'January']]
                    ==
            ==
  %-  exec-0-1
        :*  run
            :+  ~2012.4.30
                %db1
                %-  zing  :~  "CREATE DATABASE db1;"
                              create-calendar
                              insert-calendar
                              ==
            ::
            :+  ~2012.5.3
                %db1
                "WITH (FROM calendar ".
                      "WHERE day-name = 'Monday' ".
                      "SELECT date, day-name, month-name) ".
                      "AS cal-cte ".
                "FROM cal-cte SELECT * "
            ::
            :-  %results  :~  [%message 'SELECT']
                              [%result-set expected-rows]
                              [%server-time ~2012.5.3]
                              [%message 'db1.dbo.calendar']
                              [%schema-time ~2012.4.30]
                              [%data-time ~2012.4.30]
                              [%vector-count 2]
                              ==
            ==
::
::  CTE with JOIN, outer SELECT with multiple predicates (AND)
++  test-cte-10
  =|  run=@ud
  =/  expected-rows
        :~  :-  %vector
                :~  [%day-name [~.t 'Monday']]
                    [%date [~.da ~2023.12.25]]
                    [%us-federal-holiday [~.t 'Christmas Day']]
                    ==
            ==
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
                "WITH (FROM calendar T1 ".
                      "JOIN holiday-calendar T2 ".
                      "SELECT T1.day-name, T2.date, ".
                            "T2.us-federal-holiday) ".
                      "AS my-cte ".
                "FROM my-cte ".
                "WHERE day-name = 'Monday' ".
                "  AND date = ~2023.12.25 ".
                "SELECT * "
            ::
            :-  %results  :~  [%message 'SELECT']
                              [%result-set expected-rows]
                              [%server-time ~2012.5.3]
                              [%message 'db1.dbo.calendar']
                              [%schema-time ~2012.4.30]
                              [%data-time ~2012.4.30]
                              [%message msg='db1.dbo.holiday-calendar']
                              [%schema-time date=~2012.4.30]
                              [%data-time date=~2012.4.30]
                              [%vector-count 1]
                              ==
            ==
::
::  single-table CTE with WHERE, outer SELECT specific columns + predicate
++  test-cte-11
  =|  run=@ud
  =/  expected-rows
        :~  :-  %vector
                :~  [%col1 [~.t 'rygged']]
                    [%col3 [~.ud q=5]]
                    ==
            :-  %vector
                :~  [%col1 [~.t 'cord']]
                    [%col3 [~.ud 20]]
                    ==
            ==
  %-  exec-0-1
        :*  run
            :+  ~2012.4.30
                %db1
                %-  zing  :~  "CREATE DATABASE db1;"
                              create-table
                              insert-table
                              ==
            ::
            :+  ~2012.5.3
                %db1
                "WITH (FROM my-table ".
                      "WHERE col3 > 3 ".
                      "SELECT col1, col3) ".
                      "AS filtered-cte ".
                "FROM filtered-cte ".
                "WHERE col3 > 4 ".
                "SELECT col1, col3 "
            ::
            :-  %results  :~  [%message 'SELECT']
                              [%result-set expected-rows]
                              [%server-time ~2012.5.3]
                              [%message 'db1.dbo.my-table']
                              [%schema-time ~2012.4.30]
                              [%data-time ~2012.4.30]
                              [%vector-count 2]
                              ==
            ==
::
::  chained CTEs: second CTE references first CTE
++  test-cte-12
  =|  run=@ud
  =/  expected-rows
        :~  :-  %vector
                :~  [%date [~.da ~2024.1.1]]
                    [%day-name [~.t 'Monday']]
                    ==
            ==
  %-  exec-0-1
  ::%-  debug-0-1
        :*  run
            :+  ~2012.4.30
                %db1
                %-  zing  :~  "CREATE DATABASE db1;"
                              create-calendar
                              insert-calendar
                              ==
            ::
            :+  ~2012.5.3
                %db1
                "WITH (FROM calendar ".
                      "WHERE day-name = 'Monday' ".
                      "SELECT date, day-name, month-name) ".
                      "AS cal-cte, ".
                     "(FROM cal-cte ".
                      "WHERE month-name = 'January' ".
                      "SELECT date, day-name) ".
                      "AS filtered-cte ".
                "FROM filtered-cte SELECT * "
            ::
            :-  %results  :~  [%message 'SELECT']
                              [%result-set expected-rows]
                              [%server-time ~2012.5.3]
                              [%message 'db1.dbo.calendar']
                              [%schema-time ~2012.4.30]
                              [%data-time ~2012.4.30]
                              [%vector-count 1]
                              ==
            ==
::
::::::  CTE alias defined upper case, outer SELECT qualifies with differing case
::::++  test-cte-13
::::  =|  run=@ud
::::  =/  expected-rows
::::        :~  :-  %vector
::::                :~  [%day-name [~.t 'Monday']]
::::                    [%date [~.da ~2023.12.25]]
::::                    [%us-federal-holiday [~.t 'Christmas Day']]
::::                    ==
::::            :-  %vector
::::                :~  [%day-name [~.t 'Monday']]
::::                    [%date [~.da ~2024.1.1]]
::::                    [%us-federal-holiday [~.t 'New Years Day']]
::::                    ==
::::            ==
::::  ::%-  exec-0-1
::::  %-  debug-0-1
::::        :*  run
::::            :+  ~2012.4.30
::::                %db1
::::                %-  zing  :~  "CREATE DATABASE db1;"
::::                              create-calendar
::::                              insert-calendar
::::                              create-holiday-calendar
::::                              insert-holiday-calendar
::::                              ==
::::            ::
::::            :+  ~2012.5.3
::::                %db1
::::                "WITH (FROM calendar T1 ".
::::                      "JOIN holiday-calendar T2 ".
::::                      "SELECT T1.day-name, T2.date, ".
::::                            "T2.us-federal-holiday) ".
::::                      "AS MY-CTE ".
::::                "FROM my-cte SELECT my-cte.day-name, My-Cte.date, ".
::::                      "MY-CTE.us-federal-holiday "
::::            ::
::::            :-  %results  :~  [%message 'SELECT']
::::                              [%result-set expected-rows]
::::                              [%server-time ~2012.5.3]
::::                              [%message 'db1.dbo.calendar']
::::                              [%schema-time ~2012.4.30]
::::                              [%data-time ~2012.4.30]
::::                              [%message msg='db1.dbo.holiday-calendar']
::::                              [%schema-time date=~2012.4.30]
::::                              [%data-time date=~2012.4.30]
::::                              [%vector-count 2]
::::                              ==
::::            ==
::::::::::
::::::::::  CTE alias defined lower case, outer SELECT uses upper case alias.*
::::++  test-cte-14
::::  =|  run=@ud
::::  =/  expected-rows
::::        :~  :-  %vector
::::                :~  [%day-name [~.t 'Monday']]
::::                    [%date [~.da ~2023.12.25]]
::::                    [%us-federal-holiday [~.t 'Christmas Day']]
::::                    ==
::::            :-  %vector
::::                :~  [%day-name [~.t 'Monday']]
::::                    [%date [~.da ~2024.1.1]]
::::                    [%us-federal-holiday [~.t 'New Years Day']]
::::                    ==
::::            ==
::::  %-  exec-0-1
::::        :*  run
::::            :+  ~2012.4.30
::::                %db1
::::                %-  zing  :~  "CREATE DATABASE db1;"
::::                              create-calendar
::::                              insert-calendar
::::                              create-holiday-calendar
::::                              insert-holiday-calendar
::::                              ==
::::            ::
::::            :+  ~2012.5.3
::::                %db1
::::                "WITH (FROM calendar T1 ".
::::                      "JOIN holiday-calendar T2 ".
::::                      "SELECT T1.day-name, T2.date, ".
::::                            "T2.us-federal-holiday) ".
::::                      "AS my-cte ".
::::                "FROM My-Cte SELECT MY-CTE.* "
::::            ::
::::            :-  %results  :~  [%message 'SELECT']
::::                              [%result-set expected-rows]
::::                              [%server-time ~2012.5.3]
::::                              [%message 'db1.dbo.calendar']
::::                              [%schema-time ~2012.4.30]
::::                              [%data-time ~2012.4.30]
::::                              [%message msg='db1.dbo.holiday-calendar']
::::                              [%schema-time date=~2012.4.30]
::::                              [%data-time date=~2012.4.30]
::::                              [%vector-count 2]
::::                              ==
::::            ==
::
::  fail on duplicate column name
++  test-fail-cte-00
  =|  run=@ud
  %-  failon-1  :*  run
                    :+  ~2012.4.30
                        %db1
                        %-  zing  :~  "CREATE DATABASE db1;"
                                create-calendar
                                insert-calendar
                                create-holiday-calendar
                                insert-holiday-calendar
                                ==
                    ::
                    :+  ~2012.5.5
                        %db1
                        "WITH (FROM calendar t1 ".
                        "JOIN holiday-calendar T2 ".
                        "WHERE T1.day-name = 'Monday' ".
                        "  AND t2.us-federal-holiday = 'Christmas Day' ".
                        "SELECT T1.day-name, t2.*, t2.us-federal-holiday) ".
                        "AS my-cte ".
                        "FROM my-cte SELECT * "
                    ::
                    %-  crip  "%us-federal-holiday is duplicate column name in".
                              " common table expression %my-cte"
                    ==
::
::  fail on duplicate column name, part 2
++  test-fail-cte-01
  =|  run=@ud
  %-  failon-1  :*  run
                    :+  ~2012.4.30
                        %db1
                        %-  zing  :~  "CREATE DATABASE db1;"
                                  create-calendar
                                  insert-calendar
                                  create-holiday-calendar
                                  insert-holiday-calendar
                                  ==
                    ::
                    :+  ~2012.5.5
                        %db1
                        "WITH (FROM calendar t1 ".
                        "JOIN holiday-calendar T2 ".
                        "WHERE T1.day-name = 'Monday' ".
                        "  AND t2.us-federal-holiday = 'Christmas Day' ".
                        "SELECT *) AS my-cte ".
                        "FROM my-cte SELECT * "
                    ::
                    %-  crip  "%date is duplicate column name in ".
                              "common table expression %my-cte"
                    ==
::
::  fail: outer SELECT references column not in CTE projection
++  test-fail-cte-02
  =|  run=@ud
  %-  failon-1  :*  run
                    :+  ~2012.4.30
                        %db1
                        %-  zing  :~  "CREATE DATABASE db1;"
                                create-calendar
                                insert-calendar
                                create-holiday-calendar
                                insert-holiday-calendar
                                ==
                    ::
                    :+  ~2012.5.5
                        %db1
                        "WITH (FROM calendar T1 ".
                        "JOIN holiday-calendar T2 ".
                        "SELECT T1.day-name, T2.date, ".
                              "T2.us-federal-holiday) ".
                        "AS my-cte ".
                        "FROM my-cte SELECT year "
                    ::
                    'SELECT: column %year not found'
                    ==
::
::  fail: duplicate column from T1.* and T2.* with shared PK,
::        no WHERE (variant without predicate)
++  test-fail-cte-03
  =|  run=@ud
  %-  failon-1  :*  run
                    :+  ~2012.4.30
                        %db1
                        %-  zing  :~  "CREATE DATABASE db1;"
                                create-calendar
                                insert-calendar
                                create-holiday-calendar
                                insert-holiday-calendar
                                ==
                    ::
                    :+  ~2012.5.5
                        %db1
                        "WITH (FROM calendar T1 ".
                        "JOIN holiday-calendar T2 ".
                        "SELECT T1.*, T2.*) ".
                        "AS my-cte ".
                        "FROM my-cte SELECT * "
                    ::
                    %-  crip  "%date is duplicate column name in ".
                              "common table expression %my-cte"
                    ==
::
::  fail: duplicate from selecting same column twice explicitly
++  test-fail-cte-04
  =|  run=@ud
  %-  failon-1  :*  run
                    :+  ~2012.4.30
                        %db1
                        %-  zing  :~  "CREATE DATABASE db1;"
                                create-calendar
                                insert-calendar
                                create-holiday-calendar
                                insert-holiday-calendar
                                ==
                    ::
                    :+  ~2012.5.5
                        %db1
                        "WITH (FROM calendar T1 ".
                        "JOIN holiday-calendar T2 ".
                        "SELECT T1.day-name, T2.date, ".
                              "T2.us-federal-holiday, T1.day-name) ".
                        "AS my-cte ".
                        "FROM my-cte SELECT * "
                    ::
                    %-  crip  "%day-name is duplicate column name in ".
                              "common table expression %my-cte"
                    ==
::
::  fail: FROM references CTE alias that does not match any defined CTE
++  test-fail-cte-05
  =|  run=@ud
  %-  failon-1  :*  run
                    :+  ~2012.4.30
                        %db1
                        %-  zing  :~  "CREATE DATABASE db1;"
                                create-calendar
                                insert-calendar
                                ==
                    ::
                    :+  ~2012.5.5
                        %db1
                        "WITH (FROM calendar ".
                        "WHERE day-name = 'Monday' ".
                        "SELECT date, day-name) ".
                        "AS my-cte ".
                        "FROM no-such-cte SELECT * "
                    ::
                    %-  crip  "SELECT: table %db1.%dbo.%no-such-cte does ".
                              "not exist at schema time ~2012.4.30"
                    ==
--