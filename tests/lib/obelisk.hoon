::  unit tests on %obelisk library simulating pokes
::
/-  ast, *obelisk
/+  *test, *obelisk, parse
/=  agent  /app/obelisk
|%
::
::  Build an example bowl manually.
++  bowl
  |=  [run=@ud now=@da]
  ^-  bowl:gall
  :*  [~zod ~zod %obelisk `path`(limo `path`/test-agent)] :: (our src dap sap)
      [~ ~ ~]                                             :: (wex sup sky)
      [run `@uvJ`(shax run) now [~zod %base ud+run]]      :: (act eny now byk)
  ==
::
::  Build a reference state mold.
+$  state
  $:  %0
      =databases
      ==
--
|%
::
::  Set TMSP
::
::  set-tmsp back 0 seconds
++  test-set-tmsp-00
  %+  expect-eq
    !>  ~2023.12.25..7.15.0..1ef5
    !>  %-  set-tmsp
            :-  `(as-of-offset:ast %as-of-offset 0 %seconds)
                ~2023.12.25..7.15.0..1ef5
::
::  set-tmsp back 65 seconds
++  test-set-tmsp-01
  %+  expect-eq
    !>  ~2023.12.25..7.13.55..1ef5
    !>  %-  set-tmsp
          :-  `(as-of-offset:ast %as-of-offset 65 %seconds)
              ~2023.12.25..7.15.0..1ef5
::
::  set-tmsp back 0 minutes
++  test-set-tmsp-02
  %+  expect-eq
    !>  ~2023.12.25..7.15.0..1ef5
    !>  %-  set-tmsp
            :-  `(as-of-offset:ast %as-of-offset 0 %minutes)
                ~2023.12.25..7.15.0..1ef5
::
::  set-tmsp back 65 minutes
++  test-set-tmsp-03
  %+  expect-eq
    !>  ~2023.12.25..6.10.0..1ef5
    !>  %-  set-tmsp
            :-  `(as-of-offset:ast %as-of-offset 65 %minutes)
                ~2023.12.25..7.15.0..1ef5
::
::  set-tmsp back 0 hours
++  test-set-tmsp-04
  %+  expect-eq
    !>  ~2023.12.25..7.15.0..1ef5
    !>  %-  set-tmsp
            :-  `(as-of-offset:ast %as-of-offset 0 %hours)
                ~2023.12.25..7.15.0..1ef5
::
::  set-tmsp back 65 hours
++  test-set-tmsp-05
  %+  expect-eq
    !>  ~2023.12.22..14.15.0..1ef5
    !>  %-  set-tmsp
            :-  `(as-of-offset:ast %as-of-offset 65 %hours)
                ~2023.12.25..7.15.0..1ef5
::
::  set-tmsp back 0 days
++  test-set-tmsp-06
  %+  expect-eq
    !>  ~2023.12.25..7.15.0..1ef5
    !>  %-  set-tmsp
            :-  `(as-of-offset:ast %as-of-offset 0 %days)
                ~2023.12.25..7.15.0..1ef5
::
::  set-tmsp back 65 days
++  test-set-tmsp-07
  %+  expect-eq
    !>  ~2023.10.21..7.15.0..1ef5
    !>  %-  set-tmsp
            :-  `(as-of-offset:ast %as-of-offset 65 %days)
                ~2023.12.25..7.15.0..1ef5
::
::  set-tmsp back 0 weeks
++  test-set-tmsp-08
  %+  expect-eq
    !>  ~2023.12.25..7.15.0..1ef5
    !>  %-  set-tmsp
            :-  `(as-of-offset:ast %as-of-offset 0 %weeks)
                ~2023.12.25..7.15.0..1ef5
::
::  set-tmsp back 65 weeks
++  test-set-tmsp-09
  %+  expect-eq
    !>  ~2022.9.26..7.15.0..1ef5
    !>  %-  set-tmsp
            :-  `(as-of-offset:ast %as-of-offset 65 %weeks)
                ~2023.12.25..7.15.0..1ef5
::
::  set-tmsp leap year
++  test-set-tmsp-10
  %+  expect-eq
    !>  ~2020.2.27..7.15.0..1ef5
    !>  %-  set-tmsp
            :-  `(as-of-offset:ast %as-of-offset 7 %days)
                ~2020.3.5..7.15.0..1ef5
::
::  set-tmsp back 0 months
++  test-set-tmsp-11
  %+  expect-eq
    !>  ~2023.12.25..7.15.0..1ef5
    !>  %-  set-tmsp
            :-  `(as-of-offset:ast %as-of-offset 0 %months)
                ~2023.12.25..7.15.0..1ef5
