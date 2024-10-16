/-  *ast
/+  parse,  *test
|%
::  re-used components

::
::  Predicate
::
++  one-eq-1
  [%eq [[value-type=%ud value=1] ~ ~] [[value-type=%ud value=1] ~ ~]]
::
::  TABLE SET
::
++  foo-unaliased
  :+  %table-set 
      [%qualified-object ship=~ database='db1' namespace='dbo' name='foo']
      ~         ::alias
++  foo-aliased
  :+  %table-set
      [%qualified-object ship=~ database='db1' namespace='dbo' name='foo']
      [~ 'F1']  ::alias
++  bar-unaliased
  :+  %table-set
      [%qualified-object ship=~ database='db1' namespace='dbo' name='bar']
      ~         ::alias
++  bar-aliased
  :+  %table-set
      [%qualified-object ship=~ database='db1' namespace='dbo' name='bar']
      [~ 'B1']  ::alias
::
::  JOIN
::
++  join-bar
  |=  time=as-of
  :~  :*  %joined-object
          %join
          [~ time]  ::as-of
          bar-unaliased
          `one-eq-1
          ==
      ==
++  natural-join-bar
  |=  time=as-of
  :~  :*  %joined-object
          %join
          [~ time]  ::as-of
          bar-unaliased
          ~
          ==
      ==
++  join-bar-aliased
  |=  time=as-of
  :~  :*  %joined-object
          %join
          [~ time]  ::as-of
          bar-aliased 
          `one-eq-1
          ==
      ==
++  natural-join-bar-aliased
  |=  time=as-of
  :~  :*  %joined-object
          %join
          [~ time]  ::as-of
          bar-aliased 
          ~
          ==
      ==
++  join-bar-baz
  |=  time=as-of
  :~  :*  %joined-object
          %join
          [~ time]  ::as-of
          bar-unaliased
          `one-eq-1
          ==
      :*  %joined-object
          %left-join
          [~ time]  ::as-of
          :+  %table-set
              :*  %qualified-object
                  ~      ::ship
                  'db1'  ::database
                  'dbo'  ::namespace
                  'baz'  ::name
                  ==
              ~  ::alias
          `one-eq-1
          ==
      ==
++  aliased-join-bar-baz
  |=  time=as-of
  :~  :*  %joined-object
          %join
          [~ time]         ::as-of
          bar-aliased
          `one-eq-1
          ==
      :*  %joined-object
          %left-join
          [~ time]         ::as-of
          :+  %table-set
              :*  %qualified-object
                  ~      ::ship
                  'db1'  ::database
                  'dbo'  ::namespace
                  'baz'  ::name
                  ==
          [~ 'b2']  ::as-of
          `one-eq-1
          ==
      ==
++  cross-join-bar
  |=  time=as-of
  :~  :*  %joined-object
          %cross-join
          [~ time]  ::as-of
          bar-unaliased
          ~  ::predicate
          ==
      ==
++  cross-join-bar-aliased
  |=  time=as-of
  :~  :*  %joined-object
          %cross-join
          [~ time]  ::as-of
          bar-aliased
          ~  ::predicate
          ==
      ==
::
::  FROM
::
++  from-foo
  |=  time=as-of
  [~ [%from object=foo-unaliased as-of=[~ time] joins=~]]
++  from-foo-aliased
  |=  time=as-of
  [~ [%from object=foo-aliased as-of=[~ time] joins=~]]
++  from-foo-join-bar
  |=  time=as-of
  [~ [%from object=foo-unaliased as-of=[~ time] joins=(join-bar time)]]
++  from-foo-natural-join-bar
  |=  time=as-of
  [~ [%from object=foo-unaliased as-of=[~ time] joins=(natural-join-bar time)]]
++  from-foo-join-bar-aliased
  |=  time=as-of
  [~ [%from object=foo-unaliased as-of=[~ time] joins=(join-bar-aliased time)]]
++  from-foo-natural-join-bar-aliased
  |=  time=as-of
  :-  ~
      :^  %from
          object=foo-unaliased
          as-of=[~ time]
          joins=(natural-join-bar-aliased time)
++  from-foo-aliased-join-bar-aliased
  |=  time=as-of
  [~ [%from object=foo-aliased as-of=[~ time] joins=(join-bar-aliased time)]]
++  from-foo-aliased-natural-join-bar-aliased
  |=  time=as-of
  :-  ~
        :^  %from
            object=foo-aliased
            as-of=[~ time]
            joins=(natural-join-bar-aliased time)
++  from-foo-join-bar-baz
  |=  time=as-of
  [~ [%from object=foo-unaliased as-of=[~ time] joins=(join-bar-baz time)]]
++  from-foo-aliased-join-bar-baz
  |=  time=as-of
  :-  ~
     [%from object=foo-aliased as-of=[~ time] joins=(aliased-join-bar-baz time)]
++  from-foo-aliased-cross-join-bar
  |=  time=as-of
  [~ [%from object=foo-unaliased as-of=[~ time] joins=(cross-join-bar time)]]
