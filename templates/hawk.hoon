!:
:: obelisk-ui
::   A user interface for Obelisk.
::   [protocol: hawk-500]
::
::
::  Installation Instructions:
::
::   - Install %obelisk manually
::       https://github.com/jackfoxy/obelisk
::
::   - Install this hawk template by
::     placing it at an empty spot in %hawk
::
::   - Create an inital database:
::     `CREATE DATABASE db1;`
::
::   - Run a query:
::     `FROM sys.sys.databases SELECT *;`
::
::
::  Usage Instructions
::
::   - If you select text in the script,
::     only the selected portion will be run.
::
::   - Read the Obelisk Users Guide
::
::     https://github.com/jackfoxy/obelisk/blob/master/docs/users-guide.md
::
::
::  It will also be useful to place this
::  file at /~/config/templates/obelisk-ui
::  so that you can easily place it at a
::  blank hawk page.
::
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
  ;<  our=@p  bind:m  get-our
  ;<  now=@da  bind:m  get-time
  =/  dock  [our %obelisk]
  =/  default  (fall parse-default-db %sys)
  =/  action  [%tape default query]
  =/  obelisk-command=cage  obelisk-action/!>(action)
  ;<  ~  bind:m  (watch /query/[id] dock /server)
  ;<  ~  bind:m  (poke dock obelisk-command)
  ;<  [mark =vase]  bind:m  (take-fact /query/[id])
  |=  tin=strand-input:strand
  ?~  res=(mole |.((poke-result +:vase)))
    `[%fail [%malformed-obelisk-response ~]]
  `[%done u.res]
::
::  parse returns [%& (list command)] or [%| tang] on /server.
++  parse-obelisk
  |=  [id=@ta query=tape]
  =/  m  (strand ,parse-output)
  ^-  form:m
  ;<  our=@p  bind:m  get-our
  ;<  now=@da  bind:m  get-time
  =/  dock  [our %obelisk]
  =/  default  (fall parse-default-db %sys)
  =/  action  [%parse default query]
  =/  obelisk-command=cage  obelisk-action/!>(action)
  ;<  ~  bind:m  (watch /parse/[id] dock /server)
  ;<  ~  bind:m  (poke dock obelisk-command)
  ;<  [mark =vase]  bind:m  (take-fact /parse/[id])
  |=  tin=strand-input:strand
  ?~  res=(mole |.((parse-result +:vase)))
    `[%fail [%malformed-obelisk-response ~]]
  ?-  -.u.res
    %.n  `[%done [%.n p.u.res]]
    %.y  `[%done [%.y (text !>(p.u.res))]]
  ==
::
+$  poke-result  (each (list cmd-result) tang)
+$  parse-result  (each (list *) tang)
+$  parse-output  (each tape tang)
::
++  print-vector
  |=  =vector
  ;tr
    ;*
    %+  turn  +.vector
    |=  cell=vector-cell
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
  ?~  res=(gid:d "default-db")  ~
  =/  el=manx  +.u.res
  %+  bind
    (~(get by (malt a.g.el)) %val)
  crip
::
++  child-node
  |=  [tree=file pax=path]
  ^-  (unit file)
  ?~  pax  `tree
  ?~  next=(~(get by dir.tree) i.pax)  ~
  $(tree u.next, pax t.pax)
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
  ;<  =server  bind:m  (scry server %gx %obelisk /server/noun)
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
        =/  m=manx  (print-schemas server default-db)
        m(a.g [[%slot "side"] a.g.m])
      ;hawk-sidebar#h-output.hf.fc
        =side  "bottom"
        =label  "Output"
        =open  ""
        =size  "0.4"
        ;div.fc.hf
          ;+  (print-header server default-db)
          ;+  (print-query-form query)
        ==
        ;+  results(a.g [[%slot "side"] a.g.results])
      ==
    ==
    ;+  print-script
  ==
  ::
