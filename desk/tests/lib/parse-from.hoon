/-  ast
/+  parse,  *test
::
::
|%
::
:: from object and joins
::
++  one-eq-1
  [%eq [[value-type=%ud value=1] ~ ~] [[value-type=%ud value=1] ~ ~]]
++  all-columns  [%all %all]
++  select-all-columns  [%select top=~ bottom=~ columns=~[all-columns]]
++  foo-table
  [%qualified-object ship=~ database='db1' namespace='dbo' name='foo']
++  select-top-10-all  [%select top=[~ 10] bottom=~ columns=~[[%all %all]]]
++  from-foo
  [~ [%from object=[%table-set object=foo-table alias=~] as-of=~ joins=~]]
++  from-foo-aliased
  [~ [%from object=[%table-set object=foo-table alias=[~ 'F1']] as-of=~ joins=~]]
++  simple-from-foo
  [%query from-foo scalars=~ ~ group-by=~ having=~ select-top-10-all ~]
++  aliased-from-foo
  [%query from-foo-aliased scalars=~ ~ group-by=~ having=~ select-top-10-all ~]
++  joins-bar
  ~[[%joined-object join=%join as-of=~ object=[%table-set object=[%qualified-object ship=~ database='db1' namespace='dbo' name='bar'] alias=~] predicate=`one-eq-1]]
++  from-foo-join-bar
  [~ [%from object=[%table-set object=foo-table alias=~] as-of=~ joins=joins-bar]]
++  simple-from-foo-join-bar
  [%query from-foo-join-bar scalars=~ ~ group-by=~ having=~ select-top-10-all ~]
++  joins-bar-aliased
  ~[[%joined-object join=%join as-of=~ object=[%table-set object=[%qualified-object ship=~ database='db1' namespace='dbo' name='bar'] alias=[~ 'b1']] predicate=`one-eq-1]]
++  from-foo-join-bar-aliased
  [~ [%from object=[%table-set object=foo-table alias=~] as-of=~ joins=joins-bar-aliased]]
++  simple-from-foo-join-bar-aliased
  [%query from-foo-join-bar-aliased scalars=~ ~ group-by=~ having=~ select-top-10-all ~]
++  from-foo-aliased-join-bar-aliased
  [~ [%from object=[%table-set object=foo-table alias=[~ 'f1']] as-of=~ joins=joins-bar-aliased]]
++  aliased-from-foo-join-bar-aliased
  [%query from-foo-aliased-join-bar-aliased scalars=~ ~ group-by=~ having=~ select-top-10-all ~]
++  joins-bar-baz
  ~[[%joined-object join=%join as-of=~ object=[%table-set object=[%qualified-object ship=~ database='db1' namespace='dbo' name='bar'] alias=~] predicate=`one-eq-1] [%joined-object join=%left-join as-of=~ object=[%table-set object=[%qualified-object ship=~ database='db1' namespace='dbo' name='baz'] alias=~] predicate=`one-eq-1]]
++  from-foo-join-bar-baz
  [~ [%from object=[%table-set object=foo-table alias=~] as-of=~ joins=joins-bar-baz]]
++  simple-from-foo-join-bar-baz
  [%query from-foo-join-bar-baz scalars=~ ~ group-by=~ having=~ select-top-10-all ~]
++  aliased-joins-bar-baz
  ~[[%joined-object join=%join as-of=~ object=[%table-set object=[%qualified-object ship=~ database='db1' namespace='dbo' name='bar'] alias=[~ 'B1']] predicate=`one-eq-1] [%joined-object join=%left-join as-of=~ object=[%table-set object=[%qualified-object ship=~ database='db1' namespace='dbo' name='baz'] alias=[~ 'b2']] predicate=`one-eq-1]]
++  aliased-foo-join-bar-baz
  [~ [%from object=[%table-set object=foo-table alias=[~ 'f1']] as-of=~ joins=aliased-joins-bar-baz]]
++  aliased-from-foo-join-bar-baz
  [%query aliased-foo-join-bar-baz scalars=~ ~ group-by=~ having=~ select-top-10-all ~]
