/-  *ast
/+  parse,  *test
::
::
|%
::  re-used components
::
::  PREDICATE
::
++  one-eq-1
  [%eq [[value-type=%ud value=1] ~ ~] [[value-type=%ud value=1] ~ ~]]
::
::  SELECT
::
++  select-top-10-all   [%select top=[~ 10] bottom=~ columns=~[[%all %all]]]
++  select-all-columns  [%select top=~ bottom=~ columns=~[[%all %all]]]
::
::  TABLE SET
::
++  foo-table
  :-  %table-set
      :*  %qualified-object
          ship=~
          database='db1'
          namespace='dbo'
          name='foo'
          alias=~
          ==
++  foo-table-ns1
  :-  %table-set
      :*  %qualified-object
          ship=~
          database='db1'
          namespace='ns1'
          name='foo'
          alias=~
          ==
++  foo-table-db2
  :-  %table-set
      :*  %qualified-object
          ship=~
          database='db2'
          namespace='dbo'
          name='foo'
          alias=~
          ==
++  foo-table-db2-ns1
  :-  %table-set
      :*  %qualified-object
          ship=~
          database='db2'
          namespace='ns1'
          name='foo'
          alias=~
          ==
++  foo-table-nec-db2
  :-  %table-set
      :*  %qualified-object
          ship=[~ ~nec]
          database='db2'
          namespace='dbo'
          name='foo'
          alias=~
          ==
++  foo-table-nec-db2-ns1
  :-  %table-set
      :*  %qualified-object
          ship=[~ ~nec]
          database='db2'
          namespace='ns1'
          name='foo'
          alias=~
          ==
++  foo-table-f1
  :-  %table-set
      :*  %qualified-object
          ship=~
          database='db1'
          namespace='dbo'
          name='foo'
          alias=[~ 'F1']
          ==
++  foo-table-f1-ns1
  :-  %table-set
      :*  %qualified-object
          ship=~
          database='db1'
          namespace='ns1'
          name='foo'
          alias=[~ 'F1']
          ==
++  foo-table-f1-db2
  :-  %table-set
      :*  %qualified-object
          ship=~
          database='db2'
          namespace='dbo'
          name='foo'
          alias=[~ 'F1']
          ==
++  foo-table-f1-db2-ns1
  :-  %table-set
      :*  %qualified-object
          ship=~
          database='db2'
          namespace='ns1'
          name='foo'
          alias=[~ 'F1']
          ==
++  foo-table-f1-nec-db2
  :-  %table-set
      :*  %qualified-object
          ship=[~ ~nec]
          database='db2'
          namespace='dbo'
          name='foo'
          alias=[~ 'F1']
          ==
++  foo-table-f1-nec-db2-ns1
  :-  %table-set
      :*  %qualified-object
          ship=[~ ~nec]
          database='db2'
          namespace='ns1'
          name='foo'
          alias=[~ 'F1']
          ==
++  foo-table-f1-low
  :-  %table-set
      :*  %qualified-object
          ship=~
          database='db1'
          namespace='dbo'
          name='foo'
          alias=[~ 'f1']
          ==
++  bar-unaliased
  :-  %table-set
      :*  %qualified-object
          ship=~
          database='db1'
          namespace='dbo'
          name='bar'
          alias=~
          ==
++  bar-unaliased-ns1
  :-  %table-set
      :*  %qualified-object
          ship=~
          database='db1'
          namespace='ns1'
          name='bar'
          alias=~
          ==
++  bar-unaliased-db2
  :-  %table-set
      :*  %qualified-object
          ship=~
          database='db2'
          namespace='dbo'
          name='bar'
          alias=~
          ==
++  bar-unaliased-db2-ns1
  :-  %table-set
      :*  %qualified-object
          ship=~
          database='db2'
          namespace='ns1'
          name='bar'
          alias=~
          ==
++  bar-unaliased-nec-db2
  :-  %table-set
      :*  %qualified-object
          ship=[~ ~nec]
          database='db2'
          namespace='dbo'
          name='bar'
          alias=~
          ==
++  bar-unaliased-nec-db2-ns1
  :-  %table-set
      :*  %qualified-object
          ship=[~ ~nec]
          database='db2'
          namespace='ns1'
          name='bar'
          alias=~
          ==
++  foo-alias-y
  :-  %table-set
      :*  %qualified-object
          ship=~
          database='db1'
          namespace='dbo'
          name='foo'
          alias=[~ 'y']
          ==
++  bar-alias-x
  :-  %table-set
      :*  %qualified-object
          ship=~
          database='db1'
          namespace='dbo'
          name='bar'
          alias=[~ 'x']
          ==
++  foo-aliased
  :-  %table-set
      :*  %qualified-object
          ship=~
          database='db1'
          namespace='dbo'
          name='foo'
          alias=[~ 'F1']
          ==
++  foo-aliased-ns1
  :-  %table-set
      :*  %qualified-object
          ship=~
          database='db1'
          namespace='ns1'
          name='foo'
          alias=[~ 'F1']
          ==
++  foo-aliased-db2
  :-  %table-set
      :*  %qualified-object
          ship=~
          database='db2'
          namespace='dbo'
          name='foo'
          alias=[~ 'F1']
          ==
++  foo-aliased-db2-ns1
  :-  %table-set
      :*  %qualified-object
          ship=~
          database='db2'
          namespace='ns1'
          name='foo'
          alias=[~ 'F1']
          ==
++  foo-aliased-nec-db2
  :-  %table-set
      :*  %qualified-object
          ship=[~ ~nec]
          database='db2'
          namespace='dbo'
          name='foo'
          alias=[~ 'F1']
          ==
++  foo-aliased-nec-db2-ns1
  :-  %table-set
      :*  %qualified-object
          ship=[~ ~nec]
          database='db2'
          namespace='ns1'
          name='foo'
          alias=[~ 'F1']
          ==
++  bar-aliased
  :-  %table-set
      :*  %qualified-object
          ship=~
          database='db1'
          namespace='dbo'
          name='bar'
          alias=[~ 'B1']
          ==
++  bar-aliased-ns1
  :-  %table-set
      :*  %qualified-object
          ship=~
          database='db1'
          namespace='ns1'
          name='bar'
          alias=[~ 'B1']
          ==
++  bar-aliased-db2
  :-  %table-set
      :*  %qualified-object
          ship=~
          database='db2'
          namespace='dbo'
          name='bar'
          alias=[~ 'B1']
          ==
++  bar-aliased-db2-ns1
  :-  %table-set
      :*  %qualified-object
          ship=~
          database='db2'
          namespace='ns1'
          name='bar'
          alias=[~ 'B1']
          ==
++  bar-aliased-nec-db2
  :-  %table-set
      :*  %qualified-object
          ship=[~ ~nec]
          database='db2'
          namespace='dbo'
          name='bar'
          alias=[~ 'B1']
          ==
++  bar-aliased-nec-db2-ns1
  :-  %table-set
      :*  %qualified-object
          ship=[~ ~nec]
          database='db2'
          namespace='ns1'
          name='bar'
          alias=[~ 'B1']
          ==
++  passthru-row-y
  [%table-set object=[%query-row alias=[~ 'y'] ~['col1' 'col2' 'col3']]]
++  passthru-row-x
  [%table-set object=[%query-row alias=[~ 'x'] ~['col1' 'col2' 'col3']]]
++  passthru-unaliased
  [%table-set object=[%query-row alias=~ ~['col1' 'col2' 'col3']]]
::
::  QUERY
::
++  simple-from-foo
  :*  %query
      [~ [%from object=foo-table as-of=~ joins=~]]
      scalars=~
      ~
      group-by=~
      having=~
      [%select top=[~ 10] bottom=~ columns=~[[%all %all]]]
      order-by=~
      ==
++  simple-from-foo-ns1
  :*  %query
      [~ [%from object=foo-table-ns1 as-of=~ joins=~]]
      scalars=~
      ~
      group-by=~
      having=~
      [%select top=[~ 10] bottom=~ columns=~[[%all %all]]]
      order-by=~
      ==
++  simple-from-foo-db2
  :*  %query
      [~ [%from object=foo-table-db2 as-of=~ joins=~]]
      scalars=~
      ~
      group-by=~
      having=~
      [%select top=[~ 10] bottom=~ columns=~[[%all %all]]]
      order-by=~
      ==
++  simple-from-foo-db2-ns1
  :*  %query
      [~ [%from object=foo-table-db2-ns1 as-of=~ joins=~]]
      scalars=~
      ~
      group-by=~
      having=~
      [%select top=[~ 10] bottom=~ columns=~[[%all %all]]]
      order-by=~
      ==
++  simple-from-foo-nec-db2
  :*  %query
      [~ [%from object=foo-table-nec-db2 as-of=~ joins=~]]
      scalars=~
      ~
      group-by=~
      having=~
      [%select top=[~ 10] bottom=~ columns=~[[%all %all]]]
      order-by=~
      ==
++  simple-from-foo-nec-db2-ns1
  :*  %query
      [~ [%from object=foo-table-nec-db2-ns1 as-of=~ joins=~]]
      scalars=~
      ~
      group-by=~
      having=~
      [%select top=[~ 10] bottom=~ columns=~[[%all %all]]]
      order-by=~
      ==
++  aliased-from-foo
  :*  %query
      [~ [%from object=foo-table-f1 as-of=~ joins=~]]
      scalars=~
      ~
      group-by=~
      having=~
      [%select top=[~ 10] bottom=~ columns=~[[%all %all]]]
      order-by=~
      ==
++  aliased-from-foo-ns1
  :*  %query
      [~ [%from object=foo-table-f1-ns1 as-of=~ joins=~]]
      scalars=~
      ~
      group-by=~
      having=~
      [%select top=[~ 10] bottom=[~ 9] columns=~[[%all %all]]]
      order-by=~
      ==
++  aliased-from-foo-db2
  :*  %query
      [~ [%from object=foo-table-f1-db2 as-of=~ joins=~]]
      scalars=~
      ~
      group-by=~
      having=~
      [%select top=[~ 10] bottom=~ columns=~[[%all %all]]]
      order-by=~
      ==
++  aliased-from-foo-db2-ns1
  :*  %query
      [~ [%from object=foo-table-f1-db2-ns1 as-of=~ joins=~]]
      scalars=~
      ~
      group-by=~
      having=~
      [%select top=[~ 10] bottom=~ columns=~[[%all %all]]]
      order-by=~
      ==
++  aliased-from-foo-nec-db2
  :*  %query
      [~ [%from object=foo-table-f1-nec-db2 as-of=~ joins=~]]
      scalars=~
      ~
      group-by=~
      having=~
      [%select top=[~ 10] bottom=~ columns=~[[%all %all]]]
      order-by=~
      ==
++  aliased-from-foo-nec-db2-ns1
  :*  %query
      [~ [%from object=foo-table-f1-nec-db2-ns1 as-of=~ joins=~]]
      scalars=~
      ~
      group-by=~
      having=~
      [%select top=[~ 10] bottom=~ columns=~[[%all %all]]]
      order-by=~
      ==
++  simple-from-foo-join-bar
  :*  %query
      [~ [%from object=foo-table as-of=~ joins=join-bar]]
      scalars=~
      ~
      group-by=~
      having=~
      [%select top=[~ 10] bottom=~ columns=~[[%all %all]]]
      order-by=~
      ==
++  simple-from-foo-join-bar-ns1
  :*  %query
      [~ [%from foo-table-ns1 as-of=~ joins=join-bar-ns1]]
      scalars=~
      ~
      group-by=~
      having=~
      [%select top=[~ 10] bottom=~ columns=~[[%all %all]]]
      order-by=~
      ==
++  simple-from-foo-join-bar-db2
  :*  %query
      [~ [%from object=foo-table-db2 as-of=~ joins=join-bar-db2]]
      scalars=~
      ~
      group-by=~
      having=~
      [%select top=[~ 10] bottom=~ columns=~[[%all %all]]]
      order-by=~
      ==
++  simple-from-foo-join-bar-db2-ns1
  :*  %query
      [~ [%from object=foo-table-db2-ns1 as-of=~ joins=join-bar-db2-ns1]]
      scalars=~
      ~
      group-by=~
      having=~
      [%select top=[~ 10] bottom=~ columns=~[[%all %all]]]
      order-by=~
      ==
++  simple-from-foo-join-bar-nec-db2
  :*  %query
      [~ [%from object=foo-table-nec-db2 as-of=~ joins=join-bar-nec-db2]]
      scalars=~
      ~
      group-by=~
      having=~
      [%select top=[~ 10] bottom=~ columns=~[[%all %all]]]
      order-by=~
      ==
++  simple-from-foo-join-bar-nec-db2-ns1
  :*  %query
      :-  ~
      [%from object=foo-table-nec-db2-ns1 as-of=~ joins=join-bar-nec-db2-ns1]
      scalars=~
      ~
      group-by=~
      having=~
      [%select top=[~ 10] bottom=~ columns=~[[%all %all]]]
      order-by=~
      ==
++  simple-from-foo-join-bar-aliased
  :*  %query
      [~ [%from object=foo-table as-of=~ joins=join-bar-aliased]]
      scalars=~
      ~
      group-by=~
      having=~
      [%select top=[~ 10] bottom=~ columns=~[[%all %all]]]
      order-by=~
      ==
++  simple-from-foo-join-bar-aliased-ns1
  :*  %query
      [~ [%from object=foo-table-ns1 as-of=~ joins=join-bar-aliased-ns1]]
      scalars=~
      ~
      group-by=~
      having=~
      [%select top=[~ 10] bottom=~ columns=~[[%all %all]]]
      order-by=~
      ==
++  simple-from-foo-join-bar-aliased-db2
  :*  %query
      [~ [%from object=foo-table-db2 as-of=~ joins=join-bar-aliased-db2]]
      scalars=~
      ~
      group-by=~
      having=~
      [%select top=[~ 10] bottom=~ columns=~[[%all %all]]]
      order-by=~
      ==
++  simple-from-foo-join-bar-aliased-db2-ns1
  :*  %query
      :-  ~
          :^  %from
              object=foo-table-db2-ns1
              as-of=~
              joins=join-bar-aliased-db2-ns1
      scalars=~
      ~
      group-by=~
      having=~
      [%select top=[~ 10] bottom=~ columns=~[[%all %all]]]
      order-by=~
      ==
++  simple-from-foo-join-bar-aliased-nec-db2
  :*  %query
      :-  ~
          :^  %from
              object=foo-table-nec-db2
              as-of=~
              joins=join-bar-aliased-nec-db2
      scalars=~
      ~
      group-by=~
      having=~
      [%select top=[~ 10] bottom=~ columns=~[[%all %all]]]
      order-by=~
      ==
