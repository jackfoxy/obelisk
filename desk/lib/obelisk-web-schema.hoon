::  Pure schema construction for %obelisk-web.
::
/-  ast=obelisk-ast, web=obelisk-web
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
    %+  turn
      (skim +.command |=(result=result:ast ?=(%result-set -.result)))
    |=  result=result:ast
    ?>  ?=(%result-set -.result)
    +.result
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
  ?^  requested
    ?:  (has-database u.requested databases)  u.requested
    ?:  (has-database %sys databases)  %sys
    ?~(databases %sys i.databases)
  ?:  (has-database %sys databases)  %sys
  ?~(databases %sys i.databases)
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
++  key-for-column
  |=  $:  namespace=@tas
          table=@tas
          column=@tas
          keys=(list key-row)
      ==
  ^-  (unit key-dto:web)
  =/  found=(list key-row)
    %+  skim  keys
    |=  row=key-row
    ?&  =(namespace namespace.row)
        =(table table.row)
        =(column key.row)
    ==
  ?~  found  ~
  `[ordinal.i.found ascending.i.found]
::
++  table-columns
  |=  $:  namespace=@tas
          table=@tas
          keys=(list key-row)
          columns=(list column-row)
      ==
  ^-  (list column-dto:web)
  =/  matching=(list column-row)
    %+  skim  columns
    |=  row=column-row
    ?&  =(namespace namespace.row)
        =(table table.row)
    ==
  =/  result=(list column-dto:web)
    %+  turn  matching
    |=  row=column-row
    :*  column.row
        aura.row
        ordinal.row
        (key-for-column namespace table column.row keys)
    ==
  (sort result column-lte)
::
++  table-relations
  |=  $:  database=@tas
          namespace=@tas
          tables=(list table-row)
          keys=(list key-row)
          columns=(list column-row)
      ==
  ^-  (list relation-dto:web)
  =/  matching=(list table-row)
    (skim tables |=(row=table-row =(namespace namespace.row)))
  %+  turn  matching
  |=  row=table-row
  :*  database
      namespace
      name.row
      %table
      (table-columns namespace name.row keys columns)
  ==
::
++  make-column
  |=  [ordinal=@ud name=@tas aura=@ta]
  ^-  column-dto:web
  [name aura ordinal ~]
::
++  make-view
  |=  $:  database=@tas
          name=@tas
          columns=(list column-dto:web)
      ==
  ^-  relation-dto:web
  [database %sys name %view columns]
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
          tables=(list table-row)
          keys=(list key-row)
          columns=(list column-row)
      ==
  ^-  (list namespace-dto:web)
  %+  turn  namespaces
  |=  namespace=@tas
  =/  views=(list relation-dto:web)
    ?:(=(%sys namespace) (system-views database) ~)
  =/  relations=(list relation-dto:web)
    %+  weld  views
    (table-relations database namespace tables keys columns)
  [namespace (sort relations relation-lte)]
::
++  database-dto
  |=  $:  database=@tas
          default-database=@tas
          namespaces=(list @tas)
          tables=(list table-row)
          keys=(list key-row)
          columns=(list column-row)
      ==
  ^-  database-dto:web
  ?:  =(%sys database)
    :*  %sys
        =(%sys default-database)
        ~[[%sys ~[(databases-view %sys)]]]
    ==
  :*  database
      =(database default-database)
      (namespace-dtos database namespaces tables keys columns)
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
    `[(database-dto %sys default-database ~ ~ ~ ~) u.rest]
  ?~  commands  ~
  =/  namespace-command=cmd-result:ast  i.commands
  =/  after-namespace=(list cmd-result:ast)  t.commands
  ?~  after-namespace  ~
  =/  table-command=cmd-result:ast  i.after-namespace
  =/  after-table=(list cmd-result:ast)  t.after-namespace
  ?~  after-table  ~
  =/  key-command=cmd-result:ast  i.after-table
  =/  after-key=(list cmd-result:ast)  t.after-table
  ?~  after-key  ~
  =/  column-command=cmd-result:ast  i.after-key
  =/  remaining=(list cmd-result:ast)  t.after-key
  =/  namespaces-vectors=(unit (list vector:ast))
    (command-vectors namespace-command)
  =/  tables-vectors=(unit (list vector:ast))
    (command-vectors table-command)
  =/  keys-vectors=(unit (list vector:ast))
    (command-vectors key-command)
  =/  columns-vectors=(unit (list vector:ast))
    (command-vectors column-command)
  ?~  namespaces-vectors  ~
  ?~  tables-vectors  ~
  ?~  keys-vectors  ~
  ?~  columns-vectors  ~
  =/  namespaces=(unit (list @tas))
    (namespace-rows u.namespaces-vectors)
  =/  tables=(unit (list table-row))  (table-rows u.tables-vectors)
  =/  keys=(unit (list key-row))  (key-rows u.keys-vectors)
  =/  columns=(unit (list column-row))
    (column-rows u.columns-vectors)
  ?~  namespaces  ~
  ?~  tables  ~
  ?~  keys  ~
  ?~  columns  ~
  =/  rest=(unit (list database-dto:web))
    $(databases t.databases, commands remaining)
  ?~  rest  ~
  =/  node=database-dto:web
    %:  database-dto
      i.databases
      default-database
      u.namespaces
      u.tables
      u.keys
      u.columns
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
++  schema-changing-command
  |=  command=command:ast
  ^-  ?
  ?-  -.command
    %alter-database  %.y
    %alter-index  %.y
    %alter-namespace  %.y
    %alter-table  %.y
    %create-database  %.y
    %create-index  %.y
    %create-namespace  %.y
    %create-table  %.y
    %create-view  %.y
    %drop-database  %.y
    %drop-index  %.y
    %drop-namespace  %.y
    %drop-table  %.y
    %drop-view  %.y
    %grant  %.n
    %revoke  %.n
    %crud-txn  %.n
    %truncate-table  %.n
  ==
::
++  schema-changing
  |=  commands=(list command:ast)
  ^-  ?
  ?=(^ (skim commands schema-changing-command))
--
