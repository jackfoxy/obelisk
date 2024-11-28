/-  ast
/+  parse,  *test
::
|%
::
:: grant permission
::
:: tests 1, 2, 3, 5, extra whitespace characters, ship-database, parent-database
++  test-grant-01
  =/  expected1  %:  grant:ast  %grant
                                permission=%adminread
                                grantees=~[[[~.p ~sampel-palnet] [~ /foo]]]
                                grant-objects=~[[%database 'db']]
                                duration=~
                                ==
  =/  expected2  %:  grant:ast  %grant
                                permission=%adminread
                                grantees=~[[[~.tas %parent] ~]]
                                grant-objects=~[[%database 'db']]
                                duration=~
                                ==
  %+  expect-eq
    !>  ~[expected1 expected2]
    !>  %-  parse:parse(default-database 'other-db')
            "grant  adminread\0a tO \0d ~sampel-palnet /foo on\0a ".
            "database  db;Grant adminRead to paRent on dataBase db"
::
::  * leading and trailing whitespace characters
::  * end delimiter not required
::  * ship-qualified-ns
++  test-grant-02
  %+  expect-eq
    !>  :~  %:  grant:ast  %grant
                           %readwrite
                           ~[[[~.p ~sampel-palnet] [~ /foo/bar]]]
                           ~[[%namespace 'db' 'ns']]
                           ~
                           ==
            ==
    !>  %-  parse:parse(default-database 'db2')
            "   \09Grant Readwrite   to ~sampel-palnet /foo/bar ".
            "on namespace db.ns "
::
:: ship unqualified ns
++  test-grant-03
  %+  expect-eq
    !>  :~  %:  grant:ast  %grant
                           permission=%readwrite
                           grantees=~[[[~.p ~sampel-palnet] ~]]
                           grant-objects=~[[%namespace 'db2' 'ns']]
                           duration=~
                           ==
            ==
    !>  %-  parse:parse(default-database 'db2')
            "Grant Readwrite to ~sampel-palnet on namespace ns"
::
:: siblings qualified ns
++  test-grant-04
  %+  expect-eq
    !>  :~  %:  grant:ast    %grant
                             permission=%readonly
                             grantees=~[[[~.tas %siblings] ~]]
                             grant-objects=~[[%namespace 'db' 'ns']]
                             duration=~
                             ==
            ==
    !>  %-  parse:parse(default-database 'db2')
            "grant readonly to SIBLINGS on namespace db.ns"
::
:: moons unqualified ns
++  test-grant-05
  %+  expect-eq
    !>  :~  %:  grant:ast    %grant
                             permission=%readwrite
                             grantees=~[[[~.tas %moons] ~]]
                             grant-objects=~[[%namespace 'db2' 'ns']]
                             duration=~
                             ==
            ==
    !>  %-  parse:parse(default-database 'db2')
            "Grant Readwrite to moonS on namespace ns"
::
:: ship db.ns.table
++  test-grant-06
  %+  expect-eq
    !>  :~  %:  grant:ast    %grant
                             permission=%readwrite
                             grantees=~[[[~.p ~sampel-palnet] ~]]
                             :~  :-  %table-set
                                     %:  qualified-object:ast  %qualified-object
                                                               ~
                                                               'db'
                                                               'ns'
                                                               'table'
                                                               ==
                                 ==
                             duration=~
                             ==
            ==
    !>  %-  parse:parse(default-database 'db2')
            "Grant Readwrite to ~sampel-palnet on db.ns.table"
::
:: parent db.ns.table
++  test-grant-07
  %+  expect-eq
    !>  :~  %:  grant:ast    %grant
                             permission=%adminread
                             grantees=~[[[~.tas %parent] ~]]
                             :~  :-  %table-set
                                     %:  qualified-object:ast  %qualified-object
                                                               ship=~
                                                               database='db'
                                                               namespace='ns'
                                                               name='table'
                                                               ==
                                 ==
                             duration=~
                             ==
            ==
    !>  %-  parse:parse(default-database 'db2')
            "grant adminread to parent on db.ns.table"
