::  urui-js: the shared browser runtime, as cords.
::
|%
::
++  theme-bootstrap
  ::  Read a stored theme before first paint.
  ::
  |=  [storage-key=@t version=@ud]
  ^-  @t
  =/  key  (en:json:html s+storage-key)
  =/  ver  (scot %ud version)
  %+  rap  3
  :~  '''
      (() => {
        const key =
      '''
      key
      '''
      ;
        const themes = ['system', 'light', 'dark'];
        let selected = 'system';
        try {
          const saved = JSON.parse(localStorage.getItem(key));
          const candidate = saved?.preferences?.theme;
          if (saved?.version ===
      '''
      ver
      '''
       && themes.includes(candidate)) {
            selected = candidate;
          }
        } catch (_) {
          // Storage failures must not block first paint.
        }
        const systemDark = matchMedia(
          '(prefers-color-scheme: dark)'
        ).matches;
        const effective = selected === 'system'
          ? (systemDark ? 'dark' : 'light')
          : selected;
        const root = document.documentElement;
        root.dataset.theme = selected;
        root.dataset.effectiveTheme = effective;
        root.style.colorScheme = effective;
      })();
      '''
  ==
::
++  core
  ::  Define the stable API before the consumer installs its hooks.
  ::
  ^-  @t
  %+  rap  3
  :~  '''
      (() => {
        'use strict';
        let hooks = Object.create(null);
        let booted = false;

        function hook(group, method) {
          const owner = group ? hooks[group] : hooks;
          const target = owner?.[method];
          return typeof target === 'function' ? target : undefined;
        }

        //  A facade method with no hook behind it is an error, not a
        //  silent undefined.
        function invoke(group, method, args) {
          const target = hook(group, method);
          if (!target) {
            const name = group ? `${group}.${method}` : method;
            throw new Error(`urui: no ${name} hook installed`);
          }
          return target(...args);
        }

        function methods(group, names) {
          return Object.freeze(Object.fromEntries(names.map((name) => [
            name,
            (...args) => invoke(group, name, args)
          ])));
        }

        function createAceEditorAdapter(host, options = {}) {
      '''
      editor-adapter
      '''
        }

        function createRuntime(options = {}) {
      '''
      runtime
      '''
        }

        const editor = Object.freeze({
          ...methods('editor', ['primary', 'secondary']),
          adapter: createAceEditorAdapter
        });
        const api = {
          config: Object.freeze(window.URUI_CONFIG || {}),
          boot(next = {}) {
            if (booted) throw new Error('urui.boot called more than once');
            if (!next || typeof next !== 'object') {
              throw new TypeError('urui.boot requires a hook object');
            }
            hooks = next;
            booted = true;
            hook(null, 'onReady')?.(api);
            return api;
          },
          status: (...args) => invoke(null, 'status', args),
          tabs: methods('tabs', [
            'create', 'close', 'select', 'update', 'list', 'active'
          ]),
          editor,
          explorer: methods('explorer', [
            'show', 'refreshTree', 'addRef', 'openDocs'
          ]),
          panes: methods('panes', [
            'get', 'set', 'select', 'panel', 'reveal'
          ]),
          dialog: Object.freeze({
            help: (...args) => invoke('dialog', 'help', args),
            error: (...args) => invoke('dialog', 'error', args),
            //  these two fall back to the browser's own dialog
            confirm: (...args) => {
              const answer = hook('dialog', 'confirm')?.(...args);
              return answer === undefined ? window.confirm(...args) : answer;
            },
            prompt: (...args) => {
              const answer = hook('dialog', 'prompt')?.(...args);
              return answer === undefined ? window.prompt(...args) : answer;
            }
          }),
          session: methods('session', ['save', 'queue', 'get', 'set']),
          files: methods('files', ['browse', 'load', 'save', 'delete']),
          shortcuts: methods('shortcuts', ['register']),
          layout: methods('layout', ['paneWidth', 'explorerWidth']),
          problem: methods('problem', ['show', 'clear']),
          runtime: createRuntime
        };
        for (const value of Object.values(api)) {
          if (value && typeof value === 'object') Object.freeze(value);
        }
        window.urui = Object.freeze(api);
      })();
      '''
  ==