++  simple-from-foo-join-bar-aliased-nec-db2-ns1
  :*  %query
      :-  ~
          :^  %from
              object=foo-table-nec-db2-ns1
              as-of=~
              joins=join-bar-aliased-nec-db2-ns1
      scalars=~
      ~
      group-by=~
      having=~
      [%select top=[~ 10] bottom=~ columns=~[[%all %all]]]
      order-by=~
      ==
::
::  JOINED OBJECT
::
++  join-bar
  :~  :*  %joined-object
          join=%join
          object=bar-unaliased
          as-of=~
          predicate=`one-eq-1
          ==
      ==
++  join-bar-ns1
  :~  :*  %joined-object
          join=%join
          object=bar-unaliased-ns1
          as-of=~
          predicate=`one-eq-1
          ==
      ==
++  join-bar-db2
  :~  :*  %joined-object
          join=%join
          object=bar-unaliased-db2
          as-of=~
          predicate=`one-eq-1
          ==
      ==
++  join-bar-db2-ns1
  :~  :*  %joined-object
          join=%join
          object=bar-unaliased-db2-ns1
          as-of=~
          predicate=`one-eq-1
          ==
      ==
++  join-bar-nec-db2
  :~  :*  %joined-object
          join=%join
          object=bar-unaliased-nec-db2
          as-of=~
          predicate=`one-eq-1
          ==
      ==
++  join-bar-nec-db2-ns1
  :~  :*  %joined-object
          join=%join
          object=bar-unaliased-nec-db2-ns1
          as-of=~
          predicate=`one-eq-1
          ==
      ==
++  join-bar-aliased
  :~  :*  %joined-object
          join=%join
          :-  %table-set
              :*  %qualified-object
                  ship=~
                  database='db1'
                  namespace='dbo'
                  name='bar'
                  alias=[~ 'b1']
                  ==
          as-of=~
          predicate=`one-eq-1
          ==
      ==
++  join-bar-aliased-ns1
  :~  :*  %joined-object
          join=%join
          :-  %table-set
              :*  %qualified-object
                  ship=~
                  database='db1'
                  namespace='ns1'
                  name='bar'
                  alias=[~ 'b1']
                  ==
          as-of=~
          predicate=`one-eq-1
          ==
      ==
++  join-bar-aliased-db2
  :~  :*  %joined-object
          join=%join
          :-  %table-set
              :*  %qualified-object
                  ship=~
                  database='db2'
                  namespace='dbo'
                  name='bar'
                  alias=[~ 'b1']
                  ==
          as-of=~
          predicate=`one-eq-1
          ==
      ==
++  join-bar-aliased-db2-ns1
  :~  :*  %joined-object
          join=%join
          :-  %table-set
              :*  %qualified-object
                  ship=~
                  database='db2'
                  namespace='ns1'
                  name='bar'
                  alias=[~ 'b1']
                  ==
          as-of=~
          predicate=`one-eq-1
          ==
      ==
++  join-bar-aliased-nec-db2
  :~  :*  %joined-object
          join=%join
          :-  %table-set
              :*  %qualified-object
                  ship=[~ ~nec]
                  database='db2'
                  namespace='dbo'
                  name='bar'
                  alias=[~ 'b1']
                  ==
          as-of=~
          predicate=`one-eq-1
          ==
      ==
++  join-bar-aliased-nec-db2-ns1
  :~  :*  %joined-object
          join=%join
          :-  %table-set
              :*  %qualified-object
                  ship=[~ ~nec]
                  database='db2'
                  namespace='ns1'
                  name='bar'
                  alias=[~ 'b1']
                  ==
          as-of=~
          predicate=`one-eq-1
          ==
      ==
::
::  JOIN with time
::
++  join-bar-as-of
  |=  time=as-of
  :~  :*  %joined-object
          %join
          bar-unaliased
          [~ time]  ::as-of
          `one-eq-1
          ==
      ==
++  join-bar-as-of-ns1
  |=  time=as-of
  :~  :*  %joined-object
          %join
          bar-unaliased-ns1
          [~ time]  ::as-of
          `one-eq-1
          ==
      ==
++  join-bar-as-of-db2
  |=  time=as-of
  :~  :*  %joined-object
          %join
          bar-unaliased-db2
          [~ time]  ::as-of
          `one-eq-1
          ==
      ==
++  join-bar-as-of-db2-ns1
  |=  time=as-of
  :~  :*  %joined-object
          %join
          bar-unaliased-db2-ns1
          [~ time]  ::as-of
          `one-eq-1
          ==
      ==
++  join-bar-as-of-nec-db2
  |=  time=as-of
  :~  :*  %joined-object
          %join
          bar-unaliased-nec-db2
          [~ time]  ::as-of
          `one-eq-1
          ==
      ==
++  join-bar-as-of-nec-db2-ns1
  |=  time=as-of
  :~  :*  %joined-object
          %join
          bar-unaliased-nec-db2-ns1
          [~ time]  ::as-of
          `one-eq-1
          ==
      ==
++  natural-join-bar
  |=  time=as-of
  :~  :*  %joined-object
          %join
          bar-unaliased
          [~ time]  ::as-of
          ~
          ==
      ==
++  join-bar-aliased-as-of
  |=  time=as-of
  :~  :*  %joined-object
          %join
          bar-aliased 
          [~ time]  ::as-of
          `one-eq-1
          ==
      ==
++  join-bar-aliased-as-of-ns1
  |=  time=as-of
  :~  :*  %joined-object
          %join
          bar-aliased-ns1
          [~ time]  ::as-of
          `one-eq-1
          ==
      ==
++  join-bar-aliased-as-of-db2
  |=  time=as-of
  :~  :*  %joined-object
          %join
          bar-aliased-db2
          [~ time]  ::as-of
          `one-eq-1
          ==
      ==
++  join-bar-aliased-as-of-db2-ns1
  |=  time=as-of
  :~  :*  %joined-object
          %join
          bar-aliased-db2-ns1
          [~ time]  ::as-of
          `one-eq-1
          ==
      ==
++  join-bar-aliased-as-of-nec-db2
  |=  time=as-of
  :~  :*  %joined-object
          %join
          bar-aliased-nec-db2
          [~ time]  ::as-of
          `one-eq-1
          ==
      ==
++  join-bar-aliased-as-of-nec-db2-ns1
  |=  time=as-of
  :~  :*  %joined-object
          %join
          bar-aliased-nec-db2-ns1
          [~ time]  ::as-of
          `one-eq-1
          ==
      ==

++  natural-join-bar-aliased
  |=  time=as-of
  :~  :*  %joined-object
          %join
          bar-aliased
          [~ time]  ::as-of
          ~
          ==
      ==
++  join-bar-baz
  |=  time=as-of
  :~  :*  %joined-object
          %left-join
          bar-unaliased
          [~ time]  ::as-of
          `one-eq-1
          ==
      :*  %joined-object
          %join
          :-  %table-set
              :*  %qualified-object
                  ~      ::ship
                  'db1'  ::database
                  'dbo'  ::namespace
                  'baz'  ::name
                  ~      ::alias
                  ==
          [~ time]  ::as-of
          `one-eq-1
          ==
      ==
++  join-bar-baz-ns1
  |=  time=as-of
  :~  :*  %joined-object
          %left-join
          bar-unaliased-ns1
          [~ time]  ::as-of
          `one-eq-1
          ==
      :*  %joined-object
          %join
          :-  %table-set
              :*  %qualified-object
                  ~      ::ship
                  'db1'  ::database
                  'ns1'  ::namespace
                  'baz'  ::name
                  ~      ::alias
                  ==
          [~ time]  ::as-of
          `one-eq-1
          ==
      ==
++  join-bar-baz-db2
  |=  time=as-of
  :~  :*  %joined-object
          %left-join
          bar-unaliased-db2
          [~ time]  ::as-of
          `one-eq-1
          ==
      :*  %joined-object
          %join
          :-  %table-set
              :*  %qualified-object
                  ~      ::ship
                  'db2'  ::database
                  'dbo'  ::namespace
                  'baz'  ::name
                  ~      ::alias
                  ==
          [~ time]  ::as-of
          `one-eq-1
          ==
      ==
++  join-bar-baz-db2-ns1
  |=  time=as-of
  :~  :*  %joined-object
          %left-join
          bar-unaliased-db2-ns1
          [~ time]  ::as-of
          `one-eq-1
          ==
      :*  %joined-object
          %join
          :-  %table-set
              :*  %qualified-object
                  ~      ::ship
                  'db2'  ::database
                  'ns1'  ::namespace
                  'baz'  ::name
                  ~      ::alias
                  ==
          [~ time]  ::as-of
          `one-eq-1
          ==
      ==
++  join-bar-baz-nec-db2
  |=  time=as-of
  :~  :*  %joined-object
          %left-join
          bar-unaliased-nec-db2
          [~ time]  ::as-of
          `one-eq-1
          ==
      :*  %joined-object
          %join
          :-  %table-set
              :*  %qualified-object
                  [~ ~nec]  ::ship
                  'db2'     ::database
                  'dbo'     ::namespace
                  'baz'     ::name
                  ~         ::alias
                  ==
          [~ time]  ::as-of
          `one-eq-1
          ==
      ==
++  join-bar-baz-nec-db2-ns1
  |=  time=as-of
  :~  :*  %joined-object
          %left-join
          bar-unaliased-nec-db2-ns1
          [~ time]  ::as-of
          `one-eq-1
          ==
      :*  %joined-object
          %join
          :-  %table-set
              :*  %qualified-object
                  [~ ~nec]  ::ship
                  'db2'     ::database
                  'ns1'     ::namespace
                  'baz'     ::name
                  ~         ::alias
                  ==
          [~ time]  ::as-of
          `one-eq-1
          ==
      ==
++  aliased-join-bar-baz
  |=  time=as-of
  :~  :*  %joined-object
          %join
          bar-aliased
          [~ time]         ::as-of
          `one-eq-1
          ==
      :*  %joined-object
          %left-join
          :-  %table-set
              :*  %qualified-object
                  ~      ::ship
                  'db1'  ::database
                  'dbo'  ::namespace
                  'baz'  ::name
                  [~ 'b2']      ::alias
                  ==
          [~ time]         ::as-of
          `one-eq-1
          ==
      ==
++  aliased-join-bar-baz-ns1
  |=  time=as-of
  :~  :*  %joined-object
          %join
          bar-aliased-ns1
          [~ time]         ::as-of
          `one-eq-1
          ==
      :*  %joined-object
          %left-join
          :-  %table-set
              :*  %qualified-object
                  ~      ::ship
                  'db1'  ::database
                  'ns1'  ::namespace
                  'baz'  ::name
                  [~ 'b2']      ::alias
                  ==
          [~ time]         ::as-of
          `one-eq-1
          ==
      ==
++  aliased-join-bar-baz-db2
  |=  time=as-of
  :~  :*  %joined-object
          %join
          bar-aliased-db2
          [~ time]         ::as-of
          `one-eq-1
          ==
      :*  %joined-object
          %left-join
          :-  %table-set
              :*  %qualified-object
                  ~      ::ship
                  'db2'  ::database
                  'dbo'  ::namespace
                  'baz'  ::name
                  [~ 'b2']      ::alias
                  ==
          [~ time]         ::as-of
          `one-eq-1
          ==
      ==
++  aliased-join-bar-baz-db2-ns1
  |=  time=as-of
  :~  :*  %joined-object
          %join
          bar-aliased-db2-ns1
          [~ time]         ::as-of
          `one-eq-1
          ==
      :*  %joined-object
          %left-join
          :-  %table-set
              :*  %qualified-object
                  ~      ::ship
                  'db2'  ::database
                  'ns1'  ::namespace
                  'baz'  ::name
                  [~ 'b2']      ::alias
                  ==
          [~ time]         ::as-of
          `one-eq-1
          ==
      ==
++  aliased-join-bar-baz-nec-db2
  |=  time=as-of
  :~  :*  %joined-object
          %join
          bar-aliased-nec-db2
          [~ time]         ::as-of
          `one-eq-1
          ==
      :*  %joined-object
          %left-join
          :-  %table-set
              :*  %qualified-object
                  [~ ~nec]  ::ship
                  'db2'     ::database
                  'dbo'     ::namespace
                  'baz'     ::name
                  [~ 'b2']  ::alias
                  ==
          [~ time]         ::as-of
          `one-eq-1
          ==
      ==
++  aliased-join-bar-baz-nec-db2-ns1
  |=  time=as-of
  :~  :*  %joined-object
          %join
          bar-aliased-nec-db2-ns1
          [~ time]         ::as-of
          `one-eq-1
          ==
      :*  %joined-object
          %left-join
          :-  %table-set
              :*  %qualified-object
                  [~ ~nec]  ::ship
                  'db2'     ::database
                  'ns1'     ::namespace
                  'baz'     ::name
                  [~ 'b2']  ::alias
                  ==
          [~ time]         ::as-of
          `one-eq-1
          ==
      ==
++  cross-join-bar
  |=  time=as-of
  :~  :*  %joined-object
          %cross-join
          bar-unaliased
          [~ time]  ::as-of
          ~  ::predicate
          ==
      ==
++  cross-join-bar-aliased
  |=  time=as-of
  :~  :*  %joined-object
          %cross-join
          bar-aliased
          [~ time]  ::as-of
          ~  ::predicate
          ==
      ==
++  cross-join-bar-aliased-ns1
  |=  time=as-of
  :~  :*  %joined-object
          %cross-join
          bar-aliased-ns1
          [~ time]  ::as-of
          ~  ::predicate
          ==
      ==
++  cross-join-bar-aliased-db2
  |=  time=as-of
  :~  :*  %joined-object
          %cross-join
          bar-aliased-db2
          [~ time]  ::as-of
          ~  ::predicate
          ==
      ==
++  cross-join-bar-aliased-db2-ns1
  |=  time=as-of
  :~  :*  %joined-object
          %cross-join
          bar-aliased-db2-ns1
          [~ time]  ::as-of
          ~  ::predicate
          ==
      ==
++  cross-join-bar-aliased-nec-db2
  |=  time=as-of
  :~  :*  %joined-object
          %cross-join
          bar-aliased-nec-db2
          [~ time]  ::as-of
          ~  ::predicate
          ==
      ==
++  cross-join-bar-aliased-nec-db2-ns1
  |=  time=as-of
  :~  :*  %joined-object
          %cross-join
          bar-aliased-nec-db2-ns1
          [~ time]  ::as-of
          ~  ::predicate
          ==
      ==
