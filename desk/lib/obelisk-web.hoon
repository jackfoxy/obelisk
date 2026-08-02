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
            =role  "separator"
            =aria-orientation  "vertical"
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
                ;*  ~[;/("")]
              ==
            ==
            ;button#output-resizer.splitter.horizontal
              =type  "button"
              =role  "separator"
              =aria-orientation  "horizontal"
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
        ;div#app-status.status.hidden
          =role  "status"
          =aria-live  "polite"
          ;*  ~[;/("")]
        ==
        ;dialog#file-dialog.file-dialog
          =aria-labelledby  "file-dialog-title"
          ;form#file-dialog-form(method "dialog")
            ;h2#file-dialog-title: Open script
            ;p#file-dialog-help.dialog-help
              Choose a saved script.
            ==
            ;div#file-dialog-list.file-dialog-list
              =role  "tree"
              =aria-label  "Saved scripts"
              ;*  ~[;/("")]
            ==
            ;label#file-path-label.hidden(for "file-path-input")
              Script path
            ==
            ;input#file-path-input.hidden(placeholder "folder/script-name");
            ;fieldset#results-delimiter-fields.hidden
              ;legend: Delimiter
              ;label
                ;input
                  =type  "radio"
                  =name  "results-delimiter"
                  =value  "comma"
                  =checked  "";
                Comma
              ==
              ;label
                ;input
                  =type  "radio"
                  =name  "results-delimiter"
                  =value  "space";
                Space
              ==
              ;label
                ;input
                  =type  "radio"
                  =name  "results-delimiter"
                  =value  "tab";
                Tab
              ==
            ==
            ;div.dialog-actions
              ;button#file-dialog-cancel(type "button"): Cancel
              ;button#file-dialog-confirm.primary(type "submit"): Open
            ==
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

  .status {
    background: var(--surface);
    border: 1px solid var(--border);
    border-left: 0.3rem solid var(--accent);
    border-radius: 0.35rem;
    bottom: 1rem;
    box-shadow: 0 0.5rem 1.5rem rgb(0 0 0 / 0.18);
    max-width: min(32rem, calc(100vw - 2rem));
    padding: 0.65rem 0.8rem;
    position: fixed;
    right: 1rem;
    white-space: pre-wrap;
    z-index: 50;
  }

  .status[data-kind="error"] {
    border-left-color: #dc2626;
  }

  .file-dialog {
    background: var(--surface);
    border: 1px solid var(--border);
    border-radius: 0.55rem;
    color: var(--text);
    max-width: min(34rem, calc(100vw - 2rem));
    padding: 0;
    width: 30rem;
  }

  .file-dialog::backdrop {
    background: rgb(0 0 0 / 0.38);
  }

  .file-dialog form {
    display: grid;
    gap: 0.8rem;
    padding: 1rem;
  }

  .file-dialog h2, .dialog-help {
    margin: 0;
  }

  .dialog-help {
    color: var(--muted);
    font-size: 0.86rem;
  }

  .file-dialog-list {
    border: 1px solid var(--border);
    border-radius: 0.35rem;
    display: grid;
    max-height: 22rem;
    min-height: 8rem;
    overflow: auto;
    padding: 0.3rem;
  }

  .file-entry {
    align-items: center;
    background: transparent;
    border: 0;
    display: flex;
    font-family: ui-monospace, monospace;
    gap: 0.45rem;
    min-height: 2rem;
    text-align: left;
    width: 100%;
  }

  .file-entry.directory {
    color: var(--muted);
    cursor: default;
  }

  #file-path-input {
    background: var(--surface);
    border: 1px solid var(--border);
    border-radius: 0.3rem;
    color: var(--text);
    min-height: 2.25rem;
    padding: 0.4rem 0.55rem;
    width: 100%;
  }

  #results-delimiter-fields {
    border: 1px solid var(--border);
    border-radius: 0.35rem;
    display: flex;
    gap: 1rem;
    margin: 0;
    padding: 0.55rem 0.7rem 0.65rem;
  }

  #results-delimiter-fields legend {
    color: var(--muted);
    font-size: 0.8rem;
    padding: 0 0.25rem;
  }

  #results-delimiter-fields label {
    align-items: center;
    display: flex;
    gap: 0.3rem;
  }

  .dialog-actions {
    display: flex;
    gap: 0.45rem;
    justify-content: flex-end;
  }

  .dialog-actions button {
    padding: 0.35rem 0.75rem;
  }

  .dialog-actions .primary {
    background: var(--accent);
    border-color: var(--accent);
    color: var(--accent-text);
  }

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

  .schema-pane.collapsed .pane-header > div,
  .schema-pane.collapsed .schema-tree {
    display: none;
  }

  .schema-pane.collapsed .pane-header {
    justify-content: center;
    padding: 0.4rem;
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

  .schema-node {
    margin: 0.1rem 0;
  }

  .schema-node > summary {
    align-items: center;
    border-radius: 0.25rem;
    cursor: pointer;
    display: flex;
    gap: 0.35rem;
    min-height: 1.9rem;
    padding: 0.15rem 0.25rem;
  }

  .schema-node > summary:hover {
    background: var(--surface-alt);
  }

  .schema-children {
    border-left: 1px solid var(--border);
    margin-left: 0.7rem;
    padding-left: 0.65rem;
  }

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

  .relation-actions {
    margin-left: auto;
    min-height: 1.55rem;
    padding: 0 0.45rem;
  }

  .schema-column {
    align-items: center;
    display: grid;
    gap: 0.35rem;
    grid-template-columns: 1.5rem 3.5rem minmax(0, 1fr);
    min-height: 1.75rem;
    padding: 0.1rem 0.25rem;
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

  .output-pane.collapsed .results {
    display: none;
  }

  .pane-actions {
    display: flex;
    gap: 0.35rem;
  }

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

  .error-pane {
    color: #b91c1c;
  }

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

  .result-tab[aria-selected="true"] {
    background: var(--surface);
    border-bottom-color: var(--surface);
    font-weight: 600;
  }

  .command-panel, .command-metadata {
    padding: 0.65rem;
  }

  .result-set + .result-set {
    margin-top: 1rem;
  }

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
    margin-top: 0.45rem;
  }

  .result-pager-status {
    color: var(--muted);
    margin-right: auto;
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

  .metadata-row dt {
    color: var(--muted);
  }

  .metadata-row dd {
    font-family: ui-monospace, monospace;
    margin: 0;
    overflow-wrap: anywhere;
    white-space: pre-wrap;
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
  (() => {
    'use strict';

    const storageKey = 'obelisk.workbench.v1';
    const byId = (id) => document.getElementById(id);
    const app = byId('obelisk-app');
    const workbench = byId('workbench');
    const workspace = byId('workspace');
    const schemaPane = byId('schema-pane');
    const schemaResizer = byId('schema-resizer');
    const schemaCollapse = byId('schema-collapse');
    const outputPane = byId('output-pane');
    const outputResizer = byId('output-resizer');
    const outputCollapse = byId('output-collapse');
    const editor = byId('query-editor');
    const tabsElement = document.querySelector('.editor-tabs');
    const newTabButton = byId('new-tab-btn');
    const runButton = byId('run-btn');
    const parseButton = byId('parse-btn');
    const copyQueryButton = byId('copy-query-btn');
    const copyOutputButton = byId('copy-output-btn');
    const saveResultsButton = byId('save-results-btn');
    const defaultDatabase = byId('default-db');
    const schemaTree = byId('schema-tree');
    const results = byId('results');
    const status = byId('app-status');
    const fileDialog = byId('file-dialog');
    const fileDialogForm = byId('file-dialog-form');
    const fileDialogTitle = byId('file-dialog-title');
    const fileDialogHelp = byId('file-dialog-help');
    const fileDialogList = byId('file-dialog-list');
    const filePathLabel = byId('file-path-label');
    const filePathInput = byId('file-path-input');
    const resultsDelimiterFields = byId('results-delimiter-fields');
    const fileDialogConfirm = byId('file-dialog-confirm');
    const relationMenu = byId('relation-menu');
    let statusTimer = 0;
    let lastOutputText = '';
    let outputState = {
      kind: 'empty',
      commands: [],
      text: '',
      exportable: false
    };
    let busy = false;
    let fileDialogMode = 'open';
    let selectedFilePath = null;
    let fileEntries = [];
    let schemaValue = null;
    let relationContext = null;

    function initialState() {
      return {
        version: 1,
        tabs: [{
          id: 'draft-1',
          name: 'script-1',
          path: null,
          text: '',
          savedText: null,
          selectionStart: 0,
          selectionEnd: 0
        }],
        activeId: 'draft-1',
        nextDraft: 2,
        nextFile: 1,
        schemaSize: 320,
        outputSize: 260,
        schemaOpen: true,
        outputOpen: true,
        defaultDatabase: 'sys',
        schemaExpanded: [],
        schemaDatabaseNames: []
      };
    }

    function validTab(tab) {
      return tab && typeof tab.id === 'string' &&
        typeof tab.name === 'string' && typeof tab.text === 'string' &&
        Number.isInteger(tab.selectionStart) &&
        Number.isInteger(tab.selectionEnd) &&
        (tab.savedText === null || typeof tab.savedText === 'string' ||
          typeof tab.savedText === 'undefined') &&
        (tab.path === null || Array.isArray(tab.path));
    }

    function loadState() {
      try {
        const saved = JSON.parse(sessionStorage.getItem(storageKey));
        if (!saved || saved.version !== 1 || !Array.isArray(saved.tabs) ||
            saved.tabs.length === 0 || !saved.tabs.every(validTab)) {
          return initialState();
        }
        if (!saved.tabs.some((tab) => tab.id === saved.activeId)) {
          saved.activeId = saved.tabs[0].id;
        }
        const base = initialState();
        const restored = Object.assign(base, saved);
        restored.tabs.forEach((tab) => {
          if (typeof tab.savedText === 'undefined') {
            tab.savedText = tab.path ? tab.text : null;
          }
        });
        if (!Array.isArray(restored.schemaExpanded)) {
          restored.schemaExpanded = [];
        }
        if (!Array.isArray(restored.schemaDatabaseNames)) {
          restored.schemaDatabaseNames = [];
        }
        return restored;
      } catch (_) {
        return initialState();
      }
    }

    let state = loadState();

    function persist() {
      try {
        sessionStorage.setItem(storageKey, JSON.stringify(state));
      } catch (_) {
        setStatus('Session state could not be saved.', 'error', true);
      }
    }

    function activeTab() {
      return state.tabs.find((tab) => tab.id === state.activeId) ||
        state.tabs[0];
    }

    function captureEditor() {
      const tab = activeTab();
      tab.text = editor.value;
      tab.selectionStart = editor.selectionStart;
      tab.selectionEnd = editor.selectionEnd;
    }

    function restoreEditor(focus) {
      const tab = activeTab();
      editor.value = tab.text;
      const start = Math.min(tab.selectionStart, tab.text.length);
      const end = Math.min(tab.selectionEnd, tab.text.length);
      requestAnimationFrame(() => {
        editor.setSelectionRange(start, end);
        if (focus) editor.focus();
      });
    }

    function renderTabs() {
      tabsElement.querySelectorAll('[role="tab"]').forEach((tab) => {
        tab.remove();
      });
      state.tabs.forEach((tab) => {
        const button = document.createElement('button');
        const selected = tab.id === state.activeId;
        button.type = 'button';
        button.id = `tab-${tab.id}`;
        button.className = selected ? 'tab active' : 'tab';
        button.setAttribute('role', 'tab');
        button.setAttribute('aria-selected', String(selected));
        button.setAttribute('aria-controls', 'query-editor');
        button.tabIndex = selected ? 0 : -1;
        button.dataset.tabId = tab.id;
        const dirty = tab.savedText !== null && tab.text !== tab.savedText;
        button.textContent = `${tab.name}${dirty ? ' •' : ''}`;
        button.title = tab.path ? tab.path.join('/') : tab.name;
        button.addEventListener('click', () => activateTab(tab.id, true));
        button.addEventListener('keydown', tabKeydown);
        tabsElement.insertBefore(button, newTabButton);
      });
    }

    function tabKeydown(event) {
      const current = state.tabs.findIndex((tab) => {
        return tab.id === event.currentTarget.dataset.tabId;
      });
      let next = current;
      if (event.key === 'ArrowRight') next = (current + 1) % state.tabs.length;
      if (event.key === 'ArrowLeft') {
        next = (current + state.tabs.length - 1) % state.tabs.length;
      }
      if (event.key === 'Home') next = 0;
      if (event.key === 'End') next = state.tabs.length - 1;
      if (next === current) return;
      event.preventDefault();
      activateTab(state.tabs[next].id, false);
      byId(`tab-${state.tabs[next].id}`).focus();
    }

    function activateTab(id, focusEditor) {
      if (id === state.activeId) {
        if (focusEditor) editor.focus();
        return;
      }
      captureEditor();
      state.activeId = id;
      renderTabs();
      restoreEditor(focusEditor);
      persist();
    }

    function nextDraftName() {
      let name;
      do {
        name = `script-${state.nextDraft}`;
        state.nextDraft += 1;
      } while (state.tabs.some((tab) => tab.name === name));
      return name;
    }

    function uniqueTabName(candidate, exceptId = null) {
      const used = new Set(state.tabs
        .filter((tab) => tab.id !== exceptId)
        .map((tab) => tab.name));
      if (!used.has(candidate)) return candidate;
      let suffix = 2;
      while (used.has(`${candidate} (${suffix})`)) suffix += 1;
      return `${candidate} (${suffix})`;
    }

    function addDraft(text = '') {
      captureEditor();
      const name = nextDraftName();
      const tab = {
        id: `draft-${state.nextDraft - 1}`,
        name,
        path: null,
        text,
        savedText: null,
        selectionStart: 0,
        selectionEnd: 0
      };
      state.tabs.push(tab);
      state.activeId = tab.id;
      renderTabs();
      restoreEditor(true);
      persist();
      closeMenus();
      return tab;
    }

    function pathKey(path) {
      return path.join('/');
    }

    function addFileTab(path, text) {
      const key = pathKey(path);
      const existing = state.tabs.find((tab) => {
        return tab.path && pathKey(tab.path) === key;
      });
      if (existing) {
        activateTab(existing.id, true);
        return existing;
      }
      captureEditor();
      const leaf = path[path.length - 1] || 'script';
      const tab = {
        id: `file-${state.nextFile++}`,
        name: uniqueTabName(leaf),
        path: path.slice(),
        text,
        savedText: text,
        selectionStart: 0,
        selectionEnd: 0
      };
      state.tabs.push(tab);
      state.activeId = tab.id;
      renderTabs();
      restoreEditor(true);
      persist();
      return tab;
    }

    function closeActiveTab() {
      captureEditor();
      const index = state.tabs.findIndex((tab) => tab.id === state.activeId);
      state.tabs.splice(index, 1);
      if (state.tabs.length === 0) {
        const name = nextDraftName();
        state.tabs.push({
          id: `draft-${state.nextDraft - 1}`,
          name,
          path: null,
          text: '',
          savedText: null,
          selectionStart: 0,
          selectionEnd: 0
        });
      }
      const next = Math.min(index, state.tabs.length - 1);
      state.activeId = state.tabs[next].id;
      renderTabs();
      restoreEditor(true);
      persist();
      closeMenus();
    }

    function setStatus(message, kind = 'info', sticky = false) {
      clearTimeout(statusTimer);
      status.textContent = message;
      status.dataset.kind = kind;
      status.classList.remove('hidden');
      if (!sticky) {
        statusTimer = window.setTimeout(() => {
          status.classList.add('hidden');
        }, 3500);
      }
    }

    function updateOutputControls() {
      copyOutputButton.disabled = lastOutputText.length === 0;
      saveResultsButton.disabled = busy || !outputState.exportable;
      saveResultsButton.setAttribute(
        'aria-disabled',
        String(saveResultsButton.disabled)
      );
    }

    function setBusy(value, label = '') {
      busy = value;
      app.setAttribute('aria-busy', String(value));
      results.setAttribute('aria-busy', String(value));
      runButton.disabled = value;
      parseButton.disabled = value;
      byId('open-menu-item').disabled = value;
      byId('save-tab-menu-item').disabled = value;
      byId('save-as-menu-item').disabled = value;
      byId('new-tab-menu-item').disabled = value;
      byId('close-tab-menu-item').disabled = value;
      runButton.firstElementChild.textContent = value && label === 'run' ?
        'Running…' : 'Run';
      parseButton.textContent = value && label === 'parse' ?
        'Parsing…' : 'Parse';
      updateOutputControls();
      if (fileDialog.open) {
        fileDialogConfirm.disabled = value ||
          (fileDialogMode === 'open' && !selectedFilePath);
      }
    }

    function errorMessage(body, fallback) {
      if (!body || body.type !== 'error' || !body.error) return fallback;
      const details = Array.isArray(body.error.details) ?
        body.error.details.join('\n') : '';
      return details ? `${body.error.message}\n${details}` :
        body.error.message;
    }

    async function api(operation, payload) {
      const route = {
        'file-browse': 'files/browse',
        'file-load': 'files/load',
        'file-save': 'files/save'
      }[operation] || operation;
      const response = await fetch(`/apps/obelisk/api/${route}`, {
        method: 'POST',
        credentials: 'same-origin',
        headers: {'content-type': 'application/json'},
        body: JSON.stringify(Object.assign({type: operation}, payload))
      });
      let body = null;
      try {
        body = await response.json();
      } catch (_) {
        throw new Error(`Server returned invalid JSON (${response.status}).`);
      }
      if (!response.ok || body.type === 'error') {
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

    function relativePathFromInput(value, root) {
      const parts = String(value || '').split('/').map((part) => {
        return part.trim();
      });
      if (parts[0] === root) parts.shift();
      const valid = parts.length > 0 && parts.every((part) => {
        return /^[a-z][a-z0-9-]*$/.test(part);
      });
      return valid ? [root, ...parts] : null;
    }

    function scriptPathFromInput(value) {
      return relativePathFromInput(value, 'scripts');
    }

    function resultPathFromInput(value) {
      return relativePathFromInput(value, 'results');
    }

    function displayScriptPath(path) {
      return path[0] === 'scripts' ? path.slice(1).join('/') :
        path.join('/');
    }

    function suggestScriptPath(tab) {
      if (tab.path) return displayScriptPath(tab.path);
      return tab.name.replace(/\s+\(\d+\)$/, '');
    }

    function closeFileDialog() {
      if (fileDialog.open) fileDialog.close();
      selectedFilePath = null;
      resultsDelimiterFields.classList.add('hidden');
    }

    function renderFileEntries() {
      fileDialogList.replaceChildren();
      const entries = fileEntries.filter((entry) => {
        return Array.isArray(entry.path) && entry.path[0] === 'scripts';
      });
      if (entries.length === 0) {
        const empty = document.createElement('p');
        empty.className = 'empty-state';
        empty.textContent = 'No saved scripts.';
        fileDialogList.appendChild(empty);
        return;
      }
      entries.forEach((entry) => {
        const button = document.createElement('button');
        const directory = entry.kind === 'directory';
        button.type = 'button';
        button.className = directory ? 'file-entry directory' :
          'file-entry';
        button.setAttribute('role', 'treeitem');
        button.style.paddingLeft =
          `${Math.max(0, entry.path.length - 2) * 1.1 + 0.35}rem`;
        button.textContent = `${directory ? '▸' : '•'} ` +
          entry.path[entry.path.length - 1];
        if (directory) {
          button.disabled = true;
        } else {
          button.addEventListener('click', () => {
            selectedFilePath = entry.path.slice();
            fileDialogList.querySelectorAll('.file-entry').forEach((node) => {
              node.setAttribute('aria-selected', 'false');
            });
            button.setAttribute('aria-selected', 'true');
            fileDialogConfirm.disabled = false;
          });
          button.addEventListener('dblclick', () => {
            selectedFilePath = entry.path.slice();
            openSelectedFile();
          });
        }
        fileDialogList.appendChild(button);
      });
    }

    async function showOpenDialog() {
      if (busy) return;
      closeMenus();
      fileDialogMode = 'open';
      selectedFilePath = null;
      fileDialogTitle.textContent = 'Open script';
      fileDialogHelp.textContent = 'Choose a saved script.';
      fileDialogList.classList.remove('hidden');
      filePathLabel.classList.add('hidden');
      filePathInput.classList.add('hidden');
      resultsDelimiterFields.classList.add('hidden');
      fileDialogConfirm.textContent = 'Open';
      fileDialogConfirm.disabled = true;
      fileDialog.showModal();
      setBusy(true, 'browse');
      try {
        const body = await api('file-browse', {path: ['scripts']});
        fileEntries = Array.isArray(body.entries) ? body.entries : [];
        renderFileEntries();
      } catch (error) {
        closeFileDialog();
        setStatus(error.message, 'error', true);
      } finally {
        setBusy(false);
      }
    }

    function showSaveAsDialog() {
      if (busy) return;
      closeMenus();
      fileDialogMode = 'save-as';
      selectedFilePath = null;
      fileDialogTitle.textContent = 'Save script as';
      fileDialogHelp.textContent =
        'Use lower-case letters, digits, and hyphens in each path part.';
      fileDialogList.classList.add('hidden');
      filePathLabel.classList.remove('hidden');
      filePathLabel.textContent = 'Script path';
      filePathInput.classList.remove('hidden');
      resultsDelimiterFields.classList.add('hidden');
      filePathInput.value = suggestScriptPath(activeTab());
      fileDialogConfirm.textContent = 'Save';
      fileDialogConfirm.disabled = false;
      fileDialog.showModal();
      filePathInput.focus();
      filePathInput.select();
    }

    function nextResultName(entries) {
      const names = new Set(entries.filter((entry) => {
        return Array.isArray(entry.path) && entry.path.length === 2 &&
          entry.path[0] === 'results';
      }).map((entry) => entry.path[1]));
      let number = 1;
      while (names.has(`results-${number}`)) number += 1;
      return `results-${number}`;
    }

    async function showSaveResultsDialog() {
      if (busy || !outputState.exportable) return;
      closeMenus();
      setBusy(true, 'browse');
      let entries = [];
      try {
        const body = await api('file-browse', {path: ['results']});
        entries = Array.isArray(body.entries) ? body.entries : [];
      } catch (error) {
        setStatus(error.message, 'error', true);
        return;
      } finally {
        setBusy(false);
      }
      fileDialogMode = 'save-results';
      selectedFilePath = null;
      fileDialogTitle.textContent = 'Save results';
      fileDialogHelp.textContent =
        'Save under results using lower-case letters, digits, and hyphens.';
      fileDialogList.classList.add('hidden');
      filePathLabel.classList.remove('hidden');
      filePathLabel.textContent = 'Result path';
      filePathInput.classList.remove('hidden');
      filePathInput.value = nextResultName(entries);
      const showDelimiter = outputState.kind === 'run';
      resultsDelimiterFields.classList.toggle('hidden', !showDelimiter);
      const comma = resultsDelimiterFields.querySelector('[value="comma"]');
      comma.checked = true;
      fileDialogConfirm.textContent = 'Save';
      fileDialogConfirm.disabled = false;
      fileDialog.showModal();
      filePathInput.focus();
      filePathInput.select();
    }

    async function openSelectedFile() {
      if (busy || !selectedFilePath) return;
      const path = selectedFilePath.slice();
      const existing = state.tabs.find((tab) => {
        return tab.path && pathKey(tab.path) === pathKey(path);
      });
      if (existing) {
        closeFileDialog();
        activateTab(existing.id, true);
        setStatus(`${displayScriptPath(path)} is already open.`);
        return;
      }
      setBusy(true, 'open');
      try {
        const body = await api('file-load', {path});
        addFileTab(body.path, body.content);
        closeFileDialog();
        setStatus(`${displayScriptPath(body.path)} opened.`);
      } catch (error) {
        setStatus(error.message, 'error', true);
      } finally {
        setBusy(false);
      }
    }

    async function saveTab(tab, path, overwrite) {
      if (busy) return false;
      captureEditor();
      const content = tab.text;
      setBusy(true, 'save');
      try {
        const body = await api('file-save', {path, content, overwrite});
        tab.path = body.path.slice();
        tab.name = uniqueTabName(
          body.path[body.path.length - 1] || 'script',
          tab.id
        );
        tab.savedText = content;
        renderTabs();
        persist();
        setStatus(`${displayScriptPath(body.path)} saved.`);
        return true;
      } catch (error) {
        const overwriteMessage =
          `${displayScriptPath(path)} exists. Overwrite it?`;
        if (!overwrite && error.status === 409 &&
            window.confirm(overwriteMessage)) {
          setBusy(false);
          return saveTab(tab, path, true);
        }
        setStatus(error.message, 'error', true);
        return false;
      } finally {
        setBusy(false);
      }
    }

    async function saveActiveTab() {
      if (busy) return;
      closeMenus();
      const tab = activeTab();
      if (!tab.path) {
        showSaveAsDialog();
        return;
      }
      await saveTab(tab, tab.path, true);
    }

    async function saveAsFromDialog() {
      const path = scriptPathFromInput(filePathInput.value);
      if (!path) {
        fileDialogHelp.textContent =
          'Invalid path. Use names like folder/script-name.';
        filePathInput.focus();
        return;
      }
      const saved = await saveTab(activeTab(), path, false);
      if (saved) closeFileDialog();
    }

    function selectedResultsDelimiter() {
      const selected = resultsDelimiterFields.querySelector(
        'input[name="results-delimiter"]:checked'
      );
      return selected ? selected.value : 'comma';
    }

    function resultSaveText() {
      if (outputState.kind === 'parse') {
        return ensureTrailingNewline(outputState.text);
      }
      return runExportText(
        outputState.commands,
        selectedResultsDelimiter()
      );
    }

    async function saveResultsFile(path, overwrite) {
      if (busy || !outputState.exportable) return false;
      const content = resultSaveText();
      setBusy(true, 'save-results');
      try {
        const body = await api('file-save', {path, content, overwrite});
        setStatus(`${body.path.slice(1).join('/')} saved.`);
        return true;
      } catch (error) {
        const name = path.slice(1).join('/');
        if (!overwrite && error.status === 409 &&
            window.confirm(`${name} exists. Overwrite it?`)) {
          setBusy(false);
          return saveResultsFile(path, true);
        }
        setStatus(error.message, 'error', true);
        return false;
      } finally {
        setBusy(false);
      }
    }

    async function saveResultsFromDialog() {
      const path = resultPathFromInput(filePathInput.value);
      if (!path) {
        fileDialogHelp.textContent =
          'Invalid path. Use names like folder/results-name.';
        filePathInput.focus();
        return;
      }
      const saved = await saveResultsFile(path, false);
      if (saved) closeFileDialog();
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

    function auraText(aura) {
      const text = String(aura || '');
      return text.startsWith('@') ? text : `@${text}`;
    }

    function relationTemplate(action, relation) {
      const qualified = `${relation.database}.${relation.namespace}.` +
        relation.name;
      const columns = relation.columns.map((column) => column.name);
      if (action === 'SELECT') {
        return `FROM ${qualified}\nSELECT ${columns.join(', ') || '*'};`;
      }
      if (action === 'INSERT' && relation.kind === 'table') {
        const values = columns.map(() => 'DEFAULT').join(', ');
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
        return `CREATE TABLE ${qualified}\n  (\n${definitions}\n  )\n` +
          `  PRIMARY KEY (${keys.join(', ')});`;
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
      if (text) addDraft(text);
    }

    function renderColumn(column) {
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
      relation.columns.forEach((column) => {
        children.appendChild(renderColumn(column));
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
      namespace.relations.forEach((relation) => {
        children.appendChild(renderRelation(relation));
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
      database.namespaces.forEach((namespace) => {
        children.appendChild(renderNamespace(database, namespace));
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
      defaultDatabase.value = state.defaultDatabase;
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

    function selectedScript() {
      captureEditor();
      const tab = activeTab();
      if (tab.selectionEnd > tab.selectionStart) {
        return tab.text.slice(tab.selectionStart, tab.selectionEnd);
      }
      return tab.text;
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

    function renderResultSet(resultSet, resultNumber, resultCount) {
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
      let page = 0;
      const pageCount = Math.ceil(rows.length / resultPageSize);
      const pager = document.createElement('nav');
      pager.className = 'result-pager';
      pager.setAttribute('aria-label', 'Result pages');
      const pageStatus = document.createElement('span');
      pageStatus.className = 'result-pager-status';
      const previous = document.createElement('button');
      previous.type = 'button';
      previous.textContent = 'Previous';
      const next = document.createElement('button');
      next.type = 'button';
      next.textContent = 'Next';
      function renderPage() {
        const first = page * resultPageSize;
        const last = Math.min(first + resultPageSize, rows.length);
        tableHolder.replaceChildren(
          renderResultTable(resultSet, rows.slice(first, last), first)
        );
        pageStatus.textContent =
          `Rows ${first + 1}–${last} of ${rows.length} · ` +
          `Page ${page + 1} of ${pageCount}`;
        previous.disabled = page === 0;
        next.disabled = page === pageCount - 1;
      }
      previous.addEventListener('click', () => {
        page = Math.max(0, page - 1);
        renderPage();
      });
      next.addEventListener('click', () => {
        page = Math.min(pageCount - 1, page + 1);
        renderPage();
      });
      pager.append(pageStatus, previous, next);
      section.appendChild(pager);
      renderPage();
      return section;
    }

    function renderCommand(command, position) {
      const group = document.createElement('article');
      group.className = 'command-group';
      const heading = document.createElement('h3');
      heading.className = 'command-heading';
      const commandIndex = Number.isInteger(command.index) ?
        command.index + 1 : position + 1;
      heading.textContent = `Command ${commandIndex}`;
      group.appendChild(heading);
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
      messagesTab.addEventListener('click', () => selectTab(false));
      tabList.append(resultsTab, messagesTab);
      group.append(tabList, resultPanel, messagePanel);
      return group;
    }

    function revealOutput() {
      state.outputOpen = true;
      applyLayout();
      persist();
      updateOutputControls();
    }

    function showRunOutput(commands) {
      const safeCommands = Array.isArray(commands) ? commands : [];
      const exportable = allResultSets(safeCommands).some((resultSet) => {
        return Array.isArray(resultSet.columns) &&
          resultSet.columns.length > 0;
      });
      outputState = {
        kind: 'run',
        commands: safeCommands,
        text: '',
        exportable
      };
      lastOutputText = runCopyText(safeCommands);
      results.replaceChildren();
      if (safeCommands.length === 0) {
        const empty = document.createElement('p');
        empty.className = 'empty-state';
        empty.textContent = 'No command results.';
        results.appendChild(empty);
      } else {
        safeCommands.forEach((command, position) => {
          results.appendChild(renderCommand(command, position));
        });
      }
      revealOutput();
    }

    function showParseOutput(text) {
      const value = String(text || '');
      outputState = {
        kind: 'parse',
        commands: [],
        text: value,
        exportable: value.length > 0
      };
      lastOutputText = value;
      results.replaceChildren();
      const pre = document.createElement('pre');
      pre.className = 'parse-output';
      pre.textContent = value;
      results.appendChild(pre);
      revealOutput();
    }

    function showErrorOutput(text) {
      const value = String(text || 'Unknown error.');
      outputState = {
        kind: 'error',
        commands: [],
        text: value,
        exportable: false
      };
      lastOutputText = value;
      results.replaceChildren();
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

    async function execute(operation) {
      if (busy) return;
      const script = selectedScript();
      setBusy(true, operation);
      setStatus(operation === 'run' ? 'Running query…' : 'Parsing query…');
      try {
        const body = await api(operation, {
          defaultDatabase: defaultDatabase.value,
          script
        });
        if (operation === 'parse') {
          showParseOutput(body.text || '');
          setStatus('Parse complete.');
        } else {
          showRunOutput(body.commands || []);
          if (body.schemaChanged) {
            await refreshSchema({preferNewDatabase: true});
          }
          setStatus('Run complete.');
        }
      } catch (error) {
        const message = error instanceof Error ? error.message : String(error);
        showErrorOutput(message);
        setStatus(message, 'error', true);
      } finally {
        setBusy(false);
      }
    }

    async function copyText(text, label) {
      try {
        if (window.isSecureContext && navigator.clipboard) {
          await navigator.clipboard.writeText(text);
        } else {
          const helper = document.createElement('textarea');
          helper.value = text;
          helper.setAttribute('readonly', '');
          helper.style.position = 'fixed';
          helper.style.opacity = '0';
          document.body.appendChild(helper);
          helper.select();
          if (!document.execCommand('copy')) throw new Error('copy failed');
          helper.remove();
        }
        setStatus(`${label} copied.`);
      } catch (_) {
        setStatus(`Could not copy ${label.toLowerCase()}.`, 'error', true);
      }
    }

    function menuParts(menu) {
      return {
        toggle: menu.querySelector('.menu-toggle'),
        panel: menu.querySelector('.menu-panel')
      };
    }

    function setMenu(menu, open, focusFirst = false) {
      const parts = menuParts(menu);
      menu.dataset.open = String(open);
      parts.toggle.setAttribute('aria-expanded', String(open));
      parts.panel.classList.toggle('hidden', !open);
      if (open && focusFirst) {
        const selector = '[role="menuitem"]:not(:disabled)';
        const first = parts.panel.querySelector(selector);
        if (first) first.focus();
      }
    }

    const menus = Array.from(document.querySelectorAll('.menu'));

    function closeMenus(except = null) {
      menus.forEach((menu) => {
        if (menu !== except) setMenu(menu, false);
      });
    }

    function menuKeydown(event) {
      const panel = event.currentTarget;
      const items = Array.from(
        panel.querySelectorAll('[role="menuitem"]:not(:disabled)')
      );
      const current = items.indexOf(document.activeElement);
      let next = current;
      if (event.key === 'ArrowDown') next = (current + 1) % items.length;
      if (event.key === 'ArrowUp') {
        next = (current + items.length - 1) % items.length;
      }
      if (event.key === 'Home') next = 0;
      if (event.key === 'End') next = items.length - 1;
      if (next === current || items.length === 0) return;
      event.preventDefault();
      items[next].focus();
    }

    menus.forEach((menu) => {
      const parts = menuParts(menu);
      parts.toggle.addEventListener('click', () => {
        const open = menu.dataset.open !== 'true';
        closeMenus(menu);
        setMenu(menu, open);
      });
      parts.toggle.addEventListener('keydown', (event) => {
        if (event.key !== 'ArrowDown') return;
        event.preventDefault();
        closeMenus(menu);
        setMenu(menu, true, true);
      });
      parts.panel.addEventListener('keydown', menuKeydown);
    });

    function clamp(value, minimum, maximum) {
      return Math.min(maximum, Math.max(minimum, value));
    }

    function narrowLayout() {
      return window.matchMedia('(max-width: 760px)').matches;
    }

    function applyLayout() {
      schemaPane.classList.toggle('collapsed', !state.schemaOpen);
      outputPane.classList.toggle('collapsed', !state.outputOpen);
      schemaResizer.hidden = !state.schemaOpen;
      outputResizer.hidden = !state.outputOpen;
      schemaCollapse.setAttribute('aria-expanded', String(state.schemaOpen));
      outputCollapse.setAttribute('aria-expanded', String(state.outputOpen));
      schemaCollapse.setAttribute('aria-label', state.schemaOpen ?
        'Collapse schemas' : 'Expand schemas');
      outputCollapse.setAttribute('aria-label', state.outputOpen ?
        'Collapse output' : 'Expand output');
      schemaCollapse.textContent = state.schemaOpen ? '‹' : '›';
      outputCollapse.textContent = state.outputOpen ? '⌄' : '⌃';
      if (narrowLayout()) {
        const size = clamp(state.schemaSize, 160,
          Math.max(160, window.innerHeight * 0.45));
        workbench.style.gridTemplateColumns = 'minmax(0, 1fr)';
        workbench.style.gridTemplateRows = state.schemaOpen ?
          `${size}px .35rem minmax(32rem, 1fr)` :
          '3rem 0 minmax(32rem, 1fr)';
      } else {
        const size = clamp(state.schemaSize, 180,
          Math.max(180, window.innerWidth * 0.55));
        workbench.style.gridTemplateRows = '';
        workbench.style.gridTemplateColumns = state.schemaOpen ?
          `${size}px .35rem minmax(0, 1fr)` :
          '3rem 0 minmax(0, 1fr)';
      }
      const outputSize = clamp(state.outputSize, 96,
        Math.max(96, workspace.clientHeight - 180));
      workspace.style.gridTemplateRows = state.outputOpen ?
        `minmax(12rem, 1fr) .35rem ${outputSize}px` :
        'minmax(12rem, 1fr) 0 3rem';
      schemaResizer.setAttribute('aria-valuenow', String(state.schemaSize));
      outputResizer.setAttribute('aria-valuenow', String(state.outputSize));
    }

    function beginResize(kind, event) {
      if (event.button !== 0) return;
      event.preventDefault();
      const move = (next) => {
        if (kind === 'schema') {
          const rect = workbench.getBoundingClientRect();
          state.schemaSize = narrowLayout() ?
            next.clientY - rect.top : next.clientX - rect.left;
        } else {
          const rect = workspace.getBoundingClientRect();
          state.outputSize = rect.bottom - next.clientY;
        }
        applyLayout();
      };
      const finish = () => {
        document.removeEventListener('pointermove', move);
        document.removeEventListener('pointerup', finish);
        persist();
      };
      document.addEventListener('pointermove', move);
      document.addEventListener('pointerup', finish);
    }

    function resizeKeydown(kind, event) {
      let delta = 0;
      if (event.key === 'ArrowLeft' || event.key === 'ArrowUp') delta = -16;
      if (event.key === 'ArrowRight' || event.key === 'ArrowDown') delta = 16;
      if (delta === 0) return;
      event.preventDefault();
      if (kind === 'schema') state.schemaSize += delta;
      if (kind === 'output') state.outputSize -= delta;
      applyLayout();
      persist();
    }

    editor.addEventListener('input', () => {
      captureEditor();
      const tab = activeTab();
      const button = byId(`tab-${tab.id}`);
      const dirty = tab.savedText !== null && tab.text !== tab.savedText;
      if (button) button.textContent = `${tab.name}${dirty ? ' •' : ''}`;
      persist();
    });
    ['select', 'keyup', 'pointerup'].forEach((eventName) => {
      editor.addEventListener(eventName, () => {
        captureEditor();
        persist();
      });
    });
    newTabButton.addEventListener('click', () => addDraft());
    byId('new-tab-menu-item').addEventListener('click', () => addDraft());
    byId('open-menu-item').addEventListener('click', showOpenDialog);
    byId('save-tab-menu-item').addEventListener('click', saveActiveTab);
    byId('save-as-menu-item').addEventListener('click', showSaveAsDialog);
    byId('close-tab-menu-item').addEventListener('click', closeActiveTab);
    byId('file-dialog-cancel').addEventListener('click', closeFileDialog);
    fileDialogForm.addEventListener('submit', (event) => {
      event.preventDefault();
      if (fileDialogMode === 'open') openSelectedFile();
      else if (fileDialogMode === 'save-results') saveResultsFromDialog();
      else saveAsFromDialog();
    });
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
    saveResultsButton.addEventListener('click', showSaveResultsDialog);
    copyQueryButton.addEventListener('click', () => {
      captureEditor();
      copyText(activeTab().text, 'Query');
    });
    copyOutputButton.addEventListener('click', () => {
      copyText(lastOutputText, 'Output');
    });
    defaultDatabase.addEventListener('change', () => {
      state.defaultDatabase = defaultDatabase.value;
      persist();
      refreshSchema();
    });
    schemaCollapse.addEventListener('click', () => {
      state.schemaOpen = !state.schemaOpen;
      applyLayout();
      persist();
    });
    outputCollapse.addEventListener('click', () => {
      state.outputOpen = !state.outputOpen;
      applyLayout();
      persist();
    });
    schemaResizer.addEventListener('pointerdown', (event) => {
      beginResize('schema', event);
    });
    outputResizer.addEventListener('pointerdown', (event) => {
      beginResize('output', event);
    });
    schemaResizer.addEventListener('keydown', (event) => {
      resizeKeydown('schema', event);
    });
    outputResizer.addEventListener('keydown', (event) => {
      resizeKeydown('output', event);
    });
    document.addEventListener('click', (event) => {
      if (!event.target.closest('.menu')) closeMenus();
      if (!event.target.closest('#relation-menu') &&
          !event.target.closest('.relation-actions')) {
        closeRelationMenu();
      }
    });
    document.addEventListener('keydown', (event) => {
      if (event.key === 'Escape') {
        const open = menus.find((menu) => menu.dataset.open === 'true');
        closeMenus();
        closeRelationMenu();
        if (open) menuParts(open).toggle.focus();
      }
      if (event.key === 'F5') {
        event.preventDefault();
        execute('run');
      }
    });
    window.addEventListener('resize', applyLayout);
    window.addEventListener('beforeunload', () => {
      captureEditor();
      persist();
    });

    updateOutputControls();
    defaultDatabase.value = state.defaultDatabase;
    if (!defaultDatabase.value) {
      state.defaultDatabase = 'sys';
      defaultDatabase.value = 'sys';
    }
    renderTabs();
    restoreEditor(false);
    applyLayout();
    setBusy(false);
    refreshSchema();
    document.documentElement.dataset.obelisk = 'ready';

    window.ObeliskWorkbench = {
      api,
      addDraft,
      addFileTab,
      activateTab,
      closeActiveTab,
      execute,
      getState: () => state,
      openRelationAction,
      persist,
      refreshSchema,
      relationTemplate,
      renderCommand,
      runCopyText,
      runExportText,
      saveActiveTab,
      showSaveResultsDialog,
      showOpenDialog,
      showSaveAsDialog,
      setStatus,
      showOutput,
      showRunOutput
    };
  })();
  '''
--
