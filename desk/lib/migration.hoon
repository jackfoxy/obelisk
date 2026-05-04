/-  *server-state-1
/+  *utils
/=  oldstate  /sur/server-state-0
|%
++  migrate-server-0-to-1
  |=  old-server=server:oldstate
  ^-  server
  =/  new-server=server
    %-  malt
    %+  turn  ~(tap by old-server)
      |=  [kv=[name=@tas db=database:oldstate]]
      [name.kv (migrate-database-0-to-1 db.kv)]
  ?:  ?!((~(has by new-server) %sys))  new-server
  =/  sys-db=database  (~(got by new-server) %sys)
  =.  event-log.sys-db
        (weld (database-create-events old-server) event-log.sys-db)
  (~(put by new-server) %sys sys-db)
::
++  migrate-database-0-to-1
  |=  old-db=database:oldstate
  ^-  database
  =/  sys-1=((mop @da schema) gth)  `((mop @da schema) gth)`sys.old-db
  :*  %database
      name.old-db
      created-provenance.old-db
      created-tmsp.old-db
      sys-1
      `((mop @da data) gth)`content.old-db
      `view-cache`view-cache.old-db
      (build-event-log name.old-db sys-1)
      ==
::
++  database-create-events
  |=  old-server=server:oldstate
  ^-  (list sys-log-event)
  %+  turn
    %+  skim  ~(tap by old-server)
    |=  [kv=[name=@tas db=database:oldstate]]
    !=(%sys name.kv)
  |=  [kv=[name=@tas db=database:oldstate]]
  %:  make-sys-log-event  created-tmsp.db.kv
                          created-provenance.db.kv
                          %create
                          %database
                          `name.kv
                          ~
                          name.kv
                          ~
                          ~
                          ~
                          ~
                          ==
--
