/-  ast=obelisk-ast, *obelisk, *server-state-2
/+  *crud, *utils
::
::  User-defined views: CREATE VIEW, ALTER VIEW, and DROP VIEW.
::
::  A view is a named query.  Its references, the tables and views its query
::  reads, are resolved when it is created or altered: a name is a view when
::  one exists, else a table, except that the view's own name is the table it
::  shadows.  While a live view reads a relation, that relation cannot be
::  altered, dropped without FORCE, or shadowed by a new view.
::
|_  [state=server =bowl:gall]
::
++  create-vw
  |=  $:  c=create-view:ast
          next-schemas=(map @tas @da)
          next-data=(map @tas @da)
          ==
  ^-  [cmd-result:ast (map @tas @da) (map @tas @da) server]
  =/  verb  "CREATE VIEW"
  =/  qt=qualified-table:ast  view.c
  ?:  =(%sys namespace.qt)
    ~|("{verb}: views cannot be created in namespace %sys" !!)
  =/  work=[database @da schema]
    (view-work-state verb qt next-schemas next-data as-of.c)
  =/  sys-time=@da       +<.work
  =/  nxt-schema=schema  +>.work
  =/  key=[@tas @tas]    [namespace.qt name.qt]
  ?^  (get-view [-.key +.key sys-time] views.nxt-schema)
    ~|("{verb}: {<name.qt>} exists in {<namespace.qt>}" !!)
  =/  dummy
    ?.  (~(has by tables.nxt-schema) key)  ~
    =/  users=(list [ns-rel-key view])
      (view-dependents views.nxt-schema ~[[%table -.key +.key]])
    ?~  users  ~
    ~|  "{verb}: {<name.qt>} would shadow table {<namespace.qt>}.".
        "{<name.qt>} used in view {<ns.-.i.users>}.{<rel.-.i.users>}"
        !!
  =/  defined=[server view]
    (define-view verb qt nxt-schema crud-txn.c text.c sys-time)
  =/  vw=view  +.defined
  =.  views.nxt-schema
    (put:view-key views.nxt-schema [-.key +.key sys-time] vw)
  =/  srv=server
    (save-view-schema -.defined verb qt nxt-schema sys-time %create)
  =?  srv  cacheable.vw  (refresh-view srv qt sys-time)
  :^  :-  %results
          :~  [%action (crip "CREATE VIEW {<name.qt>}")]
              [%server-time now.bowl]
              [%schema-time sys-time]
              ==
      (~(put by next-schemas) database.qt sys-time)
      next-data
      srv
::
++  alter-vw
  |=  $:  c=alter-view:ast
          next-schemas=(map @tas @da)
          next-data=(map @tas @da)
          ==
  ^-  [cmd-result:ast (map @tas @da) (map @tas @da) server]
  =/  verb  "ALTER VIEW"
  =/  qt=qualified-table:ast  view.c
  ?:  =(%sys namespace.qt)
    ~|("{verb}: {<name.qt>} is a system view" !!)
  =/  work=[database @da schema]
    (view-work-state verb qt next-schemas next-data as-of.c)
  =/  sys-time=@da       +<.work
  =/  nxt-schema=schema  +>.work
  =/  key=[@tas @tas]    [namespace.qt name.qt]
  ?~  (get-view [-.key +.key sys-time] views.nxt-schema)
    ~|("{verb}: {<name.qt>} does not exist in {<namespace.qt>}" !!)
  =/  users=(list [ns-rel-key view])
    (view-dependents views.nxt-schema ~[[%view -.key +.key]])
  ?^  users
    ~|  "{verb}: {<name.qt>} used in view ".
        "{<ns.-.i.users>}.{<rel.-.i.users>}"
        !!
  =/  defined=[server view]
    (define-view verb qt nxt-schema crud-txn.c text.c sys-time)
  =/  vw=view  +.defined
  =.  views.nxt-schema
    %^  put:view-key  (remove-user-views views.nxt-schema (silt ~[key]))
                      [-.key +.key sys-time]
                      vw
  =/  srv=server
    (save-view-schema -.defined verb qt nxt-schema sys-time %alter)
  =?  srv  cacheable.vw  (refresh-view srv qt sys-time)
  :^  :-  %results
          :~  [%action (crip "ALTER VIEW {<name.qt>}")]
              [%server-time now.bowl]
              [%schema-time sys-time]
              ==
      (~(put by next-schemas) database.qt sys-time)
      next-data
      srv