::
:: ship db..table
++  test-grant-08
  %+  expect-eq
    !>  :~  %:  grant:ast    %grant
                             permission=%readwrite
                             grantees=~[[[~.p ~sampel-palnet] ~]]
                             :~  :-  %table-set
                                     %:  qualified-object:ast  %qualified-object
                                                               ship=~
                                                               database='db'
                                                               namespace='dbo'
                                                               name='table'
                                                               ==
                                 ==
                             duration=~
                             ==
            ==
    !>  %-  parse:parse(default-database 'db2')
            "Grant Readwrite to ~sampel-palnet on db..table"
::
:: parent on db..table
++  test-grant-09
  %+  expect-eq
    !>  :~  %:  grant:ast    %grant
                             permission=%adminread
                             grantees=~[[[~.tas %parent] ~]]
                             :~  :-  %table-set
                                     %:  qualified-object:ast  %qualified-object
                                                               ship=~
                                                               database='db'
                                                               namespace='dbo'
                                                               name='table'
                                                               ==
                                 ==
                             duration=~
                             ==
            ==
    !>  %-  parse:parse(default-database 'db2')
            "grant adminread to parent on db..table"
::
:: ship table
++  test-grant-10
  %+  expect-eq
    !>  :~  %:  grant:ast    %grant
                             permission=%readwrite
                             grantees=~[[[~.p ~sampel-palnet] ~]]
                             :~  :-  %table-set
                                     %:  qualified-object:ast  %qualified-object
                                                               ship=~
                                                               database='db2'
                                                               namespace='dbo'
                                                               name='table'
                                                               ==
                                 ==
                             duration=~
                             ==
            ==
    !>  %-  parse:parse(default-database 'db2')
            "Grant Readwrite to ~sampel-palnet on table"
::
:: ship list table
++  test-grant-11
  %+  expect-eq
    !>  :~  %:  grant:ast    %grant
                             permission=%readwrite
                             :~  [[~.p ~zod] ~]
                                 [[~.p ~bus] ~]
                                 [[~.p ~nec] ~]
                                 [[~.p ~sampel-palnet] ~]
                                 ==
                             :~  :-  %table-set
                                     %:  qualified-object:ast  %qualified-object
                                                               ship=~
                                                               database='db2'
                                                               namespace='dbo'
                                                               name='table'
                                                               ==
                                 ==
                             duration=~
                             ==
            ==
    !>  %-  parse:parse(default-database 'db2')
            "grant Readwrite to ~zod,~bus,~nec,~sampel-palnet on table"
::
:: ship list on db..table
++  test-grant-12
  %+  expect-eq
    !>  :~  %:  grant:ast    %grant
                             permission=%adminread
                             :~  [[~.p ~zod] ~]
                                 [[~.p ~bus] ~]
                                 [[~.p ~nec] ~]
                                 [[~.p ~sampel-palnet] ~]
                                 ==
                             :~  :-  %table-set
                                     %:  qualified-object:ast  %qualified-object
                                                               ship=~
                                                               database='db'
                                                               namespace='dbo'
                                                               name='table'
                                                               ==
                                 ==
                             duration=~
                             ==
            ==
    !>  %-  parse:parse(default-database 'db2')
            "grant adminread to ~zod,~bus,~nec,~sampel-palnet on db..table"
::
:: ship list spaced, table
++  test-grant-13
  %+  expect-eq
    !>  :~  %:  grant:ast    %grant
                             permission=%readwrite
                             :~  [[~.p ~zod] ~]
                                 [[~.p ~bus] ~]
                                 [[~.p ~nec] ~]
                                 [[~.p ~sampel-palnet] ~]
                                 ==
                             :~  :-  %table-set
                                     %:  qualified-object:ast  %qualified-object
                                                               ship=~
                                                               database='db2'
                                                               namespace='dbo'
                                                               name='table'
                                                               ==
                                 ==
                             duration=~
                             ==
            ==
    !>  %-  parse:parse(default-database 'db2')
            "grant Readwrite to  ~zod,\0a~bus ,~nec , ~sampel-palnet on table"
