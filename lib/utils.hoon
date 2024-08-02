/-  ast, *obelisk
|%
::
++  map-insert
  |*  [m=(map) key=* value=*]
  ^+  m
  ?:  (~(has by m) key)  ~|("duplicate key: {<key>}" !!)
  (~(put by m) key value)
::
++  map-delete
  |*  [m=(map) key=*]
  ^+  m
  ?:  (~(has by m) key)  (~(del by m) key)
  ~|("deletion key does not exist: {<key>}" !!)
::
::  +idx-comp
::
::  comparator for index mops
++  idx-comp
  |_  index=(list [@tas ascending=?])
  ++  order
    |=  [p=(list @) q=(list @)]
    =/  k=(list [@tas ascending=?])  index
    |-  ^-  ?
    ?:  =(-.p -.q)  $(k +.k, p +.p, q +.q)
    ?:  =(-<.k %t)  (aor -.q -.p)
    ?:  ->.k  (gth -.p -.q)
    (lth -.p -.q)
  --
::
++  pri-key
  |=  key=(list [@tas ?])
        ((on (list [@tas ?]) (map @tas @)) ~(order idx-comp key))
::
::  gets the schema with matching or next subsequent time
++  schema-key  ((on @da schema) gth)
++  get-schema
    |=  [sys=((mop @da schema) gth) time=@da]
    ^-  schema
    =/  time-key  (add time 1)
    ~|  "schema not available for {<time>}"
    ->:(pop:schema-key (lot:schema-key sys `time-key ~))
::
::  +get-next-schema
::  gets the schema with the highest timestamp for mutation
::  if schema is already mutated
::    then sys-time may = tmsp.schema  !!!!!!
::  else sys-time must be > tmsp.schema
++  get-next-schema
  |=  $:  sys=((mop @da schema) gth)
          next-schemas=(map @tas @da)
          sys-time=@da
          db-name=@tas
      ==
  ^-  schema
  =/  nxt-schema=schema  +:(need (pry:schema-key sys))
  ?:  (lth sys-time tmsp.nxt-schema)  !!
  ?:  =(tmsp.nxt-schema sys-time)
    ?:  =((~(got by next-schemas) db-name) sys-time)  nxt-schema
    !!
  nxt-schema
::
::  gets the data with matching or highest timestamp prior to
++  data-key    ((on @da data) gth)
++  get-data
  |=  [sys=((mop @da data) gth) time=@da]
  ^-  data
  =/  exact  (get:data-key sys time)
  ?^  exact  (need exact)
  =/  prior  (pry:data-key (lot:data-key sys `time ~))
  ?~  prior  ~|("data not available for {<time>}" !!)
  +:(need prior)
::
::  gets the data with the highest timestamp for mutation
++  get-next-data
  |=  $:  content=((mop @da data) gth)
          next-data=(map @tas @da)
          sys-time=@da
          db-name=@tas
      ==
  ^-  data
  =/  nxt-data=data  +:(need (pry:data-key content))
  ?:  (lth sys-time tmsp.nxt-data)  !!
  ?:  =(tmsp.nxt-data sys-time)
    ?:  =((~(got by next-data) db-name) sys-time)  nxt-data
    !!
  nxt-data
