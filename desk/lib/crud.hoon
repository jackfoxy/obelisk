/-  ast, *obelisk, *server-state
/+  *utils, *joins, *predicate
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
::  +truncate-tbl:
::    [truncate-table:ast (map @tas @da) (map @tas @da)] -> table-return
::
::  Unlike the other data manipulation functions (INSERT, DELETE, UPDATE),
::  TRUNCATE TABLE can future date its action. This however effectively locks
::  the database for data updates until that time.
++  truncate-tbl
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
                            (trip (qualified-object-to-cord table.d))
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
  =.  column-addrs.file    ~
  =.  column-catalog.file  ~
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
                          (trip (qualified-object-to-cord table.d))
              [%server-time now.bowl]
              [%data-time sys-time]
              [%vector-count dropped-rows]
              ==
      next-schemas
      (~(put by next-data) database.table.d sys-time)
      (~(put by state) name.db db)
::
::  +do-selection:
::    [selection:ast ? (map @tas @da) (map @tas @da)]
::    -> [? [(map @tas @da) server (list result)]]
++  do-selection
  |=  $:  =selection:ast
          query-has-run=?
          next-data=(map @tas @da)
          next-schemas=(map @tas @da)
      ==
  ^-  [? [(map @tas @da) server (list result)]]
  =/  tree=(tree set-function:ast)              set-functions.selection
  =/  ctes=(map @tas [@ud (list indexed-row)])  (named-queries ctes.selection)
  =/  rtree  (~(rdc of tree) rdc-set-func)
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
          =/  foo  (do-query -.rtree next-data next-schemas)
          [next-data -.foo (select-results foo)]
    %merge
      ?:  query-has-run  ~|("MERGE: state change after query in script" !!)
      !!
    ==
::
::  +do-insert:  [insert:ast (map @tas @da) (map @tas @da)]
::               -> [(map @tas @da) server (list result)]
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
  =/  rev-cols  (flop columns.table.txn)
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
                            (trip (qualified-object-to-cord table.ins))
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
  =/  file-row  (row-cells row cols rev-cols)
  =/  row-key=(list @)
        %+  turn
            key-pick
            |=(a=[p=@tas q=@ud] (key-atom [p.a -.file-row]))
  =.  pri-idx.file.txn  ?:  (has:primary-key pri-idx.file.txn row-key)
                          ~|("INSERT: cannot add duplicate key: {<row-key>}" !!)
                        (put:primary-key pri-idx.file.txn row-key file-row)
  $(i +(i), value-table `(list (list value-or-default:ast))`+.value-table)
::
::  +do-delete:
::    [delete:ast (map @tas @da) (map @tas @da)] -> table-return
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
  =/  type-lookup=lookup-type
        %+  ~(put by `lookup-type`~)  
          table.d
          (malt (turn columns.table.txn |=(a=column:ast [name.a type.a])))
  =/  qualifier-lookup
        %-  ~(gas by `(map @tas (list qualified-object:ast))`~)
            (turn columns.table.txn |=(a=column:ast [name.a (limo ~[table.d])]))
  =/  filter=$-(joined-row ?)  %^  pred-ops-and-conjs
                                      %+  pred-qualify-unqualified
                                          predicate.d
                                          qualifier-lookup
                                      type-lookup
                                      qualifier-lookup
  =/  init-map  *(map qualified-object:ast [(map @tas @) (list @)])
  =.  indexed-rows.file.txn
        %+  skim
              indexed-rows.file.txn
              |=(a=indexed-row !(filter [-.a (~(put by init-map) table.d +.a)]))
  :: 
  =/  primary-key  (pri-key key.pri-indx.table.txn)
  =/  comparator
        ~(order idx-comp `(list [@ta ?])`(reduce-key key.pri-indx.table.txn))
  =.  pri-idx.file.txn
      %+  gas:primary-key  *((mop (list @) ,[(map @tas @) (list @)]) comparator)
                           indexed-rows.file.txn
  ::
  =/  rpq=[@ud column-addrs column-catalog]  (update-cat indexed-rows.file.txn)
  =.  column-addrs.file.txn    +<.rpq
  =.  column-catalog.file.txn  +>.rpq
  ::
  =/  deleted-rows  (sub rowcount.file.txn -.rpq)
  ?:  =(deleted-rows 0)
    :+  next-data
        state
        :~  :-  %message
                %-  crip
                    %+  weld  "DELETE FROM "
                              (trip (qualified-object-to-cord table.d))
            [%server-time now.bowl]
            [%schema-time tmsp.table.txn]
            [%data-time tmsp.file.txn]
            [%message 'no rows deleted']
            ==
  =.  rowcount.file.txn        -.rpq
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
                            (trip (qualified-object-to-cord table.d))
          [%server-time now.bowl]
          [%schema-time tmsp.table.txn]
          [%data-time source-content-time.txn]
          [%message 'deleted:']
          [%vector-count deleted-rows]
          [%message msg='table data:']
          [%vector-count rowcount.file.txn]
          ==