++  from-foo-aliased-cross-join-bar-aliased
  |=  time=as-of
  :-  ~
      :^  %from
          foo-aliased
          [~ time]    ::as-of
          (cross-join-bar-aliased time)
::
::  SELECT
::
++  select-top-10-all   [%select top=[~ 10] bottom=~ columns=~[[%all %all]]]
++  select-all-columns  [%select top=~ bottom=~ columns=~[[%all %all]]]
::
::  QUERY
::
++  simple-from
  |=  time=as-of
  :*  %query 
      (from-foo time)
      ~      ::scalars
      ~      ::predicate
      ~      ::group-by
      ~      ::having
      select-top-10-all
      ~      ::order-by
      ==
++  simple-from-aliased
  |=  time=as-of
  :*  %query
      (from-foo-aliased time)
      ~      ::scalars
      ~      ::predicate
      ~      ::group-by
      ~      ::having
      select-top-10-all 
      ~      ::order-by
      ==
++  simple-from-join-bar
  |=  time=as-of
  :*  %query
      (from-foo-join-bar time)
      ~      ::scalars
      ~      ::predicate
      ~      ::group-by
      ~      ::having
      select-top-10-all
      ~      ::order-by
      ==
++  simple-from-join-bar-aliased
  |=  time=as-of
  :*  %query
      (from-foo-join-bar-aliased time)
      ~      ::scalars
      ~      ::predicate
      ~      ::group-by
      ~      ::having
      select-top-10-all
      ~      ::order-by
      ==

++  simple-from-aliased-join-bar-aliased
  |=  time=as-of
  :*  %query
      (from-foo-aliased-join-bar-aliased time)
      ~      ::scalars
      ~      ::predicate
      ~      ::group-by
      ~      ::having
      select-top-10-all
      ~      ::order-by
      ==
++  simple-from-join-bar-baz
  |=  time=as-of
  :*  %query
      (from-foo-join-bar-baz time)
      ~      ::scalars
      ~      ::predicate
      ~      ::group-by
      ~      ::having
      select-top-10-all
      ~      ::order-by
      ==
++  simple-from-aliased-join-bar-baz
  |=  time=as-of
  :*  %query
      (from-foo-aliased-join-bar-baz time)
      ~      ::scalars
      ~      ::predicate
      ~      ::group-by
      ~      ::having
      select-top-10-all
      ~      ::order-by
      ==
++  simple-from-cross-join-bar
  |=  time=as-of
  :*  %query
      (from-foo-aliased-cross-join-bar time)
      ~      ::scalars
      ~      ::predicate
      ~      ::group-by
      ~      ::having 
      selection=select-all-columns
      ~      ::order-by
      ==
++  simple-from-aliased-cross-bar
  |=  time=as-of
  :*  %query 
      (from-foo-aliased-cross-join-bar-aliased time)
      ~      ::scalars
      ~      ::predicate
      ~      ::group-by
      ~      ::having
      selection=select-all-columns
      ~      ::order-by
      ==
++  natural-from-join-bar
  |=  time=as-of
  :*  %query
      (from-foo-natural-join-bar time)
      ~      ::scalars
      ~      ::predicate
      ~      ::group-by
      ~      ::having
      select-all-columns
      ~      ::order-by
      ==
++  natural-from-join-bar-aliased
  |=  time=as-of
  :*  %query
      (from-foo-natural-join-bar-aliased time)
      ~      ::scalars
      ~      ::predicate
      ~      ::group-by
      ~      ::having
      select-all-columns
      ~      ::order-by
      ==
++  natural-from-aliased-join-bar-aliased
  |=  time=as-of
  :*  %query
      (from-foo-aliased-natural-join-bar-aliased time)
      ~      ::scalars
      ~      ::predicate
      ~      ::group-by
      ~      ::having
      select-all-columns
      ~      ::order-by
      ==
++  complex-join
  :~
    :+  %selection
        ctes=~
        :+  
          :*  %query
              :-
                ~
                :^  %from
                    [%table-set [%qualified-object ~ %db1 %dbo %foo] [~ 'F1']]
                    [~ [%dr ~h5.m30.s12]]
                    :~
                      :*  %joined-object
                          %join
                          as-of=[~ [%da ~2000.1.1]]
                          :+  %table-set
                              [%qualified-object ~ %db1 %dbo %bar]
                              [~ 'B2']
                          predicate=~
                          ==
                      :*  %joined-object
                          %left-join
                          as-of=[~ [%da ~2000.1.1]]
                          :+  %table-set
                              [%qualified-object ~ %db1 %dbo %baz]
                              [~ 'B3']
                          :-  ~
                              :+  %eq
                                  [[value-type=%ud value=1] ~ ~]
                                  [[value-type=%ud value=1] ~ ~]
                          ==
                      :*  %joined-object
                          %join
                          as-of=~
                          :+  %table-set
                              [%qualified-object ~ %db1 %dbo %bar]
                              [~ 'B4']
                          predicate=~
                          ==
                      :*  %joined-object
                          %left-join
                          as-of=~
                          :+  %table-set
                              [%qualified-object ~ %db1 %dbo %bar]
                              alias=~
                          :-  ~
                              :+  %eq
                                  [[value-type=%ud value=1] ~ ~]
                                  [[value-type=%ud value=1] ~ ~]
                          ==
                      :*  %joined-object
                          %join
                          [~ [%as-of-offset offset=2 units=%minutes]]
                          :+  %table-set
                              [%qualified-object ~ %db1 %dbo %foo]
                              alias=~
                          :-  ~
                              :+  %eq
                                  [[value-type=%ud value=1] ~ ~]
                                  [[value-type=%ud value=1] ~ ~]
                          ==
                      ==
              scalars=~
              predicate=~
              group-by=~
              having=~
              [%select top=~ bottom=~ columns=~[[%all %all]]]
              order-by=~
              ==
          ~
          ~
    ==
