::  Pure schema construction for %obelisk-web.
::
/-  ast=obelisk-ast, web=obelisk-web
/+  format
|%
::
::  +|  System View Rows
::
+$  table-row
  [namespace=@tas name=@tas]
::
+$  key-row
  $:  namespace=@tas
      table=@tas
      ordinal=@ud
      key=@tas
      ascending=?
  ==
::
+$  column-row
  $:  namespace=@tas
      table=@tas
      ordinal=@ud
      column=@tas
      aura=@ta
  ==
+$  foreign-key-row
  $:  parent-namespace=@tas
      parent-table=@tas
      child-namespace=@tas
      child-table=@tas
      ordinal=@ud
      parent-column=@tas
      child-column=@tas
      on-delete=@tas
      on-update=@tas
  ==
+$  relation-key  [namespace=@tas table=@tas]
+$  column-key  [namespace=@tas table=@tas column=@tas]
+$  table-index  (jar @tas table-row)
+$  column-index  (jar relation-key column-row)
+$  key-index  (map column-key key-dto:web)
+$  foreign-key-index  (jar relation-key foreign-key-dto:web)
::
::  +|  Queries
::
++  databases-query
  ^-  tape
  "FROM sys.sys.databases SELECT database;"
::
++  namespaces-query
  |=  database=@tas
  ^-  tape
  %+  weld  "FROM "
  %+  weld  (trip database)
  ".sys.namespaces SELECT namespace;"
::
++  tables-query
  |=  database=@tas
  ^-  tape
  %+  weld  "FROM "
  %+  weld  (trip database)
  ".sys.tables SELECT namespace, name;"
::
++  keys-query
  |=  database=@tas
  ^-  tape
  %+  weld  "FROM "
  %+  weld  (trip database)
  ".sys.table-keys SELECT namespace, name, key-ordinal, key, ".
  "key-ascending;"
::
++  columns-query
  |=  database=@tas
  ^-  tape
  %+  weld  "FROM "
  %+  weld  (trip database)
  ".sys.columns SELECT namespace, name, col-ordinal, col-name, col-type;"
::
++  foreign-keys-query
  |=  database=@tas
  ^-  tape
  %+  weld  "FROM "
  %+  weld  (trip database)
  ".sys.foreign-keys SELECT parent-namespace, parent-table, ".
  "child-namespace, child-table, ordinal, parent-column, child-column, ".
  "on-delete, on-update;"
::
++  detail-script
  |=  databases=(list @tas)
  ^-  tape
  ?~  databases  ""
  ?:  =(%sys i.databases)
    $(databases t.databases)
  %+  weld  (namespaces-query i.databases)
  %+  weld  (tables-query i.databases)
  %+  weld  (keys-query i.databases)
  %+  weld  (columns-query i.databases)
  %+  weld  (foreign-keys-query i.databases)
  $(databases t.databases)
::
::  +|  Typed Vector Decoding
::
++  vector-dime
  |=  [name=@tas vector=vector:ast]
  ^-  (unit dime)
  =/  cells=(list vector-cell:ast)  +.vector
  |-
  ?~  cells  ~
  ?:  =(name p.i.cells)  `q.i.cells
  $(cells t.cells)
::
++  vector-tas
  |=  [name=@tas vector=vector:ast]
  ^-  (unit @tas)
  =/  value=(unit dime)  (vector-dime name vector)
  ?~  value  ~
  ?.  =(%tas p.u.value)  ~
  ``@tas`q.u.value
::
++  vector-ta
  |=  [name=@tas vector=vector:ast]
  ^-  (unit @ta)
  =/  value=(unit dime)  (vector-dime name vector)
  ?~  value  ~
  ?.  =(%ta p.u.value)  ~
  ``@ta`q.u.value
::
++  vector-ud
  |=  [name=@tas vector=vector:ast]
  ^-  (unit @ud)
  =/  value=(unit dime)  (vector-dime name vector)
  ?~  value  ~
  ?.  =(%ud p.u.value)  ~
  ``@ud`q.u.value
