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
      ~|('not implemented' !!)
    %html
      (turn results format-html)
    %manx
      ~|('not implemented' !!)
    %wain
      ~|('not implemented' !!)
    %tape
      ~|('not implemented' !!)
    %json
      ~|('not implemented' !!)
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
    %:  relation-html-vectors
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
++  relation-html-vectors
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
  %-  html-escape
  ?:  =(-.value ~.t)
    (trip `@t`+.value)
  ~(rend co %$ value)
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
