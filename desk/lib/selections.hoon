/-  ast, *obelisk, *server-state
/+  *sys-views, *utils, *predicate, *scalars, mip
|_  [state=server =bowl:gall]
::
++  license
  ::  MIT+n license
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
++  select-relation
  ::  selection from a single table without joins
  |=  [q=query:ast is-cte=? =named-ctes]
  ^-  [join-return (list vector)]
  =/  from          (normalize-from (need from.q))
  =/  =full-relation  %:  source-full-relation  relation.from
                                                named-ctes
                                                as-of.from
                                                ~
                                                ~
                                                *qualified-map-meta
                                                ~
                                                ==
  =/  selected      (normalize-selected columns.select.q)
  =/  qualifier-lookup
        (query-qualifier-lookup set-tables.full-relation)
  =/  resolved-scalars
        %:  resolve-query-scalars  scalars.q
                                   named-ctes
                                   qualifier-lookup
                                   map-meta.full-relation
                                   ==
  =/  filter        ?~  predicate.q  ~
                    :-  ~
                        %:  prepare-predicate
                            (pred-unqualify-qualified predicate.q)
                            :-  %unqualified-map-meta
                                %-  ~(got by +.map-meta.full-relation)
                                    qualifier.full-relation
                            ~
                            named-ctes
                            resolved-scalars
                            ==
  ::
  ?~  set-tables.full-relation  ~|("select-relation can't get here" !!)
  :-  :*  %join-return
          state
          ?.  is-cte   set-tables.full-relation
              %-  select-for-cte
              [q set-tables.full-relation filter named-ctes resolved-scalars]
          map-meta.full-relation
          column-metas.full-relation
          ==
      ?:  is-cte  *(list vector)
      %-  relation-vectors
      :*  filter
          column-metas.full-relation
          ?:  is-cte  map-meta.full-relation
          map-meta.i.set-tables.full-relation
          ?~  joined-rows.i.set-tables.full-relation
            indexed-rows.i.set-tables.full-relation
          joined-rows.i.set-tables.full-relation
          selected
          resolved-scalars
          named-ctes
          ==
::
::  Build lookup qualifier by column name for resolving unqualified columns in
::  scalar functions on a single relation.
++  query-qualifier-lookup
  |=  sources=(list set-table)
  ^-  qualifier-lookup
  =/  lookup  *qualifier-lookup
  |-
  ?~  sources  lookup
  =/  source=set-table  i.sources
  ?~  relation.source  $(sources t.sources)
  =/  columns=(list column:ast)  columns.source
  |-
  ?~  columns  ^$(sources t.sources)
  =/  col=column:ast  -.columns
  %=  $
    columns  +.columns
    lookup   ?:  (~(has by lookup) name.col)
               %+  ~(put by lookup)
                      name.col
                      :-  (need relation.source)
                          (~(got by lookup) name.col)
             %+  ~(put by lookup)  name.col
                                   (limo ~[(need relation.source)])
  ==
::
++  resolve-query-scalars
  |=  $:  scalars=(list scalar:ast)
          =named-ctes
          =qualifier-lookup
          =map-meta
          ==
  ^-  resolved-scalars
  =/  out  *resolved-scalars
  =/  =seed  eny.bowl
  |-
  ?~  scalars  out
  =/  ps  %:  prepare-scalar  f.i.scalars
                              named-ctes
                              qualifier-lookup
                              map-meta
                              out
                              bowl
                              seed
                              ==
  =.  seed  -.ps
  %=  $
    scalars  t.scalars
    out      (~(put by out) name.i.scalars +.ps)
    seed     seed
  ==
::
++  select-for-cte
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
  |=  [q=query:ast set-tables=(list set-table) f=(unit $-(data-row ?)) =named-ctes =resolved-scalars]
  ^-  (list set-table)
  ?~  set-tables  ~|("select-for-cte can't get here" !!)
  =/  st2  i.set-tables
  =.  relation.st2      ~
  =/  col-map       (malt (turn columns.i.set-tables |=(a=column:ast [name.a a])))
  =/  flipped-cols  (flop columns.i.set-tables)
  =.  columns.st2     %-  flop
                        ^-  (list column:ast)  %-  zing
                            %+  turn  columns.select.q
                                      |=  a=selected-column:ast
                                      %-  selected-column-to-column
                                      [named-ctes col-map flipped-cols a resolved-scalars]
  
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
++  count-keys
  ::  If key exists in selected columns then count, emit, and potentially rename
  ::  to alias.
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
++  selected-table-cols
  ::  Create look-up from original table column name to name or alias in SELECT,
  ::  used in deciding if key is preserved and renaming key columns.
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
  ?:  ?=(selected-cte-column:ast a)
    (~(put by b) name.a [name.a alias.a])
  b
