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
  =/  obelisk-command=cage  obelisk-action/!>([%tape default query])
  ;<  ~  bind:m  (watch /query/[id] dock /server)
  ;<  ~  bind:m  (poke dock obelisk-command)
  ;<  [mark =vase]  bind:m  (take-fact /query/[id])
  |=  tin=strand-input:strand
  ?~  res=(mole |.((poke-result +:vase)))
    `[%fail [%malformed-obelisk-response ~]]
  `[%done u.res]
::
+$  poke-result  (each (list cmd-result) tang)
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
  ;header.p2.frw.g2.b1(style "border-bottom: 1px solid var(--b3);")
    ;button#run-btn.p-1.bd1.br1.b2.hover.loader
      =onclick  "$('#query-form').find('[type=submit]').click()"
      ;span.loaded.fr.ac.g2
        ;span: Run
        ;span.s-2.o6: F5
      ==
      ;span.loading: ...
    ==
    ;button.p-1.bd1.br1.b2.hover(disabled ""): Parse
    ;button.p-1.bd1.br1.b2.hover(disabled ""): Upload file
    ;button.p-1.bd1.br1.b2.hover(disabled ""): Import
    ;form
      =method  "post"
      =action  "/apps/hawk/code{(spud here)}/script-1"
      =hx-on-htmx-config-request  "exportScript(event)"
      =hx-swap  "none"
      ;button.p-1.bd1.br1.b2.hover.loader(disabled "")  :: XX broken
        ;span.loaded.fr.ac.g1
          ;span: Export
        ==
        ;span.loading: ...
      ==
    ==
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
      ;span.loaded.f3: Default
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
++  print-columns
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
            ;details
              ;summary
                ;span.f4.mono: [ns]
                ;span: {(trip ns)}
              ==
              ;div.p3.fc.g1
                ;*
                %+  turn  (namespace-table-names schema ns)
                |=  tbl=[@tas table]
                  ;details
                    ;summary
                      ;span.f4.mono: [tbl]
                      ;span: {(trip -.tbl)}
                    ==
                    ;*  ~[(print-columns +.tbl)]
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
    ;input.hidden(name "/", value "query");
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
  ;div#results.grow.basis-half.b1.mono.s0
    ;div.scroll-x.scroll-y.p4(data-tab "error")
      ;*
      %+  turn  tang
      |=  =tank
      ;div
        ;*
        %+  turn  (wash [0 80] tank)
        |=  =tape
        ;div: {tape}
      ==
    ==
  ==
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
++  print-script
  ;script
    ::
    ::  this script adds some of the ui state to the card
    ::  so that it can be persisted across pokes
    ::
    ;+  ;/  %-  trip
    '''
    function configRequest(e) {
      e.detail.parameters['schema-open'] = $('#h-schema').is('[open]')
      e.detail.parameters['schema-size'] = $('#h-schema').attr('size') || '0.3';
      e.detail.parameters['output-size'] = $('#h-output').attr('size') || '0.3';
      let selection = window.getSelection()
      e.detail.parameters['/selected-query-text'] = selection.toString();
    }
    function exportScript(e) {
      let script = $('#query-text').val()
      e.detail.parameters['code'] = script;
      e.detail.parameters['/protocol'] = '/text/plain';
    }

    if (!window.obeliskKeyHandler) {
      window.obeliskKeyHandler = true;
      window.addEventListener('keydown', (e) => {
        if (e.key == 'F5') {
          $('#run-btn').click()
        }
      })
    }
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
