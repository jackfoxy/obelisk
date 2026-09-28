::  Pure state lifecycle helpers for %obelisk-web.
::
/-  urui, web=obelisk-web
/+  shell=urui-shell, ucss=urui-css, uace=urui-ace
/+  ucfg=urui-config, ujs=urui-js, ufiles=urui-files
|%
::
++  empty-durable-state
  ^-  durable-state:web
  ~
::
++  empty-transient-state
  ^-  transient-state:web
  :*  %unbound
      0
      ~
      ~
      ~
      ~
      ~
  ==
::
++  binding-after-connect
  |=  accepted=?
  ^-  binding-state:web
  ?:(accepted %bound %unbound)
::
++  max-readiness-failures
  ^-  @ud
  3
::
++  readiness-delay
  ^-  @dr
  ~s1
::
++  work-timeout
  ^-  @dr
  ~s30
::
++  max-queued-requests
  ^-  @ud
  32
::
++  queue-has-room
  |=  queue=(list queued-request:web)
  ^-  ?
  (lth (lent queue) max-queued-requests)
::
++  readiness-step
  |=  [live=? failures=@ud]
  ^-  readiness-decision:web
  ?:  live
    [%ready ~]
  =/  next-failures=@ud  +(failures)
  ?:  (lth next-failures max-readiness-failures)
    [%retry next-failures]
  [%exhausted ~]
::
++  empty-saved-state
  ^-  saved-state-0:web
  [%0 empty-durable-state]
::
++  make-live-state
  |=  durable=durable-state:web
  ^-  live-state:web
  [%0 durable empty-transient-state]
::
++  empty-live-state
  ^-  live-state:web
  (make-live-state empty-durable-state)
::
++  save-state
  |=  state=live-state:web
  ^-  saved-state-0:web
  [%0 durable.state]
::
++  migrate-saved-state
  |=  old=versioned-saved-state:web
  ^-  saved-state-0:web
  ?-  -.old
    %0  old
  ==
::
++  load-state
  |=  old=versioned-saved-state:web
  ^-  live-state:web
  (make-live-state durable:(migrate-saved-state old))
::
++  load-vase
  |=  old-vase=vase
  ^-  (each live-state:web tang)
  %-  mule  |.
  =/  old  !<(versioned-saved-state:web old-vase)
  (load-state old)
::
++  files
  ::  Obelisk's document store and file tree, as urui declares them.
  ::
  ::  `/results` is written by result export alone, through +write, so
  ::  a result opened in a tab is read-only.
  ^-  files:urui
  :*  url='/apps/obelisk/files'
      :~  :*  name=%script
              noun='Script'
              untitled='script'
              starter=''
              :~  [/scripts ~[%txt] ~ &]
                  [/results ~[%csv %tab %txt %md %html %json %noun] ~ |]
              ==
              preview=`%source
              actions=~[%open %save %save-as %copy]
              refs=&
              share=~
      ==  ==
      ~[[view=%files store=%script scopes=~]]
  ==
::
++  file-policy
  ::  The stock codecs, plus `noun` results stored as lines.
  ^-  policy:ufiles
  =/  base=policy:ufiles  (make-policy:ufiles files /data/obelisk &)
  base(codecs (snoc codecs.base [%noun %wain]))
::
++  ace-spec
  ::  Text mode for scripts and result files alike; the vim keymap is
  ::  not in `exts`, which load by plain module name, because Ace
  ::  fetches a keyboard handler through its own ["keybinding", id] form.
  ^-  ace-spec:urui
  :*  base='/apps/obelisk/ace'
      global='obeliskAceAssets'
      version='1.44.0'
      mode='ace/mode/text'
      light='ace/theme/github'
      dark='ace/theme/monokai'
      :~  'ace/ext/beautify'  'ace/ext/prompt'
          'ace/ext/searchbox'  'ace/ext/settings_menu'
      ==
      use-worker=|
  ==
::
++  ace-config-js
  ^-  @t
  (config-js:uace ace-spec)
::
++  config
  ^-  app-config:urui
  :*  :*  name=%obelisk
          title='Obelisk'
          base='/apps/obelisk'
          storage-key='obelisk.session.v1'
          storage-version=2
      ==
      :*  render-debounce=0
          save-debounce=150
          min-explorer=180
          divider=10
          pane-min=30
          pane-max=85
          max-source=262.144
      ==
      slots
      ~[['F5' 'run' %always]]
      ~[[%ready 'Ready']]
      docs-root=`'/docs/d/obelisk/'
      ace-spec
      layout=%rows
      collapse=&
      files=`files
  ==
::
++  slots
  ^-  (list slot:urui)
  :~  ['workbench' %app %record ~]
      ['paneBands' %urui %record ~]
      ['panePaths' %urui %record ~]
      ['paneWidth' %urui %scalar ~]
      ['paneHeight' %urui %scalar ~]
      ['resultOpen' %urui %scalar ~]
      ['explorerWidth' %urui %scalar ~]
      ['explorerOpen' %urui %scalar ~]
      ['explorerView' %urui %scalar ~]
      ['explorerOrder' %urui %scalar ~]
      ['scriptTabs' %urui %tabs `%script]
      ['activeScriptId' %urui %active `%script]
      ['nextScript' %urui %next `%script]
      ['fileTrees' %urui %record ~]
      ['docsTabs' %urui %tabs ~]
      ['nextDocs' %urui %next ~]
      ['refTabs' %urui %tabs ~]
      ['nextRef' %urui %next ~]
      ['preferences.theme' %urui %scalar ~]
      ['preferences.layout' %urui %scalar ~]
      ['preferences.keybindings' %urui %scalar ~]
  ==
::
++  page
  |=  our=@p
  ^-  @t
  (crip (en-xml:html (build:shell (spec our))))
::
++  spec
  |=  our=@p
  ^-  shell-spec:urui
  :*  config
      brand
      toolbar
      [(reference-pane our) editor-pane result-pane]
      help
      dialogs
      styles=~['/apps/obelisk/app.css']
      :~  '/apps/obelisk/ace/ace.js'
          '/apps/obelisk/ace/obelisk-config.js'
          '/apps/obelisk/ace/theme-github.js'
          '/apps/obelisk/ace/ext-beautify.js'
          '/apps/obelisk/app.js'
      ==
      head=~[favicon]
  ==
::
++  favicon
  ^-  manx
  ;link(rel "icon", type "image/x-icon", href "/apps/obelisk/favicon.ico");
::
++  pinned
  ::  A band the user cannot hide: no reveal key, so no toggle.
  |=  [name=@tas item=band-item:urui]
  ^-  band:urui
  [name [key=~ open=& label=''] item]
::
++  reference-pane
  ::  The explorer.  urui fills `#files-tree` from the `script` store;
  ::  obelisk renders `#schemas-tree`.
  |=  our=@p
  ^-  pane:urui
  :*  role=%reference
      id='explorer-pane'
      label='Obelisk explorer'
      mode=%read-only
      kind=~
      ::  the label leads: the %tabs band carries the panels and grows,
      ::  so anything after it lands at the bottom of the pane
      :~  (pinned %ship [%label (scot %p our)])
          %+  pinned  %tabs
          :-  %tabs
          :~  :*  name=%view
                  label='Obelisk explorer'
                  source=%views
                  kind=~
                  fixed=~[[%schemas 'Schemas'] [%files 'Files']]
                  add=~
                  close=|
                  reorder=|
              ==
          ==
          (pinned %body [%panel 'explorer-body' ~ ~])
      ==
  ==
