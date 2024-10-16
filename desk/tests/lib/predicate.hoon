::  Demonstrate unit testing filtered queries on a Gall agent with %obelisk.
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
--
|%
::
::  EQ
::
::  WHERE <column> = <literal>
++  test-eq-00
  =|  run=@ud
  =/  expected-rows
        :~
          :-  %vector
              :~  [%col1 [~.t 'Angel']]
                  [%col2 [~.da ~2001.9.19]]
                  [%col3 [~.t 'tuxedo']]
                  [%col4 [~.t 'row3']]
                  ==
            ==
  =/  expected  :~  %results
                    [%message 'SELECT']
                    [%result-set expected-rows]
                    [%server-time ~2012.5.3]
                    [%message 'db1.dbo.my-table']
                    [%schema-time ~2012.5.1]
                    [%data-time ~2012.5.2]
                    [%vector-count 1]
                ==
  =^  mov1  agent
    %:  ~(on-poke agent (bowl [run ~2012.4.30]))
        %obelisk-action
        !>([%tape %sys "CREATE DATABASE db1"])
    ==
  =.  run  +(run)
  =^  mov2  agent
    %:  ~(on-poke agent (bowl [run ~2012.5.1]))
        %obelisk-action
        !>  :+  %tape
                %db1
                "CREATE TABLE db1..my-table ".
                "(col1 @t, col2 @da, col3 @t, col4 @t) ".
                "PRIMARY KEY (col1)"
    ==
    =.  run  +(run)
  =^  mov3  agent
    %:  ~(on-poke agent (bowl [run ~2012.5.2]))
        %obelisk-action
        !>  :+  %tape
                %db1
                "INSERT INTO my-table".
                " VALUES".
                " ('Abby', ~1999.2.19, 'tricolor', 'row1')".
                " ('Ace', ~2005.12.19, 'ticolor', 'row2')".
                " ('Angel', ~2001.9.19, 'tuxedo', 'row3')"
    ==
  =.  run  +(run)
  =^  mov4  agent
    %:  ~(on-poke agent (bowl [run ~2012.5.3]))
        %obelisk-action
        !>([%tape %db1 "FROM my-table WHERE col3 = 'tuxedo' SELECT *"])
    ==
  %+  expect-eq
    !>  expected
    !>  ;;(cmd-result ->+>+>-.mov4)
::
::  WHERE <literal> = <column>
++  test-eq-01
  =|  run=@ud
  =/  expected-rows
        :~
          :-  %vector
              :~  [%col1 [~.t 'Angel']]
                  [%col2 [~.da ~2001.9.19]]
                  [%col3 [~.t 'tuxedo']]
                  [%col4 [~.t 'row3']]
                  ==
            ==
  =/  expected  :~  %results
                    [%message 'SELECT']
                    [%result-set expected-rows]
                    [%server-time ~2012.5.3]
                    [%message 'db1.dbo.my-table']
                    [%schema-time ~2012.5.1]
                    [%data-time ~2012.5.2]
                    [%vector-count 1]
                ==
  =^  mov1  agent
    %:  ~(on-poke agent (bowl [run ~2012.4.30]))
        %obelisk-action
        !>([%tape %sys "CREATE DATABASE db1"])
    ==
  =.  run  +(run)
  =^  mov2  agent
    %:  ~(on-poke agent (bowl [run ~2012.5.1]))
        %obelisk-action
        !>  :+  %tape
                %db1
                "CREATE TABLE db1..my-table ".
                "(col1 @t, col2 @da, col3 @t, col4 @t) ".
                "PRIMARY KEY (col1)"
    ==
    =.  run  +(run)
  =^  mov3  agent
    %:  ~(on-poke agent (bowl [run ~2012.5.2]))
        %obelisk-action
        !>  :+  %tape
                %db1
                "INSERT INTO my-table".
                " VALUES".
                " ('Abby', ~1999.2.19, 'tricolor', 'row1')".
                " ('Ace', ~2005.12.19, 'ticolor', 'row2')".
                " ('Angel', ~2001.9.19, 'tuxedo', 'row3')"
    ==
  =.  run  +(run)
  =^  mov4  agent
    %:  ~(on-poke agent (bowl [run ~2012.5.3]))
        %obelisk-action
        !>([%tape %db1 "FROM my-table WHERE 'tuxedo' = col3 SELECT *"])
    ==
  %+  expect-eq
    !>  expected
    !>  ;;(cmd-result ->+>+>-.mov4)
::
::  WHERE <column> = <column>
++  test-eq-02
  =|  run=@ud
  =/  expected-rows
        :~
          :-  %vector
              :~  [%col1 [~.t 'Angel']]
                  [%col2 [~.da ~2001.9.19]]
                  [%col3 [~.t 'Angel']]
                  [%col4 [~.t 'row3']]
                  ==
            ==
  =/  expected  :~  %results
                    [%message 'SELECT']
                    [%result-set expected-rows]
                    [%server-time ~2012.5.3]
                    [%message 'db1.dbo.my-table']
                    [%schema-time ~2012.5.1]
                    [%data-time ~2012.5.2]
                    [%vector-count 1]
                ==
  =^  mov1  agent
    %:  ~(on-poke agent (bowl [run ~2012.4.30]))
        %obelisk-action
        !>([%tape %sys "CREATE DATABASE db1"])
    ==
  =.  run  +(run)
  =^  mov2  agent
    %:  ~(on-poke agent (bowl [run ~2012.5.1]))
        %obelisk-action
        !>  :+  %tape
                %db1
                "CREATE TABLE db1..my-table ".
                "(col1 @t, col2 @da, col3 @t, col4 @t) ".
                "PRIMARY KEY (col1)"
    ==
    =.  run  +(run)
  =^  mov3  agent
    %:  ~(on-poke agent (bowl [run ~2012.5.2]))
        %obelisk-action
        !>  :+  %tape
                %db1
                "INSERT INTO my-table".
                " VALUES".
                " ('Abby', ~1999.2.19, 'tricolor', 'row1')".
                " ('Ace', ~2005.12.19, 'ticolor', 'row2')".
                " ('Angel', ~2001.9.19, 'Angel', 'row3')"
    ==
  =.  run  +(run)
  =^  mov4  agent
    %:  ~(on-poke agent (bowl [run ~2012.5.3]))
        %obelisk-action
        !>([%tape %db1 "FROM my-table WHERE col1 = col3 SELECT *"])
    ==
  %+  expect-eq
    !>  expected
    !>  ;;(cmd-result ->+>+>-.mov4)
::
::  view WHERE <column> = <literal>
++  test-eq-03
  =|  run=@ud
  =/  expected-rows
        :~
          :-  %vector
              :~  [p=%namespace q=[p=~.tas q=%dbo]]
                  [p=%name q=[p=~.tas q=%my-table]]
                  [p=%col-ordinal q=[p=~.ud q=3]]
                  [p=%col-name q=[p=~.tas q=%col3]]
                  [p=%col-type q=[p=~.ta q=116]]
                  ==
            ==
  =/  expected  :~  %results
                    [%message 'SELECT']
                    [%result-set expected-rows]
                    [%server-time ~2012.5.3]
                    [%message 'db1.sys.columns']
                    [%schema-time ~2012.5.1]
                    [%data-time ~2012.5.1]
                    [%vector-count 1]
                ==
  =^  mov1  agent
    %:  ~(on-poke agent (bowl [run ~2012.4.30]))
        %obelisk-action
        !>([%tape %sys "CREATE DATABASE db1"])
    ==
  =.  run  +(run)
  =^  mov2  agent
    %:  ~(on-poke agent (bowl [run ~2012.5.1]))
        %obelisk-action
        !>  :+  %tape
                %db1
                "CREATE TABLE db1..my-table ".
                "(col1 @t, col2 @da, col3 @t, col4 @t) ".
                "PRIMARY KEY (col1)"
    ==
  =.  run  +(run)
  =^  mov3  agent
    %:  ~(on-poke agent (bowl [run ~2012.5.3]))
        %obelisk-action
        !>([%tape %db1 "FROM sys.columns WHERE col-name = 'col3' SELECT *"])
    ==
  %+  expect-eq
    !>  expected
    !>  ;;(cmd-result ->+>+>-.mov3)
::
::  view WHERE <column> = <literal>
++  test-eq-04
  =|  run=@ud
  =/  expected-rows
        :~
          :-  %vector
              :~  [p=%namespace q=[p=~.tas q=%dbo]]
                  [p=%name q=[p=~.tas q=%my-table]]
                  [p=%col-ordinal q=[p=~.ud q=3]]
                  [p=%col-name q=[p=~.tas q=%col3]]
                  [p=%col-type q=[p=~.ta q=116]]
                  ==
            ==
  =/  expected  :~  %results
                    [%message 'SELECT']
                    [%result-set expected-rows]
                    [%server-time ~2012.5.3]
                    [%message 'db1.sys.columns']
                    [%schema-time ~2012.5.1]
                    [%data-time ~2012.5.1]
                    [%vector-count 1]
                ==
  =^  mov1  agent
    %:  ~(on-poke agent (bowl [run ~2012.4.30]))
        %obelisk-action
        !>([%tape %sys "CREATE DATABASE db1"])
    ==
  =.  run  +(run)
  =^  mov2  agent
    %:  ~(on-poke agent (bowl [run ~2012.5.1]))
        %obelisk-action
        !>  :+  %tape
                %db1
                "CREATE TABLE db1..my-table ".
                "(col1 @t, col2 @da, col3 @t, col4 @t) ".
                "PRIMARY KEY (col1)"
    ==
  =.  run  +(run)
  =^  mov3  agent
    %:  ~(on-poke agent (bowl [run ~2012.5.3]))
        %obelisk-action
        !>([%tape %db1 "FROM sys.columns WHERE 'col3' = col-name SELECT *"])
    ==
  %+  expect-eq
    !>  expected
    !>  ;;(cmd-result ->+>+>-.mov3)
::
::  view WHERE <literal> = <literal>
++  test-eq-05
  =|  run=@ud
  =/  expected-rows
        :~
          :-  %vector
              :~  [p=%namespace q=[p=~.tas q=%dbo]]
                  [p=%name q=[p=~.tas q=%my-table]]
                  [p=%col-ordinal q=[p=~.ud q=1]]
                  [p=%col-name q=[p=~.tas q=%col1]]
                  [p=%col-type q=[p=~.ta q=~.t]]
                  ==
          :-  %vector
              :~  [p=%namespace q=[p=~.tas q=%dbo]]
                  [p=%name q=[p=~.tas q=%my-table]]
                  [p=%col-ordinal q=[p=~.ud q=2]]
                  [p=%col-name q=[p=~.tas q=%col2]]
                  [p=%col-type q=[p=~.ta q=~.da]]
                  ==
          :-  %vector
              :~  [p=%namespace q=[p=~.tas q=%dbo]]
                  [p=%name q=[p=~.tas q=%my-table]]
                  [p=%col-ordinal q=[p=~.ud q=3]]
                  [p=%col-name q=[p=~.tas q=%col3]]
                  [p=%col-type q=[p=~.ta q=~.t]]
                  ==
          :-  %vector
              :~  [p=%namespace q=[p=~.tas q=%dbo]]
                  [p=%name q=[p=~.tas q=%my-table]]
                  [p=%col-ordinal q=[p=~.ud q=4]]
                  [p=%col-name q=[p=~.tas q=%col4]]
                  [p=%col-type q=[p=~.ta q=~.t]]
                  ==
            ==
  =/  expected  :~  %results
                    [%message 'SELECT']
                    [%result-set expected-rows]
                    [%server-time ~2012.5.3]
                    [%message 'db1.sys.columns']
                    [%schema-time ~2012.5.1]
                    [%data-time ~2012.5.1]
                    [%vector-count 4]
                ==
  =^  mov1  agent
    %:  ~(on-poke agent (bowl [run ~2012.4.30]))
        %obelisk-action
        !>([%tape %sys "CREATE DATABASE db1"])
    ==
  =.  run  +(run)
  =^  mov2  agent
    %:  ~(on-poke agent (bowl [run ~2012.5.1]))
        %obelisk-action
        !>  :+  %tape
                %db1
                "CREATE TABLE db1..my-table ".
                "(col1 @t, col2 @da, col3 @t, col4 @t) ".
                "PRIMARY KEY (col1)"
    ==
  =.  run  +(run)
  =^  mov3  agent
    %:  ~(on-poke agent (bowl [run ~2012.5.3]))
        %obelisk-action
        !>([%tape %db1 "FROM sys.columns WHERE 1 = 1 SELECT *"])
    ==
  %+  expect-eq
    !>  expected
    !>  ;;(cmd-result ->+>+>-.mov3)
::
::  fail WHERE <column> = <literal> types differ
++  test-fail-eq-00
  =|  run=@ud
  =/  expected-rows
        :~
          :-  %vector
              :~  [%col1 [~.t 'Angel']]
                  [%col2 [~.da ~2001.9.19]]
                  [%col3 [~.t 'Angel']]
                  [%col4 [~.t 'row3']]
                  ==
            ==
  =/  expected  :~  %results
                    [%message 'SELECT']
                    [%result-set expected-rows]
                    [%server-time ~2012.5.3]
                    [%message 'db1.dbo.my-table']
                    [%schema-time ~2012.5.1]
                    [%data-time ~2012.5.2]
                    [%vector-count 1]
                ==
  =^  mov1  agent
    %:  ~(on-poke agent (bowl [run ~2012.4.30]))
        %obelisk-action
        !>([%tape %sys "CREATE DATABASE db1"])
    ==
  =.  run  +(run)
  =^  mov2  agent
    %:  ~(on-poke agent (bowl [run ~2012.5.1]))
        %obelisk-action
        !>  :+  %tape
                %db1
                "CREATE TABLE db1..my-table ".
                "(col1 @t, col2 @da, col3 @t, col4 @t) ".
                "PRIMARY KEY (col1)"
    ==
    =.  run  +(run)
  =^  mov3  agent
    %:  ~(on-poke agent (bowl [run ~2012.5.2]))
        %obelisk-action
        !>  :+  %tape
                %db1
                "INSERT INTO my-table".
                " VALUES".
                " ('Abby', ~1999.2.19, 'tricolor', 'row1')".
                " ('Ace', ~2005.12.19, 'ticolor', 'row2')".
                " ('Angel', ~2001.9.19, 'Angel', 'row3')"
    ==
  =.  run  +(run)
  ::
  %+  expect-fail-message
      %-  crip
          "comparing column to literal of different aura: %col1 "
  |.  %:  ~(on-poke agent (bowl [run ~2012.5.2]))
          %obelisk-action
          !>([%tape %db1 "FROM my-table WHERE col1 = ~1999.2.19 SELECT *"])
      ==
::
::  fail WHERE <literal> = <column> types differ
++  test-fail-eq-01
  =|  run=@ud
  =/  expected-rows
        :~
          :-  %vector
              :~  [%col1 [~.t 'Angel']]
                  [%col2 [~.da ~2001.9.19]]
                  [%col3 [~.t 'Angel']]
                  [%col4 [~.t 'row3']]
                  ==
            ==
  =/  expected  :~  %results
                    [%message 'SELECT']
                    [%result-set expected-rows]
                    [%server-time ~2012.5.3]
                    [%message 'db1.dbo.my-table']
                    [%schema-time ~2012.5.1]
                    [%data-time ~2012.5.2]
                    [%vector-count 1]
                ==
  =^  mov1  agent
    %:  ~(on-poke agent (bowl [run ~2012.4.30]))
        %obelisk-action
        !>([%tape %sys "CREATE DATABASE db1"])
    ==
  =.  run  +(run)
  =^  mov2  agent
    %:  ~(on-poke agent (bowl [run ~2012.5.1]))
        %obelisk-action
        !>  :+  %tape
                %db1
                "CREATE TABLE db1..my-table ".
                "(col1 @t, col2 @da, col3 @t, col4 @t) ".
                "PRIMARY KEY (col1)"
    ==
    =.  run  +(run)
  =^  mov3  agent
    %:  ~(on-poke agent (bowl [run ~2012.5.2]))
        %obelisk-action
        !>  :+  %tape
                %db1
                "INSERT INTO my-table".
                " VALUES".
                " ('Abby', ~1999.2.19, 'tricolor', 'row1')".
                " ('Ace', ~2005.12.19, 'ticolor', 'row2')".
                " ('Angel', ~2001.9.19, 'Angel', 'row3')"
    ==
  =.  run  +(run)
  ::
  %+  expect-fail-message
      %-  crip
          "comparing column to literal of different aura: %col1 "
  |.  %:  ~(on-poke agent (bowl [run ~2012.5.2]))
          %obelisk-action
          !>([%tape %db1 "FROM my-table WHERE ~1999.2.19 = col1 SELECT *"])
      ==
::
::  fail WHERE <column> = <column> types differ
++  test-fail-eq-02
  =|  run=@ud
  =/  expected-rows
        :~
          :-  %vector
              :~  [%col1 [~.t 'Angel']]
                  [%col2 [~.da ~2001.9.19]]
                  [%col3 [~.t 'Angel']]
                  [%col4 [~.t 'row3']]
                  ==
            ==
  =/  expected  :~  %results
                    [%message 'SELECT']
                    [%result-set expected-rows]
                    [%server-time ~2012.5.3]
                    [%message 'db1.dbo.my-table']
                    [%schema-time ~2012.5.1]
                    [%data-time ~2012.5.2]
                    [%vector-count 1]
                ==
  =^  mov1  agent
    %:  ~(on-poke agent (bowl [run ~2012.4.30]))
        %obelisk-action
        !>([%tape %sys "CREATE DATABASE db1"])
    ==
  =.  run  +(run)
  =^  mov2  agent
    %:  ~(on-poke agent (bowl [run ~2012.5.1]))
        %obelisk-action
        !>  :+  %tape
                %db1
                "CREATE TABLE db1..my-table ".
                "(col1 @t, col2 @da, col3 @t, col4 @t) ".
                "PRIMARY KEY (col1)"
    ==
    =.  run  +(run)
  =^  mov3  agent
    %:  ~(on-poke agent (bowl [run ~2012.5.2]))
        %obelisk-action
        !>  :+  %tape
                %db1
                "INSERT INTO my-table".
                " VALUES".
                " ('Abby', ~1999.2.19, 'tricolor', 'row1')".
                " ('Ace', ~2005.12.19, 'ticolor', 'row2')".
                " ('Angel', ~2001.9.19, 'Angel', 'row3')"
    ==
  =.  run  +(run)
  ::
  %+  expect-fail-message
      %-  crip
          "comparing columns of differing auras: %col1 %col2"
  |.  %:  ~(on-poke agent (bowl [run ~2012.5.2]))
          %obelisk-action
          !>([%tape %db1 "FROM my-table WHERE col1 = col2 SELECT *"])
      ==
::
::  NEQ
::
::  WHERE <column> <> <literal>
++  test-neq-00
  =|  run=@ud
  =/  expected-rows
        :~
          :-  %vector
              :~  [%col1 [~.t 'Abby']]
                  [%col2 [~.da ~1999.2.19]]
                  [%col3 [~.t 'tricolor']]
                  [%col4 [~.t 'row1']]
                  ==
          :-  %vector
              :~  [%col1 [~.t 'Ace']]
                  [%col2 [~.da ~2005.12.19]]
                  [%col3 [~.t 'ticolor']]
                  [%col4 [~.t 'row2']]
                  ==
            ==
  =/  expected  :~  %results
                    [%message 'SELECT']
                    [%result-set expected-rows]
                    [%server-time ~2012.5.3]
                    [%message 'db1.dbo.my-table']
                    [%schema-time ~2012.5.1]
                    [%data-time ~2012.5.2]
                    [%vector-count 2]
                ==
  =^  mov1  agent
    %:  ~(on-poke agent (bowl [run ~2012.4.30]))
        %obelisk-action
        !>([%tape %sys "CREATE DATABASE db1"])
    ==
  =.  run  +(run)
  =^  mov2  agent
    %:  ~(on-poke agent (bowl [run ~2012.5.1]))
        %obelisk-action
        !>  :+  %tape
                %db1
                "CREATE TABLE db1..my-table ".
                "(col1 @t, col2 @da, col3 @t, col4 @t) ".
                "PRIMARY KEY (col1)"
    ==
    =.  run  +(run)
  =^  mov3  agent
    %:  ~(on-poke agent (bowl [run ~2012.5.2]))
        %obelisk-action
        !>  :+  %tape
                %db1
                "INSERT INTO my-table".
                " VALUES".
                " ('Abby', ~1999.2.19, 'tricolor', 'row1')".
                " ('Ace', ~2005.12.19, 'ticolor', 'row2')".
                " ('Angel', ~2001.9.19, 'tuxedo', 'row3')"
    ==
  =.  run  +(run)
    =^  mov4  agent
    %:  ~(on-poke agent (bowl [run ~2012.5.3]))
        %obelisk-action
        !>([%tape %db1 "FROM my-table WHERE col3 <> 'tuxedo' SELECT *"])
    ==
  %+  expect-eq
    !>  expected
    !>  ;;(cmd-result ->+>+>-.mov4)
::
::  WHERE <literal> <> <column>
++  test-neq-01
  =|  run=@ud
  =/  expected-rows
        :~
          :-  %vector
              :~  [%col1 [~.t 'Abby']]
                  [%col2 [~.da ~1999.2.19]]
                  [%col3 [~.t 'tricolor']]
                  [%col4 [~.t 'row1']]
                  ==
          :-  %vector
              :~  [%col1 [~.t 'Ace']]
                  [%col2 [~.da ~2005.12.19]]
                  [%col3 [~.t 'ticolor']]
                  [%col4 [~.t 'row2']]
                  ==
            ==
  =/  expected  :~  %results
                    [%message 'SELECT']
                    [%result-set expected-rows]
                    [%server-time ~2012.5.3]
                    [%message 'db1.dbo.my-table']
                    [%schema-time ~2012.5.1]
                    [%data-time ~2012.5.2]
                    [%vector-count 2]
                ==
  =^  mov1  agent
    %:  ~(on-poke agent (bowl [run ~2012.4.30]))
        %obelisk-action
        !>([%tape %sys "CREATE DATABASE db1"])
    ==
  =.  run  +(run)
  =^  mov2  agent
    %:  ~(on-poke agent (bowl [run ~2012.5.1]))
        %obelisk-action
        !>  :+  %tape
                %db1
                "CREATE TABLE db1..my-table ".
                "(col1 @t, col2 @da, col3 @t, col4 @t) ".
                "PRIMARY KEY (col1)"
    ==
    =.  run  +(run)
  =^  mov3  agent
    %:  ~(on-poke agent (bowl [run ~2012.5.2]))
        %obelisk-action
        !>  :+  %tape
                %db1
                "INSERT INTO my-table".
                " VALUES".
                " ('Abby', ~1999.2.19, 'tricolor', 'row1')".
                " ('Ace', ~2005.12.19, 'ticolor', 'row2')".
                " ('Angel', ~2001.9.19, 'tuxedo', 'row3')"
    ==
  =.  run  +(run)
  =^  mov4  agent
    %:  ~(on-poke agent (bowl [run ~2012.5.3]))
        %obelisk-action
        !>([%tape %db1 "FROM my-table WHERE 'tuxedo' <> col3 SELECT *"])
    ==
  %+  expect-eq
    !>  expected
    !>  ;;(cmd-result ->+>+>-.mov4)