::
++  runtime
  ::  The body of createRuntime: shell behavior every consumer shares.
  ::
  ::  The runtime owns the frame urui emits — theme, status lines, the
  ::  two resizers, explorer collapse, the help panel, the panes (their
  ::  bands, reveal toggles, and every tab level), the explorer
  ::  (permanent views, docs tabs, ref tabs, and the file context menu),
  ::  session persistence, and shortcut dispatch.
  ::  It reads its policy from `window.URUI_CONFIG` and reaches the frame
  ::  through `data-role` and the ids `urui-shell` fixes, so nothing here
  ::  names a consumer. Section banners mark each responsibility;
  ::  ++shortcuts and ++documents are composed into the same lexical
  ::  scope.
  ::
  ::  Every `options` field is documented at the banner of the section
  ::  that reads it.  The object ++runtime returns is runtime-internal,
  ::  wider than `window.urui`, and unfrozen.
  ^-  @t
  %+  rap  3
  :~
  '''
  // ---- shell frame --------------------------------------------------
  //
  // Policy comes from `window.URUI_CONFIG`; the frame is reached through
  // `data-role` and the ids urui-shell fixes.  A consumer adds to or
  // overrides that node map with `options.elements`, supplies the Ace
  // adapters to resize and re-theme with `options.editors` (an array or
  // a function returning one), and takes over persistence scheduling
  // with `options.onChange`, which replaces the queued session save.
  const config = window.URUI_CONFIG || {};
  const limits = config.limits || {};
  const paneMin = limits.paneMin ?? 25;
  const paneMax = limits.paneMax ?? 70;
  const minExplorer = limits.minExplorer ?? 180;
  const dividerWidth = limits.divider ?? 10;
  //  the one breakpoint, shared with ++responsive:urui-css
  const narrowMedia = matchMedia('(max-width: 760px)');
  const themes = ['system', 'light', 'dark'];
  const layouts = ['columns', 'rows'];
  const keyModes = ['ace', 'vim'];
  //  the consumer's starting format; a saved preference replaces it
  let layout = validLayout(config.layout);
  let keybindings = 'ace';
  const themeMedia = matchMedia('(prefers-color-scheme: dark)');
  const statusLabels = new Map(
    (config.statuses || []).map((entry) => [entry.name, entry.label])
  );
  const role = (name) => document.querySelector(`[data-role="${name}"]`);
  const elements = {
    workbench: document.querySelector('#workbench'),
    workspace: document.querySelector('#workspace'),
    splitter: document.querySelector('#splitter'),
    explorerPane: role('reference'),
    explorerResizer: document.querySelector('#explorer-resizer'),
    explorerCollapse: document.querySelector('#explorer-collapse'),
    explorerTabs: explorerStrip(),
    editorPane: role('editor'),
    resultPane: role('result'),
    resultCollapse: document.querySelector('#result-collapse'),
    themeControl: document.querySelector('#theme'),
    settingsToggle: document.querySelector('#settings'),
    settingsModal: document.querySelector('#settings-modal'),
    closeSettings: document.querySelector('#close-settings'),
    layoutChoices: document.querySelectorAll?.('.layout-choice') ?? [],
    keyChoices:
      document.querySelectorAll?.('input[name="keybindings"]') ?? [],
    helpToggle: document.querySelector('#help'),
    helpPanel: document.querySelector('#help-panel'),
    closeHelp: document.querySelector('#close-help'),
    contextMenu: document.querySelector('#file-context-menu'),
    contextOpen: document.querySelector('#file-context-open'),
    contextDelete: document.querySelector('#file-context-delete'),
    fallbackHelp: document.querySelector('#fallback-help-content'),
    docsHelp: document.querySelector('#docs-help-content'),
    docsHelpNav: document.querySelector('#docs-help-nav'),
    ...(options.elements || {})
  };
  let explorerOpen = true;
  let resultOpen = true;
  const explorerListeners = new Set();
  let refreshQueued = false;

  function changed() {
    if (options.onChange) options.onChange();
    else queueSaveSession();
  }

  function clamp(value, minimum, maximum) {
    return Math.min(maximum, Math.max(minimum, value));
  }

  function editors() {
    const source = options.editors;
    const list = typeof source === 'function' ? source() : source;
    return [...(list || []), ...documentEditors()].filter(Boolean);
  }

  // One resize per frame: a drag emits pointermove far faster than Ace
  // can lay out, and an unbatched call makes the cursor lag the divider.
  function refreshEditors() {
    if (refreshQueued) return;
    refreshQueued = true;
    requestAnimationFrame(() => {
      refreshQueued = false;
      for (const item of editors()) item.refresh?.();
    });
  }


  // ---- panes --------------------------------------------------------
  //
  // `config.panes` declares three panes as ordered bands.  urui-shell
  // emitted the band wrappers, the depth-0 tab strips, and the reveal
  // toggles; this section makes them live.  Nothing here names a pane,
  // a band, or a level: every name arrives in the declaration.
  //
  // A level's tabs come from one of four sources.  %documents is the
  // document store above and %views the explorer below — each keeps its
  // own machinery and the level only points at it.  %fixed and %dynamic
  // are rendered here, the first from `level.fixed`, the second from
  // whatever `runtime.panes.set` was last given for that parent path.
  //
  // Depth 0 renders into the strip urui-shell emitted.  A deeper level
  // is generated under the pane's panel, one strip per depth, along the
  // selected path only.  A content panel is cached by its whole path,
  // so what a consumer filled survives its parent tab being switched
  // away and back.
  //
  // Two urui-owned record slots persist the result: `paneBands`, keyed
  // by each band's own `reveal.key`, and `panePaths`, the selected tab
  // at each depth, keyed by pane id.  A consumer reacts through
  // `options.panes`: onSelect, onAdd, onClose, and onRendered.
  const paneRoles = ['reference', 'editor', 'result'];
  const panes = paneRoles
    .map((role) => (config.panes || {})[role])
    .filter(Boolean);
  const paneById = new Map(panes.map((pane) => [pane.id, pane]));
  validateConfig();
  const dynamicTabs = new Map();
  const levelPanels = new Map();
  const chainHosts = new Map();
  const attachedContent = new Map();
  let panePaths = {};
  let paneBands = {};

  //  `elements` is built above this section, so both of these read
  //  `config.panes` rather than the index below it: a const in the
  //  temporal dead zone is not reachable from a hoisted function.
  function explorerLevel() {
    //  the role list is spelled out again rather than read from
    //  `paneRoles`: that const is still in its dead zone up there
    for (const role of ['reference', 'editor', 'result']) {
      const pane = (config.panes || {})[role];
      for (const band of pane?.bands || []) {
        if (band.item?.kind !== 'tabs') continue;
        const level = (band.item.levels || []).find((item) => {
          return item.source === 'views';
        });
        if (level) return {paneId: pane.id, level};
      }
    }
    return undefined;
  }

  function explorerStrip() {
    const found = explorerLevel();
    if (!found) return null;
    return document.querySelector(
      `#${stripId(found.paneId, found.level.name)}`
    );
  }

  function stripId(paneId, levelName) {
    return `${paneId}-${levelName}-tabs`;
  }

  function paneBandList(paneId) {
    return paneById.get(paneId)?.bands || [];
  }

  function paneBand(paneId, name) {
    return paneBandList(paneId).find((band) => band.name === name);
  }

  function paneItem(paneId, kind) {
    return paneBandList(paneId).find((band) => {
      return band.item?.kind === kind;
    })?.item;
  }

  function paneLevels(paneId) {
    return paneItem(paneId, 'tabs')?.levels || [];
  }

  function paneLevel(paneId, depth) {
    return paneLevels(paneId)[depth];
  }

  function paneDepthOf(paneId, levelName) {
    return paneLevels(paneId).findIndex((level) => level.name === levelName);
  }

  function paneBody(paneId) {
    const id = paneItem(paneId, 'panel')?.id;
    return id ? document.querySelector(`#${id}`) : null;
  }

  //  A config the runtime cannot honour is refused here, by name, rather
  //  than left half-working: duplicate pane, level, or store ids, a
  //  %documents level naming no store, and a store with no %documents
  //  level or with more than one.
  function validateConfig() {
    const problems = [];
    const duplicates = (label, values) => {
      const seen = new Set();
      for (const value of values) {
        if (seen.has(value)) problems.push(`duplicate ${label} "${value}"`);
        seen.add(value);
      }
    };
    duplicates('pane id', panes.map((pane) => pane.id));
    for (const pane of panes) {
      duplicates(
        `level name in pane "${pane.id}"`,
        paneLevels(pane.id).map((level) => level.name)
      );
    }
    const stores = (config.files?.stores || []).map((store) => store.name);
    duplicates('store', stores);
    const bindings = panes.flatMap((pane) => {
      return paneLevels(pane.id)
        .filter((level) => level.source === 'documents')
        .map((level) => ({pane: pane.id, store: level.kind}));
    });
    for (const {pane, store} of bindings) {
      if (!stores.includes(store)) {
        problems.push(`pane "${pane}" binds unknown store "${store}"`);
      }
    }
    for (const store of stores) {
      const bound = bindings.filter((binding) => binding.store === store);
      if (!bound.length) {
        problems.push(`store "${store}" has no %documents level`);
      } else if (bound.length > 1) {
        problems.push(`store "${store}" is bound by ${bound.length} levels`);
      }
    }
    if (problems.length) {
      throw new Error(`urui config: ${problems.join('; ')}`);
    }
  }

  //  A read-only pane refuses the `+` control and every close control,
  //  whatever its levels declare.
  function paneReadOnly(paneId) {
    return paneById.get(paneId)?.mode === 'read-only';
  }

  function stripFor(paneId, levelName) {
    return document.querySelector(`#${stripId(paneId, levelName)}`);
  }

  //  A %documents level is bound to one document store by its kind;
  //  this is how that store finds the strip it renders into.
  function levelForKind(name) {
    for (const pane of panes) {
      const levels = paneLevels(pane.id);
      const depth = levels.findIndex((level) => {
        return level.source === 'documents' && level.kind === name;
      });
      if (depth >= 0) return {paneId: pane.id, depth, level: levels[depth]};
    }
    return undefined;
  }

  //  ---- reveal
  //
  //  `reveal.key` names the field in the `paneBands` record, so a band
  //  renamed in the markup keeps the state the user already chose.  A
  //  band with no key is pinned open and urui-shell drew no toggle.
  function bandIsOpen(paneId, name) {
    const reveal = paneBand(paneId, name)?.reveal;
    if (!reveal?.key) return true;
    const stored = paneBands[reveal.key];
    return typeof stored === 'boolean' ? stored : reveal.open !== false;
  }

  function applyBand(paneId, name) {
    const open = bandIsOpen(paneId, name);
    const band = document.querySelector(`#${paneId}-${name}`);
    if (band) band.hidden = !open;
    const toggle = document.querySelector(`#${paneId}-${name}-toggle`);
    if (toggle) toggle.setAttribute('aria-expanded', String(open));
    return open;
  }

  function applyBands() {
    for (const pane of panes) {
      for (const band of pane.bands || []) {
        if (band.reveal?.key) applyBand(pane.id, band.name);
      }
    }
  }

  function revealBand(paneId, name, open, persist = true) {
    const reveal = paneBand(paneId, name)?.reveal;
    if (!reveal?.key) return undefined;
    paneBands[reveal.key] = open === undefined
      ? !bandIsOpen(paneId, name)
      : Boolean(open);
    const next = applyBand(paneId, name);
    refreshEditors();
    if (persist) changed();
    return next;
  }

  //  ---- paths
  //
  //  One path per pane: the selected tab id at each depth.  A '/' is
  //  the separator, so a tab id may not contain one.
  function panePath(paneId) {
    return panePaths[paneId] || [];
  }

  function pathKey(paneId, path) {
    return [paneId, ...path].join('/');
  }

  function dynamicKey(paneId, levelName, parentPath) {
    return [paneId, levelName, ...parentPath].join('/');
  }

  function writePathSegment(paneId, depth, id, truncate = false) {
    const path = truncate
      ? panePath(paneId).slice(0, depth)
      : panePath(paneId).slice();
    path[depth] = id;
    panePaths[paneId] = path;
    return path;
  }

  function validLevelTab(candidate) {
    if (!candidate || typeof candidate !== 'object') return undefined;
    const id = String(candidate.id ?? '');
    if (!id || id.includes('/') || id.length > 200) return undefined;
    return {
      id,
      label: String(candidate.label ?? id),
      title: candidate.title === undefined
        ? undefined
        : String(candidate.title)
    };
  }

  function levelTabs(paneId, depth, parentPath) {
    const level = paneLevel(paneId, depth);
    if (!level) return [];
    if (level.source === 'fixed') {
      return (level.fixed || []).map((view) => {
        return {id: view.name, label: view.label};
      });
    }
    if (level.source === 'dynamic') {
      return dynamicTabs.get(dynamicKey(paneId, level.name, parentPath))
        || [];
    }
    if (level.source === 'documents') {
      return documentStore(level.kind) ? documentLevelTabs(level.kind) : [];
    }
    return [];
  }

  function selectedAt(paneId, depth, tabs) {
    const wanted = panePath(paneId)[depth];
    if (tabs.some((tab) => tab.id === wanted)) return wanted;
    return tabs[0]?.id;
  }

  //  ---- rendering
  //
  //  `level.add` is the `+` control's label and `level.close` asks for
  //  a close control; both are refused outright by a read-only pane.
  function levelAddLabel(paneId, level) {
    if (paneReadOnly(paneId)) return undefined;
    return level?.add || undefined;
  }

  function levelCloses(paneId, level) {
    return Boolean(level?.close) && !paneReadOnly(paneId);
  }

  function levelKeydown(event, paneId, depth) {
    if (!['ArrowLeft', 'ArrowRight', 'Home', 'End']
      .includes(event.key)) return;
    event.preventDefault();
    const parentPath = panePath(paneId).slice(0, depth);
    const tabs = levelTabs(paneId, depth, parentPath);
    if (!tabs.length) return;
    const current = tabs.findIndex((tab) => {
      return tab.id === event.currentTarget.dataset.paneTab;
    });
    let next = current;
    if (event.key === 'Home') next = 0;
    else if (event.key === 'End') next = tabs.length - 1;
    else if (event.key === 'ArrowLeft') {
      next = (current - 1 + tabs.length) % tabs.length;
    } else {
      next = (current + 1) % tabs.length;
    }
    selectLevel(paneId, depth, tabs[next].id, {focus: true});
  }

  function focusLevelTab(paneId, depth, id) {
    const level = paneLevel(paneId, depth);
    stripFor(paneId, level?.name)
      ?.querySelector(`[data-pane-tab="${id}"]`)?.focus();
  }

  function levelTabControl(paneId, depth, level, tab, activeId) {
    const wrapper = document.createElement('div');
    wrapper.className = 'document-tab-control';
    wrapper.classList.toggle('active', tab.id === activeId);
    wrapper.setAttribute('role', 'presentation');
    const control = document.createElement('button');
    control.type = 'button';
    control.className = 'document-tab';
    control.dataset.paneTab = tab.id;
    control.dataset.paneDepth = String(depth);
    control.setAttribute('role', 'tab');
    control.setAttribute('aria-selected', String(tab.id === activeId));
    control.tabIndex = tab.id === activeId ? 0 : -1;
    control.textContent = tab.label;
    control.title = tab.title || tab.label;
    control.addEventListener('click', () => {
      selectLevel(paneId, depth, tab.id);
    });
    control.addEventListener('keydown', (event) => {
      levelKeydown(event, paneId, depth);
    });
    wrapper.append(control);
    if (levelCloses(paneId, level)) {
      const close = document.createElement('button');
      close.type = 'button';
      close.className = 'document-tab-close';
      close.textContent = 'X';
      close.title = tip('tab-close', 'Close tab');
      close.setAttribute('aria-label', `Close ${tab.label}`);
      close.addEventListener('click', (event) => {
        event.stopPropagation?.();
        closeLevelTab(paneId, depth, tab.id);
      });
      wrapper.append(close);
    }
    return wrapper;
  }

  function levelAddControl(paneId, depth, level, label) {
    const wrapper = document.createElement('div');
    wrapper.className = 'document-tab-control document-tab-add-control';
    wrapper.setAttribute('role', 'presentation');
    const add = document.createElement('button');
    add.type = 'button';
    add.className = 'document-tab-add';
    add.setAttribute('aria-label', label);
    add.title = label;
    add.textContent = '+';
    add.addEventListener('click', () => {
      options.panes?.onAdd?.(paneId, level.name, panePath(paneId).slice(
        0, depth
      ));
    });
    wrapper.append(add);
    return wrapper;
  }

  function newLevelStrip(paneId, level, depth) {
    const strip = document.createElement('div');
    strip.className = 'tab-strip';
    strip.id = stripId(paneId, level.name);
    strip.dataset.depth = String(depth);
    strip.dataset.source = level.source;
    strip.setAttribute('role', 'tablist');
    strip.setAttribute('aria-label', level.label);
    return strip;
  }

  //  The content panel for one whole path, created once and kept: a
  //  consumer may have filled it for a tab that is not selected now.
  function levelContent(paneId, path) {
    const key = pathKey(paneId, path);
    let panel = levelPanels.get(key);
    if (!panel) {
      panel = document.createElement('div');
      panel.className = 'pane-level-content';
      panel.dataset.panePath = path.join('/');
      levelPanels.set(key, panel);
    }
    return panel;
  }

  //  The generated chain under the pane body: one strip per level below
  //  depth 0, nested, the deepest of them holding the content panel.
  //  Built once and kept — a strip is an element a consumer may be
  //  holding — and filled by ++renderLevelStrip on every render.
  function levelChain(paneId) {
    const existing = chainHosts.get(paneId);
    if (existing) return existing;
    const body = paneBody(paneId);
    const levels = paneLevels(paneId);
    if (!body || levels.length < 2) return undefined;
    let host = document.createElement('div');
    host.className = 'pane-levels';
    body.append(host);
    for (let depth = 1; depth < levels.length; depth += 1) {
      host.append(newLevelStrip(paneId, levels[depth], depth));
      if (depth + 1 >= levels.length) break;
      const next = document.createElement('div');
      next.className = 'pane-level';
      next.dataset.depth = String(depth + 1);
      host.append(next);
      host = next;
    }
    chainHosts.set(paneId, host);
    return host;
  }

  //  Swap the attached content panel for the one this path names; the
  //  one it replaces keeps whatever the consumer put in it.  Answers
  //  whether anything moved.
  function attachContent(paneId, host) {
    const next = levelContent(paneId, panePath(paneId));
    if (attachedContent.get(paneId) === next) return false;
    attachedContent.get(paneId)?.remove();
    host.append(next);
    attachedContent.set(paneId, next);
    return true;
  }

  function renderLevelStrip(paneId, depth) {
    const level = paneLevel(paneId, depth);
    const strip = stripFor(paneId, level?.name);
    if (!strip) return undefined;
    const parentPath = panePath(paneId).slice(0, depth);
    const tabs = levelTabs(paneId, depth, parentPath);
    const active = selectedAt(paneId, depth, tabs);
    //  an empty level ends the path rather than putting a hole in it
    if (active === undefined) panePaths[paneId] = parentPath;
    else writePathSegment(paneId, depth, active);
    strip.replaceChildren();
    for (const tab of tabs) {
      strip.append(levelTabControl(paneId, depth, level, tab, active));
    }
    const label = levelAddLabel(paneId, level);
    if (label) strip.append(levelAddControl(paneId, depth, level, label));
    options.panes?.onRendered?.(paneId, level.name, depth);
    return active;
  }

  //  Render one pane end to end: its depth-0 strip through whichever
  //  machinery owns it, then every generated level below.
  function renderPane(paneId) {
    const levels = paneLevels(paneId);
    if (!levels.length) return;
    const first = levels[0];
    //  ++docRender ends in ++syncLevelsBelow, which renders the rest
    if (first.source === 'documents') {
      if (documentStore(first.kind)) docRender(first.kind);
      return;
    }
    if (first.source !== 'views') renderLevelStrip(paneId, 0);
    renderDeepLevels(paneId);
  }

  function renderDeepLevels(paneId) {
    const levels = paneLevels(paneId);
    if (levels.length < 2) return;
    //  Building the chain adds strips to the pane body and so moves
    //  whatever else shares it — an Ace host, say — and that one time
    //  earns an editor refresh.  Re-filling a strip or swapping the
    //  content panel does not: they replace elements in place, and an
    //  unearned refresh costs a scroll position and a cursor the user
    //  did not ask to lose.  A consumer whose panels differ in height
    //  around an editor calls `runtime.refreshEditors` itself.
    const built = !chainHosts.has(paneId);
    const deepest = levelChain(paneId);
    for (let depth = 1; depth < levels.length; depth += 1) {
      renderLevelStrip(paneId, depth);
    }
    if (deepest) attachContent(paneId, deepest);
    if (built) refreshEditors();
  }

  //  A document store owns its own depth-0 strip; these two are how the
  //  levels under it follow the tab that store just selected.  The path
  //  moves first — ++docSelect calls ++syncStorePath before its
  //  activate hook — so a consumer that fills a %dynamic level from
  //  that hook files its tabs under the parent path they belong to.
  function syncStorePath(name) {
    const found = levelForKind(name);
    if (!found) return;
    writePathSegment(found.paneId, found.depth, documentActiveId(name));
  }

  function syncLevelsBelow(name) {
    const found = levelForKind(name);
    if (!found) return;
    syncStorePath(name);
    renderDeepLevels(found.paneId);
  }

  function renderPanes() {
    for (const pane of panes) renderPane(pane.id);
  }

  //  ---- selection
  //
  //  A %documents or %views level keeps its own selection; every other
  //  level is selected here, and selecting one drops the path below it.
  function selectLevel(paneId, depth, id, choices = {}) {
    const level = paneLevel(paneId, depth);
    if (!level) return undefined;
    if (level.source === 'documents') {
      return documentStore(level.kind)
        ? docSelect(level.kind, id, choices) : undefined;
    }
    if (level.source === 'views') return setExplorerView(id, choices.focus);
    writePathSegment(paneId, depth, id, true);
    renderPane(paneId);
    options.panes?.onSelect?.(paneId, level.name, id, panePath(paneId));
    changed();
    if (choices.focus) focusLevelTab(paneId, depth, id);
    return id;
  }

  function selectPanePath(paneId, path) {
    if (!Array.isArray(path)) return undefined;
    panePaths[paneId] = path.map((id) => String(id));
    renderPane(paneId);
    changed();
    return panePath(paneId);
  }

  function closeLevelTab(paneId, depth, id) {
    const level = paneLevel(paneId, depth);
    if (!levelCloses(paneId, level)) return undefined;
    if (level.source === 'dynamic') {
      const parentPath = panePath(paneId).slice(0, depth);
      const key = dynamicKey(paneId, level.name, parentPath);
      const tabs = (dynamicTabs.get(key) || []).filter((tab) => {
        return tab.id !== id;
      });
      dynamicTabs.set(key, tabs);
      levelPanels.delete(pathKey(paneId, [...parentPath, id]));
      if (panePath(paneId)[depth] === id) {
        writePathSegment(paneId, depth, tabs[0]?.id, true);
      }
    }
    renderPane(paneId);
    options.panes?.onClose?.(paneId, level.name, id);
    changed();
    return id;
  }

  //  Replace one level's tabs wholesale, under one parent path.
  function setLevelTabs(paneId, levelName, tabs, parentPath) {
    const depth = paneDepthOf(paneId, levelName);
    if (depth < 0) return undefined;
    const parent = parentPath || panePath(paneId).slice(0, depth);
    const valid = (Array.isArray(tabs) ? tabs : [])
      .map(validLevelTab)
      .filter(Boolean);
    dynamicTabs.set(dynamicKey(paneId, levelName, parent), valid);
    renderPane(paneId);
    return valid;
  }

  //  ---- the session record
  function validBandRecord(raw) {
    if (!raw || typeof raw !== 'object') return {};
    const record = {};
    for (const pane of panes) {
      for (const band of pane.bands || []) {
        const key = band.reveal?.key;
        if (key && typeof raw[key] === 'boolean') record[key] = raw[key];
      }
    }
    return record;
  }

  function validPathRecord(raw) {
    if (!raw || typeof raw !== 'object') return {};
    const record = {};
    for (const pane of panes) {
      const path = raw[pane.id];
      if (!Array.isArray(path)) continue;
      const depth = paneLevels(pane.id).length;
      record[pane.id] = path.slice(0, depth).filter((id) => {
        return typeof id === 'string' && id && !id.includes('/')
          && id.length <= 200;
      });
    }
    return record;
  }

  // ---- theme --------------------------------------------------------
  //
  // Three selections — system, light, dark — carried on the root element
  // as `data-theme` (the selection) and `data-effective-theme` (what it
  // resolves to now), the same pair ++theme-bootstrap writes before
  // first paint.  `options.onTheme(effective, selected)` follows every
  // change; every editor is re-themed with the effective value.
  function validTheme(candidate) {
    return themes.includes(candidate) ? candidate : 'system';
  }

  function selectedTheme() {
    return elements.themeControl
      ? elements.themeControl.value
      : document.documentElement.dataset.theme;
  }

  function applyTheme(candidate, persist = true) {
    const selected = validTheme(candidate);
    const effective = selected === 'system'
      ? (themeMedia.matches ? 'dark' : 'light')
      : selected;
    if (elements.themeControl) elements.themeControl.value = selected;
    const root = document.documentElement;
    root.dataset.theme = selected;
    root.dataset.effectiveTheme = effective;
    root.style.colorScheme = effective;
    for (const item of editors()) item.setTheme?.(effective);
    options.onTheme?.(effective, selected);
    if (persist) changed();
    return effective;
  }

  function systemThemeChanged() {
    if (selectedTheme() === 'system') applyTheme('system', false);
  }

  // ---- status lines -------------------------------------------------
  //
  // `config.statuses` maps a state name to its label; an unrecognised
  // state is shown verbatim.  A pane's node is `options.elements`
  // `editorStatus`/`resultStatus` when the consumer names one, else the
  // first `.status` or `.pane-status` inside that pane.
  function statusNode(name) {
    const named = name === 'editor'
      ? elements.editorStatus
      : elements.resultStatus;
    if (named) return named;
    const pane = name === 'editor' ? elements.editorPane : elements.resultPane;
    return pane?.querySelector('.status, .pane-status');
  }

  function setStatus(name, state) {
    const node = statusNode(name);
    const label = statusLabels.has(state) ? statusLabels.get(state) : state;
    if (node) node.textContent = label;
    return label;
  }

  // ---- layout -------------------------------------------------------
  //
  // Two widths, both css custom properties the stylesheet declares and
  // the runtime rewrites inline: `--editor-width`, a percent on
  // `#workspace`, and `--explorer-width`, pixels on `#workbench`.  Every
  // change refreshes the editors, batched one per frame.  Explorer
  // collapse is a class on the pane and the workbench plus the
  // resizer's disabled state, not a width of zero.  Result collapse is
  // the same idea on the workspace: `.result-collapsed` shrinks the
  // result pane to its heading and idles the splitter, and leaves both
  // divider positions alone so expanding restores the old size.
  function paneWidth() {
    const value = getComputedStyle(elements.workspace)
      .getPropertyValue('--editor-width');
    return clamp(parseFloat(value) || 44, paneMin, paneMax);
  }

  function setPaneWidth(width, persist = true) {
    const next = clamp(width, paneMin, paneMax);
    elements.workspace.style.setProperty('--editor-width', `${next}%`);
    refreshEditors();
    if (persist) changed();
    return next;
  }

  // The rows layout sizes the same splitter on the other axis, and keeps
  // its own fraction: a comfortable 44% column is rarely a comfortable
  // 44% row, so switching format preserves how each was sized.
  function paneHeight() {
    const value = getComputedStyle(elements.workspace)
      .getPropertyValue('--editor-height');
    return clamp(parseFloat(value) || 50, paneMin, paneMax);
  }

  function setPaneHeight(height, persist = true) {
    const next = clamp(height, paneMin, paneMax);
    elements.workspace.style.setProperty('--editor-height', `${next}%`);
    refreshEditors();
    if (persist) changed();
    return next;
  }

  function validLayout(candidate) {
    return layouts.includes(candidate) ? candidate : 'columns';
  }

  // Screen format: `columns` is reference, editor and render side by
  // side; `rows` is reference beside editor stacked over render.  The
  // reference pane is vertical and leftmost either way -- only the
  // workspace changes -- and the choice holds at every viewport width.
  function setLayout(candidate, persist = true) {
    layout = validLayout(candidate);
    elements.workspace?.setAttribute('data-layout', layout);
    elements.splitter?.setAttribute(
      'aria-orientation',
      layout === 'rows' ? 'horizontal' : 'vertical'
    );
    for (const choice of elements.layoutChoices || []) {
      choice.setAttribute(
        'aria-pressed',
        String(choice.dataset?.layout === layout)
      );
    }
    applyResultLayout();
    if (persist) changed();
    return layout;
  }

  //  Only a page whose config asked for the control can collapse: a
  //  saved `false` must not strand a pane that has no way back open.
  function applyResultLayout() {
    const control = elements.resultCollapse;
    if (!control) resultOpen = true;
    elements.resultPane?.classList.toggle('collapsed', !resultOpen);
    elements.workspace?.classList.toggle('result-collapsed', !resultOpen);
    elements.splitter?.classList.toggle('inactive', !resultOpen);
    if (control) {
      const label = config.panes?.result?.label || 'result pane';
      const text = resultOpen
        ? tip('result-collapse', `Collapse ${label}`)
        : tip('result-expand', `Expand ${label}`);
      control.setAttribute('aria-expanded', String(resultOpen));
      control.setAttribute('aria-label', text);
      control.title = text;
      control.textContent = layout === 'rows'
        ? (resultOpen ? '⌄' : '⌃')
        : (resultOpen ? '›' : '‹');
    }
    refreshEditors();
  }

  function setResultOpen(open, persist = true) {
    resultOpen = open !== false;
    applyResultLayout();
    if (persist) changed();
    return resultOpen;
  }

  function validKeybindings(candidate) {
    return keyModes.includes(candidate) ? candidate : 'ace';
  }

  // Applied to every editor adapter that implements it, the same way
  // the theme is.  An adapter without `setKeybindings` keeps its own
  // keymap and the preference is still recorded.
  function setKeybindings(candidate, persist = true) {
    keybindings = validKeybindings(candidate);
    document.documentElement.dataset.keybindings = keybindings;
    for (const choice of elements.keyChoices || []) {
      choice.checked = choice.value === keybindings;
    }
    for (const item of editors()) item.setKeybindings?.(keybindings);
    if (persist) changed();
    return keybindings;
  }

  function maxExplorerWidth() {
    const bounds = elements.workbench.getBoundingClientRect();
    return Math.max(minExplorer, bounds.width - dividerWidth);
  }

  function explorerWidth() {
    const value = getComputedStyle(elements.workbench)
      .getPropertyValue('--explorer-width');
    return clamp(parseFloat(value) || 288, minExplorer, maxExplorerWidth());
  }

  function setExplorerWidth(width, persist = false) {
    const next = clamp(width, minExplorer, maxExplorerWidth());
    elements.workbench.style.setProperty('--explorer-width', `${next}px`);
    refreshEditors();
    if (persist) changed();
    return next;
  }

  //  The compact frame has no explorer: nothing to lay out, and
  //  `runtime.start` calls this on every frame.
  function applyExplorerLayout() {
    const {explorerPane, workbench, explorerResizer, explorerCollapse} =
      elements;
    explorerPane?.classList.toggle('collapsed', !explorerOpen);
    workbench?.classList.toggle('explorer-collapsed', !explorerOpen);
    explorerResizer?.classList.toggle('inactive', !explorerOpen);
    if (explorerResizer) explorerResizer.disabled = !explorerOpen;
    if (explorerCollapse) {
      const text = explorerOpen
        ? tip('explorer-collapse', 'Collapse explorer')
        : tip('explorer-expand', 'Expand explorer');
      explorerCollapse.setAttribute('aria-expanded', String(explorerOpen));
      explorerCollapse.setAttribute('aria-label', text);
      explorerCollapse.title = text;
      explorerCollapse.textContent = explorerOpen ? '‹' : '›';
    }
    refreshEditors();
    explorerChanged();
  }

  //  `runtime.explorer.onChange(fn)`: `fn({view, open})` after every
  //  view switch and every collapse or expand, so a consumer can load a
  //  view's content the first time it is on screen.  Returns an
  //  unsubscribe.
  function onExplorerChange(listener) {
    explorerListeners.add(listener);
    return () => explorerListeners.delete(listener);
  }

  function explorerChanged() {
    const state = {view: explorerView, open: explorerOpen};
    for (const listener of explorerListeners) listener(state);
  }

  function setExplorerOpen(open, persist = true) {
    explorerOpen = open !== false;
    applyExplorerLayout();
    if (persist) changed();
    return explorerOpen;
  }

  // ---- modals -------------------------------------------------------
  //
  // Help, settings, the file dialog, and the confirm dialog share one
  // controller.  Each is a `hidden`-toggled aside; the open one with the
  // highest rank is on top.  While one is open, Tab and Shift+Tab stay
  // inside it, Escape runs its `close`, the rest of the page is inert
  // (live regions excepted), and no app shortcut runs.  Opening one
  // remembers what held focus; hiding it gives focus back, or to its
  // `fallback` when nothing did.  Which modal is open is read from the
  // DOM, so every runtime on the page agrees.
  const modals = [];
  const modalInert = new Set();

  function defineModal(rank, element, close, fallback) {
    const modal = {rank, element, close, fallback, returnFocus: null};
    modals.push(modal);
    modals.sort((left, right) => right.rank - left.rank);
    return modal;
  }

  function modalIsOpen(modal) {
    const element = modal.element();
    return Boolean(element) && !element.hidden;
  }

  function topModal() {
    return modals.find(modalIsOpen);
  }

  function modalFocusables(root) {
    const found = [];
    const walk = (node) => {
      for (const child of Array.from(node?.children || [])) {
        if (child.hidden) continue;
        const name = String(child.localName || '').toLowerCase();
        if (['button', 'input', 'select', 'textarea'].includes(name)
          && !child.disabled) {
          found.push(child);
        }
        walk(child);
      }
    };
    walk(root);
    return found;
  }

  function modalTrapTab(event, root) {
    const items = modalFocusables(root);
    if (!items.length) return false;
    const first = items[0];
    const last = items[items.length - 1];
    const active = document.activeElement;
    if (event.shiftKey && (active === first || !root.contains(active))) {
      last.focus();
      return true;
    }
    if (!event.shiftKey && (active === last || !root.contains(active))) {
      first.focus();
      return true;
    }
    return false;
  }

  //  Everything beside the top modal goes inert; nodes the page had
  //  already made inert are left alone.
  function syncModalInert() {
    for (const node of modalInert) node.inert = false;
    modalInert.clear();
    const top = topModal()?.element();
    if (!top) return;
    for (const node of Array.from(document.body?.children || [])) {
      if (node === top || node.inert
        || node.getAttribute?.('aria-live')) {
        continue;
      }
      node.inert = true;
      modalInert.add(node);
    }
  }

  //  A modal lives outside any fullscreen element, so opening one
  //  leaves fullscreen first.
  function showModal(modal, focus) {
    const element = modal.element();
    if (!element) return;
    if (document.fullscreenElement
      && !document.fullscreenElement.contains(element)) {
      document.exitFullscreen?.()?.catch?.(() => {});
    }
    if (element.hidden && !element.contains(document.activeElement)) {
      modal.returnFocus = document.activeElement;
    }
    element.hidden = false;
    syncModalInert();
    focus?.focus?.();
  }

  function hideModal(modal, restoreFocus = true) {
    const element = modal.element();
    if (!element) return;
    const wasOpen = !element.hidden;
    element.hidden = true;
    syncModalInert();
    if (wasOpen && restoreFocus) {
      (modal.returnFocus ?? modal.fallback?.())?.focus?.();
    }
    modal.returnFocus = null;
  }

  // ---- tooltips -----------------------------------------------------
  //
  // Every button carries a tooltip.  urui's own come through
  // `tip(key, fallback)`: the config's `tips[key]` when the consumer
  // replaced it, else urui's default.  A key is the control's id, or a
  // name for a control urui draws many of.  A button that reaches the
  // page untitled, a consumer's included, is titled from its
  // accessible name or its text, and kept in step with them.
  const tips = config.tips || {};

  function tip(key, fallback) {
    return Object.hasOwn(tips, key) ? String(tips[key]) : fallback;
  }

  function applyTips() {
    for (const [key, text] of Object.entries(tips)) {
      const node = document.getElementById?.(key);
      if (node) node.title = String(text);
    }
  }

  //  Only a changed name is written: an attribute write is a mutation
  //  even when the value is the same, and the observer would loop.
  function autoTitle(button) {
    const name = button.getAttribute?.('aria-label')
      || String(button.textContent || '').trim();
    if (!name || button.title === name) return;
    button.title = name;
    button.dataset.autoTitle = name;
  }

  function titleButtons(root) {
    const found = root?.localName === 'button' ? [root]
      : Array.from(root?.querySelectorAll?.('button') || []);
    for (const button of found) {
      if (!button.getAttribute?.('title')) autoTitle(button);
    }
  }

  function watchTitles() {
    titleButtons(document.body);
    if (typeof MutationObserver !== 'function' || !document.body) return;
    new MutationObserver((records) => {
      for (const record of records) {
        const changed = record.target?.nodeType === 1
          ? record.target : record.target?.parentElement;
        const owner = changed?.closest?.('button');
        if (owner?.dataset.autoTitle !== undefined) {
          //  a title someone else wrote is theirs to keep
          if (owner.title !== owner.dataset.autoTitle) {
            delete owner.dataset.autoTitle;
          } else {
            autoTitle(owner);
          }
        }
        for (const node of record.addedNodes || []) {
          if (node.nodeType === 1) titleButtons(node);
        }
      }
    }).observe(document.body, {
      childList: true, subtree: true, characterData: true,
      attributes: true, attributeFilter: ['aria-label', 'title']
    });
  }

  // ---- fullscreen ---------------------------------------------------
  //
  // A button ++fullscreen-toggle:urui-shell drew expands the element its
  // `data-fullscreen-target` names.  While expanded the target carries
  // `.is-fullscreen`, which shows its `.fullscreen-only` controls, and
  // the toast moves inside it so feedback stays visible.  Tooltip keys
  // are the button's id and `{id}-exit`.
  const fullscreenToggles = [];

  function fullscreenTarget(button) {
    const id = button.dataset?.fullscreenTarget;
    return id ? document.getElementById?.(id) : null;
  }

  function syncFullscreen() {
    const expandedElement = document.fullscreenElement;
    for (const button of fullscreenToggles) {
      const target = fullscreenTarget(button);
      const expanded = Boolean(target) && expandedElement === target;
      const label = button.dataset?.fullscreenLabel || 'view';
      const text = expanded
        ? tip(`${button.id}-exit`, `Return ${label} to its pane`)
        : tip(button.id, `Expand ${label} to fullscreen`);
      button.setAttribute('aria-pressed', String(expanded));
      button.setAttribute('aria-label', text);
      button.title = text;
      target?.classList.toggle('is-fullscreen', expanded);
    }
    const toast = document.getElementById?.('urui-toast');
    const host = expandedElement || document.body;
    if (toast && host && toast.parentElement !== host) host.append(toast);
    refreshEditors();
  }

  async function toggleFullscreen(button) {
    const target = fullscreenTarget(button);
    if (!target || button.disabled) return;
    try {
      if (document.fullscreenElement === target) {
        await document.exitFullscreen();
      } else {
        await target.requestFullscreen();
      }
    } catch (_) {
      notify('Unable to change fullscreen mode.', {kind: 'error'});
    }
  }

  function wireFullscreen() {
    const found = document.querySelectorAll?.('[data-fullscreen-target]');
    for (const button of Array.from(found || [])) {
      fullscreenToggles.push(button);
      button.addEventListener('click', () => toggleFullscreen(button));
    }
    document.addEventListener('fullscreenchange', syncFullscreen);
    syncFullscreen();
  }

  // ---- help and settings ------------------------------------------
  //
  // Both are modals.  `options.onHelpOpen` runs before help takes focus.
  const helpModal = defineModal(1, () => elements.helpPanel, () => {
    setHelpOpen(false, true);
  }, () => elements.helpToggle);
  const settingsModal = defineModal(2, () => elements.settingsModal, () => {
    setSettingsOpen(false, true);
  }, () => elements.settingsToggle);

  function helpIsOpen() {
    return modalIsOpen(helpModal);
  }

  function setHelpOpen(open, restoreFocus = false) {
    elements.helpToggle?.setAttribute('aria-expanded', String(open));
    if (!open) {
      hideModal(helpModal, restoreFocus);
      return;
    }
    showModal(helpModal);
    setHelpVariant(docsAvailable === true);
    refreshHelpVariant();
    options.onHelpOpen?.();
    elements.closeHelp.focus();
  }

  function settingsIsOpen() {
    return modalIsOpen(settingsModal);
  }

  function setSettingsOpen(open, restoreFocus = false) {
    if (!elements.settingsModal) return;
    elements.settingsToggle?.setAttribute('aria-expanded', String(open));
    if (open) showModal(settingsModal, elements.closeSettings);
    else hideModal(settingsModal, restoreFocus);
  }


  // ---- references and drags ---------------------------------------
  //
  // A drag carries `draggedTab`: a document tab being reordered, a
  // document tab or app element offering a reference, or an explorer
  // tab.  References are app kinds, `options.refs[kind]`, and the
  // document stores with refs=&.  A reference payload is
  // `{kind, parentId, ...}`; one reference per kind and parentId.
  //
  //   create(payload)     `{label, data}` for a new reference, or nothing
  //   render(panel, ref)  fill the reference panel from `ref.data`
  //   validate(data)      repaired data from a saved record, or undefined
  //   persist             false keeps the kind out of the session record
  let draggedTab;

  function refHooks(kind) {
    if (documentStore(kind)) return documentRefHooks(kind);
    const hooks = options.refs || {};
    return Object.prototype.hasOwnProperty.call(hooks, kind)
      ? hooks[kind]
      : undefined;
  }

  //  the strip a store renders into is the one its %documents level
  //  declared, `{pane}-{level}-tabs`
  function tabContainer(name) {
    const found = levelForKind(name);
    return found ? stripFor(found.paneId, found.level.name) : null;
  }

  function moveExplorerTab(sourceId, targetId, after) {
    const order = explorerOrder;
    const source = order.indexOf(sourceId);
    const target = order.indexOf(targetId);
    if (source < 0 || target < 0 || source === target) return;
    order.splice(source, 1);
    let insertion = order.indexOf(targetId) + (after ? 1 : 0);
    insertion = Math.max(0, Math.min(order.length, insertion));
    order.splice(insertion, 0, sourceId);
    explorerOrder = order;
    syncExplorerTabOrder();
    changed();
  }

  function enableExplorerDrag(wrapper, id) {
    if (wrapper.dataset.dragEnabled) return;
    wrapper.dataset.dragEnabled = 'true';
    wrapper.draggable = true;
    wrapper.addEventListener('dragstart', (event) => {
      draggedTab = {kind: 'explorer', id};
      wrapper.classList.add('is-dragging');
      event.dataTransfer?.setData('text/plain', id);
      if (event.dataTransfer) event.dataTransfer.effectAllowed = 'copyMove';
    });
    wrapper.addEventListener('dragover', (event) => {
      if (draggedTab?.kind !== 'explorer') return;
      event.preventDefault();
      if (event.dataTransfer) event.dataTransfer.dropEffect = 'move';
    });
    wrapper.addEventListener('drop', (event) => {
      if (draggedTab?.kind !== 'explorer') return;
      event.preventDefault();
      const bounds = wrapper.getBoundingClientRect();
      const after = event.clientX > bounds.left + bounds.width / 2;
      moveExplorerTab(draggedTab.id, id, after);
    });
    wrapper.addEventListener('dragend', () => {
      wrapper.classList.remove('is-dragging');
      draggedTab = undefined;
    });
  }


  // ---- explorer -----------------------------------------------------
  //
  // The aside holds three kinds of view in one tab strip: the permanent
  // file trees named by `config.permanentViews`, documentation tabs
  // backed by iframes, and reference tabs mirroring an open document.
  // All three share the strip's order, which the user can drag.
  const permanentViews = (config.permanentViews || []).map((view) => {
    return view.name;
  });
  const firstView = permanentViews[0] || '';
  const docsRoot = config.docsRoot || '';
  const appTitle = String(config.appId?.title || '').toLowerCase();
  let explorerView = firstView;
  let explorerOrder = [...permanentViews];
  const docsTabs = [];
  let nextDocs = 1;
  const refTabs = [];
  let nextRef = 1;
  let docsAvailable = null;
  let docsCheckPending = false;
  let docsTreeLoaded = false;
  let contextTarget = {};

  //  the permanent views come from the page; the strip's reorder keys
  //  every wrapper the same way, so stamp them once
  for (const name of permanentViews) {
    const tab = document.querySelector(`#${name}-tab`);
    if (tab?.parentElement) tab.parentElement.dataset.explorerTabId = name;
  }

  //  the seeded panels live inside the tabs band urui-shell emitted, so
  //  a created panel joins them there rather than beside the band
  function explorerPanelHost() {
    const seeded = firstView
      ? document.querySelector(`#${firstView}-panel`)
      : null;
    return seeded?.parentElement || elements.explorerPane;
  }

  function docsTabById(id) {
    return docsTabs.find((tab) => tab.id === id);
  }

  function refTabById(id) {
    return refTabs.find((tab) => tab.id === id);
  }

  function explorerTabButtons() {
    if (!elements.explorerTabs) return [];
    return Array.from(elements.explorerTabs.querySelectorAll('[role="tab"]'));
  }

  function validExplorerView(name) {
    return permanentViews.includes(name)
      || Boolean(docsTabById(name)) || Boolean(refTabById(name));
  }

  function setExplorerView(name, focus = false) {
    explorerView = validExplorerView(name) ? name : firstView;
    for (const tab of explorerTabButtons()) {
      const active = tab.dataset.explorerView === explorerView;
      tab.setAttribute('aria-selected', String(active));
      tab.tabIndex = active ? 0 : -1;
      tab.classList.toggle('active', active);
      tab.parentElement?.classList.toggle('active', active);
      const panelId = tab.getAttribute('aria-controls');
      const panel = panelId ? document.getElementById(panelId) : undefined;
      if (panel) panel.hidden = !active;
    }
    const selectedDocs = docsTabById(explorerView);
    if (selectedDocs && docsAvailable === true) {
      const frame = document.querySelector(`#${selectedDocs.id}-panel iframe`);
      if (frame && !frame.getAttribute('src')) {
        frame.src = `${docsRoot}${selectedDocs.path}`;
      }
    }
    if (focus) {
      elements.explorerTabs.querySelector(
        `[data-explorer-view="${explorerView}"]`
      )?.focus();
    }
    refreshEditors();
    changed();
    explorerChanged();
  }

  function explorerTabKeydown(event) {
    if (!['ArrowLeft', 'ArrowRight', 'Home', 'End']
      .includes(event.key)) return;
    event.preventDefault();
    const tabs = explorerTabButtons();
    const current = tabs.indexOf(event.currentTarget);
    let next = current;
    if (event.key === 'Home') next = 0;
    else if (event.key === 'End') next = tabs.length - 1;
    else if (event.key === 'ArrowLeft') {
      next = (current - 1 + tabs.length) % tabs.length;
    } else {
      next = (current + 1) % tabs.length;
    }
    setExplorerView(tabs[next].dataset.explorerView, true);
  }

  function syncExplorerTabOrder() {
    const available = [
      ...permanentViews,
      ...docsTabs.map((tab) => tab.id),
      ...refTabs.map((tab) => tab.id)
    ];
    explorerOrder = explorerOrder.filter((id) => available.includes(id));
    for (const id of available) {
      if (!explorerOrder.includes(id)) explorerOrder.push(id);
    }
    const wrappers = new Map(
      Array.from(elements.explorerTabs.children).map((wrapper) => {
        return [wrapper.dataset.explorerTabId, wrapper];
      })
    );
    for (const id of explorerOrder) {
      const wrapper = wrappers.get(id);
      if (!wrapper) continue;
      enableExplorerDrag(wrapper, id);
      elements.explorerTabs.append(wrapper);
    }
  }

  //  A documentation page names itself in its <title>, which repeats the
  //  site and the application.  Drop that noise and keep the leaf.
  function docsTabLabel(documentTitle) {
    const ignored = new Set(['docs', appTitle].filter(Boolean));
    const names = String(documentTitle || '').split(/\s*(?:>|\/)\s*/)
      .map((name) => name.trim())
      .filter((name) => name && !ignored.has(name.toLowerCase()));
    return names.length ? names[names.length - 1] : 'Docs';
  }

  function usefulDocsTitle(title) {
    return docsTabLabel(title) !== 'Docs';
  }

  function syncDocsTab(tab, control, close, frame) {
    const relabel = (title) => {
      tab.title = title;
      control.textContent = docsTabLabel(title);
      control.title = title;
      close.setAttribute('aria-label', `Close ${docsTabLabel(title)}`);
    };
    try {
      const title = frame.contentDocument?.title?.trim();
      const pathname = frame.contentWindow?.location?.pathname || '';
      if (usefulDocsTitle(title)) relabel(title);
      if (pathname.startsWith(docsRoot)) {
        tab.path = pathname.slice(docsRoot.length);
        control.dataset.docPath = tab.path;
      }
      changed();
      const titleNode = frame.contentDocument?.querySelector('title');
      if (titleNode && typeof MutationObserver !== 'undefined') {
        const observer = new MutationObserver(() => {
          const nextTitle = frame.contentDocument?.title?.trim();
          if (!usefulDocsTitle(nextTitle)) return;
          relabel(nextTitle);
          changed();
        });
        observer.observe(titleNode, {
          childList: true, characterData: true, subtree: true
        });
      }
    } catch (_) {
      // The docs frame remains usable if its title cannot be inspected.
    }
  }

  //  Docs and reference tabs share the strip's markup; only the panel
  //  body and the close handler differ.
  function createExplorerTab(tab, variant) {
    const docs = variant === 'docs';
    const label = docs ? docsTabLabel(tab.title) : tab.label;
    const title = docs ? tab.title : tab.label;
    const wrapper = document.createElement('div');
    wrapper.className = docs
      ? 'docs-tab-control' : 'docs-tab-control ref-tab-control';
    wrapper.setAttribute('role', 'presentation');
    wrapper.dataset[docs ? 'docsTab' : 'refTab'] = tab.id;
    wrapper.dataset.explorerTabId = tab.id;
    const control = document.createElement('button');
    control.type = 'button';
    control.className = docs ? 'docs-tab' : 'docs-tab ref-tab';
    control.id = `${tab.id}-tab`;
    control.dataset.explorerView = tab.id;
    if (docs) control.dataset.docPath = tab.path;
    control.setAttribute('role', 'tab');
    control.setAttribute('aria-selected', 'false');
    control.setAttribute('aria-controls', `${tab.id}-panel`);
    control.tabIndex = -1;
    control.textContent = label;
    control.title = title;
    control.addEventListener('click', () => setExplorerView(tab.id));
    control.addEventListener('keydown', explorerTabKeydown);
    const close = document.createElement('button');
    close.type = 'button';
    close.className = docs ? 'docs-tab-close' : 'docs-tab-close ref-tab-close';
    close.setAttribute(
      'aria-label',
      docs ? `Close ${title}` : `Close ${label} reference`
    );
    close.title = docs
      ? tip('docs-tab-close', 'Close documentation tab')
      : tip('ref-tab-close', 'Close reference');
    close.textContent = 'X';
    close.addEventListener('click', () => {
      if (docs) closeDocsTab(tab.id);
      else closeRefTab(tab.id);
    });
    wrapper.append(control, close);
    elements.explorerTabs.append(wrapper);
    const panel = document.createElement('div');
    panel.className = docs
      ? 'explorer-panel docs-explorer-panel'
      : 'explorer-panel ref-explorer-panel';
    panel.id = `${tab.id}-panel`;
    panel.hidden = true;
    panel.setAttribute('role', 'tabpanel');
    panel.setAttribute('aria-labelledby', control.id);
    if (docs) {
      const frame = document.createElement('iframe');
      frame.className = 'docs-explorer-frame';
      frame.title = `${tab.title} documentation`;
      frame.addEventListener('load', () => {
        syncDocsTab(tab, control, close, frame);
      });
      frame.addEventListener('error', disableDocsExplorer);
      panel.append(frame);
    }
    explorerPanelHost().append(panel);
    if (docs) syncExplorerTabOrder();
    else updateRefContent(tab);
  }

  function renderExplorerTabs(variant) {
    //  a consumer without an explorer strip has nothing to render into
    if (!elements.explorerTabs || !elements.explorerPane) return;
    const docs = variant === 'docs';
    const flag = docs ? '[data-docs-tab]' : '[data-ref-tab]';
    const panels = docs ? '.docs-explorer-panel' : '.ref-explorer-panel';
    for (const node of elements.explorerTabs.querySelectorAll(flag)) {
      node.remove();
    }
    for (const node of explorerPanelHost().querySelectorAll(panels)) {
      node.remove();
    }
    for (const tab of docs ? docsTabs : refTabs) {
      createExplorerTab(tab, variant);
    }
    syncExplorerTabOrder();
  }

  function closeExplorerTab(id, variant) {
    const list = variant === 'docs' ? docsTabs : refTabs;
    const index = list.findIndex((tab) => tab.id === id);
    if (index < 0) return undefined;
    const tab = list[index];
    const wasActive = explorerView === id;
    const orderIndex = explorerOrder.indexOf(id);
    document.querySelector(
      `[data-${variant === 'docs' ? 'docs' : 'ref'}-tab="${id}"]`
    )?.remove();
    document.querySelector(`#${id}-panel`)?.remove();
    list.splice(index, 1);
    explorerOrder = explorerOrder.filter((tabId) => tabId !== id);
    if (wasActive) {
      const neighbor = explorerOrder[
        Math.min(orderIndex, explorerOrder.length - 1)
      ];
      setExplorerView(neighbor || '', true);
    }
    return {tab, wasActive};
  }

  function closeDocsTab(id) {
    const closed = closeExplorerTab(id, 'docs');
    if (closed && !closed.wasActive) changed();
  }

  function openDocsTab(title, path) {
    if (docsAvailable !== true) return;
    if (!explorerOpen) setExplorerOpen(true, false);
    const existing = docsTabs.find((tab) => tab.path === path);
    if (existing) {
      setHelpOpen(false);
      setExplorerView(existing.id, true);
      return;
    }
    const tab = {id: `docs-${nextDocs++}`, title, path};
    docsTabs.push(tab);
    explorerOrder.push(tab.id);
    createExplorerTab(tab, 'docs');
    setHelpOpen(false);
    setExplorerView(tab.id, true);
  }

  function updateRefContent(tab) {
    const panel = document.getElementById(`${tab.id}-panel`);
    if (!panel) return;
    const render = refHooks(tab.kind)?.render;
    if (render) {
      panel.replaceChildren();
      render(panel, tab);
      return;
    }
    const source = document.createElement('pre');
    source.className = 'ref-source';
    source.textContent = String(tab.data?.text ?? '');
    panel.replaceChildren(source);
  }

  function refForParent(name, parentId) {
    return refTabs.find((tab) => {
      return tab.kind === name && tab.parentId === parentId;
    });
  }

  function relabelRef(ref) {
    const control = elements.explorerTabs?.querySelector(
      `[data-explorer-view="${ref.id}"]`
    );
    if (!control) return;
    control.textContent = ref.label;
    control.title = ref.label;
    control.parentElement?.querySelector('.ref-tab-close')
      ?.setAttribute('aria-label', `Close ${ref.label} reference`);
  }

  function showRef(ref) {
    if (!explorerOpen) setExplorerOpen(true, false);
    setExplorerView(ref.id, true);
  }

  //  A consumer reference: an existing one for the same parent is
  //  shown rather than duplicated.
  function openAppRef(payload) {
    const hooks = refHooks(payload?.kind);
    const parentId = String(payload?.parentId ?? '');
    if (!hooks || !parentId) return undefined;
    const existing = refForParent(payload.kind, parentId);
    if (existing) {
      showRef(existing);
      return existing;
    }
    const made = hooks.create ? hooks.create(payload) : payload;
    if (!made) return undefined;
    const tab = {
      id: `ref-${nextRef++}`,
      kind: payload.kind,
      parentId,
      label: String(made.label || 'Reference'),
      data: made.data
    };
    refTabs.push(tab);
    explorerOrder.push(tab.id);
    createExplorerTab(tab, 'ref');
    syncExplorerTabOrder();
    showRef(tab);
    changed();
    return tab;
  }

  function updateAppRef(kind, parentId, change = {}) {
    const ref = refForParent(kind, String(parentId));
    if (!ref) return undefined;
    if (change.label !== undefined) ref.label = String(change.label);
    if ('data' in change) ref.data = change.data;
    relabelRef(ref);
    updateRefContent(ref);
    changed();
    return ref;
  }

  //  `payload()` runs at dragstart, so the reference snapshots the
  //  source as it is when the drag begins.
  function enableRefDrag(element, payload) {
    element.draggable = true;
    element.addEventListener('dragstart', (event) => {
      const ref = payload();
      if (!ref || !refHooks(ref.kind)) return;
      draggedTab = {kind: ref.kind, id: String(ref.parentId), ref};
      element.classList.add('is-dragging');
      event.dataTransfer?.setData('text/plain', String(ref.parentId));
      if (event.dataTransfer) event.dataTransfer.effectAllowed = 'copy';
    });
    element.addEventListener('dragend', () => {
      element.classList.remove('is-dragging');
      if (draggedTab?.ref) draggedTab = undefined;
    });
  }

  function closeRefTab(id) {
    if (closeExplorerTab(id, 'ref')) changed();
  }

  // ---- documentation ------------------------------------------------
  //
  // Availability is probed at the ship's own `/docs`, not at the
  // application; the table of contents is then read from
  // `${config.appId.base}/doc.toc`, an indented `/slug title` list (two
  // spaces per level, one nesting deep), and rendered as the collapsible
  // nav the help panel's docs tab shows.  Only the iframe a leaf opens
  // uses `config.docsRoot`.

  function parseDocsToc(source) {
    const root = [];
    const folders = [];
    for (const line of source.split(/\r?\n/)) {
      const match = line.match(/^(\s*)(\/[^\s]+)(?:\s+(.*\S))?\s*$/);
      if (!match) continue;
      const indentation = match[1].replace(/\t/g, '  ').length;
      if (indentation % 2 !== 0) continue;
      const level = indentation / 2;
      const parts = match[2].slice(1).split('/').filter(Boolean);
      if (parts.length < 1 || parts.length > 2
        || !parts.every((part) => /^[A-Za-z0-9._~-]+$/.test(part))) {
        continue;
      }
      const children = level === 0 ? root : folders[level - 1]?.children;
      if (!children) continue;
      const folder = parts.length === 1;
      const entry = {
        children: folder ? [] : undefined,
        folder,
        slug: parts[0],
        title: match[3] || parts[0]
      };
      children.push(entry);
      folders.length = level;
      if (folder) folders[level] = entry;
    }
    return root;
  }

  function appendDocsEntries(container, entries, parentPath = []) {
    for (const entry of entries) {
      const path = [...parentPath, entry.slug];
      if (entry.folder) {
        const group = document.createElement('details');
        group.className = 'docs-help-group';
        const summary = document.createElement('summary');
        summary.className = 'docs-help-summary';
        summary.textContent = entry.title;
        const subnav = document.createElement('div');
        subnav.className = 'docs-help-subnav';
        appendDocsEntries(subnav, entry.children, path);
        group.append(summary, subnav);
        container.append(group);
        continue;
      }
      const docPath = path.join('/');
      const link = document.createElement('a');
      link.className = 'docs-help-link';
      link.href = `${docsRoot}${docPath}`;
      link.dataset.docPath = docPath;
      link.textContent = entry.title;
      link.addEventListener('click', (event) => {
        event.preventDefault();
        openDocsTab(entry.title, docPath);
      });
      container.append(link);
    }
  }

  async function loadDocsTree() {
    if (docsTreeLoaded) return true;
    try {
      const response = await fetch(`${config.appId.base}/doc.toc`, {
        method: 'GET',
        credentials: 'same-origin',
        cache: 'no-store'
      });
      const contentType = response.headers.get('content-type') || '';
      if (!response.ok || !contentType.includes('text/plain')) return false;
      const entries = parseDocsToc(await response.text());
      if (!entries.length) return false;
      const tree = document.createDocumentFragment();
      appendDocsEntries(tree, entries);
      elements.docsHelpNav.replaceChildren(tree);
      elements.docsHelpNav.setAttribute('aria-busy', 'false');
      docsTreeLoaded = true;
      return true;
    } catch (_) {
      return false;
    }
  }

  function setHelpVariant(useDocs) {
    if (elements.fallbackHelp) elements.fallbackHelp.hidden = useDocs;
    if (elements.docsHelp) elements.docsHelp.hidden = !useDocs;
    if (useDocs && docsTabById(explorerView)) setExplorerView(explorerView);
  }

  function disableDocsExplorer() {
    docsAvailable = false;
    const wasDocs = Boolean(docsTabById(explorerView));
    docsTabs.length = 0;
    renderExplorerTabs('docs');
    if (wasDocs) setExplorerView(explorerOrder[0] || '');
    setHelpVariant(false);
  }

  //  Documentation is optional: the help panel falls back to the
  //  consumer's own content when /docs is not served here.
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
      const docsPath = responseUrl.pathname === '/docs'
        || responseUrl.pathname.startsWith('/docs/');
      docsAvailable = response.ok
        && responseUrl.origin === window.location.origin && docsPath
        && contentType.includes('text/html');
      if (docsAvailable) docsAvailable = await loadDocsTree();
    } catch (_) {
      docsAvailable = false;
    } finally {
      docsCheckPending = false;
    }
    if (docsAvailable) setHelpVariant(true);
    else disableDocsExplorer();
  }

  // ---- menus and tablists ------------------------------------------
  //
  // Keyboard mechanics over markup urui or a consumer owns; the commands
  // and the content stay the owner's.  Both are `runtime.a11y`.
  //
  // `createMenu(menu, {onClose})` drives a role=menu element holding
  // role=menuitem buttons.  `open(source, event)` shows it at the
  // pointer for a contextmenu event, else beside `source`, clamped to
  // the viewport, and focuses the first item.  Up and Down wrap, Home
  // and End go to the ends, and Escape or Tab closes it and focuses
  // `source` again.  The shortcut dispatcher closes an open menu on
  // Escape too, wherever focus is.  A click outside the menu and
  // `source` closes it, as does a window resize.  `onClose` runs after
  // every close of an open menu.
  //
  // `createTablist(list)` drives the role=tab buttons inside `list`.
  // The selected tab (aria-selected="true") is the one tab stop; Left
  // and Right (Up and Down under aria-orientation="vertical") wrap, and
  // Home and End go to the ends.  A key moves focus to a tab and clicks
  // it, so the owner's click handler stays the one place selection
  // changes.  `sync()` re-reads the selection after the owner changes it
  // without a click.
  const menus = [];

  function roleItems(root, role) {
    const found = [];
    const walk = (node) => {
      for (const child of Array.from(node?.children || [])) {
        if (child.hidden) continue;
        if (child.getAttribute?.('role') === role && !child.disabled) {
          found.push(child);
        }
        walk(child);
      }
    };
    walk(root);
    return found;
  }

  function stepIndex(key, current, count, back, forward) {
    if (key === 'Home') return 0;
    if (key === 'End') return count - 1;
    if (key === back) return (current - 1 + count) % count;
    if (key === forward) return (current + 1) % count;
    return undefined;
  }

  function createMenu(menu, choices = {}) {
    let source = null;
    const isOpen = () => Boolean(menu) && !menu.hidden;

    function close(restoreFocus = false) {
      if (!menu) return;
      const wasOpen = isOpen();
      const from = source;
      menu.hidden = true;
      source = null;
      from?.setAttribute?.('aria-expanded', 'false');
      if (wasOpen) choices.onClose?.();
      if (restoreFocus) from?.focus?.();
    }

    function open(from, event) {
      if (!menu) return;
      close();
      source = from || null;
      source?.setAttribute?.('aria-expanded', 'true');
      menu.style.left = '0px';
      menu.style.top = '0px';
      menu.hidden = false;
      const menuRect = menu.getBoundingClientRect();
      const anchor = source?.getBoundingClientRect?.();
      const pointer = event?.type === 'contextmenu' || !anchor;
      const margin = 8;
      const maximumLeft = window.innerWidth - menuRect.width - margin;
      const maximumTop = window.innerHeight - menuRect.height - margin;
      menu.style.left = `${clamp(
        pointer ? event?.clientX ?? 0 : anchor.right,
        margin,
        Math.max(margin, maximumLeft)
      )}px`;
      menu.style.top = `${clamp(
        pointer ? event?.clientY ?? 0 : anchor.top,
        margin,
        Math.max(margin, maximumTop)
      )}px`;
      roleItems(menu, 'menuitem')[0]?.focus();
    }

    function keydown(event) {
      if (event.key === 'Escape' || event.key === 'Tab') {
        event.preventDefault();
        close(true);
        return;
      }
      const items = roleItems(menu, 'menuitem');
      const next = stepIndex(
        event.key, items.indexOf(document.activeElement), items.length,
        'ArrowUp', 'ArrowDown'
      );
      if (next === undefined || !items.length) return;
      event.preventDefault();
      items[next].focus();
    }

    menu?.addEventListener('keydown', keydown);
    document.addEventListener('click', (event) => {
      if (!isOpen() || menu.contains(event.target)) return;
      if (source?.contains?.(event.target)) return;
      close();
    });
    const control = {open, close, isOpen, keydown, source: () => source};
    menus.push(control);
    return control;
  }

  function createTablist(list) {
    const tabs = () => roleItems(list, 'tab');

    function sync() {
      const all = tabs();
      const selected = all.find((tab) => {
        return tab.getAttribute('aria-selected') === 'true';
      }) || all[0];
      for (const tab of all) tab.tabIndex = tab === selected ? 0 : -1;
    }

    list?.addEventListener('keydown', (event) => {
      const all = tabs();
      const current = all.indexOf(event.target);
      if (current < 0) return;
      const vertical = list.getAttribute('aria-orientation') === 'vertical';
      const next = stepIndex(
        event.key, current, all.length,
        vertical ? 'ArrowUp' : 'ArrowLeft',
        vertical ? 'ArrowDown' : 'ArrowRight'
      );
      if (next === undefined) return;
      event.preventDefault();
      all[next].focus();
      all[next].click();
      sync();
    });
    list?.addEventListener('click', sync);
    sync();
    return {sync};
  }

  // ---- the file context menu ---------------------------------------
  //
  // One menu for every file tree: right-click (or a row's own button)
  // opens it.  `contextTarget` is the file it acts on.
  const fileMenu = createMenu(elements.contextMenu, {
    onClose: () => { contextTarget = {}; }
  });

  function closeFileContext(restoreFocus = false) {
    fileMenu.close(restoreFocus);
    contextTarget = {};
  }

  function openFileContext(name, path, source, event) {
    event.preventDefault();
    event.stopPropagation();
    if (elements.contextDelete) {
      elements.contextDelete.disabled = docPaneReadOnly(name);
    }
    fileMenu.open(source, event);
    contextTarget = {kind: name, path, source};
  }

  // ---- persistence --------------------------------------------------
  //
  // One localStorage record under `config.appId.storageKey`, described
  // slot by slot by `config.slots`.  Each slot names the json key as it
  // already appears on disk, so an existing record keeps loading with no
  // migration.  urui owns the shell's slots; a slot marked `app` is read
  // and written through `options.session`.
  const storageKey = config.appId?.storageKey;
  const storageVersion = config.appId?.storageVersion ?? 1;
  const slots = config.slots || [];
  const maxSource = limits.maxSource ?? 262144;
  let saveTimer;
  let saveFailing = false;

  function sourceByteLength(source) {
    return new TextEncoder().encode(source).byteLength;
  }

  function validateSource(source, limit = maxSource) {
    if (typeof source !== 'string') throw new Error('Source must be text');
    if (source.includes('\0')) throw new Error('Source contains a null byte');
    if (sourceByteLength(source) > limit) {
      throw new Error(`Source exceeds the ${limit}-byte limit`);
    }
    return source;
  }

  //  Restoring checks shape, never size: text the user already has is
  //  not dropped.  The size limit belongs to load, save, and render.
  function validSavedSource(source) {
    return typeof source === 'string' && !source.includes('\0')
      ? source : undefined;
  }

  function validTabLabel(label, fallback) {
    return typeof label === 'string' && label.trim() && label.length <= 200
      ? label.trim()
      : fallback;
  }

  function idPattern(prefix) {
    return new RegExp(`^${prefix}-[1-9][0-9]*$`);
  }

  //  A saved id carries its own counter: `note-7` means the next tab is
  //  at least 8, however stale the saved counter is.
  function highestId(tabs) {
    return tabs.reduce((highest, tab) => {
      return Math.max(highest, Number(tab.id.split('-').pop()) + 1);
    }, 1);
  }

  function validDocsTab(candidate) {
    if (!candidate || typeof candidate !== 'object') return undefined;
    if (!idPattern('docs').test(candidate.id)) return undefined;
    if (typeof candidate.title !== 'string' || !candidate.title.trim()
      || candidate.title.length > 200) return undefined;
    if (typeof candidate.path !== 'string' || !candidate.path
      || candidate.path.length > 1_024
      || candidate.path.startsWith('/')
      || candidate.path.split('/').some((part) => {
        return !part || part === '.' || part === '..';
      })) return undefined;
    return {
      id: candidate.id,
      title: candidate.title.trim(),
      path: candidate.path
    };
  }

  function validRefTab(candidate) {
    if (!candidate || typeof candidate !== 'object') return undefined;
    if (!idPattern('ref').test(candidate.id)) return undefined;
    const hooks = refHooks(candidate.kind);
    if (!hooks?.validate || hooks.persist === false) return undefined;
    const parentId = String(candidate.parentId ?? '');
    if (!parentId || parentId.length > 200) return undefined;
    const data = hooks.validate(candidate.data);
    if (data === undefined) return undefined;
    return {
      id: candidate.id,
      kind: candidate.kind,
      parentId,
      label: validTabLabel(candidate.label, 'Reference'),
      data
    };
  }

  //  `preferences.theme` is one slot naming a nested json key
  function readEnvelope(saved, key) {
    return key.split('.').reduce((node, part) => {
      return node === undefined || node === null ? undefined : node[part];
    }, saved);
  }

  function writeEnvelope(record, key, value) {
    const parts = key.split('.');
    const leaf = parts.pop();
    let node = record;
    for (const part of parts) {
      if (!node[part]) node[part] = {};
      node = node[part];
    }
    node[leaf] = value;
  }

  //  What urui writes for its own slots, by key and by shape.
  function readSlot(slot) {
    if (slot.owner === 'app') return options.session?.read?.(slot.key);
    if (slot.kind) {
      return documentStore(slot.kind) ? documentReadSlot(slot) : undefined;
    }
    switch (slot.key) {
      case 'paneWidth': return paneWidth();
      case 'explorerWidth': return explorerWidth();
      case 'explorerOpen': return explorerOpen;
      case 'explorerView': return explorerView;
      case 'explorerOrder': return explorerOrder;
      case 'docsTabs': return docsTabs;
      case 'nextDocs': return nextDocs;
      case 'refTabs':
        return refTabs.filter((tab) => refHooks(tab.kind)?.persist !== false);
      case 'nextRef': return nextRef;
      case 'paneBands': return paneBands;
      case 'panePaths': return panePaths;
      case 'preferences.theme': return selectedTheme();
      case 'preferences.layout': return layout;
      case 'preferences.keybindings': return keybindings;
      case 'paneHeight': return paneHeight();
      case 'resultOpen': return resultOpen;
      case 'fileTrees': return documentTreeState();
      default: return undefined;
    }
  }

  function saveSession() {
    clearTimeout(saveTimer);
    try {
      documentCaptureAll();
      const record = {version: storageVersion};
      for (const slot of slots) {
        writeEnvelope(record, slot.key, readSlot(slot));
      }
      localStorage.setItem(storageKey, JSON.stringify(record));
      saveFailing = false;
    } catch (cause) {
      //  storage can be disabled or full without blocking the editor;
      //  the user hears once per run of failures
      if (!saveFailing) {
        saveFailing = true;
        notify(`Session not saved: ${cause?.message || cause}`, {
          kind: 'error'
        });
      }
    }
  }

  function queueSaveSession() {
    clearTimeout(saveTimer);
    saveTimer = setTimeout(saveSession, limits.saveDebounce ?? 150);
  }

  //  Validate the whole record, then apply urui's half of it.  The
  //  consumer gets the record back and reads only its own slots.
  function loadSession() {
    let saved;
    try {
      saved = JSON.parse(localStorage.getItem(storageKey));
    } catch (_) {
      return undefined;
    }
    if (!saved || saved.version !== storageVersion) return undefined;
    const record = {};
    const acceptedIds = new Map();

    //  documents first: references and the active id point at them
    for (const slot of slots) {
      if (slot.owner !== 'urui' || slot.shape !== 'tabs'
        || !documentStore(slot.kind)) {
        continue;
      }
      const seenIds = new Set();
      const seenPaths = new Set();
      const raw = readEnvelope(saved, slot.key);
      const tabs = Array.isArray(raw)
        ? raw.map((candidate) => {
          return documentValidTab(candidate, slot.kind, acceptedIds);
        }).filter((tab) => {
          if (!tab || seenIds.has(tab.id)) return false;
          const where = tab.path ? tab.path.join('/') : '';
          if (where && seenPaths.has(where)) return false;
          seenIds.add(tab.id);
          if (where) seenPaths.add(where);
          return true;
        })
        : [];
      acceptedIds.set(slot.kind, seenIds);
      record[slot.key] = tabs;
    }

    const docsSlot = slots.find((slot) => {
      return slot.owner === 'urui' && slot.shape === 'tabs' && !slot.kind
        && slot.key === 'docsTabs';
    });
    let savedDocsTabs = [];
    if (docsSlot) {
      const seenIds = new Set();
      const seenPaths = new Set();
      const raw = readEnvelope(saved, docsSlot.key);
      savedDocsTabs = Array.isArray(raw)
        ? raw.map(validDocsTab).filter((tab) => {
          if (!tab || seenIds.has(tab.id) || seenPaths.has(tab.path)) {
            return false;
          }
          seenIds.add(tab.id);
          seenPaths.add(tab.path);
          return true;
        })
        : [];
      record[docsSlot.key] = savedDocsTabs;
    }

    const refsSlot = slots.find((slot) => {
      return slot.owner === 'urui' && slot.shape === 'tabs' && !slot.kind
        && slot.key === 'refTabs';
    });
    let savedRefTabs = [];
    if (refsSlot) {
      const seenIds = new Set();
      const seenParents = new Set();
      const raw = readEnvelope(saved, refsSlot.key);
      savedRefTabs = Array.isArray(raw)
        ? raw.map(validRefTab).filter((tab) => {
          if (!tab || seenIds.has(tab.id)) return false;
          const parentKey = `${tab.kind}:${tab.parentId}`;
          if (seenParents.has(parentKey)) return false;
          seenIds.add(tab.id);
          seenParents.add(parentKey);
          return true;
        })
        : [];
      record[refsSlot.key] = savedRefTabs;
    }

    //  the strip can hold every permanent view plus what survived
    const availableViews = [
      ...permanentViews,
      ...savedDocsTabs.map((tab) => tab.id),
      ...savedRefTabs.map((tab) => tab.id)
    ];

    for (const slot of slots) {
      if (record[slot.key] !== undefined) continue;
      const raw = readEnvelope(saved, slot.key);
      if (slot.owner === 'app') {
        record[slot.key] = options.session?.validate?.(slot.key, raw);
        continue;
      }
      if (slot.kind && slot.shape === 'active') {
        const ids = acceptedIds.get(slot.kind);
        const tabs = record[tabsKeyFor(slot.kind)] || [];
        record[slot.key] = ids?.has(raw) ? raw : tabs[0]?.id;
        continue;
      }
      if (slot.shape === 'next') {
        const tabs = slot.kind
          ? record[tabsKeyFor(slot.kind)] || []
          : (slot.key === 'nextDocs' ? savedDocsTabs : savedRefTabs);
        const floor = highestId(tabs);
        const value = Number(raw);
        record[slot.key] = Number.isSafeInteger(value)
          ? Math.max(value, floor)
          : floor;
        continue;
      }
      switch (slot.key) {
        case 'paneWidth': {
          const value = Number(raw);
          record[slot.key] = Number.isFinite(value)
            ? clamp(value, paneMin, paneMax)
            : 44;
          break;
        }
        case 'explorerWidth': {
          const value = Number(raw);
          record[slot.key] = Number.isFinite(value)
            ? Math.max(value, minExplorer)
            : 288;
          break;
        }
        case 'explorerOpen':
        case 'resultOpen':
          record[slot.key] = raw !== false;
          break;
        case 'explorerView':
          record[slot.key] = typeof raw === 'string'
            && availableViews.includes(raw) ? raw : firstView;
          break;
        case 'explorerOrder': {
          const order = Array.isArray(raw)
            ? raw.filter((id, index, items) => {
              return typeof id === 'string' && availableViews.includes(id)
                && items.indexOf(id) === index;
            })
            : [];
          for (const id of availableViews) {
            if (!order.includes(id)) order.push(id);
          }
          record[slot.key] = order;
          break;
        }
        case 'paneBands':
          record[slot.key] = validBandRecord(raw);
          break;
        case 'panePaths':
          record[slot.key] = validPathRecord(raw);
          break;
        case 'preferences.theme':
          record[slot.key] = validTheme(raw);
          break;
        case 'preferences.layout':
          record[slot.key] = validLayout(raw);
          break;
        case 'preferences.keybindings':
          record[slot.key] = validKeybindings(raw);
          break;
        case 'fileTrees':
          record[slot.key] = documentValidTreeState(raw);
          break;
        default:
          record[slot.key] = raw;
      }
    }

    applySession(record);
    return record;
  }

  function tabsKeyFor(name) {
    return slots.find((slot) => {
      return slot.kind === name && slot.shape === 'tabs';
    })?.key;
  }

  //  Apply urui's slots without persisting: this is a restore, not an
  //  edit, and writing here would race the record being read.
  function applySession(record) {
    for (const slot of slots) {
      if (slot.owner !== 'urui') continue;
      const value = record[slot.key];
      if (value === undefined) continue;
      if (slot.kind) {
        if (documentStore(slot.kind)) documentApplySlot(slot, value);
        continue;
      }
      switch (slot.key) {
        case 'paneWidth': setPaneWidth(value, false); break;
        case 'explorerWidth': setExplorerWidth(value); break;
        case 'explorerOpen': setExplorerOpen(value, false); break;
        //  assigned, not applied: the docs and reference tabs this view
        //  may name are restored further down the same loop, and
        //  ++setExplorerView re-validates once they are all there
        case 'explorerView': explorerView = value; break;
        case 'explorerOrder': explorerOrder = value; break;
        case 'docsTabs': docsTabs.splice(0, docsTabs.length, ...value); break;
        case 'nextDocs': nextDocs = value; break;
        case 'refTabs': refTabs.splice(0, refTabs.length, ...value); break;
        case 'nextRef': nextRef = value; break;
        case 'paneBands': paneBands = value; applyBands(); break;
        case 'panePaths': panePaths = value; break;
        case 'preferences.theme': applyTheme(value, false); break;
        case 'preferences.layout': setLayout(value, false); break;
        case 'preferences.keybindings': setKeybindings(value, false); break;
        case 'paneHeight': setPaneHeight(value, false); break;
        case 'resultOpen': setResultOpen(value, false); break;
        case 'fileTrees': documentSetTreeState(value); break;
        default: break;
      }
    }
  }

  // ---- shared source in the url -------------------------------------
  //
  // A store's `share` names a url query parameter that carries one
  // document's source, base64url-encoded. `decodeSource` refuses a
  // parameter that is absent, oversized, or does not round-trip.

  function encodeSource(source) {
    const bytes = new TextEncoder().encode(source);
    let binary = '';
    for (const byte of bytes) binary += String.fromCharCode(byte);
    return btoa(binary)
      .replace(/\+/g, '-')
      .replace(/\//g, '_')
      .replace(/=+$/g, '');
  }

  //  A shared link must round-trip exactly: anything that re-encodes
  //  differently is a mangled or hand-edited parameter, not a source.
  function decodeSource(encoded, spec) {
    if (!spec) throw new Error('This application does not share sources');
    if (!encoded || encoded.length > spec.paramMax) {
      throw new Error(`Shared ${spec.name} parameter is missing or too large`);
    }
    if (!/^[A-Za-z0-9_-]+$/.test(encoded)) {
      throw new Error(`Shared ${spec.name} parameter is invalid`);
    }
    const base64 = encoded.replace(/-/g, '+').replace(/_/g, '/');
    const padded = base64 + '='.repeat((4 - base64.length % 4) % 4);
    const binary = atob(padded);
    const bytes = Uint8Array.from(binary, (char) => char.charCodeAt(0));
    const source = new TextDecoder('utf-8', {fatal: true}).decode(bytes);
    validateSource(source, spec.max);
    if (encodeSource(source) !== encoded) {
      throw new Error(`Shared ${spec.name} parameter is not canonical`);
    }
    return source;
  }

  '''
  shortcuts
  documents
  '''
  // ---- wiring -------------------------------------------------------
  //
  // Everything above is callable on its own; `wire` is what turns the
  // frame into a live surface.  A consumer that wants different
  // behavior simply does not call it.  `options.onResize` runs on every
  // window resize, before the editors are refreshed.
  //  The standard boot, in order: wire the frame, load the session, lay
  //  out and draw the explorer, start the document stores, then check
  //  for the docs site.  `restore(record)` runs once the session is
  //  applied and before the stores start, with the app slots' record
  //  (undefined when nothing was saved); `start` returns the same record.
  //  The stores' tree browses go out before the docs check.
  function start(restore) {
    wire();
    const saved = loadSession();
    applyExplorerLayout();
    renderExplorerTabs('docs');
    renderExplorerTabs('ref');
    setExplorerView(explorerView);
    restore?.(saved);
    documentStart();
    refreshHelpVariant();
    return saved;
  }

  function wire() {
    document.addEventListener('keydown', dispatchShortcut, {capture: true});
    applyTips();
    wireFullscreen();
    elements.contextOpen?.addEventListener('click', () => {
      const {kind, path} = contextTarget;
      closeFileContext();
      if (kind && path) documentOpenContext(kind, path);
    });
    elements.contextDelete?.addEventListener('click', () => {
      const {kind, path, source} = contextTarget;
      closeFileContext();
      if (kind && path) documentRemoveContext(kind, path, source);
    });
    documentsWire();
    elements.themeControl?.addEventListener('change', () => {
      applyTheme(elements.themeControl.value);
    });
    if (themeMedia.addEventListener) {
      themeMedia.addEventListener('change', systemThemeChanged);
    } else {
      themeMedia.addListener(systemThemeChanged);
    }
    elements.helpToggle?.addEventListener('click', () => setHelpOpen(true));
    elements.closeHelp?.addEventListener('click', () => {
      setHelpOpen(false, true);
    });
    elements.helpPanel?.addEventListener('click', (event) => {
      if (event.target === elements.helpPanel) setHelpOpen(false, true);
    });
    elements.explorerCollapse?.addEventListener('click', () => {
      setExplorerOpen(!explorerOpen);
    });
    elements.explorerResizer?.addEventListener('pointerdown', (event) => {
      if (narrowMedia.matches) return;
      elements.explorerResizer.setPointerCapture(event.pointerId);
    });
    elements.explorerResizer?.addEventListener('pointermove', (event) => {
      if (!elements.explorerResizer.hasPointerCapture(event.pointerId)) return;
      const bounds = elements.workbench.getBoundingClientRect();
      setExplorerWidth(event.clientX - bounds.left, true);
    });
    elements.explorerResizer?.addEventListener('keydown', (event) => {
      if (event.key !== 'ArrowLeft' && event.key !== 'ArrowRight') return;
      event.preventDefault();
      const change = event.key === 'ArrowLeft' ? -16 : 16;
      setExplorerWidth(explorerWidth() + change, true);
    });
    elements.resultCollapse?.addEventListener('click', () => {
      setResultOpen(!resultOpen);
    });
    elements.splitter?.addEventListener('pointerdown', (event) => {
      if (!resultOpen) return;
      elements.splitter.setPointerCapture(event.pointerId);
    });
    elements.splitter?.addEventListener('pointermove', (event) => {
      if (!elements.splitter.hasPointerCapture(event.pointerId)) return;
      const bounds = elements.workspace.getBoundingClientRect();
      if (layout === 'rows') {
        setPaneHeight(((event.clientY - bounds.top) / bounds.height) * 100);
      } else {
        setPaneWidth(((event.clientX - bounds.left) / bounds.width) * 100);
      }
    });
    elements.splitter?.addEventListener('keydown', (event) => {
      const keys = layout === 'rows'
        ? ['ArrowUp', 'ArrowDown']
        : ['ArrowLeft', 'ArrowRight'];
      if (!resultOpen || !keys.includes(event.key)) return;
      event.preventDefault();
      const step = event.key === keys[0] ? -2 : 2;
      if (layout === 'rows') setPaneHeight(paneHeight() + step);
      else setPaneWidth(paneWidth() + step);
    });
    elements.settingsToggle?.addEventListener('click', () => {
      setSettingsOpen(true);
    });
    elements.closeSettings?.addEventListener('click', () => {
      setSettingsOpen(false, true);
    });
    elements.settingsModal?.addEventListener('click', (event) => {
      if (event.target === elements.settingsModal) setSettingsOpen(false, true);
    });
    for (const choice of elements.layoutChoices || []) {
      choice.addEventListener('click', () => {
        setLayout(choice.dataset?.layout);
      });
    }
    for (const choice of elements.keyChoices || []) {
      choice.addEventListener('change', () => {
        if (choice.checked) setKeybindings(choice.value);
      });
    }
    //  a band the user may hide carries the toggle urui-shell drew for
    //  it beside it, at `{pane}-{band}-toggle`
    for (const pane of panes) {
      for (const band of pane.bands || []) {
        if (!band.reveal?.key) continue;
        document.querySelector(`#${pane.id}-${band.name}-toggle`)
          ?.addEventListener('click', () => {
            revealBand(pane.id, band.name);
          });
      }
    }
    applyBands();
    //  the screen format is a dom attribute the stylesheet reads, so it
    //  must be written once at boot even when no session restores it
    setLayout(layout, false);
    setKeybindings(keybindings, false);
    for (const name of permanentViews) {
      const tab = document.querySelector(`#${name}-tab`);
      if (!tab) continue;
      tab.addEventListener('click', () => {
        setExplorerView(tab.dataset.explorerView);
      });
      tab.addEventListener('keydown', explorerTabKeydown);
    }
    //  a reference is created by dropping a document tab, or anything
    //  the consumer made draggable, on the aside
    const droppableRef = () => {
      return Boolean(draggedTab?.ref) && Boolean(refHooks(draggedTab.ref.kind));
    };
    elements.explorerPane?.addEventListener('dragover', (event) => {
      if (!droppableRef()) return;
      event.preventDefault();
      if (event.dataTransfer) event.dataTransfer.dropEffect = 'copy';
    });
    elements.explorerPane?.addEventListener('drop', (event) => {
      if (!droppableRef()) return;
      event.preventDefault();
      event.stopPropagation?.();
      const payload = draggedTab.ref;
      draggedTab = undefined;
      openAppRef(payload);
    });
    window.addEventListener('beforeunload', saveSession);
    window.addEventListener('resize', () => {
      for (const menu of menus) menu.close();
      options.onResize?.();
      refreshEditors();
    });
    watchTitles();
  }

  // ---- the runtime object -------------------------------------------
  //
  // Runtime-internal, not the stable api: `window.urui` is the frozen
  // facade a consumer calls, this is the surface a consumer's hooks are
  // written against.  A plain unfrozen object, reachable only as the
  // value `urui.runtime(options)` returns.
  return {
    elements,
    clamp,
    refreshEditors,
    shortcuts: {register: registerShortcut, dispatch: dispatchShortcut},
    panes: {
      list: () => panes,
      get: (paneId) => paneById.get(paneId),
      levels: paneLevels,
      strip: stripFor,
      body: paneBody,
      readOnly: paneReadOnly,
      tabs: levelTabs,
      addLabel: levelAddLabel,
      closes: levelCloses,
      set: setLevelTabs,
      path: panePath,
      select: selectPanePath,
      selectLevel,
      close: closeLevelTab,
      panel: (paneId, path) => {
        return levelContent(paneId, path || panePath(paneId));
      },
      render: renderPane,
      renderAll: renderPanes,
      reveal: revealBand,
      isOpen: bandIsOpen,
      applyBands
    },
    theme: {
      valid: validTheme,
      selected: selectedTheme,
      apply: applyTheme,
      media: themeMedia,
      systemChanged: systemThemeChanged
    },
    status: {set: setStatus, node: statusNode},
    layout: {
      paneWidth,
      setPaneWidth,
      explorerWidth,
      setExplorerWidth,
      maxExplorerWidth,
      explorerOpen: () => explorerOpen,
      setExplorerOpen,
      resultOpen: () => resultOpen,
      setResultOpen,
      apply: applyExplorerLayout
    },
    explorer: {
      view: () => explorerView,
      setView: setExplorerView,
      onChange: onExplorerChange,
      validView: validExplorerView,
      order: () => explorerOrder,
      setOrder: (list) => { explorerOrder = list; },
      syncOrder: syncExplorerTabOrder,
      tabKeydown: explorerTabKeydown,
      buttons: explorerTabButtons,
      docs: {
        list: () => docsTabs,
        //  in place, like the document stores: a consumer may hold it
        setList: (list) => { docsTabs.splice(0, docsTabs.length, ...list); },
        next: () => nextDocs,
        setNext: (value) => { nextDocs = value; },
        byId: docsTabById,
        render: () => renderExplorerTabs('docs'),
        open: openDocsTab,
        close: closeDocsTab,
        label: docsTabLabel,
        parseToc: parseDocsToc,
        available: () => docsAvailable,
        refreshVariant: refreshHelpVariant,
        setVariant: setHelpVariant,
        disable: disableDocsExplorer
      },
      refs: {
        list: () => refTabs,
        setList: (list) => { refTabs.splice(0, refTabs.length, ...list); },
        next: () => nextRef,
        setNext: (value) => { nextRef = value; },
        byId: refTabById,
        render: () => renderExplorerTabs('ref'),
        open: openAppRef,
        update: updateAppRef,
        draggable: enableRefDrag,
        close: closeRefTab,
        forParent: refForParent
      },
      context: {
        open: openFileContext,
        close: closeFileContext,
        keydown: fileMenu.keydown,
        target: () => contextTarget
      }
    },
    session: {
      key: storageKey,
      version: storageVersion,
      load: loadSession,
      save: saveSession,
      queue: queueSaveSession,
      validateSource,
      byteLength: sourceByteLength,
      encodeSource,
      decodeSource
    },
    dialogs: {
      helpIsOpen,
      setHelpOpen,
      setSettingsOpen,
      setLayout
    },
    documents: documentApi,
    a11y: {menu: createMenu, tablist: createTablist},
    tip,
    fullscreen: {toggle: toggleFullscreen, sync: syncFullscreen},
    notify,
    confirm: confirmDialog,
    copy: copyText,
    start,
    wire
  };
  '''
  ==
