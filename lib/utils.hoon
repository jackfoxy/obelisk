/-  ast, *obelisk
|%
++  map-insert
  |*  [m=(map) key=* value=*]
  ^+  m
  ?:  (~(has by m) key)  ~|("duplicate key: {<key>}" !!)
  (~(put by m) key value)
++  map-delete
  |*  [m=(map) key=*]
  ^+  m
  ?:  (~(has by m) key)  (~(del by m) key)
  ~|("deletion key does not exist: {<key>}" !!)
++  idx-comp 
  |_  index=(list [@tas ascending=?])
  ++  order
    |=  [p=(list @) q=(list @)]
    =/  k=(list [@tas ascending=?])  index
    |-  ^-  ?
    ?:  =(-.p -.q)  $(k +.k, p +.p, q +.q)
    ?:  =(-<.k %t)  (aor -.p -.q)
    ?:  ->.k  (lth -.p -.q)
    (gth -.p -.q)
  --
++  pri-key
  |=  key=(list [@tas ?])
        ((on (list [@tas ?]) (map @tas @)) ~(order idx-comp key))
++  data-key    ((on @da data) gth)
++  key-atom
  |=  a=[p=@tas q=value-or-default:ast r=(map @tas column:ast)]
  ^-  @
  ?:  ?=(dime q.a)  
    ?.  =(%default p.q.a)  q.q.a     
    ?:  =(%da type:(~(got by r.a) p.a))  *@da    :: default to bunt
    0
  ~|("key atom {<q.a>} not supported" !!)
::
::  gets the schema with matching or next subsequent time
++  schema-key  ((on @da schema) gth)
++  get-schema
    |=  [sys=((mop @da schema) gth) time=@da]
    ^-  schema
    =/  time-key  (add time `@dr`(yule `tarp`[0 0 0 1 ~]))  :: one second after
    ~|  "schema not available for {<time>}"
    ->:(pop:schema-key (lot:schema-key sys `time-key ~))
::
:: get view with current or most recent previous time
++  view-key  ((on data-obj-key view) ns-obj-comp)
++  get-view
  |=  [key=data-obj-key =views]
  ^-  view
  ~|  "view {<ns.key>}.{<obj.key>} does not exist for time {<time.key>}"
  ->:(tab:view-key views `[ns.key obj.key `@da`(add `@`time.key 1)] 1)
::
++  order-row
  |_  index=(list column-order)  
  :: to do: accommodate varying row types
  ++  order
  |=  [p=(list @) q=(list @)]
  =/  k=(list [aor=? ascending=? offset=@ud])  index
  |-  ^-  ?
  ?~  k  %.n
  =/  pp=(list @)
    ?:  =(0 ->+.k)  p                      ::offset of current index
    (oust [0 ->+.k] p)
  =/  qq=(list @)
    ?:  =(0 ->+.k)  q                      ::offset of current index
    (oust [0 ->+.k] q)
  ?:  =(-.pp -.qq)  $(k +.k)
  ?:  =(-<.k %.y)  (aor -.pp -.qq)
  ?:  ->-.k  (lth -.pp -.qq)
  (gth -.pp -.qq)
  --
++  make-ordering
  |=  [columns=(list column:ast) order=*]
  ^-  (list column-order)
  =/  out=(list column-order)  ~
  |-
  ?~  order  (flop out)
  ~|  "bad order column:  {<-.order>} ..."
  ?>  ?=(ordering-column:ast -.order)
  =/  ordering=ordering-column:ast  `ordering-column:ast`-.order                          
  =/  order-column  column.ordering
  =/  col-i=(unit [@ @ta])
        ?:  ?=(qualified-column:ast order-column)
          (try-find-col-index columns column.order-column)
        ~|("order column error:  {<order-column>}" !!)
  ?~  col-i  $(order +.order)
  =/  offset-type  (need col-i)
  %=  $
    order  +.order
    out    
      ?:  ?|(=(~.t +.offset-type) =(~.ta +.offset-type) =(~.tas +.offset-type))
        [[%.y ascending.ordering -.offset-type] out]
      [[%.n ascending.ordering -.offset-type] out]
  ==
++  try-find-col-index
  |=  [a=(list column:ast) name=@tas]
  =/  i  0
  |-  ^-  (unit [@ @ta])
  ?~  a  ~
  ?:  =(name name.i.a)  `[i type.i.a]
  $(a t.a, i +(i))
::
::  +make-rows: [(list (list @)) (lest column)] -> (list row)
++  make-rows
    |=  [data=(list (list @)) columns=(lest column:ast)]
    ^-  (list row)
    =/  rows=(list row)  ~
    |-
    ?~  data  (flop rows)
    =/  in-row  i.data
    =/  out-row=(list cell)  ~
    =/  cols=(list column:ast)  columns
        |-
        ?~  in-row  ^$(data t.data, rows [(row %row (flop out-row)) rows])
        ?~  cols  ~|("can't get here" !!)
        %=  $
          out-row  [(cell name.i.cols [p=type.i.cols q=i.in-row]) out-row]
          cols  t.cols
          in-row  t.in-row
        ==  
--
