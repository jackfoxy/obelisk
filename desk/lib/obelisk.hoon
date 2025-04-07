/-  ast, *obelisk
/+  *sys-views, *utils, *joins, *predicate, parse
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
::  +parse-urql:  [@tas tape] -> (list command:ast)
++  parse-urql
  |=  [db=@tas script=tape]
  ^-  (list command:ast)
  (parse:parse(default-database db) script)
::
::  +process-cmds:  [(list command:ast)] -> [(list cmd-result) server]
++  process-cmds
  |=  cmds=(list command:ast)
  ^-  [(list cmd-result) server]
  ::
  ::  to do:
  ::  temporary security prevents all access by foreign ships
  ::  until full persmissions processing implemented
          ?.  =(our.bowl src.bowl)
            ~|("all access by local agent only" !!)
  ::
  ::
  =/  next-schemas=(map @tas @da)  ~
  =/  next-data=(map @tas @da)  ~
  =/  results=(list cmd-result)  ~
  =/  query-has-run=?  %.n
  |-
  ?~  cmds  :-  (flop results)
                state
  ?-  -<.cmds
    %alter-index
      ?.  =(our.bowl src.bowl)
            ~|("ALTER INDEX: schema changes must be by local agent" !!)
      ?:  query-has-run
            ~|("ALTER INDEX: state change after query in script" !!)
      ~|("%alter-index not implemented" !!)
    %alter-namespace
      ?.  =(our.bowl src.bowl)
            ~|("CREATE NAMESPACE: schema changes must be by local agent" !!)
      ?:  query-has-run
        ~|("ALTER NAMESPACE: state change after query in script" !!)
      ~|("%alter-namespace not implemented" !!)
    %alter-table
      ?.  =(our.bowl src.bowl)
            ~|("ALTER TABLE: schema changes must be by local agent" !!)
      ?:  query-has-run
            ~|("ALTER TABLE: state change after query in script" !!)
      ~|("%alter-table not implemented" !!)
    %create-database
      :: create database is exempt from query-has-run
      ?.  =(our.bowl src.bowl)
            ~|("database must be created by local agent" !!)
      =/  r=[cmd-result (map @tas @da) (map @tas @da) server]
            (new-database -.cmds next-schemas next-data)
      %=  $
        next-schemas  +<.r
        next-data     +>-.r
        state         +>+.r
        cmds          +.cmds
        results  [-.r results]
      ==
    %create-index
      ?.  =(our.bowl src.bowl)
            ~|("CREATE-INDEX: schema changes must be by local agent" !!)
      ?:  query-has-run
        ~|("CREATE-INDEX: state change after query in script" !!)
      ~|("%create-index not implemented" !!)
    %create-namespace
      ?.  =(our.bowl src.bowl)
            ~|("CREATE NAMESPACE: schema changes must be by local agent" !!)
      ?:  query-has-run
        ~|("CREATE NAMESPACE: state change after query in script" !!)
      =/  cmd=create-namespace:ast  -.cmds
      =/  r=[@da (map @tas @da) server]
            (create-ns cmd next-schemas next-data)
      %=  $
        next-schemas  +<.r
        state         +>.r
        cmds          +.cmds
        results     :-
                      :-  %results
                          :~  [%message (crip "CREATE NAMESPACE {<name.cmd>}")]
                              [%server-time now.bowl]
                              [%schema-time -.r]
                              ==
                      results
      ==
    %create-table
      ?.  =(our.bowl src.bowl)
            ~|("CREATE TABLE: table must be created by local agent" !!)
      ?:  query-has-run
        ~|("CREATE TABLE: state change after query in script" !!)
      =/  cmd=create-table:ast  -.cmds
      =/  r=table-return  (create-tbl cmd next-schemas next-data)
      %=  $
        next-schemas  +<.r
        next-data     +>-.r
        state         +>+.r
        cmds          +.cmds
        results   :-
                    :-  %results
                        :~  [%message (crip "CREATE TABLE {<name.table.cmd>}")]
                            [%server-time now.bowl]
                            [%schema-time -<.r]
                            ==
                    results
      ==
    %create-view
      ?.  =(our.bowl src.bowl)
            ~|("CREATE VIEW: schema changes must be by local agent" !!)
      ?:  query-has-run
            ~|("CREATE VIEW: state change after query in script" !!)
      ~|("%create-view not implemented" !!)
    %drop-database
      ?.  =(our.bowl src.bowl)
            ~|("DROP DATABASE: database must be dropped by local agent" !!)
      ?:  query-has-run
            ~|("DROP DATABASE: state change after query in script" !!)
      =/  cmd=drop-database:ast  -.cmds
      %=  $
        state         (drop-db cmd)
        cmds          +.cmds
        results  :-
                   :-  %results
                       :~  [%message (crip "DROP DATABASE {<name.cmd>}")]
                           [%server-time now.bowl]
                           [%message (crip "database {<name.cmd>} dropped")]
                        ==
                   results
      ==
    %drop-index
      ?.  =(our.bowl src.bowl)
            ~|("DROP INDEX: schema changes must be by local agent" !!)
      ?:  query-has-run  ~|("DROP INDEX: state change after query in script" !!)
      ~|("%drop-index not implemented" !!)
    %drop-namespace
      ?.  =(our.bowl src.bowl)
            ~|("DROP NAMESPACE: schema changes must be by local agent" !!)
      ?:  query-has-run
        ~|("DROP NAMESPACE: state change after query in script" !!)
      ~|("%drop-namespace not implemented" !!)
    %drop-table
      ?.  =(our.bowl src.bowl)
            ~|("DROP TABLE: table must be dropped by local agent" !!)
      ?:  query-has-run  ~|("DROP TABLE: state change after query in script" !!)
      =/  cmd=drop-table:ast  -.cmds
      =/  r=table-return      (drop-tbl cmd next-schemas next-data)
      %=  $
        next-schemas  +<.r
        next-data     +>-.r
        state         +>+.r
        cmds          +.cmds
        results
          ?:  ->-.r
            :-  :-  %results
                    :~  [%message (crip "DROP TABLE {<name.table.cmd>}")]
                        [%server-time now.bowl]
                        [%schema-time -<.r]
                        [%data-time -<.r]
                        [%vector-count ->+.r]
                        ==
                results
          :-
            :-  %results
                :~  [%message (crip "DROP TABLE {<name.table.cmd>}")]
                    [%server-time now.bowl]
                    [%schema-time -<.r]
                    ==
            results
      ==
    %drop-view
      ?.  =(our.bowl src.bowl)
            ~|("DROP VIEW: schema changes must be by local agent" !!)
      ?:  query-has-run  ~|("DROP VIEW: state change after query in script" !!)
      ~|("%drop-view not implemented" !!)
    %grant
      ?.  =(our.bowl src.bowl)
            ~|("GRANT: grant permissions must be by local agent" !!)
      ~|("%grant not implemented" !!)
    %revoke
      ?.  =(our.bowl src.bowl)
            ~|("REVOKE: revoke permissions must be by local agent" !!)
      ~|("%revoke not implemented" !!)
    %selection
      =/  r=[? [(map @tas @da) server (list result)]]
            %:  do-selection  -.cmds
                              query-has-run
                              next-data
                              next-schemas
                              ==
      %=  $
        query-has-run   ?:  query-has-run  %.y  -.r
        next-data       +<.r
        state           +>-.r
        cmds            +.cmds
        results         [[%results +>+.r] results]
      ==
    %truncate-table
      ?:  query-has-run
        ~|("TRUNCATE TABLE: state change after query in script" !!)
      =/  cmd=truncate-table:ast  -.cmds
      =/  r=table-return  (truncate-tbl cmd next-schemas next-data)
      %=  $
        next-schemas  +<.r
        next-data     +>-.r
        state         +>+.r
        cmds          +.cmds
        results
          ?.  ->-.r
            :-  :-  %results
                    :~  :-  %message
                            %-  crip
                                %+  weld  "TRUNCATE TABLE "
                                    (trip (qualified-object-to-cord table.cmd))
                        [%message 'no data in table to truncate']
                        ==
                results
          :-  :-  %results
                  :~  :-  %message
                            %-  crip
                                %+  weld  "TRUNCATE TABLE "
                                    (trip (qualified-object-to-cord table.cmd))
                      [%server-time now.bowl]
                      [%data-time -<.r]
                      [%vector-count ->+.r]
                      ==
              results
      ==
  ==
