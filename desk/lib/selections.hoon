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
  =/  from          (normalize-from (need from.q))
  =/  query-source  ?:  ?=(qualified-table:ast relation.from)
                      relation.from
                    ~|("SELECT: not supported on %query-row" !!)
  =/  =full-relation  %:  got-relation  query-source
                                        named-ctes
                                        as-of.from
                                        ~
                                        ~
                                        *qualified-map-meta
                                        ~
                                        ==
  =/  selected      (normalize-selected columns.select.q)
  =/  filter        ?~  predicate.q  ~
                    :-  ~
                        %^  pred-ops-and-conjs
                            (pred-unqualify-qualified predicate.q)
                            :-  %unqualified-map-meta
                                %-  ~(got by +.map-meta.full-relation)
                                    qualified-table.full-relation
                            ~
  ::
  ?~  set-tables.full-relation  ~|("select-relation can't get here" !!)
  :-  :*  %join-return
          state
          ?.  is-cte   set-tables.full-relation
              (select-for-cte q set-tables.full-relation filter)
          map-meta.full-relation
          column-metas.full-relation
          ==
      ?:  is-cte  *(list vector)
      %:  relation-vectors  filter
                            column-metas.full-relation
                            ?:  is-cte  map-meta.full-relation
                            map-meta.i.set-tables.full-relation
                            ?~  joined-rows.i.set-tables.full-relation
                              indexed-rows.i.set-tables.full-relation
                            joined-rows.i.set-tables.full-relation
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
::      =map-meta  delete those that do not exist
::      pri-indx=(unit index)
::      =predicate
::      pri-indexed=(tree [(list @) (map @tas @)])

