::  urui-css: the shared stylesheet, in composable sections.
::
::  Each arm is one cord of css text.  A consumer composes the sections
::  it wants and welds its own application rules after them, so the
::  cascade order stays the consumer's decision.
::
::  Put %controls before component sections so their equally specific
::  selectors can override base control dimensions. Put %responsive last.
::
::  The frame ++compact emits is deliberately unstyled here — no rule
::  names .pane-title or .pane-actions — and so is the Ace host,
::  .editor-host.  A consumer of the compact shell brings its own.
::
::  .pane-body is the exception: every %panel band emits one, in both
::  frames, and what a consumer puts inside it expects to be a flex item
::  of a filled column.  Sizing it is urui's job, not the consumer's.
::
|%
::
+$  section
  ::  The available css sections; consumers choose their cascade order.
  ::
  $?  %tokens  %shell  %explorer  %tabs
      %dialogs  %controls  %responsive
  ==
::
++  tokens
  ::  Every custom property, on :root and its dark override, keyed to the
  ::  `data-effective-theme` ++theme-bootstrap sets before first paint.
  ::  --editor-width and --explorer-width are declared here and rewritten
  ::  inline by the runtime's layout section.
  ^-  @t
  '''
  :root {
    color-scheme: light;
    --background: #f4f4f5;
    --surface: #ffffff;
    --surface-alt: #fafafa;
    --border: #d4d4d8;
    --ink: #18181b;
    --muted: #71717a;
    --accent: #2563eb;
    --accent-text: #ffffff;
    --focus: #93c5fd;
    --danger: #b91c1c;
    --danger-background: #fef2f2;
    --danger-border: #fecaca;
    --editor-error: #fee2e2;
    --preview-background: #ffffff;
    --preview-grid: #d4d4d8;
    --floating-control: rgb(255 255 255 / 0.9);
    --selection-hover: #2563eb;
    --selection-active: #f59e0b;
    --spinner-track: #bfdbfe;
    --state-ink: #52525b;
    --state-title: #27272a;
    --inspector-background: #fffbeb;
    --inspector-border: #fde68a;
    --inspector-ink: #78350f;
    --editor-width: 44%;
  }

  :root[data-effective-theme='dark'] {
    color-scheme: dark;
    --background: #11110f;
    --surface: #191917;
    --surface-alt: #22221f;
    --border: #3b3b35;
    --ink: #f2f2ec;
    --muted: #a7a79e;
    --accent: #8b5cf6;
    --accent-text: #ffffff;
    --focus: #60a5fa;
    --danger: #f87171;
    --danger-background: #35191d;
    --danger-border: #7f1d1d;
    --editor-error: #3f1d24;
    --preview-background: #11110f;
    --preview-grid: #3b3b35;
    --floating-control: rgb(25 25 23 / 0.92);
    --selection-hover: #60a5fa;
    --selection-active: #fbbf24;
    --spinner-track: #4c1d95;
    --state-ink: #a7a79e;
    --state-title: #f2f2ec;
    --inspector-background: #33270e;
    --inspector-border: #854d0e;
    --inspector-ink: #fde68a;
  }
  '''