::
++  drop-vw
  |=  $:  d=drop-view:ast
          next-schemas=(map @tas @da)
          next-data=(map @tas @da)
          ==
  ^-  [cmd-result:ast (map @tas @da) (map @tas @da) server]
  =/  verb  "DROP VIEW"
  =/  qt=qualified-table:ast  view.d
  ?:  =(%sys namespace.qt)
    ~|("{verb}: {<name.qt>} is a system view" !!)
  =/  work=[database @da schema]
    (view-work-state verb qt next-schemas next-data as-of.d)
  =/  sys-time=@da       +<.work
  =/  nxt-schema=schema  +>.work
  =/  key=[@tas @tas]    [namespace.qt name.qt]
  ?~  (get-view [-.key +.key sys-time] views.nxt-schema)
    ~|("{verb}: {<name.qt>} does not exist in {<namespace.qt>}" !!)
  =/  users=(list [ns-rel-key view])
    (view-dependents views.nxt-schema ~[[%view -.key +.key]])
  ?:  &(?=(^ users) !force.d)
    ~|  "{verb}: {<name.qt>} used in view ".
        "{<ns.-.i.users>}.{<rel.-.i.users>}, use FORCE to DROP"
        !!
  =/  cascaded=(list [@tas @tas])
    (turn users |=([k=ns-rel-key *] [ns.k rel.k]))
  =.  views.nxt-schema
    (remove-user-views views.nxt-schema (silt [key cascaded]))
  =/  srv=server
    (save-view-schema state verb qt nxt-schema sys-time %drop)
  =/  db=database  (~(got by srv) database.qt)
  =.  event-log.db
    %+  weld
      %+  turn  (flop cascaded)
      |=  [ns=@tas rel=@tas]
      ^-  sys-log-event
      (view-event sys-time database.qt ns rel %drop)
    event-log.db
  =.  srv  (~(put by srv) database.qt db)
  =/  messages=(list result:ast)
    %+  turn  cascaded
    |=  [ns=@tas rel=@tas]
    ^-  result:ast
    [%message (crip "dropped view {<ns>}.{<rel>}")]
  :^  :-  %results
          %+  weld
            ^-  (list result:ast)
            :~  [%action (crip "DROP VIEW {<name.qt>}")]
                [%server-time now.bowl]
                [%schema-time sys-time]
                ==
          messages
      (~(put by next-schemas) database.qt sys-time)
      next-data
      srv
::
::  +|  helpers
::
++  view-work-state
  ::  the database, schema time, and next schema of a view command
  |=  $:  verb=tape
          qt=qualified-table:ast
          next-schemas=(map @tas @da)
          next-data=(map @tas @da)
          as-of=(unit as-of:ast)
          ==
  ^-  [database @da schema]
  ?^  ship.qt
    ~|("{verb}: views cannot be defined on foreign ship databases" !!)
  ?:  =(%sys database.qt)
    ~|("{verb}: database %sys has no user views" !!)
  =/  db=database
    ~|  "{verb}: database {<database.qt>} does not exist"
        (~(got by state) database.qt)
  =/  sys-time=@da  (set-tmsp as-of now.bowl)
  =/  nxt-schema=schema
    ~|  "{verb}: {<name.qt>} as-of schema time out of order"
        (get-next-schema sys.db next-schemas sys-time database.qt)
  =/  nxt-data=data
    ~|  "{verb}: {<name.qt>} as-of data time out of order"
        (get-next-data content.db next-data sys-time database.qt)
  ?.  (~(has by namespaces.nxt-schema) namespace.qt)
    ~|("{verb}: namespace {<namespace.qt>} does not exist" !!)
  [db sys-time nxt-schema]