::
++  selected-column-to-column
  |=  $:  =named-ctes
          col-map=(map @tas column:ast)
          flipped-cols=(list column:ast)
          =selected-column:ast
          =resolved-scalars
          ==
  ^-  (list column:ast)
  ?-  selected-column
    qualified-column:ast
      ~|("{<selected-column>} not supported" !!)
    unqualified-column:ast
      ~[(~(got by col-map) name.selected-column)]
    selected-aggregate:ast
      ~|("{<selected-column>} not supported" !!)
    selected-scalar:ast
      =/  rs=resolved-scalar
        ~|  "{<selected-column>} not in resolved-scalars"
        (~(got by resolved-scalars) name.selected-column)
      ~[[%column (heading selected-column name.selected-column) (resolved-scalar-type rs) 0]]
    selected-value:ast
      ~[[%column `@tas`(need alias.selected-column) p.value.selected-column 0]]
    selected-all:ast
      flipped-cols
    selected-all-table:ast
      flipped-cols
    selected-cte-column:ast
      =/  cte-fr  (~(got by named-ctes) cte.selected-column)
      =/  ta=typ-addr  %+  ~(got bi:mip +.map-meta.cte-fr)  [%cte-name cte.selected-column]
                                                              name.selected-column
      ~[[%column (heading selected-column name.selected-column) type.ta 0]]
    ==
::
++  relation-vectors
  ::  tree address of indexed/joined rows off by one
  ::  need sample column to determin path
  |=  $:  filter=(unit $-(data-row ?))
          column-metas=(list column-meta)
          =map-meta
          rows=(list data-row)
          selected=(list selected-column:ast)
          =resolved-scalars
          =named-ctes
          ==
  ^-  (list vector)
  ?~  rows         *(list vector)
  =/  out-rows     *(set vector)
  =/  templ-cells=(list templ-cell)
    %-  mk-rel-vect-templ
    [column-metas selected -.rows map-meta resolved-scalars named-ctes]
  ::
  ?~  templ-cells  ~|("relation-vectors can't get here" !!)
  =/  non-lit  %-  |=  a=(list templ-cell)
                   |-  ^-  (unit templ-cell) 
                   ?~  a  ~
                   ?~  column.i.a  $(a t.a)  [~ i.a]
                   templ-cells
  ?~  non-lit
    ?-  -.i.rows
      %joined-row  (joined-results filter ;;((list joined-row) rows) templ-cells)
      %indexed-row  (indexed-results filter ;;((list indexed-row) rows) templ-cells)
    ==
  =/  x        .*(data.i.rows [%0 addr:(need non-lit)])
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
  =/  row                     *(list vector-cell:ast)
  =/  cols=(list templ-cell)  templ-cells
  |-
  ?~  cols
    %=  ^$
      out-rows  (~(put in out-rows) (vector %vector row))
      rows      t.rows
    ==
  ?^  scalar.i.cols
    =/  x=dime  (resolve-selected-scalar i.rows (need scalar.i.cols))
    $(cols t.cols, row [[p.vc.i.cols [p.x q.x]] row])
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
  =/  row                     *(list vector-cell:ast)
  =/  cols=(list templ-cell)  templ-cells
  |-
  ?~  cols
    %=  ^$
      out-rows  (~(put in out-rows) (vector %vector row))
      rows      t.rows
    ==
  ?^  scalar.i.cols
    =/  x=dime  (resolve-selected-scalar i.rows (need scalar.i.cols))
    $(cols t.cols, row [[p.vc.i.cols [p.x q.x]] row])
  ?~  column.i.cols    :: literal
    $(cols t.cols, row [vc.i.cols row])
  %=  $
    cols  t.cols
    row   :-  :-  p.vc.i.cols
                  [p.q.vc.i.cols ;;(@ .*(data.i.rows [%0 addr.i.cols]))]
              row
  ==
::
::  recalculate addr for joined data structure
++  recalc-addr
  |=  [=set-table =full-relation from-objects=(list set-table)]
  ?~  joined-rows.set-table
    :*  %join-return
                      state
                      from-objects
                      map-meta.full-relation
                      column-metas.full-relation
                      ==
  =/  r=[(list column-meta) qualified-map-meta]
    %^  spin  column-metas.full-relation
              *qualified-map-meta
              |=  [=column-meta mm=qualified-map-meta]
              =/  new-addr
                    %^  calc-joined-addr  data.i.joined-rows.set-table
                                          qualifier.qualified-column.column-meta
                                          name.qualified-column.column-meta
              =.  addr.column-meta  new-addr
              :-  column-meta
                  :-  %qualified-map-meta
                      %^  ~(put bi:mip +.mm)
                            qualifier.qualified-column.column-meta
                            name.qualified-column.column-meta
                            [type.column-meta new-addr]
  :*  %join-return
                    state
                    from-objects
                    +.r
                    -.r
                    ==