::
::  +do-update:
::    [update:ast (map @tas @da) (map @tas @da)] -> table-return
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
  =/  type-lookup=lookup-type
        %+  ~(put by `lookup-type`~)  
          table.u
          (malt (turn columns.table.txn |=(a=column:ast [name.a type.a])))
  =/  qualifier-lookup
        %-  ~(gas by `(map @tas (list qualified-object:ast))`~)
            (turn columns.table.txn |=(a=column:ast [name.a (limo ~[table.u])]))
  =/  filter=(unit $-(joined-row ?))
        ?~  predicate.u  ~
        :-  ~
            %^  pred-ops-and-conjs  %+  pred-qualify-unqualified
                                          (need predicate.u)
                                          qualifier-lookup
                                    type-lookup
                                    qualifier-lookup
  =/  updates=(list [@tas @])  %:  mk-updates  table.u
                                               columns.u
                                               values.u
                                               type-lookup
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
            [filter table.u updates key.pri-indx.table.txn columns.table.txn]
          [filter table.u updates ~ columns.table.txn]
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
                              (trip (qualified-object-to-cord table.u))
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
      %+  gas:primary-key  *((mop (list @) ,[(map @tas @) (list @)]) comparator)
                            -.rows-count
  ::
  =/  idx  ~(wyt by pri-idx.file.txn)
  =/  fil  (lent indexed-rows.file.txn)
  ?.  =(idx fil)
    ~|("{<(sub fil idx)>} duplicate row key(s)" !!)
  ::
  =/  new-indexed-rows  (tap:primary-key pri-idx.file.txn)
  =/  rpq=[@ud column-addrs column-catalog]  (update-cat new-indexed-rows)
  =.  column-addrs.file.txn    +<.rpq
  =.  column-catalog.file.txn  +>.rpq
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
                            (trip (qualified-object-to-cord table.u))
          [%server-time now.bowl]
          [%schema-time tmsp.table.txn]
          [%data-time source-content-time.txn]
          [%message 'updated:']
          [%vector-count +.rows-count]
          [%message msg='table data:']
          [%vector-count rowcount.file.txn]
          ==
::
::  +do-query:  [query:ast (map @tas @da) (map @tas @da)]
::              -> [server (list result)]
::
::  state may be updated by insertion into view-cache, which does not effect
::  any other part of the state
++  do-query
  |=  [q=query:ast next-data=(map @tas @da) next-schemas=(map @tas @da)]
  ^-  [server (list set-table) (list vector)]
  :: no from clause, it's a single row of literals
  ?~  from.q  [state (select-literals columns.selection.q)]
  
  :: no joins, it's a single table

  =/  f  (need from.q)

  ::?~  joins:(need from.q)  (select-table(state state, bowl bowl) q)
  ?~  joins.f  (select-table(state state, bowl bowl) q)

  ::
  =/  =join-return  (join-all(state state, bowl bowl) q)
  =/  set-tables  set-tables.join-return
  ?~  set-tables  ~|("can't get here" !!)
  =/  selected  columns.selection.q
  =/  qualifier-lookup  (mk-qualifier-lookup set-tables selected)
  =.  selected  (qualify-unqualified columns.selection.q qualifier-lookup)
  =/  filter=(unit $-(joined-row ?))
    ?~  predicate.q  ~
    :-  ~
        %^  pred-ops-and-conjs
              %+  pred-qualify-unqualified
                    (need predicate.q)
                    qualifier-lookup
              type-lookup.join-return
              qualifier-lookup
  :+  server.join-return
      set-tables
      %:  joined-result  filter
                        qualified-columns.join-return
                        joined-rows.i.set-tables
                        selected
                        ==
::
++  joined-result
  |=  $:  filter=(unit $-(joined-row ?))
          qualified-columns=(list qual-col-type)
          rows=(list joined-row)
          selected=(list selected-column:ast)
          ==
  ^-  (list vector)
  ?:  =((lent rows) 0)  ~
  =/  out-rows   *(set vector)
  =/  col-lookup
    %-  ~(gas by `(map [qualified-object:ast @tas] @ta)`~)
        %+  turn
              qualified-columns
              |=(a=qual-col-type [[qualifier:-.a column:-.a] +.a])
  =/  cells=(list templ-cell)
    %^  mk-vect-templ
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
  =/  qualifier=qualified-object:ast  qualifier:(need object.cell)
  =/  value
    %-  ~(got by -:(~(got by +.i.rows) qualifier))
        column:(need object.cell)
  =/  cell-type
    %-  ~(got by col-lookup)
        [qualifier column:(need object.cell)]
  $(cols t.cols, row [[p.vc.cell [cell-type value]] row])