::
::  QUERY with time
::
++  simple-from
  |=  time=as-of
  :*  %query 
      [~ [%from object=foo-table as-of=[~ time] joins=~]]
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
      [~ [%from object=foo-aliased as-of=[~ time] joins=~]]
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
      [~ [%from object=foo-table as-of=[~ time] joins=(join-bar-as-of time)]]
      ~      ::scalars
      ~      ::predicate
      ~      ::group-by
      ~      ::having
      select-top-10-all
      ~      ::order-by
      ==
++  simple-from-join-bar-ns1
  |=  time=as-of
  :*  %query
      :-  ~
          :^  %from
              object=foo-table-ns1
              as-of=[~ time]
              joins=(join-bar-as-of-ns1 time)
      ~      ::scalars
      ~      ::predicate
      ~      ::group-by
      ~      ::having
      select-top-10-all
      ~      ::order-by
      ==
++  simple-from-join-bar-db2
  |=  time=as-of
  :*  %query
      :-  ~
          :^  %from
              object=foo-table-db2
              as-of=[~ time]
              joins=(join-bar-as-of-db2 time)
      ~      ::scalars
      ~      ::predicate
      ~      ::group-by
      ~      ::having
      select-top-10-all
      ~      ::order-by
      ==
++  simple-from-join-bar-db2-ns1
  |=  time=as-of
  :*  %query
      :-  ~
          :^  %from
              object=foo-table-db2-ns1
              as-of=[~ time]
              joins=(join-bar-as-of-db2-ns1 time)
      ~      ::scalars
      ~      ::predicate
      ~      ::group-by
      ~      ::having
      select-top-10-all
      ~      ::order-by
      ==
++  simple-from-join-bar-nec-db2
  |=  time=as-of
  :*  %query
      :-  ~
          :^  %from
              object=foo-table-nec-db2
              as-of=[~ time]
              joins=(join-bar-as-of-nec-db2 time)
      ~      ::scalars
      ~      ::predicate
      ~      ::group-by
      ~      ::having
      select-top-10-all
      ~      ::order-by
      ==
++  simple-from-join-bar-nec-db2-ns1
  |=  time=as-of
  :*  %query
      :-  ~
          :^  %from
              object=foo-table-nec-db2-ns1
              as-of=[~ time]
              joins=(join-bar-as-of-nec-db2-ns1 time)
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
      :-  ~
          :^  %from
              object=foo-table
              as-of=[~ time]
              joins=(join-bar-aliased-as-of time)
      ~      ::scalars
      ~      ::predicate
      ~      ::group-by
      ~      ::having
      select-top-10-all
      ~      ::order-by
      ==
++  simple-from-join-bar-aliased-ns1
  |=  time=as-of
  :*  %query
      :-  ~
          :^  %from
              object=foo-table-ns1
              as-of=[~ time]
              joins=(join-bar-aliased-as-of-ns1 time)
      ~      ::scalars
      ~      ::predicate
      ~      ::group-by
      ~      ::having
      select-top-10-all
      ~      ::order-by
      ==
++  simple-from-join-bar-aliased-db2
  |=  time=as-of
  :*  %query
      :-  ~
          :^  %from
              object=foo-table-db2
              as-of=[~ time]
              joins=(join-bar-aliased-as-of-db2 time)
      ~      ::scalars
      ~      ::predicate
      ~      ::group-by
      ~      ::having
      select-top-10-all
      ~      ::order-by
      ==
++  simple-from-join-bar-aliased-db2-ns1
  |=  time=as-of
  :*  %query
      :-  ~
          :^  %from
              object=foo-table-db2-ns1
              as-of=[~ time]
              joins=(join-bar-aliased-as-of-db2-ns1 time)
      ~      ::scalars
      ~      ::predicate
      ~      ::group-by
      ~      ::having
      select-top-10-all
      ~      ::order-by
      ==
++  simple-from-join-bar-aliased-nec-db2
  |=  time=as-of
  :*  %query
      :-  ~
          :^  %from
              object=foo-table-nec-db2
              as-of=[~ time]
              joins=(join-bar-aliased-as-of-nec-db2 time)
      ~      ::scalars
      ~      ::predicate
      ~      ::group-by
      ~      ::having
      select-top-10-all
      ~      ::order-by
      ==
++  simple-from-join-bar-aliased-nec-db2-ns1
  |=  time=as-of
  :*  %query
      :-  ~
          :^  %from
              object=foo-table-nec-db2-ns1
              as-of=[~ time]
              joins=(join-bar-aliased-as-of-nec-db2-ns1 time)
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
      :-  ~
          :^  %from
              object=foo-aliased
              as-of=[~ time]
              joins=(join-bar-aliased-as-of time)
      ~      ::scalars
      ~      ::predicate
      ~      ::group-by
      ~      ::having
      select-top-10-all
      ~      ::order-by
      ==
++  simple-from-aliased-join-bar-aliased-ns1
  |=  time=as-of
  :*  %query
      :-  ~
          :^  %from
              object=foo-aliased-ns1
              as-of=[~ time]
              joins=(join-bar-aliased-as-of-ns1 time)
      ~      ::scalars
      ~      ::predicate
      ~      ::group-by
      ~      ::having
      select-top-10-all
      ~      ::order-by
      ==
++  simple-from-aliased-join-bar-aliased-db2
  |=  time=as-of
  :*  %query
      :-  ~
          :^  %from
              object=foo-aliased-db2
              as-of=[~ time]
              joins=(join-bar-aliased-as-of-db2 time)
      ~      ::scalars
      ~      ::predicate
      ~      ::group-by
      ~      ::having
      select-top-10-all
      ~      ::order-by
      ==
++  simple-from-aliased-join-bar-aliased-db2-ns1
  |=  time=as-of
  :*  %query
      :-  ~
          :^  %from
              object=foo-aliased-db2-ns1
              as-of=[~ time]
              joins=(join-bar-aliased-as-of-db2-ns1 time)
      ~      ::scalars
      ~      ::predicate
      ~      ::group-by
      ~      ::having
      select-top-10-all
      ~      ::order-by
      ==
++  simple-from-aliased-join-bar-aliased-nec-db2
  |=  time=as-of
  :*  %query
      :-  ~
          :^  %from
              object=foo-aliased-nec-db2
              as-of=[~ time]
              joins=(join-bar-aliased-as-of-nec-db2 time)
      ~      ::scalars
      ~      ::predicate
      ~      ::group-by
      ~      ::having
      select-top-10-all
      ~      ::order-by
      ==
++  simple-from-aliased-join-bar-aliased-nec-db2-ns1
  |=  time=as-of
  :*  %query
      :-  ~
          :^  %from
              object=foo-aliased-nec-db2-ns1
              as-of=[~ time]
              joins=(join-bar-aliased-as-of-nec-db2-ns1 time)
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
      [~ [%from object=foo-table as-of=[~ time] joins=(join-bar-baz time)]]
      ~      ::scalars
      ~      ::predicate
      ~      ::group-by
      ~      ::having
      select-top-10-all
      ~      ::order-by
      ==
++  simple-from-join-bar-baz-ns1
  |=  time=as-of
  :*  %query
      :-  ~
          :^  %from
              object=foo-table-ns1
              as-of=[~ time]
              joins=(join-bar-baz-ns1 time)
      ~      ::scalars
      ~      ::predicate
      ~      ::group-by
      ~      ::having
      select-top-10-all
      ~      ::order-by
      ==
++  simple-from-join-bar-baz-db2
  |=  time=as-of
  :*  %query
      :-  ~
          :^  %from
              object=foo-table-db2
              as-of=[~ time]
              joins=(join-bar-baz-db2 time)
      ~      ::scalars
      ~      ::predicate
      ~      ::group-by
      ~      ::having
      select-top-10-all
      ~      ::order-by
      ==
++  simple-from-join-bar-baz-db2-ns1
  |=  time=as-of
  :*  %query
      :-  ~
          :^  %from
              object=foo-table-db2-ns1
              as-of=[~ time]
              joins=(join-bar-baz-db2-ns1 time)
      ~      ::scalars
      ~      ::predicate
      ~      ::group-by
      ~      ::having
      select-top-10-all
      ~      ::order-by
      ==
++  simple-from-join-bar-baz-nec-db2
  |=  time=as-of
  :*  %query
      :-  ~
          :^  %from
              object=foo-table-nec-db2
              as-of=[~ time]
              joins=(join-bar-baz-nec-db2 time)
      ~      ::scalars
      ~      ::predicate
      ~      ::group-by
      ~      ::having
      select-top-10-all
      ~      ::order-by
      ==
++  simple-from-join-bar-baz-nec-db2-ns1
  |=  time=as-of
  :*  %query
      :-  ~
          :^  %from
              object=foo-table-nec-db2-ns1
              as-of=[~ time]
              joins=(join-bar-baz-nec-db2-ns1 time)
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
      :-  ~
          :^  %from
              object=foo-aliased
              as-of=[~ time]
              joins=(aliased-join-bar-baz time)
      ~      ::scalars
      ~      ::predicate
      ~      ::group-by
      ~      ::having
      select-top-10-all
      ~      ::order-by
      ==
++  simple-from-aliased-join-bar-baz-ns1
  |=  time=as-of
  :*  %query
      :-  ~
          :^  %from
              object=foo-aliased-ns1
              as-of=[~ time]
              joins=(aliased-join-bar-baz-ns1 time)
      ~      ::scalars
      ~      ::predicate
      ~      ::group-by
      ~      ::having
      select-top-10-all
      ~      ::order-by
      ==
++  simple-from-aliased-join-bar-baz-db2
  |=  time=as-of
  :*  %query
      :-  ~
          :^  %from
              object=foo-aliased-db2
              as-of=[~ time]
              joins=(aliased-join-bar-baz-db2 time)
      ~      ::scalars
      ~      ::predicate
      ~      ::group-by
      ~      ::having
      select-top-10-all
      ~      ::order-by
      ==
++  simple-from-aliased-join-bar-baz-db2-ns1
  |=  time=as-of
  :*  %query
      :-  ~
          :^  %from
              object=foo-aliased-db2-ns1
              as-of=[~ time]
              joins=(aliased-join-bar-baz-db2-ns1 time)
      ~      ::scalars
      ~      ::predicate
      ~      ::group-by
      ~      ::having
      select-top-10-all
      ~      ::order-by
      ==
++  simple-from-aliased-join-bar-baz-nec-db2
  |=  time=as-of
  :*  %query
      :-  ~
          :^  %from
              object=foo-aliased-nec-db2
              as-of=[~ time]
              joins=(aliased-join-bar-baz-nec-db2 time)
      ~      ::scalars
      ~      ::predicate
      ~      ::group-by
      ~      ::having
      select-top-10-all
      ~      ::order-by
      ==
++  simple-from-aliased-join-bar-baz-nec-db2-ns1
  |=  time=as-of
  :*  %query
      :-  ~
          :^  %from
              object=foo-aliased-nec-db2-ns1
              as-of=[~ time]
              joins=(aliased-join-bar-baz-nec-db2-ns1 time)
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
      [~ [%from object=foo-table as-of=[~ time] joins=(cross-join-bar time)]]
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
      :-  ~
          :^  %from
              foo-aliased
              [~ time]    ::as-of
              (cross-join-bar-aliased time)
      ~      ::scalars
      ~      ::predicate
      ~      ::group-by
      ~      ::having
      selection=select-all-columns
      ~      ::order-by
      ==
++  simple-from-aliased-cross-bar-ns1
  |=  time=as-of
  :*  %query 
      :-  ~
          :^  %from
              foo-aliased-ns1
              [~ time]    ::as-of
              (cross-join-bar-aliased-ns1 time)
      ~      ::scalars
      ~      ::predicate
      ~      ::group-by
      ~      ::having
      selection=select-all-columns
      ~      ::order-by
      ==
++  simple-from-aliased-cross-bar-db2
  |=  time=as-of
  :*  %query 
      :-  ~
          :^  %from
              foo-aliased-db2
              [~ time]    ::as-of
              (cross-join-bar-aliased-db2 time)
      ~      ::scalars
      ~      ::predicate
      ~      ::group-by
      ~      ::having
      selection=select-all-columns
      ~      ::order-by
      ==
++  simple-from-aliased-cross-bar-db2-ns1
  |=  time=as-of
  :*  %query 
      :-  ~
          :^  %from
              foo-aliased-db2-ns1
              [~ time]    ::as-of
              (cross-join-bar-aliased-db2-ns1 time)
      ~      ::scalars
      ~      ::predicate
      ~      ::group-by
      ~      ::having
      selection=select-all-columns
      ~      ::order-by
      ==
++  simple-from-aliased-cross-bar-nec-db2
  |=  time=as-of
  :*  %query 
      :-  ~
          :^  %from
              foo-aliased-nec-db2
              [~ time]    ::as-of
              (cross-join-bar-aliased-nec-db2 time)
      ~      ::scalars
      ~      ::predicate
      ~      ::group-by
      ~      ::having
      selection=select-all-columns
      ~      ::order-by
      ==
++  simple-from-aliased-cross-bar-nec-db2-ns1
  |=  time=as-of
  :*  %query 
      :-  ~
          :^  %from
              foo-aliased-nec-db2-ns1
              [~ time]    ::as-of
              (cross-join-bar-aliased-nec-db2-ns1 time)
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
      [~ [%from object=foo-table as-of=[~ time] joins=(natural-join-bar time)]]
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
      :-  ~
          :^  %from
              object=foo-table
              as-of=[~ time]
              joins=(natural-join-bar-aliased time)
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
      :-  ~
          :^  %from
              object=foo-aliased
              as-of=[~ time]
              joins=(natural-join-bar-aliased time)
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
                    [%table-set [%qualified-object ~ %db1 %dbo %foo [~ 'F1']]]
                    [~ [%dr ~h5.m30.s12]]
                    :~
                      :*  %joined-object
                          %join
                          :-  %table-set
                              [%qualified-object ~ %db1 %dbo %bar [~ 'B2']]
                              
                          as-of=[~ [%da ~2000.1.1]]
                          predicate=~
                          ==
                      :*  %joined-object
                          %left-join
                          :-  %table-set
                              [%qualified-object ~ %db1 %dbo %baz [~ 'B3']]
                          as-of=[~ [%da ~2000.1.1]]
                          :-  ~
                              :+  %eq
                                  [[value-type=%ud value=1] ~ ~]
                                  [[value-type=%ud value=1] ~ ~]
                          ==
                      :*  %joined-object
                          %join
                          :-  %table-set
                              [%qualified-object ~ %db1 %dbo %bar [~ 'B4']]
                          as-of=~
                          predicate=~
                          ==
                      :*  %joined-object
                          %left-join
                          :-  %table-set
                              [%qualified-object ~ %db1 %dbo %bar ~]
                          as-of=~
                          :-  ~
                              :+  %eq
                                  [[value-type=%ud value=1] ~ ~]
                                  [[value-type=%ud value=1] ~ ~]
                          ==
                      :*  %joined-object
                          %join
                          :-  %table-set
                              [%qualified-object ~ %db1 %dbo %foo ~]
                          [~ [%as-of-offset offset=2 units=%minutes]]
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
::  EXPECTED with time
::
++  expected
  |=  [b=$-(as-of query) time=as-of]
  ~[[%selection ctes=~ [[(b time)] ~ ~]]]
