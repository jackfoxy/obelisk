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
::  +select-relation:  [query:ast ? named-ctes] -> [join-return (list vector)]
::
::  selection from a single table without joins
++  select-relation
  |=  [q=query:ast is-cte=? =named-ctes]
  ^-  [join-return (list vector)]
  =/  from          (need from.q)
  =/  query-source    ?:  ?=(qualified-table:ast object.+.object.from)
                      object.+.object.from
                    ~|("SELECT: not supported on %query-row" !!)
  =/  the-relation=full-relation  %:  got-relation  query-source
                                      named-ctes
                                      as-of.from
                                      ~
                                      ~
                                      *qualified-lookup-type
                                      ~
                                      ==
  =/  selected      columns.select.q
  =/  filter        ?~  predicate.q  ~
                    :-  ~
                        %^  pred-ops-and-conjs
                            (pred-unqualify-qualified predicate.q)
                            :-  %unqualified-lookup-type
                                %-  ~(got by +.lookup-type.the-relation)
                                    query-source
                            ~
  ::
  ?~  set-tables.the-relation  ~|("select-relation can't get here" !!)
  ::
  :-  :*  %join-return
          state
          ?.  is-cte   set-tables.the-relation
              (select-for-cte q set-tables.the-relation filter)
          lookup-type.the-relation
          qual-col-types.the-relation
          ==
      %:  table-result  filter
                        qual-col-types.the-relation
                        indexed-rows.i.set-tables.the-relation
                        selected
                        ==
::
::  +select-for-cte:  [query:ast (unit $-(data-row ?))]
::                    -> (list set-table) 
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
::      =predicate
::      pri-indexed=(tree [(list @) (map @tas @)])

::  5) row count
++  select-for-cte
  |=  [q=query:ast set-tables=(list set-table) f=(unit $-(data-row ?))]
  ^-  (list set-table)
  ?~  set-tables  ~|("select-for-cte can't get here" !!)
  =/  st2  i.set-tables
  =.  object.st2      ~
  =.  columns.st2     %-  flop
                        ^-  (list column:ast)  %-  zing
                            %+  turn  columns.select.q
                                      %+  cury  selected-column-to-column
                                                columns.i.set-tables
  
  =/  selected-cols   %^  fold  columns.select.q
                                *(map @tas [@tas (unit @t)])
                                (cury selected-table-cols columns.i.set-tables)
  =/  st-key          key:(need pri-indx.i.set-tables)
  =/  count-key-cols  %^  fold  st-key
                                *(pair @ud (list key-column))
                                (cury count-keys selected-cols)
  =.  pri-indx.st2    ?:  =(p.count-key-cols (lent st-key))
                        [~ [%index %.y q.count-key-cols]]
                      ~

  ?:  =(f ~)  [st2 set-tables]  :: to do: filtered CTE
  [st2 set-tables]
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
  ?:  ?=(selected-all-table:ast a)
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
    selected-aggregate:ast
      ~|("not supported" !!)
    selected-value:ast
      ~[[%column `@tas`(need alias.selected-column) p.value.selected-column]]
    selected-all:ast
      (flop columns)
    selected-all-table:ast
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
  |=  [q=query:ast =named-ctes]
  ^-  join-return
  =/  from  (need from.q)
  =/  joined-relations=(list joined-relation)
        %+  mk-joined-relations  %:  joined-relation  %joined-relation
                                                      object.from
                                                      as-of.from
                                                      ~
                                                      ~
                                                      ==
                                 joins.from
  =/  relat=joined-relation  -.joined-relations
  =/  query-source  ?:  ?=(qualified-table:ast object.relation.relat)
                      object.relation.relat
                    ~|("SELECT: not supported on %query-row" !!)
  =.  joined-relations            +.joined-relations
  =/  the-relation=full-relation  %:  got-relation  query-source
                                                     named-ctes
                                                     as-of.relat
                                                     ~
                                                     ~
                                                     *qualified-lookup-type
                                                     ~
                                                     ==
  =/  prior-join        -.set-tables.the-relation
  =/  from-objects      (limo ~[prior-join])
  |-
  ?~  joined-relations  %:  join-return  %join-return
                                         state
                                         from-objects
                                         lookup-type.the-relation
                                         qual-col-types.the-relation
                                         ==
  =.  query-source
        ?:  ?=(qualified-table:ast object.relation.i.joined-relations)
              object.relation.i.joined-relations
            ~|("SELECT: not supported on %query-row" !!)
  =.  the-relation  %:  got-relation  query-source
                                       named-ctes
                                       as-of.i.joined-relations
                                       join.i.joined-relations
                                       predicate.i.joined-relations
                                       lookup-type.the-relation
                                       qual-col-types.the-relation
                                       ==
  =.  prior-join       (join-up prior-join -.set-tables.the-relation)
  %=  $
    joined-relations   +.joined-relations
    from-objects       [prior-join from-objects]
  ==
