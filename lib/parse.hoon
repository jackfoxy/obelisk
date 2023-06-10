/-  ast
!:
:: a library for parsing urQL tapes
:: (parse:parse(default-database '<db>') "<script>")
|_  default-database=@tas
::
::  +parse: parse urQL script, emitting list of high level AST structures
++  parse
  |=  script=tape
  ^-  (list command:ast)
  =/  commands  `(list command:ast)`~
  =/  script-position  [1 1]
  =/  parse-command  ;~  pose
    (cold %alter-index ;~(plug whitespace (jester 'alter') whitespace (jester 'index')))
    (cold %alter-namespace ;~(plug whitespace (jester 'alter') whitespace (jester 'namespace')))
    (cold %alter-table ;~(plug whitespace (jester 'alter') whitespace (jester 'table')))
    (cold %create-database ;~(plug whitespace (jester 'create') whitespace (jester 'database')))
    (cold %create-namespace ;~(plug whitespace (jester 'create') whitespace (jester 'namespace')))
    (cold %create-table ;~(plug whitespace (jester 'create') whitespace (jester 'table')))
    (cold %create-view ;~(plug whitespace (jester 'create') whitespace (jester 'view')))
    (cold %create-index ;~(plug whitespace (jester 'create')))  :: must be last of creates
    (cold %delete ;~(plug whitespace (jester 'delete') whitespace (jester 'from')))
    (cold %delete ;~(plug whitespace (jester 'delete')))
    (cold %drop-database ;~(plug whitespace (jester 'drop') whitespace (jester 'database')))
    (cold %drop-index ;~(plug whitespace (jester 'drop') whitespace (jester 'index')))
    (cold %drop-namespace ;~(plug whitespace (jester 'drop') whitespace (jester 'namespace')))
    (cold %drop-table ;~(plug whitespace (jester 'drop') whitespace (jester 'table')))
    (cold %drop-view ;~(plug whitespace (jester 'drop') whitespace (jester 'view')))
    (cold %grant ;~(plug whitespace (jester 'grant')))
    (cold %insert ;~(plug whitespace (jester 'insert') whitespace (jester 'into')))
    (cold %merge ;~(plug whitespace (jester 'merge') whitespace (jester 'into')))
    (cold %merge ;~(plug whitespace (jester 'merge') whitespace (jester 'from')))
    (cold %merge ;~(plug whitespace (jester 'merge')))
    (cold %query ;~(plug whitespace (jester 'from')))
    (cold %query ;~(plug whitespace ;~(pfix (jester 'select') (funk "select" (easy ' ')))))
    (cold %revoke ;~(plug whitespace (jester 'revoke')))
    (cold %truncate-table ;~(plug whitespace (jester 'truncate') whitespace (jester 'table')))
    (cold %update ;~(pfix whitespace (jester 'update')))
    (cold %with ;~(plug whitespace (jester 'with')))
    ==
  =/  dummy   ~|('Default database name is not a proper term' (scan (trip default-database) sym))
  :: main loop
  ::
  |-
  ?~  script  (flop commands)
  =/  check-empty  u.+3:q.+3:(whitespace [[1 1] script])
  ?:  =(0 (lent q.q:check-empty))                   :: trailing whitespace after last end-command (;)
    (flop commands)
  =/  command-nail  u.+3:q.+3:(parse-command [script-position script])
  ?-  `urql-command`p.command-nail
    %alter-index
      =/  index-nail  (parse-alter-index [[1 1] q.q.command-nail])
      =/  parsed  (wonk index-nail)
      =/  next-cursor
        (get-next-cursor [script-position +<.command-nail p.q.u.+3:q.+3:index-nail])
      ?:  ?=([[@ @ @ @ @] [@ @ @ @ @] @] [parsed])  ::"alter index action"
          %=  $
            script           q.q.u.+3.q:index-nail
            script-position  next-cursor
            commands
              [`command:ast`(alter-index:ast %alter-index -.parsed +<.parsed ~ +>.parsed) commands]
          ==
      ?:  ?=([[@ @ @ @ @] [@ @ @ @ @] [[@ @ @] %~]] [parsed]) ::"alter index single column"
        %=  $
          script           q.q.u.+3.q:index-nail
          script-position  next-cursor
          commands
            [`command:ast`(alter-index:ast %alter-index -.parsed +<.parsed +>.parsed %rebuild) commands]
        ==
      ?:  ?=([[@ @ @ @ @] [@ @ @ @ @] * @] [parsed])  ::"alter index columns action"
        %=  $
          script           q.q.u.+3.q:index-nail
          script-position  next-cursor
          commands
            [`command:ast`(alter-index:ast %alter-index -.parsed +<.parsed +>-.parsed +>+.parsed) commands]
        ==
      ?:  ?=([[@ @ @ @ @] [@ @ @ @ @] *] [parsed])  ::"alter index multiple columns"
        %=  $
          script           q.q.u.+3.q:index-nail
          script-position  next-cursor
          commands
            [`command:ast`(alter-index:ast %alter-index -.parsed +<.parsed +>.parsed %rebuild) commands]
        ==
      ~|("Cannot parse alter-index {<p.q.command-nail>}" !!)
    %alter-namespace
      =/  namespace-nail  (parse-alter-namespace [[1 1] q.q.command-nail])
      =/  parsed  (wonk namespace-nail)
      =/  next-cursor
        (get-next-cursor [script-position +<.command-nail p.q.u.+3:q.+3:namespace-nail])
      %=  $
        script           q.q.u.+3.q:namespace-nail
        script-position  next-cursor
        commands
          [`command:ast`(alter-namespace:ast %alter-namespace -<.parsed ->.parsed +<.parsed +>+>+<.parsed +>+>+>.parsed) commands]
      ==
    %alter-table
      =/  table-nail  (parse-alter-table [[1 1] q.q.command-nail])
      =/  parsed  (wonk table-nail)
      =/  next-cursor
        (get-next-cursor [script-position +<.command-nail p.q.u.+3:q.+3:table-nail])
      ?:  =(+<.parsed %alter-column)
        %=  $
          script           q.q.u.+3.q:table-nail
          script-position  next-cursor
          commands
            [`command:ast`(alter-table:ast %alter-table -.parsed +>.parsed ~ ~ ~ ~) commands]
        ==
      ?:  =(+<.parsed %add-column)
        %=  $
          script           q.q.u.+3.q:table-nail
          script-position  next-cursor
          commands
            [`command:ast`(alter-table:ast %alter-table -.parsed ~ +>.parsed ~ ~ ~) commands]
        ==
      ?:  =(+<.parsed %drop-column)
        %=  $
          script           q.q.u.+3.q:table-nail
          script-position  next-cursor
          commands
            [`command:ast`(alter-table:ast %alter-table -.parsed ~ ~ +>.parsed ~ ~) commands]
        ==
      ?:  =(+<.parsed %add-fk)
        %=  $
          script           q.q.u.+3.q:table-nail
          script-position  next-cursor
          commands
            [`command:ast`(alter-table:ast %alter-table -.parsed ~ ~ ~ (build-foreign-keys [-.parsed +>.parsed]) ~) commands]
        ==
      ?:  =(+<.parsed %drop-fk)
        %=  $
          script           q.q.u.+3.q:table-nail
          script-position  next-cursor
          commands
            [`command:ast`(alter-table:ast %alter-table -.parsed ~ ~ ~ ~ +>.parsed) commands]
        ==
      ~|("Cannot parse table {<p.q.command-nail>}" !!)
    %create-database
      ~|  'Create database must be only statement in script'
      ?>  =((lent commands) 0)
      %=  $
        script  ""
        commands
          [`command:ast`(create-database:ast %create-database p.u.+3:q.+3:(parse-face [[1 1] q.q.command-nail])) commands]
      ==
    %create-index
      =/  index-nail  (parse-create-index [[1 1] q.q.command-nail])
      =/  parsed  (wonk index-nail)
      =/  next-cursor
        (get-next-cursor [script-position +<.command-nail p.q.u.+3:q.+3:index-nail])
      ?:  ?=([@ [* *]] [parsed])                    ::"create index ..."
        %=  $
          script           q.q.u.+3.q:index-nail
          script-position  next-cursor
          commands
            [`command:ast`(create-index:ast %create-index -.parsed +<.parsed %.n %.n +>.parsed) commands]
        ==
      ?:  ?=([[@ @] [* *]] [parsed])
        ?:  =(-<.parsed %unique)                    ::"create unique index ..."
            %=  $
              script           q.q.u.+3.q:index-nail
              script-position  next-cursor
              commands
                [`command:ast`(create-index:ast %create-index ->.parsed +<.parsed %.y %.n +>.parsed) commands]
            ==
        ?:  =(-<.parsed %clustered)                 ::"create clustered index ..."
            %=  $
              script           q.q.u.+3.q:index-nail
              script-position  next-cursor
              commands
                [`command:ast`(create-index:ast %create-index ->.parsed +<.parsed %.n %.y +>.parsed) commands]
            ==
        ?:  =(-<.parsed %nonclustered)              ::"create nonclustered index ..."
            %=  $
              script           q.q.u.+3.q:index-nail
              script-position  next-cursor
              commands
                [`command:ast`(create-index:ast %create-index ->.parsed +<.parsed %.n %.n +>.parsed) commands]
            ==
        ~|("Cannot parse index {<p.q.command-nail>}" !!)
      ?:  ?=([[@ @ @] [* *]] [parsed])
        ?:  =(->-.parsed %clustered)                ::"create unique clustered index ..."
            %=  $
              script           q.q.u.+3.q:index-nail
              script-position  next-cursor
              commands
                [`command:ast`(create-index:ast %create-index ->+.parsed +<.parsed %.y %.y +>.parsed) commands]
            ==
        ?:  =(->-.parsed %nonclustered)             ::"create unique nonclustered index ..."
            %=  $
              script           q.q.u.+3.q:index-nail
              script-position  next-cursor
              commands
                [`command:ast`(create-index:ast %create-index ->+.parsed +<.parsed %.y %.n +>.parsed) commands]
            ==
        ~|("Cannot parse index {<p.q.command-nail>}" !!)
      ~|("Cannot parse index {<p.q.command-nail>}" !!)
    %create-namespace
      =/  create-namespace-nail  (parse-create-namespace [[1 1] q.q.command-nail])
      =/  parsed  (wonk create-namespace-nail)
      =/  next-cursor
        (get-next-cursor [script-position +<.command-nail p.q.u.+3:q.+3:create-namespace-nail])
      ?@  parsed
        %=  $
          script           q.q.u.+3.q:create-namespace-nail
          script-position  next-cursor
          commands         [`command:ast`(create-namespace:ast %create-namespace default-database parsed) commands]
        ==
      %=  $
        script           q.q.u.+3.q:create-namespace-nail
        script-position  next-cursor
        commands         [`command:ast`(create-namespace:ast %create-namespace -.parsed +.parsed) commands]
      ==
    %create-table
      =/  table-nail  (parse-create-table [[1 1] q.q.command-nail])
      =/  parsed  (wonk table-nail)
      =/  next-cursor
        (get-next-cursor [script-position +<.command-nail p.q.u.+3:q.+3:table-nail])
      ?:  ?=([* * [@ @ *]] parsed)
        %=  $                                       :: no foreign keys
          script           q.q.u.+3.q:table-nail
          script-position  next-cursor
          commands
            [`command:ast`(create-table:ast %create-table -.parsed +<.parsed (create-primary-key [-.parsed +>.parsed]) ~) commands]
        ==
      %=  $
        script           q.q.u.+3.q:table-nail
        script-position  next-cursor
        commands
          [`command:ast`(create-table:ast %create-table -.parsed +<.parsed (create-primary-key [-.parsed +>-.parsed]) (build-foreign-keys [-.parsed +>+.parsed])) commands]
      ==
    %create-view
      !!
    %delete
      =/  delete-nail  (parse-delete [[1 1] q.q.command-nail])
      =/  parsed  (wonk delete-nail)
      =/  next-cursor
        (get-next-cursor [script-position +<.command-nail p.q.u.+3:q.+3:delete-nail])
      %=  $
        script           q.q.u.+3.q:delete-nail
        script-position  next-cursor
        commands
          [`command:ast`(transform:ast %transform ~ [(produce-delete parsed) ~ ~]) commands]
      ==
    %drop-database
      =/  drop-database-nail  (parse-drop-database [[1 1] q.q.command-nail])
      =/  parsed  (wonk drop-database-nail)
      =/  next-cursor
        (get-next-cursor [script-position +<.command-nail p.q.u.+3:q.+3:drop-database-nail])
      ?@  parsed                                    :: name
        %=  $
          script           q.q.u.+3.q:drop-database-nail
          script-position  next-cursor
          commands         [`command:ast`(drop-database:ast %drop-database parsed %.n) commands]
        ==
      ~|  "Cannot parse drop-database {<parsed>}"
      ?:  ?=([@ @] parsed)                          :: force name
        %=  $
          script           q.q.u.+3.q:drop-database-nail
          script-position  next-cursor
          commands         [`command:ast`(drop-database:ast %drop-database +.parsed %.y) commands]
        ==
      !!
    %drop-index
      =/  drop-index-nail  (parse-drop-index [[1 1] q.q.command-nail])
      =/  parsed  (wonk drop-index-nail)
      =/  next-cursor
        (get-next-cursor [script-position +<.command-nail p.q.u.+3:q.+3:drop-index-nail])
      %=  $
        script           q.q.u.+3.q:drop-index-nail
        script-position  next-cursor
        commands         [`command:ast`(drop-index:ast %drop-index -.parsed +.parsed) commands]
      ==
    %drop-namespace
      =/  drop-namespace-nail  (parse-drop-namespace [[1 1] q.q.command-nail])
      =/  parsed  (wonk drop-namespace-nail)
      =/  next-cursor
        (get-next-cursor [script-position +<.command-nail p.q.u.+3:q.+3:drop-namespace-nail])
      ?@  parsed                                    :: name
        %=  $
          script           q.q.u.+3.q:drop-namespace-nail
          script-position  next-cursor
          commands         [`command:ast`(drop-namespace:ast %drop-namespace default-database parsed %.n) commands]
        ==
      ?:  ?=([@ @] parsed)                          :: force name
        ?:  =(%force -.parsed)
          %=  $
            script           q.q.u.+3.q:drop-namespace-nail
            script-position  next-cursor
            commands         [`command:ast`(drop-namespace:ast %drop-namespace default-database +.parsed %.y) commands]
          ==
        %=  $                                       :: db.name
          script           q.q.u.+3.q:drop-namespace-nail
          script-position  next-cursor
          commands         [`command:ast`(drop-namespace:ast %drop-namespace -.parsed +.parsed %.n) commands]
        ==
      ~|  "Cannot parse drop-namespace {<parsed>}"
      ?:  ?=([* [@ @]] parsed)                      :: force db.name
        %=  $
          script           q.q.u.+3.q:drop-namespace-nail
          script-position  next-cursor
          commands         [`command:ast`(drop-namespace:ast %drop-namespace +<.parsed +>.parsed %.y) commands]
        ==
      !!
    %drop-table
      =/  drop-table-nail  (drop-table-or-view [[1 1] q.q.command-nail])
      =/  parsed  (wonk drop-table-nail)
      =/  next-cursor
        (get-next-cursor [script-position +<.command-nail p.q.u.+3:q.+3:drop-table-nail])
      ?:  ?=([@ @ @ @ @ @] parsed)                  :: force qualified table name
        %=  $
          script           q.q.u.+3.q:drop-table-nail
          script-position  next-cursor
          commands
            [`command:ast`(drop-table:ast %drop-table +.parsed %.y) commands]
        ==
      ?:  ?=([@ @ @ @ @] parsed)                    :: qualified table name
        %=  $
          script           q.q.u.+3.q:drop-table-nail
          script-position  next-cursor
          commands
            [`command:ast`(drop-table:ast %drop-table parsed %.n) commands]
        ==
      ~|("Cannot parse drop-table {<parsed>}" !!)
    %drop-view
      =/  drop-view-nail  (drop-table-or-view [[1 1] q.q.command-nail])
      =/  parsed  (wonk drop-view-nail)
      =/  next-cursor
        (get-next-cursor [script-position +<.command-nail p.q.u.+3:q.+3:drop-view-nail])
      ?:  ?=([@ @ @ @ @ @] parsed)                  :: force qualified view
        %=  $
          script           q.q.u.+3.q:drop-view-nail
          script-position  next-cursor
          commands
            [`command:ast`(drop-view:ast %drop-view +.parsed %.y) commands]
        ==
      ?:  ?=([@ @ @ @ @] parsed)                    :: qualified view
        %=  $
          script           q.q.u.+3.q:drop-view-nail
          script-position  next-cursor
          commands
            [`command:ast`(drop-view:ast %drop-view parsed %.n) commands]
        ==
      ~|("Cannot parse drop-view {<parsed>}" !!)
    %grant
      =/  grant-nail  (parse-grant [[1 1] q.q.command-nail])
      =/  parsed  (wonk grant-nail)
      =/  next-cursor
        (get-next-cursor [script-position +<.command-nail p.q.u.+3:q.+3:grant-nail])
      ?:  ?=([@ [@ [@ %~]] [@ @]] [parsed])         ::"grant adminread to ~sampel-palnet on database db"
        %=  $
          script           q.q.u.+3.q:grant-nail
          script-position  next-cursor
          commands
            [`command:ast`(grant:ast %grant -.parsed +<+.parsed +>.parsed) commands]
        ==
      ?:  ?=([@ @ [@ @]] [parsed])                  ::"grant adminread to parent on database db"
        %=  $
          script           q.q.u.+3.q:grant-nail
          script-position  next-cursor
          commands
            [`command:ast`(grant:ast %grant -.parsed +<.parsed +>.parsed) commands]
        ==
      ?:  ?=([@ [@ [@ *]] [@ *]] [parsed])          ::"grant Readwrite to ~zod,~bus,~nec,~sampel-palnet on namespace db.ns"
        %=  $                                       ::"grant adminread to ~zod,~bus,~nec,~sampel-palnet on namespace ns" (ns previously cooked)
          script           q.q.u.+3.q:grant-nail    ::"grant Readwrite to ~zod,~bus,~nec,~sampel-palnet on db.ns.table"
          script-position  next-cursor
          commands
            [`command:ast`(grant:ast %grant -.parsed +<+.parsed +>.parsed) commands]
        ==
      ?:  ?=([@ @ [@ [@ *]]] [parsed])              ::"grant readonly to siblings on namespace db.ns"
        %=  $                                       ::"grant readwrite to moons on namespace ns" (ns previously cooked)
          script           q.q.u.+3.q:grant-nail
          script-position  next-cursor
          commands
            [`command:ast`(grant:ast %grant -.parsed +<.parsed +>.parsed) commands]
        ==
      ~|("Cannot parse grant {<parsed>}" !!)
    %insert
      =/  insert-nail  (parse-insert [[1 1] q.q.command-nail])
      =/  parsed  (wonk insert-nail)
      =/  next-cursor
        (get-next-cursor [script-position +<.command-nail p.q.u.+3:q.+3:insert-nail])
      %=  $
        script           q.q.u.+3.q:insert-nail
        script-position  next-cursor
        commands
          [`command:ast`(transform:ast %transform ~ [(produce-insert parsed) ~ ~]) commands]
      ==
    %merge
      =/  merge-nail  (parse-merge [[1 1] q.q.command-nail])
      =/  parsed  (wonk merge-nail)
      =/  next-cursor
        (get-next-cursor [script-position +<.command-nail p.q.u.+3:q.+3:merge-nail])
      %=  $
        script           q.q.u.+3.q:merge-nail
        script-position  next-cursor
        commands
          [`command:ast`(transform:ast %transform ~ [(produce-merge parsed) ~ ~]) commands]
      ==
    %query
      =/  query-nail  (parse-query [[1 1] q.q.command-nail])
      =/  parsed  (wonk query-nail)
      =/  next-cursor
        (get-next-cursor [script-position +<.command-nail p.q.u.+3:q.+3:query-nail])
      %=  $
        script           q.q.u.+3.q:query-nail
        script-position  next-cursor
        commands
          [`command:ast`(transform:ast %transform ~ [(produce-query parsed) ~ ~]) commands]
      ==
    %revoke
      =/  revoke-nail  (parse-revoke [[1 1] q.q.command-nail])
      =/  parsed  (wonk revoke-nail)
      =/  next-cursor
        (get-next-cursor [script-position +<.command-nail p.q.u.+3:q.+3:revoke-nail])
      ?:  ?=([@ [@ [@ %~]] [@ @]] [parsed])         ::"revoke adminread from ~sampel-palnet on database db"
        %=  $
          script           q.q.u.+3.q:revoke-nail
          script-position  next-cursor
          commands
            [`command:ast`(revoke:ast %revoke -.parsed +<+.parsed +>.parsed) commands]
        ==
      ?:  ?=([@ @ [@ @]] [parsed])                  ::"revoke adminread from parent on database db"
        %=  $
          script           q.q.u.+3.q:revoke-nail
          script-position  next-cursor
          commands
            [`command:ast`(revoke:ast %revoke -.parsed +<.parsed +>.parsed) commands]
        ==
      ?:  ?=([@ [@ [@ *]] [@ *]] [parsed])          ::"revoke Readwrite from ~zod,~bus,~nec,~sampel-palnet on namespace db.ns"
        %=  $                                       ::"revoke adminread from ~zod,~bus,~nec,~sampel-palnet on namespace ns" (ns previously cooked)
          script           q.q.u.+3.q:revoke-nail   ::"revoke Readwrite from ~zod,~bus,~nec,~sampel-palnet on db.ns.table"
          script-position  next-cursor
          commands
            [`command:ast`(revoke:ast %revoke -.parsed +<+.parsed +>.parsed) commands]
        ==
      ?:  ?=([@ @ [@ [@ *]]] [parsed])              ::"revoke readonly from siblings on namespace db.ns"
        %=  $                                       ::"revoke readwrite from moons on namespace ns" (ns previously cooked)
          script           q.q.u.+3.q:revoke-nail
          script-position  next-cursor
          commands
            [`command:ast`(revoke:ast %revoke -.parsed +<.parsed +>.parsed) commands]
        ==
      ~|("Cannot parse revoke {<parsed>}" !!)
    %truncate-table
      =/  truncate-table-nail  (parse-truncate-table [[1 1] q.q.command-nail])
      =/  next-cursor
        (get-next-cursor [script-position +<.command-nail p.q.u.+3:q.+3:truncate-table-nail])
      %=  $
        script           q.q.u.+3.q:truncate-table-nail
        script-position  next-cursor
        commands
          [`command:ast`(truncate-table:ast %truncate-table (wonk truncate-table-nail)) commands]
      ==
    %update
      =/  update-nail  (parse-update [[1 1] q.q.command-nail])
      =/  parsed  (wonk update-nail)
      =/  next-cursor
        (get-next-cursor [script-position +<.command-nail p.q.u.+3:q.+3:update-nail])
      %=  $
        script           q.q.u.+3.q:update-nail
        script-position  next-cursor
        commands
          [`command:ast`(transform:ast %transform ~ [(produce-update parsed) ~ ~]) commands]
      ==
    %with
      =/  with-nail  (parse-with [[1 1] q.q.command-nail])
      =/  parsed  (wonk with-nail)
      =/  next-cursor
        (get-next-cursor [script-position +<.command-nail p.q.u.+3:q.+3:with-nail])
      ?:  =(+<.parsed %delete)
        %=  $
          script           q.q.u.+3.q:with-nail
          script-position  next-cursor
          commands  [`command:ast`(transform:ast %transform (produce-ctes -.parsed) [(produce-delete +>.parsed) ~ ~]) commands]
        ==
      ?:  =(+<.parsed %insert)
        %=  $
          script           q.q.u.+3.q:with-nail
          script-position  next-cursor
          commands  [`command:ast`(transform:ast %transform (produce-ctes -.parsed) [(produce-insert +>.parsed) ~ ~]) commands]
        ==
      ?:  =(+<.parsed %merge)
        %=  $
          script           q.q.u.+3.q:with-nail
          script-position  next-cursor
          commands  [`command:ast`(transform:ast %transform (produce-ctes -.parsed) [(produce-merge +>.parsed) ~ ~]) commands]
        ==  
      ?:  =(+<.parsed %query)
        %=  $
          script           q.q.u.+3.q:with-nail
          script-position  next-cursor
          commands  [`command:ast`(transform:ast %transform (produce-ctes -.parsed) [(produce-query +>.parsed) ~ ~]) commands]
        ==
      ?:  =(+<.parsed %update)
        %=  $
          script           q.q.u.+3.q:with-nail
          script-position  next-cursor
          commands  [`command:ast`(transform:ast %transform (produce-ctes -.parsed) [(produce-update +>.parsed) ~ ~]) commands]
        ==
      ~|("cannot parse 'with':  {<parsed>}" !!)
    ==
