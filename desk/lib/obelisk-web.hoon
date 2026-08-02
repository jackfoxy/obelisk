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
                ""
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
          ""
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

  .error-pane, .plain-output {
    font: 0.86rem/1.5 ui-monospace, monospace;
    margin: 0;
    overflow-wrap: anywhere;
    white-space: pre-wrap;
  }

  .error-pane {
    color: #b91c1c;
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
    const defaultDatabase = byId('default-db');
    const results = byId('results');
    const status = byId('app-status');
    let statusTimer = 0;
    let lastOutputText = '';
    let busy = false;

    function initialState() {
      return {
        version: 1,
        tabs: [{
          id: 'draft-1',
          name: 'script-1',
          path: null,
          text: '',
          selectionStart: 0,
          selectionEnd: 0
        }],
        activeId: 'draft-1',
        nextDraft: 2,
        schemaSize: 320,
        outputSize: 260,
        schemaOpen: true,
        outputOpen: true,
        defaultDatabase: 'sys'
      };
    }

    function validTab(tab) {
      return tab && typeof tab.id === 'string' &&
        typeof tab.name === 'string' && typeof tab.text === 'string' &&
        Number.isInteger(tab.selectionStart) &&
        Number.isInteger(tab.selectionEnd) &&
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
        return Object.assign(base, saved);
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
        button.textContent = tab.name;
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

    function addDraft(text = '') {
      captureEditor();
      const name = nextDraftName();
      const tab = {
        id: `draft-${state.nextDraft - 1}`,
        name,
        path: null,
        text,
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

    function setBusy(value, label = '') {
      busy = value;
      app.setAttribute('aria-busy', String(value));
      results.setAttribute('aria-busy', String(value));
      runButton.disabled = value;
      parseButton.disabled = value;
      runButton.firstElementChild.textContent = value && label === 'run' ?
        'Running…' : 'Run';
      parseButton.textContent = value && label === 'parse' ?
        'Parsing…' : 'Parse';
    }

    function errorMessage(body, fallback) {
      if (!body || body.type !== 'error' || !body.error) return fallback;
      const details = Array.isArray(body.error.details) ?
        body.error.details.join('\n') : '';
      return details ? `${body.error.message}\n${details}` :
        body.error.message;
    }

    async function api(operation, payload) {
      const response = await fetch(`/apps/obelisk/api/${operation}`, {
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
        throw new Error(errorMessage(body, fallback));
      }
      return body;
    }

    function selectedScript() {
      captureEditor();
      const tab = activeTab();
      if (tab.selectionEnd > tab.selectionStart) {
        return tab.text.slice(tab.selectionStart, tab.selectionEnd);
      }
      return tab.text;
    }

    function showOutput(text, kind = 'plain') {
      lastOutputText = text;
      results.replaceChildren();
      const pre = document.createElement('pre');
      pre.className = kind === 'error' ? 'error-pane' : 'plain-output';
      pre.textContent = text;
      results.appendChild(pre);
      copyOutputButton.disabled = text.length === 0;
      state.outputOpen = true;
      applyLayout();
      persist();
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
          showOutput(body.text || '');
          setStatus('Parse complete.');
        } else {
          showOutput(JSON.stringify(body.commands || [], null, 2));
          setStatus('Run complete.');
        }
      } catch (error) {
        const message = error instanceof Error ? error.message : String(error);
        showOutput(message, 'error');
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
    byId('close-tab-menu-item').addEventListener('click', closeActiveTab);
    runButton.addEventListener('click', () => execute('run'));
    parseButton.addEventListener('click', () => execute('parse'));
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
    });
    document.addEventListener('keydown', (event) => {
      if (event.key === 'Escape') {
        const open = menus.find((menu) => menu.dataset.open === 'true');
        closeMenus();
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

    byId('open-menu-item').disabled = true;
    byId('save-tab-menu-item').disabled = true;
    byId('save-as-menu-item').disabled = true;
    copyOutputButton.disabled = true;
    defaultDatabase.value = state.defaultDatabase;
    if (!defaultDatabase.value) {
      state.defaultDatabase = 'sys';
      defaultDatabase.value = 'sys';
    }
    renderTabs();
    restoreEditor(false);
    applyLayout();
    setBusy(false);
    document.documentElement.dataset.obelisk = 'ready';

    window.ObeliskWorkbench = {
      api,
      addDraft,
      activateTab,
      closeActiveTab,
      execute,
      getState: () => state,
      persist,
      setStatus,
      showOutput
    };
  })();
  '''
--
