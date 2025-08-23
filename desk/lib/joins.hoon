/-  ast, *obelisk, *server-state
/+  *sys-views, *utils, *predicate
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
::  +select-table:  [query:ast ?] -> [server (list set-table) (list vector)]
::
::  selection from a single table without joins
++  select-table
  |=  [q=query:ast is-cte=?]
  ^-  [server (list set-table) (list vector)]
  =/  from          (need from.q)
  =/  query-source  ?:  ?=(qualified-table:ast object.+.object.from)
                      object.+.object.from
                    ~|("SELECT: not supported on %query-row" !!)
  =/  triple=[set-table qualified-lookup-type (list qual-col-type)]
    %:  prep-table-set  query-source
                        as-of.from
                        ~
                        ~
                        *qualified-lookup-type
                        ~
                        ==
  =/  =set-table    -.triple
  =/  selected      columns.select.q
  =/  filter  ?~  predicate.q  ~
              :-  ~
                  %^  pred-ops-and-conjs
                      (pred-unqualify-qualified predicate.q)
                      :-  %unqualified-lookup-type
                          (~(got by +<+.triple) query-source)
                      ~
  ::
  ?:  is-cte  [state (select-table-cte q set-table filter) ~]
  :+  state
      ~[set-table]
      :::-  ~
          %:  table-result  filter
                            +>.triple
                            indexed-rows.set-table
                            selected
                            ==
::
::  +select-table-cte:  [query:ast (unit $-(data-row ?))]
::                  -> (list set-table) 
::
::  cons a set-table of the selection
::  1) object=~
::  2) new list of columns
::  3) (list key-column) preserved or not
::  4) indexed-rows index preserved or not
::  5) row count
++  select-table-cte
  |=  [q=query:ast st=set-table f=(unit $-(data-row ?))]
  ^-  (list set-table)
  =/  st2  st
  =.  object.st2  ~
  =/  foo=(list column:ast)
        %-  zing  %+  turn  columns.select.q
                            (cury selected-column-to-column columns.st)
  =.  columns.st2  %-  flop    foo
  ~[st2 st]
::
++  selected-column-to-column
  |=  [columns=(list column:ast) =selected-column:ast]
  ^-  (list column:ast)
  ?-  selected-column
    qualified-column:ast
      ~|("not supported" !!)
    unqualified-column:ast
      ~|("not supported" !!)
    qualified-table:ast
      ~|("not supported" !!)
    selected-aggregate:ast
      ~|("not supported" !!)
    selected-value:ast
      ~[[%column `@tas`(need alias.selected-column) p.value.selected-column]]
    selected-all:ast
      (flop columns)
    selected-all-object:ast
      (flop columns)
    ==