::
:: ship list spaced, on db..table
++  test-grant-14
  %+  expect-eq
    !>  :~  %:  grant:ast    %grant
                             permission=%adminread
                             :~  [[~.p ~zod] ~]
                                 [[~.p ~bus] ~]
                                 [[~.p ~nec] ~]
                                 [[~.p ~sampel-palnet] ~]
                                 ==
                             :~  :-  %table-set
                                     %:  qualified-object:ast  %qualified-object
                                                               ship=~
                                                               database='db'
                                                               namespace='dbo'
                                                               name='table'
                                                               ==
                                 ==
                             duration=~
                             ==
            ==
    !>  %-  parse:parse(default-database 'db2')
            "grant adminread to ~zod , ~bus, ~nec ,~sampel-palnet on db..table"
::
:: parent table
++  test-grant-15
  %+  expect-eq
    !>  :~  %:  grant:ast    %grant
                             permission=%adminread
                             grantees=~[[[~.tas %parent] ~]]
                             :~  :-  %table-set
                                     %:  qualified-object:ast  %qualified-object
                                                               ship=~
                                                               database='db2'
                                                               namespace='dbo'
                                                               name='table'
                                                               ==
                                 ==
                             duration=~
                             ==
            ==
    !>  %-  parse:parse(default-database 'db2')
            "grant adminread to parent on table"
::
:: our table
++  test-grant-16
  %+  expect-eq
    !>  :~  %:  grant:ast    %grant
                             permission=%adminread
                             grantees=~[[[~.tas %our] ~]]
                             :~  :-  %table-set
                                     %:  qualified-object:ast  %qualified-object
                                                               ship=~
                                                               database='db2'
                                                               namespace='dbo'
                                                               name='table'
                                                               ==
                                 ==
                             duration=~
                             ==
            ==
    !>  %-  parse:parse(default-database 'db2')
            "grant adminread to our on table"
::
:: all grantees with path, all grant-objects
++  test-grant-17
  %+  expect-eq
    !>  :~  %:  grant:ast    %grant
                             permission=%adminread
                             :~  [[~.tas %our] [~ /foo/our]]
                                 [[~.p ~sampel-palnet] [~ /foo/ship]]
                                 [[~.tas %parent] [~ /foo/parent]]
                                 [[~.tas %siblings] [~ /foo/siblings]]
                                 [[~.tas %moons] [~ /foo/moons]]
                                 ==
                             :~  :-  %table-set
                                     %:  qualified-object:ast  %qualified-object
                                                               ship=~
                                                               database='db2'
                                                               namespace='dbo'
                                                               name='table'
                                                               ==
                                 [%database 'db1']
                                 [%namespace 'db2' 'ns']
                                 [%table-column /db3/dbo/table1/column1]
                                 ==
                             duration=~
                             ==
            ==
    !>  %-  parse:parse(default-database 'db2')
            "grant adminread to our /foo/our, ~sampel-palnet /foo/ship, ".
            "parent /foo/parent, siblings /foo/siblings, moons /foo/moons ".
            "on table, database db1, namespace db2.ns, /db3/dbo/table1/column1"
