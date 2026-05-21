/-  ast=obelisk-ast
/+  *strandio, *hawk
|=  [the-card=card the-file=file here=path origin=(unit path)]
^-  load
=/  f  ~(. fu the-file)
=/  c  ~(. iu the-card)
=/  d  (d:f /)
=/  m  (m:f /)
::
:: obelisk-ui
::   A user interface for Obelisk.
::   [protocol: hawk-500]
::
::  Technical overview:
::
::    This template is a Hawk %shed that renders a single-page Obelisk
::    workbench.  The top-level route switch handles four request shapes:
::    the initial render, default database changes, query execution, and
::    parse-only execution.  UI state that should survive pokes is carried
::    through form fields and htmx request parameters, then parsed back out
::    of the incoming card.
::
::    Query and parse actions communicate with the %obelisk agent by opening
::    a /server watch on an action-specific wire, poking an obelisk-action
::    cage, reading one fact from that wire, and then consuming the matching
::    kick.  Query facts are decoded as (each (list cmd-result:ast) tang).
::    Parse facts are decoded as (each (list command:ast) tang).  The
::    response molds live in /sur/obelisk-ast and are imported as ast.
::
::    The schema tree is rebuilt from SELECT queries against the system views.
::    The sys database exposes sys.databases.  Every other database gets its
::    system views under that database's sys namespace, and those views are
::    combined with namespace, relation, key, and column rows to build the
::    schema tree.  Successful CREATE/DROP DATABASE commands update the
::    database list locally.  Successful CREATE/DROP NAMESPACE commands update
::    only the affected database node, and successful CREATE/DROP TABLE
::    commands update only the affected namespace node.  These local updates
::    preserve unrelated expanded/collapsed state, while expanding the parent
::    database or namespace nodes needed to show the changed object.
::
::    The default database dropdown is rendered from the current schema tree.
::    Its entries are sorted, preserve the selected database across schema
::    refreshes, fall back to sys when the selected database disappears, and
::    switch to a newly created database after CREATE DATABASE succeeds.
::
::    Result sets are rendered with hidden export data alongside the visible
::    tabs.  Save Results serializes every rendered result set in DOM order
::    with the chosen delimiter and a blank line between result sets, so
::    multi-command scripts can be saved as one text file.
::
::  Keybindings:
::
::    F5          - run the query
::
::
:-  %shed
|^
  ::::::::::::::::::::::::::::::::::::::
  ::  agent
  ::
  ::
  ::
  =/  m  (strand ,vase)
  ;<  our=@p  bind:m  get-our
  ;<  now=@da  bind:m  get-time
  ;<  has=?    bind:m  (check-for-file [our %obelisk da+now] /sys/kelvin)
  ?.  has  (pure:m !>(;/("obelisk not installed")))
  ?+  (rib:c /)
      ::
      %:  print
        parse-query
        parse-results
        parse-default-db
      ==
      ::
    [* %set-default-db]
      %:  print
        parse-query
        parse-results
        ?~(r=(reb:c /default-db) ~ `q.u.r)
      ==
      ::
    [* %query]
      =/  full-query  (pib:c /query-text)
      =/  selected-query  (pib:c /selected-query-text)
      =/  query
        ?^  selected-query  selected-query
        full-query
      ;<  res=poke-result  bind:m  (query-obelisk %$ query)
      %:  print
        full-query
        (print-poke-result res)
        parse-default-db
      ==
      ::
    [* %parse]
      =/  full-query  (pib:c /query-text)
      =/  selected-query  (pib:c /selected-query-text)
      =/  query
        ?^  selected-query  selected-query
        full-query
      ;<  res=parse-output  bind:m  (parse-obelisk %$ query)
      %:  print
        full-query
        (print-parse-output res)
        parse-default-db
      ==
    ::
  ==
::
::
++  query-obelisk
  |=  [id=@ta query=tape]
  =/  m  (strand ,poke-result)
  ^-  form:m
  ;<  response=vase  bind:m  (call-obelisk id %tape query)
  |=  tin=strand-input:strand
  ?~  res=(mole |.((poke-result +:response)))
    `[%fail [%malformed-obelisk-response ~]]
  `[%done u.res]
::
::  parse returns [%& (list command:ast)] or [%| tang] on /server.
++  parse-obelisk
  |=  [id=@ta query=tape]
  =/  m  (strand ,parse-output)
  ^-  form:m
  ;<  response=vase  bind:m  (call-obelisk id %parse query)
  |=  tin=strand-input:strand
  ?~  res=(mole |.((parse-result +:response)))
    `[%fail [%malformed-obelisk-response ~]]
  ?-  -.u.res
    %.n  `[%done [%.n p.u.res]]
    %.y  `[%done [%.y p.u.res]]
  ==
::
++  call-obelisk
  |=  [id=@ta kind=?(%tape %parse) query=tape]
  =/  m  (strand ,vase)
  ^-  form:m
  ;<  our=@p  bind:m  get-our
  =/  dock  [our %obelisk]
  =/  default  (fall parse-default-db %sys)
  =/  action  ;;(action:ast [kind default query])
  =/  command=cage  obelisk-action/!>(action)
  =/  wire=path
    ?-  kind
      %tape  /query/[id]
      %parse  /parse/[id]
    ==
  ;<  ~  bind:m  (watch wire dock /server)
  ;<  ~  bind:m  (poke dock command)
  ;<  [mark =vase]  bind:m  (take-fact wire)
  ;<  ~  bind:m  (take-kick wire)
  (pure:m vase)
::
+$  poke-result  (each (list cmd-result:ast) tang)
+$  parse-result  (each (list command:ast) tang)
+$  parse-output  (each (list command:ast) tang)
::
++  query-result-set
  |=  [id=@ta query=tape]
  =/  m  (strand ,(list vector:ast))
  ^-  form:m
  ;<  res=poke-result  bind:m  (query-obelisk id query)
  ?-  -.res
    %.n  (pure:m ~)
    %.y  (pure:m (poke-result-vectors p.res))
  ==
::
++  query-database-rows
  =/  m  (strand ,(list vector:ast))
  ^-  form:m
  (query-result-set %schema-databases sys-databases-query)
::
++  query-namespace-rows
  |=  db=@tas
  =/  m  (strand ,(list vector:ast))
  ^-  form:m
  (query-result-set %schema-namespaces (sys-namespaces-query db))
::
++  query-table-rows
  |=  db=@tas
  =/  m  (strand ,(list vector:ast))
  ^-  form:m
  (query-result-set %schema-tables (sys-tables-query db))
::
++  query-key-rows
  |=  db=@tas
  =/  m  (strand ,(list vector:ast))
  ^-  form:m
  (query-result-set %schema-keys (sys-table-keys-query db))
::
++  query-column-rows
  |=  db=@tas
  =/  m  (strand ,(list vector:ast))
  ^-  form:m
  (query-result-set %schema-columns (sys-columns-query db))
::
++  sys-databases-query
  ^-  tape
  "FROM sys.sys.databases SELECT database;"
::
++  sys-namespaces-query
  |=  db=@tas
  ^-  tape
  (weld "FROM " (weld (trip db) ".sys.namespaces SELECT namespace;"))
::
++  sys-tables-query
  |=  db=@tas
  ^-  tape
  (weld "FROM " (weld (trip db) ".sys.tables SELECT namespace, name;"))
::
++  sys-table-keys-query
  |=  db=@tas
  ^-  tape
  %+  weld  "FROM "
  %+  weld  (trip db)
  ".sys.table-keys SELECT namespace, name, key-ordinal, key, key-ascending;"
::
++  sys-columns-query
  |=  db=@tas
  ^-  tape
  %+  weld  "FROM "
  %+  weld  (trip db)
  ".sys.columns SELECT namespace, name, col-ordinal, col-name, col-type;"
::
++  poke-result-vectors
  |=  results=(list cmd-result:ast)
  ^-  (list vector:ast)
  ?~  results  ~
  (weld (cmd-result-vectors i.results) $(results t.results))
::
++  cmd-result-vectors
  |=  cmd-result=cmd-result:ast
  ^-  (list vector:ast)
  (result-vectors +.cmd-result)
::
++  result-vectors
  |=  results=(list result:ast)
  ^-  (list vector:ast)
  ?~  results  ~
  ?+  -.i.results
    $(results t.results)
    %result-set
      (weld +.i.results $(results t.results))
  ==
::
++  vector-value
  |=  [name=@tas vector=vector:ast]
  ^-  (unit dime)
  =/  cells=(list vector-cell:ast)  +.vector
  |-
  ?~  cells  ~
  ?:  =(name p.i.cells)
    `q.i.cells
  $(cells t.cells)
::
++  vector-tas
  |=  [name=@tas vector=vector:ast]
  ^-  (unit @tas)
  ?~  val=(vector-value name vector)  ~
  ?.  =(%tas p.u.val)  ~
  ``@tas`q.u.val
::
++  vector-ta
  |=  [name=@tas vector=vector:ast]
  ^-  (unit @ta)
  ?~  val=(vector-value name vector)  ~
  ?.  =(%ta p.u.val)  ~
  ``@ta`q.u.val
::
++  vector-ud
  |=  [name=@tas vector=vector:ast]
  ^-  (unit @ud)
  ?~  val=(vector-value name vector)  ~
  ?.  =(%ud p.u.val)  ~
  ``@ud`q.u.val
::
++  vector-flag
  |=  [name=@tas vector=vector:ast]
  ^-  (unit ?)
  ?~  val=(vector-value name vector)  ~
  ?.  =(%f p.u.val)  ~
  `=(0 q.u.val)
::
++  decode-database-row
  |=  vector=vector:ast
  ^-  (unit @tas)
  (vector-tas %database vector)
::
++  decode-namespace-row
  |=  vector=vector:ast
  ^-  (unit @tas)
  (vector-tas %namespace vector)
::
++  decode-table-row
  |=  vector=vector:ast
  ^-  (unit sys-table-row)
  ?~  ns=(vector-tas %namespace vector)  ~
  ?~  name=(vector-tas %name vector)  ~
  `[namespace=u.ns name=u.name]
::
++  decode-key-row
  |=  vector=vector:ast
  ^-  (unit sys-key-row)
  ?~  ns=(vector-tas %namespace vector)  ~
  ?~  table-name=(vector-tas %name vector)  ~
  ?~  ordinal=(vector-ud %key-ordinal vector)  ~
  ?~  key-name=(vector-tas %key vector)  ~
  ?~  ascending=(vector-flag %key-ascending vector)  ~
  `[namespace=u.ns table=u.table-name ordinal=u.ordinal key=u.key-name ascending=u.ascending]
::
++  decode-column-row
  |=  vector=vector:ast
  ^-  (unit sys-column-row)
  ?~  ns=(vector-tas %namespace vector)  ~
  ?~  table-name=(vector-tas %name vector)  ~
  ?~  ordinal=(vector-ud %col-ordinal vector)  ~
  ?~  column-name=(vector-tas %col-name vector)  ~
  ?~  type=(vector-ta %col-type vector)  ~
  `[namespace=u.ns table=u.table-name ordinal=u.ordinal column=u.column-name type=u.type]
::
++  decode-rows-as
  |*  out=mold
  |*  [rows=(list vector:ast) decode=$-(vector:ast (unit out))]
  ^-  (list out)
  ?~  rows  ~
  =/  row=(unit out)  (decode i.rows)
  ?~  row
    $(rows t.rows)
  [u.row $(rows t.rows)]
::
++  column-node-from-row
  |=  row=sys-column-row
  ^-  column-node
  [ordinal=ordinal.row name=column.row type=type.row]
::
++  key-node-from-row
  |=  row=sys-key-row
  ^-  key-node
  [ordinal=ordinal.row name=key.row ascending=ascending.row]
::
++  load-schema-tree
  =/  m  (strand ,schema-tree)
  ^-  form:m
  ;<  rows=(list vector:ast)  bind:m  query-database-rows
  =/  databases=(list @tas)  %+  sort   %+  (decode-rows-as @tas)
                                              rows
                                              decode-database-row
                                        aor
  (load-database-nodes databases)
::
++  maybe-load-schema-tree
  =/  m  (strand ,schema-tree)
  ^-  form:m
  ?:  should-load-schema-tree
    load-schema-tree
  (pure:m ~)
::
++  should-load-schema-tree
  ^-  ?
  ?:  =((pib:c /schema-refresh) "true")  %.y
  ?:  ?=([* %query] (rib:c /))  %.n
  ?.  ?=([* %parse] (rib:c /))  %.y
  %.n
::
++  load-database-nodes
  |=  databases=(list @tas)
  =/  m  (strand ,schema-tree)
  ^-  form:m
  ?~  databases  (pure:m ~)
  ;<  node=database-node  bind:m  (load-database-node i.databases)
  ;<  rest=schema-tree  bind:m  $(databases t.databases)
  (pure:m [node rest])
::
++  load-database-node
  |=  db=@tas
  =/  m  (strand ,database-node)
  ^-  form:m
  ?:  =(db %sys)  (pure:m sys-database-node)
  ;<  namespace-rows=(list vector:ast)  bind:m  (query-namespace-rows db)
  ;<  table-rows=(list vector:ast)      bind:m  (query-table-rows db)
  ;<  key-rows=(list vector:ast)        bind:m  (query-key-rows db)
  ;<  column-rows=(list vector:ast)     bind:m  (query-column-rows db)
  =/  namespaces  %+  sort  %+  (decode-rows-as @tas)  namespace-rows
                                                       decode-namespace-row
                            aor
  =/  tables      %+  (decode-rows-as sys-table-row)  table-rows
                                                      decode-table-row
  =/  keys        %+  (decode-rows-as sys-key-row)  key-rows
                                                    decode-key-row
  =/  columns     %+  (decode-rows-as sys-column-row)  column-rows
                                                       decode-column-row
  %-  pure:m  :-  name=db
                  (build-namespace-nodes namespaces tables keys columns)
::
++  sys-database-node
  ^-  database-node 
  [name=%sys namespaces=~[[name=%sys relations=~[sys-databases-view]]]]
::
++  build-namespace-nodes
  |=  $:  namespaces=(list @tas)
          tables=(list sys-table-row)
          keys=(list sys-key-row)
          columns=(list sys-column-row)
          ==
  ^-  (list namespace-node)
  ?~  namespaces  ~
  :-  (build-namespace-node i.namespaces tables keys columns)
      $(namespaces t.namespaces)
::
++  build-namespace-node
  |=  $:  namespace=@tas
          tables=(list sys-table-row)
          keys=(list sys-key-row)
          columns=(list sys-column-row)
      ==
  ^-  namespace-node
  =/  relations=(list relation-node)
    %+  sort
      %+  weld  ?:  =(namespace %sys)  :~  sys-namespaces-view
                                           sys-tables-view
                                           sys-table-keys-view
                                           sys-foreign-keys-view
                                           sys-columns-view
                                           sys-sys-log-view
                                           sys-data-log-view
                                           ==
                ~
                (table-relation-nodes namespace tables keys columns)
      relation-lte
  [name=namespace relations=relations]
::
++  table-relation-nodes
  |=  $:  namespace=@tas
          tables=(list sys-table-row)
          keys=(list sys-key-row)
          columns=(list sys-column-row)
      ==
  ^-  (list relation-node)
  ?~  tables  ~
  ?:  =(namespace namespace.i.tables)
    :-  :^  kind=%table
            name=name.i.tables
            :: columns
            %+  sort  (collect-columns namespace.i.tables name.i.tables columns)
                      column-lte
            :: keys
            %+  sort  (collect-keys namespace.i.tables name.i.tables keys)
                      key-lte
        $(tables t.tables)
  $(tables t.tables)
::
++  collect-columns
  |=  [namespace=@tas table-name=@tas rows=(list sys-column-row)]
  ^-  (list column-node)
  ?~  rows  ~
  ?:  ?&  =(namespace namespace.i.rows)
          =(table-name table.i.rows)
          ==
    [(column-node-from-row i.rows) $(rows t.rows)]
  $(rows t.rows)
::
++  collect-keys
  |=  [namespace=@tas table-name=@tas rows=(list sys-key-row)]
  ^-  (list key-node)
  ?~  rows  ~
  ?:  ?&  =(namespace namespace.i.rows)
          =(table-name table.i.rows)
          ==
    [(key-node-from-row i.rows) $(rows t.rows)]
  $(rows t.rows)
::
++  column-lte
  |=  [a=column-node b=column-node]
  ^-  ?
  (lth ordinal.a ordinal.b)
::
++  key-lte
  |=  [a=key-node b=key-node]
  ^-  ?
  (lth ordinal.a ordinal.b)
::
++  relation-lte
  |=  [a=relation-node b=relation-node]
  ^-  ?
  ?.  =(name.a name.b)
    (aor name.a name.b)
  (aor kind.a kind.b)
::::::
::::++  sys-view
::::  |=  [view-name=@tas columns=(list column-node)]
::::  ^-  relation-node
::::  [kind=%view name=view-name columns=columns keys=~]
::
++  make-column-node
  |=  [ordinal=@ud column-name=@tas aura=@ta]
  ^-  column-node
  [ordinal=ordinal name=column-name type=aura]
::
++  sys-databases-view
  ^-  relation-node
  :^  kind=%view
      name=%databases
      :~  (make-column-node 1 %database %tas)
          (make-column-node 2 %sys-agent %ta)
          (make-column-node 3 %sys-tmsp %da)
          (make-column-node 4 %data-ship %p)
          (make-column-node 5 %data-agent %ta)
          (make-column-node 6 %data-tmsp %da)
          ==
      keys=~
::
++  sys-namespaces-view
  ^-  relation-node
  :^  kind=%view
      name=%namespaces
      :~  (make-column-node 1 %namespace %tas)
          (make-column-node 2 %tmsp %da)
          ==
      keys=~
::
++  sys-tables-view
  ^-  relation-node
  :^  kind=%view
      name=%tables
      :~  (make-column-node 1 %namespace %tas)
          (make-column-node 2 %name %tas)
          (make-column-node 3 %agent %ta)
          (make-column-node 4 %tmsp %da)
          (make-column-node 5 %row-count %ud)
          ==
      keys=~
::
++  sys-table-keys-view
  ^-  relation-node
  :^  kind=%view
      name=%table-keys
      :~  (make-column-node 1 %namespace %tas)
          (make-column-node 2 %name %tas)
          (make-column-node 3 %key-ordinal %ud)
          (make-column-node 4 %key %tas)
          (make-column-node 5 %key-ascending %f)
          ==
      keys=~
::
++  sys-foreign-keys-view
  ^-  relation-node
  :^  kind=%view
      name=%foreign-keys
      :~  (make-column-node 1 %parent-namespace %tas)
          (make-column-node 2 %parent-table %tas)
          (make-column-node 3 %child-namespace %tas)
          (make-column-node 4 %child-table %tas)
          (make-column-node 5 %ordinal %ud)
          (make-column-node 6 %parent-column %tas)
          (make-column-node 7 %child-column %tas)
          (make-column-node 8 %on-delete %tas)
          (make-column-node 9 %on-update %tas)
          ==
      keys=~
::
++  sys-columns-view
  ^-  relation-node
  :^  kind=%view
      name=%columns
      :~  (make-column-node 1 %namespace %tas)
          (make-column-node 2 %name %tas)
          (make-column-node 3 %col-ordinal %ud)
          (make-column-node 4 %col-name %tas)
          (make-column-node 5 %col-type %ta)
          ==
      keys=~
::
++  sys-sys-log-view
  ^-  relation-node
  :^  kind=%view
      name=%sys-log
      :~  (make-column-node 1 %tmsp %da)
          (make-column-node 2 %agent %ta)
          (make-column-node 3 %action %tas)
          (make-column-node 4 %component %tas)
          (make-column-node 5 %database %t)
          (make-column-node 6 %namespace %t)
          (make-column-node 7 %relation %tas)
          (make-column-node 8 %target-database %t)
          (make-column-node 9 %target-namespace %t)
          (make-column-node 10 %target-relation %t)
          (make-column-node 11 %message %t)
          ==
      keys=~
::
++  sys-data-log-view
  ^-  relation-node
  :^  kind=%view
      name=%data-log
      :~  (make-column-node 1 %tmsp %da)
          (make-column-node 2 %ship %p)
          (make-column-node 3 %agent %ta)
          (make-column-node 4 %namespace %tas)
          (make-column-node 5 %table %tas)
          (make-column-node 6 %row-count %ud)
          ==
      keys=~
::
++  print-vector
  |=  [num=@ud vector=vector:ast]
  ;tr
    ;td.p1.bd1(style "white-space: nowrap; text-align: right;"): {(scow %ud num)}
    ;*
    %+  turn  +.vector
    |=  cell=vector-cell:ast
    ::;td.p1.bd1(style "white-space: nowrap;"): {(scow q.cell)}
    ;td.p1.bd1(style "white-space: nowrap;"): {(text (dime-to-vase q.cell))}
  ==
::
++  dime-to-vase
  |=  d=dime
  ^-  vase
  ?>  ((sane %tas) p.d)
  [[%atom `@tas`p.d ~] q.d]
::
::
::::::::::::::::::::::::::::::::::::::
::  parse ui
::
::
::
++  parse-query
  ^-  tape
  =,  mq
  %-  trip
  =<  q
  %^  fong  0  t+''
  %-  dimes
  %+  attributes  %value
  (get-id "query-text" dat:f)
  ::
++  parse-results
  ^-  manx
  =<  q
  %-  fall  :_
    ^-  (pair path manx)
    :-  /
    ;div#results.p8.fc.jc.ac.f4: No results yet
  (gid:d "results")
  ::
++  parse-default-db
  ^-  (unit term)
  ?~  req=(reb:c /default-db)
    ?~  res=(gid:d "default-db")  ~
    =/  el=manx  +.u.res
    %+  bind
      (~(get by (malt a.g.el)) %val)
    crip
  `q.u.req
::
++  collect-child-paths
  |=  [tree=file prefix=path]
  ^-  (list path)
  (collect-child-path-segs tree prefix (sort ~(tap in ~(key by dir.tree)) aor))
::
++  collect-child-path-segs
  |=  [tree=file prefix=path segs=(list @tas)]
  ^-  (list path)
  ?~  segs  ~
  =/  seg=@tas  i.segs
  =/  child=file  (~(got by dir.tree) seg)
  =/  rel=path  (snoc prefix seg)
  =/  current=(list path)  ?:(?=(^ fil.child) ~[rel] ~)
  (weld current (weld (collect-child-paths child rel) $(segs t.segs)))
::
++  descendant-child-paths
  ^-  (list path)
  (collect-child-paths the-file ~)
::
++  relative-path-text
  |=  pax=path
  ^-  tape
  ?~  pax  ""
  ?~  t.pax
    (trip i.pax)
  (weld (trip i.pax) (weld "/" $(pax t.pax)))
::
++  print-existing-child-paths
  ^-  manx
  ;div#existing-child-paths.hidden
    ;*
    %+  turn  descendant-child-paths
    |=  pax=path
    ;input.existing-child-path(type "hidden", value (relative-path-text pax));
  ==
::
::
::
::::::::::::::::::::::::::::::::::::::
::  print ui
::
::
::
++  print
  |=  [query=tape results=manx default-db=(unit term)]
  =/  m  (strand ,vase)
  ^-  form:m
  ;<  schemas=schema-tree  bind:m  maybe-load-schema-tree
  %-  pure:m  !>
  ;div.fc.hf
    ;+
    =;  m=manx
      ?.  =((pib:c /schema-open) "true")  m
      m(a.g [[%open ""] a.g.m])
    ;hawk-sidebar#h-schema.hf
      =side  "left"
      =size  "0.4"
      =label  "Schemas"
      ;+
        =/  m=manx  (print-schemas schemas default-db)
        m(a.g [[%slot "side"] a.g.m])
      ;hawk-sidebar#h-output.hf.fc
        =side  "bottom"
        =label  "Output"
        =open  ""
        =size  "0.4"
        ;div.fc.hf
          ;+  (print-header schemas default-db)
          ;+  (print-query-form query)
        ==
        ;+  results(a.g [[%slot "side"] a.g.results])
      ==
    ==
    ;+  print-script
  ==
  ::
++  print-header
  |=  [schemas=schema-tree default-db=(unit term)]
  ;header.p2.frw.g4.b1(style "border-bottom: 1px solid var(--b3); position: relative;")
      ;div#file-menu-backdrop.hidden(onclick "closeFileMenu()", style "position: fixed; inset: 0; z-index: 9;");
      ;div#file-menu.rel(style "position: relative; display: inline-block;", data-open "false")
      ;button#file-menu-toggle.underline(type "button", onclick "return toggleFileMenu()", aria-expanded "false", style "cursor: pointer; display: inline-block; position: relative; z-index: 11;")
        ;span: File
      ==
      ;div#file-menu-panel.abs.b2.bd1.br1.fc.hidden(style "position: absolute; z-index: 11; min-width: 12rem; top: calc(100% + 0.25rem); left: 0;")
        ;button#new-tab-menu-item.wf.p-1.hover(type "button", onclick "return newEditorTab()", style "text-align: left;"): New
        ;button#open-menu-item.wf.p-1.hover(type "button", onclick "toggleOpenPanel(); return false;", style "text-align: left;"): Open...
        ;button#save-tab-menu-item.wf.p-1.hover(type "button", onclick "submitSavePanel(); return false;", style "text-align: left;"): Save
        ;button#save-as-menu-item.wf.p-1.hover(type "button", onclick "toggleSaveAsPanel(); return false;", style "text-align: left;"): Save As...
        ;button#close-tab-menu-item.wf.p-1.hover(type "button", onclick "closeCurrentTab(); return false;", style "text-align: left;"): Close
        ;div#open-panel.fc.g1.p2.b1.hidden
          ;div.s-2.o7: Open child path
          ;div#open-panel-list.fc(style "max-height: calc(20 * 2rem); overflow-y: auto;");
        ==
        ;form#save-panel-form.fc.g1.loader.p2.b1.hidden
          =method  "post"
          =action  "/apps/hawk/code{(spud here)}/script-1"
          =data-base-action  "/apps/hawk/code{(spud here)}"
          =target  "save-panel-target"
          =onsubmit  "event.preventDefault(); submitSavePanel(event); return false;"
          ;div.s-2.o7: Save current tab to child path
          ;input#save-panel-child.br1.bd1.p-1.wfc(name "_child-path", value "script-1", placeholder "script-1");
          ;input.hidden(name "/protocol", value "/text/plain");
          ;button#save-panel-submit.p-1.bd1.br1.b2.hover.loader(type "button", onclick "submitSavePanel(event); return false;")
            ;span.loaded.fr.ac.g1
              ;span: Save
            ==
            ;span.loading: ...
          ==
        ==
      ==
    ==
    ;div#save-toast.hidden.mono.bd1.br1.p-2.b2(style "position: absolute; top: calc(100% + 0.5rem); left: 0; z-index: 40; display: inline-block;")
      ;span#save-toast-text;
    ==
    ;div#table-context-menu.hidden.fc.mono.bd1.br1.b2(style "position: fixed; z-index: 60; min-width: 10rem;")
      ;button#table-context-select.wf.p-1.hover(type "button", onclick "openTableActionTab('SELECT'); return false;", style "text-align: left;"): SELECT
      ;button#table-context-insert.wf.p-1.hover(type "button", onclick "openTableActionTab('INSERT'); return false;", style "text-align: left;"): INSERT
      ;button#table-context-create.wf.p-1.hover(type "button", onclick "openTableActionTab('CREATE'); return false;", style "text-align: left;"): CREATE
    ==
    ;iframe.hidden(name "save-panel-target");
    ;+  print-existing-child-paths
    ;button#run-btn.p-1.bd1.br1.b2.hover.loader
      =onclick  "return submitQueryAction('query')"
      ;span.loaded.fr.ac.g2
        ;span: Run
        ;span.s-2.o6: F5
      ==
      ;span.loading: ...
    ==
    ;button.p-1.bd1.br1.b2.hover(type "button", onclick "return submitQueryAction('parse')"): Parse
    ;button#save-results-btn.p-1.bd1.br1.b2.hover(type "button", onclick "return toggleResultsSavePanel(event)", disabled ""): Save Results
    ;a.underline(href "https://github.com/jackfoxy/obelisk/tree/master/desk/doc/usr/reference/", target "_blank", rel "noopener noreferrer"): Reference
    ;a.underline(href "https://github.com/jackfoxy/obelisk/blob/master/desk/doc/usr/users-guide.md", target "_blank", rel "noopener noreferrer"): Users Guide
    ;a.underline(href "https://github.com/jackfoxy/obelisk/blob/master/roadmap.md", target "_blank", rel "noopener noreferrer"): Roadmap
    ;+  (print-form-set-default-db schemas default-db)
    ;+  print-for-developers-menu
  ==
  ::
++  print-form-set-default-db
  |=  [schemas=schema-tree default-db=(unit term)]
  ;form#default-db-form.fr.ac.g1.pl-2(method "post")
    ;input.hidden(name "/", value "set-default-db");
    ;div.p1.loader.mono.s-2
      ;span.loaded.f3: Default DB
      ;span.loading.f4: saving..
    ==
    ;select#default-db.br1.bd1.p-1.wfc(val (trip (fall default-db 'sys')), onchange "syncDefaultDbMarker(this.value)", style "color-scheme: light dark; color: CanvasText; background: Canvas;")
      =name  "default-db"
      =required  ""
      ;*
      %+  turn  (database-names schemas)
      |=  =term
      =;  m=manx
        ?~  default-db  m
        ?.  =(default-db `term)  m
        m(a.g [[%selected (trip u.default-db)] a.g.m])
      ;option(value (trip term), style "color: CanvasText; background: Canvas;"): {(trip term)}
    ==
  ==
