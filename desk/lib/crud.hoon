/-  ast=obelisk-ast, *obelisk, *server-state-1
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
  ::  Unlike the other data manipulation functions (INSERT, UPSERT, DELETE,
  ::  UPDATE),
  ::  TRUNCATE TABLE can future date its action. This however effectively locks
  ::  the database for data updates until that time.
  |=  $:  d=truncate-table:ast
          next-schemas=(map @tas @da)
          next-data=(map @tas @da)
          ==
  ^-  [cmd-result:ast (map @tas @da) (map @tas @da) server]
  =/  work-state  %:  mk-work-state  bowl
                                     state
                                     qualified-table.d
                                     next-schemas
                                     next-data
                                     as-of.d
                                     "TRUNCATE"
                                     ==
  =/  db=database        -.work-state
  =/  sys-time=@da       +<.work-state
  =/  nxt-schema=schema  +>-.work-state
  =/  nxt-data=data      +>+.work-state
  ::
  =/  tbl=table
    ~|  "TRUNCATE TABLE: {<name.qualified-table.d>} ".
        "does not exists in {<namespace.qualified-table.d>}"
    %-  ~(got by tables:nxt-schema)
        [namespace.qualified-table.d name.qualified-table.d]
  ::
  =/  parent-file=file
    ~|  "TRUNCATE TABLE: {<namespace.qualified-table.d>}".
        ".{<name.qualified-table.d>} does not exist"
    %-  ~(got by files.nxt-data)
    [namespace.qualified-table.d name.qualified-table.d]
  ?.  (gth rowcount.parent-file 0)  :: don't bother if table is empty
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
  =/  tbl-key=[@tas @tas]  [namespace.qualified-table.d name.qualified-table.d]
  =/  deleted-parent-rows=(list indexed-row)  indexed-rows.parent-file
  =/  dummy
        %:  assert-delete-restrict
              "TRUNCATE TABLE"
              content.db
              sys-time
              tbl-key
              parent-file
              foreign-constraints.parent-file
              deleted-parent-rows
              ==
  =/  cascaded=[data file]
        %:  apply-truncate-cascades
              tables.nxt-schema
              content.db
              sys-time
              sys-time
              tbl-key
              parent-file
              foreign-constraints.parent-file
              nxt-data
              ==
  =.  nxt-data  -.cascaded
  =.  parent-file  +.cascaded
  =/  defaulted=[data file]
        %:  apply-delete-set-defaults
              "TRUNCATE TABLE"
              tables.nxt-schema
              content.db
              sys-time
              sys-time
              tbl-key
              parent-file
              foreign-constraints.parent-file
              deleted-parent-rows
              nxt-data
              ==
  =.  nxt-data  -.defaulted
  =.  parent-file  +.defaulted
  ::
  =/  tbl-fks=(list outbound-fk-entry)
        (collect-outbound-fks outbound-fk-index.tbl)
  =/  cleared=[data file]
        %:  clear-outbound-constrained-values
              content.db
              sys-time
              tbl-key
              parent-file
              tbl-fks
              nxt-data
              sys-time
              ==
  =.  nxt-data     -.cleared
  =.  parent-file  +.cleared
  =.  parent-file  (clear-all-incoming-constrained-values parent-file sys-time)
  ::
  =/  dropped-rows  rowcount.parent-file
  =.  pri-idx.parent-file         ~
  =.  indexed-rows.parent-file    ~
  =.  rowcount.parent-file        0
  =.  tmsp.parent-file            sys-time
  =/  files  %+  ~(put by files.nxt-data)
                 [namespace.qualified-table.d name.qualified-table.d]
             parent-file
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
          ::::~&  "{<name.qualified-table.+.body.crud-txn>}"   :: table name
          ::::~>  %bout.[0 %insert]
          (do-insert +.body.crud-txn next-data next-schemas)
    %upsert
      ?:  query-has-run  ~|("UPSERT: state change after query in script" !!)
      :-  %.n
          (do-upsert +.body.crud-txn next-data next-schemas)
    %query
      =/  q=query:ast  +.body.crud-txn
      :-  %.y
          ::::~&  "{<relation:(need from.q)>}"   :: from objects
          ::::~>  %bout.[0 %select]
          =/  rt  (do-query q named-ctes %.n)
          =/  results  (select-results named-ctes -.rt +.rt)
          :+  next-data  ->-.rt
          ?.  (crud-txn-has-rand scalars.q ctes.crud-txn)
            results
          [[%message 'warning: results are non-deterministic'] results]
    %set-query
      =/  sq=set-query:ast  +.body.crud-txn
      :-  %.y
          =/  rt  (do-set-query sq named-ctes)
          =/  results  (select-results named-ctes -.rt +.rt)
          :+  next-data  ->-.rt
          ?.  ?|  (set-query-has-rand sq)
                  (ctes-have-rand ctes.crud-txn)
              ==
            results
          [[%message 'warning: results are non-deterministic'] results]
    %merge
      ?:  query-has-run  ~|("MERGE: state change after query in script" !!)
      ~|("merge not implemented" !!)
    %delete
      ?:  query-has-run  ~|("DELETE: state change after query in script" !!)
      :-  %.n
          (do-delete +.body.crud-txn named-ctes next-data next-schemas)
    %update
      ?:  query-has-run  ~|("UPDATE: state change after query in script" !!)
      :-  %.n
          (do-update +.body.crud-txn named-ctes next-data next-schemas)
  ==
::
++  do-insert
  |=  [ins=insert:ast next-data=(map @tas @da) next-schemas=(map @tas @da)]
  ^-  [(map @tas @da) server (list result:ast)]
  (do-insert-upsert %insert ins next-data next-schemas)
::
++  do-upsert
  |=  [ins=insert:ast next-data=(map @tas @da) next-schemas=(map @tas @da)]
  ^-  [(map @tas @da) server (list result:ast)]
  (do-insert-upsert %upsert ins next-data next-schemas)
::
++  do-insert-upsert
  |=  $:  op=?(%insert %upsert)
          ins=insert:ast
          next-data=(map @tas @da)
          next-schemas=(map @tas @da)
      ==
  ^-  [(map @tas @da) server (list result:ast)]
  =/  verb=tape  ?:  =(%insert op)  "INSERT"  "UPSERT"
  =/  message=@t  ?:  =(%insert op)  'inserted:'  'upserted:'
  =/  txn  %:  common-txn  verb
                           state
                           now.bowl
                           qualified-table.ins
                           as-of.ins
                           next-schemas
                           ==
  =/  cur-schema=schema
        %:  get-next-schema  sys.db.txn
                             next-schemas
                             now.bowl
                             database.qualified-table.ins
                             ==
  =/  effective-time=@da  (set-tmsp as-of.ins now.bowl)
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
          ?:  =(%insert op)
            ~|("INSERT: incorrect columns specified: {<columns.ins>}" !!)
          ~|("UPSERT: incorrect columns specified: {<columns.ins>}" !!)
        %+  turn
            `(list @t)`(need columns.ins)
            |=(a=@t (to-column op a column-lookup.table.txn))
  ::
  ?.  ?=([%data *] values.ins)
    ?:  =(%insert op)
      ~|("INSERT: from query not implemented: {<values.ins>}" !!)
    ~|("UPSERT: from query not implemented: {<values.ins>}" !!)
  =/  value-table  `(list (list value-or-default:ast))`+.values.ins
  ::
  ?.  =((lent cols) (lent -.value-table))
        ?:  =(%insert op)
          ~|("INSERT: incorrect columns specified: {<-.value-table>}" !!)
        ~|("UPSERT: incorrect columns specified: {<-.value-table>}" !!)
  ::
  =/  i=@ud  0
  =/  key-pick=(list [@tas @])
        %+  turn
            key.pri-indx.table.txn
            |=(a=key-column (make-key-pick name.a column-lookup.table.txn))
  =/  primary-key  (pri-key key.pri-indx.table.txn)
  =/  inserted-rows=(list indexed-row)  ~
  ::
  =.  state          (update-sys state now.bowl)
  ::
  |-
  ?~  value-table
    =/  result-rowcount=@ud  ~(wyt by pri-idx.file.txn)
    =/  fks=(list outbound-fk-entry)
          (collect-outbound-fks outbound-fk-index.table.txn)
    =/  dummy
          %:  assert-child-fks
                op
                tables.cur-schema
                content.db.txn
                effective-time
                tbl-key.txn
                file.txn
                inserted-rows
                fks
                ==
    =/  child-key-cols=(list @tas)
          %+  turn  key.pri-indx.table.txn
          |=(col=key-column name.col)
    =/  constrained=[data file]
          %:  apply-insert-constrained-values
                content.db.txn
                effective-time
                tbl-key.txn
                child-key-cols
                file.txn
                inserted-rows
                fks
                nxt-data.txn
                now.bowl
                ==
    =.  nxt-data.txn  -.constrained
    =.  file.txn      +.constrained
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
                                                      result-rowcount
                                                      ==
                              view-cache  %:  upd-view-caches  state
                                                                db.txn
                                                                now.bowl
                                            :: to do: get list of effected views
                                                                [~ ~]
                                                                op
                                                                ==
                            ==
      :~  :-  %action
              %-  crip
                  %+  weld  (weld verb " INTO ")
                            (trip (qualified-table-to-cord qualified-table.ins))
          [%server-time now.bowl]
          [%schema-time tmsp.table.txn]
          [%data-time source-content-time.txn]
          [%message message]
          [%vector-count i]
          [%message 'table data:']
          [%vector-count result-rowcount]
          ==
  ~|  "{<verb>}: {<tbl-key.txn>} row {<+(i)>}"
  =/  row=(list value-or-default:ast)  -.value-table
  =/  file-row=(map @tas @)  (row-cells-and-keys op row cols)
  =/  got-fr  ~(got by file-row)
  =/  row-key=(list @)  (turn key-pick |=(a=[@tas @] (got-fr -.a)))
  =/  inserted-row=indexed-row  [%indexed-row row-key file-row]
  =.  pri-idx.file.txn  ?:  =(%insert op)
                          ?:  (has:primary-key pri-idx.file.txn row-key)
                            ~|("INSERT: cannot add duplicate key: {<row-key>}" !!)
                          (put:primary-key pri-idx.file.txn row-key file-row)
                        (put:primary-key pri-idx.file.txn row-key file-row)
  %=  $
    i              +(i)
    value-table    `(list (list value-or-default:ast))`+.value-table
    inserted-rows  [inserted-row inserted-rows]
  ==