::
::  WHERE <column> != <column>
++  test-neq-02
  =|  run=@ud
  =/  expected-rows
        :~
          :-  %vector
              :~  [%col1 [~.t 'Abby']]
                  [%col2 [~.da ~1999.2.19]]
                  [%col3 [~.t 'tricolor']]
                  [%col4 [~.t 'row1']]
                  ==
          :-  %vector
              :~  [%col1 [~.t 'Ace']]
                  [%col2 [~.da ~2005.12.19]]
                  [%col3 [~.t 'ticolor']]
                  [%col4 [~.t 'row2']]
                  ==
            ==
  =/  expected  :~  %results
                    [%message 'SELECT']
                    [%result-set expected-rows]
                    [%server-time ~2012.5.3]
                    [%message 'db1.dbo.my-table']
                    [%schema-time ~2012.5.1]
                    [%data-time ~2012.5.2]
                    [%vector-count 2]
                ==
  =^  mov1  agent
    %:  ~(on-poke agent (bowl [run ~2012.4.30]))
        %obelisk-action
        !>([%tape %sys "CREATE DATABASE db1"])
    ==
  =.  run  +(run)
  =^  mov2  agent
    %:  ~(on-poke agent (bowl [run ~2012.5.1]))
        %obelisk-action
        !>  :+  %tape
                %db1
                "CREATE TABLE db1..my-table ".
                "(col1 @t, col2 @da, col3 @t, col4 @t) ".
                "PRIMARY KEY (col1)"
    ==
    =.  run  +(run)
  =^  mov3  agent
    %:  ~(on-poke agent (bowl [run ~2012.5.2]))
        %obelisk-action
        !>  :+  %tape
                %db1
                "INSERT INTO my-table".
                " VALUES".
                " ('Abby', ~1999.2.19, 'tricolor', 'row1')".
                " ('Ace', ~2005.12.19, 'ticolor', 'row2')".
                " ('Angel', ~2001.9.19, 'Angel', 'row3')"
    ==
  =.  run  +(run)
  =^  mov4  agent
    %:  ~(on-poke agent (bowl [run ~2012.5.3]))
        %obelisk-action
        !>([%tape %db1 "FROM my-table WHERE col1 != col3 SELECT *"])
    ==
  %+  expect-eq
    !>  expected
    !>  ;;(cmd-result ->+>+>-.mov4)
::
::  view WHERE <column> <> <literal>
++  test-neq-03
  =|  run=@ud
  =/  expected-rows
        :~
          :-  %vector
              :~  [p=%namespace q=[p=~.tas q=%dbo]]
                  [p=%name q=[p=~.tas q=%my-table]]
                  [p=%col-ordinal q=[p=~.ud q=1]]
                  [p=%col-name q=[p=~.tas q=%col1]]
                  [p=%col-type q=[p=~.ta q=~.t]]
                  ==
          :-  %vector
              :~  [p=%namespace q=[p=~.tas q=%dbo]]
                  [p=%name q=[p=~.tas q=%my-table]]
                  [p=%col-ordinal q=[p=~.ud q=2]]
                  [p=%col-name q=[p=~.tas q=%col2]]
                  [p=%col-type q=[p=~.ta q=~.da]]
                  ==
          :-  %vector
              :~  [p=%namespace q=[p=~.tas q=%dbo]]
                  [p=%name q=[p=~.tas q=%my-table]]
                  [p=%col-ordinal q=[p=~.ud q=4]]
                  [p=%col-name q=[p=~.tas q=%col4]]
                  [p=%col-type q=[p=~.ta q=~.t]]
                  ==
            ==
  =/  expected  :~  %results
                    [%message 'SELECT']
                    [%result-set expected-rows]
                    [%server-time ~2012.5.3]
                    [%message 'db1.sys.columns']
                    [%schema-time ~2012.5.1]
                    [%data-time ~2012.5.1]
                    [%vector-count 3]
                ==
  =^  mov1  agent
    %:  ~(on-poke agent (bowl [run ~2012.4.30]))
        %obelisk-action
        !>([%tape %sys "CREATE DATABASE db1"])
    ==
  =.  run  +(run)
  =^  mov2  agent
    %:  ~(on-poke agent (bowl [run ~2012.5.1]))
        %obelisk-action
        !>  :+  %tape
                %db1
                "CREATE TABLE db1..my-table ".
                "(col1 @t, col2 @da, col3 @t, col4 @t) ".
                "PRIMARY KEY (col3)"
    ==
  =.  run  +(run)
  =^  mov3  agent
    %:  ~(on-poke agent (bowl [run ~2012.5.3]))
        %obelisk-action
        !>([%tape %db1 "FROM sys.columns WHERE col-name <> 'col3' SELECT *"])
    ==
  %+  expect-eq
    !>  expected
    !>  ;;(cmd-result ->+>+>-.mov3)
::
::  view WHERE <column> <> <literal>
++  test-neq-04
  =|  run=@ud
  =/  expected-rows
        :~
          :-  %vector
              :~  [p=%namespace q=[p=~.tas q=%dbo]]
                  [p=%name q=[p=~.tas q=%my-table]]
                  [p=%col-ordinal q=[p=~.ud q=1]]
                  [p=%col-name q=[p=~.tas q=%col1]]
                  [p=%col-type q=[p=~.ta q=~.t]]
                  ==
          :-  %vector
              :~  [p=%namespace q=[p=~.tas q=%dbo]]
                  [p=%name q=[p=~.tas q=%my-table]]
                  [p=%col-ordinal q=[p=~.ud q=2]]
                  [p=%col-name q=[p=~.tas q=%col2]]
                  [p=%col-type q=[p=~.ta q=~.da]]
                  ==
          :-  %vector
              :~  [p=%namespace q=[p=~.tas q=%dbo]]
                  [p=%name q=[p=~.tas q=%my-table]]
                  [p=%col-ordinal q=[p=~.ud q=4]]
                  [p=%col-name q=[p=~.tas q=%col4]]
                  [p=%col-type q=[p=~.ta q=~.t]]
                  ==
            ==
  =/  expected  :~  %results
                    [%message 'SELECT']
                    [%result-set expected-rows]
                    [%server-time ~2012.5.3]
                    [%message 'db1.sys.columns']
                    [%schema-time ~2012.5.1]
                    [%data-time ~2012.5.1]
                    [%vector-count 3]
                ==
  =^  mov1  agent
    %:  ~(on-poke agent (bowl [run ~2012.4.30]))
        %obelisk-action
        !>([%tape %sys "CREATE DATABASE db1"])
    ==
  =.  run  +(run)
  =^  mov2  agent
    %:  ~(on-poke agent (bowl [run ~2012.5.1]))
        %obelisk-action
        !>  :+  %tape
                %db1
                "CREATE TABLE db1..my-table ".
                "(col1 @t, col2 @da, col3 @t, col4 @t) ".
                "PRIMARY KEY (col1)"
    ==
  =.  run  +(run)
  =^  mov3  agent
    %:  ~(on-poke agent (bowl [run ~2012.5.3]))
        %obelisk-action
        !>([%tape %db1 "FROM sys.columns WHERE 'col3' <> col-name SELECT *"])
    ==
  %+  expect-eq
    !>  expected
    !>  ;;(cmd-result ->+>+>-.mov3)
::
::  view WHERE <literal> != <literal>
++  test-neq-05
  =|  run=@ud
  =/  expected  :~  %results
                    [%message 'SELECT']
                    [%result-set ~]
                    [%server-time ~2012.5.3]
                    [%message 'db1.sys.columns']
                    [%schema-time ~2012.5.1]
                    [%data-time ~2012.5.1]
                    [%vector-count 0]
                ==
  =^  mov1  agent
    %:  ~(on-poke agent (bowl [run ~2012.4.30]))
        %obelisk-action
        !>([%tape %sys "CREATE DATABASE db1"])
    ==
  =.  run  +(run)
  =^  mov2  agent
    %:  ~(on-poke agent (bowl [run ~2012.5.1]))
        %obelisk-action
        !>  :+  %tape
                %db1
                "CREATE TABLE db1..my-table ".
                "(col1 @t, col2 @da, col3 @t, col4 @t) ".
                "PRIMARY KEY (col1)"
    ==
  =.  run  +(run)
  =^  mov3  agent
    %:  ~(on-poke agent (bowl [run ~2012.5.3]))
        %obelisk-action
        !>([%tape %db1 "FROM sys.columns WHERE 1 != 1 SELECT *"])
    ==
  %+  expect-eq
    !>  expected
    !>  ;;(cmd-result ->+>+>-.mov3)
::
::  fail WHERE <column> <> <literal> types differ
++  test-fail-neq-00
  =|  run=@ud
  =/  expected-rows
        :~
          :-  %vector
              :~  [%col1 [~.t 'Angel']]
                  [%col2 [~.da ~2001.9.19]]
                  [%col3 [~.t 'Angel']]
                  [%col4 [~.t 'row3']]
                  ==
            ==
  =/  expected  :~  %results
                    [%message 'SELECT']
                    [%result-set expected-rows]
                    [%server-time ~2012.5.3]
                    [%message 'db1.dbo.my-table']
                    [%schema-time ~2012.5.1]
                    [%data-time ~2012.5.2]
                    [%vector-count 1]
                ==
  =^  mov1  agent
    %:  ~(on-poke agent (bowl [run ~2012.4.30]))
        %obelisk-action
        !>([%tape %sys "CREATE DATABASE db1"])
    ==
  =.  run  +(run)
  =^  mov2  agent
    %:  ~(on-poke agent (bowl [run ~2012.5.1]))
        %obelisk-action
        !>  :+  %tape
                %db1
                "CREATE TABLE db1..my-table ".
                "(col1 @t, col2 @da, col3 @t, col4 @t) ".
                "PRIMARY KEY (col1)"
    ==
    =.  run  +(run)
  =^  mov3  agent
    %:  ~(on-poke agent (bowl [run ~2012.5.2]))
        %obelisk-action
        !>  :+  %tape
                %db1
                "INSERT INTO my-table".
                " VALUES".
                " ('Abby', ~1999.2.19, 'tricolor', 'row1')".
                " ('Ace', ~2005.12.19, 'ticolor', 'row2')".
                " ('Angel', ~2001.9.19, 'Angel', 'row3')"
    ==
  =.  run  +(run)
  ::
  %+  expect-fail-message
      %-  crip
          "comparing column to literal of different aura: %col1 "
  |.  %:  ~(on-poke agent (bowl [run ~2012.5.2]))
          %obelisk-action
          !>([%tape %db1 "FROM my-table WHERE col1 <> ~1999.2.19 SELECT *"])
      ==
::
::  fail WHERE <literal> <><column> types differ
++  test-fail-neq-01
  =|  run=@ud
  =/  expected-rows
        :~
          :-  %vector
              :~  [%col1 [~.t 'Angel']]
                  [%col2 [~.da ~2001.9.19]]
                  [%col3 [~.t 'Angel']]
                  [%col4 [~.t 'row3']]
                  ==
            ==
  =/  expected  :~  %results
                    [%message 'SELECT']
                    [%result-set expected-rows]
                    [%server-time ~2012.5.3]
                    [%message 'db1.dbo.my-table']
                    [%schema-time ~2012.5.1]
                    [%data-time ~2012.5.2]
                    [%vector-count 1]
                ==
  =^  mov1  agent
    %:  ~(on-poke agent (bowl [run ~2012.4.30]))
        %obelisk-action
        !>([%tape %sys "CREATE DATABASE db1"])
    ==
  =.  run  +(run)
  =^  mov2  agent
    %:  ~(on-poke agent (bowl [run ~2012.5.1]))
        %obelisk-action
        !>  :+  %tape
                %db1
                "CREATE TABLE db1..my-table ".
                "(col1 @t, col2 @da, col3 @t, col4 @t) ".
                "PRIMARY KEY (col1)"
    ==
    =.  run  +(run)
  =^  mov3  agent
    %:  ~(on-poke agent (bowl [run ~2012.5.2]))
        %obelisk-action
        !>  :+  %tape
                %db1
                "INSERT INTO my-table".
                " VALUES".
                " ('Abby', ~1999.2.19, 'tricolor', 'row1')".
                " ('Ace', ~2005.12.19, 'ticolor', 'row2')".
                " ('Angel', ~2001.9.19, 'Angel', 'row3')"
    ==
  =.  run  +(run)
  ::
  %+  expect-fail-message
      %-  crip
          "comparing column to literal of different aura: %col1 "
  |.  %:  ~(on-poke agent (bowl [run ~2012.5.2]))
          %obelisk-action
          !>([%tape %db1 "FROM my-table WHERE ~1999.2.19 <> col1 SELECT *"])
      ==
::
::  fail WHERE <column> <> <column> types differ
++  test-fail-neq-02
  =|  run=@ud
  =/  expected-rows
        :~
          :-  %vector
              :~  [%col1 [~.t 'Angel']]
                  [%col2 [~.da ~2001.9.19]]
                  [%col3 [~.t 'Angel']]
                  [%col4 [~.t 'row3']]
                  ==
            ==
  =/  expected  :~  %results
                    [%message 'SELECT']
                    [%result-set expected-rows]
                    [%server-time ~2012.5.3]
                    [%message 'db1.dbo.my-table']
                    [%schema-time ~2012.5.1]
                    [%data-time ~2012.5.2]
                    [%vector-count 1]
                ==
  =^  mov1  agent
    %:  ~(on-poke agent (bowl [run ~2012.4.30]))
        %obelisk-action
        !>([%tape %sys "CREATE DATABASE db1"])
    ==
  =.  run  +(run)
  =^  mov2  agent
    %:  ~(on-poke agent (bowl [run ~2012.5.1]))
        %obelisk-action
        !>  :+  %tape
                %db1
                "CREATE TABLE db1..my-table ".
                "(col1 @t, col2 @da, col3 @t, col4 @t) ".
                "PRIMARY KEY (col1)"
    ==
    =.  run  +(run)
  =^  mov3  agent
    %:  ~(on-poke agent (bowl [run ~2012.5.2]))
        %obelisk-action
        !>  :+  %tape
                %db1
                "INSERT INTO my-table".
                " VALUES".
                " ('Abby', ~1999.2.19, 'tricolor', 'row1')".
                " ('Ace', ~2005.12.19, 'ticolor', 'row2')".
                " ('Angel', ~2001.9.19, 'Angel', 'row3')"
    ==
  =.  run  +(run)
  ::
  %+  expect-fail-message
      %-  crip
          "comparing columns of differing auras: %col1 %col2"
  |.  %:  ~(on-poke agent (bowl [run ~2012.5.2]))
          %obelisk-action
          !>([%tape %db1 "FROM my-table WHERE col1 <> col2 SELECT *"])
      ==
::
::  GT
::
::  WHERE <column> > <literal> (cord)
++  test-gt-00
  =|  run=@ud
  =/  expected-rows
        :~
          :-  %vector
              :~  [%col1 [~.t 'Abby']]
                  [%col2 [~.da ~1999.2.19]]
                  [%col3 [~.t 'tricolor']]
                  [%col4 [~.t 'row1']]
                  ==
          :-  %vector
              :~  [%col1 [~.t 'Angel']]
                  [%col2 [~.da ~2001.9.19]]
                  [%col3 [~.t 'tuxedo']]
                  [%col4 [~.t 'row3']]
                  ==
            ==
  =/  expected  :~  %results
                    [%message 'SELECT']
                    [%result-set expected-rows]
                    [%server-time ~2012.5.3]
                    [%message 'db1.dbo.my-table']
                    [%schema-time ~2012.5.1]
                    [%data-time ~2012.5.2]
                    [%vector-count 2]
                ==
  =^  mov1  agent
    %:  ~(on-poke agent (bowl [run ~2012.4.30]))
        %obelisk-action
        !>([%tape %sys "CREATE DATABASE db1"])
    ==
  =.  run  +(run)
  =^  mov2  agent
    %:  ~(on-poke agent (bowl [run ~2012.5.1]))
        %obelisk-action
        !>  :+  %tape
                %db1
                "CREATE TABLE db1..my-table ".
                "(col1 @t, col2 @da, col3 @t, col4 @t) ".
                "PRIMARY KEY (col1)"
    ==
    =.  run  +(run)
  =^  mov3  agent
    %:  ~(on-poke agent (bowl [run ~2012.5.2]))
        %obelisk-action
        !>  :+  %tape
                %db1
                "INSERT INTO my-table".
                " VALUES".
                " ('Abby', ~1999.2.19, 'tricolor', 'row1')".
                " ('Ace', ~2005.12.19, 'ticolor', 'row2')".
                " ('Angel', ~2001.9.19, 'tuxedo', 'row3')"
    ==
  =.  run  +(run)
  =^  mov4  agent
    %:  ~(on-poke agent (bowl [run ~2012.5.3]))
        %obelisk-action
        !>([%tape %db1 "FROM my-table WHERE col3 > 'toledo' SELECT *"])
    ==
  %+  expect-eq
    !>  expected
    !>  ;;(cmd-result ->+>+>-.mov4)
::
::  WHERE <column> > <literal> (@da)
++  test-gt-01
  =|  run=@ud
  =/  expected-rows
        :~
          :-  %vector
              :~  [%col1 [~.t 'Ace']]
                  [%col2 [~.da ~2005.12.19]]
                  [%col3 [~.t 'ticolor']]
                  [%col4 [~.t 'row2']]
                  ==
          :-  %vector
              :~  [%col1 [~.t 'Angel']]
                  [%col2 [~.da ~2001.9.19]]
                  [%col3 [~.t 'tuxedo']]
                  [%col4 [~.t 'row3']]
                  ==
            ==
  =/  expected  :~  %results
                    [%message 'SELECT']
                    [%result-set expected-rows]
                    [%server-time ~2012.5.3]
                    [%message 'db1.dbo.my-table']
                    [%schema-time ~2012.5.1]
                    [%data-time ~2012.5.2]
                    [%vector-count 2]
                ==
  =^  mov1  agent
    %:  ~(on-poke agent (bowl [run ~2012.4.30]))
        %obelisk-action
        !>([%tape %sys "CREATE DATABASE db1"])
    ==
  =.  run  +(run)
  =^  mov2  agent
    %:  ~(on-poke agent (bowl [run ~2012.5.1]))
        %obelisk-action
        !>  :+  %tape
                %db1
                "CREATE TABLE db1..my-table ".
                "(col1 @t, col2 @da, col3 @t, col4 @t) ".
                "PRIMARY KEY (col1)"
    ==
    =.  run  +(run)
  =^  mov3  agent
    %:  ~(on-poke agent (bowl [run ~2012.5.2]))
        %obelisk-action
        !>  :+  %tape
                %db1
                "INSERT INTO my-table".
                " VALUES".
                " ('Abby', ~1999.2.19, 'tricolor', 'row1')".
                " ('Ace', ~2005.12.19, 'ticolor', 'row2')".
                " ('Angel', ~2001.9.19, 'tuxedo', 'row3')"
    ==
  =.  run  +(run)
  =^  mov4  agent
    %:  ~(on-poke agent (bowl [run ~2012.5.3]))
        %obelisk-action
        !>([%tape %db1 "FROM my-table WHERE col2 > ~1999.2.19 SELECT *"])
    ==
  %+  expect-eq
    !>  expected
    !>  ;;(cmd-result ->+>+>-.mov4)
::
::  WHERE <literal> > <column>  (cord)
++  test-gt-02
  =|  run=@ud
  =/  expected-rows
        :~
          :-  %vector
              :~  [%col1 [~.t 'Ace']]
                  [%col2 [~.da ~2005.12.19]]
                  [%col3 [~.t 'ticolor']]
                  [%col4 [~.t 'row2']]
                  ==
            ==
  =/  expected  :~  %results
                    [%message 'SELECT']
                    [%result-set expected-rows]
                    [%server-time ~2012.5.3]
                    [%message 'db1.dbo.my-table']
                    [%schema-time ~2012.5.1]
                    [%data-time ~2012.5.2]
                    [%vector-count 1]
                ==
  =^  mov1  agent
    %:  ~(on-poke agent (bowl [run ~2012.4.30]))
        %obelisk-action
        !>([%tape %sys "CREATE DATABASE db1"])
    ==
  =.  run  +(run)
  =^  mov2  agent
    %:  ~(on-poke agent (bowl [run ~2012.5.1]))
        %obelisk-action
        !>  :+  %tape
                %db1
                "CREATE TABLE db1..my-table ".
                "(col1 @t, col2 @da, col3 @t, col4 @t) ".
                "PRIMARY KEY (col1)"
    ==
    =.  run  +(run)
  =^  mov3  agent
    %:  ~(on-poke agent (bowl [run ~2012.5.2]))
        %obelisk-action
        !>  :+  %tape
                %db1
                "INSERT INTO my-table".
                " VALUES".
                " ('Abby', ~1999.2.19, 'tricolor', 'row1')".
                " ('Ace', ~2005.12.19, 'ticolor', 'row2')".
                " ('Angel', ~2001.9.19, 'tuxedo', 'row3')"
    ==
  =.  run  +(run)
  =^  mov4  agent
    %:  ~(on-poke agent (bowl [run ~2012.5.3]))
        %obelisk-action
        !>([%tape %db1 "FROM my-table WHERE 'tricolor' > col3 SELECT *"])
    ==
  %+  expect-eq
    !>  expected
    !>  ;;(cmd-result ->+>+>-.mov4)

::
::  WHERE <column> > <column>  (cord)
++  test-gt-03
  =|  run=@ud
  =/  expected-rows
        :~
          :-  %vector
              :~  [%col1 [~.t 'Abby']]
                  [%col2 [~.da ~1999.2.19]]
                  [%col3 [~.t 'tricolor']]
                  [%col4 [~.t 'row1']]
                  ==
          :-  %vector
              :~  [%col1 [~.t 'Ace']]
                  [%col2 [~.da ~2005.12.19]]
                  [%col3 [~.t 'ticolor']]
                  [%col4 [~.t 'row2']]
                  ==
            ==
  =/  expected  :~  %results
                    [%message 'SELECT']
                    [%result-set expected-rows]
                    [%server-time ~2012.5.3]
                    [%message 'db1.dbo.my-table']
                    [%schema-time ~2012.5.1]
                    [%data-time ~2012.5.2]
                    [%vector-count 2]
                ==
  =^  mov1  agent
    %:  ~(on-poke agent (bowl [run ~2012.4.30]))
        %obelisk-action
        !>([%tape %sys "CREATE DATABASE db1"])
    ==
  =.  run  +(run)
  =^  mov2  agent
    %:  ~(on-poke agent (bowl [run ~2012.5.1]))
        %obelisk-action
        !>  :+  %tape
                %db1
                "CREATE TABLE db1..my-table ".
                "(col1 @t, col2 @da, col3 @t, col4 @t) ".
                "PRIMARY KEY (col1)"
    ==
  =.  run  +(run)
  =^  mov3  agent
    %:  ~(on-poke agent (bowl [run ~2012.5.2]))
        %obelisk-action
        !>  :+  %tape
                %db1
                "INSERT INTO my-table".
                " VALUES".
                " ('Abby', ~1999.2.19, 'tricolor', 'row1')".
                " ('Ace', ~2005.12.19, 'ticolor', 'row2')".
                " ('Angel', ~2001.9.19, 'Angel', 'row3')"
    ==
  =.  run  +(run)
  =^  mov4  agent
    %:  ~(on-poke agent (bowl [run ~2012.5.3]))
        %obelisk-action
        !>([%tape %db1 "FROM my-table WHERE col3 > col1 SELECT *"])
    ==
  %+  expect-eq
    !>  expected
    !>  ;;(cmd-result ->+>+>-.mov4)
::
::  WHERE <column> > <literal> (cord)
++  test-gt-04
  =|  run=@ud
  =/  expected-rows
        :~
          :-  %vector
              :~  [%col1 [~.t 'Ace']]
                  [%col2 [~.da ~2005.12.19]]
                  [%col3 [~.t 'ticolor']]
                  [%col4 [~.t 'row2']]
                  ==
          :-  %vector
              :~  [%col1 [~.t 'Angel']]
                  [%col2 [~.da ~2001.9.19]]
                  [%col3 [~.t 'tuxedo']]
                  [%col4 [~.t 'row3']]
                  ==
            ==
  =/  expected  :~  %results
                    [%message 'SELECT']
                    [%result-set expected-rows]
                    [%server-time ~2012.5.3]
                    [%message 'db1.dbo.my-table']
                    [%schema-time ~2012.5.1]
                    [%data-time ~2012.5.2]
                    [%vector-count 2]
                ==
  =^  mov1  agent
    %:  ~(on-poke agent (bowl [run ~2012.4.30]))
        %obelisk-action
        !>([%tape %sys "CREATE DATABASE db1"])
    ==
  =.  run  +(run)
  =^  mov2  agent
    %:  ~(on-poke agent (bowl [run ~2012.5.1]))
        %obelisk-action
        !>  :+  %tape
                %db1
                "CREATE TABLE db1..my-table ".
                "(col1 @t, col2 @da, col3 @t, col4 @t) ".
                "PRIMARY KEY (col3)"
    ==
  =.  run  +(run)
  =^  mov3  agent
    %:  ~(on-poke agent (bowl [run ~2012.5.2]))
        %obelisk-action
        !>  :+  %tape
                %db1
                "INSERT INTO my-table".
                " VALUES".
                " ('Abby', ~1999.2.19, 'tricolor', 'row1')".
                " ('Ace', ~2005.12.19, 'ticolor', 'row2')".
                " ('Angel', ~2001.9.19, 'tuxedo', 'row3')"
    ==
  =.  run  +(run)
  =^  mov4  agent
    %:  ~(on-poke agent (bowl [run ~2012.5.3]))
        %obelisk-action
        !>([%tape %db1 "FROM my-table WHERE col1 > 'Abbz' SELECT *"])
    ==
  %+  expect-eq
    !>  expected
    !>  ;;(cmd-result ->+>+>-.mov4)