::
++  shell
  ::  Reset, header and toolbar, the workbench and workspace grids, panes
  ::  and pane headers, the status line, the splitter, the connection
  ::  state panel, and .sr-only.
  ^-  @t
  '''
  * { box-sizing: border-box; }

  html, body { height: 100%; }

  body {
    background: var(--background);
    color: var(--ink);
    display: grid;
    font: 16px/1.4 system-ui, sans-serif;
    grid-template-rows: auto minmax(0, 1fr);
    margin: 0;
  }

  .app-header {
    align-items: center;
    background: var(--surface);
    border-bottom: 1px solid var(--border);
    display: flex;
    gap: 1rem;
    justify-content: space-between;
    padding: 0.75rem 1rem;
  }

  .brand h1 { font-size: 1.25rem; line-height: 1.1; margin: 0; }

  .eyebrow {
    color: var(--muted);
    display: block;
    font-size: 0.7rem;
    letter-spacing: 0.08em;
    text-transform: uppercase;
  }

  .toolbar { display: flex; flex-wrap: wrap; gap: 0.5rem; }

  /* The header is `space-between`, so a third child would sit in the
     middle of it.  `margin-left: auto` absorbs that slack instead: the
     Settings button lands hard right, one header gap left of whatever
     the consumer's toolbar begins with -- its Help button, by
     convention -- so the two read as one group. */
  .settings-button { margin-left: auto; }

  .workbench {
    display: grid;
    grid-template-columns: var(--explorer-width, 18rem) 0.6rem
      minmax(0, 1fr);
    min-height: 0;
    overflow: hidden;
  }

  .workbench.explorer-collapsed {
    grid-template-columns: 3rem 0 minmax(0, 1fr);
  }

  .workspace {
    display: grid;
    grid-template-columns: minmax(18rem, var(--editor-width)) 0.6rem
      minmax(20rem, 1fr);
    min-height: 0;
    overflow: hidden;
  }

  /* Screen format. `columns` is the default and needs no rule; `rows`
     turns the same three children into editor over render, so the
     splitter it already contains becomes the horizontal one. */
  .workspace[data-layout='rows'] {
    grid-template-columns: minmax(0, 1fr);
    grid-template-rows: minmax(6rem, var(--editor-height)) 0.6rem
      minmax(6rem, 1fr);
  }

  /* Result collapse keeps the pane's heading and nothing else: a rail
     beside the editor under `columns`, a strip below it under `rows`.
     The divider custom properties are untouched, so expanding restores
     whatever size the pane had. */
  .workspace.result-collapsed {
    grid-template-columns: minmax(0, 1fr) 0 3rem;
  }

  .workspace[data-layout='rows'].result-collapsed {
    grid-template-columns: minmax(0, 1fr);
    grid-template-rows: minmax(0, 1fr) 0 auto;
  }

  [data-role='result'].collapsed { flex-direction: column; }
  [data-role='result'].collapsed > :not(.pane-header) { display: none; }

  .workspace:not([data-layout='rows']) [data-role='result'].collapsed
    .pane-header {
    justify-content: center;
    padding: 0;
  }

  .workspace:not([data-layout='rows']) [data-role='result'].collapsed
    .pane-header > :not(.pane-actions),
  .workspace:not([data-layout='rows']) [data-role='result'].collapsed
    .pane-actions > :not(.result-collapse) {
    display: none;
  }

  .pane {
    background: var(--surface);
    display: flex;
    min-height: 0;
    min-width: 0;
  }

  .pane-band { min-height: 0; min-width: 0; }

  .pane-band-label {
    color: var(--muted);
    flex: 0 0 auto;
    font-size: 0.75rem;
    padding: 0.4rem 0.75rem;
  }

  .pane-band-controls {
    align-items: center;
    display: flex;
    flex: 0 0 auto;
    flex-wrap: wrap;
    gap: 0.5rem;
    padding: 0.5rem 0.75rem;
  }

  .pane-band-panel {
    display: flex;
    flex: 1 1 auto;
    flex-direction: column;
    min-height: 0;
    overflow: hidden;
  }

  .pane-body {
    display: flex;
    flex: 1 1 auto;
    flex-direction: column;
    min-height: 0;
    min-width: 0;
  }

  .pane-band[hidden] { display: none; }

  .band-toggle {
    align-self: flex-end;
    flex: 0 0 auto;
    height: 2rem;
    margin: 0.25rem 0.5rem;
    width: 2rem;
  }

  .band-toggle::before { content: '\25b8'; }

  .band-toggle[aria-expanded='true']::before { content: '\25be'; }

  .pane-header {
    align-items: center;
    border-bottom: 1px solid var(--border);
    display: flex;
    flex-wrap: wrap;
    gap: 0.5rem;
    justify-content: space-between;
    min-height: 2.75rem;
    padding: 0.5rem 0.75rem;
  }

  .pane-header h2 { font-size: 0.9rem; margin: 0; }

  .file-actions {
    display: flex;
    flex-wrap: wrap;
    gap: 0.5rem;
    justify-content: flex-end;
    margin-left: auto;
    min-width: 0;
  }

  .status {
    color: var(--muted);
    font-size: 0.75rem;
    margin-left: 0.5rem;
  }

  .editor-body {
    flex: 1;
    min-height: 0;
    overflow: hidden;
    position: relative;
  }

  .editor-load-error {
    background: var(--danger-background);
    border: 1px solid var(--danger);
    color: var(--danger);
    display: grid;
    gap: 0.5rem;
    inset: 1rem;
    padding: 1rem;
    position: absolute;
    z-index: 1;
  }

  .editor-load-error[hidden] { display: none; }

  .splitter {
    background: var(--border);
    cursor: col-resize;
    touch-action: none;
  }

  .workspace[data-layout='rows'] .splitter { cursor: row-resize; }

  .splitter.inactive,
  .workspace[data-layout='rows'] .splitter.inactive { cursor: default; }

  .splitter:hover, .splitter:focus { background: var(--accent); }

  .splitter.inactive:hover { background: var(--border); }

  /* ---- settings ---------------------------------------------------- */

  .settings-card { gap: 1rem; }

  .settings-field {
    align-items: start;
    border: 0;
    display: grid;
    gap: 0.35rem;
    margin: 0;
    padding: 0;
  }

  .settings-label {
    font-size: 0.75rem;
    font-weight: 700;
    letter-spacing: 0.04em;
    padding: 0;
    text-transform: uppercase;
  }

  .settings-keys { display: grid; gap: 0.25rem; }

  .layout-choices { display: flex; gap: 0.75rem; }

  .layout-choice {
    background: var(--surface);
    border: 1px solid var(--border);
    border-radius: 0.35rem;
    cursor: pointer;
    padding: 0.4rem;
  }

  .layout-choice:hover { border-color: var(--accent); }

  .layout-choice[aria-pressed='true'] {
    border-color: var(--accent);
    box-shadow: 0 0 0 1px var(--accent);
  }

  /* The pictograms: three boxes in a frame, arranged by layout. */
  .layout-glyph {
    display: grid;
    gap: 2px;
    height: 2.25rem;
    width: 3rem;
  }

  .layout-glyph-columns { grid-template-columns: repeat(3, 1fr); }

  .layout-glyph-rows {
    grid-template-columns: 1fr 2fr;
    grid-template-rows: 1fr 1fr;
  }

  .layout-glyph-rows .glyph-a { grid-row: 1 / 3; }

  .glyph-cell {
    background: var(--border);
    border-radius: 1px;
  }

  .layout-choice[aria-pressed='true'] .glyph-cell { background: var(--accent); }

  .state-panel {
    align-content: center;
    color: var(--state-ink);
    display: none;
    inset: 0;
    justify-items: center;
    padding: 2rem;
    position: absolute;
    text-align: center;
    z-index: 1;
  }

  .state-panel p { margin: 0.25rem; }

  .state-title { color: var(--state-title); font-weight: 650; }

  [data-state='empty'] #empty-state,
  [data-state='loading'] #loading-state,
  [data-state='disconnected'] #disconnected-state { display: grid; }

  .spinner {
    animation: spin 0.8s linear infinite;
    border: 3px solid var(--spinner-track);
    border-radius: 50%;
    border-top-color: var(--accent);
    height: 2rem;
    width: 2rem;
  }

  @keyframes spin { to { transform: rotate(360deg); } }

  .error {
    background: var(--danger-background);
    border-bottom: 1px solid var(--danger-border);
    color: var(--danger);
    margin: 0;
    padding: 0.75rem;
    white-space: pre-wrap;
  }

  .sr-only {
    height: 1px;
    margin: -1px;
    overflow: hidden;
    position: absolute;
    width: 1px;
  }

  .editor-pane { flex-direction: column; }
  '''
