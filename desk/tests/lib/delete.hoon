::  Demonstrate unit testing queries on a Gall agent with %obelisk.
::
/+  *test-helpers
|%
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
++  create-joined-tables
  "CREATE TABLE db1..my-table ".
  "(col1 @t, col2 @da) ".
  "PRIMARY KEY (col1); ".
  "CREATE TABLE db1..my-table-2 ".
  "(col1 @t, col3 @t, col4 @t) ".
  "PRIMARY KEY (col1)"
::
::  delete all
++  test-delete-00
  =|  run=@ud
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
          "DELETE FROM calendar ".
          "WHERE day-name = 'Sunday' ".
          "   OR day-name = 'Monday' ".
          "   OR day-name = 'Tuesday' ".
          "   OR day-name = 'Wednesday' ".
          "   OR day-name = 'Thursday' ".
          "   OR day-name = 'Friday' ".
          "   OR day-name = 'Saturday' "
      ::
      :~  %results
          [%message 'DELETE FROM db1.dbo.calendar']
          [%server-time ~2012.5.3]
          [%schema-time ~2012.4.30]
          [%data-time ~2012.4.30]
          [%message 'deleted:']
          [%vector-count 13]
          [%message 'table data:']
          [%vector-count 0]
          ==
      ==
::
::  delete none
++  test-delete-01
  =|  run=@ud
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
          "DELETE calendar ".
          "WHERE day-name = 'asdf'"
      ::
      :~  %results
          [%message 'DELETE FROM db1.dbo.calendar']
          [%server-time ~2012.5.3]
          [%schema-time ~2012.4.30]
          [%data-time ~2012.4.30]
          [%message 'no rows deleted']
          ==
      ==
::
::  delete delete 2 rows
++  test-delete-02
  =|  run=@ud
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
          "DELETE calendar ".
          "WHERE day-name = 'Monday'"
      ::
      :~  %results
          [%message 'DELETE FROM db1.dbo.calendar']
          [%server-time ~2012.5.3]
          [%schema-time ~2012.4.30]
          [%data-time ~2012.4.30]
          [%message 'deleted:']
          [%vector-count 2]
          [%message 'table data:']
          [%vector-count 11]
          ==
      ==
::
::  delete all but 1
++  test-delete-03
  =|  run=@ud
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
      :~  %results
          [%message 'DELETE FROM db1.dbo.calendar']
          [%server-time ~2012.5.3]
          [%schema-time ~2012.4.30]
          [%data-time ~2012.4.30]
          [%message 'deleted:']
          [%vector-count 12]
          [%message 'table data:']
          [%vector-count 1]
          ==
      ==
::
::  delete all but 1 FROM AS OF > data time
++  test-delete-04
  =|  run=@ud
  %-  exec-1-2
  :*  run
      :+  ~2012.4.30
          %db1
          %-  zing  :~  "CREATE DATABASE db1;"
                        create-calendar
                        insert-calendar
                        ==
      ::
      :+  ~2012.5.2
          %db1
          "INSERT INTO calendar ".
          "VALUES ".
          "(~2024.1.6, 2024, 1, 'January', 6, 'Saturday', 6, 7, 1) ".
          "(~2024.1.13, 2024, 1, 'January', 13, 'Saturday', 13, 7, 2) ".
          "(~2024.1.20, 2024, 1, 'January', 20, 'Saturday', 20, 7, 3) "
      ::
      :+  ~2012.5.3
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
      ::
      [~2012.5.4 %db1 "FROM calendar SELECT *"]
      ::
      :~  %results
          [%message 'DELETE FROM db1.dbo.calendar']
          [%server-time ~2012.5.3]
          [%schema-time ~2012.4.30]
          [%data-time ~2012.4.30]
          [%message 'deleted:']
          [%vector-count 12]
          [%message 'table data:']
          [%vector-count 1]
          ==
      ::
      :-  %results
          :~  [%message 'SELECT']
              :-  %result-set
                  :~  :-  %vector
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
              [%server-time ~2012.5.4]
              [%message 'db1.dbo.calendar']
              [%schema-time ~2012.4.30]
              [%data-time ~2012.5.3]
              [%vector-count 1]
              ==
      ==
