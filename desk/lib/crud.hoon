/-  ast, *obelisk, *server-state-0
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
  ^-  [cmd-result:ast (map @tas @da) (map @tas @da) server]
  =/  db  ~|  "TRUNCATE TABLE: database ".
              "{<database.qualified-table.d>} does not exist"
             (~(got by state) database.qualified-table.d)
  =/  sys-time  (set-tmsp as-of.d now.bowl)
  =/  nxt-schema=schema
        ~|  "TRUNCATE TABLE: {<name.qualified-table.d>} ".
            "as-of schema time out of order"
          %:  get-next-schema  sys.db
                              next-schemas
                              sys-time
                              database.qualified-table.d
                              ==
  =/  nxt-data=data
        ~|  "TRUNCATE TABLE: {<name.qualified-table.d>} ".
            "as-of data time out of order"
            %:  get-next-data  content.db
                               next-data
                               sys-time
                               database.qualified-table.d
                               ==
  ::
  ?.  (~(has by namespaces.nxt-schema) namespace.qualified-table.d)
    ~|  "TRUNCATE TABLE: namespace ".
        "{<namespace.qualified-table.d>} does not exist"
        !!
  ::
  =/  tables
    ~|  "TRUNCATE TABLE: {<name.qualified-table.d>} ".
        "does not exists in {<namespace.qualified-table.d>}"
    %-  ~(got by tables:nxt-schema)
        [namespace.qualified-table.d name.qualified-table.d]
  ::
  =/  file
    ~|  "TRUNCATE TABLE: {<namespace.qualified-table.d>}".
        ".{<name.qualified-table.d>} does not exist"
    %-  ~(got by files.nxt-data)
    [namespace.qualified-table.d name.qualified-table.d]
  ?.  (gth rowcount.file 0)  :: don't bother if table is empty
    :^  :-  %results
            :~  :-  %action
                    %-  crip
                        %+  weld  "TRUNCATE TABLE "
                            (trip (qualified-table-to-cord qualified-table.d))
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
  =/  files  %+  ~(put by files.nxt-data)
                 [namespace.qualified-table.d name.qualified-table.d]
             file
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
          :~  :-  %action
                  %-  crip
                      %+  weld  "TRUNCATE TABLE "
                          (trip (qualified-table-to-cord qualified-table.d))
              [%server-time now.bowl]
              [%data-time sys-time]
              [%vector-count dropped-rows]
              ==
      next-schemas
      (~(put by next-data) database.qualified-table.d sys-time)
      (~(put by state) name.db db)
::
++  do-crud-txn
  |=  $:  =crud-txn:ast
          query-has-run=?
          next-data=(map @tas @da)
          next-schemas=(map @tas @da)
      ==
  ^-  [? [(map @tas @da) server (list result:ast)]]
  =/  named-ctes   (named-queries ctes.crud-txn *named-ctes)
  ?-  -.body.crud-txn
    %insert
      ?:  query-has-run  ~|("INSERT: state change after query in script" !!)
      :-  %.n
          (do-insert +.body.crud-txn next-data next-schemas)
    %query
      =/  q=query:ast  +.body.crud-txn
      :-  %.y
          =/  rt  (do-query q named-ctes %.n)
          =/  results  (select-results named-ctes -.rt +.rt)
          :+  next-data  ->-.rt
          ?.  (crud-txn-has-rand scalars.q ctes.crud-txn)
            results
          [[%message 'warning: results are non-deterministic'] results]
    %set-query
      ~|("SET-QUERY (UNION/EXCEPT/etc.) execution not yet implemented" !!)
    %merge
      ?:  query-has-run  ~|("MERGE: state change after query in script" !!)
      ~|("merge not implemented" !!)
    %delete
      ~|("DELETE via crud-body not implemented" !!)
    %update
      ~|("UPDATE via crud-body not implemented" !!)
  ==
::
++  do-insert
  |=  [ins=insert:ast next-data=(map @tas @da) next-schemas=(map @tas @da)]
  ^-  [(map @tas @da) server (list result:ast)]
  =/  txn  %:  common-txn  "INSERT"
                           state
                           now.bowl
                           qualified-table.ins
                           as-of.ins
                           next-schemas
                           ==
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
  ::
  =.  state          (update-sys state now.bowl)
  ::
  |-
  ?~  value-table
    :+  (~(put by next-data) database.qualified-table.ins now.bowl)
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
      :~  :-  %action
              %-  crip
                  %+  weld  "INSERT INTO "
                            (trip (qualified-table-to-cord qualified-table.ins))
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
  =/  file-row=(map @tas @)  (row-cells-and-keys row cols)
  =/  got-fr  ~(got by file-row)
  =/  row-key=(list @)  (turn key-pick |=(a=[@tas @] (got-fr -.a)))
  =.  pri-idx.file.txn  ?:  (has:primary-key pri-idx.file.txn row-key)
                          ~|("INSERT: cannot add duplicate key: {<row-key>}" !!)
                        (put:primary-key pri-idx.file.txn row-key file-row)
  $(i +(i), value-table `(list (list value-or-default:ast))`+.value-table)