+$  urql-command
  $%
    %alter-index
    %alter-namespace
    %alter-table
    %create-database
    %create-index
    %create-namespace
    %create-table
    %create-view
    %delete
    %drop-database
    %drop-index
    %drop-namespace
    %drop-table
    %drop-view
    %grant
    %insert
    %merge
    %query
    %revoke
    %truncate-table
    %update
    %with
  ==
::
::  helper types
::
+$  interim-key
  $:
    %interim-key
    is-clustered=?
    columns=(list ordered-column:ast)
  ==
+$  parens        ?(%pal %par)
+$  raw-predicate-component  ?(parens predicate-component:ast predicate:ast)
+$  raw-predicate-component2  ?(parens predicate-component:ast)
+$  group-by-list  (list grouping-column:ast)
+$  order-by-list  (list ordering-column:ast)
::
::  +get-next-cursor:  get next position in script
++  get-next-cursor
  |=  [last-cursor=[@ud @ud] command-hair=[@ud @ud] end-hair=[@ud @ud]]
  ^-  [@ud @ud]
  =/  next-hair  ?:  (gth -.command-hair 1)                   :: if we advanced to next input line
        [(sub (add -.command-hair -.last-cursor) 1) +.command-hair]       ::   add lines and use last column
      [-.command-hair (sub (add +.command-hair +.last-cursor) 1)]         :: else add column positions
  ?:  (gth -.end-hair 1)                                      :: if we advanced to next input line
    [(sub (add -.next-hair -.end-hair) 1) +.end-hair]         ::   add lines and use last column
  [-.next-hair (sub (add +.next-hair +.end-hair) 1)]          :: else add column positions