::
++  do-delete
  |=  $:  d=delete:ast
          =named-ctes
          next-schemas=(map @tas @da)
          next-data=(map @tas @da)
          ==
  ^-  [(map @tas @da) server (list result:ast)]
  =/  txn  %:  common-txn  "DELETE FROM"
                           state
                           now.bowl
                           qualified-table.d
                           as-of.d
                           next-schemas
                           ==
  =/  cur-schema=schema
        %:  get-next-schema  sys.db.txn
                             next-schemas
                             now.bowl
                             database.qualified-table.d
                             ==
  =/  effective-time=@da  (set-tmsp as-of.d now.bowl)
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
  =/  del-qualifier-lookup=qualifier-lookup
    %+  roll  columns.table.txn
              |=  [c=column:ast ql=qualifier-lookup]
              (~(put by ql) name.c (limo ~[qualified-table.d]))
  =/  resolved-scalars
    %:  resolve-query-scalars(state state, bowl bowl)
          scalars.d
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
  =/  deleted-parent-rows=(list indexed-row)
        ?~  filter
          indexed-rows.file.txn
        %+  skim  indexed-rows.file.txn
                  |=(a=indexed-row ((need filter) a))
  =/  dummy
        %:  assert-delete-restrict
              "DELETE"
              content.db.txn
              effective-time
              tbl-key.txn
              file.txn
              foreign-constraints.file.txn
              deleted-parent-rows
              ==
  =/  cascaded=[data file]
        %:  apply-delete-cascades
              tables.cur-schema
              content.db.txn
              effective-time
              now.bowl
              tbl-key.txn
              file.txn
              foreign-constraints.file.txn
              deleted-parent-rows
              nxt-data.txn
              ==
  =.  nxt-data.txn  -.cascaded
  =.  file.txn      +.cascaded
  =/  defaulted=[data file]
        %:  apply-delete-set-defaults
              "DELETE"
              tables.cur-schema
              content.db.txn
              effective-time
              now.bowl
              tbl-key.txn
              file.txn
              foreign-constraints.file.txn
              deleted-parent-rows
              nxt-data.txn
              ==
  =.  nxt-data.txn  -.defaulted
  =.  file.txn      +.defaulted
  =/  fks=(list outbound-fk-entry)
        (collect-outbound-fks outbound-fk-index.table.txn)
  =/  child-key-cols=(list @tas)
        %+  turn  key.pri-indx.table.txn
        |=(col=key-column name.col)
  =/  constrained=[data file]
        %:  apply-delete-constrained-values
              content.db.txn
              effective-time
              tbl-key.txn
              child-key-cols
              file.txn
              deleted-parent-rows
              fks
              nxt-data.txn
              now.bowl
              ==
  =.  nxt-data.txn  -.constrained
  =.  file.txn      +.constrained
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
  |=  $:  u=update:ast
          =named-ctes
          next-schemas=(map @tas @da)
          next-data=(map @tas @da)
          ==
  ^-  [(map @tas @da) server (list result:ast)]
  =/  txn  %:  common-txn  "UPDATE"
                           state
                           now.bowl
                           qualified-table.u
                           as-of.u
                           next-schemas
                           ==
  =/  cur-schema=schema
        %:  get-next-schema  sys.db.txn
                             next-schemas
                             now.bowl
                             database.qualified-table.u
                             ==
  =/  effective-time=@da  (set-tmsp as-of.u now.bowl)
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
  =/  upd-qualifier-lookup=qualifier-lookup
    %+  roll  columns.table.txn
              |=  [c=column:ast ql=qualifier-lookup]
              (~(put by ql) name.c (limo ~[qualified-table.u]))
  =/  resolved-scalars
    %:  resolve-query-scalars(state state, bowl bowl)
          scalars.u
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
  =/  pk-updated=?  (gth ~(wyt in (~(int in aa) bb)) 0)
  =/  updated-cols=(list @tas)
        %+  weld
          (turn static-updates |=(a=[@tas @] -.a))
          (turn scalar-updates |=(a=[@tas @tas] -.a))
  =/  xx  ?:  pk-updated  :: update key column?
            :*  filter
                static-updates
                scalar-updates
                resolved-scalars
                key.pri-indx.table.txn
                columns.table.txn
                ==
          :*  filter
              static-updates
              scalar-updates
              resolved-scalars
              ~
              columns.table.txn
              ==
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
  =/  changed-parent-rows=(list indexed-row)
        ?:  pk-updated
          (changed-parent-key-rows indexed-rows.file.txn -.rows-count)
        ~
  =/  changed-parent-pairs=(list [old=indexed-row new=indexed-row])
        ?:  pk-updated
          (changed-parent-key-pairs indexed-rows.file.txn -.rows-count)
        ~
  =/  dummy
        %:  assert-update-restrict
              content.db.txn
              effective-time
              tbl-key.txn
              file.txn
              foreign-constraints.file.txn
              changed-parent-rows
              ==
  ::
  =/  cascaded=[data file]
        %:  apply-update-cascades
              tables.cur-schema
              content.db.txn
              effective-time
              now.bowl
              tbl-key.txn
              file.txn
              foreign-constraints.file.txn
              changed-parent-pairs
              nxt-data.txn
              ==
  =.  nxt-data.txn  -.cascaded
  =.  file.txn      +.cascaded
  ::
  =/  defaulted=[data file]
        %:  apply-update-set-defaults
              tables.cur-schema
              content.db.txn
              effective-time
              now.bowl
              tbl-key.txn
              file.txn
              foreign-constraints.file.txn
              changed-parent-pairs
              nxt-data.txn
              ==
  =.  nxt-data.txn  -.defaulted
  =.  file.txn      +.defaulted
  ::
  =/  fks=(list outbound-fk-entry)
        ?:  pk-updated
          (collect-outbound-fks outbound-fk-index.table.txn)
        (outbound-fks-for-columns outbound-fk-index.table.txn updated-cols)
  =/  dummy
        %:  assert-child-fks
              %update
              tables.cur-schema
              content.db.txn
              effective-time
              tbl-key.txn
              file.txn
              -.rows-count
              fks
              ==
  ::
  =/  child-key-cols=(list @tas)
        %+  turn  key.pri-indx.table.txn
        |=(col=key-column name.col)
  =/  child-row-pairs=(list [old=indexed-row new=indexed-row])
        (changed-row-pairs indexed-rows.file.txn -.rows-count)
  =/  constrained=[data file]
        %:  apply-update-constrained-values
              content.db.txn
              effective-time
              tbl-key.txn
              child-key-cols
              file.txn
              child-row-pairs
              fks
              nxt-data.txn
              now.bowl
              ==
  =.  nxt-data.txn  -.constrained
  =.  file.txn      +.constrained
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
  ::  Execute one query AST and return updated relation metadata plus vectors.
  ::
  ::  Paths:
  ::  - No FROM: resolve scalar context and delegate to +select-literals.
  ::    Literal-only results have no source rows to deduplicate.
  ::  - FROM with no joins: delegate to +select-relation.  That path eventually
  ::    uses +relation-vectors, which deduplicates projected vectors in both
  ::    ordered and unordered relation paths.
  ::  - FROM with joins in a CTE: delegate to +join-all.  If there is no
  ::    predicate, return the joined relation without vectors so the CTE can be
  ::    materialized later.  If there is a predicate, filter joined rows here,
  ::    but still return no vectors.
  ::  - FROM with joins in a normal SELECT: delegate to +join-all, qualify the
  ::    selected columns, prepare the predicate, then delegate to +joined-result.
  ::    +joined-result uses a set to deduplicate projected vectors.
  ::  - Set queries are handled by +do-set-query, which calls +do-query for each
  ::    operand and deduplicates vectors through set operations.
  ::
  ::  State may be updated by insertion into view-cache, which does not affect
  ::  any other part of the state.
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
    =/  qualifier-lookup
          (mk-qualifier-lookup set-tables.join-return columns.select.q)
    =/  resolved-scalars
          %:  resolve-query-scalars(state state, bowl bowl)
                scalars.q
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
++  do-set-query
  |=  [sq=set-query:ast =named-ctes]
  ^-  [join-return (list vector)]
  =/  head-rt                     (do-query head.sq named-ctes %.n)
  =/  head-jr=join-return         -.head-rt
  =/  head-vectors=(list vector)  +.head-rt
  =.  state                       server.head-jr
  =/  out-cols                    %:  query-output-columns  head.sq
                                                            head-jr
                                                            head-vectors
                                                            named-ctes
                                                            ==
  =/  has-union                   (set-query-has-union sq)
  =.  out-cols                    ?:  has-union
                                    (check-union-output-names out-cols)
                                  out-cols
  =/  out-metas  %+  turn  out-cols
                           |=  c=column:ast
                           :+  [%qualified-column *qualified-table:ast name.c ~]
                               type.c
                               addr.c
  =/  rows=(set vector)         (vectors-to-set head-vectors)
  =/  sources=(list set-table)  set-tables.head-jr
  =/  rest                      tail.sq
  |-
  ?~  rest
    :-  :*  %join-return
            state
            sources
            map-meta.head-jr
            out-metas
            ==
        ~(tap in rows)
  =/  next-rt                     (do-query query.i.rest named-ctes %.n)
  =/  next-jr=join-return         -.next-rt
  =/  next-vectors=(list vector)  +.next-rt
  =.  state                       server.next-jr
  =/  next-cols                   %:  query-output-columns  query.i.rest
                                                            next-jr
                                                            next-vectors
                                                            named-ctes
                                                            ==
  =.  next-cols  ?:  has-union  (check-union-output-names next-cols)
                 next-cols
  %=  $
    rows     %:  apply-set-op  op.i.rest
                               rows
                               (vectors-to-set next-vectors)
                               ==
    sources  (weld sources set-tables.next-jr)
    rest     t.rest
  ==