::
++  shortcuts
  ::  Capture app chords before Ace, preserving unclaimed editor keys.
  ^-  @t
  '''
  // ---- shortcuts ----------------------------------------------------
  // `preview` is consumer-defined availability, independent of Ace focus.
  // Other contexts use editor focus. Unclaimed non-editor keys can reach
  // onKeydown; returning true consumes a consumer's contextual action.
  const shortcutCommands = new Map();

  function registerShortcut(command, handler) {
    if (typeof handler !== 'function') {
      throw new TypeError('Shortcut handler must be a function');
    }
    shortcutCommands.set(command, handler);
  }

  function shortcutMatches(shortcut, event) {
    const parts = shortcut.binding.toLowerCase().split('-');
    const key = parts.pop();
    const primary = parts.includes('ctrl') || parts.includes('meta');
    return String(event.key).toLowerCase() === key
      && Boolean(event.ctrlKey || event.metaKey) === primary
      && Boolean(event.shiftKey) === parts.includes('shift')
      && Boolean(event.altKey) === parts.includes('alt');
  }

  function dispatchShortcut(event) {
    const consume = () => {
      event.preventDefault();
      event.stopPropagation?.();
    };
    //  the top modal takes Escape and holds Tab; a bound chord behind it
    //  is swallowed, not run, and every other key reaches the modal
    const modal = topModal();
    if (modal) {
      if (event.key === 'Escape') {
        consume();
        modal.close();
      } else if (event.key === 'Tab') {
        if (modalTrapTab(event, modal.element())) consume();
      } else if ((config.shortcuts || []).some((shortcut) => {
        return shortcutMatches(shortcut, event);
      })) {
        consume();
      }
      return;
    }
    const menu = menus.find((item) => item.isOpen());
    if (event.key === 'Escape' && menu) {
      consume();
      menu.close(true);
      return;
    }
    const target = event.target || document.activeElement;
    const inEditor = editors().some((editor) => editor.isFocused?.(target));
    const contexts = {
      always: true,
      editor: inEditor,
      'no-editor': !inEditor,
      preview: options.shortcuts?.preview?.(event) ?? false
    };
    for (const shortcut of config.shortcuts || []) {
      if (!contexts[shortcut.when] || !shortcutMatches(shortcut, event)) {
        continue;
      }
      const handler = shortcutCommands.get(shortcut.command);
      if (!handler) continue;
      consume();
      handler(event);
      return;
    }
    if (inEditor) return;
    if (options.shortcuts?.onKeydown?.(event) === true) consume();
  }
  '''