::
::  +  get-view:  [data-obj-key views] -> (unit view)
::
::  get view with current or most recent previous time
::
::  because ns-obj-comp orders on gth, tab logic requires +1 to include
::  exact match
++  view-key  ((on data-obj-key view) ns-obj-comp)
++  get-view
  |=  [key=data-obj-key =views]
  ^-  (unit view)
  ~|  "view {<ns.key>}.{<obj.key>} does not exist for time {<time.key>}"
  =/  vw  (tab:view-key views `[ns.key obj.key `@da`(add `@`time.key 1)] 1)
  ?~  vw  ~
  `->.vw
::
++  view-cache-key  ((on data-obj-key cache) ns-obj-comp)
++  get-view-cache
  |=  [key=data-obj-key q=((mop data-obj-key cache) ns-obj-comp)]
  ^-  (unit cache)
  ~|  "view {<ns.key>}.{<obj.key>} does not exist for time {<time.key>}"
  =/  vw  (tab:view-cache-key q `[ns.key obj.key `@da`(add `@`time.key 1)] 1)
  ?~  vw  ~
  `->.vw
::
::  +put-view-cache
++  put-view-cache
  |=  [db=database value=cache key=data-obj-key]
  ^-  database
  db(view-cache (~(put by view-cache.db) key value))
::
::  +get-content:  [((mop @da data) gth) @da [@tas @tas]] -> file
++  content-key  ((on @da data) gth)
++  get-content
  |=  [content=((mop @da data) gth) sys-time=@da tbl-key=[@tas @tas]]
  ^-  file
  ~|  "data for {<tbl-key>} does not exist for time {<sys-time>}"
  =/  d=data  ->:(tab:content-key content ``@da`(add `@`sys-time 1) 1)
  (~(got by files.d) tbl-key)
::
::  +select-columns:  [(list (map @tas @)) (list selected-column:ast)]
::                    -> (list (map @tas @))
++  select-columns
  |=  [rows=(list (map @tas @)) cells=(list foo-cell)]
  ~+  ^-  (list vector)
  =/  out-rows=(list vector)  ~
  |-
  ?~  rows  out-rows
  ::
  =/  row=(list vector-cell)  ~
  =/  cols=(list foo-cell)  cells
  |-
  ?~  cols
      ?~  out-rows  %=  ^$
                      out-rows  [(vector %vector row) out-rows]
                      rows      t.rows
                    ==
      ?:  =(-.out-rows (vector %vector row))  ^$(rows t.rows)
      %=  ^$
        out-rows  [(vector %vector row) out-rows]
        rows      t.rows
      ==
  ::
  ?.  is-column.i.cols
    $(cols t.cols, row [vc.i.cols row])
  =/  cell=foo-cell  i.cols
  %=  $
    cols  t.cols
    row   [[-.vc.cell [+<.vc.cell (~(got by i.rows) column-name.cell)]] row]
  ==
::
::  +heading:  [=selected-column:ast @tas] -> @tas
::
::  aliases may be mixed case
++  heading
  |=  [=selected-column:ast default=@tas]
  ^-  @tas
  ?:  ?=(qualified-column:ast selected-column)
    ?~  alias.selected-column  default
        (crip (cass (trip (need alias.selected-column))))
  ?:  ?=(selected-value:ast selected-column)
    ?~  alias.selected-column  default
        (crip (cass (trip (need alias.selected-column))))
  ~|("{<selected-column>} not supported" !!)
::
::  +order:  [(list @) (list @)] -> ?
::
::  Currently orders rows inversely so +select-columns is not required to flop
::  its output
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
  ?:  =(-<.k %.y)  (aor -.qq -.pp)  ::(aor -.pp -.qq)
  ?:  ->-.k  (gth -.pp -.qq)        ::(lth -.pp -.qq)
  (lth -.pp -.qq)                   ::(gth -.pp -.qq)
  --
::
::  +make-ordering:  [(list column:ast) *] -> (list column-order)
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
::
::    +make-index-key:  [(map @tas [@tas @ud]) (list ordered-column:ast)]
::                      -> (list [@tas ?])
++  make-index-key
  |=  [column-lookup=(map @tas [@tas @ud]) pri-indx=(list ordered-column:ast)]
  ^-  (list [@tas ?])
  =/  a=(list [@tas ?])  ~
  |-
  ?~  pri-indx  (flop a)
  =/  b=ordered-column:ast  -.pri-indx
  =/  col  (~(got by column-lookup) name.b)
  %=  $
    pri-indx  +.pri-indx
    a  [[-.col ascending.b] a]
  ==
::
++  try-find-col-index
  |=  [a=(list column:ast) name=@tas]
  =/  i  0
  |-  ^-  (unit [@ @ta])
  ?~  a  ~
  ?:  =(name name.i.a)  `[i type.i.a]
  $(a t.a, i +(i))
::
::  +atoms-2-mapped-row:  [(list (list @)) (list column:ast)]
::                        -> (list (map @tas @))
++  atoms-2-mapped-row
  |=  [p=(list (list @)) q=(list column:ast)]
  ^-  [@ (list (map @tas @))]
  =/  rows=(list (map @tas @))  ~
  =/  i  0
  |-
  ?~  p  [i (flop rows)]
  $(i +(i), p +.p, rows [(malt (zip-columns -.p q)) rows])
::
::  +zip-columns: [(list @) (list column:ast)] -> (list [@tas @])
++  zip-columns
  |*  [a=(list @) b=(list column:ast)]
  ^-  (list [@tas @])
  =/  c=(list [@tas @])  ~
  |-
  ?~  a  ?~  b  c  ~|('column lists of unequal length' !!)
  ?~  b  ~|('column lists of unequal length' !!)
  $(a +.a, b +.b, c [[name.i.b -.a] c])
::

::  +make-col-lu-data:  [=column:ast a=@] -> [[@tas [@tas @ud]] @ud]
++  make-col-lu-data
    |=  [=column:ast a=@]
    ^-  [[@tas [@tas @ud]] @ud]
    [[name.column [type.column a]] +(a)]
::
::  +mk-vect-templ: (list column:ast) -> (list vector-cell)
::
::  leave output un-flopped so consuming arm does not flop
++  foo
  |=  a=column:ast
  ^-  foo-cell
  (foo-cell %foo-cell name.a %.y `vector-cell`[name.a [type.a 0]])
++  mk-vect-templ
  |=  [cols=(list column:ast) selected=(list selected-column:ast)]
  ^-  (list foo-cell)
  =/  i  0
  =/  col-lookup=(map @tas @ta)
        (~(gas by `(map @tas @ta)`~) (turn cols |=(a=[@tas [@tas @ta]] +.a)))
  =/  cells=(list foo-cell)  ~
  |-
  ?~  selected  ?~  cells  ~|("no cells" !!)  cells
  ?:  =([%all %all] i.selected)
    %=  $
      i         +(i)
      selected  t.selected
      cells     (weld (flop (turn cols foo)) cells)
    ==
  ?:  ?=(qualified-column:ast i.selected)
    ?:  =('ALL' column.i.selected)  :: name = table name
      %=  $
        i         +(i)
        selected  t.selected
        cells     (weld (flop (turn cols foo)) cells)
      ==
    %=  $
      i         +(i)
      selected  t.selected
      cells     :-
                  %:  foo-cell  %foo-cell
                                column.i.selected
                                %.y
                                :-  (heading i.selected column.i.selected)
                                    [(~(got by col-lookup) column.i.selected) 0]
                                ==
                    cells
    ==
  ?:  ?=(selected-value:ast i.selected)
    %=  $
      i         +(i)
      selected  t.selected
      cells  [(foo-cell %foo-cell %foo %.n [(heading i.selected (crip "literal-{<i>}")) [p=+<-.i.selected q=+<+.i.selected]]) cells]
    ==
  ~|("{<i.selected>} not supported" !!)
::
::    +set-tmsp: [(unit as-of:ast) @da] -> @da
++  set-tmsp
  |=  [p=(unit as-of:ast) q=@da]
  ^-  @da
  ?~  p  q
  =/  as-of=as-of:ast  (need p)
  ?:  ?=([%da @] as-of)  +.as-of
  ?:  ?=([%dr @] as-of)  (sub q +.as-of)
  ?-  units.as-of
    %seconds
      (sub q `@dr`(yule `tarp`[0 0 0 offset:as-of ~]))
    %minutes
      (sub q `@dr`(yule `tarp`[0 0 offset:as-of 0 ~]))
    %hours
      (sub q `@dr`(yule `tarp`[0 offset:as-of 0 0 ~]))
    %days
      (sub q `@dr`(yule `tarp`[offset:as-of 0 0 0 ~]))
    %weeks
      (sub q `@dr`(yule `tarp`[(mul offset:as-of 7) 0 0 0 ~]))
    %months
      =/  foo    (yore q)
      =/  years  (div offset:as-of 12)
      =/  months  (sub offset:as-of (mul years 12))
      ?:  =(m.foo months)
        %-  year  :+  [a=%.y y=(sub y.foo (add years 1))]
                      m=12
                      t=[d=d.t.foo h=h.t.foo m=m.t.foo s=s.t.foo f=f.t.foo]
      ?:  (gth m.foo months)
        %-  year  :+  [a=%.y y=(sub y.foo years)]
                      m=(sub m.foo months)
                      t=[d=d.t.foo h=h.t.foo m=m.t.foo s=s.t.foo f=f.t.foo]
      %-  year  :+  [a=%.y y=(sub y.foo (add years 1))]
                    m=(sub (add m.foo 12) months)
                    t=[d=d.t.foo h=h.t.foo m=m.t.foo s=s.t.foo f=f.t.foo]
    %years
      =/  foo  (yore q)
      %-  year  :+  [a=%.y y=(sub y.foo offset:as-of)]
                    m=m.foo
                    t=[d=d.t.foo h=h.t.foo m=m.t.foo s=s.t.foo f=f.t.foo]
  ==
::
::    +to-column: [@t (map @tas [aura @])] -> column:ast
++  to-column
  |=  [p=@t q=(map @tas [aura @])]
  ^-  column:ast
  ~|  "insert invalid column: {<p>}"
  (column:ast %column p -:(~(got by q) p))
::
::  +upd-indices-views:  [databases qualified-object @da =views] -> databases
::
::  post- insert, update, delete, truncate procedure to create new view
::  and index instances for effected tables
::  =views passes effected sys views
++  upd-indices-views
  |=  $:  state=databases
          sys-time=@da
          objs=(list qualified-object:ast)
          sys-vws=(list [@tas @tas])
          ==
  ^-  databases
  :: to do: iterate through objects
  state
::
::  +upd-view-caches:  [databases database @da (unit (list [@tas @tas])) db-cmd]
::                     -> databases
++  upd-view-caches
  |=  $:  state=databases
          db=database
          sys-time=@da
          sys-vws=(unit (list [@tas @tas]))
          caller=db-cmd
          ==
  ^-  databases
  ?-  caller
    %create-database
      %:  upd-view-caches-db
            state
            db
            sys-time
            ~
            ==
    %drop-database
      !!
    %create-namespace
      %:  upd-view-caches-db
            state
            db
            sys-time
            ~[[%sys %namespaces]]
            ==
    %alter-namespace
      !!
    %drop-namespace
      !!
    %create-table
      =/  sys-db  (~(got by state) %sys)
      %:  upd-view-caches-db
            %:  upd-view-caches-db
                  state
                  db
                  sys-time
                  :~  [%sys %tables]
                      [%sys %columns]
                      [%sys %sys-log]
                      [%sys %data-log]
                      ==
                  ==
            sys-db
            sys-time
            ~[[%sys %databases]]
            ==
    %alter-table
      !!
    %drop-table
      =/  sys-db  (~(got by state) %sys)
      %:  upd-view-caches-db
            %:  upd-view-caches-db
                  state
                  db
                  sys-time
                  :~  [%sys %tables]
                      [%sys %columns]
                      [%sys %sys-log]
                      [%sys %data-log]
                      ==
                  ==
            sys-db
            sys-time
            ~[[%sys %databases]]
            ==
    %truncate-table
      =/  sys-db  (~(got by state) %sys)
      %:  upd-view-caches-db
            %:  upd-view-caches-db
                  state
                  db
                  sys-time
                  ~[[%sys %tables] [%sys %data-log]]
                  ==
            sys-db
            sys-time
            ~[[%sys %databases]]
            ==
    %insert
      =/  sys-db  (~(got by state) %sys)
      %:  upd-view-caches-db
            %:  upd-view-caches-db
                  state
                  db
                  sys-time
                  (weld (limo ~[[%sys %tables] [%sys %data-log]]) (need sys-vws))
                  ==
            sys-db
            sys-time
            ~[[%sys %databases]]
            ==
    %update
      !!
    %delete
      !!
  ==
::
++  upd-view-caches-db
  |=  $:  state=databases
          db=database
          sys-time=@da
          sys-vws=(list [@tas @tas])
          ==
  ^-  databases
  %+  ~(put by state)
    name.db
    %=  db
        view-cache
          %+  gas:view-cache-key
              view-cache.db
              %+  turn
                  sys-vws
            |=([p=[@tas @tas]] [[-.p +.p sys-time] (cache %cache sys-time ~)])
          ==
::
++  key-atom
  |=  a=[p=@tas q=(map @tas @)]
  ^-  @
  ~|  "key atom {<p.a>} not supported"
  (~(got by q.a) p.a)
::
++  update-file
  |=  [=file =data tbl-key=[@tas @tas] primary-key=(list [@tas ?])]
  =.  rows.file  %+  turn  (tap:(pri-key primary-key) pri-idx.file)
                            |=(a=[* (map @tas @)] +.a)
  =.  files.data  (~(put by files.data) tbl-key file)
  data
::
++  row-cells
  |=  [p=(list value-or-default:ast) q=(list column:ast)]
  ^-  (map @tas @)
  =/  cells=(list [@tas @])  ~
  |-
  ?~  p  (malt cells)
  %=  $
    cells  [(row-cell -.p -.q) cells]
    p  +.p
    q  +.q
  ==
::
++  row-cell
  |=  [p=value-or-default:ast q=column:ast]
  ^-  [@tas @]
  ?:  ?=(dime p)
    ?:  =(%default p.p)
      ?:  =(%da type.q)  [name.q *@da]                :: default to bunt
      [name.q 0]
    ?:  =(p.p type.q)  [name.q q.p]
    ~|  "type of column {<-.q>} {<+<.q>} ".
        "does not match input value type {<p.p>}"
        !!
  ~|("row cell {<p>} not supported" !!)
::
++  make-key-pick
  |=  [key=@tas column-lookup=(map @tas [aura @])]
  ^-  [@tas @]
  [key +:(~(got by column-lookup) key)]
::
++  rdc-set-func
  |=  =(tree set-function:ast)
  ?~  tree  ~
  ::  template
  ?~  l.tree
    ?~  r.tree  [n.tree ~ ~]
    [n.r.tree ~ ~]
  ?~  r.tree  [n.l.tree ~ ~]
  [n.r.tree ~ ~]
::
++  of                              ::  tree engine
  =|  a=(tree)
  |@
  ++  rep                           ::  reduce to product
    |*  b=_=>(~ |=([* *] +<+))
    |-
    ?~  a  +<+.b
    $(a r.a, +<+.b $(a l.a, +<+.b (b n.a +<+.b)))
  ++  rdc                           ::  reduce tree
    |*  b=gate
    |-
    ?:  ?=([* ~ ~] a)              a
    ?:  ?=([* [* ~ ~] [* ~ ~]] a)  $(a (b a))
    ?:  ?=([* ~ [* ~ ~]] a)        $(a (b a))
    ?:  ?=([* [* ~ ~] ~] a)        $(a (b a))
    ?:  ?=([* * ~] a)              $(a [n=n.a l=$(a l.a) r=~])
    ?:  ?=([* ~ *] a)              $(a [n=n.a l=~ r=$(a r.a)])
    ?:  ?=([* * *] a)              $(a [n=n.a l=$(a l.a) r=$(a r.a)])
    ~
  --
::
++  name-set
  |*  a=(set)
  ^-  (set @tas)
  (~(run in a) |=(b=* ?@(b !! ?@(+<.b +<.b !!))))
::
::  helper types
::
+$  db-cmd  $?  %create-database
                %drop-database
                %create-namespace
                %alter-namespace
                %drop-namespace
                %create-table
                %alter-table
                %drop-table
                %truncate-table
                %insert
                %update
                %delete
                ==
::
+$  foo-cell
  $:  %foo-cell
      column-name=@tas
      is-column=?
      vc=vector-cell
  ==
::
::  experimental code follows
::
++  fuse                        :: credit to ~paldev
  |*  [a=(list) b=(list)]       :: [(list a) (list b)] -> (list [a b])
  ^-  (list [_?>(?=(^ a) i.a) _?>(?=(^ b) i.b)])
  ?~  a  ~
  ?~  b  ~
  :-  [i.a i.b]
  $(a t.a, b t.b)
::
::
++  by2
  =|  a=(tree (pair * [* *]))  ::  (map)
  |@
  ++  uni2
    |*  b=_a
    |-  ^+  a
    ?~  b  a
    ?~  a  b
    ?:  =(p.n.b p.n.a)
        b(n [p.n.b [-.q.n.a +.q.n.b]], l $(a l.a, b l.b), r $(a r.a, b r.b))
    ?:  (mor p.n.a p.n.b)
      ?:  (gor p.n.b p.n.a)
        $(l.a $(a l.a, r.b ~), b r.b)
      $(r.a $(a r.a, l.b ~), b l.b)
    ?:  (gor p.n.a p.n.b)
      $(l.b $(b l.b, r.a ~), a r.a)
    $(r.b $(b r.b, l.a ~), a l.a)
  ++  int2                                               ::  intersection
    |*  b=_a
    |-  ^+  a
    ?~  b  ~
    ?~  a  ~
    ?:  (mor p.n.a p.n.b)
      ?:  =(p.n.b p.n.a)
        b(n [p.n.b [-.q.n.a +.q.n.b]], l $(a l.a, b l.b), r $(a r.a, b r.b))
      ?:  (gor p.n.b p.n.a)
        %-  uni2(a $(a l.a, r.b ~))  $(b r.b)
      %-  uni2(a $(a r.a, l.b ~))  $(b l.b)
    ?:  =(p.n.a p.n.b)
      b(l $(b l.b, a l.a), r $(b r.b, a r.a))
    ?:  (gor p.n.a p.n.b)
      %-  uni2(a $(b l.b, r.a ~))  $(a r.a)
    %-  uni2(a $(b r.b, l.a ~))  $(a l.a)
    --
--