::
::  view WHERE <column> > <literal>
++  test-gt-05
  =|  run=@ud
  =/  expected-rows
        :~
          :-  %vector
              :~  [p=%namespace q=[p=~.tas q=%dbo]]
                  [p=%name q=[p=~.tas q=%my-table]]
                  [p=%col-ordinal q=[p=~.ud q=1]]
                  [p=%col-name q=[p=~.tas q=%col1]]
                  [p=%col-type q=[p=~.ta q=~.t]]
                  ==
          :-  %vector
              :~  [p=%namespace q=[p=~.tas q=%dbo]]
                  [p=%name q=[p=~.tas q=%my-table]]
                  [p=%col-ordinal q=[p=~.ud q=2]]
                  [p=%col-name q=[p=~.tas q=%col2]]
                  [p=%col-type q=[p=~.ta q=~.da]]
                  ==
            ==
  =/  expected  :~  %results
                    [%message 'SELECT']
                    [%result-set expected-rows]
                    [%server-time ~2012.5.3]
                    [%message 'db1.sys.columns']
                    [%schema-time ~2012.5.1]
                    [%data-time ~2012.5.1]
                    [%vector-count 2]
                ==
  =^  mov1  agent
    %:  ~(on-poke agent (bowl [run ~2012.4.30]))
        %obelisk-action
        !>([%tape %sys "CREATE DATABASE db1"])
    ==
  =.  run  +(run)
  =^  mov2  agent
    %:  ~(on-poke agent (bowl [run ~2012.5.1]))
        %obelisk-action
        !>  :+  %tape
                %db1
                "CREATE TABLE db1..my-table ".
                "(col1 @t, col2 @da, col3 @t, col4 @t) ".
                "PRIMARY KEY (col1)"
    ==
  =.  run  +(run)
  =^  mov3  agent
    %:  ~(on-poke agent (bowl [run ~2012.5.3]))
        %obelisk-action
        !>([%tape %db1 "FROM sys.columns WHERE 'col3' > col-name SELECT *"])
    ==
  %+  expect-eq
    !>  expected
    !>  ;;(cmd-result ->+>+>-.mov3)
::
::  view WHERE <literal> > <literal>
++  test-gt-06
  =|  run=@ud
  =/  expected-rows
        :~
          :-  %vector
              :~  [p=%namespace q=[p=~.tas q=%dbo]]
                  [p=%name q=[p=~.tas q=%my-table]]
                  [p=%col-ordinal q=[p=~.ud q=1]]
                  [p=%col-name q=[p=~.tas q=%col1]]
                  [p=%col-type q=[p=~.ta q=~.t]]
                  ==
          :-  %vector
              :~  [p=%namespace q=[p=~.tas q=%dbo]]
                  [p=%name q=[p=~.tas q=%my-table]]
                  [p=%col-ordinal q=[p=~.ud q=2]]
                  [p=%col-name q=[p=~.tas q=%col2]]
                  [p=%col-type q=[p=~.ta q=~.da]]
                  ==
          :-  %vector
              :~  [p=%namespace q=[p=~.tas q=%dbo]]
                  [p=%name q=[p=~.tas q=%my-table]]
                  [p=%col-ordinal q=[p=~.ud q=3]]
                  [p=%col-name q=[p=~.tas q=%col3]]
                  [p=%col-type q=[p=~.ta q=~.t]]
                  ==
          :-  %vector
              :~  [p=%namespace q=[p=~.tas q=%dbo]]
                  [p=%name q=[p=~.tas q=%my-table]]
                  [p=%col-ordinal q=[p=~.ud q=4]]
                  [p=%col-name q=[p=~.tas q=%col4]]
                  [p=%col-type q=[p=~.ta q=~.t]]
                  ==
            ==
  =/  expected  :~  %results
                    [%message 'SELECT']
                    [%result-set expected-rows]
                    [%server-time ~2012.5.3]
                    [%message 'db1.sys.columns']
                    [%schema-time ~2012.5.1]
                    [%data-time ~2012.5.1]
                    [%vector-count 4]
                ==
  =^  mov1  agent
    %:  ~(on-poke agent (bowl [run ~2012.4.30]))
        %obelisk-action
        !>([%tape %sys "CREATE DATABASE db1"])
    ==
  =.  run  +(run)
  =^  mov2  agent
    %:  ~(on-poke agent (bowl [run ~2012.5.1]))
        %obelisk-action
        !>  :+  %tape
                %db1
                "CREATE TABLE db1..my-table ".
                "(col1 @t, col2 @da, col3 @t, col4 @t) ".
                "PRIMARY KEY (col1)"
    ==
  =.  run  +(run)
  =^  mov3  agent
    %:  ~(on-poke agent (bowl [run ~2012.5.3]))
        %obelisk-action
        !>([%tape %db1 "FROM sys.columns WHERE 2 > 1 SELECT *"])
    ==
  %+  expect-eq
    !>  expected
    !>  ;;(cmd-result ->+>+>-.mov3)
::
::  fail WHERE <column> > <literal> types differ
++  test-fail-gt-00
  =|  run=@ud
  =/  expected-rows
        :~
          :-  %vector
              :~  [%col1 [~.t 'Angel']]
                  [%col2 [~.da ~2001.9.19]]
                  [%col3 [~.t 'Angel']]
                  [%col4 [~.t 'row3']]
                  ==
            ==
  =/  expected  :~  %results
                    [%message 'SELECT']
                    [%result-set expected-rows]
                    [%server-time ~2012.5.3]
                    [%message 'db1.dbo.my-table']
                    [%schema-time ~2012.5.1]
                    [%data-time ~2012.5.2]
                    [%vector-count 1]
                ==
  =^  mov1  agent
    %:  ~(on-poke agent (bowl [run ~2012.4.30]))
        %obelisk-action
        !>([%tape %sys "CREATE DATABASE db1"])
    ==
  =.  run  +(run)
  =^  mov2  agent
    %:  ~(on-poke agent (bowl [run ~2012.5.1]))
        %obelisk-action
        !>  :+  %tape
                %db1
                "CREATE TABLE db1..my-table ".
                "(col1 @t, col2 @da, col3 @t, col4 @t) ".
                "PRIMARY KEY (col1)"
    ==
    =.  run  +(run)
  =^  mov3  agent
    %:  ~(on-poke agent (bowl [run ~2012.5.2]))
        %obelisk-action
        !>  :+  %tape
                %db1
                "INSERT INTO my-table".
                " VALUES".
                " ('Abby', ~1999.2.19, 'tricolor', 'row1')".
                " ('Ace', ~2005.12.19, 'ticolor', 'row2')".
                " ('Angel', ~2001.9.19, 'Angel', 'row3')"
    ==
  =.  run  +(run)
  ::
  %+  expect-fail-message
      %-  crip
          "comparing column to literal of different aura: %col1 "
  |.  %:  ~(on-poke agent (bowl [run ~2012.5.2]))
          %obelisk-action
          !>([%tape %db1 "FROM my-table WHERE col1 > ~1999.2.19 SELECT *"])
      ==
::
::  fail WHERE <literal> > <column> types differ
++  test-fail-gt-01
  =|  run=@ud
  =/  expected-rows
        :~
          :-  %vector
              :~  [%col1 [~.t 'Angel']]
                  [%col2 [~.da ~2001.9.19]]
                  [%col3 [~.t 'Angel']]
                  [%col4 [~.t 'row3']]
                  ==
            ==
  =/  expected  :~  %results
                    [%message 'SELECT']
                    [%result-set expected-rows]
                    [%server-time ~2012.5.3]
                    [%message 'db1.dbo.my-table']
                    [%schema-time ~2012.5.1]
                    [%data-time ~2012.5.2]
                    [%vector-count 1]
                ==
  =^  mov1  agent
    %:  ~(on-poke agent (bowl [run ~2012.4.30]))
        %obelisk-action
        !>([%tape %sys "CREATE DATABASE db1"])
    ==
  =.  run  +(run)
  =^  mov2  agent
    %:  ~(on-poke agent (bowl [run ~2012.5.1]))
        %obelisk-action
        !>  :+  %tape
                %db1
                "CREATE TABLE db1..my-table ".
                "(col1 @t, col2 @da, col3 @t, col4 @t) ".
                "PRIMARY KEY (col1)"
    ==
    =.  run  +(run)
  =^  mov3  agent
    %:  ~(on-poke agent (bowl [run ~2012.5.2]))
        %obelisk-action
        !>  :+  %tape
                %db1
                "INSERT INTO my-table".
                " VALUES".
                " ('Abby', ~1999.2.19, 'tricolor', 'row1')".
                " ('Ace', ~2005.12.19, 'ticolor', 'row2')".
                " ('Angel', ~2001.9.19, 'Angel', 'row3')"
    ==
  =.  run  +(run)
  ::
  %+  expect-fail-message
      %-  crip
          "comparing column to literal of different aura: %col1 "
  |.  %:  ~(on-poke agent (bowl [run ~2012.5.2]))
          %obelisk-action
          !>([%tape %db1 "FROM my-table WHERE ~1999.2.19 > col1 SELECT *"])
      ==
::
::  fail WHERE <column> > <column> types differ
++  test-fail-gt-02
  =|  run=@ud
  =/  expected-rows
        :~
          :-  %vector
              :~  [%col1 [~.t 'Angel']]
                  [%col2 [~.da ~2001.9.19]]
                  [%col3 [~.t 'Angel']]
                  [%col4 [~.t 'row3']]
                  ==
            ==
  =/  expected  :~  %results
                    [%message 'SELECT']
                    [%result-set expected-rows]
                    [%server-time ~2012.5.3]
                    [%message 'db1.dbo.my-table']
                    [%schema-time ~2012.5.1]
                    [%data-time ~2012.5.2]
                    [%vector-count 1]
                ==
  =^  mov1  agent
    %:  ~(on-poke agent (bowl [run ~2012.4.30]))
        %obelisk-action
        !>([%tape %sys "CREATE DATABASE db1"])
    ==
  =.  run  +(run)
  =^  mov2  agent
    %:  ~(on-poke agent (bowl [run ~2012.5.1]))
        %obelisk-action
        !>  :+  %tape
                %db1
                "CREATE TABLE db1..my-table ".
                "(col1 @t, col2 @da, col3 @t, col4 @t) ".
                "PRIMARY KEY (col1)"
    ==
    =.  run  +(run)
  =^  mov3  agent
    %:  ~(on-poke agent (bowl [run ~2012.5.2]))
        %obelisk-action
        !>  :+  %tape
                %db1
                "INSERT INTO my-table".
                " VALUES".
                " ('Abby', ~1999.2.19, 'tricolor', 'row1')".
                " ('Ace', ~2005.12.19, 'ticolor', 'row2')".
                " ('Angel', ~2001.9.19, 'Angel', 'row3')"
    ==
  =.  run  +(run)
  ::
  %+  expect-fail-message
      %-  crip
          "comparing columns of differing auras: %col1 %col2"
  |.  %:  ~(on-poke agent (bowl [run ~2012.5.2]))
          %obelisk-action
          !>([%tape %db1 "FROM my-table WHERE col1 > col2 SELECT *"])
      ==
::
::  LT
::
::  WHERE <column> < <literal> (cord)
++  test-lt-00
  =|  run=@ud
  =/  expected-rows
        :~
          :-  %vector
              :~  [%col1 [~.t 'Ace']]
                  [%col2 [~.da ~2005.12.19]]
                  [%col3 [~.t 'ticolor']]
                  [%col4 [~.t 'row2']]
                  ==
            ==
  =/  expected  :~  %results
                    [%message 'SELECT']
                    [%result-set expected-rows]
                    [%server-time ~2012.5.3]
                    [%message 'db1.dbo.my-table']
                    [%schema-time ~2012.5.1]
                    [%data-time ~2012.5.2]
                    [%vector-count 1]
                ==
  =^  mov1  agent
    %:  ~(on-poke agent (bowl [run ~2012.4.30]))
        %obelisk-action
        !>([%tape %sys "CREATE DATABASE db1"])
    ==
  =.  run  +(run)
  =^  mov2  agent
    %:  ~(on-poke agent (bowl [run ~2012.5.1]))
        %obelisk-action
        !>  :+  %tape
                %db1
                "CREATE TABLE db1..my-table ".
                "(col1 @t, col2 @da, col3 @t, col4 @t) ".
                "PRIMARY KEY (col1)"
    ==
    =.  run  +(run)
  =^  mov3  agent
    %:  ~(on-poke agent (bowl [run ~2012.5.2]))
        %obelisk-action
        !>  :+  %tape
                %db1
                "INSERT INTO my-table".
                " VALUES".
                " ('Abby', ~1999.2.19, 'tricolor', 'row1')".
                " ('Ace', ~2005.12.19, 'ticolor', 'row2')".
                " ('Angel', ~2001.9.19, 'tuxedo', 'row3')"
    ==
  =.  run  +(run)
  =^  mov4  agent
    %:  ~(on-poke agent (bowl [run ~2012.5.3]))
        %obelisk-action
        !>([%tape %db1 "FROM my-table WHERE col3 < 'toledo' SELECT *"])
    ==
  %+  expect-eq
    !>  expected
    !>  ;;(cmd-result ->+>+>-.mov4)
::
::  WHERE <column> < <literal> (@da)
++  test-lt-01
  =|  run=@ud
  =/  expected-rows
        :~
          :-  %vector
              :~  [%col1 [~.t 'Abby']]
                  [%col2 [~.da ~1999.2.19]]
                  [%col3 [~.t 'tricolor']]
                  [%col4 [~.t 'row1']]
                  ==
            ==
  =/  expected  :~  %results
                    [%message 'SELECT']
                    [%result-set expected-rows]
                    [%server-time ~2012.5.3]
                    [%message 'db1.dbo.my-table']
                    [%schema-time ~2012.5.1]
                    [%data-time ~2012.5.2]
                    [%vector-count 1]
                ==
  =^  mov1  agent
    %:  ~(on-poke agent (bowl [run ~2012.4.30]))
        %obelisk-action
        !>([%tape %sys "CREATE DATABASE db1"])
    ==
  =.  run  +(run)
  =^  mov2  agent
    %:  ~(on-poke agent (bowl [run ~2012.5.1]))
        %obelisk-action
        !>  :+  %tape
                %db1
                "CREATE TABLE db1..my-table ".
                "(col1 @t, col2 @da, col3 @t, col4 @t) ".
                "PRIMARY KEY (col1)"
    ==
    =.  run  +(run)
  =^  mov3  agent
    %:  ~(on-poke agent (bowl [run ~2012.5.2]))
        %obelisk-action
        !>  :+  %tape
                %db1
                "INSERT INTO my-table".
                " VALUES".
                " ('Abby', ~1999.2.19, 'tricolor', 'row1')".
                " ('Ace', ~2005.12.19, 'ticolor', 'row2')".
                " ('Angel', ~2001.9.19, 'tuxedo', 'row3')"
    ==
  =.  run  +(run)
  =^  mov4  agent
    %:  ~(on-poke agent (bowl [run ~2012.5.3]))
        %obelisk-action
        !>([%tape %db1 "FROM my-table WHERE col2 < ~2001.9.19 SELECT *"])
    ==
  %+  expect-eq
    !>  expected
    !>  ;;(cmd-result ->+>+>-.mov4)
::
::  WHERE <literal> < <column>  (cord)
++  test-lt-02
  =|  run=@ud
  =/  expected-rows
        :~
          :-  %vector
              :~  [%col1 [~.t 'Angel']]
                  [%col2 [~.da ~2001.9.19]]
                  [%col3 [~.t 'tuxedo']]
                  [%col4 [~.t 'row3']]
                  ==
            ==
  =/  expected  :~  %results
                    [%message 'SELECT']
                    [%result-set expected-rows]
                    [%server-time ~2012.5.3]
                    [%message 'db1.dbo.my-table']
                    [%schema-time ~2012.5.1]
                    [%data-time ~2012.5.2]
                    [%vector-count 1]
                ==
  =^  mov1  agent
    %:  ~(on-poke agent (bowl [run ~2012.4.30]))
        %obelisk-action
        !>([%tape %sys "CREATE DATABASE db1"])
    ==
  =.  run  +(run)
  =^  mov2  agent
    %:  ~(on-poke agent (bowl [run ~2012.5.1]))
        %obelisk-action
        !>  :+  %tape
                %db1
                "CREATE TABLE db1..my-table ".
                "(col1 @t, col2 @da, col3 @t, col4 @t) ".
                "PRIMARY KEY (col1)"
    ==
    =.  run  +(run)
  =^  mov3  agent
    %:  ~(on-poke agent (bowl [run ~2012.5.2]))
        %obelisk-action
        !>  :+  %tape
                %db1
                "INSERT INTO my-table".
                " VALUES".
                " ('Abby', ~1999.2.19, 'tricolor', 'row1')".
                " ('Ace', ~2005.12.19, 'ticolor', 'row2')".
                " ('Angel', ~2001.9.19, 'tuxedo', 'row3')"
    ==
  =.  run  +(run)
  =^  mov4  agent
    %:  ~(on-poke agent (bowl [run ~2012.5.3]))
        %obelisk-action
        !>([%tape %db1 "FROM my-table WHERE 'tricolor' < col3 SELECT *"])
    ==
  %+  expect-eq
    !>  expected
    !>  ;;(cmd-result ->+>+>-.mov4)
::
::  WHERE <column> < <column>  (cord)
++  test-lt-03
  =|  run=@ud
  =/  expected-rows
        :~
          :-  %vector
              :~  [%col1 [~.t 'Abby']]
                  [%col2 [~.da ~1999.2.19]]
                  [%col3 [~.t 'tricolor']]
                  [%col4 [~.t 'row1']]
                  ==
          :-  %vector
              :~  [%col1 [~.t 'Ace']]
                  [%col2 [~.da ~2005.12.19]]
                  [%col3 [~.t 'ticolor']]
                  [%col4 [~.t 'row2']]
                  ==
            ==
  =/  expected  :~  %results
                    [%message 'SELECT']
                    [%result-set expected-rows]
                    [%server-time ~2012.5.3]
                    [%message 'db1.dbo.my-table']
                    [%schema-time ~2012.5.1]
                    [%data-time ~2012.5.2]
                    [%vector-count 2]
                ==
  =^  mov1  agent
    %:  ~(on-poke agent (bowl [run ~2012.4.30]))
        %obelisk-action
        !>([%tape %sys "CREATE DATABASE db1"])
    ==
  =.  run  +(run)
  =^  mov2  agent
    %:  ~(on-poke agent (bowl [run ~2012.5.1]))
        %obelisk-action
        !>  :+  %tape
                %db1
                "CREATE TABLE db1..my-table ".
                "(col1 @t, col2 @da, col3 @t, col4 @t) ".
                "PRIMARY KEY (col1)"
    ==
  =.  run  +(run)
  =^  mov3  agent
    %:  ~(on-poke agent (bowl [run ~2012.5.2]))
        %obelisk-action
        !>  :+  %tape
                %db1
                "INSERT INTO my-table".
                " VALUES".
                " ('Abby', ~1999.2.19, 'tricolor', 'row1')".
                " ('Ace', ~2005.12.19, 'ticolor', 'row2')".
                " ('Angel', ~2001.9.19, 'Angel', 'row3')"
    ==
  =.  run  +(run)
  =^  mov4  agent
    %:  ~(on-poke agent (bowl [run ~2012.5.3]))
        %obelisk-action
        !>([%tape %db1 "FROM my-table WHERE col1 < col3 SELECT *"])
    ==
  %+  expect-eq
    !>  expected
    !>  ;;(cmd-result ->+>+>-.mov4)
::
::  WHERE <column> < <literal> (cord)
++  test-lt-04
  =|  run=@ud
  =/  expected-rows
        :~
          :-  %vector
              :~  [%col1 [~.t 'Ace']]
                  [%col2 [~.da ~2005.12.19]]
                  [%col3 [~.t 'ticolor']]
                  [%col4 [~.t 'row2']]
                  ==
          :-  %vector
              :~  [%col1 [~.t 'Abby']]
                  [%col2 [~.da ~1999.2.19]]
                  [%col3 [~.t 'tricolor']]
                  [%col4 [~.t 'row1']]
                  ==
            ==
  =/  expected  :~  %results
                    [%message 'SELECT']
                    [%result-set expected-rows]
                    [%server-time ~2012.5.3]
                    [%message 'db1.dbo.my-table']
                    [%schema-time ~2012.5.1]
                    [%data-time ~2012.5.2]
                    [%vector-count 2]
                ==
  =^  mov1  agent
    %:  ~(on-poke agent (bowl [run ~2012.4.30]))
        %obelisk-action
        !>([%tape %sys "CREATE DATABASE db1"])
    ==
  =.  run  +(run)
  =^  mov2  agent
    %:  ~(on-poke agent (bowl [run ~2012.5.1]))
        %obelisk-action
        !>  :+  %tape
                %db1
                "CREATE TABLE db1..my-table ".
                "(col1 @t, col2 @da, col3 @t, col4 @t) ".
                "PRIMARY KEY (col3)"
    ==
  =.  run  +(run)
  =^  mov3  agent
    %:  ~(on-poke agent (bowl [run ~2012.5.2]))
        %obelisk-action
        !>  :+  %tape
                %db1
                "INSERT INTO my-table".
                " VALUES".
                " ('Abby', ~1999.2.19, 'tricolor', 'row1')".
                " ('Ace', ~2005.12.19, 'ticolor', 'row2')".
                " ('Angel', ~2001.9.19, 'tuxedo', 'row3')"
    ==
  =.  run  +(run)
  =^  mov4  agent
    %:  ~(on-poke agent (bowl [run ~2012.5.3]))
        %obelisk-action
        !>([%tape %db1 "FROM my-table WHERE col1 < 'Angel' SELECT *"])
    ==
  %+  expect-eq
    !>  expected
    !>  ;;(cmd-result ->+>+>-.mov4)
::
::  view WHERE <column> < <literal>
++  test-lt-05
  =|  run=@ud
  =/  expected-rows
        :~
          :-  %vector
              :~  [p=%namespace q=[p=~.tas q=%dbo]]
                  [p=%name q=[p=~.tas q=%my-table]]
                  [p=%col-ordinal q=[p=~.ud q=3]]
                  [p=%col-name q=[p=~.tas q=%col3]]
                  [p=%col-type q=[p=~.ta q=~.t]]
                  ==
          :-  %vector
              :~  [p=%namespace q=[p=~.tas q=%dbo]]
                  [p=%name q=[p=~.tas q=%my-table]]
                  [p=%col-ordinal q=[p=~.ud q=4]]
                  [p=%col-name q=[p=~.tas q=%col4]]
                  [p=%col-type q=[p=~.ta q=~.t]]
                  ==
            ==
  =/  expected  :~  %results
                    [%message 'SELECT']
                    [%result-set expected-rows]
                    [%server-time ~2012.5.3]
                    [%message 'db1.sys.columns']
                    [%schema-time ~2012.5.1]
                    [%data-time ~2012.5.1]
                    [%vector-count 2]
                ==
  =^  mov1  agent
    %:  ~(on-poke agent (bowl [run ~2012.4.30]))
        %obelisk-action
        !>([%tape %sys "CREATE DATABASE db1"])
    ==
  =.  run  +(run)
  =^  mov2  agent
    %:  ~(on-poke agent (bowl [run ~2012.5.1]))
        %obelisk-action
        !>  :+  %tape
                %db1
                "CREATE TABLE db1..my-table ".
                "(col1 @t, col2 @da, col3 @t, col4 @t) ".
                "PRIMARY KEY (col1)"
    ==
  =.  run  +(run)
  =^  mov3  agent
    %:  ~(on-poke agent (bowl [run ~2012.5.3]))
        %obelisk-action
        !>([%tape %db1 "FROM sys.columns WHERE 'col2' < col-name SELECT *"])
    ==
  %+  expect-eq
    !>  expected
    !>  ;;(cmd-result ->+>+>-.mov3)