::
::
:: JOIN queries
::
::  from foo (un-aliased)
++  test-join-01
  %+  expect-eq
    !>  ~[[%selection ctes=~ [[simple-from-foo] ~ ~]]]
    !>  (parse:parse(default-database 'db1') "FROM foo SELECT TOP 10 *")
::
::  from ns1.foo (un-aliased)
++  test-join-02
  %+  expect-eq
    !>  ~[[%selection ctes=~ [[simple-from-foo-ns1] ~ ~]]]
    !>  (parse:parse(default-database 'db1') "FROM ns1.foo SELECT TOP 10 *")
::
::  from db2..foo (un-aliased)
++  test-join-03
  %+  expect-eq
    !>  ~[[%selection ctes=~ [[simple-from-foo-db2] ~ ~]]]
    !>  (parse:parse(default-database 'db1') "FROM db2..foo SELECT TOP 10 *")
::
::  from db2.ns1.foo (un-aliased)
++  test-join-04
  %+  expect-eq
    !>  ~[[%selection ctes=~ [[simple-from-foo-db2-ns1] ~ ~]]]
    !>  (parse:parse(default-database 'db1') "FROM db2.ns1.foo SELECT TOP 10 *")
::
::  from ~nec.db2..foo (un-aliased)
++  test-join-05
  %+  expect-eq
    !>  ~[[%selection ctes=~ [[simple-from-foo-nec-db2] ~ ~]]]
    !>    %-  parse:parse(default-database 'db1')
              "FROM ~nec.db2..foo SELECT TOP 10 *"

::
::  from ~nec.db2.ns1.foo (un-aliased)
++  test-join-06
  %+  expect-eq
    !>  ~[[%selection ctes=~ [[simple-from-foo-nec-db2-ns1] ~ ~]]]
    !>    %-  parse:parse(default-database 'db1')
              "FROM ~nec.db2.ns1.foo SELECT TOP 10 *"
::
::  from foo (aliased)
++  test-join-07
  %+  expect-eq
    !>  ~[[%selection ctes=~ [[aliased-from-foo] ~ ~]]]
    !>  (parse:parse(default-database 'db1') "FROM foo F1 SELECT TOP 10 *")
::
::  from ns1.foo (aliased)
++  test-join-08
  %+  expect-eq
    !>  ~[[%selection ctes=~ [[aliased-from-foo-ns1] ~ ~]]]
    !>    %-  parse:parse(default-database 'db1')
              "FROM ns1.foo F1 SELECT TOP 10 bottom 9 *"
::
::  from db2..foo (aliased)
++  test-join-09
  %+  expect-eq
    !>  ~[[%selection ctes=~ [[aliased-from-foo-db2] ~ ~]]]
    !>  (parse:parse(default-database 'db1') "FROM db2..foo F1 SELECT TOP 10 *")
::
::  from db2.ns1.foo (aliased)
++  test-join-10
  %+  expect-eq
    !>  ~[[%selection ctes=~ [[aliased-from-foo-db2-ns1] ~ ~]]]
    !>    %-  parse:parse(default-database 'db1')
              "FROM db2.ns1.foo F1 SELECT TOP 10 *"
::
::  from ~nec.db2..foo (aliased)
++  test-join-11
  %+  expect-eq
    !>  ~[[%selection ctes=~ [[aliased-from-foo-nec-db2] ~ ~]]]
    !>    %-  parse:parse(default-database 'db1')
              "FROM ~nec.db2..foo F1 SELECT TOP 10 *"

::
::  from ~nec.db2.ns1.foo (aliased)
++  test-join-12
  %+  expect-eq
    !>  ~[[%selection ctes=~ [[aliased-from-foo-nec-db2-ns1] ~ ~]]]
    !>    %-  parse:parse(default-database 'db1')
              "FROM ~nec.db2.ns1.foo F1 SELECT TOP 10 *"
::
::  from foo (aliased as)
++  test-join-13
  %+  expect-eq
    !>  ~[[%selection ctes=~ [[aliased-from-foo] ~ ~]]]
    !>  (parse:parse(default-database 'db1') "FROM foo as F1 SELECT TOP 10 *")
::
::  from ns1.foo (aliased as)
++  test-join-14
  %+  expect-eq
    !>  ~[[%selection ctes=~ [[aliased-from-foo-ns1] ~ ~]]]
    !>    %-  parse:parse(default-database 'db1')
              "FROM ns1.foo as F1 SELECT TOP 10 bottom 9 *"
::
::  from db2..foo (aliased as)
++  test-join-15
  %+  expect-eq
    !>  ~[[%selection ctes=~ [[aliased-from-foo-db2] ~ ~]]]
    !>    %-  parse:parse(default-database 'db1')
              "FROM db2..foo As F1 SELECT TOP 10 *"
::
::  from db2.ns1.foo (aliased as)
++  test-join-16
  %+  expect-eq
    !>  ~[[%selection ctes=~ [[aliased-from-foo-db2-ns1] ~ ~]]]
    !>    %-  parse:parse(default-database 'db1')
              "FROM db2.ns1.foo aS F1 SELECT TOP 10 *"
::
::  from ~nec.db2..foo (aliased as)
++  test-join-17
  %+  expect-eq
    !>  ~[[%selection ctes=~ [[aliased-from-foo-nec-db2] ~ ~]]]
    !>    %-  parse:parse(default-database 'db1')
              "FROM ~nec.db2..foo AS F1 SELECT TOP 10 *"

::
::  from ~nec.db2.ns1.foo (aliased as)
++  test-join-18
  %+  expect-eq
    !>  ~[[%selection ctes=~ [[aliased-from-foo-nec-db2-ns1] ~ ~]]]
    !>    %-  parse:parse(default-database 'db1')
              "FROM ~nec.db2.ns1.foo AS F1 SELECT TOP 10 *"
::
::  from foo (un-aliased) join bar (un-aliased)
++  test-join-19
  %+  expect-eq
    !>  ~[[%selection ctes=~ [[simple-from-foo-join-bar] ~ ~]]]
    !>  %-  parse:parse(default-database 'db1')
            "FROM foo join bar on 1 = 1 SELECT TOP 10 *"
::
::  from ns1.foo (un-aliased) join ns1.bar (un-aliased)
++  test-join-20
  %+  expect-eq
    !>  ~[[%selection ctes=~ [[simple-from-foo-join-bar-ns1] ~ ~]]]
    !>  %-  parse:parse(default-database 'db1')
            "FROM ns1.foo join ns1.bar on 1 = 1 SELECT TOP 10 *"
::
::  from db2..foo (un-aliased) db2..join bar (un-aliased)
++  test-join-21
  %+  expect-eq
    !>  ~[[%selection ctes=~ [[simple-from-foo-join-bar-db2] ~ ~]]]
    !>  %-  parse:parse(default-database 'db1')
            "FROM db2..foo join db2..bar on 1 = 1 SELECT TOP 10 *"
::
::  from db2.ns1.foo (un-aliased) join db2.ns1.bar (un-aliased)
++  test-join-22
  %+  expect-eq
    !>  ~[[%selection ctes=~ [[simple-from-foo-join-bar-db2-ns1] ~ ~]]]
    !>  %-  parse:parse(default-database 'db1')
            "FROM db2.ns1.foo join db2.ns1.bar on 1 = 1 SELECT TOP 10 *"
::
::  from ~nec.db2..foo (un-aliased) join ~nec.db2..bar (un-aliased)
++  test-join-23
  %+  expect-eq
    !>  ~[[%selection ctes=~ [[simple-from-foo-join-bar-nec-db2] ~ ~]]]
    !>  %-  parse:parse(default-database 'db1')
            "FROM ~nec.db2..foo join ~nec.db2..bar on 1 = 1 SELECT TOP 10 *"
::
::  from ~nec.db2.ns1.foo (un-aliased) join ~nec.db2.ns1.bar (un-aliased)
++  test-join-24
  %+  expect-eq
    !>  ~[[%selection ctes=~ [[simple-from-foo-join-bar-nec-db2-ns1] ~ ~]]]
    !>  %-  parse:parse(default-database 'db1')
            "FROM ~nec.db2.ns1.foo join ~nec.db2.ns1.bar on 1 = 1 ".
            "SELECT TOP 10 *"

::
::  from foo (un-aliased) join bar (aliased)
++  test-join-25
  %+  expect-eq
    !>  ~[[%selection ctes=~ [[simple-from-foo-join-bar-aliased] ~ ~]]]
    !>  %-  parse:parse(default-database 'db1')
            "FROM foo join bar b1 on 1 = 1 SELECT TOP 10 *"
::
::  from ns1.foo (un-aliased) join ns1.bar (aliased)
++  test-join-26
  %+  expect-eq
    !>  ~[[%selection ctes=~ [[simple-from-foo-join-bar-aliased-ns1] ~ ~]]]
    !>  %-  parse:parse(default-database 'db1')
            "FROM ns1.foo join ns1.bar b1 on 1 = 1 SELECT TOP 10 *"
::
::  from db2..foo (un-aliased) join db2..bar (aliased)
++  test-join-27
  %+  expect-eq
    !>  ~[[%selection ctes=~ [[simple-from-foo-join-bar-aliased-db2] ~ ~]]]
    !>  %-  parse:parse(default-database 'db1')
            "FROM db2..foo join db2..bar b1 on 1 = 1 SELECT TOP 10 *"
::
::  from db2.ns1.foo (un-aliased) db2.ns1.join bar (aliased)
++  test-join-28
  %+  expect-eq
    !>  ~[[%selection ctes=~ [[simple-from-foo-join-bar-aliased-db2-ns1] ~ ~]]]
    !>  %-  parse:parse(default-database 'db1')
            "FROM db2.ns1.foo join db2.ns1.bar b1 on 1 = 1 SELECT TOP 10 *"
::
::  from ~nec.db2..foo (un-aliased) join ~nec.db2..bar (aliased)
++  test-join-29
  %+  expect-eq
    !>  ~[[%selection ctes=~ [[simple-from-foo-join-bar-aliased-nec-db2] ~ ~]]]
    !>  %-  parse:parse(default-database 'db1')
            "FROM ~nec.db2..foo join ~nec.db2..bar b1 on 1 = 1 SELECT TOP 10 *"
::
::  from ~nec.db2.ns1.foo (un-aliased) join ~nec.db2.ns1.bar (aliased)
++  test-join-30
  %+  expect-eq
    !>  :~  :+  %selection
                ctes=~
                [[simple-from-foo-join-bar-aliased-nec-db2-ns1] ~ ~]
            ==
    !>  %-  parse:parse(default-database 'db1')
            "FROM ~nec.db2.ns1.foo join ~nec.db2.ns1.bar b1 on 1 = 1 ".
            "SELECT TOP 10 *"
::
::  from foo (un-aliased) join bar (aliased as)
++  test-join-31
  %+  expect-eq
    !>  ~[[%selection ctes=~ [[simple-from-foo-join-bar-aliased] ~ ~]]]
    !>  %-  parse:parse(default-database 'db1')
            "FROM foo join bar  as  b1 on 1 = 1 SELECT TOP 10 *"
::
::  from ns1.foo (un-aliased) join ns1.bar (aliased as)
++  test-join-32
  %+  expect-eq
    !>  ~[[%selection ctes=~ [[simple-from-foo-join-bar-aliased-ns1] ~ ~]]]
    !>  %-  parse:parse(default-database 'db1')
            "FROM ns1.foo join ns1.bar  as  b1 on 1 = 1 SELECT TOP 10 *"
::
::  from db2..foo (un-aliased) join db2..bar (aliased as)
++  test-join-33
  %+  expect-eq
    !>  ~[[%selection ctes=~ [[simple-from-foo-join-bar-aliased-db2] ~ ~]]]
    !>  %-  parse:parse(default-database 'db1')
            "FROM db2..foo join db2..bar  as  b1 on 1 = 1 SELECT TOP 10 *"
::
::  from db2.ns1.foo (un-aliased) join db2.ns1.bar (aliased as)
++  test-join-34
  %+  expect-eq
    !>  ~[[%selection ctes=~ [[simple-from-foo-join-bar-aliased-db2-ns1] ~ ~]]]
    !>  %-  parse:parse(default-database 'db1')
            "FROM db2.ns1.foo join db2.ns1.bar  as  b1 on 1 = 1 SELECT TOP 10 *"
::
::  from ~nec.db2..foo (un-aliased) join ~nec.db2..bar (aliased as)
++  test-join-35
  %+  expect-eq
    !>  ~[[%selection ctes=~ [[simple-from-foo-join-bar-aliased-nec-db2] ~ ~]]]
    !>  %-  parse:parse(default-database 'db1')
            "FROM ~nec.db2..foo join ~nec.db2..bar  as  b1 on 1 = 1 ".
            "SELECT TOP 10 *"
::
::  from ~nec.db2.ns1.foo (un-aliased) join ~nec.db2.ns1.bar (aliased as)
++  test-join-36
  %+  expect-eq
    !>  :~  :+  %selection
                ctes=~
                [[simple-from-foo-join-bar-aliased-nec-db2-ns1] ~ ~]
            ==
    !>  %-  parse:parse(default-database 'db1')
            "FROM ~nec.db2.ns1.foo join ~nec.db2.ns1.bar  as  b1 on 1 = 1 ".
            "SELECT TOP 10 *"
::
::  from foo (aliased lower case) join bar (aliased as)
++  test-join-37
  =/  expected  :+  %selection
                    ctes=~
                    :+  :*  %query
                            :-  ~
                                :^  %from
                                    object=foo-table-f1-low
                                    as-of=~
                                    joins=join-bar-aliased
                            scalars=~
                            ~
                            group-by=~
                            having=~
                            [%select top=[~ 10] bottom=~ columns=~[[%all %all]]]
                            order-by=~
                            ==
                        ~
                        ~
  %+  expect-eq
    !>  ~[expected]
    !>  %-  parse:parse(default-database 'db1')
            "FROM foo f1 join bar b1 on 1 = 1 SELECT TOP 10 *"
