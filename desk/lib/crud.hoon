/-  ast, *obelisk, *server-state
/+  *utils, *selections, *predicate, mip
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
++  truncate-tbl
  ::  Unlike the other data manipulation functions (INSERT, DELETE, UPDATE),
  ::  TRUNCATE TABLE can future date its action. This however effectively locks
  ::  the database for data updates until that time.
  |=  $:  d=truncate-table:ast
          next-schemas=(map @tas @da)
          next-data=(map @tas @da)
          ==
  ^-  [cmd-result (map @tas @da) (map @tas @da) server]
  =/  db  ~|  "TRUNCATE TABLE: database {<database.table.d>} does not exist"
             (~(got by state) database.table.d)
  =/  sys-time  (set-tmsp as-of.d now.bowl)
  =/  nxt-schema=schema
        ~|  "TRUNCATE TABLE: {<name.table.d>} as-of schema time out of order"
          %:  get-next-schema  sys.db
                              next-schemas
                              sys-time
                              database.table.d
                              ==
  =/  nxt-data=data
        ~|  "TRUNCATE TABLE: {<name.table.d>} as-of data time out of order"
            %:  get-next-data  content.db
                               next-data
                               sys-time
                               database.table.d
                               ==
  ::
  ?.  (~(has by namespaces.nxt-schema) namespace.table.d)
    ~|("TRUNCATE TABLE: namespace {<namespace.table.d>} does not exist" !!)
  ::
  =/  tables
    ~|  "TRUNCATE TABLE: {<name.table.d>} ".
        "does not exists in {<namespace.table.d>}"
    %-  ~(got by tables:nxt-schema)
        [namespace.table.d name.table.d]
  ::
  =/  file
    ~|  "TRUNCATE TABLE: {<namespace.table.d>}.{<name.table.d>} does not exist"
        (~(got by files.nxt-data) [namespace.table.d name.table.d])
  ?.  (gth rowcount.file 0)  :: don't bother if table is empty
    :^  :-  %results
            :~  :-  %message
                    %-  crip
                        %+  weld  "TRUNCATE TABLE "
                            (trip (qualified-table-to-cord table.d))
                [%message 'no data in table to truncate']
                ==
        next-schemas
        next-data
        state

  ::
  =/  dropped-rows  rowcount.file
  =.  pri-idx.file         ~
  =.  indexed-rows.file    ~
  =.  rowcount.file        0
  =.  tmsp.file            sys-time
  =/  files  (~(put by files.nxt-data) [namespace.table.d name.table.d] file)
  =.  files.nxt-data       files
  =.  ship.nxt-data        src.bowl
  =.  provenance.nxt-data  sap.bowl
  =.  tmsp.nxt-data        sys-time
  ::
  =.  content.db     (put:data-key content.db sys-time nxt-data)
  =.  view-cache.db  (upd-view-caches state db sys-time ~ %truncate-table)
  =.  state          (update-sys state sys-time)
  ::
  :^  :-  %results
          :~  :-  %message
                  %-  crip
                      %+  weld  "TRUNCATE TABLE "
                          (trip (qualified-table-to-cord table.d))
              [%server-time now.bowl]
              [%data-time sys-time]
              [%vector-count dropped-rows]
              ==
      next-schemas
      (~(put by next-data) database.table.d sys-time)
      (~(put by state) name.db db)
::
++  do-selection
  |=  $:  =selection:ast
          query-has-run=?
          next-data=(map @tas @da)
          next-schemas=(map @tas @da)
      ==
  ^-  [? [(map @tas @da) server (list result)]]
  =/  named-ctes   (named-queries ctes.selection *named-ctes)
  =/  rtree        (~(rdc of set-functions.selection) rdc-set-func)
  ?-  -<.rtree
    %insert
      ?:  query-has-run  ~|("INSERT: state change after query in script" !!)
      :-  %.n
          ::~&  "{<->->+>+.rtree>}"   :: table name
          ::~>  %bout.[0 %insert]
          (do-insert -.rtree next-data next-schemas)
    %query
      :-  %.y
          ::~&  "{<->->+.rtree>}"   :: from objects
          ::~>  %bout.[0 %select]
          =/  rt  (do-query -.rtree named-ctes %.n)
          [next-data ->-.rt (select-results named-ctes -.rt +.rt)]
    %merge
      ?:  query-has-run  ~|("MERGE: state change after query in script" !!)
      !!
    ==
