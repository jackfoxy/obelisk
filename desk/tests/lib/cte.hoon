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
::::++  test-cte-00
::::  =|  run=@ud
::::  %-  exec-0-1
::::  ::%-    debug-0-1
::::        :*  run
::::            :+  ~2012.4.30
::::                %db1
::::                %-  zing  :~  "CREATE DATABASE db1;"
::::                              create-table
::::                              insert-table
::::                              ==
::::            ::
::::            :+  ~2012.5.3
::::                %db1
::::                "WITH (FROM my-table ".
::::                "      SELECT *) AS my-cte ".
::::                "FROM my-cte SELECT * "
::::            ::
::::            :-  %results  :~  [%message 'SELECT']
::::                              :-  %result-set
::::                                  :~
::::                                    :-  %vector
::::                                        :~  [%col0 [~.da ~2010.5.3]]
::::                                            [%col1 [~.t 'cord']]
::::                                            [%col2 [~.p ~nomryg-nilref]]
::::                                            [%col3 [~.ud 20]]
::::                                            [%col4 [~.da ~2000.1.1]]
::::                                            ==
::::                                    :-  %vector
::::                                        :~  [%col0 [~.da ~2010.5.31]]
::::                                            [%col1 [~.t 'Default']]
::::                                            [%col2 [~.p ~zod]]
::::                                            [%col3 [~.ud 0]]
::::                                            [%col4 [~.da ~2000.1.1]]
::::                                            ==
::::                                    :-  %vector
::::                                        :~  [%col0 [~.da ~2010.5.31]]
::::                                            [%col1 [~.t 'Default']]
::::                                            [%col2 [~.p ~nec]]
::::                                            [%col3 [~.ud 1]]
::::                                            [%col4 [~.da ~2000.1.1]]
::::                                            ==
::::                                    :-  %vector
::::                                        :~  [%col0 [~.da ~2010.5.31]]
::::                                            [%col1 [~.t 'Default']]
::::                                            [%col2 [~.p ~bus]]
::::                                            [%col3 [~.ud 2]]
::::                                            [%col4 [~.da ~2000.1.1]]
::::                                            ==
::::                                    :-  %vector
::::                                        :~  [%col0 [~.da ~2010.6.30]]
::::                                            [%col1 [~.t 'zod man']]
::::                                            [%col2 [~.p ~zod]]
::::                                            [%col3 [~.ud 3]]
::::                                            [%col4 [~.da ~2010.6.1]]
::::                                            ==
::::                                    :-  %vector
::::                                        :~  [%col0 [~.da ~2010.3.23]]
::::                                            [%col1 [~.t '~num galaxy']]
::::                                            [%col2 [~.p ~num]]
::::                                            [%col3 [~.ud 4]]
::::                                            [%col4 [~.da ~2010.3.3]]
::::                                            ==
::::                                    :-  %vector
::::                                        :~  [%col0 [~.da ~2012.2.29]]
::::                                            [%col1 [~.t 'rygged']]
::::                                            [%col2 [~.p ~rus]]
::::                                            [%col3 [~.ud 5]]
::::                                            [%col4 [~.da ~2012.2.1]]
::::                                            ==
::::
::::                                    ==
::::                              [%server-time ~2012.5.3]
::::                              [%message 'db1.dbo.my-table']
::::                              [%schema-time ~2012.4.30]
::::                              [%data-time ~2012.4.30]
::::                              [%vector-count 7]
::::                              ==
::::            ==
::
::  simple query of joined, filtered cte, SELECT *
::::++  test-cte-01
::::  =|  run=@ud
::::  =/  expected-rows   :: to do!!!
::::        :~  :-  %vector
::::                :~  [%day-name [~.t 'Monday']]
::::                    [%date [~.da ~2023.12.25]]
::::                    [%us-federal-holiday [~.t 'Christmas Day']]
::::                    [%us-federal-holiday [~.t 'Christmas Day']]
::::                    ==
::::            ==
::::  ::%-  exec-0-1
::::  %-    debug-0-1
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
::::                "WITH (FROM calendar t1 ".
::::                      "JOIN holiday-calendar T2 ".
::::                      "WHERE T1.day-name = 'Monday' ".
::::                      "  AND t2.us-federal-holiday = 'Christmas Day' ".
::::                      "SELECT T1.day-name, t2.*, ".
::::                            "t2.us-federal-holiday as fed) ".
::::                      "AS my-cte ".
::::                "FROM my-cte SELECT * "
::::            ::
::::            :-  %results  :~  [%message 'SELECT']
::::                              [%result-set expected-rows]
::::                              [%server-time ~2012.5.3]
::::                              [%message 'db1.dbo.my-table']
::::                              [%schema-time ~2012.4.30]
::::                              [%data-time ~2012.4.30]
::::                              [%vector-count 2]
::::                              ==
::::            ==
::
::  fail on duplicate column name
::::++  test-fail-cte-00
::::  =|  run=@ud
::::  %-  failon-1  :*  run
::::                    :+  ~2012.4.30
::::                        %db1
::::                        %-  zing  :~  "CREATE DATABASE db1;"
::::                                create-calendar
::::                                insert-calendar
::::                                create-holiday-calendar
::::                                insert-holiday-calendar
::::                                ==
::::                    ::
::::                    :+  ~2012.5.5
::::                        %db1
::::                        "WITH (FROM calendar t1 ".
::::                        "JOIN holiday-calendar T2 ".
::::                        "WHERE T1.day-name = 'Monday' ".
::::                        "  AND t2.us-federal-holiday = 'Christmas Day' ".
::::                        "SELECT T1.day-name, t2.*, t2.us-federal-holiday) ".
::::                        "AS my-cte ".
::::                        "FROM my-cte SELECT * "
::::                    ::
::::                    %-  crip  "%us-federal-holiday is duplicate column name in".
::::                              " common table expression %my-cte"
::::                    ==
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
--