::
++  set-query-has-union
  |=  sq=set-query:ast
  ^-  ?
  %+  lien  tail.sq
  |=  item=[op=set-op:ast =query:ast]
  =(%union op.item)
::
++  check-union-output-names
  |=  columns=(list column:ast)
  ^-  (list column:ast)
  =/  seen  *(map @tas ~)
  =/  all-columns  columns
  |-
  ?~  columns  all-columns
  ?:  (~(has by seen) name.i.columns)
    ~|  "SET-QUERY UNION: duplicate output column ".
        "{<name.i.columns>} in SELECT"
        !!
  %=  $
    columns  t.columns
    seen     (~(put by seen) name.i.columns ~)
  ==
::
++  vectors-to-set
  |=  vectors=(list vector)
  ^-  (set vector)
  (~(gas in *(set vector)) vectors)
::
++  apply-set-op
  |=  [op=set-op:ast left=(set vector) right=(set vector)]
  ^-  (set vector)
  ?-  op
    %union
      (~(uni in left) right)
    %except
      (~(dif in left) right)
    %intersect
      (~(int in left) right)
    %divided-by
      ~|("SET-QUERY DIVIDED BY execution not yet implemented" !!)
    %divide-with-remainder
      ~|("SET-QUERY DIVIDE WITH REMAINDER execution not yet implemented" !!)
  ==
::
++  query-output-columns
  |=  [q=query:ast =join-return vectors=(list vector) =named-ctes]
  ^-  (list column:ast)
  ?^  vectors
    (vector-columns i.vectors)
  =/  selected  (normalize-selected columns.select.q)
  =/  qualifier-lookup  (mk-qualifier-lookup set-tables.join-return selected)
  =/  resolved-scalars
        %:  resolve-query-scalars(state state, bowl bowl)  scalars.q
                                                           named-ctes
                                                           qualifier-lookup
                                                           map-meta.join-return
                                                           ==
  %-  selected-output-columns
  [selected column-metas.join-return named-ctes resolved-scalars]
::
++  vector-columns
  |=  v=vector
  ^-  (list column:ast)
  %-  addr-columns
  %+  turn  +.v
  |=  cell=vector-cell:ast
  [%column p.cell p.q.cell 0]
::
++  selected-output-columns
  |=  $:  selected=(list selected-column:ast)
          metas=(list column-meta)
          =named-ctes
          =resolved-scalars
          ==
  ^-  (list column:ast)
  =/  out  *(list column:ast)
  |-
  ?~  selected  (addr-columns (flop out))
  ?-  i.selected
    qualified-column:ast
      =/  cm
        %-  head
        %+  skim  metas
        |=  cm=column-meta
        ?&  =(qualifier.i.selected qualifier.qualified-column.cm)
            =(name.i.selected name.qualified-column.cm)
        ==
      %=  $
        selected  t.selected
        out       [[%column (heading i.selected name.i.selected) type.cm 0] out]
      ==
    unqualified-column:ast
      =/  cm
        %-  head
        %+  skim  metas
        |=  cm=column-meta
        =(name.i.selected name.qualified-column.cm)
      %=  $
        selected  t.selected
        out       [[%column (heading i.selected name.i.selected) type.cm 0] out]
      ==
    selected-value:ast
      %=  $
        selected  t.selected
        out       :-  :^  %column
                          (heading i.selected (crip "literal"))
                          p.value.i.selected
                          0
                      out
      ==
    selected-all:ast
      =/  cols
        %+  turn  metas
        |=  cm=column-meta
        [%column name.qualified-column.cm type.cm 0]
      %=  $
        selected  t.selected
        out       (weld (flop cols) out)
      ==
    selected-all-table:ast
      =/  cols
        %+  turn
          %+  skim  metas
          |=  cm=column-meta
          =(qualified-table.i.selected qualifier.qualified-column.cm)
        |=  cm=column-meta
        [%column name.qualified-column.cm type.cm 0]
      %=  $
        selected  t.selected
        out       (weld (flop cols) out)
      ==
    selected-scalar:ast
      =/  rs=resolved-scalar
        ~|  "SELECT: scalar {<name.i.selected>} not found"
        (~(got by resolved-scalars) name.i.selected)
      %=  $
        selected  t.selected
        out       :-  :^  %column
                          (heading i.selected name.i.selected)
                          (resolved-scalar-type rs)
                          0
                      out
      ==
    selected-cte-column:ast
      =/  cte-fr  (~(got by named-ctes) cte.i.selected)
      =/  ta=typ-addr  %+  ~(got bi:mip +.map-meta.cte-fr)
                              [%cte-name cte.i.selected ~]
                              name.i.selected
      %=  $
        selected  t.selected
        out       [[%column (heading i.selected name.i.selected) type.ta 0] out]
      ==
    selected-aggregate:ast
      ~|("SET-QUERY CTE: aggregate result schema not supported" !!)
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
                 [%result-set vectors]
                 [%server-time now.bowl]
                 [%schema-time created-tmsp:(~(got by server.join-return) %sys)]
                 [%data-time created-tmsp:(~(got by server.join-return) %sys)]
                 [%vector-count (lent vectors)]
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
    =/  map-meta        :-  %unqualified-map-meta
                            (mk-unqualified-typ-addr-lookup addressed-cols)
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
                                %.n
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
                    %.n
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
              %-  tail  %+  apply-resolved-scalar
                              (~(got by rs) sname)
                              [%indexed-row key.row data.row]
  =/  all-updates=(list [@tas @])  (weld updates row-scalars)
  ?~  f
    ?~  key-columns  :-  :+  %indexed-row
                             key.row
                             (produce-update row all-updates cols)
                         +(count)
    [(update-key row all-updates key-columns cols) +(count)]
  ?.  ((need f) [%indexed-row key.row data.row])  [row count]
  ?~  key-columns  :-  :+  %indexed-row
                           key.row
                           (produce-update row all-updates cols)
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
  ?.  ?=([%query *] body.i.ctes)
    ?>  ?=([%set-query *] body.i.ctes)
    =/  cte-sq=set-query:ast  +.body.i.ctes
    =/  sq-rt  (do-set-query cte-sq nctes)
    =/  sq-jr=join-return  -.sq-rt
    =/  sq-vectors=(list vector)  +.sq-rt
    =.  state  server.sq-jr
    =/  cte-fr
      %-  set-query-cte-relation
      [name.i.ctes sq-jr sq-vectors]
    %=  $
      nctes  (~(put by nctes) name.i.ctes cte-fr)
      ctes   +.ctes
    ==
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
                        :*  name.i.ctes
                            selected
                            nctes
                            join-return
                            cte-shaped
                            resolved-scalars
                            ==
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
++  set-query-cte-relation
  |=  [name=@tas =join-return vectors=(list vector)]
  ^-  full-relation
  =/  sys-db  ~|  "At least 1 user database must exist before 'sys' database ".
                  "can be accessed"
                  (~(got by state) %sys)
  =/  cols
    %-  addr-columns
    %-  cte-col-dups
    :-  name
    %+  turn  column-metas.join-return
    |=  cm=column-meta
    [%column name.qualified-column.cm type.cm 0]
  =/  row-data
    %+  turn  vectors
    |=  v=vector
    (vector-indexed-row v)
  =/  st
    :*  %set-table
        ~
        ~
        [~ created-tmsp.sys-db]
        [~ created-tmsp.sys-db]
        cols
        ~
        (lent row-data)
        [%unqualified-map-meta (mk-unqualified-typ-addr-lookup cols)]
        ~
        %.n
        *(tree [(list @) (map @tas @)])
        row-data
        *(list joined-row)
        ==
  =/  cte-map-meta
    %+  roll  cols
    |=  [c=column:ast map-meta=qualified-map-meta]
    ^-  qualified-map-meta
    :-  %qualified-map-meta
        %^  ~(put bi:mip +.map-meta)
              [%cte-name name ~]
              name.c
              [type.c addr.c]
  :*  %full-relation
      [%cte-name name ~]
      [st set-tables.join-return]
      cte-map-meta
      (materialized-cte-column-metas name cols)
      ==