::
:: all grantees with path, all grant-objects, FOR @dr STARTING @da
++  for-dr-da
  :~  %:  grant:ast    %grant
                       permission=%adminread
                       :~  [[~.tas %our] [~ /foo/our]]
                           [[~.p ~sampel-palnet] [~ /foo/ship]]
                           [[~.tas %parent] [~ /foo/parent]]
                           [[~.tas %siblings] [~ /foo/siblings]]
                           [[~.tas %moons] [~ /foo/moons]]
                           ==
                       :~  :-  %table-set
                               %:  qualified-object:ast  %qualified-object
                                                         ship=~
                                                         database='db2'
                                                         namespace='dbo'
                                                         name='table'
                                                         ==
                           [%database 'db1']
                           [%namespace 'db2' 'ns']
                           [%table-column /db3/dbo/table1/column1]
                           ==
                       duration=`[p=[%dr ~d4.h2] q=[~ [%da ~2024.11.11]]]
                       ==
     ==
++  test-grant-18
  %+  expect-eq
    !>  for-dr-da
    !>  %-  parse:parse(default-database 'db2')
            "grant adminread to our /foo/our, ~sampel-palnet /foo/ship, ".
            "parent /foo/parent, siblings /foo/siblings, moons /foo/moons ".
            "on table, database db1, namespace db2.ns, /db3/dbo/table1/column1".
            " FoR ~d4.h2 STaRTING ~2024.11.11"
::
:: all grantees with path, all grant-objects, FOR @dr @da
++  test-grant-19
  %+  expect-eq
    !>  for-dr-da
    !>  %-  parse:parse(default-database 'db2')
            "grant adminread to our /foo/our, ~sampel-palnet /foo/ship, ".
            "parent /foo/parent, siblings /foo/siblings, moons /foo/moons ".
            "on table, database db1, namespace db2.ns, /db3/dbo/table1/column1".
            " FoR ~d4.h2 ~2024.11.11"

::to do: test SERVER
::
:: all SERVER grantee, all grant-objects, FOR @dr @da
++  test-grant-20
  %+  expect-eq
    !>  :~  %:  grant:ast    %grant
                             permission=%adminread
                             :~  [[~.tas %our] [~ /foo/our]]
                                 [[~.p ~sampel-palnet] [~ /foo/ship]]
                                 [[~.tas %parent] [~ /foo/parent]]
                                 [[~.tas %siblings] [~ /foo/siblings]]
                                 [[~.tas %moons] [~ /foo/moons]]
                                 ==
                             :~  [%server %server]
                                 ==
                             duration=`[p=[%dr ~d4.h2] q=[~ [%da ~2024.11.11]]]
                             ==
            ==
    !>  %-  parse:parse(default-database 'db2')
            "grant adminread to our /foo/our, ~sampel-palnet /foo/ship, ".
            "parent /foo/parent, siblings /foo/siblings, moons /foo/moons ".
            "on SERVEr".
            " FoR ~d4.h2 ~2024.11.11"
::
:: fail when database qualifier is not a term
++  test-fail-grant-01
  %-  expect-fail
  |.  %-  parse:parse(default-database 'db2')
          "grant adminread to parent on Db.ns.table"
::
:: fail when namespace qualifier is not a term
++  test-fail-grant-02
  %-  expect-fail
  |.  %-  parse:parse(default-database 'db2')
          "grant adminread to parent on db.Ns.table"
::
:: fail when table name is not a term
++  test-fail-grant-03
  %-  expect-fail
  |.  %-  parse:parse(default-database 'other-db')
          "grant adminread to parent on Table"
::
:: fail when table name is qualified with ship
++  test-fail-grant-04
  %-  expect-fail
  |.  %-  parse:parse(default-database 'other-db')
          "grant adminread to parent ~zod.db.ns.name"
::
:: fail when permission is not correct
++  test-fail-grant-05
  %-  expect-fail
  |.  %-  parse:parse(default-database 'other-db')
          "grant admin-read to parent db.ns.table"

::
:: fail when duration is not correct
++  test-fail-grant-06
  %-  expect-fail
  |.  %-  parse:parse(default-database 'other-db')
          "grant admin-read to parent db.ns.table ".
          "FOR ~d4h2 STARTING ~d2h4"
:: fail when SERVER is in list of grantees
++  test-fail-grant-07
  %-  expect-fail
  |.  %-  parse:parse(default-database 'other-db')
          "grant admin-read to SeRVER, parent db.ns.table ".
          "FOR ~d4h2 STARTING ~d2h4"

::
:: revoke permission
::
:: tests 1, 2, 3, 5, extra whitespace characters, ship-database, parent-database
++  test-revoke-01
  =/  expected1  %:  revoke:ast  %revoke
                                 %adminread
                                 ~[[[~.p ~sampel-palnet] ~]] 
                                 ~[[%database 'db']]
                                 ~
                                 ==
  =/  expected2  %:  revoke:ast  %revoke
                                 %adminread
                                 ~[[[~.tas %parent] ~]]
                                 ~[[%database 'db']]
                                 ~
                                 ==
  %+  expect-eq
    !>  ~[expected1 expected2]
    !>  %-  parse:parse(default-database 'other-db')
            "revoke  adminread\0a From \0d ~sampel-palnet on\0a database  db;".
            "Revoke adminRead fRom paRent on dataBase db"