::
++  expected
  |=  [b=$-(as-of query) time=as-of]
  ~[[%selection ctes=~ [[(b time)] ~ ~]]]
::
::  AS OF queries
::
::  from foo %now (un-aliased)
++  test-from-as-of-01
  %+  expect-eq
      !>  (expected [simple-from [%as-of-offset 0 %seconds]])
      !>  %-  parse:parse(default-database 'db1')
              "FROM foo aS Of Now SELECT TOP 10 *"
::
::  from foo %now (aliased)
++  test-from-as-of-02
  %+  expect-eq
      !>  (expected [simple-from-aliased [%as-of-offset 0 %seconds]])
      !>  %-  parse:parse(default-database 'db1')
              "FROM foo AS OF NOW F1 SELECT TOP 10 *"
::
::  from foo %now (aliased as)
++  test-from-as-of-03
  %+  expect-eq
      !>  (expected [simple-from-aliased [%as-of-offset 0 %seconds]])
      !>  %-  parse:parse(default-database 'db1')
              "FROM foo AS OF NOW as F1 SELECT TOP 10 *"
::
::  from foo %now (un-aliased) join bar %now (un-aliased)
++  test-from-as-of-04
  %+  expect-eq
      !>  (expected [simple-from-join-bar [%as-of-offset 0 %seconds]])
      !>  %-  parse:parse(default-database 'db1')
            "FROM foo AS OF NOW join bar AS OF NOW on 1 = 1 SELECT TOP 10 *"
::
::  from foo %now (un-aliased) join bar %now (aliased)
++  test-from-as-of-05
  %+  expect-eq
      !>  (expected [simple-from-join-bar-aliased [%as-of-offset 0 %seconds]])
      !>  %-  parse:parse(default-database 'db1')
            "FROM foo AS OF NOW join bar AS OF NOW B1 on 1 = 1 SELECT TOP 10 *"
::
::  from foo %now (un-aliased) join bar %now (aliased as)
++  test-from-as-of-06
  %+  expect-eq
      !>  (expected [simple-from-join-bar-aliased [%as-of-offset 0 %seconds]])
      !>  %-  parse:parse(default-database 'db1')
            "FROM foo AS OF NOW join bar AS OF NOW  as  B1 on 1 = 1 ".
            "SELECT TOP 10 *"
::
::  from foo %now (aliased) join bar %now (aliased as)
++  test-from-as-of-07
  %+  expect-eq
      !>  %-  expected
              [simple-from-aliased-join-bar-aliased [%as-of-offset 0 %seconds]]
      !>  %-  parse:parse(default-database 'db1')
            "FROM foo AS OF NOW F1 join bar AS OF NOW B1 on 1 = 1 ".
            "SELECT TOP 10 *"
::
::  from foo %now (un-aliased) join bar %now (un-aliased)
::                             left join baz %now (un-aliased)
++  test-from-as-of-08
  %+  expect-eq
      !>  (expected [simple-from-join-bar-baz [%as-of-offset 0 %seconds]])
      !>  %-  parse:parse(default-database 'db1')
            "FROM foo AS OF NOW ".
            "join bar AS OF NOW on 1 = 1 left ".
            "join baz AS OF NOW on 1 = 1 SELECT TOP 10 *"
::
::  from foo %now (aliased) join bar %now (aliased) left join baz %now (aliased)
++  test-from-as-of-09
  %+  expect-eq
      !>  %-  expected
              [simple-from-aliased-join-bar-baz [%as-of-offset 0 %seconds]]
      !>  %-  parse:parse(default-database 'db1')
            "FROM foo AS OF NOW F1 ".
            "join bar AS OF NOW as B1 on 1 = 1 ".
            "left join baz AS OF NOW b2 on 1 = 1 SELECT TOP 10 *"
::
::  from foo %now as (aliased) cross join bar %now (aliased)
++  test-from-as-of-10
  %+  expect-eq
      !>  (expected [simple-from-aliased-cross-bar [%as-of-offset 0 %seconds]])
      !>  %-  parse:parse(default-database 'db1')
            "FROM foo AS OF NOW as F1 cross join bar AS OF NOW B1 SELECT *"
::
::  from foo %now cross join bar %now
++  test-from-as-of-11
  %+  expect-eq
      !>  (expected [simple-from-cross-join-bar [%as-of-offset 0 %seconds]])
      !>  %-  parse:parse(default-database 'db1')
              "FROM foo AS OF NOW cross join bar AS OF NOW SELECT *"