::
++  vector-indexed-row
  |=  v=vector
  ^-  indexed-row
  =/  data  *(map @tas @)
  =/  cells=(list vector-cell:ast)  +.v
  |-
  ?~  cells  [%indexed-row ~ data]
  %=  $
    cells  t.cells
    data   (~(put by data) p.i.cells q.q.i.cells)
  ==
::
++  cte-set-tables
  |=  $:  name=@tas
          columns=(list selected-column:ast)
          st=(list set-table)
          =named-ctes
          =resolved-scalars
          ==
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
  =.  map-meta.new
        [%unqualified-map-meta (mk-unqualified-typ-addr-lookup columns.new)]
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
  =.  map-meta.st
        [%unqualified-map-meta (mk-unqualified-typ-addr-lookup out-cols)]
  =/  src-map-meta
        :-  %unqualified-map-meta
            %-  malt
                %+  turn
                    column-metas.join-return
                    |=(a=column-meta [name.qualified-column.a [type.a addr.a]])
  ::  when materializing joined-rows, the inner query's primary key
  ::  doesn't apply to the flattened result; skip key extraction
  =/  mat-pri  ?:  has-jr  ~  pri-indx.st
  =.  indexed-rows.st
    %-  materialize-cte-indexed-rows
        :*  rows
            mat-pri
            column-metas.join-return
            src-map-meta
            selected
            named-ctes
            resolved-scalars
            ==
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
  |=  $:  =file
          =data
          tbl-key=[@tas @tas]
          primary-key=(list key-column)
          result-rowcount=@ud
          ==
  =/  new-indexed-rows  %+  turn  (tap:(pri-key primary-key) pri-idx.file)
                                  |=(a=[(list @) (map @tas @)] [%indexed-row a])
  =.  indexed-rows.file    new-indexed-rows
  =.  rowcount.file        result-rowcount
  =.  files.data  (~(put by files.data) tbl-key file)
  data
::
++  collect-outbound-fks
  |=  idx=outbound-fk-index
  ^-  (list outbound-fk-entry)
  =/  pairs=(list [@tas (list outbound-fk-entry)])  ~(tap by idx)
  =/  out=(list outbound-fk-entry)  ~
  |-
  ?~  pairs  (flop out)
  =.  out  (add-unique-outbound-entries +.i.pairs out)
  $(pairs t.pairs)
::
++  apply-insert-constrained-values
  |=  $:  content=((mop @da data) gth)
          effective-time=@da
          child-key=[@tas @tas]
          child-key-cols=(list @tas)
          child-file=file
          rows=(list indexed-row)
          fks=(list outbound-fk-entry)
          acc-data=data
          edit-time=@da
          ==
  ^-  [data file]
  ?~  fks  [acc-data child-file]
  =/  updated=[data file]
        %:  apply-insert-constrained-value-fk  content
                                               effective-time
                                               child-key
                                               child-key-cols
                                               child-file
                                               rows
                                               i.fks
                                               acc-data
                                               edit-time
                                               ==
  %=  $
    fks         t.fks
    child-file  +.updated
    acc-data    -.updated
  ==
::
++  apply-insert-constrained-value-fk
  |=  $:  content=((mop @da data) gth)
          effective-time=@da
          child-key=[@tas @tas]
          child-key-cols=(list @tas)
          child-file=file
          rows=(list indexed-row)
          fk=outbound-fk-entry
          acc-data=data
          edit-time=@da
          ==
  ^-  [data file]
  ?~  rows  [acc-data child-file]
  =/  tuples=[parent-key=(list @) child-pk=(list @)]
        %:  outbound-fk-row-tuples  data.i.rows
                                    child-key-cols
                                    fk
                                    ==
  =/  updated=[data file]
        %:  add-insert-constrained-value-reference  content
                                                    effective-time
                                                    child-key
                                                    child-file
                                                    fk
                                                    parent-key.tuples
                                                    child-pk.tuples
                                                    acc-data
                                                    edit-time
                                                    ==
  %=  $
    rows        t.rows
    child-file  +.updated
    acc-data    -.updated
  ==
::
++  add-insert-constrained-value-reference
  |=  $:  content=((mop @da data) gth)
          effective-time=@da
          child-key=[@tas @tas]
          child-file=file
          fk=outbound-fk-entry
          parent-row-key=(list @)
          child-pk=(list @)
          acc-data=data
          edit-time=@da
          ==
  ^-  [data file]
  =/  parent-table-key=[@tas @tas]  reference-table.fk
  =/  edit=constrained-value-edit  [%add parent-row-key child-pk]
  ?:  =(parent-table-key child-key)
    =.  child-file
      %:  apply-constrained-value-edit-to-parent-file  child-file
                                                       child-key
                                                       constrained-columns.fk
                                                       edit
                                                       edit-time
                                                       ==
    [acc-data child-file]
  =/  parent-file=file
        ?:  (~(has by files.acc-data) parent-table-key)
          (~(got by files.acc-data) parent-table-key)
        (get-content content effective-time parent-table-key)
  =.  parent-file
    %:  apply-constrained-value-edit-to-parent-file  parent-file
                                                     child-key
                                                     constrained-columns.fk
                                                     edit
                                                     edit-time
                                                     ==
  =.  files.acc-data  (~(put by files.acc-data) parent-table-key parent-file)
  [acc-data child-file]
::
++  apply-update-constrained-values
  |=  $:  content=((mop @da data) gth)
          effective-time=@da
          child-key=[@tas @tas]
          child-key-cols=(list @tas)
          child-file=file
          pairs=(list [old=indexed-row new=indexed-row])
          fks=(list outbound-fk-entry)
          acc-data=data
          edit-time=@da
          ==
  ^-  [data file]
  ?~  fks  [acc-data child-file]
  =/  updated=[data file]
        %:  apply-update-constrained-value-fk  content
                                               effective-time
                                               child-key
                                               child-key-cols
                                               child-file
                                               pairs
                                               i.fks
                                               acc-data
                                               edit-time
                                               ==
  %=  $
    fks         t.fks
    child-file  +.updated
    acc-data    -.updated
  ==
::
++  apply-update-constrained-value-fk
  |=  $:  content=((mop @da data) gth)
          effective-time=@da
          child-key=[@tas @tas]
          child-key-cols=(list @tas)
          child-file=file
          pairs=(list [old=indexed-row new=indexed-row])
          fk=outbound-fk-entry
          acc-data=data
          edit-time=@da
          ==
  ^-  [data file]
  ?~  pairs  [acc-data child-file]
  =/  pair=[old=indexed-row new=indexed-row]  i.pairs
  =/  tuples=constrained-value-row-tuples
        %:  outbound-fk-row-move-tuples
              data.old.pair
              data.new.pair
              child-key-cols
              fk
              ==
  =/  updated=[data file]
        ?:  ?&  =(old-parent-key.tuples new-parent-key.tuples)
                =(old-child-pk.tuples new-child-pk.tuples)
                ==
          [acc-data child-file]
        %:  move-update-constrained-value-reference  content
                                                     effective-time
                                                     child-key
                                                     child-file
                                                     fk
                                                     tuples
                                                     acc-data
                                                     edit-time
                                                     ==
  %=  $
    pairs       t.pairs
    child-file  +.updated
    acc-data    -.updated
  ==
::
++  move-update-constrained-value-reference
  |=  $:  content=((mop @da data) gth)
          effective-time=@da
          child-key=[@tas @tas]
          child-file=file
          fk=outbound-fk-entry
          tuples=constrained-value-row-tuples
          acc-data=data
          edit-time=@da
          ==
  ^-  [data file]
  =/  parent-table-key=[@tas @tas]  reference-table.fk
  =/  edit=constrained-value-edit  :*  %move
                                       old-parent-key.tuples
                                       new-parent-key.tuples
                                       old-child-pk.tuples
                                       new-child-pk.tuples
                                       ==
  ?:  =(parent-table-key child-key)
    =.  child-file
      %:  apply-constrained-value-edit-to-parent-file  child-file
                                                       child-key
                                                       constrained-columns.fk
                                                       edit
                                                       edit-time
                                                       ==
    [acc-data child-file]
  =/  parent-file=file
        ?:  (~(has by files.acc-data) parent-table-key)
          (~(got by files.acc-data) parent-table-key)
        (get-content content effective-time parent-table-key)
  =.  parent-file
    %:  apply-constrained-value-edit-to-parent-file  parent-file
                                                     child-key
                                                     constrained-columns.fk
                                                     edit
                                                     edit-time
                                                     ==
  =.  files.acc-data  (~(put by files.acc-data) parent-table-key parent-file)
  [acc-data child-file]
