::  Unit tests for indexed %obelisk-web schema construction.
::
/-  web=obelisk-web
/+  json-lib=obelisk-web-json, schema-lib=obelisk-web-schema, *test
|%
::
++  scale-schema-rows
  |=  count=@ud
  ^-  $:  tables=(list table-row:schema-lib)
          keys=(list key-row:schema-lib)
          columns=(list column-row:schema-lib)
      ==
  =/  tables=(list table-row:schema-lib)  ~
  =/  keys=(list key-row:schema-lib)  ~
  =/  columns=(list column-row:schema-lib)  ~
  |-
  ?:  =(count 0)  [tables keys columns]
  =/  index=@ud  (dec count)
  =/  table=@tas
    (term-text:json-lib (cat 3 'table-' (scot %ud index)))
  %=  $
    count    index
    tables   [[%public table] tables]
    keys     [[%public table 1 %id %.y] keys]
    columns  [[%public table 1 %id %ud] columns]
  ==
::
++  test-schema-index-scale-00
  =/  rows  (scale-schema-rows 256)
  =/  database=database-dto:web
    %:  database-dto:schema-lib
      %alpha
      %alpha
      ~[%public]
      (index-tables:schema-lib tables.rows)
      (index-keys:schema-lib keys.rows)
      (index-columns:schema-lib columns.rows)
      *foreign-key-index:schema-lib
    ==
  ?>  ?=(^ namespaces.database)
  =/  namespace=namespace-dto:web  i.namespaces.database
  =/  valid=?
    %+  levy  relations.namespace
    |=  relation=relation-dto:web
    ?~  columns.relation  %.n
    ?&  =(1 (lent columns.relation))
        ?=(^ key.i.columns.relation)
    ==
  ;:  weld
    (expect-eq !>(256) !>((lent relations.namespace)))
    (expect !>(valid))
  ==
::
++  test-schema-foreign-key-index-01
  =/  foreign-key=foreign-key-row:schema-lib
    :*  %public
        %parents
        %public
        %children
        1
        %id
        %parent-id
        %restrict
        %cascade
    ==
  =/  database=database-dto:web
    %:  database-dto:schema-lib
      %alpha
      %alpha
      ~[%public]
      (index-tables:schema-lib ~[[%public %children]])
      *key-index:schema-lib
      (index-columns:schema-lib ~[[%public %children 1 %parent-id %ud]])
      (index-foreign-keys:schema-lib ~[foreign-key])
    ==
  ?>  ?=(^ namespaces.database)
  =/  namespace=namespace-dto:web  i.namespaces.database
  ?>  ?=(^ relations.namespace)
  =/  relation=relation-dto:web  i.relations.namespace
  ?>  ?=(^ foreign-keys.relation)
  =/  actual=foreign-key-dto:web  i.foreign-keys.relation
  %+  expect-eq
    !>  :*  parent-namespace=%public
            parent-table=%parents
            ordinal=1
            parent-column=%id
            child-column=%parent-id
            on-delete=%restrict
            on-update=%cascade
        ==
  !>(actual)
--