::
::  from foo %now (aliased) cross join bar %now as (aliased)
++  test-from-as-of-12
  %+  expect-eq
      !>  (expected [simple-from-aliased-cross-bar [%as-of-offset 0 %seconds]])
      !>  %-  parse:parse(default-database 'db1')
            "FROM foo AS OF NOW F1 cross join bar AS OF NOW as B1 SELECT *"
::
::  from foo as-of 2 minutes ago (un-aliased)
++  test-from-as-of-13
  %+  expect-eq
      !>  (expected [simple-from [%as-of-offset 2 %minutes]])
      !>  %-  parse:parse(default-database 'db1')
              "FROM foo As oF 2 miNutes AgO SELECT TOP 10 *"
::
::  from foo as-of 2 minutes ago (aliased)
++  test-from-as-of-14
  %+  expect-eq
      !>  (expected [simple-from-aliased [%as-of-offset 2 %minutes]])
      !>  %-  parse:parse(default-database 'db1')
              "FROM foo AS OF 2 minutes AGO F1 SELECT TOP 10 *"
::
::  from foo as-of 2 minutes ago (aliased as)
++  test-from-as-of-15
  %+  expect-eq
      !>  (expected [simple-from-aliased [%as-of-offset 2 %minutes]])
      !>  %-  parse:parse(default-database 'db1')
              "FROM foo AS OF 2 minutes AGO as F1 SELECT TOP 10 *"
::
::  from foo as-of 2 minutes ago (un-aliased) 
::  join bar as-of 2 minutes ago (un-aliased)
++  test-from-as-of-16
  %+  expect-eq
      !>  (expected [simple-from-join-bar [%as-of-offset 2 %minutes]])
      !>  %-  parse:parse(default-database 'db1')
            "FROM foo AS OF 2 minutes AGO ".
            "join bar AS OF 2 minutes AGO on 1 = 1 SELECT TOP 10 *"
::
::  from foo as-of 2 minutes ago (un-aliased) 
::  join bar as-of 2 minutes ago (aliased)
++  test-from-as-of-17
  %+  expect-eq
      !>  (expected [simple-from-join-bar-aliased [%as-of-offset 2 %minutes]])
      !>  %-  parse:parse(default-database 'db1')
            "FROM foo AS OF 2 minutes AGO ".
            "join bar AS OF 2 minutes AGO B1 on 1 = 1 SELECT TOP 10 *"
::
::  from foo as-of 2 minutes ago (un-aliased) 
::  join bar as-of 2 minutes ago (aliased as)
++  test-from-as-of-18
  %+  expect-eq
      !>  (expected [simple-from-join-bar-aliased [%as-of-offset 2 %minutes]])
      !>  %-  parse:parse(default-database 'db1')
            "FROM foo AS OF 2 minutes AGO ".
            "join bar AS OF 2 minutes AGO  as  B1 on 1 = 1 ".
            "SELECT TOP 10 *"
::
::  from foo as-of 2 minutes ago (aliased) 
::  join bar as-of 2 minutes ago (aliased as)
++  test-from-as-of-19
  %+  expect-eq
      !>  %-  expected
              [simple-from-aliased-join-bar-aliased [%as-of-offset 2 %minutes]]
      !>  %-  parse:parse(default-database 'db1')
            "FROM foo AS OF 2 minutes AGO F1 ".
            "join bar AS OF 2 minutes AGO B1 on 1 = 1 ".
            "SELECT TOP 10 *"
::
::  from foo as-of 2 minutes ago (un-aliased) 
::                             join bar as-of 2 minutes ago (un-aliased)
::                             left join baz as-of 2 minutes ago (un-aliased)
++  test-from-as-of-20
  %+  expect-eq
      !>  (expected [simple-from-join-bar-baz [%as-of-offset 2 %minutes]])
      !>  %-  parse:parse(default-database 'db1')
            "FROM foo AS OF 2 minutes AGO ".
            "join bar AS OF 2 minutes AGO on 1 = 1 left ".
            "join baz AS OF 2 minutes AGO on 1 = 1 SELECT TOP 10 *"
::
::  from foo as-of 2 minutes ago (aliased) 
::                             join bar as-of 2 minutes ago (aliased) 
::                             left join baz as-of 2 minutes ago (aliased)
++  test-from-as-of-21
  %+  expect-eq
      !>  %-  expected
              [simple-from-aliased-join-bar-baz [%as-of-offset 2 %minutes]]
      !>  %-  parse:parse(default-database 'db1')
            "FROM foo AS OF 2 minutes AGO F1 ".
            "join bar AS OF 2 minutes AGO as B1 on 1 = 1 ".
            "left join baz AS OF 2 minutes AGO b2 on 1 = 1 SELECT TOP 10 *"
::
::  from foo as-of 2 minutes ago as (aliased) 
::  cross join bar as-of 2 minutes ago (aliased)
++  test-from-as-of-22
  %+  expect-eq
      !>  (expected [simple-from-aliased-cross-bar [%as-of-offset 2 %minutes]])
      !>  %-  parse:parse(default-database 'db1')
            "FROM foo AS OF 2 minutes AGO as F1 ".
            "cross join bar AS OF 2 minutes AGO B1 SELECT *"
