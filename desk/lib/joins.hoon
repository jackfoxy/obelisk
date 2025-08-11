/-  ast, *obelisk, *server-state
/+  *sys-views, *utils
|_  [state=server =bowl:gall]
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
::  +select-table:  query:ast -> [server (list set-table) (list vector)]
::
::  selection from a single table without joins
++  select-table
  |=  q=query:ast
  ^-  [server (list set-table) (list vector)]
  =/  from        (need from.q)
  =/  triple      (prep-table-set object.+.object.from as-of.from ~ ~ ~ ~)
  =/  init-map    *(map qualified-object:ast [(map @tas @) (list @)])
  =/  =set-table  -.triple
  =/  selected    columns.selection.q
  ::
  :+  state
      ~[set-table]
      %:  table-result  ~  ::filter
                        +>.triple
                        indexed-rows.set-table
                        selected
                        ==
::
++  table-result
  |=  $:  filter=(unit $-(joined-row ?))
          qualified-columns=(list qual-col-type)
          rows=(list indexed-row)
          selected=(list selected-column:ast)
          ==
  ^-  (list vector)
  ?:  =((lent rows) 0)  ~
  =/  out-rows   *(set vector)
  =/  cells=(list templ-cell)
    %^  mk-indexed-vect-templ
          qualified-columns
          selected
          -.rows
  |-
  ?~  rows  ~(tap in out-rows)
  ::=/  include-row=?
  ::  ?~  filter
  ::    %.y
  ::  ((need filter) i.rows)
  ::?.  include-row
  ::  $(rows t.rows)
  =/  row                     *(list vector-cell)
  =/  cols=(list templ-cell)  cells
  |-
  ?~  cols
    %=  ^$
      out-rows  (~(put in out-rows) (vector %vector row))
      rows      t.rows
    ==
  ?~  object.i.cols
    $(cols t.cols, row [vc.i.cols row])
  =/  cell=templ-cell  i.cols
  =/  value  (~(got by +<.i.rows) column:(need object.cell)) 
  $(cols t.cols, row [[p.vc.cell [p.q.vc.cell value]] row])
::
::  +join-all  query:ast -> join-return
:: 
::  server state returned because we may have updated the view cache
++  join-all
  |=  q=query:ast
  ^-  join-return
  =/  from  (need from.q)
  =/  relations=(list relation)
        %+  mk-relations  (relation %relation object.from as-of.from ~ ~)
                          joins.from
  =/  relat=relation  -.relations
  =.  relations       +.relations
  =/  triple         (prep-table-set object.table-set.relat as-of.relat ~ ~ ~ ~)
  =/  init-map        *(map qualified-object:ast [(map @tas @) (list @)])
  =/  prior-obj       -.triple
  =/  from-objects    (limo ~[prior-obj])
  =/  prior-join
        %:  set-table  %set-table
                      object=~
                      schema-tmsp=~
                      data-tmsp=~
                      columns=*(list column:ast)     ::for now, to do: for CTEs
                      pri-indx=~
                      join=~
                      predicate=~
                      rowcount.prior-obj
                      ?~  pri-indx.prior-obj  ~
                                              key:(need pri-indx.prior-obj)
                      pri-indexed=*(tree indexed-row)
                      indexed-rows=*(list indexed-row)
                      %+  turn  indexed-rows.prior-obj
        |=(a=indexed-row [-.a (~(put by init-map) (need object.prior-obj) +.a)])
                       ==
  =/  type-lookup=lookup-type                 +<.triple
  =/  qualified-columns=(list qual-col-type)  +>.triple
  ::
  ?:  =((lent relations) 0)  %:  join-return  %join-return
                                              state
                                              from-objects
                                              type-lookup
                                              qualified-columns
                                              ==
  ::
  |-
  ?~  relations
        %:  join-return  %join-return
                         state
                         [prior-join from-objects]
                         type-lookup
                         qualified-columns
                         ==
  =.  triple  %:  prep-table-set  object.table-set.i.relations
                                  as-of.i.relations
                                  join.i.relations
                                  predicate.i.relations
                                  type-lookup
                                  qualified-columns
                                  ==
  %=  $
    relations          +.relations
    from-objects       [-.triple from-objects]
    prior-join         (join-up prior-join -.triple)
    type-lookup        +<.triple
    qualified-columns  +>.triple
  ==
