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
++  result-message
  |=  results=(list cmd-result:ast)
  ^-  @t
  ?~  results  ~|("formatted test: no command results" !!)
  =/  result=cmd-result:ast  (rear results)
  =/  items=(list result:ast)  +.result
  |-
  ?~  items  ~|("formatted test: no message" !!)
  ?:  ?=(%message -.i.items)
    +.i.items
  $(items t.items)
::
++  format-relation
  |=  [format=result-format:ast relation=relation:ast]
  ^-  (list cmd-result:ast)
  =/  input=(list cmd-result:ast)
    ~[[%results ~[[%relations ~[relation]] [%vector-count 99]]]]
  (format-results format input)
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
++  vectors-relation
  |=  $:  columns=(lest $%(column:ast qualified-column:ast))
          vectors=(list vector:ast)
          ==
  ^-  relation:ast
  =/  rows=(list [columns-index=@ud =data-row:ast])
    %+  turn  vectors
    |=  vector=vector:ast
    =/  data
      %-  ~(gas by *(map @tas @))
      %+  turn  +.vector
      |=  cell=vector-cell:ast
      [p.cell +.q.cell]
    =/  row=data-row:ast  [%indexed-row ~ data]
    [0 row]
  :*  %relation
      ~
      ~[columns]
      ~
      %.n
      *(tree [(list @) (map @tas @)])
      rows
      ==
::
++  vector-aura
  |=  vector=vector:ast
  ^-  @ta
  p.q.i.+.vector
::
::  HTML renders one table for each columns entry.
++  test-html-multiple-schemas-06
  =/  relation  direct-relation
  =/  rows  data-rows.relation
  ?~  rows  ~|("formatted test: direct relation has no rows" !!)
  ?~  t.rows  ~|("formatted test: direct relation has only one row" !!)
  =/  html-relation  relation(data-rows ~[i.rows i.t.rows])
  =/  input=(list cmd-result:ast)
    ~[[%results ~[[%relations ~[html-relation]] [%vector-count 99]]]]
  =/  expected
    %-  crip
    %-  zing
    :~  "<table><tr><th>value</th></tr>"
        "<tr><td>1</td></tr></table>"
        "<table><tr><th>value</th></tr>"
        "<tr><td>0x2</td></tr></table>"
        ==
  =/  expected-items=(list result:ast)
    :~  [%message expected]
        [%vector-count 2]
        ==
  =/  expected-output=(list cmd-result:ast)
    ~[[%results expected-items]]
  %+  expect-eq
    !>(expected-output)
  !>((format-results %html input))
::
::  HTML emits a header-only table for every empty columns entry.
++  test-html-empty-multiple-schemas-07
  =/  relation  direct-relation
  =/  empty  relation(data-rows ~)
  =/  expected
    %-  crip
    %-  zing
    :~  "<table><tr><th>value</th></tr></table>"
        "<table><tr><th>value</th></tr></table>"
        ==
  =/  expected-output=(list cmd-result:ast)
    ~[[%results ~[[%message expected] [%vector-count 0]]]]
  %+  expect-eq
    !>(expected-output)
  !>((format-relation %html empty))
::
::  HTML escapes text cell content.
++  test-html-escape-08
  =/  columns
    ^-  (lest $%(column:ast qualified-column:ast))
    ~[[%column %value ~.t 0]]
  =/  vectors=(list vector:ast)
    ~[[%vector ~[[%value [~.t 'a&<b>']]]]]
  =/  relation  (vectors-relation columns vectors)
  =/  expected
    '<table><tr><th>value</th></tr><tr><td>a&amp;&lt;b&gt;</td></tr></table>'
  %+  expect-eq
    !>(expected)
  !>((result-message (format-relation %html relation)))
::
::  Non-contiguous schemas are grouped by first encounter.
++  test-repeated-schema-09
  =/  formatted  (format-relation %vector direct-relation)
  =/  vectors  (result-vectors formatted)
  %+  expect-eq
    !>(`(list @ta)`~[~.ud ~.ud ~.ux])
  !>((turn vectors vector-aura))