::
::  parser rules and helpers
::
++  whitespace  ~+  (star ;~(pose gah (just '\09') (just '\0d')))
++  prn-less-soz  ~+  ;~(less (just `@`39) (just `@`127) (shim 32 256))
::
::  +crub-no-text: crub:so without text parsing
++  crub-no-text
  ~+
  ;~  pose
    (cook |=(det=date `dime`[%da (year det)]) when:so)
  ::
    %+  cook
      |=  [a=(list [p=?(%d %h %m %s) q=@]) b=(list @)]
      =+  rop=`tarp`[0 0 0 0 b]
      |-  ^-  dime
      ?~  a
        [%dr (yule rop)]
      ?-  p.i.a
        %d  $(a t.a, d.rop (add q.i.a d.rop))
        %h  $(a t.a, h.rop (add q.i.a h.rop))
        %m  $(a t.a, m.rop (add q.i.a m.rop))
        %s  $(a t.a, s.rop (add q.i.a s.rop))
      ==
    ;~  plug
      %+  most
        dot
      ;~  pose
        ;~(pfix (just 'd') (stag %d dim:ag))
        ;~(pfix (just 'h') (stag %h dim:ag))
        ;~(pfix (just 'm') (stag %m dim:ag))
        ;~(pfix (just 's') (stag %s dim:ag))
      ==
      ;~(pose ;~(pfix ;~(plug dot dot) (most dot qix:ab)) (easy ~))
    ==
  ::
    (stag %p fed:ag)
  ==
::
::  +jester: match a cord, case agnostic, thanks ~tinnus-napbus
++  jester
  |=  daf=@t
  |=  tub=nail
  ~+
  =+  fad=daf
  |-  ^-  (like @t)
  ?:  =(`@`0 daf)
    [p=p.tub q=[~ u=[p=fad q=tub]]]
  =+  n=(end 3 daf)
  ?.  ?&  ?=(^ q.tub)
          ?|  =(n i.q.tub)
              &((lte 97 n) (gte 122 n) =((sub n 32) i.q.tub))
              &((lte 65 n) (gte 90 n) =((add 32 n) i.q.tub))
          ==
      ==
    (fail tub)
  $(p.tub (lust i.q.tub p.tub), q.tub t.q.tub, daf (rsh 3 daf))
::
::  qualified objects, usually table or view
::  maximally qualified by @p.database.namespace
::  minimally qualified by namespace
::
::  +cook-qualified-2object: namespace.object-name
++  cook-qualified-2object
  |=  a=*
  ?@  a
    (qualified-object:ast %qualified-object ~ default-database 'dbo' a)
  (qualified-object:ast %qualified-object ~ default-database -.a +.a)
::
::  +cook-qualified-3object: database.namespace.object-name
++  cook-qualified-3object
  |=  a=*
  ?:  ?=([@ @ @] a)                                 :: db.ns.name
    (qualified-object:ast %qualified-object ~ -.a +<.a +>.a)
  ?:  ?=([@ @ @ @] a)                               :: db..name
    (qualified-object:ast %qualified-object ~ -.a 'dbo' +>+.a)
  ?:  ?=([@ @] a)                                   :: ns.name
    (qualified-object:ast %qualified-object ~ default-database -.a +.a)
  ?@  a                                             :: name
    (qualified-object:ast %qualified-object ~ default-database 'dbo' a)
  ~|("cannot parse qualified-object  {<a>}" !!)
::
::  +cook-qualified-object: @p.database.namespace.object-name
++  cook-qualified-object
  |=  a=*
  ?:  ?=([@ @ @ @] a)
    ?:  =(+<.a '.')
      (qualified-object:ast %qualified-object ~ -.a 'dbo' +>+.a)  :: db..name
    (qualified-object:ast %qualified-object `-.a +<.a +>-.a +>+.a)  :: ~firsub.db.ns.name
  ?:  ?=([@ @ @ @ @ @] a)                           :: ~firsub.db..name
    (qualified-object:ast %qualified-object `-.a +>-.a 'dbo' +>+>+.a)
  ?:  ?=([@ @ @] a)
    (qualified-object:ast %qualified-object ~ -.a +<.a +>.a)  :: db.ns.name
  ?:  ?=([@ @] a)                                   :: ns.name
    (qualified-object:ast %qualified-object ~ default-database -.a +.a)
  ?@  a                                             :: name
    (qualified-object:ast %qualified-object ~ default-database 'dbo' a)
  ~|("cannot parse qualified-object  {<a>}" !!)
::  +qualified-namespace: database.namespace
++  qualified-namespace
  |=  [a=* default-database=@t]
  ?:  ?=([@ @] [a])
    a
  [default-database a]
++  parse-qualified-2-name  ;~(pose ;~(pfix whitespace ;~((glue dot) sym sym)) parse-face)
::
::  +parse-qualified-3: database.namespace.object-name
++  parse-qualified-3  ;~  pose
  ;~((glue dot) sym sym sym)
  ;~(plug sym dot dot sym)
  ;~((glue dot) sym sym)
  sym
  ==
++  parse-qualified-3object  (cook cook-qualified-3object ;~(pfix whitespace parse-qualified-3))
++  parse-qualified-object  (cook cook-qualified-object ;~(pose ;~((glue dot) parse-ship sym sym sym) ;~(plug parse-ship:parse dot sym dot dot sym) ;~(plug sym dot dot sym) parse-qualified-3))
::
::  working with atomic value literals
::
++  cord-literal  ~+
  (cook |=(a=(list @t) [%t (crip a)]) (ifix [soq soq] (star ;~(pose (cold '\'' (jest '\\\'')) prn-less-soz))))
++  numeric-parser  ;~  pose
  (stag %ud (full dem:ag))                          :: formatted @ud
  (stag %ud (full dim:ag))                          :: unformatted @ud, no leading 0s
  (stag %ub (full bay:ag))                          :: formatted @ub, no leading 0s
  (stag %ux ;~(pfix (jest '0x') (full hex:ag)))     :: formatted @ux
  (full tash:so)                                    :: @sd or @sx
  (stag %rs (full royl-rs:so))                      :: @rs
  (stag %rd (full royl-rd:so))                      :: @rd
  (stag %uw (full wiz:ag))                          :: formatted @uw base-64 unsigned
  ==
++  non-numeric-parser  ;~  pose
  cord-literal
  ;~(pose ;~(pfix sig crub-no-text) crub-no-text)   :: @da, @dr, @p
  (stag %is ;~(pfix (just '.') bip:ag))             :: @is
  (stag %if ;~(pfix (just '.') lip:ag))             :: @if
  (stag %f ;~(pose (cold & (jester 'y')) (cold | (jester 'n'))))  :: @if
  ==
++  cook-numbers                                    :: works for insert values
  |=  a=(list @t)
  (scan a numeric-parser)
++  sear-numbers                                    :: works for predicate values
  |=  a=(list @t)
  =/  parsed  (numeric-parser [[1 1] a])
  ?~  q.parsed  ~
  (some (wonk parsed))
++  numeric-characters  ~+
  ::  including base-64 characters
  (star ;~(pose (shim 48 57) (shim 65 90) (shim 97 122) dot fas hep lus sig tis))
++  parse-value-literal  ;~  pose
  non-numeric-parser
  (sear sear-numbers numeric-characters)            :: all numeric parsers
  ==
++  insert-value  ~+  ;~  pose
  (cold [%default %default] (jester 'default'))
  ;~(pose non-numeric-parser (cook cook-numbers numeric-characters))
  ==
++  get-value-literal  ~+  ;~  pose                     :: changing to ifix here slowed down test cases
  ;~(sfix ;~(pfix whitespace parse-value-literal) whitespace)
  ;~(pfix whitespace parse-value-literal)
  ;~(sfix parse-value-literal whitespace)
  parse-value-literal
  ==
++  cook-literal-list
  ::  1. all literal types must be the same
  ::
  ::  2. (a-co:co d) each atom to tape, weld tapes with delimiter, crip final tape
  ::  bad reason for (2): cannot ?=(expression ...) when expression includes a list
  ::
  |=  a=(list value-literal:ast)
  ~+
  =/  literal-type=@tas  -<.a
  =/  b  a
  =/  literal-list=tape  ~
  |-
  ?:  =(b ~)  (value-literal-list:ast %value-literal-list literal-type (crip literal-list))
  ?:  =(-<.b literal-type)
    ?:  =(literal-list ~)
      $(b +.b, literal-list (a-co:co ->.b))
    $(b +.b, literal-list (weld (weld (a-co:co ->.b) ";") literal-list))
  ~|("cannot parse literal-list  {<a>}" !!)
++  value-literal-list
  (cook cook-literal-list ;~(pose ;~(pfix whitespace (ifix [pal par] (more com get-value-literal))) (ifix [pal par] (more com get-value-literal))))
++  parse-insert-value  ;~  pose
  ;~(pfix whitespace ;~(sfix insert-value whitespace))
  ;~(pfix whitespace insert-value)
  ;~(sfix insert-value whitespace)
  insert-value
  ==
::
::  used for various commands
::
++  cook-column
  |=  a=*
    ?:  ?=([@ @] [a])
      (column:ast %column -.a +.a)
    ~|("cannot parse column  {<a>}" !!)
++  cook-ordered-column
  |=  a=*
    ?@  a
      (ordered-column:ast %ordered-column a %.y)
    ?:  ?=([@ @] [a])
      ?:  =(+.a %asc)
        (ordered-column:ast %ordered-column -.a %.y)
      (ordered-column:ast %ordered-column -.a %.n)
    ~|("cannot parse ordered-column  {<a>}" !!)
++  cook-referential-integrity
  |=  a=*
  ?:  ?=([[@ @] @ @] [a])                           :: <type> cascade, <type> cascade
    ?:  =(%delete -<.a)
      ?:  =(%update +<.a)
        ~[%delete-cascade %update-cascade]
      !!
    ?:  =(%update -<.a)
      ?:  =(%delete +<.a)
        ~[%delete-cascade %update-cascade]
      !!
    !!
  ?:  ?=([@ @] [a])                                 :: <type> cascade
    ?:  =(-.a %delete)  [%delete-cascade ~]  [%update-cascade ~]
  ?:  ?=([[@ @] @ @ [@ %~] @] [a])                  :: <type> cascade, <type> no action
    ?:  =(-<.a %delete)  [%delete-cascade ~]  [%update-cascade ~]
  ?:  ?=([[@ @ [@ %~] @] @ @] [a])                  :: <type> no action, <type> cascade
    ?:  =(+<.a %delete)  [%delete-cascade ~]  [%update-cascade ~]
  ?:  ?=([@ [@ %~]] a)                              :: <type> no action
    ~
  ?:  ?=([[@ @ [@ %~] @] @ @ [@ %~] @] a)           :: <type> no action, <type> no action
    ~
  ~|("cannot parse ordered-column  {<a>}" !!)
++  end-or-next-command  ;~  plug
  (cold %end-command ;~(pose ;~(plug whitespace mic) whitespace mic))
  (easy ~)
  ==
++  alias
  %+  cook
    |=(a=tape (rap 3 ^-((list ,@) a)))
  ;~(plug alf (star ;~(pose nud alf)))
++  parse-alias  ;~(pfix whitespace alias)
++  parse-face  ;~(pfix whitespace sym)
++  face-list  ;~(pfix whitespace (ifix [pal par] (more com ;~(pose ;~(sfix parse-face whitespace) parse-face))))
++  ordering  ;~(pfix whitespace ;~(pose (jester 'asc') (jester 'desc')))
++  clustering  ;~(pfix whitespace ;~(pose (jester 'clustered') (jester 'nonclustered')))
++  ordered-column-list
  ;~(pfix whitespace (ifix [pal par] (more com (cook cook-ordered-column ;~(pose ;~(sfix ;~(plug parse-face ordering) whitespace) ;~(plug parse-face ordering) ;~(sfix parse-face whitespace) parse-face)))))
++  parse-ship  ;~(pfix sig fed:ag)
++  ship-list  (more com ;~(pose ;~(sfix ;~(pfix whitespace parse-ship) whitespace) ;~(pfix whitespace parse-ship) ;~(sfix parse-ship whitespace) parse-ship))
++  on-database  ;~(plug (jester 'database') parse-face)
++  on-namespace
  ;~(plug (jester 'namespace') (cook |=(a=* (qualified-namespace [a default-database])) parse-qualified-2-name))
++  grant-object
  ;~(pfix whitespace ;~(pfix (jester 'on') ;~(pfix whitespace ;~(pose on-database on-namespace parse-qualified-3object))))
