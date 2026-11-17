/-  *obelisk-ast
|%
::
+$  delimited-format  ?(%csv %tab %spac %tape)
::
::  $table-cell: a rendered cell; ~ is a column absent from the row's format
+$  table-cell  [p=@tas q=(unit dime)]
+$  table-cells
  $:  heading=(lest $%(column qualified-column))
      rows=(list (list table-cell))
      ==
::
::  $column-key: a column's identity across the formats of one relation
+$  column-key  [qual=(unit qualified-table) name=@tas n=@ud]
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
        =/  tables=(list table-cells)
          (zing (turn `(list relation)`+.i.results relation-tables))
        =/  arrays=(list tape)
          %+  turn  tables
          |=  t=table-cells
          ^-  tape
          %-  json-array
          %+  turn  rows.t
          |=  row=(list table-cell)
          ^-  tape
          =/  cells=(list tape)
            %+  turn  row
            |=  cell=table-cell
            ^-  tape
            =/  value=tape
              ?~  q.cell  "null"
              ::  @ud and its sized forms are json numbers
              ?.  =('ud' (end [3 2] p.u.q.cell))
                (json-string (render-dime u.q.cell))
              (skim (scow %ud q.u.q.cell) |=(char=@tD !=(char '.')))
            :(weld (json-string (trip p.cell)) ":" value)
          :(weld ~['{'] (json-comma-list cells) ~['}'])
        :-  [%message (crip (json-array arrays))]
            [~ (tables-count tables)]
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
        =/  tables=(list table-cells)
          (zing (turn `(list relation)`+.i.results relation-tables))
        =/  nodes=marl
          %+  turn  tables
          |=  t=table-cells
          ^-  manx
          =/  heading=manx
            ;tr
              ;*
              %+  turn  heading.t
              |=  column=$%(column qualified-column)
              ;th: {(trip (relation-column-name column))}
            ==
          =/  rows=marl
            %+  turn  rows.t
            |=  row=(list table-cell)
            ;tr
              ;*
              %+  turn  row
              |=  cell=table-cell
              ;td: {(cell-text cell)}
            ==
          ;table
            ;+  heading
            ;*  rows
          ==
        :-  [%message (crip (zing (turn nodes en-xml:html)))]
            [~ (tables-count tables)]
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
  =/  tables  (relation-tables a)
  :_  (tables-count tables)
  %-  zing
  %+  join  "\0a"
  %+  turn  tables
  |=  t=table-cells
  ^-  tape
  =/  line
    |=  values=(list tape)
    ^-  tape
    (zing (join (delimiter kind) (turn values (cury delimited-value kind))))
  =/  lines=(list tape)
    :-  (line (turn heading.t (cork relation-column-name trip)))
    (turn rows.t |=(row=(list table-cell) (line (turn row cell-text))))
  (zing (join "\0a" lines))
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
        =/  tables=(list table-cells)
          (zing (turn `(list relation)`+.i.results relation-tables))
        =/  markdown=tape
          %-  zing
          %+  join  "\0a\0a"
          %+  turn  tables
          |=  t=table-cells
          ^-  tape
          =/  line
            |=  values=(list tape)
            ^-  tape
            %-  zing
            :-  "|"
            (turn values |=(v=tape :(weld " " (markdown-escape v) " |")))
          =/  rows=(list tape)
            (turn rows.t |=(row=(list table-cell) (line (turn row cell-text))))
          =/  lines=(list tape)
            :*  (line (turn heading.t (cork relation-column-name trip)))
                (line (turn heading.t |=(* "---")))
                rows
            ==
          (zing (join "\0a" lines))
        :-  [%message (crip markdown)]
            [~ (tables-count tables)]
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
        =/  tables=(list table-cells)
          (zing (turn `(list relation)`+.i.results relation-tables))
        =/  html=tape
          %-  zing
          %+  turn  tables
          |=  t=table-cells
          ^-  tape
          =/  cells
            |=  [tag=tape values=(list tape)]
            ^-  tape
            %-  zing
            %+  turn  values
            |=(v=tape :(weld "<" tag ">" (html-escape v) "</" tag ">"))
          =/  rows=tape
            %-  zing
            %+  turn  rows.t
            |=  row=(list table-cell)
            :(weld "<tr>" (cells "td" (turn row cell-text)) "</tr>")
          ;:  weld
            "<table><tr>"
            (cells "th" (turn heading.t (cork relation-column-name trip)))
            "</tr>"
            rows
            "</table>"
          ==
        :-  [%message (crip html)]
            [~ (tables-count tables)]
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
  =/  tables  (relation-tables a)
  :_  (tables-count tables)
  %-  zing
  %+  turn  tables
  |=  t=table-cells
  ^-  wain
  =/  line
    |=  values=(list tape)
    ^-  @t
    (crip (zing (join " " values)))
  :-  (line (turn heading.t (cork relation-column-name trip)))
  (turn rows.t |=(row=(list table-cell) (line (turn row cell-text))))
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
::  +relation-tables: one table per columns entry of a relation, or for an
::  ordered relation of several entries one merged table keeping row order
++  relation-tables
  |=  a=relation
  ^-  (list table-cells)
  =/  use-keys  =(~ relation-id.a)
  ?:  &(ordered.a ?=(^ t.columns.a))
    ~[(merged-table use-keys a)]
  =/  formats=(list (lest $%(column qualified-column)))  columns.a
  =/  index  *@ud
  |-  ^-  (list table-cells)
  ?~  formats  ~
  =/  vectors=(list vector)
    %:  relation-table-vectors  use-keys
                                ordered.a
                                index
                                i.formats
                                data-rows.a
                                ==
  =/  rows=(list (list table-cell))
    %+  turn  vectors
    |=(v=vector (turn +.v |=(c=vector-cell [p.c `q.c])))
  [[i.formats rows] $(formats t.formats, index +(index))]
::
::  +merged-table: the columns of all formats in select order; a row has
::  an empty cell for each column its format lacks
++  merged-table
  |=  [use-keys=? a=relation]
  ^-  table-cells
  =/  formats=(list (lest $%(column qualified-column)))  columns.a
  =/  keyed=(list (list [key=column-key col=$%(column qualified-column)]))
    (turn formats column-keys)
  =/  merged=(list [key=column-key col=$%(column qualified-column)])
    %+  roll  keyed
    |=  $:  format=(list [key=column-key col=$%(column qualified-column)])
            merged=(list [key=column-key col=$%(column qualified-column)])
            ==
    =/  at  *@ud
    |-  ^+  merged
    ?~  format  merged
    =/  found  (find ~[key.i.format] (turn merged head))
    ?^  found  $(format t.format, at +(u.found))
    $(format t.format, merged (into merged at i.format), at +(at))
  =/  heading=(list $%(column qualified-column))  (turn merged tail)
  ?>  ?=(^ heading)
  =/  rows  data-rows.a
  =/  seen  *(set (list table-cell))
  =/  out  *(list (list table-cell))
  |-  ^-  table-cells
  ?~  rows  [heading (flop out)]
  =/  format  (relation-columns-at columns-index.i.rows formats)
  =/  cells=(map column-key dime)
    =/  keys  (snag columns-index.i.rows keyed)
    =/  values=(list vector-cell)
      +:(relation-vector use-keys format data-row.i.rows)
    =|  cells=(map column-key dime)
    |-  ^+  cells
    ?~  keys  cells
    ?~  values  cells
    %=  $
      keys    t.keys
      values  t.values
      cells   (~(put by cells) key.i.keys q.i.values)
    ==
  =/  row=(list table-cell)
    %+  turn  merged
    |=  [key=column-key col=$%(column qualified-column)]
    [(relation-column-name col) (~(get by cells) key)]
  ?:  (~(has in seen) row)  $(rows t.rows)
  $(rows t.rows, seen (~(put in seen) row), out [row out])
::
++  column-keys
  |=  format=(lest $%(column qualified-column))
  ^-  (list [key=column-key col=$%(column qualified-column)])
  %+  spun  `(list $%(column qualified-column))`format
  |=  $:  col=$%(column qualified-column)
          seen=(map [(unit qualified-table) @tas] @ud)
          ==
  =/  qual=(unit qualified-table)
    ?-(-.col %column ~, %qualified-column `qualifier.col)
  =/  name  (relation-column-name col)
  =/  n  (~(gut by seen) [qual name] 0)
  [[[qual name n] col] (~(put by seen) [qual name] +(n))]
::
++  tables-count
  |=  tables=(list table-cells)
  ^-  @ud
  (roll (turn tables |=(t=table-cells (lent rows.t))) add)
::
++  cell-text
  |=  cell=table-cell
  ^-  tape
  ?~(q.cell ~ (render-dime u.q.cell))
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
  ?~  rows  (flop out)
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