::
::  +new-database:  [create-database:ast] -> [cmd-result server]
++  new-database
  |=  $:  c=create-database:ast
          next-schemas=(map @tas @da)
          next-data=(map @tas @da)
          ==
  ^-  [cmd-result (map @tas @da) (map @tas @da) server]
  ?:  =(name.c %sys)            ~|("database name cannot be 'sys'" !!)
  ?:  (~(has by state) name.c)  ~|("database {<name.c>} already exists" !!)
  =/  sys-time  (set-tmsp as-of.c now.bowl)
  =/  ns=namespaces  (my ~[[%sys sys-time] [%dbo sys-time]])
  =/  db-views
        %-  limo  :~  :-  [%sys %namespaces sys-time]
                          %-  apply-ordering
                              (sys-namespaces-view +<.c sap.bowl sys-time)
                      :-  [%sys %tables sys-time]
                          %-  apply-ordering
                              (sys-tables-view +<.c sap.bowl sys-time)
                      :-  [%sys %table-keys sys-time]
                          %-  apply-ordering
                              (sys-table-keys-view +<.c sap.bowl sys-time)
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
  ::
  =/  sys-db  ?:  (~(has by state) %sys)  (~(got by state) %sys)     
              %:  mk-db        ::  first time add sys database
                    %sys
                    (my ~[[%sys sys-time]])
                    sys-time
                    :~  :-  [%sys %databases sys-time]
                            %-  apply-ordering
                                (sys-sys-dbs-view sap.bowl sys-time)
                        ==
                    ==
  =.  sys-db  ?:  =(created-tmsp.sys-db sys-time)  sys-db
  sys-db(view-cache (upd-view-caches state sys-db sys-time ~ %create-database))
  =.  state  (~(put by state) %sys sys-db)
  ::
  :-  :-  %results
          :~  [%message (crip "created database {<name.c>}")]
              [%server-time now.bowl]
              [%schema-time sys-time]
              ==
      :+  (~(put by next-schemas) name.c sys-time)
          (~(put by next-data) name.c sys-time)
          (~(put by state) name.c (mk-db name.c ns sys-time db-views))