::
:: leading and trailing whitespace characters, end delimiter not required 
:: on single, ship-qualified-ns
++  test-revoke-02
  %+  expect-eq
    !>  :~  %:  revoke:ast  %revoke
                            %readwrite
                            ~[[[~.p ~sampel-palnet] ~]] 
                            ~[[%namespace 'db' 'ns']]
                            ~
                            ==
            ==
    !>  %-  parse:parse(default-database 'db2')
            "   \09ReVoke Readwrite   From ~sampel-palnet on namespace db.ns "
::
:: ship unqualified ns
++  test-revoke-03
  %+  expect-eq
    !>  :~  %:  revoke:ast  %revoke
                            %readwrite
                            ~[[[~.p ~sampel-palnet] ~]]
                            ~[[%namespace 'db2' 'ns']]
                            ~
                            ==
            ==
    !>  %-  parse:parse(default-database 'db2')
            "Revoke Readwrite from ~sampel-palnet on namespace ns"
::
:: siblings qualified ns
++  test-revoke-04
  %+  expect-eq
    !>  :~  %:  revoke:ast  %revoke
                            %readonly
                            ~[[[~.tas %siblings] ~]]
                            ~[[%namespace 'db' 'ns']]
                            ~
                            ==
            ==
    !>  %-  parse:parse(default-database 'db2')
            "revoke readonly from SIBLINGS on namespace db.ns"
::
:: moons unqualified ns
++  test-revoke-05
  %+  expect-eq
    !>  :~  %:  revoke:ast  %revoke
                            %readwrite
                            ~[[[~.tas %moons] ~]]
                            ~[[%namespace 'db2' 'ns']]
                            ~
                            ==
            ==
    !>  %-  parse:parse(default-database 'db2')
            "Revoke Readwrite from moonS on namespace ns"
::
:: ship db.ns.table
++  test-revoke-06
  %+  expect-eq
    !>  :~  %:  revoke:ast  %revoke
                            %readwrite
                            ~[[[~.p ~sampel-palnet] ~]]
                            :~  :-  %table-set
                                    :*  %qualified-object
                                          ship=~
                                          database='db'
                                          namespace='ns'
                                          name='table'
                                          ==
                                ==
                            ~
                            ==
            ==
    !>  %-  parse:parse(default-database 'db2')
            "Revoke Readwrite from ~sampel-palnet on db.ns.table"
::
:: all from all db.ns.table
++  test-revoke-07
  %+  expect-eq
    !>  :~  %:  revoke:ast  %revoke
                            %all
                            ~[[[~.tas %all] ~]]
                            :~  :-  %table-set
                                    :*  %qualified-object
                                        ship=~
                                        database='db'
                                        namespace='ns'
                                        name='table'
                                        ==
                                ==
                            ~
                            ==
            ==
    !>  %-  parse:parse(default-database 'db2')
            "revoke all from all on db.ns.table"
::
:: ship db..table
++  test-revoke-08
  %+  expect-eq
    !>  :~  %:  revoke:ast  %revoke
                            %readwrite
                            ~[[[~.p ~sampel-palnet] ~]]
                            :~  :-  %table-set
                                    :*  %qualified-object
                                        ship=~
                                        database='db'
                                        namespace='dbo'
                                        name='table'
                                        ==
                                ==
                            ~
                            ==
            ==
    !>  %-  parse:parse(default-database 'db2')
            "Revoke Readwrite from ~sampel-palnet on db..table"
::
:: parent on db..table
++  test-revoke-09
  %+  expect-eq
    !>  :~  %:  revoke:ast  %revoke
                            %adminread
                            ~[[[~.tas %parent] ~]]
                            :~  :-  %table-set
                                    :*  %qualified-object
                                        ship=~
                                        database='db'
                                        namespace='dbo'
                                        name='table'
                                        ==
                                ==
                            ~
                            ==
            ==
    !>  %-  parse:parse(default-database 'db2')
            "revoke adminread from parent on db..table"
::
:: single ship table
++  test-revoke-10
  %+  expect-eq
    !>  :~  %:  revoke:ast  %revoke
                            %readwrite
                            ~[[[~.p ~sampel-palnet] ~]]
                            :~  :-  %table-set
                                    :*  %qualified-object
                                        ship=~
                                        database='db2'
                                        namespace='dbo'
                                        name='table'
                                        ==
                                ==
                            ~
                            ==
            ==
    !>  %-  parse:parse(default-database 'db2')
            "Revoke Readwrite from ~sampel-palnet on table"