::
::  An invalid row format index fails at the formatter boundary.
++  test-fail-invalid-format-index-10
  =/  relation  direct-relation
  =/  rows  data-rows.relation
  ?~  rows  ~|("formatted test: direct relation has no rows" !!)
  =/  bad  relation(data-rows ~[[2 data-row.i.rows]])
  %+  expect-fail-message
    'format: invalid relation columns index 2'
  |.  (format-relation %vector bad)
::
::  Ordered vector formatting with multiple schemas is not implemented.
++  test-fail-ordered-multi-schema-vector-11
  =/  relation  direct-relation
  =/  ordered-relation  relation(ordered %.y)
  %+  expect-fail-message
    'format: ordered multi-schema vector output not implemented'
  |.  (format-relation %vector ordered-relation)
::
::  Ordered HTML formatting with multiple schemas is not implemented.
++  test-fail-ordered-multi-schema-html-12
  =/  relation  direct-relation
  =/  ordered-relation  relation(ordered %.y)
  %+  expect-fail-message
    'format: ordered multi-schema html output not implemented'
  |.  (format-relation %html ordered-relation)
::
::  HTML renders multiple columns and data rows in one table.
++  test-html-multiple-columns-rows-13
  =/  columns
    ^-  (lest $%(column:ast qualified-column:ast))
    :~  [%column %id ~.ud 0]
        [%column %label ~.t 0]
        ==
  =/  vectors=(list vector:ast)
    :~  :-  %vector
            :~  [%id [~.ud 1]]
                [%label [~.t 'alpha']]
                ==
        :-  %vector
            :~  [%id [~.ud 2]]
                [%label [~.t 'beta']]
                ==
        ==
  =/  expected
    %-  crip
    %-  zing
    :~  "<table><tr><th>id</th><th>label</th></tr>"
        "<tr><td>1</td><td>alpha</td></tr>"
        "<tr><td>2</td><td>beta</td></tr></table>"
        ==
  %+  expect-eq
    !>(expected)
  !>  %-  result-message
      (format-relation %html (vectors-relation columns vectors))
::
::  HTML cells preserve date, duration, signed, and floating auras.
++  test-html-aura-values-14
  =/  columns
    ^-  (lest $%(column:ast qualified-column:ast))
    :~  [%column %date ~.da 0]
        [%column %duration ~.dr 0]
        [%column %signed ~.sd 0]
        [%column %single ~.rs 0]
        [%column %double ~.rd 0]
        ==
  =/  vectors=(list vector:ast)
    :~  :-  %vector
            :~  [%date [~.da ~2024.1.2..3.4.5]]
                [%duration [~.dr ~s5]]
                [%signed [~.sd --42]]
                [%single [~.rs .1.5]]
                [%double [~.rd .~1.5]]
                ==
        ==
  =/  expected
    %-  crip
    %-  zing
    :~  "<table><tr><th>date</th><th>duration</th><th>signed</th>"
        "<th>single</th><th>double</th></tr>"
        "<tr><td>~2024.01.02..03.04.05</td><td>~s5</td><td>--42</td>"
        "<td>.1.5</td><td>.~1.5</td></tr></table>"
        ==
  %+  expect-eq
    !>(expected)
  !>  %-  result-message
      (format-relation %html (vectors-relation columns vectors))
::
::  Markdown renders one GitHub Flavored Markdown table per columns entry.
++  test-markdown-multiple-schemas-15
  =/  relation  direct-relation
  =/  rows  data-rows.relation
  ?~  rows  ~|("formatted test: direct relation has no rows" !!)
  ?~  t.rows  ~|("formatted test: direct relation has only one row" !!)
  =/  markdown-relation  relation(data-rows ~[i.rows i.t.rows])
  =/  input=(list cmd-result:ast)
    ~[[%results ~[[%relations ~[markdown-relation]] [%vector-count 99]]]]
  =/  expected
    %-  crip
    %-  zing
    :~  "| value |"
        ~['\0a']
        "| --- |"
        ~['\0a']
        "| 1 |"
        ~['\0a' '\0a']
        "| value |"
        ~['\0a']
        "| --- |"
        ~['\0a']
        "| 0x2 |"
        ==
  =/  expected-items=(list result:ast)
    :~  [%message expected]
        [%vector-count 2]
        ==
  =/  expected-output=(list cmd-result:ast)
    ~[[%results expected-items]]
  %+  expect-eq
    !>(expected-output)
  !>((format-results %markdown input))