::
::  view WHERE <literal> < <literal>
++  test-lt-06
  =|  run=@ud
  =/  expected  :~  %results
                    [%message 'SELECT']
                    [%result-set ~]
                    [%server-time ~2012.5.3]
                    [%message 'db1.sys.columns']
                    [%schema-time ~2012.5.1]
                    [%data-time ~2012.5.1]
                    [%vector-count 0]
                ==
  =^  mov1  agent
    %:  ~(on-poke agent (bowl [run ~2012.4.30]))
        %obelisk-action
        !>([%tape %sys "CREATE DATABASE db1"])
    ==
  =.  run  +(run)
  =^  mov2  agent
    %:  ~(on-poke agent (bowl [run ~2012.5.1]))
        %obelisk-action
        !>  :+  %tape
                %db1
                "CREATE TABLE db1..my-table ".
                "(col1 @t, col2 @da, col3 @t, col4 @t) ".
                "PRIMARY KEY (col1)"
    ==
  =.  run  +(run)
  =^  mov3  agent
    %:  ~(on-poke agent (bowl [run ~2012.5.3]))
        %obelisk-action
        !>([%tape %db1 "FROM sys.columns WHERE 2 < 1 SELECT *"])
    ==
  %+  expect-eq
    !>  expected
    !>  ;;(cmd-result ->+>+>-.mov3)
::
::  fail WHERE <column> < <literal> types differ
++  test-fail-lt-00
  =|  run=@ud
  =/  expected-rows
        :~
          :-  %vector
              :~  [%col1 [~.t 'Angel']]
                  [%col2 [~.da ~2001.9.19]]
                  [%col3 [~.t 'Angel']]
                  [%col4 [~.t 'row3']]
                  ==
            ==
  =/  expected  :~  %results
                    [%message 'SELECT']
                    [%result-set expected-rows]
                    [%server-time ~2012.5.3]
                    [%message 'db1.dbo.my-table']
                    [%schema-time ~2012.5.1]
                    [%data-time ~2012.5.2]
                    [%vector-count 1]
                ==
  =^  mov1  agent
    %:  ~(on-poke agent (bowl [run ~2012.4.30]))
        %obelisk-action
        !>([%tape %sys "CREATE DATABASE db1"])
    ==
  =.  run  +(run)
  =^  mov2  agent
    %:  ~(on-poke agent (bowl [run ~2012.5.1]))
        %obelisk-action
        !>  :+  %tape
                %db1
                "CREATE TABLE db1..my-table ".
                "(col1 @t, col2 @da, col3 @t, col4 @t) ".
                "PRIMARY KEY (col1)"
    ==
    =.  run  +(run)
  =^  mov3  agent
    %:  ~(on-poke agent (bowl [run ~2012.5.2]))
        %obelisk-action
        !>  :+  %tape
                %db1
                "INSERT INTO my-table".
                " VALUES".
                " ('Abby', ~1999.2.19, 'tricolor', 'row1')".
                " ('Ace', ~2005.12.19, 'ticolor', 'row2')".
                " ('Angel', ~2001.9.19, 'Angel', 'row3')"
    ==
  =.  run  +(run)
  ::
  %+  expect-fail-message
      %-  crip
          "comparing column to literal of different aura: %col1 "
  |.  %:  ~(on-poke agent (bowl [run ~2012.5.2]))
          %obelisk-action
          !>([%tape %db1 "FROM my-table WHERE col1 < ~1999.2.19 SELECT *"])
      ==
::
::  fail WHERE <literal> < <column> types differ
++  test-fail-lt-01
  =|  run=@ud
  =/  expected-rows
        :~
          :-  %vector
              :~  [%col1 [~.t 'Angel']]
                  [%col2 [~.da ~2001.9.19]]
                  [%col3 [~.t 'Angel']]
                  [%col4 [~.t 'row3']]
                  ==
            ==
  =/  expected  :~  %results
                    [%message 'SELECT']
                    [%result-set expected-rows]
                    [%server-time ~2012.5.3]
                    [%message 'db1.dbo.my-table']
                    [%schema-time ~2012.5.1]
                    [%data-time ~2012.5.2]
                    [%vector-count 1]
                ==
  =^  mov1  agent
    %:  ~(on-poke agent (bowl [run ~2012.4.30]))
        %obelisk-action
        !>([%tape %sys "CREATE DATABASE db1"])
    ==
  =.  run  +(run)
  =^  mov2  agent
    %:  ~(on-poke agent (bowl [run ~2012.5.1]))
        %obelisk-action
        !>  :+  %tape
                %db1
                "CREATE TABLE db1..my-table ".
                "(col1 @t, col2 @da, col3 @t, col4 @t) ".
                "PRIMARY KEY (col1)"
    ==
    =.  run  +(run)
  =^  mov3  agent
    %:  ~(on-poke agent (bowl [run ~2012.5.2]))
        %obelisk-action
        !>  :+  %tape
                %db1
                "INSERT INTO my-table".
                " VALUES".
                " ('Abby', ~1999.2.19, 'tricolor', 'row1')".
                " ('Ace', ~2005.12.19, 'ticolor', 'row2')".
                " ('Angel', ~2001.9.19, 'Angel', 'row3')"
    ==
  =.  run  +(run)
  ::
  %+  expect-fail-message
      %-  crip
          "comparing column to literal of different aura: %col1 "
  |.  %:  ~(on-poke agent (bowl [run ~2012.5.2]))
          %obelisk-action
          !>([%tape %db1 "FROM my-table WHERE ~1999.2.19 < col1 SELECT *"])
      ==
::
::  fail WHERE <column> < <column> types differ
++  test-fail-lt-02
  =|  run=@ud
  =/  expected-rows
        :~
          :-  %vector
              :~  [%col1 [~.t 'Angel']]
                  [%col2 [~.da ~2001.9.19]]
                  [%col3 [~.t 'Angel']]
                  [%col4 [~.t 'row3']]
                  ==
            ==
  =/  expected  :~  %results
                    [%message 'SELECT']
                    [%result-set expected-rows]
                    [%server-time ~2012.5.3]
                    [%message 'db1.dbo.my-table']
                    [%schema-time ~2012.5.1]
                    [%data-time ~2012.5.2]
                    [%vector-count 1]
                ==
  =^  mov1  agent
    %:  ~(on-poke agent (bowl [run ~2012.4.30]))
        %obelisk-action
        !>([%tape %sys "CREATE DATABASE db1"])
    ==
  =.  run  +(run)
  =^  mov2  agent
    %:  ~(on-poke agent (bowl [run ~2012.5.1]))
        %obelisk-action
        !>  :+  %tape
                %db1
                "CREATE TABLE db1..my-table ".
                "(col1 @t, col2 @da, col3 @t, col4 @t) ".
                "PRIMARY KEY (col1)"
    ==
    =.  run  +(run)
  =^  mov3  agent
    %:  ~(on-poke agent (bowl [run ~2012.5.2]))
        %obelisk-action
        !>  :+  %tape
                %db1
                "INSERT INTO my-table".
                " VALUES".
                " ('Abby', ~1999.2.19, 'tricolor', 'row1')".
                " ('Ace', ~2005.12.19, 'ticolor', 'row2')".
                " ('Angel', ~2001.9.19, 'Angel', 'row3')"
    ==
  =.  run  +(run)
  ::
  %+  expect-fail-message
      %-  crip
          "comparing columns of differing auras: %col1 %col2"
  |.  %:  ~(on-poke agent (bowl [run ~2012.5.2]))
          %obelisk-action
          !>([%tape %db1 "FROM my-table WHERE col1 < col2 SELECT *"])
      ==
::
::  GTE
::
::  WHERE <column> >= <literal> (cord)
++  test-gte-00
  =|  run=@ud
  =/  expected-rows
        :~
          :-  %vector
              :~  [%col1 [~.t 'Abby']]
                  [%col2 [~.da ~1999.2.19]]
                  [%col3 [~.t 'tricolor']]
                  [%col4 [~.t 'row1']]
                  ==
          :-  %vector
              :~  [%col1 [~.t 'Angel']]
                  [%col2 [~.da ~2001.9.19]]
                  [%col3 [~.t 'tuxedo']]
                  [%col4 [~.t 'row3']]
                  ==
            ==
  =/  expected  :~  %results
                    [%message 'SELECT']
                    [%result-set expected-rows]
                    [%server-time ~2012.5.3]
                    [%message 'db1.dbo.my-table']
                    [%schema-time ~2012.5.1]
                    [%data-time ~2012.5.2]
                    [%vector-count 2]
                ==
  =^  mov1  agent
    %:  ~(on-poke agent (bowl [run ~2012.4.30]))
        %obelisk-action
        !>([%tape %sys "CREATE DATABASE db1"])
    ==
  =.  run  +(run)
  =^  mov2  agent
    %:  ~(on-poke agent (bowl [run ~2012.5.1]))
        %obelisk-action
        !>  :+  %tape
                %db1
                "CREATE TABLE db1..my-table ".
                "(col1 @t, col2 @da, col3 @t, col4 @t) ".
                "PRIMARY KEY (col1)"
    ==
    =.  run  +(run)
  =^  mov3  agent
    %:  ~(on-poke agent (bowl [run ~2012.5.2]))
        %obelisk-action
        !>  :+  %tape
                %db1
                "INSERT INTO my-table".
                " VALUES".
                " ('Abby', ~1999.2.19, 'tricolor', 'row1')".
                " ('Ace', ~2005.12.19, 'ticolor', 'row2')".
                " ('Angel', ~2001.9.19, 'tuxedo', 'row3')"
    ==
  =.  run  +(run)
  =^  mov4  agent
    %:  ~(on-poke agent (bowl [run ~2012.5.3]))
        %obelisk-action
        !>([%tape %db1 "FROM my-table WHERE col3 >= 'tricolor' SELECT *"])
    ==
  %+  expect-eq
    !>  expected
    !>  ;;(cmd-result ->+>+>-.mov4)
::
::  WHERE <column> >= <literal> (@da)
++  test-gte-01
  =|  run=@ud
  =/  expected-rows
        :~
          :-  %vector
              :~  [%col1 [~.t 'Abby']]
                  [%col2 [~.da ~1999.2.19]]
                  [%col3 [~.t 'tricolor']]
                  [%col4 [~.t 'row1']]
                  ==
          :-  %vector
              :~  [%col1 [~.t 'Ace']]
                  [%col2 [~.da ~2005.12.19]]
                  [%col3 [~.t 'ticolor']]
                  [%col4 [~.t 'row2']]
                  ==
          :-  %vector
              :~  [%col1 [~.t 'Angel']]
                  [%col2 [~.da ~2001.9.19]]
                  [%col3 [~.t 'tuxedo']]
                  [%col4 [~.t 'row3']]
                  ==
            ==
  =/  expected  :~  %results
                    [%message 'SELECT']
                    [%result-set expected-rows]
                    [%server-time ~2012.5.3]
                    [%message 'db1.dbo.my-table']
                    [%schema-time ~2012.5.1]
                    [%data-time ~2012.5.2]
                    [%vector-count 3]
                ==
  =^  mov1  agent
    %:  ~(on-poke agent (bowl [run ~2012.4.30]))
        %obelisk-action
        !>([%tape %sys "CREATE DATABASE db1"])
    ==
  =.  run  +(run)
  =^  mov2  agent
    %:  ~(on-poke agent (bowl [run ~2012.5.1]))
        %obelisk-action
        !>  :+  %tape
                %db1
                "CREATE TABLE db1..my-table ".
                "(col1 @t, col2 @da, col3 @t, col4 @t) ".
                "PRIMARY KEY (col1)"
    ==
    =.  run  +(run)
  =^  mov3  agent
    %:  ~(on-poke agent (bowl [run ~2012.5.2]))
        %obelisk-action
        !>  :+  %tape
                %db1
                "INSERT INTO my-table".
                " VALUES".
                " ('Abby', ~1999.2.19, 'tricolor', 'row1')".
                " ('Ace', ~2005.12.19, 'ticolor', 'row2')".
                " ('Angel', ~2001.9.19, 'tuxedo', 'row3')"
    ==
  =.  run  +(run)
  =^  mov4  agent
    %:  ~(on-poke agent (bowl [run ~2012.5.3]))
        %obelisk-action
        !>([%tape %db1 "FROM my-table WHERE col2 >= ~1999.2.19 SELECT *"])
    ==
  %+  expect-eq
    !>  expected
    !>  ;;(cmd-result ->+>+>-.mov4)
::
::  WHERE <literal> >= <column>  (cord)
++  test-gte-02
  =|  run=@ud
  =/  expected-rows
        :~
          :-  %vector
              :~  [%col1 [~.t 'Abby']]
                  [%col2 [~.da ~1999.2.19]]
                  [%col3 [~.t 'tricolor']]
                  [%col4 [~.t 'row1']]
                  ==
          :-  %vector
              :~  [%col1 [~.t 'Ace']]
                  [%col2 [~.da ~2005.12.19]]
                  [%col3 [~.t 'ticolor']]
                  [%col4 [~.t 'row2']]
                  ==
            ==
  =/  expected  :~  %results
                    [%message 'SELECT']
                    [%result-set expected-rows]
                    [%server-time ~2012.5.3]
                    [%message 'db1.dbo.my-table']
                    [%schema-time ~2012.5.1]
                    [%data-time ~2012.5.2]
                    [%vector-count 2]
                ==
  =^  mov1  agent
    %:  ~(on-poke agent (bowl [run ~2012.4.30]))
        %obelisk-action
        !>([%tape %sys "CREATE DATABASE db1"])
    ==
  =.  run  +(run)
  =^  mov2  agent
    %:  ~(on-poke agent (bowl [run ~2012.5.1]))
        %obelisk-action
        !>  :+  %tape
                %db1
                "CREATE TABLE db1..my-table ".
                "(col1 @t, col2 @da, col3 @t, col4 @t) ".
                "PRIMARY KEY (col1)"
    ==
    =.  run  +(run)
  =^  mov3  agent
    %:  ~(on-poke agent (bowl [run ~2012.5.2]))
        %obelisk-action
        !>  :+  %tape
                %db1
                "INSERT INTO my-table".
                " VALUES".
                " ('Abby', ~1999.2.19, 'tricolor', 'row1')".
                " ('Ace', ~2005.12.19, 'ticolor', 'row2')".
                " ('Angel', ~2001.9.19, 'tuxedo', 'row3')"
    ==
  =.  run  +(run)
  =^  mov4  agent
    %:  ~(on-poke agent (bowl [run ~2012.5.3]))
        %obelisk-action
        !>([%tape %db1 "FROM my-table WHERE 'tricolor' >= col3 SELECT *"])
    ==
  %+  expect-eq
    !>  expected
    !>  ;;(cmd-result ->+>+>-.mov4)
::
::  WHERE <column> >= <column>  (cord)
++  test-gte-03
  =|  run=@ud
  =/  expected-rows
        :~
          :-  %vector
              :~  [%col1 [~.t 'Abby']]
                  [%col2 [~.da ~1999.2.19]]
                  [%col3 [~.t 'tricolor']]
                  [%col4 [~.t 'row1']]
                  ==
          :-  %vector
              :~  [%col1 [~.t 'Ace']]
                  [%col2 [~.da ~2005.12.19]]
                  [%col3 [~.t 'ticolor']]
                  [%col4 [~.t 'row2']]
                  ==
          :-  %vector
              :~  [%col1 [~.t 'Angel']]
                  [%col2 [~.da ~2001.9.19]]
                  [%col3 [~.t 'Angel']]
                  [%col4 [~.t 'row3']]
                  ==
            ==
  =/  expected  :~  %results
                    [%message 'SELECT']
                    [%result-set expected-rows]
                    [%server-time ~2012.5.3]
                    [%message 'db1.dbo.my-table']
                    [%schema-time ~2012.5.1]
                    [%data-time ~2012.5.2]
                    [%vector-count 3]
                ==
  =^  mov1  agent
    %:  ~(on-poke agent (bowl [run ~2012.4.30]))
        %obelisk-action
        !>([%tape %sys "CREATE DATABASE db1"])
    ==
  =.  run  +(run)
  =^  mov2  agent
    %:  ~(on-poke agent (bowl [run ~2012.5.1]))
        %obelisk-action
        !>  :+  %tape
                %db1
                "CREATE TABLE db1..my-table ".
                "(col1 @t, col2 @da, col3 @t, col4 @t) ".
                "PRIMARY KEY (col1)"
    ==
  =.  run  +(run)
  =^  mov3  agent
    %:  ~(on-poke agent (bowl [run ~2012.5.2]))
        %obelisk-action
        !>  :+  %tape
                %db1
                "INSERT INTO my-table".
                " VALUES".
                " ('Abby', ~1999.2.19, 'tricolor', 'row1')".
                " ('Ace', ~2005.12.19, 'ticolor', 'row2')".
                " ('Angel', ~2001.9.19, 'Angel', 'row3')"
    ==
  =.  run  +(run)
  =^  mov4  agent
    %:  ~(on-poke agent (bowl [run ~2012.5.3]))
        %obelisk-action
        !>([%tape %db1 "FROM my-table WHERE col3 >= col1 SELECT *"])
    ==
  %+  expect-eq
    !>  expected
    !>  ;;(cmd-result ->+>+>-.mov4)
::
::  WHERE <column> >= <literal> (cord)
++  test-gte-04
  =|  run=@ud
  =/  expected-rows
        :~
          :-  %vector
              :~  [%col1 [~.t 'Ace']]
                  [%col2 [~.da ~2005.12.19]]
                  [%col3 [~.t 'ticolor']]
                  [%col4 [~.t 'row2']]
                  ==
          :-  %vector
              :~  [%col1 [~.t 'Angel']]
                  [%col2 [~.da ~2001.9.19]]
                  [%col3 [~.t 'tuxedo']]
                  [%col4 [~.t 'row3']]
                  ==
            ==
  =/  expected  :~  %results
                    [%message 'SELECT']
                    [%result-set expected-rows]
                    [%server-time ~2012.5.3]
                    [%message 'db1.dbo.my-table']
                    [%schema-time ~2012.5.1]
                    [%data-time ~2012.5.2]
                    [%vector-count 2]
                ==
  =^  mov1  agent
    %:  ~(on-poke agent (bowl [run ~2012.4.30]))
        %obelisk-action
        !>([%tape %sys "CREATE DATABASE db1"])
    ==
  =.  run  +(run)
  =^  mov2  agent
    %:  ~(on-poke agent (bowl [run ~2012.5.1]))
        %obelisk-action
        !>  :+  %tape
                %db1
                "CREATE TABLE db1..my-table ".
                "(col1 @t, col2 @da, col3 @t, col4 @t) ".
                "PRIMARY KEY (col3)"
    ==
  =.  run  +(run)
  =^  mov3  agent
    %:  ~(on-poke agent (bowl [run ~2012.5.2]))
        %obelisk-action
        !>  :+  %tape
                %db1
                "INSERT INTO my-table".
                " VALUES".
                " ('Abby', ~1999.2.19, 'tricolor', 'row1')".
                " ('Ace', ~2005.12.19, 'ticolor', 'row2')".
                " ('Angel', ~2001.9.19, 'tuxedo', 'row3')"
    ==
  =.  run  +(run)
  =^  mov4  agent
    %:  ~(on-poke agent (bowl [run ~2012.5.3]))
        %obelisk-action
        !>([%tape %db1 "FROM my-table WHERE col1 >= 'Ace' SELECT *"])
    ==
  %+  expect-eq
    !>  expected
    !>  ;;(cmd-result ->+>+>-.mov4)
::
::  view WHERE <column> >= <literal>
++  test-gte-05
  =|  run=@ud
  =/  expected-rows
        :~
          :-  %vector
              :~  [p=%namespace q=[p=~.tas q=%dbo]]
                  [p=%name q=[p=~.tas q=%my-table]]
                  [p=%col-ordinal q=[p=~.ud q=1]]
                  [p=%col-name q=[p=~.tas q=%col1]]
                  [p=%col-type q=[p=~.ta q=~.t]]
                  ==
          :-  %vector
              :~  [p=%namespace q=[p=~.tas q=%dbo]]
                  [p=%name q=[p=~.tas q=%my-table]]
                  [p=%col-ordinal q=[p=~.ud q=2]]
                  [p=%col-name q=[p=~.tas q=%col2]]
                  [p=%col-type q=[p=~.ta q=~.da]]
                  ==
          :-  %vector
              :~  [p=%namespace q=[p=~.tas q=%dbo]]
                  [p=%name q=[p=~.tas q=%my-table]]
                  [p=%col-ordinal q=[p=~.ud q=3]]
                  [p=%col-name q=[p=~.tas q=%col3]]
                  [p=%col-type q=[p=~.ta q=~.t]]
                  ==
            ==
  =/  expected  :~  %results
                    [%message 'SELECT']
                    [%result-set expected-rows]
                    [%server-time ~2012.5.3]
                    [%message 'db1.sys.columns']
                    [%schema-time ~2012.5.1]
                    [%data-time ~2012.5.1]
                    [%vector-count 3]
                ==
  =^  mov1  agent
    %:  ~(on-poke agent (bowl [run ~2012.4.30]))
        %obelisk-action
        !>([%tape %sys "CREATE DATABASE db1"])
    ==
  =.  run  +(run)
  =^  mov2  agent
    %:  ~(on-poke agent (bowl [run ~2012.5.1]))
        %obelisk-action
        !>  :+  %tape
                %db1
                "CREATE TABLE db1..my-table ".
                "(col1 @t, col2 @da, col3 @t, col4 @t) ".
                "PRIMARY KEY (col1)"
    ==
  =.  run  +(run)
  =^  mov3  agent
    %:  ~(on-poke agent (bowl [run ~2012.5.3]))
        %obelisk-action
        !>([%tape %db1 "FROM sys.columns WHERE 'col3' >= col-name SELECT *"])
    ==
  %+  expect-eq
    !>  expected
    !>  ;;(cmd-result ->+>+>-.mov3)
::
::  view WHERE <literal> >= <literal>
++  test-gte-06
  =|  run=@ud
  =/  expected-rows
        :~
          :-  %vector
              :~  [p=%namespace q=[p=~.tas q=%dbo]]
                  [p=%name q=[p=~.tas q=%my-table]]
                  [p=%col-ordinal q=[p=~.ud q=1]]
                  [p=%col-name q=[p=~.tas q=%col1]]
                  [p=%col-type q=[p=~.ta q=~.t]]
                  ==
          :-  %vector
              :~  [p=%namespace q=[p=~.tas q=%dbo]]
                  [p=%name q=[p=~.tas q=%my-table]]
                  [p=%col-ordinal q=[p=~.ud q=2]]
                  [p=%col-name q=[p=~.tas q=%col2]]
                  [p=%col-type q=[p=~.ta q=~.da]]
                  ==
          :-  %vector
              :~  [p=%namespace q=[p=~.tas q=%dbo]]
                  [p=%name q=[p=~.tas q=%my-table]]
                  [p=%col-ordinal q=[p=~.ud q=3]]
                  [p=%col-name q=[p=~.tas q=%col3]]
                  [p=%col-type q=[p=~.ta q=~.t]]
                  ==
          :-  %vector
              :~  [p=%namespace q=[p=~.tas q=%dbo]]
                  [p=%name q=[p=~.tas q=%my-table]]
                  [p=%col-ordinal q=[p=~.ud q=4]]
                  [p=%col-name q=[p=~.tas q=%col4]]
                  [p=%col-type q=[p=~.ta q=~.t]]
                  ==
            ==
  =/  expected  :~  %results
                    [%message 'SELECT']
                    [%result-set expected-rows]
                    [%server-time ~2012.5.3]
                    [%message 'db1.sys.columns']
                    [%schema-time ~2012.5.1]
                    [%data-time ~2012.5.1]
                    [%vector-count 4]
                ==
  =^  mov1  agent
    %:  ~(on-poke agent (bowl [run ~2012.4.30]))
        %obelisk-action
        !>([%tape %sys "CREATE DATABASE db1"])
    ==
  =.  run  +(run)
  =^  mov2  agent
    %:  ~(on-poke agent (bowl [run ~2012.5.1]))
        %obelisk-action
        !>  :+  %tape
                %db1
                "CREATE TABLE db1..my-table ".
                "(col1 @t, col2 @da, col3 @t, col4 @t) ".
                "PRIMARY KEY (col1)"
    ==
  =.  run  +(run)
  =^  mov3  agent
    %:  ~(on-poke agent (bowl [run ~2012.5.3]))
        %obelisk-action
        !>([%tape %db1 "FROM sys.columns WHERE 2 >= 1 SELECT *"])
    ==
  %+  expect-eq
    !>  expected
    !>  ;;(cmd-result ->+>+>-.mov3)