::
++  join-all
  ::  server state returned because we may have updated the view cache
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
  =/  source-db=@tas      (source-db-name relation.relat)
  =.  joined-relations    +.joined-relations
  =/  =full-relation  %:  source-full-relation  relation.relat
                                                named-ctes
                                                as-of.relat
                                                ~
                                                ~
                                                *qualified-map-meta
                                                ~
                                                ==
  =/  prior-join          -.set-tables.full-relation
  =/  from-objects        (limo ~[prior-join])
  =/  prev-as-of          as-of.relat
  =/  prev-db-name=@tas   source-db
  |-
  ?~  joined-relations  (recalc-addr prior-join full-relation from-objects)
  =.  source-db         (source-db-name relation.i.joined-relations)
  =/  needs-refresh     ?|  !=(as-of.i.joined-relations prev-as-of)
                            !=(source-db prev-db-name)
                             ==
  =.  full-relation  %:  source-full-relation  relation.i.joined-relations
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
    prev-as-of         as-of.i.joined-relations
    prev-db-name       source-db
  ==
::
++  source-db-name
  |=  rel=relation:ast
  ^-  @tas
  ?-  -.rel
    %qualified-table
      database:;;(qualified-table:ast rel)
    %cte-name
      %cte
    %query-row
      ~|("SELECT: not supported on %query-row" !!)
  ==
::
++  source-full-relation
  |=  $:  rel=relation:ast
          =named-ctes
          as-of=(unit as-of:ast)
          join=(unit join-type:ast)
          =predicate
          map-meta=qualified-map-meta
          column-metas=(list column-meta)
          ==
  ^-  full-relation
  ?-  -.rel
    %qualified-table
      =/  qt=qualified-table:ast  rel
      =/  sys-time=@da  (set-tmsp as-of now.bowl)
      =/  db=database   ~|  "SELECT: database {<database.qt>} does not exist"
                         (~(got by state) database.qt)
      =/  =schema       ~|  "SELECT: database {<database.qt>} ".
                          "doesn't exist at time {<sys-time>}"
                          (get-schema [sys.db sys-time])
      %:  got-relation  qt
                        named-ctes
                        as-of
                        db
                        schema
                        join
                        predicate
                        map-meta
                        column-metas
                        ==
    %cte-name
      =/  qt=qualified-table:ast
        :*  %qualified-table
            ship=~
            database=%cte
            namespace=%cte
            name=name:;;(cte-name:ast rel)
            alias=~
            ==
      %:  from-cte  qt
                    named-ctes
                    *schema
                    map-meta
                    column-metas
                    ==
    %query-row
      ~|("SELECT: not supported on %query-row" !!)
  ==
::
++  got-relation
  ::  branches to +from-table if not a view
  |=  $:  =qualified-table:ast
          =named-ctes
          as-of=(unit as-of:ast)
          db=database
          =schema
          join=(unit join-type:ast)
          =predicate
          map-meta=qualified-map-meta
          column-metas=(list column-meta)
          ==
  ^-  full-relation
  =/  sys-time   (set-tmsp as-of now.bowl)
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
  =/  r=[? database cache]
        %:  got-view-cache  db
                            schema
                            vw2
                            :+  namespace.qualified-table
                                name.qualified-table
                                sys-time
                            ==
  =/  view-content  (need content.+>.r)
  ::
  ::  database view cache may have been populated
  =.  state  ?:  -.r
                (~(put by state) name.db +<.r)
             state
  :*  %full-relation
      qualified-table
      :~  :*  %set-table
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
                   |=(a=(map @tas @) [%indexed-row ~ a])
              *(list joined-row)
              ==
          ==
      :-  %qualified-map-meta
          %+  ~(put by *(map qualifier (map @tas typ-addr)))
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
  ?~  tbl  %:  from-cte  qualified-table
                         named-ctes
                         schema
                         map-meta
                         column-metas
                         ==
  =/  tbl2=table  (need tbl)
  =/  file  %^  get-content  content.db
                             sys-time
                             [namespace.qualified-table name.qualified-table]
  :*  %full-relation
      qualified-table
      :~  :*  %set-table
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
++  from-cte
  ::  wrap a CTE as an opaque relation so its internal
  ::  source tables don't leak into canonical-list
  |=  $:  =qualified-table:ast
          =named-ctes
          =schema
          map-meta=qualified-map-meta
          column-metas=(list column-meta)
          ==
  ^-  full-relation
  =/  cte-fr  ~|  "SELECT: table {<database.qualified-table>}.".
                  "{<namespace.qualified-table>}.{<name.qualified-table>} ".
                  "does not exist at schema time {<tmsp.schema>}"
              (~(got by named-ctes) name.qualified-table)
  ?~  set-tables.cte-fr  ~|("from-cte: empty set-tables" !!)
  =/  cte-st  i.set-tables.cte-fr
  =.  relation.cte-st  [~ qualified-table]
  =/  cte-col-meta
    (need (~(get by +.map-meta.cte-fr) [%cte-name name.qualified-table]))
  :*  %full-relation
      qualified-table
      [cte-st ~]
      :-  %qualified-map-meta
          (~(put by +.map-meta) qualified-table cte-col-meta)
      ::  use CTE's original column-metas (correct addr from
      ::  calc-joined-addr for JOINs) rebranded to outer qualified-table
      %+  weld  column-metas
      %+  turn  column-metas.cte-fr
      |=  cm=column-meta
      :+  :^  %qualified-column
              (normalize-qt-alias qualified-table)
              name.qualified-column.cm
              alias.qualified-column.cm
          type.cm
          addr.cm
      ==
