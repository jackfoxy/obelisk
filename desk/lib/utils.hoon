/-  ast, *obelisk
|%
::
::  +license:  MIT+n license
++  license
  ^-  @  %-  crip
  "Original Copyright 2024 Jack Fox".
  " ".
  "Permission is hereby granted, free of charge, to any person obtaining a ".
  "copy of this software and associated documentation files ".
  "(the \"Software\"), to deal in the Software without restriction, ".
  "including without limitation the rights to use, copy, modify, merge, ".
  "publish, distribute, sublicense, and/or sell copies of the Software, ".
  "and to permit persons to whom the Software is furnished to do so, ".
  "subject to the following conditions: ".
  " ".
  "The above original copyright notice, this permission notice and the words".
  " ".
  "\"I AM - CHRIST LIVES - SATAN BE GONE\"".
  "  ".
  "shall be included in all copies or substantial portions of the Software, ".
  "as well as the story".
  " ".
  "\"Jesus was crucified for exposing the corruption of the ruling class and ".
  "their rulers, the bankers\"".
  ",".
  " all unaltered.".
  " ".
  "THE SOFTWARE IS PROVIDED \"AS IS\", WITHOUT WARRANTY OF ANY KIND, ".
  "EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF ".
  "MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. ".
  "IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM,".
  " DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR ".
  "OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE ".
  "USE OR OTHER DEALINGS IN THE SOFTWARE."

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
  |_  index=(list [@tas ?])
  ++  order
    |=  [p=(list @) q=(list @)]
    =/  k=(list [@tas ?])  index
    |-  ^-  ?
    ?:  =(-.p -.q)  $(k +.k, p +.p, q +.q)
    ?:  =(-<.k %t)  (alpha -.q -.p)
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
  =/  vw  (tab:view-key views `[ns.key obj.key `@da`(add `@`time.key 1)] 1)
  ?~  vw  ~
  =/  returned-key=data-obj-key  -<.vw
  ?:  &(=(ns.returned-key ns.key) =(obj.returned-key obj.key))  `->.vw
  ~
::
::  +get-view-cache:  [data-obj-key ((mop data-obj-key cache) ns-obj-comp)]
::                    -> (unit cache)
++  view-cache-key  ((on data-obj-key cache) ns-obj-comp)
++  get-view-cache
  |=  [key=data-obj-key q=((mop data-obj-key cache) ns-obj-comp)]
  ^-  cache
  =/  vw  (tab:view-cache-key q `[ns.key obj.key `@da`(add `@`time.key 1)] 1)
  ?~  vw
    ~|("view {<ns.key>}.{<obj.key>} does not exist from time {<time.key>}" !!)
  ->.vw
::
::  +put-view-cache
++  put-view-cache
  |=  [db=database value=cache key=data-obj-key]
  ^-  database
  =/  gate  put:((on data-obj-key cache) ns-obj-comp)
  db(view-cache (gate view-cache.db [key value]))
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
::  +is-content-populated:  [database @da] -> ?
++  is-content-populated
  |=  [=database sys-time=@da]
  ^-  ?
  =/  content  (tab:content-key content.database ``@da`(add `@`sys-time 1) 1)
  ?~  content  %.n
  =/  d=data  ->.content
  %^  fold  ~(tap by files.d)
            `?`%.n
            |=([[* =file] state=?] ?:(=(0 rowcount.file) state %.y))
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
  ?:  =(-<.k %.y)  (alpha -.qq -.pp)
  ?:  ->-.k  (gth -.pp -.qq)
  (lth -.pp -.qq)
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
::  +from-obj-meta: (list from-obj) -> (list result)
++  from-obj-meta
  |=  a=(list from-obj)
  ^-  (list result)
  =/  m=(list (list result))  ~
  ::
  |-
  ?~  a  (zing (flop m))
  =/  obj=from-obj  -.a
  %=  $
    a  t.a
    m  :-
        :~  `result`[%message (qualified-object-to-cord object.obj)]
            `result`[%schema-time schema-tmsp.obj]
            `result`[%data-time data-tmsp.obj]
            ==
        m
  ==
::
++  qualified-object-to-cord
  |=  a=qualified-object:ast
  ^-  @t
  =/  b  %-  zing  :~  (trip database.a)
                       "."
                       (trip namespace.a)
                       "."
                       (trip name.a)
                       ==
  ?~  ship.a  (crip b)
  %-  crip  %-  zing  :~  (trip (need ship.a))
                          "."
                          (trip name.a)
                          ==
::
::  +make-col-lu-data:  [=column:ast a=@] -> [[@tas [@tas @ud]] @ud]
++  make-col-lu-data
    |=  [=column:ast a=@]
    ^-  [[@tas [@tas @ud]] @ud]
    [[name.column [type.column a]] +(a)]
::
::  +mk-vect-templ: [(list column:ast) (list selected-column:ast)]
::                  -> (list templ-cell)
::
::  leave output un-flopped so consuming arm does not flop
++  mk-templ-cell
  |=  a=column:ast
  ^-  templ-cell
  (templ-cell %templ-cell `name.a `vector-cell`[name.a [type.a 0]])
++  mk-vect-templ
  |=  [cols=(list column:ast) selected=(list selected-column:ast)]
  ^-  (list templ-cell)
  =/  i  0
  =/  col-lookup=(map @tas @ta)
        (~(gas by `(map @tas @ta)`~) (turn cols |=(a=[@tas [@tas @ta]] +.a)))
  =/  cells=(list templ-cell)  ~
  |-
  ?~  selected  ?~  cells  ~|("no cells" !!)  cells
  ?:  =([%all %all] i.selected)
    %=  $
      i         +(i)
      selected  t.selected
      cells     (weld (flop (turn cols mk-templ-cell)) cells)
    ==
  ?:  ?=(qualified-column:ast i.selected)

    ?:  ?&  =('UNKNOWN' database.qualifier.i.selected)
            =('COLUMN-OR-CTE' namespace.qualifier.i.selected)
            !(~(has by col-lookup) name.qualifier.i.selected)
            ==
      %=  $
        i         +(i)
        selected  t.selected
        cells     (weld (flop (turn cols mk-templ-cell)) cells)
      ==

    %=  $
      i         +(i)
      selected  t.selected
      cells
            ~|  "SELECT: column {<column.i.selected>} not found"  
            :-
              %:  templ-cell  %templ-cell
                            [~ column.i.selected]
                            :-  (heading i.selected column.i.selected)
                                [(~(got by col-lookup) column.i.selected) 0]
                            ==
                cells
    ==
  ?:  ?=(selected-all-object:ast i.selected)
    %=  $
      i         +(i)
      selected  t.selected
      cells     (weld (flop (turn cols mk-templ-cell)) cells)
    ==
  ?:  ?=(selected-value:ast i.selected)
    %=  $
      i         +(i)
      selected  t.selected
      cells     
        :-  %:  templ-cell  %templ-cell
                            ~
                            :-  (heading i.selected (crip "literal-{<i>}"))
                                [p=+<-.i.selected q=+<+.i.selected]
                            ==
            cells
    ==
  ~|("{<i.selected>} not supported" !!)
::
::  +mk-vect-templ-2:
::    [(list [qualified-object:ast @ta]) (list selected-column:ast)]
::    -> (list templ-cell-2)
::
::  leave output un-flopped so consuming arm does not flop
++  mk-templ-cell-2
  |=  a=[qualified-column:ast @ta]
  ^-  templ-cell-2
  (templ-cell-2 %templ-cell-2 `-.a `vector-cell`[column.-.a [+.a 0]])
++  mk-vect-templ-2
  |=  $:  cols=(list [qualified-column:ast @ta])
          selected=(list selected-column:ast)
          ==
  ^-  (list templ-cell-2)
  =/  i  0
  =/  col-lookup=(map qualified-column:ast @ta)
        (~(gas by `(map qualified-column:ast @ta)`~) cols)
  =/  cells=(list templ-cell-2)  ~
  =.  selected  (fix-for-infer cols selected)
  ::
  |-
  ?~  selected  ?~  cells  ~|("no cells" !!)  cells
  ?:  =([%all %all] i.selected)
    %=  $
      i         +(i)
      selected  t.selected
      cells     (weld (flop (turn cols mk-templ-cell-2)) cells)
    ==
  ?:  ?=(qualified-column:ast i.selected)
    %=  $
      i         +(i)
      selected  t.selected
      cells  ~|  "SELECT: column {<column.i.selected>} not found"  
             :-
               %:  templ-cell-2
                     %templ-cell-2
                     [~ i.selected]
                     :-  (heading i.selected column.i.selected)
                         [(~(got by col-lookup) i.selected) 0]
                     ==
               cells
    ==
  ?:  ?=(selected-all-object:ast i.selected)
    %=  $
      i         +(i)
      selected  t.selected   :: to do: filter on table
      cells     
        %+  weld
          %-  flop
            %+  turn
              (skim cols |=(a=[qualified-column:ast @ta] =(->-.a +.i.selected)))
              mk-templ-cell-2
          cells
    ==
  ?:  ?=(selected-value:ast i.selected)
    %=  $
      i         +(i)
      selected  t.selected
      cells
        :-  %:  templ-cell-2  %templ-cell-2
                              ~
                              :-  (heading i.selected (crip "literal-{<i>}"))
                                  [p=+<-.i.selected q=+<+.i.selected]
                              ==
            cells
    ==
  ~|("{<i.selected>} not supported" !!)
::
++  fix-for-infer
  |=  $:  cols=(list [qualified-column:ast @ta])
          selected=(list selected-column:ast)
          ==
  ^-  (list selected-column:ast)
  =/  object-lookup=(map @tas (list qualified-object:ast))  ~
  =/  selected-out=(list selected-column:ast)  ~
  |-
  ?~  selected  (flop selected-out)
  ?.  ?=(qualified-column:ast -.selected)
    %=  $
      selected      +.selected
      selected-out  [-.selected selected-out]
    ==
  =/  col=qualified-column:ast  `qualified-column:ast`-.selected
  ?:  ?&  =('UNKNOWN' database.qualifier.col)
            =('COLUMN-OR-CTE' namespace.qualifier.col)
            ==
          ?~  object-lookup  $(object-lookup (mk-object-lookup cols))
          %=  $
            selected      +.selected
            selected-out  :-  ^-  selected-column:ast
                              %+  from-infer-objects  object-lookup
                                                      name.qualifier.col
                              selected-out
          ==
  %=  $
    selected      +.selected
    selected-out  [`selected-column:ast`col selected-out]
  ==
::
++  from-infer-objects
  |=  [object-lookup=(map @tas (list qualified-object:ast)) name=@tas]
  ^-  qualified-column:ast
  ?.  (~(has by object-lookup) name)  ~|("SELECT: column {<name>} not found" !!)
  =/  objects=(list qualified-object:ast)  (~(got by object-lookup) name)
  ?:  (gth (lent objects) 1)  ~|("SELECT: column {<name>} must be qualified" !!)
  (qualified-column:ast %qualified-column -.objects name ~)
::
++  mk-object-lookup
  |=  cols=(list [qualified-column:ast @ta])
  ^-  (map @tas (list qualified-object:ast))
  =/  object-lookup=(map @tas (list qualified-object:ast))  ~
  |-
  ?~  cols  object-lookup
  =/  column=qualified-column:ast  -<.cols
  %=  $
    cols  +.cols
    object-lookup  ?.  (~(has by object-lookup) column.column)
                     (~(put by object-lookup) column.column ~[qualifier.column])
                   =/  objects=(list qualified-object:ast)
                        (~(got by object-lookup) column.column)
                   %+  ~(put by object-lookup)  column.column
                                                [qualifier.column objects]
  ==
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
  ~|  "INSERT: invalid column: {<p>}"
  (column:ast %column p -:(~(got by q) p))
::
::  +upd-indices-views:  [server qualified-object @da =views] -> server
::
::  post- insert, update, delete, truncate procedure to create new view
::  and index instances for effected tables
::  =views passes effected sys views
++  upd-indices-views    :: to do: revisit when there are views & indices
  |=  $:  state=server
          sys-time=@da
          objs=(list qualified-object:ast)
          sys-vws=(list [@tas @tas])
          ==
  ^-  server
  :: to do: iterate through objects
  state
::
::  +update-sys:  [server @da] -> server
++  update-sys
  |=  [state=server sys-time=@da]
  ^-  server
  =/  sys-db  (~(got by state) %sys)     
  =.  view-cache.sys-db
        (upd-view-caches state sys-db sys-time ~ %create-database)
  (~(put by state) %sys sys-db)
::
::  +upd-view-caches:  [server database @da (unit (list [@tas @tas])) db-cmd]
::                     -> server
::
::  state needed for cross-db view changes
++  upd-view-caches
  |=  $:  state=server      
          db=database
          sys-time=@da
          sys-vws=(unit (list [@tas @tas]))
          caller=db-cmd
          ==
  ^-  view-cache
  ?-  caller
    %create-database
      (next-view-cache-keys db sys-time ~[[%sys %databases]])
    %drop-database
      ~|("%drop-database should implement %create-database caller" !!)
    %create-namespace
      (next-view-cache-keys db sys-time ~[[%sys %namespaces]])
    %alter-namespace
      ~|("%alter-namespace not implemented" !!)
    %drop-namespace
      ~|("%drop-namespace not implemented" !!)
    %create-table
      %^  next-view-cache-keys  db
                              sys-time
                              :~  [%sys %tables]
                                  [%sys %columns]
                                  [%sys %sys-log]
                                  [%sys %data-log]
                                  ==
    %alter-table
      ~|("%alter-table not implemented" !!)
    %drop-table
      %^  next-view-cache-keys  db
                              sys-time
                              :~  [%sys %tables]
                                  [%sys %columns]
                                  [%sys %sys-log]
                                  [%sys %data-log]
                                  ==
    %truncate-table
      (next-view-cache-keys db sys-time ~[[%sys %tables] [%sys %data-log]])
    %insert
      %^  next-view-cache-keys
                            db
                            sys-time
                            %+  weld  (limo ~[[%sys %tables] [%sys %data-log]])
                                      (need sys-vws)
    %update
      ~|("%update not implemented" !!)
    %delete
      ~|("%delete not implemented" !!)
  ==
::
::  +next-view-cache-keys:  [database @da (list [@tas @tas])] -> view-cache
++  next-view-cache-keys
  |=  [db=database sys-time=@da sys-vws=(list [@tas @tas])]
  ^-  view-cache
  %+  gas:view-cache-key
        view-cache.db
        %+  turn  sys-vws
              |=([p=[@tas @tas]] [[-.p +.p sys-time] (cache %cache sys-time ~)])
::
::    +fold: [(list T1) state:T2 folder:$-([T1 T2] T2)] -> T2
::
::  Applies a function to each element of the list, threading an
::  accumulator argument through the computation. Take the second argument, and
::  apply the function to it and the first element of the list. Then feed this
::  result into the function along with the second element and so on. Return the
::  final result. If the input function is f and the elements are i0...iN then
::  computes f (... (f s i0) i1 ...) iN.
::    Examples
::      > (fold (gulf 1 5) 0 |=([n=@ state=@] (add state (mul n n))))
::      55
::    Source
++  fold
  |*  [a=(list) b=* c=_|=(^ [** +<+])]
  |-  ^-  _b
  ?~  a  b
  $(a t.a, b (c i.a b))
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
    ~|  "INSERT: type of column {<-.q>} {<+<.q>} ".
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
::  +alpha
::
::  alphabetic order cords
++  alpha 
  |=  [a=@ b=@]
  ^-  ?
  ?:  =(a b)  %.y
  =/  e=(list ?)  ~
  |-
  =+  [c=(end 3 a) d=(end 3 b)]
  ?:  =(c 0)
    ?:  &(=(d 0) (gth (lent e) 0))
      -:(flop e)
    %.y
  ?:  =(d 0)
    %.n
  ::
  ?:  &((gte (mix c d) 32) (gte (dis c d) 64))
    ?:  (lth c d)
      ?:  (lth c (sub d 32))   %.y
      ?:  (gth c (sub d 32))   %.n
      ?:  =(c (sub d 32))      $(a (rsh 3 a), b (rsh 3 b), e [%.y e])
      $(a (rsh 3 a), b (rsh 3 b), e [%.y e])

    ?:  =((sub c 32) d)
      ?:  =((rsh 3 a) 0)
        ?:  =((rsh 3 b) 0)
          %.n
        %.y
      %.n

    ?:  (gth c d)
      ?:  (lth (sub c 32) d)
        %.y       
      %.n
    ~|("can't get here" !!)
  ::
  ?:  =(c d)
    $(a (rsh 3 a), b (rsh 3 b))  
  (lth c d)
::    +split-all: [(list T) sep:(list t)] -> (list (list T))
::
::  Splits a list into multiple lists, delimited by another list.
::    Examples
::      > (split-all "abcdefabhijkablmn" "ab")
::      ~[~ "cdef" "hijk" "lmn"]
::    Source
++  split-all
  |*  [p=(list) sep=(list)]
  =/  c=(list (list _?>(?=(^ p) i.p)))  ~
  =/  len  (lent sep)
  =/  q=(list @)  (flop (fand sep p))
  |-  ^+  c
  ?~  p  c
  ?~  q  $(p ~, c [p c])
  ?:  =(i.q 0)
    $(c [~ [(slag (add len i.q) `(list _?>(?=(^ p) i.p))`p) c]], p ~)
  %=  $
    c  [(slag (add len i.q) `(list _?>(?=(^ p) i.p))`p) c]
    p  (scag i.q `(list _?>(?=(^ p) i.p))`p)
    q  t.q
  ==
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
::  template for selected column from single data object
+$  templ-cell
  $:  %templ-cell
      column-name=(unit @tas)
      vc=vector-cell
  ==
::
::  template for selected column from joined data objects
+$  templ-cell-2
  $:  %templ-cell-2
      object=(unit qualified-column:ast)
      vc=vector-cell
  ==
--
