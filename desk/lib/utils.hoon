/-  ast, *obelisk, *server-state
/+  mip
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
::  +reduce-key:  (list key-column) -> (list [@ta ?])
++  reduce-key
  |=  key=(list key-column)
  ^-  (list [@ta ?])
  (turn key |=(a=key-column [aura.a ascending.a]))
::
::  +idx-comp
::
::  comparator for index mops
++  idx-comp
  |_  index=(list [@ta ?])
  ++  order
    |=  [p=(list @) q=(list @)]
    =/  k=(list [@ta ?])  index
    |-  ^-  ?
    ?:  =(-.p -.q)  $(k +.k, p +.p, q +.q)
    ?:  =(-<.k ~.t)  (alpha -.q -.p)
    ?:  ->.k  (gth -.p -.q)
    (lth -.p -.q)
  --
::
++  pri-key
  |=  key=(list key-column)
  =/  comparator  ~(order idx-comp (reduce-key key))
  ((on (list [@tas ?]) (map @tas @)) comparator)
::
::  gets the schema with matching or next subsequent time
++  schema-key  ((on @da schema) gth)
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
++  data-key  ((on @da data) gth)
::
::  gets the data with the highest timestamp for schema mutation
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
::  gets the data with the highest timestamp for data mutation
++  get-data-next
  |=  $:  content=((mop @da data) gth)
          sys-time=@da
      ==
  ^-  data
  =/  nxt-data=data  +:(need (pry:data-key content))
  ?:  (lth sys-time tmsp.nxt-data)  !!
  nxt-data