::
::  set-tmsp back 65 months
++  test-set-tmsp-12
  %+  expect-eq
    !>  ~2018.7.25..7.15.0..1ef5
    !>  %-  set-tmsp
            :-  `(as-of-offset:ast %as-of-offset 65 %months)
                ~2023.12.25..7.15.0..1ef5
::
::  set-tmsp back 3 months
++  test-set-tmsp-13
  %+  expect-eq
    !>  ~2019.12.5..7.15.0..1ef5
    !>  %-  set-tmsp
            :-  `(as-of-offset:ast %as-of-offset 3 %months)
                ~2020.3.5..7.15.0..1ef5
::
::  set-tmsp back 2 months
++  test-set-tmsp-14
  %+  expect-eq
    !>  ~2020.1.5..7.15.0..1ef5
    !>  %-  set-tmsp
            :-  `(as-of-offset:ast %as-of-offset 2 %months)
                ~2020.3.5..7.15.0..1ef5
::
::  set-tmsp back 0 years
++  test-set-tmsp-15
  %+  expect-eq
    !>  ~2023.12.25..7.15.0..1ef5
    !>  %-  set-tmsp
            :-  `(as-of-offset:ast %as-of-offset 0 %years)
                ~2023.12.25..7.15.0..1ef5
::
::  set-tmsp back 65 years
++  test-set-tmsp-16
  %+  expect-eq
    !>  ~1958.12.25..7.15.0..1ef5
    !>  %-  set-tmsp
            :-  `(as-of-offset:ast %as-of-offset 65 %years)
                ~2023.12.25..7.15.0..1ef5
::
::  set-tmsp to ~1962.2.2..7.15.0..1ef5
++  test-set-tmsp-17
  %+  expect-eq
    !>  ~1962.2.2..7.15.0..1ef5
    !>  (set-tmsp [`[%da ~1962.2.2..7.15.0..1ef5] ~2023.12.25..7.15.0..1ef5])
::
::  set-tmsp back ~s65
++  test-set-tmsp-18
  %+  expect-eq
    !>  ~2023.12.25..7.13.55..1ef5
    !>  (set-tmsp [`[%dr ~s65] ~2023.12.25..7.15.0..1ef5])
::
::  set-tmsp back ~m65
++  test-set-tmsp-19
  %+  expect-eq
    !>  ~2023.12.25..6.10.0..1ef5
    !>  (set-tmsp [`[%dr ~m65] ~2023.12.25..7.15.0..1ef5])
::
::  set-tmsp back ~m65.s65
++  test-set-tmsp-20
  %+  expect-eq
    !>  ~2023.12.25..6.8.55..1ef5
    !>  (set-tmsp [`[%dr ~m65.s65] ~2023.12.25..7.15.0..1ef5])
::
::  set-tmsp back ~h2.m12.s5
++  test-set-tmsp-21
  %+  expect-eq
    !>  ~2023.12.25..5.2.55..1ef5
    !>  (set-tmsp [`[%dr ~h2.m12.s5] ~2023.12.25..7.15.0..1ef5])
::
::  set-tmsp back ~d5.h2.m12.s5
++  test-set-tmsp-22
  %+  expect-eq
    !>  ~2023.12.20..5.2.55..1ef5
    !>  (set-tmsp [`[%dr ~d5.h2.m12.s5] ~2023.12.25..7.15.0..1ef5])
::
::  set-tmsp back ~s0
++  test-set-tmsp-23
  %+  expect-eq
    !>  ~2023.12.25..7.15.0..1ef5
    !>  (set-tmsp [`[%dr ~s0] ~2023.12.25..7.15.0..1ef5])