::
::  delete all but 1 FROM AS OF = data time
++  test-delete-05
  =|  run=@ud
  %-  exec-1-2
  :*  run
      :+  ~2012.4.30
          %db1
          %-  zing  :~  "CREATE DATABASE db1;"
                        create-calendar
                        insert-calendar
                        ==
      ::
      :+  ~2012.5.2
          %db1
          "INSERT INTO calendar ".
          "VALUES ".
          "(~2024.1.6, 2024, 1, 'January', 6, 'Saturday', 6, 7, 1) ".
          "(~2024.1.13, 2024, 1, 'January', 13, 'Saturday', 13, 7, 2) ".
          "(~2024.1.20, 2024, 1, 'January', 20, 'Saturday', 20, 7, 3) "
      ::
      :+  ~2012.5.3
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
      ::
      [~2012.5.4 %db1 "FROM calendar SELECT *"]
      ::
      :~  %results
          [%message 'DELETE FROM db1.dbo.calendar']
          [%server-time ~2012.5.3]
          [%schema-time ~2012.4.30]
          [%data-time ~2012.4.30]
          [%message 'deleted:']
          [%vector-count 12]
          [%message 'table data:']
          [%vector-count 1]
          ==
      ::
      :-  %results
          :~  [%message 'SELECT']
              :-  %result-set
                  :~  :-  %vector
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
              [%server-time ~2012.5.4]
              [%message 'db1.dbo.calendar']
              [%schema-time ~2012.4.30]
              [%data-time ~2012.5.3]
              [%vector-count 1]
              ==
      ==
::
::  DELETE followed by DELETE AS OF in same script
++  test-delete-06
  =|  run=@ud
  %-  exec-1-ls
  :*  run
      :+  ~2012.4.30
          %db1
          %-  zing  :~  "CREATE DATABASE db1;"
                        create-calendar
                        insert-calendar
                        ==
      ::
      :+  ~2012.5.2
          %db1
          "INSERT INTO calendar ".
          "VALUES ".
          "(~2024.1.6, 2024, 1, 'January', 6, 'Saturday', 6, 7, 1) ".
          "(~2024.1.13, 2024, 1, 'January', 13, 'Saturday', 13, 7, 2) ".
          "(~2024.1.20, 2024, 1, 'January', 20, 'Saturday', 20, 7, 3) "
      ::
      :+  ~2012.5.3
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
      ::
      [~2012.5.4 %db1 "FROM calendar SELECT *"]
      ::
      :~  :-  %results
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
      ::
      :-  %results
          :~  [%message 'SELECT']
              :-  %result-set
                  :~  :-  %vector
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
              [%server-time ~2012.5.4]
              [%message 'db1.dbo.calendar']
              [%schema-time ~2012.4.30]
              [%data-time ~2012.5.3]
              [%vector-count 1]
              ==
      ==
::
::  DELETE AS OF followed by DELETE in same script
++  test-delete-07
  =|  run=@ud
  %-  exec-1-ls
  :*  run
      :+  ~2012.4.30
          %db1
          %-  zing  :~  "CREATE DATABASE db1;"
                        create-calendar
                        insert-calendar
                        ==
      ::
      :+  ~2012.5.2
          %db1
          "INSERT INTO calendar ".
          "VALUES ".
          "(~2024.1.6, 2024, 1, 'January', 6, 'Saturday', 6, 7, 1) ".
          "(~2024.1.13, 2024, 1, 'January', 13, 'Saturday', 13, 7, 2) ".
          "(~2024.1.20, 2024, 1, 'January', 20, 'Saturday', 20, 7, 3) "
      ::
      :+  ~2012.5.3
          %db1
          "DELETE FROM calendar AS OF ~2012.5.1 ".
          "WHERE day-name = 'Wednesday'; ".
          "DELETE FROM calendar ".
          "WHERE day-name = 'Sunday' ".
          "   OR day-name = 'Friday' ".
          "   OR (day-name = 'Saturday' ".
          "       AND day-of-year = 357) "
      ::
      [~2012.5.4 %db1 "FROM calendar SELECT *"]
      ::
      :~  :-  %results
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
      ::
      :-  %results
          :~  [%message 'SELECT']
              :-  %result-set
                  :~  :-  %vector
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
              [%server-time ~2012.5.4]
              [%message 'db1.dbo.calendar']
              [%schema-time ~2012.4.30]
              [%data-time ~2012.5.3]
              [%vector-count 7]
              ==
      ==
::
::  DELETE then INSERT same key
++  test-delete-08
  =|  run=@ud
  %-  exec-2-1
  :*  run
      :+  ~2012.4.30
          %db1
          %-  zing  :~  "CREATE DATABASE db1;"
                        create-calendar
                        ==
      ::
      :+  ~2012.5.2
          %db1
          "INSERT INTO calendar ".
          "VALUES ".
          "(~2024.1.6, 2024, 1, 'January', 6, 'Saturday', 6, 7, 1) ".
          "(~2024.1.13, 2024, 1, 'January', 13, 'Saturday', 13, 7, 2) ".
          "(~2024.1.20, 2024, 1, 'January', 20, 'Saturday', 20, 7, 3) "
      ::
      :+  ~2012.5.3
          %db1
          "DELETE FROM calendar ".
          "WHERE day-name = 'Saturday' ".
          "  AND day-of-year = 13; ".
          "INSERT INTO calendar ".
          "VALUES ".
          "(~2024.1.13, 2024, 1, 'January', 13, 'Weekendday', 13, 7, 2) "
      ::
      [~2012.5.4 %db1 "FROM calendar SELECT *"]
      ::
      :-  %results
          :~  [%message 'SELECT']
              :-  %result-set
                  :~  :-  %vector
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
              [%server-time ~2012.5.4]
              [%message 'db1.dbo.calendar']
              [%schema-time ~2012.4.30]
              [%data-time ~2012.5.3]
              [%vector-count 3]
              ==
      ==