::
::  Markdown emits a header and delimiter for every empty columns entry.
++  test-markdown-empty-multiple-schemas-16
  =/  relation  direct-relation
  =/  empty  relation(data-rows ~)
  =/  expected
    %-  crip
    %-  zing
    :~  "| value |"
        ~['\0a']
        "| --- |"
        ~['\0a' '\0a']
        "| value |"
        ~['\0a']
        "| --- |"
        ==
  =/  expected-output=(list cmd-result:ast)
    ~[[%results ~[[%message expected] [%vector-count 0]]]]
  %+  expect-eq
    !>(expected-output)
  !>((format-relation %markdown empty))
::
::  Markdown escapes GFM table delimiters in text cells.
++  test-markdown-escape-17
  =/  columns
    ^-  (lest $%(column:ast qualified-column:ast))
    ~[[%column %value ~.t 0]]
  =/  vectors=(list vector:ast)
    ~[[%vector ~[[%value [~.t 'a|b']]]]]
  =/  relation  (vectors-relation columns vectors)
  %+  expect-eq
    !>('| value |\0a| --- |\0a| a\\|b |')
  !>((result-message (format-relation %markdown relation)))
::
::  Ordered Markdown formatting with multiple schemas is not implemented.
++  test-fail-ordered-multi-schema-markdown-18
  =/  relation  direct-relation
  =/  ordered-relation  relation(ordered %.y)
  %+  expect-fail-message
    'format: ordered multi-schema markdown output not implemented'
  |.  (format-relation %markdown ordered-relation)
::
::  Markdown renders multiple columns and data rows in one GFM table.
++  test-markdown-multiple-columns-rows-19
  =/  columns
    ^-  (lest $%(column:ast qualified-column:ast))
    :~  [%column %id ~.ud 0]
        [%column %label ~.t 0]
        ==
  =/  vectors=(list vector:ast)
    :~  :-  %vector
            :~  [%id [~.ud 1]]
                [%label [~.t 'alpha']]
                ==
        :-  %vector
            :~  [%id [~.ud 2]]
                [%label [~.t 'beta']]
                ==
        ==
  =/  expected
    %-  crip
    %-  zing
    :~  "| id | label |"
        ~['\0a']
        "| --- | --- |"
        ~['\0a']
        "| 1 | alpha |"
        ~['\0a']
        "| 2 | beta |"
        ==
  %+  expect-eq
    !>(expected)
  !>  %-  result-message
      (format-relation %markdown (vectors-relation columns vectors))
::
::  Markdown cells preserve date, duration, signed, and floating auras.
++  test-markdown-aura-values-20
  =/  columns
    ^-  (lest $%(column:ast qualified-column:ast))
    :~  [%column %date ~.da 0]
        [%column %duration ~.dr 0]
        [%column %signed ~.sd 0]
        [%column %single ~.rs 0]
        [%column %double ~.rd 0]
        ==
  =/  vectors=(list vector:ast)
    :~  :-  %vector
            :~  [%date [~.da ~2024.1.2..3.4.5]]
                [%duration [~.dr ~s5]]
                [%signed [~.sd --42]]
                [%single [~.rs .1.5]]
                [%double [~.rd .~1.5]]
                ==
        ==
  =/  expected
    %-  crip
    %-  zing
    :~  "| date | duration | signed | single | double |"
        ~['\0a']
        "| --- | --- | --- | --- | --- |"
        ~['\0a']
        "| ~2024.01.02..03.04.05 | ~s5 | --42 | .1.5 | .~1.5 |"
        ==
  %+  expect-eq
    !>(expected)
  !>  %-  result-message
      (format-relation %markdown (vectors-relation columns vectors))
::
::  JSON renders one row array for each columns entry.
++  test-json-multiple-schemas-21
  =/  relation  direct-relation
  =/  rows  data-rows.relation
  ?~  rows  ~|("formatted test: direct relation has no rows" !!)
  ?~  t.rows  ~|("formatted test: direct relation has only one row" !!)
  =/  json-relation  relation(data-rows ~[i.rows i.t.rows])
  =/  input=(list cmd-result:ast)
    ~[[%results ~[[%relations ~[json-relation]] [%vector-count 99]]]]
  =/  expected-items=(list result:ast)
    :~  [%message '[[{"value":1}],[{"value":"0x2"}]]']
        [%vector-count 2]
        ==
  =/  expected-output=(list cmd-result:ast)
    ~[[%results expected-items]]
  %+  expect-eq
    !>(expected-output)
  !>((format-results %json input))