::
++  do-delete
  |=  [d=delete:ast next-schemas=(map @tas @da) next-data=(map @tas @da)]
  ^-  [(map @tas @da) server (list result:ast)]
  =/  txn  %:  common-txn  "DELETE FROM"
                           state
                           now.bowl
                           qualified-table.d
                           as-of.d
                           next-schemas
                           ==
  ?.  (gth rowcount.file.txn 0)  :: don't bother if table is empty
    :+  next-data
        state
        :~  :-  %action
                %-  crip
                    "DELETE FROM ".
                    "{<namespace.qualified-table.d>}".
                    ".{<name.qualified-table.d>}"
            [%server-time now.bowl]
            [%schema-time tmsp.table.txn]
            [%data-time tmsp.file.txn]
            [%message 'no rows deleted']
            ==
  ::
  =/  named-ctes  (named-queries ctes.d *named-ctes)
  =/  del-qualifier-lookup=qualifier-lookup
    %+  roll  columns.table.txn
              |=  [c=column:ast ql=qualifier-lookup]
              (~(put by ql) name.c (limo ~[qualified-table.d]))
  =/  resolved-scalars
    %:  resolve-query-scalars(state state, bowl bowl)  scalars.d
                                                       named-ctes
                                                       del-qualifier-lookup
                                                       [%unqualified-map-meta typ-addr-lookup.table.txn]
                                                       ==
  =/  filter=(unit $-(data-row ?))
    ?~  predicate.d  ~
    :-  ~
        %:  prepare-predicate
              (pred-unqualify-qualified predicate.d)
              :-  %unqualified-map-meta
                  typ-addr-lookup.table.txn
              ~
              named-ctes
              resolved-scalars
              ==
  =.  indexed-rows.file.txn  ?~  filter  ~
                             %+  skim  indexed-rows.file.txn
                                       |=(a=indexed-row !((need filter) a))
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
        :~  :-  %action
                %-  crip
                    %+  weld  "DELETE FROM "
                              (trip (qualified-table-to-cord qualified-table.d))
            [%server-time now.bowl]
            [%schema-time tmsp.table.txn]
            [%data-time tmsp.file.txn]
            [%message 'no rows deleted']
            ==
  =.  rowcount.file.txn        rowcount
  =.  tmsp.file.txn            now.bowl
  =/  files  %+  ~(put by files.nxt-data.txn)
                 :-  namespace.qualified-table.d
                     name.qualified-table.d
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
  :+  (~(put by next-data) database.qualified-table.d now.bowl)
      (~(put by state) name.db.txn db.txn)
      :~  :-  %action
              %-  crip
                  %+  weld  "DELETE FROM "
                            (trip (qualified-table-to-cord qualified-table.d))
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
  ^-  [(map @tas @da) server (list result:ast)]
  =/  txn  %:  common-txn  "UPDATE"
                           state
                           now.bowl
                           qualified-table.u
                           as-of.u
                           next-schemas
                           ==
  ?.  (gth rowcount.file.txn 0)  :: don't bother if table is empty
    :+  next-data
        state
        :~  :-  %action
                %-  crip
                    "UPDATE ".
                    "{<namespace.qualified-table.u>}".
                    ".{<name.qualified-table.u>}"
            [%server-time now.bowl]
            [%schema-time tmsp.table.txn]
            [%data-time tmsp.file.txn]
            [%message 'no rows updated']
            ==
  ::
  ?.  =((lent columns.u) (lent values.u))
    ~|("UPDATE: columns and values mismatch" !!)
  =/  named-ctes  (named-queries ctes.u *named-ctes)
  =/  upd-qualifier-lookup=qualifier-lookup
    %+  roll  columns.table.txn
              |=  [c=column:ast ql=qualifier-lookup]
              (~(put by ql) name.c (limo ~[qualified-table.u]))
  =/  resolved-scalars
    %:  resolve-query-scalars(state state, bowl bowl)  scalars.u
                                                       named-ctes
                                                       upd-qualifier-lookup
                                                       [%unqualified-map-meta typ-addr-lookup.table.txn]
                                                       ==
  =/  filter  ?~  predicate.u  ~
              :-  ~
                  %:  prepare-predicate  %-  pred-unqualify-qualified
                                              predicate.u
                                          :-  %unqualified-map-meta
                                              typ-addr-lookup.table.txn
                                          ~
                                          named-ctes
                                          resolved-scalars
                                          ==
  =/  upd-result  %:  mk-updates  qualified-table.u
                                  columns.u
                                  values.u
                                  :-  %unqualified-map-meta
                                      typ-addr-lookup.table.txn
                                  ==
  =/  static-updates  -.upd-result
  =/  scalar-updates  +.upd-result
  ::  updating key column requires re-indexing
  =/  aa  %-  silt
              %+  turn
                  key.pri-indx.table.txn
                  |=(a=key-column name.a)
  =/  bb  %-  silt
              %+  weld
                  (turn static-updates |=(a=[@tas @] -.a))
                  (turn scalar-updates |=(a=[@tas @tas] -.a))
  =/  xx  ?:  (gth ~(wyt in (~(int in aa) bb)) 0)  :: update key column?
            [filter static-updates scalar-updates resolved-scalars key.pri-indx.table.txn columns.table.txn]
          [filter static-updates scalar-updates resolved-scalars ~ columns.table.txn]
  =/  rows-count=[(list indexed-row) @ud]
        %^  spin
              indexed-rows.file.txn
              0
              |=([a=indexed-row count=@ud] (plan-upd a count xx))
  ::
  ?:  =(+.rows-count 0)
    :+  next-data
        state
        :~  :-  %action
                %-  crip
                    %+  weld  "UPDATE "
                              (trip (qualified-table-to-cord qualified-table.u))
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
  =/  files  %+  ~(put by files.nxt-data.txn)
                 :-  namespace.qualified-table.u
                     name.qualified-table.u
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
  :+  (~(put by next-data) database.qualified-table.u now.bowl)
      (~(put by state) name.db.txn db.txn)
      :~  :-  %action
              %-  crip
                  %+  weld  "UPDATE "
                            (trip (qualified-table-to-cord qualified-table.u))
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
  :: literal/scalar only
  ?~  from.q
    =/  resolved-scalars
      %:  resolve-query-scalars(state state, bowl bowl)  scalars.q
                                                         named-ctes
                                                         *qualifier-lookup
                                                         *qualified-map-meta
                                                         ==
    (select-literals state columns.select.q is-cte resolved-scalars)
  :: no joins, it's a single relation
  =/  f  (normalize-from (need from.q))
  ?~  joins.f  (select-relation(state state, bowl bowl) q is-cte named-ctes)
  ::
  =/  =join-return      (join-all(state state, bowl bowl) q named-ctes)
  ?:  is-cte
    ?~  predicate.q  [join-return ~]
    =/  qualifier-lookup  (mk-qualifier-lookup set-tables.join-return columns.select.q)
    =/  resolved-scalars
          %:  resolve-query-scalars(state state, bowl bowl)  scalars.q
                                                             named-ctes
                                                             qualifier-lookup
                                                             map-meta.join-return
                                                             ==
    =/  filter
      %:  prepare-predicate
            %+  normalize-predicate
                predicate.q
                qualifier-lookup
            map-meta.join-return
            qualifier-lookup
            named-ctes
            resolved-scalars
            ==
    ?~  set-tables.join-return  [join-return ~]
    =.  joined-rows.i.set-tables.join-return
      %+  skim  joined-rows.i.set-tables.join-return
                |=(a=joined-row (filter a))
    [join-return ~]
  ::
  =/  selected          (normalize-selected columns.select.q)
  =/  qualifier-lookup  (mk-qualifier-lookup set-tables.join-return selected)
  =/  resolved-scalars
        %:  resolve-query-scalars(state state, bowl bowl)  scalars.q
                                                           named-ctes
                                                           qualifier-lookup
                                                           map-meta.join-return
                                                           ==
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
                                              resolved-scalars
                                              ==
  ?~  set-tables.join-return  [join-return ~]
  :-  join-return
      %-  joined-result
      :*  filter
          column-metas.join-return
          map-meta.join-return
          joined-rows.i.set-tables.join-return
          selected
          resolved-scalars
          named-ctes
          ==