::
++  got-relation
  |=  $:  ts=qualified-table:ast
          =named-ctes
          as-of=(unit as-of:ast)
          join=(unit join-type:ast)
          =predicate
          lookup-type=qualified-lookup-type
          qualified-columns=(list qual-col-type)
          ==
  ^-  full-relation
  =/  sys-time   (set-tmsp as-of now.bowl)
  =/  db         ~|  "SELECT: database {<database.ts>} does not exist"
                     (~(got by state) database.ts)
  =/  =schema    ~|  "SELECT: database {<database.ts>} ".
                     "doesn't exist at time {<sys-time>}"
                     (get-schema [sys.db sys-time])
  =/  vw  %+  get-view  [namespace.ts name.ts sys-time]
                        views.schema
  ?~  vw  %:  from-table  ts
                          named-ctes
                          db
                          schema
                          join
                          predicate
                          sys-time
                          lookup-type
                          qualified-columns
                          ==
  =/  vw2=view  (need vw)
  =/  r=[database cache]
        (got-view-cache db schema vw2 [namespace.ts name.ts sys-time])
  =/  view-content  (need content.+.r)
  ::
  ::  database view cache may have been populated
  =.  state  ?.  =(db -.r)
                (~(put by state) name.db -.r)
             state
  :^  %full-relation  
      :~  %:  set-table  %set-table
                         [~ ts]
                         [~ tmsp.schema]
                         [~ tmsp.+.r]
                         columns.vw2
                         *unqualified-lookup-type
                         ~
                         join
                         predicate
                         rowcount.view-content
                         ~
                         %+  turn  rows.view-content
                              |=(a=(map @tas @) (indexed-row %indexed-row ~ a))
                         *(list joined-row)
                         ==
          ==
      :-  %qualified-lookup-type
          (~(put by *(map qualified-table (map @tas @ta))) ts type-lookup.vw2)
      (mk-qualified-columns ts qualified-columns columns.vw2)
::
++  from-table
  |=  $:  query-obj=qualified-table:ast
          =named-ctes
          ::alias=(unit @t)
          db=database
          =schema
          join=(unit join-type:ast)
          =predicate
          sys-time=@da
          type-lookup=qualified-lookup-type
          qualified-columns=(list qual-col-type)
          ==
  ^-  full-relation
  =/  tbl  (~(get by tables.schema) [namespace.query-obj name.query-obj])
  ?~  tbl  ~|  "SELECT: table {<database.query-obj>}.{<namespace.query-obj>}".
               ".{<name.query-obj>} does not exist at schema time ".
               "{<tmsp.schema>}"
             `full-relation`(~(got by named-ctes) name.query-obj)
  =/  tbl2=table  (need tbl)
  =/  file
        (get-content content.db sys-time [namespace.query-obj name.query-obj])
  :^  %full-relation
      :~  %:  set-table  %set-table
                         [~ query-obj]
                         [~ tmsp.tbl2]
                         [~ tmsp.file]
                         columns.tbl2
                         [%unqualified-lookup-type type-lookup.tbl2]
                         [~ pri-indx.tbl2]
                         join
                         predicate
                         rowcount.file
                         pri-idx.file
                         indexed-rows.file
                         *(list joined-row)
                         ==
          ==
      :-  %qualified-lookup-type
          (~(put by +.type-lookup) query-obj type-lookup.tbl2)
      (mk-qualified-columns query-obj qualified-columns columns.tbl2)
::
::  +mk-joined-relations:  [relation (list joined-object:ast)]
::                         ->  (list joined-relation)
::
::  put all cross joins at the end of the list
++  mk-joined-relations
  |=  [relat=joined-relation joins=(list joined-object:ast)]
  ^-  (list joined-relation)
  =/  joined-relations=(list joined-relation)    ~[relat]
  =/  cross-joins  *(list joined-relation)
  |-
  ?~  joins  (flop (weld cross-joins joined-relations))
  ?:  ?=(%cross-join join.i.joins)
    %=  $
      joins  t.joins
      cross-joins  :-  %:  joined-relation  %joined-relation
                                            object.i.joins
                                            as-of.i.joins
                                            `join.i.joins
                                            predicate.i.joins
                                            ==
                       cross-joins
    ==  %=  $
    joins  t.joins
    joined-relations  :-  %:  joined-relation  %joined-relation
                                               object.i.joins
                                               as-of.i.joins
                                               `join.i.joins
                                               predicate.i.joins
                                                ==
                   joined-relations
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