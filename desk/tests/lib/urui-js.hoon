::  Tests for /lib/urui-js.
::
/-  urui
/+  *test, ucfg=urui-config, ujs=urui-js
|%
::
++  fixture-config
  ::  Consumer-neutral values used by %urui-fixture.
  ^-  app-config:urui
  %*  .  *app-config:urui
    name.app-id             %urui-fixture
    title.app-id            'urui fixture'
    base.app-id             '/apps/urui-fixture'
    storage-key.app-id      'urui-fixture.session.v1'
    storage-version.app-id  1
    render-debounce.limits  350
    save-debounce.limits    150
    min-explorer.limits     180
    divider.limits          10
    pane-min.limits         25
    pane-max.limits         70
    narrow.limits           760
    max-source.limits       262.144
    slots
      :~  ['paneWidth' %urui %scalar ~]
          ['explorerWidth' %urui %scalar ~]
          ['explorerOpen' %urui %scalar ~]
          ['explorerView' %urui %scalar ~]
          ['explorerOrder' %urui %scalar ~]
          ['docsTabs' %urui %tabs ~]
          ['nextDocs' %urui %next ~]
          ['refTabs' %urui %tabs ~]
          ['nextRef' %urui %next ~]
      ==
    docs-root  `'/docs/d/urui-fixture/'
    share-param
      `[name='source' max=12.288 param-max=16.384]
  ==
::
++  fixture-spec
  ^-  shell-spec:urui
  %*  .  *shell-spec:urui
    app-config  fixture-config
  ==
::
++  config-source
  (trip (emit:ucfg fixture-spec))
::
++  core-source
  (trip core:ujs)
::
++  has
  |=  [needle=tape source=tape]
  ^-  ?
  ?=(^ (find needle source))
::
++  test-public-api
  =/  needles=(list @t)
    :~  'window.urui = Object.freeze(api)'
        'boot(next = {})'
        'status: (...args)'
        '\27create\27, \27close\27, \27select\27'
        '\27update\27, \27list\27, \27active\27'
        '\27primary\27, \27secondary\27'
        '\27show\27, \27refreshTree\27, \27addRef\27, \27openDocs\27'
        '\27get\27, \27set\27, \27select\27, \27panel\27, \27reveal\27'
        '\27save\27, \27queue\27, \27get\27, \27set\27'
        '\27browse\27, \27load\27, \27save\27, \27delete\27'
        '\27paneWidth\27, \27explorerWidth\27'
        '\27show\27, \27clear\27'
    ==
  %-  zing
  %+  turn  needles
  |=  needle=@t
  (expect !>((has (trip needle) core-source)))
::
++  test-boot-contract
  ;:  weld
    (expect !>((has "let booted = false" core-source)))
    (expect !>((has "urui.boot called more than once" core-source)))
    (expect !>((has "invoke(null, 'onReady', [api])" core-source)))
    (expect !>((has "return target(...args)" core-source)))
  ==
::
++  test-theme-switcher
  =/  source  (trip (theme-bootstrap:ujs 'urui-fixture.session.v1' 1))
  =/  needles=(list tape)
    :~  "'system', 'light', 'dark'"
        "preferences?.theme"
        "dataset.effectiveTheme"
        "prefers-color-scheme: dark"
        "localStorage.getItem(key)"
        "saved?.version ==="
        "themes.includes(candidate)"
        "matchMedia("
        "root.style.colorScheme"
        "urui-fixture.session.v1"
    ==
  %-  zing
  %+  turn  needles
  |=  needle=tape
  (expect !>((has needle source)))
::
++  test-docs-help-contract
  =/  config-needles=(list tape)
    :~  "\"docsRoot\":\"/docs/d/urui-fixture/\""
        "\"permanentViews\""
    ==
  =/  api-needles=(list tape)
    :~  "'show', 'refreshTree', 'addRef', 'openDocs'"
        "help: (...args)"
    ==
  =/  config-tests=tang
    %-  zing
    %+  turn  config-needles
    |=  needle=tape
    (expect !>((has needle config-source)))
  =/  api-tests=tang
    %-  zing
    %+  turn  api-needles
    |=  needle=tape
    (expect !>((has needle core-source)))
  (weld config-tests api-tests)