++  foo-table-row  [%query-row ~['col1' 'col2' 'col3']]
::++  from-foo-row
::  [~ [%from object=[%table-set object=foo-table-row alias=~] as-of=~ joins=~]]
::++  from-foo-row-aliased
::  [~ [%from object=[%table-set object=foo-table-row alias=[~ 'F1']] as-of=~ joins=~]]
::++  simple-from-foo-row
::  [%query from-foo-row scalars=~ ~ group-by=~ having=~ select-top-10-all ~]
::++  aliased-from-foo-row
::  [%query from-foo-row-aliased scalars=~ ~ group-by=~ having=~ select-top-10-all ~]
::++  joins-col
::  ~[[%joined-object join=%join as-of=~ object=[%table-set object=[%query-row ~['col1' 'col2' 'col3']] alias=~] predicate=`one-eq-1]]
::++  from-foo-join-bar-row
::  [~ [%from object=[%table-set object=foo-table alias=~] as-of=~ joins=joins-col]]
::++  simple-from-foo-join-bar-row
::  [%query from-foo-join-bar-row scalars=~ ~ group-by=~ having=~ select-top-10-all ~]
::++  joins-col-aliased
::  ~[[%joined-object join=%join as-of=~ object=[%table-set object=[%query-row ~['col1' 'col2' 'col3']] alias=[~ 'b1']] predicate=`one-eq-1]]
::++  from-foo-join-bar-row-aliased
::  [~ [%from object=[%table-set object=foo-table alias=~] as-of=~ joins=joins-col-aliased]]
::++  simple-from-foo-join-bar-row-aliased
::  [%query from-foo-join-bar-row-aliased scalars=~ ~ group-by=~ having=~ select-top-10-all ~]
::++  from-foo-row-aliased-join-bar-aliased
::  [~ [%from object=[%table-set object=foo-table alias=[~ 'f1']] as-of=~ joins=joins-col-aliased]]
::++  aliased-from-foo-join-bar-row-aliased
::  [%query from-foo-row-aliased-join-bar-aliased scalars=~ ~ group-by=~ having=~ select-top-10-all ~]
::++  joins-bar-col
::  ~[[%joined-object join=%join as-of=~ object=[%table-set object=[%qualified-object ship=~ database='db1' namespace='dbo' name='bar'] alias=~] predicate=`one-eq-1] [%joined-object join=%left-join as-of=~ object=[%table-set object=[%query-row ~['col1' 'col2' 'col3']] alias=~] predicate=`one-eq-1]]
::++  from-foo-join-bar-row-baz
::  [~ [%from object=[%table-set object=foo-table-row alias=~] as-of=~ joins=joins-bar-col]]
::++  simple-from-foo-join-bar-row-baz
::  [%query from-foo-join-bar-row-baz scalars=~ ~ group-by=~ having=~ select-top-10-all ~]
::++  aliased-joins-bar-col
::  ~[[%joined-object join=%join as-of=~ object=[%table-set object=[%qualified-object ship=~ database='db1' namespace='dbo' name='bar'] alias=[~ 'B1']] predicate=`one-eq-1] [%joined-object join=%left-join as-of=~ object=[%table-set object=[%query-row ~['col1' 'col2' 'col3']] alias=[~ 'b2']] predicate=`one-eq-1]]
::++  aliased-foo-join-bar-col
::  [~ [%from object=[%table-set object=[%query-row ~['col1']] alias=[~ 'f1']] as-of=~ joins=aliased-joins-bar-col]]
::++  aliased-from-foo-join-bar-row-baz
::  [%query aliased-foo-join-bar-col scalars=~ ~ group-by=~ having=~ select-top-10-all ~]
++  foo-alias-y
  [%table-set object=[%qualified-object ship=~ database='db1' namespace='dbo' name='foo'] alias=[~ 'y']]
++  bar-alias-x
  [%table-set object=[%qualified-object ship=~ database='db1' namespace='dbo' name='bar'] alias=[~ 'x']]
++  foo-unaliased
  [%table-set object=[%qualified-object ship=~ database='db1' namespace='dbo' name='foo'] alias=~]
++  bar-unaliased
  [%table-set object=[%qualified-object ship=~ database='db1' namespace='dbo' name='bar'] alias=~]
++  passthru-row-y
  [%table-set object=[%query-row ~['col1' 'col2' 'col3']] alias=[~ 'y']]
++  passthru-row-x
  [%table-set object=[%query-row ~['col1' 'col2' 'col3']] alias=[~ 'x']]
++  passthru-unaliased
  [%table-set object=[%query-row ~['col1' 'col2' 'col3']] alias=~]