::
++  apply-delete-constrained-values
  |=  $:  content=((mop @da data) gth)
          effective-time=@da
          child-key=[@tas @tas]
          child-key-cols=(list @tas)
          child-file=file
          rows=(list indexed-row)
          fks=(list outbound-fk-entry)
          acc-data=data
          edit-time=@da
          ==
  ^-  [data file]
  ?~  fks  [acc-data child-file]
  =/  updated=[data file]
        %:  apply-delete-constrained-value-fk  content
                                               effective-time
                                               child-key
                                               child-key-cols
                                               child-file
                                               rows
                                               i.fks
                                               acc-data
                                               edit-time
                                               ==
  %=  $
    fks         t.fks
    child-file  +.updated
    acc-data    -.updated
  ==
::
++  apply-delete-constrained-value-fk
  |=  $:  content=((mop @da data) gth)
          effective-time=@da
          child-key=[@tas @tas]
          child-key-cols=(list @tas)
          child-file=file
          rows=(list indexed-row)
          fk=outbound-fk-entry
          acc-data=data
          edit-time=@da
          ==
  ^-  [data file]
  ?~  rows  [acc-data child-file]
  =/  tuples=[parent-key=(list @) child-pk=(list @)]
        %:  outbound-fk-row-tuples  data.i.rows
                                    child-key-cols
                                    fk
                                    ==
  =/  updated=[data file]
        %:  remove-delete-constrained-value-reference  content
                                                       effective-time
                                                       child-key
                                                       child-file
                                                       fk
                                                       parent-key.tuples
                                                       child-pk.tuples
                                                       acc-data
                                                       edit-time
                                                       ==
  %=  $
    rows        t.rows
    child-file  +.updated
    acc-data    -.updated
  ==
::
++  remove-delete-constrained-value-reference
  |=  $:  content=((mop @da data) gth)
          effective-time=@da
          child-key=[@tas @tas]
          child-file=file
          fk=outbound-fk-entry
          parent-row-key=(list @)
          child-pk=(list @)
          acc-data=data
          edit-time=@da
          ==
  ^-  [data file]
  =/  parent-table-key=[@tas @tas]  reference-table.fk
  =/  edit=constrained-value-edit  [%remove parent-row-key child-pk]
  ?:  =(parent-table-key child-key)
    =.  child-file
      %:  apply-constrained-value-edit-to-parent-file  child-file
                                                       child-key
                                                       constrained-columns.fk
                                                       edit
                                                       edit-time
                                                       ==
    [acc-data child-file]
  =/  parent-file=file
        ?:  (~(has by files.acc-data) parent-table-key)
          (~(got by files.acc-data) parent-table-key)
        (get-content content effective-time parent-table-key)
  =.  parent-file
    %:  apply-constrained-value-edit-to-parent-file  parent-file
                                                     child-key
                                                     constrained-columns.fk
                                                     edit
                                                     edit-time
                                                     ==
  =.  files.acc-data  (~(put by files.acc-data) parent-table-key parent-file)
  [acc-data child-file]
::
++  clear-constrained-values-on-parent-file
  |=  $:  parent-file=file
          child-key=[@tas @tas]
          source-cols=(list @tas)
          clear-time=@da
          ==
  ^-  file
  =/  incoming=foreign-constraint
        %^  find-canonical-incoming-fk  foreign-constraints.parent-file
                                        child-key
                                        source-cols
  =.  constrained-values.incoming  *constrained-values
  =.  foreign-constraints.parent-file
        %:  replace-canonical-incoming-fk
              foreign-constraints.parent-file
              child-key
              source-cols
              incoming
              ==
  =.  tmsp.parent-file  clear-time
  parent-file
::
++  clear-all-incoming-constrained-values
  |=  [parent-file=file clear-time=@da]
  ^-  file
  =.  foreign-constraints.parent-file
    %+  turn  foreign-constraints.parent-file
    |=  incoming=foreign-constraint
    =.  constrained-values.incoming  *constrained-values
    incoming
  =.  tmsp.parent-file  clear-time
  parent-file
::
++  clear-outbound-constrained-values
  |=  $:  content=((mop @da data) gth)
          effective-time=@da
          child-key=[@tas @tas]
          child-file=file
          fks=(list outbound-fk-entry)
          acc-data=data
          clear-time=@da
          ==
  ^-  [data file]
  ?~  fks  [acc-data child-file]
  =/  cleared=[data file]  %:  clear-outbound-constrained-value  content
                                                                 effective-time
                                                                 child-key
                                                                 child-file
                                                                 i.fks
                                                                 acc-data
                                                                 clear-time
                                                                 ==
  %=  $
    fks         t.fks
    child-file  +.cleared
    acc-data    -.cleared
  ==
::
++  clear-outbound-constrained-value
  |=  $:  content=((mop @da data) gth)
          effective-time=@da
          child-key=[@tas @tas]
          child-file=file
          fk=outbound-fk-entry
          acc-data=data
          clear-time=@da
          ==
  ^-  [data file]
  =/  parent-table-key=[@tas @tas]  reference-table.fk
  ?:  =(parent-table-key child-key)
    =.  child-file
      %:  clear-constrained-values-on-parent-file  child-file
                                                   child-key
                                                   constrained-columns.fk
                                                   clear-time
                                                   ==
    [acc-data child-file]
  =/  parent-file=file
        ?:  (~(has by files.acc-data) parent-table-key)
          (~(got by files.acc-data) parent-table-key)
        (get-content content effective-time parent-table-key)
  =.  parent-file
    %:  clear-constrained-values-on-parent-file
          parent-file
          child-key
          constrained-columns.fk
          clear-time
          ==
  =.  files.acc-data  (~(put by files.acc-data) parent-table-key parent-file)
  [acc-data child-file]
::
++  outbound-fks-for-columns
  |=  [idx=outbound-fk-index cols=(list @tas)]
  ^-  (list outbound-fk-entry)
  =/  out=(list outbound-fk-entry)  ~
  |-
  ?~  cols  (flop out)
  =/  found=(unit (list outbound-fk-entry))  (~(get by idx) i.cols)
  =.  out
    ?~  found
      out
    (add-unique-outbound-entries u.found out)
  $(cols t.cols)
::
++  add-unique-outbound-entries
  |=  [entries=(list outbound-fk-entry) out=(list outbound-fk-entry)]
  ^-  (list outbound-fk-entry)
  |-
  ?~  entries  out
  %=  $
    entries  t.entries
    out      ?:  (outbound-entry-exists out i.entries)  out
              [i.entries out]
  ==
::
++  outbound-entry-exists
  |=  [entries=(list outbound-fk-entry) entry=outbound-fk-entry]
  ^-  ?
  ?~  entries  %.n
  ?:  ?&  =(reference-table.i.entries reference-table.entry)
          =(constrained-columns.i.entries constrained-columns.entry)
          =(reference-columns.i.entries reference-columns.entry)
          ==
    %.y
  $(entries t.entries)
::
++  assert-child-fks
  |=  $:  op=@tas
          tbls=tables
          content=((mop @da data) gth)
          effective-time=@da
          child-key=[@tas @tas]
          child-file=file
          rows=(list indexed-row)
          fks=(list outbound-fk-entry)
          ==
  ^-  ~
  ?~  fks  ~
  |-
  ?~  rows  ~
  =/  dummy  %:  assert-row-child-fks  op
                                       tbls
                                       content
                                       effective-time
                                       child-key
                                       child-file
                                       data.i.rows
                                       fks
                                       ==
  $(rows t.rows)
::
++  assert-row-child-fks
  |=  $:  op=@tas
          tbls=tables
          content=((mop @da data) gth)
          effective-time=@da
          child-key=[@tas @tas]
          child-file=file
          row=(map @tas @)
          fks=(list outbound-fk-entry)
          ==
  ^-  ~
  ?~  fks  ~
  =/  dummy  %:  assert-one-child-fk  op
                                      tbls
                                      content
                                      effective-time
                                      child-key
                                      child-file
                                      row
                                      i.fks
                                      ==
  $(fks t.fks)
::
++  assert-one-child-fk
  |=  $:  op=@tas
          tbls=tables
          content=((mop @da data) gth)
          effective-time=@da
          child-key=[@tas @tas]
          child-file=file
          row=(map @tas @)
          fk=outbound-fk-entry
          ==
  ^-  ~
  =/  parent-key=[@tas @tas]  reference-table.fk
  =/  parent-table=table  (~(got by tbls) parent-key)
  =/  parent-file=file  ?:  =(parent-key child-key)
                          child-file
                        (get-content content effective-time parent-key)
  =/  parent-primary-key  (pri-key key.pri-indx.parent-table)
  =/  fk-key=(list @)  (fk-row-values row constrained-columns.fk)
  ?.  (has:parent-primary-key pri-idx.parent-file fk-key)
    (fk-parent-not-found op)
  ~
::
++  fk-parent-not-found
  |=  op=@tas
  ^-  ~
  ?:  =(%insert op)
    ~|("INSERT: FOREIGN KEY parent key not found" !!)
  ?:  =(%upsert op)
    ~|("UPSERT: FOREIGN KEY parent key not found" !!)
  ~|("UPDATE: FOREIGN KEY parent key not found" !!)
::
++  fk-row-values
  |=  [row=(map @tas @) cols=(list @tas)]
  ^-  (list @)
  =/  values=(list @)  ~
  |-
  ?~  cols  (flop values)
  %=  $
    cols    t.cols
    values  [(~(got by row) i.cols) values]
  ==
