/-  *obelisk-ast
|% 
::
++  print-crash
  |=  trace=tang
  ^-  @f
  ~&  "%obelisk-crash:"
  |-
  ?~  trace  %.y
  ~&  "{<(crip ~(ram re i.trace))>}"
  $(trace t.trace)
::
::  +print:  (list cmd-result) -> ?
++  print
  |=  a=(list cmd-result)
  ^-  @f
  ~&  "%obelisk-result:"
  |-
  ?~  a  %.y
  =/  rc=?  (print-cmd-result -.a)
  $(a +.a)
::
++  print-cmd-result
  |=  a=cmd-result
  ^-  @f
  ~&  "  %results"
  =/  results=(list result)  +.a
  |-
  ?~  results  %.y
  =/  b=result  -.results
    ?-  -.b
      %action
        ~&  "    [ {<-.b>} {<action.b>} ]"
        $(results +.results)
      %relation-name
        ~&  "    [ {<-.b>} {<name.b>} ]"
        $(results +.results)
      %message
        ~&  "    [ {<-.b>} {<msg.b>} ]"
        $(results +.results)
      %vector-count
        ~&  "    [ {<-.b>} {<count.b>} ]"
        $(results +.results)
      %server-time
        ~&  "    [ {<-.b>} {<date.b>} ]"
        $(results +.results)
      %security-time
        ~&  "    [ {<-.b>} {<date.b>} ]"
        $(results +.results)
      %schema-time
        ~&  "    [ {<-.b>} {<date.b>} ]"
        $(results +.results)
      %data-time
        ~&  "    [ {<-.b>} {<date.b>} ]"
        $(results +.results)
      %result-set
        ~|("print: %result-set output is no longer supported" !!)
      %relations
        =/  rc=?  (print-relations +.b)
        $(results +.results)
      %select-relation
        =/  rc=?  (print-select-relation +.b)
        $(results +.results)
      ==
::
++  print-relations
  |=  a=(list relation)
  ^-  @f
  ~&  "    %relations"
  |-
  ?~  a  %.y
  =/  rc=?  (print-relation -.a)
  $(a +.a)
::
++  print-select-relation
  |=  a=relation
  ^-  @f
  ~&  "    %select-relation"
  (print-relation a)
::
++  print-relation
  |=  a=relation
  ^-  @f
  =/  columns=(lest (lest $%(column qualified-column)))  columns.a
  =/  rows=(list [columns-index=@ud =data-row])  data-rows.a
  ?:  =(~ rows)  ~&  "      result set empty"  %.y
  =/  i  ?:  (lth (lent rows) 11)  0  1
  =/  print-elipsis=?  (gte (lent rows) 11)
  =/  prior-format=(unit @ud)  ~
  |-
  ?~  rows  %.y
  =/  row=[columns-index=@ud =data-row]  i.rows
  =/  rc2  (print-relation-entry columns row prior-format)
  =/  rc3  ?:  &(=(i 9) print-elipsis)
              (print-relation-tail columns (rear rows))
            %.n
  %=  $
    rows          ?:  =(i 9)  ~  +.rows
    i             +(i)
    prior-format  `columns-index.row
  ==
::
++  print-relation-entry
  |=  $:  columns=(lest (lest $%(column qualified-column)))
          row=[columns-index=@ud =data-row]
          prior-format=(unit @ud)
          ==
  ^-  @f
  =/  format  (relation-columns-at columns-index.row columns)
  =/  rc
    ?:  ?~(prior-format %.y !=(u.prior-format columns-index.row))
      (print-relation-heading format)
    %.y
  (print-relation-row format data-row.row)
::
++  print-relation-tail
  |=  $:  columns=(lest (lest $%(column qualified-column)))
          row=[columns-index=@ud =data-row]
          ==
  ^-  @f
  ~&  "      ..."
  (print-relation-entry columns row ~)
::
++  relation-columns-at
  |=  $:  index=@ud
          columns=(list (lest $%(column qualified-column)))
          ==
  ^-  (lest $%(column qualified-column))
  =/  requested  index
  |-
  ?~  columns
    ~|("print: invalid relation columns index {<requested>}" !!)
  ?:  =(0 index)
    i.columns
  $(index (dec index), columns t.columns)
::
++  print-relation-heading
  |=  columns=(list $%(column qualified-column))
  ^-  @f
  =/  heading=tape  "    "
  |-
  ?~  columns
    ~&  "{<(crip (flop heading))>}"  %.y
  =/  name  (relation-column-name i.columns)
  $(columns t.columns, heading (weld (flop (trip name)) (weld "  " heading)))
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
++  print-relation-row
  |=  [columns=(list $%(column qualified-column)) row=data-row]
  ^-  @f
  =/  out=tape  "    "
  |-
  ?~  columns  ~&  "{<(crip (flop out))>}"  %.y
  =/  cell  (print-relation-cell i.columns row)
  %=  $
    columns  t.columns
    out      (weld (flop cell) (weld "  " out))
  ==
::
++  print-relation-cell
  |=  [col=$%(column qualified-column) row=data-row]
  ^-  tape
  ?-  -.row
    %indexed-row
      ?>  ?=(%column -.col)
      =/  c=column  ;;(column col)
      =/  val  (~(got by data.row) name.c)
      ?:  =(type.c ~.t)  (trip `@t`val)
      ~(rend co %$ [type.c val])
    %joined-row
      ?>  ?=(%qualified-column -.col)
      =/  c=qualified-column  ;;(qualified-column col)
      =/  vals  (~(got by data.row) qualifier.c)
      (trip (scot %ud (~(got by vals) name.c)))
  ==
--
