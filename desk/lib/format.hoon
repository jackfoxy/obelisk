/-  *obelisk-ast
|%
::
++  format-results
  |=  [fmt=result-format results=(list cmd-result)]
  ^-  (list cmd-result)
  ?-  fmt
    %raw
      results
    %vector
      (turn results format-vectors)
    %markdown
      (turn results format-markdown)
    %html
      (turn results format-html)
    %manx
      ~|('not implemented' !!)
    %wain
      (turn results format-wain)
    %tape
      (turn results format-tape)
    %json
      (turn results format-json)
  ==
::
::  Format relation results as JSON arrays of row objects.
++  format-json
  |=  a=cmd-result
  ^-  cmd-result
  :-  %results
  =/  results=(list result)  +.a
  =/  out=(list result)      ~
  =/  count=(unit @ud)       ~
  |-
  ?~  results  (flop out)
  =/  formatted=[result (unit @ud)]
    ?-  -.i.results
      %relations
        =/  json-result  (relations-json +.i.results)
        :-  [%message (crip p.json-result)]
            [~ q.json-result]
      %vector-count
        ?~  count  [i.results count]
        [[%vector-count u.count] count]
      %result-set  [i.results count]
      %action  [i.results count]
      %relation-name  [i.results count]
      %message  [i.results count]
      %server-time  [i.results count]
      %security-time  [i.results count]
      %schema-time  [i.results count]
      %data-time  [i.results count]
      %select-relation  [i.results count]
    ==
  %=  $
    results  t.results
    out      [-.formatted out]
    count    +.formatted
  ==
::
::  Format relation results as space-delimited cord lines.
++  format-wain
  |=  a=cmd-result
  ^-  cmd-result
  :-  %results
  =/  results=(list result)  +.a
  =/  out=(list result)      ~
  =/  count=(unit @ud)       ~
  |-
  ?~  results  (flop out)
  =/  formatted=[result (unit @ud)]
    ?-  -.i.results
      %relations
        =/  wain-result  (relations-wain +.i.results)
        :-  [%message (crip (wain-to-tape p.wain-result))]
            [~ q.wain-result]
      %vector-count
        ?~  count  [i.results count]
        [[%vector-count u.count] count]
      %result-set  [i.results count]
      %action  [i.results count]
      %relation-name  [i.results count]
      %message  [i.results count]
      %server-time  [i.results count]
      %security-time  [i.results count]
      %schema-time  [i.results count]
      %data-time  [i.results count]
      %select-relation  [i.results count]
    ==
  %=  $
    results  t.results
    out      [-.formatted out]
    count    +.formatted
  ==
::
::  Format relation results as LF-delimited tape rows.
++  format-tape
  |=  a=cmd-result
  ^-  cmd-result
  :-  %results
  =/  results=(list result)  +.a
  =/  out=(list result)      ~
  =/  count=(unit @ud)       ~
  |-
  ?~  results  (flop out)
  =/  formatted=[result (unit @ud)]
    ?-  -.i.results
      %relations
        =/  tape-result  (relations-tape +.i.results)
        :-  [%message (crip p.tape-result)]
            [~ q.tape-result]
      %vector-count
        ?~  count  [i.results count]
        [[%vector-count u.count] count]
      %result-set  [i.results count]
      %action  [i.results count]
      %relation-name  [i.results count]
      %message  [i.results count]
      %server-time  [i.results count]
      %security-time  [i.results count]
      %schema-time  [i.results count]
      %data-time  [i.results count]
      %select-relation  [i.results count]
    ==
  %=  $
    results  t.results
    out      [-.formatted out]
    count    +.formatted
  ==
::
::  Format relation results as GitHub Flavored Markdown tables.
++  format-markdown
  |=  a=cmd-result
  ^-  cmd-result
  :-  %results
  =/  results=(list result)  +.a
  =/  out=(list result)      ~
  =/  count=(unit @ud)       ~
  |-
  ?~  results  (flop out)
  =/  formatted=[result (unit @ud)]
    ?-  -.i.results
      %relations
        =/  markdown  (relations-markdown +.i.results)
        :-  [%message (crip p.markdown)]
            [~ q.markdown]
      %vector-count
        ?~  count  [i.results count]
        [[%vector-count u.count] count]
      %result-set  [i.results count]
      %action  [i.results count]
      %relation-name  [i.results count]
      %message  [i.results count]
      %server-time  [i.results count]
      %security-time  [i.results count]
      %schema-time  [i.results count]
      %data-time  [i.results count]
      %select-relation  [i.results count]
    ==
  %=  $
    results  t.results
    out      [-.formatted out]
    count    +.formatted
  ==