::
++  joined-result
  |=  $:  filter=(unit $-(data-row ?))
          qualified-columns=(list column-meta)
          =map-meta
          rows=(list data-row)
          selected=(list selected-column:ast)
          =resolved-scalars
          =named-ctes
          ==
  ^-  (list vector)
  ?:  =(~ rows)  ~
  =/  out-rows   *(set vector)
  =/  cells
    %-  mk-rel-vect-templ
    [qualified-columns selected -.rows map-meta resolved-scalars named-ctes]
  |-
  ?~  rows  ~(tap in out-rows)
  ?.  ?~(filter %.y ((need filter) i.rows))
    $(rows t.rows)
  =/  row                     *(list vector-cell:ast)
  =/  cols=(list templ-cell)  cells
  |-
  ?~  cols
    %=  ^$
      out-rows  (~(put in out-rows) (vector %vector row))
      rows      t.rows
    ==
  ?^  scalar.i.cols
    =/  x=dime  (resolve-selected-scalar i.rows (need scalar.i.cols))
    $(cols t.cols, row [[p.vc.i.cols [p.x q.x]] row])
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
          vectors=(list vector:ast)
          ==
  ^-  (list result:ast)
  =/  out  *(list (list result:ast))
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
             :~  [%action 'SELECT']
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
    %-  zing  :~  :~  [%action 'SELECT']
                      [%result-set vectors]
                      [%server-time now.bowl]
                      ==
                  `(list result:ast)`(zing out)
                  :~  [%vector-count (lent vectors)]
                      ==
                  ==
  ?:  (~(has by named-ctes) name.-.i.raw)
    $(raw t.raw)
  %=  $
    raw  t.raw
    out  :-  :~  [%relation (qualified-table-to-cord -.i.raw)]
                 [%schema-time +<.i.raw]
                 [%data-time +>.i.raw]
                 ==
             out
  ==