::
:: ship list table
++  test-revoke-11
  %+  expect-eq
    !>  :~  %:  revoke:ast  %revoke
                            %readwrite
                            :~  [[~.p ~zod] ~]
                                [[~.p ~sampel-palnet-sampel-palnet] ~]
                                [[~.p ~nec] ~]
                                [[~.p ~sampel-palnet] ~]
                                ==
                            :~  :-  %table-set
                                    :*  %qualified-object
                                        ship=~
                                        database='db2'
                                        namespace='dbo'
                                        name='table'
                                        ==
                                ==
                            ~
                            ==
                            
            ==
    !>  %-  parse:parse(default-database 'db2')
            "Revoke Readwrite from ~zod,~sampel-palnet-sampel-palnet,~nec,".
            "~sampel-palnet on table"
::
:: ship list on db..table
++  test-revoke-12
  %+  expect-eq
    !>  :~  %:  revoke:ast  %revoke
                            %adminread
                            :~  [[~.p ~zod] ~]
                                [[~.p ~bus] ~]
                                [[~.p ~nec] ~]
                                [[~.p ~sampel-palnet] ~]
                                ==
                            :~  :-  %table-set
                                    :*  %qualified-object
                                        ship=~
                                        database='db'
                                        namespace='dbo'
                                        name='table'
                                        ==
                                ==
                            ~
                            ==
            ==
    !>  %-  parse:parse(default-database 'db2')
            "revoke adminread from ~zod,~bus,~nec,~sampel-palnet on db..table"
::
:: ship list spaced, table
++  test-revoke-13
  %+  expect-eq
    !>  :~  %:  revoke:ast  %revoke
                            %readwrite
                            :~  [[~.p ~zod] ~]
                                [[~.p ~bus] ~]
                                [[~.p ~nec] ~]
                                [[~.p ~sampel-palnet] ~]
                                ==
                            :~  :-  %table-set
                                    :*  %qualified-object
                                        ship=~
                                        database='db2'
                                        namespace='dbo'
                                        name='table'
                                        ==
                                ==
                            ~
                            ==
            ==
    !>  %-  parse:parse(default-database 'db2')
            "Revoke Readwrite from  ~zod,\0a~bus ,~nec ,".
            " ~sampel-palnet on table"
::
:: ship list spaced, on db..table
++  test-revoke-14
  %+  expect-eq
    !>  :~  %:  revoke:ast  %revoke
                            %adminread
                            :~  [[~.p ~zod] ~]
                                [[~.p ~bus] ~]
                                [[~.p ~nec] ~]
                                [[~.p ~sampel-palnet] ~]
                                ==
                            :~  :-  %table-set
                                    :*  %qualified-object
                                        ship=~
                                        database='db'
                                        namespace='dbo'
                                        name='table'
                                        ==
                                ==
                            ~
                            ==
            ==
    !>  %-  parse:parse(default-database 'db2')
            "revoke adminread from ~zod , ~bus, ~nec ,".
            "~sampel-palnet on db..table"
::
:: parent table
++  test-revoke-15
  %+  expect-eq
    !>  :~  %:  revoke:ast  %revoke
                            %adminread
                            ~[[[~.tas %parent] ~]]
                            :~  :-  %table-set
                                    :*  %qualified-object
                                        ship=~
                                        database='db2'
                                        namespace='dbo'
                                        name='table'
                                        ==
                                ==
                            ~
                            ==
            ==
    !>  %-  parse:parse(default-database 'db2')
            "revoke adminread from parent on table"
::
:: our table
++  test-revoke-16
  %+  expect-eq
    !>  :~  %:  revoke:ast    %revoke
                             permission=%adminread
                             revokees=~[[[~.tas %our] ~]]
                             :~  :-  %table-set
                                     %:  qualified-object:ast  %qualified-object
                                                               ship=~
                                                               database='db2'
                                                               namespace='dbo'
                                                               name='table'
                                                               ==
                                 ==
                             duration=~
                             ==
            ==
    !>  %-  parse:parse(default-database 'db2')
            "revoke adminread from our on table"