::  5) row count
++  select-for-cte
  |=  [q=query:ast set-tables=(list set-table) f=(unit $-(data-row ?))]
  ^-  (list set-table)
  ?~  set-tables  ~|("select-for-cte can't get here" !!)
  =/  st2  i.set-tables
  =.  relation.st2      ~
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
  ?~  f  [st2 set-tables]
  =.  indexed-rows.st2  %+  skim  indexed-rows.st2
                                   |=(a=indexed-row ((need f) a))
  =.  rowcount.st2      (lent indexed-rows.st2)
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
      ~|("{<selected-column>} not supported" !!)
    unqualified-column:ast
      (murn columns |=(a=column:ast ?:(=(name.a name.selected-column) `a ~)))
    selected-aggregate:ast
      ~|("{<selected-column>} not supported" !!)
    selected-value:ast
      ~[[%column `@tas`(need alias.selected-column) p.value.selected-column 0]]
    selected-all:ast
      (flop columns)
    selected-all-table:ast
      (flop columns)
    ==
::
::  +relation-vectors:  $:  (unit $-(data-row ?))
::                          (list column-meta)
::                          map-meta
::                          (list data-row)
::                          (list selected-column:ast)
::                      ->  (list vector)
::
::  tree address of indexed/joined rows off by one
::  need sample column to determin path
++  relation-vectors
  |=  $:  filter=(unit $-(data-row ?))
          column-metas=(list column-meta)
          =map-meta
          rows=(list data-row)
          selected=(list selected-column:ast)
          ==
  ^-  (list vector)
  ?~  rows         *(list vector)
  =/  out-rows     *(set vector)
  =/  templ-cells=(list templ-cell)  %:  mk-rel-vect-templ  column-metas
                                          selected
                                          -.rows
                                          map-meta
                                          ==
  ::
  ?~  templ-cells  ~|("relation-vectors can't get here" !!)
  =/  non-lit  %-  |=  a=(list templ-cell)
                   |-  ^-  (unit templ-cell) 
                   ?~  a  ~
                   ?~  column.i.a  $(a t.a)  [~ i.a]
                   templ-cells


    ::~&  [%column-metas column-metas]
    ::~&  [%map-meta map-meta]
    ::~&  [%row i.rows]
    ::~&  [%non-lit non-lit]



  ?~  non-lit  (indexed-results filter ;;((list indexed-row) rows) templ-cells)
  =/  x        .*(data.i.rows [%0 addr:(need non-lit)])

    ~&  [%x x]

  ?@  x        (joined-results filter ;;((list joined-row) rows) templ-cells)
  (indexed-results filter ;;((list indexed-row) rows) templ-cells)
::
++  indexed-results
  |=  $:  filter=(unit $-(data-row ?))
          rows=(list indexed-row)
          templ-cells=(list templ-cell)
          ==
  ^-  (list vector)
  =/  out-rows   *(set vector)
  |-
  ?~  rows  ~(tap in out-rows)
  =/  include-row=?
    ?~  filter
      %.y
    ((need filter) i.rows)
  ?.  include-row
    $(rows t.rows)
  =/  row                     *(list vector-cell)
  =/  cols=(list templ-cell)  templ-cells
  |-
  ?~  cols
    %=  ^$
      out-rows  (~(put in out-rows) (vector %vector row))
      rows      t.rows
    ==
  ?~  column.i.cols    :: literal
    $(cols t.cols, row [vc.i.cols row])
  %=  $
    cols  t.cols
    row   :-  :-  p.vc.i.cols
                  [p.q.vc.i.cols ;;(@ +:.*(data.i.rows [%0 addr.i.cols]))]
              row
  ==
::
++  joined-results
  |=  $:  filter=(unit $-(data-row ?))
          rows=(list joined-row)
          templ-cells=(list templ-cell)
          ==
  ^-  (list vector)
  =/  out-rows   *(set vector)
  |-
  ?~  rows  ~(tap in out-rows)
  =/  include-row=?
    ?~  filter
      %.y
    ((need filter) i.rows)
  ?.  include-row
    $(rows t.rows)
  =/  row                     *(list vector-cell)
  =/  cols=(list templ-cell)  templ-cells
  |-
  ?~  cols
    %=  ^$
      out-rows  (~(put in out-rows) (vector %vector row))
      rows      t.rows
    ==
  ?~  column.i.cols    :: literal
    $(cols t.cols, row [vc.i.cols row])
  %=  $
    cols  t.cols
    row   :-  :-  p.vc.i.cols
                  [p.q.vc.i.cols ;;(@ .*(data.i.rows [%0 addr.i.cols]))]
              row
  ==
::
::  +join-all  query:ast -> join-return
:: 
::  server state returned because we may have updated the view cache
++  join-all
  |=  [q=query:ast =named-ctes]
  ^-  join-return
  =/  from  (normalize-from (need from.q))
  =/  joined-relations=(list joined-relat)
        %+  mk-joined-relations  :*  %joined-relat
                                     ~
                                     relation.from
                                     as-of.from
                                     ~
                                     ==
                                 joins.from
  =/  relat=joined-relat  -.joined-relations
  =/  query-source  ?:  ?=(qualified-table:ast relation.relat)
                      relation.relat
                    ~|("SELECT: not supported on %query-row" !!)
  =.  joined-relations            +.joined-relations
  =/  =full-relation  %:  got-relation  query-source
                                        named-ctes
                                        as-of.relat
                                        ~
                                        ~
                                        *qualified-map-meta
                                        ~
                                        ==
  =/  prior-join        -.set-tables.full-relation
  =/  from-objects      (limo ~[prior-join])
  |-
  ?~  joined-relations  %:  join-return  %join-return
                                         state
                                         from-objects
                                         map-meta.full-relation
                                         column-metas.full-relation
                                         ==
  =.  query-source
        ?:  ?=(qualified-table:ast relation.i.joined-relations)
              relation.i.joined-relations
            ~|("SELECT: not supported on %query-row" !!)
  =.  full-relation  %:  got-relation  query-source
                                       named-ctes
                                       as-of.i.joined-relations
                                       join.i.joined-relations
                                       predicate.i.joined-relations
                                       map-meta.full-relation
                                       column-metas.full-relation
                                       ==
  =.  prior-join       (join-up prior-join -.set-tables.full-relation)
  %=  $
    joined-relations   +.joined-relations
    from-objects       [prior-join from-objects]
  ==
::
++  got-relation
  ::  branches to +from-table if not a view
  |=  $:  =qualified-table:ast
          =named-ctes
          as-of=(unit as-of:ast)
          join=(unit join-type:ast)
          =predicate
          map-meta=qualified-map-meta
          column-metas=(list column-meta)
          ==
  ^-  full-relation
  =/  sys-time   (set-tmsp as-of now.bowl)
  =/  db         ~|  "SELECT: database {<database.qualified-table>} ".
                      "does not exist"
                     (~(got by state) database.qualified-table)
  =/  =schema    ~|  "SELECT: database {<database.qualified-table>} ".
                     "doesn't exist at time {<sys-time>}"
                     (get-schema [sys.db sys-time])
  =/  vw  %+  get-view
                [namespace.qualified-table name.qualified-table sys-time]
                views.schema
  ?~  vw  %:  from-table  qualified-table
                          named-ctes
                          db
                          schema
                          join
                          predicate
                          sys-time
                          map-meta
                          column-metas
                          ==
  =/  vw2=view  (need vw)
  =/  r=[database cache]
        %:  got-view-cache  db
                            schema
                            vw2
                            :+  namespace.qualified-table
                                name.qualified-table
                                sys-time
                            ==
  =/  view-content  (need content.+.r)
  ::
  ::  database view cache may have been populated
  =.  state  ?.  =(db -.r)
                (~(put by state) name.db -.r)
             state
  :*  %full-relation
      qualified-table
      :~  %:  set-table  %set-table
                         join
                         [~ qualified-table]
                         [~ tmsp.schema]
                         [~ tmsp.+.r]
                         columns.vw2
                         predicate
                         rowcount.view-content
                         [%unqualified-map-meta typ-addr-lookup.vw2]
                         ~
                         ~
                         %+  turn  rows.view-content
                              |=(a=(map @tas @) (indexed-row %indexed-row ~ a))
                         *(list joined-row)
                         ==
          ==
      :-  %qualified-map-meta
          %+  ~(put by *(map qualified-table:ast (map @tas typ-addr)))
                qualified-table
                typ-addr-lookup.vw2
      (mk-column-metas qualified-table column-metas columns.vw2)
      ==
::
++  from-table
  :: if table doesn't exist, it can only be a CTE
  |=  $:  =qualified-table:ast
          =named-ctes
          db=database
          =schema
          join=(unit join-type:ast)
          =predicate
          sys-time=@da
          map-meta=qualified-map-meta
          column-metas=(list column-meta)
          ==
  ^-  full-relation
  =/  tbl  %-  ~(get by tables.schema)
               [namespace.qualified-table name.qualified-table]
  ?~  tbl  ~|  "SELECT: table {<database.qualified-table>}.".
               "{<namespace.qualified-table>}.{<name.qualified-table>} does ".
               "not exist at schema time {<tmsp.schema>}"
           (~(got by named-ctes) name.qualified-table)
  =/  tbl2=table  (need tbl)
  =/  file  %^  get-content  content.db
                             sys-time
                             [namespace.qualified-table name.qualified-table]
  :*  %full-relation
      qualified-table
      :~  %:  set-table  %set-table
                         join
                         [~ qualified-table]
                         [~ tmsp.tbl2]
                         [~ tmsp.file]
                         columns.tbl2
                         predicate
                         rowcount.file
                         [%unqualified-map-meta typ-addr-lookup.tbl2]
                         [~ pri-indx.tbl2]
                         pri-idx.file
                         indexed-rows.file
                         *(list joined-row)
                         ==
          ==
      :-  %qualified-map-meta
          (~(put by +.map-meta) qualified-table typ-addr-lookup.tbl2)
      (mk-column-metas qualified-table column-metas columns.tbl2)
      ==
::
::  +mk-joined-relations:  [relation (list joined-relation:ast)]
::                         ->  (list joined-relat)
::
::  put all cross joins at the end of the list
++  mk-joined-relations
  |=  [relat=joined-relat joins=(list joined-relation:ast)]
  ^-  (list joined-relat)
  =/  joined-relations=(list joined-relat)    ~[relat]
  =/  cross-joins  *(list joined-relat)
  |-
  ?~  joins  (flop (weld cross-joins joined-relations))
  ?:  ?=(%cross-join join.i.joins)
    %=  $
      joins  t.joins
      cross-joins  :-  :*  %joined-relat
                           `join.i.joins
                           (normalize-relation relation.i.joins)
                           as-of.i.joins
                           predicate.i.joins
                           ==
                       cross-joins
    ==  %=  $
    joins  t.joins
    joined-relations  :-  :*  %joined-relat
                              `join.i.joins
                                (normalize-relation relation.i.joins)
                                as-of.i.joins
                                predicate.i.joins
                              ==
                   joined-relations
  ==
::
::  +got-view-cache:
::    [database schema view ns-rel-key (list selected-column:ast)]
::    -> [database cache]
++  got-view-cache
  |=  [db=database =schema vw=view key=ns-rel-key]
  ^-  [database cache]
  =/  vw-cache=cache  (get-view-cache key view-cache.db)
  ?.  =(content.vw-cache ~)  [db vw-cache]
  =.  content.vw-cache  ?:  =(ns.key 'sys')
                              :-  ~
                                  %:  populate-system-view  state
                                                            db
                                                            schema
                                                            vw
                                                            rel.key
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
                        (~(put by data.i.a) (need relation.this) data.i.b)
                  %:  joined-from-indexed  i.a
                                           (need relation.prior)
                                           i.b
                                           (need relation.this)
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
                                          (need relation.prior)
                                          indexed-rows.this
                                          (need relation.this)
                                          this-key
                                        ==
                      %:  join-pri-key  joined-rows.prior
                                        (need relation.prior)
                                        indexed-rows.this
                                        (need relation.this)
                                        this-key
                                        ==
  ?:  =(prior-key this-key)
    (joined-set-table this -.count-and-rows +.count-and-rows)
  ::  key is same column sequence, but different ordering
  ?:  ?!  .=  (turn prior-key |=(a=key-column [name.a aura.a]))
              (turn this-key |=(a=key-column [name.a aura.a]))
    ~|  "no natural join or foreign key join, columns do not match: ".
        "{<(need relation.this)>}"
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
                              (need relation.prior)
                              indexed-rows.this
                              (need relation.this)
                              this-key
                              ==
          %:  join-pri-key  %+  sort  joined-rows.prior
                                   ~(order data-row-comp (reduce-key the-key))
                            (need relation.prior)
                            indexed-rows.this
                            (need relation.this)
                            this-key
                            ==
        ?~  joined-rows.prior
          %:  join-pri-key  indexed-rows.prior
                            (need relation.prior)
                            %+  sort  indexed-rows.this
                                    ~(order data-row-comp (reduce-key the-key))
                            (need relation.this)
                            prior-key
                            ==
        %:  join-pri-key  joined-rows.prior
                          (need relation.prior)
                          %+  sort  indexed-rows.this
                                  ~(order data-row-comp (reduce-key the-key))
                          (need relation.this)
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
::
::  +data-row-comp
::
::  comparator for index mops
++  data-row-comp
  |_  index=(list [@tas ?])
  ++  order
    |=  [a=[data-row] b=[data-row]]
    =/  p  key.a
    =/  q  key.b
    =/  k=(list [@tas ?])  index
    |-  ^-  ?
    ?:  =(-.p -.q)  $(k +.k, p +.p, q +.q)
    ?:  =(-<.k %t)  (alpha -.q -.p)
    ?:  ->.k  (gth -.p -.q)
    (lth -.p -.q)
  --
++  get-schema
    |=  [sys=((mop @da schema) gth) time=@da]
    ^-  schema
    =/  time-key  (add time 1)
    ~|  "schema not available for {<time>}"
    ->:(pop:schema-key (lot:schema-key sys `time-key ~))
++  get-view-cache
  |=  [key=ns-rel-key q=((mop ns-rel-key cache) ns-rel-comp)]
  ^-  cache
  =/  vw  (tab:view-cache-key q `[ns.key rel.key `@da`(add `@`time.key 1)] 1)
  ?~  vw
    ~|("view {<ns.key>}.{<rel.key>} does not exist from time {<time.key>}" !!)
  ->.vw
::
::  +put-view-cache
++  put-view-cache
  |=  [db=database value=cache key=ns-rel-key]
  ^-  database
  =/  gate  put:((on ns-rel-key cache) ns-rel-comp)
  db(view-cache (gate view-cache.db [key value]))
::
++  key-atom
  |=  a=[p=@tas q=(map @tas @)]
  ^-  @
  ~|  "key atom {<p.a>} not supported"
  (~(got by q.a) p.a)
--