::
++  do-insert
  |=  [ins=insert:ast next-data=(map @tas @da) next-schemas=(map @tas @da)]
    :: to do: aura validation? (isn't this covered in testing? see roadmap)
  ^-  [(map @tas @da) server (list result)]
  =/  txn  (common-txn "INSERT" state now.bowl table.ins as-of.ins next-schemas)
  ::
  =.  tmsp.file.txn            now.bowl
  =.  ship.nxt-data.txn        src.bowl
  =.  provenance.nxt-data.txn  sap.bowl
  =.  tmsp.nxt-data.txn        now.bowl
  ::
  =/  cols=(list column:ast)
        ?~  columns.ins
          columns.table.txn
        ?.  .=  ~(wyt by column-lookup.table.txn)
                ~(wyt in (silt (need columns.ins)))
          ~|("INSERT: incorrect columns specified: {<columns.ins>}" !!)
        %+  turn
            `(list @t)`(need columns.ins)
            |=(a=@t (to-column a column-lookup.table.txn))
  ::
  ?.  ?=([%data *] values.ins)  ~|("INSERT: not implemented: {<values.ins>}" !!)
  =/  value-table  `(list (list value-or-default:ast))`+.values.ins
  ::
  ?.  =((lent cols) (lent -.value-table))
        ~|("INSERT: incorrect columns specified: {<-.value-table>}" !!)
  ::
  =/  i=@ud  0
  =/  key-pick=(list [@tas @])
        %+  turn
            key.pri-indx.table.txn
            |=(a=key-column (make-key-pick name.a column-lookup.table.txn))
  =/  primary-key  (pri-key key.pri-indx.table.txn)
  =/  kns=(set @tas)  (silt (turn key-pick |=(a=[@tas @] -.a)))
  ::
  =.  state          (update-sys state now.bowl)
  ::
  |-
  ?~  value-table
    :+  (~(put by next-data) database.table.ins now.bowl)
      :: %:  upd-indices-views to do: revisit when there are views & indices
      %+  ~(put by state)  name.db.txn
                           %=  db.txn
                              content
                                %^  put:data-key
                                      content.db.txn
                                      now.bowl
                                      %:  update-file  file.txn
                                                       nxt-data.txn
                                                       tbl-key.txn
                                                       key.pri-indx.table.txn
                                                       i
                                                       ==
                              view-cache  %:  upd-view-caches  state
                                                                db.txn
                                                                now.bowl
                                            :: to do: get list of effected views
                                                                [~ ~]
                                                                %insert
                                                                ==
                            ==
      :~  :-  %message
              %-  crip
                  %+  weld  "INSERT INTO "
                            (trip (qualified-table-to-cord table.ins))
          [%server-time now.bowl]
          [%schema-time tmsp.table.txn]
          [%data-time source-content-time.txn]
          [%message 'inserted:']
          [%vector-count i]
          [%message 'table data:']
          [%vector-count (add rowcount.file.txn i)]
          ==
  ~|  "INSERT: {<tbl-key.txn>} row {<+(i)>}"
  =/  row=(list value-or-default:ast)  -.value-table
  =/  rw  (row-cells-and-keys row cols kns)
  =/  file-row=(map @tas @)   -.rw
  =/  key-map=(map @tas @)    +.rw
  =/  row-key=(list @)
        %+  turn
            key-pick
            |=(a=[@tas @] (~(got by key-map) -.a))
  =.  pri-idx.file.txn  ?:  (has:primary-key pri-idx.file.txn row-key)
                          ~|("INSERT: cannot add duplicate key: {<row-key>}" !!)
                        (put:primary-key pri-idx.file.txn row-key file-row)
  $(i +(i), value-table `(list (list value-or-default:ast))`+.value-table)
::
++  do-delete
  |=  [d=delete:ast next-schemas=(map @tas @da) next-data=(map @tas @da)]
  ^-  [(map @tas @da) server (list result)]
  =/  txn  %:  common-txn  "DELETE FROM"
                           state
                           now.bowl
                           table.d
                           as-of.d
                           next-schemas
                           ==
  ?.  (gth rowcount.file.txn 0)  :: don't bother if table is empty
    :+  next-data
        state
        :~  :-  %message
                %-  crip
                    "DELETE FROM {<namespace.table.d>}.{<name.table.d>}"
            [%server-time now.bowl]
            [%schema-time tmsp.table.txn]
            [%data-time tmsp.file.txn]
            [%message 'no rows deleted']
            ==
  ::
  =/  filter=$-(data-row ?)  %:  prepare-predicate
                                 (pred-unqualify-qualified predicate.d)
                                 :-  %unqualified-map-meta
                                     typ-addr-lookup.table.txn
                                 ~
                                 *named-ctes
                                 *resolved-scalars
                                 ==
  =.  indexed-rows.file.txn  %+  skim  indexed-rows.file.txn
                                       |=(a=indexed-row !(filter a))
  :: 
  =/  primary-key  (pri-key key.pri-indx.table.txn)
  =/  comparator
        ~(order idx-comp `(list [@ta ?])`(reduce-key key.pri-indx.table.txn))

  =.  pri-idx.file.txn
      %+  gas:primary-key  *((mop (list @) ,(map @tas @)) comparator)
                           (turn indexed-rows.file.txn |=(a=indexed-row +.a))
  ::
  =/  rowcount  (lent indexed-rows.file.txn)
  =/  deleted-rows  (sub rowcount.file.txn rowcount)
  ?:  =(deleted-rows 0)
    :+  next-data
        state
        :~  :-  %message
                %-  crip
                    %+  weld  "DELETE FROM "
                              (trip (qualified-table-to-cord table.d))
            [%server-time now.bowl]
            [%schema-time tmsp.table.txn]
            [%data-time tmsp.file.txn]
            [%message 'no rows deleted']
            ==
  =.  rowcount.file.txn        rowcount
  =.  tmsp.file.txn            now.bowl
  =/  files                    %+  ~(put by files.nxt-data.txn)
                                   [namespace.table.d name.table.d]
                                   file.txn
  =.  files.nxt-data.txn       files
  =.  ship.nxt-data.txn        src.bowl
  =.  provenance.nxt-data.txn  sap.bowl
  =.  tmsp.nxt-data.txn        now.bowl
  ::
  =.  content.db.txn     (put:data-key content.db.txn now.bowl nxt-data.txn)
  =.  view-cache.db.txn  (upd-view-caches state db.txn now.bowl ~ %delete)
  =.  state          (update-sys state now.bowl)
  ::
  :+  (~(put by next-data) database.table.d now.bowl)
      (~(put by state) name.db.txn db.txn)
      :~  :-  %message
              %-  crip
                  %+  weld  "DELETE FROM "
                            (trip (qualified-table-to-cord table.d))
          [%server-time now.bowl]
          [%schema-time tmsp.table.txn]
          [%data-time source-content-time.txn]
          [%message 'deleted:']
          [%vector-count deleted-rows]
          [%message msg='table data:']
          [%vector-count rowcount.file.txn]
          ==
::
++  do-update
  |=  [u=update:ast next-schemas=(map @tas @da) next-data=(map @tas @da)]
  ^-  [(map @tas @da) server (list result)]
  =/  txn  %:  common-txn  "UPDATE"
                           state
                           now.bowl
                           table.u
                           as-of.u
                           next-schemas
                           ==
  ?.  (gth rowcount.file.txn 0)  :: don't bother if table is empty
    :+  next-data
        state
        :~  :-  %message
                %-  crip
                    "UPDATE {<namespace.table.u>}.{<name.table.u>}"
            [%server-time now.bowl]
            [%schema-time tmsp.table.txn]
            [%data-time tmsp.file.txn]
            [%message 'no rows updated']
            ==
  ::
  ?.  =((lent columns.u) (lent values.u))
    ~|("UPDATE: columns and values mismatch" !!)
  =/  filter  ?~  predicate.u  ~
              :-  ~
                  %:  prepare-predicate  %-  pred-unqualify-qualified
                                              predicate.u
                                          :-  %unqualified-map-meta
                                              typ-addr-lookup.table.txn
                                          ~
                                          *named-ctes
                                          *resolved-scalars
                                          ==
  =/  updates  %:  mk-updates  table.u
                               columns.u
                               values.u
                               :-  %unqualified-map-meta
                                   typ-addr-lookup.table.txn
                               ==
  ::  updating key column requires re-indexing
  =/  aa  %-  silt
              %+  turn
                  key.pri-indx.table.txn
                  |=(a=key-column name.a)
  =/  bb  %-  silt
              %+  turn
                  updates
                  |=(a=[@tas @] -.a)
  =/  xx  ?:  (gth ~(wyt in (~(int in aa) bb)) 0)  :: update key column?
            [filter updates key.pri-indx.table.txn columns.table.txn]
          [filter updates ~ columns.table.txn]
  =/  rows-count=[(list indexed-row) @ud]
        %^  spin
              indexed-rows.file.txn
              0
              |=([a=indexed-row count=@ud] (plan-upd a count xx))
  ::
  ?:  =(+.rows-count 0)
    :+  next-data
        state
        :~  :-  %message
                %-  crip
                    %+  weld  "UPDATE "
                              (trip (qualified-table-to-cord table.u))
            [%server-time now.bowl]
            [%schema-time tmsp.table.txn]
            [%data-time tmsp.file.txn]
            [%message 'no rows updated']
            ==
  ::
  =/  primary-key  (pri-key key.pri-indx.table.txn)
  =/  comparator
        ~(order idx-comp `(list [@ta ?])`(reduce-key key.pri-indx.table.txn))
  =.  pri-idx.file.txn
      %+  gas:primary-key  *((mop (list @) (map @tas @)) comparator)
                           (turn -.rows-count |=(a=indexed-row +.a))
  ::
  =/  idx  ~(wyt by pri-idx.file.txn)
  =/  fil  (lent indexed-rows.file.txn)
  ?.  =(idx fil)
    ~|("{<(sub fil idx)>} duplicate row key(s)" !!)
  ::
  =/  new-indexed-rows  %+  turn  (tap:primary-key pri-idx.file.txn)
                                  |=(a=[(list @) (map @tas @)] [%indexed-row a])
  =.  indexed-rows.file.txn    new-indexed-rows
  =.  tmsp.file.txn            now.bowl
  =/  files                    %+  ~(put by files.nxt-data.txn)
                                   [namespace.table.u name.table.u]
                                   file.txn
  ::
  =.  files.nxt-data.txn       files
  =.  ship.nxt-data.txn        src.bowl
  =.  provenance.nxt-data.txn  sap.bowl
  =.  tmsp.nxt-data.txn        now.bowl
  ::
  =.  content.db.txn     (put:data-key content.db.txn now.bowl nxt-data.txn)
  =.  view-cache.db.txn  (upd-view-caches state db.txn now.bowl ~ %update)
  =.  state          (update-sys state now.bowl)
  ::
  :+  (~(put by next-data) database.table.u now.bowl)
      (~(put by state) name.db.txn db.txn)
      :~  :-  %message
              %-  crip
                  %+  weld  "UPDATE "
                            (trip (qualified-table-to-cord table.u))
          [%server-time now.bowl]
          [%schema-time tmsp.table.txn]
          [%data-time source-content-time.txn]
          [%message 'updated:']
          [%vector-count +.rows-count]
          [%message msg='table data:']
          [%vector-count rowcount.file.txn]
          ==
::
++  do-query
  ::  state may be updated by insertion into view-cache, which does not effect
  ::  any other part of the state
  |=  [q=query:ast =named-ctes is-cte=?]
  ^-  [join-return (list vector)]
  :: literal only
  ?~  from.q  (select-literals state columns.select.q is-cte)
  :: no joins, it's a single relation
  =/  f  (normalize-from (need from.q))
  ?~  joins.f  (select-relation(state state, bowl bowl) q is-cte named-ctes)
  ::
  =/  =join-return      (join-all(state state, bowl bowl) q named-ctes)
  =/  selected          (normalize-selected columns.select.q)
  =/  qualifier-lookup  (mk-qualifier-lookup set-tables.join-return selected)
  =.  selected          (qualify-unqualified selected qualifier-lookup)
  ::
  =/  filter=(unit $-(data-row ?))  ?~  predicate.q  ~
                                    :-  ~
                                        %:  prepare-predicate
                                              %+  normalize-predicate
                                                  predicate.q
                                                  qualifier-lookup
                                              map-meta.join-return
                                              qualifier-lookup
                                              named-ctes
                                              *resolved-scalars
                                              ==
  ?:  is-cte
    ?~  filter  [join-return ~]
    ?~  set-tables.join-return  [join-return ~]
    =.  joined-rows.i.set-tables.join-return
      %+  skim  joined-rows.i.set-tables.join-return
                |=(a=joined-row ((need filter) a))
    [join-return ~]
  ?~  set-tables.join-return  [join-return ~]
  :-  join-return
      %:  joined-result  filter
                          column-metas.join-return
                          map-meta.join-return
                          joined-rows.i.set-tables.join-return
                          selected
                          ==
::
++  joined-result
  |=  $:  filter=(unit $-(data-row ?))
          qualified-columns=(list column-meta)
          =map-meta
          rows=(list data-row)
          selected=(list selected-column:ast)
          ==
  ^-  (list vector)
  ?:  =(~ rows)  ~
  =/  out-rows   *(set vector)
  =/  cells  %:  mk-rel-vect-templ  qualified-columns
                                    selected
                                    -.rows
                                    map-meta
                                    ==
  |-
  ?~  rows  ~(tap in out-rows)
  ?.  ?~(filter %.y ((need filter) i.rows))
    $(rows t.rows)
  =/  row                     *(list vector-cell)
  =/  cols=(list templ-cell)  cells
  |-
  ?~  cols
    %=  ^$
      out-rows  (~(put in out-rows) (vector %vector row))
      rows      t.rows
    ==
  ?~  column.i.cols
    $(cols t.cols, row [vc.i.cols row])
  ::
  %=  $
    cols  t.cols
    row   :-  :-  p.vc.i.cols
                  [p.q.vc.i.cols ;;(@ .*(data.i.rows [%0 addr.i.cols]))]
              row
  ==
::
++  select-results
  |=  $:  =named-ctes
          =join-return
          vectors=(list vector)
          ==
  ^-  (list result)
  =/  out  *(list (list result))
  =/  ctes=(list set-table)
        (zing (turn ~(val by named-ctes) |=(a=full-relation set-tables.a)))
  =/  raw  %+  sort  %~  tap  in
                              %^  fold  (weld set-tables.join-return ctes)
                                        *(set [qualified-table:ast @da @da])
                                        pick-from-object
                     order-results
  ?~  set-tables.join-return  ~|("select-results can't get here" !!)
  |-
  ?~  raw  ?~  out
             :~  [%message 'SELECT']
                 :-  %result-set
                     ?~  indexed-rows.i.set-tables.join-return  ~
                     :~  %+  mk-vect
                             columns.i.set-tables.join-return
                             data.i.indexed-rows.i.set-tables.join-return
                         ==
                 [%server-time now.bowl]
                 [%schema-time created-tmsp:(~(got by server.join-return) %sys)]
                 [%data-time created-tmsp:(~(got by server.join-return) %sys)]
                 [%vector-count (lent indexed-rows.i.set-tables.join-return)]
                 ==
    %-  zing  :~  :~  [%message 'SELECT']
                      [%result-set vectors]
                      [%server-time now.bowl]
                      ==
                  `(list result)`(zing out)
                  :~  [%vector-count (lent vectors)]
                      ==
                  ==
  ?:  (~(has by named-ctes) name.-.i.raw)
    $(raw t.raw)
  %=  $
    raw  t.raw
    out  :-  :~  [%message (qualified-table-to-cord -.i.raw)]
                 [%schema-time +<.i.raw]
                 [%data-time +>.i.raw]
                 ==
             out
  ==
::
++  order-results
  |=  $:  p=[=qualified-table:ast schema-tmsp=@da data-tmsp=@da]
          q=[=qualified-table:ast schema-tmsp=@da data-tmsp=@da]
          ==
  ?:  ?!  %+  aor  (biff ship.qualified-table.p same)
                   (biff ship.qualified-table.q same)                 %.y
  ?:  ?&  .=  (biff ship.qualified-table.p same)
              (biff ship.qualified-table.q same)
              ?!  %+  aor  database.qualified-table.p
                           database.qualified-table.q
          ==                                                           %.y
  ?:  ?&  .=  (biff ship.qualified-table.p same)
              (biff ship.qualified-table.q same)
          =(database.qualified-table.p database.qualified-table.q)
          !(aor namespace.qualified-table.p namespace.qualified-table.q)
          ==                                                           %.y
  ?:  ?&  .=  (biff ship.qualified-table.p same) 
              (biff ship.qualified-table.q same)
          =(database.qualified-table.p database.qualified-table.q)
          =(namespace.qualified-table.p namespace.qualified-table.q)
          !(aor name.qualified-table.p name.qualified-table.q)
          ==                                                           %.y
  ?:  (gth schema-tmsp.p schema-tmsp.q)                                %.y
  ?:  &(=(schema-tmsp.p schema-tmsp.q) (gth data-tmsp.p data-tmsp.q))  %.y
  %.n
::
++  pick-from-object
  |=  [a=set-table state=(set [qualified-table:ast @da @da])]
  ^-  (set [qualified-table:ast @da @da])
  ?~  relation.a    state
  %-  ~(put in state)  :+  (need relation.a)
                           (need schema-tmsp.a)
                           (need data-tmsp.a)
::
++  select-literals
  ::  selection of literals only, no from clause
  |=  [=server columns=(list selected-column:ast) is-cte=?]
  ^-  [join-return (list vector)]
  =/  sys-db  ~|  "At least 1 user database must exist before 'sys' database ".
                  "can be accessed"
                  (~(got by state) %sys)
  =/  indexed-cols  *(map @tas @)
  =/  columns-out   *(list column:ast)
  =/  i             0
  |-
  ?~  columns
    ?:  is-cte  :-  :*  %join-return
                        server
                        :~  :*  %set-table
                                ~
                                ~
                                [~ created-tmsp.sys-db]
                                [~ created-tmsp.sys-db]
                                columns-out
                                ~
                                1
                                *unqualified-map-meta
                                ~
                                *(tree [(list @) (map @tas @)])
                                ~[[%indexed-row ~ indexed-cols]]
                                *(list joined-row)
                                ==
                            ==
                        *qualified-map-meta
                        ~
                        ==
                    ~
    :-  :*  %join-return
            server
            :~  :*  %set-table
                    ~
                    ~
                    [~ created-tmsp.sys-db]
                    [~ created-tmsp.sys-db]
                    columns-out
                    ~
                    1
                    *unqualified-map-meta
                    ~
                    *(tree [(list @) (map @tas @)])
                    ~[[%indexed-row ~ indexed-cols]]
                    *(list joined-row)
                    ==
                ==
            *qualified-map-meta
            ~
            ==
        :~  %+  mk-vect
              columns-out
              indexed-cols
              ==
  ?.  ?=(selected-value:ast -.columns)
    ~|("selected value {<-.columns>} not a literal" !!)
  =/  column-name  ?~  alias.i.columns  (crip "literal-{<i>}")
                                        (need alias.i.columns)
  %=  $
    i             +(i)
    columns       +.columns
    columns-out   :-  [%column column-name p.value.i.columns 0]
                      columns-out
    indexed-cols  (~(put by indexed-cols) column-name q.value.i.columns)
  ==
::
++  mk-vect
  |=  [columns=(list column:ast) values=(map @tas @)]
  ^-  vector
  =/  vector-cells  *(list vector-cell)
  |-
  ?~  columns  ?~  vector-cells  ~|("mk-vect can't get here" !!)
               [%vector `(lest vector-cell)`vector-cells]
  %=  $
    columns       t.columns
    vector-cells  :-  :-  name.i.columns
                          [type.i.columns (~(got by values) name.i.columns)]
                      vector-cells
  ==
::
++  plan-upd
  |=  $:  row=indexed-row
          count=@ud
          f=(unit $-(data-row ?))
          updates=(list [@tas @])
          key-columns=(list key-column)
          cols=(list column:ast)
          ==
  ^-  [indexed-row @ud]
  ?~  f
    ?~  key-columns  :-  :+  %indexed-row
                             key.row
                             (produce-update row updates cols)
                         +(count)
    [(update-key row updates key-columns cols) +(count)]
  ?.  ((need f) [%indexed-row key.row data.row])  [row count]
  ?~  key-columns  :-  [%indexed-row key.row (produce-update row updates cols)]
                       +(count)
  [(update-key row updates key-columns cols) +(count)]
++  update-key
  |=  $:  r=indexed-row
          updates=(list [@tas @])
          key-columns=(list key-column)
          cols=(list column:ast)
          ==
  ^-  indexed-row
  =/  new-key  *(list @)
  =/  upd-row  (produce-update r updates cols)
  |-
  ?~  key-columns  [%indexed-row (flop new-key) upd-row]
  %=  $
    new-key      [(~(got by upd-row) name.i.key-columns) new-key]
    key-columns  t.key-columns
  ==
++  produce-update
  |=  [r=indexed-row updates=(list [@tas @]) cols=(list column:ast)]
  ^-  (map @tas @)
  =/  x  data.r
  |-
  ?~  updates  x
  %=  $
    x        (~(put by x) -.i.updates +.i.updates)
    updates  +.updates
  ==
++  mk-updates
  |=  $:  =qualified-table:ast
          columns=(list qualified-column:ast)
          values=(list *)   ::(list value-or-default:ast)
          map-meta=unqualified-map-meta
          ==
  ^-  (list [@tas @])
  =/  updates  *(list [@tas @])
  |-
  ?~  columns  updates
  ?~  values  ~|("mk-updates can't get here" !!)
  ?:  ?=(%default i.values)
    %=  $
      columns   t.columns
      values    t.values
      updates   ?:  =(~.da -:(~(got by +.map-meta) name.i.columns))
                  [[name.i.columns *@da] updates]
                [[name.i.columns 0] updates]
    ==
  ?:  ?=(dime i.values)
    %=  $
      columns   t.columns
      values    t.values
      updates
        ?.  =(qualified-table qualifier.i.columns)
          ~|  "UPDATE: {<qualified-table>} not matched by column qualifier ".
              "{<qualifier.i.columns>}"
              !!
        ?:  .=  p.i.values  ~|  "UPDATE: {<qualified-table>} does not have ".
                                "column {<name.i.columns>}"
                                -:(~(got by +.map-meta) name.i.columns)
          [[name.i.columns +.i.values] updates]
        ~|("value type: {<-.i.values>} does not match column: {<i.columns>}" !!)
    ==
  ~|("value type not supported: {<i.values>}" !!)
::
++  named-queries
  ::  resolve CTEs
  ::  state is recycled because view cache could have been updated
  |=  [ctes=(list cte:ast) nctes=named-ctes]
  ^-  named-ctes
  |-
  ?~  ctes            nctes
  =/  =join-return    -:(do-query query.i.ctes nctes %.y)
  =.  state             server.join-return
  =/  selected          (normalize-selected columns.select.query.i.ctes)
  =/  set-tables      %^  cte-set-tables  name.i.ctes
                                          selected
                                          set-tables.join-return
  ?~  set-tables      ~|("named-queries can't get here" !!)
  =/  canonical-list  %+  murn  set-tables
                                |=  s=set-table
                                ?~  relation.s  ~
                                (some [(need relation.s) columns.s])
  =/  canonical-map   (malt canonical-list)
  =/  map-meta        ;;(qualified-map-meta map-meta.join-return)
  =/  data-row        ?~  joined-rows.i.set-tables
                        ?~  indexed-rows.i.set-tables
                          *indexed-row
                        i.indexed-rows.i.set-tables
                      i.joined-rows.i.set-tables

  =/  column-metas  %:  mk-cte-column-metas
                          selected
                          data-row
                          ;;(qualified-map-meta map-meta.join-return)
                          canonical-list
                          canonical-map
                          ==

  =/  cte-map-meta
    %+  roll  column-metas
              |=  $:  =column-meta
                      map-meta=qualified-map-meta
                      ==
              ^-  qualified-map-meta
              :-  %qualified-map-meta
                  %^  ~(put bi:mip +.map-meta)
                        [%cte-name name.i.ctes]
                        name.qualified-column.column-meta
                        [type.column-meta addr.column-meta]
  ::
  %=  $
    nctes  %+  ~(put by nctes)  name.i.ctes
                                :*  %full-relation
                                    [%cte-name name.i.ctes]
                                    set-tables
                                    cte-map-meta
                                    column-metas
                                    ==
    ctes   +.ctes
  ==
::
++  cte-set-tables
  |=  [name=@tas columns=(list selected-column:ast) st=(list set-table)]
  ^-  (list set-table)
  ?~  st  ~|("cte-set-tables can't get here" !!)
  ?:  =(~ relation.i.st)  st
  =/  new  i.st
  =.  join.new        ~
  =.  relation.new    ~
  ::
  =/  f  %+  bake  %+  cury
                       %+  cury  (cury cte-columns (mk-col-lookup st))
                                 (mk-rel-col-lookup st)
                       (flop st)
                   selected-column:ast
  =.  columns.new  (addr-columns (cte-col-dups name (zing (turn columns f))))
  [new st]
::
++  cte-columns
  |=  $:  col-lookup=(mip:mip qualified-table:ast @tas @ta)
          rel-col-lookup=(map qualified-table:ast (list column:ast))
          st=(list set-table)
          a=selected-column:ast
          ==
  ^-  (list column:ast)
  ~|  "failed lookup for column:  {<a>}"
  ?-  a
    qualified-column
    ?~  alias.a
      ~[[%column name.a (~(got bi:mip col-lookup) qualifier.a name.a) 0]]
    ~[[%column (need alias.a) (~(got bi:mip col-lookup) qualifier.a name.a) 0]]
    unqualified-column
      ~|("can't be unqualified in join" !!)
    selected-aggregate
      ~|("selected-aggregate not implemented" !!)
    selected-value
      ~[[%column (need alias.a) p.value.a 0]]
    selected-all
    %-  flop
        %+  roll  st
                  |=  [a=set-table b=(list column:ast)]
                  ?~(relation.a b (weld (flop columns.a) b))
    selected-all-table
      (~(got by rel-col-lookup) qualified-table.a)
    cte-column
      ~|("TO DO: implement cte-column" !!)
    ==
::
++  mk-cte-column-metas
  |=  $:  sel-cols=(list selected-column:ast)
          =data-row
          map-meta=qualified-map-meta
          canonical-list=(list [qualified-table *])
          canonical-map=(map qualified-table (list column:ast))
          ==
  ^-  (list column-meta)
  =/  f  |=  q=qualified-table:ast
         ^-  (list column-meta)
         ~|  "can't lookup {<q>}"
         %:  cte-meta  (~(got by canonical-map) q)
             data-row
             q
             map-meta
             ==
  ::
  %-  zing
    %+  turn  sel-cols
              |=  c=selected-column:ast
              ?-  c
                qualified-column:ast
                  =/  typ-addr  (~(got bi:mip +.map-meta) qualifier.c name.c)
                  :~  :+  :^  %qualified-column
                              qualifier.c
                              ?~(alias.c name.c (need alias.c))
                              ?~(alias.c ~ [~ name.c])
                          type.typ-addr
                          ?:  =(%indexed-row -.data-row)  addr.typ-addr
                          %^  calc-joined-addr  data:;;(joined-row data-row)
                                                qualifier.c
                                                name.c
                      ==
                unqualified-column:ast
                  =/  qt        -<.canonical-list
                  =/  typ-addr  (~(got bi:mip +.map-meta) qt name.c)
                  :~  :+  :^  %qualified-column
                              qt
                              ?~(alias.c name.c (need alias.c))
                              ?~(alias.c ~ [~ name.c])
                          type.typ-addr
                          ?:  =(%indexed-row -.data-row)  addr.typ-addr
                          %^  calc-joined-addr  data:;;(joined-row data-row)
                                                qt
                                                name.c
                      ==
                cte-column:ast
                  ~|("TO DO: implement cte-column" !!)
                selected-aggregate:ast
                  ~|("mk-cte-column-metas {<c>} not supported" !!)
                selected-value:ast
                  ~|("mk-cte-column-metas {<c>} not supported" !!)
                selected-all:ast
                  %+  roll  canonical-list
                            |=  $:  qt=[q=qualified-table:ast z=*]
                                    column-metas=(list column-meta)
                                    ==
                            ^-  (list column-meta)
                            (weld column-metas (f q.qt))
                selected-all-table:ast
                  (f +.c)
                ==
::
++  cte-meta
  |=  $:  columns=(list column:ast)
          =data-row
          =qualified-table:ast
          =qualified-map-meta
          ==
  ^-  (list column-meta)
  =/  metas  *(list column-meta)
  |-
  ?~  columns  (flop metas)
  ~|  "can't lookup column {<qualified-table>} {<name.i.columns>}"
  =/  typ-addr  %+  ~(got bi:mip +.qualified-map-meta)  %-  normalize-qt-alias
                                                                qualified-table
                                                            name.i.columns
  %=  $
    columns  t.columns
    metas  :-  :+  :^  %qualified-column
                        qualified-table
                        name.i.columns
                        ~
                    type.typ-addr
                    ?:  =(%indexed-row -.data-row)  addr.typ-addr
                    %^  calc-joined-addr  data:;;(joined-row data-row)
                                          qualified-table
                                          name.i.columns
                metas
  ==
::
++  mk-col-lookup
  |=  st=(list set-table)
  ^-  (mip:mip qualified-table:ast @tas @ta)
  =/  lookup  *(mip:mip qualified-table:ast @tas @ta)
  |-
  ?~  st  lookup
  ?~  relation.i.st  $(st t.st)
  |-
  ?~  columns.i.st  ^$(st t.st)
  =.  lookup  %^  ~(put bi:mip lookup)  (need relation.i.st)
                                        name.i.columns.i.st
                                        type.i.columns.i.st
  $(columns.i.st t.columns.i.st)
::
++  mk-rel-col-lookup
  |=  st=(list set-table)
  ^-  (map qualified-table:ast (list column:ast))
  =/  lookup  *(map qualified-table:ast (list column:ast))
  |-
  ?~  st  lookup
  ?~  relation.i.st  $(st t.st)
  %=  $
    st      t.st
    lookup  (~(put by lookup) (need relation.i.st) columns.i.st)
  ==
::
++  cte-col-dups
  |=  [name=@tas cols=(list column:ast)]
  ^-  (list column:ast)
  =/  dup  *(map @tas ~)
  =/  cs   cols
  |-
  ?~  cs  cols
  ?:  (~(has by dup) name.i.cs)
    ~|  "{<name.i.cs>} is duplicate column name in ".
        "common table expression {<name>}"
        !!
  %=  $
    cs  t.cs
    dup  (~(put by dup) name.i.cs ~)
  ==
::
++  qualified-table-to-cord
  |=  =qualified-table:ast
  ^-  @t
  =/  b  %-  zing  :~  (trip database.qualified-table)
                       "."
                       (trip namespace.qualified-table)
                       "."
                       (trip name.qualified-table)
                       ==
  ?~  ship.qualified-table  (crip b)
  %-  crip  %-  zing  :~  (trip (need ship.qualified-table))
                          "."
                          (trip name.qualified-table)
                          ==
::
++  upd-indices-views
  ::  post- insert, update, delete, truncate procedure to create new view
  ::  and index instances for effected tables
  ::  =views passes effected sys views
  :: to do: revisit when there are views & indices
  |=  $:  state=server
          sys-time=@da
          objs=(list qualified-table:ast)
          sys-vws=(list [@tas @tas])
          ==
  ^-  server
  :: to do: iterate through objects
  state
::
++  mk-qualifier-lookup
  ::  Make lookup qualifier by column name for predicate processing when a
  ::  column is unqualified.
  |=  [sources=(list set-table) selected-columns=(list selected-column:ast)]
    ^-  qualifier-lookup
    =/  lookup  *qualifier-lookup
    |-
    ?~  sources           lookup
    =/  source=set-table  i.sources
    ?~  relation.source     $(sources t.sources)
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
++  update-file
  |=  [=file =data tbl-key=[@tas @tas] primary-key=(list key-column) inserted=@ud]
  =/  new-indexed-rows  %+  turn  (tap:(pri-key primary-key) pri-idx.file)
                                  |=(a=[(list @) (map @tas @)] [%indexed-row a])
  =.  indexed-rows.file    new-indexed-rows
  =.  rowcount.file        (add rowcount.file inserted)
  =.  files.data  (~(put by files.data) tbl-key file)
  data
::
++  row-cells
  ::  Create the saved row-wise file data.
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
++  row-cells-and-keys
  ::  Build row map and key-value subset map in a single pass.
  |=  [p=(list value-or-default:ast) q=(list column:ast) key-names=(set @tas)]
  ^-  [(map @tas @) (map @tas @)]
  =/  all-cells  *(list [@tas @])
  =/  key-cells  *(list [@tas @])
  |-
  ?~  p  [(malt all-cells) (malt key-cells)]
  =/  cell=[@tas @]  (row-cell -.p -.q)
  %=  $
    all-cells  [cell all-cells]
    key-cells  ?:  (~(has in key-names) -.cell)
                 [cell key-cells]
               key-cells
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
--
 