::
::  +mk-db:  [@tas namespaces @da (list [p=data-obj-key q=view])] -> database
++  mk-db
  |=  $:  name=@tas
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
::  +drop-db:  drop-database:ast -> server
::
::  clear content of %sys view keys caches
++  drop-db
  |=  drop=drop-database:ast
  ^-  server
  ?:  =(%sys name.drop)  ~|("database %sys cannot be dropped" !!)
  =/  db  ~|  "database {<name.drop>} does not exist"
              (~(got by state) name.drop)
  =/  nop
    ?:  force.drop  %.y
      ?.  (is-content-populated db now.bowl)  %.y
      ~|("{<name.drop>} has populated tables and `FORCE` was not specified" !!)
  =/  sys-db  (~(got by state) %sys)
  =.  view-cache.sys-db  %+  run:tab:view-cache-key  view-cache.sys-db
                                                     |=(a=cache [%cache +<.a ~])
  (~(del by (~(put by state) %sys sys-db)) name.drop)
::
::  +create-ns:
::    [create-namespace:ast (map @tas @da) (map @tas @da)]
::    -> [@da (map @tas @da) server]
++  create-ns
  |=  $:  =create-namespace:ast
          next-schemas=(map @tas @da)
          next-data=(map @tas @da)
      ==
  ^-  [@da (map @tas @da) server]
  =/  db  ~|  "CREATE NAMESPACE: database {<database-name.create-namespace>} ".
              "does not exist"
                 (~(got by state) database-name.create-namespace)
  =/  sys-time  (set-tmsp as-of.create-namespace now.bowl)
  =/  nxt-schema=schema
        ~|  "CREATE NAMESPACE: namespace {<name.create-namespace>} as-of ".
            "schema time out of order"
            %:  get-next-schema  sys.db
                                 next-schemas
                                 sys-time
                                 database-name.create-namespace
                                 ==
  =/  dummy
        ~|  "CREATE NAMESPACE: namespace {<name.create-namespace>} as-of ".
            "content time out of order"
          %:  get-next-data  content.db  :: for date checking purposes
                              next-data
                              sys-time
                              database-name.create-namespace
                              ==
  =.  namespaces.nxt-schema
        ~|  "CREATE NAMESPACE: namespace {<name.create-namespace>} ".
            "already exists"
        %:  map-insert
            namespaces.nxt-schema
            name.create-namespace
            sys-time
        ==
  =.  tmsp.nxt-schema        sys-time
  =.  provenance.nxt-schema  sap.bowl
  ::
  =.  sys.db         (put:schema-key sys.db sys-time nxt-schema)
  =.  view-cache.db  (upd-view-caches state db sys-time ~ %create-namespace)
  ::
  :+  sys-time
      (~(put by next-schemas) database-name.create-namespace sys-time)
      (~(put by state) name.db db)