::
++  table-result
  |=  $:  filter=(unit $-(data-row ?))
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
  =/  include-row=?
    ?~  filter
      %.y
    ((need filter) i.rows)
  ?.  include-row
    $(rows t.rows)
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
  =/  value  (~(got by data.i.rows) name:(need object.cell)) 
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
  =/  query-source  ?:  ?=(qualified-table:ast object.table-set.relat)
                      object.table-set.relat
                    ~|("SELECT: not supported on %query-row" !!)
  =.  relations       +.relations
  =/  triple          %:  prep-table-set  query-source
                                          as-of.relat
                                          ~
                                          ~
                                          *qualified-lookup-type
                                          ~
                                          ==
  =/  prior-obj       -.triple
  =/  from-objects    (limo ~[prior-obj])
  =/  prior-join
        %:  set-table  %set-table
                       object=~
                       schema-tmsp=~
                       data-tmsp=~
                       columns=*(list column:ast)     ::for now, to do: for CTEs
                       lookup-type=*qualified-lookup-type
                       pri-indx=~
                       join=~
                       predicate=~
                       rowcount.prior-obj
                       ?~  pri-indx.prior-obj  ~
                                               key:(need pri-indx.prior-obj)
                       pri-indexed=*(tree [(list @) (map @tas @)])
                       indexed-rows=*(list indexed-row)
                       %+  turn  indexed-rows.prior-obj
                                 %+  cury  joined-row-from-indexed
                                           (need object.prior-obj)
                        ==
  =/  type-lookup                             +<.triple
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
  =.  query-source  ?:  ?=(qualified-table:ast object.table-set.i.relations)
                      object.table-set.i.relations
                    ~|("SELECT: not supported on %query-row" !!)
  =.  triple  %:  prep-table-set  query-source
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
  |=  $:  ts=qualified-table:ast
          as-of=(unit as-of:ast)
          join=(unit join-type:ast)
          predicate=(unit predicate:ast)
          type-lookup=qualified-lookup-type
          qualified-columns=(list qual-col-type)
          ==
  ^-  [set-table qualified-lookup-type (list qual-col-type)]
  =/  obj-alias  :-  ts
                     ?~  alias.ts  ~
                     `(crip (cass (trip (need alias.ts))))
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
  |=  $:  query-obj=qualified-table:ast
          alias=(unit @t)
          db=database
          =schema
          join=(unit join-type:ast)
          predicate=(unit predicate:ast)
          sys-time=@da
          type-lookup=qualified-lookup-type
          qualified-columns=(list qual-col-type)
          ==
  ^-  [set-table qualified-lookup-type (list qual-col-type)]
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
                     [%unqualified-lookup-type type-lookup.tbl]
                     [~ pri-indx.tbl]
                     join
                     predicate
                     rowcount.file
                     *(list key-column)
                     pri-idx.file
                     indexed-rows.file
                     *(list joined-row)
                     ==
      :-  %qualified-lookup-type
          (~(put by +.type-lookup) query-obj type-lookup.tbl)
      (mk-qualified-columns query-obj qualified-columns columns.tbl)
::
::  +mk-relations:  [relation (list joined-object:ast)] ->  (list relation)
::
::  put all cross joins at the end of the list
++  mk-relations
  |=  [relat=relation joins=(list joined-object:ast)]
  ^-  (list relation)
  =/  relations=(list relation)    ~[relat]
  =/  cross-joins  *(list relation)
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
  |=  $:  query-obj=qualified-table:ast
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
  |=  [query-obj=qualified-table:ast a=column:ast]
  ^-  qual-col-type
  [(qualified-column:ast %qualified-column query-obj name.a ~) type.a]
::
++  from-view
  |=  $:  query-obj=qualified-table:ast
          alias=(unit @t)
          db=database
          =schema
          =view
          join=(unit join-type:ast)
          predicate=(unit predicate:ast)
          sys-time=@da
          type-lookup=qualified-lookup-type
          qualified-columns=(list qual-col-type)
          ==
  ^-  [set-table qualified-lookup-type (list qual-col-type)]
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
                     *unqualified-lookup-type
                     ~
                     join
                     predicate
                     rowcount.view-content
                     *(list key-column)
                     ~
                     %+  turn  rows.view-content
                               |=(a=(map @tas @) [%indexed-row ~ a])
                     *(list joined-row)
                     ==
      :-  %qualified-lookup-type
          (~(put by +.type-lookup) query-obj type-lookup.view)
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
  =/  a         joined-rows.prior
  =/  out-rows  *(list joined-row)
  =/  i  0
  ::
  |-
  ?~  a  %:  set-table    %set-table
                          object=~
                          schema-tmsp=~
                          data-tmsp=~
                          columns=*(list column:ast)  ::for now, to do: for CTEs
                          lookup-type=*qualified-lookup-type
                          pri-indx=~
                          join=~
                          predicate=~
                          rowcount=i
                          key=~
                          pri-indexed=*(tree [(list @) (map @tas @)])
                          indexed-rows=~
                          joined-rows=out-rows
                          ==
  =/  b  indexed-rows.this
  |-
  ?~  b  ^$(a t.a)
  %=  $ 
    out-rows  :-  :+  %joined-row
                      ~
                      (~(put by data.i.a) (need object.this) data.i.b)
                  out-rows
    b  t.b
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
                    lookup-type=*qualified-lookup-type
                    pri-indx=~
                    join=~
                    predicate=~
                    rowcount=-.count-and-rows
                    key=this-key
                    pri-indexed=*(tree [(list @) (map @tas @)])
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
                                   ~(order data-row-comp (reduce-key the-key))
                            indexed-rows.this
                            (need object.this)
                            this-key
                            ==
        %:  join-pri-key  joined-rows.prior
                          %+  sort  indexed-rows.this
                                  ~(order data-row-comp (reduce-key the-key))
                          (need object.this)
                          key.prior
                          ==
  ::
  %:  set-table  %set-table
                object=~
                schema-tmsp=~
                data-tmsp=~
                columns=*(list column:ast)     ::for now, to do: for CTEs
                lookup-type=*qualified-lookup-type
                pri-indx=~
                join=~
                predicate=~
                rowcount=-.count-and-rows
                key=the-key
                pri-indexed=*(tree [(list @) (map @tas @)])
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
          b-qual=qualified-table:ast
          key=(list key-column)
          ==
  ^-  [@ud (list joined-row)]
  =/  c  *(list joined-row)
  =/  i  0
  ::
  |-
  ?~  a  [i (flop c)]
  ?~  b  [i (flop c)]
  ?:  =(key.i.a key.i.b)
    %=  $ 
      c  [[%joined-row key.i.a (~(put by data.i.a) b-qual data.i.b)] c]
      a  t.a
      b  t.b
      i  +(i)
    ==
  ?:  (~(order idx-comp (reduce-key key)) key.i.a key.i.b)
    $(a t.a)
  $(b t.b)
--