::  Unit tests for current-state Obelisk migrations.
::
/-  *server-state-1
/+  *migration, *sys-views, *test, *utils
|%
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
        %-  apply-ordering
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
--
