::  Pure state lifecycle helpers for %obelisk-web.
::
/-  web=obelisk-web
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
  ==
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
++  page
  |=  our=@p
  ^-  @t
  %-  crip
  %-  en-xml:html
  ;html(lang "en")
    ;head
      ;meta(charset "utf-8");
      ;meta(name "viewport", content "width=device-width, initial-scale=1");
      ;title: Obelisk
      ;link(rel "stylesheet", href "/apps/obelisk/app.css");
      ;script(src "/apps/obelisk/app.js", defer "");
    ==
    ;body
      ;div#obelisk-app.app-shell
        ;header#app-header.app-header
          ;a.brand(href "/apps/obelisk", aria-label "Obelisk home")
            Obelisk
          ==
          ;nav.toolbar(aria-label "Obelisk workbench controls")
            ;div#file-menu.menu(data-open "false")
              ;button#file-menu-toggle.menu-toggle
                =type  "button"
                =aria-haspopup  "menu"
                =aria-expanded  "false"
                File
              ==
              ;div#file-menu-panel.menu-panel.hidden(role "menu")
                ;button#new-tab-menu-item(type "button", role "menuitem")
                  New
                ==
                ;button#open-menu-item(type "button", role "menuitem")
                  Open...
                ==
                ;button#save-tab-menu-item(type "button", role "menuitem")
                  Save
                ==
                ;button#save-as-menu-item(type "button", role "menuitem")
                  Save As...
                ==
                ;button#close-tab-menu-item(type "button", role "menuitem")
                  Close
                ==
              ==
            ==
            ;button#run-btn.primary(type "button", title "Run (F5)")
              ;span: Run
              ;kbd: F5
            ==
            ;button#parse-btn(type "button"): Parse
            ;button#save-results-btn
              =type  "button"
              =disabled  ""
              =aria-disabled  "true"
              Save Results
            ==
            ;a.doc-link
              =href
                "https://github.com/jackfoxy/obelisk/tree/master/".
                "desk/doc/usr/reference/"
              =target  "_blank"
              =rel  "noopener noreferrer"
              Reference
            ==
            ;a.doc-link
              =href
                "https://github.com/jackfoxy/obelisk/blob/master/".
                "desk/doc/usr/users-guide.md"
              =target  "_blank"
              =rel  "noopener noreferrer"
              Users Guide
            ==
            ;a.doc-link
              =href
                "https://github.com/jackfoxy/obelisk/blob/master/roadmap.md"
              =target  "_blank"
              =rel  "noopener noreferrer"
              Roadmap
            ==
            ;div.default-database
              ;label(for "default-db"): Default DB
              ;select#default-db(name "default-db")
                ;option(value "sys"): sys
              ==
            ==
            ;div#dev-menu.menu(data-open "false")
              ;button#dev-menu-toggle.menu-toggle
                =type  "button"
                =aria-haspopup  "menu"
                =aria-expanded  "false"
                For Developers
              ==
              ;div#dev-menu-panel.menu-panel.menu-panel-right.hidden
                =role  "menu"
                ;a
                  =href
                    "https://github.com/jackfoxy/obelisk/blob/master/".
                    "desk/sur/obelisk-ast.hoon"
                  =target  "_blank"
                  =rel  "noopener noreferrer"
                  =role  "menuitem"
                  API/AST
                ==
                ;a
                  =href
                    "https://github.com/jackfoxy/obelisk/tree/master/".
                    ".claude/skills/obelisk-urql"
                  =target  "_blank"
                  =rel  "noopener noreferrer"
                  =role  "menuitem"
                  urQL
                ==
                ;a
                  =href
                    "https://github.com/jackfoxy/obelisk/blob/master/".
                    "desk/doc/dev/users-guide-script.txt"
                  =target  "_blank"
                  =rel  "noopener noreferrer"
                  =role  "menuitem"
                  Sample urQL
                ==
                ;a
                  =href
                    "https://github.com/jackfoxy/obelisk/blob/master/".
                    "desk/doc/dev/performance.md"
                  =target  "_blank"
                  =rel  "noopener noreferrer"
                  =role  "menuitem"
                  Benchmarks
                ==
              ==
            ==
          ==
        ==
        ;main#workbench.workbench
          ;aside#schema-pane.schema-pane
            =aria-labelledby  "schema-heading"
            ;div.pane-header
              ;div
                ;h1#schema-heading: Schemas
                ;span#local-ship.ship: {(trip (scot %p our))}
              ==
              ;button#schema-collapse.icon-button
                =type  "button"
                =aria-label  "Collapse schemas"
                =aria-expanded  "true"
                ‹
              ==
            ==
            ;div#schema-tree.schema-tree
              =role  "tree"
              =aria-label  "Database schemas"
              =aria-busy  "true"
              ;p.empty-state: Loading schemas…
            ==
          ==
          ;button#schema-resizer.splitter
            =type  "button"
            =aria-label  "Resize schemas"
            ;span.visually-hidden: Resize schemas
          ==
          ;section#workspace.workspace(aria-label "Query workspace")
            ;section#editor-pane.editor-pane
              =aria-labelledby  "editor-heading"
              ;h2#editor-heading.visually-hidden: Query editor
              ;div.editor-tabs(role "tablist", aria-label "Query tabs")
                ;button#tab-script-1.tab.active
                  =type  "button"
                  =role  "tab"
                  =aria-selected  "true"
                  =aria-controls  "query-editor"
                  script-1
                ==
                ;button#new-tab-btn.new-tab
                  =type  "button"
                  =aria-label  "New query tab"
                  +
                ==
              ==
              ;div.editor-toolbar
                ;span: urQL
                ;button#copy-query-btn.icon-button
                  =type  "button"
                  =aria-label  "Copy query"
                  Copy
                ==
              ==
              ;textarea#query-editor.query-editor
                =aria-label  "urQL query"
                =spellcheck  "false"
                =placeholder  "Enter urQL here…"
                ""
              ==
            ==
            ;button#output-resizer.splitter.horizontal
              =type  "button"
              =aria-label  "Resize output"
              ;span.visually-hidden: Resize output
            ==
            ;section#output-pane.output-pane
              =aria-labelledby  "output-heading"
              ;div.pane-header
                ;h2#output-heading: Output
                ;div.pane-actions
                  ;button#copy-output-btn.icon-button
                    =type  "button"
                    =aria-label  "Copy output"
                    Copy
                  ==
                  ;button#output-collapse.icon-button
                    =type  "button"
                    =aria-label  "Collapse output"
                    =aria-expanded  "true"
                    ⌄
                  ==
                ==
              ==
              ;div#results.results
                =role  "region"
                =aria-live  "polite"
                =aria-label  "Query results"
                ;p.empty-state: No results yet
              ==
            ==
          ==
        ==
      ==
    ==
  ==