::
::  JSON emits one empty row array for every empty columns entry.
++  test-json-empty-multiple-schemas-22
  =/  relation  direct-relation
  =/  empty  relation(data-rows ~)
  =/  expected-output=(list cmd-result:ast)
    ~[[%results ~[[%message '[[],[]]'] [%vector-count 0]]]]
  %+  expect-eq
    !>(expected-output)
  !>((format-relation %json empty))
::
::  JSON strings escape quotes and backslashes.
++  test-json-escape-23
  =/  columns
    ^-  (lest $%(column:ast qualified-column:ast))
    ~[[%column %value ~.t 0]]
  =/  vectors=(list vector:ast)
    ~[[%vector ~[[%value [~.t 'a"b\\c']]]]]
  =/  relation  (vectors-relation columns vectors)
  %+  expect-eq
    !>('[[{"value":"a\\"b\\\\c"}]]')
  !>((result-message (format-relation %json relation)))
::
::  Ordered JSON formatting with multiple schemas is not implemented.
++  test-fail-ordered-multi-schema-json-24
  =/  relation  direct-relation
  =/  ordered-relation  relation(ordered %.y)
  %+  expect-fail-message
    'format: ordered multi-schema json output not implemented'
  |.  (format-relation %json ordered-relation)
::
::  JSON renders multiple columns and data rows as row objects.
++  test-json-multiple-columns-rows-25
  =/  columns
    ^-  (lest $%(column:ast qualified-column:ast))
    :~  [%column %id ~.ud 0]
        [%column %label ~.t 0]
        ==
  =/  vectors=(list vector:ast)
    :~  :-  %vector
            :~  [%id [~.ud 1]]
                [%label [~.t 'alpha']]
                ==
        :-  %vector
            :~  [%id [~.ud 2]]
                [%label [~.t 'beta']]
                ==
        ==
  %+  expect-eq
    !>('[[{"id":1,"label":"alpha"},{"id":2,"label":"beta"}]]')
  !>  %-  result-message
      (format-relation %json (vectors-relation columns vectors))
::
::  JSON preserves non-decimal Hoon auras as strings.
++  test-json-aura-values-26
  =/  columns
    ^-  (lest $%(column:ast qualified-column:ast))
    :~  [%column %date ~.da 0]
        [%column %duration ~.dr 0]
        [%column %signed ~.sd 0]
        [%column %single ~.rs 0]
        [%column %double ~.rd 0]
        ==
  =/  vector=vector:ast
    :-  %vector
    :~  [%date [~.da ~2024.1.2..3.4.5]]
        [%duration [~.dr ~s5]]
        [%signed [~.sd --42]]
        [%single [~.rs .1.5]]
        [%double [~.rd .~1.5]]
        ==
  =/  expected
    %-  crip
    ;:  welp
      ~['[' '[' '{']
      "\"date\":\"~2024.01.02..03.04.05\",\"duration\":\"~s5\","
      "\"signed\":\"--42\",\"single\":\".1.5\",\"double\":\".~1.5\""
      ~['}' ']' ']']
    ==
  =/  relation  (vectors-relation columns ~[vector])
  %+  expect-eq
    !>(expected)
  !>((result-message (format-relation %json relation)))
::
::  Wain renders one header and its rows for each columns entry.
++  test-wain-multiple-schemas-27
  =/  relation  direct-relation
  =/  rows  data-rows.relation
  ?~  rows  ~|("formatted test: direct relation has no rows" !!)
  ?~  t.rows  ~|("formatted test: direct relation has only one row" !!)
  =/  wain-relation  relation(data-rows ~[i.rows i.t.rows])
  =/  input=(list cmd-result:ast)
    ~[[%results ~[[%relations ~[wain-relation]] [%vector-count 99]]]]
  =/  expected-items=(list result:ast)
    :~  [%message 'value\0a1\0avalue\0a0x2']
        [%vector-count 2]
        ==
  =/  expected-output=(list cmd-result:ast)
    ~[[%results expected-items]]
  %+  expect-eq
    !>(expected-output)
  !>((format-results %wain input))