::
::  from foo (un-aliased) join bar (un-aliased) left join baz (un-aliased)
++  test-join-38
  =/  expected  :+  %selection
                    ctes=~
                    :+  :*  %query
                            :-  ~
                                :^  %from
                                    object=object=foo-table
                                    as-of=~
                                    :~  :*  %joined-object
                                            join=%join
                                            object=bar-unaliased
                                            as-of=~
                                            predicate=`one-eq-1
                                            ==
                                        :*  %joined-object
                                            join=%left-join
                                            :-  %table-set
                                                :*  %qualified-object
                                                    ship=~
                                                    database='db1'
                                                    namespace='dbo'
                                                    name='baz'
                                                    alias=~
                                                    ==
                                            as-of=~
                                            predicate=`one-eq-1
                                            ==
                                        ==
                            scalars=~
                            ~
                            group-by=~
                            having=~
                            [%select top=[~ 10] bottom=~ columns=~[[%all %all]]]
                            order-by=~
                            ==
                        ~
                        ~
  %+  expect-eq
    !>   ~[expected]
    !>  %-  parse:parse(default-database 'db1')
            "FROM foo join bar on 1 = 1 left join baz on 1 = 1 SELECT TOP 10 *"
::
::  from foo (aliased) join bar (aliased) left join baz (aliased)
++  test-join-39
  =/  expected  :+  %selection
                    ctes=~
                    :+  :*  %query
                            :-  ~
                                :^  %from
                                    object=foo-table-f1-low
                                    as-of=~
                                    :~  :*  %joined-object
                                            join=%join
                                            :-  %table-set
                                                :*  %qualified-object
                                                          ship=~
                                                          database='db1'
                                                          namespace='dbo'
                                                          name='bar'
                                                          alias=[~ 'B1']
                                                          ==
                                            as-of=~
                                            predicate=`one-eq-1
                                            ==
                                        :*  %joined-object
                                            join=%left-join
                                            :-  %table-set
                                                :*  %qualified-object
                                                          ship=~
                                                          database='db1'
                                                          namespace='dbo'
                                                          name='baz'
                                                          alias=[~ 'b2']
                                                          ==
                                            as-of=~
                                            predicate=`one-eq-1
                                            ==
                                        ==
                            scalars=~
                            ~
                            group-by=~
                            having=~
                            [%select top=[~ 10] bottom=~ columns=~[[%all %all]]]
                            order-by=~
                            ==
                      ~
                      ~
  %+  expect-eq
    !>  ~[expected]
    !>  %-  parse:parse(default-database 'db1')
            "FROM foo f1 join bar as B1 on 1 = 1 ".
            "left join baz b2 on 1 = 1 SELECT TOP 10 *"
::
::  from pass-thru row (un-aliased)
:::: to do: uncomment and fix when inserted table-set enabled
::++  test-join-10
::  %+  expect-eq
::    !>  ~[[%selection ctes=~ [[simple-from-foo-row] ~ ~]]]
::    !>  %-  parse:parse(default-database 'db1')
::            "FROM (col1, col2, col3) SELECT TOP 10 *"
::::
::::  from pass-thru row (aliased)
::++  test-join-11
::  %+  expect-eq
::    !>  ~[[%selection ctes=~ [[aliased-from-foo-row] ~ ~]]]
::    !>  %-  parse:parse(default-database 'db1')
::            "FROM (col1, col2, col3) F1 SELECT TOP 10 *"
::::
::::  from pass-thru row (aliased as)
::++  test-join-12
::  %+  expect-eq
::    !>  ~[[%selection ctes=~ [[aliased-from-foo-row] ~ ~]]]
::    !>  %-  parse:parse(default-database 'db1')
::            "FROM (col1, col2, col3) as F1 SELECT TOP 10 *"
::::  from foo (un-aliased) join pass-thru (un-aliased)
::++  test-join-13
::  %+  expect-eq
::    !>  ~[[%selection ctes=~ [[simple-from-foo-join-bar-row] ~ ~]]]
::    !>  %-  parse:parse(default-database 'db1')
::            "FROM foo join (col1, col2, col3) on 1 = 1 SELECT TOP 10 *"
::::
::::  from foo (un-aliased) join pass-thru (aliased)
::++  test-join-14
::  %+  expect-eq
::    !>  ~[[%selection ctes=~ [[simple-from-foo-join-bar-row-aliased] ~ ~]]]
::    !>  %-  parse:parse(default-database 'db1')
::            "FROM foo join (col1, col2, col3) b1 on 1 = 1 SELECT TOP 10 *"
::::
::::  from foo (un-aliased) join pass-thru (aliased as)
::++  test-join-15
::  %+  expect-eq
::    !>  ~[[%selection ctes=~ [[simple-from-foo-join-bar-row-aliased] ~ ~]]]
::    !>  %-  parse:parse(default-database 'db1')
::            "FROM foo join (col1,col2,col3)  as  b1 on 1 = 1 SELECT TOP 10 *"
::::
::::  from foo (aliased lower case) join pass-thru (aliased as)
::++  test-join-16
::  %+  expect-eq
::    !>  ~[[%selection ctes=~ [[aliased-from-foo-join-bar-row-aliased] ~ ~]]]
::    !>  %-  parse:parse(default-database 'db1')
::            "FROM foo f1 join (col1,col2,col3) b1 on 1 = 1 SELECT TOP 10 *"
::::
::::  from pass-thru (un-aliased) join bar (un-aliased)
::::  left join pass-thru (un-aliased)
::++  test-join-17
::  %+  expect-eq
::    !>  ~[[%selection ctes=~ [[simple-from-foo-join-bar-row-baz] ~ ~]]]
::    !>  %-  parse:parse(default-database 'db1')
::            "FROM (col1,col2,col3) join bar on 1 = 1 ".
::            "left join (col1,col2,col3) on 1 = 1 SELECT TOP 10 *"
::::
::::  from pass-thru single column (aliased)
::::  join bar (aliased) left join pass-thru (aliased)
::++  test-join-18
::  %+  expect-eq
::    !>  ~[[%selection ctes=~ [[aliased-from-foo-join-bar-row-baz] ~ ~]]]
::    !>  %-  parse:parse(default-database 'db1')
::            "FROM (col1) f1 join bar as B1 on 1 = 1 ".
::            "left join ( col1,col2,col3 ) b2 on 1 = 1 SELECT TOP 10 *"

::
::  from foo as (aliased) cross join bar (aliased)
++  test-join-40
  %+  expect-eq
  =/  expected  :+  %selection
                    ctes=~
                    :+  :*  %query
                            :-  ~
                                :^  %from
                                    object=foo-alias-y
                                    as-of=~
                                    :~  :*  %joined-object
                                            join=%cross-join
                                            object=bar-alias-x
                                            as-of=~
                                            predicate=~
                                            ==
                                        ==
                            scalars=~
                            predicate=~
                            group-by=~
                            having=~
                            selection=select-all-columns
                            order-by=~
                            ==
                    ~
                    ~
      !>  ~[expected]
      !>  %-  parse:parse(default-database 'db1')
            "FROM foo as y cross join bar x SELECT *"
::
::  from foo (aliased) cross join bar as (aliased)
++  test-join-41
  %+  expect-eq
  =/  expected  :+  %selection
                    ctes=~
                    :+  :*  %query
                            :-  ~
                                :^  %from
                                    object=foo-alias-y
                                    as-of=~
                                    :~  :*  %joined-object
                                            join=%cross-join
                                            object=bar-alias-x
                                            as-of=~
                                            predicate=~
                                            ==
                                        ==
                            scalars=~
                            predicate=~
                            group-by=~
                            having=~
                            selection=select-all-columns
                            order-by=~
                            ==
                    ~
                    ~
      !>  ~[expected]
      !>  %-  parse:parse(default-database 'db1')
              "FROM foo y cross join bar as x SELECT *"
::
::  from foo cross join bar
++  test-join-42
  %+  expect-eq
  =/  expected  :+  %selection
                    ctes=~
                    :+  :*  %query
                            :-  ~
                                :^  %from
                                    object=foo-table
                                    as-of=~
                                    :~  :*  %joined-object
                                            join=%cross-join
                                            object=bar-unaliased
                                            as-of=~
                                            predicate=~
                                            ==
                                        ==
                            scalars=~
                            predicate=~
                            group-by=~
                            having=~
                            selection=select-all-columns
                            order-by=~
                            ==
                      ~
                      ~
      !>  ~[expected]
      !>  %-  parse:parse(default-database 'db1')
            "FROM foo cross join bar SELECT *"
::
::  from pass-thru as (aliased) cross join bar (aliased)
:::: to do: uncomment and fix when inserted table-set enabled
::++  test-join-22
::  %+  expect-eq
::  =/  expected  :+  %selection
::                    ctes=~
::                    :+  :*  %query
::                            :-  ~
::                                :^  %from
::                                    object=passthru-row-y
::                                    as-of=~
::                                    :~  :*  %joined-object
::                                            join=%cross-join
::                                            object=bar-alias-x
::                                            as-of=~
::                                            predicate=~
::                                            ==
::                                        ==
::                            scalars=~
::                            predicate=~
::                            group-by=~
::                            having=~
::                            selection=select-all-columns
::                            order-by=~
::                            ==
::                    ~
::                    ~
::      !>  ~[expected]
::      !>  %-  parse:parse(default-database 'db1')
::            "FROM (col1, col2, col3) as y cross join bar x SELECT *"
::
::  from pass-thru (aliased) cross join bar as (aliased)
::++  test-join-23
::  %+  expect-eq
::  =/  expected  :+  %selection
::                    ctes=~
::                    :+  :*  %query
::                            :-  ~
::                                :^  %from
::                                    object=passthru-row-y
::                                    as-of=~
::                                    :~  :*  %joined-object
::                                            join=%cross-join
::                                            object=bar-alias-x
::                                            as-of=~
::                                            predicate=~
::                                            ==
::                                        ==
::                            scalars=~
::                            predicate=~
::                            group-by=~
::                            having=~
::                            selection=select-all-columns
::                            order-by=~
::                            ==
::                    ~
::                    ~
::      !>  ~[expected]
::      !>  %-  parse:parse(default-database 'db1')
::            "FROM (col1,col2,col3) y cross join bar as x SELECT *"
::::
::::  from foo as (aliased) cross join pass-thru  (aliased)
::++  test-join-24
::  %+  expect-eq
::  =/  expected  :+  %selection
::                    ctes=~
::                    :+  :*  %query
::                            :-  ~
::                                :^  %from
::                                    object=foo-alias-y
::                                    as-of=~
::                                    :~  :*  %joined-object
::                                            join=%cross-join
::                                            object=passthru-row-x as-of=~
::                                            predicate=~
::                                            ==
::                                        ==
::                            scalars=~
::                            predicate=~
::                            group-by=~
::                            having=~
::                            selection=select-all-columns
::                            order-by=~
::                            ==
::                    ~
::                    ~
::      !>  ~[expected]
::      !>  %-  parse:parse(default-database 'db1')
::            "FROM foo as y cross join (col1,col2,col3) x SELECT *"
::::
::::  from foo (aliased) cross join pass-thru  as (aliased)
::++  test-join-25
::  %+  expect-eq
::  =/  expected  :+  %selection
::                    ctes=~
::                    :+  :*  %query
::                            :-  ~
::                                :^  %from
::                                    object=foo-alias-y
::                                    as-of=~
::                                    :~  :*  %joined-object
::                                            join=%cross-join
::                                            object=passthru-row-x
::                                            as-of=~
::                                            predicate=~
::                                            ==
::                                        ==
::                            scalars=~
::                            predicate=~
::                            group-by=~
::                            having=~
::                            selection=select-all-columns
::                            order-by=~
::                            ==
::                    ~
::                    ~
::      !>  ~[expected]
::      !>  %-  parse:parse(default-database 'db1')
::            "FROM foo y cross join (col1,col2,col3) as x SELECT *"
::::
::::  from pass-thru cross join pass-thru
::++  test-join-26
::  %+  expect-eq
::  =/  expected  :+  %selection
::                    ctes=~
::                    :+  :*  %query
::                            :-  ~
::                                :^  %from
::                                    object=passthru-unaliased
::                                    as-of=~
::                                    :~  :*  %joined-object
::                                            join=%cross-join
::                                            object=passthru-unaliased
::                                            as-of=~
::                                            predicate=~
::                                            ==
::                                        ==
::                            scalars=~
::                            predicate=~
::                            group-by=~
::                            having=~
::                            selection=select-all-columns
::                            order-by=~
::                            ==
::                    ~
::                    ~
::      !>  ~[expected]
::      !>  %-  parse:parse(default-database 'db1')
::            "FROM (col1,col2,col3) cross join (col1,col2,col3) SELECT *"
::::
::::  from foo (aliased) cross join pass-thru
::++  test-join-27
::  %+  expect-eq
::  =/  expected  :+  %selection
::                    ctes=~
::                    :+  :*  %query
::                            :-  ~
::                                :^  %from
::                                    object=foo-alias-y
::                                    as-of=~
::                                    :~  :*  %joined-object
::                                            join=%cross-join
::                                            object=passthru-unaliased
::                                            as-of=~
::                                            predicate=~
::                                            ==
::                                        ==
::                            scalars=~
::                            predicate=~
::                            group-by=~
::                            having=~
::                            selection=select-all-columns
::                            order-by=~
::                            ==
::                    ~
::                    ~
::      !>  ~[expected]
::      !>  %-  parse:parse(default-database 'db1')
::            "FROM foo y cross join (col1,col2,col3) SELECT *"

::
::  (natural join) from foo as (unaliased) join bar (unaliased)
++  test-join-43
  %+  expect-eq
  =/  expected  :+  %selection
                    ctes=~
                    :+  :*  %query
                            :-  ~
                                :^  %from
                                    object=foo-table
                                    as-of=~
                                    :~  :*  %joined-object
                                            join=%join
                                            object=bar-unaliased
                                            as-of=~
                                            predicate=~
                                            ==
                                        ==
                            scalars=~
                            predicate=~
                            group-by=~
                            having=~
                            selection=select-all-columns
                            order-by=~
                            ==
                    ~
                    ~
      !>  ~[expected]
      !>  (parse:parse(default-database 'db1') "FROM foo join bar SELECT *")
::
::  (natural join) from foo as (aliased) join bar (aliased)
++  test-join-44
  %+  expect-eq
  =/  expected  :+  %selection
                    ctes=~
                    :+  :*  %query
                            :-  ~
                                :^  %from
                                    object=foo-alias-y
                                    as-of=~
                                    :~  :*  %joined-object
                                            join=%join
                                            object=bar-alias-x
                                            as-of=~
                                            predicate=~
                                            ==
                                        ==
                            scalars=~
                            predicate=~
                            group-by=~
                            having=~
                            selection=select-all-columns
                            order-by=~
                            ==
                    ~
                    ~
      !>  ~[expected]
      !>  %-  parse:parse(default-database 'db1')
              "FROM foo as y join bar x SELECT *"
