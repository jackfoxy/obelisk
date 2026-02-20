::  Demonstrate unit testing queries on a Gall agent with %obelisk.
::
/+  *test-helpers
::
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
::  no predicate, one column
++  test-update-00
  =|  run=@ud
  %-  exec-0-2
        :*  run
            :+  ~2012.4.30
                %db1
                %-  zing  :~  "CREATE DATABASE db1;"
                              create-table
                              insert-table
                              ==
            ::
            [~2012.5.1 %db1 "update my-table set col1='hello'"]
            ::
            :+  ~2012.5.3
                %db1
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
  %-  exec-0-2
        :*  run
            :+  ~2012.4.30
                %db1
                %-  zing  :~  "CREATE DATABASE db1;"
                              create-table
                              insert-table
                              ==
            ::
            :+  ~2012.5.1
                %db1
                "update my-table set col1='hello', ".
                "                    col3=44, ".
                "                    col4=~2001.1.1; "
            ::
            :+  ~2012.5.3
                %db1
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
  %-  exec-0-2
        :*  run
            :+  ~2012.4.30
                %db1
                %-  zing  :~  "CREATE DATABASE db1;"
                              create-table
                              insert-table
                              ==
            ::
            [~2012.5.1 %db1 "update my-table set col0=DEFAULT"]
            ::
            :+  ~2012.5.3
                %db1
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
  %-  exec-0-2
        :*  run
            :+  ~2012.4.30
                %db1
                %-  zing  :~  "CREATE DATABASE db1;"
                              create-table
                              insert-table
                              ==
            ::
            :+  ~2012.5.1
                %db1
                "update my-table set col0=DEFAULT, ".
                "                    col1='upd1', ".
                "                    col3=7, ".
                "                    col4=~2025.4.25; "
            ::
            :+  ~2012.5.3
                %db1
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
  %-  exec-0-2
        :*  run
            :+  ~2012.4.30
                %db1
                %-  zing  :~  "CREATE DATABASE db1;"
                              create-table
                              insert-table
                              ==
            ::
            :+  ~2012.5.1
                %db1
                "UPDATE my-table SET col1='hello' ".
                "WHERE 'foo'='hello' "
            ::
            :+  ~2012.5.3
                %db1
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
  %-  exec-0-2
        :*  run
            :+  ~2012.4.30
                %db1
                %-  zing  :~  "CREATE DATABASE db1;"
                              create-table
                              insert-table
                              ==
            ::
            :+  ~2012.5.1
                %db1
                "UPDATE my-table SET col1='hello' ".
                "WHERE col3=20 "
            ::
            :+  ~2012.5.3
                %db1
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
  %-  exec-0-2
        :*  run
            :+  ~2012.4.30
                %db1
                %-  zing  :~  "CREATE DATABASE db1;"
                              create-table
                              insert-table
                              ==
            ::
            :+  ~2012.5.1
                %db1
                "UPDATE my-table SET col1='hello' ".
                "WHERE col1='Default' "
            ::
            :+  ~2012.5.3
                %db1
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
  %-  exec-0-2
        :*  run
            :+  ~2012.4.30
                %db1
                %-  zing  :~  "CREATE DATABASE db1;"
                              create-table
                              insert-table
                              ==
            ::
            :+  ~2012.5.1
                %db1
                "UPDATE my-table SET col1='hello', ".
                "                    col3=152, ".
                "                    col4=~1978.12.31 ".
                "WHERE col1='Default' "
            ::
            :+  ~2012.5.3
                %db1
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
  %-  exec-0-2
        :*  run
            :+  ~2012.4.30
                %db1
                %-  zing  :~  "CREATE DATABASE db1;"
                              create-table
                              insert-table
                              ==
            ::
            :+  ~2012.5.1
                %db1
                "UPDATE my-table SET col1='hello', ".
                "                    col3=152, ".
                "                    col4=~1978.12.31 ".
                "WHERE col1='Default' ".
                "  AND col2=~nec    ;"
            ::
            :+  ~2012.5.3
                %db1
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
  %-  exec-0-2
      :*  run
          :+  ~2012.4.30
              %db1
              %-  zing  :~  "CREATE DATABASE db1;"
                            create-table
                            insert-table
                            ==
          ::
          :+  ~2012.5.1
              %db1
              "UPDATE my-table SET col0=~1978.12.31 ".
              "WHERE col2=~nec    ;"
          ::
          :+  ~2012.5.3
              %db1
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
  %-  exec-0-2
        :*  run
            :+  ~2012.4.30
                %db1
                %-  zing  :~  "CREATE DATABASE db1;"
                              create-table
                              insert-table
                              ==
            ::
            :+  ~2012.5.1
                %db1
                "UPDATE my-table SET col0=~1980.1.1, ".
                "                    col1='hello', ".
                "                    col3=152, ".
                "                    col4=~1978.12.31 ".
                "WHERE col1='Default' ".
                "  AND col2=~nec    ;"
            ::
            :+  ~2012.5.3
                %db1
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
  %-  exec-2-2
        :*  run
            :+  ~2012.4.30
                %db1
                %-  zing  :~  "CREATE DATABASE db1;"
                              create-table
                              insert-table
                              ==
            ::
            :+  ~2012.5.1
                %db1
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
            :+  ~2012.5.2
                %db1
                "UPDATE my-table AS OF ~2012.4.30 ".
                "   SET col0=~1981.2.2, ".
                "       col1='hello you', ".
                "       col3=153, ".
                "       col4=~1999.12.31 ".
                "WHERE col1='Default' ".
                "  AND col2=~bus    ;"
            ::
            :+  ~2012.5.3
                %db1
                "FROM my-table AS OF ~2012.5.1".
                "SELECT *;"
            ::
            :+  ~2012.5.4
                %db1
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
  %-  exec-2-2
        :*  run
            :+  ~2012.4.30
                %db1
                %-  zing  :~  "CREATE DATABASE db1;"
                              create-table
                              insert-table
                              ==
            ::
            :+  ~2012.5.1
                %db1
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
            :+  ~2012.5.2
                %db1
                "UPDATE my-table AS OF 30 HOURS AGO ".
                "   SET col0=~1981.2.2, ".
                "       col1='hello you', ".
                "       col3=153, ".
                "       col4=~1999.12.31 ".
                "WHERE col1='Default' ".
                "  AND col2=~bus    ;"
            ::
            :+  ~2012.5.3
                %db1
                "FROM my-table AS OF ~2012.5.1".
                "SELECT *;"
            ::
            :+  ~2012.5.4
                %db1
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
  %-  exec-2-2
        :*  run
            :+  ~2012.4.30
                %db1
                %-  zing  :~  "CREATE DATABASE db1;"
                              create-table
                              insert-table
                              ==
            ::
            :+  ~2012.5.1
                %db1
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
            :+  ~2012.5.2
                %db1
                "UPDATE my-table AS OF ~h36.m30 ".
                "   SET col0=~1981.2.2, ".
                "       col1='hello you', ".
                "       col3=153, ".
                "       col4=~1999.12.31 ".
                "WHERE col1='Default' ".
                "  AND col2=~bus    ;"
            ::
            :+  ~2012.5.3
                %db1
                "FROM my-table AS OF ~2012.5.1".
                "SELECT *;"
            ::
            :+  ~2012.5.4
                %db1
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
  %-  exec-0-2
        :*  run
            :+  ~2012.4.30
                %db1
                %-  zing  :~  "CREATE DATABASE db1;"
                              create-table
                              insert-table
                              ==
            ::
            :+  ~2012.5.1
                %db1
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
            :+  ~2012.5.3
                %db1
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
  %-  failon-1  :*  run
                    :+  ~2012.4.30
                        %db1
                        %-  zing  :~  "CREATE DATABASE db1;"
                                      create-table
                                      insert-table
                                      ==
                    :+  tmsp=~2012.5.5
                        %db1
                        "UPDATE my-table SET col0=~1980.1.1, col2=~nec; "
                    '3 duplicate row key(s)'
                    ==
