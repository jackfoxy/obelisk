/-  ast, *obelisk
/+  *sys-views, *utils
|%
::
::  +new-database:  [databases bowl:gall command:ast] -> [cmd-result databases]
++  new-database
  |=  [state=databases =bowl:gall c=command:ast]
  ^-  [cmd-result databases]
  ?:  =(+<.c %sys)  ~|("database name cannot be 'sys'" !!)
  ?>  ?=(create-database:ast c)
  ?:  (~(has by state) +<.c)  ~|("database {<name.c>} already exists" !!)
  =/  sys-time  (set-tmsp as-of:`create-database:ast`c now.bowl)
  =/  ns=namespaces  (my ~[[%sys sys-time] [%dbo sys-time]])
  =/  db-views
        %-  limo  :~  :-  [%sys %namespaces sys-time]
                          %-  apply-ordering
                              (sys-namespaces-view +<.c sap.bowl sys-time)
                      :-  [%sys %tables sys-time]
                          %-  apply-ordering
                              (sys-tables-view +<.c sap.bowl sys-time)
                      :-  [%sys %columns sys-time]
                          %-  apply-ordering
                              (sys-columns-view +<.c sap.bowl sys-time)
                      :-  [%sys %sys-log sys-time]
                          %-  apply-ordering
                              (sys-sys-log-view +<.c sap.bowl sys-time)
                      :-  [%sys %data-log sys-time]
                          %-  apply-ordering
                              (sys-data-log-view +<.c sap.bowl sys-time)
                      ==
  =/  vws=views  (gas:view-key *((mop data-obj-key view) ns-obj-comp) db-views)
  =/  sys-db=database
        ?:  (~(has by state) %sys)
          (~(got by state) %sys)
        %:  mk-db     ::  first time add sys database
              %sys
              bowl
              (my ~[[%sys sys-time]])
              sys-time
              :~  :-  [%sys %databases sys-time]
                      (apply-ordering (sys-sys-dbs-view sap.bowl sys-time))
                      ==
              ==
  ::
  =/  next-state  (upd-view-caches state sys-db sys-time ~ %create-database)
  ::
  :-  [%results ~[[%server-time now.bowl] [%schema-time sys-time]]]
      (~(put by next-state) +<.c (mk-db name.c bowl ns sys-time db-views))
::
::  +mk-db:  [@tas bowl:gall namespaces @da (list [p=data-obj-key q=view])]
::           -> database
++  mk-db
  |=  $:  name=@tas
          =bowl:gall
          =namespaces
          sys-time=@da
          db-views=(list [p=data-obj-key q=view])
          ==
  ^-  database
  =/  vws=views  (gas:view-key *((mop data-obj-key view) ns-obj-comp) db-views)
  =/  vw-cache
        %+  gas:view-cache-key
              *((mop data-obj-key cache) ns-obj-comp)
              %+  turn  db-views
                        |=([p=data-obj-key q=view] [p (cache %cache time.p ~)])
  ::
  %:  database  %database
                name
                sap.bowl
                sys-time
                :+  :-  sys-time
                        %:  schema  %schema
                                    sap.bowl
                                    sys-time
                                    namespaces
                                    ~
                                    vws
                        ==
                    ~
                    ~
                :+  :-  sys-time
                        %:  data  %data
                                  src.bowl
                                  sap.bowl
                                  sys-time
                                  ~
                        ==
                    ~
                    ~
                vw-cache
              ==