::
++  print-for-developers-menu
  ^-  manx
  ;div.rel.pl-2(style "position: relative; display: inline-block;")
    ;div#dev-menu-backdrop.hidden(onclick "closeDevMenu()", style "position: fixed; inset: 0; z-index: 9;");
    ;div#dev-menu.rel(style "position: relative; display: inline-block;", data-open "false")
      ;button#dev-menu-toggle.underline(type "button", onclick "return toggleDevMenu()", aria-expanded "false", style "cursor: pointer; display: inline-block; position: relative; z-index: 11;")
        ;span: For Developers
      ==
      ;div#dev-menu-panel.abs.b2.bd1.br1.fc.hidden(style "position: absolute; z-index: 11; min-width: 12rem; top: calc(100% + 0.25rem); right: 0;")
        ;a.wf.p-1.hover(href "https://github.com/jackfoxy/obelisk/blob/master/desk/sur/obelisk-ast.hoon", target "_blank", rel "noopener noreferrer", style "text-align: left; display: block;"): API/AST
        ;a.wf.p-1.hover(href "https://github.com/jackfoxy/obelisk/tree/master/.claude/skills/obelisk-urql", target "_blank", rel "noopener noreferrer", style "text-align: left; display: block;"): urQL
        ;a.wf.p-1.hover(href "https://github.com/jackfoxy/obelisk/blob/master/desk/doc/dev/users-guide-script.txt", target "_blank", rel "noopener noreferrer", style "text-align: left; display: block;"): Sample urQL
        ;a.wf.p-1.hover(href "https://github.com/jackfoxy/obelisk/blob/master/desk/doc/dev/performance.md", target "_blank", rel "noopener noreferrer", style "text-align: left; display: block;"): Benchmarks
      ==
    ==
  ==