::
++  order-results
  ::  sort comparator for select-results table metadata output.
  ::  returns %.y if p should appear before q in the results list.
  ::  priority order (highest to lowest), all within the same enclosing scope:
  ::    1. ship: reverse-aor order on biff'd ship atom
  ::    2. database: reverse-aor within same ship
  ::    3. namespace: reverse-aor within same ship+database
  ::    4. table name: reverse-aor within same ship+database+namespace
  ::    5. schema-time: more recent first 
  ::                    within same ship+database+namespace+name
  ::    6. data-time: more recent first 
  ::                  within same ship+database+namespace+name+schema-time
  |=  $:  p=[=qualified-table:ast schema-tmsp=@da data-tmsp=@da]
          q=[=qualified-table:ast schema-tmsp=@da data-tmsp=@da]
          ==
  =/  ship-p  (biff ship.qualified-table.p same)
  =/  ship-q  (biff ship.qualified-table.q same)
  ?.  =(ship-p ship-q)
    ?!  (aor ship-p ship-q)
  ?.  =(database.qualified-table.p database.qualified-table.q)
    ?!  (aor database.qualified-table.p database.qualified-table.q)
  ?.  =(namespace.qualified-table.p namespace.qualified-table.q)
    ?!  (aor namespace.qualified-table.p namespace.qualified-table.q)
  ?.  =(name.qualified-table.p name.qualified-table.q)
    ?!  (aor name.qualified-table.p name.qualified-table.q)
  ?.  =(schema-tmsp.p schema-tmsp.q)
    (gth schema-tmsp.p schema-tmsp.q)
  (gth data-tmsp.p data-tmsp.q)
::
++  pick-from-object
  |=  [a=set-table sources-state=(set [qualified-table:ast @da @da])]
  ^-  (set [qualified-table:ast @da @da])
  ?~  relation.a    sources-state
  =/  qt  (need relation.a)
  %-  ~(put in sources-state)  :+  qt(alias ~)
                           (need schema-tmsp.a)
                           (need data-tmsp.a)
::
++  select-literals
  ::  crud-txn of literals/scalars only, no from clause
  |=  [=server columns=(list selected-column:ast) is-cte=? =resolved-scalars]
  ^-  [join-return (list vector)]
  =/  sys-db  ~|  "At least 1 user database must exist before 'sys' database ".
                  "can be accessed"
                  (~(got by state) %sys)
  =/  indexed-cols  *(map @tas @)
  =/  columns-out   *(list column:ast)
  =/  i             0
  =/  empty-row     [%indexed-row ~ *(map @tas @)]
  |-
  ?~  columns
    =/  addressed-cols  (addr-columns columns-out)
    =/  map-meta        [%unqualified-map-meta (mk-unqualified-typ-addr-lookup addressed-cols)]
    ?:  is-cte  :-  :*  %join-return
                        server
                        :~  :*  %set-table
                                ~
                                ~
                                [~ created-tmsp.sys-db]
                                [~ created-tmsp.sys-db]
                                addressed-cols
                                ~
                                1
                                map-meta
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
                    addressed-cols
                    ~
                    1
                    map-meta
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
              addressed-cols
              indexed-cols
              ==
  ?:  ?=(selected-value:ast -.columns)
    =/  column-name  ?~  alias.i.columns  (crip "literal-{<i>}")
                                          (need alias.i.columns)
    %=  $
      i             +(i)
      columns       +.columns
      columns-out   :-  [%column column-name p.value.i.columns 0]
                        columns-out
      indexed-cols  (~(put by indexed-cols) column-name q.value.i.columns)
    ==
  ?:  ?=(selected-scalar:ast -.columns)
    =/  rs=resolved-scalar
      ~|  "SELECT: scalar {<name.i.columns>} not found"
      (~(got by resolved-scalars) name.i.columns)
    =/  x=dime  (resolve-selected-scalar empty-row rs)
    =/  column-name  (heading i.columns name.i.columns)
    %=  $
      i             +(i)
      columns       +.columns
      columns-out   :-  [%column column-name (resolved-scalar-type rs) 0]
                        columns-out
      indexed-cols  (~(put by indexed-cols) column-name q.x)
    ==
  ~|("selected value/scalar {<-.columns>} not supported without FROM" !!)