::
++  documents
  ::  The document and file module in the runtime scope: stores, the
  ::  editor, previews, the tree, the file dialog, and feedback.  Live
  ::  only with `config.files`; see the section banner for the hooks.
  ^-  @t
  '''
  // ---- documents ----------------------------------------------------
  //
  // The document and file module, live only when `config.files` is set.
  // One store per `config.files.stores` entry, each rendered by the
  // %documents tab level whose `kind` names it.
  //
  // Behaviour is urui's and the same for every application: labels,
  // draft names, dirtiness, reopening, the file dialog, conflicts,
  // deletes, the editor and its load failure, source and preview, the
  // tree, references, and feedback.  An application supplies data in
  // `config.files` and domain logic through `options.documents[store]`:
  //
  //   fields.defaults(init)             app fields on a new tab
  //   fields.validate(saved, tab, ids)  app fields restored from a record
  //   activate(tab, choices)            domain reaction to a switch
  //   afterActivate(tab, choices)       the same, after render and save
  //   loaded(tab), saved(tab)           keep app data in step
  //
  // `options.onFile({store, op, phase, path, error})` reports each file
  // operation; `options.transport` replaces the json wire, for tests.
  // `runtime.documents.previews.register(mark, factory)` adds a preview.
  // `factory({host, store})` mounts one instance into one store's
  // preview host and returns `{show(tab), hide(), dispose()}`; each
  // store showing that mark gets its own instance.  `factory.render(
  // panel, text)` draws a reference.  Registering a mark again disposes
  // its instances; the stores showing it rebuild from the new factory.
  const filesConfig = config.files || null;
  const docStores = new Map((filesConfig?.stores || []).map((item) => {
    return [item.name, item];
  }));
  const docState = new Map([...docStores.keys()].map((name) => {
    return [name, {tabs: [], activeId: undefined, next: 1}];
  }));
  const docTrees = filesConfig?.trees || [];
  const docEditorsByStore = new Map();
  const docEditorFailed = new Set();
  const docPreviewers = new Map();
  const docPreviewInstances = new Map();
  const docOpening = new Map();
  const docTransport = options.transport
    || (filesConfig ? docJsonTransport(filesConfig.url) : null);
  let docTreeState = {};
  let docStarted = false;
  let docToastTimer;
  let docDialog;
  let docConfirm;

  function documentStore(name) {
    return docStores.has(name);
  }

  function docHooks(name) {
    return (options.documents || {})[name] || {};
  }

  function docEvent(name, op, phase, path, error) {
    options.onFile?.({store: name, op, phase, path, error});
  }

  //  ---- paths and labels
  //
  //  A path is its segments, relative to the app's file root, ending in
  //  the stored mark; the segment before the mark is the file's name.
  function samePath(left, right) {
    return Array.isArray(left) && Array.isArray(right)
      && left.length === right.length
      && left.every((part, index) => part === right[index]);
  }

  function pathText(path) {
    return Array.isArray(path) ? path.join('/') : '';
  }

  function docRootOf(name, path) {
    if (!Array.isArray(path)) return undefined;
    return (docStores.get(name)?.roots || []).find((root) => {
      return path.length > root.scope.length + 1
        && samePath(root.scope, path.slice(0, root.scope.length))
        && root.marks.includes(path[path.length - 1]);
    });
  }

  function docMarkOf(path) {
    return Array.isArray(path) ? path[path.length - 1] : undefined;
  }

  function docBaseLabel(name, path) {
    const root = docRootOf(name, path);
    const mark = docMarkOf(path);
    return `${path[path.length - 2]}.${root?.ext || mark}`;
  }

  //  Clashing labels gain parent directories, one at a time, until
  //  each is unique or runs out of directories.
  function docLabels(name) {
    const tabs = docState.get(name).tabs;
    const labels = new Map();
    const depth = new Map(tabs.map((tab) => [tab.id, 0]));
    const labelOf = (tab) => {
      if (!tab.path) return tab.draft;
      const base = docBaseLabel(name, tab.path);
      const dirs = tab.path.slice(0, -2);
      const shown = dirs.slice(dirs.length - depth.get(tab.id));
      return [...shown, base].join('/');
    };
    for (let round = 0; round < 32; round += 1) {
      const counts = new Map();
      for (const tab of tabs) {
        const label = labelOf(tab);
        labels.set(tab.id, label);
        counts.set(label, (counts.get(label) || 0) + 1);
      }
      let grew = false;
      for (const tab of tabs) {
        if (!tab.path || counts.get(labels.get(tab.id)) < 2) continue;
        if (depth.get(tab.id) < tab.path.length - 2) {
          depth.set(tab.id, depth.get(tab.id) + 1);
          grew = true;
        }
      }
      if (!grew) break;
    }
    return labels;
  }

  function docRelabel(name) {
    const labels = docLabels(name);
    for (const tab of docState.get(name).tabs) tab.label = labels.get(tab.id);
  }

  //  `untitled`, then `untitled 2`, `untitled 3`, reusing the lowest.
  function docDraftLabel(name) {
    const base = docStores.get(name).untitled || 'Untitled';
    const used = new Set(docState.get(name).tabs.map((tab) => tab.draft));
    if (!used.has(base)) return base;
    let number = 2;
    while (used.has(`${base} ${number}`)) number += 1;
    return `${base} ${number}`;
  }

  //  A store whose %documents level sits in a %read-only pane writes
  //  nothing: no save, no Save As, no delete, and no edit, drafts
  //  included.
  function docPaneReadOnly(name) {
    const bound = levelForKind(name);
    return Boolean(bound) && paneReadOnly(bound.paneId);
  }

  function docCanSave(name, path) {
    if (docPaneReadOnly(name)) return false;
    return !path || Boolean(docRootOf(name, path)?.save);
  }

  function docDirty(name, id) {
    const tab = docGet(name, id);
    return Boolean(tab) && tab.text !== tab.clean;
  }

  //  ---- tabs
  function docTabs(name) {
    const state = docState.get(name);
    if (!state) throw new Error(`unknown document store: ${name}`);
    return state.tabs;
  }

  function docGet(name, id) {
    return docTabs(name).find((tab) => tab.id === id);
  }

  function docActive(name) {
    return docGet(name, docState.get(name)?.activeId);
  }

  function documentActiveId(name) {
    return docState.get(name)?.activeId;
  }

  function docDefaultDisplay(name) {
    return docStores.get(name)?.preview || 'source';
  }

  function docCreate(name, init = {}) {
    const state = docState.get(name);
    const storeConfig = docStores.get(name);
    const path = Array.isArray(init.path) ? init.path.slice() : null;
    const text = String(init.text ?? storeConfig.starter ?? '');
    const tab = {
      id: `${name}-${state.next++}`,
      path,
      draft: path ? undefined : (init.label || docDraftLabel(name)),
      text,
      clean: init.clean ?? text,
      hash: init.hash ?? null,
      selection: init.selection || {start: 0, end: 0},
      display: init.display || docDefaultDisplay(name),
      ...(docHooks(name).fields?.defaults?.(init) || {}),
      ...(init.fields || {})
    };
    state.tabs.push(tab);
    docRelabel(name);
    if (init.activate === false) {
      docRender(name);
      changed();
    } else {
      docSelect(name, tab.id, {focus: init.focus});
    }
    return tab;
  }

  function docUpdate(name, id, change = {}) {
    const tab = docGet(name, id);
    if (!tab) return undefined;
    if (change.text !== undefined && docPaneReadOnly(name)) return undefined;
    const active = tab.id === documentActiveId(name);
    if (active) docCapture(name);
    if (change.text !== undefined) tab.text = String(change.text);
    if (change.label !== undefined && !tab.path) tab.draft = change.label;
    if (change.fields) Object.assign(tab, change.fields);
    docRelabel(name);
    if (active && change.text !== undefined) docShow(name);
    docSyncRef(name, tab);
    docRender(name);
    changed();
    return tab;
  }

  function docCapture(name) {
    const tab = docActive(name);
    if (!tab) return undefined;
    const editor = docEditorsByStore.get(name);
    if (editor && tab.display !== 'preview') {
      tab.text = editor.getSource();
      tab.selection = editor.getSelection();
    }
    return tab;
  }

  function documentCaptureAll() {
    for (const name of docStores.keys()) docCapture(name);
  }

  function docSelect(name, id, choices = {}) {
    const state = docState.get(name);
    const tab = docGet(name, id);
    if (!tab) return undefined;
    if (id === state.activeId && !choices.reactivate) {
      if (choices.focus) docFocus(name);
      return tab;
    }
    if (id !== state.activeId) docCapture(name);
    const previousId = state.activeId;
    state.activeId = id;
    //  the pane path moves first, so a level filled from `activate`
    //  files its tabs under the tab they belong to
    syncStorePath(name);
    docShow(name);
    docHooks(name).activate?.(tab, {...choices, previousId});
    docRender(name);
    changed();
    docHooks(name).afterActivate?.(tab, {...choices, previousId});
    if (choices.focus) docFocus(name);
    return tab;
  }

  function docFocus(name) {
    const tab = docActive(name);
    if (!tab) return;
    if (tab.display === 'preview' && docPreviewerFor(name, tab)) {
      docPreviewHost(name)?.focus?.();
    } else {
      docEditorsByStore.get(name)?.focus();
    }
  }

  async function docClose(name, id) {
    const tabs = docTabs(name);
    const index = tabs.findIndex((tab) => tab.id === id);
    if (index < 0) return false;
    if (id === documentActiveId(name)) docCapture(name);
    const tab = tabs[index];
    if (tab.text !== tab.clean
      && !await confirmDialog('discard', {label: tab.label})) return false;
    const wasActive = id === documentActiveId(name);
    tabs.splice(index, 1);
    if (!tabs.length) {
      docState.get(name).activeId = undefined;
      docCreate(name, {focus: true});
      return true;
    }
    docRelabel(name);
    if (wasActive) {
      docState.get(name).activeId = undefined;
      docSelect(name, tabs[Math.min(index, tabs.length - 1)].id, {focus: true});
    } else {
      docRender(name);
      changed();
    }
    return true;
  }

  function docMove(name, sourceId, targetId, after) {
    const tabs = docTabs(name);
    const source = tabs.findIndex((tab) => tab.id === sourceId);
    if (source < 0 || sourceId === targetId) return;
    const [moved] = tabs.splice(source, 1);
    const target = tabs.findIndex((tab) => tab.id === targetId);
    tabs.splice(target < 0 ? tabs.length : target + (after ? 1 : 0), 0, moved);
    docRender(name);
    changed();
  }

  //  ---- the strip
  function documentLevelTabs(name) {
    return docTabs(name).map((tab) => {
      return {
        id: tab.id, label: tab.label, title: pathText(tab.path) || tab.label
      };
    });
  }

  function docTabKeydown(event, name) {
    if (!['ArrowLeft', 'ArrowRight', 'Home', 'End'].includes(event.key)) {
      return;
    }
    event.preventDefault();
    const tabs = docTabs(name);
    const current = tabs.findIndex((tab) => {
      return tab.id === event.currentTarget.dataset.documentTab;
    });
    let next = current;
    if (event.key === 'Home') next = 0;
    else if (event.key === 'End') next = tabs.length - 1;
    else if (event.key === 'ArrowLeft') {
      next = (current - 1 + tabs.length) % tabs.length;
    } else {
      next = (current + 1) % tabs.length;
    }
    docSelect(name, tabs[next].id);
    tabContainer(name)?.querySelector?.(
      `[data-document-tab="${tabs[next].id}"]`
    )?.focus();
  }

  function docDragWrapper(wrapper, name, tab) {
    const refs = docStores.get(name).refs;
    wrapper.draggable = true;
    wrapper.addEventListener('dragstart', (event) => {
      if (tab.id === documentActiveId(name)) docCapture(name);
      draggedTab = refs
        ? {kind: name, id: tab.id, ref: {kind: name, parentId: tab.id}}
        : {kind: name, id: tab.id};
      wrapper.classList.add('is-dragging');
      event.dataTransfer?.setData('text/plain', tab.id);
      if (event.dataTransfer) event.dataTransfer.effectAllowed = 'copyMove';
    });
    wrapper.addEventListener('dragover', (event) => {
      if (draggedTab?.kind !== name) return;
      event.preventDefault();
      if (event.dataTransfer) event.dataTransfer.dropEffect = 'move';
    });
    wrapper.addEventListener('drop', (event) => {
      if (draggedTab?.kind !== name) return;
      event.preventDefault();
      event.stopPropagation?.();
      const bounds = wrapper.getBoundingClientRect();
      const after = event.clientX > bounds.left + bounds.width / 2;
      const moved = draggedTab.id;
      draggedTab = undefined;
      docMove(name, moved, tab.id, after);
    });
    wrapper.addEventListener('dragend', () => {
      wrapper.classList.remove('is-dragging');
      draggedTab = undefined;
    });
  }

  function docRender(name) {
    docApplyActions(name);
    const container = tabContainer(name);
    if (!container) return;
    const bound = levelForKind(name);
    const closes = levelCloses(bound?.paneId, bound?.level);
    const activeId = documentActiveId(name);
    container.replaceChildren();
    for (const tab of docTabs(name)) {
      const dirty = tab.text !== tab.clean;
      const wrapper = document.createElement('div');
      wrapper.className = 'document-tab-control';
      wrapper.classList.toggle('active', tab.id === activeId);
      wrapper.setAttribute('role', 'presentation');
      const control = document.createElement('button');
      control.type = 'button';
      control.className = 'document-tab';
      control.dataset.documentTab = tab.id;
      control.setAttribute('role', 'tab');
      control.setAttribute('aria-selected', String(tab.id === activeId));
      control.tabIndex = tab.id === activeId ? 0 : -1;
      control.textContent = tab.label;
      control.title = pathText(tab.path) || tab.label;
      control.addEventListener('click', () => {
        docSelect(name, tab.id, {focus: true});
      });
      control.addEventListener('keydown', (event) => {
        docTabKeydown(event, name);
      });
      wrapper.append(control);
      if (closes) {
        const close = document.createElement('button');
        close.type = 'button';
        close.className = 'document-tab-close';
        close.dataset.dirty = String(dirty);
        close.textContent = dirty ? '●' : '×';
        close.title = dirty
          ? tip('tab-close-unsaved', 'Unsaved changes; close tab')
          : tip('tab-close', 'Close tab');
        close.setAttribute(
          'aria-label',
          dirty ? `Close ${tab.label}, unsaved changes` : `Close ${tab.label}`
        );
        close.addEventListener('click', (event) => {
          event.stopPropagation?.();
          docClose(name, tab.id);
        });
        wrapper.append(close);
      }
      docDragWrapper(wrapper, name, tab);
      container.append(wrapper);
    }
    const addLabel = bound && levelAddLabel(bound.paneId, bound.level);
    if (addLabel) {
      const wrapper = document.createElement('div');
      wrapper.className = 'document-tab-control document-tab-add-control';
      wrapper.setAttribute('role', 'presentation');
      const add = document.createElement('button');
      add.type = 'button';
      add.className = 'document-tab-add';
      add.setAttribute('aria-label', addLabel);
      add.title = addLabel;
      add.textContent = '+';
      add.addEventListener('click', () => docCreate(name, {focus: true}));
      wrapper.append(add);
      container.append(wrapper);
    }
    syncLevelsBelow(name);
  }

  //  The store's heading actions: Save and Save As disappear in a
  //  read-only pane and are disabled for a tab from an app-written
  //  root, and Copy and Add Ref need text.
  function docApplyActions(name) {
    const tab = docActive(name);
    const locked = docPaneReadOnly(name);
    const written = Boolean(tab?.path) && !docCanSave(name, tab.path);
    for (const action of ['save', 'save-as']) {
      const control = document.querySelector(`#${name}-${action}`);
      if (!control) continue;
      control.hidden = locked;
      control.disabled = written;
    }
    for (const action of ['copy', 'ref']) {
      const control = document.querySelector(`#${name}-${action}`);
      if (control) control.disabled = !tab?.text;
    }
  }

  //  ---- the editor
  //
  //  Each store's editor is the Ace host of the %panel band in its pane.
  //  It is mounted once; if Ace cannot load, the notice is shown and a
  //  stand-in keeps the store working from the tabs' text.
  function docHostOf(name) {
    const bound = levelForKind(name);
    if (!bound) return undefined;
    return paneItem(bound.paneId, 'panel')?.host || undefined;
  }

  function docStandIn(name) {
    return {
      getSource: () => docActive(name)?.text ?? '',
      setSource: () => {},
      replaceRange: () => {},
      getSelection: () => ({start: 0, end: 0}),
      setSelection: () => {},
      selectRange: () => {},
      focus: () => {},
      onChange: () => () => {},
      isFocused: () => false,
      setDiagnostic: () => {},
      setTheme: () => {},
      setKeybindings: () => {},
      setReadOnly: () => {},
      refresh: () => {}
    };
  }

  //  The host is a region named by its pane's source heading, when the
  //  pane has one, and described by its own load-error notice.
  //  `options.acePlatform` overrides Ace's keyboard platform.
  function docMount(name) {
    if (docEditorsByStore.has(name)) return;
    const host = docHostOf(name);
    if (!host) return;
    const element = document.querySelector(`#${host.id}`);
    if (!element) return;
    const paneKind = paneById.get(levelForKind(name)?.paneId)?.kind;
    const heading = paneKind ? `${paneKind}-source-heading` : '';
    const labelledBy = heading && document.getElementById(heading)
      ? heading : undefined;
    const describedBy = `${host.id}-load-error`;
    element.setAttribute('role', 'region');
    if (labelledBy) element.setAttribute('aria-labelledby', labelledBy);
    element.setAttribute('aria-describedby', describedBy);
    let editor;
    try {
      editor = createAceEditorAdapter(element, {
        assets: window[config.ace?.global],
        mode: host.mode || undefined,
        label: host.label,
        labelledBy,
        describedBy,
        platform: options.acePlatform
      });
    } catch (cause) {
      element.hidden = true;
      const notice = document.querySelector(`#${host.id}-load-error`);
      if (notice) {
        notice.hidden = false;
        notice.title = String(cause);
      }
      editor = docStandIn(name);
      docEditorFailed.add(name);
    }
    editor.onChange(() => docEdited(name));
    docEditorsByStore.set(name, editor);
  }

  function documentEditors() {
    return [...docEditorsByStore.values()];
  }

  //  An edit changes only the active tab's text; the strip's dirty mark
  //  and any reference follow it.
  function docEdited(name) {
    const tab = docCapture(name);
    if (!tab) return;
    docSyncRef(name, tab);
    docRender(name);
    changed();
  }

  function docShow(name) {
    const tab = docActive(name);
    const editor = docEditorsByStore.get(name);
    if (!tab) return;
    if (editor) {
      editor.setSource(tab.text, {
        history: 'reset', notify: false, selection: tab.selection
      });
      editor.setReadOnly?.(!docCanSave(name, tab.path));
    }
    docApplyDisplay(name);
  }

  //  ---- source and preview
  //  A saved tab's mark is its path's last segment; a draft's is the
  //  store's default, the first mark of its first root, which is the
  //  mark a first save would give it.
  function docTabMark(name, tab) {
    if (tab?.path) return docMarkOf(tab.path);
    return docStores.get(name)?.roots?.[0]?.marks?.[0];
  }

  function docPreviewerFor(name, tab) {
    return tab ? docPreviewers.get(docTabMark(name, tab)) : undefined;
  }

  function docPreviewHost(name) {
    return document.querySelector(`#${name}-preview`);
  }

  function docApplyDisplay(name) {
    const tab = docActive(name);
    const previewer = docPreviewerFor(name, tab);
    const host = docHostOf(name);
    const editorElement = host ? document.querySelector(`#${host.id}`) : null;
    const previewHost = docPreviewHost(name);
    const toggle = document.querySelector(`#${name}-display`);
    const showing = Boolean(previewer && previewHost)
      && tab.display === 'preview';
    if (toggle) {
      toggle.hidden = !previewer || !previewHost;
      for (const button of Array.from(toggle.children || [])) {
        const shown = showing ? 'preview' : 'source';
        const pressed = button.dataset?.display === shown;
        button.setAttribute('aria-pressed', String(pressed));
      }
    }
    //  a host whose editor failed stays hidden behind its notice
    if (editorElement && !docEditorFailed.has(name)) {
      editorElement.hidden = showing;
    }
    if (!previewHost) return;
    previewHost.hidden = !showing;
    const mark = docTabMark(name, tab);
    for (const entry of docPreviewInstances.values()) {
      if (entry.store !== name) continue;
      if (!showing || entry.mark !== mark) entry.instance.hide?.();
    }
    if (!showing) return;
    docPreviewInstance(name, mark, previewHost).show?.(tab);
    refreshEditors();
  }

  //  One instance per store and mark, built on first show into that
  //  store's own host.
  function docPreviewInstance(name, mark, host) {
    const key = `${name}:${mark}`;
    let entry = docPreviewInstances.get(key);
    if (!entry) {
      const instance = docPreviewers.get(mark)({host, store: name});
      entry = {store: name, mark, instance};
      docPreviewInstances.set(key, entry);
    }
    return entry.instance;
  }

  function docSetDisplay(name, display) {
    const tab = docCapture(name);
    if (!tab || !['source', 'preview'].includes(display)) return;
    tab.display = display;
    if (display === 'source') docShow(name);
    else docApplyDisplay(name);
    changed();
  }

  function docRegisterPreviewer(mark, factory) {
    if (!mark) return;
    if (typeof factory !== 'function') {
      throw new TypeError(`urui: the "${mark}" previewer must be a factory`);
    }
    const key = String(mark);
    const stale = new Set();
    for (const [instanceKey, entry] of docPreviewInstances) {
      if (entry.mark !== key) continue;
      entry.instance.dispose?.();
      docPreviewInstances.delete(instanceKey);
      stale.add(entry.store);
    }
    docPreviewers.set(key, factory);
    for (const name of stale) docApplyDisplay(name);
  }

  function safeMarkdownHref(value) {
    if (value.startsWith('#')) return value;
    try {
      const url = new URL(value, window.location.href);
      if (['http:', 'https:', 'mailto:'].includes(url.protocol)) {
        return url.href;
      }
    } catch (_) {
      return null;
    }
    return null;
  }

  function appendMarkdownInline(parent, value) {
    const pattern = new RegExp([
      '`[^`\\n]+`', '\\*\\*[^*\\n]+\\*\\*', '__[^_\\n]+__',
      '\\*[^*\\n]+\\*', '_[^_\\n]+_', '\\[[^\\]\\n]+\\]\\([^) \\n]+\\)'
    ].map((part) => `(?:${part})`).join('|'), 'g');
    let offset = 0;
    for (const match of value.matchAll(pattern)) {
      parent.append(document.createTextNode(value.slice(offset, match.index)));
      const token = match[0];
      let node;
      if (token.startsWith('`')) {
        node = document.createElement('code');
        node.textContent = token.slice(1, -1);
      } else if (token.startsWith('**') || token.startsWith('__')) {
        node = document.createElement('strong');
        node.textContent = token.slice(2, -2);
      } else if (token.startsWith('*') || token.startsWith('_')) {
        node = document.createElement('em');
        node.textContent = token.slice(1, -1);
      } else {
        const parts = /^\[([^\]]+)\]\(([^) ]+)\)$/.exec(token);
        const href = parts ? safeMarkdownHref(parts[2]) : null;
        if (parts && href) {
          node = document.createElement('a');
          node.textContent = parts[1];
          node.href = href;
          node.rel = 'noreferrer';
          if (!href.startsWith(window.location.origin)) node.target = '_blank';
        } else {
          node = document.createTextNode(token);
        }
      }
      parent.append(node);
      offset = match.index + token.length;
    }
    parent.append(document.createTextNode(value.slice(offset)));
  }

  function markdownTableCells(line) {
    let value = line.trim();
    if (value.startsWith('|')) value = value.slice(1);
    if (value.endsWith('|') && !value.endsWith('\\|')) {
      value = value.slice(0, -1);
    }
    const cells = [];
    let cell = '';
    let escaped = false;
    for (const character of value) {
      if (escaped) {
        cell += character;
        escaped = false;
      } else if (character === '\\') {
        escaped = true;
      } else if (character === '|') {
        cells.push(cell.trim());
        cell = '';
      } else {
        cell += character;
      }
    }
    if (escaped) cell += '\\';
    cells.push(cell.trim());
    return cells;
  }

  function markdownTableDelimiter(line) {
    const cells = markdownTableCells(line);
    return cells.length > 0 && cells.every((cell) => /^:?-{3,}:?$/.test(cell));
  }

  function markdownBlockStart(lines, index) {
    const line = lines[index] || '';
    const next = lines[index + 1] || '';
    return /^ {0,3}```/.test(line) || /^ {0,3}#{1,6}\s+/.test(line)
      || /^ {0,3}(?:[-*_]\s*){3,}$/.test(line)
      || /^\s*>\s?/.test(line)
      || /^\s*(?:[-+*]|\d+\.)\s+/.test(line)
      || (line.includes('|') && markdownTableDelimiter(next));
  }

  function markdownCellAlign(cell, delimiter) {
    if (delimiter.startsWith(':') && delimiter.endsWith(':')) {
      cell.style.textAlign = 'center';
    } else if (delimiter.endsWith(':')) {
      cell.style.textAlign = 'right';
    }
  }

  //  A small, safe Markdown: fences, tables, headings, rules, quotes,
  //  lists, and paragraphs; inline code, emphasis, and http(s) links.
  //  Everything is built as nodes, never as HTML.
  function markdownFragment(text) {
    const fragment = document.createDocumentFragment();
    const lines = String(text || '').replace(/\r\n?/g, '\n').split('\n');
    let index = 0;
    while (index < lines.length) {
      const line = lines[index];
      if (!line.trim()) {
        index += 1;
        continue;
      }
      const fence = /^ {0,3}```\s*([^ ]*)\s*$/.exec(line);
      if (fence) {
        const codeLines = [];
        index += 1;
        while (index < lines.length && !/^ {0,3}```\s*$/.test(lines[index])) {
          codeLines.push(lines[index]);
          index += 1;
        }
        if (index < lines.length) index += 1;
        const pre = document.createElement('pre');
        const code = document.createElement('code');
        if (fence[1]) code.dataset.language = fence[1];
        code.textContent = codeLines.join('\n');
        pre.append(code);
        fragment.append(pre);
        continue;
      }
      if (index + 1 < lines.length && line.includes('|')
        && markdownTableDelimiter(lines[index + 1])) {
        const table = document.createElement('table');
        const head = document.createElement('thead');
        const headRow = document.createElement('tr');
        const delimiters = markdownTableCells(lines[index + 1]);
        markdownTableCells(line).forEach((header, cellIndex) => {
          const cell = document.createElement('th');
          markdownCellAlign(cell, delimiters[cellIndex] || '');
          appendMarkdownInline(cell, header);
          headRow.append(cell);
        });
        head.append(headRow);
        table.append(head);
        const body = document.createElement('tbody');
        index += 2;
        while (index < lines.length && lines[index].trim()
          && lines[index].includes('|')) {
          const row = document.createElement('tr');
          markdownTableCells(lines[index]).forEach((value, cellIndex) => {
            const cell = document.createElement('td');
            markdownCellAlign(cell, delimiters[cellIndex] || '');
            appendMarkdownInline(cell, value);
            row.append(cell);
          });
          body.append(row);
          index += 1;
        }
        table.append(body);
        fragment.append(table);
        continue;
      }
      const heading = /^ {0,3}(#{1,6})\s+(.+?)\s*#*\s*$/.exec(line);
      if (heading) {
        const node = document.createElement(`h${heading[1].length}`);
        appendMarkdownInline(node, heading[2]);
        fragment.append(node);
        index += 1;
        continue;
      }
      if (/^ {0,3}(?:[-*_]\s*){3,}$/.test(line)) {
        fragment.append(document.createElement('hr'));
        index += 1;
        continue;
      }
      if (/^\s*>\s?/.test(line)) {
        const quote = document.createElement('blockquote');
        const quoteLines = [];
        while (index < lines.length && /^\s*>\s?/.test(lines[index])) {
          quoteLines.push(lines[index].replace(/^\s*>\s?/, ''));
          index += 1;
        }
        appendMarkdownInline(quote, quoteLines.join(' '));
        fragment.append(quote);
        continue;
      }
      const listItem = /^\s*([-+*]|\d+\.)\s+(.+)$/.exec(line);
      if (listItem) {
        const ordered = /\d+\./.test(listItem[1]);
        const list = document.createElement(ordered ? 'ol' : 'ul');
        while (index < lines.length) {
          const item = /^\s*([-+*]|\d+\.)\s+(.+)$/.exec(lines[index]);
          if (!item || /\d+\./.test(item[1]) !== ordered) break;
          const node = document.createElement('li');
          appendMarkdownInline(node, item[2]);
          list.append(node);
          index += 1;
        }
        fragment.append(list);
        continue;
      }
      const paragraphLines = [line.trim()];
      index += 1;
      while (index < lines.length && lines[index].trim()
        && !markdownBlockStart(lines, index)) {
        paragraphLines.push(lines[index].trim());
        index += 1;
      }
      const paragraph = document.createElement('p');
      appendMarkdownInline(paragraph, paragraphLines.join(' '));
      fragment.append(paragraph);
    }
    return fragment;
  }

  //  The built-in previewers.  HTML renders in a sandboxed frame with no
  //  script, no same-origin access, and no referrer.
  function markdownPreviewer({host}) {
    const view = document.createElement('div');
    view.className = 'markdown-view';
    host.append(view);
    return {
      show(tab) {
        view.hidden = false;
        view.replaceChildren(markdownFragment(tab.text));
      },
      hide() { view.hidden = true; },
      dispose() { view.remove(); }
    };
  }

  markdownPreviewer.render = (panel, text) => {
    const node = document.createElement('div');
    node.className = 'markdown-view';
    node.append(markdownFragment(text));
    panel.append(node);
  };

  function htmlFrame(title) {
    const frame = document.createElement('iframe');
    frame.setAttribute('sandbox', '');
    frame.setAttribute('referrerpolicy', 'no-referrer');
    frame.title = title;
    return frame;
  }

  function htmlPreviewer({host}) {
    const frame = htmlFrame('Rendered HTML');
    host.append(frame);
    return {
      show(tab) {
        frame.hidden = false;
        frame.srcdoc = tab.text;
      },
      hide() { frame.hidden = true; },
      dispose() { frame.remove(); }
    };
  }

  htmlPreviewer.render = (panel, text) => {
    const node = htmlFrame('Rendered HTML reference');
    node.srcdoc = text;
    panel.append(node);
  };

  docRegisterPreviewer('md', markdownPreviewer);
  docRegisterPreviewer('html', htmlPreviewer);

  //  ---- references
  //
  //  A store with `refs` is an app reference kind to the explorer:
  //  dragging a tab, or Add Ref, opens one per tab, rendered by the
  //  mark's previewer, and it follows the tab's edits and saves.
  function documentRefHooks(name) {
    const storeConfig = docStores.get(name);
    if (!storeConfig?.refs) return undefined;
    return {
      //  an empty tab has nothing to refer to, dragged or by Add Ref
      create: ({parentId}) => {
        const tab = docGet(name, parentId);
        if (!tab?.text) return undefined;
        return {
          label: tab.label,
          data: {text: tab.text, mark: docTabMark(name, tab) || null}
        };
      },
      render: (panel, ref) => {
        const render = docPreviewers.get(ref.data?.mark)?.render;
        if (render) {
          render(panel, String(ref.data.text));
          return;
        }
        const source = document.createElement('pre');
        source.className = 'ref-source';
        source.textContent = String(ref.data?.text ?? '');
        panel.append(source);
      },
      validate: (data) => {
        if (typeof data?.text !== 'string') return undefined;
        return {
          text: data.text,
          mark: typeof data.mark === 'string' ? data.mark : null
        };
      }
    };
  }

  function docSyncRef(name, tab) {
    if (!docStores.get(name)?.refs || !refForParent(name, tab.id)) return;
    updateAppRef(name, tab.id, {
      label: tab.label,
      data: {text: tab.text, mark: docTabMark(name, tab) || null}
    });
  }

  function docAddRef(name, id = documentActiveId(name)) {
    if (id === documentActiveId(name)) docCapture(name);
    return openAppRef({kind: name, parentId: id});
  }

  //  ---- the wire
  function docJsonTransport(url) {
    async function post(body) {
      const response = await fetch(url, {
        method: 'POST',
        credentials: 'same-origin',
        headers: {'content-type': 'application/json'},
        body: JSON.stringify(body)
      });
      let reply = null;
      try {
        reply = JSON.parse(await response.text());
      } catch (_) {
        reply = null;
      }
      if (!response.ok || !reply || reply.ok === false) {
        const error = new Error(
          reply?.error?.message || `Request failed (${response.status})`
        );
        error.status = response.status;
        error.code = reply?.error?.code || null;
        error.retryable = Boolean(reply?.error?.retryable);
        error.details = Array.isArray(reply?.error?.details)
          ? reply.error.details : [];
        throw error;
      }
      return reply;
    }
    return {
      browse: async (scope) => {
        return (await post({op: 'browse', scope})).entries || [];
      },
      load: async (path) => {
        const reply = await post({op: 'load', path});
        return {text: String(reply.text ?? ''), hash: reply.hash ?? null};
      },
      save: async (path, text, choices = {}) => {
        const reply = await post({
          op: 'save',
          path,
          text,
          base: choices.base ?? null,
          overwrite: Boolean(choices.overwrite)
        });
        return {hash: reply.hash ?? null};
      },
      remove: async (path, choices = {}) => {
        await post({op: 'delete', path, base: choices.base ?? null});
      }
    };
  }

  function docFailed(name, op, path, cause) {
    docEvent(name, op, 'failed', path, cause);
    notify(String(cause?.message || cause), {
      kind: 'error', sticky: true, details: cause?.details || []
    });
  }

  //  ---- open, save, delete
  //
  //  One open per store and path at a time: a second open of a path
  //  waits for the first, then reloads against what that one left.
  async function docOpen(name, requested) {
    let path = requested;
    if (!Array.isArray(path)) {
      path = await docFileDialog({mode: 'open', store: name});
      if (!path) return undefined;
    }
    const key = `${name}:${pathText(path)}`;
    const opening = (docOpening.get(key) || Promise.resolve())
      .then(() => docLoad(name, path));
    const settled = opening.catch(() => undefined);
    docOpening.set(key, settled);
    settled.then(() => {
      if (docOpening.get(key) === settled) docOpening.delete(key);
    });
    return opening;
  }

  function docOnPath(name, path) {
    return docTabs(name).find((tab) => samePath(tab.path, path));
  }

  //  True when the user keeps a dirty tab's edits over a reload.
  async function docKeep(name, tab) {
    if (tab.id === documentActiveId(name)) docCapture(name);
    if (tab.text === tab.clean) return false;
    docSelect(name, tab.id, {focus: true});
    return !await confirmDialog('discard', {label: tab.label});
  }

  //  The response lands on the tab only if nothing moved while it was
  //  out: a tab closed meanwhile gets nothing, and a tab edited
  //  meanwhile asks again before its text is replaced.
  async function docLoad(name, path) {
    let tab = docOnPath(name, path);
    if (tab && await docKeep(name, tab)) return tab;
    const before = tab && {id: tab.id, text: tab.text};
    docEvent(name, 'load', 'start', path);
    let loaded;
    try {
      loaded = await docTransport.load(path);
    } catch (cause) {
      docFailed(name, 'load', path, cause);
      return undefined;
    }
    docEvent(name, 'load', 'done', path);
    if (before && !docGet(name, before.id)) return undefined;
    tab = docOnPath(name, path);
    if (tab?.id === documentActiveId(name)) docCapture(name);
    const moved = Boolean(tab)
      && (tab.id !== before?.id || tab.text !== before.text);
    if (moved && await docKeep(name, tab)) return tab;
    if (tab) {
      Object.assign(tab, {
        text: loaded.text,
        clean: loaded.text,
        hash: loaded.hash,
        selection: {start: 0, end: 0}
      });
      docSelect(name, tab.id, {focus: true, reactivate: true});
      docSyncRef(name, tab);
    } else {
      tab = docCreate(name, {
        path, text: loaded.text, clean: loaded.text, hash: loaded.hash,
        focus: true
      });
    }
    docHooks(name).loaded?.(tab);
    return tab;
  }

  //  A new path, or an explicit Save As, goes through the file dialog;
  //  `exists` and `changed` ask before overwriting.
  async function docSave(name, choices = {}) {
    if (docPaneReadOnly(name)) return undefined;
    const tab = docCapture(name);
    if (!tab) return undefined;
    if (!tab.path && !tab.text) {
      notify(`Nothing to save in ${tab.label}.`);
      return undefined;
    }
    //  a tab from an app-written root saves nowhere, by any route
    if (tab.path && !docCanSave(name, tab.path)) return undefined;
    let path = tab.path;
    if (choices.as || !path) {
      path = await docFileDialog({mode: 'save', store: name, tab});
      if (!path) return undefined;
    }
    const text = tab.text;
    let base = samePath(path, tab.path) ? tab.hash : null;
    let overwrite = false;
    let saved;
    docEvent(name, 'save', 'start', path);
    for (;;) {
      try {
        saved = await docTransport.save(path, text, {base, overwrite});
        break;
      } catch (cause) {
        const conflict = cause?.code === 'exists' || cause?.code === 'changed';
        if (!overwrite && conflict
          && await confirmDialog(cause.code, {path: pathText(path)})) {
          overwrite = true;
          base = null;
          continue;
        }
        docFailed(name, 'save', path, cause);
        return undefined;
      }
    }
    //  the file is written either way; a tab closed meanwhile is not
    //  revived, and edits made meanwhile stay unsaved
    if (!docGet(name, tab.id)) {
      docEvent(name, 'save', 'done', path);
      notify(`Saved ${docBaseLabel(name, path)}.`);
      docRefreshTrees(name);
      return undefined;
    }
    if (tab.id === documentActiveId(name)) docCapture(name);
    tab.path = path.slice();
    tab.draft = undefined;
    tab.clean = text;
    tab.hash = saved.hash;
    docRelabel(name);
    docEvent(name, 'save', 'done', path);
    docHooks(name).saved?.(tab);
    docSyncRef(name, tab);
    if (tab.id === documentActiveId(name)) docShow(name);
    docRender(name);
    changed();
    notify(`Saved ${tab.label}.`);
    docRefreshTrees(name);
    return tab;
  }

  //  Tabs open on a deleted path keep their text as unsaved drafts.
  async function docRemove(name, path) {
    if (!Array.isArray(path) || docPaneReadOnly(name)) return false;
    if (!await confirmDialog('delete', {path: pathText(path)})) return false;
    docEvent(name, 'delete', 'start', path);
    try {
      await docTransport.remove(path, {});
    } catch (cause) {
      docFailed(name, 'delete', path, cause);
      return false;
    }
    docEvent(name, 'delete', 'done', path);
    const label = docBaseLabel(name, path);
    for (const tab of docTabs(name)) {
      if (!samePath(tab.path, path)) continue;
      if (tab.id === documentActiveId(name)) docCapture(name);
      tab.path = null;
      tab.draft = tab.label;
      tab.clean = '';
      tab.hash = null;
    }
    docRelabel(name);
    docShow(name);
    docRender(name);
    changed();
    notify(`Deleted ${label}.`);
    docRefreshTrees(name);
    return true;
  }

  //  ---- the tree
  //
  //  One per `config.files.trees` entry, in the %views panel it names.
  //  Directories fold, and `fileTrees` remembers the folds.
  function docScopes(name, tree) {
    const scopes = tree?.scopes?.length
      ? tree.scopes
      : (docStores.get(name)?.roots || []).map((root) => root.scope);
    const unique = [];
    for (const scope of scopes) {
      if (!unique.some((item) => samePath(item, scope))) unique.push(scope);
    }
    return unique;
  }

  async function docBrowse(name, scopes) {
    const files = [];
    for (const scope of scopes) {
      for (const entry of await docTransport.browse(scope)) {
        if (entry?.kind !== 'file' || !Array.isArray(entry.path)) continue;
        if (!docRootOf(name, entry.path)) continue;
        if (!files.some((item) => samePath(item, entry.path))) {
          files.push(entry.path);
        }
      }
    }
    return files.sort((left, right) => {
      return pathText(left).localeCompare(pathText(right));
    });
  }

  async function docRefreshTree(tree) {
    const node = document.querySelector(`#${tree.view}-tree`);
    if (!node) return;
    node.setAttribute('aria-busy', 'true');
    let files;
    try {
      files = await docBrowse(tree.store, docScopes(tree.store, tree));
    } catch (cause) {
      node.setAttribute('aria-busy', 'false');
      node.replaceChildren();
      node.textContent = `Unable to load files: ${cause?.message || cause}`;
      docFailed(tree.store, 'browse', undefined, cause);
      return;
    }
    docRenderTree(tree, node, files);
  }

  function docRefreshTrees(name) {
    return Promise.all(docTrees.filter((tree) => {
      return !name || tree.store === name;
    }).map(docRefreshTree));
  }

  function docTreeRow(tree, path) {
    const name = tree.store;
    const row = document.createElement('div');
    row.className = 'explorer-file-row';
    const file = document.createElement('button');
    file.type = 'button';
    file.className = 'file-tree-file';
    file.dataset.path = pathText(path);
    file.textContent = docBaseLabel(name, path);
    file.title = pathText(path);
    file.addEventListener('click', () => {
      closeFileContext();
      docOpen(name, path);
    });
    const openMenu = (source, event) => {
      openFileContext(name, path, source, event);
    };
    row.addEventListener('contextmenu', (event) => openMenu(file, event));
    const actions = document.createElement('button');
    actions.type = 'button';
    actions.className = 'file-tree-actions';
    actions.setAttribute('aria-label', `Actions for ${file.textContent}`);
    actions.title = tip('file-actions', 'File actions');
    actions.setAttribute('aria-haspopup', 'menu');
    actions.setAttribute('aria-expanded', 'false');
    actions.textContent = '…';
    actions.addEventListener('click', (event) => openMenu(actions, event));
    row.append(file, actions);
    return row;
  }

  //  Folders are native <details> disclosures and files are buttons:
  //  no tree role, since there is no tree keyboard model to go with it.
  function docRenderTree(tree, node, files) {
    const root = {folders: new Map(), files: []};
    for (const path of files) {
      let branch = root;
      const dirs = path.slice(0, -2);
      dirs.forEach((part, index) => {
        if (!branch.folders.has(part)) {
          branch.folders.set(part, {
            path: dirs.slice(0, index + 1), folders: new Map(), files: []
          });
        }
        branch = branch.folders.get(part);
      });
      branch.files.push(path);
    }
    const build = (branch) => {
      const list = document.createElement('div');
      list.className = 'file-tree-children';
      for (const [part, folder] of branch.folders) {
        const details = document.createElement('details');
        details.className = 'file-tree-folder';
        const key = `${tree.view}:${pathText(folder.path)}`;
        details.open = docTreeState[key] !== false;
        details.addEventListener('toggle', () => {
          if (details.open) delete docTreeState[key];
          else docTreeState[key] = false;
          changed();
        });
        const summary = document.createElement('summary');
        summary.textContent = part;
        details.append(summary, build(folder));
        list.append(details);
      }
      for (const path of branch.files) list.append(docTreeRow(tree, path));
      return list;
    };
    node.replaceChildren();
    node.setAttribute('aria-busy', 'false');
    if (!files.length) {
      node.textContent = 'No files yet.';
      return;
    }
    const top = build(root);
    top.className = 'file-tree-list';
    node.append(top);
  }

  function docShowTree(name) {
    const tree = docTrees.find((item) => item.store === name);
    if (!tree) return;
    if (!explorerOpen) setExplorerOpen(true, false);
    setExplorerView(tree.view, true);
    docRefreshTree(tree);
  }

  function documentTreeState() {
    return docTreeState;
  }

  function documentValidTreeState(raw) {
    if (!raw || typeof raw !== 'object') return {};
    const valid = {};
    for (const [key, value] of Object.entries(raw)) {
      if (value === false && key.length <= 1_024) valid[key] = false;
    }
    return valid;
  }

  function documentSetTreeState(value) {
    docTreeState = value || {};
  }

  //  ---- dialogs
  //
  //  The file dialog and the confirm dialog are modals (see the runtime's
  //  modal section); the confirm dialog ranks above the file dialog, and
  //  both above settings and help.
  function docElement(id) {
    return document.querySelector(`#${id}`);
  }

  const docFileModal = defineModal(
    3, () => docElement('urui-file-dialog'), () => docDialog?.finish(null)
  );
  const docConfirmModal = defineModal(
    4, () => docElement('urui-confirm'), () => docConfirm?.finish(false)
  );

  function confirmMessage(kind, detail = {}) {
    switch (kind) {
      case 'discard': return `Discard unsaved changes in ${detail.label}?`;
      case 'exists': return `${detail.path} already exists. Overwrite it?`;
      case 'changed':
        return `${detail.path} changed since it was loaded. Overwrite it?`;
      case 'delete': return `Delete ${detail.path}? This cannot be undone.`;
      default: return String(detail.message || kind);
    }
  }

  function confirmDialog(kind, detail = {}) {
    const message = confirmMessage(kind, detail);
    const modal = docElement('urui-confirm');
    if (!modal) return Promise.resolve(Boolean(window.confirm(message)));
    if (docConfirm) docConfirm.finish(false);
    return new Promise((resolve) => {
      const finish = (answer) => {
        docConfirm = undefined;
        hideModal(docConfirmModal);
        resolve(answer);
      };
      docConfirm = {finish};
      docElement('urui-confirm-message').textContent = message;
      showModal(docConfirmModal, docElement('urui-confirm-cancel'));
    });
  }

  function docDialogEntries(list, files, choose, open) {
    list.replaceChildren();
    if (!files.length) {
      const empty = document.createElement('p');
      empty.className = 'file-dialog-help';
      empty.textContent = 'No files yet.';
      list.append(empty);
      return;
    }
    for (const path of files) {
      const entry = document.createElement('button');
      entry.type = 'button';
      entry.className = 'file-dialog-entry';
      entry.setAttribute('role', 'option');
      entry.setAttribute('aria-selected', 'false');
      entry.textContent = pathText(path);
      entry.title = pathText(path);
      entry.addEventListener('click', () => {
        for (const item of Array.from(list.children || [])) {
          item.setAttribute?.('aria-selected', String(item === entry));
        }
        choose(path);
      });
      entry.addEventListener('dblclick', () => open(path));
      list.append(entry);
    }
  }

  //  Segments a user may type, and whether the last one followed a dot.
  //  A path segment never holds a dot: `notes/plan.txt` is the path
  //  notes/plan/txt, and its `.txt` names a format.  The server refines
  //  the rule further for a strict policy.
  function docTypedSegments(value) {
    const text = String(value || '').trim().replace(/^\/+|\/+$/g, '');
    const parts = text.split(/[/.]/).map((part) => part.trim());
    if (!parts.length || parts.some((part) => {
      return !part || !/^[a-z0-9_~-]+$/.test(part);
    })) {
      return undefined;
    }
    const cut = Math.max(text.lastIndexOf('/'), text.lastIndexOf('.'));
    return {parts, suffix: cut >= 0 && text[cut] === '.'};
  }

  //  The mark a typed segment names under `root`: one of its marks, or
  //  its label extension, which stands for its first mark.
  function docTypedMark(root, segment) {
    if (root.marks.includes(segment)) return segment;
    return root.ext && segment === root.ext ? root.marks[0] : undefined;
  }

  //  `{mode, store, tab, scope, title, extra, mark, value}` → a path, or
  //  null.  `open` lists the store's files; `save` and `pick` take a
  //  typed path under a chosen root, starting from `value` when given,
  //  with a format picker when the root holds more than one mark
  //  (`mark: false` hides it; the path then keeps a mark it names, or
  //  takes the root's first).
  function docFileDialog(request) {
    const modal = docElement('urui-file-dialog');
    if (!modal) return Promise.resolve(null);
    if (docDialog) docDialog.finish(null);
    const name = request.store;
    const storeConfig = docStores.get(name);
    const mode = request.mode || 'pick';
    const opening = mode === 'open';
    const roots = (storeConfig?.roots || []).filter((root) => {
      if (request.scope) return samePath(root.scope, request.scope);
      return opening || root.save;
    });
    const title = docElement('urui-file-dialog-title');
    const help = docElement('urui-file-dialog-help');
    const rootField = docElement('urui-file-dialog-root-field');
    const rootSelect = docElement('urui-file-dialog-root');
    const list = docElement('urui-file-dialog-list');
    const pathField = docElement('urui-file-dialog-path-field');
    const pathInput = docElement('urui-file-dialog-path');
    const markField = docElement('urui-file-dialog-mark-field');
    const markSelect = docElement('urui-file-dialog-mark');
    const extra = docElement('urui-file-dialog-extra');
    const error = docElement('urui-file-dialog-error');
    const confirm = docElement('urui-file-dialog-confirm');
    const cancel = docElement('urui-file-dialog-cancel');
    const noun = storeConfig?.noun || 'file';
    title.textContent = request.title
      || (opening ? `Open ${noun}` : `Save ${noun} As`);
    help.textContent = opening
      ? `Choose a saved ${noun.toLowerCase()}.`
      : 'Use lower-case letters, digits, and hyphens; / makes folders.';
    confirm.textContent = opening ? 'Open' : 'Save';
    confirm.title = opening
      ? tip('urui-file-dialog-open', 'Open the selected file')
      : tip('urui-file-dialog-save', 'Save to this path');
    error.hidden = true;
    extra.replaceChildren(...(request.extra ? [request.extra] : []));
    let selected = null;
    const rootAt = () => roots[Number(rootSelect.value) || 0];
    const fillMarks = () => {
      const root = rootAt();
      markSelect.replaceChildren();
      for (const mark of root?.marks || []) {
        const option = document.createElement('option');
        option.value = mark;
        option.textContent = mark;
        markSelect.append(option);
      }
      const current = request.tab?.path ? docMarkOf(request.tab.path) : null;
      markSelect.value = root?.marks.includes(current)
        ? current : root?.marks[0];
      markField.hidden = opening || request.mark === false
        || (root?.marks.length || 0) < 2;
    };
    const fillList = async () => {
      const root = rootAt();
      list.replaceChildren();
      if (!root) return;
      try {
        const files = await docBrowse(name, [root.scope]);
        docDialogEntries(list, files, (path) => {
          selected = path;
          if (!opening) {
            pathInput.value = path.slice(root.scope.length, -1).join('/');
            if (root.marks.includes(docMarkOf(path))) {
              markSelect.value = docMarkOf(path);
            }
          }
        }, (path) => {
          selected = path;
          if (opening) finish(path);
          else accept();
        });
      } catch (cause) {
        error.textContent = String(cause?.message || cause);
        error.hidden = false;
      }
    };
    rootSelect.replaceChildren();
    roots.forEach((root, index) => {
      const option = document.createElement('option');
      option.value = String(index);
      option.textContent = pathText(root.scope) || '/';
      rootSelect.append(option);
    });
    const tabRoot = request.tab?.path
      ? roots.findIndex((root) => root === docRootOf(name, request.tab.path))
      : -1;
    rootSelect.value = String(Math.max(0, tabRoot));
    rootField.hidden = roots.length < 2;
    pathField.hidden = opening;
    list.hidden = false;
    fillMarks();
    if (!opening && typeof request.value === 'string') {
      pathInput.value = request.value;
    } else if (!opening) {
      const tab = request.tab;
      pathInput.value = tab?.path && docCanSave(name, tab.path)
        ? tab.path.slice(rootAt().scope.length, -1).join('/')
        : String(tab?.label || '').toLowerCase()
          .replace(/[^a-z0-9._~/-]+/g, '-');
    }
    let finish;
    const done = new Promise((resolve) => {
      finish = (answer) => {
        extra.replaceChildren();
        docDialog = undefined;
        hideModal(docFileModal);
        resolve(answer);
      };
    });
    const accept = () => {
      if (opening) {
        if (selected) finish(selected);
        return;
      }
      const root = rootAt();
      const typed = docTypedSegments(pathInput.value);
      const refuse = (message) => {
        error.textContent = message;
        error.hidden = false;
        pathInput.focus();
      };
      if (!root || !typed) {
        refuse('Enter a path such as folder/name.');
        return;
      }
      const segments = typed.parts;
      const typedMark = segments.length > 1
        ? docTypedMark(root, segments[segments.length - 1]) : undefined;
      if (typed.suffix && !typedMark) {
        const suffixes = [...new Set([root.ext, ...root.marks])]
          .filter(Boolean).map((suffix) => `.${suffix}`);
        refuse(`This location saves ${suffixes.join(', ')} files.`);
        return;
      }
      if (typedMark) segments.pop();
      const mark = typedMark
        || (markField.hidden ? root.marks[0] : markSelect.value);
      finish([...root.scope, ...segments, mark]);
    };
    docDialog = {finish, accept};
    rootSelect.onchange = () => {
      fillMarks();
      fillList();
    };
    confirm.onclick = accept;
    cancel.onclick = () => finish(null);
    pathInput.onkeydown = (event) => {
      if (event.key !== 'Enter') return;
      event.preventDefault();
      accept();
    };
    showModal(docFileModal, opening ? cancel : pathInput);
    fillList();
    return done;
  }

  //  ---- feedback
  function notify(message, choices = {}) {
    const toast = docElement('urui-toast');
    if (!toast) return;
    const kind = choices.kind || 'info';
    const details = Array.isArray(choices.details) ? choices.details : [];
    clearTimeout(docToastTimer);
    toast.dataset.kind = kind;
    toast.setAttribute('role', kind === 'error' ? 'alert' : 'status');
    docElement('urui-toast-message').textContent = String(message);
    const more = docElement('urui-toast-details');
    if (more) {
      more.textContent = details.join('\n');
      more.hidden = !details.length;
    }
    toast.hidden = false;
    if (!choices.sticky) {
      docToastTimer = setTimeout(() => { toast.hidden = true; }, 4_000);
    }
  }

  async function copyText(text) {
    const value = String(text ?? '');
    try {
      if (navigator.clipboard?.writeText) {
        await navigator.clipboard.writeText(value);
        return true;
      }
    } catch (_) {
      // Fall through for browsers that restrict the Clipboard API.
    }
    const helper = document.createElement('textarea');
    helper.value = value;
    helper.setAttribute('readonly', '');
    helper.style.position = 'fixed';
    helper.style.opacity = '0';
    document.body.append(helper);
    helper.select();
    let copied = false;
    try {
      copied = document.execCommand('copy');
    } finally {
      helper.remove();
    }
    return copied;
  }

  //  ---- the session
  //
  //  A store's tabs, active id, and counter use the store-named slots
  //  with the same shapes as the document tabs above.
  function documentReadSlot(slot) {
    const state = docState.get(slot.kind);
    if (slot.shape === 'active') return state.activeId;
    if (slot.shape === 'next') return state.next;
    if (slot.shape !== 'tabs') return undefined;
    return state.tabs.map((tab) => {
      const {label, ...stored} = tab;
      return stored;
    });
  }

  function documentValidTab(candidate, name, seen) {
    if (!candidate || typeof candidate !== 'object') return undefined;
    if (!idPattern(name).test(candidate.id)) return undefined;
    const text = validSavedSource(candidate.text);
    if (text === undefined) return undefined;
    const path = Array.isArray(candidate.path)
      && candidate.path.every((part) => typeof part === 'string')
      && docRootOf(name, candidate.path) ? candidate.path.slice() : null;
    const base = {
      id: candidate.id,
      path,
      draft: path ? undefined : validTabLabel(
        candidate.draft ?? candidate.label, docStores.get(name).untitled
      ),
      text,
      clean: validSavedSource(candidate.clean) ?? text,
      hash: typeof candidate.hash === 'string' ? candidate.hash : null,
      selection: {
        start: Math.max(0, Math.trunc(Number(candidate.selection?.start)) || 0),
        end: Math.max(0, Math.trunc(Number(candidate.selection?.end)) || 0)
      },
      display: ['source', 'preview'].includes(candidate.display)
        ? candidate.display : docDefaultDisplay(name)
    };
    const extra = docHooks(name).fields?.validate?.(candidate, base, seen);
    if (extra === false) return undefined;
    return {...base, ...(extra || {})};
  }

  function documentApplySlot(slot, value) {
    const state = docState.get(slot.kind);
    if (slot.shape === 'tabs') {
      state.tabs.splice(0, state.tabs.length, ...value);
      docRelabel(slot.kind);
    } else if (slot.shape === 'active') {
      state.activeId = value;
    } else if (slot.shape === 'next') {
      state.next = value;
    }
  }

  //  ---- start and wiring
  //
  //  `runtime.documents.start()` runs once, after `runtime.session.load()`:
  //  it mounts the editors, adds a shared source, gives every store a
  //  tab, shows each active one, and loads the trees.
  function documentStart() {
    if (!filesConfig || docStarted) return;
    docStarted = true;
    for (const name of docStores.keys()) {
      docMount(name);
      const state = docState.get(name);
      const shared = docSharedSource(name);
      if (shared !== undefined) {
        docCreate(name, {text: shared, label: 'Shared', activate: false});
        state.activeId = state.tabs[state.tabs.length - 1].id;
      }
      if (!state.tabs.length) docCreate(name, {activate: false});
      if (!docGet(name, state.activeId)) state.activeId = state.tabs[0].id;
      docSelect(name, state.activeId, {reactivate: true, restore: true});
    }
    docRefreshTrees();
  }

  function docSharedSource(name) {
    const spec = docStores.get(name)?.share;
    if (!spec) return undefined;
    const encoded = new URL(window.location.href).searchParams.get(spec.name);
    if (encoded === null) return undefined;
    try {
      return decodeSource(encoded, spec);
    } catch (cause) {
      notify(String(cause?.message || cause), {kind: 'error', sticky: true});
      return undefined;
    }
  }

  function documentOpenContext(name, path) {
    docOpen(name, path);
  }

  function documentRemoveContext(name, path, source) {
    docRemove(name, path).then((removed) => {
      if (!removed) source?.focus?.();
    });
  }

  function documentsWire() {
    if (!filesConfig) return;
    const run = {
      open: (name) => docOpen(name),
      save: (name) => docSave(name),
      'save-as': (name) => docSave(name, {as: true}),
      copy: async (name) => {
        const tab = docCapture(name);
        if (tab && await copyText(tab.text)) notify(`Copied ${tab.label}.`);
      },
      ref: (name) => docAddRef(name),
      browse: (name) => docShowTree(name)
    };
    for (const [name, storeConfig] of docStores) {
      for (const action of storeConfig.actions || []) {
        document.querySelector(`#${name}-${action}`)
          ?.addEventListener('click', () => run[action]?.(name));
      }
      const toggle = document.querySelector(`#${name}-display`);
      for (const button of Array.from(toggle?.children || [])) {
        button.addEventListener('click', () => {
          docSetDisplay(name, button.dataset?.display);
        });
      }
      registerShortcut(`open:${name}`, () => docOpen(name));
      registerShortcut(`save:${name}`, () => docSave(name));
      registerShortcut(`save-as:${name}`, () => docSave(name, {as: true}));
    }
    docElement('urui-confirm-ok')?.addEventListener('click', () => {
      docConfirm?.finish(true);
    });
    docElement('urui-confirm-cancel')?.addEventListener('click', () => {
      docConfirm?.finish(false);
    });
    docElement('urui-toast-close')?.addEventListener('click', () => {
      clearTimeout(docToastTimer);
      docElement('urui-toast').hidden = true;
    });
  }

  const documentApi = {
    start: documentStart,
    list: (name) => docTabs(name).slice(),
    active: docActive,
    get: docGet,
    create: docCreate,
    update: docUpdate,
    select: docSelect,
    close: docClose,
    open: docOpen,
    save: docSave,
    remove: docRemove,
    dirty: docDirty,
    addRef: docAddRef,
    editor: (name) => docEditorsByStore.get(name),
    pickPath: (request = {}) => docFileDialog({...request, mode: 'pick'}),
    previews: {register: docRegisterPreviewer},
    trees: {
      refresh: (view) => view
        ? docRefreshTree(docTrees.find((tree) => tree.view === view))
        : docRefreshTrees(),
      show: (view) => {
        const tree = docTrees.find((item) => item.view === view);
        if (tree) docShowTree(tree.store);
      }
    }
  };
  '''
