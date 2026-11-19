::  Unit tests for current-state Obelisk migrations.
::
/-  *server-state-2
/+  *migration, *sys-views, *test, *test-helpers, *utils
/=  agent  /app/obelisk
|%
::
::  agent state, as +on-save gives it
+$  agent-state  [%3 =server]
::
++  fixture-path
  ^-  path
  `path`/migration-test
::
++  schema-fixture
  |=  [database=@tas time=@da has-foreign-keys=?]
  ^-  schema
  =/  values=(list [ns-rel-key view])
    ?:  has-foreign-keys
      =/  view=view
        (sys-foreign-keys-view database fixture-path time)
      ~[[[%sys %foreign-keys time] view]]
    ~
  :*  %schema
      fixture-path
      time
      (my ~[[%sys time] [%dbo time]])
      *tables
      (gas:view-key *views values)
  ==
::
++  database-fixture
  |=  [name=@tas time=@da has-foreign-keys=?]
  ^-  database
  =/  snapshot=schema  (schema-fixture name time has-foreign-keys)
  =/  cache-values=(list [ns-rel-key cache])
    ?:(has-foreign-keys ~[[[%sys %foreign-keys time] [%cache time ~]]] ~)
  :*  %database
      name
      fixture-path
      time
      (gas:schema-key *((mop @da schema) gth) ~[[time snapshot]])
      *((mop @da data) gth)
      (gas:view-cache-key *view-cache cache-values)
      ~
  ==
::
++  only-schema
  |=  db=database
  ^-  schema
  =/  snapshots=(list [@da schema])  (tap:schema-key sys.db)
  ?~  snapshots  !!
  +.i.snapshots
::
++  test-adds-only-missing-foreign-key-views-00
  =/  legacy  (database-fixture %legacy ~2026.8.10 %.n)
  =/  modern  (database-fixture %modern ~2026.8.11 %.y)
  =/  system  (database-fixture %sys ~2026.8.9 %.n)
  =/  before=server  (my ~[[%legacy legacy] [%modern modern] [%sys system]])
  =/  after=server  (migrate-server-1-to-2 before)
  =/  legacy-after=database  (~(got by after) %legacy)
  =/  modern-after=database  (~(got by after) %modern)
  =/  system-after=database  (~(got by after) %sys)
  =/  legacy-schema=schema  (only-schema legacy-after)
  =/  cache-keys=(list [ns-rel-key cache])
    (tap:view-cache-key view-cache.legacy-after)
  ;:  weld
    (expect !>((has-foreign-keys-view legacy-schema)))
    (expect-eq !>(1) !>((lent cache-keys)))
    (expect-eq !>(modern) !>(modern-after))
    (expect-eq !>(system) !>(system-after))
    (expect-eq !>(after) !>((migrate-server-1-to-2 after)))
  ==
::
::  key a @sx ascending, b @rs descending: both ordered by atom value
::  before state 3, so negative values sorted after positive ones
++  key-order-uql
  "CREATE DATABASE db1; ".
  "CREATE TABLE db1..k (a @sx, b @rs, c @ud) PRIMARY KEY (a, b DESC); ".
  "INSERT INTO db1..k VALUES (-0x1, .1, 1) (--0x1, .-2, 2) ".
  "(-0x1, .-1, 3) (--0x0, .0.5, 4);"
::
++  latest-file
  |=  [db=database key=[@tas @tas]]
  ^-  file
  =/  latest=(unit [@da data])  (pry:data-key content.db)
  ?~  latest  !!
  (~(got by files.+.u.latest) key)
::
++  legacy-order
  ::  db with each file's rows reversed and its index dropped, out of key
  ::  order as an index ordered by atom value leaves signed and float keys
  |=  db=database
  ^-  database
  =/  snapshots=(list [@da data])
    %+  turn  (tap:data-key content.db)
    |=  [time=@da d=data]
    ^-  [@da data]
    :-  time
    %=  d
        files
      %-  ~(run by files.d)
      |=(f=file f(pri-idx ~, indexed-rows (flop indexed-rows.f)))
    ==
  db(content (gas:data-key *((mop @da data) gth) snapshots))
::
++  test-reorders-numeric-keys-00
  =/  ag  (exec-agent agent 0 ~2012.4.30 %sys key-order-uql)
  =/  current=server  server:!<(agent-state on-save:ag)
  =/  legacy=server
    (~(put by current) %db1 (legacy-order (~(got by current) %db1)))
  =/  migrated=server  (migrate-server-2-to-3 legacy)
  =/  keys=(list (list @))
    %+  turn  indexed-rows:(latest-file (~(got by migrated) %db1) [%dbo %k])
    |=(row=indexed-row key.row)
  ;:  weld
    %+  expect-eq
      !>  `(list (list @))`~[~[-0x1 .1] ~[-0x1 .-1] ~[--0x0 .0.5] ~[--0x1 .-2]]
      !>  keys
    (expect-eq !>(current) !>(migrated))
    (expect-eq !>(migrated) !>((migrate-server-2-to-3 migrated)))
  ==
--