::
:: all revokees with path, all grant-objects
++  test-revoke-17
  %+  expect-eq
    !>  :~  %:  revoke:ast    %revoke
                             permission=%adminread
                             :~  [[~.tas %our] [~ /foo/our]]
                                 [[~.p ~sampel-palnet] [~ /foo/ship]]
                                 [[~.tas %parent] [~ /foo/parent]]
                                 [[~.tas %siblings] [~ /foo/siblings]]
                                 [[~.tas %moons] [~ /foo/moons]]
                                 ==
                             :~  :-  %table-set
                                     %:  qualified-object:ast  %qualified-object
                                                               ship=~
                                                               database='db2'
                                                               namespace='dbo'
                                                               name='table'
                                                               ==
                                 [%database 'db1']
                                 [%namespace 'db2' 'ns']
                                 [%table-column /db3/dbo/table1/column1]
                                 ==
                             duration=~
                             ==
            ==
    !>  %-  parse:parse(default-database 'db2')
            "revoke adminread from our /foo/our, ~sampel-palnet /foo/ship, ".
            "parent /foo/parent, siblings /foo/siblings, moons /foo/moons ".
            "on table, database db1, namespace db2.ns, /db3/dbo/table1/column1"
::
:: all revokeees with path, all revoke-objects, FOR @dr STARTING @da
++  revoke-for-dr-da
  :~  %:  revoke:ast    %revoke
                       permission=%adminread
                       :~  [[~.tas %our] [~ /foo/our]]
                           [[~.p ~sampel-palnet] [~ /foo/ship]]
                           [[~.tas %parent] [~ /foo/parent]]
                           [[~.tas %siblings] [~ /foo/siblings]]
                           [[~.tas %moons] [~ /foo/moons]]
                           ==
                       :~  :-  %table-set
                               %:  qualified-object:ast  %qualified-object
                                                         ship=~
                                                         database='db2'
                                                         namespace='dbo'
                                                         name='table'
                                                         ==
                           [%database 'db1']
                           [%namespace 'db2' 'ns']
                           [%table-column /db3/dbo/table1/column1]
                           ==
                       duration=`[p=[%dr ~d4.h2] q=[~ [%da ~2024.11.11]]]
                       ==
     ==
++  test-revoke-18
  %+  expect-eq
    !>  revoke-for-dr-da
    !>  %-  parse:parse(default-database 'db2')
            "revoke adminread from our /foo/our, ~sampel-palnet /foo/ship, ".
            "parent /foo/parent, siblings /foo/siblings, moons /foo/moons ".
            "on table, database db1, namespace db2.ns, /db3/dbo/table1/column1".
            " FoR ~d4.h2 STaRTING ~2024.11.11"
::
:: all revokeees with path, all revoke-objects, FOR @dr @da
++  test-revoke-19
  %+  expect-eq
    !>  revoke-for-dr-da
    !>  %-  parse:parse(default-database 'db2')
            "revoke adminread from our /foo/our, ~sampel-palnet /foo/ship, ".
            "parent /foo/parent, siblings /foo/siblings, moons /foo/moons ".
            "on table, database db1, namespace db2.ns, /db3/dbo/table1/column1".
            " FoR ~d4.h2 ~2024.11.11"
::
:: fail when database qualifier is not a term
++  test-fail-revoke-01
  %-  expect-fail
  |.  %-  parse:parse(default-database 'db2')
          "revoke adminread from parent on Db.ns.table"
::
:: fail when namespace qualifier is not a term
++  test-fail-revoke-02
  %-  expect-fail
  |.  %-  parse:parse(default-database 'db2')
          "revoke adminread from parent on db.Ns.table"
::
:: fail when table name is not a term
++  test-fail-revoke-03
  %-  expect-fail
  |.  %-  parse:parse(default-database 'other-db')
          "revoke adminread from parent on Table"
::
:: fail when table name is qualified with ship
++  test-fail-revoke-04
  %-  expect-fail
  |.  %-  parse:parse(default-database 'other-db')
          "revoke adminread from parent on ~zod.db.ns.name"
::
--