::
::  +create-tbl:
::    [create-table:ast (map @tas @da) (map @tas @da)] -> table-return
++  create-tbl
  |=  $:  =create-table:ast
          next-schemas=(map @tas @da)
          next-data=(map @tas @da)
          ==
  ^-  table-return
  =/  db  ~|  "CREATE TABLE: database {<database.table.create-table>} ".
              "does not exist"
                 (~(got by state) database.table.create-table)
  =/  sys-time  (set-tmsp as-of.create-table now.bowl)
  =/  nxt-schema=schema
        ~|  "CREATE TABLE: table {<name.table.create-table>} as-of schema ".
            "time out of order"
          %:  get-next-schema  sys.db
                              next-schemas
                              sys-time
                              database.table.create-table
                              ==
  =/  nxt-data=data
        ~|  "CREATE TABLE: table {<name.table.create-table>} as-of data ".
            "time out of order"
          %:  get-next-data  content.db
                              next-data
                              sys-time
                              database.table.create-table
                              ==
  ::
  ?.  (~(has by namespaces.nxt-schema) namespace.table.create-table)
    ~|  "CREATE TABLE: namespace {<namespace.table.create-table>} ".
        "does not exist"
        !!
  =/  col-set  (name-set (silt columns.create-table))
  ?.  =((lent columns.create-table) ~(wyt in col-set))
    ~|("CREATE TABLE: duplicate column names {<columns.create-table>}" !!)
  =/  key-col-set  (name-set (silt pri-indx.create-table))
  =/  key-count  ~(wyt in key-col-set)
  ?.  =((lent pri-indx.create-table) key-count)
    ~|  "CREATE TABLE: duplicate column names in key {<pri-indx.create-table>}"
        !!
  ?.  =(key-count ~(wyt in (~(int in col-set) key-col-set)))
    ~|  "CREATE TABLE: key column not in column definitions ".
        "{<pri-indx.create-table>}"
        !!
  ::
  =/  column-look-up  (malt (spun columns.create-table make-col-lu-data))
  ::
  =/  table
        %:  table
            %table
            sap.bowl
            sys-time
            column-look-up
            %:  index
                %index
                %.y
                (mk-key-column column-look-up pri-indx.create-table)
            ==
            columns.create-table
            ~
        ==
  =/  tables
    ~|  "CREATE TABLE: {<name.table.create-table>} ".
        "exists in {<namespace.table.create-table>}"
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
                0
                ~
                ~
            ==
  =/  files
    ~|  "CREATE TABLE: {<name.table.create-table>} ".
        "exists in {<namespace.table.create-table>}"
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
  =.  sys.db         (put:schema-key sys.db sys-time nxt-schema)
  =.  content.db     (put:data-key content.db sys-time nxt-data)
  =.  view-cache.db  (upd-view-caches state db sys-time ~ %create-table)
  =.  state          (update-sys state sys-time)
  ::
  :^  [sys-time %.n 0]
      (~(put by next-schemas) database.table.create-table sys-time)
      (~(put by next-data) database.table.create-table sys-time)
      (~(put by state) name.db db)