++  parse-aura  ~+
  =/  root-aura  ;~  pose
    (jest '@c')
    (jest '@da')
    (jest '@dr')
    (jest '@f')
    (jest '@if')
    (jest '@is')
    (jest '@p')
    (jest '@q')
    (jest '@rh')
    (jest '@rs')
    (jest '@rd')
    (jest '@rq')
    (jest '@sb')
    (jest '@sd')
    (jest '@sv')
    (jest '@sw')
    (jest '@sx')
    (jest '@ta')
    (jest '@tas')
    (jest '@t')
    (jest '@ub')
    (jest '@ud')
    (jest '@uv')
    (jest '@uw')
    (jest '@ux')
    ==
  ;~  pose
    ;~(plug root-aura (shim 'A' 'J'))
    root-aura
  ==
++  aggregate-name
  |=  name=@t
  ^-  @t
  (crip (cass (trip name)))
++  column-defintion-list
  =/  column-definition  ;~  plug
    sym
    ;~(pfix whitespace parse-aura)
    ==
  (more com (cook cook-column ;~(pose ;~(pfix whitespace ;~(sfix column-definition whitespace)) ;~(sfix column-definition whitespace) ;~(pfix whitespace column-definition) column-definition)))
++  referential-integrity  ;~  plug
  ;~(pfix ;~(plug whitespace (jester 'on') whitespace) ;~(pose (jester 'update') (jester 'delete')))
  ;~(pfix whitespace ;~(pose (jester 'cascade') ;~(plug (jester 'no') whitespace (jester 'action'))))
  ==
++  column-definitions  ;~(pfix whitespace (ifix [pal par] column-defintion-list))
++  alter-columns  ;~  plug
  (cold %alter-column ;~(plug whitespace (jester 'alter') whitespace (jester 'column')))
  column-definitions
  ==
++  add-columns  ;~  plug
  (cold %add-column ;~(plug whitespace (jester 'add') whitespace (jester 'column')))
  column-definitions
  ==
++  drop-columns  ;~  plug
  (cold %drop-column ;~(plug whitespace (jester 'drop') whitespace (jester 'column')))
  face-list
  ==
++  parse-datum  ~+  ;~  pose
  ;~(pose ;~(pfix whitespace parse-qualified-column) parse-qualified-column)
  ;~(pose ;~(pfix whitespace parse-value-literal) parse-value-literal)
  ==
++  cook-aggregate
  |=  parsed=*
  [%aggregate -.parsed +.parsed]
++  parse-aggregate  ;~  pose
  (cook cook-aggregate ;~(pfix whitespace ;~(plug ;~(sfix parse-alias pal) ;~(sfix get-datum par))))
  (cook cook-aggregate ;~(plug ;~(sfix parse-alias pal) ;~(sfix get-datum par)))
  ==
++  cook-selected-aggregate
  |=  parsed=*
  [%selected-aggregate -.parsed +.parsed]
++  parse-selected-aggregate  ;~  pose
  (cook cook-selected-aggregate ;~(pfix whitespace ;~(plug ;~(sfix parse-alias pal) ;~(sfix get-datum par))))
  (cook cook-selected-aggregate ;~(plug ;~(sfix parse-alias pal) ;~(sfix get-datum par)))
  ==
::
::  indices
::
++  cook-primary-key
  |=  a=*
  ~+
  ?@  -.a
    ?:  =(-.a 'clustered')  (interim-key %interim-key %.y +.a)  (interim-key %interim-key %.n +.a)
  (interim-key %interim-key %.n a)
++  cook-foreign-key
  |=  a=*
  ?:  ?=([[@ * * [@ @] *] *] [a])                   :: foreign key ns.table ... references fk-table ... on action on action
    (foreign-key:ast %foreign-key -<.a ->-.a ->+<-.a ->+<+.a ->+>.a +.a)
  ?:  ?=([[@ [[@ @ @] %~] @ [@ %~]] *] [a])         :: foreign key table ... references fk-table ... on action on action
    (foreign-key:ast %foreign-key -<.a ->-.a ->+<-.a 'dbo' ->+.a +.a)
  ~|("cannot parse foreign-key  {<a>}" !!)
++  build-foreign-keys
  |=  a=[table=qualified-object:ast f-keys=(list *)]
  =/  f-keys  +.a
  =/  foreign-keys  `(list foreign-key:ast)`~
  |-
  ?:  =(~ f-keys)
    (flop foreign-keys)
  ?@  -<.f-keys
    %=  $                                           :: foreign key table must be in same DB as table
      foreign-keys  [(foreign-key:ast %foreign-key -<.f-keys -.a ->-.f-keys (qualified-object:ast %qualified-object ~ ->+<.a ->+<+>+<.f-keys ->+<+>+>.f-keys) ->+>.f-keys ~) foreign-keys]
      f-keys        +.f-keys
    ==
  %=  $                                             :: foreign key table must be in same DB as table
    foreign-keys  [(foreign-key:ast %foreign-key -<-.f-keys -.a -<+<.f-keys (qualified-object:ast %qualified-object ~ ->+<.a -<+>->+>-.f-keys -<+>->+>+.f-keys) -<+>+.f-keys ->.f-keys) foreign-keys]
    f-keys        +.f-keys
  ==
++  foreign-key-literal  ;~(plug whitespace (jester 'foreign') whitespace (jester 'key'))
++  foreign-key
  ;~(plug parse-face ordered-column-list ;~(pfix ;~(plug whitespace (jester 'references')) ;~(plug (cook cook-qualified-2object parse-qualified-2-name) face-list)))
++  full-foreign-key  ;~  pose
  ;~(plug foreign-key (cook cook-referential-integrity ;~(plug referential-integrity referential-integrity)))
  ;~(plug foreign-key (cook cook-referential-integrity ;~(plug referential-integrity referential-integrity)))
  ;~(plug foreign-key (cook cook-referential-integrity referential-integrity))
  ;~(plug foreign-key (cook cook-referential-integrity referential-integrity))
  foreign-key
  ==
++  add-foreign-key  ;~  plug
  (cold %add-fk ;~(plug whitespace (jester 'add')))
  ;~(pfix foreign-key-literal (more com full-foreign-key))
  ==
++  drop-foreign-key  ;~  plug
  (cold %drop-fk ;~(plug whitespace (jester 'drop') whitespace (jester 'foreign') whitespace (jester 'key')))
  face-list
  ==
++  primary-key
  (cook cook-primary-key ;~(pfix ;~(plug whitespace (jester 'primary') whitespace (jester 'key')) ;~(pose ;~(plug clustering ordered-column-list) ordered-column-list)))
++  create-primary-key
  |=  a=[[@ ship=(unit @p) database=@t namespace=@t name=@t] key=*]
  =/  key-name  (crip (weld (weld "ix-primary-" (trip namespace.a)) (weld "-" (trip name.a))))
  (create-index:ast %create-index key-name (qualified-object:ast %qualified-object ~ database.a namespace.a name.a) %.y +<:key.a +>:key.a)
::
::  query object and joins
::
++  join-stop  ;~  pose
  ;~(plug (jester 'where') whitespace)
  ;~(plug (jester 'scalar') whitespace)
  ;~(plug (jester 'group') whitespace)
  ;~(plug (jester 'select') whitespace)
  ;~(plug (jester 'join') whitespace)
  ;~(plug (jester 'left') whitespace)
  ;~(plug (jester 'right') whitespace)
  ;~(plug (jester 'outer') whitespace)
  ;~(plug (jester 'cross') whitespace)
  ;~(plug (jester 'on') whitespace)
  ==
++  query-object  ;~  pose
  ;~(plug parse-qualified-object ;~(pfix whitespace ;~(pfix (jester 'as') parse-alias)))
  ;~(plug parse-qualified-object ;~(pfix whitespace ;~(less join-stop parse-alias)))
  parse-qualified-object
  (stag %query-row ;~(plug face-list ;~(pfix whitespace ;~(pfix (jester 'as') parse-alias))))
  (stag %query-row ;~(plug face-list ;~(pfix whitespace ;~(less join-stop parse-alias))))
  (stag %query-row face-list)
  ==
++  parse-query-object  ;~  pfix
  whitespace
  (cook build-query-object query-object)
  ==
++  parse-join-type  ;~  pfix  whitespace  ;~  pose
    (cold %join (jester 'join'))
    (cold %left-join ;~(plug (jester 'left') whitespace (jester 'join')))
    (cold %right-join ;~(plug (jester 'right') whitespace (jester 'join')))
    (cold %outer-join-all ;~(plug (jester 'outer') whitespace (jester 'join') whitespace (jester 'all')))
    (cold %outer-join ;~(plug (jester 'outer') whitespace (jester 'join')))
    ==
  ==
++  parse-cross-join-type  ;~  pfix
  whitespace
  (cold %cross-join ;~(plug (jester 'cross') whitespace (jester 'join')))
  ==