::
++  format-html
  |=  a=cmd-result
  ^-  cmd-result
  :-  %results
  =/  results=(list result)  +.a
  =/  out=(list result)      ~
  =/  count=(unit @ud)       ~
  |-
  ?~  results  (flop out)
  =/  formatted=[result (unit @ud)]
    ?-  -.i.results
      %relations
        =/  html  (relations-html +.i.results)
        :-  [%message (crip p.html)]
            [~ q.html]
      %vector-count
        ?~  count  [i.results count]
        [[%vector-count u.count] count]
      %result-set  [i.results count]
      %action  [i.results count]
      %relation-name  [i.results count]
      %message  [i.results count]
      %server-time  [i.results count]
      %security-time  [i.results count]
      %schema-time  [i.results count]
      %data-time  [i.results count]
      %select-relation  [i.results count]
    ==
  %=  $
    results  t.results
    out      [-.formatted out]
    count    +.formatted
  ==
::
++  format-vectors
  |=  a=cmd-result
  ^-  cmd-result
  :-  %results
  =/  results=(list result)  +.a
  =/  out=(list result)      ~
  =/  count=(unit @ud)       ~
  |-
  ?~  results  (flop out)
  =/  formatted=[result (unit @ud)]
    ?-  -.i.results
      %relations
        =/  vectors  (zing (turn +.i.results relation-vectors))
        :-  [%result-set vectors]
            [~ (lent vectors)]
      %vector-count
        ?~  count  [i.results count]
        [[%vector-count u.count] count]
      %result-set
        [i.results [~ (lent +.i.results)]]
      %action  [i.results count]
      %relation-name  [i.results count]
      %message  [i.results count]
      %server-time  [i.results count]
      %security-time  [i.results count]
      %schema-time  [i.results count]
      %data-time  [i.results count]
      %select-relation  [i.results count]
    ==
  %=  $
    results  t.results
    out      [-.formatted out]
    count    +.formatted
  ==
::
++  relations-tape
  |=  relations=(list relation)
  ^-  [p=tape q=@ud]
  =/  out  *tape
  =/  count  0
  |-
  ?~  relations  [out count]
  =/  formatted  (relation-tape i.relations)
  =/  separator=tape  ?:(=(~ out) ~ ~['\0a'])
  %=  $
    relations  t.relations
    out        (weld out (weld separator p.formatted))
    count      (add count q.formatted)
  ==
::
++  relation-tape
  |=  a=relation
  ^-  [p=tape q=@ud]
  =/  columns=(lest (lest $%(column qualified-column)))  columns.a
  ?:  &(ordered.a (gth (lent columns) 1))
    ~|("format: ordered multi-schema tape output not implemented" !!)
  =/  formatted  (relation-wain a)
  [(wain-to-tape p.formatted) q.formatted]
::
++  relations-wain
  |=  relations=(list relation)
  ^-  [p=wain q=@ud]
  =/  lines  *wain
  =/  count  0
  |-
  ?~  relations  [lines count]
  =/  formatted  (relation-wain i.relations)
  %=  $
    relations  t.relations
    lines      (weld lines p.formatted)
    count      (add count q.formatted)
  ==
::
++  relation-wain
  |=  a=relation
  ^-  [p=wain q=@ud]
  =/  columns=(lest (lest $%(column qualified-column)))  columns.a
  ?:  &(ordered.a (gth (lent columns) 1))
    ~|("format: ordered multi-schema wain output not implemented" !!)
  %:  relation-wain-tables
    =(~ relation-id.a)
    ordered.a
    0
    columns
    data-rows.a
  ==
::
++  relation-wain-tables
  |=  $:  use-keys=?
          ordered=?
          columns-index=@ud
          columns=(list (lest $%(column qualified-column)))
          rows=(list [columns-index=@ud =data-row])
          ==
  ^-  [p=wain q=@ud]
  ?~  columns  [~ 0]
  =/  vectors
    %:  relation-table-vectors
      use-keys
      ordered
      columns-index
      i.columns
      rows
    ==
  =/  rest
    %=  $
      columns-index  +(columns-index)
      columns        t.columns
    ==
  :-  (weld (wain-table i.columns vectors) p.rest)
      (add (lent vectors) q.rest)