::
::  +process-cmds:  [databases bowl:gall (list command:ast)]
::                  -> [(list cmd-result) databases]
++  process-cmds
  |=  [state=databases =bowl:gall cmds=(list command:ast)]
  ^-  [(list cmd-result) databases]
  =/  next-schemas=(map @tas @da)  ~
  =/  next-data=(map @tas @da)  ~
  =/  results=(list cmd-result)  ~
  =/  query-has-run=?  %.n
  |-
  ?~  cmds  :-  (flop results)
                state
  ?-  -<.cmds
    %alter-index
      ?:  query-has-run  ~|("alter index state change after query in script" !!)
      !!
    %alter-namespace
      ?:  query-has-run
        ~|("alter namespace state change after query in script" !!)
      !!
    %alter-table
      ?:  query-has-run  ~|("alter table state change after query in script" !!)
      !!
    %create-database  ~|("create database must be only command in script" !!)
    %create-index
      ?:  query-has-run
        ~|("create-index state change after query in script" !!)
      !!
    %create-namespace
      ?:  query-has-run
        ~|("create namespace state change after query in script" !!)
      =/  r=[@da (map @tas @da) databases]
            (create-ns state bowl -.cmds next-schemas next-data)
      %=  $
        next-schemas  +<.r
        state         +>.r
        cmds          +.cmds
        results       :-
                          :-  %results
                            (limo ~[[%server-time now.bowl] [%schema-time -.r]])
                          results
      ==
    %create-table
      ?:  query-has-run
        ~|("create table state change after query in script" !!)
      =/  r=table-return
            (create-tbl state bowl -.cmds next-schemas next-data)
      %=  $
        next-schemas  +<.r
        next-data     +>-.r
        state         +>+.r
        cmds          +.cmds
        results     :-
                      :-  %results
                          (limo ~[[%server-time now.bowl] [%schema-time -<.r]])
                        results
      ==
    %create-view
      ?:  query-has-run  ~|("create view state change after query in script" !!)
      !!
    %drop-database
      !!
    %drop-index
      ?:  query-has-run  ~|("drop index state change after query in script" !!)
      !!
    %drop-namespace
      ?:  query-has-run
        ~|("drop namespace state change after query in script" !!)
      !!
    %drop-table
      ?:  query-has-run  ~|("drop table state change after query in script" !!)
      =/  r=table-return
            (drop-tbl state bowl -.cmds next-schemas next-data)
      %=  $
        next-schemas  +<.r
        next-data     +>-.r
        state         +>+.r
        cmds          +.cmds
        results
          ?:  ->-.r
            :-  :-  %results
                    %-  limo  :~  [%server-time now.bowl]
                                  [%schema-time -<.r]
                                  [%data-time -<.r]
                                  [%vector-count ->+.r]
                                  ==
                results
          :-
            :-  %results
                (limo ~[[%server-time now.bowl] [%schema-time -<.r]])
            results
      ==
    %drop-view
      ?:  query-has-run  ~|("drop view state change after query in script" !!)
      !!
    %grant
      !!
    %revoke
      !!
    %transform
      =/  r=[? [(map @tas @da) databases (list result)]]
            %:  do-transform  state
                              bowl
                              -.cmds
                              query-has-run
                              next-data
                              next-schemas
                              ==
      %=  $
        query-has-run   -.r
        next-data       +<.r
        state           +>-.r
        cmds            +.cmds
        results         [[%results +>+.r] results]
      ==
    %truncate-table
      ?:  query-has-run
        ~|("truncate table state change after query in script" !!)
      =/  r=table-return
            (truncate-tbl state bowl -.cmds next-schemas next-data)
      %=  $
        next-schemas  +<.r
        next-data     +>-.r
        state         +>+.r
        cmds          +.cmds
        results
          ?.  ->-.r
            :-  [%results (limo ~[[%message 'no data in table to truncate']])]
                results
          :-  :-  %results
                  %-  limo  :~  [%server-time now.bowl]
                                [%data-time -<.r]
                                [%vector-count ->+.r]
                                ==
              results

      ==
  ==