::
++  mk-joined-relations
  ::  put all cross joins at the end of the list
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
++  got-view-cache
  |=  [db=database =schema vw=view key=ns-rel-key]
  ^-  [? database cache]
  =/  vw-cache=cache  (get-view-cache key view-cache.db)
  ?.  =(content.vw-cache ~)  [%.n db vw-cache]
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
  [%.y (put-view-cache db vw-cache key) vw-cache]
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
  ^-  @tas
  name.a
::
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
  =/  rel-prior  (need relation.prior)
  =/  rel-this   (need relation.this)
  :: perfect natural join
  =/  count-and-rows  ?.  =(prior-key this-key)  [0 ~]
                      ?~  joined-rows.prior
                        %:  join-pri-key  indexed-rows.prior
                                          rel-prior
                                          indexed-rows.this
                                          rel-this
                                          this-key
                                        ==
                      %:  join-pri-key  joined-rows.prior
                                        rel-prior
                                        indexed-rows.this
                                        rel-this
                                        this-key
                                        ==
  ?:  =(prior-key this-key)
    (joined-set-table this -.count-and-rows +.count-and-rows)
  ::  key is same column sequence, but different ordering
  ?:  ?!  .=  (turn prior-key |=(a=key-column [name.a aura.a]))
              (turn this-key |=(a=key-column [name.a aura.a]))
    ~|  "no natural join or foreign key join, columns do not match: ".
        "{<rel-this>}"
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
                              rel-prior
                              indexed-rows.this
                              rel-this
                              this-key
                              ==
          %:  join-pri-key  %+  sort  joined-rows.prior
                                   ~(order data-row-comp (reduce-key the-key))
                            rel-prior
                            indexed-rows.this
                            rel-this
                            this-key
                            ==
        ?~  joined-rows.prior
          %:  join-pri-key  indexed-rows.prior
                            rel-prior
                            %+  sort  indexed-rows.this
                                    ~(order data-row-comp (reduce-key the-key))
                            rel-this
                            prior-key
                            ==
        %:  join-pri-key  joined-rows.prior
                          rel-prior
                          %+  sort  indexed-rows.this
                                  ~(order data-row-comp (reduce-key the-key))
                          rel-this
                          prior-key
                          ==
  ::
  (joined-set-table this -.count-and-rows +.count-and-rows)
::
++  joined-set-table
  |=  [st=set-table row-count=@ud joined-rows=(list joined-row)]
  ^-  set-table
  =.  rowcount.st     row-count
  =.  joined-rows.st  joined-rows
  st
::
++  join-pri-key
  ::  joins the data of two tables having the same key
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
++  data-row-comp
  ::
  ::  comparator for index mops
  |_  index=(list [@tas ?])
  ++  order
    |=  [a=[data-row] b=[data-row]]
    =/  p  key.a
    =/  q  key.b
    =/  k=(list [@tas ?])  index
    |-  ^-  ?
    ?:  =(-.p -.q)  $(k +.k, p +.p, q +.q)
    ?:  =(-<.k %t)  (alpha -.q -.p)
    ?:  =(-<.k %rd)
      ?:  ->.k  (gth:rd -.p -.q)
      (lth:rd -.p -.q)
    ?:  =(-<.k %sd)
      ?:  ->.k  =((cmp:si `@s`-.p `@s`-.q) --1)
      =((cmp:si `@s`-.p `@s`-.q) -1)
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