::
++  editor-adapter
  ::  The body of createAceEditorAdapter, shared by every consumer.
  ::
  ::  `options.assets` is the frozen record ++config-js:urui-ace
  ::  publishes, and is required; `mode` overrides the configured Ace
  ::  mode; `platform` overrides Ace's keyboard platform; `label`,
  ::  `labelledBy`, and `describedBy` name and describe the hidden
  ::  textarea for a screen reader.
  ::
  ^-  @t
  '''
  const assets = options.assets;
  if (!window.ace || !assets) {
    throw new Error('Ace runtime or configuration did not load');
  }
  const AceRange = window.ace.require('ace/range').Range;
  const beautify = window.ace.require('ace/ext/beautify');
  if (!Array.isArray(beautify?.commands)) {
    throw new Error('Ace Beautify extension did not load');
  }
  const aceEditor = window.ace.edit(host);
  const session = aceEditor.session;
  const changeListeners = new Set();
  const textInput = aceEditor.textInput.getElement();
  let errorMarker;
  let suppressChanges = 0;
  let readOnly = false;

  aceEditor.setOptions({
    displayIndentGuides: true,
    fontSize: '0.9rem',
    highlightActiveLine: true,
    showPrintMargin: false,
    tabSize: 2,
    useSoftTabs: true,
    wrap: true
  });
  aceEditor.setTheme(
    document.documentElement.dataset.effectiveTheme === 'dark'
      ? assets.darkTheme
      : assets.lightTheme
  );
  session.setMode(options.mode || assets.mode);
  session.setUseWorker(assets.useWorker);
  if (options.platform) {
    aceEditor.commands.platform = options.platform;
  }
  aceEditor.commands.addCommands(beautify.commands);
  aceEditor.commands.bindKey('Ctrl-T', 'transposeletters');
  //  The keymap is carried on the root element, the same way the
  //  effective theme is, so an editor mounted at any point in the
  //  session starts on the preference already in force.
  if (document.documentElement.dataset.keybindings === 'vim') {
    aceEditor.setKeyboardHandler('ace/keyboard/vim');
  }
  textInput.setAttribute(
    'aria-label',
    options.label || 'Source editor'
  );
  if (options.labelledBy) {
    textInput.setAttribute('aria-labelledby', options.labelledBy);
  }
  textInput.setAttribute(
    'aria-describedby',
    options.describedBy || ''
  );
  textInput.setAttribute('aria-invalid', 'false');

  function getSource() {
    return aceEditor.getValue();
  }

  function clampOffset(offset) {
    const numeric = Number.isFinite(offset) ? Math.trunc(offset) : 0;
    return Math.max(0, Math.min(getSource().length, numeric));
  }

  function getSelection() {
    const range = aceEditor.selection.getRange();
    return {
      start: positionToOffset(range.start),
      end: positionToOffset(range.end)
    };
  }

  function setSelection(start, end = start) {
    const nextStart = clampOffset(start);
    const nextEnd = Math.max(nextStart, clampOffset(end));
    const first = offsetToPosition(nextStart);
    const last = offsetToPosition(nextEnd);
    aceEditor.selection.setSelectionRange(new AceRange(
      first.row,
      first.column,
      last.row,
      last.column
    ));
  }

  function offsetToPosition(offset) {
    return session.doc.indexToPosition(clampOffset(offset), 0);
  }

  function positionToOffset(position) {
    const source = getSource();
    const lines = source.split('\n');
    const requestedRow = Number.isFinite(position?.row)
      ? Math.trunc(position.row)
      : 0;
    const row = Math.max(0, Math.min(lines.length - 1, requestedRow));
    const requestedColumn = Number.isFinite(position?.column)
      ? Math.trunc(position.column)
      : 0;
    const column = Math.max(0, Math.min(lines[row].length, requestedColumn));
    return session.doc.positionToIndex({row, column}, 0);
  }

  function notifyChange() {
    for (const listener of changeListeners) listener();
  }

  function mutate(change, notify) {
    suppressChanges += 1;
    try {
      change();
    } finally {
      suppressChanges -= 1;
    }
    if (notify !== false) notifyChange();
  }

  function isolateUndo(change) {
    const undoManager = session.getUndoManager();
    undoManager.startNewGroup();
    try {
      change();
    } finally {
      undoManager.startNewGroup();
    }
  }

  function setSource(source, options = {}) {
    mutate(() => {
      const history = options.history || 'undoable';
      if (history === 'reset') {
        session.setValue(source);
        session.getUndoManager().reset();
      } else if (history === 'undoable') {
        const last = offsetToPosition(getSource().length);
        isolateUndo(() => {
          session.replace(new AceRange(
            0,
            0,
            last.row,
            last.column
          ), source);
        });
      } else {
        throw new Error(`Unsupported editor history mode: ${history}`);
      }
      const selection = options.selection || {
        start: source.length,
        end: source.length
      };
      setSelection(selection.start, selection.end);
    }, options.notify);
  }

  //  A read-only editor refuses programmatic edits as it refuses typing;
  //  `setSource` still loads a tab's text into it.
  function replaceRange(start, end, replacement, options = {}) {
    if (readOnly) return false;
    const rangeStart = clampOffset(start);
    const rangeEnd = Math.max(rangeStart, clampOffset(end));
    const first = offsetToPosition(rangeStart);
    const last = offsetToPosition(rangeEnd);
    mutate(() => {
      isolateUndo(() => {
        session.replace(new AceRange(
          first.row,
          first.column,
          last.row,
          last.column
        ), replacement);
      });
      const replacementEnd = rangeStart + replacement.length;
      if (options.selection && typeof options.selection === 'object') {
        setSelection(options.selection.start, options.selection.end);
      } else if (options.selection === 'select') {
        setSelection(rangeStart, replacementEnd);
      } else if (options.selection === 'start') {
        setSelection(rangeStart);
      } else {
        setSelection(replacementEnd);
      }
    }, options.notify);
  }

  function selectRange(start, end, options = {}) {
    setSelection(start, end);
    if (options.focus) aceEditor.focus();
    if (options.reveal) {
      const position = offsetToPosition(start);
      aceEditor.scrollToLine(position.row, true, true);
    }
  }

  function clearDiagnostic() {
    session.clearAnnotations();
    if (errorMarker !== undefined) session.removeMarker(errorMarker);
    errorMarker = undefined;
    textInput.setAttribute('aria-invalid', 'false');
  }

  function setDiagnostic(problem) {
    clearDiagnostic();
    if (!problem) return;
    const requestedLine = Number(problem.line);
    if (!Number.isFinite(requestedLine) || requestedLine < 1) return;
    const lines = getSource().split('\n');
    const row = Math.min(lines.length - 1, Math.trunc(requestedLine) - 1);
    const requestedColumn = Number(problem.column);
    const column = Math.max(0, Math.min(
      lines[row].length,
      Number.isFinite(requestedColumn)
        ? Math.trunc(requestedColumn) - 1
        : 0
    ));
    const endColumn = Math.min(lines[row].length, column + 1);
    const markerEnd = endColumn > column ? endColumn : column + 1;
    const message = problem.message || 'syntax error';
    session.setAnnotations([{row, column, text: message, type: 'error'}]);
    errorMarker = session.addMarker(
      new AceRange(row, column, row, markerEnd),
      'ace-error-marker',
      'text',
      false
    );
    aceEditor.selection.moveCursorTo(row, column);
    aceEditor.clearSelection();
    aceEditor.scrollToLine(row, true, true);
    textInput.setAttribute('aria-invalid', 'true');
  }

  session.on('change', () => {
    if (!suppressChanges) notifyChange();
  });

  return {
    getSource,
    setSource,
    replaceRange,
    getSelection,
    setSelection,
    selectRange,
    offsetToPosition,
    positionToOffset,
    focus: () => aceEditor.focus(),
    onChange(listener) {
      changeListeners.add(listener);
      return () => changeListeners.delete(listener);
    },
    isFocused(target) {
      const active = document.activeElement;
      return target === host || host.contains(target)
        || active === host || host.contains(active)
        || Boolean(aceEditor.isFocused?.());
    },
    setDiagnostic,
    setTheme(effective) {
      aceEditor.setTheme(
        effective === 'dark' ? assets.darkTheme : assets.lightTheme
      );
    },
    //  `null` is Ace's own keymap, not an absence of one.  The vim
    //  handler is a module Ace fetches from basePath on first use, so
    //  this is the only place that names it.
    setKeybindings(mode) {
      aceEditor.setKeyboardHandler(
        mode === 'vim' ? 'ace/keyboard/vim' : null
      );
    },
    setReadOnly(flag) {
      readOnly = Boolean(flag);
      aceEditor.setReadOnly(readOnly);
    },
    refresh: () => aceEditor.resize(true)
  };
  '''
--
