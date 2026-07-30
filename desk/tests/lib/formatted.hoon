::  Tests for formatted %obelisk action results.
::
/-  ast=obelisk-ast
/+  *format, *test, *test-helpers
/=  agent  /app/obelisk
|%
::
++  setup
  ^-  tape
  %-  zing
  :~  "CREATE DATABASE db1;"
      "CREATE TABLE db1..same-a (id @ud, label @t) PRIMARY KEY (id);"
      "CREATE TABLE db1..same-b (id @ud, label @t) PRIMARY KEY (id);"
      "CREATE TABLE db1..hex-c (id @ux, label @t) PRIMARY KEY (id);"
      "INSERT INTO db1..same-a VALUES (1, 'alpha');"
      "INSERT INTO db1..same-b VALUES (2, 'beta');"
      "INSERT INTO db1..hex-c VALUES (0x3, 'gamma')"
      ==
::
++  heterogeneous-query
  ^-  tape
  %-  zing
  :~  "FROM same-a SELECT id, label "
      "UNION "
      "FROM hex-c SELECT id, label"
      ==
::
++  same-schema-query
  ^-  tape
  %-  zing
  :~  "FROM same-a SELECT id, label "
      "UNION "
      "FROM same-b SELECT id, label"
      ==
::
++  empty-query
  ^-  tape
  %-  zing
  :~  "FROM same-a WHERE id = 999 SELECT id, label "
      "UNION "
      "FROM same-b WHERE id = 999 SELECT id, label"
      ==
::
++  init-agent
  |=  run=@ud
  ^+  agent
  (exec-agent agent run ~2012.4.30 %db1 setup)
::
++  success
  |=  response=(each (list cmd-result:ast) tang)
  ^-  (list cmd-result:ast)
  ?-  -.response
    %&  p.response
    %|  ~|("formatted test action failed" !!)
  ==
::
++  raw-relation
  |=  results=(list cmd-result:ast)
  ^-  relation:ast
  ?~  results  ~|("formatted test: no command results" !!)
  =/  result=cmd-result:ast  (rear results)
  =/  items=(list result:ast)  +.result
  |-
  ?~  items  ~|("formatted test: no raw relation" !!)
  ?:  ?=(%relations -.i.items)
    ?~  +.i.items  ~|("formatted test: empty relation list" !!)
    i.+.i.items
  $(items t.items)
::
++  result-vectors
  |=  results=(list cmd-result:ast)
  ^-  (list vector:ast)
  ?~  results  ~|("formatted test: no command results" !!)
  =/  result=cmd-result:ast  (rear results)
  =/  items=(list result:ast)  +.result
  |-
  ?~  items  ~|("formatted test: no result set" !!)
  ?:  ?=(%result-set -.i.items)
    +.i.items
  $(items t.items)
::
++  poke-script
  |=  [run=@ud format=result-format:ast query=tape]
  ^-  (list cmd-result:ast)
  =/  ag  (init-agent run)
  =/  action-result
    (poke-action ag run ~2012.5.1 [%script %db1 format query])
  (success -.action-result)
::
++  poke-cmd-list
  |=  [run=@ud format=result-format:ast query=tape]
  ^-  (list cmd-result:ast)
  =/  ag  (init-agent run)
  =/  commands  (parse-commands %db1 query)
  =/  action-result
    (poke-action ag run ~2012.5.1 [%cmd-list format commands])
  (success -.action-result)
::
++  raw-heterogeneous-check
  |=  results=(list cmd-result:ast)
  ^-  tang
  =/  relation  (raw-relation results)
  ;:  weld
    %+  expect-eq
      !>(2)
    !>((lent columns.relation))
  ::
    %+  expect-eq
      !>(2)
    !>((lent data-rows.relation))
  ==
::
++  vector-heterogeneous-check
  |=  results=(list cmd-result:ast)
  ^-  tang
  =/  vectors  (result-vectors results)
  =/  expected
    ^-  (set vector:ast)
    %-  sy
    :~  :-  %vector
            :~  [%id [~.ud 1]]
                [%label [~.t 'alpha']]
                ==
        :-  %vector
            :~  [%id [~.ux 0x3]]
                [%label [~.t 'gamma']]
                ==
        ==
  %+  expect-eq
    !>  expected
  !>  (silt vectors)