::
::::  CTE column predicate
::::
::  DELETE with CTE predicate
::  (cte-column = cte-column, matching: all rows deleted)
++  test-delete-09
  =|  run=@ud
  %-  exec-0-1
  :*  run
      :+  ~2012.4.30
          %db1
          %-  zing  :~  "CREATE DATABASE db1;"
                        create-joined-tables
                        "INSERT INTO my-table VALUES ".
                                              "('Abby', ~1999.2.19) ".
                                              "('Ace', ~2005.12.19) ".
                                              "('Angel', ~2001.9.19);"
                        "INSERT INTO my-table-2 VALUES ".
                                              "('Abby', 'tricolor', 'row1') ".
                                              "('Ace', 'ticolor', 'row2') ".
                                              "('Angel', 'Angel', 'row3')"
                        ==
      ::
      :+  ~2012.5.3
          %db1
          "WITH (FROM my-table-2 ".
          "WHERE col4 = 'row3' SELECT col1, col3) AS my-cte ".
          "DELETE FROM my-table WHERE my-cte.col1 = my-cte.col3"
      ::
      :~  %results
          [%message 'DELETE FROM db1.dbo.my-table']
          [%server-time ~2012.5.3]
          [%schema-time ~2012.4.30]
          [%data-time ~2012.4.30]
          [%message 'deleted:']
          [%vector-count 3]
          [%message 'table data:']
          [%vector-count 0]
          ==
      ==
::
::  DELETE with CTE predicate
::  (cte-column = cte-column, not matching: no rows deleted)
++  test-delete-10
  =|  run=@ud
  %-  exec-0-1
  :*  run
      :+  ~2012.4.30
          %db1
          %-  zing  :~  "CREATE DATABASE db1;"
                        create-joined-tables
                        "INSERT INTO my-table VALUES ".
                                              "('Abby', ~1999.2.19) ".
                                              "('Ace', ~2005.12.19) ".
                                              "('Angel', ~2001.9.19);"
                        "INSERT INTO my-table-2 VALUES ".
                                                "('Abby', 'tricolor', 'row1') ".
                                                "('Ace', 'ticolor', 'row2') ".
                                                "('Angel', 'tuxedo', 'row3')"
                        ==
      ::
      :+  ~2012.5.3
          %db1
          "WITH (FROM my-table-2 WHERE col4 = 'row3' ".
          "SELECT col1, col3) AS my-cte ".
          "DELETE FROM my-table WHERE my-cte.col1 = my-cte.col3"
      ::
      :~  %results
          [%message 'DELETE FROM db1.dbo.my-table']
          [%server-time ~2012.5.3]
          [%schema-time ~2012.4.30]
          [%data-time ~2012.4.30]
          [%message 'no rows deleted']
          ==
      ==
::
::  fail on no predicate
++  test-fail-delete-00
  =|  run=@ud
  %-  failon-1
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
      "DELETE FROM calendar "
      ::
      'PARSER:'
      ==
::
::  fail on changing state after select in script
++  test-fail-delete-01
  =|  run=@ud
  %-  failon-1
  :*  run
      :+  ~2000.1.1
          %sys
      "CREATE DATABASE db1"
      ::
      :+  ~2000.1.2
          %db1
      "CREATE TABLE db1..my-table (col1 @t) PRIMARY KEY (col1); ".
      "SELECT 0;".
      "DELETE FROM calendar ".
      "WHERE 1 = 1 "
      ::
      'DELETE: state change after query in script'
      ==
::
::  fail on unknown column name in WHERE bad column = literal
++  test-fail-delete-02
  =|  run=@ud
  %-  failon-1
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
          "DELETE FROM calendar ".
          "WHERE bad-col = 'Monday'"
      ::
      'column %bad-col does not exist'
      ==
::
::  fail on unknown column name in WHERE literal = bad column
++  test-fail-delete-03
  =|  run=@ud
  %-  failon-1
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
          "DELETE FROM calendar ".
          "WHERE 'Monday' = bad-col"
      ::
      'column %bad-col does not exist'
      ==
::
::  fail on unknown column name in WHERE bad column left param
++  test-fail-delete-04
  =|  run=@ud
  %-  failon-1
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
          "DELETE FROM calendar ".
          "WHERE bad-col = date"
      ::
      'column %bad-col does not exist'
      ==
::
::  fail on unknown column name in WHERE bad column right param
++  test-fail-delete-05
  =|  run=@ud
  %-  failon-1
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
          "DELETE FROM calendar ".
          "WHERE date = bad-col"
      ::
      'column %bad-col does not exist'
      ==
--