++  print-header
  |=  [=server default-db=(unit term)]
  ;header.p2.frw.g2.b1(style "border-bottom: 1px solid var(--b3); position: relative;")
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
    ;button.p-1.bd1.br1.b2.hover(disabled ""): Upload file
    ;a.underline(href "https://github.com/jackfoxy/obelisk/tree/master/desk/doc/usr/reference/", target "_blank", rel "noopener noreferrer"): Reference
    ;a.underline(href "https://github.com/jackfoxy/obelisk/blob/master/desk/doc/usr/users-guide.md", target "_blank", rel "noopener noreferrer"): Users Guide
    ;div.grow;
    ;+  (print-form-set-default-db server default-db)
  ==
  ::
++  print-form-set-default-db
  |=  [=server default-db=(unit term)]
  ;form.fr.ac.g1(method "post")
    =hx-trigger  "change from:find select"
    =hx-on-htmx-config-request  "configRequest(event)"
    ;input.hidden(name "/", value "set-default-db");
    ;div.p1.loader.mono.s-2
      ;span.loaded.f3: Default DB
      ;span.loading.f4: saving..
    ==
    ;select#default-db.br1.bd1.p-1.wfc(val (trip (fall default-db 'sys')))
      =name  "default-db"
      =required  ""
      ;option(value "sys"): sys
      ;*
      %+  turn  (sort ~(tap in ~(key by (~(del by server) %sys))) aor)
      |=  =term
      =;  m=manx
        ?~  default-db  m
        ?.  =(default-db `term)  m
        m(a.g [[%selected (trip u.default-db)] a.g.m])
      ;option(value (trip term)): {(trip term)}
    ==
  ==
::
++  current-schema
  |=  =database
  ^-  schema
  =/  schema-key  ((on @da schema) gth)
  +:(need (pry:schema-key sys.database))
::
++  namespace-table-names
  |=  [=schema ns=@tas]
  ^-  (list [@tas table])
  %+  sort
      %+  turn
          %+  skim  ~(tap by tables.schema)
                    |=  [k=[@tas @tas] v=table]
                    =(ns -.k)
              |=  [k=[@tas @tas] v=table]
          [+.k v]
      |=  [a=[@ *] b=[@ *]]
      (aor -.a -.b)
::
++  table-columns
  |=  =table
  ^-  manx
  =/  foo  %-  malt  %+  turn  key.pri-indx.table
                         |=(=key-column [name.key-column key-column])
  ;div.p3.fc.g1
    ;*
    %+  turn  columns.table
    |=  =column
    =/  aura=tape  (weld "@" (trip type.column))
    =/  key-col=(unit key-column)  (~(get by foo) name.column)
    =/  is-index  ?~  key-col  " "
                  ?:  ascending.u.key-col  "↑"
                  "↓"
      ;summary(style "display: grid; grid-template-columns: 4ch 4ch 1fr; column-gap: 1ch; align-items: center;")
        ;span;
        ;span.f4.mono(style "text-align: center;"): {(weld is-index aura)}
        ;span: {(trip name.column)}
      ==
  ==
  ::
++  column-name-csv
  |=  cols=(list column)
  ^-  tape
  ?~  cols  ""
  ?~  t.cols
    (trip name.i.cols)
  (weld (trip name.i.cols) (weld "," $(cols t.cols)))
::
++  column-spec-csv
  |=  cols=(list column)
  ^-  tape
  ?~  cols  ""
  =/  spec=tape  (weld (trip name.i.cols) (weld ":" (weld "@" (trip type.i.cols))))
  ?~  t.cols
    spec
  (weld spec (weld "," $(cols t.cols)))
::
++  key-spec-csv
  |=  keys=(list key-column)
  ^-  tape
  ?~  keys  ""
  =/  order=tape  ?:(ascending.i.keys "ASC" "DESC")
  =/  spec=tape  (weld (trip name.i.keys) (weld ":" order))
  ?~  t.keys
    spec
  (weld spec (weld "," $(keys t.keys)))
::
++  namespace-view-names
  |=  [=schema ns=@tas]
  ^-  (list [@tas view])
  =/  view-key  ((on ns-rel-key view) ns-rel-comp)
    %+  turn  %+  sort  %+  turn
                            %+  skim  (tap:view-key views.schema)
                                      |=  [k=[@tas @tas @da] v=view]
                                      =(ns -.k)
                                |=  [k=[@tas @tas @da] v=view]
                            [+.k v]
                        |=  [a=[[@tas @da] view] b=[[@tas @da] view]]
                        ?.  =(-.a -.b)  (aor +<.a +<.b)
                        (aor -.a -.b)
              |=  [k=[@tas @da] v=view]
              [-.k v]
::
++  view-columns  
  |=  =view
  ^-  manx
  ;div.p3.fc.g1
    ;*
    %+  turn  columns.view
    |=  =column
      ;summary(style "display: grid; grid-template-columns: 4ch 4ch 1fr; column-gap: 1ch; align-items: center;")
        ;span;
        ;span.f4.mono(style "text-align: center;"): {(weld "@" (trip type.column))}
        ;span: {(trip name.column)}
      ==
  ==
::
++  print-schemas
  |=  [=server default-db=(unit term)]
  ;div.wf.hf.scroll-y.b2
    ;div.sticky.b2
      =style  "top: 0;"
      ;div.mono.tc.p-1.pre: {(pib:c /sys/our)}
      ;hr.bc4;
    ==
    ;div#schema.p2
      ;*
      %+  turn  (sort ~(tap in ~(key by server)) aor)
      |=  =term
      =/  db=database  ;;(database (~(got by server) term))
      =/  schema=schema  +:(need (pry:((on @da schema) gth) sys.db))
      ;details
        ;summary
          ;span.f4.mono: [db] 
          ;span: {(trip term)} 
          ;+  ?.  =(default-db `term)  ;/("")
          ;span.f3: (default)
        ==
        ;div.p3.fc.g1
          ;*
          %+  turn  (sort ~(tap in ~(key by namespaces.schema)) aor)
          |=  ns=@tas
            =/  tables=(list [@tas table])  (namespace-table-names schema ns)
            =/  views=(list [@tas view])  (namespace-view-names schema ns)
            ;details
              ;summary
                ;span.f4.mono: [ns]
                ;span: {(trip ns)}
              ==
              ;+
                ?~  tables  ;/("")
                ;div.p3.fc.g1
                  ;*
                  %+  turn  tables
                  |=  tbl=[@tas table]
                    ;details.rel(style "position: relative;")
                      ;summary(oncontextmenu "openTableContextMenu(event, 'table', '{(trip term)}', '{(trip ns)}', '{(trip -.tbl)}', '{(column-name-csv columns.+.tbl)}', '{(column-spec-csv columns.+.tbl)}', '{(key-spec-csv key.pri-indx.+.tbl)}'); return false;", style "padding-right: 2rem;")
                        ;span.fr.ac.g1(style "display: inline-flex;")
                          ;span.f4.mono: [tbl]
                          ;span: {(trip -.tbl)}
                        ==
                      ==
                      ;button(type "button", onclick "event.stopPropagation(); openTableContextMenu(event, 'table', '{(trip term)}', '{(trip ns)}', '{(trip -.tbl)}', '{(column-name-csv columns.+.tbl)}', '{(column-spec-csv columns.+.tbl)}', '{(key-spec-csv key.pri-indx.+.tbl)}'); return false;", style "position: absolute; top: 0.2rem; right: 0.2rem; z-index: 1; padding: 0 0.5rem; line-height: 1;")
                        ;span.mono: ...
                      ==
                      ;*  ~[(table-columns +.tbl)]
                    ==
                ==
              ;+
                ?~  views  ;/("")
                ;div.p3.fc.g1
                  ;*
                  %+  turn  views
                  |=  vw=[@tas view]
                    ;details.rel(style "position: relative;")
                      ;summary(oncontextmenu "openTableContextMenu(event, 'view', '{(trip term)}', '{(trip ns)}', '{(trip -.vw)}', '{(column-name-csv columns.+.vw)}', '', ''); return false;", style "padding-right: 2rem;")
                        ;span.fr.ac.g1(style "display: inline-flex;")
                          ;span.f4.mono: [vw]
                          ;span: {(trip -.vw)}
                        ==
                      ==
                      ;button(type "button", onclick "event.stopPropagation(); openTableContextMenu(event, 'view', '{(trip term)}', '{(trip ns)}', '{(trip -.vw)}', '{(column-name-csv columns.+.vw)}', '', ''); return false;", style "position: absolute; top: 0.2rem; right: 0.2rem; z-index: 1; padding: 0 0.5rem; line-height: 1;")
                        ;span.mono: ...
                      ==
                      ;*  ~[(view-columns +.vw)]
                    ==
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
    =hx-on-htmx-after-request  "$('#query-text').focus();"
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
  |=  results=(list cmd-result)
  ;div#results.grow.b1.mono.s0.hf
    ;*
    %+  turn  results
    |=  =cmd-result
    =/  num-sets=@ud
      %-  lent
      %+  skim  +.cmd-result
      |=  =result
      =(-.result %result-set)
    ;hawk-tabs.grow.hf
      ;+
        ?:  =(0 num-sets)  ;/("")
        ;div.p3(data-tab "Results")
          ;*
          %+  turn  +.cmd-result
          |=(=result (print-result-set result))
        ==
      ;div.p3(data-tab "Messages")
        ;*
        %+  turn  +.cmd-result
        |=(=result (print-result-metadata result))
      ==
    ==
  ==