::
++  define-view
  ::  Resolve the references of the query of a view, decide whether the
  ::  view is cacheable, and evaluate the query for its columns.  Produces
  ::  the server, with any view caches the evaluation populated, and the
  ::  view.
  |=  $:  verb=tape
          qt=qualified-table:ast
          =schema
          =crud-txn:ast
          text=@t
          sys-time=@da
          ==
  ^-  [server view]
  ?.  ?=(?(%query %set-query) -.body.crud-txn)
    ~|("{verb}: view query must be a query" !!)
  =/  refs=(list [qualified-table:ast (unit as-of:ast)])
    (crud-txn-relations crud-txn)
  =/  cte-names=(set @tas)
    (silt (turn ctes.crud-txn |=(c=cte:ast name.c)))
  =/  resolved=(list view-reference)
    %+  murn  refs
    |=  [r=qualified-table:ast *]
    ^-  (unit view-reference)
    (resolve-reference verb qt schema sys-time cte-names r)
  =/  references=(list view-reference)  ~(tap in (silt resolved))
  =/  relative=?
    %+  lien  refs
    |=  [* a=(unit as-of:ast)]
    ?~  a  %.n
    ?=(?([%dr *] [%as-of-offset *]) u.a)
  =/  volatile=?
    (crud-txn-has-scalar (silt `(list @tas)`~[%getutcdate %rand]) crud-txn)
  =/  reads-volatile=?
    %+  lien  references
    |=  r=view-reference
    ?.  &(=(%view kind.r) !=(%sys ns.r))  %.n
    =/  vw=(unit view)  (get-view [ns.r rel.r sys-time] views.schema)
    ?~  vw  %.n
    !cacheable.u.vw
  =/  evaluated=[server (list column:ast) (list (map @tas @))]
    %:  view-result(state state, bowl bowl)  database.qt
                                             namespace.qt
                                             name.qt
                                             crud-txn
                                             sys-time
                                             ==
  =/  columns=(list column:ast)  +<.evaluated
  :-  -.evaluated
  :*  %view
      sap.bowl
      sys-time
      crud-txn
      (malt (spun columns mk-col-lu-data))
      (malt (turn columns |=(a=column:ast [name.a [type.a addr.a]])))
      columns
      ~
      ~
      references
      !|(relative volatile reads-volatile)
      text
      ==
::
++  resolve-reference
  ::  A relation read by the query of view qt: a view when one exists,
  ::  except the view's own name, else a table.  ~ for a CTE.
  |=  $:  verb=tape
          qt=qualified-table:ast
          =schema
          sys-time=@da
          cte-names=(set @tas)
          r=qualified-table:ast
          ==
  ^-  (unit view-reference)
  ?^  ship.r
    ~|("{verb}: view references a foreign ship" !!)
  ?.  =(database.r database.qt)
    ~|("{verb}: view references another database {<database.r>}" !!)
  =/  key=[@tas @tas]  [namespace.r name.r]
  =/  self=?  =(key [namespace.qt name.qt])
  =/  vw=(unit view)
    ?:  self  ~
    (get-view [namespace.r name.r sys-time] views.schema)
  ?^  vw  `[%view key]
  ?:  =(%sys namespace.r)
    ~|("{verb}: {<namespace.r>}.{<name.r>} does not exist" !!)
  ?:  (~(has by tables.schema) key)  `[%table key]
  ?:  (~(has in cte-names) name.r)  ~
  ~|("{verb}: {<namespace.r>}.{<name.r>} does not exist" !!)
::
++  save-view-schema
  ::  srv with the next schema of the database of view qt, its event, and
  ::  its system view caches
  |=  $:  srv=server
          verb=tape
          qt=qualified-table:ast
          nxt-schema=schema
          sys-time=@da
          action=?(%create %alter %drop)
          ==
  ^-  server
  =/  db=database  (~(got by srv) database.qt)
  =.  tmsp.nxt-schema        sys-time
  =.  provenance.nxt-schema  sap.bowl
  =.  sys.db  (put:schema-key sys.db sys-time nxt-schema)
  =.  event-log.db
    :-  (view-event sys-time database.qt namespace.qt name.qt action)
        event-log.db
  =/  caller=db-cmd:ast
    ?-  action
      %create  %create-view
      %alter   %alter-view
      %drop    %drop-view
    ==
  =.  view-cache.db  (upd-view-caches srv db sys-time ~ caller)
  (update-sys (~(put by srv) database.qt db) sys-time)
::
++  refresh-view
  ::  srv with an empty cache entry of view qt at time
  |=  [srv=server qt=qualified-table:ast time=@da]
  ^-  server
  =/  db=database  (~(got by srv) database.qt)
  =.  view-cache.db
    (refresh-views view-cache.db time (silt ~[[namespace.qt name.qt]]))
  (~(put by srv) database.qt db)
::
++  view-event
  |=  [time=@da db=@tas ns=@tas rel=@tas action=?(%create %alter %drop)]
  ^-  sys-log-event
  :*  %sys-log-event
      time
      sap.bowl
      action
      %view
      db
      `ns
      `rel
      ~
      ~
      ~
      ~
      ==
--