::
::  from foo (un-aliased)
++  test-from-join-01
  %+  expect-eq
    !>  ~[[%selection ctes=~ [[simple-from-foo] ~ ~]]]
    !>  (parse:parse(default-database 'db1') "FROM foo SELECT TOP 10 *")
::
::  from foo (aliased)
++  test-from-join-02
  %+  expect-eq
    !>  ~[[%selection ctes=~ [[aliased-from-foo] ~ ~]]]
    !>  (parse:parse(default-database 'db1') "FROM foo F1 SELECT TOP 10 *")
::
::  from foo (aliased as)
++  test-from-join-03
  %+  expect-eq
    !>  ~[[%selection ctes=~ [[aliased-from-foo] ~ ~]]]
    !>  (parse:parse(default-database 'db1') "FROM foo as F1 SELECT TOP 10 *")
::
::  from foo (un-aliased) join bar (un-aliased)
++  test-from-join-04
  %+  expect-eq
    !>  ~[[%selection ctes=~ [[simple-from-foo-join-bar] ~ ~]]]
    !>  (parse:parse(default-database 'db1') "FROM foo join bar on 1 = 1 SELECT TOP 10 *")
::
::  from foo (un-aliased) join bar (aliased)
++  test-from-join-05
  %+  expect-eq
    !>  ~[[%selection ctes=~ [[simple-from-foo-join-bar-aliased] ~ ~]]]
    !>  (parse:parse(default-database 'db1') "FROM foo join bar b1 on 1 = 1 SELECT TOP 10 *")
::
::  from foo (un-aliased) join bar (aliased as)
++  test-from-join-06
  %+  expect-eq
    !>  ~[[%selection ctes=~ [[simple-from-foo-join-bar-aliased] ~ ~]]]
    !>  (parse:parse(default-database 'db1') "FROM foo join bar  as  b1 on 1 = 1 SELECT TOP 10 *")
::
::  from foo (aliased lower case) join bar (aliased as)
++  test-from-join-07
  %+  expect-eq
    !>  ~[[%selection ctes=~ [[aliased-from-foo-join-bar-aliased] ~ ~]]]
    !>  (parse:parse(default-database 'db1') "FROM foo f1 join bar b1 on 1 = 1 SELECT TOP 10 *")
::
::  from foo (un-aliased) join bar (un-aliased) left join baz (un-aliased)
++  test-from-join-08
  %+  expect-eq
    !>  ~[[%selection ctes=~ [[simple-from-foo-join-bar-baz] ~ ~]]]
    !>  (parse:parse(default-database 'db1') "FROM foo join bar on 1 = 1 left join baz on 1 = 1 SELECT TOP 10 *")
::
::  from foo (aliased) join bar (aliased) left join baz (aliased)
++  test-from-join-09
  %+  expect-eq
    !>  ~[[%selection ctes=~ [[aliased-from-foo-join-bar-baz] ~ ~]]]
    !>  (parse:parse(default-database 'db1') "FROM foo f1 join bar as B1 on 1 = 1 left join baz b2 on 1 = 1 SELECT TOP 10 *")