::
::  from foo as-of 2 minutes ago cross join bar as-of 2 minutes ago
++  test-from-as-of-23
  %+  expect-eq
      !>  (expected [simple-from-cross-join-bar [%as-of-offset 2 %minutes]])
      !>  %-  parse:parse(default-database 'db1')
              "FROM foo AS OF 2 minutes AGO ".
              "cross join bar AS OF 2 minutes AGO SELECT *"
::
::  from foo as-of 2 minutes ago (aliased) 
::  cross join bar as-of 2 minutes ago as (aliased)
++  test-from-as-of-24
  %+  expect-eq
      !>  (expected [simple-from-aliased-cross-bar [%as-of-offset 2 %minutes]])
      !>  %-  parse:parse(default-database 'db1')
            "FROM foo AS OF 2 minutes AGO F1 ".
            "cross join bar AS OF 2 minutes AGO as B1 SELECT *"
::
::  from foo as-of ~2000.1.1 (un-aliased)
++  test-from-as-of-25
  %+  expect-eq
      !>  (expected [simple-from [%da ~2000.1.1]])
      !>  %-  parse:parse(default-database 'db1')
              "FROM foo As Of ~2000.1.1 SELECT TOP 10 *"
::
::  from foo as-of ~2000.1.1 (aliased)
++  test-from-as-of-26
  %+  expect-eq
      !>  (expected [simple-from-aliased [%da ~2000.1.1]])
      !>  %-  parse:parse(default-database 'db1')
              "FROM foo As Of ~2000.1.1 F1 SELECT TOP 10 *"
::
::  from foo as-of ~2000.1.1 (aliased as)
++  test-from-as-of-27
  %+  expect-eq
      !>  (expected [simple-from-aliased [%da ~2000.1.1]])
      !>  %-  parse:parse(default-database 'db1')
              "FROM foo As Of ~2000.1.1 as F1 SELECT TOP 10 *"
::
::  from foo as-of ~2000.1.1 (un-aliased) 
::  join bar as-of ~2000.1.1 (un-aliased)
++  test-from-as-of-28
  %+  expect-eq
      !>  (expected [simple-from-join-bar [%da ~2000.1.1]])
      !>  %-  parse:parse(default-database 'db1')
            "FROM foo As Of ~2000.1.1 ".
            "join bar As Of ~2000.1.1 on 1 = 1 SELECT TOP 10 *"
::
::  from foo as-of ~2000.1.1 (un-aliased) 
::  join bar as-of ~2000.1.1 (aliased)
++  test-from-as-of-29
  %+  expect-eq
      !>  (expected [simple-from-join-bar-aliased [%da ~2000.1.1]])
      !>  %-  parse:parse(default-database 'db1')
            "FROM foo As Of ~2000.1.1 ".
            "join bar As Of ~2000.1.1 B1 on 1 = 1 SELECT TOP 10 *"
::
::  from foo as-of ~2000.1.1 (un-aliased) 
::  join bar as-of ~2000.1.1 (aliased as)
++  test-from-as-of-30
  %+  expect-eq
      !>  (expected [simple-from-join-bar-aliased [%da ~2000.1.1]])
      !>  %-  parse:parse(default-database 'db1')
            "FROM foo As Of ~2000.1.1 ".
            "join bar As Of ~2000.1.1  as  B1 on 1 = 1 ".
            "SELECT TOP 10 *"
::
::  from foo as-of ~2000.1.1 (aliased) 
::  join bar as-of ~2000.1.1 (aliased as)
++  test-from-as-of-31
  %+  expect-eq
      !>  %-  expected
              [simple-from-aliased-join-bar-aliased [%da ~2000.1.1]]
      !>  %-  parse:parse(default-database 'db1')
            "FROM foo As Of ~2000.1.1 F1 join bar As Of ~2000.1.1 B1 on 1 = 1 ".
            "SELECT TOP 10 *"
::
::  from foo as-of ~2000.1.1 (un-aliased) 
::                             join bar as-of ~2000.1.1 (un-aliased)
::                             left join baz as-of ~2000.1.1 (un-aliased)
++  test-from-as-of-32
  %+  expect-eq
      !>  (expected [simple-from-join-bar-baz [%da ~2000.1.1]])
      !>  %-  parse:parse(default-database 'db1')
            "FROM foo As Of ~2000.1.1 ".
            "join bar As Of ~2000.1.1 on 1 = 1 left ".
            "join baz As Of ~2000.1.1 on 1 = 1 SELECT TOP 10 *"
::
::  from foo as-of ~2000.1.1 (aliased) 
::                             join bar as-of ~2000.1.1 (aliased) 
::                             left join baz as-of ~2000.1.1 (aliased)
++  test-from-as-of-33
  %+  expect-eq
      !>  %-  expected
              [simple-from-aliased-join-bar-baz [%da ~2000.1.1]]
      !>  %-  parse:parse(default-database 'db1')
            "FROM foo As Of ~2000.1.1 F1 ".
            "join bar As Of ~2000.1.1 as B1 on 1 = 1 ".
            "left join baz As Of ~2000.1.1 b2 on 1 = 1 SELECT TOP 10 *"