::
::  Wain emits a header for every empty columns entry.
++  test-wain-empty-multiple-schemas-28
  =/  relation  direct-relation
  =/  empty  relation(data-rows ~)
  =/  formatted  (relation-wain empty)
  ;:  weld
    %+  expect-eq  !>(`wain`~['value' 'value'])
                   !>(p.formatted)
  ::
    %+  expect-eq  !>(0)
                   !>(q.formatted)
  ==
::
::  Ordered Wain formatting with multiple schemas is not implemented.
++  test-fail-ordered-multi-schema-wain-29
  =/  relation  direct-relation
  =/  ordered-relation  relation(ordered %.y)
  %+  expect-fail-message
    'format: ordered multi-schema wain output not implemented'
  |.  (relation-wain ordered-relation)
::
::  Wain separates multiple columns with one space.
++  test-wain-multiple-columns-rows-30
  =/  columns
    ^-  (lest $%(column:ast qualified-column:ast))
    :~  [%column %id ~.ud 0]
        [%column %label ~.t 0]
        ==
  =/  vectors=(list vector:ast)
    :~  :-  %vector
            :~  [%id [~.ud 1]]
                [%label [~.t 'alpha']]
                ==
        :-  %vector
            :~  [%id [~.ud 2]]
                [%label [~.t 'beta']]
                ==
        ==
  %+  expect-eq
    !>('id label\0a1 alpha\0a2 beta')
  !>  %-  result-message
      (format-relation %wain (vectors-relation columns vectors))
::
::  Wain preserves date, duration, signed, and floating auras.
++  test-wain-aura-values-31
  =/  columns
    ^-  (lest $%(column:ast qualified-column:ast))
    :~  [%column %date ~.da 0]
        [%column %duration ~.dr 0]
        [%column %signed ~.sd 0]
        [%column %single ~.rs 0]
        [%column %double ~.rd 0]
        ==
  =/  vectors=(list vector:ast)
    :~  :-  %vector
            :~  [%date [~.da ~2024.1.2..3.4.5]]
                [%duration [~.dr ~s5]]
                [%signed [~.sd --42]]
                [%single [~.rs .1.5]]
                [%double [~.rd .~1.5]]
                ==
        ==
  =/  expected
    %-  crip
    %-  zing
    :~  "date duration signed single double"
        ~['\0a']
        "~2024.01.02..03.04.05 ~s5 --42 .1.5 .~1.5"
        ==
  %+  expect-eq
    !>(expected)
  !>  %-  result-message
      (format-relation %wain (vectors-relation columns vectors))
::
::  Tape renders one header and its rows for each columns entry.
++  test-tape-multiple-schemas-32
  =/  relation  direct-relation
  =/  rows  data-rows.relation
  ?~  rows  ~|("formatted test: direct relation has no rows" !!)
  ?~  t.rows  ~|("formatted test: direct relation has only one row" !!)
  =/  tape-relation  relation(data-rows ~[i.rows i.t.rows])
  =/  input=(list cmd-result:ast)
    ~[[%results ~[[%relations ~[tape-relation]] [%vector-count 99]]]]
  =/  expected-items=(list result:ast)
    :~  [%message 'value\0a1\0avalue\0a0x2']
        [%vector-count 2]
        ==
  =/  expected-output=(list cmd-result:ast)
    ~[[%results expected-items]]
  %+  expect-eq
    !>(expected-output)
  !>((format-results %tape input))
::
::  Tape emits LF-delimited headers for empty columns entries.
++  test-tape-empty-multiple-schemas-33
  =/  relation  direct-relation
  =/  empty  relation(data-rows ~)
  =/  expected-output=(list cmd-result:ast)
    ~[[%results ~[[%message 'value\0avalue'] [%vector-count 0]]]]
  %+  expect-eq
    !>(expected-output)
  !>((format-relation %tape empty))
::
::  Ordered Tape formatting with multiple schemas is not implemented.
++  test-fail-ordered-multi-schema-tape-34
  =/  relation  direct-relation
  =/  ordered-relation  relation(ordered %.y)
  %+  expect-fail-message
    'format: ordered multi-schema tape output not implemented'
  |.  (format-relation %tape ordered-relation)