::
::  AS OF queries
::
::  from foo %now (un-aliased)
++  test-as-of-01
  %+  expect-eq
      !>  (expected [simple-from [%as-of-offset 0 %seconds]])
      !>  %-  parse:parse(default-database 'db1')
              "FROM foo aS Of Now SELECT TOP 10 *"
::
::  from foo %now (aliased)
++  test-as-of-02
  %+  expect-eq
      !>  (expected [simple-from-aliased [%as-of-offset 0 %seconds]])
      !>  %-  parse:parse(default-database 'db1')
              "FROM foo AS OF NOW F1 SELECT TOP 10 *"
::
::  from foo %now (aliased as)
++  test-as-of-03
  %+  expect-eq
      !>  (expected [simple-from-aliased [%as-of-offset 0 %seconds]])
      !>  %-  parse:parse(default-database 'db1')
              "FROM foo AS OF NOW as F1 SELECT TOP 10 *"
::
::  from foo %now (un-aliased) join bar %now (un-aliased)
++  test-as-of-04
  %+  expect-eq
      !>  (expected [simple-from-join-bar [%as-of-offset 0 %seconds]])
      !>  %-  parse:parse(default-database 'db1')
            "FROM foo AS OF NOW join bar AS OF NOW on 1 = 1 SELECT TOP 10 *"
::
::  from ns1.foo %now (un-aliased) join ns1.bar %now (un-aliased)
++  test-as-of-05
  %+  expect-eq
      !>  (expected [simple-from-join-bar-ns1 [%as-of-offset 0 %seconds]])
      !>  %-  parse:parse(default-database 'db1')
            "FROM ns1.foo AS OF NOW join ns1.bar AS OF NOW on 1 = 1 ".
            "SELECT TOP 10 *"
::
::  from db2..foo %now (un-aliased) join db2..bar %now (un-aliased)
++  test-as-of-06
  %+  expect-eq
      !>  (expected [simple-from-join-bar-db2 [%as-of-offset 0 %seconds]])
      !>  %-  parse:parse(default-database 'db1')
            "FROM db2..foo AS OF NOW join db2..bar AS OF NOW on 1 = 1 ".
            "SELECT TOP 10 *"
::
::  from db2.ns1.foo %now (un-aliased) join db2.ns1.bar %now (un-aliased)
++  test-as-of-07
  %+  expect-eq
      !>  (expected [simple-from-join-bar-db2-ns1 [%as-of-offset 0 %seconds]])
      !>  %-  parse:parse(default-database 'db1')
            "FROM db2.ns1.foo AS OF NOW join db2.ns1.bar AS OF NOW on 1 = 1 ".
            "SELECT TOP 10 *"
::
::  from ~nec.db2..foo %now (un-aliased) join ~nec.db2..bar %now (un-aliased)
++  test-as-of-08
  %+  expect-eq
      !>  (expected [simple-from-join-bar-nec-db2 [%as-of-offset 0 %seconds]])
      !>  %-  parse:parse(default-database 'db1')
            "FROM ~nec.db2..foo AS OF NOW join ~nec.db2..bar AS OF NOW ".
            "on 1 = 1 SELECT TOP 10 *"
::
::  from ~nec.db2.ns1.foo %now (un-aliased)
::       join ~nec.db2.ns1.bar %now (un-aliased)
++  test-as-of-09
  %+  expect-eq
      !>  %-  expected
              [simple-from-join-bar-nec-db2-ns1 [%as-of-offset 0 %seconds]]
      !>  %-  parse:parse(default-database 'db1')
            "FROM ~nec.db2.ns1.foo AS OF NOW join ~nec.db2.ns1.bar AS OF NOW ".
            "on 1 = 1 SELECT TOP 10 *"
::
::  from foo %now (un-aliased) join bar %now (aliased)
++  test-as-of-10
  %+  expect-eq
      !>  (expected [simple-from-join-bar-aliased [%as-of-offset 0 %seconds]])
      !>  %-  parse:parse(default-database 'db1')
            "FROM foo AS OF NOW join bar AS OF NOW B1 on 1 = 1 SELECT TOP 10 *"
::
::  from foo %now (un-aliased) join bar %now (aliased as)
++  test-as-of-11
  %+  expect-eq
      !>  (expected [simple-from-join-bar-aliased [%as-of-offset 0 %seconds]])
      !>  %-  parse:parse(default-database 'db1')
              "FROM foo AS OF NOW join bar AS OF NOW  as  B1 on 1 = 1 ".
              "SELECT TOP 10 *"
::
::  from foo %now (aliased) join bar %now (aliased as)
++  test-as-of-12
  %+  expect-eq
      !>  %-  expected
              [simple-from-aliased-join-bar-aliased [%as-of-offset 0 %seconds]]
      !>  %-  parse:parse(default-database 'db1')
              "FROM foo AS OF NOW F1 join bar AS OF NOW B1 on 1 = 1 ".
              "SELECT TOP 10 *"
::
::  from ns1.foo %now (aliased) join ns1.bar %now (aliased as)
++  test-as-of-13
  %+  expect-eq
      !>  %-  expected
              :-  simple-from-aliased-join-bar-aliased-ns1
                  [%as-of-offset 0 %seconds]
      !>  %-  parse:parse(default-database 'db1')
              "FROM ns1.foo AS OF NOW F1 join ns1.bar AS OF NOW B1 on 1 = 1 ".
              "SELECT TOP 10 *"
::
::  from db2..foo %now (aliased) join db2..bar %now (aliased as)
++  test-as-of-14
  %+  expect-eq
      !>  %-  expected
              :-  simple-from-aliased-join-bar-aliased-db2
                  [%as-of-offset 0 %seconds]
      !>  %-  parse:parse(default-database 'db1')
              "FROM db2..foo AS OF NOW F1 join db2..bar AS OF NOW B1 on 1 = 1 ".
              "SELECT TOP 10 *"
::
::  from db2.ns1.foo %now (aliased) join db2.ns1.bar %now (aliased as)
++  test-as-of-15
  %+  expect-eq
      !>  %-  expected
              :-  simple-from-aliased-join-bar-aliased-db2-ns1
                  [%as-of-offset 0 %seconds]
      !>  %-  parse:parse(default-database 'db1')
              "FROM db2.ns1.foo AS OF NOW F1 join db2.ns1.bar AS OF NOW B1 ".
              "on 1 = 1 SELECT TOP 10 *"
::
::  from ~nec.db2..foo %now (aliased) join ~nec.db2..bar %now (aliased as)
++  test-as-of-16
  %+  expect-eq
      !>  %-  expected
              :-  simple-from-aliased-join-bar-aliased-nec-db2
                  [%as-of-offset 0 %seconds]
      !>  %-  parse:parse(default-database 'db1')
              "FROM ~nec.db2..foo AS OF NOW F1 ".
              "join ~nec.db2..bar AS OF NOW B1 on 1 = 1 ".
              "SELECT TOP 10 *"
::
::  from ~nec.db2.ns1.foo %now (aliased) join ~nec.db2.ns1.bar %now (aliased as)
++  test-as-of-17
  %+  expect-eq
      !>  %-  expected
              :-  simple-from-aliased-join-bar-aliased-nec-db2-ns1
                  [%as-of-offset 0 %seconds]
      !>  %-  parse:parse(default-database 'db1')
              "FROM ~nec.db2.ns1.foo AS OF NOW F1 ".
              "join ~nec.db2.ns1.bar AS OF NOW B1 on 1 = 1 ".
              "SELECT TOP 10 *"
::
::  from foo %now (un-aliased) join bar %now (un-aliased)
::                             left join baz %now (un-aliased)
++  test-as-of-18
  %+  expect-eq
      !>  (expected [simple-from-join-bar-baz [%as-of-offset 0 %seconds]])
      !>  %-  parse:parse(default-database 'db1')
              "FROM foo AS OF NOW ".
              "left join bar AS OF NOW on 1 = 1 ".
              "join baz AS OF NOW on 1 = 1 SELECT TOP 10 *"
::
::  from foo %now (aliased) join bar %now (aliased) left join baz %now (aliased)
++  test-as-of-19
  %+  expect-eq
      !>  %-  expected
              [simple-from-aliased-join-bar-baz [%as-of-offset 0 %seconds]]
      !>  %-  parse:parse(default-database 'db1')
              "FROM foo AS OF NOW F1 ".
              "join bar AS OF NOW as B1 on 1 = 1 ".
              "left join baz AS OF NOW b2 on 1 = 1 SELECT TOP 10 *"
::
::  from foo %now as (aliased) cross join bar %now (aliased)
++  test-as-of-20
  %+  expect-eq
      !>  (expected [simple-from-aliased-cross-bar [%as-of-offset 0 %seconds]])
      !>  %-  parse:parse(default-database 'db1')
              "FROM foo AS OF NOW as F1 cross join bar AS OF NOW B1 SELECT *"
::
::  from foo %now cross join bar %now
++  test-as-of-21
  %+  expect-eq
      !>  (expected [simple-from-cross-join-bar [%as-of-offset 0 %seconds]])
      !>  %-  parse:parse(default-database 'db1')
              "FROM foo AS OF NOW cross join bar AS OF NOW SELECT *"
::
::  from foo %now (aliased) cross join bar %now as (aliased)
++  test-as-of-22
  %+  expect-eq
      !>  (expected [simple-from-aliased-cross-bar [%as-of-offset 0 %seconds]])
      !>  %-  parse:parse(default-database 'db1')
              "FROM foo AS OF NOW F1 cross join bar AS OF NOW as B1 SELECT *"
::
::  from foo as-of 2 minutes ago (un-aliased)
++  test-as-of-23
  %+  expect-eq
      !>  (expected [simple-from [%as-of-offset 2 %minutes]])
      !>  %-  parse:parse(default-database 'db1')
              "FROM foo As oF 2 miNutes AgO SELECT TOP 10 *"
::
::  from foo as-of 2 minutes ago (aliased)
++  test-as-of-24
  %+  expect-eq
      !>  (expected [simple-from-aliased [%as-of-offset 2 %minutes]])
      !>  %-  parse:parse(default-database 'db1')
              "FROM foo AS OF 2 minutes AGO F1 SELECT TOP 10 *"
::
::  from foo as-of 2 minutes ago (aliased as)
++  test-as-of-25
  %+  expect-eq
      !>  (expected [simple-from-aliased [%as-of-offset 2 %minutes]])
      !>  %-  parse:parse(default-database 'db1')
              "FROM foo AS OF 2 minutes AGO as F1 SELECT TOP 10 *"
::
::  from foo as-of 2 minutes ago (un-aliased) 
::  join bar as-of 2 minutes ago (un-aliased)
++  test-as-of-26
  %+  expect-eq
      !>  (expected [simple-from-join-bar [%as-of-offset 2 %minutes]])
      !>  %-  parse:parse(default-database 'db1')
              "FROM foo AS OF 2 minutes AGO ".
              "join bar AS OF 2 minutes AGO on 1 = 1 SELECT TOP 10 *"
::
::  from foo as-of 2 minutes ago (un-aliased) 
::  join bar as-of 2 minutes ago (aliased)
++  test-as-of-27
  %+  expect-eq
      !>  (expected [simple-from-join-bar-aliased [%as-of-offset 2 %minutes]])
      !>  %-  parse:parse(default-database 'db1')
              "FROM foo AS OF 2 minutes AGO ".
              "join bar AS OF 2 minutes AGO B1 on 1 = 1 SELECT TOP 10 *"
::
::  from foo as-of 2 minutes ago (un-aliased) 
::  join bar as-of 2 minutes ago (aliased as)
++  test-as-of-28
  %+  expect-eq
      !>  (expected [simple-from-join-bar-aliased [%as-of-offset 2 %minutes]])
      !>  %-  parse:parse(default-database 'db1')
              "FROM foo AS OF 2 minutes AGO ".
              "join bar AS OF 2 minutes AGO  as  B1 on 1 = 1 ".
              "SELECT TOP 10 *"
::
::  from foo as-of 2 minutes ago (aliased) 
::  join bar as-of 2 minutes ago (aliased as)
++  test-as-of-29
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
++  test-as-of-30
  %+  expect-eq
      !>  (expected [simple-from-join-bar-baz [%as-of-offset 2 %minutes]])
      !>  %-  parse:parse(default-database 'db1')
              "FROM foo AS OF 2 minutes AGO ".
              "left join bar AS OF 2 minutes AGO on 1 = 1 ".
              "join baz AS OF 2 minutes AGO on 1 = 1 SELECT TOP 10 *"
::
::  from ns1.foo as-of 2 minutes ago (un-aliased) 
::       join ns1.bar as-of 2 minutes ago (un-aliased)
::       left join ns1.baz as-of 2 minutes ago (un-aliased)
++  test-as-of-31
  %+  expect-eq
      !>  (expected [simple-from-join-bar-baz-ns1 [%as-of-offset 2 %minutes]])
      !>  %-  parse:parse(default-database 'db1')
              "FROM ns1.foo AS OF 2 minutes AGO ".
              "left join ns1.bar AS OF 2 minutes AGO on 1 = 1 ".
              "join ns1.baz AS OF 2 minutes AGO on 1 = 1 SELECT TOP 10 *"
::
::  from db2..foo as-of 2 minutes ago (un-aliased) 
::       join db2..bar as-of 2 minutes ago (un-aliased)
::       left join db2..baz as-of 2 minutes ago (un-aliased)
++  test-as-of-32
  %+  expect-eq
      !>  (expected [simple-from-join-bar-baz-db2 [%as-of-offset 2 %minutes]])
      !>  %-  parse:parse(default-database 'db1')
              "FROM db2..foo AS OF 2 minutes AGO ".
              "left join db2..bar AS OF 2 minutes AGO on 1 = 1 ".
              "join db2..baz AS OF 2 minutes AGO on 1 = 1 SELECT TOP 10 *"
::
::  from db2.ns1.foo as-of 2 minutes ago (un-aliased) 
::       join db2.ns1.bar as-of 2 minutes ago (un-aliased)
::       left join db2.ns1.baz as-of 2 minutes ago (un-aliased)
++  test-as-of-33
  %+  expect-eq
      !>  %-  expected
              [simple-from-join-bar-baz-db2-ns1 [%as-of-offset 2 %minutes]]
      !>  %-  parse:parse(default-database 'db1')
              "FROM db2.ns1.foo AS OF 2 minutes AGO ".
              "left join db2.ns1.bar AS OF 2 minutes AGO on 1 = 1 ".
              "join db2.ns1.baz AS OF 2 minutes AGO on 1 = 1 SELECT TOP 10 *"