::
++  explorer
  ::  The aside itself — header, collapse, panels, file-tree rows, the
  ::  resizer, and the file context menu.  Its tab strip is in %tabs.
  ^-  @t
  '''
  /* The explorer's strip and its panels are one band -- the %views case
     of %tabs -- and the pane's other bands (a %label, an unused %panel)
     are siblings whose number and order the consumer chooses.  A
     positional `grid-template-rows` cannot express that: it hands the
     1fr to whichever band happens to be second.  So the pane is a flex
     column and the band carrying the panels is the one that grows. */
  .explorer-pane {
    background: var(--surface);
    display: flex;
    flex-direction: column;
    min-height: 0;
    min-width: 0;
    overflow: hidden;
  }

  .explorer-pane > .pane-band-tabs {
    display: flex;
    flex: 1 1 auto;
    flex-direction: column;
    min-height: 0;
  }

  /* an explorer's %panel band is empty in every consumer so far; it
     must not take the space the panels need */
  .explorer-pane > .pane-band-panel { flex: 0 1 auto; }

  .explorer-header {
    align-items: stretch;
    display: flex;
    min-width: 0;
  }

  .explorer-header .explorer-tabs { flex: 1; }

  .explorer-collapse {
    border-width: 0 0 1px 1px;
    border-radius: 0;
    flex: 0 0 2.65rem;
    height: auto;
    min-height: 2.3125rem;
  }

  .explorer-pane.collapsed .explorer-tabs,
  .explorer-pane.collapsed .explorer-panel {
    display: none;
  }

  .explorer-pane.collapsed .explorer-header {
    justify-content: center;
  }

  .explorer-pane.collapsed .explorer-collapse {
    border-left: 0;
    flex-basis: 3rem;
    width: 3rem;
  }

  .explorer-panel {
    flex: 1 1 auto;
    min-height: 0;
    min-width: 0;
    overflow: hidden;
  }

  .explorer-panel[hidden] { display: none; }

  .explorer-file-tree {
    height: 100%;
    min-height: 0;
    overflow: auto;
    padding: 0.75rem;
  }

  .docs-explorer-frame {
    background: var(--surface);
    border: 0;
    height: 100%;
    width: 100%;
  }

  .ref-explorer-panel {
    overflow: auto;
    padding: 1rem;
  }

  .ref-source {
    font: 0.8rem/1.45 ui-monospace, SFMono-Regular, Consolas, monospace;
    margin: 0;
    min-width: max-content;
    white-space: pre;
  }

  .explorer-resizer {
    background: var(--border);
    border: 0;
    border-radius: 0;
    cursor: col-resize;
    padding: 0;
    touch-action: none;
  }

  .explorer-resizer:hover, .explorer-resizer:focus {
    background: var(--accent);
  }

  .explorer-resizer.inactive { cursor: default; }

  .file-context-menu {
    background: var(--surface);
    border: 1px solid var(--border);
    border-radius: 0.4rem;
    box-shadow: 0 0.7rem 2rem rgb(0 0 0 / 0.2);
    display: grid;
    min-width: 9rem;
    padding: 0.3rem;
    position: fixed;
    z-index: 60;
  }

  .file-context-menu[hidden] { display: none; }

  .file-context-menu button {
    background: transparent;
    border: 0;
    text-align: left;
  }

  .file-tree-list {
    list-style: none;
    margin: 0;
    padding-left: 1.25rem;
  }

  .explorer-file-tree > .file-tree-list { padding-left: 0; }

  .file-tree-directory {
    color: var(--muted);
    padding: 0.2rem 0;
  }

  .explorer-file-row {
    align-items: stretch;
    display: flex;
    min-width: 0;
  }

  .file-tree-file {
    background: transparent;
    border: 0;
    color: var(--accent);
    flex: 1;
    min-width: 0;
    overflow: hidden;
    padding: 0.3rem 0.5rem;
    text-align: left;
    text-overflow: ellipsis;
    white-space: nowrap;
    width: auto;
  }

  .file-tree-file:hover:not(:disabled) { background: var(--background); }

  .file-tree-actions {
    background: transparent;
    border: 0;
    color: var(--muted);
    flex: 0 0 auto;
    padding: 0.2rem 0.45rem;
  }

  .clay-error-message {
    color: var(--danger);
    overflow-wrap: anywhere;
    white-space: pre-wrap;
  }
  '''
