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
  =/  filter        ?~  predicate.q  ~
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
::  3) key preserved w/ updated names or not
::  4) indexed-rows index preserved or not

::  4.5) schema-tmsp=(unit @da)
::      data-tmsp=(unit @da)
::      =lookup-type  delete those that do not exist
::      pri-indx=(unit index)
::      predicate=(unit predicate)
::      pri-indexed=(tree [(list @) (map @tas @)])

::  5) row count
++  select-table-cte
  |=  [q=query:ast st=set-table f=(unit $-(data-row ?))]
  ^-  (list set-table)
  =/  st2  st
  =.  object.st2  ~
  =/  cols=(list column:ast)
        %-  zing  %+  turn  columns.select.q
                            (cury selected-column-to-column columns.st)
  =.  columns.st2     (flop cols)
  =/  selected-cols   %^  fold  columns.select.q
                                *(map @tas [@tas (unit @t)])
                                (cury selected-table-cols columns.st)
  =/  st-key          key:(need pri-indx.st)
  =/  count-key-cols  %^  fold  st-key
                                *(pair @ud (list key-column))
                                (cury count-keys selected-cols)
  =.  pri-indx.st2    ?:  =(p.count-key-cols (lent st-key))
                        [~ [%index %.y q.count-key-cols]]
                      ~
  ~[st2 st]
::
::  +count-keys:  
::    [(map @tas (pair @tas (unit @t))) key-column (pair @ud (list key-column))]
::    -> (pair @ud (list key-column))
::
::  If key exists in selected columns then count, emit, and potentially rename
::  to alias.
++  count-keys
  |=  $:  key-lookup=(map @tas (pair @tas (unit @t)))
          a=key-column
          b=(pair @ud (list key-column))
          ==
  =/  found  (~(get by key-lookup) name.a)
  ?~  found  b
  =/  found2  (need found)
  ?~  q.found2  [+(p.b) [a q.b]]
  [+(p.b) [[%key-column (need q.found2) aura.a ascending.a] q.b]]