::
::  from ~nec.db2..foo as-of 2 minutes ago (un-aliased) 
::       join ~nec.db2..bar as-of 2 minutes ago (un-aliased)
::       left join ~nec.db2..baz as-of 2 minutes ago (un-aliased)
++  test-as-of-34
  %+  expect-eq
      !>  %-  expected
              [simple-from-join-bar-baz-nec-db2 [%as-of-offset 2 %minutes]]
      !>  %-  parse:parse(default-database 'db1')
              "FROM ~nec.db2..foo AS OF 2 minutes AGO ".
              "left join ~nec.db2..bar AS OF 2 minutes AGO on 1 = 1 ".
              "join ~nec.db2..baz AS OF 2 minutes AGO on 1 = 1 SELECT TOP 10 *"
::
::  from ~nec.db2.ns1.foo as-of 2 minutes ago (un-aliased) 
::       join ~nec.db2.ns1.bar as-of 2 minutes ago (un-aliased)
::       left ~nec.db2.ns1.join baz as-of 2 minutes ago (un-aliased)
++  test-as-of-35
  %+  expect-eq
      !>  %-  expected
              [simple-from-join-bar-baz-nec-db2-ns1 [%as-of-offset 2 %minutes]]
      !>  %-  parse:parse(default-database 'db1')
              "FROM ~nec.db2.ns1.foo AS OF 2 minutes AGO ".
              "left join ~nec.db2.ns1.bar AS OF 2 minutes AGO on 1 = 1 ".
              "join ~nec.db2.ns1.baz AS OF 2 minutes AGO on 1 = 1 ".
              "SELECT TOP 10 *"
::
::  from foo as-of 2 minutes ago (aliased) 
::                             join bar as-of 2 minutes ago (aliased) 
::                             left join baz as-of 2 minutes ago (aliased)
++  test-as-of-36
  %+  expect-eq
      !>  %-  expected
              [simple-from-aliased-join-bar-baz [%as-of-offset 2 %minutes]]
      !>  %-  parse:parse(default-database 'db1')
              "FROM foo AS OF 2 minutes AGO F1 ".
              "join bar AS OF 2 minutes AGO as B1 on 1 = 1 ".
              "left join baz AS OF 2 minutes AGO b2 on 1 = 1 SELECT TOP 10 *"
::
::  from ns1.foo as-of 2 minutes ago (aliased) 
::                             join ns1.bar as-of 2 minutes ago (aliased) 
::                             left join ns1.baz as-of 2 minutes ago (aliased)
++  test-as-of-37
  %+  expect-eq
      !>  %-  expected
              [simple-from-aliased-join-bar-baz-ns1 [%as-of-offset 2 %minutes]]
      !>  %-  parse:parse(default-database 'db1')
              "FROM  ns1.foo AS OF 2 minutes AGO F1 ".
              "join  ns1.bar AS OF 2 minutes AGO as B1 on 1 = 1 ".
              "left join  ns1.baz AS OF 2 minutes AGO b2 on 1 = 1 ".
              "SELECT TOP 10 *"
::
::  from db2..foo as-of 2 minutes ago (aliased) 
::                             join db2..bar as-of 2 minutes ago (aliased) 
::                             left join db2..baz as-of 2 minutes ago (aliased)
++  test-as-of-38
  %+  expect-eq
      !>  %-  expected
              [simple-from-aliased-join-bar-baz-db2 [%as-of-offset 2 %minutes]]
      !>  %-  parse:parse(default-database 'db1')
              "FROM db2..foo AS OF 2 minutes AGO F1 ".
              "join db2..bar AS OF 2 minutes AGO as B1 on 1 = 1 ".
              "left join db2..baz AS OF 2 minutes AGO b2 on 1 = 1 ".
              "SELECT TOP 10 *"
::
::  from db2.ns1.foo as-of 2 minutes ago (aliased) 
::       join db2.ns1.bar as-of 2 minutes ago (aliased) 
::       left join db2.ns1.baz as-of 2 minutes ago (aliased)
++  test-as-of-39
  %+  expect-eq
      !>  %-  expected
              :-  simple-from-aliased-join-bar-baz-db2-ns1
                  [%as-of-offset 2 %minutes]
      !>  %-  parse:parse(default-database 'db1')
              "FROM db2.ns1.foo AS OF 2 minutes AGO F1 ".
              "join db2.ns1.bar AS OF 2 minutes AGO as B1 on 1 = 1 ".
              "left join db2.ns1.baz AS OF 2 minutes AGO b2 on 1 = 1 ".
              "SELECT TOP 10 *"
::
::  from ~nec.db2..foo as-of 2 minutes ago (aliased) 
::       join ~nec.db2..bar as-of 2 minutes ago (aliased) 
::       left join ~nec.db2..baz as-of 2 minutes ago (aliased)
++  test-as-of-40
  %+  expect-eq
      !>  %-  expected
              :-  simple-from-aliased-join-bar-baz-nec-db2
                  [%as-of-offset 2 %minutes]
      !>  %-  parse:parse(default-database 'db1')
              "FROM ~nec.db2..foo AS OF 2 minutes AGO F1 ".
              "join ~nec.db2..bar AS OF 2 minutes AGO as B1 on 1 = 1 ".
              "left join ~nec.db2..baz AS OF 2 minutes AGO b2 on 1 = 1 ".
              "SELECT TOP 10 *"
::
::  from ~nec.db2.ns1.foo as-of 2 minutes ago (aliased) 
::       join ~nec.db2.ns1.bar as-of 2 minutes ago (aliased) 
::       left ~nec.db2.ns1.join baz as-of 2 minutes ago (aliased)
++  test-as-of-41
  %+  expect-eq
      !>  %-  expected
              :-  simple-from-aliased-join-bar-baz-nec-db2-ns1
                  [%as-of-offset 2 %minutes]
      !>  %-  parse:parse(default-database 'db1')
              "FROM ~nec.db2.ns1.foo AS OF 2 minutes AGO F1 ".
              "join ~nec.db2.ns1.bar AS OF 2 minutes AGO as B1 on 1 = 1 ".
              "left join ~nec.db2.ns1.baz AS OF 2 minutes AGO b2 on 1 = 1 ".
              "SELECT TOP 10 *"
::
::  from foo as-of 2 minutes ago as (aliased) 
::  cross join bar 4as-of 2 minutes ago (aliased)
++  test-as-of-42
  %+  expect-eq
      !>  (expected [simple-from-aliased-cross-bar [%as-of-offset 2 %minutes]])
      !>  %-  parse:parse(default-database 'db1')
              "FROM foo AS OF 2 minutes AGO as F1 ".
              "cross join bar AS OF 2 minutes AGO B1 SELECT *"
::
::  from foo as-of 2 minutes ago cross join bar as-of 2 minutes ago
++  test-as-of-43
  %+  expect-eq
      !>  (expected [simple-from-cross-join-bar [%as-of-offset 2 %minutes]])
      !>  %-  parse:parse(default-database 'db1')
              "FROM foo AS OF 2 minutes AGO ".
              "cross join bar AS OF 2 minutes AGO SELECT *"
::
::  from foo as-of 2 minutes ago (aliased) 
::  cross join bar as-of 2 minutes ago as (aliased)
++  test-as-of-44
  %+  expect-eq
      !>  (expected [simple-from-aliased-cross-bar [%as-of-offset 2 %minutes]])
      !>  %-  parse:parse(default-database 'db1')
              "FROM foo AS OF 2 minutes AGO F1 ".
              "cross join bar AS OF 2 minutes AGO as B1 SELECT *"
::
::  from foo as-of ~2000.1.1 (un-aliased)
++  test-as-of-45
  %+  expect-eq
      !>  (expected [simple-from [%da ~2000.1.1]])
      !>  %-  parse:parse(default-database 'db1')
              "FROM foo As Of ~2000.1.1 SELECT TOP 10 *"
::
::  from foo as-of ~2000.1.1 (aliased)
++  test-as-of-46
  %+  expect-eq
      !>  (expected [simple-from-aliased [%da ~2000.1.1]])
      !>  %-  parse:parse(default-database 'db1')
              "FROM foo As Of ~2000.1.1 F1 SELECT TOP 10 *"
::
::  from foo as-of ~2000.1.1 (aliased as)
++  test-as-of-47
  %+  expect-eq
      !>  (expected [simple-from-aliased [%da ~2000.1.1]])
      !>  %-  parse:parse(default-database 'db1')
              "FROM foo As Of ~2000.1.1 as F1 SELECT TOP 10 *"
::
::  from foo as-of ~2000.1.1 (un-aliased) 
::  join bar as-of ~2000.1.1 (un-aliased)
++  test-as-of-48
  %+  expect-eq
      !>  (expected [simple-from-join-bar [%da ~2000.1.1]])
      !>  %-  parse:parse(default-database 'db1')
              "FROM foo As Of ~2000.1.1 ".
              "join bar As Of ~2000.1.1 on 1 = 1 SELECT TOP 10 *"
::
::  from ns1.foo as-of ~2000.1.1 (un-aliased) 
::  join ns1.bar as-of ~2000.1.1 (un-aliased)
++  test-as-of-49
  %+  expect-eq
      !>  (expected [simple-from-join-bar-ns1 [%da ~2000.1.1]])
      !>  %-  parse:parse(default-database 'db1')
              "FROM ns1.foo As Of ~2000.1.1 ".
              "join ns1.bar As Of ~2000.1.1 on 1 = 1 SELECT TOP 10 *"
::
::  from db2..foo as-of ~2000.1.1 (un-aliased) 
::  join db2..bar as-of ~2000.1.1 (un-aliased)
++  test-as-of-50
  %+  expect-eq
      !>  (expected [simple-from-join-bar-db2 [%da ~2000.1.1]])
      !>  %-  parse:parse(default-database 'db1')
              "FROM db2..foo As Of ~2000.1.1 ".
              "join db2..bar As Of ~2000.1.1 on 1 = 1 SELECT TOP 10 *"
::
::  from db2.ns1.foo as-of ~2000.1.1 (un-aliased) 
::  join db2.ns1.bar as-of ~2000.1.1 (un-aliased)
++  test-as-of-51
  %+  expect-eq
      !>  (expected [simple-from-join-bar-db2-ns1 [%da ~2000.1.1]])
      !>  %-  parse:parse(default-database 'db1')
              "FROM db2.ns1.foo As Of ~2000.1.1 ".
              "join db2.ns1.bar As Of ~2000.1.1 on 1 = 1 SELECT TOP 10 *"
::
::  from ~nec.db2..foo as-of ~2000.1.1 (un-aliased) 
::  join ~nec.db2..bar as-of ~2000.1.1 (un-aliased)
++  test-as-of-52
  %+  expect-eq
      !>  (expected [simple-from-join-bar-nec-db2 [%da ~2000.1.1]])
      !>  %-  parse:parse(default-database 'db1')
              "FROM ~nec.db2..foo As Of ~2000.1.1 ".
              "join ~nec.db2..bar As Of ~2000.1.1 on 1 = 1 SELECT TOP 10 *"
::
::  from ~nec.db2.ns1.foo as-of ~2000.1.1 (un-aliased) 
::  join ~nec.db2.ns1.bar as-of ~2000.1.1 (un-aliased)
++  test-as-of-53
  %+  expect-eq
      !>  (expected [simple-from-join-bar-nec-db2-ns1 [%da ~2000.1.1]])
      !>  %-  parse:parse(default-database 'db1')
              "FROM ~nec.db2.ns1.foo As Of ~2000.1.1 ".
              "join ~nec.db2.ns1.bar As Of ~2000.1.1 on 1 = 1 SELECT TOP 10 *"
::
::  from foo as-of ~2000.1.1 (un-aliased) 
::  join bar as-of ~2000.1.1 (aliased)
++  test-as-of-54
  %+  expect-eq
      !>  (expected [simple-from-join-bar-aliased [%da ~2000.1.1]])
      !>  %-  parse:parse(default-database 'db1')
              "FROM foo As Of ~2000.1.1 ".
              "join bar As Of ~2000.1.1 B1 on 1 = 1 SELECT TOP 10 *"
::
::  from foo as-of ~2000.1.1 (un-aliased) 
::  join bar as-of ~2000.1.1 (aliased as)
++  test-as-of-55
  %+  expect-eq
      !>  (expected [simple-from-join-bar-aliased [%da ~2000.1.1]])
      !>  %-  parse:parse(default-database 'db1')
              "FROM foo As Of ~2000.1.1 ".
              "join bar As Of ~2000.1.1  as  B1 on 1 = 1 ".
              "SELECT TOP 10 *"
::
::  from foo as-of ~2000.1.1 (aliased) 
::  join bar as-of ~2000.1.1 (aliased as)
++  test-as-of-56
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
++  test-as-of-57
  %+  expect-eq
      !>  (expected [simple-from-join-bar-baz [%da ~2000.1.1]])
      !>  %-  parse:parse(default-database 'db1')
              "FROM foo As Of ~2000.1.1 ".
              "left join bar As Of ~2000.1.1 on 1 = 1 ".
              "join baz As Of ~2000.1.1 on 1 = 1 SELECT TOP 10 *"
::
::  from foo as-of ~2000.1.1 (aliased) 
::                             join bar as-of ~2000.1.1 (aliased) 
::                             left join baz as-of ~2000.1.1 (aliased)
++  test-as-of-58
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
++  test-as-of-59
  %+  expect-eq
      !>  (expected [simple-from-aliased-cross-bar [%da ~2000.1.1]])
      !>  %-  parse:parse(default-database 'db1')
              "FROM foo As Of ~2000.1.1 as F1 ".
              "cross join bar As Of ~2000.1.1 B1 SELECT *"
::
::  from ns1.foo as-of ~2000.1.1 as (aliased) 
::  cross join ns1.bar as-of ~2000.1.1 (aliased)
++  test-as-of-60
  %+  expect-eq
      !>  (expected [simple-from-aliased-cross-bar-ns1 [%da ~2000.1.1]])
      !>  %-  parse:parse(default-database 'db1')
              "FROM ns1.foo As Of ~2000.1.1 as F1 ".
              "cross join ns1.bar As Of ~2000.1.1 B1 SELECT *"
::
::  from db2..foo as-of ~2000.1.1 as (aliased) 
::  cross join db2..bar as-of ~2000.1.1 (aliased)
++  test-as-of-61
  %+  expect-eq
      !>  (expected [simple-from-aliased-cross-bar-db2 [%da ~2000.1.1]])
      !>  %-  parse:parse(default-database 'db1')
              "FROM db2..foo As Of ~2000.1.1 as F1 ".
              "cross join db2..bar As Of ~2000.1.1 B1 SELECT *"