::
++  mk-vect
  |=  [columns=(list column:ast) values=(map @tas @)]
  ^-  vector
  =/  vector-cells  *(list vector-cell:ast)
  |-
  ?~  columns  ?~  vector-cells  ~|("mk-vect can't get here" !!)
               [%vector `(lest vector-cell:ast)`vector-cells]
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
          scalar-updates=(list [@tas @tas])
          rs=resolved-scalars
          key-columns=(list key-column)
          cols=(list column:ast)
          ==
  ^-  [indexed-row @ud]
  =/  row-scalars=(list [@tas @])
    %+  turn  scalar-updates
              |=  [col=@tas sname=@tas]
              :-  col
              +:(apply-resolved-scalar (~(got by rs) sname) [%indexed-row key.row data.row])
  =/  all-updates=(list [@tas @])  (weld updates row-scalars)
  ?~  f
    ?~  key-columns  :-  :+  %indexed-row
                             key.row
                             (produce-update row all-updates cols)
                         +(count)
    [(update-key row all-updates key-columns cols) +(count)]
  ?.  ((need f) [%indexed-row key.row data.row])  [row count]
  ?~  key-columns  :-  [%indexed-row key.row (produce-update row all-updates cols)]
                       +(count)
  [(update-key row all-updates key-columns cols) +(count)]
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
  ^-  [(list [@tas @]) (list [@tas @tas])]
  =/  updates         *(list [@tas @])
  =/  scalar-updates  *(list [@tas @tas])
  |-
  ?~  columns  [updates scalar-updates]
  ?~  values  ~|("mk-updates can't get here" !!)
  ?:  ?=(%default i.values)
    %=  $
      columns   t.columns
      values    t.values
      updates   ?:  =(~.da -:(~(got by +.map-meta) name.i.columns))
                  [[name.i.columns *@da] updates]
                [[name.i.columns 0] updates]
    ==
  ?:  ?=([%scalar-name *] i.values)
    %=  $
      columns        t.columns
      values         t.values
      scalar-updates  [[name.i.columns ;;(@tas +.i.values)] scalar-updates]
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
  ?>  ?=([%query *] body.i.ctes)
  =/  cte-q=query:ast   +.body.i.ctes
  =/  =join-return    -:(do-query cte-q nctes %.y)
  =.  state             server.join-return
  =/  selected          (normalize-selected columns.select.cte-q)
  =/  qualifier-lookup  (mk-qualifier-lookup set-tables.join-return selected)
  =/  resolved-scalars
        %:  resolve-query-scalars(state state, bowl bowl)  scalars.cte-q
                                                           nctes
                                                           qualifier-lookup
                                                           map-meta.join-return
                                                           ==
  =/  cte-shaped
    %-  cte-set-tables
    [name.i.ctes selected set-tables.join-return nctes resolved-scalars]
  =/  needs-mat       (selected-needs-materialization selected)
  =/  has-joined      ?~  set-tables.join-return  %.n
                      !=(~ joined-rows.i.set-tables.join-return)
  =/  set-tables      ?:  ?|(needs-mat has-joined)
                        %-  materialize-cte-set-tables
                        [name.i.ctes selected nctes join-return cte-shaped resolved-scalars]
                      cte-shaped
  ?~  set-tables      ~|("named-queries can't get here" !!)
  =/  canonical-list  %+  murn  set-tables
                                |=  s=set-table
                                ?~  relation.s  ~
                                (some [(need relation.s) columns.s])
  =/  canonical-map   (malt canonical-list)
  =/  map-meta        ;;(qualified-map-meta map-meta.join-return)
  =/  column-metas
    ?:  ?|(needs-mat has-joined)
      (materialized-cte-column-metas name.i.ctes columns.i.set-tables)
    =/  data-row  ?~  joined-rows.i.set-tables
                    ?~  indexed-rows.i.set-tables
                      *indexed-row
                    i.indexed-rows.i.set-tables
                  i.joined-rows.i.set-tables
    %-  mk-cte-column-metas
    :*  selected
        name.i.ctes
        data-row
        map-meta
        canonical-list
        canonical-map
        columns.i.set-tables
        nctes
        ==

  =/  cte-map-meta
    %+  roll  column-metas
              |=  $:  =column-meta
                      map-meta=qualified-map-meta
                      ==
              ^-  qualified-map-meta
              :-  %qualified-map-meta
                  %^  ~(put bi:mip +.map-meta)
                        [%cte-name name.i.ctes ~]
                        name.qualified-column.column-meta
                        [type.column-meta addr.column-meta]
  ::
  %=  $
    nctes  %+  ~(put by nctes)  name.i.ctes
                                :*  %full-relation
                                    [%cte-name name.i.ctes ~]
                                    set-tables
                                    cte-map-meta
                                    column-metas
                                    ==
    ctes   +.ctes
  ==