::
::  %script supports raw relations.
++  test-script-raw-00
  =|  run=@ud
  (raw-heterogeneous-check (poke-script run %raw heterogeneous-query))
::
::  %script supports vector result sets.
++  test-script-vector-01
  =|  run=@ud
  (vector-heterogeneous-check (poke-script run %vector heterogeneous-query))
::
::  %cmd-list supports raw relations.
++  test-cmd-list-raw-02
  =|  run=@ud
  (raw-heterogeneous-check (poke-cmd-list run %raw heterogeneous-query))
::
::  %cmd-list supports vector result sets.
++  test-cmd-list-vector-03
  =|  run=@ud
  %-  vector-heterogeneous-check
  (poke-cmd-list run %vector heterogeneous-query)
::
::  A same-schema UNION has one columns entry and only index zero.
++  test-same-schema-union-04
  =|  run=@ud
  =/  relation  (raw-relation (poke-script run %raw same-schema-query))
  ;:  weld
    %+  expect-eq
      !>(1)
    !>((lent columns.relation))
  ::
    %-  expect
    !>  %+  levy  data-rows.relation
        |=  row=[columns-index=@ud =data-row:ast]
        =(0 columns-index.row)
  ==
::
::  Empty results retain one schema and contain no indexed rows.
++  test-empty-result-05
  =|  run=@ud
  =/  relation  (raw-relation (poke-script run %raw empty-query))
  ;:  weld
    %+  expect-eq
      !>(1)
    !>((lent columns.relation))
  ::
    %+  expect-eq
      !>(`(list [columns-index=@ud =data-row:ast])`~)
    !>(data-rows.relation)
  ==
::
++  direct-relation
  ^-  relation:ast
  =/  ud-columns
    ^-  (lest $%(column:ast qualified-column:ast))
    ~[[%column %value ~.ud 0]]
  =/  ux-columns
    ^-  (lest $%(column:ast qualified-column:ast))
    ~[[%column %value ~.ux 0]]
  =/  ud-row-1=data-row:ast
    [%indexed-row ~[1] (~(gas by *(map @tas @)) ~[[%value 1]])]
  =/  ux-row=data-row:ast
    [%indexed-row ~[2] (~(gas by *(map @tas @)) ~[[%value 0x2]])]
  =/  ud-row-3=data-row:ast
    [%indexed-row ~[3] (~(gas by *(map @tas @)) ~[[%value 3]])]
  :*  %relation
      ~
      ~[ud-columns ux-columns]
      ~
      %.n
      *(tree [(list @) (map @tas @)])
      ~[[0 ud-row-1] [1 ux-row] [0 ud-row-3]]
      ==
::
++  vector-aura
  |=  vector=vector:ast
  ^-  @ta
  p.q.i.+.vector
::
::  Non-contiguous schemas are grouped by first encounter.
++  test-repeated-schema-06
  =/  vectors  (relation-vectors direct-relation)
  %+  expect-eq
    !>(`(list @ta)`~[~.ud ~.ud ~.ux])
  !>((turn vectors vector-aura))
::
::  An invalid row format index fails at the formatter boundary.
++  test-fail-invalid-format-index-07
  =/  relation  direct-relation
  =/  rows  data-rows.relation
  ?~  rows  ~|("formatted test: direct relation has no rows" !!)
  =/  bad  relation(data-rows ~[[2 data-row.i.rows]])
  %+  expect-fail-message
    'format: invalid relation columns index 2'
  |.  (relation-vectors bad)
::
::  Ordered formatting with multiple schemas is not implemented.
++  test-fail-ordered-multi-schema-08
  =/  relation  direct-relation
  =/  ordered-relation  relation(ordered %.y)
  %+  expect-fail-message
    'format: ordered multi-schema vector output not implemented'
  |.  (relation-vectors ordered-relation)
--