++  build-query-object
  |=  parsed=*
  ?:  ?=([@ @ @ @ @] parsed)
    (table-set:ast %table-set parsed ~)
  ?:  ?=([[@ @ @ @ @] @] parsed)
    (table-set:ast %table-set -.parsed `+.parsed)
  ?:  =(%query-row -.parsed)  parsed
  ~|("cannot parse query-object  {<parsed>}" !!)
++  parse-cross-joined-object  ;~(plug parse-cross-join-type parse-query-object)
++  parse-joined-object  ;~  plug
  parse-join-type
  parse-query-object
  ;~(pfix whitespace ;~(pfix (jester 'on') parse-predicate))
  ==
++  parse-object-and-joins  ;~  plug
  parse-query-object
  ;~(pose parse-cross-joined-object (star parse-joined-object))
  ==
::
::  column in "join on" or "where" predicate, qualified or aliased
::  indeterminate qualification and aliasing is determined later
::
++  cook-qualified-column
  |=  a=*
  ~+
  ?:  ?=([@ @ @ @ @] a)                                       :: @p.db.ns.object.column
    (qualified-column:ast %qualified-column (qualified-object:ast %qualified-object `-.a +<.a +>-.a +>+<.a) +>+>.a ~)
  ?:  ?=([@ @ @ @ @ @] a)                                     :: @p.db..object.column
    (qualified-column:ast %qualified-column (qualified-object:ast %qualified-object `-.a +<.a 'dbo' +>+>-.a) +>+>+.a ~)
  ?:  ?=([@ @ @ @] a)                                         :: db..object.column; db.ns.object.column
    ?:  =(+<.a '.')
    (qualified-column:ast %qualified-column (qualified-object:ast %qualified-object ~ -.a 'dbo' +>-.a) +>+.a ~)
  (qualified-column:ast %qualified-column (qualified-object:ast %qualified-object ~ -.a +<.a +>-.a) +>+.a ~)
  ?:  ?=([@ @ @] a)                                           :: ns.object.column
    (qualified-column:ast %qualified-column (qualified-object:ast %qualified-object ~ default-database -.a +<.a) +>.a ~)
  ?:  ?=([@ @] a)                                             :: something.column (could be table, table alias or cte)
    (qualified-column:ast %qualified-column (qualified-object:ast %qualified-object ~ 'UNKNOWN' 'COLUMN' -.a) +.a ~)
  ?@  a                                                       :: column, column alias, or cte
    (qualified-column:ast %qualified-column (qualified-object:ast %qualified-object ~ 'UNKNOWN' 'COLUMN-OR-CTE' a) a ~)
  ~|("cannot parse qualified-column  {<a>}" !!)
++  parse-column  ~+  ;~  pose
  ;~((glue dot) parse-ship sym sym sym sym)
  ;~(plug parse-ship ;~(pfix dot sym) dot dot sym ;~(pfix dot sym))
  ;~((glue dot) sym sym sym sym)
  ;~(plug sym dot ;~(pfix dot sym) ;~(pfix dot sym))
  ;~((glue dot) sym sym sym)
  ;~(plug mixed-case-symbol ;~(pfix dot sym))
  sym
  ==
++  parse-qualified-column  ~+  (cook cook-qualified-column parse-column)
::
::  predicate
::
++  parse-operator  ~+  ;~  pose
    ::  binary operators
  (cold %eq (just '='))
  (cold %neq ;~(pose (jest '<>') (jest '!=')))
  (cold %gte ;~(pose (jest '>=') (jest '!<')))
  (cold %lte ;~(pose (jest '<=') (jest '!>')))
  (cold %gt (just '>'))
  (cold %lt (just '<'))
  (cold %and ;~(plug (jester 'and') whitespace))
  (cold %or ;~(plug (jester 'or') whitespace))
  (cold %equiv ;~(plug (jester 'equiv') whitespace))
  (cold %not-equiv ;~(plug (jester 'not') whitespace (jester 'equiv') whitespace))
    :: unary operators
  (cold %not ;~(plug (jester 'not') whitespace))
  (cold %exists ;~(plug (jester 'exists') whitespace))
  (cold %in ;~(plug (jester 'in') whitespace))
  (cold %any ;~(plug (jester 'any') whitespace))
  (cold %all ;~(plug (jester 'all') whitespace))
    :: ternary operator
  (cold %between ;~(plug (jester 'between') whitespace))
    :: nesting
  (cold %pal pal)
  (cold %par par)
  ==
++  predicate-list
  |=  a=*
  ^-  (list raw-predicate-component2)
  =/  new-list=(list raw-predicate-component2)  ~
  |-
  ?:  =(a ~)  (flop new-list)
  ?:  ?=(parens -.a)                  $(new-list [i=`parens`-.a t=new-list], a +.a)
  ?:  ?=(ops-and-conjs:ast -.a)       $(new-list [i=`ops-and-conjs:ast`-.a t=new-list], a +.a)
  ?:  ?=(qualified-column:ast -.a)    $(new-list [i=`qualified-column:ast`-.a t=new-list], a +.a)
  ?:  ?=(value-literal:ast -.a)       $(new-list [i=`value-literal:ast`-.a t=new-list], a +.a)
  ?:  ?=(value-literal-list:ast -.a)  $(new-list [i=`value-literal-list:ast`-.a t=new-list], a +.a)
  ?:  ?&(=(%aggregate:ast -<.a) ?=(@ ->-.a) ?=(qualified-column:ast ->+.a))
    $(new-list [i=(aggregate:ast %aggregate (aggregate-name ->-.a) `qualified-column:ast`->+.a) t=new-list], a +.a)
  ~|("problem with predicate noun:  {<a>}" !!)
++  predicate-stop  ~+  ;~  pose
  ;~(plug whitespace mic)
  mic
  ;~(plug whitespace (jester 'where') whitespace)
  ;~(plug whitespace (jester 'when') whitespace)
  ;~(plug whitespace (jester 'select') whitespace)
  ;~(plug whitespace (jester 'as') whitespace)
  ;~(plug whitespace (jester 'join') whitespace)
  ;~(plug whitespace (jester 'left') whitespace)
  ;~(plug whitespace (jester 'right') whitespace)
  ;~(plug whitespace (jester 'outer') whitespace)
  ;~(plug whitespace (jester 'then') whitespace)
  ;~(plug whitespace (jester 'group') whitespace (jester 'by') whitespace)
  ==
++  predicate-part  ~+  ;~  pose
  parse-aggregate
  value-literal-list
  ;~(pose ;~(pfix whitespace parse-operator) parse-operator)
  parse-datum
  ==
++  parse-predicate
  (star ;~(less predicate-stop predicate-part))
  ::
  ::  when not qualified by () right conjunction takes precedence and "or" takes precedence over "and"
  ::
  ::  1=1 and 1=3 (false)
  ::       /\
  ::    1=1  11=3
  ::
  ::  1=1 and 1=3 and 1=4 (false)
  ::               /\
  ::              &  1=4
  ::             /\
  ::          1=1  1=3
  ::
  ::  1=2 and 3=3 and 1=4 or 1=1 (true)
  ::                      /\
  ::                     &  1=1
  ::                    /\
  ::                   &  1=4
  ::                  /\
  ::               1=1  3=3
  ::
  ::  1=2 and 3=3 and 1=4 or 1=1 and 1=4 (false)
  ::                      /\
  ::                     &  1=1 and 1=4
  ::                    /\
  ::                   &  1=4
  ::                  /\
  ::               1=2  3=3
  ::
  ::  1=2 and 3=3 and 1=4 or 1=1 and 1=4 or 2=2 (true)
  ::                                     /\
  ::                                    |  2=2
  ::                                   /\
  ::                                  &  1=1 and 1=4
  ::                                 /\
  ::                                &  1=4
  ::                               /\
  ::                            1=2  3=3
  ::
  ::  1=2 and 3=3 and 1=4 or 1=1 and 1=4 or 2=2 and 3=2 (false)
  ::                                     /\
  ::                                    |  2=2 and 3=2
  ::                                   /\
  ::                                  &  1=1 and 1=4
  ::                                 /\
  ::                                &  1=4
  ::                               /\
  ::                            1=2  3=3
  ::
++  produce-predicate
  |=  parsed=(list raw-predicate-component2)
  ^-  predicate:ast
  =/  working-tree=predicate:ast       ~
  =/  tree-stack=(list predicate:ast)  ~
  |-
  ?:  =((lent parsed) 0)
    |-
      ?~  tree-stack
        working-tree
      %=  $
        working-tree
          ?~  ->-.tree-stack  [-<.tree-stack working-tree ~]
            [-<.tree-stack ->-.tree-stack working-tree]
        tree-stack    +.tree-stack
      ==
  ?-  -.parsed
    %pal              :: push working predicate onto the stack
      ?~  working-tree  $(parsed +.parsed)
      %=  $
        tree-stack    [working-tree tree-stack]
        working-tree  ~
        parsed        +.parsed
      ==
    %par              :: pop the stack, updating next working tree
      ?~  tree-stack  $(parsed +.parsed)
      %=  $
        tree-stack    +.tree-stack
        working-tree
          ?~  ->-.tree-stack  [-<.tree-stack working-tree ~]
          [-<.tree-stack ->-.tree-stack working-tree]
        parsed        +.parsed
      ==
    unary-op:ast
      ?~  working-tree
        %=  $
          working-tree  [-.parsed ~ ~]
          parsed        +.parsed
        ==
      ?~  l.working-tree
        ?:  ?&(=(%not -.working-tree) =(%exists -.parsed))
          ?>  ?=(qualified-column:ast +<.parsed)
          %=  $
            working-tree  [-.working-tree [-.parsed [+<.parsed ~ ~] ~] ~]
            parsed        +>.parsed
          ==
        ~|("invalid compbination of unary operators {<-.working-tree>} and {<-.parsed>}" !!)
      ?~  r.working-tree  ~|("unary-op, right tree empty  {<working-tree>}" !!)
      ~|("unary-op can't get here  {<working-tree>}" !!)
    binary-op:ast
      ?~  working-tree    !!
      ?~  l.working-tree  ~|("binary-op, left tree empty  {<working-tree>}" !!)
      ?~  r.working-tree  ~|("binary-op, right tree empty  {<working-tree>}" !!)
      ~|("binary-op can't get here  {<working-tree>}" !!)
    ternary-op:ast
      ?~  working-tree    !!
      ?~  l.working-tree  ~|("ternary-op, left tree empty  {<working-tree>}" !!)
      ?~  r.working-tree  ~|("ternary-op, right tree empty  {<working-tree>}" !!)
      ~|("ternary-op can't get here  {<working-tree>}" !!)
    conjunction:ast
      ?~  working-tree
        %=  $
          working-tree  [-.parsed ~ ~]
          parsed        +.parsed
        ==
      ?~  l.working-tree  ~|("conjunction, left tree empty  {<working-tree>}" !!)
      ?~  r.working-tree  ~|("conjunction, right tree empty  {<working-tree>}" !!)
      %=  $
        working-tree  [-.parsed working-tree ~]
        parsed        +.parsed
      ==
    all-any-op:ast
      ?~  working-tree  ~|("operator {<-.parsed>} can only follow equality or inequality operator" !!)
      ?~  r.working-tree
        ?:  ?&(?=(binary-op:ast n.working-tree) ?!(=(%in n.working-tree)))
          ?:  ?=(value-literal-list:ast +<.parsed)
            %=  $
              working-tree  [-.working-tree +<.working-tree [-.parsed [+<.parsed ~ ~] ~]]
              parsed        +>.parsed
            ==
          ?:  ?=(qualified-column:ast +<.parsed)
            %=  $
              working-tree  [-.working-tree +<.working-tree [-.parsed [+<.parsed ~ ~] ~]]
              parsed        +>.parsed
            ==
          ~|("all-any-op {<-.parsed>} must target CTE or literal list {<+<.parsed>}" !!)
        ~|("all-any-op {<-.parsed>} can only follow equality or inequality operator" !!)
      ~|("all-any-op {<-.parsed>} can't get here, working-tree {<working-tree>}" !!)
    qualified-column:ast
      ?~  working-tree
        ?:  ?=(binary-op:ast +<.parsed)
          %=  $
            working-tree  [+<.parsed [-.parsed ~ ~] ~]
            parsed        +>.parsed
          ==
        ?:  ?=(unary-op:ast +<.parsed)
          ?:  ?&(=(%not +<.parsed) =(%between +>-.parsed))
            ?:  =(%and +>+>-.parsed)
              %=  $
                working-tree
                  [%not [%between (produce-predicate ~[-.parsed %gte +>+<.parsed]) (produce-predicate ~[-.parsed %lte +>+>+<.parsed])] ~]
                parsed  +>+>+>.parsed
              ==
            %=  $
              working-tree
                [%not [%between (produce-predicate ~[-.parsed %gte +>+<.parsed]) (produce-predicate ~[-.parsed %lte +>+>-.parsed])] ~]
              parsed  +>+>+.parsed
            ==
          ?:  =(%in +>-.parsed)
            %=  $
              working-tree  [%not (produce-predicate ~[-.parsed %in +>+<.parsed]) ~]
              parsed        +>+>.parsed
            ==
          ~|("unary-op {<+<.parsed>} can't get here after qualified-column, working-tree {<working-tree>}" !!)
        ?:  =(%between +<.parsed)
          ?:  =(%and +>+<.parsed)
            %=  $
              working-tree
                [%between (produce-predicate ~[-.parsed %gte +>-.parsed]) (produce-predicate ~[-.parsed %lte +>+>-.parsed])]
              parsed  +>+>+.parsed
            ==
          %=  $
            working-tree
              [%between (produce-predicate ~[-.parsed %gte +>-.parsed]) (produce-predicate ~[-.parsed %lte +>+<.parsed])]
            parsed  +>+>.parsed
          ==
        ~|("qualified-column can't get here after {<+<.parsed>} , working-tree {<working-tree>}" !!)
      ?~  l.working-tree
        %=  $
          working-tree  [-.working-tree [-.parsed ~ ~] ~]
          parsed        +.parsed
        ==
      ?~  r.working-tree
        ?:  ?=(conjunction:ast -.working-tree)
          %=  $
            working-tree  ~
            tree-stack    [working-tree tree-stack]
          ==
        %=  $
          working-tree  [-.working-tree +<.working-tree [-.parsed ~ ~]]
          parsed        +.parsed
        ==
      ~|("qualified-column can't get here" !!)
    value-literal:ast
      ?~  working-tree
        ?:  ?=(binary-op:ast +<.parsed)
          %=  $
            working-tree  [+<.parsed [-.parsed ~ ~] ~]
            parsed        +>.parsed
          ==
        ?:  ?=(unary-op:ast +<.parsed)
          ?:  ?&(=(%not +<.parsed) =(%between +>-.parsed))
            ?:  =(%and +>+>-.parsed)
              %=  $
                working-tree
                  [%not [%between (produce-predicate ~[-.parsed %gte +>+<.parsed]) (produce-predicate ~[-.parsed %lte +>+>+<.parsed])] ~]
                parsed  +>+>+>.parsed
              ==
            %=  $
              working-tree
                [%not [%between (produce-predicate ~[-.parsed %gte +>+<.parsed]) (produce-predicate ~[-.parsed %lte +>+>-.parsed])] ~]
              parsed  +>+>+.parsed
            ==
          ?:  =(%in +>-.parsed)
            %=  $
              working-tree  [%not (produce-predicate ~[-.parsed %in +>+<.parsed]) ~]
              parsed        +>+>.parsed
            ==
          ~|("unary-op {<+<.parsed>} can't get here after value-literal, working-tree {<working-tree>}" !!)
        ?:  =(%between +<.parsed)
          ?:  =(%and +>+<.parsed)
            %=  $
              working-tree
                [%between (produce-predicate ~[-.parsed %gte +>-.parsed]) (produce-predicate ~[-.parsed %lte +>+>-.parsed])]
              parsed  +>+>+.parsed
            ==
          %=  $
            working-tree
              [%between (produce-predicate ~[-.parsed %gte +>-.parsed]) (produce-predicate ~[-.parsed %lte +>+<.parsed])]
            parsed  +>+>.parsed
          ==
        ~|("value-literal can't get here after {<+<.parsed>} , working-tree {<working-tree>}" !!)
      ?~  l.working-tree
        %=  $
          working-tree  [-.working-tree [-.parsed ~ ~] ~]
          parsed        +.parsed
        ==
      ?~  r.working-tree
        ?:  ?=(conjunction:ast -.working-tree)
          %=  $
            working-tree  ~
            tree-stack    [working-tree tree-stack]
          ==
        %=  $
          working-tree  [-.working-tree +<.working-tree [-.parsed ~ ~]]
          parsed        +.parsed
        ==
      ~|("value-literal can't get here" !!)
    aggregate:ast
      ?~  working-tree
        ?:  ?=(binary-op:ast +<.parsed)
          %=  $
            working-tree  [+<.parsed [-.parsed ~ ~] ~]
            parsed        +>.parsed
          ==
        ?:  ?=(unary-op:ast +<.parsed)
          ?:  ?&(=(%not +<.parsed) =(%between +>-.parsed))
            ?:  =(%and +>+>-.parsed)
              %=  $
                working-tree
                  [%not [%between (produce-predicate ~[-.parsed %gte +>+<.parsed]) (produce-predicate ~[-.parsed %lte +>+>+<.parsed])] ~]
                parsed  +>+>+>.parsed
              ==
            %=  $
              working-tree
                [%not [%between (produce-predicate ~[-.parsed %gte +>+<.parsed]) (produce-predicate ~[-.parsed %lte +>+>-.parsed])] ~]
              parsed  +>+>+.parsed
            ==
          ?:  =(%in +>-.parsed)
            %=  $
              working-tree  [%not (produce-predicate ~[-.parsed %in +>+<.parsed]) ~]
              parsed        +>+>.parsed
            ==
          ~|("unary-op {<+<.parsed>} can't get here after aggregate, working-tree {<working-tree>}" !!)
        ?:  =(%between +<.parsed)
          ?:  =(%and +>+<.parsed)
            %=  $
              working-tree
                [%between (produce-predicate ~[-.parsed %gte +>-.parsed]) (produce-predicate ~[-.parsed %lte +>+>-.parsed])]
              parsed  +>+>+.parsed
            ==
          %=  $
            working-tree
              [%between (produce-predicate ~[-.parsed %gte +>-.parsed]) (produce-predicate ~[-.parsed %lte +>+<.parsed])]
            parsed  +>+>.parsed
          ==
        ~|("aggregate can't get here after {<+<.parsed>} , working-tree {<working-tree>}" !!)
      ?~  l.working-tree
        %=  $
          working-tree  [-.working-tree [-.parsed ~ ~] ~]
          parsed        +.parsed
        ==
      ?~  r.working-tree
        ?:  ?=(conjunction:ast -.working-tree)
          %=  $
            working-tree  ~
            tree-stack    [working-tree tree-stack]
          ==
        %=  $
          working-tree  [-.working-tree +<.working-tree [-.parsed ~ ~]]
          parsed        +.parsed
        ==
      ~|("selected-aggregate can't get here" !!)
    value-literal-list:ast
      ?~  working-tree    ~|("Literal list in a predicate can only follow the IN operator" !!)
      ?~  l.working-tree  !!
      ?~  r.working-tree
        %=  $
          working-tree  [-.working-tree +<.working-tree [-.parsed ~ ~]]
          parsed        +.parsed
        ==
      ~|("value-literal-list can't get here" !!)
  ==
::
::  parse scalar
::
++  get-datum  ~+  ;~  pose
  ;~(sfix parse-qualified-column whitespace)
  ;~(sfix parse-value-literal whitespace)
  ;~(sfix parse-datum whitespace)
  parse-datum
  ==
::++  cook-if
::  |=  parsed=*
::  ^-  if-then-else:ast
::  (if-then-else:ast %if-then-else -.parsed +>-.parsed +>+>-.parsed)
++  parse-if  ;~  plug
    parse-predicate
    ;~(pfix whitespace (cold %then (jester 'then')))
    ;~(pose scalar-body parse-datum)
    ;~(pfix whitespace (cold %else (jester 'else')))
    ;~(pose scalar-body parse-datum)
    ;~(pfix whitespace (cold %endif (jester 'endif')))
  ==
++  parse-when-then  ;~  plug
    ;~(pfix whitespace (cold %when (jester 'when')))
    ;~(pose parse-predicate parse-datum)
    ;~(pfix whitespace (cold %then (jester 'then')))
    ;~(pose parse-aggregate scalar-body parse-datum)
  ==
++  parse-case-else  ;~  plug
    ;~(pfix whitespace (cold %else (jester 'else')))
    ;~(pfix whitespace ;~(pose parse-aggregate scalar-body parse-datum))
    ;~(pfix whitespace (cold %end (jester 'end')))
  ==
++  cook-case
  |=  parsed=*
  ~+
  =/  raw-cases   +<.parsed
  =/  cases=(list case-when-then:ast)  ~
  |-
  ?.  =(raw-cases ~)
    $(cases [(case-when-then:ast ->-.raw-cases ->+>.raw-cases) cases], raw-cases +.raw-cases)
  ?:  ?=(qualified-column:ast -.parsed)
    ?:  =('else' +>-.parsed)  (case:ast %case -.parsed (flop cases) +>+<.parsed)
      (case:ast %case -.parsed (flop cases) ~)
  ?:  ?=(value-literal:ast -.parsed)
    ?:  =('else' +>-.parsed)  (case:ast %case -.parsed (flop cases) +>+<.parsed)
      (case:ast %case -.parsed (flop cases) ~)
  ~|("cannot parse case  {<parsed>}" !!)
++  parse-case  ;~  plug
  parse-datum
  (star parse-when-then)
  ;~(pose parse-case-else ;~(pfix whitespace (cold %end (jester 'end'))))
  ==
::++  cook-coalesce
::  |=  parsed=(list datum:ast)
::  ^-  coalesce:ast
::  (coalesce:ast %coalesce parsed)
++  scalar-token  ;~  pose
    ;~(pfix whitespace (cold %end (jester 'end')))
    ;~(pfix whitespace ;~(plug (cold %if (jester 'if')) parse-if))
    ;~(plug (cold %if (jester 'if')) parse-if)
    ;~(pfix whitespace ;~(plug (cold %case (jester 'case')) parse-case))
    ;~(plug (cold %case (jester 'case')) parse-case)
    ;~(pfix whitespace ;~(plug (cold %coalesce (jester 'coalesce')) parse-coalesce))
    ;~(plug (cold %coalesce (jester 'coalesce')) parse-coalesce)
    (cold %pal ;~(plug whitespace pal))
    (cold %pal pal)
    (cold %par ;~(plug whitespace par))
    (cold %par par)
    (cold %lus ;~(plug whitespace lus))
    (cold %lus lus)
    (cold %hep ;~(plug whitespace hep))
    (cold %hep hep)
    (cold %tar ;~(plug whitespace tar))
    (cold %tar tar)
    (cold %fas ;~(plug whitespace fas))
    (cold %fas fas)
    (cold %ket ;~(plug whitespace ket))
    (cold %ket ket)
    parse-datum
  ==
++  parse-coalesce  ~+  (more com ;~(pose parse-aggregate get-datum))
++  parse-math  ;~  plug
  (cold %begin (jester 'begin'))
  (star scalar-token)
  ==
++  parse-scalar-body  %+  knee  *noun
  |.  ~+
   ;~  pose
    ;~(plug (cold %if (jester 'if')) parse-if)
    ;~(plug (cold %case (jester 'case')) parse-case)
    ;~(plug (cold %coalesce (jester 'coalesce')) parse-coalesce)
    parse-math
  ==
++  scalar-stop  ;~  pose
  ;~(plug whitespace (jester 'where'))
  ;~(plug whitespace (jester 'scalar'))
  ;~(plug whitespace (jester 'select'))
  ==
++  scalar-body  ;~(pfix whitespace parse-scalar-body)
++  parse-scalar-part  ~+  ;~  plug
  (cold %scalar ;~(pfix whitespace (jester 'scalar')))
  parse-face
  ==
++  parse-scalar  ;~  pose
  ;~(plug parse-scalar-part ;~(pfix ;~(plug whitespace (jester 'as')) scalar-body))
  ;~(plug parse-scalar-part scalar-body)
  ==
::
::  select
::
++  parse-alias-all  (stag %all-columns ;~(sfix parse-alias ;~(plug dot tar)))
++  parse-object-all  (stag %all-columns ;~(sfix parse-qualified-object ;~(plug dot tar)))
++  parse-selection  ~+  ;~  pose
  ;~(plug ;~(sfix parse-selected-aggregate whitespace) (cold %as (jester 'as')) ;~(pfix whitespace alias))
  parse-selected-aggregate
  parse-alias-all
  parse-object-all
  ;~(plug ;~(sfix ;~(pose parse-qualified-column parse-value-literal) whitespace) (cold %as (jester 'as')) ;~(pfix whitespace alias))
  ;~(pose parse-qualified-column parse-value-literal)
  (cold %all tar)
  ==
++  select-column  ;~  pose
  (ifix [whitespace whitespace] parse-selection)
  ;~(plug whitespace parse-selection)
  parse-selection
  ==
++  select-columns  ;~  pose
  (more com select-column)
  select-column
  ==
++  select-top-bottom  ;~  plug
  (cold %top ;~(plug whitespace (jester 'top')))
  ;~(pfix whitespace dem)
  (cold %bottom ;~(plug whitespace (jester 'bottom')))
  ;~(pfix whitespace dem)
  select-columns
  ==
++  select-top  ;~  plug
  (cold %top ;~(plug whitespace (jester 'top')))
  ;~(pfix whitespace dem)
  ;~(less ;~(plug whitespace (jester 'bottom')) select-columns)
  ==
++  select-bottom  ;~  plug
  (cold %bottom ;~(plug whitespace (jester 'bottom')))
  ;~(pfix whitespace dem)
  select-columns
  ==
++  parse-select  ;~  plug
  (cold %select ;~(plug whitespace (jester 'select')))
  ;~  pose
    select-top-bottom
    select-top
    select-bottom
    select-columns
    ==
  ==
::
::  group and order by
::
++  parse-grouping-column  (ifix [whitespace whitespace] ;~(pose parse-qualified-column dem))
++  parse-group-by  ;~  plug
  (cold %group-by ;~(plug whitespace (jester 'group') whitespace (jester 'by')))
  (more com parse-grouping-column)
  ==
++  cook-ordering-column
  |=  parsed=*
  ?:  ?=(qualified-column:ast parsed)  (ordering-column:ast %ordering-column parsed %.y)
  ?@  parsed  (ordering-column:ast %ordering-column parsed %.y)
  ?:  =(+.parsed %asc)  (ordering-column:ast %ordering-column -.parsed %.y)
  (ordering-column:ast %ordering-column -.parsed %.n)
++  parse-ordered-column
  (cook cook-ordering-column ;~(plug ;~(pose parse-qualified-column dem) ;~(pfix whitespace ;~(pose (cold %asc (jester 'asc')) (cold %desc (jester 'desc'))))))
++  parse-ordering-column  ;~  pose
  (ifix [whitespace whitespace] parse-ordered-column)
  (cook cook-ordering-column (ifix [whitespace whitespace] ;~(pose parse-qualified-column dem)))
  ==
++  parse-order-by  ;~  plug
  (cold %order-by ;~(plug whitespace (jester 'order') whitespace (jester 'by')))
  (more com parse-ordering-column)
  ==
++  make-query-object
  |=  a=*
  ^-  table-set:ast
  ?:  ?=(qualified-object:ast a)
    (table-set:ast %table-set a ~)
  ?:  ?=(qualified-object:ast -.a)
    ?~  +.a  (table-set:ast %table-set -.a ~)
    ?:  ?=((unit @t) +.a)
      (table-set:ast %table-set -.a +.a)
    (table-set:ast %table-set -.a `+.a)
  ?:  ?=([@ @] a)
     (table-set:ast %table-set (qualified-object:ast %qualified-object ~ 'UNKNOWN' 'COLUMN-OR-CTE' -.a) `+.a)
  =/  columns=(list @t)  ~
  =/  b  ?:  ?=([%query-row * @] a)  +<.a
    ?:  =(%query-row -.a)  +.a
    ?:  =(%query-row -<.a)  ->.a  -.a
  =/  alias  ?:  ?=([%query-row * @] a)  +>.a
    ?:  =(%query-row -.a)  ~  +.a
  |-
  ?~  b
    ?~  alias  (table-set:ast %table-set object=(query-row:ast %query-row (flop columns)) ~)
    (table-set:ast %table-set object=(query-row:ast %query-row (flop columns)) `alias)
  ?@  -.b  $(b +.b, columns [-.b columns])
  ~|("cannot make-query-object:  {<a>}" !!)
++  produce-from
  |=  a=*
  ^-  from:ast
  =/  query-object=table-set:ast  (make-query-object ->.a)
  =/  raw-joined-objects  +.a
  =/  joined-objects=(list joined-object:ast)  ~
  =/  is-cross-join=?  %.n
  |-
  ?:  =(raw-joined-objects ~)
    ?:  is-cross-join
      ?:  =((lent joined-objects) 1)
        (from:ast %from query-object (flop joined-objects))
      ~|("cross join must be only join in query" !!)
    (from:ast %from query-object (flop joined-objects))
  ?:  ?=(%cross-join -.raw-joined-objects)
    %=  $
      joined-objects
        [(joined-object:ast %joined-object %cross-join (make-query-object +>.raw-joined-objects) ~) joined-objects]
      is-cross-join       %.y
      raw-joined-objects  ~
    ==
  ?>  ?=(join-type:ast -<.raw-joined-objects)
  =/  joined=joined-object:ast
    (joined-object:ast %joined-object -<.raw-joined-objects (make-query-object ->->.raw-joined-objects) `(produce-predicate (predicate-list ->+.raw-joined-objects)))
  %=  $
  joined-objects  [joined joined-objects]
  raw-joined-objects  +.raw-joined-objects
  ==
++  produce-ctes
  |=  a=*
  ^-  (list cte:ast)
  =/  ctes=(list cte:ast)  ~
  |-
  ?~  a  (flop ctes)
  ?:  ?&(=(%cte -<.a) =(%as ->+<.a))
    %=  $
      a  +.a
      ctes  [(cte:ast %cte ->+>.a (produce-query ->-.a)) ctes]
    ==
  ~|('cannot produce ctes from parsed:  {<a>}' !!)
++  produce-delete
  |=  a=*
  ^-  delete:ast
  ?>  ?=(qualified-object:ast -.a)
  ?:  =(%end-command +<.a)
    (delete:ast %delete -.a ~)
?:  =(%where +<.a)
  (delete:ast %delete -.a `(produce-predicate (predicate-list +>-.a)))
(delete:ast %delete -.a `(produce-predicate (predicate-list +>->.a)))
++  produce-select
  |=  a=*
  ^-  select:ast
  =/  top=(unit @ud)  ~
  =/  bottom=(unit @ud)  ~
  =/  columns=(list selected-column:ast)  ~
  |-
    ~|  "cannot parse select -.a:  {<-.a>}"
    ?~  a
      ?~  columns  ~|('no columns selected' !!)
      (select:ast %select top bottom (flop columns))
    ?@  -.a
      ?+  -.a  ~|('some other select atom' !!)
      %top       ?>  ?=(@ud +<.a)  $(top `+<.a, a +>.a)
      %bottom    ?>  ?=(@ud +<.a)  $(bottom `+<.a, a +>.a)
      %all
        %=  $
          columns  [(qualified-object:ast %qualified-object ~ 'ALL' 'ALL' 'ALL') columns]
          a        +.a
        ==
      ==
    ?:  ?=([[%selected-aggregate @ %qualified-column [%qualified-object @ @ @ @] @ @] %as @] -.a)
      %=  $
        columns  [(selected-aggregate:ast %selected-aggregate (aggregate:ast %aggregate (aggregate-name -<+<.a) (qualified-column:ast %qualified-column -<+>+<.a -<+>+>-.a -<+>+>+.a)) `->+.a) columns]
        a        +.a
      ==
    ?:  ?=([%selected-aggregate @ %qualified-column [%qualified-object @ @ @ @] @ @] -.a)
      %=  $
        columns  [(selected-aggregate:ast %selected-aggregate (aggregate:ast %aggregate (aggregate-name ->-.a) (qualified-column:ast %qualified-column ->+>-.a ->+>+<.a ->+>+>.a)) ~) columns]
        a        +.a
      ==
    ?:  ?=([%all-columns %qualified-object @ @ @ @] -.a)
      %=  $
        columns  [(qualified-column:ast %qualified-column (qualified-object:ast %qualified-object ->+<.a ->+>-.a ->+>+<.a ->+>+>.a) 'ALL' ~) columns]
        a        +.a
      ==
    ?:  ?=([@ @] -.a)
      ?:  =(%all-columns -<.a)
        %=  $
          columns  [(qualified-column:ast %qualified-column (qualified-object:ast %qualified-object ~ 'UNKNOWN' 'COLUMN-OR-CTE' ->.a) 'ALL' ~) columns]
          a        +.a
        ==
      ?>  ?=(value-literal:ast -.a)
        %=  $
          columns  [(selected-value:ast %selected-value -.a ~) columns]
          a        +.a
        ==
    ?:  ?=([qualified-column:ast %as @] -.a)
      %=  $
        columns  [(qualified-column:ast %qualified-column (qualified-object:ast %qualified-object -<+<+<.a -<+<+>-.a -<+<+>+<.a -<+<+>+>.a) -<+>-.a `->+.a) columns]
        a        +.a
      ==
    ?:  ?=([[@tas @] %as @] -.a)
      %=  $
        columns  [(selected-value:ast %selected-value -<.a `->+.a) columns]
        a        +.a
      ==
    ?>  ?=(qualified-column:ast -.a)  $(columns [-.a columns], a +.a)