::
::  fail WHERE <column> >= <literal> types differ
++  test-fail-gte-00
  =|  run=@ud
  =/  expected-rows
        :~
          :-  %vector
              :~  [%col1 [~.t 'Angel']]
                  [%col2 [~.da ~2001.9.19]]
                  [%col3 [~.t 'Angel']]
                  [%col4 [~.t 'row3']]
                  ==
            ==
  =/  expected  :~  %results
                    [%message 'SELECT']
                    [%result-set expected-rows]
                    [%server-time ~2012.5.3]
                    [%message 'db1.dbo.my-table']
                    [%schema-time ~2012.5.1]
                    [%data-time ~2012.5.2]
                    [%vector-count 1]
                ==
  =^  mov1  agent
    %:  ~(on-poke agent (bowl [run ~2012.4.30]))
        %obelisk-action
        !>([%tape %sys "CREATE DATABASE db1"])
    ==
  =.  run  +(run)
  =^  mov2  agent
    %:  ~(on-poke agent (bowl [run ~2012.5.1]))
        %obelisk-action
        !>  :+  %tape
                %db1
                "CREATE TABLE db1..my-table ".
                "(col1 @t, col2 @da, col3 @t, col4 @t) ".
                "PRIMARY KEY (col1)"
    ==
    =.  run  +(run)
  =^  mov3  agent
    %:  ~(on-poke agent (bowl [run ~2012.5.2]))
        %obelisk-action
        !>  :+  %tape
                %db1
                "INSERT INTO my-table".
                " VALUES".
                " ('Abby', ~1999.2.19, 'tricolor', 'row1')".
                " ('Ace', ~2005.12.19, 'ticolor', 'row2')".
                " ('Angel', ~2001.9.19, 'Angel', 'row3')"
    ==
  =.  run  +(run)
  ::
  %+  expect-fail-message
      %-  crip
          "comparing column to literal of different aura: %col1 "
  |.  %:  ~(on-poke agent (bowl [run ~2012.5.2]))
          %obelisk-action
          !>([%tape %db1 "FROM my-table WHERE col1 >= ~1999.2.19 SELECT *"])
      ==
::
::  fail WHERE <literal> >= <column> types differ
++  test-fail-gte-01
  =|  run=@ud
  =/  expected-rows
        :~
          :-  %vector
              :~  [%col1 [~.t 'Angel']]
                  [%col2 [~.da ~2001.9.19]]
                  [%col3 [~.t 'Angel']]
                  [%col4 [~.t 'row3']]
                  ==
            ==
  =/  expected  :~  %results
                    [%message 'SELECT']
                    [%result-set expected-rows]
                    [%server-time ~2012.5.3]
                    [%message 'db1.dbo.my-table']
                    [%schema-time ~2012.5.1]
                    [%data-time ~2012.5.2]
                    [%vector-count 1]
                ==
  =^  mov1  agent
    %:  ~(on-poke agent (bowl [run ~2012.4.30]))
        %obelisk-action
        !>([%tape %sys "CREATE DATABASE db1"])
    ==
  =.  run  +(run)
  =^  mov2  agent
    %:  ~(on-poke agent (bowl [run ~2012.5.1]))
        %obelisk-action
        !>  :+  %tape
                %db1
                "CREATE TABLE db1..my-table ".
                "(col1 @t, col2 @da, col3 @t, col4 @t) ".
                "PRIMARY KEY (col1)"
    ==
    =.  run  +(run)
  =^  mov3  agent
    %:  ~(on-poke agent (bowl [run ~2012.5.2]))
        %obelisk-action
        !>  :+  %tape
                %db1
                "INSERT INTO my-table".
                " VALUES".
                " ('Abby', ~1999.2.19, 'tricolor', 'row1')".
                " ('Ace', ~2005.12.19, 'ticolor', 'row2')".
                " ('Angel', ~2001.9.19, 'Angel', 'row3')"
    ==
  =.  run  +(run)
  ::
  %+  expect-fail-message
      %-  crip
          "comparing column to literal of different aura: %col1 "
  |.  %:  ~(on-poke agent (bowl [run ~2012.5.2]))
          %obelisk-action
          !>([%tape %db1 "FROM my-table WHERE ~1999.2.19 >= col1 SELECT *"])
      ==
::
::  fail WHERE <column> >= <column> types differ
++  test-fail-gte-02
  =|  run=@ud
  =/  expected-rows
        :~
          :-  %vector
              :~  [%col1 [~.t 'Angel']]
                  [%col2 [~.da ~2001.9.19]]
                  [%col3 [~.t 'Angel']]
                  [%col4 [~.t 'row3']]
                  ==
            ==
  =/  expected  :~  %results
                    [%message 'SELECT']
                    [%result-set expected-rows]
                    [%server-time ~2012.5.3]
                    [%message 'db1.dbo.my-table']
                    [%schema-time ~2012.5.1]
                    [%data-time ~2012.5.2]
                    [%vector-count 1]
                ==
  =^  mov1  agent
    %:  ~(on-poke agent (bowl [run ~2012.4.30]))
        %obelisk-action
        !>([%tape %sys "CREATE DATABASE db1"])
    ==
  =.  run  +(run)
  =^  mov2  agent
    %:  ~(on-poke agent (bowl [run ~2012.5.1]))
        %obelisk-action
        !>  :+  %tape
                %db1
                "CREATE TABLE db1..my-table ".
                "(col1 @t, col2 @da, col3 @t, col4 @t) ".
                "PRIMARY KEY (col1)"
    ==
    =.  run  +(run)
  =^  mov3  agent
    %:  ~(on-poke agent (bowl [run ~2012.5.2]))
        %obelisk-action
        !>  :+  %tape
                %db1
                "INSERT INTO my-table".
                " VALUES".
                " ('Abby', ~1999.2.19, 'tricolor', 'row1')".
                " ('Ace', ~2005.12.19, 'ticolor', 'row2')".
                " ('Angel', ~2001.9.19, 'Angel', 'row3')"
    ==
  =.  run  +(run)
  ::
  %+  expect-fail-message
      %-  crip
          "comparing columns of differing auras: %col1 %col2"
  |.  %:  ~(on-poke agent (bowl [run ~2012.5.2]))
          %obelisk-action
          !>([%tape %db1 "FROM my-table WHERE col1 >= col2 SELECT *"])
      ==
::
::  LTE
::
::  WHERE <column> <= <literal> (cord)
++  test-lte-00
  =|  run=@ud
  =/  expected-rows
        :~
          :-  %vector
              :~  [%col1 [~.t 'Ace']]
                  [%col2 [~.da ~2005.12.19]]
                  [%col3 [~.t 'ticolor']]
                  [%col4 [~.t 'row2']]
                  ==
            ==
  =/  expected  :~  %results
                    [%message 'SELECT']
                    [%result-set expected-rows]
                    [%server-time ~2012.5.3]
                    [%message 'db1.dbo.my-table']
                    [%schema-time ~2012.5.1]
                    [%data-time ~2012.5.2]
                    [%vector-count 1]
                ==
  =^  mov1  agent
    %:  ~(on-poke agent (bowl [run ~2012.4.30]))
        %obelisk-action
        !>([%tape %sys "CREATE DATABASE db1"])
    ==
  =.  run  +(run)
  =^  mov2  agent
    %:  ~(on-poke agent (bowl [run ~2012.5.1]))
        %obelisk-action
        !>  :+  %tape
                %db1
                "CREATE TABLE db1..my-table ".
                "(col1 @t, col2 @da, col3 @t, col4 @t) ".
                "PRIMARY KEY (col1)"
    ==
    =.  run  +(run)
  =^  mov3  agent
    %:  ~(on-poke agent (bowl [run ~2012.5.2]))
        %obelisk-action
        !>  :+  %tape
                %db1
                "INSERT INTO my-table".
                " VALUES".
                " ('Abby', ~1999.2.19, 'tricolor', 'row1')".
                " ('Ace', ~2005.12.19, 'ticolor', 'row2')".
                " ('Angel', ~2001.9.19, 'tuxedo', 'row3')"
    ==
  =.  run  +(run)
  =^  mov4  agent
    %:  ~(on-poke agent (bowl [run ~2012.5.3]))
        %obelisk-action
        !>([%tape %db1 "FROM my-table WHERE col3 <= 'ticolor' SELECT *"])
    ==
  %+  expect-eq
    !>  expected
    !>  ;;(cmd-result ->+>+>-.mov4)
::
::  WHERE <column> <= <literal> (@da)
++  test-lte-01
  =|  run=@ud
  =/  expected-rows
        :~
          :-  %vector
              :~  [%col1 [~.t 'Abby']]
                  [%col2 [~.da ~1999.2.19]]
                  [%col3 [~.t 'tricolor']]
                  [%col4 [~.t 'row1']]
                  ==
          :-  %vector
              :~  [%col1 [~.t 'Angel']]
                  [%col2 [~.da ~2001.9.19]]
                  [%col3 [~.t 'tuxedo']]
                  [%col4 [~.t 'row3']]
                  ==
              ==
  =/  expected  :~  %results
                    [%message 'SELECT']
                    [%result-set expected-rows]
                    [%server-time ~2012.5.3]
                    [%message 'db1.dbo.my-table']
                    [%schema-time ~2012.5.1]
                    [%data-time ~2012.5.2]
                    [%vector-count 2]
                ==
  =^  mov1  agent
    %:  ~(on-poke agent (bowl [run ~2012.4.30]))
        %obelisk-action
        !>([%tape %sys "CREATE DATABASE db1"])
    ==
  =.  run  +(run)
  =^  mov2  agent
    %:  ~(on-poke agent (bowl [run ~2012.5.1]))
        %obelisk-action
        !>  :+  %tape
                %db1
                "CREATE TABLE db1..my-table ".
                "(col1 @t, col2 @da, col3 @t, col4 @t) ".
                "PRIMARY KEY (col1)"
    ==
    =.  run  +(run)
  =^  mov3  agent
    %:  ~(on-poke agent (bowl [run ~2012.5.2]))
        %obelisk-action
        !>  :+  %tape
                %db1
                "INSERT INTO my-table".
                " VALUES".
                " ('Abby', ~1999.2.19, 'tricolor', 'row1')".
                " ('Ace', ~2005.12.19, 'ticolor', 'row2')".
                " ('Angel', ~2001.9.19, 'tuxedo', 'row3')"
    ==
  =.  run  +(run)
  =^  mov4  agent
    %:  ~(on-poke agent (bowl [run ~2012.5.3]))
        %obelisk-action
        !>([%tape %db1 "FROM my-table WHERE col2 <= ~2001.9.19 SELECT *"])
    ==
  %+  expect-eq
    !>  expected
    !>  ;;(cmd-result ->+>+>-.mov4)
::
::  WHERE <literal> <= <column>  (cord)
++  test-lte-02
  =|  run=@ud
  =/  expected-rows
        :~
          :-  %vector
              :~  [%col1 [~.t 'Abby']]
                  [%col2 [~.da ~1999.2.19]]
                  [%col3 [~.t 'tricolor']]
                  [%col4 [~.t 'row1']]
                  ==
          :-  %vector
              :~  [%col1 [~.t 'Angel']]
                  [%col2 [~.da ~2001.9.19]]
                  [%col3 [~.t 'tuxedo']]
                  [%col4 [~.t 'row3']]
                  ==
              ==
  =/  expected  :~  %results
                    [%message 'SELECT']
                    [%result-set expected-rows]
                    [%server-time ~2012.5.3]
                    [%message 'db1.dbo.my-table']
                    [%schema-time ~2012.5.1]
                    [%data-time ~2012.5.2]
                    [%vector-count 2]
                ==
  =^  mov1  agent
    %:  ~(on-poke agent (bowl [run ~2012.4.30]))
        %obelisk-action
        !>([%tape %sys "CREATE DATABASE db1"])
    ==
  =.  run  +(run)
  =^  mov2  agent
    %:  ~(on-poke agent (bowl [run ~2012.5.1]))
        %obelisk-action
        !>  :+  %tape
                %db1
                "CREATE TABLE db1..my-table ".
                "(col1 @t, col2 @da, col3 @t, col4 @t) ".
                "PRIMARY KEY (col1)"
    ==
    =.  run  +(run)
  =^  mov3  agent
    %:  ~(on-poke agent (bowl [run ~2012.5.2]))
        %obelisk-action
        !>  :+  %tape
                %db1
                "INSERT INTO my-table".
                " VALUES".
                " ('Abby', ~1999.2.19, 'tricolor', 'row1')".
                " ('Ace', ~2005.12.19, 'ticolor', 'row2')".
                " ('Angel', ~2001.9.19, 'tuxedo', 'row3')"
    ==
  =.  run  +(run)
  =^  mov4  agent
    %:  ~(on-poke agent (bowl [run ~2012.5.3]))
        %obelisk-action
        !>([%tape %db1 "FROM my-table WHERE 'tricolor' <= col3 SELECT *"])
    ==
  %+  expect-eq
    !>  expected
    !>  ;;(cmd-result ->+>+>-.mov4)
::
::  WHERE <column> <= <column>  (cord)
++  test-lte-03
  =|  run=@ud
  =/  expected-rows
        :~
          :-  %vector
              :~  [%col1 [~.t 'Abby']]
                  [%col2 [~.da ~1999.2.19]]
                  [%col3 [~.t 'tricolor']]
                  [%col4 [~.t 'row1']]
                  ==
          :-  %vector
              :~  [%col1 [~.t 'Ace']]
                  [%col2 [~.da ~2005.12.19]]
                  [%col3 [~.t 'ticolor']]
                  [%col4 [~.t 'row2']]
                  ==
          :-  %vector
              :~  [%col1 [~.t 'Angel']]
                  [%col2 [~.da ~2001.9.19]]
                  [%col3 [~.t 'Angel']]
                  [%col4 [~.t 'row3']]
                  ==
            ==
  =/  expected  :~  %results
                    [%message 'SELECT']
                    [%result-set expected-rows]
                    [%server-time ~2012.5.3]
                    [%message 'db1.dbo.my-table']
                    [%schema-time ~2012.5.1]
                    [%data-time ~2012.5.2]
                    [%vector-count 3]
                ==
  =^  mov1  agent
    %:  ~(on-poke agent (bowl [run ~2012.4.30]))
        %obelisk-action
        !>([%tape %sys "CREATE DATABASE db1"])
    ==
  =.  run  +(run)
  =^  mov2  agent
    %:  ~(on-poke agent (bowl [run ~2012.5.1]))
        %obelisk-action
        !>  :+  %tape
                %db1
                "CREATE TABLE db1..my-table ".
                "(col1 @t, col2 @da, col3 @t, col4 @t) ".
                "PRIMARY KEY (col1)"
    ==
  =.  run  +(run)
  =^  mov3  agent
    %:  ~(on-poke agent (bowl [run ~2012.5.2]))
        %obelisk-action
        !>  :+  %tape
                %db1
                "INSERT INTO my-table".
                " VALUES".
                " ('Abby', ~1999.2.19, 'tricolor', 'row1')".
                " ('Ace', ~2005.12.19, 'ticolor', 'row2')".
                " ('Angel', ~2001.9.19, 'Angel', 'row3')"
    ==
  =.  run  +(run)
  =^  mov4  agent
    %:  ~(on-poke agent (bowl [run ~2012.5.3]))
        %obelisk-action
        !>([%tape %db1 "FROM my-table WHERE col1 <= col3 SELECT *"])
    ==
  %+  expect-eq
    !>  expected
    !>  ;;(cmd-result ->+>+>-.mov4)
::
::  WHERE <column> <= <literal> (cord)
++  test-lte-04
  =|  run=@ud
  =/  expected-rows
        :~
          :-  %vector
              :~  [%col1 [~.t 'Ace']]
                  [%col2 [~.da ~2005.12.19]]
                  [%col3 [~.t 'ticolor']]
                  [%col4 [~.t 'row2']]
                  ==
          :-  %vector
              :~  [%col1 [~.t 'Abby']]
                  [%col2 [~.da ~1999.2.19]]
                  [%col3 [~.t 'tricolor']]
                  [%col4 [~.t 'row1']]
                  ==
            ==
  =/  expected  :~  %results
                    [%message 'SELECT']
                    [%result-set expected-rows]
                    [%server-time ~2012.5.3]
                    [%message 'db1.dbo.my-table']
                    [%schema-time ~2012.5.1]
                    [%data-time ~2012.5.2]
                    [%vector-count 2]
                ==
  =^  mov1  agent
    %:  ~(on-poke agent (bowl [run ~2012.4.30]))
        %obelisk-action
        !>([%tape %sys "CREATE DATABASE db1"])
    ==
  =.  run  +(run)
  =^  mov2  agent
    %:  ~(on-poke agent (bowl [run ~2012.5.1]))
        %obelisk-action
        !>  :+  %tape
                %db1
                "CREATE TABLE db1..my-table ".
                "(col1 @t, col2 @da, col3 @t, col4 @t) ".
                "PRIMARY KEY (col3)"
    ==
  =.  run  +(run)
  =^  mov3  agent
    %:  ~(on-poke agent (bowl [run ~2012.5.2]))
        %obelisk-action
        !>  :+  %tape
                %db1
                "INSERT INTO my-table".
                " VALUES".
                " ('Abby', ~1999.2.19, 'tricolor', 'row1')".
                " ('Ace', ~2005.12.19, 'ticolor', 'row2')".
                " ('Angel', ~2001.9.19, 'tuxedo', 'row3')"
    ==
  =.  run  +(run)
  =^  mov4  agent
    %:  ~(on-poke agent (bowl [run ~2012.5.3]))
        %obelisk-action
        !>([%tape %db1 "FROM my-table WHERE col1 <= 'Ace' SELECT *"])
    ==
  %+  expect-eq
    !>  expected
    !>  ;;(cmd-result ->+>+>-.mov4)
::
::  view WHERE <column> <= <literal>
++  test-lte-05
  =|  run=@ud
  =/  expected-rows
        :~
          :-  %vector
              :~  [p=%namespace q=[p=~.tas q=%dbo]]
                  [p=%name q=[p=~.tas q=%my-table]]
                  [p=%col-ordinal q=[p=~.ud q=2]]
                  [p=%col-name q=[p=~.tas q=%col2]]
                  [p=%col-type q=[p=~.ta q=~.da]]
                  ==
          :-  %vector
              :~  [p=%namespace q=[p=~.tas q=%dbo]]
                  [p=%name q=[p=~.tas q=%my-table]]
                  [p=%col-ordinal q=[p=~.ud q=3]]
                  [p=%col-name q=[p=~.tas q=%col3]]
                  [p=%col-type q=[p=~.ta q=~.t]]
                  ==
          :-  %vector
              :~  [p=%namespace q=[p=~.tas q=%dbo]]
                  [p=%name q=[p=~.tas q=%my-table]]
                  [p=%col-ordinal q=[p=~.ud q=4]]
                  [p=%col-name q=[p=~.tas q=%col4]]
                  [p=%col-type q=[p=~.ta q=~.t]]
                  ==
            ==
  =/  expected  :~  %results
                    [%message 'SELECT']
                    [%result-set expected-rows]
                    [%server-time ~2012.5.3]
                    [%message 'db1.sys.columns']
                    [%schema-time ~2012.5.1]
                    [%data-time ~2012.5.1]
                    [%vector-count 3]
                ==
  =^  mov1  agent
    %:  ~(on-poke agent (bowl [run ~2012.4.30]))
        %obelisk-action
        !>([%tape %sys "CREATE DATABASE db1"])
    ==
  =.  run  +(run)
  =^  mov2  agent
    %:  ~(on-poke agent (bowl [run ~2012.5.1]))
        %obelisk-action
        !>  :+  %tape
                %db1
                "CREATE TABLE db1..my-table ".
                "(col1 @t, col2 @da, col3 @t, col4 @t) ".
                "PRIMARY KEY (col1)"
    ==
  =.  run  +(run)
  =^  mov3  agent
    %:  ~(on-poke agent (bowl [run ~2012.5.3]))
        %obelisk-action
        !>([%tape %db1 "FROM sys.columns WHERE 'col2' <= col-name SELECT *"])
    ==
  %+  expect-eq
    !>  expected
    !>  ;;(cmd-result ->+>+>-.mov3)
::
::  view WHERE <literal> <= <literal>
++  test-lte-06
  =|  run=@ud
  =/  expected-rows
        :~
          :-  %vector
              :~  [p=%namespace q=[p=~.tas q=%dbo]]
                  [p=%name q=[p=~.tas q=%my-table]]
                  [p=%col-ordinal q=[p=~.ud q=1]]
                  [p=%col-name q=[p=~.tas q=%col1]]
                  [p=%col-type q=[p=~.ta q=~.t]]
                  ==
          :-  %vector
              :~  [p=%namespace q=[p=~.tas q=%dbo]]
                  [p=%name q=[p=~.tas q=%my-table]]
                  [p=%col-ordinal q=[p=~.ud q=2]]
                  [p=%col-name q=[p=~.tas q=%col2]]
                  [p=%col-type q=[p=~.ta q=~.da]]
                  ==
          :-  %vector
              :~  [p=%namespace q=[p=~.tas q=%dbo]]
                  [p=%name q=[p=~.tas q=%my-table]]
                  [p=%col-ordinal q=[p=~.ud q=3]]
                  [p=%col-name q=[p=~.tas q=%col3]]
                  [p=%col-type q=[p=~.ta q=~.t]]
                  ==
          :-  %vector
              :~  [p=%namespace q=[p=~.tas q=%dbo]]
                  [p=%name q=[p=~.tas q=%my-table]]
                  [p=%col-ordinal q=[p=~.ud q=4]]
                  [p=%col-name q=[p=~.tas q=%col4]]
                  [p=%col-type q=[p=~.ta q=~.t]]
                  ==
            ==
  =/  expected  :~  %results
                    [%message 'SELECT']
                    [%result-set expected-rows]
                    [%server-time ~2012.5.3]
                    [%message 'db1.sys.columns']
                    [%schema-time ~2012.5.1]
                    [%data-time ~2012.5.1]
                    [%vector-count 4]
                ==
  =^  mov1  agent
    %:  ~(on-poke agent (bowl [run ~2012.4.30]))
        %obelisk-action
        !>([%tape %sys "CREATE DATABASE db1"])
    ==
  =.  run  +(run)
  =^  mov2  agent
    %:  ~(on-poke agent (bowl [run ~2012.5.1]))
        %obelisk-action
        !>  :+  %tape
                %db1
                "CREATE TABLE db1..my-table ".
                "(col1 @t, col2 @da, col3 @t, col4 @t) ".
                "PRIMARY KEY (col1)"
    ==
  =.  run  +(run)
  =^  mov3  agent
    %:  ~(on-poke agent (bowl [run ~2012.5.3]))
        %obelisk-action
        !>([%tape %db1 "FROM sys.columns WHERE 1 <= 1 SELECT *"])
    ==
  %+  expect-eq
    !>  expected
    !>  ;;(cmd-result ->+>+>-.mov3)