::
++  assert-delete-restrict
  |=  $:  op=tape
          content=((mop @da data) gth)
          effective-time=@da
          parent-key=[@tas @tas]
          parent-file=file
          constraints=(list foreign-constraint)
          deleted-rows=(list indexed-row)
          ==
  ^-  ~
  ?~  deleted-rows  ~
  |-
  ?~  constraints  ~
  ?.  =(on-delete.actions.i.constraints %restrict)
    $(constraints t.constraints)
  =/  child-key=[@tas @tas]  constrained-table.i.constraints
  =/  child-file=file
        ?:  =(child-key parent-key)
          parent-file
        (get-content content effective-time child-key)
  =/  dummy  %:  assert-delete-restrict-constraint
                 op
                 child-file
                 constrained-columns.i.constraints
                 deleted-rows
                 ==
  $(constraints t.constraints)
::
++  assert-delete-restrict-constraint
  |=  $:  op=tape
          child-file=file
          source-cols=(list @tas)
          deleted-rows=(list indexed-row)
          ==
  ^-  ~
  ?~  deleted-rows  ~
  ?:  %^  child-has-fk-reference  indexed-rows.child-file
                                  source-cols
                                  key.i.deleted-rows
    ~|  %+  weld  op  ": FOREIGN KEY restrict violation"
        !!
  $(deleted-rows t.deleted-rows)
::
++  assert-update-restrict
  |=  $:  content=((mop @da data) gth)
          effective-time=@da
          parent-key=[@tas @tas]
          parent-file=file
          constraints=(list foreign-constraint)
          changed-rows=(list indexed-row)
          ==
  ^-  ~
  ?~  changed-rows  ~
  |-
  ?~  constraints  ~
  ?.  =(on-update.actions.i.constraints %restrict)
    $(constraints t.constraints)
  =/  child-key=[@tas @tas]  constrained-table.i.constraints
  =/  child-file=file
        ?:  =(child-key parent-key)
          parent-file
        (get-content content effective-time child-key)
  =/  dummy
        %:  assert-update-restrict-constraint
              child-file
              constrained-columns.i.constraints
              changed-rows
              ==
  $(constraints t.constraints)
::
++  assert-update-restrict-constraint
  |=  $:  child-file=file
          source-cols=(list @tas)
          changed-rows=(list indexed-row)
          ==
  ^-  ~
  ?~  changed-rows  ~
  ?:  %^  child-has-fk-reference  indexed-rows.child-file
                                  source-cols
                                  key.i.changed-rows
    ~|("UPDATE: FOREIGN KEY restrict violation" !!)
  $(changed-rows t.changed-rows)
::
++  changed-parent-key-rows
  |=  [old-rows=(list indexed-row) new-rows=(list indexed-row)]
  ^-  (list indexed-row)
  =/  changed=(list indexed-row)  ~
  |-
  ?~  old-rows
    (flop changed)
  ?~  new-rows
    (flop changed)
  %=  $
    old-rows  t.old-rows
    new-rows  t.new-rows
    changed   ?:  =(key.i.old-rows key.i.new-rows)
                changed
              [i.old-rows changed]
  ==
::
++  changed-parent-key-pairs
  |=  [old-rows=(list indexed-row) new-rows=(list indexed-row)]
  ^-  (list [old=indexed-row new=indexed-row])
  =/  changed=(list [old=indexed-row new=indexed-row])  ~
  |-
  ?~  old-rows
    (flop changed)
  ?~  new-rows
    (flop changed)
  %=  $
    old-rows  t.old-rows
    new-rows  t.new-rows
    changed   ?:  =(key.i.old-rows key.i.new-rows)
                changed
              [[i.old-rows i.new-rows] changed]
  ==
::
++  changed-row-pairs
  |=  [old-rows=(list indexed-row) new-rows=(list indexed-row)]
  ^-  (list [old=indexed-row new=indexed-row])
  =/  changed=(list [old=indexed-row new=indexed-row])  ~
  |-
  ?~  old-rows
    (flop changed)
  ?~  new-rows
    (flop changed)
  %=  $
    old-rows  t.old-rows
    new-rows  t.new-rows
    changed   ?:  =(i.old-rows i.new-rows)
                changed
              [[i.old-rows i.new-rows] changed]
  ==
::
++  child-has-fk-reference
  |=  $:  child-rows=(list indexed-row)
          source-cols=(list @tas)
          parent-row-key=(list @)
          ==
  ^-  ?
  ?~  child-rows  %.n
  ?:  =((fk-row-values data.i.child-rows source-cols) parent-row-key)
    %.y
  $(child-rows t.child-rows)
::
++  apply-update-cascades
  |=  $:  tbls=tables
          content=((mop @da data) gth)
          effective-time=@da
          now=@da
          parent-key=[@tas @tas]
          parent-file=file
          constraints=(list foreign-constraint)
          changed-pairs=(list [old=indexed-row new=indexed-row])
          cur-data=data
          ==
  ^-  [data file]
  ?~  changed-pairs  [cur-data parent-file]
  |-
  ?~  constraints  [cur-data parent-file]
  ?.  =(on-update.actions.i.constraints %cascade)
    $(constraints t.constraints)
  =/  cascaded=[data file]
        %:  apply-update-cascade-constraint  tbls
                                             content
                                             effective-time
                                             now
                                             parent-key
                                             parent-file
                                             i.constraints
                                             changed-pairs
                                             cur-data
                                             ==
  %=  $
    constraints  t.constraints
    cur-data     -.cascaded
    parent-file  +.cascaded
  ==
::
++  apply-update-cascade-constraint
  |=  $:  tbls=tables
          content=((mop @da data) gth)
          effective-time=@da
          now=@da
          parent-key=[@tas @tas]
          parent-file=file
          constraint=foreign-constraint
          changed-pairs=(list [old=indexed-row new=indexed-row])
          cur-data=data
          ==
  ^-  [data file]
  =/  child-key=[@tas @tas]  constrained-table.constraint
  =/  child-table=table      (~(got by tbls) child-key)
  =/  child-file=file
        ?:  =(child-key parent-key)
          parent-file
        ?:  (~(has by files.cur-data) child-key)
          (~(got by files.cur-data) child-key)
        (get-content content effective-time child-key)
  =/  old-child-rows=(list indexed-row)  indexed-rows.child-file
  =.  indexed-rows.child-file
        %+  turn  indexed-rows.child-file
        |=  row=indexed-row
        =/  updates=(list [@tas @])  %:  update-cascade-row-updates
                                         row
                                         constrained-columns.constraint
                                         changed-pairs
                                         ==
        ?~  updates
          row
        (update-key row updates key.pri-indx.child-table columns.child-table)
  =/  child-row-pairs=(list [old=indexed-row new=indexed-row])
        (changed-row-pairs old-child-rows indexed-rows.child-file)
  =.  files.cur-data
        ?:  =(child-key parent-key)
          files.cur-data
        (~(put by files.cur-data) parent-key parent-file)
  =/  child-key-cols=(list @tas)
        %+  turn  key.pri-indx.child-table
        |=(col=key-column name.col)
  =/  child-fks=(list outbound-fk-entry)
        (collect-outbound-fks outbound-fk-index.child-table)
  =/  constrained=[data file]
        %:  apply-update-constrained-values  content
                                             effective-time
                                             child-key
                                             child-key-cols
                                             child-file
                                             child-row-pairs
                                             child-fks
                                             cur-data
                                             now
                                             ==
  =.  cur-data    -.constrained
  =.  child-file  +.constrained
  =.  parent-file
        ?:  =(child-key parent-key)
          child-file
        (~(got by files.cur-data) parent-key)
  =.  tmsp.child-file  now
  =.  child-file       (rebuild-primary-index child-table child-file)
  ?:  =(child-key parent-key)
    [cur-data child-file]
  =.  files.cur-data  (~(put by files.cur-data) child-key child-file)
  [cur-data parent-file]
::
++  update-cascade-row-updates
  |=  $:  child-row=indexed-row
          source-cols=(list @tas)
          changed-pairs=(list [old=indexed-row new=indexed-row])
          ==
  ^-  (list [@tas @])
  =/  child-fk-key=(list @)  (fk-row-values data.child-row source-cols)
  |-
  ?~  changed-pairs  ~
  =/  pair=[old=indexed-row new=indexed-row]  i.changed-pairs
  ?:  =(child-fk-key key.old.pair)
    (pair-cols-values source-cols key.new.pair)
  $(changed-pairs t.changed-pairs)
::
++  pair-cols-values
  |=  [cols=(list @tas) values=(list @)]
  ^-  (list [@tas @])
  =/  out=(list [@tas @])  ~
  |-
  ?~  cols  (flop out)
  ?~  values  (flop out)
  %=  $
    cols    t.cols
    values  t.values
    out     [[i.cols i.values] out]
  ==
::
++  apply-update-set-defaults
  |=  $:  tbls=tables
          content=((mop @da data) gth)
          effective-time=@da
          now=@da
          parent-key=[@tas @tas]
          parent-file=file
          constraints=(list foreign-constraint)
          changed-pairs=(list [old=indexed-row new=indexed-row])
          cur-data=data
          ==
  ^-  [data file]
  ?~  changed-pairs  [cur-data parent-file]
  |-
  ?~  constraints  [cur-data parent-file]
  ?.  =(on-update.actions.i.constraints %set-default)
    $(constraints t.constraints)
  =/  defaulted=[data file]
        %:  apply-update-set-default-constraint  tbls
                                                 content
                                                 effective-time
                                                 now
                                                 parent-key
                                                 parent-file
                                                 i.constraints
                                                 changed-pairs
                                                 cur-data
                                                 ==
  %=  $
    constraints  t.constraints
    cur-data     -.defaulted
    parent-file  +.defaulted
  ==