::
++  prep-table-set
  |=  $:  ts=query-source:ast
          as-of=(unit as-of:ast)
          join=(unit join-type:ast)
          predicate=(unit predicate:ast)
          type-lookup=lookup-type
          qualified-columns=(list qual-col-type)
          ==
  ^-  [set-table lookup-type (list qual-col-type)]
  =/  obj-alias  ?:  ?=(qualified-object:ast ts)
                   :-  ts
                       ?~  alias.ts  ~
                       `(crip (cass (trip (need alias.ts))))
                 ~|("SELECT: not supported on %query-row" !!)
  =/  sys-time   (set-tmsp as-of now.bowl)
  =/  db         ~|  "SELECT: database {<database.-.obj-alias>} does not exist"
                     (~(got by state) database.-.obj-alias)
  =/  =schema    ~|  "SELECT: database {<database.-.obj-alias>} ".
                     "doesn't exist at time {<sys-time>}"
                     (get-schema [sys.db sys-time])
  =/  vw  %+  get-view  [namespace.-.obj-alias name.-.obj-alias sys-time]
                        views.schema
  ?~  vw  %:  from-table  -.obj-alias
                          +.obj-alias
                          db
                          schema
                          join
                          predicate
                          sys-time
                          type-lookup
                          qualified-columns
                          ==
  %:  from-view  -.obj-alias
                  +.obj-alias
                  db
                  schema
                  (need vw)
                  join
                  predicate
                  sys-time
                  type-lookup
                  qualified-columns
                  ==
::
++  from-table
  |=  $:  query-obj=qualified-object:ast
          alias=(unit @t)
          db=database
          =schema
          join=(unit join-type:ast)
          predicate=(unit predicate:ast)
          sys-time=@da
          type-lookup=lookup-type
          qualified-columns=(list qual-col-type)
          ==
  ^-  [set-table lookup-type (list qual-col-type)]
  =/  tbl  ~|  "SELECT: table {<database.query-obj>}.{<namespace.query-obj>}".
               ".{<name.query-obj>} does not exist at schema time ".
               "{<tmsp.schema>}"
               (~(got by tables.schema) [namespace.query-obj name.query-obj])
  =/  file
        (get-content content.db sys-time [namespace.query-obj name.query-obj])
  :+  %:  set-table  %set-table
                     [~ query-obj]
                     [~ tmsp.tbl]
                     [~ tmsp.file]
                     columns.tbl
                     [~ pri-indx.tbl]
                     join
                     predicate
                     rowcount.file
                     *(list key-column)
                     pri-idx.file
                     indexed-rows.file
                     *(list joined-row)
                     ==
      %+  ~(put by type-lookup)  
            query-obj
            column-types.tbl
      (mk-qualified-columns query-obj qualified-columns columns.tbl)
::
::  +mk-relations:  [relation (list joined-object:ast)] ->  (list relation)
::
::  put all cross joins at the end of the list
++  mk-relations
  |=  [relat=relation joins=(list joined-object:ast)]
  ^-  (list relation)
  =/  relations=(list relation)    ~[relat]
  =/  cross-joins=(list relation)  ~
  |-
  ?~  joins  (flop (weld cross-joins relations))
  ?:  ?=(%cross-join join.i.joins)
    %=  $
      joins  t.joins
      cross-joins  :-  %:  relation  %relation
                                  object.i.joins
                                  as-of.i.joins
                                  `join.i.joins
                                  predicate.i.joins
                                  ==
                       cross-joins
    ==
  %=  $
    joins  t.joins
    relations  :-  %:  relation  %relation
                                 object.i.joins
                                 as-of.i.joins
                                 `join.i.joins
                                 predicate.i.joins
                                 ==
                   relations
  ==
::
++  mk-qualified-columns
  |=  $:  query-obj=qualified-object:ast
          qualified-columns=(list qual-col-type)
          columns=(list column:ast)
          ==
  ?~  qualified-columns
        %+  turn  columns
                |=(a=column:ast (mk-qualified-column query-obj a))
  %+  weld  qualified-columns
                %+  turn  columns
                |=(a=column:ast (mk-qualified-column query-obj a))
::
++  mk-qualified-column
  |=  [query-obj=qualified-object:ast a=column:ast]
  ^-  qual-col-type
  [(qualified-column:ast %qualified-column query-obj name.a ~) type.a]
::
++  from-view
  |=  $:  query-obj=qualified-object:ast
          alias=(unit @t)
          db=database
          =schema
          =view
          ::relat=relation
          join=(unit join-type:ast)
          predicate=(unit predicate:ast)
          sys-time=@da
          type-lookup=lookup-type
          qualified-columns=(list qual-col-type)
          ==
  ^-  [set-table lookup-type (list qual-col-type)]
  =/  r=[database cache]  %:  got-view-cache  db
                                              schema
                                              view
                                              :+  namespace.query-obj
                                                  name.query-obj
                                                  sys-time
                                              ==
  =/  view-content  (need content.+.r)
  ::
  ::  database view cache may have been populated
  =.  state  ?.  =(db -.r)
                (~(put by state) database.query-obj -.r)
             state
  :+  %:  set-table  %set-table
                     [~ query-obj]
                     [~ tmsp.schema]
                     [~ tmsp.+.r]
                     columns.view
                     ~
                     join
                     predicate
                     rowcount.view-content
                     *(list key-column)
                     ~
                     %+  turn  rows.view-content
                               |=(a=(map @tas @) [~ a ~]) ::to do: missing 
                     *(list joined-row)                   :: sequential col vals
                     ==
      %+  ~(put by type-lookup)  
            query-obj
            column-types.view
      (mk-qualified-columns query-obj qualified-columns columns.view)
::
::  +got-view-cache:
::    [database schema view data-obj-key (list selected-column:ast)]
::    -> [database cache]
++  got-view-cache
  |=  [db=database =schema vw=view key=data-obj-key]
  ^-  [database cache]
  =/  vw-cache=cache  (get-view-cache key view-cache.db)
  ?.  =(content.vw-cache ~)  [db vw-cache]
  =.  content.vw-cache  ?:  =(ns.key 'sys')
                              :-  ~
                                  %:  populate-system-view  state
                                                            db
                                                            schema
                                                            vw
                                                            obj.key
                                                            tmsp.vw-cache
                                                            ==
                                !!  :: : implement view refresh for non-sys
  [(put-view-cache db vw-cache key) vw-cache]
::
++  join-up
  |=  [prior=set-table this=set-table]
  ^-  set-table
  ?-  (need join.this)
    %join
      ?:  =(~ predicate.this)  (join-natural prior this)
      ~|("%join with ON predicate not implemented" !!)
    %left-join
      ~|("%left-join not implemented" !!)
    %right-join
      ~|("right-join not implemented" !!)
    %outer-join
      ~|("%outer-join not implemented" !!)
    %cross-join
      (cross-join prior this)
  ==
::
::  +cross-join:  [set-table set-table] -> set-table
++  cross-join
  |=  [prior=set-table this=set-table]
  ^-  set-table
  =/  a=(list joined-row)  joined-rows.prior
  =/  out-rows=(list joined-row)  ~
  =/  i  0
  ::
  |-
  ?~  a  %:  set-table    %set-table
                         object=~
                         schema-tmsp=~
                         data-tmsp=~
                         columns=*(list column:ast)   ::for now, to do: for CTEs
                         pri-indx=~
                         join=~
                         predicate=~
                         rowcount=i
                         key=~
                         pri-indexed=*(tree indexed-row)
                         indexed-rows=~
                         joined-rows=out-rows
                         ==
  =/  b  indexed-rows.this
  |-
  ?~  b  ^$(a +.a)
  =/  data-row  -.a
  %=  $ 
    out-rows  :-  :-  ~
                      (~(put by +.data-row) (need object.this) ->.b)
                  out-rows
    b  +.b
    i  +(i)
  ==
::
++  reduce-ord-col
  |=  a=ordered-column:ast
  name.a
::
::  +join-natural:  [set-table set-table] -> set-table
++  join-natural
  |=  [prior=set-table this=set-table]
  ^-  set-table
  ::join on foreign keys (to do)
  ::
  ::join on primary key
  ?:  &(=(~ key.prior) =(~ pri-indx.this))
    ~|("no natural join, missing index: {<prior>} {<this>}" !!)
  =/  this-key  key:(need pri-indx.this)
  :: perfect natural join
  =/  count-and-rows  ?.  =(key.prior this-key)  [0 ~]
                      %:  join-pri-key  joined-rows.prior
                                        indexed-rows.this
                                        (need object.this)
                                        this-key
                                        ==
  ?:  =(key.prior this-key)
      %:  set-table  %set-table
                    object=~
                    schema-tmsp=~
                    data-tmsp=~
                    columns=*(list column:ast)     ::for now, to do: for CTEs
                    pri-indx=~
                    join=~
                    predicate=~
                    rowcount=-.count-and-rows
                    key=this-key
                    pri-indexed=*(tree indexed-row)
                    indexed-rows=~
                    joined-rows=+.count-and-rows
                    ==
  ::  key is same column sequence, but different ordering
  ?:  ?!  .=  (turn key.prior |=(a=key-column [name.a aura.a]))
              (turn this-key |=(a=key-column [name.a aura.a]))
    ~|  "no natural join or foreign key join, columns do not match: ".
        "{<(need object.this)>}"
        !!
  ::  sort the little one
  =/  the-key  ?:  (gth rowcount.this rowcount.prior)
                 this-key
               key.prior
  =.  count-and-rows
        ?:  (gth rowcount.this rowcount.prior)
          %:  join-pri-key  %+  sort  joined-rows.prior
                                      ~(order idx-comp-2 (reduce-key the-key))
                            indexed-rows.this
                            (need object.this)
                            this-key
                            ==
        %:  join-pri-key  joined-rows.prior
                          %+  sort  indexed-rows.this
                                    ~(order idx-comp-2 (reduce-key the-key))
                          (need object.this)
                          key.prior
                          ==
  ::
  %:  set-table  %set-table
                object=~
                schema-tmsp=~
                data-tmsp=~
                columns=*(list column:ast)     ::for now, to do: for CTEs
                pri-indx=~
                join=~
                predicate=~
                rowcount=-.count-and-rows
                key=the-key
                pri-indexed=*(tree indexed-row)
                indexed-rows=~
                joined-rows=+.count-and-rows
                ==
::
::  +join-pri-key
::
::  joins the data of two tables having the same key
++  join-pri-key
  |=  $:  a=(list joined-row)
          b=(list indexed-row)
          b-qual=qualified-object:ast
          key=(list key-column)
          ==
  ^-  [@ud (list joined-row)]
  =/  c  *(list joined-row)
  =/  i  0
  ::
  |-
  ?~  a  [i (flop c)]
  ?~  b  [i (flop c)]
  =/  data-row  i.a
  ?:  =(-.i.a -.i.b)              :: keys =
    %=  $ 
      c  [[-.data-row (~(put by +.data-row) b-qual +.i.b)] c]
      a  t.a
      b  t.b
      i  +(i)
    ==
  ?:  (~(order idx-comp (reduce-key key)) -.i.a -.i.b)
    $(a t.a)
  $(b t.b)
--