::
++  test-responsive-layout-contract
  =/  needles=(list tape)
    :~  "\"minExplorer\":180"
        "\"divider\":10"
        "\"paneMin\":25"
        "\"paneMax\":70"
        "\"narrow\":760"
    ==
  =/  tests=tang
    %-  zing
    %+  turn  needles
    |=  needle=tape
    (expect !>((has needle config-source)))
  ;:  weld
    tests
    (expect !>((has "'paneWidth', 'explorerWidth'" core-source)))
  ==
::
++  test-editor-usability
  =/  source  (trip editor-adapter:ujs)
  =/  needles=(list tape)
    :~  "const assets = options.assets"
        "window.ace.edit(host)"
        "session.setMode(options.mode"
        "session.setUseWorker(assets.useWorker)"
        "showPrintMargin: false"
        "tabSize: 2"
        "useSoftTabs: true"
        "wrap: true"
        "addCommands(beautify.commands)"
        "bindKey('Ctrl-T', 'transposeletters')"
        "setDiagnostic"
        "onChange(listener)"
        "aria-label"
        "aria-labelledby"
        "aria-describedby"
        "aria-invalid"
    ==
  =/  tests=tang
    %-  zing
    %+  turn  needles
    |=  needle=tape
    (expect !>((has needle source)))
  ;:  weld
    tests
    (expect !>(?=(~ (find "DOT" source))))
  ==
::
++  test-persistence-and-url-import-contract
  =/  config-needles=(list tape)
    :~  "\"storageKey\":\"urui-fixture.session.v1\""
        "\"storageVersion\":1"
        "\"key\":\"paneWidth\""
        "\"key\":\"explorerWidth\""
        "\"key\":\"explorerOpen\""
        "\"key\":\"explorerView\""
        "\"key\":\"explorerOrder\""
        "\"key\":\"docsTabs\""
        "\"key\":\"nextDocs\""
        "\"key\":\"refTabs\""
        "\"key\":\"nextRef\""
        "\"owner\":\"urui\""
        "\"shape\":\"tabs\""
        "\"shareParam\""
        "\"name\":\"source\""
        "\"max\":12288"
        "\"paramMax\":16384"
    ==
  =/  api-needles=(list tape)
    :~  "session: methods('session', ['save', 'queue', 'get', 'set'])"
        "files: methods('files', ['browse', 'load', 'save', 'delete'])"
    ==
  =/  config-tests=tang
    %-  zing
    %+  turn  config-needles
    |=  needle=tape
    (expect !>((has needle config-source)))
  =/  api-tests=tang
    %-  zing
    %+  turn  api-needles
    |=  needle=tape
    (expect !>((has needle core-source)))
  (weld config-tests api-tests)
::
++  test-shell-runtime-contract
  ::  The runtime owns the frame urui emits, and names no consumer.
  =/  source  (trip runtime:ujs)
  =/  needles=(list tape)
    :~  "const config = window.URUI_CONFIG"
        "config.limits ||"
        "limits.paneMin ?? 25"
        "limits.paneMax ?? 70"
        "limits.minExplorer ?? 180"
        "limits.divider ?? 10"
        "limits.narrow ?? 760"
        "role('reference')"
        "#explorer-resizer"
        "#explorer-collapse"
        "#help-panel"
        "#close-help"
        "#clay-error-modal"
        "#clay-error-message"
        "#close-clay-error"
        "#splitter"
        "#workbench"
        "#workspace"
        "requestAnimationFrame"
        "themes.includes(candidate)"
        "root.dataset.effectiveTheme = effective"
        "root.style.colorScheme = effective"
        "prefers-color-scheme: dark"
        "--editor-width"
        "--explorer-width"
        "explorer-collapsed"
        "Collapse explorer"
        "Expand explorer"
        "aria-expanded"
        "errorReturnFocus"
        "function wire()"
        "if (options.onChange) options.onChange()"
        "else queueSaveSession()"
        "options.editors"
    ==
  =/  tests=tang
    %-  zing
    %+  turn  needles
    |=  needle=tape
    (expect !>((has needle source)))
  ;:  weld
    tests
    (expect !>((has "runtime: createRuntime" core-source)))
    (expect !>((has "function createRuntime(options =" core-source)))
    (expect !>(?=(~ (find "DOT" source))))
  ==