::
++  tabs
  ::  All three strips: the explorer tabs, the docs tabs beside them, and
  ::  the document tabs in a workspace pane.
  ^-  @t
  '''
  .explorer-tabs {
    align-items: flex-start;
    border-bottom: 1px solid var(--border);
    display: flex;
    flex: 0 0 2.55rem;
    height: 2.55rem;
    min-height: 2.55rem;
    min-width: 0;
    overscroll-behavior-inline: contain;
    overflow-x: auto;
    overflow-y: hidden;
  }

  .explorer-tab-control, .docs-tab-control {
    align-items: center;
    border-right: 1px solid var(--border);
    display: inline-flex;
    flex: 0 0 auto;
    height: 2.25rem;
  }

  .docs-tab-control { position: relative; }

  .explorer-tab, .docs-tab, .docs-tab-close {
    background: transparent;
    border: 0;
    border-radius: 0;
    color: var(--muted);
    font-size: 0.75rem;
    height: 2.25rem;
    min-height: 2.25rem;
    padding-block: 0;
  }

  .explorer-tab, .docs-tab {
    max-width: 14rem;
    overflow: hidden;
    text-align: center;
    text-overflow: ellipsis;
    white-space: nowrap;
  }

  .explorer-tab {
    align-items: center;
    display: inline-flex;
    justify-content: center;
    line-height: 1;
  }

  .docs-tab {
    padding-left: 2.25rem;
    padding-right: 2.25rem;
  }

  .explorer-tab-control.active, .docs-tab-control.active {
    box-shadow: inset 0 -2px var(--accent);
  }

  .explorer-tab[aria-selected='true'],
  .docs-tab[aria-selected='true'] {
    color: var(--ink);
    font-weight: 650;
  }

  .docs-tab-close {
    bottom: 0;
    font: 700 0.75rem/1 ui-monospace, monospace;
    position: absolute;
    padding: 0.25rem 0.55rem;
    right: 0;
    top: 0;
    width: 1.75rem;
    z-index: 1;
  }

  .tab-strip[data-depth='0'] {
    --tab-font-size: 0.75rem;
    --tab-add-font-size: 1rem;
    --tab-height: 2.25rem;
    --tab-max-width: 14rem;
    --tab-strip-height: 2.55rem;
  }

  .tab-strip[data-depth='1'] {
    --tab-font-size: 0.7rem;
    --tab-add-font-size: 0.9rem;
    --tab-height: 2rem;
    --tab-max-width: 12rem;
    --tab-strip-height: 2.3rem;
  }

  .tab-strip[data-depth='2'] {
    --tab-font-size: 0.65rem;
    --tab-add-font-size: 0.8rem;
    --tab-height: 1.75rem;
    --tab-max-width: 10rem;
    --tab-strip-height: 2.05rem;
  }

  .tab-strip {
    align-items: flex-start;
    border-bottom: 1px solid var(--border);
    border-top: 1px solid var(--border);
    display: flex;
    flex: 0 0 var(--tab-strip-height, 2.55rem);
    height: var(--tab-strip-height, 2.55rem);
    min-height: var(--tab-strip-height, 2.55rem);
    min-width: 0;
    overscroll-behavior-inline: contain;
    overflow-x: auto;
    overflow-y: hidden;
  }

  .explorer-tabs::-webkit-scrollbar,
  .tab-strip::-webkit-scrollbar {
    height: 0.3rem;
  }

  .explorer-tabs::-webkit-scrollbar-track,
  .tab-strip::-webkit-scrollbar-track {
    background: transparent;
  }

  .explorer-tabs::-webkit-scrollbar-thumb,
  .tab-strip::-webkit-scrollbar-thumb {
    background: var(--muted);
    border-radius: 999px;
  }

  @supports (-moz-appearance: none) {
    .explorer-tabs, .tab-strip {
      scrollbar-color: var(--muted) transparent;
      scrollbar-width: thin;
    }
  }

  .document-tab-control {
    align-items: stretch;
    border-right: 1px solid var(--border);
    display: inline-flex;
    flex: 0 0 auto;
    height: var(--tab-height, 2.25rem);
  }

  .document-tab-control.active {
    box-shadow: inset 0 -2px var(--accent);
  }

  .document-tab-control[draggable='true'] { cursor: grab; }

  .document-tab-control.is-dragging { opacity: 0.45; }

  .document-tab, .document-tab-close, .document-tab-add {
    background: transparent;
    border: 0;
    border-radius: 0;
    color: var(--muted);
    font-size: var(--tab-font-size, 0.75rem);
    height: var(--tab-height, 2.25rem);
    min-height: var(--tab-height, 2.25rem);
    padding-block: 0;
  }

  .document-tab {
    max-width: var(--tab-max-width, 14rem);
    overflow: hidden;
    text-overflow: ellipsis;
    white-space: nowrap;
  }

  .document-tab[aria-selected='true'] {
    color: var(--ink);
    font-weight: 650;
  }

  .document-tab-close {
    font: 700 var(--tab-font-size, 0.75rem)/1 ui-monospace, monospace;
    padding: 0.25rem 0.55rem;
  }

  .document-tab-add {
    color: var(--ink);
    font-size: var(--tab-add-font-size, 1rem);
    min-width: var(--tab-height, 2.25rem);
    padding: 0.25rem 0.65rem;
  }

  .explorer-tab-control[draggable='true'],
  .docs-tab-control[draggable='true'],
  .ref-tab-control[draggable='true'] {
    cursor: grab;
  }

  .explorer-tab-control.is-dragging,
  .docs-tab-control.is-dragging,
  .ref-tab-control.is-dragging {
    opacity: 0.45;
  }
  '''
