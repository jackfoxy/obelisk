/-  ast, *obelisk
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
  =/  ctes=(list cte:ast)  ctes.selection  :: To Do - map CTEs
  %:  do-set-functions  set-functions.selection
                        query-has-run
                        next-data
                        next-schemas
                        ==
::
::  +do-set-functions:
:: [(tree set-function:ast) ? (map @tas @da) (map @tas @da)]
:: -> [? [(map @tas @da) server (list result)]]
++  do-set-functions
  |=  $:  =(tree set-function:ast)
          query-has-run=?
          next-data=(map @tas @da)
          next-schemas=(map @tas @da)
      ==
  ^-  [? [(map @tas @da) server (list result)]]
  =/  rtree  (~(rdc of tree) rdc-set-func)
  ?-  -<.rtree
    %delete
      ?:  query-has-run  ~|("DELETE: state change after query in script" !!)
      :-  %.n
          (do-delete -.rtree next-data next-schemas)
    %insert
      ?:  query-has-run  ~|("INSERT: state change after query in script" !!)
      :-  %.n
          ::~&  "{<->->+>+.rtree>}"   :: table name
          ::~>  %bout.[0 %insert]
          (do-insert -.rtree next-data next-schemas)
    %update
      ?:  query-has-run  ~|("UPDATE: state change after query in script" !!)
      :-  %.n
          (do-update -.rtree next-data next-schemas)
    %query
      :-  %.y
          ::~&  "{<->->+.rtree>}"   :: from objects
          ::~>  %bout.[0 %select]
          [next-data (do-query -.rtree next-data next-schemas)]
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
  =/  file-row=(map @tas @)  (row-cells row cols)
  =/  row-key=(list @)
        %+  turn
            key-pick
            |=(a=[p=@tas q=@ud] (key-atom [p.a file-row]))
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
  =/  init-map=(map qualified-object:ast (map @tas @))  ~
  =.  indexed-rows.file.txn
        %+  skim
              indexed-rows.file.txn
              |=(a=indexed-row !(filter [-.a (~(put by init-map) table.d +.a)]))
  :: 
  =/  primary-key  (pri-key key.pri-indx.table.txn)
  =/  comparator
        ~(order idx-comp `(list [@ta ?])`(reduce-key key.pri-indx.table.txn))
  =.  pri-idx.file.txn
        %+  gas:primary-key  *((mop (list @) (map @tas @)) comparator)
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
            [filter table.u updates key.pri-indx.table.txn]
          [filter table.u updates ~]
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

  =/  primary-key  (pri-key key.pri-indx.table.txn)
  =/  comparator
        ~(order idx-comp `(list [@ta ?])`(reduce-key key.pri-indx.table.txn))
  =.  pri-idx.file.txn
        %+  gas:primary-key  *((mop (list @) (map @tas @)) comparator)
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
::  +do-query:  [query:ast (map @tas @da) (map @tas @da)]
::              -> [server (list result)]
::
::  state may be updated by insertion into view-cache, which does not effect
::  any other part of the state
++  do-query
  |=  [q=query:ast next-data=(map @tas @da) next-schemas=(map @tas @da)]
  ^-  [server (list result)]
  =/  sys-db  ~|  "At least 1 user database must exist before 'sys' database ".
                  "can be accessed"
                  (~(got by state) %sys)
  ?~  from.q
       :-  state    :: no from? only literals
           :~  [%message 'SELECT']
               [%result-set (select-literals columns.selection.q)]
               [%server-time now.bowl]
               [%schema-time created-tmsp.sys-db]
               [%data-time created-tmsp:(~(got by state) %sys)]
               (result %vector-count 1)
               ==
  =/  =join-return        (join-all(state state, bowl bowl) q)
  =/  output=[@ud (list vector)]  %:  vector-data  join-data.join-return
                                                   q
                                                   data-objs.join-return
                                                   type-lookup.join-return
                                                   qualified-columns.join-return
                                                   ==
  ::
  :-  server.join-return  :: state
      %-  zing  :~  :~  [%message 'SELECT']
                        [%result-set +.output]
                        [%server-time now.bowl]
                        ==
                        (from-obj-meta data-objs.join-return)
                    :~  [%vector-count -.output]
                        ==
                    ==
::
::  +vector-data:  [(list from-obj) query:ast] -> [@ud (list vector)]
++  vector-data
  |=  $:  all-data=joined
          q=query:ast
          sources=(list from-obj)
          type-lookup=lookup-type
          qualified-columns=(list qual-col-type)
          ==
  ^-  [@ud (list vector)]
  =/  selected  columns.selection.q
  =/  qualifier-lookup  (mk-qualifier-lookup sources selected)
  =.  selected  (qualify-unqualified selected qualifier-lookup)
  =/  vectors
      ?~  joined-rows.all-data  ~
      ?~  predicate.q
          %+  select-columns  joined-rows.all-data
                              %^  mk-vect-templ  qualified-columns
                                                 selected
                                                 -.joined-rows.all-data
      %^  select-columns-filtered  joined-rows.all-data
                                   %^  mk-vect-templ
                                         qualified-columns
                                         selected
                                         -.joined-rows.all-data
                                   %^  pred-ops-and-conjs
                                         %+  pred-qualify-unqualified
                                              (need predicate.q)
                                              qualifier-lookup
                                         type-lookup
                                         qualifier-lookup
  ::
  [(lent vectors) vectors]