::
++  test-document-tab-contract
  ::  Tabs are parameterized over `config.kinds`; the strip markup and
  ::  the clay-leaf label rule belong to urui, not to a consumer.
  =/  source  (trip runtime:ujs)
  =/  needles=(list tape)
    :~  "const kinds = config.kinds"
        "unknown document kind:"
        "kind?.untitled"
        "leaf === kind.leaf"
        "document-tab-control"
        "document-tab-add-control"
        "data-document-tab"
        "aria-selected"
        "Unsaved changes; close tab"
        "Discard unsaved changes in"
        "effectAllowed = 'copyMove'"
        "dropEffect = 'move'"
        "is-dragging"
        "options.onTabsRendered"
        "syncExplorerTabOrder()"
        "tabHooks(name).onActivate"
        "tabHooks(name).afterActivate"
        "tabHooks(name).onCapture"
        "tabHooks(name).onClose"
    ==
  =/  tests=tang
    %-  zing
    %+  turn  needles
    |=  needle=tape
    (expect !>((has needle source)))
  ;:  weld
    tests
    (expect !>(?=(~ (find "dotTabs" source))))
    (expect !>(?=(~ (find "svgTabs" source))))
  ==
::
++  test-pane-contract
  ::  `config.panes` is the whole declaration: three panes, each an
  ::  ordered list of bands, one of them a stack of tab levels.  The
  ::  runtime reads names out of it and spells none of them itself.
  =/  source  (trip runtime:ujs)
  =/  needles=(list tape)
    :~  "config.panes"
        "'reference', 'editor', 'result'"
        "`$\{paneId}-$\{levelName}-tabs`"
        "`#$\{paneId}-$\{name}-toggle`"
        "band.item?.kind !== 'tabs'"
        "return band.item?.kind === kind"
        "paneItem(paneId, 'panel')"
        ::  mode, not a level, is what forbids the `+` and the close
        "mode === 'read-only'"
        "function levelAddLabel"
        "function levelCloses"
        "if (paneReadOnly(paneId)) return undefined"
        ::  the four sources a level's tabs come from
        "level.source === 'fixed'"
        "level.source === 'dynamic'"
        "level.source === 'documents'"
        "item.source === 'views'"
        ::  reveal is keyed by the band's own reveal.key
        "paneBands[reveal.key]"
        "case 'paneBands':"
        "case 'panePaths':"
        "function validBandRecord"
        "function validPathRecord"
        ::  depth, the generated chain, and the cached content panel
        "function levelChain"
        "function renderDeepLevels"
        "pane-levels"
        "pane-level-content"
        "dataset.paneTab"
        "dataset.paneDepth"
        "strip.dataset.depth = String(depth)"
        "function levelContent"
        "function attachContent"
        ::  the consumer's four hooks and the store binding
        "options.panes?.onSelect"
        "options.panes?.onAdd"
        "options.panes?.onClose"
        "options.panes?.onRendered"
        "function levelForKind"
        "function setLevelTabs"
        "function selectLevel"
    ==
  =/  tests=tang
    %-  zing
    %+  turn  needles
    |=  needle=tape
    (expect !>((has needle source)))
  ;:  weld
    tests
    (expect !>((has "\"panes\"" config-source)))
    (expect !>((has "panes: methods('panes', [" core-source)))
    ::  the `+` is declared, never hooked
    (expect !>(?=(~ (find "tabHooks(name).add" source))))
    ::  and no pane, band, or level name is spelled in the runtime
    (expect !>(?=(~ (find "explorer-view-tabs" source))))
    (expect !>(?=(~ (find "editorControls" source))))
  ==
