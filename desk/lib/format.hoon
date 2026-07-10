/-  *obelisk-ast
|%
::
++  format-results
  |=  [fmt=result-format results=(list cmd-result)]
  ^-  (list cmd-result)
  ?-  fmt
    %raw
      results
    %vectors
      (turn results format-cmd-result)
    %markdown
      ~|('not implemented' !!)
    %html
      ~|('not implemented' !!)
    %wain
      ~|('not implemented' !!)
    %tape
      ~|('not implemented' !!)
    %json
      ~|('not implemented' !!)
  ==
::
++  format-cmd-result
  |=  a=cmd-result
  ^-  cmd-result
  :-  %results
  =/  results=(list result)  +.a
  =/  out=(list result)      ~
  =/  count=(unit @ud)       ~
  |-
  ?~  results  (flop out)
  =/  formatted  (format-result i.results count)
  %=  $
    results  t.results
    out      [-.formatted out]
    count    +.formatted
  ==
::
++  format-result
  |=  [a=result count=(unit @ud)]
  ^-  [result (unit @ud)]
  ?-  -.a
    %relations
      =/  vectors=(list vector)  (relations-vectors +.a)
      [[%result-set vectors] [~ (lent vectors)]]
    %vector-count
      ?~  count  [a count]
      [[%vector-count u.count] count]
    %result-set
      [a [~ (lent +.a)]]
    %action  [a count]
    %relation-name  [a count]
    %message  [a count]
    %server-time  [a count]
    %security-time  [a count]
    %schema-time  [a count]
    %data-time  [a count]
    %select-relation  [a count]
  ==
::
++  relations-vectors
  |=  relations=(list relation)
  ^-  (list vector)
  (zing (turn relations relation-vectors))
::
++  relation-vectors
  |=  a=relation
  ^-  (list vector)
  =/  columns=(lest $%(column qualified-column))  columns.a
  =/  use-keys  (relation-output-keys relation-id.a)
  ?:  ordered.a
    (relation-vectors-ordered use-keys columns data-rows.a)
  (relation-vectors-unordered use-keys columns data-rows.a)
::
++  relation-vectors-ordered
  |=  $:  use-keys=?
          columns=(lest $%(column qualified-column))
          rows=(list data-row)
          ==
  ^-  (list vector)
  =/  out   *(list vector)
  =/  seen  *(set vector)
  |-
  ?~  rows  out
  =/  v  (relation-vector use-keys columns i.rows)
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
          columns=(lest $%(column qualified-column))
          rows=(list data-row)
          ==
  ^-  (list vector)
  =/  out  *(set vector)
  |-
  ?~  rows  ~(tap in out)
  %=  $
    rows  t.rows
    out   (~(put in out) (relation-vector use-keys columns i.rows))
  ==
::
++  relation-vector
  |=  [use-keys=? columns=(lest $%(column qualified-column)) row=data-row]
  ^-  vector
  :-  %vector
  (relation-row-cells use-keys columns row)
::
++  relation-row-cells
  |=  [use-keys=? columns=(lest $%(column qualified-column)) row=data-row]
  ^-  (lest vector-cell)
  (relation-row-cells-with use-keys *(map @tas @ud) columns row)
::
++  relation-row-cells-with
  |=  $:  use-keys=?
          counts=(map @tas @ud)
          columns=(lest $%(column qualified-column))
          row=data-row
          ==
  ^-  (lest vector-cell)
  =/  name   (relation-column-name i.columns)
  =/  count  (~(gut by counts) name 0)
  =/  key    ?:  use-keys  (output-cell-key name count)  name
  =/  cell   (relation-cell i.columns key row)
  ?~  t.columns
    [cell ~]
  =/  next-counts  (~(put by counts) name +(count))
  [cell $(counts next-counts, columns t.columns)]
::
++  relation-output-keys
  |=  rid=relation-id
  ^-  ?
  ?-  -.rid
    %qualified-table  %.n
    %cte-name         =(%result name.rid)
  ==
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
++  relation-cell
  |=  [col=$%(column qualified-column) key=@tas row=data-row]
  ^-  vector-cell
  ?-  -.row
    %indexed-row
      ?-  -.col
        %column
          =/  c=column  ;;(column col)
          [name.c [type.c (indexed-cell-value data.row key name.c addr.c)]]
        %qualified-column
          =/  c=qualified-column  ;;(qualified-column col)
          [name.c [%ud (indexed-cell-value data.row key name.c 0)]]
      ==
    %joined-row
      ?>  ?=(%qualified-column -.col)
      =/  c=qualified-column  ;;(qualified-column col)
      =/  vals  (~(got by data.row) qualifier.c)
      [name.c [%ud (~(got by vals) name.c)]]
  ==
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
::
++  output-cell-key
  |=  [name=@tas count=@ud]
  ^-  @tas
  ?:  =(0 count)
    name
  %-  crip
  %-  zing
  :~  (trip name)
      "-"
      (trip (scot %ud count))
      ==
--
