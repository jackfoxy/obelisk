/-  *obelisk-ast
|%
::
+$  delimited-format  ?(%csv %tab %spac %tape)
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
      (turn results format-manx)
    %wain
      (turn results format-wain)
    %tape
      (turn results format-tape)
    %json
      (turn results format-json)
    %csv
      (turn results format-csv)
    %tab
      (turn results format-tab)
    %spac
      (turn results format-spac)
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
        =/  relations=(list relation)  +.i.results
        =/  json-result=[p=tape q=@ud]
          =/  tables  *(list tape)
          =/  total  *@ud
          |-
          ?~  relations  [(json-array tables) total]
          =/  a=relation  i.relations
          =/  columns
            ^-  (lest (lest $%(column qualified-column)))
            columns.a
          ?:  &(ordered.a (gth (lent columns) 1))
            ~|  "format: ordered multi-schema json output not implemented"
                !!
          =/  formatted=[p=(list tape) q=@ud]
            =/  columns-index  *@ud
            =/  remaining  `(list (lest $%(column qualified-column)))`columns
            =/  out  *(list tape)
            =/  count  *@ud
            |-
            ?~  remaining  [out count]
            =/  vectors
              %:  relation-table-vectors
                =(~ relation-id.a)
                ordered.a
                columns-index
                i.remaining
                data-rows.a
              ==
            =/  rows=(list tape)
              %+  turn  vectors
              |=  vector=vector
              =/  cells=(list tape)
                %+  turn  +.vector
                |=  cell=vector-cell
                =/  value
                  ?:  =(-.q.cell ~.ud)
                    %+  skim  (scow %ud `@ud`+.q.cell)
                    |=  char=@tD
                    !=(char '.')
                  (json-string (render-dime q.cell))
                ;:  weld
                  (json-string (trip p.cell))
                  ":"
                  value
                ==
              (weld ~['{'] (weld (json-comma-list cells) ~['}']))
            %=  $
              columns-index  +(columns-index)
              remaining      t.remaining
              out            (weld out ~[(json-array rows)])
              count          (add count (lent vectors))
            ==
          %=  $
            relations  t.relations
            tables     (weld tables p.formatted)
            total      (add total q.formatted)
          ==
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
::  Format relation results as serialized table nodes.
++  format-manx
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
        =/  relations=(list relation)  +.i.results
        =/  manx-result=[p=marl q=@ud]
          =/  tables  *marl
          =/  total  *@ud
          |-
          ?~  relations  [tables total]
          =/  a=relation  i.relations
          =/  columns
            ^-  (lest (lest $%(column qualified-column)))
            columns.a
          ?:  &(ordered.a (gth (lent columns) 1))
            ~|  "format: ordered multi-schema manx output not implemented"
                !!
          =/  formatted=[p=marl q=@ud]
            =/  columns-index  *@ud
            =/  remaining  `(list (lest $%(column qualified-column)))`columns
            =/  nodes  *marl
            =/  count  *@ud
            |-
            ?~  remaining  [nodes count]
            =/  vectors
              %:  relation-table-vectors
                =(~ relation-id.a)
                ordered.a
                columns-index
                i.remaining
                data-rows.a
              ==
            =/  heading=manx
              ;tr
                ;*
                %+  turn  i.remaining
                |=  column=$%(column qualified-column)
                ;th: {(trip (relation-column-name column))}
              ==
            =/  rows=marl
              %+  turn  vectors
              |=  vector=vector
              ;tr
                ;*
                %+  turn  +.vector
                |=  cell=vector-cell
                ;td: {(render-dime q.cell)}
              ==
            =/  node=manx
              ;table
                ;+  heading
                ;*  rows
              ==
            %=  $
              columns-index  +(columns-index)
              remaining      t.remaining
              nodes          (weld nodes ~[node])
              count          (add (lent vectors) count)
            ==
          %=  $
            relations  t.relations
            tables     (weld tables p.formatted)
            total      (add total q.formatted)
          ==
        =/  serialized
          %-  zing
          %+  turn  p.manx-result
          |=  node=manx
          (en-xml:html node)
        :-  [%message (crip serialized)]
            [~ q.manx-result]
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
::  Format relation results as one message per space-delimited Wain cord.
++  format-wain
  |=  a=cmd-result
  ^-  cmd-result
  :-  %results
  =/  results=(list result)  +.a
  =/  out=(list result)      ~
  =/  count=(unit @ud)       ~
  |-
  ?~  results  (flop out)
  =/  formatted=[p=(list result) q=(unit @ud)]
    ?-  -.i.results
      %relations
        =/  relations=(list relation)  +.i.results
        =/  wain-result=[p=wain q=@ud]
          =/  lines  *wain
          =/  total  *@ud
          |-
          ?~  relations  [lines total]
          =/  formatted  (relation-wain i.relations)
          %=  $
            relations  t.relations
            lines      (weld lines p.formatted)
            total      (add total q.formatted)
          ==
        =/  messages=(list result)
          %+  turn  p.wain-result
          |=  line=@t
          ^-  result
          [%message line]
        [messages [~ q.wain-result]]
      %vector-count
        =/  formatted-result=result
          ?~  count  i.results
          [%vector-count u.count]
        [~[formatted-result] count]
      %result-set  [~[i.results] count]
      %action  [~[i.results] count]
      %relation-name  [~[i.results] count]
      %message  [~[i.results] count]
      %server-time  [~[i.results] count]
      %security-time  [~[i.results] count]
      %schema-time  [~[i.results] count]
      %data-time  [~[i.results] count]
      %select-relation  [~[i.results] count]
    ==
  %=  $
    results  t.results
    out      (weld (flop p.formatted) out)
    count    q.formatted
  ==
