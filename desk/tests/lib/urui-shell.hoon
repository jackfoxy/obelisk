::  Tests for /lib/urui-shell.
::
::  The shell is asserted structurally — tags, attributes, and order — not
::  by searching the rendered text.  A substring test passes when the same
::  id appears in the wrong element, which is exactly the mistake a frame
::  rewrite could make.
::
::  The spec below is a probe, not the browser fixture: keeping it here
::  lets `-test /=urui=/tests ~` run against the source desk alone, with no
::  consumer staged in.  The fixture covers the same ground through a real
::  agent in /tests/app/urui-fixture.
::
/-  urui
/+  *test, shell=urui-shell
|%
::
++  config
  ^-  app-config:urui
  %*  .  *app-config:urui
    name.app-id   %probe
    title.app-id  'Probe'
  ==
::
++  pinned
  ::  A band the user cannot hide: no reveal key, so no toggle.
  |=  [name=@tas item=band-item:urui]
  ^-  band:urui
  [name [key=~ open=& label=''] item]
::
++  hideable
  ::  A band the user can hide, persisted under `key`.
  |=  [name=@tas key=@t open=? label=@t item=band-item:urui]
  ^-  band:urui
  [name [`key open label] item]
::
++  reference-pane
  ::  Read-only, heading above a seeded strip: the other ordering from
  ::  the editor pane below, and the branch with no status line.
  ^-  pane:urui
  :*  role=%reference
      id='probe-reference'
      label='Probe reference'
      mode=%read-only
      kind=~
      :~  (pinned %head [%heading `'Files' ~ ~])
          (pinned %tabs [%tabs ~[reference-level]])
          %+  pinned  %body
          [%panel 'probe-reference-body' ~ ~[;div#probe-tree.tree;]]
      ==
  ==
::
++  reference-level
  ::  %fixed in the compact spec; ++full-spec swaps it for %views, which
  ::  is the one difference that picks the explorer frame.
  ^-  tab-level:urui
  :*  name=%view
      label='Probe views'
      source=%fixed
      kind=~
      fixed=~[[%text-files 'Text Files'] [%note-files 'Note Files']]
      add=~
      close=|
      reorder=|
  ==
::
++  editor-pane
  ::  Heading *below* the tabs, a hidden controls band, and a status
  ::  line: the three branches the reference pane does not take.
  ^-  pane:urui
  :*  role=%editor
      id='probe-editor'
      label='Probe editor'
      mode=%read-write
      kind=`%text
      :~  (pinned %tabs [%tabs ~[editor-level]])
          (pinned %head [%heading `'Source' `'probe-status' editor-actions])
          %:  hideable
            %extra
            'probeExtra'
            open=|
            label='Probe extra controls'
            [%controls ~[;button#probe-extra(type "button"):"Extra"]]
          ==
          (pinned %body [%panel 'probe-source' ~ ~[;div#probe-source.source;]])
      ==
  ==
::
++  editor-actions
  ^-  marl
  :~  ;button#probe-save(type "button"):"Save"
  ==
::
++  editor-level
  ^-  tab-level:urui
  :*  name=%doc
      label='Open Text documents'
      source=%documents
      kind=`%text
      fixed=~
      add=`'Add empty Text tab'
      close=&
      reorder=&
  ==
::
++  result-pane
  ^-  pane:urui
  :*  role=%result
      id='probe-result'
      label='Probe result'
      mode=%read-write
      kind=`%note
      :~  (pinned %head [%heading `'Result' ~ ~])
          (pinned %tabs [%tabs ~[result-level]])
          %+  pinned  %body
          [%panel 'probe-output' `secondary-editor ~[;pre#probe-report.output;]]
      ==
  ==
::
++  result-level
  ^-  tab-level:urui
  :*  name=%note
      label='Open Note documents'
      source=%documents
      kind=`%note
      fixed=~
      add=~
      close=|
      reorder=|
  ==
::
++  secondary-editor
  ^-  editor:urui
  :*  id='probe-secondary'
      label='Probe secondary'
      mode='ace/mode/text'
      wrap=&
      read-only=|
      max-bytes=1.024
  ==
::
++  spec
  ^-  shell-spec:urui
  :*  config
      brand=~[;h1.brand:"Probe"]
      toolbar=~[;button#probe-run(type "button"):"Run"]
      [reference-pane editor-pane result-pane]
      help=~[;p.probe-help:"nothing to see"]
      dialogs=~[;div#probe-dialog.dialog;]
      styles=~['/probe/app.css']
      scripts=~['/probe/app.js' '/probe/extra.js']
  ==
::
++  doc  (build:shell spec)
::
++  full-config
  ^-  app-config:urui
  %*  .  config
    storage-key.app-id      'probe.session.v1'
    storage-version.app-id  1
    kinds
      :~  :*  name=%text
              label='Text'
              untitled='Untitled'
              ext=%txt
              leaf=%txt
              mime='text/plain'
              tabs=&
              refs=&
          ==
          :*  name=%note
              label='Note'
              untitled='Preview'
              ext=%md
              leaf=%md
              mime='text/markdown'
              tabs=&
              refs=&
          ==
      ==
    statuses  ~[[%ready 'Ready'] [%busy 'Busy'] [%empty 'Empty']]
  ==
::
++  full-spec
  ::  The same three panes with the reference level switched to %views:
  ::  ++build reads that one field to choose the explorer frame.
  ^-  shell-spec:urui
  =/  full-reference=pane:urui
    %*  .  reference-pane
      bands
        :~  (pinned %tabs [%tabs ~[%*(. reference-level source %views)]])
            (pinned %ship [%label 'probe-ship'])
            %+  pinned  %body
            [%panel 'probe-reference-body' ~ ~[;div#probe-tree.tree;]]
        ==
    ==
  =/  full-editor=pane:urui
    %*  .  editor-pane
      bands
        :~  (pinned %tabs [%tabs ~[editor-level]])
            (pinned %head [%heading `'Source' `'probe-status' editor-actions])
            %:  hideable
              %extra
              'probeExtra'
              open=|
              label='Probe extra controls'
              [%controls ~[;button#probe-extra(type "button"):"Extra"]]
            ==
            %+  pinned  %body
            :*  %panel  'probe-source'  ~
                :~  ;p#editor-load-error(hidden "", role "alert");
                    ;div#probe-source.source;
                ==
            ==
        ==
    ==
  =/  fixture-toolbar=marl
    ::  no theme control: urui's settings modal owns it now
    :~  ;nav.toolbar(aria-label "Fixture controls")
          ;button#help(type "button", aria-expanded "false"): Help
        ==
    ==
  =/  fixture-help=marl
    :~  ;div#fallback-help-content
          ;p: Consumer-neutral fallback help.
        ==
        ;div#docs-help-content.docs-help-content(hidden "")
          ;nav#docs-help-nav.docs-help-nav
            =aria-label  "Fixture documentation"
            =aria-busy   "true"
            ;p.docs-help-loading: Loading documentation…
          ==
        ==
    ==
  :*  full-config
      brand=~[;h1.brand:"Probe"]
      fixture-toolbar
      [full-reference full-editor result-pane]
      fixture-help
      dialogs=~[;div#probe-dialog.dialog;]
      styles=~['body { color: black; }']
      scripts=~['/probe/app.js']
  ==
::
++  full-doc  (build:shell full-spec)
::
++  fixture-spec  full-spec
::
++  fixture-doc  (build:shell fixture-spec)
::
++  elements
  ::  Every element with this tag, depth first.
  ::
  ::  The recursive results are bound before `weld` sees them: `weld` is a
  ::  wet gate, and a bare `^$` in its argument mulls against a type that
  ::  is still being computed.
  |=  [top=manx name=@tas]
  ^-  (list manx)
  =/  here=(list manx)  ?:(=(name n.g.top) ~[top] ~)
  =/  below=(list manx)
    |-  ^-  (list manx)
    ?~  c.top  ~
    =/  head=(list manx)  ^$(top i.c.top)
    =/  rest=(list manx)  $(c.top t.c.top)
    (weld head rest)
  (weld here below)
::
++  attribute
  ::  One attribute's value, or "" when absent.
  |=  [=manx name=@tas]
  ^-  tape
  =/  found  (skim a.g.manx |=([n=mane v=tape] =(name n)))
  ?~  found  ""
  v.i.found
::
++  has-attribute
  |=  [=manx name=@tas]
  ^-  ?
  ?=(^ (skim a.g.manx |=([n=mane v=tape] =(name n))))
::
++  has-id
  |=  [nodes=(list manx) id=tape]
  ^-  ?
  ?=(^ (skim nodes |=(kid=manx =(id (attribute kid %id)))))
::
++  node-by-id
  ::  The first element with this id, depth first.
  |=  [top=manx id=tape]
  ^-  (unit manx)
  ?:  =(id (attribute top %id))  `top
  =/  children=(list manx)  c.top
  |-
  ?~  children  ~
  =/  found=(unit manx)  ^$(top i.children)
  ?^  found  found
  $(children t.children)
::
++  has-node-id
  |=  [top=manx id=tape]
  ^-  ?
  ?=(^ (node-by-id top id))
::
++  panes
  ::  The three pane sections of the compact frame, in document order.
  ^-  (list manx)
  =/  shells  (elements doc %main)
  ?~  shells  ~
  %+  skim  c.i.shells
  |=(=manx =(%section n.g.manx))
::
++  bands-of
  ::  Every band wrapper inside one pane, in document order.
  ::
  ::  `top`, not `=manx`, for the reason ++text-of gives: a face of that
  ::  name shadows the mold the inner gate's sample needs.
  |=  top=manx
  ^-  (list manx)
  %+  skim  c.top
  |=(kid=manx ?=(^ (find "pane-band" (attribute kid %class))))
::
++  text-of
  ::  The concatenated text of an element's immediate children.
  ::
  ::  `top`, not `=manx`: a face of that name would shadow the mold, and
  ::  the inner gate's `kid=manx` would then be a noun used as a gate.
  |=  top=manx
  ^-  tape
  %-  zing
  %+  turn  c.top
  |=  kid=manx
  ^-  tape
  ?.  =(%$ n.g.kid)  ""
  =/  found  (skim a.g.kid |=([n=mane v=tape] =(%$ n)))
  ?~(found "" v.i.found)
::
++  test-shell-page
  ::  Shared page contract, exercised through the fixture-shaped spec.
  =/  ids=(list tape)
    :~  "probe-reference"
        "probe-reference-view-tabs"
        "explorer-collapse"
        "text-files-tab"
        "note-files-tab"
        "text-files-tree"
        "note-files-tree"
        "explorer-resizer"
        "workspace"
        "splitter"
        "probe-editor"
        "probe-result"
        "probe-editor-doc-tabs"
        "probe-result-note-tabs"
        "probe-secondary"
        "editor-load-error"
        "settings"
        "settings-modal"
        "theme"
        "keys-ace"
        "keys-vim"
        "layout-columns"
        "layout-rows"
        "help"
        "help-panel"
        "fallback-help-content"
        "docs-help-content"
        "docs-help-nav"
        "file-context-menu"
        "file-context-open"
        "file-context-delete"
        "clay-error-modal"
        "clay-error-message"
        "probe-status"
        "probe-save"
    ==
  =/  dialogs=(list manx)
    %+  skim  (elements fixture-doc %aside)
    |=(kid=manx =("dialog" (attribute kid %role)))
  =/  options  (elements fixture-doc %option)
  =/  id-tests=tang
    %-  zing
    %+  turn  ids
    |=  id=tape
    (expect !>((has-node-id fixture-doc id)))
  ;:  weld
    id-tests
    (expect-eq !>(3) !>((lent dialogs)))
    (expect-eq !>("true") !>((attribute (snag 0 dialogs) %aria-modal)))
    (expect-eq !>("true") !>((attribute (snag 1 dialogs) %aria-modal)))
    (expect-eq !>("true") !>((attribute (snag 2 dialogs) %aria-modal)))
    ::  one theme control in the page, and it is urui's: a consumer that
    ::  still emitted its own would double these options
    (expect-eq !>(3) !>((lent options)))
    (expect-eq !>("system") !>((attribute (snag 0 options) %value)))
    (expect-eq !>("light") !>((attribute (snag 1 options) %value)))
    (expect-eq !>("dark") !>((attribute (snag 2 options) %value)))
    (expect-eq !>(0) !>((lent (elements fixture-doc %iframe))))
  ==
::
++  test-shell-emits-three-panes-in-document-order
  =/  found  panes
  ;:  weld
    (expect-eq !>(3) !>((lent found)))
    (expect-eq !>("probe-reference") !>((attribute (snag 0 found) %id)))
    (expect-eq !>("probe-editor") !>((attribute (snag 1 found) %id)))
    (expect-eq !>("probe-result") !>((attribute (snag 2 found) %id)))
  ==
::
++  test-shell-pane-carries-role-label-and-mode
  =/  found  panes
  =/  first  (snag 0 found)
  ;:  weld
    (expect-eq !>("region") !>((attribute first %role)))
    (expect-eq !>("Probe reference") !>((attribute first %aria-label)))
    (expect-eq !>("reference") !>((attribute first %data-role)))
    (expect-eq !>("read-only") !>((attribute first %data-mode)))
    (expect-eq !>("pane reference-pane") !>((attribute first %class)))
    (expect-eq !>("editor") !>((attribute (snag 1 found) %data-role)))
    (expect-eq !>("read-write") !>((attribute (snag 1 found) %data-mode)))
    (expect-eq !>("pane editor-pane") !>((attribute (snag 1 found) %class)))
    (expect-eq !>("result") !>((attribute (snag 2 found) %data-role)))
    (expect-eq !>("pane preview-pane") !>((attribute (snag 2 found) %class)))
  ==
::
++  test-shell-stacks-bands-in-declared-order
  ::  Band order is the layout: the reference pane's heading is above its
  ::  tabs and the editor pane's is below, from the same two items.
  =/  found  panes
  =/  names
    |=  top=manx
    ^-  (list tape)
    %+  turn  (bands-of top)
    |=(kid=manx (attribute kid %data-band))
  =/  ids
    |=  top=manx
    ^-  (list tape)
    %+  turn  (bands-of top)
    |=(kid=manx (attribute kid %id))
  ::  every band wrapper is `{pane}-{band}`
  =/  wanted=(list tape)
    :~  "probe-reference-head"
        "probe-reference-tabs"
        "probe-reference-body"
    ==
  ;:  weld
    (expect-eq !>(~["head" "tabs" "body"]) !>((names (snag 0 found))))
    (expect-eq !>(~["tabs" "head" "extra" "body"]) !>((names (snag 1 found))))
    (expect-eq !>(~["head" "tabs" "body"]) !>((names (snag 2 found))))
    (expect-eq !>(wanted) !>((ids (snag 0 found))))
  ==
::
++  test-shell-heading-band-carries-title-status-and-actions
  =/  found  panes
  =/  editor  (snag 1 found)
  =/  header
    %-  head
    %+  skim  (bands-of editor)
    |=(kid=manx =("tabs" (attribute kid %data-band)))
  =/  head-band
    %-  head
    %+  skim  (bands-of editor)
    |=(kid=manx =("head" (attribute kid %data-band)))
  =/  titled  (elements head-band %h2)
  =/  status  (elements head-band %span)
  =/  actions
    %+  skim  (elements head-band %div)
    |=(kid=manx =("pane-actions" (attribute kid %class)))
  ;:  weld
    (expect-eq !>("pane-band pane-header") !>((attribute head-band %class)))
    (expect-eq !>(1) !>((lent titled)))
    (expect-eq !>("Source") !>((text-of (snag 0 titled))))
    ::  an editor pane's title is what its Ace host labels itself by
    (expect-eq !>("text-source-heading") !>((attribute (snag 0 titled) %id)))
    (expect-eq !>(1) !>((lent status)))
    (expect-eq !>("probe-status") !>((attribute (snag 0 status) %id)))
    (expect-eq !>("status") !>((attribute (snag 0 status) %role)))
    (expect-eq !>(1) !>((lent actions)))
    %-  expect-eq
    :-  !>("probe-save")
    !>((attribute (head (elements (head actions) %button)) %id))
    ::  the tabs band above it carries no heading of its own
    (expect-eq !>(0) !>((lent (elements header %h2))))
  ==
::
++  test-shell-heading-without-actions-emits-no-action-row
  =/  found  panes
  =/  head-band
    %-  head
    %+  skim  (bands-of (snag 0 found))
    |=(kid=manx =("head" (attribute kid %data-band)))
  ::  ++elements counts the band wrapper itself, so an empty heading band
  ::  is one div: the wrapper, with no action row inside it
  =/  inside  (elements head-band %div)
  ;:  weld
    (expect-eq !>(1) !>((lent (elements head-band %h2))))
    (expect-eq !>(0) !>((lent (elements head-band %span))))
    (expect-eq !>(1) !>((lent inside)))
    (expect-eq !>("pane-band pane-header") !>((attribute (head inside) %class)))
  ==
::
++  test-shell-reveal-emits-a-toggle-and-hides-a-closed-band
  ::  A band with a reveal key gets `{pane}-{band}-toggle` as its
  ::  *sibling*, so hiding the band cannot hide its own control.
  =/  found  panes
  =/  editor  (snag 1 found)
  =/  extra
    %-  head
    %+  skim  (bands-of editor)
    |=(kid=manx =("extra" (attribute kid %data-band)))
  =/  toggles
    %+  skim  (elements editor %button)
    |=(kid=manx =("probe-editor-extra-toggle" (attribute kid %id)))
  =/  toggle  (head toggles)
  ;:  weld
    (expect-eq !>(1) !>((lent toggles)))
    (expect-eq !>("probe-editor-extra") !>((attribute toggle %aria-controls)))
    (expect-eq !>("false") !>((attribute toggle %aria-expanded)))
    (expect-eq !>("Probe extra controls") !>((attribute toggle %title)))
    (expect !>((has-attribute extra %hidden)))
    ::  and a pinned band has neither toggle nor hidden flag
    (expect-eq !>(%.n) !>((has-attribute (head (bands-of editor)) %hidden)))
  ==
::
++  test-shell-tab-strip-is-one-per-pane-at-depth-zero
  =/  found  panes
  =/  strips
    |=  top=manx
    ^-  (list manx)
    %+  skim  (elements top %div)
    |=(kid=manx ?=(^ (find "tab-strip" (attribute kid %class))))
  =/  counts  (turn found |=(top=manx (lent (strips top))))
  =/  first  (head (strips (snag 0 found)))
  ;:  weld
    (expect-eq !>(~[1 1 1]) !>(counts))
    ::  the strip is named for its pane and its level, so no two collide
    (expect-eq !>("probe-reference-view-tabs") !>((attribute first %id)))
    (expect-eq !>("tablist") !>((attribute first %role)))
    (expect-eq !>("0") !>((attribute first %data-depth)))
    (expect-eq !>("fixed") !>((attribute first %data-source)))
    (expect-eq !>("Probe views") !>((attribute first %aria-label)))
    %-  expect-eq
    :-  !>("documents")
    !>((attribute (head (strips (snag 1 found))) %data-source))
  ==
::
++  test-shell-panel-band-hosts-the-ace-editor
  =/  found  panes
  =/  hosts
    |=  top=manx
    ^-  (list manx)
    %+  skim  (elements top %div)
    |=(kid=manx =("editor-host" (attribute kid %class)))
  =/  counts  (turn found |=(top=manx (lent (hosts top))))
  =/  host  (head (hosts (snag 2 found)))
  =/  body
    %-  head
    %+  skim  (elements (snag 2 found) %div)
    |=(kid=manx =("pane-body" (attribute kid %class)))
  ;:  weld
    (expect-eq !>(~[0 0 1]) !>(counts))
    (expect-eq !>("probe-secondary") !>((attribute host %id)))
    (expect-eq !>("Probe secondary") !>((attribute host %aria-label)))
    (expect-eq !>("ace/mode/text") !>((attribute host %data-mode)))
    ::  the panel's own id is the one a consumer addresses it by
    (expect-eq !>("probe-output") !>((attribute body %id)))
  ==
::
++  test-shell-splices-consumer-body-and-controls
  =/  found  panes
  =/  bodies
    %+  skim  (elements (snag 1 found) %div)
    |=(kid=manx =("pane-body" (attribute kid %class)))
  ::  ++elements counts the pane body itself, so the consumer's own div is
  ::  the second hit: it is inside the body, not beside it
  =/  inside=(list manx)  (elements (head bodies) %div)
  =/  extra
    %-  head
    %+  skim  (bands-of (snag 1 found))
    |=(kid=manx =("extra" (attribute kid %data-band)))
  ;:  weld
    (expect-eq !>(2) !>((lent inside)))
    (expect-eq !>("probe-source") !>((attribute (snag 1 inside) %id)))
    ::  a %controls band is the row itself: its marl is spliced bare
    (expect-eq !>(1) !>((lent (elements extra %button))))
    %-  expect-eq
    :-  !>("probe-extra")
    !>((attribute (head (elements extra %button)) %id))
  ==
::
++  test-shell-label-band-emits-one-line-of-text
  =/  labels
    %+  skim  (elements full-doc %span)
    |=(kid=manx =("pane-label" (attribute kid %class)))
  ;:  weld
    (expect-eq !>(1) !>((lent labels)))
    (expect-eq !>("probe-ship") !>((text-of (head labels))))
  ==
::
++  test-shell-emits-scripts-in-list-order
  =/  scripts  (elements doc %script)
  ;:  weld
    (expect-eq !>(2) !>((lent scripts)))
    (expect-eq !>("/probe/app.js") !>((attribute (snag 0 scripts) %src)))
    (expect-eq !>("/probe/extra.js") !>((attribute (snag 1 scripts) %src)))
  ==
::
++  test-shell-emits-styles-as-stylesheet-links
  =/  links  (elements doc %link)
  ;:  weld
    (expect-eq !>(1) !>((lent links)))
    (expect-eq !>("stylesheet") !>((attribute (snag 0 links) %rel)))
    (expect-eq !>("/probe/app.css") !>((attribute (snag 0 links) %href)))
  ==
::
++  test-shell-titles-the-document-from-the-app-id
  =/  titles  (elements doc %title)
  =/  frame=manx  (head (elements doc %body))
  ;:  weld
    (expect-eq !>(1) !>((lent titles)))
    (expect-eq !>("Probe") !>((text-of (snag 0 titles))))
    (expect-eq !>("probe") !>((attribute frame %data-app)))
  ==
::
++  test-shell-hides-the-help-container
  =/  helps
    %+  skim  (elements doc %div)
    |=(=manx =("app-help" (attribute manx %class)))
  ;:  weld
    (expect-eq !>(1) !>((lent helps)))
    (expect !>((has-attribute (head helps) %hidden)))
    (expect-eq !>(1) !>((lent (elements (head helps) %p))))
  ==
::
++  test-shell-splices-consumer-dialogs
  =/  holders
    %+  skim  (elements doc %div)
    |=(=manx =("app-dialogs" (attribute manx %class)))
  =/  inside=(list manx)  (elements (head holders) %div)
  ;:  weld
    (expect-eq !>(1) !>((lent holders)))
    (expect-eq !>("probe-dialog") !>((attribute (snag 1 inside) %id)))
  ==
::
++  test-full-shell-is-chosen-by-the-views-level
  ::  The only difference between the two specs is `source=%views` on the
  ::  reference level, and that is what swaps the section for an aside.
  =/  compact-asides
    %+  skim  (elements doc %aside)
    |=(kid=manx =("probe-reference" (attribute kid %id)))
  =/  full-asides
    %+  skim  (elements full-doc %aside)
    |=(kid=manx =("probe-reference" (attribute kid %id)))
  ;:  weld
    (expect-eq !>(0) !>((lent compact-asides)))
    (expect-eq !>(1) !>((lent full-asides)))
    %-  expect-eq
    :-  !>("explorer-pane")
    !>((attribute (head full-asides) %class))
  ==
::
++  test-full-shell-emits-explorer-regions
  =/  asides  (elements full-doc %aside)
  =/  tabs  (elements full-doc %button)
  =/  panels
    %+  skim  (elements (snag 0 asides) %div)
    |=(kid=manx =("explorer-panel" (attribute kid %class)))
  ;:  weld
    (expect-eq !>("probe-reference") !>((attribute (snag 0 asides) %id)))
    (expect-eq !>(%.y) !>((has-id tabs "text-files-tab")))
    (expect-eq !>(%.y) !>((has-id tabs "note-files-tab")))
    (expect-eq !>(2) !>((lent panels)))
  ==
::
++  test-full-shell-emits-workspace-and-resizers
  =/  sections  (elements full-doc %section)
  =/  separators
    %+  skim  ;:  weld  (elements full-doc %button)
                       (elements full-doc %div)
             ==
    |=(kid=manx =("separator" (attribute kid %role)))
  ;:  weld
    (expect-eq !>(%.y) !>((has-id sections "workspace")))
    (expect-eq !>(2) !>((lent separators)))
    (expect-eq !>("explorer-resizer") !>((attribute (snag 0 separators) %id)))
    (expect-eq !>("splitter") !>((attribute (snag 1 separators) %id)))
  ==
::
++  test-full-shell-emits-one-strip-per-pane
  =/  strips
    %+  skim  (elements full-doc %div)
    |=(kid=manx ?=(^ (find "tab-strip" (attribute kid %class))))
  =/  explorer
    %+  skim  (elements full-doc %div)
    |=(kid=manx =("explorer-tabs" (attribute kid %class)))
  ;:  weld
    ::  two document strips; the explorer's carries its own class
    (expect-eq !>(2) !>((lent strips)))
    (expect-eq !>("probe-editor-doc-tabs") !>((attribute (snag 0 strips) %id)))
    (expect-eq !>("probe-result-note-tabs") !>((attribute (snag 1 strips) %id)))
    (expect-eq !>(1) !>((lent explorer)))
    %-  expect-eq
    :-  !>("probe-reference-view-tabs")
    !>((attribute (head explorer) %id))
  ==
::
++  test-full-shell-emits-help-and-dialogs
  =/  dialogs
    %+  skim  (elements full-doc %aside)
    |=(kid=manx =("dialog" (attribute kid %role)))
  =/  menus
    %+  skim  (elements full-doc %div)
    |=(kid=manx =("menu" (attribute kid %role)))
  ;:  weld
    (expect-eq !>(3) !>((lent dialogs)))
    (expect-eq !>("settings-modal") !>((attribute (snag 0 dialogs) %id)))
    (expect-eq !>("help-panel") !>((attribute (snag 1 dialogs) %id)))
    (expect-eq !>("clay-error-modal") !>((attribute (snag 2 dialogs) %id)))
    (expect-eq !>(1) !>((lent menus)))
    (expect-eq !>("file-context-menu") !>((attribute (head menus) %id)))
  ==
::
++  test-full-shell-emits-prepaint-style-and-assets
  =/  scripts  (elements full-doc %script)
  =/  styles  (elements full-doc %style)
  ;:  weld
    (expect-eq !>(2) !>((lent scripts)))
    (expect-eq !>("") !>((attribute (snag 0 scripts) %src)))
    (expect-eq !>("/probe/app.js") !>((attribute (snag 1 scripts) %src)))
    (expect-eq !>(1) !>((lent styles)))
  ==
::
++  test-full-shell-starts-in-the-configured-format
  ::  The page is drawn in the consumer's format, so the first paint
  ::  already has it; the default spec asks for columns.
  =/  rows-spec=shell-spec:urui
    %*(. full-spec layout.app-config %rows)
  =/  rows-doc  (build:shell rows-spec)
  =/  workspace  (need (node-by-id full-doc "workspace"))
  =/  splitter  (need (node-by-id full-doc "splitter"))
  =/  rows-workspace  (need (node-by-id rows-doc "workspace"))
  =/  rows-splitter  (need (node-by-id rows-doc "splitter"))
  ;:  weld
    (expect-eq !>("columns") !>((attribute workspace %data-layout)))
    (expect-eq !>("vertical") !>((attribute splitter %aria-orientation)))
    (expect-eq !>("rows") !>((attribute rows-workspace %data-layout)))
    %+  expect-eq  !>("horizontal")
    !>((attribute rows-splitter %aria-orientation))
  ==
::
++  test-full-shell-collapse-is-the-result-heading-last-action
  ::  Off by default.  On, it is the last action in the result pane's
  ::  heading — an action row is made for it when the consumer gave
  ::  none — and no other pane gets one.
  =/  on-spec=shell-spec:urui
    %*  .  full-spec
      collapse.app-config  &
      layout.app-config    %rows
    ==
  =/  on-doc  (build:shell on-spec)
  =/  result  (need (node-by-id on-doc "probe-result"))
  =/  head-band
    %-  head
    %+  skim  (bands-of result)
    |=(kid=manx =("head" (attribute kid %data-band)))
  =/  actions
    %+  skim  (elements head-band %div)
    |=(kid=manx =("pane-actions" (attribute kid %class)))
  =/  buttons  (elements (head actions) %button)
  =/  control  (rear buttons)
  =/  collapses
    %+  skim  (elements on-doc %button)
    |=(kid=manx =("result-collapse" (attribute kid %id)))
  ;:  weld
    (expect !>(!(has-node-id full-doc "result-collapse")))
    (expect-eq !>(1) !>((lent collapses)))
    (expect-eq !>(1) !>((lent actions)))
    (expect-eq !>("result-collapse") !>((attribute control %id)))
    %+  expect-eq  !>("Collapse Probe result")
    !>((attribute control %aria-label))
    (expect-eq !>("true") !>((attribute control %aria-expanded)))
    (expect-eq !>("⌄") !>((text-of control)))
  ==
--