::
++  apply-update-set-default-constraint
  |=  $:  tbls=tables
          content=((mop @da data) gth)
          effective-time=@da
          now=@da
          parent-key=[@tas @tas]
          parent-file=file
          constraint=foreign-constraint
          changed-pairs=(list [old=indexed-row new=indexed-row])
          cur-data=data
          ==
  ^-  [data file]
  =/  child-key=[@tas @tas]  constrained-table.constraint
  =/  child-table=table      (~(got by tbls) child-key)
  =/  child-file=file
        ?:  =(child-key parent-key)
          parent-file
        ?:  (~(has by files.cur-data) child-key)
          (~(got by files.cur-data) child-key)
        (get-content content effective-time child-key)
  =/  updates=(list [@tas @])
        (default-updates constrained-columns.constraint columns.child-table)
  =/  default-key=(list @)  (turn updates |=(u=[@tas @] +.u))
  =/  parent-table=table  (~(got by tbls) parent-key)
  =/  dummy  %^  assert-update-set-default-parent  parent-table
                                                   parent-file
                                                   default-key
  =/  old-child-rows=(list indexed-row)  indexed-rows.child-file
  =.  indexed-rows.child-file
        %+  turn  indexed-rows.child-file
        |=  row=indexed-row
        ?:  %^  child-row-matches-changed  row
                                           constrained-columns.constraint
                                           changed-pairs
          (update-key row updates key.pri-indx.child-table columns.child-table)
        row
  =/  child-row-pairs=(list [old=indexed-row new=indexed-row])
        (changed-row-pairs old-child-rows indexed-rows.child-file)
  =.  files.cur-data
        ?:  =(child-key parent-key)
          files.cur-data
        (~(put by files.cur-data) parent-key parent-file)
  =/  child-key-cols=(list @tas)
        %+  turn  key.pri-indx.child-table
        |=(col=key-column name.col)
  =/  child-fks=(list outbound-fk-entry)
        (collect-outbound-fks outbound-fk-index.child-table)
  =/  constrained=[data file]
        %:  apply-update-constrained-values  content
                                             effective-time
                                             child-key
                                             child-key-cols
                                             child-file
                                             child-row-pairs
                                             child-fks
                                             cur-data
                                             now
                                             ==
  =.  cur-data    -.constrained
  =.  child-file  +.constrained
  =.  parent-file
        ?:  =(child-key parent-key)
          child-file
        (~(got by files.cur-data) parent-key)
  =.  tmsp.child-file  now
  =.  child-file       (rebuild-primary-index child-table child-file)
  ?:  =(child-key parent-key)
    [cur-data child-file]
  =.  files.cur-data  (~(put by files.cur-data) child-key child-file)
  [cur-data parent-file]
::
++  child-row-matches-changed
  |=  $:  child-row=indexed-row
          source-cols=(list @tas)
          changed-pairs=(list [old=indexed-row new=indexed-row])
          ==
  ^-  ?
  =/  child-fk-key=(list @)  (fk-row-values data.child-row source-cols)
  |-
  ?~  changed-pairs  %.n
  =/  pair=[old=indexed-row new=indexed-row]  i.changed-pairs
  ?:  =(child-fk-key key.old.pair)  %.y
  $(changed-pairs t.changed-pairs)
::
++  assert-update-set-default-parent
  |=  [parent-table=table parent-file=file default-key=(list @)]
  ^-  ~
  =/  parent-primary-key  (pri-key key.pri-indx.parent-table)
  ?.  (has:parent-primary-key pri-idx.parent-file default-key)
    ~|("UPDATE: FOREIGN KEY SET DEFAULT parent bunt key not found" !!)
  ~
::
++  apply-truncate-cascades
  |=  $:  tbls=tables
          content=((mop @da data) gth)
          effective-time=@da
          now=@da
          parent-key=[@tas @tas]
          parent-file=file
          constraints=(list foreign-constraint)
          cur-data=data
          ==
  ^-  [data file]
  |-
  ?~  constraints  [cur-data parent-file]
  ?.  =(on-delete.actions.i.constraints %cascade)
    $(constraints t.constraints)
  =/  cascaded=[data file]
        %:  apply-truncate-cascade-constraint  tbls
                                               content
                                               effective-time
                                               now
                                               parent-key
                                               parent-file
                                               i.constraints
                                               cur-data
                                               ==
  %=  $
    constraints  t.constraints
    cur-data     -.cascaded
    parent-file  +.cascaded
  ==
::
++  apply-truncate-cascade-constraint
  |=  $:  tbls=tables
          content=((mop @da data) gth)
          effective-time=@da
          now=@da
          parent-key=[@tas @tas]
          parent-file=file
          constraint=foreign-constraint
          cur-data=data
          ==
  ^-  [data file]
  =/  child-key=[@tas @tas]  constrained-table.constraint
  =/  child-table=table      (~(got by tbls) child-key)
  =/  child-file=file  ?:  =(child-key parent-key)
                         parent-file
                       ?:  (~(has by files.cur-data) child-key)
                         (~(got by files.cur-data) child-key)
                       (get-content content effective-time child-key)
  ?:  =(rowcount.child-file 0)
    [cur-data parent-file]
  =.  files.cur-data
        ?:  =(child-key parent-key)
          files.cur-data
        (~(put by files.cur-data) parent-key parent-file)
  =/  child-fks=(list outbound-fk-entry)
        (collect-outbound-fks outbound-fk-index.child-table)
  =/  cleared=[data file]
        %:  clear-outbound-constrained-values  content
                                               effective-time
                                               child-key
                                               child-file
                                               child-fks
                                               cur-data
                                               now
                                               ==
  =.  cur-data    -.cleared
  =.  child-file  +.cleared
  =.  parent-file
        ?:  =(child-key parent-key)
          child-file
        (~(got by files.cur-data) parent-key)
  =.  pri-idx.child-file       ~
  =.  indexed-rows.child-file  ~
  =.  rowcount.child-file      0
  =.  tmsp.child-file          now
  ?:  =(child-key parent-key)
    [cur-data child-file]
  =.  files.cur-data  (~(put by files.cur-data) child-key child-file)
  [cur-data parent-file]
::
++  apply-delete-cascades
  |=  $:  tbls=tables
          content=((mop @da data) gth)
          effective-time=@da
          now=@da
          parent-key=[@tas @tas]
          parent-file=file
          constraints=(list foreign-constraint)
          deleted-rows=(list indexed-row)
          cur-data=data
          ==
  ^-  [data file]
  ?~  deleted-rows  [cur-data parent-file]
  |-
  ?~  constraints  [cur-data parent-file]
  ?.  =(on-delete.actions.i.constraints %cascade)
    $(constraints t.constraints)
  =/  cascaded=[data file]
        %:  apply-delete-cascade-constraint  tbls
                                             content
                                             effective-time
                                             now
                                             parent-key
                                             parent-file
                                             i.constraints
                                             deleted-rows
                                             cur-data
                                             ==
  %=  $
    constraints  t.constraints
    cur-data     -.cascaded
    parent-file  +.cascaded
  ==
::
++  apply-delete-cascade-constraint
  |=  $:  tbls=tables
          content=((mop @da data) gth)
          effective-time=@da
          now=@da
          parent-key=[@tas @tas]
          parent-file=file
          constraint=foreign-constraint
          deleted-rows=(list indexed-row)
          cur-data=data
          ==
  ^-  [data file]
  =/  child-key=[@tas @tas]  constrained-table.constraint
  =/  child-table=table      (~(got by tbls) child-key)
  =/  child-file=file
        ?:  =(child-key parent-key)
          parent-file
        ?:  (~(has by files.cur-data) child-key)
          (~(got by files.cur-data) child-key)
        (get-content content effective-time child-key)
  =/  matching-rows=(list indexed-row)
        %+  skim  indexed-rows.child-file
                  |=  a=indexed-row
                  %:  child-row-matches-deleted
                        a
                        constrained-columns.constraint
                        deleted-rows
                        ==
  =/  kept-rows=(list indexed-row)
        %+  skim  indexed-rows.child-file
                  |=  a=indexed-row
                  =/  matches=?
                        %:  child-row-matches-deleted
                            a
                            constrained-columns.constraint
                            deleted-rows
                            ==
                  !matches
  ?:  =((lent kept-rows) rowcount.child-file)
    [cur-data parent-file]
  =.  files.cur-data
        ?:  =(child-key parent-key)
          files.cur-data
        (~(put by files.cur-data) parent-key parent-file)
  =/  child-key-cols=(list @tas)
        %+  turn  key.pri-indx.child-table
        |=(col=key-column name.col)
  =/  child-fks=(list outbound-fk-entry)
        (collect-outbound-fks outbound-fk-index.child-table)
  =/  constrained=[data file]
        %:  apply-delete-constrained-values  content
                                             effective-time
                                             child-key
                                             child-key-cols
                                             child-file
                                             matching-rows
                                             child-fks
                                             cur-data
                                             now
                                             ==
  =.  cur-data    -.constrained
  =.  child-file  +.constrained
  =.  parent-file
        ?:  =(child-key parent-key)
          child-file
        (~(got by files.cur-data) parent-key)
  =.  indexed-rows.child-file  kept-rows
  =.  rowcount.child-file      (lent kept-rows)
  =.  tmsp.child-file          now
  =.  child-file               (rebuild-primary-index child-table child-file)
  ?:  =(child-key parent-key)
    [cur-data child-file]
  =.  files.cur-data  (~(put by files.cur-data) child-key child-file)
  [cur-data parent-file]