::
::  +create-ns:
::    [databases bowl:gall create-namespace:ast (map @tas @da) (map @tas @da)]
::    -> [@da (map @tas @da) databases]
++  create-ns
  |=  $:  state=databases
          =bowl:gall
          =create-namespace:ast
          next-schemas=(map @tas @da)
          next-data=(map @tas @da)
      ==
  ^-  [@da (map @tas @da) databases]
  ?.  =(our.bowl src.bowl)  ~|("schema changes must be by local agent" !!)
  =/  db  ~|  "database {<database-name.create-namespace>} does not exist"
                 (~(got by state) database-name.create-namespace)
  =/  sys-time  (set-tmsp as-of.create-namespace now.bowl)
  =/  nxt-schema=schema
        ~|  "namespace {<name.create-namespace>} as-of schema time out of order"
          %:  get-next-schema  sys.db
                            next-schemas
                            sys-time
                            database-name.create-namespace
                            ==
  =/  dummy
       ~|  "namespace {<name.create-namespace>} as-of content time out of order"
          %:  get-next-data  content.db  :: for date checking purposes
                              next-data
                              sys-time
                              database-name.create-namespace
                              ==
  =.  namespaces.nxt-schema
        ~|  "namespace {<name.create-namespace>} already exists"
        %:  map-insert
            namespaces.nxt-schema
            name.create-namespace
            sys-time
        ==
  =.  tmsp.nxt-schema        sys-time
  =.  provenance.nxt-schema  sap.bowl
  ::
  :+  sys-time
      (~(put by next-schemas) database-name.create-namespace sys-time)
      %:  upd-view-caches
          state
          db(sys (put:schema-key sys.db sys-time nxt-schema))
          sys-time
          ~
          %create-namespace
          ==
::
::  +create-tbl:
::    [databases bowl:gall create-table:ast (map @tas @da) (map @tas @da)]
::    -> table-return
++  create-tbl
  |=  $:  state=databases
          =bowl:gall
          =create-table:ast
          next-schemas=(map @tas @da)
          next-data=(map @tas @da)
          ==
  ^-  table-return
  ?.  =(our.bowl src.bowl)  ~|("table must be created by local agent" !!)
  =/  db  ~|  "database {<database.table.create-table>} does not exist"
                 (~(got by state) database.table.create-table)
  =/  sys-time  (set-tmsp as-of.create-table now.bowl)
  =/  nxt-schema=schema
        ~|  "table {<name.table.create-table>} as-of schema time out of order"
          %:  get-next-schema  sys.db
                              next-schemas
                              sys-time
                              database.table.create-table
                              ==
  =/  nxt-data=data
        ~|  "table {<name.table.create-table>} as-of data time out of order"
          %:  get-next-data  content.db
                              next-data
                              sys-time
                              database.table.create-table
                              ==
  ::
  ?.  (~(has by namespaces.nxt-schema) namespace.table.create-table)
    ~|("namespace {<namespace.table.create-table>} does not exist" !!)
  =/  col-set  (name-set (silt columns.create-table))
  ?.  =((lent columns.create-table) ~(wyt in col-set))
    ~|("duplicate column names {<columns.create-table>}" !!)
  =/  key-col-set  (name-set (silt pri-indx.create-table))
  =/  key-count  ~(wyt in key-col-set)
  ?.  =((lent pri-indx.create-table) key-count)
    ~|("duplicate column names in key {<columns.create-table>}" !!)
  ?.  =(key-count ~(wyt in (~(int in col-set) key-col-set)))
    ~|("key column not in column definitions {<pri-indx.create-table>}" !!)
  ::
  =/  column-look-up  (malt (spun columns.create-table make-col-lu-data))
  ::
  =/  table
        %:  table
            %table
            sap.bowl
            sys-time
            column-look-up
            (make-index-key column-look-up pri-indx.create-table)
            %:  index
                %index
                %.y
                clustered.create-table
                pri-indx.create-table
            ==
            columns.create-table
            ~
        ==
  =/  tables
    ~|  "{<name.table.create-table>} exists in {<namespace.table.create-table>}"
    %:  map-insert
        tables.nxt-schema
        [namespace.table.create-table name.table.create-table]
        table
    ==
  =.  tables.nxt-schema      tables
  =.  tmsp.nxt-schema        sys-time
  =.  provenance.nxt-schema  sap.bowl
  ::
  =/  file  %:  file
                %file
                src.bowl
                sap.bowl
                sys-time
                clustered.create-table
                0
                ~
                ~
            ==
  =/  files
    ~|  "{<name.table.create-table>} exists in {<namespace.table.create-table>}"
    %:  map-insert
        files.nxt-data
        [namespace.table.create-table name.table.create-table]
        file
    ==
  =.  files.nxt-data       files
  =.  ship.nxt-data        src.bowl
  =.  provenance.nxt-data  sap.bowl
  =.  tmsp.nxt-data        sys-time
  ::
  :^  [sys-time %.n 0]
      (~(put by next-schemas) database.table.create-table sys-time)
      (~(put by next-data) database.table.create-table sys-time)
      %:  upd-view-caches
            state
              %=  db
                  sys      (put:schema-key sys.db sys-time nxt-schema)
                  content  (put:data-key content.db sys-time nxt-data)
                  ==
            sys-time
            ~
            %create-table
            ==