::
++  database-names
  |=  schemas=schema-tree
  ^-  (list @tas)
  (sort (database-names-raw schemas) aor)
::
++  database-names-raw
  |=  schemas=schema-tree
  ^-  (list @tas)
  ?~  schemas  ~
  [name.i.schemas $(schemas t.schemas)]
::
++  relation-columns
  |=  rel=relation-node
  ^-  manx
  ;div.p3.fc.g1
    ;*
    %+  turn  columns.rel
    |=  col=column-node
    =/  aura=tape  (weld "@" (trip type.col))
    =/  is-index=tape  (key-indicator name.col keys.rel)
      ;summary(style "display: grid; grid-template-columns: 4ch 4ch 1fr; column-gap: 1ch; align-items: center;")
        ;span;
        ;span.f4.mono(style "text-align: center;"): {(weld is-index aura)}
        ;span: {(trip name.col)}
      ==
  ==
::
++  key-indicator
  |=  [name=@tas keys=(list key-node)]
  ^-  tape
  ?~  keys  " "
  ?:  =(name name.i.keys)
    ?:(ascending.i.keys "↑" "↓")
  $(keys t.keys)
  ::
++  column-name-csv
  |=  cols=(list column-node)
  ^-  tape
  ?~  cols  ""
  ?~  t.cols
    (trip name.i.cols)
  (weld (trip name.i.cols) (weld "," $(cols t.cols)))
::
++  column-spec-csv
  |=  cols=(list column-node)
  ^-  tape
  ?~  cols  ""
  =/  spec  (weld (trip name.i.cols) (weld ":" (weld "@" (trip type.i.cols))))
  ?~  t.cols
    spec
  (weld spec (weld "," $(cols t.cols)))
::
++  key-spec-csv
  |=  keys=(list key-node)
  ^-  tape
  ?~  keys  ""
  =/  order=tape  ?:(ascending.i.keys "ASC" "DESC")
  =/  spec=tape  (weld (trip name.i.keys) (weld ":" order))
  ?~  t.keys
    spec
  (weld spec (weld "," $(keys t.keys)))
::
++  print-relation
  |=  [db=@tas ns=@tas rel=relation-node]
  ^-  manx
  =/  kind-text=tape    ?-  kind.rel
                          %table  "table"
                          %view   "view"
                          ==
  =/  tag=tape          ?-  kind.rel
                          %table  "tbl"
                          %view   "vw"
                          ==
  =/  columns-csv=tape  (column-name-csv columns.rel)
  =/  specs-csv=tape
    ?:(=(kind.rel %table) (column-spec-csv columns.rel) "")
  =/  keys-csv=tape
    ?:(=(kind.rel %table) (key-spec-csv keys.rel) "")
  ;details.rel(style "position: relative;")
    =data-relation  "{(trip db)}.{(trip ns)}.{(trip name.rel)}"
    ;summary(oncontextmenu "openTableContextMenu(event, '{kind-text}', '{(trip db)}', '{(trip ns)}', '{(trip name.rel)}', '{columns-csv}', '{specs-csv}', '{keys-csv}'); return false;", style "padding-right: 2rem;")
      ;span.fr.ac.g1(style "display: inline-flex;")
        ;span.f4.mono: {(weld "[" (weld tag "]"))}
        ;span: {(trip name.rel)}
      ==
    ==
    ;button(type "button", onclick "event.stopPropagation(); openTableContextMenu(event, '{kind-text}', '{(trip db)}', '{(trip ns)}', '{(trip name.rel)}', '{columns-csv}', '{specs-csv}', '{keys-csv}'); return false;", style "position: absolute; top: 0.2rem; right: 0.2rem; z-index: 1; padding: 0 0.5rem; line-height: 1;")
      ;span.mono: ...
    ==
    ;*  ~[(relation-columns rel)]
  ==