::
++  apply-delete-set-defaults
  |=  $:  op=tape
          tbls=tables
          content=((mop @da data) gth)
          effective-time=@da
          now=@da
          parent-key=[@tas @tas]
          parent-file=file
          constraints=(list foreign-constraint)
          deleted-rows=(list indexed-row)
          cur-data=data
          ==
  ^-  [data file]
  ?~  deleted-rows  [cur-data parent-file]
  |-
  ?~  constraints  [cur-data parent-file]
  ?.  =(on-delete.actions.i.constraints %set-default)
    $(constraints t.constraints)
  =/  defaulted=[data file]
        %:  apply-delete-set-default-constraint  op
                                                 tbls
                                                 content
                                                 effective-time
                                                 now
                                                 parent-key
                                                 parent-file
                                                 i.constraints
                                                 deleted-rows
                                                 cur-data
                                                 ==
  %=  $
    constraints  t.constraints
    cur-data     -.defaulted
    parent-file  +.defaulted
  ==
::
++  apply-delete-set-default-constraint
  |=  $:  op=tape
          tbls=tables
          content=((mop @da data) gth)
          effective-time=@da
          now=@da
          parent-key=[@tas @tas]
          parent-file=file
          constraint=foreign-constraint
          deleted-rows=(list indexed-row)
          cur-data=data
          ==
  ^-  [data file]
  =/  child-key=[@tas @tas]  constrained-table.constraint
  =/  child-table=table      (~(got by tbls) child-key)
  =/  child-file=file
        ?:  =(child-key parent-key)
          parent-file
        ?:  (~(has by files.cur-data) child-key)
          (~(got by files.cur-data) child-key)
        (get-content content effective-time child-key)
  =/  matching-rows=(list indexed-row)
        %+  skim  indexed-rows.child-file
                  |=  a=indexed-row
                  %:  child-row-matches-deleted
                        a
                        constrained-columns.constraint
                        deleted-rows
                        ==
  ?~  matching-rows  [cur-data parent-file]
  =/  updates=(list [@tas @])
        (default-updates constrained-columns.constraint columns.child-table)
  =/  default-key=(list @)  (turn updates |=(u=[@tas @] +.u))
  =/  parent-table=table  (~(got by tbls) parent-key)
  =/  dummy
        %:  assert-delete-set-default-parent  op
                                              parent-table
                                              parent-file
                                              default-key
                                              deleted-rows
                                              ==
  =/  old-child-rows=(list indexed-row)  indexed-rows.child-file
  =.  indexed-rows.child-file
        %+  turn  indexed-rows.child-file
        |=  row=indexed-row
        =/  matches=?
              %:  child-row-matches-deleted  row
                                             constrained-columns.constraint
                                             deleted-rows
                                             ==
        ?:  matches
          (update-key row updates key.pri-indx.child-table columns.child-table)
        row
  =/  changed-pairs=(list [old=indexed-row new=indexed-row])
        (changed-row-pairs old-child-rows indexed-rows.child-file)
  =.  files.cur-data
        ?:  =(child-key parent-key)
          files.cur-data
        (~(put by files.cur-data) parent-key parent-file)
  =/  child-key-cols=(list @tas)
        %+  turn  key.pri-indx.child-table
        |=(col=key-column name.col)
  =/  child-fks=(list outbound-fk-entry)
        (collect-outbound-fks outbound-fk-index.child-table)
  =/  constrained=[data file]
        %:  apply-update-constrained-values
              content
              effective-time
              child-key
              child-key-cols
              child-file
              changed-pairs
              child-fks
              cur-data
              now
              ==
  =.  cur-data    -.constrained
  =.  child-file  +.constrained
  =.  parent-file
        ?:  =(child-key parent-key)
          child-file
        (~(got by files.cur-data) parent-key)
  =.  tmsp.child-file  now
  =.  child-file       (rebuild-primary-index child-table child-file)
  ?:  =(child-key parent-key)
    [cur-data child-file]
  =.  files.cur-data  (~(put by files.cur-data) child-key child-file)
  [cur-data parent-file]
::
++  default-updates
  |=  [source-cols=(list @tas) cols=(list column:ast)]
  ^-  (list [@tas @])
  =/  cmap=(map @tas column:ast)  (malt (turn cols |=(c=column:ast [name.c c])))
  =/  updates=(list [@tas @])  ~
  |-
  ?~  source-cols  (flop updates)
  =/  col=column:ast  (~(got by cmap) i.source-cols)
  %=  $
    source-cols  t.source-cols
    updates      [[i.source-cols (default-column-value col)] updates]
  ==
::
++  default-column-value
  |=  col=column:ast
  ^-  @
  ?:  =(%da type.col)  *@da
  0
::
++  assert-delete-set-default-parent
  |=  $:  op=tape
          parent-table=table
          parent-file=file
          default-key=(list @)
          deleted-rows=(list indexed-row)
          ==
  ^-  ~
  =/  parent-primary-key  (pri-key key.pri-indx.parent-table)
  ?.  (has:parent-primary-key pri-idx.parent-file default-key)
    ~|  %+  weld  op  ": FOREIGN KEY SET DEFAULT parent bunt key not found"
        !!
  ?:  (deleted-row-key-exists deleted-rows default-key)
    ~|  %+  weld  op  ": FOREIGN KEY SET DEFAULT parent bunt key not found"
        !!
  ~
::
++  deleted-row-key-exists
  |=  [deleted-rows=(list indexed-row) row-key=(list @)]
  ^-  ?
  ?~  deleted-rows  %.n
  ?:  =(key.i.deleted-rows row-key)  %.y
  $(deleted-rows t.deleted-rows)
::
++  child-row-matches-deleted
  |=  $:  child-row=indexed-row
          source-cols=(list @tas)
          deleted-rows=(list indexed-row)
          ==
  ^-  ?
  =/  child-fk-key=(list @)  (fk-row-values data.child-row source-cols)
  |-
  ?~  deleted-rows  %.n
  ?:  =(child-fk-key key.i.deleted-rows)
    %.y
  $(deleted-rows t.deleted-rows)
::
++  rebuild-primary-index
  |=  [tbl=table f=file]
  ^-  file
  =/  primary-key  (pri-key key.pri-indx.tbl)
  =/  comparator
        ~(order idx-comp `(list [@ta ?])`(reduce-key key.pri-indx.tbl))
  =.  pri-idx.f
      %+  gas:primary-key  *((mop (list @) (map @tas @)) comparator)
                           (turn indexed-rows.f |=(a=indexed-row +.a))
  f
::
++  row-cells
  ::  Create the saved row-wise file data.
  |=  [op=?(%insert %upsert) p=(list value-or-default:ast) q=(list column:ast)]
  ^-  (map @tas @)
  =/  cells  *(list [@tas @])
  |-
  ?~  p  (malt cells)
  %=  $
    cells  [(row-cell op -.p -.q) cells]
    p  +.p
    q  +.q
  ==
::
++  row-cells-and-keys
  ::  Build row map incrementally, no intermediate list or key-map.
  |=  [op=?(%insert %upsert) p=(list value-or-default:ast) q=(list column:ast)]
  ^-  (map @tas @)
  =/  cells  *(map @tas @)
  |-
  ?~  p  cells
  =/  cell=[@tas @]  (row-cell op -.p -.q)
  %=  $
    cells  (~(put by cells) -.cell +.cell)
    p  +.p
    q  +.q
  ==
::
++  row-cell
  |=  [op=?(%insert %upsert) p=value-or-default:ast q=column:ast]
  ^-  [@tas @]
  ?:  ?=(dime p)
    ?:  =(p.p type.q)  [name.q q.p]
    ?:  =(%insert op)
      ~|  "INSERT: type of column {<-.q>} {<+<.q>} ".
          "does not match input value type {<p.p>}"
          !!
    ~|  "UPSERT: type of column {<-.q>} {<+<.q>} ".
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
      (ctes-have-rand ctes)
  ==
::
++  ctes-have-rand
  |=  ctes=(list cte:ast)
  ^-  ?
  %+  lien  ctes
  |=  c=cte:ast
  ?-  -.body.c
    %query      (query-has-rand +.body.c)
    %set-query  (set-query-has-rand +.body.c)
  ==
::
++  set-query-has-rand
  |=  sq=set-query:ast
  ^-  ?
  ?|  (query-has-rand head.sq)
      %+  lien  tail.sq
      |=  item=[op=set-op:ast =query:ast]
      (query-has-rand query.item)
  ==
::
++  query-has-rand
  |=  q=query:ast
  ^-  ?
  (scalars-have-rand scalars.q)
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
      ?~  pattern.sn  ~[string-expression.sn]
      ~[string-expression.sn u.pattern.sn]
    %rtrim
      ?~  pattern.sn  ~[string-expression.sn]
      ~[string-expression.sn u.pattern.sn]
    %trim
      ?~  pattern.sn  ~[string-expression.sn]
      ~[string-expression.sn u.pattern.sn]
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