::
++  cte-set-tables
  |=  [name=@tas columns=(list selected-column:ast) st=(list set-table) =named-ctes =resolved-scalars]
  ^-  (list set-table)
  ?~  st  ~|("cte-set-tables can't get here" !!)
  ?:  =(~ relation.i.st)  st
  =/  new  i.st
  =.  join.new        ~
  =.  relation.new    ~
  ::
  =/  col-lookup      (mk-col-lookup st)
  =/  rel-col-lookup  (mk-rel-col-lookup st)
  =/  flipped-st      (flop st)
  =/  f  |=  a=selected-column:ast
          %-  cte-columns
          [col-lookup rel-col-lookup named-ctes resolved-scalars flipped-st a]
  =.  columns.new  (addr-columns (cte-col-dups name (zing (turn columns f))))
  =.  map-meta.new  [%unqualified-map-meta (mk-unqualified-typ-addr-lookup columns.new)]
  [new st]
::
++  cte-columns
  |=  $:  col-lookup=(mip:mip qualified-table:ast @tas @ta)
          rel-col-lookup=(map qualified-table:ast (list column:ast))
          =named-ctes
          =resolved-scalars
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
    selected-scalar
      =/  rs=resolved-scalar
        ~|  "selected scalar {<name.a>} not in resolved-scalars"
        (~(got by resolved-scalars) name.a)
      ~[[%column (heading a name.a) (resolved-scalar-type rs) 0]]
    selected-value
      ~[[%column (need alias.a) p.value.a 0]]
    selected-all
    %-  flop
        %+  roll  st
                  |=  [a=set-table b=(list column:ast)]
                  ?~(relation.a b (weld (flop columns.a) b))
    selected-all-table
      (~(got by rel-col-lookup) qualified-table.a)
    selected-cte-column
      =/  cte-fr  (~(got by named-ctes) cte.a)
      =/  ta=typ-addr  %+  ~(got bi:mip +.map-meta.cte-fr)  [%cte-name cte.a ~]
                                                              name.a
      ~[[%column (heading a name.a) type.ta 0]]
    ==
::
++  mk-cte-column-metas
  |=  $:  sel-cols=(list selected-column:ast)
          cte=@tas
          =data-row
          map-meta=qualified-map-meta
          canonical-list=(list [qualified-table:ast *])
          canonical-map=(map qualified-table:ast (list column:ast))
          cte-cols=(list column:ast)
          =named-ctes
          ==
  ^-  (list column-meta)
  =/  default-qt  :*  %qualified-table
                      ship=~
                      database=%cte
                      namespace=%cte
                      name=cte
                      alias=~
                  ==
  =/  unq-lookup  (mk-unqualified-typ-addr-lookup cte-cols)
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
                selected-scalar:ast
                  =/  out-name  (heading c name.c)
                  =/  typ-addr  (~(got by unq-lookup) out-name)
                  =/  qt  ?~(canonical-list default-qt -.i.canonical-list)
                  :~  :+  :^  %qualified-column
                              qt
                              out-name
                              ?~(alias.c ~ [~ name.c])
                          type.typ-addr
                          addr.typ-addr
                      ==
                selected-cte-column:ast
                  =/  out-name  (heading c name.c)
                  =/  cte-fr  (~(got by named-ctes) cte.c)
                  =/  cte-ta=typ-addr
                    %+  ~(got bi:mip +.map-meta.cte-fr)  [%cte-name cte.c ~]
                                                        name.c
                  =/  qt  ?~(canonical-list default-qt -.i.canonical-list)
                  =/  out-ta  (~(got by unq-lookup) out-name)
                  :~  :+  :^  %qualified-column
                              qt
                              out-name
                              ?~(alias.c ~ [~ name.c])
                          type.cte-ta
                          addr.out-ta
                      ==
                selected-aggregate:ast
                  ~|("mk-cte-column-metas {<c>} not supported" !!)
                selected-value:ast
                  =/  out-name  (heading c (crip "literal"))
                  =/  out-ta  (~(got by unq-lookup) out-name)
                  =/  qt  ?~(canonical-list default-qt -.i.canonical-list)
                  :~  :+  :^  %qualified-column
                              qt
                              out-name
                              ~
                          type.out-ta
                          addr.out-ta
                      ==
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
++  selected-has-cte-column
  |=  selected=(list selected-column:ast)
  ^-  ?
  |-
  ?~  selected  %.n
  ?:  ?=(selected-cte-column:ast i.selected)  %.y
  $(selected t.selected)
