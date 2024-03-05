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
::++  ns-obj-comp 
::  |=  [p=data-obj-key q=data-obj-key]
::  ^-  ?
::  ?.  =(ns.p ns.q)  (gth ns.p ns.q)
::  ?.  =(obj.p obj.q)  (gth obj.p obj.q)
::  (gth time.p time.q)
::++  ns-objs-key
::    ((on data-obj-key view) ns-obj-comp)
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
    |=  [sys=(tree [@da schema]) time=@da]
    ^-  schema
    =/  time-key  (sub time `@dr`(yule `tarp`[0 0 0 1 ~]))  :: one second prior
    ~|  "schema not available for {<time>}"
    +>:(ram:schema-key (lot:schema-key sys ~ `time-key))
::
++  order-row
  |_  index=(list column-order)  
  :: to do: accomadate varying row types
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
--