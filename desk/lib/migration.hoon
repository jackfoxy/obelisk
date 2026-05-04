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
  %+  turn  %+  skim  ~(tap by old-server)
                      |=  [kv=[name=@tas db=database:oldstate]]
                      !=(%sys name.kv)
            |=  [kv=[name=@tas db=database:oldstate]]
            :*  %sys-log-event
                created-tmsp.db.kv
                created-provenance.db.kv
                %create
                %database
                name.kv
                ~
                ~
                ~
                ~
                ~
                ~
                ==
::
++  build-event-log
  |=  [db-name=@tas sys=((mop @da schema) gth)]
  ^-  (list sys-log-event)
  =/  snaps=(list schema)
        (turn (tap:schema-key sys) |=(b=[@da schema] +.b))
  =/  events  *(list sys-log-event)
  |-
  ?~  snaps  events
  =/  prev=(unit schema)  ?~(t.snaps ~ `i.t.snaps)
  %=  $
    snaps   t.snaps
    events  (weld (schema-events db-name i.snaps prev) events)
  ==
::
++  schema-events
  |=  [db-name=@tas curr=schema prev=(unit schema)]
  ^-  (list sys-log-event)
  =/  ns-events=(list sys-log-event)
        %+  turn
          %+  skim  ~(tap by namespaces.curr)
          |=  [kv=[@tas @da]]
          ?~  prev
            =(tmsp.curr +.kv)
          ?&  =(tmsp.curr +.kv)
              ?!((~(has by namespaces.u.prev) -.kv))
          ==
        |=  [kv=[@tas @da]]
        ^-  sys-log-event
        :*  %sys-log-event
            tmsp.curr
            provenance.curr
            %create
            %namespace
            db-name
            `-.kv
            ~
            ~
            ~
            ~
            ~
            ==
  =/  tbl-creates=(list sys-log-event)
        %+  turn
          %+  skim  ~(tap by tables.curr)
          |=  [kv=[k=[ns=@tas name=@tas] tbl=table]]
          ?~  prev
            =(tmsp.curr tmsp.tbl.kv)
          ?&  =(tmsp.curr tmsp.tbl.kv)
              ?!((~(has by tables.u.prev) k.kv))
          ==
        |=  [kv=[k=[ns=@tas name=@tas] tbl=table]]
        ^-  sys-log-event
        :*  %sys-log-event
            tmsp.curr
            provenance.curr
            %create
            %table
            db-name
            `ns.k.kv
            `name.k.kv
            ~
            ~
            ~
            ~
            ==
  =/  tbl-drops=(list sys-log-event)
        ?~  prev
          ~
        %+  turn
          %+  skim  ~(tap by tables.u.prev)
          |=  [kv=[k=[ns=@tas name=@tas] tbl=table]]
          ?!((~(has by tables.curr) k.kv))
        |=  [kv=[k=[ns=@tas name=@tas] tbl=table]]
        ^-  sys-log-event
        :*  %sys-log-event
            tmsp.curr
            provenance.curr
            %drop
            %table
            db-name
            `ns.k.kv
            `name.k.kv
            ~
            ~
            ~
            ~
            ==
  (weld ns-events (weld tbl-creates tbl-drops))
--