::
++  dialogs
  ::  The help panel and its card, including the documentation nav the
  ::  runtime builds from doc.toc.  The Clay error modal reuses .help-card.
  ^-  @t
  '''
  .help-panel {
    background: rgb(0 0 0 / 0.4);
    display: grid;
    inset: 0;
    padding: 1rem;
    place-items: center;
    position: fixed;
    z-index: 70;
  }

  .help-panel[hidden] { display: none; }

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

  .help-card a { color: inherit; }

  .help-card a p { margin: 0; }

  .help-skill-links {
    grid-template-columns: repeat(3, minmax(0, 1fr));
    margin-top: 1rem;
  }

  .help-skill-links a { text-align: center; }

  #fallback-help-content[hidden], .docs-help-content[hidden] {
    display: none;
  }

  .docs-help-content {
    display: grid;
    gap: 0.8rem;
  }

  .docs-help-nav {
    align-content: start;
    display: grid;
    gap: 0.4rem;
    max-height: min(32rem, calc(100vh - 15rem));
    overflow: auto;
  }

  .docs-help-link {
    border-radius: 0.3rem;
    padding: 0.45rem 0.65rem;
    text-decoration: none;
  }

  .docs-help-link:hover, .docs-help-link[aria-current="page"] {
    background: var(--surface-alt);
  }

  .docs-help-link[aria-current="page"] { font-weight: 600; }

  .docs-help-summary {
    align-items: center;
    cursor: pointer;
    display: flex;
    font-weight: 600;
    list-style: none;
    padding: 0.6rem 0.7rem;
  }

  .docs-help-summary::-webkit-details-marker { display: none; }

  .docs-help-summary:hover { background: var(--surface-alt); }

  .docs-help-summary::before {
    color: var(--muted);
    content: '\25b8';
    font-size: 0.7rem;
    margin-right: 0.5rem;
  }

  .docs-help-group[open] > .docs-help-summary::before { content: '\25be'; }

  .docs-help-group {
    border: 1px solid var(--border);
    border-radius: 0.4rem;
  }

  .docs-help-subnav {
    border-top: 1px solid var(--border);
    display: grid;
    gap: 0;
    padding: 0.3rem 0.3rem 0.3rem 1.5rem;
  }

  .docs-help-subnav .docs-help-link {
    display: block;
    font-size: 0.9rem;
    padding: 0.3rem 0.65rem;
  }

  .docs-help-subnav .docs-help-group {
    border-width: 0 0 0 1px;
    border-radius: 0;
  }

  .docs-help-loading {
    color: var(--muted);
    margin: 0;
    padding: 0.65rem;
  }

  .shortcut-list { line-height: 1.8; padding-left: 1.5rem; }
  '''