::
::  Format relation results as LF-delimited, space-separated tape rows.
++  format-tape
  |=  a=cmd-result
  ^-  cmd-result
  (format-delimited %tape a)
::
::  Format relation results as comma-separated values.
++  format-csv
  |=  a=cmd-result
  ^-  cmd-result
  (format-delimited %csv a)
::
::  Format relation results as tab-delimited values.
++  format-tab
  |=  a=cmd-result
  ^-  cmd-result
  (format-delimited %tab a)
::
::  Format relation results as space-delimited values.
++  format-spac
  |=  a=cmd-result
  ^-  cmd-result
  (format-delimited %spac a)
::
++  format-delimited
  |=  [kind=delimited-format a=cmd-result]
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
        =/  relations=(list relation)  +.i.results
        =/  delimited-result=[p=tape q=@ud]
          =/  out  *tape
          =/  total  *@ud
          |-
          ?~  relations  [out total]
          =/  formatted  (relation-delimited kind i.relations)
          =/  separator=tape  ?:(=(~ out) ~ ~['\0a'])
          %=  $
            relations  t.relations
            out        (weld out (weld separator p.formatted))
            total      (add total q.formatted)
          ==
        :-  [%message (crip p.delimited-result)]
            [~ q.delimited-result]
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
++  relation-delimited
  |=  [kind=delimited-format a=relation]
  ^-  [p=tape q=@ud]
  =/  columns=(lest (lest $%(column qualified-column)))  columns.a
  ?:  &(ordered.a (gth (lent columns) 1))
    ?-  kind
      %csv
        ~|("format: ordered multi-schema csv output not implemented" !!)
      %tab
        ~|("format: ordered multi-schema tab output not implemented" !!)
      %spac
        ~|("format: ordered multi-schema spac output not implemented" !!)
      %tape
        ~|("format: ordered multi-schema tape output not implemented" !!)
    ==
  =/  columns-index  *@ud
  =/  remaining  `(list (lest $%(column qualified-column)))`columns
  =/  out  *tape
  =/  count  *@ud
  |-
  ?~  remaining  [out count]
  =/  vectors
    %:  relation-table-vectors
      =(~ relation-id.a)
      ordered.a
      columns-index
      i.remaining
      data-rows.a
    ==
  =/  heading=tape
    %-  zing
    %+  join  (delimiter kind)
    %+  turn  i.remaining
    |=  column=$%(column qualified-column)
    (delimited-value kind (trip (relation-column-name column)))
  =/  rows=wain
    %+  turn  vectors
    |=  vector=vector
    %-  crip
    %-  zing
    %+  join  (delimiter kind)
    %+  turn  +.vector
    |=  cell=vector-cell
    (delimited-value kind (render-dime q.cell))
  =/  table=tape
    ?~  rows  heading
    (weld heading (weld ~['\0a'] (wain-to-tape rows)))
  =/  separator=tape  ?:(=(~ out) ~ ~['\0a'])
  %=  $
    columns-index  +(columns-index)
    remaining      t.remaining
    out            (weld out (weld separator table))
    count          (add count (lent vectors))
  ==