::
++  vector-flag
  |=  [name=@tas vector=vector:ast]
  ^-  (unit ?)
  =/  value=(unit dime)  (vector-dime name vector)
  ?~  value  ~
  ?.  =(%f p.u.value)  ~
  `=(0 q.u.value)
::
++  command-vectors
  |=  command=cmd-result:ast
  ^-  (unit (list vector:ast))
  =/  sets=(list (list vector:ast))
    %+  murn  +.command
    |=  result=result:ast
    ^-  (unit (list vector:ast))
    ?.  ?=(%result-set -.result)  ~
    `+.result
  ?~  sets  ~
  ?.  ?=(~ t.sets)  ~
  `i.sets
::
++  database-names
  |=  commands=(list cmd-result:ast)
  ^-  (unit (list @tas))
  ?~  commands  ~
  ?.  ?=(~ t.commands)  ~
  =/  vectors=(unit (list vector:ast))  (command-vectors i.commands)
  ?~  vectors  ~
  =/  names=(list @tas)  ~
  =/  remaining=(list vector:ast)  u.vectors
  |-
  ?~  remaining
    `(sort names aor)
  =/  name=(unit @tas)  (vector-tas %database i.remaining)
  ?~  name  ~
  $(names [u.name names], remaining t.remaining)
::
++  namespace-rows
  |=  vectors=(list vector:ast)
  ^-  (unit (list @tas))
  =/  rows=(list @tas)  ~
  |-
  ?~  vectors  `(sort rows aor)
  =/  namespace=(unit @tas)  (vector-tas %namespace i.vectors)
  ?~  namespace  ~
  $(vectors t.vectors, rows [u.namespace rows])
::
++  table-rows
  |=  vectors=(list vector:ast)
  ^-  (unit (list table-row))
  =/  rows=(list table-row)  ~
  |-
  ?~  vectors  `rows
  =/  namespace=(unit @tas)  (vector-tas %namespace i.vectors)
  =/  name=(unit @tas)  (vector-tas %name i.vectors)
  ?~  namespace  ~
  ?~  name  ~
  $(vectors t.vectors, rows [[u.namespace u.name] rows])
::
++  key-rows
  |=  vectors=(list vector:ast)
  ^-  (unit (list key-row))
  =/  rows=(list key-row)  ~
  |-
  ?~  vectors  `rows
  =/  namespace=(unit @tas)  (vector-tas %namespace i.vectors)
  =/  table=(unit @tas)  (vector-tas %name i.vectors)
  =/  ordinal=(unit @ud)  (vector-ud %key-ordinal i.vectors)
  =/  key=(unit @tas)  (vector-tas %key i.vectors)
  =/  ascending=(unit ?)  (vector-flag %key-ascending i.vectors)
  ?~  namespace  ~
  ?~  table  ~
  ?~  ordinal  ~
  ?~  key  ~
  ?~  ascending  ~
  =/  row=key-row
    [u.namespace u.table u.ordinal u.key u.ascending]
  $(vectors t.vectors, rows [row rows])
::
++  column-rows
  |=  vectors=(list vector:ast)
  ^-  (unit (list column-row))
  =/  rows=(list column-row)  ~
  |-
  ?~  vectors  `rows
  =/  namespace=(unit @tas)  (vector-tas %namespace i.vectors)
  =/  table=(unit @tas)  (vector-tas %name i.vectors)
  =/  ordinal=(unit @ud)  (vector-ud %col-ordinal i.vectors)
  =/  column=(unit @tas)  (vector-tas %col-name i.vectors)
  =/  aura=(unit @ta)  (vector-ta %col-type i.vectors)
  ?~  namespace  ~
  ?~  table  ~
  ?~  ordinal  ~
  ?~  column  ~
  ?~  aura  ~
  =/  row=column-row
    [u.namespace u.table u.ordinal u.column u.aura]
  $(vectors t.vectors, rows [row rows])