::
::  +truncate-tbl:
::    [databases bowl:gall truncate-table:ast (map @tas @da) (map @tas @da)]
::    -> table-return
::
::  TRUNCATE is one of the few commands where AS OF is of no use.
++  truncate-tbl
  |=  $:  state=databases
          =bowl:gall
          d=truncate-table:ast
          next-schemas=(map @tas @da)
          next-data=(map @tas @da)
          ==
  ^-  table-return
  =/  db  ~|  "database {<database.table.d>} does not exist"
             (~(got by state) database.table.d)
  =/  nxt-schema=schema
        ~|  "truncate table {<name.table.d>} as-of schema time out of order"
          %:  get-next-schema  sys.db
                              next-schemas
                              now.bowl
                              database.table.d
                              ==
  =/  nxt-data=data
        ~|  "truncate table {<name.table.d>} as-of data time out of order"
          %:  get-next-data  content.db
                              next-data
                              now.bowl
                              database.table.d
                              ==
  ::
  ?.  (~(has by namespaces.nxt-schema) namespace.table.d)
    ~|("namespace {<namespace.table.d>} does not exist" !!)
  ::
  =/  tables
    ~|  "{<name.table.d>} does not exists in {<namespace.table.d>}"
    %-  ~(got by tables:nxt-schema)
        [namespace.table.d name.table.d]
  ::
  =/  file
    ~|  "truncate table {<namespace.table.d>}.{<name.table.d>} does not exist"
        (~(got by files.nxt-data) [namespace.table.d name.table.d])
  ?.  (gth rowcount.file 0)  :: don't bother if table is empty
    [[now.bowl %.n 0] next-schemas next-data state]
  ::
  =/  dropped-rows  rowcount.file
  =.  rows.file     ~
  =.  rowcount.file   0
  =.  tmsp.file     now.bowl
  =/  files  (~(put by files.nxt-data) [namespace.table.d name.table.d] file)
  =.  files.nxt-data       files
  =.  ship.nxt-data        src.bowl
  =.  provenance.nxt-data  sap.bowl
  =.  tmsp.nxt-data        now.bowl
  ::
  :^  [now.bowl %.y dropped-rows]
      next-schemas
      (~(put by next-data) database.table.d now.bowl)
      %:  upd-view-caches
            state
            db(content (put:data-key content.db now.bowl nxt-data))
            now.bowl
            ~
            %truncate-table
            ==