::
::  +selected-table-cols:
::    [(list column:ast) selected-column:ast (map @tas [@tas (unit @t)])]
::    ->  (map @tas [@tas (unit @t)])
::
::  Create look-up from original table column name to name or alias in SELECT,
::  used in deciding if key is preserved and renaming key columns.
++  selected-table-cols
  |=  $:  all-cols=(list column:ast)
          a=selected-column:ast
          b=(map @tas [@tas (unit @t)])
          ==
  ^-  (map @tas [@tas (unit @t)])
  ?:  ?=(unqualified-column:ast a)
    (~(put by b) name.a [name.a alias.a])
  ?:  ?=(qualified-column:ast a)
    (~(put by b) name.a [name.a alias.a])
  ?:  ?=(selected-all:ast a)
    |-
    ?~  all-cols  b
    %=  $
      all-cols  t.all-cols
      b         (~(put by b) name.i.all-cols [name.i.all-cols ~])
    ==
  ?:  ?=(selected-all-object:ast a)
    |-
    ?~  all-cols  b
    %=  $
      all-cols  t.all-cols
      b         (~(put by b) name.i.all-cols [name.i.all-cols ~])
    ==
  b
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
  =/  query-source    ?:  ?=(qualified-table:ast object.table-set.relat)
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
  =/  prior-join      -.triple
  ::=.  joined-rows.prior-join  %+  turn  indexed-rows.prior-join
  ::                                      %+  cury  joined-row-from-indexed
  ::                                                (need object.prior-join)
  =/  from-objects    (limo ~[prior-join])
  =/  type-lookup     +<.triple
  =/  qualified-columns=(list qual-col-type)  +>.triple
  |-
  ?~  relations  %:  join-return  %join-return
                                  state
                                  from-objects
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
  =.  prior-join       (join-up prior-join -.triple)
  %=  $
    relations          +.relations
    from-objects       [prior-join from-objects]
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
  =/  a=(list data-row)  ?~  joined-rows.prior
                           indexed-rows.prior
                         joined-rows.prior
  =/  out-rows           *(list joined-row)
  =/  i  0
  ::
  |-
  ?~  a  (joined-set-table this i out-rows)
  =/  b  indexed-rows.this
  |-
  ?~  b  ^$(a t.a)
  %=  $ 
    out-rows  :-  ?:  ?=(%joined-row -.i.a)
                    :+  %joined-row
                        ~
                        (~(put by data.i.a) (need object.this) data.i.b)
                  %:  joined-from-indexed  i.a
                                           (need object.prior)
                                           i.b
                                           (need object.this)
                                           ==
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
  ?:  &(=(~ pri-indx.prior) =(~ pri-indx.this))
    ~|("no natural join, missing index: {<prior>} {<this>}" !!)
  =/  this-key   key:(need pri-indx.this)
  =/  prior-key  key:(need pri-indx.prior)
  :: perfect natural join
  =/  count-and-rows  ?.  =(prior-key this-key)  [0 ~]
                      ?~  joined-rows.prior
                        %:  join-pri-key  indexed-rows.prior
                                          (need object.prior)
                                          indexed-rows.this
                                          (need object.this)
                                          this-key
                                        ==
                      %:  join-pri-key  joined-rows.prior
                                        (need object.prior)
                                        indexed-rows.this
                                        (need object.this)
                                        this-key
                                        ==
  ?:  =(prior-key this-key)
    (joined-set-table this -.count-and-rows +.count-and-rows)
  ::  key is same column sequence, but different ordering
  ?:  ?!  .=  (turn prior-key |=(a=key-column [name.a aura.a]))
              (turn this-key |=(a=key-column [name.a aura.a]))
    ~|  "no natural join or foreign key join, columns do not match: ".
        "{<(need object.this)>}"
        !!
  ::  sort the little one
  =/  the-key  ?:  (gth rowcount.this rowcount.prior)
                 this-key
               prior-key
  =.  count-and-rows
        ?:  (gth rowcount.this rowcount.prior)
          ?~  joined-rows.prior
            %:  join-pri-key  %+  sort  indexed-rows.prior
                                   ~(order data-row-comp (reduce-key the-key))
                              (need object.prior)
                              indexed-rows.this
                              (need object.this)
                              this-key
                              ==
          %:  join-pri-key  %+  sort  joined-rows.prior
                                   ~(order data-row-comp (reduce-key the-key))
                            (need object.prior)
                            indexed-rows.this
                            (need object.this)
                            this-key
                            ==
        ?~  joined-rows.prior
          %:  join-pri-key  indexed-rows.prior
                            (need object.prior)
                            %+  sort  indexed-rows.this
                                    ~(order data-row-comp (reduce-key the-key))
                            (need object.this)
                            prior-key
                            ==
        %:  join-pri-key  joined-rows.prior
                          (need object.prior)
                          %+  sort  indexed-rows.this
                                  ~(order data-row-comp (reduce-key the-key))
                          (need object.this)
                          prior-key
                          ==
  ::
  (joined-set-table this -.count-and-rows +.count-and-rows)
::
::  +joined-set-table:  [set-table @ud (list joined-row)] -> set-table
++  joined-set-table
  |=  [st=set-table row-count=@ud joined-rows=(list joined-row)]
  ^-  set-table
  =.  rowcount.st     row-count
  =.  joined-rows.st  joined-rows
  st
::
::  +join-pri-key:  $:  (list data-row)
::                      qualified-table:ast
::                      (list indexed-row)
::                      qualified-table:ast
::                      (list key-column)
::                      ==
::                  ->  [@ud (list joined-row)]
::
::  joins the data of two tables having the same key
++  join-pri-key
  |=  $:  a=(list data-row)
          a-qual=qualified-table:ast
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
      c  ?:  ?=(%joined-row -.i.a) 
        [[%joined-row key.i.a (~(put by data.i.a) b-qual data.i.b)] c]
      [(joined-from-indexed i.a a-qual i.b b-qual) c]
      a  t.a
      b  t.b
      i  +(i)
    ==
  ?:  (~(order idx-comp (reduce-key key)) key.i.a key.i.b)
    $(a t.a)
  $(b t.b)
::
++  joined-from-indexed
  |=  $:  a=indexed-row
          a-qual=qualified-table:ast
          b=indexed-row
          b-qual=qualified-table:ast
          ==
  ^-  joined-row
  :+  %joined-row
      key.a
      %+  %~  put  by  %+  %~  put  by  *(map qualified-table:ast (map @tas @))
                           a-qual
                           data.a
          b-qual
          data.b
--