::
::  from foo as-of ~2000.1.1 as (aliased) 
::  cross join bar as-of ~2000.1.1 (aliased)
++  test-from-as-of-34
  %+  expect-eq
      !>  (expected [simple-from-aliased-cross-bar [%da ~2000.1.1]])
      !>  %-  parse:parse(default-database 'db1')
            "FROM foo As Of ~2000.1.1 as F1 ".
            "cross join bar As Of ~2000.1.1 B1 SELECT *"
::
::  from foo as-of ~2000.1.1 cross join bar as-of ~2000.1.1
++  test-from-as-of-35
  %+  expect-eq
      !>  (expected [simple-from-cross-join-bar [%da ~2000.1.1]])
      !>  %-  parse:parse(default-database 'db1')
              "FROM foo As Of ~2000.1.1 cross join bar As Of ~2000.1.1 SELECT *"
::
::  from foo as-of ~2000.1.1 (aliased) 
::  cross join bar as-of ~2000.1.1 as (aliased)
++  test-from-as-of-36
  %+  expect-eq
      !>  (expected [simple-from-aliased-cross-bar [%da ~2000.1.1]])
      !>  %-  parse:parse(default-database 'db1')
            "FROM foo As Of ~2000.1.1 F1 ".
            "cross join bar As Of ~2000.1.1 as B1 SELECT *"
::
::  from foo as-of ~h5.m30.s12 (un-aliased)
++  test-from-as-of-37
  %+  expect-eq
      !>  (expected [simple-from [%dr ~h5.m30.s12]])
      !>  %-  parse:parse(default-database 'db1')
              "FROM foo As Of ~h5.m30.s12 SELECT TOP 10 *"
::
::  from foo as-of ~h5.m30.s12 (aliased)
++  test-from-as-of-38
  %+  expect-eq
      !>  (expected [simple-from-aliased [%dr ~h5.m30.s12]])
      !>  %-  parse:parse(default-database 'db1')
              "FROM foo As Of ~h5.m30.s12 F1 SELECT TOP 10 *"
::
::  from foo as-of ~h5.m30.s12 (aliased as)
++  test-from-as-of-39
  %+  expect-eq
      !>  (expected [simple-from-aliased [%dr ~h5.m30.s12]])
      !>  %-  parse:parse(default-database 'db1')
              "FROM foo As Of ~h5.m30.s12 as F1 SELECT TOP 10 *"
::
::  from foo as-of ~h5.m30.s12 (un-aliased) 
::  join bar as-of ~h5.m30.s12 (un-aliased)
++  test-from-as-of-40
  %+  expect-eq
      !>  (expected [simple-from-join-bar [%dr ~h5.m30.s12]])
      !>  %-  parse:parse(default-database 'db1')
            "FROM foo As Of ~h5.m30.s12 ".
            "join bar As Of ~h5.m30.s12 on 1 = 1 SELECT TOP 10 *"
::
::  from foo as-of ~h5.m30.s12 (un-aliased) 
::  join bar as-of ~h5.m30.s12 (aliased)
++  test-from-as-of-41
  %+  expect-eq
      !>  (expected [simple-from-join-bar-aliased [%dr ~h5.m30.s12]])
      !>  %-  parse:parse(default-database 'db1')
            "FROM foo As Of ~h5.m30.s12 ".
            "join bar As Of ~h5.m30.s12 B1 on 1 = 1 SELECT TOP 10 *"
::
::  from foo as-of ~h5.m30.s12 (un-aliased) 
::  join bar as-of ~h5.m30.s12 (aliased as)
++  test-from-as-of-42
  %+  expect-eq
      !>  (expected [simple-from-join-bar-aliased [%dr ~h5.m30.s12]])
      !>  %-  parse:parse(default-database 'db1')
            "FROM foo As Of ~h5.m30.s12 ".
            "join bar As Of ~h5.m30.s12  as  B1 on 1 = 1 ".
            "SELECT TOP 10 *"
::
::  from foo as-of ~h5.m30.s12 (aliased) 
::  join bar as-of ~h5.m30.s12 (aliased as)
++  test-from-as-of-43
  %+  expect-eq
      !>  %-  expected
              [simple-from-aliased-join-bar-aliased [%dr ~h5.m30.s12]]
      !>  %-  parse:parse(default-database 'db1')
            "FROM foo As Of ~h5.m30.s12 F1 join bar As Of ~h5.m30.s12 B1 on 1 = 1 ".
            "SELECT TOP 10 *"
::
::  from foo as-of ~h5.m30.s12 (un-aliased) 
::                             join bar as-of ~h5.m30.s12 (un-aliased)
::                             left join baz as-of ~h5.m30.s12 (un-aliased)
++  test-from-as-of-44
  %+  expect-eq
      !>  (expected [simple-from-join-bar-baz [%dr ~h5.m30.s12]])
      !>  %-  parse:parse(default-database 'db1')
            "FROM foo As Of ~h5.m30.s12 ".
            "join bar As Of ~h5.m30.s12 on 1 = 1 left ".
            "join baz As Of ~h5.m30.s12 on 1 = 1 SELECT TOP 10 *"