++  produce-query
  |=  a=*
  ^-  query:ast
  =/  from=(unit from:ast)  ~
  =/  scalars=(list scalar-function:ast)  ~
  =/  predicate=(unit predicate:ast)  ~
  =/  group-by=(list grouping-column:ast)  ~
  =/  having=(unit predicate:ast)  ~
  =/  select=(unit select:ast)  ~
  =/  order-by=(list ordering-column:ast)  ~
  |-
  ?~  a  ~|("cannot parse query  {<a>}" !!)
  ?:  =(-.a %query)           $(a +.a)
  ?:  =(-.a %end-command)
    (query:ast %query from scalars predicate group-by having (need select) order-by)
  ::?:  =(i.a %scalars)  $(a t.a, scalars  +.i.a)
  ?:  =(-<.a %scalars)        $(a +.a, scalars ~)
  ?:  =(-<.a %where)          $(a +.a, predicate `(produce-predicate (predicate-list ->.a)))
  ?:  =(-<.a %select)         $(a +.a, select `(produce-select ->.a))
  ?:  =(-<.a %group-by)       $(a +.a, group-by (group-by-list ->.a))
  ?:  =(-<.a %order-by)       $(a +.a, order-by (order-by-list ->.a))
  ?:  =(-<-.a %table-set)  $(a +.a, from `(produce-from -.a))
  ?:  =(-<-.a %query-row)     $(a +.a, from `(produce-from -.a))
  ~|("cannot parse query  {<a>}" !!)