::
::  from db2.ns1.foo as-of ~2000.1.1 as (aliased) 
::  cross join db2.ns1.bar as-of ~2000.1.1 (aliased)
++  test-as-of-62
  %+  expect-eq
      !>  (expected [simple-from-aliased-cross-bar-db2-ns1 [%da ~2000.1.1]])
      !>  %-  parse:parse(default-database 'db1')
              "FROM db2.ns1.foo As Of ~2000.1.1 as F1 ".
              "cross join db2.ns1.bar As Of ~2000.1.1 B1 SELECT *"
::
::  from ~nec.db2..foo as-of ~2000.1.1 as (aliased) 
::  cross join ~nec.db2..bar as-of ~2000.1.1 (aliased)
++  test-as-of-63
  %+  expect-eq
      !>  (expected [simple-from-aliased-cross-bar-nec-db2 [%da ~2000.1.1]])
      !>  %-  parse:parse(default-database 'db1')
              "FROM ~nec.db2..foo As Of ~2000.1.1 as F1 ".
              "cross join ~nec.db2..bar As Of ~2000.1.1 B1 SELECT *"
::
::  from ~nec.db2.ns1.foo as-of ~2000.1.1 as (aliased) 
::  cross join ~nec.db2.ns1.bar as-of ~2000.1.1 (aliased)
++  test-as-of-64
  %+  expect-eq
      !>  (expected [simple-from-aliased-cross-bar-nec-db2-ns1 [%da ~2000.1.1]])
      !>  %-  parse:parse(default-database 'db1')
              "FROM ~nec.db2.ns1.foo As Of ~2000.1.1 as F1 ".
              "cross join ~nec.db2.ns1.bar As Of ~2000.1.1 B1 SELECT *"
::
::  from foo as-of ~2000.1.1 cross join bar as-of ~2000.1.1
++  test-as-of-65
  %+  expect-eq
      !>  (expected [simple-from-cross-join-bar [%da ~2000.1.1]])
      !>  %-  parse:parse(default-database 'db1')
              "FROM foo As Of ~2000.1.1 cross join bar As Of ~2000.1.1 SELECT *"
::
::  from foo as-of ~2000.1.1 (aliased) 
::  cross join bar as-of ~2000.1.1 as (aliased)
++  test-as-of-66
  %+  expect-eq
      !>  (expected [simple-from-aliased-cross-bar [%da ~2000.1.1]])
      !>  %-  parse:parse(default-database 'db1')
              "FROM foo As Of ~2000.1.1 F1 ".
              "cross join bar As Of ~2000.1.1 as B1 SELECT *"
::
::  from foo as-of ~h5.m30.s12 (un-aliased)
++  test-as-of-67
  %+  expect-eq
      !>  (expected [simple-from [%dr ~h5.m30.s12]])
      !>  %-  parse:parse(default-database 'db1')
              "FROM foo As Of ~h5.m30.s12 SELECT TOP 10 *"
::
::  from foo as-of ~h5.m30.s12 (aliased)
++  test-as-of-68
  %+  expect-eq
      !>  (expected [simple-from-aliased [%dr ~h5.m30.s12]])
      !>  %-  parse:parse(default-database 'db1')
              "FROM foo As Of ~h5.m30.s12 F1 SELECT TOP 10 *"
::
::  from foo as-of ~h5.m30.s12 (aliased as)
++  test-as-of-69
  %+  expect-eq
      !>  (expected [simple-from-aliased [%dr ~h5.m30.s12]])
      !>  %-  parse:parse(default-database 'db1')
              "FROM foo As Of ~h5.m30.s12 as F1 SELECT TOP 10 *"
::
::  from foo as-of ~h5.m30.s12 (un-aliased) 
::  join bar as-of ~h5.m30.s12 (un-aliased)
++  test-as-of-70
  %+  expect-eq
      !>  (expected [simple-from-join-bar [%dr ~h5.m30.s12]])
      !>  %-  parse:parse(default-database 'db1')
              "FROM foo As Of ~h5.m30.s12 ".
              "join bar As Of ~h5.m30.s12 on 1 = 1 SELECT TOP 10 *"
::
::  from foo as-of ~h5.m30.s12 (un-aliased) 
::  join bar as-of ~h5.m30.s12 (aliased)
++  test-as-of-71
  %+  expect-eq
      !>  (expected [simple-from-join-bar-aliased [%dr ~h5.m30.s12]])
      !>  %-  parse:parse(default-database 'db1')
              "FROM foo As Of ~h5.m30.s12 ".
              "join bar As Of ~h5.m30.s12 B1 on 1 = 1 SELECT TOP 10 *"
::
::  from foo as-of ~h5.m30.s12 (un-aliased) 
::  join bar as-of ~h5.m30.s12 (aliased as)
++  test-as-of-72
  %+  expect-eq
      !>  (expected [simple-from-join-bar-aliased [%dr ~h5.m30.s12]])
      !>  %-  parse:parse(default-database 'db1')
              "FROM foo As Of ~h5.m30.s12 ".
              "join bar As Of ~h5.m30.s12  as  B1 on 1 = 1 ".
              "SELECT TOP 10 *"
::
::  from foo as-of ~h5.m30.s12 (aliased) 
::  join bar as-of ~h5.m30.s12 (aliased as)
++  test-as-of-73
  %+  expect-eq
      !>  %-  expected
              [simple-from-aliased-join-bar-aliased [%dr ~h5.m30.s12]]
      !>  %-  parse:parse(default-database 'db1')
              "FROM foo As Of ~h5.m30.s12 F1 join bar As Of ~h5.m30.s12 B1 ".
              "on 1 = 1 SELECT TOP 10 *"
::
::  from foo as-of ~h5.m30.s12 (un-aliased) 
::                             join bar as-of ~h5.m30.s12 (un-aliased)
::                             left join baz as-of ~h5.m30.s12 (un-aliased)
++  test-as-of-74
  %+  expect-eq
      !>  (expected [simple-from-join-bar-baz [%dr ~h5.m30.s12]])
      !>  %-  parse:parse(default-database 'db1')
              "FROM foo As Of ~h5.m30.s12 ".
              "left join bar As Of ~h5.m30.s12 on 1 = 1 ".
              "join baz As Of ~h5.m30.s12 on 1 = 1 SELECT TOP 10 *"
::
::  from foo as-of ~h5.m30.s12 (aliased) 
::                             join bar as-of ~h5.m30.s12 (aliased) 
::                             left join baz as-of ~h5.m30.s12 (aliased)
++  test-as-of-75
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
++  test-as-of-76
  %+  expect-eq
      !>  (expected [simple-from-aliased-cross-bar [%dr ~h5.m30.s12]])
      !>  %-  parse:parse(default-database 'db1')
              "FROM foo As Of ~h5.m30.s12 as F1 ".
              "cross join bar As Of ~h5.m30.s12 B1 SELECT *"
::
::  from foo as-of ~h5.m30.s12 cross join bar as-of ~h5.m30.s12
++  test-as-of-77
  %+  expect-eq
      !>  (expected [simple-from-cross-join-bar [%dr ~h5.m30.s12]])
      !>  %-  parse:parse(default-database 'db1')
              "FROM foo As Of ~h5.m30.s12 ".
              "cross join bar As Of ~h5.m30.s12 SELECT *"
::
::  from foo as-of ~h5.m30.s12 (aliased) 
::  cross join bar as-of ~h5.m30.s12 as (aliased)
++  test-as-of-78
  %+  expect-eq
      !>  (expected [simple-from-aliased-cross-bar [%dr ~h5.m30.s12]])
      !>  %-  parse:parse(default-database 'db1')
            "FROM foo As Of ~h5.m30.s12 F1 ".
            "cross join bar As Of ~h5.m30.s12 as B1 SELECT *"
::
::  natural joins
::
::  (natural join) from foo %now (un-aliased) join bar %now (un-aliased)
++  test-as-of-79
  %+  expect-eq
      !>  (expected [natural-from-join-bar [%as-of-offset 0 %seconds]])
      !>  %-  parse:parse(default-database 'db1')
            "FROM foo AS OF NOW join bar AS OF NOW SELECT *"
::
::  (natural join) from foo %now (un-aliased) join bar %now (aliased)
++  test-as-of-80
  %+  expect-eq
      !>  (expected [natural-from-join-bar-aliased [%as-of-offset 0 %seconds]])
      !>  %-  parse:parse(default-database 'db1')
            "FROM foo AS OF NOW join bar AS OF NOW B1 SELECT *"
::
::  (natural join) from foo %now (un-aliased) join bar %now (aliased as)
++  test-as-of-81
  %+  expect-eq
      !>  (expected [natural-from-join-bar-aliased [%as-of-offset 0 %seconds]])
      !>  %-  parse:parse(default-database 'db1')
            "FROM foo AS OF NOW join bar AS OF NOW as B1 SELECT *"
::
::  (natural join) from foo %now (aliased) join bar %now (aliased as)
++  test-as-of-82
  %+  expect-eq
      !>  %-  expected
              [natural-from-aliased-join-bar-aliased [%as-of-offset 0 %seconds]]
      !>  %-  parse:parse(default-database 'db1')
            "FROM foo AS OF NOW F1 join bar AS OF NOW B1 SELECT *"
::
::  (natural join) from foo as-of 2 minutes ago (un-aliased) 
::                 join bar as-of 2 minutes ago (un-aliased)
++  test-as-of-83
  %+  expect-eq
      !>  (expected [natural-from-join-bar [%as-of-offset 2 %minutes]])
      !>  %-  parse:parse(default-database 'db1')
            "FROM foo AS OF 2 minutes AGO join bar AS OF 2 minutes AGO SELECT *"
::
::  (natural join) from foo as-of 2 minutes ago (un-aliased) 
::                 join bar as-of 2 minutes ago (aliased)
++  test-as-of-84
  %+  expect-eq
      !>  (expected [natural-from-join-bar-aliased [%as-of-offset 2 %minutes]])
      !>  %-  parse:parse(default-database 'db1')
         "FROM foo AS OF 2 minutes AGO join bar AS OF 2 minutes AGO B1 SELECT *"
::
::  (natural join) from foo as-of 2 minutes ago (un-aliased) 
::                 join bar as-of 2 minutes ago (aliased as)
++  test-as-of-85
  %+  expect-eq
      !>  (expected [natural-from-join-bar-aliased [%as-of-offset 2 %minutes]])
      !>  %-  parse:parse(default-database 'db1')
      "FROM foo AS OF 2 minutes AGO join bar AS OF 2 minutes AGO as B1 SELECT *"
::
::  (natural join) from foo as-of 2 minutes ago (aliased) 
::                 join bar as-of 2 minutes ago (aliased as)
++  test-as-of-86
  %+  expect-eq
      !>  %-  expected
              [natural-from-aliased-join-bar-aliased [%as-of-offset 2 %minutes]]
      !>  %-  parse:parse(default-database 'db1')
      "FROM foo AS OF 2 minutes AGO F1 join bar AS OF 2 minutes AGO B1 SELECT *"
::
::  (natural join) from foo as-of ~2000.1.1 (un-aliased) 
::                 join bar as-of ~2000.1.1 (un-aliased)
++  test-as-of-87
  %+  expect-eq
      !>  (expected [natural-from-join-bar [%da ~2000.1.1]])
      !>  %-  parse:parse(default-database 'db1')
            "FROM foo AS OF ~2000.1.1 join bar AS OF ~2000.1.1 SELECT *"
::
::  (natural join) from foo as-of ~2000.1.1 (un-aliased) 
::                 join bar as-of ~2000.1.1 (aliased)
++  test-as-of-88
  %+  expect-eq
      !>  (expected [natural-from-join-bar-aliased [%da ~2000.1.1]])
      !>  %-  parse:parse(default-database 'db1')
            "FROM foo AS OF ~2000.1.1 join bar AS OF ~2000.1.1 B1 SELECT *"
::
::  (natural join) from foo as-of ~2000.1.1 (un-aliased) 
::                 join bar as-of ~2000.1.1 (aliased as)
++  test-as-of-89
  %+  expect-eq
      !>  (expected [natural-from-join-bar-aliased [%da ~2000.1.1]])
      !>  %-  parse:parse(default-database 'db1')
            "FROM foo AS OF ~2000.1.1 join bar AS OF ~2000.1.1 as B1 SELECT *"
::
::  (natural join) from foo as-of ~2000.1.1 (aliased) 
::                 join bar as-of ~2000.1.1 (aliased as)
++  test-as-of-90
  %+  expect-eq
      !>  %-  expected
              [natural-from-aliased-join-bar-aliased [%da ~2000.1.1]]
      !>  %-  parse:parse(default-database 'db1')
            "FROM foo AS OF ~2000.1.1 F1 join bar AS OF ~2000.1.1 B1 SELECT *"
::
::  (natural join) from foo as-of ~h5.m30.s12 (un-aliased) 
::                 join bar as-of ~h5.m30.s12 (un-aliased)
++  test-as-of-91
  %+  expect-eq
      !>  (expected [natural-from-join-bar [%dr ~h5.m30.s12]])
      !>  %-  parse:parse(default-database 'db1')
            "FROM foo AS OF ~h5.m30.s12 join bar AS OF ~h5.m30.s12 SELECT *"
::
::  (natural join) from foo as-of ~h5.m30.s12 (un-aliased) 
::                 join bar as-of ~h5.m30.s12 (aliased)
++  test-as-of-92
  %+  expect-eq
      !>  (expected [natural-from-join-bar-aliased [%dr ~h5.m30.s12]])
      !>  %-  parse:parse(default-database 'db1')
            "FROM foo AS OF ~h5.m30.s12 join bar AS OF ~h5.m30.s12 B1 SELECT *"
::
::  (natural join) from foo as-of ~h5.m30.s12 (un-aliased) 
::                 join bar as-of ~h5.m30.s12 (aliased as)
++  test-as-of-93
  %+  expect-eq
      !>  (expected [natural-from-join-bar-aliased [%dr ~h5.m30.s12]])
      !>  %-  parse:parse(default-database 'db1')
          "FROM foo AS OF ~h5.m30.s12 join bar AS OF ~h5.m30.s12 as B1 SELECT *"
::
::  (natural join) from foo as-of ~h5.m30.s12 (aliased) 
::                 join bar as-of ~h5.m30.s12 (aliased as)
++  test-as-of-94
  %+  expect-eq
      !>  %-  expected
              [natural-from-aliased-join-bar-aliased [%dr ~h5.m30.s12]]
      !>  %-  parse:parse(default-database 'db1')
          "FROM foo AS OF ~h5.m30.s12 F1 join bar AS OF ~h5.m30.s12 B1 SELECT *"
::
::  complex join
++  test-as-of-95
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