::
++  editor-pane
  ::  Tabs first, then the heading: the language on the left, urui's
  ::  file actions and source/preview toggle on the right.  The panel is
  ::  urui's editor host, load-error notice, and preview host.
  ^-  pane:urui
  :*  role=%editor
      id='editor-pane'
      label='Query editor'
      mode=%read-write
      kind=~
      :~  %+  pinned  %tabs
          :-  %tabs
          :~  :*  name=%script
                  label='Query tabs'
                  source=%documents
                  kind=`%script
                  fixed=~
                  add=`'New query tab'
                  close=&
                  reorder=&
              ==
          ==
          %+  pinned  %head
          [%heading ~ ~ ~[;span#editor-language.editor-mode:"urQL"]]
          %+  pinned  %body
          [%panel 'editor-body' `['query-editor' 'urQL query' '' | | 262.144] ~]
      ==
  ==
::
++  result-pane
  ::  Heading first, then one command level.  A command's Results and
  ::  Messages views and its stacked result sets stay obelisk's markup
  ::  inside `#results`.  urui appends the collapse control.
  ^-  pane:urui
  :*  role=%result
      id='output-pane'
      label='Output'
      mode=%read-write
      kind=~
      :~  (pinned %head [%heading `'Output' ~ result-actions])
          %+  pinned  %tabs
          :-  %tabs
          :~  :*  name=%command
                  label='Command results'
                  source=%dynamic
                  kind=~
                  fixed=~
                  add=~
                  close=|
                  reorder=|
              ==
          ==
          %+  pinned  %body
          :*  %panel  'output-body'  ~
              :~  ;div#results.results
                    =role        "region"
                    =aria-live   "polite"
                    =aria-label  "Query results"
                    ;p.empty-state: No results yet
                  ==
              ==
          ==
      ==
  ==
::
++  result-actions
  ^-  marl
  :~  ;button#save-output-btn.icon-button.save-action
        =type        "button"
        =title       "Save results"
        =aria-label  "Save results"
        =disabled    ""
        ;span.save-icon(aria-hidden "true");
      ==
      ;button#copy-output-btn.icon-button
        =type        "button"
        =title       "Copy results"
        =aria-label  "Copy results"
        ;span.copy-icon(aria-hidden "true");
      ==
  ==
::
++  brand
  ^-  marl
  :~  ;a.brand(href "/apps/obelisk", aria-label "Obelisk home"): Obelisk
  ==
::
++  toolbar
  ::  No theme control: urui's settings modal owns it; the Settings
  ::  button itself is placed here, between Parse and Help.
  ^-  marl
  :~  ;nav.toolbar(aria-label "Obelisk workbench controls")
        ;div.default-database
          ;label(for "default-db"): Default DB
          ;select#default-db(name "default-db")
            ;option(value "sys"): sys
          ==
        ==
        ;button#run-btn.primary(type "button", title "Run (F5)")
          ;span: Run
          ;kbd: F5
        ==
        ;button#parse-btn(type "button"): Parse
        ;+  settings-button:shell
        ;button#help(type "button", aria-expanded "false"): Help
      ==
  ==
::
++  help
  ^-  marl
  :~  ;div#fallback-help-content
        ;nav.help-links(aria-label "Obelisk documentation")
          ;a
            =href
              "https://github.com/jackfoxy/obelisk/tree/master/".
              "desk/doc/usr/reference/"
            =target  "_blank"
            =rel     "noopener noreferrer"
            Reference
          ==
          ;a
            =href
              "https://github.com/jackfoxy/obelisk/blob/master/".
              "desk/doc/usr/users-guide.md"
            =target  "_blank"
            =rel     "noopener noreferrer"
            Users Guide
          ==
          ;a
            =href
              "https://github.com/jackfoxy/obelisk/blob/master/".
              "roadmap.md"
            =target  "_blank"
            =rel     "noopener noreferrer"
            Roadmap
          ==
        ==
        ;section.help-section
          ;h3: For Developers
          ;nav#developer-help-links.help-links
            =aria-label  "Obelisk developer documentation"
            ;a
              =href
                "https://github.com/jackfoxy/obelisk/blob/master/".
                "desk/sur/obelisk-ast.hoon"
              =target  "_blank"
              =rel     "noopener noreferrer"
              API/AST
            ==
            ;a
              =href
                "https://github.com/jackfoxy/obelisk/tree/master/".
                ".claude/skills/obelisk-urql"
              =target  "_blank"
              =rel     "noopener noreferrer"
              urQL LLM
            ==
            ;a
              =href
                "https://github.com/jackfoxy/obelisk/blob/master/".
                "desk/doc/dev/users-guide-script.txt"
              =target  "_blank"
              =rel     "noopener noreferrer"
              Sample urQL
            ==
            ;a
              =href
                "https://github.com/jackfoxy/obelisk/blob/master/".
                "desk/doc/dev/performance.md"
              =target  "_blank"
              =rel     "noopener noreferrer"
              Benchmarks
            ==
          ==
        ==
      ==
      ;div#docs-help-content.docs-help-content(hidden "")
        ;nav#docs-help-nav.docs-help-nav
          =aria-label  "Obelisk documentation in Docs"
          =aria-busy   "true"
          ;p.docs-help-loading: Loading documentation…
        ==
        ;a.docs-llm-button
          =href
            "https://github.com/jackfoxy/obelisk/tree/master/".
            ".claude/skills/obelisk-urql"
          =target  "_blank"
          =rel     "noopener noreferrer"
          =role    "button"
          urQL LLM
        ==
      ==
  ==
::
++  dialogs
  ::  The file dialog, confirm dialog, toast, and file context menu are
  ::  urui's.  The results format field waits hidden here until result
  ::  export lends it to urui's file dialog.
  ^-  marl
  :~  ;label#results-format-field(for "results-format-select", hidden "")
        Format
        ;select#results-format-select(name "results-format")
          ;option(value "%csv"): comma-separated
          ;option(value "%tab"): tab-separated
          ;option(value "%spac"): space-separated
          ;option(value "%markdown"): markdown
          ;option(value "%html"): html
          ;option(value "%tape"): text
          ;option(value "%json"): json
          ;option(value "%wain"): %wain
          ;option(value "%manx"): %manx
          ;option(value "%vector"): %vector
          ;option(value "%raw"): %raw
        ==
      ==
      ;div#relation-menu.relation-menu.hidden(role "menu")
        ;button#relation-select(type "button", role "menuitem")
          SELECT
        ==
        ;button#relation-insert(type "button", role "menuitem")
          INSERT
        ==
        ;button#relation-create(type "button", role "menuitem")
          CREATE
        ==
      ==
  ==
::
++  css
  ^-  @t
  %+  rap  3
  :~  %-  compose:ucss
      :~  %tokens  %controls  %shell  %explorer
          %tabs  %dialogs  %responsive
      ==
      app-css
  ==
::
++  app-css
  ::  Obelisk's palette and its own surfaces: the relation menu, the
  ::  results format field, the schema tree, the editor heading, and
  ::  command output.  The frame, panes, tabs, explorer, file tree,
  ::  dialogs, toast, previews, help, and dark theme are urui's.
  ::
  ::  The light palette overrides urui's tokens on `:root`; urui's dark
  ::  palette is already obelisk's, and its `data-effective-theme`
  ::  selector outranks this one.
  ^-  @t
  '''
  :root {
    --background: #f7f7f4;
    --surface-alt: #f0f0eb;
    --ink: #181817;
    --muted: #66665f;
    --border: #d4d4cc;
    --accent: #6d28d9;
    --focus: #2563eb;
    --explorer-width: 320px;
    --editor-height: 66.67%;
  }

  body {
    font-family: Inter, ui-sans-serif, system-ui, sans-serif;
    font-size: 15px;
    line-height: normal;
    overflow: hidden;
  }

  button, select { min-height: 2rem; }

  a { border-radius: 0.2rem; color: inherit; }

  a:hover { background: var(--surface-alt); }

  .brand {
    font-size: 1.05rem;
    font-weight: 700;
    text-decoration: none;
  }

  .toolbar { align-items: center; }

  .toolbar kbd {
    font-family: ui-monospace, monospace;
    font-size: 0.72rem;
    margin-left: 0.35rem;
    opacity: 0.8;
  }

  .default-database {
    align-items: center;
    display: flex;
    gap: 0.35rem;
  }

  .default-database label {
    color: var(--muted);
    font-size: 0.8rem;
    white-space: nowrap;
  }

  .hidden { display: none !important; }

  /* ---- menus and the results format field -------------------------- */

  #results-format-select {
    background: var(--surface);
    border: 1px solid var(--border);
    border-radius: 0.3rem;
    color: var(--ink);
    min-height: 2.25rem;
    padding: 0.4rem 0.55rem;
    width: 100%;
  }

  #results-format-field {
    color: var(--muted);
    display: grid;
    font-size: 0.8rem;
    gap: 0.3rem;
  }

  #results-format-field[hidden] { display: none; }

  .relation-menu {
    background: var(--surface);
    border: 1px solid var(--border);
    border-radius: 0.4rem;
    box-shadow: 0 0.7rem 2rem rgb(0 0 0 / 0.16);
    display: grid;
    min-width: 9rem;
    padding: 0.3rem;
    position: fixed;
    z-index: 60;
  }

  .relation-menu button {
    background: transparent;
    border: 0;
    text-align: left;
  }

  /* ---- explorer trees ---------------------------------------------- */

  #explorer-pane-ship {
    font-family: ui-monospace, monospace;
    font-size: 0.78rem;
  }

  .results {
    flex: 1 1 auto;
    min-height: 0;
    overflow: auto;
    padding: 0.75rem;
  }

  .schema-children {
    border-left: 1px solid var(--border);
    margin-left: 0.7rem;
    padding-left: 0.65rem;
  }

  .relation-actions {
    display: inline-block;
    flex: 0 0 auto;
    margin-left: auto;
    min-height: 1.55rem;
    padding: 0 0.45rem;
  }

  .schema-node { margin: 0.1rem 0; }

  .schema-node > summary {
    align-items: center;
    border-radius: 0.25rem;
    cursor: pointer;
    display: flex;
    gap: 0.35rem;
    min-height: 1.9rem;
    padding: 0.15rem 0.25rem;
  }

  .schema-node > summary:hover { background: var(--surface-alt); }

  .schema-tag, .schema-column-aura, .schema-key {
    color: var(--muted);
    font-family: ui-monospace, monospace;
    font-size: 0.78rem;
  }

  .schema-default {
    color: var(--accent);
    font-size: 0.75rem;
  }

  .relation-summary {
    padding-right: 2.3rem !important;
    position: relative;
  }

  .schema-column {
    align-items: center;
    display: grid;
    gap: 0.35rem;
    grid-template-columns: 1.5rem 3.5rem minmax(0, 1fr);
    min-height: 1.75rem;
    padding: 0.1rem 0.25rem;
  }

  /* ---- editor ------------------------------------------------------ */

  .editor-pane > .pane-header {
    color: var(--muted);
    font-size: 0.8rem;
    min-height: 2.4rem;
    padding: 0.35rem 0.65rem;
  }

  /* the heading has no title, so its one action row spans it: the
     language left, urui's file actions and view toggle right */
  .editor-pane > .pane-header .pane-actions { flex: 1; }

  .pane-actions {
    align-items: center;
    display: flex;
    gap: 0.35rem;
  }

  .editor-mode { margin-right: auto; }

  #copy-output-btn, #save-output-btn, #result-collapse {
    height: 2rem;
    padding: 0;
    width: 2rem;
  }

  .save-icon {
    border: 1.5px solid currentcolor;
    border-radius: 2px;
    height: 0.9rem;
    position: relative;
    width: 0.9rem;
  }

  .save-icon::before, .save-icon::after {
    border: 1.5px solid currentcolor;
    content: '';
    left: 0.16rem;
    position: absolute;
    width: 0.42rem;
  }

  .save-icon::before {
    border-top: 0;
    height: 0.23rem;
    top: -0.02rem;
  }

  .save-icon::after {
    bottom: 0.07rem;
    height: 0.24rem;
  }

  .copy-icon::after { background: var(--surface); }

  /* urui's host keeps a 12rem floor; the rows layout's editor may be
     shorter, as it was before urui mounted it */
  #query-editor {
    background: var(--surface);
    border: 0;
    font: 0.95rem/1.55 ui-monospace, monospace;
    min-height: 0;
    outline: none;
    width: 100%;
  }

  #query-editor.ace_focus, #query-editor:focus-within {
    box-shadow: inset 0 0 0 2px var(--accent);
    outline: 3px solid var(--focus);
    outline-offset: -3px;
  }

  #query-editor[hidden] { display: none; }

  /* ---- output ------------------------------------------------------ */

  #output-pane { flex-direction: column; }

  .workspace[data-layout='rows'] #output-pane {
    border-top: 1px solid var(--border);
  }

  .pane-header h2 { font-size: 0.95rem; }

  .empty-state {
    color: var(--muted);
    margin: 0;
  }

  .error-pane, .plain-output, .parse-output {
    font: 0.86rem/1.5 ui-monospace, monospace;
    margin: 0;
    overflow-wrap: anywhere;
    white-space: pre-wrap;
  }

  .error-pane { color: #b91c1c; }

  .error-summary {
    color: #b91c1c;
    font-weight: 600;
    margin: 0 0 0.45rem;
  }

  .command-group {
    border: 1px solid var(--border);
    border-radius: 0.45rem;
    margin-bottom: 0.75rem;
    min-width: 0;
  }

  .command-heading {
    background: var(--surface-alt);
    border-bottom: 1px solid var(--border);
    font-size: 0.88rem;
    margin: 0;
    padding: 0.5rem 0.65rem;
  }

  .command-tab-panel .command-group { margin-bottom: 0; }

  .result-tabs {
    border-bottom: 1px solid var(--border);
    display: flex;
    gap: 0.25rem;
    padding: 0.35rem 0.5rem 0;
  }

  .result-tab {
    border-bottom-left-radius: 0;
    border-bottom-right-radius: 0;
  }

  .result-tab[draggable='true'] { cursor: grab; }

  .result-tab.is-dragging { opacity: 0.45; }

  .result-tab[aria-selected="true"] {
    background: var(--surface);
    border-bottom-color: var(--surface);
    font-weight: 600;
  }

  .command-panel, .command-metadata { padding: 0.65rem; }

  .result-set + .result-set { margin-top: 1rem; }

  .result-set-heading {
    font-size: 0.84rem;
    margin: 0 0 0.4rem;
  }

  .result-table-wrap {
    border: 1px solid var(--border);
    overflow-x: auto;
  }

  .result-table {
    border-collapse: collapse;
    font: 0.82rem/1.4 ui-monospace, monospace;
    white-space: nowrap;
    width: max-content;
  }

  .result-table th, .result-table td {
    border-bottom: 1px solid var(--border);
    border-right: 1px solid var(--border);
    padding: 0.35rem 0.5rem;
    text-align: left;
  }

  .result-table th {
    background: var(--surface-alt);
    position: sticky;
    top: 0;
  }

  .result-table .row-number {
    color: var(--muted);
    text-align: right;
  }

  .result-pager {
    align-items: center;
    display: flex;
    gap: 0.45rem;
  }

  .result-pager-top { margin-bottom: 0.45rem; }

  .result-pager-bottom { margin-top: 0.45rem; }

  .result-pager-status {
    color: var(--muted);
    margin-left: 3.25rem;
  }

  .metadata-list {
    display: grid;
    gap: 0.35rem;
    margin: 0;
  }

  .metadata-row {
    display: grid;
    gap: 0.55rem;
    grid-template-columns: max-content minmax(0, 1fr);
  }

  .metadata-row dt { color: var(--muted); }

  .metadata-row dd {
    font-family: ui-monospace, monospace;
    margin: 0;
    overflow-wrap: anywhere;
    white-space: pre-wrap;
  }

  /* ---- help -------------------------------------------------------- */

  .help-section { margin-top: 1rem; }

  .help-section h3 {
    font-size: 0.9rem;
    margin: 0 0 0.5rem;
  }

  .docs-llm-button {
    border: 1px solid var(--accent);
    border-radius: 0.4rem;
    padding: 0.65rem 0.75rem;
    text-align: center;
    text-decoration: none;
  }

  @media (max-width: 760px) {
    body { overflow: auto; }

    .app-header { align-items: flex-start; }

    .toolbar { align-items: stretch; }
  }

  @media (prefers-reduced-motion: reduce) {
    *, *::before, *::after {
      scroll-behavior: auto !important;
      transition-duration: 0.01ms !important;
    }
  }
  '''
::
++  javascript
  ::  urui's config and runtime, then obelisk's tail.  A gate because the
  ::  config carries the pane spec, and the spec carries the ship.
  |=  our=@p
  ^-  @t
  %+  rap  3
  :~  (emit:ucfg (spec our))
      core:ujs
      app-js
  ==
::
++  app-js
  ::  Obelisk's behaviour on urui's frame.  urui owns layout, the
  ::  explorer strip, docs tabs, help, settings, theme, the tab strips,
  ::  and the `script` store: its tabs, editor, files, tree, dialogs,
  ::  previews, and toast.  This owns the schema tree, the relation
  ::  menu, run and parse, command output, and result export.
  ^-  @t
  '''
  (() => {
    'use strict';

    const byId = (id) => document.getElementById(id);
    const workbench = byId('workbench');
    const explorerPane = byId('explorer-pane');
    const outputTabsBand = byId('output-pane-tabs');
    const editorLanguage = byId('editor-language');
    const runButton = byId('run-btn');
    const parseButton = byId('parse-btn');
    const saveOutputButton = byId('save-output-btn');
    const copyOutputButton = byId('copy-output-btn');
    const defaultDatabase = byId('default-db');
    const schemasPanel = byId('schemas-panel');
    const schemaTree = byId('schemas-tree');
    const results = byId('results');
    const resultsFormatField = byId('results-format-field');
    const resultsFormatSelect = byId('results-format-select');
    const relationMenu = byId('relation-menu');
    //  urui mounts the query editor in `docs.start()`, at boot
    let editor;
    const runtime = window.urui.runtime({
      session: {
        read: (key) => key === 'workbench' ? state : undefined,
        validate: (key, raw) => {
          return key === 'workbench' ? validWorkbench(raw) : undefined;
        }
      },
      panes: {
        onSelect: (paneId, _level, id) => {
          if (paneId !== 'output-pane') return;
          const position = Number(String(id).replace('command-', ''));
          if (Number.isInteger(position)) selectCommand(position);
        }
      },
      //  Script tabs are urui's `script` store: tabs, files, the tree,
      //  source and preview, and their references.  A result opened from
      //  the tree is read-only, and neither runs nor parses.
      documents: {
        script: {
          activate: (tab) => {
            showLanguage(tab);
            updateExecutionControls();
            updateOutputControls();
          }
        }
      },
      //  a result reference is a snapshot and is not saved
      refs: {
        result: {
          persist: false,
          create: ({data}) => {
            return {label: `Results ${nextResultRef++}`, data};
          },
          render: renderResultRef
        },
        //  parse output is plain text, so unlike a result set it is
        //  small enough to keep across reloads
        parse: {
          create: ({data}) => {
            return {label: `Parse ${nextParseRef++}`, data};
          },
          render: renderParseRef,
          validate: (data) => {
            return typeof data?.text === 'string' ?
              {text: data.text} : undefined;
          }
        }
      }
    });
    const docs = runtime.documents;
    const notify = runtime.notify;

    let lastOutputText = '';
    let outputState = {
      kind: 'empty',
      resultId: null,
      commands: [],
      activeCommand: null,
      text: '',
      exportable: false,
      path: null,
      format: null
    };
    let busy = false;
    let outputRun = 0;
    let nextResultRef = 1;
    let nextParseRef = 1;
    let schemaValue = null;
    let schemaPromise = null;
    let relationContext = null;

    function initialState() {
      return {
        defaultDatabase: null,
        schemaExpanded: [],
        schemaDatabaseNames: []
      };
    }

    //  The `workbench` slot of urui's session record: the default
    //  database and the schema tree's folds.  Anything unreadable starts
    //  afresh rather than failing.
    function validWorkbench(saved) {
      const restored = initialState();
      if (!saved || typeof saved !== 'object') return restored;
      if (typeof saved.defaultDatabase === 'string') {
        restored.defaultDatabase = saved.defaultDatabase;
      }
      ['schemaExpanded', 'schemaDatabaseNames'].forEach((key) => {
        if (Array.isArray(saved[key])) {
          restored[key] = saved[key].filter((item) => {
            return typeof item === 'string';
          });
        }
      });
      return restored;
    }

    //  replaced by the saved workbench once urui's session loads
    let state = initialState();

    //  urui writes the whole record, `workbench` included, on a short
    //  debounce and again on unload
    function persist() {
      runtime.session.queue();
    }

    function activeTab() {
      return docs.active('script');
    }

    function activeTabIsResult() {
      return activeTab()?.path?.[0] === 'results';
    }

    //  The heading names what the active tab holds: urQL for a script,
    //  else the stored result's format.
    const languageNames = {md: 'Markdown', html: 'HTML'};

    function showLanguage(tab) {
      const path = tab?.path;
      const mark = path?.[0] === 'results' ? path[path.length - 1] : null;
      editorLanguage.textContent = mark ?
        (languageNames[mark] || mark.toUpperCase()) : 'urQL';
    }

    function updateOutputControls() {
      copyOutputButton.disabled = !outputCopyAvailable();
      saveOutputButton.disabled = busy || !outputState.exportable;
      saveOutputButton.setAttribute(
        'aria-disabled',
        String(saveOutputButton.disabled)
      );
    }

    function updateExecutionControls() {
      const blocked = busy || activeTabIsResult();
      runButton.disabled = blocked;
      parseButton.disabled = blocked;
    }

    function setBusy(value, label = '') {
      busy = value;
      workbench.setAttribute('aria-busy', String(value));
      results.setAttribute('aria-busy', String(value));
      updateExecutionControls();
      runButton.firstElementChild.textContent = value && label === 'run' ?
        'Running…' : 'Run';
      parseButton.textContent = value && label === 'parse' ?
        'Parsing…' : 'Parse';
      updateOutputControls();
    }

    function notifyError(error) {
      const message = error instanceof Error ? error.message : String(error);
      notify(message, {
        kind: 'error',
        sticky: true,
        details: Array.isArray(error?.details) ? error.details : []
      });
    }

    function errorMessage(body, fallback) {
      if (!body || !body.error) return fallback;
      const details = Array.isArray(body.error.details) ?
        body.error.details.join('\n') : '';
      return details ? `${body.error.message}\n${details}` :
        body.error.message;
    }

    //  Obelisk's api answers `{type: 'error'}` on failure; urui's file
    //  wire answers `{ok: false}`.  Both carry the same `error` record.
    async function post(url, payload) {
      const response = await fetch(url, {
        method: 'POST',
        credentials: 'same-origin',
        headers: {'content-type': 'application/json'},
        body: JSON.stringify(payload)
      });
      let body = null;
      try {
        body = await response.json();
      } catch (_) {
        throw new Error(`Server returned invalid JSON (${response.status}).`);
      }
      if (!response.ok || body.type === 'error' || body.ok === false) {
        const fallback = `Request failed (${response.status}).`;
        const error = new Error(errorMessage(body, fallback));
        error.status = response.status;
        error.code = body && body.error ? body.error.code : null;
        error.retryable = Boolean(body && body.error &&
          body.error.retryable);
        error.details = body && body.error ? body.error.details : [];
        throw error;
      }
      return body;
    }

    async function api(operation, payload) {
      const route = {
        'result-save': 'results/save',
        'result-text-save': 'results/save-text'
      }[operation] || operation;
      const body = await post(
        `/apps/obelisk/api/${route}`,
        Object.assign({type: operation}, payload)
      );
      //  urui's +write answers an export without echoing its path
      if (operation.startsWith('result-')) return {path: payload.path};
      return body;
    }

    function schemasShowing() {
      return runtime.layout.explorerOpen() &&
        runtime.explorer.view() === 'schemas';
    }

    //  Result export is obelisk's: urui's file dialog picks the path,
    //  with the format field lent to it, and the agent writes the file.
    const resultFormatMarks = {
      '%csv': 'csv',
      '%tab': 'tab',
      '%spac': 'txt',
      '%markdown': 'md',
      '%html': 'html',
      '%tape': 'txt',
      '%json': 'json',
      '%wain': 'noun',
      '%manx': 'noun',
      '%vector': 'noun',
      '%raw': 'noun'
    };

    //  The first `results-N` no saved result uses; a failed listing
    //  still suggests one, and a clash then asks before overwriting.
    async function nextResultName() {
      let entries = [];
      try {
        const body = await post(window.urui.config.files.url, {
          op: 'browse',
          scope: ['results']
        });
        entries = Array.isArray(body.entries) ? body.entries : [];
      } catch (_) {
        entries = [];
      }
      const names = new Set(entries.filter((entry) => {
        return Array.isArray(entry.path) && entry.path.length >= 2;
      }).map((entry) => entry.path[1]));
      let number = 1;
      while (names.has(`results-${number}`)) number += 1;
      return `results-${number}`;
    }

    function resultSaveText() {
      if (outputState.kind === 'parse') {
        return ensureTrailingNewline(outputState.text);
      }
      return null;
    }

    async function showSaveResultsDialog() {
      if (busy || !outputState.exportable) return;
      const run = outputState.kind === 'run';
      const value = outputState.path ?
        outputState.path.slice(1, -1).join('/') : await nextResultName();
      resultsFormatSelect.value = run ? (outputState.format || '%csv') :
        '%tape';
      resultsFormatField.hidden = !run;
      const picked = await docs.pickPath({
        store: 'script',
        scope: ['results'],
        title: 'Save results',
        extra: resultsFormatField,
        mark: false,
        value
      });
      if (!picked) return;
      const format = run ? (resultsFormatSelect.value || '%csv') : '%tape';
      const path = [...picked.slice(0, -1), resultFormatMarks[format]];
      await saveResultsFile(path, false, format);
    }

    async function saveResultsFile(path, overwrite, format) {
      if (busy || !outputState.exportable) return false;
      setBusy(true, 'save-results');
      try {
        let body;
        if (outputState.kind === 'run') {
          const command = Number.isInteger(outputState.activeCommand) ?
            outputState.commands[outputState.activeCommand] : null;
          if (!command || outputState.resultId === null) {
            notify('Results are no longer available.', {
              kind: 'error',
              sticky: true
            });
            return false;
          }
          const commandIndex = Number.isInteger(command.index) ?
            command.index : outputState.activeCommand;
          body = await api('result-save', {
            resultId: String(outputState.resultId),
            commandIndex: String(commandIndex),
            format: String(format || '').replace(/^%/, ''),
            path,
            overwrite
          });
        } else {
          const text = resultSaveText();
          if (text === null) return false;
          body = await api('result-text-save', {path, text, overwrite});
        }
        outputState.path = body.path.slice();
        outputState.format = format;
        docs.trees.refresh();
        const mark = body.path[body.path.length - 1];
        notify(`Saved ${body.path.slice(1, -1).join('/')}.${mark}.`);
        return true;
      } catch (error) {
        if (!overwrite && ['exists', 'changed'].includes(error.code)) {
          setBusy(false);
          const replace = await runtime.confirm(error.code, {
            path: path.join('/')
          });
          return replace ? await saveResultsFile(path, true, format) : false;
        }
        notifyError(error);
        return false;
      } finally {
        setBusy(false);
      }
    }

    function schemaExpansion(key, details) {
      details.dataset.schemaKey = key;
      details.open = state.schemaExpanded.includes(key);
      details.addEventListener('toggle', () => {
        const expanded = new Set(state.schemaExpanded);
        if (details.open) expanded.add(key);
        else expanded.delete(key);
        state.schemaExpanded = Array.from(expanded);
        persist();
      });
    }

    function schemaSummary(tag, name, marker = '') {
      const summary = document.createElement('summary');
      const tagElement = document.createElement('span');
      tagElement.className = 'schema-tag';
      tagElement.textContent = `[${tag}]`;
      const nameElement = document.createElement('span');
      nameElement.textContent = name;
      summary.append(tagElement, nameElement);
      if (marker) {
        const markerElement = document.createElement('span');
        markerElement.className = 'schema-default';
        markerElement.textContent = marker;
        summary.appendChild(markerElement);
      }
      return summary;
    }

    function schemaChildren() {
      const children = document.createElement('div');
      children.className = 'schema-children';
      children.setAttribute('role', 'group');
      return children;
    }

    function renderSchemaChildren(details, children, values, render) {
      let rendered = false;
      const populate = () => {
        if (rendered) return;
        rendered = true;
        values.forEach((value) => {
          children.appendChild(render(value));
        });
      };
      if (details.open) populate();
      details.addEventListener('toggle', () => {
        if (details.open) populate();
      });
    }

    function auraText(aura) {
      const text = String(aura || '');
      return text.startsWith('@') ? text : `@${text}`;
    }

    function foreignKeyGroups(relation) {
      const groups = [];
      const buckets = new Map();
      (relation.foreignKeys || []).forEach((foreignKey) => {
        const key = [
          foreignKey.parentNamespace,
          foreignKey.parentTable,
          foreignKey.onDelete,
          foreignKey.onUpdate
        ].join('\u0000');
        const bucket = buckets.get(key) || [];
        let group = bucket.find((candidate) => {
          return foreignKey.ordinal > 1 &&
            candidate.rows.length === foreignKey.ordinal - 1;
        });
        if (!group) {
          group = {
            parentNamespace: foreignKey.parentNamespace,
            parentTable: foreignKey.parentTable,
            onDelete: foreignKey.onDelete,
            onUpdate: foreignKey.onUpdate,
            rows: [foreignKey]
          };
          bucket.push(group);
          buckets.set(key, bucket);
          groups.push(group);
        } else {
          group.rows.push(foreignKey);
        }
      });
      return groups;
    }

    function foreignKeyAction(action) {
      return String(action || 'restrict').replaceAll('-', ' ').toUpperCase();
    }

    function relationTemplate(action, relation) {
      const qualified = `${relation.database}.${relation.namespace}.` +
        relation.name;
      const columns = relation.columns.map((column) => column.name);
      if (action === 'SELECT') {
        return `::WITH (FROM...\n` +
          `::      SELECT...) AS ...\n` +
          `FROM ${qualified}\n` +
          `::JOIN\n` +
          `::SCALARS\n` +
          `::WHERE\n` +
          `SELECT ${columns.join(', ') || '*'} ;`;
      }
      if (action === 'INSERT' && relation.kind === 'table') {
        const values = relation.columns.map((column) => column.bunt)
          .join(', ');
        return `INSERT INTO ${qualified}\n` +
          `  (${columns.join(', ')})\nVALUES\n  (${values});`;
      }
      if (action === 'CREATE' && relation.kind === 'table') {
        const definitions = relation.columns.map((column) => {
          return `    ${column.name} ${auraText(column.aura)}`;
        }).join(',\n');
        const keys = relation.columns.filter((column) => column.key)
          .sort((left, right) => left.key.ordinal - right.key.ordinal)
          .map((column) => {
            return `${column.name} ` +
              (column.key.ascending ? 'ASC' : 'DESC');
          });
        const foreignKeys = foreignKeyGroups(relation).map((foreignKey) => {
          const childColumns = foreignKey.rows.map((row) => row.childColumn);
          const parentColumns = foreignKey.rows.map((row) => row.parentColumn);
          let clause = `(${childColumns.join(', ')}) REFERENCES ` +
            `${foreignKey.parentNamespace}.${foreignKey.parentTable} ` +
            `(${parentColumns.join(', ')})`;
          if (foreignKey.onDelete !== 'restrict') {
            clause += ` ON DELETE ${foreignKeyAction(foreignKey.onDelete)}`;
          }
          if (foreignKey.onUpdate !== 'restrict') {
            clause += ` ON UPDATE ${foreignKeyAction(foreignKey.onUpdate)}`;
          }
          return clause;
        });
        const foreignKeyClause = foreignKeys.length > 0 ?
          `\n  FOREIGN KEY ${foreignKeys.join(',\n    ')}` : '';
        return `CREATE TABLE ${qualified}\n  (\n${definitions}\n  )\n` +
          `  PRIMARY KEY (${keys.join(', ')})${foreignKeyClause};`;
      }
      return '';
    }

    function closeRelationMenu() {
      relationMenu.classList.add('hidden');
      relationContext = null;
    }

    function openRelationMenu(event, relation) {
      event.preventDefault();
      event.stopPropagation();
      relationContext = relation;
      const table = relation.kind === 'table';
      byId('relation-insert').classList.toggle('hidden', !table);
      byId('relation-create').classList.toggle('hidden', !table);
      relationMenu.classList.remove('hidden');
      const rect = relationMenu.getBoundingClientRect();
      relationMenu.style.left = `${Math.min(event.clientX,
        window.innerWidth - rect.width - 8)}px`;
      relationMenu.style.top = `${Math.min(event.clientY,
        window.innerHeight - rect.height - 8)}px`;
    }

    function openRelationAction(action) {
      if (!relationContext) return;
      const text = relationTemplate(action, relationContext);
      closeRelationMenu();
      if (text) docs.create('script', {text, focus: true});
    }

    function renderColumn(column, relation) {
      const row = document.createElement('div');
      row.className = 'schema-column';
      row.setAttribute('role', 'treeitem');
      const key = document.createElement('span');
      key.className = 'schema-key';
      key.textContent = column.key ?
        (column.key.ascending ? '↑' : '↓') : '';
      key.title = column.key ?
        `Primary key ${column.key.ordinal}, ` +
          (column.key.ascending ? 'ascending' : 'descending') : '';
      const aura = document.createElement('span');
      aura.className = 'schema-column-aura';
      aura.textContent = auraText(column.aura);
      const name = document.createElement('span');
      name.textContent = column.name;
      const foreignKey = (relation.foreignKeys || []).some((candidate) => {
        return candidate.childColumn === column.name;
      });
      if (foreignKey) {
        const marker = document.createElement('span');
        marker.className = 'schema-column-aura';
        marker.textContent = 'fk';
        name.append(' ', marker);
      }
      row.append(key, aura, name);
      return row;
    }

    function renderRelation(relation) {
      const details = document.createElement('details');
      details.className = 'schema-node';
      details.setAttribute('role', 'treeitem');
      const key = `rel:${relation.database}.${relation.namespace}.` +
        `${relation.kind}.${relation.name}`;
      schemaExpansion(key, details);
      const summary = schemaSummary(
        relation.kind === 'table' ? 'tbl' : 'vw',
        relation.name
      );
      summary.classList.add('relation-summary');
      summary.addEventListener('contextmenu', (event) => {
        openRelationMenu(event, relation);
      });
      const actions = document.createElement('button');
      actions.type = 'button';
      actions.className = 'relation-actions';
      actions.setAttribute('aria-label', `Actions for ${relation.name}`);
      actions.textContent = '…';
      actions.addEventListener('click', (event) => {
        openRelationMenu(event, relation);
      });
      summary.appendChild(actions);
      const children = schemaChildren();
      renderSchemaChildren(details, children, relation.columns, (column) => {
        return renderColumn(column, relation);
      });
      details.append(summary, children);
      return details;
    }

    function renderNamespace(database, namespace) {
      const details = document.createElement('details');
      details.className = 'schema-node';
      details.setAttribute('role', 'treeitem');
      schemaExpansion(`ns:${database.name}.${namespace.name}`, details);
      const summary = schemaSummary('ns', namespace.name);
      const children = schemaChildren();
      renderSchemaChildren(details, children, namespace.relations,
        (relation) => {
          return renderRelation(relation);
        });
      details.append(summary, children);
      return details;
    }

    function renderDatabase(database) {
      const details = document.createElement('details');
      details.className = 'schema-node';
      details.setAttribute('role', 'treeitem');
      schemaExpansion(`db:${database.name}`, details);
      const marker = database.name === state.defaultDatabase ?
        '(default)' : '';
      const summary = schemaSummary('db', database.name, marker);
      const children = schemaChildren();
      renderSchemaChildren(details, children, database.namespaces,
        (namespace) => {
          return renderNamespace(database, namespace);
        });
      details.append(summary, children);
      return details;
    }

    function renderDefaultDatabases(databases) {
      const names = databases.map((database) => database.name);
      defaultDatabase.replaceChildren();
      names.forEach((name) => {
        const option = document.createElement('option');
        option.value = name;
        option.textContent = name;
        defaultDatabase.appendChild(option);
      });
      //  an unset or vanished choice would leave the select empty, and
      //  the server refuses an empty database name
      const wanted = [state.defaultDatabase, 'sys', names[0]]
        .find((name) => names.includes(name));
      if (wanted) defaultDatabase.value = wanted;
    }

    function renderSchema(schema) {
      schemaTree.replaceChildren();
      renderDefaultDatabases(schema.databases);
      if (schema.databases.length === 0) {
        const empty = document.createElement('p');
        empty.className = 'empty-state';
        empty.textContent = 'No databases.';
        schemaTree.appendChild(empty);
      } else {
        schema.databases.forEach((database) => {
          schemaTree.appendChild(renderDatabase(database));
        });
      }
      schemaTree.setAttribute('aria-busy', 'false');
    }

    async function refreshSchema(options = {}) {
      schemaTree.setAttribute('aria-busy', 'true');
      try {
        const body = await api('schema', {
          defaultDatabase: state.defaultDatabase || null
        });
        const schema = body.value;
        const oldNames = state.schemaDatabaseNames.slice();
        const newNames = schema.databases.map((database) => database.name);
        const added = newNames.filter((name) => !oldNames.includes(name));
        if (options.preferNewDatabase && added.length === 1) {
          schema.defaultDatabase = added[0];
        }
        state.defaultDatabase = schema.defaultDatabase;
        state.schemaDatabaseNames = newNames;
        schema.databases.forEach((database) => {
          database.default = database.name === state.defaultDatabase;
        });
        schemaValue = schema;
        renderSchema(schemaValue);
        persist();
      } catch (error) {
        schemaTree.replaceChildren();
        const failure = document.createElement('p');
        failure.className = 'error-pane';
        failure.textContent = error.message;
        schemaTree.appendChild(failure);
        schemaTree.setAttribute('aria-busy', 'false');
      }
    }

    //  `always` loads even while the tree is off screen: the Default DB
    //  dropdown is filled from the same schema, and needs it at boot
    function ensureSchemaLoaded(options = {}) {
      if (!options.always && !schemasShowing()) return Promise.resolve();
      if (schemaValue && !options.force) return Promise.resolve();
      if (schemaPromise) return schemaPromise;
      schemaPromise = refreshSchema(options).finally(() => {
        schemaPromise = null;
      });
      return schemaPromise;
    }

    function selectedScript() {
      const text = editor.getSource();
      const {start, end} = editor.getSelection();
      return end > start ? text.slice(start, end) : text;
    }

    const resultPageSize = 500;
    const resultPagingThreshold = 800;

    function resultSetsForCommand(command) {
      const commandResults = Array.isArray(command.results) ?
        command.results : [];
      return commandResults.filter((result) => {
        return result && result.type === 'result-set';
      }).map((result) => result.value || {columns: [], rows: []});
    }

    function metadataForCommand(command) {
      const commandResults = Array.isArray(command.results) ?
        command.results : [];
      return commandResults.filter((result) => {
        return result && result.type !== 'result-set';
      });
    }

    function metadataLabel(type) {
      return {
        action: 'message:',
        'relation-name': 'message:',
        message: 'message:',
        'vector-count': 'vector count:',
        'server-time': 'server-time:',
        'security-time': 'security-time:',
        'schema-time': 'schema-time:',
        'data-time': 'data-time:',
        relations: 'relations:',
        'select-relation': 'select-relation:'
      }[type] || `${type}:`;
    }

    function metadataLine(result) {
      return `${metadataLabel(result.type)} ${String(result.value)}`;
    }

    function delimiterCharacter(delimiter) {
      if (delimiter === 'space') return ' ';
      if (delimiter === 'tab') return '\t';
      return ',';
    }

    function exportResultSet(resultSet, delimiter) {
      const columns = Array.isArray(resultSet.columns) ?
        resultSet.columns : [];
      if (columns.length === 0) return '';
      const separator = delimiterCharacter(delimiter);
      const lines = [columns.map((column) => column.name).join(separator)];
      const rows = Array.isArray(resultSet.rows) ? resultSet.rows : [];
      rows.forEach((row) => {
        const cells = Array.isArray(row) ? row : [];
        lines.push(cells.map((cell) => String(cell.value)).join(separator));
      });
      return lines.join('\n');
    }

    function allResultSets(commands) {
      return commands.flatMap(resultSetsForCommand);
    }

    function commandIsExportable(command) {
      return resultSetsForCommand(command).some((resultSet) => {
        return Array.isArray(resultSet.columns) &&
          resultSet.columns.length > 0;
      });
    }

    function outputCopyAvailable() {
      if (outputState.kind !== 'run') return lastOutputText.length > 0;
      const index = outputState.activeCommand;
      const command = Number.isInteger(index) ?
        outputState.commands[index] : null;
      return Boolean(command) &&
        (resultSetsForCommand(command).length > 0 ||
          metadataForCommand(command).length > 0);
    }

    function outputCopyText() {
      if (outputState.kind !== 'run') return lastOutputText;
      const index = outputState.activeCommand;
      const command = Number.isInteger(index) ?
        outputState.commands[index] : null;
      return command ? runCopyText([command]) : '';
    }

    function runExportText(commands, delimiter) {
      const chunks = allResultSets(commands).map((resultSet) => {
        return exportResultSet(resultSet, delimiter);
      }).filter((chunk) => chunk.length > 0);
      return chunks.length > 0 ? `${chunks.join('\n\n')}\n` : '';
    }

    function runMetadataText(commands) {
      const lines = commands.flatMap((command) => {
        return metadataForCommand(command).map(metadataLine);
      });
      return lines.length > 0 ? `${lines.join('\n')}\n` : '';
    }

    function runCopyText(commands) {
      const resultText = runExportText(commands, 'comma');
      const metadataText = runMetadataText(commands);
      if (!resultText) return metadataText;
      if (!metadataText) return resultText;
      return `${resultText}\n${metadataText}`;
    }

    function ensureTrailingNewline(text) {
      return text.endsWith('\n') ? text : `${text}\n`;
    }

    function renderMetadata(container, metadata) {
      if (metadata.length === 0) {
        const empty = document.createElement('p');
        empty.className = 'empty-state';
        empty.textContent = 'No messages.';
        container.appendChild(empty);
        return;
      }
      const list = document.createElement('dl');
      list.className = 'metadata-list';
      metadata.forEach((result) => {
        const row = document.createElement('div');
        row.className = 'metadata-row';
        const term = document.createElement('dt');
        term.textContent = metadataLabel(result.type);
        const description = document.createElement('dd');
        description.textContent = String(result.value);
        row.append(term, description);
        list.appendChild(row);
      });
      container.appendChild(list);
    }

    function renderResultTable(resultSet, rows, firstRow) {
      const wrapper = document.createElement('div');
      wrapper.className = 'result-table-wrap';
      const table = document.createElement('table');
      table.className = 'result-table';
      const head = document.createElement('thead');
      const headRow = document.createElement('tr');
      const numberHeading = document.createElement('th');
      numberHeading.className = 'row-number';
      numberHeading.setAttribute('aria-label', 'Row number');
      headRow.appendChild(numberHeading);
      const columns = Array.isArray(resultSet.columns) ?
        resultSet.columns : [];
      columns.forEach((column) => {
        const heading = document.createElement('th');
        heading.scope = 'col';
        heading.textContent = column.name;
        heading.title = column.aura ? `@${column.aura}` : '';
        headRow.appendChild(heading);
      });
      head.appendChild(headRow);
      const body = document.createElement('tbody');
      rows.forEach((row, rowIndex) => {
        const tableRow = document.createElement('tr');
        const number = document.createElement('th');
        number.className = 'row-number';
        number.scope = 'row';
        number.textContent = String(firstRow + rowIndex + 1);
        tableRow.appendChild(number);
        const cells = Array.isArray(row) ? row : [];
        cells.forEach((cell) => {
          const data = document.createElement('td');
          data.textContent = String(cell.value);
          data.title = cell.aura ? `@${cell.aura}` : '';
          tableRow.appendChild(data);
        });
        body.appendChild(tableRow);
      });
      table.append(head, body);
      wrapper.appendChild(table);
      return wrapper;
    }

    function renderResultSet(resultSet, resultNumber, resultCount,
        startPage = 0) {
      const section = document.createElement('section');
      section.className = 'result-set';
      if (resultCount > 1) {
        const heading = document.createElement('h4');
        heading.className = 'result-set-heading';
        heading.textContent = `Result set ${resultNumber + 1}`;
        section.appendChild(heading);
      }
      const rows = Array.isArray(resultSet.rows) ? resultSet.rows : [];
      const columns = Array.isArray(resultSet.columns) ?
        resultSet.columns : [];
      if (columns.length === 0) {
        const empty = document.createElement('p');
        empty.className = 'empty-state';
        empty.textContent = 'Empty result set.';
        section.appendChild(empty);
        return section;
      }
      const tableHolder = document.createElement('div');
      section.appendChild(tableHolder);
      if (rows.length < resultPagingThreshold) {
        tableHolder.appendChild(renderResultTable(resultSet, rows, 0));
        return section;
      }
      const pageCount = Math.ceil(rows.length / resultPageSize);
      let page = clamp(startPage, 0, pageCount - 1);
      const pagers = [];
      function makePager(position) {
        const pager = document.createElement('nav');
        pager.className = `result-pager result-pager-${position}`;
        pager.setAttribute(
          'aria-label',
          `Result pages ${position === 'top' ? 'above' : 'below'} table`
        );
        const status = document.createElement('span');
        status.className = 'result-pager-status';
        const previous = document.createElement('button');
        previous.type = 'button';
        previous.textContent = 'Previous';
        previous.addEventListener('click', () => {
          page = Math.max(0, page - 1);
          renderPage();
        });
        const next = document.createElement('button');
        next.type = 'button';
        next.textContent = 'Next';
        next.addEventListener('click', () => {
          page = Math.min(pageCount - 1, page + 1);
          renderPage();
        });
        pagers.push({status, previous, next});
        pager.append(previous, next, status);
        return pager;
      }
      const topPager = makePager('top');
      const bottomPager = makePager('bottom');
      function renderPage() {
        const first = page * resultPageSize;
        const last = Math.min(first + resultPageSize, rows.length);
        section.dataset.page = String(page);
        tableHolder.replaceChildren(
          renderResultTable(resultSet, rows.slice(first, last), first)
        );
        pagers.forEach((pager) => {
          pager.status.textContent =
            `Rows ${first + 1}–${last} of ${rows.length} · ` +
            `Page ${page + 1} of ${pageCount}`;
          pager.previous.disabled = page === 0;
          pager.next.disabled = page === pageCount - 1;
        });
      }
      section.insertBefore(topPager, tableHolder);
      section.appendChild(bottomPager);
      renderPage();
      return section;
    }

    function renderParseRef(panel, ref) {
      const pre = document.createElement('pre');
      pre.className = 'parse-output';
      pre.textContent = ref.data.text;
      panel.appendChild(pre);
    }

    function renderResultRef(panel, ref) {
      const {command, pages} = ref.data;
      const resultSets = resultSetsForCommand(command);
      resultSets.forEach((resultSet, resultNumber) => {
        panel.appendChild(renderResultSet(
          resultSet, resultNumber, resultSets.length, pages[resultNumber] || 0
        ));
      });
    }

    function renderCommand(command, position, showHeading = true) {
      const group = document.createElement('article');
      group.className = 'command-group';
      const commandIndex = Number.isInteger(command.index) ?
        command.index + 1 : position + 1;
      if (showHeading) {
        const heading = document.createElement('h3');
        heading.className = 'command-heading';
        heading.textContent = `Command ${commandIndex}`;
        group.appendChild(heading);
      }
      const resultSets = resultSetsForCommand(command);
      const metadata = metadataForCommand(command);
      if (resultSets.length === 0) {
        const direct = document.createElement('div');
        direct.className = 'command-metadata';
        renderMetadata(direct, metadata);
        group.appendChild(direct);
        return group;
      }
      const tabList = document.createElement('div');
      tabList.className = 'result-tabs';
      tabList.setAttribute('role', 'tablist');
      tabList.setAttribute('aria-label', `Command ${commandIndex} output`);
      const resultsTab = document.createElement('button');
      resultsTab.type = 'button';
      resultsTab.className = 'result-tab';
      resultsTab.textContent = 'Results';
      resultsTab.setAttribute('role', 'tab');
      resultsTab.setAttribute('aria-selected', 'true');
      const messagesTab = document.createElement('button');
      messagesTab.type = 'button';
      messagesTab.className = 'result-tab';
      messagesTab.textContent = 'Messages';
      messagesTab.setAttribute('role', 'tab');
      messagesTab.setAttribute('aria-selected', 'false');
      const resultPanel = document.createElement('div');
      resultPanel.className = 'command-panel';
      resultPanel.setAttribute('role', 'tabpanel');
      const messagePanel = document.createElement('div');
      messagePanel.className = 'command-panel hidden';
      messagePanel.setAttribute('role', 'tabpanel');
      const resultPanelId = `command-${position}-results`;
      const messagePanelId = `command-${position}-messages`;
      resultsTab.setAttribute('aria-controls', resultPanelId);
      messagesTab.setAttribute('aria-controls', messagePanelId);
      resultPanel.id = resultPanelId;
      messagePanel.id = messagePanelId;
      resultSets.forEach((resultSet, resultNumber) => {
        resultPanel.appendChild(
          renderResultSet(resultSet, resultNumber, resultSets.length)
        );
      });
      renderMetadata(messagePanel, metadata);
      function selectTab(showResults) {
        resultsTab.setAttribute('aria-selected', String(showResults));
        messagesTab.setAttribute('aria-selected', String(!showResults));
        resultPanel.classList.toggle('hidden', !showResults);
        messagePanel.classList.toggle('hidden', showResults);
      }
      resultsTab.addEventListener('click', () => selectTab(true));
      const run = outputRun;
      runtime.explorer.refs.draggable(resultsTab, () => {
        const pages = Array.from(
          resultPanel.querySelectorAll(':scope > .result-set')
        ).map((section) => Number(section.dataset.page) || 0);
        return {
          kind: 'result',
          parentId: `run-${run}-${position}`,
          data: {command, pages}
        };
      });
      messagesTab.addEventListener('click', () => selectTab(false));
      tabList.append(resultsTab, messagesTab);
      group.append(tabList, resultPanel, messagePanel);
      return group;
    }

    function commandTabId(position) {
      return `command-${position}`;
    }

    //  One panel per command, all kept, so a command's Results/Messages
    //  choice and result page survive switching to another and back.
    //  The strip above them is urui's %dynamic level.
    let commandPanels = [];

    function selectCommand(selected) {
      const commands = outputState.commands;
      if (!commands[selected]) return;
      commandPanels.forEach((panel, position) => {
        panel.hidden = position !== selected;
      });
      runtime.panes.select('output-pane', [commandTabId(selected)]);
      outputState.activeCommand = selected;
      outputState.exportable = commandIsExportable(commands[selected]);
      updateOutputControls();
    }

    function renderCommandTabs(commands) {
      const container = document.createElement('div');
      container.className = 'command-tab-set';
      commandPanels = commands.map((command, position) => {
        const panel = document.createElement('div');
        panel.id = `command-tab-panel-${position}`;
        panel.className = 'command-tab-panel';
        panel.setAttribute('role', 'tabpanel');
        panel.appendChild(renderCommand(command, position, false));
        container.appendChild(panel);
        return panel;
      });
      runtime.panes.set('output-pane', 'command',
        commands.map((command, position) => {
          const commandIndex = Number.isInteger(command.index) ?
            command.index + 1 : position + 1;
          return {id: commandTabId(position), label: `Command ${commandIndex}`};
        }));
      outputTabsBand.hidden = false;
      selectCommand(0);
      return container;
    }

    //  A single command, a parse, or an error shows no command strip.
    function clearCommandTabs() {
      commandPanels = [];
      runtime.panes.set('output-pane', 'command', []);
      outputTabsBand.hidden = true;
    }

    function revealOutput() {
      runtime.layout.setResultOpen(true);
      updateOutputControls();
    }

    function showRunOutput(commands, resultId = null) {
      const safeCommands = Array.isArray(commands) ? commands : [];
      const activeCommand = safeCommands.length > 0 ? 0 : null;
      const exportable = activeCommand === null ? false :
        commandIsExportable(safeCommands[activeCommand]);
      outputState = {
        kind: 'run',
        resultId,
        commands: safeCommands,
        activeCommand,
        text: '',
        exportable,
        path: null,
        format: null
      };
      lastOutputText = '';
      outputRun += 1;
      results.replaceChildren();
      clearCommandTabs();
      if (safeCommands.length === 0) {
        const empty = document.createElement('p');
        empty.className = 'empty-state';
        empty.textContent = 'No command results.';
        results.appendChild(empty);
      } else if (safeCommands.length === 1) {
        results.appendChild(renderCommand(safeCommands[0], 0));
      } else {
        results.appendChild(renderCommandTabs(safeCommands));
      }
      revealOutput();
    }

    function showParseOutput(text) {
      const value = String(text || '');
      outputState = {
        kind: 'parse',
        resultId: null,
        commands: [],
        activeCommand: null,
        text: value,
        exportable: value.length > 0,
        path: null,
        format: null
      };
      lastOutputText = value;
      results.replaceChildren();
      clearCommandTabs();
      //  The tab is what drags to the explorer: a draggable <pre> would
      //  lose mouse text selection.
      const heading = document.createElement('div');
      heading.className = 'result-tabs';
      const tab = document.createElement('span');
      tab.className = 'result-tab';
      tab.setAttribute('aria-selected', 'true');
      tab.title = 'Drag to the explorer to keep a reference';
      tab.textContent = 'Parse output';
      heading.appendChild(tab);
      //  parse refs outlive the page, so the id cannot restart per load
      const parentId = `parse-${Date.now().toString(36)}`;
      runtime.explorer.refs.draggable(tab, () => {
        return {kind: 'parse', parentId, data: {text: value}};
      });
      const pre = document.createElement('pre');
      pre.className = 'parse-output';
      pre.textContent = value;
      results.append(heading, pre);
      revealOutput();
    }

    function showErrorOutput(text) {
      const value = String(text || 'Unknown error.');
      outputState = {
        kind: 'error',
        resultId: null,
        commands: [],
        activeCommand: null,
        text: value,
        exportable: false,
        path: null,
        format: null
      };
      lastOutputText = value;
      results.replaceChildren();
      clearCommandTabs();
      const summary = document.createElement('p');
      summary.className = 'error-summary';
      summary.textContent = value.split('\n').find((line) => line.trim()) ||
        'Request failed.';
      const trace = document.createElement('pre');
      trace.className = 'error-pane';
      trace.textContent = value;
      results.append(summary, trace);
      revealOutput();
    }

    function showOutput(text, kind = 'plain') {
      if (kind === 'error') showErrorOutput(text);
      else showParseOutput(text);
    }

    function clearOutput() {
      outputState = {
        kind: 'empty',
        resultId: null,
        commands: [],
        activeCommand: null,
        text: '',
        exportable: false,
        path: null,
        format: null
      };
      lastOutputText = '';
      results.replaceChildren();
      clearCommandTabs();
      updateOutputControls();
    }

    async function execute(operation) {
      if (busy) return;
      const script = selectedScript();
      clearOutput();
      setBusy(true, operation);
      notify(operation === 'run' ? 'Running query…' : 'Parsing query…');
      try {
        const body = await api(operation, {
          defaultDatabase: defaultDatabase.value,
          script
        });
        if (operation === 'parse') {
          showParseOutput(body.text || '');
          notify('Parse complete.');
        } else {
          showRunOutput(body.commands || [], body.resultId ?? null);
          if (body.schemaChanged) {
            schemaValue = null;
            await ensureSchemaLoaded({
              force: true,
              preferNewDatabase: true
            });
          }
          notify('Run complete.');
        }
      } catch (error) {
        showErrorOutput(error instanceof Error ? error.message : String(error));
        notifyError(error);
      } finally {
        setBusy(false);
      }
    }

    async function copyOutput() {
      if (await runtime.copy(outputCopyText())) {
        notify('Results copied.');
      } else {
        notify('Could not copy results.', {kind: 'error', sticky: true});
      }
    }

    function clamp(value, minimum, maximum) {
      return Math.min(maximum, Math.max(minimum, value));
    }

    byId('relation-select').addEventListener('click', () => {
      openRelationAction('SELECT');
    });
    byId('relation-insert').addEventListener('click', () => {
      openRelationAction('INSERT');
    });
    byId('relation-create').addEventListener('click', () => {
      openRelationAction('CREATE');
    });
    runButton.addEventListener('click', () => execute('run'));
    parseButton.addEventListener('click', () => execute('parse'));
    saveOutputButton.addEventListener('click', showSaveResultsDialog);
    copyOutputButton.addEventListener('click', copyOutput);
    defaultDatabase.addEventListener('change', () => {
      state.defaultDatabase = defaultDatabase.value;
      persist();
      ensureSchemaLoaded({force: true});
    });
    //  urui switches views and collapses the explorer; the schema loads
    //  the first time its panel is actually on screen
    new MutationObserver(() => ensureSchemaLoaded()).observe(schemasPanel, {
      attributes: true,
      attributeFilter: ['hidden']
    });
    new MutationObserver(() => ensureSchemaLoaded()).observe(explorerPane, {
      attributes: true,
      attributeFilter: ['class']
    });
    document.addEventListener('click', (event) => {
      if (!event.target.closest('#relation-menu') &&
          !event.target.closest('.relation-actions')) {
        closeRelationMenu();
      }
    });
    //  urui's dialogs and menus close themselves on Escape
    window.addEventListener('keydown', (event) => {
      if (event.key === 'Escape') closeRelationMenu();
    }, true);
    runtime.shortcuts.register('run', () => {
      if (!runButton.disabled) execute('run');
    });

    runtime.wire();
    const saved = runtime.session.load();
    if (saved?.workbench) state = saved.workbench;
    runtime.layout.apply();
    runtime.explorer.docs.render();
    runtime.explorer.refs.render();
    runtime.explorer.setView(runtime.explorer.view());
    runtime.explorer.docs.refreshVariant();
    docs.start();
    editor = docs.editor('script');
    updateOutputControls();
    //  show the saved default before the schema arrives with the rest
    const savedDefault = state.defaultDatabase || 'sys';
    if (!Array.from(defaultDatabase.options).some((option) => {
      return option.value === savedDefault;
    })) {
      defaultDatabase.appendChild(new Option(savedDefault, savedDefault));
    }
    defaultDatabase.value = savedDefault;
    clearCommandTabs();
    setBusy(false);
    ensureSchemaLoaded({always: true});
    document.documentElement.dataset.obelisk = 'ready';

    window.ObeliskWorkbench = {
      api,
      closeDocsTab: runtime.explorer.docs.close,
      execute,
      getState: () => state,
      openRelationAction,
      openDocsTab: runtime.explorer.docs.open,
      persist,
      refreshHelpVariant: runtime.explorer.docs.refreshVariant,
      refreshSchema,
      relationTemplate,
      renderCommand,
      runCopyText,
      runExportText,
      showSaveResultsDialog,
      showOutput,
      showRunOutput
    };

    window.urui.boot({
      onReady: () => {},
      editor: {primary: () => editor},
      panes: {
        get: runtime.panes.get,
        set: runtime.panes.set,
        select: runtime.panes.select,
        panel: runtime.panes.panel,
        reveal: runtime.panes.reveal
      },
      explorer: {
        show: runtime.explorer.setView,
        openDocs: runtime.explorer.docs.open
      },
      dialog: {help: runtime.dialogs.setHelpOpen},
      session: {
        save: runtime.session.save,
        queue: runtime.session.queue,
        get: runtime.session.load
      },
      shortcuts: runtime.shortcuts,
      layout: {
        paneWidth: runtime.layout.paneWidth,
        explorerWidth: runtime.layout.explorerWidth
      }
    });
  })();
  '''
--