::
::  parse urQL command
::
++  parse-alter-index
  =/  columns  ;~(pfix whitespace ordered-column-list)
  =/  action  ;~(pfix whitespace ;~(pose (jester 'rebuild') (jester 'disable') (jester 'resume')))
  ;~  plug
    ;~(pfix whitespace parse-qualified-3object)
    ;~(pfix whitespace ;~(pfix (jester 'on') ;~(pfix whitespace parse-qualified-3object)))
    ;~(sfix ;~(pose ;~(plug columns action) columns action) end-or-next-command)
  ==
++  parse-alter-namespace  ;~  plug
  (cook |=(a=* (qualified-namespace [a default-database])) parse-qualified-2-name)
  ;~(pfix ;~(plug whitespace (jester 'transfer')) ;~(pfix whitespace ;~(pose (jester 'table') (jester 'view'))))
  ;~(sfix ;~(pfix whitespace parse-qualified-3object) end-or-next-command)
  ==
++  parse-alter-table  ;~  plug
  ;~(pfix whitespace parse-qualified-3object)
  ;~(sfix ;~(pfix whitespace ;~(pose alter-columns add-columns drop-columns add-foreign-key drop-foreign-key)) end-or-next-command)
  ==
++  parse-create-namespace  ;~  sfix
  parse-qualified-2-name
  end-or-next-command
  ==
++  parse-create-index
  =/  is-unique  ;~(pfix whitespace (jester 'unique'))
  =/  index-name  ;~(pfix whitespace (jester 'index') parse-face)
  =/  type-and-name  ;~  pose
    ;~(plug is-unique clustering index-name)
    ;~(plug is-unique index-name)
    ;~(plug clustering index-name)
    index-name
    ==
  ;~  plug
    type-and-name
    ;~(pfix whitespace ;~(pfix (jester 'on') ;~(pfix whitespace parse-qualified-3object)))
    ;~(sfix ordered-column-list end-or-next-command)
  ==
++  parse-create-table  ;~  plug
  ;~(pfix whitespace parse-qualified-3object)
  column-definitions
  ;~(sfix ;~(pose ;~(plug primary-key ;~(pfix foreign-key-literal (more com full-foreign-key))) primary-key) end-or-next-command)
  ==
++  parse-drop-database  ;~  sfix
  ;~(pose ;~(plug ;~(pfix whitespace (jester 'force')) ;~(pfix whitespace sym)) ;~(pfix whitespace sym))
  end-or-next-command
  ==
++  parse-drop-index  ;~  sfix
  ;~(pfix whitespace ;~(plug parse-face ;~(pfix whitespace ;~(pfix (jester 'on') ;~(pfix whitespace parse-qualified-3object)))))
  end-or-next-command
  ==
++  parse-drop-namespace  ;~  sfix
  ;~(pose ;~(plug ;~(pfix whitespace (cold %force (jester 'force'))) parse-qualified-2-name) parse-qualified-2-name)
  end-or-next-command
  ==
++  drop-table-or-view  ;~  sfix
  ;~(pose ;~(pfix whitespace ;~(plug (jester 'force') parse-qualified-3object)) parse-qualified-3object)
  end-or-next-command
  ==
++  parse-grant  ;~  plug
  :: permission
  ;~(pfix whitespace ;~(pose (jester 'adminread') (jester 'readonly') (jester 'readwrite')))
  :: grantee
  ;~(pfix whitespace ;~(pfix (jester 'to') ;~(pfix whitespace ;~(pose (jester 'parent') (jester 'siblings') (jester 'moons') (stag %ships ship-list)))))
  ;~(sfix grant-object end-or-next-command)
  ==
++  parse-insert  ;~  plug
  ;~(pfix whitespace parse-qualified-object)
  ;~(pose ;~(plug face-list ;~(pfix whitespace (jester 'values'))) ;~(pfix whitespace (jester 'values')))
  ;~(pfix whitespace (more whitespace (ifix [pal par] (more com parse-insert-value))))
  end-or-next-command
  ==
++  parse-query01  ;~  plug
  parse-object-and-joins
::  (stag %scalars (star parse-scalar))
  ;~(pfix whitespace ;~(plug (cold %where (jester 'where')) parse-predicate))
  parse-group-by
  parse-select
  parse-order-by
  end-or-next-command
  ==
++  parse-query02  ;~  plug
  parse-object-and-joins
::  (stag %scalars (star parse-scalar))
  ;~(pfix whitespace ;~(plug (cold %where (jester 'where')) parse-predicate))
  parse-group-by
  parse-select
  end-or-next-command
  ==
++  parse-query03  ;~  plug
  parse-object-and-joins
::  (stag %scalars (star parse-scalar))
  ;~(pfix whitespace ;~(plug (cold %where (jester 'where')) parse-predicate))
  parse-select
  parse-order-by
  end-or-next-command
  ==
++  parse-query04  ;~  plug
  parse-object-and-joins
::  (stag %scalars (star parse-scalar))
  ;~(pfix whitespace ;~(plug (cold %where (jester 'where')) parse-predicate))
  parse-select
  end-or-next-command
  ==
++  parse-query05  ;~  plug
  parse-object-and-joins
::  (stag %scalars (star parse-scalar))
  parse-select
  parse-order-by
  end-or-next-command
  ==
++  parse-query06  ;~  plug
  parse-object-and-joins
::  (stag %scalars (star parse-scalar))
  parse-select
  end-or-next-command
  ==
++  parse-query07  ;~  plug
  parse-object-and-joins
::  (stag %scalars (star parse-scalar))
  parse-group-by
  parse-select
  parse-order-by
  end-or-next-command
  ==
++  parse-query08  ;~  plug
  parse-object-and-joins
::  (stag %scalars (star parse-scalar))
  parse-group-by
  parse-select
  end-or-next-command
  ==
++  parse-query09  ;~  plug
  parse-object-and-joins
  parse-select
  end-or-next-command
  ==
++  parse-query10  ;~  plug
  parse-select
  end-or-next-command
  ==
++  parse-query  ;~  pose
  parse-query01
  parse-query02
  parse-query03
  parse-query04
  parse-query05
  parse-query06
  parse-query07
  parse-query08
  parse-query09
  parse-query10
  ==
++  parse-cte  ;~  plug
  (cold %cte ;~(plug whitespace (jest '(')))
  ;~  pose
    ;~(pfix ;~(whitespace (jester 'from')) parse-query)
    ;~(pfix (jester 'from') parse-query)
    parse-query
  ==
  ;~  pose
    ;~(pfix whitespace ;~(pfix (jest ')') ;~(pfix whitespace (jester 'as'))))
    ;~(pfix (jest ')') ;~(pfix whitespace (jester 'as')))
    ==
  ;~(pose ;~(sfix parse-alias whitespace) parse-alias)
  ==
++  parse-ctes
  (more com ;~(pose with-stop parse-cte))
++  parse-delete  ;~  plug
  ;~(pfix whitespace parse-qualified-3object)
  ;~  pose
    ;~(pfix whitespace ;~(plug (cold %where (jester 'where')) parse-predicate end-or-next-command))
    end-or-next-command
    ==
  ==
++  merge-stop  ;~  pose
  ;~(plug (jester 'with') whitespace)
  ;~(plug (jester 'using') whitespace)
  ;~(plug (jester 'on') whitespace)
  ;~(plug (jester 'when') whitespace)
  ==
++  parse-matching-predicate  ;~  plug
  (cold %predicate ;~(plug whitespace (jester 'and')))
  parse-predicate
  ==