::
::  from foo as-of ~h5.m30.s12 (aliased) 
::                             join bar as-of ~h5.m30.s12 (aliased) 
::                             left join baz as-of ~h5.m30.s12 (aliased)
++  test-from-as-of-45
  %+  expect-eq
      !>  %-  expected
              [simple-from-aliased-join-bar-baz [%dr ~h5.m30.s12]]
      !>  %-  parse:parse(default-database 'db1')
            "FROM foo As Of ~h5.m30.s12 F1 ".
            "join bar As Of ~h5.m30.s12 as B1 on 1 = 1 ".
            "left join baz As Of ~h5.m30.s12 b2 on 1 = 1 SELECT TOP 10 *"
::
::  from foo as-of ~h5.m30.s12 as (aliased) 
::  cross join bar as-of ~h5.m30.s12 (aliased)
++  test-from-as-of-46
  %+  expect-eq
      !>  (expected [simple-from-aliased-cross-bar [%dr ~h5.m30.s12]])
      !>  %-  parse:parse(default-database 'db1')
            "FROM foo As Of ~h5.m30.s12 as F1 ".
            "cross join bar As Of ~h5.m30.s12 B1 SELECT *"
::
::  from foo as-of ~h5.m30.s12 cross join bar as-of ~h5.m30.s12
++  test-from-as-of-47
  %+  expect-eq
      !>  (expected [simple-from-cross-join-bar [%dr ~h5.m30.s12]])
      !>  %-  parse:parse(default-database 'db1')
              "FROM foo As Of ~h5.m30.s12 ".
              "cross join bar As Of ~h5.m30.s12 SELECT *"
::
::  from foo as-of ~h5.m30.s12 (aliased) 
::  cross join bar as-of ~h5.m30.s12 as (aliased)
++  test-from-as-of-48
  %+  expect-eq
      !>  (expected [simple-from-aliased-cross-bar [%dr ~h5.m30.s12]])
      !>  %-  parse:parse(default-database 'db1')
            "FROM foo As Of ~h5.m30.s12 F1 ".
            "cross join bar As Of ~h5.m30.s12 as B1 SELECT *"
::
::  natural joins
::
::  (natural join) from foo %now (un-aliased) join bar %now (un-aliased)
++  test-from-as-of-49
  %+  expect-eq
      !>  (expected [natural-from-join-bar [%as-of-offset 0 %seconds]])
      !>  %-  parse:parse(default-database 'db1')
            "FROM foo AS OF NOW join bar AS OF NOW SELECT *"
::
::  (natural join) from foo %now (un-aliased) join bar %now (aliased)
++  test-from-as-of-50
  %+  expect-eq
      !>  (expected [natural-from-join-bar-aliased [%as-of-offset 0 %seconds]])
      !>  %-  parse:parse(default-database 'db1')
            "FROM foo AS OF NOW join bar AS OF NOW B1 SELECT *"
::
::  (natural join) from foo %now (un-aliased) join bar %now (aliased as)
++  test-from-as-of-51
  %+  expect-eq
      !>  (expected [natural-from-join-bar-aliased [%as-of-offset 0 %seconds]])
      !>  %-  parse:parse(default-database 'db1')
            "FROM foo AS OF NOW join bar AS OF NOW as B1 SELECT *"
::
::  (natural join) from foo %now (aliased) join bar %now (aliased as)
++  test-from-as-of-52
  %+  expect-eq
      !>  %-  expected
              [natural-from-aliased-join-bar-aliased [%as-of-offset 0 %seconds]]
      !>  %-  parse:parse(default-database 'db1')
            "FROM foo AS OF NOW F1 join bar AS OF NOW B1 SELECT *"
::
::  (natural join) from foo as-of 2 minutes ago (un-aliased) 
::                 join bar as-of 2 minutes ago (un-aliased)
++  test-from-as-of-53
  %+  expect-eq
      !>  (expected [natural-from-join-bar [%as-of-offset 2 %minutes]])
      !>  %-  parse:parse(default-database 'db1')
            "FROM foo AS OF 2 minutes AGO join bar AS OF 2 minutes AGO SELECT *"
::
::  (natural join) from foo as-of 2 minutes ago (un-aliased) 
::                 join bar as-of 2 minutes ago (aliased)
++  test-from-as-of-54
  %+  expect-eq
      !>  (expected [natural-from-join-bar-aliased [%as-of-offset 2 %minutes]])
      !>  %-  parse:parse(default-database 'db1')
         "FROM foo AS OF 2 minutes AGO join bar AS OF 2 minutes AGO B1 SELECT *"