::
++  css
  ^-  @t
  '''
  :root {
    color-scheme: light;
    --bg: #f7f7f4;
    --surface: #ffffff;
    --surface-alt: #f0f0eb;
    --text: #181817;
    --muted: #66665f;
    --border: #d4d4cc;
    --accent: #6d28d9;
    --accent-text: #ffffff;
    --focus: #2563eb;
    font-family: Inter, ui-sans-serif, system-ui, sans-serif;
    font-size: 15px;
  }

  html, body {
    height: 100%;
    margin: 0;
  }

  * {
    box-sizing: border-box;
  }

  body {
    background: var(--bg);
    color: var(--text);
    overflow: hidden;
  }

  button, select, textarea {
    color: inherit;
    font: inherit;
  }

  button, select {
    background: var(--surface);
    border: 1px solid var(--border);
    border-radius: 0.3rem;
    min-height: 2rem;
  }

  button, select, a {
    touch-action: manipulation;
  }

  button:not(:disabled), select, a {
    cursor: pointer;
  }

  button:hover:not(:disabled), a:hover {
    background: var(--surface-alt);
  }

  button:focus-visible, select:focus-visible, textarea:focus-visible,
  a:focus-visible, [role="separator"]:focus-visible {
    outline: 2px solid var(--focus);
    outline-offset: 2px;
  }

  button:disabled {
    cursor: not-allowed;
    opacity: 0.45;
  }

  a {
    border-radius: 0.2rem;
    color: inherit;
  }

  #obelisk-app {
    display: grid;
    grid-template-rows: auto minmax(0, 1fr);
    height: 100%;
  }

  .app-header {
    align-items: center;
    background: var(--surface);
    border-bottom: 1px solid var(--border);
    display: flex;
    gap: 1rem;
    min-height: 3.25rem;
    padding: 0.55rem 0.8rem;
    position: relative;
    z-index: 20;
  }

  .brand {
    font-size: 1.05rem;
    font-weight: 700;
    text-decoration: none;
  }

  .toolbar {
    align-items: center;
    display: flex;
    flex: 1;
    flex-wrap: wrap;
    gap: 0.45rem;
  }

  .toolbar button, .toolbar select {
    padding: 0.3rem 0.65rem;
  }

  .toolbar .primary {
    background: var(--accent);
    border-color: var(--accent);
    color: var(--accent-text);
  }

  .toolbar kbd {
    font-family: ui-monospace, monospace;
    font-size: 0.72rem;
    margin-left: 0.35rem;
    opacity: 0.8;
  }

  .doc-link {
    padding: 0.35rem 0.2rem;
  }

  .default-database {
    align-items: center;
    display: flex;
    gap: 0.35rem;
    margin-left: auto;
  }

  .default-database label {
    color: var(--muted);
    font-size: 0.8rem;
    white-space: nowrap;
  }

  .menu {
    position: relative;
  }

  .menu-panel {
    background: var(--surface);
    border: 1px solid var(--border);
    border-radius: 0.4rem;
    box-shadow: 0 0.7rem 2rem rgb(0 0 0 / 0.16);
    display: grid;
    left: 0;
    min-width: 12rem;
    padding: 0.3rem;
    position: absolute;
    top: calc(100% + 0.35rem);
    z-index: 30;
  }

  .menu-panel-right {
    left: auto;
    right: 0;
  }

  .menu-panel button, .menu-panel a {
    background: transparent;
    border: 0;
    display: block;
    min-height: 2rem;
    padding: 0.45rem 0.55rem;
    text-align: left;
    text-decoration: none;
  }

  .hidden {
    display: none !important;
  }

  .workbench {
    display: grid;
    grid-template-columns: minmax(14rem, 22rem) 0.35rem minmax(0, 1fr);
    min-height: 0;
  }

  .schema-pane, .editor-pane, .output-pane {
    background: var(--surface);
    min-height: 0;
    min-width: 0;
  }

  .schema-pane {
    display: grid;
    grid-template-rows: auto minmax(0, 1fr);
  }

  .pane-header {
    align-items: center;
    border-bottom: 1px solid var(--border);
    display: flex;
    justify-content: space-between;
    min-height: 3rem;
    padding: 0.55rem 0.75rem;
  }

  .pane-header h1, .pane-header h2 {
    font-size: 0.95rem;
    margin: 0;
  }

  .ship {
    color: var(--muted);
    display: block;
    font-family: ui-monospace, monospace;
    font-size: 0.78rem;
    margin-top: 0.15rem;
  }

  .schema-tree, .results {
    overflow: auto;
    padding: 0.75rem;
  }

  .splitter {
    background: var(--border);
    border: 0;
    border-radius: 0;
    cursor: col-resize;
    min-height: 0.35rem;
    min-width: 0.35rem;
    padding: 0;
  }

  .splitter:hover, .splitter:focus {
    background: var(--accent);
  }

  .splitter.horizontal {
    cursor: row-resize;
  }

  .workspace {
    display: grid;
    grid-template-rows: minmax(12rem, 3fr) 0.35rem minmax(9rem, 2fr);
    min-height: 0;
    min-width: 0;
  }

  .editor-pane {
    display: grid;
    grid-template-rows: auto auto minmax(0, 1fr);
  }

  .editor-tabs {
    align-items: end;
    background: var(--surface-alt);
    border-bottom: 1px solid var(--border);
    display: flex;
    min-height: 2.65rem;
    padding: 0.35rem 0.5rem 0;
  }

  .editor-tabs button {
    border-bottom-left-radius: 0;
    border-bottom-right-radius: 0;
    margin-right: 0.25rem;
  }

  .editor-tabs .active {
    background: var(--surface);
    border-bottom-color: var(--surface);
    font-weight: 600;
  }

  .editor-toolbar {
    align-items: center;
    border-bottom: 1px solid var(--border);
    color: var(--muted);
    display: flex;
    font-size: 0.8rem;
    justify-content: space-between;
    min-height: 2.4rem;
    padding: 0.35rem 0.65rem;
  }

  .icon-button {
    min-height: 1.8rem;
    padding: 0.2rem 0.5rem;
  }

  .query-editor {
    background: var(--surface);
    border: 0;
    color: var(--text);
    font: 0.95rem/1.55 ui-monospace, monospace;
    min-height: 0;
    outline-offset: -2px;
    padding: 1rem;
    resize: none;
    tab-size: 2;
    width: 100%;
  }

  .output-pane {
    display: grid;
    grid-template-rows: auto minmax(0, 1fr);
  }

  .pane-actions {
    display: flex;
    gap: 0.35rem;
  }

  .empty-state {
    color: var(--muted);
    margin: 0;
  }

  .visually-hidden {
    clip: rect(0 0 0 0);
    clip-path: inset(50%);
    height: 1px;
    overflow: hidden;
    position: absolute;
    white-space: nowrap;
    width: 1px;
  }

  @media (prefers-color-scheme: dark) {
    :root {
      color-scheme: dark;
      --bg: #11110f;
      --surface: #191917;
      --surface-alt: #22221f;
      --text: #f2f2ec;
      --muted: #a7a79e;
      --border: #3b3b35;
      --accent: #8b5cf6;
      --accent-text: #ffffff;
      --focus: #60a5fa;
    }
  }

  @media (max-width: 760px) {
    body {
      overflow: auto;
    }

    #obelisk-app {
      height: auto;
      min-height: 100%;
    }

    .app-header {
      align-items: flex-start;
    }

    .toolbar {
      align-items: stretch;
    }

    .default-database {
      margin-left: 0;
    }

    .workbench {
      grid-template-columns: minmax(0, 1fr);
      grid-template-rows: minmax(10rem, 28vh) 0.35rem minmax(32rem, 1fr);
    }

    .splitter {
      cursor: row-resize;
    }

    .workspace {
      min-height: 32rem;
    }
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
  ^-  @t
  '''
  document.documentElement.dataset.obelisk = 'ready';
  '''
--
