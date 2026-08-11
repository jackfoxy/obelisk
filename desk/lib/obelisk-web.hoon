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
      ;link#favicon(rel "icon", type "image/png", href "/apps/obelisk/favicon.png");
      ;link(rel "stylesheet", href "/apps/obelisk/app.css");
      ;script(src "/apps/obelisk/app.js", defer "");
    ==
    ;body
      ;div#obelisk-app.app-shell
        ;header#app-header.app-header
          ;a.brand(href "/apps/obelisk", aria-label "Obelisk home")
            Obelisk
          ==
          ;div#file-menu.menu.header-file-menu(data-open "false")
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
                Close Current
              ==
            ==
          ==
          ;nav.toolbar(aria-label "Obelisk workbench controls")
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
            ;button#help-btn(type "button", aria-expanded "false"): Help
          ==
        ==
        ;main#workbench.workbench
          ;aside#schema-pane.schema-pane
            =aria-label  "Obelisk explorer"
            ;div.pane-header
              ;div.explorer-heading
                ;div#explorer-tabs.explorer-tabs
                  =role  "tablist"
                  =aria-label  "Obelisk explorer"
                  ;div.explorer-tab-control.active(role "presentation")
                    ;button#schemas-tab.explorer-tab.active
                      =type  "button"
                      =role  "tab"
                      =data-explorer-view  "schemas"
                      =aria-selected  "true"
                      =aria-controls  "schema-panel"
                      Schemas
                    ==
                  ==
                  ;div.explorer-tab-control(role "presentation")
                    ;button#files-tab.explorer-tab
                      =type  "button"
                      =role  "tab"
                      =data-explorer-view  "files"
                      =aria-selected  "false"
                      =aria-controls  "files-panel"
                      =tabindex  "-1"
                      Files
                    ==
                  ==
                ==
                ;span#local-ship.ship: {(trip (scot %p our))}
              ==
              ;button#schema-collapse.icon-button
                =type  "button"
                =aria-label  "Collapse explorer"
                =aria-expanded  "true"
                ‹
              ==
            ==
            ;div#schema-panel.explorer-panel
              =role  "tabpanel"
              =aria-labelledby  "schemas-tab"
              ;div#schema-tree.schema-tree
                =role  "tree"
                =aria-label  "Database schemas"
                =aria-busy  "true"
                ;p.empty-state: Loading schemas…
              ==
            ==
            ;div#files-panel.explorer-panel(hidden "")
              =role  "tabpanel"
              =aria-labelledby  "files-tab"
              ;div#files-tree.file-tree
                =role  "tree"
                =aria-label  "Saved scripts and results"
                =aria-busy  "true"
                ;p.empty-state: Loading files…
              ==
            ==
          ==
          ;button#schema-resizer.splitter
            =type  "button"
            =role  "separator"
            =aria-orientation  "vertical"
            =aria-label  "Resize explorer"
            ;span.visually-hidden: Resize explorer
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
                ;div.editor-actions
                  ;button#save-query-btn.icon-button.save-action
                    =type  "button"
                    =title  "Save script"
                    =aria-label  "Save script"
                    =aria-haspopup  "menu"
                    =aria-expanded  "false"
                    ;span.save-icon(aria-hidden "true");
                  ==
                  ;button#copy-query-btn.icon-button
                    =type  "button"
                    =title  "Copy script"
                    =aria-label  "Copy script"
                    ;span.copy-icon(aria-hidden "true");
                  ==
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
                  ;button#save-output-btn.icon-button.save-action
                    =type  "button"
                    =title  "Save results"
                    =aria-label  "Save results"
                    =disabled  ""
                    ;span.save-icon(aria-hidden "true");
                  ==
                  ;button#copy-output-btn.icon-button
                    =type  "button"
                    =title  "Copy results"
                    =aria-label  "Copy results"
                    ;span.copy-icon(aria-hidden "true");
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
        ;aside#help-panel.help-panel(hidden "", aria-label "Help")
          ;div.help-card
            ;div.pane-header
              ;h2: Help
              ;button#close-help.icon-button.help-close
                =type  "button"
                =title  "Close"
                =aria-label  "Close help"
                ;span.close-icon(aria-hidden "true");
              ==
            ==
            ;div#fallback-help-content
              ;nav.help-links(aria-label "Obelisk documentation")
                ;a
                  =href
                    "https://github.com/jackfoxy/obelisk/tree/master/".
                    "desk/doc/usr/reference/"
                  =target  "_blank"
                  =rel  "noopener noreferrer"
                  Reference
                ==
                ;a
                  =href
                    "https://github.com/jackfoxy/obelisk/blob/master/".
                    "desk/doc/usr/users-guide.md"
                  =target  "_blank"
                  =rel  "noopener noreferrer"
                  Users Guide
                ==
                ;a
                  =href
                    "https://github.com/jackfoxy/obelisk/blob/master/".
                    "roadmap.md"
                  =target  "_blank"
                  =rel  "noopener noreferrer"
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
                    =rel  "noopener noreferrer"
                    API/AST
                  ==
                  ;a
                    =href
                      "https://github.com/jackfoxy/obelisk/tree/master/".
                      ".claude/skills/obelisk-urql"
                    =target  "_blank"
                    =rel  "noopener noreferrer"
                    urQL LLM
                  ==
                  ;a
                    =href
                      "https://github.com/jackfoxy/obelisk/blob/master/".
                      "desk/doc/dev/users-guide-script.txt"
                    =target  "_blank"
                    =rel  "noopener noreferrer"
                    Sample urQL
                  ==
                  ;a
                    =href
                      "https://github.com/jackfoxy/obelisk/blob/master/".
                      "desk/doc/dev/performance.md"
                    =target  "_blank"
                    =rel  "noopener noreferrer"
                    Benchmarks
                  ==
                ==
              ==
            ==
            ;div#docs-help-content.docs-help-content.hidden
              ;nav#docs-help-tree.docs-help-tree
                =role  "tree"
                =aria-label  "Obelisk documentation in Docs"
                ;*  ~[;/("")]
              ==
              ;a.docs-llm-button
                =href
                  "https://github.com/jackfoxy/obelisk/tree/master/".
                  ".claude/skills/obelisk-urql"
                =target  "_blank"
                =rel  "noopener noreferrer"
                =role  "button"
                urQL LLM
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
            ;label#results-format-field.hidden(for "results-format-select")
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
        ;div#save-context-menu.save-context-menu.hidden(role "menu")
          ;button#save-context-save(type "button", role "menuitem")
            Save
          ==
          ;button#save-context-save-as(type "button", role "menuitem")
            Save As...
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
    border-radius: 0.4rem;
    min-height: 2rem;
    padding: 0.5rem 0.75rem;
  }

  button, select, a {
    touch-action: manipulation;
  }

  button:not(:disabled), select, a {
    cursor: pointer;
  }

  button:hover:not(:disabled) {
    border-color: var(--accent);
  }

  a:hover {
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
    padding: 0.75rem 1rem;
    position: relative;
    z-index: 20;
  }

  .brand {
    font-size: 1.05rem;
    font-weight: 700;
    text-decoration: none;
  }

  .header-file-menu {
    margin-left: 0.25rem;
  }

  #file-menu-toggle {
    background: transparent;
    border: 0;
  }

  .toolbar {
    align-items: center;
    display: flex;
    flex: 1;
    flex-wrap: wrap;
    gap: 0.5rem;
    justify-content: flex-end;
    margin-left: auto;
  }

  .toolbar button, .toolbar select {
    padding: 0.5rem 0.75rem;
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

  #results-format-field {
    color: var(--muted);
    display: grid;
    font-size: 0.8rem;
    gap: 0.3rem;
  }

  #results-format-select {
    background: var(--surface);
    border: 1px solid var(--border);
    border-radius: 0.3rem;
    color: var(--text);
    min-height: 2.25rem;
    padding: 0.4rem 0.55rem;
    width: 100%;
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

  .relation-menu, .save-context-menu {
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

  .relation-menu button, .save-context-menu button {
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
  .schema-pane.collapsed .explorer-panel {
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

  .explorer-heading {
    flex: 1;
    min-width: 0;
  }

  .explorer-tabs {
    border-bottom: 1px solid var(--border);
    display: flex;
    gap: 0.2rem;
    overflow-x: auto;
  }

  .explorer-tab {
    background: transparent;
    border: 0;
    border-radius: 0;
    color: var(--muted);
    font-weight: 600;
    height: 100%;
    padding: 0.2rem 0.35rem;
  }

  .explorer-tab:hover, .explorer-tab:focus-visible {
    background: var(--surface-alt);
    color: var(--text);
  }

  .explorer-tab.active {
    color: var(--text);
  }

  .explorer-tab-control, .docs-tab-control {
    align-items: center;
    border: 1px solid var(--border);
    border-radius: 0.4rem;
    display: inline-flex;
    overflow: hidden;
  }

  .explorer-tab-control {
    height: 2rem;
  }

  .explorer-tab-control .explorer-tab {
    align-items: center;
    display: inline-flex;
    justify-content: center;
    line-height: 1;
    padding-block: 0;
  }

  .docs-tab-control {
    height: 2.3rem;
  }

  .docs-tab-control .explorer-tab {
    max-width: 12rem;
    overflow: hidden;
    padding-right: 0.2rem;
    text-overflow: ellipsis;
    white-space: nowrap;
  }

  .docs-tab-close {
    align-items: center;
    align-self: stretch;
    background: transparent;
    border: 0;
    border-left: 0;
    border-radius: 0;
    display: inline-flex;
    justify-content: center;
    min-height: 1.5rem;
    padding: 0.2rem;
    width: 1.5rem;
  }

  .docs-tab-close .close-icon {
    height: 0.65rem;
    width: 0.65rem;
  }

  .docs-tab-close .close-icon::before,
  .docs-tab-close .close-icon::after {
    top: 0.3rem;
    width: 0.65rem;
  }

  .ship {
    color: var(--muted);
    display: block;
    font-family: ui-monospace, monospace;
    font-size: 0.78rem;
    margin-top: 0.15rem;
  }

  .explorer-panel {
    min-height: 0;
    overflow: hidden;
  }

  .docs-panel {
    padding: 0;
  }

  .docs-frame {
    background: var(--surface);
    border: 0;
    display: block;
    height: 100%;
    width: 100%;
  }

  .schema-tree, .file-tree, .results {
    height: 100%;
    overflow: auto;
    padding: 0.75rem;
  }

  .file-node {
    margin: 0.1rem 0;
  }

  .file-node > summary {
    border-radius: 0.25rem;
    color: var(--muted);
    cursor: pointer;
    font-family: ui-monospace, monospace;
    min-height: 1.9rem;
    padding: 0.3rem 0.25rem;
  }

  .file-node > summary:hover, .explorer-file:hover {
    background: var(--surface-alt);
  }

  .file-children {
    border-left: 1px solid var(--border);
    margin-left: 0.7rem;
    padding-left: 0.65rem;
  }

  .explorer-file {
    border-radius: 0.25rem;
    padding: 0.15rem 0.25rem;
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

  .splitter.inactive {
    pointer-events: none;
    visibility: hidden;
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

  .editor-tabs > button, .editor-tab-control {
    border-bottom-left-radius: 0;
    border-bottom-right-radius: 0;
    height: 2.3rem;
    margin-right: 0.25rem;
  }

  .editor-tab-control {
    align-items: stretch;
    border: 1px solid var(--border);
    border-radius: 0.4rem;
    display: inline-flex;
    overflow: hidden;
  }

  .editor-tab-control .tab, .editor-tab-close {
    background: transparent;
    border: 0;
    border-radius: 0;
    height: 100%;
    margin: 0;
  }

  .editor-tab-close {
    align-items: center;
    border-left: 0;
    display: inline-flex;
    justify-content: center;
    padding: 0.2rem;
    width: 1.75rem;
  }

  .editor-tab-close .close-icon {
    height: 0.65rem;
    width: 0.65rem;
  }

  .editor-tab-close .close-icon::before,
  .editor-tab-close .close-icon::after {
    top: 0.3rem;
    width: 0.65rem;
  }

  .editor-tabs .active {
    background: var(--surface);
    border-bottom-color: var(--surface);
    font-weight: 600;
  }

  .editor-tabs .new-tab {
    align-items: center;
    display: inline-flex;
    justify-content: center;
    line-height: 1;
    padding-block: 0;
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

  .editor-actions {
    display: flex;
    gap: 0.35rem;
  }

  .icon-button {
    align-items: center;
    display: inline-flex;
    justify-content: center;
    min-height: 1.8rem;
    padding: 0.2rem 0.5rem;
  }

  #copy-query-btn, #copy-output-btn,
  #save-query-btn, #save-output-btn {
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

  .copy-icon {
    height: 0.9rem;
    position: relative;
    width: 0.9rem;
  }

  .copy-icon::before, .copy-icon::after {
    border: 1.5px solid currentcolor;
    border-radius: 2px;
    content: '';
    height: 0.58rem;
    position: absolute;
    width: 0.5rem;
  }

  .copy-icon::before {
    left: 0;
    top: 0;
  }

  .copy-icon::after {
    background: var(--surface);
    bottom: 0;
    right: 0;
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

  .command-tabs {
    align-items: end;
    background: var(--surface-alt);
    border-bottom: 1px solid var(--border);
    display: flex;
    min-height: 2.65rem;
    padding: 0.35rem 0.5rem 0;
  }

  .command-tab {
    border-bottom-left-radius: 0;
    border-bottom-right-radius: 0;
    height: 2.3rem;
    margin-right: 0.25rem;
  }

  .command-tab[aria-selected="true"] {
    background: var(--surface);
    border-bottom-color: var(--surface);
    font-weight: 600;
  }

  .command-tab-panel .command-group {
    margin-bottom: 0;
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
  }

  .result-pager-top {
    margin-bottom: 0.45rem;
  }

  .result-pager-bottom {
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

  .help-panel {
    background: rgb(0 0 0 / 0.4);
    display: grid;
    inset: 0;
    padding: 1rem;
    place-items: center;
    position: fixed;
    z-index: 70;
  }

  .help-panel[hidden] {
    display: none;
  }

  .help-card {
    background: var(--surface);
    border: 1px solid var(--border);
    border-radius: 0.75rem;
    box-shadow: 0 1rem 3rem rgb(0 0 0 / 0.2);
    max-width: 32rem;
    padding: 0 1rem 1rem;
    width: 100%;
  }

  .help-close {
    height: 2rem;
    padding: 0;
    width: 2rem;
  }

  .close-icon {
    height: 0.9rem;
    position: relative;
    width: 0.9rem;
  }

  .close-icon::before, .close-icon::after {
    background: currentcolor;
    content: '';
    height: 1px;
    left: 0;
    position: absolute;
    top: 0.42rem;
    width: 0.9rem;
  }

  .close-icon::before {
    transform: rotate(45deg);
  }

  .close-icon::after {
    transform: rotate(-45deg);
  }

  .help-links {
    display: grid;
    gap: 0.5rem;
  }

  .help-links a {
    border: 1px solid var(--border);
    border-radius: 0.4rem;
    padding: 0.65rem 0.75rem;
    text-decoration: none;
  }

  .help-section {
    margin-top: 1rem;
  }

  .help-section h3 {
    font-size: 0.9rem;
    margin: 0 0 0.5rem;
  }

  .docs-help-content {
    display: grid;
    gap: 0.8rem;
  }

  .docs-help-tree {
    display: grid;
    gap: 0.4rem;
    max-height: min(32rem, calc(100vh - 11rem));
    overflow: auto;
  }

  .docs-help-branch {
    border: 1px solid var(--border);
    border-radius: 0.4rem;
  }

  .docs-help-branch > summary {
    cursor: pointer;
    font-weight: 600;
    padding: 0.6rem 0.7rem;
  }

  .docs-help-branch > summary:hover,
  .docs-help-link:hover {
    background: var(--surface-alt);
  }

  .docs-help-group {
    border-top: 1px solid var(--border);
    display: grid;
    padding: 0.3rem;
  }

  .docs-help-static {
    display: grid;
  }

  .docs-help-label {
    color: var(--muted);
    font-size: 0.84rem;
    font-weight: 600;
    padding: 0.45rem 0.65rem 0.25rem;
  }

  .docs-help-static-children {
    border-left: 1px solid var(--border);
    display: grid;
    margin-left: 0.75rem;
    padding-left: 0.3rem;
  }

  .docs-help-link {
    border-radius: 0.3rem;
    padding: 0.45rem 0.65rem;
    text-decoration: none;
  }

  .docs-llm-button {
    border: 1px solid var(--accent);
    border-radius: 0.4rem;
    padding: 0.65rem 0.75rem;
    text-align: center;
    text-decoration: none;
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
    const saveQueryButton = byId('save-query-btn');
    const saveOutputButton = byId('save-output-btn');
    const copyQueryButton = byId('copy-query-btn');
    const copyOutputButton = byId('copy-output-btn');
    const helpButton = byId('help-btn');
    const helpPanel = byId('help-panel');
    const closeHelpButton = byId('close-help');
    const fallbackHelpContent = byId('fallback-help-content');
    const docsHelpContent = byId('docs-help-content');
    const docsHelpTree = byId('docs-help-tree');
    const defaultDatabase = byId('default-db');
    const explorerTabs = byId('explorer-tabs');
    const schemasTab = byId('schemas-tab');
    const filesTab = byId('files-tab');
    const schemaPanel = byId('schema-panel');
    const filesPanel = byId('files-panel');
    const schemaTree = byId('schema-tree');
    const filesTree = byId('files-tree');
    const results = byId('results');
    const status = byId('app-status');
    const fileDialog = byId('file-dialog');
    const fileDialogForm = byId('file-dialog-form');
    const fileDialogTitle = byId('file-dialog-title');
    const fileDialogHelp = byId('file-dialog-help');
    const fileDialogList = byId('file-dialog-list');
    const filePathLabel = byId('file-path-label');
    const filePathInput = byId('file-path-input');
    const resultsFormatField = byId('results-format-field');
    const resultsFormatSelect = byId('results-format-select');
    const fileDialogConfirm = byId('file-dialog-confirm');
    const relationMenu = byId('relation-menu');
    const saveContextMenu = byId('save-context-menu');
    const saveContextSave = byId('save-context-save');
    const saveContextSaveAs = byId('save-context-save-as');
    let statusTimer = 0;
    let lastOutputText = '';
    let outputState = {
      kind: 'empty',
      commands: [],
      activeCommand: null,
      text: '',
      exportable: false,
      path: null,
      format: null
    };
    let busy = false;
    let fileDialogMode = 'open';
    let selectedFilePath = null;
    let fileEntries = [];
    let explorerFileEntries = [];
    let schemaValue = null;
    const foreignKeysUnavailable = new Set();
    let relationContext = null;
    let saveContextKind = null;
    let saveContextSource = null;
    let docsAvailable = null;
    let docsCheckPending = false;
    const docsHelpSections = [
      {
        children: [
          {title: 'Users Guide', path: 'usr/users-guide'},
          {
            title: 'Reference',
            children: [
              {
                title: 'Preliminaries',
                path: 'usr/reference/preliminaries'
              },
              {
                title: 'Data Definition Language',
                children: [
                  {
                    title: 'Database',
                    path: 'usr/reference/ddl/database'
                  },
                  {
                    title: 'Namespace',
                    path: 'usr/reference/ddl/namespace'
                  },
                  {title: 'Table', path: 'usr/reference/ddl/table'},
                  {title: 'Index', path: 'usr/reference/ddl/index'}
                ]
              },
              {
                title: 'Data Manipulation Language',
                children: [
                  {title: 'Insert', path: 'usr/reference/dml/insert'},
                  {title: 'Update', path: 'usr/reference/dml/update'},
                  {title: 'Upsert', path: 'usr/reference/dml/upsert'},
                  {title: 'Delete', path: 'usr/reference/dml/delete'},
                  {
                    title: 'Truncate Table DML',
                    path: 'usr/reference/dml/truncate-table'
                  }
                ]
              },
              {title: 'Select', path: 'usr/reference/select'},
              {
                title: 'Scries and Subscriptions',
                path: 'usr/reference/scry'
              },
              {title: 'Scalars', path: 'usr/reference/scalars'},
              {
                title: 'Security Permissions',
                path: 'usr/reference/security-permissions'
              }
            ]
          }
        ]
      },
      {
        title: 'Developer Docs',
        children: [
          {title: 'Performance', path: 'dev/performance'},
          {
            title: 'Users Guide Scripts',
            path: 'dev/users-guide-script'
          }
        ]
      }
    ];

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
        defaultDatabase: null,
        explorerView: 'schemas',
        docsTabs: [],
        nextDocs: 1,
        schemaExpanded: [],
        schemaDatabaseNames: [],
        filesCollapsed: []
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

    function validDocsTab(tab) {
      return tab && typeof tab.id === 'string' &&
        typeof tab.documentTitle === 'string' &&
        typeof tab.path === 'string';
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
        if (!Array.isArray(restored.docsTabs)) restored.docsTabs = [];
        restored.docsTabs = restored.docsTabs.filter(validDocsTab);
        if (!Number.isInteger(restored.nextDocs)) restored.nextDocs = 1;
        const explorerViewExists = ['schemas', 'files'].includes(
          restored.explorerView
        ) || restored.docsTabs.some((tab) => {
          return tab.id === restored.explorerView;
        });
        if (!explorerViewExists) {
          restored.explorerView = 'schemas';
        }
        if (!Array.isArray(restored.filesCollapsed)) {
          restored.filesCollapsed = [];
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
      const controls = tabsElement.querySelectorAll(
        '.editor-tab-control, .tab'
      );
      controls.forEach((tab) => {
        tab.remove();
      });
      state.tabs.forEach((tab) => {
        const control = document.createElement('div');
        const button = document.createElement('button');
        const selected = tab.id === state.activeId;
        control.className = selected ?
          'editor-tab-control active' : 'editor-tab-control';
        control.setAttribute('role', 'presentation');
        button.type = 'button';
        button.id = `tab-${tab.id}`;
        button.className = 'tab';
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
        const close = document.createElement('button');
        close.type = 'button';
        close.className = 'editor-tab-close';
        close.title = 'Close';
        close.setAttribute('aria-label', `Close ${tab.name} script tab`);
        const closeIcon = document.createElement('span');
        closeIcon.className = 'close-icon';
        closeIcon.setAttribute('aria-hidden', 'true');
        close.appendChild(closeIcon);
        close.addEventListener('click', (event) => {
          event.stopPropagation();
          closeTab(tab.id);
        });
        control.append(button, close);
        tabsElement.insertBefore(control, newTabButton);
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

    function closeTab(id) {
      const active = id === state.activeId;
      if (active) captureEditor();
      const index = state.tabs.findIndex((tab) => tab.id === id);
      if (index < 0) return;
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
      if (active) {
        const next = Math.min(index, state.tabs.length - 1);
        state.activeId = state.tabs[next].id;
      }
      renderTabs();
      if (active) restoreEditor(true);
      persist();
      closeMenus();
    }

    function closeActiveTab() {
      closeTab(state.activeId);
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
      saveQueryButton.disabled = busy;
      saveOutputButton.disabled = busy || !outputState.exportable;
      saveQueryButton.setAttribute(
        'aria-disabled',
        String(saveQueryButton.disabled)
      );
      saveOutputButton.setAttribute(
        'aria-disabled',
        String(saveOutputButton.disabled)
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

    function resultPathFromInput(value, mark = null) {
      const path = relativePathFromInput(value, 'results');
      if (!path || !mark || path[path.length - 1] === mark) return path;
      return [...path, mark];
    }

    function displayScriptPath(path) {
      return path[0] === 'scripts' ? path.slice(1).join('/') :
        path.join('/');
    }

    function suggestScriptPath(tab) {
      if (tab.path) return tab.path.slice(1).join('/');
      return tab.name.replace(/\s+\(\d+\)$/, '');
    }

    function tabStorageRoot(tab) {
      return tab.path && tab.path[0] === 'results' ? 'results' : 'scripts';
    }

    function closeFileDialog() {
      if (fileDialog.open) fileDialog.close();
      selectedFilePath = null;
      resultsFormatField.classList.add('hidden');
    }

    function samePath(left, right) {
      return left.length === right.length && left.every((part, index) => {
        return part === right[index];
      });
    }

    function explorerFileParent(entry) {
      const result = entry.kind === 'file' && entry.path[0] === 'results';
      return entry.path.slice(0, result ? -2 : -1);
    }

    function childFileEntries(parent) {
      return explorerFileEntries.filter((entry) => {
        return Array.isArray(entry.path) &&
          samePath(explorerFileParent(entry), parent);
      });
    }

    function neededExplorerDirectory(directory, entries) {
      return entries.some((entry) => {
        if (entry.kind !== 'file') return false;
        const parent = explorerFileParent(entry);
        return directory.path.length <= parent.length &&
          samePath(directory.path, parent.slice(0, directory.path.length));
      });
    }

    function explorerFileLabel(entry) {
      const result = entry.kind === 'file' && entry.path[0] === 'results';
      return entry.path.slice(result ? -2 : -1).join('/');
    }

    function fileExpansion(path, details) {
      const key = pathKey(path);
      details.open = !state.filesCollapsed.includes(key);
      details.addEventListener('toggle', () => {
        const collapsed = new Set(state.filesCollapsed);
        if (details.open) collapsed.delete(key);
        else collapsed.add(key);
        state.filesCollapsed = Array.from(collapsed);
        persist();
      });
    }

    function renderExplorerFile(entry) {
      if (entry.kind === 'directory') {
        const details = document.createElement('details');
        details.className = 'file-node';
        details.setAttribute('role', 'treeitem');
        fileExpansion(entry.path, details);
        const summary = document.createElement('summary');
        summary.textContent = entry.path[entry.path.length - 1];
        const children = document.createElement('div');
        children.className = 'file-children';
        children.setAttribute('role', 'group');
        childFileEntries(entry.path).forEach((child) => {
          children.appendChild(renderExplorerFile(child));
        });
        details.append(summary, children);
        return details;
      }
      const button = document.createElement('button');
      button.type = 'button';
      button.className = 'file-entry explorer-file';
      button.setAttribute('role', 'treeitem');
      button.textContent = explorerFileLabel(entry);
      button.title = entry.path.join('/');
      button.addEventListener('click', () => {
        loadFilePath(entry.path);
      });
      return button;
    }

    function renderFiles(entries) {
      const candidates = entries.filter((entry) => {
        return Array.isArray(entry.path) &&
          ['scripts', 'results'].includes(entry.path[0]);
      });
      explorerFileEntries = candidates.filter((entry) => {
        return entry.kind !== 'directory' ||
          neededExplorerDirectory(entry, candidates);
      });
      filesTree.replaceChildren();
      const roots = childFileEntries([]);
      if (roots.length === 0) {
        const empty = document.createElement('p');
        empty.className = 'empty-state';
        empty.textContent = 'No saved scripts or results.';
        filesTree.appendChild(empty);
      } else {
        roots.forEach((entry) => {
          filesTree.appendChild(renderExplorerFile(entry));
        });
      }
      filesTree.setAttribute('aria-busy', 'false');
    }

    async function refreshFiles() {
      filesTree.setAttribute('aria-busy', 'true');
      try {
        const body = await api('file-browse', {path: []});
        const entries = Array.isArray(body.entries) ? body.entries : [];
        renderFiles(entries);
      } catch (error) {
        filesTree.replaceChildren();
        const failure = document.createElement('p');
        failure.className = 'error-pane';
        failure.textContent = error.message;
        filesTree.appendChild(failure);
        filesTree.setAttribute('aria-busy', 'false');
      }
    }

    function docsTabById(id) {
      return state.docsTabs.find((tab) => tab.id === id) || null;
    }

    function validExplorerView(view) {
      return ['schemas', 'files'].includes(view) ||
        Boolean(docsTabById(view));
    }

    function setExplorerView(view, focus = false) {
      const selected = validExplorerView(view) ? view : 'schemas';
      const schemas = selected === 'schemas';
      const files = selected === 'files';
      state.explorerView = selected;
      schemasTab.classList.toggle('active', schemas);
      filesTab.classList.toggle('active', files);
      schemasTab.parentElement.classList.toggle('active', schemas);
      filesTab.parentElement.classList.toggle('active', files);
      schemasTab.setAttribute('aria-selected', String(schemas));
      filesTab.setAttribute('aria-selected', String(files));
      schemasTab.tabIndex = schemas ? 0 : -1;
      filesTab.tabIndex = files ? 0 : -1;
      schemaPanel.hidden = !schemas;
      filesPanel.hidden = !files;
      explorerTabs.querySelectorAll('.docs-tab').forEach((button) => {
        const active = button.dataset.explorerView === selected;
        button.classList.toggle('active', active);
        button.setAttribute('aria-selected', String(active));
        button.tabIndex = active ? 0 : -1;
        button.parentElement.classList.toggle('active', active);
      });
      schemaPane.querySelectorAll('.docs-panel').forEach((panel) => {
        panel.hidden = panel.id !== `docs-panel-${selected}`;
      });
      persist();
      if (focus) {
        const target = Array.from(
          explorerTabs.querySelectorAll('[role="tab"]')
        ).find((tab) => tab.dataset.explorerView === selected);
        if (target) target.focus();
      }
    }

    function explorerTabKeydown(event) {
      if (!['ArrowLeft', 'ArrowRight', 'Home', 'End'].includes(event.key)) {
        return;
      }
      event.preventDefault();
      const tabs = Array.from(
        explorerTabs.querySelectorAll('[role="tab"]')
      );
      const current = Math.max(0, tabs.indexOf(event.currentTarget));
      let next = current;
      if (event.key === 'ArrowLeft') next = Math.max(0, current - 1);
      if (event.key === 'ArrowRight') {
        next = Math.min(tabs.length - 1, current + 1);
      }
      if (event.key === 'Home') next = 0;
      if (event.key === 'End') next = tabs.length - 1;
      setExplorerView(tabs[next].dataset.explorerView, true);
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
      resultsFormatField.classList.add('hidden');
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
      closeSaveContext();
      const root = tabStorageRoot(activeTab());
      fileDialogMode = root === 'results' ? 'save-result-as' : 'save-as';
      selectedFilePath = null;
      fileDialogTitle.textContent = root === 'results' ?
        'Save result as' : 'Save script as';
      fileDialogHelp.textContent =
        'Use lower-case letters, digits, and hyphens in each path part.';
      fileDialogList.classList.add('hidden');
      filePathLabel.classList.remove('hidden');
      filePathLabel.textContent = root === 'results' ?
        'Result path' : 'Script path';
      filePathInput.classList.remove('hidden');
      resultsFormatField.classList.add('hidden');
      filePathInput.value = suggestScriptPath(activeTab());
      fileDialogConfirm.textContent = 'Save';
      fileDialogConfirm.disabled = false;
      fileDialog.showModal();
      filePathInput.focus();
      filePathInput.select();
    }

    function nextResultName(entries) {
      const names = new Set(entries.filter((entry) => {
        return Array.isArray(entry.path) && entry.path.length >= 2 &&
          entry.path[0] === 'results';
      }).map((entry) => entry.path[1]));
      let number = 1;
      while (names.has(`results-${number}`)) number += 1;
      return `results-${number}`;
    }

    async function showSaveResultsDialog() {
      if (busy || !outputState.exportable) return;
      closeMenus();
      closeSaveContext();
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
      filePathInput.value = outputState.path ?
        outputState.path.slice(1).join('/') : nextResultName(entries);
      const showFormat = outputState.kind === 'run';
      resultsFormatField.classList.toggle('hidden', !showFormat);
      resultsFormatSelect.value = showFormat ?
        (outputState.format || '%csv') : '%tape';
      fileDialogConfirm.textContent = 'Save';
      fileDialogConfirm.disabled = false;
      fileDialog.showModal();
      filePathInput.focus();
      filePathInput.select();
    }

    async function loadFilePath(filePath, closeDialog = false) {
      if (busy || !filePath) return;
      const path = filePath.slice();
      const existing = state.tabs.find((tab) => {
        return tab.path && pathKey(tab.path) === pathKey(path);
      });
      if (existing) {
        if (closeDialog) closeFileDialog();
        activateTab(existing.id, true);
        setStatus(`${displayScriptPath(path)} is already open.`);
        return;
      }
      setBusy(true, 'open');
      try {
        const body = await api('file-load', {path});
        addFileTab(body.path, body.content);
        if (closeDialog) closeFileDialog();
        setStatus(`${displayScriptPath(body.path)} opened.`);
      } catch (error) {
        setStatus(error.message, 'error', true);
      } finally {
        setBusy(false);
      }
    }

    async function openSelectedFile() {
      if (!selectedFilePath) return;
      await loadFilePath(selectedFilePath, true);
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
        await refreshFiles();
        setStatus(`${displayScriptPath(body.path)} saved.`);
        return true;
      } catch (error) {
        const overwriteMessage =
          `${displayScriptPath(path)} exists. Overwrite it?`;
        if (!overwrite && error.status === 409 &&
            window.confirm(overwriteMessage)) {
          setBusy(false);
          return await saveTab(tab, path, true);
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
      const root = tabStorageRoot(activeTab());
      const path = root === 'results' ?
        resultPathFromInput(filePathInput.value) :
        scriptPathFromInput(filePathInput.value);
      if (!path) {
        fileDialogHelp.textContent = root === 'results' ?
          'Invalid path. Use names like folder/result-name.' :
          'Invalid path. Use names like folder/script-name.';
        filePathInput.focus();
        return;
      }
      const saved = await saveTab(activeTab(), path, false);
      if (saved) closeFileDialog();
    }

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

    function selectedResultsFormat() {
      return resultsFormatSelect.value || '%csv';
    }

    function resultSaveText(format) {
      if (outputState.kind === 'parse') {
        return ensureTrailingNewline(outputState.text);
      }
      const command = Number.isInteger(outputState.activeCommand) ?
        outputState.commands[outputState.activeCommand] : null;
      const exports = command && command.exports &&
        typeof command.exports === 'object' ? command.exports : {};
      const exportKey = String(format || '').replace(/^%/, '');
      return Object.prototype.hasOwnProperty.call(exports, exportKey) ?
        ensureTrailingNewline(String(exports[exportKey])) : null;
    }

    async function saveResultsFile(path, overwrite, format) {
      if (busy || !outputState.exportable) return false;
      const content = resultSaveText(format);
      if (content === null) {
        setStatus(`Results are unavailable as ${format}.`, 'error', true);
        return false;
      }
      setBusy(true, 'save-results');
      try {
        const body = await api('file-save', {path, content, overwrite});
        outputState.path = body.path.slice();
        outputState.format = format;
        await refreshFiles();
        setStatus(`${body.path.slice(1).join('/')} saved.`);
        return true;
      } catch (error) {
        const name = path.slice(1).join('/');
        if (!overwrite && error.status === 409 &&
            window.confirm(`${name} exists. Overwrite it?`)) {
          setBusy(false);
          return await saveResultsFile(path, true, format);
        }
        setStatus(error.message, 'error', true);
        return false;
      } finally {
        setBusy(false);
      }
    }

    async function saveResultsFromDialog() {
      const format = outputState.kind === 'run' ?
        selectedResultsFormat() : '%tape';
      const mark = resultFormatMarks[format];
      const path = resultPathFromInput(filePathInput.value, mark);
      if (!path) {
        fileDialogHelp.textContent =
          'Invalid path. Use names like folder/results-name.';
        filePathInput.focus();
        return;
      }
      const saved = await saveResultsFile(path, false, format);
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
      if (text) addDraft(text);
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
      relation.columns.forEach((column) => {
        children.appendChild(renderColumn(column, relation));
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

    function schemaTerm(value) {
      return String(value || '').replace(/^%/, '');
    }

    function foreignKeyRow(row) {
      const values = {};
      (Array.isArray(row) ? row : []).forEach((cell) => {
        values[cell.name] = cell.value;
      });
      return {
        parentNamespace: schemaTerm(values['parent-namespace']),
        parentTable: schemaTerm(values['parent-table']),
        childNamespace: schemaTerm(values['child-namespace']),
        childTable: schemaTerm(values['child-table']),
        ordinal: Number(String(values.ordinal || '0').replaceAll('.', '')),
        parentColumn: schemaTerm(values['parent-column']),
        childColumn: schemaTerm(values['child-column']),
        onDelete: schemaTerm(values['on-delete']),
        onUpdate: schemaTerm(values['on-update'])
      };
    }

    function attachForeignKeys(database, commands) {
      const resultSet = allResultSets(commands)[0];
      if (!resultSet || !Array.isArray(resultSet.rows)) return;
      resultSet.rows.map(foreignKeyRow).forEach((foreignKey) => {
        const namespace = database.namespaces.find((candidate) => {
          return candidate.name === foreignKey.childNamespace;
        });
        if (!namespace) return;
        const relation = namespace.relations.find((candidate) => {
          return candidate.kind === 'table' &&
            candidate.name === foreignKey.childTable;
        });
        if (!relation) return;
        if (!Array.isArray(relation.foreignKeys)) relation.foreignKeys = [];
        relation.foreignKeys.push(foreignKey);
      });
    }

    async function loadForeignKeys(schema) {
      for (const database of schema.databases) {
        if (database.name === 'sys' ||
            foreignKeysUnavailable.has(database.name)) continue;
        const script = `FROM ${database.name}.sys.foreign-keys\n` +
          `SELECT parent-namespace, parent-table, child-namespace, ` +
          `child-table, ordinal, parent-column, child-column, ` +
          `on-delete, on-update;`;
        try {
          const body = await api('run', {
            defaultDatabase: database.name,
            script
          });
          attachForeignKeys(database, body.commands || []);
        } catch (error) {
          if (String(error.message).includes('foreign-keys does not exist')) {
            foreignKeysUnavailable.add(database.name);
          }
        }
      }
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
        await loadForeignKeys(schema);
        if (schemaValue === schema) renderSchema(schemaValue);
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

    function commandIsExportable(command) {
      return resultSetsForCommand(command).some((resultSet) => {
        return Array.isArray(resultSet.columns) &&
          resultSet.columns.length > 0;
      });
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
        pager.append(status, previous, next);
        return pager;
      }
      const topPager = makePager('top');
      const bottomPager = makePager('bottom');
      function renderPage() {
        const first = page * resultPageSize;
        const last = Math.min(first + resultPageSize, rows.length);
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
      messagesTab.addEventListener('click', () => selectTab(false));
      tabList.append(resultsTab, messagesTab);
      group.append(tabList, resultPanel, messagePanel);
      return group;
    }

    function renderCommandTabs(commands) {
      const container = document.createElement('div');
      container.className = 'command-tab-set';
      const tabList = document.createElement('div');
      tabList.className = 'command-tabs';
      tabList.setAttribute('role', 'tablist');
      tabList.setAttribute('aria-label', 'Command results');
      const tabs = [];
      const panels = [];
      function selectCommand(selected) {
        tabs.forEach((tab, position) => {
          const active = position === selected;
          tab.setAttribute('aria-selected', String(active));
          tab.tabIndex = active ? 0 : -1;
          panels[position].hidden = !active;
        });
        outputState.activeCommand = selected;
        outputState.exportable = commandIsExportable(commands[selected]);
        lastOutputText = runCopyText([commands[selected]]);
        updateOutputControls();
      }
      commands.forEach((command, position) => {
        const commandIndex = Number.isInteger(command.index) ?
          command.index + 1 : position + 1;
        const tab = document.createElement('button');
        const panel = document.createElement('div');
        const tabId = `command-tab-${position}`;
        const panelId = `command-tab-panel-${position}`;
        tab.type = 'button';
        tab.id = tabId;
        tab.className = 'command-tab';
        tab.textContent = `Command ${commandIndex}`;
        tab.setAttribute('role', 'tab');
        tab.setAttribute('aria-controls', panelId);
        panel.id = panelId;
        panel.className = 'command-tab-panel';
        panel.setAttribute('role', 'tabpanel');
        panel.setAttribute('aria-labelledby', tabId);
        panel.appendChild(renderCommand(command, position, false));
        tab.addEventListener('click', () => selectCommand(position));
        tabs.push(tab);
        panels.push(panel);
        tabList.appendChild(tab);
        container.appendChild(panel);
      });
      container.prepend(tabList);
      selectCommand(0);
      return container;
    }

    function revealOutput() {
      state.outputOpen = true;
      applyLayout();
      persist();
      updateOutputControls();
    }

    function showRunOutput(commands) {
      const safeCommands = Array.isArray(commands) ? commands : [];
      const activeCommand = safeCommands.length > 0 ? 0 : null;
      const exportable = activeCommand === null ? false :
        commandIsExportable(safeCommands[activeCommand]);
      outputState = {
        kind: 'run',
        commands: safeCommands,
        activeCommand,
        text: '',
        exportable,
        path: null,
        format: null
      };
      lastOutputText = runCopyText(safeCommands);
      results.replaceChildren();
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
        commands: [],
        activeCommand: null,
        text: value,
        exportable: value.length > 0,
        path: null,
        format: null
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
        activeCommand: null,
        text: value,
        exportable: false,
        path: null,
        format: null
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

    function directSaveAvailable(kind) {
      if (kind === 'script') {
        const tab = activeTab();
        return Boolean(tab.path) && tab.savedText !== null &&
          tab.text !== tab.savedText;
      }
      return kind === 'result' && outputState.exportable &&
        Array.isArray(outputState.path);
    }

    function closeSaveContext(restoreFocus = false) {
      saveContextMenu.classList.add('hidden');
      if (saveContextSource) {
        saveContextSource.setAttribute('aria-expanded', 'false');
        if (restoreFocus) saveContextSource.focus();
      }
      saveContextKind = null;
      saveContextSource = null;
    }

    function openSaveContext(kind, event) {
      if (busy || (kind === 'result' && !outputState.exportable)) return;
      captureEditor();
      closeMenus();
      closeRelationMenu();
      closeSaveContext();
      saveContextKind = kind;
      saveContextSource = kind === 'script' ?
        saveQueryButton : saveOutputButton;
      saveContextSave.disabled = !directSaveAvailable(kind);
      saveContextSaveAs.disabled = false;
      saveContextSource.setAttribute('aria-expanded', 'true');
      saveContextMenu.style.left = '0px';
      saveContextMenu.style.top = '0px';
      saveContextMenu.classList.remove('hidden');
      const menuRect = saveContextMenu.getBoundingClientRect();
      const sourceRect = saveContextSource.getBoundingClientRect();
      const margin = 8;
      let left = event.clientX;
      let top = event.clientY;
      if (left === 0 && top === 0) {
        left = sourceRect.left;
        top = sourceRect.bottom;
      }
      if (left + menuRect.width > window.innerWidth - margin) {
        left -= menuRect.width;
      }
      if (top + menuRect.height > window.innerHeight - margin) {
        top -= menuRect.height;
      }
      left = clamp(left, margin, window.innerWidth - menuRect.width - margin);
      top = clamp(top, margin, window.innerHeight - menuRect.height - margin);
      saveContextMenu.style.left = `${left}px`;
      saveContextMenu.style.top = `${top}px`;
      const first = saveContextMenu.querySelector(
        '[role="menuitem"]:not(:disabled)'
      );
      if (first) first.focus();
    }

    async function directSaveFromContext() {
      const kind = saveContextKind;
      const path = kind === 'result' && outputState.path ?
        outputState.path.slice() : null;
      closeSaveContext();
      if (kind === 'script') await saveActiveTab();
      else if (path) {
        await saveResultsFile(path, true, outputState.format || '%csv');
      }
    }

    function saveAsFromContext() {
      const kind = saveContextKind;
      closeSaveContext();
      if (kind === 'script') showSaveAsDialog();
      else if (kind === 'result') showSaveResultsDialog();
    }

    function renderDocsHelpTree() {
      docsHelpTree.replaceChildren();
      docsHelpSections.forEach((section, index) => {
        if (!section.title) {
          section.children.forEach((child) => {
            docsHelpTree.appendChild(renderDocsHelpNode(child));
          });
          return;
        }
        const branch = document.createElement('details');
        branch.className = 'docs-help-branch';
        branch.setAttribute('role', 'treeitem');
        branch.open = index === 0;
        const summary = document.createElement('summary');
        summary.textContent = section.title;
        const group = document.createElement('div');
        group.className = 'docs-help-group';
        group.setAttribute('role', 'group');
        section.children.forEach((child) => {
          group.appendChild(renderDocsHelpNode(child));
        });
        branch.append(summary, group);
        docsHelpTree.appendChild(branch);
      });
    }

    function renderDocsHelpNode(node) {
      if (node.path) {
        const link = document.createElement('a');
        link.className = 'docs-help-link';
        link.href = `/docs/d/obelisk/${node.path}`;
        link.setAttribute('role', 'treeitem');
        link.textContent = node.title;
        link.addEventListener('click', (event) => {
          event.preventDefault();
          openDocsTab(node.title, node.path);
        });
        return link;
      }
      const directory = document.createElement('div');
      directory.className = 'docs-help-static';
      directory.setAttribute('role', 'treeitem');
      const label = document.createElement('div');
      label.className = 'docs-help-label';
      label.textContent = node.title;
      const children = document.createElement('div');
      children.className = 'docs-help-static-children';
      children.setAttribute('role', 'group');
      node.children.forEach((child) => {
        children.appendChild(renderDocsHelpNode(child));
      });
      directory.append(label, children);
      return directory;
    }

    function docsTitleNodes(documentTitle) {
      const ignored = new Set(['Docs', 'Obelisk', 'User Docs']);
      return String(documentTitle || '').split(/\s*(?:>|\/)\s*/)
        .map((node) => {
          return node.trim();
        }).filter((node) => node && !ignored.has(node));
    }

    function docsTabLabel(documentTitle) {
      const nodes = docsTitleNodes(documentTitle);
      return nodes.length > 0 ? nodes[nodes.length - 1] : 'Docs';
    }

    function docsTabTrail(documentTitle) {
      const aliases = new Map([
        ['Data Definition Language', 'DDL'],
        ['Data Manipulation Language', 'DML']
      ]);
      const nodes = docsTitleNodes(documentTitle).map((node) => {
        return aliases.get(node) || node;
      });
      const languageIndex = nodes.findIndex((node) => {
        return node === 'DDL' || node === 'DML';
      });
      if (languageIndex > 0) {
        return nodes.slice(languageIndex - 1).join(' > ');
      }
      return nodes.length > 0 ? nodes.slice(-2).join(' > ') : 'Docs';
    }

    function createDocsTab(tab) {
      const control = document.createElement('div');
      control.id = `docs-control-${tab.id}`;
      control.className = 'docs-tab-control';
      control.setAttribute('role', 'presentation');
      const button = document.createElement('button');
      button.type = 'button';
      button.id = `explorer-${tab.id}`;
      button.className = 'explorer-tab docs-tab';
      button.dataset.explorerView = tab.id;
      button.setAttribute('role', 'tab');
      button.setAttribute('aria-controls', `docs-panel-${tab.id}`);
      button.setAttribute('aria-selected', 'false');
      button.tabIndex = -1;
      button.textContent = docsTabLabel(tab.documentTitle);
      button.title = docsTabTrail(tab.documentTitle);
      button.addEventListener('click', () => setExplorerView(tab.id));
      button.addEventListener('keydown', explorerTabKeydown);
      const close = document.createElement('button');
      close.type = 'button';
      close.className = 'docs-tab-close';
      close.title = 'Close';
      close.setAttribute(
        'aria-label', `Close ${docsTabLabel(tab.documentTitle)} document tab`
      );
      const closeIcon = document.createElement('span');
      closeIcon.className = 'close-icon';
      closeIcon.setAttribute('aria-hidden', 'true');
      close.appendChild(closeIcon);
      close.addEventListener('click', (event) => {
        event.stopPropagation();
        closeDocsTab(tab.id);
      });
      control.append(button, close);
      explorerTabs.appendChild(control);

      const panel = document.createElement('div');
      panel.id = `docs-panel-${tab.id}`;
      panel.className = 'explorer-panel docs-panel';
      panel.setAttribute('role', 'tabpanel');
      panel.setAttribute('aria-labelledby', button.id);
      panel.hidden = true;
      const frame = document.createElement('iframe');
      frame.className = 'docs-frame';
      frame.title = tab.documentTitle;
      let titleObserver = null;
      const syncFrameState = () => {
        try {
          const documentTitle = frame.contentDocument.title.trim();
          let changed = false;
          if (documentTitle && documentTitle !== tab.documentTitle) {
            tab.documentTitle = documentTitle;
            button.textContent = docsTabLabel(documentTitle);
            button.title = docsTabTrail(documentTitle);
            frame.title = documentTitle;
            close.setAttribute(
              'aria-label',
              `Close ${docsTabLabel(documentTitle)} document tab`
            );
            changed = true;
          }
          const prefix = '/docs/d/obelisk/';
          const pathname = frame.contentWindow.location.pathname;
          if (pathname.startsWith(prefix)) {
            const path = pathname.slice(prefix.length);
            if (path && path !== tab.path) {
              tab.path = path;
              changed = true;
            }
          }
          if (changed) persist();
        } catch (_) {
          //  Keep the selected Help title if the frame is not same-origin.
        }
      };
      frame.addEventListener('load', () => {
        if (titleObserver) titleObserver.disconnect();
        syncFrameState();
        try {
          const titleRoot = frame.contentDocument.head ||
            frame.contentDocument.documentElement;
          if (!titleRoot) return;
          titleObserver = new MutationObserver(syncFrameState);
          titleObserver.observe(titleRoot, {
            childList: true,
            characterData: true,
            subtree: true
          });
        } catch (_) {
          titleObserver = null;
        }
      });
      frame.src = `/docs/d/obelisk/${tab.path}`;
      panel.appendChild(frame);
      schemaPane.appendChild(panel);
    }

    function renderDocsTabs() {
      explorerTabs.querySelectorAll('.docs-tab-control').forEach((node) => {
        node.remove();
      });
      schemaPane.querySelectorAll('.docs-panel').forEach((node) => {
        node.remove();
      });
      state.docsTabs.forEach(createDocsTab);
    }

    function openDocsTab(documentTitle, path) {
      const tab = {
        id: `docs-${state.nextDocs++}`,
        documentTitle,
        path
      };
      state.docsTabs.push(tab);
      createDocsTab(tab);
      if (!state.schemaOpen) {
        state.schemaOpen = true;
        applyLayout();
      }
      setHelpOpen(false);
      setExplorerView(tab.id, true);
    }

    function closeDocsTab(id) {
      const index = state.docsTabs.findIndex((tab) => tab.id === id);
      if (index < 0) return;
      const wasActive = state.explorerView === id;
      state.docsTabs.splice(index, 1);
      byId(`docs-control-${id}`).remove();
      byId(`docs-panel-${id}`).remove();
      if (wasActive) {
        const view = index > 0 ? state.docsTabs[index - 1].id : 'files';
        setExplorerView(view, true);
      } else {
        persist();
      }
    }

    function setHelpVariant(useDocs) {
      fallbackHelpContent.classList.toggle('hidden', useDocs);
      docsHelpContent.classList.toggle('hidden', !useDocs);
    }

    async function refreshHelpVariant() {
      if (docsCheckPending || docsAvailable === true) return;
      docsCheckPending = true;
      try {
        const response = await fetch('/docs', {
          method: 'GET',
          credentials: 'same-origin',
          cache: 'no-store'
        });
        const responseUrl = new URL(response.url, window.location.origin);
        const contentType = response.headers.get('content-type') || '';
        docsAvailable = response.ok &&
          responseUrl.origin === window.location.origin &&
          responseUrl.pathname.startsWith('/docs') &&
          contentType.includes('text/html');
      } catch (_) {
        docsAvailable = false;
      } finally {
        docsCheckPending = false;
      }
      setHelpVariant(docsAvailable);
    }

    function setHelpOpen(open, restoreFocus = false) {
      helpPanel.hidden = !open;
      helpButton.setAttribute('aria-expanded', String(open));
      if (open) {
        setHelpVariant(docsAvailable === true);
        refreshHelpVariant();
        closeHelpButton.focus();
      }
      if (!open && restoreFocus) helpButton.focus();
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
      schemaResizer.classList.toggle('inactive', !state.schemaOpen);
      outputResizer.classList.toggle('inactive', !state.outputOpen);
      schemaResizer.disabled = !state.schemaOpen;
      outputResizer.disabled = !state.outputOpen;
      schemaCollapse.setAttribute('aria-expanded', String(state.schemaOpen));
      outputCollapse.setAttribute('aria-expanded', String(state.outputOpen));
      schemaCollapse.setAttribute('aria-label', state.schemaOpen ?
        'Collapse explorer' : 'Expand explorer');
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
    saveQueryButton.addEventListener('click', (event) => {
      openSaveContext('script', event);
    });
    saveOutputButton.addEventListener('click', showSaveResultsDialog);
    saveContextSave.addEventListener('click', directSaveFromContext);
    saveContextSaveAs.addEventListener('click', saveAsFromContext);
    saveContextMenu.addEventListener('keydown', menuKeydown);
    copyQueryButton.addEventListener('click', () => {
      captureEditor();
      copyText(activeTab().text, 'Script');
    });
    copyOutputButton.addEventListener('click', () => {
      copyText(lastOutputText, 'Results');
    });
    helpButton.addEventListener('click', () => setHelpOpen(true));
    closeHelpButton.addEventListener('click', () => {
      setHelpOpen(false, true);
    });
    helpPanel.addEventListener('click', (event) => {
      if (event.target === helpPanel) setHelpOpen(false, true);
    });
    defaultDatabase.addEventListener('change', () => {
      state.defaultDatabase = defaultDatabase.value;
      persist();
      refreshSchema();
    });
    schemasTab.addEventListener('click', () => {
      setExplorerView('schemas');
    });
    filesTab.addEventListener('click', () => {
      setExplorerView('files');
    });
    schemasTab.addEventListener('keydown', explorerTabKeydown);
    filesTab.addEventListener('keydown', explorerTabKeydown);
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
      if (!event.target.closest('#save-context-menu') &&
          !event.target.closest('.save-action')) {
        closeSaveContext();
      }
      if (!event.target.closest('#relation-menu') &&
          !event.target.closest('.relation-actions')) {
        closeRelationMenu();
      }
    });
    document.addEventListener('keydown', (event) => {
      if (event.key === 'Escape') {
        if (!helpPanel.hidden) {
          setHelpOpen(false, true);
          return;
        }
        if (!saveContextMenu.classList.contains('hidden')) {
          closeSaveContext(true);
          return;
        }
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
    defaultDatabase.value = state.defaultDatabase || 'sys';
    renderTabs();
    restoreEditor(false);
    renderDocsHelpTree();
    renderDocsTabs();
    refreshHelpVariant();
    setExplorerView(state.explorerView);
    applyLayout();
    setBusy(false);
    refreshSchema();
    refreshFiles();
    document.documentElement.dataset.obelisk = 'ready';

    window.ObeliskWorkbench = {
      api,
      addDraft,
      addFileTab,
      activateTab,
      closeActiveTab,
      closeDocsTab,
      execute,
      getState: () => state,
      openRelationAction,
      openDocsTab,
      persist,
      refreshFiles,
      refreshHelpVariant,
      refreshSchema,
      relationTemplate,
      renderCommand,
      runCopyText,
      runExportText,
      saveActiveTab,
      openSaveContext,
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