::
::  fail on predicate, create 1 dup key
++  test-fail-update-01
  =|  run=@ud
  %-  failon-1  :*  run
                    :+  ~2012.4.30
                        %db1
                        %-  zing  :~  "CREATE DATABASE db1;"
                                      create-table
                                      insert-table
                                      ==
                    :+  tmsp=~2012.5.5
                        %db1
                        "UPDATE my-table SET col0=~2010.5.31, col2=~nec ".
                        "WHERE col2=~nomryg-nilref;"
                    '1 duplicate row key(s)'
                    ==
::
::  fail on column does not exist
++  test-fail-update-02
  =|  run=@ud
  %-  failon-1  :*  run
                    :+  ~2012.4.30
                        %db1
                        %-  zing  :~  "CREATE DATABASE db1;"
                                      create-table
                                      insert-table
                                      ==
                    :+  tmsp=~2012.5.5
                        %db1
                        "UPDATE my-table SET col5=~1980.1.1, col2=~nec; "
                    %-  crip  "UPDATE: [%qualified-table ship=~ database=%db1 ".
                                     "namespace=%dbo name=%my-table alias=~] ".
                                     "does not have column %col5"
                    ==
::
::  fail on column is wrong type
++  test-fail-update-03
  =|  run=@ud
  %-  failon-1  :*  run
                    :+  ~2012.4.30
                        %db1
                        %-  zing  :~  "CREATE DATABASE db1;"
                                      create-table
                                      insert-table
                                      ==
                    :+  tmsp=~2012.5.5
                        %db1
                        "UPDATE my-table SET col0=~1980.1.1, col2=44; "
                    %-  crip  "value type: p=~.ud does not match column: ".
                              "[%qualified-column qualifier=[%qualified-table ".
                              "ship=~ database=%db1 namespace=%dbo ".
                              "name=%my-table alias=~] name=%col2 alias=~]"
                    ==