::
::  fail WHERE <column> <= <literal> types differ
++  test-fail-lte-00
  =|  run=@ud
  =/  expected-rows
        :~
          :-  %vector
              :~  [%col1 [~.t 'Angel']]
                  [%col2 [~.da ~2001.9.19]]
                  [%col3 [~.t 'Angel']]
                  [%col4 [~.t 'row3']]
                  ==
            ==
  =/  expected  :~  %results
                    [%message 'SELECT']
                    [%result-set expected-rows]
                    [%server-time ~2012.5.3]
                    [%message 'db1.dbo.my-table']
                    [%schema-time ~2012.5.1]
                    [%data-time ~2012.5.2]
                    [%vector-count 1]
                ==
  =^  mov1  agent
    %:  ~(on-poke agent (bowl [run ~2012.4.30]))
        %obelisk-action
        !>([%tape %sys "CREATE DATABASE db1"])
    ==
  =.  run  +(run)
  =^  mov2  agent
    %:  ~(on-poke agent (bowl [run ~2012.5.1]))
        %obelisk-action
        !>  :+  %tape
                %db1
                "CREATE TABLE db1..my-table ".
                "(col1 @t, col2 @da, col3 @t, col4 @t) ".
                "PRIMARY KEY (col1)"
    ==
    =.  run  +(run)
  =^  mov3  agent
    %:  ~(on-poke agent (bowl [run ~2012.5.2]))
        %obelisk-action
        !>  :+  %tape
                %db1
                "INSERT INTO my-table".
                " VALUES".
                " ('Abby', ~1999.2.19, 'tricolor', 'row1')".
                " ('Ace', ~2005.12.19, 'ticolor', 'row2')".
                " ('Angel', ~2001.9.19, 'Angel', 'row3')"
    ==
  =.  run  +(run)
  ::
  %+  expect-fail-message
      %-  crip
          "comparing column to literal of different aura: %col1 "
  |.  %:  ~(on-poke agent (bowl [run ~2012.5.2]))
          %obelisk-action
          !>([%tape %db1 "FROM my-table WHERE col1 <= ~1999.2.19 SELECT *"])
      ==
::
::  fail WHERE <literal> <= <column> types differ
++  test-fail-lte-01
  =|  run=@ud
  =/  expected-rows
        :~
          :-  %vector
              :~  [%col1 [~.t 'Angel']]
                  [%col2 [~.da ~2001.9.19]]
                  [%col3 [~.t 'Angel']]
                  [%col4 [~.t 'row3']]
                  ==
            ==
  =/  expected  :~  %results
                    [%message 'SELECT']
                    [%result-set expected-rows]
                    [%server-time ~2012.5.3]
                    [%message 'db1.dbo.my-table']
                    [%schema-time ~2012.5.1]
                    [%data-time ~2012.5.2]
                    [%vector-count 1]
                ==
  =^  mov1  agent
    %:  ~(on-poke agent (bowl [run ~2012.4.30]))
        %obelisk-action
        !>([%tape %sys "CREATE DATABASE db1"])
    ==
  =.  run  +(run)
  =^  mov2  agent
    %:  ~(on-poke agent (bowl [run ~2012.5.1]))
        %obelisk-action
        !>  :+  %tape
                %db1
                "CREATE TABLE db1..my-table ".
                "(col1 @t, col2 @da, col3 @t, col4 @t) ".
                "PRIMARY KEY (col1)"
    ==
    =.  run  +(run)
  =^  mov3  agent
    %:  ~(on-poke agent (bowl [run ~2012.5.2]))
        %obelisk-action
        !>  :+  %tape
                %db1
                "INSERT INTO my-table".
                " VALUES".
                " ('Abby', ~1999.2.19, 'tricolor', 'row1')".
                " ('Ace', ~2005.12.19, 'ticolor', 'row2')".
                " ('Angel', ~2001.9.19, 'Angel', 'row3')"
    ==
  =.  run  +(run)
  ::
  %+  expect-fail-message
      %-  crip
          "comparing column to literal of different aura: %col1 "
  |.  %:  ~(on-poke agent (bowl [run ~2012.5.2]))
          %obelisk-action
          !>([%tape %db1 "FROM my-table WHERE ~1999.2.19 <= col1 SELECT *"])
      ==
::
::  fail WHERE <column> <= <column> types differ
++  test-fail-lte-02
  =|  run=@ud
  =/  expected-rows
        :~
          :-  %vector
              :~  [%col1 [~.t 'Angel']]
                  [%col2 [~.da ~2001.9.19]]
                  [%col3 [~.t 'Angel']]
                  [%col4 [~.t 'row3']]
                  ==
            ==
  =/  expected  :~  %results
                    [%message 'SELECT']
                    [%result-set expected-rows]
                    [%server-time ~2012.5.3]
                    [%message 'db1.dbo.my-table']
                    [%schema-time ~2012.5.1]
                    [%data-time ~2012.5.2]
                    [%vector-count 1]
                ==
  =^  mov1  agent
    %:  ~(on-poke agent (bowl [run ~2012.4.30]))
        %obelisk-action
        !>([%tape %sys "CREATE DATABASE db1"])
    ==
  =.  run  +(run)
  =^  mov2  agent
    %:  ~(on-poke agent (bowl [run ~2012.5.1]))
        %obelisk-action
        !>  :+  %tape
                %db1
                "CREATE TABLE db1..my-table ".
                "(col1 @t, col2 @da, col3 @t, col4 @t) ".
                "PRIMARY KEY (col1)"
    ==
    =.  run  +(run)
  =^  mov3  agent
    %:  ~(on-poke agent (bowl [run ~2012.5.2]))
        %obelisk-action
        !>  :+  %tape
                %db1
                "INSERT INTO my-table".
                " VALUES".
                " ('Abby', ~1999.2.19, 'tricolor', 'row1')".
                " ('Ace', ~2005.12.19, 'ticolor', 'row2')".
                " ('Angel', ~2001.9.19, 'Angel', 'row3')"
    ==
  =.  run  +(run)
  ::
  %+  expect-fail-message
      %-  crip
          "comparing columns of differing auras: %col1 %col2"
  |.  %:  ~(on-poke agent (bowl [run ~2012.5.2]))
          %obelisk-action
          !>([%tape %db1 "FROM my-table WHERE col1 <= col2 SELECT *"])
      ==
::
::  IN
::
::  WHERE <column> IN (list @t)
++  test-in-00
  =|  run=@ud
  =/  expected-rows
        :~
          :-  %vector
              :~  [%col1 [~.t 'Abby']]
                  [%col2 [~.da ~1999.2.19]]
                  [%col3 [~.t 'tricolor']]
                  [%col4 [~.t 'row1']]
                  ==
          :-  %vector
              :~  [%col1 [~.t 'Ace']]
                  [%col2 [~.da ~2005.12.19]]
                  [%col3 [~.t 'ticolor']]
                  [%col4 [~.t 'row2']]
                  ==
            ==
  =/  expected  :~  %results
                    [%message 'SELECT']
                    [%result-set expected-rows]
                    [%server-time ~2012.5.3]
                    [%message 'db1.dbo.my-table']
                    [%schema-time ~2012.5.1]
                    [%data-time ~2012.5.2]
                    [%vector-count 2]
                ==
  =^  mov1  agent
    %:  ~(on-poke agent (bowl [run ~2012.4.30]))
        %obelisk-action
        !>([%tape %sys "CREATE DATABASE db1"])
    ==
  =.  run  +(run)
  =^  mov2  agent
    %:  ~(on-poke agent (bowl [run ~2012.5.1]))
        %obelisk-action
        !>  :+  %tape
                %db1
                "CREATE TABLE db1..my-table ".
                "(col1 @t, col2 @da, col3 @t, col4 @t) ".
                "PRIMARY KEY (col1)"
    ==
    =.  run  +(run)
  =^  mov3  agent
    %:  ~(on-poke agent (bowl [run ~2012.5.2]))
        %obelisk-action
        !>  :+  %tape
                %db1
                "INSERT INTO my-table".
                " VALUES".
                " ('Abby', ~1999.2.19, 'tricolor', 'row1')".
                " ('Ace', ~2005.12.19, 'ticolor', 'row2')".
                " ('Angel', ~2001.9.19, 'tuxedo', 'row3')"
    ==
  =.  run  +(run)
  =^  mov4  agent
    %:  ~(on-poke agent (bowl [run ~2012.5.3]))
        %obelisk-action
        !>([%tape %db1 "FROM my-table WHERE col3 IN ('ticolor', 'tricolor') SELECT *"])
    ==
  %+  expect-eq
    !>  expected
    !>  ;;(cmd-result ->+>+>-.mov4)
::
::  WHERE <column> IN (list @da) (@da)
++  test-in-01
  =|  run=@ud
  =/  expected-rows
        :~
          :-  %vector
              :~  [%col1 [~.t 'Abby']]
                  [%col2 [~.da ~1999.2.19]]
                  [%col3 [~.t 'tricolor']]
                  [%col4 [~.t 'row1']]
                  ==
          :-  %vector
              :~  [%col1 [~.t 'Angel']]
                  [%col2 [~.da ~2001.9.19]]
                  [%col3 [~.t 'tuxedo']]
                  [%col4 [~.t 'row3']]
                  ==
              ==
  =/  expected  :~  %results
                    [%message 'SELECT']
                    [%result-set expected-rows]
                    [%server-time ~2012.5.3]
                    [%message 'db1.dbo.my-table']
                    [%schema-time ~2012.5.1]
                    [%data-time ~2012.5.2]
                    [%vector-count 2]
                ==
  =^  mov1  agent
    %:  ~(on-poke agent (bowl [run ~2012.4.30]))
        %obelisk-action
        !>([%tape %sys "CREATE DATABASE db1"])
    ==
  =.  run  +(run)
  =^  mov2  agent
    %:  ~(on-poke agent (bowl [run ~2012.5.1]))
        %obelisk-action
        !>  :+  %tape
                %db1
                "CREATE TABLE db1..my-table ".
                "(col1 @t, col2 @da, col3 @t, col4 @t) ".
                "PRIMARY KEY (col1)"
    ==
    =.  run  +(run)
  =^  mov3  agent
    %:  ~(on-poke agent (bowl [run ~2012.5.2]))
        %obelisk-action
        !>  :+  %tape
                %db1
                "INSERT INTO my-table".
                " VALUES".
                " ('Abby', ~1999.2.19, 'tricolor', 'row1')".
                " ('Ace', ~2005.12.19, 'ticolor', 'row2')".
                " ('Angel', ~2001.9.19, 'tuxedo', 'row3')"
    ==
  =.  run  +(run)
  =^  mov4  agent
    %:  ~(on-poke agent (bowl [run ~2012.5.3]))
        %obelisk-action
        !>([%tape %db1 "FROM my-table WHERE col2 in(~2001.9.19, ~1999.2.19) SELECT *"])
    ==
  %+  expect-eq
    !>  expected
    !>  ;;(cmd-result ->+>+>-.mov4)
::
::  WHERE <literal> IN (list @t)
++  test-in-02
  =|  run=@ud
  =/  expected-rows
        :~
          :-  %vector
              :~  [%col1 [~.t 'Abby']]
                  [%col2 [~.da ~1999.2.19]]
                  [%col3 [~.t 'tricolor']]
                  [%col4 [~.t 'row1']]
                  ==
          :-  %vector
              :~  [%col1 [~.t 'Ace']]
                  [%col2 [~.da ~2005.12.19]]
                  [%col3 [~.t 'ticolor']]
                  [%col4 [~.t 'row2']]
                  ==
          :-  %vector
              :~  [%col1 [~.t 'Angel']]
                  [%col2 [~.da ~2001.9.19]]
                  [%col3 [~.t 'tuxedo']]
                  [%col4 [~.t 'row3']]
                  ==
              ==
  =/  expected  :~  %results
                    [%message 'SELECT']
                    [%result-set expected-rows]
                    [%server-time ~2012.5.3]
                    [%message 'db1.dbo.my-table']
                    [%schema-time ~2012.5.1]
                    [%data-time ~2012.5.2]
                    [%vector-count 3]
                ==
  =^  mov1  agent
    %:  ~(on-poke agent (bowl [run ~2012.4.30]))
        %obelisk-action
        !>([%tape %sys "CREATE DATABASE db1"])
    ==
  =.  run  +(run)
  =^  mov2  agent
    %:  ~(on-poke agent (bowl [run ~2012.5.1]))
        %obelisk-action
        !>  :+  %tape
                %db1
                "CREATE TABLE db1..my-table ".
                "(col1 @t, col2 @da, col3 @t, col4 @t) ".
                "PRIMARY KEY (col1)"
    ==
    =.  run  +(run)
  =^  mov3  agent
    %:  ~(on-poke agent (bowl [run ~2012.5.2]))
        %obelisk-action
        !>  :+  %tape
                %db1
                "INSERT INTO my-table".
                " VALUES".
                " ('Abby', ~1999.2.19, 'tricolor', 'row1')".
                " ('Ace', ~2005.12.19, 'ticolor', 'row2')".
                " ('Angel', ~2001.9.19, 'tuxedo', 'row3')"
    ==
  =.  run  +(run)
  =^  mov4  agent
    %:  ~(on-poke agent (bowl [run ~2012.5.3]))
        %obelisk-action
        !>([%tape %db1 "FROM my-table WHERE 'tricolor' IN ('tricolor', 'ticolor', 'tuxedo') SELECT *"])
    ==
  %+  expect-eq
    !>  expected
    !>  ;;(cmd-result ->+>+>-.mov4)
::
::  WHERE <column> IN (list @)  (no matches)
++  test-in-03
  =|  run=@ud
  =/  expected  :~  %results
                    [%message 'SELECT']
                    [%result-set ~]
                    [%server-time ~2012.5.3]
                    [%message 'db1.dbo.my-table']
                    [%schema-time ~2012.5.1]
                    [%data-time ~2012.5.2]
                    [%vector-count 0]
                ==
  =^  mov1  agent
    %:  ~(on-poke agent (bowl [run ~2012.4.30]))
        %obelisk-action
        !>([%tape %sys "CREATE DATABASE db1"])
    ==
  =.  run  +(run)
  =^  mov2  agent
    %:  ~(on-poke agent (bowl [run ~2012.5.1]))
        %obelisk-action
        !>  :+  %tape
                %db1
                "CREATE TABLE db1..my-table ".
                "(col1 @t, col2 @da, col3 @t, col4 @t) ".
                "PRIMARY KEY (col1)"
    ==
  =.  run  +(run)
  =^  mov3  agent
    %:  ~(on-poke agent (bowl [run ~2012.5.2]))
        %obelisk-action
        !>  :+  %tape
                %db1
                "INSERT INTO my-table".
                " VALUES".
                " ('Abby', ~1999.2.19, 'tricolor', 'row1')".
                " ('Ace', ~2005.12.19, 'ticolor', 'row2')".
                " ('Angel', ~2001.9.19, 'Angel', 'row3')"
    ==
  =.  run  +(run)
  =^  mov4  agent
    %:  ~(on-poke agent (bowl [run ~2012.5.3]))
        %obelisk-action
        !>([%tape %db1 "FROM my-table WHERE col1 IN ('widget', 'bam') SELECT *"])
    ==
  %+  expect-eq
    !>  expected
    !>  ;;(cmd-result ->+>+>-.mov4)

::
::  fail WHERE <column> IN (list @t) types differ
++  test-fail-in-00
  =|  run=@ud
  =/  expected-rows
        :~
          :-  %vector
              :~  [%col1 [~.t 'Angel']]
                  [%col2 [~.da ~2001.9.19]]
                  [%col3 [~.t 'Angel']]
                  [%col4 [~.t 'row3']]
                  ==
            ==
  =/  expected  :~  %results
                    [%message 'SELECT']
                    [%result-set expected-rows]
                    [%server-time ~2012.5.3]
                    [%message 'db1.dbo.my-table']
                    [%schema-time ~2012.5.1]
                    [%data-time ~2012.5.2]
                    [%vector-count 1]
                ==
  =^  mov1  agent
    %:  ~(on-poke agent (bowl [run ~2012.4.30]))
        %obelisk-action
        !>([%tape %sys "CREATE DATABASE db1"])
    ==
  =.  run  +(run)
  =^  mov2  agent
    %:  ~(on-poke agent (bowl [run ~2012.5.1]))
        %obelisk-action
        !>  :+  %tape
                %db1
                "CREATE TABLE db1..my-table ".
                "(col1 @t, col2 @da, col3 @t, col4 @t) ".
                "PRIMARY KEY (col1)"
    ==
    =.  run  +(run)
  =^  mov3  agent
    %:  ~(on-poke agent (bowl [run ~2012.5.2]))
        %obelisk-action
        !>  :+  %tape
                %db1
                "INSERT INTO my-table".
                " VALUES".
                " ('Abby', ~1999.2.19, 'tricolor', 'row1')".
                " ('Ace', ~2005.12.19, 'ticolor', 'row2')".
                " ('Angel', ~2001.9.19, 'Angel', 'row3')"
    ==
  =.  run  +(run)
  ::
  %+  expect-fail-message
      %-  crip
          "type of IN list incorrect, should be p=~.t"
  |.  %:  ~(on-poke agent (bowl [run ~2012.5.2]))
          %obelisk-action
          !>([%tape %db1 "FROM my-table WHERE col3 IN (~1999.2.19, ~2005.12.19, ~2001.9.19) SELECT *"])
      ==
::
::  fail WHERE <literal> IN (list @) types differ
++  test-fail-in-01
  =|  run=@ud
  =/  expected-rows
        :~
          :-  %vector
              :~  [%col1 [~.t 'Angel']]
                  [%col2 [~.da ~2001.9.19]]
                  [%col3 [~.t 'Angel']]
                  [%col4 [~.t 'row3']]
                  ==
            ==
  =/  expected  :~  %results
                    [%message 'SELECT']
                    [%result-set expected-rows]
                    [%server-time ~2012.5.3]
                    [%message 'db1.dbo.my-table']
                    [%schema-time ~2012.5.1]
                    [%data-time ~2012.5.2]
                    [%vector-count 1]
                ==
  =^  mov1  agent
    %:  ~(on-poke agent (bowl [run ~2012.4.30]))
        %obelisk-action
        !>([%tape %sys "CREATE DATABASE db1"])
    ==
  =.  run  +(run)
  =^  mov2  agent
    %:  ~(on-poke agent (bowl [run ~2012.5.1]))
        %obelisk-action
        !>  :+  %tape
                %db1
                "CREATE TABLE db1..my-table ".
                "(col1 @t, col2 @da, col3 @t, col4 @t) ".
                "PRIMARY KEY (col1)"
    ==
    =.  run  +(run)
  =^  mov3  agent
    %:  ~(on-poke agent (bowl [run ~2012.5.2]))
        %obelisk-action
        !>  :+  %tape
                %db1
                "INSERT INTO my-table".
                " VALUES".
                " ('Abby', ~1999.2.19, 'tricolor', 'row1')".
                " ('Ace', ~2005.12.19, 'ticolor', 'row2')".
                " ('Angel', ~2001.9.19, 'Angel', 'row3')"
    ==
  =.  run  +(run)
  ::
  %+  expect-fail-message
      %-  crip
          "type of IN list incorrect, should be p=~.t"
  |.  %:  ~(on-poke agent (bowl [run ~2012.5.2]))
          %obelisk-action
          !>([%tape %db1 "FROM my-table WHERE 'ticolor' IN (~1999.2.19, ~2005.12.19, ~2001.9.19) SELECT *"])
      ==
::
::  NOT IN
::
::  WHERE <column> NOT IN (list @t)
++  test-not-in-00
  =|  run=@ud
  =/  expected-rows
        :~
          :-  %vector
              :~  [%col1 [~.t 'Angel']]
                  [%col2 [~.da ~2001.9.19]]
                  [%col3 [~.t 'tuxedo']]
                  [%col4 [~.t 'row3']]
                  ==
            ==
  =/  expected  :~  %results
                    [%message 'SELECT']
                    [%result-set expected-rows]
                    [%server-time ~2012.5.3]
                    [%message 'db1.dbo.my-table']
                    [%schema-time ~2012.5.1]
                    [%data-time ~2012.5.2]
                    [%vector-count 1]
                ==
  =^  mov1  agent
    %:  ~(on-poke agent (bowl [run ~2012.4.30]))
        %obelisk-action
        !>([%tape %sys "CREATE DATABASE db1"])
    ==
  =.  run  +(run)
  =^  mov2  agent
    %:  ~(on-poke agent (bowl [run ~2012.5.1]))
        %obelisk-action
        !>  :+  %tape
                %db1
                "CREATE TABLE db1..my-table ".
                "(col1 @t, col2 @da, col3 @t, col4 @t) ".
                "PRIMARY KEY (col1)"
    ==
    =.  run  +(run)
  =^  mov3  agent
    %:  ~(on-poke agent (bowl [run ~2012.5.2]))
        %obelisk-action
        !>  :+  %tape
                %db1
                "INSERT INTO my-table".
                " VALUES".
                " ('Abby', ~1999.2.19, 'tricolor', 'row1')".
                " ('Ace', ~2005.12.19, 'ticolor', 'row2')".
                " ('Angel', ~2001.9.19, 'tuxedo', 'row3')"
    ==
  =.  run  +(run)
  =^  mov4  agent
    %:  ~(on-poke agent (bowl [run ~2012.5.3]))
        %obelisk-action
        !>([%tape %db1 "FROM my-table WHERE col3 NOT IN ('ticolor', 'tricolor') SELECT *"])
    ==
  %+  expect-eq
    !>  expected
    !>  ;;(cmd-result ->+>+>-.mov4)
::
::  WHERE <column> NOT IN (list @da) (@da)
++  test-not-in-01
  =|  run=@ud
  =/  expected-rows
        :~
          :-  %vector
              :~  [%col1 [~.t 'Ace']]
                  [%col2 [~.da ~2005.12.19]]
                  [%col3 [~.t 'ticolor']]
                  [%col4 [~.t 'row2']]
                  ==
              ==
  =/  expected  :~  %results
                    [%message 'SELECT']
                    [%result-set expected-rows]
                    [%server-time ~2012.5.3]
                    [%message 'db1.dbo.my-table']
                    [%schema-time ~2012.5.1]
                    [%data-time ~2012.5.2]
                    [%vector-count 1]
                ==
  =^  mov1  agent
    %:  ~(on-poke agent (bowl [run ~2012.4.30]))
        %obelisk-action
        !>([%tape %sys "CREATE DATABASE db1"])
    ==
  =.  run  +(run)
  =^  mov2  agent
    %:  ~(on-poke agent (bowl [run ~2012.5.1]))
        %obelisk-action
        !>  :+  %tape
                %db1
                "CREATE TABLE db1..my-table ".
                "(col1 @t, col2 @da, col3 @t, col4 @t) ".
                "PRIMARY KEY (col1)"
    ==
    =.  run  +(run)
  =^  mov3  agent
    %:  ~(on-poke agent (bowl [run ~2012.5.2]))
        %obelisk-action
        !>  :+  %tape
                %db1
                "INSERT INTO my-table".
                " VALUES".
                " ('Abby', ~1999.2.19, 'tricolor', 'row1')".
                " ('Ace', ~2005.12.19, 'ticolor', 'row2')".
                " ('Angel', ~2001.9.19, 'tuxedo', 'row3')"
    ==
  =.  run  +(run)
  =^  mov4  agent
    %:  ~(on-poke agent (bowl [run ~2012.5.3]))
        %obelisk-action
        !>([%tape %db1 "FROM my-table WHERE col2 NOT IN (~2001.9.19, ~1999.2.19) SELECT *"])
    ==
  %+  expect-eq
    !>  expected
    !>  ;;(cmd-result ->+>+>-.mov4)