::
::  +  get-view:  [ns-rel-key views] -> (unit view)
::
::  get view with current or most recent previous time
::
::  because ns-rel-comp orders on gth, tab logic requires +1 to include
::  exact match
++  view-key  ((on ns-rel-key view) ns-rel-comp)
++  get-view
  |=  [key=ns-rel-key =views]
  ^-  (unit view)
  =/  vw  (tab:view-key views `[ns.key rel.key `@da`(add `@`time.key 1)] 1)
  ?~  vw  ~
  =/  returned-key=ns-rel-key  -<.vw
  ?:  &(=(ns.returned-key ns.key) =(rel.returned-key rel.key))  `->.vw
  ~
::
::  +get-view-cache:  [ns-rel-key ((mop ns-rel-key cache) ns-rel-comp)]
::                    -> (unit cache)
++  view-cache-key  ((on ns-rel-key cache) ns-rel-comp)
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
  ?:  ?=(unqualified-column:ast selected-column)
    ?~  alias.selected-column  default
        (crip (cass (trip (need alias.selected-column))))
  ?:  ?=(selected-value:ast selected-column)
    ?~  alias.selected-column  default
        (crip (cass (trip (need alias.selected-column))))
  ~|("{<selected-column>} not supported" !!)
::
::  +mk-col-lu-data:  [=column:ast a=@] -> [[@tas [@tas @ud]] @ud]
++  mk-col-lu-data
    |=  [=column:ast a=@]
    ^-  [[@tas [@tas @ud]] @ud]
    [[name.column [type.column a]] +(a)]
::
++  calc-joined-addr
  |=  $:  data=(mip:mip qualified-table:ast @tas @)
          qual=qualified-table:ast
          col=@tas
          ==
  ^-  @
  =/  outer    +:(~(dig by data) qual)
  =/  columns  ;;((map @tas @) +:.*(data [%0 outer]))
  =/  inner    +:(~(dig by columns) col)
  (peg (add (mul 2 outer) 1) (add (mul 2 inner) 1))
::
++  addr-columns
  |=  columns=(list column:ast)
  ^-  (list column:ast)
  =/  fake-data=(map @tas @)
       (roll columns |=([a=column:ast b=(map @tas @)] (~(put by b) [name.a 0])))
  %+  turn
        columns
        |=(a=column:ast [%column name.a type.a +:(~(dig by fake-data) name.a)])
::
::  +mk-rel-vect-templ:
::    [(list column-meta) (list selected-column:ast) data-row lookup-type]
::    -> (list templ-cell)
::
::  leave output un-flopped so consuming arm does not flop
++  mk-rel-vect-templ
  |=  $:  cols=(list column-meta)
          selected=(list selected-column:ast)
          row=data-row 
          =lookup-type
          ==
  ^-  (list templ-cell)
  =/  is-join  =(%joined-row -.row)
  =/  i  0
  =/  cells  *(list templ-cell)
  ::
  |-
  ?~  selected  ?~  cells  ~|("no cells" !!)  cells
  ?:  =([%all %all] i.selected)
    %=  $
      i         +(i)
      selected  t.selected
      cells     %+  weld
                    ?:  is-join
                      (flop (turn cols (cury mk-templ-cell-joined +>:;;(joined-row row))))
                    (flop (turn cols (cury mk-templ-cell-indexed +:;;(unqualified-lookup-type lookup-type))))
                    cells
    ==
  ?:  ?=(selected-all-table:ast i.selected)
    %=  $
      i         +(i)
      selected  t.selected
      cells     
        %+  weld
          %-  flop
            %+  turn
              %+  skim
                    cols
                  |=(a=column-meta =(qualifier.qualified-column.a +.i.selected))
              ?:  is-join  (cury mk-templ-cell-joined +>:;;(joined-row row))
              (cury mk-templ-cell-indexed +:;;(unqualified-lookup-type lookup-type))
          cells
    ==
  ?:  ?=(selected-value:ast i.selected)
    %=  $
      i         +(i)
      selected  t.selected
      cells
        :-  %:  templ-cell  %templ-cell
                            ~
                            0  :: addr
                            :-  (heading i.selected (crip "literal-{<i>}"))
                                [p=+<-.i.selected q=+<+.i.selected]
                            ==
            cells
    ==
  =/  typ-addr  ?:  ?=(qualified-column:ast i.selected)
                  ~|  "SELECT: column {<name.i.selected>} not found"
                  (~(get by +.lookup-type) name.i.selected)
                ?:  ?=(unqualified-column:ast i.selected)
                  ~|  "SELECT: column {<name.i.selected>} not found"
                  (~(get by +.lookup-type) name.i.selected)
                ~
  ?:  ?=(unqualified-column:ast i.selected)
    %=  $
      i         +(i)
      selected  t.selected
      cells  ~|  "SELECT: column {<name.i.selected>} not found"  
             :-
               %:  templ-cell
                     %templ-cell
                     :-  ~
                         :^  %qualified-column
                             *qualified-table:ast
                             name.i.selected 
                             alias.i.selected
                     +:(need typ-addr)
                     [(heading i.selected name.i.selected) [-:(need typ-addr) 0]]
                     ==
               cells
    ==
  ?:  ?=(qualified-column:ast i.selected)
    %=  $
      i         +(i)
      selected  t.selected
      cells  ~|  "SELECT: column {<name.i.selected>} not found"
             :-
                ?:  is-join
                  %:  templ-cell 
                      %templ-cell
                      [~ i.selected]
                      %^  calc-joined-addr  data:;;(joined-row row)
                                            qualifier.i.selected
                                            name.i.selected
                      :-  (heading i.selected name.i.selected)
                          :-  %-  head  %+  ~(got bi:mip +:;;(qualified-lookup-type lookup-type))
                                                qualifier.i.selected
                                                name.i.selected
                              0
                      ==
                %:  templ-cell  
                    %templ-cell
                    [~ i.selected]
                    +:(need typ-addr)
                    [(heading i.selected name.i.selected) [-:(need typ-addr) 0]]
                    ==
                cells
    ==
  ~|("{<i.selected>} not supported" !!)
::
++  mk-templ-cell-indexed
  |=  [col-lookup=(map @tas typ-addr) a=column-meta]
  ^-  templ-cell
  :^  %templ-cell
      `-.a 
      addr:(~(got by col-lookup) name.qualified-column.a)
      [name.qualified-column.a [type.a 0]]
::
++  mk-templ-cell-joined
  |=  [data=(mip:mip qualified-table:ast @tas @) a=column-meta]
  ^-  templ-cell
  :^  %templ-cell
      `-.a
      (calc-joined-addr data qualifier.qualified-column.a name.qualified-column.a)
      `vector-cell`[name.qualified-column.a [type.a 0]]
::
++  mk-unqualified-typ-addr-lookup
  |=  a=(list column:ast)
  ^-  (map @tas typ-addr)
  (malt (turn a |=(a=column:ast [name.a [type.a addr.a]])))
::
++  mk-qualified-type-lookup
  |=  [kvp=(list [qualified-table:ast (list column:ast)])]
  ^-  qualified-lookup-type
  :-  %qualified-lookup-type
  %-  malt
  (turn kvp |=(e=[qualified-table:ast (list column:ast)] [-.e (mk-unqualified-typ-addr-lookup +.e)]))
::
++  qualify-unqualified
  |=  $:  selected=(list selected-column:ast)
          qualifier-lookup=(map @tas (list qualified-table:ast))
          ==
  =/  selected-out  *(list selected-column:ast)
  |-
  ?~  selected  (flop selected-out)
  ?.  ?=(unqualified-column:ast -.selected)
    %=  $
      selected      t.selected
      selected-out  [i.selected selected-out]
    ==
  =/  qualifiers   ~|  "SELECT: column {<name.i.selected>} not found"
                       (~(got by qualifier-lookup) name.i.selected)
  ?:  (gth (lent qualifiers) 1)
    ~|("SELECT: column {<name.i.selected>} must be qualified" !!)
  %=  $
    selected      t.selected
    selected-out  :-  ^-  selected-column:ast
                      %:  qualified-column:ast  %qualified-column
                                                -.qualifiers
                                                name.i.selected
                                                alias.i.selected
                                                ==
                      selected-out
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
      =/  dt    (yore q)
      =/  years  (div offset:as-of 12)
      =/  months  (sub offset:as-of (mul years 12))
      ?:  =(m.dt months)
        %-  year  :+  [a=%.y y=(sub y.dt (add years 1))]
                      m=12
                      t=[d=d.t.dt h=h.t.dt m=m.t.dt s=s.t.dt f=f.t.dt]
      ?:  (gth m.dt months)
        %-  year  :+  [a=%.y y=(sub y.dt years)]
                      m=(sub m.dt months)
                      t=[d=d.t.dt h=h.t.dt m=m.t.dt s=s.t.dt f=f.t.dt]
      %-  year  :+  [a=%.y y=(sub y.dt (add years 1))]
                    m=(sub (add m.dt 12) months)
                    t=[d=d.t.dt h=h.t.dt m=m.t.dt s=s.t.dt f=f.t.dt]
    %years
      =/  dt  (yore q)
      %-  year  :+  [a=%.y y=(sub y.dt offset:as-of)]
                    m=m.dt
                    t=[d=d.t.dt h=h.t.dt m=m.t.dt s=s.t.dt f=f.t.dt]
  ==
::
::    +to-column: [@t (map @tas [aura @])] -> column:ast
++  to-column
  |=  [p=@t q=(map @tas [aura @])]
  ^-  column:ast
  ~|  "INSERT: invalid column: {<p>}"
  (column:ast %column p -:(~(got by q) p) 0)
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
                                    [%sys %table-keys]
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
                                    [%sys %table-keys]
                                    [%sys %columns]
                                    [%sys %sys-log]
                                    [%sys %data-log]
                                    ==
    %truncate-table
      %^  next-view-cache-keys  db
                                sys-time
                                :~  [%sys %tables]
                                    [%sys %data-log]
                                    ==
    %insert
      %^  next-view-cache-keys
                            db
                            sys-time
                            %+  weld  %-  limo  :~  [%sys %tables]
                                                    [%sys %data-log]
                                                    ==
                                      (need sys-vws)
    %update
      %^  next-view-cache-keys  db
                                sys-time
                                :~  [%sys %tables]
                                    [%sys %data-log]
                                    ==
    %delete
      %^  next-view-cache-keys  db
                                sys-time
                                :~  [%sys %tables]
                                    [%sys %data-log]
                                    ==
  ==
::
::  +next-view-cache-keys:  [database @da (list [@tas @tas])] -> view-cache
++  next-view-cache-keys
  |=  [db=database sys-time=@da sys-vws=(list [@tas @tas])]
  ^-  view-cache
  %+  gas:view-cache-key
        view-cache.db
        %+  turn
              sys-vws
              |=([p=[@tas @tas]] [[-.p +.p sys-time] (cache %cache sys-time ~)])
::
::  +common-txn
::    [tape server @da qualified-table:ast (unit as-of:ast) (map @tas @da)]
::    -> txn-meta
::
::  source-content-time is the data state time against which to apply the
::  change. It is the closest available table state = or < than requested
::  as-of time.
::  The resulting data state time will always be NOW.
++  common-txn
  |=  $:  txn=tape
          state=server
          now=@da
          t=qualified-table:ast
          as-of=(unit as-of:ast)
          next-schemas=(map @tas @da)
          ==
  ^-  txn-meta
  =/  db  ~|  %+  weld  txn  ": database {<database.t>} does not exist"
          (~(got by state) database.t)
  =/  content-time  (set-tmsp as-of now)
  =/  nxt-schema=schema  ~|  %+  weld  txn  ": table {<name.t>} ".
                             "as-of schema time out of order"
                              %:  get-next-schema  sys.db
                                                    next-schemas
                                                    now
                                                    database.t
                                                    ==
  =/  nxt-data=data  ~|  %+  weld  txn  ": table {<name.t>} ".
                         "as-of data time out of order"
                         (get-data-next content.db now)
  =/  tbl-key  [namespace.t name.t]
  =/  =table  ~|  %+  weld  txn  ": table {<tbl-key>} does not exist"
                  (~(got by tables:nxt-schema) tbl-key)
  =/  f=file  (get-content content.db content-time tbl-key)
  :*  %txn-meta
      db
      tbl-key
      nxt-data
      table
      f
      tmsp.f
      ==
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
  |=  [=file =data tbl-key=[@tas @tas] primary-key=(list key-column)]
  ~+  :: keeper
  =/  new-indexed-rows  %+  turn  (tap:(pri-key primary-key) pri-idx.file)
                                  |=(a=[(list @) (map @tas @)] [%indexed-row a])
  =.  indexed-rows.file    new-indexed-rows
  =.  rowcount.file        (lent new-indexed-rows)
  =.  files.data  (~(put by files.data) tbl-key file)
  data
::
::  +row-cells:
::    [(list value-or-default:ast) (list column:ast)] -> (map @tas @)
::
::  Create the saved row-wise file data.
++  row-cells
  |=  [p=(list value-or-default:ast) q=(list column:ast)]
  ^-  (map @tas @)
  =/  cells  *(list [@tas @])
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
    ?:  =(p.p type.q)  [name.q q.p]
    ~|  "INSERT: type of column {<-.q>} {<+<.q>} ".
        "does not match input value type {<p.p>}"
        !!
  ?:  =(%default p)
    ?:  =(%da type.q)  [name.q *@da]                :: default to bunt
    [name.q 0]
  ~|("row cell {<p>} not supported" !!)
::
++  joined-row-from-indexed
  |=  [qo=qualified-table:ast =indexed-row]
  ^-  joined-row      
  :+  %joined-row
      key.indexed-row
      %+  ~(put by *(map qualified-table:ast (map @tas @)))
          qo
          data.indexed-row
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
::  alphabetically order cords
++  alpha
  |=  [a=cord b=cord]
  ~+  :: keep, makes big difference inserting large @t
  ^-  ?
  =/  a  (trip a)
  =/  b  (trip b)
  =/  a-cass  (cass a)
  =/  b-cass  (cass b)
  ?.  =(a-cass b-cass)  (aor a-cass b-cass)
  (aor a b)
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
  ~+   :: keep, seems to make small difference
  ^-  (set @tas)
  (~(run in a) |=(b=* ?@(b !! ?@(+<.b +<.b !!))))
--