::
::  from pass-thru row (un-aliased)
:::: to do: uncomment and fix when inserted table-set enabled
::++  test-from-join-10
::  %+  expect-eq
::    !>  ~[[%selection ctes=~ [[simple-from-foo-row] ~ ~]]]
::    !>  (parse:parse(default-database 'db1') "FROM (col1, col2, col3) SELECT TOP 10 *")
::::
::::  from pass-thru row (aliased)
::++  test-from-join-11
::  %+  expect-eq
::    !>  ~[[%selection ctes=~ [[aliased-from-foo-row] ~ ~]]]
::    !>  (parse:parse(default-database 'db1') "FROM (col1, col2, col3) F1 SELECT TOP 10 *")
::::
::::  from pass-thru row (aliased as)
::++  test-from-join-12
::  %+  expect-eq
::    !>  ~[[%selection ctes=~ [[aliased-from-foo-row] ~ ~]]]
::    !>  (parse:parse(default-database 'db1') "FROM (col1, col2, col3) as F1 SELECT TOP 10 *")
::::  from foo (un-aliased) join pass-thru (un-aliased)
::++  test-from-join-13
::  %+  expect-eq
::    !>  ~[[%selection ctes=~ [[simple-from-foo-join-bar-row] ~ ~]]]
::    !>  (parse:parse(default-database 'db1') "FROM foo join (col1, col2, col3) on 1 = 1 SELECT TOP 10 *")
::::
::::  from foo (un-aliased) join pass-thru (aliased)
::++  test-from-join-14
::  %+  expect-eq
::    !>  ~[[%selection ctes=~ [[simple-from-foo-join-bar-row-aliased] ~ ~]]]
::    !>  (parse:parse(default-database 'db1') "FROM foo join (col1, col2, col3) b1 on 1 = 1 SELECT TOP 10 *")
::::
::::  from foo (un-aliased) join pass-thru (aliased as)
::++  test-from-join-15
::  %+  expect-eq
::    !>  ~[[%selection ctes=~ [[simple-from-foo-join-bar-row-aliased] ~ ~]]]
::    !>  (parse:parse(default-database 'db1') "FROM foo join (col1,col2,col3)  as  b1 on 1 = 1 SELECT TOP 10 *")
::::
::::  from foo (aliased lower case) join pass-thru (aliased as)
::++  test-from-join-16
::  %+  expect-eq
::    !>  ~[[%selection ctes=~ [[aliased-from-foo-join-bar-row-aliased] ~ ~]]]
::    !>  (parse:parse(default-database 'db1') "FROM foo f1 join (col1,col2,col3) b1 on 1 = 1 SELECT TOP 10 *")
::::
::::  from pass-thru (un-aliased) join bar (un-aliased) left join pass-thru (un-aliased)
::++  test-from-join-17
::  %+  expect-eq
::    !>  ~[[%selection ctes=~ [[simple-from-foo-join-bar-row-baz] ~ ~]]]
::    !>  (parse:parse(default-database 'db1') "FROM (col1,col2,col3) join bar on 1 = 1 left join (col1,col2,col3) on 1 = 1 SELECT TOP 10 *")
::::
::::  from pass-thru single column (aliased) join bar (aliased) left join pass-thru (aliased)
::++  test-from-join-18
::  %+  expect-eq
::    !>  ~[[%selection ctes=~ [[aliased-from-foo-join-bar-row-baz] ~ ~]]]
::    !>  (parse:parse(default-database 'db1') "FROM (col1) f1 join bar as B1 on 1 = 1 left join ( col1,col2,col3 ) b2 on 1 = 1 SELECT TOP 10 *")


::
::  from foo as (aliased) cross join bar (aliased)
++  test-from-join-19
  %+  expect-eq
  =/  expected
    [%selection ctes=~ [[%query from=[~ [%from object=foo-alias-y as-of=~ joins=~[[%joined-object join=%cross-join as-of=~ object=bar-alias-x predicate=~]]]] scalars=~ predicate=~ group-by=~ having=~ selection=select-all-columns order-by=~] ~ ~]]
      !>  ~[expected]
      !>  (parse:parse(default-database 'db1') "FROM foo as y cross join bar x SELECT *")
::
::  from foo (aliased) cross join bar as (aliased)
++  test-from-join-20
  %+  expect-eq
  =/  expected
    [%selection ctes=~ [[%query from=[~ [%from object=foo-alias-y as-of=~ joins=~[[%joined-object join=%cross-join as-of=~ object=bar-alias-x predicate=~]]]] scalars=~ predicate=~ group-by=~ having=~ selection=select-all-columns order-by=~] ~ ~]]
      !>  ~[expected]
      !>  (parse:parse(default-database 'db1') "FROM foo y cross join bar as x SELECT *")
::
::  from foo cross join bar
++  test-from-join-21
  %+  expect-eq
  =/  expected
    [%selection ctes=~ [[%query from=[~ [%from object=foo-unaliased as-of=~ joins=~[[%joined-object join=%cross-join as-of=~ object=bar-unaliased predicate=~]]]] scalars=~ predicate=~ group-by=~ having=~ selection=select-all-columns order-by=~] ~ ~]]
      !>  ~[expected]
      !>  (parse:parse(default-database 'db1') "FROM foo cross join bar SELECT *")