::
++  foreign-key-rows
  |=  vectors=(list vector:ast)
  ^-  (unit (list foreign-key-row))
  =/  rows=(list foreign-key-row)  ~
  |-
  ?~  vectors  `rows
  =/  parent-namespace=(unit @tas)
    (vector-tas %parent-namespace i.vectors)
  =/  parent-table=(unit @tas)  (vector-tas %parent-table i.vectors)
  =/  child-namespace=(unit @tas)
    (vector-tas %child-namespace i.vectors)
  =/  child-table=(unit @tas)  (vector-tas %child-table i.vectors)
  =/  ordinal=(unit @ud)  (vector-ud %ordinal i.vectors)
  =/  parent-column=(unit @tas)  (vector-tas %parent-column i.vectors)
  =/  child-column=(unit @tas)  (vector-tas %child-column i.vectors)
  =/  on-delete=(unit @tas)  (vector-tas %on-delete i.vectors)
  =/  on-update=(unit @tas)  (vector-tas %on-update i.vectors)
  ?~  parent-namespace  ~
  ?~  parent-table  ~
  ?~  child-namespace  ~
  ?~  child-table  ~
  ?~  ordinal  ~
  ?~  parent-column  ~
  ?~  child-column  ~
  ?~  on-delete  ~
  ?~  on-update  ~
  =/  row=foreign-key-row
    :*  u.parent-namespace
        u.parent-table
        u.child-namespace
        u.child-table
        u.ordinal
        u.parent-column
        u.child-column
        u.on-delete
        u.on-update
    ==
  $(vectors t.vectors, rows [row rows])
::
::  +|  Schema Construction
::
++  has-database
  |=  [name=@tas databases=(list @tas)]
  ^-  ?
  (lien databases |=(database=@tas =(name database)))
::
++  default-database
  |=  [requested=(unit @tas) databases=(list @tas)]
  ^-  @tas
  =/  user-databases=(list @tas)
    (skim databases |=(database=@tas !=(%sys database)))
  =/  fallback=@tas
    ?^  user-databases  i.user-databases
    ?:  (has-database %sys databases)  %sys
    ?~(databases %sys i.databases)
  ?~  requested  fallback
  ?:((has-database u.requested databases) u.requested fallback)
::
++  column-lte
  |=  [a=column-dto:web b=column-dto:web]
  ^-  ?
  ?:  =(ordinal.a ordinal.b)  (aor name.a name.b)
  (lth ordinal.a ordinal.b)
::
++  relation-lte
  |=  [a=relation-dto:web b=relation-dto:web]
  ^-  ?
  ?:  =(name.a name.b)  (aor kind.a kind.b)
  (aor name.a name.b)
::
++  foreign-key-lte
  |=  [a=foreign-key-dto:web b=foreign-key-dto:web]
  ^-  ?
  ?.  =(parent-namespace.a parent-namespace.b)
    (aor parent-namespace.a parent-namespace.b)
  ?.  =(parent-table.a parent-table.b)
    (aor parent-table.a parent-table.b)
  ?.  =(ordinal.a ordinal.b)  (lth ordinal.a ordinal.b)
  ?.  =(parent-column.a parent-column.b)
    (aor parent-column.a parent-column.b)
  (aor child-column.a child-column.b)
::
++  index-tables
  |=  rows=(list table-row)
  ^-  table-index
  %+  roll  rows
  |=  [row=table-row index=table-index]
  (~(add ja index) namespace.row row)
::
++  index-columns
  |=  rows=(list column-row)
  ^-  column-index
  %+  roll  rows
  |=  [row=column-row index=column-index]
  (~(add ja index) [namespace.row table.row] row)
::
++  index-keys
  |=  rows=(list key-row)
  ^-  key-index
  %+  roll  rows
  |=  [row=key-row index=key-index]
  %+  ~(put by index)
    [namespace.row table.row key.row]
  [ordinal.row ascending.row]
::
++  index-foreign-keys
  |=  rows=(list foreign-key-row)
  ^-  foreign-key-index
  %+  roll  rows
  |=  [row=foreign-key-row index=foreign-key-index]
  =/  value=foreign-key-dto:web
    :*  parent-namespace.row
        parent-table.row
        ordinal.row
        parent-column.row
        child-column.row
        on-delete.row
        on-update.row
    ==
  (~(add ja index) [child-namespace.row child-table.row] value)
::
++  column-bunt
  |=  aura=@ta
  ^-  @t
  ?:  =("da" (scag 2 (trip aura)))  '~2000.1.1'
  (crip (render-dime:format [aura 0]))
::
++  table-columns
  |=  $:  namespace=@tas
          table=@tas
          keys=key-index
          columns=column-index
      ==
  ^-  (list column-dto:web)
  =/  matching=(list column-row)  (~(get ja columns) [namespace table])
  =/  result=(list column-dto:web)
    %+  turn  matching
    |=  row=column-row
    :*  column.row
        aura.row
        (column-bunt aura.row)
        ordinal.row
        (~(get by keys) [namespace table column.row])
    ==
  (sort result column-lte)
::
++  table-relations
  |=  $:  database=@tas
          namespace=@tas
          tables=table-index
          keys=key-index
          columns=column-index
          foreign-keys=foreign-key-index
      ==
  ^-  (list relation-dto:web)
  =/  matching=(list table-row)  (~(get ja tables) namespace)
  %+  turn  matching
  |=  row=table-row
  :*  database
      namespace
      name.row
      %table
      (table-columns namespace name.row keys columns)
      %+  sort
        (~(get ja foreign-keys) [namespace name.row])
      foreign-key-lte
  ==
::
++  make-column
  |=  [ordinal=@ud name=@tas aura=@ta]
  ^-  column-dto:web
  [name aura (column-bunt aura) ordinal ~]
::
++  make-view
  |=  $:  database=@tas
          name=@tas
          columns=(list column-dto:web)
      ==
  ^-  relation-dto:web
  [database %sys name %view columns ~]
::
++  databases-view
  |=  database=@tas
  ^-  relation-dto:web
  %^  make-view  database  %databases
  :~  (make-column 1 %database %tas)
      (make-column 2 %sys-agent %ta)
      (make-column 3 %sys-tmsp %da)
      (make-column 4 %data-ship %p)
      (make-column 5 %data-agent %ta)
      (make-column 6 %data-tmsp %da)
  ==
::
++  system-views
  |=  database=@tas
  ^-  (list relation-dto:web)
  :~  %^  make-view  database  %namespaces
      :~  (make-column 1 %namespace %tas)
          (make-column 2 %tmsp %da)
      ==
      %^  make-view  database  %tables
      :~  (make-column 1 %namespace %tas)
          (make-column 2 %name %tas)
          (make-column 3 %agent %ta)
          (make-column 4 %tmsp %da)
          (make-column 5 %row-count %ud)
      ==
      %^  make-view  database  %table-keys
      :~  (make-column 1 %namespace %tas)
          (make-column 2 %name %tas)
          (make-column 3 %key-ordinal %ud)
          (make-column 4 %key %tas)
          (make-column 5 %key-ascending %f)
      ==
      %^  make-view  database  %foreign-keys
      :~  (make-column 1 %parent-namespace %tas)
          (make-column 2 %parent-table %tas)
          (make-column 3 %child-namespace %tas)
          (make-column 4 %child-table %tas)
          (make-column 5 %ordinal %ud)
          (make-column 6 %parent-column %tas)
          (make-column 7 %child-column %tas)
          (make-column 8 %on-delete %tas)
          (make-column 9 %on-update %tas)
      ==
      %^  make-view  database  %columns
      :~  (make-column 1 %namespace %tas)
          (make-column 2 %name %tas)
          (make-column 3 %col-ordinal %ud)
          (make-column 4 %col-name %tas)
          (make-column 5 %col-type %ta)
      ==
      %^  make-view  database  %sys-log
      :~  (make-column 1 %tmsp %da)
          (make-column 2 %agent %ta)
          (make-column 3 %action %tas)
          (make-column 4 %component %tas)
          (make-column 5 %database %t)
          (make-column 6 %namespace %t)
          (make-column 7 %relation-id %tas)
          (make-column 8 %target-database %t)
          (make-column 9 %target-namespace %t)
          (make-column 10 %target-relation %t)
          (make-column 11 %message %t)
      ==
      %^  make-view  database  %data-log
      :~  (make-column 1 %tmsp %da)
          (make-column 2 %ship %p)
          (make-column 3 %agent %ta)
          (make-column 4 %namespace %tas)
          (make-column 5 %table %tas)
          (make-column 6 %row-count %ud)
      ==
  ==
::
++  namespace-dtos
  |=  $:  database=@tas
          namespaces=(list @tas)
          tables=table-index
          keys=key-index
          columns=column-index
          foreign-keys=foreign-key-index
      ==
  ^-  (list namespace-dto:web)
  %+  turn  namespaces
  |=  namespace=@tas
  =/  views=(list relation-dto:web)
    ?:(=(%sys namespace) (system-views database) ~)
  =/  relations=(list relation-dto:web)
    %+  weld  views
    (table-relations database namespace tables keys columns foreign-keys)
  [namespace (sort relations relation-lte)]
::
++  database-dto
  |=  $:  database=@tas
          default-database=@tas
          namespaces=(list @tas)
          tables=table-index
          keys=key-index
          columns=column-index
          foreign-keys=foreign-key-index
      ==
  ^-  database-dto:web
  ?:  =(%sys database)
    :*  %sys
        =(%sys default-database)
        ~[[%sys ~[(databases-view %sys)]]]
    ==
  :*  database
      =(database default-database)
      (namespace-dtos database namespaces tables keys columns foreign-keys)
  ==
::
++  build-databases
  |=  $:  databases=(list @tas)
          default-database=@tas
          commands=(list cmd-result:ast)
      ==
  ^-  (unit (list database-dto:web))
  ?~  databases
    ?~(commands `~ ~)
  ?:  =(%sys i.databases)
    =/  rest=(unit (list database-dto:web))
      $(databases t.databases)
    ?~  rest  ~
    =/  system=database-dto:web
      %:  database-dto
        %sys
        default-database
        ~
        *table-index
        *key-index
        *column-index
        *foreign-key-index
      ==
    `[system u.rest]
  ::  Each non-sys database contributes five result sets, in query order.
  ::
  ?.  ?=([* * * * * *] commands)  ~
  =/  namespaces-vectors=(unit (list vector:ast))
    (command-vectors i.commands)
  =/  tables-vectors=(unit (list vector:ast))
    (command-vectors i.t.commands)
  =/  keys-vectors=(unit (list vector:ast))
    (command-vectors i.t.t.commands)
  =/  columns-vectors=(unit (list vector:ast))
    (command-vectors i.t.t.t.commands)
  =/  foreign-key-vectors=(unit (list vector:ast))
    (command-vectors i.t.t.t.t.commands)
  ?~  namespaces-vectors  ~
  ?~  tables-vectors  ~
  ?~  keys-vectors  ~
  ?~  columns-vectors  ~
  ?~  foreign-key-vectors  ~
  =/  namespaces=(unit (list @tas))
    (namespace-rows u.namespaces-vectors)
  =/  tables=(unit (list table-row))  (table-rows u.tables-vectors)
  =/  keys=(unit (list key-row))  (key-rows u.keys-vectors)
  =/  columns=(unit (list column-row))
    (column-rows u.columns-vectors)
  =/  foreign-keys=(unit (list foreign-key-row))
    (foreign-key-rows u.foreign-key-vectors)
  ?~  namespaces  ~
  ?~  tables  ~
  ?~  keys  ~
  ?~  columns  ~
  ?~  foreign-keys  ~
  =/  rest=(unit (list database-dto:web))
    $(databases t.databases, commands t.t.t.t.t.commands)
  ?~  rest  ~
  =/  node=database-dto:web
    %:  database-dto
      i.databases
      default-database
      u.namespaces
      (index-tables u.tables)
      (index-keys u.keys)
      (index-columns u.columns)
      (index-foreign-keys u.foreign-keys)
    ==
  `[node u.rest]
::
++  schema-response
  |=  $:  requested=(unit @tas)
          databases=(list @tas)
          commands=(list cmd-result:ast)
      ==
  ^-  (unit web-response:web)
  =/  default=@tas  (default-database requested databases)
  =/  values=(unit (list database-dto:web))
    (build-databases databases default commands)
  ?~  values  ~
  `[%schema [default u.values]]
::
::  +|  Schema Mutation Detection
::
++  schema-changing
  ::  Only DDL invalidates the schema the browser has cached.
  ::
  |=  commands=(list command:ast)
  ^-  ?
  %+  lien  commands
  |=  command=command:ast
  ?-  -.command
    ?(%grant %revoke %crud-txn %truncate-table)  %.n
    ?(%alter-database %alter-index %alter-namespace %alter-table)  %.y
    ?(%create-database %create-index %create-namespace)  %.y
    ?(%create-table %create-view)  %.y
    ?(%drop-database %drop-index %drop-namespace)  %.y
    ?(%drop-table %drop-view)  %.y
  ==
--