::
++  test-explorer-contract
  ::  One strip holds the permanent file trees, documentation tabs and
  ::  reference tabs; the tree, its context menu, and the `doc.toc`
  ::  format are urui's, and none of it names a consumer.
  =/  source  (trip runtime:ujs)
  =/  needles=(list tape)
    :~  "config.permanentViews"
        "config.docsRoot"
        "config.appId?.title"
        "data-explorer-view"
        "explorerTabId"
        "docs-tab-control"
        "ref-tab-control"
        "docs-explorer-panel"
        "ref-explorer-panel"
        "docs-explorer-frame"
        "ref-source"
        "aria-labelledby"
        "reference'"
        "explorer-file-row"
        "file-tree-file"
        "file-tree-actions"
        "file-tree-directory"
        "file-tree-list"
        "Invalid Clay file list"
        "Enter a relative Clay path"
        "Clay path contains unsupported characters"
        "Unable to load files:"
        "aria-haspopup"
        "docs-help-group"
        "docs-help-summary"
        "docs-help-subnav"
        "docs-help-link"
        "doc.toc"
        "text/plain"
        "browseClayNode(name)"
        "loadFile(name, path)"
        "kindByName.get(name)?.leaf"
    ==
  =/  tests=tang
    %-  zing
    %+  turn  needles
    |=  needle=tape
    (expect !>((has needle source)))
  ;:  weld
    tests
    (expect !>(?=(~ (find "dot-files" source))))
    (expect !>(?=(~ (find "svg-files" source))))
  ==
::
++  test-session-contract
  ::  The record is described slot by slot by `config.slots`, each slot
  ::  naming the json key already on disk, so no migration is written.
  =/  source  (trip runtime:ujs)
  =/  needles=(list tape)
    :~  "config.appId?.storageKey"
        "config.appId?.storageVersion"
        "config.slots"
        "config.shareParam"
        "saved.version !== storageVersion"
        "localStorage.setItem(storageKey"
        "localStorage.getItem(storageKey)"
        "readEnvelope"
        "writeEnvelope"
        "key.split('.')"
        "slot.owner === 'app'"
        "options.session?.read?.(slot.key)"
        "options.session?.validate?.(slot.key, raw)"
        "tabHooks(name).validate"
        "highestId"
        "Number.isSafeInteger(value)"
        "limits.saveDebounce ?? 150"
        "beforeunload"
        "Source must be text"
        "Source contains a null byte"
        "-byte limit"
        "TextEncoder"
        "TextDecoder"
        "is not canonical"
        "searchParams.get(share.name)"
        "applySession(record)"
    ==
  =/  tests=tang
    %-  zing
    %+  turn  needles
    |=  needle=tape
    (expect !>((has needle source)))
  ;:  weld
    tests
    ::  the slot keys are data, never spelled out in the runtime
    (expect !>(?=(~ (find "dotTabs" source))))
    (expect !>(?=(~ (find "activeDotTabId" source))))
    (expect !>(?=(~ (find "autoRender" source))))
    (expect !>(?=(~ (find "DOT" source))))
  ==
::
++  test-files-contract
  =/  source  (trip files:ujs)
  =/  needles=(list tape)
    :~  "config.endpoints"
        "endpoints.transport"
        "path.split('/')"
        "endpoints.pathHeader"
        "endpoints.flagHeader"
        "route.replaceAll('\{kind}', name)"
        "response.status === 409"
        "changed in Clay since it was loaded"
        "Delete $\{path}? This cannot be undone."
        "tab.cleanSource = source"
        "await refreshFileTree(name)"
        "hooks.saved?.(tab, source)"
    ==
  %-  zing
  %+  turn  needles
  |=  needle=tape
  (expect !>((has needle source)))
::
++  test-shortcut-contract
  =/  source  (trip shortcuts:ujs)
  =/  needles=(list tape)
    :~  "shortcutCommands.set(command, handler)"
        "config.shortcuts"
        "contexts[shortcut.when]"
        "helpIsOpen()"
        "errorIsOpen()"
        "closeFileContext(true)"
        "parts.includes('alt')"
        "editor.isFocused?.(target)"
        "if (inEditor) return"
        "handler(event)"
    ==
  %-  zing
  %+  turn  needles
  |=  needle=tape
  (expect !>((has needle source)))
--