++  parse-merge-when  ;~  plug
  ;~  pose
    ;~(plug (cold %matched ;~(plug (jester 'when') whitespace (jester 'matched'))) parse-matching-predicate)
    (cold %matched ;~(plug (jester 'when') whitespace (jester 'matched')))
    ::
    ;~(plug (cold %unmatch-target ;~(plug (jester 'when') whitespace (jester 'not') whitespace (jester 'matched') whitespace (jester 'by') whitespace (jester 'target'))) parse-matching-predicate)
    (cold %unmatch-target ;~(plug (jester 'when') whitespace (jester 'not') whitespace (jester 'matched') whitespace (jester 'by') whitespace (jester 'target')))
    ;~(plug (cold %unmatch-target ;~(plug (jester 'when') whitespace (jester 'not') whitespace (jester 'matched'))) parse-matching-predicate)
    (cold %unmatch-target ;~(plug (jester 'when') whitespace (jester 'not') whitespace (jester 'matched')))
    ::
    ;~(plug (cold %unmatch-source ;~(plug (jester 'when') whitespace (jester 'not') whitespace (jester 'matched') whitespace (jester 'by') whitespace (jester 'source'))) parse-matching-predicate)
    (cold %unmatch-source ;~(plug (jester 'when') whitespace (jester 'not') whitespace (jester 'matched') whitespace (jester 'by') whitespace (jester 'source')))
  ==
  ;~  pose
    ;~  plug
      (cold %update ;~(pose ;~(plug whitespace (jester 'then') whitespace (jester 'update') whitespace (jester 'set')) ;~(plug whitespace (jester 'then') whitespace (jester 'update'))))
      (more com update-column)
    ==
    ;~  plug
      (cold %insert ;~(pose ;~(plug whitespace (jester 'then') whitespace (jester 'insert'))))
    ;~(pose ;~(plug face-list ;~(pfix whitespace (jester 'values'))) ;~(pfix whitespace (jester 'values')))
    ;~(pfix whitespace (more whitespace (ifix [pal par] (more com ;~(pose parse-qualified-column parse-insert-value)))))
    ==
  ==
==
++  parse-merge  ;~  plug
  ;~  pose
    ;~(pfix whitespace ;~(plug parse-qualified-object ;~(pfix whitespace ;~(pfix (jester 'as') parse-alias))))
    ;~(pfix whitespace ;~(plug (stag %query-row face-list) ;~(pfix whitespace ;~(pfix (jester 'as') parse-alias))))
    ;~(pfix whitespace ;~(plug parse-qualified-object (cold %as whitespace) ;~(less merge-stop parse-alias)))
    ;~(pfix whitespace ;~(plug (stag %query-row face-list) ;~(pfix whitespace ;~(less merge-stop parse-alias))))
    ;~(pfix whitespace parse-qualified-object)
    ;~(pfix whitespace (stag %query-row face-list))
  ==
  ;~  pose
      ;~(plug (cold %using ;~(plug whitespace (jester 'using') whitespace)) ;~(plug ;~(pose parse-qualified-object parse-alias) ;~(pfix whitespace ;~(pfix (jester 'as') parse-alias))))
      ;~(plug (cold %using ;~(plug whitespace (jester 'using') whitespace)) (stag %query-row ;~(plug face-list ;~(pfix whitespace ;~(pfix (jester 'as') parse-alias)))))
      ;~(plug (cold %using ;~(plug whitespace (jester 'using') whitespace)) ;~(plug ;~(pose parse-qualified-object parse-alias) (cold %as whitespace) ;~(less merge-stop parse-alias)))
      ;~(plug (cold %using ;~(plug whitespace (jester 'using') whitespace)) (stag %query-row ;~(plug face-list ;~(pfix whitespace ;~(less merge-stop parse-alias)))))
      ;~(plug (cold %using ;~(plug whitespace (jester 'using') whitespace)) parse-qualified-object)
      ;~(plug (cold %using ;~(plug whitespace (jester 'using') whitespace)) (stag %query-row face-list))
  ==
  ;~(plug ;~(pfix whitespace (jester 'on')) parse-predicate)
  ;~(pfix whitespace (star parse-merge-when))
  (easy ~)
==
++  produce-insert
  |=  a=*
  ^-  insert:ast
  ?:  ?=([[@ @ @ @ @] @ *] a)            ::"insert rows"
    (insert:ast %insert -.a ~ (insert-values:ast %data +>-.a))
  ?:  ?=([[@ @ @ @ @] [* @] *] a)        ::"insert column names rows"
    (insert:ast %insert -.a `+<-.a (insert-values:ast %data +>-.a))
  ~|("Cannot parse insert {<a>}" !!)
++  produce-merge
  |=  a=*
  ^-  merge:ast
  =/  into=?  %.y
  =/  target-table=(unit table-set:ast)  ~
  =/  new-table=(unit table-set:ast)  ~
  =/  source-table=(unit table-set:ast)  ~
  =/  predicate=(unit predicate:ast)  ~
  =/  matching=[matched=(list matching:ast) not-target=(list matching:ast) not-source=(list matching:ast)]  [~ ~ ~]
  |-
  ?~  a  ?:  ?&(=(target-table ~) =(source-table ~))  ~|("target and source tables cannot both be pass through" !!)
  (merge:ast %merge (need target-table) new-table (need source-table) (need predicate) matched=matched.matching unmatched-by-target=not-target.matching unmatched-by-source=not-source.matching)
  ?:  ?=(qualified-object:ast -.a)
    %=  $
      a  +.a
      target-table  `(table-set:ast %table-set -.a ~)
    ==
  ?:  ?=([%using @ %as @] -.a)
    %=  $
      a  +.a
      source-table  `(table-set:ast %table-set (qualified-object:ast %qualified-object ~ default-database 'dbo' +<.a) `+>+.a)
    ==
  ?:  ?=([qualified-object:ast @] -.a)
    %=  $
      a  +.a
      target-table  `(make-query-object -.a)
    ==
  ?:  ?=([%using qualified-object:ast %as @] -.a)
    %=  $
      a  +.a
      source-table  `(table-set:ast %table-set ->-.a `->+>.a)
    ==
  ?:  =(%on -<.a)
    %=  $
      a  +.a
      predicate  `(produce-predicate (predicate-list ->.a))
    ==
  ?:  =(%query-row -<.a)
    %=  $
      a  +.a
      target-table  `(make-query-object -.a)
    ==
  ?:  =(%using -<.a)
    %=  $
      a  +.a
      source-table  `(make-query-object ->.a)
    ==
  ?:  =(%query-row -<-.a)
    %=  $
      a  +.a
      target-table  `(make-query-object -.a)
    ==
  %=  $
    a  +.a
    matching  (produce-matching -.a)
  ==
++  produce-matching-profile
  |=  a=*
  ^-  (list [@t datum:ast])
  =/  profile=(list [@t datum:ast])  ~
  |-
  ?~  a  (flop profile)
  ?:  ?=([@ %qualified-column qualified-object:ast @ ~] -.a)
    %=  $
      profile  [[-<.a (qualified-column:ast %qualified-column `qualified-object:ast`->+<.a ->+>-.a ~)] profile]
      a  +.a
    ==
  ?:  =(%values ->.a)
    ?:  =(~ -<.a)
      ?:  =(~ +<.a)  $(a ~)
        ~|("produce-matching-profile error:  {<a>}" !!)
    ?@  -<-.a
      ?:  ?=(datum:ast +<-.a)
        %=  $
         profile  [[-<-.a +<-.a] profile]
          a  [[-<+.a 'values'] +<+.a ~]
        ==
      ~|("produce-matching-profile error on source:  {<+<-.a>}" !!)
    ~|("produce-matching-profile error:  {<a>}" !!)
  ~|("produce-matching-profile error:  {<a>}" !!)
++  produce-matching
  |=  a=*
  ^-  [(list matching:ast) (list matching:ast) (list matching:ast)]
  =/  matched=(list matching:ast)  ~
  =/  not-matched-by-target=(list matching:ast)  ~
  =/  not-matched-by-source=(list matching:ast)  ~
  |-
  ?~  a
    [(flop matched) (flop not-matched-by-target) (flop not-matched-by-source)]
  ?>  ?=(matching-action:ast ->-.a)
  ?-  `matching-action:ast`->-.a
    %insert
      ?:  ?=([%matched @ *] -.a)
        %=  $
          matched  [(matching:ast %matching predicate=~ matching-profile=[->-.a (produce-matching-profile ->+.a)]) matched]
          a  +.a
        ==
      ?:  =(%unmatch-target -<.a)
        %=  $
          not-matched-by-target  [(matching:ast %matching predicate=~ matching-profile=[->-.a (produce-matching-profile ->+.a)]) not-matched-by-target]
          a  +.a
        ==
      ?:  ?&(=(%matched -<-.a) =(%predicate -<+<.a))
        %=  $
          matched  [(matching:ast %matching predicate=`(produce-predicate (predicate-list -<+>.a)) matching-profile=[->-.a (produce-matching-profile ->+.a)]) matched]
          a  +.a
        ==
      ~|("merge insert can't get here:  {<-.a>}" !!)
    %update
      ?:  ?=([%matched @ *] -.a)
        %=  $
          matched  [(matching:ast %matching predicate=~ matching-profile=[->-.a (produce-matching-profile ->+.a)]) matched]
          a  +.a
        ==
      ?:  ?&(=(%matched -<-.a) =(%predicate -<+<.a))
        %=  $
          matched  [(matching:ast %matching predicate=`(produce-predicate (predicate-list -<+>.a)) matching-profile=[->-.a (produce-matching-profile ->+.a)]) matched]
          a  +.a
        ==
      ~|("merge update can't get here:  {<-.a>}" !!)
    %delete
      ?:  ?=([%matched @ *] -.a)
        %=  $
          matched  [(matching:ast %matching predicate=~ matching-profile=%delete) matched]
          a  +.a
        ==
      ?:  =(%unmatch-target -<.a)
        %=  $
          not-matched-by-target  [(matching:ast %matching predicate=~ matching-profile=%delete) not-matched-by-target]
          a  +.a
        ==
      ?:  ?&(=(%matched -<-.a) =(%predicate -<+<.a))
        %=  $
          matched  [(matching:ast %matching predicate=`(produce-predicate (predicate-list -<+>.a)) matching-profile=%delete) matched]
          a  +.a
        ==
      ~|("merge delete can't get here:  {<-.a>}" !!)
  ==
++  update-column-inner  ;~  pose
  ;~(plug sym ;~(pfix whitespace ;~(pfix (jest '=') ;~(pfix whitespace ;~(pose parse-qualified-column parse-value-literal)))))
  ==
++  produce-column-sets
  |=  a=*
  ^-  [(list @t) (list datum:ast)]
  =/  columns=(list @t)  ~
  =/  values=(list datum:ast)  ~
  |-
  ?:  =(a ~)
    [columns values]
  ?:  ?&(?=(datum:ast ->.a) ?=(@ -<.a))
    %=  $
      columns  [-<.a columns]
      values   [->.a values]
      a        +.a
    ==
  ~|("cannot parse column setting {<a>}" !!)
++  produce-update
  |=  a=*
  ^-  update:ast
  =/  table=qualified-object:ast  ?>(?=(qualified-object:ast -.a) -.a)
  =/  columns-values=[(list @t) (list datum:ast)]  (produce-column-sets +>-.a)
  ?~  +>+.a
    (update:ast %update table -.columns-values +.columns-values ~)
  (update:ast %update table -.columns-values +.columns-values `(produce-predicate (predicate-list +>+.a)))
++  update-column  ;~  pose
  ;~(pfix whitespace ;~(sfix update-column-inner whitespace))
  ;~(pfix whitespace update-column-inner)
  ;~(sfix update-column-inner whitespace)
  update-column-inner
  ==
++  parse-update  ;~  plug
  ;~(pfix whitespace parse-qualified-object)
  (cold %set ;~(plug whitespace (jester 'set')))
  (more com update-column)
  ;~  pose
    ;~(pfix ;~(plug whitespace (jester 'where')) parse-predicate)
    (easy ~)
    ==
  ==
++  with-stop  ;~  pose
  ;~(plug (jester 'delete') whitespace)
  ;~(plug (jester 'insert') whitespace)
  ;~(plug (jester 'merge') whitespace)
  ;~(plug (jester 'query') whitespace)
  ;~(plug (jester 'select') whitespace)
  ;~(plug (jester 'update') whitespace)
  ==
++  parse-with  ;~  plug
  parse-ctes
  ;~  pose
    ;~(plug (cold %delete ;~(plug (jester 'delete') whitespace (jester 'from'))) parse-delete)
    ;~(plug (jester 'delete') parse-delete)
    ;~(plug (cold %insert ;~(plug (jester 'insert') whitespace (jester 'into'))) parse-insert)
    ;~(plug (cold %merge ;~(plug (jester 'merge') whitespace (jester 'into'))) parse-merge)
    ;~(plug (cold %merge ;~(plug (jester 'merge') whitespace (jester 'from'))) parse-merge)
    ;~(plug (jester 'merge') parse-merge)
    ;~(plug (cold %query ;~(plug (jester 'from'))) parse-query)
    ;~(plug (cold %query ;~(plug ;~(pfix (jester 'select') (funk "select" (easy ' '))))) parse-query)
    ;~(plug (jester 'update') parse-update)
    ==
  ==
++  parse-revoke  ;~  plug
  :: permission
  ;~(pfix whitespace ;~(pose (jester 'adminread') (jester 'readonly') (jester 'readwrite') (jester 'all')))
  :: revokee
  ;~(pfix whitespace ;~(pfix (jester 'from') ;~(pfix whitespace ;~(pose (jester 'parent') (jester 'siblings') (jester 'moons') (jester 'all') (stag %ships ship-list)))))
  ;~(sfix grant-object end-or-next-command)
  ==
++  parse-truncate-table  ;~  sfix
  ;~(pfix whitespace parse-qualified-object)
  end-or-next-command
  ==
--