::
++  wain-table
  |=  $:  columns=(lest $%(column qualified-column))
          vectors=(list vector)
          ==
  ^-  wain
  [(wain-heading columns) (turn vectors wain-row)]
::
++  wain-heading
  |=  columns=(list $%(column qualified-column))
  ^-  cord
  %-  crip
  %-  zing
  %+  join  " "
  %+  turn  columns
  |=  column=$%(column qualified-column)
  (trip (relation-column-name column))
::
++  wain-row
  |=  vector=vector
  ^-  cord
  %-  crip
  %-  zing
  %+  join  " "
  %+  turn  +.vector
  |=  cell=vector-cell
  (render-dime q.cell)
::
++  wain-to-tape
  |=  lines=wain
  ^-  tape
  %-  zing
  (join "\0a" (turn lines trip))
::
++  relations-json
  |=  relations=(list relation)
  ^-  [p=tape q=@ud]
  =/  tables  *(list tape)
  =/  count  0
  |-
  ?~  relations  [(json-array tables) count]
  =/  formatted  (relation-json i.relations)
  %=  $
    relations  t.relations
    tables     (weld tables p.formatted)
    count      (add count q.formatted)
  ==
::
++  relation-json
  |=  a=relation
  ^-  [p=(list tape) q=@ud]
  =/  columns=(lest (lest $%(column qualified-column)))  columns.a
  ?:  &(ordered.a (gth (lent columns) 1))
    ~|("format: ordered multi-schema json output not implemented" !!)
  %:  relation-json-tables
    =(~ relation-id.a)
    ordered.a
    0
    columns
    data-rows.a
  ==
::
++  relation-json-tables
  |=  $:  use-keys=?
          ordered=?
          columns-index=@ud
          columns=(list (lest $%(column qualified-column)))
          rows=(list [columns-index=@ud =data-row])
          ==
  ^-  [p=(list tape) q=@ud]
  ?~  columns  [~ 0]
  =/  vectors
    %:  relation-table-vectors
      use-keys
      ordered
      columns-index
      i.columns
      rows
    ==
  =/  rest
    %=  $
      columns-index  +(columns-index)
      columns        t.columns
    ==
  :-  [(json-table vectors) p.rest]
      (add (lent vectors) q.rest)
::
++  json-table
  |=  vectors=(list vector)
  ^-  tape
  (json-array (turn vectors json-row))
::
++  json-row
  |=  vector=vector
  ^-  tape
  =/  cells  (turn +.vector json-cell)
  (weld ~['{'] (weld (json-comma-list cells) ~['}']))
::
++  json-array
  |=  values=(list tape)
  ^-  tape
  (weld "[" (weld (json-comma-list values) "]"))
::
++  json-comma-list
  |=  values=(list tape)
  ^-  tape
  =/  out  *tape
  |-
  ?~  values  out
  =/  separator=tape  ?:(=(~ out) ~ ",")
  %=  $
    values  t.values
    out     (weld out (weld separator i.values))
  ==
::
++  json-string
  |=  value=tape
  ^-  tape
  (weld "\"" (weld (json-escape value) "\""))
::
++  json-escape
  |=  value=tape
  ^-  tape
  %-  zing
  %+  turn  value
  |=  char=@tD
  ^-  tape
  ?:  =(char 34)   ~[`@tD`92 `@tD`34]
  ?:  =(char 92)   ~[`@tD`92 `@tD`92]
  ?:  =(char 8)    ~[`@tD`92 `@tD`98]
  ?:  =(char 12)   ~[`@tD`92 `@tD`102]
  ?:  =(char 10)   ~[`@tD`92 `@tD`110]
  ?:  =(char 13)   ~[`@tD`92 `@tD`114]
  ?:  =(char 9)    ~[`@tD`92 `@tD`116]
  ?:  (lth char 32)
    =/  hex  (slag 2 (scow %ux char))
    =/  digits  ?:(=(1 (lent hex)) ['0' hex] hex)
    (weld "\\u00" digits)
  ~[char]
::
++  json-cell
  |=  cell=vector-cell
  ^-  tape
  ;:  weld
    (json-string (trip p.cell))
    ":"
    (json-dime q.cell)
  ==