::
++  controls
  ::  Base button, select, and input dimensions, the theme control, icon
  ::  buttons, preferences, and the css-drawn copy and close icons.
  ^-  @t
  '''
  button, select, input, .preference {
    background: var(--surface);
    border: 1px solid var(--border);
    border-radius: 0.4rem;
    color: inherit;
    font: inherit;
    padding: 0.5rem 0.75rem;
  }

  button, select { cursor: pointer; }

  button:hover:not(:disabled) { border-color: var(--accent); }

  button:focus-visible, select:focus-visible, input:focus-visible,
  .help-card a:focus-visible {
    outline: 3px solid var(--focus);
  }

  button:disabled { cursor: not-allowed; opacity: 0.45; }

  .primary {
    background: var(--accent);
    border-color: var(--accent);
    color: var(--accent-text);
  }

  .theme-control {
    align-items: center;
    color: var(--muted);
    display: inline-flex;
    font-size: 0.75rem;
    gap: 0.4rem;
  }

  .theme-control select { color: var(--ink); }

  .icon-button {
    align-items: center;
    display: inline-flex;
    height: 2.65rem;
    justify-content: center;
    padding: 0;
    width: 2.65rem;
  }

  .control {
    display: grid;
    font-size: 0.7rem;
    gap: 0.2rem;
  }

  .control input, .control select {
    font-size: 0.85rem;
    min-width: 0;
    padding: 0.35rem 0.5rem;
  }

  .preference {
    align-items: center;
    display: inline-flex;
    gap: 0.4rem;
  }

  .preference input { accent-color: var(--accent); }

  .source-auto-render { margin-left: 0.5rem; white-space: nowrap; }

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

  .copy-icon::before { left: 0; top: 0; }

  .copy-icon::after {
    background: var(--floating-control);
    bottom: 0;
    right: 0;
  }

  .danger-button { color: var(--danger); }

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

  .close-icon::before { transform: rotate(45deg); }

  .close-icon::after { transform: rotate(-45deg); }
  '''