::
::  WHERE <literal> NOT IN (list @t)  (no matches)
++  test-not-in-02
  =|  run=@ud
  =/  expected-rows
        :~
          :-  %vector
              :~  [%col1 [~.t 'Abby']]
                  [%col2 [~.da ~1999.2.19]]
                  [%col3 [~.t 'tricolor']]
                  [%col4 [~.t 'row1']]
                  ==
          :-  %vector
              :~  [%col1 [~.t 'Ace']]
                  [%col2 [~.da ~2005.12.19]]
                  [%col3 [~.t 'ticolor']]
                  [%col4 [~.t 'row2']]
                  ==
          :-  %vector
              :~  [%col1 [~.t 'Angel']]
                  [%col2 [~.da ~2001.9.19]]
                  [%col3 [~.t 'tuxedo']]
                  [%col4 [~.t 'row3']]
                  ==
              ==
  =/  expected  :~  %results
                    [%message 'SELECT']
                    [%result-set expected-rows]
                    [%server-time ~2012.5.3]
                    [%message 'db1.dbo.my-table']
                    [%schema-time ~2012.5.1]
                    [%data-time ~2012.5.2]
                    [%vector-count 3]
                ==
  =^  mov1  agent
    %:  ~(on-poke agent (bowl [run ~2012.4.30]))
        %obelisk-action
        !>([%tape %sys "CREATE DATABASE db1"])
    ==
  =.  run  +(run)
  =^  mov2  agent
    %:  ~(on-poke agent (bowl [run ~2012.5.1]))
        %obelisk-action
        !>  :+  %tape
                %db1
                "CREATE TABLE db1..my-table ".
                "(col1 @t, col2 @da, col3 @t, col4 @t) ".
                "PRIMARY KEY (col1)"
    ==
    =.  run  +(run)
  =^  mov3  agent
    %:  ~(on-poke agent (bowl [run ~2012.5.2]))
        %obelisk-action
        !>  :+  %tape
                %db1
                "INSERT INTO my-table".
                " VALUES".
                " ('Abby', ~1999.2.19, 'tricolor', 'row1')".
                " ('Ace', ~2005.12.19, 'ticolor', 'row2')".
                " ('Angel', ~2001.9.19, 'tuxedo', 'row3')"
    ==
  =.  run  +(run)
  =^  mov4  agent
    %:  ~(on-poke agent (bowl [run ~2012.5.3]))
        %obelisk-action
        !>([%tape %db1 "FROM my-table WHERE 'boo' NOT IN ('tricolor', 'ticolor', 'tuxedo') SELECT *"])
    ==
  %+  expect-eq
    !>  expected
    !>  ;;(cmd-result ->+>+>-.mov4)
::
::  WHERE <column> NOT IN (list @)
++  test-not-in-03
  =|  run=@ud
  =/  expected  :~  %results
                    [%message 'SELECT']
                    [%result-set ~]
                    [%server-time ~2012.5.3]
                    [%message 'db1.dbo.my-table']
                    [%schema-time ~2012.5.1]
                    [%data-time ~2012.5.2]
                    [%vector-count 0]
                ==
  =^  mov1  agent
    %:  ~(on-poke agent (bowl [run ~2012.4.30]))
        %obelisk-action
        !>([%tape %sys "CREATE DATABASE db1"])
    ==
  =.  run  +(run)
  =^  mov2  agent
    %:  ~(on-poke agent (bowl [run ~2012.5.1]))
        %obelisk-action
        !>  :+  %tape
                %db1
                "CREATE TABLE db1..my-table ".
                "(col1 @t, col2 @da, col3 @t, col4 @t) ".
                "PRIMARY KEY (col1)"
    ==
  =.  run  +(run)
  =^  mov3  agent
    %:  ~(on-poke agent (bowl [run ~2012.5.2]))
        %obelisk-action
        !>  :+  %tape
                %db1
                "INSERT INTO my-table".
                " VALUES".
                " ('Abby', ~1999.2.19, 'tricolor', 'row1')".
                " ('Ace', ~2005.12.19, 'ticolor', 'row2')".
                " ('Angel', ~2001.9.19, 'Angel', 'row3')"
    ==
  =.  run  +(run)
  =^  mov4  agent
    %:  ~(on-poke agent (bowl [run ~2012.5.3]))
        %obelisk-action
        !>([%tape %db1 "FROM my-table WHERE col1 NOT IN ('Abby', 'Ace', 'Angel') SELECT *"])
    ==
  %+  expect-eq
    !>  expected
    !>  ;;(cmd-result ->+>+>-.mov4)

::
::  fail WHERE <column> NOT IN (list @t) types differ
++  test-fail-not-in-00
  =|  run=@ud
  =/  expected-rows
        :~
          :-  %vector
              :~  [%col1 [~.t 'Angel']]
                  [%col2 [~.da ~2001.9.19]]
                  [%col3 [~.t 'Angel']]
                  [%col4 [~.t 'row3']]
                  ==
            ==
  =/  expected  :~  %results
                    [%message 'SELECT']
                    [%result-set expected-rows]
                    [%server-time ~2012.5.3]
                    [%message 'db1.dbo.my-table']
                    [%schema-time ~2012.5.1]
                    [%data-time ~2012.5.2]
                    [%vector-count 1]
                ==
  =^  mov1  agent
    %:  ~(on-poke agent (bowl [run ~2012.4.30]))
        %obelisk-action
        !>([%tape %sys "CREATE DATABASE db1"])
    ==
  =.  run  +(run)
  =^  mov2  agent
    %:  ~(on-poke agent (bowl [run ~2012.5.1]))
        %obelisk-action
        !>  :+  %tape
                %db1
                "CREATE TABLE db1..my-table ".
                "(col1 @t, col2 @da, col3 @t, col4 @t) ".
                "PRIMARY KEY (col1)"
    ==
    =.  run  +(run)
  =^  mov3  agent
    %:  ~(on-poke agent (bowl [run ~2012.5.2]))
        %obelisk-action
        !>  :+  %tape
                %db1
                "INSERT INTO my-table".
                " VALUES".
                " ('Abby', ~1999.2.19, 'tricolor', 'row1')".
                " ('Ace', ~2005.12.19, 'ticolor', 'row2')".
                " ('Angel', ~2001.9.19, 'Angel', 'row3')"
    ==
  =.  run  +(run)
  ::
  %+  expect-fail-message
      %-  crip
          "type of IN list incorrect, should be p=~.t"
  |.  %:  ~(on-poke agent (bowl [run ~2012.5.2]))
          %obelisk-action
          !>([%tape %db1 "FROM my-table WHERE col3 IN (~1999.2.19, ~2005.12.19, ~2001.9.19) SELECT *"])
      ==
::
::  fail WHERE <literal> NOT IN (list @) types differ
++  test-fail-not-in-01
  =|  run=@ud
  =/  expected-rows
        :~
          :-  %vector
              :~  [%col1 [~.t 'Angel']]
                  [%col2 [~.da ~2001.9.19]]
                  [%col3 [~.t 'Angel']]
                  [%col4 [~.t 'row3']]
                  ==
            ==
  =/  expected  :~  %results
                    [%message 'SELECT']
                    [%result-set expected-rows]
                    [%server-time ~2012.5.3]
                    [%message 'db1.dbo.my-table']
                    [%schema-time ~2012.5.1]
                    [%data-time ~2012.5.2]
                    [%vector-count 1]
                ==
  =^  mov1  agent
    %:  ~(on-poke agent (bowl [run ~2012.4.30]))
        %obelisk-action
        !>([%tape %sys "CREATE DATABASE db1"])
    ==
  =.  run  +(run)
  =^  mov2  agent
    %:  ~(on-poke agent (bowl [run ~2012.5.1]))
        %obelisk-action
        !>  :+  %tape
                %db1
                "CREATE TABLE db1..my-table ".
                "(col1 @t, col2 @da, col3 @t, col4 @t) ".
                "PRIMARY KEY (col1)"
    ==
    =.  run  +(run)
  =^  mov3  agent
    %:  ~(on-poke agent (bowl [run ~2012.5.2]))
        %obelisk-action
        !>  :+  %tape
                %db1
                "INSERT INTO my-table".
                " VALUES".
                " ('Abby', ~1999.2.19, 'tricolor', 'row1')".
                " ('Ace', ~2005.12.19, 'ticolor', 'row2')".
                " ('Angel', ~2001.9.19, 'Angel', 'row3')"
    ==
  =.  run  +(run)
  ::
  %+  expect-fail-message
      %-  crip
          "type of IN list incorrect, should be p=~.t"
  |.  %:  ~(on-poke agent (bowl [run ~2012.5.2]))
          %obelisk-action
          !>([%tape %db1 "FROM my-table WHERE 'ticolor' IN (~1999.2.19, ~2005.12.19, ~2001.9.19) SELECT *"])
      ==
::
::  BETWEEN
::
::  WHERE <column> BETWEEN <literal> AND <literal>
++  test-between-00
  =|  run=@ud
  =/  expected-rows
        :~
          :-  %vector
              :~  [%col1 [~.t 'Abby']]
                  [%col2 [~.da ~1999.2.19]]
                  [%col3 [~.t 'tricolor']]
                  [%col4 [~.t 'row1']]
                  ==
          :-  %vector
              :~  [%col1 [~.t 'Ace']]
                  [%col2 [~.da ~2005.12.19]]
                  [%col3 [~.t 'ticolor']]
                  [%col4 [~.t 'row2']]
                  ==
            ==
  =/  expected  :~  %results
                    [%message 'SELECT']
                    [%result-set expected-rows]
                    [%server-time ~2012.5.3]
                    [%message 'db1.dbo.my-table']
                    [%schema-time ~2012.5.1]
                    [%data-time ~2012.5.2]
                    [%vector-count 2]
                ==
  =^  mov1  agent
    %:  ~(on-poke agent (bowl [run ~2012.4.30]))
        %obelisk-action
        !>([%tape %sys "CREATE DATABASE db1"])
    ==
  =.  run  +(run)
  =^  mov2  agent
    %:  ~(on-poke agent (bowl [run ~2012.5.1]))
        %obelisk-action
        !>  :+  %tape
                %db1
                "CREATE TABLE db1..my-table ".
                "(col1 @t, col2 @da, col3 @t, col4 @t) ".
                "PRIMARY KEY (col1)"
    ==
    =.  run  +(run)
  =^  mov3  agent
    %:  ~(on-poke agent (bowl [run ~2012.5.2]))
        %obelisk-action
        !>  :+  %tape
                %db1
                "INSERT INTO my-table".
                " VALUES".
                " ('Abby', ~1999.2.19, 'tricolor', 'row1')".
                " ('Ace', ~2005.12.19, 'ticolor', 'row2')".
                " ('Angel', ~2001.9.19, 'tuxedo', 'row3')"
    ==
  =.  run  +(run)
  =^  mov4  agent
    %:  ~(on-poke agent (bowl [run ~2012.5.3]))
        %obelisk-action
        !>([%tape %db1 "FROM my-table WHERE col3 BETWEEN 'ticolor' AND 'tummy' SELECT *"])
    ==
  %+  expect-eq
    !>  expected
    !>  ;;(cmd-result ->+>+>-.mov4)
::
::  WHERE <literal> BETWEEN <column> AND <literal>
++  test-between-01
  =|  run=@ud
  =/  expected-rows
        :~
          :-  %vector
              :~  [%col1 [~.t 'Abby']]
                  [%col2 [~.da ~1999.2.19]]
                  [%col3 [~.t 'tricolor']]
                  [%col4 [~.t 'row1']]
                  ==
          :-  %vector
              :~  [%col1 [~.t 'Ace']]
                  [%col2 [~.da ~2005.12.19]]
                  [%col3 [~.t 'ticolor']]
                  [%col4 [~.t 'row2']]
                  ==
          :-  %vector
              :~  [%col1 [~.t 'Angel']]
                  [%col2 [~.da ~2001.9.19]]
                  [%col3 [~.t 'tuxedo']]
                  [%col4 [~.t 'row3']]
                  ==
            ==
  =/  expected  :~  %results
                    [%message 'SELECT']
                    [%result-set expected-rows]
                    [%server-time ~2012.5.3]
                    [%message 'db1.dbo.my-table']
                    [%schema-time ~2012.5.1]
                    [%data-time ~2012.5.2]
                    [%vector-count 3]
                ==
  =^  mov1  agent
    %:  ~(on-poke agent (bowl [run ~2012.4.30]))
        %obelisk-action
        !>([%tape %sys "CREATE DATABASE db1"])
    ==
  =.  run  +(run)
  =^  mov2  agent
    %:  ~(on-poke agent (bowl [run ~2012.5.1]))
        %obelisk-action
        !>  :+  %tape
                %db1
                "CREATE TABLE db1..my-table ".
                "(col1 @t, col2 @da, col3 @t, col4 @t) ".
                "PRIMARY KEY (col1)"
    ==
    =.  run  +(run)
  =^  mov3  agent
    %:  ~(on-poke agent (bowl [run ~2012.5.2]))
        %obelisk-action
        !>  :+  %tape
                %db1
                "INSERT INTO my-table".
                " VALUES".
                " ('Abby', ~1999.2.19, 'tricolor', 'row1')".
                " ('Ace', ~2005.12.19, 'ticolor', 'row2')".
                " ('Angel', ~2001.9.19, 'tuxedo', 'row3')"
    ==
  =.  run  +(run)
  =^  mov4  agent
    %:  ~(on-poke agent (bowl [run ~2012.5.3]))
        %obelisk-action
        !>([%tape %db1 "FROM my-table WHERE 'tuxedo' BETWEEN col3 AND 'tuxedos' SELECT *"])
    ==
  %+  expect-eq
    !>  expected
    !>  ;;(cmd-result ->+>+>-.mov4)
::
::  WHERE <column> BETWEEN <column> <column> (no optional AND)
++  test-between-02
  =|  run=@ud
  =/  expected-rows
        :~
          :-  %vector
              :~  [%col1 [~.t 'Angel']]
                  [%col2 [~.da ~2001.9.19]]
                  [%col3 [~.t 'Angel']]
                  [%col4 [~.t 'row3']]
                  ==
            ==
  =/  expected  :~  %results
                    [%message 'SELECT']
                    [%result-set expected-rows]
                    [%server-time ~2012.5.3]
                    [%message 'db1.dbo.my-table']
                    [%schema-time ~2012.5.1]
                    [%data-time ~2012.5.2]
                    [%vector-count 1]
                ==
  =^  mov1  agent
    %:  ~(on-poke agent (bowl [run ~2012.4.30]))
        %obelisk-action
        !>([%tape %sys "CREATE DATABASE db1"])
    ==
  =.  run  +(run)
  =^  mov2  agent
    %:  ~(on-poke agent (bowl [run ~2012.5.1]))
        %obelisk-action
        !>  :+  %tape
                %db1
                "CREATE TABLE db1..my-table ".
                "(col1 @t, col2 @da, col3 @t, col4 @t) ".
                "PRIMARY KEY (col1)"
    ==
    =.  run  +(run)
  =^  mov3  agent
    %:  ~(on-poke agent (bowl [run ~2012.5.2]))
        %obelisk-action
        !>  :+  %tape
                %db1
                "INSERT INTO my-table".
                " VALUES".
                " ('Abby', ~1999.2.19, 'tricolor', 'row1')".
                " ('Ace', ~2005.12.19, 'ticolor', 'row2')".
                " ('Angel', ~2001.9.19, 'Angel', 'row3')"
    ==
  =.  run  +(run)
  =^  mov4  agent
    %:  ~(on-poke agent (bowl [run ~2012.5.3]))
        %obelisk-action
        !>([%tape %db1 "FROM my-table WHERE col1 BETWEEN col3 col4 SELECT *"])
    ==
  %+  expect-eq
    !>  expected
    !>  ;;(cmd-result ->+>+>-.mov4)
::
::  view WHERE <column> BETWEEN <literal> AND <literal>
++  test-between-03
  =|  run=@ud
  =/  expected-rows
        :~
          :-  %vector
              :~  [p=%namespace q=[p=~.tas q=%dbo]]
                  [p=%name q=[p=~.tas q=%my-table]]
                  [p=%col-ordinal q=[p=~.ud q=2]]
                  [p=%col-name q=[p=~.tas q=%col2]]
                  [p=%col-type q=[p=~.ta q=~.da]]
                  ==
          :-  %vector
              :~  [p=%namespace q=[p=~.tas q=%dbo]]
                  [p=%name q=[p=~.tas q=%my-table]]
                  [p=%col-ordinal q=[p=~.ud q=3]]
                  [p=%col-name q=[p=~.tas q=%col3]]
                  [p=%col-type q=[p=~.ta q=~.t]]
                  ==
            ==
  =/  expected  :~  %results
                    [%message 'SELECT']
                    [%result-set expected-rows]
                    [%server-time ~2012.5.3]
                    [%message 'db1.sys.columns']
                    [%schema-time ~2012.5.1]
                    [%data-time ~2012.5.1]
                    [%vector-count 2]
                ==
  =^  mov1  agent
    %:  ~(on-poke agent (bowl [run ~2012.4.30]))
        %obelisk-action
        !>([%tape %sys "CREATE DATABASE db1"])
    ==
  =.  run  +(run)
  =^  mov2  agent
    %:  ~(on-poke agent (bowl [run ~2012.5.1]))
        %obelisk-action
        !>  :+  %tape
                %db1
                "CREATE TABLE db1..my-table ".
                "(col1 @t, col2 @da, col3 @t, col4 @t) ".
                "PRIMARY KEY (col1)"
    ==
  =.  run  +(run)
  =^  mov3  agent
    %:  ~(on-poke agent (bowl [run ~2012.5.3]))
        %obelisk-action
        !>([%tape %db1 "FROM sys.columns WHERE col-name BETWEEN 'col2' AND 'col3' SELECT *"])
    ==
  %+  expect-eq
    !>  expected
    !>  ;;(cmd-result ->+>+>-.mov3)
::
::  fail WHERE <column> BETWEEN <literal> AND <literal> types differ
++  test-fail-between-00
  =|  run=@ud
  =^  mov1  agent
    %:  ~(on-poke agent (bowl [run ~2012.4.30]))
        %obelisk-action
        !>([%tape %sys "CREATE DATABASE db1"])
    ==
  =.  run  +(run)
  =^  mov2  agent
    %:  ~(on-poke agent (bowl [run ~2012.5.1]))
        %obelisk-action
        !>  :+  %tape
                %db1
                "CREATE TABLE db1..my-table ".
                "(col1 @t, col2 @da, col3 @t, col4 @t) ".
                "PRIMARY KEY (col1)"
    ==
    =.  run  +(run)
  =^  mov3  agent
    %:  ~(on-poke agent (bowl [run ~2012.5.2]))
        %obelisk-action
        !>  :+  %tape
                %db1
                "INSERT INTO my-table".
                " VALUES".
                " ('Abby', ~1999.2.19, 'tricolor', 'row1')".
                " ('Ace', ~2005.12.19, 'ticolor', 'row2')".
                " ('Angel', ~2001.9.19, 'Angel', 'row3')"
    ==
  =.  run  +(run)
  ::
  %+  expect-fail-message
      %-  crip
          "comparing column to literal of different aura: %col1 "
  |.  %:  ~(on-poke agent (bowl [run ~2012.5.2]))
          %obelisk-action
          !>([%tape %db1 "FROM my-table WHERE col1 BETWEEN ~1999.2.19 AND 'row1' SELECT *"])
      ==
::
::  fail WHERE <literal> BETWEEN <column> AND <column> types differ
++  test-fail-between-01
  =|  run=@ud
  =^  mov1  agent
    %:  ~(on-poke agent (bowl [run ~2012.4.30]))
        %obelisk-action
        !>([%tape %sys "CREATE DATABASE db1"])
    ==
  =.  run  +(run)
  =^  mov2  agent
    %:  ~(on-poke agent (bowl [run ~2012.5.1]))
        %obelisk-action
        !>  :+  %tape
                %db1
                "CREATE TABLE db1..my-table ".
                "(col1 @t, col2 @da, col3 @t, col4 @t) ".
                "PRIMARY KEY (col1)"
    ==
    =.  run  +(run)
  =^  mov3  agent
    %:  ~(on-poke agent (bowl [run ~2012.5.2]))
        %obelisk-action
        !>  :+  %tape
                %db1
                "INSERT INTO my-table".
                " VALUES".
                " ('Abby', ~1999.2.19, 'tricolor', 'row1')".
                " ('Ace', ~2005.12.19, 'ticolor', 'row2')".
                " ('Angel', ~2001.9.19, 'Angel', 'row3')"
    ==
  =.  run  +(run)
  ::
  %+  expect-fail-message
      %-  crip
          "comparing column to literal of different aura: %col1 "
  |.  %:  ~(on-poke agent (bowl [run ~2012.5.2]))
          %obelisk-action
          !>([%tape %db1 "FROM my-table WHERE ~1999.2.19 BETWEEN col1 AND col2 SELECT *"])
      ==
::
::  fail WHERE <column> BETWEEN <column> AND <column> types differ
++  test-fail-between-02
  =|  run=@ud
  =^  mov1  agent
    %:  ~(on-poke agent (bowl [run ~2012.4.30]))
        %obelisk-action
        !>([%tape %sys "CREATE DATABASE db1"])
    ==
  =.  run  +(run)
  =^  mov2  agent
    %:  ~(on-poke agent (bowl [run ~2012.5.1]))
        %obelisk-action
        !>  :+  %tape
                %db1
                "CREATE TABLE db1..my-table ".
                "(col1 @t, col2 @da, col3 @t, col4 @t) ".
                "PRIMARY KEY (col1)"
    ==
    =.  run  +(run)
  =^  mov3  agent
    %:  ~(on-poke agent (bowl [run ~2012.5.2]))
        %obelisk-action
        !>  :+  %tape
                %db1
                "INSERT INTO my-table".
                " VALUES".
                " ('Abby', ~1999.2.19, 'tricolor', 'row1')".
                " ('Ace', ~2005.12.19, 'ticolor', 'row2')".
                " ('Angel', ~2001.9.19, 'Angel', 'row3')"
    ==
  =.  run  +(run)
  ::
  %+  expect-fail-message
      %-  crip
          "comparing columns of differing auras: %col1 %col2"
  |.  %:  ~(on-poke agent (bowl [run ~2012.5.2]))
          %obelisk-action
          !>([%tape %db1 "FROM my-table WHERE col1 BETWEEN col2 AND col3 SELECT *"])
      ==
::
::  fail WHERE <column> BETWEEN <column> AND <column> range not ascending
++  test-fail-between-03
  =|  run=@ud
  =^  mov1  agent
    %:  ~(on-poke agent (bowl [run ~2012.4.30]))
        %obelisk-action
        !>([%tape %sys "CREATE DATABASE db1"])
    ==
  =.  run  +(run)
  =^  mov2  agent
    %:  ~(on-poke agent (bowl [run ~2012.5.1]))
        %obelisk-action
        !>  :+  %tape
                %db1
                "CREATE TABLE db1..my-table ".
                "(col1 @t, col2 @da, col3 @t, col4 @t) ".
                "PRIMARY KEY (col1)"
    ==
    =.  run  +(run)
  =^  mov3  agent
    %:  ~(on-poke agent (bowl [run ~2012.5.2]))
        %obelisk-action
        !>  :+  %tape
                %db1
                "INSERT INTO my-table".
                " VALUES".
                " ('Abby', ~1999.2.19, 'tricolor', 'row1')".
                " ('Ace', ~2005.12.19, 'ticolor', 'row2')".
                " ('Angel', ~2001.9.19, 'Angel', 'row3')"
    ==
  =.  run  +(run)
  ::
  %+  expect-fail-message
      %-  crip
          "comparing column to literal of different aura: %col1"
  |.  %:  ~(on-poke agent (bowl [run ~2012.5.2]))
          %obelisk-action
          !>([%tape %db1 "FROM my-table WHERE col1 BETWEEN ~2005.12.19 AND ~1999.2.19 SELECT *"])
      ==
::
::  NOT BETWEEN
::
::  WHERE <column> NOT BETWEEN <literal> AND <literal>
++  test-not-between-00
  =|  run=@ud
  =/  expected-rows
        :~
          :-  %vector
              :~  [%col1 [~.t 'Angel']]
                  [%col2 [~.da ~2001.9.19]]
                  [%col3 [~.t 'tuxedo']]
                  [%col4 [~.t 'row3']]
                  ==
            ==
  =/  expected  :~  %results
                    [%message 'SELECT']
                    [%result-set expected-rows]
                    [%server-time ~2012.5.3]
                    [%message 'db1.dbo.my-table']
                    [%schema-time ~2012.5.1]
                    [%data-time ~2012.5.2]
                    [%vector-count 1]
                ==
  =^  mov1  agent
    %:  ~(on-poke agent (bowl [run ~2012.4.30]))
        %obelisk-action
        !>([%tape %sys "CREATE DATABASE db1"])
    ==
  =.  run  +(run)
  =^  mov2  agent
    %:  ~(on-poke agent (bowl [run ~2012.5.1]))
        %obelisk-action
        !>  :+  %tape
                %db1
                "CREATE TABLE db1..my-table ".
                "(col1 @t, col2 @da, col3 @t, col4 @t) ".
                "PRIMARY KEY (col1)"
    ==
    =.  run  +(run)
  =^  mov3  agent
    %:  ~(on-poke agent (bowl [run ~2012.5.2]))
        %obelisk-action
        !>  :+  %tape
                %db1
                "INSERT INTO my-table".
                " VALUES".
                " ('Abby', ~1999.2.19, 'tricolor', 'row1')".
                " ('Ace', ~2005.12.19, 'ticolor', 'row2')".
                " ('Angel', ~2001.9.19, 'tuxedo', 'row3')"
    ==
  =.  run  +(run)
  =^  mov4  agent
    %:  ~(on-poke agent (bowl [run ~2012.5.3]))
        %obelisk-action
        !>([%tape %db1 "FROM my-table WHERE col3 NOT BETWEEN 'ticolor' AND 'tummy' SELECT *"])
    ==
  %+  expect-eq
    !>  expected
    !>  ;;(cmd-result ->+>+>-.mov4)