::
::  +select-results:  [server (list set-table) (list vector)] -> (list result)
++  select-results
  |=  [state=server set-tables=(list set-table) result-set=(list vector)]
  ^-  (list result)
  =/  out  *(list (list result))
  =/  raw  %+  sort  %~  tap  in
                              %^  fold  set-tables
                                        *(set [qualified-object:ast @da @da])
                                        pick-from-object
                     order-results
  ?~  set-tables  ~|("can't get here" !!)
  |-
  ?~  raw  ?~  out
             :~  [%message 'SELECT']
                 :-  %result-set
                     ?~  indexed-rows.i.set-tables  ~
                     :~  %+  mk-vect
                             columns.i.set-tables
                             ->-.indexed-rows.i.set-tables
                         ==
                 [%server-time now.bowl]
                 [%schema-time created-tmsp:(~(got by state) %sys)]
                 [%data-time created-tmsp:(~(got by state) %sys)]
                 [%vector-count (lent indexed-rows.i.set-tables)]
                 ==
    %-  zing  :~  :~  [%message 'SELECT']
                      [%result-set result-set]
                      [%server-time now.bowl]
                      ==
                  `(list result)`(zing out)
                  :~  [%vector-count (lent result-set)]
                      ==
                  ==
  %=  $
    raw  t.raw
    out  :-  :~  [%message (qualified-object-to-cord -.i.raw)]
                 [%schema-time +<.i.raw]
                 [%data-time +>.i.raw]
                 ==
             out
  ==
::
::  +order-results
++  order-results
  |=  $:  p=[=qualified-object:ast schema-tmsp=@da data-tmsp=@da]
          q=[=qualified-object:ast schema-tmsp=@da data-tmsp=@da]
          ==
  ?:  ?!  %+  aor  (biff ship.qualified-object.p same)
                   (biff ship.qualified-object.q same)                 %.y
  ?:  ?&  .=  (biff ship.qualified-object.p same)
              (biff ship.qualified-object.q same)
              ?!  %+  aor  database.qualified-object.p
                           database.qualified-object.q
          ==                                                           %.y
  ?:  ?&  .=  (biff ship.qualified-object.p same)
              (biff ship.qualified-object.q same)
          =(database.qualified-object.p database.qualified-object.q)
          !(aor namespace.qualified-object.p namespace.qualified-object.q)
          ==                                                           %.y
  ?:  ?&  .=  (biff ship.qualified-object.p same) 
              (biff ship.qualified-object.q same)
          =(database.qualified-object.p database.qualified-object.q)
          =(namespace.qualified-object.p namespace.qualified-object.q)
          !(aor name.qualified-object.p name.qualified-object.q)
          ==                                                           %.y
  ?:  (gth schema-tmsp.p schema-tmsp.q)                                %.y
  ?:  &(=(schema-tmsp.p schema-tmsp.q) (gth data-tmsp.p data-tmsp.q))  %.y
  %.n
::
++  pick-from-object
  |=  [a=set-table state=(set [qualified-object:ast @da @da])]
  ^-  (set [qualified-object:ast @da @da])
  ?~  object.a    state
  %-  ~(put in state)  :+  (need object.a)
                           (need schema-tmsp.a)
                           (need data-tmsp.a)
::
::  +select-literals:  (list selected-column:ast) -> (list vector)
::
::  selection of literals only, no from clause
++  select-literals
  |=  columns=(list selected-column:ast)
  ^-  [(list set-table) (list vector)]
  =/  sys-db  ~|  "At least 1 user database must exist before 'sys' database ".
                  "can be accessed"
                  (~(got by state) %sys)
  =/  indexed-cols  *[(map @tas @) (list @)]
  =/  columns-out   *(list column:ast)
  =/  i             0
  |-
  ?~  columns
    :-  :~  :*  %set-table
                ~
                [~ created-tmsp.sys-db]
                [~ created-tmsp.sys-db]
                columns-out
                ~
                ~
                ~
                1
                *(list key-column)
                *(tree indexed-row)
                ~[[~ indexed-cols]]
                *(list joined-row)
                ==
            ==
        :~  %+  mk-vect
                columns-out
                -.indexed-cols
            ==
  ?.  ?=(selected-value:ast -.columns)
    ~|("selected value {<-.columns>} not a literal" !!)
  =/  column-name  ?~  alias.i.columns  (crip "literal-{<i>}")
                                        (need alias.i.columns)
  %=  $
    i             +(i)
    columns       +.columns
    columns-out   :-  (column:ast %column column-name p.value.i.columns)
                      columns-out
    indexed-cols  [(~(put by -.indexed-cols) column-name q.value.i.columns) ~]
  ==