::
++  json-dime
  |=  value=dime
  ^-  tape
  ?:  =(-.value ~.ud)
    (json-unsigned `@ud`+.value)
  (json-string (render-dime value))
::
++  json-unsigned
  |=  value=@ud
  ^-  tape
  %+  skim  (scow %ud value)
  |=  char=@tD
  !=(char '.')
::
++  render-dime
  |=  value=dime
  ^-  tape
  ?:  =(-.value ~.t)
    (trip `@t`+.value)
  ~(rend co %$ value)
::
++  relations-markdown
  |=  relations=(list relation)
  ^-  [p=tape q=@ud]
  =/  out  *tape
  =/  count  0
  |-
  ?~  relations  [out count]
  =/  markdown  (relation-markdown i.relations)
  =/  separator=tape
    ?:  =(~ out)
      ~
    ?:  =(~ p.markdown)
      ~
    ~['\0a' '\0a']
  %=  $
    relations  t.relations
    out        (weld out (weld separator p.markdown))
    count      (add count q.markdown)
  ==
::
++  relation-markdown
  |=  a=relation
  ^-  [p=tape q=@ud]
  =/  columns=(lest (lest $%(column qualified-column)))  columns.a
  ?:  &(ordered.a (gth (lent columns) 1))
    ~|("format: ordered multi-schema markdown output not implemented" !!)
  %:  relation-markdown-tables
    =(~ relation-id.a)
    ordered.a
    0
    columns
    data-rows.a
  ==
::
++  relation-markdown-tables
  |=  $:  use-keys=?
          ordered=?
          columns-index=@ud
          columns=(list (lest $%(column qualified-column)))
          rows=(list [columns-index=@ud =data-row])
          ==
  ^-  [p=tape q=@ud]
  ?~  columns  [~ 0]
  =/  vectors
    %:  relation-table-vectors
      use-keys
      ordered
      columns-index
      i.columns
      rows
    ==
  =/  rest
    %=  $
      columns-index  +(columns-index)
      columns        t.columns
    ==
  =/  table  (markdown-table i.columns vectors)
  =/  separator=tape  ?:(=(~ p.rest) ~ ~['\0a' '\0a'])
  :-  (weld table (weld separator p.rest))
      (add (lent vectors) q.rest)
::
++  markdown-table
  |=  $:  columns=(lest $%(column qualified-column))
          vectors=(list vector)
          ==
  ^-  tape
  =/  heading  (markdown-heading columns)
  =/  divider  (markdown-divider columns)
  =/  table  (weld heading (weld ~['\0a'] divider))
  =/  rows  (markdown-rows vectors)
  ?~  rows  table
  (weld table (weld ~['\0a'] rows))
::
++  markdown-rows
  |=  vectors=(list vector)
  ^-  tape
  =/  out  *tape
  |-
  ?~  vectors  out
  =/  row  (markdown-row +.i.vectors)
  =/  separator=tape  ?:(=(~ out) ~ ~['\0a'])
  %=  $
    vectors  t.vectors
    out      (weld out (weld separator row))
  ==
::
++  markdown-heading
  |=  columns=(list $%(column qualified-column))
  ^-  tape
  =/  out=tape  "|"
  |-
  ?~  columns  out
  =/  name
    (markdown-escape (trip (relation-column-name i.columns)))
  %=  $
    columns  t.columns
    out      (weld out (weld " " (weld name " |")))
  ==
::
++  markdown-divider
  |=  columns=(list $%(column qualified-column))
  ^-  tape
  =/  out=tape  "|"
  |-
  ?~  columns  out
  %=  $
    columns  t.columns
    out      (weld out " --- |")
  ==
::
++  markdown-row
  |=  values=(list vector-cell)
  ^-  tape
  =/  out=tape  "|"
  |-
  ?~  values  out
  =/  cell=vector-cell  i.values
  =/  value  (markdown-dime +.cell)
  %=  $
    values  t.values
    out     (weld out (weld " " (weld value " |")))
  ==
::
++  markdown-dime
  |=  value=dime
  ^-  tape
  (markdown-escape (render-dime value))
::
++  markdown-escape
  |=  value=tape
  ^-  tape
  %-  zing
  %+  turn  value
  |=  char=@tD
  ^-  tape
  ?:  =(char 92)  "\\\\"
  ?:  =(char '|')  "\\|"
  ?:  =(char 10)  "<br>"
  ~[char]