::
::  WHERE <literal> NOT BETWEEN <column> AND <literal>
++  test-not-between-01
  =|  run=@ud
  =/  expected  :~  %results
                    [%message 'SELECT']
                    [%result-set ~]
                    [%server-time ~2012.5.3]
                    [%message 'db1.dbo.my-table']
                    [%schema-time ~2012.5.1]
                    [%data-time ~2012.5.2]
                    [%vector-count 0]
                ==
  =^  mov1  agent
    %:  ~(on-poke agent (bowl [run ~2012.4.30]))
        %obelisk-action
        !>([%tape %sys "CREATE DATABASE db1"])
    ==
  =.  run  +(run)
  =^  mov2  agent
    %:  ~(on-poke agent (bowl [run ~2012.5.1]))
        %obelisk-action
        !>  :+  %tape
                %db1
                "CREATE TABLE db1..my-table ".
                "(col1 @t, col2 @da, col3 @t, col4 @t) ".
                "PRIMARY KEY (col1)"
    ==
    =.  run  +(run)
  =^  mov3  agent
    %:  ~(on-poke agent (bowl [run ~2012.5.2]))
        %obelisk-action
        !>  :+  %tape
                %db1
                "INSERT INTO my-table".
                " VALUES".
                " ('Abby', ~1999.2.19, 'tricolor', 'row1')".
                " ('Ace', ~2005.12.19, 'ticolor', 'row2')".
                " ('Angel', ~2001.9.19, 'tuxedo', 'row3')"
    ==
  =.  run  +(run)
  =^  mov4  agent
    %:  ~(on-poke agent (bowl [run ~2012.5.3]))
        %obelisk-action
        !>([%tape %db1 "FROM my-table WHERE 'tuxedo' NOT BETWEEN col3 AND 'tuxedos' SELECT *"])
    ==
  %+  expect-eq
    !>  expected
    !>  ;;(cmd-result ->+>+>-.mov4)
::
::  WHERE <column> NOT BETWEEN <column> <column> (no optional AND)
++  test-not-between-02
  =|  run=@ud
  =/  expected-rows
        :~
          :-  %vector
              :~  [%col1 [~.t 'Abby']]
                  [%col2 [~.da ~1999.2.19]]
                  [%col3 [~.t 'tricolor']]
                  [%col4 [~.t 'row1']]
                  ==
          :-  %vector
              :~  [%col1 [~.t 'Ace']]
                  [%col2 [~.da ~2005.12.19]]
                  [%col3 [~.t 'ticolor']]
                  [%col4 [~.t 'row2']]
                  ==
            ==
  =/  expected  :~  %results
                    [%message 'SELECT']
                    [%result-set expected-rows]
                    [%server-time ~2012.5.3]
                    [%message 'db1.dbo.my-table']
                    [%schema-time ~2012.5.1]
                    [%data-time ~2012.5.2]
                    [%vector-count 2]
                ==
  =^  mov1  agent
    %:  ~(on-poke agent (bowl [run ~2012.4.30]))
        %obelisk-action
        !>([%tape %sys "CREATE DATABASE db1"])
    ==
  =.  run  +(run)
  =^  mov2  agent
    %:  ~(on-poke agent (bowl [run ~2012.5.1]))
        %obelisk-action
        !>  :+  %tape
                %db1
                "CREATE TABLE db1..my-table ".
                "(col1 @t, col2 @da, col3 @t, col4 @t) ".
                "PRIMARY KEY (col1)"
    ==
    =.  run  +(run)
  =^  mov3  agent
    %:  ~(on-poke agent (bowl [run ~2012.5.2]))
        %obelisk-action
        !>  :+  %tape
                %db1
                "INSERT INTO my-table".
                " VALUES".
                " ('Abby', ~1999.2.19, 'tricolor', 'row1')".
                " ('Ace', ~2005.12.19, 'ticolor', 'row2')".
                " ('Angel', ~2001.9.19, 'Angel', 'row3')"
    ==
  =.  run  +(run)
  =^  mov4  agent
    %:  ~(on-poke agent (bowl [run ~2012.5.3]))
        %obelisk-action
        !>([%tape %db1 "FROM my-table WHERE col1 NOT BETWEEN col3 col4 SELECT *"])
    ==
  %+  expect-eq
    !>  expected
    !>  ;;(cmd-result ->+>+>-.mov4)
::
::  view WHERE <column> NOT BETWEEN <literal> AND <literal>
++  test-not-between-03
  =|  run=@ud
  =/  expected-rows
        :~
          :-  %vector
              :~  [p=%namespace q=[p=~.tas q=%dbo]]
                  [p=%name q=[p=~.tas q=%my-table]]
                  [p=%col-ordinal q=[p=~.ud q=1]]
                  [p=%col-name q=[p=~.tas q=%col1]]
                  [p=%col-type q=[p=~.ta q=~.t]]
                  ==
          :-  %vector
              :~  [p=%namespace q=[p=~.tas q=%dbo]]
                  [p=%name q=[p=~.tas q=%my-table]]
                  [p=%col-ordinal q=[p=~.ud q=4]]
                  [p=%col-name q=[p=~.tas q=%col4]]
                  [p=%col-type q=[p=~.ta q=~.t]]
                  ==
            ==
  =/  expected  :~  %results
                    [%message 'SELECT']
                    [%result-set expected-rows]
                    [%server-time ~2012.5.3]
                    [%message 'db1.sys.columns']
                    [%schema-time ~2012.5.1]
                    [%data-time ~2012.5.1]
                    [%vector-count 2]
                ==
  =^  mov1  agent
    %:  ~(on-poke agent (bowl [run ~2012.4.30]))
        %obelisk-action
        !>([%tape %sys "CREATE DATABASE db1"])
    ==
  =.  run  +(run)
  =^  mov2  agent
    %:  ~(on-poke agent (bowl [run ~2012.5.1]))
        %obelisk-action
        !>  :+  %tape
                %db1
                "CREATE TABLE db1..my-table ".
                "(col1 @t, col2 @da, col3 @t, col4 @t) ".
                "PRIMARY KEY (col1)"
    ==
  =.  run  +(run)
  =^  mov3  agent
    %:  ~(on-poke agent (bowl [run ~2012.5.3]))
        %obelisk-action
        !>([%tape %db1 "FROM sys.columns WHERE col-name NOT BETWEEN 'col2' AND 'col3' SELECT *"])
    ==
  %+  expect-eq
    !>  expected
    !>  ;;(cmd-result ->+>+>-.mov3)
::
::  fail WHERE <column> NOT BETWEEN <literal> AND <literal> types differ
++  test-fail-not-between-00
  =|  run=@ud
  =^  mov1  agent
    %:  ~(on-poke agent (bowl [run ~2012.4.30]))
        %obelisk-action
        !>([%tape %sys "CREATE DATABASE db1"])
    ==
  =.  run  +(run)
  =^  mov2  agent
    %:  ~(on-poke agent (bowl [run ~2012.5.1]))
        %obelisk-action
        !>  :+  %tape
                %db1
                "CREATE TABLE db1..my-table ".
                "(col1 @t, col2 @da, col3 @t, col4 @t) ".
                "PRIMARY KEY (col1)"
    ==
    =.  run  +(run)
  =^  mov3  agent
    %:  ~(on-poke agent (bowl [run ~2012.5.2]))
        %obelisk-action
        !>  :+  %tape
                %db1
                "INSERT INTO my-table".
                " VALUES".
                " ('Abby', ~1999.2.19, 'tricolor', 'row1')".
                " ('Ace', ~2005.12.19, 'ticolor', 'row2')".
                " ('Angel', ~2001.9.19, 'Angel', 'row3')"
    ==
  =.  run  +(run)
  ::
  %+  expect-fail-message
      %-  crip
          "comparing column to literal of different aura: %col1 "
  |.  %:  ~(on-poke agent (bowl [run ~2012.5.2]))
          %obelisk-action
          !>([%tape %db1 "FROM my-table WHERE col1 NOT BETWEEN ~1999.2.19 AND 'row1' SELECT *"])
      ==
::
::  fail WHERE <literal> NOT BETWEEN <column> AND <column> types differ
++  test-fail-not-between-01
  =|  run=@ud
  =^  mov1  agent
    %:  ~(on-poke agent (bowl [run ~2012.4.30]))
        %obelisk-action
        !>([%tape %sys "CREATE DATABASE db1"])
    ==
  =.  run  +(run)
  =^  mov2  agent
    %:  ~(on-poke agent (bowl [run ~2012.5.1]))
        %obelisk-action
        !>  :+  %tape
                %db1
                "CREATE TABLE db1..my-table ".
                "(col1 @t, col2 @da, col3 @t, col4 @t) ".
                "PRIMARY KEY (col1)"
    ==
    =.  run  +(run)
  =^  mov3  agent
    %:  ~(on-poke agent (bowl [run ~2012.5.2]))
        %obelisk-action
        !>  :+  %tape
                %db1
                "INSERT INTO my-table".
                " VALUES".
                " ('Abby', ~1999.2.19, 'tricolor', 'row1')".
                " ('Ace', ~2005.12.19, 'ticolor', 'row2')".
                " ('Angel', ~2001.9.19, 'Angel', 'row3')"
    ==
  =.  run  +(run)
  ::
  %+  expect-fail-message
      %-  crip
          "comparing column to literal of different aura: %col1 "
  |.  %:  ~(on-poke agent (bowl [run ~2012.5.2]))
          %obelisk-action
          !>([%tape %db1 "FROM my-table WHERE ~1999.2.19 NOT BETWEEN col1 AND col2 SELECT *"])
      ==
::
::  fail WHERE <column> NOT BETWEEN <column> AND <column> types differ
++  test-fail-not-between-02
  =|  run=@ud
  =^  mov1  agent
    %:  ~(on-poke agent (bowl [run ~2012.4.30]))
        %obelisk-action
        !>([%tape %sys "CREATE DATABASE db1"])
    ==
  =.  run  +(run)
  =^  mov2  agent
    %:  ~(on-poke agent (bowl [run ~2012.5.1]))
        %obelisk-action
        !>  :+  %tape
                %db1
                "CREATE TABLE db1..my-table ".
                "(col1 @t, col2 @da, col3 @t, col4 @t) ".
                "PRIMARY KEY (col1)"
    ==
    =.  run  +(run)
  =^  mov3  agent
    %:  ~(on-poke agent (bowl [run ~2012.5.2]))
        %obelisk-action
        !>  :+  %tape
                %db1
                "INSERT INTO my-table".
                " VALUES".
                " ('Abby', ~1999.2.19, 'tricolor', 'row1')".
                " ('Ace', ~2005.12.19, 'ticolor', 'row2')".
                " ('Angel', ~2001.9.19, 'Angel', 'row3')"
    ==
  =.  run  +(run)
  ::
  %+  expect-fail-message
      %-  crip
          "comparing columns of differing auras: %col1 %col2"
  |.  %:  ~(on-poke agent (bowl [run ~2012.5.2]))
          %obelisk-action
          !>([%tape %db1 "FROM my-table WHERE col1 NOT BETWEEN col2 AND col3 SELECT *"])
      ==
::
::  fail WHERE <column> NOT BETWEEN <column> AND <column> range not ascending
++  test-fail-not-between-03
  =|  run=@ud
  =^  mov1  agent
    %:  ~(on-poke agent (bowl [run ~2012.4.30]))
        %obelisk-action
        !>([%tape %sys "CREATE DATABASE db1"])
    ==
  =.  run  +(run)
  =^  mov2  agent
    %:  ~(on-poke agent (bowl [run ~2012.5.1]))
        %obelisk-action
        !>  :+  %tape
                %db1
                "CREATE TABLE db1..my-table ".
                "(col1 @t, col2 @da, col3 @t, col4 @t) ".
                "PRIMARY KEY (col1)"
    ==
    =.  run  +(run)
  =^  mov3  agent
    %:  ~(on-poke agent (bowl [run ~2012.5.2]))
        %obelisk-action
        !>  :+  %tape
                %db1
                "INSERT INTO my-table".
                " VALUES".
                " ('Abby', ~1999.2.19, 'tricolor', 'row1')".
                " ('Ace', ~2005.12.19, 'ticolor', 'row2')".
                " ('Angel', ~2001.9.19, 'Angel', 'row3')"
    ==
  =.  run  +(run)
  ::
  %+  expect-fail-message
      %-  crip
          "comparing column to literal of different aura: %col1"
  |.  %:  ~(on-poke agent (bowl [run ~2012.5.2]))
          %obelisk-action
          !>([%tape %db1 "FROM my-table WHERE col1 NOT BETWEEN ~2005.12.19 AND ~1999.2.19 SELECT *"])
      ==
::
::  OR
::
::  WHERE <column> = <literal> OR <column> = <literal>
++  test-or-00
  =|  run=@ud
  =/  expected-rows
        :~
          :-  %vector
              :~  [%col1 [~.t 'Abby']]
                  [%col2 [~.da ~1999.2.19]]
                  [%col3 [~.t 'tricolor']]
                  [%col4 [~.t 'row1']]
                  ==
          :-  %vector
              :~  [%col1 [~.t 'Ace']]
                  [%col2 [~.da ~2005.12.19]]
                  [%col3 [~.t 'ticolor']]
                  [%col4 [~.t 'row2']]
                  ==
            ==
  =/  expected  :~  %results
                    [%message 'SELECT']
                    [%result-set expected-rows]
                    [%server-time ~2012.5.3]
                    [%message 'db1.dbo.my-table']
                    [%schema-time ~2012.5.1]
                    [%data-time ~2012.5.2]
                    [%vector-count 2]
                ==
  =^  mov1  agent
    %:  ~(on-poke agent (bowl [run ~2012.4.30]))
        %obelisk-action
        !>([%tape %sys "CREATE DATABASE db1"])
    ==
  =.  run  +(run)
  =^  mov2  agent
    %:  ~(on-poke agent (bowl [run ~2012.5.1]))
        %obelisk-action
        !>  :+  %tape
                %db1
                "CREATE TABLE db1..my-table ".
                "(col1 @t, col2 @da, col3 @t, col4 @t) ".
                "PRIMARY KEY (col1)"
    ==
    =.  run  +(run)
  =^  mov3  agent
    %:  ~(on-poke agent (bowl [run ~2012.5.2]))
        %obelisk-action
        !>  :+  %tape
                %db1
                "INSERT INTO my-table".
                " VALUES".
                " ('Abby', ~1999.2.19, 'tricolor', 'row1')".
                " ('Ace', ~2005.12.19, 'ticolor', 'row2')".
                " ('Angel', ~2001.9.19, 'tuxedo', 'row3')"
    ==
  =.  run  +(run)
  =^  mov4  agent
    %:  ~(on-poke agent (bowl [run ~2012.5.3]))
        %obelisk-action
        !>([%tape %db1 "FROM my-table WHERE col3 = 'ticolor' OR col3='tricolor' SELECT *"])
    ==
  %+  expect-eq
    !>  expected
    !>  ;;(cmd-result ->+>+>-.mov4)
::
::  WHERE <column> = <column> OR <column> = <column>
++  test-or-01
  =|  run=@ud
  =/  expected-rows
        :~
          :-  %vector
              :~  [%col1 [~.t 'Angel']]
                  [%col2 [~.da ~2001.9.19]]
                  [%col3 [~.t 'Angel']]
                  [%col4 [~.t 'row3']]
                  ==
            ==
  =/  expected  :~  %results
                    [%message 'SELECT']
                    [%result-set expected-rows]
                    [%server-time ~2012.5.3]
                    [%message 'db1.dbo.my-table']
                    [%schema-time ~2012.5.1]
                    [%data-time ~2012.5.2]
                    [%vector-count 1]
                ==
  =^  mov1  agent
    %:  ~(on-poke agent (bowl [run ~2012.4.30]))
        %obelisk-action
        !>([%tape %sys "CREATE DATABASE db1"])
    ==
  =.  run  +(run)
  =^  mov2  agent
    %:  ~(on-poke agent (bowl [run ~2012.5.1]))
        %obelisk-action
        !>  :+  %tape
                %db1
                "CREATE TABLE db1..my-table ".
                "(col1 @t, col2 @da, col3 @t, col4 @t) ".
                "PRIMARY KEY (col1)"
    ==
    =.  run  +(run)
  =^  mov3  agent
    %:  ~(on-poke agent (bowl [run ~2012.5.2]))
        %obelisk-action
        !>  :+  %tape
                %db1
                "INSERT INTO my-table".
                " VALUES".
                " ('Abby', ~1999.2.19, 'tricolor', 'row1')".
                " ('Ace', ~2005.12.19, 'ticolor', 'row2')".
                " ('Angel', ~2001.9.19, 'Angel', 'row3')"
    ==
  =.  run  +(run)
  =^  mov4  agent
    %:  ~(on-poke agent (bowl [run ~2012.5.3]))
        %obelisk-action
        !>([%tape %db1 "FROM my-table WHERE col1 = col3 OR col3=col4 SELECT *"])
    ==
  %+  expect-eq
    !>  expected
    !>  ;;(cmd-result ->+>+>-.mov4)
::
::  WHERE <column> = ... AND ... OR ... AND ...
++  test-or-02
  =|  run=@ud
  =/  expected-rows
        :~
          :-  %vector
              :~  [%col1 [~.t 'Abby']]
                  [%col2 [~.da ~1999.2.19]]
                  [%col3 [~.t 'tricolor']]
                  [%col4 [~.t 'row1']]
                  ==
          :-  %vector
              :~  [%col1 [~.t 'Ace']]
                  [%col2 [~.da ~2005.12.19]]
                  [%col3 [~.t 'ticolor']]
                  [%col4 [~.t 'row2']]
                  ==
            ==
  =/  expected  :~  %results
                    [%message 'SELECT']
                    [%result-set expected-rows]
                    [%server-time ~2012.5.3]
                    [%message 'db1.dbo.my-table']
                    [%schema-time ~2012.5.1]
                    [%data-time ~2012.5.2]
                    [%vector-count 2]
                ==
  =^  mov1  agent
    %:  ~(on-poke agent (bowl [run ~2012.4.30]))
        %obelisk-action
        !>([%tape %sys "CREATE DATABASE db1"])
    ==
  =.  run  +(run)
  =^  mov2  agent
    %:  ~(on-poke agent (bowl [run ~2012.5.1]))
        %obelisk-action
        !>  :+  %tape
                %db1
                "CREATE TABLE db1..my-table ".
                "(col1 @t, col2 @da, col3 @t, col4 @t) ".
                "PRIMARY KEY (col1)"
    ==
    =.  run  +(run)
  =^  mov3  agent
    %:  ~(on-poke agent (bowl [run ~2012.5.2]))
        %obelisk-action
        !>  :+  %tape
                %db1
                "INSERT INTO my-table".
                " VALUES".
                " ('Abby', ~1999.2.19, 'tricolor', 'row1')".
                " ('Ace', ~2005.12.19, 'ticolor', 'row2')".
                " ('Angel', ~2001.9.19, 'tuxedo', 'row3')"
    ==
  =.  run  +(run)
  =^  mov4  agent
    %:  ~(on-poke agent (bowl [run ~2012.5.3]))
        %obelisk-action
        !>([%tape %db1 "FROM my-table WHERE (col3 = 'ticolor' AND col4='row2') OR (col3='tricolor' AND col4='row1') SELECT *"])
    ==
  %+  expect-eq
    !>  expected
    !>  ;;(cmd-result ->+>+>-.mov4)
::
::  AND
::
::  WHERE <column> = <literal> AND <column> = <literal>
++  test-and-00
  =|  run=@ud
  =/  expected-rows
        :~
          :-  %vector
              :~  [%col1 [~.t 'Ace']]
                  [%col2 [~.da ~2005.12.19]]
                  [%col3 [~.t 'ticolor']]
                  [%col4 [~.t 'row2']]
                  ==
            ==
  =/  expected  :~  %results
                    [%message 'SELECT']
                    [%result-set expected-rows]
                    [%server-time ~2012.5.3]
                    [%message 'db1.dbo.my-table']
                    [%schema-time ~2012.5.1]
                    [%data-time ~2012.5.2]
                    [%vector-count 1]
                ==
  =^  mov1  agent
    %:  ~(on-poke agent (bowl [run ~2012.4.30]))
        %obelisk-action
        !>([%tape %sys "CREATE DATABASE db1"])
    ==
  =.  run  +(run)
  =^  mov2  agent
    %:  ~(on-poke agent (bowl [run ~2012.5.1]))
        %obelisk-action
        !>  :+  %tape
                %db1
                "CREATE TABLE db1..my-table ".
                "(col1 @t, col2 @da, col3 @t, col4 @t) ".
                "PRIMARY KEY (col1)"
    ==
    =.  run  +(run)
  =^  mov3  agent
    %:  ~(on-poke agent (bowl [run ~2012.5.2]))
        %obelisk-action
        !>  :+  %tape
                %db1
                "INSERT INTO my-table".
                " VALUES".
                " ('Abby', ~1999.2.19, 'tricolor', 'row1')".
                " ('Ace', ~2005.12.19, 'ticolor', 'row2')".
                " ('Angel', ~2001.9.19, 'tuxedo', 'row3')"
    ==
  =.  run  +(run)
  =^  mov4  agent
    %:  ~(on-poke agent (bowl [run ~2012.5.3]))
        %obelisk-action
        !>([%tape %db1 "FROM my-table WHERE col3 = 'ticolor' AND col4='row2' SELECT *"])
    ==
  %+  expect-eq
    !>  expected
    !>  ;;(cmd-result ->+>+>-.mov4)
::
::  WHERE <column> = <column> AND <column> = <literal>
++  test-and-01
  =|  run=@ud
  =/  expected-rows
        :~
          :-  %vector
              :~  [%col1 [~.t 'Angel']]
                  [%col2 [~.da ~2001.9.19]]
                  [%col3 [~.t 'Angel']]
                  [%col4 [~.t 'row3']]
                  ==
            ==
  =/  expected  :~  %results
                    [%message 'SELECT']
                    [%result-set expected-rows]
                    [%server-time ~2012.5.3]
                    [%message 'db1.dbo.my-table']
                    [%schema-time ~2012.5.1]
                    [%data-time ~2012.5.2]
                    [%vector-count 1]
                ==
  =^  mov1  agent
    %:  ~(on-poke agent (bowl [run ~2012.4.30]))
        %obelisk-action
        !>([%tape %sys "CREATE DATABASE db1"])
    ==
  =.  run  +(run)
  =^  mov2  agent
    %:  ~(on-poke agent (bowl [run ~2012.5.1]))
        %obelisk-action
        !>  :+  %tape
                %db1
                "CREATE TABLE db1..my-table ".
                "(col1 @t, col2 @da, col3 @t, col4 @t) ".
                "PRIMARY KEY (col1)"
    ==
    =.  run  +(run)
  =^  mov3  agent
    %:  ~(on-poke agent (bowl [run ~2012.5.2]))
        %obelisk-action
        !>  :+  %tape
                %db1
                "INSERT INTO my-table".
                " VALUES".
                " ('Abby', ~1999.2.19, 'tricolor', 'row1')".
                " ('Ace', ~2005.12.19, 'ticolor', 'row2')".
                " ('Angel', ~2001.9.19, 'Angel', 'row3')"
    ==
  =.  run  +(run)
  =^  mov4  agent
    %:  ~(on-poke agent (bowl [run ~2012.5.3]))
        %obelisk-action
        !>([%tape %db1 "FROM my-table WHERE col1 = col3 AND col4='row3' SELECT *"])
    ==
  %+  expect-eq
    !>  expected
    !>  ;;(cmd-result ->+>+>-.mov4)
--