::
++  print-schemas
  |=  [schemas=schema-tree default-db=(unit term)]
  ;div.wf.hf.scroll-y.b2
    ;div.sticky.b2
      =style  "top: 0;"
      ;div.mono.tc.p-1.pre: {(pib:c /sys/our)}
      ;hr.bc4;
    ==
    ;div#schema.p2
      ;*
      %+  turn  schemas
      |=  db=database-node
      ;details
        =data-db  (trip name.db)
        ;summary
          ;span.f4.mono: [db] 
          ;span: {(trip name.db)} 
          ;+  ?.  =(default-db `name.db)  ;/("")
          ;span.schema-default-db.f3: (default)
        ==
        ;div.p3.fc.g1
          ;*
          %+  turn  namespaces.db
          |=  ns=namespace-node
            ;details
              =data-ns  "{(trip name.db)}.{(trip name.ns)}"
              ;summary
                ;span.f4.mono: [ns]
                ;span: {(trip name.ns)}
              ==
              ;div.p3.fc.g1
                ;*
                %+  turn  relations.ns
                |=  rel=relation-node
                (print-relation name.db name.ns rel)
              ==
          ==
        ==
      ==
    ==
  ==
::
++  print-query-form
  |=  [query=tape]
  ;form#query-form.grow.fc.mono.s0.hf
    :: =method  "post"
    =hx-swap  "outerHTML"
    =hx-target  "#results"
    =hx-select  "#results"
    =hx-post  ""
    =hx-indicator  "#run-btn"
    =hx-on-htmx-config-request  "configRequest(event); $('#query-text').focus()"
    =hx-on-htmx-after-request  "$('#query-text').focus(); syncSaveResultsButton(); maybeRefreshSchema(window.obeliskLastQuery);"
    ;input#query-action.hidden(name "/", value "query");
    ;div#query-tabs.fr.ac.px-1.pt-1.scroll-x(style "border-bottom: 1px solid var(--b3); gap: 0.375rem;")
      ;div#query-tabs-list.fr.ac(style "gap: 0.375rem;");
      ;button#query-tab-add.px-2.py-1.bd1.br1.hover(type "button", onclick "newEditorTab()", style "margin-bottom: 1px;"): +
    ==
    ;textarea#query-text.p3.grow.b0(hx-preserve "")
      =aura  "t-multi"
      =name  "/query-text"
      =placeholder  "FROM ... SELECT *"
      =value  query
      ;*  ~[;/(query)]
    ==
    ;button.hidden(type "submit");
  ==
++  print-poke-result
  |=  res=poke-result
  ^-  manx
  ?-  -.res
    %.n  (print-tang p.res)
    %.y  (print-results p.res)
  ==
  ::
++  print-tang
  |=  =tang
  =/  tang  (show-crash-messages tang)
  ;div#results.grow.basis-half.b1.mono.s0
    ;div.scroll-x.scroll-y.p4(data-tab "error")
      ;*
      %+  turn  tang
      |=  =tank
      ;div
        ;*
        %+  turn  (wash [0 80] tank)
        |=  =tape
        ;div(style "white-space: pre-wrap; min-height: 1em;"): {tape}
      ==
    ==
  ==
::  Lift crash messages above the raw trace, separated by a blank line.
++  show-crash-messages
  |=  trc=tang
  ^-  tang
  =/  msgs=(list tank)  (crash-summary-lines trc)
  ?~  msgs  trc
  (weld msgs `(list tank)`[leaf+" " leaf+" " trc])
::
++  crash-summary-lines
  |=  trc=tang
  ^-  (list tank)
  =|  acc=(list tank)
  |-
  ?~  trc  (flop acc)
  =/  msgs=(list tank)  (crash-summary-from-lines (wash [0 80] i.trc))
  $(trc t.trc, acc (weld (flop msgs) acc))
::
++  crash-summary-from-lines
  |=  lines=(list tape)
  ^-  (list tank)
  =|  acc=(list tank)
  |-
  ?~  lines  (flop acc)
  =/  msg=(unit tape)  (extract-crash-message i.lines)
  $(lines t.lines, acc ?~(msg acc [leaf+u.msg acc]))
::
++  extract-crash-message
  |=  line=tape
  ^-  (unit tape)
  =/  msg=(unit tape)  (extract-quoted-message line)
  ?^  msg  msg
  ?:  ?|(=(~ line) (trace-line line) !(tape-has-alpha line))
      ~
  `line
::
++  extract-quoted-message
  |=  line=tape
  ^-  (unit tape)
  |-
  ?~  line  ~
  ?:  =('"' i.line)
    (collect-until-quote t.line)
  $(line t.line)
::
++  collect-until-quote
  |=  line=tape
  ^-  (unit tape)
  =|  acc=tape
  =|  escaped=?
  |-
  ?~  line  ~
  ?:  escaped
    $(line t.line, escaped %.n, acc [i.line acc])
  ?:  =('\\' i.line)
    $(line t.line, escaped %.y)
  ?:  =('"' i.line)
    `(tape-flop acc)
  $(line t.line, acc [i.line acc])
::
++  trace-line
  |=  line=tape
  ^-  ?
  ?~  line  %.n
  =('/' i.line)
::
++  tape-has-alpha
  |=  line=tape
  ^-  ?
  |-
  ?~  line  %.n
  =/  upper=?  ?&((gte i.line 'A') (lte i.line 'Z'))
  =/  lower=?  ?&((gte i.line 'a') (lte i.line 'z'))
  ?:  ?|(upper lower)
    %.y
  $(line t.line)
::
++  tape-flop
  |=  tp=tape
  ^-  tape
  =|  acc=tape
  |-
  ?~  tp  acc
  $(tp t.tp, acc [i.tp acc])
++  print-results
  |=  results=(list cmd-result:ast)
  ;div#results.grow.b1.mono.s0.hf
    ;*  (print-numbered-cmd-results results 1)
  ==
++  print-numbered-cmd-results
  |=  [results=(list cmd-result:ast) num=@ud]
  ^-  (list manx)
  ?~  results  ~
  [(print-cmd-result-tabs num i.results) $(results t.results, num +(num))]
::
++  print-cmd-result-tabs
  |=  [group-id=@ud cmd-result=cmd-result:ast]
  =/  num-sets=@ud
    %-  lent
    %+  skim  +.cmd-result
    |=  result=result:ast
    =(-.result %result-set)
  ;div.result-export-group.rel(style "position: relative;")
    =data-results-group  (scow %ud group-id)
    =data-has-results  ?:(=(0 num-sets) "false" "true")
    ;+
      ?:  =(0 num-sets)
        ;div.p3
          ;*
          %+  turn  +.cmd-result
          |=(result=result:ast (print-result-metadata result))
        ==
      ;hawk-tabs.grow.hf
        ;div.p3(data-tab "Results")
          ;*
          %+  turn  +.cmd-result
          |=(result=result:ast (print-result-set result))
        ==
      ;div.p3(data-tab "Messages")
        ;*
        %+  turn  +.cmd-result
        |=(result=result:ast (print-result-metadata result))
      ==
    ==
    ;+
      ?:  =(0 num-sets)  ;/("")
      (print-results-save-panel group-id)
    ;+
      ?:  =(0 num-sets)  ;/("")
      (print-results-export-data +.cmd-result)
  ==
::
++  print-result-metadata
  |=  result=result:ast
  ?+  -.result  ;div;
    %action
      (print-message-row "message:" (trip action.result))
    %relation
      (print-message-row "message:" (trip relation.result))
    %message
      (print-message-row "message:" (trip msg.result))
    %vector-count
      (print-message-row "vector count:" (scow %ud count.result))
    %server-time
      (print-message-row "server-time:" (scow %da date.result))
    %schema-time
      (print-message-row "schema-time:" (scow %da date.result))
    %data-time
      (print-message-row "data-time:" (scow %da date.result))
  ==
::
++  print-message-row
  |=  [label=tape value=tape]
  ^-  manx
  ;div.fr.g1
    ;div.bold: {label}
    ;div: {value}
  ==
::
++  print-result-set
  |=  result=result:ast
  ?+  -.result  ;/("")
    %result-set
      (print-list-vector +.result)
  ==
  ::
++  print-results-save-panel
  |=  group-id=@ud
  (print-results-save-panel-with-delimiter group-id %.y)
::
++  print-results-save-panel-with-delimiter
  |=  [group-id=@ud show-delimiter=?]
  ;div.results-save-panel.hidden.b2.bd1.br1(style "position: fixed; top: 0; left: 0; z-index: 20; min-width: 16rem; max-width: 20rem;")
    ;form.results-save-panel-form.fc.g1.loader.p2
      =method  "post"
      =action  "/apps/hawk/code{(spud here)}/results-1"
      =data-base-action  "/apps/hawk/code{(spud here)}"
      =onsubmit  "event.preventDefault(); submitResultsSavePanel(event); return false;"
      ;div.s-2.o7: Save results to child path
      ;input.results-save-child.br1.bd1.p-1.wfc(name "_child-path", value "results-1", placeholder "results-1");
      ;+
        ?:  show-delimiter
          ;div.fc.g1
            ;div.s-2.o7: Delimiter
            ;label.fr.ac.g1
              ;input(type "radio", name "results-delimiter-{(scow %ud group-id)}", value "comma", checked "");
              ;span: comma
            ==
            ;label.fr.ac.g1
              ;input(type "radio", name "results-delimiter-{(scow %ud group-id)}", value "space");
              ;span: space
            ==
            ;label.fr.ac.g1
              ;input(type "radio", name "results-delimiter-{(scow %ud group-id)}", value "tab");
              ;span: tab
            ==
          ==
        ;/("")
      ;button.results-save-submit.p-1.bd1.br1.b2.hover.loader(type "button", onclick "submitResultsSavePanel(event); return false;")
        ;span.loaded.fr.ac.g1
          ;span: Save
        ==
        ;span.loading: ...
      ==
    ==
  ==
::
++  print-results-export-data
  |=  results=(list result:ast)
  ^-  manx
  ;div.results-export-data.hidden
    ;*
    %+  turn  results
    |=  result=result:ast
    ?+  -.result  ;/("")
      %result-set
        (print-result-export-set +.result)
    ==
  ==
::
++  print-result-export-set
  |=  vectors=(list vector:ast)
  ^-  manx
  ;div.result-export-set.hidden
    ;+
      ?~  vectors
        ;/("")
      ;div.result-export-headers.hidden
        ;*
        %+  turn  +:i.vectors
        |=  cell=vector-cell:ast
        ;textarea.result-export-header.hidden: {(trip p.cell)}
      ==
    ;*
    %+  turn  vectors
    |=  vector=vector:ast
    ;div.result-export-row.hidden
      ;*
      %+  turn  +.vector
      |=  cell=vector-cell:ast
      ;textarea.result-export-cell.hidden: {(text (dime-to-vase q.cell))}
    ==
  ==
::
++  print-list-vector
  |=  vectors=(list vector:ast)
  ;div
    ;table.p3
      =style  "border-collapse: collapse;"
      ;tr
        ;th.p1.bd1;
        ;*
        ?~  vectors  ~
        %+  turn  +:i.vectors
        |=  cell=vector-cell:ast
        ;th.p1.bd1(style "white-space: nowrap;"): {(trip p.cell)}
      ==
      ;*  (print-numbered-vectors vectors 1)
    ==
  ==
::
++  print-numbered-vectors
  |=  [vectors=(list vector:ast) num=@ud]
  ^-  (list manx)
  ?~  vectors  ~
  [(print-vector num i.vectors) $(vectors t.vectors, num +(num))]
::
++  print-parse-output
  |=  output=parse-output
  ?-  -.output
    %.n  (print-tang p.output)
    %.y
      ;div#results.grow.b1.mono.s0
        ;div.result-export-group.rel
          =data-results-group  "1"
          =data-has-results  "true"
          ;div.scroll-x.scroll-y.p4.pre-wrap(style "white-space: pre-wrap;")
            {(text !>(p.output))}
          ==
          ;+  (print-results-save-panel-with-delimiter 1 %.n)
          ;textarea.parse-export-text.hidden: {(text !>(p.output))}
        ==
      ==
  ==
++  print-script
  ;script
    ::
    ::  this script adds some of the ui state to the card
    ::  so that it can be persisted across pokes
    ::
    ;+  ;/  %-  trip
    '''
    function configRequest(e) {
      syncEditorTabs();
      e.detail.parameters['schema-open'] = $('#h-schema').is('[open]')
      e.detail.parameters['schema-size'] = $('#h-schema').attr('size') || '0.3';
      e.detail.parameters['output-size'] = $('#h-output').attr('size') || '0.3';
      let selection = window.getSelection()
      const selText = selection.toString();
      e.detail.parameters['/selected-query-text'] = selText;
      e.detail.parameters['default-db'] = $('#default-db').val() || 'sys';
      window.obeliskLastQuery = selText || ($('#query-text').val() || '');
      window.obeliskLastAction = $('#query-action').val() || 'query';
      e.detail.parameters['schema-refresh'] = 'false';
    }
    function submitQueryAction(action) {
      const input = document.getElementById('query-action');
      if (input) {
        input.value = action;
      }
      $('#query-form').find('[type=submit]').click();
      return false;
    }
    function prepareExportForm(form) {
      const state = getEditorTabs();
      const activeTab = state.tabs[state.active];
      const childInput = form.querySelector('#save-panel-child');
      const fallbackChild = activeTab ? currentTabPath(activeTab) : 'script-1';
      const rawChild = childInput && childInput.value ? childInput.value : fallbackChild;
      const displayPath = normalizeChildPath(rawChild || fallbackChild);
      const safeChild = displayPath.split('/').map(encodeURIComponent).join('/');
      const baseAction = form.getAttribute('data-base-action') || '';
      if (childInput) {
        childInput.value = displayPath;
      }
      form.action = baseAction + '/' + safeChild;
      return {
        displayPath,
        safePath: safeChild,
      };
    }
    function normalizeChildPath(rawChild) {
      const parts = String(rawChild || '').split('/').map((part) => part.trim()).filter(Boolean);
      return (parts.length ? parts : ['script-1']).join('/');
    }
    function readKnownChildPaths() {
      return Array.from(document.querySelectorAll('#existing-child-paths .existing-child-path'))
        .map((input) => normalizeChildPath(input.value))
        .filter(Boolean);
    }
    function getKnownChildPaths() {
      if (!window.obeliskKnownChildPaths) {
        window.obeliskKnownChildPaths = new Set();
      }
      readKnownChildPaths().forEach((path) => window.obeliskKnownChildPaths.add(path));
      return window.obeliskKnownChildPaths;
    }
    function getRenderableChildPaths() {
      const paths = new Set(readKnownChildPaths());
      if (window.obeliskKnownChildPaths) {
        window.obeliskKnownChildPaths.forEach((path) => paths.add(normalizeChildPath(path)));
      }
      const state = getEditorTabs();
      state.tabs.forEach((tab) => {
        if (tab.savedPath) {
          paths.add(normalizeChildPath(tab.savedPath));
        }
      });
      return Array.from(paths).sort((a, b) => a.localeCompare(b));
    }
    function knownChildPathExists(path) {
      return getKnownChildPaths().has(normalizeChildPath(path));
    }
    function registerKnownChildPath(path) {
      if (!path) {
        return;
      }
      getKnownChildPaths().add(normalizeChildPath(path));
    }
    function currentTabPath(tab) {
      return normalizeChildPath((tab && (tab.savedPath || tab.draftPath)) ? (tab.savedPath || tab.draftPath) : 'script-1');
    }
    function getSortedChildPaths() {
      return getRenderableChildPaths();
    }
    function childCodeUrl(path) {
      const base = new URL(window.location.href);
      base.search = '';
      base.hash = '';
      const normalizedPath = normalizeChildPath(path);
      const childUrl = new URL(normalizedPath + '/', base.href);
      childUrl.search = '?code';
      return childUrl.toString();
    }
    function nextNumberedChildPath(prefix, skipTabId) {
      const state = getEditorTabs();
      const taken = new Set();
      getKnownChildPaths().forEach((path) => {
        taken.add(normalizeChildPath(path));
      });
      state.tabs.forEach((tab) => {
        if (skipTabId && tab.id === skipTabId) {
          return;
        }
        if (tab.savedPath) {
          taken.add(normalizeChildPath(tab.savedPath));
        }
        if (tab.draftPath) {
          taken.add(normalizeChildPath(tab.draftPath));
        }
      });
      let nextNum = 1;
      while (taken.has(prefix + '-' + nextNum)) {
        nextNum += 1;
      }
      return prefix + '-' + nextNum;
    }
    function nextScriptPath(skipTabId) {
      return nextNumberedChildPath('script', skipTabId);
    }
    function nextResultsPath() {
      return nextNumberedChildPath('results');
    }
    function ensureTabDraftPath(tab, force) {
      if (!tab || tab.savedPath) {
        return false;
      }
      if (!force && tab.draftPath) {
        return false;
      }
      const nextPath = nextScriptPath(force ? tab.id : null);
      if (tab.draftPath === nextPath) {
        return false;
      }
      tab.draftPath = nextPath;
      return true;
    }
    function setFileMenuOpen(open) {
      const menu = document.getElementById('file-menu');
      const panel = document.getElementById('file-menu-panel');
      const toggle = document.getElementById('file-menu-toggle');
      const backdrop = document.getElementById('file-menu-backdrop');
      if (!menu || !panel || !toggle || !backdrop) {
        return;
      }
      menu.setAttribute('data-open', open ? 'true' : 'false');
      backdrop.classList.toggle('hidden', !open);
      panel.classList.toggle('hidden', !open);
      toggle.setAttribute('aria-expanded', open ? 'true' : 'false');
      if (!open) {
        hideSaveAsPanel();
        hideOpenPanel();
      }
    }
    function toggleFileMenu() {
      const menu = document.getElementById('file-menu');
      const isOpen = !!menu && menu.getAttribute('data-open') === 'true';
      setFileMenuOpen(!isOpen);
      return false;
    }
    function setDevMenuOpen(open) {
      const menu = document.getElementById('dev-menu');
      const panel = document.getElementById('dev-menu-panel');
      const toggle = document.getElementById('dev-menu-toggle');
      const backdrop = document.getElementById('dev-menu-backdrop');
      if (!menu || !panel || !toggle || !backdrop) {
        return;
      }
      menu.setAttribute('data-open', open ? 'true' : 'false');
      backdrop.classList.toggle('hidden', !open);
      panel.classList.toggle('hidden', !open);
      toggle.setAttribute('aria-expanded', open ? 'true' : 'false');
    }
    function toggleDevMenu() {
      const menu = document.getElementById('dev-menu');
      const isOpen = !!menu && menu.getAttribute('data-open') === 'true';
      setDevMenuOpen(!isOpen);
      return false;
    }
    function closeDevMenu() {
      setDevMenuOpen(false);
    }
    function hideSaveAsPanel() {
      const form = document.getElementById('save-panel-form');
      if (form) {
        form.classList.add('hidden');
      }
    }
    function hideOpenPanel() {
      const panel = document.getElementById('open-panel');
      if (panel) {
        panel.classList.add('hidden');
      }
    }
    function renderOpenPanel() {
      const list = document.getElementById('open-panel-list');
      if (!list) {
        return;
      }
      list.innerHTML = '';
      const paths = getSortedChildPaths();
      if (!paths.length) {
        const empty = document.createElement('div');
        empty.className = 'p-1 o7';
        empty.textContent = 'No child paths yet';
        list.appendChild(empty);
        return;
      }
      paths.forEach((path) => {
        const button = document.createElement('button');
        button.type = 'button';
        button.className = 'wf p-1 hover mono';
        button.style.textAlign = 'left';
        button.textContent = path;
        button.addEventListener('click', () => openChildPath(path));
        list.appendChild(button);
      });
    }
    function setBusyCursor(active) {
      const cursor = active ? 'progress' : '';
      document.documentElement.style.cursor = cursor;
      if (document.body) {
        document.body.style.cursor = cursor;
      }
    }
    async function nudgeHawkTreeRefresh() {
      const target = document.querySelector('#tree-tab > .oob');
      if (!target) return;
      try {
        const url = window.location.pathname + window.location.search;
        const res = await fetch(url, { credentials: 'same-origin' });
        if (!res.ok) return;
        const doc = new DOMParser().parseFromString(await res.text(), 'text/html');
        const fragment = doc.querySelector('[hx-swap-oob*="#tree-tab > .oob"]');
        if (!fragment) return;
        target.innerHTML = fragment.innerHTML;
        if (typeof htmx !== 'undefined') {
          htmx.process(target);
        }
      } catch (_err) {
        // best effort only
      }
    }
    function getResultsSavePanel(group) {
      return group ? group.querySelector('.results-save-panel') : null;
    }
    function firstResultsGroup() {
      return document.querySelector('.result-export-group[data-has-results="true"]');
    }
    function syncSaveResultsButton() {
      const button = document.getElementById('save-results-btn');
      if (!button) {
        return;
      }
      button.disabled = !firstResultsGroup();
    }
    function positionResultsSavePanel(panel, button) {
      if (!panel || !button) {
        return;
      }
      const rect = button.getBoundingClientRect();
      panel.style.top = (rect.bottom + 8) + 'px';
      panel.style.left = Math.max(8, rect.left) + 'px';
    }
    function toggleResultsSavePanel(e) {
      if (e) {
        e.preventDefault();
      }
      const btn = (e && e.currentTarget) || document.getElementById('save-results-btn');
      const group = (btn && btn.closest('.result-export-group')) || firstResultsGroup();
      const panel = getResultsSavePanel(group);
      if (!panel) {
        return false;
      }
      const isHidden = panel.classList.contains('hidden');
      document.querySelectorAll('.results-save-panel').forEach((p) => p.classList.add('hidden'));
      if (isHidden) {
        const input = panel.querySelector('.results-save-child');
        if (input) {
          const current = (input.value || '').trim();
          if (!current || current === 'results-1') {
            input.value = nextResultsPath();
          }
        }
        positionResultsSavePanel(panel, btn);
        panel.classList.remove('hidden');
      }
      return false;
    }
    function prepareResultsSaveForms() {
      document.querySelectorAll('.results-save-child').forEach((input) => {
        if (!input) {
          return;
        }
        const current = (input.value || '').trim();
        if (!current || current === 'results-1') {
          input.value = nextResultsPath();
        }
      });
    }
    function resultsDelimiterText(form) {
      const selected = form ? form.querySelector('input[type="radio"]:checked') : null;
      const value = selected ? selected.value : 'comma';
      if (value === 'space') {
        return ' ';
      }
      if (value === 'tab') {
        return '\t';
      }
      return ',';
    }
    function textareaValues(node, selector) {
      return Array.from(node.querySelectorAll(selector)).map((el) => el.value || '');
    }
    function resultsExportSets(group) {
      const root = document.getElementById('results');
      const sets = root ? Array.from(root.querySelectorAll('.result-export-set')) : [];
      if (sets.length) {
        return sets;
      }
      return group ? Array.from(group.querySelectorAll('.result-export-set')) : [];
    }
    function parseExportText(group) {
      const root = document.getElementById('results');
      const node = (root && root.querySelector('.parse-export-text')) ||
        (group && group.querySelector('.parse-export-text'));
      return node ? (node.value || '') : null;
    }
    function buildResultsExportText(group, delimiter) {
      const parseText = parseExportText(group);
      if (parseText !== null) {
        return parseText.endsWith('\n') ? parseText : (parseText + '\n');
      }
      const sets = resultsExportSets(group);
      const chunks = sets.map((set) => {
        const lines = [];
        const headers = textareaValues(set, '.result-export-header');
        if (headers.length) {
          lines.push(headers.join(delimiter));
        }
        Array.from(set.querySelectorAll('.result-export-row')).forEach((row) => {
          const cells = textareaValues(row, '.result-export-cell');
          lines.push(cells.join(delimiter));
        });
        return lines.join('\n');
      }).filter(Boolean);
      return chunks.length ? (chunks.join('\n\n') + '\n') : '';
    }
    async function submitResultsSavePanel(e) {
      if (e) {
        e.preventDefault();
      }
      const target = e && e.currentTarget ? e.currentTarget : null;
      const form = target ? target.closest('.results-save-panel-form') : document.querySelector('.results-save-panel-form');
      if (!form) {
        return false;
      }
      const group = form.closest('.result-export-group');
      if (!group) {
        return false;
      }
      const input = form.querySelector('.results-save-child');
      const rawChild = input && input.value ? input.value : nextResultsPath();
      const displayPath = normalizeChildPath(rawChild);
      const safeChild = displayPath.split('/').map(encodeURIComponent).join('/');
      const baseAction = form.getAttribute('data-base-action') || '';
      if (input) {
        input.value = displayPath;
      }
      if (knownChildPathExists(displayPath)) {
        if (!window.confirm(displayPath + ' already exists. Save anyway?')) {
          return false;
        }
      }
      const body = new URLSearchParams();
      body.set('code', buildResultsExportText(group, resultsDelimiterText(form)));
      body.set('/protocol', '/text/plain');
      setBusyCursor(true);
      try {
        const res = await fetch(baseAction + '/' + safeChild, {
          method: (form.method || 'post').toUpperCase(),
          headers: {
            'Content-Type': 'application/x-www-form-urlencoded;charset=UTF-8',
          },
          body,
          credentials: 'same-origin',
        });
        if (!res.ok) {
          throw new Error('results save failed');
        }
        registerKnownChildPath(displayPath);
        nudgeHawkTreeRefresh();
        const panel = form.closest('.results-save-panel');
        if (panel) {
          panel.classList.add('hidden');
        }
        showSaveToast(displayPath + ' saved');
      } catch (err) {
        console.error(err);
      } finally {
        setBusyCursor(false);
      }
      return false;
    }
    async function submitSavePanel(e) {
      if (e) {
        e.preventDefault();
      }
      const form = document.getElementById('save-panel-form');
      if (!form) {
        return false;
      }
      const state = getEditorTabs();
      const activeTab = state.tabs[state.active];
      if ((!activeTab || !activeTab.savedPath) && !e) {
        toggleSaveAsPanel();
        return false;
      }
      const childInput = form.querySelector('#save-panel-child');
      if (!e && childInput) {
        childInput.value = activeTab.savedPath;
      }
      syncEditorTabs();
      const meta = prepareExportForm(form);
      if (e && meta.displayPath !== (activeTab && activeTab.savedPath) && knownChildPathExists(meta.displayPath)) {
        if (!window.confirm(meta.displayPath + ' already exists. Save anyway?')) {
          return false;
        }
      }
      const textarea = document.getElementById('query-text');
      const body = new URLSearchParams();
      body.set('code', textarea ? (textarea.value || '') : '');
      body.set('/protocol', '/text/plain');
      setBusyCursor(true);
      try {
        const res = await fetch(form.action, {
          method: (form.method || 'post').toUpperCase(),
          headers: {
            'Content-Type': 'application/x-www-form-urlencoded;charset=UTF-8',
          },
          body,
          credentials: 'same-origin',
        });
        if (!res.ok) {
          throw new Error('save failed');
        }
        if (activeTab) {
          activeTab.title = meta.displayPath;
          activeTab.savedPath = meta.displayPath;
          activeTab.draftPath = null;
        }
        registerKnownChildPath(meta.displayPath);
        renderEditorTabs();
        closeFileMenu(form);
        nudgeHawkTreeRefresh();
        showSaveToast(meta.displayPath + ' saved');
      } catch (err) {
        console.error(err);
      } finally {
        setBusyCursor(false);
      }
      return false;
    }
    async function openChildPath(path) {
      const normalizedPath = normalizeChildPath(path);
      const state = getEditorTabs();
      const existingIndex = state.tabs.findIndex((tab) => tab.savedPath && normalizeChildPath(tab.savedPath) === normalizedPath);
      if (existingIndex >= 0) {
        activateEditorTab(existingIndex);
        closeFileMenu();
        return false;
      }
      setBusyCursor(true);
      try {
        const res = await fetch(childCodeUrl(normalizedPath), {
          method: 'GET',
          credentials: 'same-origin',
        });
        if (!res.ok) {
          throw new Error('open failed');
        }
        const code = await res.text();
        createEditorTab(code, normalizedPath);
        registerKnownChildPath(normalizedPath);
        closeFileMenu();
      } catch (err) {
        console.error(err);
      } finally {
        setBusyCursor(false);
      }
      return false;
    }
    function toggleOpenPanel() {
      const panel = document.getElementById('open-panel');
      if (!panel) {
        return false;
      }
      setFileMenuOpen(true);
      const hidden = panel.classList.contains('hidden');
      hideSaveAsPanel();
      if (!hidden) {
        hideOpenPanel();
        return false;
      }
      renderOpenPanel();
      panel.classList.remove('hidden');
      return false;
    }
    function toggleSaveAsPanel() {
      const form = document.getElementById('save-panel-form');
      if (!form) {
        return false;
      }
      setFileMenuOpen(true);
      const hidden = form.classList.contains('hidden');
      hideOpenPanel();
      if (!hidden) {
        hideSaveAsPanel();
        return false;
      }
      const state = getEditorTabs();
      const activeTab = state.tabs[state.active];
      if (activeTab && !activeTab.savedPath && ensureTabDraftPath(activeTab, true)) {
        renderEditorTabs();
      }
      form.classList.remove('hidden');
      const input = form.querySelector('#save-panel-child');
      if (input) {
        input.value = currentTabPath(activeTab);
        input.focus();
        input.select();
      }
      return false;
    }
    function closeFileMenu(_el) {
      setFileMenuOpen(false);
    }
    function eventInside(node, e) {
      if (!node || !e) {
        return false;
      }
      if (typeof e.composedPath === 'function') {
        return e.composedPath().includes(node);
      }
      return node.contains(e.target);
    }
    function showSaveToast(message) {
      const toast = document.getElementById('save-toast');
      const text = document.getElementById('save-toast-text');
      if (!toast || !text) {
        return;
      }
      text.textContent = message;
      toast.classList.remove('hidden');
    }
    function hideSaveToast() {
      const toast = document.getElementById('save-toast');
      if (!toast) {
        return;
      }
      toast.classList.add('hidden');
    }
    function getEditorTabs() {
      if (!window.obeliskEditorTabs) {
        const textarea = document.getElementById('query-text');
        const initial = textarea ? (textarea.value || '') : '';
        window.obeliskEditorTabs = {
          active: 0,
          nextId: 2,
          tabs: [{id: 1, title: 'tab-1', code: initial, savedPath: null, draftPath: null}]
        };
      }
      return window.obeliskEditorTabs;
    }
    function syncEditorTabs() {
      const state = getEditorTabs();
      const textarea = document.getElementById('query-text');
      if (!textarea || !state.tabs.length) {
        return;
      }
      state.tabs[state.active].code = textarea.value || '';
    }
    function focusQueryEditor() {
      const textarea = document.getElementById('query-text');
      if (textarea) {
        textarea.focus();
      }
    }
    function createEditorTab(code, savedPath) {
      const state = getEditorTabs();
      syncEditorTabs();
      const id = state.nextId++;
      state.tabs.push({
        id,
        title: savedPath || ('tab-' + id),
        code: code || '',
        savedPath: savedPath || null,
        draftPath: null
      });
      state.active = state.tabs.length - 1;
      if (!savedPath) {
        ensureTabDraftPath(state.tabs[state.active]);
      }
      renderEditorTabs();
      focusQueryEditor();
      return state.tabs[state.active];
    }
    function closeTableContextMenu() {
      const menu = document.getElementById('table-context-menu');
      if (menu) {
        menu.classList.add('hidden');
      }
      window.obeliskTableContext = null;
    }
    function syncTableContextMenu() {
      const context = window.obeliskTableContext;
      const insert = document.getElementById('table-context-insert');
      const create = document.getElementById('table-context-create');
      if (!context || !insert || !create) {
        return;
      }
      const isView = context.kind === 'view';
      insert.classList.toggle('hidden', isView);
      create.disabled = isView;
    }
    function openTableContextMenu(e, kind, db, ns, table, columnsCsv, columnSpecsCsv, keySpecsCsv) {
      if (e) {
        e.preventDefault();
        e.stopPropagation();
      }
      const menu = document.getElementById('table-context-menu');
      if (!menu) {
        return false;
      }
      const columns = String(columnsCsv || '')
        .split(',')
        .map((column) => column.trim())
        .filter(Boolean);
      const columnSpecs = String(columnSpecsCsv || '')
        .split(',')
        .map((entry) => entry.trim())
        .filter(Boolean)
        .map((entry) => {
          const [name, type] = entry.split(':');
          return {name: (name || '').trim(), type: (type || '').trim()};
        });
      const keySpecs = String(keySpecsCsv || '')
        .split(',')
        .map((entry) => entry.trim())
        .filter(Boolean)
        .map((entry) => {
          const [name, order] = entry.split(':');
          return {name: (name || '').trim(), order: (order || '').trim()};
        });
      window.obeliskTableContext = {kind, db, ns, table, columns, columnSpecs, keySpecs};
      syncTableContextMenu();
      const x = e && typeof e.clientX === 'number' ? e.clientX : 0;
      const y = e && typeof e.clientY === 'number' ? e.clientY : 0;
      menu.style.left = x + 'px';
      menu.style.top = y + 'px';
      menu.classList.remove('hidden');
      return false;
    }
    function buildTableActionCode(action, context) {
      if (action === 'SELECT') {
        return [
          'FROM ' + context.db + '.' + context.ns + '.' + context.table,
          '::SCALARS',
          '::WHERE',
          'SELECT ' + context.columns.join(', ') + ' ;'
        ].join('\n');
      }
      if (action === 'INSERT' && context.kind === 'table') {
        const valuesLine = '(' + context.columnSpecs.map((column) => '<' + column.type + '>').join(', ') + ')';
        return [
          'INSERT INTO ' + context.db + '.' + context.ns + '.' + context.table,
          '(' + context.columns.join(', ') + ')',
          'VALUES',
          valuesLine,
          valuesLine + ' ;'
        ].join('\n');
      }
      if (action === 'CREATE' && context.kind === 'table') {
        const columnLines = context.columnSpecs.map((column) => '    ' + column.name + ' ' + column.type).join(',\n');
        const keyLine = context.keySpecs.map((key) => key.name + ' ' + key.order).join(', ');
        return [
          'CREATE TABLE ' + context.db + '.' + context.ns + '.' + context.table,
          '(',
          columnLines,
          ')',
          'PRIMARY KEY (' + keyLine + ') ;'
        ].join('\n');
      }
      if (action !== 'SELECT') {
        return action + ' not enabled';
      }
      return action + ' not enabled';
    }
    function openTableActionTab(action) {
      const context = window.obeliskTableContext;
      if (!context) {
        return false;
      }
      const code = buildTableActionCode(action, context);
      closeTableContextMenu();
      createEditorTab(code, null);
      return false;
    }
    function activateEditorTab(index) {
      const state = getEditorTabs();
      if (index < 0 || index >= state.tabs.length) {
        return;
      }
      syncEditorTabs();
      state.active = index;
      renderEditorTabs();
      focusQueryEditor();
    }
    function newEditorTab() {
      createEditorTab('', null);
      closeFileMenu();
    }
    function closeCurrentTab() {
      const state = getEditorTabs();
      syncEditorTabs();
      if (state.tabs.length <= 1) {
        const id = state.nextId++;
        state.tabs = [{id, title: 'tab-' + id, code: '', savedPath: null, draftPath: null}];
        state.active = 0;
      } else {
        state.tabs.splice(state.active, 1);
        state.active = Math.max(0, state.active - 1);
      }
      ensureTabDraftPath(state.tabs[state.active]);
      renderEditorTabs();
      closeFileMenu();
      focusQueryEditor();
    }
    function renderEditorTabs() {
      const state = getEditorTabs();
      const list = document.getElementById('query-tabs-list');
      const textarea = document.getElementById('query-text');
      const closeItem = document.getElementById('close-tab-menu-item');
      const saveItem = document.getElementById('save-tab-menu-item');
      const saveFormInput = document.getElementById('save-panel-child');
      if (!list || !textarea) {
        return;
      }
      if (closeItem) {
        closeItem.disabled = (state.tabs.length <= 1);
      }
      if (saveItem) {
        const activeTab = state.tabs[state.active];
        saveItem.disabled = !(activeTab && activeTab.savedPath);
      }
      list.innerHTML = '';
      state.tabs.forEach((tab, index) => {
        const button = document.createElement('button');
        button.type = 'button';
        button.className = 'px-3 py-1 bd1 hover mono';
        button.style.borderRadius = '0.5rem 0.5rem 0 0';
        button.style.marginBottom = '-1px';
        button.style.borderBottom = '1px solid var(--b3)';
        button.textContent = tab.title;
        if (index === state.active) {
          button.classList.add('b2');
          button.style.borderBottom = '1px solid var(--b2)';
          button.style.position = 'relative';
          button.style.top = '1px';
        } else {
          button.style.opacity = '0.8';
        }
        button.addEventListener('click', () => activateEditorTab(index));
        list.appendChild(button);
      });
      if (saveFormInput) {
        const activeTab = state.tabs[state.active];
        saveFormInput.value = currentTabPath(activeTab);
      }
      textarea.value = state.tabs[state.active] ? state.tabs[state.active].code : '';
    }
    function setupEditorTabs() {
      const textarea = document.getElementById('query-text');
      const list = document.getElementById('query-tabs-list');
      const saveForm = document.getElementById('save-panel-form');
      if (!textarea || !list) {
        return;
      }
      if (!window.obeliskEditorTabsReady) {
        window.obeliskEditorTabsReady = true;
        textarea.addEventListener('input', () => syncEditorTabs());
      }
      if (saveForm && !window.obeliskSaveFormReady) {
        window.obeliskSaveFormReady = true;
        saveForm.addEventListener('submit', (e) => {
          e.preventDefault();
          submitSavePanel(e);
        });
      }
      ensureTabDraftPath(getEditorTabs().tabs[getEditorTabs().active]);
      renderEditorTabs();
    }

    function eachMatch(query, regex, build) {
      return Array.from(String(query || '').matchAll(regex))
        .map((match) => build(match))
        .filter(Boolean);
    }
    function schemaMutationSource(query) {
      let inBlock = false;
      return String(query || '').split(/\r?\n/).map((line) => {
        if (inBlock) {
          if (line.startsWith('*/')) { inBlock = false; }
          return '';
        }
        if (line.startsWith('/*')) {
          inBlock = true;
          return '';
        }
        const comment = line.indexOf('::');
        return comment >= 0 ? line.slice(0, comment) : line;
      }).join('\n');
    }
    function currentDefaultDb() {
      return document.getElementById('default-db')?.value || 'sys';
    }
    function parseNamespaceRef(raw, fallbackDb) {
      const parts = String(raw || '').toLowerCase().split('.').filter(Boolean);
      if (parts.length >= 2) {
        return {db: parts[parts.length - 2], ns: parts[parts.length - 1]};
      }
      if (parts.length === 1) {
        return {db: fallbackDb, ns: parts[0]};
      }
      return null;
    }
    function parseTableRef(raw, fallbackDb) {
      const text = String(raw || '').toLowerCase();
      const parts = text.split('.');
      const compact = parts.filter(Boolean);
      if (parts.length >= 3) {
        return {
          db: parts[0] || fallbackDb,
          ns: parts[1] || 'dbo',
          table: compact[compact.length - 1]
        };
      }
      if (compact.length === 2) {
        return {db: fallbackDb, ns: compact[0], table: compact[1]};
      }
      if (compact.length === 1) {
        return {db: fallbackDb, ns: 'dbo', table: compact[0]};
      }
      return null;
    }
    function parseColumnSpecs(body) {
      return String(body || '').split(',')
        .map((part) => part.trim().match(/^([a-z][a-z0-9-]*)\s+(@[a-z0-9-]+)\b/i))
        .filter(Boolean)
        .map((match) => [match[2].toLowerCase(), match[1].toLowerCase()]);
    }
    function parseKeySpecs(body) {
      return String(body || '').split(',')
        .map((part) => part.trim().match(/^([a-z][a-z0-9-]*)(?:\s+(asc|desc))?/i))
        .filter(Boolean)
        .map((match) => ({
          name: match[1].toLowerCase(),
          order: (match[2] || 'ASC').toUpperCase()
        }));
    }
    function schemaMutations(query) {
      const fallbackDb = currentDefaultDb();
      const mutations = [
        ...eachMatch(query, /\bcreate\s+database\s+([a-z][a-z0-9-]*)\b/gi, (match) => ({
          index: match.index,
          type: 'create-db',
          db: match[1].toLowerCase()
        })),
        ...eachMatch(query, /\bdrop\s+database\s+([a-z][a-z0-9-]*)\b/gi, (match) => ({
          index: match.index,
          type: 'drop-db',
          db: match[1].toLowerCase()
        })),
        ...eachMatch(query, /\bcreate\s+namespace\s+((?:[a-z][a-z0-9-]*\.)?[a-z][a-z0-9-]*)\b/gi, (match) => {
          const ref = parseNamespaceRef(match[1], fallbackDb);
          return ref ? {index: match.index, type: 'create-ns', ref} : null;
        }),
        ...eachMatch(query, /\bdrop\s+namespace\s+(?:force\s+)?((?:[a-z][a-z0-9-]*\.)?[a-z][a-z0-9-]*)\b/gi, (match) => {
          const ref = parseNamespaceRef(match[1], fallbackDb);
          return ref ? {index: match.index, type: 'drop-ns', ref} : null;
        }),
        ...eachMatch(query, /\bcreate\s+table\s+([a-z][a-z0-9-]*(?:(?:\.\.?)[a-z][a-z0-9-]*){0,2})\s*\(([\s\S]*?)\)\s*primary\s+key\s*\(([\s\S]*?)\)/gi, (match) => {
          const ref = parseTableRef(match[1], fallbackDb);
          if (!ref) { return null; }
          return {
            index: match.index,
            type: 'create-table',
            spec: {
              db: ref.db,
              ns: ref.ns,
              name: ref.table,
              kind: 'table',
              columns: parseColumnSpecs(match[2]),
              keys: parseKeySpecs(match[3])
            }
          };
        }),
        ...eachMatch(query, /\bdrop\s+table\s+(?:force\s+)?([a-z][a-z0-9-]*(?:(?:\.\.?)[a-z][a-z0-9-]*){0,2})\b/gi, (match) => {
          const ref = parseTableRef(match[1], fallbackDb);
          return ref ? {index: match.index, type: 'drop-table', ref} : null;
        })
      ];
      return mutations.sort((a, b) => a.index - b.index);
    }
    function sysViewSpecs() {
      return [
        {name: 'columns', columns: [
          ['@tas', 'namespace'], ['@tas', 'name'], ['@ud', 'col-ordinal'],
          ['@tas', 'col-name'], ['@ta', 'col-type']
        ]},
        {name: 'data-log', columns: [
          ['@da', 'tmsp'], ['@p', 'ship'], ['@ta', 'agent'],
          ['@tas', 'namespace'], ['@tas', 'table'], ['@ud', 'row-count']
        ]},
        {name: 'foreign-keys', columns: [
          ['@tas', 'parent-namespace'], ['@tas', 'parent-table'],
          ['@tas', 'child-namespace'], ['@tas', 'child-table'],
          ['@ud', 'ordinal'], ['@tas', 'parent-column'],
          ['@tas', 'child-column'], ['@tas', 'on-delete'],
          ['@tas', 'on-update']
        ]},
        {name: 'namespaces', columns: [
          ['@tas', 'namespace'], ['@da', 'tmsp']
        ]},
        {name: 'sys-log', columns: [
          ['@da', 'tmsp'], ['@ta', 'agent'], ['@tas', 'action'],
          ['@tas', 'component'], ['@t', 'database'], ['@t', 'namespace'],
          ['@tas', 'relation'], ['@t', 'target-database'],
          ['@t', 'target-namespace'], ['@t', 'target-relation'],
          ['@t', 'message']
        ]},
        {name: 'table-keys', columns: [
          ['@tas', 'namespace'], ['@tas', 'name'], ['@ud', 'key-ordinal'],
          ['@tas', 'key'], ['@f', 'key-ascending']
        ]},
        {name: 'tables', columns: [
          ['@tas', 'namespace'], ['@tas', 'name'], ['@ta', 'agent'],
          ['@da', 'tmsp'], ['@ud', 'row-count']
        ]}
      ].sort((a, b) => a.name.localeCompare(b.name));
    }
    function immediateSummary(details) {
      return details ? details.querySelector(':scope > summary') : null;
    }
    function makeSummary(kind, name) {
      const summary = document.createElement('summary');
      const tag = document.createElement('span');
      tag.className = 'f4 mono';
      tag.textContent = '[' + kind + ']';
      summary.appendChild(tag);
      summary.appendChild(document.createTextNode(' '));
      const label = document.createElement('span');
      label.textContent = name;
      summary.appendChild(label);
      return summary;
    }
    function makeRelationDetails(db, ns, spec) {
      const details = document.createElement('details');
      details.className = 'rel';
      details.style.position = 'relative';
      details.dataset.relation = db + '.' + ns + '.' + spec.name;
      const kind = spec.kind || 'view';
      const tagText = kind === 'table' ? '[tbl]' : '[vw]';
      const columnsCsv = spec.columns.map((entry) => entry[1]).join(',');
      const columnSpecsCsv = kind === 'table'
        ? spec.columns.map((entry) => entry[1] + ':' + entry[0]).join(',')
        : '';
      const keySpecsCsv = kind === 'table'
        ? (spec.keys || []).map((key) => key.name + ':' + key.order).join(',')
        : '';
      const openMenu = (event) => {
        return openTableContextMenu(
          event,
          kind,
          db,
          ns,
          spec.name,
          columnsCsv,
          columnSpecsCsv,
          keySpecsCsv
        );
      };
      const summary = document.createElement('summary');
      summary.style.paddingRight = '2rem';
      summary.addEventListener('contextmenu', openMenu);
      const label = document.createElement('span');
      label.className = 'fr ac g1';
      label.style.display = 'inline-flex';
      const tag = document.createElement('span');
      tag.className = 'f4 mono';
      tag.textContent = tagText;
      const name = document.createElement('span');
      name.textContent = spec.name;
      label.appendChild(tag);
      label.appendChild(name);
      summary.appendChild(label);
      details.appendChild(summary);
      const button = document.createElement('button');
      button.type = 'button';
      button.style.position = 'absolute';
      button.style.top = '0.2rem';
      button.style.right = '0.2rem';
      button.style.zIndex = '1';
      button.style.padding = '0 0.5rem';
      button.style.lineHeight = '1';
      button.addEventListener('click', (event) => {
        event.stopPropagation();
        openMenu(event);
      });
      const dots = document.createElement('span');
      dots.className = 'mono';
      dots.textContent = '...';
      button.appendChild(dots);
      details.appendChild(button);
      const columns = document.createElement('div');
      columns.className = 'p3 fc g1';
      spec.columns.forEach(([aura, column]) => {
        const row = document.createElement('summary');
        row.style.display = 'grid';
        row.style.gridTemplateColumns = '4ch 4ch 1fr';
        row.style.columnGap = '1ch';
        row.style.alignItems = 'center';
        row.appendChild(document.createElement('span'));
        const type = document.createElement('span');
        type.className = 'f4 mono';
        type.style.textAlign = 'center';
        const key = (spec.keys || []).find((entry) => entry.name === column);
        type.textContent = (key ? (key.order === 'DESC' ? '↓' : '↑') : ' ') + aura;
        const col = document.createElement('span');
        col.textContent = column;
        row.appendChild(type);
        row.appendChild(col);
        columns.appendChild(row);
      });
      details.appendChild(columns);
      return details;
    }
    function makeNamespaceDetails(db, ns, includeViews) {
      const details = document.createElement('details');
      details.dataset.ns = db + '.' + ns;
      details.appendChild(makeSummary('ns', ns));
      const body = document.createElement('div');
      body.className = 'p3 fc g1';
      if (includeViews) {
        sysViewSpecs().forEach((spec) => {
          body.appendChild(makeRelationDetails(db, ns, spec));
        });
      }
      details.appendChild(body);
      return details;
    }
    function makeDatabaseDetails(db) {
      const details = document.createElement('details');
      details.dataset.db = db;
      details.appendChild(makeSummary('db', db));
      const body = document.createElement('div');
      body.className = 'p3 fc g1';
      body.appendChild(makeNamespaceDetails(db, 'dbo', false));
      body.appendChild(makeNamespaceDetails(db, 'sys', true));
      details.appendChild(body);
      return details;
    }
    function schemaDatabases() {
      return Array.from(document.querySelectorAll('#schema > details[data-db]'));
    }
    function databaseNode(db) {
      return document.querySelector('#schema > details[data-db="' + db + '"]');
    }
    function namespaceNode(db, ns) {
      return document.querySelector('#schema details[data-ns="' + db + '.' + ns + '"]');
    }
    function expandDatabaseNode(db) {
      const node = databaseNode(db);
      if (node) { node.open = true; }
    }
    function expandNamespaceNode(db, ns) {
      const node = namespaceNode(db, ns);
      if (node) { node.open = true; }
    }
    function databaseBody(db) {
      const node = databaseNode(db);
      return node ? node.querySelector(':scope > div') : null;
    }
    function namespaceBody(db, ns) {
      const node = namespaceNode(db, ns);
      return node ? node.querySelector(':scope > div') : null;
    }
    function namespaceNodes(db) {
      const body = databaseBody(db);
      return body ? Array.from(body.querySelectorAll(':scope > details[data-ns]')) : [];
    }
    function relationNodes(db, ns) {
      const body = namespaceBody(db, ns);
      return body ? Array.from(body.querySelectorAll(':scope > details[data-relation]')) : [];
    }
    function removeDatabaseNode(db) {
      const node = databaseNode(db);
      if (node) { node.remove(); }
    }
    function insertDatabaseNode(db) {
      const schema = document.getElementById('schema');
      if (!schema || document.querySelector('#schema > details[data-db="' + db + '"]')) {
        return;
      }
      const node = makeDatabaseDetails(db);
      const next = schemaDatabases().find((el) => {
        return (el.dataset.db || '').localeCompare(db) > 0;
      });
      if (next) {
        schema.insertBefore(node, next);
      } else {
        schema.appendChild(node);
      }
      node.open = true;
    }
    function insertNamespaceNode(db, ns) {
      const body = databaseBody(db);
      const key = db + '.' + ns;
      if (!body || document.querySelector('#schema details[data-ns="' + key + '"]')) {
        expandDatabaseNode(db);
        return;
      }
      const node = makeNamespaceDetails(db, ns, ns === 'sys');
      const next = namespaceNodes(db).find((el) => {
        const name = (el.dataset.ns || '').split('.').pop();
        return name.localeCompare(ns) > 0;
      });
      if (next) {
        body.insertBefore(node, next);
      } else {
        body.appendChild(node);
      }
      expandDatabaseNode(db);
    }
    function removeNamespaceNode(db, ns) {
      expandDatabaseNode(db);
      const node = namespaceNode(db, ns);
      if (node) { node.remove(); }
    }
    function insertTableNode(spec) {
      insertNamespaceNode(spec.db, spec.ns);
      const body = namespaceBody(spec.db, spec.ns);
      const key = spec.db + '.' + spec.ns + '.' + spec.name;
      if (!body || document.querySelector('#schema details[data-relation="' + key + '"]')) {
        expandDatabaseNode(spec.db);
        expandNamespaceNode(spec.db, spec.ns);
        return;
      }
      const node = makeRelationDetails(spec.db, spec.ns, spec);
      const next = relationNodes(spec.db, spec.ns).find((el) => {
        const name = (el.dataset.relation || '').split('.').pop();
        return name.localeCompare(spec.name) > 0;
      });
      if (next) {
        body.insertBefore(node, next);
      } else {
        body.appendChild(node);
      }
      expandDatabaseNode(spec.db);
      expandNamespaceNode(spec.db, spec.ns);
    }
    function removeTableNode(ref) {
      expandDatabaseNode(ref.db);
      expandNamespaceNode(ref.db, ref.ns);
      const node = document.querySelector(
        '#schema details[data-relation="' + ref.db + '.' + ref.ns + '.' + ref.table + '"]'
      );
      if (node) { node.remove(); }
    }
    function syncDefaultDbMarker(db) {
      document.querySelectorAll('.schema-default-db').forEach((el) => el.remove());
      const node = document.querySelector('#schema > details[data-db="' + db + '"]');
      const summary = immediateSummary(node);
      if (!summary) { return; }
      summary.appendChild(document.createTextNode(' '));
      const marker = document.createElement('span');
      marker.className = 'schema-default-db f3';
      marker.textContent = '(default)';
      summary.appendChild(marker);
    }
    function setDefaultDbSelection(db) {
      const select = document.getElementById('default-db');
      if (!select) { return; }
      select.value = db;
      syncDefaultDbMarker(db);
    }
    function syncDefaultDbOption(db, shouldExist) {
      const select = document.getElementById('default-db');
      if (!select) { return; }
      const existing = Array.from(select.options).find((option) => option.value === db);
      if (!shouldExist) {
        const wasSelected = select.value === db;
        if (existing) { existing.remove(); }
        if (wasSelected) { setDefaultDbSelection('sys'); }
        return;
      }
      if (!existing) {
        const option = document.createElement('option');
        option.value = db;
        option.textContent = db;
        option.style.color = 'CanvasText';
        option.style.background = 'Canvas';
        const next = Array.from(select.options).find((el) => {
          return el.value.localeCompare(db) > 0;
        });
        if (next) {
          select.insertBefore(option, next);
        } else {
          select.appendChild(option);
        }
      }
    }
    function maybeRefreshSchema(query) {
      if (window.obeliskLastAction && window.obeliskLastAction !== 'query') {
        return;
      }
      const source = schemaMutationSource(query);
      const lower = source.toLowerCase();
      if (!lower.includes('create') && !lower.includes('drop')) { return; }
      schemaMutations(source).forEach((mutation) => {
        switch (mutation.type) {
          case 'drop-db':
            removeDatabaseNode(mutation.db);
            syncDefaultDbOption(mutation.db, false);
            break;
          case 'drop-ns':
            removeNamespaceNode(mutation.ref.db, mutation.ref.ns);
            break;
          case 'drop-table':
            removeTableNode(mutation.ref);
            break;
          case 'create-db':
            insertDatabaseNode(mutation.db);
            syncDefaultDbOption(mutation.db, true);
            setDefaultDbSelection(mutation.db);
            break;
          case 'create-ns':
            insertNamespaceNode(mutation.ref.db, mutation.ref.ns);
            break;
          case 'create-table':
            insertTableNode(mutation.spec);
            break;
        }
      });
    }
    if (!window.obeliskFileMenuHandler) {
      window.obeliskFileMenuHandler = true;
      const maybeCloseFileMenu = (e) => {
        const menu = document.getElementById('file-menu');
        if (!menu || menu.getAttribute('data-open') !== 'true') {
          return;
        }
        if (!eventInside(menu, e)) {
          closeFileMenu(menu);
        }
      };
      document.addEventListener('pointerdown', maybeCloseFileMenu, true);
      document.addEventListener('click', maybeCloseFileMenu, true);
    }
    if (!window.obeliskDevMenuHandler) {
      window.obeliskDevMenuHandler = true;
      const maybeCloseDevMenu = (e) => {
        const menu = document.getElementById('dev-menu');
        if (!menu || menu.getAttribute('data-open') !== 'true') {
          return;
        }
        if (!eventInside(menu, e)) {
          closeDevMenu();
        }
      };
      document.addEventListener('pointerdown', maybeCloseDevMenu, true);
      document.addEventListener('click', maybeCloseDevMenu, true);
    }
    if (!window.obeliskTableContextMenuHandler) {
      window.obeliskTableContextMenuHandler = true;
      document.addEventListener('pointerdown', (e) => {
        const menu = document.getElementById('table-context-menu');
        if (!menu || menu.classList.contains('hidden')) {
          return;
        }
        if (!eventInside(menu, e)) {
          closeTableContextMenu();
        }
      }, true);
      document.addEventListener('contextmenu', (e) => {
        const menu = document.getElementById('table-context-menu');
        if (!menu || menu.classList.contains('hidden')) {
          return;
        }
        if (!eventInside(menu, e)) {
          closeTableContextMenu();
        }
      }, true);
    }
    if (!window.obeliskToastHandler) {
      window.obeliskToastHandler = true;
      document.addEventListener('pointerdown', () => {
        const toast = document.getElementById('save-toast');
        if (toast && !toast.classList.contains('hidden')) {
          hideSaveToast();
        }
      }, true);
    }
    if (!window.obeliskResultsSavePanelHandler) {
      window.obeliskResultsSavePanelHandler = true;
      document.addEventListener('pointerdown', (e) => {
        document.querySelectorAll('.results-save-panel').forEach((panel) => {
          if (panel.classList.contains('hidden')) {
            return;
          }
          if (!eventInside(panel, e)) {
            const saveBtn = document.getElementById('save-results-btn');
            if (saveBtn && eventInside(saveBtn, e)) {
              return;
            }
            panel.classList.add('hidden');
          }
        });
      }, true);
    }
    if (!window.obeliskKeyHandler) {
      window.obeliskKeyHandler = true;
      window.addEventListener('keydown', (e) => {
        if (e.key == 'F5') {
          $('#run-btn').click()
        }
      })
    }
    setTimeout(setupEditorTabs, 0);
    setTimeout(prepareResultsSaveForms, 0);
    setTimeout(syncSaveResultsButton, 0);
    '''
  ==
  ::
::
::::::::::::::::::::::::::::::::::::::
::  schema tree query types
::
::
+$  schema-tree  (list database-node)
::
+$  database-node
  $:  name=@tas
      namespaces=(list namespace-node)
      ==
::
+$  namespace-node
  $:  name=@tas
      relations=(list relation-node)
      ==
::
+$  relation-kind  ?(%table %view)
+$  relation-node
  $:  kind=relation-kind
      name=@tas
      columns=(list column-node)
      keys=(list key-node)
      ==
::
+$  column-node
  $:  ordinal=@ud
      name=@tas
      type=@ta
      ==
::
+$  key-node
  $:  ordinal=@ud
      name=@tas
      ascending=?
      ==
::
+$  sys-table-row
  $:  namespace=@tas
      name=@tas
      ==
::
+$  sys-key-row
  $:  namespace=@tas
      table=@tas
      ordinal=@ud
      key=@tas
      ascending=?
      ==
::
+$  sys-column-row
  $:  namespace=@tas
      table=@tas
      ordinal=@ud
      column=@tas
      type=@ta
      ==
--