::
::  Tape separates columns with spaces and rows with line feeds.
++  test-tape-multiple-columns-rows-35
  =/  columns
    ^-  (lest $%(column:ast qualified-column:ast))
    :~  [%column %id ~.ud 0]
        [%column %label ~.t 0]
        ==
  =/  vectors=(list vector:ast)
    :~  :-  %vector
            :~  [%id [~.ud 1]]
                [%label [~.t 'alpha']]
                ==
        :-  %vector
            :~  [%id [~.ud 2]]
                [%label [~.t 'beta']]
                ==
        ==
  %+  expect-eq
    !>('id label\0a1 alpha\0a2 beta')
  !>  %-  result-message
      (format-relation %tape (vectors-relation columns vectors))
::
::  Tape preserves date, duration, signed, and floating auras.
++  test-tape-aura-values-36
  =/  columns
    ^-  (lest $%(column:ast qualified-column:ast))
    :~  [%column %date ~.da 0]
        [%column %duration ~.dr 0]
        [%column %signed ~.sd 0]
        [%column %single ~.rs 0]
        [%column %double ~.rd 0]
        ==
  =/  vectors=(list vector:ast)
    :~  :-  %vector
            :~  [%date [~.da ~2024.1.2..3.4.5]]
                [%duration [~.dr ~s5]]
                [%signed [~.sd --42]]
                [%single [~.rs .1.5]]
                [%double [~.rd .~1.5]]
                ==
        ==
  =/  expected=tape
    ;:  welp
      "date duration signed single double"
      "\0a"
      "~2024.01.02..03.04.05 ~s5 --42 .1.5 .~1.5"
    ==
  %+  expect-eq
    !>((crip expected))
  !>  %-  result-message
      (format-relation %tape (vectors-relation columns vectors))
::
::  Manx renders one table node for each columns entry.
++  test-manx-multiple-schemas-37
  =/  relation  direct-relation
  =/  rows  data-rows.relation
  ?~  rows  ~|("formatted test: direct relation has no rows" !!)
  ?~  t.rows  ~|("formatted test: direct relation has only one row" !!)
  =/  manx-relation  relation(data-rows ~[i.rows i.t.rows])
  =/  input=(list cmd-result:ast)
    ~[[%results ~[[%relations ~[manx-relation]] [%vector-count 99]]]]
  =/  expected
    %-  crip
    %-  zing
    :~  "<table><tr><th>value</th></tr>"
        "<tr><td>1</td></tr></table>"
        "<table><tr><th>value</th></tr>"
        "<tr><td>0x2</td></tr></table>"
        ==
  =/  expected-items=(list result:ast)
    :~  [%message expected]
        [%vector-count 2]
        ==
  =/  expected-output=(list cmd-result:ast)
    ~[[%results expected-items]]
  %+  expect-eq
    !>(expected-output)
  !>((format-results %manx input))
::
::  Manx emits a header-only table for every empty columns entry.
++  test-manx-empty-multiple-schemas-38
  =/  relation  direct-relation
  =/  empty  relation(data-rows ~)
  =/  expected
    %-  crip
    %-  zing
    :~  "<table><tr><th>value</th></tr></table>"
        "<table><tr><th>value</th></tr></table>"
        ==
  =/  expected-output=(list cmd-result:ast)
    ~[[%results ~[[%message expected] [%vector-count 0]]]]
  %+  expect-eq
    !>(expected-output)
  !>((format-relation %manx empty))
::
::  Manx serialization escapes text content.
++  test-manx-escape-39
  =/  columns
    ^-  (lest $%(column:ast qualified-column:ast))
    ~[[%column %value ~.t 0]]
  =/  vectors=(list vector:ast)
    ~[[%vector ~[[%value [~.t 'a&<b>']]]]]
  =/  expected
    '<table><tr><th>value</th></tr><tr><td>a&amp;&lt;b&gt;</td></tr></table>'
  %+  expect-eq
    !>(expected)
  !>  %-  result-message
      (format-relation %manx (vectors-relation columns vectors))
::
::  Ordered Manx formatting with multiple schemas is not implemented.
++  test-fail-ordered-multi-schema-manx-40
  =/  relation  direct-relation
  =/  ordered-relation  relation(ordered %.y)
  %+  expect-fail-message
    'format: ordered multi-schema manx output not implemented'
  |.  (format-relation %manx ordered-relation)