::
++  relations-html
  |=  relations=(list relation)
  ^-  [p=tape q=@ud]
  =/  out  *tape
  =/  count  0
  |-
  ?~  relations  [out count]
  =/  html  (relation-html i.relations)
  %=  $
    relations  t.relations
    out        (weld out p.html)
    count      (add count q.html)
  ==
::
++  relation-html
  |=  a=relation
  ^-  [p=tape q=@ud]
  =/  columns=(lest (lest $%(column qualified-column)))  columns.a
  ?:  &(ordered.a (gth (lent columns) 1))
    ~|("format: ordered multi-schema html output not implemented" !!)
  %:  relation-html-tables
    =(~ relation-id.a)
    ordered.a
    0
    columns
    data-rows.a
  ==
::
++  relation-html-tables
  |=  $:  use-keys=?
          ordered=?
          columns-index=@ud
          columns=(list (lest $%(column qualified-column)))
          rows=(list [columns-index=@ud =data-row])
          ==
  ^-  [p=tape q=@ud]
  ?~  columns  [~ 0]
  =/  vectors
    %:  relation-table-vectors
      use-keys
      ordered
      columns-index
      i.columns
      rows
    ==
  =/  rest
    %=  $
      columns-index  +(columns-index)
      columns        t.columns
    ==
  :-  (weld (html-table i.columns vectors) p.rest)
      (add (lent vectors) q.rest)
::
++  relation-table-vectors
  |=  $:  use-keys=?
          ordered=?
          columns-index=@ud
          columns=(lest $%(column qualified-column))
          rows=(list [columns-index=@ud =data-row])
          ==
  ^-  (list vector)
  =/  matching
    %+  turn
      %+  skim  rows
      |=  row=[columns-index=@ud =data-row]
      =(columns-index columns-index.row)
    |=  row=[columns-index=@ud =data-row]
    [0 data-row.row]
  =/  schemas  ~[columns]
  ?:  ordered
    (relation-vectors-ordered use-keys schemas matching)
  (relation-vectors-unordered use-keys schemas matching)
::
++  html-table
  |=  $:  columns=(lest $%(column qualified-column))
          vectors=(list vector)
          ==
  ^-  tape
  =/  body=tape
    (weld (html-heading columns) (html-rows vectors))
  (weld "<table>" (weld body "</table>"))
::
++  html-rows
  |=  vectors=(list vector)
  ^-  tape
  =/  out  *tape
  |-
  ?~  vectors  out
  =/  v=vector  i.vectors
  %=  $
    vectors  t.vectors
    out      (weld out (html-row +.v))
  ==
::
++  html-heading
  |=  columns=(list $%(column qualified-column))
  ^-  tape
  =/  out=tape  "<tr>"
  |-
  ?~  columns  (weld out "</tr>")
  =/  name
    (html-escape (trip (relation-column-name i.columns)))
  %=  $
    columns  t.columns
    out      (weld out (weld "<th>" (weld name "</th>")))
  ==
::
::  Render one HTML data row.
++  html-row
  |=  values=(list vector-cell)
  ^-  tape
  =/  out=tape  "<tr>"
  |-
  ?~  values  (weld out "</tr>")
  =/  cell=vector-cell  i.values
  %=  $
    values  t.values
    out     (weld out (weld "<td>" (weld (html-dime +.cell) "</td>")))
  ==
::
++  html-dime
  |=  value=dime
  ^-  tape
  (html-escape (render-dime value))
::
++  html-escape
  |=  value=tape
  ^-  tape
  %-  zing
  %+  turn  value
  |=  char=@tD
  ^-  tape
  ?:  =(char '&')  "&amp;"
  ?:  =(char '<')  "&lt;"
  ?:  =(char '>')  "&gt;"
  ~[char]
::
++  relation-column-name
  |=  col=$%(column qualified-column)
  ^-  @tas
  ?-  -.col
    %column
      name.col
    %qualified-column
      name.col
  ==
::
++  relation-vectors
  |=  a=relation
  ^-  (list vector)
  =/  columns=(lest (lest $%(column qualified-column)))  columns.a
  =/  use-keys  =(~ relation-id.a)
  ?:  ordered.a
    ?:  (gth (lent columns) 1)
      ~|("format: ordered multi-schema vector output not implemented" !!)
    (relation-vectors-ordered use-keys columns data-rows.a)
  (relation-vectors-unordered use-keys columns data-rows.a)