::
++  responsive
  ::  The single narrow-viewport query, at the same 760px `limits.narrow`
  ::  the runtime matches on.  Last in the cascade, by convention.
  ^-  @t
  '''
  @media (max-width: 760px) {
    body { height: auto; min-height: 100%; }

    .app-header { align-items: stretch; flex-direction: column; }
    /*  stacked, it is a full-width row like the toolbar below it */
    .settings-button { margin-left: 0; }
    .toolbar { display: grid; grid-template-columns: repeat(3, 1fr); }

    /*  The reference pane stays vertical and to the left, and the
        screen format stays whatever the user chose, at every width:
        narrow no longer restacks the panes or drops their dividers.
        Only the minimums relax, so three columns still fit. */
    .workbench { overflow: visible; }

    .workspace {
      grid-template-columns: minmax(0, var(--editor-width)) 0.6rem
        minmax(0, 1fr);
      overflow: visible;
    }

    .workspace[data-layout='rows'] {
      grid-template-columns: minmax(0, 1fr);
    }

    .help-skill-links { grid-template-columns: minmax(0, 1fr); }
  }
  '''
::
++  compose
  ::  Concatenate the named sections, in the order given.
  ::
  ::  Example:
  ::    (compose ~[%tokens %shell %explorer %tabs])
  |=  parts=(list section)
  ^-  @t
  %+  rap  3
  %+  turn  parts
  |=  name=section
  ^-  @t
  ?-  name
    %tokens      tokens
    %shell       shell
    %explorer    explorer
    %tabs        tabs
    %dialogs     dialogs
    %controls    controls
    %responsive  responsive
  ==
--