::
++  selected-needs-materialization
  ::  CTE must be materialized when selected columns include cte-columns,
  ::  literal values, or scalars, since these have no real addr in source rows.
  |=  selected=(list selected-column:ast)
  ^-  ?
  |-
  ?~  selected  %.n
  ?:  ?=(selected-cte-column:ast i.selected)  %.y
  ?:  ?=(selected-value:ast i.selected)  %.y
  ?:  ?=(selected-scalar:ast i.selected)  %.y
  $(selected t.selected)
::
++  materialized-cte-column-metas
  |=  [cte=@tas cols=(list column:ast)]
  ^-  (list column-meta)
  %+  turn
      cols
      |=  c=column:ast
      :+  [%qualified-column [%qualified-table ~ %cte %cte cte ~] name.c ~]
          type.c
          addr.c
::
++  materialize-cte-set-tables
  |=  $:  name=@tas
          selected=(list selected-column:ast)
          =named-ctes
          =join-return
          set-tables=(list set-table)
          =resolved-scalars
          ==
  ^-  (list set-table)
  ?~  set-tables  ~|("materialize-cte-set-tables can't get here" !!)
  =/  st  i.set-tables
  =/  out-cols  (addr-columns (cte-col-dups name columns.st))
  =/  has-jr  !=(~ joined-rows.st)
  =/  rows=(list data-row)  ?~  joined-rows.st
                             indexed-rows.st
                           joined-rows.st
  =.  columns.st       out-cols
  =.  relation.st      ~
  =.  join.st          ~
  =.  map-meta.st      [%unqualified-map-meta (mk-unqualified-typ-addr-lookup out-cols)]
  =/  src-map-meta  :-  %unqualified-map-meta
    %-  malt
    %+  turn  column-metas.join-return
    |=(a=column-meta [name.qualified-column.a [type.a addr.a]])
  ::  when materializing joined-rows, the inner query's primary key
  ::  doesn't apply to the flattened result; skip key extraction
  =/  mat-pri  ?:  has-jr  ~  pri-indx.st
  =.  indexed-rows.st
    %-  materialize-cte-indexed-rows
    [rows mat-pri column-metas.join-return src-map-meta selected named-ctes resolved-scalars]
  =.  joined-rows.st   ~
  =.  rowcount.st      (lent indexed-rows.st)
  =.  pri-indexed.st   (materialize-cte-pri-index mat-pri indexed-rows.st)
  [st t.set-tables]
::
++  materialize-cte-indexed-rows
  |=  $:  rows=(list data-row)
          pri=(unit index)
          column-metas=(list column-meta)
          =map-meta
          selected=(list selected-column:ast)
          =named-ctes
          =resolved-scalars
          ==
  ^-  (list indexed-row)
  ?~  rows  ~
  =/  templ-cells
    %-  mk-rel-vect-templ
    [column-metas selected -.rows map-meta resolved-scalars named-ctes]
  =/  key-cols=(unit (list key-column))  ?~(pri ~ [~ key.u.pri])
  =/  out=(list indexed-row)  ~
  =/  rows=(list data-row)  rows
  |-
  ?~  rows  (flop out)
  =/  data  (materialize-cte-row i.rows templ-cells)
  =/  key   ?~  key-cols
              ~
            (turn u.key-cols |=(a=key-column (~(got by data) name.a)))
  %=  $
    rows  t.rows
    out   :-  [%indexed-row key data]  out
  ==
::
++  materialize-cte-row
  |=  [row=data-row templ-cells=(list templ-cell)]
  ^-  (map @tas @)
  =/  out  *(map @tas @)
  |-
  ?~  templ-cells  out
  =/  x
    ?^  scalar.i.templ-cells
      q:(resolve-selected-scalar row (need scalar.i.templ-cells))
    ?~  column.i.templ-cells
      q.q.vc.i.templ-cells
    .*(data.row [%0 addr.i.templ-cells])
  %=  $
    templ-cells  t.templ-cells
    out          (~(put by out) p.vc.i.templ-cells ?@(x x ;;(@ +.x)))
  ==