::
::  Manx renders multiple columns and data rows in one table node.
++  test-manx-multiple-columns-rows-41
  =/  columns
    ^-  (lest $%(column:ast qualified-column:ast))
    :~  [%column %id ~.ud 0]
        [%column %label ~.t 0]
        ==
  =/  vectors=(list vector:ast)
    :~  :-  %vector
            :~  [%id [~.ud 1]]
                [%label [~.t 'alpha']]
                ==
        :-  %vector
            :~  [%id [~.ud 2]]
                [%label [~.t 'beta']]
                ==
        ==
  =/  expected
    %-  crip
    %-  zing
    :~  "<table><tr><th>id</th><th>label</th></tr>"
        "<tr><td>1</td><td>alpha</td></tr>"
        "<tr><td>2</td><td>beta</td></tr></table>"
        ==
  %+  expect-eq
    !>(expected)
  !>  %-  result-message
      (format-relation %manx (vectors-relation columns vectors))
::
::  Manx preserves date, duration, signed, and floating auras.
++  test-manx-aura-values-42
  =/  columns
    ^-  (lest $%(column:ast qualified-column:ast))
    :~  [%column %date ~.da 0]
        [%column %duration ~.dr 0]
        [%column %signed ~.sd 0]
        [%column %single ~.rs 0]
        [%column %double ~.rd 0]
        ==
  =/  vectors=(list vector:ast)
    :~  :-  %vector
            :~  [%date [~.da ~2024.1.2..3.4.5]]
                [%duration [~.dr ~s5]]
                [%signed [~.sd --42]]
                [%single [~.rs .1.5]]
                [%double [~.rd .~1.5]]
                ==
        ==
  =/  expected
    %-  crip
    %-  zing
    :~  "<table><tr><th>date</th><th>duration</th><th>signed</th>"
        "<th>single</th><th>double</th></tr>"
        "<tr><td>~2024.01.02..03.04.05</td><td>~s5</td>"
        "<td>--42</td><td>.1.5</td><td>.~1.5</td></tr></table>"
        ==
  %+  expect-eq
    !>(expected)
  !>  %-  result-message
      (format-relation %manx (vectors-relation columns vectors))
::
::  Delimited formats use their designated separators and CSV quoting.
++  test-delimited-formats-43
  =/  columns
    ^-  (lest $%(column:ast qualified-column:ast))
    :~  [%column %id ~.ud 0]
        [%column %label ~.t 0]
        ==
  =/  vectors=(list vector:ast)
    :~  :-  %vector
            :~  [%id [~.ud 1]]
                [%label [~.t 'alpha,beta']]
                ==
        :-  %vector
            :~  [%id [~.ud 2]]
                [%label [~.t 'say "hi"']]
                ==
        ==
  =/  relation  (vectors-relation columns vectors)
  ;:  weld
    %+  expect-eq
      !>('id,label\0a1,"alpha,beta"\0a2,"say ""hi"""')
    !>((result-message (format-relation %csv relation)))
  ::
    %+  expect-eq
      !>('id\09label\0a1\09alpha,beta\0a2\09say "hi"')
    !>((result-message (format-relation %tab relation)))
  ::
    %+  expect-eq
      !>('id label\0a1 alpha,beta\0a2 say "hi"')
    !>((result-message (format-relation %spac relation)))
  ==
::
::  Ordered CSV formatting with multiple schemas is not implemented.
++  test-fail-ordered-multi-schema-csv-44
  =/  relation  direct-relation
  =/  ordered-relation  relation(ordered %.y)
  %+  expect-fail-message
    'format: ordered multi-schema csv output not implemented'
  |.  (format-relation %csv ordered-relation)
::
::  CSV quotes values containing carriage returns and line feeds.
++  test-csv-record-boundaries-45
  =/  columns
    ^-  (lest $%(column:ast qualified-column:ast))
    ~[[%column %value ~.t 0]]
  =/  vectors=(list vector:ast)
    ~[[%vector ~[[%value [~.t 'line\0abreak\0dend']]]]]
  =/  relation  (vectors-relation columns vectors)
  %+  expect-eq
    !>('value\0a"line\0abreak\0dend"')
  !>((result-message (format-relation %csv relation)))
--