::
++  delimiter
  |=  kind=delimited-format
  ^-  tape
  ?-  kind
    %csv   ","
    %tab   "\09"
    %spac  " "
    %tape  " "
  ==
::
++  delimited-value
  |=  [kind=delimited-format value=tape]
  ^-  tape
  ?.  =(%csv kind)  value
  ?.  ?|  ?=(^ (find "," value))
          ?=(^ (find "\"" value))
          ?=(^ (find "\0a" value))
          ?=(^ (find "\0d" value))
      ==
    value
  =/  escaped=tape
    %-  zing
    %+  turn  value
    |=  char=@tD
    ^-  tape
    ?:  =(char 34)  "\"\""
    ~[char]
  (weld "\"" (weld escaped "\""))
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
        =/  relations=(list relation)  +.i.results
        =/  markdown=[p=tape q=@ud]
          =/  out  *tape
          =/  total  *@ud
          |-
          ?~  relations  [out total]
          =/  a=relation  i.relations
          =/  columns
            ^-  (lest (lest $%(column qualified-column)))
            columns.a
          ?:  &(ordered.a (gth (lent columns) 1))
            ~|  "format: ordered multi-schema markdown output not implemented"
                !!
          =/  formatted=[p=tape q=@ud]
            =/  columns-index  *@ud
            =/  remaining  `(list (lest $%(column qualified-column)))`columns
            =/  tables  *tape
            =/  count  *@ud
            |-
            ?~  remaining  [tables count]
            =/  vectors
              %:  relation-table-vectors
                =(~ relation-id.a)
                ordered.a
                columns-index
                i.remaining
                data-rows.a
              ==
            =/  heading=tape
              %-  zing
              :-  "|"
              %+  turn  i.remaining
              |=  column=$%(column qualified-column)
              =/  name
                %-  markdown-escape
                (trip (relation-column-name column))
              (weld " " (weld name " |"))
            =/  divider=tape
              %-  zing
              :-  "|"
              (turn i.remaining |=(column=* " --- |"))
            =/  rows=(list tape)
              %+  turn  vectors
              |=  vector=vector
              %-  zing
              :-  "|"
              %+  turn  +.vector
              |=  cell=vector-cell
              =/  value  (markdown-escape (render-dime q.cell))
              (weld " " (weld value " |"))
            =/  table=tape
              =/  base=tape  (weld heading (weld ~['\0a'] divider))
              ?~  rows  base
              =/  row-text=tape  (zing (join "\0a" rows))
              (weld base (weld ~['\0a'] row-text))
            =/  separator=tape  ?:(=(~ tables) ~ ~['\0a' '\0a'])
            %=  $
              columns-index  +(columns-index)
              remaining      t.remaining
              tables         (weld tables (weld separator table))
              count          (add count (lent vectors))
            ==
          =/  separator=tape
            ?:  =(~ out)
              ~
            ?:  =(~ p.formatted)
              ~
            ~['\0a' '\0a']
          %=  $
            relations  t.relations
            out        (weld out (weld separator p.formatted))
            total      (add total q.formatted)
          ==
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
        =/  relations=(list relation)  +.i.results
        =/  html=[p=tape q=@ud]
          =/  out  *tape
          =/  total  *@ud
          |-
          ?~  relations  [out total]
          =/  a=relation  i.relations
          =/  columns
            ^-  (lest (lest $%(column qualified-column)))
            columns.a
          ?:  &(ordered.a (gth (lent columns) 1))
            ~|  "format: ordered multi-schema html output not implemented"
                !!
          =/  formatted=[p=tape q=@ud]
            =/  columns-index  *@ud
            =/  remaining  `(list (lest $%(column qualified-column)))`columns
            =/  tables  *tape
            =/  count  *@ud
            |-
            ?~  remaining  [tables count]
            =/  vectors
              %:  relation-table-vectors
                =(~ relation-id.a)
                ordered.a
                columns-index
                i.remaining
                data-rows.a
              ==
            =/  heading=tape
              %-  zing
              %+  turn  i.remaining
              |=  column=$%(column qualified-column)
              =/  name
                %-  html-escape
                (trip (relation-column-name column))
              (weld "<th>" (weld name "</th>"))
            =/  rows=tape
              %-  zing
              %+  turn  vectors
              |=  vector=vector
              =/  cells=tape
                %-  zing
                %+  turn  +.vector
                |=  cell=vector-cell
                =/  value  (html-escape (render-dime q.cell))
                (weld "<td>" (weld value "</td>"))
              (weld "<tr>" (weld cells "</tr>"))
            =/  table=tape
              ;:  weld
                "<table><tr>"
                heading
                "</tr>"
                rows
                "</table>"
              ==
            %=  $
              columns-index  +(columns-index)
              remaining      t.remaining
              tables         (weld tables table)
              count          (add count (lent vectors))
            ==
          %=  $
            relations  t.relations
            out        (weld out p.formatted)
            total      (add total q.formatted)
          ==
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
        =/  vectors
          %-  zing
          %+  turn  +.i.results
          |=  a=relation
          =/  columns
            ^-  (lest (lest $%(column qualified-column)))
            columns.a
          =/  use-keys  =(~ relation-id.a)
          ?:  ordered.a
            ?:  (gth (lent columns) 1)
              ~|  "format: ordered multi-schema vector output not implemented"
                  !!
            (relation-vectors-ordered use-keys columns data-rows.a)
          (relation-vectors-unordered use-keys columns data-rows.a)
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
++  relation-wain
  |=  a=relation
  ^-  [p=wain q=@ud]
  =/  columns=(lest (lest $%(column qualified-column)))  columns.a
  ?:  &(ordered.a (gth (lent columns) 1))
    ~|("format: ordered multi-schema wain output not implemented" !!)
  =/  columns-index  *@ud
  =/  remaining  `(list (lest $%(column qualified-column)))`columns
  =/  lines  *wain
  =/  count  *@ud
  |-
  ?~  remaining  [lines count]
  =/  vectors
    %:  relation-table-vectors
      =(~ relation-id.a)
      ordered.a
      columns-index
      i.remaining
      data-rows.a
    ==
  =/  heading
    %-  crip
    %-  zing
    %+  join  " "
    %+  turn  i.remaining
    |=  column=$%(column qualified-column)
    (trip (relation-column-name column))
  =/  rows=wain
    %+  turn  vectors
    |=  vector=vector
    %-  crip
    %-  zing
    %+  join  " "
    %+  turn  +.vector
    |=  cell=vector-cell
    (render-dime q.cell)
  %=  $
    columns-index  +(columns-index)
    remaining      t.remaining
    lines          (weld lines [heading rows])
    count          (add count (lent vectors))
  ==