::
::  +select-columns:
::    [(list joined-row) (unit @t) (list templ-cell)]
::    -> (list vector)
::
::  select columns from join
++   select-columns
  |=  $:  rows=(list joined-row)
          cells=(list templ-cell)
          ==
  ~+  ^-  (list vector)
  =/  out-rows=(list vector)  ~
  |-
  ?~  rows  ~(tap in (silt out-rows))
  ::
  =/  row=(list vector-cell)  ~
  =/  cols=(list templ-cell)  cells
  |-
  ?~  cols
      %=  ^$
        out-rows  [(vector %vector row) out-rows]
        rows      t.rows
      ==
  ::
  ?~  object.i.cols                         :: case: is literal
    $(cols t.cols, row [vc.i.cols row])
  =/  cell=templ-cell  i.cols            :: case: is table column
  =/  qualifier=qualified-object:ast  qualifier:(need object.cell)
  %=  $
    cols  t.cols
    row   :-
            :-  p.vc.cell
              :-  p.q.vc.cell
                  ;;(@ +:.*((~(got by +.i.rows) qualifier) [0 addr.cell]))
            row
  ==
::
::  +select-columns-filtered:
::    $:  (list joined-row)
::        (list templ-cell)
::        $-((map @tas @) ?)
::        -> (list vector)
::
::  select columns from join
::  rejects rows that do not pass filter
++   select-columns-filtered
  |=  $:  rows=(list joined-row)
          cells=(list templ-cell)
          filter=$-(joined-row ?)
          ==
  ~+  ^-  (list vector)  
  =/  out-rows=(list vector)  ~
  |-
  ?~  rows  ~(tap in (silt out-rows))
  ::
  ?.  (filter i.rows)  $(rows t.rows)
  ::
  =/  row=(list vector-cell)  ~
  =/  cols=(list templ-cell)  cells
  |-
  ?~  cols
      %=  ^$
        out-rows  [(vector %vector row) out-rows]
        rows      t.rows
      ==
  ::
  ?~  object.i.cols                   :: case: is literal
    $(cols t.cols, row [vc.i.cols row])
  =/  cell=templ-cell  i.cols              :: case: is table column
  =/  qualifier=qualified-object:ast  qualifier:(need object.cell)
  %=  $
    cols  t.cols
    row   :-
            :-  p.vc.cell
              :-  p.q.vc.cell
                  %-  ~(got by (~(got by +.i.rows) qualifier))
                      column:(need object.cell)
            row
  ==
::
::  +select-literals:  (list selected-column:ast) -> (list vector)
++  select-literals
  |=  columns=(list selected-column:ast)
  ^-  (list vector)
  =/  i  0
  =/  vals=(list vector-cell)  ~
  |-
  ?~  columns  ?:  =(~ vals)  ~|("no literal values" !!)
               (limo ~[(vector %vector (flop vals))])
  ?.  ?=(selected-value:ast -.columns)
    ~|("selected value {<-.columns>} not a literal" !!)
  =/  column=selected-value:ast  -.columns
  %=  $
    i        +(i)
    columns  +.columns
    vals
      [(vector-cell (heading column (crip "literal-{<i>}")) value.column) vals]
  ==
++  plan-upd
  |=  $:  r=indexed-row
          count=@ud
          f=(unit $-(joined-row ?))
          obj=qualified-object:ast
          updates=(list [@tas @])
          key-columns=(list key-column)
          ==
  ^-  [indexed-row @ud]
  ?~  f
    ?~  key-columns  [[-.r (produce-update r updates)] +(count)]
    [(update-key r updates key-columns) +(count)]

  ?.  ((need f) [-.r [[obj +.r] ~ ~]])  [r count]
  ?~  key-columns  [[-.r (produce-update r updates)] +(count)]
  [(update-key r updates key-columns) +(count)]
++  update-key
  |=  [r=indexed-row updates=(list [@tas @]) key-columns=(list key-column)]
  ^-  indexed-row
  =/  new-key=(list @)  ~
  =/  upd-row  (produce-update r updates)
  |-
  ?~  key-columns  [(flop new-key) upd-row]
  %=  $
    new-key      [(~(got by upd-row) name.i.key-columns) new-key]
    key-columns  t.key-columns
  ==
++  produce-update
  |=  [r=indexed-row updates=(list [@tas @])]
  ^-  (map @tas @)
  =/  x  +.r
  |-
  ?~  updates  x
  %=  $
    x        (~(put by x) -.i.updates +.i.updates)
    updates  +.updates
  ==
++  mk-updates
  |=  $:  table=qualified-object:ast
          columns=(list qualified-column:ast)
          ::values=(list value-or-default:ast)
          values=(list *)
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
++  named-queries
  |=  ctes=(list cte:ast)
  ^-  (map @tas [@ud (list indexed-row)])
  =/  cte-rows=(map @tas [@ud (list indexed-row)])  ~
  |-
  ?~  ctes  cte-rows
  %=  $
    cte-rows  (~(put by cte-rows) +<.i.ctes (named-query +>.i.ctes))
    ctes  +.ctes
  ==
::
::  +named-query:  (list cte:ast) -> (map @tas from-obj)
::  resolve CTEs
++  named-query
  |=  q=query:ast
  ^-  [@ud (list indexed-row)]
  ?~  from.q  [1 (select-literals columns.selection.q)]
  =/  =join-return        (join-all(state state, bowl bowl) q)
  ?~  data-objs.join-return  ~|("can't get here" !!)
  [rowcount.i.data-objs.join-return indexed-rows.i.data-objs.join-return]
--