::
++  materialize-cte-pri-index
  |=  [pri=(unit index) rows=(list indexed-row)]
  ^-  (tree [(list @) (map @tas @)])
  ?~  pri  ~
  =/  primary-key  (pri-key key.u.pri)
  =/  out  *(tree [(list @) (map @tas @)])
  |-
  ?~  rows  out
  %=  $
    rows  t.rows
    out   (put:primary-key out key.i.rows data.i.rows)
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
  ::  Build row map incrementally, no intermediate list or key-map.
  |=  [p=(list value-or-default:ast) q=(list column:ast)]
  ^-  (map @tas @)
  =/  cells  *(map @tas @)
  |-
  ?~  p  cells
  =/  cell=[@tas @]  (row-cell -.p -.q)
  %=  $
    cells  (~(put by cells) -.cell +.cell)
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
++  crud-txn-has-rand
  |=  [scalars=(list scalar:ast) ctes=(list cte:ast)]
  ^-  ?
  ?|  (scalars-have-rand scalars)
      %+  lien  ctes
        |=  c=cte:ast
        ?.  ?=([%query *] body.c)  |
        (scalars-have-rand scalars.+.body.c)
  ==
::
++  scalars-have-rand
  |=  scalars=(list scalar:ast)
  ^-  ?
  (lien scalars |=(s=scalar:ast (node-has-rand `scalar-node:ast`f.s)))
::
++  node-has-rand
  |=  sn=scalar-node:ast
  ^-  ?
  ?:  ?=([%rand *] sn)  %.y
  %+  lien  (scalar-node-children sn)
  |=(n=scalar-node:ast ^$(sn n))
::
++  scalar-node-children
  |=  sn=scalar-node:ast
  ^-  (list scalar-node:ast)
  ::  exclude dime and scalar-name (atom payloads, no children)
  ::  also excludes concat with empty args (no children)
  ?:  ?=(@ +.sn)  ~
  ?+  -.sn  ~
    %arithmetic     ~[left.sn right.sn]
    %if-then-else   ~[then.sn else.sn]
  ::
    %case
      %+  weld  ?~(target.sn ~ ~[u.target.sn])
      %+  weld  (turn cases.sn |=(cwt=case-when-then:ast then.cwt))
      ?~(else.sn ~ ~[u.else.sn])
  ::
    %coalesce  data.sn
  ::  datetime
    %year      ~[date.sn]
    %month     ~[date.sn]
    %day       ~[time-expression.sn]
    %hour      ~[time-expression.sn]
    %minute    ~[time-expression.sn]
    %second    ~[time-expression.sn]
  ::
    %add-time       ~[time-expression.sn duration.sn]
    %subtract-time  ~[time-expression.sn duration.sn]
  ::  math
    %abs       ~[numeric-expression.sn]
    %acos      ~[numeric-expression.sn]
    %asin      ~[numeric-expression.sn]
    %atan      ~[numeric-expression.sn]
    %ceiling   ~[numeric-expression.sn]
    %cos       ~[numeric-expression.sn]
    %degrees   ~[numeric-expression.sn]
    %floor     ~[numeric-expression.sn]
    %sign      ~[numeric-expression.sn]
    %sin       ~[numeric-expression.sn]
    %tan       ~[numeric-expression.sn]
    %sqrt      ~[float-expression.sn]
    %atan2     ~[numeric-expression-1.sn numeric-expression-2.sn]
    %max       ~[numeric-expression-1.sn numeric-expression-2.sn]
    %min       ~[numeric-expression-1.sn numeric-expression-2.sn]
    %round     ~[numeric-expression.sn length.sn]
  ::
    %log
      ?~(base.sn ~[float-expression.sn] ~[float-expression.sn u.base.sn])
  ::  string
    %len       ~[string-expression.sn]
    %lower     ~[string-expression.sn]
    %reverse   ~[string-expression.sn]
    %upper     ~[string-expression.sn]
    %string    ~[numeric-expression.sn]
  ::
    %left       ~[string-expression.sn integer-expression.sn]
    %patindex   ~[string-expression.sn pattern.sn]
    %replicate  ~[string-expression.sn integer-expression.sn]
    %right      ~[string-expression.sn integer-expression.sn]
  ::
    %ltrim
      ?~(pattern.sn ~[string-expression.sn] ~[string-expression.sn u.pattern.sn])
    %rtrim
      ?~(pattern.sn ~[string-expression.sn] ~[string-expression.sn u.pattern.sn])
    %trim
      ?~(pattern.sn ~[string-expression.sn] ~[string-expression.sn u.pattern.sn])
    %substring
      ?~  length.sn  ~[string-expression.sn start.sn]
      ~[string-expression.sn start.sn u.length.sn]
  ::
    %replace  ~[string-expression.sn pattern.sn replacement.sn]
    %stuff    ~[string-expression.sn start.sn length.sn replace.sn]
  ::
    %concat       args.sn
    %string-concat
      ?@(args.sn ~[delimiter.sn] [delimiter.sn args.sn])
    %quotestring
      ?~  quote.sn  ~[string-expression.sn]
      ~[string-expression.sn -.u.quote.sn +.u.quote.sn]
  ==
--
 