::
::  fail on table not matching by column qualifier
++  test-fail-update-04
  =|  run=@ud
  %-  failon-c
  :*  run
      :+  ~2012.4.30
          %db1
      %-  zing  :~  "CREATE DATABASE db1;"
                    create-table
                    insert-table
                    ==
      ::
      :-  ~2012.5.1
          :-  %commands  :~  :*  %update
                                 ctes=~
                                 :*  %qualified-table
                                     ship=~
                                     database=%db1
                                     namespace=%dbo
                                     name=%my-table
                                     alias=~
                                     ==
                                 as-of=~
                                 :-  :~  :^  %qualified-column
                                             :*  %qualified-table
                                                 ship=~
                                                 database=%db1
                                                 namespace=%dbo
                                                 name=%my-table-1
                                                 alias=~
                                                 ==
                                             name=%col2
                                             alias=~
                                         :^  %qualified-column
                                             :*  %qualified-table
                                                 ship=~
                                                 database=%db1
                                                 namespace=%dbo
                                                 name=%my-table
                                                 alias=~
                                                 ==
                                             name=%col0
                                             alias=~
                                         ==
                                     :~  [p=~.p q=44]
                                         [p=~.da q=~1980.1.1]
                                         ==
                                 predicate=~
                                 ==
                             ==
      ::
      %-  crip
          "UPDATE: [%qualified-table ship=~ database=%db1 namespace=%dbo ".
          "name=%my-table alias=~] not matched by column qualifier ".
          "[%qualified-table ship=~ database=%db1 namespace=%dbo ".
          "name=%my-table-1 alias=~]"
      ==