::
::  set-tmsp back ~d0.h0.m0.s0
++  test-set-tmsp-24
  %+  expect-eq
    !>  ~2023.12.25..7.15.0..1ef5
    !>  (set-tmsp [`[%dr ~d0.h0.m0.s0] ~2023.12.25..7.15.0..1ef5])
::
::  CREATE DATABASE
::
::  fail duplicate database
++  test-fail-create-database-01
  =|  run=@ud
  =^  move  agent
    %:  ~(on-poke agent (bowl [run ~2000.1.1]))
        %obelisk-action
        !>([%tape-create-db "CREATE DATABASE db1"])
    ==
  ::
  %+  expect-fail-message
        'database %db1 already exists'
  |.  %:  ~(on-poke agent (bowl [run ~2000.1.2]))
          %obelisk-action
          !>([%tape-create-db "CREATE DATABASE db1"])
    ==
::
::  CREATE NAMESPACE
::
::  fail on duplicate namepsace
++  test-fail-create-namespace-01
  =|  run=@ud
  =^  mov1  agent
    %:  ~(on-poke agent (bowl [run ~2000.1.1]))
        %obelisk-action
        !>([%cmd-create-db [%create-database 'db1' ~]])
    ==
  =.  run  +(run)
  =^  mov2  agent
    %:  ~(on-poke agent (bowl [run ~2000.1.2]))
        %obelisk-action
        !>([%commands ~[[%create-namespace %db1 %ns1 ~]]])
    ==
  =.  run  +(run)
  ::
  %+  expect-fail-message
        'namespace %ns1 already exists'
  |.  %:  ~(on-poke agent (bowl [run ~2000.1.3]))
      %obelisk-action
      !>([%commands ~[[%create-namespace %db1 %ns1 ~]]])
    ==
::
::  fail on database does not exist
++  test-fail-create-namespace-02
  =|  run=@ud
  =^  mov1  agent
    %:  ~(on-poke agent (bowl [run ~2000.1.1]))
        %obelisk-action
        !>([%cmd-create-db [%create-database 'db1' ~]])
    ==
  =.  run  +(run)
  ::
  %+  expect-fail-message
        'database %db2 does not exist'
  |.  %:  ~(on-poke agent (bowl [run ~2000.1.3]))
      %obelisk-action
      !>([%commands ~[[%create-namespace %db2 %ns1 ~]]])
    ==
:: fail on time, create ns = schema
++  test-fail-create-namespace-03
  =|  run=@ud
  =^  mov1  agent
    %:  ~(on-poke agent (bowl [run ~2000.1.1]))
        %obelisk-action
        !>  :-  %tape-create-db
                "CREATE DATABASE db1 as of ~2023.7.9..22.35.35..7e90"
    ==
  =.  run  +(run)
  ::
  %+  expect-fail-message
        'namespace %ns1 as-of schema time out of order'
  |.  %:  ~(on-poke agent (bowl [run ~2000.1.2]))
      %obelisk-action
      !>  :+  %tape
              %db1
              "CREATE NAMESPACE ns1 as of ~2023.7.9..22.35.35..7e90"
    ==
::
:: fail on time, create ns lt schema
++  test-fail-create-namespace-04
  =|  run=@ud
  =^  mov1  agent
    %:  ~(on-poke agent (bowl [run ~2000.1.1]))
        %obelisk-action
        !>  :-  %tape-create-db
                "CREATE DATABASE db1 as of ~2023.7.9..22.35.35..7e90"
    ==
  =.  run  +(run)
  ::
  %+  expect-fail-message
        'namespace %ns1 as-of schema time out of order'
  |.  %:  ~(on-poke agent (bowl [run ~2000.1.2]))
      %obelisk-action
      !>  :+  %tape
              %db1
              "CREATE NAMESPACE ns1 as of ~2023.7.9..22.35.34..7e90"
    ==
::
::  fail on time, create ns = content
++  test-fail-create-namespace-05
  =|  run=@ud
  =^  mov1  agent
    %:  ~(on-poke agent (bowl [run ~2000.1.1]))
        %obelisk-action
        !>([%tape-create-db "CREATE DATABASE db1"])
    ==
  =.  run  +(run)
  =^  mov2  agent
    %:  ~(on-poke agent (bowl [run ~2000.1.2]))
        %obelisk-action
        !>  :+  %tape
                %db1
                "CREATE TABLE db1..my-table (col1 @t) PRIMARY KEY (col1)"
    ==
  =.  run  +(run)
  =^  mov3  agent
    %:  ~(on-poke agent (bowl [run ~2023.7.9..22.35.35..7e90]))
        %obelisk-action
        !>  :+  %tape
                %db1
                "INSERT INTO db1..my-table (col1) VALUES ('cord') ".
                "AS OF ~2023.7.9..22.35.35..7e90"
    ==
  =.  run  +(run)
  ::
  %+  expect-fail-message
        'namespace %ns1 as-of content time out of order'
  |.  %:  ~(on-poke agent (bowl [run ~2000.1.2]))
      %obelisk-action
      !>  :+  %tape
              %db1
              "CREATE NAMESPACE ns1 as of ~2023.7.9..22.35.35..7e90"
    ==
::
::  fail on time, create ns lt content
++  test-fail-create-namespace-06
  =|  run=@ud
  =^  mov1  agent
    %:  ~(on-poke agent (bowl [run ~2000.1.1]))
        %obelisk-action
        !>([%tape-create-db "CREATE DATABASE db1"])
    ==
  =.  run  +(run)
  =^  mov2  agent
    %:  ~(on-poke agent (bowl [run ~2000.1.2]))
        %obelisk-action
        !>  :+  %tape
                %db1
                "CREATE TABLE db1..my-table (col1 @t) PRIMARY KEY (col1)"
    ==
  =.  run  +(run)
  =^  mov3  agent
    %:  ~(on-poke agent (bowl [run ~2023.7.9..22.35.35..7e90]))
        %obelisk-action
        !>  :+  %tape
                %db1
                "INSERT INTO db1..my-table (col1) VALUES ('cord') ".
                "AS OF ~2023.7.9..22.35.35..7e90"
    ==
  =.  run  +(run)
  ::
  %+  expect-fail-message
        'namespace %ns1 as-of content time out of order'
  |.  %:  ~(on-poke agent (bowl [run ~2000.1.2]))
      %obelisk-action
      !>  :+  %tape
              %db1
              "CREATE NAMESPACE ns1 as of ~2023.7.9..22.35.34..7e90"
    ==
::
::  CREATE TABLE
::  fail on database does not exist
++  test-fail-create-table-01
  =|  run=@ud
  =/  cmd
    :*  %create-table
        [%qualified-object ship=~ database='db' namespace='dbo' name='my-table']
        :~  [%column name='col1' column-type=%t]
            [%column name='col2' column-type=%p]
            [%column name='col3' column-type=%ud]
        ==
        clustered=%.n
        pri-indx=~[[%ordered-column column-name='col1' ascending=%.y]]
        foreign-keys=~
        as-of=~
    ==
  =^  mov1  agent
    %:  ~(on-poke agent (bowl [run ~2000.1.1]))
        %obelisk-action
        !>([%cmd-create-db [%create-database 'db1' ~]])
    ==
  =.  run  +(run)
  ::
  %+  expect-fail-message
        'database %db does not exist'
  |.  %:  ~(on-poke agent (bowl [run ~2000.1.4]))
      %obelisk-action
      !>([%commands ~[cmd]])
    ==
::
::  fail on namespace does not exist
++  test-fail-create-table-02
  =|  run=@ud
  =/  cmd
    :*  %create-table
        :*  %qualified-object
            ship=~
            database='db1'
            namespace='ns1'
            name='my-table'
        ==
        :~  [%column name='col1' column-type=%t]
            [%column name='col2' column-type=%p]
            [%column name='col3' column-type=%ud]
        ==
        clustered=%.n
        pri-indx=~[[%ordered-column column-name='col1' ascending=%.y]]
        foreign-keys=~
        as-of=~
    ==
  =^  mov1  agent
    %:  ~(on-poke agent (bowl [run ~2000.1.1]))
        %obelisk-action
        !>([%cmd-create-db [%create-database 'db1' ~]])
    ==
  =.  run  +(run)
  ::
  %+  expect-fail-message
        'namespace %ns1 does not exist'
  |.  %:  ~(on-poke agent (bowl [run ~2000.1.4]))
      %obelisk-action
      !>([%commands ~[cmd]])
    ==
::
::  fail on duplicate table name
++  test-fail-create-table-03
  =|  run=@ud
  =/  cmd
    :*  %create-table
        :*  %qualified-object
            ship=~
            database='db1'
            namespace='dbo'
            name='my-table'
        ==
        :~  [%column name='col1' column-type=%t]
            [%column name='col2' column-type=%p]
            [%column name='col3' column-type=%ud]
        ==
        clustered=%.n
        pri-indx=~[[%ordered-column column-name='col1' ascending=%.y]]
        foreign-keys=~
        as-of=~
    ==
  =^  mov1  agent
    %:  ~(on-poke agent (bowl [run ~2000.1.1]))
        %obelisk-action
        !>([%cmd-create-db [%create-database 'db1' ~]])
    ==
  =.  run  +(run)
  =^  mov2  agent
    %:  ~(on-poke agent (bowl [run ~2000.1.2]))
        %obelisk-action
        !>([%commands ~[cmd]])
    ==
  =.  run  +(run)
  ::
  %+  expect-fail-message
        '%my-table exists in %dbo'
  |.  %:  ~(on-poke agent (bowl [run ~2000.1.4]))
      %obelisk-action
      !>([%commands ~[cmd]])
    ==
::
::  fail on duplicate column names
++  test-fail-create-table-04
  =|  run=@ud
  =/  cmd
    :*  %create-table
        :*  %qualified-object
            ship=~
            database='db1'
            namespace='dbo'
            name='my-table'
        ==
        :~  [%column name='col1' column-type=%t]
            [%column name='col2' column-type=%p]
            [%column name='col1' column-type=%t]
        ==
        clustered=%.n
        pri-indx=~[[%ordered-column column-name='col1' ascending=%.y]]
        foreign-keys=~
        as-of=~
    ==
  =^  mov1  agent
    %:  ~(on-poke agent (bowl [run ~2000.1.1]))
        %obelisk-action
        !>([%cmd-create-db [%create-database 'db1' ~]])
    ==
  =.  run  +(run)
  ::
  %+  expect-fail-message
        'duplicate column names ~[[%column name=%col1 type=~.t] [%column name=%col2 type=~.p] [%column name=%col1 type=~.t]]'
  |.  %:  ~(on-poke agent (bowl [run ~2000.1.4]))
      %obelisk-action
      !>([%commands ~[cmd]])
    ==
::
::  fail on time, create table = content
++  test-fail-create-table-05
  =|  run=@ud
  =^  mov1  agent
    %:  ~(on-poke agent (bowl [run ~2000.1.1]))
        %obelisk-action
        !>([%tape-create-db "CREATE DATABASE db1"])
    ==
  =.  run  +(run)
  =^  mov2  agent
    %:  ~(on-poke agent (bowl [run ~2000.1.2]))
        %obelisk-action
        !>  :+  %tape
                %db1
                "CREATE TABLE db1..my-table (col1 @t) PRIMARY KEY (col1)"
    ==
  =.  run  +(run)
  =^  mov3  agent
    %:  ~(on-poke agent (bowl [run ~2023.7.9..22.35.35..7e90]))
        %obelisk-action
        !>  :+  %tape
                %db1
                "INSERT INTO db1..my-table (col1) VALUES ('cord') ".
                "AS OF ~2023.7.9..22.35.35..7e90"
    ==
  =.  run  +(run)
  ::
  %+  expect-fail-message
        'table %my-table-2 as-of data time out of order'
  |.  %:  ~(on-poke agent (bowl [run ~2000.1.2]))
      %obelisk-action
      !>  :+  %tape
              %db1
              "CREATE TABLE db1..my-table-2 (col1 @t) PRIMARY KEY (col1) ".
              "AS OF ~2023.7.9..22.35.35..7e90"
    ==
::
::  fail on time, create table < content
++  test-fail-create-table-06
  =|  run=@ud
  =^  mov1  agent
    %:  ~(on-poke agent (bowl [run ~2000.1.1]))
        %obelisk-action
        !>([%tape-create-db "CREATE DATABASE db1"])
    ==
  =.  run  +(run)
  =^  mov2  agent
    %:  ~(on-poke agent (bowl [run ~2000.1.2]))
        %obelisk-action
        !>  :+  %tape
                %db1
                "CREATE TABLE db1..my-table (col1 @t) PRIMARY KEY (col1)"
    ==
  =.  run  +(run)
  =^  mov3  agent
    %:  ~(on-poke agent (bowl [run ~2023.7.9..22.35.35..7e90]))
        %obelisk-action
        !>  :+  %tape
                %db1
                "INSERT INTO db1..my-table (col1) VALUES ('cord') ".
                "AS OF ~2023.7.9..22.35.35..7e90"
    ==
  =.  run  +(run)
  ::
  %+  expect-fail-message
        'table %my-table-2 as-of data time out of order'
  |.  %:  ~(on-poke agent (bowl [run ~2000.1.2]))
      %obelisk-action
      !>  :+  %tape
              %db1
              "CREATE TABLE db1..my-table-2 (col1 @t) PRIMARY KEY (col1) ".
              "AS OF ~2023.7.9..22.35.35..7e90"
    ==
::
::  fail on time, create table = schema
++  test-fail-create-table-07
  =|  run=@ud
  =^  mov1  agent
    %:  ~(on-poke agent (bowl [run ~2000.1.1]))
        %obelisk-action
        !>  :-  %tape-create-db
                "CREATE DATABASE db1 as of ~2023.7.9..22.35.35..7e90"
    ==
  =.  run  +(run)
  ::
  %+  expect-fail-message
        'table %my-table-2 as-of schema time out of order'
  |.  %:  ~(on-poke agent (bowl [run ~2000.1.2]))
      %obelisk-action
      !>  :+  %tape
              %db1
              "CREATE TABLE db1..my-table-2 (col1 @t, col2 @p) ".
              "PRIMARY KEY (col1, col2) ".
              "as of ~2023.7.9..22.35.35..7e90"
    ==
::
::  fail on time, create table lt schema
++  test-fail-create-table-08
  =|  run=@ud
  =^  mov1  agent
    %:  ~(on-poke agent (bowl [run ~2000.1.1]))
        %obelisk-action
        !>  :-  %tape-create-db
                "CREATE DATABASE db1 as of ~2023.7.9..22.35.35..7e90"
    ==
  =.  run  +(run)
  ::
  %+  expect-fail-message
        'table %my-table-2 as-of schema time out of order'
  |.  %:  ~(on-poke agent (bowl [run ~2000.1.2]))
      %obelisk-action
      !>  :+  %tape
              %db1
              "CREATE TABLE db1..my-table-2 (col1 @t, col2 @p) ".
                "PRIMARY KEY (col1, col2) ".
                "as of ~2023.7.9..22.35.34..7e90"
    ==
::
::  fail on key column not in column definitions
++  test-fail-create-table-09
  =|  run=@ud
  =/  cmd
    :*  %create-table
        :*  %qualified-object
            ship=~
            database='db1'
            namespace='dbo'
            name='my-table'
        ==
        :~  [%column name='col1' column-type=%t]
            [%column name='col2' column-type=%p]
            [%column name='col3' column-type=%ud]
        ==
        clustered=%.n
        :~  [%ordered-column column-name='col1' ascending=%.y]
            [%ordered-column column-name='col4' ascending=%.y]
        ==
        foreign-keys=~
        as-of=~
    ==
  =^  mov1  agent
    %:  ~(on-poke agent (bowl [run ~2000.1.1]))
        %obelisk-action
        !>([%cmd-create-db [%create-database 'db1' ~]])
    ==
  =.  run  +(run)
  ::
  %+  expect-fail-message
        'key column not in column definitions ~[[%ordered-column name=%col1 ascending=%.y] [%ordered-column name=%col4 ascending=%.y]]'
  |.  %:  ~(on-poke agent (bowl [run ~2000.1.2]))
          %obelisk-action
          !>([%commands ~[cmd]])
    ==
::
::  Drop table
::
::  fail on time, drop table = schema
++  test-fail-drop-table-01
  =|  run=@ud
  =^  mov1  agent
    %:  ~(on-poke agent (bowl [run ~2000.1.1]))
        %obelisk-action
        !>  :-  %tape-create-db
                "CREATE DATABASE db1 as of ~2023.7.9..22.35.35..7e90"
    ==
  =.  run  +(run)
  =^  mov2  agent
    %:  ~(on-poke agent (bowl [run ~2000.1.2]))
        %obelisk-action
        !>  :+  %tape
                %db1
                "CREATE TABLE db1..my-table-2 (col1 @t, col2 @p) ".
                "PRIMARY KEY (col1, col2) ".
                "AS OF ~2023.7.9..22.35.36..7e90"
    ==
  =.  run  +(run)
  =^  mov2  agent
    %:  ~(on-poke agent (bowl [run ~2000.1.3]))
        %obelisk-action
        !>([%tape %db1 "CREATE NAMESPACE ns1 as of ~2023.7.9..22.35.37..7e90"])
    ==
  =.  run  +(run)
  ::
  %+  expect-fail-message
        'drop table %my-table-2 as-of schema time out of order'
  |.  %:  ~(on-poke agent (bowl [run ~2000.1.2]))
      %obelisk-action
      !>  :+  %tape
              %db1
              "DROP TABLE db1..my-table-2 ".
              "AS OF ~2023.7.9..22.35.37..7e90"
    ==
::
::  fail on time, drop table lt schema
++  test-fail-drop-table-02
  =|  run=@ud
  =^  mov1  agent
    %:  ~(on-poke agent (bowl [run ~2000.1.1]))
        %obelisk-action
        !>  :-  %tape-create-db
                "CREATE DATABASE db1 as of ~2023.7.9..22.35.35..7e90"
    ==
  =.  run  +(run)
  =^  mov2  agent
    %:  ~(on-poke agent (bowl [run ~2000.1.2]))
        %obelisk-action
        !>  :+  %tape
                %db1
                "CREATE TABLE db1..my-table-2 (col1 @t, col2 @p) ".
                "PRIMARY KEY (col1, col2) ".
                "AS OF ~2023.7.9..22.35.36..7e90"
    ==
  =.  run  +(run)
  =^  mov2  agent
    %:  ~(on-poke agent (bowl [run ~2000.1.3]))
        %obelisk-action
        !>([%tape %db1 "CREATE NAMESPACE ns1 as of ~2023.7.9..22.35.37..7e90"])
    ==
  =.  run  +(run)
  ::
  %+  expect-fail-message
        'drop table %my-table-2 as-of schema time out of order'
  |.  %:  ~(on-poke agent (bowl [run ~2000.1.2]))
      %obelisk-action
      !>  :+  %tape
              %db1
              "DROP TABLE db1..my-table-2 ".
              "AS OF ~2023.7.9..22.35.36..7e90"
    ==
::
::  fail on time, drop table = content
++  test-fail-drop-table-03
  =|  run=@ud
  =^  mov1  agent
    %:  ~(on-poke agent (bowl [run ~2000.1.1]))
        %obelisk-action
        !>([%tape-create-db "CREATE DATABASE db1"])
    ==
  =.  run  +(run)
  =^  mov2  agent
    %:  ~(on-poke agent (bowl [run ~2000.1.2]))
        %obelisk-action
        !>  :+  %tape
                %db1
                "CREATE TABLE db1..my-table (col1 @t) PRIMARY KEY (col1)"
    ==
  =.  run  +(run)
  =^  mov3  agent
    %:  ~(on-poke agent (bowl [run ~2023.7.9..22.35.35..7e90]))
        %obelisk-action
        !>  :+  %tape
                %db1
                "INSERT INTO db1..my-table (col1) VALUES ('cord') ".
                "AS OF ~2023.7.9..22.35.35..7e90"
    ==
  =.  run  +(run)
  ::
  %+  expect-fail-message
        'drop table %my-table as-of data time out of order'
  |.  %:  ~(on-poke agent (bowl [run ~2000.1.2]))
      %obelisk-action
      !>  :+  %tape
              %db1
              "DROP TABLE db1..my-table as of ~2023.7.9..22.35.35..7e90"
    ==
::
::  fail on time, drop table < content
++  test-fail-drop-table-04
  =|  run=@ud
  =^  mov1  agent
    %:  ~(on-poke agent (bowl [run ~2000.1.1]))
        %obelisk-action
        !>([%tape-create-db "CREATE DATABASE db1"])
    ==
  =.  run  +(run)
  =^  mov2  agent
    %:  ~(on-poke agent (bowl [run ~2000.1.2]))
        %obelisk-action
        !>  :+  %tape
                %db1
                "CREATE TABLE db1..my-table (col1 @t) PRIMARY KEY (col1)"
    ==
  =.  run  +(run)
  =^  mov3  agent
    %:  ~(on-poke agent (bowl [run ~2023.7.9..22.35.35..7e90]))
        %obelisk-action
        !>  :+  %tape
                %db1
                "INSERT INTO db1..my-table (col1) VALUES ('cord') ".
                "AS OF ~2023.7.9..22.35.35..7e90"
    ==
  =.  run  +(run)
  ::
  %+  expect-fail-message
        'drop table %my-table as-of data time out of order'
  |.  %:  ~(on-poke agent (bowl [run ~2000.1.2]))
      %obelisk-action
      !>  :+  %tape
              %db1
              "DROP TABLE db1..my-table as of ~2023.7.9..22.35.34..7e90"
    ==
::
::  fail drop table with data no force
++  test-fail-drop-table-05
  =|  run=@ud
  =/  cmd
    :^  %drop-table
        :*  %qualified-object
            ship=~
            database='db1'
            namespace='dbo'
            name='my-table'
        ==
        %.n
        ~
  =^  mov1  agent
    %:  ~(on-poke agent (bowl [run ~2000.1.1]))
        %obelisk-action
        !>([%tape-create-db "CREATE DATABASE db1"])
    ==
  =.  run  +(run)
  =^  mov2  agent
    %:  ~(on-poke agent (bowl [run ~2000.1.2]))
        %obelisk-action
        !>  :+  %tape
                %db1
                "CREATE TABLE db1..my-table (col1 @t) PRIMARY KEY (col1)"
    ==
  =.  run  +(run)
  =^  mov3  agent
    %:  ~(on-poke agent (bowl [run ~2000.1.3]))
        %obelisk-action
        !>([%tape %db1 "INSERT INTO db1..my-table (col1) VALUES ('cord')"])
    ==
  =.  run  +(run)
  ::
  %+  expect-fail-message
        'drop table %my-table has data, use FORCE to DROP'
  |.  %:  ~(on-poke agent (bowl [run ~2000.1.4]))
      %obelisk-action
      !>([%commands ~[cmd]])
    ==
::
::  fail on database does not exist
++  test-fail-drop-table-06
  =|  run=@ud
  =/  cmd
    :^  %drop-table
        :*  %qualified-object
            ship=~
            database='db'
            namespace='dbo'
            name='my-table'
        ==
        %.n
        ~
  =^  mov1  agent
    %:  ~(on-poke agent (bowl [run ~2000.1.1]))
        %obelisk-action
        !>([%tape-create-db "CREATE DATABASE db1"])
    ==
  =.  run  +(run)
  ::
  %+  expect-fail-message
        'database %db does not exist'
  |.  %:  ~(on-poke agent (bowl [run ~2000.1.4]))
      %obelisk-action
      !>([%commands ~[cmd]])
    ==
::
::  fail on namespace does not exist
++  test-fail-drop-table-07
  =|  run=@ud
  =/  cmd
    :^  %drop-table
        :*  %qualified-object
            ship=~
            database='db1'
            namespace='ns1'
            name='my-table'
        ==
        %.n
        ~
  =^  mov1  agent
    %:  ~(on-poke agent (bowl [run ~2000.1.1]))
        %obelisk-action
        !>([%cmd-create-db [%create-database 'db1' ~]])
    ==
  =.  run  +(run)
  ::
  %+  expect-fail-message
        'namespace %ns1 does not exist'
  |.  %:  ~(on-poke agent (bowl [run ~2000.1.4]))
      %obelisk-action
      !>([%commands ~[cmd]])
    ==
::
::  fail on table name does not exist
++  test-fail-drop-table-08
  =|  run=@ud
  =/  cmd
    :^  %drop-table
        :*  %qualified-object
            ship=~
            database='db1'
            namespace='dbo'
            name='my-table'
        ==
        %.n
        ~
  =^  mov1  agent
    %:  ~(on-poke agent (bowl [run ~2000.1.1]))
        %obelisk-action
        !>([%cmd-create-db [%create-database 'db1' ~]])
    ==
  =.  run  +(run)
  ::
  %+  expect-fail-message
        '%my-table does not exist in %dbo'
  |.  %:  ~(on-poke agent (bowl [run ~2000.1.4]))
      %obelisk-action
      !>([%commands ~[cmd]])
    ==
::
::  Truncate table
::
::  fail on database does not exist
++  test-fail-truncate-tbl-01
  =|  run=@ud
  =/  cmd
    :-  %truncate-table
        [%qualified-object ship=~ database='db' namespace='dbo' name='my-table']
  =^  mov1  agent
    %:  ~(on-poke agent (bowl [run ~2000.1.1]))
        %obelisk-action
        !>([%cmd-create-db [%create-database 'db1' ~]])
    ==
  =.  run  +(run)
  ::
  %+  expect-fail-message
        'database %db does not exist'
  |.  %:  ~(on-poke agent (bowl [run ~2000.1.3]))
      %obelisk-action
      !>([%commands ~[cmd]])
    ==
::
::  fail on namespace does not exist
++  test-fail-truncate-tbl-02
  =|  run=@ud
  =/  cmd
    :-  %truncate-table
        [%qualified-object ship=~ database='db1' namespace='ns1' name='my-table']
  =^  mov1  agent
    %:  ~(on-poke agent (bowl [run ~2000.1.1]))
        %obelisk-action
        !>([%cmd-create-db [%create-database 'db1' ~]])
    ==
  =.  run  +(run)
  ::
  %+  expect-fail-message
        'namespace %ns1 does not exist'
  |.  %:  ~(on-poke agent (bowl [run ~2000.1.3]))
      %obelisk-action
      !>([%commands ~[cmd]])
    ==
::
::  fail on table name does not exist
++  test-fail-truncate-tbl-03
  =|  run=@ud
  =/  cmd
    :-  %truncate-table
        :*  %qualified-object
            ship=~
            database='db1'
            namespace='dbo'
            name='my-table'
        ==
  =^  mov1  agent
    %:  ~(on-poke agent (bowl [run ~2000.1.1]))
        %obelisk-action
        !>([%cmd-create-db [%create-database 'db1' ~]])
    ==
  =.  run  +(run)
  ::
  %+  expect-fail-message
        '%my-table does not exists in %dbo'
  |.  %:  ~(on-poke agent (bowl [run ~2000.1.3]))
      %obelisk-action
      !>([%commands ~[cmd]])
    ==

--
