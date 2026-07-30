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
      (turn results format-vectors)
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
++  relation-vectors
  |=  a=relation
  ^-  (list vector)
  =/  columns=(lest $%(column qualified-column))  columns.a
  =/  use-keys  =(~ relation-id.a)
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
