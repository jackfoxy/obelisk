/-  *server-state-1
/+  *utils
/=  oldstate  /sur/server-state-0
|%
++  old-schema-key  ((on @da schema:oldstate) gth)
++  old-data-key    ((on @da data:oldstate) gth)
::
++  migrate-server-0-to-1
  |=  old-server=server:oldstate
  ^-  server
  ?:  =(~ old-server)  *server
  =/  new-server=server
    %-  malt  %+  turn  ~(tap by old-server)
                        |=  [kv=[name=@tas db=database:oldstate]]
                        [name.kv (migrate-database-0-to-1 db.kv)]
  :: NOTE: a situation where there are existing databases, but no %sys database,
  ::       indicates the server has been tampered with outside of the normal
  ::       runtime operations...or some unanticipated bug
  ?:  ?!((~(has by new-server) %sys))
    ~&  "WARNING: no %sys database encountered during migration"
    new-server
  =/  sys-db=database  (~(got by new-server) %sys)
  =.  event-log.sys-db
        (weld (database-create-events old-server) event-log.sys-db)
  (~(put by new-server) %sys sys-db)
::
++  migrate-database-0-to-1
  |=  old-db=database:oldstate
  ^-  database
  =/  sys-1=((mop @da schema) gth)  (migrate-sys-0-to-1 sys.old-db)
  :*  %database
      name.old-db
      created-provenance.old-db
      created-tmsp.old-db
      sys-1
      (migrate-content-0-to-1 content.old-db)
      `view-cache`view-cache.old-db
      (build-event-log name.old-db sys-1)
      ==
::
++  migrate-sys-0-to-1
  |=  old-sys=((mop @da schema:oldstate) gth)
  ^-  ((mop @da schema) gth)
  %+  gas:schema-key
      *((mop @da schema) gth)
      %+  turn  (tap:old-schema-key old-sys)
      |=  [kv=[@da schema:oldstate]]
      [-.kv (migrate-schema-0-to-1 +.kv)]
::
++  migrate-content-0-to-1
  |=  old-content=((mop @da data:oldstate) gth)
  ^-  ((mop @da data) gth)
  %+  gas:data-key
      *((mop @da data) gth)
      %+  turn  (tap:old-data-key old-content)
      |=  [kv=[@da data:oldstate]]
      [-.kv (migrate-data-0-to-1 +.kv)]
::
++  migrate-schema-0-to-1
  |=  old-schema=schema:oldstate
  ^-  schema
  :*  %schema
      provenance.old-schema
      tmsp.old-schema
      namespaces.old-schema
      %-  malt
      %+  turn  ~(tap by tables.old-schema)
      |=  [kv=[[ns=@tas name=@tas] table:oldstate]]
      [-.kv (migrate-table-0-to-1 +.kv)]
      views.old-schema
      ==
::
++  migrate-data-0-to-1
  |=  old-data=data:oldstate
  ^-  data
  :*  %data
      ship.old-data
      provenance.old-data
      tmsp.old-data
      %-  malt
      %+  turn  ~(tap by files.old-data)
      |=  [kv=[[ns=@tas name=@tas] file:oldstate]]
      [-.kv (migrate-file-0-to-1 +.kv)]
      ==
::
++  migrate-table-0-to-1
  |=  old-table=table:oldstate
  ^-  table
  :*  %table
      provenance.old-table
      tmsp.old-table
      column-lookup.old-table
      typ-addr-lookup.old-table
      pri-indx.old-table
      columns.old-table
      indices.old-table
      ~
      ==
::
++  migrate-file-0-to-1
  |=  old-file=file:oldstate
  ^-  file
  :*  %file
      ship.old-file
      provenance.old-file
      tmsp.old-file
      rowcount.old-file
      pri-idx.old-file
      indexed-rows.old-file
      ~
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