::
::  from pass-thru as (aliased) cross join bar (aliased)
:::: to do: uncomment and fix when inserted table-set enabled
::++  test-from-join-22
::  %+  expect-eq
::  =/  expected
::    [%selection ctes=~ [[%query from=[~ [%from object=passthru-row-y as-of=~ joins=~[[%joined-object join=%cross-join as-of=~ object=bar-alias-x predicate=~]]]] scalars=~ predicate=~ group-by=~ having=~ selection=select-all-columns order-by=~] ~ ~]]
::      !>  ~[expected]
::      !>  (parse:parse(default-database 'db1') "FROM (col1, col2, col3) as y cross join bar x SELECT *")
::
::  from pass-thru (aliased) cross join bar as (aliased)
::++  test-from-join-23
::  %+  expect-eq
::  =/  expected
::    [%selection ctes=~ [[%query from=[~ [%from object=passthru-row-y as-of=~ joins=~[[%joined-object join=%cross-join as-of=~ object=bar-alias-x predicate=~]]]] scalars=~ predicate=~ group-by=~ having=~ selection=select-all-columns order-by=~] ~ ~]]
::      !>  ~[expected]
::      !>  (parse:parse(default-database 'db1') "FROM (col1,col2,col3) y cross join bar as x SELECT *")
::::
::::  from foo as (aliased) cross join pass-thru  (aliased)
::++  test-from-join-24
::  %+  expect-eq
::  =/  expected
::    [%selection ctes=~ [[%query from=[~ [%from object=foo-alias-y as-of=~ joins=~[[%joined-object join=%cross-join as-of=~ object=passthru-row-x predicate=~]]]] scalars=~ predicate=~ group-by=~ having=~ selection=select-all-columns order-by=~] ~ ~]]
::      !>  ~[expected]
::      !>  (parse:parse(default-database 'db1') "FROM foo as y cross join (col1,col2,col3) x SELECT *")
::::
::::  from foo (aliased) cross join pass-thru  as (aliased)
::++  test-from-join-25
::  %+  expect-eq
::  =/  expected
::    [%selection ctes=~ [[%query from=[~ [%from object=foo-alias-y as-of=~ joins=~[[%joined-object join=%cross-join as-of=~ object=passthru-row-x predicate=~]]]] scalars=~ predicate=~ group-by=~ having=~ selection=select-all-columns order-by=~] ~ ~]]
::      !>  ~[expected]
::      !>  (parse:parse(default-database 'db1') "FROM foo y cross join (col1,col2,col3) as x SELECT *")
::::
::::  from pass-thru cross join pass-thru
::++  test-from-join-26
::  %+  expect-eq
::  =/  expected
::    [%selection ctes=~ [[%query from=[~ [%from object=passthru-unaliased as-of=~ joins=~[[%joined-object join=%cross-join as-of=~ object=passthru-unaliased predicate=~]]]] scalars=~ predicate=~ group-by=~ having=~ selection=select-all-columns order-by=~] ~ ~]]
::      !>  ~[expected]
::      !>  (parse:parse(default-database 'db1') "FROM (col1,col2,col3) cross join (col1,col2,col3) SELECT *")
::::
::::  from foo (aliased) cross join pass-thru
::++  test-from-join-27
::  %+  expect-eq
::  =/  expected
::    [%selection ctes=~ [[%query from=[~ [%from object=foo-alias-y as-of=~ joins=~[[%joined-object join=%cross-join as-of=~ object=passthru-unaliased predicate=~]]]] scalars=~ predicate=~ group-by=~ having=~ selection=select-all-columns order-by=~] ~ ~]]
::      !>  ~[expected]
::      !>  (parse:parse(default-database 'db1') "FROM foo y cross join (col1,col2,col3) SELECT *")

::
::  (natural join) from foo as (unaliased) join bar (unaliased)
++  test-from-join-28
  %+  expect-eq
  =/  expected
    [%selection ctes=~ [[%query from=[~ [%from object=foo-unaliased as-of=~ joins=~[[%joined-object join=%join as-of=~ object=bar-unaliased predicate=~]]]] scalars=~ predicate=~ group-by=~ having=~ selection=select-all-columns order-by=~] ~ ~]]
      !>  ~[expected]
      !>  (parse:parse(default-database 'db1') "FROM foo join bar SELECT *")
::
::  (natural join) from foo as (aliased) join bar (aliased)
++  test-from-join-29
  %+  expect-eq
  =/  expected
    [%selection ctes=~ [[%query from=[~ [%from object=foo-alias-y as-of=~ joins=~[[%joined-object join=%join as-of=~ object=bar-alias-x predicate=~]]]] scalars=~ predicate=~ group-by=~ having=~ selection=select-all-columns order-by=~] ~ ~]]
      !>  ~[expected]
      !>  (parse:parse(default-database 'db1') "FROM foo as y join bar x SELECT *")
--