::
++  relation-vectors-ordered
  |=  $:  use-keys=?
          columns=(lest (lest $%(column qualified-column)))
          rows=(list [columns-index=@ud =data-row])
          ==
  ^-  (list vector)
  =/  out  *(list vector)
  =/  seen  *(set vector)
  |-
  ?~  rows  out
  =/  row=[columns-index=@ud =data-row]  i.rows
  =/  format
    (relation-columns-at columns-index.row columns)
  =/  v  (relation-vector use-keys format data-row.row)
  ?:  (~(has in seen) v)
    $(rows t.rows)
  %=  $
    rows  t.rows
    out   [v out]
    seen  (~(put in seen) v)
  ==
::
++  relation-vectors-unordered
  |=  $:  use-keys=?
          columns=(lest (lest $%(column qualified-column)))
          rows=(list [columns-index=@ud =data-row])
          ==
  ^-  (list vector)
  ?~  rows  ~
  =/  first=[columns-index=@ud =data-row]  i.rows
  =/  format
    (relation-columns-at columns-index.first columns)
  =/  grouped
    %:  relation-vector-group
      use-keys
      format
      columns-index.first
      rows
    ==
  (weld -.grouped $(rows +.grouped))
::
++  relation-vector-group
  |=  $:  use-keys=?
          format=(lest $%(column qualified-column))
          format-index=@ud
          rows=(list [columns-index=@ud =data-row])
          ==
  ^-  [(list vector) (list [columns-index=@ud =data-row])]
  =/  out  *(set vector)
  =/  aside  *(list [columns-index=@ud =data-row])
  |-
  ?~  rows
    [~(tap in out) (flop aside)]
  =/  row=[columns-index=@ud =data-row]  i.rows
  ?.  =(format-index columns-index.row)
    %=  $
      rows   t.rows
      aside  [row aside]
    ==
  %=  $
    rows  t.rows
    out   (~(put in out) (relation-vector use-keys format data-row.row))
  ==
::
++  relation-columns-at
  |=  $:  index=@ud
          columns=(list (lest $%(column qualified-column)))
          ==
  ^-  (lest $%(column qualified-column))
  =/  requested  index
  |-
  ?~  columns
    ~|("format: invalid relation columns index {<requested>}" !!)
  ?:  =(0 index)
    i.columns
  $(index (dec index), columns t.columns)
::
++  relation-vector
  |=  [use-keys=? columns=(lest $%(column qualified-column)) row=data-row]
  ^-  vector
  :-  %vector
  =/  counts  *(map @tas @ud)
  |-
  ^-  (lest vector-cell)
  =/  name
    ?-  -.i.columns
      %column
        name.i.columns
      %qualified-column
        name.i.columns
    ==
  =/  count  (~(gut by counts) name 0)
  =/  key
    ?:  use-keys
      ?:  =(0 count)
        name
      %-  crip
      %-  zing
      :~  (trip name)
          "-"
          (trip (scot %ud count))
          ==
    name
  =/  cell=vector-cell
    ?-  -.row
      %indexed-row
        ?-  -.i.columns
          %column
            =/  c=column  ;;(column i.columns)
            [name.c [type.c (indexed-cell-value data.row key name.c addr.c)]]
          %qualified-column
            =/  c=qualified-column  ;;(qualified-column i.columns)
            [name.c [%ud (indexed-cell-value data.row key name.c 0)]]
        ==
      %joined-row
        ?>  ?=(%qualified-column -.i.columns)
        =/  c=qualified-column  ;;(qualified-column i.columns)
        =/  vals  (~(got by data.row) qualifier.c)
        [name.c [%ud (~(got by vals) name.c)]]
    ==
  ?~  t.columns
    [cell ~]
  =/  next-counts  (~(put by counts) name +(count))
  [cell $(counts next-counts, columns t.columns)]
::
++  indexed-cell-value
  |=  [data=(map @tas @) key=@tas name=@tas addr=@]
  ^-  @
  =/  val  (~(get by data) key)
  ?^  val
    u.val
  =/  named  (~(get by data) name)
  ?^  named
    u.named
  ?:  =(0 addr)
    ~|("format: indexed column {<name>} not found" !!)
  =/  x  .*(data [%0 addr])
  ?@(x x ;;(@ +.x))
--