::
::  +truncate-tbl:
::    [truncate-table:ast (map @tas @da) (map @tas @da)] -> table-return
++  truncate-tbl
  |=  $:  d=truncate-table:ast
          next-schemas=(map @tas @da)
          next-data=(map @tas @da)
          ==
  ^-  table-return
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
    [[sys-time %.n 0] next-schemas next-data state]
  ::
  =/  dropped-rows  rowcount.file
  =.  pri-idx.file    ~
  =.  indexed-rows.file       ~
  =.  rowcount.file   0
  =.  tmsp.file       sys-time
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
  :^  [sys-time %.y dropped-rows]
      next-schemas
      (~(put by next-data) database.table.d sys-time)
      (~(put by state) name.db db)
::
::  +drop-tbl:
::    [drop-table:ast (map @tas @da) (map @tas @da)] -> table-return
++  drop-tbl
  |=  $:  d=drop-table:ast
          next-schemas=(map @tas @da)
          next-data=(map @tas @da)
          ==
  ^-  table-return
  =/  db  ~|  "DROP TABLE: database {<database.table.d>} does not exist"
             (~(got by state) database.table.d)
  =/  sys-time  (set-tmsp as-of.d now.bowl)
  =/  nxt-schema=schema
        ~|  "DROP TABLE: {<name.table.d>} as-of schema time out of order"
          %:  get-next-schema  sys.db
                              next-schemas
                              sys-time
                              database.table.d
                              ==
  =/  nxt-data=data
        ~|  "DROP TABLE: {<name.table.d>} as-of data time out of order"
          %:  get-next-data  content.db
                              next-data
                              sys-time
                              database.table.d
                              ==
  ::
  ?.  (~(has by namespaces.nxt-schema) namespace.table.d)
    ~|("DROP TABLE: namespace {<namespace.table.d>} does not exist" !!)
  ::
  =/  tables
    ~|  "DROP TABLE: {<name.table.d>} does not exist in {<namespace.table.d>}"
    %+  map-delete
        tables.nxt-schema
        [namespace.table.d name.table.d]
  =.  tables.nxt-schema      tables
  =.  tmsp.nxt-schema        sys-time
  =.  provenance.nxt-schema  sap.bowl
  ::
  =/  file
        ~|  "DROP TABLE: {<namespace.table.d>}.{<name.table.d>} does not exist"
            (~(got by files.nxt-data) [namespace.table.d name.table.d])
  ?:  ?&((gth rowcount.file 0) =(force.d %.n))
    ~|("DROP TABLE: {<name.table.d>} has data, use FORCE to DROP" !!)
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
  =.  sys.db         (put:schema-key sys.db sys-time nxt-schema)
  =.  content.db     (put:data-key content.db sys-time nxt-data)
  =.  view-cache.db  (upd-view-caches state db sys-time ~ %drop-table)
  =.  state          (update-sys state sys-time)
  ::
  :^  [sys-time dropped-data rowcount.file]
      (~(put by next-schemas) database.table.d sys-time)
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
      !!
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
  |=  $:  ins=insert:ast
          next-data=(map @tas @da)
          next-schemas=(map @tas @da)
      ==
    :: to do: aura validation? (isn't this covered in testing? see roadmap)
  ^-  [(map @tas @da) server (list result)]
  =/  db  ~|  "INSERT: database {<database.table.ins>} does not exist"
          (~(got by state) database.table.ins)
  =/  content-time  (set-tmsp as-of.ins now.bowl)
  =/  nxt-schema=schema  ~|  "INSERT: table {<name.table.ins>} ".
                             "as-of schema time out of order"
                         %:  get-next-schema  sys.db
                                              next-schemas
                                              now.bowl
                                              database.table.ins
                                              ==
  =/  nxt-data=data  ~|  "INSERT: table {<name.table.ins>} ".
                         "as-of data time out of order"
                     (get-data-next content.db now.bowl)
  =/  tbl-key  [namespace.table.ins name.table.ins]
  =/  =table  ~|  "INSERT: table {<tbl-key>} does not exist"
              (~(got by tables:nxt-schema) tbl-key)
  =/  =file  (get-content content.db content-time tbl-key)
  =/  source-content-time  tmsp.file
  ::
  =.  tmsp.file            now.bowl
  =.  ship.nxt-data        src.bowl
  =.  provenance.nxt-data  sap.bowl
  =.  tmsp.nxt-data        now.bowl
  ::
  =/  cols=(list column:ast)
        ?~  columns.ins
          columns.table
        ?.  =(~(wyt by column-lookup.table) ~(wyt in (silt (need columns.ins))))
          ~|("INSERT: incorrect columns specified: {<columns.ins>}" !!)
          %+  turn
              `(list @t)`(need columns.ins)
              |=(a=@t (to-column a column-lookup.table))
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
            key.pri-indx.table
            |=(a=key-column (make-key-pick name.a column-lookup.table))
  =/  primary-key  (pri-key key.pri-indx.table)
  ::
  =.  state          (update-sys state now.bowl)
  ::
  |-
  ?~  value-table
    :+  (~(put by next-data) database.table.ins now.bowl)
      :: %:  upd-indices-views to do: revisit when there are views & indices
      %+  ~(put by state)  name.db
                           %=  db
                           content  %^  put:data-key
                                        content.db
                                        now.bowl
                                        %:  update-file  file
                                                         nxt-data
                                                         tbl-key
                                                         key.pri-indx.table
                                                         ==
                           view-cache  %:  upd-view-caches  state
                                                            db
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
          [%schema-time tmsp.table]
          [%data-time source-content-time]
          [%message 'inserted:']
          [%vector-count i]
          [%message 'table data:']
          [%vector-count rowcount.file]
          ==
  ~|  "INSERT: {<tbl-key>} row {<+(i)>}"
  =/  row=(list value-or-default:ast)  -.value-table
  =/  file-row=(map @tas @)  (row-cells row cols)
  =/  row-key=(list @)
        %+  turn
            key-pick
            |=(a=[p=@tas q=@ud] (key-atom [p.a file-row]))
  =.  pri-idx.file  ?:  (has:primary-key pri-idx.file row-key)
                      ~|("INSERT: cannot add duplicate key: {<row-key>}" !!)
                    (put:primary-key pri-idx.file row-key file-row)
  =.  rowcount.file           +(rowcount.file)
  $(i +(i), value-table `(list (list value-or-default:ast))`+.value-table)
::
::  +do-delete:
::    [delete:ast (map @tas @da) (map @tas @da)] -> table-return
++  do-delete
  |=  $:  d=delete:ast
          next-schemas=(map @tas @da)
          next-data=(map @tas @da)
          ==
  ^-  [(map @tas @da) server (list result)]
  =/  db  ~|  "DELETE FROM: database {<database.table.d>} does not exist"
             (~(got by state) database.table.d)
  =/  content-time  (set-tmsp as-of.d now.bowl)
  =/  nxt-schema=schema
        ~|  "DELETE FROM: {<name.table.d>} as-of schema time out of order"
          %:  get-next-schema  sys.db
                               next-schemas
                               now.bowl
                               database.table.d
                               ==
  =/  nxt-data=data
        ~|  "DELETE FROM: {<name.table.d>} as-of data time out of order"
        (get-data-next content.db now.bowl)
  ::
  =/  tbl-key  [namespace.table.d name.table.d]
  =/  table  ~|  "DELETE FROM: table {<tbl-key>} does not exist"
            (~(got by tables:nxt-schema) tbl-key)
  =/  file  (get-content content.db content-time tbl-key)
  =/  source-content-time  tmsp.file
  ?.  (gth rowcount.file 0)  :: don't bother if table is empty
    :+  next-data
        state
        :~  :-  %message
                %-  crip
                    "DELETE FROM {<namespace.table.d>}.{<name.table.d>}"
            [%server-time now.bowl]
            [%schema-time tmsp.table]
            [%data-time tmsp.file]
            [%message 'no rows deleted']
            ==
  ::
  =/  type-lookup=lookup-type
        %+  ~(put by `lookup-type`~)  
          table.d
          (malt (turn columns.table |=(a=column:ast [name.a type.a])))
  =/  qualifier-lookup
        %-  ~(gas by `(map @tas (list qualified-object:ast))`~)
            (turn columns.table |=(a=column:ast [name.a (limo ~[table.d])]))
  =/  filter=$-(joined-row ?)  %^  pred-ops-and-conjs
                                      %+  pred-qualify-unqualified
                                          predicate.d
                                          qualifier-lookup
                                      type-lookup
                                      qualifier-lookup
  =/  init-map=(map qualified-object:ast (map @tas @))  ~
  =.  indexed-rows.file
        %+  skim
              indexed-rows.file
              |=(a=indexed-row !(filter [-.a (~(put by init-map) table.d +.a)]))
  ::
  =/  new-rowcount  (lent indexed-rows.file)
  =/  deleted-rows  (sub rowcount.file new-rowcount)
  ?:  =(deleted-rows 0)
    :+  next-data
        state
        :~  :-  %message
                %-  crip
                    %+  weld  "DELETE FROM "
                              (trip (qualified-object-to-cord table.d))
            [%server-time now.bowl]
            [%schema-time tmsp.table]
            [%data-time tmsp.file]
            [%message 'no rows deleted']
            ==
  :: 
  =/  primary-key  (pri-key key.pri-indx.table)
  =/  comparator
        ~(order idx-comp `(list [@ta ?])`(reduce-key key.pri-indx.table))
  =.  pri-idx.file
        %+  gas:primary-key  *((mop (list @) (map @tas @)) comparator)
                             indexed-rows.file
  ::
  =.  rowcount.file       new-rowcount
  =.  tmsp.file           now.bowl
  =/  files  (~(put by files.nxt-data) [namespace.table.d name.table.d] file)
  =.  files.nxt-data       files
  =.  ship.nxt-data        src.bowl
  =.  provenance.nxt-data  sap.bowl
  =.  tmsp.nxt-data        now.bowl
  ::
  =.  content.db     (put:data-key content.db now.bowl nxt-data)
  =.  view-cache.db  (upd-view-caches state db now.bowl ~ %delete)
  =.  state          (update-sys state now.bowl)
  ::
  :+  (~(put by next-data) database.table.d now.bowl)
      (~(put by state) name.db db)
      :~  :-  %message
              %-  crip
                  %+  weld  "DELETE FROM "
                            (trip (qualified-object-to-cord table.d))
          [%server-time now.bowl]
          [%schema-time tmsp.table]
          [%data-time source-content-time]
          [%message 'deleted:']
          [%vector-count deleted-rows]
          [%message msg='table data:']
          [%vector-count rowcount.file]
          ==
::
::  +do-query:  [query:ast (map @tas @da) (map @tas @da)]
::              -> [server (list result)]
::
::  state may be updated by insertion into view-cache, which does not effect
::  any other part of the state
++  do-query
  |=  $:  q=query:ast
          next-data=(map @tas @da)     :: probably no longer necessary, but
          next-schemas=(map @tas @da)  :: problematic w/ same times in 1 script
          ==
  ^-  [server (list result)]
  =/  sys-db  (~(got by state) %sys)
  ?~  from.q
       :-  state    :: no from? only literals
           :~  [%message 'SELECT']
               (result %result-set (select-literals columns.selection.q))
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
      ?~  predicate.q
          %+  select-columns  joined-rows.all-data
                              %+  mk-vect-templ  qualified-columns
                                                 selected
      %^  select-columns-filtered  joined-rows.all-data
                                   %+  mk-vect-templ
                                         qualified-columns
                                         selected
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
::    -> (list (map @tas @))
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
                  %-  ~(got by (~(got by +.i.rows) qualifier))
                      column:(need object.cell)
            row
  ==
::
::  +select-columns-filtered:
::    $:  (list joined-row)
::        (list templ-cell)
::        $-((map @tas @) ?)
::        -> (list (map @tas @))
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
--
