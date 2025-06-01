/-  ast, *obelisk
/+  *sys-views, *ddl, *selection, parse
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
  ::  next-schemas and next-data respectively track whether the current script 
  ::  has advanced the schema and data times, respectively.
  ::  If so, schema and data changes at the current schema and data times are
  ::  allowed.
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
      =/  r=[cmd-result (map @tas @da) server]
            (create-ns(state state, bowl bowl) -.cmds next-schemas next-data)
      %=  $
        next-schemas  +<.r
        state         +>.r
        cmds          +.cmds
        results       [-.r results]
      ==
    %create-table
      ?.  =(our.bowl src.bowl)
            ~|("CREATE TABLE: table must be created by local agent" !!)
      ?:  query-has-run
        ~|("CREATE TABLE: state change after query in script" !!)
      =/  r=[cmd-result (map @tas @da) (map @tas @da) server]
            (create-tbl(state state, bowl bowl) -.cmds next-schemas next-data)
      %=  $
        next-schemas  +<.r
        next-data     +>-.r
        state         +>+.r
        cmds          +.cmds
        results       [-.r results]
      ==
    %create-view
      ?.  =(our.bowl src.bowl)
            ~|("CREATE VIEW: schema changes must be by local agent" !!)
      ?:  query-has-run
            ~|("CREATE VIEW: state change after query in script" !!)
      ~|("%create-view not implemented" !!)
    %delete
      ?:  query-has-run  ~|("DELETE: state change after query in script" !!)
      =/  ctes=(map @tas [@ud (list indexed-row)])
            (named-queries ->-.cmds)
      =/  r=[(map @tas @da) server (list result)]
            %^  do-delete(state state, bowl bowl)  -.cmds
                                                   next-data
                                                   next-schemas
      %=  $
        query-has-run   %.n
        next-data       -.r
        state           +<.r
        cmds            +.cmds
        results         [[%results +>.r] results]
      ==
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
      =/  r=[cmd-result (map @tas @da) (map @tas @da) server]
            (drop-tbl(state state, bowl bowl) -.cmds next-schemas next-data)
      %=  $
        next-schemas  +<.r
        next-data     +>-.r
        state         +>+.r
        cmds          +.cmds
        results       [-.r results]
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
            %:  do-selection(state state, bowl bowl)  -.cmds
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
      =/  r=[cmd-result (map @tas @da) (map @tas @da) server]
            (truncate-tbl(state state, bowl bowl) cmd next-schemas next-data)
      %=  $
        next-schemas  +<.r
        next-data     +>-.r
        state         +>+.r
        cmds          +.cmds
        results       [-.r results]
      ==
    %update
      ?:  query-has-run  ~|("UPDATE: state change after query in script" !!)
      =/  ctes=(map @tas [@ud (list indexed-row)])
            (named-queries ->-.cmds)
      =/  r=[(map @tas @da) server (list result)]
            %^  do-update(state state, bowl bowl)  -.cmds
                                                   next-data
                                                   next-schemas
      %=  $
        query-has-run   %.n
        next-data       -.r
        state           +<.r
        cmds            +.cmds
        results         [[%results +>.r] results]
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
--