++  print-result-metadata
  |=  =result
  ?+  -.result  ;div;
    %action
      ;div.fr.g1
        ;div.bold: message:
        ;div: {(trip action.result)}
      ==
    %relation
      ;div.fr.g1
        ;div.bold: message:
        ;div: {(trip relation.result)}
      ==
    %message
      ;div.fr.g1
        ;div.bold: message:
        ;div: {(trip msg.result)}
      ==
    %vector-count
      ;div.fr.g1
        ;div.bold: vector count:
        ;div: {(scow %ud count.result)}
      ==
    %server-time
      ;div.fr.g1
        ;div.bold: server-time:
        ;div: {(scow %da date.result)}
      ==
    %schema-time
      ;div.fr.g1
        ;div.bold: schema-time:
        ;div: {(scow %da date.result)}
      ==
    %data-time
      ;div.fr.g1
        ;div.bold: data-time:
        ;div: {(scow %da date.result)}
      ==
  ==
++  print-result-set
  |=  =result
  ?+  -.result  ;/("")
    %result-set
      (print-list-vector +.result)
  ==
  ::
++  print-list-vector
  |=  vectors=(list vector)
  ;div
    ;table.p3
      =style  "border-collapse: collapse;"
      ;tr
        ;*
        ?~  vectors  ~
        %+  turn  +:i.vectors
        |=  cell=vector-cell
        ;th.p1.bd1(style "white-space: nowrap;"): {(trip p.cell)}
      ==
      ;*  (turn vectors print-vector)
    ==
  ==