::
::  +drop-tbl:
::    [databases bowl:gall drop-table:ast (map @tas @da) (map @tas @da)]
::    -> table-return
++  drop-tbl
  |=  $:  state=databases
          =bowl:gall
          d=drop-table:ast
          next-schemas=(map @tas @da)
          next-data=(map @tas @da)
          ==
  ^-  table-return
  ?.  =(our.bowl src.bowl)  ~|("table must be dropped by local agent" !!)
  =/  db  ~|  "database {<database.table.d>} does not exist"
             (~(got by state) database.table.d)
  =/  sys-time  (set-tmsp as-of.d now.bowl)
  =/  nxt-schema=schema
        ~|  "drop table {<name.table.d>} as-of schema time out of order"
          %:  get-next-schema  sys.db
                              next-schemas
                              sys-time
                              database.table.d
                              ==
  =/  nxt-data=data
        ~|  "drop table {<name.table.d>} as-of data time out of order"
          %:  get-next-data  content.db
                              next-data
                              sys-time
                              database.table.d
                              ==
  ::
  ?.  (~(has by namespaces.nxt-schema) namespace.table.d)
    ~|("namespace {<namespace.table.d>} does not exist" !!)
  ::
  =/  tables
    ~|  "{<name.table.d>} does not exist in {<namespace.table.d>}"
    %+  map-delete
        tables.nxt-schema
        [namespace.table.d name.table.d]
  =.  tables.nxt-schema      tables
  =.  tmsp.nxt-schema        sys-time
  =.  provenance.nxt-schema  sap.bowl
  ::
  =/  file
        ~|  "drop table {<namespace.table.d>}.{<name.table.d>} does not exist"
            (~(got by files.nxt-data) [namespace.table.d name.table.d])
  ?:  ?&((gth rowcount.file 0) =(force.d %.n))
    ~|("drop table {<name.table.d>} has data, use FORCE to DROP" !!)
  =/  dropped-data=?  (gth rowcount.file 0)
  =/  files
    %+  map-delete
        files.nxt-data
        [namespace.table.d name.table.d]
  =.  files.nxt-data       files
  =.  ship.nxt-data        src.bowl
  =.  provenance.nxt-data  sap.bowl
  =.  tmsp.nxt-data        sys-time
  ::
  :^  [sys-time dropped-data rowcount.file]
      (~(put by next-schemas) database.table.d sys-time)
      (~(put by next-data) database.table.d sys-time)
      %:  upd-view-caches
            state
            %=  db
                sys      (put:schema-key sys.db sys-time nxt-schema)
                content  (put:data-key content.db sys-time nxt-data)
                ==
            sys-time
            ~
            %drop-table
            ==
::
::  +do-transform:
::    [databases bowl:gall transform:ast ? (map @tas @da) (map @tas @da)]
::    -> [? [(map @tas @da) databases (list result)]]
++  do-transform
  |=  $:  state=databases
          =bowl:gall
          =transform:ast
          query-has-run=?
          next-data=(map @tas @da)
          next-schemas=(map @tas @da)
      ==
  ^-  [? [(map @tas @da) databases (list result)]]

  =/  ctes=(list cte:ast)  ctes.transform  :: To Do - map CTEs
  %:  do-set-functions  state
                        bowl
                        set-functions.transform
                        query-has-run
                        next-data
                        next-schemas
                        ==
::
::  +do-set-functions:
:: [databases bowl:gall (tree set-function:ast) ? (map @tas @da) (map @tas @da)]
:: -> [? [(map @tas @da) databases (list result)]]
++  do-set-functions
  |=  $:  state=databases
          =bowl:gall
          =(tree set-function:ast)
          query-has-run=?
          next-data=(map @tas @da)
          next-schemas=(map @tas @da)
      ==
  ::  =/  rtree  ^+((~(rdc of tree) foo) tree)
  ::  =/  rtree  `(tree set-function:ast)`(~(rdc of tree) foo)
  ::  =/  rtree=(tree set-function:ast)  (~(rdc of tree) foo)
  ::  ?~  rtree  !!  :: fuse loop

  ^-  [? [(map @tas @da) databases (list result)]]
  =/  rtree  (~(rdc of tree) rdc-set-func)
  ?-  -<.rtree
    %delete
      ?:  query-has-run  ~|("delete state change after query in script" !!)
      !!
    %insert
      ?:  query-has-run  ~|("insert state change after query in script" !!)
      :-  %.n
      ::    ~>  %bout.[0 %process-insert]
              (do-insert state bowl -.rtree next-data next-schemas)
    %update
      ?:  query-has-run  ~|("update state change after query in script" !!)
      !!
    %query
      :-  %.y
          [next-data (do-query state bowl -.rtree next-data next-schemas)]
  ::    ~&  >  "-.rtree: {<-.rtree>}"
  ::    ~&  >  "+.rtree: {<+.rtree>}"
  ::    ?>  ?=(query:ast -.rtree)
  ::    `query:ast`-.rtree
  ::    -.rtree

  ::    !!
    %merge
      ?:  query-has-run  ~|("merge state change after query in script" !!)
      !!
    ==