::
::  fail on length of columns and values mismatch
++  test-fail-update-05
  =|  run=@ud
  %-  failon-c
  :*  run
      :+  ~2012.4.30
          %db1
      %-  zing  :~  "CREATE DATABASE db1;"
                    create-table
                    insert-table
                    ==
      ::
      :-  ~2012.5.1
          :-  %commands  :~  :*  %update
                                 ctes=~
                                 :*  %qualified-table
                                     ship=~
                                     database=%db1
                                     namespace=%dbo
                                     name=%my-table
                                     alias=~
                                     ==
                                 as-of=~
                                 :-  :~  :^  %qualified-column
                                             :*  %qualified-table
                                                 ship=~
                                                 database=%db1
                                                 namespace=%dbo
                                                 name=%my-table
                                                 alias=~
                                                 ==
                                             name=%col2
                                             alias=~
                                         :^  %qualified-column
                                             :*  %qualified-table
                                                 ship=~
                                                 database=%db1
                                                 namespace=%dbo
                                                 name=%my-table
                                                 alias=~
                                                 ==
                                             name=%col0
                                             alias=~
                                         ==
                                     :~  [p=~.p q=44]
                                         [p=~.da q=~1980.1.1]
                                         [p=~.ud q=44]
                                         ==
                                 predicate=~
                                ==
                             ==
      ::
      'UPDATE: columns and values mismatch'
      ==
::
::  fail on changing state after select in script
++  test-fail-update-06
  =|  run=@ud
  %-  failon-1
  :*  run
      :+  ~2000.1.1
          %sys
          "CREATE DATABASE db1"
      ::
      :+  ~2000.1.2
          %test
          "CREATE TABLE db1..my-table (col1 @t) PRIMARY KEY (col1); ".
          "SELECT 0;".
          "UPDATE my-table ".
          "   SET col1='hi'; "
      ::
      'UPDATE: state change after query in script'
      ==
::
::  fail on unknown column name in WHERE bad column = literal
++  test-fail-update-07
  =|  run=@ud
  %-  failon-1
  :*  run
      :+  ~2012.4.30
          %db1
          %-  zing  :~  "CREATE DATABASE db1;"
                        create-table
                        insert-table
                        ==
      ::
      :+  ~2012.5.1
          %db1
          "UPDATE my-table SET col1='hello' ".
          "WHERE bad-col = 'hello'"
      ::
      'column %bad-col does not exist'
      ==
::
::  fail on unknown column name in WHERE literal = bad column
++  test-fail-update-08
  =|  run=@ud
  %-  failon-1
  :*  run
      :+  ~2012.4.30
          %db1
          %-  zing  :~  "CREATE DATABASE db1;"
                        create-table
                        insert-table
                        ==
      ::
      :+  ~2012.5.1
          %db1
          "UPDATE my-table SET col1='hello' ".
          "WHERE 'hello' = bad-col"
      ::
      'column %bad-col does not exist'
      ==
::
::  fail on unknown column name in WHERE bad column = good column
++  test-fail-update-09
  =|  run=@ud
  %-  failon-1
  :*  run
      :+  ~2012.4.30
          %db1
          %-  zing  :~  "CREATE DATABASE db1;"
                        create-table
                        insert-table
                        ==
      ::
      :+  ~2012.5.1
          %db1
          "UPDATE my-table SET col1='hello' ".
          "WHERE bad-col = col1"
      ::
      'column %bad-col does not exist'
      ==
::
::  fail on unknown column name in WHERE good column = bad column
++  test-fail-update-10
  =|  run=@ud
  %-  failon-1
  :*  run
      :+  ~2012.4.30
          %db1
          %-  zing  :~  "CREATE DATABASE db1;"
                        create-table
                        insert-table
                        ==
      ::
      :+  ~2012.5.1
          %db1
          "UPDATE my-table SET col1='hello' ".
          "WHERE col1 = bad-col"
      ::
      'column %bad-col does not exist'
      ==
--