::
++  wain-to-tape
  |=  lines=wain
  ^-  tape
  %-  zing
  (join "\0a" (turn lines trip))
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
  =/  escaped=tape
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
  (weld "\"" (weld escaped "\""))
::
++  render-dime
  |=  value=dime
  ^-  tape
  ?:  =(-.value ~.t)
    =/  backslash  `@tD`92
    =/  quote      `@tD`39
    =/  slash      `@tD`47
    =/  escaped=tape
      %-  zing
      %+  turn  (trip +.value)
      |=  char=@tD
      ^-  tape
      ?:  =(char backslash)  ~[backslash backslash]
      ?:  =(char quote)      ~[backslash quote]
      ?:  ?|  (gth char 126)
              (lth char 32)
          ==
        [backslash (welp ~(rux at char) ~[slash])]
      ~[char]
    (weld "'" (weld escaped "'"))
  ~(rend co %$ value)
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
++  relation-table-vectors
  |=  $:  use-keys=?
          ordered=?
          columns-index=@ud
          columns=(lest $%(column qualified-column))
          rows=(list [columns-index=@ud =data-row])
          ==
  ^-  (list vector)
  =/  matching=(list [columns-index=@ud =data-row])
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
  =/  format-index  columns-index.first
  =/  grouped=[(list vector) (list [columns-index=@ud =data-row])]
    =/  remaining  `(list [columns-index=@ud =data-row])`rows
    =/  out  *(list vector)
    =/  seen  *(set vector)
    =/  aside  *(list [columns-index=@ud =data-row])
    |-
    ?~  remaining  [(flop out) (flop aside)]
    =/  row=[columns-index=@ud =data-row]  i.remaining
    ?.  =(format-index columns-index.row)
      %=  $
        remaining  t.remaining
        aside      [row aside]
      ==
    =/  vector  (relation-vector use-keys format data-row.row)
    ?:  (~(has in seen) vector)
      $(remaining t.remaining)
    %=  $
      remaining  t.remaining
      out        [vector out]
      seen       (~(put in seen) vector)
    ==
  (weld -.grouped $(rows +.grouped))
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