::
++  mk-vect
  |=  [columns=(list column:ast) values=(map @tas @)]
  ^-  vector
  =/  vector-cells  *(list vector-cell)
  |-
  ?~  columns  ?~  vector-cells  ~|("can't get here" !!)
               [%vector `(lest vector-cell)`vector-cells]
  %=  $
    columns       t.columns
    vector-cells  :-  :-  name.i.columns
                          [type.i.columns (~(got by values) name.i.columns)]
                      vector-cells
  ==
::
++  plan-upd
  |=  $:  r=indexed-row
          count=@ud
          f=(unit $-(joined-row ?))
          obj=qualified-object:ast
          updates=(list [@tas @])
          key-columns=(list key-column)
          cols=(list column:ast)
          ==
  ^-  [indexed-row @ud]
  ?~  f
    ?~  key-columns  [[-.r (produce-update r updates cols)] +(count)]
    [(update-key r updates key-columns cols) +(count)]

  ?.  ((need f) [-.r [[obj +.r] ~ ~]])  [r count]
  ?~  key-columns  [[-.r (produce-update r updates cols)] +(count)]
  [(update-key r updates key-columns cols) +(count)]
++  update-key
  |=  $:  r=indexed-row
          updates=(list [@tas @])
          key-columns=(list key-column)
          cols=(list column:ast)
          ==
  ^-  indexed-row
  =/  new-key=(list @)  ~
  =/  upd-row  (produce-update r updates cols)
  |-
  ?~  key-columns  [(flop new-key) upd-row]
  %=  $
    new-key      [(~(got by -.upd-row) name.i.key-columns) new-key]
    key-columns  t.key-columns
  ==
++  produce-update
  |=  [r=indexed-row updates=(list [@tas @]) cols=(list column:ast)]
  ^-  [(map @tas @) (list @)]
  =/  x  +.r
  |-
  ?~  updates  x
  =/  mapped  (~(put by -.x) -.i.updates +.i.updates)
  %=  $
    x        (row-wise-data mapped cols)
    updates  +.updates
  ==
++  mk-updates
  |=  $:  table=qualified-object:ast
          columns=(list qualified-column:ast)
          values=(list *)   ::(list value-or-default:ast)
          type-lookup=lookup-type
          ==
  ^-  (list [@tas @])
  =/  updates=(list [@tas @])  ~
  |-
  ?~  columns  updates
  ?~  values  !!   :: can't get here
  ?:  ?=(%default i.values)
    %=  $
      columns   t.columns
      values    t.values
      updates   ?:  .=  ~.da
                        %-  ~(got by (~(got by type-lookup) table))
                            column.i.columns
                  [[column.i.columns *@da] updates]
                [[column.i.columns 0] updates]
    ==
  ?:  ?=(dime i.values)
    %=  $
      columns   t.columns
      values    t.values
      updates
        ?.  =(table qualifier.i.columns)
          ~|  "UPDATE: {<table>} not matched by column qualifier ".
              "{<qualifier.i.columns>}"
              !!
        ~|  "value type: {<-.i.values>} does not match column: {<i.columns>}"
            ?.  .=  p.i.values
                    (~(got by (~(got by type-lookup) table)) column.i.columns)
              !!
            [[column.i.columns +.i.values] updates]
    ==
  ~|("value type not supported: {<i.values>}" !!)
::
::  +named-queries:  (list cte:ast) -> (map @tas [@ud (list indexed-row)])
::  resolve CTEs
++  named-queries  ::To Do: resolve data tmsps in CTEs
  |=  ctes=(list cte:ast)
  ^-  (map @tas [@ud (list indexed-row)])
  =/  cte-rows  *(map @tas [@ud (list indexed-row)])
  |-
  ?~  ctes  cte-rows
  %=  $
    cte-rows  (~(put by cte-rows) +<.i.ctes (named-query +>.i.ctes))
    ctes  +.ctes
  ==
::
::  +named-query:  (list query:ast) -> [@ud (list indexed-row)]
::  resolve CTEs
++  named-query
  |=  q=query:ast
  ^-  [@ud (list indexed-row)]
  =/  i  0
  =/  vals  *(list vector-cell)
  =/  columns=(list selected-column:ast)  columns.selection.q
  |-
  ?~  columns
    ?~  vals  ~|("can't get here" !!)
    =/  xx=(list vector-cell)  vals
    =/  yy  %^  spin
                xx
                *(map @tas @)
                |=([a=vector-cell s=(map @tas @)] [a (~(put by s) p.a q.q.a)])
    [1 ~[[*(list @) [+.yy *(list @)]]]]
  ?.  ?=(selected-value:ast -.columns)
    ~|("selected value {<-.columns>} not a literal" !!)
  =/  column=selected-value:ast  -.columns
  %=  $
    i        +(i)
    columns  +.columns
    vals
      [(vector-cell (heading column (crip "literal-{<i>}")) value.column) vals]
  ==
--