::
::  (natural join) from foo as-of 2 minutes ago (un-aliased) 
::                 join bar as-of 2 minutes ago (aliased as)
++  test-from-as-of-55
  %+  expect-eq
      !>  (expected [natural-from-join-bar-aliased [%as-of-offset 2 %minutes]])
      !>  %-  parse:parse(default-database 'db1')
      "FROM foo AS OF 2 minutes AGO join bar AS OF 2 minutes AGO as B1 SELECT *"
::
::  (natural join) from foo as-of 2 minutes ago (aliased) 
::                 join bar as-of 2 minutes ago (aliased as)
++  test-from-as-of-56
  %+  expect-eq
      !>  %-  expected
              [natural-from-aliased-join-bar-aliased [%as-of-offset 2 %minutes]]
      !>  %-  parse:parse(default-database 'db1')
      "FROM foo AS OF 2 minutes AGO F1 join bar AS OF 2 minutes AGO B1 SELECT *"
::
::  (natural join) from foo as-of ~2000.1.1 (un-aliased) 
::                 join bar as-of ~2000.1.1 (un-aliased)
++  test-from-as-of-57
  %+  expect-eq
      !>  (expected [natural-from-join-bar [%da ~2000.1.1]])
      !>  %-  parse:parse(default-database 'db1')
            "FROM foo AS OF ~2000.1.1 join bar AS OF ~2000.1.1 SELECT *"
::
::  (natural join) from foo as-of ~2000.1.1 (un-aliased) 
::                 join bar as-of ~2000.1.1 (aliased)
++  test-from-as-of-58
  %+  expect-eq
      !>  (expected [natural-from-join-bar-aliased [%da ~2000.1.1]])
      !>  %-  parse:parse(default-database 'db1')
            "FROM foo AS OF ~2000.1.1 join bar AS OF ~2000.1.1 B1 SELECT *"
::
::  (natural join) from foo as-of ~2000.1.1 (un-aliased) 
::                 join bar as-of ~2000.1.1 (aliased as)
++  test-from-as-of-59
  %+  expect-eq
      !>  (expected [natural-from-join-bar-aliased [%da ~2000.1.1]])
      !>  %-  parse:parse(default-database 'db1')
            "FROM foo AS OF ~2000.1.1 join bar AS OF ~2000.1.1 as B1 SELECT *"
::
::  (natural join) from foo as-of ~2000.1.1 (aliased) 
::                 join bar as-of ~2000.1.1 (aliased as)
++  test-from-as-of-60
  %+  expect-eq
      !>  %-  expected
              [natural-from-aliased-join-bar-aliased [%da ~2000.1.1]]
      !>  %-  parse:parse(default-database 'db1')
            "FROM foo AS OF ~2000.1.1 F1 join bar AS OF ~2000.1.1 B1 SELECT *"
::
::  (natural join) from foo as-of ~h5.m30.s12 (un-aliased) 
::                 join bar as-of ~h5.m30.s12 (un-aliased)
++  test-from-as-of-61
  %+  expect-eq
      !>  (expected [natural-from-join-bar [%dr ~h5.m30.s12]])
      !>  %-  parse:parse(default-database 'db1')
            "FROM foo AS OF ~h5.m30.s12 join bar AS OF ~h5.m30.s12 SELECT *"
::
::  (natural join) from foo as-of ~h5.m30.s12 (un-aliased) 
::                 join bar as-of ~h5.m30.s12 (aliased)
++  test-from-as-of-62
  %+  expect-eq
      !>  (expected [natural-from-join-bar-aliased [%dr ~h5.m30.s12]])
      !>  %-  parse:parse(default-database 'db1')
            "FROM foo AS OF ~h5.m30.s12 join bar AS OF ~h5.m30.s12 B1 SELECT *"
::
::  (natural join) from foo as-of ~h5.m30.s12 (un-aliased) 
::                 join bar as-of ~h5.m30.s12 (aliased as)
++  test-from-as-of-63
  %+  expect-eq
      !>  (expected [natural-from-join-bar-aliased [%dr ~h5.m30.s12]])
      !>  %-  parse:parse(default-database 'db1')
          "FROM foo AS OF ~h5.m30.s12 join bar AS OF ~h5.m30.s12 as B1 SELECT *"
::
::  (natural join) from foo as-of ~h5.m30.s12 (aliased) 
::                 join bar as-of ~h5.m30.s12 (aliased as)
++  test-from-as-of-64
  %+  expect-eq
      !>  %-  expected
              [natural-from-aliased-join-bar-aliased [%dr ~h5.m30.s12]]
      !>  %-  parse:parse(default-database 'db1')
          "FROM foo AS OF ~h5.m30.s12 F1 join bar AS OF ~h5.m30.s12 B1 SELECT *"
::
::  complex join
++  test-from-as-of-65
  %+  expect-eq
      !>  complex-join
      !>  %-  parse:parse(default-database 'db1')
             "FROM foo AS OF ~h5.m30.s12 F1 ".
             "join      bar AS OF ~2000.1.1 B2 ".
             "left join baz AS OF ~2000.1.1 B3     on 1 = 1 ".
             "join      bar                 B4 ".
             "left join bar                        on 1 = 1 ".
             "join      foo AS OF 2 minutes AGO    on 1 = 1 ".
             "SELECT *"
--