::
++  print-parse-output
  |=  output=parse-output
  ?-  -.output
    %.n  (print-tang p.output)
    %.y
      ;div#results.grow.b1.mono.s0
        ;div.scroll-x.scroll-y.p4.pre-wrap(style "white-space: pre-wrap;")
          {p.output}
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
      e.detail.parameters['/selected-query-text'] = selection.toString();
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
    function scriptPathNumber(path) {
      const match = /^script-(\d+)$/.exec(path || '');
      return match ? parseInt(match[1], 10) : 0;
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
    function nextScriptPath(skipTabId) {
      const state = getEditorTabs();
      const taken = new Set();
      let nextNum = 1;
      getKnownChildPaths().forEach((path) => {
        taken.add(path);
        nextNum = Math.max(nextNum, scriptPathNumber(path) + 1);
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
        nextNum = Math.max(nextNum, scriptPathNumber(tab.savedPath) + 1, scriptPathNumber(tab.draftPath) + 1);
      });
      while (taken.has('script-' + nextNum)) {
        nextNum += 1;
      }
      return 'script-' + nextNum;
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
    function nudgeHawkTreeRefresh() {
      const notify = (target) => {
        if (!target || typeof target.dispatchEvent !== 'function') {
          return;
        }
        try {
          target.dispatchEvent(new Event('focus'));
          target.dispatchEvent(new Event('resize'));
          target.dispatchEvent(new PopStateEvent('popstate'));
        } catch (_err) {
          // best effort only
        }
      };
      notify(window);
      try {
        if (window.parent && window.parent !== window) {
          notify(window.parent);
        }
      } catch (_err) {
        // ignore cross-frame access issues
      }
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
      const existingIndex = state.tabs.findIndex((tab) => normalizeChildPath(tab.savedPath || '') === normalizedPath);
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
        title: 'tab-' + id,
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
    if (!window.obeliskKeyHandler) {
      window.obeliskKeyHandler = true;
      window.addEventListener('keydown', (e) => {
        if (e.key == 'F5') {
          $('#run-btn').click()
        }
      })
    }
    setTimeout(setupEditorTabs, 0);
    '''
  ==
  ::
::
::::::::::::::::::::::::::::::::::::::
::  obelisk types & wrapper
::
::
+$  server  (map @tas *)
+$  database
  $:  %database
    name=@tas
    created-provenance=path
    created-tmsp=@da
    sys=((mop @da schema) gth)
    ::content=((mop @da data) gth)
    content=((mop @da *) gth)
    ::=view-cache
    view-cache=*
    ==
::
+$  schema
  $:  %schema
    provenance=path
    tmsp=@da
    =namespaces
    =tables
    =views
  :: permissions   :: maybe at server or database level?
    ==
+$  table
  $+  table
  $:  %table
    provenance=path
    tmsp=@da
    ::=column-lookup
    column-lookup=*
    typ-addr-lookup=*
    pri-indx=index
    columns=(list column)      ::  canonical column list
    indices=(list index)      :: to do: indices indexed by (list column)
    ==
+$  column
  $+  column
  $:  %column
    name=@tas
    type=@ta
    addr=@
    ==
+$  ns-rel-key
  $:  ns=@tas
      rel=@tas
      time=@da
      ==
++  ns-rel-comp
  |=  [p=ns-rel-key q=ns-rel-key]
  ^-  ?
  ?.  =(ns.p ns.q)  (gth ns.p ns.q)
  ?.  =(rel.p rel.q)  (gth rel.p rel.q)
  (gth time.p time.q)
+$  namespaces  (map @tas @da)
+$  tables  (map [@tas @tas] table)
+$  views  ((mop ns-rel-key view) ns-rel-comp)
+$  view
  $+  view
  $:  %view
    provenance=path
    tmsp=@da
    ::=selection
    ::=column-lookup
    selection=*
    column-lookup=*
    typ-addr-lookup=*
    columns=(list column)      ::  canonical column list
    :: to do: replace ordering with index (requires non-unique mop type)
    ordering=(list *)
    :: indices
    ==
+$  index
  $:  %index
    unique=?
    key=(list key-column)
    ==
+$  key-column
  $:  %key-column
    name=@tas
    =aura
    ascending=?
    ==
::
::  OUTPUT
::
+$  cmd-result  [%results (list result)]
+$  result
  $%
    [%action action=@t]
    [%relation relation=@t]
    [%message msg=@t]
    [%vector-count count=@ud]
    [%server-time date=@da]
    [%security-time date=@da]
    [%schema-time date=@da]
    [%data-time date=@da]
    [%result-set (list vector)]
    ==
::
+$  vector-cell  [p=@tas q=dime]
+$  vector
  $+  vector
  $:  %vector
    (lest vector-cell)
    ==
--