::
::  +do-insert:  [databases bowl:gall insert:ast (map @tas @da) (map @tas @da)]
::               -> [(map @tas @da) databases (list result)]
++  do-insert
  |=  $:  state=databases
          =bowl:gall
          ins=insert:ast
          next-data=(map @tas @da)
          next-schemas=(map @tas @da)
      ==
    :: to do: aura validation? (isn't this covered in testing?)
  ^-  [(map @tas @da) databases (list result)]
  =/  db  ~|  "database {<database.table.ins>} does not exist"
          (~(got by state) database.table.ins)
  =/  sys-time  (set-tmsp as-of.ins now.bowl)
  =/  nxt-schema=schema  ~|  "insert into table {<name.table.ins>} ".
                             "as-of schema time out of order"
                         %:  get-next-schema  sys.db
                                              next-schemas
                                              sys-time
                                              database.table.ins
                                              ==
  =/  nxt-data=data  ~|  "insert into table {<name.table.ins>} ".
                         "as-of data time out of order"
                     %:  get-next-data  content.db
                                        next-data
                                        sys-time
                                        database.table.ins
                                        ==
  =/  tbl-key  [namespace.table.ins name.table.ins]
  =/  =table  ~|  "table {<tbl-key>} does not exist"
              %-  ~(got by tables:nxt-schema)
                  tbl-key
  =/  =file  (~(got by files.nxt-data) tbl-key)
  =.  tmsp.file            sys-time
  =.  ship.nxt-data        src.bowl
  =.  provenance.nxt-data  sap.bowl
  =.  tmsp.nxt-data        sys-time
  ::
  =/  cols=(list column:ast)
        ?~  columns.ins
          columns.table
        ?.  =(~(wyt by column-lookup.table) ~(wyt in (silt (need columns.ins))))
          ~|("incorrect columns specified: {<columns.ins>}" !!)
          %+  turn
              `(list @t)`(need columns.ins)
              |=(a=@t (to-column a column-lookup.table))
  ::
  ?.  ?=([%data *] values.ins)  ~|("not implemented: {<values.ins>}" !!)
  =/  value-table  `(list (list value-or-default:ast))`+.values.ins
  =/  i=@ud  0
  =/  key-pick=(list [@tas @])
        %+  turn
            columns.pri-indx.table
            |=(a=ordered-column:ast (make-key-pick name.a column-lookup.table))
  =/  primary-key  (pri-key key.table)
  |-
  ?~  value-table
    :+  next-data
      %:  upd-indices-views
          %:  upd-view-caches
                state
                %=  db
                    content  %^  put:data-key
                                 content.db
                                 sys-time
                                 (update-file file nxt-data tbl-key key.table)
                    ==
                sys-time
                [~ ~]  :: to do: get list of effected views
                %insert
                ==
          sys-time
          ~[[table.ins]]
          ~  :: to do: indices to update
          ==
        :~  [%server-time now.bowl]
            [%schema-time tmsp.table]
            [%data-time sys-time]
            [%message 'inserted:']
            [%vector-count i]
            [%message 'table data:']
            [%vector-count rowcount.file]
            ==
  ~|  "insert {<tbl-key>} row {<+(i)>}"
  =/  row=(list value-or-default:ast)  -.value-table
  =/  file-row=(map @tas @)  (row-cells row cols)
  =/  row-key
        %+  turn
            key-pick
            |=(a=[p=@tas q=@ud] (key-atom [p.a file-row]))
  =.  pri-idx.file  ?:  (has:primary-key pri-idx.file row-key)
                      ~|("cannot add duplicate key: {<row-key>}" !!)
                    (put:primary-key pri-idx.file row-key file-row)
  ::=.  rows.file             [file-row rows.file]
  =.  rowcount.file           +(rowcount.file)
  $(i +(i), value-table `(list (list value-or-default:ast))`+.value-table)
::
::  +do-query:  [databases bowl:gall query:ast (map @tas @da) (map @tas @da)]
::              -> [databases (list result)]
++  do-query
  |=  $:  state=databases
          =bowl:gall
          q=query:ast
          next-data=(map @tas @da)     :: probably no longer necessary, but
          next-schemas=(map @tas @da)  :: problematic w/ same times in 1 script
          ==
  ^-  [databases (list result)]
  =/  sys-db  (~(got by state) %sys)
  ?~  from.q
       :-  state    :: no from? only literals
           :~  (result %result-set (select-literals columns.selection.q))
               [%server-time now.bowl]
               [%schema-time created-tmsp.sys-db]
               [%data-time created-tmsp:(~(got by state) %sys)]
               (result %vector-count 1)
               ==
  =/  =from:ast  (need from.q)
  =/  =table-set:ast  object.from
    :::::
  =/  query-obj=qualified-object:ast
        ?:  ?=(qualified-object:ast object.table-set)
          `qualified-object:ast`object.table-set
        ~|("not supported" !!)   :: %query-row non-sense to support
                                 :: %transform composition
    ::::::::
  =/  sys-time  now.bowl  :: to do: sys-time  parse updated to object as of time
  =/  db=database  ~|  "database {<database.query-obj>} does not exist"
                  (~(got by state) database.query-obj)
  =/  =schema
        ~|  "database {<database.query-obj>} doesn't exist at time {<sys-time>}"
        (get-schema [sys.db sys-time])
  =/  vw  (get-view [namespace.query-obj name.query-obj sys-time] views.schema)
  =/  r=[databases data-obj]
    ?~  vw
      [state (table-data db schema query-obj sys-time columns.selection.q)]
    (view-data state db schema (need vw) query-obj sys-time columns.selection.q)
  :-  -.r
      :~  [%result-set rows.+.r]
          [%server-time now.bowl]
          [%schema-time tmsp.schema]
          [%data-time data-time.+.r]
          [%vector-count rowcount.+.r]
          ==
::
::  +view-data:
::  [databases database schema view qualified-object (list selected-column:ast)]
::  -> [databases (list vector)]
::
::  state may be updated by insertion into view-cache, which does not effect
::  any other part of the state
++  view-data
  |=  $:  state=databases
          db=database
          =schema
          =view
          q=qualified-object:ast
          sys-time=@da
          selected=(list selected-column:ast)
          ==
  ^-  [databases data-obj]
  =/  r=[database cache]
        (mk-view-cache state db schema view [namespace.q name.q sys-time])
  =/  view-content  (need content.+.r)
  =/  vectors  %+  select-columns  rows.view-content
                                   (mk-vect-templ columns.view selected)
  =/  data-object
        %:  data-obj  %data-obj
                      tmsp.schema
                      tmsp.+.r
                      columns.view
                      (lent vectors)
                      vectors
                      ==
  ?:  =(db -.r)  [state data-object]
  [(~(put by state) database.q -.r) data-object]
::
::  +mk-view-cache:
::    [databases database schema view data-obj-key (list selected-column:ast)]
::    -> [database cache]
++  mk-view-cache
  |=  [state=databases db=database =schema vw=view key=data-obj-key]
  ^-  [database cache]
  =/  vw-cache=cache  (need (get-view-cache key view-cache.db))
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
::  +table-data:  [database schema qualified-object:ast @da] -> data-obj
++  table-data
  |=   $:  db=database
           =schema
           q=qualified-object:ast
           sys-time=@da
           selected=(list selected-column:ast)
           ==
  ^-  data-obj
  =/  tbl-key  [namespace.q name.q]
  =/  tbl  ~|  "table {<namespace.q>}.{<name.q>} does not exist at schema ".
               "time {<tmsp.schema>}"
           (~(got by tables.schema) tbl-key)
  =/  file  (get-content content.db sys-time tbl-key)
  =/  vectors  (select-columns rows.file (mk-vect-templ columns.tbl selected))
  %:  data-obj  %data-obj
                tmsp.schema
                tmsp.file
                columns.tbl
                (lent vectors)
                vectors
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
--
