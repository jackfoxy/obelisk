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
    ;details#file-menu.rel(style "position: relative; display: inline-block;")
      ;summary.underline(style "list-style: none; cursor: pointer; display: inline-block;")
        ;span: File
      ==
      ;div.abs.b2.bd1.br1.fc(style "position: absolute; z-index: 10; min-width: 12rem; top: calc(100% + 0.25rem); left: 0;")
        ;button.wf.p-1.hover(type "button", onclick "newEditorTab()", style "text-align: left;"): New
        ;button.wf.p-1.hover(type "button", disabled "", style "text-align: left;"): Open...
        ;button.wf.p-1.hover(type "button", onclick "submitSavePanel()", style "text-align: left;"): Save
        ;button.wf.p-1.hover(type "button", onclick "toggleSaveAsPanel()", style "text-align: left;"): Save As...
        ;button.wf.p-1.hover(type "button", onclick "closeCurrentTab()", style "text-align: left;"): Close
        ;form#save-panel-form.fc.g1.loader.p2.b1
          =method  "post"
          =action  "/apps/hawk/code{(spud here)}/script-1"
          =target  "save-panel-target"
          =onsubmit  "prepareExportForm(this)"
          =style  "display: none;"
          ;div.s-2.o7: Save main panel to child path
          ;input#save-panel-child.br1.bd1.p-1.wfc(name "_child-path", value "script-1", placeholder "script-1");
          ;input.hidden(name "code", value "");
          ;input.hidden(name "/protocol", value "/text/plain");
          ;button.p-1.bd1.br1.b2.hover.loader(type "submit")
            ;span.loaded.fr.ac.g1
              ;span: Save
            ==
            ;span.loading: ...
          ==
        ==
      ==
    ==
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
    ;iframe.hidden(name "save-panel-target");
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
                    ;details
                      ;summary
                        ;span.f4.mono: [tbl]
                        ;span: {(trip -.tbl)}
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
                    ;details
                      ;summary
                        ;span.f4.mono: [vw]
                        ;span: {(trip -.vw)}
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
    ;input.hidden(name "/", value "query");
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
      syncEditorTabs();
      e.detail.parameters['schema-open'] = $('#h-schema').is('[open]')
      e.detail.parameters['schema-size'] = $('#h-schema').attr('size') || '0.3';
      e.detail.parameters['output-size'] = $('#h-output').attr('size') || '0.3';
      let selection = window.getSelection()
      e.detail.parameters['/selected-query-text'] = selection.toString();
    }
    function prepareExportForm(form) {
      const childInput = form.querySelector('#save-panel-child');
      const rawChild = (childInput && childInput.value ? childInput.value : 'script-1').trim();
      const parts = rawChild.split('/').map((part) => part.trim()).filter(Boolean);
      const safeChild = (parts.length ? parts : ['script-1']).map(encodeURIComponent).join('/');
      const codeInput = form.querySelector('[name="code"]');
      if (codeInput) {
        codeInput.value = $('#query-text').val() || '';
      }
      form.action = '/apps/hawk/code{(spud here)}/' + safeChild;
    }
    function submitSavePanel() {
      const form = document.getElementById('save-panel-form');
      if (!form) {
        return;
      }
      syncEditorTabs();
      prepareExportForm(form);
      if (form.requestSubmit) {
        form.requestSubmit();
      } else {
        form.submit();
      }
      closeFileMenu(form);
    }
    function toggleSaveAsPanel() {
      const form = document.getElementById('save-panel-form');
      if (!form) {
        return;
      }
      const hidden = (form.style.display === 'none' || form.style.display === '');
      form.style.display = hidden ? 'flex' : 'none';
      if (hidden) {
        const input = form.querySelector('#save-panel-child');
        if (input) {
          input.focus();
          input.select();
        }
      }
    }
    function closeFileMenu(el) {
      const details = el.closest('details');
      if (details) {
        details.removeAttribute('open');
      }
    }
    function getEditorTabs() {
      if (!window.obeliskEditorTabs) {
        const textarea = document.getElementById('query-text');
        const initial = textarea ? (textarea.value || '') : '';
        window.obeliskEditorTabs = {
          active: 0,
          nextId: 2,
          tabs: [{id: 1, title: 'Tab 1', code: initial}]
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
      const state = getEditorTabs();
      syncEditorTabs();
      const id = state.nextId++;
      state.tabs.push({id, title: 'Tab ' + id, code: ''});
      state.active = state.tabs.length - 1;
      renderEditorTabs();
      focusQueryEditor();
      const details = document.getElementById('file-menu');
      if (details) {
        details.removeAttribute('open');
      }
    }
    function closeCurrentTab() {
      const state = getEditorTabs();
      syncEditorTabs();
      if (state.tabs.length <= 1) {
        const id = state.nextId++;
        state.tabs = [{id, title: 'Tab ' + id, code: ''}];
        state.active = 0;
      } else {
        state.tabs.splice(state.active, 1);
        state.active = Math.max(0, state.active - 1);
      }
      renderEditorTabs();
      const details = document.getElementById('file-menu');
      if (details) {
        details.removeAttribute('open');
      }
      focusQueryEditor();
    }
    function renderEditorTabs() {
      const state = getEditorTabs();
      const list = document.getElementById('query-tabs-list');
      const textarea = document.getElementById('query-text');
      if (!list || !textarea) {
        return;
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
      textarea.value = state.tabs[state.active] ? state.tabs[state.active].code : '';
    }
    function setupEditorTabs() {
      const textarea = document.getElementById('query-text');
      const list = document.getElementById('query-tabs-list');
      if (!textarea || !list) {
        return;
      }
      if (!window.obeliskEditorTabsReady) {
        window.obeliskEditorTabsReady = true;
        textarea.addEventListener('input', () => syncEditorTabs());
      }
      renderEditorTabs();
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
